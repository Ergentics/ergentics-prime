import Foundation

public enum PinnedLedgerProjectionV1 {
    public static let sourcePath =
        "/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/" +
        ".phase-a-v2-fixture-identity-restore-only-staging/docs/" +
        "PRIME-SWIFT-VALIDATION-DRIVER-V2-DURABLE-PHASE-CONTROL-2026-08-22.md"
    public static let outputRootPath =
        "/private/tmp/ergentics-ledger-projection-a9ee8e7-77b7235-v1"
    public static let databaseLeaf = "ergentics-ledger-projection.v1.sqlite3"
    public static let sealLeaf = "ergentics-ledger-projection.v1.seal.json"
    public static let sourceCommit = "a9ee8e78df41d4d769e60b2db30fcef23d01360e"
    public static let sourceTree = "132c43811ce23e0a5e9bf77f2746f567b7337503"
    public static let sourceBlob = "7ca21046e99421769dcd0b5ef59788ebd15a3d64"
    public static let sourceSHA256 =
        "77b7235a07c02b678cb40ccbc9ec48d70170403cf254f988fa6c102f950d13ab"
    public static let sourceBytes = 2_262_434
    public static let sourceLFCount = 22_833
    public static let terminalPayloadSHA256 =
        "a4e0e8b709de7f1cb96e6dc27f2361c98aed49f7275c900947cf835ae5751331"
    public static let terminalFrameSHA256 =
        "00a181c9711f753df6761230cc61a07842a6f3de3505d6226df0bae03b23ce69"
    public static let terminalFrameWithLFSHA256 =
        "4fa1cd63395c4cfc506bccadefcbfe5aab39349baf028bf781ae22fb0a9ed80a"
}

public struct LedgerProjectionRejection: Error, Equatable, Sendable {
    public let code: String
    public let detail: String

    public init(code: String, detail: String) {
        self.code = code
        self.detail = detail
    }
}

public enum LedgerProjectionAvailability: Equatable, Sendable {
    case empty
    case rejected(LedgerProjectionRejection)
    case admitted(LedgerProjectionSnapshot)
}

public struct LedgerProjectionMetadata: Equatable, Sendable {
    public let projectionID: String
    public let sourceCommit: String
    public let sourceTree: String
    public let sourceBlob: String
    public let sourceSHA256: String
    public let databaseSHA256: String
    public let databaseBytes: Int
    public let relationalExportSHA256: String
    public let graphExportSHA256: String
    public let authorityVector: String
    public let authoritative: Bool
    public let mayFeedController: Bool
}

public struct LedgerProjectionCounts: Equatable, Sendable {
    public let sections: Int
    public let fences: Int
    public let records: Int
    public let canonicalRecords: Int
    public let legacyRecords: Int
    public let jsonNodes: Int
    public let stateTokens: Int
    public let digestOccurrences: Int
    public let graphNodes: Int
    public let graphEdges: Int
}

public struct LedgerTimelineEntry: Identifiable, Equatable, Sendable {
    public var id: Int { recordOrdinal }
    public let recordOrdinal: Int
    public let lineNumber: Int
    public let sectionTitle: String?
    public let schema: String?
    public let status: String?
    public let canonicalState: String
    public let frameSHA256: String
    public let payloadSHA256: String?
    public let payloadHashState: String
}

public struct LedgerRawRecord: Identifiable, Equatable, Sendable {
    public var id: Int { recordOrdinal }
    public let recordOrdinal: Int
    public let lineNumber: Int
    public let schema: String?
    public let status: String?
    public let canonicalState: String
    public let rawJSON: String
    public let frameSHA256: String
}

public struct LedgerStateToken: Identifiable, Equatable, Sendable {
    public var id: String { "\(recordOrdinal):\(jsonPointer)" }
    public let recordOrdinal: Int
    public let jsonPointer: String
    public let exactValue: String
    public let stateClass: String
    public let canonicalSource: Bool
}

public struct LedgerGraphNode: Identifiable, Equatable, Sendable {
    public var id: String { nodeID }
    public let nodeID: String
    public let kind: String
    public let canonicalKey: String
    public let label: String
    public let recordOrdinal: Int?
    public let jsonPointer: String?
}

public struct LedgerGraphEdge: Identifiable, Equatable, Sendable {
    public var id: String { edgeID }
    public let edgeID: String
    public let fromNodeID: String
    public let predicate: String
    public let toNodeID: String
    public let sourceRecordOrdinal: Int?
    public let sourceJSONPointer: String?
    public let evidenceGrade: String
}

public struct LedgerEnergyFact: Identifiable, Equatable, Sendable {
    public var id: String { "\(recordOrdinal):\(jsonPointer)" }
    public let recordOrdinal: Int
    public let jsonPointer: String
    public let exactValue: String
    public let unit: String?
    public let qualification: String?
    public let evidenceGrade: String
}

public struct LedgerProjectionSnapshot: Equatable, Sendable {
    public let metadata: LedgerProjectionMetadata
    public let counts: LedgerProjectionCounts
    public let timeline: [LedgerTimelineEntry]
    public let records: [LedgerRawRecord]
    public let stateTokens: [LedgerStateToken]
    public let graphNodes: [LedgerGraphNode]
    public let graphEdges: [LedgerGraphEdge]
    public let energyFacts: [LedgerEnergyFact]
}

public struct LedgerProjectionBuildReport: Equatable, Sendable {
    public let outputRootPath: String
    public let databasePath: String
    public let sealPath: String
    public let databaseBytes: Int
    public let databaseSHA256: String
    public let sealSHA256: String
    public let projectionID: String
    public let counts: LedgerProjectionCounts
}
