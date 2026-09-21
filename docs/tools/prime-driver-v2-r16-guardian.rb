#!/usr/bin/ruby

# Retired 2026-09-20: this historical r16-guardian helper has
# failure paths that can remain active indefinitely. Reject all roles before
# bootstrap intake, library loading, process inspection, or child creation.
# The historical body below is unchanged; its original Git blob is
# 23d7b4faba1a91879c86426267b430b1801feff0. Existing live instances are unaffected.
begin
  STDERR.write_nonblock(
    "{\"schema\":\"prime-driver-v2-r16-retirement/v1\"," \
    "\"status\":\"R16_GUARDIAN_RETIRED\",\"launch_allowed\":false," \
    "\"gate_e_outcome\":\"ABSTAIN\",\"gate_e_clearance\":0}\n",
    exception: false
  )
rescue IOError, SystemCallError
  # Diagnostics are best-effort, including closed or full output pipes.
ensure
  Process.exit!(70)
end

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
  "/private/tmp/gate-e1-4-mechanics-r16-befc6324-b501ad0d7ab1b6c5"
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
TERMINAL_LEAF = "r16-guardian-terminal.json"
TERMINAL = "#{EPOCH}/#{TERMINAL_LEAF}"
TERMINAL_MAX_BYTES = 16_384
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
BSD_SIZE = 136
REGION_SIZE = 1_272
VNODE_PATH_SIZE = 1_176
VNODE_PATHS_SIZE = 2_352
PATH_SIZE = 4_096
PROC_ALL_PIDS = 1
PROC_PGRP_ONLY = 2
PROC_RUID_ONLY = 5
PROC_PIDTBSDINFO = 3
PROC_PIDREGIONPATHINFO = 8
PROC_PIDVNODEPATHINFO = 9
VM_PROT_EXECUTE = 4
O_RDONLY = 0
O_CLOEXEC = 0x01000000
O_NOFOLLOW_ANY = 0x20000000
O_DIRECTORY = 0x00100000
SIGNALS = %w[HUP INT QUIT TERM].freeze

module DarwinProcess
  extend Fiddle::Importer
  dlload Fiddle.dlopen(nil)
  extern "int proc_listpids(unsigned int, unsigned int, void*, int)"
  extern "int proc_pidinfo(int, int, unsigned long long, void*, int)"
  extern "int proc_pidpath(int, void*, unsigned int)"
  extern "int getsid(int)"
  extern "int getpgid(int)"
  extern "int openat(int, const char*, int, unsigned int)"
end

class GuardianDeadline < StandardError; end

def monotonic
  Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond)
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

def generation_key(member)
  [member[:pid], member[:start_seconds], member[:start_microseconds]]
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

def bsd_record(pid, deadline)
  require_time(deadline, "census-deadline")
  bytes = "\0" * BSD_SIZE
  Fiddle.last_error = 0
  returned = DarwinProcess.proc_pidinfo(
    pid, PROC_PIDTBSDINFO, 0, bytes, bytes.bytesize
  )
  error = Fiddle.last_error
  require_time(deadline, "census-deadline")
  return :gone if returned <= 0 && error == Errno::ESRCH::Errno
  raise "bsdinfo-#{pid}-#{error}" unless returned == BSD_SIZE
  observed_pid = u32(bytes, 12)
  raise "bsdinfo-pid-#{pid}" unless observed_pid == pid
  {
    pid: pid,
    ppid: u32(bytes, 16),
    uid: u32(bytes, 20),
    gid: u32(bytes, 24),
    ruid: u32(bytes, 28),
    rgid: u32(bytes, 32),
    svuid: u32(bytes, 36),
    svgid: u32(bytes, 40),
    status: u32(bytes, 4),
    bsd_pgid: u32(bytes, 100),
    name: bytes.byteslice(64, 32).split("\0", 2).first,
    start_seconds: u64(bytes, 120),
    start_microseconds: u64(bytes, 128),
  }
end

