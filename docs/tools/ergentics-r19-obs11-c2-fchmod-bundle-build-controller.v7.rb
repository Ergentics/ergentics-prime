#!/usr/bin/ruby

# Retired 2026-09-20: this frozen helper has unbounded process, pipe,
# or recovery waits. Reject before bootstrap intake, file access, or signals.
# Original Git blob: 535ea01cf33df74b6d8f8adf465c50306431c273.
# Existing live instances and historical copies are unaffected.
begin
  STDERR.write_nonblock(
    "{\"schema\":\"prime-v2-historical-helper-retirement/v1\"," \
    "\"helper\":\"ergentics-r19-obs11-c2-fchmod-bundle-build-controller.v7.rb\"," \
    "\"status\":\"RETIRED\",\"launch_allowed\":false," \
    "\"gate_e_outcome\":\"ABSTAIN\",\"gate_e_clearance\":0}\n",
    exception: false
  )
rescue IOError, SystemCallError
  # Diagnostic failure or a full pipe must not delay retirement.
ensure
  Process.exit!(70)
end

require "digest"
require "fiddle/import"
require "json"

class D3BuildFailure < StandardError
  attr_reader :label

  def initialize(label)
    @label = label
    super(label)
  end
end

EXPECTED_ENVIRONMENT = {
  "__CF_USER_TEXT_ENCODING" => "0x1F5:0x0:0x0",
}.freeze
REPOSITORY =
  "/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/" \
  ".phase-a-v2-fixture-identity-restore-only-staging"
ARTIFACT_PARENT =
  "#{REPOSITORY}/artifacts/" \
  "r19-obs11-retained-r19-projection-chain-2026-08-26"
FREEZE =
  "#{ARTIFACT_PARENT}/" \
  "r19-obs11-c2-prefix-capture-runner-correction-freeze.v7.json"
SOURCE = "#{REPOSITORY}/docs/tools/ergentics-r19-obs11-c2-fchmod-v7.c"
HEADER = "#{REPOSITORY}/docs/tools/ergentics-r19-obs11-c2-fchmod-v7.h"
CONTROLLER =
  "#{REPOSITORY}/docs/tools/" \
  "ergentics-r19-obs11-c2-fchmod-bundle-build-controller.v7.rb"
RECEIPT =
  "#{ARTIFACT_PARENT}/r19-obs11-c2-fchmod-bundle-build-result.v7.json"
BUILD_ROOTS = {
  "A" =>
    "/private/tmp/" \
    "ergentics-r19-obs11-c2-fchmod-bundle-v7-build-a-31c345d-ac9f4420",
  "B" =>
    "/private/tmp/" \
    "ergentics-r19-obs11-c2-fchmod-bundle-v7-build-b-31c345d-ac9f4420",
}.freeze
OBJECT_LEAF = "ergentics-r19-obs11-c2-fchmod-v7.o"
BUNDLE_LEAF = "libergentics-r19-obs11-c2-fchmod-v7.bundle"
CLANG =
  "/Applications/Xcode.app/Contents/Developer/Toolchains/" \
  "XcodeDefault.xctoolchain/usr/bin/clang"
LD =
  "/Applications/Xcode.app/Contents/Developer/Toolchains/" \
  "XcodeDefault.xctoolchain/usr/bin/ld"
LLVM_NM =
  "/Applications/Xcode.app/Contents/Developer/Toolchains/" \
  "XcodeDefault.xctoolchain/usr/bin/llvm-nm"
LLVM_OTOOL =
  "/Applications/Xcode.app/Contents/Developer/Toolchains/" \
  "XcodeDefault.xctoolchain/usr/bin/llvm-otool"
LLVM_DWARFDUMP =
  "/Applications/Xcode.app/Contents/Developer/Toolchains/" \
  "XcodeDefault.xctoolchain/usr/bin/llvm-dwarfdump"
SDK =
  "/Applications/Xcode.app/Contents/Developer/Platforms/" \
  "MacOSX.platform/Developer/SDKs/MacOSX26.5.sdk"
SDK_CANONICAL =
  "/Applications/Xcode.app/Contents/Developer/Platforms/" \
  "MacOSX.platform/Developer/SDKs/MacOSX.sdk"
SDK_SETTINGS =
  "/Applications/Xcode.app/Contents/Developer/Platforms/" \
  "MacOSX.platform/Developer/SDKs/MacOSX.sdk/SDKSettings.json"

FREEZE_SHA256 =
  "e9aebb182bef6faa4807d3f4c8a2198b4a82899af78fe76c2c63cf7b3d387441"
TOOL_SHA256 = {
  CLANG =>
    "7def90dd8829726686213a747fc5bff1583df933dae5edc55d755479e0bfe00a",
  LD =>
    "5897b275efd93b201b6df5832dd541262b3f20f290859ba78f2200a6a66ef38b",
  SDK_SETTINGS =>
    "f8d005f09381389167f9e0aeaa169bc9e7dff162ef22ca2fd8e98df7ff1acafe",
  "/usr/bin/cmp" =>
    "0f5da62f0875e924e5774371a954828b7e88143597bd38d9863ad223d886fd7b",
  "/usr/bin/codesign" =>
    "214d455584d19abc0d74d02b9cbc7d3da6bdcb0596c235e6156dd9ed2f4e1ba7",
  LLVM_DWARFDUMP =>
    "e49099fc871e88f10cd7865dfbde5a8f574da31d03f197a70fcad1daaff4e32d",
  "/usr/bin/file" =>
    "a4ba66d26a9cfdc70637c78cdacef920f94147f6aa45ccc73858e493589ef94d",
  LLVM_NM =>
    "d910f3acb104791e5475254000ede2aa129aa1a42eafcc7f5bdb27afffc642dc",
  LLVM_OTOOL =>
    "be184bb7054565eae25193e45e4235ea2d372c1eb6288ce900b2fad6d9dcc3f3",
}.freeze

O_RDONLY = 0
O_RDWR = 2
O_CREAT = 0x00000200
O_EXCL = 0x00000800
O_CLOEXEC = 0x01000000
O_DIRECTORY = 0x00100000
O_NOFOLLOW_ANY = 0x20000000
STAT_BYTES = 144
S_IFMT = 0o170000
S_IFDIR = 0o040000
S_IFREG = 0o100000
STREAM_CAP = 1_048_576
FILE_CAP = 16_777_216
TOOL_CAP = 268_435_456
RECEIPT_CAP = 4_194_304
OUTER_FAILURE_CAP = 16_384
ORDERED_LABELS = %w[
  COMPILE_A LINK_A COMPILE_B LINK_B
  CMP_A_B_OBJECT CMP_A_B_BUNDLE
  NM_DEFINED_A NM_DEFINED_B NM_UNDEFINED_A NM_UNDEFINED_B
  OTOOL_LOAD_COMMANDS_A OTOOL_LOAD_COMMANDS_B
  OTOOL_LINKED_IMAGES_A OTOOL_LINKED_IMAGES_B
  DWARFDUMP_UUID_A DWARFDUMP_UUID_B
  CODESIGN_DISPLAY_A CODESIGN_DISPLAY_B
  CODESIGN_VERIFY_A CODESIGN_VERIFY_B FILE_A FILE_B
].freeze

module D3BuildDarwin
  extend Fiddle::Importer
  dlload Fiddle.dlopen(nil)
  extern "void* __error()"
  extern "int dup(int)"
  extern "int fstat(int, void*)"
  extern "void* fdopendir(int)"
  extern "void* readdir(void*)"
  extern "void rewinddir(void*)"
  extern "int closedir(void*)"
end

def fail_build(label)
  raise D3BuildFailure, label
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

def diagnostic(error, phase)
  bytes = error.message.b
  prefix = bytes.byteslice(0, 1_024)
  {
    "class" => error.class.name,
    "message_bytes" => bytes.bytesize,
    "message_prefix_hex" => prefix.unpack1("H*"),
    "message_prefix_truncated" => prefix.bytesize != bytes.bytesize,
    "message_sha256" => Digest::SHA256.hexdigest(bytes),
    "phase" => phase,
  }
end

def native_errno_pointer
  raw = D3BuildDarwin.__error
  raw.is_a?(Fiddle::Pointer) ? raw : Fiddle::Pointer.new(raw)
end

def native_call(label)
  fail_build("#{label}:ERRNO_WIDTH") unless Fiddle::SIZEOF_INT == 4
  errno_pointer = native_errno_pointer
  zero = [0].pack("l<")
  Fiddle.last_error = 0
  errno_pointer[0, 4] = zero
  fail_build("#{label}:ERRNO_CLEAR") unless errno_pointer[0, 4] == zero
  errno_pointer[0, 4] = zero
  result = yield
  saved_error = Fiddle.last_error
  actual_error = errno_pointer[0, 4].unpack1("l<")
  [result, saved_error, actual_error]
end

