#!/usr/bin/ruby

BOOTSTRAP_ENV = {
  "LANG" => "C.UTF-8",
  "LC_ALL" => "C.UTF-8",
  "TZ" => "UTC",
  "PATH" => "/usr/bin:/bin",
  "__CF_USER_TEXT_ENCODING" => "0x1F5:0x0:0x0",
}.freeze

unless ARGV.empty? && ENV.to_h == BOOTSTRAP_ENV
  STDERR.write("{\"error\":\"unexpected-bootstrap\"," \
    "\"status\":\"R19_EPOCH_CONSTRUCTION_FAILED\"}\n")
  exit 70
end

require "digest"
require "fiddle/import"
require "json"

# This is a closed Workstation namespace constructor. It cannot launch a
# process, signal a process, or interpret scientific evidence. A failed
# construction is retained and permanently consumes this R19 constructor.
PRIVATE_TMP = "/private/tmp"
STAGING_LEAF =
  "gate-e1-4-mechanics-r19-staging-befc6324-b501ad0d7ab1b6c5"
FINAL_LEAF =
  "gate-e1-4-mechanics-r19-befc6324-b501ad0d7ab1b6c5"
STAGING = "#{PRIVATE_TMP}/#{STAGING_LEAF}"
FINAL = "#{PRIVATE_TMP}/#{FINAL_LEAF}"
GUARDIAN_TERMINAL_LEAF = "r19-guardian-terminal.json"
EPOCH_CHILDREN = %w[
  home config tmp git-template swiftpm-cache swiftpm-config
  swiftpm-security clang-module-cache swiftpm-module-cache
].freeze

EXPECTED_UID = 501
EXPECTED_GID = 20
EXPECTED_GROUPS = [
  12, 20, 33, 61, 79, 80, 81, 98, 100, 204, 250, 395, 398, 399, 400, 701,
].freeze
EXPECTED_DEVICE = 16_777_231
EXPECTED_PARENT_INODE = 774_813
EXPECTED_PARENT_UID = 0
EXPECTED_PARENT_GID = 0
EXPECTED_PARENT_MODE = 0o1777
EXPECTED_EPOCH_GID = 0
EXPECTED_BASELINE_COUNT = 12
EXPECTED_BASELINE_SHA256 =
  "f5b32198b79756a580471065094208d1fa8a451f5eaaa29d0454cc95d85263f0"
EXPECTED_STAGED_COUNT = 13
EXPECTED_STAGED_SHA256 =
  "ac8beb68ecb27595efb3ab924351a177c9cf3f8cfe7e7f19d744a14b9b5b8bd5"
EXPECTED_FINAL_COUNT = 13
EXPECTED_FINAL_SHA256 =
  "043ab46066a30c11bac6adfb431829117e5cafb05a43db7388d1806b5945e0c9"
RECEIPT_MAX_BYTES = 16_384

O_RDONLY = 0
O_CLOEXEC = 0x01000000
O_NOFOLLOW_ANY = 0x20000000
O_DIRECTORY = 0x00100000
RENAME_EXCL = 0x00000004
RENAME_NOFOLLOW_ANY = 0x00000010
F_FULLFSYNC = 51
ATTR_BIT_MAP_COUNT = 5
ATTR_CMN_FLAGS = 0x00040000
ATTR_VOL_INFO = 0x80000000
ATTR_VOL_CAPABILITIES = 0x00020000
VOL_CAP_INT_RENAME_EXCL = 0x00080000
VOL_CAP_INT_RENAME_OPENFAIL = 0x00100000

module R19EpochFS
  extend Fiddle::Importer
  dlload Fiddle.dlopen(nil)
  extern "int mkdirat(int, const char*, unsigned int)"
  extern "int openat(int, const char*, int, unsigned int)"
  extern "int renameatx_np(int, const char*, int, const char*, unsigned int)"
  extern "int fgetattrlist(int, void*, void*, unsigned long, unsigned long)"
  extern "int fcntl(int, int)"
end

def canonical_receipt(report)
  payload = JSON.generate(report.sort.to_h)
  framed = report.merge("payload_sha256" => Digest::SHA256.hexdigest(payload))
  bytes = JSON.generate(framed.sort.to_h) + "\n"
  raise "receipt-cap" if bytes.bytesize > RECEIPT_MAX_BYTES
  bytes
