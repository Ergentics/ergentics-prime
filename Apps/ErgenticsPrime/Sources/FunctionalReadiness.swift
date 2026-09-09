import CryptoKit
import Foundation

struct FunctionalReadinessCheck: Codable, Equatable, Sendable {
    enum ID: String, Codable, CaseIterable, Sendable {
        case cborUnsigned = "cbor.uint_known_answers"
        case cborMapOrder = "cbor.map_key_known_answer"
        case cborSignedStatus = "cbor.signed_status_known_answer"
        case cborNonminimal = "cbor.reject_nonminimal"
        case cborMalformed = "cbor.reject_malformed"
        case cborAmbiguousMaps = "cbor.reject_ambiguous_maps"
        case mailboxKnownAnswer = "mailbox.fixed_known_answer"
        case imagePin = "guest_image.literal_hash_pin"
        case merkleSingle = "merkle.single_leaf_known_answer"
        case merkleOdd = "merkle.odd_unary_known_answer"
        case merkleTamper = "merkle.reject_count_and_payload_tamper"
        case merkleInvalidLeaves = "merkle.reject_invalid_leaf_sets"
        case mailboxMutation = "mailbox.reject_rehashed_mutation"
        case verifierKnownAnswer = "verifier.synthetic_complete_known_answer"
        case verifierPrefix = "verifier.prefix_is_incomplete"
        case verifierProse = "verifier.reject_prose_pass"
        case verifierProjection = "verifier.reject_projection_and_profile"
    }
    enum Outcome: String, Codable, Sendable { case passed, failed }
    let id: ID
    let outcome: Outcome

    fileprivate init(id: ID, outcome: Outcome) { self.id = id; self.outcome = outcome }
    private enum CodingKeys: String, CodingKey { case id, outcome }
    init(from decoder: any Decoder) throws {
        try FunctionalReadinessWire.requireKeys(decoder, ["id", "outcome"])
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(ID.self, forKey: .id)
        outcome = try values.decode(Outcome.self, forKey: .outcome)
    }
}

/// A synthetic computation report, not proof that a guest, filesystem or native
/// owner ran. Decoding validates report consistency; it does not attest a prior
/// execution. Only run() performs these checks in the current process.
struct FunctionalReadinessResult: Codable, Equatable, Sendable {
    static let expectedSchema = "com.ergentics.provenance.functional-self-test.v1"
    static let expectedScope = "Synthetic in-memory known-answer and rejection checks of the 92-byte assembly baseline only, not the 164-byte Rust guest; no guest execution, native teardown, storage, host integrity or Gate E proof"
    static let maximumEncodedBytes = 16_384
    let schema: String
    let scope: String
    let guestExecuted: Bool
    let storageVerified: Bool
    let checks: [FunctionalReadinessCheck]

    var passed: Bool {
        schema == Self.expectedSchema && scope == Self.expectedScope &&
        !guestExecuted && !storageVerified &&
        checks.map(\.id) == FunctionalReadinessCheck.ID.allCases &&
        checks.allSatisfy { $0.outcome == .passed }
    }

    fileprivate init(checks: [FunctionalReadinessCheck]) {
        schema = Self.expectedSchema; scope = Self.expectedScope
        guestExecuted = false; storageVerified = false; self.checks = checks
    }

    private enum CodingKeys: String, CodingKey {
        case schema, scope, guestExecuted, storageVerified, checks, passed
    }
    init(from decoder: any Decoder) throws {
        try FunctionalReadinessWire.requireKeys(decoder,
            ["schema", "scope", "guestExecuted", "storageVerified", "checks", "passed"])
        let values = try decoder.container(keyedBy: CodingKeys.self)
        schema = try values.decode(String.self, forKey: .schema)
        scope = try values.decode(String.self, forKey: .scope)
        guestExecuted = try values.decode(Bool.self, forKey: .guestExecuted)
        storageVerified = try values.decode(Bool.self, forKey: .storageVerified)
        var sequence = try values.nestedUnkeyedContainer(forKey: .checks)
        var found: [FunctionalReadinessCheck] = []
        for expected in FunctionalReadinessCheck.ID.allCases {
            guard !sequence.isAtEnd else { throw FunctionalReadinessWire.invalid(decoder) }
            let check = try sequence.decode(FunctionalReadinessCheck.self)
            guard check.id == expected else { throw FunctionalReadinessWire.invalid(decoder) }
            found.append(check)
        }
        guard sequence.isAtEnd else { throw FunctionalReadinessWire.invalid(decoder) }
        checks = found
        let reportedPass = try values.decode(Bool.self, forKey: .passed)
        guard schema == Self.expectedSchema, scope == Self.expectedScope,
              !guestExecuted, !storageVerified, reportedPass == passed else {
            throw FunctionalReadinessWire.invalid(decoder)
        }
    }

