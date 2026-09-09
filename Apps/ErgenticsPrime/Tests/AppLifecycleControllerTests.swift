import Foundation
import XCTest

/// Hostless controller mechanics. Exit hooks are inert and clocks fabricated.
/// Most tests disable automaticTimer; the named automatic-timer tests exercise
/// real DispatchSource scheduling with fabricated elapsed time and bounded
/// waits. None performs a native/VM call, real exit or kernel timing proof.
final class AppLifecycleControllerTests: XCTestCase {
    // Every mutable field is protected by this private lock. No closure is
    // invoked while the helper's lock is held; no native/resource handle lives
    // here. @unchecked Sendable is confined to these synchronized test boxes.
    private final class Observations: @unchecked Sendable {
        private let lock = NSLock()
        private var ticks: UInt64 = 1_000
        private var counts: [String: Int] = [:]
        private var flags: [String: Bool] = [:]
        func now() -> UInt64 { lock.lock(); defer { lock.unlock() }; return ticks }
        func setTime(_ value: UInt64) { lock.lock(); ticks = value; lock.unlock() }
        func increment(_ name: String) { lock.lock(); counts[name, default: 0] += 1; lock.unlock() }
        func count(_ name: String) -> Int { lock.lock(); defer { lock.unlock() }; return counts[name, default: 0] }
        func setFlag(_ name: String, _ value: Bool) { lock.lock(); flags[name] = value; lock.unlock() }
        func flag(_ name: String) -> Bool { lock.lock(); defer { lock.unlock() }; return flags[name] == true }
    }
    private final class ControllerBox: @unchecked Sendable {
        private let lock = NSLock()
        private weak var stored: AppLifecycleController?
        func set(_ controller: AppLifecycleController) { lock.lock(); stored = controller; lock.unlock() }
        func get() -> AppLifecycleController? { lock.lock(); defer { lock.unlock() }; return stored }
    }

    private let first = UUID(uuidString: "00000000-0000-0000-0000-000000000011")!
    private let second = UUID(uuidString: "00000000-0000-0000-0000-000000000012")!
    private let start: UInt64 = 1_000
    private let fiveSecondTicks: UInt64 = 120_000_000

    private func controller(_ observations: Observations,
                            normal: (@Sendable () -> Void)? = nil,
                            force: (@Sendable () -> Void)? = nil) -> AppLifecycleController {
        AppLifecycleController(timebaseNumerator: 125, timebaseDenominator: 3,
            clock: { observations.now() },
            forceExit: { observations.increment("force"); force?() },
            normalExit: { observations.increment("normal"); normal?() },
            automaticTimer: false)
    }

    func testIdleQuitPermissionPersistsWithoutRecursivelyCallingNormalHook() {
        let seen = Observations(); let c = controller(seen)
        XCTAssertTrue(c.requestQuit())
        XCTAssertTrue(c.requestQuit())
        XCTAssertEqual(seen.count("normal"), 0)
        seen.setTime(start + fiveSecondTicks)
        c.poll()
        XCTAssertEqual(seen.count("force"), 1)
        c.poll()
        XCTAssertEqual(seen.count("force"), 1)
    }

    func testExpiredInspectionBudgetCannotCancelLaterInspection() throws {
        let seen = Observations(); let c = controller(seen)
        try c.beginInspection(first) { seen.increment("first") }
        c.complete(first, completion: .inspected)
        try c.beginInspection(second) { seen.increment("second") }
        c.requestStop(for: first)
        XCTAssertEqual(seen.count("first"), 0)
        XCTAssertEqual(seen.count("second"), 0)
        c.requestStop(for: second); c.requestStop(for: second)
        XCTAssertEqual(seen.count("second"), 1)
        seen.setTime(start + fiveSecondTicks)
        c.poll()
        XCTAssertEqual(seen.count("force"), 1)
    }

    func testEarlyRepeatedStopRequestsOneRunScopedCancellation() throws {
        let seen = Observations(); let c = controller(seen)
        try c.beginRun(first) { seen.increment("cancel") }
        c.requestStop(); c.requestStop(); c.requestStop()
        XCTAssertEqual(seen.count("cancel"), 1)
        seen.setTime(start + fiveSecondTicks - 1); c.requestStop()
        XCTAssertEqual(seen.count("force"), 0)
        seen.setTime(start + fiveSecondTicks); c.poll()
        XCTAssertEqual(seen.count("cancel"), 1)
        XCTAssertEqual(seen.count("force"), 1)
        XCTAssertEqual(seen.count("normal"), 0)
    }