def expected_credentials?(member)
  [
    member[:uid], member[:gid], member[:ruid], member[:rgid],
    member[:svuid], member[:svgid],
  ] == [
    EXPECTED_UID, EXPECTED_GID, EXPECTED_UID, EXPECTED_GID,
    EXPECTED_UID, EXPECTED_GID,
  ]
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

def joined_process(pid, deadline, fixture_io)
  4.times do
    first = bsd_record(pid, deadline)
    return nil if first == :gone
    Fiddle.last_error = 0
    require_time(deadline, "census-deadline")
    sid = DarwinProcess.getsid(pid)
    sid_error = Fiddle.last_error
    require_time(deadline, "census-deadline")
    return nil if sid < 0 && sid_error == Errno::ESRCH::Errno
    raise "getsid-#{pid}-#{sid_error}" if sid < 0
    Fiddle.last_error = 0
    require_time(deadline, "census-deadline")
    pgid = DarwinProcess.getpgid(pid)
    pgid_error = Fiddle.last_error
    require_time(deadline, "census-deadline")
    return nil if pgid < 0 && pgid_error == Errno::ESRCH::Errno
    raise "getpgid-#{pid}-#{pgid_error}" unless pgid > 0
    candidate = first[:ruid] == EXPECTED_UID &&
      first[:name].start_with?("PrimeValidation")
    path = candidate ? process_path(pid, deadline) : nil
    return nil if path == :gone
    mapped_identity = nil
    fixture_cwd = nil
    if path == FIXTURE
      mapped_identity = mapped_executable_identity(pid, deadline, FIXTURE)
      return nil if mapped_identity == :gone
      raise "fixture-mapped-image-#{pid}" unless mapped_identity
      fixture_cwd = process_cwd(pid, deadline)
      return nil if fixture_cwd == :gone
    end
    second = bsd_record(pid, deadline)
    return nil if second == :gone
    raise "bsd-pgid-#{pid}" unless second[:bsd_pgid] == pgid
    stable_fields = %i[ppid uid gid ruid rgid svuid svgid name]
    if first[:start_seconds] != second[:start_seconds] ||
       first[:start_microseconds] != second[:start_microseconds] ||
       stable_fields.any? { |field| first[field] != second[field] }
      next
    end
    return second.merge(
      sid: sid,
      pgid: pgid,
      path: path,
      fixture: !mapped_identity.nil?,
      fixture_identity: mapped_identity,
      fixture_cwd: fixture_cwd,
      test_runner: path == TEST_RUNNER
    )
  end
  raise "generation-nonconvergent-#{pid}"
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
  return [] if allow_empty && returned == 0 && error == 0
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

