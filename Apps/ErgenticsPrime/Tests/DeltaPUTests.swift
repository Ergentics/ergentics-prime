import CryptoKit
import Darwin
import Foundation
import XCTest

@MainActor
final class DeltaPUTests: XCTestCase {
    private func node(_ id: UInt32, _ operation: DeltaPUOperation) -> DeltaPUNode {
        DeltaPUNode(id: id, operation: operation)
    }
    private func hash(_ bytes: Data) -> String {
        SHA256.hash(data: bytes).map { String(format: "%02x", $0) }.joined()
    }
    private func baseGraph() -> [DeltaPUNode] {
        [node(1, .literal(19)), node(2, .literal(23)), node(3, .add(1, 2)),
         node(4, .literal(1)), node(5, .select(condition: 4, ifNonzero: 3, ifZero: 2))]
    }
    @discardableResult
    private func checkedApply(_ engine: DeltaPUEngine, _ edits: [DeltaPUEdit]) async throws -> DeltaPUTransition {
        let before = await engine.snapshot()
        let expectedNodes = try DeltaPUReference.applying(edits, to: before.nodes)
        let reference = try DeltaPUReference.measuredEvaluation(expectedNodes)
        let delta = DeltaPUInputDelta(baseStateID: before.stateID, edits: edits)
        let transition = try await engine.apply(delta)
        let after = await engine.snapshot()
        XCTAssertEqual(transition.fromStateID, before.stateID)
        XCTAssertEqual(transition.snapshot, after)
        XCTAssertEqual(after.values, reference.values)
        XCTAssertEqual(after.nodes, expectedNodes)
        XCTAssertEqual(try DeltaPUReference.applyingOutput(transition.outputDelta, to: before.values), reference.values)
        XCTAssertEqual(transition.deltaID, hash(transition.deltaCBOR))
        XCTAssertEqual(try GuestCBOR.decode(transition.deltaCBOR), expectedDelta(base: before.stateID, edits: edits))
        let expectedOutput: [DeltaPUOutputEdit] = Set(before.values.keys).union(reference.values.keys).sorted().compactMap { id in
            if let value = reference.values[id] {
                return before.values[id] == value ? nil : .set(id, value)
            }
            return .remove(id)
        }
        XCTAssertEqual(transition.outputDelta, expectedOutput, "Output delta must be the exact minimal sorted difference")
        XCTAssertEqual(transition.committed, before.nodes != expectedNodes)
        if transition.committed {
            XCTAssertEqual(after.revision, before.revision + 1)
            XCTAssertEqual(after.parentStateID, before.stateID)
            XCTAssertEqual(after.appliedDeltaID, transition.deltaID)
            XCTAssertNotEqual(after.stateID, before.stateID)
        } else {
            XCTAssertEqual(before, after)
            XCTAssertTrue(transition.outputDelta.isEmpty)
        }
        XCTAssertEqual(transition.work.nodesEvaluated + transition.work.valuesReused, after.nodes.count)
        XCTAssertLessThanOrEqual(transition.work.nodesEvaluated, reference.nodeEvaluations)
        try DeltaPUReference.verify(after)
        // Exercise the now-precommit verifier across this suite's generic
        // edits and histories, independently of the two closed demo scenarios.
        let verified = try DeltaPUDemoVerification.verify(before: before, delta: delta, transition: transition)
        XCTAssertEqual(verified.afterNodeEvaluations, reference.nodeEvaluations)
        XCTAssertEqual(verified.afterOperandReads, reference.operandReads)
        XCTAssertEqual(verified.rows.map(\.id), Set(before.values.keys).union(after.values.keys).sorted())
        return transition
    }
    // Separate literal schema reconstruction, not the engine's encoder.
    private func expectedDelta(base: String, edits: [DeltaPUEdit]) -> GuestCBORValue {
        func operation(_ value: DeltaPUOperation) -> GuestCBORValue {
            switch value {
            case .literal(let number): return .array([.unsigned(0), .unsigned(UInt64(bitPattern: number))])
            case .add(let a, let b): return .array([.unsigned(1), .unsigned(UInt64(a)), .unsigned(UInt64(b))])
            case .select(let c, let a, let b):
                return .array([.unsigned(2), .unsigned(UInt64(c)), .unsigned(UInt64(a)), .unsigned(UInt64(b))])
            }
        }
        let rows: [(UInt32, GuestCBORValue)] = edits.map { edit in
            switch edit {
            case .insert(let node): return (node.id, .array([.unsigned(0), .unsigned(UInt64(node.id)), operation(node.operation)]))
            case .replace(let node): return (node.id, .array([.unsigned(1), .unsigned(UInt64(node.id)), operation(node.operation)]))
            case .remove(let id): return (id, .array([.unsigned(2), .unsigned(UInt64(id))]))
            }
        }
        return .map(["schema": .text("ergentics.deltapu.delta.v1"), "base_state_id": .text(base),
                     "edits": .array(rows.sorted { $0.0 < $1.0 }.map { $0.1 })])
    }
    private func rejected(_ engine: DeltaPUEngine, _ edits: [DeltaPUEdit],
                          _ expected: DeltaPUFailure, base: String? = nil) async {
        let before = await engine.snapshot()
        do {
            _ = try await engine.apply(DeltaPUInputDelta(baseStateID: base ?? before.stateID, edits: edits))
            XCTFail("Expected rejection: " + String(describing: expected))
        } catch {
            XCTAssertEqual(error as? DeltaPUFailure, expected)
        }
        let after = await engine.snapshot()
        XCTAssertEqual(after, before, "Every rejected transaction must roll back all state")
    }

