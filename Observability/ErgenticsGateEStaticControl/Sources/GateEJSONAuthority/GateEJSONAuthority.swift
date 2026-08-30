import CryptoKit
import Foundation

public enum GateEJSONAuthorityError: Error, Equatable, Sendable {
    case empty
    case size
    case syntax
    case duplicateKey
    case nonCanonical
    case schema
    case digest
    case graph
}

indirect enum GateEJSONValue: Sendable {
    case null
    case bool(Bool)
    case unsigned(UInt64)
    case string(String)
    case array([GateEJSONValue])
    case object([(String, GateEJSONValue)])

    static func exactObject(
        _ fields: [(String, GateEJSONValue)]
    ) throws -> GateEJSONValue {
        var keys = Set<String>()
        for (key, _) in fields where !keys.insert(key).inserted {
            throw GateEJSONAuthorityError.duplicateKey
        }
        return .object(fields)
    }

    var objectFields: [(String, GateEJSONValue)]? {
        guard case .object(let fields) = self else { return nil }
        return fields
    }

    func field(_ name: String) -> GateEJSONValue? {
        objectFields?.first(where: { $0.0 == name })?.1
    }
}

enum GateECanonicalJSON {
    static let maximumBytes = 16 * 1024 * 1024

    static func decode(_ bytes: [UInt8]) throws -> GateEJSONValue {
        guard !bytes.isEmpty else { throw GateEJSONAuthorityError.empty }
        guard bytes.count <= maximumBytes else {
            throw GateEJSONAuthorityError.size
        }
        var parser = Parser(bytes)
        let value = try parser.document()
        guard parser.isAtEnd else { throw GateEJSONAuthorityError.syntax }
        return value
    }

    static func decodeCanonical(_ bytes: [UInt8]) throws -> GateEJSONValue {
        let value = try decode(bytes)
        guard try encode(value) == bytes else {
            throw GateEJSONAuthorityError.nonCanonical
        }
        return value
    }

    static func encode(_ value: GateEJSONValue) throws -> [UInt8] {
        var bytes: [UInt8] = []
        try append(value, to: &bytes)
        guard bytes.count <= maximumBytes else {
            throw GateEJSONAuthorityError.size
        }
        return bytes
    }

    private static func append(
        _ value: GateEJSONValue,
        to bytes: inout [UInt8]
    ) throws {
        switch value {
        case .null:
            bytes.append(contentsOf: [0x6e, 0x75, 0x6c, 0x6c])
        case .bool(false):
            bytes.append(contentsOf: [0x66, 0x61, 0x6c, 0x73, 0x65])
        case .bool(true):
            bytes.append(contentsOf: [0x74, 0x72, 0x75, 0x65])
        case .unsigned(let value):
            bytes.append(contentsOf: String(value).utf8)
        case .string(let value):
            try appendString(value, to: &bytes)
        case .array(let values):
            bytes.append(0x5b)
            for index in values.indices {
                if index > values.startIndex { bytes.append(0x2c) }
                try append(values[index], to: &bytes)
            }
            bytes.append(0x5d)
        case .object(let fields):
            var keys = Set<String>()
            let ordered = try fields.map { field -> (String, GateEJSONValue) in
                guard keys.insert(field.0).inserted else {
                    throw GateEJSONAuthorityError.duplicateKey
                }
                return field
            }.sorted { utf8Less($0.0, $1.0) }
            bytes.append(0x7b)
            for index in ordered.indices {
                if index > ordered.startIndex { bytes.append(0x2c) }
                try appendString(ordered[index].0, to: &bytes)
                bytes.append(0x3a)
                try append(ordered[index].1, to: &bytes)
            }
            bytes.append(0x7d)
        }
    }