def process_scan(
  deadline,
  fixture_io,
  list_type: PROC_RUID_ONLY,
  type_info: EXPECTED_UID,
  allow_empty: false
)
  listed_pids(
    deadline, list_type, type_info, allow_empty: allow_empty
  ).each_with_object([]) do |pid, records|
    member = joined_process(pid, deadline, fixture_io)
    next unless member
    raise "process-ruid-#{pid}-#{member[:ruid]}" unless
      member[:ruid] == EXPECTED_UID
    records << member
  end
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
    raise "workspace-registry-capacity" if novel.length > 64
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
    held = entry[:workspace].stat
    [held.dev, held.ino] == cwd[:identity] &&
      [held.uid, held.gid, held.mode & 0o7777] ==
        [EXPECTED_UID, entry[:workspace_gid], 0o700]
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
  attr_reader :captured, :proof_groups, :scans, :unsafe,
              :signal_count, :stop_count, :kill_count,
              :fixture_replacement_seen, :unexpected_nested_seen,
              :unsafe_seen_count, :workspace_registry,
              :global_session_projection_count, :actuation_groups

  def initialize(fixture_io, guardian_pid, guardian_sid, workspace_registry)
    @fixture_io = fixture_io
    @guardian_pid = guardian_pid
    @guardian_sid = guardian_sid
    @workspace_registry = workspace_registry
    @captured = {}
    @proof_groups = Set.new
    @actuation_groups = {}
    @supervisors = {}
    @detached_sessions = {}
    @scans = 0
    @unsafe = []
    @unsafe_seen = Set.new
    @armed = false
    @signal_count = 0
    @stop_count = 0
    @kill_count = 0
    @orphan_residuals = Set.new
    @fixture_replacement_seen = false
    @unexpected_nested_seen = false
    @last_domain_generations = Set.new
    @global_session_projection_count = 0
  end

  def arm!
    return if @armed
    @armed = true
  end

  def orphan_attribution_residual_count
    @orphan_residuals.length
  end

  def remember(member)
    @captured[generation_key(member)] ||= member
    @proof_groups.add(member[:pgid])
    domain = member[:sid] == @guardian_sid ? :session : :detached
    existing = @actuation_groups[member[:pgid]]
    raise "actuation-group-domain-rebound-#{member[:pgid]}" if
      existing && existing != domain
    @actuation_groups[member[:pgid]] = domain
  end

  def seed_direct_group(group)
    raise "direct-group-target" unless group > 0 && group != @guardian_pid
    existing = @actuation_groups[group]
    raise "direct-group-domain-rebound-#{group}" if existing && existing != :session
    @proof_groups.add(group)
    @actuation_groups[group] = :session
  end

  def fixture_nonce_authorized?(member)
    @armed && member[:fixture] &&
      @workspace_registry.admits?(member[:fixture_cwd])
  end

  def detached_members(records)
    by_pid = records.to_h { |member| [member[:pid], member] }
    authorized = Set.new
    records.each do |member|
      key = generation_key(member)
      leader = by_pid[member[:sid]]
      leader_key = leader && generation_key(leader)
      current_leader = member[:pid] == member[:sid] &&
        member[:pgid] == member[:pid] &&
        @detached_sessions[member[:sid]] == leader_key
      authorized.add(key) if fixture_nonce_authorized?(member) ||
        @captured.key?(key) || current_leader
    end
    loop do
      changed = false
      records.each do |member|
        next if member[:sid] == @guardian_sid
        key = generation_key(member)
        next if authorized.include?(key)
        parent = by_pid[member[:ppid]]
        next unless parent && parent[:sid] == member[:sid] &&
          authorized.include?(generation_key(parent))
        authorized.add(key)
        changed = true
      end
      break unless changed
    end
    uncertain = records.find do |member|
      member[:sid] != @guardian_sid &&
        @detached_sessions.key?(member[:sid]) &&
        !authorized.include?(generation_key(member))
    end
    raise "detached-session-generation-uncertain-#{uncertain[:pid]}" if uncertain
    records.select do |member|
      member[:sid] != @guardian_sid &&
        authorized.include?(generation_key(member))
    end
  end

  def observe(deadline)
    @workspace_registry.update
    records = process_scan(deadline, @fixture_io)
    @scans += 1
    by_pid = records.to_h { |member| [member[:pid], member] }
    global_session_projection(deadline, @guardian_sid).each_key do |pid|
      prior = by_pid[pid]
      records.reject! { |record| record[:pid] == pid }
      by_pid.delete(pid)
      refreshed = joined_process(pid, deadline, @fixture_io)
      next unless refreshed
      raise "global-session-ruid-#{pid}-#{refreshed[:ruid]}" unless
        refreshed[:ruid] == EXPECTED_UID
      if prior
        raise "global-session-generation-#{pid}" unless
          generation_key(prior) == generation_key(refreshed)
        if prior[:sid] == @guardian_sid && refreshed[:sid] != @guardian_sid
          remember(refreshed)
          @unexpected_nested_seen = true
        end
      elsif refreshed[:sid] != @guardian_sid
        raise "global-session-transition-unjoined-#{pid}"
      end
      records << refreshed
      by_pid[pid] = refreshed
    end
    @global_session_projection_count += 1
    records.sort_by! { |member| member[:pid] }
    @last_domain_generations = records.map { |member| generation_key(member) }.to_set
    session = records.select { |member| member[:sid] == @guardian_sid }
    joined_guardian = by_pid[@guardian_pid]
    raise "guardian-generation-missing" unless joined_guardian &&
      joined_guardian[:pgid] == @guardian_pid
    raise "guardian-group-joined" if session.any? do |member|
      member[:pid] != @guardian_pid && member[:pgid] == @guardian_pid
    end
    session_keys = session.to_h do |member|
      [member[:pid], generation_key(member)]
    end
    fixtures = records.select { |member| member[:fixture] }
    runners = records.select { |member| member[:test_runner] }
    (session + fixtures + runners).each do |member|
      raise "process-credentials-#{member[:pid]}" unless
        expected_credentials?(member)
    end

    fixtures.each do |member|
      key = generation_key(member)
      parent_joined = session_keys[member[:ppid]]
      if member[:sid] == member[:pid] && member[:pgid] == member[:pid] &&
         parent_joined
        @supervisors[member[:pid]] = key
        @detached_sessions[member[:sid]] = key
      end
      @fixture_replacement_seen ||=
        member[:fixture_identity] != FIXTURE_IDENTITY
    end

    records.each do |member|
      next if member[:sid] == @guardian_sid || member[:fixture]
      parent_joined = session_keys[member[:ppid]]
      next unless parent_joined && member[:sid] == member[:pid] &&
        member[:pgid] == member[:pid]
      @detached_sessions[member[:sid]] = generation_key(member)
      @unexpected_nested_seen = true
    end

    detached = detached_members(records)
    detached.each do |member|
      raise "detached-credentials-#{member[:pid]}" unless
        expected_credentials?(member)
    end
    detached_keys = detached.to_h do |member|
      [member[:pid], generation_key(member)]
    end
    fixtures.each do |member|
      next unless @armed
      key = generation_key(member)
      current_supervisor = by_pid[member[:sid]]
      supervisor_key = current_supervisor && generation_key(current_supervisor)
      lineaged = @captured.key?(key) ||
        @supervisors[member[:pid]] == key ||
        (!supervisor_key.nil? &&
          @supervisors[member[:sid]] == supervisor_key) ||
        session_keys.key?(member[:ppid]) ||
        detached_keys.key?(member[:ppid])
      @orphan_residuals.add(key) unless lineaged
    end

    @unsafe = fixtures.reject do |member|
      member[:sid] == @guardian_sid ||
        detached_keys[member[:pid]] == generation_key(member)
    end
    @unsafe += runners.reject do |member|
      member[:sid] == @guardian_sid ||
        detached_keys[member[:pid]] == generation_key(member)
    end
    @unsafe.each { |member| @unsafe_seen.add(generation_key(member)) }

    owned_session = session.reject { |member| member[:pid] == @guardian_pid }
    owned_session.each { |member| remember(member) }
    detached.each { |member| remember(member) }
    [owned_session, detached]
  end

  def unsafe_seen_count
    @unsafe_seen.length
  end

  def captured_generation_present?
    @captured.keys.any? { |key| @last_domain_generations.include?(key) }
  end

  def joined_group(group, deadline, domain:)
    raise "group-target" unless group > 0 && group != @guardian_pid
    members = process_scan(
      deadline,
      @fixture_io,
      list_type: PROC_PGRP_ONLY,
      type_info: group,
      allow_empty: true
    )
    @scans += 1
    authorized_detached = detached_members(members).map do |member|
      generation_key(member)
    end.to_set
    members.each do |member|
      raise "group-pgid-#{group}" unless member[:pgid] == group
      case domain
      when :session
        raise "group-session-domain-#{group}" unless
          member[:sid] == @guardian_sid && member[:pid] != @guardian_pid
      when :detached
        raise "group-detached-domain-#{group}" unless
          member[:sid] != @guardian_sid &&
            authorized_detached.include?(generation_key(member))
      else
        raise "group-domain-#{group}"
      end
      remember(member)
    end
    members
  end

  def record_signal(signal)
    @signal_count += 1
    @stop_count += 1 if signal == "STOP"
    @kill_count += 1 if signal == "KILL"
  end
