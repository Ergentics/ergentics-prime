import Foundation

enum HypervisorStageH3CursorFailure: Error, Equatable, Sendable {
    case rejected(String)
}

enum HypervisorStageH3Predicate: String, CaseIterable, Sendable {
    case predecessor = "h2_product_causal_lineage_exact"
    case schema = "cursor_schema_exact"
    case checkpoint = "checkpoint_state_exact"
    case nextOperation = "next_operation_exact"
    case sourceRetired = "source_owner_retired"
    case freshOwner = "fresh_owner_independent"
    case noReexecution = "resume_not_reexecution"
    case terminalEquality = "control_resume_terminal_equal"
    case oneWinner = "cursor_one_winner_no_replay"
    case semanticJoin = "json_cbor_semantic_join"
    case merkleAncestry = "merkle_ancestry_exact"
    case noEffects = "no_live_or_durable_effects"
}

struct HypervisorStageH3MachineState: Equatable, Sendable {
    let left: UInt64
    let right: UInt64
    let accumulator: UInt64
    let nextOrdinal: Int
}

struct HypervisorStageH3MachineOwnerSnapshot: Equatable, Sendable {
    let state: HypervisorStageH3MachineState
    let executedOrdinals: [Int]
    let retired: Bool
}

struct HypervisorStageH3CursorFrame: Equatable, Sendable {
    let schema: String
    let profile: String
    let h2ProductSourceCommit: String
    let h2ProductSourceTree: String
    let h2ProductResultCommit: String
    let h2ProductResultTree: String
    let h2ProductResultParentCommit: String
    let h2ProductReceiptSHA256: String
    let h2ProductReceiptGitBlob: String
    let buildArchiveReceiptSHA256: String
    let buildArchiveReceiptGitBlob: String
    let h2StaticResultSHA256: String
    let h2StaticResultGitBlob: String
    let h2StaticReceiptRoot: String
    let h2StaticOutputStateRoot: String
    let h2SnapshotRoot: String
    let sourceGeneration: String
    let baseStateRoot: String
    let checkpointStateRoot: String
    let nextOrdinal: Int
    let nextOperation: String
    let state: HypervisorStageH3MachineState
}

struct HypervisorStageH3ContractReceipt: Equatable, Sendable {
    let inputState: HypervisorStageNode
    let cursor: HypervisorStageNode
    let witnesses: [HypervisorStageNode]
    let transition: HypervisorStageNode
    let outputState: HypervisorStageNode
    let graph: HypervisorStageNode
    let root: String
}

struct HypervisorStageH3VerifiedResult: Equatable, Sendable {
    let outcome: String
    let receiptRoot: String
    let cursorRoot: String
    let graphRoot: String
    let gateE: String
    let authorityVector: String
    let vmEntryCount: Int
    let stageCompleted: Bool
    let liveResumeAuthorized: Bool
}

private enum HypervisorStageH3ProjectionRole: String {
    case state
    case cursor
    case transition
    case witness
    case graph

    var jsonLabel: String { "\(rawValue).json" }
    var cborLabel: String { "\(rawValue).cbor" }
}

/// A process-local capability. Serialized projections describe what was
/// checked; they cannot reconstruct this owner or mint another consume right.
final class HypervisorStageH3CursorCapability: @unchecked Sendable {
    enum Disposition: Equatable { case available, claimed, consumed, poisoned }

    let frame: HypervisorStageH3CursorFrame
    private let lock = NSLock()
    private var disposition: Disposition = .available

    fileprivate init(frame: HypervisorStageH3CursorFrame) { self.frame = frame }

    func snapshotDisposition() -> Disposition {
        lock.lock(); defer { lock.unlock() }
        return disposition
    }

    func consume(into target: HypervisorStageH3MachineOwner) throws {
        lock.lock()
        guard disposition == .available else {
            lock.unlock()
            throw HypervisorStageH3CursorFailure.rejected("cursor.already_consumed")
        }
        disposition = .claimed
        lock.unlock()

        do {
            try HypervisorStageH3Cursor.validate(frame)
            try target.restoreAndConsume(frame)
            lock.lock(); disposition = .consumed; lock.unlock()
        } catch {
            lock.lock(); disposition = .poisoned; lock.unlock()
            throw error
        }
    }
}

/// Small value machine used to freeze cursor semantics before the native H3
/// bridge. It has no filesystem, SQLite, clock, environment, UI or VM calls.
final class HypervisorStageH3MachineOwner: @unchecked Sendable {
    private let lock = NSLock()
    private var storedState: HypervisorStageH3MachineState
    private var storedExecutedOrdinals: [Int] = []
    private var storedRetired = false

    init(initial: HypervisorStageH3MachineState = HypervisorStageH3Cursor.initialState) {
        storedState = initial
    }

