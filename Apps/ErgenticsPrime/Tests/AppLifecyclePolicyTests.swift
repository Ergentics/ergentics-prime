import Foundation
import XCTest

/// Fabricated clock and work observations only. No timer, native call, app,
/// cancellation, filesystem, process, or real exit is entered by these tests.
final class AppLifecyclePolicyTests: XCTestCase {
    private let first = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    private let second = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
    private let start: UInt64 = 1_000
    private let fiveSecondTicks: UInt64 = 120_000_000 // exact 125/3 ns timebase

    private func policy() -> AppLifecyclePolicy {
        AppLifecyclePolicy(timebaseNumerator: 125, timebaseDenominator: 3)
    }

    func testReadOnlyInspectionRepeatsWithoutEnablingGuestOrPersistence() throws {
        var p = policy()
        try p.beginInspection(first)
        XCTAssertFalse(p.mayActivate(runID: first))
        XCTAssertThrowsError(try p.beginInspection(second))
        _ = p.observe(runID: first, state: .completed(.inspected), now: start)
        XCTAssertThrowsError(try p.beginRun(second))
        XCTAssertThrowsError(try p.beginPersistence(second))
        XCTAssertThrowsError(try p.beginInspection(first))
        try p.beginInspection(second)
        XCTAssertFalse(p.mayActivate(runID: second))
        XCTAssertEqual(p.request(.stop, now: start + 1), [.requestCancellation(runID: second)])
        XCTAssertEqual(p.poll(now: start + 1 + fiveSecondTicks), [.forceSelfExit70])
    }

    func testInspectionCannotAdoptUnsavedRecoveryOrPendingQuit() throws {
        for completion in [AppLifecyclePolicy.Completion.conservedVolatile, .recoveryVolatile, .quarantined] {
            var p = policy(); try p.beginRun(first)
            _ = p.observe(runID: first, state: .completed(completion), now: start)
            XCTAssertThrowsError(try p.beginInspection(second))
        }
        var p = policy(); _ = p.request(.quit, now: start)
        XCTAssertThrowsError(try p.beginInspection(first))
        var saved = policy(); try saved.beginRun(first)
        _ = saved.observe(runID: first, state: .completed(.conserved), now: start)
        try saved.beginInspection(second)
        XCTAssertFalse(saved.mayActivate(runID: second))
    }

    func testConservedVolatileH3AllowsOnlyExplicitPersistenceNotGuestReentry() throws {
        var p = policy()
        try p.beginRun(first)
        _ = p.observe(runID: first, state: .completed(.conservedVolatile), now: start)
        XCTAssertThrowsError(try p.beginRun(second))
        XCTAssertThrowsError(try p.beginPersistence(first))
        try p.beginPersistence(second)
        XCTAssertFalse(p.mayActivate(runID: second))
        XCTAssertEqual(p.request(.stop, now: start + 1), [.requestCancellation(runID: second)])
        XCTAssertEqual(p.poll(now: start + 1 + fiveSecondTicks), [.forceSelfExit70])
    }

    func testPersistenceCannotConvertRecoveryQuarantineOrQuitIntoAdmission() throws {
        for completion in [AppLifecyclePolicy.Completion.recoveryVolatile, .quarantined, .conserved] {
            var p = policy()
            try p.beginRun(first)
            _ = p.observe(runID: first, state: .completed(completion), now: start)
            XCTAssertThrowsError(try p.beginPersistence(second))
        }
        var p = policy()
        XCTAssertThrowsError(try p.beginPersistence(first))
        try p.beginRun(first)
        _ = p.observe(runID: first, state: .completed(.conservedVolatile), now: start)
        _ = p.request(.quit, now: start + 1)
        XCTAssertThrowsError(try p.beginPersistence(second))
        XCTAssertTrue(p.hasPendingDeadline)
    }

    func testIdleStopDoesNotRequestCancellationOrForceExit() {
        var p = policy()
        XCTAssertEqual(p.request(.stop, now: start), [.finishStop(runID: nil)])
        XCTAssertEqual(p.request(.stop, now: UInt64.max), [])
        XCTAssertFalse(p.hasPendingDeadline)
        XCTAssertNil(p.forceReason)
    }