    func encode(to encoder: any Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(schema, forKey: .schema)
        try values.encode(scope, forKey: .scope)
        try values.encode(guestExecuted, forKey: .guestExecuted)
        try values.encode(storageVerified, forKey: .storageVerified)
        try values.encode(checks, forKey: .checks)
        try values.encode(passed, forKey: .passed)
    }

    func encoded() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(self)
    }

    /// Closed bounded standalone frame admission. Canonical byte equality also
    /// rejects duplicate JSON keys, whitespace/trailing frames and aliases.
    static func decode(_ bytes: Data) throws -> Self {
        guard !bytes.isEmpty, bytes.count <= maximumEncodedBytes else {
            throw FunctionalReadinessWire.invalidFrame
        }
        let result = try JSONDecoder().decode(Self.self, from: bytes)
        guard try result.encoded() == bytes else { throw FunctionalReadinessWire.invalidFrame }
        return result
    }
}

private enum FunctionalReadinessWire {
    case invalidFrame
    struct Key: CodingKey {
        let stringValue: String
        var intValue: Int? { nil }
        init?(stringValue: String) { self.stringValue = stringValue }
        init?(intValue: Int) { return nil }
    }
    static func invalid(_ decoder: any Decoder) -> DecodingError {
        .dataCorrupted(.init(codingPath: decoder.codingPath,
            debugDescription: "Functional check manifest, scope or derived result rejected"))
    }
    static func requireKeys(_ decoder: any Decoder, _ expected: Set<String>) throws {
        let actual = try decoder.container(keyedBy: Key.self).allKeys.map(\.stringValue)
        guard Set(actual) == expected else { throw invalid(decoder) }
    }
}
extension FunctionalReadinessWire: Error {}

/// Zero-input pure self-test. No clock/environment reads, native accessor, VM,
/// AppKit, SQLite connection, file, subprocess, network, or imported receipt.
enum FunctionalReadiness {
    static func run() -> FunctionalReadinessResult {
        FunctionalReadinessResult(checks: FunctionalReadinessCheck.ID.allCases.map { id in
            let passed: Bool
            do { passed = try check(id) } catch { passed = false }
            return FunctionalReadinessCheck(id: id, outcome: passed ? .passed : .failed)
        })
    }

    // Literal vectors are copied from GuestJournalTests, HypervisorContractTests
    // and MerkleGenesisTests, not obtained from native code or runtime output.
    private static let request = Data([1,0,0,0,0,0,0,0, 1,0,0,0,0,0,0,0,
                                      19,0,0,0,0,0,0,0, 23,0,0,0,0,0,0,0])
    private static let reply = Data([1,0,0,0,0,0,0,0, 1,0,0,0,0,0,0,0,
                                    42,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0])
    private static let imageSHA = "67290a73b53047374096142356a35338f6722d724586cc10373dfecab9a4cc44"
    private static var image: Data {
        let words: [UInt32] = [0xd2880000,0xf2a20000,0xd2900001,0xf2a20001,
            0xd2980003,0xf2a20003,0xc8dffc04,0xf100049f,0x540001c1,0xf9400405,
            0xf10004bf,0x54000161,0xf9400806,0xf9400c07,0x8b0700c6,0xf9000425,
            0xf9000826,0xf9000c3f,0xc89ffc24,0xd5033f9f,0xb9000064,0xd43bd5a0,0xd42175a0]
        return Data(words.flatMap { word in (0..<4).map { UInt8(truncatingIfNeeded: word >> ($0 * 8)) } })
    }
    private static let schemaLeaf = GenesisLeaf(label: "schema", payload: Data("v1".utf8))
    private static let schemaLeafFrame = Data([0,0,0,0,6,0x73,0x63,0x68,0x65,0x6d,0x61,
                                               0,0,0,0,0,0,0,2,0x76,0x31])
    private static func hash(_ bytes: Data) -> Data { Data(SHA256.hash(data: bytes)) }
    private static func hex(_ bytes: Data) -> String { bytes.map { String(format: "%02x", $0) }.joined() }
    private static var singleRoot: String { hex(hash(Data([2,0,0,0,0,0,0,0,1]) + hash(schemaLeafFrame))) }
    // Independently framed four-leaf known answer. No Merkle/GuestContract
    // constructor supplies these labels, lengths, order, domains or payloads.
    private static var snapshotRootBytes: Data {
        let imageLeaf = hash(Data([0,0,0,0,11]) + Data("guest_image".utf8) + Data([0,0,0,0,0,0,0,92]) + image)
        let replyLeaf = hash(Data([0,0,0,0,5]) + Data("reply".utf8) + Data([0,0,0,0,0,0,0,32]) + reply)
        let requestLeaf = hash(Data([0,0,0,0,7]) + Data("request".utf8) + Data([0,0,0,0,0,0,0,32]) + request)
        let schema = hash(Data([0,0,0,0,6]) + Data("schema".utf8) + Data([0,0,0,0,0,0,0,38]) +
            Data("ergentics.hypervisor.guest.snapshot.v1".utf8))
        let left = hash(Data([1]) + imageLeaf + replyLeaf)
        let right = hash(Data([1]) + requestLeaf + schema)
        return hash(Data([2,0,0,0,0,0,0,0,4]) + hash(Data([1]) + left + right))
    }
    private static func rejects(_ body: () throws -> Void) -> Bool {
        do { try body(); return false } catch { return true }
    }

