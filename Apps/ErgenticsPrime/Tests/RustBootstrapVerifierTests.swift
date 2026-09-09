import CryptoKit
import Foundation
import XCTest

// Fabricated byte fixtures only. No native helper, guest, filesystem, process,
// image accessor or cancellation API is called by this test class.
final class RustBootstrapVerifierTests: XCTestCase {
    private let runID = "rust-bootstrap-pure-fixture"
    private let kinds = ["start", "observation", "terminal"]
    private let baselineStatuses = [
        "failure_stage", "first_error", "signing_error", "vm_create", "vcpu_create",
        "register", "run", "read_register", "vcpu_destroy", "vm_destroy",
        "watchdog_create", "watchdog_join", "map_code", "map_request", "map_reply",
        "unmap_code", "unmap_request", "unmap_reply", "host_unmap_code",
        "host_unmap_request", "host_unmap_reply"
    ]
    private let rustStatuses = ["map_stack", "unmap_stack", "host_unmap_stack", "entry_sp", "exit_sp"]

    private func littleWords(_ values: [UInt64]) -> Data {
        Data(values.flatMap { value in (0..<8).map { UInt8(truncatingIfNeeded: value >> ($0 * 8)) } })
    }

    private func instructions(_ values: [UInt32]) -> Data {
        Data(values.flatMap { value in (0..<4).map { UInt8(truncatingIfNeeded: value >> ($0 * 8)) } })
    }

    private var rustImage: Data {
        // Independent literal transcription of the retained 41-word image.
        instructions([
            0xd2880009, 0xf2a20029, 0x9100013f, 0xaa1f03fd, 0xaa1f03fe,
            0xd2880009, 0xf2a20009, 0xc8dffd20, 0xf9400521, 0xf9400922,
            0xf9400d23, 0x94000014, 0xf100a81f, 0x540001c1, 0xd2900001,
            0xf2a20001, 0xd2980003, 0xf2a20003, 0xd2800024, 0xf9000424,
            0xf9000820, 0xf9000c3f, 0xc89ffc24, 0xd5033f9f, 0xb9000064,
            0xd43bd5a0, 0x14000000, 0xd42175a0, 0x14000000, 0xd42175e0,
            0x14000000, 0xa9bf7bfd, 0xf1005c7f, 0x52800548, 0x910003fd,
            0xfa530840, 0xfa410820, 0xfa410800, 0x9a9f0100, 0xa8c17bfd,
            0xd65f03c0
        ])
    }

    private var legacyImage: Data {
        instructions([
            0xd2880000, 0xf2a20000, 0xd2900001, 0xf2a20001, 0xd2980003, 0xf2a20003,
            0xc8dffc04, 0xf100049f, 0x540001c1, 0xf9400405, 0xf10004bf, 0x54000161,
            0xf9400806, 0xf9400c07, 0x8b0700c6, 0xf9000425, 0xf9000826, 0xf9000c3f,
            0xc89ffc24, 0xd5033f9f, 0xb9000064, 0xd43bd5a0, 0xd42175a0
        ])
    }

    private func bytes(_ hex: String) -> Data {
        let digits = Array(hex.utf8)
        func nibble(_ value: UInt8) -> UInt8 { value <= 57 ? value - 48 : value - 87 }
        return Data(stride(from: 0, to: digits.count, by: 2).map {
            nibble(digits[$0]) << 4 | nibble(digits[$0 + 1])
        })
    }