def native_fstat(io, label)
  fail_build("#{label}:STAT_FRAME") unless Fiddle::SIZEOF_INT == 4
  bytes = Fiddle::Pointer.malloc(STAT_BYTES)
  bytes[0, STAT_BYTES] = "\0" * STAT_BYTES
  result, error, actual_error = native_call("#{label}:FSTAT") do
    D3BuildDarwin.fstat(io.fileno, bytes)
  end
  fail_build("#{label}:FSTAT:#{result}:#{error}:#{actual_error}") unless
    result == 0
  mode = bytes[4, 2].unpack1("S<")
  type = case mode & S_IFMT
  when S_IFDIR then "DIRECTORY"
  when S_IFREG then "REGULAR"
  else "OTHER"
  end
  {
    "bytes" => bytes[96, 8].unpack1("q<"),
    "device" => bytes[0, 4].unpack1("l<"),
    "flags" => bytes[116, 4].unpack1("L<"),
    "gid" => bytes[20, 4].unpack1("L<"),
    "inode" => bytes[8, 8].unpack1("Q<"),
    "mode" => format("%04o", mode & 0o7777),
    "nlink" => bytes[6, 2].unpack1("S<"),
    "type" => type,
    "uid" => bytes[16, 4].unpack1("L<"),
  }
end

def stat_signature(value)
  %w[type device inode uid gid mode nlink bytes flags].map do |key|
    value.fetch(key)
  end
end

def ruby_stat_matches?(stat, native)
  type = if stat.directory?
    "DIRECTORY"
  elsif stat.file?
    "REGULAR"
  else
    "OTHER"
  end
  [type, stat.dev, stat.ino, stat.uid, stat.gid,
   format("%04o", stat.mode & 0o7777), stat.nlink, stat.size] ==
    %w[type device inode uid gid mode nlink bytes].map do |key|
      native.fetch(key)
    end
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
  fail_build("#{label}:#{error}") if error
  true
end

def io_from_descriptor(descriptor, mode, label)
  io = IO.new(descriptor, mode)
  io.binmode
  fail_build("#{label}:CLOEXEC") unless io.close_on_exec?
  io
rescue StandardError
  if defined?(io) && io
    close_io(io)
  else
    begin
      IO.for_fd(descriptor).close if descriptor && descriptor >= 0
    rescue StandardError
      nil
    end
  end
  raise
end

def open_path(path, flags, mode, label)
  descriptor = IO.sysopen(path, flags)
  fail_build("#{label}:FD:#{descriptor}") unless descriptor >= 3
  io_from_descriptor(descriptor, mode, label)
rescue StandardError => error
  raise if error.is_a?(D3BuildFailure)
  fail_build("#{label}:#{error.class.name}:#{error.message}")
end

def rejoin_path(path, io, label)
  held = native_fstat(io, "#{label}:HELD")
  named = File.lstat(path)
  fail_build("#{label}:RUBY_NAMED") unless ruby_stat_matches?(named, held)
  flags = O_RDONLY | O_NOFOLLOW_ANY | O_CLOEXEC
  flags |= O_DIRECTORY if held.fetch("type") == "DIRECTORY"
  independent = open_path(path, flags, "rb", "#{label}:INDEPENDENT")
  independent_identity = native_fstat(independent, "#{label}:INDEPENDENT")
  fail_build("#{label}:INDEPENDENT_JOIN") unless
    stat_signature(independent_identity) == stat_signature(held)
  close_io!(independent, "#{label}:INDEPENDENT_CLOSE")
  held
rescue StandardError
  close_io(independent) if defined?(independent)
  raise
end

def descriptor_directory_names(path, root_io, label)
  held_before = rejoin_path(path, root_io, "#{label}:ROOT_BEFORE")
  descriptor, duplicate_error, duplicate_actual_error =
    native_call("#{label}:DUP") do
      D3BuildDarwin.dup(root_io.fileno)
    end
  fail_build(
    "#{label}:DUP:#{descriptor}:#{duplicate_error}:#{duplicate_actual_error}"
  ) unless
    descriptor >= 3
  begin
    scan_io = IO.new(descriptor, "rb")
    descriptor = nil
    scan_io.binmode
    scan_io.close_on_exec = true
    fail_build("#{label}:CLOEXEC") unless scan_io.close_on_exec?
    scan_before = native_fstat(scan_io, "#{label}:SCAN_BEFORE")
    fail_build("#{label}:SCAN_ROOT") unless
      stat_signature(scan_before) == stat_signature(held_before)
    scan_io.autoclose = false
    directory_pointer, open_error, open_actual_error =
      native_call("#{label}:FDOPENDIR") do
        D3BuildDarwin.fdopendir(scan_io.fileno)
    end
    directory_open = !directory_pointer.nil? && !directory_pointer.to_i.zero?
    unless directory_open
      close_io!(scan_io, "#{label}:FDOPENDIR_SOURCE_CLOSE")
      scan_io = nil
      fail_build("#{label}:FDOPENDIR:#{open_error}:#{open_actual_error}")
    end
    names = []
    _, rewind_before_error, rewind_before_actual_error =
      native_call("#{label}:REWIND_BEFORE") do
        D3BuildDarwin.rewinddir(directory_pointer)
      end
    loop do
      raw_pointer, read_error, read_actual_error =
        native_call("#{label}:READDIR") do
          D3BuildDarwin.readdir(directory_pointer)
        end
      if raw_pointer.nil? || raw_pointer.to_i.zero?
        fail_build(
          "#{label}:READDIR:#{read_error}:#{read_actual_error}"
        ) unless read_error.zero?
        break
      end
      entry_pointer = raw_pointer.is_a?(Fiddle::Pointer) ?
        raw_pointer : Fiddle::Pointer.new(raw_pointer)
      record_length = entry_pointer[16, 2].unpack1("S<")
      name_length = entry_pointer[18, 2].unpack1("S<")
      minimum = (21 + name_length + 1 + 3) & ~3
      fail_build("#{label}:DIRENT_SHAPE") unless
        name_length.between?(1, 1_023) && record_length <= 1_048 &&
          record_length >= minimum && (record_length % 4).zero?
      name = entry_pointer[21, name_length].b
      terminator = entry_pointer[21 + name_length, 1]
      fail_build("#{label}:DIRENT_NAME") if
        terminator != "\0" || name.include?("\0") || name.include?("/")
      next if name == "." || name == ".."
      fail_build("#{label}:DUPLICATE:#{name.unpack1('H*')}") if
        names.include?(name)
      names << name
    end
    _, rewind_after_error, rewind_after_actual_error =
      native_call("#{label}:REWIND_AFTER") do
        D3BuildDarwin.rewinddir(directory_pointer)
      end
    scan_after = native_fstat(scan_io, "#{label}:SCAN_AFTER")
    held_after = native_fstat(root_io, "#{label}:HELD_AFTER")
    fail_build("#{label}:SCAN_DRIFT") unless
      stat_signature(scan_after) == stat_signature(scan_before) &&
        stat_signature(held_after) == stat_signature(held_before)
    close_result, close_error, close_actual_error =
      native_call("#{label}:CLOSEDIR") do
        D3BuildDarwin.closedir(directory_pointer)
    end
    directory_open = false
    fail_build(
      "#{label}:CLOSEDIR:#{close_result}:#{close_error}:#{close_actual_error}"
    ) unless
      close_result == 0
    scan_io = nil
    joined_after = rejoin_path(path, root_io, "#{label}:ROOT_AFTER")
    fail_build("#{label}:ROOT_JOIN_DRIFT") unless
      stat_signature(joined_after) == stat_signature(held_before)
    names.sort
  rescue StandardError => primary
    if defined?(directory_open) && directory_open
      close_result, close_error, close_actual_error =
        native_call("#{label}:RESCUE_CLOSEDIR") do
          D3BuildDarwin.closedir(directory_pointer)
      end
      directory_open = false
      fail_build(
        "#{label}:RESCUE_CLOSEDIR:#{close_result}:" \
        "#{close_error}:#{close_actual_error}"
      ) unless close_result == 0
    elsif defined?(scan_io) && scan_io && !scan_io.closed?
      close_io(scan_io)
    elsif descriptor
      begin
        IO.for_fd(descriptor).close
      rescue StandardError
        nil
      end
    end
    raise primary
  end
end

def absent_twice!(path, label)
  2.times do |index|
    begin
      File.lstat(path)
      fail_build("#{label}:PRESENT:#{index + 1}")
    rescue Errno::ENOENT
      nil
    end
  end
  true
end