    func testIdleQuitRequestsNormalTerminationOnce() {
        var p = policy()
        XCTAssertEqual(p.request(.quit, now: start), [.terminateNormally])
        XCTAssertEqual(p.request(.quit, now: start + 1), [])
        XCTAssertTrue(p.hasPendingDeadline)
        XCTAssertThrowsError(try p.beginRun(first))
        XCTAssertEqual(p.poll(now: start + fiveSecondTicks), [.forceSelfExit70])
    }

    func testStopLatchesBeforeActivationAndCancelsExactRunOnce() throws {
        var p = policy(); try p.beginRun(first)
        XCTAssertTrue(p.mayActivate(runID: first))
        XCTAssertFalse(p.mayActivate(runID: second))
        XCTAssertEqual(p.request(.stop, now: start), [.requestCancellation(runID: first)])
        XCTAssertFalse(p.mayActivate(runID: first))
        XCTAssertEqual(p.request(.stop, now: start + 1), [])
        XCTAssertEqual(p.graceStartedTicks, start)
        XCTAssertTrue(p.hasPendingDeadline)
    }

    func testStopCompletionPreservesAppAndDoesNotRestart() throws {
        var p = policy(); try p.beginRun(first)
        _ = p.request(.stop, now: start)
        XCTAssertEqual(p.observe(runID: first, state: .completed(.conserved), now: start + 1), [.finishStop(runID: first)])
        XCTAssertEqual(p.workState, .completed(.conserved))
        XCTAssertFalse(p.hasPendingDeadline)
        XCTAssertFalse(p.mayActivate(runID: first))
        XCTAssertEqual(p.poll(now: UInt64.max), [])
        XCTAssertEqual(p.request(.stop, now: UInt64.max), [])
    }

    func testQuitCompletionRequestsNormalTermination() throws {
        var p = policy(); try p.beginRun(first)
        XCTAssertEqual(p.request(.quit, now: start), [.requestCancellation(runID: first)])
        XCTAssertEqual(p.observe(runID: first, state: .completed(.conserved), now: start + 1), [.terminateNormally])
        XCTAssertEqual(p.observe(runID: first, state: .completed(.conserved), now: start + 2), [])
        XCTAssertTrue(p.hasPendingDeadline)
        XCTAssertEqual(p.poll(now: start + fiveSecondTicks), [.forceSelfExit70])
    }

    func testRepeatedStopCannotExtendDeadline() throws {
        var p = policy(); try p.beginRun(first)
        _ = p.request(.stop, now: start)
        XCTAssertEqual(p.request(.stop, now: start + fiveSecondTicks - 1), [])
        XCTAssertEqual(p.poll(now: start + fiveSecondTicks), [.forceSelfExit70])
        XCTAssertEqual(p.graceStartedTicks, start)
        XCTAssertEqual(p.forceReason, .graceExpired)
    }

    func testStopToQuitPreservesFirstDeadline() throws {
        var p = policy(); try p.beginRun(first)
        _ = p.request(.stop, now: start)
        XCTAssertEqual(p.request(.quit, now: start + fiveSecondTicks - 1), [])
        XCTAssertEqual(p.pendingIntent, .quit)
        XCTAssertEqual(p.graceStartedTicks, start)
        XCTAssertEqual(p.poll(now: start + fiveSecondTicks), [.forceSelfExit70])
    }

    func testStopCannotDowngradePendingQuit() throws {
        var p = policy(); try p.beginRun(first)
        _ = p.request(.quit, now: start)
        XCTAssertEqual(p.request(.stop, now: start + 1), [])
        XCTAssertEqual(p.pendingIntent, .quit)
        XCTAssertEqual(p.observe(runID: first, state: .completed(.conserved), now: start + 2), [.terminateNormally])
    }

    func testCompletedStopThenLaterQuitStartsFreshQuitDeadline() throws {
        var p = policy(); try p.beginRun(first)
        _ = p.request(.stop, now: start)
        _ = p.observe(runID: first, state: .completed(.conserved), now: start + 1)
        XCTAssertNil(p.graceStartedTicks)
        let later = start + fiveSecondTicks * 2
        XCTAssertEqual(p.request(.quit, now: later), [.terminateNormally])
        XCTAssertEqual(p.graceStartedTicks, later)
        XCTAssertEqual(p.poll(now: later + fiveSecondTicks - 1), [])
        XCTAssertEqual(p.poll(now: later + fiveSecondTicks), [.forceSelfExit70])
    }

