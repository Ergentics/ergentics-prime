#if EPR_H3_QUALIFICATION_TESTS
import Foundation
import XCTest
import Darwin

// Pure fabricated value results. This suite never reserves a native owner,
// enters Hypervisor.framework, opens a journal/SQLite/file, or requests stop.
// SYNTHETIC schedules only: no Task, FD, clock sampling, OS or native calls.
final class H3QualificationApplicationStateTests: XCTestCase {
    private typealias Input = H3QualificationInputStateMachine
    private func input(_ role: Input.Role = .gate) throws -> Input {
        try Input(role: role, startTick: 1, numerator: 1, denominator: 1)
    }
    private func ready(_ value: inout Input) throws {
        try value.beginPoll(at: 2)
        try value.finishPoll(.ready, at: 2)
    }
    private func read(_ result: Input.ReadResult, value: inout Input, count: Int = 42) throws {
        try value.beginRead(at: 2, requested: count)
        try value.finishRead(result)
    }

    func testDeadlineExactCheckedTimebaseAndOverflow() throws {
        XCTAssertEqual(try input().deadline, 6_000_000_001)
        XCTAssertEqual(try input(.cancellation).deadline, 10_000_000_001)
        XCTAssertEqual(try H3QualificationDeadline.end(start: 1, seconds: 6, numerator: 125, denominator: 3), 144_000_001)
        for (start, numerator, denominator) in [(UInt64(0), UInt32(1), UInt32(1)), (1, 0, 1), (1, 1, 0), (.max, 1, 1), (1, 1, .max)] {
            XCTAssertThrowsError(try Input(role: .gate, startTick: start, numerator: numerator, denominator: denominator))
        }
        XCTAssertThrowsError(try H3QualificationDeadline.end(start: 1, seconds: .max, numerator: 1, denominator: 1))
    }

    func testGateExactBytesRequireEOFAndCannotBeReused() throws {
        var gate = try input()
        for _ in 0..<41 {
            try ready(&gate)
            try read(.bytes(1), value: &gate, count: 42 - gate.offset)
        }
        XCTAssertEqual(gate.offset, 41)
        XCTAssertEqual(gate.phase, .pollable)
        try ready(&gate); try read(.eof, value: &gate, count: 1)
        XCTAssertEqual(gate.phase, .gateEOF)
        XCTAssertEqual(gate.readCalls, 42)
        XCTAssertThrowsError(try gate.beginPoll(at: 3))
        XCTAssertEqual(gate.phase, .rejected)
        XCTAssertThrowsError(try gate.observeClock(4))
    }

    func testGateEarlyEOFExtraByteAndOverReturnReject() throws {
        for length in 0..<41 {
            var gate = try input()
            if length > 0 { try ready(&gate); try read(.bytes(length), value: &gate) }
            try ready(&gate)
            XCTAssertThrowsError(try read(.eof, value: &gate, count: 42 - length))
        }
        for count in [0, 42, 43, Int.max] {
            var gate = try input(); try ready(&gate)
            XCTAssertThrowsError(try read(.bytes(count), value: &gate))
        }
        var trailing = try input(); try ready(&trailing); try read(.bytes(41), value: &trailing)
        try ready(&trailing)
        XCTAssertThrowsError(try read(.bytes(1), value: &trailing, count: 1))
    }

    func testGateAndMonitorEnforceOrderAndNoZeroRequest() throws {
        for role in [Input.Role.gate, .cancellation] {
            var value = try input(role)
            XCTAssertThrowsError(try value.beginRead(at: 2, requested: 1))
            value = try input(role)
            XCTAssertThrowsError(try value.finishRead(.eof))
            value = try input(role)
            XCTAssertThrowsError(try value.finishPoll(.ready, at: 2))
            value = try input(role); try ready(&value)
            XCTAssertThrowsError(try value.beginRead(at: 2, requested: 0))
            value = try input(role); try ready(&value)
            XCTAssertThrowsError(try value.beginRead(at: 2, requested: role == .gate ? 43 : 42))
        }
    }

    func testGateEAGAINReturnsToPollAndEINTRRetriesReadyRead() throws {
        var gate = try input()
        try ready(&gate); try read(.again, value: &gate)
        XCTAssertEqual(gate.phase, .pollable)
        XCTAssertEqual(gate.offset, 0)
        try ready(&gate); try read(.interrupted, value: &gate)
        XCTAssertEqual(gate.phase, .readable)
        try read(.bytes(41), value: &gate)
        try ready(&gate); try read(.eof, value: &gate, count: 1)
        XCTAssertEqual(gate.phase, .gateEOF)
        XCTAssertEqual(gate.pollCalls, 3)
        XCTAssertEqual(gate.readCalls, 4)
    }

    func testPollAndReadEINTRExhaustionStopsBeforeSixtyFifthCall() throws {
        for role in [Input.Role.gate, .cancellation] {
            var polls = try input(role)
            for _ in 0..<64 {
                try polls.beginPoll(at: 2); try polls.finishPoll(.interrupted, at: 2)
            }
            XCTAssertThrowsError(try polls.beginPoll(at: 2))
            XCTAssertEqual(polls.pollCalls, 64)
            var reads = try input(role); try ready(&reads)
            for _ in 0..<64 { try read(.interrupted, value: &reads, count: role == .gate ? 42 : 41) }
            XCTAssertThrowsError(try reads.beginRead(at: 2, requested: 1))
            XCTAssertEqual(reads.readCalls, 64)
        }
    }

    func testOrdinaryPollBudgetsAndExactDeadlineAlwaysTerminate() throws {
        for role in [Input.Role.gate, .cancellation] {
            var polls = try input(role)
            let limit = role == .gate ? 601 : 1001
            for _ in 0..<limit { try polls.beginPoll(at: 2); try polls.finishPoll(.timeout, at: 2) }
            XCTAssertThrowsError(try polls.beginPoll(at: 2))
            XCTAssertEqual(polls.pollCalls, UInt32(limit))
            var deadline = try input(role)
            XCTAssertThrowsError(try deadline.beginPoll(at: deadline.deadline))
            var returning = try input(role); try returning.beginPoll(at: 2)
            XCTAssertThrowsError(try returning.finishPoll(.ready, at: returning.deadline))
            var backward = try input(role); try backward.beginPoll(at: 3)
            XCTAssertThrowsError(try backward.finishPoll(.timeout, at: 2))
        }
    }

    func testMonitorAnyByteEOFOrReadFailureWinsWithoutFrameParsing() throws {
        for observation in [Input.ReadResult.bytes(1), .bytes(39), .bytes(40), .bytes(41), .eof, .failed] {
            var value = try input(.cancellation); try ready(&value)
            try read(observation, value: &value, count: 41)
            XCTAssertEqual(value.phase, .cancellationObserved)
            XCTAssertThrowsError(try value.beginRead(at: 2, requested: 1))
        }
        for role in [Input.Role.gate, .cancellation] {
            var failure = try input(role); try failure.beginPoll(at: 2)
            XCTAssertThrowsError(try failure.finishPoll(.failed, at: 2))
        }
    }

    func testBarrierCompletionWinsBeforeReadyReadAndJoinsExactHandle() throws {
        var barrier = H3QualificationBarrierStateMachine()
        XCTAssertThrowsError(try barrier.claimCompletion())
        try barrier.install(identity: 17)
        XCTAssertEqual(try barrier.claimCompletion(), .completion)
        XCTAssertFalse(try barrier.beginRead())
        XCTAssertFalse(barrier.permitsReport)
        XCTAssertThrowsError(try barrier.join(identity: 18, fdClosed: true, handleCanceled: true))
        XCTAssertThrowsError(try barrier.join(identity: 17, fdClosed: false, handleCanceled: true))
        XCTAssertThrowsError(try barrier.join(identity: 17, fdClosed: true, handleCanceled: false))
        try barrier.join(identity: 17, fdClosed: true, handleCanceled: true)
        XCTAssertTrue(barrier.permitsReport)
        XCTAssertThrowsError(try barrier.claimCompletion())
        XCTAssertThrowsError(try barrier.join(identity: 17, fdClosed: true, handleCanceled: true))
    }

    func testBarrierReadAndLatchCannotBeInterposedOrRouteUnderLock() throws {
        var barrier = H3QualificationBarrierStateMachine(); try barrier.install(identity: 1)
        XCTAssertTrue(try barrier.beginRead())
        XCTAssertThrowsError(try barrier.claimCompletion())
        XCTAssertThrowsError(try barrier.routeCancellation())
        XCTAssertThrowsError(try barrier.cancelForInternalFailure())
        try barrier.finishRead(cancellationObserved: true)
        XCTAssertEqual(try barrier.claimCompletion(), .cancellation)
        XCTAssertThrowsError(try barrier.join(identity: 1, fdClosed: true, handleCanceled: false))
        try barrier.routeCancellation()
        XCTAssertThrowsError(try barrier.routeCancellation())
        XCTAssertThrowsError(try barrier.join(identity: 1, fdClosed: true, handleCanceled: true))
        try barrier.join(identity: 1, fdClosed: true, handleCanceled: false)
        XCTAssertFalse(barrier.permitsReport)
    }

    func testBarrierEAGAINReleasesLockAndInternalFailureNeverReports() throws {
        var value = H3QualificationBarrierStateMachine(); try value.install(identity: 1)
        XCTAssertTrue(try value.beginRead()); try value.finishRead(cancellationObserved: false)
        XCTAssertEqual(try value.claimCompletion(), .completion)
        try value.join(identity: 1, fdClosed: true, handleCanceled: true)
        XCTAssertTrue(value.permitsReport)
        var canceled = H3QualificationBarrierStateMachine(); try canceled.install(identity: 2)
        try canceled.cancelForInternalFailure(); try canceled.routeCancellation()
        XCTAssertEqual(try canceled.claimCompletion(), .cancellation)
        try canceled.join(identity: 2, fdClosed: true, handleCanceled: false)
        XCTAssertFalse(canceled.permitsReport)
    }

    func testActivationSameIdentitiesTimebaseAndInertFrameworkEvents() throws {
        var trace = H3QualificationActivationTrace(coordinator: 1, model: 2, lab: 3, owner: 4)
        XCTAssertThrowsError(try trace.observe(.gateAccepted(numerator: 125, denominator: 3)))
        XCTAssertThrowsError(try trace.observe(.entered(coordinator: 9, model: 2, lab: 3, owner: 4)))
        try trace.observe(.entered(coordinator: 1, model: 2, lab: 3, owner: 4))
        XCTAssertThrowsError(try trace.observe(.entered(coordinator: 1, model: 2, lab: 3, owner: 4)))
        XCTAssertThrowsError(try trace.observe(.lifecycleInstalled(owner: 4, controller: 5, numerator: 125, denominator: 3)))
        try trace.observe(.gateAccepted(numerator: 125, denominator: 3))
        XCTAssertThrowsError(try trace.observe(.lifecycleInstalled(owner: 9, controller: 5, numerator: 125, denominator: 3)))
        XCTAssertThrowsError(try trace.observe(.lifecycleInstalled(owner: 4, controller: 5, numerator: 126, denominator: 3)))
        XCTAssertThrowsError(try trace.observe(.lifecycleInstalled(owner: 4, controller: 0, numerator: 125, denominator: 3)))
        try trace.observe(.lifecycleInstalled(owner: 4, controller: 5, numerator: 125, denominator: 3))
        XCTAssertThrowsError(try trace.observe(.lifecycleInstalled(owner: 4, controller: 5, numerator: 125, denominator: 3)))
        XCTAssertThrowsError(try trace.observe(.monitorInstalled(6)))
        try trace.observe(.exporterAdmitted); try trace.observe(.monitorInstalled(6)); try trace.observe(.signingReturned)
        let snapshot = trace
        try trace.observe(.titlebarClosed); try trace.observe(.delegateQuit); try trace.observe(.parentTaskCanceled)
        XCTAssertEqual(trace, snapshot)
        XCTAssertThrowsError(try trace.observe(.ordinaryFallthrough))
        XCTAssertThrowsError(try trace.observe(.signingReturned))
    }

    func testApplicationQualificationGrammarIsExplicitAndAbsentFromOrdinaryParsing() throws {
        let nonce = String(repeating: "a0", count: 32)
        for mode in H3QualificationMode.allCases {
            let token = mode == .admissionOnly ? "--h3-qualification-admission-once" : "--h3-qualification-guest-once"
            let expected: DevelopmentLaunch.Mode = mode == .admissionOnly
                ? .h3QualificationAdmission(nonce: nonce) : .h3QualificationGuest(nonce: nonce)
            XCTAssertEqual(DevelopmentLaunch.evaluate(arguments: [token, nonce], qualificationEnabled: true), expected)
            XCTAssertEqual(DevelopmentLaunch.evaluate(arguments: [token, nonce], qualificationEnabled: false), .invalid)
            XCTAssertEqual(DevelopmentLaunch.parse(arguments: [token, nonce]), .invalid)
            let invalid: [[String]] = [[], [token], [nonce, token], [token, nonce, "extra"],
                [token, nonce.uppercased()], [token, String(nonce.dropLast())], [token, nonce + "0"],
                [token, String(repeating: "g", count: 64)], [token, String(repeating: "é", count: 32)],
                [token, " " + String(nonce.dropFirst())], [token + "=", nonce], ["--run-fixed-guest-once", nonce]]
            for arguments in invalid {
                XCTAssertEqual(DevelopmentLaunch.evaluate(arguments: arguments, qualificationEnabled: true), .invalid)
            }
        }
        XCTAssertEqual(DevelopmentLaunch.evaluate(arguments: [], qualificationEnabled: false), .ordinary)
        XCTAssertEqual(DevelopmentLaunch.parse(arguments: []), .ordinary)
    }

    func testGateIdentityChangesForEitherModeOrAnyNonceByte() throws {
        let nonce = String(repeating: "00", count: 32)
        let expected = try H3QualificationProtocol.gateFrame(mode: .admissionOnly, nonce: nonce)
        XCTAssertEqual(expected.count, 41)
        XCTAssertEqual(expected.prefix(8), Data("EPRH3G01".utf8))
        XCTAssertNotEqual(expected, try H3QualificationProtocol.gateFrame(mode: .guest, nonce: nonce))
        for offset in 0..<32 {
            var changed = Data(repeating: 0, count: 32); changed[offset] = 1
            XCTAssertNotEqual(expected, try H3QualificationProtocol.gateFrame(mode: .admissionOnly,
                nonce: H3QualificationProtocol.hex(changed)))
        }
        for count in [0, 1, 31, 33, 64] {
            XCTAssertThrowsError(try H3QualificationProtocol.gateFrame(mode: .guest, nonce: String(repeating: "a0", count: count)))
        }
    }

    func testFrameworkCancellationIsInertAtEveryActivationBoundary() throws {
        var trace = H3QualificationActivationTrace(coordinator: 1, model: 2, lab: 3, owner: 4)
        let events: [H3QualificationActivationTrace.Event] = [
            .entered(coordinator: 1, model: 2, lab: 3, owner: 4),
            .gateAccepted(numerator: 1, denominator: 1),
            .lifecycleInstalled(owner: 4, controller: 5, numerator: 1, denominator: 1),
            .exporterAdmitted, .monitorInstalled(6), .signingReturned]
        for event in events {
            let before = trace
            try trace.observe(.parentTaskCanceled); try trace.observe(.titlebarClosed); try trace.observe(.delegateQuit)
            XCTAssertEqual(trace, before)
            try trace.observe(event)
        }
        let final = trace
        try trace.observe(.parentTaskCanceled); try trace.observe(.titlebarClosed); try trace.observe(.delegateQuit)
        XCTAssertEqual(trace, final)
    }

    func testEveryWorkerTagStatePairAndCancellationWinner() throws {
        typealias R = H3QualificationReservationStateMachine
        typealias W = H3QualificationWorkerOutcome
        typealias D = H3QualificationWorkerPolicy.CompletionDecision
        let presentation = try H3QualificationReplay.preparationPresentation(error: 12)
        // Opaque synthetic worker payload: no claim that it is a valid native
        // capture. Native bytes/presentation admission has its separate matrix.
        let native = W.nativeReturned(capture: .init(wire: .object([:])), presentation: presentation)
        var states = [R(policy: .qualificationChecked)]
        for (token, error) in [(false, Int32(12)), (false, 0), (true, 12), (true, 0)] {
            var state = R(policy: .qualificationChecked)
            try state.recordReserve(tokenPresent: token, error: error); states.append(state)
        }
        var sentinel = states[1]; _ = try sentinel.beginCheckedRelease(tokenPresent: false); states.append(sentinel)
        var released = states[4]; _ = try released.beginCheckedRelease(tokenPresent: true)
        try released.finishCheckedRelease(status: 0); states.append(released)
        XCTAssertEqual(states.count, 7)
        for observed in states {
            var cases: [(W, Bool, D)] = [(native, observed.state == .acquired, .releaseToken)]
            for error: Int32 in [-1, 0, 12, 13] {
                cases.append((.preparationFailed(preparationError: error, presentation: presentation),
                              observed.state == .failedReserve && error == observed.observedError && error > 0, .releaseSentinel))
            }
            for declared in states {
                cases.append((.canceledBeforeNative(reservationState: declared.state),
                    declared.state == observed.state && (declared.state == .unprepared || declared.state == .acquired), .internalFailure))
                for error in [observed.observedError, observed.observedError + 1] {
                    cases.append((.invalidReservation(reservationState: declared.state, observedError: error),
                        declared.state == observed.state && error == observed.observedError &&
                            (declared.state == .invalidReserveNoToken || declared.state == .invalidReserveWithToken), .rejectStart))
                }
            }
            for (outcome, matches, completionDecision) in cases {
                for first in [false, true] {
                    let expected: D = !matches ? .internalFailure : (first ? completionDecision : .cancellation)
                    XCTAssertEqual(H3QualificationWorkerPolicy.decision(outcome: outcome, reservation: observed, completionFirst: first), expected)
                }
            }
        }
        var ordinary = R(policy: .ordinaryDeinit); try ordinary.recordReserve(tokenPresent: true, error: 0)
        for first in [false, true] {
            XCTAssertEqual(H3QualificationWorkerPolicy.decision(outcome: native, reservation: ordinary, completionFirst: first), .internalFailure)
        }
    }

    func testNoHypervisorQueryRequiresNoCopiedCapabilities() {
        let capabilities = H3QualificationCapabilities(hostSupported: 1, supportStatus: 0, supportSize: 4,
            supportError: 0, signingAdmitted: 1, signingError: 0, queriesEntered: 1,
            vcpuStatus: 0, ipaStatus: 0, maxVCPUs: 1, maxIPABits: 36)
        for result: Int32 in [-1, 0, 1] {
            let error: Int32 = result == -1 ? -50 : 0
            XCTAssertEqual(ProvenanceHostInspectionResult.classify(nativeResult: result, nativeError: error,
                queryHypervisor: false, capabilities: capabilities),
                .incomplete(reason: .unexpectedCapabilities, nativeResult: result, nativeError: error))
        }
        XCTAssertEqual(ProvenanceHostInspectionResult.classify(nativeResult: 1, nativeError: 0,
            queryHypervisor: true, capabilities: capabilities),
            .assessed(nativeResult: 1, nativeError: 0, status: .admitted, capabilities: capabilities))
    }

    func testCapturedStreamRejectsDecodedOverBoundBeforeBase64Allocation() throws {
        for count in [0, 65_535, 65_536, 65_537, 65_538, 65_539] {
            let bytes = Data(repeating: 0, count: count)
            let stream: H3QualificationJSONValue = .object([
                "base64": .string(bytes.base64EncodedString()), "byte_count": .integer(Int64(min(count, 65_536))),
                "sha256": .string(H3QualificationProtocol.hash(bytes)), "truncated": .bool(false)])
            if count <= 65_536 { XCTAssertNoThrow(try H3QualificationWire.validate(stream, schema: "captured_stream")) }
            else { XCTAssertThrowsError(try H3QualificationWire.validateStructure(stream, schema: "captured_stream")) }
        }
    }
}

/// The freeze's sole live-I/O exception: fresh, owned regular files only.
/// No Task, pipe, process, native owner, signing, guest, or ambient path access.
final class H3QualificationExportTests: XCTestCase {
    private func withFile(_ body: (Int32, String) throws -> Void) throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("h3-export-" + UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: false,
                                               attributes: [.posixPermissions: 0o700])
        defer { try? FileManager.default.removeItem(at: root) }
        let path = root.appendingPathComponent("frame").path
        let fd = Darwin.open(path, O_RDWR | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC | O_NONBLOCK, mode_t(0o600))
        guard fd >= 0 else { throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno)) }
        defer { XCTAssertEqual(Darwin.close(fd), 0) }
        try body(fd, path)
    }

    private func frame(_ payload: Data = Data("{}".utf8)) -> Data {
        Data(("EPRH3I01" + String(format: "%08x", payload.count)).utf8) + payload
    }

    private func contents(_ fd: Int32, count: Int) throws -> Data {
        var bytes = Data(count: count)
        try bytes.withUnsafeMutableBytes { buffer in
            var transfer = H3QualificationExportTransferStateMachine(totalBytes: count)
            while transfer.offset < count {
                guard transfer.canAttempt else { throw NSError(domain: "H3QualificationExportTests", code: 1) }
                let offset = transfer.offset
                let result = Darwin.pread(fd, buffer.baseAddress!.advanced(by: offset), count - offset, off_t(offset))
                _ = try transfer.consume(count: result, error: result < 0 ? errno : 0, requested: count - offset)
            }
        }
        var extra: UInt8 = 0
        XCTAssertEqual(Darwin.pread(fd, &extra, 1, off_t(count)), 0)
        return bytes
    }

    func testQualificationExportSyncsReadsBackAndConsumesOnce() throws {
        try withFile { fd, _ in
            let writer = try DevelopmentRustBootExport(h3QualificationTestDescriptor: fd)
            let bytes = frame(Data("{\"message\":\"bounded\"}".utf8))
            let result = try writer.exportH3Qualification(frame: bytes)
            XCTAssertEqual(result.bytes, bytes.count)
            XCTAssertEqual(result.sha256, H3QualificationProtocol.hash(bytes))
            XCTAssertEqual(result.identity, writer.identity)
            XCTAssertEqual(result.fsyncStatus, 0); XCTAssertEqual(result.fullSyncStatus, 0)
            XCTAssertEqual(try contents(fd, count: bytes.count), bytes)
            XCTAssertEqual(Darwin.lseek(fd, 0, SEEK_CUR), off_t(bytes.count))
            XCTAssertThrowsError(try writer.exportH3Qualification(frame: bytes)) { error in
                XCTAssertEqual((error as? DevelopmentRustBootExport.Failure)?.stage, "already-consumed")
            }
            XCTAssertEqual(try contents(fd, count: bytes.count), bytes)
        }
    }

    func testQualificationExactMaximumFrameAndOneByteOver() throws {
        let payload = Data(("{\"v\":\"" + String(repeating: "x", count: 65_528) + "\"}").utf8)
        XCTAssertEqual(payload.count, 65_536)
        try withFile { fd, _ in
            let bytes = frame(payload)
            XCTAssertEqual(bytes.count, 65_552)
            let result = try DevelopmentRustBootExport(h3QualificationTestDescriptor: fd).exportH3Qualification(frame: bytes)
            XCTAssertEqual(result.bytes, 65_552)
            XCTAssertEqual(try contents(fd, count: bytes.count), bytes)
        }
        try withFile { fd, _ in
            let writer = try DevelopmentRustBootExport(h3QualificationTestDescriptor: fd)
            XCTAssertThrowsError(try writer.exportH3Qualification(frame: frame(payload) + Data([0])))
            var value = stat(); XCTAssertEqual(Darwin.fstat(fd, &value), 0); XCTAssertEqual(value.st_size, 0)
        }
    }

    func testMalformedQualificationFramesConsumeWithoutWriting() throws {
        let invalid = [Data(), Data("EPRH3I0100000000".utf8),
                       Data("EPRH3I010000000A{\"x\":true}".utf8),
                       Data("EPRH3I0200000002{}".utf8),
                       frame() + Data([10]), Data(frame().dropLast()),
                       frame(Data("[]".utf8)), frame(Data("null".utf8)),
                       frame(Data("{ \"x\":1}".utf8)), frame(Data("{\"x\":1,\"x\":2}".utf8)),
                       frame(Data("{\"z\":1,\"a\":2}".utf8)), frame(Data([123, 0xff, 125]))]
        for bytes in invalid {
            try withFile { fd, _ in
                let writer = try DevelopmentRustBootExport(h3QualificationTestDescriptor: fd)
                XCTAssertThrowsError(try writer.exportH3Qualification(frame: bytes))
                XCTAssertThrowsError(try writer.exportH3Qualification(frame: frame())) { error in
                    XCTAssertEqual((error as? DevelopmentRustBootExport.Failure)?.stage, "already-consumed")
                }
                var value = stat(); XCTAssertEqual(Darwin.fstat(fd, &value), 0)
                XCTAssertEqual(value.st_size, 0); XCTAssertEqual(Darwin.lseek(fd, 0, SEEK_CUR), 0)
            }
        }
    }

    func testExportPoliciesRejectBothCrossPolicyDirections() throws {
        let rust = DevelopmentRustBootExport.prefix + Data("{}\n".utf8)
        try withFile { fd, _ in
            let writer = try DevelopmentRustBootExport(h3QualificationTestDescriptor: fd)
            XCTAssertThrowsError(try writer.export(frame: rust)) { error in
                XCTAssertEqual((error as? DevelopmentRustBootExport.Failure)?.stage, "wrong-export-policy")
            }
            XCTAssertThrowsError(try writer.exportH3Qualification(frame: frame()))
        }
        try withFile { fd, _ in
            let writer = try DevelopmentRustBootExport(testDescriptor: fd)
            XCTAssertThrowsError(try writer.exportH3Qualification(frame: frame())) { error in
                XCTAssertEqual((error as? DevelopmentRustBootExport.Failure)?.stage, "wrong-export-policy")
            }
            XCTAssertThrowsError(try writer.export(frame: rust))
        }
    }

    func testQualificationAdmissionRejectsPermissionsLinksAndAppend() throws {
        for mode in [mode_t(0o400), mode_t(0o640), mode_t(0o660), mode_t(0o1600)] {
            try withFile { fd, _ in
                XCTAssertEqual(Darwin.fchmod(fd, mode), 0)
                XCTAssertThrowsError(try DevelopmentRustBootExport(h3QualificationTestDescriptor: fd))
            }
        }
        try withFile { fd, path in
            XCTAssertEqual(Darwin.link(path, path + "-link"), 0)
            XCTAssertThrowsError(try DevelopmentRustBootExport(h3QualificationTestDescriptor: fd))
        }
        try withFile { fd, _ in
            XCTAssertEqual(Darwin.fcntl(fd, F_SETFL, Darwin.fcntl(fd, F_GETFL) | O_APPEND), 0)
            XCTAssertThrowsError(try DevelopmentRustBootExport(h3QualificationTestDescriptor: fd))
        }
    }

    func testQualificationAdmissionRejectsLengthOrOffset() throws {
        try withFile { fd, _ in
            XCTAssertEqual(Darwin.ftruncate(fd, 1), 0)
            XCTAssertThrowsError(try DevelopmentRustBootExport(h3QualificationTestDescriptor: fd))
        }
        try withFile { fd, _ in
            XCTAssertEqual(Darwin.lseek(fd, 1, SEEK_SET), 1)
            XCTAssertThrowsError(try DevelopmentRustBootExport(h3QualificationTestDescriptor: fd))
        }
    }

    func testQualificationRevalidationRejectsEachPrewriteDrift() throws {
        for mutation in 0..<5 {
            try withFile { fd, path in
                let writer = try DevelopmentRustBootExport(h3QualificationTestDescriptor: fd)
                switch mutation {
                case 0: XCTAssertEqual(Darwin.fchmod(fd, 0o640), 0)
                case 1: XCTAssertEqual(Darwin.link(path, path + "-link"), 0)
                case 2: XCTAssertEqual(Darwin.fcntl(fd, F_SETFL, Darwin.fcntl(fd, F_GETFL) & ~O_NONBLOCK), 0)
                case 3: XCTAssertEqual(Darwin.ftruncate(fd, 1), 0)
                default: XCTAssertEqual(Darwin.lseek(fd, 1, SEEK_SET), 1)
                }
                XCTAssertThrowsError(try writer.exportH3Qualification(frame: frame())) { error in
                    XCTAssertEqual((error as? DevelopmentRustBootExport.Failure)?.bytesWritten, 0)
                }
                XCTAssertThrowsError(try writer.exportH3Qualification(frame: frame()))
            }
        }
    }

    func testQualificationRevalidationRejectsFreshVnodeSubstitution() throws {
        try withFile { fd, _ in
            let writer = try DevelopmentRustBootExport(h3QualificationTestDescriptor: fd)
            try withFile { replacement, _ in
                var replacementStat = stat(); XCTAssertEqual(Darwin.fstat(replacement, &replacementStat), 0)
                XCTAssertNotEqual(writer.identity.inode, UInt64(replacementStat.st_ino))
                XCTAssertEqual(Darwin.dup2(replacement, fd), fd)
                XCTAssertThrowsError(try writer.exportH3Qualification(frame: frame())) { error in
                    XCTAssertEqual((error as? DevelopmentRustBootExport.Failure)?.stage, "before-write-changed")
                    XCTAssertEqual((error as? DevelopmentRustBootExport.Failure)?.bytesWritten, 0)
                }
                XCTAssertEqual(Darwin.fstat(replacement, &replacementStat), 0)
                XCTAssertEqual(replacementStat.st_size, 0)
            }
        }
    }

    func testTransferBudgetIncludesSixteenInterruptionsAndOneEOFObservation() throws {
        var transfer = H3QualificationExportTransferStateMachine(totalBytes: 1)
        for _ in 0..<16 {
            XCTAssertTrue(transfer.canAttempt)
            XCTAssertFalse(try transfer.consume(count: -1, error: EINTR, requested: 1))
        }
        XCTAssertFalse(transfer.canAttempt)
        XCTAssertEqual(transfer.attempts, 16)
        var end = H3QualificationExportTransferStateMachine(totalBytes: 1)
        try end.consumeEOF(count: 0, error: 0)
        XCTAssertThrowsError(try end.consumeEOF(count: 0, error: 0))
        for (count, error) in [(1, Int32(0)), (-1, EINTR), (-1, EIO), (0, EIO)] {
            var bad = H3QualificationExportTransferStateMachine(totalBytes: 1)
            XCTAssertThrowsError(try bad.consumeEOF(count: count, error: error))
            XCTAssertThrowsError(try bad.consumeEOF(count: 0, error: 0))
        }
    }
}

final class H3QualificationRunnerTests: XCTestCase {
    override func setUpWithError() throws {
        executionTimeAllowance = 20
    }

    private let pageBytes = 16_384
    private let sourceGeneration: UInt64 = 9
    private let targetGeneration: UInt64 = 10

    private var image: Data {
        let words: [UInt32] = [
            0xd2880000, 0xf2a20000, 0xd2900001, 0xf2a20001,
            0xd2980003, 0xf2a20003, 0xc8dffc04, 0xf100049f,
            0x54000321, 0xf9400405, 0xf10004bf, 0x540002c1,
            0xf9400806, 0xf9400c07, 0x8b0700c6, 0xf9000425,
            0xf9000826, 0xf9000c3f, 0xc89ffc24, 0xd5033f9f,
            0xb9000064, 0xf100a8df, 0x54000161, 0xf9400828,
            0xf100a91f, 0x54000101, 0x91000508, 0xf9000c28,
            0xd2800044, 0xc89ffc24, 0xd5033f9f, 0xb9000064,
            0xd43bd5a0, 0xd42175a0,
        ]
        return Data(words.flatMap { word in
            (0..<4).map { UInt8(truncatingIfNeeded: word >> ($0 * 8)) }
        })
    }

    private func page(_ prefix: Data) -> Data {
        var result = Data(repeating: 0, count: pageBytes)
        result.replaceSubrange(0..<prefix.count, with: prefix)
        return result
    }

    private func appendBE(_ value: UInt64, to data: inout Data) {
        for index in (0..<8).reversed() {
            data.append(UInt8(truncatingIfNeeded: value >> (index * 8)))
        }
    }

    private func bytes(_ hex: String) -> Data {
        let characters = Array(hex.utf8)
        func nibble(_ value: UInt8) -> UInt8 { value <= 57 ? value - 48 : value - 87 }
        return Data(stride(from: 0, to: characters.count, by: 2).map {
            (nibble(characters[$0]) << 4) | nibble(characters[$0 + 1])
        })
    }

    private func store<T>(_ data: Data, in tuple: inout T) {
        withUnsafeMutableBytes(of: &tuple) { destination in
            XCTAssertEqual(destination.count, data.count)
            destination.copyBytes(from: data)
        }
    }

    private func load<T>(_ tuple: inout T) -> Data {
        withUnsafeBytes(of: &tuple) { Data($0) }
    }

    private func phase(generation: UInt64, pc: UInt64, x4: UInt64,
                       reads: UInt32, entry: UInt64, exit: UInt64) -> EPRGuestH3PhaseResult {
        var result = EPRGuestH3PhaseResult()
        result.run_entries = 1
        result.mappings_entered = 3
        result.register_set_calls = 36
        result.register_read_calls = reads
        result.conserved = 1
        result.generation = generation
        result.entry_ticks = entry
        result.exit_ticks = exit
        result.exception_reason = 1
        result.syndrome = 0x9384_0044
        result.pc = pc
        result.fault_ipa = 0x1000_c000
        result.fault_virtual_address = 0x1000_c000
        result.x4 = x4
        return result
    }

    private func setCheckpointPass(_ result: inout EPRGuestH3CursorResumeResult) {
        result.checkpoint_diagnostic.schema_version = 1
        result.checkpoint_diagnostic.required_mask = 0x1ff
        result.checkpoint_diagnostic.evaluated_mask = 0x1ff
        result.checkpoint_diagnostic.passed_mask = 0x1ff
        result.checkpoint_diagnostic.gpr_mismatch_mask = 0
        result.checkpoint_diagnostic.reserved_zero = 0
        result.checkpoint_diagnostic.checkpoint_sequence = 1
        result.checkpoint_diagnostic.gprs = (
            0x1000_4000, 0x1000_8000, 0, 0x1000_c000, 1, 1, 42, 23,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0
        )
        result.checkpoint_diagnostic.cpsr = 0x6000_03c5
        result.checkpoint_diagnostic.sctlr = 0x30d0_0980
        result.checkpoint_diagnostic.sp = 0x1000_bff0
        result.checkpoint_diagnostic.vbar = 0
        result.checkpoint_diagnostic.page_witnesses.0.first_mismatch_offset = UInt32.max
        result.checkpoint_diagnostic.page_witnesses.1.first_mismatch_offset = UInt32.max
        result.checkpoint_diagnostic.page_witnesses.2.first_mismatch_offset = UInt32.max
    }

    private func setSCTLRTransitionFull(_ result: inout EPRGuestH3CursorResumeResult,
                                         pre: UInt64 = 0x30d0_0980,
                                         post: UInt64 = 0x30d0_0980) {
        result.sctlr_transition_diagnostic.schema_version = 1
        result.sctlr_transition_diagnostic.sampled_mask = 0x7
        result.sctlr_transition_diagnostic.source_pre_entry_read_entries = 1
        result.sctlr_transition_diagnostic.source_post_exit_read_entries = 1
        result.sctlr_transition_diagnostic.source_pre_entry_read_status = 0
        result.sctlr_transition_diagnostic.source_post_exit_read_status = 0
        result.sctlr_transition_diagnostic.reserved_zero_0 = 0
        result.sctlr_transition_diagnostic.reserved_zero_1 = 0
        result.sctlr_transition_diagnostic.requested = 0x30d0_0980
        result.sctlr_transition_diagnostic.source_pre_entry = pre
        result.sctlr_transition_diagnostic.source_post_exit = post
    }

    private func setSCTLRTransitionZero(_ result: inout EPRGuestH3CursorResumeResult) {
        result.sctlr_transition_diagnostic = EPRGuestH3SCTLRTransitionDiagnostic()
    }

    private func setCheckpointNotEvaluated(_ result: inout EPRGuestH3CursorResumeResult) {
        result.checkpoint_valid = 0
        result.checkpoint_diagnostic = EPRGuestH3CheckpointDiagnostic()
        result.checkpoint_diagnostic.schema_version = 1
        result.checkpoint_diagnostic.required_mask = 0x1ff
        result.checkpoint_diagnostic.page_witnesses.0.first_mismatch_offset = UInt32.max
        result.checkpoint_diagnostic.page_witnesses.1.first_mismatch_offset = UInt32.max
        result.checkpoint_diagnostic.page_witnesses.2.first_mismatch_offset = UInt32.max
    }

    private func makeSCTLRCheckpointFailure(_ value: EPRGuestH3CursorResumeResult,
                                             pre: UInt64,
                                             post: UInt64) -> EPRGuestH3CursorResumeResult {
        var result = makeCheckpointFailure(value)
        result.checkpoint_diagnostic.passed_mask &= ~UInt32(EPR_GUEST_H3_CP_SCTLR)
        result.checkpoint_diagnostic.sctlr = post
        setSCTLRTransitionFull(&result, pre: pre, post: post)
        return result
    }

    private func makeCheckpointFailure(_ value: EPRGuestH3CursorResumeResult)
        -> EPRGuestH3CursorResumeResult {
        var result = value
        result.outcome = UInt32(EPR_GUEST_FAILED)
        result.execution_pass = 0
        result.checkpoint_valid = 0
        result.failure_stage = 11
        result.first_error = EPROTO
        return result
    }

    private func makeEvidence(source: UInt64, target: UInt64) -> (Data, Data) {
        var evidence = Data([0x45, 0x50, 0x52, 0x48, 0x33, 0x45, 0x32, 0])
        let header: [UInt64] = [2, source, target, 2, 3, 31, 4, 136, 16_384,
            0x50, 0x54, 0x7c, 0x1000_c000, 4, 1, 2]
        for word in header { appendBE(word, to: &evidence) }
        let gprs: [UInt64] = [0x1000_4000, 0x1000_8000, 0, 0x1000_c000,
                              1, 1, 42, 23] + Array(repeating: 0, count: 23)
        for word in gprs { appendBE(word, to: &evidence) }
        for word in [UInt64(0x6000_03c5), 0x30d0_0980, 0x1000_bff0, 0] {
            appendBE(word, to: &evidence)
        }
        for word in [UInt64(1), 0x1000_0000, 16_384, 5,
                     2, 0x1000_4000, 16_384, 1,
                     3, 0x1000_8000, 16_384, 3] {
            appendBE(word, to: &evidence)
        }
        let checkpointReply = GuestContract.frame([1, 1, 42, 0])
        evidence.append(bytes(GuestContract.hash(page(image))))
        evidence.append(bytes(GuestContract.hash(page(GuestContract.request))))
        evidence.append(bytes(GuestContract.hash(page(checkpointReply))))
        XCTAssertEqual(evidence.count, 608)
        var internalCursor = Data("EPRCUR02".utf8)
        internalCursor.append(evidence.subdata(in: 8..<608))
        internalCursor.append(page(checkpointReply))
        XCTAssertEqual(internalCursor.count, 16_992)
        let digest = bytes(GuestContract.hash(internalCursor))
        evidence.append(checkpointReply)
        appendBE(UInt64(pageBytes - checkpointReply.count), to: &evidence)
        evidence.append(digest)
        XCTAssertEqual(evidence.count, 680)
        return (evidence, digest)
    }

    private func roots(cursorDigest: Data, checkpointReply: Data,
                       finalReply: Data) throws -> (Data, Data) {
        let checkpoint = try MerkleGenesis.commit([
            GenesisLeaf(label: "cursor_digest", payload: cursorDigest),
            GenesisLeaf(label: "guest_image", payload: image),
            GenesisLeaf(label: "reply", payload: checkpointReply),
            GenesisLeaf(label: "request", payload: GuestContract.request),
            GenesisLeaf(label: "schema", payload: Data("ergentics.hypervisor.guest.h3.checkpoint.v2".utf8)),
        ])
        let terminal = try MerkleGenesis.commit([
            GenesisLeaf(label: "checkpoint_reply", payload: checkpointReply),
            GenesisLeaf(label: "cursor_digest", payload: cursorDigest),
            GenesisLeaf(label: "final_reply", payload: finalReply),
            GenesisLeaf(label: "guest_image", payload: image),
            GenesisLeaf(label: "request", payload: GuestContract.request),
            GenesisLeaf(label: "schema", payload: Data("ergentics.hypervisor.guest.h3.terminal.v2".utf8)),
        ])
        return (bytes(checkpoint.root), bytes(terminal.root))
    }

    private func fixture(source: UInt64? = nil, target: UInt64? = nil) throws -> EPRGuestH3CursorResumeResult {
        let source = source ?? sourceGeneration
        let target = target ?? targetGeneration
        let (evidence, digest) = makeEvidence(source: source, target: target)
        let checkpointReply = GuestContract.frame([1, 1, 42, 0])
        let finalReply = GuestContract.frame([2, 1, 42, 43])
        let commitments = try roots(cursorDigest: digest, checkpointReply: checkpointReply,
                                    finalReply: finalReply)
        var result = EPRGuestH3CursorResumeResult()
        result.abi_version = 5
        result.outcome = 1
        result.execution_pass = 1
        result.teardown_pass = 1
        result.signing_admitted = 1
        result.cursor_sealed = 1
        result.cursor_decoded = 1
        result.cursor_restored = 1
        result.checkpoint_valid = 1
        result.terminal_valid = 1
        result.source_conserved = 1
        result.target_conserved = 1
        result.watchdog_create_entries = 2
        result.watchdog_join_entries = 2
        result.timebase_numer = 125
        result.timebase_denom = 3
        result.cancellation_status = Int32.min
        result.start_ticks = 1
        result.end_ticks = 6
        result.source = phase(generation: source, pc: 0x1000_0050, x4: 1,
                              reads: 36, entry: 2, exit: 3)
        result.target = phase(generation: target, pc: 0x1000_007c, x4: 2,
                              reads: 38, entry: 4, exit: 5)
        setCheckpointPass(&result)
        setSCTLRTransitionFull(&result)
        result.cursor_evidence.byte_count = 680
        store(evidence, in: &result.cursor_evidence.bytes)
        store(digest, in: &result.cursor_sha256)
        store(checkpointReply, in: &result.checkpoint_reply)
        store(finalReply, in: &result.final_reply)
        store(commitments.0, in: &result.checkpoint_merkle)
        store(commitments.1, in: &result.terminal_merkle)
        return result
    }
    private func untouchedPhase(_ generation: UInt64) -> EPRGuestH3PhaseResult {
        var p = EPRGuestH3PhaseResult()
        p.generation = generation; p.exception_reason = .max
        p.vm_create_status = .min; p.vcpu_create_status = .min
        p.register_status = .min; p.run_status = .min; p.read_register_status = .min
        p.vcpu_destroy_status = .min; p.vm_destroy_status = .min
        p.map_status = (.min, .min, .min); p.unmap_status = (.min, .min, .min)
        p.host_unmap_status = (.min, .min, .min)
        return p
    }

    private func earlyNative(stage: Int32 = 1, error: Int32 = 13) -> EPRGuestH3CursorResumeResult {
        var v = EPRGuestH3CursorResumeResult()
        v.abi_version = 5; v.outcome = 2; v.teardown_pass = 1
        v.failure_stage = stage; v.first_error = error
        v.cancellation_status = .min; v.watchdog_create_status = .min
        v.watchdog_join_status = .min; v.watchdog_wait_status = .min
        v.start_ticks = 1; v.end_ticks = 6
        v.source = untouchedPhase(9); v.target = untouchedPhase(10)
        setCheckpointNotEvaluated(&v)
        return v
    }

    private func preparedPhase(_ generation: UInt64) -> EPRGuestH3PhaseResult {
        var p = untouchedPhase(generation)
        p.vm_create_status = 0; p.mappings_entered = 3; p.map_status = (0, 0, 0)
        p.vcpu_create_status = 0; p.register_set_calls = 36; p.register_status = 0
        p.vcpu_destroy_status = 0; p.unmap_status = (0, 0, 0)
        p.vm_destroy_status = 0; p.host_unmap_status = (0, 0, 0); p.conserved = 1
        return p
    }

    private func sourcePreparedNative() -> EPRGuestH3CursorResumeResult {
        var v = earlyNative(stage: 2, error: 75) // Watchdog deadline arithmetic failed before pthread_create.
        v.signing_admitted = 1; v.timebase_numer = 125; v.timebase_denom = 3
        v.source = preparedPhase(9); v.source_conserved = 1
        v.sctlr_transition_diagnostic.schema_version = 1
        v.sctlr_transition_diagnostic.sampled_mask = 3
        v.sctlr_transition_diagnostic.source_pre_entry_read_entries = 1
        v.sctlr_transition_diagnostic.source_post_exit_read_status = .min
        v.sctlr_transition_diagnostic.requested = 0x30d0_0980
        v.sctlr_transition_diagnostic.source_pre_entry = 0x30d0_0980
        return v
    }

    private func sourceReadFailure(_ count: UInt32) -> EPRGuestH3CursorResumeResult {
        var v = sourcePreparedNative()
        v.failure_stage = 10; v.first_error = -5
        v.watchdog_create_entries = 1; v.watchdog_join_entries = 1
        v.watchdog_create_status = 0; v.watchdog_join_status = 0
        v.source.run_entries = 1; v.source.run_status = 0
        v.source.entry_ticks = 2; v.source.exit_ticks = 3
        v.source.exception_reason = 1; v.source.syndrome = 0x9384_0044
        v.source.fault_ipa = 0x1000_c000; v.source.fault_virtual_address = 0x1000_c000
        v.source.register_read_calls = count; v.source.read_register_status = -5
        v.source.pc = count > 33 ? 0x1000_0050 : 0
        setSCTLRTransitionFull(&v)
        if count == 1 {
            v.sctlr_transition_diagnostic.sampled_mask = 3
            v.sctlr_transition_diagnostic.source_post_exit = 0
            v.sctlr_transition_diagnostic.source_post_exit_read_status = -5
        }
        return v
    }

    private func sourceOnlyNative() throws -> EPRGuestH3CursorResumeResult {
        var v = try fixture()
        v.outcome = 2; v.execution_pass = 0; v.terminal_valid = 0
        v.cursor_decoded = 0; v.cursor_restored = 0
        v.failure_stage = 21; v.first_error = 71
        v.target = untouchedPhase(10); v.target_conserved = 0
        v.watchdog_create_entries = 1; v.watchdog_join_entries = 1
        store(Data(repeating: 0, count: 32), in: &v.final_reply)
        store(Data(repeating: 0, count: 32), in: &v.terminal_merkle)
        return v
    }

    private func targetPreparedNative() throws -> EPRGuestH3CursorResumeResult {
        var v = try sourceOnlyNative()
        v.cursor_decoded = 1; v.target = preparedPhase(10); v.target_conserved = 1
        v.failure_stage = 22 // Restored-page comparison fails before the first restore read.
        return v
    }

    private func admitNative(_ v: EPRGuestH3CursorResumeResult) throws {
        try H3QualificationWire.validate(GuestH3LiveVerifier.qualificationCapture(v).wire, schema: "inner_native_returned")
    }

    private typealias V = H3QualificationJSONValue
    private typealias R = H3QualificationReservationStateMachine

    private func replacement(_ value: V, _ path: [String], _ replacement: V) throws -> V {
        guard let head = path.first, var fields = value.objectValue, let child = fields[head] else {
            throw H3QualificationFailure.malformed("test replacement path")
        }
        fields[head] = path.count == 1 ? replacement : try self.replacement(child, Array(path.dropFirst()), replacement)
        return .object(fields)
    }

    private func replayParity(_ native: EPRGuestH3CursorResumeResult,
                              file: StaticString = #filePath, line: UInt = #line) throws -> H3QualificationPresentation {
        let expected: GuestH3Presentation
        do { expected = try GuestH3LiveVerifier.verify(native) }
        catch { expected = GuestH3LiveVerifier.rejected(native, error) }
        let actual = try H3QualificationReplay.replay(capture: GuestH3LiveVerifier.qualificationCapture(native))
        XCTAssertEqual(actual, GuestH3LiveVerifier.qualificationPresentation(expected, returned: native), file: file, line: line)
        return actual
    }

    func testCanonicalRoundTripRetainsTypesAndBoundaryIntegers() throws {
        let bytes = Data(#"{"a":[true,false,null,-9223372036854775808,18446744073709551615],"s":"é/\n"}"#.utf8)
        let value = try H3QualificationCanonicalJSON.decode(bytes)
        XCTAssertEqual(try H3QualificationCanonicalJSON.encode(value), bytes)
        XCTAssertEqual(value["a"]?.arrayValue?.last, .unsigned(.max))
        XCTAssertNotEqual(V.bool(true), V.integer(1))
    }

    func testCanonicalParserRejectsEveryLexicalAlias() {
        let rejected = ["", " {}", "{}\n", "{}{}", "{\"a\":1,\"a\":2}", "{\"b\":1,\"a\":2}",
                        "{\"a\":01}", "{\"a\":-0}", "{\"a\":1.0}", "{\"a\":1e1}", "{\"a\":+1}",
                        "{\"a\":18446744073709551616}", "{\"a\":-9223372036854775809}",
                        "{\"a\":\"\\/\"}", "{\"a\":\"\\u0061\"}", "{\"a\":\"\\uD800\"}",
                        "{\"a\":\"\\uDC00\"}", "{\"a\":\"\\uD800\\u0041\"}", "{\"a\":\"\\q\"}",
                        "{\"a\":true,}", "[1,]", "[1 2]", "{\"a\"1}", "{\"a\":tru}", "[", "{", "\"x"]
        for text in rejected {
            XCTAssertThrowsError(try H3QualificationCanonicalJSON.decode(Data(text.utf8)), text)
        }
    }

    func testCanonicalParserRejectsInvalidUTF8AndDecodedDuplicateKeys() {
        for bytes: [UInt8] in [[0xff], [34, 0xc0, 0xaf, 34], [34, 0xed, 0xa0, 0x80, 34], [34, 10, 34]] {
            XCTAssertThrowsError(try H3QualificationCanonicalJSON.decode(Data(bytes)))
        }
        XCTAssertThrowsError(try H3QualificationCanonicalJSON.decode(Data(#"{"a":0,"\u0061":1}"#.utf8)))
    }

    func testCanonicalParserEnforcesStructuralAllocationBounds() throws {
        var limits = H3QualificationCanonicalJSON.Limits()
        limits.nestingDepth = 2
        XCTAssertNoThrow(try H3QualificationCanonicalJSON.decode(Data("[[0]]".utf8), limits: limits))
        XCTAssertThrowsError(try H3QualificationCanonicalJSON.decode(Data("[[[0]]]".utf8), limits: limits))
        limits = .init(); limits.totalValueTokens = 2
        XCTAssertThrowsError(try H3QualificationCanonicalJSON.decode(Data("[0,1]".utf8), limits: limits))
        limits = .init(); limits.arrayElementsEach = 1
        XCTAssertThrowsError(try H3QualificationCanonicalJSON.decode(Data("[0,1]".utf8), limits: limits))
        limits = .init(); limits.objectMembersEach = 1
        XCTAssertThrowsError(try H3QualificationCanonicalJSON.decode(Data(#"{"a":0,"b":1}"#.utf8), limits: limits))
        limits = .init(); limits.singleDecodedStringBytes = 1
        XCTAssertThrowsError(try H3QualificationCanonicalJSON.decode(Data("\"é\"".utf8), limits: limits))
        limits = .init(); limits.cumulativeDecodedStringBytes = 2
        XCTAssertThrowsError(try H3QualificationCanonicalJSON.decode(Data(#"{"a":"bc"}"#.utf8), limits: limits))
        XCTAssertThrowsError(try H3QualificationCanonicalJSON.decode(Data("{}".utf8), maximumBytes: 1))
    }

    func testCanonicalEncoderEnforcesBoundsBeforeUnboundedRecursion() throws {
        var nested = V.null
        for _ in 0..<33 { nested = .array([nested]) }
        XCTAssertThrowsError(try H3QualificationCanonicalJSON.encode(nested))
        XCTAssertThrowsError(try H3QualificationCanonicalJSON.encode(.array(Array(repeating: .null, count: 4097))))
        XCTAssertThrowsError(try H3QualificationCanonicalJSON.encode(.string(String(repeating: "a", count: 12)), maximumBytes: 8))
    }

    func testFrameRequiresExactMagicLengthAndSinglePayload() throws {
        let frame = try H3QualificationProtocol.frame(payload: .object(["a": .integer(1)]))
        XCTAssertEqual(try H3QualificationProtocol.decodeFrame(frame), .object(["a": .integer(1)]))
        for count in 0..<frame.count { XCTAssertThrowsError(try H3QualificationProtocol.decodeFrame(frame.prefix(count))) }
        var trailing = frame; trailing.append(10)
        XCTAssertThrowsError(try H3QualificationProtocol.decodeFrame(trailing))
        var wrong = frame; wrong[0] ^= 1
        XCTAssertThrowsError(try H3QualificationProtocol.decodeFrame(wrong))
        for length in ["00000000", "00010001", "0000000A", "zzzzzzzz"] {
            var bad = Data("EPRH3I01".utf8); bad.append(contentsOf: length.utf8); bad.append(Data("{}".utf8))
            XCTAssertThrowsError(try H3QualificationProtocol.decodeFrame(bad))
        }
        XCTAssertThrowsError(try H3QualificationProtocol.decodeFrame(H3QualificationProtocol.frame(payload: .array([]))))
    }

    func testFrameMaximumBoundary() throws {
        let value = V.object(["a": .string(String(repeating: "x", count: 65_528))])
        let frame = try H3QualificationProtocol.frame(payload: value)
        XCTAssertEqual(frame.count, 65_552)
        XCTAssertEqual(try H3QualificationProtocol.decodeFrame(frame), value)
        XCTAssertThrowsError(try H3QualificationProtocol.frame(payload: .object(["a": .string(String(repeating: "x", count: 65_529))])))
    }

    func testNonceRunIDAndGateAreBoundToBothSelections() throws {
        let nonce = String(repeating: "01", count: 32)
        var identities = Set<String>()
        for mode in H3QualificationMode.allCases {
            for config in H3QualificationConfiguration.allCases {
                XCTAssertTrue(identities.insert(try H3QualificationProtocol.runID(mode: mode, configuration: config, nonce: nonce)).inserted)
            }
        }
        XCTAssertEqual(try H3QualificationProtocol.gateFrame(mode: .guest, nonce: nonce).count, 41)
        XCTAssertEqual(try H3QualificationProtocol.gateFrame(mode: .guest, nonce: nonce)[8], 2)
        for invalid in ["", String(repeating: "A", count: 64), String(repeating: "0", count: 63), String(repeating: "0", count: 65)] {
            XCTAssertThrowsError(try H3QualificationProtocol.runID(mode: .guest, configuration: .debug, nonce: invalid))
        }
    }

    func testReservationStrictTupleMatrixAndRetainedAmbiguity() throws {
        let cases: [(Bool, Int32, R.State, UInt32)] = [
            (false, 5, .failedReserve, 0), (true, 0, .acquired, 1),
            (false, 0, .invalidReserveNoToken, 0), (false, -1, .invalidReserveNoToken, 0),
            (false, .min, .invalidReserveNoToken, 0), (true, 5, .invalidReserveWithToken, 0),
            (true, -1, .invalidReserveWithToken, 0), (true, .min, .invalidReserveWithToken, 0)
        ]
        for (token, error, state, entries) in cases {
            var reducer = R(policy: .qualificationChecked)
            try reducer.recordReserve(tokenPresent: token, error: error)
            XCTAssertEqual(reducer.state, state); XCTAssertEqual(reducer.reservationEntries, entries)
            XCTAssertEqual(reducer.observedError, error)
            XCTAssertThrowsError(try reducer.recordReserve(tokenPresent: token, error: error))
            if state == .invalidReserveNoToken || state == .invalidReserveWithToken {
                XCTAssertThrowsError(try reducer.beginCheckedRelease(tokenPresent: token))
                XCTAssertEqual(reducer.reservationReleaseEntries, 0)
                XCTAssertEqual(try reducer.deinitDecision(tokenPresent: token), .noCall)
            }
        }
    }

    func testFailedReserveReleaseIsExactlyOneZeroCallSentinel() throws {
        var reducer = R(policy: .qualificationChecked)
        XCTAssertThrowsError(try reducer.beginCheckedRelease(tokenPresent: false))
        try reducer.recordReserve(tokenPresent: false, error: 12)
        XCTAssertEqual(try reducer.beginCheckedRelease(tokenPresent: false), .noCall)
        XCTAssertEqual(reducer.state, .releasedWithoutToken)
        XCTAssertEqual(reducer.reservationEntries, 0)
        XCTAssertEqual(reducer.reservationReleaseEntries, 0)
        XCTAssertEqual(reducer.reservationReleaseStatus, .min)
        XCTAssertThrowsError(try reducer.beginCheckedRelease(tokenPresent: false))
        XCTAssertThrowsError(try reducer.finishCheckedRelease(status: 0))
    }

    func testAcquiredReleaseRecordsActualResultOnceWithoutRetry() throws {
        for status: Int32 in [0, 1, .max, -1, .min] {
            var reducer = R(policy: .qualificationChecked)
            try reducer.recordReserve(tokenPresent: true, error: 0)
            XCTAssertThrowsError(try reducer.beginCheckedRelease(tokenPresent: false))
            XCTAssertEqual(try reducer.beginCheckedRelease(tokenPresent: true), .callToken)
            XCTAssertThrowsError(try reducer.beginCheckedRelease(tokenPresent: true))
            if status >= 0 { try reducer.finishCheckedRelease(status: status) }
            else { XCTAssertThrowsError(try reducer.finishCheckedRelease(status: status)) }
            XCTAssertEqual(reducer.state, .releaseAttemptedToken)
            XCTAssertEqual(reducer.reservationReleaseStatus, status)
            XCTAssertEqual(reducer.reservationReleaseEntries, 1)
            XCTAssertThrowsError(try reducer.finishCheckedRelease(status: 0))
            XCTAssertThrowsError(try reducer.beginCheckedRelease(tokenPresent: false))
            XCTAssertEqual(try reducer.deinitDecision(tokenPresent: false), .noCall)
        }
    }

    func testOrdinaryReservationPreservesEveryNonnullPredecessorTuple() throws {
        for error: Int32 in [.min, -1, 0, 1, .max] {
            for token in [false, true] {
                var reducer = R()
                try reducer.recordReserve(tokenPresent: token, error: error)
                XCTAssertEqual(reducer.state, token ? .acquired : .failedReserve)
                XCTAssertThrowsError(try reducer.beginCheckedRelease(tokenPresent: token))
                XCTAssertEqual(try reducer.deinitDecision(tokenPresent: token), token ? .callToken : .noCall)
                if token { XCTAssertThrowsError(try reducer.deinitDecision(tokenPresent: true)) }
                XCTAssertEqual(try reducer.deinitDecision(tokenPresent: false), .noCall)
            }
        }
    }

    func testQualificationDeinitNeverReleasesAnyState() throws {
        var states = [R(policy: .qualificationChecked)]
        for (token, error) in [(false, Int32(12)), (true, 0), (true, 12), (false, 0)] {
            var reducer = R(policy: .qualificationChecked)
            try reducer.recordReserve(tokenPresent: token, error: error); states.append(reducer)
        }
        var empty = states[1]; _ = try empty.beginCheckedRelease(tokenPresent: false); states.append(empty)
        var released = states[2]; _ = try released.beginCheckedRelease(tokenPresent: true)
        try released.finishCheckedRelease(status: 0); states.append(released)
        for var reducer in states {
            XCTAssertEqual(try reducer.deinitDecision(tokenPresent: false), .noCall)
            XCTAssertEqual(try reducer.deinitDecision(tokenPresent: true), .noCall)
        }
    }

    func testWorkerTagAndReducerStateMustAgree() throws {
        let presentation = try H3QualificationReplay.preparationPresentation(error: 12)
        var failed = R(policy: .qualificationChecked); try failed.recordReserve(tokenPresent: false, error: 12)
        var acquired = R(policy: .qualificationChecked); try acquired.recordReserve(tokenPresent: true, error: 0)
        let outcome = H3QualificationWorkerOutcome.preparationFailed(preparationError: 12, presentation: presentation)
        XCTAssertEqual(H3QualificationWorkerPolicy.decision(outcome: outcome, reservation: failed, completionFirst: true), .releaseSentinel)
        XCTAssertEqual(H3QualificationWorkerPolicy.decision(outcome: outcome, reservation: acquired, completionFirst: true), .internalFailure)
        XCTAssertEqual(H3QualificationWorkerPolicy.decision(outcome: outcome, reservation: failed, completionFirst: false), .cancellation)
        let canceled = H3QualificationWorkerOutcome.canceledBeforeNative(reservationState: .acquired)
        XCTAssertEqual(H3QualificationWorkerPolicy.decision(outcome: canceled, reservation: acquired, completionFirst: true), .internalFailure)
        XCTAssertEqual(H3QualificationWorkerPolicy.decision(outcome: canceled, reservation: acquired, completionFirst: false), .cancellation)
        XCTAssertEqual(H3QualificationWorkerPolicy.decision(outcome: .canceledBeforeNative(reservationState: .failedReserve), reservation: failed, completionFirst: false), .internalFailure)
    }

    func testTerminalOwnerAcceptsOnlyMatchingOneWinningClaim() throws {
        for code: Int32 in [0, 64, 74, -1, 75] {
            var state = H3QualificationTerminalStateMachine()
            XCTAssertThrowsError(try state.claim(code))
        }
        for outcome in [H3QualificationTerminalStateMachine.ExportOutcome.succeeded, .failed] {
            var state = H3QualificationTerminalStateMachine()
            try state.recordExport(outcome)
            XCTAssertThrowsError(try state.recordExport(outcome))
            XCTAssertThrowsError(try state.claim(outcome == .succeeded ? 74 : 0))
            try state.claim(outcome == .succeeded ? 0 : 74)
            for code: Int32 in [0, 70, 74] { XCTAssertThrowsError(try state.claim(code)) }
        }
    }

    func testInternalTerminalRemainsAvailableAfterEitherExportOutcome() throws {
        for outcome: H3QualificationTerminalStateMachine.ExportOutcome? in [nil, .succeeded, .failed] {
            var state = H3QualificationTerminalStateMachine()
            if let outcome { try state.recordExport(outcome) }
            try state.claim(70)
            XCTAssertEqual(state.phase, .terminal)
            XCTAssertThrowsError(try state.claim(70))
            XCTAssertThrowsError(try state.recordExport(.succeeded))
        }
    }

    func testStartupAndCancellationHaveOneWinner() throws {
        var startup = H3QualificationStartupStateMachine()
        try startup.activate(); XCTAssertThrowsError(try startup.activate())
        for completionFirst in [false, true] {
            var state = H3QualificationCancellationStateMachine()
            XCTAssertTrue(completionFirst ? state.claimCompletion() : state.latchCancellation())
            XCTAssertFalse(state.claimCompletion()); XCTAssertFalse(state.latchCancellation())
            XCTAssertEqual(state.state, completionFirst ? .operationCompleted : .cancellationLatched)
        }
    }

    func testSigningClassifierExhaustiveRepresentativeTupleMatrix() {
        for result: Int32 in [-2, -1, 0, 1, 2] {
            for error: Int32 in [.min, -1, 0, 1, .max] {
                let actual = ProvenanceHostInspectionResult.classify(nativeResult: result, nativeError: error, queryHypervisor: false, capabilities: nil)
                let valid = (result == 1 && error == 0) || (result == 0 && error == 0) || (result == -1 && error != 0)
                if case .assessed(let copiedResult, let copiedError, _, let capabilities) = actual {
                    XCTAssertTrue(valid); XCTAssertEqual(copiedResult, result); XCTAssertEqual(copiedError, error); XCTAssertNil(capabilities)
                } else {
                    XCTAssertFalse(valid)
                    XCTAssertEqual(actual, .incomplete(reason: .impossibleNativeTuple, nativeResult: result, nativeError: error))
                }
            }
        }
    }

    func testHostInspectionCachesOneProviderResultAndNoFabricatedAPIError() throws {
        let result = ProvenanceHostInspectionResult.classify(nativeResult: 0, nativeError: 0, queryHypervisor: false, capabilities: nil)
        var cache = H3QualificationHostInspectionCache(), calls = 0
        for _ in 0..<3 {
            let actual = try cache.inspect(bundleIdentifierValid: true, expectedTeamValid: true) { calls += 1; return result }
            XCTAssertEqual(actual, result)
        }
        XCTAssertEqual(calls, 1)
        for (bundle, team, reason) in [(false, true, H3QualificationInspectionIncompleteReason.invalidBundleIdentifier), (true, false, .invalidExpectedTeam)] {
            var invalid = H3QualificationHostInspectionCache()
            let actual = try invalid.inspect(bundleIdentifierValid: bundle, expectedTeamValid: team) { XCTFail("provider must not execute"); return result }
            XCTAssertEqual(actual, .incomplete(reason: reason, nativeResult: nil, nativeError: nil))
        }
        var pending = H3QualificationHostInspectionCache()
        XCTAssertNil(pending.begin(bundleIdentifierValid: true, expectedTeamValid: true))
        XCTAssertEqual(pending.begin(bundleIdentifierValid: true, expectedTeamValid: true), .incomplete(reason: .missingCachedResult, nativeResult: nil, nativeError: nil))
    }

    func testSigningWireRejectsWrongTupleAndUnknownKeys() throws {
        let valid = V.object(["admitted": .bool(false), "error": .integer(0), "native_result": .integer(0), "status": .string("REJECTED")])
        XCTAssertNoThrow(try H3QualificationWire.validate(valid, schema: "inner_signing_rejected"))
        XCTAssertThrowsError(try H3QualificationWire.validate(replacement(valid, ["error"], .integer(1)), schema: "inner_signing_rejected"))
        var unknown = valid.objectValue!; unknown["extra"] = .null
        XCTAssertThrowsError(try H3QualificationWire.validate(.object(unknown), schema: "inner_signing_rejected"))
        XCTAssertThrowsError(try H3QualificationWire.validate(replacement(valid, ["native_result"], .bool(false)), schema: "inner_signing_rejected"))
    }

    func testFullNativePASSRetainsCompleteCaptureAndNilPresentationDiagnostic() throws {
        let native = try fixture()
        let result = try replayParity(native)
        XCTAssertEqual(result.status, "PASS"); XCTAssertNil(result.nativeDiagnostic)
        XCTAssertEqual(result.wire["checkpoint_integrity"], .string("VALID_PASS"))
        XCTAssertEqual(result.wire["sctlr_transition_integrity"], .string("VALID_FULL"))
        XCTAssertFalse(result.durable); XCTAssertFalse(result.h4Entered)
        let capture = GuestH3LiveVerifier.qualificationCapture(native)
        XCTAssertEqual(capture.wire["cursor_evidence_hex"]?.stringValue?.utf8.count, 1360)
        XCTAssertNotEqual(result.projectionRoot, ""); XCTAssertNotEqual(result.graphRoot, "")
    }

    func testPASSIndependentReplayRetainsNonzeroSCTLRDelta() throws {
        var native = try fixture()
        setSCTLRTransitionFull(&native, pre: 0x30d0_0981)
        let result = try replayParity(native)
        XCTAssertEqual(result.status, "PASS")
        XCTAssertEqual(result.wire["requested_xor_pre_entry"], .string("1"))
        XCTAssertEqual(result.wire["pre_entry_xor_post_exit"], .string("1"))
        XCTAssertNil(result.nativeDiagnostic)
    }

    func testNativeTerminalSemanticFailurePreservesEveryDiagnosticField() throws {
        var native = try fixture()
        native.outcome = 2; native.execution_pass = 0; native.terminal_valid = 0
        native.failure_stage = 23; native.first_error = 71
        native.target.x4 = 99
        store(Data(repeating: 0, count: 32), in: &native.terminal_merkle)
        let result = try replayParity(native)
        XCTAssertEqual(result.status, "FAIL")
        XCTAssertEqual(result.verificationDisposition, "NATIVE_NONPASS")
        XCTAssertEqual(result.nativeDiagnostic?["failureStageName"], .string("h3-terminal"))
        XCTAssertEqual(result.nativeDiagnostic?["target"]?["x4"], .string("99"))
        XCTAssertEqual(result.wire["verifier_error_sha256"], .string(H3QualificationProtocol.hash(Data("H3 native PASS predicates rejected".utf8))))
    }

    func testIndependentReplayDetectsByteTamperEvenWithRehashedStorage() throws {
        let native = try fixture()
        let original = GuestH3LiveVerifier.qualificationCapture(native)
        var evidence = try H3QualificationProtocol.unhex(original.wire["cursor_evidence_hex"]!.stringValue!, bytes: 680)
        evidence[200] ^= 1
        var tampered = try replacement(original.wire, ["cursor_evidence_hex"], .string(H3QualificationProtocol.hex(evidence)))
        XCTAssertThrowsError(try H3QualificationReplay.replay(capture: .init(wire: tampered)))
        tampered = try replacement(tampered, ["cursor_evidence_sha256"], .string(H3QualificationProtocol.hash(evidence)))
        XCTAssertThrowsError(try H3QualificationReplay.replay(capture: .init(wire: tampered)))
    }

    func testNativeScalarRangesAndSourcePrefixRejectBeforeReplay() throws {
        let base = GuestH3LiveVerifier.qualificationCapture(try fixture()).wire
        let mutations: [([String], V)] = [
            (["outer", "abi_version"], .integer(4)), (["outer", "cursor_evidence_byte_count"], .integer(681)),
            (["outer", "failure_stage"], .integer(24)), (["outer", "watchdog_create_status"], .integer(-1)),
            (["outer", "cancellation_calls"], .integer(1)), (["source", "run_entries"], .integer(2)),
            (["source", "mappings_entered"], .integer(4)), (["source", "register_set_calls"], .integer(37)),
            (["source", "register_read_calls"], .integer(37)), (["target", "register_read_calls"], .integer(39)),
            (["source", "generation"], .string("09")), (["checkpoint", "evaluated_mask"], .integer(1)),
            (["checkpoint", "gprs"], .array(Array(repeating: .string("0"), count: 32)))
        ]
        for (path, value) in mutations {
            XCTAssertThrowsError(try H3QualificationReplay.replay(capture: .init(wire: replacement(base, path, value))), path.joined(separator: "."))
        }
    }

    func testPreNativePresentationParityAndExactDetailPreimage() throws {
        for error: Int32 in [1, 12, .max] {
            let expected = GuestH3LiveVerifier.rejected(ProvenanceFailure("H3 preparation failed with errno \(error)"))
            let actual = try H3QualificationReplay.preparationPresentation(error: error)
            XCTAssertEqual(actual, GuestH3LiveVerifier.qualificationPresentation(expected))
            XCTAssertEqual(actual.wire["detail_sha256"], .string(H3QualificationProtocol.hash(Data(expected.detail.utf8))))
        }
        XCTAssertThrowsError(try H3QualificationReplay.preparationPresentation(error: 0))
        XCTAssertThrowsError(try H3QualificationReplay.preparationPresentation(error: -1))
        XCTAssertEqual(H3QualificationReplay.signingRejectedPresentation(), GuestH3LiveVerifier.qualificationPresentation(
            GuestH3LiveVerifier.rejected(ProvenanceFailure("live self-signing admission did not pass"))))
    }

    func testExportTransferShortProgressAndEINTRUseActualReducer() throws {
        var transfer = H3QualificationExportTransferStateMachine(totalBytes: 4)
        XCTAssertFalse(try transfer.consume(count: -1, error: EINTR, requested: 4))
        XCTAssertFalse(try transfer.consume(count: 1, error: 0, requested: 4))
        XCTAssertFalse(try transfer.consume(count: 1, error: 0, requested: 3))
        XCTAssertTrue(try transfer.consume(count: 2, error: 0, requested: 2))
        XCTAssertEqual(transfer.offset, 4); XCTAssertEqual(transfer.eintrCount, 1)
        XCTAssertThrowsError(try transfer.consume(count: 1, error: 0, requested: 1))
    }

    func testExportTransferRejectsNoProgressOverReturnAndRetryAfterFailure() throws {
        for (count, error, request) in [(0, Int32(0), 4), (5, 0, 4), (-1, 5, 4), (1, 0, 0), (1, 0, 5)] {
            var transfer = H3QualificationExportTransferStateMachine(totalBytes: 4)
            XCTAssertThrowsError(try transfer.consume(count: count, error: error, requested: request))
            XCTAssertTrue(transfer.failed)
            XCTAssertThrowsError(try transfer.consume(count: 4, error: 0, requested: 4))
        }
        var interrupted = H3QualificationExportTransferStateMachine(totalBytes: 1)
        for _ in 0..<16 { XCTAssertFalse(try interrupted.consume(count: -1, error: EINTR, requested: 1)) }
        XCTAssertFalse(interrupted.canAttempt)
        XCTAssertThrowsError(try interrupted.consume(count: -1, error: EINTR, requested: 1))
        XCTAssertEqual(interrupted.eintrCount, 16)
    }

    func testExportBoundedSyntheticNativeFixturesForIndependentRubyReplay() throws {
        // SYNTHETIC ONLY: owned test structs, pure replay, one bounded stdout
        // record. No native entry, guest, filesystem or environment operation.
        var cases: [(String, EPRGuestH3CursorResumeResult)] = [
            ("PASS", try fixture()), ("SIGNING_REJECTED", earlyNative()),
            ("SOURCE_PREPARED", sourcePreparedNative()),
            ("SOURCE_READ_1", sourceReadFailure(1)),
            ("SOURCE_READ_33", sourceReadFailure(33)),
            ("SOURCE_READ_36", sourceReadFailure(36)),
            ("SOURCE_ONLY", try sourceOnlyNative()),
            ("TARGET_PREPARED", try targetPreparedNative())
        ]
        var signingAPI = earlyNative(error: -67050)
        signingAPI.signing_error = -67050
        cases.append(("SIGNING_API_ERROR", signingAPI))
        var badPC = try fixture()
        badPC.outcome = 2; badPC.execution_pass = 0; badPC.terminal_valid = 0
        badPC.failure_stage = 23; badPC.first_error = 71
        badPC.target.pc = 0
        store(Data(repeating: 0, count: 32), in: &badPC.final_reply)
        store(Data(repeating: 0, count: 32), in: &badPC.terminal_merkle)
        cases.append(("TARGET_PC_REJECTED", badPC))
        var values: [String: V] = [:]
        for (name, native) in cases {
            let capture = GuestH3LiveVerifier.qualificationCapture(native)
            let expected = try H3QualificationReplay.replay(capture: capture)
            let conditions = try H3QualificationPredicateEvaluator.nativeConditions(capture: capture)
            values[name] = .object([
                "native": capture.wire, "verifier": expected.wire,
                "conditions": .object(conditions.mapValues { .bool($0) })
            ])
        }
        let envelope: V = .object(["synthetic": .bool(true), "version": .integer(1), "cases": .object(values)])
        let bytes = try H3QualificationCanonicalJSON.encode(envelope, maximumBytes: 786_432)
        let line = "H3_SYNTHETIC_NATIVE_BASE64=" + bytes.base64EncodedString()
        XCTAssertLessThanOrEqual(line.utf8.count + 1, 1_048_576)
        guard line.utf8.count + 1 <= 1_048_576 else { return }
        print(line)
    }

    func testEveryIndependentNativeAndSwiftPredicatePassesGoldenCapture() throws {
        let conditions = try H3QualificationPredicateEvaluator.nativeConditions(
            capture: GuestH3LiveVerifier.qualificationCapture(fixture()))
        XCTAssertEqual(conditions.count, 26)
        XCTAssertTrue(conditions.values.allSatisfy { $0 })
    }

    func testNativeSigningFailureRecomputesCompleteSetAndRetainsErrorDistinction() throws {
        func untouchedPhase(generation: UInt64) -> EPRGuestH3PhaseResult {
            var phase = EPRGuestH3PhaseResult()
            phase.generation = generation
            phase.exception_reason = .max
            phase.vm_create_status = .min; phase.vcpu_create_status = .min
            phase.register_status = .min; phase.run_status = .min; phase.read_register_status = .min
            phase.vcpu_destroy_status = .min; phase.vm_destroy_status = .min
            phase.map_status = (.min, .min, .min)
            phase.unmap_status = (.min, .min, .min)
            phase.host_unmap_status = (.min, .min, .min)
            return phase
        }
        let expectedPassing: Set<String> = ["native.abi", "native.cancellation", "native.quarantine",
                                            "native.teardown", "swift.fixed_image", "swift.readiness_contract"]
        var priorFailed: [String]?
        for signingError: Int32 in [0, -50] {
            var native = EPRGuestH3CursorResumeResult()
            native.abi_version = 5; native.outcome = 2; native.teardown_pass = 1
            native.failure_stage = 1; native.first_error = signingError == 0 ? 13 : signingError
            native.signing_error = signingError; native.cancellation_status = .min
            native.watchdog_create_status = .min; native.watchdog_join_status = .min; native.watchdog_wait_status = .min
            native.start_ticks = 1; native.end_ticks = 2
            native.source = untouchedPhase(generation: 9); native.target = untouchedPhase(generation: 10)
            setCheckpointNotEvaluated(&native)
            let presentation = try replayParity(native)
            XCTAssertEqual(presentation.nativeDiagnostic?["signingError"], .integer(Int64(signingError)))
            let conditions = try H3QualificationPredicateEvaluator.nativeConditions(
                capture: GuestH3LiveVerifier.qualificationCapture(native))
            XCTAssertEqual(Set(conditions.filter { $0.value }.map(\.key)), expectedPassing)
            let failed = conditions.filter { !$0.value }.map(\.key).sorted()
            XCTAssertTrue(failed.contains("native.signing")); XCTAssertEqual(failed.count, 20)
            if let priorFailed { XCTAssertEqual(failed, priorFailed) }
            priorFailed = failed
        }
    }

    func testMonitorEvidenceCannotTurnCancellationIntoCompletion() throws {
        func evidence(bytes: UInt32 = 0, polls: UInt32 = 1, reads: UInt32 = 0,
                      routes: UInt32 = 0, close: Bool = true, join: Bool = true) -> H3QualificationMonitorEvidence {
            .init(bytesObserved: bytes, pollCalls: polls, readCalls: reads, routeCalls: routes,
                  startedTick: 1, terminalTick: 2, fdClosed: close, taskJoined: join)
        }
        XCTAssertNoThrow(try evidence().validate(completionFirst: true))
        for value in [evidence(bytes: 1), evidence(polls: 1066), evidence(reads: 1130), evidence(routes: 1), evidence(close: false), evidence(join: false)] {
            XCTAssertThrowsError(try value.validate(completionFirst: true))
        }
        XCTAssertThrowsError(try evidence().validate(completionFirst: false))
        XCTAssertNoThrow(try evidence(bytes: 40, routes: 1).validate(completionFirst: false))
    }

    func testControllerPolicyRequiresFreshLiveObservationForOneAttempt() {
        var policy = H3QualificationControllerPolicy()
        XCTAssertFalse(policy.claimGate(immediateWait: .interrupted, beforeDeadline: true))
        XCTAssertFalse(policy.claimGate(immediateWait: .live, beforeDeadline: false))
        XCTAssertTrue(policy.claimGate(immediateWait: .live, beforeDeadline: true))
        XCTAssertFalse(policy.claimGate(immediateWait: .live, beforeDeadline: true))
        XCTAssertFalse(policy.claimCancellation(immediateWait: .reaped(0), eligible: true))
        XCTAssertTrue(policy.claimCancellation(immediateWait: .live, eligible: true))
        XCTAssertFalse(policy.claimCancellation(immediateWait: .live, eligible: true))
        XCTAssertFalse(policy.claimKill(immediateWait: .failed(1), eligible: true))
        XCTAssertTrue(policy.claimKill(immediateWait: .live, eligible: true))
        XCTAssertFalse(policy.claimKill(immediateWait: .live, eligible: true))
        XCTAssertTrue(policy.observe(.reaped(0)))
        XCTAssertFalse(policy.observe(.live)); XCTAssertFalse(policy.canObserveWait)
    }

    func testControllerPolicyWaitBoundsAreFinite() {
        var ordinary = H3QualificationControllerPolicy()
        for _ in 0..<4096 { XCTAssertTrue(ordinary.observe(.live)) }
        XCTAssertFalse(ordinary.observe(.live)); XCTAssertTrue(ordinary.waitCapExhausted)
        var interrupted = H3QualificationControllerPolicy()
        for _ in 0..<64 { XCTAssertTrue(interrupted.observe(.interrupted)) }
        XCTAssertFalse(interrupted.observe(.interrupted)); XCTAssertTrue(interrupted.waitCapExhausted)
    }

    func testSyntheticControllerTerminalWaitStatusDecodesEveryExitAndSignal() {
        // SYNTHETIC raw integers only: 256 exits and 31 signals with/without
        // WCOREFLAG. No process, native, Security, signal, or clock operation.
        func admitted(_ raw: Int32, _ expected: H3QualificationTerminalWaitStatus) {
            XCTAssertEqual(H3QualificationTerminalWaitStatus(rawValue: raw), expected)
            var policy = H3QualificationControllerPolicy()
            XCTAssertTrue(policy.observe(.reaped(raw)))
            XCTAssertEqual(policy.terminalStatus, raw)
            XCTAssertEqual(policy.ordinaryWaits, 1)
            XCTAssertFalse(policy.waitFailed)
            XCTAssertFalse(policy.terminalObservationUncertain)
            XCTAssertFalse(policy.canObserveWait)
            XCTAssertFalse(policy.observe(.live))
            XCTAssertFalse(policy.claimGate(immediateWait: .live, beforeDeadline: true))
            XCTAssertFalse(policy.claimCancellation(immediateWait: .live, eligible: true))
            XCTAssertFalse(policy.claimKill(immediateWait: .live, eligible: true))
        }
        for code: Int32 in 0...255 { admitted(code << 8, .exited(code)) }
        for signal: Int32 in 1...31 {
            admitted(signal, .signaled(signal: signal, coreDumped: false))
            admitted(signal | 0x80, .signaled(signal: signal, coreDumped: true))
        }
    }

    func testSyntheticControllerTerminalWaitStatusExhaustsLowSixteenBits() {
        // Exactly 65,536 pure cases, within this class's 20-second XCTest limit.
        // Build the accepted set from independent Darwin encoder formulas, not
        // the classifier's masks or decoded branch decisions.
        var accepted = Set<Int32>()
        for code: Int32 in 0...255 { accepted.insert(code * 256) }
        for signal: Int32 in 1...31 {
            accepted.insert(signal)
            accepted.insert(signal + 128)
        }
        XCTAssertEqual(accepted.count, 318)
        for raw: Int32 in 0...65535 {
            XCTAssertEqual(H3QualificationTerminalWaitStatus(rawValue: raw) != nil,
                           accepted.contains(raw), "SYNTHETIC raw wait status \(raw)")
        }
    }

    func testSyntheticControllerTerminalWaitStatusRejectsEveryUpperBit() {
        var admitted: [Int32] = (Int32(0)...255).map { $0 * 256 }
        for signal: Int32 in 1...31 { admitted.append(signal); admitted.append(signal + 128) }
        // Exactly 16 * 318 fabricated high-bit mutations; bit 31 also covers
        // negative encodings, without invoking a Darwin status or signal API.
        for bit in 16...31 {
            let filler = UInt32(1) << bit
            for raw in admitted {
                let changed = Int32(bitPattern: UInt32(raw) | filler)
                XCTAssertNil(H3QualificationTerminalWaitStatus(rawValue: changed))
            }
        }
        for raw: Int32 in [.min, .max, -1, -256] {
            XCTAssertNil(H3QualificationTerminalWaitStatus(rawValue: raw))
        }
    }

    func testSyntheticControllerPolicyRejectsNonterminalWithoutAuthority() {
        // Darwin stopped signals 1...31 include the continued encoding 0x137f.
        // Add zero-signal core, invalid signal, mixed exit/signal and filler bits.
        let rejected: [Int32] = (Int32(1)...31).map { $0 * 256 + 127 } +
            [0x7f, 0xff, 0xffff, 0x80, 0x20, 0x7e, 0xa0, 0xfe,
             0x109, 0x189, 0x10000, 0x10009, .min, .max, -1]
        for raw in rejected {
            XCTAssertNil(H3QualificationTerminalWaitStatus(rawValue: raw))
            // Cover both the process owner's explicit uncertain observation and
            // a malformed reaped value supplied directly to the pure policy.
            for initial: H3QualificationControllerPolicy.WaitObservation in
                [.terminalUncertain(raw), .reaped(raw)] {
                var policy = H3QualificationControllerPolicy()
                XCTAssertFalse(policy.observe(initial))
                XCTAssertNil(policy.terminalStatus)
                XCTAssertTrue(policy.waitFailed)
                XCTAssertTrue(policy.terminalObservationUncertain)
                XCTAssertFalse(policy.canObserveWait)
                // These are hostile *later* observations. In particular a later
                // live result must not revive numeric-PID wait or signal authority.
                for later: H3QualificationControllerPolicy.WaitObservation in
                    [.live, .reaped(0), .failed(EINVAL), .interrupted, .terminalUncertain(raw)] {
                    XCTAssertFalse(policy.observe(later))
                    XCTAssertFalse(policy.canObserveWait)
                    XCTAssertFalse(policy.claimGate(immediateWait: later, beforeDeadline: true))
                    XCTAssertFalse(policy.claimCancellation(immediateWait: later, eligible: true))
                    XCTAssertFalse(policy.claimKill(immediateWait: later, eligible: true))
                    XCTAssertNil(policy.terminalStatus)
                    XCTAssertTrue(policy.terminalObservationUncertain)
                    XCTAssertEqual(policy.ordinaryWaits, 1)
                    XCTAssertEqual(policy.interruptedWaits, 0)
                }
                XCTAssertFalse(policy.waitCapExhausted)
                XCTAssertFalse(policy.gateAttempted)
                XCTAssertFalse(policy.cancellationAttempted)
                XCTAssertFalse(policy.killAttempted)
            }
        }
    }

    func testSyntheticControllerPolicyOrdinaryFailureRetainsExistingWaitBudget() {
        // Unlike an uncertain exact-PID result, an ordinary failed wait retains
        // only the existing bounded observation and fresh-live containment rules.
        var ordinary = H3QualificationControllerPolicy()
        XCTAssertTrue(ordinary.observe(.failed(EINVAL)))
        XCTAssertFalse(ordinary.terminalObservationUncertain)
        XCTAssertTrue(ordinary.canObserveWait)
        for _ in 1..<4096 { XCTAssertTrue(ordinary.observe(.live)) }
        XCTAssertEqual(ordinary.ordinaryWaits, 4096)
        XCTAssertFalse(ordinary.canObserveWait)
        XCTAssertFalse(ordinary.observe(.reaped(0)))
        XCTAssertNil(ordinary.terminalStatus)
        XCTAssertTrue(ordinary.waitCapExhausted)
        XCTAssertFalse(ordinary.observe(.terminalUncertain(0x137f)))
        XCTAssertTrue(ordinary.terminalObservationUncertain)
        XCTAssertEqual(ordinary.ordinaryWaits, 4096)
        XCTAssertFalse(ordinary.claimCancellation(immediateWait: .live, eligible: true))
        XCTAssertFalse(ordinary.claimKill(immediateWait: .live, eligible: true))

        var interrupted = H3QualificationControllerPolicy()
        XCTAssertTrue(interrupted.observe(.failed(EINVAL)))
        for _ in 0..<64 { XCTAssertTrue(interrupted.observe(.interrupted)) }
        XCTAssertEqual(interrupted.ordinaryWaits, 1)
        XCTAssertEqual(interrupted.interruptedWaits, 64)
        XCTAssertFalse(interrupted.canObserveWait)
        XCTAssertFalse(interrupted.observe(.interrupted))
        XCTAssertNil(interrupted.terminalStatus)
        XCTAssertTrue(interrupted.waitCapExhausted)
        XCTAssertFalse(interrupted.observe(.reaped(0x7f)))
        XCTAssertTrue(interrupted.terminalObservationUncertain)
        XCTAssertEqual(interrupted.ordinaryWaits, 1)
        XCTAssertEqual(interrupted.interruptedWaits, 64)
        XCTAssertFalse(interrupted.claimCancellation(immediateWait: .live, eligible: true))
        XCTAssertFalse(interrupted.claimKill(immediateWait: .live, eligible: true))

        var recovered = H3QualificationControllerPolicy()
        XCTAssertTrue(recovered.observe(.failed(EINVAL)))
        XCTAssertTrue(recovered.observe(.live))
        XCTAssertFalse(recovered.terminalObservationUncertain)
        XCTAssertFalse(recovered.claimGate(immediateWait: .live, beforeDeadline: true))
        XCTAssertTrue(recovered.claimCancellation(immediateWait: .live, eligible: true))
        XCTAssertTrue(recovered.claimKill(immediateWait: .live, eligible: true))
    }

    func testImmediateNativeClaimResultsRequireEntireUntouchedPrefix() throws {
        for outcome: UInt32 in [2, 4, 5] {
            var v = earlyNative(stage: outcome == 2 ? 1 : 0, error: outcome == 2 ? 22 : 0)
            v.outcome = outcome; v.start_ticks = 0; v.end_ticks = 0; v.teardown_pass = 0
            v.signing_error = .min; v.source = untouchedPhase(0); v.target = untouchedPhase(0)
            v.resources_quarantined = outcome == 5 ? 1 : 0
            XCTAssertNoThrow(try admitNative(v), "immediate outcome \(outcome)")
            let wire = GuestH3LiveVerifier.qualificationCapture(v).wire
            for (path, value): ([String], V) in [
                (["outer", "signing_error"], .integer(0)), (["outer", "teardown_pass"], .integer(1)),
                (["source", "generation"], .string("9")), (["target", "pc"], .string("1")),
                (["outer", "watchdog_wait_status"], .integer(0)), (["outer", "end_ticks"], .string("1"))
            ] {
                XCTAssertThrowsError(try H3QualificationWire.validate(replacement(wire, path, value), schema: "inner_native_returned"), path.joined(separator: "."))
            }
        }
    }

    func testNativeBeforeSigningClockAndEveryAllocationPrefixRemainNonpass() throws {
        var beforeSigning = earlyNative(stage: 18, error: 89)
        beforeSigning.signing_error = .min; beforeSigning.cancellation_requested = 1; beforeSigning.outcome = 3
        XCTAssertNoThrow(try admitNative(beforeSigning))
        var beforeGeneration = earlyNative(stage: 1, error: 22)
        beforeGeneration.signing_error = .min
        beforeGeneration.source = untouchedPhase(0); beforeGeneration.target = untouchedPhase(0)
        XCTAssertNoThrow(try admitNative(beforeGeneration))
        var clock = earlyNative(stage: 2, error: 22); clock.signing_admitted = 1
        XCTAssertNoThrow(try admitNative(clock))
        var pageSize = clock; pageSize.failure_stage = 3; pageSize.timebase_numer = 125; pageSize.timebase_denom = 3
        XCTAssertNoThrow(try admitNative(pageSize))
        for allocated in 0...3 {
            var v = pageSize; v.source.conserved = 1; v.source_conserved = 1
            let statuses = (0..<3).map { $0 < allocated ? Int32(0) : Int32.min }
            v.source.host_unmap_status = (statuses[0], statuses[1], statuses[2])
            XCTAssertNoThrow(try admitNative(v), "allocation prefix \(allocated)")
            var skipped = v; skipped.source.host_unmap_status = (.min, 0, .min)
            XCTAssertThrowsError(try admitNative(skipped))
            var impossible = v; impossible.target.host_unmap_status = (0, .min, .min)
            XCTAssertThrowsError(try admitNative(impossible))
        }
    }

    func testNativeVMMapVCPUAndEverySetterFailurePrefix() throws {
        var vm = sourcePreparedNative(); setSCTLRTransitionZero(&vm)
        vm.source = untouchedPhase(9); vm.source.host_unmap_status = (0, 0, 0)
        vm.source.conserved = 1; vm.source.vm_create_status = -5; vm.failure_stage = 4; vm.first_error = -5
        XCTAssertNoThrow(try admitNative(vm))
        var maps = vm; maps.source.vm_create_status = 0; maps.source.vm_destroy_status = 0; maps.failure_stage = 5
        for count in 1...3 {
            var v = maps; v.source.mappings_entered = UInt32(count)
            let statuses = (0..<3).map { $0 < count - 1 ? Int32(0) : ($0 == count - 1 ? -5 : .min) }
            let unmaps = (0..<3).map { $0 < count - 1 ? Int32(0) : .min }
            v.source.map_status = (statuses[0], statuses[1], statuses[2])
            v.source.unmap_status = (unmaps[0], unmaps[1], unmaps[2])
            XCTAssertNoThrow(try admitNative(v), "mapping prefix \(count)")
            var invalid = v; invalid.source.vcpu_create_status = 0
            XCTAssertThrowsError(try admitNative(invalid))
        }
        var vcpu = sourcePreparedNative(); setSCTLRTransitionZero(&vcpu)
        vcpu.failure_stage = 6; vcpu.first_error = -5; vcpu.source.register_set_calls = 0
        vcpu.source.register_status = .min; vcpu.source.vcpu_create_status = -5; vcpu.source.vcpu_destroy_status = .min
        XCTAssertNoThrow(try admitNative(vcpu))
        vcpu.source.vcpu_create_status = 0; vcpu.source.vcpu_destroy_status = 0; vcpu.first_error = 14 // NULL exit-info.
        XCTAssertNoThrow(try admitNative(vcpu))
        for count in 1...36 {
            var v = sourcePreparedNative(); setSCTLRTransitionZero(&v)
            v.failure_stage = 7; v.first_error = -5; v.source.register_set_calls = UInt32(count); v.source.register_status = -5
            XCTAssertNoThrow(try admitNative(v), "setter prefix \(count)")
            var invalid = v; invalid.source.register_status = 0
            XCTAssertThrowsError(try admitNative(invalid), "successful setter cannot stop prefix \(count)")
        }
    }

    func testNativeEverySourceReadFailureAndUntouchedRegisterValues() throws {
        for count in 1...36 {
            let v = sourceReadFailure(UInt32(count))
            XCTAssertNoThrow(try admitNative(v), "source read prefix \(count)")
            var invalid = v; invalid.source.x4 = 1
            XCTAssertThrowsError(try admitNative(invalid), "X4 only copied after all reads")
            invalid = v; invalid.source.read_register_status = 0
            XCTAssertThrowsError(try admitNative(invalid), "successful incomplete read prefix \(count)")
        }
        let presentation = try replayParity(sourceReadFailure(33))
        XCTAssertEqual(presentation.verificationDisposition, "NATIVE_NONPASS")
        XCTAssertEqual(presentation.wire["checkpoint_integrity"], .string("VALID_NOT_EVALUATED"))
    }

    func testNativeSCTLRPartialAndWatchdogFailurePrefixes() throws {
        var pre = sourcePreparedNative(); pre.failure_stage = 7; pre.first_error = -5
        pre.sctlr_transition_diagnostic.sampled_mask = 1
        pre.sctlr_transition_diagnostic.source_pre_entry_read_status = -5
        pre.sctlr_transition_diagnostic.source_pre_entry = 0
        XCTAssertNoThrow(try admitNative(pre))
        var preBad = pre; preBad.sctlr_transition_diagnostic.source_pre_entry = 1
        XCTAssertThrowsError(try admitNative(preBad))
        var create = sourcePreparedNative(); create.failure_stage = 8; create.first_error = 11
        create.watchdog_create_entries = 1; create.watchdog_create_status = 11
        XCTAssertNoThrow(try admitNative(create))
        var run = sourcePreparedNative(); run.failure_stage = 9; run.first_error = -5
        run.watchdog_create_entries = 1; run.watchdog_join_entries = 1
        run.watchdog_create_status = 0; run.watchdog_join_status = 0
        run.source.run_entries = 1; run.source.run_status = -5; run.source.entry_ticks = 2; run.source.exit_ticks = 3
        XCTAssertNoThrow(try admitNative(run))
        var join = sourceReadFailure(36)
        join.failure_stage = 13; join.first_error = 22; join.source.read_register_status = 0; join.source.x4 = 1
        join.watchdog_join_status = 22; join.teardown_pass = 0; join.resources_quarantined = 1
        XCTAssertNoThrow(try admitNative(join))
        var invalid = join; setCheckpointPass(&invalid)
        XCTAssertThrowsError(try admitNative(invalid), "checkpoint capture cannot pass failed source join")
        var deadline = sourcePreparedNative(); deadline.source.entry_ticks = 2; deadline.first_error = 60
        deadline.watchdog_create_entries = 1; deadline.watchdog_join_entries = 1
        deadline.watchdog_create_status = 0; deadline.watchdog_join_status = 0
        XCTAssertNoThrow(try admitNative(deadline), "positive entry with zero run is deadline prefix")
    }

    func testNativeSourceCursorRemainsValidWithoutAnyTargetOrTerminalBytes() throws {
        let v = try sourceOnlyNative()
        let presentation = try replayParity(v)
        XCTAssertEqual(presentation.verificationDisposition, "NATIVE_NONPASS")
        let conditions = try H3QualificationPredicateEvaluator.nativeConditions(capture: GuestH3LiveVerifier.qualificationCapture(v))
        XCTAssertEqual(conditions["swift.cursor_reconstruction"], true)
        XCTAssertEqual(conditions["swift.fixed_replies"], false)
        var invalid = v; invalid.target = preparedPhase(10); invalid.target_conserved = 1
        XCTAssertThrowsError(try admitNative(invalid), "target needs decode, not only sealed source")
        invalid = v; invalid.cursor_decoded = 1
        XCTAssertThrowsError(try admitNative(invalid), "decode immediately attempts target preparation")
    }

    func testNativeEveryTargetRestoreMismatchAndReadFailurePrefix() throws {
        XCTAssertNoThrow(try admitNative(targetPreparedNative()))
        for count in 1...36 {
            for status: Int32 in [0, -5] {
                var v = try targetPreparedNative()
                v.target.register_read_calls = UInt32(count); v.target.read_register_status = status
                v.failure_stage = status == 0 ? 22 : 10; v.first_error = status == 0 ? 71 : status
                XCTAssertNoThrow(try admitNative(v), "target restore \(count) status \(status)")
                var invalid = v; invalid.target.pc = 0x1000_0054
                XCTAssertThrowsError(try admitNative(invalid), "restore uses local temporary, not phase PC")
                invalid = v; invalid.cursor_restored = 1
                if count < 36 || status != 0 { XCTAssertThrowsError(try admitNative(invalid)) }
            }
        }
        var representative = try targetPreparedNative()
        representative.target.register_read_calls = 8; representative.target.read_register_status = 0
        XCTAssertEqual(try replayParity(representative).verificationDisposition, "NATIVE_NONPASS")
        for count: UInt32 in [37, 38] {
            var v = try fixture(); v.outcome = 2; v.execution_pass = 0; v.terminal_valid = 0
            v.failure_stage = 10; v.first_error = -5
            v.target.register_read_calls = count; v.target.read_register_status = -5; v.target.x4 = 0
            if count == 37 { v.target.pc = 0 }
            store(Data(repeating: 0, count: 32), in: &v.final_reply)
            store(Data(repeating: 0, count: 32), in: &v.terminal_merkle)
            XCTAssertNoThrow(try admitNative(v), "target terminal read \(count)")
            var invalid = v; invalid.target.x4 = 2
            XCTAssertThrowsError(try admitNative(invalid))
        }
    }

    func testNativeEveryCleanupFailureRetainsItsQuarantinedPrefix() throws {
        for source in [true, false] {
            for stage: Int32 in [14, 15, 16, 17] {
                for slot in 0..<3 {
                    var v = source ? try sourceOnlyNative() : try fixture()
                    v.outcome = 2; v.teardown_pass = 0; v.resources_quarantined = 1
                    v.failure_stage = stage; v.first_error = stage == 17 ? 22 : -5
                    var p = source ? v.source : v.target; p.conserved = 0
                    if stage == 14 {
                        p.vcpu_destroy_status = -5; p.vm_destroy_status = .min
                        p.unmap_status = (.min, .min, .min); p.host_unmap_status = (.min, .min, .min)
                    } else if stage == 15 {
                        var statuses: [Int32] = [0, 0, 0]; statuses[slot] = -5
                        p.unmap_status = (statuses[0], statuses[1], statuses[2])
                    } else if stage == 16 {
                        p.vm_destroy_status = -5; p.host_unmap_status = (.min, .min, .min)
                    } else {
                        var statuses: [Int32] = [0, 0, 0]; statuses[slot] = -1
                        p.host_unmap_status = (statuses[0], statuses[1], statuses[2])
                    }
                    if source { v.source = p; v.source_conserved = 0 }
                    else { v.target = p; v.target_conserved = 0 }
                    XCTAssertNoThrow(try admitNative(v), "\(source ? "source" : "target") cleanup \(stage)/\(slot)")
                    var invalid = v; invalid.resources_quarantined = 0
                    XCTAssertThrowsError(try admitNative(invalid))
                    invalid = v; invalid.teardown_pass = 1
                    XCTAssertThrowsError(try admitNative(invalid))
                    if stage == 14 || stage == 16 {
                        invalid = v
                        if source { invalid.source.host_unmap_status.0 = 0 }
                        else { invalid.target.host_unmap_status.0 = 0 }
                        XCTAssertThrowsError(try admitNative(invalid), "host memory cannot be released before kernel conservation")
                    }
                }
            }
        }
    }

    func testLegacySnapshotStageCannotBecomeAnH3NativeFirstFailure() throws {
        var v = try fixture()
        v.outcome = 2
        v.failure_stage = 12
        v.first_error = 5
        XCTAssertThrowsError(try admitNative(v))
        // A coherent native non-PASS prefix cannot relabel its actual first
        // error as the legacy snapshot stage either.
        v = try sourceOnlyNative()
        v.failure_stage = 12
        XCTAssertThrowsError(try admitNative(v))
    }

    func testNativeCheckpointWitnessRecomputationAndNoLaterBuffers() throws {
        var trap = sourceReadFailure(36)
        trap.source.read_register_status = 0; trap.source.x4 = 99
        trap.failure_stage = 11; trap.first_error = 71
        XCTAssertNoThrow(try admitNative(trap))
        var v = try sourceOnlyNative(); v.failure_stage = 11; v.first_error = 71
        v.checkpoint_valid = 0; v.cursor_sealed = 0; v.cursor_evidence = EPRGuestH3CursorEvidence()
        store(Data(repeating: 0, count: 32), in: &v.cursor_sha256)
        store(Data(repeating: 0, count: 32), in: &v.checkpoint_reply)
        store(Data(repeating: 0, count: 32), in: &v.checkpoint_merkle)
        for (bit, field, replacementValue): (UInt32, String, V) in [
            (5, "cpsr", .string("0")), (6, "sctlr", .string("0")),
            (7, "sp", .string("0")), (8, "vbar", .string("1"))
        ] {
            var wire = GuestH3LiveVerifier.qualificationCapture(v).wire
            wire = try replacement(wire, ["checkpoint", field], replacementValue)
            wire = try replacement(wire, ["checkpoint", "passed_mask"], .integer(Int64(511 & ~(1 << bit))))
            if field == "sctlr" { wire = try replacement(wire, ["sctlr_transition", "source_post_exit"], replacementValue) }
            XCTAssertNoThrow(try H3QualificationWire.validate(wire, schema: "inner_native_returned"), field)
            XCTAssertThrowsError(try H3QualificationWire.validate(replacement(wire, ["checkpoint", "passed_mask"], .integer(511)), schema: "inner_native_returned"))
            XCTAssertThrowsError(try H3QualificationWire.validate(replacement(wire, ["final_reply_hex"], .string(String(repeating: "01", count: 32))), schema: "inner_native_returned"))
        }
        for slot in 0..<3 {
            var wire = GuestH3LiveVerifier.qualificationCapture(v).wire
            var pages = wire["checkpoint"]!["pages"]!.arrayValue!
            pages[slot] = try replacement(pages[slot], ["first_mismatch_offset"], .integer(16_383))
            pages[slot] = try replacement(pages[slot], ["observed_byte"], .integer(1))
            wire = try replacement(wire, ["checkpoint", "pages"], .array(pages))
            wire = try replacement(wire, ["checkpoint", "passed_mask"], .integer(Int64(511 & ~(1 << (slot + 1)))))
            XCTAssertNoThrow(try H3QualificationWire.validate(wire, schema: "inner_native_returned"))
            pages[slot] = try replacement(pages[slot], ["expected_byte"], .integer(1))
            XCTAssertThrowsError(try H3QualificationWire.validate(replacement(wire, ["checkpoint", "pages"], .array(pages)), schema: "inner_native_returned"))
        }
    }

    func testNativeRoleChronologyAndCancellationOutcomeAreNotLabels() throws {
        let base = GuestH3LiveVerifier.qualificationCapture(try fixture()).wire
        for (path, value): ([String], V) in [
            (["source", "generation"], .string("8")), (["target", "generation"], .string("12")),
            (["source", "entry_ticks"], .string("0")), (["source", "exit_ticks"], .string("5")),
            (["target", "entry_ticks"], .string("2")), (["target", "exit_ticks"], .string("7")),
            (["outer", "outcome"], .integer(2)), (["outer", "outcome"], .integer(3)),
            (["outer", "source_conserved"], .integer(0)), (["outer", "signing_admitted"], .integer(0))
        ] {
            XCTAssertThrowsError(try H3QualificationWire.validate(replacement(base, path, value), schema: "inner_native_returned"), path.joined(separator: "."))
        }
        var canceled = try fixture(); canceled.outcome = 3; canceled.execution_pass = 0
        canceled.failure_stage = 18; canceled.first_error = 89; canceled.cancellation_requested = 1
        XCTAssertNoThrow(try admitNative(canceled), "cancel observed after terminal seal still clears execution")
        canceled.cancellation_calls = 1; canceled.cancellation_status = 0
        XCTAssertNoThrow(try admitNative(canceled))
        canceled.watchdog_fired = 1; canceled.watchdog_wait_status = 60
        XCTAssertNoThrow(try admitNative(canceled))
        canceled.execution_pass = 1
        XCTAssertThrowsError(try admitNative(canceled))
    }

    func testNativeFirstErrorIsExactAndAttemptedJoinCannotUseSentinel() throws {
        var setter = sourcePreparedNative(); setSCTLRTransitionZero(&setter)
        setter.source.register_set_calls = 5; setter.source.register_status = -5
        setter.failure_stage = 7; setter.first_error = -5
        var run = sourcePreparedNative(); run.failure_stage = 9; run.first_error = -5
        run.watchdog_create_entries = 1; run.watchdog_join_entries = 1
        run.watchdog_create_status = 0; run.watchdog_join_status = 0
        run.source.run_entries = 1; run.source.run_status = -5; run.source.entry_ticks = 2; run.source.exit_ticks = 3
        var create = sourcePreparedNative(); create.failure_stage = 8; create.first_error = 11
        create.watchdog_create_entries = 1; create.watchdog_create_status = 11
        var join = sourceReadFailure(36)
        join.failure_stage = 13; join.first_error = 22; join.source.read_register_status = 0; join.source.x4 = 1
        join.watchdog_join_status = 22; join.teardown_pass = 0; join.resources_quarantined = 1
        for original in [setter, sourceReadFailure(5), run, create, join] {
            XCTAssertNoThrow(try admitNative(original))
            var changed = original; changed.first_error = original.first_error == -5 ? -6 : 23
            XCTAssertThrowsError(try admitNative(changed), "first_error cannot be substituted")
        }
        var impossibleJoin = run
        impossibleJoin.watchdog_join_status = .min
        impossibleJoin.teardown_pass = 0; impossibleJoin.resources_quarantined = 1
        XCTAssertThrowsError(try admitNative(impossibleJoin), "run failure cannot hide missing join result")
        var fallback = try sourceOnlyNative(); fallback.failure_stage = 20; fallback.first_error = 16
        XCTAssertThrowsError(try admitNative(fallback), "conserve false already records first stage 14...17")
    }

    func testNativeSecondWatchdogAndTargetRunFailurePrefixes() throws {
        var create = try targetPreparedNative()
        create.target.register_read_calls = 36; create.target.read_register_status = 0; create.cursor_restored = 1
        create.watchdog_create_entries = 2; create.watchdog_create_status = 11
        create.failure_stage = 8; create.first_error = 11
        XCTAssertNoThrow(try admitNative(create))
        var run = create
        run.watchdog_create_status = 0; run.watchdog_join_entries = 2; run.watchdog_join_status = 0
        run.target.entry_ticks = 4; run.target.exit_ticks = 5
        run.target.run_entries = 1; run.target.run_status = -5; run.failure_stage = 9; run.first_error = -5
        XCTAssertNoThrow(try admitNative(run))
        var invalid = run; invalid.target.register_read_calls = 37
        XCTAssertThrowsError(try admitNative(invalid))
        var join = try fixture(); join.outcome = 2; join.execution_pass = 0; join.terminal_valid = 0
        join.failure_stage = 13; join.first_error = 22; join.watchdog_join_status = 22
        join.teardown_pass = 0; join.resources_quarantined = 1
        store(Data(repeating: 0, count: 32), in: &join.final_reply)
        store(Data(repeating: 0, count: 32), in: &join.terminal_merkle)
        XCTAssertNoThrow(try admitNative(join))
        invalid = join; store(GuestContract.frame([2, 1, 42, 43]), in: &invalid.final_reply)
        XCTAssertThrowsError(try admitNative(invalid), "terminal reply copy follows successful second join")
    }

    func testNativeCursorGrammarRejectsEverySectionEvenAfterStorageRehash() throws {
        let base = GuestH3LiveVerifier.qualificationCapture(try sourceOnlyNative()).wire
        let original = try H3QualificationProtocol.unhex(base["cursor_evidence_hex"]!.stringValue!, bytes: 680)
        // Magic, each header/GPR/system/region word, each page digest, reply,
        // zero-tail metadata and the final independently reconstructed digest.
        let offsets = [0] + Array(stride(from: 8, to: 512, by: 8)) + [512, 544, 576, 608, 640, 648, 679]
        for offset in offsets {
            var evidence = original; evidence[offset] ^= 1
            var wire = try replacement(base, ["cursor_evidence_hex"], .string(H3QualificationProtocol.hex(evidence)))
            wire = try replacement(wire, ["cursor_evidence_sha256"], .string(H3QualificationProtocol.hash(evidence)))
            XCTAssertThrowsError(try H3QualificationWire.validate(wire, schema: "inner_native_returned"), "evidence byte \(offset)")
        }
        for count: Int64 in [679, 681] {
            XCTAssertThrowsError(try H3QualificationWire.validate(replacement(base, ["outer", "cursor_evidence_byte_count"], .integer(count)), schema: "inner_native_returned"))
        }
        let empty = GuestH3LiveVerifier.qualificationCapture(earlyNative()).wire
        var dirtyStorage = Data(repeating: 0, count: 680); dirtyStorage[679] = 1
        var wire = try replacement(empty, ["cursor_evidence_hex"], .string(H3QualificationProtocol.hex(dirtyStorage)))
        wire = try replacement(wire, ["cursor_evidence_sha256"], .string(H3QualificationProtocol.hash(dirtyStorage)))
        XCTAssertThrowsError(try H3QualificationWire.validate(wire, schema: "inner_native_returned"), "count zero requires untouched storage, not merely a matching storage hash")
    }

    func testNativeCheckpointGPRAndSequenceWitnessesAreJointlyRecomputed() throws {
        var v = try sourceOnlyNative(); v.failure_stage = 11; v.first_error = 71
        v.checkpoint_valid = 0; v.cursor_sealed = 0; v.cursor_evidence = EPRGuestH3CursorEvidence()
        store(Data(repeating: 0, count: 32), in: &v.cursor_sha256)
        store(Data(repeating: 0, count: 32), in: &v.checkpoint_reply)
        store(Data(repeating: 0, count: 32), in: &v.checkpoint_merkle)
        let base = GuestH3LiveVerifier.qualificationCapture(v).wire
        for index in 0..<31 where index != 4 { // X4 mismatch fails the trap before capture, not the GPR witness.
            var gprs = base["checkpoint"]!["gprs"]!.arrayValue!
            gprs[index] = .string(String(gprs[index].uintValue! ^ 1))
            var wire = try replacement(base, ["checkpoint", "gprs"], .array(gprs))
            wire = try replacement(wire, ["checkpoint", "gpr_mismatch_mask"], .integer(Int64(1) << index))
            wire = try replacement(wire, ["checkpoint", "passed_mask"], .integer(495))
            XCTAssertNoThrow(try H3QualificationWire.validate(wire, schema: "inner_native_returned"), "GPR witness \(index)")
            XCTAssertThrowsError(try H3QualificationWire.validate(replacement(wire, ["checkpoint", "gpr_mismatch_mask"], .integer(0)), schema: "inner_native_returned"))
        }
        for byteOffset in 0..<8 {
            let sequence = UInt64(1) ^ (UInt64(1) << (byteOffset * 8))
            var wire = try replacement(base, ["checkpoint", "checkpoint_sequence"], .string(String(sequence)))
            var pages = wire["checkpoint"]!["pages"]!.arrayValue!
            pages[2] = try replacement(pages[2], ["first_mismatch_offset"], .integer(Int64(byteOffset)))
            pages[2] = try replacement(pages[2], ["expected_byte"], .integer(byteOffset == 0 ? 1 : 0))
            pages[2] = try replacement(pages[2], ["observed_byte"], .integer(byteOffset == 0 ? 0 : 1))
            wire = try replacement(wire, ["checkpoint", "pages"], .array(pages))
            wire = try replacement(wire, ["checkpoint", "passed_mask"], .integer(502))
            XCTAssertNoThrow(try H3QualificationWire.validate(wire, schema: "inner_native_returned"), "sequence byte \(byteOffset)")
            XCTAssertThrowsError(try H3QualificationWire.validate(replacement(wire, ["checkpoint", "checkpoint_sequence"], .string("1")), schema: "inner_native_returned"))
        }
    }

    func testNativeEarlyFailureLabelsCannotBeAttachedToCompletedLaterPhases() throws {
        for stage: Int32 in 1...23 where stage != 18 {
            var impossible = try fixture()
            impossible.outcome = 2; impossible.failure_stage = stage
            switch stage {
            case 1, 2, 3: impossible.first_error = 22
            case 4...10, 14...16: impossible.first_error = -5
            case 13, 17: impossible.first_error = 22
            case 19: impossible.first_error = 5
            default: impossible.first_error = 71
            }
            XCTAssertThrowsError(try admitNative(impossible), "completed terminal cannot acquire unrelated stage \(stage)")
        }
        var sourceDeadline = sourceReadFailure(36)
        sourceDeadline.failure_stage = 2; sourceDeadline.first_error = 60
        sourceDeadline.source.read_register_status = 0; sourceDeadline.source.x4 = 1
        XCTAssertNoThrow(try admitNative(sourceDeadline))
        var falseCheckpoint = sourceDeadline; setCheckpointPass(&falseCheckpoint)
        XCTAssertThrowsError(try admitNative(falseCheckpoint), "post-run deadline prevents checkpoint capture")
        var targetClock = try targetPreparedNative()
        targetClock.target.register_read_calls = 36; targetClock.target.read_register_status = 0; targetClock.cursor_restored = 1
        targetClock.failure_stage = 2; targetClock.first_error = 75
        XCTAssertNoThrow(try admitNative(targetClock), "second watchdog arithmetic prefix")
        var targetDeadline = targetClock; targetDeadline.first_error = 60
        targetDeadline.watchdog_create_entries = 2; targetDeadline.watchdog_join_entries = 2
        targetDeadline.watchdog_create_status = 0; targetDeadline.watchdog_join_status = 0
        targetDeadline.target.entry_ticks = 4
        XCTAssertNoThrow(try admitNative(targetDeadline), "target pre-run deadline prefix")
        targetDeadline.target = try fixture().target
        XCTAssertNoThrow(try admitNative(targetDeadline), "target post-read deadline prefix")
        var copiedTooSoon = targetDeadline
        store(GuestContract.frame([2, 1, 42, 43]), in: &copiedTooSoon.final_reply)
        XCTAssertThrowsError(try admitNative(copiedTooSoon), "post-run deadline prevents terminal copy")
        var claimedBeforeSigning = earlyNative(stage: 1, error: 22); claimedBeforeSigning.signing_error = .min
        XCTAssertThrowsError(try admitNative(claimedBeforeSigning), "post-generation no-signing prefix can only stop for cancellation")
    }

    func testEmptyExternalInputsRejectWithoutOutput() {
        XCTAssertThrowsError(try H3QualificationPrelaunchVerifier.verify(mode: .guest, configuration: .debug,
            artifacts: [:], controllerClaim: .object([:])))
        XCTAssertThrowsError(try H3QualificationCampaignVerifier.verify(bundle: .init(mode: .admissionOnly, artifacts: [:]), verifierClaim: .object([:])))
        XCTAssertThrowsError(try H3QualificationPredicateEvaluator.evaluate(receipt: .object([:]), inner: nil))
    }
}
#endif

#if EPR_H3_QUALIFICATION_TESTS
import CryptoKit

extension H3QualificationRunnerTests {
    /// SYNTHETIC: reuse copied test values, never invoke a native entry point.
    static func externalGuestCapture(nonpass: Bool = false) throws -> H3QualificationNativeCapture {
        let fixtureOwner = H3QualificationRunnerTests()
        return GuestH3LiveVerifier.qualificationCapture(try nonpass ? fixtureOwner.sourceOnlyNative() : fixtureOwner.fixture())
    }
}

/// SYNTHETIC callbacks and deep bytes only. The actual controller provider and
/// all directory/descriptor/Security/process implementations are not compiled here.
final class H3QualificationPrelaunchTransactionTests: XCTestCase {
    private typealias V = H3QualificationJSONValue
    private typealias Selection = H3QualificationPrelaunchSelection
    private typealias Role = Selection.Role
    private struct Identity: Equatable, Sendable { var fields: [Int64] }
    private typealias Transaction = H3QualificationPrelaunchTransaction<Identity>
    private typealias Acquisition = Transaction.Acquisition
    private enum Fault: Error, Equatable { case injected(Int), cleanup, contract }
    private enum Event: Equatable {
        case begin(Role, Acquisition), capture(Role), observe(Role), end(Role, Acquisition), ownerJoin
    }
    private final class SyntheticProvider {
        let selection: Selection
        let owner = Identity(fields: [1, 100, 0, 501, 20, 448, 2, 4096, 0, 1, 2, 3, 4])
        var artifacts: [String: Data]
        var events: [Event] = []
        var active: (Role, Acquisition)?
        var failureAt: Int?
        var secondaryCloseFailure = false
        var primaryRaised = false
        var terminalOwner: Identity?
        var mutate: ((Role, Acquisition, Transaction.Observation) -> Transaction.Observation)?

        init(_ selection: Selection, artifacts: [String: Data]? = nil) {
            self.selection = selection
            self.artifacts = artifacts ?? Dictionary(uniqueKeysWithValues:
                Role.allCases.map { (selection.name($0), Data("SYNTHETIC".utf8)) })
        }
        func record(_ event: Event) throws {
            guard events.count < 20 else { throw Fault.contract }
            let index = events.count
            events.append(event)
            if failureAt == index { primaryRaised = true; throw Fault.injected(index) }
        }
        func require(_ role: Role, _ acquisition: Acquisition) throws {
            guard let active, active.0 == role, active.1 == acquisition else { throw Fault.contract }
        }
        func observation(_ role: Role, _ acquisition: Acquisition) -> Transaction.Observation {
            let ordinal = Int64(Role.allCases.firstIndex(of: role)!)
            let identity = Identity(fields: [1, 200 + ordinal, 0, 501, 20, 384, 1, 8, 0, 5, 6, 7, 8])
            let value = Transaction.Observation(role: role, owner: owner, identity: identity)
            return mutate?(role, acquisition, value) ?? value
        }
        var operations: Transaction.Operations {
            .init(begin: { role, acquisition in
                guard self.active == nil else { throw Fault.contract }
                try self.record(.begin(role, acquisition))
                self.active = (role, acquisition)
            }, capture: { role in
                try self.require(role, .content); try self.record(.capture(role))
                guard let bytes = self.artifacts[self.selection.name(role)] else { throw Fault.contract }
                return .init(bytes: bytes, observation: self.observation(role, .content))
            }, observe: { role in
                try self.require(role, .identity); try self.record(.observe(role))
                return self.observation(role, .identity)
            }, end: { role, acquisition in
                try self.require(role, acquisition)
                self.active = nil // A failed close still consumes the attempt.
                try self.record(.end(role, acquisition))
                if self.secondaryCloseFailure && self.primaryRaised { throw Fault.cleanup }
            }, revalidateOwner: {
                guard self.active == nil else { throw Fault.contract }
                try self.record(.ownerJoin)
                return self.terminalOwner ?? self.owner
            })
        }
    }
    override func setUpWithError() throws { executionTimeAllowance = 20 }
    private func selection(_ mode: H3QualificationMode = .admissionOnly,
                           _ configuration: H3QualificationConfiguration = .debug) throws -> Selection {
        try Selection(mode: mode, configuration: configuration,
            runRoot: "/private/tmp/ergentics-h3q-\(mode == .admissionOnly ? "admission" : "guest")-campaign-v1/\(configuration == .debug ? "debug" : "release")")
    }
    private var completeTrace: [Event] {
        Role.allCases.flatMap { role in
            [Event.begin(role, .content), .capture(role), .end(role, .content),
             .begin(role, .identity), .observe(role), .end(role, .identity)]
        } + [.ownerJoin]
    }
    private func rejected(_ transaction: inout Transaction, _ provider: SyntheticProvider,
                          claim: V = .object([:]), file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertThrowsError(try transaction.run(controllerClaim: claim, operations: provider.operations), file: file, line: line) {
            XCTAssertTrue($0 is H3QualificationControllerFailure || $0 is H3QualificationFailure,
                          "Unexpected error: \($0)", file: file, line: line)
        }
        XCTAssertEqual(transaction.phase, .failed, file: file, line: line)
        XCTAssertNil(provider.active, file: file, line: line)
        let events = provider.events
        XCTAssertThrowsError(try transaction.run(controllerClaim: claim, operations: provider.operations), file: file, line: line) {
            XCTAssertEqual($0 as? H3QualificationControllerFailure, .rejected("prelaunch transaction consumed"), file: file, line: line)
        }
        XCTAssertEqual(provider.events, events, file: file, line: line)
    }
    private func changed(_ value: V, path: [String], to replacement: V) -> V {
        guard let first = path.first else { return replacement }
        var fields = value.objectValue!
        fields[first] = changed(fields[first]!, path: Array(path.dropFirst()), to: replacement)
        return .object(fields)
    }

    func testSyntheticFourSelectionsHaveExactClosedTraceAndRetainedHashes() throws {
        for configuration in H3QualificationConfiguration.allCases {
            let inputs = try H3QualificationExternalValidationTests.syntheticPrelaunchInputs(configuration: configuration)
            for mode in [H3QualificationMode.admissionOnly, .guest] {
                let selected = try selection(mode, configuration)
                let provider = SyntheticProvider(selected, artifacts: inputs.artifacts)
                var transaction = Transaction(selection: selected, owner: provider.owner)
                let result = try transaction.run(controllerClaim: inputs.controllerClaim, operations: provider.operations)
                XCTAssertEqual(provider.events, completeTrace)
                XCTAssertNil(provider.active)
                XCTAssertEqual(transaction.phase, .complete)
                XCTAssertEqual(transaction.contentAttempts, 3); XCTAssertEqual(transaction.identityAttempts, 3)
                XCTAssertEqual(transaction.contentCloseAttempts, 3); XCTAssertEqual(transaction.identityCloseAttempts, 3)
                XCTAssertEqual(transaction.ownerJoinAttempts, 1); XCTAssertEqual(transaction.verifierAttempts, 1)
                XCTAssertFalse(transaction.cleanupFailureObserved)
                XCTAssertEqual(result.artifacts, inputs.artifacts)
                XCTAssertEqual(result.expectedApplication, inputs.applicationClaim)
                XCTAssertEqual(result.manifestSHA256, H3QualificationProtocol.hash(inputs.artifacts[selected.name(.manifest)]!))
                XCTAssertEqual(result.productAuditSHA256, H3QualificationProtocol.hash(inputs.artifacts[selected.name(.productAudit)]!))
                XCTAssertEqual(transaction.retainedByteCount, inputs.artifacts.values.reduce(0) { $0 + $1.count })
                XCTAssertThrowsError(try transaction.run(controllerClaim: inputs.controllerClaim, operations: provider.operations))
                XCTAssertEqual(provider.events, completeTrace)
            }
        }
    }

    func testSyntheticSelectionRejectsEveryAlternateRootAndConfigurationBeforeCallbacks() throws {
        for mode in [H3QualificationMode.admissionOnly, .guest] {
            for configuration in H3QualificationConfiguration.allCases {
                let selected = try selection(mode, configuration)
                let otherMode = try selection(mode == .guest ? .admissionOnly : .guest, configuration)
                let otherConfiguration = try selection(mode, configuration == .debug ? .release : .debug)
                for value in ["", selected.campaignRoot, selected.runRoot + "/", selected.runRoot + "/extra",
                              selected.runRoot + "\0", selected.runRoot.replacingOccurrences(of: "/private/tmp/", with: "/tmp/"),
                              selected.campaignRoot + "/../debug", selected.campaignRoot + "//debug",
                              otherMode.runRoot, otherConfiguration.runRoot, String(repeating: "x", count: 129)] {
                    XCTAssertThrowsError(try Selection(mode: mode, configuration: configuration, runRoot: value))
                }
            }
        }
    }

    func testSyntheticEveryTransactionCallbackFailureClosesOnlyItsOwnedPrefix() throws {
        // Four selections * nineteen callbacks. A begin failure owns nothing;
        // capture/observation failure adds one cleanup close, never another read.
        for mode in [H3QualificationMode.admissionOnly, .guest] {
            for configuration in H3QualificationConfiguration.allCases {
                let selected = try selection(mode, configuration)
                for index in completeTrace.indices {
                    let provider = SyntheticProvider(selected); provider.failureAt = index
                    var transaction = Transaction(selection: selected, owner: provider.owner)
                    XCTAssertThrowsError(try transaction.run(controllerClaim: .object([:]), operations: provider.operations)) {
                        XCTAssertEqual($0 as? Fault, .injected(index))
                    }
                    var expected = Array(completeTrace.prefix(index + 1))
                    switch completeTrace[index] {
                    case .capture(let role): expected.append(.end(role, .content))
                    case .observe(let role): expected.append(.end(role, .identity))
                    default: break
                    }
                    XCTAssertEqual(provider.events, expected)
                    XCTAssertNil(provider.active); XCTAssertEqual(transaction.phase, .failed)
                    XCTAssertEqual(transaction.verifierAttempts, 0)
                    XCTAssertFalse(transaction.cleanupFailureObserved)
                    XCTAssertThrowsError(try transaction.run(controllerClaim: .object([:]), operations: provider.operations))
                    XCTAssertEqual(provider.events, expected)
                }
            }
        }
    }

    func testSyntheticCleanupFailureKeepsEveryOriginalReadOrObservationError() throws {
        let selected = try selection()
        for index in [1, 4, 7, 10, 13, 16] {
            let provider = SyntheticProvider(selected)
            provider.failureAt = index; provider.secondaryCloseFailure = true
            var transaction = Transaction(selection: selected, owner: provider.owner)
            XCTAssertThrowsError(try transaction.run(controllerClaim: .object([:]), operations: provider.operations)) {
                XCTAssertEqual($0 as? Fault, .injected(index))
            }
            XCTAssertTrue(transaction.cleanupFailureObserved)
            XCTAssertNil(provider.active); XCTAssertEqual(transaction.phase, .failed)
            XCTAssertEqual(provider.events.count, index + 2)
            XCTAssertEqual(transaction.verifierAttempts, 0)
        }
    }

    func testSyntheticEveryIdentityFieldRoleAndOwnerMismatchWithholdsCompletion() throws {
        let selected = try selection()
        for role in Role.allCases {
            for field in 0..<13 {
                for category in 0..<3 {
                    let provider = SyntheticProvider(selected)
                    provider.mutate = { observedRole, acquisition, value in
                        guard observedRole == role,
                              acquisition == (category == 0 ? .content : .identity) else { return value }
                        var owner = value.owner, identity = value.identity
                        if category < 2 { owner.fields[field] += 1 } else { identity.fields[field] += 1 }
                        return .init(role: value.role, owner: owner, identity: identity)
                    }
                    var transaction = Transaction(selection: selected, owner: provider.owner)
                    rejected(&transaction, provider)
                    XCTAssertEqual(transaction.verifierAttempts, 0)
                    // A later unchanged owner sample cannot restore an observed
                    // mismatch: the owner-join callback was never reached.
                    XCTAssertEqual(transaction.ownerJoinAttempts, 0)
                }
            }
            for acquisition in [Acquisition.content, .identity] {
                let provider = SyntheticProvider(selected)
                provider.mutate = { observedRole, phase, value in
                    guard observedRole == role, phase == acquisition else { return value }
                    return .init(role: role == .manifest ? .sourceState : .manifest,
                                 owner: value.owner, identity: value.identity)
                }
                var transaction = Transaction(selection: selected, owner: provider.owner)
                rejected(&transaction, provider)
                XCTAssertEqual(transaction.verifierAttempts, 0)
            }
        }
        for field in 0..<13 {
            let provider = SyntheticProvider(selected)
            var owner = provider.owner; owner.fields[field] += 1; provider.terminalOwner = owner
            var transaction = Transaction(selection: selected, owner: provider.owner)
            rejected(&transaction, provider)
            XCTAssertEqual(provider.events, completeTrace)
            XCTAssertEqual(transaction.ownerJoinAttempts, 1); XCTAssertEqual(transaction.verifierAttempts, 0)
        }
    }

    func testSyntheticByteBoundsRejectWithoutExtraAcquisitionOrRetry() throws {
        let selected = try selection()
        for role in Role.allCases {
            for count in [0, 262145] {
                let provider = SyntheticProvider(selected)
                provider.artifacts[selected.name(role)] = Data(repeating: 0x78, count: count)
                var transaction = Transaction(selection: selected, owner: provider.owner)
                rejected(&transaction, provider)
                XCTAssertEqual(provider.events.last, .end(role, .content))
                XCTAssertEqual(transaction.verifierAttempts, 0)
            }
        }
        let provider = SyntheticProvider(selected)
        for role in Role.allCases { provider.artifacts[selected.name(role)] = Data(repeating: 0x78, count: 262144) }
        var transaction = Transaction(selection: selected, owner: provider.owner)
        rejected(&transaction, provider) // At-limit bytes are retained, not accepted as valid JSON.
        XCTAssertEqual(transaction.retainedByteCount, 786432)
        XCTAssertEqual(transaction.verifierAttempts, 1); XCTAssertEqual(provider.events, completeTrace)
    }

    func testSyntheticRehashedProductAndManifestMutationsRejectAfterExactCapture() throws {
        for configuration in H3QualificationConfiguration.allCases {
            let selected = try selection(.admissionOnly, configuration)
            let inputs = try H3QualificationExternalValidationTests.syntheticPrelaunchInputs(configuration: configuration)
            let auditName = selected.name(.productAudit)
            let originalAudit = try H3QualificationCanonicalJSON.decode(inputs.artifacts[auditName]!)
            let originalManifest = try H3QualificationCanonicalJSON.decode(inputs.artifacts[selected.name(.manifest)]!)
            let auditMutations: [([String], V)] = [
                (["application", "cdhash"], .string(String(repeating: "c", count: 40))),
                (["application", "identifier"], .string("com.ergentics.provenance.h3-qualification-controller")),
                (["application", "team_identifier"], .string("WRONGTEAM0")),
                (["application", "code_object_path"], originalAudit["application"]!["executable_path"]!),
                (["application", "executable_path"], originalAudit["application"]!["code_object_path"]!),
                (["application", "runtime"], .bool(false)),
                (["configuration"], .string(configuration == .debug ? "RELEASE" : "DEBUG"))
            ]
            for (path, replacement) in auditMutations {
                let audit = changed(originalAudit, path: path, to: replacement)
                let bytes = try H3QualificationCanonicalJSON.encode(audit)
                let reference: V = .object(["path": .string(auditName), "byte_count": .integer(Int64(bytes.count)),
                                            "sha256": .string(H3QualificationProtocol.hash(bytes))])
                var manifest = changed(originalManifest, path: ["artifacts", configuration == .debug ? "debug_product_audit" : "release_product_audit"], to: reference)
                let index = configuration == .debug ? 0 : 1
                var builds = manifest["builds"]!.arrayValue!
                builds[index] = changed(builds[index], path: ["product_audit"], to: reference)
                manifest = changed(manifest, path: ["builds"], to: .array(builds))
                var products = manifest["products"]!.arrayValue!
                products[index] = changed(products[index], path: ["audit"], to: reference)
                products[index] = changed(products[index], path: ["application"], to: audit["application"]!)
                manifest = changed(manifest, path: ["products"], to: .array(products))
                var artifacts = inputs.artifacts
                artifacts[auditName] = bytes
                artifacts[selected.name(.manifest)] = try H3QualificationCanonicalJSON.encode(manifest)
                let provider = SyntheticProvider(selected, artifacts: artifacts)
                var transaction = Transaction(selection: selected, owner: provider.owner)
                rejected(&transaction, provider, claim: inputs.controllerClaim)
                XCTAssertEqual(provider.events, completeTrace); XCTAssertEqual(transaction.verifierAttempts, 1)
            }
            for (path, replacement): ([String], V) in [
                (["source_state", "sha256"], .string(String(repeating: "0", count: 64))),
                (["source_state", "path"], .string("../source-state.json")),
                (["source_state", "byte_count"], .integer(1))
            ] {
                var artifacts = inputs.artifacts
                artifacts[selected.name(.manifest)] = try H3QualificationCanonicalJSON.encode(changed(originalManifest, path: path, to: replacement))
                let provider = SyntheticProvider(selected, artifacts: artifacts)
                var transaction = Transaction(selection: selected, owner: provider.owner)
                rejected(&transaction, provider, claim: inputs.controllerClaim)
                XCTAssertEqual(transaction.verifierAttempts, 1)
            }
            let provider = SyntheticProvider(selected, artifacts: inputs.artifacts)
            var transaction = Transaction(selection: selected, owner: provider.owner)
            rejected(&transaction, provider, claim: changed(inputs.controllerClaim, path: ["code", "cdhash"],
                                                            to: .string(String(repeating: "c", count: 40))))
            XCTAssertEqual(transaction.verifierAttempts, 1)
        }
    }
}

/// SYNTHETIC retained source observations, not a Git/configuration/filesystem
/// inspection or proof of the bytes consumed by a compiler or mapped executable.
final class H3QualificationSourceStateMutationTests: XCTestCase {
    private typealias V = H3QualificationJSONValue
    private enum Bound: Error { case exceeded }
    private var cases = 0
    override func setUpWithError() throws { executionTimeAllowance = 20; cases = 0 }
    private func fixture() throws -> V {
        let value = try H3QualificationExternalValidationTests.syntheticSourceState()
        XCTAssertNoThrow(try H3QualificationWire.validate(value, schema: "source_state_v1"))
        return value
    }
    private func replace(_ value: V, _ path: [String], _ replacement: V) -> V {
        guard let first = path.first else { return replacement }
        var fields = value.objectValue!
        fields[first] = replace(fields[first]!, Array(path.dropFirst()), replacement)
        return .object(fields)
    }
    private func reject(_ value: V, _ label: String, file: StaticString = #filePath, line: UInt = #line) throws {
        cases += 1
        guard cases <= 256 else { throw Bound.exceeded }
        XCTAssertThrowsError(try H3QualificationWire.validate(value, schema: "source_state_v1"), label, file: file, line: line) {
            XCTAssertTrue($0 is H3QualificationFailure, "Unexpected error \($0): \(label)", file: file, line: line)
        }
    }
    private func probe(_ value: V, _ index: Int, _ path: [String], _ replacement: V) -> V {
        var probes = value["probes"]!.arrayValue!
        probes[index] = replace(probes[index], path, replacement)
        return replace(value, ["probes"], .array(probes))
    }
    private func stream(_ bytes: Data) -> V {
        .object(["base64": .string(bytes.base64EncodedString()), "byte_count": .integer(Int64(bytes.count)),
                 "sha256": .string(H3QualificationProtocol.hash(bytes)), "truncated": .bool(false)])
    }
    private func output(_ value: V, _ index: Int) -> String {
        String(data: Data(base64Encoded: value["probes"]!.arrayValue![index]["stdout"]!["base64"]!.stringValue!)!, encoding: .utf8)!
    }
    private func records(_ value: V, _ index: Int) -> [String] {
        Array(output(value, index).components(separatedBy: "\0").dropLast())
    }
    private func withRecords(_ value: V, _ index: Int, _ records: [String]) -> V {
        probe(value, index, ["stdout"], stream(Data((records.joined(separator: "\0") + "\0").utf8)))
    }

    func testSyntheticSourceAncestryPinOrderAndDirtyNamespaceFields() throws {
        let value = try fixture()
        for key in ["freeze_commit", "freeze_tree", "implementation_commit", "implementation_tree"] {
            try reject(replace(value, ["source", key], .string(String(repeating: "3", count: 40))), "source identity \(key)")
        }
        for key in ["delta_paths", "delta_path_pins", "frozen_input_pins"] {
            let original = value["source"]![key]!.arrayValue!
            if !original.isEmpty {
                try reject(replace(value, ["source", key], .array(Array(original.dropLast()))), "missing \(key)")
                var duplicate = original; duplicate[duplicate.count - 1] = original[0]
                if duplicate != original { try reject(replace(value, ["source", key], .array(duplicate)), "duplicate \(key)") }
            }
            if original.count > 1 {
                try reject(replace(value, ["source", key], .array(Array(original.reversed()))), "reordered \(key)")
            }
        }
        for invalid in ["../escape.swift", "/absolute.swift", "Sources//extra.swift", "Sources/./extra.swift",
                        "Sources/../extra.swift", "Sources\\extra.swift", "a/b/c/d/e/f/g/h/i", "Unapproved.swift"] {
            var paths = value["source"]!["delta_paths"]!.arrayValue!
            paths[0] = .string(invalid)
            var pins = value["source"]!["delta_path_pins"]!.arrayValue!
            pins[0] = replace(pins[0], ["path"], .string(invalid))
            var changed = replace(value, ["source", "delta_paths"], .array(paths))
            changed = replace(changed, ["source", "delta_path_pins"], .array(pins))
            try reject(changed, "delta path \(invalid)")
        }
        let frozen = value["source"]!["frozen_input_pins"]!.arrayValue!
        for index in frozen.indices {
            var changed = frozen
            changed[index] = replace(changed[index], ["sha256"], .string(String(repeating: "0", count: 64)))
            try reject(replace(value, ["source", "frozen_input_pins"], .array(changed)), "frozen hash \(index)")
        }
        let dirty = value["dirty_guard"]!.objectValue!
        for (key, original) in dirty where key != "allowed_tracked_dirty" {
            let changed: V
            switch original {
            case .integer(let number): changed = .integer(number + 1)
            case .bool(let flag): changed = .bool(!flag)
            case .string: changed = .string(String(repeating: "0", count: 64))
            default: throw Bound.exceeded
            }
            try reject(replace(value, ["dirty_guard", key], changed), "dirty namespace \(key)")
        }
        let exceptions = dirty["allowed_tracked_dirty"]!.arrayValue!
        for index in exceptions.indices {
            for key in ["path", "sha256"] {
                var changed = exceptions
                changed[index] = replace(changed[index], [key], .string(key == "path" ? "Control/unapproved.json" : String(repeating: "0", count: 64)))
                try reject(replace(value, ["dirty_guard", "allowed_tracked_dirty"], .array(changed)), "dirty exception \(index)/\(key)")
            }
        }
        try reject(replace(value, ["dirty_guard", "allowed_tracked_dirty"], .array(Array(exceptions.reversed()))), "dirty exception order")
    }

    func testSyntheticEveryDeltaRecordModeOIDStatusAndPathIsBound() throws {
        let value = try fixture(), original = records(value, 4)
        XCTAssertEqual(original.count, 34) // Seventeen fixed implementation paths.
        for position in stride(from: 0, to: original.count, by: 2) {
            let header = original[position].components(separatedBy: " ")
            let mutations = [(0, header[0] == ":100755" ? ":100644" : ":100755"),
                             (1, header[1] == "100755" ? "100644" : "100755"),
                             (2, String(repeating: "3", count: 40)), (3, String(repeating: "3", count: 40)),
                             (4, "D"), (4, "R100"), (4, "X")]
            for (field, replacement) in mutations {
                var rows = original, changed = header; changed[field] = replacement
                rows[position] = changed.joined(separator: " ")
                try reject(withRecords(value, 4, rows), "delta \(position / 2) field \(field)=\(replacement)")
            }
            var rows = original; rows[position + 1] = "Unapproved.swift"
            try reject(withRecords(value, 4, rows), "delta path \(position / 2)")
        }
        var duplicate = original; duplicate[duplicate.count - 2] = original[0]; duplicate[duplicate.count - 1] = original[1]
        try reject(withRecords(value, 4, duplicate), "duplicate delta record")
        let reversed = stride(from: original.count - 2, through: 0, by: -2).flatMap { [original[$0], original[$0 + 1]] }
        try reject(withRecords(value, 4, reversed), "delta record order")
        try reject(withRecords(value, 4, Array(original.dropLast(2))), "missing complete delta")
        try reject(withRecords(value, 4, Array(original.dropLast())), "half delta")
        try reject(probe(value, 4, ["stdout"], stream(Data(output(value, 4).dropLast().utf8))), "delta missing NUL")
        let freeze = records(value, 3), header = freeze[0].components(separatedBy: " ")
        for (field, replacement) in [(0, ":100644"), (1, "100755"), (2, String(repeating: "3", count: 40)),
                                     (3, String(repeating: "3", count: 40)), (4, "M")] {
            var changed = header; changed[field] = replacement
            try reject(withRecords(value, 3, [changed.joined(separator: " "), freeze[1]]), "freeze delta \(field)")
        }
        try reject(withRecords(value, 3, [freeze[0], "Control/substitute.json"]), "freeze path")
    }

    func testSyntheticRehashedListingIndexOrderTypeAndTreeCrossJoins() throws {
        let value = try fixture()
        for index in [6, 8] {
            let original = records(value, index)
            for position in [0, original.count / 2, original.count - 1] {
                let halves = original[position].components(separatedBy: "\t")
                let fields = halves[0].components(separatedBy: " ")
                for (field, replacement) in [(0, "120000"), (index == 6 ? 1 : 2, index == 6 ? "tree" : "1"),
                                             (index == 6 ? 2 : 1, String(repeating: "3", count: 40)),
                                             (index == 6 ? 2 : 1, String(repeating: "0", count: 40))] {
                    var rows = original, changed = fields; changed[field] = replacement
                    rows[position] = changed.joined(separator: " ") + "\t" + halves[1]
                    try reject(withRecords(value, index, rows), "listing/index \(index)/\(position)/\(field)/\(replacement)")
                }
            }
            var duplicate = original; duplicate[1] = original[0]
            try reject(withRecords(value, index, duplicate), "duplicate entry \(index)")
            var reversed = original; reversed.swapAt(0, 1)
            try reject(withRecords(value, index, reversed), "entry order \(index)")
            try reject(withRecords(value, index, Array(original.dropLast())), "entry missing \(index)")
            try reject(probe(value, index, ["stdout"], stream(Data(output(value, index).dropLast().utf8))), "entry missing terminal NUL \(index)")
            for path in ["../escape", "/absolute", "a/b/c/d/e/f/g/h/i", "bad\\path", "bad//path"] {
                var rows = original
                rows[0] = rows[0].components(separatedBy: "\t")[0] + "\t" + path
                try reject(withRecords(value, index, rows), "entry path \(index)/\(path)")
            }
        }
        var listing = records(value, 6)
        let indexed = records(value, 8)
        let firstPath = listing[0].components(separatedBy: "\t")[1]
        listing[1] = listing[1].components(separatedBy: "\t")[0] + "\t" + firstPath + "/child"
        try reject(withRecords(value, 6, listing), "file/directory prefix collision")
        listing = records(value, 6)
        for index in [0, listing.count - 1] {
            let lhs = listing[index].components(separatedBy: "\t"), rhs = indexed[index].components(separatedBy: "\t")
            var left = lhs[0].components(separatedBy: " "), right = rhs[0].components(separatedBy: " ")
            left[0] = left[0] == "100755" ? "100644" : "100755"; right[0] = left[0]
            var leftRows = listing, rightRows = indexed
            leftRows[index] = left.joined(separator: " ") + "\t" + lhs[1]
            rightRows[index] = right.joined(separator: " ") + "\t" + rhs[1]
            let changed = withRecords(withRecords(value, 6, leftRows), 8, rightRows)
            try reject(changed, "matching index/listing still binds reconstructed tree \(index)")
        }
    }

    func testSyntheticBatchAncestryRequestAndReconstructedTreeBindings() throws {
        let value = try fixture(), batch = value["probes"]!.arrayValue![7]
        for field in ["implementation_commit_parent", "implementation_commit_recomputed_oid", "implementation_commit_tree",
                      "implementation_reconstructed_tree", "freeze_commit_parent", "freeze_commit_recomputed_oid",
                      "freeze_commit_tree", "freeze_reconstructed_tree", "predecessor_reconstructed_tree",
                      "pbx_baseline_blob_oid", "pbx_baseline_blob_recomputed_oid"] {
            try reject(probe(value, 7, [field], .string(String(repeating: "3", count: 40))), "batch identity \(field)")
        }
        for field in ["listing_sha256", "request_sha256", "tree_reconstruction_join_sha256", "pbx_baseline_blob_sha256"] {
            try reject(probe(value, 7, [field], .string(String(repeating: "0", count: 64))), "batch derived hash \(field)")
        }
        for field in ["entry_count", "clean_match_count", "dirty_exception_count", "auxiliary_object_count",
                      "implementation_commit_parent_count", "freeze_commit_parent_count", "request_byte_count"] {
            try reject(probe(value, 7, [field], .integer(batch[field]!.intValue! + 1)), "batch count \(field)")
        }
        for field in ["stdin_closed", "stdout_eof"] {
            try reject(probe(value, 7, [field], .bool(false)), "batch completion \(field)")
        }
        for field in ["implementation_commit_byte_count", "freeze_commit_byte_count", "pbx_baseline_blob_byte_count"] {
            for invalid: Int64 in [0, 1048577] { try reject(probe(value, 7, [field], .integer(invalid)), "batch size \(field)/\(invalid)") }
        }
        // Opaque entry/response/commit hashes have no retained raw preimage here.
        // Their syntax can be tested, not falsely promoted to source-byte proof.
        for field in ["entry_join_sha256", "response_sha256", "implementation_commit_sha256", "freeze_commit_sha256"] {
            try reject(probe(value, 7, [field], .string("NOT_A_HASH")), "opaque hash syntax \(field)")
        }
        let wrongTree = String(repeating: "3", count: 40)
        var changed = replace(value, ["source", "implementation_tree"], .string(wrongTree))
        changed = probe(changed, 1, ["stdout"], stream(Data((wrongTree + "\n").utf8)))
        for field in ["implementation_commit_tree", "implementation_reconstructed_tree"] { changed = probe(changed, 7, [field], .string(wrongTree)) }
        try reject(changed, "repeated matching tree claims cannot replace reconstructed listing")
    }

    func testSyntheticRetainedProbeContextsRejectAmbientInjectionClaims() throws {
        let value = try fixture()
        let injections = ["GIT_CONFIG_GLOBAL=/tmp/injected", "GIT_CONFIG_NOSYSTEM=0", "GIT_NO_LAZY_FETCH=0",
                          "GIT_ALTERNATE_OBJECT_DIRECTORIES=/tmp/objects", "GIT_REPLACE_REF_BASE=refs/injected/",
                          "GIT_CONFIG_COUNT=1", "GIT_CONFIG_KEY_0=filter.synthetic.clean", "GIT_CONFIG_VALUE_0=synthetic",
                          "GIT_ATTR_NOSYSTEM=0", "GIT_CONFIG_SYSTEM=/tmp/injected"]
        for index in 0..<9 {
            let original = value["probes"]!.arrayValue![index]
            for entry in injections {
                let environment = original["environment"]!.arrayValue! + [.string(entry)]
                try reject(probe(value, index, ["environment"], .array(environment)), "retained environment \(index)/\(entry)")
            }
            for argument in ["--textconv", "--filters", "--use-mailmap", "--allow-promisor", "-cfilter.synthetic.clean=synthetic"] {
                try reject(probe(value, index, ["argv"], .array(original["argv"]!.arrayValue! + [.string(argument)])), "retained argv \(index)/\(argument)")
            }
            try reject(probe(value, index, ["cwd"], .string("/tmp")), "retained cwd \(index)")
            try reject(probe(value, index, ["exit_status"], .integer(1)), "retained exit \(index)")
            try reject(probe(value, index, ["stderr"], stream(Data("SYNTHETIC ERROR\n".utf8))), "retained stderr \(index)")
        }
        // These tests reject injected *retained values*. They do not inspect
        // real attributes, filters, config, grafts, alternates or partial clones.
    }
}

extension H3QualificationExternalValidationTests {
    /// SYNTHETIC fixture sharing only: no file, product, process, or native call.
    static func syntheticPrelaunchInputs(configuration: H3QualificationConfiguration) throws ->
        (artifacts: [String: Data], controllerClaim: H3QualificationJSONValue, applicationClaim: H3QualificationJSONValue) {
        let fixture = H3QualificationExternalValidationTests()
        let names = ["build-source-manifest.json", "source-state.json",
                     configuration == .debug ? "debug-product-audit.json" : "release-product-audit.json"]
        return (try fixture.buildArtifacts().filter { names.contains($0.key) },
                try fixture.controller(configuration), try fixture.code(configuration))
    }
    static func syntheticSourceState() throws -> H3QualificationJSONValue {
        try H3QualificationExternalValidationTests().sourceState()
    }
}

/// SYNTHETIC scalar observations only. No descriptor, stat, path lookup, read,
/// architecture query, native function, controller entry point or clock is used.
final class H3QualificationControllerReadArgumentTests: XCTestCase {
    private typealias Invocation = H3QualificationControllerInvocation
    private typealias Read = H3QualificationReadPolicy
    private typealias Admission = H3QualificationRegularReadAdmission
    private typealias Failure = H3QualificationControllerFailure
    private enum SyntheticLimit: Error { case exceeded }

    override func setUp() { super.setUp(); executionTimeAllowance = 20 }

    private func rejects(_ expected: Failure, _ operation: () throws -> Void) {
        XCTAssertThrowsError(try operation()) { error in XCTAssertEqual(error as? Failure, expected) }
    }

    func testControllerExactTwoArgumentModesAndConfigurationRoots() throws {
        let cases: [(String, H3QualificationMode, Bool, String)] = [
            ("--admission-only", .admissionOnly, false, "/private/tmp/ergentics-h3q-admission-campaign-v1"),
            ("--guest", .guest, false, "/private/tmp/ergentics-h3q-guest-campaign-v1"),
            ("--verify-admission-campaign", .admissionOnly, true, "/private/tmp/ergentics-h3q-admission-campaign-v1"),
            ("--verify-guest-campaign", .guest, true, "/private/tmp/ergentics-h3q-guest-campaign-v1")
        ]
        for configuration: H3QualificationConfiguration in [.debug, .release] {
            for (argument, mode, verifying, root) in cases {
                let path = root + (verifying ? "" : configuration == .debug ? "/debug" : "/release")
                if verifying && configuration == .debug {
                    rejects(.invalidArguments) { _ = try Invocation(arguments: [argument, path], configuration: configuration) }
                    continue
                }
                let selected = try Invocation(arguments: [argument, path], configuration: configuration)
                XCTAssertEqual(selected.mode, mode); XCTAssertEqual(selected.configuration, configuration)
                XCTAssertEqual(selected.verifying, verifying); XCTAssertEqual(selected.campaignRoot, root)
                XCTAssertEqual(selected.selectedRoot, path)
                for count in [0, 1, 3, 4, 5, 16] {
                    var values = Array([argument, path].prefix(count))
                    while values.count < count { values.append("SYNTHETIC") }
                    rejects(.invalidArguments) { _ = try Invocation(arguments: values, configuration: configuration) }
                }
                let wrongPaths = ["", root + "/debug", root + "/release", root, path + "/", path + "/.",
                    path + "/..", path.replacingOccurrences(of: "/private/tmp/", with: "/tmp/"),
                    path.replacingOccurrences(of: "campaign-v1", with: "campaign-v2"),
                    path.replacingOccurrences(of: "/", with: "//"), " " + path, path + "\n", path + "\0",
                    "/Users/ergentics/Developer/ErgenticsProvenance", "../" + path]
                for wrong in wrongPaths where wrong != path {
                    rejects(.invalidArguments) { _ = try Invocation(arguments: [argument, wrong], configuration: configuration) }
                }
                // The controller draws its own nonce; it accepts no nonce argv.
                // The application's separate nonce grammar is tested elsewhere.
                for nonce in [String(repeating: "a", count: 63), String(repeating: "a", count: 64),
                              String(repeating: "A", count: 64), String(repeating: "a", count: 65),
                              String(repeating: "0", count: 64), String(repeating: "g", count: 64)] {
                    rejects(.invalidArguments) { _ = try Invocation(arguments: [argument, nonce], configuration: configuration) }
                    rejects(.invalidArguments) { _ = try Invocation(arguments: [argument, path, nonce], configuration: configuration) }
                }
            }
        }
    }

    func testControllerRejectsEveryTokenByteMutationAndForeignMode() throws {
        let arguments = ["--admission-only", "--guest", "--verify-admission-campaign", "--verify-guest-campaign"]
        for argument in arguments {
            let admission = argument.contains("admission")
            let root = admission ? "/private/tmp/ergentics-h3q-admission-campaign-v1" : "/private/tmp/ergentics-h3q-guest-campaign-v1"
            let path = root + (argument.contains("verify") ? "" : "/release")
            let bytes = Array(argument.utf8)
            for index in bytes.indices {
                var changed = bytes; changed[index] = changed[index] == 45 ? 95 : 88
                let token = String(decoding: changed, as: UTF8.self)
                rejects(.invalidArguments) { _ = try Invocation(arguments: [token, path], configuration: .release) }
            }
            for token in ["", " "+argument, argument+" ", argument+"\n", argument+"\0", argument+"=1",
                          argument.uppercased(), String(argument.dropFirst()), "--run-guest-debug",
                          "--h3-qualification-guest-once", "--h3-qualification-admission-once", "--verify"] {
                rejects(.invalidArguments) { _ = try Invocation(arguments: [token, path], configuration: .release) }
            }
        }
    }

    func testRegularReadAdmissionRejectsEveryTypePermissionAndScalarDrift() throws {
        let valid = Admission.Value(mode: 0o100600, owner: 501, links: 1, size: 4, device: 7)
        func admit(_ value: Admission.Value, maximum: Int = 4, device: Int32? = 7, executable: Bool = false) throws {
            try Admission.validate(value, maximum: maximum, expectedOwner: 501, device: device, executable: executable)
        }
        try admit(valid)
        // Includes FIFO, character/block devices, directory, symlink, socket,
        // whiteout and every remaining raw Darwin type-mask value.
        for kind in UInt16(0)..<16 {
            for permissions: UInt16 in [0, 0o600, 0o700, 0o777, 0o7777] {
                for executable in [false, true] {
                    var value = valid; value.mode = kind << 12 | permissions
                    let allowed = kind == 8 && (executable || permissions == 0o600)
                    XCTAssertEqual(Admission.isRegular(mode: value.mode), kind == 8)
                    if allowed { XCTAssertNoThrow(try admit(value, executable: executable)) }
                    else { rejects(.rejected("regular leaf policy")) { try admit(value, executable: executable) } }
                }
            }
        }
        for permissions: UInt16 in 0...0o7777 {
            var value = valid; value.mode = 0o100000 | permissions
            if permissions == 0o600 { XCTAssertNoThrow(try admit(value)) }
            else { rejects(.rejected("regular leaf policy")) { try admit(value) } }
        }
        for owner: UInt32 in [0, 500, 502, .max] {
            var value = valid; value.owner = owner
            rejects(.rejected("regular leaf policy")) { try admit(value) }
        }
        for links: UInt16 in [0, 2, .max] {
            var value = valid; value.links = links
            rejects(.rejected("regular leaf policy")) { try admit(value) }
        }
        for size: Int64 in [.min, -1, 5, .max] {
            var value = valid; value.size = size
            rejects(.rejected("regular leaf policy")) { try admit(value) }
        }
        var otherDevice = valid; otherDevice.device = -1
        rejects(.rejected("regular leaf policy")) { try admit(otherDevice) }
        XCTAssertNoThrow(try admit(otherDevice, device: nil))
        var empty = valid; empty.size = 0
        XCTAssertNoThrow(try admit(empty, maximum: 0))
        rejects(.rejected("regular leaf policy")) { try admit(empty, maximum: 0, executable: true) }
        rejects(.rejected("regular leaf policy")) { try admit(empty, maximum: -1) }
        for maximum in [65552, 262144, 1048576, 8 * 1048576, 64 * 1048576] {
            var endpoint = valid; endpoint.size = Int64(maximum)
            XCTAssertNoThrow(try admit(endpoint, maximum: maximum, executable: true))
            endpoint.size += 1
            rejects(.rejected("regular leaf policy")) { try admit(endpoint, maximum: maximum, executable: true) }
        }
    }

    func testReadRequestsExactBytesEOFAndBoundedRetainedPrefix() throws {
        let sizes = [0, 1, 63, 64, 65, 65535, 65536, 65537, 1048607, 1048608, 1048609, 8 * 1048576, 64 * 1048576]
        for size in sizes {
            for chunk in [1, 7, 65536] where chunk == 65536 || size <= 65537 {
                for executable in [false, true] {
                    for retain in [false, true] {
                        var policy = try Read(expected: size, executable: executable, retain: retain)
                        var offset = 0, calls = 0, digestCount = 0, retainedCount = 0, eofCount = 0
                        while !policy.eof {
                            // Finite scalar schedule only: never allocate size bytes.
                            guard calls < 65540 else { throw SyntheticLimit.exceeded }
                            let request = try policy.nextRequest()
                            XCTAssertEqual(request, offset == size ? 1 : min(65536, size - offset))
                            XCTAssertGreaterThan(request, 0); XCTAssertLessThanOrEqual(request, 65536)
                            calls += 1
                            let amount = offset == size ? 0 : min(chunk, request)
                            switch try policy.observe(amount: amount, error: 0) {
                            case .interrupted: XCTFail("No fabricated interruption was supplied")
                            case .eof:
                                XCTAssertEqual(offset, size); eofCount += 1
                            case .bytes(let digest, let retained):
                                XCTAssertEqual(digest, amount)
                                let limit = retain ? size : executable ? min(size, 1048608) : 0
                                XCTAssertEqual(retained, min(amount, max(0, limit - retainedCount)))
                                digestCount += digest; retainedCount += retained; offset += amount
                            }
                        }
                        XCTAssertEqual(calls, (size + chunk - 1) / chunk + 1)
                        XCTAssertEqual(policy.calls, calls); XCTAssertEqual(policy.callLimit, size + 65)
                        XCTAssertEqual(policy.offset, size); XCTAssertEqual(digestCount, size); XCTAssertEqual(eofCount, 1)
                        XCTAssertEqual(retainedCount, retain ? size : executable ? min(size, 1048608) : 0)
                        XCTAssertEqual(policy.retainedByteCount, retainedCount)
                    }
                }
            }
        }
    }

    func testReadExactly64InterruptionsStopBeforeTheFollowingCallAtEveryOffset() throws {
        // The same supplied 4-byte content has five possible interruption sites,
        // including immediately before its sole EOF probe. Swift stops after 64.
        for location in 0...4 {
            for count in 0...64 {
                var policy = try Read(expected: 4, executable: false, retain: true)
                var issued = 0
                for offset in 0...4 {
                    if offset == location {
                        for _ in 0..<count {
                            _ = try policy.nextRequest(); issued += 1
                            XCTAssertEqual(try policy.observe(amount: -1, error: 4), .interrupted)
                        }
                    }
                    if count == 64 && offset == location {
                        XCTAssertEqual(policy.interruptions, 64); XCTAssertNil(policy.failure)
                        rejects(.rejected("read call bound")) { _ = try policy.nextRequest() }
                        XCTAssertEqual(policy.calls, issued); XCTAssertFalse(policy.eof)
                        rejects(.rejected("read call bound")) { _ = try policy.observe(amount: 1, error: 0) }
                        rejects(.rejected("read call bound")) { _ = try policy.nextRequest() }
                        XCTAssertEqual(policy.calls, issued)
                        break
                    }
                    _ = try policy.nextRequest(); issued += 1
                    let result = try policy.observe(amount: offset == 4 ? 0 : 1, error: 0)
                    XCTAssertEqual(result, offset == 4 ? .eof : .bytes(digest: 1, retained: 1))
                }
                if count < 64 {
                    XCTAssertTrue(policy.eof); XCTAssertEqual(policy.calls, count + 5)
                    XCTAssertEqual(policy.interruptions, count); XCTAssertNil(policy.failure)
                }
            }
        }
        var empty = try Read(expected: 0, executable: false, retain: false)
        for _ in 0..<64 { _ = try empty.nextRequest(); _ = try empty.observe(amount: -1, error: 4) }
        rejects(.rejected("read call bound")) { _ = try empty.nextRequest() }
        XCTAssertEqual(empty.calls, 64); XCTAssertEqual(empty.offset, 0); XCTAssertFalse(empty.eof)
    }

    func testReadErrorsGrowthAndOverReturnPreserveOriginalClassification() throws {
        let errors: [(Int, Int32, Failure)] = [
            (-1, 0, .system("read", 0)), (-1, 5, .system("read", 5)), (-1, 35, .system("read", 35)),
            (-2, 22, .system("read", 22)), (5, 0, .system("read", 0)),
            (0, 0, .rejected("early EOF"))
        ]
        for (amount, error, expected) in errors {
            var policy = try Read(expected: 4, executable: false, retain: true)
            XCTAssertEqual(try policy.nextRequest(), 4)
            rejects(expected) { _ = try policy.observe(amount: amount, error: error) }
            XCTAssertEqual(policy.offset, 0); XCTAssertEqual(policy.retainedByteCount, 0)
            rejects(expected) { _ = try policy.nextRequest() }
            XCTAssertEqual(policy.calls, 1)
        }
        for size in [0, 1, 4] {
            for amount in [1, 2, Int.max] {
                var policy = try Read(expected: size, executable: false, retain: true)
                if size > 0 { _ = try policy.nextRequest(); _ = try policy.observe(amount: size, error: 0) }
                XCTAssertEqual(try policy.nextRequest(), 1)
                let expected: Failure = amount == 1 ? .rejected("growth") : .system("read", 0)
                rejects(expected) { _ = try policy.observe(amount: amount, error: 0) }
                XCTAssertEqual(policy.offset, size); XCTAssertFalse(policy.eof)
                rejects(expected) { _ = try policy.nextRequest() }
            }
        }
        // Preserve the old amount<0/error==EINTR predicate exactly, without
        // making a malformed supplied negative result into a new error class.
        var interrupted = try Read(expected: 1, executable: false, retain: false)
        _ = try interrupted.nextRequest()
        XCTAssertEqual(try interrupted.observe(amount: -2, error: 4), .interrupted)
        XCTAssertEqual(interrupted.interruptions, 1); XCTAssertEqual(interrupted.offset, 0)
    }

    func testReadOrderEOFAndArithmeticNeverAuthorizeAnotherObservation() throws {
        for size in [-1, Int.min, Int.max - 64, Int.max] {
            rejects(.rejected("read call bound")) { _ = try Read(expected: size, executable: false, retain: false) }
        }
        let largest = try Read(expected: Int.max - 65, executable: true, retain: false)
        XCTAssertEqual(largest.callLimit, Int.max) // No content allocation or loop.
        var unissued = try Read(expected: 1, executable: false, retain: true)
        rejects(.rejected("read observation order")) { _ = try unissued.observe(amount: 1, error: 0) }
        rejects(.rejected("read observation order")) { _ = try unissued.nextRequest() }
        XCTAssertEqual(unissued.calls, 0)
        var duplicate = try Read(expected: 1, executable: false, retain: true)
        _ = try duplicate.nextRequest()
        rejects(.rejected("read observation order")) { _ = try duplicate.nextRequest() }
        rejects(.rejected("read observation order")) { _ = try duplicate.observe(amount: 1, error: 0) }
        XCTAssertEqual(duplicate.calls, 1); XCTAssertEqual(duplicate.offset, 0)
        var terminal = try Read(expected: 0, executable: false, retain: true)
        XCTAssertEqual(try terminal.nextRequest(), 1); XCTAssertEqual(try terminal.observe(amount: 0, error: 0), .eof)
        rejects(.rejected("read observation order")) { _ = try terminal.nextRequest() }
        rejects(.rejected("read observation order")) { _ = try terminal.observe(amount: -1, error: 4) }
        XCTAssertEqual(terminal.calls, 1); XCTAssertTrue(terminal.eof); XCTAssertEqual(terminal.interruptions, 0)
    }
}

/// Fabricated byte-only product/process observations. These tests neither read
/// a product nor execute Security, a controller, a process, or a guest.
final class H3QualificationExternalValidationTests: XCTestCase {
    private typealias V = H3QualificationJSONValue
    // Frozen input listing, copied read-only from the reviewed freeze commit.
    // All later implementation/probe/process fields are synthetic test values.
    private let frozenTreeBytes = Data(#"[[".gitignore","100644","421ab40c9dfcd134844b4016fd27761150997632"],["Assets.xcassets/AppIcon.appiconset/Contents.json","100644","70647d2754bff48cf114c137b8a6bf6340f91578"],["Assets.xcassets/AppIcon.appiconset/icon_128x128.png","100644","8f99ef333e39be52ba106b07f4435967596e4b20"],["Assets.xcassets/AppIcon.appiconset/icon_128x128@2x.png","100644","01bee0f17da3e45590d0d1a9a972e8b60fbab9dd"],["Assets.xcassets/AppIcon.appiconset/icon_16x16.png","100644","7d3053bcb1e31c3c4024e5e1fd648b110e565406"],["Assets.xcassets/AppIcon.appiconset/icon_16x16@2x.png","100644","7abb1de73fe18186fca5a4e3a45eb137c90e1849"],["Assets.xcassets/AppIcon.appiconset/icon_256x256.png","100644","01bee0f17da3e45590d0d1a9a972e8b60fbab9dd"],["Assets.xcassets/AppIcon.appiconset/icon_256x256@2x.png","100644","8481288260e3e80aacbacc35c8de88c2cdbe27ce"],["Assets.xcassets/AppIcon.appiconset/icon_32x32.png","100644","7abb1de73fe18186fca5a4e3a45eb137c90e1849"],["Assets.xcassets/AppIcon.appiconset/icon_32x32@2x.png","100644","ab3663297b71745ed2480d6241c70c693d7c81ad"],["Assets.xcassets/AppIcon.appiconset/icon_512x512.png","100644","8481288260e3e80aacbacc35c8de88c2cdbe27ce"],["Assets.xcassets/AppIcon.appiconset/icon_512x512@2x.png","100644","92a4a17668c7630b5f3f5e9874996a2644840e53"],["Assets.xcassets/Contents.json","100644","7f3a7e1811606a1b6d72d07b0d0e27ef5537802c"],["Control/capability-flow-independent-verifier-2026-08-31/CapabilityFlowReceiptVerifier","100755","7fc97c2843abef898d6b97a5924a3c4342a05919"],["Control/capability-flow-independent-verifier-2026-08-31/README.md","100644","d0b8ed05ed11d59953d9e9c13e43457306816cf1"],["Control/capability-flow-independent-verifier-2026-08-31/contract-correction.json","100644","1f9a6070faca10f80f6256e32814b61aeaae5c88"],["Control/capability-flow-independent-verifier-2026-08-31/contract.json","100644","cf4743f33acb899c487b267ef3bc118ff49cfc64"],["Control/capability-flow-independent-verifier-2026-08-31/result.json","100644","5bca8c9ce2af652b87adeb8bf999fa27d5a84080"],["Control/capability-flow-independent-verifier-2026-08-31/result.sha256","100644","35503659c5543c444a37cda83256902d15dc5328"],["Control/capability-flow-independent-verifier-2026-08-31/reviews.json","100644","8a6292a25f3a6a7d525a6beac65bdeecd97ac44a"],["Control/capability-flow-independent-verifier-2026-08-31/reviews.sha256","100644","82df0b045544fadece285eb3c10779bca674443f"],["Control/host-integrity-trust-boundary.v1.json","100644","4514b64da3019177c993ad75f81923ba86e0b757"],["Control/hypervisor-development-checkpoint-2026-08-30.json","100644","7d7138f6aaf9d0d1c70225ed092acb15d9d565f8"],["Control/hypervisor-genesis-design.v1.md","100644","6001c8bde51d8237a6dd75ca3298fd2698f1c7ee"],["Control/hypervisor-guest-contract.v1.json","100644","89e2d2b9f9c789848feca6640e456816ecfb5cfd"],["Control/hypervisor-local-v1/commit-23b1479-xcode-build-archive-result.v1.json","100644","33ad6a6294e1f9b1ea7461b3c9364f81d887fa80"],["Control/hypervisor-local-v1/commit-23b1479-xcode-build-archive-result.v1.sha256","100644","9a990d21bfc37f15365a597b63a19192618f1a78"],["Control/hypervisor-local-v1/commit-23b1479-xcode-test-result.v1.json","100644","b69a95af3b3b3c3c6ff816878cf5dffe40f9ea87"],["Control/hypervisor-local-v1/commit-23b1479-xcode-test-result.v1.sha256","100644","ac1d8f51730fba12b1a579a19aa0823af7d9e32b"],["Control/hypervisor-local-v1/h1-pure-contract-result.v1.json","100644","8be4a177e57da6bbbe4820856ebeb2acf462fec2"],["Control/hypervisor-local-v1/h1-pure-contract-result.v1.sha256","100644","16e6bd48a4919c35cd7fb8c0744438d9d84be9e6"],["Control/hypervisor-local-v1/h1-xcode-build-archive-continuity-result.v1.json","100644","1a6e3b0006e49b841633c9e0b2786d47bbb0ee6c"],["Control/hypervisor-local-v1/h1-xcode-build-archive-continuity-result.v1.sha256","100644","7b19df8521e26dc0d2c50eb9a6f88825a816cda0"],["Control/hypervisor-local-v1/h1-xcode-build-archive-result.v1.json","100644","67d38de9d71a28c9ea03b99c23e8c9ac5c13198c"],["Control/hypervisor-local-v1/h1-xcode-build-archive-result.v1.sha256","100644","e43a55b3c810b06a981bd2d5e9a498ffba4b85e5"],["Control/hypervisor-local-v1/h1-xcode-product-eligibility-graph-receipt.v1.json","100644","18a83f132b0e1dcfdb75401c6da253a8d47761c3"],["Control/hypervisor-local-v1/h1-xcode-product-eligibility-graph-receipt.v1.sha256","100644","5b13809d8358d92a7f2a14c260b81ea3f80e8f4f"],["Control/hypervisor-local-v1/h1-xcode-product-eligibility-graph.v1.cbor","100644","805a20bebbd0fd9c9fa09ba8e573816212e705b7"],["Control/hypervisor-local-v1/h1-xcode-product-eligibility-graph.v1.json","100644","b6f3f53e669b836f887f2d8c09ee24652b2e7c38"],["Control/hypervisor-local-v1/h1-xcode-product-eligibility-graph.v1.sha256","100644","c2519cf9f8e809b271c3e9f88cc285d802243718"],["Control/hypervisor-local-v1/h1-xcode-product-source-manifest.v1.json","100644","d715b017e7a1c1668410a9585c13bf2cdb1584d8"],["Control/hypervisor-local-v1/h1-xcode-product-source-manifest.v1.sha256","100644","8201e710714338a33f10c730fba3c5518323b4b7"],["Control/hypervisor-local-v1/h2-live-build-plan.v1.json","100644","33c09b8b954ee73f4b690258308dbbfbd59ce269"],["Control/hypervisor-local-v1/h2-live-build-wire.schema.v1.json","100644","c1e82d7c1bcd7d3d36af4c8ad5b2cd52ce904217"],["Control/hypervisor-local-v1/h2-live-execution-wire.schema.v1.json","100644","e9cf06c8a3cdf3b7e3f9a499ac91756f75992f9f"],["Control/hypervisor-local-v1/h2-live-mechanics-implementation-handoff.v1.json","100644","3a6157bca76bacb0adae37f85806d05e68f91d76"],["Control/hypervisor-local-v1/h2-live-mechanics-implementation-handoff.v1.sha256","100644","8082c920860f50c02a8ed3e78f9b2e6f46b4b0be"],["Control/hypervisor-local-v1/h2-live-mechanics-source-freeze.v1.json","100644","6ed224d728e695ae7c03d142b4a4c92374a32697"],["Control/hypervisor-local-v1/h2-live-mechanics-source-freeze.v1.sha256","100644","b356b80f3229413ccf79e6f5b152e7231bf4a2d5"],["Control/hypervisor-local-v1/h2-static-admission-freeze.v1.json","100644","e521a6b764ef7120e81536d5aae9d8562bcdb54b"],["Control/hypervisor-local-v1/h2-static-admission-freeze.v1.sha256","100644","a117a4f6b3d8247135af64ce1f2fae6efcaf80ee"],["Control/hypervisor-local-v1/h2-static-admission-result.v1.json","100644","ef67768a9c895f9c9a06e12f49590b9d724e5103"],["Control/hypervisor-local-v1/h2-static-admission-result.v1.sha256","100644","61dfd3916fee628925aa0359f49035ec09a84b75"],["Control/hypervisor-local-v1/h3-signed-application-qualification-runner-freeze-2026-09-04.v1.json","100644","75884c075c2b27a7882d35c4dd33375dd09c33b3"],["Control/hypervisor-local-v1/h4-external-commitment-anti-replay-threat-model-freeze-2026-09-04.v1.json","100644","0b11d60af0bd68c98cea0cf56ad9dd331d70a45f"],["Control/hypervisor-local-v1/h4-externality-privacy-delta-review-2026-09-04.v1.json","100644","d4c6029d94187b01762d52fa35c6956135da32d5"],["Control/hypervisor-local-v1/h4-private-physical-verifier-architecture-custody-freeze-2026-09-04.v1.json","100644","ab2577c261e3db925f4a4db4d89cb3017491fe74"],["Control/hypervisor-local-v1/h4-private-verifier-canonical-format-crypto-atomicity-freeze-2026-09-04.v1.json","100644","fc29ebbb15954018228d26a744ee4ae6cf7af314"],["Control/hypervisor-local-v1/h4-private-verifier-execution-surface-workflow-correction-2026-09-04.v1.json","100644","43ed4b8a4a474978656ee9048bc473920d66debc"],["Control/hypervisor-local-v1/h4-private-verifier-pure-implementation-handoff-2026-09-04.v1.json","100644","08b075a40c9a6aa1ebd77ad03922a7e270a8d21c"],["Control/hypervisor-local-v1/h4a-privacy-envelope-checkpoint-2026-09-01.v1.json","100644","fea590bd579abae33667fee39880848e80897f51"],["Control/hypervisor-local-v1/h4b-destination-dispatch-checkpoint-2026-09-01.v1.json","100644","7cdf764f0fbe163e22889915d2f23c405d64d98c"],["Control/hypervisor-local-v1/h4c-dual-canonical-reconstruction-checkpoint-2026-09-01.v1.json","100644","625d1d2b03ae9947429d9c65cbfe6c67c5b9edd7"],["Control/hypervisor-local-v1/h4d-private-owner-epoch-binding-checkpoint-2026-09-01.v1.json","100644","94f7d755716e25cf04eb92ece58364635f14516b"],["Control/hypervisor-local-v1/h4d2-sqlite-persistence-admission-checkpoint-2026-09-01.v1.json","100644","7c941f6fc58e7daa7a68a744b98aa86660775974"],["Control/hypervisor-local-v1/h4d2-sqlite-persistence-admission-freeze-2026-09-01.v1.json","100644","7392162bdc230c2c4e648a09726ee473de968953"],["Control/hypervisor-local-v1/h4d2b-descriptor-rooted-sqlite-image-publication-checkpoint-2026-09-01.v1.json","100644","2e7adf2af017c7d4cd8d66224c05013e9b4faa1f"],["Control/hypervisor-local-v1/h4d2b-descriptor-rooted-sqlite-image-publication-checkpoint-2026-09-01.v1.json.sha256","100644","f64f3182183bc02de2503dab520adb6746879d79"],["Control/hypervisor-local-v1/h4d2b-descriptor-rooted-sqlite-image-publication-freeze-2026-09-01.v1.json","100644","5c93855315a4abc1b56c56e73ed797e6e15ba281"],["Control/hypervisor-local-v1/h4d2c-v2-retained-image-inspection-checkpoint-2026-09-01.v1.json","100644","55dbca5cac15790f7c197bec9e104651dc8cffe5"],["Control/hypervisor-local-v1/h4d2c-v2-retained-image-inspection-freeze-2026-09-01.v1.json","100644","00a9aa094e44d7679b975237bbe9e1436cbc9345"],["Control/hypervisor-local-v1/h4d3-dual-stream-sqlite-image-publication-checkpoint-2026-09-02.v1.json","100644","3afdef40f09e9c1a482d86dbe14dd522bb6f8fff"],["Control/hypervisor-local-v1/h4d3-dual-stream-sqlite-image-publication-freeze-2026-09-01.v1.json","100644","0f5b3808836d0355ad73f646e786d2352a7ebe12"],["Control/hypervisor-local-v1/h4d3b-fresh-process-dual-stream-restart-inspection-checkpoint-2026-09-03.v1.json","100644","c9cde226e1bff8531da9928493a1ded93254d5df"],["Control/hypervisor-local-v1/h4d3b-fresh-process-dual-stream-restart-inspection-freeze-2026-09-03.v1.json","100644","98751a446b5b2b8dc63ef4853e4166ef401bc793"],["Control/hypervisor-local-v1/h4d3c-bounded-sigkill-dual-stream-cut-classification-checkpoint-2026-09-04.v1.json","100644","83912e15fef368d515b5c233c394e2aeb09f94aa"],["Control/hypervisor-local-v1/h4d3c-bounded-sigkill-dual-stream-cut-classification-checkpoint-correction-2026-09-04.v1.json","100644","df7ba1e32e319fe5211397df633805d4b00aac2e"],["Control/hypervisor-local-v1/h4d3c-bounded-sigkill-dual-stream-cut-classification-freeze-2026-09-03.v1.json","100644","2564a1d99fd4e560119406fe5cf34f08c237ca1d"],["Control/hypervisor-local-v1/h4d3c-bounded-sigkill-dual-stream-cut-classification-freeze-2026-09-03.v2.json","100644","e22fa97d9d815b35df3ec6bfe11bd060a9ec76ac"],["Control/hypervisor-local-v1/stage-xcode-build-archive-admission-freeze.v1.json","100644","51dada29bce1587ff3dc77decd6f89a74c886a02"],["Control/hypervisor-local-v1/stage-xcode-build-archive-admission-freeze.v1.sha256","100644","b7d70d7a222f2206a3521548e21e0c41a457ad98"],["Control/hypervisor-local-v1/stage-xcode-eligibility-projector.v1.swift","100644","7b21ecbb6668d3176821d2ceffa293f71ac92fa3"],["Control/hypervisor-local-v1/stage-xcode-eligibility-verifier.v1.swift","100644","6db3d54752a705e4ce61e05b6c804c26ce7de6c5"],["Control/hypervisor-local-v1/stage-xcode-product-source-manifest.v1.swift","100644","80d9d5cbf7bf436f1ab2efc3cbf540f9e39b69e6"],["Control/hypervisor-local-v1/stage0-genesis-freeze.v1.json","100644","777bd7b1e6b51b73214da9f2ebd6affdc1d99ee1"],["Control/hypervisor-read-only-result.v1.json","100644","d46e75aee0df5a5e1448a8d9da85f776e65a33d9"],["Control/macos26-baseline-2026-08-31.json","100644","a90146a77e83fd9205a271bb9763ea6f183b9474"],["Control/prime-git-development-verification.v1.json","100644","c8fc74393cb91eeb9278bf6abb8e3ff3e42d6961"],["Control/prime-git-read-only-design.v1.json","100644","ab0378e5caef7f0d3faa55697e3f5995084f7adc"],["Control/prime-git-w2-live-acceptance-2026-09-01.v1.json","100644","c387c54e6cc2ce99cdde71bb65d6c48302075b66"],["Control/python-external-tool-boundary-2026-08-31.json","100644","5a17b9ba64f8369d977e45dfc1fc0eba6b32454b"],["Control/read-only-successor.v1.json","100644","f28adf5892098cba8940cb9afa13273f1a7338bd"],["Control/rust-guest-bootstrap-build.v1.json","100644","ee7baf4e136c7327fc8baab1c738694508c5290d"],["Control/rust-security-primitives-review.v1.md","100644","c56923bc8573be48ace7d1eb293a5f140a4bf976"],["Control/source-origin.v1.json","100644","3a53032437fb716f7882c5e1e2a1a358585204ab"],["Control/tiny-aarch64-guest-research.v1.json","100644","9846c097bec80edfac97f872c00cdbc25f0ce583"],["Distribution/AppStoreConnect-1.0.2-upload-receipt.json","100644","9d3a0918df176b5a04a7414abf81ee3520dab2f2"],["Distribution/AppStoreConnect-1.0.3-upload-receipt.json","100644","ffe8ffab62db8ecd9779e5b131e35caa859ef095"],["Distribution/ExportOptions-AppStoreConnectUpload.plist","100644","3db7ab27439f33f014e5c4b1b2f35e2cf19ba858"],["Distribution/ExportOptions-TestFlight.plist","100644","46866161a999da4f17d1734dd92e4f881de582a6"],["Distribution/H2-Product-1.0.5-receipt.json","100644","98c037b8c82ed27f458c48fc6a1d92fc05a78e59"],["Distribution/H3-Product-1.0.6-receipt.json","100644","81f5c578c89a5ceff6dc400ef26c1635d2f7b0ee"],["Distribution/H3-Product-1.0.7-receipt.json","100644","a6e34aba7371614968433f5bd89fc9441e2a6c77"],["Distribution/H3-Product-1.0.8-receipt.json","100644","f47b7ac38743644e481a670a9dc116e9318c9451"],["Distribution/H3-Product-1.0.9-readiness.json","100644","9f345d7b4190674f7ce1a56ac5f526fc253ab918"],["Distribution/H3-Product-1.0.9-receipt.json","100644","21dc12f43b374612134bc475418e15c948424ea8"],["Distribution/LocalArchive-1.0.10-receipt.json","100644","66e333cc1824bf905a519305bbf07b07247c42e8"],["Distribution/LocalArchive-1.0.10-receipt.json.sha256","100644","65ce3ffa085885b56a2a97b9ba8b2bdf2a2d0c1e"],["Distribution/LocalArchive-1.0.4-receipt.json","100644","87e0ad0d8899fbb04f2d0dde6369188fdb9dac27"],["Distribution/LocalArchive-1.0.5-receipt.json","100644","5b46f8e7f88895d7a1919eb325a4f6ce827806af"],["Distribution/README.md","100644","a5b4ad724d252b0902943a0f494ac739be496398"],["Documentation/Architecture/PrivacyArchitecture.md","100644","18b1060199c425e31c8c563ae070a6bac828abdf"],["ERGENTICS.spdx.json","100644","27632e1a6cbc86cff5a0c5b0c285670d246362b5"],["Entitlements.plist","100644","d7bd491f0c772584a3bfa1b977306e3f31941bf4"],["ErgenticsProvenance.xcodeproj/project.pbxproj","100644","b5fd9b2e1c72f54924269b6ff9453f87abeae5f2"],["ErgenticsProvenance.xcodeproj/xcshareddata/xcschemes/ErgenticsProvenance.xcscheme","100644","412b603ef4b0ca473dbae34dbd8051690e01a7b8"],["Examples/prime-git-synthetic-example.json","100644","0d55bd7acffce462dd2d6ec63ab299a6bec8db41"],["Guest/RustBootstrap/README.md","100644","b00a958d76d1902acb15090817dac4d109f3eae2"],["Guest/RustBootstrap/build.rb","100644","5ba75d95084519752125c51cf3cd176a7578435c"],["Guest/RustBootstrap/entry.S","100644","a780f07bb28010b08188a057fe575ac3b439d197"],["Guest/RustBootstrap/inspect.rb","100644","bc4d7905c8804416207838a47a1e6f64aaaebe43"],["Guest/RustBootstrap/inspector-tests.rb","100644","f7e78cbcbdb55c77090df9d2602fffe4fd571b43"],["Guest/RustBootstrap/kernel.rs","100644","02652632802062c857229ee7fcbeb73106b875b4"],["Guest/RustBootstrap/linker.ld","100644","8efa0ae12faac9057de873aee9d30458275933ba"],["Guest/cursor-resume.S","100644","0abbf5d5cc460b6c8f042e6f80b9edf137b33182"],["Guest/doorbell.S","100644","d685eadaa2c88d73b4d2426f460ee3bea4ed9d6c"],["Info.plist","100644","1011ba137f9a7d66b59d8a26c9eab9af18c26dcd"],["LICENSE","100644","22301f6bef93644dc0bec7b142533f3008d4ccb8"],["PrivacyInfo.xcprivacy","100644","33f1b94709774c88925ec84a6a3df5c7f8ad3fbf"],["README.md","100644","067217e916813efaef94c51bf3f7df4ffbb27116"],["Sources/AppLifecycleController.swift","100644","21d2d49eb0c9534abea699ebc5797de35f04ba3f"],["Sources/AppLifecyclePolicy.swift","100644","3f1ada05595a96c2f90d7836255a24a7e09082f6"],["Sources/CapabilityFlowClosure.swift","100644","263586cfd023a7c01a3a17ce3d3cfe5a217b4a14"],["Sources/CapabilityLuminosity.swift","100644","2c2b96f1b30eef6cf92f64a6c7ebd8858d5753e8"],["Sources/DeltaPUDemoModel.swift","100644","b801224044aca1bd95b085a9d670ce3056d3758c"],["Sources/DeltaPUDemoVerification.swift","100644","85aa090c4c17c0c311fdc468f91047c10981186d"],["Sources/DeltaPUDemoView.swift","100644","b37adc655c20e158ad8fbeb27546f3576eb98cb5"],["Sources/DeltaPUDemonstration.swift","100644","dbe5a6a4d80a6a06d4342f46b07c2cb8fbdf8a08"],["Sources/DeltaPUEngine.swift","100644","3434f70e1206c98aeed25ce539f9100e847d1c53"],["Sources/DeltaPUGUIReadiness.swift","100644","6864ff1dbcfbd1ed1a7d32cbfaac51dc12afa44a"],["Sources/DeltaPUGUIReadinessReport.swift","100644","ae644755ad8d4fe526a2f2bd12b35bf0c04eca61"],["Sources/DeltaPULayoutPlan.swift","100644","37060124a8b6ff2738eecd99eb3ed887c4c83da5"],["Sources/DeltaPUTypes.swift","100644","da986c5a37a4400e88c10890456021a51d66316a"],["Sources/DevelopmentLaunch.swift","100644","c0814a3454b30ccf83b888ab1899c1779c2f96c8"],["Sources/DevelopmentReadiness.swift","100644","2bb19bead0fd423141a9a201e18921cf28ebd6e1"],["Sources/DevelopmentRustBoot.swift","100644","6986130d60eaac7e9e83cd7e5bc27ef04180eabd"],["Sources/DevelopmentRustBootExport.swift","100644","6c39514d5d617bbf95d5eef81fcb0a7ac49cd3d9"],["Sources/DevelopmentRustBootReport.swift","100644","f79fbc7f4fa8eb6c7522e0d1ca04cc9b744f0e15"],["Sources/FunctionalReadiness.swift","100644","2be9701570843b504fbc29791a564befc54f11c9"],["Sources/GuestCapabilityPlan.h","100644","3b01399c4b9c8ed4ca62243d12d4bc8b8628c142"],["Sources/GuestCapabilityWitness.swift","100644","61f99ee791917eaacf1a50c790689e1817713902"],["Sources/GuestContract.swift","100644","7c48eba52420e668353271c6e80506d415f29b41"],["Sources/GuestJournal.swift","100644","ae11bd85cf628119bea1c28357d6923724580706"],["Sources/GuestResultVerifier.swift","100644","91f00577cc25b813284fddf7cfce52c72ddf3c4a"],["Sources/GuestSupervisorGrants.swift","100644","2a9d7579f18461b20c2e212805583fe1616b23fb"],["Sources/H4D3bRestartReaderMain.swift","100644","a0a647706bf9774b1d0ecef27397a4bc0f6b2924"],["Sources/H4D3cCutPublisherMain.swift","100644","31a9268a938d2d378452688689eda1920ac28079"],["Sources/HypervisorGuest.c","100644","f4262e98bab43d9d649fa7a3b5d69d36f3cc3ec6"],["Sources/HypervisorGuest.h","100644","4630c11f629f57b7086328448fabc1c7ddb18d35"],["Sources/HypervisorH3LiveVerifier.swift","100644","3e2f7504e0d16df16c2064f41a7ddf4d1fd4bef1"],["Sources/HypervisorLabView.swift","100644","0f560c637e25dd8cde7279f167fee920fb030033"],["Sources/HypervisorModel.swift","100644","e57277d21cfffbdfd6c9bc8d71151d08460971a5"],["Sources/HypervisorStageH2Admission.swift","100644","a85b1f3965d40511c960381aaa311ca8011115a4"],["Sources/HypervisorStageH3Cursor.swift","100644","0e28d11fb01908180a346d07749e249cb7b170a3"],["Sources/HypervisorStageH4CanonicalStreams.swift","100644","8930a4ae727e3fb4a2d35cdb4713519df89f479a"],["Sources/HypervisorStageH4DualStreamPersistence.swift","100644","c54eef92afa479386723d87926779873a48d798f"],["Sources/HypervisorStageH4DualStreamRestartInspection.swift","100644","7e64fbc7d2e1f185e7a0717356fc28f864b6c877"],["Sources/HypervisorStageH4OwnerBinding.swift","100644","1b93fd605a45f2e7fef634c5bc864b3087b6c43a"],["Sources/HypervisorStageH4Persistence.swift","100644","6c021c21ee8a601f19f9d5fb5525e136a26f9b4d"],["Sources/HypervisorStageH4Privacy.swift","100644","7e640f2c8621a3b990f867421b2bafaa38d85e64"],["Sources/HypervisorStageH4PrivateVerifier.swift","100644","caf1c1159d41b6caa7571ef7b0893cf5dac24965"],["Sources/HypervisorStageH4PrivateVerifierFormat.swift","100644","b9b67f732df4cfde4a9e9fddacde7726aab713c9"],["Sources/HypervisorStageRoadmap.swift","100644","753a83403f25f07b84b0c39130a4cfbd263bfcb9"],["Sources/ManagedWorkspace.swift","100644","02cc7979b1bb2646266d785886478cd6f8c58cab"],["Sources/ManagedWorkspaceAssessmentCoordinator.swift","100644","e40a6c3766a0fa9829e16bc720bfa09dd3cfd176"],["Sources/ManagedWorkspaceAssessmentLease.swift","100644","3f321348e57ed752f9e3843e4407107d94d70e7d"],["Sources/ManagedWorkspaceObservation.swift","100644","ec7c9649e9596d06ca4aec77b3a2cd63ded4434c"],["Sources/ManagedWorkspaceProjection.swift","100644","62ebbd48c45385479f1fecfb256d6257880b2b96"],["Sources/MerkleGenesis.swift","100644","a0c6439e2aabf598ca993d9bc6ac5b36e47d5c50"],["Sources/PrimeGitModel.swift","100644","5cb5ef7b23c24bbc3fd271c42185aaf938f0a150"],["Sources/PrimeGitSnapshot.swift","100644","eb67a40352320251338d811a13827d19312b9686"],["Sources/PrimeGitView.swift","100644","98878652b8c65cbd899e1490fd1b0fb6c8a45baa"],["Sources/ProvenanceApp.swift","100644","a857dfbd24b8f494d44b9599fadbd1e214eaf203"],["Sources/ProvenanceModel.swift","100644","3c3e66a8b4ac75784f825ecf57b9c7510a6eb3c3"],["Sources/ProvenanceReadOnly.c","100644","45292fa6c53b42b600be49dce90eed82e6cb84b7"],["Sources/ProvenanceReadOnly.h","100644","1ce9ac20364d5c0aba768de040fc6744f4888016"],["Sources/ProvenanceView.swift","100644","06e84a09534f5f74b07c7c20279748eae6cfe9bb"],["Sources/ReadinessAssessment.swift","100644","3cac3999b51e633f22e76c7fb02b1b1fde29ddd8"],["Sources/ReceiptVerifier.swift","100644","b9d20980eeef9de4497f1f96d03a969963ba44aa"],["Sources/RustBootstrapContract.swift","100644","ee8e8c21cf3e2d54c69b164ca07abc9dab78d788"],["Sources/RustBootstrapImage.h","100644","87cecd4cca326b6593f3de5287f7ad2d741e2ad2"],["THIRD_PARTY_NOTICES.md","100644","1af4b8ebc384c673483a5203cb7a2f6379c59e0b"],["Tests/AppLifecycleControllerTests.swift","100644","4fb2a004fe8a8055e31b3816f79f364108c581ba"],["Tests/AppLifecyclePolicyTests.swift","100644","0eb0e43e12e3c7dd4fc8cb28f430df59bac96da5"],["Tests/CapabilityFlowClosureReference.swift","100644","20ff3690d05f038a4a6a291534e3d5c804568be8"],["Tests/CapabilityFlowClosureTests.swift","100644","46637030bd24bf9988ebf452659d4b7d1f439c92"],["Tests/CapabilityFlowRustReceiptVerifierTests.swift","100644","a532cfbffe3a710f9965e3bb60c586fabf9645c4"],["Tests/CapabilityLuminosityTests.swift","100644","f536353b23cf76b1da3b357fca428c95b84f9abf"],["Tests/DeltaPUDemoModelTests.swift","100644","bb9e5e67776a24fce1cf117bce890b003751abcd"],["Tests/DeltaPUDemoVerificationTests.swift","100644","ea852cfd6a5d9be62874e0a9cf9a5bc10d19ac04"],["Tests/DeltaPUDemonstrationTests.swift","100644","e28ccb74931eb03ef62f89eccd6defdd9aa2c85d"],["Tests/DeltaPUGUIReadinessTests.swift","100644","bdbce6163b5133970f701a732deebc40962664a4"],["Tests/DeltaPULayoutPlanTests.swift","100644","4047377a1a1aeb07952e985aaf820a72f8fc37cf"],["Tests/DeltaPUReference.swift","100644","34d4be901f9228a984af896d0ae5e21f93c6d42d"],["Tests/DeltaPUTests.swift","100644","298feb149e1e4483a9b79e5216cf2209ccdd9b15"],["Tests/DevelopmentReadinessTests.swift","100644","8d4d7d6753488fe698c5026db6d81358c8aa1ec8"],["Tests/DevelopmentRustBootExportTests.swift","100644","05e5662ceb6fcb3aa2952a3c0501372d327668a4"],["Tests/DevelopmentRustBootTests.swift","100644","1d4865ffe00f9fd3bdb59e5fd10ff239da0a14b1"],["Tests/FunctionalReadinessTests.swift","100644","9e5f66d32c9a3080e1d754e2b39d517a85b88cc4"],["Tests/GuestCapabilityNativeTests.c","100644","c2d484bcd4bc4e346be47c16bf6c84813762ea7a"],["Tests/GuestCapabilityWitnessTests.swift","100644","138d3caf1fc11072b91f1c0faabc91a87ee073ed"],["Tests/GuestH3LifecycleFaultNativeTests.c","100644","edfeb2cbeea722320adafd27aeebdd8c1cf39e35"],["Tests/GuestJournalTests.swift","100644","3a09cfb29f3fd0fb7466d8f9485d980f21a47355"],["Tests/GuestLifecycleNativeTests.c","100644","289c72bfa71f83734776bb572f947dcc799faedb"],["Tests/GuestResultVerifierTests.swift","100644","df97ed10859cf8a07e6d372288c572552639addb"],["Tests/GuestSupervisorGrantsTests.swift","100644","a5c44eadf904281ba190ce144bad28c8ea103cfc"],["Tests/HypervisorContractTests.swift","100644","a8039960c49f7815530fe56b5fa35c23c0ddbe5d"],["Tests/HypervisorH3LiveVerifierTests.swift","100644","5bf3d5e3e16395212daab0018c19c10d8cbdd1af"],["Tests/HypervisorStageH2AdmissionTests.swift","100644","a054434089e60279178b67810ccd83d64a94bb5b"],["Tests/HypervisorStageH3CursorTests.swift","100644","d6a1f0b0adb77bc9c3e7a73503e772843ca17650"],["Tests/HypervisorStageH4CanonicalStreamsTests.swift","100644","874ca885ef7528b686281155a9ad815d71006500"],["Tests/HypervisorStageH4DualStreamPersistenceTests.swift","100644","970bd7e6cc7091c356dc2c62ddc5251bf1d76016"],["Tests/HypervisorStageH4DualStreamRestartInspectionTests.swift","100644","7341286835dc5f8f4c530b3b1f5b2db90c91da6c"],["Tests/HypervisorStageH4DualStreamSigkillCutClassificationTests.swift","100644","e2d35691b056da9df7dafe0cf0a2dedebf8888fe"],["Tests/HypervisorStageH4OwnerBindingTests.swift","100644","6a1845ee263864434fa0da17b1a94278721655af"],["Tests/HypervisorStageH4PersistenceTests.swift","100644","9e52dc468bed37657fed514ab934868d93d9d0e6"],["Tests/HypervisorStageH4PrivacyTests.swift","100644","232680c4dfa2c2c999ae7f584a0055786c7446eb"],["Tests/HypervisorStageH4PrivateVerifierFormatTests.swift","100644","786b9e70f6614e8a45070d328d22067529f78163"],["Tests/HypervisorStageH4PrivateVerifierTests.swift","100644","d5a9b1b41ab5a4b8d622abc2c36b5317ee61c488"],["Tests/HypervisorStageRoadmapTests.swift","100644","65ebeb79642f8bc794683b9638dd2b62797098fc"],["Tests/ManagedWorkspaceAssessmentCoordinatorTests.swift","100644","0855ce6ff0d5927bcd7f36afa07fc1ad9428005b"],["Tests/ManagedWorkspaceAssessmentLeaseTests.swift","100644","1ed5704ff9c0cac9fad25f0db77aa2e504390eac"],["Tests/ManagedWorkspaceProjectionTests.swift","100644","306c70c4832c6aabd011f9ebc1b41f0341e4777d"],["Tests/ManagedWorkspaceTests.swift","100644","0d7214abbb4894b571e0b4a635cc87a74c02e875"],["Tests/MerkleGenesisTests.swift","100644","3ae1ae8551257cd642afe7760413c06579be176b"],["Tests/NativeSnapshotCheck.c","100644","5137cf0f5b2c82276481dbf8736b1534b321d390"],["Tests/PrimeGitSnapshotTests.swift","100644","d9f90d0fd61b34c811fd7d1924ded80dcda37baf"],["Tests/ReadinessAssessmentTests.swift","100644","33640926ff86eada345b5aa943da755509f2d87a"],["Tests/ReceiptVerifierTests.swift","100644","8749f221b50ae3059f8fed0a5660129d49aaeb7c"],["Tests/RustBootstrapVerifierTests.swift","100644","1c6a1114a8f10938295dbb47d64a571e7d8a815d"],["Tools/CapabilityFlowRustReceiptVerifier/main.rs","100644","7a7ff0cf39a797b2d7603cc6935a7e41b9efa0a2"],["Tools/GenerateAppIcon.swift","100644","e0c4861de55da16a66211ce12b9d51022dbcd965"],["Tools/GenerateSPDX.swift","100644","a2d18fc1ebc4ab396e1d7245441b6c6589c28390"],["Tools/RenderPrimeGitPreview.swift","100644","2a08f001f710b743cca1718cef60ccafacd1a277"]]"#.utf8)
    private let contractBytes = Data(#"{"allowlist":["ErgenticsProvenance.xcodeproj/project.pbxproj","ErgenticsProvenance.xcodeproj/xcshareddata/xcschemes/ErgenticsProvenanceH3Qualification.xcscheme","Sources/DevelopmentLaunch.swift","Sources/ProvenanceApp.swift","Sources/ProvenanceModel.swift","Sources/HypervisorModel.swift","Sources/HypervisorH3LiveVerifier.swift","Sources/DevelopmentRustBootExport.swift","Sources/H3QualificationProtocol.swift","Sources/H3QualificationCoordinator.swift","Tools/H3QualificationSeal/h3_qualification_seal.rb","Tools/H3QualificationController/main.swift","Tools/H3QualificationController/H3QualificationControllerPolicy.swift","Tools/H3QualificationController/H3QualificationProcess.swift","Tools/H3QualificationController/H3QualificationSigning.swift","Tools/H3QualificationController/H3QualificationStorage.swift","Tests/H3QualificationRunnerTests.swift"],"build_debug":["/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild","-project","/Users/ergentics/Developer/ErgenticsProvenance/ErgenticsProvenance.xcodeproj","-scheme","ErgenticsProvenanceH3Qualification","-configuration","Debug","-destination","platform=macOS,arch=arm64","-derivedDataPath","/private/tmp/ergentics-h3q-debug-v1","SWIFT_ACTIVE_COMPILATION_CONDITIONS=$(inherited) EPR_H3_QUALIFICATION","CODE_SIGNING_ALLOWED=YES","build"],"build_release":["/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild","-project","/Users/ergentics/Developer/ErgenticsProvenance/ErgenticsProvenance.xcodeproj","-scheme","ErgenticsProvenanceH3Qualification","-configuration","Release","-destination","platform=macOS,arch=arm64","-derivedDataPath","/private/tmp/ergentics-h3q-release-v1","SWIFT_ACTIVE_COMPILATION_CONDITIONS=$(inherited) EPR_H3_QUALIFICATION","CODE_SIGNING_ALLOWED=YES","build"],"environment":["DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer","GIT_CONFIG_GLOBAL=/dev/null","GIT_CONFIG_NOSYSTEM=1","GIT_NO_LAZY_FETCH=1","GIT_OPTIONAL_LOCKS=0","HOME=/Users/ergentics","LANG=C","LC_ALL=C","LOGNAME=ergentics","PATH=/usr/bin:/bin:/usr/sbin:/sbin","TMPDIR=/private/tmp/","USER=ergentics","__CF_USER_TEXT_ENCODING=0x1F5:0x0:0x0"],"pins":[{"git_blob":"b5fd9b2e1c72f54924269b6ff9453f87abeae5f2","path":"ErgenticsProvenance.xcodeproj/project.pbxproj","sha256":"93a0ff15e38859a9f74268861a1c18803f514f0f8be7af9bc4b22d6f59ea9561"},{"git_blob":"412b603ef4b0ca473dbae34dbd8051690e01a7b8","path":"ErgenticsProvenance.xcodeproj/xcshareddata/xcschemes/ErgenticsProvenance.xcscheme","sha256":"3a34c15f9ecb369fd18956ee671fa3b67d83414d6af35c4a9a486bcca1df4666"},{"git_blob":"d7bd491f0c772584a3bfa1b977306e3f31941bf4","path":"Entitlements.plist","sha256":"ffab5dd538d1fc0aefa6b0e7facf2dcc4f0927845db0806b2bec82a617b2dcf2"},{"git_blob":"c0814a3454b30ccf83b888ab1899c1779c2f96c8","path":"Sources/DevelopmentLaunch.swift","sha256":"c5470f01af214bd52b0f4b9048a54900de04a33e4974c53685f7da83ba4f10f6"},{"git_blob":"a857dfbd24b8f494d44b9599fadbd1e214eaf203","path":"Sources/ProvenanceApp.swift","sha256":"ce66b6846cd08a9a7058d77d9a59b2da781364544b4cf6f2460b4e0fe2cd57cb"},{"git_blob":"3c3e66a8b4ac75784f825ecf57b9c7510a6eb3c3","path":"Sources/ProvenanceModel.swift","sha256":"c4eb9d1fa4e5d69a48db70e26029090aa939e6eaf95d223cc25b86716f1ecb28"},{"git_blob":"45292fa6c53b42b600be49dce90eed82e6cb84b7","path":"Sources/ProvenanceReadOnly.c","sha256":"78c4d4e2e8e4b50ee81b5a671b127dfb2fdad2ec812b67314bf6553af37fd0c6"},{"git_blob":"e57277d21cfffbdfd6c9bc8d71151d08460971a5","path":"Sources/HypervisorModel.swift","sha256":"216a72a262f275ae9e1c6da57e3cb35ee9f76bcac41db484e7c9c80a27a36ede"},{"git_blob":"f4262e98bab43d9d649fa7a3b5d69d36f3cc3ec6","path":"Sources/HypervisorGuest.c","sha256":"006b15327db939ad930ef8594eca61b5bbd71cc243250caee9393fbf539baf87"},{"git_blob":"4630c11f629f57b7086328448fabc1c7ddb18d35","path":"Sources/HypervisorGuest.h","sha256":"d663619e58a267dce936a4551ba69a493c238fa9c6897ef68ebf003fa9dbb58d"},{"git_blob":"3e2f7504e0d16df16c2064f41a7ddf4d1fd4bef1","path":"Sources/HypervisorH3LiveVerifier.swift","sha256":"3072f6b85a310ddc8c3a7bf5eedb8fe7ef7cfcd86fedd9d7b56593e5a54666cd"},{"git_blob":"6c39514d5d617bbf95d5eef81fcb0a7ac49cd3d9","path":"Sources/DevelopmentRustBootExport.swift","sha256":"71cf5756b23e02bb139f7521d719d0620b62b1a3e1b6365bba6e5bf4fe93f1a9"},{"git_blob":"0abbf5d5cc460b6c8f042e6f80b9edf137b33182","path":"Guest/cursor-resume.S","sha256":"5c0461d4d61bf798c334e33f822ff37f9e8f0b1a3272f812d4d2154ace4197a3"}],"product_argv":[["/usr/bin/shasum","-a","256","<product_executable>"],["/usr/bin/dwarfdump","--uuid","<product_executable>"],["/usr/bin/codesign","--verify","--strict","--all-architectures","<product_bundle_or_executable>"],["/usr/bin/codesign","-d","--verbose=4","--requirements","-","--entitlements",":-","<product_bundle_or_executable>"],["/usr/bin/otool","-L","<product_executable>"],["/usr/bin/nm","-gju","<product_executable>"]],"settings":{"application_settings":{"CODE_SIGN_ENTITLEMENTS":"Entitlements.plist","ENABLE_APP_SANDBOX":"YES","EXECUTABLE_NAME":"Ergentics Provenance","EXECUTABLE_PATH":"Ergentics Provenance.app/Contents/MacOS/Ergentics Provenance","FULL_PRODUCT_NAME":"Ergentics Provenance.app","PRODUCT_BUNDLE_IDENTIFIER":"com.ergentics.provenance","PRODUCT_NAME":"Ergentics Provenance","TARGET_NAME":"ErgenticsProvenance"},"application_target":"ErgenticsProvenance","configuration_settings":{"DEBUG":{"CONFIGURATION":"Debug","SWIFT_ACTIVE_COMPILATION_CONDITIONS":"DEBUG EPR_H3_QUALIFICATION","TARGET_BUILD_DIR":"/private/tmp/ergentics-h3q-debug-v1/Build/Products/Debug"},"RELEASE":{"CONFIGURATION":"Release","SWIFT_ACTIVE_COMPILATION_CONDITIONS":"EPR_H3_QUALIFICATION","TARGET_BUILD_DIR":"/private/tmp/ergentics-h3q-release-v1/Build/Products/Release"}},"controller_settings":{"CODE_SIGN_ENTITLEMENTS":"ABSENT_KEY","CODE_SIGN_INJECT_BASE_ENTITLEMENTS":"NO","CREATE_INFOPLIST_SECTION_IN_BINARY":"YES","ENABLE_APP_SANDBOX":"NO","EXECUTABLE_NAME":"ErgenticsProvenanceH3QualificationController","EXECUTABLE_PATH":"ErgenticsProvenanceH3QualificationController","FULL_PRODUCT_NAME":"ErgenticsProvenanceH3QualificationController","GENERATE_INFOPLIST_FILE":"YES","PRODUCT_BUNDLE_IDENTIFIER":"com.ergentics.provenance.h3-qualification-controller","PRODUCT_NAME":"ErgenticsProvenanceH3QualificationController","SKIP_INSTALL":"YES","TARGET_NAME":"ErgenticsProvenanceH3QualificationController"},"controller_target":"ErgenticsProvenanceH3QualificationController","derived_path_rules":"For each record, BUILT_PRODUCTS_DIR and CONFIGURATION_BUILD_DIR equal TARGET_BUILD_DIR. TARGET_BUILD_DIR plus FULL_PRODUCT_NAME/EXECUTABLE_PATH derives exactly the frozen concrete product bundle/executable, with canonical containment below that configuration's one DerivedData path. No setting may resolve through a caller-selected path.","parse":"Read exactly 1...1048576 bytes, require strict UTF-8, and use an iterative duplicate-key-rejecting JSON parser with maximum nesting depth 32, 65536 total value tokens, 8192 members in any object, 4096 elements in any array, 262144 decoded UTF-8 bytes in any string, and 2097152 cumulative decoded string bytes. The root is an array of exactly two objects, each containing exactly action, buildSettings, and target; every key and value inside buildSettings is a string, each key is at most 1024 UTF-8 bytes, and action/target are at most 256 UTF-8 bytes. Numbers, booleans, null, invalid escapes/scalars, trailing bytes, any limit excess, arithmetic overflow, and parser recursion are rejected. action is exactly build, matching the explicit literal action in both fixed settings argv arrays; target is unique and the records are normalized to APPLICATION then CONTROLLER before comparison. Unknown buildSettings keys are retained by the raw artifact hash but may not substitute for, contradict, or suppress any required key.","required_common_settings":{"ARCHS":"arm64","CODE_SIGNING_ALLOWED":"YES","CODE_SIGNING_REQUIRED":"YES","CODE_SIGN_IDENTITY":"Apple Development","CODE_SIGN_STYLE":"Automatic","DEVELOPMENT_TEAM":"ZCQ435U8JP","ENABLE_HARDENED_RUNTIME":"YES","MACOSX_DEPLOYMENT_TARGET":"26.0","PLATFORM_NAME":"macosx","SDKROOT":"/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX26.5.sdk","SWIFT_VERSION":"6.0"}},"source_argv":[["/usr/bin/git","--no-replace-objects","--git-dir=/Users/ergentics/Developer/ErgenticsProvenance/.git","--work-tree=/Users/ergentics/Developer/ErgenticsProvenance","rev-parse","HEAD"],["/usr/bin/git","--no-replace-objects","--git-dir=/Users/ergentics/Developer/ErgenticsProvenance/.git","--work-tree=/Users/ergentics/Developer/ErgenticsProvenance","rev-parse","HEAD^{tree}"],["/usr/bin/git","--no-replace-objects","--git-dir=/Users/ergentics/Developer/ErgenticsProvenance/.git","--work-tree=/Users/ergentics/Developer/ErgenticsProvenance","rev-parse","<freeze_commit>^{tree}"],["/usr/bin/git","--no-replace-objects","--git-dir=/Users/ergentics/Developer/ErgenticsProvenance/.git","--work-tree=/Users/ergentics/Developer/ErgenticsProvenance","diff","--raw","--no-abbrev","--no-renames","--no-ext-diff","--no-textconv","-z","461af031064b0529e7432b1f6cf0cfc2cbccec48..<freeze_commit>","--"],["/usr/bin/git","--no-replace-objects","--git-dir=/Users/ergentics/Developer/ErgenticsProvenance/.git","--work-tree=/Users/ergentics/Developer/ErgenticsProvenance","diff","--raw","--no-abbrev","--no-renames","--no-ext-diff","--no-textconv","-z","<freeze_commit>..<implementation_commit>","--"],["/usr/bin/git","--no-replace-objects","--git-dir=/Users/ergentics/Developer/ErgenticsProvenance/.git","--work-tree=/Users/ergentics/Developer/ErgenticsProvenance","-c","core.quotePath=false","diff","--no-ext-diff","--no-textconv","--name-only","--no-renames","-z","<freeze_commit>..<implementation_commit>","--"],["/usr/bin/git","--no-replace-objects","--git-dir=/Users/ergentics/Developer/ErgenticsProvenance/.git","--work-tree=/Users/ergentics/Developer/ErgenticsProvenance","ls-tree","-r","-z","--full-tree","<implementation_commit>"],["/usr/bin/git","--no-replace-objects","--git-dir=/Users/ergentics/Developer/ErgenticsProvenance/.git","--work-tree=/Users/ergentics/Developer/ErgenticsProvenance","cat-file","--batch"],["/usr/bin/git","--no-replace-objects","--git-dir=/Users/ergentics/Developer/ErgenticsProvenance/.git","--work-tree=/Users/ergentics/Developer/ErgenticsProvenance","ls-files","--stage","-z","--"]],"toolchain_argv":[["/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild","-version"],["/usr/bin/xcrun","--sdk","macosx","--show-sdk-version"],["/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swiftc","--version"],["/usr/bin/ruby","--disable=gems,rubyopt,did_you_mean","-v"],["/usr/bin/shasum","-a","256","/usr/bin/ruby"],["/usr/bin/codesign","-d","--verbose=4","/usr/bin/ruby"],["/usr/bin/shasum","-a","256","/usr/bin/env"],["/usr/bin/codesign","-d","--verbose=4","/usr/bin/env"],["/usr/bin/sw_vers","-buildVersion"],["/usr/bin/uname","-m"]],"vocabulary":["application.h3_preparation","application.live_self_signing_admission","native.abi","native.cancellation","native.chronology","native.conservation","native.counts","native.cursor","native.execution","native.outcome","native.phase_source","native.phase_target","native.quarantine","native.signing","native.status","native.teardown","native.watchdog","runner.application_identity","runner.authority_boundary","runner.build_identity","runner.cancellation","runner.deadline","runner.environment","runner.exit","runner.export","runner.gate","runner.inner_frame","runner.monitor","runner.run_identity","runner.signal","runner.spawn","runner.stderr","runner.timing","swift.checkpoint_diagnostic","swift.checkpoint_merkle","swift.cursor_reconstruction","swift.fixed_image","swift.fixed_replies","swift.live_graph","swift.live_projection","swift.live_receipt","swift.readiness_contract","swift.sctlr_transition","swift.terminal_merkle"]}"#.utf8)
    private let zero = String(repeating: "0", count: 64)
    private let toolchainBytes = Data(#"{"architecture":"arm64","macos_build":"25G83","macos_sdk":"26.5","probes":[],"seal_launcher_cdhash":"a6a8e7d5551056079e931c3b7f491ef3d41e3780","seal_launcher_identifier":"com.apple.env","seal_launcher_path":"/usr/bin/env","seal_launcher_sha256":"75690864f0e7397db05bcc0f4439915559ce24c2d834d530e4e619c14b938556","seal_runtime_cdhash":"6f4f8341f32e8e479783aa9e2fc9518693472df2","seal_runtime_identifier":"com.apple.ruby","seal_runtime_path":"/usr/bin/ruby","seal_runtime_platform":"universal.arm64e-darwin25","seal_runtime_revision":"67958","seal_runtime_sha256":"4d57327e7abe67e1c3f84a0869f4239b3324a3d7ea20a70077450e688282fe4f","seal_runtime_support_pins_sha256":"0273e30aa84370d5aa2440e1e870b3319f6a6a6fed81f9143f208da8f0833f2b","seal_runtime_version":"2.6.10p210","swift_build":"swiftlang-6.3.3.1.3 clang-2100.1.1.101","swift_driver_version":"1.148.6","swift_target":"arm64-apple-macosx26.0","swift_version":"6.3.3","swiftc_path":"/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swiftc","xcode_build":"17F113","xcode_version":"26.6","xcodebuild_path":"/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild"}"#.utf8)
    private let batchBytes = Data(#"{"argv":[],"auxiliary_object_count":3,"clean_match_count":1,"cwd":"/Users/ergentics/Developer/ErgenticsProvenance","dirty_exception_count":2,"entry_count":1,"entry_join_sha256":"0000000000000000000000000000000000000000000000000000000000000000","environment":[],"exit_status":0,"freeze_commit_byte_count":1,"freeze_commit_parent":"461af031064b0529e7432b1f6cf0cfc2cbccec48","freeze_commit_parent_count":1,"freeze_commit_recomputed_oid":"1111111111111111111111111111111111111111","freeze_commit_sha256":"0000000000000000000000000000000000000000000000000000000000000000","freeze_commit_tree":"1111111111111111111111111111111111111111","freeze_reconstructed_tree":"1111111111111111111111111111111111111111","implementation_commit_byte_count":1,"implementation_commit_parent":"1111111111111111111111111111111111111111","implementation_commit_parent_count":1,"implementation_commit_recomputed_oid":"1111111111111111111111111111111111111111","implementation_commit_sha256":"0000000000000000000000000000000000000000000000000000000000000000","implementation_commit_tree":"1111111111111111111111111111111111111111","implementation_reconstructed_tree":"1111111111111111111111111111111111111111","listing_sha256":"0000000000000000000000000000000000000000000000000000000000000000","pbx_baseline_blob_byte_count":1,"pbx_baseline_blob_oid":"b5fd9b2e1c72f54924269b6ff9453f87abeae5f2","pbx_baseline_blob_recomputed_oid":"b5fd9b2e1c72f54924269b6ff9453f87abeae5f2","pbx_baseline_blob_sha256":"93a0ff15e38859a9f74268861a1c18803f514f0f8be7af9bc4b22d6f59ea9561","predecessor_reconstructed_tree":"829331092cdc290f1a0e651fd64a9a56dd4187d2","request_byte_count":1,"request_sha256":"0000000000000000000000000000000000000000000000000000000000000000","response_byte_count":1,"response_sha256":"0000000000000000000000000000000000000000000000000000000000000000","stderr":{"base64":"","byte_count":0,"sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855","truncated":false},"stdin_closed":true,"stdout_eof":true,"tree_reconstruction_join_sha256":"0000000000000000000000000000000000000000000000000000000000000000"}"#.utf8)
    private let environment = ["DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer", "GIT_CONFIG_GLOBAL=/dev/null", "GIT_CONFIG_NOSYSTEM=1", "GIT_NO_LAZY_FETCH=1", "GIT_OPTIONAL_LOCKS=0", "HOME=/Users/ergentics", "LANG=C", "LC_ALL=C", "LOGNAME=ergentics", "PATH=/usr/bin:/bin:/usr/sbin:/sbin", "TMPDIR=/private/tmp/", "USER=ergentics", "__CF_USER_TEXT_ENCODING=0x1F5:0x0:0x0"]
    private func array(_ strings: [String]) -> V { .array(strings.map(V.string)) }
    private func hash(_ text: String) -> String { H3QualificationProtocol.hash(Data(text.utf8)) }
    private func changed(_ value: V, _ key: String, _ replacement: V) -> V {
        var fields = value.objectValue!; fields[key] = replacement; return .object(fields)
    }
    private func stream(_ text: String) -> V {
        let bytes = Data(text.utf8)
        return .object(["base64": .string(bytes.base64EncodedString()), "byte_count": .integer(Int64(bytes.count)), "sha256": .string(H3QualificationProtocol.hash(bytes)), "truncated": .bool(false)])
    }
    private func code(_ configuration: H3QualificationConfiguration = .debug, app: Bool = true) throws -> V {
        let identifier = app ? "com.ergentics.provenance" : "com.ergentics.provenance.h3-qualification-controller"
        let base = "/private/tmp/ergentics-h3q-\(configuration == .debug ? "debug" : "release")-v1/Build/Products/\(configuration == .debug ? "Debug" : "Release")/" + (app ? "Ergentics Provenance.app" : "ErgenticsProvenanceH3QualificationController")
        let executable = base + (app ? "/Contents/MacOS/Ergentics Provenance" : "")
        let entitlements: V = app ? .object(["com.apple.security.app-sandbox": .bool(true), "com.apple.security.files.user-selected.read-only": .bool(true), "com.apple.security.hypervisor": .bool(true)]) : .null
        return .object(["cdhash": .string(String(repeating: app ? "a" : "b", count: 40)), "code_object_path": .string(base), "designated_requirement": .string("anchor apple generic and identifier \"\(identifier)\" and certificate leaf[subject.OU] = \"ZCQ435U8JP\""), "entitlements": entitlements, "entitlements_sha256": .string(H3QualificationProtocol.hash(try H3QualificationCanonicalJSON.encode(entitlements))), "executable_path": .string(executable), "executable_sha256": .string(hash(executable)), "identifier": .string(identifier), "macho_uuid": .string("01234567-89ab-cdef-0123-456789abcdef"), "runtime": .bool(true), "team_identifier": .string("ZCQ435U8JP"), "valid": .bool(true)])
    }
    private func vnode(mode: Int64 = 493, inode: Int = 42, links: Int = 1) -> V {
        .object(["device": .string("1"), "generation": .integer(0), "inode": .string(String(inode)), "link_count": .string(String(links)), "mode": .integer(mode), "owner": .integer(501)])
    }
    private func controller(_ configuration: H3QualificationConfiguration = .debug) throws -> V {
        .object(["code": try code(configuration, app: false), "held_at_start": vnode(inode: 50), "named_at_start": vnode(inode: 50), "pid": .integer(123)])
    }
    private func productAudit(_ configuration: H3QualificationConfiguration = .debug) throws -> V {
        var probes: [V] = []
        for app in [true, false] {
            let claim = try code(configuration, app: app), path = claim["executable_path"]!.stringValue!, base = claim["code_object_path"]!.stringValue!
            let argv = [["/usr/bin/shasum", "-a", "256", path], ["/usr/bin/dwarfdump", "--uuid", path], ["/usr/bin/codesign", "--verify", "--strict", "--all-architectures", base], ["/usr/bin/codesign", "-d", "--verbose=4", "--requirements", "-", "--entitlements", ":-", base], ["/usr/bin/otool", "-L", path], ["/usr/bin/nm", "-gju", path]]
            let entitlements = app ? "[Dict]\n\t[Key] com.apple.security.app-sandbox\n\t[Value]\n\t\t[Bool] true\n\t[Key] com.apple.security.files.user-selected.read-only\n\t[Value]\n\t\t[Bool] true\n\t[Key] com.apple.security.hypervisor\n\t[Value]\n\t\t[Bool] true\n" : ""
            let metadata = "Executable=\(path)\nIdentifier=\(claim["identifier"]!.stringValue!)\nCodeDirectory v=20500 size=123 flags=0x10000(runtime) hashes=5+7 location=embedded\nAuthority=Apple Development: SYNTHETIC TEST\nAuthority=Apple Worldwide Developer Relations Certification Authority\nAuthority=Apple Root CA\nTeamIdentifier=ZCQ435U8JP\nCDHash=\(claim["cdhash"]!.stringValue!)\n"
            let outputs = [claim["executable_sha256"]!.stringValue! + "  " + path + "\n", "UUID: \(claim["macho_uuid"]!.stringValue!.uppercased()) (arm64) \(path)\n", "", "designated => \(claim["designated_requirement"]!.stringValue!)\n" + entitlements, path + ":\n\t/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1354.0.0)\n", "_exit\n"]
            for index in 0..<6 { probes.append(.object(["argv": array(argv[index]), "cwd": .string("/private/var/empty"), "environment": array(environment), "exit_status": .integer(0), "stdout": stream(outputs[index]), "stderr": stream(index == 3 ? metadata : "")])) }
        }
        return .object(["application": try code(configuration), "configuration": .string(configuration.rawValue), "controller": try code(configuration, app: false), "controller_hypervisor_load_commands": .integer(0), "controller_hypervisor_symbols": .integer(0), "probes": .array(probes), "schema": .string("com.ergentics.provenance.h3-qualification-product-audit.v1"), "version": .integer(1)])
    }
    private func admission(_ configuration: H3QualificationConfiguration = .debug, signingError: Int32? = nil) throws -> V {
        let claim = try code(configuration), admitted = signingError == nil
        let nonce = String(repeating: configuration == .debug ? "1" : "2", count: 64)
        let signing: V = admitted ? .object(["admitted": .bool(true), "effective_entitlements": claim["entitlements"]!, "effective_entitlements_sha256": claim["entitlements_sha256"]!, "error": .integer(0), "native_result": .integer(1), "status": .string("ADMITTED")]) : .object(["admitted": .bool(false), "error": .integer(Int64(signingError!)), "native_result": .integer(signingError == 0 ? 0 : -1), "status": .string(signingError == 0 ? "REJECTED" : "API_ERROR")])
        return .object([
            "authority": .object(["authority_effect": .string("NONE"), "authority_vector": .string("00000000"), "gate_e": .string("ABSTAIN"), "h4_entered": .bool(false), "prime_git_entered": .bool(false), "sqlite_opened": .bool(false)]),
            "build": .object(["configuration": .string(configuration.rawValue), "guest_abi_version": .integer(5), "guest_image_byte_count": .integer(136), "guest_image_sha256": .string("3c03199c6ae993fa5c316a497cf4d59d590ee0e1a4488b598d8da385f38af8b0"), "guest_profile_id": .string("H3_CURSOR_RESUME"), "qualification_variant": .bool(true)]),
            "cancellation_monitor": .object(["bytes_observed": .integer(0), "disposition": .string("COMPLETION_FIRST"), "fd_closed": .bool(true), "poll_calls": .integer(1), "read_calls": .integer(0), "route_calls": .integer(0), "started_tick": .string("104"), "task_joined": .bool(true), "terminal_tick": .string("105")]),
            "effects": .object(["app_launched": .bool(true), "guest_entered_count": .integer(0), "helper_processes": .integer(0), "hv_vm_created_count": .integer(0), "lifecycle_disposition": .string("NOT_ENTERED"), "prime_git_entries": .integer(0), "reservation_entries": .integer(0), "reservation_release_entries": .integer(0), "reservation_release_status": .integer(Int64(Int32.min)), "runner_location": .string("EVALUATED_MAC_EXTERNAL_CONTROLLER"), "signals_observed_before_report": .integer(0), "signing_state": signing["status"]!, "storage_entries": .integer(0), "subject_location": .string("EVALUATED_MAC_SIGNED_PRODUCT_APPLICATION")]),
            "gate": .object(["accepted": .bool(true), "frame_sha256": .string(H3QualificationProtocol.hash(try H3QualificationProtocol.gateFrame(mode: .admissionOnly, nonce: nonce))), "mode_byte": .string("01"), "validated_tick": .string("103")]),
            "native": .object(["disposition": .string("NOT_ENTERED"), "preparation_error": .integer(Int64(Int32.min)), "reason": .string(admitted ? "ADMISSION_MODE" : "SIGNING_REJECTED")]),
            "process": .object(["bundle_identifier": .string("com.ergentics.provenance"), "environment_count": .integer(5), "environment_names": array(["APP_SANDBOX_CONTAINER_ID", "CFFIXED_USER_HOME", "HOME", "TMPDIR", "__CF_USER_TEXT_ENCODING"]), "environment_observation": .string("OBSERVED_AFTER_FRAMEWORK_START_FROM_EMPTY_ENVP_ORIGIN_UNATTRIBUTED"), "pid": .integer(124), "team_identifier": .string("ZCQ435U8JP")]),
            "run": .object(["configuration": .string(configuration.rawValue), "mode": .string("ADMISSION_ONLY"), "nonce": .string(nonce), "run_id": .string(try H3QualificationProtocol.runID(mode: .admissionOnly, configuration: configuration, nonce: nonce))]), "schema": .string("com.ergentics.provenance.h3-qualification-inner.v1"), "signing": signing,
            "timing": .object(["continuous_start_tick": .string("101"), "continuous_end_tick": .string("106"), "timebase_denominator": .integer(1), "timebase_numerator": .integer(1)]), "verifier": .object(["disposition": .string("NOT_ENTERED")]), "version": .integer(1)])
    }
    private func receipt(_ inner: V) throws -> V {
        let config = H3QualificationConfiguration(rawValue: inner["run"]!["configuration"]!.stringValue!)!, claim = try code(config)
        let guest = inner["run"]?["mode"] == .string("GUEST")
        let nonce = inner["run"]!["nonce"]!.stringValue!, admitted = inner["signing"]?["admitted"] == .bool(true)
        let frame = try H3QualificationProtocol.frame(payload: inner)
        var cancel = Data("EPRH3C01".utf8); cancel.append(try H3QualificationProtocol.unhex(nonce, bytes: 32))
        let application: V = .object(["dynamic": claim, "held_after_reap": vnode(), "held_before_gate": vnode(), "held_before_spawn": vnode(), "named_after_reap": vnode(), "named_before_gate": vnode(), "named_before_spawn": vnode(), "post_static": claim, "pre_static": claim, "proc_pidpath": claim["executable_path"]!])
        return .object([
            "application": application, "child": .object(["disposition": .string("REAPED"), "exit": .integer(0), "pid": .integer(124), "reap": .string("EXACT_PID_REAPED"), "signal": .string("NOT_APPLICABLE"), "wait_status": .integer(0)]),
            "classification": .object(["failed_predicates": array(admitted ? [] : ["application.live_self_signing_admission"]), "result": .string(admitted ? "RUN_CANDIDATE_PASS" : "RETAINED_NONPASS")]), "controller_claim": try controller(config),
            "deadlines": .object(["cancel_tick": .string("0"), "gate_attempt_tick": .string("102"), "gate_deadline_tick": .string("5000000100"), "gate_return_tick": .string("104"), "kill_attempt_tick": .string("0"), "kill_deadline_tick": .string("15000000100"), "operation_deadline_tick": .string("10000000100"), "reap_tick": .string("107"), "spawn_tick": .string("100"), "terminal_horizon_tick": .string("20000000100"), "terminal_tick": .string("108"), "timebase_denominator": .integer(1), "timebase_numerator": .integer(1)]),
            "evidence": .object(["build_source_manifest_sha256": .string(zero), "effective_entitlements_sha256": admitted ? claim["entitlements_sha256"]! : .string(zero), "effective_hypervisor_value": .string(admitted ? "TRUE" : "NOT_OBSERVED"), "hypervisor_support": .string(guest ? "NATIVE_ENTRY_SUCCEEDED" : "NOT_QUERIED"), "inner_byte_count": .integer(Int64(frame.count)), "inner_eof": .bool(true), "inner_sha256": .string(H3QualificationProtocol.hash(frame)), "inner_valid": .bool(true), "product_audit_sha256": .string(zero), "root_identity": vnode(mode: 448, inode: 60, links: 2), "stdout_identity_terminal": vnode(mode: 384, inode: 61)]),
            "gate": .object(["cancel_errno": .integer(0), "cancel_frame_sha256": .string(H3QualificationProtocol.hash(cancel)), "cancel_return": .integer(Int64(Int32.min)), "cancel_writes": .integer(0), "gate_errno": .integer(0), "gate_frame_sha256": inner["gate"]!["frame_sha256"]!, "gate_return": .integer(41), "gate_writes": .integer(1)]),
            "host": .object(["architecture": .string("arm64"), "macos_build": .string("25G83"), "macos_version": .string("26.5.2")]), "kill": .object(["attempted": .bool(false), "errno": .integer(0), "pid": .integer(124), "return": .integer(Int64(Int32.min))]), "run": inner["run"]!, "schema": .string("com.ergentics.provenance.h3-qualification-outer-receipt.v1"),
            "spawn": .object(["argv": array([guest ? "--h3-qualification-guest-once" : "--h3-qualification-admission-once", nonce]), "attributes": .string("CLOEXEC_DEFAULT_EMPTY_MASK_DEFAULT_CATCHABLE_SIGNALS"), "cwd": .string("/private/var/empty"), "environment_count": .integer(0), "fd_map": .string("0=devnull-ro,1=regular-rw-0600,2=pipe,3=gate-ro,4=cancel-ro"), "spawn_return": .integer(0)]),
            "stderr": .object(["eof": .bool(true), "overflow": .bool(false), "retained_byte_count": .integer(0), "retained_sha256": .string(hash("")), "total_byte_count": .integer(0)]),
            "taxonomy": .object(["app_launched": .bool(true), "authority_effect": .string("NONE"), "guest_entered_count": inner["effects"]!["guest_entered_count"]!, "helper_processes": .integer(0), "hv_vm_created_count": inner["effects"]!["hv_vm_created_count"]!, "runner_location": .string("EVALUATED_MAC_EXTERNAL_CONTROLLER"), "signals": .integer(0), "signing_state": inner["signing"]!["status"]!, "sqlite_opened": .bool(false), "subject_location": .string("EVALUATED_MAC_SIGNED_PRODUCT_APPLICATION")]), "version": .integer(1)])
    }
    private func encoded(_ value: V) throws -> Data { try H3QualificationCanonicalJSON.encode(value, maximumBytes: 262_144) }
    private func contract() throws -> V { try H3QualificationCanonicalJSON.decode(contractBytes, maximumBytes: 262_144) }
    private func gitHash(_ payload: Data, kind: String) -> String {
        var bytes = Data((kind + " " + String(payload.count)).utf8); bytes.append(0); bytes.append(payload)
        return Insecure.SHA1.hash(data: bytes).map { String(format: "%02x", $0) }.joined()
    }
    private func gitTree(_ rows: [[String]]) throws -> String {
        try gitTreeDetails(rows).0
    }
    private func gitTreeDetails(_ rows: [[String]]) throws -> (String, V) {
        var treeRecords: [V] = []
        func subtree(_ records: [[String]], prefix: String) throws -> String {
            var leaves: [(String, String, String)] = [], children: [String: [[String]]] = [:]
            for record in records {
                let suffix = String(record[0].dropFirst(prefix.count))
                if let slash = suffix.firstIndex(of: "/") { children[String(suffix[..<slash]), default: []].append(record) }
                else { leaves.append((suffix, record[1], record[2])) }
            }
            for (child, records) in children { leaves.append((child + "/", "40000", try subtree(records, prefix: prefix + child + "/"))) }
            var payload = Data()
            for (name, mode, oid) in leaves.sorted(by: { $0.0.utf8.lexicographicallyPrecedes($1.0.utf8) }) {
                payload.append(contentsOf: (mode + " " + (mode == "40000" ? String(name.dropLast()) : name)).utf8); payload.append(0)
                payload.append(try H3QualificationProtocol.unhex(oid, bytes: 20))
            }
            let hash = gitHash(payload, kind: "tree")
            treeRecords.append(.object(["oid": .string(hash), "path": .string(prefix.isEmpty ? "" : String(prefix.dropLast())), "payload_byte_count": .integer(Int64(payload.count)), "payload_sha256": .string(H3QualificationProtocol.hash(payload))]))
            return hash
        }
        let root = try subtree(rows, prefix: "")
        treeRecords.sort { $0["path"]!.stringValue! < $1["path"]!.stringValue! }
        let summary: V = .object(["blob_count": .integer(Int64(rows.count)), "root_oid": .string(root), "subtree_count": .integer(Int64(treeRecords.count)), "trees_sha256": .string(H3QualificationProtocol.hash(try encoded(.array(treeRecords))))])
        return (root, summary)
    }
    private func sourceState() throws -> V {
        let contract = try contract(), frozen = try H3QualificationCanonicalJSON.decode(frozenTreeBytes, maximumBytes: 262_144).arrayValue!.map { $0.arrayValue!.map { $0.stringValue! } }
        let delta = contract["allowlist"]!.arrayValue!.map { $0.stringValue! }.sorted()
        var byPath = Dictionary(uniqueKeysWithValues: frozen.map { ($0[0], $0) }), rawDelta = "", pins: [V] = []
        for path in delta {
            let body = Data(("SYNTHETIC IMPLEMENTATION " + path).utf8), oid = gitHash(body, kind: "blob"), old = byPath[path]
            rawDelta += ":\(old?[1] ?? "000000") 100644 \(old?[2] ?? String(repeating: "0", count: 40)) \(oid) \(old == nil ? "A" : "M")\0\(path)\0"
            byPath[path] = [path, "100644", oid]
            pins.append(.object(["path": .string(path), "sha256": .string(H3QualificationProtocol.hash(body))]))
        }
        let rows = byPath.values.sorted { $0[0] < $1[0] }, tree = try gitTree(rows), freeze = "245382fb61fb94fe8ef29bcbfa00d6f39fa7d14a"
        let commitPayload = Data(("tree \(tree)\nparent \(freeze)\nauthor Synthetic <fixture@invalid> 0 +0000\ncommitter Synthetic <fixture@invalid> 0 +0000\n\nFixture only\n").utf8)
        let implementation = gitHash(commitPayload, kind: "commit")
        let source: V = .object(["delta_path_pins": .array(pins), "delta_paths": array(delta), "freeze_commit": .string(freeze), "freeze_tree": .string("fc44ef370d3ff8888e4dfecbc3901fc0ec1a5600"), "frozen_input_pins": .array(contract["pins"]!.arrayValue!.filter { !delta.contains($0["path"]!.stringValue!) }.map { .object(["path": $0["path"]!, "sha256": $0["sha256"]!]) }), "implementation_commit": .string(implementation), "implementation_tree": .string(tree)])
        let dirty: V = .object(["allowed_tracked_dirty": .array([.object(["path": .string("Control/hypervisor-local-v1/h2-live-build-plan.v1.json"), "sha256": .string("b0a73ca324d0c7dc4e9619b549c2c4c85cbcae1e32a021f55d282a7c150470ba")]), .object(["path": .string("Control/hypervisor-local-v1/h2-live-build-wire.schema.v1.json"), "sha256": .string("307e614ca6940bb01a57c625ed8e2a22378269d0fc2c923b86154c2862ac79b1")])]), "ambient_roots_count": .integer(53), "ambient_roots_sha256": .string("1aa7745b2bfd2f8840bb6f636c43ef9139ebfce0e10d5cc40c8beb7d305f7db8"), "head_matches_implementation": .bool(true), "ignored_paths_count": .integer(7), "ignored_paths_sha256": .string("d06e3ba7884ccc4ed3d34ab0fa741bbf3f3c0fe1a2c3a43a0f07778054e9a0ec"), "index_empty": .bool(true), "unexpected_namespace_entries": .integer(0), "workspace_structural_directories_count": .integer(4), "workspace_structural_directories_sha256": .string("43240b37a01222d07606e683dc9d0970e5322d4b79f5b87ba5156d205ad337f0")])
        let listing = rows.map { "\($0[1]) blob \($0[2])\t\($0[0])\0" }.joined()
        let index = rows.map { "\($0[1]) \($0[2]) 0\t\($0[0])\0" }.joined()
        let freezeDelta = ":000000 100644 \(String(repeating: "0", count: 40)) 75884c075c2b27a7882d35c4dd33375dd09c33b3 A\0Control/hypervisor-local-v1/h3-signed-application-qualification-runner-freeze-2026-09-04.v1.json\0"
        let outputs = [implementation + "\n", tree + "\n", "fc44ef370d3ff8888e4dfecbc3901fc0ec1a5600\n", freezeDelta, rawDelta, delta.map { $0 + "\0" }.joined(), listing, "", index]
        var probes: [V] = []
        for (index, template) in contract["source_argv"]!.arrayValue!.enumerated() {
            let argv = array(template.arrayValue!.map { $0.stringValue!.replacingOccurrences(of: "<freeze_commit>", with: freeze).replacingOccurrences(of: "<implementation_commit>", with: implementation) })
            probes.append(.object(["argv": argv, "cwd": .string("/Users/ergentics/Developer/ErgenticsProvenance"), "environment": array(environment), "exit_status": .integer(0), "stdout": stream(outputs[index]), "stderr": stream("")]))
        }
        var batch = try H3QualificationCanonicalJSON.decode(batchBytes, maximumBytes: 262_144).objectValue!
        batch["argv"] = probes[7]["argv"]; batch["environment"] = array(environment)
        batch["entry_count"] = .integer(Int64(rows.count)); batch["clean_match_count"] = .integer(Int64(rows.count - 2))
        batch["listing_sha256"] = .string(hash(listing))
        let request = implementation + "\n" + freeze + "\n" + rows.map { $0[2] + "\n" }.joined() + "b5fd9b2e1c72f54924269b6ff9453f87abeae5f2\n"
        batch["request_byte_count"] = .integer(Int64(request.utf8.count)); batch["request_sha256"] = .string(hash(request))
        batch["implementation_commit_byte_count"] = .integer(Int64(commitPayload.count))
        batch["implementation_commit_sha256"] = .string(H3QualificationProtocol.hash(commitPayload))
        for prefix in ["implementation", "freeze"] {
            batch[prefix + "_commit_recomputed_oid"] = source[prefix + "_commit"]
            batch[prefix + "_commit_tree"] = source[prefix + "_tree"]
            batch[prefix + "_reconstructed_tree"] = source[prefix + "_tree"]
        }
        batch["implementation_commit_parent"] = .string(freeze)
        let predecessor = frozen.filter { $0[0] != "Control/hypervisor-local-v1/h3-signed-application-qualification-runner-freeze-2026-09-04.v1.json" }
        let snapshots = try [("PREDECESSOR", predecessor), ("FREEZE", frozen), ("IMPLEMENTATION", rows)].map { name, rows -> V in
            changed(try gitTreeDetails(rows).1, "snapshot", .string(name))
        }
        batch["tree_reconstruction_join_sha256"] = .string(H3QualificationProtocol.hash(try encoded(.array(snapshots))))
        probes[7] = .object(batch)
        return .object(["dirty_guard": dirty, "probes": .array(probes), "schema": .string("com.ergentics.provenance.h3-qualification-source-state.v1"), "source": source, "version": .integer(1)])
    }
    private func toolchain() throws -> V {
        var value = try H3QualificationCanonicalJSON.decode(toolchainBytes, maximumBytes: 262_144).objectValue!
        let contract = try contract(), argv = contract["toolchain_argv"]!.arrayValue!
        let outputs = ["Xcode 26.6\nBuild version 17F113\n", "26.5\n", "swift-driver version: 1.148.6 Apple Swift version 6.3.3 (swiftlang-6.3.3.1.3 clang-2100.1.1.101)\nTarget: arm64-apple-macosx26.0\n", "ruby 2.6.10p210 (2022-04-12 revision 67958) [universal.arm64e-darwin25]\n", value["seal_runtime_sha256"]!.stringValue! + "  /usr/bin/ruby\n", "", value["seal_launcher_sha256"]!.stringValue! + "  /usr/bin/env\n", "", "25G83\n", "arm64\n"]
        var probes: [V] = []
        for index in argv.indices {
            let prefix = index == 5 ? "seal_runtime" : "seal_launcher"
            let stderr = index == 5 || index == 7 ? "Executable=\(value[prefix + "_path"]!.stringValue!)\nIdentifier=\(value[prefix + "_identifier"]!.stringValue!)\nCDHash=\(value[prefix + "_cdhash"]!.stringValue!)\n" : ""
            probes.append(.object(["argv": argv[index], "cwd": .string("/private/var/empty"), "environment": array(environment), "exit_status": .integer(0), "stdout": stream(outputs[index]), "stderr": stream(stderr)]))
        }
        value["probes"] = .array(probes); return .object(value)
    }
    private func process(seconds: UInt64, pipes: Int64 = 2, supervised: Bool = false) -> V {
        var fields: [String: V] = ["child_pid": .integer(123), "exit_status": .integer(0), "kill_attempted": .bool(false), "kill_errno": .integer(0), "kill_return": .integer(Int64(Int32.min)), "normal_exit": .bool(true), "observed_pipe_eof_count": .integer(pipes), "operation_deadline_tick": .string(String(1 + seconds * 1_000_000_000)), "output_overflow": .bool(false), "process_group_gone": .bool(true), "reap_tick": .string("200"), "reaped": .bool(true), "required_pipe_eof_count": .integer(pipes), "signal": .null, "spawn_tick": .string("1"), "terminal_tick": .string("201"), "timebase_denominator": .integer(1), "timebase_numerator": .integer(1), "timed_out": .bool(false), "wait_status": .integer(0)]
        if supervised { fields["process_group"] = .integer(123); fields["stdout"] = stream(""); fields["stderr"] = stream("") }
        return .object(fields)
    }
    private func ref(_ name: String, _ bytes: Data) -> V {
        .object(["path": .string(name), "byte_count": .integer(Int64(bytes.count)), "sha256": .string(H3QualificationProtocol.hash(bytes))])
    }
    private func buildArtifacts() throws -> [String: Data] {
        let contract = try contract(), source = try sourceState(), toolchain = try toolchain()
        var artifacts = ["source-state.json": try encoded(source)], records: [V] = [], pairs: [V] = [], references: [String: V] = [:]
        references["source_state"] = ref("source-state.json", artifacts["source-state.json"]!)
        for configuration in H3QualificationConfiguration.allCases {
            let prefix = configuration == .debug ? "debug" : "release", audit = try productAudit(configuration)
            artifacts[prefix + "-product-audit.json"] = try encoded(audit); artifacts[prefix + "-build.log"] = Data("SYNTHETIC BUILD\n".utf8)
            var settingsRecords: [V] = []
            for application in [true, false] {
                var fields = contract["settings"]!["required_common_settings"]!.objectValue!
                fields.merge(contract["settings"]!["configuration_settings"]![configuration.rawValue]!.objectValue!) { _, new in new }
                fields.merge(contract["settings"]![application ? "application_settings" : "controller_settings"]!.objectValue!) { _, new in new }
                fields = fields.filter { $0.value != .string("ABSENT_KEY") }
                fields["BUILT_PRODUCTS_DIR"] = fields["TARGET_BUILD_DIR"]; fields["CONFIGURATION_BUILD_DIR"] = fields["TARGET_BUILD_DIR"]
                settingsRecords.append(.object(["action": .string("build"), "buildSettings": .object(fields), "target": .string(application ? "ErgenticsProvenance" : "ErgenticsProvenanceH3QualificationController")]))
            }
            artifacts[prefix + "-build-settings.json"] = try encoded(.array(settingsRecords))
            for suffix in ["build_log", "build_settings", "product_audit"] {
                let name = suffix == "build_log" ? prefix + "-build.log" : prefix + "-" + suffix.replacingOccurrences(of: "_", with: "-") + ".json"
                references[prefix + "_" + suffix] = ref(name, artifacts[name]!)
            }
            let argv = contract["build_" + prefix]!
            records.append(.object(["argv": argv, "build_log": references[prefix + "_build_log"]!, "build_process": process(seconds: 900, pipes: 1), "configuration": .string(configuration.rawValue), "cwd": .string("/Users/ergentics/Developer/ErgenticsProvenance"), "derived_data_path": .string("/private/tmp/ergentics-h3q-\(prefix)-v1"), "environment": array(environment), "product_audit": references[prefix + "_product_audit"]!, "settings": references[prefix + "_build_settings"]!, "settings_argv": .array(argv.arrayValue! + [.string("-showBuildSettings"), .string("-json")]), "settings_process": process(seconds: 120), "settings_stderr": stream("")]))
            pairs.append(.object(["application": audit["application"]!, "audit": references[prefix + "_product_audit"]!, "configuration": .string(configuration.rawValue), "controller": audit["controller"]!]))
        }
        let manifest: V = .object(["artifacts": .object(references), "builds": .array(records), "dirty_guard": source["dirty_guard"]!, "products": .array(pairs), "schema": .string("com.ergentics.provenance.h3-qualification-build-source-manifest.v1"), "source": source["source"]!, "source_state": references["source_state"]!, "toolchain": toolchain, "version": .integer(1)])
        artifacts["build-source-manifest.json"] = try encoded(manifest)
        return artifacts
    }
    private func guest(_ configuration: H3QualificationConfiguration, nonpass: Bool = false, nonce override: String? = nil) throws -> V {
        var value = try admission(configuration).objectValue!
        let nonce = override ?? String(repeating: configuration == .debug ? "3" : "4", count: 64)
        let capture = try H3QualificationRunnerTests.externalGuestCapture(nonpass: nonpass)
        let replay = try H3QualificationReplay.replay(capture: capture)
        value["native"] = capture.wire; value["verifier"] = replay.wire
        value["run"] = .object(["mode": .string("GUEST"), "configuration": .string(configuration.rawValue), "nonce": .string(nonce), "run_id": .string(try H3QualificationProtocol.runID(mode: .guest, configuration: configuration, nonce: nonce))])
        value["gate"] = .object(["accepted": .bool(true), "mode_byte": .string("02"), "validated_tick": .string("103"), "frame_sha256": .string(H3QualificationProtocol.hash(try H3QualificationProtocol.gateFrame(mode: .guest, nonce: nonce)))])
        var effects = value["effects"]!.objectValue!
        effects["reservation_entries"] = .integer(1); effects["reservation_release_entries"] = .integer(1); effects["reservation_release_status"] = .integer(0)
        effects["lifecycle_disposition"] = .string("RECOVERY_VOLATILE")
        effects["hv_vm_created_count"] = .integer(["source", "target"].reduce(0) { $0 + (capture.wire[$1]?["vm_create_status"] == .integer(0) ? 1 : 0) })
        effects["guest_entered_count"] = .integer(["source", "target"].reduce(0) { $0 + capture.wire[$1]!["run_entries"]!.intValue! })
        value["effects"] = .object(effects)
        return .object(value)
    }
    private func supervisor(artifacts: [String: Data], configuration: H3QualificationConfiguration, guest: Bool, verifying: Bool, result: String) throws -> V {
        let prefix = configuration == .debug ? "debug" : "release", campaign = guest ? "GUEST" : "ADMISSION"
        let root = "/private/tmp/ergentics-h3q-\(guest ? "guest" : "admission")-campaign-v1" + (verifying ? "" : "/" + prefix)
        let code = try code(configuration, app: false), controllerPath = code["executable_path"]!.stringValue!
        let path: V = .object(["device": .string("1"), "inode": .string("50"), "link_count": .string("1"), "mode": .integer(493), "owner": .integer(501), "path": .string(controllerPath), "sha256": code["executable_sha256"]!, "size": .string("1024"), "type": .string("REGULAR")])
        let directory: V = .object(["device": .string("1"), "inode": .string("60"), "link_count": .string("2"), "mode": .integer(448), "owner": .integer(501), "path": .string(root), "type": .string("DIRECTORY")])
        let before = artifacts.keys.filter { !$0.contains("/") && !$0.hasSuffix("campaign-checkpoint.json") }.sorted() + ["debug", "release"]
        let checkpointName = guest ? "guest-campaign-checkpoint.json" : "admission-campaign-checkpoint.json"
        let source = try H3QualificationCanonicalJSON.decode(artifacts["source-state.json"]!, maximumBytes: 262_144)
        let sealPin = source["source"]!["delta_path_pins"]!.arrayValue!.first { $0["path"] == .string("Tools/H3QualificationSeal/h3_qualification_seal.rb") }!["sha256"]!
        var process = process(seconds: verifying ? 120 : 60, supervised: true).objectValue!
        let exit: Int64 = result == "RETAINED_NONPASS" || result == "FAIL_H3_GUEST_CAMPAIGN" ? 65 : 0
        process["exit_status"] = .integer(exit); process["wait_status"] = .integer(exit << 8)
        return .object(["argv": array([controllerPath, verifying ? (guest ? "--verify-guest-campaign" : "--verify-admission-campaign") : (guest ? "--guest" : "--admission-only"), root]), "build_source_manifest": ref("build-source-manifest.json", artifacts["build-source-manifest.json"]!), "campaign": .string(campaign), "campaign_checkpoint": verifying ? ref(checkpointName, artifacts[checkpointName]!) : .null, "configuration": verifying ? .null : .string(configuration.rawValue), "controller_executable_after": .object(["held": path, "named": path]), "controller_executable_before": .object(["held": path, "named": path]), "controller_product_audit": ref(prefix + "-product-audit.json", artifacts[prefix + "-product-audit.json"]!), "cwd": .string("/private/var/empty"), "descriptor_contract": .string("STDIN_DEV_NULL_STDOUT_PIPE_STDERR_PIPE_CLOSE_OTHERS_FRESH_PGROUP"), "environment": .array([]), "evidence_root_after_child": .object(["held": directory, "named": directory]), "evidence_root_before": .object(["held": directory, "named": directory]), "inventory_after_child": array(verifying ? (before + [checkpointName]).sorted() : ["application-stderr.bin", "inner-application-report.frame", "manifest.json", "outer-observer-receipt.json"]), "inventory_before": array(verifying ? before.sorted() : []), "mode": .string(verifying ? "VERIFY_" + campaign : "RUN_" + campaign + "_" + configuration.rawValue), "outer_receipt": verifying ? .null : ref("outer-observer-receipt.json", artifacts[prefix + "/outer-observer-receipt.json"]!), "process": .object(process), "result": .string(result), "run_manifest": verifying ? .null : ref("manifest.json", artifacts[prefix + "/manifest.json"]!), "schema": .string("com.ergentics.provenance.h3-qualification-seal-supervisor-receipt.v1"), "seal_source_sha256": sealPin, "source_state": ref("source-state.json", artifacts["source-state.json"]!), "version": .integer(1)])
    }
    private func closedCampaign(guestMode: Bool = false, nonpass: Bool = false, debugNonce: String? = nil) throws -> [String: Data] {
        var artifacts = try buildArtifacts()
        if guestMode {
            var admissionArtifacts = try closedCampaign()
            let checkpointBytes = try H3QualificationCampaignVerifier.verify(bundle: .init(mode: .admissionOnly, artifacts: admissionArtifacts), verifierClaim: controller(.release))
            let checkpoint = try H3QualificationCanonicalJSON.decode(checkpointBytes, maximumBytes: 262_144)
            admissionArtifacts["admission-campaign-checkpoint.json"] = checkpointBytes
            let verifier = try supervisor(artifacts: admissionArtifacts, configuration: .release, guest: false, verifying: true, result: "PASS_ADMISSION_CAMPAIGN"), verifierBytes = try encoded(verifier)
            let seal: V = .object(["build_source_manifest": ref("build-source-manifest.json", artifacts["build-source-manifest.json"]!), "campaign": .string("ADMISSION"), "campaign_checkpoint": ref("admission-campaign-checkpoint.json", checkpointBytes), "result": .string("PASS_ADMISSION_CAMPAIGN"), "run_supervisors": .array(checkpoint["runs"]!.arrayValue!.map { $0["supervisor"]! }), "schema": .string("com.ergentics.provenance.h3-qualification-campaign-seal.v1"), "seal_source_sha256": verifier["seal_source_sha256"]!, "source_state": ref("source-state.json", artifacts["source-state.json"]!), "verifier_supervisor": ref("campaign-verifier-supervisor.json", verifierBytes), "version": .integer(1)])
            artifacts["prior-admission-checkpoint.json"] = checkpointBytes
            artifacts["prior-admission-verifier-supervisor.json"] = verifierBytes
            artifacts["prior-admission-campaign-seal.json"] = try encoded(seal)
        }
        for configuration in H3QualificationConfiguration.allCases {
            let prefix = configuration == .debug ? "debug" : "release"
            let inner = try guestMode ? guest(configuration, nonpass: nonpass && configuration == .debug, nonce: configuration == .debug ? debugNonce : nil) : admission(configuration)
            var outer = try receipt(inner)
            var evidence = outer["evidence"]!.objectValue!
            evidence["build_source_manifest_sha256"] = .string(H3QualificationProtocol.hash(artifacts["build-source-manifest.json"]!))
            evidence["product_audit_sha256"] = .string(H3QualificationProtocol.hash(artifacts[prefix + "-product-audit.json"]!))
            outer = changed(outer, "evidence", .object(evidence))
            let failures = try H3QualificationPredicateEvaluator.evaluate(receipt: outer, inner: inner)
            outer = changed(outer, "classification", .object(["failed_predicates": array(failures), "result": .string(failures.isEmpty ? "RUN_CANDIDATE_PASS" : "RETAINED_NONPASS")]))
            artifacts[prefix + "/inner-application-report.frame"] = try H3QualificationProtocol.frame(payload: inner)
            artifacts[prefix + "/application-stderr.bin"] = Data()
            artifacts[prefix + "/outer-observer-receipt.json"] = try encoded(outer)
            let files = ["inner-application-report.frame", "application-stderr.bin", "outer-observer-receipt.json"].map { name -> V in
                changed(ref(name, artifacts[prefix + "/" + name]!), "mode", .integer(384))
            }
            let manifest: V = .object(["configuration": .string(configuration.rawValue), "files": .array(files), "mode": .string(guestMode ? "GUEST" : "ADMISSION_ONLY"), "run_id": inner["run"]!["run_id"]!, "schema": .string("com.ergentics.provenance.h3-qualification-manifest.v1"), "version": .integer(1)])
            artifacts[prefix + "/manifest.json"] = try encoded(manifest)
            artifacts[prefix + "/seal-supervisor-receipt.json"] = try encoded(supervisor(artifacts: artifacts, configuration: configuration, guest: guestMode, verifying: false, result: failures.isEmpty ? "RUN_CANDIDATE_PASS" : "RETAINED_NONPASS"))
        }
        return artifacts
    }
    func testExportBoundedSyntheticCampaignFixturesForIndependentRubyReplay() throws {
        // SYNTHETIC ONLY: fixed, freshly owned values from the existing pure
        // fixtures. No filesystem loader, environment read, signing, process,
        // native entry or guest operation is involved. XCTest owns stdout.
        func artifactValues(_ artifacts: [String: Data]) -> V {
            .object(artifacts.mapValues { .string($0.base64EncodedString()) })
        }
        let verifier = try controller(.release)
        let campaigns: [(String, Bool, Bool)] = [
            ("ADMISSION", false, false), ("GUEST_PASS", true, false), ("GUEST_NONPASS", true, true)
        ]
        var campaignValues: [String: V] = [:]
        for (name, guestMode, nonpass) in campaigns {
            let artifacts = try closedCampaign(guestMode: guestMode, nonpass: nonpass)
            let checkpoint = try H3QualificationCampaignVerifier.verify(
                bundle: .init(mode: guestMode ? .guest : .admissionOnly, artifacts: artifacts), verifierClaim: verifier)
            campaignValues[name] = .object([
                "artifacts": artifactValues(artifacts), "verifier": verifier,
                "expected_checkpoint_base64": .string(checkpoint.base64EncodedString())
            ])
        }
        var admissionValues: [String: V] = [:]
        let signingCases: [(String, Int32?)] = [("PASS", nil), ("REJECTED", 0), ("API_ERROR", -67050)]
        for configuration in H3QualificationConfiguration.allCases {
            for (name, error) in signingCases {
                let inner = try admission(configuration, signingError: error)
                admissionValues[configuration.rawValue + "_" + name] = .object([
                    "configuration": .string(configuration.rawValue),
                    "inner_base64": .string(try H3QualificationProtocol.frame(payload: inner).base64EncodedString()),
                    "outer_base64": .string(try encoded(receipt(inner)).base64EncodedString()),
                    "stderr_base64": .string("")
                ])
            }
        }
        let envelope: V = .object([
            "admission_runs": .object(admissionValues), "build_artifacts": artifactValues(try buildArtifacts()),
            "campaigns": .object(campaignValues), "synthetic": .bool(true), "version": .integer(1)
        ])
        let payload = try H3QualificationCanonicalJSON.encode(envelope, maximumBytes: 3_145_600)
        let line = "H3_SYNTHETIC_FIXTURE_BASE64=" + payload.base64EncodedString()
        XCTAssertLessThanOrEqual(line.utf8.count + 1, 4_194_304, "single bounded synthetic stdout record")
        guard line.utf8.count + 1 <= 4_194_304 else { return }
        print(line)
    }
    func testCompleteAdmissionAndGuestCampaignsProduceCanonicalCheckpoints() throws {
        for guest in [false, true] {
            let artifacts = try closedCampaign(guestMode: guest)
            let bytes = try H3QualificationCampaignVerifier.verify(bundle: .init(mode: guest ? .guest : .admissionOnly, artifacts: artifacts), verifierClaim: controller(.release))
            let checkpoint = try H3QualificationCanonicalJSON.decode(bytes, maximumBytes: 262_144)
            XCTAssertEqual(checkpoint["result"], .string(guest ? "PASS_H3_GUEST_CAMPAIGN" : "PASS_ADMISSION_CAMPAIGN"))
            XCTAssertEqual(checkpoint["aggregates"]?["guest_entries"], .integer(guest ? 4 : 0))
            XCTAssertNoThrow(try H3QualificationWire.validate(checkpoint, schema: "campaign_checkpoint_v1"))
        }
    }
    func testGuestTerminalNonpassRetainsActualCountsAndCrossPriorNonceCannotReplay() throws {
        let artifacts = try closedCampaign(guestMode: true, nonpass: true)
        let bytes = try H3QualificationCampaignVerifier.verify(bundle: .init(mode: .guest, artifacts: artifacts), verifierClaim: controller(.release))
        let checkpoint = try H3QualificationCanonicalJSON.decode(bytes, maximumBytes: 262_144)
        XCTAssertEqual(checkpoint["result"], .string("FAIL_H3_GUEST_CAMPAIGN"))
        XCTAssertEqual(checkpoint["aggregates"]?["guest_entries"], .integer(3))
        XCTAssertEqual(checkpoint["aggregates"]?["hv_vm_creates"], .integer(3))
        let crossNonce = try closedCampaign(guestMode: true, debugNonce: String(repeating: "2", count: 64))
        XCTAssertThrowsError(try H3QualificationCampaignVerifier.verify(bundle: .init(mode: .guest, artifacts: crossNonce), verifierClaim: controller(.release)))
    }
    func testCampaignRejectsExtraLeafAndRehashedWrongSupervisorPID() throws {
        var artifacts = try closedCampaign()
        artifacts["extra.json"] = Data("{}".utf8)
        XCTAssertThrowsError(try H3QualificationCampaignVerifier.verify(bundle: .init(mode: .admissionOnly, artifacts: artifacts), verifierClaim: controller(.release)))
        artifacts.removeValue(forKey: "extra.json")
        let name = "debug/seal-supervisor-receipt.json", supervisor = try H3QualificationCanonicalJSON.decode(artifacts[name]!, maximumBytes: 131_072)
        let process = changed(changed(supervisor["process"]!, "child_pid", .integer(999)), "process_group", .integer(999))
        artifacts[name] = try encoded(changed(supervisor, "process", process))
        XCTAssertThrowsError(try H3QualificationCampaignVerifier.verify(bundle: .init(mode: .admissionOnly, artifacts: artifacts), verifierClaim: controller(.release)))
    }
    func testFullSourceProductPrelaunchChainAdmitsAndRejectsWrongSourceParent() throws {
        let source = try sourceState()
        XCTAssertNoThrow(try H3QualificationWire.validate(source, schema: "source_state_v1"))
        let artifacts = try buildArtifacts()
        for configuration in H3QualificationConfiguration.allCases {
            let audit = (configuration == .debug ? "debug" : "release") + "-product-audit.json"
            let selected = artifacts.filter { ["build-source-manifest.json", "source-state.json", audit].contains($0.key) }
            XCTAssertEqual(try H3QualificationPrelaunchVerifier.verify(mode: .admissionOnly, configuration: configuration, artifacts: selected, controllerClaim: controller(configuration)), try code(configuration))
            var changedArtifacts = selected
            changedArtifacts[audit] = try encoded(changed(try productAudit(configuration), "application", changed(try code(configuration), "executable_sha256", .string(zero))))
            XCTAssertThrowsError(try H3QualificationPrelaunchVerifier.verify(mode: .admissionOnly, configuration: configuration, artifacts: changedArtifacts, controllerClaim: controller(configuration)))
        }
        var probes = source["probes"]!.arrayValue!
        probes[7] = changed(probes[7], "implementation_commit_parent", .string(String(repeating: "2", count: 40)))
        XCTAssertThrowsError(try H3QualificationWire.validate(changed(source, "probes", .array(probes)), schema: "source_state_v1"))
        probes = source["probes"]!.arrayValue!
        probes[7] = changed(probes[7], "tree_reconstruction_join_sha256", .string(zero))
        XCTAssertThrowsError(try H3QualificationWire.validate(changed(source, "probes", .array(probes)), schema: "source_state_v1"))
    }
    func testSourceRejectsRehashedRawIndexAndReverseDeltaMismatch() throws {
        let source = try sourceState()
        for index in [3, 4, 5, 6, 8] {
            var probes = source["probes"]!.arrayValue!
            probes[index] = changed(probes[index], "stdout", stream("malformed\0"))
            XCTAssertThrowsError(try H3QualificationWire.validate(changed(source, "probes", .array(probes)), schema: "source_state_v1"))
        }
    }
    func testRawSettingsWhitespaceOnlyModePreservesQuotedBytesAndRejectsDuplicates() throws {
        let raw = Data(" \n[ { \"action\" : \"build\", \"buildSettings\" : { \"A\" : \"a b\\t c\" }, \"target\" : \"X\" } ] \r\n".utf8)
        let parsed = try H3QualificationCanonicalJSON.decodeBuildSettings(raw)
        XCTAssertEqual(parsed.arrayValue?[0]["buildSettings"]?["A"], .string("a b\t c"))
        XCTAssertThrowsError(try H3QualificationCanonicalJSON.decode(raw))
        for invalid in ["{\"a\":\"x\", \"a\":\"y\"}", "[null]", "[false]", "[1]", "[\"x\",]", "[\"x\"] [\"y\"]"] { XCTAssertThrowsError(try H3QualificationCanonicalJSON.decodeBuildSettings(Data(invalid.utf8))) }
    }
    func testProductRawProbesAdmitBothConfigurationsAndRejectRehashedMutations() throws {
        for config in H3QualificationConfiguration.allCases {
            let audit = try productAudit(config)
            XCTAssertNoThrow(try H3QualificationWire.validate(audit, schema: "product_audit_v1"))
            for index in [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11] {
                var probes = audit["probes"]!.arrayValue!
                probes[index] = changed(probes[index], "stdout", stream("tampered invalid token\n"))
                XCTAssertThrowsError(try H3QualificationWire.validate(changed(audit, "probes", .array(probes)), schema: "product_audit_v1"), "probe \(index)")
            }
        }
    }
    private func cnRequirement(app: Bool, authority: String = "Apple Development: SYNTHETIC TEST") -> String {
        let identifier = app ? "com.ergentics.provenance" : "com.ergentics.provenance.h3-qualification-controller"
        return "identifier \"\(identifier)\" and anchor apple generic and certificate leaf[subject.CN] = \"\(authority)\" and certificate 1[field.1.2.840.113635.100.6.2.1] /* exists */"
    }
    private func auditWithRequirement(_ configuration: H3QualificationConfiguration = .debug, app: Bool,
                                      text: String, authority: String = "Apple Development: SYNTHETIC TEST") throws -> V {
        let audit = try productAudit(configuration), role = app ? "application" : "controller", index = app ? 3 : 9
        var probes = audit["probes"]!.arrayValue!
        let stdout = String(data: Data(base64Encoded: probes[index]["stdout"]!["base64"]!.stringValue!)!, encoding: .utf8)!
        let stderr = String(data: Data(base64Encoded: probes[index]["stderr"]!["base64"]!.stringValue!)!, encoding: .utf8)!
        probes[index] = changed(probes[index], "stdout", stream("designated => " + text + "\n" + stdout.components(separatedBy: "\n").dropFirst().joined(separator: "\n")))
        probes[index] = changed(probes[index], "stderr", stream(stderr.replacingOccurrences(of: "Authority=Apple Development: SYNTHETIC TEST\n", with: "Authority=" + authority + "\n")))
        return changed(changed(audit, role, changed(audit[role]!, "designated_requirement", .string(text))), "probes", .array(probes))
    }
    func testProductCNRequirementsAdmitBothRolesAndConfigurationsWithoutRewritingEvidence() throws {
        for configuration in H3QualificationConfiguration.allCases {
            for app in [true, false] {
                for authority in ["Apple Development: SYNTHETIC TEST", "Apple Development: SYNTHETIC and Å"] {
                    let text = cnRequirement(app: app, authority: authority)
                    let audit = try auditWithRequirement(configuration, app: app, text: text, authority: authority)
                    XCTAssertNoThrow(try H3QualificationWire.validate(audit, schema: "product_audit_v1"))
                    let role = app ? "application" : "controller", index = app ? 3 : 9
                    XCTAssertEqual(audit[role]!["designated_requirement"], .string(text))
                    let raw = Data(base64Encoded: audit["probes"]!.arrayValue![index]["stdout"]!["base64"]!.stringValue!)!
                    XCTAssertTrue(raw.starts(with: Data(("designated => " + text + "\n").utf8)))
                    let substituted = changed(audit, role, changed(audit[role]!, "designated_requirement", try code(configuration, app: app)["designated_requirement"]!))
                    XCTAssertThrowsError(try H3QualificationWire.validate(substituted, schema: "product_audit_v1"), "policy text must not replace observed CN text")
                }
            }
        }
    }
    func testProductCNAndCodeIdentityRequireExactUnicodeBytes() throws {
        let composed = "Apple Development: SYNTHETIC Å", decomposed = "Apple Development: SYNTHETIC A\u{030a}"
        XCTAssertEqual(composed, decomposed, "demonstrate Swift canonical-equivalence edge")
        XCTAssertNotEqual(Data(composed.utf8), Data(decomposed.utf8))
        XCTAssertFalse(try H3QualificationProtocol.sameCodeIdentity(nil, nil))
        for app in [true, false] {
            let first = cnRequirement(app: app, authority: composed), second = cnRequirement(app: app, authority: decomposed)
            let a = try auditWithRequirement(app: app, text: first, authority: composed)
            let b = try auditWithRequirement(app: app, text: second, authority: decomposed)
            let role = app ? "application" : "controller"
            XCTAssertNoThrow(try H3QualificationWire.validate(a, schema: "product_audit_v1"))
            XCTAssertNoThrow(try H3QualificationWire.validate(b, schema: "product_audit_v1"))
            XCTAssertThrowsError(try H3QualificationWire.validate(auditWithRequirement(app: app, text: second, authority: composed), schema: "product_audit_v1"))
            XCTAssertThrowsError(try H3QualificationWire.validate(auditWithRequirement(app: app, text: first, authority: decomposed), schema: "product_audit_v1"))
            XCTAssertThrowsError(try H3QualificationWire.validate(changed(a, role, b[role]!), schema: "product_audit_v1"), "raw probe and claimed DR cannot differ only in normalization")
            XCTAssertTrue(try H3QualificationProtocol.sameCodeIdentity(a[role], a[role]))
            XCTAssertFalse(try H3QualificationProtocol.sameCodeIdentity(a[role], b[role]))
            XCTAssertFalse(try H3QualificationProtocol.sameCodeIdentity(a[role], nil))
        }
        let outer = try receipt(admission()), pre = changed(try code(), "designated_requirement", .string(cnRequirement(app: true, authority: composed)))
        let normalized = changed(pre, "designated_requirement", .string(cnRequirement(app: true, authority: decomposed)))
        var application = outer["application"]!
        for field in ["pre_static", "dynamic", "post_static"] { application = changed(application, field, pre) }
        XCTAssertNoThrow(try H3QualificationWire.validate(changed(outer, "application", application), schema: "outer_receipt_v1"))
        for field in ["dynamic", "post_static"] {
            XCTAssertThrowsError(try H3QualificationWire.validate(changed(outer, "application", changed(application, field, normalized)), schema: "outer_receipt_v1"), "static/dynamic identity must not normalize \(field)")
        }
    }
    func testProductCNRequirementBoundUsesUTF8BytesAt256And257() throws {
        for app in [true, false] {
            let prefix = "Apple Development: ", remaining = 256 - cnRequirement(app: app, authority: prefix).utf8.count
            let authority = prefix + "é" + String(repeating: "x", count: remaining - 2)
            let text = cnRequirement(app: app, authority: authority)
            XCTAssertEqual(text.utf8.count, 256); XCTAssertLessThan(text.count, 256)
            XCTAssertNoThrow(try H3QualificationWire.validate(auditWithRequirement(app: app, text: text, authority: authority), schema: "product_audit_v1"))
            let oversized = cnRequirement(app: app, authority: authority + "x")
            XCTAssertEqual(oversized.utf8.count, 257)
            XCTAssertThrowsError(try H3QualificationWire.validate(auditWithRequirement(app: app, text: oversized, authority: authority + "x"), schema: "product_audit_v1"))
        }
    }
    func testProductCNRequirementRejectsWrongIdentityAndWeakenedGrammar() throws {
        for app in [true, false] {
            let text = cnRequirement(app: app)
            let intermediate = " and certificate 1[field.1.2.840.113635.100.6.2.1] /* exists */"
            let mutations = [text.replacingOccurrences(of: "SYNTHETIC TEST", with: "OTHER SIGNER"),
                text.replacingOccurrences(of: "anchor apple generic", with: "anchor trusted"),
                text.replacingOccurrences(of: "com.ergentics.provenance", with: "com.untrusted.provenance"),
                text.replacingOccurrences(of: intermediate, with: ""),
                text.replacingOccurrences(of: " and anchor apple generic", with: " or anchor apple generic"),
                text + " and anchor apple generic", text + " and ", text + " or true",
                text + " and certificate leaf[subject.OU] = \"ZCQ435U8JP\"",
                text.replacingOccurrences(of: "subject.CN", with: "subject.O"),
                text.replacingOccurrences(of: "100.6.2.1", with: "100.6.2.9")]
            for changedText in mutations {
                XCTAssertThrowsError(try H3QualificationWire.validate(auditWithRequirement(app: app, text: changedText), schema: "product_audit_v1"), changedText)
            }
        }
        for authority in ["Apple Development: ", "Apple Development:   ", "Apple Development: SYNTHETIC\"", "Apple Development: SYNTHETIC\\"] {
            XCTAssertThrowsError(try H3QualificationWire.validate(auditWithRequirement(app: true, text: cnRequirement(app: true, authority: authority), authority: authority), schema: "product_audit_v1"))
        }
    }
    func testProductCNRequirementRejectsControlsAndUnstructuredText() throws {
        let text = cnRequirement(app: true)
        for invalid in ["", "true", "anchor apple generic", text + "\0", text + "\u{7f}", text + "\t", text + "\r", text + "\n", "\0H3_CAPTURED_LEAF_CN\0"] {
            XCTAssertThrowsError(try H3QualificationWire.validate(auditWithRequirement(app: true, text: invalid), schema: "product_audit_v1"))
        }
    }
    func testProductCNFormStillRequiresPinnedMetadataAndSuccessfulVerification() throws {
        for app in [true, false] {
            let audit = try auditWithRequirement(app: app, text: cnRequirement(app: app)), index = app ? 3 : 9
            let probes = audit["probes"]!.arrayValue!
            let metadata = String(data: Data(base64Encoded: probes[index]["stderr"]!["base64"]!.stringValue!)!, encoding: .utf8)!
            for (old, new) in [("TeamIdentifier=ZCQ435U8JP", "TeamIdentifier=WRONGTEAM1"),
                ("Identifier=com.ergentics.provenance", "Identifier=com.untrusted.provenance"),
                ("Authority=Apple Root CA", "Authority=Untrusted Root"),
                ("Authority=Apple Worldwide Developer Relations Certification Authority", "Authority=Wrong Intermediate"),
                ("Authority=Apple Development: SYNTHETIC TEST", "Authority=Apple Development: OTHER SIGNER"),
                ("flags=0x10000(runtime)", "flags=0x0(none)")] {
                var altered = probes
                altered[index] = changed(altered[index], "stderr", stream(metadata.replacingOccurrences(of: old, with: new)))
                XCTAssertThrowsError(try H3QualificationWire.validate(changed(audit, "probes", .array(altered)), schema: "product_audit_v1"))
            }
            var altered = probes
            altered[index] = changed(altered[index], "stderr", stream(metadata + "TeamIdentifier=ZCQ435U8JP\n"))
            XCTAssertThrowsError(try H3QualificationWire.validate(changed(audit, "probes", .array(altered)), schema: "product_audit_v1"))
            altered = probes; altered[index - 1] = changed(altered[index - 1], "exit_status", .integer(1))
            XCTAssertThrowsError(try H3QualificationWire.validate(changed(audit, "probes", .array(altered)), schema: "product_audit_v1"))
            let role = app ? "application" : "controller"
            XCTAssertThrowsError(try H3QualificationWire.validate(changed(audit, role, changed(audit[role]!, "team_identifier", .string("WRONGTEAM1"))), schema: "product_audit_v1"))
        }
    }
    func testProductRejectsControllerHypervisorSymbolsAndEntitlements() throws {
        let audit = try productAudit()
        var probes = audit["probes"]!.arrayValue!
        probes[11] = changed(probes[11], "stdout", stream("_hv_vm_create\n"))
        XCTAssertThrowsError(try H3QualificationWire.validate(changed(audit, "probes", .array(probes)), schema: "product_audit_v1"))
        XCTAssertThrowsError(try H3QualificationWire.validate(changed(try code(app: false), "entitlements", code()["entitlements"]!), schema: "code_identity_claim"))
    }
    func testAdmissionPassAndBothClosedSigningNonpassTuples() throws {
        for config in H3QualificationConfiguration.allCases {
            let pass = try admission(config), outer = try receipt(pass)
            XCTAssertNoThrow(try H3QualificationWire.validate(pass, schema: "inner_report_v1"))
            XCTAssertNoThrow(try H3QualificationWire.validate(outer, schema: "outer_receipt_v1"))
            XCTAssertEqual(try H3QualificationPredicateEvaluator.evaluate(receipt: outer, inner: pass), [])
            XCTAssertFalse(try H3QualificationPredicateEvaluator.validTerminalNonpass(receipt: outer, inner: pass))
            for error: Int32 in [0, -67050, 22] {
                let inner = try admission(config, signingError: error), receipt = try receipt(inner)
                XCTAssertEqual(try H3QualificationPredicateEvaluator.evaluate(receipt: receipt, inner: inner), ["application.live_self_signing_admission"])
                XCTAssertTrue(try H3QualificationPredicateEvaluator.validTerminalNonpass(receipt: receipt, inner: inner))
            }
        }
    }
    func testOuterRejectsImpossibleUnknownTaxonomyIdentityAndDeadlineMutations() throws {
        let inner = try admission(), outer = try receipt(inner)
        for field in ["guest_entered_count", "hv_vm_created_count", "signing_state"] {
            let altered = changed(outer, "taxonomy", changed(outer["taxonomy"]!, field, .string("UNKNOWN")))
            XCTAssertThrowsError(try H3QualificationPredicateEvaluator.evaluate(receipt: altered, inner: inner))
        }
        for field in ["gate_deadline_tick", "operation_deadline_tick", "kill_deadline_tick", "terminal_horizon_tick", "reap_tick"] {
            let altered = changed(outer, "deadlines", changed(outer["deadlines"]!, field, .string("1")))
            XCTAssertThrowsError(try H3QualificationPredicateEvaluator.evaluate(receipt: altered, inner: inner))
        }
        let altered = changed(outer, "application", changed(outer["application"]!, "named_after_reap", vnode(inode: 99)))
        XCTAssertThrowsError(try H3QualificationPredicateEvaluator.evaluate(receipt: altered, inner: inner))
    }
    func testOuterRetainsExactRunnerFailureSetAndDoesNotCloseMechanicalFailure() throws {
        let inner = try admission(signingError: 0), outer = try receipt(inner)
        let altered = changed(outer, "gate", changed(outer["gate"]!, "gate_return", .integer(40)))
        XCTAssertEqual(try H3QualificationPredicateEvaluator.evaluate(receipt: altered, inner: inner), ["application.live_self_signing_admission", "runner.gate"])
        XCTAssertFalse(try H3QualificationPredicateEvaluator.validTerminalNonpass(receipt: altered, inner: inner))
    }
}
#endif

#if EPR_H3_QUALIFICATION_TESTS
/// SYNTHETIC counted callbacks and deep values only. This class never creates
/// a Task, owner, timer, FD, process, native/Security call, or filesystem input.
final class H3QualificationApplicationEventTests: XCTestCase {
    private typealias App = H3QualificationApplicationEventStateMachine
    private typealias Worker = H3QualificationExecutionEventStateMachine
    private typealias Event = H3QualificationApplicationEvent
    private let run = UUID(uuidString: "00000000-0000-0000-0000-000000000042")!
    private let admitted = ProvenanceHostInspectionResult.assessed(nativeResult: 1, nativeError: 0,
        status: .admitted, capabilities: nil)
    override func setUp() { super.setUp(); executionTimeAllowance = 10 }

    private func monitor(first: Bool = true, closed: Bool = true, joined: Bool = true) -> H3QualificationMonitorEvidence {
        .init(bytesObserved: first ? 0 : 1, pollCalls: 1, readCalls: first ? 0 : 1,
            routeCalls: first ? 0 : 1, startedTick: 1, terminalTick: 2, fdClosed: closed, taskJoined: joined)
    }
    private func startup(_ mode: H3QualificationMode = .guest) -> App {
        var app = App(mode: mode)
        for (role, token): (App.IdentityRole, UInt64) in [(.owner, 11), (.model, 12), (.lab, 13), (.coordinator, 14)] {
            XCTAssertTrue(app.identity(role, value: token))
        }
        for event: Event in [.owner, .model, .lab, .storedModel, .storedLab, .coordinator,
                              .startup, .gateTimebase] { XCTAssertTrue(app.record(event)) }
        XCTAssertTrue(app.gate(numerator: 125, denominator: 3))
        XCTAssertTrue(app.record(.lifecycleInstall))
        XCTAssertTrue(app.lifecycle(owner: 11, stored: 15, returned: 15, numerator: 125, denominator: 3))
        for event: Event in [.exporterAdmission, .exporterInstance, .barrierInstance, .monitorTask] {
            XCTAssertTrue(app.record(event))
        }
        XCTAssertTrue(app.identity(.monitor, value: 16))
        XCTAssertTrue(app.record(.monitorInstalled))
        XCTAssertTrue(app.record(.signingInspection))
        return app
    }
    private func workerPrefix(token: Bool = true, error: Int32 = 0) throws -> Worker {
        var worker = Worker()
        XCTAssertTrue(worker.begin(identity: run, owner: 21))
        XCTAssertTrue(worker.record(.lifecycleBegin))
        XCTAssertTrue(worker.record(.workerTask))
        var reservation = H3QualificationReservationStateMachine(policy: .qualificationChecked)
        try reservation.recordReserve(tokenPresent: token, error: error)
        worker.reserveReturned(reservation)
        return worker
    }
    private func complete(_ original: Worker, native: H3QualificationNativeEventAssessment? = nil,
                          parity: Bool = true, releaseStatus: Int32 = 0) throws -> Worker {
        var worker = original
        if native != nil { XCTAssertTrue(worker.record(.nativeEntry)) }
        worker.workerReturned(native: native, parity: parity)
        _ = worker.record(.workerAwait)
        worker.join(monitor(), first: true)
        _ = worker.record(.checkedRelease)
        // The existing app's nil-presentation guard selects owner70 before
        // release. Do not invent cleanup effects for that inherited prefix.
        guard worker.vector[.checkedRelease] == 1 else { return worker }
        var reservation = try XCTUnwrap(worker.reservation)
        if try reservation.beginCheckedRelease(tokenPresent: reservation.state == .acquired) == .callToken {
            try reservation.finishCheckedRelease(status: releaseStatus)
        }
        worker.released(reservation)
        worker.sameOwners(identity: run, owner: 21)
        _ = worker.record(.publication)
        _ = worker.record(.lifecycleComplete)
        return worker
    }
    private func finish(_ original: App, worker: Worker? = nil) -> App {
        var app = original
        if let worker { XCTAssertTrue(app.mergeWorker(worker)) }
        XCTAssertTrue(app.joinedMonitor(monitor(), completionFirst: true))
        XCTAssertTrue(app.reportPrerequisites)
        for event: Event in [.frame, .exportAttempt, .exportOutcome, .terminalRequest] { XCTAssertTrue(app.record(event)) }
        return app
    }

    func testTwoAdmissionRunsHaveExactTwoPlusZeroEffectVector() throws {
        var app = startup(.admissionOnly)
        XCTAssertTrue(app.signing(admitted))
        app = finish(app)
        let total = try H3QualificationApplicationEventVector.sum(app.vector, app.vector)
        for event: Event in [.owner, .model, .lab, .storedModel, .storedLab, .coordinator, .startup,
            .gateTimebase, .gateAccepted, .lifecycleInstall, .lifecycleInstance, .exporterAdmission,
            .exporterInstance, .barrierInstance, .monitorTask, .monitorInstalled, .signingInspection,
            .signingTask, .wrapperSigning, .signingJoined, .barrierClaim, .monitorCancel, .monitorClose,
            .monitorJoin, .frame, .exportAttempt, .exportOutcome, .terminalRequest] {
            XCTAssertEqual(total[event], 2, "SYNTHETIC admission \(event)")
        }
        for event in Worker.workerEvents { XCTAssertEqual(total[event], 0) }
        for event: Event in [.cancellationRoute, .cancellationWorker, .forceTimer, .ordinaryLifecycle,
            .extraWorker, .threadDetach, .childMainActorTask, .continuation, .retry, .sqlite, .h4, .primeGit] {
            XCTAssertEqual(total[event], 0)
        }
    }

    func testTwoGuestPassRunsHaveExactTwoPlusTwoAndFourWatchdogs() throws {
        let native = try H3QualificationNativeEventAssessment.replay(H3QualificationRunnerTests.externalGuestCapture())
        XCTAssertEqual(native.signingCalls, 1); XCTAssertEqual(native.timebaseCalls, 1)
        XCTAssertEqual(native.watchdogCreates, 2); XCTAssertEqual(native.watchdogJoins, 2)
        XCTAssertEqual(native.vmCreates, 2); XCTAssertEqual(native.guestEntries, 2)
        let worker = try complete(workerPrefix(), native: native)
        XCTAssertTrue(worker.reportable)
        var app = startup(); XCTAssertTrue(app.signing(admitted)); app = finish(app, worker: worker)
        let total = try H3QualificationApplicationEventVector.sum(app.vector, app.vector)
        for event: Event in [.wrapperSigning, .nativeSigning, .gateTimebase, .nativeTimebase,
            .uuid, .lifecycleBegin, .workerTask, .workerAwait, .reserveAttempt, .reserveAcquired,
            .nativeEntry, .checkedRelease, .nativeRelease, .publication, .lifecycleComplete] {
            XCTAssertEqual(total[event], 2, "SYNTHETIC guest \(event)")
        }
        for event: Event in [.watchdogCreate, .watchdogJoin, .vmCreate, .guestRun] { XCTAssertEqual(total[event], 4) }
        for event: Event in [.threadDetach, .childMainActorTask, .continuation, .extraWorker, .retry,
            .cancellationWorker, .forceTimer, .ordinaryLifecycle, .sqlite, .h4, .primeGit] { XCTAssertEqual(total[event], 0) }
        XCTAssertThrowsError(try H3QualificationApplicationEventVector.sum(total, app.vector))
    }

    func testPreparationAndSourceOnlyNativePrefixesKeepLowerCounts() throws {
        let failed = try complete(workerPrefix(token: false, error: 12))
        XCTAssertTrue(failed.reportable)
        XCTAssertEqual(failed.vector[.reserveAttempt], 1)
        XCTAssertEqual(failed.vector[.checkedRelease], 1)
        for event: Event in [.nativeEntry, .reserveAcquired, .nativeRelease, .nativeSigning,
            .nativeTimebase, .watchdogCreate, .watchdogJoin, .vmCreate, .guestRun] { XCTAssertEqual(failed.vector[event], 0) }
        XCTAssertEqual(failed.reservation?.state, .releasedWithoutToken)
        let native = try H3QualificationNativeEventAssessment.replay(H3QualificationRunnerTests.externalGuestCapture(nonpass: true))
        XCTAssertEqual(native.signingCalls, 1); XCTAssertEqual(native.timebaseCalls, 1)
        XCTAssertEqual(native.watchdogCreates, 1); XCTAssertEqual(native.watchdogJoins, 1)
        XCTAssertEqual(native.vmCreates, 1); XCTAssertEqual(native.guestEntries, 1)
        let nonpass = try complete(workerPrefix(), native: native)
        XCTAssertTrue(nonpass.reportable)
        XCTAssertEqual(nonpass.vector[.watchdogCreate], 1)
        XCTAssertNotEqual(native.presentation.wire["status"], .string("PASS"))
    }

    func testCountedInspectionProviderIsSingleEntryAndCachedWithoutTaskPadding() throws {
        let cases: [ProvenanceHostInspectionResult] = [admitted,
            .assessed(nativeResult: 0, nativeError: 0, status: .rejected, capabilities: nil),
            .assessed(nativeResult: -1, nativeError: -50, status: .apiError, capabilities: nil)]
        for expected in cases {
            var cache = H3QualificationHostInspectionCache(), calls = 0
            let first = try cache.inspect(bundleIdentifierValid: true, expectedTeamValid: true) { calls += 1; return expected }
            let second = try cache.inspect(bundleIdentifierValid: true, expectedTeamValid: true) { calls += 1; return admitted }
            XCTAssertEqual(first, expected); XCTAssertEqual(second, expected); XCTAssertEqual(calls, 1)
            var app = startup(.admissionOnly); XCTAssertTrue(app.signing(first)); app = finish(app)
            XCTAssertEqual(app.vector[.signingTask], 1); XCTAssertEqual(app.vector[.wrapperSigning], 1)
            XCTAssertFalse(app.signing(second)); XCTAssertTrue(app.failed)
            XCTAssertEqual(app.vector[.signingTask], 1)
        }
        for flags in [(false, true), (true, false)] {
            var cache = H3QualificationHostInspectionCache(), calls = 0
            let result = try cache.inspect(bundleIdentifierValid: flags.0, expectedTeamValid: flags.1) { calls += 1; return admitted }
            XCTAssertEqual(calls, 0)
            var app = startup(); XCTAssertTrue(app.signing(result))
            XCTAssertEqual(app.vector[.signingTask], 0); XCTAssertEqual(app.vector[.wrapperSigning], 0)
            XCTAssertFalse(app.reportPrerequisites)
        }
    }

    func testIdentityTimebaseAndForbiddenActionsLatchWithoutInventingEvents() throws {
        for mutation in 0..<8 {
            var app = startup()
            switch mutation {
            case 0: XCTAssertFalse(app.identity(.owner, value: 99))
            case 1: XCTAssertFalse(app.identity(.model, value: 99))
            case 2: XCTAssertFalse(app.identity(.lab, value: 99))
            case 3: XCTAssertFalse(app.identity(.coordinator, value: 99))
            case 4: XCTAssertFalse(app.identity(.monitor, value: 99))
            case 5: XCTAssertFalse(app.gate(numerator: 126, denominator: 3))
            case 6: XCTAssertFalse(app.lifecycle(owner: 11, stored: 15, returned: 16, numerator: 125, denominator: 3))
            default: XCTAssertFalse(app.record(.startup))
            }
            XCTAssertTrue(app.failed); XCTAssertFalse(app.reportPrerequisites)
        }
        for event: Event in [.ordinaryLifecycle, .extraWorker, .threadDetach, .childMainActorTask,
            .continuation, .retry, .sqlite, .h4, .primeGit, .frame, .exportAttempt, .exportOutcome] {
            var app = startup(); XCTAssertFalse(app.record(event)); XCTAssertEqual(app.vector[event], 0)
            XCTAssertTrue(app.failed)
        }
        var absent = App(mode: .guest)
        XCTAssertFalse(absent.lifecycle(owner: 11, stored: 0, returned: 0, numerator: 1, denominator: 1))
    }

    func testReleaseAndParityFaultsCannotReportButCleanupCountsRemain() throws {
        let native = try H3QualificationNativeEventAssessment.replay(H3QualificationRunnerTests.externalGuestCapture())
        for (parity, status) in [(false, Int32(0)), (true, 22)] {
            let worker = try complete(workerPrefix(), native: native, parity: parity, releaseStatus: status)
            XCTAssertFalse(worker.reportable); XCTAssertTrue(worker.failed)
            XCTAssertEqual(worker.vector[.checkedRelease], parity ? 1 : 0)
            XCTAssertEqual(worker.vector[.nativeRelease], parity ? 1 : 0)
            XCTAssertEqual(worker.vector[.publication], 0); XCTAssertEqual(worker.vector[.lifecycleComplete], 0)
            var app = startup(); XCTAssertTrue(app.signing(admitted))
            XCTAssertFalse(app.mergeWorker(worker)); XCTAssertFalse(app.reportPrerequisites)
        }
        var wrong = try complete(workerPrefix(token: false, error: 12))
        wrong.sameOwners(identity: run, owner: 99)
        XCTAssertFalse(wrong.reportable)
        XCTAssertEqual(wrong.vector[.checkedRelease], 1)
        XCTAssertFalse(wrong.record(.checkedRelease))
        XCTAssertEqual(wrong.vector[.checkedRelease], 1)
        var canceledParity = try workerPrefix()
        XCTAssertTrue(canceledParity.record(.nativeEntry))
        canceledParity.workerReturned(native: native, parity: false)
        _ = canceledParity.record(.workerAwait); canceledParity.join(monitor(first: false), first: false)
        XCTAssertFalse(canceledParity.record(.lifecycleComplete))
        XCTAssertEqual(canceledParity.vector[.checkedRelease], 0)
        XCTAssertEqual(canceledParity.vector[.lifecycleComplete], 0)
    }

    func testCancellationPrefixesNeverPerformExplicitReleaseOrReport() throws {
        for prefix in 0...2 {
            var premature = Worker()
            if prefix > 0 { XCTAssertTrue(premature.begin(identity: run, owner: 21)) }
            if prefix > 1 { XCTAssertTrue(premature.record(.lifecycleBegin)) }
            premature.reserveReturned(H3QualificationReservationStateMachine(policy: .qualificationChecked))
            XCTAssertTrue(premature.failed); XCTAssertNil(premature.reservation)
            XCTAssertEqual(premature.vector[.reserveAttempt], 0)
            XCTAssertEqual(premature.vector[.workerTask], 0)
        }
        for acquired in [false, true] {
            var worker = Worker(); XCTAssertTrue(worker.begin(identity: run, owner: 21))
            XCTAssertTrue(worker.record(.lifecycleBegin)); XCTAssertTrue(worker.record(.workerTask))
            var reservation = H3QualificationReservationStateMachine(policy: .qualificationChecked)
            if acquired { try reservation.recordReserve(tokenPresent: true, error: 0) }
            worker.reserveReturned(reservation); worker.workerReturned()
            XCTAssertTrue(worker.record(.workerAwait)); worker.join(monitor(first: false), first: false)
            XCTAssertTrue(worker.record(.lifecycleComplete)); XCTAssertFalse(worker.reportable)
            XCTAssertEqual(worker.vector[.checkedRelease], 0); XCTAssertEqual(worker.vector[.nativeRelease], 0)
            XCTAssertEqual(worker.vector[.reserveAttempt], acquired ? 1 : 0)
            XCTAssertEqual(worker.vector[.reserveAcquired], acquired ? 1 : 0)
            XCTAssertFalse(worker.record(.checkedRelease)); XCTAssertEqual(worker.vector[.checkedRelease], 0)
        }
        for tuple in [(false, Int32(0)), (false, -1), (true, 1), (true, -1)] {
            var worker = try workerPrefix(token: tuple.0, error: tuple.1)
            worker.workerReturned(); XCTAssertTrue(worker.record(.workerAwait))
            XCTAssertEqual(worker.vector[.reserveAcquired], 0)
            var reservation = try XCTUnwrap(worker.reservation)
            XCTAssertThrowsError(try reservation.beginCheckedRelease(tokenPresent: tuple.0))
            XCTAssertEqual(worker.vector[.checkedRelease], 0)
            XCTAssertEqual(try reservation.deinitDecision(tokenPresent: tuple.0), .noCall)
        }
    }

    func testPreparedMonitorCanRunBeforeHandleInstallButCannotBeClaimed() throws {
        for cancelBeforeInstall in [false, true] {
            var barrier = H3QualificationBarrierStateMachine()
            try barrier.prepare(identity: 31)
            XCTAssertFalse(barrier.monitorInstalled)
            XCTAssertThrowsError(try barrier.claimCompletion())
            XCTAssertThrowsError(try barrier.install(identity: 32))
            XCTAssertTrue(try barrier.beginRead())
            XCTAssertThrowsError(try barrier.claimCompletion())
            try barrier.finishRead(cancellationObserved: cancelBeforeInstall)
            if cancelBeforeInstall { try barrier.routeCancellation() }
            try barrier.install(identity: 31)
            XCTAssertEqual(try barrier.claimCompletion(), cancelBeforeInstall ? .cancellation : .completion)
            try barrier.join(identity: 31, fdClosed: true, handleCanceled: !cancelBeforeInstall)
            XCTAssertEqual(barrier.permitsReport, !cancelBeforeInstall)
            XCTAssertThrowsError(try barrier.prepare(identity: 31))
            XCTAssertThrowsError(try barrier.install(identity: 31))
        }
    }

    func testBarrierCountedCallbacksAreOutsideBorrowAndCompetingClaimsCannotWin() throws {
        // The reducer returns before these counted callbacks execute. Reentry
        // uses the same reducer, never a second owner or real lock/task.
        var barrier = H3QualificationBarrierStateMachine(), callbacks = [String]()
        try barrier.prepare(identity: 31); try barrier.install(identity: 31)
        let winner = try barrier.claimCompletion()
        func cancelCallback() throws {
            callbacks.append("cancel")
            XCTAssertThrowsError(try barrier.claimCompletion())
            XCTAssertFalse(try barrier.beginRead())
        }
        XCTAssertEqual(winner, .completion); try cancelCallback()
        callbacks.append("await")
        XCTAssertThrowsError(try barrier.join(identity: 32, fdClosed: true, handleCanceled: true))
        XCTAssertFalse(barrier.permitsReport)
        try barrier.join(identity: 31, fdClosed: true, handleCanceled: true)
        callbacks.append("report")
        XCTAssertEqual(callbacks, ["cancel", "await", "report"])

        var canceled = H3QualificationBarrierStateMachine(); try canceled.prepare(identity: 41)
        XCTAssertTrue(try canceled.beginRead())
        XCTAssertThrowsError(try canceled.routeCancellation())
        XCTAssertThrowsError(try canceled.claimCompletion())
        try canceled.finishRead(cancellationObserved: true)
        try canceled.routeCancellation()
        callbacks = ["requestQuit"]
        XCTAssertThrowsError(try canceled.routeCancellation())
        try canceled.install(identity: 41)
        XCTAssertEqual(try canceled.claimCompletion(), .cancellation)
        callbacks.append("await")
        try canceled.join(identity: 41, fdClosed: true, handleCanceled: false)
        callbacks.append("lifecycle.complete")
        XCTAssertFalse(canceled.permitsReport)
        XCTAssertEqual(callbacks, ["requestQuit", "await", "lifecycle.complete"])
    }

    func testGateMatcherRejectsEveryByteAndEveryTruncationOrTrailingFrame() throws {
        let nonce = String(repeating: "00", count: 32)
        for mode in H3QualificationMode.allCases {
            let frame = try H3QualificationProtocol.gateFrame(mode: mode, nonce: nonce)
            XCTAssertNoThrow(try H3QualificationGateIdentity.validate(frame, mode: mode, nonce: nonce))
            for offset in frame.indices {
                var bad = frame; bad[offset] ^= 1
                XCTAssertThrowsError(try H3QualificationGateIdentity.validate(bad, mode: mode, nonce: nonce))
            }
            for length in 0..<41 {
                XCTAssertThrowsError(try H3QualificationGateIdentity.validate(Data(frame.prefix(length)), mode: mode, nonce: nonce))
            }
            for bad in [frame + Data([0]), frame + frame, Data("EPRH3C01".utf8) + frame.dropFirst(8)] {
                XCTAssertThrowsError(try H3QualificationGateIdentity.validate(bad, mode: mode, nonce: nonce))
            }
        }
    }

    func testTraceCannotReportUnjoinedNonreturningWorkerOrMonitor() throws {
        var app = startup(); XCTAssertTrue(app.signing(admitted))
        var worker = try workerPrefix(token: false, error: 12)
        XCTAssertFalse(worker.record(.workerAwait)); XCTAssertFalse(worker.reportable)
        XCTAssertFalse(app.mergeWorker(worker)); XCTAssertFalse(app.reportPrerequisites)
        for evidence in [monitor(closed: false), monitor(joined: false)] {
            var candidate = startup(.admissionOnly); XCTAssertTrue(candidate.signing(admitted))
            XCTAssertFalse(candidate.joinedMonitor(evidence, completionFirst: true))
            XCTAssertFalse(candidate.record(.frame)); XCTAssertFalse(candidate.reportPrerequisites)
        }
    }

    func testNativeCallProjectionKeepsEveryEarlySigningAndClockPrefix() throws {
        for (label, capture, expectedSigning, expectedTimebase) in try H3QualificationRunnerTests.applicationEarlyNativeCaptures() {
            let assessment = try H3QualificationNativeEventAssessment.replay(capture)
            XCTAssertEqual(assessment.signingCalls, expectedSigning, label)
            XCTAssertEqual(assessment.timebaseCalls, expectedTimebase, label)
            XCTAssertEqual(assessment.watchdogCreates, 0, label); XCTAssertEqual(assessment.watchdogJoins, 0, label)
            XCTAssertEqual(assessment.vmCreates, 0, label); XCTAssertEqual(assessment.guestEntries, 0, label)
            let outer = try XCTUnwrap(capture.wire["outer"])
            let generation = try XCTUnwrap(UInt64(try XCTUnwrap(capture.wire["source"]?["generation"]?.stringValue)))
            let byChronology: UInt16 = outer["signing_admitted"]?.intValue == 1 ||
                (outer["failure_stage"]?.intValue == 1 && generation > 0) ? 1 : 0
            XCTAssertEqual(assessment.signingCalls, byChronology, label)
            var worker = try complete(workerPrefix(), native: assessment)
            XCTAssertTrue(worker.reportable, label)
            XCTAssertEqual(worker.vector[.nativeSigning], expectedSigning, label)
            XCTAssertFalse(worker.record(.nativeEntry), label)
        }
    }

    func testAssessedTupleContradictionsAndCapabilityInjectionNeverAuthorizeWorker() throws {
        for tuple in [(Int32(1), Int32(0), H3QualificationSigningStatus.rejected),
                      (0, 0, .admitted), (-1, 0, .apiError), (-1, -50, .admitted), (1, 22, .admitted)] {
            var app = startup()
            XCTAssertFalse(app.signing(.assessed(nativeResult: tuple.0, nativeError: tuple.1, status: tuple.2, capabilities: nil)))
            XCTAssertTrue(app.failed); XCTAssertEqual(app.vector[.wrapperSigning], 0)
            XCTAssertFalse(app.reportPrerequisites)
        }
        let incomplete = ProvenanceHostInspectionResult.classify(nativeResult: 2, nativeError: 0,
            queryHypervisor: false, capabilities: nil)
        var app = startup(); XCTAssertTrue(app.signing(incomplete))
        XCTAssertEqual(app.vector[.wrapperSigning], 1); XCTAssertFalse(app.reportPrerequisites)
    }

    func testReleaseCannotSubstituteStateErrorOwnerOrPriorCallCounts() throws {
        let native = try H3QualificationNativeEventAssessment.replay(H3QualificationRunnerTests.externalGuestCapture())
        for token in [false, true] {
            var worker = try workerPrefix(token: token, error: token ? 0 : 12)
            if token { XCTAssertTrue(worker.record(.nativeEntry)) }
            worker.workerReturned(native: token ? native : nil)
            XCTAssertTrue(worker.record(.workerAwait)); worker.join(monitor(), first: true)
            XCTAssertTrue(worker.record(.checkedRelease))
            var substituted = H3QualificationReservationStateMachine(policy: .qualificationChecked)
            try substituted.recordReserve(tokenPresent: !token, error: token ? 99 : 0)
            if try substituted.beginCheckedRelease(tokenPresent: !token) == .callToken { try substituted.finishCheckedRelease(status: 0) }
            worker.released(substituted)
            XCTAssertTrue(worker.failed); XCTAssertFalse(worker.reportable)
            XCTAssertEqual(worker.vector[.nativeRelease], 0)
        }
        var finished = try complete(workerPrefix(), native: native)
        let released = try XCTUnwrap(finished.reservation)
        finished.released(released)
        XCTAssertTrue(finished.failed); XCTAssertEqual(finished.vector[.nativeRelease], 1)
        var premature = Worker(); XCTAssertTrue(premature.begin(identity: run, owner: 21))
        XCTAssertTrue(premature.record(.lifecycleBegin)); XCTAssertTrue(premature.record(.workerTask))
        premature.reserveReturned(released)
        XCTAssertTrue(premature.failed); XCTAssertEqual(premature.vector[.reserveAttempt], 0)
        var canceled = try workerPrefix(); canceled.workerReturned()
        XCTAssertTrue(canceled.record(.workerAwait)); canceled.join(monitor(), first: true)
        XCTAssertFalse(canceled.record(.checkedRelease)); XCTAssertEqual(canceled.vector[.checkedRelease], 0)
    }

    func testAllReturnableStartRejectionsJoinExactMonitorWithoutWorkerOrRelease() throws {
        let cases: [(Bool, Bool, Bool, H3QualificationStartRejection?)] = [
            (false, false, false, .lifecycleNotInstalled), (false, true, true, .lifecycleNotInstalled),
            (true, false, true, .notAdmitted), (true, false, false, .notAdmitted),
            (true, true, false, .modelStateRejected), (true, true, true, nil)
        ]
        for entry in cases {
            XCTAssertEqual(H3QualificationStartEventPolicy.rejection(lifecycleInstalled: entry.0,
                admitted: entry.1, modelEligible: entry.2), entry.3)
        }
        for rejection: H3QualificationStartRejection in [.lifecycleNotInstalled, .notAdmitted,
            .modelStateRejected, .lifecycleBeginRejected] {
            for first in [false, true] {
                var prefix = Worker(), barrier = H3QualificationBarrierStateMachine()
                var callbacks = [String]()
                if rejection == .lifecycleBeginRejected {
                    XCTAssertTrue(prefix.begin(identity: run, owner: 21))
                    XCTAssertTrue(prefix.record(.lifecycleBegin))
                }
                try barrier.prepare(identity: 31); try barrier.install(identity: 31)
                if !first { try barrier.cancelForInternalFailure(); try barrier.routeCancellation(); callbacks.append("requestQuit") }
                XCTAssertEqual(try barrier.claimCompletion(), first ? .completion : .cancellation)
                if first { callbacks.append("cancel") }
                callbacks.append("await")
                XCTAssertThrowsError(try barrier.join(identity: 99, fdClosed: true, handleCanceled: first))
                try barrier.join(identity: 31, fdClosed: true, handleCanceled: first)
                callbacks.append("startRejected")
                XCTAssertEqual(callbacks, first ? ["cancel", "await", "startRejected"] : ["requestQuit", "await", "startRejected"])
                XCTAssertEqual(H3QualificationH3Completion.startRejected(rejection), .startRejected(rejection))
                XCTAssertEqual(prefix.vector[.uuid], rejection == .lifecycleBeginRejected ? 1 : 0)
                for event: Event in [.workerTask, .workerAwait, .reserveAttempt, .reserveAcquired,
                    .nativeEntry, .checkedRelease, .nativeRelease, .publication, .lifecycleComplete] {
                    XCTAssertEqual(prefix.vector[event], 0)
                }
                XCTAssertFalse(prefix.reportable)
            }
        }
    }

    func testMixedOrdinaryAndSeparateInterruptBudgetsStayInsideEveryFrozenCap() throws {
        for role in [H3QualificationInputStateMachine.Role.gate, .cancellation] {
            var input = try H3QualificationInputStateMachine(role: role, startTick: 1, numerator: 1, denominator: 1)
            let ordinary = role == .gate ? 601 : 1001
            for _ in 0..<63 { try input.beginPoll(at: 2); try input.finishPoll(.interrupted, at: 2) }
            for index in 0..<ordinary {
                try input.beginPoll(at: 2); try input.finishPoll(.ready, at: 2)
                if index == ordinary - 1 {
                    for _ in 0..<63 { try input.beginRead(at: 2, requested: 1); try input.finishRead(.interrupted) }
                }
                try input.beginRead(at: 2, requested: 1); try input.finishRead(.again)
            }
            XCTAssertEqual(input.ordinaryPolls, UInt32(ordinary)); XCTAssertEqual(input.ordinaryReads, UInt32(ordinary))
            XCTAssertEqual(input.pollInterrupts, 63); XCTAssertEqual(input.readInterrupts, 63)
            XCTAssertEqual(input.pollCalls, UInt32(ordinary + 63)); XCTAssertEqual(input.readCalls, UInt32(ordinary + 63))
            XCTAssertLessThanOrEqual(input.pollCalls, role == .gate ? 665 : 1065)
            XCTAssertLessThanOrEqual(input.readCalls, role == .gate ? 729 : 1129)
            XCTAssertThrowsError(try input.beginPoll(at: 2))
            let snapshot = input
            XCTAssertThrowsError(try input.beginRead(at: 2, requested: 1))
            XCTAssertEqual(input.pollCalls, snapshot.pollCalls); XCTAssertEqual(input.readCalls, snapshot.readCalls)
        }
    }

    func testLifecyclePolicyCountsPreRunActiveAndForcedCancellationPrefixes() throws {
        // The frozen lifecycle controller is not instantiated. These are its
        // actual policy effects and pending-deadline decisions, with inert
        // callback counts. Static adapter review supplies lock/timer wiring.
        for active in [false, true] {
            for validClock in [false, true] {
                var policy = AppLifecyclePolicy(timebaseNumerator: validClock ? 1 : 0, timebaseDenominator: 1)
                if active { try policy.beginRun(run) }
                let effects = policy.request(.quit, now: 1)
                let forced = effects.contains(.forceSelfExit70)
                var cancelCallbacks = 0, owner70 = 0, normalCallbacks = 0, timerCreations = 0
                if policy.hasPendingDeadline { timerCreations += 1 }
                // deliver() gives force priority over every queued cancellation.
                if forced { owner70 += 1 }
                else {
                    for effect in effects {
                        switch effect {
                        case .requestCancellation(let id): XCTAssertEqual(id, run); cancelCallbacks += 1
                        case .terminateNormally: normalCallbacks += 1
                        default: break
                        }
                    }
                }
                XCTAssertEqual(timerCreations, validClock ? 1 : 0)
                XCTAssertEqual(cancelCallbacks, active && validClock ? 1 : 0)
                XCTAssertEqual(normalCallbacks, !active && validClock ? 1 : 0)
                XCTAssertEqual(owner70, validClock ? 0 : 1)
                XCTAssertTrue(policy.request(.quit, now: 1).isEmpty)
                if active && validClock {
                    let completed = policy.observe(runID: run, state: .completed(.recoveryVolatile), now: 2)
                    XCTAssertEqual(completed, [.terminateNormally])
                    XCTAssertEqual(policy.poll(now: 5_000_000_001), [.forceSelfExit70])
                    XCTAssertTrue(policy.poll(now: 5_000_000_002).isEmpty)
                    XCTAssertFalse(policy.hasPendingDeadline)
                }
            }
        }
    }

    func testTerminalOutcomeMatrixAfterCompletedEventTraceHasOneWinningCallback() throws {
        for outcome in [H3QualificationTerminalStateMachine.ExportOutcome.succeeded, .failed] {
            for code: Int32 in [0, 64, 70, 74] {
                var app = startup(.admissionOnly); XCTAssertTrue(app.signing(admitted))
                XCTAssertTrue(app.joinedMonitor(monitor(), completionFirst: true))
                XCTAssertTrue(app.record(.frame)); XCTAssertTrue(app.record(.exportAttempt))
                var terminal = H3QualificationTerminalStateMachine(), callbacks = 0
                try terminal.recordExport(outcome)
                XCTAssertTrue(app.record(.exportOutcome)); XCTAssertTrue(app.record(.terminalRequest))
                let permitted = code == 70 || (code == 0 && outcome == .succeeded) || (code == 74 && outcome == .failed)
                if permitted { try terminal.claim(code); callbacks += 1 }
                else { XCTAssertThrowsError(try terminal.claim(code)); try terminal.claim(70); callbacks += 1 }
                for duplicate: Int32 in [0, 64, 70, 74] { XCTAssertThrowsError(try terminal.claim(duplicate)) }
                XCTAssertEqual(callbacks, 1)
                XCTAssertFalse(app.record(.exportOutcome)); XCTAssertFalse(app.record(.terminalRequest))
                XCTAssertEqual(app.vector[.exportOutcome], 1); XCTAssertEqual(app.vector[.terminalRequest], 1)
            }
        }
    }

    func testCancellationHelperAndTimerPrefixVectorsUseActualSharedDecisions() throws {
        let states: [H3QualificationReservationStateMachine.State] = [.unprepared, .failedReserve,
            .invalidReserveNoToken, .invalidReserveWithToken, .acquired, .releasedWithoutToken, .releaseAttemptedToken]
        for policy in [H3QualificationReservationStateMachine.Policy.ordinaryDeinit, .qualificationChecked] {
            for state in states {
                for token in [false, true] {
                    XCTAssertEqual(H3QualificationCancellationEventPolicy.mayStartHelper(policy: policy,
                        state: state, tokenPresent: token), token && (policy == .ordinaryDeinit || state == .acquired))
                }
            }
        }
        for state in [H3QualificationReservationStateMachine.State.unprepared, .acquired] {
            for validClock in [false, true] {
                var app = startup(), policy = AppLifecyclePolicy(timebaseNumerator: validClock ? 1 : 0, timebaseDenominator: 1)
                try policy.beginRun(run)
                XCTAssertTrue(app.record(.cancellationRoute))
                let effects = policy.request(.quit, now: 1)
                if policy.hasPendingDeadline { XCTAssertTrue(app.record(.forceTimer)) }
                var helperCallbacks = 0
                if !effects.contains(.forceSelfExit70), effects.contains(.requestCancellation(runID: run)),
                   H3QualificationCancellationEventPolicy.mayStartHelper(policy: .qualificationChecked,
                    state: state, tokenPresent: state == .acquired) {
                    XCTAssertTrue(app.record(.cancellationWorker)); helperCallbacks += 1
                }
                XCTAssertEqual(app.vector[.cancellationRoute], 1)
                XCTAssertEqual(app.vector[.forceTimer], validClock ? 1 : 0)
                XCTAssertEqual(app.vector[.cancellationWorker], validClock && state == .acquired ? 1 : 0)
                XCTAssertEqual(helperCallbacks, Int(app.vector[.cancellationWorker]))
                XCTAssertFalse(app.reportPrerequisites)
                XCTAssertTrue(policy.request(.quit, now: 1).isEmpty)
                XCTAssertFalse(app.record(.cancellationRoute))
                XCTAssertEqual(app.vector[.cancellationRoute], 1)
            }
        }
    }
}

extension H3QualificationRunnerTests {
    /// Deep-owned SYNTHETIC prefixes reused from the existing native fixture
    /// builders. No native entry, file, clock, Task or process is involved.
    static func applicationEarlyNativeCaptures() throws -> [(String, H3QualificationNativeCapture, UInt16, UInt16)] {
        let owner = H3QualificationRunnerTests()
        var values: [(String, EPRGuestH3CursorResumeResult, UInt16, UInt16)] = []
        for outcome: UInt32 in [2, 4, 5] {
            var value = owner.earlyNative(stage: outcome == 2 ? 1 : 0, error: outcome == 2 ? 22 : 0)
            value.outcome = outcome; value.start_ticks = 0; value.end_ticks = 0; value.teardown_pass = 0
            value.signing_error = .min; value.source = owner.untouchedPhase(0); value.target = owner.untouchedPhase(0)
            value.resources_quarantined = outcome == 5 ? 1 : 0
            values.append(("IMMEDIATE_\(outcome)", value, 0, 0))
        }
        var beforeGeneration = owner.earlyNative(error: 22)
        beforeGeneration.signing_error = .min
        beforeGeneration.source = owner.untouchedPhase(0); beforeGeneration.target = owner.untouchedPhase(0)
        values.append(("BEFORE_GENERATION", beforeGeneration, 0, 0))
        var beforeSigning = owner.earlyNative(stage: 18, error: 89)
        beforeSigning.signing_error = .min; beforeSigning.cancellation_requested = 1; beforeSigning.outcome = 3
        values.append(("BEFORE_SIGNING", beforeSigning, 0, 0))
        values.append(("SIGNING_REJECTED", owner.earlyNative(), 1, 0))
        var api = owner.earlyNative(error: -50); api.signing_error = -50
        values.append(("SIGNING_API_ERROR", api, 1, 0))
        var clock = owner.earlyNative(stage: 2, error: 22); clock.signing_admitted = 1
        values.append(("TIMEBASE_FAILED", clock, 1, 1))
        var pages = clock; pages.failure_stage = 3; pages.timebase_numer = 125; pages.timebase_denom = 3
        values.append(("PAGE_SIZE_FAILED", pages, 1, 1))
        return values.map { ($0.0, GuestH3LiveVerifier.qualificationCapture($0.1), $0.2, $0.3) }
    }
}
#endif

#if EPR_H3_QUALIFICATION_TESTS
extension H3QualificationExternalValidationTests {
    static func spawnSupportFixture(_ configuration: H3QualificationConfiguration,
                                    guestMode: Bool = false) throws -> (H3QualificationJSONValue, H3QualificationJSONValue) {
        let owner = H3QualificationExternalValidationTests()
        let inner = try guestMode ? owner.guest(configuration) : owner.admission(configuration)
        return (inner, try owner.receipt(inner))
    }
    static func spawnSupportReceipt(_ inner: H3QualificationJSONValue) throws -> H3QualificationJSONValue {
        try H3QualificationExternalValidationTests().receipt(inner)
    }
}
extension H3QualificationRunnerTests {
    static func spawnSupportVMFailure() -> H3QualificationNativeCapture {
        let owner = H3QualificationRunnerTests()
        var value = owner.sourcePreparedNative(); owner.setSCTLRTransitionZero(&value)
        value.source = owner.untouchedPhase(9); value.source.host_unmap_status = (0, 0, 0)
        value.source.conserved = 1; value.source.vm_create_status = -5
        value.failure_stage = 4; value.first_error = -5
        return GuestH3LiveVerifier.qualificationCapture(value)
    }
}

/// SYNTHETIC complete values only. No controller, spawn, process, native,
/// Security, descriptor, filesystem, clock, app or guest operation is invoked.
final class H3QualificationSpawnSupportMatrixTests: XCTestCase {
    private typealias V = H3QualificationJSONValue
    private let supports = ["NOT_ENTERED", "NOT_QUERIED", "NATIVE_ENTRY_SUCCEEDED", "NATIVE_ENTRY_FAILED", "UNKNOWN"]
    override func setUp() { super.setUp(); executionTimeAllowance = 10 }
    private func set(_ value: V, _ path: [String], _ replacement: V) -> V {
        precondition(!path.isEmpty && path.count <= 4)
        var object = value.objectValue!
        object[path[0]] = path.count == 1 ? replacement : set(object[path[0]]!, Array(path.dropFirst()), replacement)
        return .object(object)
    }
    private func classify(_ receipt: V, inner: V?) throws -> V {
        let failed = try H3QualificationPredicateEvaluator.evaluate(receipt: receipt, inner: inner)
        let noChild = receipt["child"]?["disposition"] == .string("NOT_CREATED")
        return set(receipt, ["classification"], .object([
            "failed_predicates": .array(failed.map(V.string)),
            "result": .string(noChild ? "NO_CHILD_FAILURE" : failed.isEmpty ? "RUN_CANDIDATE_PASS" : "RETAINED_NONPASS")]))
    }
    private func noChild(_ launched: V, spawn: Int64 = 1) -> V {
        let application = launched["application"]!
        var value = set(launched, ["application"], .object([
            "held_before_spawn": application["held_before_spawn"]!, "named_before_spawn": application["named_before_spawn"]!,
            "held_terminal": application["held_after_reap"]!, "named_terminal": application["named_after_reap"]!,
            "pre_static": application["pre_static"]!]))
        value = set(value, ["child"], .object(["disposition": .string("NOT_CREATED"), "exit": .string("NOT_APPLICABLE"),
            "pid": .integer(0), "reap": .string("NOT_APPLICABLE"), "signal": .string("NOT_APPLICABLE"), "wait_status": .string("NOT_APPLICABLE")]))
        for (path, replacement): ([String], V) in [
            (["spawn", "spawn_return"], .integer(spawn)), (["kill", "pid"], .integer(0)),
            (["taxonomy", "app_launched"], .bool(false)), (["taxonomy", "signing_state"], .string("NOT_ENTERED")),
            (["taxonomy", "guest_entered_count"], .integer(0)), (["taxonomy", "hv_vm_created_count"], .integer(0)),
            (["deadlines", "reap_tick"], .string("0")), (["deadlines", "gate_attempt_tick"], .string("0")),
            (["deadlines", "gate_return_tick"], .string("0")), (["gate", "gate_writes"], .integer(0)),
            (["gate", "gate_return"], .integer(Int64(Int32.min))), (["evidence", "inner_valid"], .bool(false)),
            (["evidence", "inner_byte_count"], .integer(0)), (["evidence", "inner_sha256"], .string(H3QualificationProtocol.hash(Data()))),
            (["evidence", "hypervisor_support"], .string("NOT_ENTERED")), (["evidence", "effective_hypervisor_value"], .string("NOT_OBSERVED")),
            (["evidence", "effective_entitlements_sha256"], .string(String(repeating: "0", count: 64))),
            (["classification"], .object(["failed_predicates": .array([.string("runner.spawn")]), "result": .string("NO_CHILD_FAILURE")]))
        ] { value = set(value, path, replacement) }
        return value
    }

    func testSpawnDispositionBijectionAtEverySignedBoundaryAndBothConfigurations() throws {
        let values: [Int64] = [.min, Int64(Int32.min) - 1, Int64(Int32.min), -22, -1, 0, 1, 22,
            Int64(Int32.max) - 1, Int64(Int32.max), Int64(Int32.max) + 1, .max]
        for configuration in H3QualificationConfiguration.allCases {
            let (inner, launched) = try H3QualificationExternalValidationTests.spawnSupportFixture(configuration)
            XCTAssertNoThrow(try H3QualificationWire.validate(launched, schema: "outer_receipt_v1"))
            for status in values {
                let absent = noChild(launched, spawn: status)
                if status > 0 && status <= Int64(Int32.max) {
                    XCTAssertNoThrow(try H3QualificationWire.validate(absent, schema: "outer_receipt_v1"), "SYNTHETIC no-child \(status)")
                    XCTAssertEqual(try H3QualificationPredicateEvaluator.evaluate(receipt: absent, inner: nil), ["runner.spawn"])
                    XCTAssertThrowsError(try H3QualificationPredicateEvaluator.evaluate(receipt: absent, inner: inner))
                } else {
                    XCTAssertThrowsError(try H3QualificationWire.validate(absent, schema: "outer_receipt_v1"))
                    XCTAssertThrowsError(try H3QualificationPredicateEvaluator.evaluate(receipt: absent, inner: nil))
                }
                let present = set(launched, ["spawn", "spawn_return"], .integer(status))
                if status == 0 { XCTAssertEqual(try H3QualificationPredicateEvaluator.evaluate(receipt: present, inner: inner), []) }
                else { XCTAssertThrowsError(try H3QualificationPredicateEvaluator.evaluate(receipt: present, inner: inner)) }
            }
        }
    }

    func testNoChildRejectsVariantEffectsDataAndClassificationSubstitution() throws {
        for guest in [false, true] {
            let (inner, launched) = try H3QualificationExternalValidationTests.spawnSupportFixture(.debug, guestMode: guest)
            let absent = noChild(launched)
            XCTAssertNoThrow(try H3QualificationWire.validate(absent, schema: "outer_receipt_v1"))
            let contradictions: [([String], V)] = [
                (["application"], launched["application"]!), (["child"], launched["child"]!),
                (["taxonomy", "app_launched"], .bool(true)), (["taxonomy", "signing_state"], .string("ADMITTED")),
                (["taxonomy", "signing_state"], .string("REJECTED")), (["taxonomy", "signing_state"], .string("API_ERROR")),
                (["taxonomy", "guest_entered_count"], .integer(1)), (["taxonomy", "hv_vm_created_count"], .integer(1)),
                (["evidence", "inner_valid"], .bool(true)), (["evidence", "inner_eof"], .bool(false)),
                (["evidence", "inner_byte_count"], .integer(1)), (["evidence", "inner_sha256"], .string(String(repeating: "f", count: 64))),
                (["evidence", "effective_hypervisor_value"], .string("TRUE")),
                (["evidence", "effective_entitlements_sha256"], launched["evidence"]!["effective_entitlements_sha256"]!),
                (["stderr", "eof"], .bool(false)), (["stderr", "total_byte_count"], .integer(1)),
                (["gate", "gate_writes"], .integer(1)), (["gate", "cancel_writes"], .integer(1)),
                (["kill", "attempted"], .bool(true)), (["kill", "pid"], .integer(124)),
                (["classification", "result"], .string("RETAINED_NONPASS")),
                (["classification", "result"], .string("RUN_CANDIDATE_PASS")),
                (["classification", "failed_predicates"], .array([])),
                (["classification", "failed_predicates"], .array([.string("runner.exit")]))
            ]
            for (path, changed) in contradictions {
                XCTAssertThrowsError(try H3QualificationWire.validate(set(absent, path, changed), schema: "outer_receipt_v1"), path.joined(separator: "."))
            }
            XCTAssertThrowsError(try H3QualificationWire.validate(set(launched, ["application"], absent["application"]!), schema: "outer_receipt_v1"))
            XCTAssertThrowsError(try H3QualificationWire.validate(set(launched, ["classification", "result"], .string("NO_CHILD_FAILURE")), schema: "outer_receipt_v1"))
            XCTAssertThrowsError(try H3QualificationPredicateEvaluator.evaluate(receipt: absent, inner: inner))
            for support in supports where support != "NOT_ENTERED" {
                XCTAssertThrowsError(try H3QualificationWire.validate(set(absent, ["evidence", "hypervisor_support"], .string(support)), schema: "outer_receipt_v1"))
            }
        }
    }

    func testAbsentOrInvalidDecodedInnerHasOnlyNotEnteredSupport() throws {
        let invalidFrames = [Data(), Data("SYNTHETIC invalid frame".utf8), Data("EPRH3I0100000001".utf8) + Data([0xff])]
        for guest in [false, true] {
            let (_, baseline) = try H3QualificationExternalValidationTests.spawnSupportFixture(.release, guestMode: guest)
            for bytes in invalidFrames {
                XCTAssertThrowsError(try H3QualificationProtocol.decodeFrame(bytes))
                var receipt = baseline
                for (path, replacement): ([String], V) in [
                    (["evidence", "inner_valid"], .bool(false)), (["evidence", "inner_byte_count"], .integer(Int64(bytes.count))),
                    (["evidence", "inner_sha256"], .string(H3QualificationProtocol.hash(bytes))),
                    (["evidence", "hypervisor_support"], .string("NOT_ENTERED")),
                    (["evidence", "effective_hypervisor_value"], .string("NOT_OBSERVED")),
                    (["evidence", "effective_entitlements_sha256"], .string(String(repeating: "0", count: 64))),
                    (["taxonomy", "signing_state"], .string("NOT_ENTERED")),
                    (["taxonomy", "guest_entered_count"], .integer(0)), (["taxonomy", "hv_vm_created_count"], .integer(0))
                ] { receipt = set(receipt, path, replacement) }
                receipt = try classify(receipt, inner: nil)
                XCTAssertEqual(try H3QualificationPredicateEvaluator.evaluate(receipt: receipt, inner: nil), ["runner.export", "runner.inner_frame"])
                XCTAssertNoThrow(try H3QualificationWire.validate(receipt, schema: "outer_receipt_v1"))
                for support in supports where support != "NOT_ENTERED" {
                    XCTAssertThrowsError(try H3QualificationPredicateEvaluator.evaluate(receipt:
                        set(receipt, ["evidence", "hypervisor_support"], .string(support)), inner: nil))
                }
                XCTAssertThrowsError(try H3QualificationPredicateEvaluator.evaluate(receipt:
                    set(receipt, ["evidence", "inner_valid"], .bool(true)), inner: nil))
            }
        }
    }

    func testValidGuestNotEnteredAndAllReturnedSupportPrefixesAreDerived() throws {
        let (guest, _) = try H3QualificationExternalValidationTests.spawnSupportFixture(.debug, guestMode: true)
        var preparation = set(guest, ["native"], .object(["disposition": .string("NOT_ENTERED"),
            "preparation_error": .integer(12), "reason": .string("PREPARATION_REJECTED")]))
        preparation = set(preparation, ["verifier"], try H3QualificationReplay.preparationPresentation(error: 12).wire)
        for key in ["guest_entered_count", "hv_vm_created_count", "reservation_entries", "reservation_release_entries"] {
            preparation = set(preparation, ["effects", key], .integer(0))
        }
        preparation = set(preparation, ["effects", "reservation_release_status"], .integer(Int64(Int32.min)))
        var cases: [(String, V)] = [("NOT_ENTERED", preparation)]
        let early = try XCTUnwrap(H3QualificationRunnerTests.applicationEarlyNativeCaptures().first { $0.0 == "SIGNING_REJECTED" }?.1)
        let captures: [(String, H3QualificationNativeCapture)] = [
            ("NOT_ENTERED", early), ("NATIVE_ENTRY_FAILED", H3QualificationRunnerTests.spawnSupportVMFailure()),
            ("NATIVE_ENTRY_SUCCEEDED", try H3QualificationRunnerTests.externalGuestCapture()),
            ("NATIVE_ENTRY_SUCCEEDED", try H3QualificationRunnerTests.externalGuestCapture(nonpass: true))]
        for (expected, capture) in captures {
            let replay = try H3QualificationReplay.replay(capture: capture)
            var inner = set(guest, ["native"], capture.wire)
            inner = set(inner, ["verifier"], replay.wire)
            inner = set(inner, ["effects", "lifecycle_disposition"], .string(replay.quarantined ? "QUARANTINED" : "RECOVERY_VOLATILE"))
            inner = set(inner, ["effects", "guest_entered_count"], .integer(["source", "target"].reduce(Int64(0)) { $0 + capture.wire[$1]!["run_entries"]!.intValue! }))
            inner = set(inner, ["effects", "hv_vm_created_count"], .integer(Int64(["source", "target"].filter { capture.wire[$0]?["vm_create_status"] == .integer(0) }.count)))
            cases.append((expected, inner))
        }
        for (expected, inner) in cases {
            XCTAssertNoThrow(try H3QualificationWire.validate(inner, schema: "inner_report_v1"))
            var receipt = try H3QualificationExternalValidationTests.spawnSupportReceipt(inner)
            receipt = set(receipt, ["evidence", "hypervisor_support"], .string(expected))
            receipt = try classify(receipt, inner: inner)
            XCTAssertNoThrow(try H3QualificationWire.validate(receipt, schema: "outer_receipt_v1"))
            XCTAssertNoThrow(try H3QualificationPredicateEvaluator.evaluate(receipt: receipt, inner: inner))
            for support in supports where support != expected {
                XCTAssertThrowsError(try H3QualificationPredicateEvaluator.evaluate(receipt:
                    set(receipt, ["evidence", "hypervisor_support"], .string(support)), inner: inner), "SYNTHETIC expected \(expected), got \(support)")
            }
        }
    }
}
#endif

#if EPR_H3_QUALIFICATION_TESTS
/// SYNTHETIC copied observations and inert callbacks. Signing, Process and
/// Storage effect owners are not compiled into or invoked by these tests.
/// Source review establishes their calls to the predicates exercised here.
final class H3QualificationPathIdentityTests: XCTestCase {
    private typealias P = H3QualificationPathIdentityPolicy
    private typealias V = H3QualificationJSONValue
    private typealias Snapshot = [String: Int64]
    private let snapshot: Snapshot = ["device": 1, "inode": 42, "generation": 0,
        "owner": 501, "group": 20, "mode": 0o100755, "links": 1, "size": 1024,
        "flags": 0, "modifiedSeconds": 10, "modifiedNanos": 11, "changedSeconds": 12, "changedNanos": 13]
    override func setUp() { super.setUp(); executionTimeAllowance = 10 }

    private func claims(_ configuration: H3QualificationConfiguration) throws -> (V, V) {
        let (_, outer) = try H3QualificationExternalValidationTests.spawnSupportFixture(configuration)
        return (outer["application"]!["pre_static"]!, outer["controller_claim"]!["code"]!)
    }
    private func changed(_ value: V, key: String) -> V {
        var fields = value.objectValue!
        switch fields[key]! {
        case .string(let text): fields[key] = .string(text + "SYNTHETIC_MUTATION")
        case .bool(let flag): fields[key] = .bool(!flag)
        default: fields[key] = .null
        }
        return .object(fields)
    }
    private func changed(_ value: Snapshot, key: String) -> Snapshot {
        var result = value; result[key]! += 1; return result
    }
    private func attemptGate(policy: inout H3QualificationControllerPolicy, expected: V, dynamic: V,
        original: Snapshot, held: Snapshot, named: Snapshot, processPath: String,
        immediate: H3QualificationControllerPolicy.WaitObservation = .live,
        beforeDeadline: Bool = true, callback: () -> Void) throws -> Bool {
        // Compose the actual production predicates at the existing observation
        // boundaries, not an invented model of Security/wait/descriptor effects.
        guard try P.dynamicCode(dynamic, expected: expected),
              P.preGate(original: original, held: held, named: named, processPath: processPath,
                        executablePath: expected["executable_path"]!.stringValue!) else { return false }
        guard policy.observe(immediate), policy.claimGate(immediateWait: immediate, beforeDeadline: beforeDeadline) else { return false }
        callback(); return true
    }
    private func terminal(_ code: V, original: Snapshot? = nil, heldGate: Snapshot? = nil,
        namedGate: Snapshot? = nil, heldTerminal: Snapshot? = nil, namedTerminal: Snapshot? = nil,
        preStatic: V? = nil, dynamic: V? = nil, postStatic: V? = nil, path: String? = nil) throws -> Bool {
        try P.terminal(original: original ?? snapshot, heldGate: heldGate ?? snapshot,
            namedGate: namedGate ?? snapshot, heldTerminal: heldTerminal ?? snapshot,
            namedTerminal: namedTerminal ?? snapshot, preStatic: preStatic ?? code,
            dynamic: dynamic ?? code, postStatic: postStatic ?? code,
            processPath: path ?? code["executable_path"]!.stringValue!,
            executablePath: code["executable_path"]!.stringValue!)
    }

    func testCodeObjectVersusMachOAndProcessPathRolesForBothProductsAndConfigurations() throws {
        for configuration in H3QualificationConfiguration.allCases {
            let (application, controller) = try claims(configuration)
            for code in [application, controller] {
                let object = code["code_object_path"]!.stringValue!, executable = code["executable_path"]!.stringValue!
                XCTAssertTrue(P.codeObjectPath(object, expected: object))
                XCTAssertTrue(P.executablePath(executable, expected: executable))
                let observedPaths: [String?] = [nil, "", "/", object + "/", executable + "/",
                    object + "\0", executable + "\n", object.uppercased(), executable.uppercased(),
                    object.replacingOccurrences(of: "/Build/", with: "/./Build/"),
                    executable.replacingOccurrences(of: "/Build/", with: "/../Build/")]
                for path in observedPaths {
                    XCTAssertFalse(P.codeObjectPath(path, expected: object))
                    XCTAssertFalse(P.executablePath(path, expected: executable))
                }
            }
            let bundle = application["code_object_path"]!.stringValue!, macho = application["executable_path"]!.stringValue!
            XCTAssertNotEqual(bundle, macho)
            XCTAssertFalse(P.codeObjectPath(macho, expected: bundle)) // executable-as-app-code-object
            XCTAssertFalse(P.executablePath(bundle, expected: macho)) // bundle-as-proc/main-executable
            XCTAssertFalse(P.preGate(original: snapshot, held: snapshot, named: snapshot, processPath: bundle, executablePath: macho))
            for collapsed in [bundle, macho] {
                XCTAssertFalse(P.codeObjectPath(collapsed, expected: bundle) && P.executablePath(collapsed, expected: macho))
            }
            let command = controller["executable_path"]!.stringValue!
            XCTAssertEqual(command, controller["code_object_path"]!.stringValue!)
            XCTAssertTrue(P.codeObjectPath(command, expected: command) && P.executablePath(command, expected: command))
            XCTAssertFalse(P.codeObjectPath(command, expected: bundle)); XCTAssertFalse(P.executablePath(command, expected: macho))
        }
    }

    func testEveryPreSpawnAndPreGateSnapshotAndDynamicCodeMismatchWithholdsGate() throws {
        for configuration in H3QualificationConfiguration.allCases {
            let (code, _) = try claims(configuration), path = code["executable_path"]!.stringValue!
            var good = H3QualificationControllerPolicy(), gateCallbacks = 0
            XCTAssertTrue(try attemptGate(policy: &good, expected: code, dynamic: code,
                original: snapshot, held: snapshot, named: snapshot, processPath: path) { gateCallbacks += 1 })
            XCTAssertFalse(try attemptGate(policy: &good, expected: code, dynamic: code,
                original: snapshot, held: snapshot, named: snapshot, processPath: path) { gateCallbacks += 1 })
            XCTAssertEqual(gateCallbacks, 1)
            for key in snapshot.keys.sorted() {
                let mutation = changed(snapshot, key: key)
                XCTAssertFalse(P.snapshot(mutation, matches: snapshot), "SYNTHETIC pre-spawn \(key)")
                XCTAssertFalse(P.pair(original: snapshot, held: mutation, named: snapshot))
                XCTAssertFalse(P.pair(original: snapshot, held: snapshot, named: mutation))
                for role in 0..<3 {
                    var policy = H3QualificationControllerPolicy(), callbacks = 0
                    XCTAssertFalse(try attemptGate(policy: &policy, expected: code, dynamic: code,
                        original: role == 0 ? mutation : snapshot, held: role == 1 ? mutation : snapshot,
                        named: role == 2 ? mutation : snapshot, processPath: path) { callbacks += 1 })
                    XCTAssertEqual(callbacks, 0); XCTAssertFalse(policy.gateAttempted); XCTAssertEqual(policy.ordinaryWaits, 0)
                }
            }
            for key in code.objectValue!.keys.sorted() {
                var policy = H3QualificationControllerPolicy(), callbacks = 0
                XCTAssertFalse(try attemptGate(policy: &policy, expected: code, dynamic: changed(code, key: key),
                    original: snapshot, held: snapshot, named: snapshot, processPath: path) { callbacks += 1 }, key)
                XCTAssertEqual(callbacks, 0); XCTAssertFalse(policy.gateAttempted); XCTAssertEqual(policy.ordinaryWaits, 0)
            }
            for path in [code["code_object_path"]!.stringValue!, path + "/", path + "\0"] {
                var policy = H3QualificationControllerPolicy(), callbacks = 0
                XCTAssertFalse(try attemptGate(policy: &policy, expected: code, dynamic: code,
                    original: snapshot, held: snapshot, named: snapshot, processPath: path) { callbacks += 1 })
                XCTAssertEqual(callbacks, 0); XCTAssertFalse(policy.gateAttempted)
            }
        }
    }

    func testEveryCopiedTerminalSnapshotCodeAndPathMismatchWithholdsReceipt() throws {
        let (code, _) = try claims(.debug), path = code["executable_path"]!.stringValue!
        var policy = H3QualificationControllerPolicy(), gateCallbacks = 0
        XCTAssertTrue(try attemptGate(policy: &policy, expected: code, dynamic: code,
            original: snapshot, held: snapshot, named: snapshot, processPath: path) { gateCallbacks += 1 })
        XCTAssertTrue(policy.observe(.reaped(0)))
        XCTAssertTrue(try terminal(code))
        for key in snapshot.keys.sorted() {
            let mutation = changed(snapshot, key: key)
            let outcomes = try [terminal(code, original: mutation), terminal(code, heldGate: mutation),
                terminal(code, namedGate: mutation), terminal(code, heldTerminal: mutation), terminal(code, namedTerminal: mutation)]
            for admitted in outcomes { var reports = 0; if admitted { reports += 1 }; XCTAssertEqual(reports, 0, key) }
        }
        for key in code.objectValue!.keys.sorted() {
            let mutation = changed(code, key: key)
            let outcomes = try [terminal(code, preStatic: mutation), terminal(code, dynamic: mutation), terminal(code, postStatic: mutation)]
            for admitted in outcomes { var reports = 0; if admitted { reports += 1 }; XCTAssertEqual(reports, 0, key) }
        }
        for path in [code["code_object_path"]!.stringValue!, path + "/", path + "\0"] { XCTAssertFalse(try terminal(code, path: path)) }
        var unicode = code.objectValue!
        unicode["designated_requirement"] = .string("SYNTHETIC \u{00c5}")
        var decomposed = unicode; decomposed["designated_requirement"] = .string("SYNTHETIC A\u{030a}")
        XCTAssertFalse(try P.dynamicCode(.object(decomposed), expected: .object(unicode)))
        XCTAssertFalse(try terminal(.object(unicode), dynamic: .object(decomposed)))
        XCTAssertFalse(try attemptGate(policy: &policy, expected: code, dynamic: code,
            original: snapshot, held: snapshot, named: snapshot, processPath: path) { gateCallbacks += 1 })
        XCTAssertEqual(gateCallbacks, 1); XCTAssertEqual(policy.terminalStatus, 0)
    }

    func testFreshWaitAndDeadlineStillOwnOneGateAndUnobservedRestoreRemainsAResidual() throws {
        let (code, _) = try claims(.release), path = code["executable_path"]!.stringValue!
        let waits: [H3QualificationControllerPolicy.WaitObservation] = [.live, .reaped(0),
            .terminalUncertain(0x137f), .interrupted, .failed(5)]
        for immediate in waits {
            for before in [false, true] {
                var policy = H3QualificationControllerPolicy(), callbacks = 0
                let admitted = try attemptGate(policy: &policy, expected: code, dynamic: code,
                    original: snapshot, held: snapshot, named: snapshot, processPath: path,
                    immediate: immediate, beforeDeadline: before) { callbacks += 1 }
                XCTAssertEqual(admitted, immediate == .live && before); XCTAssertEqual(callbacks, admitted ? 1 : 0)
            }
        }
        // Fabricated A -> B -> A interval. B is intentionally not supplied to
        // an observation predicate: sample equality cannot prove consumed vnode
        // identity or mutation prevention. An actually observed B is rejected.
        let unobservedReplacement = changed(snapshot, key: "inode")
        XCTAssertNotEqual(unobservedReplacement, snapshot)
        var policy = H3QualificationControllerPolicy(), gates = 0, reports = 0
        XCTAssertTrue(try attemptGate(policy: &policy, expected: code, dynamic: code,
            original: snapshot, held: snapshot, named: snapshot, processPath: path) { gates += 1 })
        XCTAssertTrue(policy.observe(.reaped(0)))
        if try terminal(code) { reports += 1 }
        XCTAssertEqual(gates, 1); XCTAssertEqual(reports, 1)
        XCTAssertFalse(try terminal(code, namedTerminal: unobservedReplacement))
        XCTAssertFalse(try attemptGate(policy: &policy, expected: code, dynamic: code,
            original: snapshot, held: snapshot, named: snapshot, processPath: path) { gates += 1 })
        XCTAssertEqual(gates, 1)
    }
}
#endif