    var state: HypervisorStageH3MachineState { snapshot().state }
    var executedOrdinals: [Int] { snapshot().executedOrdinals }
    var retired: Bool { snapshot().retired }

    func snapshot() -> HypervisorStageH3MachineOwnerSnapshot {
        lock.lock(); defer { lock.unlock() }
        return HypervisorStageH3MachineOwnerSnapshot(
            state: storedState, executedOrdinals: storedExecutedOrdinals,
            retired: storedRetired)
    }

    private func advanceLocked() throws {
        guard !storedRetired else {
            throw HypervisorStageH3CursorFailure.rejected("owner.retired")
        }
        switch storedState.nextOrdinal {
        case 0:
            let sum = storedState.left.addingReportingOverflow(storedState.right)
            guard !sum.overflow else { throw HypervisorStageH3CursorFailure.rejected("state.overflow") }
            storedState = HypervisorStageH3MachineState(left: storedState.left, right: storedState.right,
                accumulator: sum.partialValue, nextOrdinal: 1)
            storedExecutedOrdinals.append(0)
        case 1:
            let sum = storedState.accumulator.addingReportingOverflow(1)
            guard !sum.overflow else { throw HypervisorStageH3CursorFailure.rejected("state.overflow") }
            storedState = HypervisorStageH3MachineState(left: storedState.left, right: storedState.right,
                accumulator: sum.partialValue, nextOrdinal: 2)
            storedExecutedOrdinals.append(1)
        default:
            throw HypervisorStageH3CursorFailure.rejected("state.complete")
        }
    }

    func advance() throws {
        lock.lock(); defer { lock.unlock() }
        try advanceLocked()
    }

    func exportCursor() throws -> HypervisorStageH3CursorCapability {
        lock.lock(); defer { lock.unlock() }
        guard !storedRetired, storedExecutedOrdinals == [0],
              storedState == HypervisorStageH3Cursor.checkpointState else {
            throw HypervisorStageH3CursorFailure.rejected("cursor.export_state")
        }
        let frame = try HypervisorStageH3Cursor.makeFrame(state: storedState)
        storedRetired = true
        return HypervisorStageH3CursorCapability(frame: frame)
    }

    fileprivate func restoreAndConsume(_ frame: HypervisorStageH3CursorFrame) throws {
        // Frame validation touches no owner state and therefore precedes the
        // target's one mutation boundary.
        try HypervisorStageH3Cursor.validate(frame)
        lock.lock(); defer { lock.unlock() }
        guard !storedRetired, storedExecutedOrdinals.isEmpty,
              storedState == HypervisorStageH3Cursor.initialState else {
            throw HypervisorStageH3CursorFailure.rejected("target.not_fresh")
        }
        storedState = frame.state
        try advanceLocked()
        guard storedExecutedOrdinals == [1] else {
            throw HypervisorStageH3CursorFailure.rejected("target.trace")
        }
    }
}

/// H3 contract/readiness: explicit cursor, fresh owner and exact resumed value.
/// This is compiled product code, but it remains deliberately effect-free and
/// cannot claim the later native H3 execution or H4 durability stages.
enum HypervisorStageH3Cursor {
    static let stageID = "hypervisor_explicit_state_cursor_resume_v1"
    static let cursorSchema = "ergentics.provenance.hypervisor-stage.h3.cursor.v1"
    static let inputStateSchema = "ergentics.provenance.hypervisor-stage.h3.input-state.v1"
    static let outputStateSchema = "ergentics.provenance.hypervisor-stage.h3.output-state.v1"
    static let witnessSchema = "ergentics.provenance.hypervisor-stage.h3.witness.v1"
    static let transitionSchema = "ergentics.provenance.hypervisor-stage.h3.transition.v1"
    static let graphSchema = "ergentics.provenance.hypervisor-stage.h3.graph.v1"
    static let receiptSchema = "ergentics.provenance.hypervisor-stage.h3.receipt.v1"
    static let profile = "fixed-two-phase-19-plus-23-then-increment-v1"
    // H2 ran from the archive checkpoint. Its result was then committed as the
    // checkpoint's exact single-parent child. These identities are deliberately
    // separate: neither a later result commit nor the guest snapshot is the H2
    // static graph's output state.
    static let h2ProductSourceCommit = "ffefa11b412cbefb0dd5230e7eb6f6cfa6d5eb55"
    static let h2ProductSourceTree = "2b6333ba5c05a8a6b3b4e873850bd36355a5cba9"
    static let h2ProductResultCommit = "12a0ff52a81e669f135ec9ab4640ee0ba091dbc6"
    static let h2ProductResultTree = "3c06694713ceb690373a36c04922371180c06931"
    static let h2ProductResultParentCommit = h2ProductSourceCommit
    static let h2ProductReceiptSHA256 = "83a201a32114c81fa737f6edfa2b0976324e6e0ca44223f589abbffae4c6f4d4"
    static let h2ProductReceiptGitBlob = "98c037b8c82ed27f458c48fc6a1d92fc05a78e59"
    static let buildArchiveReceiptSHA256 = "fd5e58920b61750cd37b1f6d19e78d37b17824aae559f306527268feb2f7ddd2"
    static let buildArchiveReceiptGitBlob = "5b46f8e7f88895d7a1919eb325a4f6ce827806af"
    static let h2StaticResultSHA256 = "b3693a405a382bd33f8762c08147afd13669533a525856cabb7b954238853855"
    static let h2StaticResultGitBlob = "ef67768a9c895f9c9a06e12f49590b9d724e5103"
    static let h2StaticReceiptRoot = "50a3a244914f5987c3552a0d68faaedef29d17d856d7d645f6d834b5e32c20ca"
    static let h2StaticOutputStateRoot = "6b880870ce4216c9c0793ef198695920323ff23cf6e79b0d8a6cca1f2d8d5d66"
    static let h2SnapshotRoot = "37b6aa19da562bf99810c8169e091357bc4e789a82b50366e0752ffb1a9d89df"
    static let sourceGeneration = "h3-contract-source-owner-v1"
    static let nextOperation = "increment_checkpoint_once"
    static let maximumStreamBytes = 65_536

