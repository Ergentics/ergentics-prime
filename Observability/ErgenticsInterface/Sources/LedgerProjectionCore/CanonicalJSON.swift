import CryptoKit
import Foundation

struct LedgerJSONSpan: Equatable, Sendable {
    let lowerBound: Int
    let upperBound: Int

    var count: Int { upperBound - lowerBound }
}

struct LedgerJSONObjectMember: Sendable {
    let key: String
    let value: LedgerJSONValue
}

indirect enum LedgerJSONValue: Sendable {
    case object([LedgerJSONObjectMember], LedgerJSONSpan)
    case array([LedgerJSONValue], LedgerJSONSpan)
    case string(String, LedgerJSONSpan)
    case number(String, LedgerJSONSpan)
    case bool(Bool, LedgerJSONSpan)
    case null(LedgerJSONSpan)

    var span: LedgerJSONSpan {
        switch self {
        case .object(_, let span), .array(_, let span), .string(_, let span),
             .number(_, let span), .bool(_, let span), .null(let span):
            return span
        }
    }

    var kind: String {
        switch self {
        case .object: "OBJECT"
        case .array: "ARRAY"
        case .string: "STRING"
        case .number: "NUMBER"
        case .bool: "BOOLEAN"
        case .null: "JSON_NULL"
        }
    }

    var childCount: Int {
        switch self {
        case .object(let members, _): members.count
        case .array(let values, _): values.count
        default: 0
        }
    }

    var decodedText: String? {
        switch self {
        case .string(let value, _), .number(let value, _): value
        case .bool(let value, _): value ? "true" : "false"
        case .object, .array, .null: nil
        }
    }

    func member(_ key: String) -> LedgerJSONValue? {
        guard case .object(let members, _) = self else { return nil }
        return members.first(where: { $0.key == key })?.value
    }

    func stringValue() -> String? {
        guard case .string(let value, _) = self else { return nil }
        return value
    }

    func numberValue() -> String? {
        guard case .number(let value, _) = self else { return nil }
        return value
    }

    func boolValue() -> Bool? {
        guard case .bool(let value, _) = self else { return nil }
        return value
    }

    func canonicalData() -> Data {
        var bytes: [UInt8] = []
        appendCanonical(to: &bytes)
        return Data(bytes)
    }

    private func appendCanonical(to bytes: inout [UInt8]) {
        switch self {
        case .object(let members, _):
            bytes.append(0x7b)
            let ordered = members.sorted { ledgerLexicalLess($0.key, $1.key) }
            for (index, member) in ordered.enumerated() {
                if index > 0 { bytes.append(0x2c) }
                LedgerJSONValue.appendString(member.key, to: &bytes)
                bytes.append(0x3a)
                member.value.appendCanonical(to: &bytes)
            }
            bytes.append(0x7d)
        case .array(let values, _):
            bytes.append(0x5b)
            for (index, value) in values.enumerated() {
                if index > 0 { bytes.append(0x2c) }
                value.appendCanonical(to: &bytes)
            }
            bytes.append(0x5d)
        case .string(let value, _):
            LedgerJSONValue.appendString(value, to: &bytes)
        case .number(let lexeme, _):
            bytes.append(contentsOf: lexeme.utf8)
        case .bool(let value, _):
            bytes.append(contentsOf: value ? [0x74, 0x72, 0x75, 0x65] : [0x66, 0x61, 0x6c, 0x73, 0x65])
        case .null:
            bytes.append(contentsOf: [0x6e, 0x75, 0x6c, 0x6c])
        }
    }

    private static func appendString(_ value: String, to bytes: inout [UInt8]) {
        bytes.append(0x22)
        for scalar in value.unicodeScalars {
            switch scalar.value {
            case 0x22: bytes.append(contentsOf: [0x5c, 0x22])
            case 0x5c: bytes.append(contentsOf: [0x5c, 0x5c])
            case 0x08: bytes.append(contentsOf: [0x5c, 0x62])
            case 0x0c: bytes.append(contentsOf: [0x5c, 0x66])
            case 0x0a: bytes.append(contentsOf: [0x5c, 0x6e])
            case 0x0d: bytes.append(contentsOf: [0x5c, 0x72])
            case 0x09: bytes.append(contentsOf: [0x5c, 0x74])
            case 0x00...0x1f:
                let digits = Array("0123456789abcdef".utf8)
                bytes.append(contentsOf: [0x5c, 0x75, 0x30, 0x30])
                bytes.append(digits[Int((scalar.value >> 4) & 0xf)])
                bytes.append(digits[Int(scalar.value & 0xf)])
            default:
                bytes.append(contentsOf: String(scalar).utf8)
            }
        }
        bytes.append(0x22)
    }
}

