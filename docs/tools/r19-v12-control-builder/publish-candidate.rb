# frozen_string_literal: true

require "digest"
require "fiddle/import"
require "json"
require_relative "control-file"

USAGE =
  "usage: #{$PROGRAM_NAME} CANDIDATE TARGET JOURNAL " \
  "NEW_SHA256 NEW_BYTES OLD_SHA256 OLD_BYTES"
abort(USAGE) unless ARGV.length == 7

candidate_argument, target_argument, journal_argument, expected_new_sha,
  expected_new_bytes_text, expected_old_sha, expected_old_bytes_text = ARGV

unless expected_new_sha.match?(/\A[0-9a-f]{64}\z/) &&
       expected_old_sha.match?(/\A[0-9a-f]{64}\z/) &&
       expected_new_bytes_text.match?(/\A[1-9][0-9]*\z/) &&
       expected_old_bytes_text.match?(/\A[1-9][0-9]*\z/)
  abort("invalid expected identity")
end

expected_new_bytes = Integer(expected_new_bytes_text, 10)
expected_old_bytes = Integer(expected_old_bytes_text, 10)

O_RDONLY = 0
O_CLOEXEC = 0x01000000
O_DIRECTORY = 0x00100000
O_NOFOLLOW_ANY = 0x20000000
RENAME_SWAP = 0x00000002
RENAME_NOFOLLOW_ANY = 0x00000010
JOURNAL_MODE = 0o600
MAX_LEAF_BYTES = 255
MAX_JOURNAL_BYTES = 1_048_576
NATIVE_ERRNO_ZERO = [0].pack("l<").freeze

module V12PublishDarwin
  extend Fiddle::Importer
  dlload Fiddle.dlopen(nil)
  extern "void* __error()"
  extern "int fchdir(int)"
  extern "int fchmod(int,unsigned int)"
  extern "int fchown(int,int,int)"
  extern "int fclonefileat(int,int,const char*,unsigned int)"
  extern "int renameatx_np(int,const char*,int,const char*,unsigned int)"
end

def v12_native_call(label)
  raise "#{label}:abi" unless
    Fiddle::SIZEOF_INT == 4 && Fiddle::SIZEOF_VOIDP == 8

  errno_address = V12PublishDarwin.__error.to_i
  raise "#{label}:errno-pointer" if errno_address.zero?

  errno_pointer = Fiddle::Pointer.new(errno_address)
  Fiddle.last_error = 0
  errno_pointer[0, 4] = NATIVE_ERRNO_ZERO
  result = yield
  native_errno = errno_pointer[0, 4].unpack1("l<")
  fiddle_errno = Fiddle.last_error
  raise "#{label}:errno-snapshot" unless
    native_errno.is_a?(Integer) && fiddle_errno.is_a?(Integer)

  [result, native_errno, fiddle_errno]
end

def v12_canonical_value(value)
  case value
  when Hash
    value.keys.sort.each_with_object({}) do |key, result|
      raise "canonical non-string key" unless key.is_a?(String)
      result[key] = v12_canonical_value(value.fetch(key))
    end
  when Array
    value.map { |entry| v12_canonical_value(entry) }
  when String, Integer, TrueClass, FalseClass, NilClass
    value
  else
    raise "canonical unsupported type:#{value.class.name}"
  end
end

def v12_canonical_json(value)
  JSON.generate(v12_canonical_value(value))
end

def v12_journal_frame(payload, ordinal, previous_frame_with_lf_sha256)
  payload_bytes = v12_canonical_json(payload).b
  without_self_digest = {
    "ordinal_uint" => ordinal,
    "payload" => payload,
    "payload_sha256" => Digest::SHA256.hexdigest(payload_bytes),
    "previous_frame_with_lf_sha256_or_null" =>
      previous_frame_with_lf_sha256,
    "schema" => "ergentics.r19.v12-control-publication-journal-frame.v1",
  }
  without_self_bytes = v12_canonical_json(without_self_digest).b
  frame = without_self_digest.merge(
    "frame_without_self_digest_sha256" =>
      Digest::SHA256.hexdigest(without_self_bytes)
  )
  v12_canonical_json(frame).b + "\n"
