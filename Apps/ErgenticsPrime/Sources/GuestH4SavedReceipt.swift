import Foundation

/// Inert history data, deliberately outside the live handoff's source file.
/// Reopening a file never issues native execution, save, or attestation authority.
enum GuestH4SavedReceipt {
    struct Receipt: Equatable, Sendable {
        let json: Data
        let cbor: Data
        let root: String
        let h3: GuestH3LiveProjectionReceipt
        let interval: String
    }

    struct Snapshot: Sendable {
        let receipt: Receipt
        let location: String
        let imageSHA256: String
        let imageBytes: Int
    }

    /// One worker's cooperative budget, also used by SQLite's progress handler.
    /// The app separately arms its existing bounded Stop/Quit fallback.
    final class Budget: @unchecked Sendable {
        private let lock = NSLock()
        private let deadline = ContinuousClock.now.advanced(by: .seconds(10))
        private var canceled = false
        private var progressCalls = 0
        #if EPR_H4_PRIVACY_TESTS
        let afterCapture: (@Sendable () throws -> Void)?
        init(afterCapture: (@Sendable () throws -> Void)? = nil) { self.afterCapture = afterCapture }
        #endif
        func cancel() { lock.lock(); canceled = true; lock.unlock() }
        func check() throws {
            lock.lock(); defer { lock.unlock() }
            guard !canceled, ContinuousClock.now < deadline else {
                throw ProvenanceFailure("H4 read canceled or exceeded its ten-second work budget")
            }
        }
        func interruptSQLite() -> Int32 {
            lock.lock(); defer { lock.unlock() }
            progressCalls += 1
            return canceled || ContinuousClock.now >= deadline || progressCalls > 2_000 ? 1 : 0
        }
    }

    static func decode(_ row: HypervisorStageH4DualStreamPersistence.ReopenedDualStreamRowInput) throws -> Receipt {
        guard row.semanticSchema == GuestH3LivePersistence.schema,
              row.claimState == "OBSERVED_NATIVE_PASS", row.predicateCount == 9,
              row.authorityVector == "00000000",
              (1...GuestH3LivePersistence.maximumStreamBytes).contains(row.canonicalJSON.count),
              (1...GuestH3LivePersistence.maximumStreamBytes).contains(row.canonicalCBOR.count) else {
            throw ProvenanceFailure("Saved H4 schema, indexes or stream bounds rejected")
        }
        let json = try StageCanonicalJSON.decode(row.canonicalJSON)
        let cbor = try GuestCBOR.decode(row.canonicalCBOR)
        guard json == cbor, try StageCanonicalJSON.encode(json) == row.canonicalJSON,
              try GuestCBOR.encode(cbor) == row.canonicalCBOR,
              case .map(let fields) = json, let state = fields["h3_state"], let graph = fields["h3_graph"] else {
            throw ProvenanceFailure("Saved H4 streams are not exact canonical peers")
        }
        let h3 = try GuestH3LiveVerifier.reconstructSaved(state: state, graph: graph)
        let expected: GuestCBORValue = .map([
            "schema": .text(GuestH3LivePersistence.schema), "claim_state": .text("OBSERVED_NATIVE_PASS"),
            "authority_vector": .text("00000000"), "gate_e": .text("ABSTAIN"),
            "predicate_count": .text("9"), "predicate_scope": .text("H3_SOURCE_CHECKPOINT_MASK_0x1ff"),
            "h3_receipt_root": .text(h3.root), "h3_state_root": .text(h3.state.root),
            "h3_graph_root": .text(h3.graph.root), "h3_state": state, "h3_graph": graph,
        ])
        guard json == expected, case .map(let stateFields) = state,
              case .map(let clock) = stateFields["lifecycle"],
              case .text(let start) = clock["start_ticks"], let startTicks = UInt64(start),
              case .text(let end) = clock["end_ticks"], let endTicks = UInt64(end), endTicks >= startTicks,
              case .text(let numer) = clock["timebase_numer"], case .text(let denom) = clock["timebase_denom"] else {
            throw ProvenanceFailure("Saved H4/H3 roots or exact field inventory rejected")
        }
        let root = try MerkleGenesis.commit([
            GenesisLeaf(label: "schema", payload: Data(GuestH3LivePersistence.schema.utf8)),
            GenesisLeaf(label: "receipt.json", payload: row.canonicalJSON),
            GenesisLeaf(label: "receipt.cbor", payload: row.canonicalCBOR),
        ]).root
        return Receipt(json: row.canonicalJSON, cbor: row.canonicalCBOR, root: root, h3: h3,
            interval: "\(endTicks - startTicks) ticks × \(numer)/\(denom) ns")
    }
}
