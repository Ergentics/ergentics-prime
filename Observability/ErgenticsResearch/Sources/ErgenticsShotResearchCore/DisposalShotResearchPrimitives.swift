import CryptoKit
import Foundation

public struct DisposalShotResearchRejection: Error, Equatable, Sendable,
    CustomStringConvertible
{
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

typealias DisposalProjectionRejection = DisposalShotResearchRejection

struct DisposalJSONSpan: Equatable, Sendable {
    let lowerBound: Int
    let upperBound: Int
}

struct DisposalJSONObjectMember: Sendable {
    let key: String
    let value: DisposalJSONValue
}

indirect enum DisposalJSONValue: Sendable {
    case object([DisposalJSONObjectMember], DisposalJSONSpan)
    case array([DisposalJSONValue], DisposalJSONSpan)
    case string(String, DisposalJSONSpan)
    case number(String, DisposalJSONSpan)
    case boolean(Bool, DisposalJSONSpan)
    case null(DisposalJSONSpan)

    func stringValue() -> String? {
        guard case .string(let value, _) = self else { return nil }
        return value
    }

    func numberLexeme() -> String? {
        guard case .number(let value, _) = self else { return nil }
        return value
    }

    func booleanValue() -> Bool? {
        guard case .boolean(let value, _) = self else { return nil }
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
            let ordered = members.sorted {
                $0.key.utf8.lexicographicallyPrecedes($1.key.utf8)
            }
            for (index, member) in ordered.enumerated() {
                if index > 0 { bytes.append(0x2c) }
                Self.appendString(member.key, to: &bytes)
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
            Self.appendString(value, to: &bytes)
        case .number(let lexeme, _):
            bytes.append(contentsOf: lexeme.utf8)
        case .boolean(let value, _):
            bytes.append(contentsOf: value
                ? [0x74, 0x72, 0x75, 0x65]
                : [0x66, 0x61, 0x6c, 0x73, 0x65])
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

struct DisposalCanonicalJSONParser {
    private let bytes: [UInt8]
    private let frameOrdinal: Int
    private let journalByteOffset: Int
    private let maximumDepth: Int
    private let maximumEntries: Int
    private let maximumStringBytes: Int
    private(set) var offset = 0
    private var entryCount = 0

    init(
        data: Data,
        frameOrdinal: Int,
        journalByteOffset: Int,
        maximumDepth: Int = 64,
        maximumEntries: Int = 131_072,
        maximumStringBytes: Int = 1_048_576
    ) {
        bytes = Array(data)
        self.frameOrdinal = frameOrdinal
        self.journalByteOffset = journalByteOffset
        self.maximumDepth = maximumDepth
        self.maximumEntries = maximumEntries
        self.maximumStringBytes = maximumStringBytes
    }

    mutating func parse() throws -> DisposalJSONValue {
        let value = try parseValue(depth: 0)
        skipWhitespace()
        try require(offset == bytes.count, "JSON_TRAILING_BYTE")
        return value
    }

    private mutating func parseValue(depth: Int) throws -> DisposalJSONValue {
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
            return .boolean(true, .init(lowerBound: start, upperBound: offset))
        case 0x66:
            let start = offset
            try consume([0x66, 0x61, 0x6c, 0x73, 0x65])
            return .boolean(false, .init(lowerBound: start, upperBound: offset))
        case 0x6e:
            let start = offset
            try consume([0x6e, 0x75, 0x6c, 0x6c])
            return .null(.init(lowerBound: start, upperBound: offset))
        case 0x2d, 0x30...0x39:
            let start = offset
            let lexeme = try parseNumber()
            return .number(lexeme, .init(lowerBound: start, upperBound: offset))
        default:
            throw error("JSON_TOKEN")
        }
    }

    private mutating func parseObject(depth: Int) throws -> DisposalJSONValue {
        let start = offset
        offset += 1
        skipWhitespace()
        var members: [DisposalJSONObjectMember] = []
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
            members.append(.init(key: key, value: try parseValue(depth: depth + 1)))
            skipWhitespace()
            if consumeIf(0x7d) { break }
            try require(consumeIf(0x2c), "JSON_OBJECT_COMMA")
        }
        return .object(members, .init(lowerBound: start, upperBound: offset))
    }

    private mutating func parseArray(depth: Int) throws -> DisposalJSONValue {
        let start = offset
        offset += 1
        skipWhitespace()
        var values: [DisposalJSONValue] = []
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
            try require(
                offset < bytes.count && (0x31...0x39).contains(bytes[offset]),
                "JSON_NUMBER_INTEGER")
            offset += 1
            while offset < bytes.count && (0x30...0x39).contains(bytes[offset]) {
                offset += 1
            }
        }
        if consumeIf(0x2e) {
            try require(
                offset < bytes.count && (0x30...0x39).contains(bytes[offset]),
                "JSON_NUMBER_FRACTION")
            while offset < bytes.count && (0x30...0x39).contains(bytes[offset]) {
                offset += 1
            }
        }
        if offset < bytes.count && (bytes[offset] == 0x65 || bytes[offset] == 0x45) {
            offset += 1
            if offset < bytes.count && (bytes[offset] == 0x2b || bytes[offset] == 0x2d) {
                offset += 1
            }
            try require(
                offset < bytes.count && (0x30...0x39).contains(bytes[offset]),
                "JSON_NUMBER_EXPONENT")
            while offset < bytes.count && (0x30...0x39).contains(bytes[offset]) {
                offset += 1
            }
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
                guard let value = String(bytes: decoded, encoding: .utf8) else {
                    throw error("JSON_INVALID_UTF8")
                }
                return value
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
                    try require(
                        offset + 2 <= bytes.count && bytes[offset] == 0x5c &&
                            bytes[offset + 1] == 0x75,
                        "JSON_SURROGATE_PAIR")
                    offset += 2
                    let low = try parseHexQuad()
                    try require((0xdc00...0xdfff).contains(low), "JSON_LOW_SURROGATE")
                    scalar = 0x10000 + ((scalar - 0xd800) << 10) + (low - 0xdc00)
                } else {
                    try require(!(0xdc00...0xdfff).contains(scalar), "JSON_LONE_LOW_SURROGATE")
                }
                guard let unicode = Unicode.Scalar(scalar) else {
                    throw error("JSON_UNICODE_SCALAR")
                }
                decoded.append(contentsOf: String(unicode).utf8)
            default:
                throw error("JSON_ESCAPE")
            }
        }
        throw error("JSON_UNTERMINATED_STRING")
    }

    private mutating func parseHexQuad() throws -> UInt32 {
        try require(offset + 4 <= bytes.count, "JSON_UNICODE_ESCAPE_END")
        var value: UInt32 = 0
        for _ in 0..<4 {
            let byte = bytes[offset]
            offset += 1
            let digit: UInt32
            switch byte {
            case 0x30...0x39: digit = UInt32(byte - 0x30)
            case 0x41...0x46: digit = UInt32(byte - 0x41 + 10)
            case 0x61...0x66: digit = UInt32(byte - 0x61 + 10)
            default: throw error("JSON_UNICODE_HEX")
            }
            value = value * 16 + digit
        }
        return value
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
        try require(
            Array(bytes[offset..<(offset + expected.count)]) == expected,
            "JSON_LITERAL")
        offset += expected.count
    }

    private mutating func consumeIf(_ byte: UInt8) -> Bool {
        guard offset < bytes.count && bytes[offset] == byte else { return false }
        offset += 1
        return true
    }

    private func require(_ condition: Bool, _ code: String) throws {
        guard condition else { throw error(code) }
    }

    private func error(_ code: String) -> DisposalShotResearchRejection {
        .init(
            code: code,
            frameOrdinal: frameOrdinal,
            byteOffset: journalByteOffset + offset)
    }
}

