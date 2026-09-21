import Foundation

enum DevelopmentRustNativeDisposition: String, Codable, Sendable {
    case notEntered = "not_entered"
    case running = "running"
    case returnedConserved = "returned_conserved"
    case returnedUnconserved = "returned_unconserved"
}

// Deep immutable value snapshots only: no native handles, journal owner, or
// mutable reference storage. GuestCBORValue and GuestJournalEvent already have
// checked Sendable conformance; no unchecked transfer is necessary here.
struct DevelopmentRustBootCompletion: Sendable {
    let runID: String
    let nativeDisposition: DevelopmentRustNativeDisposition
    let rawFields: [String: GuestCBORValue]
    let events: [GuestJournalEvent]
    let journalVerified: Bool
    let journalRetainsAllEvidence: Bool
    let status: String
    let detail: String
    // End of the journal-owner attempt, not by itself evidence of a commit.
    let journalCompletedTicks: UInt64
}

struct DevelopmentRustBootContext: Sendable {
    let bootID: String
    let pid: Int32
    let bundleIdentifier: String
    let executablePath: String
    let team: String
    let signatureAdmitted: Bool
    let signingStatus: String
    let environmentNames: [String]
    let startTicks: UInt64
    let timebaseNumerator: UInt32
    let timebaseDenominator: UInt32
}

struct DevelopmentRustBootVerifiedReport: Sendable {
    let bootID: String
    let runID: String
    let nativeDisposition: DevelopmentRustNativeDisposition
    let status: String
    let journalVerified: Bool
    let journalRetainsAllEvidence: Bool
    let frameSHA256: String
}

// Pure transport boundary. JSON carries the ORIGINAL deterministic CBOR, not
// another execution authority. A valid prepared frame does not prove that it
// was written/synchronized/read back, or that the process subsequently exited.
enum DevelopmentRustBootReport {
    static let prefix = "ERGENTICS_RUST_BOOT_V1 "
    static let schema = "ergentics.rust-first-boot.report.v1"
    static let maximumFrameBytes = 512 * 1_024
    static let maximumEventBytes = 64 * 1_024
    static let maximumRecoveryBytes = 64 * 1_024
    private static let expectedTeam = "ZCQ435U8JP"
    private static let expectedBundle = "com.ergentics.provenance"
    private static let kinds = ["start", "observation", "terminal"]
    private static let flagKeys = [
        "abi_version", "outcome", "execution_pass", "teardown_pass", "signing_admitted",
        "run_entries", "vcpu_created", "mappings_entered", "register_calls", "read_register_calls",
        "cancellation_requested", "cancellation_calls", "watchdog_fired", "resources_quarantined",
        "request_unchanged", "reply_valid", "code_unchanged", "trap_valid", "exception_reason",
        "timebase_numer", "timebase_denom", "snapshot_sealed", "stack_valid"
    ]
    private static let wordKeys = [
        "start_ticks", "entry_ticks", "exit_ticks", "snapshot_ticks", "end_ticks", "deadline_ticks",
        "syndrome", "pc", "fault_ipa", "fault_virtual_address", "x4", "sctlr_el1", "cpsr",
        "entry_sp", "exit_sp"
    ]
    private static let statusKeys = [
        "failure_stage", "first_error", "signing_error", "vm_create", "vcpu_create", "register",
        "run", "read_register", "vcpu_destroy", "vm_destroy", "cancellation", "watchdog_create",
        "watchdog_join", "watchdog_wait", "map_code", "map_request", "map_reply", "map_stack",
        "unmap_code", "unmap_request", "unmap_reply", "unmap_stack", "host_unmap_code",
        "host_unmap_request", "host_unmap_reply", "host_unmap_stack", "entry_sp", "exit_sp"
    ]

    private struct ContextWire: Codable {
        let boot_id: String
        let pid: Int32
        let bundle_identifier: String
        let executable_path: String
        let team: String
        let signature_admitted: Bool
        let signing_status: String
        let environment_names: [String]
        let environment_count: Int
        let start_ticks: String
        let timebase_numerator: UInt32
        let timebase_denominator: UInt32
    }

