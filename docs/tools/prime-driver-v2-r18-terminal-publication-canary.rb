#!/usr/bin/ruby

BOOTSTRAP_ENV = {
  "LANG" => "C.UTF-8",
  "LC_ALL" => "C.UTF-8",
  "TZ" => "UTC",
  "PATH" => "/usr/bin:/bin",
  "__CF_USER_TEXT_ENCODING" => "0x1F5:0x0:0x0",
}.freeze

unless ARGV.empty? && ENV.to_h == BOOTSTRAP_ENV
  STDERR.write("{\"status\":\"R18_TERMINAL_CANARY_FAILED\"," \
    "\"error\":\"unexpected-bootstrap\"}\n")
  exit 70
end

require "digest"
require "fiddle/import"
require "json"

# This is a disposable, one-shot filesystem primitive canary. It cannot
# launch or signal a process, touch a mechanics epoch, or interpret evidence.
# Any mutation or failure permanently consumes the disjoint canary root.
PRIVATE_TMP = "/private/tmp"
CANARY_LEAF =
  "prime-driver-v2-r18-terminal-canary-befc6324-b501ad0d7ab1b6c5"
CANARY_ROOT = "#{PRIVATE_TMP}/#{CANARY_LEAF}"
TERMINAL_LEAF = "r18-guardian-terminal.json"
STAGING_TEMPLATE = "r18-guardian-terminal.XXXXXX.staging"
STAGING_SUFFIX_LENGTH = 8
STAGING_LEAF =
  /\Ar18-guardian-terminal\.[A-Za-z0-9]{6}\.staging\z/
RECEIPT_MAX_BYTES = 65_536
TERMINAL_MAX_BYTES = 16_384
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
EXPECTED_CANARY_GID = 0

O_RDONLY = 0
O_CLOEXEC = 0x01000000
O_NOFOLLOW_ANY = 0x20000000
O_DIRECTORY = 0x00100000
RENAME_EXCL = 0x00000004
RENAME_NOFOLLOW_ANY = 0x00000010
F_FULLFSYNC = 51

module R18TerminalFS
  extend Fiddle::Importer
  dlload Fiddle.dlopen(nil)
  extern "int mkdirat(int, const char*, unsigned int)"
  extern "int mkostempsat_np(int, char*, int, int)"
  extern "int renameatx_np(int, const char*, int, const char*, unsigned int)"
  extern "int fcntl(int, int)"
end

def path_absent?(path)
  File.lstat(path)
  false
rescue Errno::ENOENT
  true
end

def full_fsync(io)
  Fiddle.last_error = 0
  result = R18TerminalFS.fcntl(io.fileno, F_FULLFSYNC)
  error = Fiddle.last_error
  raise "fullfsync:#{error}" unless result == 0
  true
end

def sync_io(io)
  io.fsync
  full_fsync(io)
  {"fsync" => true, "fullfsync" => true}
end

def open_directory(path)
  flags = O_RDONLY | O_CLOEXEC | O_NOFOLLOW_ANY | O_DIRECTORY
  io = IO.new(IO.sysopen(path, flags))
  raise "directory-cloexec:#{path}" unless io.close_on_exec?
  io
end

def rejoin_directory(path, io)
  named = File.lstat(path)
  held = io.stat
  raise "directory-type:#{path}" unless named.directory? && held.directory?
  raise "directory-rebound:#{path}" unless
    [named.dev, named.ino] == [held.dev, held.ino]
  held
end

def rejoin_file(path, io)
  named = File.lstat(path)
  held = io.stat
  raise "file-type:#{path}" unless named.file? && held.file?
  raise "file-rebound:#{path}" unless
    [named.dev, named.ino] == [held.dev, held.ino]
  held
end

def stat_receipt(stat)
  {
    "dev" => stat.dev,
    "ino" => stat.ino,
    "uid" => stat.uid,
    "gid" => stat.gid,
    "mode" => format("%04o", stat.mode & 0o7777),
    "nlink" => stat.nlink,
    "size" => stat.size,
  }
end

def stat_signature(stat)
  [
    stat.dev, stat.ino, stat.uid, stat.gid, stat.mode & 0o7777,
    stat.nlink, stat.size, stat.mtime.to_r, stat.ctime.to_r,
  ]
end

def held_bytes(io)
  io.flush
  io.seek(0)
  bytes = io.read
  io.seek(0)
  bytes