let disposalZeroSpan = DisposalJSONSpan(lowerBound: 0, upperBound: 0)

func disposalSHA256(_ data: Data) -> String {
    SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
}

func disposalLengthFramedID(_ domain: String, _ components: [String]) -> String {
    var bytes = Data("ERGENTICS_DISPOSAL_LENGTH_FRAMED_ID_V1".utf8)
    disposalAppendUInt64BE(UInt64(domain.utf8.count), to: &bytes)
    bytes.append(contentsOf: domain.utf8)
    disposalAppendUInt64BE(UInt64(components.count), to: &bytes)
    for component in components {
        disposalAppendUInt64BE(UInt64(component.utf8.count), to: &bytes)
        bytes.append(contentsOf: component.utf8)
    }
    return disposalSHA256(bytes)
}

private func disposalAppendUInt64BE(_ value: UInt64, to data: inout Data) {
    var encoded = value.bigEndian
    withUnsafeBytes(of: &encoded) { data.append(contentsOf: $0) }
}

func disposalIsLowerHex(_ value: String, count: Int) -> Bool {
    value.utf8.count == count && value.utf8.allSatisfy {
        (0x30...0x39).contains($0) || (0x61...0x66).contains($0)
    }
}

func disposalCanonicalObject(_ members: [String: DisposalJSONValue]) -> Data {
    DisposalJSONValue.object(
        members.map { DisposalJSONObjectMember(key: $0.key, value: $0.value) },
        disposalZeroSpan).canonicalData()
}

func disposalJSONString(_ value: String) -> DisposalJSONValue {
    .string(value, disposalZeroSpan)
}

func disposalJSONNumber(_ value: Int) -> DisposalJSONValue {
    .number(String(value), disposalZeroSpan)
}

func disposalJSONBoolean(_ value: Bool) -> DisposalJSONValue {
    .boolean(value, disposalZeroSpan)
}