    func testExactFiveSecondBoundaryForcesEvenLateCompletion() throws {
        for intent in [AppLifecyclePolicy.Intent.stop, .quit] {
            var p = policy(); try p.beginRun(first)
            _ = p.request(intent, now: start)
            XCTAssertEqual(p.observe(runID: first, state: .completed(.conserved), now: start + fiveSecondTicks), [.forceSelfExit70])
            XCTAssertEqual(p.forceReason, .graceExpired)
            XCTAssertEqual(p.workState, .completed(.conserved))
            XCTAssertFalse(p.hasPendingDeadline)
        }
    }

    func testJournalStillRunningRemainsInsideSameGraceWindow() throws {
        var p = policy(); try p.beginRun(first)
        _ = p.request(.quit, now: start)
        XCTAssertEqual(p.observe(runID: first, state: .running, now: start + fiveSecondTicks - 1), [])
        XCTAssertEqual(p.poll(now: start + fiveSecondTicks), [.forceSelfExit70])
    }

    func testCompletedVolatileRecoveryAndQuarantineDoNotBlockQuit() throws {
        for completion in [AppLifecyclePolicy.Completion.recoveryVolatile, .quarantined] {
            var p = policy(); try p.beginRun(first)
            XCTAssertEqual(p.observe(runID: first, state: .completed(completion), now: start), [])
            XCTAssertEqual(p.workState, .completed(completion))
            XCTAssertEqual(p.request(.quit, now: start + 1), [.terminateNormally])
            XCTAssertNil(p.forceReason)
        }
    }

    func testVolatileCompletionDuringPendingQuitCanQuitBeforeDeadline() throws {
        var p = policy(); try p.beginRun(first)
        _ = p.request(.quit, now: start)
        XCTAssertEqual(p.observe(runID: first, state: .completed(.recoveryVolatile), now: start + 1), [.terminateNormally])
    }

    func testStoppedFailedRecoveryStaysInspectableWithoutRestart() throws {
        for completion in [AppLifecyclePolicy.Completion.recoveryVolatile, .quarantined] {
            var p = policy(); try p.beginRun(first)
            _ = p.request(.stop, now: start)
            XCTAssertEqual(p.observe(runID: first, state: .completed(completion), now: start + 1), [.finishStop(runID: first)])
            XCTAssertThrowsError(try p.beginRun(second)) { XCTAssertEqual($0 as? AppLifecyclePolicy.BeginError, .recoveryRequiresAttention) }
            XCTAssertEqual(p.request(.quit, now: start + 2), [.terminateNormally])
        }
    }

    func testQuitNowAlwaysRequestsSelfExitOnceWithoutExternalActuation() throws {
        var idle = policy()
        XCTAssertEqual(idle.request(.quitNow, now: start), [.forceSelfExit70])
        XCTAssertEqual(idle.request(.quitNow, now: start), [])
        var running = policy(); try running.beginRun(first)
        XCTAssertEqual(running.request(.quitNow, now: start), [.forceSelfExit70])
        XCTAssertFalse(running.mayActivate(runID: first))
        XCTAssertEqual(running.forceReason, .explicitQuitNow)
        XCTAssertFalse(running.hasPendingDeadline)
    }

    func testQuitNowCanEscalateAnUncompletedNormalQuitRequest() {
        var p = policy()
        XCTAssertEqual(p.request(.quit, now: start), [.terminateNormally])
        XCTAssertEqual(p.request(.quitNow, now: start + 1), [.forceSelfExit70])
    }

    func testUnsettledWorkCannotBeReplacedOrErasedByIdleObservation() throws {
        var p = policy(); try p.beginRun(first)
        XCTAssertThrowsError(try p.beginRun(second)) { XCTAssertEqual($0 as? AppLifecyclePolicy.BeginError, .workUnsettled) }
        XCTAssertEqual(p.observe(runID: first, state: .idle, now: start), [])
        XCTAssertEqual(p.workState, .running)
    }

    func testStaleRunCompletionCannotSettleNewRun() throws {
        var p = policy(); try p.beginRun(first)
        _ = p.observe(runID: first, state: .completed(.conserved), now: start)
        try p.beginRun(second)
        _ = p.request(.stop, now: start + 1)
        XCTAssertEqual(p.observe(runID: first, state: .completed(.conserved), now: UInt64.max), [])
        XCTAssertEqual(p.workState, .running)
        XCTAssertEqual(p.runID, second)
        XCTAssertTrue(p.hasPendingDeadline)
    }

