import Darwin
import Foundation

struct LedgerScannedSection: Sendable {
    let ordinal: Int
    let level: Int
    let headingLine: Int
    let headingByteOffset: Int
    var contentEndByteOffset: Int
    let headingText: String
    let headingSHA256: String
}

struct LedgerScannedNode: Sendable {
    let pointer: String
    let parentPointer: String?
    let childOrdinal: Int
    let kind: String
    let decodedText: String?
    let relativeByteOffset: Int
    let byteCount: Int
    let rawSHA256: String
    let childCount: Int
}

struct LedgerScannedState: Sendable {
    let pointer: String
    let exactValue: String
    let stateClass: String
}

struct LedgerScannedDigest: Sendable {
    let pointer: String
    let widthBits: Int
    let exactHex: String
    let declaredAlgorithm: String?
}

struct LedgerScannedRecord: Sendable {
    let ordinal: Int
    let sectionOrdinal: Int?
    let fenceOrdinal: Int
    let ordinalInFence: Int
    let lineNumber: Int
    let byteOffset: Int
    let raw: Data
    let rawSHA256NoLF: String
    let rawSHA256WithLF: String
    let canonicalState: String
    let canonicalJSONSHA256: String
    let schema: String?
    let status: String?
    let payloadPresent: Bool
    let payloadHashRule: String?
    let declaredPayloadSHA256: String?
    let computedPayloadSHA256: String?
    let payloadHashState: String
    let nodes: [LedgerScannedNode]
    let states: [LedgerScannedState]
    let digests: [LedgerScannedDigest]
}

struct LedgerScanResult: Sendable {
    let source: Data
    let sections: [LedgerScannedSection]
    let fenceCount: Int
    let records: [LedgerScannedRecord]

    var canonicalRecordCount: Int {
        records.lazy.filter { $0.canonicalState == "CANONICAL_EXACT" }.count
    }

    var legacyRecordCount: Int { records.count - canonicalRecordCount }
    var jsonNodeCount: Int { records.reduce(0) { $0 + $1.nodes.count } }
    var stateTokenCount: Int { records.reduce(0) { $0 + $1.states.count } }
    var digestOccurrenceCount: Int { records.reduce(0) { $0 + $1.digests.count } }
}

enum LedgerPrefixScanner {
    static let maximumSourceBytes = 4 * 1_024 * 1_024
    static let maximumFences = 512
    static let maximumRecords = 1_024
    static let maximumRecordBytes = 256 * 1_024
    static let maximumTotalNodes = 131_072

    static func scanPinnedSource() throws -> LedgerScanResult {
        let held = try HeldLedgerSource()
        let source = held.data
        try require(source.count == PinnedLedgerProjectionV1.sourceBytes, "SOURCE_BYTES")
        try require(source.count <= maximumSourceBytes, "SOURCE_CAP")
        try require(source.last == 0x0a, "SOURCE_TERMINAL_LF")
        try require(source.filter { $0 == 0x0a }.count == PinnedLedgerProjectionV1.sourceLFCount, "SOURCE_LF_COUNT")
        try require(ledgerSHA256(source) == PinnedLedgerProjectionV1.sourceSHA256, "SOURCE_SHA256")
        let result = try scan(source: source)
        try held.revalidate()
        return result
    }

