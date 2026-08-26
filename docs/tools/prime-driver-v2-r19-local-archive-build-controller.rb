require "base64"
require "digest"
require "fcntl"
require "json"

Thread.abort_on_exception = false

class BuildFailure < StandardError
  attr_reader :code

  def initialize(code)
    @code = code
    super(code)
  end
end

F_FULLFSYNC = 51
O_NOFOLLOW_ANY = 0x20000000
O_DIRECTORY = 0x00100000
O_CLOEXEC = 0x01000000
JOURNAL_MAX_BYTES = 67_108_864
JOURNAL_TERMINAL_RESERVE_BYTES = 1_048_576
CONTROLLER_PAYLOAD_SHA256 = "3bdda381319bea8ba4b0c2d24ae949793800924e8e6d9ef5e818868106d06bf7"
CONTROLLER_ENVIRONMENT = {"__CF_USER_TEXT_ENCODING"=>"0x1F5:0x0:0x0"}.freeze

REPO = "/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.phase-a-v2-fixture-identity-restore-only-staging"
SOURCE_C = "#{REPO}/docs/tools/prime-driver-v2-r19-local-archive-publisher-fixed-openat.c"
SOURCE_H = "#{REPO}/docs/tools/prime-driver-v2-r19-local-archive-publisher-fixed-openat.h"
SOURCE_SWIFT = "#{REPO}/docs/tools/prime-driver-v2-r19-local-archive-publisher.swift"

TMP_PARENT = "/private/tmp"
A_ROOT = "/private/tmp/prime-driver-v2-r19-local-archive-publisher-source-repair1-build-a-a9129484-d2f23691"
B_ROOT = "/private/tmp/prime-driver-v2-r19-local-archive-publisher-source-repair1-build-b-a9129484-d2f23691"
JOURNAL_LEAF = "00-build-controller-journal.jsonl"
OBJECT_LEAF = "prime-driver-v2-r19-local-archive-publisher-fixed-openat.o"
PRODUCT_LEAF = "PrimeDriverV2R19LocalArchivePublisher"

ARCHIVE_PARENT = "/Users/ergentics/Documents"
ARCHIVE_STAGING = "#{ARCHIVE_PARENT}/.PrimeValidationLocalArchive-R19-ce8e584e-f6a03155d136-staging"
ARCHIVE_FINAL = "#{ARCHIVE_PARENT}/PrimeValidationLocalArchive-R19-ce8e584e-f6a03155d136"

SDK = "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX26.5.sdk"
SDK_SETTINGS = "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/SDKSettings.json"
SDK_STDIO = "#{SDK}/usr/include/stdio.h"
SDK_UNDERSCORE_STDIO = "#{SDK}/usr/include/_stdio.h"
SDK_SYS_STDIO = "#{SDK}/usr/include/sys/stdio.h"
CLANG = "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang"
SWIFTC = "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swiftc"
SWIFT_DRIVER = "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-driver"
SWIFT_FRONTEND = "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-frontend"
LD = "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/ld"
LLVM_NM = "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/llvm-nm"
FILE_TOOL = "/usr/bin/file"
OTOOL = "/usr/bin/otool"
CODESIGN = "/usr/bin/codesign"
XATTR = "/usr/bin/xattr"

SOURCE_EXPECTED = {
  SOURCE_C => {"bytes_decimal"=>"11778", "device_decimal"=>"16777231", "inode_decimal"=>"17529977", "uid_decimal"=>"501", "gid_decimal"=>"20", "mode"=>"0644", "nlink_decimal"=>"1", "sha256"=>"e3fd8ce85290107026d1b37e948d6ff57112b448f2705c3010ec9d87f63dd77a"},
  SOURCE_H => {"bytes_decimal"=>"2145", "device_decimal"=>"16777231", "inode_decimal"=>"17529976", "uid_decimal"=>"501", "gid_decimal"=>"20", "mode"=>"0644", "nlink_decimal"=>"1", "sha256"=>"b7546f62ca79a341de90a6dda51eafaa70ec9734ee35aca964bfc99eca1de2b8"},
  SOURCE_SWIFT => {"bytes_decimal"=>"110080", "device_decimal"=>"16777231", "inode_decimal"=>"17530055", "uid_decimal"=>"501", "gid_decimal"=>"20", "mode"=>"0644", "nlink_decimal"=>"1", "sha256"=>"5970f3df699d772314617ef7b1648df8a698df49814f8866b121c39c8b841baf"}
}.freeze

HEADER_EXPECTED = {
  SDK_STDIO => {"bytes_decimal"=>"3069", "device_decimal"=>"16777231", "inode_decimal"=>"1017554", "uid_decimal"=>"0", "gid_decimal"=>"0", "mode"=>"0644", "nlink_decimal"=>"1", "sha256"=>"d2220614f42d3cb678ae0de176ba0ab3256e15fb45b3efdb5d17b8ac1f6a4b54"},
  SDK_UNDERSCORE_STDIO => {"bytes_decimal"=>"20526", "device_decimal"=>"16777231", "inode_decimal"=>"931744", "uid_decimal"=>"0", "gid_decimal"=>"0", "mode"=>"0644", "nlink_decimal"=>"9", "sha256"=>"8417242466f6df6890587974393e97bb0aeac8caeb80cdf82a4e03a97e6d4660"},
  SDK_SYS_STDIO => {"bytes_decimal"=>"2415", "device_decimal"=>"16777231", "inode_decimal"=>"1016683", "uid_decimal"=>"0", "gid_decimal"=>"0", "mode"=>"0644", "nlink_decimal"=>"1", "sha256"=>"a8078ae1cba1a46a66d0de6fe7f13bbc969cdb7e78fc2d4b9a5c5cdaaf16126b"}
}.freeze

TOOL_EXPECTED = {
  "/usr/bin/ruby" => {"bytes_decimal"=>"135200", "device_decimal"=>"16777231", "inode_decimal"=>"1152921500312572705", "uid_decimal"=>"0", "gid_decimal"=>"0", "mode"=>"0555", "nlink_decimal"=>"1", "sha256"=>"9d6ff3e289c7d908e3c785e0bedd6692d1d6a3377965c88c04d847104b7c892c"},
  CLANG => {"bytes_decimal"=>"141373024", "device_decimal"=>"16777231", "inode_decimal"=>"1118318", "uid_decimal"=>"0", "gid_decimal"=>"0", "mode"=>"0755", "nlink_decimal"=>"1", "sha256"=>"7def90dd8829726686213a747fc5bff1583df933dae5edc55d755479e0bfe00a"},
  SWIFT_DRIVER => {"bytes_decimal"=>"3011968", "device_decimal"=>"16777231", "inode_decimal"=>"1118459", "uid_decimal"=>"0", "gid_decimal"=>"0", "mode"=>"0755", "nlink_decimal"=>"1", "sha256"=>"fead52ebe00ec6ec700ecbb4be30f0b6204dd0506cb271dda72ac257261bd64b"},
  SWIFT_FRONTEND => {"bytes_decimal"=>"171036592", "device_decimal"=>"16777231", "inode_decimal"=>"1118375", "uid_decimal"=>"0", "gid_decimal"=>"0", "mode"=>"0755", "nlink_decimal"=>"1", "sha256"=>"2ed38571e92c0283091838c1649e27650ad9c99950288e883c7b2dc6c4ce89fb"},
  LD => {"bytes_decimal"=>"2331792", "device_decimal"=>"16777231", "inode_decimal"=>"1118358", "uid_decimal"=>"0", "gid_decimal"=>"0", "mode"=>"0755", "nlink_decimal"=>"1", "sha256"=>"5897b275efd93b201b6df5832dd541262b3f20f290859ba78f2200a6a66ef38b"},
  LLVM_NM => {"bytes_decimal"=>"16380560", "device_decimal"=>"16777231", "inode_decimal"=>"1118384", "uid_decimal"=>"0", "gid_decimal"=>"0", "mode"=>"0755", "nlink_decimal"=>"1", "sha256"=>"d910f3acb104791e5475254000ede2aa129aa1a42eafcc7f5bdb27afffc642dc"},
  FILE_TOOL => {"bytes_decimal"=>"534480", "device_decimal"=>"16777231", "inode_decimal"=>"1152921500312572000", "uid_decimal"=>"0", "gid_decimal"=>"0", "mode"=>"0755", "nlink_decimal"=>"1", "sha256"=>"a4ba66d26a9cfdc70637c78cdacef920f94147f6aa45ccc73858e493589ef94d"},
  OTOOL => {"bytes_decimal"=>"118928", "device_decimal"=>"16777231", "inode_decimal"=>"1152921500312571585", "uid_decimal"=>"0", "gid_decimal"=>"0", "mode"=>"0755", "nlink_decimal"=>"78", "sha256"=>"179301dcb41ea78accc3fa0048a7e6f6710d891945a751a34addd622020c1818"},
  CODESIGN => {"bytes_decimal"=>"459824", "device_decimal"=>"16777231", "inode_decimal"=>"1152921500312571780", "uid_decimal"=>"0", "gid_decimal"=>"0", "mode"=>"0755", "nlink_decimal"=>"1", "sha256"=>"214d455584d19abc0d74d02b9cbc7d3da6bdcb0596c235e6156dd9ed2f4e1ba7"},
  XATTR => {"bytes_decimal"=>"118896", "device_decimal"=>"16777231", "inode_decimal"=>"1152921500312573128", "uid_decimal"=>"0", "gid_decimal"=>"0", "mode"=>"0755", "nlink_decimal"=>"1", "sha256"=>"3cc7308e9dfd687b0b7f4778a6101633aa9dce5ccdd012cf17cd858848295162"},
  SDK_SETTINGS => {"bytes_decimal"=>"7774", "device_decimal"=>"16777231", "inode_decimal"=>"1082899", "uid_decimal"=>"0", "gid_decimal"=>"0", "mode"=>"0644", "nlink_decimal"=>"1", "sha256"=>"f8d005f09381389167f9e0aeaa169bc9e7dff162ef22ca2fd8e98df7ff1acafe"}
}.freeze