def digest_open_path(path, cap, label)
  io = open_path(
    path, O_RDONLY | O_NOFOLLOW_ANY | O_CLOEXEC, "rb", label
  )
  before = native_fstat(io, "#{label}:BEFORE")
  fail_build("#{label}:TYPE") unless before.fetch("type") == "REGULAR"
  fail_build("#{label}:CAP:#{before.fetch('bytes')}") if
    before.fetch("bytes") > cap
  digest = Digest::SHA256.new
  total = 0
  while (bytes = io.read(65_536))
    total += bytes.bytesize
    fail_build("#{label}:READ_CAP") if total > cap
    digest.update(bytes)
  end
  after = native_fstat(io, "#{label}:AFTER")
  fail_build("#{label}:DRIFT") unless
    stat_signature(after) == stat_signature(before)
  fail_build("#{label}:SIZE") unless total == after.fetch("bytes")
  joined = rejoin_path(path, io, "#{label}:REJOIN")
  result = joined.merge("sha256" => digest.hexdigest)
  close_io!(io, "#{label}:CLOSE")
  result
rescue StandardError
  close_io(io) if defined?(io)
  raise
end

def read_held_io(path, io, label, sync: false)
  before = native_fstat(io, "#{label}:BEFORE")
  fail_build("#{label}:TYPE") unless before.fetch("type") == "REGULAR"
  fail_build("#{label}:CAP") if before.fetch("bytes") > FILE_CAP
  io.fsync if sync
  io.rewind
  bytes = io.read
  fail_build("#{label}:READ") unless bytes.bytesize == before.fetch("bytes")
  fail_build("#{label}:EOF") unless io.read(1).nil?
  after = native_fstat(io, "#{label}:AFTER")
  fail_build("#{label}:DRIFT") unless
    stat_signature(after) == stat_signature(before)
  joined = rejoin_path(path, io, "#{label}:REJOIN")
  fail_build("#{label}:JOIN_DRIFT") unless
    stat_signature(joined) == stat_signature(before)
  [joined.merge("sha256" => Digest::SHA256.hexdigest(bytes)), bytes]
end

def read_held_file(path, label, sync: false)
  io = open_path(
    path, O_RDONLY | O_NOFOLLOW_ANY | O_CLOEXEC, "rb", label
  )
  result = read_held_io(path, io, label, sync: sync)
  close_io!(io, "#{label}:CLOSE")
  io = nil
  result
rescue StandardError
  close_io(io) if defined?(io)
  raise
end

def child_environment(root)
  {
    "DEVELOPER_DIR" => "/Applications/Xcode.app/Contents/Developer",
    "LANG" => "C.UTF-8",
    "LC_ALL" => "C.UTF-8",
    "PATH" => "/usr/bin:/bin",
    "SDKROOT" => SDK,
    "SOURCE_DATE_EPOCH" => "0",
    "TMPDIR" => root,
    "TZ" => "UTC",
    "ZERO_AR_DATE" => "1",
    "__CF_USER_TEXT_ENCODING" => "0x1F5:0x0:0x0",
  }
end

def drain_channel(io)
  digest = Digest::SHA256.new
  total = 0
  lines = 0
  retained = "".b
  overflow = false
  read_error = nil
  loop do
    bytes = io.sysread(16_384)
    total += bytes.bytesize
    lines += bytes.count("\n")
    digest.update(bytes)
    remaining = STREAM_CAP - retained.bytesize
    retained << bytes.byteslice(0, remaining) if remaining.positive?
    overflow = true if total > STREAM_CAP
  end
rescue EOFError
  nil
rescue StandardError => error
  read_error = diagnostic(error, "CHILD_DRAIN")
ensure
  close_error = close_io(io)
  return {
    "bytes" => total,
    "close_error" => close_error,
    "lf_count" => lines,
    "overflow" => overflow,
    "raw_hex" => retained.unpack1("H*"),
    "read_error" => read_error,
    "retained_bytes" => retained.bytesize,
    "sha256" => digest.hexdigest,
  }
end

def exact_wait(pid)
  loop do
    waited, status = Process.waitpid2(pid)
    return [waited, status, nil] if waited == pid
    return [
      waited, status,
      diagnostic(
        D3BuildFailure.new("WAIT_PID:#{waited}:#{pid}"), "WAIT_PID"
      ),
    ]
  rescue Errno::EINTR
    next
  rescue StandardError => error
    return [nil, nil, diagnostic(error, "WAIT_PID")]
  end
end

def run_child(label, argv, root)
  stdout_r = nil
  stdout_w = nil
  stderr_r = nil
  stderr_w = nil
  stdout_thread = nil
  stderr_thread = nil
  stdout = nil
  stderr = nil
  spawn_error = nil
  pid = nil
  waited_pid = nil
  status = nil
  wait_error = nil
  parent_close_errors = {}
  begin
    stdout_r, stdout_w = IO.pipe
    stderr_r, stderr_w = IO.pipe
    [stdout_r, stdout_w, stderr_r, stderr_w].each(&:binmode)
    stdout_thread = Thread.new { drain_channel(stdout_r) }
    stderr_thread = Thread.new { drain_channel(stderr_r) }
    begin
      pid = Process.spawn(
        child_environment(root),
        *argv,
        chdir: "/private/var/empty",
        in: "/dev/null",
        out: stdout_w,
        err: stderr_w,
        close_others: true,
        unsetenv_others: true,
        umask: 0o377
      )
    rescue StandardError => error
      spawn_error = diagnostic(error, "SPAWN:#{label}")
    ensure
      stdout_close = close_io(stdout_w)
      stderr_close = close_io(stderr_w)
      parent_close_errors["stdout_writer"] = stdout_close if stdout_close
      parent_close_errors["stderr_writer"] = stderr_close if stderr_close
      stdout_w = nil if stdout_close.nil?
      stderr_w = nil if stderr_close.nil?
    end
    waited_pid, status, wait_error = exact_wait(pid) if pid
    stdout = stdout_thread.value
    stderr = stderr_thread.value
    {
      "argv" => argv,
      "environment" => child_environment(root),
      "environment_sha256" =>
        Digest::SHA256.hexdigest(canonical_json(child_environment(root))),
      "label" => label,
      "parent_close_errors" => parent_close_errors,
      "pid" => pid,
      "spawn_error" => spawn_error,
      "status" => status && {
        "exited" => status.exited?,
        "exitstatus" => status.exited? ? status.exitstatus : nil,
        "signaled" => status.signaled?,
        "termsig" => status.signaled? ? status.termsig : nil,
      },
      "stderr" => stderr,
      "stdout" => stdout,
      "waited_pid" => waited_pid,
      "wait_error" => wait_error,
    }
  ensure
    close_io(stdout_w)
    close_io(stderr_w)
    if stdout_thread && stdout.nil?
      stdout = stdout_thread.value
    else
      close_io(stdout_r) unless stdout_thread
    end
    if stderr_thread && stderr.nil?
      stderr = stderr_thread.value
    else
      close_io(stderr_r) unless stderr_thread
    end
  end
end

def raw_bytes(channel)
  [channel.fetch("raw_hex")].pack("H*")
end

def require_settled_child!(receipt, label)
  fail_build("#{label}:SPAWN") if receipt.fetch("spawn_error")
  fail_build("#{label}:PARENT_CLOSE") unless
    receipt.fetch("parent_close_errors").empty?
  fail_build("#{label}:WAIT") if receipt.fetch("wait_error")
  status = receipt.fetch("status")
  fail_build("#{label}:STATUS") unless
    status && status.fetch("exited") && status.fetch("exitstatus") == 0 &&
      !status.fetch("signaled") &&
      receipt.fetch("waited_pid") == receipt.fetch("pid")
  %w[stdout stderr].each do |stream|
    channel = receipt.fetch(stream)
    fail_build("#{label}:#{stream}:OVERFLOW") if channel.fetch("overflow")
    fail_build("#{label}:#{stream}:READ") if channel.fetch("read_error")
    fail_build("#{label}:#{stream}:CLOSE") if channel.fetch("close_error")
    fail_build("#{label}:#{stream}:RETAIN") unless
      channel.fetch("bytes") == channel.fetch("retained_bytes")
  end
  true
end

def compiler_argv(label)
  root = BUILD_ROOTS.fetch(label.end_with?("_A") ? "A" : "B")
  object = "#{root}/#{OBJECT_LEAF}"
  bundle = "#{root}/#{BUNDLE_LEAF}"
  case label
  when "COMPILE_A", "COMPILE_B"
    [
      CLANG, "-target", "arm64-apple-macosx14.0", "-isysroot", SDK,
      "-std=c17", "-O2", "-fvisibility=hidden", "-fno-common",
      "-fno-stack-protector", "-fno-modules", "-fno-implicit-modules",
      "-Wall", "-Wextra", "-Wconversion", "-Werror",
      "-c", SOURCE, "-o", object,
    ]
  when "LINK_A", "LINK_B"
    [
      CLANG, "-target", "arm64-apple-macosx14.0", "-isysroot", SDK,
      "-bundle", "-Wl,-S", "-Wl,-dead_strip", "-Wl,-fatal_warnings",
      "-Wl,-adhoc_codesign", "-Wl,-undefined,error",
      "-Wl,-exported_symbol,_ergentics_r19_obs11_c2_v7_fchmod",
      object, "-o", bundle,
    ]
  else
    fail_build("COMPILER_LABEL:#{label}")
  end
