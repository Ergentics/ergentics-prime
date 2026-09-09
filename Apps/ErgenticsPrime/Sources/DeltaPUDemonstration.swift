import Foundation

enum DeltaPUDemoScenario: String, CaseIterable, Identifiable, Sendable {
    case sparse
    case dense

    var id: String { rawValue }
    var title: String {
        switch self {
        case .sparse: "Sparse change"
        case .dense: "Dense change"
        }
    }
    var detail: String {
        switch self {
        case .sparse: "Sixteen independent four-node graphs. Replace node 1's literal 1 with 7."
        case .dense: "One 64-node dependency chain. Replace the shared root literal 1 with 2."
        }
    }
}

enum DeltaPUDemoResultScope: String, Sendable {
    case diagnosticOnly = "Diagnostic only"
}

/// The scenario travels with its own inputs and checked result. Changing a UI
/// picker afterward cannot rename this report. This value is volatile session
/// data, not a persisted receipt, execution capability or performance claim.
struct DeltaPUDemoReport: Equatable, Sendable {
    let scenario: DeltaPUDemoScenario
    let before: DeltaPUSnapshot
    let delta: DeltaPUInputDelta
    let transition: DeltaPUTransition
    let verification: DeltaPUVerifiedTransition
    let scope: DeltaPUDemoResultScope = .diagnosticOnly

    // Only this core file can construct a report, and construction always checks
    // the exact source tuple. This is source-level integrity, not a boundary
    // against arbitrary same-process modification or debugger attachment.
    fileprivate init(scenario: DeltaPUDemoScenario, before: DeltaPUSnapshot,
                     delta: DeltaPUInputDelta, transition: DeltaPUTransition) throws {
        let verification = try DeltaPUDemonstration.verify(scenario: scenario,
            before: before, delta: delta, transition: transition)
        try Task.checkCancellation()
        self.scenario = scenario
        self.before = before
        self.delta = delta
        self.transition = transition
        self.verification = verification
    }
}

enum DeltaPUDemonstration {
    /// One closed fixture, one initial materialization, one fixed edit. No
    /// filesystem, clock, environment, subprocess, guest or input-loader path.
    static func run(_ scenario: DeltaPUDemoScenario) async throws -> DeltaPUDemoReport {
        try Task.checkCancellation()
        let fixture = specification(scenario)
        let engine = try DeltaPUEngine(nodes: fixture.nodes)
        try Task.checkCancellation()
        let before = await engine.snapshot()
        try Task.checkCancellation()
        let delta = DeltaPUInputDelta(baseStateID: before.stateID, edits: [fixture.edit])
        let transition = try await engine.apply(delta)
        try Task.checkCancellation()
        let after = await engine.snapshot()
        guard transition.snapshot == after else { throw DeltaPUFailure.inconsistentState }
        return try DeltaPUDemoReport(scenario: scenario, before: before, delta: delta,
                                     transition: transition)
    }

    /// The generic verifier proves computation; this wrapper additionally binds
    /// the selected label to its exact fixture, genesis and single frozen edit.
    static func verify(scenario: DeltaPUDemoScenario, before: DeltaPUSnapshot,
                       delta: DeltaPUInputDelta, transition: DeltaPUTransition) throws -> DeltaPUVerifiedTransition {
        let fixture = specification(scenario)
        guard before.nodes == fixture.nodes, before.revision == 0,
              before.parentStateID == nil, before.appliedDeltaID == nil,
              delta.edits == [fixture.edit] else { throw DeltaPUFailure.inconsistentState }
        return try DeltaPUDemoVerification.verify(before: before, delta: delta, transition: transition)
    }

    private static func specification(_ scenario: DeltaPUDemoScenario) -> (nodes: [DeltaPUNode], edit: DeltaPUEdit) {
        switch scenario {
        case .sparse:
            let nodes = (0..<16).flatMap { index -> [DeltaPUNode] in
                let id = UInt32(index * 4 + 1)
                return [DeltaPUNode(id: id, operation: .literal(1)),
                        DeltaPUNode(id: id + 1, operation: .literal(2)),
                        DeltaPUNode(id: id + 2, operation: .add(id, id + 1)),
                        DeltaPUNode(id: id + 3, operation: .add(id + 2, id + 1))]
            }
            return (nodes, .replace(DeltaPUNode(id: 1, operation: .literal(7))))
        case .dense:
            var nodes = [DeltaPUNode(id: 1, operation: .literal(1))]
            for id in UInt32(2)...64 {
                nodes.append(DeltaPUNode(id: id, operation: .add(id - 1, 1)))
            }
            return (nodes, .replace(DeltaPUNode(id: 1, operation: .literal(2))))
        }
    }
}