end

def held_sha256(io)
  Digest::SHA256.hexdigest(held_bytes(io))
end

def canonical_terminal(report)
  payload = JSON.generate(report.sort.to_h)
  framed = report.merge("payload_sha256" => Digest::SHA256.hexdigest(payload))
  bytes = JSON.generate(framed.sort.to_h) + "\n"
  raise "terminal-cap" if bytes.bytesize > TERMINAL_MAX_BYTES
  bytes
end

def canonical_receipt(report)
  payload = JSON.generate(report.sort.to_h)
  framed = report.merge("payload_sha256" => Digest::SHA256.hexdigest(payload))
  bytes = JSON.generate(framed.sort.to_h) + "\n"
  raise "receipt-cap" if bytes.bytesize > RECEIPT_MAX_BYTES
  bytes
end

def mkdirat_once(parent, leaf)
  raise "directory-leaf:#{leaf}" unless leaf.match?(/\A[a-z0-9-]+\z/)
  Fiddle.last_error = 0
  result = R18TerminalFS.mkdirat(parent.fileno, leaf, 0o700)
  error = Fiddle.last_error
  raise "mkdirat:#{leaf}:#{error}" unless result == 0
end

def renameatx_once(parent, source, destination)
  Fiddle.last_error = 0
  result = R18TerminalFS.renameatx_np(
    parent.fileno, source, parent.fileno, destination,
    RENAME_EXCL | RENAME_NOFOLLOW_ANY
  )
  [result, Fiddle.last_error]
end

def validate_staging(io, parent_stat, mode:, size:)
  stat = io.stat
  expected = [
    parent_stat.dev, EXPECTED_UID, parent_stat.gid, mode, 1, size,
  ]
  observed = [
    stat.dev, stat.uid, stat.gid, stat.mode & 0o7777, stat.nlink, stat.size,
  ]
  raise "staging-metadata" unless observed == expected && stat.file?
  raise "staging-cloexec" unless io.close_on_exec?
  stat
end

def create_staging(parent, parent_path)
  parent_stat = rejoin_directory(parent_path, parent)
  template_bytes = STAGING_TEMPLATE + "\0"
  template = Fiddle::Pointer.malloc(template_bytes.bytesize)
  template[0, template_bytes.bytesize] = template_bytes
  Fiddle.last_error = 0
  descriptor = R18TerminalFS.mkostempsat_np(
    parent.fileno, template, STAGING_SUFFIX_LENGTH, O_CLOEXEC
  )
  error = Fiddle.last_error
  raise "mkostempsat-np:#{error}" unless descriptor >= 3
  leaf = template.to_s(STAGING_TEMPLATE.bytesize).split("\0", 2).first
  io = File.new(descriptor, "r+")
  begin
    raise "staging-leaf:#{leaf}" unless STAGING_LEAF.match?(leaf)
    stat = rejoin_file("#{parent_path}/#{leaf}", io)
    validate_staging(io, parent_stat, mode: 0o600, size: 0)
    [leaf, io, stat]
  rescue StandardError
    io.close unless io.closed?
    raise
  end
end

def seal_and_write(parent, parent_path, leaf, io, report)
  parent_stat = rejoin_directory(parent_path, parent)
  io.chmod(0o400)
  validate_staging(io, parent_stat, mode: 0o400, size: 0)
  terminal_report = report.merge(
    "generated_staging_leaf" => leaf,
    "staging_initial_mode" => "0600",
    "sealed_mode" => "0400"
  )
  bytes = canonical_terminal(terminal_report)
  written = io.write(bytes)
  raise "terminal-short-write" unless written == bytes.bytesize
  file_sync = sync_io(io)
  validate_staging(io, parent_stat, mode: 0o400, size: bytes.bytesize)
  raise "terminal-readback" unless held_bytes(io) == bytes
  raise "terminal-sha256" unless
    held_sha256(io) == Digest::SHA256.hexdigest(bytes)
  parent_sync = sync_io(parent)
  [bytes, file_sync, parent_sync]
end