end

def signal_group(signal, group, deadline)
  require_time(deadline, "signal-deadline")
  raise "guardian-group-target" if group == Process.getpgrp
  Process.kill(signal, -group)
  true
rescue Errno::ESRCH
  false
rescue Errno::EPERM, Errno::EINVAL => error
  raise "group-signal-#{signal}-#{group}-#{error.errno}"
end

def group_absent?(group, deadline)
  require_time(deadline, "group-proof-deadline")
  Process.kill(0, -group)
  false
rescue Errno::ESRCH
  true
rescue Errno::EPERM, Errno::EINVAL => error
  raise "group-proof-#{group}-#{error.errno}"
end

class ChildLifecycle
  attr_reader :pid, :status

  def initialize(pid)
    @pid = pid
    @status = nil
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
  rescue Errno::ECHILD
    raise "wait-lost-owner"
  end

  def reap(deadline)
    until exact_reaped?
      require_time(deadline, "exact-reap-deadline")
      poll
      sleep 0.001 unless exact_reaped?
    end
    @status
  end
end

def signal_current_group(tracker, signal, group, deadline, domain:)
  members = tracker.joined_group(group, deadline, domain: domain)
  return false if members.empty?
  if signal_group(signal, group, deadline)
    tracker.record_signal(signal)
    true
  else
    false
  end
