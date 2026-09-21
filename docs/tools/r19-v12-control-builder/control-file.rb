# frozen_string_literal: true

# Finite intake for the existing local V12 scratch transformers. This is not
# the authoritative publication route; publish-candidate.rb retains that role.
require "digest"

module V12ControlFile
  MAX_BYTES = 64 * 1024 * 1024
  O_NOFOLLOW_ANY = 0x20000000
  O_CLOEXEC = 0x01000000
  Snapshot = Struct.new(:path, :bytes, :signature, :writable_identity, keyword_init: true)

  module_function

  def signature(stat)
    [stat.dev, stat.ino, stat.mode, stat.uid, stat.gid, stat.nlink, stat.size,
     stat.mtime.to_i, stat.mtime.nsec, stat.ctime.to_i, stat.ctime.nsec]
  end

  def with_regular(path, access)
    raise "V12_CONTROL_DARWIN_REQUIRED" unless RUBY_PLATFORM.include?("darwin")
    descriptor = nil
    io = nil
    begin
      descriptor = IO.sysopen(path, access | File::NONBLOCK | O_NOFOLLOW_ANY | O_CLOEXEC)
      io = File.new(descriptor, access == File::RDONLY ? "rb" : "r+b")
      descriptor = nil
      raise "V12_CONTROL_NOT_REGULAR" unless io.stat.file?
      raise "V12_CONTROL_NOT_CLOEXEC" unless io.close_on_exec?
      yield io
    ensure
      io.close if io && !io.closed?
      IO.new(descriptor).close if descriptor
    end
  end

  def read_held(io)
    before = io.stat
    raise "V12_CONTROL_NOT_REGULAR" unless before.file?
    raise "V12_CONTROL_SIZE_LIMIT" unless before.size.between?(0, MAX_BYTES)
    io.rewind
    bytes = io.read(before.size + 1) || "".b
    raise "V12_CONTROL_CHANGED_DURING_READ" unless
      bytes.bytesize == before.size && signature(before) == signature(io.stat)
    bytes
  end

  # The publisher already admits an exact expected file size. Hash that finite
  # snapshot in chunks, without imposing the scratch JSON allocation limit.
  def digest_held(io)
    before = io.stat
    raise "V12_CONTROL_NOT_REGULAR" unless before.file?
    remaining = before.size
    digest = Digest::SHA256.new
    io.rewind
    while remaining.positive?
      chunk = io.read([remaining, 65_536].min)
      raise "V12_CONTROL_CHANGED_DURING_READ" if chunk.nil? || chunk.empty?
      digest.update(chunk)
      remaining -= chunk.bytesize
    end
    raise "V12_CONTROL_CHANGED_DURING_READ" unless
      io.read(1).nil? && signature(before) == signature(io.stat)
    digest.hexdigest
  end

  def capture(path)
    absolute = File.expand_path(path)
    with_regular(absolute, File::RDONLY) do |io|
      before = io.stat
      bytes = read_held(io)
      expected = signature(before)
      raise "V12_CONTROL_NAMED_IDENTITY" unless expected == signature(File.lstat(absolute))
      Snapshot.new(
        path: absolute.freeze, bytes: bytes.freeze, signature: expected.freeze,
        writable_identity: before.nlink == 1 && before.uid == Process.euid
      ).freeze
    end
  end

  def overwrite_scratch(snapshot, bytes)
    raise "V12_CONTROL_SIZE_LIMIT" if bytes.bytesize > MAX_BYTES
    raise "V12_CONTROL_SCRATCH_OWNERSHIP" unless snapshot.writable_identity
    with_regular(snapshot.path, File::RDWR) do |io|
      raise "V12_CONTROL_SCRATCH_BUSY" unless io.flock(File::LOCK_EX | File::LOCK_NB)
      raise "V12_CONTROL_CHANGED_BEFORE_WRITE" unless
        signature(io.stat) == snapshot.signature &&
        signature(File.lstat(snapshot.path)) == snapshot.signature &&
        read_held(io) == snapshot.bytes
      io.rewind
      offset = 0
      while offset < bytes.bytesize
        count = io.syswrite(bytes.byteslice(offset, bytes.bytesize - offset))
        raise "V12_CONTROL_SHORT_WRITE" unless count && count.positive?
        offset += count
      end
      io.truncate(bytes.bytesize)
      io.fsync
      written = signature(io.stat)
      raise "V12_CONTROL_WRITE_READBACK" unless
        read_held(io) == bytes && signature(io.stat) == written
      # A pathname may have been replaced after the pre-write identity check.
      # Reopen without following any symlink and bind success to the new bytes
      # still being named here. This is an observation, not atomic publication.
      with_regular(snapshot.path, File::RDONLY) do |named|
        raise "V12_CONTROL_CHANGED_AFTER_WRITE" unless signature(named.stat) == written
      end
      offset
    end
  end
end
