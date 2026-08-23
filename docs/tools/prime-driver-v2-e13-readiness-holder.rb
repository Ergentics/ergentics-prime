#!/usr/bin/ruby

HOLDER_ENV = {
  "LANG" => "C.UTF-8",
  "LC_ALL" => "C.UTF-8",
  "TZ" => "UTC",
  "PATH" => "/usr/bin:/bin",
  "__CF_USER_TEXT_ENCODING" => "0x1F5:0x0:0x0",
}.freeze

unless ARGV.empty? && ENV.to_h == HOLDER_ENV
  STDERR.write("{\"status\":\"failed\",\"error_class\":\"BootstrapGuard\",\"error\":\"unexpected-bootstrap\"}\n")
  exit 70
end

require "json"
require "fiddle/import"

EPOCH = "/private/tmp/gate-e1-3-readiness-r3-474008bdffccf410"
SOURCE = "/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.driver-v2-gate-c-staging"
CHILDREN = %w[
  home
  tmp
  git-template
  clang-module-cache
  swiftpm-module-cache
  prime
].freeze

EXPECTED_DEVICE = 16_777_231
EXPECTED_UID = 501
EXPECTED_GID = 0
PRIVATE_IDENTITY = [16_777_231, 773_652].freeze
TMP_ROOT_IDENTITY = [16_777_231, 774_813].freeze
SOURCE_IDENTITY = [16_777_231, 17_154_421].freeze
TERMINATION_SIGNALS = %w[HUP INT QUIT TERM].freeze
TERMINAL_OLD_EPOCH = "/private/tmp/gate-e1-3-readiness-474008bdffccf410"
TERMINAL_R2_EPOCH = "/private/tmp/gate-e1-3-readiness-r2-474008bdffccf410"
TERMINAL_CANARIES = [
  [TERMINAL_OLD_EPOCH, [16_777_231, 17_350_005], 2, true],
  [TERMINAL_R2_EPOCH, [16_777_231, 17_351_796], 8, false],
  ["#{TERMINAL_R2_EPOCH}/home", [16_777_231, 17_351_797], 2, true],
  ["#{TERMINAL_R2_EPOCH}/tmp", [16_777_231, 17_351_798], 2, true],
  ["#{TERMINAL_R2_EPOCH}/git-template", [16_777_231, 17_351_799], 2, true],
  ["#{TERMINAL_R2_EPOCH}/clang-module-cache", [16_777_231, 17_351_800], 2, true],
  ["#{TERMINAL_R2_EPOCH}/swiftpm-module-cache", [16_777_231, 17_351_801], 2, true],
  ["#{TERMINAL_R2_EPOCH}/prime", [16_777_231, 17_351_802], 2, true],
].freeze

module DarwinLibC
  extend Fiddle::Importer
  dlload Fiddle.dlopen(nil)
  extern "int fchdir(int)"
  extern "int fgetattrlist(int, void*, void*, size_t, unsigned int)"
  extern "ssize_t flistxattr(int, void*, size_t, int)"
  extern "void* acl_get_fd_np(int, int)"
  extern "int acl_free(void*)"
end

# Darwin fcntl.h values from the admitted MacOSX SDK.
O_RDONLY = 0x00000000
O_NOFOLLOW = 0x00000100
O_DIRECTORY = 0x00100000
O_CLOEXEC = 0x01000000
O_NOFOLLOW_ANY = 0x20000000
DIRECTORY_OPEN_FLAGS = O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW_ANY

# Typed descriptor metadata constants from the admitted Darwin SDK.
ATTR_BIT_MAP_COUNT = 5
ATTR_CMN_FLAGS = 0x00040000
ACL_TYPE_EXTENDED = 0x00000100
XATTR_SHOWCOMPRESSION = 0x00000020
NO_ACL_ERRNO = Errno::ENOENT::Errno
EXPECTED_XATTR_BYTES = "com.apple.provenance\0".b.freeze
ATTR_LIST_BYTES = [
  ATTR_BIT_MAP_COUNT,
  0,
  ATTR_CMN_FLAGS,
  0,
  0,
  0,
  0,
].pack("S!S!I!I!I!I!I!").freeze

def missing?(path)
  File.lstat(path)
  false
rescue Errno::ENOENT
  true