    private func fixture(rust: Bool = true) throws -> [[String: GuestCBORValue]] {
        let image = rust ? rustImage : legacyImage
        let imageHash = rust ? RustBootstrapContract.expectedGuestSHA256 : GuestContract.expectedGuestSHA256
        var start: [String: GuestCBORValue] = [
            "guest_image": .bytes(image), "guest_sha256": .text(imageHash),
            "request": .bytes(GuestContract.request), "expected_reply": .bytes(GuestContract.reply),
            "load_ipa": .unsigned(0x10000000), "doorbell_instruction_offset": .unsigned(rust ? 96 : 80),
            "host_bundle": .text("com.ergentics.provenance"),
            "scope": .text("fabricated fixture, not a guest execution")
        ]
        var observation: [String: GuestCBORValue] = [:]
        for key in ["outcome", "execution_pass", "teardown_pass", "signing_admitted", "run_entries",
                    "vcpu_created", "request_unchanged", "reply_valid", "code_unchanged", "trap_valid",
                    "snapshot_sealed", "exception_reason"] { observation[key] = .unsigned(1) }
        for key in ["cancellation_requested", "cancellation_calls", "watchdog_fired", "resources_quarantined"] {
            observation[key] = .unsigned(0)
        }
        let numbers: [String: UInt64] = [
            "abi_version": rust ? 2 : 1, "mappings_entered": rust ? 4 : 3,
            "register_calls": 36, "read_register_calls": rust ? 6 : 4,
            "pc": rust ? 0x10000060 : 0x10000050, "fault_ipa": 0x1000c000,
            "fault_virtual_address": 0x1000c000, "x4": 1, "sctlr_el1": 0x30d00800,
            "cpsr": 0x3c5, "syndrome": 0x93840046, "start_ticks": 100,
            "entry_ticks": 200, "exit_ticks": 300, "snapshot_ticks": 310,
            "end_ticks": 350, "deadline_ticks": 48_000_150, "timebase_numer": 125,
            "timebase_denom": 3
        ]
        for (key, value) in numbers { observation[key] = .unsigned(value) }
        var statuses = Dictionary(uniqueKeysWithValues: (baselineStatuses + (rust ? rustStatuses : [])).map {
            ($0, GuestCBORValue.text("0"))
        })
        statuses["cancellation"] = .text(String(Int32.min))
        statuses["watchdog_wait"] = .text("0")
        observation["native_status_decimal"] = .map(statuses)
        observation["request"] = .bytes(GuestContract.request)
        observation["reply"] = .bytes(GuestContract.reply)
        observation["guest_sha256"] = .text(imageHash)
        observation["independent_snapshot_pass"] = .bool(true)
        var terminal: [String: GuestCBORValue] = [
            "status": .text("PASS"), "execution_pass": .bool(true), "teardown_pass": .bool(true),
            "independent_snapshot_pass": .bool(true), "resources_quarantined": .bool(false),
            "detail": .text("fabricated fixture"), "elapsed": .text("250 ticks × 125/3 ns"),
            "energy": .text("unmeasured; ergs unavailable"), "gate_e": .text("ABSTAIN"),
            "authority_vector": .text("00000000")
        ]
        if rust {
            start["snapshot_schema"] = .text(RustBootstrapContract.schema)
            observation["stack_valid"] = .unsigned(1)
            observation["entry_sp"] = .unsigned(RustBootstrapContract.entrySP)
            observation["exit_sp"] = .unsigned(RustBootstrapContract.exitSP)
            observation["stack_frame"] = .bytes(RustBootstrapContract.stackFrame)
            start["profile"] = .text(RustBootstrapContract.profile)
            observation["profile"] = .text(RustBootstrapContract.profile)
            terminal["profile"] = .text(RustBootstrapContract.profile)
            start["memory_contract"] = .bytes(RustBootstrapContract.memoryContract)
            observation["memory_contract"] = .bytes(RustBootstrapContract.memoryContract)
            terminal["memory_contract"] = .bytes(RustBootstrapContract.memoryContract)
        }
        var payloads = [start, observation, terminal]
        try reseal(&payloads, rust: rust)
        return payloads
    }

