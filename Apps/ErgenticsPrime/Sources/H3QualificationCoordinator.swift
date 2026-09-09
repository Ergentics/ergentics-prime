#if EPR_H3_QUALIFICATION
import Darwin
import Foundation

/// One process-lifetime terminal primitive; the lock intentionally stays held
/// through the nonreturning exit. No callback can win a second terminal action.
final class H3QualificationTerminalOwner: @unchecked Sendable {
    private let lock = NSLock()
    private var state = H3QualificationTerminalStateMachine()

    func recordExport(_ outcome: H3QualificationTerminalStateMachine.ExportOutcome) {
        lock.lock()
        do { try state.recordExport(outcome) }
        catch { lock.unlock(); terminate(70) }
        lock.unlock()
    }

    func terminate(_ code: Int32) -> Never {
        lock.lock()
        let selected: Int32
        do { try state.claim(code); selected = code }
        catch { _ = try? state.claim(70); selected = 70 }
        Darwin._exit(selected)
    }
}


/// Sole lock domain for read-observation versus operation-completion. The
/// retained task is installed once; no lock is held across joining or routing.
final class H3QualificationCompletionBarrier: @unchecked Sendable {
    private let lock = NSLock()
    private var state = H3QualificationBarrierStateMachine()
    private var monitor: Task<H3QualificationMonitorEvidence, Never>?
    private let terminalOwner: H3QualificationTerminalOwner
    @MainActor private(set) var joinedMonitorEvidence: H3QualificationMonitorEvidence?

    init(terminalOwner: H3QualificationTerminalOwner) {
        self.terminalOwner = terminalOwner
        // One slot scoped to this retained barrier; no extra UUID or Task.
        // A detached monitor may run before install receives its real handle.
        do { try state.prepare(identity: 1) }
        catch { terminalOwner.terminate(70) }
    }

    func install(_ handle: Task<H3QualificationMonitorEvidence, Never>) {
        lock.lock()
        guard monitor == nil else { lock.unlock(); terminalOwner.terminate(70) }
        do { try state.install(identity: 1) }
        catch { lock.unlock(); terminalOwner.terminate(70) }
        monitor = handle
        lock.unlock()
    }

    private func snapshot() -> H3QualificationBarrierStateMachine.Winner? {
        lock.lock(); defer { lock.unlock() }
        return state.winner
    }

    private func latch() -> Bool {
        lock.lock(); defer { lock.unlock() }
        let first = state.winner == nil
        try? state.cancelForInternalFailure()
        return first
    }

    private func claim() -> (Bool, Task<H3QualificationMonitorEvidence, Never>) {
        lock.lock()
        guard let monitor else { lock.unlock(); terminalOwner.terminate(70) }
        let first: Bool
        do { first = try state.claimCompletion() == .completion }
        catch { lock.unlock(); terminalOwner.terminate(70) }
        lock.unlock()
        return (first, monitor)
    }

    private func finishJoin(_ joined: H3QualificationMonitorEvidence, completionFirst: Bool) {
        lock.lock()
        do { try state.join(identity: 1, fdClosed: joined.fdClosed, handleCanceled: completionFirst) }
        catch { lock.unlock(); terminalOwner.terminate(70) }
        lock.unlock()
    }

    @MainActor
    func claimCompletionAndStopMonitor() async -> H3QualificationCancellationDisposition {
        let (first, handle) = claim()
        if first { handle.cancel() }
        let observed = await handle.value
        let joined = H3QualificationMonitorEvidence(bytesObserved: observed.bytesObserved,
            pollCalls: observed.pollCalls, readCalls: observed.readCalls, routeCalls: observed.routeCalls,
            startedTick: observed.startedTick, terminalTick: observed.terminalTick,
            fdClosed: observed.fdClosed, taskJoined: true)
        do { try joined.validate(completionFirst: first) }
        catch { terminalOwner.terminate(70) }
        finishJoin(joined, completionFirst: first)
        joinedMonitorEvidence = joined
        return first ? .completionFirst(joined) : .cancellationFirst(joined)
    }

