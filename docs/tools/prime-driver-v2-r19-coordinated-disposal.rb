#!/usr/bin/ruby

# Retired 2026-09-20: this frozen helper has unbounded process, pipe,
# or recovery waits. Reject before bootstrap intake, file access, or signals.
# Original Git blob: 7f2cef7ff309b1b814ed8c797dd6aa46c5b7b4b1.
# Existing live instances and historical copies are unaffected.
begin
  STDERR.write_nonblock(
    "{\"schema\":\"prime-v2-historical-helper-retirement/v1\"," \
    "\"helper\":\"prime-driver-v2-r19-coordinated-disposal.rb\"," \
    "\"status\":\"RETIRED\",\"launch_allowed\":false," \
    "\"gate_e_outcome\":\"ABSTAIN\",\"gate_e_clearance\":0}\n",
    exception: false
  )
rescue IOError, SystemCallError
  # Diagnostic failure or a full pipe must not delay retirement.
ensure
  Process.exit!(70)
end

# Safety-only Workstation controller for the permanently consumed, nonterminal
# R19 mechanics invocation. This file does not interpret scientific evidence,
# close authority, retry R19, launch a child, or own either retained process.

BOOTSTRAP_ENV = {
  "LANG" => "C.UTF-8",
  "LC_ALL" => "C.UTF-8",
  "TZ" => "UTC",
  "PATH" => "/usr/bin:/bin",
  "__CF_USER_TEXT_ENCODING" => "0x1F5:0x0:0x0",
}.freeze

CONTROL_CWD =
  "/Users/ergentics/Documents/Codex/2026-08-09/" \
  "resume-latin-roadmap-pr45/.phase-a-v2-fixture-identity-restore-only-staging"
CONTROLLER =
  "#{CONTROL_CWD}/docs/tools/prime-driver-v2-r19-coordinated-disposal.rb"
SOURCE =
  "/Users/ergentics/Documents/Codex/2026-08-09/" \
  "resume-latin-roadmap-pr45/.driver-v2-gate-c-staging"
PACKAGE = "#{SOURCE}/Tests/PrimeValidationWorkflow"
BUILD = "#{PACKAGE}/.build"
FIXTURE =
  "#{BUILD}/arm64-apple-macosx/release/" \
  "PrimeValidationWorkflowDriverV2SessionFixture"
RUBY_IMAGE = "/usr/bin/ruby"
PRIVATE_TMP = "/private/tmp"
DISPOSAL_LEAF =
  "gate-e1-4-r19-coordinated-disposal-11a5dce6-8930176-8930235"
DISPOSAL_ROOT = "#{PRIVATE_TMP}/#{DISPOSAL_LEAF}"
EPOCH =
  "/private/tmp/gate-e1-4-mechanics-r19-befc6324-b501ad0d7ab1b6c5"
GUARDIAN_TERMINAL_LEAF = "r19-guardian-terminal.json"
GUARDIAN_TERMINAL = "#{EPOCH}/#{GUARDIAN_TERMINAL_LEAF}"
GUARDIAN_STAGING =
  /\Ar19-guardian-terminal\.[A-Za-z0-9]{6}\.staging\z/
FIXTURE_WORKSPACE =
  "/private/tmp/" \
  "prime-validation-admission-tests-369E97E5-AAF3-4267-B810-BA92ADB20BD1/" \
  "workspace"
FAIL_STOP_LEAF = "gate-e-session-fixture-fail-stop.json"
FAIL_STOP = "#{File.dirname(FIXTURE_WORKSPACE)}/#{FAIL_STOP_LEAF}"

CONTROL_FREEZE_COMMIT =
  "c3b155f648b6abcaca734eb34d6a38837d150571"
CONTROL_FREEZE_TREE =
  "2280af710cbb54acbf751496ef35d032c6dddd6f"
SOURCE_COMMIT = "befc632485930a9cca7f618d3704292b5465f911"
SOURCE_TREE = "7d1a3bf302fe358f9e42dc1ed2bf54ed3d22982e"

EXPECTED_UID = 501
EXPECTED_GID = 20
EXPECTED_GROUPS = [
  12, 20, 33, 61, 79, 80, 81, 98, 100, 204, 250, 395, 398, 399, 400, 701,
].freeze
PRIVATE_TMP_IDENTITY = [16_777_231, 774_813].freeze
CONTROL_CWD_IDENTITY = [16_777_231, 17_077_237].freeze
EPOCH_IDENTITY = [16_777_231, 17_445_748].freeze
FIXTURE_IDENTITY = [16_777_231, 17_382_060].freeze
FIXTURE_BYTES = 53_072
FIXTURE_SHA256 =
  "177a18c20bc42486c77b52af4c472be222dec1baabf8973ece7b2d44ea92756e"
FIXTURE_UUID = "2ebb880ad28b32ff9b7eeb868af5d9b6"
FIXTURE_WORKSPACE_IDENTITY = [16_777_231, 17_447_047].freeze
RUBY_IDENTITY = [16_777_231, 1_152_921_500_312_572_705].freeze
RUBY_BYTES = 135_200
RUBY_SHA256 =
  "9d6ff3e289c7d908e3c785e0bedd6692d1d6a3377965c88c04d847104b7c892c"
RUBY_UUID = "eb2540b7e13236beb719619d0fbf7203"

GUARDIAN_PID = 21_601
GUARDIAN_UNIQUEID = 8_930_176
GUARDIAN_IDVERSION = 17_456_018
GUARDIAN_PARENT_PID = 21_600
GUARDIAN_PARENT_UNIQUEID = 8_930_175
GUARDIAN_PARENT_IDVERSION = 17_456_015
FIXTURE_PID = 21_660
FIXTURE_UNIQUEID = 8_930_235
FIXTURE_IDVERSION = 17_456_153
FIXTURE_PARENT_UNIQUEID = 8_930_233
FIXTURE_PARENT_IDVERSION = 17_456_148

JOURNAL_LEAVES = %w[
  00-start.json
  01-prestate.json
  02-guardian-kill-commitment.json
  03-guardian-kill-result.json
  04-guardian-conservation.json
  05-fixture-prestate.json
  06-fixture-kill-commitment.json
  07-fixture-kill-result.json
  08-fixture-conservation.json
  09-disposal-terminal.json
].freeze
JOURNAL_FILE_CAP = 16_384
FAIL_STOP_CAP = 1_024
TERMINAL_CAP = 16_384
PID_CAPACITY = 131_072
JOINED_LIFETIME_CAP = 4_096
JOIN_ATTEMPTS = 4
JOIN_RETRY_SECONDS = 0.001
CONSERVATION_RETRY_SECONDS = 0.01
CERTIFICATE_MAX_AGE_NS = 50_000_000
REGION_ITERATION_CAP = 256
STATFS_SIZE = 2_168
MNT_LOCAL = 0x00001000

FULL_BSD_SIZE = 136
SHORT_BSD_SIZE = 64
UNIQUE_INFO_SIZE = 56
REGION_SIZE = 1_272
VNODE_PATHS_SIZE = 2_352
PATH_SIZE = 4_096
PROC_ALL_PIDS = 1
PROC_PGRP_ONLY = 2
PROC_PIDTBSDINFO = 3
PROC_PIDT_SHORTBSDINFO = 13
PROC_PIDUNIQIDENTIFIERINFO = 17
PROC_PIDREGIONPATHINFO = 8
PROC_PIDVNODEPATHINFO = 9
VM_PROT_EXECUTE = 4
ERRNO_EPERM = 1
ERRNO_ENOENT = 2
ERRNO_ESRCH = 3
ERRNO_EEXIST = 17
SIGKILL_NUMBER = 9
AT_FDCWD = -2
O_RDONLY = 0
O_RDWR = 2
O_CREAT = 0x00000200
O_EXCL = 0x00000800
O_CLOEXEC = 0x01000000
O_DIRECTORY = 0x00100000
O_NOFOLLOW_ANY = 0x20000000
F_FULLFSYNC = 51
DIRECTORY_OPEN_FLAGS = O_RDONLY | O_CLOEXEC | O_DIRECTORY | O_NOFOLLOW_ANY
REGULAR_READ_FLAGS = O_RDONLY | O_CLOEXEC | O_NOFOLLOW_ANY
JOURNAL_CREATE_FLAGS =
  O_RDWR | O_CREAT | O_EXCL | O_CLOEXEC | O_NOFOLLOW_ANY

EXPECTED_SYSCTLS = {
  "kern.osproductversion" => "26.5.2",
  "kern.osversion" => "25F84",
  "kern.osrelease" => "25.5.0",
  "kern.version" =>
    "Darwin Kernel Version 25.5.0: Tue Jun  9 22:28:34 PDT 2026; " \
      "root:xnu-12377.121.10~1/RELEASE_ARM64_T6050",
  "hw.machine" => "arm64",
}.freeze
XNU_ABI_SOURCE =
  "apple-oss-distributions/xnu@xnu-12377.1.9/bsd/sys/proc_info_private.h"

unless ARGV.empty? && ENV.to_h == BOOTSTRAP_ENV
  STDERR.write("{\"status\":\"failed\",\"error\":\"unexpected-bootstrap\"}\n")
  exit 70
end

require "digest"
require "fiddle/import"
require "json"

INTERRUPT_SIGNALS = %w[HUP INT QUIT TERM].freeze
$r19_interrupted = nil
INTERRUPT_SIGNALS.each do |signal|
  Signal.trap(signal) { $r19_interrupted ||= signal }
end

module DarwinR19Disposal
  extend Fiddle::Importer
  dlload Fiddle.dlopen(nil)
  extern "int proc_listpids(unsigned int, unsigned int, void*, int)"
  extern "int proc_pidinfo(int, int, unsigned long long, void*, int)"
  extern "int proc_pidpath(int, void*, unsigned int)"
  extern "int getsid(int)"
  extern "int getpgid(int)"
  extern "int kill(int, int)"
  extern "int openat(int, const char*, int, unsigned int)"
  extern "int mkdirat(int, const char*, unsigned int)"
  extern "int fcntl(int, int)"
  extern "int sysctlbyname(const char*, void*, void*, void*, unsigned long)"
  extern "int fstatfs(int, void*)"
end

class DisposalFailure < StandardError; end

def fail_disposal(message)
  raise DisposalFailure, message
end

def monotonic_ns
  Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond)
end

def canonical_value(value)
  case value
  when Hash
    value.keys.sort.each_with_object({}) do |key, result|
      fail_disposal("canonical-non-string-key") unless key.is_a?(String)
      result[key] = canonical_value(value.fetch(key))
    end
  when Array
    value.map { |entry| canonical_value(entry) }
  when String, Integer, TrueClass, FalseClass, NilClass
    value
  else
    fail_disposal("canonical-value-#{value.class}")
  end
end