    static let initialState = HypervisorStageH3MachineState(
        left: 19, right: 23, accumulator: 0, nextOrdinal: 0)
    static let checkpointState = HypervisorStageH3MachineState(
        left: 19, right: 23, accumulator: 42, nextOrdinal: 1)
    static let terminalState = HypervisorStageH3MachineState(
        left: 19, right: 23, accumulator: 43, nextOrdinal: 2)

    static func runContract() throws -> HypervisorStageH3ContractReceipt {
        let control = HypervisorStageH3MachineOwner()
        try control.advance(); try control.advance()

        let source = HypervisorStageH3MachineOwner()
        try source.advance()
        let capability = try source.exportCursor()
        let frame = capability.frame
        let target = HypervisorStageH3MachineOwner()
        guard ObjectIdentifier(source) != ObjectIdentifier(target) else {
            throw failure("owner.identity")
        }
        try capability.consume(into: target)

        let replayTarget = HypervisorStageH3MachineOwner()
        var replayRejected = false
        do { try capability.consume(into: replayTarget) }
        catch { replayRejected = true }

        let expectedCheckpointRoot = try stateRoot(checkpointState)
        let results: [HypervisorStageH3Predicate: Bool] = [
            .predecessor: predecessorExact(frame),
            .schema: frame.schema == cursorSchema && frame.profile == profile,
            .checkpoint: frame.state == checkpointState &&
                frame.checkpointStateRoot == expectedCheckpointRoot,
            .nextOperation: frame.nextOrdinal == 1 && frame.nextOperation == nextOperation,
            .sourceRetired: source.retired,
            .freshOwner: ObjectIdentifier(source) != ObjectIdentifier(target),
            .noReexecution: source.executedOrdinals == [0] && target.executedOrdinals == [1],
            .terminalEquality: control.state == terminalState && target.state == control.state,
            .oneWinner: capability.snapshotDisposition() == .consumed && replayRejected &&
                replayTarget.state == initialState && replayTarget.executedOrdinals.isEmpty,
            .semanticJoin: try semanticJoinExact(frame),
            .merkleAncestry: try merkleAncestryExact(frame),
            .noEffects: effectsExactlyClosed(),
        ]
        guard HypervisorStageH3Predicate.allCases.allSatisfy({ results[$0] == true }) else {
            throw failure("predicate.internal")
        }

        let input = HypervisorStageNode(projection: try project(
            inputStateSemantic(), schema: inputStateSchema, role: .state))
        let cursor = HypervisorStageNode(projection: try project(
            cursorSemantic(frame), schema: cursorSchema, role: .cursor))
        let witnesses = try HypervisorStageH3Predicate.allCases.enumerated().map { index, predicate in
            HypervisorStageNode(projection: try project(
                witnessSemantic(predicate: predicate, position: index,
                                satisfied: results[predicate] == true,
                                cursorRoot: cursor.projection.root),
                schema: witnessSchema, role: .witness))
        }
        let transition = HypervisorStageNode(projection: try project(
            transitionSemantic(inputRoot: input.projection.root,
                               cursorRoot: cursor.projection.root,
                               witnesses: witnesses),
            schema: transitionSchema, role: .transition))
        let output = HypervisorStageNode(projection: try project(
            outputStateSemantic(inputRoot: input.projection.root,
                                cursorRoot: cursor.projection.root,
                                transitionRoot: transition.projection.root),
            schema: outputStateSchema, role: .state))
        let graph = HypervisorStageNode(projection: try project(
            graphSemantic(input: input, cursor: cursor, witnesses: witnesses,
                          transition: transition, output: output),
            schema: graphSchema, role: .graph))
        let partial = HypervisorStageH3ContractReceipt(inputState: input, cursor: cursor,
            witnesses: witnesses, transition: transition, outputState: output,
            graph: graph, root: "")
        let root = try MerkleGenesis.commit(receiptLeaves(partial)).root
        let receipt = HypervisorStageH3ContractReceipt(inputState: input, cursor: cursor,
            witnesses: witnesses, transition: transition, outputState: output,
            graph: graph, root: root)
        _ = try verifyContract(receipt)
        return receipt
    }