end

def emergency_contain_known_groups(tracker, report)
  tracker.actuation_groups.sort.each do |group, domain|
    %w[STOP KILL].each do |signal|
      begin
        signal_current_group(tracker, signal, group, nil, domain: domain)
      rescue StandardError => error
        report["containment_fault_count"] += 1
        report["last_emergency_containment_fault"] =
          "#{error.class}:#{error.message}".byteslice(0, 512)
        break
      end
    end
  end
end

def prove_empty_and_absent(tracker, deadline)
  empty = 0
  while empty < 2
    session, detached = tracker.observe(deadline)
    raise "domain-not-empty" unless session.empty? && detached.empty?
    empty += 1
  end
  raise "captured-generation-present" if tracker.captured_generation_present?
  tracker.proof_groups.each do |group|
    raise "proof-group-present-#{group}" unless group_absent?(group, deadline)
  end
  empty
end

def fixed_point(tracker, deadline)
  previous = nil
  loop do
    require_time(deadline, "fixed-point-deadline")
    session, detached = tracker.observe(deadline)
    session_groups = session.map { |member| member[:pgid] }.uniq.sort
    detached_groups = detached.map { |member| member[:pgid] }.uniq.sort
    session_groups.each do |group|
      signal_current_group(
        tracker, "STOP", group, deadline, domain: :session
      )
    end
    detached_groups.each do |group|
      signal_current_group(
        tracker, "STOP", group, deadline, domain: :detached
      )
    end
    current = (session + detached).map { |member| generation_key(member) }.sort
    return [session_groups, detached_groups] if current == previous &&
      (session + detached).all? { |member| [4, 5].include?(member[:status]) }
    previous = current
    sleep 0.001
  end
end

def contain(tracker, lifecycle, deadline)
  lifecycle.poll
  session_groups, detached_groups = fixed_point(tracker, deadline)
  session_groups.each do |group|
    signal_current_group(
      tracker, "KILL", group, deadline, domain: :session
    )
  end
  detached_groups.each do |group|
    signal_current_group(
      tracker, "KILL", group, deadline, domain: :detached
    )
  end
  lifecycle.reap(deadline)
  loop do
    require_time(deadline, "containment-empty-deadline")
    session, detached = tracker.observe(deadline)
    break if session.empty? && detached.empty?
    late_session, late_detached = fixed_point(tracker, deadline)
    late_session.each do |group|
      signal_current_group(
        tracker, "KILL", group, deadline, domain: :session
      )
    end
    late_detached.each do |group|
      signal_current_group(
        tracker, "KILL", group, deadline, domain: :detached
      )
    end
    sleep 0.001
  end
  prove_empty_and_absent(tracker, deadline)