struct LedgerCanonicalJSONParser {
    private let bytes: [UInt8]
    private(set) var offset = 0
    private var entryCount = 0
    private let maximumDepth: Int
    private let maximumEntries: Int
    private let maximumStringBytes: Int

    init(
        data: Data,
        maximumDepth: Int = 64,
        maximumEntries: Int = 4_096,
        maximumStringBytes: Int = 1_048_576
    ) {
        bytes = Array(data)
        self.maximumDepth = maximumDepth
        self.maximumEntries = maximumEntries
        self.maximumStringBytes = maximumStringBytes
    }

    mutating func parse() throws -> LedgerJSONValue {
        let value = try parseValue(depth: 0)
        skipWhitespace()
        try require(offset == bytes.count, "JSON_TRAILING_BYTE")
        return value
    }

    private mutating func parseValue(depth: Int) throws -> LedgerJSONValue {
        try require(depth <= maximumDepth, "JSON_DEPTH_CAP")
        skipWhitespace()
        try require(offset < bytes.count, "JSON_UNEXPECTED_END")
        switch bytes[offset] {
        case 0x7b: return try parseObject(depth: depth)
        case 0x5b: return try parseArray(depth: depth)
        case 0x22:
            let start = offset
            let value = try parseString()
            return .string(value, .init(lowerBound: start, upperBound: offset))
        case 0x74:
            let start = offset
            try consume([0x74, 0x72, 0x75, 0x65])
            return .bool(true, .init(lowerBound: start, upperBound: offset))
        case 0x66:
            let start = offset
            try consume([0x66, 0x61, 0x6c, 0x73, 0x65])
            return .bool(false, .init(lowerBound: start, upperBound: offset))
        case 0x6e:
            let start = offset
            try consume([0x6e, 0x75, 0x6c, 0x6c])
            return .null(.init(lowerBound: start, upperBound: offset))
        case 0x2d, 0x30...0x39:
            let start = offset
            let value = try parseNumber()
            return .number(value, .init(lowerBound: start, upperBound: offset))
        default:
            throw rejection("JSON_TOKEN")
        }
    }

    private mutating func parseObject(depth: Int) throws -> LedgerJSONValue {
        let start = offset
        offset += 1
        skipWhitespace()
        var members: [LedgerJSONObjectMember] = []
        var keys = Set<String>()
        if consumeIf(0x7d) {
            return .object(members, .init(lowerBound: start, upperBound: offset))
        }
        while true {
            try countEntry()
            skipWhitespace()
            try require(offset < bytes.count && bytes[offset] == 0x22, "JSON_OBJECT_KEY")
            let key = try parseString()
            try require(keys.insert(key).inserted, "JSON_DUPLICATE_KEY")
            skipWhitespace()
            try require(consumeIf(0x3a), "JSON_COLON")
            let value = try parseValue(depth: depth + 1)
            members.append(.init(key: key, value: value))
            skipWhitespace()
            if consumeIf(0x7d) { break }
            try require(consumeIf(0x2c), "JSON_OBJECT_COMMA")
        }
        return .object(members, .init(lowerBound: start, upperBound: offset))
    }

    private mutating func parseArray(depth: Int) throws -> LedgerJSONValue {
        let start = offset
        offset += 1
        skipWhitespace()
        var values: [LedgerJSONValue] = []
        if consumeIf(0x5d) {
            return .array(values, .init(lowerBound: start, upperBound: offset))
        }
        while true {
            try countEntry()
            values.append(try parseValue(depth: depth + 1))
            skipWhitespace()
            if consumeIf(0x5d) { break }
            try require(consumeIf(0x2c), "JSON_ARRAY_COMMA")
        }
        return .array(values, .init(lowerBound: start, upperBound: offset))
    }

    private mutating func parseNumber() throws -> String {
        let start = offset
        if consumeIf(0x2d) {
            try require(offset < bytes.count, "JSON_NUMBER_SIGN_END")
        }
        if consumeIf(0x30) {
            if offset < bytes.count {
                try require(!(0x30...0x39).contains(bytes[offset]), "JSON_NUMBER_LEADING_ZERO")
            }
        } else {
            try require(offset < bytes.count && (0x31...0x39).contains(bytes[offset]), "JSON_NUMBER_INTEGER")
            offset += 1
            while offset < bytes.count && (0x30...0x39).contains(bytes[offset]) { offset += 1 }
        }
        if consumeIf(0x2e) {
            try require(offset < bytes.count && (0x30...0x39).contains(bytes[offset]), "JSON_NUMBER_FRACTION")
            while offset < bytes.count && (0x30...0x39).contains(bytes[offset]) { offset += 1 }
        }
        if offset < bytes.count && (bytes[offset] == 0x65 || bytes[offset] == 0x45) {
            offset += 1
            if offset < bytes.count && (bytes[offset] == 0x2b || bytes[offset] == 0x2d) { offset += 1 }
            try require(offset < bytes.count && (0x30...0x39).contains(bytes[offset]), "JSON_NUMBER_EXPONENT")
            while offset < bytes.count && (0x30...0x39).contains(bytes[offset]) { offset += 1 }
        }
        return String(decoding: bytes[start..<offset], as: UTF8.self)
    }