    static func verifyContract(_ receipt: HypervisorStageH3ContractReceipt) throws -> HypervisorStageH3VerifiedResult {
        let input = try verify(receipt.inputState.projection, schema: inputStateSchema, role: .state)
        guard input == inputStateSemantic() else { throw failure("input.exact") }
        let cursorValue = try verify(receipt.cursor.projection, schema: cursorSchema, role: .cursor)
        guard cursorValue == cursorSemantic(try makeFrame(state: checkpointState)) else {
            throw failure("cursor.exact")
        }
        guard receipt.witnesses.count == HypervisorStageH3Predicate.allCases.count else {
            throw failure("witness.count")
        }
        for (index, predicate) in HypervisorStageH3Predicate.allCases.enumerated() {
            let actual = try verify(receipt.witnesses[index].projection,
                                    schema: witnessSchema, role: .witness)
            let expected = witnessSemantic(predicate: predicate, position: index,
                                           satisfied: true,
                                           cursorRoot: receipt.cursor.projection.root)
            guard actual == expected else { throw failure("witness.\(index)") }
        }
        let transition = try verify(receipt.transition.projection,
                                    schema: transitionSchema, role: .transition)
        guard transition == transitionSemantic(inputRoot: receipt.inputState.projection.root,
                                                cursorRoot: receipt.cursor.projection.root,
                                                witnesses: receipt.witnesses) else {
            throw failure("transition.exact")
        }
        let output = try verify(receipt.outputState.projection,
                                schema: outputStateSchema, role: .state)
        guard output == outputStateSemantic(inputRoot: receipt.inputState.projection.root,
                                            cursorRoot: receipt.cursor.projection.root,
                                            transitionRoot: receipt.transition.projection.root) else {
            throw failure("output.exact")
        }
        let graph = try verify(receipt.graph.projection, schema: graphSchema, role: .graph)
        guard graph == graphSemantic(input: receipt.inputState, cursor: receipt.cursor,
                                     witnesses: receipt.witnesses,
                                     transition: receipt.transition,
                                     output: receipt.outputState) else {
            throw failure("graph.exact")
        }
        guard try MerkleGenesis.verify(receiptLeaves(receipt), expectedRoot: receipt.root) else {
            throw failure("receipt.root")
        }
        return HypervisorStageH3VerifiedResult(
            outcome: "PASS_H3_CURSOR_CONTRACT_ONLY", receiptRoot: receipt.root,
            cursorRoot: receipt.cursor.projection.root,
            graphRoot: receipt.graph.projection.root, gateE: "ABSTAIN",
            authorityVector: "00000000", vmEntryCount: 0,
            stageCompleted: false, liveResumeAuthorized: false)
    }

    fileprivate static func makeFrame(state: HypervisorStageH3MachineState) throws -> HypervisorStageH3CursorFrame {
        guard state == checkpointState else { throw failure("cursor.state") }
        return HypervisorStageH3CursorFrame(schema: cursorSchema, profile: profile,
            h2ProductSourceCommit: h2ProductSourceCommit,
            h2ProductSourceTree: h2ProductSourceTree,
            h2ProductResultCommit: h2ProductResultCommit,
            h2ProductResultTree: h2ProductResultTree,
            h2ProductResultParentCommit: h2ProductResultParentCommit,
            h2ProductReceiptSHA256: h2ProductReceiptSHA256,
            h2ProductReceiptGitBlob: h2ProductReceiptGitBlob,
            buildArchiveReceiptSHA256: buildArchiveReceiptSHA256,
            buildArchiveReceiptGitBlob: buildArchiveReceiptGitBlob,
            h2StaticResultSHA256: h2StaticResultSHA256,
            h2StaticResultGitBlob: h2StaticResultGitBlob,
            h2StaticReceiptRoot: h2StaticReceiptRoot,
            h2StaticOutputStateRoot: h2StaticOutputStateRoot,
            h2SnapshotRoot: h2SnapshotRoot,
            sourceGeneration: sourceGeneration,
            baseStateRoot: try stateRoot(initialState),
            checkpointStateRoot: try stateRoot(state),
            nextOrdinal: 1, nextOperation: nextOperation, state: state)
    }