end

def contain_until_proved(tracker, lifecycle, hard_deadline, report)
  deadline = hard_deadline
  loop do
    begin
      return contain(tracker, lifecycle, deadline)
    rescue GuardianDeadline => error
      report["hard_deadline_crossed"] = true
      report["containment_deadline_coordinate"] ||= error.message
      deadline = nil
    rescue StandardError => error
      report["containment_fault_count"] += 1
      report["last_containment_fault"] =
        "#{error.class}:#{error.message}".byteslice(0, 512)
      deadline = nil
      emergency_contain_known_groups(tracker, report)
      sleep 0.1
    end
  end
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

def persist_terminal(report, epoch_parent)
  payload = JSON.generate(report.sort.to_h)
  payload_sha256 = Digest::SHA256.hexdigest(payload)
  terminal_report = report.merge("payload_sha256" => payload_sha256)
  bytes = JSON.generate(terminal_report.sort.to_h) + "\n"
  raise "terminal-cap" if bytes.bytesize > TERMINAL_MAX_BYTES
  flags = File::RDWR | File::CREAT | File::EXCL |
    O_CLOEXEC | O_NOFOLLOW_ANY
  Fiddle.last_error = 0
  descriptor = DarwinProcess.openat(
    epoch_parent.fileno, TERMINAL_LEAF, flags, 0o400
  )
  error = Fiddle.last_error
  raise "terminal-openat-#{error}" unless descriptor >= 3
  io = IO.new(descriptor)
  begin
    raise "terminal-cloexec" unless io.close_on_exec?
    written = io.write(bytes)
    raise "terminal-short-write" unless written == bytes.bytesize
    io.fsync
    stat = rejoin(TERMINAL, io)
    raise "terminal-metadata" unless
      [stat.uid, stat.mode & 0o7777, stat.nlink, stat.size] ==
        [EXPECTED_UID, 0o400, 1, bytes.bytesize]
    raise "terminal-bytes" unless held_sha256(io) == Digest::SHA256.hexdigest(bytes)
    rejoin(EPOCH, epoch_parent, directory: true)
    epoch_parent.fsync
  ensure
    io.close
  end
  bytes
end

$interrupted = nil
SIGNALS.each { |signal| Signal.trap(signal) { $interrupted ||= signal } }

report = {
  "status" => "R16_GUARDIAN_PRELAUNCH_FAILED",
  "authority_vector" => "00000000",
  "gate_e_outcome" => "ABSTAIN",
  "process_census_scope" => "ruid:501+global-session-projection",
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
  "global_session_projection_count" => 0,
  "captured_process_generations" => 0,
  "captured_fixture_generations" => 0,
  "proof_groups" => [],
  "stop_signals_sent" => 0,
  "kill_signals_sent" => 0,
  "orphan_attribution_residual_count" => 0,
  "fixture_replacement_seen" => false,
  "unexpected_nested_session_seen" => false,
  "unsafe_process_count" => 0,
  "unsafe_process_history_count" => 0,
  "workspace_baseline_count" => 0,
  "workspace_baseline_sha256" => nil,
  "held_workspace_count" => 0,
  "workspace_rebound_seen" => false,
  "final_empty_scans" => 0,
}

child_pid = nil
lifecycle = nil
tracker = nil
fixture_io = nil
epoch_parent = nil
epoch_children = nil
hard_deadline = nil
source_io = nil
operational_error = nil
process_proof = false
workspace_registry = nil

