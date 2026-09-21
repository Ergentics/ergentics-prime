import Darwin
import Foundation
import XCTest

final class PrimeRuntimeTests: XCTestCase {
    private func fixture() throws -> Data {
        try JSONSerialization.data(withJSONObject: [
            "evidence_id": "ergentics_prime_native_decoder_maintained_runtime_initialization_v1",
            "bounded_mlx_runtime_initialization_established": true,
            "decoder_forward_observed": false,
            "checkpoint_io_observed": false,
            "sandbox_application_synchronization_lease": [
                "policy": "signed_sandbox_application_internal_synchronization_v1",
                "applicationIdentifier": "com.ergentics.provenance",
                "helperIdentifier": "com.ergentics.provenance.prime-runtime",
            ],
            "metal_device": ["index_zero_name": "Test device"],
            "metallib": ["sha256": String(repeating: "a", count: 64)],
        ])
    }

    func testReportPreservesNativeBytesWithoutClaimingInference() throws {
        let data = try fixture()
        let report = try PrimeRuntimeReport.decode(data, elapsedSeconds: 0.25)
        XCTAssertEqual(report.nativeEvidence, data)
        XCTAssertEqual(report.deviceName, "Test device")
        XCTAssertEqual(report.elapsedSeconds, 0.25)
    }

    func testIncompleteOrDifferentOperationCannotBecomeRuntimeSuccess() throws {
        let source = try JSONSerialization.jsonObject(with: fixture()) as! [String: Any]
        for key in ["evidence_id", "bounded_mlx_runtime_initialization_established", "metal_device", "metallib", "sandbox_application_synchronization_lease"] {
            var changed = source
            changed.removeValue(forKey: key)
            let data = try JSONSerialization.data(withJSONObject: changed)
            XCTAssertThrowsError(try PrimeRuntimeReport.decode(data, elapsedSeconds: 0))
        }
        for key in ["decoder_forward_observed", "checkpoint_io_observed"] {
            var changed = source
            changed[key] = true
            let data = try JSONSerialization.data(withJSONObject: changed)
            XCTAssertThrowsError(try PrimeRuntimeReport.decode(data, elapsedSeconds: 0))
        }
        for key in ["policy", "applicationIdentifier", "helperIdentifier"] {
            var changed = source
            var synchronization = source["sandbox_application_synchronization_lease"] as! [String: Any]
            synchronization[key] = "different-policy-or-identity"
            changed["sandbox_application_synchronization_lease"] = synchronization
            XCTAssertThrowsError(try PrimeRuntimeReport.decode(JSONSerialization.data(withJSONObject: changed), elapsedSeconds: 0))
        }
        XCTAssertThrowsError(try PrimeRuntimeReport.decode(Data(repeating: 32, count: 262_145), elapsedSeconds: 0))
        XCTAssertThrowsError(try PrimeRuntimeReport.decode(Data("{".utf8), elapsedSeconds: 0))
    }

    func testCancelledRequestDoesNotResolveOrLaunchHelper() {
        let cancellation = PrimeRuntimeCancellation()
        cancellation.cancel()
        XCTAssertThrowsError(try PrimeRuntimeBackend.check(cancellation: cancellation)) { error in
            XCTAssertTrue(error is CancellationError)
        }
    }

    @MainActor
    func testViewModelDoesNotLaunchUntilRequestedAndRejectsOverlap() async throws {
        let gate = PrimeRuntimeTestGate()
        let report = try PrimeRuntimeReport.decode(fixture(), elapsedSeconds: 0.1)
        let model = PrimeRuntimeModel(checker: { _ in gate.wait(); return report })
        XCTAssertFalse(model.busy)
        XCTAssertTrue(model.requestQuit())
        XCTAssertEqual(gate.calls, 0)
        let completion = try XCTUnwrap(model.check())
        XCTAssertTrue(model.busy)
        XCTAssertNil(model.check())
        gate.open()
        await completion.value
        XCTAssertFalse(model.busy)
        XCTAssertEqual(model.report, report)
        XCTAssertEqual(gate.calls, 1)
    }

    @MainActor
    func testCancellationDiscardsLateSuccessAndReopensAdmission() async throws {
        let gate = PrimeRuntimeTestGate()
        let report = try PrimeRuntimeReport.decode(fixture(), elapsedSeconds: 0.1)
        let model = PrimeRuntimeModel(checker: { _ in gate.wait(); return report })
        let completion = try XCTUnwrap(model.check())
        model.cancel()
        XCTAssertTrue(model.busy)
        XCTAssertNil(model.check())
        gate.open()
        await completion.value
        XCTAssertFalse(model.busy)
        XCTAssertNil(model.report)
        XCTAssertEqual(model.status, "Cancelled")
        let retry = try XCTUnwrap(model.check())
        await retry.value
        XCTAssertEqual(model.report, report)
    }