end

def analyzer_specs
  a_object = "#{BUILD_ROOTS.fetch('A')}/#{OBJECT_LEAF}"
  b_object = "#{BUILD_ROOTS.fetch('B')}/#{OBJECT_LEAF}"
  a_bundle = "#{BUILD_ROOTS.fetch('A')}/#{BUNDLE_LEAF}"
  b_bundle = "#{BUILD_ROOTS.fetch('B')}/#{BUNDLE_LEAF}"
  [
    ["CMP_A_B_OBJECT", ["/usr/bin/cmp", "-s", a_object, b_object], "A"],
    ["CMP_A_B_BUNDLE", ["/usr/bin/cmp", "-s", a_bundle, b_bundle], "A"],
    ["NM_DEFINED_A", [LLVM_NM, "--defined-only", "--extern-only", a_bundle], "A"],
    ["NM_DEFINED_B", [LLVM_NM, "--defined-only", "--extern-only", b_bundle], "B"],
    ["NM_UNDEFINED_A", [LLVM_NM, "-u", a_bundle], "A"],
    ["NM_UNDEFINED_B", [LLVM_NM, "-u", b_bundle], "B"],
    ["OTOOL_LOAD_COMMANDS_A", [LLVM_OTOOL, "-l", a_bundle], "A"],
    ["OTOOL_LOAD_COMMANDS_B", [LLVM_OTOOL, "-l", b_bundle], "B"],
    ["OTOOL_LINKED_IMAGES_A", [LLVM_OTOOL, "-L", a_bundle], "A"],
    ["OTOOL_LINKED_IMAGES_B", [LLVM_OTOOL, "-L", b_bundle], "B"],
    ["DWARFDUMP_UUID_A", [LLVM_DWARFDUMP, "--uuid", a_bundle], "A"],
    ["DWARFDUMP_UUID_B", [LLVM_DWARFDUMP, "--uuid", b_bundle], "B"],
    ["CODESIGN_DISPLAY_A", ["/usr/bin/codesign", "-d", "--verbose=4", a_bundle], "A"],
    ["CODESIGN_DISPLAY_B", ["/usr/bin/codesign", "-d", "--verbose=4", b_bundle], "B"],
    ["CODESIGN_VERIFY_A", ["/usr/bin/codesign", "--verify", "--strict", "--verbose=4", a_bundle], "A"],
    ["CODESIGN_VERIFY_B", ["/usr/bin/codesign", "--verify", "--strict", "--verbose=4", b_bundle], "B"],
    ["FILE_A", ["/usr/bin/file", "-b", a_bundle], "A"],
    ["FILE_B", ["/usr/bin/file", "-b", b_bundle], "B"],
  ]
end

def parse_nm_symbols(bytes, label)
  text = bytes.dup.force_encoding(Encoding::UTF_8)
  fail_build("#{label}:ENCODING") unless text.valid_encoding?
  text.lines.map do |line|
    fields = line.strip.split(/\s+/)
    fail_build("#{label}:LINE") if fields.empty?
    fields.last
  end.sort
end

def normalized_tool_body(bytes, expected_path, label)
  fail_build("#{label}:FRAME") unless bytes.end_with?("\n")
  first, body = bytes.split("\n", 2)
  fail_build("#{label}:PATH_LINE") unless first == "#{expected_path}:"
  body || ""
end

