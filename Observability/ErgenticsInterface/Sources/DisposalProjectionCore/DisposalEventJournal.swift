import Foundation

public enum DisposalEventJournal {
    public static let frameSchema = "ergentics_disposal_event_frame_v1"
    public static let payloadHashRule =
        "SHA256_CANONICAL_RFC8259_EXACT_NUMBER_LEXEMES_NO_TRAILING_LF"
    public static let maximumSourceBytes = 32 * 1_024 * 1_024
    public static let maximumFrameBytes = 1 * 1_024 * 1_024
    public static let maximumFrames = 4_096
    public static let maximumTotalNodes = 1_048_576

    private static let exactOuterKeys = Set([
        "authoritative",
        "authority_vector",
        "event_type",
        "may_feed_controller",
        "ordinal",
        "payload",
        "payload_hash_rule",
        "payload_sha256",
        "previous_frame_sha256",
        "prose_may_supply_fact",
        "schema",
    ])

    public static func decode(_ source: Data) throws -> DisposalDecodedJournal {
        try require(
            source.count <= maximumSourceBytes,
            code: "JOURNAL_SOURCE_CAP",
            byteOffset: source.count)
        let sourceSHA256 = disposalSHA256(source)
        if source.isEmpty {
            return .init(
                source: source,
                sourceSHA256: sourceSHA256,
                frames: [],
                sourceKind: .disposalEvent,
                sourceSealed: false,
                isTerminal: false,
                completion: .incomplete(.emptySource))
        }
        try require(
            source.last == 0x0a,
            code: "JOURNAL_TERMINAL_LF",
            byteOffset: source.count - 1)

        let bytes = [UInt8](source)
        var frames: [DisposalDecodedFrame] = []
        var lineStart = 0
        var lineNumber = 1
        var totalNodes = 0

        for newline in bytes.indices where bytes[newline] == 0x0a {
            let expectedOrdinal = frames.count
            try require(
                expectedOrdinal < maximumFrames,
                code: "JOURNAL_FRAME_CAP",
                frameOrdinal: expectedOrdinal,
                byteOffset: lineStart)
            try require(
                newline > lineStart,
                code: "JOURNAL_EMPTY_LINE",
                frameOrdinal: expectedOrdinal,
                byteOffset: lineStart)
            try require(
                newline - lineStart <= maximumFrameBytes,
                code: "JOURNAL_FRAME_BYTE_CAP",
                frameOrdinal: expectedOrdinal,
                byteOffset: lineStart)
            try require(
                frames.last?.isTerminal != true,
                code: "JOURNAL_FRAME_AFTER_TERMINAL",
                frameOrdinal: expectedOrdinal,
                byteOffset: lineStart)

            let raw = Data(bytes[lineStart..<newline])
            var rawWithLF = raw
            rawWithLF.append(0x0a)
            let frame = try decodeFrame(
                raw: raw,
                rawWithLF: rawWithLF,
                expectedOrdinal: expectedOrdinal,
                lineNumber: lineNumber,
                journalByteOffset: lineStart,
                priorFrameWithLFSHA256: frames.last?.rawWithLFSHA256)
            totalNodes += frame.nodes.count
            try require(
                totalNodes <= maximumTotalNodes,
                code: "JOURNAL_TOTAL_NODE_CAP",
                frameOrdinal: expectedOrdinal,
                byteOffset: lineStart)
            frames.append(frame)
            lineStart = newline + 1
            lineNumber += 1
        }
        try require(
            lineStart == bytes.count,
            code: "JOURNAL_UNFRAMED_SUFFIX",
            frameOrdinal: frames.count,
            byteOffset: lineStart)

        guard let last = frames.last else {
            throw DisposalProjectionRejection(code: "JOURNAL_INTERNAL_EMPTY_AFTER_NONEMPTY")
        }
        if last.eventType == .terminal {
            guard let status = last.status else {
                throw DisposalProjectionRejection(
                    code: "TERMINAL_STATUS_ABSENT",
                    frameOrdinal: last.ordinal,
                    byteOffset: last.journalByteOffset)
            }
            return .init(
                source: source,
                sourceSHA256: sourceSHA256,
                frames: frames,
                sourceKind: .disposalEvent,
                sourceSealed: true,
                isTerminal: true,
                completion: .terminalFramePresent(ordinal: last.ordinal, exactStatus: status))
        }
        return .init(
            source: source,
            sourceSHA256: sourceSHA256,
            frames: frames,
            sourceKind: .disposalEvent,
            sourceSealed: false,
            isTerminal: false,
            completion: .incomplete(.prefixEndingAtOrdinal(last.ordinal)))
    }

