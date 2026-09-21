import CryptoKit
import Foundation

/// CPU reference implementation of change-driven graph computation. The actor
/// owns definitions and cached values; each apply independently checks its
/// candidate before any volatile commit, synchronously within its isolation
/// domain. No caller can restore an arbitrary snapshot or supply an evaluator,
/// scheduler, clock, path or execution capability. Verification is additional
/// full-graph work, separate from the transition's incremental work counters.
actor DeltaPUEngine {
    private struct Graph: Sendable {
        let nodes: [DeltaPUNode] // canonical ID order, independent of input order
        let definitions: [DeltaPUNodeID: DeltaPUOperation]
        let topologicalOrder: [DeltaPUNodeID]
        let reverse: [DeltaPUNodeID: Set<DeltaPUNodeID>]
    }

    private var graph: Graph
    private var state: DeltaPUSnapshot
    private let initialWork: DeltaPUWork

    init(nodes: [DeltaPUNode]) throws {
        try Task.checkCancellation()
        var work = DeltaPUWork()
        let admitted = try Self.validate(nodes, work: &work)
        work.changedDefinitions = admitted.nodes.count
        work.invalidatedNodes = admitted.nodes.count
        var values: [DeltaPUNodeID: Int64] = [:]
        for id in admitted.topologicalOrder {
            try Task.checkCancellation()
            guard let operation = admitted.definitions[id] else { throw DeltaPUFailure.inconsistentState }
            values[id] = try Self.evaluate(id, operation: operation, values: values, work: &work)
        }
        let snapshot = try Self.makeSnapshot(graph: admitted, values: values, revision: 0,
            parentStateID: nil, appliedDeltaID: nil, work: &work)
        try Task.checkCancellation()
        graph = admitted
        state = snapshot
        initialWork = work
    }

    func snapshot() -> DeltaPUSnapshot { state }
    func initializationWork() -> DeltaPUWork { initialWork }

    func apply(_ delta: DeltaPUInputDelta) throws -> DeltaPUTransition {
        try Task.checkCancellation()
        guard delta.baseStateID == state.stateID else { throw DeltaPUFailure.staleBase }
        guard delta.edits.count <= DeltaPUContract.maximumEdits else { throw DeltaPUFailure.tooManyEdits }
        var work = DeltaPUWork()
        work.submittedEdits = delta.edits.count
        var targetIDs: Set<DeltaPUNodeID> = []
        for edit in delta.edits {
            let id = Self.target(edit)
            guard id != 0 else { throw DeltaPUFailure.zeroNodeID }
            guard targetIDs.insert(id).inserted else { throw DeltaPUFailure.duplicateEdit(id) }
        }
        let edits = delta.edits.sorted { Self.target($0) < Self.target($1) }
        var definitions = graph.definitions
        for edit in edits {
            try Task.checkCancellation()
            switch edit {
            case .insert(let node):
                guard graph.definitions[node.id] == nil else { throw DeltaPUFailure.nodeAlreadyExists(node.id) }
                definitions[node.id] = node.operation
            case .replace(let node):
                guard graph.definitions[node.id] != nil else { throw DeltaPUFailure.nodeNotFound(node.id) }
                definitions[node.id] = node.operation
            case .remove(let id):
                guard graph.definitions[id] != nil else { throw DeltaPUFailure.nodeNotFound(id) }
                definitions.removeValue(forKey: id)
            }
        }
        // Validate the complete final graph, never intermediate edit order.
        let proposed = try Self.validate(definitions.map { DeltaPUNode(id: $0.key, operation: $0.value) }, work: &work)
        let deltaCBOR = try Self.encodeDelta(base: state.stateID, edits: edits)
        let deltaID = Self.hash(deltaCBOR)
        work.commitmentPayloadBytes += deltaCBOR.count

        let allIDs = Set(graph.definitions.keys).union(proposed.definitions.keys)
        let changed = Set(allIDs.filter { graph.definitions[$0] != proposed.definitions[$0] })
        work.changedDefinitions = changed.count
        let affected = Self.affected(changed, old: graph, new: proposed, work: &work)
        work.invalidatedNodes = affected.reduce(0) { $0 + (proposed.definitions[$1] == nil ? 0 : 1) }

        // Dictionary copying/filtering and full validation/hash/output scans
        // remain whole-graph work in v1; valuesReused counts cached numerical
        // values, not avoided allocations or end-to-end O(delta) complexity.
        var values = state.values.filter { proposed.definitions[$0.key] != nil }
        for id in proposed.topologicalOrder {
            try Task.checkCancellation()
            if affected.contains(id) {
                guard let operation = proposed.definitions[id] else { throw DeltaPUFailure.inconsistentState }
                values[id] = try Self.evaluate(id, operation: operation, values: values, work: &work)
            } else {
                guard values[id] != nil else { throw DeltaPUFailure.inconsistentState }
                work.valuesReused += 1
            }
        }
        var output: [DeltaPUOutputEdit] = []
        for id in allIDs.sorted() {
            work.outputComparisons += 1
            if let value = values[id] {
                if state.values[id] != value { output.append(.set(id, value)) }
            } else if state.values[id] != nil { output.append(.remove(id)) }
        }

        if changed.isEmpty {
            // No-op admission is not free: count its submitted delta hashing,
            // complete graph validation, output scan and reconstructed content.
            // Do not hash a new version or alter prior ancestry for a no-op.
            let content = try Self.content(graph: proposed, values: values, work: &work)
            guard values == state.values, content.bytes == state.contentCBOR,
                  content.root == state.contentRoot, output.isEmpty else { throw DeltaPUFailure.inconsistentState }
            let transition = DeltaPUTransition(fromStateID: state.stateID, deltaID: deltaID,
                deltaCBOR: deltaCBOR, snapshot: state, outputDelta: [], work: work, committed: false)
            // The generic reconstruction also checks no-op identity, ancestry,
            // exact output and logical counters; no scenario wrapper is used.
            _ = try DeltaPUDemoVerification.verify(before: state, delta: delta, transition: transition)
            try Task.checkCancellation()
            return transition
        }

        let (revision, overflow) = state.revision.addingReportingOverflow(1)
        guard !overflow else { throw DeltaPUFailure.revisionOverflow }
        let candidate = try Self.makeSnapshot(graph: proposed, values: values, revision: revision,
            parentStateID: state.stateID, appliedDeltaID: deltaID, work: &work)
        let transition = DeltaPUTransition(fromStateID: state.stateID, deltaID: deltaID,
            deltaCBOR: deltaCBOR, snapshot: candidate, outputDelta: output, work: work, committed: true)
        // Independently reconstruct the complete before/delta/candidate tuple
        // before mutating either owned value. Its cost is not incremental work
        // and grants no persistence, debugger eligibility or execution authority.
        _ = try DeltaPUDemoVerification.verify(before: state, delta: delta, transition: transition)
        // Cooperative cancellation is checked immediately before publication.
        // No await/reentrancy occurs across verification, this check, and both
        // assignments; any thrown rejection leaves all owned state unchanged.
        try Task.checkCancellation()
        graph = proposed
        state = candidate
        return transition
    }

    private static func target(_ edit: DeltaPUEdit) -> DeltaPUNodeID {
        switch edit {
        case .insert(let node), .replace(let node): node.id
        case .remove(let id): id
        }
    }

    /// Operand occurrences retain duplicates for admission/read accounting.
    /// Topological scheduling and reverse traversal use unique dependency edges.
    private static func operands(_ operation: DeltaPUOperation) -> [DeltaPUNodeID] {
        switch operation {
        case .literal: []
        case .add(let left, let right): [left, right]
        case .select(let condition, let nonzero, let zero): [condition, nonzero, zero]
        }
    }

    private static func validate(_ nodes: [DeltaPUNode], work: inout DeltaPUWork) throws -> Graph {
        guard nodes.count <= DeltaPUContract.maximumNodes else { throw DeltaPUFailure.tooManyNodes }
        var definitions: [DeltaPUNodeID: DeltaPUOperation] = [:]
        for node in nodes {
            guard node.id != 0 else { throw DeltaPUFailure.zeroNodeID }
            guard definitions.updateValue(node.operation, forKey: node.id) == nil else {
                throw DeltaPUFailure.duplicateNode(node.id)
            }
        }
        let ordered = nodes.sorted { $0.id < $1.id }
        var reverse: [DeltaPUNodeID: Set<DeltaPUNodeID>] = [:]
        var remaining: [DeltaPUNodeID: Int] = [:]
        for node in ordered {
            try Task.checkCancellation()
            work.nodesValidated += 1
            let dependencies = operands(node.operation)
            for dependency in dependencies {
                work.operandEdgesValidated += 1
                guard dependency != 0 else { throw DeltaPUFailure.zeroNodeID }
                guard definitions[dependency] != nil else {
                    throw DeltaPUFailure.missingDependency(node: node.id, dependency: dependency)
                }
                reverse[dependency, default: []].insert(node.id)
            }
            remaining[node.id] = Set(dependencies).count
        }
        var ready = ordered.filter { remaining[$0.id] == 0 }.map(\.id)
        var topology: [DeltaPUNodeID] = []
        while !ready.isEmpty {
            let id = ready.removeFirst()
            topology.append(id)
            for dependent in (reverse[id] ?? []).sorted() {
                guard let count = remaining[dependent], count > 0 else { throw DeltaPUFailure.inconsistentState }
                remaining[dependent] = count - 1
                if count == 1 { ready.append(dependent) }
            }
            ready.sort()
        }
        guard topology.count == ordered.count else { throw DeltaPUFailure.cycle }
        return Graph(nodes: ordered, definitions: definitions, topologicalOrder: topology, reverse: reverse)
    }

    private static func affected(_ seeds: Set<DeltaPUNodeID>, old: Graph, new: Graph,
                                 work: inout DeltaPUWork) -> Set<DeltaPUNodeID> {
        var visited = seeds
        var pending = seeds.sorted()
        var position = 0
        while position < pending.count {
            let id = pending[position]; position += 1
            let edges = (old.reverse[id] ?? []).union(new.reverse[id] ?? [])
            for dependent in edges.sorted() {
                // Each source ID is visited once: this counts each unique
                // old/new-union edge attempted, even if its target is visited.
                work.invalidationEdgesVisited += 1
                if visited.insert(dependent).inserted { pending.append(dependent) }
            }
        }
        return visited
    }

    private static func evaluate(_ id: DeltaPUNodeID, operation: DeltaPUOperation,
                                 values: [DeltaPUNodeID: Int64], work: inout DeltaPUWork) throws -> Int64 {
        work.nodesEvaluated += 1
        switch operation {
        case .literal(let value): return value
        case .add(let left, let right):
            guard let a = values[left], let b = values[right] else { throw DeltaPUFailure.inconsistentState }
            work.operandReads += 2
            let (value, overflow) = a.addingReportingOverflow(b)
            guard !overflow else { throw DeltaPUFailure.overflow(id) }
            return value
        case .select(let condition, let nonzero, let zero):
            // Read all declared operands, including the inactive branch. Its
            // producer is also materialized and must be individually valid.
            guard let predicate = values[condition], let a = values[nonzero], let b = values[zero] else {
                throw DeltaPUFailure.inconsistentState
            }
            work.operandReads += 3
            return predicate != 0 ? a : b
        }
    }

    private static func operationCBOR(_ operation: DeltaPUOperation) -> GuestCBORValue {
        switch operation {
        case .literal(let value): return .array([.unsigned(0), .unsigned(UInt64(bitPattern: value))])
        case .add(let left, let right):
            return .array([.unsigned(1), .unsigned(UInt64(left)), .unsigned(UInt64(right))])
        case .select(let condition, let nonzero, let zero):
            return .array([.unsigned(2), .unsigned(UInt64(condition)), .unsigned(UInt64(nonzero)), .unsigned(UInt64(zero))])
        }
    }

    private static func encodeDelta(base: String, edits: [DeltaPUEdit]) throws -> Data {
        let values: [GuestCBORValue] = edits.map { edit in
            switch edit {
            case .insert(let node): return .array([.unsigned(0), .unsigned(UInt64(node.id)), operationCBOR(node.operation)])
            case .replace(let node): return .array([.unsigned(1), .unsigned(UInt64(node.id)), operationCBOR(node.operation)])
            case .remove(let id): return .array([.unsigned(2), .unsigned(UInt64(id))])
            }
        }
        return try encode(.map(["schema": .text(DeltaPUContract.deltaSchema), "base_state_id": .text(base),
                                "edits": .array(values)]))
    }

    private static func content(graph: Graph, values: [DeltaPUNodeID: Int64],
                                work: inout DeltaPUWork) throws -> (bytes: Data, root: String) {
        guard Set(values.keys) == Set(graph.definitions.keys) else { throw DeltaPUFailure.inconsistentState }
        var encodedNodes: [GuestCBORValue] = []
        var encodedValues: [GuestCBORValue] = []
        for node in graph.nodes {
            guard let value = values[node.id] else { throw DeltaPUFailure.inconsistentState }
            encodedNodes.append(.map(["id": .unsigned(UInt64(node.id)), "op": operationCBOR(node.operation)]))
            encodedValues.append(.array([.unsigned(UInt64(node.id)), .unsigned(UInt64(bitPattern: value))]))
        }
        let bytes = try encode(.map(["schema": .text(DeltaPUContract.contentSchema),
            "nodes": .array(encodedNodes), "values": .array(encodedValues)]))
        let schema = Data(DeltaPUContract.contentSchema.utf8)
        let commitment = try MerkleGenesis.commit([GenesisLeaf(label: "schema", payload: schema),
                                                 GenesisLeaf(label: "graph", payload: bytes)])
        work.commitmentPayloadBytes += schema.count + bytes.count
        return (bytes, commitment.root)
    }

    private static func makeSnapshot(graph: Graph, values: [DeltaPUNodeID: Int64], revision: UInt64,
                                     parentStateID: String?, appliedDeltaID: String?,
                                     work: inout DeltaPUWork) throws -> DeltaPUSnapshot {
        let materialized = try content(graph: graph, values: values, work: &work)
        let version = try encode(.map(["schema": .text(DeltaPUContract.stateSchema),
            "revision": .unsigned(revision), "parent_state_id": .text(parentStateID ?? ""),
            "delta_id": .text(appliedDeltaID ?? ""), "content_root": .text(materialized.root)]))
        let stateID = hash(version)
        work.commitmentPayloadBytes += version.count
        return DeltaPUSnapshot(nodes: graph.nodes, values: values, revision: revision,
            parentStateID: parentStateID, appliedDeltaID: appliedDeltaID, contentRoot: materialized.root,
            stateID: stateID, contentCBOR: materialized.bytes, versionCBOR: version)
    }

    private static func encode(_ value: GuestCBORValue) throws -> Data {
        let bytes = try GuestCBOR.encode(value)
        guard bytes.count <= DeltaPUContract.maximumFrameBytes else { throw DeltaPUFailure.frameTooLarge }
        return bytes
    }

    private static func hash(_ bytes: Data) -> String {
        SHA256.hash(data: bytes).map { String(format: "%02x", $0) }.joined()
    }
}