    private static func appendString(
        _ value: String,
        to bytes: inout [UInt8]
    ) throws {
        guard !value.unicodeScalars.contains(where: { $0.value == 0 }) else {
            throw GateEJSONAuthorityError.schema
        }
        bytes.append(0x22)
        for byte in value.utf8 {
            switch byte {
            case 0x22:
                bytes.append(contentsOf: [0x5c, 0x22])
            case 0x5c:
                bytes.append(contentsOf: [0x5c, 0x5c])
            case 0x08:
                bytes.append(contentsOf: [0x5c, 0x62])
            case 0x0c:
                bytes.append(contentsOf: [0x5c, 0x66])
            case 0x0a:
                bytes.append(contentsOf: [0x5c, 0x6e])
            case 0x0d:
                bytes.append(contentsOf: [0x5c, 0x72])
            case 0x09:
                bytes.append(contentsOf: [0x5c, 0x74])
            case 0x00 ... 0x1f:
                let digits = Array("0123456789abcdef".utf8)
                bytes.append(contentsOf: [
                    0x5c, 0x75, 0x30, 0x30,
                    digits[Int(byte >> 4)], digits[Int(byte & 0x0f)],
                ])
            default:
                bytes.append(byte)
            }
        }
        bytes.append(0x22)
    }

    private static func utf8Less(_ lhs: String, _ rhs: String) -> Bool {
        Array(lhs.utf8).lexicographicallyPrecedes(Array(rhs.utf8))
    }

    private struct Parser {
        private let bytes: [UInt8]
        private var offset = 0

        init(_ bytes: [UInt8]) { self.bytes = bytes }

        var isAtEnd: Bool { offset == bytes.count }

        mutating func document() throws -> GateEJSONValue {
            skipWhitespace()
            let value = try value(depth: 0)
            skipWhitespace()
            return value
        }

        private mutating func value(depth: Int) throws -> GateEJSONValue {
            guard depth <= 64, let byte = peek() else {
                throw GateEJSONAuthorityError.syntax
            }
            switch byte {
            case 0x7b: return try object(depth: depth + 1)
            case 0x5b: return try array(depth: depth + 1)
            case 0x22: return .string(try string())
            case 0x74:
                try literal([0x74, 0x72, 0x75, 0x65])
                return .bool(true)
            case 0x66:
                try literal([0x66, 0x61, 0x6c, 0x73, 0x65])
                return .bool(false)
            case 0x6e:
                try literal([0x6e, 0x75, 0x6c, 0x6c])
                return .null
            case 0x30 ... 0x39:
                return .unsigned(try unsigned())
            default:
                throw GateEJSONAuthorityError.syntax
            }
        }

        private mutating func object(depth: Int) throws -> GateEJSONValue {
            try consume(0x7b)
            skipWhitespace()
            if take(0x7d) { return .object([]) }
            var fields: [(String, GateEJSONValue)] = []
            var keys = Set<String>()
            while true {
                guard peek() == 0x22 else {
                    throw GateEJSONAuthorityError.syntax
                }
                let key = try string()
                guard keys.insert(key).inserted else {
                    throw GateEJSONAuthorityError.duplicateKey
                }
                skipWhitespace()
                try consume(0x3a)
                skipWhitespace()
                fields.append((key, try value(depth: depth)))
                skipWhitespace()
                if take(0x7d) { return .object(fields) }
                try consume(0x2c)
                skipWhitespace()
            }
        }

        private mutating func array(depth: Int) throws -> GateEJSONValue {
            try consume(0x5b)
            skipWhitespace()
            if take(0x5d) { return .array([]) }
            var values: [GateEJSONValue] = []
            while true {
                values.append(try value(depth: depth))
                skipWhitespace()
                if take(0x5d) { return .array(values) }
                try consume(0x2c)
                skipWhitespace()
            }
        }