    private struct EventWire: Codable {
        let run_id: String
        let sequence: Int
        let kind: String
        let parent: String?
        let sha256: String
        let canonical_cbor_base64: String
    }

    private struct Wire: Codable {
        let schema: String
        let context: ContextWire
        let profile: String
        let snapshot_schema: String
        let guest_sha256: String
        let guest_bytes: Int
        let memory_contract_base64: String
        let run_id: String
        let native_disposition: DevelopmentRustNativeDisposition
        let raw_recovery_cbor_base64: String
        let raw_recovery_sha256: String
        let events: [EventWire]
        let journal_verified: Bool
        let journal_retains_all_evidence: Bool
        let journal_completed_ticks: String
        let prepared_ticks: String
        let timing_scope: String
        let status: String
        let detail: String
        let authority_vector: String
        let gate_e: String
        let energy_ergs: String
    }

    private static let timingScope = "integer mach ticks; journal completion is attempt completion, not commit proof; prepared precedes export and process exit"

    static func encode(context: DevelopmentRustBootContext,
                       completion: DevelopmentRustBootCompletion,
                       preparedTicks: UInt64) throws -> Data {
        try validateContext(context, completion: completion, preparedTicks: preparedTicks)
        try validateCompletion(completion)
        let raw = try GuestCBOR.encode(.map(completion.rawFields))
        guard raw.count <= maximumRecoveryBytes else { throw failure("Raw recovery exceeds its bound") }
        let wire = Wire(schema: schema, context: ContextWire(boot_id: context.bootID,
            pid: context.pid, bundle_identifier: context.bundleIdentifier,
            executable_path: context.executablePath, team: context.team,
            signature_admitted: context.signatureAdmitted, signing_status: context.signingStatus,
            environment_names: context.environmentNames, environment_count: context.environmentNames.count,
            start_ticks: String(context.startTicks), timebase_numerator: context.timebaseNumerator,
            timebase_denominator: context.timebaseDenominator),
            profile: RustBootstrapContract.profile, snapshot_schema: RustBootstrapContract.schema,
            guest_sha256: RustBootstrapContract.expectedGuestSHA256,
            guest_bytes: RustBootstrapContract.imageByteCount,
            memory_contract_base64: RustBootstrapContract.memoryContract.base64EncodedString(),
            run_id: completion.runID, native_disposition: completion.nativeDisposition,
            raw_recovery_cbor_base64: raw.base64EncodedString(), raw_recovery_sha256: GuestContract.hash(raw),
            events: completion.events.map { EventWire(run_id: $0.runID, sequence: $0.sequence,
                kind: $0.kind, parent: $0.parent, sha256: $0.digest,
                canonical_cbor_base64: $0.payload.base64EncodedString()) },
            journal_verified: completion.journalVerified,
            journal_retains_all_evidence: completion.journalRetainsAllEvidence,
            journal_completed_ticks: String(completion.journalCompletedTicks), prepared_ticks: String(preparedTicks),
            timing_scope: timingScope, status: completion.status, detail: completion.detail,
            authority_vector: "00000000", gate_e: "ABSTAIN", energy_ergs: "UNMEASURED")
        let encodedFrame = try frame(wire)
        // Exercise the independent decode/projection path before admitting an
        // export. This verifies prepared bytes only; it performs no I/O.
        _ = try verify(frame: encodedFrame)
        return encodedFrame
    }

