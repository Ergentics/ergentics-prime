import Foundation

/// Bounded, product-local comparison of independently verified native H3
/// returns. Imported H3/H4 receipt bytes cannot enter this batch. The value
/// verifier remains usable with fabricated inputs in hostless tests.
enum HypervisorStageH5Repeat {
    static let runCount = 3
    static let workSeconds = 15
    static let schema = "ergentics.provenance.hypervisor-stage.h5.repeat.v1"
    static let comparisonSchema = "ergentics.provenance.hypervisor-stage.h5.comparison.v1"

    enum Failure: String, Error, Sendable {
        case consumed, canceled, nativeRejected, staleRun, clockChanged, mismatch, incomplete
    }

    struct Observation: Sendable {
        let ordinal: Int
        let presentation: GuestH3Presentation
        let evidence: Data
        let comparison: HypervisorStageProjection
        let start: UInt64
        let end: UInt64
        let numerator: UInt32
        let denominator: UInt32
    }

    struct Summary: Sendable {
        let epoch: UUID
        let observations: [Observation]
        let projection: HypervisorStageProjection
    }

    struct Batch: Sendable {
        let epoch: UUID
        private(set) var observations: [Observation] = []
        private(set) var attempted = 0
        private(set) var failure: Failure?
        private var pending = false
        private var finished = false

        init(epoch: UUID) { self.epoch = epoch }

        mutating func beginAttempt() throws {
            guard failure == nil, !finished, !pending, attempted < runCount else { throw Failure.consumed }
            attempted += 1
            pending = true
        }

        mutating func cancel() {
            // Cancellation remains sticky through the gaps between attempts.
            if !finished { failure = .canceled; pending = false }
        }

        mutating func reject(_ reason: Failure) {
            if !finished { failure = failure ?? reason; pending = false }
        }

        mutating func accept(_ native: EPRGuestH3CursorResumeResult) throws {
            guard failure == nil, !finished, pending else { throw Failure.consumed }
            do {
                let observation = try capture(native, ordinal: attempted)
                if let prior = observations.last {
                    guard observation.presentation.sourceGeneration > prior.presentation.targetGeneration,
                          observation.start >= prior.end,
                          observation.presentation.receipt?.root != prior.presentation.receipt?.root else {
                        throw Failure.staleRun
                    }
                    guard observation.numerator == prior.numerator,
                          observation.denominator == prior.denominator else { throw Failure.clockChanged }
                    guard observation.comparison == prior.comparison else { throw Failure.mismatch }
                }
                observations.append(observation)
                pending = false
            } catch {
                let reason = (error as? Failure) ?? .nativeRejected
                reject(reason)
                throw reason
            }
        }

        mutating func finish() throws -> Summary {
            guard failure == nil, !finished, !pending,
                  attempted == runCount, observations.count == runCount else { throw Failure.incomplete }
            let projection = try summary(epoch: epoch, observations: observations)
            finished = true
            return Summary(epoch: epoch, observations: observations, projection: projection)
        }
    }

