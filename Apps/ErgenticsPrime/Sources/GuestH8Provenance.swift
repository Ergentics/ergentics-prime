import Foundation

/// Product-local retained evidence. Persistence and inspection have separate
/// one-use owners. Stored bytes never reconstruct an execution capability.
enum GuestH8Provenance {
    static let schema = "com.ergentics.provenance.hypervisor.h8.retained-checkpoint.v1"
    static let rootLeaf = "H8Provenance-v1"
    static let maximumStreamBytes = 32_768
    static let readSeconds = 60

    enum Failure: Error { case unavailable, invalid }

    struct Projection: Equatable, Sendable {
        let json: Data
        let cbor: Data
        let root: String
        let epoch: UUID
        let h3: GuestH3LiveProjectionReceipt

        fileprivate init(source: GuestH7Execution.VerifiedSource) throws {
            let jsonValue = try Self.semantic(state: StageCanonicalJSON.decode(source.receipt.state.json),
                graph: StageCanonicalJSON.decode(source.receipt.graph.json), request: source.request)
            let cborValue = try Self.semantic(state: GuestCBOR.decode(source.receipt.state.cbor),
                graph: GuestCBOR.decode(source.receipt.graph.cbor), request: source.request)
            guard jsonValue == cborValue else { throw Failure.invalid }
            self = try Self.decode(json: StageCanonicalJSON.encode(jsonValue), cbor: GuestCBOR.encode(cborValue))
        }

        private init(json: Data, cbor: Data, root: String, epoch: UUID, h3: GuestH3LiveProjectionReceipt) {
            self.json = json; self.cbor = cbor; self.root = root; self.epoch = epoch; self.h3 = h3
        }

        private static func semantic(state: GuestCBORValue, graph: GuestCBORValue,
                                     request: GuestH7Execution.Request) throws -> GuestCBORValue {
            let h3 = try GuestH3LiveVerifier.reconstructSaved(state: state, graph: graph)
            return .map([
                "schema": .text(schema), "claim_state": .text("RECORDED_H7_NATIVE_PASS"),
                "epoch": .text(request.epoch.uuidString.lowercased()),
                "subject": .text(request.subject.uuidString.lowercased()),
                "namespace": .text(request.namespace.uuidString.lowercased()),
                "purpose": .text("local-checkpoint-demonstration"),
                "function": .text("fixed-cursor-resume-v1"),
                "input": .map(["left": .text("19"), "right": .text("23"), "increment": .text("1")]),
                "h3_receipt_root": .text(h3.root), "h3_state_root": .text(h3.state.root),
                "h3_graph_root": .text(h3.graph.root), "h3_state": state, "h3_graph": graph,
                "disclosure": .map([
                    "operation": .text("EXPLICIT_SAVE_OF_THIS_LIVE_CHECKPOINT"),
                    "recipients": .array([.text("private_application_sqlite"), .text("local_gui_and_accessibility_summary")]),
                    "classes": .array(["fixed_guest_state", "run_timing", "generation_identifiers", "native_status_and_counters", "content_commitments"].map { .text($0) }),
                    "retention": .text("INDEFINITE_LOCAL_EVIDENCE_UNTIL_USER_REMOVAL"),
                    "deletion_authority": .text("USER_FILE_OWNER; APPLICATION_HAS_NO_DELETE_GRANT"),
                    "deletion_conflict": .text("PRESERVE_EVIDENCE_AND_REVOKE_ACTIVE_READ_GRANT"),
                    "cryptographic_domain": .text("DOMAIN_SEPARATED_CONTENT_COMMITMENT; NOT_ENCRYPTION_OR_ATTESTATION"),
                    "read_policy": .text("NEW_EXPLICIT_SELECTED_FILE_GRANT; SIXTY_SECONDS_OR_REVOCATION"),
                    "protection_join": .text("COMPLETE_H3_STATE_AND_GRAPH; NO_DECLASSIFICATION"),
                ]),
                "gate_e": .text("ABSTAIN"), "authority_vector": .text("00000000"),
                "execution_admission": .text("DENIED_FROM_RETAINED_BYTES"),
                "trusted_egress": .text("DENIED; INDEPENDENT_RELYING_PARTY_AUTHORITY_ABSENT"),
            ])
        }

        static func decode(json: Data, cbor: Data) throws -> Projection {
            guard (1...maximumStreamBytes).contains(json.count), (1...maximumStreamBytes).contains(cbor.count) else { throw Failure.invalid }
            let value = try StageCanonicalJSON.decode(json)
            guard try value == GuestCBOR.decode(cbor), try StageCanonicalJSON.encode(value) == json,
                  try GuestCBOR.encode(value) == cbor, case .map(let fields) = value,
                  let state = fields["h3_state"], let graph = fields["h3_graph"] else { throw Failure.invalid }
            func uuid(_ field: String) throws -> UUID {
                guard case .text(let text) = fields[field], let id = UUID(uuidString: text),
                      id.uuidString.lowercased() == text else { throw Failure.invalid }
                return id
            }
            let request = GuestH7Execution.Request(subject: try uuid("subject"), epoch: try uuid("epoch"),
                namespace: try uuid("namespace"), purpose: "local-checkpoint-demonstration",
                operation: "fixed-cursor-resume-v1", record: "fixed-operands", fields: ["left", "right", "increment"])
            guard try value == semantic(state: state, graph: graph, request: request) else { throw Failure.invalid }
            let h3 = try GuestH3LiveVerifier.reconstructSaved(state: state, graph: graph)
            let root = try MerkleGenesis.commit([
                GenesisLeaf(label: "schema", payload: Data(schema.utf8)),
                GenesisLeaf(label: "receipt.json", payload: json), GenesisLeaf(label: "receipt.cbor", payload: cbor)
            ]).root
            return Projection(json: json, cbor: cbor, root: root, epoch: request.epoch, h3: h3)
        }