    func testGenesisMaterializationAndIndependentRoundTrip() async throws {
        let engine = try DeltaPUEngine(nodes: Array(baseGraph().reversed()))
        let snapshot = await engine.snapshot()
        XCTAssertEqual(snapshot.values, [1:19, 2:23, 3:42, 4:1, 5:42])
        XCTAssertEqual(snapshot.nodes.map(\.id), [1,2,3,4,5])
        XCTAssertEqual(snapshot.revision, 0)
        XCTAssertNil(snapshot.parentStateID)
        XCTAssertNil(snapshot.appliedDeltaID)
        let work = await engine.initializationWork()
        XCTAssertEqual(work.nodesEvaluated, 5)
        XCTAssertEqual(work.operandReads, 5)
        XCTAssertEqual(work.valuesReused, 0)
        try DeltaPUReference.verify(snapshot)
    }

    func testInputOrderIsNotIdentity() async throws {
        let a = try DeltaPUEngine(nodes: baseGraph())
        let b = try DeltaPUEngine(nodes: Array(baseGraph().reversed()))
        let first = await a.snapshot(), second = await b.snapshot()
        XCTAssertEqual(first, second)
    }

    func testSignedIntegerExtremesAndNegativeCondition() async throws {
        let engine = try DeltaPUEngine(nodes: [
            node(1, .literal(Int64.min)), node(2, .literal(Int64.max)),
            node(3, .add(1, 2)), node(4, .select(condition: 1, ifNonzero: 3, ifZero: 2))])
        let snapshot = await engine.snapshot()
        XCTAssertEqual(snapshot.values[3], -1)
        XCTAssertEqual(snapshot.values[4], -1)
        try DeltaPUReference.verify(snapshot)
    }

    func testInitialAdmissionRejectsDuplicatesZeroMissingCyclesAndOverflow() {
        XCTAssertThrowsError(try DeltaPUEngine(nodes: [node(1, .literal(0)), node(1, .literal(1))]))
        XCTAssertThrowsError(try DeltaPUEngine(nodes: [node(0, .literal(0))]))
        XCTAssertThrowsError(try DeltaPUEngine(nodes: [node(1, .add(2, 2))]))
        XCTAssertThrowsError(try DeltaPUEngine(nodes: [node(1, .add(1, 1))]))
        XCTAssertThrowsError(try DeltaPUEngine(nodes: [node(1, .add(2, 2)), node(2, .add(1, 1))]))
        XCTAssertThrowsError(try DeltaPUEngine(nodes: [
            node(1, .literal(Int64.max)), node(2, .literal(1)), node(3, .add(1, 2))]))
        XCTAssertThrowsError(try DeltaPUEngine(nodes: (1...129).map { node(UInt32($0), .literal(0)) }))
    }