def canonical_json(value)
  JSON.generate(canonical_value(value))
end

def error_receipt(error)
  bytes = "#{error.class}:#{error.message}".b
  {
    "bytes" => bytes.bytesize,
    "prefix_hex" => bytes.byteslice(0, 128).unpack1("H*"),
    "sha256" => Digest::SHA256.hexdigest(bytes),
  }
end

def stat_receipt(stat)
  {
    "device" => stat.dev,
    "inode" => stat.ino,
    "uid" => stat.uid,
    "gid" => stat.gid,
    "mode" => format("%04o", stat.mode & 0o7777),
    "nlink" => stat.nlink,
    "size" => stat.size,
  }
end

def u32(bytes, offset)
  bytes.byteslice(offset, 4).unpack1("L<")
end

def u64(bytes, offset)
  bytes.byteslice(offset, 8).unpack1("Q<")
end

def checked_sysctl_string(name)
  buffer = "\0" * 4_096
  size = [buffer.bytesize].pack("J")
  Fiddle.last_error = 0
  result = DarwinR19Disposal.sysctlbyname(name, buffer, size, nil, 0)
  error = Fiddle.last_error
  fail_disposal("sysctl-#{name}-#{error}") unless result == 0
  length = size.unpack1("J")
  fail_disposal("sysctl-frame-#{name}") unless
    length.between?(1, buffer.bytesize)
  value = buffer.byteslice(0, length)
  value = value.byteslice(0, value.bytesize - 1) if value.end_with?("\0")
  value.force_encoding(Encoding::UTF_8)
  fail_disposal("sysctl-encoding-#{name}") unless value.valid_encoding?
  value
end

def openat_io(directory_fd, leaf, flags, mode = 0)
  Fiddle.last_error = 0
  descriptor = DarwinR19Disposal.openat(directory_fd, leaf, flags, mode)
  error = Fiddle.last_error
  return [nil, error] if descriptor < 0
  fail_disposal("reserved-descriptor-#{leaf}-#{descriptor}") if descriptor < 3
  io = IO.new(descriptor)
  io.close_on_exec = true
  fail_disposal("descriptor-not-cloexec-#{leaf}") unless io.close_on_exec?
  [io, nil]
end

def open_held(path, directory: false)
  flags = directory ? DIRECTORY_OPEN_FLAGS : REGULAR_READ_FLAGS
  io, error = openat_io(AT_FDCWD, path, flags)
  fail_disposal("open-held-#{path}-#{error}") unless io
  io
end

def rejoin(path, io, directory: false)
  named = File.lstat(path)
  held = io.stat
  expected = directory ? named.directory? && held.directory? :
    named.file? && held.file?
  fail_disposal("named-held-type-#{path}") unless expected
  fail_disposal("named-held-rebound-#{path}") unless
    [named.dev, named.ino] == [held.dev, held.ino]
  held
end

def held_sha256(io)
  digest = Digest::SHA256.new
  io.seek(0)
  while (chunk = io.read(65_536))
    digest.update(chunk)
  end
  io.seek(0)
  digest.hexdigest
end

def full_sync(io, coordinate)
  io.fsync
  Fiddle.last_error = 0
  result = DarwinR19Disposal.fcntl(io.fileno, F_FULLFSYNC)
  error = Fiddle.last_error
  fail_disposal("fullfsync-#{coordinate}-#{error}") unless result == 0
  true
end

def require_local_apfs(io, coordinate)
  bytes = "\0" * STATFS_SIZE
  Fiddle.last_error = 0
  result = DarwinR19Disposal.fstatfs(io.fileno, bytes)
  error = Fiddle.last_error
  fail_disposal("fstatfs-#{coordinate}-#{error}") unless result == 0
  flags = u32(bytes, 64)
  filesystem = bytes.byteslice(72, 16).split("\0", 2).first
  fail_disposal("filesystem-#{coordinate}") unless
    filesystem == "apfs" && flags & MNT_LOCAL != 0
  {"filesystem" => filesystem, "local" => true, "flags" => flags}
end

def write_all(io, bytes)
  offset = 0
  while offset < bytes.bytesize
    written = io.syswrite(bytes.byteslice(offset, bytes.bytesize - offset))
    fail_disposal("short-write") unless written.positive?
    offset += written
  end
  offset
end

def read_exact(io, size)
  io.seek(0)
  bytes = "".b
  while bytes.bytesize < size
    chunk = io.read(size - bytes.bytesize)
    fail_disposal("short-read") if chunk.nil? || chunk.empty?
    bytes << chunk
  end
  fail_disposal("read-not-eof") unless io.read(1).nil?
  io.seek(0)
  bytes
end

class DisposalJournal
  attr_reader :root_io, :last_leaf, :last_frame_sha256

  def poisoned?
    @poisoned
  end

  def self.create
    parent = open_held(PRIVATE_TMP, directory: true)
    parent_stat = rejoin(PRIVATE_TMP, parent, directory: true)
    fail_disposal("private-tmp-preimage") unless
      [parent_stat.dev, parent_stat.ino] == PRIVATE_TMP_IDENTITY &&
        [parent_stat.uid, parent_stat.gid, parent_stat.mode & 0o7777] ==
          [0, 0, 0o1777]
    filesystem = require_local_apfs(parent, "private-tmp")
    begin
      File.lstat(DISPOSAL_ROOT)
      fail_disposal("disposal-root-preexists")
    rescue Errno::ENOENT
      nil
    end
    Fiddle.last_error = 0
    created = DarwinR19Disposal.mkdirat(parent.fileno, DISPOSAL_LEAF, 0o700)
    error = Fiddle.last_error
    fail_disposal("disposal-mkdirat-#{error}") unless created == 0
    root, open_error = openat_io(
      parent.fileno, DISPOSAL_LEAF, DIRECTORY_OPEN_FLAGS
    )
    fail_disposal("disposal-open-#{open_error}") unless root
    root_stat = rejoin(DISPOSAL_ROOT, root, directory: true)
    fail_disposal("disposal-root-metadata") unless
      [root_stat.dev, root_stat.uid, root_stat.gid,
       root_stat.mode & 0o7777, root_stat.nlink] ==
        [parent_stat.dev, EXPECTED_UID, parent_stat.gid, 0o700, 2]
    fail_disposal("disposal-root-not-empty") unless
      Dir.children(DISPOSAL_ROOT).empty?
    full_sync(root, "disposal-root")
    full_sync(parent, "private-tmp")
    new(parent, root, filesystem)
  rescue StandardError
    begin
      root.close if defined?(root) && root && !root.closed?
      parent.close if defined?(parent) && parent && !parent.closed?
    rescue StandardError
      nil
    end
    raise
  end

  def initialize(parent_io, root_io, filesystem)
    @parent_io = parent_io
    @root_io = root_io
    @last_leaf = nil
    @last_frame_sha256 = nil
    @last_index = -1
    @poisoned = false
    @successful_leaves = []
    @filesystem = filesystem
  end

  def publish(leaf, payload)
    fail_disposal("journal-poisoned") if @poisoned
    @poisoned = true
    index = JOURNAL_LEAVES.index(leaf)
    fail_disposal("journal-leaf-#{leaf}") unless index
    fail_disposal("journal-order-#{leaf}") unless index > @last_index
    fail_disposal("journal-inventory-before-#{leaf}") unless
      Dir.children(DISPOSAL_ROOT).sort == @successful_leaves.sort
    base = payload.merge(
      "journal_leaf" => leaf,
      "previous_leaf" => @last_leaf,
      "previous_frame_sha256" => @last_frame_sha256,
      "journal_filesystem" => @filesystem
    )
    digest_free = canonical_json(base)
    record = base.merge(
      "record_sha256" => Digest::SHA256.hexdigest(digest_free)
    )
    bytes = canonical_json(record) + "\n"
    fail_disposal("journal-cap-#{leaf}") if bytes.bytesize > JOURNAL_FILE_CAP
    rejoin(DISPOSAL_ROOT, @root_io, directory: true)
    io, error = openat_io(
      @root_io.fileno, leaf, JOURNAL_CREATE_FLAGS, 0o400
    )
    fail_disposal("journal-open-#{leaf}-#{error}") unless io
    begin
      initial = io.stat
      fail_disposal("journal-initial-#{leaf}") unless
        initial.file? && initial.size == 0 && initial.nlink == 1 &&
          [initial.uid, initial.gid, initial.mode & 0o7777] ==
            [EXPECTED_UID, @root_io.stat.gid, 0o400]
      write_all(io, bytes)
      full_sync(io, leaf)
      held = io.stat
      named = File.lstat("#{DISPOSAL_ROOT}/#{leaf}")
      fail_disposal("journal-rebound-#{leaf}") unless
        named.file? && [named.dev, named.ino] == [held.dev, held.ino] &&
          [initial.dev, initial.ino] == [held.dev, held.ino]
      fail_disposal("journal-metadata-#{leaf}") unless
        held.nlink == 1 && held.size == bytes.bytesize &&
          [held.uid, held.gid, held.mode & 0o7777] ==
            [EXPECTED_UID, @root_io.stat.gid, 0o400]
      fail_disposal("journal-readback-#{leaf}") unless
        read_exact(io, bytes.bytesize) == bytes
      full_sync(@root_io, "journal-parent-#{leaf}")
      rejoin(DISPOSAL_ROOT, @root_io, directory: true)
      expected_inventory = (@successful_leaves + [leaf]).sort
      fail_disposal("journal-inventory-after-#{leaf}") unless
        Dir.children(DISPOSAL_ROOT).sort == expected_inventory
      @last_leaf = leaf
      @last_frame_sha256 = Digest::SHA256.hexdigest(bytes)
      @last_index = index
      @successful_leaves << leaf
      io.close unless io.closed?
      @poisoned = false
      bytes
    ensure
      begin
        io.close unless io.closed?
      rescue StandardError
        @poisoned = true
        raise
      end
    end
  end
end

def raw_pidinfo(pid, flavor, size)
  buffer = "\0" * size
  Fiddle.last_error = 0
  returned = DarwinR19Disposal.proc_pidinfo(
    pid, flavor, 0, buffer, buffer.bytesize
  )
  error = Fiddle.last_error
  [returned, error, buffer]
end

def parse_unique_info(buffer)
  fail_disposal("flavor17-frame") unless buffer.bytesize == UNIQUE_INFO_SIZE
  record = {
    "uuid_hex" => buffer.byteslice(0, 16).unpack1("H*"),
    "uniqueid" => buffer.byteslice(16, 8).unpack1("Q<"),
    "puniqueid" => buffer.byteslice(24, 8).unpack1("Q<"),
    "idversion" => buffer.byteslice(32, 4).unpack1("l<"),
    "orig_ppidversion" => buffer.byteslice(36, 4).unpack1("l<"),
    "reserve2" => buffer.byteslice(40, 8).unpack1("Q<"),
    "reserve3" => buffer.byteslice(48, 8).unpack1("Q<"),
  }
  fail_disposal("flavor17-zero-lifetime") if record["uniqueid"] == 0
  fail_disposal("flavor17-reserved") unless
    record["reserve2"] == 0 && record["reserve3"] == 0
  record