    func testNewExplicitRunGetsFreshLatchButCannotReuseOldRunIdentity() throws {
        var p = policy(); try p.beginRun(first)
        _ = p.request(.stop, now: start)
        _ = p.observe(runID: first, state: .completed(.conserved), now: start + 1)
        try p.beginRun(second)
        XCTAssertNil(p.pendingIntent)
        XCTAssertNil(p.graceStartedTicks)
        XCTAssertTrue(p.mayActivate(runID: second))
        _ = p.observe(runID: second, state: .completed(.conserved), now: start + 2)
        XCTAssertThrowsError(try p.beginRun(first)) { XCTAssertEqual($0 as? AppLifecyclePolicy.BeginError, .duplicateRunID) }
    }

    func testClockRegressionForcesInsteadOfParking() throws {
        var p = policy(); try p.beginRun(first)
        _ = p.request(.stop, now: start)
        XCTAssertEqual(p.poll(now: start + 5), [])
        XCTAssertEqual(p.poll(now: start + 4), [.forceSelfExit70])
        XCTAssertEqual(p.forceReason, .clockRegressed)
        XCTAssertEqual(p.poll(now: UInt64.max), [])
    }

    func testInvalidTimebaseCannotCreateAnIndefiniteDeadline() throws {
        let cases: [(UInt32, UInt32)] = [(0, 1), (1, 0), (0, 0)]
        for values in cases {
            var p = AppLifecyclePolicy(timebaseNumerator: values.0, timebaseDenominator: values.1)
            try p.beginRun(first)
            XCTAssertEqual(p.request(.quit, now: start), [.requestCancellation(runID: first), .forceSelfExit70])
            XCTAssertEqual(p.forceReason, .invalidTimebase)
            XCTAssertFalse(p.hasPendingDeadline)
        }
    }

    func testUnrequestedRunningWorkDoesNotAcquireAnAutomaticDeadline() throws {
        var p = policy(); try p.beginRun(first)
        XCTAssertEqual(p.poll(now: UInt64.max), [])
        XCTAssertFalse(p.hasPendingDeadline)
        XCTAssertTrue(p.mayActivate(runID: first))
    }

    func testDeadlineDoesNotOverflowWhenStartIsNearUInt64Maximum() throws {
        var p = AppLifecyclePolicy(timebaseNumerator: 1, timebaseDenominator: 1)
        try p.beginRun(first)
        let nearEnd = UInt64.max - AppLifecyclePolicy.graceNanoseconds
        _ = p.request(.stop, now: nearEnd)
        XCTAssertEqual(p.poll(now: UInt64.max - 1), [])
        XCTAssertEqual(p.poll(now: UInt64.max), [.forceSelfExit70])
    }

    func testWideProductsRetainExactBoundaryWithoutFloatingPoint() throws {
        var p = AppLifecyclePolicy(timebaseNumerator: UInt32.max, timebaseDenominator: UInt32.max)
        try p.beginRun(first)
        _ = p.request(.quit, now: 0)
        XCTAssertEqual(p.poll(now: AppLifecyclePolicy.graceNanoseconds - 1), [])
        XCTAssertEqual(p.poll(now: AppLifecyclePolicy.graceNanoseconds), [.forceSelfExit70])
    }

    func testNonintegralTickDeadlineRoundsOnlyByExactComparison() throws {
        var p = AppLifecyclePolicy(timebaseNumerator: 3, timebaseDenominator: 1)
        try p.beginRun(first)
        _ = p.request(.stop, now: 0)
        XCTAssertEqual(p.poll(now: 1_666_666_666), [])
        XCTAssertEqual(p.poll(now: 1_666_666_667), [.forceSelfExit70])
    }