    private mutating func parseString() throws -> String {
        try require(consumeIf(0x22), "JSON_STRING_OPEN")
        var decoded: [UInt8] = []
        while offset < bytes.count {
            let byte = bytes[offset]
            offset += 1
            if byte == 0x22 {
                try require(decoded.count <= maximumStringBytes, "JSON_STRING_CAP")
                guard let string = String(bytes: decoded, encoding: .utf8) else {
                    throw rejection("JSON_INVALID_UTF8")
                }
                return string
            }
            try require(byte >= 0x20, "JSON_RAW_CONTROL")
            if byte != 0x5c {
                decoded.append(byte)
                continue
            }
            try require(offset < bytes.count, "JSON_ESCAPE_END")
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
                if (0xd800...0xdbff).contains(scalar) {
                    try require(offset + 2 <= bytes.count && bytes[offset] == 0x5c && bytes[offset + 1] == 0x75, "JSON_SURROGATE_PAIR")
                    offset += 2
                    let low = try parseHexQuad()
                    try require((0xdc00...0xdfff).contains(low), "JSON_LOW_SURROGATE")
                    scalar = 0x10000 + ((scalar - 0xd800) << 10) + (low - 0xdc00)
                } else {
                    try require(!(0xdc00...0xdfff).contains(scalar), "JSON_LONE_LOW_SURROGATE")
                }
                guard let unicode = Unicode.Scalar(scalar) else { throw rejection("JSON_UNICODE_SCALAR") }
                decoded.append(contentsOf: String(unicode).utf8)
            default:
                throw rejection("JSON_ESCAPE")
            }
        }
        throw rejection("JSON_UNTERMINATED_STRING")
    }

    private mutating func parseHexQuad() throws -> UInt32 {
        try require(offset + 4 <= bytes.count, "JSON_UNICODE_ESCAPE_END")
        var result: UInt32 = 0
        for _ in 0..<4 {
            let byte = bytes[offset]
            offset += 1
            let digit: UInt32
            switch byte {
            case 0x30...0x39: digit = UInt32(byte - 0x30)
            case 0x41...0x46: digit = UInt32(byte - 0x41 + 10)
            case 0x61...0x66: digit = UInt32(byte - 0x61 + 10)
            default: throw rejection("JSON_UNICODE_HEX")
            }
            result = result * 16 + digit
        }
        return result
    }

    private mutating func countEntry() throws {
        entryCount += 1
        try require(entryCount <= maximumEntries, "JSON_ENTRY_CAP")
    }

    private mutating func skipWhitespace() {
        while offset < bytes.count && [0x20, 0x09, 0x0a, 0x0d].contains(bytes[offset]) {
            offset += 1
        }
    }

    private mutating func consume(_ expected: [UInt8]) throws {
        try require(offset + expected.count <= bytes.count, "JSON_LITERAL_END")
        try require(Array(bytes[offset..<(offset + expected.count)]) == expected, "JSON_LITERAL")
        offset += expected.count
    }

    private mutating func consumeIf(_ byte: UInt8) -> Bool {
        guard offset < bytes.count && bytes[offset] == byte else { return false }
        offset += 1
        return true
    }
}

func ledgerLexicalLess(_ lhs: String, _ rhs: String) -> Bool {
    lhs.utf8.lexicographicallyPrecedes(rhs.utf8)
}

func ledgerSHA256(_ data: Data) -> String {
    SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
}

func ledgerCanonicalObject(_ values: [String: LedgerJSONValue]) -> Data {
    let span = LedgerJSONSpan(lowerBound: 0, upperBound: 0)
    return LedgerJSONValue.object(values.map { .init(key: $0.key, value: $0.value) }, span).canonicalData()
}

func rejection(_ code: String, _ detail: String = "") -> LedgerProjectionRejection {
    .init(code: code, detail: detail)
}

func require(_ condition: Bool, _ code: String, _ detail: String = "") throws {
    guard condition else { throw rejection(code, detail) }
}