    func testSparseUpdateMeasuresActualEvaluationSavingsAndFullGraphOverhead() async throws {
        let graph = (0..<16).flatMap { index -> [DeltaPUNode] in
            let id = UInt32(index * 4 + 1)
            return [node(id, .literal(1)), node(id + 1, .literal(2)),
                    node(id + 2, .add(id, id + 1)), node(id + 3, .add(id + 2, id + 1))]
        }
        let engine = try DeltaPUEngine(nodes: graph)
        let result = try await checkedApply(engine, [.replace(node(1, .literal(7)))])
        let reference = try DeltaPUReference.measuredEvaluation(result.snapshot.nodes)
        XCTAssertEqual(result.work.nodesEvaluated, 3)
        XCTAssertEqual(result.work.valuesReused, 61)
        XCTAssertEqual(reference.nodeEvaluations, 64)
        XCTAssertEqual(result.work.nodesValidated, 64)
        XCTAssertEqual(result.work.operandEdgesValidated, 64)
        XCTAssertEqual(result.work.outputComparisons, 64)
        XCTAssertGreaterThan(result.work.commitmentPayloadBytes, 0)
        try emitWork("sparse_three_of_sixty_four", result, reference)
    }

    func testWholeGraphAffectedIsReportedWithoutSavingsClaim() async throws {
        var graph = [node(1, .literal(1))]
        for id in UInt32(2)...64 { graph.append(node(id, .add(id - 1, 1))) }
        let engine = try DeltaPUEngine(nodes: graph)
        let result = try await checkedApply(engine, [.replace(node(1, .literal(2)))])
        let reference = try DeltaPUReference.measuredEvaluation(result.snapshot.nodes)
        XCTAssertEqual(result.work.nodesEvaluated, 64)
        XCTAssertEqual(result.work.valuesReused, 0)
        XCTAssertEqual(reference.nodeEvaluations, 64)
        try emitWork("all_sixty_four_affected", result, reference)
    }

    private func emitWork(_ name: String, _ result: DeltaPUTransition,
                          _ reference: (values: [UInt32:Int64], nodeEvaluations: Int, operandReads: Int)) throws {
        let work = result.work
        let report: [String:Any] = [
            "schema": "ergentics.deltapu.work-observation.v1", "case": name,
            "oracle_equal": result.snapshot.values == reference.values,
            "nodes": result.snapshot.nodes.count, "revision": result.snapshot.revision,
            "state_id": result.snapshot.stateID, "content_root": result.snapshot.contentRoot,
            "submitted_edits": work.submittedEdits, "changed_definitions": work.changedDefinitions,
            "validated_nodes": work.nodesValidated, "validated_operand_edges": work.operandEdgesValidated,
            "invalidated_nodes": work.invalidatedNodes, "invalidation_edges_visited": work.invalidationEdgesVisited,
            "incremental_node_evaluations": work.nodesEvaluated, "incremental_operand_reads": work.operandReads,
            "reused_values": work.valuesReused, "output_comparisons": work.outputComparisons,
            "commitment_payload_bytes": work.commitmentPayloadBytes,
            "full_reference_node_evaluations": reference.nodeEvaluations,
            "full_reference_operand_reads": reference.operandReads,
            "qualification": "Logical work counters, not CPU time, wall-speedup, GPU replacement or energy; full-graph admission and commitment remain.",
            "energy_ergs": NSNull()
        ]
        let bytes = try JSONSerialization.data(withJSONObject: report, options: [.sortedKeys, .withoutEscapingSlashes])
        print("DELTAPU_WORK_V1=" + String(decoding: bytes, as: UTF8.self))
    }

    func testDiamondReevaluatesEachAffectedNodeOnceAndCountsRepeatedOperands() async throws {
        let engine = try DeltaPUEngine(nodes: [
            node(1, .literal(1)), node(2, .literal(2)), node(3, .add(1, 2)),
            node(4, .add(1, 1)), node(5, .add(3, 4)), node(6, .literal(99))])
        let result = try await checkedApply(engine, [.replace(node(1, .literal(4)))])
        XCTAssertEqual(result.work.nodesEvaluated, 4)
        XCTAssertEqual(result.work.operandReads, 6)
        XCTAssertEqual(result.work.valuesReused, 2)
        XCTAssertEqual(result.snapshot.values[5], 14)
    }

