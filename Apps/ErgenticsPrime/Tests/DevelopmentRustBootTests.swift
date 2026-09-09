import Foundation
import XCTest

// Pure fabricated host values. This class never opens a journal, calls a
// native helper, creates/runs a VM, launches a process, or touches the filesystem.
final class DevelopmentRustBootTests: XCTestCase {
    private let bootID = "01234567-89ab-cdef-0123-456789abcdef"
    private let runID = "fedcba98-7654-4321-fedc-ba9876543210"

    private func context(signature: Bool = true, team: String = "ZCQ435U8JP",
                         names: [String] = ["A_NAME", "Z_NAME"],
                         start: UInt64 = 50, numerator: UInt32 = 125,
                         denominator: UInt32 = 3) -> DevelopmentRustBootContext {
        DevelopmentRustBootContext(bootID: bootID, pid: 123,
            bundleIdentifier: "com.ergentics.provenance", executablePath: "/fixture/Ergentics Provenance",
            team: team, signatureAdmitted: signature, signingStatus: "fabricated signing observation",
            environmentNames: names, startTicks: start,
            timebaseNumerator: numerator, timebaseDenominator: denominator)
    }

    private var image: Data {
        let words: [UInt32] = [
            0xd2880009, 0xf2a20029, 0x9100013f, 0xaa1f03fd, 0xaa1f03fe,
            0xd2880009, 0xf2a20009, 0xc8dffd20, 0xf9400521, 0xf9400922,
            0xf9400d23, 0x94000014, 0xf100a81f, 0x540001c1, 0xd2900001,
            0xf2a20001, 0xd2980003, 0xf2a20003, 0xd2800024, 0xf9000424,
            0xf9000820, 0xf9000c3f, 0xc89ffc24, 0xd5033f9f, 0xb9000064,
            0xd43bd5a0, 0x14000000, 0xd42175a0, 0x14000000, 0xd42175e0,
            0x14000000, 0xa9bf7bfd, 0xf1005c7f, 0x52800548, 0x910003fd,
            0xfa530840, 0xfa410820, 0xfa410800, 0x9a9f0100, 0xa8c17bfd, 0xd65f03c0
        ]
        return Data(words.flatMap { value in (0..<4).map { UInt8(truncatingIfNeeded: value >> ($0 * 8)) } })
    }

    private func hex(_ string: String) -> Data {
        let bytes = Array(string.utf8)
        func nibble(_ value: UInt8) -> UInt8 { value <= 57 ? value - 48 : value - 87 }
        return Data(stride(from: 0, to: bytes.count, by: 2).map { nibble(bytes[$0]) << 4 | nibble(bytes[$0 + 1]) })
    }

