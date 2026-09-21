import Foundation
import XCTest

// Pure fabricated observations. These tests never call the native runner,
// cancellation API, a VM API, or an image/accessor executable.
final class GuestResultVerifierTests: XCTestCase {
    private let runID = "guest-result-verifier-fixture"
    private let kinds = ["start", "observation", "terminal"]
    private let zeroStatusKeys = [
        "failure_stage", "first_error", "signing_error", "vm_create", "vcpu_create",
        "register", "run", "read_register", "vcpu_destroy", "vm_destroy",
        "watchdog_create", "watchdog_join", "map_code", "map_request", "map_reply",
        "unmap_code", "unmap_request", "unmap_reply", "host_unmap_code",
        "host_unmap_request", "host_unmap_reply"
    ]

    private var image: Data {
        let words: [UInt32] = [
            0xd2880000, 0xf2a20000, 0xd2900001, 0xf2a20001, 0xd2980003, 0xf2a20003,
            0xc8dffc04, 0xf100049f, 0x540001c1, 0xf9400405, 0xf10004bf, 0x54000161,
            0xf9400806, 0xf9400c07, 0x8b0700c6, 0xf9000425, 0xf9000826, 0xf9000c3f,
            0xc89ffc24, 0xd5033f9f, 0xb9000064, 0xd43bd5a0, 0xd42175a0
        ]
        return Data(words.flatMap { word in
            (0..<4).map { UInt8(truncatingIfNeeded: word >> ($0 * 8)) }
        })
    }

    private func bytes(_ hex: String) -> Data {
        let characters = Array(hex.utf8)
        func nibble(_ value: UInt8) -> UInt8 { value <= 57 ? value - 48 : value - 87 }
        return Data(stride(from: 0, to: characters.count, by: 2).map {
            (nibble(characters[$0]) << 4) | nibble(characters[$0 + 1])
        })
    }

    private func fixture() throws -> [[String: GuestCBORValue]] {
        let commitment = try MerkleGenesis.commit(GuestContract.snapshotLeaves(
            image: image, request: GuestContract.request, reply: GuestContract.reply))
        let start: [String: GuestCBORValue] = [
            "guest_image": .bytes(image), "guest_sha256": .text(GuestContract.expectedGuestSHA256),
            "request": .bytes(GuestContract.request), "expected_reply": .bytes(GuestContract.reply),
            "load_ipa": .unsigned(0x10000000), "doorbell_instruction_offset": .unsigned(80),
            "host_bundle": .text("com.ergentics.provenance"),
            "scope": .text("fabricated pure verifier fixture; not guest execution")
        ]
        var observation: [String: GuestCBORValue] = [:]
        for key in ["abi_version", "outcome", "execution_pass", "teardown_pass", "signing_admitted",
                    "run_entries", "vcpu_created", "request_unchanged", "reply_valid", "code_unchanged",
                    "trap_valid", "snapshot_sealed", "exception_reason"] {
            observation[key] = .unsigned(1)
        }
        for key in ["cancellation_requested", "cancellation_calls", "watchdog_fired", "resources_quarantined"] {
            observation[key] = .unsigned(0)
        }
        let words: [String: UInt64] = [
            "mappings_entered": 3, "register_calls": 36, "read_register_calls": 4,
            "pc": 0x10000050, "fault_ipa": 0x1000c000, "fault_virtual_address": 0x1000c000,
            "x4": 1, "sctlr_el1": 0x30d00800, "cpsr": 0x3c5, "syndrome": 0x93840046,
            "start_ticks": 100, "entry_ticks": 200, "exit_ticks": 300,
            "snapshot_ticks": 310, "end_ticks": 350, "deadline_ticks": 48_000_150,
            "timebase_numer": 125, "timebase_denom": 3
        ]
        for (key, value) in words { observation[key] = .unsigned(value) }
        var statuses = Dictionary(uniqueKeysWithValues: zeroStatusKeys.map { ($0, GuestCBORValue.text("0")) })
        statuses["cancellation"] = .text(String(Int32.min))
        statuses["watchdog_wait"] = .text("0")
        observation["native_status_decimal"] = .map(statuses)
        observation["request"] = .bytes(GuestContract.request)
        observation["reply"] = .bytes(GuestContract.reply)
        observation["guest_sha256"] = .text(GuestContract.expectedGuestSHA256)
        observation["snapshot_merkle"] = .bytes(bytes(commitment.root))
        observation["independent_snapshot_pass"] = .bool(true)
        let terminal: [String: GuestCBORValue] = [
            "status": .text("PASS"), "execution_pass": .bool(true), "teardown_pass": .bool(true),
            "independent_snapshot_pass": .bool(true), "resources_quarantined": .bool(false),
            "snapshot_merkle": .text(commitment.root), "detail": .text("fabricated fixture"),
            "elapsed": .text("250 ticks × 125/3 ns"), "energy": .text("unmeasured; ergs unavailable"),
            "gate_e": .text("ABSTAIN"), "authority_vector": .text("00000000")
        ]
        return [start, observation, terminal]
    }