    private static func capture(_ native: EPRGuestH3CursorResumeResult, ordinal: Int) throws -> Observation {
        let presentation = try GuestH3LiveVerifier.verify(native)
        guard let receipt = presentation.receipt,
              case .map(let state) = try StageCanonicalJSON.decode(receipt.state.json) else {
            throw Failure.nativeRejected
        }
        var value = native
        let evidence = withUnsafeBytes(of: &value.cursor_evidence.bytes) { Data($0) }
        // H3 v2 already independently checked every byte. Only the two
        // generation words (16..<32) and generation-bound cursor digest
        // (648..<680) are omitted. The raw evidence above is retained intact.
        let stableEvidence = evidence.subdata(in: 0..<16) + evidence.subdata(in: 32..<648)
        func stablePhase(_ key: String) throws -> GuestCBORValue {
            guard case .map(var phase) = state[key] else { throw Failure.nativeRejected }
            for field in ["generation", "entry_ticks", "exit_ticks"] { phase.removeValue(forKey: field) }
            return .map(phase)
        }
        let comparison = try project(.map([
            "schema": .text(comparisonSchema),
            "cursor_invariant_bytes_hex": .text(hex(stableEvidence)),
            "checkpoint_reply_hex": .text(withUnsafeBytes(of: &value.checkpoint_reply) { hex(Data($0)) }),
            "terminal_reply_hex": .text(withUnsafeBytes(of: &value.final_reply) { hex(Data($0)) }),
            "source": try stablePhase("source"), "target": try stablePhase("target"),
            "native_result": state["native_result"]!,
        ]), schema: comparisonSchema)
        return Observation(ordinal: ordinal, presentation: presentation, evidence: evidence,
            comparison: comparison, start: native.start_ticks, end: native.end_ticks,
            numerator: native.timebase_numer, denominator: native.timebase_denom)
    }

    private static func summary(epoch: UUID, observations: [Observation]) throws -> HypervisorStageProjection {
        let runs: [GuestCBORValue] = observations.map { observation in
            .map([
                "ordinal": .text(String(observation.ordinal)),
                "h3_receipt_root": .text(observation.presentation.receipt!.root),
                "raw_cursor_evidence_sha256": .text(GuestContract.hash(observation.evidence)),
                "comparison_root": .text(observation.comparison.root),
                "source_generation": .text(String(observation.presentation.sourceGeneration)),
                "target_generation": .text(String(observation.presentation.targetGeneration)),
                "start_ticks": .text(String(observation.start)), "end_ticks": .text(String(observation.end)),
                "timebase_numer": .text(String(observation.numerator)),
                "timebase_denom": .text(String(observation.denominator)),
                "cumulative_executions": .text(String(observation.ordinal)),
                "cumulative_native_intervals": .text(String(observation.ordinal * 2)),
                "cumulative_raw_cursor_bytes": .text(String(observation.ordinal * 680)),
            ])
        }
        return try project(.map([
            "schema": .text(schema),
            "stage_id": .text("hypervisor_repeated_same_host_resume_determinism_v1"),
            "status": .text("PASS_LOCAL_REPEAT_COMPARISON"),
            "epoch": .text(epoch.uuidString.lowercased()),
            "purpose": .text("THREE_FIXED_H3_RESUME_COMPARISONS"),
            "host_scope": .text("ONE_APPLICATION_PROCESS_LOCAL_OBSERVATION"),
            "same_host_attestation": .text("NOT_INDEPENDENTLY_ATTESTED"),
            "run_count": .text(String(runCount)),
            "runs": .array(runs),
            "comparison_root": .text(observations[0].comparison.root),
            "excluded_from_equality": .array([
                "generation_words_and_dependent_commitments", "monotonic_timing", "watchdog_wait_status"
            ].map { .text($0) }),
            "disclosure": .map([
                "classes": .array(["fixed_guest_state", "run_timing", "generation_identifiers", "content_commitments", "native_status_and_counters"].map { .text($0) }),
                "recipients": .array(["local_application_memory", "local_gui_and_accessibility"].map { .text($0) }),
                "retention": .text("VOLATILE_APPLICATION_LIFETIME"),
                "linkability": .text("THREE_RUNS_WITHIN_EPOCH_AND_EXISTING_H3_CONTENT_ROOTS"),
                "inference_scope": .text("DECLARED_EXPOSURE_UNION_ONLY_NOT_GENERAL_INFERENCE_CLOSURE"),
                "persistent_host_identifier": .bool(false), "export": .bool(false),
            ]),
            "durable": .bool(false), "gate_e": .text("ABSTAIN"),
            "authority_vector": .text("00000000"), "next_stage_authorized": .bool(false),
        ]), schema: schema)
    }