    static func validate(_ frame: HypervisorStageH3CursorFrame) throws {
        guard frame == (try makeFrame(state: checkpointState)), predecessorExact(frame) else {
            throw failure("cursor.validation")
        }
    }

    private static func predecessorExact(_ frame: HypervisorStageH3CursorFrame) -> Bool {
        frame.h2ProductSourceCommit == h2ProductSourceCommit &&
        frame.h2ProductSourceTree == h2ProductSourceTree &&
        frame.h2ProductResultCommit == h2ProductResultCommit &&
        frame.h2ProductResultTree == h2ProductResultTree &&
        frame.h2ProductResultParentCommit == h2ProductSourceCommit &&
        frame.h2ProductReceiptSHA256 == h2ProductReceiptSHA256 &&
        frame.h2ProductReceiptGitBlob == h2ProductReceiptGitBlob &&
        frame.buildArchiveReceiptSHA256 == buildArchiveReceiptSHA256 &&
        frame.buildArchiveReceiptGitBlob == buildArchiveReceiptGitBlob &&
        frame.h2StaticResultSHA256 == h2StaticResultSHA256 &&
        frame.h2StaticResultGitBlob == h2StaticResultGitBlob &&
        frame.h2StaticReceiptRoot == h2StaticReceiptRoot &&
        frame.h2StaticOutputStateRoot == h2StaticOutputStateRoot &&
        frame.h2SnapshotRoot == h2SnapshotRoot
    }

    private static func lowercaseHex(_ value: String, count: Int) -> Bool {
        value.utf8.count == count && value.utf8.allSatisfy {
            (48...57).contains($0) || (97...102).contains($0)
        }
    }

    private static func semanticJoinExact(_ frame: HypervisorStageH3CursorFrame) throws -> Bool {
        let semantic = cursorSemantic(frame)
        let json = try StageCanonicalJSON.encode(semantic)
        let cbor = try GuestCBOR.encode(semantic)
        let leaves = [
            GenesisLeaf(label: "schema", payload: Data(cursorSchema.utf8)),
            GenesisLeaf(label: HypervisorStageH3ProjectionRole.cursor.jsonLabel, payload: json),
            GenesisLeaf(label: HypervisorStageH3ProjectionRole.cursor.cborLabel, payload: cbor),
        ]
        let root = try MerkleGenesis.commit(leaves).root
        let fromJSON = try StageCanonicalJSON.decode(json)
        let fromCBOR = try GuestCBOR.decode(cbor)
        let jsonRoundTrip = try StageCanonicalJSON.encode(fromJSON)
        let cborRoundTrip = try GuestCBOR.encode(fromCBOR)
        let rootVerified = try MerkleGenesis.verify(leaves, expectedRoot: root)
        return fromJSON == semantic && fromCBOR == semantic && fromJSON == fromCBOR &&
            jsonRoundTrip == json && cborRoundTrip == cbor && rootVerified
    }

    private static func merkleAncestryExact(_ frame: HypervisorStageH3CursorFrame) throws -> Bool {
        let baseStateRoot = try stateRoot(initialState)
        let checkpointStateRoot = try stateRoot(checkpointState)
        return predecessorExact(frame) &&
            lowercaseHex(frame.h2ProductSourceCommit, count: 40) &&
            lowercaseHex(frame.h2ProductSourceTree, count: 40) &&
            lowercaseHex(frame.h2ProductResultCommit, count: 40) &&
            lowercaseHex(frame.h2ProductResultTree, count: 40) &&
            lowercaseHex(frame.h2ProductResultParentCommit, count: 40) &&
            lowercaseHex(frame.h2ProductReceiptSHA256, count: 64) &&
            lowercaseHex(frame.h2ProductReceiptGitBlob, count: 40) &&
            lowercaseHex(frame.buildArchiveReceiptSHA256, count: 64) &&
            lowercaseHex(frame.buildArchiveReceiptGitBlob, count: 40) &&
            lowercaseHex(frame.h2StaticResultSHA256, count: 64) &&
            lowercaseHex(frame.h2StaticResultGitBlob, count: 40) &&
            lowercaseHex(frame.h2StaticReceiptRoot, count: 64) &&
            lowercaseHex(frame.h2StaticOutputStateRoot, count: 64) &&
            lowercaseHex(frame.h2SnapshotRoot, count: 64) &&
            frame.baseStateRoot == baseStateRoot &&
            frame.checkpointStateRoot == checkpointStateRoot
    }

