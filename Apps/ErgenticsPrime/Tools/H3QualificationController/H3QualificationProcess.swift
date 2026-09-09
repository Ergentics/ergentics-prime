#if EPR_H3_QUALIFICATION
import Foundation
import Darwin

struct H3QualificationContinuousClock {
    let numerator: UInt32
    let denominator: UInt32
    init() throws {
        var timebase = mach_timebase_info_data_t()
        guard mach_timebase_info(&timebase) == KERN_SUCCESS, timebase.numer > 0, timebase.denom > 0 else {
            throw H3QualificationControllerFailure.rejected("timebase")
        }
        numerator = timebase.numer; denominator = timebase.denom
    }
    func deadline(start: UInt64, seconds: UInt64) throws -> UInt64 {
        let (nanos, first) = seconds.multipliedReportingOverflow(by: 1_000_000_000)
        let (scaled, second) = nanos.multipliedReportingOverflow(by: UInt64(denominator))
        let (rounded, third) = scaled.addingReportingOverflow(UInt64(numerator) - 1)
        let delta = rounded / UInt64(numerator)
        let (result, fourth) = start.addingReportingOverflow(delta)
        guard start > 0, delta > 0, !first, !second, !third, !fourth else {
            throw H3QualificationControllerFailure.rejected("deadline arithmetic")
        }
        return result
    }
}

struct H3QualificationProcessResult {
    let spawnReturn: Int32
    let pid: Int32
    var waitStatus: Int32?
    let clock: H3QualificationContinuousClock
    let spawnTick: UInt64
    let gateDeadline: UInt64
    let operationDeadline: UInt64
    let killDeadline: UInt64
    let terminalHorizon: UInt64
    var reapTick: UInt64 = 0
    var gateAttemptTick: UInt64 = 0
    var gateReturnTick: UInt64 = 0
    var cancelTick: UInt64 = 0
    var killTick: UInt64 = 0
    var gateWrites = 0
    var gateReturn: Int32 = .min
    var gateErrno: Int32 = 0
    var cancelWrites = 0
    var cancelReturn: Int32 = .min
    var cancelErrno: Int32 = 0
    var killAttempted = false
    var killReturn: Int32 = .min
    var killErrno: Int32 = 0
    var lastWaitReturn: Int32 = 0
    var lastWaitErrno: Int32 = 0
    var stderrBytes = Data()
    var stderrTotal = 0
    var stderrEOF = false
    var stderrOverflow = false
    var observationFailure = false
    var dynamicClaim: H3QValue?
    var dynamicPath: String?
    var heldBeforeGate: H3QualificationFileSnapshot?
    var namedBeforeGate: H3QualificationFileSnapshot?

    func deadlines(terminal: UInt64) -> H3QValue {
        .object([
            "cancel_tick": .string(String(cancelTick)), "gate_attempt_tick": .string(String(gateAttemptTick)),
            "gate_deadline_tick": .string(String(gateDeadline)), "gate_return_tick": .string(String(gateReturnTick)),
            "kill_attempt_tick": .string(String(killTick)), "kill_deadline_tick": .string(String(killDeadline)),
            "operation_deadline_tick": .string(String(operationDeadline)), "reap_tick": .string(String(reapTick)),
            "spawn_tick": .string(String(spawnTick)), "terminal_horizon_tick": .string(String(terminalHorizon)),
            "terminal_tick": .string(String(terminal)), "timebase_denominator": .integer(Int64(clock.denominator)),
            "timebase_numerator": .integer(Int64(clock.numerator))
        ])
    }
}

final class H3QualificationApplicationProcess {
    private let application: H3QualificationExecutable
    private let expectedClaim: H3QValue
    private let stdoutWriter: H3QualificationDescriptor
    private let gateRead: H3QualificationDescriptor
    private let gateWrite: H3QualificationDescriptor
    private let cancelRead: H3QualificationDescriptor
    private let cancelWrite: H3QualificationDescriptor
    private let stderrRead: H3QualificationDescriptor
    private let stderrWrite: H3QualificationDescriptor
    private let stdin: H3QualificationDescriptor
    private var consumed = false