        private mutating func string() throws -> String {
            try consume(0x22)
            var decoded: [UInt8] = []
            while let byte = peek() {
                offset += 1
                switch byte {
                case 0x22:
                    guard let value = String(bytes: decoded, encoding: .utf8),
                          !value.unicodeScalars.contains(where: { $0.value == 0 })
                    else { throw GateEJSONAuthorityError.syntax }
                    return value
                case 0x00 ... 0x1f:
                    throw GateEJSONAuthorityError.syntax
                case 0x5c:
                    guard let escape = peek() else {
                        throw GateEJSONAuthorityError.syntax
                    }
                    offset += 1
                    switch escape {
                    case 0x22, 0x5c, 0x2f: decoded.append(escape)
                    case 0x62: decoded.append(0x08)
                    case 0x66: decoded.append(0x0c)
                    case 0x6e: decoded.append(0x0a)
                    case 0x72: decoded.append(0x0d)
                    case 0x74: decoded.append(0x09)
                    case 0x75:
                        let first = try hexQuad()
                        let scalarValue: UInt32
                        if (0xd800 ... 0xdbff).contains(first) {
                            try consume(0x5c)
                            try consume(0x75)
                            let second = try hexQuad()
                            guard (0xdc00 ... 0xdfff).contains(second) else {
                                throw GateEJSONAuthorityError.syntax
                            }
                            scalarValue = 0x10000
                                + (UInt32(first - 0xd800) << 10)
                                + UInt32(second - 0xdc00)
                        } else {
                            guard !(0xdc00 ... 0xdfff).contains(first) else {
                                throw GateEJSONAuthorityError.syntax
                            }
                            scalarValue = UInt32(first)
                        }
                        guard let scalar = UnicodeScalar(scalarValue) else {
                            throw GateEJSONAuthorityError.syntax
                        }
                        decoded.append(contentsOf: String(scalar).utf8)
                    default:
                        throw GateEJSONAuthorityError.syntax
                    }
                default:
                    decoded.append(byte)
                }
            }
            throw GateEJSONAuthorityError.syntax
        }

        private mutating func unsigned() throws -> UInt64 {
            guard let first = peek() else { throw GateEJSONAuthorityError.syntax }
            var digits: [UInt8] = []
            while let byte = peek(), (0x30 ... 0x39).contains(byte) {
                digits.append(byte)
                offset += 1
            }
            guard !digits.isEmpty,
                  !(first == 0x30 && digits.count > 1),
                  let value = UInt64(String(decoding: digits, as: UTF8.self))
            else { throw GateEJSONAuthorityError.syntax }
            return value
        }

        private mutating func hexQuad() throws -> UInt16 {
            var value: UInt16 = 0
            for _ in 0 ..< 4 {
                guard let byte = peek(), let digit = hexDigit(byte) else {
                    throw GateEJSONAuthorityError.syntax
                }
                offset += 1
                value = (value << 4) | UInt16(digit)
            }
            return value
        }

        private func hexDigit(_ byte: UInt8) -> UInt8? {
            switch byte {
            case 0x30 ... 0x39: return byte - 0x30
            case 0x41 ... 0x46: return byte - 0x41 + 10
            case 0x61 ... 0x66: return byte - 0x61 + 10
            default: return nil
            }
        }

        private mutating func literal(_ literal: [UInt8]) throws {
            guard offset + literal.count <= bytes.count,
                  Array(bytes[offset ..< offset + literal.count]) == literal
            else { throw GateEJSONAuthorityError.syntax }
            offset += literal.count
        }

        private mutating func skipWhitespace() {
            while let byte = peek(),
                  byte == 0x20 || byte == 0x09 || byte == 0x0a || byte == 0x0d
            { offset += 1 }
        }

        private func peek() -> UInt8? {
            offset < bytes.count ? bytes[offset] : nil
        }

        private mutating func take(_ byte: UInt8) -> Bool {
            guard peek() == byte else { return false }
            offset += 1
            return true
        }

        private mutating func consume(_ byte: UInt8) throws {
            guard take(byte) else { throw GateEJSONAuthorityError.syntax }
        }
    }
}

