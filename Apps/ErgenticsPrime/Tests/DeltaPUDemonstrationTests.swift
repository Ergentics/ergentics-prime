import Foundation
import XCTest

/// Bounded, volatile CPU fixture work only. No GUI, guest, native owner, file,
/// clock, environment, process or persistent demonstration session is entered.
@MainActor
final class DeltaPUDemonstrationTests: XCTestCase {
    private func independentlyCheck(_ report: DeltaPUDemoReport) throws {
        try DeltaPUReference.verify(report.before)
        try DeltaPUReference.verify(report.transition.snapshot)
        let expectedNodes = try DeltaPUReference.applying(report.delta.edits, to: report.before.nodes)
        let expected = try DeltaPUReference.measuredEvaluation(expectedNodes)
        XCTAssertEqual(report.transition.snapshot.nodes, expectedNodes)
        XCTAssertEqual(report.transition.snapshot.values, expected.values)
        XCTAssertEqual(try DeltaPUReference.applyingOutput(report.transition.outputDelta, to: report.before.values), expected.values)
        XCTAssertEqual(report.verification.beforeNodeEvaluations, 64)
        XCTAssertEqual(report.verification.afterNodeEvaluations, expected.nodeEvaluations)
        XCTAssertEqual(report.verification.afterOperandReads, expected.operandReads)
        XCTAssertEqual(report.verification.rows.count, 64)
        XCTAssertEqual(report.verification.rows.map(\.id), Array(UInt32(1)...64))
        for row in report.verification.rows {
            XCTAssertEqual(row.oldValue, report.before.values[row.id])
            XCTAssertEqual(row.newValue, report.transition.snapshot.values[row.id])
        }
        XCTAssertEqual(report.before.revision, 0)
        XCTAssertNil(report.before.parentStateID)
        XCTAssertNil(report.before.appliedDeltaID)
        XCTAssertEqual(report.delta.baseStateID, report.before.stateID)
        XCTAssertEqual(report.transition.fromStateID, report.before.stateID)
        XCTAssertEqual(report.transition.snapshot.parentStateID, report.before.stateID)
        XCTAssertEqual(report.transition.snapshot.appliedDeltaID, report.transition.deltaID)
        XCTAssertEqual(report.transition.snapshot.revision, 1)
        XCTAssertTrue(report.transition.committed)
        XCTAssertEqual(try DeltaPUDemonstration.verify(scenario: report.scenario, before: report.before,
            delta: report.delta, transition: report.transition), report.verification)
    }

    func testSparseClosedFixtureMatchesPriorIdentityAndThreeNodeWork() async throws {
        let report = try await DeltaPUDemonstration.run(.sparse)
        try independentlyCheck(report)
        XCTAssertEqual(report.scenario, .sparse)
        XCTAssertEqual(report.delta.edits, [.replace(DeltaPUNode(id: 1, operation: .literal(7)))])
        XCTAssertEqual(report.transition.snapshot.contentRoot, "1fa00f205cff30f8720b1007de2427b2981060faea2b9764418531689724fe7d")
        XCTAssertEqual(report.transition.snapshot.stateID, "dc13cd1748923b11b72c14ac5b59a1a78b67f421eaf238e1ce0b95a75e43dc21")
        XCTAssertEqual(report.transition.outputDelta, [.set(1, 7), .set(3, 9), .set(4, 11)])
        let work = report.transition.work
        XCTAssertEqual(work.submittedEdits, 1)
        XCTAssertEqual(work.changedDefinitions, 1)
        XCTAssertEqual(work.nodesValidated, 64)
        XCTAssertEqual(work.operandEdgesValidated, 64)
        XCTAssertEqual(work.invalidatedNodes, 3)
        XCTAssertEqual(work.invalidationEdgesVisited, 2)
        XCTAssertEqual(work.nodesEvaluated, 3)
        XCTAssertEqual(work.operandReads, 4)
        XCTAssertEqual(work.valuesReused, 61)
        XCTAssertEqual(work.outputComparisons, 64)
        XCTAssertEqual(work.commitmentPayloadBytes, 1540)
        XCTAssertEqual(report.verification.afterOperandReads, 64)
        XCTAssertEqual(report.verification.rows.filter { $0.status == .changed }.map(\.id), [1, 3, 4])
        XCTAssertEqual(report.verification.rows.filter { $0.status == .reused }.count, 61)
        XCTAssertTrue(report.verification.rows.filter { $0.status == .affectedUnchanged || $0.status == .removed }.isEmpty)
        XCTAssertEqual(report.verification.rows.filter(\.definitionChanged).map(\.id), [1])
        try emit(report)
    }

