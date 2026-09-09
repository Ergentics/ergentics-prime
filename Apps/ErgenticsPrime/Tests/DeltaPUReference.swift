import CryptoKit
import Foundation

/// Test-only full recomputation. No production DeltaPUEngine validation,
/// scheduling, operation evaluation or encoding helper is used here.
enum DeltaPUReference {
    enum ReferenceError: Error, Equatable {
        case bound
        case invalidID
        case duplicateNode(UInt32)
        case missingDependency(UInt32)
        case cycle
        case overflow(UInt32)
        case duplicateEdit(UInt32)
        case invalidEdit(UInt32)
        case outputOrder
        case invalidSnapshot
    }

    private static let nodeLimit = 128
    private static let editLimit = 128
    private static let frameLimit = 65_536
    private static let contentSchema = "ergentics.deltapu.graph.v1"
    private static let stateSchema = "ergentics.deltapu.state.v1"

    static func evaluate(_ nodes: [DeltaPUNode]) throws -> [UInt32: Int64] {
        try measuredEvaluation(nodes).values
    }

    /// These are actual oracle operations, not counts inferred from nodeCount.
    /// A memo hit reads an operand but does not execute that node again.
    static func measuredEvaluation(_ nodes: [DeltaPUNode]) throws
        -> (values: [UInt32: Int64], nodeEvaluations: Int, operandReads: Int) {
        let graph = try index(nodes)
        var colors: [UInt32: UInt8] = [:] // absent = white, 1 = gray, 2 = black
        var memo: [UInt32: Int64] = [:]
        var nodeEvaluations = 0
        var operandReads = 0

        func operand(_ id: UInt32) throws -> Int64 {
            operandReads += 1
            return try visit(id)
        }

        func visit(_ id: UInt32) throws -> Int64 {
            guard id != 0 else { throw ReferenceError.invalidID }
            guard let node = graph[id] else { throw ReferenceError.missingDependency(id) }
            if colors[id] == 1 { throw ReferenceError.cycle }
            if colors[id] == 2 {
                guard let value = memo[id] else { throw ReferenceError.invalidSnapshot }
                return value
            }
            colors[id] = 1
            nodeEvaluations += 1
            let value: Int64
            switch node.operation {
            case .literal(let literal):
                value = literal
            case .add(let left, let right):
                let a = try operand(left), b = try operand(right)
                let sum = a.addingReportingOverflow(b)
                guard !sum.overflow else { throw ReferenceError.overflow(id) }
                value = sum.partialValue
            case .select(let condition, let nonzero, let zero):
                // All declared operands are evaluated, including the inactive
                // branch. No lazy-select shortcut may hide a cycle/overflow.
                let test = try operand(condition)
                let whenNonzero = try operand(nonzero)
                let whenZero = try operand(zero)
                value = test != 0 ? whenNonzero : whenZero
            }
            memo[id] = value
            colors[id] = 2
            return value
        }

        for id in graph.keys.sorted() { _ = try visit(id) }
        return (memo, nodeEvaluations, operandReads)
    }

    static func applying(_ edits: [DeltaPUEdit], to nodes: [DeltaPUNode]) throws -> [DeltaPUNode] {
        guard edits.count <= editLimit else { throw ReferenceError.bound }
        // The provided baseline must itself be a valid graph. Only the final
        // edited graph is then evaluated; transient edit ordering is irrelevant.
        _ = try evaluate(nodes)
        var graph = try index(nodes)
        var seen = Set<UInt32>()
        for edit in edits {
            let id: UInt32
            switch edit {
            case .insert(let node), .replace(let node): id = node.id
            case .remove(let target): id = target
            }
            guard id != 0 else { throw ReferenceError.invalidID }
            guard seen.insert(id).inserted else { throw ReferenceError.duplicateEdit(id) }
            switch edit {
            case .insert(let node):
                guard graph[id] == nil else { throw ReferenceError.invalidEdit(id) }
                graph[id] = node
            case .replace(let node):
                guard graph[id] != nil else { throw ReferenceError.invalidEdit(id) }
                graph[id] = node
            case .remove:
                guard graph.removeValue(forKey: id) != nil else { throw ReferenceError.invalidEdit(id) }
            }
        }
        let result = graph.keys.sorted().compactMap { graph[$0] }
        _ = try evaluate(result)
        return result
    }