    private func payloads() -> [[String: GuestCBORValue]] {
        let start: [String: GuestCBORValue] = [
            "profile": .text(RustBootstrapContract.profile),
            "snapshot_schema": .text(RustBootstrapContract.schema),
            "memory_contract": .bytes(RustBootstrapContract.memoryContract),
            "guest_image": .bytes(image), "guest_sha256": .text(RustBootstrapContract.expectedGuestSHA256),
            "request": .bytes(RustBootstrapContract.request), "expected_reply": .bytes(RustBootstrapContract.reply),
            "load_ipa": .unsigned(0x10000000), "doorbell_instruction_offset": .unsigned(96),
            "host_bundle": .text("com.ergentics.provenance"), "scope": .text("fabricated pure fixture")
        ]
        var raw: [String: GuestCBORValue] = [:]
        for key in ["outcome", "execution_pass", "teardown_pass", "signing_admitted", "run_entries",
                    "vcpu_created", "request_unchanged", "reply_valid", "code_unchanged", "trap_valid",
                    "snapshot_sealed", "exception_reason", "stack_valid"] { raw[key] = .unsigned(1) }
        for key in ["cancellation_requested", "cancellation_calls", "watchdog_fired", "resources_quarantined"] {
            raw[key] = .unsigned(0)
        }
        let values: [String: UInt64] = [
            "abi_version": 2, "mappings_entered": 4, "register_calls": 36, "read_register_calls": 6,
            "pc": 0x10000060, "fault_ipa": 0x1000c000, "fault_virtual_address": 0x1000c000,
            "x4": 1, "sctlr_el1": 0x30d00800, "cpsr": 0x3c5, "syndrome": 0x93840046,
            "start_ticks": 100, "entry_ticks": 200, "exit_ticks": 300, "snapshot_ticks": 310,
            "end_ticks": 350, "deadline_ticks": 48_000_150, "timebase_numer": 125, "timebase_denom": 3,
            "entry_sp": 0x10014000, "exit_sp": 0x10014000
        ]
        for (key, value) in values { raw[key] = .unsigned(value) }
        var statuses = Dictionary(uniqueKeysWithValues: [
            "failure_stage", "first_error", "signing_error", "vm_create", "vcpu_create", "register",
            "run", "read_register", "vcpu_destroy", "vm_destroy", "watchdog_create", "watchdog_join",
            "watchdog_wait", "map_code", "map_request", "map_reply", "map_stack", "unmap_code",
            "unmap_request", "unmap_reply", "unmap_stack", "host_unmap_code", "host_unmap_request",
            "host_unmap_reply", "host_unmap_stack", "entry_sp", "exit_sp"
        ].map { ($0, GuestCBORValue.text("0")) })
        statuses["cancellation"] = .text(String(Int32.min))
        raw["native_status_decimal"] = .map(statuses)
        raw["profile"] = .text(RustBootstrapContract.profile)
        raw["memory_contract"] = .bytes(RustBootstrapContract.memoryContract)
        raw["request"] = .bytes(RustBootstrapContract.request)
        raw["reply"] = .bytes(RustBootstrapContract.reply)
        raw["guest_sha256"] = .text(RustBootstrapContract.expectedGuestSHA256)
        raw["stack_frame"] = .bytes(RustBootstrapContract.stackFrame)
        raw["independent_snapshot_pass"] = .bool(true)
        raw["seal_scope"] = .text("fabricated raw observation; not a guest execution")
        let root = "f30c5b950a5ee19fab3dc1d6a828cc6c0c41fb64460c06ca455951dd0c631366"
        raw["snapshot_merkle"] = .bytes(hex(root))
        let terminal: [String: GuestCBORValue] = [
            "profile": .text(RustBootstrapContract.profile), "memory_contract": .bytes(RustBootstrapContract.memoryContract),
            "status": .text("PASS"), "detail": .text("fabricated complete result"),
            "execution_pass": .bool(true), "teardown_pass": .bool(true), "resources_quarantined": .bool(false),
            "independent_snapshot_pass": .bool(true), "snapshot_merkle": .text(root),
            "elapsed": .text("250 ticks × 125/3 ns"), "energy": .text("unmeasured; ergs unavailable"),
            "gate_e": .text("ABSTAIN"), "authority_vector": .text("00000000")
        ]
        return [start, raw, terminal]
    }

    private func events(_ payloads: [[String: GuestCBORValue]]) throws -> [GuestJournalEvent] {
        var events: [GuestJournalEvent] = []
        for (index, payload) in payloads.enumerated() {
            let kind = ["start", "observation", "terminal"][min(index, 2)]
            let parent = events.last?.digest
            let bytes = try GuestCBOR.encode(.map([
                "schema": .text(GuestJournal.schema), "run_id": .text(runID),
                "sequence": .unsigned(UInt64(index)), "kind": .text(kind),
                "parent": .bytes(parent.map(hex) ?? Data()), "payload": .map(payload)
            ]))
            events.append(GuestJournalEvent(runID: runID, sequence: index, kind: kind, payload: bytes,
                digest: GuestContract.hash(bytes), parent: parent))
        }
        return events
    }

