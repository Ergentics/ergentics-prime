#!/usr/bin/ruby
# Offline development build helper. Never invokes a resulting guest/host image.
require "json"
require "digest"
require "time"

abort "usage: ruby build.rb EXISTING_EMPTY_RESULT_DIRECTORY" unless ARGV.length == 1
root = File.realpath(ARGV.fetch(0))
st = File.lstat(root)
abort "private empty output directory required" unless st.directory? && st.uid == Process.uid && (st.mode & 0777) == 0700 && Dir.children(root).empty?
source = File.realpath(__dir__)
toolchain = "/Users/ergentics/Developer/ErgenticsToolchains/rust-1.98.0-guest-bootstrap"
prefix = "#{toolchain}/prefix"
rustc = "#{prefix}/bin/rustc"
llvm = "#{prefix}/lib/rustlib/aarch64-apple-darwin/bin"
names = %w[kernel.rs entry.S linker.ld inspect.rb inspector-tests.rb build.rb]

def retain(path, bytes)
  File.open(path, File::WRONLY | File::CREAT | File::EXCL, 0600) do |f|
    f.write(bytes)
    f.flush
    f.fsync
  end
end

def record(path, value)
  retain(path, JSON.pretty_generate(value) + "\n")
end

def file_identity(path)
  {"bytes" => File.size(path), "sha256" => Digest::SHA256.file(path).hexdigest}
end

def command(root, label, cwd, environment, argv)
  started = Time.now.utc.iso8601(9)
  tick = Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond)
  record("#{root}/#{label}.invocation.json", {"argv" => argv, "cwd" => cwd, "replacement_environment" => environment,
    "stdin" => "/dev/null", "started_utc" => started, "clock" => "Ruby CLOCK_MONOTONIC normalized integer nanoseconds, not raw hardware ticks or energy"})
  out = File.open("#{root}/#{label}.stdout", File::WRONLY | File::CREAT | File::EXCL, 0600)
  err = File.open("#{root}/#{label}.stderr", File::WRONLY | File::CREAT | File::EXCL, 0600)
  pid = Process.spawn(environment, *argv, unsetenv_others: true, chdir: cwd, in: File::NULL, out: out, err: err, close_others: true)
  _, status = Process.wait2(pid)
  out.flush; out.fsync; err.flush; err.fsync
  out.close; err.close
  result = {"pid" => pid, "normal_exit" => status.exited?, "exit_status" => status.exitstatus,
    "term_signal" => status.termsig, "ended_utc" => Time.now.utc.iso8601(9),
    "elapsed_monotonic_ns" => Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond) - tick,
    "stdout" => file_identity("#{root}/#{label}.stdout"), "stderr" => file_identity("#{root}/#{label}.stderr")}
  record("#{root}/#{label}.result.json", result)
  raise "#{label} failed: #{result.inspect}" unless status.exited? && status.exitstatus == 0
  result
end