    func runMonitor(numerator: UInt32, denominator: UInt32,
                    lifecycle: AppLifecycleController) -> H3QualificationMonitorEvidence {
        let start = mach_continuous_time()
        var budget = try? H3QualificationInputStateMachine(role: .cancellation, startTick: start,
            numerator: numerator, denominator: denominator)
        var bytes = [UInt8](repeating: 0, count: 41)
        var item = pollfd(fd: 4, events: Int16(POLLIN | POLLHUP), revents: 0)
        lock.lock()
        if state.winner == nil {
            let flags = Darwin.fcntl(4, F_GETFL)
            if flags < 0 || flags & O_NONBLOCK == 0 || budget == nil { try? state.cancelForInternalFailure() }
        }
        lock.unlock()
        while snapshot() == nil {
            do { try budget!.beginPoll(at: mach_continuous_time()) }
            catch { _ = latch(); break }
            item.revents = 0
            let status = Darwin.poll(&item, 1, 10)
            let pollError = status < 0 ? errno : 0
            let outcome: H3QualificationInputStateMachine.PollResult
            if status < 0 && pollError == EINTR { outcome = .interrupted }
            else if status < 0 || item.revents & Int16(POLLERR | POLLNVAL) != 0 { outcome = .failed }
            else if status == 0 { outcome = .timeout }
            else if status == 1 && item.revents & Int16(POLLIN | POLLHUP) != 0 { outcome = .ready }
            else { outcome = .failed }
            do { try budget!.finishPoll(outcome, at: mach_continuous_time()) }
            catch { _ = latch(); break }
            while budget!.phase == .readable {
                // Clock sampling is outside the shared lock. Read admission,
                // returned bytes/EOF/error, and the winning latch are inside it.
                let readTick = mach_continuous_time()
                lock.lock()
                do {
                    guard try state.beginRead() else { lock.unlock(); break }
                } catch { lock.unlock(); _ = latch(); break }
                do { try budget!.beginRead(at: readTick, requested: bytes.count) }
                catch { try? state.finishRead(cancellationObserved: true); lock.unlock(); break }
                let count = bytes.withUnsafeMutableBytes { Darwin.read(4, $0.baseAddress!, $0.count) }
                let readError = count < 0 ? errno : 0
                let observation: H3QualificationInputStateMachine.ReadResult
                if count > 0 { observation = .bytes(count) }
                else if count == 0 { observation = .eof }
                else if count == -1 && readError == EINTR { observation = .interrupted }
                else if count == -1 && readError == EAGAIN { observation = .again }
                else { observation = .failed }
                do {
                    try budget!.finishRead(observation)
                    try state.finishRead(cancellationObserved: budget!.phase == .cancellationObserved)
                } catch { try? state.finishRead(cancellationObserved: true) }
                lock.unlock()
            }
        }
        let closed = Darwin.close(4) == 0
        let canceled = snapshot() == .cancellation
        if canceled {
            lock.lock()
            do { try state.routeCancellation() }
            catch { lock.unlock(); terminalOwner.terminate(70) }
            lock.unlock()
        }
        if canceled, lifecycle.requestQuit() { terminalOwner.terminate(70) }
        return H3QualificationMonitorEvidence(bytesObserved: UInt32(budget?.offset ?? 0),
            pollCalls: budget?.pollCalls ?? 0, readCalls: budget?.readCalls ?? 0,
            routeCalls: canceled ? 1 : 0, startedTick: start, terminalTick: mach_continuous_time(),
            fdClosed: closed, taskJoined: false)
    }
}

@MainActor
final class H3QualificationCoordinator {
    private let terminalOwner: H3QualificationTerminalOwner
    private let mode: H3QualificationMode
    private let nonce: String
    private let model: ProvenanceModel
    private let lab: HypervisorModel
    private var startup = H3QualificationStartupStateMachine()
    private var events: H3QualificationApplicationEventStateMachine

    init(terminalOwner: H3QualificationTerminalOwner, mode: DevelopmentLaunch.Mode,
         model: ProvenanceModel, lab: HypervisorModel, events: H3QualificationApplicationEventStateMachine) {
        self.terminalOwner = terminalOwner
        switch mode {
        case .h3QualificationAdmission(let nonce): self.mode = .admissionOnly; self.nonce = nonce
        case .h3QualificationGuest(let nonce): self.mode = .guest; self.nonce = nonce
        default: terminalOwner.terminate(70)
        }
        self.model = model
        self.lab = lab
        self.events = events
        self.events.identity(.owner, value: UInt64(UInt(bitPattern: ObjectIdentifier(terminalOwner))))
        self.events.identity(.model, value: UInt64(UInt(bitPattern: ObjectIdentifier(model))))
        self.events.identity(.lab, value: UInt64(UInt(bitPattern: ObjectIdentifier(lab))))
        self.events.identity(.coordinator, value: UInt64(UInt(bitPattern: ObjectIdentifier(self))))
        self.events.record(.coordinator)
    }