DEFINED_C_SYMBOLS = %w[
  _prime_r19_archive_create_directory
  _prime_r19_archive_create_leaf
  _prime_r19_archive_create_staging_root
  _prime_r19_archive_destination_absent
  _prime_r19_archive_full_fsync
  _prime_r19_archive_get_xattr
  _prime_r19_archive_list_xattrs
  _prime_r19_archive_open_directory
  _prime_r19_archive_open_leaf
  _prime_r19_archive_open_node
  _prime_r19_archive_open_root
  _prime_r19_archive_parent_volume_uuid
  _prime_r19_archive_publish
  _prime_r19_archive_validate_parent_filesystem
  _prime_r19_archive_validate_stdin_devnull
].sort.freeze

OBJECT_UNDEFINED_ALLOWED = %w[
  ___error ___stack_chk_fail ___stack_chk_guard _bzero _close _fcntl
  _fgetattrlist _fgetxattr _flistxattr _fstat _fstatat _fstatfs _fsync
  _memcpy _memset _mkdirat _open _openat _renameatx_np _strcmp
].freeze

FORBIDDEN_PRODUCT_SYMBOLS = %w[
  _accept _accept4 _bind _connect _copyfile _dlopen _dlsym _execv _execve
  _execvp _execvP _fclonefileat _fork _fremovexattr _fsetxattr _kill
  _killpg _link _linkat _listen _popen _posix_spawn _posix_spawnp _raise
  _recv _recvfrom _recvmsg _removexattr _send _sendmsg _sendto _setxattr
  _signal _sigaction _socket _socketpair _symlink _symlinkat _system
  _unlink _unlinkat _vfork _wait _wait3 _wait4 _waitid _waitpid
].freeze

FORBIDDEN_PRODUCT_SYMBOL_PATTERNS = [
  /\A_(?:posix_spawn.*|fork|vfork|exec.*|wait.*|kill.*|pthread_kill|raise|signal|sigaction|setpgid|setsid)\z/,
  /\A_(?:accept.*|bind|connect|listen|socket.*|send.*|recv.*|getaddrinfo|freeaddrinfo|gethostbyname.*)\z/,
  /\A_(?:system|popen|dlopen|dlsym|dlclose)\z/,
  /\A_(?:copyfile.*|clonefile.*|fclonefileat|link|linkat|symlink|symlinkat|unlink|unlinkat|remove|rmdir)\z/,
  /\A_(?:setxattr|fsetxattr|removexattr|fremovexattr)\z/,
  /NSTask/
].freeze

ALLOWED_LINKED_IMAGES = %w[
  /usr/lib/libSystem.B.dylib
  /System/Library/Frameworks/CryptoKit.framework/Versions/A/CryptoKit
  /System/Library/Frameworks/Foundation.framework/Versions/C/Foundation
  /usr/lib/libobjc.A.dylib
  /usr/lib/swift/libswiftCore.dylib
  /usr/lib/swift/libswiftCoreFoundation.dylib
  /usr/lib/swift/libswiftDarwin.dylib
  /usr/lib/swift/libswiftDispatch.dylib
  /usr/lib/swift/libswiftIOKit.dylib
  /usr/lib/swift/libswiftObjectiveC.dylib
  /usr/lib/swift/libswiftXPC.dylib
  /usr/lib/swift/libswift_Concurrency.dylib
  /usr/lib/swift/libswift_Builtin_float.dylib
  /usr/lib/swift/libswift_errno.dylib
].freeze

def fail_build(code)
  raise BuildFailure, code
end

def deep_sort(value)
  case value
  when Hash
    value.keys.sort.each_with_object({}) { |key, out| out[key] = deep_sort(value.fetch(key)) }
  when Array
    value.map { |item| deep_sort(item) }
  else
    value
  end
end

def canonical_json(value)
  JSON.generate(deep_sort(value))
end

def mode_string(stat)
  format("%04o", stat.mode & 0o7777)
end

def read_all_from_descriptor(io)
  digest = Digest::SHA256.new
  total = 0
  io.rewind
  loop do
    chunk = io.read(65_536)
    break if chunk.nil? || chunk.empty?
    digest.update(chunk)
    total += chunk.bytesize
  end
  io.rewind
  [total.to_s, digest.hexdigest]
end

def identity_from_held(io)
  stat = io.stat
  fail_build("HELD_NOT_REGULAR") unless stat.file?
  bytes, sha = read_all_from_descriptor(io)
  {
    "bytes_decimal"=>bytes,
    "device_decimal"=>stat.dev.to_s,
    "inode_decimal"=>stat.ino.to_s,
    "uid_decimal"=>stat.uid.to_s,
    "gid_decimal"=>stat.gid.to_s,
    "mode"=>mode_string(stat),
    "nlink_decimal"=>stat.nlink.to_s,
    "sha256"=>sha
  }
end

def held_regular(path)
  fd = IO.sysopen(path, File::RDONLY | O_NOFOLLOW_ANY | O_CLOEXEC)
  io = File.new(fd, "rb")
  stat = io.stat
  fail_build("NOT_REGULAR:#{path}") unless stat.file?
  bytes, sha = read_all_from_descriptor(io)
  identity = {
    "bytes_decimal"=>bytes,
    "device_decimal"=>stat.dev.to_s,
    "inode_decimal"=>stat.ino.to_s,
    "uid_decimal"=>stat.uid.to_s,
    "gid_decimal"=>stat.gid.to_s,
    "mode"=>mode_string(stat),
    "nlink_decimal"=>stat.nlink.to_s,
    "sha256"=>sha
  }
  [io, identity]
rescue StandardError
  io.close if defined?(io) && io && !io.closed?
  raise
end

def require_identity(path, expected)
  io, observed = held_regular(path)
  fail_build("IDENTITY_MISMATCH:#{path}") unless observed == expected
  close_error = safe_close(io)
  fail_build("IDENTITY_CLOSE_FAILED:#{path}") if close_error
  observed
end

def require_named_join(path, io)
  named_fd = IO.sysopen(path, File::RDONLY | O_NOFOLLOW_ANY | O_CLOEXEC)
  named = File.new(named_fd, "rb")
  a = io.stat
  b = named.stat
  fail_build("NAMED_JOIN_MISMATCH:#{path}") unless a.dev == b.dev && a.ino == b.ino
  named.close
  true
rescue StandardError
  named.close if defined?(named) && named && !named.closed?
  raise
end

def require_held_identity(path, io, expected)
  require_named_join(path, io)
  observed = identity_from_held(io)
  fail_build("HELD_IDENTITY_DRIFT:#{path}") unless observed == expected
  observed
end

def open_directory(path)
  fd = IO.sysopen(path, File::RDONLY | O_NOFOLLOW_ANY | O_DIRECTORY | O_CLOEXEC)
  io = File.new(fd, "r")
  fail_build("NOT_DIRECTORY:#{path}") unless io.stat.directory?
  io
end

def require_directory_join(path, io, expected_mode)
  named = open_directory(path)
  held_stat = io.stat
  named_stat = named.stat
  fail_build("DIRECTORY_JOIN_MISMATCH:#{path}") unless held_stat.dev == named_stat.dev && held_stat.ino == named_stat.ino
  [held_stat, named_stat].each do |stat|
    fail_build("DIRECTORY_TYPE_DRIFT:#{path}") unless stat.directory?
    fail_build("DIRECTORY_MODE_DRIFT:#{path}") unless mode_string(stat) == expected_mode
  end
  fail_build("DIRECTORY_UID_DRIFT:#{path}") unless held_stat.uid == named_stat.uid
  fail_build("DIRECTORY_GID_DRIFT:#{path}") unless held_stat.gid == named_stat.gid
  result = {
    "device_decimal"=>held_stat.dev.to_s,
    "gid_decimal"=>held_stat.gid.to_s,
    "inode_decimal"=>held_stat.ino.to_s,
    "mode"=>mode_string(held_stat),
    "nlink_decimal"=>held_stat.nlink.to_s,
    "uid_decimal"=>held_stat.uid.to_s
  }
  named.close
  result