    private func completion(_ payloads: [[String: GuestCBORValue]]? = nil,
                            disposition: DevelopmentRustNativeDisposition = .returnedConserved,
                            verified: Bool = true, retained: Bool = true, status: String = "PASS",
                            detail: String = "fabricated complete result",
                            rawOverride: [String: GuestCBORValue]? = nil,
                            ticks: UInt64 = 400) throws -> DevelopmentRustBootCompletion {
        let p = payloads ?? self.payloads()
        let raw = rawOverride ?? (p.count > 1 ? p[1] : [:])
        return DevelopmentRustBootCompletion(runID: runID, nativeDisposition: disposition,
            rawFields: raw, events: try events(p), journalVerified: verified,
            journalRetainsAllEvidence: retained, status: status, detail: detail, journalCompletedTicks: ticks)
    }

    private func encode(_ value: DevelopmentRustBootCompletion,
                        context: DevelopmentRustBootContext? = nil, prepared: UInt64 = 500) throws -> Data {
        try DevelopmentRustBootReport.encode(context: context ?? self.context(), completion: value, preparedTicks: prepared)
    }

    private func mutate(_ frame: Data, _ body: (inout [String: Any]) -> Void) throws -> Data {
        let json = Data(frame.dropFirst(DevelopmentRustBootReport.prefix.utf8.count).dropLast())
        var value = try XCTUnwrap(JSONSerialization.jsonObject(with: json) as? [String: Any])
        body(&value)
        return Data(DevelopmentRustBootReport.prefix.utf8) +
            (try JSONSerialization.data(withJSONObject: value, options: [.sortedKeys, .withoutEscapingSlashes])) + Data([10])
    }