    private func reseal(_ payloads: inout [[String: GuestCBORValue]], rust: Bool = true) throws {
        guard case .bytes(let image) = payloads[0]["guest_image"],
              case .bytes(let request) = payloads[1]["request"],
              case .bytes(let reply) = payloads[1]["reply"] else { return XCTFail("Malformed test fixture") }
        let leaves: [GenesisLeaf]
        if rust {
            guard case .bytes(let memory) = payloads[1]["memory_contract"],
                  case .bytes(let frame) = payloads[1]["stack_frame"] else { return XCTFail("Malformed Rust fixture") }
            leaves = RustBootstrapContract.snapshotLeaves(image: image, request: request,
                reply: reply, memoryContract: memory, stackFrame: frame)
        } else { leaves = GuestContract.snapshotLeaves(image: image, request: request, reply: reply) }
        let commitment = try MerkleGenesis.commit(leaves)
        payloads[1]["snapshot_merkle"] = .bytes(bytes(commitment.root))
        payloads[2]["snapshot_merkle"] = .text(commitment.root)
    }

    private func events(_ payloads: [[String: GuestCBORValue]]) throws -> [GuestJournalEvent] {
        var result: [GuestJournalEvent] = []
        for (index, payload) in payloads.enumerated() {
            let parent = result.last?.digest
            let envelope: [String: GuestCBORValue] = [
                "schema": .text(GuestJournal.schema), "run_id": .text(runID),
                "sequence": .unsigned(UInt64(index)), "kind": .text(kinds[index]),
                "parent": .bytes(parent.map(bytes) ?? Data()), "payload": .map(payload)
            ]
            let frame = try GuestCBOR.encode(.map(envelope))
            result.append(GuestJournalEvent(runID: runID, sequence: index, kind: kinds[index],
                payload: frame, digest: GuestContract.hash(frame), parent: parent))
        }
        return result
    }

    private func verify(_ payloads: [[String: GuestCBORValue]]) throws -> VerifiedGuestResult {
        try GuestResultVerifier.verify(runID: runID, events: events(payloads))
    }

    private func status(_ key: String, _ value: GuestCBORValue?, in payloads: inout [[String: GuestCBORValue]]) {
        guard case .map(var values) = payloads[1]["native_status_decimal"] else { return XCTFail("Missing status fixture") }
        values[key] = value
        payloads[1]["native_status_decimal"] = .map(values)
    }

    func testExactRustFixtureAndIndependentBytePins() throws {
        XCTAssertEqual(rustImage.count, 164)
        XCTAssertEqual(GuestContract.hash(rustImage), "6e1b2a92646a69ef353491b2cde8104c6d6f311bc4d03bb8cb3bd5bb28f4dfa1")
        XCTAssertEqual(RustBootstrapContract.memoryContract, littleWords([
            268435456, 16384, 5, 268451840, 16384, 1, 268468224, 16384,
            3, 268500992, 16384, 3, 268484608, 96, 268517376, 16
        ]))
        XCTAssertEqual(RustBootstrapContract.memoryContract.count, 128)
        XCTAssertEqual(RustBootstrapContract.stackFrame, littleWords([0, 0x10000030]))
        let result = try verify(fixture())
        XCTAssertEqual(result.status, "PASS")
        XCTAssertEqual(result.elapsed, "250 ticks × 125/3 ns")
        XCTAssertFalse(result.quarantined)
    }