begin
  raise "guardian-credentials" unless
    [Process.uid, Process.euid, Process.gid, Process.egid] ==
      [EXPECTED_UID, EXPECTED_UID, EXPECTED_GID, EXPECTED_GID]
  raise "guardian-supplementary-groups" unless
    Process.groups.sort == EXPECTED_GROUPS
  source_io = open_held(SOURCE, directory: true)
  source_stat = rejoin(SOURCE, source_io, directory: true)
  raise "source-identity" unless [source_stat.dev, source_stat.ino] == SOURCE_IDENTITY
  epoch_parent, epoch_children = verify_epoch
  fixture_io = open_held(FIXTURE)
  verify_fixture(fixture_io)
  guardian_sid = Process.setsid
  guardian_pid = Process.pid
  raise "guardian-session" unless guardian_sid == guardian_pid &&
    Process.getsid(0) == guardian_pid && Process.getpgrp == guardian_pid
  workspace_registry = WorkspaceRegistry.new
  raise "workspace-baseline" unless
    workspace_registry.baseline.length == ADMISSION_BASELINE_COUNT &&
    workspace_registry.baseline_sha256 == ADMISSION_BASELINE_SHA256
  tracker = Tracker.new(
    fixture_io, guardian_pid, guardian_sid, workspace_registry
  )
  preflight_deadline = monotonic + 15_000_000_000
  2.times do
    preflight = tracker.observe(preflight_deadline)
    raise "process-preflight-nonempty" unless
      preflight.first.empty? && preflight.last.empty? && tracker.unsafe.empty?
    raise "workspace-preflight-drift" unless
      workspace_registry.preflight_unchanged?
  end
  raise "interrupted-before-spawn:#{$interrupted}" if $interrupted

  started_monotonic = monotonic
  ordinary_deadline = started_monotonic + CHILD_NANOSECONDS
  hard_deadline = started_monotonic + HARD_NANOSECONDS
  report["assessment_start_monotonic_ns"] = started_monotonic
  report["child_started_at"] = Time.now.to_i
  tracker.arm!
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
  lifecycle = ChildLifecycle.new(child_pid)
  tracker.seed_direct_group(child_pid)
  raise "spawn-pgroup" unless Process.getpgid(child_pid) == child_pid
  raise "spawn-session" unless Process.getsid(child_pid) == guardian_sid
  loop do
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
    raise "unsafe-process-domain" unless tracker.unsafe.empty?
    lifecycle.poll
    next if lifecycle.exact_reaped?
    remaining = (ordinary_deadline - monotonic).fdiv(1_000_000_000)
    if remaining <= 0
      report["timed_out"] = true
      break
    end
    sleep([TRACK_INTERVAL, remaining].min)
  end
  report["interrupted_signal"] = $interrupted
  report["child_ended_at"] = Time.now.to_i if lifecycle.exact_reaped?
  report["child_reaped_elapsed_ns"] = monotonic - started_monotonic if
    lifecycle.exact_reaped?

  session_leftovers, detached_leftovers = tracker.observe(hard_deadline)
  if !lifecycle.exact_reaped? || !session_leftovers.empty? ||
     !detached_leftovers.empty?
    report["containment_started"] = true
    report["containment_started_elapsed_ns"] =
      monotonic - started_monotonic
    report["final_empty_scans"] = contain_until_proved(
      tracker, lifecycle, hard_deadline, report
    )
  else
    report["final_empty_scans"] =
      prove_empty_and_absent(tracker, hard_deadline)
  end
  process_proof = true
  report["process_containment_complete"] = true
  report["child_ended_at"] ||= Time.now.to_i
  report["child_reaped_elapsed_ns"] ||= monotonic - started_monotonic

  verify_fixture(fixture_io)
  rejoin(SOURCE, source_io, directory: true)
  rejoin(EPOCH, epoch_parent, directory: true)
  raise "epoch-inventory-post" unless Dir.children(EPOCH).sort == EPOCH_CHILDREN.sort
  epoch_children.each do |leaf, io|
    rejoin("#{EPOCH}/#{leaf}", io, directory: true)
  end