    @MainActor
    func testQuitRetriesOnlyAfterTheWorkerSettles() async throws {
        let gate = PrimeRuntimeTestGate()
        let report = try PrimeRuntimeReport.decode(fixture(), elapsedSeconds: 0.1)
        var quitCount = 0
        let model = PrimeRuntimeModel(checker: { _ in gate.wait(); return report }, finishQuit: { quitCount += 1 })
        let completion = try XCTUnwrap(model.check())
        XCTAssertFalse(model.requestQuit())
        XCTAssertEqual(quitCount, 0)
        gate.open()
        await completion.value
        XCTAssertEqual(quitCount, 1)
        XCTAssertNil(model.report)
        XCTAssertFalse(model.busy)
    }

    @MainActor
    func testCancellationCannotHideUnconfirmedCleanup() async throws {
        let gate = PrimeRuntimeTestGate()
        let model = PrimeRuntimeModel(checker: { _ in
            gate.wait()
            throw PrimeRuntimeBackend.CleanupFailure(detail: "Fixture cleanup was not confirmed.")
        })
        let completion = try XCTUnwrap(model.check())
        model.cancel()
        gate.open()
        await completion.value
        XCTAssertEqual(model.status, "Runtime shutdown needs attention")
        XCTAssertTrue(try XCTUnwrap(model.failure).contains("cleanup could not be confirmed"))
        XCTAssertNil(model.report)
    }

    func testUnconfirmedCleanupPermanentlyClosesRunAdmission() throws {
        let admission = PrimeRuntimeBackend.RunAdmission()
        try admission.enter()
        XCTAssertThrowsError(try admission.enter())
        admission.leave(cleanupConfirmed: true)
        try admission.enter()
        admission.leave(cleanupConfirmed: false)
        for _ in 0..<2 {
            XCTAssertThrowsError(try admission.enter()) { error in
                XCTAssertTrue(error is PrimeRuntimeBackend.CleanupFailure)
            }
        }
    }

    // This fixture is a separately compiled tiny C executable, never a shell or
    // the MLX helper. Its output is explicitly synthetic; these tests establish
    // only the backend's native process/pipe lifecycle.
    private func processFixture(mode: String) throws -> (helper: URL, root: URL) {
        guard let path = ProcessInfo.processInfo.environment["PRIME_RUNTIME_PROCESS_FIXTURE_PATH"] else {
            throw XCTSkip("Compile Tests/Fixtures/PrimeRuntimeProcess.c and supply PRIME_RUNTIME_PROCESS_FIXTURE_PATH. Focused native verification requires all four process tests to execute.")
        }
        XCTAssertTrue(path.hasPrefix("/"))
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("prime-process-test-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: false,
                                                attributes: [.posixPermissions: 0o700])
        try Data(mode.utf8).write(to: root.appendingPathComponent("fixture-mode"), options: .withoutOverwriting)
        return (URL(fileURLWithPath: path), root)
    }

    private func assertChildReaped(in root: URL, file: StaticString = #filePath, line: UInt = #line) throws {
        let pidText = try String(contentsOf: root.appendingPathComponent("helper.pid"), encoding: .utf8)
        let pid = try XCTUnwrap(pid_t(pidText.trimmingCharacters(in: .whitespacesAndNewlines)), file: file, line: line)
        var status: Int32 = 0
        XCTAssertEqual(waitpid(pid, &status, WNOHANG), -1, file: file, line: line)
        XCTAssertEqual(errno, ECHILD, "The backend must already have reaped its exact child.", file: file, line: line)
        XCTAssertEqual(kill(-pid, 0), -1, file: file, line: line)
        XCTAssertEqual(errno, ESRCH, "The original group must be observed absent.", file: file, line: line)
    }

    func testNativeRunNormalExitReapsExactChildAndReopensAdmission() throws {
        let fixture = try processFixture(mode: "normal")
        defer { try? FileManager.default.removeItem(at: fixture.root) }
        let admission = PrimeRuntimeBackend.RunAdmission()
        let report = try PrimeRuntimeBackend.run(helper: fixture.helper, root: fixture.root,
            cancellation: PrimeRuntimeCancellation(), timeoutSeconds: 3, admission: admission)
        XCTAssertEqual(report.deviceName, "Native process fixture")
        XCTAssertLessThan(report.elapsedSeconds, 3)
        XCTAssertTrue(admission.terminationAttempts.isEmpty, "An ordinary exit must not send an unnecessary KILL.")
        try assertChildReaped(in: fixture.root)
        try admission.enter()
        admission.leave(cleanupConfirmed: true)
    }