    private static func effectsExactlyClosed() -> Bool {
        let names = Set(["clock_read", "environment_read", "file_read", "file_write",
                         "journal_open", "network", "process_launch", "sqlite_open", "vm_launch"])
        guard case .map(let effects) = effectMap(), Set(effects.keys) == names else { return false }
        return effects.values.allSatisfy { $0 == .bool(false) }
    }

    private static func stateSemantic(_ state: HypervisorStageH3MachineState) -> GuestCBORValue {
        .map([
            "accumulator": .text(String(state.accumulator)),
            "left": .text(String(state.left)),
            "next_ordinal": .text(String(state.nextOrdinal)),
            "right": .text(String(state.right)),
            "schema": .text("ergentics.provenance.hypervisor-stage.h3.machine-state.v1"),
        ])
    }

    private static func stateRoot(_ state: HypervisorStageH3MachineState) throws -> String {
        let semantic = stateSemantic(state)
        return try MerkleGenesis.commit([
            GenesisLeaf(label: "schema", payload: Data("ergentics.provenance.hypervisor-stage.h3.machine-state.v1".utf8)),
            GenesisLeaf(label: "state.json", payload: try StageCanonicalJSON.encode(semantic)),
            GenesisLeaf(label: "state.cbor", payload: try GuestCBOR.encode(semantic)),
        ]).root
    }

    private static func inputStateSemantic() -> GuestCBORValue {
        .map([
            "authority_vector": .text("00000000"),
            "archive_receipt_disposition": .text("EXTERNAL_COMMITTED_INPUT_PIN"),
            "build_archive_receipt_git_blob": .text(buildArchiveReceiptGitBlob),
            "build_archive_receipt_sha256": .text(buildArchiveReceiptSHA256),
            "effects": effectMap(),
            "gate_e": .text("ABSTAIN"),
            "h2_product_receipt_sha256": .text(h2ProductReceiptSHA256),
            "h2_product_receipt_git_blob": .text(h2ProductReceiptGitBlob),
            "h2_product_result_commit": .text(h2ProductResultCommit),
            "h2_product_result_parent_commit": .text(h2ProductResultParentCommit),
            "h2_product_result_tree": .text(h2ProductResultTree),
            "h2_product_source_commit": .text(h2ProductSourceCommit),
            "h2_product_source_tree": .text(h2ProductSourceTree),
            "h2_snapshot_root": .text(h2SnapshotRoot),
            "h2_static_output_state_root": .text(h2StaticOutputStateRoot),
            "h2_static_receipt_root": .text(h2StaticReceiptRoot),
            "h2_static_result_git_blob": .text(h2StaticResultGitBlob),
            "h2_static_result_sha256": .text(h2StaticResultSHA256),
            "lineage_disposition": .text("EXACT_PARENT_RESULT_COMMIT_CONTAINS_RECEIPTS"),
            "schema": .text(inputStateSchema),
            "stage_id": .text(stageID),
            "status": .text("H2_PRODUCT_LOCAL_MECHANICS_PASS"),
        ])
    }

    private static func cursorSemantic(_ frame: HypervisorStageH3CursorFrame) -> GuestCBORValue {
        .map([
            "base_state_root": .text(frame.baseStateRoot),
            "build_archive_receipt_git_blob": .text(frame.buildArchiveReceiptGitBlob),
            "build_archive_receipt_sha256": .text(frame.buildArchiveReceiptSHA256),
            "checkpoint_state": stateSemantic(frame.state),
            "checkpoint_state_root": .text(frame.checkpointStateRoot),
            "h2_product_receipt_sha256": .text(frame.h2ProductReceiptSHA256),
            "h2_product_receipt_git_blob": .text(frame.h2ProductReceiptGitBlob),
            "h2_product_result_commit": .text(frame.h2ProductResultCommit),
            "h2_product_result_parent_commit": .text(frame.h2ProductResultParentCommit),
            "h2_product_result_tree": .text(frame.h2ProductResultTree),
            "h2_product_source_commit": .text(frame.h2ProductSourceCommit),
            "h2_product_source_tree": .text(frame.h2ProductSourceTree),
            "h2_snapshot_root": .text(frame.h2SnapshotRoot),
            "h2_static_output_state_root": .text(frame.h2StaticOutputStateRoot),
            "h2_static_receipt_root": .text(frame.h2StaticReceiptRoot),
            "h2_static_result_git_blob": .text(frame.h2StaticResultGitBlob),
            "h2_static_result_sha256": .text(frame.h2StaticResultSHA256),
            "next_operation": .text(frame.nextOperation),
            "next_ordinal": .text(String(frame.nextOrdinal)),
            "profile": .text(frame.profile),
            "schema": .text(frame.schema),
            "source_generation": .text(frame.sourceGeneration),
        ])
    }