    private struct Gate {
        let start: UInt64
        let validated: UInt64
        let numerator: UInt32
        let denominator: UInt32
        let sha256: String
    }

    /// No nested task or native admission precedes this fixed-buffer FD-3 gate.
    private func readGate() throws -> Gate {
        let start = mach_continuous_time()
        var timebase = mach_timebase_info_data_t()
        var closed = false
        defer { if !closed { _ = Darwin.close(3) } }
        events.record(.gateTimebase)
        guard mach_timebase_info(&timebase) == KERN_SUCCESS else { throw H3QualificationFailure.invariant("gate timebase") }
        var budget = try H3QualificationInputStateMachine(role: .gate, startTick: start,
            numerator: timebase.numer, denominator: timebase.denom)
        let flags = Darwin.fcntl(3, F_GETFL)
        guard flags >= 0, flags & O_NONBLOCK != 0 else { throw H3QualificationFailure.invariant("gate descriptor") }
        var bytes = [UInt8](repeating: 0, count: 42)
        var item = pollfd(fd: 3, events: Int16(POLLIN | POLLHUP), revents: 0)
        while budget.phase != .gateEOF {
            if budget.phase == .pollable {
                try budget.beginPoll(at: mach_continuous_time())
                item.revents = 0
                let status = Darwin.poll(&item, 1, 10)
                let code = status < 0 ? errno : 0
                let outcome: H3QualificationInputStateMachine.PollResult
                if status < 0 && code == EINTR { outcome = .interrupted }
                else if status < 0 || item.revents & Int16(POLLERR | POLLNVAL) != 0 { outcome = .failed }
                else if status == 0 { outcome = .timeout }
                else if status == 1 && item.revents & Int16(POLLIN | POLLHUP) != 0 { outcome = .ready }
                else { outcome = .failed }
                try budget.finishPoll(outcome, at: mach_continuous_time())
            }
            if budget.phase != .readable { continue }
            let requested = bytes.count - budget.offset
            let offset = budget.offset
            try budget.beginRead(at: mach_continuous_time(), requested: requested)
            let count = bytes.withUnsafeMutableBytes { Darwin.read(3, $0.baseAddress!.advanced(by: offset), requested) }
            let code = count < 0 ? errno : 0
            let observation: H3QualificationInputStateMachine.ReadResult
            if count > 0 { observation = .bytes(count) }
            else if count == 0 { observation = .eof }
            else if count == -1 && code == EINTR { observation = .interrupted }
            else if count == -1 && code == EAGAIN { observation = .again }
            else { observation = .failed }
            try budget.finishRead(observation)
        }
        let frame = Data(bytes.prefix(budget.offset))
        try H3QualificationGateIdentity.validate(frame, mode: mode, nonce: nonce)
        closed = true
        guard Darwin.close(3) == 0 else { throw H3QualificationFailure.invariant("gate close") }
        let validated = mach_continuous_time()
        try budget.observeClock(validated)
        return Gate(start: start, validated: validated, numerator: timebase.numer, denominator: timebase.denom,
            sha256: H3QualificationProtocol.hash(frame))
    }