    func testReadinessAdmissionArmsFixedBudgetAndPreservesRawClockFields() throws {
        var p = policy()
        let update = try p.beginReadiness(first, now: start)
        XCTAssertEqual(update.effects, [])
        XCTAssertEqual(update.snapshot.runID, first)
        XCTAssertEqual(update.snapshot.phase, .working)
        XCTAssertEqual(update.snapshot.startTicks, start)
        XCTAssertEqual(update.snapshot.observationTicks, start)
        XCTAssertEqual(update.snapshot.timebaseNumerator, 125)
        XCTAssertEqual(update.snapshot.timebaseDenominator, 3)
        XCTAssertTrue(update.snapshot.clockValid)
        XCTAssertTrue(update.snapshot.fallbackArmed)
        XCTAssertFalse(update.snapshot.canceled)
        XCTAssertFalse(update.snapshot.workBudgetExpired)
        XCTAssertFalse(update.snapshot.workCompleted)
        XCTAssertTrue(p.hasPendingDeadline)
        XCTAssertNil(p.graceStartedTicks)
        XCTAssertFalse(p.mayActivate(runID: first))
    }

    func testReadinessExactWorkBoundaryCancelsOnceBeforeSnapshotIsReturned() throws {
        var p = policy(); _ = try p.beginReadiness(first, now: start)
        let before = try p.checkReadiness(first, now: start + fiveSecondTicks * 2 - 1)
        XCTAssertEqual(before.snapshot.phase, .working)
        XCTAssertFalse(before.snapshot.canceled)
        let boundary = try p.checkReadiness(first, now: start + fiveSecondTicks * 2)
        XCTAssertEqual(boundary.effects, [.requestCancellation(runID: first)])
        XCTAssertEqual(boundary.snapshot.phase, .grace)
        XCTAssertTrue(boundary.snapshot.workBudgetExpired)
        XCTAssertTrue(boundary.snapshot.canceled)
        XCTAssertTrue(boundary.snapshot.fallbackArmed)
        XCTAssertFalse(p.mayActivate(runID: first))
        XCTAssertNil(p.graceStartedTicks)
        XCTAssertEqual(try p.checkReadiness(first, now: start + fiveSecondTicks * 2 + 1).effects, [])
    }

    func testDelayedFirstReadinessPollNeverRestartsFiveSecondGrace() throws {
        var p = policy(); _ = try p.beginReadiness(first, now: start)
        let delayed = try p.checkReadiness(first, now: start + fiveSecondTicks * 3 - 1)
        XCTAssertEqual(delayed.effects, [.requestCancellation(runID: first)])
        XCTAssertEqual(delayed.snapshot.startTicks, start)
        XCTAssertNil(p.graceStartedTicks)
        let cutoff = try p.checkReadiness(first, now: start + fiveSecondTicks * 3)
        XCTAssertEqual(cutoff.effects, [.forceSelfExit70])
        XCTAssertEqual(cutoff.snapshot.phase, .forced)
        XCTAssertTrue(cutoff.snapshot.workBudgetExpired)
        XCTAssertTrue(cutoff.snapshot.canceled)
        XCTAssertFalse(cutoff.snapshot.fallbackArmed)
        XCTAssertEqual(p.forceReason, .readinessHorizonExpired)
        XCTAssertEqual(try p.checkReadiness(first, now: UInt64.max).effects, [])
    }

    func testFirstReadinessPollAtHorizonForcesWithoutBlockingCancellationEffect() throws {
        var p = policy(); _ = try p.beginReadiness(first, now: start)
        XCTAssertEqual(p.poll(now: start + fiveSecondTicks * 3), [.forceSelfExit70])
        XCTAssertEqual(p.forceReason, .readinessHorizonExpired)
    }

    func testReadinessCompletionDoesNotProveOutputOrRemoveOriginalHorizon() throws {
        var p = policy(); _ = try p.beginReadiness(first, now: start)
        let completed = try p.completeReadiness(first, now: start + 1)
        XCTAssertEqual(completed.effects, [])
        XCTAssertEqual(completed.snapshot.phase, .completedAwaitingExit)
        XCTAssertTrue(completed.snapshot.workCompleted)
        XCTAssertTrue(completed.snapshot.fallbackArmed)
        XCTAssertFalse(completed.snapshot.canceled)
        XCTAssertFalse(p.mayActivate(runID: first))
        XCTAssertThrowsError(try p.beginRun(second))
        XCTAssertThrowsError(try p.completeReadiness(first, now: start + 2)) {
            XCTAssertEqual($0 as? AppLifecyclePolicy.ReadinessError, .alreadyCompleted)
        }
        let late = try p.checkReadiness(first, now: start + fiveSecondTicks * 2)
        XCTAssertTrue(late.snapshot.workBudgetExpired)
        XCTAssertTrue(late.snapshot.workCompleted)
        XCTAssertEqual(late.effects, []) // no new normal0 after work-budget expiry
        XCTAssertEqual(p.poll(now: start + fiveSecondTicks * 3), [.forceSelfExit70])
    }