    private static func witnessSemantic(predicate: HypervisorStageH3Predicate,
                                        position: Int, satisfied: Bool,
                                        cursorRoot: String) -> GuestCBORValue {
        .map([
            "authority_delta": .text("00000000"),
            "cursor_root": .text(cursorRoot),
            "observed": .bool(satisfied),
            "outcome": .text(satisfied ? "SATISFIED" : "REJECTED"),
            "position": .text(String(position)),
            "predicate_id": .text(predicate.rawValue),
            "producer_scope": .text("PURE_PRODUCT_CONTRACT"),
            "schema": .text(witnessSchema),
            "slice_id": .text("H3_CONTRACT_READINESS"),
            "stage_id": .text(stageID),
            "vm_disposition": .text("NOT_CREATED"),
        ])
    }

    private static func transitionSemantic(inputRoot: String, cursorRoot: String,
                                           witnesses: [HypervisorStageNode]) -> GuestCBORValue {
        .map([
            "authority_delta": .text("00000000"),
            "combiner": .text("ALL_OF"),
            "cursor_root": .text(cursorRoot),
            "derived_outcome": .text("PASS_H3_CURSOR_CONTRACT_ONLY"),
            "gate_e": .text("ABSTAIN"),
            "input_state_root": .text(inputRoot),
            "output_stage": .text(stageID),
            "predicates": .array(zip(HypervisorStageH3Predicate.allCases, witnesses).enumerated().map {
                index, pair in .map([
                    "outcome": .text("SATISFIED"),
                    "position": .text(String(index)),
                    "predicate_id": .text(pair.0.rawValue),
                    "witness_root": .text(pair.1.projection.root),
                ])
            }),
            "schema": .text(transitionSchema),
            "successor_authorized": .bool(false),
            "vm_entry_count": .text("0"),
        ])
    }

    private static func graphSemantic(input: HypervisorStageNode,
                                      cursor: HypervisorStageNode,
                                      witnesses: [HypervisorStageNode],
                                      transition: HypervisorStageNode,
                                      output: HypervisorStageNode) -> GuestCBORValue {
        func node(_ id: String, _ partition: String, _ type: String,
                  _ schema: String, _ root: String) -> GuestCBORValue {
            .map(["content_root": .text(root), "content_schema": .text(schema),
                  "id": .text(id), "node_type": .text(type),
                  "partition": .text(partition)])
        }
        func edge(_ from: String, _ to: String, _ position: Int,
                  _ relation: String, _ predicate: String? = nil) -> GuestCBORValue {
            var value: [String: GuestCBORValue] = [
                "from": .text(from), "position": .text(String(position)),
                "relation": .text(relation), "to": .text(to),
            ]
            if let predicate { value["predicate_id"] = .text(predicate) }
            return .map(value)
        }

        var nodes: [GuestCBORValue] = [
            node("input-state", "evidence", "state", inputStateSchema,
                 input.projection.root),
            node("cursor", "evidence", "state-cursor", cursorSchema,
                 cursor.projection.root),
        ]
        nodes += zip(HypervisorStageH3Predicate.allCases, witnesses).enumerated().map {
            index, pair in node("witness-\(index)", "evidence", "witness",
                                witnessSchema, pair.1.projection.root)
        }
        nodes += [
            node("transition", "transition", "transition", transitionSchema,
                 transition.projection.root),
            node("output-state", "evidence", "state", outputStateSchema,
                 output.projection.root),
        ]

        var edges: [GuestCBORValue] = [
            edge("input-state", "transition", 0, "INPUT_STATE"),
            edge("cursor", "transition", 1, "CURSOR_INPUT"),
        ]
        edges += HypervisorStageH3Predicate.allCases.enumerated().map {
            index, predicate in edge("witness-\(index)", "transition", index + 2,
                                     "SATISFIES_PREDICATE", predicate.rawValue)
        }
        edges.append(edge("transition", "output-state", edges.count,
                          "DERIVES_OUTPUT_STATE"))
        return .map([
            "bipartite_rule": .text("EVIDENCE_TO_TRANSITION_OR_TRANSITION_TO_EVIDENCE_ONLY"),
            "edge_count": .text(String(edges.count)), "edges": .array(edges),
            "node_count": .text(String(nodes.count)), "nodes": .array(nodes),
            "schema": .text(graphSchema), "stage_id": .text(stageID),
        ])
    }

    private static func outputStateSemantic(inputRoot: String, cursorRoot: String,
                                            transitionRoot: String) -> GuestCBORValue {
        .map([
            "authority_vector": .text("00000000"),
            "cursor_root": .text(cursorRoot),
            "effects": effectMap(),
            "gate_e": .text("ABSTAIN"),
            "next_stage": .text("NONE"),
            "parent_state_roots": .array([.text(inputRoot)]),
            "schema": .text(outputStateSchema),
            "stage_complete": .bool(false),
            "slice_id": .text("H3_CONTRACT_READINESS"),
            "stage_id": .text(stageID),
            "status": .text("PASS_H3_CURSOR_CONTRACT_ONLY"),
            "successor_authorized": .bool(false),
            "transition_root": .text(transitionRoot),
            "vm_entry_count": .text("0"),
        ])
    }