    init(application: H3QualificationExecutable, expectedClaim: H3QValue,
         stdoutWriter: H3QualificationDescriptor) throws {
        self.application = application; self.expectedClaim = expectedClaim; self.stdoutWriter = stdoutWriter
        var action = sigaction()
        action.__sigaction_u.__sa_handler = SIG_IGN
        sigemptyset(&action.sa_mask)
        guard sigaction(SIGPIPE, &action, nil) == 0 else {
            throw H3QualificationControllerFailure.system("ignore controller SIGPIPE", errno)
        }
        (gateRead, gateWrite) = try Self.pipe()
        (cancelRead, cancelWrite) = try Self.pipe()
        (stderrRead, stderrWrite) = try Self.pipe()
        stdin = try H3QualificationDescriptor(Darwin.open("/dev/null", O_RDONLY | O_CLOEXEC))
        for descriptor in [stdin, stdoutWriter, gateRead, gateWrite, cancelRead, cancelWrite, stderrRead, stderrWrite] {
            try descriptor.relocateAboveControlSlots()
        }
    }

    private static func pipe() throws -> (H3QualificationDescriptor, H3QualificationDescriptor) {
        var descriptors: [Int32] = [-1, -1]
        guard Darwin.pipe(&descriptors) == 0 else { throw H3QualificationControllerFailure.system("pipe", errno) }
        let read = try H3QualificationDescriptor(descriptors[0]), write = try H3QualificationDescriptor(descriptors[1])
        for descriptor in [read, write] {
            let status = Darwin.fcntl(descriptor.value, F_GETFL)
            guard status >= 0, Darwin.fcntl(descriptor.value, F_SETFL, status | O_NONBLOCK) == 0,
                  Darwin.fcntl(descriptor.value, F_SETFD, FD_CLOEXEC) == 0 else {
                throw H3QualificationControllerFailure.system("pipe flags", errno)
            }
        }
        return (read, write)
    }

