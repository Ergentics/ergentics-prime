import Swift
import CryptoKit
import Darwin
import SQLite3

let r19AuthorityVector = "00000000"
let r19InputSessionID = "r19-observability-eaf9b76-v1"
let r19ControlCommit = "744a06db8cc7d5f4617df7667e83082ce15f15f7"
let r19ControlTree = "f8630d1d0eb4c27f7c1b5a920cfc5dd74fc33e46"
let r19ControlFrameSHA256 =
    "161998e7381c88633816819fabcd981555b859360ceb72e1b11f348643b618f5"
let r19InputJournalSHA256 =
    "6f90d4709ad136c356d75ee28ba49a71854215ed386721e734a42eac86f56743"
let r19InputDatabaseSHA256 =
    "cc3cc4489b4dee8218173721051ebc0d9be12a26a8ff1f8e3fe4e7fa6f5b4032"
let r19InputJournalBytes = 17_557
let r19InputDatabaseBytes = 1_802_240
let r19InputRootPath =
    "/Users/ergentics/Documents/Codex/2026-08-09/" +
    "resume-latin-roadmap-pr45/r19-observability-eaf9b76-v1"
let r19OutputRootPath =
    "/Users/ergentics/Documents/Codex/2026-08-09/" +
    "resume-latin-roadmap-pr45/r19-observability-eaf9b76-cpu-overlay-v1"
let r19InputJournalLeaf = "r19-observations.v1.jsonl"
let r19InputDatabaseLeaf = "r19-observations.v1.sqlite3"
let r19OutputJournalLeaf = "r19-cpu-overlay.v1.jsonl"
let r19OutputDatabaseLeaf = "r19-cpu-overlay.v1.sqlite3"
let r19OverlayFrameSchema = "prime_driver_v2_r19_observability_cpu_overlay_frame_v1"
let r19InputFrameSchema = "prime_driver_v2_r19_observability_frame_v1"
let r19PayloadHashRule =
    "SHA256_COMPACT_RECURSIVE_LEXICOGRAPHIC_KEYS_UTF8_NO_TRAILING_LF"
let r19TransformSchema = "prime_driver_v2_r19_observability_cpu_overlay_transform_v1"
let r19ExpectedUID = uid_t(501)
let r19ExpectedGID = gid_t(20)

enum R19OverlayError: Error {
    case contract(String)
    case posix(String, Int32)
    case sqlite(String, Int32)
}

@inline(__always)
func r19Require(_ condition: @autoclosure () throws -> Bool, _ operation: String) throws {
    if try !condition() { throw R19OverlayError.contract(operation) }
}

func r19SHA256(_ bytes: [UInt8]) -> String {
    SHA256.hash(data: bytes).map { byte in
        let table = Array("0123456789abcdef".utf8)
        return String(decoding: [table[Int(byte >> 4)], table[Int(byte & 15)]], as: UTF8.self)
    }.joined()
}

func r19HexByte(_ byte: UInt8) -> [UInt8] {
    let table = Array("0123456789abcdef".utf8)
    return [table[Int(byte >> 4)], table[Int(byte & 15)]]
}

func r19LexicalLess(_ lhs: String, _ rhs: String) -> Bool {
    lhs.utf8.lexicographicallyPrecedes(rhs.utf8)
}

indirect enum R19JSONValue: Equatable {
    case object([String: R19JSONValue])
    case array([R19JSONValue])
    case string(String)
    case number(String)
    case bool(Bool)
    case null

    func encoded() -> [UInt8] {
        var output: [UInt8] = []
        appendEncoded(to: &output)
        return output
    }

    private func appendEncoded(to output: inout [UInt8]) {
        switch self {
        case .object(let object):
            output.append(0x7b)
            let keys = object.keys.sorted(by: r19LexicalLess)
            for index in keys.indices {
                if index != keys.startIndex { output.append(0x2c) }
                R19JSONValue.string(keys[index]).appendEncoded(to: &output)
                output.append(0x3a)
                object[keys[index]]!.appendEncoded(to: &output)
            }
            output.append(0x7d)
        case .array(let array):
            output.append(0x5b)
            for index in array.indices {
                if index != array.startIndex { output.append(0x2c) }
                array[index].appendEncoded(to: &output)
            }
            output.append(0x5d)
        case .string(let string):
            output.append(0x22)
            for scalar in string.unicodeScalars {
                switch scalar.value {
                case 0x22: output += [0x5c, 0x22]
                case 0x5c: output += [0x5c, 0x5c]
                case 0x08: output += [0x5c, 0x62]
                case 0x0c: output += [0x5c, 0x66]
                case 0x0a: output += [0x5c, 0x6e]
                case 0x0d: output += [0x5c, 0x72]
                case 0x09: output += [0x5c, 0x74]
                case 0x00...0x1f:
                    let table = Array("0123456789abcdef".utf8)
                    output += [0x5c, 0x75, 0x30, 0x30,
                               table[Int((scalar.value >> 4) & 15)],
                               table[Int(scalar.value & 15)]]
                default:
                    output.append(contentsOf: String(scalar).utf8)
                }
            }
            output.append(0x22)
        case .number(let lexeme): output.append(contentsOf: lexeme.utf8)
        case .bool(let value): output += value ? Array("true".utf8) : Array("false".utf8)
        case .null: output += Array("null".utf8)
        }
    }

    func object(_ operation: String) throws -> [String: R19JSONValue] {
        guard case .object(let value) = self else {
            throw R19OverlayError.contract(operation)
        }
        return value
    }

    func array(_ operation: String) throws -> [R19JSONValue] {
        guard case .array(let value) = self else {
            throw R19OverlayError.contract(operation)
        }
        return value
    }

    func string(_ operation: String) throws -> String {
        guard case .string(let value) = self else {
            throw R19OverlayError.contract(operation)
        }
        return value
    }

    func uint64(_ operation: String) throws -> UInt64 {
        guard case .number(let value) = self,
              value.first != "-", let number = UInt64(value)
        else { throw R19OverlayError.contract(operation) }
        return number
    }

    func int(_ operation: String) throws -> Int {
        let value = try uint64(operation)
        guard value <= UInt64(Int.max) else { throw R19OverlayError.contract(operation) }
        return Int(value)
    }
}

struct R19CanonicalJSONParser {
    let bytes: [UInt8]
    var offset = 0
    var entryCount = 0
    let maximumDepth: Int
    let maximumEntries: Int
    let maximumStringBytes: Int

    init(
        _ bytes: [UInt8],
        maximumDepth: Int = 64,
        maximumEntries: Int = 4_096,
        maximumStringBytes: Int = 4 * 1_024 * 1_024
    ) {
        self.bytes = bytes
        self.maximumDepth = maximumDepth
        self.maximumEntries = maximumEntries
        self.maximumStringBytes = maximumStringBytes
    }

    mutating func parseCanonical() throws -> R19JSONValue {
        let value = try parseValue(depth: 0)
        skipWhitespace()
        try r19Require(offset == bytes.count, "JSON trailing byte")
        try r19Require(value.encoded() == bytes, "JSON noncanonical encoding")
        return value
    }

    mutating func parseValue(depth: Int) throws -> R19JSONValue {
        try r19Require(depth <= maximumDepth, "JSON depth cap")
        skipWhitespace()
        try r19Require(offset < bytes.count, "JSON unexpected end")
        switch bytes[offset] {
        case 0x7b: return try parseObject(depth: depth)
        case 0x5b: return try parseArray(depth: depth)
        case 0x22: return .string(try parseString())
        case 0x74:
            try consume(Array("true".utf8)); return .bool(true)
        case 0x66:
            try consume(Array("false".utf8)); return .bool(false)
        case 0x6e:
            try consume(Array("null".utf8)); return .null
        case 0x2d, 0x30...0x39: return .number(try parseInteger())
        default: throw R19OverlayError.contract("JSON token")
        }
    }

    mutating func skipWhitespace() {
        while offset < bytes.count &&
            (bytes[offset] == 0x20 || bytes[offset] == 0x09 ||
             bytes[offset] == 0x0a || bytes[offset] == 0x0d) { offset += 1 }
    }

    mutating func consume(_ expected: [UInt8]) throws {
        try r19Require(offset + expected.count <= bytes.count, "JSON literal end")
        try r19Require(Array(bytes[offset..<(offset + expected.count)]) == expected,
                       "JSON literal")
        offset += expected.count
    }

    mutating func countEntry() throws {
        entryCount += 1
        try r19Require(entryCount <= maximumEntries, "JSON entry cap")
    }

    mutating func parseObject(depth: Int) throws -> R19JSONValue {
        offset += 1
        skipWhitespace()
        var result: [String: R19JSONValue] = [:]
        if offset < bytes.count && bytes[offset] == 0x7d { offset += 1; return .object(result) }
        while true {
            try countEntry()
            skipWhitespace()
            try r19Require(offset < bytes.count && bytes[offset] == 0x22, "JSON object key")
            let key = try parseString()
            try r19Require(result[key] == nil, "JSON duplicate key")
            skipWhitespace()
            try r19Require(offset < bytes.count && bytes[offset] == 0x3a, "JSON colon")
            offset += 1
            result[key] = try parseValue(depth: depth + 1)
            skipWhitespace()
            try r19Require(offset < bytes.count, "JSON object end")
            if bytes[offset] == 0x7d { offset += 1; break }
            try r19Require(bytes[offset] == 0x2c, "JSON object comma")
            offset += 1
        }
        return .object(result)
    }

    mutating func parseArray(depth: Int) throws -> R19JSONValue {
        offset += 1
        skipWhitespace()
        var result: [R19JSONValue] = []
        if offset < bytes.count && bytes[offset] == 0x5d { offset += 1; return .array(result) }
        while true {
            try countEntry()
            result.append(try parseValue(depth: depth + 1))
            skipWhitespace()
            try r19Require(offset < bytes.count, "JSON array end")
            if bytes[offset] == 0x5d { offset += 1; break }
            try r19Require(bytes[offset] == 0x2c, "JSON array comma")
            offset += 1
        }
        return .array(result)
    }

    mutating func parseInteger() throws -> String {
        let start = offset
        var negative = false
        if bytes[offset] == 0x2d { negative = true; offset += 1 }
        try r19Require(offset < bytes.count, "JSON integer end")
        if bytes[offset] == 0x30 {
            offset += 1
            try r19Require(!negative, "JSON negative zero")
            if offset < bytes.count {
                try r19Require(!(bytes[offset] >= 0x30 && bytes[offset] <= 0x39),
                               "JSON leading zero")
            }
        } else {
            try r19Require(bytes[offset] >= 0x31 && bytes[offset] <= 0x39,
                           "JSON integer digit")
            offset += 1
            while offset < bytes.count && bytes[offset] >= 0x30 && bytes[offset] <= 0x39 {
                offset += 1
            }
        }
        if offset < bytes.count {
            try r19Require(bytes[offset] != 0x2e && bytes[offset] != 0x65 &&
                           bytes[offset] != 0x45 && bytes[offset] != 0x2b,
                           "JSON noninteger number")
        }
        return String(decoding: bytes[start..<offset], as: UTF8.self)
    }

    mutating func parseString() throws -> String {
        try r19Require(bytes[offset] == 0x22, "JSON string open")
        offset += 1
        var decoded: [UInt8] = []
        while offset < bytes.count {
            let byte = bytes[offset]
            offset += 1
            if byte == 0x22 {
                try r19Require(decoded.count <= maximumStringBytes, "JSON string cap")
                guard let value = String(validating: decoded, as: UTF8.self) else {
                    throw R19OverlayError.contract("JSON invalid UTF8")
                }
                return value
            }
            if byte < 0x20 { throw R19OverlayError.contract("JSON raw control") }
            if byte != 0x5c { decoded.append(byte); continue }
            try r19Require(offset < bytes.count, "JSON escape end")
            let escaped = bytes[offset]
            offset += 1
            switch escaped {
            case 0x22: decoded.append(0x22)
            case 0x5c: decoded.append(0x5c)
            case 0x2f: decoded.append(0x2f)
            case 0x62: decoded.append(0x08)
            case 0x66: decoded.append(0x0c)
            case 0x6e: decoded.append(0x0a)
            case 0x72: decoded.append(0x0d)
            case 0x74: decoded.append(0x09)
            case 0x75:
                var scalar = try parseHexQuad()
                if scalar >= 0xd800 && scalar <= 0xdbff {
                    try r19Require(offset + 2 <= bytes.count && bytes[offset] == 0x5c &&
                                   bytes[offset + 1] == 0x75, "JSON surrogate pair")
                    offset += 2
                    let low = try parseHexQuad()
                    try r19Require(low >= 0xdc00 && low <= 0xdfff, "JSON low surrogate")
                    scalar = 0x10000 + ((scalar - 0xd800) << 10) + (low - 0xdc00)
                } else {
                    try r19Require(!(scalar >= 0xdc00 && scalar <= 0xdfff),
                                   "JSON lone low surrogate")
                }
                guard let unicode = Unicode.Scalar(scalar) else {
                    throw R19OverlayError.contract("JSON scalar")
                }
                decoded.append(contentsOf: String(unicode).utf8)
            default: throw R19OverlayError.contract("JSON escape")
            }
        }
        throw R19OverlayError.contract("JSON unterminated string")
    }

    mutating func parseHexQuad() throws -> UInt32 {
        try r19Require(offset + 4 <= bytes.count, "JSON unicode escape")
        var value: UInt32 = 0
        for _ in 0..<4 {
            let byte = bytes[offset]
            offset += 1
            let digit: UInt32
            switch byte {
            case 0x30...0x39: digit = UInt32(byte - 0x30)
            case 0x41...0x46: digit = UInt32(byte - 0x41 + 10)
            case 0x61...0x66: digit = UInt32(byte - 0x61 + 10)
            default: throw R19OverlayError.contract("JSON unicode hex")
            }
            value = value * 16 + digit
        }
        return value
    }
}

func r19CheckedDelta(_ later: UInt64, _ earlier: UInt64) throws -> UInt64 {
    let result = later.subtractingReportingOverflow(earlier)
    try r19Require(!result.overflow, "counter regression")
    return result.partialValue
}

func r19CheckedSum(_ lhs: UInt64, _ rhs: UInt64) throws -> UInt64 {
    let result = lhs.addingReportingOverflow(rhs)
    try r19Require(!result.overflow, "counter sum overflow")
    return result.partialValue
}

func r19CheckedMultiply(_ lhs: UInt128, _ rhs: UInt128) throws -> UInt128 {
    let result = lhs.multipliedReportingOverflow(by: rhs)
    try r19Require(!result.overflow, "UInt128 product overflow")
    return result.partialValue
}

func r19GCD(_ lhs: UInt128, _ rhs: UInt128) -> UInt128 {
    var a = lhs
    var b = rhs
    while b != 0 { let remainder = a % b; a = b; b = remainder }
    return a
}

struct R19Rational: Equatable {
    let numerator: UInt128
    let denominator: UInt128
    let unit: String

    init(_ numerator: UInt128, _ denominator: UInt128, unit: String) throws {
        try r19Require(denominator > 0, "rational zero denominator")
        if numerator == 0 {
            self.numerator = 0
            self.denominator = 1
        } else {
            let divisor = r19GCD(numerator, denominator)
            self.numerator = numerator / divisor
            self.denominator = denominator / divisor
        }
        self.unit = unit
    }