        func verifyRetained(_ row: HypervisorStageH4DualStreamPersistence.ReopenedDualStreamRowInput) throws {
            guard row.semanticSchema == schema, row.claimState == "RECORDED_H7_NATIVE_PASS",
                  row.predicateCount == 9, row.authorityVector == "00000000",
                  row.canonicalJSON == json, row.canonicalCBOR == cbor,
                  try Self.decode(json: row.canonicalJSON, cbor: row.canonicalCBOR) == self else { throw Failure.invalid }
        }
    }

    struct Saved: Sendable {
        let durable: Bool
        let location: String
        let projection: Projection?
    }
    struct Snapshot: Equatable, Sendable {
        let projection: Projection
        let location: String
        let imageSHA256: String
        let imageBytes: Int
    }

    /// This initializer requires the opaque result minted only by the H7
    /// native verifier. There is no initializer from a decoded Projection.
    final class Pending: @unchecked Sendable {
        private let lock = NSLock()
        private var source: GuestH7Execution.VerifiedSource?
        private let now: @Sendable () -> ContinuousClock.Instant
        private let expiration: ContinuousClock.Instant
        private var deadline: ContinuousClock.Instant?
        private var consumed = false
        private var canceled = false
        let leaf = UUID().uuidString.lowercased()

        init(source: GuestH7Execution.VerifiedSource) {
            self.source = source; now = { .now }; expiration = .now.advanced(by: .seconds(300))
        }
        #if EPR_H4_PRIVACY_TESTS
        init(source: GuestH7Execution.VerifiedSource, testClock: @escaping @Sendable () -> ContinuousClock.Instant) {
            self.source = source; now = testClock; expiration = testClock().advanced(by: .seconds(300))
        }
        #endif
        func cancel() { lock.lock(); canceled = true; source = nil; lock.unlock() }
        func claim() throws -> Projection {
            lock.lock(); defer { lock.unlock() }
            guard !consumed else { throw Failure.unavailable }
            consumed = true
            guard !canceled, now() < expiration, let source else { self.source = nil; throw Failure.unavailable }
            self.source = nil
            deadline = min(expiration, now().advanced(by: .seconds(10)))
            return try Projection(source: source)
        }
        func remainsLive() -> Bool {
            lock.lock(); defer { lock.unlock() }
            return !canceled && consumed && deadline.map { now() < $0 } == true
        }
        func finish() -> Bool {
            lock.lock(); defer { lock.unlock() }
            let accepted = !canceled && deadline.map { now() < $0 } == true
            canceled = true; source = nil; return accepted
        }
        func persist() -> Saved { HypervisorStageH4DualStreamPersistence.persistH8(self) }
    }

    /// One selected-file inspection grant. Reopen is a fresh read and fresh
    /// grant; a saved root/old grant ID cannot replay this admission. Revocation
    /// withdraws future local display, not copies already observed elsewhere.
    final class ReadGrant: @unchecked Sendable {
        enum State: String, Sendable { case active, consumed, expired, revoked, retainedConflict }
        let id = UUID()
        private let lock = NSLock()
        private let now: @Sendable () -> ContinuousClock.Instant
        private let deadline: ContinuousClock.Instant
        private var snapshot: Snapshot?
        private var state = State.active
        private var remaining: Set<GuestH7Execution.Destination> = [.gui, .accessibility]
        init(snapshot: Snapshot) {
            self.snapshot = snapshot; now = { .now }; deadline = .now.advanced(by: .seconds(readSeconds))
        }
        #if EPR_H4_PRIVACY_TESTS
        init(snapshot: Snapshot, testClock: @escaping @Sendable () -> ContinuousClock.Instant) {
            self.snapshot = snapshot; now = testClock; deadline = testClock().advanced(by: .seconds(readSeconds))
        }
        #endif
        func take(_ destination: GuestH7Execution.Destination = .gui, id supplied: UUID) -> Snapshot? {
            lock.lock(); defer { lock.unlock() }
            expireLocked()
            guard supplied == id, state == .active, remaining.contains(destination) else { return nil }
            let result = snapshot; remaining.remove(destination)
            if remaining.isEmpty { snapshot = nil; state = .consumed }
            return result
        }
        func status() -> State { lock.lock(); defer { lock.unlock() }; expireLocked(); return state }
        func revoke(deletionRequested: Bool = false) {
            lock.lock(); defer { lock.unlock() }
            snapshot = nil; state = deletionRequested ? .retainedConflict : .revoked
        }
        private func expireLocked() {
            if (state == .active || state == .consumed) && now() >= deadline { snapshot = nil; state = .expired }
        }
    }
}