    func testSelectTracksConditionAndBothBranchDependencies() async throws {
        let engine = try DeltaPUEngine(nodes: baseGraph())
        let switched = try await checkedApply(engine, [.replace(node(4, .literal(0)))])
        XCTAssertEqual(switched.snapshot.values[5], 23)
        XCTAssertEqual(switched.work.nodesEvaluated, 2)
        let inactive = try await checkedApply(engine, [.replace(node(1, .literal(20)))])
        XCTAssertEqual(inactive.snapshot.values[5], 23)
        XCTAssertEqual(inactive.work.nodesEvaluated, 3)
        XCTAssertFalse(inactive.outputDelta.contains(.set(5, 23)))
    }

    func testInactiveBranchStillRejectsOverflowMissingAndCycle() async throws {
        let engine = try DeltaPUEngine(nodes: [
            node(1, .literal(0)), node(2, .literal(Int64.max)), node(3, .literal(0)),
            node(4, .add(2, 3)), node(5, .select(condition: 1, ifNonzero: 4, ifZero: 3))])
        await rejected(engine, [.replace(node(3, .literal(1)))], .overflow(4))
        await rejected(engine, [.replace(node(4, .add(2, 99)))], .missingDependency(node: 4, dependency: 99))
        await rejected(engine, [.replace(node(4, .add(5, 3)))], .cycle)
    }

    func testAtomicRemoveProducerReplaceConsumerAndInsertIndependentOfEditOrder() async throws {
        let graph = [node(1, .literal(5)), node(2, .add(1, 1)), node(3, .add(2, 2))]
        let edits: [DeltaPUEdit] = [.remove(1), .replace(node(2, .add(4, 4))), .insert(node(4, .literal(7)))]
        let a = try DeltaPUEngine(nodes: graph), b = try DeltaPUEngine(nodes: graph)
        let left = try await checkedApply(a, edits)
        let right = try await checkedApply(b, Array(edits.reversed()))
        XCTAssertEqual(left.snapshot, right.snapshot)
        XCTAssertEqual(left.deltaCBOR, right.deltaCBOR)
        XCTAssertEqual(left.deltaID, right.deltaID)
        XCTAssertEqual(left.outputDelta, [.remove(1), .set(2, 14), .set(3, 28), .set(4, 7)])
    }

    func testNewEdgeInfluencesFutureUpdatesAndRemovedEdgeDoesNotCorruptCache() async throws {
        let engine = try DeltaPUEngine(nodes: [
            node(1, .literal(2)), node(2, .literal(9)), node(3, .add(1, 1)), node(4, .add(3, 3))])
        _ = try await checkedApply(engine, [.replace(node(3, .add(2, 2)))])
        let changedOld = try await checkedApply(engine, [.replace(node(1, .literal(100)))])
        XCTAssertEqual(changedOld.work.nodesEvaluated, 1)
        let changedNew = try await checkedApply(engine, [.replace(node(2, .literal(10)))])
        XCTAssertEqual(changedNew.work.nodesEvaluated, 3)
        XCTAssertEqual(changedNew.snapshot.values[4], 40)
    }

    func testDeletionAndEmptyGraph() async throws {
        let engine = try DeltaPUEngine(nodes: [node(1, .literal(2)), node(2, .add(1, 1))])
        await rejected(engine, [.remove(1)], .missingDependency(node: 2, dependency: 1))
        let result = try await checkedApply(engine, [.remove(1), .remove(2)])
        XCTAssertTrue(result.snapshot.values.isEmpty)
        XCTAssertEqual(result.outputDelta, [.remove(1), .remove(2)])
        XCTAssertEqual(result.work.nodesEvaluated, 0)
        let empty = try DeltaPUEngine(nodes: [])
        try DeltaPUReference.verify(await empty.snapshot())
    }

    func testInsertForwardReferencesAndMaximumID() async throws {
        let engine = try DeltaPUEngine(nodes: [])
        let result = try await checkedApply(engine, [
            .insert(node(1, .add(UInt32.max, UInt32.max))), .insert(node(UInt32.max, .literal(-2)))])
        XCTAssertEqual(result.snapshot.values[1], -4)
    }