end

def mechanics_paths
  Dir.children(PRIVATE_TMP).select do |leaf|
    leaf.start_with?("gate-e1-4-mechanics-")
  end.map { |leaf| "#{PRIVATE_TMP}/#{leaf}" }.sort
end

def mechanics_sha256(paths)
  Digest::SHA256.hexdigest(paths.join("\n") + "\n")
end

def path_absent?(path)
  File.lstat(path)
  false
rescue Errno::ENOENT
  true
end

def require_absent(path, coordinate)
  raise coordinate unless path_absent?(path)
end

def observed_presence(path)
  [!path_absent?(path), nil]
rescue StandardError => error
  [nil, "#{error.class}:#{error.message}".byteslice(0, 512)]
end

def descriptor_flags(io)
  attributes = [
    ATTR_BIT_MAP_COUNT, 0, ATTR_CMN_FLAGS, 0, 0, 0, 0,
  ].pack("S<S<L<L<L<L<L<")
  result_bytes = "\0" * 8
  Fiddle.last_error = 0
  result = R19EpochFS.fgetattrlist(
    io.fileno, attributes, result_bytes, result_bytes.bytesize, 0
  )
  error = Fiddle.last_error
  raise "fgetattrlist-flags:#{error}" unless result == 0
  length, flags = result_bytes.unpack("L<L<")
  raise "fgetattrlist-flags-frame" unless length == result_bytes.bytesize
  flags
end

def validate_volume_capabilities!(io)
  attributes = [
    ATTR_BIT_MAP_COUNT, 0, 0,
    ATTR_VOL_INFO | ATTR_VOL_CAPABILITIES, 0, 0, 0,
  ].pack("S<S<L<L<L<L<L<")
  result_bytes = "\0" * 36
  Fiddle.last_error = 0
  result = R19EpochFS.fgetattrlist(
    io.fileno, attributes, result_bytes, result_bytes.bytesize, 0
  )
  error = Fiddle.last_error
  raise "fgetattrlist-volume:#{error}" unless result == 0
  words = result_bytes.unpack("L<*")
  raise "fgetattrlist-volume-frame" unless
    words.length == 9 && words.fetch(0) == result_bytes.bytesize
  interface_capabilities = words.fetch(2)
  interface_valid = words.fetch(6)
  raise "volume-rename-excl-invalid" if
    interface_valid & VOL_CAP_INT_RENAME_EXCL == 0
  raise "volume-rename-excl-unsupported" if
    interface_capabilities & VOL_CAP_INT_RENAME_EXCL == 0
  raise "volume-rename-openfail-invalid" if
    interface_valid & VOL_CAP_INT_RENAME_OPENFAIL == 0
  raise "volume-rename-openfail" unless
    interface_capabilities & VOL_CAP_INT_RENAME_OPENFAIL == 0
end

def full_fsync(io)
  Fiddle.last_error = 0
  result = R19EpochFS.fcntl(io.fileno, F_FULLFSYNC)
  error = Fiddle.last_error
  raise "fullfsync:#{error}" unless result == 0
end

def rejoin(path, io)
  named = File.lstat(path)
  held = io.stat
  raise "named-type:#{path}" unless named.directory?
  raise "named-rebound:#{path}" unless
    [named.dev, named.ino] == [held.dev, held.ino]
  held
end

def directory_receipt(stat, leaf = nil)
  receipt = {
    "dev" => stat.dev,
    "ino" => stat.ino,
    "uid" => stat.uid,
    "gid" => stat.gid,
    "mode" => format("%04o", stat.mode & 0o7777),
    "nlink" => stat.nlink,
    "size" => stat.size,
    "mtime" => stat.mtime.to_i,
    "ctime" => stat.ctime.to_i,
    "flags" => 0,
  }
  receipt["leaf"] = leaf if leaf
  receipt
end

