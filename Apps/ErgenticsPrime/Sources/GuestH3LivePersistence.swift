import Darwin
import Foundation

/// The live successor is separate from H4's retained structural fixtures.
/// Only a successful native reserved call can mint a product handoff. A
/// decoded receipt, a UI value, or a hash cannot create this one-use owner.
enum GuestH3LivePersistence {
    static let schema = "com.ergentics.provenance.hypervisor.h4.live-h3-receipt.v1"
    static let maximumStreamBytes = 32_768
    static let rootLeaf = "H4LiveReceipts-v1"

    struct Completion: Sendable {
        let presentation: GuestH3Presentation
        let handoff: Handoff?
    }

    #if !EPR_H4_PRIVACY_TESTS
    static func runReserved(_ reservation: OpaquePointer?) -> Completion {
        let native = epr_guest_h3_cursor_resume_run_reserved(reservation)
        do {
            let presentation = try GuestH3LiveVerifier.verify(native)
            let receipt = try requireReceipt(presentation)
            return Completion(presentation: presentation, handoff: Handoff(receipt))
        } catch {
            return Completion(presentation: GuestH3LiveVerifier.rejected(native, error), handoff: nil)
        }
    }
    #endif

    struct Presentation: Sendable {
        let durable: Bool
        let detail: String
        let location: String
        let receipt: Projection?
    }

    /// Inert dual representation. JSON is derived from the verified H3 JSON
    /// stream, CBOR independently from H3 CBOR; neither synthesizes the other.
    struct Projection: Equatable, Sendable {
        let json: Data
        let cbor: Data
        let root: String
        let h3ReceiptRoot: String

        fileprivate init(_ receipt: GuestH3LiveProjectionReceipt) throws {
            func semantic(_ state: GuestCBORValue, _ graph: GuestCBORValue) -> GuestCBORValue {
                .map([
                    "schema": .text(schema), "claim_state": .text("OBSERVED_NATIVE_PASS"),
                    "authority_vector": .text("00000000"), "gate_e": .text("ABSTAIN"),
                    "predicate_count": .text("9"),
                    "predicate_scope": .text("H3_SOURCE_CHECKPOINT_MASK_0x1ff"),
                    "h3_receipt_root": .text(receipt.root),
                    "h3_state_root": .text(receipt.state.root),
                    "h3_graph_root": .text(receipt.graph.root),
                    "h3_state": state, "h3_graph": graph,
                ])
            }
            for bytes in [receipt.state.json, receipt.state.cbor, receipt.graph.json, receipt.graph.cbor] {
                guard !bytes.isEmpty, bytes.count <= 16_384 else {
                    throw ProvenanceFailure("H4 live source exceeds its fixed byte bound")
                }
            }
            let stateJSON = try StageCanonicalJSON.decode(receipt.state.json)
            let stateCBOR = try GuestCBOR.decode(receipt.state.cbor)
            let graphJSON = try StageCanonicalJSON.decode(receipt.graph.json)
            let graphCBOR = try GuestCBOR.decode(receipt.graph.cbor)
            guard stateJSON == stateCBOR, graphJSON == graphCBOR,
                  try StageCanonicalJSON.encode(stateJSON) == receipt.state.json,
                  try GuestCBOR.encode(stateCBOR) == receipt.state.cbor,
                  try StageCanonicalJSON.encode(graphJSON) == receipt.graph.json,
                  try GuestCBOR.encode(graphCBOR) == receipt.graph.cbor else {
                throw ProvenanceFailure("H4 live H3 streams are not exact canonical peers")
            }
            json = try StageCanonicalJSON.encode(semantic(stateJSON, graphJSON))
            cbor = try GuestCBOR.encode(semantic(stateCBOR, graphCBOR))
            guard json.count <= maximumStreamBytes, cbor.count <= maximumStreamBytes else {
                throw ProvenanceFailure("H4 live receipt exceeds its fixed byte bound")
            }
            h3ReceiptRoot = receipt.root
            root = try MerkleGenesis.commit([
                GenesisLeaf(label: "schema", payload: Data(schema.utf8)),
                GenesisLeaf(label: "receipt.json", payload: json),
                GenesisLeaf(label: "receipt.cbor", payload: cbor)
            ]).root
        }

        func verifyRetained(_ row: HypervisorStageH4DualStreamPersistence.ReopenedDualStreamRowInput) throws {
            guard row.semanticSchema == schema, row.claimState == "OBSERVED_NATIVE_PASS",
                  row.predicateCount == 9, row.authorityVector == "00000000",
                  row.canonicalJSON == json, row.canonicalCBOR == cbor,
                  try StageCanonicalJSON.decode(row.canonicalJSON) == GuestCBOR.decode(row.canonicalCBOR),
                  try StageCanonicalJSON.encode(StageCanonicalJSON.decode(row.canonicalJSON)) == json,
                  try GuestCBOR.encode(GuestCBOR.decode(row.canonicalCBOR)) == cbor else {
                throw ProvenanceFailure("H4 live retained streams/indexes differ from the owner")
            }
        }
    }

