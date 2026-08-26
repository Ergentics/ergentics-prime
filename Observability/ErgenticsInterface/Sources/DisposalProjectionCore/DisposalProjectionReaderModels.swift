import Foundation

public enum DisposalProjectionAvailability: Equatable, Sendable {
    case empty
    case rejected(DisposalProjectionRejection)
    case admitted(DisposalProjectionSnapshot)
}

public struct DisposalProjectionSnapshot: Equatable, Sendable {
    public let metadata: DisposalProjectionMetadata
    public let counts: DisposalProjectionCounts
    public let frames: [DisposalFramePresentation]
    public let processRows: [DisposalProcessPresentation]
    public let riskWindows: [DisposalRiskWindowPresentation]
    public let missingEvidence: [DisposalMissingEvidencePresentation]
    public let metrics: [DisposalMetricPresentation]
    public let graphNodes: [DisposalGraphNodePresentation]
    public let graphEdges: [DisposalGraphEdgePresentation]
    public let machineStates: [DisposalMachineStatePresentation]
    public let machineTransitions: [DisposalMachineTransitionPresentation]
    public let machineWitnesses: [DisposalMachineWitnessPresentation]
    public let machinePredicates: [DisposalMachinePredicatePresentation]
    public let machineMerkleLeaves: [DisposalMachineMerkleLeafPresentation]
    public let machineEdges: [DisposalMachineEdgePresentation]
    public let sourceConservationSets: [DisposalSourceConservationSetPresentation]
    public let sourceConservationMemberships: [DisposalSourceConservationMembershipPresentation]
    public let sourceConservationProofNodes: [DisposalSourceConservationProofNodePresentation]
    public let sourceConservationMappings: [DisposalSourceConservationMappingPresentation]
}

public struct DisposalProjectionMetadata: Equatable, Sendable {
    public let projectionID: String
    public let sourceSHA256: String
    public let sourceBytes: Int
    public let frameCount: Int
    public let sourceKind: String
    public let sourceSealed: Bool
    public let terminal: Bool
    public let status: String
    public let evidenceSHA256: String
    public let metricsSHA256: String
    public let graphSHA256: String
    public let sealSHA256: String
    public let predecessorProjectionID: String?
    public let authorityVector: String
    public let authoritative: Bool
    public let mayFeedController: Bool
}

public struct DisposalProjectionCounts: Equatable, Sendable {
    public let frames: Int
    public let processRows: Int
    public let riskWindows: Int
    public let missingEvidence: Int
    public let samples: Int
    public let metrics: Int
    public let graphNodes: Int
    public let graphEdges: Int
    public let machineStates: Int
    public let machineTransitions: Int
    public let machineWitnesses: Int
    public let machinePredicates: Int
    public let machineMerkleLeaves: Int
    public let machineEdges: Int
    public let sourceConservationSets: Int
    public let sourceConservationMemberships: Int
    public let sourceConservationProofNodes: Int
    public let sourceConservationMappings: Int
}

public struct DisposalFramePresentation: Equatable, Identifiable, Sendable {
    public let id: String
    public let ordinal: Int
    public let eventType: String
    public let phase: String?
    public let targetLabel: String?
    public let status: String?
    public let schema: String
    public let rawSHA256: String
    public let rawWithLFSHA256: String
    public let payloadSHA256: String
    public let rawJSON: String
}

public struct DisposalExactField: Equatable, Identifiable, Sendable {
    public var id: String { key }
    public let key: String
    public let value: String?
}

public struct DisposalProcessPresentation: Equatable, Identifiable, Sendable {
    public let id: String
    public let category: String
    public let sourceFrameID: String?
    public let targetID: String?
    public let exactState: String
    public let fields: [DisposalExactField]
}

public struct DisposalRiskWindowPresentation: Equatable, Identifiable, Sendable {
    public let id: String
    public let sourceFrameID: String
    public let targetID: String?
    public let kind: String
    public let basis: String
    public let closureState: String
    public let maximumDurationNanoseconds: String?
    public let qualification: String
}

public struct DisposalMissingEvidencePresentation: Equatable, Identifiable, Sendable {
    public let id: String
    public let evidenceKind: String
    public let targetRole: String?
    public let sourceFrameID: String?
    public let reasonCode: String
    public let valueState: String
}

public struct DisposalMetricPresentation: Equatable, Identifiable, Sendable {
    public let id: String
    public let intervalID: String
    public let name: String
    public let bound: String
    public let numerator: String
    public let denominator: String
    public let unit: String
    public let approximation: String?
    public let sourceGrade: String
    public let premise: String
    public let sourcePointer: String
    public let qualifications: [DisposalExactField]
}

public struct DisposalGraphNodePresentation: Equatable, Identifiable, Sendable {
    public let id: String
    public let kind: String
    public let canonicalKey: String
    public let label: String
    public let sourceDatabaseRole: String
    public let sourceRowID: String
}