    func approximation(places: Int = 12) throws -> String {
        try r19Require(places >= 0 && places <= 18, "decimal places")
        var scale: UInt128 = 1
        for _ in 0..<places { scale = try r19CheckedMultiply(scale, 10) }
        let scaled = try r19CheckedMultiply(numerator, scale)
        var quotient = scaled / denominator
        let remainder = scaled % denominator
        let otherHalf = denominator - remainder
        if remainder > otherHalf || (remainder == otherHalf && quotient % 2 == 1) {
            let next = quotient.addingReportingOverflow(1)
            try r19Require(!next.overflow, "decimal rounding overflow")
            quotient = next.partialValue
        }
        if places == 0 { return String(quotient) }
        let whole = quotient / scale
        var fraction = String(quotient % scale)
        if fraction.count < places {
            fraction = String(repeating: "0", count: places - fraction.count) + fraction
        }
        return String(whole) + "." + fraction
    }

    func json() throws -> R19JSONValue {
        .object([
            "approximation_12_places_half_even": .string(try approximation()),
            "denominator": .string(String(denominator)),
            "numerator": .string(String(numerator)),
            "unit": .string(unit),
        ])
    }
}

struct R19ExactTime: Equatable {
    let numerator: UInt128
    let denominator: UInt128
    let floor: UInt128
    let remainder: UInt128
    let ceil: UInt128

    func json() -> R19JSONValue {
        .object([
            "ceil": .string(String(ceil)),
            "denominator": .string(String(denominator)),
            "floor": .string(String(floor)),
            "numerator": .string(String(numerator)),
            "remainder": .string(String(remainder)),
            "unit": .string("nanoseconds"),
        ])
    }
}

func r19CPUTime(_ ticks: UInt64) throws -> R19ExactTime {
    let numerator = try r19CheckedMultiply(UInt128(ticks), 125)
    let denominator: UInt128 = 3
    let floor = numerator / denominator
    let remainder = numerator % denominator
    let ceil = floor + (remainder == 0 ? 0 : 1)
    return .init(numerator: numerator, denominator: denominator,
                 floor: floor, remainder: remainder, ceil: ceil)
}

func r19CPUPercent(_ ticks: UInt64, elapsedNanoseconds: UInt64) throws -> R19Rational {
    try r19Require(elapsedNanoseconds > 0, "CPU elapsed zero")
    var numerator = try r19CheckedMultiply(UInt128(ticks), 125)
    numerator = try r19CheckedMultiply(numerator, 100)
    let denominator = try r19CheckedMultiply(UInt128(elapsedNanoseconds), 3)
    return try R19Rational(numerator, denominator, unit: "aggregate_core_equivalent_percent")
}

func r19Power(_ energyNJ: UInt64, elapsedNanoseconds: UInt64) throws -> R19Rational {
    try r19Require(elapsedNanoseconds > 0, "power elapsed zero")
    return try R19Rational(UInt128(energyNJ), UInt128(elapsedNanoseconds), unit: "watts")
}

func r19Member(_ object: [String: R19JSONValue], _ key: String, _ operation: String) throws
    -> R19JSONValue
{
    guard let value = object[key] else { throw R19OverlayError.contract(operation) }
    return value
}

func r19RequireExactKeys(
    _ object: [String: R19JSONValue], _ keys: [String], _ operation: String
) throws {
    try r19Require(object.keys.sorted(by: r19LexicalLess) == keys.sorted(by: r19LexicalLess),
                   operation)
}

struct R19ParsedFrame: Equatable {
    let ordinal: Int
    let kind: String
    let sessionID: String
    let payload: R19JSONValue
    let payloadSHA256: String
    let previousFrameSHA256: String?
    let frameSHA256: String
    let rawWithLF: [UInt8]
    let byteOffset: Int
}

func r19ParseJournal(
    _ bytes: [UInt8], expectedBytes: Int = r19InputJournalBytes,
    expectedSHA256: String = r19InputJournalSHA256,
    expectedSessionID: String = r19InputSessionID,
    expectedSealFrameSHA256: String? =
        "d2e1c528f67102b4e9e21fca74bc3c82f92a405f5919cb35905d521857cc40a1"
) throws -> [R19ParsedFrame] {
    try r19Require(bytes.count == expectedBytes, "input journal byte count")
    try r19Require(bytes.last == 0x0a, "input journal terminal LF")
    try r19Require(r19SHA256(bytes) == expectedSHA256, "input journal SHA256")
    var lines: [[UInt8]] = []
    var start = 0
    for index in bytes.indices where bytes[index] == 0x0a {
        try r19Require(index > start, "input journal empty frame")
        lines.append(Array(bytes[start..<index]))
        start = index + 1
    }
    try r19Require(start == bytes.count && lines.count == 8, "input journal frame count")
    var frames: [R19ParsedFrame] = []
    var byteOffset = 0
    for ordinal in lines.indices {
        let raw = lines[ordinal]
        var parser = R19CanonicalJSONParser(raw)
        let value = try parser.parseCanonical()
        let object = try value.object("input frame object")
        try r19RequireExactKeys(
            object,
            ["frame_kind", "ordinal", "payload", "payload_hash_rule", "payload_sha256",
             "previous_frame_sha256", "schema", "session_id"],
            "input frame keys")
        let parsedOrdinal = try r19Member(object, "ordinal", "input ordinal").int("input ordinal")
        try r19Require(parsedOrdinal == ordinal, "input ordinal sequence")
        let kind = try r19Member(object, "frame_kind", "input kind").string("input kind")
        let sessionID = try r19Member(object, "session_id", "input session").string("input session")
        try r19Require(sessionID == expectedSessionID, "input session identity")
        try r19Require(
            try r19Member(object, "schema", "input frame schema").string("input frame schema") ==
                r19InputFrameSchema,
            "input frame schema value")
        try r19Require(
            try r19Member(object, "payload_hash_rule", "input payload rule")
                .string("input payload rule") == r19PayloadHashRule,
            "input payload rule value")
        let payload = try r19Member(object, "payload", "input payload")
        let payloadHash = try r19Member(object, "payload_sha256", "input payload hash")
            .string("input payload hash")
        try r19Require(r19SHA256(payload.encoded()) == payloadHash, "input payload hash match")
        let previousValue = try r19Member(object, "previous_frame_sha256", "input previous")
        let previous: String?
        if case .null = previousValue { previous = nil }
        else { previous = try previousValue.string("input previous string") }
        try r19Require(previous == frames.last?.frameSHA256, "input frame chain")
        let withLF = raw + [0x0a]
        let frameHash = r19SHA256(withLF)
        frames.append(.init(
            ordinal: ordinal, kind: kind, sessionID: sessionID, payload: payload,
            payloadSHA256: payloadHash, previousFrameSHA256: previous,
            frameSHA256: frameHash, rawWithLF: withLF, byteOffset: byteOffset))
        byteOffset += withLF.count
    }
    try r19Require(frames[0].kind == "session", "input session frame kind")
    for index in 1...6 { try r19Require(frames[index].kind == "sample", "input sample kind") }
    try r19Require(frames[7].kind == "seal", "input seal kind")
    if let expectedSealFrameSHA256 {
        try r19Require(frames[7].frameSHA256 == expectedSealFrameSHA256,
                       "input seal frame identity")
    }
    let prefix = frames[0...6].flatMap(\.rawWithLF)
    let seal = try frames[7].payload.object("input seal payload")
    try r19Require(try r19Member(seal, "preseal_frame_count", "preseal count").uint64("preseal count") == 7,
                   "input preseal frame count")
    try r19Require(try r19Member(seal, "preseal_journal_bytes", "preseal bytes").uint64("preseal bytes") == UInt64(prefix.count),
                   "input preseal bytes")
    try r19Require(try r19Member(seal, "preseal_journal_sha256", "preseal hash").string("preseal hash") == r19SHA256(prefix),
                   "input preseal hash")
    try r19Require(try r19Member(seal, "preseal_tail_frame_sha256", "preseal tail").string("preseal tail") == frames[6].frameSHA256,
                   "input preseal tail")
    return frames
}

struct R19ObservationFields: Equatable {
    let label: String
    let round: Int
    let pid: UInt64
    let uniqueID: UInt64
    let idVersion: UInt64
    let sid: UInt64
    let pgid: UInt64
    let rusageUUID: String
    let startAbstime: UInt64
    let userTicks: UInt64
    let systemTicks: UInt64
    let energyNJ: UInt64
    let availability: String
    let status: UInt64
    let originalDeltaCPULexeme: String?
    let originalCPUPercentEstimated: String?
    let originalCPUPercentAtMaximum: String?
    let originalCPUPercentAtMinimum: String?
    let elapsedMinimumNS: UInt64?
    let elapsedEstimateNS: UInt64?
    let elapsedMaximumNS: UInt64?
    let originalDeltaEnergyNJ: UInt64?
    let originalJoules: String?
    let originalErgs: String?
}

func r19OptionalString(_ value: R19JSONValue, _ operation: String) throws -> String? {
    if case .null = value { return nil }
    return try value.string(operation)
}

func r19OptionalUInt(_ value: R19JSONValue, _ operation: String) throws -> UInt64? {
    if case .null = value { return nil }
    return try value.uint64(operation)
}

func r19ExtractObservation(_ frame: R19ParsedFrame) throws -> R19ObservationFields {
    let payload = try frame.payload.object("sample payload")
    let process = try r19Member(payload, "process", "sample process").object("sample process")
    let usage = try r19Member(payload, "rusage_v6", "sample usage").object("sample usage")
    let interval = try r19Member(payload, "interval", "sample interval").object("sample interval")
    return .init(
        label: try r19Member(payload, "label", "sample label").string("sample label"),
        round: try r19Member(payload, "round", "sample round").int("sample round"),
        pid: try r19Member(payload, "pid", "sample pid").uint64("sample pid"),
        uniqueID: try r19Member(process, "unique_id", "sample unique").uint64("sample unique"),
        idVersion: try r19Member(process, "idversion", "sample idversion").uint64("sample idversion"),
        sid: try r19Member(process, "sid", "sample sid").uint64("sample sid"),
        pgid: try r19Member(process, "pgid", "sample pgid").uint64("sample pgid"),
        rusageUUID: try r19Member(usage, "uuid_hex", "sample usage uuid").string("sample usage uuid"),
        startAbstime: try r19Member(usage, "process_start_abstime", "sample start").uint64("sample start"),
        userTicks: try r19Member(usage, "user_time", "sample user ticks").uint64("sample user ticks"),
        systemTicks: try r19Member(usage, "system_time", "sample system ticks").uint64("sample system ticks"),
        energyNJ: try r19Member(usage, "energy_nj", "sample energy").uint64("sample energy"),
        availability: try r19Member(payload, "availability", "sample availability").string("sample availability"),
        status: try r19Member(process, "status", "sample status").uint64("sample status"),
        originalDeltaCPULexeme: try r19OptionalNumberLexeme(r19Member(interval, "delta_cpu_ns", "sample original cpu"), "sample original cpu"),
        originalCPUPercentEstimated: try r19OptionalString(r19Member(interval, "cpu_percent_at_estimated_interval_approx", "sample original percent"), "sample original percent"),
        originalCPUPercentAtMaximum: try r19OptionalString(r19Member(interval, "cpu_percent_at_maximum_interval_approx", "sample original max percent"), "sample original max percent"),
        originalCPUPercentAtMinimum: try r19OptionalString(r19Member(interval, "cpu_percent_at_minimum_interval_approx", "sample original min percent"), "sample original min percent"),
        elapsedMinimumNS: try r19OptionalUInt(r19Member(interval, "elapsed_minimum_ns", "sample elapsed min"), "sample elapsed min"),
        elapsedEstimateNS: try r19OptionalUInt(r19Member(interval, "elapsed_estimate_ns", "sample elapsed estimate"), "sample elapsed estimate"),
        elapsedMaximumNS: try r19OptionalUInt(r19Member(interval, "elapsed_maximum_ns", "sample elapsed max"), "sample elapsed max"),
        originalDeltaEnergyNJ: try r19OptionalUInt(r19Member(interval, "delta_energy_nj", "sample delta energy"), "sample delta energy"),
        originalJoules: try r19OptionalString(r19Member(interval, "delta_joules", "sample joules"), "sample joules"),
        originalErgs: try r19OptionalString(r19Member(interval, "delta_ergs", "sample ergs"), "sample ergs"))
}

func r19OptionalNumberLexeme(_ value: R19JSONValue, _ operation: String) throws -> String? {
    if case .null = value { return nil }
    guard case .number(let lexeme) = value else { throw R19OverlayError.contract(operation) }
    return lexeme
}

struct R19EnergyProjection: Equatable {
    let deltaNJ: UInt64
    let joulesExact: String
    let ergsExact: String
    let lowerPower: R19Rational
    let estimatedPower: R19Rational
    let upperPower: R19Rational
    let meterStatus: String
}

struct R19IntervalProjection: Equatable {
    let label: String
    let predecessor: R19ParsedFrame
    let current: R19ParsedFrame
    let before: R19ObservationFields
    let after: R19ObservationFields
    let deltaUserTicks: UInt64
    let deltaSystemTicks: UInt64
    let deltaCPUTicks: UInt64
    let cpuTime: R19ExactTime
    let cpuLower: R19Rational
    let cpuEstimated: R19Rational
    let cpuUpper: R19Rational
    let energy: R19EnergyProjection
}

func r19ScaledDecimal(_ value: UInt64, places: Int) -> String {
    var digits = String(value)
    if places == 0 { return digits }
    if digits.count <= places {
        digits = String(repeating: "0", count: places + 1 - digits.count) + digits
    }
    let split = digits.index(digits.endIndex, offsetBy: -places)
    return String(digits[..<split]) + "." + String(digits[split...])
}

func r19EnergyProjection(
    deltaEnergyNJ: UInt64,
    deltaCPUTicks: UInt64,
    elapsedMinimumNS: UInt64,
    elapsedEstimateNS: UInt64,
    elapsedMaximumNS: UInt64,
    label: String
) throws -> R19EnergyProjection {
    let meter: String
    if deltaEnergyNJ == 0 {
        meter = "ABSTAIN_ZERO_DELTA_NO_POSITIVE_METER_SUPPORT_EVIDENCE"
    } else {
        try r19Require(label == "guardian", "unexpected positive energy label")
        meter = "POSITIVE_KERNEL_TASK_ATTRIBUTED_DELTA_OBSERVED_SCOPE_REMAINS_QUALIFIED"
    }
    if deltaEnergyNJ == 0 && deltaCPUTicks > 0 {
        throw R19OverlayError.contract("zero energy with positive CPU")
    }
    return .init(
        deltaNJ: deltaEnergyNJ,
        joulesExact: r19ScaledDecimal(deltaEnergyNJ, places: 9),
        ergsExact: r19ScaledDecimal(deltaEnergyNJ, places: 2),
        lowerPower: try r19Power(deltaEnergyNJ, elapsedNanoseconds: elapsedMaximumNS),
        estimatedPower: try r19Power(deltaEnergyNJ, elapsedNanoseconds: elapsedEstimateNS),
        upperPower: try r19Power(deltaEnergyNJ, elapsedNanoseconds: elapsedMinimumNS),
        meterStatus: meter)
}