    static func verify(frame bytes: Data) throws -> DevelopmentRustBootVerifiedReport {
        let prefixBytes = Data(prefix.utf8)
        guard bytes.count <= maximumFrameBytes, bytes.count > prefixBytes.count + 1,
              bytes.starts(with: prefixBytes), bytes.last == 10 else {
            throw failure("Missing, truncated or oversized report frame")
        }
        let json = Data(bytes.dropFirst(prefixBytes.count).dropLast())
        let wire = try JSONDecoder().decode(Wire.self, from: json)
        // Reject extra fields, duplicate-key aliases, whitespace variants,
        // numeric aliases and competing/trailing frames, not just parsed values.
        guard try frame(wire) == bytes,
              wire.schema == schema, wire.profile == RustBootstrapContract.profile,
              wire.snapshot_schema == RustBootstrapContract.schema,
              wire.guest_sha256 == RustBootstrapContract.expectedGuestSHA256,
              wire.guest_bytes == RustBootstrapContract.imageByteCount,
              wire.memory_contract_base64 == RustBootstrapContract.memoryContract.base64EncodedString(),
              wire.authority_vector == "00000000", wire.gate_e == "ABSTAIN",
              wire.energy_ergs == "UNMEASURED", wire.timing_scope == timingScope,
              wire.events.count <= 3, wire.context.environment_count == wire.context.environment_names.count else {
            throw failure("Report schema, canonical representation or fixed pins rejected")
        }
        let raw = try base64(wire.raw_recovery_cbor_base64, limit: maximumRecoveryBytes)
        guard isHash(wire.raw_recovery_sha256), GuestContract.hash(raw) == wire.raw_recovery_sha256,
              case .map(let rawFields) = try GuestCBOR.decode(raw) else {
            throw failure("Raw recovery canonical bytes or digest rejected")
        }
        let events = try wire.events.map { event in
            GuestJournalEvent(runID: event.run_id, sequence: event.sequence, kind: event.kind,
                payload: try base64(event.canonical_cbor_base64, limit: maximumEventBytes),
                digest: event.sha256, parent: event.parent)
        }
        let completion = DevelopmentRustBootCompletion(runID: wire.run_id,
            nativeDisposition: wire.native_disposition, rawFields: rawFields, events: events,
            journalVerified: wire.journal_verified, journalRetainsAllEvidence: wire.journal_retains_all_evidence,
            status: wire.status, detail: wire.detail,
            journalCompletedTicks: try decimal(wire.journal_completed_ticks))
        let context = DevelopmentRustBootContext(bootID: wire.context.boot_id, pid: wire.context.pid,
            bundleIdentifier: wire.context.bundle_identifier, executablePath: wire.context.executable_path,
            team: wire.context.team, signatureAdmitted: wire.context.signature_admitted,
            signingStatus: wire.context.signing_status, environmentNames: wire.context.environment_names,
            startTicks: try decimal(wire.context.start_ticks), timebaseNumerator: wire.context.timebase_numerator,
            timebaseDenominator: wire.context.timebase_denominator)
        try validateContext(context, completion: completion, preparedTicks: decimal(wire.prepared_ticks))
        try validateCompletion(completion)
        return DevelopmentRustBootVerifiedReport(bootID: context.bootID, runID: completion.runID,
            nativeDisposition: completion.nativeDisposition, status: completion.status,
            journalVerified: completion.journalVerified,
            journalRetainsAllEvidence: completion.journalRetainsAllEvidence,
            frameSHA256: GuestContract.hash(bytes))
    }

    // Lifecycle table only: use a validated report's disposition/retention or
    // the actual typed owner state, never unvalidated transport claims.
    static func mayTerminate(nativeDisposition: DevelopmentRustNativeDisposition,
                             journalRetainsAllEvidence: Bool, exportRetained: Bool) -> Bool {
        (nativeDisposition == .notEntered || nativeDisposition == .returnedConserved) &&
            (journalRetainsAllEvidence || exportRetained)
    }

    static func mayTerminate(completion: DevelopmentRustBootCompletion, exportRetained: Bool) throws -> Bool {
        try validateCompletion(completion)
        return mayTerminate(nativeDisposition: completion.nativeDisposition,
            journalRetainsAllEvidence: completion.journalRetainsAllEvidence, exportRetained: exportRetained)
    }

