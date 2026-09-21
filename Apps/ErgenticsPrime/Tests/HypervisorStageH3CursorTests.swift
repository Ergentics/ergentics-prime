import Foundation
import XCTest

final class HypervisorStageH3CursorTests: XCTestCase {
    private final class LockedValues<Element>: @unchecked Sendable {
        private let lock = NSLock()
        private var storage: [Element] = []
        func append(_ value: Element) { lock.lock(); storage.append(value); lock.unlock() }
        func snapshot() -> [Element] { lock.lock(); defer { lock.unlock() }; return storage }
    }

    private func role(for schema: String) throws -> String {
        switch schema {
        case HypervisorStageH3Cursor.inputStateSchema,
             HypervisorStageH3Cursor.outputStateSchema: return "state"
        case HypervisorStageH3Cursor.cursorSchema: return "cursor"
        case HypervisorStageH3Cursor.witnessSchema: return "witness"
        case HypervisorStageH3Cursor.transitionSchema: return "transition"
        case HypervisorStageH3Cursor.graphSchema: return "graph"
        default: throw HypervisorStageH3CursorFailure.rejected("test.schema")
        }
    }

    private func projectionRoot(json: Data, cbor: Data, schema: String) throws -> String {
        let role = try role(for: schema)
        return try MerkleGenesis.commit([
            GenesisLeaf(label: "schema", payload: Data(schema.utf8)),
            GenesisLeaf(label: "\(role).json", payload: json),
            GenesisLeaf(label: "\(role).cbor", payload: cbor),
        ]).root
    }

    private func map(_ projection: HypervisorStageProjection) throws -> [String: GuestCBORValue] {
        guard case .map(let values) = try GuestCBOR.decode(projection.cbor) else {
            throw HypervisorStageH3CursorFailure.rejected("test.map")
        }
        return values
    }