def publish(parent, parent_path, leaf, io, bytes)
  source_path = "#{parent_path}/#{leaf}"
  final_path = "#{parent_path}/#{TERMINAL_LEAF}"
  raise "final-preexists" unless path_absent?(final_path)
  source_stat = rejoin_file(source_path, io)
  result, error = renameatx_once(parent, leaf, TERMINAL_LEAF)
  raise "terminal-publish:#{error}" unless result == 0
  raise "staging-remains" unless path_absent?(source_path)
  parent_stat = rejoin_directory(parent_path, parent)
  final_stat = rejoin_file(final_path, io)
  raise "publish-vnode" unless
    [source_stat.dev, source_stat.ino] == [final_stat.dev, final_stat.ino]
  validated = validate_staging(
    io, parent_stat, mode: 0o400, size: bytes.bytesize
  )
  raise "publish-stat-join" unless
    [validated.dev, validated.ino] == [final_stat.dev, final_stat.ino]
  raise "publish-bytes" unless held_bytes(io) == bytes
  raise "publish-sha256" unless
    held_sha256(io) == Digest::SHA256.hexdigest(bytes)
  parent_sync = sync_io(parent)
  parent_stat = rejoin_directory(parent_path, parent)
  final_stat = rejoin_file(final_path, io)
  validated = validate_staging(
    io, parent_stat, mode: 0o400, size: bytes.bytesize
  )
  raise "publish-stat-join-after-sync" unless
    [validated.dev, validated.ino] == [final_stat.dev, final_stat.ino]
  {
    "generated_staging_leaf" => leaf,
    "published_leaf" => TERMINAL_LEAF,
    "file" => stat_receipt(final_stat),
    "bytes" => bytes.bytesize,
    "sha256" => Digest::SHA256.hexdigest(bytes),
    "rename_errno" => error,
    "parent_sync" => parent_sync,
  }
end

def create_case_directory(root, leaf)
  mkdirat_once(root, leaf)
  path = "#{CANARY_ROOT}/#{leaf}"
  io = open_directory(path)
  stat = rejoin_directory(path, io)
  raise "case-directory-metadata:#{leaf}" unless
    [stat.dev, stat.uid, stat.gid, stat.mode & 0o7777, stat.nlink] ==
      [EXPECTED_DEVICE, EXPECTED_UID, EXPECTED_CANARY_GID, 0o700, 2]
  [path, io]
end

def relative_inventory(root)
  result = []
  pending = [[root, ""]]
  until pending.empty?
    absolute, relative = pending.shift
    Dir.children(absolute).sort.each do |leaf|
      child_absolute = "#{absolute}/#{leaf}"
      child_relative = relative.empty? ? leaf : "#{relative}/#{leaf}"
      stat = File.lstat(child_absolute)
      raise "inventory-symlink:#{child_relative}" if stat.symlink?
      raise "inventory-type:#{child_relative}" unless
        stat.directory? || stat.file?
      result << child_relative
      pending << [child_absolute, child_relative] if stat.directory?
    end
  end
  result.sort
end

incoming_umask = File.umask(0o077)
held = []
root_created = false
report = {
  "status" => "R18_TERMINAL_CANARY_FAILED",
  "authority_vector" => "00000000",
  "scientific_outcome" => "ABSTAIN",
  "gate_e_clearance" => 0,
  "canary_root" => CANARY_ROOT,
  "incoming_umask" => format("%04o", incoming_umask),
  "process_spawn_calls" => 0,
  "signals" => 0,
  "swift_commands" => 0,
  "git_commands" => 0,
}