    private static func validateContext(_ c: DevelopmentRustBootContext,
                                        completion: DevelopmentRustBootCompletion,
                                        preparedTicks: UInt64) throws {
        guard isUUID(c.bootID), c.pid > 0, c.bundleIdentifier.utf8.count <= 256,
              !c.bundleIdentifier.utf8.contains(0), c.executablePath.utf8.count <= 4_096,
              !c.executablePath.utf8.contains(0), c.team.utf8.count <= 128,
              c.signingStatus.utf8.count <= 8_192, c.environmentNames.count <= 256,
              c.environmentNames == c.environmentNames.sorted(),
              Set(c.environmentNames).count == c.environmentNames.count,
              c.environmentNames.allSatisfy({ !$0.isEmpty && $0.utf8.count <= 1_024 &&
                  !$0.utf8.contains(0) && !$0.contains("=") }),
              c.startTicks > 0, preparedTicks >= c.startTicks,
              completion.journalCompletedTicks == 0 ||
                (completion.journalCompletedTicks >= c.startTicks && completion.journalCompletedTicks <= preparedTicks),
              !c.signatureAdmitted || (c.team == expectedTeam && c.bundleIdentifier == expectedBundle &&
                c.executablePath.hasPrefix("/")) else {
            throw failure("Report context, exact timing or environment-name projection rejected")
        }
        if completion.status == "PASS" {
            guard c.signatureAdmitted, c.timebaseNumerator > 0, c.timebaseDenominator > 0,
                  completion.journalCompletedTicks > 0,
                  uint(completion.rawFields, "start_ticks") >= c.startTicks,
                  uint(completion.rawFields, "end_ticks") <= completion.journalCompletedTicks,
                  completion.rawFields["timebase_numer"] == .unsigned(UInt64(c.timebaseNumerator)),
                  completion.rawFields["timebase_denom"] == .unsigned(UInt64(c.timebaseDenominator)) else {
                throw failure("PASS context does not join signing, raw clock and journal attempt")
            }
        }
    }