    static func applyingOutput(_ edits: [DeltaPUOutputEdit], to values: [UInt32: Int64]) throws -> [UInt32: Int64] {
        guard values.count <= nodeLimit, edits.count <= nodeLimit * 2 else { throw ReferenceError.bound }
        guard values.keys.allSatisfy({ $0 != 0 }) else { throw ReferenceError.invalidID }
        var result = values
        var previous: UInt32 = 0
        for edit in edits {
            let id: UInt32
            switch edit {
            case .set(let target, _), .remove(let target): id = target
            }
            guard id != 0 else { throw ReferenceError.invalidID }
            guard id > previous else { throw ReferenceError.outputOrder }
            previous = id
            switch edit {
            case .set(_, let value): result[id] = value
            case .remove:
                guard result.removeValue(forKey: id) != nil else { throw ReferenceError.invalidEdit(id) }
            }
        }
        guard result.count <= nodeLimit else { throw ReferenceError.bound }
        return result
    }

    /// Independently parses the committed graph and version and recomputes every
    /// value. A snapshot contains no parent snapshot or delta bytes: parent and
    /// delta checks here bind their exact IDs/formats, not unavailable ancestry
    /// or edit-history semantics. Transition tests must check those separately.
    static func verify(_ snapshot: DeltaPUSnapshot) throws {
        guard !snapshot.contentCBOR.isEmpty, snapshot.contentCBOR.count <= frameLimit,
              !snapshot.versionCBOR.isEmpty, snapshot.versionCBOR.count <= frameLimit,
              validDigest(snapshot.contentRoot), validDigest(snapshot.stateID) else {
            throw ReferenceError.invalidSnapshot
        }
        // GuestCBOR.decode independently parses and requires canonical re-encode
        // equality, rejecting nonminimal integers, duplicate keys and trailers.
        let content = try dictionary(GuestCBOR.decode(snapshot.contentCBOR), keys: ["schema", "nodes", "values"])
        guard content["schema"] == .text(contentSchema),
              case .array(let encodedNodes) = content["nodes"],
              case .array(let encodedValues) = content["values"],
              encodedNodes.count <= nodeLimit, encodedValues.count <= nodeLimit else {
            throw ReferenceError.invalidSnapshot
        }
        var nodes: [DeltaPUNode] = []
        var previousNode: UInt32 = 0
        for encoded in encodedNodes {
            let node = try dictionary(encoded, keys: ["id", "op"])
            guard let encodedID = node["id"], let encodedOperation = node["op"] else {
                throw ReferenceError.invalidSnapshot
            }
            let id = try nodeID(encodedID)
            guard id > previousNode else { throw ReferenceError.invalidSnapshot }
            previousNode = id
            nodes.append(DeltaPUNode(id: id, operation: try operation(encodedOperation)))
        }
        var values: [UInt32: Int64] = [:]
        var previousValue: UInt32 = 0
        for encoded in encodedValues {
            guard case .array(let pair) = encoded, pair.count == 2 else { throw ReferenceError.invalidSnapshot }
            let id = try nodeID(pair[0])
            guard id > previousValue else { throw ReferenceError.invalidSnapshot }
            previousValue = id
            values[id] = Int64(bitPattern: try unsigned(pair[1]))
        }
        let evaluated = try evaluate(nodes)
        guard nodes == snapshot.nodes, values == snapshot.values, evaluated == values else {
            throw ReferenceError.invalidSnapshot
        }
        let leaves = [GenesisLeaf(label: "schema", payload: Data(contentSchema.utf8)),
                      GenesisLeaf(label: "graph", payload: snapshot.contentCBOR)]
        guard try MerkleGenesis.verify(leaves, expectedRoot: snapshot.contentRoot) else {
            throw ReferenceError.invalidSnapshot
        }

        let version = try dictionary(GuestCBOR.decode(snapshot.versionCBOR),
            keys: ["schema", "revision", "parent_state_id", "delta_id", "content_root"])
        guard version["schema"] == .text(stateSchema),
              version["revision"] == .unsigned(snapshot.revision),
              version["parent_state_id"] == .text(snapshot.parentStateID ?? ""),
              version["delta_id"] == .text(snapshot.appliedDeltaID ?? ""),
              version["content_root"] == .text(snapshot.contentRoot) else {
            throw ReferenceError.invalidSnapshot
        }
        if snapshot.revision == 0 {
            guard snapshot.parentStateID == nil, snapshot.appliedDeltaID == nil else {
                throw ReferenceError.invalidSnapshot
            }
        } else {
            guard let parent = snapshot.parentStateID, let delta = snapshot.appliedDeltaID,
                  validDigest(parent), validDigest(delta), parent != snapshot.stateID else {
                throw ReferenceError.invalidSnapshot
            }
        }
        let stateHash = SHA256.hash(data: snapshot.versionCBOR).map { String(format: "%02x", $0) }.joined()
        guard stateHash == snapshot.stateID else { throw ReferenceError.invalidSnapshot }
    }