    func testTimelyReadinessQuitCanShortenButNeverRemoveFallback() throws {
        var p = policy(); _ = try p.beginReadiness(first, now: start)
        _ = try p.completeReadiness(first, now: start + 1)
        XCTAssertEqual(p.request(.quit, now: start + 2), [.terminateNormally])
        XCTAssertTrue(p.hasPendingDeadline)
        XCTAssertEqual(p.request(.quit, now: start + fiveSecondTicks), [])
        XCTAssertEqual(p.poll(now: start + fiveSecondTicks + 1), [])
        XCTAssertEqual(p.poll(now: start + fiveSecondTicks + 2), [.forceSelfExit70])
        XCTAssertEqual(p.graceStartedTicks, start + 2)
        XCTAssertEqual(p.forceReason, .graceExpired)
    }

    func testReadinessStopCompletionCannotEraseEarlierManualDeadline() throws {
        var p = policy(); _ = try p.beginReadiness(first, now: start)
        let manual = start + fiveSecondTicks / 5 // one second
        XCTAssertEqual(p.request(.stop, now: manual), [.requestCancellation(runID: first)])
        let completed = try p.completeReadiness(first, now: manual + 1)
        XCTAssertEqual(completed.effects, [.finishStop(runID: first)])
        XCTAssertTrue(completed.snapshot.canceled)
        XCTAssertTrue(completed.snapshot.fallbackArmed)
        XCTAssertEqual(p.graceStartedTicks, manual)
        XCTAssertEqual(p.request(.stop, now: manual + fiveSecondTicks - 1), [])
        XCTAssertEqual(p.poll(now: manual + fiveSecondTicks), [.forceSelfExit70])
    }

    func testLateManualReadinessQuitCannotExtendOriginalHorizon() throws {
        var p = policy(); _ = try p.beginReadiness(first, now: start)
        let late = start + fiveSecondTicks * 2 + 1
        _ = p.request(.quit, now: late)
        XCTAssertEqual(p.graceStartedTicks, late)
        let completed = try p.completeReadiness(first, now: late + 1)
        XCTAssertTrue(completed.snapshot.canceled)
        XCTAssertTrue(completed.snapshot.workBudgetExpired)
        XCTAssertFalse(completed.effects.contains(.terminateNormally))
        XCTAssertEqual(p.poll(now: start + fiveSecondTicks * 3), [.forceSelfExit70])
        XCTAssertEqual(p.forceReason, .readinessHorizonExpired)
    }

    func testLateReadinessCompletionCannotProduceNewNormalSuccessExit() throws {
        for ticks in [fiveSecondTicks * 2, fiveSecondTicks * 3 - 1, fiveSecondTicks * 3] {
            var p = policy(); _ = try p.beginReadiness(first, now: start)
            let update = try p.completeReadiness(first, now: start + ticks)
            XCTAssertTrue(update.snapshot.canceled)
            XCTAssertTrue(update.snapshot.workBudgetExpired)
            XCTAssertTrue(update.snapshot.workCompleted)
            XCTAssertFalse(update.effects.contains(.terminateNormally))
            if ticks == fiveSecondTicks * 3 {
                XCTAssertEqual(update.effects, [.forceSelfExit70])
                XCTAssertEqual(update.snapshot.phase, .forced)
            } else {
                XCTAssertEqual(update.snapshot.phase, .grace)
                XCTAssertEqual(p.request(.quit, now: start + ticks), [])
                XCTAssertTrue(p.hasPendingDeadline)
            }
        }
    }

    func testReadinessMissingStaleAndRepeatedAdmissionDoNotResetDeadline() throws {
        var p = policy()
        XCTAssertThrowsError(try p.checkReadiness(first, now: start)) {
            XCTAssertEqual($0 as? AppLifecyclePolicy.ReadinessError, .notAdmitted)
        }
        _ = try p.beginReadiness(first, now: start)
        XCTAssertThrowsError(try p.beginReadiness(first, now: start + 1))
        XCTAssertThrowsError(try p.beginReadiness(second, now: start + 2))
        XCTAssertThrowsError(try p.checkReadiness(second, now: UInt64.max)) {
            XCTAssertEqual($0 as? AppLifecyclePolicy.ReadinessError, .staleRunID)
        }
        XCTAssertThrowsError(try p.completeReadiness(second, now: UInt64.max))
        let unchanged = try p.checkReadiness(first, now: start + 3)
        XCTAssertEqual(unchanged.snapshot.startTicks, start)
        XCTAssertTrue(unchanged.snapshot.clockValid)
        XCTAssertEqual(p.poll(now: start + fiveSecondTicks * 3), [.forceSelfExit70])
    }