struct GateEStaticModel: Equatable, Sendable {
    static let schema = "ergentics.gate-e.static.candidate.v1"
    static let roles = [
        "prime_head_pre", "prime_object_format", "prime_status_pre",
        "prime_tree_discovery", "prime_tree_replay", "prime_status_post",
        "prime_head_post", "companion_head_pre", "companion_object_format",
        "companion_status_pre", "companion_tree_discovery",
        "companion_tree_replay", "companion_status_post",
        "companion_head_post", "swift_version", "swift_target_info",
    ]
    static let predicates = [
        "PRIME_HEAD_PRE_EQUALS_POST_40_LOWERHEX_LF",
        "PRIME_OBJECT_FORMAT_EQUALS_SHA1_LF",
        "PRIME_STATUS_PRE_AND_POST_EXACT_EMPTY",
        "PRIME_TREE_DISCOVERY_EQUALS_REPLAY",
        "PRIME_GATE_D_MANIFEST_JOINS_RETAINED_SOURCE_AUTHORITY",
        "COMPANION_HEAD_PRE_EQUALS_POST_EQUALS_PINNED_COMMIT",
        "COMPANION_OBJECT_FORMAT_EQUALS_SHA1_LF",
        "COMPANION_STATUS_PRE_AND_POST_EXACT_EMPTY",
        "COMPANION_TREE_DISCOVERY_EQUALS_REPLAY",
        "COMPANION_GATE_D_MANIFEST_JOINS_COMPLETE_GATE_C_CLOSURE",
        "SWIFT_VERSION_BOUNDED_FRAMING_AND_INTENT_BIND",
        "SWIFT_TARGET_INFO_CANONICAL_FRAMING_AND_INTENT_BIND",
        "DRIVERCORE_INDEPENDENT_REPARSE_AND_LIVE_BIND_PASS",
        "FINAL_ROOT_IMAGE_LEASE_JOURNAL_CONTINUITY_PASS",
        "FINAL_PROCESS_CONSERVATION_PASS",
        "BUILD_STAGE_LIST_ROLE_ENTRY_COUNTS_ALL_ZERO",
    ]

    let sourceCommit: String
    let sourceTree: String
    let sourceIdentity: String

    init(sourceCommit: String, sourceTree: String, sourceIdentity: String) throws {
        guard Self.isLowerHex(sourceCommit, count: 40),
              Self.isLowerHex(sourceTree, count: 40),
              Self.isLowerHex(sourceIdentity, count: 64)
        else { throw GateEJSONAuthorityError.schema }
        self.sourceCommit = sourceCommit
        self.sourceTree = sourceTree
        self.sourceIdentity = sourceIdentity
    }

    init(json value: GateEJSONValue) throws {
        guard let fields = value.objectFields,
              Set(fields.map { $0.0 }) == Set([
                "authority_vector", "gate_state", "predicates", "roles",
                "schema", "source_commit", "source_identity", "source_tree",
              ]),
              value.field("schema")?.stringValue == Self.schema,
              value.field("authority_vector")?.stringValue == "00000000",
              value.field("gate_state")?.stringValue == "ABSTAIN",
              value.field("roles")?.stringArray == Self.roles,
              value.field("predicates")?.stringArray == Self.predicates,
              let sourceCommit = value.field("source_commit")?.stringValue,
              let sourceTree = value.field("source_tree")?.stringValue,
              let sourceIdentity = value.field("source_identity")?.stringValue
        else { throw GateEJSONAuthorityError.schema }
        try self.init(
            sourceCommit: sourceCommit,
            sourceTree: sourceTree,
            sourceIdentity: sourceIdentity
        )
    }

    var canonicalValue: GateEJSONValue {
        .object([
            ("authority_vector", .string("00000000")),
            ("gate_state", .string("ABSTAIN")),
            ("predicates", .array(Self.predicates.map { .string($0) })),
            ("roles", .array(Self.roles.map { .string($0) })),
            ("schema", .string(Self.schema)),
            ("source_commit", .string(sourceCommit)),
            ("source_identity", .string(sourceIdentity)),
            ("source_tree", .string(sourceTree)),
        ])
    }