    private func events(_ payloads: [[String: GuestCBORValue]],
                        transform: ((Int, inout [String: GuestCBORValue]) -> Void)? = nil) throws -> [GuestJournalEvent] {
        var result: [GuestJournalEvent] = []
        for (index, payload) in payloads.enumerated() {
            let parent = result.last?.digest
            let kind = kinds[index]
            var envelope: [String: GuestCBORValue] = [
                "schema": .text(GuestJournal.schema), "run_id": .text(runID),
                "sequence": .unsigned(UInt64(index)), "kind": .text(kind),
                "parent": .bytes(parent.map(bytes) ?? Data()), "payload": .map(payload)
            ]
            transform?(index, &envelope)
            let encoded = try GuestCBOR.encode(.map(envelope))
            result.append(GuestJournalEvent(runID: runID, sequence: index, kind: kind,
                payload: encoded, digest: GuestContract.hash(encoded), parent: parent))
        }
        return result
    }

    private func verify(_ payloads: [[String: GuestCBORValue]]) throws -> VerifiedGuestResult {
        try GuestResultVerifier.verify(runID: runID, events: events(payloads))
    }

    private func setStatus(_ key: String, _ value: String, in payloads: inout [[String: GuestCBORValue]]) {
        guard case .map(var statuses) = payloads[1]["native_status_decimal"] else { return XCTFail("Fixture status map missing") }
        statuses[key] = .text(value)
        payloads[1]["native_status_decimal"] = .map(statuses)
    }

    private func syncElapsed(in payloads: inout [[String: GuestCBORValue]]) {
        func word(_ key: String) -> UInt64 {
            if case .unsigned(let value) = payloads[1][key] { return value }; return 0
        }
        let begin = word("start_ticks"), end = word("end_ticks")
        payloads[2]["elapsed"] = .text("\(end >= begin ? end - begin : 0) ticks × \(word("timebase_numer"))/\(word("timebase_denom")) ns")
    }

    func testExactPureFixturePassesWithoutExecutingGuest() throws {
        XCTAssertEqual(image.count, 92)
        XCTAssertEqual(GuestContract.hash(image), GuestContract.expectedGuestSHA256)
        let value = try verify(fixture())
        XCTAssertEqual(value.status, "PASS")
        XCTAssertEqual(value.root.count, 64)
        XCTAssertEqual(value.elapsed, "250 ticks × 125/3 ns")
        XCTAssertFalse(value.quarantined)
    }

    func testStartAndObservationPrefixesRemainIncomplete() throws {
        let complete = try events(fixture())
        for count in 1...2 {
            let value = try GuestResultVerifier.verify(runID: runID, events: Array(complete.prefix(count)))
            XCTAssertEqual(value.status, "INCOMPLETE")
            XCTAssertTrue(value.root.isEmpty)
        }
    }

    func testRejectsEmptyAndOverlongEventSequences() throws {
        XCTAssertThrowsError(try GuestResultVerifier.verify(runID: runID, events: []))
        let complete = try events(fixture())
        XCTAssertThrowsError(try GuestResultVerifier.verify(runID: runID, events: complete + [complete[2]]))
    }

    func testRejectsOrderAndProjectedRunOrSequenceMismatch() throws {
        let complete = try events(fixture())
        XCTAssertThrowsError(try GuestResultVerifier.verify(runID: runID, events: [complete[1], complete[0], complete[2]]))
        let first = complete[0]
        let otherRun = GuestJournalEvent(runID: "another-run", sequence: 0, kind: first.kind,
            payload: first.payload, digest: first.digest, parent: first.parent)
        XCTAssertThrowsError(try GuestResultVerifier.verify(runID: runID, events: [otherRun] + Array(complete.dropFirst())))
        let wrongSequence = GuestJournalEvent(runID: runID, sequence: 7, kind: first.kind,
            payload: first.payload, digest: first.digest, parent: first.parent)
        XCTAssertThrowsError(try GuestResultVerifier.verify(runID: runID, events: [wrongSequence] + Array(complete.dropFirst())))
    }