    private static func check(_ id: FunctionalReadinessCheck.ID) throws -> Bool {
        switch id {
        case .cborUnsigned:
            let vectors: [(UInt64, [UInt8])] = [(0,[0]), (23,[23]), (24,[0x18,24]),
                (255,[0x18,255]), (256,[0x19,1,0]), (65_535,[0x19,255,255]),
                (65_536,[0x1a,0,1,0,0]), (4_294_967_296,[0x1b,0,0,0,1,0,0,0,0]),
                (UInt64.max,[0x1b,255,255,255,255,255,255,255,255])]
            return try vectors.allSatisfy { value, bytes in
                try GuestCBOR.encode(.unsigned(value)) == Data(bytes) && GuestCBOR.decode(Data(bytes)) == .unsigned(value)
            }
        case .cborMapOrder:
            let value = GuestCBORValue.map(["b": .unsigned(1), "aa": .unsigned(2), "a": .unsigned(3)])
            let bytes = Data([0xa3,0x61,0x61,3,0x61,0x62,1,0x62,0x61,0x61,2])
            return try GuestCBOR.encode(value) == bytes && GuestCBOR.decode(bytes) == value
        case .cborSignedStatus:
            let bytes = Data([0x6b]) + Data("-2147483648".utf8)
            return try GuestCBOR.encode(.text(String(Int32.min))) == bytes &&
                GuestCBOR.decode(bytes) == .text("-2147483648") &&
                GuestCBOR.encode(.text("-1")) == Data([0x62,0x2d,0x31])
        case .cborNonminimal:
            let frames: [[UInt8]] = [[0x18,0], [0x19,0,24], [0x58,0], [0x78,1,0x61], [0x98,0]]
            return frames.allSatisfy { bytes in
                rejects { _ = try GuestCBOR.decode(Data(bytes)) }
            }
        case .cborMalformed:
            let frames: [[UInt8]] = [[], [0x19,1], [0x43,1,2], [0x61,0xff],
                [0,0], [0x9f,0xff], [0x20], [0xf6], [0xf9,0,0], [0xc0,0]]
            return frames.allSatisfy { bytes in rejects { _ = try GuestCBOR.decode(Data(bytes)) } }
        case .cborAmbiguousMaps:
            let frames: [[UInt8]] = [[0xa2,0x61,0x61,0,0x61,0x61,1],
                [0xa2,0x61,0x62,0,0x61,0x61,1], [0xa1,0,1],
                [0xa2,0x62,0xc3,0xa9,0,0x63,0x65,0xcc,0x81,1]]
            return frames.allSatisfy { bytes in rejects { _ = try GuestCBOR.decode(Data(bytes)) } }
        case .mailboxKnownAnswer:
            let sum = UInt64(19).addingReportingOverflow(23)
            return request.count == 32 && reply.count == 32 && !sum.overflow && sum.partialValue == 42 &&
                GuestContract.request == request && GuestContract.reply == reply &&
                GuestContract.frame([1,1,19,23]) == request && GuestContract.frame([1,1,42,0]) == reply
        case .imagePin:
            return image.count == 92 && GuestContract.hash(image) == imageSHA &&
                GuestContract.expectedGuestSHA256 == imageSHA && Data(image[80..<84]) == Data([0x64,0,0,0xb9])
        case .merkleSingle:
            let actual = try MerkleGenesis.commit([schemaLeaf])
            let verified = try MerkleGenesis.verify([schemaLeaf], expectedRoot: singleRoot)
            return actual.leafCount == 1 && actual.leafHashes == ["schema": hex(hash(schemaLeafFrame))] &&
                actual.root == singleRoot && verified
        case .merkleOdd:
            let leaves = [schemaLeaf, GenesisLeaf(label: "b", payload: Data([2])), GenesisLeaf(label: "a", payload: Data([1]))]
            let a = hash(Data([0,0,0,0,1,0x61,0,0,0,0,0,0,0,1,1]))
            let b = hash(Data([0,0,0,0,1,0x62,0,0,0,0,0,0,0,1,2]))
            let schema = hash(schemaLeafFrame)
            let pair = hash(Data([1]) + a + b)
            let expected = hex(hash(Data([2,0,0,0,0,0,0,0,3]) + hash(Data([1]) + pair + hash(Data([3]) + schema))))
            let duplicated = hex(hash(Data([2,0,0,0,0,0,0,0,3]) + hash(Data([1]) + pair + hash(Data([1]) + schema + schema))))
            return try MerkleGenesis.commit(leaves).root == expected &&
                MerkleGenesis.verify(Array(leaves.reversed()), expectedRoot: expected) &&
                !MerkleGenesis.verify(leaves, expectedRoot: duplicated)
        case .merkleTamper:
            let wrongCount = hex(hash(Data([2,0,0,0,0,0,0,0,2]) + hash(schemaLeafFrame)))
            return try !MerkleGenesis.verify([schemaLeaf], expectedRoot: wrongCount) &&
                !MerkleGenesis.verify([GenesisLeaf(label: "schema", payload: Data("v2".utf8))], expectedRoot: singleRoot) &&
                !MerkleGenesis.verify([schemaLeaf], expectedRoot: singleRoot.uppercased())
        case .merkleInvalidLeaves:
            return rejects { _ = try MerkleGenesis.commit([schemaLeaf, schemaLeaf]) } &&
                rejects { _ = try MerkleGenesis.commit([]) } &&
                rejects { _ = try MerkleGenesis.commit([GenesisLeaf(label: "a", payload: Data())]) }
        case .mailboxMutation:
            var changed = reply; changed[16] = 43
            let root = try MerkleGenesis.commit(GuestContract.snapshotLeaves(image: image, request: request, reply: changed)).root
            let short = Data(request.dropLast())
            let shortRoot = try MerkleGenesis.commit(GuestContract.snapshotLeaves(image: image, request: short, reply: reply)).root
            return try !GuestContract.validateSnapshot(image: image, request: request, reply: changed, expectedRoot: root) &&
                !GuestContract.validateSnapshot(image: image, request: short, reply: reply, expectedRoot: shortRoot)
        case .verifierKnownAnswer:
            let root = hex(snapshotRootBytes)
            let snapshotPassed = try GuestContract.validateSnapshot(image: image, request: request, reply: reply, expectedRoot: root)
            let commitment = try MerkleGenesis.commit(GuestContract.snapshotLeaves(image: image, request: request, reply: reply))
            let candidate = try events(completeSyntheticPayloads)
            let result = try GuestResultVerifier.verify(runID: runID, events: candidate)
            return snapshotPassed && commitment.root == root && commitment.leafCount == 4 &&
                result.status == "PASS" && result.root == root && result.detail == syntheticDetail &&
                result.elapsed == "250 ticks × 125/3 ns" && !result.quarantined
        case .verifierPrefix:
            let prefix = try events([startPayload])
            let result = try GuestResultVerifier.verify(runID: runID, events: prefix)
            return result.status == "INCOMPLETE" && result.root.isEmpty && result.elapsed.isEmpty && !result.quarantined
        case .verifierProse:
            var payloads = completeSyntheticPayloads
            payloads[1]["execution_pass"] = .unsigned(0)
            payloads[2]["execution_pass"] = .bool(false)
            let candidate = try events(payloads)
            return rejects { _ = try GuestResultVerifier.verify(runID: runID, events: candidate) }
        case .verifierProjection:
            let prefix = try events([startPayload])
            var changed = prefix[0].payload; changed.append(0)
            let corrupted = GuestJournalEvent(runID: runID, sequence: 0, kind: "start", payload: changed,
                digest: GuestContract.hash(changed), parent: nil)
            var unknown = startPayload; unknown["profile"] = .text("unknown-profile")
            let unknownEvents = try events([unknown])
            return rejects { _ = try GuestResultVerifier.verify(runID: runID, events: [corrupted]) } &&
                rejects { _ = try GuestResultVerifier.verify(runID: runID + "-wrong", events: prefix) } &&
                rejects { _ = try GuestResultVerifier.verify(runID: runID, events: unknownEvents) }
        }
    }