    func run() async {
        do { try startup.activate() }
        catch { terminalOwner.terminate(70) }
        events.record(.startup)
        let gate: Gate
        do { gate = try readGate() }
        catch { terminalOwner.terminate(70) }
        events.gate(numerator: gate.numerator, denominator: gate.denominator)
        let lifecycle: AppLifecycleController
        events.record(.lifecycleInstall)
        do { lifecycle = try lab.installQualificationLifecycle(timebaseNumerator: gate.numerator,
            timebaseDenominator: gate.denominator, terminalOwner: terminalOwner) }
        catch { _ = Darwin.close(4); terminalOwner.terminate(70) }
        events.lifecycle(owner: UInt64(UInt(bitPattern: ObjectIdentifier(terminalOwner))),
            stored: UInt64(UInt(bitPattern: ObjectIdentifier(lab.lifecycle))),
            returned: UInt64(UInt(bitPattern: ObjectIdentifier(lifecycle))),
            numerator: gate.numerator, denominator: gate.denominator)
        let exporter: DevelopmentRustBootExport
        events.record(.exporterAdmission)
        do { exporter = try DevelopmentRustBootExport.admitH3QualificationStandardOutput() }
        catch { _ = Darwin.close(4); terminalOwner.terminate(70) }
        events.record(.exporterInstance)
        let barrier = H3QualificationCompletionBarrier(terminalOwner: terminalOwner)
        events.record(.barrierInstance)
        events.record(.monitorTask)
        let handle = Task.detached { [barrier, lifecycle, numerator = gate.numerator, denominator = gate.denominator] in
            barrier.runMonitor(numerator: numerator, denominator: denominator, lifecycle: lifecycle)
        }
        barrier.install(handle)
        events.identity(.monitor, value: UInt64(UInt(bitPattern: ObjectIdentifier(barrier))))
        events.record(.monitorInstalled)
        events.record(.signingInspection)
        let inspection = await model.inspectHost(queryHypervisor: false)
        events.signing(inspection)
        let completion: H3QualificationH3Completion?
        let disposition: H3QualificationCancellationDisposition
        if case .assessed(_, _, .admitted, nil) = inspection, mode == .guest {
            completion = await lab.runH3CursorResumeQualification(admitted: true, completionBarrier: barrier)
            if let workerEvents = lab.qualificationEventSnapshot { events.mergeWorker(workerEvents) }
            guard let joined = barrier.joinedMonitorEvidence else { terminalOwner.terminate(70) }
            disposition = .completionFirst(joined)
        } else {
            completion = nil
            disposition = await barrier.claimCompletionAndStopMonitor()
        }
        guard case .completionFirst(let monitor) = disposition else { terminalOwner.terminate(70) }
        events.joinedMonitor(monitor, completionFirst: true)
        // A trace fault cannot escape reservation or monitor cleanup. It is
        // considered only after the same existing completion path has settled.
        guard events.reportPrerequisites else { terminalOwner.terminate(70) }
        let frame: Data
        do {
            let report = try makeReport(gate: gate, inspection: inspection, completion: completion, monitor: monitor)
            try H3QualificationWire.validate(report, schema: "inner_report_v1")
            frame = try H3QualificationProtocol.frame(payload: report)
        } catch { terminalOwner.terminate(70) }
        events.record(.frame)
        events.record(.exportAttempt)
        guard !events.failed else { terminalOwner.terminate(70) }
        do {
            _ = try exporter.exportH3Qualification(frame: frame)
            terminalOwner.recordExport(.succeeded)
            events.record(.exportOutcome)
            events.record(.terminalRequest)
            guard !events.failed else { terminalOwner.terminate(70) }
            terminalOwner.terminate(0)
        } catch {
            let message = Array("H3 qualification export failed\n".utf8)
            _ = message.withUnsafeBytes { Darwin.write(2, $0.baseAddress!, $0.count) }
            terminalOwner.recordExport(.failed)
            events.record(.exportOutcome)
            events.record(.terminalRequest)
            guard !events.failed else { terminalOwner.terminate(70) }
            terminalOwner.terminate(74)
        }
    }