end

def parse_short_bsd(buffer)
  fail_disposal("shortbsd-frame") unless buffer.bytesize == SHORT_BSD_SIZE
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
  fail_disposal("shortbsd-reserved") unless record["rfu"] == 0
  record
end

def read_unique(pid)
  returned, error, buffer = raw_pidinfo(
    pid, PROC_PIDUNIQIDENTIFIERINFO, UNIQUE_INFO_SIZE
  )
  return ["joined", parse_unique_info(buffer)] if returned == UNIQUE_INFO_SIZE
  fail_disposal("flavor17-partial-#{pid}-#{returned}") if returned.positive?
  return ["gone", nil] if returned == 0 && error == ERRNO_ESRCH
  fail_disposal("flavor17-#{pid}-#{returned}-#{error}")
end

def read_short(pid)
  returned, error, buffer = raw_pidinfo(
    pid, PROC_PIDT_SHORTBSDINFO, SHORT_BSD_SIZE
  )
  if returned == SHORT_BSD_SIZE
    record = parse_short_bsd(buffer)
    fail_disposal("shortbsd-pid-#{pid}") unless record["pid"] == pid
    return ["joined", record]
  end
  fail_disposal("shortbsd-partial-#{pid}-#{returned}") if returned.positive?
  return ["gone", nil] if returned == 0 && error == ERRNO_ESRCH
  fail_disposal("shortbsd-#{pid}-#{returned}-#{error}")
end

def read_domain(name, pid)
  Fiddle.last_error = 0
  value = name == "getsid" ?
    DarwinR19Disposal.getsid(pid) : DarwinR19Disposal.getpgid(pid)
  error = Fiddle.last_error
  return ["joined", value] if value >= 0
  return ["gone", nil] if error == ERRNO_ESRCH
  fail_disposal("#{name}-#{pid}-#{value}-#{error}")
end

def same_unique?(left, right)
  %w[
    uuid_hex uniqueid puniqueid idversion orig_ppidversion reserve2 reserve3
  ].all? { |field| left[field] == right[field] }
end

def same_join?(left, right)
  same_unique?(left.fetch("unique"), right.fetch("unique")) &&
    left.fetch("short") == right.fetch("short") &&
    left["sid"] == right["sid"] && left["pgid"] == right["pgid"]
end

def join_process(pid)
  observed = []
  JOIN_ATTEMPTS.times do |attempt|
    u0_kind, u0 = read_unique(pid)
    return {"kind" => "gone", "pid" => pid, "attempts" => attempt + 1} if
      u0_kind == "gone" && observed.empty?
    return {"kind" => "gone", "pid" => pid, "attempts" => attempt + 1,
            "tombstone_epochs" => observed.uniq} if u0_kind == "gone"
    observed << [u0["uniqueid"], u0["idversion"]]
    s0_kind, s0 = read_short(pid)
    sid0_kind, sid0 = read_domain("getsid", pid)
    pgid0_kind, pgid0 = read_domain("getpgid", pid)
    sid1_kind, sid1 = read_domain("getsid", pid)
    pgid1_kind, pgid1 = read_domain("getpgid", pid)
    s1_kind, s1 = read_short(pid)
    u1_kind, u1 = read_unique(pid)
    kinds = [s0_kind, sid0_kind, pgid0_kind, sid1_kind, pgid1_kind,
             s1_kind, u1_kind]
    return {"kind" => "gone", "pid" => pid, "attempts" => attempt + 1,
            "tombstone_epochs" => observed.uniq} if kinds.include?("gone")
    observed << [u1["uniqueid"], u1["idversion"]]
    stable = same_unique?(u0, u1) && s0 == s1 && sid0 == sid1 &&
      pgid0 == pgid1 && s0["pgid"] == pgid0 && s1["pgid"] == pgid1
    return {
      "kind" => "joined", "pid" => pid, "attempts" => attempt + 1,
      "unique" => u1, "short" => s1, "sid" => sid1, "pgid" => pgid1,
    } if stable
    sleep(JOIN_RETRY_SECONDS) if attempt + 1 < JOIN_ATTEMPTS
  end
  {
    "kind" => "unknown", "pid" => pid, "attempts" => JOIN_ATTEMPTS,
    "observed_epochs" => observed.uniq,
  }
end

def require_joined(pid, coordinate)
  joined = join_process(pid)
  fail_disposal("#{coordinate}-#{joined.fetch("kind")}") unless
    joined["kind"] == "joined"
  joined
end

def process_path(pid)
  bytes = "\0" * PATH_SIZE
  Fiddle.last_error = 0
  returned = DarwinR19Disposal.proc_pidpath(pid, bytes, bytes.bytesize)
  error = Fiddle.last_error
  return :gone if returned <= 0 && error == ERRNO_ESRCH
  fail_disposal("pidpath-#{pid}-#{returned}-#{error}") if returned <= 0
  fail_disposal("pidpath-frame-#{pid}") unless returned < bytes.bytesize
  path = bytes.byteslice(0, returned).split("\0", 2).first
  path.force_encoding(Encoding::UTF_8)
  fail_disposal("pidpath-encoding-#{pid}") unless path.valid_encoding?
  path
end

def mapped_executable_identity(pid, expected_path)
  address = 0
  REGION_ITERATION_CAP.times do
    bytes = "\0" * REGION_SIZE
    Fiddle.last_error = 0
    returned = DarwinR19Disposal.proc_pidinfo(
      pid, PROC_PIDREGIONPATHINFO, address, bytes, bytes.bytesize
    )
    error = Fiddle.last_error
    return :gone if returned <= 0 && error == ERRNO_ESRCH
    return false if returned == 0 && error == 0
    fail_disposal("region-#{pid}-#{returned}-#{error}") unless
      returned == REGION_SIZE
    protection = u32(bytes, 0)
    file_offset = u64(bytes, 16)
    region_address = u64(bytes, 80)
    region_size = u64(bytes, 88)
    device = u32(bytes, 96)
    inode = u64(bytes, 104)
    fail_disposal("region-order-#{pid}") if
      region_address < address || region_size == 0
    following = region_address + region_size
    fail_disposal("region-overflow-#{pid}") if
      following > 0xffff_ffff_ffff_ffff
    if protection & VM_PROT_EXECUTE != 0 && file_offset == 0
      path = bytes.byteslice(248, 1_024).split("\0", 2).first
      return [device, inode] if path == expected_path
    end
    address = following
  end
  fail_disposal("region-capacity-#{pid}")
end

def process_cwd(pid)
  bytes = "\0" * VNODE_PATHS_SIZE
  Fiddle.last_error = 0
  returned = DarwinR19Disposal.proc_pidinfo(
    pid, PROC_PIDVNODEPATHINFO, 0, bytes, bytes.bytesize
  )
  error = Fiddle.last_error
  return :gone if returned <= 0 && error == ERRNO_ESRCH
  fail_disposal("cwd-#{pid}-#{returned}-#{error}") unless
    returned == VNODE_PATHS_SIZE
  path = bytes.byteslice(152, 1_024).split("\0", 2).first
  path.force_encoding(Encoding::UTF_8)
  fail_disposal("cwd-frame-#{pid}") unless
    path.valid_encoding? && path.start_with?("/")
  {
    "path" => path,
    "device" => u32(bytes, 0),
    "inode" => u64(bytes, 8),
  }
end

def listed_pids(list_type, type_info, allow_empty: false)
  bytes = "\0" * (PID_CAPACITY * 4)
  Fiddle.last_error = 0
  returned = DarwinR19Disposal.proc_listpids(
    list_type, type_info, bytes, bytes.bytesize
  )
  error = Fiddle.last_error
  return [] if allow_empty && returned == 0 && error == 0
  fail_disposal("pid-list-#{list_type}-#{type_info}-#{returned}-#{error}") unless
    returned > 0 && returned < bytes.bytesize && returned % 4 == 0
  pids = bytes.byteslice(0, returned).unpack("L<*").reject(&:zero?)
  fail_disposal("pid-list-duplicate") unless pids.uniq.length == pids.length
  pids.sort
end

def join_receipt(joined)
  {
    "pid" => joined.fetch("pid"),
    "uniqueid" => joined.dig("unique", "uniqueid"),
    "idversion" => joined.dig("unique", "idversion"),
    "puniqueid" => joined.dig("unique", "puniqueid"),
    "orig_ppidversion" => joined.dig("unique", "orig_ppidversion"),
    "uuid_hex" => joined.dig("unique", "uuid_hex"),
    "ppid" => joined.dig("short", "ppid"),
    "pgid" => joined.fetch("pgid"),
    "sid" => joined.fetch("sid"),
    "status" => joined.dig("short", "status"),
    "flags" => joined.dig("short", "flags"),
    "comm_hex" => joined.dig("short", "comm_hex"),
    "credentials" => %w[uid gid ruid rgid svuid svgid].map do |field|
      joined.dig("short", field)
    end,
  }
end

def expected_credentials?(joined)
  join_receipt(joined).fetch("credentials") ==
    [EXPECTED_UID, EXPECTED_GID, EXPECTED_UID, EXPECTED_GID,
     EXPECTED_UID, EXPECTED_GID]
end

def group_snapshot(group, self_pid)
  fail_disposal("group-domain-#{group}") unless group > 1
  pids = listed_pids(PROC_PGRP_ONLY, group, allow_empty: true)
  pids = pids.reject { |pid| pid == self_pid }
  fail_disposal("group-cap-#{group}") if pids.length > JOINED_LIFETIME_CAP
  pids.map do |pid|
    joined = join_process(pid)
    next if joined["kind"] == "gone"
    fail_disposal("group-unknown-#{group}-#{pid}") unless
      joined["kind"] == "joined"
    fail_disposal("group-rebound-#{group}-#{pid}") unless
      joined["pgid"] == group && joined.dig("short", "pgid") == group
    join_receipt(joined)
  end.compact.sort_by { |row| row.fetch("pid") }
end

def session_snapshot(session, self_pid)
  fail_disposal("session-domain-#{session}") unless session > 1
  matched = []
  listed_pids(PROC_ALL_PIDS, 0).reject { |pid| pid == self_pid }.each do |pid|
    sid0_kind, sid0 = read_domain("getsid", pid)
    next if sid0_kind == "gone" || sid0 != session
    joined = join_process(pid)
    next if joined["kind"] == "gone"
    fail_disposal("session-unknown-#{session}-#{pid}") unless
      joined["kind"] == "joined"
    sid1_kind, sid1 = read_domain("getsid", pid)
    next if sid1_kind == "gone"
    fail_disposal("session-race-#{session}-#{pid}") unless
      sid0 == sid1 && joined["sid"] == session
    matched << join_receipt(joined)
    fail_disposal("session-cap-#{session}") if
      matched.length > JOINED_LIFETIME_CAP
  end
  matched.sort_by { |row| row.fetch("pid") }