func r19ProjectInterval(
    predecessor: R19ParsedFrame, current: R19ParsedFrame, expectedLabel: String
) throws -> R19IntervalProjection {
    let before = try r19ExtractObservation(predecessor)
    let after = try r19ExtractObservation(current)
    try r19Require(before.round == 0 && after.round == 1, "interval rounds")
    try r19Require(before.label == expectedLabel && after.label == expectedLabel, "interval label")
    try r19Require(before.pid == after.pid && before.uniqueID == after.uniqueID &&
                   before.idVersion == after.idVersion && before.sid == after.sid &&
                   before.pgid == after.pgid && before.rusageUUID == after.rusageUUID &&
                   before.startAbstime == after.startAbstime,
                   "interval generation join")
    try r19Require(after.availability == "AVAILABLE_EXACT_GENERATION_SANDWICHED" &&
                   before.availability == "AVAILABLE_EXACT_GENERATION_SANDWICHED",
                   "interval sample availability")
    guard let elapsedMinimum = after.elapsedMinimumNS,
          let elapsedEstimate = after.elapsedEstimateNS,
          let elapsedMaximum = after.elapsedMaximumNS,
          let sourceDeltaEnergy = after.originalDeltaEnergyNJ,
          let sourceDeltaCPU = after.originalDeltaCPULexeme,
          let sourceJoules = after.originalJoules,
          let sourceErgs = after.originalErgs
    else { throw R19OverlayError.contract("round one interval fields") }
    try r19Require(elapsedMinimum > 0 && elapsedMinimum <= elapsedEstimate &&
                   elapsedEstimate <= elapsedMaximum, "elapsed interval ordering")
    let deltaUser = try r19CheckedDelta(after.userTicks, before.userTicks)
    let deltaSystem = try r19CheckedDelta(after.systemTicks, before.systemTicks)
    let deltaCPU = try r19CheckedSum(deltaUser, deltaSystem)
    try r19Require(sourceDeltaCPU == String(deltaCPU), "original CPU diagnosis lexeme")
    let deltaEnergy = try r19CheckedDelta(after.energyNJ, before.energyNJ)
    try r19Require(deltaEnergy == sourceDeltaEnergy, "energy delta source match")
    try r19Require(sourceJoules == r19ScaledDecimal(deltaEnergy, places: 9) &&
                   sourceErgs == r19ScaledDecimal(deltaEnergy, places: 2),
                   "energy exact decimal source match")
    let energy = try r19EnergyProjection(
        deltaEnergyNJ: deltaEnergy, deltaCPUTicks: deltaCPU,
        elapsedMinimumNS: elapsedMinimum, elapsedEstimateNS: elapsedEstimate,
        elapsedMaximumNS: elapsedMaximum, label: expectedLabel)
    return .init(
        label: expectedLabel, predecessor: predecessor, current: current,
        before: before, after: after,
        deltaUserTicks: deltaUser, deltaSystemTicks: deltaSystem,
        deltaCPUTicks: deltaCPU, cpuTime: try r19CPUTime(deltaCPU),
        cpuLower: try r19CPUPercent(deltaCPU, elapsedNanoseconds: elapsedMaximum),
        cpuEstimated: try r19CPUPercent(deltaCPU, elapsedNanoseconds: elapsedEstimate),
        cpuUpper: try r19CPUPercent(deltaCPU, elapsedNanoseconds: elapsedMinimum),
        energy: energy)
}

typealias R19IntervalPairPin = (Int, String, String, Int, String, String, String)

let r19PairPins: [R19IntervalPairPin] = [
    (1, "0d038102858c9e7eca6d33eee33b40c19b92818be95faf70ec89c1a53b0cc479",
     "af0357467461ee7d29422d7f81081e941b743fc126834e4c0e199f629b09a8e1",
     4, "772dbce9af1dfa2f8bb8482ce70486ea8b5ddc45b01d684ea8fa2c060e0b1809",
     "6596221f97dd3417935747dc2e46079759654944a24fd34bbaaa7cbb50b12804", "wrapper"),
    (2, "c5bf5cceca75877dfdb2613857a0753adb68f8db56abdcbd92058cb55f8c95ec",
     "3828ef81a1260b63c6707c27869ab0229c57deb4b0c7bd0af39f336688799181",
     5, "395fd45de1a1a1b896dea6c71da620d8e46f386cc43ed064b1e8f28561ad5f71",
     "2bacc9cee04aabd82b377cac5cd306e624722a72b5fa81abaca3b1dec2768064", "guardian"),
    (3, "9da1c5798c88eaa29a9671c51c997712690b3c5d455b45a5ca2e35fa4e282405",
     "a003ca19f8651f62455c06a157abeef9f10662536605e85acf4fabd8c18fdc56",
     6, "c7d354bd8fb70b97babe7aa2ac2f509282f982c19c3a3892dbb5c4ca068788ba",
     "245eae5841d6f1be97804f25fb239ac44adb6632e29d5a4f94dacc52d9d7d799", "fixture"),
]

func r19BuildIntervalProjections(
    _ frames: [R19ParsedFrame], pairPins: [R19IntervalPairPin]
) throws
    -> [R19IntervalProjection]
{
    try r19Require(frames.count == 8, "projection input frame count")
    var result: [R19IntervalProjection] = []
    for pin in pairPins {
        let before = frames[pin.0]
        let after = frames[pin.3]
        try r19Require(before.frameSHA256 == pin.1 && before.payloadSHA256 == pin.2 &&
                       after.frameSHA256 == pin.4 && after.payloadSHA256 == pin.5,
                       "frozen interval pair identity")
        result.append(try r19ProjectInterval(
            predecessor: before, current: after, expectedLabel: pin.6))
    }
    return result
}

func r19BuildIntervalProjections(_ frames: [R19ParsedFrame]) throws
    -> [R19IntervalProjection]
{
    try r19BuildIntervalProjections(frames, pairPins: r19PairPins)
}

struct R19OverlayFrame: Equatable {
    let ordinal: Int
    let kind: String
    let payload: R19JSONValue
    let payloadSHA256: String
    let previousFrameSHA256: String?
    let frameSHA256: String
    let byteOffset: Int
    let rawWithLF: [UInt8]
}

func r19MakeFrame(
    ordinal: Int, kind: String, payload: R19JSONValue,
    previous: String?, byteOffset: Int
) -> R19OverlayFrame {
    let payloadHash = r19SHA256(payload.encoded())
    let value = R19JSONValue.object([
        "frame_kind": .string(kind),
        "ordinal": .number(String(ordinal)),
        "payload": payload,
        "payload_hash_rule": .string(r19PayloadHashRule),
        "payload_sha256": .string(payloadHash),
        "previous_frame_sha256": previous.map(R19JSONValue.string) ?? .null,
        "schema": .string(r19OverlayFrameSchema),
        "session_id": .string(r19InputSessionID),
    ])
    let raw = value.encoded() + [0x0a]
    return .init(ordinal: ordinal, kind: kind, payload: payload,
                 payloadSHA256: payloadHash, previousFrameSHA256: previous,
                 frameSHA256: r19SHA256(raw), byteOffset: byteOffset, rawWithLF: raw)
}

func r19ProjectionID() -> String {
    let value = R19JSONValue.object([
        "control_frame_sha256": .string(r19ControlFrameSHA256),
        "input_database_sha256": .string(r19InputDatabaseSHA256),
        "input_journal_sha256": .string(r19InputJournalSHA256),
        "timebase_denominator": .number("3"),
        "timebase_numerator": .number("125"),
        "transform_schema": .string(r19TransformSchema),
    ])
    return r19SHA256(value.encoded())
}

func r19ArgumentPreflight(_ count: Int) -> Int32? { count == 1 ? nil : 64 }

func r19RegisterEINTR(_ enteredResults: inout Int) throws {
    enteredResults += 1
    if enteredResults >= 64 {
        throw R19OverlayError.posix("byte I/O EINTR budget", EINTR)
    }
}

struct R19InventoryBudget {
    var positiveResults = 0
    var acceptedNonDotEntries = 0

    mutating func registerPositiveResult() throws {
        positiveResults += 1
        try r19Require(positiveResults < 6, "inventory readdir result budget")
    }

    mutating func registerNonDotEntry() throws {
        try r19Require(acceptedNonDotEntries < 2, "inventory non-dot entry cap")
        acceptedNonDotEntries += 1
    }
}

let r19SQLiteTransient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

final class R19SQLiteConnection {
    var handle: OpaquePointer?

    init() throws {
        let flags = SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_MEMORY | SQLITE_OPEN_NOMUTEX
        let result = sqlite3_open_v2(":memory:", &handle, flags, nil)
        if result != SQLITE_OK {
            if let handle { sqlite3_close(handle) }
            throw R19OverlayError.sqlite("sqlite open memory", result)
        }
        let extendedResult = sqlite3_extended_result_codes(handle, 1)
        if extendedResult != SQLITE_OK {
            if let handle { sqlite3_close(handle) }
            self.handle = nil
            throw R19OverlayError.sqlite("sqlite extended result codes", extendedResult)
        }
    }

    deinit { if let handle { sqlite3_close(handle) } }

    func close() throws {
        guard let handle else { return }
        let result = sqlite3_close(handle)
        if result != SQLITE_OK { throw R19OverlayError.sqlite("sqlite close", result) }
        self.handle = nil
    }

    func execute(_ sql: String) throws {
        guard let handle else { throw R19OverlayError.contract("sqlite closed") }
        var message: UnsafeMutablePointer<CChar>?
        let result = sqlite3_exec(handle, sql, nil, nil, &message)
        if let message { sqlite3_free(message) }
        if result != SQLITE_OK { throw R19OverlayError.sqlite("sqlite exec", result) }
    }

    func prepare(_ sql: String) throws -> OpaquePointer {
        guard let handle else { throw R19OverlayError.contract("sqlite closed") }
        var statement: OpaquePointer?
        let result = sqlite3_prepare_v2(handle, sql, -1, &statement, nil)
        guard result == SQLITE_OK, let statement else {
            throw R19OverlayError.sqlite("sqlite prepare", result)
        }
        return statement
    }

    func serialize() throws -> [UInt8] {
        guard let handle else { throw R19OverlayError.contract("sqlite closed") }
        var count: sqlite3_int64 = 0
        guard let pointer = sqlite3_serialize(handle, "main", &count, 0) else {
            throw R19OverlayError.sqlite("sqlite serialize", sqlite3_errcode(handle))
        }
        defer { sqlite3_free(pointer) }
        try r19Require(count > 0 && count <= 1_048_576, "overlay database byte cap")
        return Array(UnsafeBufferPointer(start: pointer, count: Int(count)))
    }
}

func r19SQLiteStepDone(_ statement: OpaquePointer) throws {
    let result = sqlite3_step(statement)
    if result != SQLITE_DONE { throw R19OverlayError.sqlite("sqlite step done", result) }
}

func r19BindText(_ statement: OpaquePointer, _ index: Int32, _ value: String?) throws {
    let result: Int32
    if let value {
        result = value.withCString { pointer in
            sqlite3_bind_text(statement, index, pointer, Int32(value.utf8.count), r19SQLiteTransient)
        }
    } else { result = sqlite3_bind_null(statement, index) }
    if result != SQLITE_OK { throw R19OverlayError.sqlite("sqlite bind text", result) }
}

func r19BindInt(_ statement: OpaquePointer, _ index: Int32, _ value: Int64) throws {
    let result = sqlite3_bind_int64(statement, index, value)
    if result != SQLITE_OK { throw R19OverlayError.sqlite("sqlite bind int", result) }
}

func r19BindBlob(_ statement: OpaquePointer, _ index: Int32, _ value: [UInt8]) throws {
    let result = value.withUnsafeBytes { raw in
        sqlite3_bind_blob(statement, index, raw.baseAddress, Int32(raw.count), r19SQLiteTransient)
    }
    if result != SQLITE_OK { throw R19OverlayError.sqlite("sqlite bind blob", result) }
}

func r19SQLiteScalarText(_ connection: R19SQLiteConnection, _ sql: String) throws -> String {
    let statement = try connection.prepare(sql)
    defer { sqlite3_finalize(statement) }
    let rowResult = sqlite3_step(statement)
    if rowResult == SQLITE_DONE {
        throw R19OverlayError.contract("sqlite scalar text row missing")
    }
    if rowResult != SQLITE_ROW {
        throw R19OverlayError.sqlite("sqlite scalar text row", rowResult)
    }
    guard let pointer = sqlite3_column_text(statement, 0) else {
        throw R19OverlayError.contract("sqlite scalar null")
    }
    let value = String(cString: pointer)
    let terminalResult = sqlite3_step(statement)
    if terminalResult == SQLITE_ROW {
        throw R19OverlayError.contract("sqlite scalar text cardinality")
    }
    if terminalResult != SQLITE_DONE {
        throw R19OverlayError.sqlite("sqlite scalar text terminal", terminalResult)
    }
    return value
}

func r19SQLiteScalarInt(_ connection: R19SQLiteConnection, _ sql: String) throws -> Int64 {
    let statement = try connection.prepare(sql)
    defer { sqlite3_finalize(statement) }
    let rowResult = sqlite3_step(statement)
    if rowResult == SQLITE_DONE {
        throw R19OverlayError.contract("sqlite scalar int row missing")
    }
    if rowResult != SQLITE_ROW {
        throw R19OverlayError.sqlite("sqlite scalar int row", rowResult)
    }
    let value = sqlite3_column_int64(statement, 0)
    let terminalResult = sqlite3_step(statement)
    if terminalResult == SQLITE_ROW {
        throw R19OverlayError.contract("sqlite scalar int cardinality")
    }
    if terminalResult != SQLITE_DONE {
        throw R19OverlayError.sqlite("sqlite scalar int terminal", terminalResult)
    }
    return value
}

