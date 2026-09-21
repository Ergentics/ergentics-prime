import XCTest

@MainActor
final class DeltaPUDemoModelTests: XCTestCase {
    func testInitializationDoesNotRunAndIdleCancellationDoesNothing() {
        let model = DeltaPUDemoModel()
        XCTAssertEqual(model.phase, .idle)
        XCTAssertFalse(model.busy)
        XCTAssertNil(model.report)
        XCTAssertNil(model.failureMessage)
        model.cancel()
        XCTAssertEqual(model.phase, .idle)
        XCTAssertTrue(model.clear())
    }

    func testSparseRunPublishesOnlyVerifiedScenarioBoundResult() async throws {
        let model = DeltaPUDemoModel()
        let completion = try XCTUnwrap(model.run(.sparse))
        XCTAssertEqual(model.phase, .running)
        XCTAssertTrue(model.busy)
        XCTAssertNil(model.report)
        await completion.value
        XCTAssertEqual(model.phase, .verified)
        XCTAssertFalse(model.busy)
        XCTAssertNil(model.failureMessage)
        let report = try XCTUnwrap(model.report)
        XCTAssertEqual(report.scenario, .sparse)
        XCTAssertEqual(report.transition.work.nodesEvaluated, 3)
        XCTAssertEqual(report.verification.rows.filter { $0.status == .reused }.count, 61)
    }

    func testSynchronousAdmissionRejectsSecondRunBeforeObservation() async throws {
        let model = DeltaPUDemoModel()
        let first = try XCTUnwrap(model.run(.dense))
        XCTAssertNil(model.run(.sparse))
        XCTAssertFalse(model.clear())
        XCTAssertTrue(model.busy)
        await first.value
        XCTAssertEqual(model.report?.scenario, .dense)
        XCTAssertEqual(model.report?.transition.work.nodesEvaluated, 64)
        XCTAssertEqual(model.phase, .verified)
    }

    func testCancelSuppressesLatePublicationAndKeepsAdmissionClosedUntilCompletion() async throws {
        let model = DeltaPUDemoModel()
        let completion = try XCTUnwrap(model.run(.dense))
        model.cancel()
        XCTAssertEqual(model.phase, .cancelling)
        XCTAssertTrue(model.busy)
        XCTAssertNil(model.run(.sparse))
        XCTAssertFalse(model.clear())
        await completion.value
        XCTAssertEqual(model.phase, .cancelled)
        XCTAssertFalse(model.busy)
        XCTAssertNil(model.report)
        XCTAssertNil(model.failureMessage)
    }

    func testRepeatedCancelIsIdempotentAndFreshRunCanComplete() async throws {
        let model = DeltaPUDemoModel()
        let first = try XCTUnwrap(model.run(.sparse))
        model.cancel()
        model.cancel()
        await first.value
        XCTAssertEqual(model.phase, .cancelled)
        model.cancel()
        XCTAssertEqual(model.phase, .cancelled)
        let second = try XCTUnwrap(model.run(.dense))
        await second.value
        XCTAssertEqual(model.phase, .verified)
        XCTAssertEqual(model.report?.scenario, .dense)
    }

    func testCancellingCompletionHandlePropagatesToDetachedWorker() async throws {
        let model = DeltaPUDemoModel()
        let completion = try XCTUnwrap(model.run(.sparse))
        completion.cancel()
        await completion.value
        XCTAssertEqual(model.phase, .cancelled)
        XCTAssertFalse(model.busy)
        XCTAssertNil(model.report)
    }

    func testAlreadyCancelledCallerDoesNotAdmitWork() async {
        let model = DeltaPUDemoModel()
        let caller = Task { @MainActor in
            withUnsafeCurrentTask { $0?.cancel() }
            return model.run(.sparse) == nil
        }
        let rejected = await caller.value
        XCTAssertTrue(rejected)
        XCTAssertEqual(model.phase, .cancelled)
        XCTAssertFalse(model.busy)
        XCTAssertNil(model.report)
    }

    func testClearRemovesOnlyIdleResultAndNextRunStartsWithoutStalePresentation() async throws {
        let model = DeltaPUDemoModel()
        let first = try XCTUnwrap(model.run(.dense))
        await first.value
        let dense = try XCTUnwrap(model.report)
        XCTAssertTrue(model.clear())
        XCTAssertEqual(model.phase, .idle)
        XCTAssertNil(model.report)
        let second = try XCTUnwrap(model.run(.sparse))
        XCTAssertNil(model.report)
        await second.value
        XCTAssertEqual(dense.scenario, .dense)
        XCTAssertEqual(dense.transition.work.nodesEvaluated, 64)
        XCTAssertEqual(model.report?.scenario, .sparse)
        XCTAssertEqual(model.report?.transition.work.nodesEvaluated, 3)
    }

    func testStartingAnotherRunClearsPriorVerifiedResultSynchronously() async throws {
        let model = DeltaPUDemoModel()
        let first = try XCTUnwrap(model.run(.sparse))
        await first.value
        XCTAssertNotNil(model.report)
        let second = try XCTUnwrap(model.run(.dense))
        XCTAssertNil(model.report)
        XCTAssertNil(model.failureMessage)
        XCTAssertEqual(model.phase, .running)
        model.cancel() // Same operation used when the page disappears.
        await second.value
        XCTAssertNil(model.report)
        XCTAssertEqual(model.phase, .cancelled)
    }
}