end

def exact_target_fields?(joined, role)
  unique = joined.fetch("unique")
  short = joined.fetch("short")
  return false unless expected_credentials?(joined)
  if role == "guardian"
    unique["uniqueid"] == GUARDIAN_UNIQUEID &&
      unique["idversion"] == GUARDIAN_IDVERSION &&
      unique["puniqueid"] == GUARDIAN_PARENT_UNIQUEID &&
      unique["orig_ppidversion"] == GUARDIAN_PARENT_IDVERSION &&
      unique["uuid_hex"] == RUBY_UUID &&
      short["pid"] == GUARDIAN_PID &&
      short["ppid"] == GUARDIAN_PARENT_PID &&
      short["status"] == 2 &&
      joined["sid"] == GUARDIAN_PID && joined["pgid"] == GUARDIAN_PID
  else
    unique["uniqueid"] == FIXTURE_UNIQUEID &&
      unique["idversion"] == FIXTURE_IDVERSION &&
      unique["puniqueid"] == FIXTURE_PARENT_UNIQUEID &&
      unique["orig_ppidversion"] == FIXTURE_PARENT_IDVERSION &&
      unique["uuid_hex"] == FIXTURE_UUID &&
      short["pid"] == FIXTURE_PID && short["ppid"] == 1 &&
      short["status"] == 4 && joined["sid"] == FIXTURE_PID &&
      joined["pgid"] == FIXTURE_PID
  end
end

def one_target_snapshot(role, image_io, cwd_io, self_pid)
  pid = role == "guardian" ? GUARDIAN_PID : FIXTURE_PID
  expected_uniqueid = role == "guardian" ?
    GUARDIAN_UNIQUEID : FIXTURE_UNIQUEID
  expected_idversion = role == "guardian" ?
    GUARDIAN_IDVERSION : FIXTURE_IDVERSION
  path = role == "guardian" ? RUBY_IMAGE : FIXTURE
  cwd_path = role == "guardian" ? CONTROL_CWD : FIXTURE_WORKSPACE
  expected_image = role == "guardian" ? RUBY_IDENTITY : FIXTURE_IDENTITY
  expected_cwd = role == "guardian" ?
    CONTROL_CWD_IDENTITY : FIXTURE_WORKSPACE_IDENTITY
  first = join_process(pid)
  return {"kind" => "absent", "role" => role} if first["kind"] == "gone"
  fail_disposal("#{role}-join-unknown") unless first["kind"] == "joined"
  if first.dig("unique", "uniqueid") != expected_uniqueid ||
     first.dig("unique", "idversion") != expected_idversion
    return {
      "kind" => "rebound", "role" => role,
      "observed" => join_receipt(first),
    }
  end
  fail_disposal("#{role}-identity") unless exact_target_fields?(first, role)
  observed_path = process_path(pid)
  fail_disposal("#{role}-path-gone") if observed_path == :gone
  fail_disposal("#{role}-path") unless observed_path == path
  mapped = mapped_executable_identity(pid, path)
  fail_disposal("#{role}-mapped-gone") if mapped == :gone
  fail_disposal("#{role}-mapped") unless mapped == expected_image
  held_image = rejoin(path, image_io)
  fail_disposal("#{role}-mapped-held") unless
    mapped == [held_image.dev, held_image.ino]
  cwd = process_cwd(pid)
  fail_disposal("#{role}-cwd-gone") if cwd == :gone
  fail_disposal("#{role}-cwd") unless
    cwd["path"] == cwd_path && [cwd["device"], cwd["inode"]] == expected_cwd
  held_cwd = rejoin(cwd_path, cwd_io, directory: true)
  fail_disposal("#{role}-cwd-held") unless
    [held_cwd.dev, held_cwd.ino] == expected_cwd
  group = group_snapshot(pid, self_pid)
  session = session_snapshot(pid, self_pid)
  second = join_process(pid)
  fail_disposal("#{role}-post-image-gone") if second["kind"] == "gone"
  fail_disposal("#{role}-post-image-unknown") unless
    second["kind"] == "joined"
  fail_disposal("#{role}-observation-race") unless same_join?(first, second)
  receipt = join_receipt(second)
  fail_disposal("#{role}-group-singleton") unless group == [receipt]
  fail_disposal("#{role}-session-singleton") unless session == [receipt]
  {
    "kind" => "present",
    "role" => role,
    "process" => receipt,
    "path" => observed_path,
    "mapped_image" => {"device" => mapped[0], "inode" => mapped[1]},
    "cwd" => cwd,
    "group_members" => group,
    "session_members" => session,
    "invocation_framing_basis" => role == "guardian" ?
      "exact_consumed_generation_plus_recorded_frozen_transport" :
      "exact_consumed_generation_plus_held_fixture_admission",
  }
end

def double_target_snapshot(role, image_io, cwd_io, self_pid)
  first = one_target_snapshot(role, image_io, cwd_io, self_pid)
  second = one_target_snapshot(role, image_io, cwd_io, self_pid)
  fail_disposal("#{role}-double-snapshot-race") unless first == second
  first
end

def signal_zero(group, accounting)
  fail_disposal("signal-zero-target-#{group}") unless
    [GUARDIAN_PID, FIXTURE_PID].include?(group)
  fail_disposal("signal-zero-accounting") unless
    accounting.is_a?(Hash) &&
      accounting["entered_call_count"].is_a?(Integer) &&
      accounting["entered_call_count"] >= 0
  Fiddle.last_error = 0
  accounting["entered_call_count"] += 1
  result = DarwinR19Disposal.kill(-group, 0)
  error = Fiddle.last_error
  {
    "entered" => true,
    "return" => result,
    "errno" => result == -1 ? error : 0,
    "esrch" => result == -1 && error == ERRNO_ESRCH,
  }
end

def absence_round(pid, uniqueid, group, session, self_pid, accounting)
  kind, unique = read_unique(pid)
  fail_disposal("absence-generation-live-#{pid}") unless kind == "gone"
  groups = group_snapshot(group, self_pid)
  sessions = session_snapshot(session, self_pid)
  fail_disposal("absence-group-live-#{group}") unless groups.empty?
  fail_disposal("absence-session-live-#{session}") unless sessions.empty?
  probe = signal_zero(group, accounting)
  fail_disposal("absence-signal-zero-#{group}") unless probe["esrch"]
  {
    "pid" => pid,
    "uniqueid" => uniqueid,
    "generation" => "ESRCH",
    "group_projection" => groups,
    "session_projection" => sessions,
    "signal_zero" => probe,
  }
end

def preexisting_absence_proof(pid, uniqueid, group, session, self_pid)
  accounting = {"entered_call_count" => 0}
  rounds = 2.times.map do
    absence_round(
      pid, uniqueid, group, session, self_pid, accounting
    )
  end
  {
    "kind" => "external_conservation",
    "preexisting_absence" => true,
    "rounds" => rounds,
    "signal_zero_entered_count" => accounting.fetch("entered_call_count"),
  }
end

def post_kill_conservation(pid, uniqueid, group, session, self_pid)
  rounds = []
  accounting = {"entered_call_count" => 0}
  fault_count = 0
  until rounds.length == 2
    begin
      kind, = read_unique(pid)
      unless kind == "gone"
        rounds.clear
        sleep(CONSERVATION_RETRY_SECONDS)
        next
      end
      groups = group_snapshot(group, self_pid)
      sessions = session_snapshot(session, self_pid)
      unless groups.empty? && sessions.empty?
        rounds.clear
        sleep(CONSERVATION_RETRY_SECONDS)
        next
      end
      probe = signal_zero(group, accounting)
      unless probe["esrch"]
        rounds.clear
        sleep(CONSERVATION_RETRY_SECONDS)
        next
      end
      rounds << {
        "pid" => pid,
        "uniqueid" => uniqueid,
        "generation" => "ESRCH",
        "group_projection" => groups,
        "session_projection" => sessions,
        "signal_zero" => probe,
      }
    rescue StandardError
      fault_count += 1
      rounds.clear
      sleep(CONSERVATION_RETRY_SECONDS)
    end
  end
  {
    "kind" => "external_conservation",
    "preexisting_absence" => false,
    "rounds" => rounds,
    "signal_zero_entered_count" => accounting.fetch("entered_call_count"),
    "transient_fault_count" => fault_count,
  }
end

def pid1_abi_probe
  returned, error, = raw_pidinfo(1, PROC_PIDTBSDINFO, FULL_BSD_SIZE)
  fail_disposal("pid1-fullbsd-control") unless
    returned == 0 && error == ERRNO_EPERM
  joined = require_joined(1, "pid1")
  {
    "full_bsd_returned" => returned,
    "full_bsd_errno" => error,
    "short_unique_join" => join_receipt(joined),
  }
end

def validate_terminal_record(bytes)
  fail_disposal("guardian-terminal-frame") unless
    bytes.end_with?("\n") && bytes.count("\n") == 1
  body = bytes.byteslice(0, bytes.bytesize - 1)
  parsed = JSON.parse(body)
  fail_disposal("guardian-terminal-canonical") unless
    canonical_json(parsed) == body
  fail_disposal("guardian-terminal-schema") unless
    parsed["schema"] == "prime-driver-v2-r19-guardian/v1" &&
      %w[
        R19_GUARDIAN_NATURAL_EXIT R19_GUARDIAN_CONTAINED_ABNORMAL
      ].include?(parsed["status"])
  fail_disposal("guardian-terminal-authority") unless
    parsed["authority_vector"] == "00000000" &&
      parsed["gate_e_outcome"] == "ABSTAIN" &&
      parsed["gate_e_clearance"] == 0 &&
      parsed["process_containment_complete"] == true
  digest = parsed["payload_sha256"]
  fail_disposal("guardian-terminal-digest-shape") unless
    digest.is_a?(String) && /\A[0-9a-f]{64}\z/.match?(digest)
  digest_free = parsed.reject { |key, _| key == "payload_sha256" }
  fail_disposal("guardian-terminal-digest") unless
    Digest::SHA256.hexdigest(canonical_json(digest_free)) == digest
  {
    "status" => parsed.fetch("status"),
    "bytes" => bytes.bytesize,
    "sha256" => Digest::SHA256.hexdigest(bytes),
    "payload_sha256" => digest,
  }
rescue JSON::ParserError => error
  fail_disposal("guardian-terminal-json-#{error.message}")