let r19DatabaseSchemaStatements: [String] = [
    "PRAGMA page_size=4096;",
    "PRAGMA encoding='UTF-8';",
    "PRAGMA auto_vacuum=NONE;",
    "PRAGMA journal_mode=OFF;",
    "PRAGMA synchronous=OFF;",
    "PRAGMA temp_store=MEMORY;",
    "PRAGMA locking_mode=EXCLUSIVE;",
    "PRAGMA foreign_keys=ON;",
    "PRAGMA trusted_schema=OFF;",
    "PRAGMA application_id=1378957647;",
    "PRAGMA user_version=1;",
    "CREATE TABLE metadata(key TEXT PRIMARY KEY,value TEXT NOT NULL) STRICT,WITHOUT ROWID;",
    "CREATE TABLE input_artifacts(role TEXT PRIMARY KEY CHECK(role IN('journal','database')),path TEXT NOT NULL UNIQUE,device INTEGER NOT NULL,inode INTEGER NOT NULL,uid INTEGER NOT NULL,gid INTEGER NOT NULL,mode TEXT NOT NULL,nlink INTEGER NOT NULL,bytes INTEGER NOT NULL,sha256 TEXT NOT NULL CHECK(length(sha256)=64)) STRICT,WITHOUT ROWID;",
    "CREATE TABLE intervals(source_frame_ordinal INTEGER PRIMARY KEY CHECK(source_frame_ordinal IN(4,5,6)),predecessor_frame_ordinal INTEGER NOT NULL UNIQUE CHECK(predecessor_frame_ordinal IN(1,2,3)),source_frame_sha256 TEXT NOT NULL UNIQUE CHECK(length(source_frame_sha256)=64),predecessor_frame_sha256 TEXT NOT NULL UNIQUE CHECK(length(predecessor_frame_sha256)=64),source_payload_sha256 TEXT NOT NULL CHECK(length(source_payload_sha256)=64),predecessor_payload_sha256 TEXT NOT NULL CHECK(length(predecessor_payload_sha256)=64),target_label TEXT NOT NULL UNIQUE CHECK(target_label IN('wrapper','guardian','fixture')),sample_round INTEGER NOT NULL CHECK(sample_round=1),pid INTEGER NOT NULL,unique_id_text TEXT NOT NULL,idversion_text TEXT NOT NULL,sid INTEGER NOT NULL,pgid INTEGER NOT NULL,rusage_uuid_hex TEXT NOT NULL CHECK(length(rusage_uuid_hex)=32),process_start_abstime_text TEXT NOT NULL,delta_user_ticks_text TEXT NOT NULL,delta_system_ticks_text TEXT NOT NULL,delta_cpu_ticks_text TEXT NOT NULL,elapsed_minimum_ns_text TEXT NOT NULL,elapsed_estimate_ns_text TEXT NOT NULL,elapsed_maximum_ns_text TEXT NOT NULL,delta_energy_nj_text TEXT NOT NULL,generation_join_status TEXT NOT NULL) STRICT,WITHOUT ROWID;",
    "CREATE TABLE field_adjudications(source_frame_ordinal INTEGER NOT NULL REFERENCES intervals(source_frame_ordinal),field_surface TEXT NOT NULL CHECK(field_surface IN('JSON','SQLITE')),field_name TEXT NOT NULL,source_pointer TEXT NOT NULL,original_lexeme TEXT NOT NULL,verdict TEXT NOT NULL,reason TEXT NOT NULL,replacement_metric TEXT NOT NULL,PRIMARY KEY(source_frame_ordinal,field_surface,field_name)) STRICT,WITHOUT ROWID;",
    "CREATE TABLE metric_facts(source_frame_ordinal INTEGER NOT NULL REFERENCES intervals(source_frame_ordinal),metric_name TEXT NOT NULL,bound_kind TEXT NOT NULL CHECK(bound_kind IN('exact','lower','estimated','upper')),numerator_text TEXT NOT NULL,denominator_text TEXT NOT NULL,unit TEXT NOT NULL,status TEXT NOT NULL,source_pointer TEXT NOT NULL,approximation_text TEXT,PRIMARY KEY(source_frame_ordinal,metric_name,bound_kind)) STRICT,WITHOUT ROWID;",
    "CREATE TABLE overlay_frames(ordinal INTEGER PRIMARY KEY CHECK(ordinal BETWEEN 0 AND 4),frame_kind TEXT NOT NULL CHECK(frame_kind IN('start','input_admission','interval_overlay')),byte_offset INTEGER NOT NULL CHECK(byte_offset>=0),frame_bytes INTEGER NOT NULL CHECK(frame_bytes>1),frame_sha256 TEXT NOT NULL UNIQUE CHECK(length(frame_sha256)=64),previous_frame_sha256 TEXT CHECK(previous_frame_sha256 IS NULL OR length(previous_frame_sha256)=64),payload_sha256 TEXT NOT NULL CHECK(length(payload_sha256)=64),raw_frame BLOB NOT NULL CHECK(length(raw_frame)=frame_bytes)) STRICT,WITHOUT ROWID;",
    "CREATE TABLE overlay_seal(singleton INTEGER PRIMARY KEY CHECK(singleton=1),projection_id TEXT NOT NULL CHECK(length(projection_id)=64),authority_vector TEXT NOT NULL CHECK(authority_vector='00000000'),journal_prefix_frame_count INTEGER NOT NULL CHECK(journal_prefix_frame_count=5),journal_prefix_bytes INTEGER NOT NULL CHECK(journal_prefix_bytes>0),journal_prefix_sha256 TEXT NOT NULL CHECK(length(journal_prefix_sha256)=64),journal_prefix_tail_frame_sha256 TEXT NOT NULL CHECK(length(journal_prefix_tail_frame_sha256)=64),input_journal_sha256 TEXT NOT NULL CHECK(length(input_journal_sha256)=64),input_database_sha256 TEXT NOT NULL CHECK(length(input_database_sha256)=64)) STRICT;",
]

var r19DatabaseSchemaBytes: [UInt8] {
    Array(r19DatabaseSchemaStatements.joined(separator: "\n").utf8)
}

func r19ConfigureReadOnly(_ connection: R19SQLiteConnection, invokeFixedWrapper: Bool) throws {
    #if !R19_CPU_OVERLAY_TESTING
    if invokeFixedWrapper {
        guard let handle = connection.handle else {
            throw R19OverlayError.contract("sqlite fixed harden closed connection")
        }
        let result = prime_r19_overlay_sqlite_harden_connection(handle)
        if result != SQLITE_OK { throw R19OverlayError.sqlite("sqlite fixed harden", result) }
    }
    #else
    _ = invokeFixedWrapper
    #endif
    try connection.execute("PRAGMA query_only=ON")
    try connection.execute("PRAGMA trusted_schema=OFF")
    try connection.execute("PRAGMA foreign_keys=ON")
}

func r19DeserializeReadOnly(_ bytes: [UInt8], invokeFixedWrapper: Bool)
    throws -> R19SQLiteConnection
{
    let connection = try R19SQLiteConnection()
    guard let rawAllocation = sqlite3_malloc64(sqlite3_uint64(bytes.count)) else {
        throw R19OverlayError.sqlite("sqlite deserialize allocation", SQLITE_NOMEM)
    }
    let allocation = rawAllocation.assumingMemoryBound(to: UInt8.self)
    bytes.withUnsafeBytes { source in
        if let sourceBase = source.baseAddress { memcpy(allocation, sourceBase, source.count) }
    }
    let result = sqlite3_deserialize(
        connection.handle, "main", allocation,
        sqlite3_int64(bytes.count), sqlite3_int64(bytes.count),
        UInt32(SQLITE_DESERIALIZE_FREEONCLOSE | SQLITE_DESERIALIZE_READONLY))
    if result != SQLITE_OK {
        throw R19OverlayError.sqlite("sqlite deserialize", result)
    }
    try r19ConfigureReadOnly(connection, invokeFixedWrapper: invokeFixedWrapper)
    return connection
}

struct R19DatabaseArtifact: Equatable {
    let role: String
    let path: String
    let device: UInt64
    let inode: UInt64
    let uid: UInt64
    let gid: UInt64
    let mode: String
    let nlink: UInt64
    let bytes: Int
    let sha256: String
}

struct R19RootArtifact: Equatable {
    let path: String
    let device: UInt64
    let inode: UInt64
    let uid: UInt64
    let gid: UInt64
    let mode: String
    let nlink: UInt64
    let inventory: [String]
}

struct R19Adjudication: Equatable {
    let sourceFrameOrdinal: Int
    let surface: String
    let fieldName: String
    let sourcePointer: String
    let originalLexeme: String
    let verdict: String
    let reason: String
    let replacementMetric: String
}

struct R19MetricFact: Equatable {
    let sourceFrameOrdinal: Int
    let metricName: String
    let boundKind: String
    let rational: R19Rational
    let status: String
    let sourcePointer: String
    let approximation: String?
}

func r19Adjudications(_ projection: R19IntervalProjection) throws -> [R19Adjudication] {
    guard let delta = projection.after.originalDeltaCPULexeme,
          let estimated = projection.after.originalCPUPercentEstimated,
          let maximum = projection.after.originalCPUPercentAtMaximum,
          let minimum = projection.after.originalCPUPercentAtMinimum
    else { throw R19OverlayError.contract("adjudication original lexemes") }
    let ordinal = projection.current.ordinal
    let templates: [(String, String, String, String, String, String)] = [
        ("JSON", "delta_cpu_ns", "/payload/interval/delta_cpu_ns", delta,
         "INVALID_MISLABELED_MACH_ABSOLUTE_TIME_TICKS",
         "RAW_VALUE_IS_MACH_ABSOLUTE_TIME_TICKS_NOT_NANOSECONDS"),
        ("JSON", "cpu_percent_at_estimated_interval_approx",
         "/payload/interval/cpu_percent_at_estimated_interval_approx", estimated,
         "INVALID_DERIVED_WITHOUT_TIMEBASE",
         "DERIVED_FROM_UNSCALED_TICKS_WITHOUT_PERSISTED_TIMEBASE"),
        ("JSON", "cpu_percent_at_maximum_interval_approx",
         "/payload/interval/cpu_percent_at_maximum_interval_approx", maximum,
         "INVALID_DERIVED_WITHOUT_TIMEBASE",
         "DERIVED_FROM_UNSCALED_TICKS_WITHOUT_PERSISTED_TIMEBASE"),
        ("JSON", "cpu_percent_at_minimum_interval_approx",
         "/payload/interval/cpu_percent_at_minimum_interval_approx", minimum,
         "INVALID_DERIVED_WITHOUT_TIMEBASE",
         "DERIVED_FROM_UNSCALED_TICKS_WITHOUT_PERSISTED_TIMEBASE"),
        ("SQLITE", "delta_cpu_ns_text", "process_samples.delta_cpu_ns_text", delta,
         "INVALID_MISLABELED_MACH_ABSOLUTE_TIME_TICKS",
         "NORMALIZED_ROW_COPIES_MACH_TICKS_UNDER_NANOSECOND_LABEL"),
        ("SQLITE", "cpu_percent_at_estimated_interval_approx_text",
         "process_samples.cpu_percent_at_estimated_interval_approx_text", estimated,
         "INVALID_DERIVED_WITHOUT_TIMEBASE", "NORMALIZED_ROW_DERIVED_FROM_UNSCALED_TICKS"),
        ("SQLITE", "cpu_percent_at_maximum_interval_approx_text",
         "process_samples.cpu_percent_at_maximum_interval_approx_text", maximum,
         "INVALID_DERIVED_WITHOUT_TIMEBASE", "NORMALIZED_ROW_DERIVED_FROM_UNSCALED_TICKS"),
        ("SQLITE", "cpu_percent_at_minimum_interval_approx_text",
         "process_samples.cpu_percent_at_minimum_interval_approx_text", minimum,
         "INVALID_DERIVED_WITHOUT_TIMEBASE", "NORMALIZED_ROW_DERIVED_FROM_UNSCALED_TICKS"),
    ]
    return templates.map { item in
        let replacement = item.1.hasPrefix("delta_cpu") ?
            "delta_cpu_ticks_and_cpu_time_nanoseconds" :
            (item.1.contains("estimated") ? "cpu_percent_estimated" :
             (item.1.contains("maximum") ? "cpu_percent_lower" : "cpu_percent_upper"))
        return .init(sourceFrameOrdinal: ordinal, surface: item.0, fieldName: item.1,
                     sourcePointer: item.2, originalLexeme: item.3,
                     verdict: item.4, reason: item.5, replacementMetric: replacement)
    }
}

func r19MetricFacts(_ projection: R19IntervalProjection) throws -> [R19MetricFact] {
    let ordinal = projection.current.ordinal
    let elapsedMinimum = projection.after.elapsedMinimumNS!
    let elapsedMaximum = projection.after.elapsedMaximumNS!
    let cpuTime = try R19Rational(
        projection.cpuTime.numerator, projection.cpuTime.denominator, unit: "nanoseconds")
    let joules = try R19Rational(UInt128(projection.energy.deltaNJ), 1_000_000_000,
                                 unit: "joules")
    let ergs = try R19Rational(UInt128(projection.energy.deltaNJ), 100, unit: "ergs")
    let status = "PASS_NONAUTHORITATIVE_EXACT_RATIONAL"
    return [
        .init(sourceFrameOrdinal: ordinal, metricName: "cpu_percent_estimated",
              boundKind: "estimated", rational: projection.cpuEstimated, status: status,
              sourcePointer: "/payload/interval", approximation: try projection.cpuEstimated.approximation()),
        .init(sourceFrameOrdinal: ordinal, metricName: "cpu_percent_lower", boundKind: "lower",
              rational: projection.cpuLower, status: status, sourcePointer: "/payload/interval",
              approximation: try projection.cpuLower.approximation()),
        .init(sourceFrameOrdinal: ordinal, metricName: "cpu_percent_upper", boundKind: "upper",
              rational: projection.cpuUpper, status: status, sourcePointer: "/payload/interval",
              approximation: try projection.cpuUpper.approximation()),
        .init(sourceFrameOrdinal: ordinal, metricName: "cpu_time_nanoseconds", boundKind: "exact",
              rational: cpuTime, status: status, sourcePointer: "/payload/rusage_v6/user_time|system_time",
              approximation: try cpuTime.approximation()),
        .init(sourceFrameOrdinal: ordinal, metricName: "delta_cpu_ticks", boundKind: "exact",
              rational: try R19Rational(UInt128(projection.deltaCPUTicks), 1,
                                        unit: "mach_absolute_time_ticks"),
              status: status, sourcePointer: "/payload/rusage_v6/user_time|system_time",
              approximation: nil),
        .init(sourceFrameOrdinal: ordinal, metricName: "delta_energy_ergs", boundKind: "exact",
              rational: ergs, status: status, sourcePointer: "/payload/interval/delta_energy_nj",
              approximation: projection.energy.ergsExact),
        .init(sourceFrameOrdinal: ordinal, metricName: "delta_energy_joules", boundKind: "exact",
              rational: joules, status: status, sourcePointer: "/payload/interval/delta_energy_nj",
              approximation: projection.energy.joulesExact),
        .init(sourceFrameOrdinal: ordinal, metricName: "delta_energy_nj", boundKind: "exact",
              rational: try R19Rational(UInt128(projection.energy.deltaNJ), 1, unit: "nanojoules"),
              status: "VALID_MONOTONIC_RUSAGE_V6_ENERGY_NJ_DELTA",
              sourcePointer: "/payload/interval/delta_energy_nj", approximation: nil),
        .init(sourceFrameOrdinal: ordinal, metricName: "power_w_estimated", boundKind: "estimated",
              rational: projection.energy.estimatedPower, status: status,
              sourcePointer: "/payload/interval/delta_energy_nj|elapsed_estimate_ns",
              approximation: try projection.energy.estimatedPower.approximation()),
        .init(sourceFrameOrdinal: ordinal, metricName: "power_w_lower", boundKind: "lower",
              rational: try r19Power(projection.energy.deltaNJ, elapsedNanoseconds: elapsedMaximum),
              status: status,
              sourcePointer: "/payload/interval/delta_energy_nj|elapsed_maximum_ns",
              approximation: try projection.energy.lowerPower.approximation()),
        .init(sourceFrameOrdinal: ordinal, metricName: "power_w_upper", boundKind: "upper",
              rational: try r19Power(projection.energy.deltaNJ, elapsedNanoseconds: elapsedMinimum),
              status: status,
              sourcePointer: "/payload/interval/delta_energy_nj|elapsed_minimum_ns",
              approximation: try projection.energy.upperPower.approximation()),
    ]
}

func r19ArtifactJSON(_ artifact: R19DatabaseArtifact) -> R19JSONValue {
    .object([
        "bytes": .number(String(artifact.bytes)), "device": .number(String(artifact.device)),
        "gid": .number(String(artifact.gid)), "inode": .number(String(artifact.inode)),
        "mode": .string(artifact.mode), "nlink": .number(String(artifact.nlink)),
        "path": .string(artifact.path), "sha256": .string(artifact.sha256),
        "uid": .number(String(artifact.uid)),
    ])
}

func r19RootJSON(_ artifact: R19RootArtifact) -> R19JSONValue {
    .object([
        "device": .number(String(artifact.device)), "gid": .number(String(artifact.gid)),
        "inode": .number(String(artifact.inode)),
        "inventory": .array(artifact.inventory.map(R19JSONValue.string)),
        "mode": .string(artifact.mode), "nlink": .number(String(artifact.nlink)),
        "path": .string(artifact.path), "uid": .number(String(artifact.uid)),
    ])
}