    private static func decodeFrame(
        raw: Data,
        rawWithLF: Data,
        expectedOrdinal: Int,
        lineNumber: Int,
        journalByteOffset: Int,
        priorFrameWithLFSHA256: String?
    ) throws -> DisposalDecodedFrame {
        var parser = DisposalCanonicalJSONParser(
            data: raw,
            frameOrdinal: expectedOrdinal,
            journalByteOffset: journalByteOffset)
        let root = try parser.parse()
        guard case .object(let outerMembers, _) = root else {
            throw rejection(
                "FRAME_ROOT_NOT_OBJECT",
                frameOrdinal: expectedOrdinal,
                byteOffset: journalByteOffset)
        }
        try require(
            root.canonicalData() == raw,
            code: "FRAME_NOT_CANONICAL",
            frameOrdinal: expectedOrdinal,
            byteOffset: journalByteOffset)
        try require(
            Set(outerMembers.map(\.key)) == exactOuterKeys,
            code: "FRAME_OUTER_KEY_SET",
            frameOrdinal: expectedOrdinal,
            byteOffset: journalByteOffset)

        let schema = try requiredString(
            root, "schema", frameOrdinal: expectedOrdinal, byteOffset: journalByteOffset)
        try require(
            schema == frameSchema,
            code: "FRAME_SCHEMA",
            frameOrdinal: expectedOrdinal,
            byteOffset: journalByteOffset)

        let ordinalLexeme = try requiredNumber(
            root, "ordinal", frameOrdinal: expectedOrdinal, byteOffset: journalByteOffset)
        guard let ordinal = Int(ordinalLexeme), String(ordinal) == ordinalLexeme, ordinal >= 0 else {
            throw rejection(
                "FRAME_ORDINAL_INTEGER",
                frameOrdinal: expectedOrdinal,
                byteOffset: journalByteOffset,
                detail: ordinalLexeme)
        }
        try require(
            ordinal == expectedOrdinal,
            code: "FRAME_ORDINAL_SEQUENCE",
            frameOrdinal: expectedOrdinal,
            byteOffset: journalByteOffset)

        let eventTypeText = try requiredString(
            root, "event_type", frameOrdinal: ordinal, byteOffset: journalByteOffset)
        guard let eventType = DisposalEventType(rawValue: eventTypeText) else {
            throw rejection(
                "FRAME_EVENT_TYPE",
                frameOrdinal: ordinal,
                byteOffset: journalByteOffset,
                detail: eventTypeText)
        }
        if ordinal == 0 {
            try require(
                eventType == .start,
                code: "JOURNAL_FIRST_EVENT_NOT_START",
                frameOrdinal: ordinal,
                byteOffset: journalByteOffset)
        } else {
            try require(
                eventType != .start,
                code: "JOURNAL_REPEATED_START",
                frameOrdinal: ordinal,
                byteOffset: journalByteOffset)
        }

        try require(
            try requiredString(
                root, "payload_hash_rule", frameOrdinal: ordinal, byteOffset: journalByteOffset)
                == payloadHashRule,
            code: "FRAME_PAYLOAD_HASH_RULE",
            frameOrdinal: ordinal,
            byteOffset: journalByteOffset)
        try require(
            try requiredString(
                root, "authority_vector", frameOrdinal: ordinal, byteOffset: journalByteOffset)
                == "00000000",
            code: "FRAME_AUTHORITY_VECTOR",
            frameOrdinal: ordinal,
            byteOffset: journalByteOffset)
        try require(
            try requiredBoolean(
                root, "authoritative", frameOrdinal: ordinal, byteOffset: journalByteOffset) == false,
            code: "FRAME_AUTHORITATIVE",
            frameOrdinal: ordinal,
            byteOffset: journalByteOffset)
        try require(
            try requiredBoolean(
                root, "may_feed_controller", frameOrdinal: ordinal, byteOffset: journalByteOffset) == false,
            code: "FRAME_CONTROLLER_FEED",
            frameOrdinal: ordinal,
            byteOffset: journalByteOffset)
        try require(
            try requiredBoolean(
                root, "prose_may_supply_fact", frameOrdinal: ordinal, byteOffset: journalByteOffset) == false,
            code: "FRAME_PROSE_FACT",
            frameOrdinal: ordinal,
            byteOffset: journalByteOffset)

        guard let payloadValue = root.member("payload"), case .object = payloadValue else {
            throw rejection(
                "FRAME_PAYLOAD_NOT_OBJECT",
                frameOrdinal: ordinal,
                byteOffset: journalByteOffset)
        }
        let payloadSpan = payloadValue.span
        let payload = raw.subdata(in: payloadSpan.lowerBound..<payloadSpan.upperBound)
        try require(
            payloadValue.canonicalData() == payload,
            code: "FRAME_PAYLOAD_NOT_CANONICAL",
            frameOrdinal: ordinal,
            byteOffset: journalByteOffset + payloadSpan.lowerBound)
        let payloadSHA256 = disposalSHA256(payload)
        let declaredPayloadSHA256 = try requiredString(
            root, "payload_sha256", frameOrdinal: ordinal, byteOffset: journalByteOffset)
        try require(
            isLowerSHA256(declaredPayloadSHA256),
            code: "FRAME_PAYLOAD_SHA256_SHAPE",
            frameOrdinal: ordinal,
            byteOffset: journalByteOffset)
        try require(
            declaredPayloadSHA256 == payloadSHA256,
            code: "FRAME_PAYLOAD_SHA256_MISMATCH",
            frameOrdinal: ordinal,
            byteOffset: journalByteOffset)

        let previousSHA256: String?
        guard let previousValue = root.member("previous_frame_sha256") else {
            throw rejection(
                "FRAME_PREVIOUS_SHA256_ABSENT",
                frameOrdinal: ordinal,
                byteOffset: journalByteOffset)
        }
        switch previousValue {
        case .null:
            previousSHA256 = nil
        case .string(let value, _):
            try require(
                isLowerSHA256(value),
                code: "FRAME_PREVIOUS_SHA256_SHAPE",
                frameOrdinal: ordinal,
                byteOffset: journalByteOffset)
            previousSHA256 = value
        default:
            throw rejection(
                "FRAME_PREVIOUS_SHA256_TYPE",
                frameOrdinal: ordinal,
                byteOffset: journalByteOffset)
        }
        if ordinal == 0 {
            try require(
                previousSHA256 == nil,
                code: "FRAME_INITIAL_PREVIOUS_SHA256",
                frameOrdinal: ordinal,
                byteOffset: journalByteOffset)
        } else {
            try require(
                previousSHA256 == priorFrameWithLFSHA256,
                code: "FRAME_HASH_CHAIN",
                frameOrdinal: ordinal,
                byteOffset: journalByteOffset)
        }

        let phase = try optionalString(
            payloadValue, "phase", frameOrdinal: ordinal, byteOffset: journalByteOffset)
        let targetLabel = try optionalString(
            payloadValue, "target_label", frameOrdinal: ordinal, byteOffset: journalByteOffset)
        let status = try optionalString(
            payloadValue, "status", frameOrdinal: ordinal, byteOffset: journalByteOffset)
        let eventID = try optionalString(
            payloadValue, "event_id", frameOrdinal: ordinal, byteOffset: journalByteOffset)
        let observedUTC = try optionalString(
            payloadValue, "observed_utc", frameOrdinal: ordinal, byteOffset: journalByteOffset)
        let monotonicNanoseconds = try optionalUInt64(
            payloadValue, "monotonic_ns", frameOrdinal: ordinal, byteOffset: journalByteOffset)
        if eventType == .terminal {
            try require(
                status != nil,
                code: "TERMINAL_STATUS_ABSENT",
                frameOrdinal: ordinal,
                byteOffset: journalByteOffset + payloadSpan.lowerBound)
        }

        var nodes: [DisposalJSONNode] = []
        flatten(
            root,
            raw: raw,
            frameOrdinal: ordinal,
            journalByteOffset: journalByteOffset,
            pointer: "",
            parentPointer: nil,
            childOrdinal: 0,
            nodes: &nodes)
        return .init(
            schema: schema,
            ordinal: ordinal,
            eventType: eventType,
            sourceFrameKind: .disposalEvent,
            phase: phase,
            targetLabel: targetLabel,
            status: status,
            eventID: eventID,
            observedUTC: observedUTC,
            monotonicNanoseconds: monotonicNanoseconds,
            lineNumber: lineNumber,
            journalByteOffset: journalByteOffset,
            raw: raw,
            rawSHA256: disposalSHA256(raw),
            rawWithLF: rawWithLF,
            rawWithLFSHA256: disposalSHA256(rawWithLF),
            payload: payload,
            payloadSHA256: payloadSHA256,
            previousSHA256: previousSHA256,
            nodes: nodes)
    }