end

def terminal_namespace(epoch_io)
  rejoin(EPOCH, epoch_io, directory: true)
  entries = Dir.children(EPOCH)
  terminal_prefixed = entries.select do |leaf|
    leaf.start_with?("r19-guardian-terminal")
  end
  unrecognized = terminal_prefixed.reject do |leaf|
    leaf == GUARDIAN_TERMINAL_LEAF || GUARDIAN_STAGING.match?(leaf)
  end
  fail_disposal("guardian-terminal-unrecognized-prefix") unless
    unrecognized.empty?
  staging = entries.select { |leaf| GUARDIAN_STAGING.match?(leaf) }.sort
  fail_disposal("guardian-terminal-staging-present") unless staging.empty?
  unless entries.include?(GUARDIAN_TERMINAL_LEAF)
    rejoin(EPOCH, epoch_io, directory: true)
    return {"kind" => "absent", "staging" => []}
  end
  io, error = openat_io(
    epoch_io.fileno, GUARDIAN_TERMINAL_LEAF, REGULAR_READ_FLAGS
  )
  fail_disposal("guardian-terminal-open-#{error}") unless io
  begin
    stat = rejoin(GUARDIAN_TERMINAL, io)
    fail_disposal("guardian-terminal-metadata") unless
      stat.dev == epoch_io.stat.dev &&
      [stat.uid, stat.gid, stat.mode & 0o7777, stat.nlink] ==
        [EXPECTED_UID, epoch_io.stat.gid, 0o400, 1] &&
        stat.size.between?(1, TERMINAL_CAP)
    bytes = read_exact(io, stat.size)
    receipt = validate_terminal_record(bytes)
    after = rejoin(GUARDIAN_TERMINAL, io)
    fail_disposal("guardian-terminal-changed") unless
      [after.dev, after.ino, after.size] == [stat.dev, stat.ino, stat.size]
    rejoin(EPOCH, epoch_io, directory: true)
    {"kind" => "present", "record" => receipt, "staging" => []}
  ensure
    io.close unless io.closed?
  end
end

FAIL_STOP_KEYS = %w[
  admittedDeviceID admittedInode containmentState
  containmentStopAttemptSequence containmentStopDeathEventCheckPerformed
  containmentStopDeathEventObserved containmentStopErrno containmentStopReturn
  deadlineExpired deathEventObservedAtContainmentFailure deathWaitReturned
  executionPhase failureCoordinate failureStatus fixedFailStopStatus fixtureMode
  initiatingFailureCoordinate initiatingFailureStatus schema sourceIdentitySHA256
].freeze
SOURCE_IDENTITY_SHA256 =
  "b501ad0d7ab1b6c54cbf30f9a79d75c54fe1d3783c516e10ad73fdd5fb4df397"

def bounded_diagnostic_coordinate?(coordinate)
  coordinate.is_a?(String) && coordinate.bytesize.between?(1, 128) &&
    /\A[a-z0-9_]+\z/.match?(coordinate)
end

def closed_census_coordinate?(coordinate)
  return true if %w[
    session_census_capacity session_census_duplicate_pid
    session_census_duplicate_generation session_census_nonconvergent_query
  ].include?(coordinate)
  families = {
    "session_census_getsid_" => true,
    "session_census_bsdinfo_" => false,
    "session_census_getpgid_" => true,
  }
  families.any? do |prefix, excludes_esrch|
    next false unless coordinate.start_with?(prefix)
    suffix = coordinate.byteslice(prefix.bytesize, coordinate.bytesize)
    next false unless /\A(?:0|[1-9][0-9]*)\z/.match?(suffix)
    value = Integer(suffix, 10)
    value <= 2_147_483_647 && (!excludes_esrch || value != ERRNO_ESRCH)
  rescue ArgumentError
    false
  end
end

def valid_fail_stop_v2?(record, leaf_stat)
  return false unless record.is_a?(Hash) &&
    record.keys.sort == FAIL_STOP_KEYS.sort &&
    record["schema"] == "prime_driver_v2_session_fixture_fail_stop_v2" &&
    record["sourceIdentitySHA256"] == SOURCE_IDENTITY_SHA256 &&
    record["admittedDeviceID"] == leaf_stat.dev &&
    record["admittedInode"] == leaf_stat.ino &&
    record["fixtureMode"] == "orphan_transition" &&
    record["executionPhase"] == "orphan_initial_census" &&
    record["containmentState"] == "armed" &&
    record["containmentStopAttemptSequence"] == 1 &&
    record["failureCoordinate"] == "supervisor_stop" &&
    record["failureStatus"] == 70 && record["fixedFailStopStatus"] == 70 &&
    record["initiatingFailureStatus"] == 70 &&
    bounded_diagnostic_coordinate?(record["failureCoordinate"]) &&
    bounded_diagnostic_coordinate?(record["initiatingFailureCoordinate"]) &&
    closed_census_coordinate?(record["initiatingFailureCoordinate"])
  boolean_fields = %w[
    containmentStopDeathEventCheckPerformed
    containmentStopDeathEventObserved deadlineExpired
    deathEventObservedAtContainmentFailure deathWaitReturned
  ]
  return false unless boolean_fields.all? do |field|
    record[field] == true || record[field] == false
  end
  stop_return = record["containmentStopReturn"]
  stop_errno = record["containmentStopErrno"]
  checked = record["containmentStopDeathEventCheckPerformed"]
  observed = record["containmentStopDeathEventObserved"]
  return false unless [0, -1].include?(stop_return) &&
    stop_errno.is_a?(Integer) && stop_errno.between?(0, 2_147_483_647) &&
    (stop_return == 0) == (stop_errno == 0) &&
    (stop_return == -1) == (stop_errno >= 1) &&
    checked == (stop_return == -1 && stop_errno == ERRNO_ESRCH) &&
    (checked || !observed) &&
    record["deathEventObservedAtContainmentFailure"] == true &&
    record["deathWaitReturned"] == true &&
    (!record["deathWaitReturned"] || !checked || observed) &&
    (!observed || record["deathEventObservedAtContainmentFailure"])
  (stop_return == -1) ==
    !(stop_errno == ERRNO_ESRCH && checked && observed)
end

def observe_fail_stop_after_conservation(journal, workspace_io)
  inventory = Dir.children(DISPOSAL_ROOT)
  fail_disposal("fail-stop-before-guardian-conservation") unless
    inventory.include?("04-guardian-conservation.json")
  fail_disposal("fail-stop-before-fixture-conservation") unless
    inventory.include?("08-fixture-conservation.json") &&
      journal.last_leaf == "08-fixture-conservation.json"
  observed_receipt = nil
  base_path = File.dirname(FIXTURE_WORKSPACE)
  base_io = open_held(base_path, directory: true)
  begin
    base_before = rejoin(base_path, base_io, directory: true)
    workspace_check, workspace_error = openat_io(
      base_io.fileno, "workspace", DIRECTORY_OPEN_FLAGS
    )
    fail_disposal("fail-stop-workspace-open-#{workspace_error}") unless
      workspace_check
    begin
      named_workspace = rejoin(
        FIXTURE_WORKSPACE, workspace_check, directory: true
      )
      held_workspace = rejoin(
        FIXTURE_WORKSPACE, workspace_io, directory: true
      )
      fail_disposal("fail-stop-workspace-rebound") unless
        [named_workspace.dev, named_workspace.ino] ==
          [held_workspace.dev, held_workspace.ino] &&
          [held_workspace.dev, held_workspace.ino] ==
            FIXTURE_WORKSPACE_IDENTITY
    ensure
      workspace_check.close unless workspace_check.closed?
    end
    io, error = openat_io(base_io.fileno, FAIL_STOP_LEAF, REGULAR_READ_FLAGS)
    if io.nil?
      fail_disposal("fail-stop-open-#{error}") unless error == ERRNO_ENOENT
      rejoin(base_path, base_io, directory: true)
      rejoin(FIXTURE_WORKSPACE, workspace_io, directory: true)
      return {
        "classification" => "ABSENT_ABSTAIN",
        "bytes" => 0,
        "sha256" => nil,
      }
    end
    begin
      stat = rejoin(FAIL_STOP, io)
      fail_disposal("fail-stop-owner") unless
        stat.file? && stat.uid == EXPECTED_UID &&
          stat.gid == base_before.gid && stat.nlink == 1
      mode = stat.mode & 0o7777
      if stat.size > FAIL_STOP_CAP
        io.seek(0)
        prefix = io.read(FAIL_STOP_CAP + 1) || "".b
        after = rejoin(FAIL_STOP, io)
        fail_disposal("fail-stop-oversized-changed") unless
          [after.dev, after.ino, after.size, after.mode & 0o7777] ==
            [stat.dev, stat.ino, stat.size, mode]
        rejoin(base_path, base_io, directory: true)
        rejoin(FIXTURE_WORKSPACE, workspace_io, directory: true)
        return {
          "classification" => "INVALID_OR_PARTIAL_RETAINED_ABSTAIN",
          "reason" => "OVERSIZED",
          "held_size" => stat.size,
          "observed_prefix_bytes" => prefix.bytesize,
          "observed_prefix_hex" => prefix.unpack1("H*"),
          "observed_prefix_sha256" => Digest::SHA256.hexdigest(prefix),
          "file" => stat_receipt(after),
        }
      end
      bytes = read_exact(io, stat.size)
      after = rejoin(FAIL_STOP, io)
      fail_disposal("fail-stop-changed") unless
        [after.dev, after.ino, after.size, after.mode & 0o7777] ==
          [stat.dev, stat.ino, stat.size, mode]
      rejoin(base_path, base_io, directory: true)
      rejoin(FIXTURE_WORKSPACE, workspace_io, directory: true)
      observed_receipt = {
        "bytes" => bytes.bytesize,
        "bytes_hex" => bytes.unpack1("H*"),
        "sha256" => Digest::SHA256.hexdigest(bytes),
        "file" => stat_receipt(stat),
      }
      if bytes.empty? && mode == 0o600
        return observed_receipt.merge(
          "classification" => "EMPTY_PREIMAGE_ABSTAIN"
        )
      end
      begin
        fail_disposal("fail-stop-mode") unless
          mode == 0o400 && !bytes.empty?
        parsed = JSON.parse(bytes)
        fail_disposal("fail-stop-canonical") unless
          canonical_json(parsed) == bytes
        fail_disposal("fail-stop-schema") unless
          valid_fail_stop_v2?(parsed, stat)
        observed_receipt.merge(
          "classification" => "VALID_CANONICAL_V2_DIAGNOSTIC_RETAINED"
        )
      rescue StandardError => error
        observed_receipt.merge(
          "classification" => "INVALID_OR_PARTIAL_RETAINED_ABSTAIN",
          "error" => error_receipt(error)
        )
      end
    ensure
      io.close unless io.closed?
    end
  rescue StandardError => error
    (observed_receipt || {}).merge(
      "classification" => "INVALID_OR_REBOUND_RETAINED_ABSTAIN",
      "error" => error_receipt(error)
    )
  ensure
    base_io.close if base_io && !base_io.closed?
  end