    private static func effectMap() -> GuestCBORValue {
        .map([
            "clock_read": .bool(false), "environment_read": .bool(false),
            "file_read": .bool(false), "file_write": .bool(false),
            "journal_open": .bool(false), "network": .bool(false),
            "process_launch": .bool(false), "sqlite_open": .bool(false),
            "vm_launch": .bool(false),
        ])
    }

    private static func project(_ semantic: GuestCBORValue, schema: String,
                                role: HypervisorStageH3ProjectionRole) throws -> HypervisorStageProjection {
        let json = try StageCanonicalJSON.encode(semantic)
        let cbor = try GuestCBOR.encode(semantic)
        guard json.count <= maximumStreamBytes, cbor.count <= maximumStreamBytes else {
            throw failure("projection.bound")
        }
        let partial = HypervisorStageProjection(json: json, cbor: cbor, root: "")
        let root = try MerkleGenesis.commit(projectionLeaves(schema: schema,
            projection: partial, role: role)).root
        let projection = HypervisorStageProjection(json: json, cbor: cbor, root: root)
        guard try verify(projection, schema: schema, role: role) == semantic else {
            throw failure("projection.self_verify")
        }
        return projection
    }

    private static func verify(_ projection: HypervisorStageProjection, schema: String,
                               role: HypervisorStageH3ProjectionRole) throws -> GuestCBORValue {
        guard !projection.json.isEmpty, !projection.cbor.isEmpty,
              projection.json.count <= maximumStreamBytes,
              projection.cbor.count <= maximumStreamBytes else { throw failure("projection.bound") }
        let json = try StageCanonicalJSON.decode(projection.json)
        let cbor = try GuestCBOR.decode(projection.cbor)
        guard json == cbor, case .map(let values) = json,
              values["schema"] == .text(schema),
              try MerkleGenesis.verify(projectionLeaves(schema: schema,
                  projection: projection, role: role), expectedRoot: projection.root) else {
            throw failure("projection.join")
        }
        return json
    }

    private static func projectionLeaves(schema: String, projection: HypervisorStageProjection,
                                         role: HypervisorStageH3ProjectionRole) -> [GenesisLeaf] {
        [GenesisLeaf(label: "schema", payload: Data(schema.utf8)),
         GenesisLeaf(label: role.jsonLabel, payload: projection.json),
         GenesisLeaf(label: role.cborLabel, payload: projection.cbor)]
    }

    private static func receiptLeaves(_ receipt: HypervisorStageH3ContractReceipt) throws -> [GenesisLeaf] {
        let state = GuestCBORValue.array([
            try verify(receipt.inputState.projection, schema: inputStateSchema, role: .state),
            try verify(receipt.outputState.projection, schema: outputStateSchema, role: .state),
        ])
        let cursor = try verify(receipt.cursor.projection, schema: cursorSchema, role: .cursor)
        let transition = try verify(receipt.transition.projection,
                                    schema: transitionSchema, role: .transition)
        let witnesses = GuestCBORValue.array(try receipt.witnesses.map {
            try verify($0.projection, schema: witnessSchema, role: .witness)
        })
        let graph = try verify(receipt.graph.projection, schema: graphSchema, role: .graph)
        return [
            GenesisLeaf(label: "schema", payload: Data(receiptSchema.utf8)),
            GenesisLeaf(label: "cursor.json", payload: try StageCanonicalJSON.encode(cursor)),
            GenesisLeaf(label: "cursor.cbor", payload: try GuestCBOR.encode(cursor)),
            GenesisLeaf(label: "graph.json", payload: try StageCanonicalJSON.encode(graph)),
            GenesisLeaf(label: "graph.cbor", payload: try GuestCBOR.encode(graph)),
            GenesisLeaf(label: "state.json", payload: try StageCanonicalJSON.encode(state)),
            GenesisLeaf(label: "state.cbor", payload: try GuestCBOR.encode(state)),
            GenesisLeaf(label: "transition.json", payload: try StageCanonicalJSON.encode(transition)),
            GenesisLeaf(label: "transition.cbor", payload: try GuestCBOR.encode(transition)),
            GenesisLeaf(label: "witnesses.json", payload: try StageCanonicalJSON.encode(witnesses)),
            GenesisLeaf(label: "witnesses.cbor", payload: try GuestCBOR.encode(witnesses)),
        ]
    }

    private static func failure(_ predicate: String) -> HypervisorStageH3CursorFailure {
        .rejected(predicate)
    }
}
