import Foundation

public struct DisposalProjectionSetRequest: Equatable, Sendable {
    public let journal: Data
    public let journalLogicalPath: String
    public let predecessorProjectionID: String?

    public init(
        journal: Data,
        journalLogicalPath: String,
        predecessorProjectionID: String? = nil
    ) {
        self.journal = journal
        self.journalLogicalPath = journalLogicalPath
        self.predecessorProjectionID = predecessorProjectionID
    }
}

public struct DisposalProjectionSetReport: Equatable, Sendable {
    public let outputRootPath: String
    public let evidencePath: String
    public let metricsPath: String
    public let graphPath: String
    public let sealPath: String
    public let projectionID: String
    public let evidenceSHA256: String
    public let metricsSHA256: String
    public let graphSHA256: String
    public let sealSHA256: String
    public let evidenceBytes: Int
    public let metricsBytes: Int
    public let graphBytes: Int
    public let frameCount: Int
    public let terminal: Bool
    public let authorityVector: String
}

struct DisposalProjectionSetMaterial: Sendable {
    let evidence: Data
    let metrics: Data
    let graph: Data
    let seal: Data
    let projectionID: String
    let evidenceProjectionID: String
    let metricsProjectionID: String
    let graphProjectionID: String
    let evidenceSHA256: String
    let metricsSHA256: String
    let graphSHA256: String
    let sealSHA256: String
    let frameCount: Int
    let terminal: Bool
}

struct DisposalEvidenceMaterial: Sendable {
    let database: Data
    let databaseSHA256: String
    let projectionID: String
    let relationalExportSHA256: String
    let invocationID: String
    let epochLabel: String
    let streamID: String
    let artifactID: String
    let frameIDs: [String]
    let riskWindowIDs: [String]
    let typedEvidenceIDs: DisposalTypedEvidenceIDs
    let missingEvidenceCount: Int
    let ddlSHA256: String
    let adapterSHA256: String
    let latticeSHA256: String
    let extractorSHA256: String
}

struct DisposalTypedEvidenceIDs: Equatable, Sendable {
    let frameAdapterCoverageIDs: [String]
    let targetIDs: [String]
    let processReceiptIDs: [String]
    let vnodeJoinIDs: [String]
    let domainSnapshotIDs: [String]
    let targetSnapshotIDs: [String]
    let snapshotPairIDs: [String]
    let namespaceObservationIDs: [String]
    let commitmentIDs: [String]
    let signalCallIDs: [String]
    let signalZeroCallIDs: [String]
    let waitCallIDs: [String]
    let reapIDs: [String]
    let absenceProofIDs: [String]
    let conservationIDs: [String]
    let conservationSetCommitmentIDs: [String]
    let conservationSetMembershipIDs: [String]
    let conservationSetMappingIDs: [String]

    static let empty = DisposalTypedEvidenceIDs(
        frameAdapterCoverageIDs: [],
        targetIDs: [],
        processReceiptIDs: [],
        vnodeJoinIDs: [],
        domainSnapshotIDs: [],
        targetSnapshotIDs: [],
        snapshotPairIDs: [],
        namespaceObservationIDs: [],
        commitmentIDs: [],
        signalCallIDs: [],
        signalZeroCallIDs: [],
        waitCallIDs: [],
        reapIDs: [],
        absenceProofIDs: [],
        conservationIDs: [],
        conservationSetCommitmentIDs: [],
        conservationSetMembershipIDs: [],
        conservationSetMappingIDs: [])
}

struct DisposalMetricsMaterial: Sendable {
    let database: Data
    let databaseSHA256: String
    let projectionID: String
    let relationalExportSHA256: String
    let sampleIDs: [String]
    let metricIDs: [String]
    let ddlSHA256: String
    let rationalMathSHA256: String
}

struct DisposalGraphMaterial: Sendable {
    let database: Data
    let databaseSHA256: String
    let projectionID: String
    let graphExportSHA256: String
    let nodeCount: Int
    let edgeCount: Int
    let ddlSHA256: String
}