    static func scan(source: Data) throws -> LedgerScanResult {
        try require(source.count <= maximumSourceBytes, "SOURCE_CAP")
        var sections: [LedgerScannedSection] = []
        var records: [LedgerScannedRecord] = []
        var fenceLanguage: String?
        var fenceOrdinal = 0
        var ordinalInFence = 0
        var currentSectionOrdinal: Int?
        var totalNodes = 0
        var lineNumber = 1
        var start = 0
        let bytes = [UInt8](source)

        for end in 0...bytes.count where end == bytes.count || bytes[end] == 0x0a {
            let hasLF = end < bytes.count
            let raw = Data(bytes[start..<end])
            let text = String(data: raw, encoding: .utf8)

            if let text, let heading = parseHeading(text), fenceLanguage == nil {
                if heading.level == 2 {
                    if !sections.isEmpty { sections[sections.count - 1].contentEndByteOffset = start }
                    let ordinal = sections.count + 1
                    sections.append(.init(
                        ordinal: ordinal,
                        level: heading.level,
                        headingLine: lineNumber,
                        headingByteOffset: start,
                        contentEndByteOffset: source.count,
                        headingText: heading.text,
                        headingSHA256: ledgerSHA256(raw)))
                    currentSectionOrdinal = ordinal
                }
            }

            if let text, text.hasPrefix("```") {
                if fenceLanguage == nil {
                    fenceLanguage = String(text.dropFirst(3)).lowercased()
                    if fenceLanguage == "json" {
                        fenceOrdinal += 1
                        ordinalInFence = 0
                        try require(fenceOrdinal <= maximumFences, "FENCE_CAP")
                    }
                } else if text == "```" {
                    fenceLanguage = nil
                    ordinalInFence = 0
                }
            } else if fenceLanguage == "json" && !raw.isEmpty {
                try require(hasLF, "RECORD_TERMINAL_LF")
                try require(raw.count <= maximumRecordBytes, "RECORD_BYTE_CAP")
                try require(records.count < maximumRecords, "RECORD_COUNT_CAP")
                ordinalInFence += 1
                let record = try scanRecord(
                    raw: raw,
                    ordinal: records.count + 1,
                    sectionOrdinal: currentSectionOrdinal,
                    fenceOrdinal: fenceOrdinal,
                    ordinalInFence: ordinalInFence,
                    lineNumber: lineNumber,
                    byteOffset: start)
                totalNodes += record.nodes.count
                try require(totalNodes <= maximumTotalNodes, "TOTAL_NODE_CAP")
                records.append(record)
            }

            start = end + 1
            lineNumber += 1
        }
        try require(fenceLanguage == nil, "UNCLOSED_MARKDOWN_FENCE")
        if !sections.isEmpty { sections[sections.count - 1].contentEndByteOffset = source.count }

        let result = LedgerScanResult(
            source: source,
            sections: sections,
            fenceCount: fenceOrdinal,
            records: records)
        if ledgerSHA256(source) == PinnedLedgerProjectionV1.sourceSHA256 {
            try require(result.sections.count == 174, "PINNED_SECTION_COUNT")
            try require(result.fenceCount == 73, "PINNED_FENCE_COUNT")
            try require(result.records.count == 76, "PINNED_RECORD_COUNT")
            try require(result.canonicalRecordCount == 67, "PINNED_CANONICAL_COUNT")
            try require(result.legacyRecordCount == 9, "PINNED_LEGACY_COUNT")
            try require(result.jsonNodeCount == 22_576, "PINNED_NODE_COUNT")
            try require(result.stateTokenCount == 490, "PINNED_STATE_COUNT")
            try require(result.digestOccurrenceCount == 1_292, "PINNED_DIGEST_COUNT")
            guard let terminal = result.records.last else { throw rejection("PINNED_TERMINAL_ABSENT") }
            try require(terminal.rawSHA256NoLF == PinnedLedgerProjectionV1.terminalFrameSHA256, "PINNED_TERMINAL_FRAME")
            try require(terminal.rawSHA256WithLF == PinnedLedgerProjectionV1.terminalFrameWithLFSHA256, "PINNED_TERMINAL_FRAME_LF")
            try require(terminal.computedPayloadSHA256 == PinnedLedgerProjectionV1.terminalPayloadSHA256, "PINNED_TERMINAL_PAYLOAD")
        }
        return result
    }

    private static func scanRecord(
        raw: Data,
        ordinal: Int,
        sectionOrdinal: Int?,
        fenceOrdinal: Int,
        ordinalInFence: Int,
        lineNumber: Int,
        byteOffset: Int
    ) throws -> LedgerScannedRecord {
        var parser = LedgerCanonicalJSONParser(data: raw)
        let value = try parser.parse()
        guard case .object = value else { throw rejection("RECORD_ROOT_NOT_OBJECT") }
        let canonical = value.canonicalData()
        let canonicalState = canonical == raw ? "CANONICAL_EXACT" : "PARSED_LEGACY_NONCANONICAL"
        let schema = value.member("schema")?.stringValue()
        let status = value.member("status")?.stringValue()
        let payload = value.member("payload")
        let payloadHashRule = value.member("payload_hash_rule")?.stringValue()
        let declaredPayloadSHA256 = value.member("payload_sha256")?.stringValue()
        let computedPayloadSHA256 = payload.map { ledgerSHA256($0.canonicalData()) }
        let payloadHashState: String
        if let computedPayloadSHA256 {
            if let declaredPayloadSHA256 {
                try require(declaredPayloadSHA256 == computedPayloadSHA256, "PAYLOAD_HASH_MISMATCH", "line=\(lineNumber)")
                payloadHashState = "MATCH"
            } else {
                payloadHashState = "ABSENT_DECLARATION"
            }
        } else {
            payloadHashState = "NOT_APPLICABLE"
        }

        var nodes: [LedgerScannedNode] = []
        var states: [LedgerScannedState] = []
        var digests: [LedgerScannedDigest] = []
        flatten(
            value,
            raw: raw,
            pointer: "",
            parentPointer: nil,
            childOrdinal: 0,
            nodes: &nodes,
            states: &states,
            digests: &digests)

        var withLF = raw
        withLF.append(0x0a)
        return .init(
            ordinal: ordinal,
            sectionOrdinal: sectionOrdinal,
            fenceOrdinal: fenceOrdinal,
            ordinalInFence: ordinalInFence,
            lineNumber: lineNumber,
            byteOffset: byteOffset,
            raw: raw,
            rawSHA256NoLF: ledgerSHA256(raw),
            rawSHA256WithLF: ledgerSHA256(withLF),
            canonicalState: canonicalState,
            canonicalJSONSHA256: ledgerSHA256(canonical),
            schema: schema,
            status: status,
            payloadPresent: payload != nil,
            payloadHashRule: payloadHashRule,
            declaredPayloadSHA256: declaredPayloadSHA256,
            computedPayloadSHA256: computedPayloadSHA256,
            payloadHashState: payloadHashState,
            nodes: nodes,
            states: states,
            digests: digests)
    }