    func testConcurrentStopQuitRequestsDeliverOneCancellation() throws {
        let seen = Observations(); let c = controller(seen)
        try c.beginRun(first) { seen.increment("cancel") }
        DispatchQueue.concurrentPerform(iterations: 32) { index in
            if index.isMultiple(of: 2) { c.requestStop() } else { _ = c.requestQuit() }
        }
        XCTAssertEqual(seen.count("cancel"), 1)
        seen.setTime(start + 1); c.complete(first, completion: .conserved)
        XCTAssertEqual(seen.count("normal"), 1)
        XCTAssertEqual(seen.count("force"), 0)
    }

    func testStopCompletionBeforeGraceKeepsAppAliveAndDisarmsStop() throws {
        let seen = Observations(); let c = controller(seen)
        try c.beginRun(first) { seen.increment("cancel") }
        c.requestStop()
        seen.setTime(start + fiveSecondTicks - 1); c.complete(first, completion: .conserved)
        seen.setTime(start + fiveSecondTicks * 2); c.poll()
        XCTAssertEqual(seen.count("cancel"), 1)
        XCTAssertEqual(seen.count("normal"), 0)
        XCTAssertEqual(seen.count("force"), 0)
        try c.beginRun(second) { seen.increment("secondCancel") }
        XCTAssertEqual(seen.count("secondCancel"), 0) // explicit begin, no restart effect
    }

    func testNormalQuitHookCanReenterAndReceivesLastingPermission() throws {
        let seen = Observations(); let box = ControllerBox(); let finished = DispatchSemaphore(value: 0)
        let c = controller(seen, normal: {
            seen.setFlag("reentrantPermission", box.get()?.requestQuit() == true)
        })
        box.set(c); let id = first
        try c.beginRun(id) { seen.increment("cancel") }
        XCTAssertFalse(c.requestQuit())
        seen.setTime(start + 1)
        DispatchQueue.global().async { c.complete(id, completion: .conserved); finished.signal() }
        XCTAssertEqual(finished.wait(timeout: .now() + 2), .success)
        XCTAssertTrue(seen.flag("reentrantPermission"))
        XCTAssertEqual(seen.count("normal"), 1)
        XCTAssertEqual(seen.count("force"), 0)
    }

    func testCompletionAtOrAfterGraceForcesAndNeverClaimsTimelyQuit() throws {
        for extra in [UInt64(0), UInt64(1)] {
            let seen = Observations(); let c = controller(seen)
            try c.beginRun(first) { seen.increment("cancel") }
            XCTAssertFalse(c.requestQuit())
            seen.setTime(start + fiveSecondTicks + extra)
            c.complete(first, completion: .conserved); c.poll()
            XCTAssertEqual(seen.count("force"), 1)
            XCTAssertEqual(seen.count("normal"), 0)
        }
    }

    func testStaleCompletionCannotDisarmCurrentRunDeadlineOrClearItsCallback() throws {
        let seen = Observations(); let c = controller(seen)
        try c.beginRun(first) { seen.increment("oldCancel") }
        c.complete(first, completion: .conserved)
        try c.beginRun(second) { seen.increment("currentCancel") }
        c.complete(first, completion: .conserved)
        c.requestStop()
        XCTAssertEqual(seen.count("oldCancel"), 0)
        XCTAssertEqual(seen.count("currentCancel"), 1)
        seen.setTime(start + fiveSecondTicks)
        c.complete(first, completion: .conserved)
        c.poll()
        XCTAssertEqual(seen.count("force"), 1)
    }

    func testCancellationCallbackCanReenterControllerWithoutHeldLock() throws {
        let seen = Observations(); let box = ControllerBox(); let finished = DispatchSemaphore(value: 0)
        let c = controller(seen); box.set(c); let id = first
        try c.beginRun(id) {
            seen.increment("cancel")
            box.get()?.requestStop()
            box.get()?.complete(id, completion: .conserved)
            seen.setFlag("callbackReturned", true)
        }
        DispatchQueue.global().async { c.requestStop(); finished.signal() }
        XCTAssertEqual(finished.wait(timeout: .now() + 2), .success)
        XCTAssertTrue(seen.flag("callbackReturned"))
        XCTAssertEqual(seen.count("cancel"), 1)
        seen.setTime(start + fiveSecondTicks); c.poll()
        XCTAssertEqual(seen.count("force"), 0)
    }