    private static func isLowerHex(_ value: String, count: Int) -> Bool {
        value.utf8.count == count && value.utf8.allSatisfy {
            (0x30 ... 0x39).contains($0) || (0x61 ... 0x66).contains($0)
        }
    }
}

private extension GateEJSONValue {
    var stringValue: String? {
        guard case .string(let value) = self else { return nil }
        return value
    }

    var stringArray: [String]? {
        guard case .array(let values) = self else { return nil }
        return values.reduce(into: [String]()) { result, value in
            if let string = value.stringValue { result.append(string) }
        }.count == values.count ? values.compactMap(\.stringValue) : nil
    }
}

enum GateEStaticHash {
    static func sha256(_ bytes: [UInt8]) -> [UInt8] {
        Array(SHA256.hash(data: Data(bytes)))
    }

    static func hex(_ bytes: [UInt8]) -> String {
        let digits = Array("0123456789abcdef".utf8)
        var output: [UInt8] = []
        output.reserveCapacity(bytes.count * 2)
        for byte in bytes {
            output.append(digits[Int(byte >> 4)])
            output.append(digits[Int(byte & 0x0f)])
        }
        return String(decoding: output, as: UTF8.self)
    }

    static func sha256Hex(_ bytes: [UInt8]) -> String { hex(sha256(bytes)) }

    static func domain(_ name: String, _ fields: [[UInt8]]) -> [UInt8] {
        var preimage = Array(name.utf8)
        preimage.append(0)
        for field in fields {
            appendUInt64BE(UInt64(field.count), to: &preimage)
            preimage.append(contentsOf: field)
        }
        return sha256(preimage)
    }

    static func appendUInt64BE(_ value: UInt64, to bytes: inout [UInt8]) {
        bytes.append(UInt8((value >> 56) & 0xff))
        bytes.append(UInt8((value >> 48) & 0xff))
        bytes.append(UInt8((value >> 40) & 0xff))
        bytes.append(UInt8((value >> 32) & 0xff))
        bytes.append(UInt8((value >> 24) & 0xff))
        bytes.append(UInt8((value >> 16) & 0xff))
        bytes.append(UInt8((value >> 8) & 0xff))
        bytes.append(UInt8(value & 0xff))
    }
}

struct GateEStaticGraphProjection: Sendable {
    let graphFrame: [UInt8]
    let semanticRoot: String
    let graphMerkleRoot: String
}

enum GateEStaticGraphProjector {
    static let graphSchema = "ergentics.gate-e.static.graph-frame.v1"
    static let semanticDomain = "ERGENTICS-GATE-E-STATIC-SEMANTIC-V1"
    static let factDomain = "ERGENTICS-GATE-E-STATIC-FACT-V1"
    static let relationDomain = "ERGENTICS-GATE-E-STATIC-RELATION-V1"
    static let edgeDomain = "ERGENTICS-GATE-E-STATIC-EDGE-V1"
    static let merkleLeafDomain = "ERGENTICS-GATE-E-STATIC-MERKLE-LEAF-V1"
    static let merkleNodeDomain = "ERGENTICS-GATE-E-STATIC-MERKLE-NODE-V1"
    static let merkleEmptyDomain = "ERGENTICS-GATE-E-STATIC-MERKLE-EMPTY-V1"

    private struct Row {
        let value: GateEJSONValue
        let bytes: [UInt8]
    }