    func run(argv: [String], gate: Data, cancellation: Data) throws -> H3QualificationProcessResult {
        guard !consumed, argv.count == 2, gate.count == 41, cancellation.count == 40 else {
            throw H3QualificationControllerFailure.rejected("spawn consumption")
        }
        consumed = true
        let clock = try H3QualificationContinuousClock()
        var actions: posix_spawn_file_actions_t?
        var attributes: posix_spawnattr_t?
        guard posix_spawn_file_actions_init(&actions) == 0 else { throw H3QualificationControllerFailure.rejected("spawn file actions") }
        defer { posix_spawn_file_actions_destroy(&actions) }
        guard posix_spawnattr_init(&attributes) == 0 else { throw H3QualificationControllerFailure.rejected("spawn attributes") }
        defer { posix_spawnattr_destroy(&attributes) }
        let cwd = try H3QualificationStorage.openAbsolute("/private/var/empty", directory: true)
        let cwdIdentity = try H3QualificationStorage.snapshot(cwd.value)
        guard cwdIdentity.mode & UInt16(S_IFMT) == UInt16(S_IFDIR), cwdIdentity.owner == 0,
              cwdIdentity.mode & 0o022 == 0 else {
            throw H3QualificationControllerFailure.rejected("spawn cwd policy")
        }
        try cwd.relocateAboveControlSlots()
        func checked(_ result: Int32) throws {
            guard result == 0 else { throw H3QualificationControllerFailure.system("spawn setup", result) }
        }
        for (source, target) in [(stdin, Int32(0)), (stdoutWriter, 1), (stderrWrite, 2), (gateRead, 3), (cancelRead, 4)] {
            try checked(posix_spawn_file_actions_adddup2(&actions, source.value, target))
        }
        try checked(posix_spawn_file_actions_addfchdir(&actions, cwd.value))
        for descriptor in [stdin, stdoutWriter, gateRead, gateWrite, cancelRead, cancelWrite, stderrRead, stderrWrite, cwd] {
            try checked(posix_spawn_file_actions_addclose(&actions, descriptor.value))
        }
        var empty = sigset_t(), defaults = sigset_t()
        sigemptyset(&empty); sigfillset(&defaults); sigdelset(&defaults, SIGKILL); sigdelset(&defaults, SIGSTOP)
        try checked(posix_spawnattr_setsigmask(&attributes, &empty))
        try checked(posix_spawnattr_setsigdefault(&attributes, &defaults))
        let flags = Int16(POSIX_SPAWN_CLOEXEC_DEFAULT | POSIX_SPAWN_SETSIGMASK | POSIX_SPAWN_SETSIGDEF)
        try checked(posix_spawnattr_setflags(&attributes, flags))
        let strings = [application.path] + argv
        var arguments = strings.map { strdup($0) }
        guard arguments.allSatisfy({ $0 != nil }) else {
            for argument in arguments { free(argument) }
            throw H3QualificationControllerFailure.rejected("argv allocation")
        }
        arguments.append(nil)
        defer { for argument in arguments { free(argument) } }
        var environment: [UnsafeMutablePointer<CChar>?] = [nil]
        _ = try application.observeNamed(requireHash: false)
        guard try H3QualificationStorage.snapshot(cwd.value) == cwdIdentity else {
            throw H3QualificationControllerFailure.rejected("spawn cwd changed")
        }
        // Compute the deltas before sampling the spawn anchor. The final checked
        // additions are pure and introduce no intervening filesystem/Security effect.
        let gateDelta = try clock.deadline(start: 1, seconds: 5) - 1
        let operationDelta = try clock.deadline(start: 1, seconds: 10) - 1
        let killDelta = try clock.deadline(start: 1, seconds: 15) - 1
        let horizonDelta = try clock.deadline(start: 1, seconds: 20) - 1
        let spawnTick = mach_continuous_time()
        guard spawnTick > 0, spawnTick <= UInt64.max - horizonDelta else {
            throw H3QualificationControllerFailure.rejected("spawn clock")
        }
        var pid: pid_t = 0
        let spawnReturn = posix_spawn(&pid, application.path, &actions, &attributes, &arguments, &environment)
        var result = H3QualificationProcessResult(spawnReturn: spawnReturn, pid: spawnReturn == 0 ? pid : 0,
            waitStatus: nil, clock: clock, spawnTick: spawnTick, gateDeadline: spawnTick + gateDelta,
            operationDeadline: spawnTick + operationDelta, killDeadline: spawnTick + killDelta,
            terminalHorizon: spawnTick + horizonDelta)
        if spawnReturn != 0 {
            try stdin.close(); try gateRead.close(); try cancelRead.close(); try stderrWrite.close(); try cwd.close()
            try gateWrite.close(); try cancelWrite.close(); try stderrRead.close()
            result.stderrEOF = true
            return result // Caller still owns the empty stdout creator and its sync duty.
        }
        // From this point the parent owns no write-capable stdout descriptor.
        // No close error can unwind out of a successfully spawned child's owner.
        for descriptor in [stdoutWriter, stdin, gateRead, cancelRead, stderrWrite, cwd] {
            do { try descriptor.close() } catch { result.observationFailure = true }
        }
        guard pid > 0 else {
            result.observationFailure = true
            return result
        }
        return supervise(result: result, gate: gate, cancellation: cancellation)
    }