    func testRejectsFullEnvelopeProjectionMismatch() throws {
        let payloads = try fixture()
        let changes: [(String, GuestCBORValue)] = [
            ("schema", .text("another-schema")), ("run_id", .text("another-run")),
            ("sequence", .unsigned(7)), ("kind", .text("terminal")), ("parent", .bytes(Data([1])))
        ]
        for (key, value) in changes {
            let altered = try events(payloads) { index, envelope in if index == 0 { envelope[key] = value } }
            XCTAssertThrowsError(try GuestResultVerifier.verify(runID: runID, events: altered), key)
        }
    }

    func testRejectsDigestAndParentProjectionCorruption() throws {
        var complete = try events(fixture())
        let original = complete[1]
        complete[1] = GuestJournalEvent(runID: runID, sequence: 1, kind: original.kind,
            payload: original.payload, digest: String(repeating: "0", count: 64), parent: original.parent)
        XCTAssertThrowsError(try GuestResultVerifier.verify(runID: runID, events: complete))
        complete[1] = GuestJournalEvent(runID: runID, sequence: 1, kind: original.kind,
            payload: original.payload, digest: original.digest, parent: String(repeating: "0", count: 64))
        XCTAssertThrowsError(try GuestResultVerifier.verify(runID: runID, events: complete))
    }

    func testRejectsPassProseOverRawExecutionFailure() throws {
        var payloads = try fixture()
        payloads[1]["execution_pass"] = .unsigned(0)
        payloads[2]["execution_pass"] = .bool(false)
        XCTAssertThrowsError(try verify(payloads))
    }

    func testRejectsFailProseOverCompletePassData() throws {
        var payloads = try fixture()
        payloads[2]["status"] = .text("FAIL")
        XCTAssertThrowsError(try verify(payloads))
    }

    func testRejectsTerminalProjectionAndAuthorityPromotion() throws {
        let cases: [(String, GuestCBORValue)] = [
            ("execution_pass", .bool(false)), ("teardown_pass", .bool(false)),
            ("resources_quarantined", .bool(true)), ("independent_snapshot_pass", .bool(false)),
            ("gate_e", .text("PASS")), ("authority_vector", .text("10000000"))
        ]
        for (key, value) in cases {
            var payloads = try fixture(); payloads[2][key] = value
            XCTAssertThrowsError(try verify(payloads), key)
        }
    }

    func testRejectsChangedPinnedImageAndDeclaredInput() throws {
        for key in ["guest_image", "request", "expected_reply", "guest_sha256"] {
            var payloads = try fixture()
            payloads[0][key] = key == "guest_sha256" ? .text(String(repeating: "0", count: 64)) : .bytes(Data([0]))
            XCTAssertThrowsError(try verify(payloads), key)
        }
    }

    func testMerkleCommitmentCannotMakeWrongArithmeticValid() throws {
        var payloads = try fixture()
        let wrongReply = GuestContract.frame([1, 1, 43, 0])
        let commitment = try MerkleGenesis.commit(GuestContract.snapshotLeaves(
            image: image, request: GuestContract.request, reply: wrongReply))
        payloads[1]["reply"] = .bytes(wrongReply)
        payloads[1]["snapshot_merkle"] = .bytes(bytes(commitment.root))
        payloads[2]["snapshot_merkle"] = .text(commitment.root)
        XCTAssertThrowsError(try verify(payloads))
    }

    func testRejectsTerminalRootAndReconstructedRootMismatch() throws {
        var payloads = try fixture()
        payloads[2]["snapshot_merkle"] = .text(String(repeating: "0", count: 64))
        XCTAssertThrowsError(try verify(payloads))
        payloads[1]["snapshot_merkle"] = .bytes(Data(repeating: 0, count: 32))
        XCTAssertThrowsError(try verify(payloads))
    }

    func testRejectsEveryNonzeroRequiredRawSuccessStatus() throws {
        for key in zeroStatusKeys {
            var payloads = try fixture(); setStatus(key, "-1", in: &payloads)
            XCTAssertThrowsError(try verify(payloads), key)
        }
        var payloads = try fixture(); setStatus("cancellation", "0", in: &payloads)
        XCTAssertThrowsError(try verify(payloads))
    }

