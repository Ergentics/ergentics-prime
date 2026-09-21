# Finite synthetic I/O fixtures; no historical V12 transformation is executed.
require "json"
require "digest"
require "tmpdir"
require "fileutils"
require_relative "../control-file"

results = []
check = lambda do |name, &operation|
  started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  Dir.mktmpdir("v12-input-") do |temporary|
    # Normalize only this newly owned fixture directory (Darwin /var aliases).
    root = File.realpath(temporary)
    begin
      operation.call(root)
      row = {"case" => name, "status" => "PASS"}
    rescue StandardError => error
      row = {"case" => name, "status" => "FAIL", "error_class" => error.class.name,
             "error" => error.message}
    end
    row["duration_seconds"] = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started
    results << row
  end
end
reject = lambda do |&operation|
  raised = false
  begin
    operation.call
  rescue RuntimeError, SystemCallError
    raised = true
  end
  raise "expected rejection" unless raised
end

check.call("benign-read-control") do |root|
  path = File.join(root, "control.json"); bytes = "{\"synthetic\":true}\n"
  File.binwrite(path, bytes)
  snapshot = V12ControlFile.capture(path)
  raise "bytes differ" unless snapshot.bytes == bytes
end

check.call("empty-regular-file") do |root|
  path = File.join(root, "empty"); File.binwrite(path, "")
  raise "empty read" unless V12ControlFile.capture(path).bytes == ""
end

check.call("fifo-with-no-writer") do |root|
  path = File.join(root, "fifo")
  # File.mkfifo is unavailable on Apple Ruby; the fixed local utility creates
  # only this owned synthetic FIFO. It is not a historical helper.
  raise "mkfifo failed" unless system("/usr/bin/mkfifo", path)
  reject.call { V12ControlFile.capture(path) }
end

check.call("directory-input") { |root| reject.call { V12ControlFile.capture(root) } }

check.call("leaf-symlink") do |root|
  path = File.join(root, "regular"); File.binwrite(path, "fixture")
  link = File.join(root, "link"); File.symlink(path, link)
  reject.call { V12ControlFile.capture(link) }
end

check.call("ancestor-symlink") do |root|
  directory = File.join(root, "real"); Dir.mkdir(directory)
  File.binwrite(File.join(directory, "control"), "fixture")
  File.symlink(directory, File.join(root, "alias"))
  reject.call { V12ControlFile.capture(File.join(root, "alias", "control")) }
end

check.call("oversized-sparse-input") do |root|
  path = File.join(root, "large")
  File.open(path, "wb") { |io| io.truncate(V12ControlFile::MAX_BYTES + 1) }
  reject.call { V12ControlFile.capture(path) }
end

check.call("benign-shorter-scratch-overwrite") do |root|
  path = File.join(root, "control"); File.binwrite(path, "synthetic-long-input")
  snapshot = V12ControlFile.capture(path)
  count = V12ControlFile.overwrite_scratch(snapshot, "short")
  raise "write/readback" unless count == 5 && File.binread(path) == "short"
end

check.call("benign-empty-scratch-overwrite") do |root|
  path = File.join(root, "control"); File.binwrite(path, "fixture")
  snapshot = V12ControlFile.capture(path)
  V12ControlFile.overwrite_scratch(snapshot, "")
  raise "not empty" unless File.size(path) == 0
end

check.call("changed-input-before-overwrite") do |root|
  path = File.join(root, "control"); File.binwrite(path, "initial")
  snapshot = V12ControlFile.capture(path)
  File.binwrite(path, "changed")
  reject.call { V12ControlFile.overwrite_scratch(snapshot, "new") }
  raise "changed input overwritten" unless File.binread(path) == "changed"
end

check.call("replaced-inode-before-overwrite") do |root|
  path = File.join(root, "control"); File.binwrite(path, "initial")
  snapshot = V12ControlFile.capture(path)
  File.rename(path, File.join(root, "original")); File.binwrite(path, "initial")
  reject.call { V12ControlFile.overwrite_scratch(snapshot, "new") }
  raise "replacement overwritten" unless File.binread(path) == "initial"
end

check.call("symlink-substitution-before-overwrite") do |root|
  path = File.join(root, "control"); File.binwrite(path, "initial")
  snapshot = V12ControlFile.capture(path)
  other = File.join(root, "other"); File.binwrite(other, "other")
  File.rename(path, File.join(root, "original")); File.symlink(other, path)
  reject.call { V12ControlFile.overwrite_scratch(snapshot, "new") }
  raise "symlink target changed" unless File.binread(other) == "other"
end