end

def directory_security_tuple(stat)
  [stat.dev, stat.uid, stat.gid, stat.mode & 0o7777]
end

def require_secure_directory(path, expected_nlink: nil, expected_identity: nil, empty: false)
  stat = File.lstat(path)
  expected = [EXPECTED_DEVICE, EXPECTED_UID, EXPECTED_GID, 0o700]
  raise "directory-security:#{path}" unless stat.directory? && directory_security_tuple(stat) == expected
  raise "directory-link-count:#{path}" if expected_nlink && stat.nlink != expected_nlink
  raise "directory-identity:#{path}" if expected_identity && [stat.dev, stat.ino] != expected_identity
  raise "directory-nonempty:#{path}" if empty && !Dir.children(path).empty?
  stat
end

def open_directory(path)
  descriptor = IO.sysopen(path, DIRECTORY_OPEN_FLAGS)
  io = IO.new(descriptor)
  raise "descriptor-not-cloexec:#{path}" unless io.close_on_exec?
  io
end

def rejoin!(path, io)
  path_stat = File.lstat(path)
  descriptor_stat = io.stat
  raise "path-rebound:#{path}" unless path_stat.directory?
  raise "path-rebound:#{path}" unless [path_stat.dev, path_stat.ino] == [descriptor_stat.dev, descriptor_stat.ino]
end

def require_ancestor(path, io, identity, mode)
  stat = File.lstat(path)
  raise "ancestor-security:#{path}" unless stat.directory?
  raise "ancestor-security:#{path}" unless [stat.dev, stat.ino] == identity
  raise "ancestor-security:#{path}" unless [stat.uid, stat.gid, stat.mode & 0o7777] == [0, 0, mode]
  rejoin!(path, io)
end

def process_group_exists?(pid)
  Process.kill(0, -pid)
  true
rescue Errno::ESRCH
  false
rescue Errno::EPERM
  true
end

def kill_process_group(pid)
  Process.kill("KILL", -pid)
rescue Errno::ESRCH
  nil
rescue Errno::EPERM
  nil
end

def wait_for_group_empty(pid)
  while process_group_exists?(pid)
    kill_process_group(pid)
    sleep(0.001)
  end
end

def contain_reap_and_join(pid)
  kill_process_group(pid)
  begin
    Process.wait2(pid)
  rescue Errno::ECHILD
    nil
  end
  wait_for_group_empty(pid)
end

def wait_exact(pid)
  $active_child_pid = pid
  kill_process_group(pid) if $interrupted_signal
  status = nil
  begin
    _, status = Process.wait2(pid)
    if process_group_exists?(pid)
      kill_process_group(pid)
      wait_for_group_empty(pid)
      raise "process-group-not-empty:#{pid}"
    end
  rescue Exception
    contain_reap_and_join(pid)
    raise
  ensure
    $active_child_pid = nil if $active_child_pid == pid
  end
  raise "holder-interrupted:#{$interrupted_signal}" if $interrupted_signal
  status
end

def fchdir_exact(io, expected_identity)
  raise "fchdir-failed" unless DarwinLibC.fchdir(io.fileno) == 0
  cwd_stat = File.stat(".")
  raise "fchdir-identity" unless [cwd_stat.dev, cwd_stat.ino] == expected_identity
end

def require_uninterrupted
  raise "holder-interrupted:#{$interrupted_signal}" if $interrupted_signal
end

def descriptor_flags(io)
  raise "attr-list-layout" unless ATTR_LIST_BYTES.bytesize == 24
  buffer = "\0" * 8
  Fiddle.last_error = 0
  result = DarwinLibC.fgetattrlist(
    io.fileno,
    ATTR_LIST_BYTES,
    buffer,
    buffer.bytesize,
    0
  )
  error = Fiddle.last_error
  raise "descriptor-flags-read:#{error}" unless result == 0
  returned_bytes, flags = buffer.unpack("I!I!")
  raise "descriptor-flags-frame" unless returned_bytes == 8
  flags
end