func r19StartPayload() -> R19JSONValue {
    .object([
        "authority_vector": .string(r19AuthorityVector),
        "control_commit": .string(r19ControlCommit), "control_tree": .string(r19ControlTree),
        "input_database_sha256": .string(r19InputDatabaseSHA256),
        "input_journal_sha256": .string(r19InputJournalSHA256),
        "output_root": .string(r19OutputRootPath), "projection_id": .string(r19ProjectionID()),
        "schema": .string("prime_driver_v2_r19_observability_cpu_overlay_start_v1"),
        "session_id": .string(r19InputSessionID),
        "status": .string("STARTED_OFFLINE_NONAUTHORITATIVE_CPU_OVERLAY"),
        "timebase_denominator": .number("3"), "timebase_numerator": .number("125"),
        "ticks_per_second": .number("24000000"),
    ])
}

func r19InputAdmissionPayload(
    root: R19RootArtifact, journal: R19DatabaseArtifact, database: R19DatabaseArtifact
) -> R19JSONValue {
    .object([
        "database": r19ArtifactJSON(database), "journal": r19ArtifactJSON(journal),
        "root": r19RootJSON(root),
        "schema": .string("prime_driver_v2_r19_observability_cpu_overlay_input_admission_v1"),
        "status": .string("PASS_INPUT_RECEIPT_ADMITTED"),
    ])
}

func r19IntervalPayload(_ projection: R19IntervalProjection) throws -> R19JSONValue {
    let after = projection.after
    let pair = R19JSONValue.object([
        "current_frame_ordinal": .number(String(projection.current.ordinal)),
        "current_frame_sha256": .string(projection.current.frameSHA256),
        "current_payload_sha256": .string(projection.current.payloadSHA256),
        "predecessor_frame_ordinal": .number(String(projection.predecessor.ordinal)),
        "predecessor_frame_sha256": .string(projection.predecessor.frameSHA256),
        "predecessor_payload_sha256": .string(projection.predecessor.payloadSHA256),
    ])
    let cpu = R19JSONValue.object([
        "delta_ticks": .string(String(projection.deltaCPUTicks)),
        "percent_estimated": try projection.cpuEstimated.json(),
        "percent_lower": try projection.cpuLower.json(),
        "percent_upper": try projection.cpuUpper.json(),
        "time_nanoseconds": projection.cpuTime.json(),
        "timebase_premise_status":
            .string("VALID_UNDER_FROZEN_SAME_CAPTURE_HOST_24000000_HZ_PREMISE"),
    ])
    let energy = R19JSONValue.object([
        "counter_delta_status": .string("VALID_MONOTONIC_RUSAGE_V6_ENERGY_NJ_DELTA"),
        "delta_energy_nj": .string(String(projection.energy.deltaNJ)),
        "delta_ergs_exact": .string(projection.energy.ergsExact),
        "delta_joules_exact": .string(projection.energy.joulesExact),
        "meter_support_interpretation": .string(projection.energy.meterStatus),
        "power_estimated": try projection.energy.estimatedPower.json(),
        "power_lower": try projection.energy.lowerPower.json(),
        "power_upper": try projection.energy.upperPower.json(),
        "scope": .string("KERNEL_RECOUNT_DIRECT_TASK_ATTRIBUTION_AT_CONTEXT_SWITCH_GRANULARITY_NOT_WALL_PLUG_PACKAGE_GPU_OR_ANE_ENERGY"),
    ])
    let interval = R19JSONValue.object([
        "counter_interval_status": .string("VALID_MONOTONIC_COUNTER_INTERVAL"),
        "elapsed_estimate_ns": .string(String(after.elapsedEstimateNS!)),
        "elapsed_maximum_ns": .string(String(after.elapsedMaximumNS!)),
        "elapsed_minimum_ns": .string(String(after.elapsedMinimumNS!)),
        "generation_join_status":
            .string("VALID_EXACT_GENERATION_SESSION_GROUP_UUID_AND_START_JOIN"),
    ])
    return .object([
        "authority_vector": .string(r19AuthorityVector), "cpu": cpu, "energy": energy,
        "interval": interval, "label": .string(projection.label), "pair": pair,
        "round": .number("1"),
        "schema": .string("prime_driver_v2_r19_observability_cpu_overlay_interval_v1"),
        "status": .string("PASS_EXACT_TIMEBASE_PROJECTION_AUTHORITY_ABSTAIN"),
    ])
}

func r19BuildPrefixFrames(
    root: R19RootArtifact, journal: R19DatabaseArtifact, database: R19DatabaseArtifact,
    projections: [R19IntervalProjection]
) throws -> [R19OverlayFrame] {
    try r19Require(projections.map(\.label) == ["wrapper", "guardian", "fixture"],
                   "overlay projection order")
    let payloads: [(String, R19JSONValue)] = [
        ("start", r19StartPayload()),
        ("input_admission", r19InputAdmissionPayload(root: root, journal: journal, database: database)),
        ("interval_overlay", try r19IntervalPayload(projections[0])),
        ("interval_overlay", try r19IntervalPayload(projections[1])),
        ("interval_overlay", try r19IntervalPayload(projections[2])),
    ]
    var result: [R19OverlayFrame] = []
    var offset = 0
    for ordinal in payloads.indices {
        let frame = r19MakeFrame(ordinal: ordinal, kind: payloads[ordinal].0,
                                 payload: payloads[ordinal].1,
                                 previous: result.last?.frameSHA256, byteOffset: offset)
        result.append(frame)
        offset += frame.rawWithLF.count
    }
    return result
}

func r19Reset(_ statement: OpaquePointer) throws {
    let resetResult = sqlite3_reset(statement)
    if resetResult != SQLITE_OK {
        throw R19OverlayError.sqlite("sqlite reset", resetResult)
    }
    let clearResult = sqlite3_clear_bindings(statement)
    if clearResult != SQLITE_OK {
        throw R19OverlayError.sqlite("sqlite clear bindings", clearResult)
    }
}

func r19InsertMetadata(_ connection: R19SQLiteConnection, _ values: [String: String]) throws {
    let statement = try connection.prepare("INSERT INTO metadata(key,value) VALUES(?,?)")
    defer { sqlite3_finalize(statement) }
    for key in values.keys.sorted(by: r19LexicalLess) {
        try r19Reset(statement)
        try r19BindText(statement, 1, key)
        try r19BindText(statement, 2, values[key]!)
        try r19SQLiteStepDone(statement)
    }
}

func r19InsertArtifacts(
    _ connection: R19SQLiteConnection, _ artifacts: [R19DatabaseArtifact]
) throws {
    let statement = try connection.prepare(
        "INSERT INTO input_artifacts(role,path,device,inode,uid,gid,mode,nlink,bytes,sha256) " +
        "VALUES(?,?,?,?,?,?,?,?,?,?)")
    defer { sqlite3_finalize(statement) }
    for artifact in artifacts.sorted(by: { $0.role < $1.role }) {
        try r19Reset(statement)
        try r19BindText(statement, 1, artifact.role)
        try r19BindText(statement, 2, artifact.path)
        try r19BindInt(statement, 3, Int64(artifact.device))
        try r19BindInt(statement, 4, Int64(artifact.inode))
        try r19BindInt(statement, 5, Int64(artifact.uid))
        try r19BindInt(statement, 6, Int64(artifact.gid))
        try r19BindText(statement, 7, artifact.mode)
        try r19BindInt(statement, 8, Int64(artifact.nlink))
        try r19BindInt(statement, 9, Int64(artifact.bytes))
        try r19BindText(statement, 10, artifact.sha256)
        try r19SQLiteStepDone(statement)
    }
}

func r19InsertIntervals(
    _ connection: R19SQLiteConnection, _ projections: [R19IntervalProjection]
) throws {
    let statement = try connection.prepare(
        "INSERT INTO intervals(source_frame_ordinal,predecessor_frame_ordinal," +
        "source_frame_sha256,predecessor_frame_sha256,source_payload_sha256," +
        "predecessor_payload_sha256,target_label,sample_round,pid,unique_id_text," +
        "idversion_text,sid,pgid,rusage_uuid_hex,process_start_abstime_text," +
        "delta_user_ticks_text,delta_system_ticks_text,delta_cpu_ticks_text," +
        "elapsed_minimum_ns_text,elapsed_estimate_ns_text,elapsed_maximum_ns_text," +
        "delta_energy_nj_text,generation_join_status) VALUES(" +
        String(repeating: "?,", count: 22) + "?)")
    defer { sqlite3_finalize(statement) }
    for item in projections.sorted(by: { $0.current.ordinal < $1.current.ordinal }) {
        try r19Reset(statement)
        let after = item.after
        try r19BindInt(statement, 1, Int64(item.current.ordinal))
        try r19BindInt(statement, 2, Int64(item.predecessor.ordinal))
        try r19BindText(statement, 3, item.current.frameSHA256)
        try r19BindText(statement, 4, item.predecessor.frameSHA256)
        try r19BindText(statement, 5, item.current.payloadSHA256)
        try r19BindText(statement, 6, item.predecessor.payloadSHA256)
        try r19BindText(statement, 7, item.label)
        try r19BindInt(statement, 8, 1)
        try r19BindInt(statement, 9, Int64(after.pid))
        try r19BindText(statement, 10, String(after.uniqueID))
        try r19BindText(statement, 11, String(after.idVersion))
        try r19BindInt(statement, 12, Int64(after.sid))
        try r19BindInt(statement, 13, Int64(after.pgid))
        try r19BindText(statement, 14, after.rusageUUID)
        try r19BindText(statement, 15, String(after.startAbstime))
        try r19BindText(statement, 16, String(item.deltaUserTicks))
        try r19BindText(statement, 17, String(item.deltaSystemTicks))
        try r19BindText(statement, 18, String(item.deltaCPUTicks))
        try r19BindText(statement, 19, String(after.elapsedMinimumNS!))
        try r19BindText(statement, 20, String(after.elapsedEstimateNS!))
        try r19BindText(statement, 21, String(after.elapsedMaximumNS!))
        try r19BindText(statement, 22, String(item.energy.deltaNJ))
        try r19BindText(statement, 23,
                        "VALID_EXACT_GENERATION_SESSION_GROUP_UUID_AND_START_JOIN")
        try r19SQLiteStepDone(statement)
    }
}

func r19InsertAdjudications(
    _ connection: R19SQLiteConnection, _ projections: [R19IntervalProjection]
) throws {
    var rows: [R19Adjudication] = []
    for projection in projections { rows += try r19Adjudications(projection) }
    rows.sort {
        ($0.sourceFrameOrdinal, $0.surface, $0.fieldName) <
            ($1.sourceFrameOrdinal, $1.surface, $1.fieldName)
    }
    let statement = try connection.prepare(
        "INSERT INTO field_adjudications(source_frame_ordinal,field_surface,field_name," +
        "source_pointer,original_lexeme,verdict,reason,replacement_metric) " +
        "VALUES(?,?,?,?,?,?,?,?)")
    defer { sqlite3_finalize(statement) }
    for row in rows {
        try r19Reset(statement)
        try r19BindInt(statement, 1, Int64(row.sourceFrameOrdinal))
        try r19BindText(statement, 2, row.surface)
        try r19BindText(statement, 3, row.fieldName)
        try r19BindText(statement, 4, row.sourcePointer)
        try r19BindText(statement, 5, row.originalLexeme)
        try r19BindText(statement, 6, row.verdict)
        try r19BindText(statement, 7, row.reason)
        try r19BindText(statement, 8, row.replacementMetric)
        try r19SQLiteStepDone(statement)
    }
}

func r19InsertMetricFacts(
    _ connection: R19SQLiteConnection, _ projections: [R19IntervalProjection]
) throws {
    var rows: [R19MetricFact] = []
    for projection in projections { rows += try r19MetricFacts(projection) }
    rows.sort {
        ($0.sourceFrameOrdinal, $0.metricName, $0.boundKind) <
            ($1.sourceFrameOrdinal, $1.metricName, $1.boundKind)
    }
    let statement = try connection.prepare(
        "INSERT INTO metric_facts(source_frame_ordinal,metric_name,bound_kind," +
        "numerator_text,denominator_text,unit,status,source_pointer,approximation_text) " +
        "VALUES(?,?,?,?,?,?,?,?,?)")
    defer { sqlite3_finalize(statement) }
    for row in rows {
        try r19Reset(statement)
        try r19BindInt(statement, 1, Int64(row.sourceFrameOrdinal))
        try r19BindText(statement, 2, row.metricName)
        try r19BindText(statement, 3, row.boundKind)
        try r19BindText(statement, 4, String(row.rational.numerator))
        try r19BindText(statement, 5, String(row.rational.denominator))
        try r19BindText(statement, 6, row.rational.unit)
        try r19BindText(statement, 7, row.status)
        try r19BindText(statement, 8, row.sourcePointer)
        try r19BindText(statement, 9, row.approximation)
        try r19SQLiteStepDone(statement)
    }
}

func r19InsertOverlayFrames(
    _ connection: R19SQLiteConnection, _ frames: [R19OverlayFrame]
) throws {
    let statement = try connection.prepare(
        "INSERT INTO overlay_frames(ordinal,frame_kind,byte_offset,frame_bytes," +
        "frame_sha256,previous_frame_sha256,payload_sha256,raw_frame) VALUES(?,?,?,?,?,?,?,?)")
    defer { sqlite3_finalize(statement) }
    for frame in frames.sorted(by: { $0.ordinal < $1.ordinal }) {
        try r19Reset(statement)
        try r19BindInt(statement, 1, Int64(frame.ordinal))
        try r19BindText(statement, 2, frame.kind)
        try r19BindInt(statement, 3, Int64(frame.byteOffset))
        try r19BindInt(statement, 4, Int64(frame.rawWithLF.count))
        try r19BindText(statement, 5, frame.frameSHA256)
        try r19BindText(statement, 6, frame.previousFrameSHA256)
        try r19BindText(statement, 7, frame.payloadSHA256)
        try r19BindBlob(statement, 8, frame.rawWithLF)
        try r19SQLiteStepDone(statement)
    }
}

func r19InsertOverlaySeal(
    _ connection: R19SQLiteConnection, frames: [R19OverlayFrame]
) throws {
    let prefix = frames.flatMap(\.rawWithLF)
    let statement = try connection.prepare(
        "INSERT INTO overlay_seal(singleton,projection_id,authority_vector," +
        "journal_prefix_frame_count,journal_prefix_bytes,journal_prefix_sha256," +
        "journal_prefix_tail_frame_sha256,input_journal_sha256,input_database_sha256) " +
        "VALUES(1,?,?,?,?,?,?,?,?)")
    defer { sqlite3_finalize(statement) }
    try r19BindText(statement, 1, r19ProjectionID())
    try r19BindText(statement, 2, r19AuthorityVector)
    try r19BindInt(statement, 3, Int64(frames.count))
    try r19BindInt(statement, 4, Int64(prefix.count))
    try r19BindText(statement, 5, r19SHA256(prefix))
    try r19BindText(statement, 6, frames.last!.frameSHA256)
    try r19BindText(statement, 7, r19InputJournalSHA256)
    try r19BindText(statement, 8, r19InputDatabaseSHA256)
    try r19SQLiteStepDone(statement)
}

struct R19DatabaseSnapshot: Equatable {
    let tables: [String: [[String]]]
}