def openat_directory(parent, leaf)
  flags = O_RDONLY | O_CLOEXEC | O_NOFOLLOW_ANY | O_DIRECTORY
  Fiddle.last_error = 0
  descriptor = R19EpochFS.openat(parent.fileno, leaf, flags, 0)
  error = Fiddle.last_error
  raise "openat:#{leaf}:#{error}" unless descriptor >= 3
  io = IO.new(descriptor)
  raise "descriptor-cloexec:#{leaf}" unless io.close_on_exec?
  io
end

def mkdirat_once(parent, leaf)
  Fiddle.last_error = 0
  result = R19EpochFS.mkdirat(parent.fileno, leaf, 0o700)
  error = Fiddle.last_error
  raise "mkdirat:#{leaf}:#{error}" unless result == 0
end

def validate_runtime!(parent, parent_stat)
  raise "runtime-ruby-version" unless
    [RUBY_VERSION, RUBY_PATCHLEVEL, RUBY_PLATFORM] ==
      ["2.6.10", 210, "universal.arm64e-darwin25"]
  raise "runtime-pointer-width" unless [0].pack("J").bytesize == 8
  raise "runtime-byte-order" unless [1].pack("L").bytes == [1, 0, 0, 0]
  required_stat_methods = %i[
    dev ino uid gid mode nlink size mtime ctime directory?
  ]
  missing_stat = required_stat_methods.reject do |method|
    parent_stat.respond_to?(method)
  end
  raise "runtime-stat-methods:#{missing_stat.join(',')}" unless missing_stat.empty?

  required_io_methods = %i[fileno close_on_exec? stat fsync close closed?]
  missing_io = required_io_methods.reject { |method| parent.respond_to?(method) }
  raise "runtime-io-methods:#{missing_io.join(',')}" unless missing_io.empty?
  raise "runtime-fiddle" unless
    R19EpochFS.respond_to?(:mkdirat) && R19EpochFS.respond_to?(:openat) &&
    R19EpochFS.respond_to?(:renameatx_np) &&
    R19EpochFS.respond_to?(:fgetattrlist) && R19EpochFS.respond_to?(:fcntl) &&
    Fiddle.respond_to?(:last_error) && Fiddle.respond_to?(:last_error=)
  raise "runtime-json" unless JSON.respond_to?(:generate)
  raise "runtime-digest" unless Digest::SHA256.respond_to?(:hexdigest)

  validate_volume_capabilities!(parent)
  raise "private-tmp-flags" unless descriptor_flags(parent) == 0
  openat_probe = openat_directory(parent, ".")
  begin
    openat_stat = openat_probe.stat
    raise "runtime-openat-join" unless
      [openat_stat.dev, openat_stat.ino] == [parent_stat.dev, parent_stat.ino]
    raise "runtime-openat-flags" unless descriptor_flags(openat_probe) == 0
  ensure
    openat_probe.close
  end
  receipt_probe = canonical_receipt(
    "status" => "R19_CONSTRUCTOR_RUNTIME_PROBE",
    "directory" => directory_receipt(parent_stat)
  )
  raise "runtime-receipt" unless
    receipt_probe.end_with?("\n") &&
    receipt_probe.bytesize < RECEIPT_MAX_BYTES

  # Both durability primitives are exercised before the first namespace
  # mutation so an unsupported runtime/filesystem pair cannot consume R19.
  parent.fsync
  full_fsync(parent)
end

def validate_epoch_root(stat, io, nlink)
  observed = [
    stat.dev, stat.uid, stat.gid, stat.mode & 0o7777, stat.nlink,
  ]
  expected = [
    EXPECTED_DEVICE, EXPECTED_UID, EXPECTED_EPOCH_GID, 0o700, nlink,
  ]
  raise "epoch-root-metadata" unless observed == expected
  raise "epoch-root-flags" unless descriptor_flags(io) == 0
end

def validate_child(path, io, leaf)
  stat = rejoin(path, io)
  observed = [
    stat.dev, stat.uid, stat.gid, stat.mode & 0o7777, stat.nlink,
  ]
  expected = [
    EXPECTED_DEVICE, EXPECTED_UID, EXPECTED_EPOCH_GID, 0o700, 2,
  ]
  raise "epoch-child-metadata:#{leaf}" unless observed == expected
  raise "epoch-child-flags:#{leaf}" unless descriptor_flags(io) == 0
  raise "epoch-child-nonempty:#{leaf}" unless Dir.children(path).empty?
  stat