    static func project(_ model: GateEStaticModel) throws -> GateEStaticGraphProjection {
        let semanticBytes = try GateECanonicalJSON.encode(model.canonicalValue)
        let semanticRoot = GateEStaticHash.hex(GateEStaticHash.domain(
            semanticDomain, [semanticBytes]
        ))

        let preBody: GateEJSONValue = .object([
            ("authority_vector", .string("00000000")),
            ("gate_state", .string("ABSTAIN")),
            ("predecessor_state_id_or_null", .null),
            ("prior_transition_id_or_null", .null),
            ("state_class", .string("STATIC_INPUT")),
        ])
        let pre = try fact(subtype: "STATE", body: preBody)

        let source = try fact(subtype: "WITNESS", body: .object([
            ("kind", .string("SOURCE_BINDING")),
            ("source_commit", .string(model.sourceCommit)),
            ("source_identity", .string(model.sourceIdentity)),
            ("source_tree", .string(model.sourceTree)),
        ]))
        let roles = try fact(subtype: "WITNESS", body: .object([
            ("kind", .string("ROLE_ORDER")),
            ("roles", .array(GateEStaticModel.roles.map { .string($0) })),
        ]))
        let predicates = try fact(subtype: "WITNESS", body: .object([
            ("kind", .string("PREDICATE_SET")),
            ("predicates", .array(GateEStaticModel.predicates.map { .string($0) })),
        ]))
        let vector = try fact(subtype: "WITNESS", body: .object([
            ("authority_vector", .string("00000000")),
            ("gate_state", .string("ABSTAIN")),
            ("kind", .string("AUTHORITY_PRESTATE")),
        ]))
        let witnessIDs = try [source, roles, predicates, vector].map(rowID)

        let relation = try transition(body: .object([
            ("from_state_id", .string(try rowID(pre))),
            ("predicate", .string("CANDIDATE_SCHEMA_ROLE_PREDICATE_AND_PRESTATE_EXACT")),
            ("result", .string("PROVED")),
            ("witness_ids", .array(witnessIDs.map { .string($0) })),
        ]))
        let post = try fact(subtype: "STATE", body: .object([
            ("authority_vector", .string("00000000")),
            ("gate_state", .string("ABSTAIN")),
            ("predecessor_state_id_or_null", .string(try rowID(pre))),
            ("prior_transition_id_or_null", .string(try rowID(relation))),
            ("state_class", .string("STATIC_READY")),
        ]))

        var facts = [pre, post, source, roles, predicates, vector]
        var relations = [relation]
        let relationID = try rowID(relation)
        var edges = [try edge(
            role: "STATE_FACT_TO_TRANSITION_RELATION_FROM",
            source: try rowID(pre), target: relationID, ordinal: 0
        )]
        for (ordinal, witnessID) in witnessIDs.enumerated() {
            edges.append(try edge(
                role: "WITNESS_FACT_TO_TRANSITION_RELATION_WITNESS",
                source: witnessID, target: relationID, ordinal: UInt64(ordinal)
            ))
        }
        edges.append(try edge(
            role: "TRANSITION_RELATION_TO_STATE_FACT_TO",
            source: relationID, target: try rowID(post), ordinal: 0
        ))

        facts.sort { $0.bytes.lexicographicallyPrecedes($1.bytes) }
        relations.sort { $0.bytes.lexicographicallyPrecedes($1.bytes) }
        edges.sort { $0.bytes.lexicographicallyPrecedes($1.bytes) }
        let allRows = (facts + relations + edges).sorted {
            $0.bytes.lexicographicallyPrecedes($1.bytes)
        }
        let merkleRoot = GateEStaticHash.hex(merkle(allRows.map(\.bytes)))
        let frame: GateEJSONValue = .object([
            ("authority_vector_expectation", .string("00000000")),
            ("edges", .array(edges.map(\.value))),
            ("facts", .array(facts.map(\.value))),
            ("gate_state", .string("ABSTAIN")),
            ("graph_merkle_root", .string(merkleRoot)),
            ("relations", .array(relations.map(\.value))),
            ("schema", .string(graphSchema)),
            ("semantic_root", .string(semanticRoot)),
        ])
        return GateEStaticGraphProjection(
            graphFrame: try GateECanonicalJSON.encode(frame),
            semanticRoot: semanticRoot,
            graphMerkleRoot: merkleRoot
        )
    }