    func testFabricatedCompleteReportRoundTripsExactOriginalEvents() throws {
        let value = try completion()
        let frame = try encode(value)
        let verified = try DevelopmentRustBootReport.verify(frame: frame)
        XCTAssertEqual(verified.bootID, bootID)
        XCTAssertEqual(verified.runID, runID)
        XCTAssertEqual(verified.status, "PASS")
        XCTAssertEqual(verified.nativeDisposition, .returnedConserved)
        XCTAssertTrue(verified.journalVerified)
        XCTAssertTrue(verified.journalRetainsAllEvidence)
        XCTAssertEqual(verified.frameSHA256, GuestContract.hash(frame))
        XCTAssertEqual(frame, try encode(value))
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: Data(frame.dropFirst(DevelopmentRustBootReport.prefix.utf8.count).dropLast())) as? [String: Any])
        let rows = try XCTUnwrap(json["events"] as? [[String: Any]])
        for (row, event) in zip(rows, value.events) {
            XCTAssertEqual(Data(base64Encoded: try XCTUnwrap(row["canonical_cbor_base64"] as? String)), event.payload)
        }
        for futureClaim in ["process_exited", "export_completed", "export_retained", "normalQuitRequested"] {
            XCTAssertNil(json[futureClaim])
        }
    }

    func testPreparedReportCannotProveItsOwnFutureExportOrExit() throws {
        let frame = try encode(completion())
        for key in ["export_completed", "process_exited", "export_retained"] {
            XCTAssertThrowsError(try DevelopmentRustBootReport.verify(frame: mutate(frame) { $0[key] = true }))
        }
    }

    func testAllLifecycleDispositionAndRetentionCombinations() {
        for disposition in [DevelopmentRustNativeDisposition.notEntered, .running, .returnedConserved, .returnedUnconserved] {
            for journal in [false, true] {
                for export in [false, true] {
                    let expected = (disposition == .notEntered || disposition == .returnedConserved) && (journal || export)
                    XCTAssertEqual(DevelopmentRustBootReport.mayTerminate(nativeDisposition: disposition,
                        journalRetainsAllEvidence: journal, exportRetained: export), expected)
                }
            }
        }
    }

    func testNoEntryFailureRetainsUnknownSigningAndTimebaseWithoutGrantingPass() throws {
        let value = DevelopmentRustBootCompletion(runID: "", nativeDisposition: .notEntered,
            rawFields: [:], events: [], journalVerified: false, journalRetainsAllEvidence: false,
            status: "NOT_ENTERED", detail: "signing or descriptor admission failed", journalCompletedTicks: 0)
        let frame = try encode(value, context: context(signature: false, team: "", numerator: 0, denominator: 0))
        XCTAssertEqual(try DevelopmentRustBootReport.verify(frame: frame).nativeDisposition, .notEntered)
        XCTAssertFalse(try DevelopmentRustBootReport.mayTerminate(completion: value, exportRetained: false))
        XCTAssertTrue(try DevelopmentRustBootReport.mayTerminate(completion: value, exportRetained: true))
    }

    func testRunningStartPrefixCannotExitEvenWhenExported() throws {
        let value = try completion(Array(payloads().prefix(1)), disposition: .running,
            verified: false, retained: false, status: "INCOMPLETE")
        XCTAssertEqual(try DevelopmentRustBootReport.verify(frame: encode(value)).status, "INCOMPLETE")
        XCTAssertFalse(try DevelopmentRustBootReport.mayTerminate(completion: value, exportRetained: true))
    }

    func testReturnedRawRecoveryPreservesEveryAvailablePrefix() throws {
        let p = payloads()
        for count in 0...3 {
            let value = try completion(Array(p.prefix(count)), verified: false, retained: false,
                status: "INCOMPLETE", detail: "journal read-back incomplete", rawOverride: p[1])
            XCTAssertEqual(try DevelopmentRustBootReport.verify(frame: encode(value)).status, "INCOMPLETE")
            XCTAssertFalse(try DevelopmentRustBootReport.mayTerminate(completion: value, exportRetained: false))
            XCTAssertTrue(try DevelopmentRustBootReport.mayTerminate(completion: value, exportRetained: true))
        }
    }

    func testVerifiedJournalFlagsCannotPromotePrefixesOrNewUnretainedError() throws {
        for count in 0...2 {
            XCTAssertThrowsError(try encode(completion(Array(payloads().prefix(count)), rawOverride: payloads()[1])))
        }
        XCTAssertThrowsError(try encode(completion(detail: "new error absent from terminal")))
        XCTAssertThrowsError(try encode(completion(verified: false, retained: true, status: "INCOMPLETE")))
        XCTAssertThrowsError(try encode(completion(verified: false, retained: false)))
    }

    func testConservedExecutionFailureMayExitAsFailureNotPass() throws {
        var p = payloads()
        p[1]["outcome"] = .unsigned(2); p[1]["execution_pass"] = .unsigned(0)
        p[2]["status"] = .text("FAIL"); p[2]["execution_pass"] = .bool(false)
        let value = try completion(p, status: "FAIL")
        XCTAssertEqual(try DevelopmentRustBootReport.verify(frame: encode(value)).status, "FAIL")
        XCTAssertTrue(try DevelopmentRustBootReport.mayTerminate(completion: value, exportRetained: false))
    }

    func testUnconservedReturnCannotExitDespiteCompleteEvidence() throws {
        var p = payloads()
        p[1]["outcome"] = .unsigned(2); p[1]["teardown_pass"] = .unsigned(0)
        p[1]["resources_quarantined"] = .unsigned(1)
        p[2]["status"] = .text("FAIL"); p[2]["teardown_pass"] = .bool(false)
        p[2]["resources_quarantined"] = .bool(true)
        let value = try completion(p, disposition: .returnedUnconserved, status: "FAIL")
        XCTAssertEqual(try DevelopmentRustBootReport.verify(frame: encode(value)).nativeDisposition, .returnedUnconserved)
        XCTAssertFalse(try DevelopmentRustBootReport.mayTerminate(completion: value, exportRetained: true))
        XCTAssertThrowsError(try encode(completion(p, status: "FAIL")))
    }

    func testForgedConservationFlagsCannotHideFailedOrUnenteredDisposal() throws {
        for key in ["vm_destroy", "vcpu_destroy", "watchdog_join", "host_unmap_stack"] {
            for status in ["5", String(Int32.min)] {
                var p = payloads()
                guard case .map(var statuses) = p[1]["native_status_decimal"] else { return XCTFail() }
                statuses[key] = .text(status); p[1]["native_status_decimal"] = .map(statuses)
                let value = try completion(p, verified: false, retained: false, status: "INCOMPLETE")
                XCTAssertThrowsError(try encode(value), key)
                XCTAssertThrowsError(try DevelopmentRustBootReport.mayTerminate(completion: value, exportRetained: true), key)
            }
        }
    }

    func testRawObservationMustEqualOriginalCommittedPayload() throws {
        var raw = payloads()[1]; raw["pc"] = .unsigned(0x10000050)
        XCTAssertThrowsError(try encode(completion(rawOverride: raw)))
        raw = payloads()[1]; raw["teardown_pass"] = .bool(true)
        XCTAssertThrowsError(try encode(completion(rawOverride: raw)))
    }

    func testEnteredMappingCannotHideBehindUnenteredVMCreation() throws {
        for slot in ["code", "request", "reply", "stack"] {
            for mapStatus in ["0", "5"] {
                var p = payloads()
                guard case .map(var statuses) = p[1]["native_status_decimal"] else { return XCTFail() }
                statuses["vm_create"] = .text(String(Int32.min))
                statuses["vm_destroy"] = .text(String(Int32.min))
                statuses["map_" + slot] = .text(mapStatus)
                statuses["host_unmap_" + slot] = .text(String(Int32.min))
                p[1]["native_status_decimal"] = .map(statuses)
                let value = try completion(p, verified: false, retained: false, status: "INCOMPLETE")
                XCTAssertThrowsError(try encode(value), slot)
                XCTAssertThrowsError(try DevelopmentRustBootReport.mayTerminate(completion: value, exportRetained: true), slot)
            }
        }
    }

    func testFailedEnteredVMCreationStillRequiresAllFourHostDisposals() throws {
        for slot in ["code", "request", "reply", "stack"] {
            var p = payloads()
            guard case .map(var statuses) = p[1]["native_status_decimal"] else { return XCTFail() }
            statuses["vm_create"] = .text("5")
            statuses["vm_destroy"] = .text(String(Int32.min))
            for name in ["code", "request", "reply", "stack"] {
                statuses["map_" + name] = .text(String(Int32.min))
            }
            statuses["host_unmap_" + slot] = .text(String(Int32.min))
            p[1]["native_status_decimal"] = .map(statuses)
            let value = try completion(p, verified: false, retained: false, status: "INCOMPLETE")
            XCTAssertThrowsError(try encode(value), slot)
            XCTAssertThrowsError(try DevelopmentRustBootReport.mayTerminate(completion: value, exportRetained: true), slot)
        }
    }

    func testEarlyPartialAllocationFailureCanBeConservedWithoutUnenteredDisposals() throws {
        var raw = payloads()[1]
        // Fabricated stage_memory failure on the third allocation. The first
        // two allocations were disposed; slots three/four and all HV calls
        // never existed. This must not require four invented successful calls.
        for (key, value) in raw {
            if case .unsigned = value { raw[key] = .unsigned(0) }
        }
        raw["abi_version"] = .unsigned(2); raw["outcome"] = .unsigned(2)
        raw["signing_admitted"] = .unsigned(1); raw["teardown_pass"] = .unsigned(1)
        raw["exception_reason"] = .unsigned(UInt64(UInt32.max))
        raw["timebase_numer"] = .unsigned(125); raw["timebase_denom"] = .unsigned(3)
        raw["start_ticks"] = .unsigned(100); raw["end_ticks"] = .unsigned(350)
        for key in ["request", "reply", "snapshot_merkle"] { raw[key] = .bytes(Data(repeating: 0, count: 32)) }
        raw["stack_frame"] = .bytes(Data(repeating: 0, count: 16))
        raw["independent_snapshot_pass"] = .bool(false)
        guard case .map(var statuses) = raw["native_status_decimal"] else { return XCTFail() }
        for key in statuses.keys { statuses[key] = .text(String(Int32.min)) }
        statuses["failure_stage"] = .text("3"); statuses["first_error"] = .text("12")
        statuses["signing_error"] = .text("0")
        statuses["host_unmap_code"] = .text("0"); statuses["host_unmap_request"] = .text("0")
        raw["native_status_decimal"] = .map(statuses)
        let value = try completion(Array(payloads().prefix(1)), verified: false, retained: false,
            status: "INCOMPLETE", detail: "fixture journal failure after conserved early native failure", rawOverride: raw)
        XCTAssertEqual(try DevelopmentRustBootReport.verify(frame: encode(value)).nativeDisposition, .returnedConserved)
        XCTAssertFalse(try DevelopmentRustBootReport.mayTerminate(completion: value, exportRetained: false))
        XCTAssertTrue(try DevelopmentRustBootReport.mayTerminate(completion: value, exportRetained: true))
    }

    func testEveryEventProfileAndLayoutIsBoundEvenForIncompleteReports() throws {
        for index in 0..<3 {
            for key in ["profile", "memory_contract"] {
                var p = payloads(); p[index].removeValue(forKey: key)
                XCTAssertThrowsError(try encode(completion(p, verified: false, retained: false, status: "INCOMPLETE")))
            }
        }
        var p = payloads(); p[0]["guest_image"] = .bytes(Data(repeating: 0, count: 164))
        XCTAssertThrowsError(try encode(completion(Array(p.prefix(1)), disposition: .notEntered,
            verified: false, retained: false, status: "INCOMPLETE")))
    }

    func testRehashedInvalidNativeResultCannotObtainPass() throws {
        for key in ["pc", "entry_sp", "exit_sp", "stack_valid", "run_entries"] {
            var p = payloads(); p[1][key] = .unsigned(0)
            // events() rehashes every envelope and ancestor; the semantic
            // verifier still rejects a transported PASS with wrong raw facts.
            XCTAssertThrowsError(try encode(completion(p)), key)
        }
    }

    func testEventDigestAncestryAndProjectionAreNotTrusted() throws {
        let value = try completion()
        let first = value.events[0]
        let wrong = GuestJournalEvent(runID: first.runID, sequence: first.sequence, kind: first.kind,
            payload: first.payload, digest: String(repeating: "0", count: 64), parent: first.parent)
        let altered = DevelopmentRustBootCompletion(runID: runID, nativeDisposition: value.nativeDisposition,
            rawFields: value.rawFields, events: [wrong] + Array(value.events.dropFirst()),
            journalVerified: true, journalRetainsAllEvidence: true, status: "PASS", detail: value.detail,
            journalCompletedTicks: 400)
        XCTAssertThrowsError(try encode(altered))
        let frame = try encode(value)
        let changed = try mutate(frame) { object in
            var rows = object["events"] as! [[String: Any]]
            rows[1]["parent"] = String(repeating: "0", count: 64); object["events"] = rows
        }
        XCTAssertThrowsError(try DevelopmentRustBootReport.verify(frame: changed))
    }

    func testTruncationExtraFramesWhitespaceAndUnknownFieldsReject() throws {
        let frame = try encode(completion())
        for value in [Data(), Data(frame.dropLast()), Data(frame.dropFirst()), frame + Data([10]),
                      frame + frame, Data(" ".utf8) + frame] {
            XCTAssertThrowsError(try DevelopmentRustBootReport.verify(frame: value))
        }
        let prefix = Data(DevelopmentRustBootReport.prefix.utf8)
        let json = Data(frame.dropFirst(prefix.count))
        XCTAssertThrowsError(try DevelopmentRustBootReport.verify(frame: prefix + Data([32]) + json))
    }

    func testRawRecoveryAndEventBoundsAreEnforcedBeforeExport() throws {
        var p = payloads(); p[0]["padding"] = .bytes(Data(repeating: 0, count: 65_536))
        XCTAssertThrowsError(try encode(completion(p)))
        p = payloads(); p[1]["seal_scope"] = .text(String(repeating: "a", count: 65_536))
        XCTAssertThrowsError(try encode(completion(p)))
        p = payloads(); p.append(p[2])
        XCTAssertThrowsError(try encode(completion(p)))
        XCTAssertThrowsError(try DevelopmentRustBootReport.verify(frame: Data(repeating: 65, count: 524_289)))
    }

    func testBase64RawDigestAndCanonicalCBORCannotBeAliased() throws {
        let frame = try encode(completion())
        for key in ["raw_recovery_cbor_base64", "raw_recovery_sha256"] {
            XCTAssertThrowsError(try DevelopmentRustBootReport.verify(frame: mutate(frame) { $0[key] = "AA== " }))
        }
        let noncanonical = Data([0xb8, 0x00]) // Empty map with nonminimal argument width.
        let changed = try mutate(frame) {
            $0["raw_recovery_cbor_base64"] = noncanonical.base64EncodedString()
            $0["raw_recovery_sha256"] = GuestContract.hash(noncanonical)
        }
        XCTAssertThrowsError(try DevelopmentRustBootReport.verify(frame: changed))
    }

    func testClockStringsPreserveLargeExactTicksAndRejectAliases() throws {
        let start: UInt64 = 9_007_199_254_740_993
        let value = DevelopmentRustBootCompletion(runID: "", nativeDisposition: .notEntered,
            rawFields: [:], events: [], journalVerified: false, journalRetainsAllEvidence: false,
            status: "NOT_ENTERED", detail: "fixture", journalCompletedTicks: 0)
        let frame = try encode(value, context: context(start: start), prepared: start + 1)
        XCTAssertTrue(String(decoding: frame, as: UTF8.self).contains("\"start_ticks\":\"9007199254740993\""))
        for invalid in ["0500", "+500", "500.0", "18446744073709551616"] {
            XCTAssertThrowsError(try DevelopmentRustBootReport.verify(frame: mutate(frame) { $0["prepared_ticks"] = invalid }))
        }
        XCTAssertThrowsError(try encode(completion(), prepared: 399))
        XCTAssertThrowsError(try encode(completion(), context: context(numerator: 1, denominator: 1)))
    }

    func testEnvironmentUsesNamesOnlyAndRejectsCountDuplicatesAndAssignments() throws {
        let frame = try encode(completion())
        for names in [["Z", "A"], ["A", "A"], ["SECRET=value"], [""]] {
            XCTAssertThrowsError(try encode(completion(), context: context(names: names)))
        }
        XCTAssertThrowsError(try DevelopmentRustBootReport.verify(frame: mutate(frame) { object in
            var c = object["context"] as! [String: Any]; c["environment_count"] = 99; object["context"] = c
        }))
        XCTAssertFalse(String(decoding: frame, as: UTF8.self).contains("environment_values"))
    }

    func testSigningIdentityAndAllFixedProtocolPinsConstrainPass() throws {
        XCTAssertThrowsError(try encode(completion(), context: context(signature: false, team: "")))
        XCTAssertThrowsError(try encode(completion(), context: context(team: "OTHERTEAM1")))
        let frame = try encode(completion())
        for key in ["profile", "snapshot_schema", "guest_sha256", "memory_contract_base64",
                    "authority_vector", "gate_e", "energy_ergs"] {
            XCTAssertThrowsError(try DevelopmentRustBootReport.verify(frame: mutate(frame) { $0[key] = "wrong" }), key)
        }
    }
}