check.call("hardlink-read-but-no-overwrite") do |root|
  path = File.join(root, "control"); File.binwrite(path, "fixture")
  File.link(path, File.join(root, "alias"))
  snapshot = V12ControlFile.capture(path)
  raise "read failed" unless snapshot.bytes == "fixture"
  reject.call { V12ControlFile.overwrite_scratch(snapshot, "new") }
  raise "hardlinked data changed" unless File.binread(path) == "fixture"
end

check.call("busy-scratch-lock-does-not-wait") do |root|
  path = File.join(root, "control"); File.binwrite(path, "fixture")
  snapshot = V12ControlFile.capture(path)
  File.open(path, "r+b") do |lock|
    raise "lock" unless lock.flock(File::LOCK_EX | File::LOCK_NB)
    reject.call { V12ControlFile.overwrite_scratch(snapshot, "new") }
  end
  raise "locked data changed" unless File.binread(path) == "fixture"
end

check.call("snapshot-cannot-silently-repeat-a-write") do |root|
  path = File.join(root, "control"); File.binwrite(path, "initial")
  snapshot = V12ControlFile.capture(path)
  V12ControlFile.overwrite_scratch(snapshot, "first")
  reject.call { V12ControlFile.overwrite_scratch(snapshot, "second") }
  raise "second write entered" unless File.binread(path) == "first"
end

check.call("oversized-output-rejected-before-write") do |root|
  path = File.join(root, "control"); File.binwrite(path, "initial")
  snapshot = V12ControlFile.capture(path)
  reject.call { V12ControlFile.overwrite_scratch(snapshot, "x" * (V12ControlFile::MAX_BYTES + 1)) }
  raise "oversized output mutated input" unless File.binread(path) == "initial"
end

check.call("postcheck-rename-does-not-report-named-write-success") do |root|
  path = File.join(root, "control"); retained = File.join(root, "retained")
  File.binwrite(path, "before")
  snapshot = V12ControlFile.capture(path)
  # Interpose only on this test's held File descriptor, at the write boundary.
  original = V12ControlFile.method(:with_regular)
  V12ControlFile.define_singleton_method(:with_regular) do |name, access, &body|
    original.call(name, access) do |io|
      if access == File::RDWR
        original_write = io.method(:syswrite)
        io.define_singleton_method(:syswrite) do |bytes|
          File.rename(path, retained)
          File.binwrite(path, "replacement")
          original_write.call(bytes)
        end
      end
      body.call(io)
    end
  end
  begin
    reject.call { V12ControlFile.overwrite_scratch(snapshot, "new") }
    raise "replacement changed" unless File.binread(path) == "replacement"
    raise "race not reached" unless File.binread(retained) == "new"
  ensure
    V12ControlFile.define_singleton_method(:with_regular, original)
  end
end

check.call("finite-publisher-digest-control") do |root|
  path = File.join(root, "control"); bytes = "fixture" * 20000
  File.binwrite(path, bytes)
  V12ControlFile.with_regular(path, File::RDONLY) do |io|
    raise "digest" unless V12ControlFile.digest_held(io) == Digest::SHA256.hexdigest(bytes)
  end
end

check.call("finite-publisher-empty-digest") do |root|
  path = File.join(root, "control"); File.binwrite(path, "")
  V12ControlFile.with_regular(path, File::RDONLY) do |io|
    raise "empty digest" unless V12ControlFile.digest_held(io) == Digest::SHA256.hexdigest("")
  end
end

check.call("publisher-digest-preserves-files-larger-than-scratch-cap") do |root|
  path = File.join(root, "large")
  File.open(path, "wb") { |io| io.truncate(V12ControlFile::MAX_BYTES + 1) }
  expected = Digest::SHA256.file(path).hexdigest
  V12ControlFile.with_regular(path, File::RDONLY) do |io|
    raise "large digest" unless V12ControlFile.digest_held(io) == expected
  end
end

check.call("publisher-digest-rejects-growth-without-reading-until-eof") do |root|
  path = File.join(root, "control"); File.binwrite(path, "fixture" * 20000)
  V12ControlFile.with_regular(path, File::RDONLY) do |io|
    original_read = io.method(:read)
    changed = false
    io.define_singleton_method(:read) do |length|
      result = original_read.call(length)
      unless changed
        changed = true
        File.open(path, "ab") { |writer| writer.write("growth") }
      end
      result
    end
    reject.call { V12ControlFile.digest_held(io) }
    raise "growth boundary not exercised" unless changed
  end
end

record = {
  "scope" => "New V12 regular-file intake and guarded scratch overwrite on owned synthetic files only",
  "checks" => results.length, "passed" => results.count { |r| r["status"] == "PASS" },
  "failed" => results.count { |r| r["status"] == "FAIL" },
  "original_transforms_or_publisher_executed" => false,
  "results" => results,
}
STDOUT.write(JSON.pretty_generate(record) + "\n")
exit(record["failed"].zero? ? 0 : 1)
