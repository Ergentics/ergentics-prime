import AppKit
import Combine
import Foundation

struct GuestEventDisplay: Identifiable, Sendable {
    let id: Int
    let kind: String
    let digest: String
    let byteCount: Int
}

struct GuestPresentation: Identifiable, Sendable {
    let id: String
    let status: String
    let detail: String
    let root: String
    let elapsed: String
    let events: [GuestEventDisplay]
    let quarantined: Bool
    var volatileObservation: Data? = nil
}

@MainActor
final class HypervisorModel: ObservableObject {
    @Published private(set) var busy = false
    @Published private(set) var phase = "Ready for an explicit development run"
    @Published private(set) var result: GuestPresentation?
    @Published private(set) var recent: [GuestPresentation] = []
    @Published private(set) var error: String?
    @Published private(set) var quarantined = false
    private var startupHandled = false
    private var cancelPending = false

    var journalURL: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("ErgenticsProvenance/HypervisorLab/guest-events.sqlite3")
    }

    func startup(admitted: Bool) {
        guard !startupHandled else { return }
        startupHandled = true
        guard admitted else { return }
        refresh()
        #if DEBUG
        // A closed development launch convenience, not a request/command loader.
        // It enters the same fixed operation as the visible button, once per launch.
        if Array(CommandLine.arguments.dropFirst()) == ["--run-fixed-guest-once"] {
            run(admitted: admitted)
        }
        #endif
    }

    func run(admitted: Bool) {
        guard admitted, !busy, !quarantined, !cancelPending else { return }
        busy = true; error = nil; cancelPending = false
        phase = "Preparing durable start → fixed guest → snapshot → teardown → read-back"
        let destination = journalURL
        let runID = UUID().uuidString.lowercased()
        // The complete synchronous native call is confined to this one OS thread.
        Thread.detachNewThread { [weak self] in
            let presentation: GuestPresentation
            do { presentation = try Self.execute(runID: runID, destination: destination) }
            catch {
                presentation = GuestPresentation(id: runID, status: "INCOMPLETE",
                    detail: "\(error). Inspect the retained journal prefix; no automatic rerun.",
                    root: "", elapsed: "", events: [], quarantined: true)
            }
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.busy = false
                self.result = presentation
                self.quarantined = presentation.quarantined
                self.phase = presentation.status
                if presentation.status != "PASS" { self.error = presentation.detail }
                self.refresh()
            }
        }
    }

    func cancel() {
        guard busy, !cancelPending else { return }
        cancelPending = true
        phase = "Requesting cancellation; the owner still must return and tear down"
        Thread.detachNewThread { [weak self] in
            let accepted = epr_guest_cancel()
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.cancelPending = false
                guard self.busy else { return }
                self.phase = accepted == 1 ? "Cancellation requested; waiting for owner exit and teardown" :
                    "No cancellable vCPU currently published; waiting for the operation"
            }
        }
    }

    func refresh() {
        // Do not open/close a second journal instance while the owner is
        // transacting: closing any same-process FD can affect POSIX locks.
        guard !busy else { return }
        let destination = journalURL
        guard FileManager.default.fileExists(atPath: destination.path) else { return }
        do {
            let journal = try GuestJournal(url: destination)
            recent = try journal.runIDs().map { runID in
                try Self.present(runID: runID, events: journal.events(runID: runID))
            }
        } catch { self.error = "Journal read-back rejected: \(error)" }
    }

    nonisolated private static func execute(runID: String, destination: URL) throws -> GuestPresentation {
        let directory = destination.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true,
                                                attributes: [.posixPermissions: 0o700])
        let journal = try GuestJournal(url: destination)
        guard let imagePointer = epr_guest_image_bytes() else { throw ProvenanceFailure("No fixed guest image") }
        let image = Data(bytes: imagePointer, count: epr_guest_image_size())
        guard GuestContract.hash(image) == GuestContract.expectedGuestSHA256 else {
            throw ProvenanceFailure("Guest image is not sealed to its reviewed assembly")
        }
        _ = try journal.append(runID: runID, kind: "start", payload: [
            "guest_image": .bytes(image), "guest_sha256": .text(GuestContract.hash(image)),
            "request": .bytes(GuestContract.request), "expected_reply": .bytes(GuestContract.reply),
            "load_ipa": .unsigned(epr_guest_image_load_address()),
            "doorbell_instruction_offset": .unsigned(epr_guest_doorbell_instruction_offset()),
            "host_bundle": .text("com.ergentics.provenance"),
            "host_version": .text(ProcessInfo.processInfo.operatingSystemVersionString),
            "utc": .text(ISO8601DateFormatter().string(from: Date())),
            "scope": .text("local development transport, not DeltaPU acceleration or Gate E")
        ])
        let startReadback = try journal.events(runID: runID)
        guard startReadback.count == 1, startReadback[0].kind == "start" else {
            throw ProvenanceFailure("Committed start read-back failed before guest entry")
        }
        var raw = epr_guest_run()
        let request = withUnsafeBytes(of: &raw.request) { Data($0) }
        let reply = withUnsafeBytes(of: &raw.reply) { Data($0) }
        let rootBytes = withUnsafeBytes(of: &raw.snapshot_merkle) { Data($0) }
        let root = rootBytes.map { String(format: "%02x", $0) }.joined()
        let independentPass = try raw.snapshot_sealed == 1 &&
            GuestContract.validateSnapshot(image: image, request: request, reply: reply, expectedRoot: root)
        var fields = nativeFields(raw)
        fields["request"] = .bytes(request); fields["reply"] = .bytes(reply)
        fields["guest_sha256"] = .text(GuestContract.hash(image))
        fields["snapshot_merkle"] = .bytes(rootBytes)
        fields["independent_snapshot_pass"] = .bool(independentPass)
        fields["seal_scope"] = .text("volatile before teardown; durable only on this host transaction")
        let recovery = try GuestCBOR.encode(.map(fields))
        do {
        _ = try journal.append(runID: runID, kind: "observation", payload: fields)
        let passed = raw.outcome == EPR_GUEST_PASS && raw.execution_pass == 1 &&
            raw.teardown_pass == 1 && independentPass
        let status = passed ? "PASS" : (raw.outcome == EPR_GUEST_CANCELED ? "CANCELED" : "FAIL")
        let stage = String(cString: epr_guest_stage_name(raw.failure_stage))
        _ = try journal.append(runID: runID, kind: "terminal", payload: [
            "status": .text(status), "execution_pass": .bool(raw.execution_pass == 1),
            "teardown_pass": .bool(raw.teardown_pass == 1),
            "independent_snapshot_pass": .bool(independentPass),
            "resources_quarantined": .bool(raw.resources_quarantined == 1),
            "snapshot_merkle": .text(raw.snapshot_sealed == 1 ? root : ""),
            "detail": .text(passed ? "One fixed guest entry; 19 + 23 = 42; exact doorbell, independent snapshot and teardown verified." :
                "Native stage \(stage), error \(raw.first_error); execution and teardown remain separate observations."),
            "elapsed": .text("\(raw.end_ticks >= raw.start_ticks ? raw.end_ticks - raw.start_ticks : 0) ticks × \(raw.timebase_numer)/\(raw.timebase_denom) ns"),
            "energy": .text("unmeasured; ergs unavailable"),
            "gate_e": .text("ABSTAIN"), "authority_vector": .text("00000000")
        ])
        return try present(runID: runID, events: journal.events(runID: runID))
        } catch {
            // Keep the complete native observation in memory even when durable
            // publication or its verification fails. Never turn that failure
            // into native FAIL, a successful teardown, or permission to rerun.
            return GuestPresentation(id: runID, status: "INCOMPLETE",
                detail: "Persistence/read-back failed: \(error). Native execution=\(raw.execution_pass), teardown=\(raw.teardown_pass), quarantined=\(raw.resources_quarantined). Raw CBOR remains in this window; the retained database prefix is not rewritten.",
                root: raw.snapshot_sealed == 1 ? root : "", elapsed: "", events: [], quarantined: true,
                volatileObservation: recovery)
        }
    }

    nonisolated private static func nativeFields(_ r: EPRGuestResult) -> [String: GuestCBORValue] {
        var values: [String: GuestCBORValue] = [:]
        let flags: [(String, UInt32)] = [
            ("abi_version", r.abi_version), ("outcome", r.outcome), ("execution_pass", r.execution_pass),
            ("teardown_pass", r.teardown_pass), ("signing_admitted", r.signing_admitted),
            ("run_entries", r.run_entries), ("vcpu_created", r.vcpu_created), ("mappings_entered", r.mappings_entered),
            ("register_calls", r.register_calls), ("read_register_calls", r.read_register_calls),
            ("cancellation_requested", r.cancellation_requested), ("cancellation_calls", r.cancellation_calls),
            ("watchdog_fired", r.watchdog_fired), ("resources_quarantined", r.resources_quarantined),
            ("request_unchanged", r.request_unchanged), ("reply_valid", r.reply_valid),
            ("code_unchanged", r.code_unchanged), ("trap_valid", r.trap_valid),
            ("exception_reason", r.exception_reason), ("timebase_numer", r.timebase_numer),
            ("timebase_denom", r.timebase_denom), ("snapshot_sealed", r.snapshot_sealed)]
        for (key, value) in flags { values[key] = .unsigned(UInt64(value)) }
        let words: [(String, UInt64)] = [
            ("start_ticks", r.start_ticks), ("entry_ticks", r.entry_ticks), ("exit_ticks", r.exit_ticks),
            ("snapshot_ticks", r.snapshot_ticks), ("end_ticks", r.end_ticks), ("deadline_ticks", r.deadline_ticks),
            ("syndrome", r.syndrome), ("pc", r.pc), ("fault_ipa", r.fault_ipa),
            ("fault_virtual_address", r.fault_virtual_address), ("x4", r.x4),
            ("sctlr_el1", r.sctlr_el1), ("cpsr", r.cpsr)]
        for (key, value) in words { values[key] = .unsigned(value) }
        let statuses: [(String, Int32)] = [
            ("failure_stage", r.failure_stage), ("first_error", r.first_error), ("signing_error", r.signing_error),
            ("vm_create", r.vm_create_status), ("vcpu_create", r.vcpu_create_status),
            ("register", r.register_status), ("run", r.run_status), ("read_register", r.read_register_status),
            ("vcpu_destroy", r.vcpu_destroy_status), ("vm_destroy", r.vm_destroy_status),
            ("cancellation", r.cancellation_status), ("watchdog_create", r.watchdog_create_status),
            ("watchdog_join", r.watchdog_join_status), ("map_code", r.map_status.0),
            ("watchdog_wait", r.watchdog_wait_status),
            ("host_unmap_code", r.host_unmap_status.0), ("host_unmap_request", r.host_unmap_status.1),
            ("host_unmap_reply", r.host_unmap_status.2),
            ("map_request", r.map_status.1), ("map_reply", r.map_status.2),
            ("unmap_code", r.unmap_status.0), ("unmap_request", r.unmap_status.1), ("unmap_reply", r.unmap_status.2)]
        // Decimal strings preserve signed native status values, including the
        // INT32_MIN not-entered sentinel, without changing the unsigned CBOR profile.
        values["native_status_decimal"] = .map(Dictionary(uniqueKeysWithValues:
            statuses.map { ($0.0, .text(String($0.1))) }))
        return values
    }

    nonisolated private static func present(runID: String, events: [GuestJournalEvent]) throws -> GuestPresentation {
        let verified = try GuestResultVerifier.verify(runID: runID, events: events)
        return GuestPresentation(id: runID, status: verified.status, detail: verified.detail, root: verified.root, elapsed: verified.elapsed,
            events: events.map { GuestEventDisplay(id: $0.sequence, kind: $0.kind, digest: $0.digest, byteCount: $0.payload.count) },
            quarantined: verified.quarantined)
    }
}