public struct DisposalGraphEdgePresentation: Equatable, Identifiable, Sendable {
    public let id: String
    public let fromNodeID: String
    public let predicate: String
    public let toNodeID: String
    public let sourceDatabaseRole: String
    public let sourceRowID: String
    public let sourcePointer: String?
    public let evidenceGrade: String
}

public struct DisposalMachineStatePresentation: Equatable, Identifiable, Sendable {
    public let id: String
    public let prefixOrdinal: Int
    public let predecessorStateID: String?
    public let ancestrySHA256: String
    public let highWaterFrameNodeID: String?
    public let highWaterFrameLFSHA256: String?
    public let matchedRuleID: String
    public let predicateVectorSHA256: String
    public let stateClass: String
    public let derivedWitnessMerkleRootSHA256: String
    public let derivedWitnessLeafCount: Int
    public let merkleAlgorithm: String
    public let merkleDomainTag: String
    public let merkleLeafOrdering: String
    public let merkleDuplicatePolicy: String
    public let merkleOddLeafRule: String
}

public struct DisposalMachineTransitionPresentation: Equatable, Identifiable, Sendable {
    public let id: String
    public let fromStateID: String
    public let toStateID: String
    public let acceptedFrameNodeID: String
    public let acceptedFrameLFSHA256: String
    public let matchedRuleID: String
    public let stateClass: String
    public let predicateVectorSHA256: String
    public let derivedSourceSetSHA256: String
    public let predecessorWitnessMerkleRootSHA256: String
    public let predecessorWitnessLeafCount: Int
    public let preconservationMerkleCommitted: String
    public let preconservationCommitmentWitnessID: String?
}

public struct DisposalMachineWitnessPresentation: Equatable, Identifiable, Sendable {
    public let id: String
    public let kind: String
    public let sourceTable: String
    public let sourceRowID: String
    public let exactRowSHA256: String
    public let normalizedFactSHA256: String
    public let intrinsicSourceFrameLFSHA256: String?
    public let sourceFrameNodeID: String?
    public let visiblePrefixOrdinal: Int
}

public struct DisposalMachinePredicatePresentation: Equatable, Identifiable, Sendable {
    public var id: String { transitionID + ":" + String(predicateOrdinal) }
    public let transitionID: String
    public let predicateOrdinal: Int
    public let ruleOrdinal: Int
    public let ruleID: String
    public let clauseOrdinal: Int
    public let clause: String
    public let lhs: String
    public let comparisonOperator: String
    public let rhs: String
    public let actualScalar: String
    public let normalizedState: String
    public let sourceCount: Int
    public let sourceSetSHA256: String
    public let predicateSHA256: String
}

public struct DisposalMachineMerkleLeafPresentation: Equatable, Identifiable, Sendable {
    public var id: String { stateID + ":" + String(leafOrdinal) }
    public let stateID: String
    public let leafOrdinal: Int
    public let witnessID: String
    public let normalizedLeafSHA256: String
}

public struct DisposalMachineEdgePresentation: Equatable, Identifiable, Sendable {
    public let id: String
    public let fromNodeID: String
    public let toNodeID: String
    public let role: String
}

public struct DisposalSourceConservationSetPresentation: Equatable, Identifiable, Sendable {
    public let id: String
    public let sourceFrameID: String
    public let sourceFrameLFSHA256: String
    public let invocationID: String
    public let epochLabel: String
    public let purpose: String
    public let scopeKind: String
    public let scopeID: String
    public let algorithm: String
    public let domainTag: String
    public let leafOrdering: String
    public let duplicatePolicy: String
    public let treeShape: String
    public let oddLeafRule: String
    public let witnessRootSHA256: String
    public let leafCount: Int
    public let temporalState: String
}

public struct DisposalSourceConservationMembershipPresentation: Equatable, Identifiable, Sendable {
    public let id: String
    public let conservationSetID: String
    public let leafOrdinal: Int
    public let obligationKeySHA256: String
    public let obligationCommitmentID: String
    public let targetID: String
    public let targetRole: String
    public let targetForm: String
    public let expectedUniqueID: String
    public let expectedIDVersion: String
    public let operation: String
    public let numericArgument: Int
    public let signalNumber: Int
    public let budgetOrdinal: Int
    public let commitmentFrameLFSHA256: String
    public let leafSHA256: String
    public let proofSHA256: String
    public let proofDepth: Int
}

public struct DisposalSourceConservationMappingPresentation: Equatable, Identifiable, Sendable {
    public let id: String
    public let conservationID: String
    public let conservationSetID: String
    public let membershipID: String
    public let targetID: String
    public let mappingState: String
    public let merkleState: String
    public let conservationCompletionState: String
    public let conservationSourceFrameLFSHA256: String
}

public struct DisposalSourceConservationProofNodePresentation: Equatable, Identifiable, Sendable {
    public var id: String { membershipID + ":" + String(proofOrdinal) }
    public let membershipID: String
    public let proofOrdinal: Int
    public let siblingPosition: String
    public let siblingSHA256: String
}