rescue StandardError
  named.close if defined?(named) && named && !named.closed?
  raise
end

def durable_sync(io, code)
  fail_build("FSYNC_FAILED:#{code}") unless io.fsync == 0
  fail_build("FULLFSYNC_FAILED:#{code}") unless io.fcntl(F_FULLFSYNC, 0) == 0
end

def require_absent(path, code)
  File.lstat(path)
  fail_build("EXPECTED_ABSENT:#{code}")
rescue Errno::ENOENT
  true
end

def require_parent_identity(path, expected)
  stat = File.lstat(path)
  observed = {
    "device_decimal"=>stat.dev.to_s,
    "inode_decimal"=>stat.ino.to_s,
    "uid_decimal"=>stat.uid.to_s,
    "gid_decimal"=>stat.gid.to_s,
    "mode"=>mode_string(stat),
    "type"=>(stat.directory? ? "DIRECTORY" : "OTHER")
  }
  fail_build("PARENT_IDENTITY_MISMATCH:#{path}") unless observed == expected
  observed
end

class DurableJournal
  attr_reader :sealed

  def initialize(root, root_io, parent_io)
    @root = root
    @root_io = root_io
    @parent_io = parent_io
    @path = "#{root}/#{JOURNAL_LEAF}"
    flags = File::WRONLY | File::CREAT | File::EXCL | File::APPEND | O_NOFOLLOW_ANY | O_CLOEXEC
    fd = IO.sysopen(@path, flags, 0o400)
    @io = File.new(fd, "ab")
    @sequence = 0
    @previous = "0" * 64
    @bytes = 0
    @append_failed = false
    @terminal_started = false
    @sealed = false
    verify_named
  end

  def writable?
    !@sealed && !@append_failed && !@terminal_started
  end

  def verify_named
    fail_build("JOURNAL_HELD_NOT_REGULAR") unless @io.stat.file?
    fail_build("JOURNAL_HELD_MODE") unless mode_string(@io.stat) == "0400"
    fail_build("JOURNAL_HELD_NLINK") unless @io.stat.nlink == 1
    named_fd = IO.sysopen(@path, File::RDONLY | O_NOFOLLOW_ANY | O_CLOEXEC)
    named = File.new(named_fd, "rb")
    fail_build("JOURNAL_NAMED_NOT_REGULAR") unless named.stat.file?
    fail_build("JOURNAL_NAMED_JOIN") unless named.stat.dev == @io.stat.dev && named.stat.ino == @io.stat.ino
    fail_build("JOURNAL_NAMED_MODE") unless mode_string(named.stat) == "0400"
    fail_build("JOURNAL_NAMED_NLINK") unless named.stat.nlink == 1
    fail_build("JOURNAL_NAMED_SIZE") unless named.stat.size == @bytes
    named.close
    require_directory_join(@root, @root_io, "0700")
    require_directory_join(TMP_PARENT, @parent_io, "1777")
    true
  rescue StandardError
    named.close if defined?(named) && named && !named.closed?
    raise
  end

  def append(event, terminal=false)
    fail_build("JOURNAL_ALREADY_SEALED") if @sealed
    fail_build("JOURNAL_APPEND_POISONED") if @append_failed
    fail_build("JOURNAL_TERMINAL_ALREADY_STARTED") if @terminal_started && !terminal
    verify_named
    core = {
      "event"=>event,
      "predecessor_record_sha256"=>@previous,
      "sequence_decimal"=>@sequence.to_s
    }
    digest = Digest::SHA256.hexdigest(canonical_json(core))
    frame = core.merge("record_sha256"=>digest)
    bytes = canonical_json(frame) + "\n"
    limit = terminal ? JOURNAL_MAX_BYTES : JOURNAL_MAX_BYTES - JOURNAL_TERMINAL_RESERVE_BYTES
    fail_build("JOURNAL_BYTE_CAP") if @bytes + bytes.bytesize > limit
    @append_failed = true
    offset = 0
    while offset < bytes.bytesize
      written = @io.write(bytes.byteslice(offset, bytes.bytesize - offset))
      fail_build("JOURNAL_SHORT_WRITE") unless written && written > 0
      offset += written
    end
    @io.flush
    durable_sync(@io, "JOURNAL_APPEND")
    @bytes += bytes.bytesize
    verify_named
    @previous = digest
    @sequence += 1
    @append_failed = false
    digest
  end

  def validate_readback
    named_fd = IO.sysopen(@path, File::RDONLY | O_NOFOLLOW_ANY | O_CLOEXEC)
    named = File.new(named_fd, "rb")
    bytes = named.read(JOURNAL_MAX_BYTES + 1)
    fail_build("JOURNAL_READBACK_CAP") if bytes.bytesize > JOURNAL_MAX_BYTES
    fail_build("JOURNAL_READBACK_SIZE") unless bytes.bytesize == @bytes
    fail_build("JOURNAL_READBACK_LF") unless bytes.empty? || bytes.end_with?("\n")
    previous = "0" * 64
    count = 0
    bytes.lines.each do |line|
      fail_build("JOURNAL_READBACK_FRAME_LF") unless line.end_with?("\n")
      frame = JSON.parse(line.byteslice(0, line.bytesize - 1))
      digest = frame.fetch("record_sha256")
      core = frame.reject { |key, _| key == "record_sha256" }
      fail_build("JOURNAL_READBACK_SEQUENCE") unless core.fetch("sequence_decimal") == count.to_s
      fail_build("JOURNAL_READBACK_PREDECESSOR") unless core.fetch("predecessor_record_sha256") == previous
      fail_build("JOURNAL_READBACK_CANONICAL") unless canonical_json(frame) + "\n" == line
      fail_build("JOURNAL_READBACK_DIGEST") unless Digest::SHA256.hexdigest(canonical_json(core)) == digest
      previous = digest
      count += 1
    end
    fail_build("JOURNAL_READBACK_COUNT") unless count == @sequence
    fail_build("JOURNAL_READBACK_TAIL") unless previous == @previous
    named.close
    true
  rescue StandardError
    named.close if defined?(named) && named && !named.closed?
    raise
  end

  def append_terminal_and_seal(event)
    fail_build("JOURNAL_NOT_TERMINAL_READY") unless writable?
    @terminal_started = true
    verify_named
    validate_readback
    fail_build("JOURNAL_FCHMOD_FAILED") unless @io.chmod(0o400) == 0
    durable_sync(@io, "JOURNAL_PRETERMINAL")
    durable_sync(@root_io, "A_ROOT_PRETERMINAL")
    durable_sync(@parent_io, "TMP_PARENT_PRETERMINAL")
    verify_named
    validate_readback
    append(event, true)
    @sealed = true
  end

  def retain_prefix_unchecked
    @io.chmod(0o400)
    @io.fsync
    @io.fcntl(F_FULLFSYNC, 0)
    @root_io.fsync
    @root_io.fcntl(F_FULLFSYNC, 0)
    @parent_io.fsync
    @parent_io.fcntl(F_FULLFSYNC, 0)
  rescue StandardError
  end

  def close_unchecked
    @io.close unless @io.closed?
  rescue StandardError
  end
end

def stream_capture_blocking(io, cap)
  digest = Digest::SHA256.new
  prefix = "".b
  total = 0
  capture_error = nil
  loop do
    begin
      chunk = io.readpartial(65_536)
    rescue Errno::EINTR
      next
    rescue EOFError
      break
    rescue StandardError => error
      capture_error = error.class.name
      break
    end
    digest.update(chunk)
    total += chunk.bytesize
    if prefix.bytesize < cap
      take = [cap - prefix.bytesize, chunk.bytesize].min
      prefix << chunk.byteslice(0, take)
    end
  end
  close_error = safe_close(io)
  capture_error ||= close_error
  {
    "bytes_decimal"=>total.to_s,
    "capture_error"=>capture_error,
    "overflow"=>total > cap,
    "prefix_base64"=>Base64.strict_encode64(prefix),
    "prefix_bytes_decimal"=>prefix.bytesize.to_s,
    "sha256"=>digest.hexdigest,
    "raw"=>prefix
  }
end

def safe_close(io)
  return nil if io.nil? || io.closed?
  io.close
  nil
rescue Errno::EINTR
  retry
rescue StandardError
  "CLOSE_UNKNOWN"
end

def remain_in_reap_containment
  loop { sleep(3600) }
end

def public_capture(capture)
  capture.reject { |key, _| key == "raw" }
end

