import CryptoKit
import Foundation
import XCTest

@MainActor
final class DeltaPUDemoVerificationTests: XCTestCase {
    private struct Sample {
        let before: DeltaPUSnapshot
        let delta: DeltaPUInputDelta
        let transition: DeltaPUTransition
    }

    private func node(_ id: UInt32, _ operation: DeltaPUOperation) -> DeltaPUNode {
        DeltaPUNode(id: id, operation: operation)
    }

    private func sample(_ nodes: [DeltaPUNode], edits: [DeltaPUEdit]) async throws -> Sample {
        let engine = try DeltaPUEngine(nodes: nodes)
        let before = await engine.snapshot()
        let delta = DeltaPUInputDelta(baseStateID: before.stateID, edits: edits)
        return Sample(before: before, delta: delta, transition: try await engine.apply(delta))
    }

    private func simple() async throws -> Sample {
        try await sample([node(1, .literal(19)), node(2, .literal(23)), node(3, .add(1, 2))],
                         edits: [.replace(node(1, .literal(20)))])
    }

    private func verify(_ sample: Sample, transition: DeltaPUTransition? = nil,
                        before: DeltaPUSnapshot? = nil, delta: DeltaPUInputDelta? = nil) throws -> DeltaPUVerifiedTransition {
        try DeltaPUDemoVerification.verify(before: before ?? sample.before, delta: delta ?? sample.delta,
                                          transition: transition ?? sample.transition)
    }

    private func changed(_ value: DeltaPUTransition, from: String? = nil, deltaID: String? = nil,
                         bytes: Data? = nil, snapshot: DeltaPUSnapshot? = nil,
                         output: [DeltaPUOutputEdit]? = nil, work: DeltaPUWork? = nil,
                         committed: Bool? = nil) -> DeltaPUTransition {
        DeltaPUTransition(fromStateID: from ?? value.fromStateID, deltaID: deltaID ?? value.deltaID,
            deltaCBOR: bytes ?? value.deltaCBOR, snapshot: snapshot ?? value.snapshot,
            outputDelta: output ?? value.outputDelta, work: work ?? value.work, committed: committed ?? value.committed)
    }

    private func hash(_ bytes: Data) -> String {
        SHA256.hash(data: bytes).map { String(format: "%02x", $0) }.joined()
    }

    // Test-side reconstruction can rehash false data. Verification must still
    // reject semantic inconsistency instead of merely trusting hashes.
    private func resealed(_ original: DeltaPUSnapshot, nodes: [DeltaPUNode]? = nil,
                          values: [UInt32: Int64]? = nil, revision: UInt64? = nil,
                          parent: String? = nil, delta: String? = nil,
                          contentOverride: GuestCBORValue? = nil) throws -> DeltaPUSnapshot {
        let nodes = nodes ?? original.nodes, values = values ?? original.values
        func operation(_ op: DeltaPUOperation) -> GuestCBORValue {
            switch op {
            case .literal(let n): return .array([.unsigned(0), .unsigned(UInt64(bitPattern: n))])
            case .add(let a, let b): return .array([.unsigned(1), .unsigned(UInt64(a)), .unsigned(UInt64(b))])
            case .select(let c, let a, let b):
                return .array([.unsigned(2), .unsigned(UInt64(c)), .unsigned(UInt64(a)), .unsigned(UInt64(b))])
            }
        }
        let content = contentOverride ?? .map([
            "schema": .text("ergentics.deltapu.graph.v1"),
            "nodes": .array(nodes.map { .map(["id": .unsigned(UInt64($0.id)), "op": operation($0.operation)]) }),
            "values": .array(values.keys.sorted().map { .array([.unsigned(UInt64($0)), .unsigned(UInt64(bitPattern: values[$0]!))]) })
        ])
        let bytes = try GuestCBOR.encode(content)
        let root = try MerkleGenesis.commit([
            GenesisLeaf(label: "schema", payload: Data("ergentics.deltapu.graph.v1".utf8)),
            GenesisLeaf(label: "graph", payload: bytes)
        ]).root
        let revision = revision ?? original.revision
        let parent = parent ?? original.parentStateID, delta = delta ?? original.appliedDeltaID
        let version = try GuestCBOR.encode(.map([
            "schema": .text("ergentics.deltapu.state.v1"), "revision": .unsigned(revision),
            "parent_state_id": .text(parent ?? ""), "delta_id": .text(delta ?? ""), "content_root": .text(root)
        ]))
        return DeltaPUSnapshot(nodes: nodes, values: values, revision: revision,
            parentStateID: parent, appliedDeltaID: delta, contentRoot: root,
            stateID: hash(version), contentCBOR: bytes, versionCBOR: version)
    }