    private static func flatten(
        _ value: DisposalJSONValue,
        raw: Data,
        frameOrdinal: Int,
        journalByteOffset: Int,
        pointer: String,
        parentPointer: String?,
        childOrdinal: Int,
        nodes: inout [DisposalJSONNode]
    ) {
        let span = value.span
        let nodeRaw = raw.subdata(in: span.lowerBound..<span.upperBound)
        let kind: DisposalJSONNodeKind
        let scalar: DisposalJSONScalar?
        switch value {
        case .object:
            kind = .object
            scalar = nil
        case .array:
            kind = .array
            scalar = nil
        case .string(let value, _):
            kind = .string
            scalar = .string(value)
        case .number(let lexeme, _):
            kind = .number
            scalar = .numberLexeme(lexeme)
        case .boolean(let value, _):
            kind = .boolean
            scalar = .boolean(value)
        case .null:
            kind = .null
            scalar = .null
        }
        nodes.append(.init(
            jsonPointer: pointer,
            parentPointer: parentPointer,
            childOrdinal: childOrdinal,
            kind: kind,
            scalar: scalar,
            childCount: value.childCount,
            frameRelativeByteOffset: span.lowerBound,
            journalByteOffset: journalByteOffset + span.lowerBound,
            byteCount: span.count,
            raw: nodeRaw,
            rawSHA256: disposalSHA256(nodeRaw)))

        switch value {
        case .object(let members, _):
            for (index, member) in members.enumerated() {
                let childPointer = pointer + "/" + escapePointerToken(member.key)
                flatten(
                    member.value,
                    raw: raw,
                    frameOrdinal: frameOrdinal,
                    journalByteOffset: journalByteOffset,
                    pointer: childPointer,
                    parentPointer: pointer,
                    childOrdinal: index,
                    nodes: &nodes)
            }
        case .array(let values, _):
            for (index, child) in values.enumerated() {
                flatten(
                    child,
                    raw: raw,
                    frameOrdinal: frameOrdinal,
                    journalByteOffset: journalByteOffset,
                    pointer: pointer + "/" + String(index),
                    parentPointer: pointer,
                    childOrdinal: index,
                    nodes: &nodes)
            }
        default:
            break
        }
    }