end

def v12_stat_record(stat)
  {
    "device_uint" => stat.dev,
    "gid_uint" => stat.gid,
    "inode_uint" => stat.ino,
    "mode_octal4" => format("%04o", stat.mode & 0o7777),
    "nlink_uint" => stat.nlink,
    "size_uint" => stat.size,
    "uid_uint" => stat.uid,
  }
end

def v12_stat_signature(stat)
  [
    stat.dev, stat.ino, stat.uid, stat.gid, stat.mode & 0o7777,
    stat.nlink, stat.size, stat.mtime.to_r, stat.ctime.to_r,
  ]
end

def v12_directory_signature(stat)
  [
    stat.dev, stat.ino, stat.uid, stat.gid, stat.mode & 0o7777,
  ]
end

def v12_digest(io)
  digest = V12ControlFile.digest_held(io)
  io.rewind
  digest
end

def v12_write_all(io, bytes)
  offset = 0
  while offset < bytes.bytesize
    written = io.syswrite(bytes.byteslice(offset, bytes.bytesize - offset))
    raise "zero-length write" unless written && written.positive?
    offset += written
  end
  io.flush
  offset
end

def v12_read_all(io)
  io.flush
  io.rewind
  bytes = io.read(MAX_JOURNAL_BYTES + 1)
  raise "journal read cap" if bytes.bytesize > MAX_JOURNAL_BYTES
  io.seek(0, IO::SEEK_END)
  bytes
end

def v12_leaf!(leaf, label)
  raise "#{label}:not-leaf" unless
    leaf == File.basename(leaf) && leaf != "." && leaf != ".." &&
    !leaf.include?("\0") && !leaf.include?("/")
  utf8_leaf = leaf.b.dup.force_encoding(Encoding::UTF_8)
  raise "#{label}:encoding" unless utf8_leaf.valid_encoding?
  raise "#{label}:name-max" if utf8_leaf.b.bytesize > MAX_LEAF_BYTES
  utf8_leaf
end

def v12_absent?(path)
  File.lstat(path)
  false
rescue Errno::ENOENT
  true
end

def v12_open_readonly(path)
  descriptor = IO.sysopen(
    path, O_RDONLY | File::NONBLOCK | O_CLOEXEC | O_NOFOLLOW_ANY
  )
  io = File.new(descriptor, "rb")
  raise "read descriptor is not close-on-exec:#{path}" unless io.close_on_exec?
  io
end

def v12_open_directory(path)
  descriptor = IO.sysopen(
    path, O_RDONLY | O_CLOEXEC | O_NOFOLLOW_ANY | O_DIRECTORY
  )
  io = File.new(descriptor, "rb")
  raise "directory descriptor is not close-on-exec:#{path}" unless
    io.close_on_exec?
  raise "not directory:#{path}" unless io.stat.directory?
  io
end

def v12_join!(path, io, type, label)
  named = File.lstat(path)
  held = io.stat
  expected_type = type == :directory ? named.directory? : named.file?
  held_type = type == :directory ? held.directory? : held.file?
  raise "#{label}:type" unless expected_type && held_type && !named.symlink?
  raise "#{label}:identity" unless
    [named.dev, named.ino] == [held.dev, held.ino]
  held
end

def v12_require_regular!(io, label, nlink: 1)
  stat = io.stat
  raise "#{label}:type" unless stat.file?
  raise "#{label}:nlink" unless stat.nlink == nlink
  stat
end

def v12_clone!(source, parent, destination_leaf, label)
  result, native_errno, fiddle_errno = v12_native_call(label) do
    V12PublishDarwin.fclonefileat(
      source.fileno, parent.fileno, destination_leaf, 0
    )
  end
  raise "#{label}:#{native_errno}:#{fiddle_errno}" unless result == 0