    private static func fact(
        subtype: String,
        body: GateEJSONValue
    ) throws -> Row {
        let bodyBytes = try GateECanonicalJSON.encode(body)
        let id = GateEStaticHash.hex(GateEStaticHash.domain(
            factDomain, [Array(subtype.utf8), bodyBytes]
        ))
        let value: GateEJSONValue = .object([
            ("body", body), ("id", .string(id)),
            ("partition", .string("FACT")), ("subtype", .string(subtype)),
        ])
        return Row(value: value, bytes: try GateECanonicalJSON.encode(value))
    }

    private static func transition(body: GateEJSONValue) throws -> Row {
        let bodyBytes = try GateECanonicalJSON.encode(body)
        let id = GateEStaticHash.hex(GateEStaticHash.domain(
            relationDomain, [bodyBytes]
        ))
        let value: GateEJSONValue = .object([
            ("body", body), ("id", .string(id)),
            ("partition", .string("RELATION")),
            ("subtype", .string("TRANSITION")),
        ])
        return Row(value: value, bytes: try GateECanonicalJSON.encode(value))
    }

    private static func edge(
        role: String,
        source: String,
        target: String,
        ordinal: UInt64
    ) throws -> Row {
        let id = GateEStaticHash.hex(GateEStaticHash.domain(edgeDomain, [
            Array(role.utf8), Array(source.utf8), Array(target.utf8),
            Array(String(ordinal).utf8),
        ]))
        let value: GateEJSONValue = .object([
            ("id", .string(id)), ("ordinal", .unsigned(ordinal)),
            ("role", .string(role)), ("source_id", .string(source)),
            ("target_id", .string(target)),
        ])
        return Row(value: value, bytes: try GateECanonicalJSON.encode(value))
    }

    private static func rowID(_ row: Row) throws -> String {
        guard let value = row.value.field("id")?.stringValue else {
            throw GateEJSONAuthorityError.graph
        }
        return value
    }

    private static func merkle(_ rows: [[UInt8]]) -> [UInt8] {
        guard !rows.isEmpty else {
            return GateEStaticHash.domain(merkleEmptyDomain, [])
        }
        var level = rows.map { GateEStaticHash.domain(merkleLeafDomain, [$0]) }
        while level.count > 1 {
            var next: [[UInt8]] = []
            var index = 0
            while index < level.count {
                let left = level[index]
                let right = index + 1 < level.count ? level[index + 1] : left
                next.append(GateEStaticHash.domain(merkleNodeDomain, [left, right]))
                index += 2
            }
            level = next
        }
        return level[0]
    }
}

public struct GateEJSONProjectionResult: Equatable, Sendable {
    public let verifierReceipt: [UInt8]
    public let graphFrame: [UInt8]

    public init(verifierReceipt: [UInt8], graphFrame: [UInt8]) {
        self.verifierReceipt = verifierReceipt
        self.graphFrame = graphFrame
    }
}

public enum GateEJSONAuthority {
    public static let roles = GateEStaticModel.roles
    public static let predicates = GateEStaticModel.predicates

    public static func projectAndVerify(
        candidate: [UInt8]
    ) throws -> GateEJSONProjectionResult {
        guard candidate.count <= 4 * 1024 * 1024 else {
            throw GateEJSONAuthorityError.size
        }
        let value = try GateECanonicalJSON.decodeCanonical(candidate)
        let model = try GateEStaticModel(json: value)
        let projection = try GateEStaticGraphProjector.project(model)
        let receipt: GateEJSONValue = .object([
            ("candidate_sha256", .string(GateEStaticHash.sha256Hex(candidate))),
            ("graph_frame_sha256", .string(
                GateEStaticHash.sha256Hex(projection.graphFrame)
            )),
            ("graph_merkle_root", .string(projection.graphMerkleRoot)),
            ("result", .string("PASS")),
            ("schema", .string("ergentics.gate-e.static.verifier-receipt.v1")),
            ("semantic_root", .string(projection.semanticRoot)),
            ("source_authority", .string("JSON")),
        ])
        return GateEJSONProjectionResult(
            verifierReceipt: try GateECanonicalJSON.encode(receipt),
            graphFrame: projection.graphFrame
        )
    }
}