    func testSparseRowsAndActualFullEvaluationCounts() async throws {
        let graph = (0..<16).flatMap { component -> [DeltaPUNode] in
            let id = UInt32(component * 4 + 1)
            return [node(id, .literal(1)), node(id + 1, .literal(2)),
                    node(id + 2, .add(id, id + 1)), node(id + 3, .add(id + 2, id + 1))]
        }
        let s = try await sample(graph, edits: [.replace(node(1, .literal(7)))])
        let result = try verify(s)
        XCTAssertEqual(result.beforeNodeEvaluations, 64)
        XCTAssertEqual(result.afterNodeEvaluations, 64)
        XCTAssertEqual(result.afterOperandReads, 64)
        XCTAssertEqual(result.rows.map(\.id), Array(UInt32(1)...64))
        XCTAssertEqual(result.rows.filter { $0.status == .changed }.map(\.id), [1, 3, 4])
        XCTAssertEqual(result.rows.filter { $0.status == .reused }.count, 61)
        XCTAssertEqual(result.rows.filter(\.definitionChanged).map(\.id), [1])
        XCTAssertEqual(result.rows.first?.oldValue, 1)
        XCTAssertEqual(result.rows.first?.newValue, 7)
    }

    func testDenseFullClosureAndRepeatedOperandAccounting() async throws {
        var nodes = [node(1, .literal(1))]
        for id in UInt32(2)...64 { nodes.append(node(id, .add(id - 1, 1))) }
        let s = try await sample(nodes, edits: [.replace(node(1, .literal(2)))])
        let result = try verify(s)
        XCTAssertEqual(result.afterNodeEvaluations, 64)
        XCTAssertEqual(result.afterOperandReads, 126)
        XCTAssertEqual(result.rows.filter { $0.status == .changed }.count, 64)
        XCTAssertEqual(s.transition.work.invalidationEdgesVisited, 125)
    }

    func testEmptyAndExactReplacementNoOpsKeepIdentity() async throws {
        let noOps: [[DeltaPUEdit]] = [[], [.replace(node(1, .literal(-7)))]]
        for edits in noOps {
            let s = try await sample([node(1, .literal(-7))], edits: edits)
            let result = try verify(s)
            XCTAssertEqual(result.rows.map(\.status), [.reused])
            XCTAssertEqual(result.beforeNodeEvaluations, 1)
            XCTAssertEqual(result.afterNodeEvaluations, 1)
            XCTAssertEqual(result.afterOperandReads, 0)
            XCTAssertFalse(s.transition.committed)
        }
        let empty = try await sample([], edits: [])
        XCTAssertEqual(try verify(empty).rows, [])
        XCTAssertEqual(try verify(empty).afterNodeEvaluations, 0)
    }

    func testAffectedUnchangedIsNotMislabelledAsReused() async throws {
        let s = try await sample([
            node(1, .literal(0)), node(2, .literal(19)), node(3, .literal(23)),
            node(4, .select(condition: 1, ifNonzero: 2, ifZero: 3))
        ], edits: [.replace(node(2, .literal(20)))])
        let rows = try verify(s).rows
        XCTAssertEqual(rows.map(\.status), [.reused, .changed, .reused, .affectedUnchanged])
        XCTAssertEqual(rows[3].oldValue, 23)
        XCTAssertEqual(rows[3].newValue, 23)
        XCTAssertFalse(rows[3].definitionChanged)
    }

    func testChangedDefinitionWithIdenticalOutputStillCommits() async throws {
        let s = try await sample([node(1, .literal(2)), node(2, .literal(2)), node(3, .add(1, 1))],
                                 edits: [.replace(node(3, .add(2, 2)))])
        let result = try verify(s)
        XCTAssertTrue(s.transition.committed)
        XCTAssertTrue(s.transition.outputDelta.isEmpty)
        XCTAssertEqual(result.rows[2].status, .affectedUnchanged)
        XCTAssertTrue(result.rows[2].definitionChanged)
    }