def require_held_devnull(io)
  stat = io.stat
  fail_build("DEVNULL_NOT_CHARACTER") unless stat.chardev?
  fail_build("DEVNULL_MODE") unless mode_string(stat) == "0666"
  flags = io.fcntl(Fcntl::F_GETFL, 0)
  fail_build("DEVNULL_ACCESS_MODE") unless (flags & Fcntl::O_ACCMODE) == Fcntl::O_RDONLY
  named_fd = IO.sysopen("/dev/null", File::RDONLY | O_NOFOLLOW_ANY | O_CLOEXEC)
  named = File.new(named_fd, "rb")
  fail_build("DEVNULL_NAMED_JOIN") unless named.stat.dev == stat.dev && named.stat.ino == stat.ino && named.stat.chardev?
  named.close
  true
rescue StandardError
  named.close if defined?(named) && named && !named.closed?
  raise
end

def child_environment(root)
  {
    "DEVELOPER_DIR"=>"/Applications/Xcode.app/Contents/Developer",
    "LANG"=>"C.UTF-8",
    "LC_ALL"=>"C.UTF-8",
    "PATH"=>"/usr/bin:/bin",
    "SDKROOT"=>SDK,
    "TMPDIR"=>"#{root}/tmp/",
    "TZ"=>"UTC",
    "__CF_USER_TEXT_ENCODING"=>"0x1F5:0x0:0x0"
  }
end

def run_child(journal, label, argv, environment, cap)
  journal.append({
    "argv"=>argv,
    "capture_cap_bytes_decimal"=>cap.to_s,
    "cwd"=>"/",
    "environment_sorted"=>environment.keys.sort.map { |key| "#{key}=#{environment.fetch(key)}" },
    "label"=>label,
    "type"=>"CHILD_ENTRY_COMMITMENT"
  })

  pid = nil
  begin
    stdout_r, stdout_w = IO.pipe
    stderr_r, stderr_w = IO.pipe
    stdout_thread = Thread.new { stream_capture_blocking(stdout_r, cap) }
    stderr_thread = Thread.new { stream_capture_blocking(stderr_r, cap) }
    stdout_thread.report_on_exception = false if stdout_thread.respond_to?(:report_on_exception=)
    stderr_thread.report_on_exception = false if stderr_thread.respond_to?(:report_on_exception=)
    devnull_fd = IO.sysopen("/dev/null", File::RDONLY | O_NOFOLLOW_ANY | O_CLOEXEC)
    devnull = File.new(devnull_fd, "rb")
    require_held_devnull(devnull)
    pid = Process.spawn(
      environment,
      [argv.fetch(0), argv.fetch(0)],
      *argv.drop(1),
      :chdir=>"/",
      :in=>devnull,
      :out=>stdout_w,
      :err=>stderr_w,
      :close_others=>true,
      :unsetenv_others=>true
    )
  rescue StandardError
    safe_close(stdout_w) if defined?(stdout_w)
    safe_close(stderr_w) if defined?(stderr_w)
    safe_close(devnull) if defined?(devnull)
    stdout_thread.value if defined?(stdout_thread) && stdout_thread
    stderr_thread.value if defined?(stderr_thread) && stderr_thread
    safe_close(stdout_r) if defined?(stdout_r)
    safe_close(stderr_r) if defined?(stderr_r)
    raise
  end

  close_errors = [safe_close(stdout_w), safe_close(stderr_w), safe_close(devnull)].compact
  stdout_capture = stdout_thread.value
  stderr_capture = stderr_thread.value
  begin
    waited_pid, status = Process.wait2(pid)
  rescue Errno::EINTR
    retry
  rescue StandardError
    remain_in_reap_containment
  end
  remain_in_reap_containment unless waited_pid == pid
  fail_build("POST_SPAWN_CLOSE_FAILURE:#{label}") unless close_errors.empty?
  result = {
    "exited"=>status.exited?,
    "exit_status_decimal"=>(status.exited? ? status.exitstatus.to_s : nil),
    "label"=>label,
    "pid_decimal"=>pid.to_s,
    "signaled"=>status.signaled?,
    "termsig_decimal"=>(status.signaled? ? status.termsig.to_s : nil),
    "stdout"=>public_capture(stdout_capture),
    "stderr"=>public_capture(stderr_capture),
    "type"=>"CHILD_TERMINAL"
  }
  journal.append(result)
  result.merge("stdout_raw"=>stdout_capture.fetch("raw"), "stderr_raw"=>stderr_capture.fetch("raw"))
end

def require_normal_zero(result, code, require_silent)
  fail_build("#{code}:NOT_NORMAL_ZERO") unless result.fetch("exited") && result.fetch("exit_status_decimal") == "0" && !result.fetch("signaled")
  fail_build("#{code}:STDOUT_OVERFLOW") if result.fetch("stdout").fetch("overflow")
  fail_build("#{code}:STDERR_OVERFLOW") if result.fetch("stderr").fetch("overflow")
  fail_build("#{code}:STDOUT_CAPTURE_ERROR") if result.fetch("stdout").fetch("capture_error")
  fail_build("#{code}:STDERR_CAPTURE_ERROR") if result.fetch("stderr").fetch("capture_error")
  if require_silent
    fail_build("#{code}:STDOUT_NOT_EMPTY") unless result.fetch("stdout").fetch("bytes_decimal") == "0"
    fail_build("#{code}:STDERR_NOT_EMPTY") unless result.fetch("stderr").fetch("bytes_decimal") == "0"
  end
  true
end

def compiler_argv(root)
  object = "#{root}/#{OBJECT_LEAF}"
  product = "#{root}/#{PRODUCT_LEAF}"
  c = [
    CLANG, "-target", "arm64-apple-macosx14.0", "-isysroot", SDK,
    "-std=c17", "-O2", "-fvisibility=hidden", "-fno-common", "-Wall",
    "-Wextra", "-Werror", "-fno-modules", "-fno-implicit-modules",
    "-c", SOURCE_C, "-o", object
  ]
  swift = [
    SWIFTC, "-swift-version", "6", "-O", "-whole-module-optimization",
    "-parse-as-library", "-emit-executable", "-target", "arm64-apple-macosx14.0",
    "-sdk", SDK, "-module-name", "PrimeDriverV2R19LocalArchivePublisher",
    "-module-cache-path", "#{root}/module-cache", "-import-objc-header", SOURCE_H,
    SOURCE_SWIFT, object, "-o", product
  ]
  [c, swift]
end

def analyzer_argv(root)
  object = "#{root}/#{OBJECT_LEAF}"
  product = "#{root}/#{PRODUCT_LEAF}"
  [
    ["object-defined", [LLVM_NM, "--defined-only", "--extern-only", object]],
    ["object-undefined", [LLVM_NM, "-u", object]],
    ["product-file", [FILE_TOOL, "-b", product]],
    ["product-otool-header", [OTOOL, "-hv", product]],
    ["product-otool-load-commands", [OTOOL, "-l", product]],
    ["product-otool-linked-images", [OTOOL, "-L", product]],
    ["product-codesign-verify", [CODESIGN, "--verify", "--strict", "--verbose=4", product]],
    ["product-codesign-display", [CODESIGN, "-d", "--verbose=4", product]],
    ["product-xattrs", [XATTR, "-l", product]],
    ["product-undefined", [LLVM_NM, "-u", product]]
  ]
end

def extract_nm_symbols(bytes)
  bytes.lines.map { |line| line.strip.split(/\s+/).last }.compact.reject(&:empty?).sort
end