end

def v12_append_journal!(journal, journal_bytes, frame)
  raise "journal cap" if journal_bytes.bytesize + frame.bytesize > MAX_JOURNAL_BYTES
  journal.seek(0, IO::SEEK_END)
  v12_write_all(journal, frame)
  journal.fsync
  combined = journal_bytes + frame
  raise "journal readback" unless v12_read_all(journal) == combined
  combined
end

def v12_failure_payload(error, phase)
  message = error.message.to_s.b
  prefix = message.byteslice(0, 1024)
  {
    "error_class" => error.class.name,
    "error_message_bytes_uint" => message.bytesize,
    "error_message_prefix_hex" => prefix.unpack1("H*"),
    "error_message_prefix_truncated_bool" => prefix.bytesize != message.bytesize,
    "error_message_sha256" => Digest::SHA256.hexdigest(message),
    "event_type_enum" => "FAIL",
    "phase_enum" => phase,
    "result_enum" => "FAIL_RETAINED_NO_RETRY",
    "schema" => "ergentics.r19.v12-control-publication-event.v1",
  }
end

candidate_path = File.expand_path(candidate_argument)
target_path = File.expand_path(target_argument)
journal_path = File.expand_path(journal_argument)
target_parent = File.dirname(target_path)
target_parent_real = File.realpath(target_parent)
raise "target parent is not canonical" unless target_parent == target_parent_real
raise "candidate is not canonical" unless File.realpath(candidate_path) == candidate_path
raise "target is not canonical" unless File.realpath(target_path) == target_path
raise "candidate target path alias" if candidate_path == target_path
raise "journal parent mismatch" unless File.dirname(journal_path) == target_parent

target_leaf = v12_leaf!(File.basename(target_path), "target leaf")
journal_leaf = v12_leaf!(File.basename(journal_path), "journal leaf")
exchange_leaf = v12_leaf!(
  ".#{target_leaf}.#{expected_new_sha[0, 16]}.exchange-retained",
  "exchange leaf"
)
predecessor_leaf = v12_leaf!(
  ".#{target_leaf}.#{expected_old_sha[0, 16]}.predecessor-content-retained",
  "predecessor leaf"
)
raise "publication leaf collision" unless
  [target_leaf, journal_leaf, exchange_leaf, predecessor_leaf].uniq.length == 4

parent = nil
candidate = nil
target = nil
journal = nil
exchange = nil
predecessor_copy = nil
published = nil
retained_exchange = nil
journal_bytes = "".b
phase = "PREFLIGHT"