    func testBackgroundForceHookRunsWithoutMainDrainAndCanReenter() throws {
        let seen = Observations(); let box = ControllerBox(); let finished = DispatchSemaphore(value: 0)
        let c = controller(seen, force: {
            seen.setFlag("backgroundForce", !Thread.isMainThread)
            box.get()?.poll()
            seen.setFlag("forceReentered", true)
        })
        box.set(c)
        try c.beginRun(first) { seen.increment("cancel") }
        c.requestStop(); seen.setTime(start + fiveSecondTicks)
        DispatchQueue.global().async { c.poll(); finished.signal() }
        // A semaphore blocks the test thread; it does not pump the main run
        // loop or run MainActor tasks like an async expectation waiter might.
        XCTAssertEqual(finished.wait(timeout: .now() + 2), .success)
        XCTAssertTrue(seen.flag("backgroundForce"))
        XCTAssertTrue(seen.flag("forceReentered"))
        XCTAssertEqual(seen.count("force"), 1)
    }

    func testExplicitQuitNowBypassesAClockHoldingTheControllerLock() {
        let seen = Observations(); let clockEntered = DispatchSemaphore(value: 0)
        let releaseClock = DispatchSemaphore(value: 0); let finished = DispatchSemaphore(value: 0)
        let forceObserved = DispatchSemaphore(value: 0); let quitReturned = DispatchSemaphore(value: 0)
        let c = AppLifecycleController(timebaseNumerator: 125, timebaseDenominator: 3,
            clock: {
                clockEntered.signal()
                _ = releaseClock.wait(timeout: .now() + 5)
                return seen.now()
            }, forceExit: { seen.increment("force"); forceObserved.signal() },
            normalExit: { seen.increment("normal") }, automaticTimer: false)
        DispatchQueue.global().async { c.requestStop(); finished.signal() }
        XCTAssertEqual(clockEntered.wait(timeout: .now() + 2), .success)
        DispatchQueue.global().async { c.quitNow(); quitReturned.signal() }
        let bypassed = forceObserved.wait(timeout: .now() + 2)
        releaseClock.signal()
        XCTAssertEqual(finished.wait(timeout: .now() + 2), .success)
        XCTAssertEqual(quitReturned.wait(timeout: .now() + 2), .success)
        XCTAssertEqual(bypassed, .success)
        XCTAssertEqual(seen.count("force"), 1) // inert hook; live hook does not return
        XCTAssertEqual(seen.count("normal"), 0)
    }

    func testStalledNormalExitHookCannotDisarmOriginalQuitDeadline() throws {
        let seen = Observations(); let normalEntered = DispatchSemaphore(value: 0)
        let releaseNormal = DispatchSemaphore(value: 0); let completionReturned = DispatchSemaphore(value: 0)
        let forceObserved = DispatchSemaphore(value: 0)
        let c = controller(seen, normal: {
            normalEntered.signal()
            _ = releaseNormal.wait(timeout: .now() + 5)
        }, force: {
            seen.setFlag("forceWhileNormalStalled", !Thread.isMainThread)
            forceObserved.signal()
        })
        let id = first
        try c.beginRun(id) { seen.increment("cancel") }
        XCTAssertFalse(c.requestQuit())
        seen.setTime(start + fiveSecondTicks - 1)
        DispatchQueue.global().async { c.complete(id, completion: .conserved); completionReturned.signal() }
        XCTAssertEqual(normalEntered.wait(timeout: .now() + 2), .success)
        seen.setTime(start + fiveSecondTicks)
        DispatchQueue.global().async { c.poll() }
        let observed = forceObserved.wait(timeout: .now() + 2)
        releaseNormal.signal()
        XCTAssertEqual(completionReturned.wait(timeout: .now() + 2), .success)
        XCTAssertEqual(observed, .success)
        XCTAssertTrue(seen.flag("forceWhileNormalStalled"))
        XCTAssertEqual(seen.count("normal"), 1)
        XCTAssertEqual(seen.count("force"), 1)
    }