begin
  raise "incoming-umask" unless incoming_umask == 0o077
  raise "runtime-ruby-version" unless
    [RUBY_VERSION, RUBY_PATCHLEVEL, RUBY_PLATFORM] ==
      ["2.6.10", 210, "universal.arm64e-darwin25"]
  raise "runtime-pointer-width" unless [0].pack("J").bytesize == 8
  raise "runtime-byte-order" unless [1].pack("L").bytes == [1, 0, 0, 0]
  raise "runtime-fiddle" unless
    R18TerminalFS.respond_to?(:mkdirat) &&
    R18TerminalFS.respond_to?(:mkostempsat_np) &&
    R18TerminalFS.respond_to?(:renameatx_np) &&
    R18TerminalFS.respond_to?(:fcntl)
  raise "runtime-file-chmod" unless File.instance_methods.include?(:chmod)
  raise "credentials" unless
    [Process.uid, Process.euid, Process.gid, Process.egid] ==
      [EXPECTED_UID, EXPECTED_UID, EXPECTED_GID, EXPECTED_GID]
  raise "supplementary-groups" unless Process.groups.sort == EXPECTED_GROUPS
  raise "canary-root-preexists" unless path_absent?(CANARY_ROOT)

  private_tmp = open_directory(PRIVATE_TMP)
  held << private_tmp
  private_stat = rejoin_directory(PRIVATE_TMP, private_tmp)
  raise "private-tmp-preimage" unless
    [
      private_stat.dev, private_stat.ino, private_stat.uid, private_stat.gid,
      private_stat.mode & 0o7777,
    ] == [
      EXPECTED_DEVICE, EXPECTED_PARENT_INODE, EXPECTED_PARENT_UID,
      EXPECTED_PARENT_GID, EXPECTED_PARENT_MODE,
    ]

  mkdirat_once(private_tmp, CANARY_LEAF)
  root_created = true
  root = open_directory(CANARY_ROOT)
  held << root
  root_stat = rejoin_directory(CANARY_ROOT, root)
  raise "canary-root-metadata" unless
    [root_stat.dev, root_stat.uid, root_stat.gid, root_stat.mode & 0o7777] ==
      [EXPECTED_DEVICE, EXPECTED_UID, EXPECTED_CANARY_GID, 0o700]

  cases = {}

  success_path, success_dir = create_case_directory(root, "success")
  held << success_dir
  success_leaf, success_io, success_initial =
    create_staging(success_dir, success_path)
  held << success_io
  success_bytes, success_file_sync, success_parent_sync = seal_and_write(
    success_dir, success_path, success_leaf, success_io,
    "case" => "success", "status" => "CANARY_TERMINAL"
  )
  success = publish(
    success_dir, success_path, success_leaf, success_io, success_bytes
  )
  success["initial"] = stat_receipt(success_initial)
  success["file_sync"] = success_file_sync
  success["prepublish_parent_sync"] = success_parent_sync
  cases["success"] = success

  collision_path, collision_dir = create_case_directory(root, "collision")
  held << collision_dir
  destination_leaf, destination_io, =
    create_staging(collision_dir, collision_path)
  held << destination_io
  destination_bytes, = seal_and_write(
    collision_dir, collision_path, destination_leaf, destination_io,
    "case" => "collision-destination", "status" => "CANARY_TERMINAL"
  )
  destination = publish(
    collision_dir, collision_path, destination_leaf, destination_io,
    destination_bytes
  )
  destination_before = destination_io.stat
  destination_signature_before = stat_signature(destination_before)
  destination_hash_before = held_sha256(destination_io)

  collision_leaf, collision_io, = create_staging(collision_dir, collision_path)
  held << collision_io
  collision_bytes, = seal_and_write(
    collision_dir, collision_path, collision_leaf, collision_io,
    "case" => "collision-source", "status" => "CANARY_TERMINAL"
  )
  collision_source_before = collision_io.stat
  collision_source_signature_before = stat_signature(collision_source_before)
  result, collision_errno = renameatx_once(
    collision_dir, collision_leaf, TERMINAL_LEAF
  )
  raise "collision-result:#{result}:#{collision_errno}" unless
    result == -1 && collision_errno == Errno::EEXIST::Errno
  collision_source_after = rejoin_file(
    "#{collision_path}/#{collision_leaf}", collision_io
  )
  destination_after = rejoin_file(
    "#{collision_path}/#{TERMINAL_LEAF}", destination_io
  )
  raise "collision-source-mutated" unless
    collision_source_signature_before ==
      stat_signature(collision_source_after) &&
    held_bytes(collision_io) == collision_bytes
  raise "collision-destination-mutated" unless
    destination_signature_before == stat_signature(destination_after) &&
    destination_hash_before == held_sha256(destination_io)
  collision_parent_stat = rejoin_directory(collision_path, collision_dir)
  validate_staging(
    collision_io, collision_parent_stat,
    mode: 0o400, size: collision_bytes.bytesize
  )
  validate_staging(
    destination_io, collision_parent_stat,
    mode: 0o400, size: destination_bytes.bytesize
  )
  cases["collision"] = {
    "destination" => destination,
    "source_generated_staging_leaf" => collision_leaf,
    "source" => stat_receipt(collision_source_after),
    "source_sha256" => Digest::SHA256.hexdigest(collision_bytes),
    "rename_errno" => collision_errno,
    "destination_unchanged" => true,
    "source_unchanged" => true,
  }

  rebound_original_path, rebound_dir =
    create_case_directory(root, "rebound-original")
  held << rebound_dir
  result, rebound_errno = renameatx_once(
    root, "rebound-original", "rebound-held"
  )
  raise "rebound-rename:#{rebound_errno}" unless result == 0
  rebound_held_path = "#{CANARY_ROOT}/rebound-held"
  raise "rebound-source-remains" unless path_absent?(rebound_original_path)
  rejoin_directory(rebound_held_path, rebound_dir)
  replacement_path, replacement_dir =
    create_case_directory(root, "rebound-original")
  held << replacement_dir
  rebound_leaf, rebound_io, = create_staging(rebound_dir, rebound_held_path)
  held << rebound_io
  rebound_bytes, = seal_and_write(
    rebound_dir, rebound_held_path, rebound_leaf, rebound_io,
    "case" => "held-parent-rebound", "status" => "CANARY_TERMINAL"
  )
  rebound = publish(
    rebound_dir, rebound_held_path, rebound_leaf, rebound_io, rebound_bytes
  )
  raise "rebound-replacement-mutated" unless
    Dir.children(replacement_path).empty?
  cases["held_parent_rebound"] = rebound.merge(
    "original_path_replaced" => true,
    "held_path" => rebound_held_path,
    "replacement_inventory" => [],
    "directory_rename_errno" => rebound_errno
  )

  created_path, created_dir =
    create_case_directory(root, "residual-created")
  held << created_dir
  created_leaf, created_io, created_stat =
    create_staging(created_dir, created_path)
  held << created_io
  cases["residual_created"] = {
    "authoritative" => false,
    "generated_staging_leaf" => created_leaf,
    "final_absent" => path_absent?("#{created_path}/#{TERMINAL_LEAF}"),
    "file" => stat_receipt(created_stat),
  }

  written_path, written_dir =
    create_case_directory(root, "residual-written")
  held << written_dir
  written_leaf, written_io, = create_staging(written_dir, written_path)
  held << written_io
  written_bytes, = seal_and_write(
    written_dir, written_path, written_leaf, written_io,
    "case" => "residual-written", "status" => "CANARY_STAGING_ONLY"
  )
  written_stat = rejoin_file("#{written_path}/#{written_leaf}", written_io)
  cases["residual_written"] = {
    "authoritative" => false,
    "generated_staging_leaf" => written_leaf,
    "final_absent" => path_absent?("#{written_path}/#{TERMINAL_LEAF}"),
    "file" => stat_receipt(written_stat),
    "sha256" => Digest::SHA256.hexdigest(written_bytes),
  }

  sync_io(root)
  sync_io(private_tmp)
  final_root = rejoin_directory(CANARY_ROOT, root)
  expected_inventory = [
    "collision",
    "collision/#{TERMINAL_LEAF}",
    "collision/#{collision_leaf}",
    "rebound-held",
    "rebound-held/#{TERMINAL_LEAF}",
    "rebound-original",
    "residual-created",
    "residual-created/#{created_leaf}",
    "residual-written",
    "residual-written/#{written_leaf}",
    "success",
    "success/#{TERMINAL_LEAF}",
  ].sort
  inventory = relative_inventory(CANARY_ROOT)
  raise "final-inventory" unless inventory == expected_inventory

  report["status"] = "R18_TERMINAL_CANARY_PASS"
  report["root"] = stat_receipt(final_root)
  report["cases"] = cases
  report["inventory"] = inventory
  report["inventory_count"] = inventory.length
  report["inventory_sha256"] =
    Digest::SHA256.hexdigest(inventory.join("\n") + "\n")
  receipt = canonical_receipt(report)
  written = STDOUT.write(receipt)
  raise "receipt-short-write" unless written == receipt.bytesize
  STDOUT.flush
rescue StandardError => error
  report["error"] = "#{error.class}:#{error.message}".byteslice(0, 512)
  report["root_created"] = root_created
  begin
    report["inventory"] = relative_inventory(CANARY_ROOT) if root_created
  rescue StandardError => observation_error
    report["observation_error"] =
      "#{observation_error.class}:#{observation_error.message}".byteslice(0, 512)
  end
  STDERR.write(canonical_receipt(report))
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