begin
  # Snapshot every source once, then use these identical bytes for A and B.
  snapshots = names.to_h { |name| [name, File.binread("#{source}/#{name}")] }
  record("#{root}/source-identities.json", snapshots.transform_values { |b| {"bytes" => b.bytesize, "sha256" => Digest::SHA256.hexdigest(b)} })
  project = File.realpath("../..", source)
  baseline_names = %w[Guest/doorbell.S Sources/HypervisorGuest.c Sources/HypervisorGuest.h ErgenticsProvenance.xcodeproj/project.pbxproj]
  baseline = baseline_names.to_h { |name| [name, file_identity("#{project}/#{name}")] }
  record("#{root}/baseline-identities.json", baseline)
  retain("#{root}/build-contract.json", File.binread("#{project}/Control/rust-guest-bootstrap-build.v1.json"))
  record("#{root}/scope.json", {"schema" => "ergentics.rust-bootstrap.build-observation.v1", "guest_executions" => 0,
    "resulting_host_binary_executions" => 0, "production_files_modified" => false, "gate_e" => "ABSTAIN", "authority_vector" => "00000000"})
  identities = {}
  [rustc, "#{llvm}/rust-lld", "#{llvm}/llvm-objdump", "#{llvm}/llvm-readobj", "#{llvm}/llvm-objcopy",
    "#{llvm}/../lib/libLLVM.dylib", "/usr/bin/ruby"].each { |p| identities[p] = file_identity(p) }
  Dir.glob("#{prefix}/lib/librustc_driver-*.dylib").sort.each { |p| identities[p] = file_identity(p) }
  Dir.glob("#{prefix}/lib/rustlib/aarch64-unknown-none-softfloat/lib/*").sort.each { |p| identities[p] = file_identity(p) if File.file?(p) }
  record("#{root}/toolchain-identities.json", identities)
  retain("#{root}/toolchain-setup-record.json", File.binread("#{toolchain}/setup-record.json"))
  retain("#{root}/release-manifest.toml", File.binread("#{toolchain}/downloads/channel-rust-1.98.0.toml"))
  retain("#{root}/release-manifest.toml.sha256", File.binread("#{toolchain}/downloads/channel-rust-1.98.0.toml.sha256"))
  base_env = {"PATH" => "/usr/bin:/bin", "LANG" => "C", "LC_ALL" => "C", "TZ" => "UTC"}
  command(root, "rustc-version", root, base_env, [rustc, "--version", "--verbose"])
  command(root, "lld-version", root, base_env, ["#{llvm}/rust-lld", "-flavor", "gnu", "--version"])
  command(root, "llvm-version", root, base_env, ["#{llvm}/llvm-objdump", "--version"])

  %w[A B].each do |side|
    dir = "#{root}/build-#{side}"
    Dir.mkdir(dir, 0700)
    Dir.mkdir("#{dir}/tmp", 0700)
    snapshots.each { |name, bytes| retain("#{dir}/#{name}", bytes) }
    env = base_env.merge("TMPDIR" => "#{dir}/tmp")
    arguments = [rustc, "kernel.rs", "--edition=2024", "--crate-name", "ergentics_guest_bootstrap", "--crate-type=bin",
      "--target", "aarch64-unknown-none-softfloat", "--sysroot", prefix, "--emit=link", "-o", "image.elf",
      "-Dwarnings", "-Copt-level=2", "-Cpanic=abort", "-Ccodegen-units=1", "-Cdebuginfo=0",
      "-Cmetadata=ergentics_guest_bootstrap_v1", "-Crelocation-model=static", "-Ctarget-cpu=generic",
      "-Cforce-frame-pointers=yes", "-Cforce-unwind-tables=no", "-Clinker=#{llvm}/rust-lld",
      "-Clink-arg=-Tlinker.ld", "-Clink-arg=--build-id=none", "-Clink-arg=--fatal-warnings",
      "-Clink-arg=-Map=image.map", "--remap-path-prefix=#{dir}=/ergentics/rust-bootstrap"]
    command(dir, "compile", dir, env, arguments)
    command(dir, "disassembly", dir, env, ["#{llvm}/llvm-objdump", "--disassemble", "--print-imm-hex", "image.elf"])
    command(dir, "elf-facts", dir, env, ["#{llvm}/llvm-readobj", "--file-headers", "--program-headers", "--sections", "--symbols", "--relocations", "--dynamic-table", "image.elf"])
    command(dir, "independent-inspection", dir, env, ["/usr/bin/ruby", "--disable-gems", "inspect.rb", "image.elf", "."])
    command(dir, "llvm-extraction", dir, env, ["#{llvm}/llvm-objcopy", "--only-section=.text", "-O", "binary", "image.elf", "llvm-image.bin"])
    raise "independent extraction disagrees" unless File.binread("#{dir}/image.bin") == File.binread("#{dir}/llvm-image.bin")
  end
  command(root, "inspector-tests", "#{root}/build-A", base_env, ["/usr/bin/ruby", "--disable-gems", "inspector-tests.rb"])
  comparisons = {}
  %w[image.elf image.bin llvm-image.bin image.map disassembly.stdout elf-facts.stdout inspection.json].each do |name|
    a = File.binread("#{root}/build-A/#{name}")
    b = File.binread("#{root}/build-B/#{name}")
    comparisons[name] = {"equal" => a == b, "A" => file_identity("#{root}/build-A/#{name}"), "B" => file_identity("#{root}/build-B/#{name}")}
  end
  # Map files may name rustc's independently generated temporary object files.
  critical = %w[image.elf image.bin llvm-image.bin disassembly.stdout elf-facts.stdout inspection.json]
  raise "A/B critical comparison failed" unless critical.all? { |name| comparisons.fetch(name).fetch("equal") }
  record("#{root}/comparison.json", comparisons)
  source_unchanged = snapshots.all? { |name, bytes| File.binread("#{source}/#{name}") == bytes }
  raise "source changed during build" unless source_unchanged
  raise "baseline changed during build" unless baseline.all? { |name, identity| file_identity("#{project}/#{name}") == identity }
  raise "toolchain changed during build" unless identities.all? { |path, identity| file_identity(path) == identity }
  record("#{root}/result.json", {"result" => "BUILD_AND_STATIC_LAYOUT_PASS_PENDING_INSTRUCTION_REVIEW", "source_unchanged" => source_unchanged,
    "guest_executions" => 0, "resulting_host_binary_executions" => 0, "gate_e" => "ABSTAIN", "authority_vector" => "00000000"})
  puts "BUILD_AND_STATIC_LAYOUT_PASS_PENDING_INSTRUCTION_REVIEW #{root}"
rescue StandardError => error
  path = "#{root}/failure.json"
  record(path, {"result" => "BUILD_OR_INSPECTION_FAILED", "error_class" => error.class.name, "error" => error.message,
    "guest_executions" => 0, "ended_utc" => Time.now.utc.iso8601(9)}) unless File.exist?(path)
  warn error.message
  exit 1
end
