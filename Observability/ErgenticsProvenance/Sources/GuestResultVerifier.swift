import Foundation

struct VerifiedGuestResult {
    let status: String
    let detail: String
    let root: String
    let elapsed: String
    let quarantined: Bool
}

enum GuestResultVerifier {
    // Journal verifies canonical envelope bytes and ancestry. This separately
    // reconstructs the semantic result; a terminal's prose cannot grant PASS.
    static func verify(runID: String, events: [GuestJournalEvent]) throws -> VerifiedGuestResult {
        let expectedKinds = ["start", "observation", "terminal"]
        guard !events.isEmpty, events.count <= 3 else { throw ProvenanceFailure("Unexpected guest event count") }
        var payloads: [[String: GuestCBORValue]] = []
        for (index, event) in events.enumerated() {
            let parent = index == 0 ? nil : events[index - 1].digest
            let parentBytes = parent.map { value in
                Data(stride(from: 0, to: value.count, by: 2).compactMap { position in
                    let start = value.index(value.startIndex, offsetBy: position)
                    let end = value.index(start, offsetBy: 2, limitedBy: value.endIndex) ?? value.endIndex
                    return UInt8(value[start..<end], radix: 16)
                })
            } ?? Data()
            guard event.runID == runID, event.sequence == index, event.kind == expectedKinds[index],
                  event.parent == parent, GuestContract.hash(event.payload) == event.digest,
                  case .map(let envelope) = try GuestCBOR.decode(event.payload),
                  Set(envelope.keys) == Set(["schema", "run_id", "sequence", "kind", "parent", "payload"]),
                  envelope["schema"] == .text(GuestJournal.schema), envelope["run_id"] == .text(runID),
                  envelope["sequence"] == .unsigned(UInt64(index)), envelope["kind"] == .text(event.kind),
                  envelope["parent"] == .bytes(parentBytes),
                  case .map(let payload) = envelope["payload"] else {
                throw ProvenanceFailure("Guest event order or projection rejected")
            }
            payloads.append(payload)
        }
        guard events.count == 3 else {
            return VerifiedGuestResult(status: "INCOMPLETE", detail: "Retained prefix without a verified terminal",
                root: "", elapsed: "", quarantined: false)
        }
        let start = payloads[0], observation = payloads[1], terminal = payloads[2]
        func text(_ p: [String: GuestCBORValue], _ key: String) -> String {
            if case .text(let value) = p[key] { return value }; return ""
        }
        func uint(_ key: String) -> UInt64? {
            if case .unsigned(let value) = observation[key] { return value }; return nil
        }
        func flag(_ p: [String: GuestCBORValue], _ key: String) -> Bool? {
            if case .bool(let value) = p[key] { return value }; return nil
        }
        let label = text(terminal, "status")
        guard ["PASS", "FAIL", "CANCELED"].contains(label),
              (label == "CANCELED") == (uint("outcome") == 3),
              label != "CANCELED" || uint("cancellation_requested") == 1,
              terminal["gate_e"] == .text("ABSTAIN"), terminal["authority_vector"] == .text("00000000"),
              flag(terminal, "execution_pass") == (uint("execution_pass") == 1),
              flag(terminal, "teardown_pass") == (uint("teardown_pass") == 1),
              flag(terminal, "resources_quarantined") == (uint("resources_quarantined") == 1),
              flag(terminal, "independent_snapshot_pass") == flag(observation, "independent_snapshot_pass") else {
            throw ProvenanceFailure("Guest terminal does not join its observation")
        }
        let root = text(terminal, "snapshot_merkle")
        var snapshotValid = false
        if case .bytes(let image) = start["guest_image"],
           case .bytes(let request) = observation["request"],
           case .bytes(let reply) = observation["reply"],
           case .bytes(let rootBytes) = observation["snapshot_merkle"] {
            let observedRoot = rootBytes.map { String(format: "%02x", $0) }.joined()
            snapshotValid = try GuestContract.validateSnapshot(image: image, request: request,
                reply: reply, expectedRoot: observedRoot)
            guard root == (uint("snapshot_sealed") == 1 ? observedRoot : "") else {
                throw ProvenanceFailure("Terminal Merkle root differs from its snapshot")
            }
        }
        if flag(observation, "independent_snapshot_pass") == true && !snapshotValid {
            throw ProvenanceFailure("Stored snapshot assertion fails independent reconstruction")
        }
        var nativePass = true
        for key in ["abi_version", "outcome", "execution_pass", "teardown_pass", "signing_admitted",
                    "run_entries", "vcpu_created", "request_unchanged", "reply_valid", "code_unchanged",
                    "trap_valid", "snapshot_sealed", "exception_reason"] {
            nativePass = nativePass && uint(key) == 1
        }
        for key in ["cancellation_requested", "cancellation_calls", "watchdog_fired", "resources_quarantined"] {
            nativePass = nativePass && uint(key) == 0
        }
        nativePass = nativePass && uint("mappings_entered") == 3 && uint("register_calls") == 36 && uint("read_register_calls") == 4
        nativePass = nativePass && uint("pc") == 0x10000050 && uint("fault_ipa") == 0x1000c000 &&
            uint("fault_virtual_address") == 0x1000c000 && uint("x4") == 1 && uint("sctlr_el1") == 0x30d00800 && uint("cpsr") == 0x3c5
        if let syndrome = uint("syndrome") {
            nativePass = nativePass && (4...7).contains(syndrome & 63) && syndrome == (0x93840040 | (syndrome & 63))
        } else { nativePass = false }
        if let begin = uint("start_ticks"), let entry = uint("entry_ticks"), let exit = uint("exit_ticks"),
           let seal = uint("snapshot_ticks"), let end = uint("end_ticks"), let deadline = uint("deadline_ticks"),
           let numerator = uint("timebase_numer"), let denominator = uint("timebase_denom") {
            nativePass = nativePass && begin > 0 && begin <= entry && entry <= exit && exit <= seal && seal <= end &&
                entry < deadline && exit <= deadline && numerator > 0 && denominator > 0
            if numerator > 0, denominator > 0, numerator <= UInt32.max, denominator <= UInt32.max, deadline > entry {
                let maximumTicks = (2_000_000_000 * denominator + numerator - 1) / numerator
                nativePass = nativePass && deadline - entry <= maximumTicks
            } else { nativePass = false }
            guard text(terminal, "elapsed") == "\(end >= begin ? end - begin : 0) ticks × \(numerator)/\(denominator) ns" else {
                throw ProvenanceFailure("Elapsed display differs from exact tick data")
            }
        } else { nativePass = false }
        if case .map(let statuses) = observation["native_status_decimal"] {
            for key in ["failure_stage", "first_error", "signing_error", "vm_create", "vcpu_create", "register", "run",
                        "read_register", "vcpu_destroy", "vm_destroy", "watchdog_create", "watchdog_join",
                        "map_code", "map_request", "map_reply", "unmap_code", "unmap_request", "unmap_reply",
                        "host_unmap_code", "host_unmap_request", "host_unmap_reply"] {
                nativePass = nativePass && statuses[key] == .text("0")
            }
            nativePass = nativePass && statuses["cancellation"] == .text(String(Int32.min))
            let waitStatus = statuses["watchdog_wait"]
            nativePass = nativePass && (waitStatus == .text(String(Int32.min)) || waitStatus == .text("0") || waitStatus == .text("60"))
        } else { nativePass = false }
        let inputPass = start["request"] == .bytes(GuestContract.request) && start["expected_reply"] == .bytes(GuestContract.reply) &&
            start["host_bundle"] == .text("com.ergentics.provenance") &&
            start["guest_sha256"] == .text(GuestContract.expectedGuestSHA256) &&
            observation["guest_sha256"] == .text(GuestContract.expectedGuestSHA256) &&
            start["load_ipa"] == .unsigned(0x10000000) && start["doorbell_instruction_offset"] == .unsigned(80)
        let reconstructedPass = nativePass && snapshotValid && inputPass && flag(observation, "independent_snapshot_pass") == true
        guard (label == "PASS") == reconstructedPass else { throw ProvenanceFailure("Terminal PASS label disagrees with reconstructed predicates") }
        return VerifiedGuestResult(status: label, detail: text(terminal, "detail"), root: root,
            elapsed: text(terminal, "elapsed"), quarantined: uint("resources_quarantined") == 1)
    }
}