    func testReadinessInvalidTimebaseForcesAtAdmissionAndReturnsQualifiedSnapshot() throws {
        let timebases: [(UInt32, UInt32)] = [(0, 1), (1, 0), (0, 0)]
        for pair in timebases {
            var p = AppLifecyclePolicy(timebaseNumerator: pair.0, timebaseDenominator: pair.1)
            let update = try p.beginReadiness(first, now: start)
            XCTAssertEqual(update.effects, [.forceSelfExit70])
            XCTAssertEqual(update.snapshot.phase, .forced)
            XCTAssertFalse(update.snapshot.clockValid)
            XCTAssertFalse(update.snapshot.fallbackArmed)
            XCTAssertTrue(update.snapshot.canceled)
            XCTAssertEqual(update.snapshot.observationTicks, start)
        }
    }

    func testReadinessClockRegressionCannotBeHiddenByFirstManualRequest() throws {
        var p = policy(); _ = try p.beginReadiness(first, now: start)
        _ = try p.checkReadiness(first, now: start + 100)
        XCTAssertEqual(p.request(.stop, now: start + 99), [.requestCancellation(runID: first), .forceSelfExit70])
        let update = try p.checkReadiness(first, now: start + 101)
        XCTAssertEqual(update.snapshot.phase, .forced)
        XCTAssertFalse(update.snapshot.clockValid)
        XCTAssertEqual(update.snapshot.observationTicks, start + 99)
        XCTAssertEqual(p.forceReason, .clockRegressed)
    }

    func testReadinessClockRegressionAfterCompletionStillForces() throws {
        var p = policy(); _ = try p.beginReadiness(first, now: start)
        _ = try p.completeReadiness(first, now: start + 100)
        let update = try p.checkReadiness(first, now: start + 99)
        XCTAssertEqual(update.effects, [.forceSelfExit70])
        XCTAssertTrue(update.snapshot.workCompleted)
        XCTAssertFalse(update.snapshot.clockValid)
        XCTAssertTrue(update.snapshot.canceled)
    }

    func testReadinessExactWideProductsAndNearMaximumStartAvoidOverflow() throws {
        let timebases: [(UInt32, UInt32)] = [(1, 1), (UInt32.max, UInt32.max)]
        for timebase in timebases {
            var p = AppLifecyclePolicy(timebaseNumerator: timebase.0, timebaseDenominator: timebase.1)
            let nearEnd = UInt64.max - AppLifecyclePolicy.readinessHorizonNanoseconds
            _ = try p.beginReadiness(first, now: nearEnd)
            XCTAssertFalse(try p.checkReadiness(first, now: nearEnd + AppLifecyclePolicy.readinessWorkNanoseconds - 1).snapshot.workBudgetExpired)
            XCTAssertTrue(try p.checkReadiness(first, now: nearEnd + AppLifecyclePolicy.readinessWorkNanoseconds).snapshot.workBudgetExpired)
            XCTAssertEqual(p.poll(now: UInt64.max - 1), [])
            XCTAssertEqual(p.poll(now: UInt64.max), [.forceSelfExit70])
        }
    }

    func testReadinessNonintegralWorkBoundaryUsesExactRationalComparison() throws {
        var p = AppLifecyclePolicy(timebaseNumerator: 3, timebaseDenominator: 1)
        _ = try p.beginReadiness(first, now: 0)
        XCTAssertFalse(try p.checkReadiness(first, now: 3_333_333_333).snapshot.workBudgetExpired)
        XCTAssertTrue(try p.checkReadiness(first, now: 3_333_333_334).snapshot.workBudgetExpired)
        XCTAssertEqual(p.poll(now: 4_999_999_999), [])
        XCTAssertEqual(p.poll(now: 5_000_000_000), [.forceSelfExit70])
    }
}