    /// All calls after successful spawn remain inside this finite owner. Errors become
    /// retained observations; they cannot unwind out while a known child needs containment.
    private func supervise(result initial: H3QualificationProcessResult, gate: Data,
                           cancellation: Data) -> H3QualificationProcessResult {
        var result = initial
        var policy = H3QualificationControllerPolicy()
        var terminalStatus: Int32?
        var stderrCalls = 0, stderrInterruptions = 0
        var previousTick = result.spawnTick
        var clockFailed = false
        // Readable stderr must not consume the entire wait budget before the
        // later containment deadlines. Ordinary observations are clock-cadenced;
        // each gate/cancel/kill eligibility check still performs its own fresh wait.
        let waitIntervalTicks = (UInt64(10_000_000) * UInt64(result.clock.denominator) +
            UInt64(result.clock.numerator) - 1) / UInt64(result.clock.numerator)
        var nextOrdinaryWaitTick = result.spawnTick

        func sample() -> UInt64 {
            let tick = mach_continuous_time()
            if tick < previousTick || tick == 0 { result.observationFailure = true; clockFailed = true }
            previousTick = max(previousTick, tick)
            return tick
        }
        func wait() -> H3QualificationControllerPolicy.WaitObservation {
            while policy.canObserveWait {
                let before = sample()
                guard !clockFailed, before <= result.terminalHorizon else { return .failed(ETIMEDOUT) }
                var status: Int32 = 0
                let returned = waitpid(result.pid, &status, WNOHANG)
                let error = returned < 0 ? errno : 0
                let observedTick = sample()
                result.lastWaitReturn = returned; result.lastWaitErrno = error
                if returned == 0 {
                    let (next, overflow) = observedTick.addingReportingOverflow(waitIntervalTicks)
                    if overflow { clockFailed = true; result.observationFailure = true }
                    else { nextOrdinaryWaitTick = next }
                }
                let observation: H3QualificationControllerPolicy.WaitObservation
                if returned == result.pid {
                    // An exact PID alone does not prove a terminal reap. Keep an
                    // unexpected raw status uncertain; it is not a live witness
                    // and grants no gate, cancellation, or signal eligibility.
                    observation = H3QualificationTerminalWaitStatus(rawValue: status) != nil ?
                        .reaped(status) : .terminalUncertain(status)
                } else if returned == 0 { observation = .live }
                else if returned == -1 && error == EINTR { observation = .interrupted }
                else { observation = .failed(error == 0 ? ECHILD : error) }
                guard policy.observe(observation) else {
                    result.observationFailure = true
                    if case .terminalUncertain = observation { return observation }
                    return .failed(EOVERFLOW)
                }
                if case .reaped(let status) = observation {
                    terminalStatus = status
                    result.reapTick = observedTick
                }
                if observation == .interrupted {
                    guard observedTick < result.terminalHorizon else { return .failed(ETIMEDOUT) }
                    continue
                }
                if case .failed = observation { result.observationFailure = true }
                return observation
            }
            result.observationFailure = true; return .failed(EOVERFLOW)
        }
        func closeObserved(_ descriptor: H3QualificationDescriptor) {
            if descriptor.value >= 0 {
                do { try descriptor.close() } catch { result.observationFailure = true }
            }
        }
        func drain() {
            guard stderrRead.value >= 0, !result.stderrEOF else { return }
            var buffer = [UInt8](repeating: 0, count: 4096)
            // Each positive read advances at least one byte; EAGAIN returns to the
            // bounded poll loop and EINTR consumes the shared 16-observation allowance.
            while stderrCalls < 1048592 && result.stderrTotal < 1048576 && stderrInterruptions < 16 {
                guard sample() <= result.terminalHorizon else { return }
                stderrCalls += 1
                let requested = min(4096, 1048576 - result.stderrTotal)
                let amount = Darwin.read(stderrRead.value, &buffer, requested)
                let error = amount < 0 ? errno : 0
                if amount == 0 { result.stderrEOF = true; closeObserved(stderrRead); return }
                if amount < 0 && error == EAGAIN { return }
                if amount < 0 && error == EINTR && stderrInterruptions < 16 {
                    stderrInterruptions += 1; continue
                }
                guard amount > 0, amount <= requested else {
                    result.observationFailure = true; closeObserved(stderrRead); return
                }
                result.stderrTotal += amount
                let retained = min(amount, 65536 - result.stderrBytes.count)
                result.stderrBytes.append(contentsOf: buffer[..<retained])
                if result.stderrTotal > 65536 { result.stderrOverflow = true }
            }
            if result.stderrTotal >= 1048576 { result.stderrOverflow = true }
            result.observationFailure = true; closeObserved(stderrRead)
        }
        do {
            let start = sample()
            guard !result.observationFailure, !clockFailed, start <= result.gateDeadline else {
                throw H3QualificationControllerFailure.rejected("gate deadline or pre-entry observation")
            }
            let dynamic = try H3QualificationSigning.dynamicApplication(pid: result.pid, executable: application)
            guard try H3QualificationPathIdentityPolicy.dynamicCode(dynamic.claim, expected: expectedClaim) else { throw H3QualificationControllerFailure.rejected("dynamic identity") }
            let named = try application.observeNamed(requireHash: false)
            let held = try H3QualificationStorage.snapshot(application.descriptor.value)
            guard H3QualificationPathIdentityPolicy.preGate(original: application.original, held: held, named: named,
                processPath: dynamic.path, executablePath: application.path) else { throw H3QualificationControllerFailure.rejected("gate held identity") }
            result.dynamicClaim = dynamic.claim; result.dynamicPath = dynamic.path
            result.heldBeforeGate = held; result.namedBeforeGate = named
            let live = wait()
            let tick = sample()
            if policy.claimGate(immediateWait: live, beforeDeadline: !clockFailed && tick <= result.gateDeadline) {
                result.gateWrites = 1; result.gateAttemptTick = tick
                let count = gate.withUnsafeBytes { Darwin.write(gateWrite.value, $0.baseAddress!, gate.count) }
                result.gateErrno = count < 0 ? errno : 0
                result.gateReturnTick = sample(); result.gateReturn = Int32(count)
            } else { result.observationFailure = true }
        } catch { result.observationFailure = true }
        closeObserved(gateWrite)

        // The continuous terminal horizon bounds this observation loop even after
        // wait/read quotas are exhausted; an exhausted quota never exits early and
        // silently abandons the later cancellation/kill eligibility deadlines.
        while !clockFailed {
            let tick = sample()
            if tick >= result.terminalHorizon { break }
            let observation: H3QualificationControllerPolicy.WaitObservation?
            if terminalStatus == nil && tick >= nextOrdinaryWaitTick { observation = wait() }
            else { observation = nil }
            drain()
            if terminalStatus != nil && result.stderrEOF { break }
            if terminalStatus == nil && tick >= result.operationDeadline && !policy.cancellationAttempted {
                let immediate = wait()
                let cancelTick = sample()
                if policy.claimCancellation(immediateWait: immediate,
                                            eligible: !clockFailed && cancelTick >= result.operationDeadline && cancelTick <= result.terminalHorizon) {
                    result.cancelWrites = 1; result.cancelTick = cancelTick
                    let count = cancellation.withUnsafeBytes { Darwin.write(cancelWrite.value, $0.baseAddress!, cancellation.count) }
                    result.cancelErrno = count < 0 ? errno : 0; result.cancelReturn = Int32(count)
                    closeObserved(cancelWrite)
                }
            }
            if terminalStatus == nil && tick >= result.killDeadline && !policy.killAttempted {
                let immediate = wait()
                let killTick = sample()
                if policy.claimKill(immediateWait: immediate,
                                    eligible: !clockFailed && result.pid > 0 && killTick >= result.killDeadline && killTick <= result.terminalHorizon) {
                    result.killAttempted = true; result.killTick = killTick
                    result.killReturn = Darwin.kill(result.pid, SIGKILL)
                    result.killErrno = result.killReturn < 0 ? errno : 0
                }
            }
            if let observation, case .failed = observation { result.observationFailure = true }
            var pollDescriptor = pollfd(fd: stderrRead.value, events: Int16(POLLIN | POLLHUP), revents: 0)
            let beforePoll = sample()
            let ticksRemaining = nextOrdinaryWaitTick > beforePoll ? nextOrdinaryWaitTick - beforePoll : 0
            let (scaledRemaining, remainingOverflow) = ticksRemaining.multipliedReportingOverflow(by: UInt64(result.clock.numerator))
            let nanosRemaining = remainingOverflow ? UInt64(10_000_000) : scaledRemaining / UInt64(result.clock.denominator)
            // Floor gives at most the remaining policy interval. A submillisecond
            // remainder uses a zero-time poll and remains continuous-deadline bounded.
            let timeout = terminalStatus == nil ? Int32(min(10, nanosRemaining / 1_000_000)) : 10
            let polled = Darwin.poll(&pollDescriptor, stderrRead.value >= 0 ? 1 : 0, timeout)
            if polled < 0 && errno != EINTR { result.observationFailure = true }
            if pollDescriptor.revents & Int16(POLLERR | POLLNVAL) != 0 {
                result.observationFailure = true; closeObserved(stderrRead)
            }
        }
        closeObserved(gateWrite); closeObserved(cancelWrite); closeObserved(stderrRead)
        // Only an actual exact-PID terminal wait produces this disposition.
        result.waitStatus = terminalStatus
        return result
    }
}
#endif
