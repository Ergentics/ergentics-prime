import Darwin
import Foundation

/// One owner for the stop deadline. No AppKit, journal, VM or external PID is
/// consulted by the emergency path. Tests inject clocks and inert exit hooks.
final class AppLifecycleController: @unchecked Sendable {
    private let lock = NSLock()
    private var policy: AppLifecyclePolicy
    private var cancellation: (UUID, @Sendable () -> Void)?
    private var timer: DispatchSourceTimer?
    private var normalTerminationRequested = false
    private let queue = DispatchQueue(label: "com.ergentics.provenance.stop-deadline", qos: .userInitiated)
    private let callbackQueue = DispatchQueue(label: "com.ergentics.provenance.lifecycle-callbacks",
                                             qos: .userInitiated, attributes: .concurrent)
    private let clock: @Sendable () -> UInt64
    private let forceExit: @Sendable () -> Void
    private let normalExit: @Sendable () -> Void
    private let automaticTimer: Bool

    init(timebaseNumerator: UInt32, timebaseDenominator: UInt32,
         clock: @escaping @Sendable () -> UInt64,
         forceExit: @escaping @Sendable () -> Void,
         normalExit: @escaping @Sendable () -> Void,
         automaticTimer: Bool = true) {
        policy = AppLifecyclePolicy(timebaseNumerator: timebaseNumerator,
                                    timebaseDenominator: timebaseDenominator)
        self.clock = clock; self.forceExit = forceExit
        self.normalExit = normalExit; self.automaticTimer = automaticTimer
    }

    #if !EPR_APP_LIFECYCLE_TESTS
    static func live(normalExit: @escaping @Sendable () -> Void) -> AppLifecycleController {
        var timebase = mach_timebase_info_data_t()
        let status = mach_timebase_info(&timebase)
        return AppLifecycleController(timebaseNumerator: status == KERN_SUCCESS ? timebase.numer : 0,
            timebaseDenominator: status == KERN_SUCCESS ? timebase.denom : 0,
            clock: { mach_continuous_time() }, forceExit: { Darwin._exit(70) }, normalExit: normalExit)
    }
    #endif

    func beginRun(_ id: UUID, cancel: @escaping @Sendable () -> Void) throws {
        lock.lock(); defer { lock.unlock() }
        try policy.beginRun(id)
        cancellation = (id, cancel)
    }

    /// Scheduling only. The app separately requires the native owner's opaque
    /// H3 handoff; this transition cannot activate another guest.
    func beginPersistence(_ id: UUID, cancel: @escaping @Sendable () -> Void) throws {
        lock.lock(); defer { lock.unlock() }
        try policy.beginPersistence(id)
        cancellation = (id, cancel)
    }

    func beginInspection(_ id: UUID, cancel: @escaping @Sendable () -> Void) throws {
        lock.lock(); defer { lock.unlock() }
        try policy.beginInspection(id)
        cancellation = (id, cancel)
    }

    /// A delayed worker budget cannot stop a later run or inspection.
    func requestStop(for id: UUID) {
        lock.lock()
        guard cancellation?.0 == id else { lock.unlock(); return }
        let effects = policy.request(.stop, now: clock())
        let callback = cancellation
        updateTimerLocked()
        lock.unlock()
        deliver(effects, callback: callback)
    }

    /// Fixed ten-second work budget and original-start fifteen-second exit
    /// horizon. Admission arms the independent timer before returning.
    func beginReadiness(_ id: UUID, cancel: @escaping @Sendable () -> Void) throws
        -> AppLifecyclePolicy.ReadinessSnapshot {
        lock.lock()
        let update: AppLifecyclePolicy.ReadinessUpdate
        do { update = try policy.beginReadiness(id, now: clock()) }
        catch { lock.unlock(); throw error }
        cancellation = (id, cancel)
        if update.effects.contains(.terminateNormally) { normalTerminationRequested = true }
        let callback = cancellation
        updateTimerLocked()
        lock.unlock()
        deliver(update.effects, callback: callback)
        return update.snapshot
    }

    func checkReadiness(_ id: UUID) throws -> AppLifecyclePolicy.ReadinessSnapshot {
        try updateReadiness(id, completing: false)
    }