    private static let runID = "functional-readiness-synthetic-fixed-v1"
    private static let syntheticDetail = "fabricated 92-byte assembly fixture; no native or guest execution"
    private static var startPayload: [String: GuestCBORValue] {
        ["guest_image": .bytes(image), "guest_sha256": .text(imageSHA),
         "request": .bytes(request), "expected_reply": .bytes(reply),
         "host_bundle": .text("com.ergentics.provenance"), "load_ipa": .unsigned(0x10000000),
         "doorbell_instruction_offset": .unsigned(80), "scope": .text("synthetic; no guest or storage operation")]
    }
    // The already-tested GuestResultVerifierTests fixture, condensed without
    // using native accessors or opening GuestJournal. Statuses/ticks are invented
    // test inputs, never measurements. The result report does not export them as
    // live observations; it exports only the synthetic check's outcome.
    private static var completeSyntheticPayloads: [[String: GuestCBORValue]] {
        var observation: [String: GuestCBORValue] = [:]
        for key in ["abi_version", "outcome", "execution_pass", "teardown_pass", "signing_admitted",
                    "run_entries", "vcpu_created", "request_unchanged", "reply_valid", "code_unchanged",
                    "trap_valid", "snapshot_sealed", "exception_reason"] { observation[key] = .unsigned(1) }
        for key in ["cancellation_requested", "cancellation_calls", "watchdog_fired", "resources_quarantined"] {
            observation[key] = .unsigned(0)
        }
        let words: [String: UInt64] = ["mappings_entered": 3, "register_calls": 36, "read_register_calls": 4,
            "pc": 0x10000050, "fault_ipa": 0x1000c000, "fault_virtual_address": 0x1000c000,
            "x4": 1, "sctlr_el1": 0x30d00800, "cpsr": 0x3c5, "syndrome": 0x93840046,
            "start_ticks": 100, "entry_ticks": 200, "exit_ticks": 300, "snapshot_ticks": 310,
            "end_ticks": 350, "deadline_ticks": 48_000_150, "timebase_numer": 125, "timebase_denom": 3]
        for (key, value) in words { observation[key] = .unsigned(value) }
        let zeroStatuses = ["failure_stage", "first_error", "signing_error", "vm_create", "vcpu_create",
            "register", "run", "read_register", "vcpu_destroy", "vm_destroy", "watchdog_create", "watchdog_join",
            "map_code", "map_request", "map_reply", "unmap_code", "unmap_request", "unmap_reply",
            "host_unmap_code", "host_unmap_request", "host_unmap_reply", "watchdog_wait"]
        var statuses = Dictionary(uniqueKeysWithValues: zeroStatuses.map { ($0, GuestCBORValue.text("0")) })
        statuses["cancellation"] = .text("-2147483648")
        observation["native_status_decimal"] = .map(statuses)
        observation["request"] = .bytes(request); observation["reply"] = .bytes(reply)
        observation["guest_sha256"] = .text(imageSHA)
        observation["snapshot_merkle"] = .bytes(snapshotRootBytes)
        observation["independent_snapshot_pass"] = .bool(true)
        let terminal: [String: GuestCBORValue] = ["status": .text("PASS"), "execution_pass": .bool(true),
            "teardown_pass": .bool(true), "independent_snapshot_pass": .bool(true), "resources_quarantined": .bool(false),
            "snapshot_merkle": .text(hex(snapshotRootBytes)), "detail": .text(syntheticDetail),
            "elapsed": .text("250 ticks × 125/3 ns"), "energy": .text("unmeasured; ergs unavailable"),
            "gate_e": .text("ABSTAIN"), "authority_vector": .text("00000000")]
        return [startPayload, observation, terminal]
    }
    private static func events(_ payloads: [[String: GuestCBORValue]]) throws -> [GuestJournalEvent] {
        let kinds = ["start", "observation", "terminal"]
        var result: [GuestJournalEvent] = []
        for (index, payload) in payloads.enumerated() {
            let parent = result.last?.digest
            let parentBytes = result.last.map { hash($0.payload) } ?? Data()
            let envelope = GuestCBORValue.map(["schema": .text("ergentics.guest-journal.event.v1"),
                "run_id": .text(runID), "sequence": .unsigned(UInt64(index)), "kind": .text(kinds[index]),
                "parent": .bytes(parentBytes), "payload": .map(payload)])
            let bytes = try GuestCBOR.encode(envelope)
            result.append(GuestJournalEvent(runID: runID, sequence: index, kind: kinds[index], payload: bytes,
                digest: GuestContract.hash(bytes), parent: parent))
        }
        return result
    }
}