end

incoming_umask = File.umask(0o077)
held = []
root_created = false
published = false
child_mkdirat_count = 0

begin
  raise "constructor-umask" unless incoming_umask == 0o077
  raise "constructor-credentials" unless
    [Process.uid, Process.euid, Process.gid, Process.egid] ==
      [EXPECTED_UID, EXPECTED_UID, EXPECTED_GID, EXPECTED_GID]
  raise "constructor-supplementary-groups" unless
    Process.groups.sort == EXPECTED_GROUPS
  raise "staging-leaf" unless STAGING_LEAF.match?(/\A[a-z0-9-]+\z/)
  raise "final-leaf" unless FINAL_LEAF.match?(/\A[a-z0-9-]+\z/)
  raise "leaf-alias" if STAGING_LEAF == FINAL_LEAF
  raise "child-leaves" unless
    EPOCH_CHILDREN.length == 9 && EPOCH_CHILDREN.uniq.length == 9 &&
    EPOCH_CHILDREN.all? { |leaf| leaf.match?(/\A[a-z0-9-]+\z/) }

  flags = O_RDONLY | O_CLOEXEC | O_NOFOLLOW_ANY | O_DIRECTORY
  parent = IO.new(IO.sysopen(PRIVATE_TMP, flags))
  held << parent
  raise "parent-cloexec" unless parent.close_on_exec?
  parent_stat = rejoin(PRIVATE_TMP, parent)
  raise "private-tmp-preimage" unless
    [
      parent_stat.dev, parent_stat.ino, parent_stat.uid, parent_stat.gid,
      parent_stat.mode & 0o7777,
    ] == [
      EXPECTED_DEVICE, EXPECTED_PARENT_INODE, EXPECTED_PARENT_UID,
      EXPECTED_PARENT_GID, EXPECTED_PARENT_MODE,
    ]

  validate_runtime!(parent, parent_stat)
  require_absent(STAGING, "staging-preexists")
  require_absent(FINAL, "final-preexists")
  baseline = mechanics_paths
  raise "mechanics-baseline" unless
    baseline.length == EXPECTED_BASELINE_COUNT &&
    mechanics_sha256(baseline) == EXPECTED_BASELINE_SHA256

  mkdirat_once(parent, STAGING_LEAF)
  root_created = true
  staging_root = openat_directory(parent, STAGING_LEAF)
  held << staging_root
  staging_initial = rejoin(STAGING, staging_root)
  validate_epoch_root(staging_initial, staging_root, 2)
  raise "staging-inventory-initial" unless Dir.children(STAGING).empty?

  child_ios = {}
  EPOCH_CHILDREN.each do |leaf|
    rejoin(STAGING, staging_root)
    mkdirat_once(staging_root, leaf)
    child_mkdirat_count += 1
    child = openat_directory(staging_root, leaf)
    held << child
    child_ios[leaf] = child
    validate_child("#{STAGING}/#{leaf}", child, leaf)
  end

  staging_final = rejoin(STAGING, staging_root)
  validate_epoch_root(staging_final, staging_root, 11)
  raise "staging-inventory-final" unless
    Dir.children(STAGING).sort == EPOCH_CHILDREN.sort
  child_ios.each do |leaf, io|
    validate_child("#{STAGING}/#{leaf}", io, leaf)
    io.fsync
  end
  staging_root.fsync
  parent.fsync
  full_fsync(parent)

  staging_final = rejoin(STAGING, staging_root)
  validate_epoch_root(staging_final, staging_root, 11)
  raise "staging-inventory-after-sync" unless
    Dir.children(STAGING).sort == EPOCH_CHILDREN.sort
  child_ios.each do |leaf, io|
    validate_child("#{STAGING}/#{leaf}", io, leaf)
  end

  require_absent(FINAL, "final-appeared-before-publish")
  staged_paths = mechanics_paths
  raise "mechanics-staged" unless
    staged_paths.length == EXPECTED_STAGED_COUNT &&
    mechanics_sha256(staged_paths) == EXPECTED_STAGED_SHA256
  Fiddle.last_error = 0
  result = R19EpochFS.renameatx_np(
    parent.fileno, STAGING_LEAF, parent.fileno, FINAL_LEAF,
    RENAME_EXCL | RENAME_NOFOLLOW_ANY
  )
  error = Fiddle.last_error
  raise "renameatx-noreplace:#{error}" unless result == 0
  published = true

  require_absent(STAGING, "staging-remains-after-publish")
  final_stat = rejoin(FINAL, staging_root)
  validate_epoch_root(final_stat, staging_root, 11)
  raise "final-inventory" unless
    Dir.children(FINAL).sort == EPOCH_CHILDREN.sort
  child_receipts = EPOCH_CHILDREN.map do |leaf|
    io = child_ios.fetch(leaf)
    stat = validate_child("#{FINAL}/#{leaf}", io, leaf)
    directory_receipt(stat, leaf)
  end
  raise "guardian-terminal-present" unless
    path_absent?("#{FINAL}/#{GUARDIAN_TERMINAL_LEAF}")

  staging_root.fsync
  parent.fsync
  full_fsync(parent)

  final_stat = rejoin(FINAL, staging_root)
  validate_epoch_root(final_stat, staging_root, 11)
  raise "final-inventory-after-sync" unless
    Dir.children(FINAL).sort == EPOCH_CHILDREN.sort
  child_ios.each do |leaf, io|
    validate_child("#{FINAL}/#{leaf}", io, leaf)
  end
  final_paths = mechanics_paths
  final_sha256 = mechanics_sha256(final_paths)
  raise "mechanics-final" unless
    final_paths.length == EXPECTED_FINAL_COUNT &&
    final_sha256 == EXPECTED_FINAL_SHA256

  report = {
    "status" => "R19_EPOCH_CONSTRUCTION_COMPLETE",
    "staging_path" => STAGING,
    "final_path" => FINAL,
    "staging_absent" => true,
    "published_no_replace" => true,
    "root_mkdirat_count" => 1,
    "child_mkdirat_count" => child_mkdirat_count,
    "root" => directory_receipt(final_stat),
    "children" => child_receipts,
    "mechanics_count" => final_paths.length,
    "mechanics_sha256" => final_sha256,
    "guardian_terminal_present" => false,
    "constructor_process_spawn_calls" => 0,
    "constructor_signals" => 0,
  }
  receipt_bytes = canonical_receipt(report)
  written = STDOUT.write(receipt_bytes)
  raise "receipt-short-write" unless written == receipt_bytes.bytesize
  STDOUT.flush