    final class Handoff: @unchecked Sendable {
        private enum State { case ready, claimed, finished }
        private let lock = NSLock()
        private var state = State.ready
        private var canceled = false
        private var deadline: UInt64 = 0
        private let receipt: GuestH3LiveProjectionReceipt
        private let leaf = UUID().uuidString.lowercased()

        fileprivate init(_ receipt: GuestH3LiveProjectionReceipt) { self.receipt = receipt }

        func cancel() { lock.lock(); canceled = true; lock.unlock() }

        private func claim() throws -> Claim {
            lock.lock(); defer { lock.unlock() }
            guard state == .ready, !canceled else { throw ProvenanceFailure("H4 handoff is already consumed or canceled") }
            state = .claimed // Failure consumes; there is no implicit retry.
            var timebase = mach_timebase_info_data_t()
            guard mach_timebase_info(&timebase) == KERN_SUCCESS, timebase.numer > 0, timebase.denom > 0 else {
                throw ProvenanceFailure("H4 monotonic timebase is unavailable")
            }
            let (scaled, scaleOverflow) = UInt64(10_000_000_000).multipliedReportingOverflow(by: UInt64(timebase.denom))
            guard !scaleOverflow else { throw ProvenanceFailure("H4 timebase overflow") }
            let ticks = scaled / UInt64(timebase.numer)
            let (end, overflow) = mach_continuous_time().addingReportingOverflow(ticks)
            guard !overflow, ticks > 0 else { throw ProvenanceFailure("H4 deadline overflow") }
            deadline = end
            return Claim(owner: self, projection: try Projection(receipt), leaf: leaf)
        }

        fileprivate func remainsLive() -> Bool {
            lock.lock(); defer { lock.unlock() }
            return state == .claimed && !canceled && mach_continuous_time() <= deadline
        }

        fileprivate func finish() -> Bool {
            lock.lock(); defer { lock.unlock() }
            let admitted = state == .claimed && !canceled && mach_continuous_time() <= deadline
            state = .finished
            return admitted
        }

        /// Explicit UI action only. No caller path, bytes, policy, or deadline.
        func persist() -> Presentation {
            do { return HypervisorStageH4DualStreamPersistence.persistLive(try claim()) }
            catch { return Presentation(durable: false, detail: String(describing: error), location: "", receipt: nil) }
        }

        #if EPR_H4_PRIVACY_TESTS
        func persistProvisionedTest(baseURL: URL) -> Presentation {
            do { return try HypervisorStageH4DualStreamPersistence.persistLiveProvisionedTest(claim(), baseURL: baseURL) }
            catch { _ = finish(); return Presentation(durable: false, detail: String(describing: error), location: "", receipt: nil) }
        }

        func persistTest(rootURL: URL,
                         fault: HypervisorStageH4DualStreamPersistence.TestFault = .none,
                         interstice: HypervisorStageH4DualStreamPersistence.TestPublicationIntersticeCallback? = nil) -> Presentation {
            do { return try HypervisorStageH4DualStreamPersistence.persistLiveTest(
                claim(), rootURL: rootURL, fault: fault, interstice: interstice) }
            catch { _ = finish(); return Presentation(durable: false, detail: String(describing: error), location: "", receipt: nil) }
        }
        #endif
    }

    /// Its initializer is file-private to the native handoff owner, not the
    /// codec or SQLite file. Copied projections cannot impersonate this claim.
    final class Claim: @unchecked Sendable {
        private let owner: Handoff
        let projection: Projection
        let leaf: String
        fileprivate init(owner: Handoff, projection: Projection, leaf: String) {
            self.owner = owner; self.projection = projection; self.leaf = leaf
        }
        func remainsLive() -> Bool { owner.remainsLive() }
        func finish() -> Bool { owner.finish() }
    }

    private static func requireReceipt(_ presentation: GuestH3Presentation) throws -> GuestH3LiveProjectionReceipt {
        guard presentation.status == "PASS", presentation.verificationDisposition == "VERIFIED_PASS",
              !presentation.quarantined, !presentation.durable, !presentation.h4Entered,
              presentation.authorityVector == "00000000", presentation.gateE == "ABSTAIN",
              let receipt = presentation.receipt, receipt.root == presentation.projectionRoot,
              receipt.graph.root == presentation.graphRoot else {
            throw ProvenanceFailure("H4 requires the verified native H3 completion")
        }
        return receipt
    }

    #if EPR_H4_PRIVACY_TESTS
    static func makeTestHandoff(_ fabricated: EPRGuestH3CursorResumeResult) throws -> Handoff {
        Handoff(try requireReceipt(GuestH3LiveVerifier.verify(fabricated)))
    }
    #endif
}