    func testSixLeafOddParentFramingIsIndependentlyReconstructed() throws {
        let leaves = RustBootstrapContract.snapshotLeaves(image: rustImage,
            request: GuestContract.request, reply: GuestContract.reply,
            memoryContract: RustBootstrapContract.memoryContract, stackFrame: RustBootstrapContract.stackFrame)
        XCTAssertEqual(leaves.map(\.label), ["guest_image", "memory_contract", "reply", "request", "schema", "stack_frame"])
        func big(_ value: UInt64, _ width: Int) -> Data {
            Data((0..<width).reversed().map { UInt8(truncatingIfNeeded: value >> ($0 * 8)) })
        }
        func hash(_ value: Data) -> Data { Data(SHA256.hash(data: value)) }
        let nodes = leaves.map { leaf -> Data in
            let label = Data(leaf.label.utf8)
            return hash(Data([0]) + big(UInt64(label.count), 4) + label + big(UInt64(leaf.payload.count), 8) + leaf.payload)
        }
        let parents = [hash(Data([1]) + nodes[0] + nodes[1]), hash(Data([1]) + nodes[2] + nodes[3]),
                       hash(Data([1]) + nodes[4] + nodes[5])]
        let top = hash(Data([1]) + hash(Data([1]) + parents[0] + parents[1]) + hash(Data([3]) + parents[2]))
        let expected = hash(Data([2]) + big(6, 8) + top).map { String(format: "%02x", $0) }.joined()
        // Concordance with actual production C seal helpers invoked on
        // FABRICATED host data by NativeSnapshotCheck.c; not a guest result.
        // Retained native-hash-result.json reports zero guest entries.
        XCTAssertEqual(expected, "f30c5b950a5ee19fab3dc1d6a828cc6c0c41fb64460c06ca455951dd0c631366")
        XCTAssertEqual(try MerkleGenesis.commit(leaves).root, expected)
        XCTAssertTrue(try RustBootstrapContract.validateSnapshot(image: rustImage, request: GuestContract.request,
            reply: GuestContract.reply, memoryContract: RustBootstrapContract.memoryContract,
            stackFrame: RustBootstrapContract.stackFrame, expectedRoot: expected))
        var changedFrame = RustBootstrapContract.stackFrame
        changedFrame[0] ^= 1
        let changedLeaves = RustBootstrapContract.snapshotLeaves(image: rustImage,
            request: GuestContract.request, reply: GuestContract.reply,
            memoryContract: RustBootstrapContract.memoryContract, stackFrame: changedFrame)
        let changedNativeRoot = "737f73bcfca5efdd1c53f9cd93a857f9437223d9c26a2db1abb15f92a3d747a6"
        XCTAssertEqual(try MerkleGenesis.commit(changedLeaves).root, changedNativeRoot)
        XCTAssertTrue(try MerkleGenesis.verify(changedLeaves, expectedRoot: changedNativeRoot))
        // A matching commitment of the wrong frame still cannot pass policy.
        XCTAssertFalse(try RustBootstrapContract.validateSnapshot(image: rustImage,
            request: GuestContract.request, reply: GuestContract.reply,
            memoryContract: RustBootstrapContract.memoryContract, stackFrame: changedFrame,
            expectedRoot: changedNativeRoot))
    }

    func testLegacyBaselineAndLegacyPrefixesRemainReadable() throws {
        XCTAssertEqual(legacyImage.count, 92)
        XCTAssertEqual(GuestContract.hash(legacyImage), GuestContract.expectedGuestSHA256)
        let old = try fixture(rust: false)
        XCTAssertEqual(try verify(old).status, "PASS")
        // Same fabricated-host native-helper check, preserving the four-leaf
        // baseline's historical framing independently of the Rust profile.
        XCTAssertEqual(try verify(old).root, "37b6aa19da562bf99810c8169e091357bc4e789a82b50366e0752ffb1a9d89df")
        for count in 1...2 { XCTAssertEqual(try verify(Array(old.prefix(count))).status, "INCOMPLETE") }
    }

    func testTypedPrefixesStayIncompleteButCannotHideMismatchedProfiles() throws {
        let good = try fixture()
        for count in 1...2 { XCTAssertEqual(try verify(Array(good.prefix(count))).status, "INCOMPLETE") }
        var wrong = good
        wrong[1].removeValue(forKey: "profile")
        XCTAssertThrowsError(try verify(Array(wrong.prefix(2))))
        wrong = good; wrong[0].removeValue(forKey: "profile")
        XCTAssertThrowsError(try verify(Array(wrong.prefix(1))))
    }

    func testEveryEventRequiresExactProfileAndMemoryContract() throws {
        let profiles: [GuestCBORValue?] = [nil, .text("unknown.v1"), .bool(true)]
        let layouts: [GuestCBORValue?] = [nil, .bytes(Data()), .bytes(Data(repeating: 0, count: 128))]
        for index in 0..<3 {
            for replacement in profiles {
                var payloads = try fixture(); payloads[index]["profile"] = replacement
                XCTAssertThrowsError(try verify(payloads), "profile event \(index)")
            }
            for replacement in layouts {
                var payloads = try fixture(); payloads[index]["memory_contract"] = replacement
                XCTAssertThrowsError(try verify(payloads), "memory event \(index)")
            }
        }
    }

