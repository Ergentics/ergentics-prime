import CryptoKit
import Foundation

enum DeltaPUVerifiedNodeStatus: String, Sendable {
    case changed = "Changed value"
    case affectedUnchanged = "Affected / same value"
    case reused = "Cached / unaffected"
    case removed = "Removed"
}

struct DeltaPUVerifiedNode: Equatable, Sendable, Identifiable {
    let id: UInt32
    let oldValue: Int64?
    let newValue: Int64?
    let definitionChanged: Bool
    let status: DeltaPUVerifiedNodeStatus
}

struct DeltaPUVerifiedTransition: Equatable, Sendable {
    let rows: [DeltaPUVerifiedNode]
    let beforeNodeEvaluations: Int
    let afterNodeEvaluations: Int
    let afterOperandReads: Int
}

/// Independent, bounded reconstruction for the volatile CPU demonstration.
/// This does not call the incremental engine or the test-only reference. Shared
/// CBOR/hash/Merkle primitives are not independent cryptographic implementations.
/// Membership rows are reconstructed dependencies, not per-node execution traces.
enum DeltaPUDemoVerification {
    enum Failure: Error, Equatable {
        case bound, malformed, invalidGraph, arithmeticOverflow, wrongTransition, wrongWork
    }

    private static let nodeLimit = 128
    private static let editLimit = 128
    private static let frameLimit = 65_536
    private static let graphSchema = "ergentics.deltapu.graph.v1"
    private static let deltaSchema = "ergentics.deltapu.delta.v1"
    private static let stateSchema = "ergentics.deltapu.state.v1"

    private struct Evaluation {
        let values: [UInt32: Int64]
        let nodeEvaluations: Int
        let operandReads: Int
        let readsByNode: [UInt32: Int]
    }

    private struct Edge: Hashable {
        let source: UInt32
        let target: UInt32
    }