rescue StandardError => error
  staging_present, staging_observation_error = observed_presence(STAGING)
  final_present, final_observation_error = observed_presence(FINAL)
  failure = {
    "status" => "R19_EPOCH_CONSTRUCTION_FAILED",
    "error" => "#{error.class}:#{error.message}".byteslice(0, 512),
    "root_created" => root_created,
    "published_no_replace" => published,
    "child_mkdirat_count" => child_mkdirat_count,
    "staging_present" => staging_present,
    "final_present" => final_present,
    "constructor_process_spawn_calls" => 0,
    "constructor_signals" => 0,
  }
  failure["staging_observation_error"] = staging_observation_error if
    staging_observation_error
  failure["final_observation_error"] = final_observation_error if
    final_observation_error
  begin
    paths = mechanics_paths
    failure["mechanics_count"] = paths.length
    failure["mechanics_sha256"] = mechanics_sha256(paths)
  rescue StandardError => observation_error
    failure["observation_error"] =
      "#{observation_error.class}:#{observation_error.message}".byteslice(0, 512)
  end
  begin
    failure_bytes = canonical_receipt(failure)
    failure_written = STDERR.write(failure_bytes)
    raise "failure-receipt-short-write" unless
      failure_written == failure_bytes.bytesize
    STDERR.flush
  rescue StandardError
    STDERR.write("{\"status\":\"R19_EPOCH_CONSTRUCTION_FAILED\"}\n")
  end
  exit 70
ensure
  held.reverse_each do |io|
    begin
      io.close unless io.closed?
    rescue StandardError
      nil
    end
  end
end