    func testStartSchemaAndOptionalRepeatedSchemaMustMatch() throws {
        let schemas: [GuestCBORValue?] = [nil, .text(GuestContract.schema), .unsigned(1)]
        for replacement in schemas {
            var payloads = try fixture(); payloads[0]["snapshot_schema"] = replacement
            XCTAssertThrowsError(try verify(payloads))
        }
        for index in 1...2 {
            var payloads = try fixture(); payloads[index]["snapshot_schema"] = .text(GuestContract.schema)
            XCTAssertThrowsError(try verify(payloads))
        }
    }

    func testUnknownProfileCannotBeRenamedToLegacy() throws {
        var payloads = try fixture()
        for index in 0..<3 { payloads[index]["profile"] = .text("baseline.v1") }
        XCTAssertThrowsError(try verify(payloads))
        for index in 0..<3 { payloads[index].removeValue(forKey: "profile") }
        XCTAssertThrowsError(try verify(payloads))
    }

    func testRustOnlyPayloadAndStatusMarkersCannotEnterLegacy() throws {
        let markers: [(String, GuestCBORValue)] = [
            ("memory_contract", .bytes(RustBootstrapContract.memoryContract)),
            ("stack_valid", .unsigned(1)), ("entry_sp", .unsigned(RustBootstrapContract.entrySP)),
            ("exit_sp", .unsigned(RustBootstrapContract.exitSP)), ("stack_frame", .bytes(RustBootstrapContract.stackFrame)),
            ("snapshot_schema", .text(RustBootstrapContract.schema))
        ]
        for (key, value) in markers {
            for index in 0..<3 {
                var payloads = try fixture(rust: false); payloads[index][key] = value
                XCTAssertThrowsError(try verify(payloads), key)
            }
        }
        for key in rustStatuses {
            var payloads = try fixture(rust: false); status(key, .text("0"), in: &payloads)
            XCTAssertThrowsError(try verify(payloads), key)
        }
    }

    func testCrossImageAndRehashedRootsCannotCrossProfiles() throws {
        var rust = try fixture(); rust[0]["guest_image"] = .bytes(legacyImage)
        try reseal(&rust); XCTAssertThrowsError(try verify(rust))
        var legacy = try fixture(rust: false); legacy[0]["guest_image"] = .bytes(rustImage)
        try reseal(&legacy, rust: false); XCTAssertThrowsError(try verify(legacy))
        rust = try fixture(); rust[0]["guest_sha256"] = .text(GuestContract.expectedGuestSHA256)
        XCTAssertThrowsError(try verify(rust))
        rust = try fixture(); rust[1]["guest_sha256"] = .text(GuestContract.expectedGuestSHA256)
        XCTAssertThrowsError(try verify(rust))
    }

    func testOldCountsAndOldOrWrongDoorbellCannotPassRust() throws {
        let changes: [(String, UInt64)] = [("abi_version", 1), ("mappings_entered", 3),
            ("register_calls", 35), ("read_register_calls", 4), ("pc", 0x10000050), ("pc", 0x10000064)]
        for (key, value) in changes {
            var payloads = try fixture(); payloads[1][key] = .unsigned(value)
            XCTAssertThrowsError(try verify(payloads), key)
        }
        var payloads = try fixture(); payloads[0]["doorbell_instruction_offset"] = .unsigned(80)
        XCTAssertThrowsError(try verify(payloads))
        for key in ["abi_version", "mappings_entered", "register_calls", "read_register_calls"] {
            payloads = try fixture(); payloads[1].removeValue(forKey: key)
            XCTAssertThrowsError(try verify(payloads), key)
        }
    }