    static func verify(before: DeltaPUSnapshot, delta: DeltaPUInputDelta,
                       transition: DeltaPUTransition) throws -> DeltaPUVerifiedTransition {
        try Task.checkCancellation()
        guard delta.edits.count <= editLimit, transition.outputDelta.count <= nodeLimit * 2,
              !transition.deltaCBOR.isEmpty, transition.deltaCBOR.count <= frameLimit else {
            throw Failure.bound
        }
        let beforeEvaluation = try validateSnapshot(before)
        let after = transition.snapshot
        let afterEvaluation = try validateSnapshot(after)
        guard delta.baseStateID == before.stateID, transition.fromStateID == before.stateID else {
            throw Failure.wrongTransition
        }
        let old = try index(before.nodes)
        let new = try index(after.nodes)
        let edited = try applyEdits(delta.edits, to: old)
        guard edited == new else { throw Failure.wrongTransition }

        // Parse independently and compare the entire submitted transaction,
        // including sorted IDs, tags, signed bit patterns and exact schema.
        let expectedDelta = try encodedDelta(delta)
        let decodedDelta = try GuestCBOR.decode(transition.deltaCBOR)
        let canonicalDelta = try GuestCBOR.encode(expectedDelta)
        guard decodedDelta == expectedDelta, canonicalDelta == transition.deltaCBOR,
              hash(transition.deltaCBOR) == transition.deltaID else {
            throw Failure.wrongTransition
        }

        let ids = Set(old.keys).union(new.keys).sorted()
        let changed = Set(ids.filter { old[$0] != new[$0] })
        let committed = !changed.isEmpty
        guard transition.committed == committed else { throw Failure.wrongTransition }
        if committed {
            let increment = before.revision.addingReportingOverflow(1)
            guard !increment.overflow, after.revision == increment.partialValue,
                  after.parentStateID == before.stateID, after.appliedDeltaID == transition.deltaID,
                  after.stateID != before.stateID else { throw Failure.wrongTransition }
        } else {
            guard after == before else { throw Failure.wrongTransition }
        }

        // Deliberately use a fixed-point scan over dependency edges, not the
        // engine's reverse-adjacency worklist. Removed definitions participate.
        var edges = Set<Edge>()
        for graph in [old, new] {
            for (id, operation) in graph {
                try Task.checkCancellation()
                for dependency in operands(operation) { edges.insert(Edge(source: dependency, target: id)) }
            }
        }
        var affected = changed
        var grew = true
        while grew {
            try Task.checkCancellation()
            grew = false
            for edge in edges where affected.contains(edge.source) {
                if affected.insert(edge.target).inserted { grew = true }
            }
        }
        let survivingAffected = affected.intersection(Set(new.keys))
        var expectedOutput: [DeltaPUOutputEdit] = []
        var rows: [DeltaPUVerifiedNode] = []
        for id in ids {
            try Task.checkCancellation()
            let oldValue = beforeEvaluation.values[id], newValue = afterEvaluation.values[id]
            let status: DeltaPUVerifiedNodeStatus
            if let value = newValue {
                if oldValue != newValue {
                    expectedOutput.append(.set(id, value))
                    status = .changed
                } else {
                    status = affected.contains(id) ? .affectedUnchanged : .reused
                }
            } else {
                guard oldValue != nil else { throw Failure.wrongTransition }
                expectedOutput.append(.remove(id))
                status = .removed
            }
            rows.append(DeltaPUVerifiedNode(id: id, oldValue: oldValue, newValue: newValue,
                definitionChanged: changed.contains(id), status: status))
        }
        guard transition.outputDelta == expectedOutput else { throw Failure.wrongTransition }

        var expectedWork = DeltaPUWork()
        expectedWork.submittedEdits = delta.edits.count
        expectedWork.changedDefinitions = changed.count
        expectedWork.nodesValidated = new.count
        expectedWork.operandEdgesValidated = afterEvaluation.operandReads
        expectedWork.invalidatedNodes = survivingAffected.count
        expectedWork.invalidationEdgesVisited = edges.reduce(0) { $0 + (affected.contains($1.source) ? 1 : 0) }
        expectedWork.nodesEvaluated = survivingAffected.count
        expectedWork.operandReads = survivingAffected.reduce(0) { $0 + (afterEvaluation.readsByNode[$1] ?? 0) }
        expectedWork.valuesReused = new.count - survivingAffected.count
        expectedWork.outputComparisons = ids.count
        expectedWork.commitmentPayloadBytes = transition.deltaCBOR.count + graphSchema.utf8.count
            + after.contentCBOR.count + (committed ? after.versionCBOR.count : 0)
        guard transition.work == expectedWork else { throw Failure.wrongWork }
        try Task.checkCancellation()
        return DeltaPUVerifiedTransition(rows: rows,
            beforeNodeEvaluations: beforeEvaluation.nodeEvaluations,
            afterNodeEvaluations: afterEvaluation.nodeEvaluations,
            afterOperandReads: afterEvaluation.operandReads)
    }

    private static func applyEdits(_ edits: [DeltaPUEdit], to old: [UInt32: DeltaPUOperation]) throws
        -> [UInt32: DeltaPUOperation] {
        var seen = Set<UInt32>()
        var result = old
        for edit in edits {
            try Task.checkCancellation()
            let id = target(edit)
            guard id != 0, seen.insert(id).inserted else { throw Failure.wrongTransition }
            switch edit {
            case .insert(let node):
                guard old[id] == nil else { throw Failure.wrongTransition }
                result[id] = node.operation
            case .replace(let node):
                guard old[id] != nil else { throw Failure.wrongTransition }
                result[id] = node.operation
            case .remove:
                guard old[id] != nil else { throw Failure.wrongTransition }
                result.removeValue(forKey: id)
            }
        }
        guard result.count <= nodeLimit else { throw Failure.bound }
        return result
    }