    func testCompletedVolatileRecoveryAndQuarantineStillPermitUserQuit() throws {
        for result in [AppLifecyclePolicy.Completion.recoveryVolatile, .quarantined] {
            let seen = Observations(); let c = controller(seen)
            try c.beginRun(first) { seen.increment("cancel") }
            c.complete(first, completion: result)
            XCTAssertTrue(c.requestQuit())
            XCTAssertEqual(seen.count("normal"), 0) // delegate receives the permission directly
            XCTAssertEqual(seen.count("cancel"), 0)
            seen.setTime(start + fiveSecondTicks); c.poll()
            XCTAssertEqual(seen.count("force"), 1) // no observed process exit in this inert fixture
        }
    }

    func testReadinessCheckReturnsCanceledBeforeReentrantCallbackReadsIt() throws {
        let seen = Observations(); let c = controller(seen); let box = ControllerBox()
        box.set(c); let id = first
        let admitted = try c.beginReadiness(id) {
            seen.increment("cancel")
            if let snapshot = try? box.get()?.checkReadiness(id) {
                seen.setFlag("callbackSawCanceled", snapshot.canceled && snapshot.workBudgetExpired)
            }
        }
        XCTAssertEqual(admitted.phase, .working)
        XCTAssertEqual(admitted.startTicks, start)
        XCTAssertTrue(admitted.fallbackArmed)
        seen.setTime(start + fiveSecondTicks * 2)
        let checked = try c.checkReadiness(id)
        XCTAssertEqual(checked.phase, .grace)
        XCTAssertTrue(checked.canceled)
        XCTAssertTrue(seen.flag("callbackSawCanceled"))
        _ = try c.checkReadiness(id)
        XCTAssertEqual(seen.count("cancel"), 1)
        XCTAssertEqual(seen.count("force"), 0)
    }

    func testReadinessStaleCallsAndDuplicateAdmissionCannotReplaceOriginalOwner() throws {
        let seen = Observations(); let c = controller(seen)
        XCTAssertThrowsError(try c.checkReadiness(first))
        _ = try c.beginReadiness(first) { seen.increment("originalCancel") }
        XCTAssertThrowsError(try c.beginReadiness(second) { seen.increment("replacementCancel") })
        seen.setTime(UInt64.max)
        XCTAssertThrowsError(try c.checkReadiness(second))
        XCTAssertThrowsError(try c.completeReadiness(second))
        seen.setTime(start + fiveSecondTicks * 2)
        XCTAssertEqual(try c.checkReadiness(first).startTicks, start)
        XCTAssertEqual(seen.count("originalCancel"), 1)
        XCTAssertEqual(seen.count("replacementCancel"), 0)
        XCTAssertEqual(seen.count("force"), 0)
        seen.setTime(start + fiveSecondTicks * 3); c.poll()
        XCTAssertEqual(seen.count("force"), 1)
    }

    func testReadinessConcurrentAdmissionHasOnlyOneWinner() {
        let seen = Observations(); let c = controller(seen); let id = first
        DispatchQueue.concurrentPerform(iterations: 16) { _ in
            do {
                _ = try c.beginReadiness(id) { seen.increment("cancel") }
                seen.increment("admitted")
            } catch { seen.increment("rejected") }
        }
        XCTAssertEqual(seen.count("admitted"), 1)
        XCTAssertEqual(seen.count("rejected"), 15)
        seen.setTime(start + fiveSecondTicks * 2); c.poll()
        XCTAssertEqual(seen.count("cancel"), 1)
    }

    func testReadinessCompletionAndNormalQuitKeepEarlierFallbackArmed() throws {
        let seen = Observations(); let c = controller(seen)
        _ = try c.beginReadiness(first) { seen.increment("cancel") }
        seen.setTime(start + 1)
        let completed = try c.completeReadiness(first)
        XCTAssertEqual(completed.phase, .completedAwaitingExit)
        XCTAssertTrue(completed.workCompleted)
        XCTAssertTrue(completed.fallbackArmed)
        XCTAssertTrue(c.requestQuit())
        XCTAssertThrowsError(try c.beginRun(second) {})
        XCTAssertThrowsError(try c.completeReadiness(first))
        seen.setTime(start + fiveSecondTicks + 1); c.poll()
        XCTAssertEqual(seen.count("cancel"), 0)
        XCTAssertEqual(seen.count("normal"), 0) // delegate got permission, not an exit observation
        XCTAssertEqual(seen.count("force"), 1)
    }