    func testAtomicEditAndRemovalUseOldAndNewEdges() async throws {
        let s = try await sample([node(1, .literal(5)), node(2, .add(1, 1)), node(3, .add(2, 2))],
            edits: [.remove(1), .replace(node(2, .add(4, 4))), .insert(node(4, .literal(7)))])
        let result = try verify(s)
        XCTAssertEqual(result.beforeNodeEvaluations, 3)
        XCTAssertEqual(result.afterNodeEvaluations, 3)
        XCTAssertEqual(result.rows.map(\.status), [.removed, .changed, .changed, .changed])
        XCTAssertNil(result.rows[0].newValue)
        XCTAssertNil(result.rows[3].oldValue)
        XCTAssertEqual(s.transition.work.invalidationEdgesVisited, 3)
        let emptied = try await sample([node(1, .literal(3)), node(2, .add(1, 1))],
                                       edits: [.remove(2), .remove(1)])
        XCTAssertEqual(try verify(emptied).rows.map(\.status), [.removed, .removed])
        XCTAssertEqual(try verify(emptied).afterNodeEvaluations, 0)
    }

    func testEveryWorkCounterForgeryIsRejected() async throws {
        let s = try await simple()
        let fields: [WritableKeyPath<DeltaPUWork, Int>] = [
            \.submittedEdits, \.changedDefinitions, \.nodesValidated, \.operandEdgesValidated,
            \.invalidatedNodes, \.invalidationEdgesVisited, \.nodesEvaluated, \.operandReads,
            \.valuesReused, \.outputComparisons, \.commitmentPayloadBytes
        ]
        for field in fields {
            var work = s.transition.work
            work[keyPath: field] += 1
            XCTAssertThrowsError(try verify(s, transition: changed(s.transition, work: work))) {
                XCTAssertEqual($0 as? DeltaPUDemoVerification.Failure, .wrongWork)
            }
            work[keyPath: field] = -1
            XCTAssertThrowsError(try verify(s, transition: changed(s.transition, work: work)))
        }
    }

    func testForgedMaterializedValuesAreRejectedAfterAllHashesResealed() async throws {
        let s = try await simple()
        var values = s.transition.snapshot.values
        values[3] = 999
        let forged = try resealed(s.transition.snapshot, values: values)
        XCTAssertThrowsError(try verify(s, transition: changed(s.transition, snapshot: forged)))
        var oldValues = s.before.values
        oldValues[1] = 888
        XCTAssertThrowsError(try verify(s, before: resealed(s.before, values: oldValues)))
    }

    func testForgedDeltaInputHashAndCanonicalBytesAreRejected() async throws {
        let s = try await simple()
        XCTAssertThrowsError(try verify(s, delta: DeltaPUInputDelta(baseStateID: s.before.stateID,
            edits: [.replace(node(1, .literal(21)))])))
        XCTAssertThrowsError(try verify(s, transition: changed(s.transition, deltaID: String(repeating: "0", count: 64))))
        var trailing = s.transition.deltaCBOR; trailing.append(0)
        XCTAssertThrowsError(try verify(s, transition: changed(s.transition, deltaID: hash(trailing), bytes: trailing)))
        let replacementBytes = try GuestCBOR.encode(.map([
            "schema": .text("ergentics.deltapu.delta.v1"), "base_state_id": .text(s.before.stateID),
            "edits": .array([.array([.unsigned(1), .unsigned(1), .array([.unsigned(0), .unsigned(21)])])])
        ]))
        let newHash = hash(replacementBytes)
        let rehashedState = try resealed(s.transition.snapshot, delta: newHash)
        XCTAssertThrowsError(try verify(s, transition: changed(s.transition, deltaID: newHash,
            bytes: replacementBytes, snapshot: rehashedState)))
    }

    func testResealedAncestryRevisionAndCommitForgeryAreRejected() async throws {
        let s = try await simple()
        XCTAssertThrowsError(try verify(s, transition: changed(s.transition,
            snapshot: resealed(s.transition.snapshot, revision: 2))))
        XCTAssertThrowsError(try verify(s, transition: changed(s.transition,
            snapshot: resealed(s.transition.snapshot, parent: String(repeating: "a", count: 64)))))
        XCTAssertThrowsError(try verify(s, transition: changed(s.transition,
            snapshot: resealed(s.transition.snapshot, delta: String(repeating: "b", count: 64)))))
        XCTAssertThrowsError(try verify(s, transition: changed(s.transition, committed: false)))
        XCTAssertThrowsError(try verify(s, transition: changed(s.transition, from: s.transition.snapshot.stateID)))
        XCTAssertThrowsError(try verify(s, delta: DeltaPUInputDelta(baseStateID: s.transition.snapshot.stateID, edits: s.delta.edits)))
        let noOp = try await sample([node(1, .literal(1))], edits: [])
        XCTAssertThrowsError(try verify(noOp, transition: changed(noOp.transition, committed: true)))
    }