    private static func requiredString(
        _ object: DisposalJSONValue,
        _ key: String,
        frameOrdinal: Int,
        byteOffset: Int
    ) throws -> String {
        guard let member = object.member(key) else {
            throw rejection(
                "FRAME_REQUIRED_MEMBER_ABSENT",
                frameOrdinal: frameOrdinal,
                byteOffset: byteOffset,
                detail: key)
        }
        guard let value = member.stringValue() else {
            throw rejection(
                "FRAME_REQUIRED_STRING",
                frameOrdinal: frameOrdinal,
                byteOffset: byteOffset + member.span.lowerBound,
                detail: key)
        }
        return value
    }

    private static func requiredNumber(
        _ object: DisposalJSONValue,
        _ key: String,
        frameOrdinal: Int,
        byteOffset: Int
    ) throws -> String {
        guard let member = object.member(key) else {
            throw rejection(
                "FRAME_REQUIRED_MEMBER_ABSENT",
                frameOrdinal: frameOrdinal,
                byteOffset: byteOffset,
                detail: key)
        }
        guard let value = member.numberLexeme() else {
            throw rejection(
                "FRAME_REQUIRED_NUMBER",
                frameOrdinal: frameOrdinal,
                byteOffset: byteOffset + member.span.lowerBound,
                detail: key)
        }
        return value
    }