end

def validate_fixed_preimages
  control = open_held(CONTROL_CWD, directory: true)
  control_stat = rejoin(CONTROL_CWD, control, directory: true)
  fail_disposal("control-cwd-identity") unless
    [control_stat.dev, control_stat.ino] == CONTROL_CWD_IDENTITY

  epoch = open_held(EPOCH, directory: true)
  epoch_stat = rejoin(EPOCH, epoch, directory: true)
  fail_disposal("epoch-identity") unless
    [epoch_stat.dev, epoch_stat.ino] == EPOCH_IDENTITY &&
      [epoch_stat.uid, epoch_stat.gid, epoch_stat.mode & 0o7777] ==
        [EXPECTED_UID, 0, 0o700]

  ruby = open_held(RUBY_IMAGE)
  ruby_stat = rejoin(RUBY_IMAGE, ruby)
  fail_disposal("ruby-preimage") unless
    [ruby_stat.dev, ruby_stat.ino] == RUBY_IDENTITY &&
      [ruby_stat.uid, ruby_stat.gid, ruby_stat.mode & 0o7777,
       ruby_stat.nlink, ruby_stat.size] == [0, 0, 0o555, 1, RUBY_BYTES] &&
      held_sha256(ruby) == RUBY_SHA256

  fixture = open_held(FIXTURE)
  fixture_stat = rejoin(FIXTURE, fixture)
  fail_disposal("fixture-preimage") unless
    [fixture_stat.dev, fixture_stat.ino] == FIXTURE_IDENTITY &&
      [fixture_stat.uid, fixture_stat.gid, fixture_stat.mode & 0o7777,
       fixture_stat.nlink, fixture_stat.size] ==
        [EXPECTED_UID, EXPECTED_GID, 0o700, 1, FIXTURE_BYTES] &&
      held_sha256(fixture) == FIXTURE_SHA256

  workspace = open_held(FIXTURE_WORKSPACE, directory: true)
  workspace_stat = rejoin(FIXTURE_WORKSPACE, workspace, directory: true)
  fail_disposal("fixture-workspace-preimage") unless
    [workspace_stat.dev, workspace_stat.ino] ==
      FIXTURE_WORKSPACE_IDENTITY && workspace_stat.uid == EXPECTED_UID &&
      workspace_stat.mode & 0o7777 == 0o700

  {
    "control" => control,
    "epoch" => epoch,
    "ruby" => ruby,
    "fixture" => fixture,
    "workspace" => workspace,
    "receipt" => {
      "control_cwd" => stat_receipt(control_stat),
      "epoch" => stat_receipt(epoch_stat),
      "ruby" => stat_receipt(ruby_stat).merge("sha256" => RUBY_SHA256),
      "fixture" =>
        stat_receipt(fixture_stat).merge("sha256" => FIXTURE_SHA256),
      "fixture_workspace" => stat_receipt(workspace_stat),
    },
  }
rescue StandardError
  %w[control epoch ruby fixture workspace].each do |name|
    io = binding.local_variable_get(name.to_sym) if
      binding.local_variable_defined?(name.to_sym)
    io.close if io && !io.closed?
  end
  raise
end

def verify_bootstrap
  incoming_umask = File.umask(0o077)
  fail_disposal("bootstrap-umask") unless incoming_umask == 0o077
  fail_disposal("bootstrap-program") unless
    File.expand_path($PROGRAM_NAME) == CONTROLLER
  fail_disposal("bootstrap-cwd") unless Dir.pwd == CONTROL_CWD
  fail_disposal("bootstrap-ruby") unless
    [RUBY_VERSION, RUBY_PATCHLEVEL, RUBY_PLATFORM] ==
      ["2.6.10", 210, "universal.arm64e-darwin25"]
  fail_disposal("bootstrap-pointer-width") unless [0].pack("J").bytesize == 8
  fail_disposal("bootstrap-byte-order") unless
    [1].pack("L").bytes == [1, 0, 0, 0]
  fail_disposal("bootstrap-credentials") unless
    [Process.uid, Process.euid, Process.gid, Process.egid] ==
      [EXPECTED_UID, EXPECTED_UID, EXPECTED_GID, EXPECTED_GID]
  fail_disposal("bootstrap-groups") unless Process.groups.sort == EXPECTED_GROUPS
  runtime_sysctls = EXPECTED_SYSCTLS.keys.each_with_object({}) do |name, result|
    result[name] = checked_sysctl_string(name)
  end
  fail_disposal("bootstrap-sysctls") unless runtime_sysctls == EXPECTED_SYSCTLS
  null_stat = File.stat(File::NULL)
  stdin_stat = STDIN.stat
  fail_disposal("bootstrap-stdin") unless
    null_stat.chardev? && stdin_stat.chardev? &&
      [stdin_stat.dev, stdin_stat.ino, stdin_stat.rdev] ==
        [null_stat.dev, null_stat.ino, null_stat.rdev]
  {
    "incoming_umask" => format("%04o", incoming_umask),
    "runtime_sysctls" => runtime_sysctls,
    "ruby" => [RUBY_VERSION, RUBY_PATCHLEVEL, RUBY_PLATFORM],
    "stdin" => File::NULL,
  }
end

$r19_kill_call_budget = {}
$r19_signal_call_state = nil

def require_not_interrupted(coordinate)
  fail_disposal("interrupted-#{coordinate}-#{$r19_interrupted}") if
    $r19_interrupted
end

def enter_kill(role, target, certificate_issued_ns)
  expected_target = role == "guardian" ? GUARDIAN_PID : -FIXTURE_PID
  fail_disposal("kill-target-#{role}") unless target == expected_target
  fail_disposal("kill-role-#{role}") unless %w[guardian fixture].include?(role)
  fail_disposal("kill-budget-#{role}") if $r19_kill_call_budget.key?(role)
  fail_disposal("kill-total-budget") if $r19_kill_call_budget.length >= 2
  require_not_interrupted("before-#{role}-kill")
  $r19_kill_call_budget[role] = true
  call_state = {
    "phase" => "MAY_HAVE_ENTERED",
    "role" => role,
    "pid" => role == "guardian" ? GUARDIAN_PID : FIXTURE_PID,
    "uniqueid" => role == "guardian" ? GUARDIAN_UNIQUEID : FIXTURE_UNIQUEID,
    "group" => role == "guardian" ? GUARDIAN_PID : FIXTURE_PID,
    "session" => role == "guardian" ? GUARDIAN_PID : FIXTURE_PID,
    "target" => target,
  }
  Fiddle.last_error = 0
  preentry_check_ns = monotonic_ns
  fail_disposal("kill-certificate-future-#{role}") if
    certificate_issued_ns > preentry_check_ns
  certificate_age_ns = preentry_check_ns - certificate_issued_ns
  fail_disposal("kill-certificate-expired-#{role}") unless
    certificate_age_ns < CERTIFICATE_MAX_AGE_NS
  $r19_signal_call_state = call_state
  result = DarwinR19Disposal.kill(target, SIGKILL_NUMBER)
  error = Fiddle.last_error
  returned = {
    "role" => role,
    "target" => target,
    "signal" => "KILL",
    "signal_number" => SIGKILL_NUMBER,
    "call_entered" => true,
    "certificate_age_ns_at_preentry_check" => certificate_age_ns,
    "certificate_max_age_ns" => CERTIFICATE_MAX_AGE_NS,
    "return" => result,
    "errno" => result == -1 ? error : 0,
    "delivered" => result == 0,
    "retried" => false,
  }
  $r19_signal_call_state = $r19_signal_call_state.merge(
    "phase" => result == 0 ? "RETURNED_SUCCESS" : "RETURNED_FAILURE",
    "return" => result,
    "errno" => result == -1 ? error : 0
  )
  returned
end

TERMINAL_STATUSES = %w[
  DISPOSAL_NOOP_ALREADY_CONSERVED
  DISPOSAL_DEFERRED_R19_TERMINAL_APPEARED
  DISPOSAL_PREACTUATION_REJECTED
  DISPOSAL_GUARDIAN_RETIRED_FIXTURE_ABSENT
  DISPOSAL_COMPLETE_EXTERNAL_CONSERVATION
  DISPOSAL_GUARDIAN_SIGNAL_ENTERED_NONTERMINAL
  DISPOSAL_FIXTURE_SIGNAL_ENTERED_NONTERMINAL
].freeze

def disposal_terminal_payload(status, fields = {})
  fail_disposal("terminal-status-#{status}") unless
    TERMINAL_STATUSES.include?(status)
  {
    "schema" => "prime-driver-v2-r19-coordinated-disposal/v1",
    "status" => status,
    "authority_vector" => "00000000",
    "gate_e_mechanics_outcome" => "ABSTAIN",
    "gate_e_scientific_outcome" => "ABSTAIN",
    "gate_e_clearance" => 0,
    "scientific_authorities_closed" => 0,
    "retry_authorized" => false,
    "cleanup_performed" => false,
    "swift_commands" => 0,
    "process_wait_calls" => 0,
    "stop_calls" => 0,
    "cont_calls" => 0,
    "kill_calls_entered" => $r19_kill_call_budget.length,
    "control_freeze_commit" => CONTROL_FREEZE_COMMIT,
    "control_freeze_tree" => CONTROL_FREEZE_TREE,
  }.merge(fields)
end

def finish_disposal(journal, status, fields = {})
  bytes = journal.publish(
    "09-disposal-terminal.json",
    disposal_terminal_payload(status, fields)
  )
  begin
    written = STDOUT.write(bytes)
    STDOUT.flush if written == bytes.bytesize
  rescue StandardError
    nil
  end
  bytes
end

def certificate_hash(snapshot)
  Digest::SHA256.hexdigest(canonical_json(snapshot))
end

# Pure transition inventory for the later readiness model. It has no process,
# filesystem, timing, or actuation behavior and is not a runtime selector.
PURE_MODEL_CASES = {
  "present" => "commit_resnapshot_call_conserve",
  "absent" => "prove_twice_no_call",
  "rebound" => "reject_no_call",
  "terminal_present" => "defer_no_call",
  "non_singleton" => "reject_no_call",
  "late_member" => "reject_no_call",
  "image_or_cwd_drift" => "reject_no_call",
  "signal_failure" => "record_no_retry",
  "prefix_interruption" => "retain_prefix_no_retry",
}.freeze