    private var repositoryRoot: URL {
        URL(fileURLWithPath: #filePath).deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func git(_ arguments: [String]) throws -> Data {
        let process = Process()
        let output = Pipe()
        let errors = Pipe()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["-C", repositoryRoot.path] + arguments
        process.standardInput = FileHandle.nullDevice
        process.standardOutput = output
        process.standardError = errors
        try process.run()
        process.waitUntilExit()
        let bytes = output.fileHandleForReading.readDataToEndOfFile()
        let diagnostics = errors.fileHandleForReading.readDataToEndOfFile()
        guard process.terminationReason == .exit, process.terminationStatus == 0 else {
            throw HypervisorStageH3CursorFailure.rejected(
                "test.git.\(process.terminationStatus).\(String(decoding: diagnostics, as: UTF8.self))")
        }
        return bytes
    }

    private func receiptRoot(_ receipt: HypervisorStageH3ContractReceipt) throws -> String {
        let state = GuestCBORValue.array([
            try GuestCBOR.decode(receipt.inputState.projection.cbor),
            try GuestCBOR.decode(receipt.outputState.projection.cbor),
        ])
        let cursor = try GuestCBOR.decode(receipt.cursor.projection.cbor)
        let graph = try GuestCBOR.decode(receipt.graph.projection.cbor)
        let transition = try GuestCBOR.decode(receipt.transition.projection.cbor)
        let witnesses = GuestCBORValue.array(try receipt.witnesses.map {
            try GuestCBOR.decode($0.projection.cbor)
        })
        return try MerkleGenesis.commit([
            GenesisLeaf(label: "schema", payload: Data(HypervisorStageH3Cursor.receiptSchema.utf8)),
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
        ]).root
    }

    private func replacing(_ receipt: HypervisorStageH3ContractReceipt,
                           input: HypervisorStageNode? = nil,
                           cursor: HypervisorStageNode? = nil,
                           witnesses: [HypervisorStageNode]? = nil,
                           transition: HypervisorStageNode? = nil,
                           output: HypervisorStageNode? = nil,
                           graph: HypervisorStageNode? = nil) throws -> HypervisorStageH3ContractReceipt {
        let partial = HypervisorStageH3ContractReceipt(
            inputState: input ?? receipt.inputState,
            cursor: cursor ?? receipt.cursor,
            witnesses: witnesses ?? receipt.witnesses,
            transition: transition ?? receipt.transition,
            outputState: output ?? receipt.outputState,
            graph: graph ?? receipt.graph, root: "")
        return HypervisorStageH3ContractReceipt(inputState: partial.inputState,
            cursor: partial.cursor, witnesses: partial.witnesses,
            transition: partial.transition, outputState: partial.outputState,
            graph: partial.graph, root: try receiptRoot(partial))
    }

    private func reproject(_ projection: HypervisorStageProjection,
                           mutate: (inout [String: GuestCBORValue]) -> Void) throws -> HypervisorStageProjection {
        guard case .map(var values) = try GuestCBOR.decode(projection.cbor),
              case .text(let schema)? = values["schema"] else {
            throw HypervisorStageH3CursorFailure.rejected("test.projection")
        }
        mutate(&values)
        let semantic = GuestCBORValue.map(values)
        let json = try StageCanonicalJSON.encode(semantic)
        let cbor = try GuestCBOR.encode(semantic)
        return HypervisorStageProjection(json: json, cbor: cbor,
            root: try projectionRoot(json: json, cbor: cbor, schema: schema))
    }

    private func changedFrame(_ frame: HypervisorStageH3CursorFrame,
                              schema: String? = nil,
                              profile: String? = nil,
                              nextOrdinal: Int? = nil,
                              nextOperation: String? = nil,
                              h2ProductSourceCommit: String? = nil,
                              h2ProductSourceTree: String? = nil,
                              h2ProductResultCommit: String? = nil,
                              h2ProductResultTree: String? = nil,
                              h2ProductResultParentCommit: String? = nil,
                              h2ProductReceiptSHA256: String? = nil,
                              h2ProductReceiptGitBlob: String? = nil,
                              buildArchiveReceiptSHA256: String? = nil,
                              buildArchiveReceiptGitBlob: String? = nil,
                              h2StaticResultSHA256: String? = nil,
                              h2StaticResultGitBlob: String? = nil,
                              h2StaticReceiptRoot: String? = nil,
                              h2StaticOutputStateRoot: String? = nil,
                              h2SnapshotRoot: String? = nil,
                              sourceGeneration: String? = nil,
                              baseStateRoot: String? = nil,
                              checkpointStateRoot: String? = nil,
                              checkpoint: HypervisorStageH3MachineState? = nil) -> HypervisorStageH3CursorFrame {
        HypervisorStageH3CursorFrame(schema: schema ?? frame.schema,
            profile: profile ?? frame.profile,
            h2ProductSourceCommit: h2ProductSourceCommit ?? frame.h2ProductSourceCommit,
            h2ProductSourceTree: h2ProductSourceTree ?? frame.h2ProductSourceTree,
            h2ProductResultCommit: h2ProductResultCommit ?? frame.h2ProductResultCommit,
            h2ProductResultTree: h2ProductResultTree ?? frame.h2ProductResultTree,
            h2ProductResultParentCommit: h2ProductResultParentCommit ?? frame.h2ProductResultParentCommit,
            h2ProductReceiptSHA256: h2ProductReceiptSHA256 ?? frame.h2ProductReceiptSHA256,
            h2ProductReceiptGitBlob: h2ProductReceiptGitBlob ?? frame.h2ProductReceiptGitBlob,
            buildArchiveReceiptSHA256: buildArchiveReceiptSHA256 ?? frame.buildArchiveReceiptSHA256,
            buildArchiveReceiptGitBlob: buildArchiveReceiptGitBlob ?? frame.buildArchiveReceiptGitBlob,
            h2StaticResultSHA256: h2StaticResultSHA256 ?? frame.h2StaticResultSHA256,
            h2StaticResultGitBlob: h2StaticResultGitBlob ?? frame.h2StaticResultGitBlob,
            h2StaticReceiptRoot: h2StaticReceiptRoot ?? frame.h2StaticReceiptRoot,
            h2StaticOutputStateRoot: h2StaticOutputStateRoot ?? frame.h2StaticOutputStateRoot,
            h2SnapshotRoot: h2SnapshotRoot ?? frame.h2SnapshotRoot,
            sourceGeneration: sourceGeneration ?? frame.sourceGeneration,
            baseStateRoot: baseStateRoot ?? frame.baseStateRoot,
            checkpointStateRoot: checkpointStateRoot ?? frame.checkpointStateRoot,
            nextOrdinal: nextOrdinal ?? frame.nextOrdinal,
            nextOperation: nextOperation ?? frame.nextOperation,
            state: checkpoint ?? frame.state)
    }

    func testContractIsDeterministicDualStreamGraphAndNonAuthoritative() throws {
        let first = try HypervisorStageH3Cursor.runContract()
        let second = try HypervisorStageH3Cursor.runContract()
        XCTAssertEqual(first, second)
        XCTAssertEqual(first.root, try receiptRoot(first))
        XCTAssertEqual(first.witnesses.count, HypervisorStageH3Predicate.allCases.count)
        let verified = try HypervisorStageH3Cursor.verifyContract(first)
        XCTAssertEqual(verified.outcome, "PASS_H3_CURSOR_CONTRACT_ONLY")
        XCTAssertEqual(verified.receiptRoot, first.root)
        XCTAssertEqual(verified.cursorRoot, first.cursor.projection.root)
        XCTAssertEqual(verified.graphRoot, first.graph.projection.root)
        XCTAssertEqual(verified.gateE, "ABSTAIN")
        XCTAssertEqual(verified.authorityVector, "00000000")
        XCTAssertEqual(verified.vmEntryCount, 0)
        XCTAssertFalse(verified.stageCompleted)
        XCTAssertFalse(verified.liveResumeAuthorized)
    }

    func testH2CausalLineageJoinsStaticStateSnapshotAndExactParentResultCommit() throws {
        let h2 = try Data(contentsOf: repositoryRoot.appendingPathComponent(
            "Distribution/H2-Product-1.0.5-receipt.json"))
        let archive = try Data(contentsOf: repositoryRoot.appendingPathComponent(
            "Distribution/LocalArchive-1.0.5-receipt.json"))
        let staticResult = try Data(contentsOf: repositoryRoot.appendingPathComponent(
            "Control/hypervisor-local-v1/h2-static-admission-result.v1.json"))
        XCTAssertEqual(GuestContract.hash(h2), HypervisorStageH3Cursor.h2ProductReceiptSHA256)
        XCTAssertEqual(GuestContract.hash(archive), HypervisorStageH3Cursor.buildArchiveReceiptSHA256)
        XCTAssertEqual(GuestContract.hash(staticResult), HypervisorStageH3Cursor.h2StaticResultSHA256)

        let object = try XCTUnwrap(try JSONSerialization.jsonObject(with: h2) as? [String: Any])
        let source = try XCTUnwrap(object["source_checkpoint"] as? [String: Any])
        XCTAssertEqual(source["commit"] as? String, HypervisorStageH3Cursor.h2ProductSourceCommit)
        XCTAssertEqual(source["tree"] as? String, HypervisorStageH3Cursor.h2ProductSourceTree)
        let run = try XCTUnwrap(object["fixed_guest_run"] as? [String: Any])
        XCTAssertEqual(run["snapshot_merkle_sha256"] as? String,
                       HypervisorStageH3Cursor.h2SnapshotRoot)
        let roadmap = try XCTUnwrap(object["roadmap"] as? [String: Any])
        XCTAssertEqual(roadmap["h2_product_local_mechanics"] as? String, "PASS")
        XCTAssertEqual(roadmap["gate_e"] as? String, "ABSTAIN_NONBLOCKING")
        XCTAssertEqual(roadmap["authority_vector"] as? String, "00000000")

        let staticObject = try XCTUnwrap(
            try JSONSerialization.jsonObject(with: staticResult) as? [String: Any])
        let staticGraph = try XCTUnwrap(staticObject["canonical_graph"] as? [String: Any])
        XCTAssertEqual(staticGraph["receipt_root"] as? String,
                       HypervisorStageH3Cursor.h2StaticReceiptRoot)
        XCTAssertEqual(staticGraph["output_state_root"] as? String,
                       HypervisorStageH3Cursor.h2StaticOutputStateRoot)
        let staticGuest = try XCTUnwrap(staticObject["fixed_guest_identity"] as? [String: Any])
        XCTAssertEqual(staticGuest["snapshot_merkle_root"] as? String,
                       HypervisorStageH3Cursor.h2SnapshotRoot)

        func line(_ data: Data) -> String {
            String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        XCTAssertEqual(line(try git(["rev-parse", "\(HypervisorStageH3Cursor.h2ProductSourceCommit)^{tree}"])),
                       HypervisorStageH3Cursor.h2ProductSourceTree)
        XCTAssertEqual(line(try git(["rev-parse", "\(HypervisorStageH3Cursor.h2ProductResultCommit)^{tree}"])),
                       HypervisorStageH3Cursor.h2ProductResultTree)
        XCTAssertEqual(line(try git(["rev-parse", "\(HypervisorStageH3Cursor.h2ProductResultCommit)^1"])),
                       HypervisorStageH3Cursor.h2ProductSourceCommit)
        XCTAssertEqual(line(try git(["diff-tree", "--no-commit-id", "--name-status", "-r",
                                     HypervisorStageH3Cursor.h2ProductResultCommit])),
                       "A\tDistribution/H2-Product-1.0.5-receipt.json")
        XCTAssertEqual(HypervisorStageH3Cursor.h2ProductResultParentCommit,
                       HypervisorStageH3Cursor.h2ProductSourceCommit)
        XCTAssertEqual(line(try git(["rev-parse", "\(HypervisorStageH3Cursor.h2ProductResultCommit):Distribution/H2-Product-1.0.5-receipt.json"])),
                       HypervisorStageH3Cursor.h2ProductReceiptGitBlob)
        XCTAssertEqual(line(try git(["rev-parse", "\(HypervisorStageH3Cursor.h2ProductSourceCommit):Distribution/LocalArchive-1.0.5-receipt.json"])),
                       HypervisorStageH3Cursor.buildArchiveReceiptGitBlob)
        XCTAssertEqual(line(try git(["rev-parse", "\(HypervisorStageH3Cursor.h2ProductSourceCommit):Control/hypervisor-local-v1/h2-static-admission-result.v1.json"])),
                       HypervisorStageH3Cursor.h2StaticResultGitBlob)
        XCTAssertEqual(try git(["show", "\(HypervisorStageH3Cursor.h2ProductResultCommit):Distribution/H2-Product-1.0.5-receipt.json"]), h2)
        XCTAssertEqual(try git(["show", "\(HypervisorStageH3Cursor.h2ProductSourceCommit):Distribution/LocalArchive-1.0.5-receipt.json"]), archive)
        XCTAssertEqual(try git(["show", "\(HypervisorStageH3Cursor.h2ProductSourceCommit):Control/hypervisor-local-v1/h2-static-admission-result.v1.json"]), staticResult)
    }

    func testCursorResumesOnlyTheNextOperationIntoFreshOwner() throws {
        let control = HypervisorStageH3MachineOwner()
        try control.advance(); try control.advance()
        let source = HypervisorStageH3MachineOwner()
        try source.advance()
        let capability = try source.exportCursor()
        let target = HypervisorStageH3MachineOwner()
        try capability.consume(into: target)

        XCTAssertTrue(source.retired)
        XCTAssertEqual(source.executedOrdinals, [0])
        XCTAssertEqual(target.executedOrdinals, [1])
        XCTAssertEqual(target.state, control.state)
        XCTAssertEqual(target.state, HypervisorStageH3Cursor.terminalState)
        XCTAssertEqual(capability.snapshotDisposition(), .consumed)
        XCTAssertNotEqual(ObjectIdentifier(source), ObjectIdentifier(target))
    }

    func testCursorReplayRejectsWithoutChangingFreshTarget() throws {
        let source = HypervisorStageH3MachineOwner(); try source.advance()
        let capability = try source.exportCursor()
        try capability.consume(into: HypervisorStageH3MachineOwner())
        let replay = HypervisorStageH3MachineOwner()
        XCTAssertThrowsError(try capability.consume(into: replay))
        XCTAssertEqual(replay.state, HypervisorStageH3Cursor.initialState)
        XCTAssertTrue(replay.executedOrdinals.isEmpty)
        XCTAssertEqual(capability.snapshotDisposition(), .consumed)
    }

    func testInvalidFramesRejectWithoutMintingCapabilities() throws {
        let source = HypervisorStageH3MachineOwner()
        try source.advance()
        let valid = try source.exportCursor().frame
        let candidates = [
            changedFrame(valid, schema: "cursor.v2"),
            changedFrame(valid, profile: "other-profile"),
            changedFrame(valid, nextOrdinal: 0),
            changedFrame(valid, nextOrdinal: 2),
            changedFrame(valid, nextOperation: "repeat_origin"),
            changedFrame(valid, h2ProductSourceCommit: String(repeating: "0", count: 40)),
            changedFrame(valid, h2ProductSourceTree: String(repeating: "0", count: 40)),
            changedFrame(valid, h2ProductResultCommit: String(repeating: "0", count: 40)),
            changedFrame(valid, h2ProductResultTree: String(repeating: "0", count: 40)),
            changedFrame(valid, h2ProductResultParentCommit: String(repeating: "0", count: 40)),
            changedFrame(valid, h2ProductReceiptSHA256: String(repeating: "0", count: 64)),
            changedFrame(valid, h2ProductReceiptGitBlob: String(repeating: "0", count: 40)),
            changedFrame(valid, buildArchiveReceiptSHA256: String(repeating: "0", count: 64)),
            changedFrame(valid, buildArchiveReceiptGitBlob: String(repeating: "0", count: 40)),
            changedFrame(valid, h2StaticResultSHA256: String(repeating: "0", count: 64)),
            changedFrame(valid, h2StaticResultGitBlob: String(repeating: "0", count: 40)),
            changedFrame(valid, h2StaticReceiptRoot: String(repeating: "0", count: 64)),
            changedFrame(valid, h2StaticOutputStateRoot: String(repeating: "0", count: 64)),
            changedFrame(valid, h2SnapshotRoot: String(repeating: "0", count: 64)),
            changedFrame(valid, sourceGeneration: "rebound-source"),
            changedFrame(valid, baseStateRoot: String(repeating: "0", count: 64)),
            changedFrame(valid, checkpointStateRoot: String(repeating: "0", count: 64)),
            changedFrame(valid, checkpoint: HypervisorStageH3MachineState(
                left: 19, right: 23, accumulator: 41, nextOrdinal: 1)),
            changedFrame(valid, checkpoint: HypervisorStageH3MachineState(
                left: 18, right: 23, accumulator: 42, nextOrdinal: 1)),
            changedFrame(valid, checkpoint: HypervisorStageH3MachineState(
                left: 19, right: 24, accumulator: 42, nextOrdinal: 1)),
            changedFrame(valid, checkpoint: HypervisorStageH3MachineState(
                left: 19, right: 23, accumulator: 42, nextOrdinal: 0)),
        ]
        for candidate in candidates {
            XCTAssertThrowsError(try HypervisorStageH3Cursor.validate(candidate))
        }
    }

    func testNonfreshTargetRejectsAndConsumesCapabilityAsPoison() throws {
        let source = HypervisorStageH3MachineOwner(); try source.advance()
        let capability = try source.exportCursor()
        let target = HypervisorStageH3MachineOwner(); try target.advance()
        let before = target.state
        XCTAssertThrowsError(try capability.consume(into: target))
        XCTAssertEqual(target.state, before)
        XCTAssertEqual(target.executedOrdinals, [0])
        XCTAssertEqual(capability.snapshotDisposition(), .poisoned)
    }

    func testConcurrentConsumeHasExactlyOneWinner() throws {
        let source = HypervisorStageH3MachineOwner(); try source.advance()
        let capability = try source.exportCursor()
        let queue = DispatchQueue(label: "h3.cursor.concurrent", attributes: .concurrent)
        let group = DispatchGroup()
        let outcomes = LockedValues<Bool>()
        let targets = (0..<16).map { _ in HypervisorStageH3MachineOwner() }
        for target in targets {
            group.enter()
            queue.async {
                do {
                    try capability.consume(into: target)
                    outcomes.append(true)
                } catch {
                    outcomes.append(false)
                }
                group.leave()
            }
        }
        XCTAssertEqual(group.wait(timeout: .now() + 5), .success)
        XCTAssertEqual(outcomes.snapshot().filter { $0 }.count, 1)
        XCTAssertEqual(outcomes.snapshot().filter { !$0 }.count, 15)
        XCTAssertEqual(targets.filter { $0.state == HypervisorStageH3Cursor.terminalState }.count, 1)
        XCTAssertEqual(targets.filter { $0.state == HypervisorStageH3Cursor.initialState }.count, 15)
        XCTAssertEqual(capability.snapshotDisposition(), .consumed)
    }

    func testConcurrentExportHasExactlyOneMintAndRetiresSource() throws {
        let source = HypervisorStageH3MachineOwner()
        try source.advance()
        let queue = DispatchQueue(label: "h3.cursor.export", attributes: .concurrent)
        let group = DispatchGroup()
        let capabilities = LockedValues<HypervisorStageH3CursorCapability>()
        let rejected = LockedValues<Bool>()
        for _ in 0..<16 {
            group.enter()
            queue.async {
                do { capabilities.append(try source.exportCursor()) }
                catch { rejected.append(true) }
                group.leave()
            }
        }
        XCTAssertEqual(group.wait(timeout: .now() + 5), .success)
        XCTAssertEqual(capabilities.snapshot().count, 1)
        XCTAssertEqual(rejected.snapshot().count, 15)
        XCTAssertEqual(source.snapshot(), HypervisorStageH3MachineOwnerSnapshot(
            state: HypervisorStageH3Cursor.checkpointState,
            executedOrdinals: [0], retired: true))
        XCTAssertThrowsError(try source.advance())
        XCTAssertThrowsError(try source.exportCursor())
    }

    func testTwoCapabilitiesIntoOneTargetHaveExactlyOneWinner() throws {
        let firstSource = HypervisorStageH3MachineOwner(); try firstSource.advance()
        let secondSource = HypervisorStageH3MachineOwner(); try secondSource.advance()
        let capabilities = [try firstSource.exportCursor(), try secondSource.exportCursor()]
        let target = HypervisorStageH3MachineOwner()
        let queue = DispatchQueue(label: "h3.cursor.shared-target", attributes: .concurrent)
        let group = DispatchGroup()
        let outcomes = LockedValues<Bool>()
        for capability in capabilities {
            group.enter()
            queue.async {
                do { try capability.consume(into: target); outcomes.append(true) }
                catch { outcomes.append(false) }
                group.leave()
            }
        }
        XCTAssertEqual(group.wait(timeout: .now() + 5), .success)
        XCTAssertEqual(outcomes.snapshot().filter { $0 }.count, 1)
        XCTAssertEqual(outcomes.snapshot().filter { !$0 }.count, 1)
        XCTAssertEqual(target.snapshot(), HypervisorStageH3MachineOwnerSnapshot(
            state: HypervisorStageH3Cursor.terminalState,
            executedOrdinals: [1], retired: false))
        XCTAssertEqual(capabilities.filter { $0.snapshotDisposition() == .consumed }.count, 1)
        XCTAssertEqual(capabilities.filter { $0.snapshotDisposition() == .poisoned }.count, 1)
    }

    func testTargetAdvanceRacingConsumeHasOneCoherentMutation() throws {
        let source = HypervisorStageH3MachineOwner(); try source.advance()
        let capability = try source.exportCursor()
        let target = HypervisorStageH3MachineOwner()
        let queue = DispatchQueue(label: "h3.cursor.advance-consume", attributes: .concurrent)
        let group = DispatchGroup()
        let outcomes = LockedValues<Bool>()
        group.enter(); queue.async {
            do { try target.advance(); outcomes.append(true) }
            catch { outcomes.append(false) }
            group.leave()
        }
        group.enter(); queue.async {
            do { try capability.consume(into: target); outcomes.append(true) }
            catch { outcomes.append(false) }
            group.leave()
        }
        XCTAssertEqual(group.wait(timeout: .now() + 5), .success)
        XCTAssertEqual(outcomes.snapshot().filter { $0 }.count, 1)
        XCTAssertEqual(outcomes.snapshot().filter { !$0 }.count, 1)
        let snapshot = target.snapshot()
        XCTAssertTrue(snapshot == HypervisorStageH3MachineOwnerSnapshot(
            state: HypervisorStageH3Cursor.checkpointState,
            executedOrdinals: [0], retired: false) ||
            snapshot == HypervisorStageH3MachineOwnerSnapshot(
                state: HypervisorStageH3Cursor.terminalState,
                executedOrdinals: [1], retired: false))
        XCTAssertEqual(capability.snapshotDisposition(),
            snapshot.state == HypervisorStageH3Cursor.terminalState ? .consumed : .poisoned)
    }

    func testOverflowRejectsWithoutChangingStateOrTrace() throws {
        let first = HypervisorStageH3MachineOwner(initial: HypervisorStageH3MachineState(
            left: UInt64.max, right: 1, accumulator: 0, nextOrdinal: 0))
        let firstBefore = first.snapshot()
        XCTAssertThrowsError(try first.advance())
        XCTAssertEqual(first.snapshot(), firstBefore)

        let second = HypervisorStageH3MachineOwner(initial: HypervisorStageH3MachineState(
            left: 19, right: 23, accumulator: UInt64.max, nextOrdinal: 1))
        let secondBefore = second.snapshot()
        XCTAssertThrowsError(try second.advance())
        XCTAssertEqual(second.snapshot(), secondBefore)
    }

    func testEveryProjectionRoundTripsAndHasIndependentMerkleJoin() throws {
        let receipt = try HypervisorStageH3Cursor.runContract()
        let projections = [receipt.inputState.projection, receipt.cursor.projection] +
            receipt.witnesses.map(\.projection) +
            [receipt.transition.projection, receipt.outputState.projection,
             receipt.graph.projection]
        for projection in projections {
            let json = try StageCanonicalJSON.decode(projection.json)
            let cbor = try GuestCBOR.decode(projection.cbor)
            XCTAssertEqual(json, cbor)
            XCTAssertEqual(try StageCanonicalJSON.encode(json), projection.json)
            XCTAssertEqual(try GuestCBOR.encode(cbor), projection.cbor)
            guard case .map(let values) = cbor,
                  case .text(let schema)? = values["schema"] else { return XCTFail("schema") }
            XCTAssertEqual(projection.root, try projectionRoot(
                json: projection.json, cbor: projection.cbor, schema: schema))
        }
    }

    func testGraphIsBipartiteContentAddressedAndCarriesExactPredicates() throws {
        let receipt = try HypervisorStageH3Cursor.runContract()
        let graph = try map(receipt.graph.projection)
        XCTAssertEqual(graph["stage_id"], .text(HypervisorStageH3Cursor.stageID))
        XCTAssertEqual(graph["bipartite_rule"],
                       .text("EVIDENCE_TO_TRANSITION_OR_TRANSITION_TO_EVIDENCE_ONLY"))
        guard case .array(let nodes)? = graph["nodes"],
              case .array(let edges)? = graph["edges"] else { return XCTFail("graph arrays") }
        XCTAssertEqual(nodes.count, HypervisorStageH3Predicate.allCases.count + 4)
        XCTAssertEqual(edges.count, HypervisorStageH3Predicate.allCases.count + 3)

        var partitions: [String: String] = [:]
        var roots = Set<String>()
        for case .map(let node) in nodes {
            guard case .text(let id)? = node["id"],
                  case .text(let partition)? = node["partition"],
                  case .text(let root)? = node["content_root"] else {
                return XCTFail("graph node")
            }
            XCTAssertNil(partitions.updateValue(partition, forKey: id))
            XCTAssertEqual(root.count, 64)
            XCTAssertTrue(root.utf8.allSatisfy {
                (48...57).contains($0) || (97...102).contains($0)
            })
            roots.insert(root)
        }
        let expectedRoots = Set([receipt.inputState.projection.root,
                                 receipt.cursor.projection.root,
                                 receipt.transition.projection.root,
                                 receipt.outputState.projection.root] +
                                receipt.witnesses.map(\.projection.root))
        XCTAssertEqual(roots, expectedRoots)

        var predicateIDs = Set<String>()
        for (position, edgeValue) in edges.enumerated() {
            guard case .map(let edge) = edgeValue,
                  case .text(let from)? = edge["from"],
                  case .text(let to)? = edge["to"],
                  case .text(let encodedPosition)? = edge["position"],
                  let fromPartition = partitions[from], let toPartition = partitions[to] else {
                return XCTFail("graph edge")
            }
            XCTAssertEqual(encodedPosition, String(position))
            XCTAssertNotEqual(fromPartition, toPartition)
            if case .text(let predicate)? = edge["predicate_id"] {
                predicateIDs.insert(predicate)
            }
        }
        XCTAssertEqual(predicateIDs, Set(HypervisorStageH3Predicate.allCases.map(\.rawValue)))
    }

    func testRehashedCursorSemanticSubstitutionRejects() throws {
        let receipt = try HypervisorStageH3Cursor.runContract()
        let changed = try reproject(receipt.cursor.projection) {
            $0["next_ordinal"] = .text("0")
            $0["next_operation"] = .text("repeat_origin")
        }
        let candidate = try replacing(receipt,
            cursor: HypervisorStageNode(projection: changed))
        XCTAssertThrowsError(try HypervisorStageH3Cursor.verifyContract(candidate))
    }

    func testCrossStreamMismatchRejectsEvenWithFreshProjectionRoot() throws {
        let receipt = try HypervisorStageH3Cursor.runContract()
        let changed = try reproject(receipt.cursor.projection) {
            $0["next_operation"] = .text("repeat_origin")
        }
        let cbor = changed.cbor
        let json = receipt.cursor.projection.json
        let mismatched = HypervisorStageProjection(json: json, cbor: cbor,
            root: try projectionRoot(json: json, cbor: cbor,
                                     schema: HypervisorStageH3Cursor.cursorSchema))
        let candidate = try replacing(receipt,
            cursor: HypervisorStageNode(projection: mismatched))
        XCTAssertThrowsError(try HypervisorStageH3Cursor.verifyContract(candidate))
    }

    func testWitnessOrderReportedPassAndAuthoritySubstitutionReject() throws {
        let receipt = try HypervisorStageH3Cursor.runContract()
        var reversed = receipt.witnesses
        reversed.swapAt(0, 1)
        XCTAssertThrowsError(try HypervisorStageH3Cursor.verifyContract(
            try replacing(receipt, witnesses: reversed)))

        let elevated = try reproject(receipt.outputState.projection) {
            $0["gate_e"] = .text("PASS")
            $0["authority_vector"] = .text("11111111")
            $0["stage_complete"] = .bool(true)
        }
        XCTAssertThrowsError(try HypervisorStageH3Cursor.verifyContract(
            try replacing(receipt, output: HypervisorStageNode(projection: elevated))))
    }

    func testEveryProjectionTypeRejectsContentRootSubstitution() throws {
        let receipt = try HypervisorStageH3Cursor.runContract()
        func rebound(_ node: HypervisorStageNode) -> HypervisorStageNode {
            HypervisorStageNode(projection: HypervisorStageProjection(
                json: node.projection.json, cbor: node.projection.cbor,
                root: String(repeating: "0", count: 64)))
        }
        XCTAssertThrowsError(try HypervisorStageH3Cursor.verifyContract(
            try replacing(receipt, input: rebound(receipt.inputState))))
        XCTAssertThrowsError(try HypervisorStageH3Cursor.verifyContract(
            try replacing(receipt, cursor: rebound(receipt.cursor))))
        var witnesses = receipt.witnesses; witnesses[0] = rebound(witnesses[0])
        XCTAssertThrowsError(try HypervisorStageH3Cursor.verifyContract(
            try replacing(receipt, witnesses: witnesses)))
        XCTAssertThrowsError(try HypervisorStageH3Cursor.verifyContract(
            try replacing(receipt, transition: rebound(receipt.transition))))
        XCTAssertThrowsError(try HypervisorStageH3Cursor.verifyContract(
            try replacing(receipt, output: rebound(receipt.outputState))))
        XCTAssertThrowsError(try HypervisorStageH3Cursor.verifyContract(
            try replacing(receipt, graph: rebound(receipt.graph))))
    }

    func testRehashedInputWitnessTransitionAndGraphSubstitutionsReject() throws {
        let receipt = try HypervisorStageH3Cursor.runContract()
        let input = try reproject(receipt.inputState.projection) {
            $0["h2_static_output_state_root"] = .text(String(repeating: "0", count: 64))
        }
        XCTAssertThrowsError(try HypervisorStageH3Cursor.verifyContract(
            try replacing(receipt, input: HypervisorStageNode(projection: input))))

        let witness = try reproject(receipt.witnesses[0].projection) {
            $0["observed"] = .bool(false); $0["outcome"] = .text("REJECTED")
        }
        var witnesses = receipt.witnesses
        witnesses[0] = HypervisorStageNode(projection: witness)
        XCTAssertThrowsError(try HypervisorStageH3Cursor.verifyContract(
            try replacing(receipt, witnesses: witnesses)))

        let transition = try reproject(receipt.transition.projection) {
            $0["successor_authorized"] = .bool(true)
            $0["derived_outcome"] = .text("PASS_PRODUCT_H3")
        }
        XCTAssertThrowsError(try HypervisorStageH3Cursor.verifyContract(
            try replacing(receipt, transition: HypervisorStageNode(projection: transition))))

        let graph = try reproject(receipt.graph.projection) {
            if case .array(var edges)? = $0["edges"], case .map(var first) = edges[0] {
                first["relation"] = .text("BYPASSES_TRANSITION")
                edges[0] = .map(first); $0["edges"] = .array(edges)
            }
        }
        XCTAssertThrowsError(try HypervisorStageH3Cursor.verifyContract(
            try replacing(receipt, graph: HypervisorStageNode(projection: graph))))
    }

    func testMalformedCanonicalStreamsRejectAfterProjectionRehash() throws {
        let receipt = try HypervisorStageH3Cursor.runContract()
        let base = receipt.cursor.projection
        func candidate(json: Data, cbor: Data) throws -> HypervisorStageH3ContractReceipt {
            let projection = HypervisorStageProjection(json: json, cbor: cbor,
                root: try projectionRoot(json: json, cbor: cbor,
                    schema: HypervisorStageH3Cursor.cursorSchema))
            return try replacing(receipt, cursor: HypervisorStageNode(projection: projection))
        }

        var trailingJSON = base.json; trailingJSON.append(10)
        XCTAssertThrowsError(try HypervisorStageH3Cursor.verifyContract(
            try candidate(json: trailingJSON, cbor: base.cbor)))

        var trailingCBOR = base.cbor; trailingCBOR.append(0)
        XCTAssertThrowsError(try HypervisorStageH3Cursor.verifyContract(
            try candidate(json: base.json, cbor: trailingCBOR)))

        let body = try XCTUnwrap(String(data: base.json, encoding: .utf8))
        let duplicate = Data(("{\"schema\":\"\(HypervisorStageH3Cursor.cursorSchema)\"," +
                              body.dropFirst()).utf8)
        XCTAssertThrowsError(try HypervisorStageH3Cursor.verifyContract(
            try candidate(json: duplicate, cbor: base.cbor)))

        let oversized = Data(repeating: 0x20,
            count: HypervisorStageH3Cursor.maximumStreamBytes + 1)
        XCTAssertThrowsError(try HypervisorStageH3Cursor.verifyContract(
            try candidate(json: oversized, cbor: base.cbor)))
    }

    func testEffectsStayEmptyAndH4IsNotAuthorized() throws {
        let receipt = try HypervisorStageH3Cursor.runContract()
        let input = try map(receipt.inputState.projection)
        let output = try map(receipt.outputState.projection)
        guard case .map(let inputEffects)? = input["effects"],
              case .map(let outputEffects)? = output["effects"] else {
            return XCTFail("effects")
        }
        XCTAssertEqual(inputEffects.count, 9)
        XCTAssertTrue(inputEffects.values.allSatisfy { $0 == .bool(false) })
        XCTAssertEqual(outputEffects, inputEffects)
        XCTAssertEqual(output["next_stage"], .text("NONE"))
        XCTAssertEqual(output["successor_authorized"], .bool(false))
        XCTAssertEqual(output["stage_complete"], .bool(false))
        XCTAssertEqual(output["vm_entry_count"], .text("0"))
    }

    func testReadinessSourceClosesMintingAndHasNoLiveOrDurableSurface() throws {
        let source = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
            .deletingLastPathComponent().appendingPathComponent(
                "Sources/HypervisorStageH3Cursor.swift")
        let text = try String(contentsOf: source, encoding: .utf8)
        XCTAssertTrue(text.contains("fileprivate init(frame:"))
        XCTAssertTrue(text.contains("fileprivate static func makeFrame"))
        for forbidden in ["hv_vcpu_", "hv_vm_", "epr_guest_", "GuestJournal",
                          "SQLite3", "FileManager", "Process(", "CommandLine",
                          "Date(", "UUID(", "SwiftUI", "AppKit"] {
            XCTAssertFalse(text.contains(forbidden), forbidden)
        }
    }
}