    func testEmptyAndExactReplacementAreNoOps() async throws {
        let engine = try DeltaPUEngine(nodes: baseGraph())
        let first = try await checkedApply(engine, [])
        let second = try await checkedApply(engine, [.replace(node(1, .literal(19)))])
        XCTAssertFalse(first.committed)
        XCTAssertFalse(second.committed)
        XCTAssertEqual(first.snapshot, second.snapshot)
        XCTAssertEqual(first.snapshot.revision, 0)
        XCTAssertEqual(first.work.nodesEvaluated, 0)
        XCTAssertEqual(second.work.nodesEvaluated, 0)
    }

    func testPrecommitVerificationAdmitsBoundedEmptyGraphAndFullBatches() async throws {
        let engine = try DeltaPUEngine(nodes: [])
        let genesis = await engine.snapshot()
        let emptyNoOp = try await checkedApply(engine, [])
        XCTAssertFalse(emptyNoOp.committed)
        XCTAssertEqual(emptyNoOp.snapshot, genesis)

        let inserted = try await checkedApply(engine, (1...128).map {
            .insert(node(UInt32($0), .literal(Int64($0))))
        })
        XCTAssertTrue(inserted.committed)
        XCTAssertEqual(inserted.snapshot.nodes.count, 128)
        XCTAssertEqual(inserted.work.nodesEvaluated, 128)
        XCTAssertEqual(inserted.work.valuesReused, 0)

        let removed = try await checkedApply(engine, (1...128).map { .remove(UInt32($0)) })
        XCTAssertTrue(removed.committed)
        XCTAssertTrue(removed.snapshot.nodes.isEmpty)
        XCTAssertEqual(removed.snapshot.revision, 2)
        XCTAssertEqual(removed.work.nodesEvaluated, 0)
        XCTAssertEqual(removed.work.outputComparisons, 128)
        let historicalEmptyNoOp = try await checkedApply(engine, [])
        XCTAssertFalse(historicalEmptyNoOp.committed)
        XCTAssertEqual(historicalEmptyNoOp.snapshot, removed.snapshot)
    }

    func testPrecommitVerificationDoesNotBecomeIncrementalWorkOrChangeNoOpHistory() async throws {
        let engine = try DeltaPUEngine(nodes: baseGraph())
        let committed = try await checkedApply(engine, [.replace(node(1, .literal(20)))])
        let noOp = try await checkedApply(engine, [.replace(node(1, .literal(20)))])
        XCTAssertFalse(noOp.committed)
        XCTAssertEqual(noOp.snapshot, committed.snapshot)
        XCTAssertEqual(noOp.work.nodesEvaluated, 0)
        XCTAssertEqual(noOp.work.operandReads, 0)
        XCTAssertEqual(noOp.work.valuesReused, 5)
        XCTAssertEqual(noOp.work.nodesValidated, 5)
        XCTAssertEqual(noOp.work.operandEdgesValidated, 5)
        XCTAssertEqual(noOp.work.outputComparisons, 5)
        XCTAssertGreaterThan(noOp.work.commitmentPayloadBytes, 0)
    }

    func testChangedDefinitionWithSameValueAdvancesButOutputCanBeEmpty() async throws {
        let engine = try DeltaPUEngine(nodes: [node(1, .literal(2)), node(2, .literal(2)), node(3, .add(1, 1))])
        let before = await engine.snapshot()
        let result = try await checkedApply(engine, [.replace(node(3, .add(2, 2)))])
        XCTAssertTrue(result.committed)
        XCTAssertTrue(result.outputDelta.isEmpty)
        XCTAssertEqual(result.snapshot.revision, 1)
        XCTAssertNotEqual(result.snapshot.contentRoot, before.contentRoot)
    }

    func testReturningToSameContentDoesNotRecreateOldStateIdentity() async throws {
        let engine = try DeltaPUEngine(nodes: baseGraph())
        let first = await engine.snapshot()
        _ = try await checkedApply(engine, [.replace(node(1, .literal(20)))])
        let third = try await checkedApply(engine, [.replace(node(1, .literal(19)))])
        XCTAssertEqual(third.snapshot.contentRoot, first.contentRoot)
        XCTAssertNotEqual(third.snapshot.stateID, first.stateID)
        XCTAssertEqual(third.snapshot.revision, 2)
        await rejected(engine, [.replace(node(1, .literal(99)))], .staleBase, base: first.stateID)
    }