    private static func index(_ nodes: [DeltaPUNode]) throws -> [UInt32: DeltaPUNode] {
        guard nodes.count <= nodeLimit else { throw ReferenceError.bound }
        var result: [UInt32: DeltaPUNode] = [:]
        for node in nodes {
            guard node.id != 0 else { throw ReferenceError.invalidID }
            guard result.updateValue(node, forKey: node.id) == nil else {
                throw ReferenceError.duplicateNode(node.id)
            }
        }
        return result
    }

    private static func validDigest(_ value: String) -> Bool {
        let bytes = value.utf8
        return bytes.count == 64 && bytes.allSatisfy { (48...57).contains($0) || (97...102).contains($0) }
    }

    private static func dictionary(_ value: GuestCBORValue, keys: Set<String>) throws -> [String: GuestCBORValue] {
        guard case .map(let map) = value, Set(map.keys) == keys else { throw ReferenceError.invalidSnapshot }
        return map
    }

    private static func unsigned(_ value: GuestCBORValue) throws -> UInt64 {
        guard case .unsigned(let number) = value else { throw ReferenceError.invalidSnapshot }
        return number
    }

    private static func nodeID(_ value: GuestCBORValue) throws -> UInt32 {
        let number = try unsigned(value)
        guard number > 0, number <= UInt32.max else { throw ReferenceError.invalidID }
        return UInt32(number)
    }

    private static func operation(_ value: GuestCBORValue) throws -> DeltaPUOperation {
        guard case .array(let parts) = value, !parts.isEmpty else { throw ReferenceError.invalidSnapshot }
        switch try unsigned(parts[0]) {
        case 0:
            guard parts.count == 2 else { throw ReferenceError.invalidSnapshot }
            return .literal(Int64(bitPattern: try unsigned(parts[1])))
        case 1:
            guard parts.count == 3 else { throw ReferenceError.invalidSnapshot }
            return .add(try nodeID(parts[1]), try nodeID(parts[2]))
        case 2:
            guard parts.count == 4 else { throw ReferenceError.invalidSnapshot }
            return .select(condition: try nodeID(parts[1]), ifNonzero: try nodeID(parts[2]), ifZero: try nodeID(parts[3]))
        default:
            throw ReferenceError.invalidSnapshot
        }
    }
}
