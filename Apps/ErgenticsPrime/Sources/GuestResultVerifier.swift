import Foundation

struct VerifiedGuestResult {
    let status: String
    let detail: String
    let root: String
    let elapsed: String
    let quarantined: Bool
}

enum GuestResultVerifier {
    private enum Profile: Equatable { case legacy, rustBootstrap }
    private static let rustStatusKeys = ["map_stack", "unmap_stack", "host_unmap_stack", "entry_sp", "exit_sp"]
    private static let rustPayloadKeys: Set<String> = [
        "snapshot_schema", "memory_contract", "stack_valid", "entry_sp", "exit_sp", "stack_frame"
    ]

    // A missing profile selects only the historical baseline. Merkle hashes
    // cannot erase a Rust marker or turn one typed protocol into another.
    private static func profile(for payloads: [[String: GuestCBORValue]]) throws -> Profile {
        let selected: Profile
        if payloads[0]["profile"] == nil { selected = .legacy }
        else if payloads[0]["profile"] == .text(RustBootstrapContract.profile) { selected = .rustBootstrap }
        else { throw ProvenanceFailure("Unknown guest receipt profile") }
        for (index, payload) in payloads.enumerated() {
            switch selected {
            case .legacy:
                guard payload["profile"] == nil, rustPayloadKeys.isDisjoint(with: payload.keys),
                      payload["guest_sha256"] != .text(RustBootstrapContract.expectedGuestSHA256),
                      payload["abi_version"] != .unsigned(2) else {
                    throw ProvenanceFailure("Rust or mixed-profile markers in a legacy guest receipt")
                }
                if case .map(let statuses) = payload["native_status_decimal"],
                   !Set(rustStatusKeys).isDisjoint(with: statuses.keys) {
                    throw ProvenanceFailure("Rust native statuses in a legacy guest receipt")
                }
                if case .bytes(let image) = payload["guest_image"],
                   GuestContract.hash(image) == RustBootstrapContract.expectedGuestSHA256 {
                    throw ProvenanceFailure("Rust image cannot use the legacy receipt profile")
                }
            case .rustBootstrap:
                guard payload["profile"] == .text(RustBootstrapContract.profile),
                      payload["memory_contract"] == .bytes(RustBootstrapContract.memoryContract) else {
                    throw ProvenanceFailure("Rust profile or memory contract does not join every event")
                }
                if let schema = payload["snapshot_schema"], schema != .text(RustBootstrapContract.schema) {
                    throw ProvenanceFailure("Rust snapshot schema does not match its profile")
                }
                if index == 0, payload["snapshot_schema"] != .text(RustBootstrapContract.schema) {
                    throw ProvenanceFailure("Rust start must name its exact snapshot schema")
                }
                if index == 1, payload["abi_version"] != .unsigned(2) {
                    throw ProvenanceFailure("Rust observation requires native ABI 2")
                }
            }
        }
        return selected
    }

    // Journal verifies canonical envelope bytes and ancestry. This separately
    // reconstructs the semantic result; a terminal's prose cannot grant PASS.
    static func verify(runID: String, events: [GuestJournalEvent],
                       expectedRetention: GuestRetentionAncestry? = nil) throws -> VerifiedGuestResult {
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
        let selectedProfile = try profile(for: payloads)
        if let expectedRetention {
            let start = payloads[0]
            guard start["retention_epoch_id"] == .text(expectedRetention.epochID),
                  start["retention_genesis_sha256"] == .text(expectedRetention.genesisSHA256) else {
                throw ProvenanceFailure("Guest start does not join the retained genesis")
            }
        }
        let rust = selectedProfile == .rustBootstrap
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
            if rust {
                if case .bytes(let memory) = observation["memory_contract"],
                   case .bytes(let stack) = observation["stack_frame"] {
                    snapshotValid = try RustBootstrapContract.validateSnapshot(image: image,
                        request: request, reply: reply, memoryContract: memory,
                        stackFrame: stack, expectedRoot: observedRoot)
                }
            } else {
                snapshotValid = try GuestContract.validateSnapshot(image: image, request: request,
                    reply: reply, expectedRoot: observedRoot)
            }
            guard root == (uint("snapshot_sealed") == 1 ? observedRoot : "") else {
                throw ProvenanceFailure("Terminal Merkle root differs from its snapshot")
            }
        }
        if flag(observation, "independent_snapshot_pass") == true && !snapshotValid {
            throw ProvenanceFailure("Stored snapshot assertion fails independent reconstruction")
        }
        var nativePass = true
        for key in ["outcome", "execution_pass", "teardown_pass", "signing_admitted",
                    "run_entries", "vcpu_created", "request_unchanged", "reply_valid", "code_unchanged",
                    "trap_valid", "snapshot_sealed", "exception_reason"] {
            nativePass = nativePass && uint(key) == 1
        }
        for key in ["cancellation_requested", "cancellation_calls", "watchdog_fired", "resources_quarantined"] {
            nativePass = nativePass && uint(key) == 0
        }
        nativePass = nativePass && uint("abi_version") == (rust ? 2 : 1) &&
            uint("mappings_entered") == (rust ? 4 : 3) && uint("register_calls") == 36 &&
            uint("read_register_calls") == (rust ? 6 : 4)
        nativePass = nativePass && uint("pc") == (rust ? RustBootstrapContract.doorbellPC : 0x10000050) && uint("fault_ipa") == 0x1000c000 &&
            uint("fault_virtual_address") == 0x1000c000 && uint("x4") == 1 && uint("sctlr_el1") == 0x30d00800 && uint("cpsr") == 0x3c5
        if rust {
            nativePass = nativePass && uint("stack_valid") == 1 &&
                uint("entry_sp") == RustBootstrapContract.entrySP && uint("exit_sp") == RustBootstrapContract.exitSP &&
                observation["stack_frame"] == .bytes(RustBootstrapContract.stackFrame)
        }
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
            if rust {
                for key in rustStatusKeys { nativePass = nativePass && statuses[key] == .text("0") }
            }
            nativePass = nativePass && statuses["cancellation"] == .text(String(Int32.min))
            let waitStatus = statuses["watchdog_wait"]
            nativePass = nativePass && (waitStatus == .text(String(Int32.min)) || waitStatus == .text("0") || waitStatus == .text("60"))
        } else { nativePass = false }
        let expectedHash = rust ? RustBootstrapContract.expectedGuestSHA256 : GuestContract.expectedGuestSHA256
        let inputPass = start["request"] == .bytes(GuestContract.request) && start["expected_reply"] == .bytes(GuestContract.reply) &&
            start["host_bundle"] == .text("com.ergentics.provenance") &&
            start["guest_sha256"] == .text(expectedHash) && observation["guest_sha256"] == .text(expectedHash) &&
            start["load_ipa"] == .unsigned(0x10000000) &&
            start["doorbell_instruction_offset"] == .unsigned(rust ? RustBootstrapContract.doorbellOffset : 80)
        let reconstructedPass = nativePass && snapshotValid && inputPass && flag(observation, "independent_snapshot_pass") == true
        guard (label == "PASS") == reconstructedPass else { throw ProvenanceFailure("Terminal PASS label disagrees with reconstructed predicates") }
        return VerifiedGuestResult(status: label, detail: text(terminal, "detail"), root: root,
            elapsed: text(terminal, "elapsed"), quarantined: uint("resources_quarantined") == 1)
    }
}