    private static func validateSnapshot(_ snapshot: DeltaPUSnapshot) throws -> Evaluation {
        guard snapshot.nodes.count <= nodeLimit, snapshot.values.count <= nodeLimit,
              !snapshot.contentCBOR.isEmpty, snapshot.contentCBOR.count <= frameLimit,
              !snapshot.versionCBOR.isEmpty, snapshot.versionCBOR.count <= frameLimit else { throw Failure.bound }
        guard digest(snapshot.contentRoot), digest(snapshot.stateID) else { throw Failure.malformed }
        let content = try map(GuestCBOR.decode(snapshot.contentCBOR), keys: ["schema", "nodes", "values"])
        guard content["schema"] == .text(graphSchema), case .array(let rawNodes) = content["nodes"],
              case .array(let rawValues) = content["values"], rawNodes.count <= nodeLimit,
              rawValues.count <= nodeLimit else { throw Failure.malformed }
        var nodes: [DeltaPUNode] = []
        var lastID: UInt32 = 0
        for raw in rawNodes {
            try Task.checkCancellation()
            let row = try map(raw, keys: ["id", "op"])
            guard let rawID = row["id"], let rawOperation = row["op"] else { throw Failure.malformed }
            let id = try nodeID(rawID)
            guard id > lastID else { throw Failure.malformed }
            lastID = id
            nodes.append(DeltaPUNode(id: id, operation: try operation(rawOperation)))
        }
        var values: [UInt32: Int64] = [:]
        lastID = 0
        for raw in rawValues {
            try Task.checkCancellation()
            guard case .array(let pair) = raw, pair.count == 2 else { throw Failure.malformed }
            let id = try nodeID(pair[0])
            guard id > lastID else { throw Failure.malformed }
            lastID = id
            values[id] = Int64(bitPattern: try unsigned(pair[1]))
        }
        let evaluation = try evaluate(index(nodes))
        guard nodes == snapshot.nodes, values == snapshot.values, evaluation.values == values,
              try MerkleGenesis.verify([
                GenesisLeaf(label: "schema", payload: Data(graphSchema.utf8)),
                GenesisLeaf(label: "graph", payload: snapshot.contentCBOR)
              ], expectedRoot: snapshot.contentRoot) else { throw Failure.malformed }
        let version = try map(GuestCBOR.decode(snapshot.versionCBOR),
            keys: ["schema", "revision", "parent_state_id", "delta_id", "content_root"])
        guard version["schema"] == .text(stateSchema), version["revision"] == .unsigned(snapshot.revision),
              version["parent_state_id"] == .text(snapshot.parentStateID ?? ""),
              version["delta_id"] == .text(snapshot.appliedDeltaID ?? ""),
              version["content_root"] == .text(snapshot.contentRoot), hash(snapshot.versionCBOR) == snapshot.stateID else {
            throw Failure.malformed
        }
        if snapshot.revision == 0 {
            guard snapshot.parentStateID == nil, snapshot.appliedDeltaID == nil else { throw Failure.malformed }
        } else {
            guard let parent = snapshot.parentStateID, let delta = snapshot.appliedDeltaID,
                  digest(parent), digest(delta), parent != snapshot.stateID else { throw Failure.malformed }
        }
        // Earlier ancestry is unavailable here; verify() binds the one supplied
        // before -> delta -> after transition, not an unseen historical chain.
        return evaluation
    }

    private static func evaluate(_ graph: [UInt32: DeltaPUOperation]) throws -> Evaluation {
        var active = Set<UInt32>()
        var values: [UInt32: Int64] = [:]
        var nodeEvaluations = 0, operandReads = 0
        var readsByNode: [UInt32: Int] = [:]
        func read(_ dependency: UInt32, owner: UInt32) throws -> Int64 {
            operandReads += 1
            readsByNode[owner, default: 0] += 1
            return try visit(dependency)
        }
        func visit(_ id: UInt32) throws -> Int64 {
            try Task.checkCancellation()
            if let value = values[id] { return value }
            guard id != 0, let operation = graph[id], active.insert(id).inserted else { throw Failure.invalidGraph }
            nodeEvaluations += 1
            let value: Int64
            switch operation {
            case .literal(let literal): value = literal
            case .add(let left, let right):
                let a = try read(left, owner: id), b = try read(right, owner: id)
                let sum = a.addingReportingOverflow(b)
                guard !sum.overflow else { throw Failure.arithmeticOverflow }
                value = sum.partialValue
            case .select(let condition, let nonzero, let zero):
                let test = try read(condition, owner: id)
                let yes = try read(nonzero, owner: id), no = try read(zero, owner: id)
                value = test != 0 ? yes : no
            }
            active.remove(id)
            values[id] = value
            return value
        }
        for id in graph.keys.sorted() { _ = try visit(id) }
        return Evaluation(values: values, nodeEvaluations: nodeEvaluations,
            operandReads: operandReads, readsByNode: readsByNode)
    }