    private static func flatten(
        _ value: LedgerJSONValue,
        raw: Data,
        pointer: String,
        parentPointer: String?,
        childOrdinal: Int,
        nodes: inout [LedgerScannedNode],
        states: inout [LedgerScannedState],
        digests: inout [LedgerScannedDigest]
    ) {
        let span = value.span
        let nodeBytes = raw.subdata(in: span.lowerBound..<span.upperBound)
        nodes.append(.init(
            pointer: pointer,
            parentPointer: parentPointer,
            childOrdinal: childOrdinal,
            kind: value.kind,
            decodedText: value.decodedText,
            relativeByteOffset: span.lowerBound,
            byteCount: span.count,
            rawSHA256: ledgerSHA256(nodeBytes),
            childCount: value.childCount))

        if case .string(let text, _) = value {
            if let stateClass = classifyState(text) {
                states.append(.init(pointer: pointer, exactValue: text, stateClass: stateClass))
            }
            if isLowerHex(text, count: 40) {
                digests.append(.init(pointer: pointer, widthBits: 160, exactHex: text, declaredAlgorithm: nil))
            } else if isLowerHex(text, count: 64) {
                let token = pointer.split(separator: "/").last.map(String.init) ?? ""
                digests.append(.init(
                    pointer: pointer,
                    widthBits: 256,
                    exactHex: text,
                    declaredAlgorithm: token.lowercased().contains("sha256") ? "SHA256" : nil))
            }
        }

        switch value {
        case .object(let members, _):
            for (index, member) in members.enumerated() {
                let childPointer = pointer + "/" + escapePointerToken(member.key)
                flatten(
                    member.value,
                    raw: raw,
                    pointer: childPointer,
                    parentPointer: pointer,
                    childOrdinal: index,
                    nodes: &nodes,
                    states: &states,
                    digests: &digests)
            }
        case .array(let values, _):
            for (index, child) in values.enumerated() {
                flatten(
                    child,
                    raw: raw,
                    pointer: pointer + "/" + String(index),
                    parentPointer: pointer,
                    childOrdinal: index,
                    nodes: &nodes,
                    states: &states,
                    digests: &digests)
            }
        default:
            break
        }
    }

    private static func classifyState(_ value: String) -> String? {
        if value == "PASS" || value.hasPrefix("PASS_") { return "PASS" }
        if value == "FAIL" || value.hasPrefix("FAIL_") { return "FAIL" }
        if value == "ABSTAIN" || value.hasPrefix("ABSTAIN_") { return "ABSTAIN" }
        return nil
    }

    private static func isLowerHex(_ value: String, count: Int) -> Bool {
        value.utf8.count == count && value.utf8.allSatisfy {
            (0x30...0x39).contains($0) || (0x61...0x66).contains($0)
        }
    }

    private static func escapePointerToken(_ token: String) -> String {
        token.replacingOccurrences(of: "~", with: "~0")
            .replacingOccurrences(of: "/", with: "~1")
    }

    private static func parseHeading(_ value: String) -> (level: Int, text: String)? {
        var level = 0
        for byte in value.utf8 {
            if byte == 0x23 { level += 1 } else { break }
        }
        guard level > 0, level <= 6 else { return nil }
        let prefix = String(repeating: "#", count: level) + " "
        guard value.hasPrefix(prefix) else { return nil }
        return (level, String(value.dropFirst(prefix.count)))
    }
}