    /// This records only returned coordinator work, not successful output or
    /// process exit. The fixed exit fallback remains armed after completion.
    func completeReadiness(_ id: UUID) throws -> AppLifecyclePolicy.ReadinessSnapshot {
        try updateReadiness(id, completing: true)
    }

    private func updateReadiness(_ id: UUID, completing: Bool) throws
        -> AppLifecyclePolicy.ReadinessSnapshot {
        lock.lock()
        let update: AppLifecyclePolicy.ReadinessUpdate
        do {
            if completing { update = try policy.completeReadiness(id, now: clock()) }
            else { update = try policy.checkReadiness(id, now: clock()) }
        } catch { lock.unlock(); throw error }
        if update.effects.contains(.terminateNormally) { normalTerminationRequested = true }
        let callback = cancellation
        if completing && cancellation?.0 == id { cancellation = nil }
        updateTimerLocked()
        lock.unlock()
        deliver(update.effects, callback: callback)
        return update.snapshot
    }

    func complete(_ id: UUID, completion: AppLifecyclePolicy.Completion) {
        lock.lock()
        let effects = policy.observe(runID: id, state: .completed(completion), now: clock())
        if effects.contains(.terminateNormally) { normalTerminationRequested = true }
        let callback = cancellation
        if cancellation?.0 == id { cancellation = nil }
        updateTimerLocked()
        lock.unlock()
        deliver(effects, callback: callback)
    }

    func requestStop() { _ = request(.stop, returnNormalExit: false) }

    /// When called from applicationShouldTerminate, return true directly;
    /// do not recursively call NSApplication.terminate from that delegate call.
    func requestQuit() -> Bool { request(.quit, returnNormalExit: true) }

    // Explicit user emergency exit bypasses policy locks, clocks and callbacks.
    // The live hook never returns. Tests use an inert hook instead.
    func quitNow() { forceExit() }

    private func request(_ intent: AppLifecyclePolicy.Intent, returnNormalExit: Bool) -> Bool {
        lock.lock()
        let effects = policy.request(intent, now: clock())
        if effects.contains(.terminateNormally) { normalTerminationRequested = true }
        let mayTerminateNormally = normalTerminationRequested
        let callback = cancellation
        updateTimerLocked()
        lock.unlock()
        deliver(effects, callback: callback, suppressNormalExit: returnNormalExit)
        return mayTerminateNormally
    }

    /// Also exercised by fabricated-clock tests; never waits on the UI actor.
    func poll() { poll(timerOrigin: false) }

    private func poll(timerOrigin: Bool) {
        lock.lock()
        let effects = policy.poll(now: clock())
        if effects.contains(.terminateNormally) { normalTerminationRequested = true }
        let callback = cancellation
        updateTimerLocked()
        lock.unlock()
        // A timer-origin callback may wait on arbitrary coordinator work.
        // Keep it off the deadline queue so the next poll can still force exit.
        // The force hook itself stays direct and does not wait behind callbacks.
        if timerOrigin && !effects.contains(.forceSelfExit70) && !effects.isEmpty {
            callbackQueue.async { [self] in deliver(effects, callback: callback) }
        } else { deliver(effects, callback: callback) }
    }

    private func updateTimerLocked() {
        guard policy.hasPendingDeadline else {
            timer?.cancel(); timer = nil
            return
        }
        guard automaticTimer, timer == nil else { return }
        let source = DispatchSource.makeTimerSource(queue: queue)
        source.schedule(deadline: .now(), repeating: .milliseconds(20), leeway: .milliseconds(1))
        source.setEventHandler { [weak self] in self?.poll(timerOrigin: true) }
        timer = source
        source.resume()
    }

    private func deliver(_ effects: [AppLifecyclePolicy.Effect],
                         callback: (UUID, @Sendable () -> Void)?, suppressNormalExit: Bool = false) {
        // A late deadline must not be delayed by a cancellation callback.
        if effects.contains(.forceSelfExit70) { forceExit(); return }
        for effect in effects {
            switch effect {
            case .requestCancellation(let id):
                if let callback, callback.0 == id { callback.1() }
            case .terminateNormally:
                if !suppressNormalExit { normalExit() }
            case .finishStop, .forceSelfExit70: break
            }
        }
    }

    deinit { timer?.cancel() }
}