    private static func requiredBoolean(
        _ object: DisposalJSONValue,
        _ key: String,
        frameOrdinal: Int,
        byteOffset: Int
    ) throws -> Bool {
        guard let member = object.member(key) else {
            throw rejection(
                "FRAME_REQUIRED_MEMBER_ABSENT",
                frameOrdinal: frameOrdinal,
                byteOffset: byteOffset,
                detail: key)
        }
        guard let value = member.booleanValue() else {
            throw rejection(
                "FRAME_REQUIRED_BOOLEAN",
                frameOrdinal: frameOrdinal,
                byteOffset: byteOffset + member.span.lowerBound,
                detail: key)
        }
        return value
    }

    private static func optionalString(
        _ object: DisposalJSONValue,
        _ key: String,
        frameOrdinal: Int,
        byteOffset: Int
    ) throws -> String? {
        guard let member = object.member(key) else { return nil }
        guard let value = member.stringValue() else {
            throw rejection(
                "FRAME_OPTIONAL_STRING_TYPE",
                frameOrdinal: frameOrdinal,
                byteOffset: byteOffset + member.span.lowerBound,
                detail: key)
        }
        return value
    }

    private static func optionalUInt64(
        _ object: DisposalJSONValue,
        _ key: String,
        frameOrdinal: Int,
        byteOffset: Int
    ) throws -> UInt64? {
        guard let member = object.member(key) else { return nil }
        guard let lexeme = member.numberLexeme(),
              let value = UInt64(lexeme),
              String(value) == lexeme
        else {
            throw rejection(
                "FRAME_OPTIONAL_UINT64_TYPE",
                frameOrdinal: frameOrdinal,
                byteOffset: byteOffset + member.span.lowerBound,
                detail: key)
        }
        return value
    }

    private static func escapePointerToken(_ token: String) -> String {
        token.replacingOccurrences(of: "~", with: "~0")
            .replacingOccurrences(of: "/", with: "~1")
    }

    private static func isLowerSHA256(_ value: String) -> Bool {
        value.utf8.count == 64 && value.utf8.allSatisfy {
            (0x30...0x39).contains($0) || (0x61...0x66).contains($0)
        }
    }

    private static func require(
        _ condition: Bool,
        code: String,
        frameOrdinal: Int? = nil,
        byteOffset: Int? = nil,
        detail: String = ""
    ) throws {
        guard condition else {
            throw rejection(
                code,
                frameOrdinal: frameOrdinal,
                byteOffset: byteOffset,
                detail: detail)
        }
    }

    private static func rejection(
        _ code: String,
        frameOrdinal: Int? = nil,
        byteOffset: Int? = nil,
        detail: String = ""
    ) -> DisposalProjectionRejection {
        .init(
            code: code,
            frameOrdinal: frameOrdinal,
            byteOffset: byteOffset,
            detail: detail)
    }
}