    private static func validateCompletion(_ c: DevelopmentRustBootCompletion) throws {
        guard (c.runID.isEmpty || isUUID(c.runID)), c.events.count <= 3,
              ["PASS", "FAIL", "CANCELED", "INCOMPLETE", "NOT_ENTERED"].contains(c.status),
              c.status != "NOT_ENTERED" || c.nativeDisposition == .notEntered,
              c.detail.utf8.count <= 8_192,
              !c.runID.isEmpty || (c.events.isEmpty && c.rawFields.isEmpty && c.nativeDisposition == .notEntered),
              try GuestCBOR.encode(.map(c.rawFields)).count <= maximumRecoveryBytes else {
            throw failure("Completion identifiers, status or recovery bounds rejected")
        }
        var payloads: [[String: GuestCBORValue]] = []
        for (index, event) in c.events.enumerated() {
            let parent = index == 0 ? nil : c.events[index - 1].digest
            guard !event.payload.isEmpty, event.payload.count <= maximumEventBytes,
                  event.runID == c.runID, event.sequence == index, event.kind == kinds[index],
                  event.parent == parent, isHash(event.digest), GuestContract.hash(event.payload) == event.digest,
                  case .map(let envelope) = try GuestCBOR.decode(event.payload),
                  Set(envelope.keys) == Set(["schema", "run_id", "sequence", "kind", "parent", "payload"]),
                  envelope["schema"] == .text(GuestJournal.schema), envelope["run_id"] == .text(c.runID),
                  envelope["sequence"] == .unsigned(UInt64(index)), envelope["kind"] == .text(kinds[index]),
                  envelope["parent"] == .bytes(try hashBytes(parent)),
                  case .map(let payload) = envelope["payload"],
                  payload["profile"] == .text(RustBootstrapContract.profile),
                  payload["memory_contract"] == .bytes(RustBootstrapContract.memoryContract) else {
                throw failure("Event framing, ancestry, digest or Rust profile rejected")
            }
            payloads.append(payload)
        }
        if let start = payloads.first {
            guard start["snapshot_schema"] == .text(RustBootstrapContract.schema),
                  case .bytes(let image) = start["guest_image"], image.count == RustBootstrapContract.imageByteCount,
                  GuestContract.hash(image) == RustBootstrapContract.expectedGuestSHA256,
                  start["guest_sha256"] == .text(RustBootstrapContract.expectedGuestSHA256),
                  start["request"] == .bytes(RustBootstrapContract.request),
                  start["expected_reply"] == .bytes(RustBootstrapContract.reply),
                  start["load_ipa"] == .unsigned(RustBootstrapContract.loadAddress),
                  start["doorbell_instruction_offset"] == .unsigned(RustBootstrapContract.doorbellOffset),
                  start["host_bundle"] == .text(expectedBundle) else {
                throw failure("Start prefix does not contain the exact reviewed image and input")
            }
        }
        switch c.nativeDisposition {
        case .notEntered, .running:
            guard c.rawFields.isEmpty, c.events.count <= 1, !c.journalVerified,
                  !c.journalRetainsAllEvidence, c.status != "PASS",
                  c.nativeDisposition != .running || c.status == "INCOMPLETE" else {
                throw failure("No captured return cannot supply native or complete journal evidence")
            }
        case .returnedConserved, .returnedUnconserved:
            guard !c.runID.isEmpty else { throw failure("Returned native state requires a run UUID") }
            try validateRaw(c.rawFields, disposition: c.nativeDisposition)
        }
        if payloads.count >= 2, payloads[1] != c.rawFields {
            throw failure("Raw recovery is not the exact committed observation payload")
        }
        if c.journalVerified {
            guard c.events.count == 3, c.journalCompletedTicks > 0 else {
                throw failure("Verified journal requires a complete current-run terminal")
            }
            let reconstructed = try GuestResultVerifier.verify(runID: c.runID, events: c.events)
            guard reconstructed.status == c.status,
                  (c.status != "PASS" || c.nativeDisposition == .returnedConserved) else {
                throw failure("Completion label differs from independently reconstructed journal result")
            }
            if c.journalRetainsAllEvidence, reconstructed.detail != c.detail {
                throw failure("New completion error/detail is not retained in the terminal")
            }
        } else if c.journalRetainsAllEvidence || !["INCOMPLETE", "NOT_ENTERED"].contains(c.status) {
            throw failure("Unverified journal requires a qualified incomplete/not-entered outcome")
        }
    }

