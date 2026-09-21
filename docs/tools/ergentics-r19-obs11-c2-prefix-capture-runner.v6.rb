#!/usr/bin/ruby

# Retired 2026-09-20: this frozen helper has unbounded process, pipe,
# or recovery waits. Reject before bootstrap intake, file access, or signals.
# Original Git blob: 4dd0e5eb80780d2de03e2dfd2b2b118ba959fcb8.
# Existing live instances and historical copies are unaffected.
begin
  STDERR.write_nonblock(
    "{\"schema\":\"prime-v2-historical-helper-retirement/v1\"," \
    "\"helper\":\"ergentics-r19-obs11-c2-prefix-capture-runner.v6.rb\"," \
    "\"status\":\"RETIRED\",\"launch_allowed\":false," \
    "\"gate_e_outcome\":\"ABSTAIN\",\"gate_e_clearance\":0}\n",
    exception: false
  )
rescue IOError, SystemCallError
  # Diagnostic failure or a full pipe must not delay retirement.
ensure
  Process.exit!(70)
end

# Closed control-only runner that captures the non-consuming C2 prefix harness
# with descriptor-rooted publication and raw-first durable retention.

require "digest"
require "fiddle/import"
require "json"

class C2PrefixCaptureFailure < StandardError; end

EXPECTED_ENVIRONMENT = {
  "__CF_USER_TEXT_ENCODING" => "0x1F5:0x0:0x0",
}.freeze
EXPECTED_GROUPS = [
  12, 20, 33, 61, 79, 80, 81, 98, 100, 204, 250, 395, 398, 399,
  400, 701,
].freeze
REPOSITORY =
  "/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/" \
  ".phase-a-v2-fixture-identity-restore-only-staging"
CAPTURE_PARENT =
  "#{REPOSITORY}/artifacts/" \
  "r19-obs11-retained-r19-projection-chain-2026-08-26"
CAPTURE_ROOT_LEAF = "r19-obs11-c2-preconsumption-prefix-capture.v6"
CAPTURE_ROOT = "#{CAPTURE_PARENT}/#{CAPTURE_ROOT_LEAF}"
HARNESS =
  "#{REPOSITORY}/docs/tools/" \
  "ergentics-r19-obs11-c2-preconsumption-prefix-harness.v4.rb"
CHILD_ENVIRONMENT = EXPECTED_ENVIRONMENT
CHANNEL_CAP = 65_536
OUTER_SUMMARY_CAP = 16_384
INCOMPLETE_LEAF_CAP = 262_144

O_RDONLY = 0
O_RDWR = 2
O_CLOEXEC = 0x01000000
O_NOFOLLOW_ANY = 0x20000000
O_DIRECTORY = 0x00100000
AT_SYMLINK_NOFOLLOW = 0x0020
AT_SYMLINK_NOFOLLOW_ANY = 0x0800
AT_FDCWD = -2
RENAME_EXCL = 0x00000004
RENAME_NOFOLLOW_ANY = 0x00000010
F_FULLFSYNC = 51
STAT_BYTES = 144
S_IFMT = 0o170000
S_IFDIR = 0o040000
S_IFREG = 0o100000
DT_DIR = 4
DT_REG = 8
STAGING_TEMPLATE = "c2-prefix-capture.tmp.XXXXXX"
STAGING_PATTERN = /\Ac2-prefix-capture\.tmp\.[A-Za-z0-9]{6}\z/

module C2CaptureDarwin
  extend Fiddle::Importer
  dlload Fiddle.dlopen(nil)
  extern "void* __error()"
  extern "int mkdirat(int, const char*, unsigned int)"
  extern "int openat(int, const char*, int)"
  extern "int fstatat(int, const char*, void*, int)"
  extern "int mkostempsat_np(int, char*, int, int)"
  extern "int renameatx_np(int, const char*, int, const char*, unsigned int)"
  extern "int fcntl(int, int)"
  extern "void* fdopendir(int)"
  extern "void* readdir(void*)"
  extern "int closedir(void*)"
end