func r19DatabaseSnapshot(_ connection: R19SQLiteConnection) throws -> R19DatabaseSnapshot {
    let queries: [(String, String)] = [
        ("metadata", "SELECT * FROM metadata ORDER BY key"),
        ("input_artifacts", "SELECT * FROM input_artifacts ORDER BY role"),
        ("intervals", "SELECT * FROM intervals ORDER BY source_frame_ordinal"),
        ("field_adjudications", "SELECT * FROM field_adjudications ORDER BY source_frame_ordinal,field_surface,field_name"),
        ("metric_facts", "SELECT * FROM metric_facts ORDER BY source_frame_ordinal,metric_name,bound_kind"),
        ("overlay_frames", "SELECT * FROM overlay_frames ORDER BY ordinal"),
        ("overlay_seal", "SELECT * FROM overlay_seal ORDER BY singleton"),
    ]
    var tables: [String: [[String]]] = [:]
    for query in queries {
        let statement = try connection.prepare(query.1)
        defer { sqlite3_finalize(statement) }
        var rows: [[String]] = []
        while true {
            let result = sqlite3_step(statement)
            if result == SQLITE_DONE { break }
            if result != SQLITE_ROW { throw R19OverlayError.sqlite("sqlite snapshot row", result) }
            var row: [String] = []
            for column in 0..<sqlite3_column_count(statement) {
                switch sqlite3_column_type(statement, column) {
                case SQLITE_NULL: row.append("N")
                case SQLITE_INTEGER: row.append("I" + String(sqlite3_column_int64(statement, column)))
                case SQLITE_TEXT:
                    guard let pointer = sqlite3_column_text(statement, column) else {
                        throw R19OverlayError.contract("sqlite snapshot text")
                    }
                    row.append("T" + String(cString: pointer))
                case SQLITE_BLOB:
                    let count = Int(sqlite3_column_bytes(statement, column))
                    guard let pointer = sqlite3_column_blob(statement, column) else {
                        throw R19OverlayError.contract("sqlite snapshot blob")
                    }
                    let bytes = Array(UnsafeRawBufferPointer(start: pointer, count: count))
                    row.append("B" + String(count) + ":" + r19SHA256(bytes))
                default: throw R19OverlayError.contract("sqlite snapshot type")
                }
            }
            rows.append(row)
        }
        tables[query.0] = rows
    }
    return .init(tables: tables)
}

func r19ValidateOverlayDatabase(
    _ connection: R19SQLiteConnection, prefixFrames: [R19OverlayFrame]
) throws -> R19DatabaseSnapshot {
    try r19Require(try r19SQLiteScalarText(connection, "PRAGMA quick_check") == "ok",
                   "overlay quick check")
    try r19Require(try r19SQLiteScalarInt(connection,
        "SELECT count(*) FROM pragma_foreign_key_check") == 0, "overlay foreign key check")
    let counts: [(String, Int64)] = [
        ("metadata", 13), ("input_artifacts", 2), ("intervals", 3),
        ("field_adjudications", 24), ("metric_facts", 33),
        ("overlay_frames", 5), ("overlay_seal", 1),
    ]
    for count in counts {
        try r19Require(try r19SQLiteScalarInt(connection,
            "SELECT count(*) FROM " + count.0) == count.1, "overlay row count " + count.0)
    }
    let statement = try connection.prepare("SELECT ordinal,raw_frame FROM overlay_frames ORDER BY ordinal")
    defer { sqlite3_finalize(statement) }
    var reconstructed: [UInt8] = []
    var ordinal = 0
    while true {
        let result = sqlite3_step(statement)
        if result == SQLITE_DONE { break }
        if result != SQLITE_ROW {
            throw R19OverlayError.sqlite("overlay database frame scan", result)
        }
        try r19Require(Int(sqlite3_column_int64(statement, 0)) == ordinal,
                       "overlay database frame ordinal")
        let count = Int(sqlite3_column_bytes(statement, 1))
        guard let pointer = sqlite3_column_blob(statement, 1) else {
            throw R19OverlayError.contract("overlay database frame blob")
        }
        let raw = Array(UnsafeRawBufferPointer(start: pointer, count: count))
        try r19Require(raw == prefixFrames[ordinal].rawWithLF,
                       "overlay database frame bytes")
        reconstructed += raw
        ordinal += 1
    }
    try r19Require(ordinal == 5 && reconstructed == prefixFrames.flatMap(\.rawWithLF),
                   "overlay database prefix reconstruction")
    return try r19DatabaseSnapshot(connection)
}

struct R19OverlayDatabaseProduct {
    let bytes: [UInt8]
    let sha256: String
    let snapshot: R19DatabaseSnapshot
}

func r19BuildOverlayDatabase(
    prefixFrames: [R19OverlayFrame], projections: [R19IntervalProjection],
    journalArtifact: R19DatabaseArtifact, databaseArtifact: R19DatabaseArtifact,
    invokeFixedWrappers: Bool
) throws -> R19OverlayDatabaseProduct {
    try r19Require(prefixFrames.count == 5, "overlay prefix frame count")
    try r19Require(r19DatabaseSchemaBytes.count == 4_068, "overlay DDL byte count")
    try r19Require(r19SHA256(r19DatabaseSchemaBytes) ==
        "e5cb95990c66af7933ed213be5335ebe76a3c373ac216eadb3d048ee6c06f52b",
        "overlay DDL SHA256")
    let connection = try R19SQLiteConnection()
    for statement in r19DatabaseSchemaStatements { try connection.execute(statement) }
    try connection.execute("BEGIN IMMEDIATE")
    do {
        let prefix = prefixFrames.flatMap(\.rawWithLF)
        let metadata = [
            "authority_vector": r19AuthorityVector,
            "control_commit": r19ControlCommit,
            "control_frame_sha256": r19ControlFrameSHA256,
            "control_tree": r19ControlTree,
            "gate_e_outcome": "ABSTAIN",
            "input_session_id": r19InputSessionID,
            "journal_prefix_sha256": r19SHA256(prefix),
            "projection_id": r19ProjectionID(),
            "source_index_completeness": "ABSTAIN_NONEXHAUSTIVE_28_OF_37_PRESENTATION_SUBSET",
            "timebase_ns_denominator": "3",
            "timebase_ns_numerator": "125",
            "timebase_ticks_per_second": "24000000",
            "transform_schema": r19TransformSchema,
        ]
        try r19InsertMetadata(connection, metadata)
        try r19InsertArtifacts(connection, [databaseArtifact, journalArtifact])
        try r19InsertIntervals(connection, projections)
        try r19InsertAdjudications(connection, projections)
        try r19InsertMetricFacts(connection, projections)
        try r19InsertOverlayFrames(connection, prefixFrames)
        try r19InsertOverlaySeal(connection, frames: prefixFrames)
        try connection.execute("COMMIT")
    } catch {
        try? connection.execute("ROLLBACK")
        throw error
    }
    try r19ConfigureReadOnly(connection, invokeFixedWrapper: invokeFixedWrappers)
    let snapshot = try r19ValidateOverlayDatabase(connection, prefixFrames: prefixFrames)
    let bytes = try connection.serialize()
    try connection.close()
    let verification = try r19DeserializeReadOnly(bytes, invokeFixedWrapper: invokeFixedWrappers)
    let secondSnapshot = try r19ValidateOverlayDatabase(verification, prefixFrames: prefixFrames)
    try r19Require(secondSnapshot == snapshot, "overlay deserialized every-cell snapshot")
    let secondBytes = try verification.serialize()
    try r19Require(secondBytes == bytes, "overlay deserialized serialization identity")
    try verification.close()
    return .init(bytes: bytes, sha256: r19SHA256(bytes), snapshot: snapshot)
}

#if !R19_CPU_OVERLAY_TESTING
@_silgen_name("prime_r19_overlay_full_sync_file")
func prime_r19_overlay_full_sync_file(_ descriptor: Int32) -> Int32

@_silgen_name("prime_r19_overlay_open_directory_no_follow_any")
func prime_r19_overlay_open_directory_no_follow_any(_ path: UnsafePointer<CChar>) -> Int32

@_silgen_name("prime_r19_overlay_openat_directory_no_follow")
func prime_r19_overlay_openat_directory_no_follow(
    _ directoryDescriptor: Int32, _ leaf: UnsafePointer<CChar>) -> Int32

@_silgen_name("prime_r19_overlay_openat_readonly_no_follow")
func prime_r19_overlay_openat_readonly_no_follow(
    _ directoryDescriptor: Int32, _ leaf: UnsafePointer<CChar>) -> Int32

@_silgen_name("prime_r19_overlay_mkdirat_private")
func prime_r19_overlay_mkdirat_private(
    _ directoryDescriptor: Int32, _ leaf: UnsafePointer<CChar>) -> Int32

@_silgen_name("prime_r19_overlay_openat_create_exclusive_private")
func prime_r19_overlay_openat_create_exclusive_private(
    _ directoryDescriptor: Int32, _ leaf: UnsafePointer<CChar>) -> Int32

@_silgen_name("prime_r19_overlay_sqlite_harden_connection")
func prime_r19_overlay_sqlite_harden_connection(_ database: OpaquePointer) -> Int32

let r19WorkspacePath =
    "/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45"
let r19InputRootLeaf = "r19-observability-eaf9b76-v1"
let r19OutputRootLeaf = "r19-observability-eaf9b76-cpu-overlay-v1"

func r19OpenDirectory(_ path: String) throws -> Int32 {
    let descriptor = path.withCString { prime_r19_overlay_open_directory_no_follow_any($0) }
    if descriptor < 0 { throw R19OverlayError.posix("open fixed directory", errno) }
    return descriptor
}

func r19OpenatDirectory(_ parent: Int32, _ leaf: String) throws -> Int32 {
    let descriptor = leaf.withCString { prime_r19_overlay_openat_directory_no_follow(parent, $0) }
    if descriptor < 0 { throw R19OverlayError.posix("openat fixed directory", errno) }
    return descriptor
}

func r19OpenatReadOnly(_ root: Int32, _ leaf: String) throws -> Int32 {
    let descriptor = leaf.withCString { prime_r19_overlay_openat_readonly_no_follow(root, $0) }
    if descriptor < 0 { throw R19OverlayError.posix("openat fixed input", errno) }
    return descriptor
}

func r19CreateExclusive(_ root: Int32, _ leaf: String) throws -> Int32 {
    let descriptor = leaf.withCString {
        prime_r19_overlay_openat_create_exclusive_private(root, $0)
    }
    if descriptor < 0 { throw R19OverlayError.posix("openat exclusive output", errno) }
    return descriptor
}

func r19FileStat(_ descriptor: Int32, _ operation: String) throws -> stat {
    var value = stat()
    if fstat(descriptor, &value) != 0 { throw R19OverlayError.posix(operation, errno) }
    return value
}

func r19NamedStat(_ directory: Int32, _ leaf: String, _ operation: String) throws -> stat {
    var value = stat()
    let result = leaf.withCString { fstatat(directory, $0, &value, AT_SYMLINK_NOFOLLOW) }
    if result != 0 { throw R19OverlayError.posix(operation, errno) }
    return value
}

func r19Device(_ value: stat) -> UInt64 { UInt64(value.st_dev) }
func r19Inode(_ value: stat) -> UInt64 { UInt64(value.st_ino) }
func r19Mode(_ value: stat) -> mode_t { value.st_mode & mode_t(0o7777) }

func r19RequireJoined(_ held: stat, _ named: stat, _ operation: String) throws {
    try r19Require(held.st_dev == named.st_dev && held.st_ino == named.st_ino &&
                   held.st_mode == named.st_mode && held.st_uid == named.st_uid &&
                   held.st_gid == named.st_gid && held.st_nlink == named.st_nlink &&
                   held.st_size == named.st_size, operation)
}

func r19ReadExact(_ descriptor: Int32, _ count: Int) throws -> [UInt8] {
    var bytes = [UInt8](repeating: 0, count: count)
    var offset = 0
    var enteredEINTRResults = 0
    try bytes.withUnsafeMutableBytes { raw in
        while offset < count {
            let result = pread(descriptor, raw.baseAddress!.advanced(by: offset),
                               count - offset, off_t(offset))
            if result > 0 { offset += result }
            else if result < 0 && errno == EINTR {
                try r19RegisterEINTR(&enteredEINTRResults)
                continue
            }
            else if result == 0 { throw R19OverlayError.contract("held input early EOF") }
            else { throw R19OverlayError.posix("pread held bytes", errno) }
        }
    }
    return bytes
}

func r19WriteAll(_ descriptor: Int32, _ bytes: [UInt8]) throws {
    var offset = 0
    var enteredEINTRResults = 0
    try bytes.withUnsafeBytes { raw in
        while offset < raw.count {
            let result = write(descriptor, raw.baseAddress!.advanced(by: offset), raw.count - offset)
            if result > 0 { offset += result }
            else if result < 0 && errno == EINTR {
                try r19RegisterEINTR(&enteredEINTRResults)
                continue
            }
            else { throw R19OverlayError.posix("write held output", errno) }
        }
    }
}

func r19SyncFile(_ descriptor: Int32) throws {
    if prime_r19_overlay_full_sync_file(descriptor) != 0 {
        throw R19OverlayError.posix("fixed full file sync", errno)
    }
}

func r19SyncDirectory(_ descriptor: Int32) throws {
    if fsync(descriptor) != 0 { throw R19OverlayError.posix("directory fsync", errno) }
}

func r19Inventory(_ root: Int32) throws -> [String] {
    let copy = dup(root)
    if copy < 0 { throw R19OverlayError.posix("dup directory", errno) }
    guard let directory = fdopendir(copy) else {
        let code = errno
        close(copy)
        throw R19OverlayError.posix("fdopendir", code)
    }
    defer { closedir(directory) }
    rewinddir(directory)
    var values: [String] = []
    var budget = R19InventoryBudget()
    while true {
        errno = 0
        guard let entry = readdir(directory) else {
            if errno != 0 { throw R19OverlayError.posix("readdir", errno) }
            break
        }
        try budget.registerPositiveResult()
        var name = entry.pointee.d_name
        let value = withUnsafeBytes(of: &name) { raw in
            String(decoding: raw.prefix { $0 != 0 }, as: UTF8.self)
        }
        if value != "." && value != ".." {
            try budget.registerNonDotEntry()
            values.append(value)
        }
    }
    return values.sorted(by: r19LexicalLess)
}

final class R19HeldInputs {
    let parent: Int32
    let parentIdentity: stat
    let root: Int32
    let journal: Int32
    let database: Int32
    let journalBytes: [UInt8]
    let databaseBytes: [UInt8]
    let rootArtifact: R19RootArtifact
    let journalArtifact: R19DatabaseArtifact
    let databaseArtifact: R19DatabaseArtifact