    func testOutputMustBeExactMinimalSortedDifference() async throws {
        let s = try await simple()
        let outputs: [[DeltaPUOutputEdit]] = [
            [], [.set(1, 20)], [.set(1, 20), .set(3, 99)],
            [.set(3, 43), .set(1, 20)], [.set(1, 20), .set(1, 20), .set(3, 43)],
            [.set(1, 20), .set(2, 23), .set(3, 43)], [.remove(1), .set(3, 43)]
        ]
        for output in outputs {
            XCTAssertThrowsError(try verify(s, transition: changed(s.transition, output: output)))
        }
    }

    func testMalformedSchemaOrderingAndExtraFieldsRejectEvenResealed() async throws {
        let s = try await simple()
        guard case .map(let original) = try GuestCBOR.decode(s.transition.snapshot.contentCBOR) else {
            return XCTFail("expected map")
        }
        var wrongSchema = original; wrongSchema["schema"] = .text("unknown")
        var extra = original; extra["authority"] = .bool(true)
        var wrongOrder = original
        if case .array(let nodes) = original["nodes"] { wrongOrder["nodes"] = .array(Array(nodes.reversed())) }
        for content in [wrongSchema, extra, wrongOrder] {
            XCTAssertThrowsError(try verify(s, transition: changed(s.transition,
                snapshot: resealed(s.transition.snapshot, contentOverride: .map(content)))))
        }
    }

    func testResealedCyclesMissingDependenciesAndOverflowReject() async throws {
        let s = try await simple()
        for nodes in [
            [node(1, .add(1, 1)), node(2, .literal(23)), node(3, .add(1, 2))],
            [node(1, .add(99, 99)), node(2, .literal(23)), node(3, .add(1, 2))],
            [node(1, .literal(Int64.max)), node(2, .literal(23)), node(3, .add(1, 2))]
        ] {
            XCTAssertThrowsError(try verify(s, transition: changed(s.transition,
                snapshot: resealed(s.transition.snapshot, nodes: nodes))))
        }
    }

    func testBoundsDuplicateEditsAndExistencePreconditionsFailClosed() async throws {
        let s = try await simple()
        XCTAssertThrowsError(try verify(s, delta: DeltaPUInputDelta(baseStateID: s.before.stateID,
            edits: Array(repeating: .replace(node(1, .literal(20))), count: 129))))
        let invalidEdits: [[DeltaPUEdit]] = [
            [.replace(node(1, .literal(20))), .remove(1)], [.insert(node(1, .literal(20)))],
            [.replace(node(99, .literal(20)))], [.remove(99)], [.insert(node(0, .literal(20)))]
        ]
        for edits in invalidEdits {
            XCTAssertThrowsError(try verify(s, delta: DeltaPUInputDelta(baseStateID: s.before.stateID, edits: edits)))
        }
        XCTAssertThrowsError(try verify(s, transition: changed(s.transition,
            bytes: Data(repeating: 0, count: 65_537))))
        XCTAssertThrowsError(try verify(s, transition: changed(s.transition,
            output: Array(repeating: .remove(1), count: 257))))
        let oversized = DeltaPUSnapshot(nodes: Array(repeating: node(1, .literal(0)), count: 129),
            values: s.before.values, revision: s.before.revision, parentStateID: s.before.parentStateID,
            appliedDeltaID: s.before.appliedDeltaID, contentRoot: s.before.contentRoot, stateID: s.before.stateID,
            contentCBOR: s.before.contentCBOR, versionCBOR: s.before.versionCBOR)
        XCTAssertThrowsError(try verify(s, before: oversized))
    }

    func testSignedBitsMaximumIDAndNegativeSelectCondition() async throws {
        let s = try await sample([
            node(1, .literal(Int64.min)), node(2, .literal(Int64.max)),
            node(3, .add(1, 2)), node(UInt32.max, .select(condition: 1, ifNonzero: 3, ifZero: 2))
        ], edits: [.replace(node(2, .literal(Int64.max - 1)))])
        let result = try verify(s)
        XCTAssertEqual(result.rows.last?.id, UInt32.max)
        XCTAssertEqual(result.rows.last?.newValue, -2)
        XCTAssertEqual(result.afterOperandReads, 5)
    }

    func testPreCancelledVerificationCannotPublishResult() async throws {
        let s = try await simple()
        let task = Task {
            withUnsafeCurrentTask { $0?.cancel() }
            return try DeltaPUDemoVerification.verify(before: s.before, delta: s.delta, transition: s.transition)
        }
        do { _ = try await task.value; XCTFail("cancelled verifier returned") }
        catch { XCTAssertTrue(error is CancellationError) }
    }
}