    func testDenseClosedFixtureMatchesPriorIdentityAndNoAvoidedNodeWork() async throws {
        let report = try await DeltaPUDemonstration.run(.dense)
        try independentlyCheck(report)
        XCTAssertEqual(report.scenario, .dense)
        XCTAssertEqual(report.delta.edits, [.replace(DeltaPUNode(id: 1, operation: .literal(2)))])
        XCTAssertEqual(report.transition.snapshot.contentRoot, "d736d4dcf8f0c3d0e89b91005d1c8529e339028ed9e0c3e0a785d95bb511944f")
        XCTAssertEqual(report.transition.snapshot.stateID, "60f3939947071eda31c579d813400aad91dd01919e4e7de08ee421294fe796bc")
        XCTAssertEqual(report.transition.outputDelta, (UInt32(1)...64).map { .set($0, Int64($0) * 2) })
        for id in UInt32(1)...64 {
            XCTAssertEqual(report.before.values[id], Int64(id))
            XCTAssertEqual(report.transition.snapshot.values[id], Int64(id) * 2)
        }
        let work = report.transition.work
        XCTAssertEqual(work.submittedEdits, 1)
        XCTAssertEqual(work.changedDefinitions, 1)
        XCTAssertEqual(work.nodesValidated, 64)
        XCTAssertEqual(work.operandEdgesValidated, 126)
        XCTAssertEqual(work.invalidatedNodes, 64)
        XCTAssertEqual(work.invalidationEdgesVisited, 125)
        XCTAssertEqual(work.nodesEvaluated, 64)
        XCTAssertEqual(work.operandReads, 126)
        XCTAssertEqual(work.valuesReused, 0)
        XCTAssertEqual(work.outputComparisons, 64)
        XCTAssertEqual(work.commitmentPayloadBytes, 1624)
        XCTAssertEqual(report.verification.afterOperandReads, 126)
        XCTAssertEqual(report.verification.rows.filter { $0.status == .changed }.count, 64)
        XCTAssertTrue(report.verification.rows.filter { $0.status != .changed }.isEmpty)
        XCTAssertEqual(report.verification.rows.filter(\.definitionChanged).map(\.id), [1])
        try emit(report)
    }

    func testRepeatedDemonstrationsHaveExactlyIdenticalReportsWithoutSessionHistory() async throws {
        for scenario in DeltaPUDemoScenario.allCases {
            let first = try await DeltaPUDemonstration.run(scenario)
            let second = try await DeltaPUDemonstration.run(scenario)
            XCTAssertEqual(first, second)
            XCTAssertEqual(first.before.revision, 0)
            XCTAssertEqual(second.transition.snapshot.revision, 1)
        }
    }

    func testPreCanceledTaskRejectsBothClosedScenarios() async {
        for scenario in DeltaPUDemoScenario.allCases {
            let task = Task {
                withUnsafeCurrentTask { $0?.cancel() }
                return try await DeltaPUDemonstration.run(scenario)
            }
            do {
                _ = try await task.value
                XCTFail("Pre-canceled demonstration returned a report")
            } catch is CancellationError {
                // Cancellation applies to this task only; no process signal.
            } catch { XCTFail("Wrong cancellation error: \(error)") }
        }
    }

    func testOtherScenarioCannotRelabelAnOtherwiseValidTransition() async throws {
        let sparse = try await DeltaPUDemonstration.run(.sparse)
        let dense = try await DeltaPUDemonstration.run(.dense)
        XCTAssertThrowsError(try DeltaPUDemonstration.verify(scenario: .dense, before: sparse.before,
            delta: sparse.delta, transition: sparse.transition))
        XCTAssertThrowsError(try DeltaPUDemonstration.verify(scenario: .sparse, before: dense.before,
            delta: dense.delta, transition: dense.transition))
    }

    func testAlteredFixtureRejectsEvenWhenItsComputationIsIndependentlyValid() async throws {
        let original = try await DeltaPUDemonstration.run(.sparse)
        var nodes = original.before.nodes
        nodes[1] = DeltaPUNode(id: 2, operation: .literal(3))
        let engine = try DeltaPUEngine(nodes: nodes)
        let before = await engine.snapshot()
        let delta = DeltaPUInputDelta(baseStateID: before.stateID, edits: original.delta.edits)
        let transition = try await engine.apply(delta)
        _ = try DeltaPUDemoVerification.verify(before: before, delta: delta, transition: transition)
        XCTAssertThrowsError(try DeltaPUDemonstration.verify(scenario: .sparse, before: before,
            delta: delta, transition: transition))
    }

    func testAlteredEditRejectsEvenWhenItIsAValidBaseBoundUpdate() async throws {
        let original = try await DeltaPUDemonstration.run(.sparse)
        let engine = try DeltaPUEngine(nodes: original.before.nodes)
        let before = await engine.snapshot()
        let delta = DeltaPUInputDelta(baseStateID: before.stateID,
            edits: [.replace(DeltaPUNode(id: 1, operation: .literal(8)))])
        let transition = try await engine.apply(delta)
        _ = try DeltaPUDemoVerification.verify(before: before, delta: delta, transition: transition)
        XCTAssertThrowsError(try DeltaPUDemonstration.verify(scenario: .sparse, before: before,
            delta: delta, transition: transition))
    }