    func testRejectsUnreportedOrFailedWatchdogWaitOnPass() throws {
        var payloads = try fixture(); setStatus("watchdog_wait", "22", in: &payloads)
        XCTAssertThrowsError(try verify(payloads))
        guard case .map(var statuses) = payloads[1]["native_status_decimal"] else { return XCTFail("Missing fixture statuses") }
        statuses.removeValue(forKey: "watchdog_wait")
        payloads[1]["native_status_decimal"] = .map(statuses)
        XCTAssertThrowsError(try verify(payloads))
    }

    func testWatchdogNeedNotHaveEnteredWaitBeforeFastCompletion() throws {
        var payloads = try fixture(); setStatus("watchdog_wait", String(Int32.min), in: &payloads)
        XCTAssertEqual(try verify(payloads).status, "PASS")
    }

    func testRejectsMissingCountsAndBadTrapFields() throws {
        for key in ["register_calls", "read_register_calls", "mappings_entered"] {
            var payloads = try fixture(); payloads[1].removeValue(forKey: key)
            XCTAssertThrowsError(try verify(payloads), key)
        }
        for key in ["pc", "fault_ipa", "fault_virtual_address", "x4", "sctlr_el1", "cpsr", "syndrome"] {
            var payloads = try fixture(); payloads[1][key] = .unsigned(0)
            XCTAssertThrowsError(try verify(payloads), key)
        }
    }

    func testRejectsInvalidTimingEvenWithMatchingDisplayText() throws {
        let cases: [(String, UInt64)] = [
            ("start_ticks", 0), ("entry_ticks", 301), ("snapshot_ticks", 299),
            ("end_ticks", 309), ("deadline_ticks", 299), ("timebase_numer", 0), ("timebase_denom", 0)
        ]
        for (key, value) in cases {
            var payloads = try fixture(); payloads[1][key] = .unsigned(value); syncElapsed(in: &payloads)
            XCTAssertThrowsError(try verify(payloads), key)
        }
    }

    func testRejectsRationalTimeDisplayDrift() throws {
        var payloads = try fixture()
        payloads[2]["elapsed"] = .text("250 nanoseconds")
        XCTAssertThrowsError(try verify(payloads))
    }

    func testRejectsExpandedDeadlineAndOutOfNativeRangeTimebase() throws {
        var payloads = try fixture()
        payloads[1]["deadline_ticks"] = .unsigned(48_000_201)
        XCTAssertThrowsError(try verify(payloads))
        for key in ["timebase_numer", "timebase_denom"] {
            payloads = try fixture()
            payloads[1][key] = .unsigned(UInt64(UInt32.max) + 1)
            syncElapsed(in: &payloads)
            XCTAssertThrowsError(try verify(payloads), key)
        }
    }

    func testRejectsInventedCancellationClassification() throws {
        var payloads = try fixture()
        payloads[1]["outcome"] = .unsigned(2)
        payloads[1]["execution_pass"] = .unsigned(0)
        payloads[2]["execution_pass"] = .bool(false)
        payloads[2]["status"] = .text("CANCELED")
        XCTAssertThrowsError(try verify(payloads))
    }

    func testAcceptsCoherentCancellationWithoutPromotingPass() throws {
        var payloads = try fixture()
        payloads[1]["outcome"] = .unsigned(3)
        payloads[1]["execution_pass"] = .unsigned(0)
        payloads[1]["cancellation_requested"] = .unsigned(1)
        payloads[1]["cancellation_calls"] = .unsigned(1)
        setStatus("cancellation", "0", in: &payloads)
        setStatus("failure_stage", "18", in: &payloads)
        setStatus("first_error", "89", in: &payloads)
        payloads[2]["execution_pass"] = .bool(false)
        payloads[2]["status"] = .text("CANCELED")
        XCTAssertEqual(try verify(payloads).status, "CANCELED")
    }

    func testPreservesFailedTeardownQuarantineSeparatelyFromExecution() throws {
        var payloads = try fixture()
        payloads[1]["outcome"] = .unsigned(2)
        payloads[1]["teardown_pass"] = .unsigned(0)
        payloads[1]["resources_quarantined"] = .unsigned(1)
        setStatus("failure_stage", "16", in: &payloads)
        setStatus("first_error", "-1", in: &payloads)
        setStatus("vm_destroy", "-1", in: &payloads)
        payloads[2]["status"] = .text("FAIL")
        payloads[2]["teardown_pass"] = .bool(false)
        payloads[2]["resources_quarantined"] = .bool(true)
        let result = try verify(payloads)
        XCTAssertEqual(result.status, "FAIL")
        XCTAssertTrue(result.quarantined)
        XCTAssertEqual(result.root.count, 64)
    }
}