    private static func validateRaw(_ raw: [String: GuestCBORValue],
                                    disposition: DevelopmentRustNativeDisposition) throws {
        let extras = ["native_status_decimal", "profile", "memory_contract", "request", "reply", "guest_sha256",
                      "snapshot_merkle", "stack_frame", "independent_snapshot_pass", "seal_scope"]
        guard Set(raw.keys) == Set(flagKeys + wordKeys + extras),
              raw["profile"] == .text(RustBootstrapContract.profile),
              raw["memory_contract"] == .bytes(RustBootstrapContract.memoryContract),
              raw["guest_sha256"] == .text(RustBootstrapContract.expectedGuestSHA256),
              raw["abi_version"] == .unsigned(2),
              case .bytes(let request) = raw["request"], request.count == 32,
              case .bytes(let reply) = raw["reply"], reply.count == 32,
              case .bytes(let root) = raw["snapshot_merkle"], root.count == 32,
              case .bytes(let stack) = raw["stack_frame"], stack.count == 16,
              case .bool = raw["independent_snapshot_pass"], case .text = raw["seal_scope"],
              case .map(let statuses) = raw["native_status_decimal"], Set(statuses.keys) == Set(statusKeys) else {
            throw failure("Explicit native recovery field schema rejected")
        }
        for key in flagKeys {
            guard case .unsigned(let value) = raw[key], value <= UInt32.max else { throw failure("Native UInt32 field rejected") }
        }
        for key in wordKeys {
            guard case .unsigned = raw[key] else { throw failure("Native UInt64 field rejected") }
        }
        var signed: [String: Int32] = [:]
        for key in statusKeys {
            guard case .text(let text) = statuses[key], let value = Int32(text), String(value) == text else {
                throw failure("Native signed status must retain its exact canonical decimal value")
            }
            signed[key] = value
        }
        let conserved = raw["teardown_pass"] == .unsigned(1) && raw["resources_quarantined"] == .unsigned(0)
        guard conserved == (disposition == .returnedConserved) else {
            throw failure("Native disposition does not join captured teardown/resource fields")
        }
        if conserved {
            // Flags are not sufficient when retained API statuses contradict
            // them. A successful VM destroy may conserve failed guest unmaps;
            // host unmaps must independently succeed for allocated pages.
            for key in ["vm_destroy", "vcpu_destroy", "watchdog_join", "host_unmap_code",
                        "host_unmap_request", "host_unmap_reply", "host_unmap_stack"] {
                guard signed[key] == 0 || signed[key] == Int32.min else { throw failure("Conservation contradicts teardown status") }
            }
            for (create, destroy) in [("vm_create", "vm_destroy"), ("vcpu_create", "vcpu_destroy"),
                                      ("watchdog_create", "watchdog_join")] {
                if signed[create] == 0, signed[destroy] != 0 { throw failure("Created native resource has no successful disposal") }
            }
            if raw["vcpu_created"] == .unsigned(1), signed["vcpu_destroy"] != 0 {
                throw failure("Recorded vCPU is not conserved")
            }
            // run_fixed_guest allocates all four host slots BEFORE entering
            // hv_vm_create, even when that call fails. A per-slot entered map
            // is an independent allocation witness and cannot be erased by a
            // contradictory vm_create sentinel in transported recovery data.
            if signed["vm_create"] != Int32.min {
                for key in ["host_unmap_code", "host_unmap_request", "host_unmap_reply", "host_unmap_stack"] {
                    guard signed[key] == 0 else { throw failure("Entered VM creation implies four allocated pages requiring disposal") }
                }
            }
            for slot in ["code", "request", "reply", "stack"] {
                if signed["map_" + slot] != Int32.min {
                    guard signed["host_unmap_" + slot] == 0 else {
                        throw failure("Entered slot mapping requires its host allocation disposal")
                    }
                }
            }
        }
    }

    private static func frame(_ value: Wire) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        let bytes = Data(prefix.utf8) + (try encoder.encode(value)) + Data([10])
        guard bytes.count <= maximumFrameBytes else { throw failure("Complete report exceeds its frame bound") }
        return bytes
    }

    private static func base64(_ text: String, limit: Int) throws -> Data {
        guard text.utf8.count <= ((limit + 2) / 3) * 4,
              let data = Data(base64Encoded: text), data.count <= limit,
              data.base64EncodedString() == text else { throw failure("Noncanonical or oversized base64 payload") }
        return data
    }

    private static func decimal(_ text: String) throws -> UInt64 {
        guard let value = UInt64(text), String(value) == text else { throw failure("Clock field is not canonical unsigned decimal") }
        return value
    }

    private static func uint(_ fields: [String: GuestCBORValue], _ key: String) -> UInt64 {
        if case .unsigned(let value) = fields[key] { return value }
        return 0
    }

    private static func isUUID(_ value: String) -> Bool {
        UUID(uuidString: value)?.uuidString.lowercased() == value
    }

    private static func isHash(_ value: String) -> Bool {
        value.utf8.count == 64 && value.utf8.allSatisfy { (48...57).contains($0) || (97...102).contains($0) }
    }

    private static func hashBytes(_ hash: String?) throws -> Data {
        guard let hash else { return Data() }
        guard isHash(hash) else { throw failure("Parent digest is not lowercase SHA-256") }
        let chars = Array(hash.utf8)
        func nibble(_ value: UInt8) -> UInt8 { value <= 57 ? value - 48 : value - 87 }
        return Data(stride(from: 0, to: chars.count, by: 2).map { nibble(chars[$0]) << 4 | nibble(chars[$0 + 1]) })
    }

    private static func failure(_ description: String) -> ProvenanceFailure {
        ProvenanceFailure("Rust boot report: \(description)")
    }
}