    private static func index(_ nodes: [DeltaPUNode]) throws -> [UInt32: DeltaPUOperation] {
        guard nodes.count <= nodeLimit else { throw Failure.bound }
        var graph: [UInt32: DeltaPUOperation] = [:]
        for node in nodes {
            try Task.checkCancellation()
            guard node.id != 0, graph.updateValue(node.operation, forKey: node.id) == nil else {
                throw Failure.invalidGraph
            }
        }
        return graph
    }

    private static func target(_ edit: DeltaPUEdit) -> UInt32 {
        switch edit {
        case .insert(let node), .replace(let node): node.id
        case .remove(let id): id
        }
    }

    private static func operands(_ operation: DeltaPUOperation) -> [UInt32] {
        switch operation {
        case .literal: []
        case .add(let a, let b): [a, b]
        case .select(let c, let a, let b): [c, a, b]
        }
    }

    private static func encodedDelta(_ delta: DeltaPUInputDelta) throws -> GuestCBORValue {
        let rows = delta.edits.sorted { target($0) < target($1) }.map { edit -> GuestCBORValue in
            switch edit {
            case .insert(let node): return .array([.unsigned(0), .unsigned(UInt64(node.id)), encodeOperation(node.operation)])
            case .replace(let node): return .array([.unsigned(1), .unsigned(UInt64(node.id)), encodeOperation(node.operation)])
            case .remove(let id): return .array([.unsigned(2), .unsigned(UInt64(id))])
            }
        }
        return .map(["schema": .text(deltaSchema), "base_state_id": .text(delta.baseStateID), "edits": .array(rows)])
    }

    private static func encodeOperation(_ value: DeltaPUOperation) -> GuestCBORValue {
        switch value {
        case .literal(let n): .array([.unsigned(0), .unsigned(UInt64(bitPattern: n))])
        case .add(let a, let b): .array([.unsigned(1), .unsigned(UInt64(a)), .unsigned(UInt64(b))])
        case .select(let c, let a, let b): .array([.unsigned(2), .unsigned(UInt64(c)), .unsigned(UInt64(a)), .unsigned(UInt64(b))])
        }
    }

    private static func operation(_ raw: GuestCBORValue) throws -> DeltaPUOperation {
        guard case .array(let parts) = raw, !parts.isEmpty else { throw Failure.malformed }
        switch try unsigned(parts[0]) {
        case 0:
            guard parts.count == 2 else { throw Failure.malformed }
            return .literal(Int64(bitPattern: try unsigned(parts[1])))
        case 1:
            guard parts.count == 3 else { throw Failure.malformed }
            return .add(try nodeID(parts[1]), try nodeID(parts[2]))
        case 2:
            guard parts.count == 4 else { throw Failure.malformed }
            return .select(condition: try nodeID(parts[1]), ifNonzero: try nodeID(parts[2]), ifZero: try nodeID(parts[3]))
        default: throw Failure.malformed
        }
    }

    private static func map(_ raw: GuestCBORValue, keys: Set<String>) throws -> [String: GuestCBORValue] {
        guard case .map(let value) = raw, Set(value.keys) == keys else { throw Failure.malformed }
        return value
    }

    private static func unsigned(_ raw: GuestCBORValue) throws -> UInt64 {
        guard case .unsigned(let value) = raw else { throw Failure.malformed }
        return value
    }

    private static func nodeID(_ raw: GuestCBORValue) throws -> UInt32 {
        let value = try unsigned(raw)
        guard value > 0, value <= UInt32.max else { throw Failure.malformed }
        return UInt32(value)
    }

    private static func digest(_ value: String) -> Bool {
        let bytes = value.utf8
        return bytes.count == 64 && bytes.allSatisfy { (48...57).contains($0) || (97...102).contains($0) }
    }

    private static func hash(_ bytes: Data) -> String {
        SHA256.hash(data: bytes).map { String(format: "%02x", $0) }.joined()
    }
}