    private static func project(_ semantic: GuestCBORValue, schema: String) throws -> HypervisorStageProjection {
        let json = try StageCanonicalJSON.encode(semantic), cbor = try GuestCBOR.encode(semantic)
        guard json.count <= 65_536, cbor.count <= 65_536,
              try StageCanonicalJSON.decode(json) == GuestCBOR.decode(cbor) else { throw Failure.incomplete }
        let root = try MerkleGenesis.commit([
            GenesisLeaf(label: "schema", payload: Data(schema.utf8)),
            GenesisLeaf(label: "state.json", payload: json), GenesisLeaf(label: "state.cbor", payload: cbor)
        ]).root
        return HypervisorStageProjection(json: json, cbor: cbor, root: root)
    }

    private static func hex(_ bytes: Data) -> String { bytes.map { String(format: "%02x", $0) }.joined() }
}

/// One synchronous worker per explicitly selected batch. The effect adapter
/// is supplied by the application; tests supply fabricated native returns.
/// Nothing in this worker accepts serialized history or restores a cursor.
struct GuestCheckpointAttempt {
    let native: EPRGuestH3CursorResumeResult?
    let released: Bool
}

final class GuestH5RepeatWorker: @unchecked Sendable {
    typealias Attempt = GuestCheckpointAttempt
    struct Outcome: Sendable {
        let attempted: Int
        let observations: [HypervisorStageH5Repeat.Observation]
        let summary: HypervisorStageH5Repeat.Summary?
        let failure: HypervisorStageH5Repeat.Failure?
        let quarantined: Bool
    }
    private let lock = NSLock()
    private let epoch: UUID
    private let deadline: ContinuousClock.Instant
    private var canceled = false
    private var started = false
    private var completed = false

    init(epoch: UUID) {
        self.epoch = epoch
        deadline = .now.advanced(by: .seconds(HypervisorStageH5Repeat.workSeconds))
    }

    func cancel() { lock.lock(); if !completed { canceled = true }; lock.unlock() }
    private func mayContinue() -> Bool {
        lock.lock(); defer { lock.unlock() }
        return !canceled && ContinuousClock.now < deadline
    }

    func run(attempt: () -> Attempt) -> Outcome {
        lock.lock()
        guard !started else {
            lock.unlock()
            return Outcome(attempted: 0, observations: [], summary: nil, failure: .consumed, quarantined: false)
        }
        started = true
        lock.unlock()
        var batch = HypervisorStageH5Repeat.Batch(epoch: epoch)
        var quarantined = false
        do {
            for _ in 0..<HypervisorStageH5Repeat.runCount {
                guard mayContinue() else { batch.cancel(); throw HypervisorStageH5Repeat.Failure.canceled }
                try batch.beginAttempt()
                let result = attempt()
                quarantined = !result.released || result.native?.resources_quarantined != 0 && result.native != nil
                guard result.released, let native = result.native else {
                    batch.reject(.nativeRejected); throw HypervisorStageH5Repeat.Failure.nativeRejected
                }
                guard mayContinue() else { batch.cancel(); throw HypervisorStageH5Repeat.Failure.canceled }
                try batch.accept(native)
            }
            // Linearize final publication with cancellation. A canceled batch
            // cannot publish PASS merely because its last native call returned.
            lock.lock()
            defer { lock.unlock() }
            guard !canceled, ContinuousClock.now < deadline else {
                batch.cancel(); throw HypervisorStageH5Repeat.Failure.canceled
            }
            let summary = try batch.finish()
            completed = true
            return Outcome(attempted: batch.attempted, observations: batch.observations,
                summary: summary, failure: nil, quarantined: false)
        } catch {
            batch.reject((error as? HypervisorStageH5Repeat.Failure) ?? .incomplete)
            lock.lock(); completed = true; lock.unlock()
            return Outcome(attempted: batch.attempted, observations: batch.observations,
                summary: nil, failure: batch.failure, quarantined: quarantined)
        }
    }
}