def parse_macho(io)
  file_size = io.stat.size
  io.rewind
  header = io.read(32)
  fail_build("MACHO_HEADER_SHORT") unless header && header.bytesize == 32
  values = header.unpack("L<8")
  magic, cpu_type, cpu_subtype, file_type, command_count, command_bytes, flags, reserved = values
  fail_build("MACHO_MAGIC") unless magic == 0xfeedfacf
  fail_build("MACHO_CPU") unless cpu_type == 0x0100000c
  fail_build("MACHO_CPU_SUBTYPE") unless (cpu_subtype & 0x00ffffff) == 0
  fail_build("MACHO_FILETYPE") unless file_type == 2
  fail_build("MACHO_FLAGS") unless flags == 0x00200085
  fail_build("MACHO_RESERVED") unless reserved == 0
  fail_build("MACHO_COMMAND_CAP") unless command_count <= 128 && command_bytes <= 1_048_576
  fail_build("MACHO_COMMAND_FILE_BOUNDS") if 32 + command_bytes > file_size

  commands = io.read(command_bytes)
  fail_build("MACHO_COMMANDS_SHORT") unless commands && commands.bytesize == command_bytes
  offset = 0
  uuid = nil
  build = nil
  main = nil
  signature = nil
  command_digests = []
  seen = Hash.new(0)
  command_count.times do
    fail_build("MACHO_COMMAND_HEADER") if offset + 8 > commands.bytesize
    command, size = commands.byteslice(offset, 8).unpack("L<2")
    fail_build("MACHO_COMMAND_SIZE") if size < 8 || (size % 8) != 0 || offset + size > commands.bytesize
    bytes = commands.byteslice(offset, size)
    command_digests << {"command_hex"=>format("0x%08x", command), "sha256"=>Digest::SHA256.hexdigest(bytes), "size_decimal"=>size.to_s}
    case command
    when 0x1b
      seen["uuid"] += 1
      fail_build("MACHO_UUID_SIZE") unless size == 24
      raw = bytes.byteslice(8, 16).unpack("C16")
      hex = raw.map { |value| format("%02X", value) }.join
      uuid = "#{hex[0,8]}-#{hex[8,4]}-#{hex[12,4]}-#{hex[16,4]}-#{hex[20,12]}"
    when 0x32
      seen["build"] += 1
      fail_build("MACHO_BUILD_SIZE") unless size >= 24
      platform, minimum, sdk, tools = bytes.byteslice(8, 16).unpack("L<4")
      fail_build("MACHO_BUILD_TOOL_CAP") if tools > 16
      fail_build("MACHO_BUILD_TOOL_BOUNDS") unless size == 24 + tools * 8
      build = {"minimum_hex"=>format("0x%08x", minimum), "platform_decimal"=>platform.to_s, "sdk_hex"=>format("0x%08x", sdk), "tool_count_decimal"=>tools.to_s}
    when 0x80000028
      seen["main"] += 1
      fail_build("MACHO_MAIN_SIZE") unless size == 24
      entry, stack = bytes.byteslice(8, 16).unpack("Q<2")
      main = {"entryoff_decimal"=>entry.to_s, "stacksize_decimal"=>stack.to_s}
    when 0x1d
      seen["signature"] += 1
      fail_build("MACHO_SIGNATURE_SIZE") unless size == 16
      data_offset, data_size = bytes.byteslice(8, 8).unpack("L<2")
      signature = {"offset_decimal"=>data_offset.to_s, "size_decimal"=>data_size.to_s}
    end
    offset += size
  end
  fail_build("MACHO_COMMAND_COUNT_JOIN") unless offset == commands.bytesize
  %w[uuid build main signature].each { |kind| fail_build("MACHO_#{kind.upcase}_COUNT") unless seen[kind] == 1 }
  fail_build("MACHO_UUID_MISSING") unless uuid
  fail_build("MACHO_BUILD_MISSING") unless build
  fail_build("MACHO_BUILD_PLATFORM") unless build.fetch("platform_decimal") == "1"
  fail_build("MACHO_BUILD_MINIMUM") unless build.fetch("minimum_hex") == "0x000e0000"
  fail_build("MACHO_BUILD_SDK") unless build.fetch("sdk_hex") == "0x001a0500"
  fail_build("MACHO_MAIN_MISSING") unless main
  fail_build("MACHO_SIGNATURE_MISSING") unless signature

  signature_offset = Integer(signature.fetch("offset_decimal"), 10)
  signature_size = Integer(signature.fetch("size_decimal"), 10)
  fail_build("MACHO_SIGNATURE_OFFSET_ALIGNMENT") unless (signature_offset % 16) == 0
  fail_build("MACHO_SIGNATURE_SIZE_CAP") if signature_size < 20 || signature_size > 1_048_576
  fail_build("MACHO_SIGNATURE_BEFORE_COMMANDS") if signature_offset < 32 + command_bytes
  fail_build("MACHO_SIGNATURE_FILE_END") unless signature_offset + signature_size == file_size
  fail_build("MACHO_MAIN_ENTRY_BOUNDS") unless Integer(main.fetch("entryoff_decimal"), 10) < signature_offset
  io.rewind
  io.seek(signature_offset)
  signature_bytes = io.read(signature_size)
  fail_build("MACHO_SIGNATURE_SHORT") unless signature_bytes && signature_bytes.bytesize == signature_size
  code_directory = parse_code_directory(signature_bytes, signature_offset)
  io.rewind
  {
    "build_version"=>build,
    "code_directory"=>code_directory,
    "command_count_decimal"=>command_count.to_s,
    "command_digests"=>command_digests,
    "commands_size_decimal"=>command_bytes.to_s,
    "cpu_subtype_hex"=>format("0x%08x", cpu_subtype),
    "header_flags_hex"=>format("0x%08x", flags),
    "lc_code_signature"=>signature,
    "lc_main"=>main,
    "uuid"=>uuid
  }
end

def parse_code_directory(signature_bytes, signature_offset)
  fail_build("SUPERBLOB_HEADER_SHORT") if signature_bytes.bytesize < 12
  magic, length, count = signature_bytes.byteslice(0, 12).unpack("N3")
  fail_build("SUPERBLOB_MAGIC") unless magic == 0xfade0cc0
  fail_build("SUPERBLOB_LENGTH") if length < 20 || length > signature_bytes.bytesize
  fail_build("SUPERBLOB_PADDING") unless signature_bytes.byteslice(length, signature_bytes.bytesize - length).bytes.all?(&:zero?)
  fail_build("SUPERBLOB_COUNT") unless count == 1
  index_end = 12 + count * 8
  fail_build("SUPERBLOB_INDEX_BOUNDS") if index_end > length
  candidates = []
  observed_slots = {}
  count.times do |index|
    slot_type, offset = signature_bytes.byteslice(12 + index * 8, 8).unpack("N2")
    fail_build("SUPERBLOB_DUPLICATE_SLOT") if observed_slots.key?(slot_type)
    observed_slots[slot_type] = true
    fail_build("SUPERBLOB_BLOB_OFFSET") if offset < index_end || (offset % 4) != 0 || offset + 8 > length
    blob_magic, blob_length = signature_bytes.byteslice(offset, 8).unpack("N2")
    next unless blob_magic == 0xfade0c02
    fail_build("CODEDIRECTORY_LENGTH") if blob_length < 44 || offset + blob_length > length
    candidates << [slot_type, offset, signature_bytes.byteslice(offset, blob_length)]
  end
  primary = candidates.select { |entry| entry[0] == 0 }
  fail_build("PRIMARY_CODEDIRECTORY_COUNT") unless primary.length == 1
  slot_type, blob_offset, bytes = primary.first
  version, flags = bytes.byteslice(8, 8).unpack("N2")
  hash_offset, ident_offset = bytes.byteslice(16, 8).unpack("N2")
  n_special, n_code, code_limit = bytes.byteslice(24, 12).unpack("N3")
  hash_size, hash_type, platform, page_size = bytes.byteslice(36, 4).unpack("C4")
  fail_build("CODEDIRECTORY_VERSION") unless version == 0x20400
  fail_build("CODEDIRECTORY_FLAGS") unless flags == 0x20002
  fail_build("CODEDIRECTORY_SPECIAL_SLOTS") unless n_special == 0
  fail_build("CODEDIRECTORY_HASH_ALGORITHM") unless hash_size == 32 && hash_type == 2
  fail_build("CODEDIRECTORY_PLATFORM") unless platform == 0
  fail_build("CODEDIRECTORY_PAGE_SIZE") unless page_size == 12
  fail_build("CODEDIRECTORY_CODE_LIMIT") unless code_limit == signature_offset
  fail_build("CODEDIRECTORY_CODE_SLOT_COUNT") unless n_code == (code_limit + 4095) / 4096
  fail_build("CODEDIRECTORY_IDENT_OFFSET") if ident_offset < 88 || ident_offset >= bytes.bytesize
  ident_tail = bytes.byteslice(ident_offset, bytes.bytesize - ident_offset)
  terminator = ident_tail.index("\0")
  fail_build("CODEDIRECTORY_IDENTIFIER_TERMINATOR") unless terminator
  identifier = ident_tail.byteslice(0, terminator)
  fail_build("CODEDIRECTORY_IDENTIFIER") unless identifier == PRODUCT_LEAF
  fail_build("CODEDIRECTORY_HASH_OFFSET") if hash_offset <= ident_offset + terminator || hash_offset > bytes.bytesize
  fail_build("CODEDIRECTORY_HASH_BOUNDS") unless hash_offset + n_code * hash_size == bytes.bytesize
  fail_build("CODEDIRECTORY_BLOB_JOIN") unless blob_offset + bytes.bytesize == length
  result = {
    "code_limit_decimal"=>code_limit.to_s,
    "code_slots_decimal"=>n_code.to_s,
    "flags_hex"=>format("0x%08x", flags),
    "full_sha256"=>Digest::SHA256.hexdigest(bytes),
    "hash_size_decimal"=>hash_size.to_s,
    "hash_type_decimal"=>hash_type.to_s,
    "identifier"=>identifier,
    "page_size_exponent_decimal"=>page_size.to_s,
    "size_decimal"=>bytes.bytesize.to_s,
    "slot_type_decimal"=>slot_type.to_s,
    "special_slots_decimal"=>n_special.to_s,
    "version_hex"=>format("0x%08x", version)
  }
  fail_build("CODEDIRECTORY_EXEC_FIELDS") if bytes.bytesize < 88
  base, limit, exec_flags = bytes.byteslice(64, 24).unpack("Q>3")
  fail_build("CODEDIRECTORY_EXEC_BASE") unless base == 0
  fail_build("CODEDIRECTORY_EXEC_LIMIT") if limit == 0 || limit > code_limit
  fail_build("CODEDIRECTORY_EXEC_FLAGS") unless exec_flags == 1
  result["executable_segment_base_decimal"] = base.to_s
  result["executable_segment_flags_hex"] = format("0x%x", exec_flags)
  result["executable_segment_limit_decimal"] = limit.to_s
  result