    init() throws {
        let parentValue = try r19OpenDirectory(r19WorkspacePath)
        var rootValue: Int32 = -1
        var journalValue: Int32 = -1
        var databaseValue: Int32 = -1
        do {
            let parentState = try r19FileStat(parentValue, "fstat input parent")
            var namedParent = stat()
            let parentResult = r19WorkspacePath.withCString { lstat($0, &namedParent) }
            if parentResult != 0 { throw R19OverlayError.posix("lstat input parent", errno) }
            try r19RequireJoined(parentState, namedParent, "input parent initial join")
            rootValue = try r19OpenatDirectory(parentValue, r19InputRootLeaf)
            let heldRoot = try r19FileStat(rootValue, "fstat input root")
            let namedRoot = try r19NamedStat(parentValue, r19InputRootLeaf, "fstatat input root")
            try r19RequireJoined(heldRoot, namedRoot, "input root join")
            try r19Require(r19Device(heldRoot) == 16_777_231 &&
                           r19Inode(heldRoot) == 17_509_052 &&
                           r19Mode(heldRoot) == 0o500 && heldRoot.st_uid == r19ExpectedUID &&
                           heldRoot.st_gid == r19ExpectedGID && heldRoot.st_nlink == 4 &&
                           (heldRoot.st_mode & S_IFMT) == S_IFDIR,
                           "input root metadata")
            let inventory = try r19Inventory(rootValue)
            try r19Require(inventory == [r19InputJournalLeaf, r19InputDatabaseLeaf].sorted(by: r19LexicalLess),
                           "input root inventory")
            journalValue = try r19OpenatReadOnly(rootValue, r19InputJournalLeaf)
            let journalState = try r19FileStat(journalValue, "fstat input journal")
            try R19HeldInputs.requireInputFile(
                journalState, device: 16_777_231, inode: 17_509_053,
                bytes: r19InputJournalBytes, operation: "input journal metadata")
            let journalNamed = try r19NamedStat(rootValue, r19InputJournalLeaf,
                                                "fstatat input journal")
            try r19RequireJoined(journalState, journalNamed, "input journal join")
            databaseValue = try r19OpenatReadOnly(rootValue, r19InputDatabaseLeaf)
            let databaseState = try r19FileStat(databaseValue, "fstat input database")
            try R19HeldInputs.requireInputFile(
                databaseState, device: 16_777_231, inode: 17_509_057,
                bytes: r19InputDatabaseBytes, operation: "input database metadata")
            let databaseNamed = try r19NamedStat(rootValue, r19InputDatabaseLeaf,
                                                 "fstatat input database")
            try r19RequireJoined(databaseState, databaseNamed, "input database join")
            let readJournal = try r19ReadExact(journalValue, r19InputJournalBytes)
            let readDatabase = try r19ReadExact(databaseValue, r19InputDatabaseBytes)
            try r19Require(r19SHA256(readJournal) == r19InputJournalSHA256,
                           "input held journal hash")
            try r19Require(r19SHA256(readDatabase) == r19InputDatabaseSHA256,
                           "input held database hash")
            let admittedRoot = R19RootArtifact(
                path: r19InputRootPath, device: r19Device(heldRoot), inode: r19Inode(heldRoot),
                uid: UInt64(heldRoot.st_uid), gid: UInt64(heldRoot.st_gid), mode: "0500",
                nlink: UInt64(heldRoot.st_nlink), inventory: inventory)
            let admittedJournal = R19HeldInputs.artifact(
                role: "journal", path: r19InputRootPath + "/" + r19InputJournalLeaf,
                state: journalState, bytes: r19InputJournalBytes, sha: r19InputJournalSHA256)
            let admittedDatabase = R19HeldInputs.artifact(
                role: "database", path: r19InputRootPath + "/" + r19InputDatabaseLeaf,
                state: databaseState, bytes: r19InputDatabaseBytes, sha: r19InputDatabaseSHA256)
            parent = parentValue
            parentIdentity = parentState
            root = rootValue
            journal = journalValue
            database = databaseValue
            journalBytes = readJournal
            databaseBytes = readDatabase
            rootArtifact = admittedRoot
            journalArtifact = admittedJournal
            databaseArtifact = admittedDatabase
        } catch {
            if databaseValue >= 0 { close(databaseValue) }
            if journalValue >= 0 { close(journalValue) }
            if rootValue >= 0 { close(rootValue) }
            close(parentValue)
            throw error
        }
    }

    deinit { close(database); close(journal); close(root); close(parent) }

    static func requireInputFile(
        _ value: stat, device: UInt64, inode: UInt64, bytes: Int, operation: String
    ) throws {
        try r19Require((value.st_mode & S_IFMT) == S_IFREG,
                       operation + " regular-file type")
        try r19Require(r19Device(value) == device && r19Inode(value) == inode &&
                       r19Mode(value) == 0o400 && value.st_uid == r19ExpectedUID &&
                       value.st_gid == r19ExpectedGID && value.st_nlink == 1 &&
                       value.st_size == off_t(bytes),
                       operation)
    }

    static func artifact(
        role: String, path: String, state: stat, bytes: Int, sha: String
    ) -> R19DatabaseArtifact {
        .init(role: role, path: path, device: r19Device(state), inode: r19Inode(state),
              uid: UInt64(state.st_uid), gid: UInt64(state.st_gid),
              mode: "0400", nlink: UInt64(state.st_nlink), bytes: bytes, sha256: sha)
    }

    func revalidate() throws {
        let heldParent = try r19FileStat(parent, "post fstat input parent")
        var namedParent = stat()
        let parentResult = r19WorkspacePath.withCString { lstat($0, &namedParent) }
        if parentResult != 0 { throw R19OverlayError.posix("post lstat input parent", errno) }
        try r19Require(heldParent.st_dev == parentIdentity.st_dev &&
                       heldParent.st_ino == parentIdentity.st_ino,
                       "post input parent identity")
        try r19RequireJoined(heldParent, namedParent, "post input parent named join")
        let heldRoot = try r19FileStat(root, "post fstat input root")
        let namedRoot = try r19NamedStat(parent, r19InputRootLeaf, "post fstatat input root")
        try r19RequireJoined(heldRoot, namedRoot, "post input root join")
        try r19Require(r19Device(heldRoot) == 16_777_231 &&
                       r19Inode(heldRoot) == 17_509_052 &&
                       r19Mode(heldRoot) == 0o500 && heldRoot.st_uid == r19ExpectedUID &&
                       heldRoot.st_gid == r19ExpectedGID && heldRoot.st_nlink == 4 &&
                       (heldRoot.st_mode & S_IFMT) == S_IFDIR,
                       "post input root metadata")
        let journalState = try r19FileStat(journal, "post fstat input journal")
        let databaseState = try r19FileStat(database, "post fstat input database")
        try r19RequireJoined(journalState,
            try r19NamedStat(root, r19InputJournalLeaf, "post fstatat input journal"),
            "post input journal join")
        try r19RequireJoined(databaseState,
            try r19NamedStat(root, r19InputDatabaseLeaf, "post fstatat input database"),
            "post input database join")
        try R19HeldInputs.requireInputFile(journalState, device: 16_777_231,
                                           inode: 17_509_053, bytes: r19InputJournalBytes,
                                           operation: "post input journal metadata")
        try R19HeldInputs.requireInputFile(databaseState, device: 16_777_231,
                                           inode: 17_509_057, bytes: r19InputDatabaseBytes,
                                           operation: "post input database metadata")
        let postJournal = try r19ReadExact(journal, r19InputJournalBytes)
        let postDatabase = try r19ReadExact(database, r19InputDatabaseBytes)
        try r19Require(postJournal == journalBytes && postDatabase == databaseBytes &&
                       r19SHA256(postJournal) == r19InputJournalSHA256 &&
                       r19SHA256(postDatabase) == r19InputDatabaseSHA256,
                       "post input held byte and hash identity")
        try r19Require(try r19Inventory(root) == rootArtifact.inventory,
                       "post input inventory")
    }
}

final class R19OutputRoot {
    let parent: Int32
    let root: Int32
    let journal: Int32
    var database: Int32 = -1
    let parentIdentity: stat
    let rootIdentity: stat
    var frames: [R19OverlayFrame] = []
    var journalBytes: [UInt8] = []
    var successSealAppended = false
    var journalWritable = true

    init() throws {
        let parentValue = try r19OpenDirectory(r19WorkspacePath)
        var rootValue: Int32 = -1
        var journalValue: Int32 = -1
        do {
            let parentState = try r19FileStat(parentValue, "fstat output parent")
            var existing = stat()
            errno = 0
            let prior = r19OutputRootLeaf.withCString {
                fstatat(parentValue, $0, &existing, AT_SYMLINK_NOFOLLOW)
            }
            let absenceErrno = errno
            if prior == 0 {
                throw R19OverlayError.contract("output root not absent")
            }
            if absenceErrno != ENOENT {
                throw R19OverlayError.posix("output root absence fstatat", absenceErrno)
            }
            let made = r19OutputRootLeaf.withCString {
                prime_r19_overlay_mkdirat_private(parentValue, $0)
            }
            if made != 0 {
                throw R19OverlayError.posix("exclusive output mkdirat", errno)
            }
            try r19SyncDirectory(parentValue)
            rootValue = try r19OpenatDirectory(parentValue, r19OutputRootLeaf)
            let heldRoot = try r19FileStat(rootValue, "fstat output root")
            let namedRoot = try r19NamedStat(
                parentValue, r19OutputRootLeaf, "fstatat output root")
            try r19RequireJoined(heldRoot, namedRoot, "output root initial join")
            try r19Require((heldRoot.st_mode & S_IFMT) == S_IFDIR &&
                           r19Mode(heldRoot) == 0o700 && heldRoot.st_uid == r19ExpectedUID &&
                           heldRoot.st_gid == r19ExpectedGID && heldRoot.st_nlink == 2,
                           "output root initial metadata")
            journalValue = try r19CreateExclusive(rootValue, r19OutputJournalLeaf)
            let journalState = try r19FileStat(journalValue, "fstat output journal")
            try r19Require((journalState.st_mode & S_IFMT) == S_IFREG &&
                           r19Mode(journalState) == 0o600 &&
                           journalState.st_uid == r19ExpectedUID &&
                           journalState.st_gid == r19ExpectedGID && journalState.st_nlink == 1 &&
                           journalState.st_size == 0,
                           "output journal initial metadata")
            try r19SyncDirectory(rootValue)
            parent = parentValue
            parentIdentity = parentState
            root = rootValue
            journal = journalValue
            rootIdentity = heldRoot
        } catch {
            if journalValue >= 0 { close(journalValue) }
            if rootValue >= 0 { close(rootValue) }
            close(parentValue)
            throw error
        }
    }

    deinit {
        if database >= 0 { close(database) }
        close(journal); close(root); close(parent)
    }

    func append(kind: String, payload: R19JSONValue) throws -> R19OverlayFrame {
        try r19Require(journalWritable && !successSealAppended, "journal append state")
        if kind == "seal" { successSealAppended = true }
        let frame = r19MakeFrame(
            ordinal: frames.count, kind: kind, payload: payload,
            previous: frames.last?.frameSHA256, byteOffset: journalBytes.count)
        try r19Require(journalBytes.count + frame.rawWithLF.count <= 262_144,
                       "overlay journal byte cap")
        let currentOffset = lseek(journal, 0, SEEK_CUR)
        if currentOffset < 0 { throw R19OverlayError.posix("output journal lseek", errno) }
        try r19Require(currentOffset == off_t(journalBytes.count), "output journal offset")
        try r19WriteAll(journal, frame.rawWithLF)
        let readback = try r19ReadExactRange(
            journal, count: frame.rawWithLF.count, offset: frame.byteOffset)
        try r19Require(readback == frame.rawWithLF, "output frame readback")
        try r19SyncFile(journal)
        journalBytes += frame.rawWithLF
        frames.append(frame)
        return frame
    }

    func createDatabase() throws -> Int32 {
        try r19Require(database < 0 && frames.count == 5, "database creation order")
        database = try r19CreateExclusive(root, r19OutputDatabaseLeaf)
        let state = try r19FileStat(database, "fstat new output database")
        try r19Require((state.st_mode & S_IFMT) == S_IFREG && r19Mode(state) == 0o600 &&
                       state.st_uid == r19ExpectedUID && state.st_gid == r19ExpectedGID &&
                       state.st_nlink == 1 && state.st_size == 0,
                       "new output database metadata")
        try r19SyncDirectory(root)
        return database
    }

    func appendFailure(_ error: Error) {
        guard journalWritable && !successSealAppended && frames.count < 8 else { return }
        let classification: String
        let operation: String
        switch error {
        case R19OverlayError.contract(let value):
            classification = "CONTRACT_FAILURE"
            operation = value
        case R19OverlayError.posix(let value, let code):
            classification = "POSIX_FAILURE_" + String(code)
            operation = value
        case R19OverlayError.sqlite(let value, let code):
            classification = "SQLITE_FAILURE_" + String(code)
            operation = value
        default:
            classification = "INTERNAL_FAILURE"
            operation = "unknown"
        }
        let payload = R19JSONValue.object([
            "authority_vector": .string(r19AuthorityVector),
            "failure_class": .string(classification), "operation": .string(operation),
            "schema": .string("prime_driver_v2_r19_observability_cpu_overlay_failure_v1"),
            "status": .string("FAIL_RETAINED_PREFIX_NO_RETRY"),
        ])
        _ = try? append(kind: "failure", payload: payload)
    }

    func revalidateRoot(mode: mode_t, expectedNlink: nlink_t) throws {
        let heldParent = try r19FileStat(parent, "fstat held output parent")
        try r19Require(heldParent.st_dev == parentIdentity.st_dev &&
                       heldParent.st_ino == parentIdentity.st_ino,
                       "output parent identity")
        var namedParent = stat()
        let result = r19WorkspacePath.withCString { lstat($0, &namedParent) }
        if result != 0 { throw R19OverlayError.posix("lstat output parent", errno) }
        try r19RequireJoined(heldParent, namedParent, "output parent named join")
        let heldRoot = try r19FileStat(root, "fstat held output root")
        let namedRoot = try r19NamedStat(parent, r19OutputRootLeaf, "fstatat output root")
        try r19RequireJoined(heldRoot, namedRoot, "output root named join")
        try r19Require(heldRoot.st_dev == rootIdentity.st_dev &&
                       heldRoot.st_ino == rootIdentity.st_ino && r19Mode(heldRoot) == mode &&
                       heldRoot.st_uid == r19ExpectedUID && heldRoot.st_gid == r19ExpectedGID &&
                       heldRoot.st_nlink == expectedNlink,
                       "output root metadata")
    }

    func revalidateLeaf(
        descriptor: Int32, leaf: String, mode: mode_t, bytes: Int
    ) throws -> [UInt8] {
        let held = try r19FileStat(descriptor, "fstat output leaf")
        let named = try r19NamedStat(root, leaf, "fstatat output leaf")
        try r19RequireJoined(held, named, "output leaf named join")
        try r19Require((held.st_mode & S_IFMT) == S_IFREG && r19Mode(held) == mode &&
                       held.st_uid == r19ExpectedUID && held.st_gid == r19ExpectedGID &&
                       held.st_nlink == 1 && held.st_size == off_t(bytes),
                       "output leaf metadata")
        return try r19ReadExact(descriptor, bytes)
    }

    func seal(databaseBytes expectedDatabase: [UInt8]) throws {
        try r19Require(successSealAppended && frames.count == 7 && frames.last?.kind == "seal",
                       "output success frame sequence")
        if fchmod(journal, 0o400) != 0 { throw R19OverlayError.posix("chmod journal", errno) }
        journalWritable = false
        try r19SyncFile(journal)
        try revalidateRoot(mode: 0o700, expectedNlink: 4)
        let databaseRead = try revalidateLeaf(
            descriptor: database, leaf: r19OutputDatabaseLeaf, mode: 0o400,
            bytes: expectedDatabase.count)
        let journalRead = try revalidateLeaf(
            descriptor: journal, leaf: r19OutputJournalLeaf, mode: 0o400,
            bytes: journalBytes.count)
        let expectedDatabaseSHA256 = r19SHA256(expectedDatabase)
        let expectedJournalSHA256 = r19SHA256(journalBytes)
        try r19Require(databaseRead == expectedDatabase && journalRead == journalBytes &&
                       r19SHA256(databaseRead) == expectedDatabaseSHA256 &&
                       r19SHA256(journalRead) == expectedJournalSHA256,
                       "output sealed leaf bytes and hashes")
        try r19Require(try r19Inventory(root) ==
            [r19OutputJournalLeaf, r19OutputDatabaseLeaf].sorted(by: r19LexicalLess),
            "output exact inventory")
        if fchmod(root, 0o500) != 0 { throw R19OverlayError.posix("chmod output root", errno) }
        try r19SyncDirectory(root)
        try r19SyncDirectory(parent)
        try revalidateRoot(mode: 0o500, expectedNlink: 4)
        let finalDatabase = try revalidateLeaf(
            descriptor: database, leaf: r19OutputDatabaseLeaf, mode: 0o400,
            bytes: expectedDatabase.count)
        let finalJournal = try revalidateLeaf(
            descriptor: journal, leaf: r19OutputJournalLeaf, mode: 0o400,
            bytes: journalBytes.count)
        try r19Require(finalDatabase == expectedDatabase &&
                       r19SHA256(finalDatabase) == expectedDatabaseSHA256,
                       "final database admission and hash")
        try r19Require(finalJournal == journalBytes &&
                       r19SHA256(finalJournal) == expectedJournalSHA256,
                       "final journal admission and hash")
        try r19Require(try r19Inventory(root) ==
            [r19OutputJournalLeaf, r19OutputDatabaseLeaf].sorted(by: r19LexicalLess),
            "final output inventory")
    }
}