def parse_linked_images(bytes, expected_path, label)
  body = normalized_tool_body(bytes, expected_path, label)
  body.lines.map do |line|
    stripped = line.strip
    next if stripped.empty?
    stripped.split(/\s+\(/, 2).first
  end.compact
end

def parse_uuid(bytes, expected_path, label)
  text = bytes.dup.force_encoding(Encoding::UTF_8)
  fail_build("#{label}:ENCODING") unless text.valid_encoding?
  match = /\AUUID: ([0-9A-F]{8}(?:-[0-9A-F]{4}){3}-[0-9A-F]{12}) \(arm64\) #{Regexp.escape(expected_path)}\n\z/.match(text)
  fail_build("#{label}:FRAME") unless match
  match[1]
end

def parse_codesign_display(bytes, expected_path, label)
  text = bytes.dup.force_encoding(Encoding::UTF_8)
  fail_build("#{label}:ENCODING") unless text.valid_encoding?
  lines = text.lines
  executable = lines.select { |line| line.start_with?("Executable=") }
  fail_build("#{label}:EXECUTABLE") unless
    executable == ["Executable=#{expected_path}\n"]
  normalized = lines.reject { |line| line.start_with?("Executable=") }.join
  cdhash_lines = lines.select { |line| line.start_with?("CDHash=") }
  directory_lines = lines.select { |line| line.start_with?("CodeDirectory ") }
  fail_build("#{label}:CDHASH_COUNT") unless cdhash_lines.length == 1
  fail_build("#{label}:CODEDIRECTORY_COUNT") unless directory_lines.length == 1
  cdhash_line = cdhash_lines.first
  directory_line = directory_lines.first
  fail_build("#{label}:CDHASH") unless
    cdhash_line.match?(/\ACDHash=[0-9a-f]{40}\n\z/)
  {
    "cdhash" => cdhash_line.split("=", 2).last.strip,
    "code_directory_line" => directory_line.strip,
    "normalized_sha256" => Digest::SHA256.hexdigest(normalized),
  }
end

def u32le(bytes, offset)
  bytes.byteslice(offset, 4).unpack1("L<")
end

def u32be(bytes, offset)
  bytes.byteslice(offset, 4).unpack1("N")
end

def parse_macho(bytes, label)
  fail_build("#{label}:HEADER") if bytes.bytesize < 32
  fail_build("#{label}:MAGIC") unless u32le(bytes, 0) == 0xfeedfacf
  fail_build("#{label}:CPU") unless u32le(bytes, 4) == 0x0100000c
  fail_build("#{label}:FILETYPE") unless u32le(bytes, 12) == 8
  ncmds = u32le(bytes, 16)
  sizeofcmds = u32le(bytes, 20)
  fail_build("#{label}:COMMAND_CAP") unless
    ncmds.between?(1, 128) && sizeofcmds <= bytes.bytesize - 32
  cursor = 32
  finish = 32 + sizeofcmds
  uuid = nil
  build = nil
  signature = nil
  commands = []
  ncmds.times do
    fail_build("#{label}:COMMAND_HEADER") if cursor + 8 > finish
    command = u32le(bytes, cursor)
    command_size = u32le(bytes, cursor + 4)
    fail_build("#{label}:COMMAND_SIZE") unless
      command_size >= 8 && cursor + command_size <= finish
    commands << command
    case command
    when 0x1b
      fail_build("#{label}:UUID_SIZE") unless command_size == 24 && uuid.nil?
      hex = bytes.byteslice(cursor + 8, 16).unpack1("H*").upcase
      uuid = [
        hex[0, 8], hex[8, 4], hex[12, 4], hex[16, 4], hex[20, 12],
      ].join("-")
    when 0x32
      fail_build("#{label}:BUILD_SIZE") unless command_size >= 24 && build.nil?
      build = {
        "platform" => u32le(bytes, cursor + 8),
        "minos_raw" => u32le(bytes, cursor + 12),
        "sdk_raw" => u32le(bytes, cursor + 16),
      }
    when 0x1d
      fail_build("#{label}:SIGNATURE_SIZE") unless
        command_size == 16 && signature.nil?
      signature = {
        "dataoff" => u32le(bytes, cursor + 8),
        "datasize" => u32le(bytes, cursor + 12),
      }
    end
    cursor += command_size
  end
  fail_build("#{label}:COMMAND_END") unless cursor == finish
  fail_build("#{label}:UUID_MISSING") unless uuid
  fail_build("#{label}:BUILD_MISSING") unless
    build && build.fetch("platform") == 1 &&
      build.fetch("minos_raw") == 0x000e0000 &&
      build.fetch("sdk_raw") == 0x001a0500
  fail_build("#{label}:SIGNATURE_MISSING") unless signature
  signature_end = signature.fetch("dataoff") + signature.fetch("datasize")
  fail_build("#{label}:SIGNATURE_RANGE") unless
    signature.fetch("datasize").positive? && signature_end <= bytes.bytesize
  signature_bytes =
    bytes.byteslice(signature.fetch("dataoff"), signature.fetch("datasize"))
  fail_build("#{label}:SUPERBLOB") unless
    signature_bytes.bytesize >= 12 && u32be(signature_bytes, 0) == 0xfade0cc0
  superblob_length = u32be(signature_bytes, 4)
  count = u32be(signature_bytes, 8)
  fail_build("#{label}:SUPERBLOB_FRAME") unless
    superblob_length == signature_bytes.bytesize && count.between?(1, 16) &&
      12 + count * 8 <= superblob_length
  code_directory = nil
  count.times do |index|
    slot_type = u32be(signature_bytes, 12 + index * 8)
    offset = u32be(signature_bytes, 16 + index * 8)
    next unless slot_type == 0
    fail_build("#{label}:CODEDIRECTORY_DUPLICATE") if code_directory
    fail_build("#{label}:CODEDIRECTORY_OFFSET") if offset + 8 > superblob_length
    length = u32be(signature_bytes, offset + 4)
    fail_build("#{label}:CODEDIRECTORY_RANGE") unless
      u32be(signature_bytes, offset) == 0xfade0c02 &&
        length >= 44 && offset + length <= superblob_length
    code_directory = signature_bytes.byteslice(offset, length)
    fail_build("#{label}:CODEDIRECTORY_HASH") unless
      code_directory.getbyte(36) == 32 && code_directory.getbyte(37) == 2
  end
  fail_build("#{label}:CODEDIRECTORY_MISSING") unless code_directory
  {
    "code_directory_bytes" => code_directory.bytesize,
    "code_directory_sha256" => Digest::SHA256.hexdigest(code_directory),
    "commands" => commands,
    "lc_build_version" => {
      "minimum_os" => "14.0.0",
      "platform" => "macOS",
      "sdk" => "26.5.0",
    },
    "lc_code_signature" => signature,
    "uuid" => uuid,
  }
end

def require_silent!(receipt, label)
  fail_build("#{label}:STDOUT") unless receipt.dig("stdout", "bytes").zero?
  fail_build("#{label}:STDERR") unless receipt.dig("stderr", "bytes").zero?
end

def admit_analyzer!(label, receipt, derived)
  require_settled_child!(receipt, label)
  stdout = raw_bytes(receipt.fetch("stdout"))
  stderr = raw_bytes(receipt.fetch("stderr"))
  a_bundle = "#{BUILD_ROOTS.fetch('A')}/#{BUNDLE_LEAF}"
  b_bundle = "#{BUILD_ROOTS.fetch('B')}/#{BUNDLE_LEAF}"
  case label
  when "CMP_A_B_OBJECT", "CMP_A_B_BUNDLE"
    require_silent!(receipt, label)
  when "NM_DEFINED_A", "NM_DEFINED_B"
    fail_build("#{label}:STDERR") unless stderr.empty?
    symbols = parse_nm_symbols(stdout, label)
    fail_build("#{label}:SYMBOLS") unless
      symbols == ["_ergentics_r19_obs11_c2_v7_fchmod"]
    derived[label] = symbols
  when "NM_UNDEFINED_A", "NM_UNDEFINED_B"
    fail_build("#{label}:STDERR") unless stderr.empty?
    symbols = parse_nm_symbols(stdout, label)
    fail_build("#{label}:SYMBOLS") unless symbols == %w[___error _fchmod]
    derived[label] = symbols
  when "OTOOL_LOAD_COMMANDS_A", "OTOOL_LOAD_COMMANDS_B"
    fail_build("#{label}:STDERR") unless stderr.empty?
    path = label.end_with?("_A") ? a_bundle : b_bundle
    body = normalized_tool_body(stdout, path, label)
    %w[LC_UUID LC_BUILD_VERSION LC_CODE_SIGNATURE].each do |command|
      fail_build("#{label}:#{command}") unless body.include?("cmd #{command}\n")
    end
    fail_build("#{label}:MINOS") unless body.match?(/\n\s*minos 14\.0\n/)
    fail_build("#{label}:SDK") unless body.match?(/\n\s*sdk 26\.5\n/)
    derived[label] = {"normalized_sha256" => Digest::SHA256.hexdigest(body)}
    if label.end_with?("_B")
      fail_build("#{label}:A_B") unless
        derived.fetch("OTOOL_LOAD_COMMANDS_A") == derived.fetch(label)
    end
  when "OTOOL_LINKED_IMAGES_A", "OTOOL_LINKED_IMAGES_B"
    fail_build("#{label}:STDERR") unless stderr.empty?
    path = label.end_with?("_A") ? a_bundle : b_bundle
    images = parse_linked_images(stdout, path, label)
    fail_build("#{label}:IMAGES") unless images == ["/usr/lib/libSystem.B.dylib"]
    derived[label] = images
    if label.end_with?("_B")
      fail_build("#{label}:A_B") unless
        derived.fetch("OTOOL_LINKED_IMAGES_A") == images
    end
  when "DWARFDUMP_UUID_A", "DWARFDUMP_UUID_B"
    fail_build("#{label}:STDERR") unless stderr.empty?
    path = label.end_with?("_A") ? a_bundle : b_bundle
    uuid = parse_uuid(stdout, path, label)
    expected = derived.fetch(
      label.end_with?("_A") ? "MACHO_UUID_A" : "MACHO_UUID_B"
    )
    fail_build("#{label}:MACHO") unless uuid == expected
    derived[label] = uuid
    if label.end_with?("_B")
      fail_build("#{label}:A_B") unless
        derived.fetch("DWARFDUMP_UUID_A") == uuid
    end
  when "CODESIGN_DISPLAY_A", "CODESIGN_DISPLAY_B"
    fail_build("#{label}:STDOUT") unless stdout.empty?
    path = label.end_with?("_A") ? a_bundle : b_bundle
    parsed = parse_codesign_display(stderr, path, label)
    expected_cd = derived.fetch(
      label.end_with?("_A") ?
        "MACHO_CODE_DIRECTORY_SHA256_A" :
        "MACHO_CODE_DIRECTORY_SHA256_B"
    )
    fail_build("#{label}:CDHASH_JOIN") unless
      parsed.fetch("cdhash") == expected_cd[0, 40]
    derived[label] = parsed
    if label.end_with?("_B")
      fail_build("#{label}:A_B") unless
        derived.fetch("CODESIGN_DISPLAY_A") == parsed
    end
  when "CODESIGN_VERIFY_A", "CODESIGN_VERIFY_B"
    fail_build("#{label}:STDOUT") unless stdout.empty?
    derived[label] = {
      "stderr_sha256" => Digest::SHA256.hexdigest(stderr),
    }
  when "FILE_A", "FILE_B"
    fail_build("#{label}:STDERR") unless stderr.empty?
    fail_build("#{label}:STDOUT") unless
      stdout == "Mach-O 64-bit bundle arm64\n"
    derived[label] = stdout
    if label.end_with?("_B")
      fail_build("#{label}:A_B") unless derived.fetch("FILE_A") == stdout
    end
  else
    fail_build("ANALYZER_LABEL:#{label}")
  end
  true
end

def create_build_roots!(state)
  BUILD_ROOTS.each do |label, path|
    absent_twice!(path, "ROOT_#{label}:ABSENT")
    Dir.mkdir(path, 0o700)
    state.fetch("operations")["build_root_creations"] += 1
    io = open_path(
      path,
      O_RDONLY | O_DIRECTORY | O_NOFOLLOW_ANY | O_CLOEXEC,
      "rb",
      "ROOT_#{label}:OPEN"
    )
    state.fetch("root_ios")[label] = io
    identity = rejoin_path(path, io, "ROOT_#{label}:JOIN")
    fail_build("ROOT_#{label}:POLICY") unless
      [
        identity.fetch("type"), identity.fetch("uid"), identity.fetch("gid"),
        identity.fetch("mode"), identity.fetch("nlink"),
        identity.fetch("bytes"), identity.fetch("flags"),
      ] == ["DIRECTORY", 501, 0, "0700", 2, 64, 0]
    state.fetch("roots")[label] = identity
  end
end

def admit_artifacts!(state)
  result = {}
  bytes = {}
  BUILD_ROOTS.each do |label, root|
    root_io = state.fetch("root_ios").fetch(label)
    root_before = rejoin_path(root, root_io, "ARTIFACT_#{label}:ROOT_BEFORE")
    names = descriptor_directory_names(
      root, root_io, "ARTIFACT_#{label}:INVENTORY"
    )
    fail_build("ARTIFACT_#{label}:NAMES") unless
      names == [BUNDLE_LEAF, OBJECT_LEAF].sort
    object_path = "#{root}/#{OBJECT_LEAF}"
    object_io = open_path(
      object_path, O_RDONLY | O_NOFOLLOW_ANY | O_CLOEXEC, "rb",
      "ARTIFACT_#{label}:OBJECT:OPEN"
    )
    state.fetch("artifact_ios").fetch(label)["object"] = object_io
    object_identity, object_bytes = read_held_io(
      object_path, object_io, "ARTIFACT_#{label}:OBJECT", sync: true
    )
    bundle_path = "#{root}/#{BUNDLE_LEAF}"
    bundle_io = open_path(
      bundle_path, O_RDONLY | O_NOFOLLOW_ANY | O_CLOEXEC, "rb",
      "ARTIFACT_#{label}:BUNDLE:OPEN"
    )
    state.fetch("artifact_ios").fetch(label)["bundle"] = bundle_io
    bundle_identity, bundle_bytes = read_held_io(
      bundle_path, bundle_io, "ARTIFACT_#{label}:BUNDLE", sync: true
    )
    [object_identity, bundle_identity].each do |identity|
      fail_build("ARTIFACT_#{label}:FILE_POLICY") unless
        [
          identity.fetch("type"), identity.fetch("uid"), identity.fetch("gid"),
          identity.fetch("mode"), identity.fetch("nlink"),
          identity.fetch("flags"),
        ] == ["REGULAR", 501, 0, "0400", 1, 0]
      fail_build("ARTIFACT_#{label}:EMPTY") unless identity.fetch("bytes").positive?
    end
    root_io.fsync
    root_after = rejoin_path(root, root_io, "ARTIFACT_#{label}:ROOT_AFTER")
    fail_build("ARTIFACT_#{label}:ROOT_POLICY") unless
      [
        root_after.fetch("type"), root_after.fetch("uid"),
        root_after.fetch("gid"), root_after.fetch("mode"),
        root_after.fetch("nlink"), root_after.fetch("flags"),
      ] == ["DIRECTORY", 501, 0, "0700", 4, 0]
    fail_build("ARTIFACT_#{label}:ROOT_IDENTITY") unless
      [root_before.fetch("device"), root_before.fetch("inode")] ==
        [root_after.fetch("device"), root_after.fetch("inode")]
    macho = parse_macho(bundle_bytes, "ARTIFACT_#{label}:MACHO")
    result[label] = {
      "bundle" => bundle_identity,
      "macho" => macho,
      "names" => names,
      "object" => object_identity,
      "root" => root_after,
    }
    bytes[label] = {"bundle" => bundle_bytes, "object" => object_bytes}
  end
  %w[root object bundle].each do |kind|
    a = kind == "root" ? result.dig("A", "root") : result.dig("A", kind)
    b = kind == "root" ? result.dig("B", "root") : result.dig("B", kind)
    fail_build("ARTIFACT:A_B_#{kind.upcase}_VNODE") if
      [a.fetch("device"), a.fetch("inode")] ==
        [b.fetch("device"), b.fetch("inode")]
  end
  fail_build("ARTIFACT:A_B_OBJECT_BYTES") unless
    bytes.dig("A", "object") == bytes.dig("B", "object")
  fail_build("ARTIFACT:A_B_BUNDLE_BYTES") unless
    bytes.dig("A", "bundle") == bytes.dig("B", "bundle")
  fail_build("ARTIFACT:A_B_MACHO") unless
    result.dig("A", "macho") == result.dig("B", "macho")
  state["artifacts"] = result
  state["derived"]["MACHO_UUID_A"] = result.dig("A", "macho", "uuid")
  state["derived"]["MACHO_UUID_B"] = result.dig("B", "macho", "uuid")
  state["derived"]["MACHO_CODE_DIRECTORY_SHA256_A"] =
    result.dig("A", "macho", "code_directory_sha256")
  state["derived"]["MACHO_CODE_DIRECTORY_SHA256_B"] =
    result.dig("B", "macho", "code_directory_sha256")
end

def revalidate_held_artifacts!(state, label)
  current = {}
  bytes = {}
  BUILD_ROOTS.each do |root_label, root|
    root_io = state.fetch("root_ios").fetch(root_label)
    initial_root = state.dig("artifacts", root_label, "root")
    root_before = rejoin_path(
      root, root_io, "#{label}:#{root_label}:ROOT_BEFORE"
    )
    fail_build("#{label}:#{root_label}:ROOT_INITIAL") unless
      stat_signature(root_before) == stat_signature(initial_root)
    names = descriptor_directory_names(
      root, root_io, "#{label}:#{root_label}:INVENTORY"
    )
    fail_build("#{label}:#{root_label}:NAMES") unless
      names == [BUNDLE_LEAF, OBJECT_LEAF].sort
    current[root_label] = {"names" => names, "root" => root_before}
    bytes[root_label] = {}
    {"object" => OBJECT_LEAF, "bundle" => BUNDLE_LEAF}.each do |kind, leaf|
      path = "#{root}/#{leaf}"
      io = state.fetch("artifact_ios").fetch(root_label).fetch(kind)
      observed, observed_bytes = read_held_io(
        path, io, "#{label}:#{root_label}:#{kind.upcase}"
      )
      initial = state.dig("artifacts", root_label, kind)
      fail_build("#{label}:#{root_label}:#{kind.upcase}:INITIAL") unless
        stat_signature(observed) == stat_signature(initial) &&
          observed.fetch("sha256") == initial.fetch("sha256")
      current.fetch(root_label)[kind] = observed
      bytes.fetch(root_label)[kind] = observed_bytes
    end
    root_after = rejoin_path(
      root, root_io, "#{label}:#{root_label}:ROOT_AFTER"
    )
    fail_build("#{label}:#{root_label}:ROOT_DRIFT") unless
      stat_signature(root_after) == stat_signature(initial_root)
    current.fetch(root_label)["root"] = root_after
  end
  fail_build("#{label}:A_B_OBJECT_BYTES") unless
    bytes.dig("A", "object") == bytes.dig("B", "object")
  fail_build("#{label}:A_B_BUNDLE_BYTES") unless
    bytes.dig("A", "bundle") == bytes.dig("B", "bundle")
  fail_build("#{label}:A_B_MACHO") unless
    parse_macho(bytes.dig("A", "bundle"), "#{label}:MACHO_A") ==
      parse_macho(bytes.dig("B", "bundle"), "#{label}:MACHO_B")
  state["artifact_revalidation_count"] += 1
  current
end

def close_artifacts(state, strict:)
  errors = {}
  state.fetch("artifact_ios").each do |root_label, values|
    values.each do |kind, io|
      error = close_io(io)
      errors["#{root_label}:#{kind}"] = error if error
    end
  end
  state.fetch("artifact_close_errors").merge!(errors)
  if strict && !state.fetch("artifact_close_errors").empty?
    fail_build(
      "ARTIFACT_CLOSE:#{canonical_json(state.fetch('artifact_close_errors'))}"
    )
  end
  state.fetch("artifact_close_errors")
end

def close_roots(state, strict:)
  errors = {}
  state.fetch("root_ios").each do |label, io|
    error = close_io(io)
    errors[label] = error if error
  end
  state.fetch("root_close_errors").merge!(errors)
  fail_build("ROOT_CLOSE:#{canonical_json(state.fetch('root_close_errors'))}") if
    strict && !state.fetch("root_close_errors").empty?
  state.fetch("root_close_errors")
end

def safe_root_snapshot(path)
  begin
    File.lstat(path)
  rescue Errno::ENOENT
    return {"presence" => "ABSENT"}
  end
  root_io = open_path(
    path,
    O_RDONLY | O_DIRECTORY | O_NOFOLLOW_ANY | O_CLOEXEC,
    "rb",
    "FAILURE_SNAPSHOT:ROOT"
  )
  identity = rejoin_path(path, root_io, "FAILURE_SNAPSHOT:ROOT_JOIN")
  names = descriptor_directory_names(path, root_io, "FAILURE_SNAPSHOT:INVENTORY")
  entries = {}
  names.each do |name|
    child = "#{path}/#{name}"
    begin
      child_identity, = read_held_file(child, "FAILURE_SNAPSHOT:#{name}")
      entries[name] = child_identity
    rescue StandardError => error
      entries[name] = {"observation_error" => diagnostic(error, "FAILURE_SNAPSHOT")}
    end
  end
  close_io!(root_io, "FAILURE_SNAPSHOT:ROOT_CLOSE")
  {"entries" => entries, "names" => names, "root" => identity}
rescue StandardError => error
  close_io(root_io) if defined?(root_io)
  {"observation_error" => diagnostic(error, "FAILURE_SNAPSHOT")}
end

def sdk_alias_identity!(label)
  link = File.lstat(SDK)
  fail_build("#{label}:ALIAS_TYPE") unless link.symlink?
  link_target = File.readlink(SDK).b
  fail_build("#{label}:ALIAS_TARGET") unless link_target == "MacOSX.sdk".b
  fail_build("#{label}:REALPATH") unless File.realpath(SDK) == SDK_CANONICAL
  {
    "bytes" => link.size,
    "device" => link.dev,
    "gid" => link.gid,
    "inode" => link.ino,
    "mode" => format("%04o", link.mode & 0o7777),
    "nlink" => link.nlink,
    "raw_target_hex" => link_target.unpack1("H*"),
    "raw_target_sha256" => Digest::SHA256.hexdigest(link_target),
    "type" => "SYMLINK",
    "uid" => link.uid,
  }
end

def sdk_admission!(label)
  link_identity = sdk_alias_identity!("#{label}:ALIAS_BEFORE")
  target_io = open_path(
    SDK_CANONICAL,
    O_RDONLY | O_DIRECTORY | O_NOFOLLOW_ANY | O_CLOEXEC,
    "rb",
    "#{label}:TARGET"
  )
  target_identity = rejoin_path(
    SDK_CANONICAL, target_io, "#{label}:TARGET_JOIN"
  )
  fail_build("#{label}:TARGET_POLICY") unless
    target_identity.fetch("type") == "DIRECTORY"
  settings = digest_open_path(
    SDK_SETTINGS, FILE_CAP, "#{label}:SDK_SETTINGS"
  )
  fail_build("#{label}:SDK_SETTINGS_HASH") unless
    settings.fetch("sha256") == TOOL_SHA256.fetch(SDK_SETTINGS)
  target_after = rejoin_path(
    SDK_CANONICAL, target_io, "#{label}:TARGET_JOIN_AFTER_SETTINGS"
  )
  fail_build("#{label}:TARGET_DRIFT") unless
    stat_signature(target_after) == stat_signature(target_identity)
  link_after = sdk_alias_identity!("#{label}:ALIAS_AFTER")
  fail_build("#{label}:ALIAS_DRIFT") unless link_after == link_identity
  close_io!(target_io, "#{label}:TARGET_CLOSE")
  target_io = nil
  {
    "alias" => link_identity,
    "canonical_target" => target_identity,
    "identity_scope" => "SDK_SETTINGS_ONLY_NOT_HEADER_CLOSURE",
    "sdk_settings" => settings,
    "whole_sdk_header_closure" => "UNKNOWN_NOT_CONTENT_BOUND",
  }
rescue StandardError
  close_io(target_io) if defined?(target_io)
  raise
end

def revalidate_sdk!(expected, label)
  observed = sdk_admission!(label)
  fail_build("#{label}:IDENTITY_DRIFT") unless observed == expected
  observed
end

def source_and_tool_admission!
  freeze = digest_open_path(FREEZE, FILE_CAP, "FREEZE")
  fail_build("FREEZE:IDENTITY") unless
    freeze.fetch("sha256") == FREEZE_SHA256 &&
      freeze.fetch("bytes") == 37_346
  sources = {
    "c" => digest_open_path(SOURCE, FILE_CAP, "SOURCE_C"),
    "controller" => digest_open_path(CONTROLLER, FILE_CAP, "SOURCE_CONTROLLER"),
    "header" => digest_open_path(HEADER, FILE_CAP, "SOURCE_HEADER"),
  }
  tools = {}
  TOOL_SHA256.each do |path, expected|
    observed = digest_open_path(path, TOOL_CAP, "TOOL:#{File.basename(path)}")
    fail_build("TOOL:#{path}:HASH") unless observed.fetch("sha256") == expected
    tools[path] = observed
  end
  {
    "freeze" => freeze,
    "sdk" => sdk_admission!("SDK_ADMISSION"),
    "sources" => sources,
    "tools" => tools,
  }
end

def build_receipt(state, status, failure = nil)
  value = {
    "artifact_close_errors" => state.fetch("artifact_close_errors"),
    "artifact_revalidation_count" =>
      state.fetch("artifact_revalidation_count"),
    "artifacts" => state.fetch("artifacts"),
    "authority" => {
      "authority_vector" => "00000000",
      "bundle_execution_entries" => 0,
      "gate_e" => "ABSTAIN",
      "runner_execution_entries" => 0,
      "scientific_outcome" => "ABSTAIN",
    },
    "commands" => state.fetch("commands"),
    "completed_ordered_labels" => state.fetch("completed_labels"),
    "consumption" => "CONSUMED_AT_OUTER_ZSH_ENTRY_NO_RETRY",
    "control" => {
      "freeze_commit" => "a59b2fd790569c1fc27c3fe27fa7de72ce424714",
      "freeze_sha256" => FREEZE_SHA256,
      "freeze_tree" => "5be380bb77dd3d291c2922dac945a2e153bd4388",
    },
    "derived" => state.fetch("derived"),
    "failure" => failure,
    "failure_position" => state.fetch("failure_position"),
    "first_unentered_label" => state.fetch("first_unentered_label"),
    "first_unentered_ordinal_one_based" =>
      state.fetch("first_unentered_ordinal_one_based"),
    "incoming_umask" => state.fetch("incoming_umask"),
    "operations" => state.fetch("operations"),
    "root_close_errors" => state.fetch("root_close_errors"),
    "roots" => state.fetch("roots"),
    "schema" => "ergentics-r19-obs11-c2-fchmod-bundle-build-result-v7",
    "sdk_revalidation_count" => state.fetch("sdk_revalidation_count"),
    "source_and_tool_admission" => state.fetch("source_and_tool_admission"),
    "status" => status,
    "terminal_root_snapshots" => state.fetch("terminal_root_snapshots"),
  }
  value
end

def publish_receipt!(value)
  bytes = canonical_json(value) + "\n"
  fail_build("RECEIPT:CAP:#{bytes.bytesize}") if bytes.bytesize > RECEIPT_CAP
  absent_twice!(RECEIPT, "RECEIPT:ABSENT")
  parent = open_path(
    ARTIFACT_PARENT,
    O_RDONLY | O_DIRECTORY | O_NOFOLLOW_ANY | O_CLOEXEC,
    "rb",
    "RECEIPT:PARENT"
  )
  parent_before = rejoin_path(ARTIFACT_PARENT, parent, "RECEIPT:PARENT_BEFORE")
  old_umask = File.umask(0o077)
  descriptor = nil
  begin
    descriptor = IO.sysopen(
      RECEIPT,
      O_RDWR | O_CREAT | O_EXCL | O_NOFOLLOW_ANY | O_CLOEXEC,
      0o400
    )
  ensure
    File.umask(old_umask)
  end
  fail_build("RECEIPT:FD") unless descriptor && descriptor >= 3
  io = io_from_descriptor(descriptor, "r+", "RECEIPT:OPEN")
  initial = native_fstat(io, "RECEIPT:INITIAL")
  fail_build("RECEIPT:INITIAL_POLICY") unless
    [
      initial.fetch("type"), initial.fetch("uid"), initial.fetch("gid"),
      initial.fetch("mode"), initial.fetch("nlink"), initial.fetch("bytes"),
      initial.fetch("flags"),
    ] == ["REGULAR", 501, 20, "0400", 1, 0, 0]
  offset = 0
  while offset < bytes.bytesize
    written = io.syswrite(bytes.byteslice(offset, bytes.bytesize - offset))
    fail_build("RECEIPT:WRITE_ZERO") unless written.positive?
    offset += written
  end
  io.rewind
  readback = io.read
  fail_build("RECEIPT:READBACK") unless readback == bytes
  fail_build("RECEIPT:EOF") unless io.read(1).nil?
  io.fsync
  parent.fsync
  final = rejoin_path(RECEIPT, io, "RECEIPT:FINAL")
  fail_build("RECEIPT:FINAL_POLICY") unless
    [
      final.fetch("type"), final.fetch("uid"), final.fetch("gid"),
      final.fetch("mode"), final.fetch("nlink"), final.fetch("bytes"),
      final.fetch("flags"), final.fetch("device"),
    ] == [
      "REGULAR", 501, 20, "0400", 1, bytes.bytesize, 0,
      parent_before.fetch("device"),
    ]
  parent_after = rejoin_path(ARTIFACT_PARENT, parent, "RECEIPT:PARENT_AFTER")
  fail_build("RECEIPT:PARENT_DRIFT") unless
    [parent_before.fetch("device"), parent_before.fetch("inode")] ==
      [parent_after.fetch("device"), parent_after.fetch("inode")]
  close_io!(parent, "RECEIPT:PARENT_CLOSE")
  parent = nil
  close_io!(io, "RECEIPT:CLOSE")
  io = nil
  {
    "bytes" => bytes.bytesize,
    "sha256" => Digest::SHA256.hexdigest(bytes),
  }
rescue StandardError
  close_io(io) if defined?(io)
  close_io(parent) if defined?(parent)
  raise
end

state = {
  "artifact_close_errors" => {},
  "artifact_ios" => {"A" => {}, "B" => {}},
  "artifact_revalidation_count" => 0,
  "artifacts" => {},
  "commands" => [],
  "completed_labels" => [],
  "derived" => {},
  "first_unentered_label" => ORDERED_LABELS.first,
  "first_unentered_ordinal_one_based" => 1,
  "failure_position" => nil,
  "incoming_umask" => nil,
  "operations" => {
    "analyzer_attempts" => 0,
    "analyzer_entries" => 0,
    "build_root_creations" => 0,
    "bundle_executions" => 0,
    "compiler_attempts" => 0,
    "compiler_entries" => 0,
    "python_entries" => 0,
    "receipt_creation_attempts" => 0,
    "runner_executions" => 0,
    "signals" => 0,
  },
  "root_close_errors" => {},
  "root_ios" => {},
  "roots" => {},
  "sdk_revalidation_count" => 0,
  "source_and_tool_admission" => {},
  "terminal_root_snapshots" => {},
}
phase = "ENTRY"
primary_error = nil
requested_exit = 70

begin
  fail_build("ENTRY:ARGV") unless ARGV.empty?
  fail_build("ENTRY:ENVIRONMENT") unless ENV.to_h == EXPECTED_ENVIRONMENT
  fail_build("ENTRY:CWD") unless Dir.pwd == "/private/var/empty"
  fail_build("ENTRY:RUBY") unless
    [RUBY_VERSION, RUBY_PATCHLEVEL, RUBY_PLATFORM] ==
      ["2.6.10", 210, "universal.arm64e-darwin25"]
  fail_build("ENTRY:ABI") unless
    Fiddle::SIZEOF_INT == 4 && Fiddle::SIZEOF_VOIDP == 8 &&
      [1].pack("L").bytes == [1, 0, 0, 0]
  fail_build("ENTRY:UID") unless Process.uid == 501 && Process.euid == 501
  fail_build("ENTRY:GID") unless Process.gid == 20 && Process.egid == 20
  state["incoming_umask"] = format("%04o", File.umask(0o077))
  absent_twice!(RECEIPT, "ENTRY:RECEIPT")
  BUILD_ROOTS.each do |label, path|
    absent_twice!(path, "ENTRY:ROOT_#{label}")
  end

  phase = "SOURCE_AND_TOOL_ADMISSION"
  state["source_and_tool_admission"] = source_and_tool_admission!

  phase = "ROOT_CREATION"
  create_build_roots!(state)

  compiler_labels = %w[COMPILE_A LINK_A COMPILE_B LINK_B]
  compiler_labels.each do |label|
    phase = "SDK_REVALIDATION_BEFORE_#{label}"
    revalidate_sdk!(
      state.dig("source_and_tool_admission", "sdk"), phase
    )
    state["sdk_revalidation_count"] += 1
    phase = label
    ordinal = ORDERED_LABELS.index(label)
    state["first_unentered_label"] = label
    state["first_unentered_ordinal_one_based"] = ordinal + 1
    state.fetch("operations")["compiler_attempts"] += 1
    root_label = label.end_with?("_A") ? "A" : "B"
    command = run_child(label, compiler_argv(label), BUILD_ROOTS.fetch(root_label))
    state.fetch("commands") << command
    if command.fetch("pid")
      state.fetch("operations")["compiler_entries"] += 1
      state["first_unentered_label"] = ORDERED_LABELS[ordinal + 1]
      state["first_unentered_ordinal_one_based"] =
        ORDERED_LABELS[ordinal + 1] ? ordinal + 2 : nil
    end
    require_settled_child!(command, label)
    require_silent!(command, label)
    state.fetch("completed_labels") << label
  end

  phase = "ARTIFACT_ADMISSION"
  state["first_unentered_label"] = "CMP_A_B_OBJECT"
  state["first_unentered_ordinal_one_based"] = 5
  admit_artifacts!(state)

  analyzer_specs.each do |label, argv, root_label|
    phase = "ARTIFACT_REVALIDATION_BEFORE_#{label}"
    revalidate_held_artifacts!(state, phase)
    phase = label
    ordinal = ORDERED_LABELS.index(label)
    state["first_unentered_label"] = label
    state["first_unentered_ordinal_one_based"] = ordinal + 1
    state.fetch("operations")["analyzer_attempts"] += 1
    command = run_child(label, argv, BUILD_ROOTS.fetch(root_label))
    state.fetch("commands") << command
    if command.fetch("pid")
      state.fetch("operations")["analyzer_entries"] += 1
      state["first_unentered_label"] = ORDERED_LABELS[ordinal + 1]
      state["first_unentered_ordinal_one_based"] =
        ORDERED_LABELS[ordinal + 1] ? ordinal + 2 : nil
    end
    admit_analyzer!(label, command, state.fetch("derived"))
    revalidate_held_artifacts!(state, "ARTIFACT_REVALIDATION_AFTER_#{label}")
    state.fetch("completed_labels") << label
  end

  fail_build("SUCCESS:COMPILER_COUNT") unless
    state.dig("operations", "compiler_attempts") == 4 &&
      state.dig("operations", "compiler_entries") == 4
  fail_build("SUCCESS:ANALYZER_COUNT") unless
    state.dig("operations", "analyzer_attempts") == 18 &&
      state.dig("operations", "analyzer_entries") == 18
  fail_build("SUCCESS:LABEL_COUNT") unless
    state.fetch("completed_labels").length == 22
  state["first_unentered_label"] = nil
  state["first_unentered_ordinal_one_based"] = nil
  phase = "FINAL_SDK_REVALIDATION"
  revalidate_sdk!(
    state.dig("source_and_tool_admission", "sdk"), phase
  )
  state["sdk_revalidation_count"] += 1
  phase = "FINAL_ARTIFACT_REVALIDATION"
  revalidate_held_artifacts!(state, phase)
  fail_build("SUCCESS:SDK_REVALIDATION_COUNT") unless
    state.fetch("sdk_revalidation_count") == 5
  fail_build("SUCCESS:ARTIFACT_REVALIDATION_COUNT") unless
    state.fetch("artifact_revalidation_count") == 37
  phase = "ARTIFACT_CLOSE"
  close_artifacts(state, strict: true)
  phase = "ROOT_CLOSE"
  close_roots(state, strict: true)
  BUILD_ROOTS.each_key do |label|
    state.fetch("terminal_root_snapshots")[label] =
      state.dig("artifacts", label)
  end
  phase = "PASS_RECEIPT_CONSTRUCTION"
  requested_exit = 0
rescue StandardError => error
  primary_error = error
  ordered_index = ORDERED_LABELS.index(phase)
  last_command = state.fetch("commands").last
  process_entry_observed = last_command &&
    last_command.fetch("label") == phase && !last_command.fetch("pid").nil?
  state["failure_position"] = {
    "attempted_label" => ordered_index ? phase : nil,
    "attempted_ordinal_one_based" => ordered_index ? ordered_index + 1 : nil,
    "entered_label" => process_entry_observed ? phase : nil,
    "entered_ordinal_one_based" => process_entry_observed ?
      ordered_index + 1 : nil,
    "failed_ordered_label" => ordered_index ? phase : nil,
    "failed_ordered_ordinal_one_based" => ordered_index ? ordered_index + 1 : nil,
    "process_entry_observed" => !!process_entry_observed,
    "phase" => phase,
  }
  close_artifacts(state, strict: false)
  close_roots(state, strict: false)
  BUILD_ROOTS.each do |label, path|
    state.fetch("terminal_root_snapshots")[label] = safe_root_snapshot(path)
  end
ensure
  close_artifacts(state, strict: false) unless
    state.fetch("artifact_ios").values.flat_map(&:values).all?(&:closed?)
  close_roots(state, strict: false) unless
    state.fetch("root_ios").values.all?(&:closed?)
end

receipt_status = requested_exit.zero? ?
  "PASS_TWO_BUILD_NATIVE_BUNDLE_IDENTICAL_UNEXECUTED" :
  "FAIL_CONSUMED_NO_RETRY"
failure = primary_error && diagnostic(primary_error, phase)
state.fetch("operations")["receipt_creation_attempts"] += 1
receipt_value = build_receipt(state, receipt_status, failure)

begin
  publication = publish_receipt!(receipt_value)
  if requested_exit.zero?
    exit(0)
  end
  outer = {
    "failure" => failure,
    "receipt" => publication,
    "schema" => "ergentics-r19-obs11-c2-fchmod-bundle-build-outer-failure-v7",
    "status" => "FAIL_CONSUMED_NO_RETRY",
  }
  bytes = canonical_json(outer) + "\n"
  fail_build("OUTER_FAILURE:CAP") if bytes.bytesize > OUTER_FAILURE_CAP
  STDERR.write(bytes)
  exit(70)
rescue SystemExit
  raise
rescue StandardError => publication_error
  outer = {
    "build_failure" => failure,
    "publication_failure" => diagnostic(publication_error, "RECEIPT_PUBLICATION"),
    "schema" => "ergentics-r19-obs11-c2-fchmod-bundle-build-outer-failure-v7",
    "status" => "FAIL_CONSUMED_NO_RETRY",
  }
  bytes = canonical_json(outer) + "\n"
  bytes = canonical_json({
    "schema" => "ergentics-r19-obs11-c2-fchmod-bundle-build-outer-failure-v7",
    "status" => "FAIL_CONSUMED_NO_RETRY_DIAGNOSTIC_TRUNCATED",
    "sha256" => Digest::SHA256.hexdigest(bytes),
  }) + "\n" if bytes.bytesize > OUTER_FAILURE_CAP
  STDERR.write(bytes)
  exit(70)
end