end

def root_inventory(root)
  files = 0
  directories = 0
  bytes = 0
  byte_cap = root == A_ROOT ? 133_169_152 : 134_217_728
  stack = [root]
  until stack.empty?
    current = stack.pop
    entries = Dir.children(current).sort
    entries.each do |leaf|
      path = "#{current}/#{leaf}"
      stat = File.lstat(path)
      if stat.directory?
        directories += 1
        fail_build("ROOT_DIRECTORY_CAP") if directories > 4096
        stack << path
      elsif stat.file?
        files += 1
        bytes += stat.size
        fail_build("ROOT_FILE_CAP") if files > 4096
        fail_build("ROOT_BYTE_CAP") if bytes > byte_cap
      else
        fail_build("ROOT_UNSUPPORTED_NODE")
      end
    end
  end
  {"aggregate_file_bytes_decimal"=>bytes.to_s, "directories_decimal"=>directories.to_s, "files_decimal"=>files.to_s}
end

def validate_static_surface(build)
  analyzers = build.fetch("analyzers")
  defined = extract_nm_symbols(analyzers.fetch("object-defined").fetch("stdout_raw"))
  fail_build("OBJECT_DEFINED_SYMBOLS") unless defined == DEFINED_C_SYMBOLS
  undefined_object = extract_nm_symbols(analyzers.fetch("object-undefined").fetch("stdout_raw"))
  fail_build("OBJECT_UNDEFINED_SYMBOLS") unless (undefined_object - OBJECT_UNDEFINED_ALLOWED).empty?

  file_text = analyzers.fetch("product-file").fetch("stdout_raw")
  fail_build("PRODUCT_FILE_TYPE") unless file_text.include?("Mach-O 64-bit executable arm64")
  header_text = analyzers.fetch("product-otool-header").fetch("stdout_raw")
  fail_build("PRODUCT_OTOOL_HEADER") unless header_text.include?("ARM64") && header_text.include?("EXECUTE")
  codesign_text = analyzers.fetch("product-codesign-display").fetch("stderr_raw")
  fail_build("PRODUCT_CODESIGN_ADHOC") unless codesign_text.include?("Signature=adhoc")

  library_text = analyzers.fetch("product-otool-linked-images").fetch("stdout_raw")
  libraries = library_text.lines.drop(1).map { |line| line.strip.sub(/ \(compatibility version.*\z/, "") }.reject(&:empty?)
  fail_build("PRODUCT_LINKED_IMAGES_EMPTY") if libraries.empty?
  fail_build("PRODUCT_LINKED_IMAGE_DUPLICATE") unless libraries.uniq == libraries
  fail_build("PRODUCT_LINKED_IMAGE_FORBIDDEN") unless (libraries - ALLOWED_LINKED_IMAGES).empty?

  undefined_product = extract_nm_symbols(analyzers.fetch("product-undefined").fetch("stdout_raw"))
  forbidden = undefined_product & FORBIDDEN_PRODUCT_SYMBOLS
  forbidden.concat(undefined_product.select { |symbol| FORBIDDEN_PRODUCT_SYMBOL_PATTERNS.any? { |pattern| pattern.match?(symbol) } })
  fail_build("PRODUCT_FORBIDDEN_SYMBOLS") unless forbidden.empty?
  xattr_bytes = analyzers.fetch("product-xattrs").fetch("stdout_raw")
  xattr_names = xattr_bytes.lines.map { |line| match = /\A([^:\n]+):/.match(line); match && match[1] }.compact
  fail_build("PRODUCT_XATTR_DUPLICATE") unless xattr_names.uniq == xattr_names
  fail_build("PRODUCT_XATTR_FORBIDDEN") unless (xattr_names - ["com.apple.provenance"]).empty?
  {
    "c_defined_symbols"=>defined,
    "c_undefined_symbols"=>undefined_object,
    "linked_images"=>libraries,
    "product_undefined_symbols"=>undefined_product,
    "product_xattr_names"=>xattr_names,
    "product_xattr_stdout_sha256"=>Digest::SHA256.hexdigest(xattr_bytes)
  }
end

def normalize_capture(bytes, root, analyzer_label)
  product = "#{root}/#{PRODUCT_LEAF}"
  escaped = Regexp.escape(product)
  case analyzer_label
  when "product-otool-header", "product-otool-load-commands", "product-otool-linked-images"
    bytes.sub(/\A#{escaped}(?=:?\n|\z)/, "<PRODUCT>")
  when "product-codesign-verify", "product-xattrs"
    bytes.gsub(/^#{escaped}(?=:)/, "<PRODUCT>")
  when "product-codesign-display"
    bytes.gsub(/^Executable=#{escaped}$/, "Executable=<PRODUCT>")
  else
    bytes
  end
end

def compare_held(left, right)
  left.rewind
  right.rewind
  loop do
    a = left.read(65_536)
    b = right.read(65_536)
    return true if (a.nil? || a.empty?) && (b.nil? || b.empty?)
    return false unless a == b
  end
ensure
  left.rewind
  right.rewind
end

def verify_swiftc_link
  stat = File.lstat(SWIFTC)
  fail_build("SWIFTC_NOT_SYMLINK") unless stat.symlink?
  expected_lstat = {"device_decimal"=>"16777231", "inode_decimal"=>"1118435", "uid_decimal"=>"0", "gid_decimal"=>"0", "mode"=>"0755", "nlink_decimal"=>"1", "bytes_decimal"=>"14"}
  observed_lstat = {"device_decimal"=>stat.dev.to_s, "inode_decimal"=>stat.ino.to_s, "uid_decimal"=>stat.uid.to_s, "gid_decimal"=>stat.gid.to_s, "mode"=>mode_string(stat), "nlink_decimal"=>stat.nlink.to_s, "bytes_decimal"=>stat.size.to_s}
  fail_build("SWIFTC_LSTAT_MISMATCH") unless observed_lstat == expected_lstat
  fail_build("SWIFTC_TARGET_MISMATCH") unless File.readlink(SWIFTC) == "swift-frontend"
  fail_build("SWIFTC_REALPATH_MISMATCH") unless File.realpath(SWIFTC) == SWIFT_FRONTEND
  require_identity(SWIFT_FRONTEND, TOOL_EXPECTED.fetch(SWIFT_FRONTEND))
end

def verify_sdk
  sdk_stat = File.lstat(SDK)
  fail_build("SDK_NOT_SYMLINK") unless sdk_stat.symlink? && File.readlink(SDK) == "MacOSX.sdk"
  fail_build("SDK_REALPATH") unless File.realpath(SDK) == "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
  require_identity(SDK_SETTINGS, TOOL_EXPECTED.fetch(SDK_SETTINGS))
end

def verify_fixed_inputs
  SOURCE_EXPECTED.each { |path, expected| require_identity(path, expected) }
  HEADER_EXPECTED.each { |path, expected| require_identity(path, expected) }
  TOOL_EXPECTED.each { |path, expected| require_identity(path, expected) }
  verify_swiftc_link
  verify_sdk
  true
end

def create_directory_step(journal, root, root_io, leaf, label)
  path = "#{root}/#{leaf}"
  require_directory_join(root, root_io, "0700")
  require_absent(path, "#{label}:PRE")
  journal.append({"label"=>label, "path"=>path, "type"=>"DIRECTORY_CREATE_COMMITMENT"})
  Dir.mkdir(path, 0o700)
  child = open_directory(path)
  fail_build("DIRECTORY_MODE:#{label}") unless mode_string(child.stat) == "0700"
  durable_sync(child, "#{label}:CHILD")
  durable_sync(root_io, "#{label}:ROOT")
  require_directory_join(root, root_io, "0700")
  journal.append({"identity"=>{"device_decimal"=>child.stat.dev.to_s, "inode_decimal"=>child.stat.ino.to_s, "mode"=>mode_string(child.stat)}, "label"=>label, "type"=>"DIRECTORY_CREATED"})
  child.close
end

def build_one(journal, label, root, root_io)
  environment = child_environment(root)
  c_argv, swift_argv = compiler_argv(root)
  require_directory_join(root, root_io, "0700")
  SOURCE_EXPECTED.each { |path, expected| require_identity(path, expected) }
  require_identity(CLANG, TOOL_EXPECTED.fetch(CLANG))
  verify_sdk
  HEADER_EXPECTED.each { |path, expected| require_identity(path, expected) }
  c_result = run_child(journal, "#{label}:compiler-c", c_argv, environment, 1_048_576)
  HEADER_EXPECTED.each { |path, expected| require_identity(path, expected) }
  require_normal_zero(c_result, "#{label}:COMPILER_C", true)
  require_directory_join(root, root_io, "0700")

  SOURCE_EXPECTED.each { |path, expected| require_identity(path, expected) }
  verify_swiftc_link
  require_identity(SWIFT_DRIVER, TOOL_EXPECTED.fetch(SWIFT_DRIVER))
  require_identity(LD, TOOL_EXPECTED.fetch(LD))
  verify_sdk
  swift_result = run_child(journal, "#{label}:compiler-swift-link", swift_argv, environment, 1_048_576)
  require_normal_zero(swift_result, "#{label}:COMPILER_SWIFT", true)
  require_directory_join(root, root_io, "0700")

  object_io, object_identity = held_regular("#{root}/#{OBJECT_LEAF}")
  product_io, product_identity = held_regular("#{root}/#{PRODUCT_LEAF}")
  fail_build("#{label}:OBJECT_MODE") unless object_identity.fetch("mode") == "0600"
  fail_build("#{label}:OBJECT_NLINK") unless object_identity.fetch("nlink_decimal") == "1"
  fail_build("#{label}:OBJECT_CAP") if Integer(object_identity.fetch("bytes_decimal"), 10) > 4_194_304
  fail_build("#{label}:PRODUCT_MODE") unless product_identity.fetch("mode") == "0700"
  fail_build("#{label}:PRODUCT_NLINK") unless product_identity.fetch("nlink_decimal") == "1"
  fail_build("#{label}:PRODUCT_CAP") if Integer(product_identity.fetch("bytes_decimal"), 10) > 16_777_216
  fail_build("#{label}:OBJECT_PRODUCT_VNODE_ALIAS") if object_identity.fetch("device_decimal") == product_identity.fetch("device_decimal") && object_identity.fetch("inode_decimal") == product_identity.fetch("inode_decimal")

  durable_sync(object_io, "#{label}:OBJECT")
  durable_sync(product_io, "#{label}:PRODUCT")
  durable_sync(root_io, "#{label}:ARTIFACT_ROOT")
  require_directory_join(root, root_io, "0700")
  journal.append({"label"=>label, "object"=>object_identity, "product"=>product_identity, "type"=>"BUILD_ARTIFACTS_DURABLE"})

  macho = parse_macho(product_io)
  analyzers = {}
  analyzer_argv(root).each do |analyzer_label, argv|
    require_identity(argv.first, TOOL_EXPECTED.fetch(argv.first))
    require_named_join("#{root}/#{OBJECT_LEAF}", object_io)
    require_named_join("#{root}/#{PRODUCT_LEAF}", product_io)
    require_directory_join(root, root_io, "0700")
    result = run_child(journal, "#{label}:#{analyzer_label}", argv, environment, 4_194_304)
    require_normal_zero(result, "#{label}:#{analyzer_label}", false)
    require_directory_join(root, root_io, "0700")
    analyzers[analyzer_label] = result
  end

  require_held_identity("#{root}/#{OBJECT_LEAF}", object_io, object_identity)
  require_held_identity("#{root}/#{PRODUCT_LEAF}", product_io, product_identity)
  surface = validate_static_surface({"analyzers"=>analyzers})
  inventory = root_inventory(root)
  require_directory_join(root, root_io, "0700")
  journal.append({"artifact_identities"=>{"object"=>object_identity, "product"=>product_identity}, "label"=>label, "macho"=>macho, "root_inventory"=>inventory, "surface"=>surface, "type"=>"BUILD_STATIC_ADMISSION_PASS"})
  {"analyzers"=>analyzers, "macho"=>macho, "object_identity"=>object_identity, "object_io"=>object_io, "product_identity"=>product_identity, "product_io"=>product_io, "surface"=>surface}
rescue StandardError
  object_io.close if defined?(object_io) && object_io && !object_io.closed?
  product_io.close if defined?(product_io) && product_io && !product_io.closed?
  raise
end

journal = nil
tmp_parent_io = nil
archive_parent_io = nil
a_root_io = nil
b_root_io = nil
a_build = nil
b_build = nil

begin
  fail_build("ARGV_NOT_EMPTY") unless ARGV.empty?
  fail_build("ENV_MISMATCH") unless ENV.to_h == CONTROLLER_ENVIRONMENT
  fail_build("CWD_NOT_ROOT") unless Dir.pwd == "/"
  File.umask(0o077)

  require_parent_identity(TMP_PARENT, {"device_decimal"=>"16777231", "inode_decimal"=>"774813", "uid_decimal"=>"0", "gid_decimal"=>"0", "mode"=>"1777", "type"=>"DIRECTORY"})
  require_parent_identity(ARCHIVE_PARENT, {"device_decimal"=>"16777231", "inode_decimal"=>"341832", "uid_decimal"=>"501", "gid_decimal"=>"20", "mode"=>"0700", "type"=>"DIRECTORY"})
  require_absent(A_ROOT, "A_ROOT_INITIAL")
  require_absent(B_ROOT, "B_ROOT_INITIAL")
  require_absent(ARCHIVE_STAGING, "ARCHIVE_STAGING_INITIAL")
  require_absent(ARCHIVE_FINAL, "ARCHIVE_FINAL_INITIAL")
  verify_fixed_inputs

  tmp_parent_io = open_directory(TMP_PARENT)
  tmp_identity = require_directory_join(TMP_PARENT, tmp_parent_io, "1777")
  fail_build("TMP_PARENT_HELD_IDENTITY") unless tmp_identity.fetch("device_decimal") == "16777231" && tmp_identity.fetch("inode_decimal") == "774813" && tmp_identity.fetch("uid_decimal") == "0" && tmp_identity.fetch("gid_decimal") == "0"
  archive_parent_io = open_directory(ARCHIVE_PARENT)
  archive_identity = require_directory_join(ARCHIVE_PARENT, archive_parent_io, "0700")
  fail_build("ARCHIVE_PARENT_HELD_IDENTITY") unless archive_identity.fetch("device_decimal") == "16777231" && archive_identity.fetch("inode_decimal") == "341832" && archive_identity.fetch("uid_decimal") == "501" && archive_identity.fetch("gid_decimal") == "20"
  require_absent(A_ROOT, "A_ROOT_IMMEDIATE")
  require_directory_join(TMP_PARENT, tmp_parent_io, "1777")
  Dir.mkdir(A_ROOT, 0o700)
  a_root_io = open_directory(A_ROOT)
  fail_build("A_ROOT_MODE") unless mode_string(a_root_io.stat) == "0700"
  journal = DurableJournal.new(A_ROOT, a_root_io, tmp_parent_io)
  journal.append({"a_root_identity"=>{"device_decimal"=>a_root_io.stat.dev.to_s, "inode_decimal"=>a_root_io.stat.ino.to_s, "mode"=>mode_string(a_root_io.stat)}, "controller_payload_sha256"=>CONTROLLER_PAYLOAD_SHA256, "implementation_commit"=>"afe59cb6bc410a1db5c68539abbb2b760ebe8e3e", "implementation_tree"=>"2c50486f4d74aafb2265dcc8859be14e3ded647b", "ruby_visible_environment_pairs"=>ENV.keys.sort.map { |key| [key, ENV.fetch(key)] }, "type"=>"CONTROLLER_START"})
  durable_sync(a_root_io, "A_ROOT_INITIAL")
  durable_sync(tmp_parent_io, "TMP_PARENT_AFTER_A")
  journal.append({"type"=>"A_ROOT_AND_JOURNAL_DURABLE"})
  create_directory_step(journal, A_ROOT, a_root_io, "module-cache", "A:MODULE_CACHE")
  create_directory_step(journal, A_ROOT, a_root_io, "tmp", "A:TMP")

  a_build = build_one(journal, "A", A_ROOT, a_root_io)

  require_absent(B_ROOT, "B_ROOT_IMMEDIATE")
  journal.append({"path"=>B_ROOT, "type"=>"B_ROOT_CREATE_COMMITMENT"})
  Dir.mkdir(B_ROOT, 0o700)
  b_root_io = open_directory(B_ROOT)
  fail_build("B_ROOT_MODE") unless mode_string(b_root_io.stat) == "0700"
  require_directory_join(B_ROOT, b_root_io, "0700")
  durable_sync(b_root_io, "B_ROOT_INITIAL")
  durable_sync(tmp_parent_io, "TMP_PARENT_AFTER_B")
  journal.append({"b_root_identity"=>{"device_decimal"=>b_root_io.stat.dev.to_s, "inode_decimal"=>b_root_io.stat.ino.to_s, "mode"=>mode_string(b_root_io.stat)}, "type"=>"B_ROOT_CREATED_DURABLE"})
  create_directory_step(journal, B_ROOT, b_root_io, "module-cache", "B:MODULE_CACHE")
  create_directory_step(journal, B_ROOT, b_root_io, "tmp", "B:TMP")

  b_build = build_one(journal, "B", B_ROOT, b_root_io)

  fail_build("A_B_OBJECT_VNODE_ALIAS") if a_build.fetch("object_identity").fetch("device_decimal") == b_build.fetch("object_identity").fetch("device_decimal") && a_build.fetch("object_identity").fetch("inode_decimal") == b_build.fetch("object_identity").fetch("inode_decimal")
  fail_build("A_B_PRODUCT_VNODE_ALIAS") if a_build.fetch("product_identity").fetch("device_decimal") == b_build.fetch("product_identity").fetch("device_decimal") && a_build.fetch("product_identity").fetch("inode_decimal") == b_build.fetch("product_identity").fetch("inode_decimal")

  require_directory_join(A_ROOT, a_root_io, "0700")
  require_directory_join(B_ROOT, b_root_io, "0700")
  require_named_join("#{A_ROOT}/#{OBJECT_LEAF}", a_build.fetch("object_io"))
  require_named_join("#{B_ROOT}/#{OBJECT_LEAF}", b_build.fetch("object_io"))
  journal.append({"type"=>"RAW_OBJECT_COMPARISON_ENTRY"})
  fail_build("RAW_OBJECT_MISMATCH") unless compare_held(a_build.fetch("object_io"), b_build.fetch("object_io"))
  journal.append({"sha256"=>a_build.fetch("object_identity").fetch("sha256"), "type"=>"RAW_OBJECT_EQUAL"})

  require_named_join("#{A_ROOT}/#{PRODUCT_LEAF}", a_build.fetch("product_io"))
  require_named_join("#{B_ROOT}/#{PRODUCT_LEAF}", b_build.fetch("product_io"))
  journal.append({"type"=>"RAW_PRODUCT_COMPARISON_ENTRY"})
  fail_build("RAW_PRODUCT_MISMATCH") unless compare_held(a_build.fetch("product_io"), b_build.fetch("product_io"))
  journal.append({"sha256"=>a_build.fetch("product_identity").fetch("sha256"), "type"=>"RAW_PRODUCT_EQUAL"})
  require_held_identity("#{A_ROOT}/#{OBJECT_LEAF}", a_build.fetch("object_io"), a_build.fetch("object_identity"))
  require_held_identity("#{B_ROOT}/#{OBJECT_LEAF}", b_build.fetch("object_io"), b_build.fetch("object_identity"))
  require_held_identity("#{A_ROOT}/#{PRODUCT_LEAF}", a_build.fetch("product_io"), a_build.fetch("product_identity"))
  require_held_identity("#{B_ROOT}/#{PRODUCT_LEAF}", b_build.fetch("product_io"), b_build.fetch("product_identity"))
  require_directory_join(A_ROOT, a_root_io, "0700")
  require_directory_join(B_ROOT, b_root_io, "0700")

  analyzer_argv(A_ROOT).each_with_index do |(analyzer_label, _), index|
    a_result = a_build.fetch("analyzers").fetch(analyzer_label)
    b_result = b_build.fetch("analyzers").fetch(analyzer_label)
    fail_build("ANALYZER_EXIT_DRIFT:#{analyzer_label}") unless a_result.fetch("exit_status_decimal") == b_result.fetch("exit_status_decimal") && a_result.fetch("exited") == b_result.fetch("exited") && a_result.fetch("signaled") == b_result.fetch("signaled")
    a_stdout = normalize_capture(a_result.fetch("stdout_raw"), A_ROOT, analyzer_label)
    b_stdout = normalize_capture(b_result.fetch("stdout_raw"), B_ROOT, analyzer_label)
    a_stderr = normalize_capture(a_result.fetch("stderr_raw"), A_ROOT, analyzer_label)
    b_stderr = normalize_capture(b_result.fetch("stderr_raw"), B_ROOT, analyzer_label)
    fail_build("ANALYZER_STDOUT_DRIFT:#{analyzer_label}") unless a_stdout == b_stdout
    fail_build("ANALYZER_STDERR_DRIFT:#{analyzer_label}") unless a_stderr == b_stderr
    journal.append({"analyzer_index_decimal"=>(index + 1).to_s, "label"=>analyzer_label, "type"=>"NORMALIZED_ANALYZER_PAIR_EQUAL"})
  end

  fail_build("MACHO_METADATA_DRIFT") unless a_build.fetch("macho") == b_build.fetch("macho")
  fail_build("STATIC_SURFACE_DRIFT") unless a_build.fetch("surface") == b_build.fetch("surface")

  verify_fixed_inputs
  require_held_identity("#{A_ROOT}/#{OBJECT_LEAF}", a_build.fetch("object_io"), a_build.fetch("object_identity"))
  require_held_identity("#{B_ROOT}/#{OBJECT_LEAF}", b_build.fetch("object_io"), b_build.fetch("object_identity"))
  require_held_identity("#{A_ROOT}/#{PRODUCT_LEAF}", a_build.fetch("product_io"), a_build.fetch("product_identity"))
  require_held_identity("#{B_ROOT}/#{PRODUCT_LEAF}", b_build.fetch("product_io"), b_build.fetch("product_identity"))
  require_directory_join(A_ROOT, a_root_io, "0700")
  require_directory_join(B_ROOT, b_root_io, "0700")
  require_directory_join(TMP_PARENT, tmp_parent_io, "1777")
  require_directory_join(ARCHIVE_PARENT, archive_parent_io, "0700")
  require_absent(ARCHIVE_STAGING, "ARCHIVE_STAGING_FINAL")
  require_absent(ARCHIVE_FINAL, "ARCHIVE_FINAL_FINAL")
  preterminal_a_inventory = root_inventory(A_ROOT)
  preterminal_b_inventory = root_inventory(B_ROOT)
  require_held_identity("#{A_ROOT}/#{OBJECT_LEAF}", a_build.fetch("object_io"), a_build.fetch("object_identity"))
  require_held_identity("#{B_ROOT}/#{OBJECT_LEAF}", b_build.fetch("object_io"), b_build.fetch("object_identity"))
  require_held_identity("#{A_ROOT}/#{PRODUCT_LEAF}", a_build.fetch("product_io"), a_build.fetch("product_identity"))
  require_held_identity("#{B_ROOT}/#{PRODUCT_LEAF}", b_build.fetch("product_io"), b_build.fetch("product_identity"))
  require_directory_join(A_ROOT, a_root_io, "0700")
  require_directory_join(B_ROOT, b_root_io, "0700")
  require_directory_join(TMP_PARENT, tmp_parent_io, "1777")
  require_directory_join(ARCHIVE_PARENT, archive_parent_io, "0700")

  close_errors = [
    safe_close(a_build.fetch("object_io")),
    safe_close(a_build.fetch("product_io")),
    safe_close(b_build.fetch("object_io")),
    safe_close(b_build.fetch("product_io")),
    safe_close(b_root_io),
    safe_close(archive_parent_io)
  ].compact
  fail_build("PRETERMINAL_CLOSE_FAILURE") unless close_errors.empty?

  journal.append_terminal_and_seal({
    "archive_final_absent"=>true,
    "archive_staging_absent"=>true,
    "build_a_inventory_preterminal"=>preterminal_a_inventory,
    "build_b_inventory_preterminal"=>preterminal_b_inventory,
    "object_sha256"=>a_build.fetch("object_identity").fetch("sha256"),
    "product_sha256"=>a_build.fetch("product_identity").fetch("sha256"),
    "publisher_executions_decimal"=>"0",
    "interpretation"=>"PASS_ONLY_WITH_EXACT_OUTER_NORMAL_EXIT_0_AND_SUCCESSOR_CHAIN_VALIDATION",
    "status"=>"PASS_CANDIDATE",
    "type"=>"CONTROLLER_TERMINAL"
  })
  journal.close_unchecked
  exit!(0)
rescue StandardError => error
  if journal && !journal.sealed
    begin
      event = {"error_class"=>error.class.name, "interpretation"=>"REQUIRES_EXACT_OUTER_EXIT_AND_SUCCESSOR_CHAIN_VALIDATION", "status"=>"FAIL_CANDIDATE", "type"=>"CONTROLLER_TERMINAL"}
      event["error_code"] = error.code if error.is_a?(BuildFailure)
      event["errno_decimal"] = error.errno.to_s if error.is_a?(SystemCallError)
      if journal.writable?
        journal.append_terminal_and_seal(event)
      else
        journal.retain_prefix_unchecked
      end
    rescue StandardError
      journal.retain_prefix_unchecked
    end
  end
  journal.close_unchecked if journal
  exit!(70)
end