def descriptor_xattr_bytes(io)
  Fiddle.last_error = 0
  required = DarwinLibC.flistxattr(io.fileno, nil, 0, XATTR_SHOWCOMPRESSION)
  size_error = Fiddle.last_error
  raise "descriptor-xattr-size:#{size_error}" unless required == EXPECTED_XATTR_BYTES.bytesize
  buffer = "\0" * required
  Fiddle.last_error = 0
  returned = DarwinLibC.flistxattr(
    io.fileno,
    buffer,
    buffer.bytesize,
    XATTR_SHOWCOMPRESSION
  )
  read_error = Fiddle.last_error
  raise "descriptor-xattr-read:#{read_error}" unless returned == required
  buffer
end

def require_descriptor_acl_free(io)
  Fiddle.last_error = 0
  acl = DarwinLibC.acl_get_fd_np(io.fileno, ACL_TYPE_EXTENDED)
  error = Fiddle.last_error
  unless acl.null?
    Fiddle.last_error = 0
    freed = DarwinLibC.acl_free(acl)
    free_error = Fiddle.last_error
    raise "descriptor-acl-free:#{free_error}" unless freed == 0
    raise "descriptor-acl-present"
  end
  raise "descriptor-acl-read" unless error == NO_ACL_ERRNO
end

def require_extended_security(path, io:, expected_identity:, expected_nlink:)
  require_uninterrupted
  rejoin!(path, io)
  before = io.stat
  raise "extended-identity-before:#{path}" unless [before.dev, before.ino] == expected_identity
  raise "extended-link-count:#{path}" unless before.nlink == expected_nlink
  raise "extended-flags:#{path}" unless descriptor_flags(io) == 0
  require_descriptor_acl_free(io)
  raise "extended-xattrs:#{path}" unless descriptor_xattr_bytes(io) == EXPECTED_XATTR_BYTES
  after = io.stat
  raise "extended-identity-after:#{path}" unless [after.dev, after.ino] == expected_identity
  raise "extended-link-count-after:#{path}" unless after.nlink == expected_nlink
  rejoin!(path, io)
end

def require_terminal_canaries
  held = TERMINAL_CANARIES.map do |path, identity, nlink, empty|
    io = open_directory(path)
    require_secure_directory(
      path,
      expected_nlink: nlink,
      expected_identity: identity,
      empty: empty
    )
    require_extended_security(
      path,
      io: io,
      expected_identity: identity,
      expected_nlink: nlink
    )
    io
  end
  raise "terminal-r2-inventory" unless Dir.children(TERMINAL_R2_EPOCH).sort == CHILDREN.sort
  held
end

def run_exact(*argv)
  require_uninterrupted
  options = {
    in: File::NULL,
    out: File::NULL,
    err: File::NULL,
    umask: 0o077,
    pgroup: true,
    close_others: true,
  }
  pid = Process.spawn(*argv, options)
  status = wait_exact(pid)
  raise "nonzero:#{status.exitstatus}:#{argv.first}" unless status.success?
end

def clone_arguments
  [
    "-i",
    "HOME=#{EPOCH}/home",
    "CFFIXED_USER_HOME=#{EPOCH}/home",
    "XDG_CONFIG_HOME=#{EPOCH}/home",
    "TMPDIR=#{EPOCH}/tmp/",
    "USER=ergentics",
    "LOGNAME=ergentics",
    "LANG=C.UTF-8",
    "LC_ALL=C.UTF-8",
    "TZ=UTC",
    "TERM=dumb",
    "NO_COLOR=1",
    "PATH=/Applications/Xcode.app/Contents/Developer/usr/bin:/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin:/usr/bin:/bin",
    "DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer",
    "SDKROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk",
    "GIT_EXEC_PATH=/Applications/Xcode.app/Contents/Developer/usr/libexec/git-core",
    "GIT_CONFIG_NOSYSTEM=1",
    "GIT_CONFIG_GLOBAL=/dev/null",
    "GIT_ATTR_NOSYSTEM=1",
    "GIT_CONFIG_COUNT=6",
    "GIT_CONFIG_KEY_0=core.hooksPath",
    "GIT_CONFIG_VALUE_0=#{EPOCH}/git-template",
    "GIT_CONFIG_KEY_1=init.templateDir",
    "GIT_CONFIG_VALUE_1=#{EPOCH}/git-template",
    "GIT_CONFIG_KEY_2=core.attributesFile",
    "GIT_CONFIG_VALUE_2=/dev/null",
    "GIT_CONFIG_KEY_3=checkout.workers",
    "GIT_CONFIG_VALUE_3=1",
    "GIT_CONFIG_KEY_4=maintenance.auto",
    "GIT_CONFIG_VALUE_4=false",
    "GIT_CONFIG_KEY_5=gc.auto",
    "GIT_CONFIG_VALUE_5=0",
    "GIT_ALLOW_PROTOCOL=file",
    "GIT_PROTOCOL_FROM_USER=0",
    "GIT_OPTIONAL_LOCKS=0",
    "GIT_TERMINAL_PROMPT=0",
    "GIT_LFS_SKIP_SMUDGE=1",
    "GIT_NO_LAZY_FETCH=1",
    "GIT_NO_REPLACE_OBJECTS=1",
    "/Applications/Xcode.app/Contents/Developer/usr/bin/git",
    "clone",
    "--local",
    "--no-hardlinks",
    "--no-tags",
    "--single-branch",
    "--branch=agent/prime-validation-driver-v2-gate-c",
    "--origin=origin",
    "--template=#{EPOCH}/git-template",
    "--no-recurse-submodules",
    "--reject-shallow",
    "--ref-format=files",
    "--no-progress",
    "--",
    SOURCE,
    ".",
  ]
