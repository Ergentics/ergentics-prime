#!/usr/bin/ruby

# Retired 2026-09-20: this frozen helper has unbounded process, pipe,
# or recovery waits. Reject before bootstrap intake, file access, or signals.
# Original Git blob: 6fd46406f4a37f9dd62a703e80ef6857578941e9.
# Existing live instances and historical copies are unaffected.
begin
  STDERR.write_nonblock(
    "{\"schema\":\"prime-v2-historical-helper-retirement/v1\"," \
    "\"helper\":\"ergentics-r19-obs11-c2-prefix-capture-runner.v9.rb\"," \
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
CAPTURE_ROOT_LEAF = "r19-obs11-c2-preconsumption-prefix-capture.v9"
CAPTURE_ROOT = "#{CAPTURE_PARENT}/#{CAPTURE_ROOT_LEAF}"
HARNESS =
  "#{REPOSITORY}/docs/tools/" \
  "ergentics-r19-obs11-c2-preconsumption-prefix-harness.v4.rb"
CHILD_ENVIRONMENT = EXPECTED_ENVIRONMENT
CHANNEL_CAP = 65_536
OUTER_SUMMARY_CAP = 16_384
INCOMPLETE_LEAF_CAP = 262_144
OUTER_NATIVE_COMPONENT_CAP = 6_656
OUTER_PUBLICATION_COMPONENT_CAP = 2_688
OUTER_BUNDLE_COMPONENT_CAP = 3_584
OUTER_TERMINAL_COMPONENT_CAP = 960
OUTER_ERROR_CONTAINMENT_COMPONENT_CAP = 1_472
OUTER_EVIDENCE_WRAPPER_MAX = 128
OUTER_FAILURE_FIXED_OVERHEAD_MAX = 896
OUTER_PASS_FIXED_OVERHEAD_MAX = 2_368
OUTER_FAILURE_ADDITIVE_MAX =
  OUTER_NATIVE_COMPONENT_CAP + OUTER_PUBLICATION_COMPONENT_CAP +
  OUTER_BUNDLE_COMPONENT_CAP + OUTER_TERMINAL_COMPONENT_CAP +
  OUTER_ERROR_CONTAINMENT_COMPONENT_CAP + OUTER_EVIDENCE_WRAPPER_MAX +
  OUTER_FAILURE_FIXED_OVERHEAD_MAX
OUTER_PASS_ADDITIVE_MAX =
  OUTER_NATIVE_COMPONENT_CAP + OUTER_PUBLICATION_COMPONENT_CAP +
  OUTER_BUNDLE_COMPONENT_CAP + OUTER_TERMINAL_COMPONENT_CAP +
  OUTER_EVIDENCE_WRAPPER_MAX + OUTER_PASS_FIXED_OVERHEAD_MAX
LIVE_FREEZE_COMMIT = "c91859792277df5581fc3f9ee754d3774ee5289e"
LIVE_FREEZE_TREE = "c3302539ac2403d043a82bac3e2bcd93d433cd7a"
LIVE_FREEZE_SHA256 =
  "b6b52b5af55c5997c43e2186771ccefd844b28ccca8a1ba4b776d9943632a3c2"
STATIC_BUNDLE_RESULT_SHA256 =
  "ebaf82a0d4b08cbf6d6d15331e13246ec01942fde2e881c965eb3fe9746d0bda"
STATIC_BUNDLE_OUTER_SHA256 =
  "617d9a7be5f75d717a5bde89c6b8086078dd472925fc267a1d82c212107a7e94"

BUILD_A_PARENT = "/private/tmp"
BUILD_A_ROOT_LEAF =
  "ergentics-r19-obs11-c2-fchmod-bundle-v9-build-a-79e4211-00e9242e"
BUILD_A_ROOT = "#{BUILD_A_PARENT}/#{BUILD_A_ROOT_LEAF}"
BUILD_A_OBJECT_LEAF = "ergentics-r19-obs11-c2-fchmod-v7.o"
BUILD_A_BUNDLE_LEAF = "libergentics-r19-obs11-c2-fchmod-v7.bundle"
BUILD_A_OBJECT = "#{BUILD_A_ROOT}/#{BUILD_A_OBJECT_LEAF}"
BUILD_A_BUNDLE = "#{BUILD_A_ROOT}/#{BUILD_A_BUNDLE_LEAF}"
BUILD_A_NAMES = [BUILD_A_OBJECT_LEAF, BUILD_A_BUNDLE_LEAF].sort.freeze
NATIVE_SYMBOL = "ergentics_r19_obs11_c2_v7_fchmod"
DARWIN_RTLD_NOW = 0x2
DARWIN_RTLD_LOCAL = 0x4
DARWIN_RTLD_MODE = DARWIN_RTLD_NOW | DARWIN_RTLD_LOCAL
PROC_PIDREGIONPATHINFO = 8
PROC_REGION_PATH_INFO_BYTES = 1_272
VM_PROT_EXECUTE = 0x4
U64_MAX = 0xffff_ffff_ffff_ffff
INT32_MAX = 0x7fff_ffff

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
  extern "int close(int)"
  extern "int dup(int)"
  extern "void* fdopendir(int)"
  extern "void* readdir(void*)"
  extern "void rewinddir(void*)"
  extern "int closedir(void*)"
  extern "int proc_pidinfo(int, int, unsigned long long, void*, int)"
end

BUILD_A_PARENT_EXPECTED = {
  "device" => 16_777_231,
  "flags" => 0,
  "gid" => 0,
  "inode" => 774_813,
  "mode" => "1777",
  "uid" => 0,
}.freeze
BUILD_A_ROOT_EXPECTED = {
  "bytes" => 128,
  "device" => 16_777_231,
  "flags" => 0,
  "gid" => 0,
  "inode" => 18_009_932,
  "mode" => "0700",
  "nlink" => 4,
  "type" => "DIRECTORY",
  "uid" => 501,
}.freeze
BUILD_A_OBJECT_EXPECTED = {
  "bytes" => 728,
  "device" => 16_777_231,
  "flags" => 0,
  "gid" => 0,
  "inode" => 18_009_934,
  "mode" => "0400",
  "nlink" => 1,
  "sha256" =>
    "20502bf5d7958d9367712a01ba30c305840d65574d5bdd9f0c12d70a6d37a728",
  "type" => "REGULAR",
  "uid" => 501,
}.freeze
BUILD_A_BUNDLE_EXPECTED = {
  "bytes" => 33_496,
  "device" => 16_777_231,
  "flags" => 0,
  "gid" => 0,
  "inode" => 18_009_935,
  "mode" => "0400",
  "nlink" => 1,
  "sha256" =>
    "09b8f7d5cb6104e13e2cbc0d3731e81031287f1d6e3436c14e0ef3937d5a0c71",
  "type" => "REGULAR",
  "uid" => 501,
}.freeze
BUILD_A_MACHO_EXPECTED = {
  "blob_bounds" => [{"length" => 419, "offset" => 20, "slot_type" => 0}],
  "cdhash" => "aff7772ee4414e612b62b5bf4a8576527d33f285",
  "code_directory_bytes" => 419,
  "code_directory_offset" => 20,
  "code_directory_sha256" =>
    "aff7772ee4414e612b62b5bf4a8576527d33f285a22e97edd85a0f332e4eed03",
  "commands" => [
    25, 25, 25, 2_147_483_700, 2_147_483_699, 2, 11, 27, 50, 42, 12,
    38, 41, 29,
  ],
  "external_defined_symbols" => ["_ergentics_r19_obs11_c2_v7_fchmod"],
  "external_undefined_symbols" => ["___error", "_fchmod"],
  "lc_build_version" => {
    "minimum_os" => "14.0.0", "platform" => "macOS", "sdk" => "26.5.0",
  },
  "lc_code_signature" => {"dataoff" => 33_056, "datasize" => 440},
  "linked_images" => ["/usr/lib/libSystem.B.dylib"],
  "lc_suffix" => {
    "all_zero" => true,
    "bytes" => 1,
    "hex" => "00",
    "sha256" =>
      "6e340b9cffb37a989ca544e6bb780a2c78901d3fb33738768511a30617afa01d",
  },
  "signature_region_sha256" =>
    "370663a8ffe2452bde1e32d751852fde6defc1d047d841075fa4f5ae08f58cf2",
  "superblob" => {
    "bytes" => 439,
    "count" => 1,
    "fresh_v9_expected_witness" => true,
    "sha256" =>
      "0fb2ce1e730c318301416493a95f112c5758c371b60319a13ad996120ae2ddff",
    "structural_predicates" => true,
  },
  "uuid" => "0371C336-3A6F-338E-9CD4-9349603C9F44",
}.freeze

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
OUTER_PUBLICATION_LEAVES =
  (SUCCESS_INVENTORY + ["99-incomplete.json"]).freeze
COMPACT_VNODE_FIELDS = %w[
  device inode uid gid mode nlink bytes flags type
].freeze
ABSOLUTE_EMERGENCY_OUTER_BYTES = (
  "{\"authority\":\"ABSTAIN\"," \
  "\"capture_root\":\"#{CAPTURE_ROOT}\"," \
  "\"classification\":\"INFRASTRUCTURE_INCOMPLETE\"," \
  "\"consumption\":\"CONSUMED_NO_RETRY\"," \
  "\"data_status\":\"STATIC_BOUNDED_LAST_RESORT_NO_DYNAMIC_FACTS\"," \
  "\"journal_contract\":\"UNSATISFIED_OUTER_ONLY_RECEIPT_RETENTION\"," \
  "\"live_freeze_commit\":\"#{LIVE_FREEZE_COMMIT}\"," \
  "\"live_freeze_sha256\":\"#{LIVE_FREEZE_SHA256}\"," \
  "\"live_freeze_tree\":\"#{LIVE_FREEZE_TREE}\"," \
  "\"runner_source_identity\":\"EXTERNAL_FINAL_READINESS_BINDING\"," \
  "\"schema\":\"ergentics-r19-obs11-c2-prefix-capture-emergency-outer-v9\"," \
  "\"status\":\"CONSUMED_EMERGENCY_OUTER_RETAINED_NO_RETRY\"}\n"
).b.freeze

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

def close_raw_descriptor(descriptor)
  return nil unless descriptor.is_a?(Integer) && descriptor >= 0
  result, error = native_call { C2CaptureDarwin.close(descriptor) }
  return nil if result == 0
  "close:#{result}:#{error}"
rescue StandardError => close_error
  "#{close_error.class.name}:#{close_error.message}"
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
  close_error = if defined?(io) && io
    close_io(io)
  elsif defined?(descriptor)
    close_raw_descriptor(descriptor)
  end
  if error.is_a?(C2PrefixCaptureFailure)
    capture_fail("#{error.message}:RAW_CLOSE:#{close_error}") if close_error
    raise
  end
  suffix = close_error ? ":RAW_CLOSE:#{close_error}" : ""
  capture_fail("#{label}:#{error.class.name}:#{error.message}#{suffix}")
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
  close_error = if defined?(io) && io
    close_io(io)
  elsif defined?(result) && result.is_a?(Integer) && result >= 0
    close_raw_descriptor(result)
  end
  if exception.is_a?(C2PrefixCaptureFailure)
    capture_fail("#{exception.message}:RAW_CLOSE:#{close_error}") if close_error
    raise
  end
  suffix = close_error ? ":RAW_CLOSE:#{close_error}" : ""
  capture_fail("#{label}:#{exception.class.name}:#{exception.message}#{suffix}")
end

def exact_stat_signature(stat)
  [stat.dev, stat.ino, stat.uid, stat.gid, stat.mode & 0o7777,
   stat.nlink, stat.size]
end

def require_named_held_join(path, held, label)
  named = File.lstat(path)
  capture_fail("#{label}:NAMED_HELD") unless
    exact_stat_signature(named) == exact_stat_signature(held)
  named
end

def rejoin_build_parent(parent_io, label)
  held = parent_io.stat
  named = require_named_held_join(BUILD_A_PARENT, held, label)
  native = native_stat_path(BUILD_A_PARENT, "#{label}:NATIVE")
  capture_fail("#{label}:TYPE") unless named.directory? &&
    native.fetch("type") == "DIRECTORY"
  capture_fail("#{label}:HELD_NATIVE") unless stat_matches_native?(held, native)
  observed = native.reject { |key, _| %w[bytes nlink type].include?(key) }
  capture_fail("#{label}:IDENTITY") unless observed == BUILD_A_PARENT_EXPECTED
  native
end

def rejoin_build_root(parent_io, root_io, label)
  rejoin_build_parent(parent_io, "#{label}:PARENT")
  held = root_io.stat
  relative = native_stat_at(
    parent_io.fileno, BUILD_A_ROOT_LEAF, "#{label}:RELATIVE",
    flags: AT_SYMLINK_NOFOLLOW_ANY
  )
  named = require_named_held_join(BUILD_A_ROOT, held, label)
  capture_fail("#{label}:TYPE") unless named.directory? &&
    relative.fetch("type") == "DIRECTORY"
  capture_fail("#{label}:HELD_RELATIVE") unless
    stat_matches_native?(held, relative)
  capture_fail("#{label}:IDENTITY") unless relative == BUILD_A_ROOT_EXPECTED
  relative
end

def rejoin_build_leaf(root_io, leaf, path, held_io, expected, label)
  held = held_io.stat
  relative = native_stat_at(
    root_io.fileno, leaf, "#{label}:RELATIVE",
    flags: AT_SYMLINK_NOFOLLOW_ANY
  )
  named = require_named_held_join(path, held, label)
  capture_fail("#{label}:TYPE") unless named.file? &&
    relative.fetch("type") == "REGULAR"
  capture_fail("#{label}:HELD_RELATIVE") unless
    stat_matches_native?(held, relative)
  expected_stat = expected.reject { |key, _| key == "sha256" }
  capture_fail("#{label}:IDENTITY") unless relative == expected_stat
  relative
end

def raw_held_directory_names(directory_io, label)
  held_before = directory_io.stat
  duplicate, duplicate_error = native_call do
    C2CaptureDarwin.dup(directory_io.fileno)
  end
  capture_fail("#{label}:DUP:#{duplicate}:#{duplicate_error}") unless
    duplicate >= 3
  scan_io = IO.new(duplicate)
  scan_io.binmode
  scan_io.close_on_exec = true
  capture_fail("#{label}:CLOEXEC") unless scan_io.close_on_exec?
  capture_fail("#{label}:SCAN_ROOT") unless
    exact_stat_signature(scan_io.stat) == exact_stat_signature(held_before)
  pointer, fdopendir_error = native_call do
    C2CaptureDarwin.fdopendir(duplicate)
  end
  if pointer.nil? || pointer.to_i.zero?
    close_io!(scan_io, "#{label}:FDOPENDIR_SOURCE_CLOSE")
    capture_fail("#{label}:FDOPENDIR:#{fdopendir_error}")
  end
  scan_io.autoclose = false
  directory_pointer = pointer
  directory_open = true
  names = []
  C2CaptureDarwin.rewinddir(directory_pointer)
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
  held_after = directory_io.stat
  capture_fail("#{label}:SCAN_DRIFT") unless
    exact_stat_signature(scan_after) == exact_stat_signature(held_before) &&
      exact_stat_signature(held_after) == exact_stat_signature(held_before)
  C2CaptureDarwin.rewinddir(directory_pointer)
  close_result, close_error = native_call do
    C2CaptureDarwin.closedir(directory_pointer)
  end
  directory_open = false
  capture_fail("#{label}:CLOSEDIR:#{close_result}:#{close_error}") unless
    close_result == 0
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
  elsif defined?(duplicate) && duplicate.is_a?(Integer) && duplicate >= 0 &&
      (!defined?(scan_io) || scan_io.nil?)
    close_raw_descriptor(duplicate)
  end
  raise primary
end

def u32le(bytes, offset)
  bytes.byteslice(offset, 4).unpack1("L<")
end

def u32be(bytes, offset)
  bytes.byteslice(offset, 4).unpack1("N")
end

def bounded_macho_string(bytes, offset, limit, label)
  capture_fail("#{label}:OFFSET") unless
    offset.is_a?(Integer) && limit.is_a?(Integer) &&
      offset >= 0 && limit > offset && limit <= bytes.bytesize
  frame = bytes.byteslice(offset, limit - offset)
  nul = frame.index("\0")
  capture_fail("#{label}:NUL") unless nul
  value = frame.byteslice(0, nul)
  text = value.dup.force_encoding(Encoding::UTF_8)
  capture_fail("#{label}:UTF8") unless text.valid_encoding?
  text
end

def parse_build_a_macho(bytes, label)
  capture_fail("#{label}:HEADER") if bytes.bytesize < 32
  capture_fail("#{label}:MAGIC") unless u32le(bytes, 0) == 0xfeedfacf
  capture_fail("#{label}:CPU") unless u32le(bytes, 4) == 0x0100000c
  capture_fail("#{label}:FILETYPE") unless u32le(bytes, 12) == 8
  ncmds = u32le(bytes, 16)
  sizeofcmds = u32le(bytes, 20)
  capture_fail("#{label}:COMMAND_CAP") unless
    ncmds.between?(1, 128) && sizeofcmds <= bytes.bytesize - 32
  cursor = 32
  finish = 32 + sizeofcmds
  uuid = nil
  build = nil
  signature = nil
  symtab = nil
  commands = []
  linked_images = []
  ncmds.times do
    capture_fail("#{label}:COMMAND_HEADER") if cursor + 8 > finish
    command = u32le(bytes, cursor)
    command_size = u32le(bytes, cursor + 4)
    capture_fail("#{label}:COMMAND_SIZE") unless
      command_size >= 8 && cursor + command_size <= finish
    commands << command
    case command
    when 0x1b
      capture_fail("#{label}:UUID_SIZE") unless command_size == 24 && uuid.nil?
      hex = bytes.byteslice(cursor + 8, 16).unpack1("H*").upcase
      uuid = [
        hex[0, 8], hex[8, 4], hex[12, 4], hex[16, 4], hex[20, 12],
      ].join("-")
    when 0x32
      capture_fail("#{label}:BUILD_SIZE") unless command_size >= 24 && build.nil?
      build = {
        "platform" => u32le(bytes, cursor + 8),
        "minos_raw" => u32le(bytes, cursor + 12),
        "sdk_raw" => u32le(bytes, cursor + 16),
      }
    when 0x1d
      capture_fail("#{label}:SIGNATURE_SIZE") unless
        command_size == 16 && signature.nil?
      signature = {
        "dataoff" => u32le(bytes, cursor + 8),
        "datasize" => u32le(bytes, cursor + 12),
      }
    when 0x2
      capture_fail("#{label}:SYMTAB_SIZE") unless command_size == 24 && symtab.nil?
      symtab = {
        "symoff" => u32le(bytes, cursor + 8),
        "nsyms" => u32le(bytes, cursor + 12),
        "stroff" => u32le(bytes, cursor + 16),
        "strsize" => u32le(bytes, cursor + 20),
      }
    when 0xc
      capture_fail("#{label}:DYLIB_SIZE") unless command_size >= 24
      name_offset = u32le(bytes, cursor + 8)
      capture_fail("#{label}:DYLIB_NAME_OFFSET") unless
        name_offset >= 24 && name_offset < command_size
      linked_images << bounded_macho_string(
        bytes, cursor + name_offset, cursor + command_size,
        "#{label}:DYLIB_NAME"
      )
    end
    cursor += command_size
  end
  capture_fail("#{label}:COMMAND_END") unless cursor == finish
  capture_fail("#{label}:UUID_MISSING") unless uuid
  capture_fail("#{label}:BUILD_MISSING") unless
    build && build.fetch("platform") == 1 &&
      build.fetch("minos_raw") == 0x000e0000 &&
      build.fetch("sdk_raw") == 0x001a0500
  capture_fail("#{label}:SIGNATURE_MISSING") unless signature
  capture_fail("#{label}:SYMTAB_MISSING") unless symtab

  symoff = symtab.fetch("symoff")
  nsyms = symtab.fetch("nsyms")
  stroff = symtab.fetch("stroff")
  strsize = symtab.fetch("strsize")
  capture_fail("#{label}:SYMTAB_RANGE") unless
    nsyms.between?(1, 1_024) && symoff + nsyms * 16 <= bytes.bytesize &&
      strsize.positive? && stroff + strsize <= bytes.bytesize
  external_defined = []
  external_undefined = []
  nsyms.times do |index|
    entry = symoff + index * 16
    string_index = u32le(bytes, entry)
    type = bytes.getbyte(entry + 4)
    next if (type & 0xe0) != 0 || (type & 0x01).zero?
    capture_fail("#{label}:SYMBOL_STRING_INDEX") unless
      string_index.positive? && string_index < strsize
    name = bounded_macho_string(
      bytes, stroff + string_index, stroff + strsize,
      "#{label}:SYMBOL_NAME"
    )
    if (type & 0x0e).zero?
      external_undefined << name
    else
      external_defined << name
    end
  end

  signature_end = signature.fetch("dataoff") + signature.fetch("datasize")
  capture_fail("#{label}:SIGNATURE_RANGE") unless
    signature.fetch("datasize").positive? && signature_end <= bytes.bytesize
  signature_region =
    bytes.byteslice(signature.fetch("dataoff"), signature.fetch("datasize"))
  capture_fail("#{label}:SUPERBLOB") unless
    signature_region.bytesize >= 12 &&
      u32be(signature_region, 0) == 0xfade0cc0
  superblob_length = u32be(signature_region, 4)
  count = u32be(signature_region, 8)
  header_and_indexes_length = 12 + count * 8
  capture_fail("#{label}:SUPERBLOB_STRUCTURAL") unless
    count.between?(1, 16) &&
      header_and_indexes_length <= superblob_length &&
      superblob_length <= signature_region.bytesize
  suffix_length = signature_region.bytesize - superblob_length
  suffix = signature_region.byteslice(superblob_length, suffix_length)
  capture_fail("#{label}:SUPERBLOB_SUFFIX") unless
    [0, 1].include?(suffix_length) && suffix == ("\0".b * suffix_length)
  superblob = signature_region.byteslice(0, superblob_length)
  code_directory = nil
  code_directory_offset = nil
  blob_bounds = []
  count.times do |index|
    slot_type = u32be(superblob, 12 + index * 8)
    offset = u32be(superblob, 16 + index * 8)
    capture_fail("#{label}:BLOB_OFFSET") if
      offset < header_and_indexes_length || offset + 8 > superblob_length
    length = u32be(superblob, offset + 4)
    capture_fail("#{label}:BLOB_RANGE") unless
      length >= 8 && offset + length <= superblob_length
    blob_bounds << {"length" => length, "offset" => offset,
                    "slot_type" => slot_type}
    next unless slot_type.zero?
    capture_fail("#{label}:CODE_DIRECTORY_DUPLICATE") if code_directory
    capture_fail("#{label}:CODE_DIRECTORY_RANGE") unless
      u32be(superblob, offset) == 0xfade0c02 && length >= 44
    code_directory = superblob.byteslice(offset, length)
    code_directory_offset = offset
    capture_fail("#{label}:CODE_DIRECTORY_HASH_TYPE") unless
      code_directory.getbyte(36) == 32 && code_directory.getbyte(37) == 2
  end
  capture_fail("#{label}:CODE_DIRECTORY_MISSING") unless code_directory
  code_directory_sha = Digest::SHA256.hexdigest(code_directory)
  {
    "blob_bounds" => blob_bounds,
    "cdhash" => code_directory_sha.byteslice(0, 40),
    "code_directory_bytes" => code_directory.bytesize,
    "code_directory_offset" => code_directory_offset,
    "code_directory_sha256" => code_directory_sha,
    "commands" => commands,
    "external_defined_symbols" => external_defined.sort,
    "external_undefined_symbols" => external_undefined.sort,
    "lc_build_version" => {
      "minimum_os" => "14.0.0", "platform" => "macOS", "sdk" => "26.5.0",
    },
    "lc_code_signature" => signature,
    "linked_images" => linked_images.sort,
    "lc_suffix" => {
      "all_zero" => true,
      "bytes" => suffix_length,
      "hex" => suffix.unpack1("H*"),
      "sha256" => Digest::SHA256.hexdigest(suffix),
    },
    "signature_region_sha256" => Digest::SHA256.hexdigest(signature_region),
    "superblob" => {
      "bytes" => superblob_length,
      "count" => count,
      "fresh_v9_expected_witness" =>
        superblob_length == 439 && signature_region.bytesize == 440 &&
          suffix_length == 1 && suffix == "\0".b,
      "sha256" => Digest::SHA256.hexdigest(superblob),
      "structural_predicates" => true,
    },
    "uuid" => uuid,
  }
end

def revalidate_build_a(parent_io, root_io, object_io, bundle_io, label)
  parent_before = rejoin_build_parent(parent_io, "#{label}:PARENT_BEFORE")
  root_before = rejoin_build_root(parent_io, root_io, "#{label}:ROOT_BEFORE")
  names = raw_held_directory_names(root_io, "#{label}:NAMES")
  capture_fail("#{label}:NAMES") unless names == BUILD_A_NAMES
  capture_fail("#{label}:NLINK") unless root_before.fetch("nlink") == 4
  object_before = rejoin_build_leaf(
    root_io, BUILD_A_OBJECT_LEAF, BUILD_A_OBJECT, object_io,
    BUILD_A_OBJECT_EXPECTED, "#{label}:OBJECT_BEFORE"
  )
  bundle_before = rejoin_build_leaf(
    root_io, BUILD_A_BUNDLE_LEAF, BUILD_A_BUNDLE, bundle_io,
    BUILD_A_BUNDLE_EXPECTED, "#{label}:BUNDLE_BEFORE"
  )
  capture_fail("#{label}:VNODE_DISTINCT") unless
    [root_before.fetch("inode"), object_before.fetch("inode"),
     bundle_before.fetch("inode")].uniq.length == 3
  object_bytes = held_bytes(
    object_io, "#{label}:OBJECT_READ", cap: BUILD_A_OBJECT_EXPECTED.fetch("bytes")
  )
  capture_fail("#{label}:OBJECT_EOF") unless object_io.read(1).nil?
  bundle_bytes = held_bytes(
    bundle_io, "#{label}:BUNDLE_READ", cap: BUILD_A_BUNDLE_EXPECTED.fetch("bytes")
  )
  capture_fail("#{label}:BUNDLE_EOF") unless bundle_io.read(1).nil?
  object_sha = Digest::SHA256.hexdigest(object_bytes)
  bundle_sha = Digest::SHA256.hexdigest(bundle_bytes)
  capture_fail("#{label}:OBJECT_HASH") unless
    object_sha == BUILD_A_OBJECT_EXPECTED.fetch("sha256")
  capture_fail("#{label}:BUNDLE_HASH") unless
    bundle_sha == BUILD_A_BUNDLE_EXPECTED.fetch("sha256")
  macho = parse_build_a_macho(bundle_bytes, "#{label}:MACHO")
  capture_fail("#{label}:MACHO_IDENTITY") unless macho == BUILD_A_MACHO_EXPECTED
  object_after = rejoin_build_leaf(
    root_io, BUILD_A_OBJECT_LEAF, BUILD_A_OBJECT, object_io,
    BUILD_A_OBJECT_EXPECTED, "#{label}:OBJECT_AFTER"
  )
  bundle_after = rejoin_build_leaf(
    root_io, BUILD_A_BUNDLE_LEAF, BUILD_A_BUNDLE, bundle_io,
    BUILD_A_BUNDLE_EXPECTED, "#{label}:BUNDLE_AFTER"
  )
  root_after = rejoin_build_root(parent_io, root_io, "#{label}:ROOT_AFTER")
  capture_fail("#{label}:ROOT_DRIFT") unless root_after == root_before
  parent_after = rejoin_build_parent(parent_io, "#{label}:PARENT_AFTER")
  capture_fail("#{label}:PARENT_IDENTITY_DRIFT") unless
    %w[device flags gid inode mode type uid].all? { |field|
      parent_after.fetch(field) == parent_before.fetch(field)
    }
  {
    "bundle" => bundle_after.merge("sha256" => bundle_sha),
    "macho" => macho,
    "names" => names,
    "object" => object_after.merge("sha256" => object_sha),
    "parent" => parent_after,
    "root" => root_after,
  }
end

def mark_build_a_descriptor_opened(state, role, io)
  lifecycle = state.fetch("bundle_runtime").fetch(
    "descriptor_lifecycle"
  ).fetch(role)
  capture_fail("BUILD_A_DESCRIPTOR:#{role}:DUPLICATE_OPEN") if
    lifecycle.fetch("opened")
  lifecycle["fd_at_open"] = io.fileno
  lifecycle["opened"] = true
  true
end

def admit_build_a(state)
  capture_fail("BUILD_A_PARENT_REALPATH") unless
    File.realpath(BUILD_A_PARENT) == BUILD_A_PARENT
  capture_fail("BUILD_A_ROOT_REALPATH") unless
    File.realpath(BUILD_A_ROOT) == BUILD_A_ROOT
  capture_fail("BUILD_A_OBJECT_REALPATH") unless
    File.realpath(BUILD_A_OBJECT) == BUILD_A_OBJECT
  capture_fail("BUILD_A_BUNDLE_REALPATH") unless
    File.realpath(BUILD_A_BUNDLE) == BUILD_A_BUNDLE
  parent_io = open_directory_path(BUILD_A_PARENT, "BUILD_A_PARENT_OPEN")
  mark_build_a_descriptor_opened(state, "private_tmp", parent_io)
  rejoin_build_parent(parent_io, "BUILD_A_PARENT_ADMISSION")
  root_io = open_at(
    parent_io.fileno, BUILD_A_ROOT_LEAF,
    O_RDONLY | O_DIRECTORY | O_NOFOLLOW_ANY | O_CLOEXEC,
    "BUILD_A_ROOT_OPEN"
  )
  mark_build_a_descriptor_opened(state, "root", root_io)
  rejoin_build_root(parent_io, root_io, "BUILD_A_ROOT_ADMISSION")
  object_io = open_at(
    root_io.fileno, BUILD_A_OBJECT_LEAF,
    O_RDONLY | O_NOFOLLOW_ANY | O_CLOEXEC, "BUILD_A_OBJECT_OPEN"
  )
  mark_build_a_descriptor_opened(state, "object", object_io)
  bundle_io = open_at(
    root_io.fileno, BUILD_A_BUNDLE_LEAF,
    O_RDONLY | O_NOFOLLOW_ANY | O_CLOEXEC, "BUILD_A_BUNDLE_OPEN"
  )
  mark_build_a_descriptor_opened(state, "bundle", bundle_io)
  receipt = revalidate_build_a(
    parent_io, root_io, object_io, bundle_io, "BUILD_A_ADMISSION"
  )
  [parent_io, root_io, object_io, bundle_io, receipt]
rescue StandardError
  close_build_a_descriptors(
    state,
    defined?(parent_io) ? parent_io : nil,
    defined?(root_io) ? root_io : nil,
    defined?(object_io) ? object_io : nil,
    defined?(bundle_io) ? bundle_io : nil
  )
  raise
end

def mapped_build_a_identity(state, symbol_address, label)
  state.fetch("bundle_runtime")["mapping_attempts"] += 1
  capture_fail("#{label}:MAPPING_BUDGET") if
    state.fetch("bundle_runtime").fetch("mapping_attempts") > 2
  buffer = Fiddle::Pointer.malloc(PROC_REGION_PATH_INFO_BYTES)
  buffer[0, PROC_REGION_PATH_INFO_BYTES] = "\0" * PROC_REGION_PATH_INFO_BYTES
  returned, error = native_call do
    C2CaptureDarwin.proc_pidinfo(
      Process.pid, PROC_PIDREGIONPATHINFO, symbol_address, buffer,
      PROC_REGION_PATH_INFO_BYTES
    )
  end
  capture_fail("#{label}:PROC_PIDINFO:#{returned}:#{error}") unless
    returned == PROC_REGION_PATH_INFO_BYTES
  bytes = buffer[0, PROC_REGION_PATH_INFO_BYTES]
  protection = u32le(bytes, 0)
  file_offset = bytes.byteslice(16, 8).unpack1("Q<")
  region_address = bytes.byteslice(80, 8).unpack1("Q<")
  region_size = bytes.byteslice(88, 8).unpack1("Q<")
  device = u32le(bytes, 96)
  inode = bytes.byteslice(104, 8).unpack1("Q<")
  capture_fail("#{label}:REGION_SIZE") if region_size.zero?
  following = region_address + region_size
  capture_fail("#{label}:REGION_OVERFLOW") if following > U64_MAX
  capture_fail("#{label}:SYMBOL_CONTAINMENT") unless
    region_address <= symbol_address && symbol_address < following
  path_frame = bytes.byteslice(248, 1_024)
  nul = path_frame.index("\0")
  capture_fail("#{label}:PATH_NUL") unless nul
  path = path_frame.byteslice(0, nul).dup.force_encoding(Encoding::UTF_8)
  capture_fail("#{label}:PATH_UTF8") unless path.valid_encoding?
  capture_fail("#{label}:PROTECTION") if
    (protection & VM_PROT_EXECUTE).zero?
  capture_fail("#{label}:FILE_OFFSET") unless file_offset.zero?
  capture_fail("#{label}:PATH") unless path == BUILD_A_BUNDLE
  capture_fail("#{label}:VNODE") unless
    [device, inode] ==
      [BUILD_A_BUNDLE_EXPECTED.fetch("device"),
       BUILD_A_BUNDLE_EXPECTED.fetch("inode")]
  receipt = {
    "adjacent_parsed_bundle_uuid" => BUILD_A_MACHO_EXPECTED.fetch("uuid"),
    "device" => device,
    "file_offset" => file_offset,
    "inode" => inode,
    "observation_stage" => label,
    "path" => path,
    "protection" => protection,
    "region_address" => region_address,
    "region_size" => region_size,
    "symbol_address" => symbol_address,
  }
  state.fetch("bundle_runtime")["mapping_completed"] += 1
  state.fetch("bundle_runtime").fetch("mapping_receipts") << receipt
  receipt
end

def load_build_a_bundle(state, runtime_owner, parent_io, root_io, object_io,
                        bundle_io)
  capture_fail("LOADER:RTLD_NOW") unless Fiddle::RTLD_NOW == DARWIN_RTLD_NOW
  capture_fail("LOADER:RTLD_MODE") unless DARWIN_RTLD_MODE == 6
  state.fetch("bundle_runtime")["preload_revalidation"] = revalidate_build_a(
    parent_io, root_io, object_io, bundle_io, "BUILD_A_PRELOAD"
  )
  state.fetch("bundle_runtime")["dlopen_attempts"] += 1
  capture_fail("LOADER:DLOPEN_BUDGET") unless
    state.fetch("bundle_runtime").fetch("dlopen_attempts") == 1
  handle = Fiddle::Handle.new(BUILD_A_BUNDLE, DARWIN_RTLD_MODE)
  runtime_owner["handle"] = handle
  handle.disable_close
  capture_fail("LOADER:CLOSE_STILL_ENABLED") unless
    handle.close_enabled? == false
  state.fetch("bundle_runtime")["handle_close_disabled"] = true
  state.fetch("bundle_runtime")["dlsym_attempts"] += 1
  capture_fail("LOADER:DLSYM_BUDGET") unless
    state.fetch("bundle_runtime").fetch("dlsym_attempts") == 1
  address = handle[NATIVE_SYMBOL]
  capture_fail("LOADER:SYMBOL_ADDRESS") unless
    address.is_a?(Integer) && address.positive? && address <= U64_MAX
  function = Fiddle::Function.new(
    address,
    [Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP],
    Fiddle::TYPE_INT
  )
  runtime_owner["function"] = function
  runtime_owner["symbol_address"] = address
  mapped_build_a_identity(state, address, "BUILD_A_MAPPING_INITIAL")
  state.fetch("bundle_runtime")["postload_revalidation"] = revalidate_build_a(
    parent_io, root_io, object_io, bundle_io, "BUILD_A_POSTLOAD"
  )
  [handle, function, address]
end

def finalize_build_a(state, symbol_address, parent_io, root_io, object_io,
                     bundle_io, label)
  mapped_build_a_identity(state, symbol_address, "#{label}:MAPPING_FINAL")
  state.fetch("bundle_runtime")["final_revalidation_attempts"] += 1
  capture_fail("#{label}:FINAL_REVALIDATION_BUDGET") unless
    state.fetch("bundle_runtime").fetch("final_revalidation_attempts") == 1
  receipt = revalidate_build_a(
    parent_io, root_io, object_io, bundle_io, "#{label}:REVALIDATION_FINAL"
  )
  state.fetch("bundle_runtime")["final_revalidation"] = receipt
  bundle = state.fetch("bundle_runtime")
  capture_fail("#{label}:DLOPEN_EXACT") unless bundle.fetch("dlopen_attempts") == 1
  capture_fail("#{label}:DLSYM_EXACT") unless bundle.fetch("dlsym_attempts") == 1
  capture_fail("#{label}:HANDLE_LIFETIME") unless
    bundle.fetch("handle_close_disabled") == true
  capture_fail("#{label}:MAPPING_ATTEMPTS_EXACT") unless
    bundle.fetch("mapping_attempts") == 2
  capture_fail("#{label}:MAPPING_COMPLETED_EXACT") unless
    bundle.fetch("mapping_completed") == 2
  receipt
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
  named = File.lstat("#{CAPTURE_ROOT}/#{leaf}")
  capture_fail("#{label}:TYPE") unless native.fetch("type") == "REGULAR"
  capture_fail("#{label}:HELD") unless stat_matches_native?(held_io.stat, native)
  capture_fail("#{label}:NAMED_HELD") unless
    exact_stat_signature(named) == exact_stat_signature(held_io.stat)
  native
end

def runtime_evidence_snapshot(state)
  canonical_value(
    {
      "bundle_runtime" => state.fetch("bundle_runtime"),
      "native_mode" => state.fetch("native_mode"),
    }
  )
end

def projection_string_identity(value, label)
  return nil if value.nil?
  capture_fail("#{label}:TYPE") unless value.is_a?(String)
  bytes = value.b
  {
    "bytes" => bytes.bytesize,
    "sha256" => Digest::SHA256.hexdigest(bytes),
  }
end

def compact_failure_diagnostic(value, label, prefix_bytes: 0)
  return nil if value.nil?
  capture_fail("#{label}:SHAPE") unless value.is_a?(Hash)
  result = {
    "error_class" => projection_string_identity(
      value["error_class"], "#{label}:CLASS"
    ),
    "error_message_bytes" => value["error_message_bytes"],
    "error_message_sha256" => value["error_message_sha256"],
    "error_message_was_truncated" =>
      value["error_message_prefix_truncated"],
    "phase" => projection_string_identity(
      value["phase"], "#{label}:PHASE"
    ),
  }
  if prefix_bytes.positive?
    prefix = value["error_message_prefix_hex"]
    capture_fail("#{label}:PREFIX_TYPE") unless
      prefix.nil? || prefix.is_a?(String)
    if prefix
      maximum_hex_bytes = prefix_bytes * 2
      result["error_message_bounded_prefix_hex"] =
        prefix.byteslice(0, maximum_hex_bytes)
      result["error_message_bounded_prefix_truncated"] =
        value["error_message_prefix_truncated"] == true ||
          prefix.bytesize > maximum_hex_bytes
    end
  end
  result
end

def compact_vnode_signature(value, label)
  return nil if value.nil?
  capture_fail("#{label}:SHAPE") unless value.is_a?(Hash)
  COMPACT_VNODE_FIELDS.map { |field| value.fetch(field) }
end

def compact_vnode_identity(value, label)
  return nil if value.nil?
  signature = compact_vnode_signature(value, label)
  COMPACT_VNODE_FIELDS.each_with_index.each_with_object({}) do |pair, result|
    field, index = pair
    result[field] = signature.fetch(index)
  end
end

def compact_leaf_identity(value, label)
  return nil if value.nil?
  capture_fail("#{label}:SHAPE") unless value.is_a?(Hash)
  {
    "sha256" => value["sha256"],
    "vnode" => compact_vnode_identity(value, "#{label}:VNODE"),
  }
end

def compact_mapping_receipt(value, label)
  return nil if value.nil?
  capture_fail("#{label}:SHAPE") unless value.is_a?(Hash)
  %w[
    adjacent_parsed_bundle_uuid device file_offset inode observation_stage
    path protection region_address region_size symbol_address
  ].each_with_object({}) do |field, result|
    result[field] = value.fetch(field)
  end
end

def compact_build_revalidation(value, label)
  return nil if value.nil?
  capture_fail("#{label}:SHAPE") unless value.is_a?(Hash)
  macho = value.fetch("macho")
  capture_fail("#{label}:MACHO_SHAPE") unless macho.is_a?(Hash)
  superblob = macho.fetch("superblob")
  capture_fail("#{label}:SUPERBLOB_SHAPE") unless superblob.is_a?(Hash)
  {
    "bundle" => compact_leaf_identity(value.fetch("bundle"), "#{label}:BUNDLE"),
    "macho_identity" => {
      "parsed_macho_receipt_canonical_sha256" =>
        Digest::SHA256.hexdigest(canonical_json(macho)),
      "cdhash" => macho.fetch("cdhash"),
      "code_directory_sha256" => macho.fetch("code_directory_sha256"),
      "signature_region_sha256" => macho.fetch("signature_region_sha256"),
      "superblob_sha256" => superblob.fetch("sha256"),
      "uuid" => macho.fetch("uuid"),
    },
    "names" => value.fetch("names"),
    "object" => compact_leaf_identity(value.fetch("object"), "#{label}:OBJECT"),
    "parent" => compact_vnode_identity(value.fetch("parent"), "#{label}:PARENT"),
    "root" => compact_vnode_identity(value.fetch("root"), "#{label}:ROOT"),
  }
end

def compact_descriptor_close_errors(value, label)
  capture_fail("#{label}:SHAPE") unless value.is_a?(Hash)
  allowed = %w[bundle object private_tmp root]
  capture_fail("#{label}:KEYS") unless (value.keys - allowed).empty?
  allowed.each_with_object({}) do |key, result|
    next unless value.key?(key)
    result[key] = projection_string_identity(value[key], "#{label}:#{key}")
  end
end

def compact_descriptor_lifecycle(value, label)
  capture_fail("#{label}:SHAPE") unless value.is_a?(Hash)
  roles = %w[bundle object private_tmp root]
  capture_fail("#{label}:KEYS") unless value.keys.sort == roles.sort
  roles.each_with_object({}) do |role, result|
    receipt = value.fetch(role)
    capture_fail("#{label}:#{role}:SHAPE") unless receipt.is_a?(Hash)
    close_errors = receipt.fetch("close_errors")
    capture_fail("#{label}:#{role}:ERRORS") unless
      close_errors.is_a?(Array) && close_errors.length <= 3
    result[role] = {
      "close_attempts" => receipt.fetch("close_attempts"),
      "close_completed" => receipt.fetch("close_completed"),
      "close_errors" => close_errors.each_with_index.map do |error, index|
        projection_string_identity(
          error, "#{label}:#{role}:ERROR:#{index}"
        )
      end,
      "closed_observed_immediately_after_failed_attempt" => receipt.fetch(
        "closed_observed_immediately_after_failed_attempt"
      ),
      "fd_at_open" => receipt.fetch("fd_at_open"),
      "opened" => receipt.fetch("opened"),
    }
  end
end

def compact_bundle_runtime(state)
  bundle = state.fetch("bundle_runtime")
  mappings = bundle.fetch("mapping_receipts")
  capture_fail("OUTER:BUNDLE:MAPPING_RECEIPTS") unless
    mappings.is_a?(Array) && mappings.length <= 2
  stages = [
    ["FINAL", bundle.fetch("final_revalidation")],
    ["POSTLOAD", bundle.fetch("postload_revalidation")],
    ["PRELOAD", bundle.fetch("preload_revalidation")],
    ["ADMISSION", bundle.fetch("build_a_admission")],
  ]
  selected_stage, selected_receipt = stages.find { |pair| !pair.last.nil? }
  {
    "build_a_names" => BUILD_A_NAMES,
    "build_a_root" => BUILD_A_ROOT,
    "descriptor_close_errors" => compact_descriptor_close_errors(
      bundle.fetch("descriptor_close_errors"), "OUTER:BUNDLE:CLOSE_ERRORS"
    ),
    "descriptor_lifecycle" => compact_descriptor_lifecycle(
      bundle.fetch("descriptor_lifecycle"), "OUTER:BUNDLE:LIFECYCLE"
    ),
    "descriptor_lifecycle_observation" =>
      "AT_OUTER_PROJECTION_BEFORE_PROCESS_ENSURE",
    "dlopen_attempts" => bundle.fetch("dlopen_attempts"),
    "dlsym_attempts" => bundle.fetch("dlsym_attempts"),
    "final_revalidation_reference" =>
      selected_stage == "FINAL" ? "STRONGEST_COMPLETED_REVALIDATION" : nil,
    "final_revalidation_attempts" =>
      bundle.fetch("final_revalidation_attempts"),
    "handle_close_disabled" => bundle.fetch("handle_close_disabled"),
    "mapping_attempts" => bundle.fetch("mapping_attempts"),
    "mapping_completed" => bundle.fetch("mapping_completed"),
    "mapping_receipts" => mappings.each_with_index.map do |receipt, index|
      compact_mapping_receipt(receipt, "OUTER:BUNDLE:MAPPING:#{index}")
    end,
    "mapping_receipt_semantics" =>
      "BOUNDED_POINT_OBSERVATIONS_NOT_PROCESS_EXIT_CONTINUITY",
    "revalidation_completed" => {
      "admission" => !bundle.fetch("build_a_admission").nil?,
      "final" => !bundle.fetch("final_revalidation").nil?,
      "postload" => !bundle.fetch("postload_revalidation").nil?,
      "preload" => !bundle.fetch("preload_revalidation").nil?,
    },
    "strongest_completed_revalidation" => compact_build_revalidation(
      selected_receipt, "OUTER:BUNDLE:#{selected_stage || 'NONE'}"
    ),
    "strongest_completed_revalidation_stage" => selected_stage,
  }
end

def compact_native_call_receipt(receipt, label)
  capture_fail("#{label}:SHAPE") unless receipt.is_a?(Hash)
  target_role = receipt.fetch("target_role")
  relative_name = receipt.fetch("relative_name")
  capture_fail("#{label}:TARGET_ROLE") unless
    target_role.is_a?(String) && target_role.b.bytesize <= 64
  capture_fail("#{label}:RELATIVE_NAME") unless
    relative_name.is_a?(String) && relative_name.b.bytesize <= 64
  sync = receipt["target_sync"]
  capture_fail("#{label}:SYNC_SHAPE") unless sync.nil? || sync.is_a?(Hash)
  {
    "budget_class" => receipt.fetch("budget_class"),
    "errno_out" => receipt["errno_out"],
    "failure" => compact_failure_diagnostic(
      receipt["failure"], "#{label}:FAILURE"
    ),
    "fd" => receipt.fetch("fd"),
    "helper_entry_attempted" => receipt.fetch("helper_entry_attempted"),
    "helper_entry_classification" => receipt.fetch(
      "helper_entry_classification"
    ),
    "helper_entry_proven" => receipt.fetch("helper_entry_proven"),
    "helper_return" => receipt["helper_return"],
    "immediate_post_call_vnode" => compact_vnode_signature(
      receipt["immediate_post_call_join"], "#{label}:IMMEDIATE"
    ),
    "native_fchmod_reach_classification" =>
      receipt["native_fchmod_reach_classification"],
    "native_fchmod_reached" => receipt["native_fchmod_reached"],
    "ordinal" => receipt.fetch("ordinal"),
    "phase" => projection_string_identity(receipt["phase"], "#{label}:PHASE"),
    "post_sync_vnode" => compact_vnode_signature(
      receipt["post_sync_join"], "#{label}:POST_SYNC"
    ),
    "pre_call_vnode" => compact_vnode_signature(
      receipt["pre_call_join"], "#{label}:PRE_CALL"
    ),
    "preparation_complete" => receipt.fetch("preparation_complete"),
    "relative_name" => relative_name,
    "requested_mode" => receipt.fetch("requested_mode"),
    "sync" => sync && [sync["fsync"], sync["F_FULLFSYNC"]],
    "target_role" => target_role,
    "transition_complete" => receipt.fetch("transition_complete"),
  }
end

def compact_native_mode(state)
  native = state.fetch("native_mode")
  receipts = native.fetch("call_receipts")
  capture_fail("OUTER:NATIVE:RECEIPTS") unless
    receipts.is_a?(Array) && receipts.length <= 8
  {
    "call_receipts" => receipts.each_with_index.map do |receipt, index|
      compact_native_call_receipt(receipt, "OUTER:NATIVE:RECEIPT:#{index}")
    end,
    "failed_helper_entries" => native.fetch("failed_helper_entries"),
    "failed_helper_entries_semantics" =>
      "PROVEN_HELPER_ENTRIES_WITH_INCOMPLETE_TRANSITIONS",
    "helper_call_attempts" => native.fetch("helper_call_attempts"),
    "helper_call_entries" => native.fetch("helper_call_entries"),
    "helper_call_entries_semantics" =>
      "PROVEN_RUBY_TO_BUNDLE_ENTRIES_BY_NORMAL_WRAPPER_RETURN",
    "incomplete_transition_attempts" =>
      native.fetch("incomplete_transition_attempts"),
    "incomplete_99_helper_attempts" =>
      native.fetch("incomplete_99_helper_attempts"),
    "incomplete_99_helper_entries" =>
      native.fetch("incomplete_99_helper_entries"),
    "native_fchmod_call_entries" =>
      native.fetch("native_fchmod_call_entries"),
    "native_fchmod_call_entries_semantics" =>
      "PROVEN_LIBC_FCHMOD_REACH_BY_PREVALIDATED_NORMAL_RETURN",
    "native_fchmod_success_entries" =>
      native.fetch("native_fchmod_success_entries"),
    "next_ordinal" => native.fetch("next_ordinal"),
    "ordinary_leaf_helper_attempts" =>
      native.fetch("ordinary_leaf_helper_attempts"),
    "ordinary_leaf_helper_entries" =>
      native.fetch("ordinary_leaf_helper_entries"),
    "root_helper_attempts" => native.fetch("root_helper_attempts"),
    "root_helper_entries" => native.fetch("root_helper_entries"),
    "unproven_helper_entry_attempts" =>
      native.fetch("unproven_helper_entry_attempts"),
    "vnode_signature_fields" => COMPACT_VNODE_FIELDS,
  }
end

def compact_publication_outcomes(state)
  outcomes = state.fetch("publication_outcomes")
  OUTER_PUBLICATION_LEAVES.map do |leaf|
    outcome = outcomes[leaf]
    if outcome.nil?
      {
        "attempted" => state.fetch("publication_attempts").include?(leaf),
        "durability_proof_stage" => nil,
        "durable" => false,
        "failure" => compact_failure_diagnostic(
          state.fetch("publication_errors")[leaf],
          "OUTER:PUBLICATION:#{leaf}:FAILURE_WITHOUT_OUTCOME"
        ),
        "first_possible_mode_ordinal" => nil,
        "identity" => nil,
        "last_observed_mode_ordinal" => nil,
        "leaf" => leaf,
        "verification_complete" => false,
      }
    else
      capture_fail("OUTER:PUBLICATION:#{leaf}:SHAPE") unless
        outcome.is_a?(Hash)
      {
        "attempted" => outcome.fetch("attempted"),
        "durable" => outcome.fetch("durable"),
        "failure" => compact_failure_diagnostic(
          outcome["failure"], "OUTER:PUBLICATION:#{leaf}:FAILURE"
        ),
        "first_possible_mode_ordinal" =>
          outcome["first_possible_mode_ordinal"],
        "durability_proof_stage" => outcome["durability_proof_stage"],
        "identity" => compact_leaf_identity(
          outcome["leaf"], "OUTER:PUBLICATION:#{leaf}:IDENTITY"
        ),
        "last_observed_mode_ordinal" =>
          outcome["last_observed_mode_ordinal"],
        "leaf" => leaf,
        "verification_complete" => outcome.fetch("verification_complete"),
      }
    end
  end
end

def compact_root_state(value, label)
  return nil if value.nil?
  capture_fail("#{label}:SHAPE") unless value.is_a?(Hash)
  names = value["names"]
  if names
    capture_fail("#{label}:NAMES_SHAPE") unless
      names.is_a?(Array) && names.length <= 12 && names.all? { |name|
        name.is_a?(String) && name.b.bytesize <= 64
      }
  end
  status = value["status"]
  capture_fail("#{label}:STATUS") unless
    status.nil? || (status.is_a?(String) && status.b.bytesize <= 128)
  %w[
    observation_order observation_source terminal_completion terminal_purpose
  ].each do |field|
    candidate = value[field]
    capture_fail("#{label}:#{field}:TYPE_OR_CAP") unless
      candidate.nil? ||
        (candidate.is_a?(String) && candidate.b.bytesize <= 128)
  end
  {
    "current_mode_observed" => value["current_mode_observed"],
    "entries_count" => value["entries"].is_a?(Hash) ?
      value.fetch("entries").length : nil,
    "manifest_sha256" => value["manifest_sha256"],
    "mode_call_ordinal" => value["mode_call_ordinal"],
    "mode_call_reach_classification" =>
      value["mode_call_reach_classification"],
    "names" => names,
    "observation_order" => value["observation_order"],
    "observation_source" => value["observation_source"],
    "parent_sync_complete" => value["parent_sync_complete"],
    "root" => compact_vnode_identity(value["root"], "#{label}:ROOT"),
    "root_created_by_successful_mkdirat" =>
      value["root_created_by_successful_mkdirat"],
    "root_descriptor_observation" => compact_vnode_identity(
      value["root_descriptor_observation"], "#{label}:DESCRIPTOR"
    ),
    "root_recovery_error" => compact_failure_diagnostic(
      value["root_recovery_error"], "#{label}:RECOVERY_ERROR"
    ),
    "scan_error" => compact_failure_diagnostic(
      value["scan_error"], "#{label}:SCAN_ERROR"
    ),
    "status" => status,
    "root_sync_complete" => value["root_sync_complete"],
    "terminal_completion" => value["terminal_completion"],
    "terminal_purpose" => value["terminal_purpose"],
  }
end

def require_projection_component(value, cap, label)
  bytes = canonical_json(value).b
  capture_fail("#{label}:CAP:#{bytes.bytesize}") if bytes.bytesize > cap
  value
end

def outer_runtime_evidence_snapshot(state)
  bundle = require_projection_component(
    compact_bundle_runtime(state), OUTER_BUNDLE_COMPONENT_CAP,
    "OUTER:BUNDLE_COMPONENT"
  )
  native = require_projection_component(
    compact_native_mode(state), OUTER_NATIVE_COMPONENT_CAP,
    "OUTER:NATIVE_COMPONENT"
  )
  require_projection_component(
    canonical_value({"bundle_runtime" => bundle, "native_mode" => native}),
    OUTER_BUNDLE_COMPONENT_CAP + OUTER_NATIVE_COMPONENT_CAP +
      OUTER_EVIDENCE_WRAPPER_MAX,
    "OUTER:EVIDENCE_WRAPPER"
  )
end

def require_native_budgets(state, outcome, label)
  native = state.fetch("native_mode")
  capture_fail("#{label}:TOTAL_ATTEMPT_MAX") if
    native.fetch("helper_call_attempts") > 8
  capture_fail("#{label}:ORDINARY_ATTEMPT_MAX") if
    native.fetch("ordinary_leaf_helper_attempts") > 5
  capture_fail("#{label}:INCOMPLETE_ATTEMPT_MAX") if
    native.fetch("incomplete_99_helper_attempts") > 1
  capture_fail("#{label}:ROOT_ATTEMPT_MAX") if
    native.fetch("root_helper_attempts") > 2
  capture_fail("#{label}:TOTAL_ENTRY_MAX") if
    native.fetch("helper_call_entries") > native.fetch("helper_call_attempts")
  capture_fail("#{label}:ORDINARY_ENTRY_MAX") if
    native.fetch("ordinary_leaf_helper_entries") >
      native.fetch("ordinary_leaf_helper_attempts")
  capture_fail("#{label}:INCOMPLETE_ENTRY_MAX") if
    native.fetch("incomplete_99_helper_entries") >
      native.fetch("incomplete_99_helper_attempts")
  capture_fail("#{label}:ROOT_ENTRY_MAX") if
    native.fetch("root_helper_entries") > native.fetch("root_helper_attempts")
  # A failed 00 stops before child capture.  The branch that can fail both raw
  # leaves has already completed 00, so raw 01 + raw 02 + 99 + root is the
  # structural maximum of four proven entries with incomplete transitions.
  capture_fail("#{label}:FAILED_MAX") if
    native.fetch("failed_helper_entries") > 4
  capture_fail("#{label}:INCOMPLETE_TRANSITION_MAX") if
    native.fetch("incomplete_transition_attempts") > 4
  capture_fail("#{label}:NATIVE_COUNT") if
    native.fetch("native_fchmod_call_entries") >
      native.fetch("helper_call_entries")
  capture_fail("#{label}:NATIVE_SUCCESS_COUNT") if
    native.fetch("native_fchmod_success_entries") >
      native.fetch("native_fchmod_call_entries")
  capture_fail("#{label}:UNKNOWN_ACCOUNTING") unless
    native.fetch("helper_call_entries") +
      native.fetch("unproven_helper_entry_attempts") ==
        native.fetch("helper_call_attempts")
  expected = case outcome
  when "PASS" then 6
  when "SCIENTIFIC_FAILURE" then 5
  else nil
  end
  capture_fail("#{label}:ATTEMPT_EXACT:#{expected}") if
    expected && native.fetch("helper_call_attempts") != expected
  capture_fail("#{label}:ENTRY_EXACT:#{expected}") if
    expected && native.fetch("helper_call_entries") != expected
  if expected
    capture_fail("#{label}:NATIVE_EXACT:#{expected}") unless
      native.fetch("native_fchmod_call_entries") == expected
    capture_fail("#{label}:NATIVE_SUCCESS_EXACT:#{expected}") unless
      native.fetch("native_fchmod_success_entries") == expected
    capture_fail("#{label}:RECEIPTS_EXACT:#{expected}") unless
      native.fetch("call_receipts").length == expected
    capture_fail("#{label}:FAILED_ZERO") unless
      native.fetch("failed_helper_entries").zero?
    capture_fail("#{label}:INCOMPLETE_ZERO") unless
      native.fetch("incomplete_transition_attempts").zero?
    capture_fail("#{label}:UNKNOWN_ZERO") unless
      native.fetch("unproven_helper_entry_attempts").zero?
  end
  true
end

def native_mode_transition(state, native_function, target_io, target_role,
                           relative_name, named_path, requested_mode, label,
                           budget_class, expected_before, expected_after)
  capture_fail("#{label}:FUNCTION") unless
    native_function.is_a?(Fiddle::Function)
  target_fd = target_io.fileno
  capture_fail("#{label}:FD") unless
    target_fd.between?(3, INT32_MAX) &&
      [target_fd].pack("l<").unpack1("l<") == target_fd
  capture_fail("#{label}:MODE") unless [0o400, 0o500].include?(requested_mode)
  capture_fail("#{label}:BUDGET_CLASS") unless
    %w[ORDINARY_LEAF INCOMPLETE_99 PRIMARY_ROOT CONTAINMENT_ROOT].include?(
      budget_class
    )
  native = state.fetch("native_mode")
  class_entry_key = case budget_class
  when "ORDINARY_LEAF" then "ordinary_leaf_helper_entries"
  when "INCOMPLETE_99" then "incomplete_99_helper_entries"
  else "root_helper_entries"
  end
  class_attempt_key = case budget_class
  when "ORDINARY_LEAF" then "ordinary_leaf_helper_attempts"
  when "INCOMPLETE_99" then "incomplete_99_helper_attempts"
  else "root_helper_attempts"
  end
  class_cap = case class_entry_key
  when "ordinary_leaf_helper_entries" then 5
  when "incomplete_99_helper_entries" then 1
  else 2
  end
  ordinal = native.fetch("next_ordinal")
  native["next_ordinal"] = ordinal + 1
  receipt = {
    "budget_class" => budget_class,
    "errno_out" => nil,
    "failure" => nil,
    "fd" => target_fd,
    "helper_entry_attempted" => false,
    "helper_entry_classification" => "NOT_ATTEMPTED",
    "helper_entry_proven" => false,
    "helper_return" => nil,
    "immediate_post_call_join" => nil,
    "named_path" => named_path,
    "native_fchmod_reached" => nil,
    "native_fchmod_reach_classification" => nil,
    "ordinal" => ordinal,
    "phase" => state.fetch("phase"),
    "post_sync_join" => nil,
    "pre_call_join" => nil,
    "preparation_complete" => false,
    "relative_name" => relative_name,
    "requested_mode" => format("%04o", requested_mode),
    "target_role" => target_role,
    "target_sync" => nil,
    "transition_complete" => false,
  }
  receipt_appended = false
  pre_call = yield("PRE_CALL", expected_before)
  capture_fail("#{label}:PRE_MODE") unless
    pre_call.fetch("mode") == expected_before
  receipt["pre_call_join"] = pre_call
  native.fetch("call_receipts") << receipt
  receipt_appended = true

  errno_out = Fiddle::Pointer.malloc(4)
  capture_fail("#{label}:ERRNO_ALIGNMENT") unless
    (errno_out.to_i % 4).zero?
  errno_out[0, 4] = [0].pack("l<")
  capture_fail("#{label}:ERRNO_ZERO") unless errno_out[0, 4] == "\0\0\0\0"
  receipt["preparation_complete"] = true
  capture_fail("#{label}:TOTAL_BUDGET") if
    native.fetch("helper_call_attempts") >= 8
  capture_fail("#{label}:CLASS_BUDGET") if
    native.fetch(class_attempt_key) >= class_cap
  native["helper_call_attempts"] += 1
  native[class_attempt_key] += 1
  receipt["helper_entry_attempted"] = true
  receipt["helper_entry_classification"] =
    "CALL_ATTEMPT_RECORDED_NO_RETURN_OBSERVED"
  helper_return = native_function.call(
    target_fd, requested_mode, errno_out
  )
  helper_errno = errno_out[0, 4].unpack1("l<")
  receipt["helper_return"] = helper_return
  receipt["errno_out"] = helper_errno
  receipt["helper_entry_classification"] =
    "PROVEN_RUBY_TO_BUNDLE_ENTRY_BY_NORMAL_RETURN"
  receipt["helper_entry_proven"] = true
  native["helper_call_entries"] += 1
  native[class_entry_key] += 1
  if helper_return == 0
    receipt["native_fchmod_reached"] = true
    receipt["native_fchmod_reach_classification"] =
      "PROVEN_REACHED_LIBC_FCHMOD_AND_SUCCEEDED"
    native["native_fchmod_call_entries"] += 1
    native["native_fchmod_success_entries"] += 1
  elsif helper_return == -1
    receipt["native_fchmod_reached"] = true
    receipt["native_fchmod_reach_classification"] =
      "PROVEN_REACHED_LIBC_FCHMOD_BY_PREVALIDATED_ARGUMENTS"
    native["native_fchmod_call_entries"] += 1
  else
    receipt["native_fchmod_reach_classification"] =
      "UNPROVEN_ON_UNEXPECTED_FIXED_WRAPPER_RETURN"
  end
  capture_fail("#{label}:HELPER_RETURN:#{helper_return}:#{helper_errno}") unless
    helper_return == 0 && helper_errno == 0

  immediate = yield("IMMEDIATE_POST_CALL", expected_after)
  capture_fail("#{label}:IMMEDIATE_MODE") unless
    immediate.fetch("mode") == expected_after
  receipt["immediate_post_call_join"] = immediate
  receipt["target_sync"] = sync_io(target_io, "#{label}:TARGET_SYNC")
  post_sync = yield("POST_SYNC", expected_after)
  capture_fail("#{label}:POST_SYNC_MODE") unless
    post_sync.fetch("mode") == expected_after
  receipt["post_sync_join"] = post_sync
  receipt["transition_complete"] = true
  receipt
rescue StandardError => error
  if defined?(receipt) && receipt
    unless defined?(receipt_appended) && receipt_appended
      state.fetch("native_mode").fetch("call_receipts") << receipt
      receipt_appended = true
    end
    if receipt["helper_entry_attempted"] &&
        receipt["native_fchmod_reach_classification"].nil?
      receipt["native_fchmod_reach_classification"] =
        "UNPROVEN_NO_FIXED_WRAPPER_RETURN_OBSERVED"
    end
    if receipt["helper_entry_attempted"] &&
        !receipt["helper_entry_proven"] &&
        !receipt["unproven_helper_entry_attempt_counted"]
      state.fetch("native_mode")["unproven_helper_entry_attempts"] += 1
      receipt["unproven_helper_entry_attempt_counted"] = true
    end
    receipt["failure"] ||= failure_diagnostic(error, phase: label)
    if receipt["helper_entry_attempted"] && !receipt["transition_complete"] &&
        !receipt["failure_counted"]
      state.fetch("native_mode")["incomplete_transition_attempts"] += 1
      if receipt["helper_entry_proven"]
        state.fetch("native_mode")["failed_helper_entries"] += 1
      end
      receipt["failure_counted"] = true
    end
  end
  raise
end

def publish_leaf(state, native_function, parent_io, root_io, leaf, bytes)
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
  budget_class = leaf == "99-incomplete.json" ?
    "INCOMPLETE_99" : "ORDINARY_LEAF"
  native_mode_transition(
    state, native_function, io, "LEAF:#{leaf}", staging,
    "#{CAPTURE_ROOT}/#{staging}", 0o400, "PUBLISH:#{leaf}:MODE",
    budget_class, "0600", "0400"
  ) do |stage, expected_mode|
    rejoin_leaf(
      root_io, staging, io, "PUBLISH:#{leaf}:MODE:#{stage}"
    ).tap do |observed|
      capture_fail("PUBLISH:#{leaf}:MODE:#{stage}:EXPECTED") unless
        observed.fetch("mode") == expected_mode
    end
  end
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
  durable_prefix = final.merge("sha256" => Digest::SHA256.hexdigest(bytes))
  state.fetch("publication_durable_prefixes")[leaf] = durable_prefix

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
  capture_fail("PUBLISH:#{leaf}:DURABLE_PREFIX_DRIFT") unless
    reopened_after.merge("sha256" => Digest::SHA256.hexdigest(bytes)) ==
      durable_prefix
  durable_prefix
rescue StandardError
  close_io(reopened) if defined?(reopened)
  if defined?(io) && io
    close_io(io)
  elsif defined?(descriptor) && descriptor.is_a?(Integer) && descriptor >= 0
    close_raw_descriptor(descriptor)
  end
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
  elsif defined?(descriptor) && descriptor.is_a?(Integer) && descriptor >= 0 &&
      (!defined?(scan_io) || scan_io.nil?)
    close_raw_descriptor(descriptor)
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

def seal_root(state, native_function, parent_io, root_io, label,
              expected_names: nil, purpose:)
  capture_fail("#{label}:PURPOSE") unless
    %w[PRIMARY_ROOT CONTAINMENT_ROOT].include?(purpose)
  progress = state.fetch("root_seal_progress").fetch(purpose)
  capture_fail("#{label}:DUPLICATE_ATTEMPT") if progress.fetch("attempted")
  progress["attempted"] = true
  progress["terminal_completion"] = "IN_PROGRESS"
  native_mode_transition(
    state, native_function, root_io, "CAPTURE_ROOT", CAPTURE_ROOT_LEAF,
    CAPTURE_ROOT, 0o500, "#{label}:MODE", purpose, "0700", "0500"
  ) do |stage, expected_mode|
    rejoin_root(
      parent_io, root_io, "#{label}:MODE:#{stage}", mode: expected_mode
    )
  end
  progress["current_mode_observed"] = "0500"
  progress["mode_return_observed_success"] = true
  progress["mode_transition_complete"] = true
  progress["root_sync_complete"] = true
  sync_io(parent_io, "#{label}:PARENT")
  progress["parent_sync_complete"] = true
  rejoin_root(
    parent_io, root_io, "#{label}:PRE_SCAN", mode: "0500",
    nlink: expected_names ? 2 + expected_names.length : nil
  )
  inventory = descriptor_inventory(
    parent_io, root_io, "#{label}:INVENTORY",
    expected_names: expected_names
  )
  progress["inventory_complete"] = true
  capture_fail("#{label}:NAMES") if
    expected_names && inventory.fetch("names") != expected_names
  root = rejoin_root(
    parent_io, root_io, "#{label}:FINAL", mode: "0500",
    nlink: 2 + inventory.fetch("names").length
  )
  progress["terminal_completion"] = "COMPLETE"
  inventory.merge(
    "current_mode_observed" => root.fetch("mode"),
    "observation_order" =>
      "AFTER_MODE_ROOT_SYNC_PARENT_SYNC_AND_TERMINAL_INVENTORY",
    "observation_source" => "#{purpose}_SEAL_ROOT_RETURN",
    "parent_sync_complete" => true,
    "root" => root,
    "root_sync_complete" => true,
    "terminal_completion" => "COMPLETE",
    "terminal_purpose" => purpose
  )
rescue StandardError
  if defined?(progress) && progress
    receipt = state.fetch("native_mode").fetch("call_receipts").reverse.find do |entry|
      entry.is_a?(Hash) && entry["target_role"] == "CAPTURE_ROOT" &&
        entry["budget_class"] == purpose
    end
    if receipt
      progress["mode_return_observed_success"] =
        receipt["helper_return"] == 0 && receipt["errno_out"] == 0
      sync = receipt["target_sync"]
      progress["root_sync_complete"] =
        sync.is_a?(Hash) && sync["fsync"] == true &&
          sync["F_FULLFSYNC"] == true
      joined = receipt["post_sync_join"] ||
        receipt["immediate_post_call_join"]
      progress["current_mode_observed"] = joined["mode"] if
        joined.is_a?(Hash)
    end
    progress["terminal_completion"] = if
      progress["mode_return_observed_success"]
      "FAILED_AFTER_MODE_CHANGE"
    else
      "UNKNOWN_AFTER_ATTEMPT"
    end
  end
  raise
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

def outer_freeze_identity
  {
    "commit" => LIVE_FREEZE_COMMIT,
    "sha256" => LIVE_FREEZE_SHA256,
    "tree" => LIVE_FREEZE_TREE,
  }
end

def compact_vnode_signature_digest(value, label)
  signature = compact_vnode_signature(value, label)
  return nil if signature.nil?
  Digest::SHA256.hexdigest(canonical_json(signature))
end

def minimal_failure_reference(value, label)
  return nil if value.nil?
  capture_fail("#{label}:SHAPE") unless value.is_a?(Hash)
  {
    "error_class" => projection_string_identity(
      value["error_class"], "#{label}:CLASS"
    ),
    "error_message_bytes" => value["error_message_bytes"],
    "error_message_sha256" => value["error_message_sha256"],
    "phase" => projection_string_identity(
      value["phase"], "#{label}:PHASE"
    ),
  }
end

def emergency_native_mode(state)
  native = state.fetch("native_mode")
  receipts = native.fetch("call_receipts")
  capture_fail("EMERGENCY:NATIVE:RECEIPTS") unless
    receipts.is_a?(Array) && receipts.length <= 8
  {
    "call_receipts" => receipts.each_with_index.map do |receipt, index|
      label = "EMERGENCY:NATIVE:RECEIPT:#{index}"
      capture_fail("#{label}:SHAPE") unless receipt.is_a?(Hash)
      {
        "budget_class" => receipt["budget_class"],
        "errno_out" => receipt["errno_out"],
        "failure" => minimal_failure_reference(
          receipt["failure"], "#{label}:FAILURE"
        ),
        "fd" => receipt["fd"],
        "helper_entry_attempted" => receipt["helper_entry_attempted"],
        "helper_entry_classification" =>
          receipt["helper_entry_classification"],
        "helper_entry_proven" => receipt["helper_entry_proven"],
        "helper_return" => receipt["helper_return"],
        "immediate_post_call_vnode_sha256" =>
          compact_vnode_signature_digest(
            receipt["immediate_post_call_join"], "#{label}:IMMEDIATE"
          ),
        "native_fchmod_reach_classification" =>
          receipt["native_fchmod_reach_classification"],
        "native_fchmod_reached" => receipt["native_fchmod_reached"],
        "ordinal" => receipt["ordinal"],
        "post_sync_vnode_sha256" => compact_vnode_signature_digest(
          receipt["post_sync_join"], "#{label}:POST_SYNC"
        ),
        "pre_call_vnode_sha256" => compact_vnode_signature_digest(
          receipt["pre_call_join"], "#{label}:PRE_CALL"
        ),
        "relative_name" => projection_string_identity(
          receipt["relative_name"], "#{label}:RELATIVE_NAME"
        ),
        "requested_mode" => receipt["requested_mode"],
        "target_role" => projection_string_identity(
          receipt["target_role"], "#{label}:TARGET_ROLE"
        ),
        "transition_complete" => receipt["transition_complete"],
      }
    end,
    "failed_helper_entries" => native.fetch("failed_helper_entries"),
    "failed_helper_entries_semantics" =>
      "PROVEN_HELPER_ENTRIES_WITH_INCOMPLETE_TRANSITIONS",
    "helper_call_attempts" => native.fetch("helper_call_attempts"),
    "helper_call_entries" => native.fetch("helper_call_entries"),
    "helper_call_entries_semantics" =>
      "PROVEN_RUBY_TO_BUNDLE_ENTRIES_BY_NORMAL_WRAPPER_RETURN",
    "incomplete_transition_attempts" =>
      native.fetch("incomplete_transition_attempts"),
    "incomplete_99_helper_attempts" =>
      native.fetch("incomplete_99_helper_attempts"),
    "incomplete_99_helper_entries" =>
      native.fetch("incomplete_99_helper_entries"),
    "native_fchmod_call_entries" =>
      native.fetch("native_fchmod_call_entries"),
    "native_fchmod_call_entries_semantics" =>
      "PROVEN_LIBC_FCHMOD_REACH_BY_PREVALIDATED_NORMAL_RETURN",
    "native_fchmod_success_entries" =>
      native.fetch("native_fchmod_success_entries"),
    "next_ordinal" => native.fetch("next_ordinal"),
    "ordinary_leaf_helper_attempts" =>
      native.fetch("ordinary_leaf_helper_attempts"),
    "ordinary_leaf_helper_entries" =>
      native.fetch("ordinary_leaf_helper_entries"),
    "root_helper_attempts" => native.fetch("root_helper_attempts"),
    "root_helper_entries" => native.fetch("root_helper_entries"),
    "unproven_helper_entry_attempts" =>
      native.fetch("unproven_helper_entry_attempts"),
  }
end

def emergency_publication_outcomes(state)
  outcomes = state.fetch("publication_outcomes")
  OUTER_PUBLICATION_LEAVES.map do |leaf|
    outcome = outcomes[leaf]
    if outcome.nil?
      {
        "attempted" => state.fetch("publication_attempts").include?(leaf),
        "durability_proof_stage" => nil,
        "durable" => false,
        "failure" => minimal_failure_reference(
          state.fetch("publication_errors")[leaf],
          "EMERGENCY:PUBLICATION:#{leaf}:FAILURE_WITHOUT_OUTCOME"
        ),
        "first_possible_mode_ordinal" => nil,
        "identity" => nil,
        "last_observed_mode_ordinal" => nil,
        "leaf" => leaf,
        "verification_complete" => false,
      }
    else
      capture_fail("EMERGENCY:PUBLICATION:#{leaf}:SHAPE") unless
        outcome.is_a?(Hash)
      {
        "attempted" => outcome["attempted"],
        "durable" => outcome["durable"],
        "failure" => minimal_failure_reference(
          outcome["failure"], "EMERGENCY:PUBLICATION:#{leaf}:FAILURE"
        ),
        "first_possible_mode_ordinal" =>
          outcome["first_possible_mode_ordinal"],
        "durability_proof_stage" => outcome["durability_proof_stage"],
        "identity" => compact_leaf_identity(
          outcome["leaf"], "EMERGENCY:PUBLICATION:#{leaf}:IDENTITY"
        ),
        "last_observed_mode_ordinal" =>
          outcome["last_observed_mode_ordinal"],
        "leaf" => leaf,
        "verification_complete" => outcome["verification_complete"],
      }
    end
  end
end

def emergency_outer_frame(state, primary_error, frame_error, root_state)
  record = {
    "bundle_and_native_evidence" => {
      "bundle_runtime" => compact_bundle_runtime(state),
      "native_mode" => emergency_native_mode(state),
    },
    "capture_root" => CAPTURE_ROOT,
    "classification" => "INFRASTRUCTURE_INCOMPLETE",
    "containment" => compact_containment_state(state),
    "consumption" => "CONSUMED_NO_RETRY",
    "freeze_identity" => outer_freeze_identity,
    "normal_projection_error" => minimal_failure_reference(
      frame_error, "EMERGENCY:FRAME_ERROR"
    ),
    "primary_error" => minimal_failure_reference(
      primary_error, "EMERGENCY:PRIMARY_ERROR"
    ),
    "publication_outcomes" => emergency_publication_outcomes(state),
    "root_state" => compact_root_state(root_state, "EMERGENCY:ROOT_STATE"),
    "runner_source_identity" => "EXTERNAL_FINAL_READINESS_BINDING",
    "schema" => "ergentics-r19-obs11-c2-prefix-capture-emergency-outer-v9",
    "status" => "CONSUMED_EMERGENCY_OUTER_RETAINED_NO_RETRY",
  }
  canonical_frame(record, OUTER_SUMMARY_CAP, "OUTER_INCOMPLETE_EMERGENCY")
rescue StandardError
  ABSOLUTE_EMERGENCY_OUTER_BYTES
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
  outcome = state.fetch("publication_outcomes")[leaf]
  if outcome
    {
      "attempted" => outcome.fetch("attempted"),
      "durability_proof_stage" => outcome["durability_proof_stage"],
      "durable" => outcome.fetch("durable"),
      "failure" => outcome["failure"],
      "leaf" => outcome["leaf"],
      "verification_complete" => outcome.fetch("verification_complete"),
    }
  else
    {
      "attempted" => state.fetch("publication_attempts").include?(leaf),
      "durability_proof_stage" => nil,
      "durable" => false,
      "failure" => state.fetch("publication_errors")[leaf],
      "leaf" => nil,
      "verification_complete" => false,
    }
  end
end

def publication_verified?(state, leaf)
  outcome = state.fetch("publication_outcomes")[leaf]
  outcome.is_a?(Hash) && outcome["durable"] == true &&
    outcome["verification_complete"] == true &&
    state.fetch("durable_leaves").key?(leaf)
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

def attempt_publication(state, native_function, parent_io, root_io, leaf, bytes)
  first_ordinal = nil
  return state.fetch("publication_outcomes")[leaf] if
    state.fetch("publication_attempts").include?(leaf)
  state.fetch("publication_attempts") << leaf
  first_ordinal = state.fetch("native_mode").fetch("next_ordinal")
  durable = publish_leaf(
    state, native_function, parent_io, root_io, leaf, bytes
  )
  capture_fail("PUBLICATION:#{leaf}:DURABLE_PREFIX") unless
    state.fetch("publication_durable_prefixes")[leaf] == durable
  state.fetch("durable_leaves")[leaf] = durable
  state.fetch("publication_outcomes")[leaf] = {
    "attempted" => true,
    "durability_proof_stage" =>
      "FINAL_NAME_VNODE_JOIN_THEN_ROOT_FSYNC_AND_FULLFSYNC",
    "durable" => true,
    "first_possible_mode_ordinal" => first_ordinal,
    "last_observed_mode_ordinal" =>
      state.fetch("native_mode").fetch("next_ordinal") - 1,
    "leaf" => durable,
    "verification_complete" => true,
  }
rescue StandardError => error
  diagnostic = failure_diagnostic(error, phase: state.fetch("phase"))
  state.fetch("publication_errors")[leaf] = diagnostic
  durable_prefix = state.fetch("publication_durable_prefixes")[leaf]
  state.fetch("durable_leaves")[leaf] = durable_prefix if durable_prefix
  state.fetch("publication_outcomes")[leaf] = {
    "attempted" => true,
    "durability_proof_stage" => durable_prefix ?
      "FINAL_NAME_VNODE_JOIN_THEN_ROOT_FSYNC_AND_FULLFSYNC" : nil,
    "durable" => !durable_prefix.nil?,
    "failure" => diagnostic,
    "first_possible_mode_ordinal" => first_ordinal,
    "last_observed_mode_ordinal" =>
      state.fetch("native_mode").fetch("next_ordinal") - 1,
    "leaf" => durable_prefix,
    "verification_complete" => false,
  }
end

def require_parent_nlink(parent_io, expected, label)
  observed = rejoin_parent(parent_io, label)
  capture_fail("#{label}:NLINK:#{observed.fetch('nlink')}:#{expected}") unless
    observed.fetch("nlink") == expected
  observed
end

def compact_root_seal_progress(state)
  progress = state.fetch("root_seal_progress")
  %w[CONTAINMENT_ROOT PRIMARY_ROOT].each_with_object({}) do |purpose, result|
    receipt = progress.fetch(purpose)
    result[purpose] = %w[
      attempted current_mode_observed inventory_complete
      mode_return_observed_success mode_transition_complete
      parent_sync_complete root_sync_complete terminal_completion
    ].each_with_object({}) do |field, fields|
      fields[field] = receipt.fetch(field)
    end
  end
end

def compact_containment_state(state)
  containment_keys = %w[
    bundle_final_mapping_error bundle_final_revalidation_error
    containment_outer_error
    incomplete_99_construction_error incomplete_terminal
    incomplete_terminal_error native_budget_error
    post99_writable_check_error postcontainment_scan_error
    root_recovery_error root_writable_check_error
  ]
  containment = containment_keys.each_with_object({}) do |key, result|
    next unless state.key?(key)
    result[key] = if key == "incomplete_terminal"
      compact_root_state(state[key], "OUTER:CONTAINMENT:TERMINAL")
    else
      compact_failure_diagnostic(
        state[key], "OUTER:CONTAINMENT:#{key}"
      )
    end
  end
  containment["root_seal_progress"] = compact_root_seal_progress(state)
  containment
end

def outer_failure_record(state, error_receipt, root_state, classification:)
  capture_fail("OUTER:CLASSIFICATION") unless
    %w[SCIENTIFIC_FAILURE INFRASTRUCTURE_INCOMPLETE].include?(classification)
  evidence = outer_runtime_evidence_snapshot(state)
  publications = require_projection_component(
    compact_publication_outcomes(state), OUTER_PUBLICATION_COMPONENT_CAP,
    "OUTER:PUBLICATION_COMPONENT"
  )
  root = require_projection_component(
    compact_root_state(root_state, "OUTER:ROOT_STATE"),
    OUTER_TERMINAL_COMPONENT_CAP, "OUTER:TERMINAL_COMPONENT"
  )
  error_and_containment = require_projection_component(
    {
      "containment" => compact_containment_state(state),
      "error" => compact_failure_diagnostic(
        error_receipt, "OUTER:PRIMARY_ERROR", prefix_bytes: 128
      ),
    },
    OUTER_ERROR_CONTAINMENT_COMPONENT_CAP,
    "OUTER:ERROR_CONTAINMENT_COMPONENT"
  )
  fixed = require_projection_component(
    {
    "capture_root" => CAPTURE_ROOT,
    "classification" => classification,
    "consumption" => "CONSUMED_NO_RETRY",
    "freeze_identity" => outer_freeze_identity,
    "runner_source_identity" => "EXTERNAL_FINAL_READINESS_BINDING",
    "runner_status" => "FAIL_CAPTURE_RUNNER_CONSUMED_NO_RETRY",
    "schema" => "ergentics-r19-obs11-c2-prefix-capture-outer-failure-v9",
    },
    OUTER_FAILURE_FIXED_OVERHEAD_MAX, "OUTER:FAILURE_FIXED_OVERHEAD"
  )
  fixed.merge(
    "bundle_and_native_evidence" => evidence,
    "containment" => error_and_containment.fetch("containment"),
    "error" => error_and_containment.fetch("error"),
    "publication_outcomes" => publications,
    "root_state" => root
  )
end

def root_inventory_observation?(value)
  value.is_a?(Hash) && value["root"].is_a?(Hash) &&
    value["names"].is_a?(Array) &&
    value["manifest_sha256"].is_a?(String)
end

def latest_root_mode_epistemic_state(state, budget_class:)
  receipt = state.fetch("native_mode").fetch("call_receipts").reverse.find do |entry|
    entry.is_a?(Hash) && entry["target_role"] == "CAPTURE_ROOT" &&
      entry["budget_class"] == budget_class &&
      entry["helper_entry_attempted"] == true
  end
  return nil unless receipt
  progress = state.fetch("root_seal_progress").fetch(budget_class)
  join_label, join = if receipt["post_sync_join"].is_a?(Hash)
    ["POST_SYNC", receipt["post_sync_join"]]
  elsif receipt["immediate_post_call_join"].is_a?(Hash)
    ["IMMEDIATE_POST_CALL", receipt["immediate_post_call_join"]]
  else
    [nil, nil]
  end
  if join
    {
      "mode_call_ordinal" => receipt["ordinal"],
      "mode_call_reach_classification" =>
        receipt["native_fchmod_reach_classification"],
      "current_mode_observed" => join["mode"],
      "observation_order" => "AFTER_ATTEMPTED_MODE_CALL",
      "observation_source" => "#{budget_class}_MODE_CALL_RECEIPT",
      "parent_sync_complete" => progress["parent_sync_complete"],
      "root" => join,
      "root_sync_complete" => progress["root_sync_complete"],
      "status" =>
        "CURRENT_ROOT_FROM_#{budget_class}_#{join_label}_MODE_CALL_JOIN",
      "terminal_completion" => progress["terminal_completion"],
      "terminal_purpose" => budget_class,
    }
  else
    {
      "mode_call_ordinal" => receipt["ordinal"],
      "mode_call_reach_classification" =>
        receipt["native_fchmod_reach_classification"],
      "current_mode_observed" => nil,
      "observation_order" => "AFTER_ATTEMPTED_MODE_CALL",
      "observation_source" => "#{budget_class}_MODE_CALL_RECEIPT",
      "parent_sync_complete" => progress["parent_sync_complete"],
      "root" => nil,
      "root_sync_complete" => progress["root_sync_complete"],
      "status" =>
        "CURRENT_ROOT_STATE_UNKNOWN_AFTER_ATTEMPTED_#{budget_class}_MODE_CALL",
      "terminal_completion" => progress["terminal_completion"],
      "terminal_purpose" => budget_class,
    }
  end
end

def latest_attempted_root_seal_progress(state)
  progress = state.fetch("root_seal_progress")
  purpose = %w[CONTAINMENT_ROOT PRIMARY_ROOT].find do |candidate|
    progress.fetch(candidate).fetch("attempted")
  end
  [purpose, purpose && progress.fetch(purpose)]
end

def joined_root_epistemic_state(value, status, source, state)
  return nil unless value.is_a?(Hash)
  purpose, progress = latest_attempted_root_seal_progress(state)
  {
    "current_mode_observed" => value["mode"],
    "observation_order" => source,
    "observation_source" => source,
    "parent_sync_complete" => progress && progress["parent_sync_complete"],
    "root" => value,
    "root_sync_complete" => progress && progress["root_sync_complete"],
    "status" => status,
    "terminal_completion" => progress ?
      progress.fetch("terminal_completion") : "NOT_ATTEMPTED",
    "terminal_purpose" => purpose,
  }
end

def typed_postcontainment_root_state(state, inventory)
  purpose, progress = latest_attempted_root_seal_progress(state)
  root = inventory.fetch("root")
  inventory.merge(
    "current_mode_observed" => root.fetch("mode"),
    "observation_order" =>
      "AFTER_CONTAINMENT_STAGE_BEFORE_BUILD_A_FINAL_REVALIDATION",
    "observation_source" =>
      "INCOMPLETE_POSTCONTAINMENT_DESCRIPTOR_INVENTORY",
    "parent_sync_complete" => progress && progress["parent_sync_complete"],
    "root_sync_complete" => progress && progress["root_sync_complete"],
    "terminal_completion" => progress ?
      progress.fetch("terminal_completion") : "NOT_ATTEMPTED",
    "terminal_purpose" => purpose
  )
end

def known_outer_root_state(state, postcontainment, pre99)
  return postcontainment if root_inventory_observation?(postcontainment)
  incomplete_terminal = state["incomplete_terminal"]
  return incomplete_terminal if root_inventory_observation?(incomplete_terminal)
  terminal = state["terminal_root_state"]
  return terminal if root_inventory_observation?(terminal)
  containment_mode = latest_root_mode_epistemic_state(
    state, budget_class: "CONTAINMENT_ROOT"
  )
  return containment_mode if containment_mode
  post99 = joined_root_epistemic_state(
    state["post99_writable_observation"],
    "CURRENT_ROOT_FROM_POST99_WRITABLE_DESCRIPTOR_JOIN",
    "POST99_WRITABLE_DESCRIPTOR_JOIN", state
  )
  return post99 if post99
  writable = joined_root_epistemic_state(
    state["root_writable_observation"],
    "CURRENT_ROOT_FROM_PRE99_WRITABLE_DESCRIPTOR_JOIN",
    "PRE99_WRITABLE_DESCRIPTOR_JOIN", state
  )
  return writable if writable
  return pre99 if root_inventory_observation?(pre99)
  primary_mode = latest_root_mode_epistemic_state(
    state, budget_class: "PRIMARY_ROOT"
  )
  return primary_mode if primary_mode
  return nil unless state.fetch("root_created")
  {
    "root_created_by_successful_mkdirat" => true,
    "root_descriptor_observation" => nil,
    "root_recovery_error" => state["root_recovery_error"],
    "status" => "CREATED_ROOT_CURRENT_DESCRIPTOR_JOIN_UNAVAILABLE",
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

def initial_build_a_descriptor_lifecycle
  %w[bundle object private_tmp root].each_with_object({}) do |role, result|
    result[role] = {
      "close_attempts" => 0,
      "close_completed" => false,
      "close_errors" => [],
      "closed_observed_immediately_after_failed_attempt" => false,
      "fd_at_open" => nil,
      "opened" => false,
    }
  end
end

def initial_root_seal_progress
  %w[CONTAINMENT_ROOT PRIMARY_ROOT].each_with_object({}) do |purpose, result|
    result[purpose] = {
      "attempted" => false,
      "current_mode_observed" => nil,
      "inventory_complete" => false,
      "mode_return_observed_success" => false,
      "mode_transition_complete" => false,
      "parent_sync_complete" => false,
      "root_sync_complete" => false,
      "terminal_completion" => "NOT_ATTEMPTED",
    }
  end
end

def close_build_a_descriptors(state, parent_io, root_io, object_io, bundle_io)
  runtime = state.fetch("bundle_runtime")
  errors = runtime.fetch("descriptor_close_errors")
  lifecycle = runtime.fetch("descriptor_lifecycle")
  [
    ["bundle", bundle_io], ["object", object_io], ["root", root_io],
    ["private_tmp", parent_io],
  ].each do |label, io|
    next if io.nil? || io.closed?
    receipt = lifecycle.fetch(label)
    receipt["close_attempts"] += 1
    error = close_io(io)
    if error
      receipt.fetch("close_errors") << error
      receipt["closed_observed_immediately_after_failed_attempt"] = io.closed?
      errors[label] ||= error
    else
      receipt["close_completed"] = true
    end
  end
  errors
end

state = {
  "active_staging" => [],
  "admission" => nil,
  "bundle_runtime" => {
    "build_a_admission" => nil,
    "descriptor_close_errors" => {},
    "descriptor_lifecycle" => initial_build_a_descriptor_lifecycle,
    "dlopen_attempts" => 0,
    "dlsym_attempts" => 0,
    "final_revalidation" => nil,
    "final_revalidation_attempts" => 0,
    "handle_close_disabled" => false,
    "mapping_attempts" => 0,
    "mapping_completed" => 0,
    "mapping_receipts" => [],
    "postload_revalidation" => nil,
    "preload_revalidation" => nil,
  },
  "channels" => {
    "stderr" => unavailable_channel_receipt(capture_started: false),
    "stdout" => unavailable_channel_receipt(capture_started: false),
  },
  "child" => nil,
  "durable_leaves" => {},
  "phase" => "RUNNER_ENTERED",
  "publication_attempts" => [],
  "publication_durable_prefixes" => {},
  "publication_errors" => {},
  "publication_outcomes" => {},
  "native_mode" => {
    "call_receipts" => [],
    "failed_helper_entries" => 0,
    "failed_helper_entries_semantics" =>
      "PROVEN_HELPER_ENTRIES_WITH_INCOMPLETE_TRANSITIONS",
    "helper_call_attempts" => 0,
    "helper_call_entries" => 0,
    "helper_call_entries_semantics" =>
      "PROVEN_RUBY_TO_BUNDLE_ENTRIES_BY_NORMAL_WRAPPER_RETURN",
    "incomplete_transition_attempts" => 0,
    "incomplete_99_helper_attempts" => 0,
    "incomplete_99_helper_entries" => 0,
    "native_fchmod_call_entries" => 0,
    "native_fchmod_call_entries_semantics" =>
      "PROVEN_LIBC_FCHMOD_REACH_BY_PREVALIDATED_NORMAL_RETURN",
    "native_fchmod_success_entries" => 0,
    "next_ordinal" => 1,
    "ordinary_leaf_helper_attempts" => 0,
    "ordinary_leaf_helper_entries" => 0,
    "root_helper_attempts" => 0,
    "root_helper_entries" => 0,
    "unproven_helper_entry_attempts" => 0,
  },
  "root_created" => false,
  "root_seal_progress" => initial_root_seal_progress,
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
build_a_parent_io = nil
build_a_root_io = nil
build_a_object_io = nil
build_a_bundle_io = nil
native_handle = nil
native_function = nil
native_symbol_address = nil
runtime_owner = {}

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
  capture_fail("OUTER_FAILURE_ADDITIVE_BOUND") unless
    OUTER_FAILURE_ADDITIVE_MAX == OUTER_SUMMARY_CAP
  capture_fail("OUTER_PASS_ADDITIVE_BOUND") unless
    OUTER_PASS_ADDITIVE_MAX == OUTER_SUMMARY_CAP
  capture_fail("UID") unless Process.uid == 501 && Process.euid == 501
  capture_fail("GID") unless Process.gid == 20 && Process.egid == 20
  capture_fail("GROUPS") unless Process.groups.sort == EXPECTED_GROUPS
  incoming_umask = File.umask(0o077)

  state["phase"] = "BUILD_A_ADMISSION"
  build_a_parent_io, build_a_root_io, build_a_object_io, build_a_bundle_io,
    build_a_admission = admit_build_a(state)
  runtime_owner["build_a_parent_io"] = build_a_parent_io
  runtime_owner["build_a_root_io"] = build_a_root_io
  runtime_owner["build_a_object_io"] = build_a_object_io
  runtime_owner["build_a_bundle_io"] = build_a_bundle_io
  state.fetch("bundle_runtime")["build_a_admission"] = build_a_admission

  state["phase"] = "BUILD_A_LOAD_AND_MAPPING"
  native_handle, native_function, native_symbol_address = load_build_a_bundle(
    state, runtime_owner, build_a_parent_io, build_a_root_io,
    build_a_object_io, build_a_bundle_io
  )
  capture_fail("BUILD_A_RUNTIME_OWNERSHIP") unless
    runtime_owner.fetch("handle") == native_handle &&
      runtime_owner.fetch("function") == native_function &&
      runtime_owner.fetch("symbol_address") == native_symbol_address

  state["phase"] = "CAPTURE_PARENT_ADMISSION"
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
    "live_freeze_commit" => LIVE_FREEZE_COMMIT,
    "live_freeze_sha256" => LIVE_FREEZE_SHA256,
    "live_freeze_tree" => LIVE_FREEZE_TREE,
    "fd3_reason" => "CONTROLLED_HELD_HARNESS_SOURCE_TRANSPORT",
    "harness_sha256" => HARNESS_EXPECTED.fetch("sha256"),
    "incoming_umask" => format("%04o", incoming_umask),
    "parent" => parent_after,
    "root" => root_initial,
    "runner_pid" => Process.pid,
    "runner_ppid" => Process.ppid,
    "runner_source_identity" => "EXTERNAL_FINAL_READINESS_BINDING",
    "runtime_evidence_before_self_seal" => runtime_evidence_snapshot(state),
    "schema" => "ergentics-r19-obs11-c2-prefix-capture-start-v9",
    "status" => "START_DURABLE_BEFORE_HARNESS_ADMISSION_OR_CHILD_SPAWN",
    "static_bundle_outer_sha256" => STATIC_BUNDLE_OUTER_SHA256,
    "static_bundle_result_sha256" => STATIC_BUNDLE_RESULT_SHA256,
  }
  attempt_publication(
    state, native_function, parent_io, root_io, "00-start.json",
    canonical_frame(start, INCOMPLETE_LEAF_CAP, "START")
  )
  capture_fail("START_NOT_VERIFIED") unless
    publication_verified?(state, "00-start.json")
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
    state, native_function, parent_io, root_io, "01-stdout.bin",
    stdout_capture.fetch("retained")
  )
  attempt_publication(
    state, native_function, parent_io, root_io, "02-stderr.bin",
    stderr_capture.fetch("retained")
  )
  attach_raw_publication_state(state)
  capture_fail("RAW_PUBLICATION_INCOMPLETE") unless
    %w[01-stdout.bin 02-stderr.bin].all? do |leaf|
      publication_verified?(state, leaf)
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
    "runtime_evidence_before_self_seal" => runtime_evidence_snapshot(state),
    "schema" => "ergentics-r19-obs11-c2-prefix-capture-result-v9",
    "signals" => 0,
    "start_leaf" => state.fetch("durable_leaves").fetch("00-start.json"),
    "status" => admitted ?
      "PASS_CAPTURED_EXACT_NONCONSUMING_PREFIX_V9" :
      "FAIL_CAPTURED_PREFIX_V9_CONSUMED_NO_RETRY",
  }
  state["phase"] = "RESULT_PUBLICATION"
  attempt_publication(
    state, native_function, parent_io, root_io, "03-result.json",
    canonical_frame(result, INCOMPLETE_LEAF_CAP, "RESULT")
  )
  capture_fail("RESULT_NOT_VERIFIED") unless
    publication_verified?(state, "03-result.json")
  require_parent_nlink(parent_io, state.fetch("parent_nlink"), "RESULT:PARENT")

  unless admitted
    state["phase"] = "CAPTURED_SCIENTIFIC_FAILURE_TERMINAL"
    failure_names = SUCCESS_INVENTORY.first(4)
    terminal = seal_root(
      state, native_function, parent_io, root_io, "SCIENTIFIC_FAILURE",
      expected_names: failure_names, purpose: "PRIMARY_ROOT"
    )
    state["terminal_root_state"] = terminal
    require_native_budgets(
      state, "SCIENTIFIC_FAILURE", "SCIENTIFIC_FAILURE:BUDGET"
    )
    finalize_build_a(
      state, native_symbol_address, build_a_parent_io, build_a_root_io,
      build_a_object_io, build_a_bundle_io, "SCIENTIFIC_FAILURE"
    )
    build_close_errors = close_build_a_descriptors(
      state, build_a_parent_io, build_a_root_io, build_a_object_io,
      build_a_bundle_io
    )
    capture_fail("SCIENTIFIC_FAILURE:BUILD_A_CLOSE") unless
      build_close_errors.empty?
    diagnostic = failure_diagnostic(
      C2PrefixCaptureFailure.new("SCIENTIFIC:#{admission_code}"),
      phase: state.fetch("phase")
    )
    outer = outer_failure_record(
      state, diagnostic, terminal, classification: "SCIENTIFIC_FAILURE"
    )
    outer_bytes = canonical_frame(
      outer, OUTER_SUMMARY_CAP, "OUTER_FAILURE"
    )
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
    "runtime_evidence_before_self_seal" => runtime_evidence_snapshot(state),
    "schema" => "ergentics-r19-obs11-c2-prefix-capture-closure-v9",
    "status" => "PASS_CLOSURE_FOR_EXACT_NONCONSUMING_PREFIX_V9",
  }
  attempt_publication(
    state, native_function, parent_io, root_io, "04-closure.json",
    canonical_frame(closure, INCOMPLETE_LEAF_CAP, "CLOSURE")
  )
  capture_fail("CLOSURE_NOT_VERIFIED") unless
    publication_verified?(state, "04-closure.json")
  preseal = descriptor_inventory(
    parent_io, root_io, "PRESEAL", expected_names: SUCCESS_INVENTORY
  )
  state["phase"] = "PASS_TERMINAL"
  terminal = seal_root(
    state, native_function, parent_io, root_io, "PASS_TERMINAL",
    expected_names: SUCCESS_INVENTORY, purpose: "PRIMARY_ROOT"
  )
  state["terminal_root_state"] = terminal
  capture_fail("TERMINAL_MANIFEST_DRIFT") unless
    terminal.fetch("manifest_sha256") ==
      preseal.fetch("manifest_sha256")
  require_parent_nlink(
    parent_io, state.fetch("parent_nlink"), "PASS_TERMINAL:PARENT"
  )
  require_native_budgets(state, "PASS", "PASS_TERMINAL:BUDGET")
  finalize_build_a(
    state, native_symbol_address, build_a_parent_io, build_a_root_io,
    build_a_object_io, build_a_bundle_io, "PASS_TERMINAL"
  )
  build_close_errors = close_build_a_descriptors(
    state, build_a_parent_io, build_a_root_io, build_a_object_io,
    build_a_bundle_io
  )
  capture_fail("PASS_TERMINAL:BUILD_A_CLOSE") unless build_close_errors.empty?
  pass_evidence = outer_runtime_evidence_snapshot(state)
  pass_publications = require_projection_component(
    compact_publication_outcomes(state), OUTER_PUBLICATION_COMPONENT_CAP,
    "OUTER_PASS:PUBLICATION_COMPONENT"
  )
  pass_terminal = require_projection_component(
    compact_root_state(terminal, "OUTER_PASS:TERMINAL"),
    OUTER_TERMINAL_COMPONENT_CAP, "OUTER_PASS:TERMINAL_COMPONENT"
  )
  pass_fixed = require_projection_component(
    {
      "capture_root" => CAPTURE_ROOT,
      "classification" => "PASS",
      "closure_leaf" => compact_leaf_identity(
        terminal.fetch("entries").fetch("04-closure.json"),
        "OUTER_PASS:CLOSURE_LEAF"
      ),
      "final_inventory" => terminal.fetch("names"),
      "final_inventory_manifest_sha256" =>
        terminal.fetch("manifest_sha256"),
      "final_root" => pass_terminal.fetch("root"),
      "freeze_identity" => outer_freeze_identity,
      "runner_status" => "PASS_DURABLE_CAPTURE_RUNNER_COMPLETED",
      "runner_source_identity" => "EXTERNAL_FINAL_READINESS_BINDING",
      "schema" => "ergentics-r19-obs11-c2-prefix-capture-outer-summary-v9",
      "scientific_status" => "PASS_CAPTURED_EXACT_NONCONSUMING_PREFIX_V9",
    },
    OUTER_PASS_FIXED_OVERHEAD_MAX, "OUTER_PASS:FIXED_OVERHEAD"
  )
  summary = pass_fixed.merge(
    "bundle_and_native_evidence" => pass_evidence,
    "publication_outcomes" => pass_publications,
    "root_state" => pass_terminal
  )
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
  outer_bytes = ABSOLUTE_EMERGENCY_OUTER_BYTES
  diagnostic = nil
  outer_root_state = nil
  postcontainment = nil
  pre99 = nil
  begin
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
      state, native_function, parent_io, root_io, "01-stdout.bin",
      stdout_capture.fetch("retained")
    )
  end
  if root_io && stderr_capture
    attempt_publication(
      state, native_function, parent_io, root_io, "02-stderr.bin",
      stderr_capture.fetch("retained")
    )
  end
  attach_raw_publication_state(state)

  diagnostic = failure_diagnostic(
    primary_error, phase: state.fetch("phase_at_failure")
  )
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
  root_writable = begin
    if root_io && !root_io.closed?
      state["root_writable_observation"] = rejoin_root(
        parent_io, root_io, "INCOMPLETE_WRITABLE_CHECK", mode: "0700"
      )
      true
    else
      false
    end
  rescue StandardError => writable_error
    state["root_writable_check_error"] = failure_diagnostic(
      writable_error, phase: "INCOMPLETE_WRITABLE_CHECK"
    )
    false
  end
  if root_writable
    begin
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
        "inventory" => pre99,
        "outer_summary" => {
          "state_at_99_construction" =>
            "PENDING_UNOBSERVED_UNTIL_AFTER_99_AND_CONTAINMENT_ATTEMPTS",
        },
        "root" => {
          "mode_before_99" => mode_string(root_io.stat),
          "observed_pre99" => pre99 && pre99["root"],
          "seal_attempted_at_99_construction" => false,
          "seal_state_at_99_construction" =>
            "PENDING_AFTER_NON_SELF_HASHING_99_PUBLICATION",
          "sync_and_rejoin_required_after_99" => true,
        },
        "runtime_evidence_before_self_seal" => runtime_evidence_snapshot(state),
        "schema" => "ergentics-r19-obs11-c2-prefix-capture-incomplete-v9",
        "status" => "CONSUMED_INCOMPLETE_NO_RETRY",
      }
      incomplete_bytes = canonical_frame(
        incomplete, INCOMPLETE_LEAF_CAP, "INCOMPLETE"
      )
      attempt_publication(
        state, native_function, parent_io, root_io, "99-incomplete.json",
        incomplete_bytes
      )
    rescue StandardError => incomplete_error
      state["incomplete_99_construction_error"] = failure_diagnostic(
        incomplete_error, phase: "INCOMPLETE_99_CONSTRUCTION"
      )
    end
    containment_writable = begin
      state["post99_writable_observation"] = rejoin_root(
        parent_io, root_io, "INCOMPLETE_POST99_WRITABLE", mode: "0700"
      )
      true
    rescue StandardError => post99_error
      state["post99_writable_check_error"] = failure_diagnostic(
        post99_error, phase: "INCOMPLETE_POST99_WRITABLE"
      )
      false
    end
    if containment_writable
      begin
        state["incomplete_terminal"] = seal_root(
          state, native_function, parent_io, root_io, "INCOMPLETE_TERMINAL",
          purpose: "CONTAINMENT_ROOT"
        )
      rescue StandardError => terminal_error
        state["incomplete_terminal_error"] = failure_diagnostic(
          terminal_error, phase: "INCOMPLETE_TERMINAL"
        )
      end
    end
  end

  if root_io && !root_io.closed?
    begin
      postcontainment = descriptor_inventory(
        parent_io, root_io, "INCOMPLETE_POSTCONTAINMENT"
      )
      postcontainment = typed_postcontainment_root_state(
        state, postcontainment
      )
    rescue StandardError => postcontainment_error
      state["postcontainment_scan_error"] = failure_diagnostic(
        postcontainment_error, phase: "INCOMPLETE_POSTCONTAINMENT"
      )
    end
  end

  containment_symbol_address =
    native_symbol_address || runtime_owner["symbol_address"]
  if state.fetch("bundle_runtime").fetch("mapping_completed") == 1 &&
      state.fetch("bundle_runtime").fetch("mapping_attempts") < 2 &&
      containment_symbol_address
    begin
      mapped_build_a_identity(
        state, containment_symbol_address, "INCOMPLETE:MAPPING_FINAL"
      )
    rescue StandardError => mapping_error
      state["bundle_final_mapping_error"] = failure_diagnostic(
        mapping_error, phase: "INCOMPLETE:MAPPING_FINAL"
      )
    end
  end
  if state.fetch("bundle_runtime").fetch("mapping_completed").positive? &&
      state.fetch("bundle_runtime").fetch("final_revalidation_attempts").zero? &&
      [build_a_parent_io, build_a_root_io, build_a_object_io,
       build_a_bundle_io].all? { |io| io && !io.closed? }
    begin
      state.fetch("bundle_runtime")["final_revalidation_attempts"] += 1
      state.fetch("bundle_runtime")["final_revalidation"] =
        revalidate_build_a(
          build_a_parent_io, build_a_root_io, build_a_object_io,
          build_a_bundle_io, "INCOMPLETE:BUILD_A_FINAL"
        )
    rescue StandardError => build_error
      state["bundle_final_revalidation_error"] = failure_diagnostic(
        build_error, phase: "INCOMPLETE:BUILD_A_FINAL"
      )
    end
  end
  close_build_a_descriptors(
    state, build_a_parent_io, build_a_root_io, build_a_object_io,
    build_a_bundle_io
  )
  begin
    require_native_budgets(state, "INFRASTRUCTURE", "INCOMPLETE:BUDGET")
  rescue StandardError => budget_error
    state["native_budget_error"] = failure_diagnostic(
      budget_error, phase: "INCOMPLETE:BUDGET"
    )
  end

  outer_root_state = known_outer_root_state(state, postcontainment, pre99)
  begin
    outer = outer_failure_record(
      state, diagnostic, outer_root_state,
      classification: "INFRASTRUCTURE_INCOMPLETE"
    )
    outer_bytes = canonical_frame(
      outer, OUTER_SUMMARY_CAP, "OUTER_INCOMPLETE"
    )
  rescue StandardError => outer_frame_error
    state["outer_frame_error"] = failure_diagnostic(
      outer_frame_error, phase: "OUTER_INCOMPLETE_FRAME"
    )
    outer_bytes = emergency_outer_frame(
      state, diagnostic, state.fetch("outer_frame_error"), outer_root_state
    )
  end
  rescue StandardError => containment_outer_error
    begin
      diagnostic ||= failure_diagnostic(
        primary_error, phase: state["phase_at_failure"]
      )
      state["containment_outer_error"] = failure_diagnostic(
        containment_outer_error, phase: "INCOMPLETE_CONTAINMENT_OUTER"
      )
      outer_root_state ||= known_outer_root_state(
        state, postcontainment, pre99
      )
      outer_bytes = emergency_outer_frame(
        state, diagnostic, state.fetch("containment_outer_error"),
        outer_root_state
      )
    rescue StandardError
      outer_bytes = ABSOLUTE_EMERGENCY_OUTER_BYTES
    end
  ensure
    [harness_io, root_io, parent_io].each { |io| close_io(io) }
    begin
      write_all(STDERR, outer_bytes, "OUTER_INCOMPLETE_WRITE")
    rescue StandardError
      nil
    end
  end
  exit(70)