rescue StandardError => error
  operational_error = error
  if child_pid && tracker && !process_proof
    lifecycle ||= ChildLifecycle.new(child_pid)
    tracker.arm!
    report["containment_started"] = true
    report["containment_started_elapsed_ns"] ||=
      monotonic - started_monotonic if started_monotonic
    report["final_empty_scans"] = contain_until_proved(
      tracker, lifecycle, hard_deadline, report
    )
    process_proof = true
    report["process_containment_complete"] = true
    report["child_ended_at"] ||= Time.now.to_i
    report["child_reaped_elapsed_ns"] ||=
      monotonic - started_monotonic if started_monotonic
  end
end

SIGNALS.each { |signal| Signal.trap(signal, "IGNORE") }
terminal_interrupted = $interrupted
report["interrupted_signal"] = terminal_interrupted
report["assessment_elapsed_ns"] = monotonic - started_monotonic if
  started_monotonic
if lifecycle&.status
  report["child_raw_status"] = lifecycle.status.to_i
  report["child_exit_status"] = lifecycle.status.exitstatus
  report["child_term_signal"] = lifecycle.status.termsig
end
if tracker
  report["complete_scan_count"] = tracker.scans
  report["global_session_projection_count"] =
    tracker.global_session_projection_count
  report["captured_process_generations"] = tracker.captured.length
  report["captured_fixture_generations"] = tracker.captured.values.count do |member|
    member[:fixture]
  end
  report["proof_groups"] = tracker.proof_groups.to_a.sort
  report["stop_signals_sent"] = tracker.stop_count
  report["kill_signals_sent"] = tracker.kill_count
  report["orphan_attribution_residual_count"] =
    tracker.orphan_attribution_residual_count
  report["fixture_replacement_seen"] = tracker.fixture_replacement_seen
  report["unexpected_nested_session_seen"] = tracker.unexpected_nested_seen
  report["unsafe_process_count"] = tracker.unsafe.length
  report["unsafe_process_history_count"] = tracker.unsafe_seen_count
end
if workspace_registry
  report["workspace_baseline_count"] = workspace_registry.baseline.length
  report["workspace_baseline_sha256"] =
    workspace_registry.baseline_sha256
  report["held_workspace_count"] = workspace_registry.held_workspace_count
  report["workspace_rebound_seen"] = workspace_registry.rebound_seen
end
report["error"] =
  "#{operational_error.class}:#{operational_error.message}".byteslice(0, 512) if
    operational_error

if child_pid && process_proof
  natural = operational_error.nil? && lifecycle.status&.success? &&
    !terminal_interrupted && !report["timed_out"] && tracker.signal_count == 0 &&
    !report["containment_started"] &&
    report["assessment_elapsed_ns"] < CHILD_NANOSECONDS &&
    tracker.global_session_projection_count == tracker.scans &&
    tracker.unsafe.empty? && tracker.unsafe_seen_count == 0 &&
    tracker.orphan_attribution_residual_count == 0 &&
    !tracker.fixture_replacement_seen && !tracker.unexpected_nested_seen &&
    !workspace_registry.rebound_seen
  report["status"] = natural ?
    "R16_GUARDIAN_NATURAL_EXIT" : "R16_GUARDIAN_CONTAINED_ABNORMAL"
  begin
    terminal_bytes = persist_terminal(report, epoch_parent)
    begin
      STDOUT.write(terminal_bytes)
      STDOUT.flush
    rescue StandardError
      nil
    end
  rescue StandardError => terminal_error
    report["status"] = "R16_GUARDIAN_TERMINAL_FAILED"
    report["terminal_error"] =
      "#{terminal_error.class}:#{terminal_error.message}".byteslice(0, 512)
    STDERR.write(JSON.generate(report.sort.to_h) + "\n")
    exit 70
  end
  exit(natural ? 0 : 70)
end

STDERR.write(JSON.generate(report.sort.to_h) + "\n")
exit 70
