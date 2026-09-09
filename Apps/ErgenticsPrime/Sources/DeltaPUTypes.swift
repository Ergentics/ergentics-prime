import Foundation

// Internal typed computation API. No files, process commands, guest pointers,
// or authority-bearing capabilities cross this boundary.
enum DeltaPUContract {
    static let maximumNodes = 128
    static let maximumEdits = 128
    static let maximumFrameBytes = 65_536
    static let contentSchema = "ergentics.deltapu.graph.v1"
    static let deltaSchema = "ergentics.deltapu.delta.v1"
    static let stateSchema = "ergentics.deltapu.state.v1"
}

typealias DeltaPUNodeID = UInt32

enum DeltaPUOperation: Equatable, Sendable {
    case literal(Int64)
    case add(DeltaPUNodeID, DeltaPUNodeID)
    case select(condition: DeltaPUNodeID, ifNonzero: DeltaPUNodeID, ifZero: DeltaPUNodeID)
}

struct DeltaPUNode: Equatable, Sendable {
    let id: DeltaPUNodeID
    let operation: DeltaPUOperation
}

enum DeltaPUEdit: Equatable, Sendable {
    case insert(DeltaPUNode)
    case replace(DeltaPUNode)
    case remove(DeltaPUNodeID)
}

struct DeltaPUInputDelta: Equatable, Sendable {
    let baseStateID: String
    let edits: [DeltaPUEdit]
}

enum DeltaPUOutputEdit: Equatable, Sendable {
    case set(DeltaPUNodeID, Int64)
    case remove(DeltaPUNodeID)
}

struct DeltaPUWork: Equatable, Sendable {
    var submittedEdits = 0
    var changedDefinitions = 0
    var nodesValidated = 0
    var operandEdgesValidated = 0
    var invalidatedNodes = 0
    var invalidationEdgesVisited = 0
    var nodesEvaluated = 0
    var operandReads = 0
    var valuesReused = 0
    var outputComparisons = 0
    // Total bytes in leaf payloads and standalone delta/version hash payloads.
    // Excludes hash framing bytes, repeated verification and memory-copy costs.
    var commitmentPayloadBytes = 0
}

struct DeltaPUSnapshot: Equatable, Sendable {
    let nodes: [DeltaPUNode]
    let values: [DeltaPUNodeID: Int64]
    let revision: UInt64
    let parentStateID: String?
    let appliedDeltaID: String?
    let contentRoot: String
    let stateID: String
    let contentCBOR: Data
    let versionCBOR: Data
}

struct DeltaPUTransition: Equatable, Sendable {
    let fromStateID: String
    let deltaID: String
    let deltaCBOR: Data
    let snapshot: DeltaPUSnapshot
    let outputDelta: [DeltaPUOutputEdit]
    let work: DeltaPUWork
    let committed: Bool
}

enum DeltaPUFailure: Error, Equatable {
    case tooManyNodes
    case tooManyEdits
    case zeroNodeID
    case duplicateNode(DeltaPUNodeID)
    case duplicateEdit(DeltaPUNodeID)
    case nodeAlreadyExists(DeltaPUNodeID)
    case nodeNotFound(DeltaPUNodeID)
    case missingDependency(node: DeltaPUNodeID, dependency: DeltaPUNodeID)
    case cycle
    case overflow(DeltaPUNodeID)
    case staleBase
    case revisionOverflow
    case frameTooLarge
    case inconsistentState
}