    func testReplayAndStaleNoOpRejectWithoutRebase() async throws {
        let engine = try DeltaPUEngine(nodes: baseGraph())
        let first = await engine.snapshot()
        _ = try await checkedApply(engine, [.replace(node(1, .literal(20)))])
        await rejected(engine, [.replace(node(1, .literal(20)))], .staleBase, base: first.stateID)
        await rejected(engine, [], .staleBase, base: first.stateID)
        await rejected(engine, [], .staleBase, base: first.stateID.uppercased())
    }

    func testDuplicateEditsAndExistencePreconditionsRollback() async throws {
        let engine = try DeltaPUEngine(nodes: baseGraph())
        await rejected(engine, [.remove(1), .insert(node(1, .literal(5)))], .duplicateEdit(1))
        await rejected(engine, [.replace(node(1, .literal(5))), .replace(node(1, .literal(6)))], .duplicateEdit(1))
        await rejected(engine, [.insert(node(1, .literal(5)))], .nodeAlreadyExists(1))
        await rejected(engine, [.replace(node(99, .literal(5)))], .nodeNotFound(99))
        await rejected(engine, [.remove(99)], .nodeNotFound(99))
        await rejected(engine, [.insert(node(0, .literal(5)))], .zeroNodeID)
    }

    func testOverflowBatchRollsBackThenValidUpdateStillWorks() async throws {
        let engine = try DeltaPUEngine(nodes: baseGraph())
        await rejected(engine, [.replace(node(1, .literal(Int64.max))), .insert(node(99, .literal(7)))], .overflow(3))
        let result = try await checkedApply(engine, [.replace(node(1, .literal(1)))])
        XCTAssertEqual(result.snapshot.values[3], 24)
        XCTAssertNil(result.snapshot.values[99])
    }

    func testNodeAndEditLimitsAndFinalGraphNotTransientCount() async throws {
        let engine = try DeltaPUEngine(nodes: (1...128).map { node(UInt32($0), .literal(0)) })
        await rejected(engine, [.insert(node(129, .literal(0)))], .tooManyNodes)
        await rejected(engine, Array(repeating: .remove(1), count: 129), .tooManyEdits)
        let result = try await checkedApply(engine, [.insert(node(129, .literal(7))), .remove(1)])
        XCTAssertEqual(result.snapshot.nodes.count, 128)
        XCTAssertEqual(result.snapshot.values[129], 7)
    }

    func testCancelledTaskCannotPublish() async throws {
        let engine = try DeltaPUEngine(nodes: baseGraph())
        let before = await engine.snapshot()
        let task = Task {
            withUnsafeCurrentTask { $0?.cancel() }
            return try await engine.apply(DeltaPUInputDelta(
                baseStateID: before.stateID, edits: [.replace(DeltaPUNode(id: 1, operation: .literal(9)))]))
        }
        do { _ = try await task.value; XCTFail("Cancelled apply published") }
        catch { XCTAssertTrue(error is CancellationError) }
        let after = await engine.snapshot()
        XCTAssertEqual(before, after)
    }

    func testConcurrentSameBaseHasOneWinner() async throws {
        let engine = try DeltaPUEngine(nodes: baseGraph())
        let before = await engine.snapshot()
        let outcomes = await withTaskGroup(of: String.self, returning: [String].self) { group in
            for value in [Int64(7), Int64(8)] {
                group.addTask {
                    do {
                        _ = try await engine.apply(DeltaPUInputDelta(
                            baseStateID: before.stateID,
                            edits: [.replace(DeltaPUNode(id: 1, operation: .literal(value)))]))
                        return "committed"
                    } catch DeltaPUFailure.staleBase { return "stale" }
                    catch { return "unexpected:" + String(describing: error) }
                }
            }
            var results: [String] = []
            for await result in group { results.append(result) }
            return results.sorted()
        }
        XCTAssertEqual(outcomes, ["committed", "stale"])
        let after = await engine.snapshot()
        XCTAssertEqual(after.revision, 1)
        try DeltaPUReference.verify(after)
    }

