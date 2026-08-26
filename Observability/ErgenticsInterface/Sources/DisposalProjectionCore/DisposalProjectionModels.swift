import Foundation

public struct DisposalProjectionRejection: Error, Equatable, Sendable, CustomStringConvertible {
    public let code: String
    public let frameOrdinal: Int?
    public let byteOffset: Int?
    public let detail: String

    public init(
        code: String,
        frameOrdinal: Int? = nil,
        byteOffset: Int? = nil,
        detail: String = ""
    ) {
        self.code = code
        self.frameOrdinal = frameOrdinal
        self.byteOffset = byteOffset
        self.detail = detail
    }

    public var description: String {
        var fields = [code]
        if let frameOrdinal { fields.append("frame=\(frameOrdinal)") }
        if let byteOffset { fields.append("byte=\(byteOffset)") }
        if !detail.isEmpty { fields.append(detail) }
        return fields.joined(separator: ":")
    }
}

public enum DisposalEventType: String, CaseIterable, Equatable, Sendable {
    case start
    case clocks
    case policy
    case snapshot
    case namespace
    case resource
    case commitment
    case signalCall = "signal_call"
    case waitReap = "wait_reap"
    case absence
    case conservation
    case riskWindow = "risk_window"
    case terminal
}

public enum DisposalJSONNodeKind: String, Equatable, Sendable {
    case object = "OBJECT"
    case array = "ARRAY"
    case string = "STRING"
    case number = "NUMBER"
    case boolean = "BOOLEAN"
    case null = "JSON_NULL"
}

public enum DisposalJSONScalar: Equatable, Sendable {
    case string(String)
    case numberLexeme(String)
    case boolean(Bool)
    case null
}

public struct DisposalJSONNode: Equatable, Sendable {
    public let jsonPointer: String
    public let parentPointer: String?
    public let childOrdinal: Int
    public let kind: DisposalJSONNodeKind
    public let scalar: DisposalJSONScalar?
    public let childCount: Int
    public let frameRelativeByteOffset: Int
    public let journalByteOffset: Int
    public let byteCount: Int
    public let raw: Data
    public let rawSHA256: String
}

public enum DisposalIncompleteReason: Equatable, Sendable {
    case emptySource
    case prefixEndingAtOrdinal(Int)
}

public enum DisposalJournalCompletion: Equatable, Sendable {
    case incomplete(DisposalIncompleteReason)
    case terminalFramePresent(ordinal: Int, exactStatus: String)
    case sealedPresentationSource(ordinal: Int, exactStatus: String)
}

public enum DisposalJournalSourceKind: String, Equatable, Sendable {
    case disposalEvent = "DISPOSAL_EVENT_JOURNAL"
    case r19Observability = "R19_OBSERVABILITY_JOURNAL"
}

public enum DisposalSourceFrameKind: String, Equatable, Sendable {
    case disposalEvent = "DISPOSAL_EVENT"
    case r19ObservabilitySession = "R19_OBSERVABILITY_SESSION"
    case r19ObservabilitySample = "R19_OBSERVABILITY_SAMPLE"
    case r19ObservabilitySeal = "R19_OBSERVABILITY_SEAL"
}

public struct DisposalDecodedFrame: Equatable, Sendable {
    public let schema: String
    public let ordinal: Int
    public let eventType: DisposalEventType
    public let sourceFrameKind: DisposalSourceFrameKind
    public let phase: String?
    public let targetLabel: String?
    public let status: String?
    public let eventID: String?
    public let observedUTC: String?
    public let monotonicNanoseconds: UInt64?
    public let lineNumber: Int
    public let journalByteOffset: Int
    public let raw: Data
    public let rawSHA256: String
    public let rawWithLF: Data
    public let rawWithLFSHA256: String
    public let payload: Data
    public let payloadSHA256: String
    public let previousSHA256: String?
    public let nodes: [DisposalJSONNode]

    public var isTerminal: Bool { eventType == .terminal }
}

extension DisposalDecodedFrame {
    /// Compact builder-facing aliases. The stored values remain explicitly
    /// named SHA-256 fields so their algorithm cannot become ambiguous.
    public var rawSHA: String { rawSHA256 }
    public var rawWithLFSHA: String { rawWithLFSHA256 }
    public var payloadSHA: String { payloadSHA256 }
    public var previousSHA: String? { previousSHA256 }
}

public struct DisposalDecodedJournal: Equatable, Sendable {
    public let source: Data
    public let sourceSHA256: String
    public let frames: [DisposalDecodedFrame]
    public let sourceKind: DisposalJournalSourceKind
    public let sourceSealed: Bool
    public let isTerminal: Bool
    public let completion: DisposalJournalCompletion
}