    func testReadinessLateCompletionNeverDeliversNewNormalExitHook() throws {
        let seen = Observations(); let c = controller(seen)
        _ = try c.beginReadiness(first) { seen.increment("cancel") }
        seen.setTime(start + fiveSecondTicks * 2)
        let late = try c.completeReadiness(first)
        XCTAssertTrue(late.workCompleted)
        XCTAssertTrue(late.workBudgetExpired)
        XCTAssertTrue(late.canceled)
        XCTAssertEqual(late.phase, .grace)
        XCTAssertFalse(c.requestQuit())
        XCTAssertEqual(seen.count("normal"), 0)
        XCTAssertEqual(seen.count("cancel"), 1)
        seen.setTime(start + fiveSecondTicks * 3); c.poll()
        XCTAssertEqual(seen.count("force"), 1)
    }

    func testTimelyHandledDiagnosticSettlesOnlyAfterOutputThenPermitsNormalQuit() throws {
        let seen = Observations(); let c = controller(seen)
        _ = try c.beginReadiness(first) { seen.increment("cancel") }
        seen.setTime(start + fiveSecondTicks * 2 - 1)
        // Only the coordinator's ordering is modeled: no diagnostic stream,
        // AppKit termination, guest or real process exit runs in this test.
        let whileOutputPending = try c.checkReadiness(first)
        XCTAssertFalse(whileOutputPending.workCompleted)
        XCTAssertEqual(whileOutputPending.phase, .working)
        XCTAssertTrue(whileOutputPending.fallbackArmed)
        seen.increment("diagnosticOutputReturned")
        let settled = try c.completeReadiness(first)
        XCTAssertEqual(seen.count("diagnosticOutputReturned"), 1)
        XCTAssertTrue(settled.clockValid)
        XCTAssertFalse(settled.canceled)
        XCTAssertFalse(settled.workBudgetExpired)
        XCTAssertTrue(settled.workCompleted)
        XCTAssertTrue(settled.fallbackArmed)
        XCTAssertEqual(settled.startTicks, start)
        XCTAssertTrue(c.requestQuit()) // delegate permission, not readiness PASS
        XCTAssertEqual(seen.count("normal"), 0) // no recursive normal-exit hook
        XCTAssertEqual(seen.count("cancel"), 0)
        XCTAssertThrowsError(try c.completeReadiness(first))
        XCTAssertThrowsError(try c.beginReadiness(second) {})
        // Quit was requested one tick before 10s, so its five-second grace
        // is one tick earlier than the original fifteen-second horizon.
        seen.setTime(start + fiveSecondTicks * 3 - 2); c.poll()
        XCTAssertEqual(seen.count("force"), 0)
        seen.setTime(start + fiveSecondTicks * 3 - 1); c.poll()
        XCTAssertEqual(seen.count("force"), 1) // earlier grace, never completion + 15s
        seen.setTime(start + fiveSecondTicks * 3); c.poll()
        XCTAssertEqual(seen.count("force"), 1)
    }

    func testExpiredDiagnosticReturnCannotBecomeNormalQuitOrResetOriginalHorizon() throws {
        let seen = Observations(); let c = controller(seen)
        _ = try c.beginReadiness(first) { seen.increment("cancel") }
        seen.setTime(start + fiveSecondTicks * 2 + 1)
        // A returned diagnostic is not a timely work result. The production
        // coordinator may use its app-local emergency exit; this inert test
        // instead proves that the unchanged fallback still owns the deadline.
        let expired = try c.completeReadiness(first)
        XCTAssertTrue(expired.workCompleted)
        XCTAssertTrue(expired.workBudgetExpired)
        XCTAssertTrue(expired.canceled)
        XCTAssertTrue(expired.fallbackArmed)
        XCTAssertEqual(expired.startTicks, start)
        XCTAssertFalse(c.requestQuit())
        XCTAssertEqual(seen.count("normal"), 0)
        XCTAssertEqual(seen.count("cancel"), 1)
        seen.setTime(start + fiveSecondTicks * 3 - 1); c.poll()
        XCTAssertEqual(seen.count("force"), 0)
        seen.setTime(start + fiveSecondTicks * 3); c.poll()
        XCTAssertEqual(seen.count("force"), 1)
        c.poll()
        XCTAssertEqual(seen.count("force"), 1)
        XCTAssertEqual(seen.count("normal"), 0)
    }