def run_controller
  journal = nil
  pending_successful_kill = nil
  handles = nil
  begin
    bootstrap = verify_bootstrap
    fail_disposal("controller-self-ruby") unless
      File.realpath(RUBY_IMAGE) == RUBY_IMAGE
    self_pid = Process.pid
    journal = DisposalJournal.create
    journal.publish(
      "00-start.json",
      {
        "schema" => "prime-driver-v2-r19-coordinated-disposal-start/v1",
        "status" => "START_PUBLISHED",
        "control_freeze_commit" => CONTROL_FREEZE_COMMIT,
        "control_freeze_tree" => CONTROL_FREEZE_TREE,
        "source_commit" => SOURCE_COMMIT,
        "source_tree" => SOURCE_TREE,
        "controller_pid" => self_pid,
        "fixed_guardian_generation" =>
          [GUARDIAN_PID, GUARDIAN_UNIQUEID, GUARDIAN_IDVERSION],
        "fixed_fixture_generation" =>
          [FIXTURE_PID, FIXTURE_UNIQUEID, FIXTURE_IDVERSION],
        "kill_call_ceiling" => 2,
        "stop_call_ceiling" => 0,
        "cont_call_ceiling" => 0,
        "process_wait_call_ceiling" => 0,
        "journal_leaf_ceiling" => JOURNAL_LEAVES.length,
        "journal_file_byte_cap" => JOURNAL_FILE_CAP,
        "bootstrap" => bootstrap,
        "xnu_abi_source" => XNU_ABI_SOURCE,
      }
    )

    handles = validate_fixed_preimages
    self_join = require_joined(self_pid, "controller-self")
    fail_disposal("controller-self-target-collision") if
      [GUARDIAN_PID, FIXTURE_PID].include?(self_pid)
    fail_disposal("controller-self-ruby-uuid") unless
      self_join.dig("unique", "uuid_hex") == RUBY_UUID
    controller_domains = [self_join.fetch("sid"), self_join.fetch("pgid")]
    fail_disposal("controller-self-target-domain-collision") unless
      (controller_domains & [GUARDIAN_PID, FIXTURE_PID]).empty?
    self_generation = [
      self_join.dig("unique", "uniqueid"),
      self_join.dig("unique", "idversion"),
    ]
    pid1 = pid1_abi_probe
    namespace = terminal_namespace(handles.fetch("epoch"))
    guardian = if namespace["kind"] == "present"
      "UNOBSERVED_TERMINAL_PRESENT"
    else
      double_target_snapshot(
        "guardian", handles.fetch("ruby"), handles.fetch("control"), self_pid
      )
    end
    fail_disposal("guardian-rebound") if
      guardian.is_a?(Hash) && guardian["kind"] == "rebound"
    journal.publish(
      "01-prestate.json",
      {
        "schema" => "prime-driver-v2-r19-coordinated-disposal-prestate/v1",
        "guardian" => guardian,
        "guardian_terminal_namespace" => namespace,
        "controller_self_excluded_before_projection" => true,
        "controller_generation" => self_generation,
        "controller_domains" => {
          "sid" => self_join.fetch("sid"),
          "pgid" => self_join.fetch("pgid"),
          "disjoint_from_target_domains" => true,
        },
        "preimages" => handles.fetch("receipt"),
        "pid1_abi_probe" => pid1,
        "replacement_target_scan_performed" => false,
      }
    )
    if namespace["kind"] == "present"
      finish_disposal(
        journal, "DISPOSAL_DEFERRED_R19_TERMINAL_APPEARED",
        "guardian_terminal" => namespace.fetch("record")
      )
      return 0
    end

    guardian_retired = false
    if guardian["kind"] == "absent"
      conservation = preexisting_absence_proof(
        GUARDIAN_PID, GUARDIAN_UNIQUEID, GUARDIAN_PID, GUARDIAN_PID, self_pid
      )
      journal.publish(
        "04-guardian-conservation.json",
        {
          "schema" => "prime-driver-v2-r19-guardian-conservation/v1",
          "signal_call_entered" => false,
          "signal_delivered" => false,
          "proof" => conservation,
          "outer_wait_owner" => "OPTIONAL_UNSIGNALED_TELEMETRY",
        }
      )
    elsif guardian["kind"] == "present"
      require_not_interrupted("before-guardian-commitment")
      namespace = terminal_namespace(handles.fetch("epoch"))
      if namespace["kind"] == "present"
        finish_disposal(
          journal, "DISPOSAL_DEFERRED_R19_TERMINAL_APPEARED",
          "guardian_terminal" => namespace.fetch("record")
        )
        return 0
      end
      journal.publish(
        "02-guardian-kill-commitment.json",
        {
          "schema" => "prime-driver-v2-r19-kill-commitment/v1",
          "role" => "guardian",
          "target" => GUARDIAN_PID,
          "generation" => [GUARDIAN_UNIQUEID, GUARDIAN_IDVERSION],
          "prestate_sha256" => certificate_hash(guardian),
          "call_may_enter_after_this_record" => true,
          "missing_result_means_may_have_entered" => true,
          "retry_authorized" => false,
          "atomic_generation_bound_signal_available" => false,
          "joined_snapshot_to_numeric_pid_race_named" => true,
          "terminal_snapshot_to_signal_race_named" => true,
        }
      )
      certificate = double_target_snapshot(
        "guardian", handles.fetch("ruby"), handles.fetch("control"), self_pid
      )
      fail_disposal("guardian-postcommit-not-present") unless
        certificate["kind"] == "present"
      issued = monotonic_ns
      namespace = terminal_namespace(handles.fetch("epoch"))
      if namespace["kind"] == "present"
        journal.publish(
          "03-guardian-kill-result.json",
          {
            "schema" => "prime-driver-v2-r19-kill-result/v1",
            "role" => "guardian",
            "call_entered" => false,
            "reason" => "R19_TERMINAL_APPEARED_AFTER_COMMITMENT",
          }
        )
        finish_disposal(
          journal, "DISPOSAL_DEFERRED_R19_TERMINAL_APPEARED",
          "guardian_terminal" => namespace.fetch("record")
        )
        return 0
      end
      result = enter_kill("guardian", GUARDIAN_PID, issued)
      returned_esrch_conservation = nil
      returned_esrch_conservation_error = nil
      if result["delivered"]
        pending_successful_kill = {
          "role" => "guardian", "pid" => GUARDIAN_PID,
          "uniqueid" => GUARDIAN_UNIQUEID, "group" => GUARDIAN_PID,
          "session" => GUARDIAN_PID, "self_pid" => self_pid,
          "conservation_complete" => false,
        }
      elsif result["return"] == -1 && result["errno"] == ERRNO_ESRCH
        begin
          returned_esrch_conservation = preexisting_absence_proof(
            GUARDIAN_PID, GUARDIAN_UNIQUEID, GUARDIAN_PID,
            GUARDIAN_PID, self_pid
          )
        rescue StandardError => proof_error
          returned_esrch_conservation_error = error_receipt(proof_error)
        end
      end
      begin
        journal.publish(
          "03-guardian-kill-result.json",
          {
            "schema" => "prime-driver-v2-r19-kill-result/v1",
            "certificate_sha256" => certificate_hash(certificate),
            "certificate_issued_monotonic_ns" => issued,
            "result" => result,
            "returned_esrch_conservation" => returned_esrch_conservation,
            "returned_esrch_conservation_error" =>
              returned_esrch_conservation_error,
          }
        )
      rescue StandardError
        if result["delivered"]
          post_kill_conservation(
            GUARDIAN_PID, GUARDIAN_UNIQUEID, GUARDIAN_PID,
            GUARDIAN_PID, self_pid
          )
          pending_successful_kill["conservation_complete"] = true
        end
        raise
      end
      if result["delivered"]
        guardian_retired = true
        conservation = post_kill_conservation(
          GUARDIAN_PID, GUARDIAN_UNIQUEID, GUARDIAN_PID,
          GUARDIAN_PID, self_pid
        )
        pending_successful_kill["conservation_complete"] = true
        journal.publish(
          "04-guardian-conservation.json",
          {
            "schema" => "prime-driver-v2-r19-guardian-conservation/v1",
            "signal_call_entered" => true,
            "signal_delivered" => true,
            "returned_esrch" => false,
            "proof" => conservation,
            "outer_wait_owner" => "OPTIONAL_UNSIGNALED_TELEMETRY",
          }
        )
        pending_successful_kill = nil
        $r19_signal_call_state = nil
      elsif returned_esrch_conservation
        journal.publish(
          "04-guardian-conservation.json",
          {
            "schema" => "prime-driver-v2-r19-guardian-conservation/v1",
            "signal_call_entered" => true,
            "signal_delivered" => false,
            "returned_esrch" => true,
            "proof" => returned_esrch_conservation,
            "outer_wait_owner" => "OPTIONAL_UNSIGNALED_TELEMETRY",
          }
        )
        guardian_retired = true
        $r19_signal_call_state = nil
      else
        finish_disposal(
          journal, "DISPOSAL_GUARDIAN_SIGNAL_ENTERED_NONTERMINAL",
          "kill_result" => result
        )
        return 70
      end
    else
      fail_disposal("guardian-state-#{guardian.fetch("kind")}")
    end

    # No Fixture process observation made before this point is retained or
    # reused. The first Fixture observation is wholly fresh after guardian
    # conservation is durable.
    fixture = double_target_snapshot(
      "fixture", handles.fetch("fixture"), handles.fetch("workspace"), self_pid
    )
    fail_disposal("fixture-rebound") if fixture["kind"] == "rebound"
    journal.publish(
      "05-fixture-prestate.json",
      {
        "schema" => "prime-driver-v2-r19-fixture-prestate/v1",
        "fixture" => fixture,
        "prior_fixture_observations_discarded" => true,
        "replacement_target_scan_performed" => false,
      }
    )

    if fixture["kind"] == "absent"
      conservation = preexisting_absence_proof(
        FIXTURE_PID, FIXTURE_UNIQUEID, FIXTURE_PID, FIXTURE_PID, self_pid
      )
      journal.publish(
        "08-fixture-conservation.json",
        {
          "schema" => "prime-driver-v2-r19-fixture-conservation/v1",
          "signal_call_entered" => false,
          "signal_delivered" => false,
          "proof" => conservation,
        }
      )
      diagnostic = observe_fail_stop_after_conservation(
        journal, handles.fetch("workspace")
      )
      status = guardian_retired ?
        "DISPOSAL_GUARDIAN_RETIRED_FIXTURE_ABSENT" :
        "DISPOSAL_NOOP_ALREADY_CONSERVED"
      finish_disposal(journal, status, "retained_diagnostic" => diagnostic)
      return 0
    end
    fail_disposal("fixture-state-#{fixture.fetch("kind")}") unless
      fixture["kind"] == "present"

    namespace = terminal_namespace(handles.fetch("epoch"))
    if namespace["kind"] == "present"
      finish_disposal(
        journal, "DISPOSAL_DEFERRED_R19_TERMINAL_APPEARED",
        "guardian_terminal" => namespace.fetch("record")
      )
      return 0
    end
    require_not_interrupted("before-fixture-commitment")
    journal.publish(
      "06-fixture-kill-commitment.json",
      {
        "schema" => "prime-driver-v2-r19-kill-commitment/v1",
        "role" => "fixture",
        "target" => -FIXTURE_PID,
        "generation" => [FIXTURE_UNIQUEID, FIXTURE_IDVERSION],
        "prestate_sha256" => certificate_hash(fixture),
        "call_may_enter_after_this_record" => true,
        "missing_result_means_may_have_entered" => true,
        "retry_authorized" => false,
        "atomic_generation_bound_signal_available" => false,
        "singleton_snapshot_to_numeric_pgid_race_named" => true,
        "late_member_and_group_reuse_race_named" => true,
        "terminal_snapshot_to_signal_race_named" => true,
      }
    )
    certificate = double_target_snapshot(
      "fixture", handles.fetch("fixture"), handles.fetch("workspace"), self_pid
    )
    fail_disposal("fixture-postcommit-not-present") unless
      certificate["kind"] == "present"
    issued = monotonic_ns
    namespace = terminal_namespace(handles.fetch("epoch"))
    if namespace["kind"] == "present"
      journal.publish(
        "07-fixture-kill-result.json",
        {
          "schema" => "prime-driver-v2-r19-kill-result/v1",
          "role" => "fixture",
          "call_entered" => false,
          "reason" => "R19_TERMINAL_APPEARED_AFTER_COMMITMENT",
        }
      )
      finish_disposal(
        journal, "DISPOSAL_DEFERRED_R19_TERMINAL_APPEARED",
        "guardian_terminal" => namespace.fetch("record")
      )
      return 0
    end
    result = enter_kill("fixture", -FIXTURE_PID, issued)
    returned_esrch_conservation = nil
    returned_esrch_conservation_error = nil
    if result["delivered"]
      pending_successful_kill = {
        "role" => "fixture", "pid" => FIXTURE_PID,
        "uniqueid" => FIXTURE_UNIQUEID, "group" => FIXTURE_PID,
        "session" => FIXTURE_PID, "self_pid" => self_pid,
        "conservation_complete" => false,
      }
    elsif result["return"] == -1 && result["errno"] == ERRNO_ESRCH
      begin
        returned_esrch_conservation = preexisting_absence_proof(
          FIXTURE_PID, FIXTURE_UNIQUEID, FIXTURE_PID, FIXTURE_PID, self_pid
        )
      rescue StandardError => proof_error
        returned_esrch_conservation_error = error_receipt(proof_error)
      end
    end
    begin
      journal.publish(
        "07-fixture-kill-result.json",
        {
          "schema" => "prime-driver-v2-r19-kill-result/v1",
          "certificate_sha256" => certificate_hash(certificate),
          "certificate_issued_monotonic_ns" => issued,
          "result" => result,
          "returned_esrch_conservation" => returned_esrch_conservation,
          "returned_esrch_conservation_error" =>
            returned_esrch_conservation_error,
        }
      )
    rescue StandardError
      if result["delivered"]
        post_kill_conservation(
          FIXTURE_PID, FIXTURE_UNIQUEID, FIXTURE_PID, FIXTURE_PID, self_pid
        )
        pending_successful_kill["conservation_complete"] = true
      end
      raise
    end
    if result["delivered"]
      conservation = post_kill_conservation(
        FIXTURE_PID, FIXTURE_UNIQUEID, FIXTURE_PID, FIXTURE_PID, self_pid
      )
      pending_successful_kill["conservation_complete"] = true
      journal.publish(
        "08-fixture-conservation.json",
        {
          "schema" => "prime-driver-v2-r19-fixture-conservation/v1",
          "signal_call_entered" => true,
          "signal_delivered" => true,
          "returned_esrch" => false,
          "proof" => conservation,
        }
      )
      pending_successful_kill = nil
      $r19_signal_call_state = nil
    elsif returned_esrch_conservation
      journal.publish(
        "08-fixture-conservation.json",
        {
          "schema" => "prime-driver-v2-r19-fixture-conservation/v1",
          "signal_call_entered" => true,
          "signal_delivered" => false,
          "returned_esrch" => true,
          "proof" => returned_esrch_conservation,
        }
      )
      $r19_signal_call_state = nil
    else
      finish_disposal(
        journal, "DISPOSAL_FIXTURE_SIGNAL_ENTERED_NONTERMINAL",
        "kill_result" => result
      )
      return 70
    end
    diagnostic = observe_fail_stop_after_conservation(
      journal, handles.fetch("workspace")
    )
    finish_disposal(
      journal, "DISPOSAL_COMPLETE_EXTERNAL_CONSERVATION",
      "retained_diagnostic" => diagnostic
    )
    0
  rescue StandardError => error
    if pending_successful_kill
      # A successful KILL can never publish a nonconservation terminal. The
      # immutable prefix remains the only durable fact if observation or
      # journal publication fails before the matching conservation leaf.
      unless pending_successful_kill["conservation_complete"]
        post_kill_conservation(
          pending_successful_kill.fetch("pid"),
          pending_successful_kill.fetch("uniqueid"),
          pending_successful_kill.fetch("group"),
          pending_successful_kill.fetch("session"),
          pending_successful_kill.fetch("self_pid")
        )
        pending_successful_kill["conservation_complete"] = true
      end
      begin
        STDERR.write(canonical_json({
          "schema" => "prime-driver-v2-r19-coordinated-disposal/v1",
          "status" => "SUCCESSFUL_KILL_PREFIX_INTERRUPTED",
          "role" => pending_successful_kill.fetch("role"),
          "authority_vector" => "00000000",
          "gate_e_outcome" => "ABSTAIN",
          "retry_authorized" => false,
          "error" => error_receipt(error),
        }) + "\n")
        STDERR.flush
      rescue StandardError
        nil
      end
      return 70
    end
    call_state = $r19_signal_call_state
    if call_state && call_state["phase"] == "RETURNED_SUCCESS"
      post_kill_conservation(
        call_state.fetch("pid"), call_state.fetch("uniqueid"),
        call_state.fetch("group"), call_state.fetch("session"), Process.pid
      )
      begin
        STDERR.write(canonical_json({
          "schema" => "prime-driver-v2-r19-coordinated-disposal/v1",
          "status" => "RETURNED_SUCCESS_PREFIX_CONSERVED",
          "role" => call_state.fetch("role"),
          "authority_vector" => "00000000",
          "retry_authorized" => false,
          "error" => error_receipt(error),
        }) + "\n")
        STDERR.flush
      rescue StandardError
        nil
      end
      return 70
    end
    if call_state && call_state["phase"] == "MAY_HAVE_ENTERED"
      post_kill_conservation(
        call_state.fetch("pid"), call_state.fetch("uniqueid"),
        call_state.fetch("group"), call_state.fetch("session"), Process.pid
      )
      begin
        STDERR.write(canonical_json({
          "schema" => "prime-driver-v2-r19-coordinated-disposal/v1",
          "status" => "SIGNAL_CALL_MAY_HAVE_ENTERED_PREFIX_RETAINED",
          "role" => call_state.fetch("role"),
          "authority_vector" => "00000000",
          "retry_authorized" => false,
          "error" => error_receipt(error),
        }) + "\n")
        STDERR.flush
      rescue StandardError
        nil
      end
      return 70
    end
    if call_state && call_state["phase"] == "RETURNED_FAILURE"
      if journal && !journal.poisoned? &&
         journal.last_leaf != "09-disposal-terminal.json"
        status = call_state.fetch("role") == "guardian" ?
          "DISPOSAL_GUARDIAN_SIGNAL_ENTERED_NONTERMINAL" :
          "DISPOSAL_FIXTURE_SIGNAL_ENTERED_NONTERMINAL"
        begin
          finish_disposal(
            journal, status,
            "kill_result" => call_state,
            "error" => error_receipt(error)
          )
          return 70
        rescue StandardError => terminal_error
          error = terminal_error
        end
      end
      begin
        STDERR.write(canonical_json({
          "schema" => "prime-driver-v2-r19-coordinated-disposal/v1",
          "status" => "RETURNED_FAILED_SIGNAL_PREFIX_RETAINED",
          "role" => call_state.fetch("role"),
          "authority_vector" => "00000000",
          "retry_authorized" => false,
          "error" => error_receipt(error),
        }) + "\n")
        STDERR.flush
      rescue StandardError
        nil
      end
      return 70
    end
    if journal && !journal.poisoned? &&
       %w[
         02-guardian-kill-commitment.json
         06-fixture-kill-commitment.json
       ].include?(journal.last_leaf)
      begin
        STDERR.write(canonical_json({
          "schema" => "prime-driver-v2-r19-coordinated-disposal/v1",
          "status" => "COMMITMENT_PREFIX_RETAINED_MAY_HAVE_ENTERED",
          "journal_leaf" => journal.last_leaf,
          "authority_vector" => "00000000",
          "gate_e_outcome" => "ABSTAIN",
          "retry_authorized" => false,
          "error" => error_receipt(error),
        }) + "\n")
        STDERR.flush
      rescue StandardError
        nil
      end
      return 70
    end
    if journal && !journal.poisoned? &&
       journal.last_leaf == "08-fixture-conservation.json"
      begin
        finish_disposal(
          journal, "DISPOSAL_COMPLETE_EXTERNAL_CONSERVATION",
          "retained_diagnostic" => {
            "classification" => "INVALID_OR_REBOUND_RETAINED_ABSTAIN",
            "error" => error_receipt(error),
          }
        )
        return 0
      rescue StandardError => terminal_error
        error = terminal_error
      end
    end
    if journal && !journal.poisoned? &&
       journal.last_leaf != "09-disposal-terminal.json"
      begin
        finish_disposal(
          journal, "DISPOSAL_PREACTUATION_REJECTED",
          "error" => error_receipt(error)
        )
        return 70
      rescue StandardError => terminal_error
        error = terminal_error
      end
    end
    begin
      STDERR.write(canonical_json({
        "schema" => "prime-driver-v2-r19-coordinated-disposal/v1",
        "status" => "PREJOURNAL_OR_TERMINAL_PUBLICATION_FAILED",
        "authority_vector" => "00000000",
        "gate_e_outcome" => "ABSTAIN",
        "retry_authorized" => false,
        "error" => error_receipt(error),
      }) + "\n")
      STDERR.flush
    rescue StandardError
      nil
    end
    70
  ensure
    if handles
      %w[control epoch ruby fixture workspace].each do |name|
        io = handles[name]
        io.close if io && !io.closed?
      end
    end
  end
end

exit(run_controller)