    func testDeterministicMixedTraceMatchesFullReferenceAtEveryTransition() async throws {
        let engine = try DeltaPUEngine(nodes: baseGraph())
        for step in 0..<160 {
            let edits: [DeltaPUEdit]
            switch step % 8 {
            case 0: edits = [.replace(node(1, .literal(Int64(step - 70))))]
            case 1: edits = [.replace(node(2, .literal(Int64(90 - step))))]
            case 2: edits = [.replace(node(4, .literal(Int64(step % 3 - 1))))]
            case 3: edits = [.insert(node(99, .add(5, 1)))]
            case 4: edits = [.replace(node(3, step % 16 == 4 ? .add(2, 1) : .add(1, 2)))]
            case 5: edits = [.replace(node(99, .select(condition: 4, ifNonzero: 1, ifZero: 3)))]
            case 6: edits = [.remove(99)]
            default: edits = []
            }
            _ = try await checkedApply(engine, edits)
        }
    }

    func testIndependentReferenceRejectsFalseValueEvenWhenAllHashesAreResealed() async throws {
        let engine = try DeltaPUEngine(nodes: baseGraph())
        let snapshot = await engine.snapshot()
        var falseValues = snapshot.values
        falseValues[3] = 999
        guard case .map(var content) = try GuestCBOR.decode(snapshot.contentCBOR) else { return XCTFail("content") }
        content["values"] = .array(falseValues.keys.sorted().map {
            .array([.unsigned(UInt64($0)), .unsigned(UInt64(bitPattern: falseValues[$0]!))])
        })
        let bytes = try GuestCBOR.encode(.map(content))
        let root = try MerkleGenesis.commit([
            GenesisLeaf(label: "schema", payload: Data("ergentics.deltapu.graph.v1".utf8)),
            GenesisLeaf(label: "graph", payload: bytes)]).root
        guard case .map(var version) = try GuestCBOR.decode(snapshot.versionCBOR) else { return XCTFail("version") }
        version["content_root"] = .text(root)
        let versionBytes = try GuestCBOR.encode(.map(version))
        let forged = DeltaPUSnapshot(nodes: snapshot.nodes, values: falseValues, revision: snapshot.revision,
            parentStateID: snapshot.parentStateID, appliedDeltaID: snapshot.appliedDeltaID,
            contentRoot: root, stateID: hash(versionBytes), contentCBOR: bytes, versionCBOR: versionBytes)
        XCTAssertThrowsError(try DeltaPUReference.verify(forged))
    }

    func testIndependentReferenceRejectsTamperedVersionAndContent() async throws {
        let engine = try DeltaPUEngine(nodes: baseGraph())
        let s = await engine.snapshot()
        let wrongRevision = DeltaPUSnapshot(nodes: s.nodes, values: s.values, revision: 42,
            parentStateID: s.parentStateID, appliedDeltaID: s.appliedDeltaID,
            contentRoot: s.contentRoot, stateID: s.stateID, contentCBOR: s.contentCBOR, versionCBOR: s.versionCBOR)
        XCTAssertThrowsError(try DeltaPUReference.verify(wrongRevision))
        var trailing = s.contentCBOR
        trailing.append(0)
        let wrongBytes = DeltaPUSnapshot(nodes: s.nodes, values: s.values, revision: s.revision,
            parentStateID: s.parentStateID, appliedDeltaID: s.appliedDeltaID,
            contentRoot: s.contentRoot, stateID: s.stateID, contentCBOR: trailing, versionCBOR: s.versionCBOR)
        XCTAssertThrowsError(try DeltaPUReference.verify(wrongBytes))
    }

    func testReferenceOutputApplicationRejectsAmbiguity() {
        XCTAssertThrowsError(try DeltaPUReference.applyingOutput([.set(1, 2), .set(1, 3)], to: [:]))
        XCTAssertThrowsError(try DeltaPUReference.applyingOutput([.remove(1)], to: [:]))
        XCTAssertThrowsError(try DeltaPUReference.applyingOutput([.set(2, 2), .set(1, 1)], to: [:]))
    }
}