    private func makeReport(gate: Gate, inspection: ProvenanceHostInspectionResult,
                            completion: H3QualificationH3Completion?, monitor: H3QualificationMonitorEvidence) throws -> H3QualificationJSONValue {
        typealias V = H3QualificationJSONValue
        guard case .assessed(let nativeResult, let nativeError, let signingStatus, nil) = inspection else {
            throw H3QualificationFailure.invariant("unassessed signing")
        }
        let configuration: H3QualificationConfiguration
        #if DEBUG
        configuration = .debug
        #else
        configuration = .release
        #endif
        let environmentNames = ProcessInfo.processInfo.environment.keys.sorted { $0.utf8.lexicographicallyPrecedes($1.utf8) }
        guard environmentNames == ["APP_SANDBOX_CONTAINER_ID", "CFFIXED_USER_HOME", "HOME", "TMPDIR", "__CF_USER_TEXT_ENCODING"] else {
            throw H3QualificationFailure.invariant("framework environment")
        }
        var signing: [String: V] = ["admitted": .bool(signingStatus == .admitted), "native_result": .integer(Int64(nativeResult)),
            "error": .integer(Int64(nativeError)), "status": .string(signingStatus.rawValue)]
        if signingStatus == .admitted {
            signing["effective_entitlements"] = .object(["com.apple.security.app-sandbox": .bool(true),
                "com.apple.security.files.user-selected.read-only": .bool(true), "com.apple.security.hypervisor": .bool(true)])
            signing["effective_entitlements_sha256"] = .string("f754d498901c39fbbc8f6a5cfb35cf5661174a201d24c6c37a22a3f50708336b")
        }
        var native: V = .object(["disposition": .string("NOT_ENTERED"), "preparation_error": .integer(Int64(Int32.min)),
            "reason": .string(mode == .admissionOnly && signingStatus == .admitted ? "ADMISSION_MODE" : "SIGNING_REJECTED")])
        var verifier: V = mode == .admissionOnly ? .object(["disposition": .string("NOT_ENTERED")]) :
            H3QualificationReplay.signingRejectedPresentation().wire
        var entries: UInt32 = 0, releases: UInt32 = 0
        var releaseStatus: Int32 = .min
        var lifecycle = H3QualificationLifecycleDisposition.notEntered
        if let completion {
            switch completion {
            case .preparationRejected(let error, let acquired, let released, let status, let presentation, let passed):
                native = .object(["disposition": .string("NOT_ENTERED"), "reason": .string("PREPARATION_REJECTED"),
                    "preparation_error": .integer(Int64(error))])
                verifier = presentation.wire; entries = acquired; releases = released; releaseStatus = status; lifecycle = passed
            case .nativeReturned(let capture, let presentation, let acquired, let released, let status, let passed):
                native = capture.wire; verifier = presentation.wire
                entries = acquired; releases = released; releaseStatus = status; lifecycle = passed
            default: throw H3QualificationFailure.invariant("nonreporting H3 completion")
            }
        } else if mode == .guest, signingStatus == .admitted {
            throw H3QualificationFailure.invariant("missing H3 completion")
        }
        // This projection is the one already admitted by worker replay, not a
        // second verifier or another native observation.
        let assessment = lab.qualificationEventSnapshot?.native
        let guestCount = Int64(assessment?.guestEntries ?? 0)
        let vmCount = Int64(assessment?.vmCreates ?? 0)
        let end = mach_continuous_time()
        guard end >= gate.validated else { throw H3QualificationFailure.invariant("report clock") }
        return .object([
            "schema": .string("com.ergentics.provenance.h3-qualification-inner.v1"), "version": .integer(1),
            "run": .object(["mode": .string(mode.rawValue), "configuration": .string(configuration.rawValue),
                "nonce": .string(nonce), "run_id": .string(try H3QualificationProtocol.runID(mode: mode, configuration: configuration, nonce: nonce))]),
            "authority": .object(["authority_effect": .string("NONE"), "authority_vector": .string("00000000"),
                "gate_e": .string("ABSTAIN"), "h4_entered": .bool(false), "prime_git_entered": .bool(false), "sqlite_opened": .bool(false)]),
            "build": .object(["configuration": .string(configuration.rawValue), "guest_abi_version": .integer(5),
                "guest_image_byte_count": .integer(136), "guest_image_sha256": .string(H3QualificationProtocol.imageSHA256),
                "guest_profile_id": .string("H3_CURSOR_RESUME"), "qualification_variant": .bool(true)]),
            "process": .object(["bundle_identifier": .string("com.ergentics.provenance"), "team_identifier": .string("ZCQ435U8JP"),
                "pid": .integer(Int64(getpid())), "environment_count": .integer(Int64(environmentNames.count)),
                "environment_names": .array(environmentNames.map { .string($0) }),
                "environment_observation": .string("OBSERVED_AFTER_FRAMEWORK_START_FROM_EMPTY_ENVP_ORIGIN_UNATTRIBUTED")]),
            "effects": .object(["app_launched": .bool(true), "guest_entered_count": .integer(guestCount), "helper_processes": .integer(0),
                "hv_vm_created_count": .integer(Int64(vmCount)), "lifecycle_disposition": .string(lifecycle.rawValue),
                "prime_git_entries": .integer(0), "reservation_entries": .integer(Int64(entries)),
                "reservation_release_entries": .integer(Int64(releases)), "reservation_release_status": .integer(Int64(releaseStatus)),
                "runner_location": .string("EVALUATED_MAC_EXTERNAL_CONTROLLER"), "signals_observed_before_report": .integer(0),
                "signing_state": .string(signingStatus.rawValue), "storage_entries": .integer(0),
                "subject_location": .string("EVALUATED_MAC_SIGNED_PRODUCT_APPLICATION")]),
            "gate": .object(["accepted": .bool(true), "frame_sha256": .string(gate.sha256),
                "mode_byte": .string(mode == .admissionOnly ? "01" : "02"), "validated_tick": .string(String(gate.validated))]),
            "timing": .object(["continuous_start_tick": .string(String(gate.start)), "continuous_end_tick": .string(String(end)),
                "timebase_numerator": .integer(Int64(gate.numerator)), "timebase_denominator": .integer(Int64(gate.denominator))]),
            "native": native, "verifier": verifier, "signing": .object(signing), "cancellation_monitor": monitor.wire
        ])
    }
}
#endif