end

$active_child_pid = nil
$interrupted_signal = nil
TERMINATION_SIGNALS.each do |signal|
  Signal.trap(signal) do
    $interrupted_signal ||= signal
    kill_process_group($active_child_pid) if $active_child_pid
  end
end

begin
  raise "unexpected-argv" unless ARGV.empty?
  raise "unexpected-environment" unless ENV.to_h == HOLDER_ENV

  private_root = open_directory("/private")
  tmp_root = open_directory("/private/tmp")
  source_root = open_directory(SOURCE)
  require_ancestor("/private", private_root, PRIVATE_IDENTITY, 0o755)
  require_ancestor("/private/tmp", tmp_root, TMP_ROOT_IDENTITY, 0o1777)
  raise "descriptor-flags-positive-control" unless descriptor_flags(private_root) == 1_081_344
  source_stat = File.lstat(SOURCE)
  raise "source-security" unless source_stat.directory?
  raise "source-security" unless [source_stat.dev, source_stat.ino] == SOURCE_IDENTITY
  raise "source-security" unless [source_stat.uid, source_stat.gid, source_stat.mode & 0o7777] == [501, 20, 0o755]
  rejoin!(SOURCE, source_root)
  terminal_canaries = require_terminal_canaries
  raise "terminal-canary-cardinality" unless terminal_canaries.length == 8
  raise "epoch-present" unless missing?(EPOCH)

  run_exact("/bin/mkdir", "-m", "0700", EPOCH)
  require_ancestor("/private", private_root, PRIVATE_IDENTITY, 0o755)
  require_ancestor("/private/tmp", tmp_root, TMP_ROOT_IDENTITY, 0o1777)
  parent_stat = require_secure_directory(EPOCH, expected_nlink: 2, empty: true)
  parent = open_directory(EPOCH)
  parent_identity = [parent.stat.dev, parent.stat.ino]
  raise "parent-observation-rebound" unless [parent_stat.dev, parent_stat.ino] == parent_identity
  rejoin!(EPOCH, parent)
  require_extended_security(EPOCH, io: parent, expected_identity: parent_identity, expected_nlink: 2)

  created = {}
  held = {}
  CHILDREN.each do |leaf|
    path = "#{EPOCH}/#{leaf}"
    raise "child-present:#{leaf}" unless missing?(path)
    require_ancestor("/private", private_root, PRIVATE_IDENTITY, 0o755)
    require_ancestor("/private/tmp", tmp_root, TMP_ROOT_IDENTITY, 0o1777)
    rejoin!(EPOCH, parent)
    run_exact("/bin/mkdir", "-m", "0700", path)
    require_ancestor("/private", private_root, PRIVATE_IDENTITY, 0o755)
    require_ancestor("/private/tmp", tmp_root, TMP_ROOT_IDENTITY, 0o1777)
    child_stat = require_secure_directory(path, expected_nlink: 2, empty: true)
    child = open_directory(path)
    rejoin!(EPOCH, parent)
    created[leaf] = [child_stat.dev, child_stat.ino]
    raise "child-observation-rebound:#{leaf}" unless [child.stat.dev, child.stat.ino] == created.fetch(leaf)
    held[leaf] = child
    require_extended_security(path, io: child, expected_identity: created.fetch(leaf), expected_nlink: 2)
    created.each do |created_leaf, identity|
      require_secure_directory(
        "#{EPOCH}/#{created_leaf}",
        expected_nlink: 2,
        expected_identity: identity,
        empty: true
      )
      rejoin!("#{EPOCH}/#{created_leaf}", held.fetch(created_leaf))
    end
  end

  raise "parent-inventory" unless Dir.children(EPOCH).sort == CHILDREN.sort
  raise "parent-link-count" unless File.lstat(EPOCH).nlink == 8

  prime_path = "#{EPOCH}/prime"
  prime = held.fetch("prime")
  prime_identity = [prime.stat.dev, prime.stat.ino]
  raise "prime-observation-rebound" unless created.fetch("prime") == prime_identity
  rejoin!(EPOCH, parent)
  rejoin!(prime_path, prime)

  CHILDREN.each do |leaf|
    child_stat = require_secure_directory(
      "#{EPOCH}/#{leaf}",
      expected_nlink: 2,
      expected_identity: created.fetch(leaf),
      empty: true
    )
    require_extended_security(
      "#{EPOCH}/#{leaf}",
      io: held.fetch(leaf),
      expected_identity: created.fetch(leaf),
      expected_nlink: child_stat.nlink
    )
  end

  require_extended_security(EPOCH, io: parent, expected_identity: parent_identity, expected_nlink: 8)

  require_ancestor("/private", private_root, PRIVATE_IDENTITY, 0o755)
  require_ancestor("/private/tmp", tmp_root, TMP_ROOT_IDENTITY, 0o1777)
  rejoin!(SOURCE, source_root)
  fchdir_exact(prime, prime_identity)
  run_exact("/usr/bin/env", *clone_arguments)

  require_ancestor("/private", private_root, PRIVATE_IDENTITY, 0o755)
  require_ancestor("/private/tmp", tmp_root, TMP_ROOT_IDENTITY, 0o1777)
  rejoin!(SOURCE, source_root)
  fchdir_exact(prime, prime_identity)
  rejoin!(EPOCH, parent)
  rejoin!(prime_path, prime)
  raise "parent-identity" unless parent_identity == [parent.stat.dev, parent.stat.ino]
  raise "prime-identity" unless prime_identity == [prime.stat.dev, prime.stat.ino]
  raise "parent-inventory-post" unless Dir.children(EPOCH).sort == CHILDREN.sort
  raise "parent-link-count-post" unless File.lstat(EPOCH).nlink == 8
  prime_stat = require_secure_directory(prime_path, expected_identity: prime_identity)
  require_extended_security(prime_path, io: prime, expected_identity: prime_identity, expected_nlink: prime_stat.nlink)
  (CHILDREN - ["prime"]).each do |leaf|
    child_stat = require_secure_directory(
      "#{EPOCH}/#{leaf}",
      expected_nlink: 2,
      expected_identity: created.fetch(leaf),
      empty: true
    )
    require_extended_security(
      "#{EPOCH}/#{leaf}",
      io: held.fetch(leaf),
      expected_identity: created.fetch(leaf),
      expected_nlink: child_stat.nlink
    )
  end
  require_extended_security(EPOCH, io: parent, expected_identity: parent_identity, expected_nlink: 8)

  TERMINATION_SIGNALS.each { |signal| Signal.trap(signal, "DEFAULT") }
  require_uninterrupted

  puts JSON.generate(
    {
      "status" => "holder_complete_pending_outer_clone_admission",
      "epoch" => [parent_stat.dev, parent_stat.ino, File.lstat(EPOCH).nlink],
      "children" => CHILDREN.map { |leaf| [leaf, *created.fetch(leaf)] },
      "prime" => [prime.stat.dev, prime.stat.ino, prime.stat.nlink],
    }
  )
rescue StandardError => error
  warn JSON.generate(
    {
      "status" => "failed",
      "error_class" => error.class.name,
      "error" => error.message,
    }
  )
  exit 70
end