ensure
  ensure_symbol_address = native_symbol_address || runtime_owner["symbol_address"]
  if state.fetch("bundle_runtime").fetch("mapping_completed") == 1 &&
      state.fetch("bundle_runtime").fetch("mapping_attempts") < 2 &&
      ensure_symbol_address
    begin
      mapped_build_a_identity(
        state, ensure_symbol_address, "ENSURE:MAPPING_FINAL"
      )
    rescue StandardError
      nil
    end
  end
  if state.fetch("bundle_runtime").fetch("mapping_completed").positive? &&
      state.fetch("bundle_runtime").fetch("final_revalidation_attempts").zero? &&
      [build_a_parent_io, build_a_root_io, build_a_object_io,
       build_a_bundle_io].all? { |io| io && !io.closed? }
    begin
      state.fetch("bundle_runtime")["final_revalidation_attempts"] += 1
      state.fetch("bundle_runtime")["final_revalidation"] =
        revalidate_build_a(
          build_a_parent_io, build_a_root_io, build_a_object_io,
          build_a_bundle_io, "ENSURE:BUILD_A_FINAL"
        )
    rescue StandardError
      nil
    end
  end
  close_build_a_descriptors(
    state, build_a_parent_io, build_a_root_io, build_a_object_io,
    build_a_bundle_io
  )
  close_io(exec_harness_io)
  close_io(stdout_w)
  close_io(stderr_w)
  close_io(stdout_r) unless stdout_thread
  close_io(stderr_r) unless stderr_thread
  close_io(harness_io)
  close_io(root_io)
  close_io(parent_io)
end