func r19ReadExactRange(_ descriptor: Int32, count: Int, offset: Int) throws -> [UInt8] {
    var bytes = [UInt8](repeating: 0, count: count)
    var completed = 0
    var enteredEINTRResults = 0
    try bytes.withUnsafeMutableBytes { raw in
        while completed < count {
            let result = pread(descriptor, raw.baseAddress!.advanced(by: completed),
                               count - completed, off_t(offset + completed))
            if result > 0 { completed += result }
            else if result < 0 && errno == EINTR {
                try r19RegisterEINTR(&enteredEINTRResults)
                continue
            }
            else if result == 0 { throw R19OverlayError.contract("output readback EOF") }
            else { throw R19OverlayError.posix("pread output range", errno) }
        }
    }
    return bytes
}

func r19DatabaseFramePayload(
    product: R19OverlayDatabaseProduct, prefixFrames: [R19OverlayFrame]
) -> R19JSONValue {
    let prefix = prefixFrames.flatMap(\.rawWithLF)
    return .object([
        "database_bytes": .number(String(product.bytes.count)),
        "database_sha256": .string(product.sha256),
        "journal_prefix_bytes": .number(String(prefix.count)),
        "journal_prefix_frame_count": .number(String(prefixFrames.count)),
        "journal_prefix_sha256": .string(r19SHA256(prefix)),
        "schema": .string("prime_driver_v2_r19_observability_cpu_overlay_database_v1"),
        "status": .string("PASS_DATABASE_SERIALIZED_DURABLE_HASHED"),
    ])
}

func r19SealPayload(
    product: R19OverlayDatabaseProduct, presealFrames: [R19OverlayFrame]
) -> R19JSONValue {
    let preseal = presealFrames.flatMap(\.rawWithLF)
    return .object([
        "authority_vector": .string(r19AuthorityVector),
        "database_bytes": .number(String(product.bytes.count)),
        "database_sha256": .string(product.sha256),
        "preseal_journal_bytes": .number(String(preseal.count)),
        "preseal_journal_frame_count": .number(String(presealFrames.count)),
        "preseal_journal_sha256": .string(r19SHA256(preseal)),
        "preseal_tail_frame_sha256": .string(presealFrames.last!.frameSHA256),
        "projection_id": .string(r19ProjectionID()),
        "schema": .string("prime_driver_v2_r19_observability_cpu_overlay_seal_v1"),
        "status": .string("PASS_SEALED_OFFLINE_CPU_OVERLAY_AUTHORITY_ABSTAIN_GATE_E_ABSTAIN"),
    ])
}

func r19RunOverlay() throws {
    let inputs = try R19HeldInputs()
    let parsedFrames = try r19ParseJournal(inputs.journalBytes)
    let inputDatabase = try r19ValidateInputDatabase(
        bytes: inputs.databaseBytes, frames: parsedFrames, invokeFixedWrapper: true)
    let projections = try r19BuildIntervalProjections(parsedFrames)
    try inputDatabase.connection.close()
    var output: R19OutputRoot?
    do {
        let root = try R19OutputRoot()
        output = root
        let start = try root.append(kind: "start", payload: r19StartPayload())
        let admission = try root.append(
            kind: "input_admission",
            payload: r19InputAdmissionPayload(
                root: inputs.rootArtifact, journal: inputs.journalArtifact,
                database: inputs.databaseArtifact))
        try r19Require(start.ordinal == 0 && admission.ordinal == 1,
                       "overlay initial frame order")
        for projection in projections {
            _ = try root.append(kind: "interval_overlay",
                                payload: r19IntervalPayload(projection))
        }
        try r19Require(root.frames.count == 5, "overlay prefix count")
        let product = try r19BuildOverlayDatabase(
            prefixFrames: root.frames, projections: projections,
            journalArtifact: inputs.journalArtifact,
            databaseArtifact: inputs.databaseArtifact, invokeFixedWrappers: true)
        let databaseDescriptor = try root.createDatabase()
        try r19WriteAll(databaseDescriptor, product.bytes)
        try r19SyncFile(databaseDescriptor)
        let databaseReadback = try r19ReadExact(databaseDescriptor, product.bytes.count)
        try r19Require(databaseReadback == product.bytes &&
                       r19SHA256(databaseReadback) == product.sha256,
                       "output database first readback")
        if fchmod(databaseDescriptor, 0o400) != 0 {
            throw R19OverlayError.posix("chmod output database", errno)
        }
        try r19SyncFile(databaseDescriptor)
        let prefixFrames = root.frames
        _ = try root.append(
            kind: "database_serialized_and_hashed",
            payload: r19DatabaseFramePayload(product: product, prefixFrames: prefixFrames))
        try inputs.revalidate()
        let presealFrames = root.frames
        _ = try root.append(kind: "seal",
                            payload: r19SealPayload(product: product,
                                                    presealFrames: presealFrames))
        try root.seal(databaseBytes: product.bytes)
    } catch {
        output?.appendFailure(error)
        throw error
    }
}

@main
struct PrimeDriverV2R19ObservabilityCPUOverlay {
    static func main() {
        if let code = r19ArgumentPreflight(CommandLine.arguments.count) { _exit(code) }
        _ = umask(0o077)
        do {
            try r19RunOverlay()
            _exit(0)
        } catch R19OverlayError.contract(_) {
            _exit(65)
        } catch {
            _exit(70)
        }
    }
}
#endif





struct R19InputDatabaseValidation {
    let connection: R19SQLiteConnection
    let sourceRecordCount: Int64
    let sourceLexicalReferenceCount: Int64
}

struct R19InputDatabaseExpectations {
    let bytes: Int
    let sha256: String
    let journalSHA256: String
    let frameCount: Int64
    let sampleCount: Int64
    let sourceRecordCount: Int64
    let lexicalReferenceCount: Int64

    static let frozen = R19InputDatabaseExpectations(
        bytes: r19InputDatabaseBytes, sha256: r19InputDatabaseSHA256,
        journalSHA256: r19InputJournalSHA256, frameCount: 8, sampleCount: 6,
        sourceRecordCount: 28, lexicalReferenceCount: 211)
}

func r19SQLiteOptionalText(_ statement: OpaquePointer, _ column: Int32) -> String? {
    if sqlite3_column_type(statement, column) == SQLITE_NULL { return nil }
    guard let pointer = sqlite3_column_text(statement, column) else { return nil }
    return String(cString: pointer)
}

func r19ExpectedNormalizedValues(_ frame: R19ParsedFrame) throws -> [String?] {
    let observation = try r19ExtractObservation(frame)
    let payload = try frame.payload.object("normalized payload")
    let interval = try r19Member(payload, "interval", "normalized interval").object("normalized interval")
    func stringOrNumber(_ key: String) throws -> String? {
        let value = try r19Member(interval, key, "normalized field " + key)
        if case .null = value { return nil }
        if case .string(let text) = value { return text }
        if case .number(let text) = value { return text }
        throw R19OverlayError.contract("normalized field type " + key)
    }
    return [
        String(observation.round), observation.label, String(observation.pid),
        observation.availability, String(observation.uniqueID), String(observation.idVersion),
        String(observation.sid), String(observation.pgid), String(observation.status),
        String(observation.energyNJ),
        try r19Member(interval, "valid", "normalized valid") == .bool(true) ? "1" : "0",
        try r19Member(interval, "reason", "normalized reason").string("normalized reason"),
        try r19Member(interval, "energy_interpretation_valid", "normalized energy valid") == .bool(true) ? "1" : "0",
        try r19Member(interval, "energy_interpretation", "normalized energy interpretation").string("normalized energy interpretation"),
        try stringOrNumber("elapsed_estimate_ns"), try stringOrNumber("elapsed_minimum_ns"),
        try stringOrNumber("elapsed_maximum_ns"), try stringOrNumber("delta_cpu_ns"),
        try stringOrNumber("delta_energy_nj"), try stringOrNumber("delta_joules"),
        try stringOrNumber("delta_ergs"),
        try stringOrNumber("average_power_at_estimated_interval_w_approx"),
        try stringOrNumber("average_power_at_maximum_interval_w_approx"),
        try stringOrNumber("average_power_at_minimum_interval_w_approx"),
        try stringOrNumber("cpu_percent_at_estimated_interval_approx"),
        try stringOrNumber("cpu_percent_at_maximum_interval_approx"),
        try stringOrNumber("cpu_percent_at_minimum_interval_approx"),
    ]
}

func r19ValidateInputDatabase(
    bytes: [UInt8], frames: [R19ParsedFrame], invokeFixedWrapper: Bool,
    expectations: R19InputDatabaseExpectations = .frozen
) throws -> R19InputDatabaseValidation {
    try r19Require(bytes.count == expectations.bytes, "input database byte count")
    try r19Require(r19SHA256(bytes) == expectations.sha256, "input database SHA256")
    let connection = try r19DeserializeReadOnly(bytes, invokeFixedWrapper: invokeFixedWrapper)
    try r19Require(try r19SQLiteScalarText(connection, "PRAGMA quick_check") == "ok",
                   "input database quick check")
    try r19Require(try r19SQLiteScalarInt(connection,
        "SELECT count(*) FROM pragma_foreign_key_check") == 0,
        "input database foreign key check")
    try r19Require(try r19SQLiteScalarInt(connection, "SELECT count(*) FROM frames") == expectations.frameCount,
                   "input frame count")
    try r19Require(try r19SQLiteScalarInt(connection, "SELECT count(*) FROM process_samples") == expectations.sampleCount,
                   "input sample count")
    let recordCount = try r19SQLiteScalarInt(connection, "SELECT count(*) FROM source_records")
    let referenceCount = try r19SQLiteScalarInt(connection,
                                                 "SELECT count(*) FROM source_lexical_references")
    try r19Require(recordCount == expectations.sourceRecordCount &&
                   referenceCount == expectations.lexicalReferenceCount,
                   "input source subset residual counts")
    let frameStatement = try connection.prepare("SELECT ordinal,raw_frame FROM frames ORDER BY ordinal")
    defer { sqlite3_finalize(frameStatement) }
    var reconstructed: [UInt8] = []
    var ordinal = 0
    while true {
        let result = sqlite3_step(frameStatement)
        if result == SQLITE_DONE { break }
        if result != SQLITE_ROW {
            throw R19OverlayError.sqlite("input database frame scan", result)
        }
        try r19Require(Int(sqlite3_column_int64(frameStatement, 0)) == ordinal,
                       "input database frame ordinal")
        let count = Int(sqlite3_column_bytes(frameStatement, 1))
        guard let pointer = sqlite3_column_blob(frameStatement, 1) else {
            throw R19OverlayError.contract("input database frame blob")
        }
        let raw = Array(UnsafeRawBufferPointer(start: pointer, count: count))
        try r19Require(raw == frames[ordinal].rawWithLF, "input database frame bytes")
        reconstructed += raw
        ordinal += 1
    }
    try r19Require(ordinal == Int(expectations.frameCount) &&
                   r19SHA256(reconstructed) == expectations.journalSHA256,
                   "input database journal reconstruction")
    let sampleSQL =
        "SELECT ordinal,sample_round,target_label,pid,availability,unique_id_text," +
        "idversion_text,sid_text,pgid_text,process_status_text,energy_nj_text," +
        "interval_valid,interval_reason,energy_interpretation_valid,energy_interpretation," +
        "elapsed_estimate_ns_text,elapsed_minimum_ns_text,elapsed_maximum_ns_text," +
        "delta_cpu_ns_text,delta_energy_nj_text,delta_joules_text,delta_ergs_text," +
        "average_power_at_estimated_interval_w_approx_text," +
        "average_power_at_maximum_interval_w_approx_text," +
        "average_power_at_minimum_interval_w_approx_text," +
        "cpu_percent_at_estimated_interval_approx_text," +
        "cpu_percent_at_maximum_interval_approx_text," +
        "cpu_percent_at_minimum_interval_approx_text FROM process_samples ORDER BY ordinal"
    let sampleStatement = try connection.prepare(sampleSQL)
    defer { sqlite3_finalize(sampleStatement) }
    let sampleOrdinals = [1, 2, 3, 4, 5, 6]
    var row = 0
    while true {
        let result = sqlite3_step(sampleStatement)
        if result == SQLITE_DONE { break }
        if result != SQLITE_ROW {
            throw R19OverlayError.sqlite("input database sample scan", result)
        }
        try r19Require(row < sampleOrdinals.count, "input normalized extra row")
        let expectedOrdinal = sampleOrdinals[row]
        try r19Require(Int(sqlite3_column_int64(sampleStatement, 0)) == expectedOrdinal,
                       "input normalized ordinal")
        let expected = try r19ExpectedNormalizedValues(frames[expectedOrdinal])
        try r19Require(expected.count == 27, "input normalized arity")
        for index in expected.indices {
            try r19Require(r19SQLiteOptionalText(sampleStatement, Int32(index + 1)) == expected[index],
                           "input normalized cell")
        }
        row += 1
    }
    try r19Require(row == Int(expectations.sampleCount), "input normalized row count")
    let seal = try connection.prepare(
        "SELECT journal_bytes,journal_sha256,frame_count,seal_frame_sha256," +
        "source_record_count FROM capture_seal WHERE singleton=1")
    defer { sqlite3_finalize(seal) }
    let sealRowResult = sqlite3_step(seal)
    if sealRowResult == SQLITE_DONE {
        throw R19OverlayError.contract("input capture seal row missing")
    }
    if sealRowResult != SQLITE_ROW {
        throw R19OverlayError.sqlite("input capture seal row", sealRowResult)
    }
    try r19Require(sqlite3_column_int64(seal, 0) == Int64(reconstructed.count) &&
                   r19SQLiteOptionalText(seal, 1) == expectations.journalSHA256 &&
                   sqlite3_column_int64(seal, 2) == expectations.frameCount &&
                   r19SQLiteOptionalText(seal, 3) == frames[7].frameSHA256 &&
                   sqlite3_column_int64(seal, 4) == expectations.sourceRecordCount,
                   "input capture seal values")
    let sealTerminalResult = sqlite3_step(seal)
    if sealTerminalResult == SQLITE_ROW {
        throw R19OverlayError.contract("input capture seal cardinality")
    }
    if sealTerminalResult != SQLITE_DONE {
        throw R19OverlayError.sqlite("input capture seal terminal", sealTerminalResult)
    }
    return .init(connection: connection, sourceRecordCount: recordCount,
                 sourceLexicalReferenceCount: referenceCount)
}