    func testReadinessInvalidClockForcesBeforeAdmissionReturns() throws {
        let seen = Observations()
        let c = AppLifecycleController(timebaseNumerator: 0, timebaseDenominator: 0,
            clock: { seen.now() }, forceExit: { seen.increment("force") },
            normalExit: { seen.increment("normal") }, automaticTimer: false)
        let snapshot = try c.beginReadiness(first) { seen.increment("cancel") }
        XCTAssertEqual(snapshot.phase, .forced)
        XCTAssertFalse(snapshot.clockValid)
        XCTAssertFalse(snapshot.fallbackArmed)
        XCTAssertTrue(snapshot.canceled)
        XCTAssertEqual(seen.count("force"), 1)
        XCTAssertEqual(seen.count("cancel"), 0)
        c.poll()
        XCTAssertEqual(seen.count("force"), 1)
    }

    func testAutomaticReadinessTimerForcesWhileItsCancellationCallbackIsBlocked() throws {
        let seen = Observations(); let entered = DispatchSemaphore(value: 0)
        let release = DispatchSemaphore(value: 0); let returned = DispatchSemaphore(value: 0)
        let forced = DispatchSemaphore(value: 0)
        let c = AppLifecycleController(timebaseNumerator: 125, timebaseDenominator: 3,
            clock: { seen.now() }, forceExit: {
                seen.increment("force"); seen.setFlag("backgroundForce", !Thread.isMainThread)
                forced.signal()
            }, normalExit: { seen.increment("normal") }, automaticTimer: true)
        _ = try c.beginReadiness(first) {
            seen.increment("cancel"); entered.signal()
            _ = release.wait(timeout: .now() + 5)
            returned.signal()
        }
        defer { release.signal() }
        seen.setTime(start + fiveSecondTicks * 2)
        XCTAssertEqual(entered.wait(timeout: .now() + 2), .success)
        seen.setTime(start + fiveSecondTicks * 3)
        // No explicit poll and no main-run-loop pumping: the real timer queue
        // must remain available even though its cancellation callback waits.
        let observed = forced.wait(timeout: .now() + 2)
        release.signal()
        XCTAssertEqual(returned.wait(timeout: .now() + 2), .success)
        XCTAssertEqual(observed, .success)
        XCTAssertTrue(seen.flag("backgroundForce"))
        XCTAssertEqual(seen.count("cancel"), 1)
        XCTAssertEqual(seen.count("force"), 1)
        XCTAssertEqual(seen.count("normal"), 0)
        XCTAssertEqual(try c.checkReadiness(first).phase, .forced)
    }

    func testAutomaticReadinessTimerSurvivesBlockedNormalExitAfterTimelyCompletion() throws {
        let seen = Observations(); let entered = DispatchSemaphore(value: 0)
        let release = DispatchSemaphore(value: 0); let returned = DispatchSemaphore(value: 0)
        let forced = DispatchSemaphore(value: 0)
        let c = AppLifecycleController(timebaseNumerator: 125, timebaseDenominator: 3,
            clock: { seen.now() }, forceExit: {
                seen.increment("force"); seen.setFlag("backgroundForce", !Thread.isMainThread)
                forced.signal()
            }, normalExit: {
                seen.increment("normal"); entered.signal()
                _ = release.wait(timeout: .now() + 5)
            }, automaticTimer: true)
        let id = first
        _ = try c.beginReadiness(id) { seen.increment("cancel") }
        XCTAssertFalse(c.requestQuit())
        seen.setTime(start + 1)
        DispatchQueue.global().async {
            do { _ = try c.completeReadiness(id) }
            catch { seen.increment("unexpectedError") }
            returned.signal()
        }
        defer { release.signal() }
        XCTAssertEqual(entered.wait(timeout: .now() + 2), .success)
        seen.setTime(start + fiveSecondTicks)
        let observed = forced.wait(timeout: .now() + 2)
        release.signal()
        XCTAssertEqual(returned.wait(timeout: .now() + 2), .success)
        XCTAssertEqual(observed, .success)
        XCTAssertTrue(seen.flag("backgroundForce"))
        XCTAssertEqual(seen.count("unexpectedError"), 0)
        XCTAssertEqual(seen.count("cancel"), 1)
        XCTAssertEqual(seen.count("normal"), 1)
        XCTAssertEqual(seen.count("force"), 1)
    }
}