private final class HeldLedgerSource {
    let descriptor: Int32
    let initialState: stat
    let data: Data

    init() throws {
        var resolved = [CChar](repeating: 0, count: Int(PATH_MAX))
        guard realpath(PinnedLedgerProjectionV1.sourcePath, &resolved) != nil else {
            throw rejection("SOURCE_REALPATH", String(cString: strerror(errno)))
        }
        let resolvedPath = String(
            decoding: resolved.prefix { $0 != 0 }.map { UInt8(bitPattern: $0) },
            as: UTF8.self)
        try require(resolvedPath == PinnedLedgerProjectionV1.sourcePath, "SOURCE_PATH_ALIAS")

        let opened = Darwin.open(
            PinnedLedgerProjectionV1.sourcePath,
            O_RDONLY | O_CLOEXEC | O_NOFOLLOW_ANY)
        guard opened >= 0 else {
            throw rejection("SOURCE_OPEN", String(cString: strerror(errno)))
        }
        var closeOnFailure = true
        defer { if closeOnFailure { _ = Darwin.close(opened) } }

        var before = stat()
        guard fstat(opened, &before) == 0 else {
            throw rejection("SOURCE_FSTAT", String(cString: strerror(errno)))
        }
        try require((before.st_mode & S_IFMT) == S_IFREG, "SOURCE_NOT_REGULAR")
        try require((before.st_mode & 0o022) == 0, "SOURCE_WRITABLE_BY_GROUP_OR_OTHER")
        try require(before.st_nlink == 1, "SOURCE_LINK_COUNT")
        try require(before.st_uid == geteuid(), "SOURCE_OWNER")
        try require(before.st_size >= off_t(PinnedLedgerProjectionV1.sourceBytes), "SOURCE_PREFIX_SHORT")
        try require(before.st_size <= off_t(16 * 1_024 * 1_024), "SOURCE_FILE_CAP")
        data = try preadExact(
            descriptor: opened,
            count: PinnedLedgerProjectionV1.sourceBytes,
            offset: 0)

        var after = stat()
        guard fstat(opened, &after) == 0 else {
            throw rejection("SOURCE_FSTAT_AFTER_READ", String(cString: strerror(errno)))
        }
        try require(sameSourceState(before, after), "SOURCE_DRIFT_DURING_READ")
        descriptor = opened
        initialState = before
        try revalidate()
        closeOnFailure = false
    }

    deinit { _ = Darwin.close(descriptor) }

    func revalidate() throws {
        var held = stat()
        var named = stat()
        guard fstat(descriptor, &held) == 0 else {
            throw rejection("SOURCE_HELD_REVALIDATE", String(cString: strerror(errno)))
        }
        guard lstat(PinnedLedgerProjectionV1.sourcePath, &named) == 0 else {
            throw rejection("SOURCE_NAMED_REVALIDATE", String(cString: strerror(errno)))
        }
        try require(sameSourceState(initialState, held), "SOURCE_HELD_DRIFT")
        try require(sameSourceState(held, named), "SOURCE_NAMED_REBOUND")
    }
}

private func sameSourceState(_ lhs: stat, _ rhs: stat) -> Bool {
    lhs.st_dev == rhs.st_dev &&
        lhs.st_ino == rhs.st_ino &&
        lhs.st_mode == rhs.st_mode &&
        lhs.st_nlink == rhs.st_nlink &&
        lhs.st_uid == rhs.st_uid &&
        lhs.st_gid == rhs.st_gid &&
        lhs.st_size == rhs.st_size &&
        lhs.st_gen == rhs.st_gen &&
        lhs.st_mtimespec.tv_sec == rhs.st_mtimespec.tv_sec &&
        lhs.st_mtimespec.tv_nsec == rhs.st_mtimespec.tv_nsec &&
        lhs.st_ctimespec.tv_sec == rhs.st_ctimespec.tv_sec &&
        lhs.st_ctimespec.tv_nsec == rhs.st_ctimespec.tv_nsec
}

private func preadExact(descriptor: Int32, count: Int, offset: off_t) throws -> Data {
    var data = Data(count: count)
    var completed = 0
    while completed < count {
        let result = data.withUnsafeMutableBytes { raw -> Int in
            guard let base = raw.baseAddress else { return -1 }
            return pread(descriptor, base.advanced(by: completed), count - completed, offset + off_t(completed))
        }
        if result > 0 {
            completed += result
        } else if result == 0 {
            throw rejection("SOURCE_PREAD_EOF")
        } else if errno != EINTR {
            throw rejection("SOURCE_PREAD", String(cString: strerror(errno)))
        }
    }
    return data
}