begin
  parent = v12_open_directory(target_parent)
  parent_admitted = v12_join!(target_parent, parent, :directory, "parent")
  parent_signature = v12_directory_signature(parent_admitted)

  changed, native_errno, fiddle_errno = v12_native_call("fchdir") do
    V12PublishDarwin.fchdir(parent.fileno)
  end
  raise "fchdir:#{native_errno}:#{fiddle_errno}" unless changed == 0
  raise "cwd parent identity" unless
    v12_directory_signature(File.lstat(".")) == parent_signature

  raise "journal leaf already exists" unless v12_absent?(journal_leaf)
  raise "exchange leaf already exists" unless v12_absent?(exchange_leaf)
  raise "predecessor leaf already exists" unless v12_absent?(predecessor_leaf)

  candidate = v12_open_readonly(candidate_path)
  target = v12_open_readonly(target_leaf)
  candidate_before = v12_require_regular!(candidate, "candidate")
  target_before = v12_require_regular!(target, "target")
  v12_join!(candidate_path, candidate, :file, "candidate")
  v12_join!(target_leaf, target, :file, "target")
  raise "candidate target vnode alias" if
    [candidate_before.dev, candidate_before.ino] ==
      [target_before.dev, target_before.ino]
  raise "same-device prerequisite" unless
    candidate_before.dev == target_before.dev &&
    target_before.dev == parent_admitted.dev
  raise "candidate expected identity" unless
    [v12_digest(candidate), candidate_before.size] ==
      [expected_new_sha, expected_new_bytes]
  raise "target predecessor identity" unless
    [v12_digest(target), target_before.size] ==
      [expected_old_sha, expected_old_bytes]

  start_payload = {
    "candidate" => v12_stat_record(candidate_before).merge(
      "bytes_uint" => expected_new_bytes,
      "path" => candidate_path,
      "sha256" => expected_new_sha
    ),
    "event_type_enum" => "START",
    "exchange_leaf" => exchange_leaf,
    "journal_leaf" => journal_leaf,
    "parent" => v12_stat_record(parent_admitted).merge("path" => target_parent),
    "predecessor_content_leaf" => predecessor_leaf,
    "publication_primitive" =>
      "FCLONEFILEAT_HELD_SOURCES_THEN_RENAMEATX_NP_RENAME_SWAP",
    "result_enum" => "START_DURABLE_BEFORE_PUBLICATION_MUTATION",
    "same_device_prerequisite_bool" => true,
    "schema" => "ergentics.r19.v12-control-publication-event.v1",
    "target" => v12_stat_record(target_before).merge(
      "bytes_uint" => expected_old_bytes,
      "path" => target_path,
      "sha256" => expected_old_sha
    ),
  }
  start_frame = v12_journal_frame(start_payload, 0, nil)
  journal = File.open(
    journal_leaf,
    File::RDWR | File::CREAT | File::EXCL | File::NOFOLLOW,
    JOURNAL_MODE
  )
  raise "journal descriptor is not close-on-exec" unless journal.close_on_exec?
  journal_bytes = v12_append_journal!(journal, journal_bytes, start_frame)
  parent.fsync
  journal_stat = v12_require_regular!(journal, "journal")
  v12_join!(journal_leaf, journal, :file, "journal-start")
  raise "journal mode" unless (journal_stat.mode & 0o7777) == JOURNAL_MODE
  phase = "START_DURABLE"

  v12_clone!(target, parent, predecessor_leaf, "clone-predecessor")
  predecessor_copy = v12_open_readonly(predecessor_leaf)
  predecessor_stat = v12_require_regular!(
    predecessor_copy, "predecessor copy"
  )
  v12_join!(predecessor_leaf, predecessor_copy, :file, "predecessor copy")
  raise "predecessor copy same-device" unless predecessor_stat.dev == parent_admitted.dev
  raise "predecessor copy metadata" unless
    [predecessor_stat.uid, predecessor_stat.gid,
     predecessor_stat.mode & 0o7777, predecessor_stat.size] ==
      [target_before.uid, target_before.gid,
       target_before.mode & 0o7777, expected_old_bytes]
  raise "predecessor copy digest" unless
    v12_digest(predecessor_copy) == expected_old_sha
  predecessor_copy.fsync
  parent.fsync
  phase = "PREDECESSOR_CONTENT_RETAINED"

  v12_clone!(candidate, parent, exchange_leaf, "clone-candidate")
  exchange = v12_open_readonly(exchange_leaf)
  changed, native_errno, fiddle_errno = v12_native_call("exchange-fchown") do
    V12PublishDarwin.fchown(
      exchange.fileno, target_before.uid, target_before.gid
    )
  end
  raise "exchange-fchown:#{native_errno}:#{fiddle_errno}" unless changed == 0
  changed, native_errno, fiddle_errno = v12_native_call("exchange-fchmod") do
    V12PublishDarwin.fchmod(exchange.fileno, target_before.mode & 0o7777)
  end
  raise "exchange-fchmod:#{native_errno}:#{fiddle_errno}" unless changed == 0
  exchange_before = v12_require_regular!(exchange, "candidate exchange")
  v12_join!(exchange_leaf, exchange, :file, "candidate exchange")
  raise "candidate exchange same-device" unless exchange_before.dev == parent_admitted.dev
  raise "candidate exchange metadata" unless
    [exchange_before.uid, exchange_before.gid,
     exchange_before.mode & 0o7777, exchange_before.size] ==
      [target_before.uid, target_before.gid,
       target_before.mode & 0o7777, expected_new_bytes]
  raise "candidate exchange digest" unless v12_digest(exchange) == expected_new_sha
  exchange.fsync
  parent.fsync
  phase = "CANDIDATE_EXCHANGE_RETAINED"

  candidate_prerename = candidate.stat
  target_prerename = target.stat
  predecessor_prerename = predecessor_copy.stat
  exchange_prerename = exchange.stat
  raise "candidate descriptor drift" unless
    v12_stat_signature(candidate_prerename) ==
      v12_stat_signature(candidate_before)
  raise "target descriptor drift" unless
    v12_stat_signature(target_prerename) == v12_stat_signature(target_before)
  raise "predecessor copy drift" unless
    v12_stat_signature(predecessor_prerename) ==
      v12_stat_signature(predecessor_stat)
  raise "candidate exchange drift" unless
    v12_stat_signature(exchange_prerename) ==
      v12_stat_signature(exchange_before)
  raise "candidate digest drift" unless v12_digest(candidate) == expected_new_sha
  raise "target digest drift" unless v12_digest(target) == expected_old_sha
  raise "predecessor copy digest drift" unless
    v12_digest(predecessor_copy) == expected_old_sha
  raise "candidate exchange digest drift" unless
    v12_digest(exchange) == expected_new_sha
  v12_join!(candidate_path, candidate, :file, "candidate-prerename")
  v12_join!(target_leaf, target, :file, "target-prerename")
  v12_join!(predecessor_leaf, predecessor_copy, :file, "predecessor-prerename")
  v12_join!(exchange_leaf, exchange, :file, "exchange-prerename")
  v12_join!(target_parent, parent, :directory, "parent-prerename")
  raise "parent policy drift" unless
    v12_directory_signature(parent.stat) == parent_signature

  phase = "RENAME_SWAP_ENTERED"
  swapped, native_errno, fiddle_errno = v12_native_call("rename-swap") do
    V12PublishDarwin.renameatx_np(
      parent.fileno, exchange_leaf, parent.fileno, target_leaf,
      RENAME_SWAP | RENAME_NOFOLLOW_ANY
    )
  end
  raise "rename-swap:#{native_errno}:#{fiddle_errno}" unless swapped == 0
  parent.fsync
  phase = "RENAME_SWAP_PARENT_SYNCED"

  published = v12_open_readonly(target_leaf)
  retained_exchange = v12_open_readonly(exchange_leaf)
  published_stat = v12_require_regular!(published, "published")
  retained_exchange_stat = v12_require_regular!(
    retained_exchange, "retained exchange"
  )
  v12_join!(target_leaf, published, :file, "published")
  v12_join!(exchange_leaf, retained_exchange, :file, "retained exchange")
  v12_join!(predecessor_leaf, predecessor_copy, :file, "predecessor-final")
  v12_join!(candidate_path, candidate, :file, "candidate-final")
  v12_join!(target_parent, parent, :directory, "parent-final")
  raise "published candidate clone identity" unless
    [published_stat.dev, published_stat.ino] ==
      [exchange_before.dev, exchange_before.ino]
  raise "retained predecessor vnode identity" unless
    [retained_exchange_stat.dev, retained_exchange_stat.ino] ==
      [target_before.dev, target_before.ino]
  raise "published expected identity" unless
    [v12_digest(published), published_stat.size] ==
      [expected_new_sha, expected_new_bytes]
  raise "retained exchange expected identity" unless
    [v12_digest(retained_exchange), retained_exchange_stat.size] ==
      [expected_old_sha, expected_old_bytes]
  raise "retained content expected identity" unless
    [v12_digest(predecessor_copy), predecessor_copy.stat.size] ==
      [expected_old_sha, expected_old_bytes]
  raise "parent final policy drift" unless
    v12_directory_signature(parent.stat) == parent_signature

  pass_payload = {
    "candidate_exchange_before_swap" => v12_stat_record(exchange_before),
    "event_type_enum" => "PASS",
    "journal_before_pass_append" =>
      v12_stat_record(journal.stat).merge("path" => journal_path),
    "parent_fsync_after_swap_bool" => true,
    "predecessor_content_retained" =>
      v12_stat_record(predecessor_copy.stat).merge(
        "leaf" => predecessor_leaf,
        "sha256" => expected_old_sha
      ),
    "published" => v12_stat_record(published_stat).merge(
      "path" => target_path,
      "sha256" => expected_new_sha
    ),
    "result_enum" => "PASS_ATOMIC_EXCHANGE_PREDECESSOR_RETAINED",
    "retained_exchange" => v12_stat_record(retained_exchange_stat).merge(
      "leaf" => exchange_leaf,
      "sha256" => expected_old_sha
    ),
    "same_device_prerequisite_bool" => true,
    "schema" => "ergentics.r19.v12-control-publication-event.v1",
    "swap_join_bool" => true,
  }
  pass_frame = v12_journal_frame(
    pass_payload, 1, Digest::SHA256.hexdigest(start_frame)
  )
  journal_bytes = v12_append_journal!(journal, journal_bytes, pass_frame)
  parent.fsync
  v12_join!(journal_leaf, journal, :file, "journal-pass")
  raise "journal final bytes" unless v12_read_all(journal) == journal_bytes
  phase = "PASS_DURABLE"

  STDOUT.binmode
  STDOUT.write(v12_canonical_json({
    "candidate_bytes_uint" => expected_new_bytes,
    "candidate_sha256" => expected_new_sha,
    "exchange_leaf" => exchange_leaf,
    "journal_bytes_uint" => journal_bytes.bytesize,
    "journal_path" => journal_path,
    "journal_sha256" => Digest::SHA256.hexdigest(journal_bytes),
    "predecessor_bytes_uint" => expected_old_bytes,
    "predecessor_content_leaf" => predecessor_leaf,
    "predecessor_sha256" => expected_old_sha,
    "result_enum" => "PASS_ATOMIC_EXCHANGE_PREDECESSOR_RETAINED",
    "schema" => "ergentics.r19.v12-control-publication-receipt.v2",
    "target_path" => target_path,
  }) + "\n")
rescue StandardError => error
  if journal && !journal.closed? && !journal_bytes.empty? && phase != "PASS_DURABLE"
    begin
      raise "journal prefix drift" unless v12_read_all(journal) == journal_bytes
      previous = Digest::SHA256.hexdigest(journal_bytes.lines.last)
      failure_frame = v12_journal_frame(
        v12_failure_payload(error, phase),
        journal_bytes.count("\n"),
        previous
      )
      journal_bytes = v12_append_journal!(journal, journal_bytes, failure_frame)
      parent.fsync if parent && !parent.closed?
    rescue StandardError
      # The already-fsynced START or longer prefix is the retained outcome.
    end
  end
  STDERR.write(v12_canonical_json({
    "error" => v12_failure_payload(error, phase),
    "journal_path" => journal_path,
    "result_enum" => "FAIL_RETAINED_NO_RETRY",
    "schema" => "ergentics.r19.v12-control-publication-diagnostic.v1",
  }) + "\n")
  exit 70
ensure
  [published, retained_exchange, predecessor_copy, exchange, journal,
   target, candidate, parent].each do |io|
    begin
      io.close if io && !io.closed?
    rescue StandardError
      nil
    end
  end
end