    func testUnchangedContentWithNonGenesisHistoryCannotStandInForInitialFixture() async throws {
        let original = try await DeltaPUDemonstration.run(.sparse)
        let engine = try DeltaPUEngine(nodes: original.before.nodes)
        var current = await engine.snapshot()
        _ = try await engine.apply(DeltaPUInputDelta(baseStateID: current.stateID,
            edits: [.replace(DeltaPUNode(id: 1, operation: .literal(3)))]))
        current = await engine.snapshot()
        _ = try await engine.apply(DeltaPUInputDelta(baseStateID: current.stateID,
            edits: [.replace(DeltaPUNode(id: 1, operation: .literal(1)))]))
        let before = await engine.snapshot()
        XCTAssertEqual(before.nodes, original.before.nodes)
        XCTAssertEqual(before.contentRoot, original.before.contentRoot)
        XCTAssertNotEqual(before.stateID, original.before.stateID)
        let delta = DeltaPUInputDelta(baseStateID: before.stateID, edits: original.delta.edits)
        let transition = try await engine.apply(delta)
        _ = try DeltaPUDemoVerification.verify(before: before, delta: delta, transition: transition)
        XCTAssertThrowsError(try DeltaPUDemonstration.verify(scenario: .sparse, before: before,
            delta: delta, transition: transition))
    }

    func testScenarioIdentifiersAreClosedAndStable() {
        XCTAssertEqual(DeltaPUDemoScenario.allCases, [.sparse, .dense])
        XCTAssertEqual(DeltaPUDemoScenario.allCases.map(\.id), ["sparse", "dense"])
        for scenario in DeltaPUDemoScenario.allCases {
            XCTAssertFalse(scenario.title.isEmpty)
            XCTAssertFalse(scenario.detail.isEmpty)
        }
    }

    func testReportsAndTheirCopiesRemainDiagnosticOnlyAcrossFreshRuns() async throws {
        for scenario in DeltaPUDemoScenario.allCases {
            let report = try await DeltaPUDemonstration.run(scenario)
            let copy = report
            let fresh = try await DeltaPUDemonstration.run(scenario)
            XCTAssertEqual(report.scope, .diagnosticOnly)
            XCTAssertEqual(copy.scope, .diagnosticOnly)
            XCTAssertEqual(fresh.scope, .diagnosticOnly)
            XCTAssertEqual(report.scope.rawValue, "Diagnostic only")
            XCTAssertEqual(report.verification, try DeltaPUDemonstration.verify(
                scenario: report.scenario, before: report.before,
                delta: report.delta, transition: report.transition))
        }
    }

    private func emit(_ report: DeltaPUDemoReport) throws {
        let work = report.transition.work
        let independentlyComputed = try DeltaPUReference.evaluate(report.transition.snapshot.nodes)
        let independentlyApplied = try DeltaPUReference.applyingOutput(report.transition.outputDelta, to: report.before.values)
        let observation: [String: Any] = [
            "schema": "ergentics.deltapu.demonstration-test-observation.v1",
            "scenario": report.scenario.rawValue,
            "before_state_id": report.before.stateID,
            "after_state_id": report.transition.snapshot.stateID,
            "content_root": report.transition.snapshot.contentRoot,
            "delta_id": report.transition.deltaID,
            "rows": report.verification.rows.count,
            "changed_value_rows": report.verification.rows.filter { $0.status == .changed }.count,
            "reused_rows": report.verification.rows.filter { $0.status == .reused }.count,
            "incremental_node_evaluations": work.nodesEvaluated,
            "incremental_operand_reads": work.operandReads,
            "full_before_node_evaluations": report.verification.beforeNodeEvaluations,
            "full_after_node_evaluations": report.verification.afterNodeEvaluations,
            "full_after_operand_reads": report.verification.afterOperandReads,
            "validated_nodes": work.nodesValidated, "output_comparisons": work.outputComparisons,
            "commitment_payload_bytes": work.commitmentPayloadBytes,
            "test_reference_equal": report.transition.snapshot.values == independentlyComputed && independentlyApplied == independentlyComputed,
            "qualification": "Logical CPU reference work and independently derived dependency membership, not per-node CPU tracing, elapsed speedup, GPU replacement, guest or persisted-session proof.",
            "energy_ergs": NSNull()
        ]
        let bytes = try JSONSerialization.data(withJSONObject: observation, options: [.sortedKeys, .withoutEscapingSlashes])
        print("DELTAPU_DEMO_TEST_V1=" + String(decoding: bytes, as: UTF8.self))
    }
}