PARENT_EXPECTED = {
  "device" => 16_777_231,
  "flags" => 0,
  "gid" => 20,
  "inode" => 17_940_458,
  "mode" => "0755",
  "uid" => 501,
}.freeze
HARNESS_EXPECTED = {
  "bytes" => 9_474,
  "device" => 16_777_231,
  "gid" => 20,
  "inode" => 17_956_974,
  "mode" => "0644",
  "nlink" => 1,
  "sha256" =>
    "5615b14b24e68644c6ef5cfb379e415160f465af987a3aa74d1908fca8ada39e",
  "uid" => 501,
}.freeze
CONTROLLER_EXPECTED = {
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
PREFIX_EXPECTED = {
  "bytes" => 143_916,
  "lines" => 3_879,
  "sha256" =>
    "3328e81448266ad8a63dbeca72fba580e9f91556aaede391f92e30c37084e8b4",
}.freeze
RUBY_MAPPING_EXPECTED = {
  "device" => 16_777_231,
  "file_offset" => 65_536,
  "inode" => 1_152_921_500_312_572_705,
  "path" => "/usr/bin/ruby",
  "uuid_hex" => "eb2540b7e13236beb719619d0fbf7203",
}.freeze
DOT_BUILD_EXPECTED = {
  "aggregate_file_bytes" => 457_185_791,
  "directories" => 1_182,
  "files" => 3_348,
  "frames" => 4_532,
  "root" =>
    "#{REPOSITORY}/Observability/ErgenticsInterface/.build",
  "symlinks" => 2,
}.freeze
FROZEN_ROOTS_EXPECTED = {
  "/private/tmp/ergentics-r19-obs11-chain-runner-296d32da-build-a-v1" =>
    "ABSENT",
  "/private/tmp/ergentics-r19-obs11-chain-runner-296d32da-build-b-v1" =>
    "ABSENT",
  "/private/tmp/ergentics-r19-obs11-chain-runner-296d32da-execution-closure-v1" =>
    "ABSENT",
  "/private/tmp/ergentics-r19-obs11-chain-runner-296d32da-build-b-witness-closure-v1" =>
    "ABSENT",
  "/private/tmp/ergentics-r19-obs11-c2-build-control-8405636a-v1" =>
    "ABSENT",
}.freeze
HARNESS_OPERATIONS_EXPECTED = {
  "apple_ruby_harness_entries" => 1,
  "bootstrap_preflight_entries" => 1,
  "continuity_revalidation_entries_after_bootstrap" => 2,
  "controller_bottom_entries" => 0,
  "controller_full_invocations" => 0,
  "dot_build_snapshot_entries_after_bootstrap" => 1,
  "filesystem_creation_call_entries" => 0,
  "journal_constructor_entries" => 0,
  "process_signal_call_entries" => 0,
  "process_spawn_call_entries" => 0,
  "product_execution_entries" => 0,
  "python_entries" => 0,
  "source_prefix_evaluation_entries" => 1,
  "state_machine_constructor_entries" => 0,
  "swiftpm_spawn_entries" => 0,
}.freeze
HARNESS_POLICY_EXPECTED = {
  "eventual_swift_spawn_close_others_frozen" => true,
  "python" => "FORBIDDEN",
  "ruby_fd3_through_fd7_pipe_deviation" =>
    "CATALOGED_UNSUITABLE_AS_SWIFT_FD_DOMAIN_PROXY",
  "ruby_inherited_fd_census_in_this_harness" => false,
  "swift_fd_domain_inference_from_this_harness" => false,
}.freeze
HARNESS_TOP_LEVEL_KEYS = %w[
  bottom_entry_evaluated continuity controller controller_source
  descriptor_close_count dot_build frozen_roots_after
  historical_operations_reinterpreted language_and_fd_policy mapped_ruby
  operation_scope operations prefix status tmp
].sort.freeze
SUCCESS_INVENTORY = %w[
  00-start.json 01-stdout.bin 02-stderr.bin 03-result.json 04-closure.json
].freeze

def capture_fail(code)
  raise C2PrefixCaptureFailure, code
end

def canonical_value(value)
  case value
  when Hash
    value.keys.sort.each_with_object({}) do |key, output|
      output[key] = canonical_value(value.fetch(key))
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

def mode_string(stat)
  format("%04o", stat.mode & 0o7777)
end

def file_identity(stat, sha256: nil)
  result = {
    "bytes" => stat.size,
    "device" => stat.dev,
    "gid" => stat.gid,
    "inode" => stat.ino,
    "mode" => mode_string(stat),
    "nlink" => stat.nlink,
    "uid" => stat.uid,
  }
  result["sha256"] = sha256 if sha256
  result
end

def native_errno_pointer
  pointer = C2CaptureDarwin.__error
  pointer.is_a?(Fiddle::Pointer) ? pointer : Fiddle::Pointer.new(pointer)
end

def native_call
  pointer = native_errno_pointer
  capture_fail("NATIVE_ERRNO_WIDTH") unless Fiddle::SIZEOF_INT == 4
  zero = [0].pack("l<")
  Fiddle.last_error = 0
  pointer[0, 4] = zero
  capture_fail("NATIVE_ERRNO_READBACK") unless
    pointer[0, 4] == zero
  pointer[0, 4] = zero
  result = yield
  saved_error = Fiddle.last_error
  actual_after_wrapper = pointer[0, 4].unpack1("l<")
  capture_fail("NATIVE_ERRNO_CAPTURE") unless
    saved_error.is_a?(Integer) && actual_after_wrapper.is_a?(Integer)
  [result, saved_error]
end

def decode_native_stat(bytes)
  capture_fail("STAT_FRAME") unless bytes.bytesize == STAT_BYTES
  mode = bytes.byteslice(4, 2).unpack1("S<")
  type = case mode & S_IFMT
  when S_IFDIR then "DIRECTORY"
  when S_IFREG then "REGULAR"
  else "OTHER"
  end
  {
    "bytes" => bytes.byteslice(96, 8).unpack1("q<"),
    "device" => bytes.byteslice(0, 4).unpack1("l<"),
    "flags" => bytes.byteslice(116, 4).unpack1("L<"),
    "gid" => bytes.byteslice(20, 4).unpack1("L<"),
    "inode" => bytes.byteslice(8, 8).unpack1("Q<"),
    "mode" => format("%04o", mode & 0o7777),
    "nlink" => bytes.byteslice(6, 2).unpack1("S<"),
    "type" => type,
    "uid" => bytes.byteslice(16, 4).unpack1("L<"),
  }
end

def native_stat_at(directory_fd, leaf, label, flags: AT_SYMLINK_NOFOLLOW,
                   allow_absent: false)
  capture_fail("#{label}:LEAF") unless leaf.is_a?(String) &&
    !leaf.empty? && !leaf.include?("\0")
  buffer = Fiddle::Pointer.malloc(STAT_BYTES)
  buffer[0, STAT_BYTES] = "\0" * STAT_BYTES
  result, error = native_call do
    C2CaptureDarwin.fstatat(directory_fd, leaf, buffer, flags)
  end
  return decode_native_stat(buffer[0, STAT_BYTES]) if result == 0
  return nil if allow_absent && result == -1 && error == Errno::ENOENT::Errno
  capture_fail("#{label}:FSTATAT:#{result}:#{error}")
end

def native_stat_path(path, label)
  native_stat_at(
    AT_FDCWD, path, label, flags: AT_SYMLINK_NOFOLLOW_ANY
  )
end

def stat_matches_native?(stat, native)
  [stat.dev, stat.ino, stat.uid, stat.gid, stat.mode & 0o7777,
   stat.nlink, stat.size] ==
    [native.fetch("device"), native.fetch("inode"), native.fetch("uid"),
     native.fetch("gid"), native.fetch("mode").to_i(8),
     native.fetch("nlink"), native.fetch("bytes")]
end

def close_io(io)
  return nil if io.nil? || io.closed?
  io.close
  nil
rescue Errno::EINTR
  retry
rescue StandardError => error
  "#{error.class.name}:#{error.message}"
end

def close_io!(io, label)
  error = close_io(io)
  capture_fail("#{label}:#{error}") if error
  true
end

def write_all(io, bytes, label = "WRITE")
  offset = 0
  while offset < bytes.bytesize
    written = io.syswrite(bytes.byteslice(offset, bytes.bytesize - offset))
    capture_fail("#{label}:ZERO") unless written.positive?
    offset += written
  end
  offset
end

def held_bytes(io, label, cap: nil)
  before = io.stat
  capture_fail("#{label}:CAP") if cap && before.size > cap
  io.flush unless io.closed?
  io.rewind
  bytes = io.read
  after = io.stat
  capture_fail("#{label}:READ") unless bytes.bytesize == after.size
  capture_fail("#{label}:DRIFT") unless
    [before.dev, before.ino, before.uid, before.gid, before.mode,
     before.nlink, before.size] ==
      [after.dev, after.ino, after.uid, after.gid, after.mode,
       after.nlink, after.size]
  bytes
end

def sync_io(io, label)
  io.fsync
  result, error = native_call do
    C2CaptureDarwin.fcntl(io.fileno, F_FULLFSYNC)
  end
  capture_fail("#{label}:FULLFSYNC:#{result}:#{error}") unless result == 0
  {"F_FULLFSYNC" => true, "fsync" => true}
rescue StandardError => error
  raise if error.is_a?(C2PrefixCaptureFailure)
  capture_fail("#{label}:#{error.class.name}:#{error.message}")
end

def open_directory_path(path, label)
  flags = O_RDONLY | O_DIRECTORY | O_NOFOLLOW_ANY | O_CLOEXEC
  descriptor = IO.sysopen(path, flags)
  io = IO.new(descriptor)
  io.binmode
  capture_fail("#{label}:CLOEXEC") unless io.close_on_exec?
  io
rescue StandardError => error
  close_io(io) if defined?(io)
  raise if error.is_a?(C2PrefixCaptureFailure)
  capture_fail("#{label}:#{error.class.name}:#{error.message}")
end

def open_at(directory_fd, leaf, flags, label, mode = "r")
  capture_fail("#{label}:CREATING_OPENAT") unless
    (flags & File::CREAT).zero?
  result, error = native_call do
    C2CaptureDarwin.openat(directory_fd, leaf, flags)
  end
  capture_fail("#{label}:OPENAT:#{result}:#{error}") unless result >= 3
  io = IO.new(result, mode)
  io.binmode
  capture_fail("#{label}:CLOEXEC") unless io.close_on_exec?
  io
rescue StandardError => exception
  close_io(io) if defined?(io)
  raise if exception.is_a?(C2PrefixCaptureFailure)
  capture_fail("#{label}:#{exception.class.name}:#{exception.message}")
end

def rejoin_parent(parent_io, label)
  held = parent_io.stat
  named = File.lstat(CAPTURE_PARENT)
  native = native_stat_path(CAPTURE_PARENT, "#{label}:NATIVE")
  capture_fail("#{label}:TYPE") unless named.directory? &&
    native.fetch("type") == "DIRECTORY"
  capture_fail("#{label}:HELD_NATIVE") unless stat_matches_native?(held, native)
  capture_fail("#{label}:NAMED_HELD") unless
    [named.dev, named.ino, named.uid, named.gid, named.mode & 0o7777,
     named.nlink, named.size] ==
      [held.dev, held.ino, held.uid, held.gid, held.mode & 0o7777,
       held.nlink, held.size]
  expected = PARENT_EXPECTED
  observed = native.reject { |key, _| %w[bytes nlink type].include?(key) }
  capture_fail("#{label}:IDENTITY") unless observed == expected
  native
end

def rejoin_root(parent_io, root_io, label, mode: nil, nlink: nil)
  parent = rejoin_parent(parent_io, "#{label}:PARENT")
  held = root_io.stat
  relative = native_stat_at(
    parent_io.fileno, CAPTURE_ROOT_LEAF, "#{label}:RELATIVE"
  )
  named = File.lstat(CAPTURE_ROOT)
  capture_fail("#{label}:TYPE") unless named.directory? &&
    relative.fetch("type") == "DIRECTORY"
  capture_fail("#{label}:HELD_RELATIVE") unless
    stat_matches_native?(held, relative)
  capture_fail("#{label}:NAMED_HELD") unless
    [named.dev, named.ino, named.uid, named.gid, named.mode & 0o7777,
     named.nlink, named.size] ==
      [held.dev, held.ino, held.uid, held.gid, held.mode & 0o7777,
       held.nlink, held.size]
  capture_fail("#{label}:DEVICE") unless
    relative.fetch("device") == parent.fetch("device")
  capture_fail("#{label}:OWNER") unless
    [relative.fetch("uid"), relative.fetch("gid"),
     relative.fetch("flags")] == [501, 20, 0]
  capture_fail("#{label}:MODE") if mode && relative.fetch("mode") != mode
  capture_fail("#{label}:NLINK") if nlink && relative.fetch("nlink") != nlink
  relative
end

def rejoin_leaf(root_io, leaf, held_io, label)
  native = native_stat_at(root_io.fileno, leaf, "#{label}:RELATIVE")
  capture_fail("#{label}:TYPE") unless native.fetch("type") == "REGULAR"
  capture_fail("#{label}:HELD") unless stat_matches_native?(held_io.stat, native)
  native
end

def publish_leaf(state, parent_io, root_io, leaf, bytes)
  allowed = SUCCESS_INVENTORY + ["99-incomplete.json"]
  capture_fail("PUBLISH:LEAF:#{leaf}") unless allowed.include?(leaf)
  root_before = rejoin_root(parent_io, root_io, "PUBLISH:#{leaf}:BEFORE")
  capture_fail("PUBLISH:#{leaf}:FINAL_PRESENT") unless
    native_stat_at(
      root_io.fileno, leaf, "PUBLISH:#{leaf}:ABSENT", allow_absent: true
    ).nil?

  template_bytes = STAGING_TEMPLATE + "\0"
  template = Fiddle::Pointer.malloc(template_bytes.bytesize)
  template[0, template_bytes.bytesize] = template_bytes
  descriptor, error = native_call do
    C2CaptureDarwin.mkostempsat_np(
      root_io.fileno, template, 0, O_CLOEXEC
    )
  end
  capture_fail("PUBLISH:#{leaf}:MKOSTEMPSAT:#{descriptor}:#{error}") unless
    descriptor >= 3
  staging = template.to_s(STAGING_TEMPLATE.bytesize)
  capture_fail("PUBLISH:#{leaf}:STAGING_NAME") unless
    STAGING_PATTERN.match?(staging)
  state.fetch("active_staging") << staging
  io = IO.new(descriptor, "r+")
  io.binmode
  capture_fail("PUBLISH:#{leaf}:CLOEXEC") unless io.close_on_exec?
  rejoin_root(
    parent_io, root_io, "PUBLISH:#{leaf}:STAGED_ROOT",
    nlink: root_before.fetch("nlink") + 1
  )
  staged = rejoin_leaf(root_io, staging, io, "PUBLISH:#{leaf}:STAGED")
  capture_fail("PUBLISH:#{leaf}:STAGED_POLICY") unless
    [staged.fetch("device"), staged.fetch("uid"), staged.fetch("gid"),
     staged.fetch("mode"), staged.fetch("nlink"), staged.fetch("bytes"),
     staged.fetch("flags")] ==
      [root_before.fetch("device"), 501, 20, "0600", 1, 0, 0]

  write_all(io, bytes, "PUBLISH:#{leaf}:WRITE")
  capture_fail("PUBLISH:#{leaf}:READBACK") unless
    held_bytes(io, "PUBLISH:#{leaf}:READBACK") == bytes
  sync_io(io, "PUBLISH:#{leaf}:DATA")
  io.chmod(0o400)
  sync_io(io, "PUBLISH:#{leaf}:SEALED")
  sealed = rejoin_leaf(root_io, staging, io, "PUBLISH:#{leaf}:SEALED")
  capture_fail("PUBLISH:#{leaf}:SEALED_POLICY") unless
    [sealed.fetch("mode"), sealed.fetch("nlink"), sealed.fetch("bytes"),
     sealed.fetch("flags")] == ["0400", 1, bytes.bytesize, 0]

  result, rename_error = native_call do
    C2CaptureDarwin.renameatx_np(
      root_io.fileno, staging, root_io.fileno, leaf,
      RENAME_EXCL | RENAME_NOFOLLOW_ANY
    )
  end
  capture_fail("PUBLISH:#{leaf}:RENAME:#{result}:#{rename_error}") unless
    result == 0
  state.fetch("active_staging").delete(staging)
  capture_fail("PUBLISH:#{leaf}:STAGING_REMAINS") unless
    native_stat_at(
      root_io.fileno, staging, "PUBLISH:#{leaf}:STAGING_ABSENT",
      allow_absent: true
    ).nil?
  final = rejoin_leaf(root_io, leaf, io, "PUBLISH:#{leaf}:FINAL")
  capture_fail("PUBLISH:#{leaf}:VNODE") unless
    [final.fetch("device"), final.fetch("inode")] ==
      [sealed.fetch("device"), sealed.fetch("inode")]
  sync_io(root_io, "PUBLISH:#{leaf}:ROOT")

  reopened = open_at(
    root_io.fileno, leaf, O_RDONLY | O_NOFOLLOW_ANY | O_CLOEXEC,
    "PUBLISH:#{leaf}:REOPEN"
  )
  reopened_before = rejoin_leaf(
    root_io, leaf, reopened, "PUBLISH:#{leaf}:REOPEN"
  )
  reopened_bytes = held_bytes(
    reopened, "PUBLISH:#{leaf}:REOPEN_READ", cap: INCOMPLETE_LEAF_CAP
  )
  capture_fail("PUBLISH:#{leaf}:REOPEN_BYTES") unless reopened_bytes == bytes
  reopened_after = rejoin_leaf(
    root_io, leaf, reopened, "PUBLISH:#{leaf}:REOPEN_AFTER_READ"
  )
  capture_fail("PUBLISH:#{leaf}:REOPEN_JOIN_DRIFT") unless
    reopened_after == reopened_before
  close_io!(reopened, "PUBLISH:#{leaf}:REOPEN_CLOSE")
  close_io!(io, "PUBLISH:#{leaf}:HELD_CLOSE")
  rejoin_root(
    parent_io, root_io, "PUBLISH:#{leaf}:AFTER",
    nlink: root_before.fetch("nlink") + 1
  )
  reopened_after.merge("sha256" => Digest::SHA256.hexdigest(bytes))
rescue StandardError
  close_io(reopened) if defined?(reopened)
  close_io(io) if defined?(io)
  raise
end

def named_absent?(path)
  File.lstat(path)
  false
rescue Errno::ENOENT
  true
end

def create_root(parent_io, state)
  parent_before = rejoin_parent(parent_io, "ROOT_CREATE:BEFORE")
  capture_fail("ROOT_CREATE:NAMED_PRESENT") unless named_absent?(CAPTURE_ROOT)
  capture_fail("ROOT_CREATE:RELATIVE_PRESENT") unless
    native_stat_at(
      parent_io.fileno, CAPTURE_ROOT_LEAF, "ROOT_CREATE:ABSENT",
      allow_absent: true
    ).nil?
  result, error = native_call do
    C2CaptureDarwin.mkdirat(parent_io.fileno, CAPTURE_ROOT_LEAF, 0o700)
  end
  capture_fail("ROOT_CREATE:MKDIRAT:#{result}:#{error}") unless result == 0
  state["root_created"] = true
  root_io = open_at(
    parent_io.fileno, CAPTURE_ROOT_LEAF,
    O_RDONLY | O_DIRECTORY | O_NOFOLLOW_ANY | O_CLOEXEC,
    "ROOT_CREATE:OPEN"
  )
  root_io.chmod(0o700)
  root = rejoin_root(
    parent_io, root_io, "ROOT_CREATE:JOIN", mode: "0700", nlink: 2
  )
  capture_fail("ROOT_CREATE:POLICY") unless
    [root.fetch("type"), root.fetch("uid"), root.fetch("gid"),
     root.fetch("flags")] == ["DIRECTORY", 501, 20, 0]
  sync_io(root_io, "ROOT_CREATE:ROOT")
  sync_io(parent_io, "ROOT_CREATE:PARENT")
  parent_after = rejoin_parent(parent_io, "ROOT_CREATE:AFTER")
  capture_fail("ROOT_CREATE:PARENT_NLINK") unless
    parent_after.fetch("nlink") == parent_before.fetch("nlink") + 1
  [root_io, parent_before, parent_after, root]
rescue StandardError
  close_io(root_io) if defined?(root_io)
  raise
end

def stable_stat_signature(stat)
  [stat.dev, stat.ino, stat.uid, stat.gid, stat.mode & 0o7777,
   stat.nlink, stat.size]
end

def raw_directory_names(parent_io, root_io, label)
  held_before = root_io.stat
  joined_before = rejoin_root(parent_io, root_io, "#{label}:ROOT_BEFORE")
  descriptor, error = native_call do
    C2CaptureDarwin.openat(
      parent_io.fileno, CAPTURE_ROOT_LEAF,
      O_RDONLY | O_DIRECTORY | O_NOFOLLOW_ANY | O_CLOEXEC
    )
  end
  capture_fail("#{label}:OPENAT:#{descriptor}:#{error}") unless descriptor >= 3
  scan_io = IO.new(descriptor)
  capture_fail("#{label}:CLOEXEC") unless scan_io.close_on_exec?
  capture_fail("#{label}:SCAN_ROOT") unless
    stable_stat_signature(scan_io.stat) == stable_stat_signature(held_before)
  pointer, fdopendir_error = native_call do
    C2CaptureDarwin.fdopendir(descriptor)
  end
  if pointer.nil? || pointer.to_i.zero?
    close_io!(scan_io, "#{label}:FDOPENDIR_SOURCE_CLOSE")
    capture_fail("#{label}:FDOPENDIR:#{fdopendir_error}")
  end
  scan_io.autoclose = false
  directory_pointer = pointer
  directory_open = true
  names = []
  loop do
    entry_pointer, read_error = native_call do
      C2CaptureDarwin.readdir(directory_pointer)
    end
    if entry_pointer.nil? || entry_pointer.to_i.zero?
      capture_fail("#{label}:READDIR:#{read_error}") unless read_error.zero?
      break
    end
    record_length = entry_pointer[16, 2].unpack1("S<")
    name_length = entry_pointer[18, 2].unpack1("S<")
    minimum = (21 + name_length + 1 + 3) & ~3
    capture_fail("#{label}:DIRENT_SHAPE") unless
      name_length.between?(1, 1_023) && record_length <= 1_048 &&
        record_length >= minimum && (record_length % 4).zero?
    name = entry_pointer[21, name_length].b
    terminator = entry_pointer[21 + name_length, 1]
    capture_fail("#{label}:DIRENT_NAME") if
      terminator != "\0" || name.include?("\0") || name.include?("/")
    next if name == "." || name == ".."
    capture_fail("#{label}:DUPLICATE:#{name}") if names.include?(name)
    names << name
  end
  scan_after = scan_io.stat
  held_after = root_io.stat
  capture_fail("#{label}:SCAN_DRIFT") unless
    stable_stat_signature(scan_after) == stable_stat_signature(held_before) &&
      stable_stat_signature(held_after) == stable_stat_signature(held_before)
  close_result, close_error = native_call do
    C2CaptureDarwin.closedir(directory_pointer)
  end
  directory_open = false
  capture_fail("#{label}:CLOSEDIR:#{close_result}:#{close_error}") unless
    close_result == 0
  joined_after = rejoin_root(parent_io, root_io, "#{label}:ROOT_AFTER")
  capture_fail("#{label}:ROOT_JOIN_DRIFT") unless
    joined_before == joined_after
  names.sort
rescue StandardError => primary
  if defined?(directory_open) && directory_open
    close_result, close_error = native_call do
      C2CaptureDarwin.closedir(directory_pointer)
    end
    directory_open = false
    capture_fail("#{label}:RESCUE_CLOSEDIR:#{close_result}:#{close_error}") unless
      close_result == 0
  elsif defined?(scan_io) && scan_io && scan_io.autoclose?
    close_io(scan_io)
  end
  raise primary
end

def descriptor_inventory(parent_io, root_io, label, expected_names: nil)
  root_before = rejoin_root(parent_io, root_io, "#{label}:BEFORE")
  names = raw_directory_names(parent_io, root_io, "#{label}:SCAN")
  if expected_names
    capture_fail("#{label}:NAMES") unless names == expected_names
  else
    allowed = SUCCESS_INVENTORY + ["99-incomplete.json"]
    names.each do |name|
      capture_fail("#{label}:NAME:#{name}") unless
        allowed.include?(name) || STAGING_PATTERN.match?(name)
    end
  end
  capture_fail("#{label}:NLINK") unless
    root_before.fetch("nlink") == 2 + names.length

  entries = {}
  manifest = "".b
  inodes = []
  names.each do |name|
    io = open_at(
      root_io.fileno, name, O_RDONLY | O_NOFOLLOW_ANY | O_CLOEXEC,
      "#{label}:#{name}:OPEN"
    )
    native_before = rejoin_leaf(
      root_io, name, io, "#{label}:#{name}:JOIN_BEFORE_READ"
    )
    bytes = held_bytes(io, "#{label}:#{name}:READ", cap: INCOMPLETE_LEAF_CAP)
    capture_fail("#{label}:#{name}:EOF") unless io.read(1).nil?
    native_after = rejoin_leaf(
      root_io, name, io, "#{label}:#{name}:JOIN_AFTER_READ"
    )
    capture_fail("#{label}:#{name}:JOIN_DRIFT") unless
      native_after == native_before
    close_io!(io, "#{label}:#{name}:CLOSE")
    sha256 = Digest::SHA256.hexdigest(bytes)
    receipt = native_after.merge("sha256" => sha256)
    if expected_names
      capture_fail("#{label}:#{name}:POLICY") unless
        [receipt.fetch("type"), receipt.fetch("device"),
         receipt.fetch("uid"), receipt.fetch("gid"),
         receipt.fetch("mode"), receipt.fetch("nlink"),
         receipt.fetch("flags")] ==
          ["REGULAR", root_before.fetch("device"), 501, 20, "0400", 1, 0]
    end
    capture_fail("#{label}:#{name}:ROOT_INODE_REUSE") if
      receipt.fetch("inode") == root_before.fetch("inode")
    capture_fail("#{label}:#{name}:INODE_REUSE") if
      inodes.include?(receipt.fetch("inode"))
    inodes << receipt.fetch("inode")
    entries[name] = receipt
    manifest << [
      name, receipt.fetch("device"), receipt.fetch("inode"),
      receipt.fetch("mode"), receipt.fetch("nlink"),
      receipt.fetch("bytes"), receipt.fetch("sha256"),
    ].join("\t") << "\n"
  rescue StandardError
    close_io(io) if defined?(io)
    raise
  end
  root_after = rejoin_root(parent_io, root_io, "#{label}:AFTER")
  capture_fail("#{label}:ROOT_DRIFT") unless root_after == root_before
  {
    "entries" => entries,
    "manifest_sha256" => Digest::SHA256.hexdigest(manifest),
    "names" => names,
    "root" => root_after,
  }
end

def seal_root(parent_io, root_io, label, expected_names: nil)
  root_io.chmod(0o500)
  sync_io(root_io, "#{label}:ROOT")
  sync_io(parent_io, "#{label}:PARENT")
  rejoin_root(
    parent_io, root_io, "#{label}:PRE_SCAN", mode: "0500",
    nlink: expected_names ? 2 + expected_names.length : nil
  )
  inventory = descriptor_inventory(
    parent_io, root_io, "#{label}:INVENTORY",
    expected_names: expected_names
  )
  capture_fail("#{label}:NAMES") if
    expected_names && inventory.fetch("names") != expected_names
  root = rejoin_root(
    parent_io, root_io, "#{label}:FINAL", mode: "0500",
    nlink: 2 + inventory.fetch("names").length
  )
  inventory.merge("root" => root)
end

def revalidate_harness(io, label)
  before = io.stat
  io.rewind
  bytes = io.read
  after = io.stat
  named = File.lstat(HARNESS)
  observed = file_identity(
    after, sha256: Digest::SHA256.hexdigest(bytes)
  )
  capture_fail("#{label}:HELD_DRIFT") unless
    [before.dev, before.ino, before.mode, before.uid, before.gid,
     before.nlink, before.size] ==
      [after.dev, after.ino, after.mode, after.uid, after.gid,
       after.nlink, after.size]
  capture_fail("#{label}:NAMED_REJOIN") unless
    [named.dev, named.ino, named.mode, named.uid, named.gid,
     named.nlink, named.size] ==
      [after.dev, after.ino, after.mode, after.uid, after.gid,
       after.nlink, after.size]
  capture_fail("#{label}:IDENTITY") unless observed == HARNESS_EXPECTED
  observed
end

def drain_channel(io)
  digest = Digest::SHA256.new
  retained = "".b
  total = 0
  lines = 0
  overflow = false
  read_error = nil
  begin
    loop do
      chunk = io.readpartial(4_096)
      digest.update(chunk)
      total += chunk.bytesize
      lines += chunk.count("\n")
      remaining = CHANNEL_CAP - retained.bytesize
      retained << chunk.byteslice(0, remaining) if remaining.positive?
      overflow = true if total > CHANNEL_CAP
    end
  rescue EOFError
    nil
  rescue StandardError => error
    read_error = failure_diagnostic(error, phase: "CHANNEL_DRAIN")
  end
  close_error = close_io(io)
  {
    "bytes" => total,
    "capture_started" => true,
    "close_error" => close_error,
    "close_observed" => true,
    "eof_observed" => read_error.nil?,
    "lf_count" => lines,
    "observation_status" => read_error.nil? ?
      "COMPLETE_TO_EOF" : "PARTIAL_BEFORE_READ_ERROR",
    "overflow" => overflow,
    "read_error" => read_error,
    "retained" => retained,
    "retained_bytes" => retained.bytesize,
    "sha256" => digest.hexdigest,
  }
end

def exact_wait(pid)
  loop do
    waited_pid, status = Process.waitpid2(pid)
    capture_fail("WAIT_PID:#{waited_pid}:#{pid}") unless waited_pid == pid
    return [waited_pid, status]
  rescue Errno::EINTR
    next
  end
end

def child_status_receipt(pid, waited_pid, status)
  {
    "exited" => status.exited?,
    "exitstatus" => status.exited? ? status.exitstatus : nil,
    "pid" => pid,
    "signaled" => status.signaled?,
    "termsig" => status.signaled? ? status.termsig : nil,
    "waited_pid" => waited_pid,
  }
end

def require_hash_equal(actual, expected, code)
  capture_fail(code) unless actual == expected
end

def admit_harness_receipt(stdout, stderr, status, spawned_pid, runner_pid)
  return [false, "CHILD_NOT_EXIT_ZERO", nil] unless
    status.exited? && status.exitstatus == 0
  return [false, "STDERR_NOT_EMPTY", nil] unless stderr.empty?
  return [false, "STDOUT_FRAME", nil] unless
    stdout.end_with?("\n") && stdout.count("\n") == 1
  parsed = JSON.parse(stdout)
  return [false, "STDOUT_NOT_OBJECT", parsed] unless parsed.is_a?(Hash)
  return [false, "STDOUT_NOT_CANONICAL", parsed] unless
    canonical_json(parsed) + "\n" == stdout
  return [false, "TOP_LEVEL_KEYS", parsed] unless
    parsed.keys.sort == HARNESS_TOP_LEVEL_KEYS
  return [false, "STATUS", parsed] unless
    parsed["status"] == "PASS_EXACT_NONCONSUMING_C2_PREFIX_PREFLIGHT_V4"
  return [false, "BOTTOM", parsed] unless
    parsed["bottom_entry_evaluated"] == false
  return [false, "OPERATION_SCOPE", parsed] unless
    parsed["operation_scope"] == "THIS_EXACT_HARNESS_PROCESS_ONLY" &&
      parsed["historical_operations_reinterpreted"] == false
  return [false, "OPERATIONS", parsed] unless
    parsed["operations"] == HARNESS_OPERATIONS_EXPECTED
  return [false, "CONTROLLER_SOURCE", parsed] unless
    parsed["controller_source"] == CONTROLLER_EXPECTED
  return [false, "PREFIX", parsed] unless parsed["prefix"] == PREFIX_EXPECTED
  return [false, "FROZEN_ROOTS", parsed] unless
    parsed["frozen_roots_after"] == FROZEN_ROOTS_EXPECTED
  return [false, "POLICY", parsed] unless
    parsed["language_and_fd_policy"] == HARNESS_POLICY_EXPECTED
  continuity = parsed["continuity"]
  return [false, "CONTINUITY", parsed] unless
    continuity.is_a?(Hash) && continuity["armed"] == false &&
      continuity["events"] == 0 && continuity["poisoned"] == false &&
      continuity["nodes"].is_a?(Integer) && continuity["nodes"].positive?
  return [false, "DESCRIPTOR_CLOSE", parsed] unless
    parsed["descriptor_close_count"] == continuity["nodes"] + 2
  dot_build = parsed["dot_build"]
  return [false, "DOT_BUILD_SHAPE", parsed] unless dot_build.is_a?(Hash)
  DOT_BUILD_EXPECTED.each do |key, value|
    return [false, "DOT_BUILD:#{key}", parsed] unless
      dot_build[key] == value
  end
  return [false, "DOT_BUILD_MANIFEST", parsed] unless
    dot_build["manifest_sha256"].is_a?(String) &&
      dot_build["manifest_sha256"].match?(/\A[0-9a-f]{64}\z/)
  return [false, "MAPPED_RUBY", parsed] unless
    parsed["mapped_ruby"] == RUBY_MAPPING_EXPECTED
  controller = parsed["controller"]
  controller_keys = %w[
    comm_hex credentials idversion orig_ppidversion pgid pid ppid
    puniqueid sid status uniqueid uuid_hex
  ].sort
  process_epoch_fields_valid =
    %w[idversion orig_ppidversion pgid puniqueid sid uniqueid].all? do |key|
      controller.is_a?(Hash) && controller[key].is_a?(Integer) &&
        controller[key].positive?
    end
  return [false, "CONTROLLER_RECEIPT", parsed] unless
    controller.is_a?(Hash) && controller.keys.sort == controller_keys &&
      controller["pid"] == spawned_pid && controller["ppid"] == runner_pid &&
      controller["credentials"] == [501, 20, 501, 20, 501, 20] &&
      controller["uuid_hex"] == RUBY_MAPPING_EXPECTED.fetch("uuid_hex") &&
      process_epoch_fields_valid
  tmp = parsed["tmp"]
  return [false, "TMP", parsed] unless
    tmp.is_a?(Hash) && tmp["type"] == "DIRECTORY" &&
      tmp["mode"] == "1777" && tmp["uid"] == 0 && tmp["gid"] == 0
  [true, "PASS", parsed]
rescue JSON::ParserError
  [false, "STDOUT_JSON_PARSE", nil]
end

def failure_diagnostic(error, phase: nil)
  bytes = error.message.b
  prefix = bytes.byteslice(0, 1_024)
  result = {
    "error_class" => error.class.name,
    "error_message_bytes" => bytes.bytesize,
    "error_message_prefix_hex" => prefix.unpack1("H*"),
    "error_message_prefix_truncated" => prefix.bytesize != bytes.bytesize,
    "error_message_sha256" => Digest::SHA256.hexdigest(bytes),
  }
  result["phase"] = phase if phase
  result
end

def canonical_frame(value, cap, label)
  bytes = canonical_json(value) + "\n"
  capture_fail("#{label}:CAP:#{bytes.bytesize}") if bytes.bytesize > cap
  bytes
end

def channel_receipt(capture)
  return nil unless capture
  capture.reject { |key, _| key == "retained" }
end

def unavailable_channel_receipt(capture_started:, error: nil)
  {
    "bytes" => nil,
    "capture_started" => capture_started,
    "close_error" => nil,
    "close_observed" => false,
    "eof_observed" => false,
    "lf_count" => nil,
    "observation_status" => capture_started ?
      "DRAIN_RESULT_UNAVAILABLE" : "CAPTURE_NOT_STARTED",
    "overflow" => nil,
    "read_error" => error,
    "retained_bytes" => nil,
    "sha256" => nil,
  }
end

def publication_state(state, leaf)
  if state.fetch("durable_leaves").key?(leaf)
    {
      "attempted" => true,
      "durable" => true,
      "leaf" => state.fetch("durable_leaves").fetch(leaf),
    }
  elsif state.fetch("publication_attempts").include?(leaf)
    {
      "attempted" => true,
      "durable" => false,
      "error" => state.fetch("publication_errors")[leaf],
    }
  else
    {"attempted" => false, "durable" => false}
  end
end

def attach_raw_publication_state(state)
  {"stdout" => "01-stdout.bin", "stderr" => "02-stderr.bin"}.each do |channel, leaf|
    state.fetch("channels").fetch(channel)["publication"] =
      publication_state(state, leaf)
  end
end

def fixed_leaf_states(state)
  (SUCCESS_INVENTORY + ["99-incomplete.json"]).each_with_object({}) do |leaf, result|
    result[leaf] = publication_state(state, leaf)
  end
end

def attempt_publication(state, parent_io, root_io, leaf, bytes)
  return if state.fetch("publication_attempts").include?(leaf)
  state.fetch("publication_attempts") << leaf
  state.fetch("durable_leaves")[leaf] =
    publish_leaf(state, parent_io, root_io, leaf, bytes)
rescue StandardError => error
  state.fetch("publication_errors")[leaf] =
    failure_diagnostic(error, phase: state.fetch("phase"))
end

def require_parent_nlink(parent_io, expected, label)
  observed = rejoin_parent(parent_io, label)
  capture_fail("#{label}:NLINK:#{observed.fetch('nlink')}:#{expected}") unless
    observed.fetch("nlink") == expected
  observed
end

def outer_failure_record(error_receipt, root_state)
  {
    "capture_root" => CAPTURE_ROOT,
    "consumption" => "CONSUMED_NO_RETRY",
    "error" => error_receipt,
    "root_state" => root_state,
    "runner_status" => "FAIL_CAPTURE_RUNNER_CONSUMED_NO_RETRY",
    "schema" => "ergentics-r19-obs11-c2-prefix-capture-outer-failure-v6",
  }
end

def known_outer_root_state(state, observed)
  return observed if observed
  return state.fetch("terminal_root_state") if state["terminal_root_state"]
  return nil unless state.fetch("root_created")
  {
    "root_created_by_successful_mkdirat" => true,
    "root_descriptor_observation" => nil,
    "root_recovery_error" => state["root_recovery_error"],
    "status" => "CREATED_ROOT_CURRENT_DESCRIPTOR_JOIN_UNAVAILABLE",
  }
end

def intended_outer_receipt(bytes, channel, exit_status)
  {
    "bytes" => bytes.bytesize,
    "channel" => channel,
    "exit" => exit_status,
    "lf_count" => bytes.count("\n"),
    "sha256" => Digest::SHA256.hexdigest(bytes),
  }
end

def transport_close_errors(exec_io, stdout_w, stderr_w)
  errors = {}
  [["fd3_parent", exec_io], ["stdout_writer", stdout_w],
   ["stderr_writer", stderr_w]].each do |label, io|
    error = close_io(io)
    errors[label] = error if error
  end
  errors
end

state = {
  "active_staging" => [],
  "admission" => nil,
  "channels" => {
    "stderr" => unavailable_channel_receipt(capture_started: false),
    "stdout" => unavailable_channel_receipt(capture_started: false),
  },
  "child" => nil,
  "durable_leaves" => {},
  "phase" => "RUNNER_ENTERED",
  "publication_attempts" => [],
  "publication_errors" => {},
  "root_created" => false,
  "terminal_root_state" => nil,
  "transport_close_errors" => {},
}
harness_io = nil
exec_harness_io = nil
parent_io = nil
root_io = nil
stdout_r = nil
stdout_w = nil
stderr_r = nil
stderr_w = nil
stdout_thread = nil
stderr_thread = nil
stdout_capture = nil
stderr_capture = nil
pid = nil
waited_pid = nil
wait_status = nil
child_spawn_call_entries = 0
incoming_umask = nil

begin
  capture_fail("ARGV") unless ARGV.empty?
  capture_fail("ENVIRONMENT") unless ENV.to_h == EXPECTED_ENVIRONMENT
  capture_fail("CWD") unless Dir.pwd == "/private/var/empty"
  capture_fail("RUBY") unless
    [RUBY_VERSION, RUBY_PATCHLEVEL, RUBY_PLATFORM] ==
      ["2.6.10", 210, "universal.arm64e-darwin25"]
  capture_fail("ABI") unless
    Fiddle::SIZEOF_INT == 4 && Fiddle::SIZEOF_VOIDP == 8 &&
      [1].pack("L").bytes == [1, 0, 0, 0]
  capture_fail("UID") unless Process.uid == 501 && Process.euid == 501
  capture_fail("GID") unless Process.gid == 20 && Process.egid == 20
  capture_fail("GROUPS") unless Process.groups.sort == EXPECTED_GROUPS
  incoming_umask = File.umask(0o077)
  capture_fail("PARENT_REALPATH") unless
    File.realpath(CAPTURE_PARENT) == CAPTURE_PARENT
  parent_io = open_directory_path(CAPTURE_PARENT, "PARENT_OPEN")
  rejoin_parent(parent_io, "PARENT_ADMISSION")

  state["phase"] = "ROOT_CREATION"
  root_io, _parent_before, parent_after, root_initial =
    create_root(parent_io, state)
  state["parent_nlink"] = parent_after.fetch("nlink")
  state["root_initial"] = root_initial

  state["phase"] = "START_PUBLICATION"
  start = {
    "capture_root" => CAPTURE_ROOT,
    "consumption" => "CONSUMED_NO_RETRY_AT_TRUSTED_OUTER_LAUNCH_ATTEMPT",
    "controller_sha256" => CONTROLLER_EXPECTED.fetch("sha256"),
    "correction_freeze_commit" =>
      "f3e073ee13e93623d5b4f3e77b677afc584c1154",
    "correction_freeze_tree" =>
      "805376d885d84d08d6197692a1ed1a386a03e563",
    "fd3_reason" => "CONTROLLED_HELD_HARNESS_SOURCE_TRANSPORT",
    "harness_sha256" => HARNESS_EXPECTED.fetch("sha256"),
    "incoming_umask" => format("%04o", incoming_umask),
    "parent" => parent_after,
    "root" => root_initial,
    "runner_pid" => Process.pid,
    "runner_ppid" => Process.ppid,
    "runner_source_identity" => "EXTERNAL_FINAL_READINESS_BINDING",
    "schema" => "ergentics-r19-obs11-c2-prefix-capture-start-v6",
    "status" => "START_DURABLE_BEFORE_HARNESS_ADMISSION_OR_CHILD_SPAWN",
  }
  attempt_publication(
    state, parent_io, root_io, "00-start.json",
    canonical_frame(start, INCOMPLETE_LEAF_CAP, "START")
  )
  capture_fail("START_NOT_DURABLE") unless
    state.fetch("durable_leaves").key?("00-start.json")
  require_parent_nlink(parent_io, state.fetch("parent_nlink"), "START:PARENT")

  state["phase"] = "HARNESS_ADMISSION"
  harness_io = File.open(HARNESS, "rb")
  harness_io.close_on_exec = true
  revalidate_harness(harness_io, "HARNESS_PRIMARY")
  exec_harness_io = File.open(HARNESS, "rb")
  exec_harness_io.close_on_exec = true
  revalidate_harness(exec_harness_io, "HARNESS_EXEC")
  capture_fail("HARNESS_EXEC_FD3_COLLISION") if exec_harness_io.fileno == 3
  exec_harness_io.rewind
  capture_fail("HARNESS_EXEC_OFFSET") unless exec_harness_io.pos.zero?

  state["phase"] = "CHILD_ENTRY"
  stdout_r, stdout_w = IO.pipe
  stderr_r, stderr_w = IO.pipe
  stdout_thread = Thread.new { drain_channel(stdout_r) }
  stderr_thread = Thread.new { drain_channel(stderr_r) }
  child_spawn_call_entries += 1
  pid = Process.spawn(
    CHILD_ENVIRONMENT,
    ["/usr/bin/ruby", "ruby"],
    "--disable-gems", "/dev/fd/3",
    chdir: "/private/var/empty",
    in: $stdin,
    out: stdout_w,
    err: stderr_w,
    3 => exec_harness_io,
    close_others: true,
    unsetenv_others: true
  )
  state["transport_close_errors"] =
    transport_close_errors(exec_harness_io, stdout_w, stderr_w)
  exec_harness_io = nil
  stdout_w = nil
  stderr_w = nil

  waited_pid, wait_status = exact_wait(pid)
  stdout_capture = stdout_thread.value
  stderr_capture = stderr_thread.value
  state["channels"] = {
    "stderr" => channel_receipt(stderr_capture) ||
      unavailable_channel_receipt(
        capture_started: !stderr_thread.nil?,
        error: state["stderr_thread_error"]
      ),
    "stdout" => channel_receipt(stdout_capture) ||
      unavailable_channel_receipt(
        capture_started: !stdout_thread.nil?,
        error: state["stdout_thread_error"]
      ),
  }
  state["child"] = child_status_receipt(pid, waited_pid, wait_status)

  state["phase"] = "RAW_PUBLICATION"
  attempt_publication(
    state, parent_io, root_io, "01-stdout.bin",
    stdout_capture.fetch("retained")
  )
  attempt_publication(
    state, parent_io, root_io, "02-stderr.bin",
    stderr_capture.fetch("retained")
  )
  attach_raw_publication_state(state)
  capture_fail("RAW_PUBLICATION_INCOMPLETE") unless
    %w[01-stdout.bin 02-stderr.bin].all? do |leaf|
      state.fetch("durable_leaves").key?(leaf)
    end
  capture_fail("TRANSPORT_CLOSE") unless
    state.fetch("transport_close_errors").empty?
  capture_fail("DRAIN_CLOSE") unless
    [stdout_capture, stderr_capture].all? do |capture|
      capture.fetch("close_error").nil?
    end
  capture_fail("DRAIN_READ") unless
    [stdout_capture, stderr_capture].all? do |capture|
      capture.fetch("read_error").nil?
    end

  state["phase"] = "POSTREAP_REVALIDATION"
  revalidate_harness(harness_io, "HARNESS_POSTREAP_RAW_DURABLE")
  capture_complete =
    !stdout_capture.fetch("overflow") && !stderr_capture.fetch("overflow") &&
      stdout_capture.fetch("retained_bytes") == stdout_capture.fetch("bytes") &&
      stderr_capture.fetch("retained_bytes") == stderr_capture.fetch("bytes")
  state["phase"] = "RECEIPT_ADMISSION"
  admitted, admission_code, parsed = if capture_complete
    admit_harness_receipt(
      stdout_capture.fetch("retained"), stderr_capture.fetch("retained"),
      wait_status, pid, Process.pid
    )
  else
    [false, "CHANNEL_OVERFLOW_OR_TRUNCATION", nil]
  end
  state["admission"] = {
    "code" => admission_code,
    "pass" => admitted,
    "receipt_sha256" => parsed ?
      Digest::SHA256.hexdigest(canonical_json(parsed) + "\n") : nil,
  }
  result = {
    "admission" => state.fetch("admission"),
    "capture_complete" => capture_complete,
    "capture_root" => CAPTURE_ROOT,
    "channels" => state.fetch("channels"),
    "child" => state.fetch("child"),
    "child_spawn_call_entries" => child_spawn_call_entries,
    "consumption" => "CONSUMED_NO_RETRY",
    "controller_bottom_entries" => 0,
    "prefix_harness_entries" => 1,
    "python_entries" => 0,
    "raw_leaves" => {
      "stderr" => state.fetch("durable_leaves").fetch("02-stderr.bin"),
      "stdout" => state.fetch("durable_leaves").fetch("01-stdout.bin"),
    },
    "schema" => "ergentics-r19-obs11-c2-prefix-capture-result-v6",
    "signals" => 0,
    "start_leaf" => state.fetch("durable_leaves").fetch("00-start.json"),
    "status" => admitted ?
      "PASS_CAPTURED_EXACT_NONCONSUMING_PREFIX_V6" :
      "FAIL_CAPTURED_PREFIX_V6_CONSUMED_NO_RETRY",
  }
  state["phase"] = "RESULT_PUBLICATION"
  attempt_publication(
    state, parent_io, root_io, "03-result.json",
    canonical_frame(result, INCOMPLETE_LEAF_CAP, "RESULT")
  )
  capture_fail("RESULT_NOT_DURABLE") unless
    state.fetch("durable_leaves").key?("03-result.json")
  require_parent_nlink(parent_io, state.fetch("parent_nlink"), "RESULT:PARENT")

  unless admitted
    state["phase"] = "CAPTURED_SCIENTIFIC_FAILURE_TERMINAL"
    failure_names = SUCCESS_INVENTORY.first(4)
    terminal = seal_root(
      parent_io, root_io, "SCIENTIFIC_FAILURE", expected_names: failure_names
    )
    state["terminal_root_state"] = terminal
    diagnostic = failure_diagnostic(
      C2PrefixCaptureFailure.new("SCIENTIFIC:#{admission_code}"),
      phase: state.fetch("phase")
    )
    outer = outer_failure_record(diagnostic, terminal)
    outer_bytes = canonical_frame(outer, OUTER_SUMMARY_CAP, "OUTER_FAILURE")
    close_io!(harness_io, "SCIENTIFIC_FAILURE:HARNESS_CLOSE")
    harness_io = nil
    close_io!(root_io, "SCIENTIFIC_FAILURE:ROOT_CLOSE")
    root_io = nil
    close_io!(parent_io, "SCIENTIFIC_FAILURE:PARENT_CLOSE")
    parent_io = nil
    write_all(STDERR, outer_bytes, "OUTER_FAILURE_WRITE")
    exit(70)
  end

  state["phase"] = "PASS_CLOSURE"
  revalidate_harness(harness_io, "HARNESS_FINAL")
  preclosure = descriptor_inventory(
    parent_io, root_io, "PRECLOSURE", expected_names: SUCCESS_INVENTORY.first(4)
  )
  closure = {
    "admission" => state.fetch("admission"),
    "channels" => state.fetch("channels"),
    "child" => state.fetch("child"),
    "consumption" => "CONSUMED_NO_RETRY",
    "expected_terminal" => {
      "inventory" => SUCCESS_INVENTORY,
      "root_flags" => 0,
      "root_mode" => "0500",
      "root_nlink" => 7,
    },
    "leaves_00_through_03" => preclosure.fetch("entries"),
    "preclosure_manifest_sha256" =>
      preclosure.fetch("manifest_sha256"),
    "preclosure_root" => preclosure.fetch("root"),
    "schema" => "ergentics-r19-obs11-c2-prefix-capture-closure-v6",
    "status" => "PASS_CLOSURE_FOR_EXACT_NONCONSUMING_PREFIX_V6",
  }
  attempt_publication(
    state, parent_io, root_io, "04-closure.json",
    canonical_frame(closure, INCOMPLETE_LEAF_CAP, "CLOSURE")
  )
  capture_fail("CLOSURE_NOT_DURABLE") unless
    state.fetch("durable_leaves").key?("04-closure.json")
  preseal = descriptor_inventory(
    parent_io, root_io, "PRESEAL", expected_names: SUCCESS_INVENTORY
  )
  state["phase"] = "PASS_TERMINAL"
  terminal = seal_root(
    parent_io, root_io, "PASS_TERMINAL", expected_names: SUCCESS_INVENTORY
  )
  state["terminal_root_state"] = terminal
  capture_fail("TERMINAL_MANIFEST_DRIFT") unless
    terminal.fetch("manifest_sha256") ==
      preseal.fetch("manifest_sha256")
  require_parent_nlink(
    parent_io, state.fetch("parent_nlink"), "PASS_TERMINAL:PARENT"
  )
  summary = {
    "capture_root" => CAPTURE_ROOT,
    "closure_leaf" => terminal.fetch("entries").fetch("04-closure.json"),
    "final_inventory" => terminal.fetch("names"),
    "final_inventory_manifest_sha256" =>
      terminal.fetch("manifest_sha256"),
    "final_root" => terminal.fetch("root"),
    "runner_status" => "PASS_DURABLE_CAPTURE_RUNNER_COMPLETED",
    "schema" => "ergentics-r19-obs11-c2-prefix-capture-outer-summary-v6",
    "scientific_status" => "PASS_CAPTURED_EXACT_NONCONSUMING_PREFIX_V6",
  }
  summary_bytes = canonical_frame(summary, OUTER_SUMMARY_CAP, "OUTER_PASS")
  close_io!(harness_io, "PASS:HARNESS_CLOSE")
  harness_io = nil
  close_io!(root_io, "PASS:ROOT_CLOSE")
  root_io = nil
  close_io!(parent_io, "PASS:PARENT_CLOSE")
  parent_io = nil
  write_all(STDOUT, summary_bytes, "OUTER_PASS_WRITE")
  exit(0)
rescue StandardError => primary_error
  state["phase_at_failure"] = state.fetch("phase")
  state["phase"] = "INCOMPLETE_CONTAINMENT"

  if root_io.nil? && state.fetch("root_created") && parent_io &&
      !parent_io.closed?
    begin
      root_io = open_at(
        parent_io.fileno, CAPTURE_ROOT_LEAF,
        O_RDONLY | O_DIRECTORY | O_NOFOLLOW_ANY | O_CLOEXEC,
        "INCOMPLETE_ROOT_RECOVERY_OPEN"
      )
      rejoin_root(parent_io, root_io, "INCOMPLETE_ROOT_RECOVERY_JOIN")
    rescue StandardError => recovery_error
      state["root_recovery_error"] = failure_diagnostic(
        recovery_error, phase: "INCOMPLETE_ROOT_RECOVERY"
      )
      root_io = nil
    end
  end

  close_errors = transport_close_errors(exec_harness_io, stdout_w, stderr_w)
  state.fetch("transport_close_errors").merge!(close_errors)
  exec_harness_io = nil
  stdout_w = nil
  stderr_w = nil

  if pid && waited_pid.nil?
    begin
      waited_pid, wait_status = exact_wait(pid)
    rescue StandardError => wait_error
      state["wait_error"] = failure_diagnostic(
        wait_error, phase: "INCOMPLETE_EXACT_REAP"
      )
    end
  end
  if stdout_thread && stdout_capture.nil?
    begin
      stdout_capture = stdout_thread.value
    rescue StandardError => thread_error
      state["stdout_thread_error"] = failure_diagnostic(
        thread_error, phase: "INCOMPLETE_STDOUT_DRAIN"
      )
    end
  end
  if stderr_thread && stderr_capture.nil?
    begin
      stderr_capture = stderr_thread.value
    rescue StandardError => thread_error
      state["stderr_thread_error"] = failure_diagnostic(
        thread_error, phase: "INCOMPLETE_STDERR_DRAIN"
      )
    end
  end
  state["channels"] = {
    "stderr" => channel_receipt(stderr_capture) ||
      unavailable_channel_receipt(
        capture_started: !stderr_thread.nil?,
        error: state["stderr_thread_error"]
      ),
    "stdout" => channel_receipt(stdout_capture) ||
      unavailable_channel_receipt(
        capture_started: !stdout_thread.nil?,
        error: state["stdout_thread_error"]
      ),
  }
  state["child"] = if pid && waited_pid && wait_status
    child_status_receipt(pid, waited_pid, wait_status)
  else
    {
      "exact_reap" => false,
      "pid" => pid,
      "wait_error" => state["wait_error"],
      "waited_pid" => waited_pid,
    }
  end

  if root_io && stdout_capture
    attempt_publication(
      state, parent_io, root_io, "01-stdout.bin",
      stdout_capture.fetch("retained")
    )
  end
  if root_io && stderr_capture
    attempt_publication(
      state, parent_io, root_io, "02-stderr.bin",
      stderr_capture.fetch("retained")
    )
  end
  attach_raw_publication_state(state)

  diagnostic = failure_diagnostic(
    primary_error, phase: state.fetch("phase_at_failure")
  )
  pre99 = nil
  if root_io
    begin
      pre99 = descriptor_inventory(parent_io, root_io, "INCOMPLETE_PRE99")
    rescue StandardError => scan_error
      pre99 = {
        "scan_error" => failure_diagnostic(
          scan_error, phase: "INCOMPLETE_PRE99_SCAN"
        ),
      }
    end
  end
  outer = outer_failure_record(
    diagnostic, known_outer_root_state(state, pre99)
  )
  outer_bytes = canonical_frame(outer, OUTER_SUMMARY_CAP, "OUTER_INCOMPLETE")
  intended_outer = intended_outer_receipt(outer_bytes, "STDERR", 70)

  root_writable = begin
    root_io && !root_io.closed? && mode_string(root_io.stat) == "0700"
  rescue StandardError
    false
  end
  if root_writable
    incomplete = {
      "capture_root" => CAPTURE_ROOT,
      "channels" => state.fetch("channels"),
      "child" => state.fetch("child"),
      "consumption" => "CONSUMED_NO_RETRY",
      "durable_leaves" => {
        "fixed_leaf_states_at_99_construction" => fixed_leaf_states(state),
        "identities" => state.fetch("durable_leaves"),
        "publication_errors" => state.fetch("publication_errors"),
        "transport_close_errors" =>
          state.fetch("transport_close_errors"),
      },
      "failure" => diagnostic,
      "generated_staging_names" => state.fetch("active_staging").sort,
      "intended_outer" => intended_outer,
      "inventory" => pre99,
      "root" => {
        "mode_before_99" => mode_string(root_io.stat),
        "observed_pre99" => pre99 && pre99["root"],
        "seal_attempted_at_99_construction" => false,
        "seal_state_at_99_construction" =>
          "PENDING_AFTER_NON_SELF_HASHING_99_PUBLICATION",
        "sync_and_rejoin_required_after_99" => true,
      },
      "schema" => "ergentics-r19-obs11-c2-prefix-capture-incomplete-v6",
      "status" => "CONSUMED_INCOMPLETE_NO_RETRY",
    }
    attempt_publication(
      state, parent_io, root_io, "99-incomplete.json",
      canonical_frame(incomplete, INCOMPLETE_LEAF_CAP, "INCOMPLETE")
    )
    begin
      state["incomplete_terminal"] = seal_root(
        parent_io, root_io, "INCOMPLETE_TERMINAL"
      )
    rescue StandardError => terminal_error
      state["incomplete_terminal_error"] = failure_diagnostic(
        terminal_error, phase: "INCOMPLETE_TERMINAL"
      )
    end
  end

  [harness_io, root_io, parent_io].each { |io| close_io(io) }
  begin
    write_all(STDERR, outer_bytes, "OUTER_INCOMPLETE_WRITE")
  rescue StandardError
    nil
  end
  exit(70)
ensure
  close_io(exec_harness_io)
  close_io(stdout_w)
  close_io(stderr_w)
  close_io(stdout_r) unless stdout_thread
  close_io(stderr_r) unless stderr_thread
  close_io(harness_io)
  close_io(root_io)
  close_io(parent_io)
end
