#!/usr/bin/ruby
# Local inference process control; retained from the previously exercised exact-reap runner.
require 'json'
require 'digest'
require 'fileutils'
require 'fiddle'
require 'time'

module PrimeExperimentProcess
  REPO = File.expand_path(__dir__).freeze
  MAX_LOG = 32 * 1024 * 1024
  RUN_SECONDS = 120.0
  METHODS = {}.freeze

  def self.write_json(path, value)
    File.open(path, File::WRONLY | File::CREAT | File::EXCL, 0600) do |f|
      f.write(JSON.pretty_generate(value) + "\n"); f.flush; f.fsync
    end
  end

  class Native
    def initialize
      raise 'Darwin LP64 required' unless RUBY_PLATFORM.include?('darwin') && Fiddle::SIZEOF_VOIDP == 8
      @waitid = Fiddle::Function.new(Fiddle::Handle::DEFAULT['waitid'],
        [Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
      @list = Fiddle::Function.new(Fiddle::Handle::DEFAULT['proc_listpids'],
        [Fiddle::TYPE_INT, Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT], Fiddle::TYPE_INT)
    end
    def dead?(pid)
      buffer = Fiddle::Pointer["\0" * 128]
      rc = @waitid.call(1, pid, buffer, 1 | 4 | 32)
      return false if rc == -1 && Fiddle.last_error == Errno::EINTR::Errno
      raise SystemCallError.new('waitid', Fiddle.last_error) if rc == -1
      observed = buffer[12, 4].unpack1('i')
      raise 'wrong waitid PID' unless [0, pid].include?(observed)
      observed == pid && [1, 2, 3].include?(buffer[8, 4].unpack1('i'))
    end
    def members(pid)
      buffer = Fiddle::Pointer["\0" * 262_144]
      count = @list.call(2, pid, buffer, 262_144)
      raise 'owned group census failed or truncated' unless count >= 0 && count < 262_144 && count % 4 == 0
      buffer[0, count].unpack('i*').select { |v| v > 0 }.uniq.sort
    end
  end

  def self.run(directory, kind)
    specification = JSON.parse(File.read(File.join(directory, 'specification.json')))
    logical_kind = kind.sub(/[0-9]+\z/, '')
    raise 'product' unless %w[controller].include?(logical_kind)
    phase = 'inference'
    product = 'PrimeNativeDecoderCurrentLocal300MExecution'
    output = File.join(directory, kind)
    Dir.mkdir(output, 0700)
    env = specification.fetch('environment')
    command = specification.fetch('argv')
    write_json(File.join(output, 'invocation.json'), {
      runner_sha256: Digest::SHA256.file(__FILE__).hexdigest, argv: command, replacement_environment: env, cwd: REPO, stdin: 'owned EOF pipe',
      timeout_seconds: RUN_SECONDS, stream_limit_bytes: MAX_LOG,
      test_methods: phase == 'test' ? METHODS : {},
      cleanup_scope: 'Owned process group, while leader remains unreaped. No detached-session containment claim.'})
    native = Native.new
    stdout_r, stdout_w = IO.pipe; stderr_r, stderr_w = IO.pipe; stdin_r, stdin_w = IO.pipe
    captures = {stdout_r => ['stdout', File.open(File.join(output, 'stdout.bin'), 'wx', 0600), 0, false],
                stderr_r => ['stderr', File.open(File.join(output, 'stderr.bin'), 'wx', 0600), 0, false]}
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    start_utc = Time.now.utc.iso8601(6)
    cancellation = nil
    old_traps = %w[INT TERM HUP].to_h { |name| [name, Signal.trap(name) { cancellation ||= name }] }
    pid = nil; status = nil; wait_pid = nil; reason = nil; runner_error = nil; signals = []; cleanup_at = nil; dead_at = nil
    begin
      pid = Process.spawn(env, *command, unsetenv_others: true, pgroup: true, chdir: REPO,
                          in: stdin_r, out: stdout_w, err: stderr_w, close_others: true)
      stdin_r.close; stdin_w.close; stdout_w.close; stderr_w.close
      signal_group = lambda do |signal|
        errno = 0
        begin Process.kill(signal, -pid); rescue Errno::ESRCH; errno = Errno::ESRCH::Errno; end
        signals << {signal: signal, target: -pid, errno: errno,
                    elapsed_seconds: Process.clock_gettime(Process::CLOCK_MONOTONIC) - start,
                    leader_unreaped: status.nil?}
      end
      loop do
        now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        reason ||= 'cancelled_' + cancellation if cancellation
        reason ||= 'deadline' if now - start >= RUN_SECONDS
        ready = IO.select(captures.keys.reject(&:closed?), nil, nil, 0.05)&.first || []
        ready.each do |io|
          value = captures.fetch(io)
          begin
            data = io.read_nonblock(65_536)
            prior = value[2]; value[2] += data.bytesize
            keep = [MAX_LOG - prior, data.bytesize].min
            value[1].write(data.byteslice(0, keep)) if keep > 0
            reason ||= value[0] + '_overflow' if value[2] > MAX_LOG
          rescue IO::WaitReadable
          rescue EOFError
            value[3] = true; io.close
          end
        end
        dead = native.dead?(pid)
        dead_at ||= now if dead
        members = native.members(pid)
        if dead && now - dead_at >= 0.5 && (members - [pid]).any?
          reason ||= 'descendants_after_leader_death'
        end
        reason ||= 'stream_not_eof_after_death' if dead && now - dead_at >= 2 && captures.values.any? { |v| !v[3] }
        if reason && !cleanup_at
          cleanup_at = now; signal_group.call('TERM')
        end
        signal_group.call('KILL') if cleanup_at && now - cleanup_at >= 0.25 && signals.none? { |s| s[:signal] == 'KILL' }
        if dead && (members - [pid]).empty? && (captures.values.all? { |v| v[3] } || (cleanup_at && now - cleanup_at >= 2))
          wait_pid, status = Process.waitpid2(pid)
          raise 'wrong exact reap PID' unless wait_pid == pid
          break
        end
        if cleanup_at && now - cleanup_at >= 10
          # Never abandon an unreaped child. Retain a visible nonterminal marker,
          # issue KILL while identity is still anchored, then perform exact reap.
          write_json(File.join(output, 'cleanup-stall.json'), {pid: pid, group: pid, leader_unreaped: true})
          signal_group.call('KILL')
          wait_pid, status = Process.waitpid2(pid)
          raise 'wrong exact reap PID' unless wait_pid == pid
          reason ||= 'cleanup_stall'
          break
        end
      end
    rescue Exception => error
      reason ||= 'runner_error_' + error.class.name
      runner_error = {class: error.class.name, message: error.message, backtrace: error.backtrace&.first(8)}
      if pid && !status
        begin Process.kill('KILL', -pid); rescue Errno::ESRCH; end
        # No timeout escape or final receipt is possible before this exact wait.
        wait_pid, status = Process.waitpid2(pid)
        raise 'wrong exact reap PID' unless wait_pid == pid
      end
      raise if !pid
    ensure
      [stdin_r, stdin_w, stdout_w, stderr_w, stdout_r, stderr_r].each { |io| io.close unless io.closed? }
      captures.each_value { |v| v[1].flush; v[1].fsync; v[1].close }
      old_traps.each { |name, handler| Signal.trap(name, handler) }
    end
    group = native.members(pid)
    result = {started_at_utc: start_utc, elapsed_seconds: Process.clock_gettime(Process::CLOCK_MONOTONIC) - start,
      pid: pid, requested_wait_pid: pid, returned_wait_pid: wait_pid, exact_reap_count: status ? 1 : 0,
      raw_wait_status: status.to_i, exit_status: status.exitstatus, termination_signal: status.termsig,
      reason: reason, runner_error: runner_error, signals: signals, process_group_members_after_reap: group,
      streams: captures.values.to_h { |v| [v[0], {total_bytes: v[2], eof: v[3],
        captured_bytes: File.size(File.join(output, v[0] + '.bin')),
        sha256: Digest::SHA256.file(File.join(output, v[0] + '.bin')).hexdigest}] }}
    result[:passed] = status.success? && reason.nil? && group.empty? && captures.values.all? { |v| v[3] }
    if phase == 'test'
      # Require every exact selected XCTest method once; a zero-match SwiftPM
      # exit cannot count as successful validation.
      text = File.binread(File.join(output, 'stdout.bin')).force_encoding(Encoding::UTF_8).scrub
      text += File.binread(File.join(output, 'stderr.bin')).force_encoding(Encoding::UTF_8).scrub
      counts = METHODS.flat_map do |klass, names|
        names.map do |name|
          pattern = /^Test Case .*#{Regexp.escape(klass)}[ .\/]#{Regexp.escape(name)}.* passed \(/
          [klass + '/' + name, text.lines.count { |line| pattern.match?(line) }]
        end
      end.to_h
      result[:selected_method_pass_counts] = counts
      result[:passed] &&= counts.values.all? { |count| count == 1 }
    end
    write_json(File.join(output, 'result.json'), result)
    puts JSON.generate(result)
    result[:passed] ? 0 : 1
  end
end

if $PROGRAM_NAME == __FILE__
  directory = File.expand_path(ARGV.fetch(0))
  exit PrimeExperimentProcess.run(directory, 'controller')
end