    func testNativeRunTimeoutFinishesCleanupWithinBound() throws {
        let fixture = try processFixture(mode: "linger")
        defer { try? FileManager.default.removeItem(at: fixture.root) }
        let start = ProcessInfo.processInfo.systemUptime
        let admission = PrimeRuntimeBackend.RunAdmission()
        XCTAssertThrowsError(try PrimeRuntimeBackend.run(helper: fixture.helper, root: fixture.root,
            cancellation: PrimeRuntimeCancellation(), timeoutSeconds: 0.2,
            admission: admission)) { error in
            XCTAssertFalse(error is PrimeRuntimeBackend.CleanupFailure)
            XCTAssertTrue(error.localizedDescription.contains("runtime check limit"))
        }
        XCTAssertEqual(admission.terminationAttempts.count, 1)
        XCTAssertEqual(admission.terminationAttempts.first?.result, 0)
        XCTAssertLessThan(ProcessInfo.processInfo.systemUptime - start, 3.5)
        try assertChildReaped(in: fixture.root)
    }

    func testNativeRunCancellationKillsAndReapsStartedChild() throws {
        let fixture = try processFixture(mode: "linger")
        defer { try? FileManager.default.removeItem(at: fixture.root) }
        let cancellation = PrimeRuntimeCancellation()
        let cancelled = DispatchSemaphore(value: 0)
        DispatchQueue.global().async {
            let deadline = ProcessInfo.processInfo.systemUptime + 2
            while !FileManager.default.fileExists(atPath: fixture.root.appendingPathComponent("helper.pid").path),
                  ProcessInfo.processInfo.systemUptime < deadline { Thread.sleep(forTimeInterval: 0.01) }
            cancellation.cancel()
            cancelled.signal()
        }
        let start = ProcessInfo.processInfo.systemUptime
        let admission = PrimeRuntimeBackend.RunAdmission()
        XCTAssertThrowsError(try PrimeRuntimeBackend.run(helper: fixture.helper, root: fixture.root,
            cancellation: cancellation, timeoutSeconds: 3,
            admission: admission)) { error in
            XCTAssertTrue(error is CancellationError)
        }
        XCTAssertEqual(admission.terminationAttempts.count, 1)
        XCTAssertEqual(admission.terminationAttempts.first?.result, 0)
        XCTAssertEqual(cancelled.wait(timeout: .now() + 0.5), .success)
        XCTAssertLessThan(ProcessInfo.processInfo.systemUptime - start, 4.5)
        try assertChildReaped(in: fixture.root)
    }

    func testNativeRunRetiresDescendantThatHoldsOutputPipes() throws {
        let fixture = try processFixture(mode: "descendant")
        defer { try? FileManager.default.removeItem(at: fixture.root) }
        let admission = PrimeRuntimeBackend.RunAdmission()
        let report = try PrimeRuntimeBackend.run(helper: fixture.helper, root: fixture.root,
            cancellation: PrimeRuntimeCancellation(), timeoutSeconds: 3,
            admission: admission)
        XCTAssertEqual(report.deviceName, "Native process fixture")
        XCTAssertLessThan(report.elapsedSeconds, 3)
        XCTAssertEqual(admission.terminationAttempts.count, 1)
        XCTAssertEqual(admission.terminationAttempts.first?.result, 0)
        try assertChildReaped(in: fixture.root)
        let childText = try String(contentsOf: fixture.root.appendingPathComponent("descendant.pid"), encoding: .utf8)
        let child = try XCTUnwrap(pid_t(childText.trimmingCharacters(in: .whitespacesAndNewlines)))
        XCTAssertEqual(kill(child, 0), -1)
        XCTAssertEqual(errno, ESRCH)
    }
}

private final class PrimeRuntimeTestGate: @unchecked Sendable {
    private let condition = NSCondition()
    private var opened = false
    private var count = 0
    var calls: Int { condition.lock(); defer { condition.unlock() }; return count }
    func wait() {
        condition.lock(); defer { condition.unlock() }
        count += 1
        let deadline = Date().addingTimeInterval(3)
        while !opened && condition.wait(until: deadline) {}
    }
    func open() { condition.lock(); opened = true; condition.broadcast(); condition.unlock() }
}