    func testFullStackFlagIsRequiredIndependentlyOfValidFrameAndRoot() throws {
        let changes: [GuestCBORValue?] = [nil, .unsigned(0), .unsigned(2), .bool(true)]
        for value in changes {
            var payloads = try fixture(); payloads[1]["stack_valid"] = value
            XCTAssertThrowsError(try verify(payloads))
        }
    }

    func testBothStackPointersRequireExactTopAndUnsignedType() throws {
        let changes: [GuestCBORValue?] = [nil, .unsigned(0x10013ff0), .unsigned(0x1000bff0), .text("268517376")]
        for key in ["entry_sp", "exit_sp"] {
            for value in changes {
                var payloads = try fixture(); payloads[1][key] = value
                XCTAssertThrowsError(try verify(payloads), key)
            }
        }
    }

    func testStackShapeOrBytesRejectEvenWithFreshMerkleRoot() throws {
        for frame in [Data(), Data(repeating: 0, count: 16), Data(repeating: 0, count: 32),
                      littleWords([1, 0x10000030]), littleWords([0, 0x10000034])] {
            var payloads = try fixture(); payloads[1]["stack_frame"] = .bytes(frame)
            try reseal(&payloads); XCTAssertThrowsError(try verify(payloads))
        }
        var payloads = try fixture(); payloads[1].removeValue(forKey: "stack_frame")
        XCTAssertThrowsError(try verify(payloads))
    }

    func testAlteredMemoryLayoutCannotBeLegitimizedByResealing() throws {
        var memory = RustBootstrapContract.memoryContract
        memory[16] = 7 // Attempt to change the code mapping from RX to RWX.
        var payloads = try fixture()
        for index in 0..<3 { payloads[index]["memory_contract"] = .bytes(memory) }
        try reseal(&payloads); XCTAssertThrowsError(try verify(payloads))
    }

    func testEveryStackStatusRequiresEnteredExactZero() throws {
        let changes: [GuestCBORValue?] = [nil, .text(String(Int32.min)), .text("-1"), .text("00"), .unsigned(0)]
        for key in rustStatuses {
            for value in changes {
                var payloads = try fixture(); status(key, value, in: &payloads)
                XCTAssertThrowsError(try verify(payloads), key)
            }
        }
    }

    func testWrongRequestAndReplyCannotPassUnderNewRoots() throws {
        for key in ["request", "reply"] {
            var payloads = try fixture(); payloads[1][key] = .bytes(littleWords([1, 1, 43, 0]))
            try reseal(&payloads); XCTAssertThrowsError(try verify(payloads), key)
        }
    }

    func testTypedTerminalLabelsAndRootStillFollowRawData() throws {
        var payloads = try fixture(); payloads[2]["status"] = .text("FAIL")
        XCTAssertThrowsError(try verify(payloads))
        payloads = try fixture(); payloads[1]["execution_pass"] = .unsigned(0)
        payloads[2]["execution_pass"] = .bool(false)
        XCTAssertThrowsError(try verify(payloads))
        payloads = try fixture(); payloads[2]["snapshot_merkle"] = .text(String(repeating: "0", count: 64))
        XCTAssertThrowsError(try verify(payloads))
    }

    func testFailedRustStackTeardownPreservesQuarantineWithoutPass() throws {
        var payloads = try fixture()
        payloads[1]["outcome"] = .unsigned(2)
        payloads[1]["teardown_pass"] = .unsigned(0)
        payloads[1]["resources_quarantined"] = .unsigned(1)
        status("failure_stage", .text("16"), in: &payloads)
        status("first_error", .text("-1"), in: &payloads)
        status("host_unmap_stack", .text("-1"), in: &payloads)
        payloads[2]["status"] = .text("FAIL")
        payloads[2]["teardown_pass"] = .bool(false)
        payloads[2]["resources_quarantined"] = .bool(true)
        let value = try verify(payloads)
        XCTAssertEqual(value.status, "FAIL")
        XCTAssertTrue(value.quarantined)
    }
}
