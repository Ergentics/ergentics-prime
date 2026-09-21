import CryptoKit
import Foundation

public struct GateECBORProjectionResult: Equatable, Sendable {
    public let verifierReceipt: [UInt8]
    public let graphFrame: [UInt8]

    public init(verifierReceipt: [UInt8], graphFrame: [UInt8]) {
        self.verifierReceipt = verifierReceipt
        self.graphFrame = graphFrame
    }
}

public enum GateECBORAuthorityError: Error, Equatable, Sendable {
    case candidateTooLarge
    case malformedCBOR
    case nonCanonicalCBOR
    case invalidCandidate
    case invalidGraphFrame
    case reconstructionMismatch
}

enum GateECBORStaticSchema {
    static let candidateSchema = "ergentics.gate-e.static.candidate.v1"
    static let graphSchema = "ergentics.gate-e.static.graph-frame.v1"
    static let verifierReceiptSchema = "ergentics.gate-e.static.verifier-receipt.v1"
    static let roundTripReceiptSchema = "ergentics.gate-e.static.round-trip-receipt.v1"

    static let semanticDomain = "ERGENTICS-GATE-E-STATIC-SEMANTIC-V1"
    static let factDomain = "ERGENTICS-GATE-E-STATIC-FACT-V1"
    static let relationDomain = "ERGENTICS-GATE-E-STATIC-RELATION-V1"
    static let edgeDomain = "ERGENTICS-GATE-E-STATIC-EDGE-V1"
    static let merkleLeafDomain = "ERGENTICS-GATE-E-STATIC-MERKLE-LEAF-V1"
    static let merkleNodeDomain = "ERGENTICS-GATE-E-STATIC-MERKLE-NODE-V1"
    static let merkleEmptyDomain = "ERGENTICS-GATE-E-STATIC-MERKLE-EMPTY-V1"

    static let roles = [
        "prime_head_pre",
        "prime_object_format",
        "prime_status_pre",
        "prime_tree_discovery",
        "prime_tree_replay",
        "prime_status_post",
        "prime_head_post",
        "companion_head_pre",
        "companion_object_format",
        "companion_status_pre",
        "companion_tree_discovery",
        "companion_tree_replay",
        "companion_status_post",
        "companion_head_post",
        "swift_version",
        "swift_target_info",
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
}

struct GateECBORCandidateModel: Equatable, Sendable {
    let sourceCommit: String
    let sourceTree: String
    let sourceIdentity: String
    let authorityVector: [UInt8]
    let gateState: String
    let roles: [String]
    let predicates: [String]
}

public enum GateECBORAuthority {
    public static let roles = GateECBORStaticSchema.roles
    public static let predicates = GateECBORStaticSchema.predicates

    public static func canonicalCandidate(
        sourceCommit: String,
        sourceTree: String,
        sourceIdentity: String
    ) throws -> [UInt8] {
        guard AuthorityCandidateValidation.isLowerHex(sourceCommit, count: 40),
              AuthorityCandidateValidation.isLowerHex(sourceTree, count: 40),
              AuthorityCandidateValidation.isLowerHex(sourceIdentity, count: 64)
        else {
            throw GateECBORAuthorityError.invalidCandidate
        }
        return AuthorityCandidateEncoder.encode(GateECBORCandidateModel(
            sourceCommit: sourceCommit,
            sourceTree: sourceTree,
            sourceIdentity: sourceIdentity,
            authorityVector: [0],
            gateState: "ABSTAIN",
            roles: GateECBORStaticSchema.roles,
            predicates: GateECBORStaticSchema.predicates
        ))
    }

    public static func projectAndVerify(candidate: [UInt8]) throws -> GateECBORProjectionResult {
        var decoder = AuthorityCandidateDecoder(bytes: candidate)
        let model = try decoder.decodeCandidate()
        let canonicalCandidate = AuthorityCandidateEncoder.encode(model)
        guard canonicalCandidate == candidate else {
            throw GateECBORAuthorityError.nonCanonicalCBOR
        }

        let projection = try AuthorityGraphProjector.project(model)
        let verifierReceipt = try AuthorityCanonicalJSON.encode(.object([
            ("candidate_sha256", .string(AuthorityHash.hex(AuthorityHash.sha256(candidate)))),
            ("graph_frame_sha256", .string(AuthorityHash.hex(AuthorityHash.sha256(projection.graphFrame)))),
            ("graph_merkle_root", .string(projection.graphMerkleRoot)),
            ("result", .string("PASS")),
            ("schema", .string(GateECBORStaticSchema.verifierReceiptSchema)),
            ("semantic_root", .string(projection.semanticRoot)),
            ("source_authority", .string("CBOR")),
        ]))

        return GateECBORProjectionResult(
            verifierReceipt: verifierReceipt,
            graphFrame: projection.graphFrame
        )
    }
}

private struct AuthorityCandidateDecoder {
    private static let maximumCandidateBytes = 4 * 1_024 * 1_024
    private static let maximumStringBytes = 4 * 1_024 * 1_024
    private static let maximumArrayEntries = 65_536

    let bytes: [UInt8]
    private var offset = 0

    init(bytes: [UInt8]) {
        self.bytes = bytes
    }

    mutating func decodeCandidate() throws -> GateECBORCandidateModel {
        guard !bytes.isEmpty, bytes.count <= Self.maximumCandidateBytes else {
            throw GateECBORAuthorityError.candidateTooLarge
        }
        guard try readArgument(major: 5) == 8 else {
            throw GateECBORAuthorityError.invalidCandidate
        }

        // These one-byte canonical key encodings must occur in complete
        // encoded-key unsigned-byte lexicographic order: 00 through 07.
        try expectKey(0)
        let schema = try readText()
        try expectKey(1)
        let sourceCommit = try readText()
        try expectKey(2)
        let sourceTree = try readText()
        try expectKey(3)
        let sourceIdentity = try readText()
        try expectKey(4)
        let authorityVector = try readByteString()
        try expectKey(5)
        let gateState = try readText()
        try expectKey(6)
        let roles = try readTextArray()
        try expectKey(7)
        let predicates = try readTextArray()

        guard offset == bytes.count else {
            throw GateECBORAuthorityError.nonCanonicalCBOR
        }
        guard schema == GateECBORStaticSchema.candidateSchema,
              AuthorityCandidateValidation.isLowerHex(sourceCommit, count: 40),
              AuthorityCandidateValidation.isLowerHex(sourceTree, count: 40),
              AuthorityCandidateValidation.isLowerHex(sourceIdentity, count: 64),
              authorityVector == [0],
              gateState == "ABSTAIN",
              roles == GateECBORStaticSchema.roles,
              predicates == GateECBORStaticSchema.predicates
        else {
            throw GateECBORAuthorityError.invalidCandidate
        }

        return GateECBORCandidateModel(
            sourceCommit: sourceCommit,
            sourceTree: sourceTree,
            sourceIdentity: sourceIdentity,
            authorityVector: authorityVector,
            gateState: gateState,
            roles: roles,
            predicates: predicates
        )
    }

    private mutating func expectKey(_ expected: UInt64) throws {
        guard try readArgument(major: 0) == expected else {
            throw GateECBORAuthorityError.invalidCandidate
        }
    }

    private mutating func readByteString() throws -> [UInt8] {
        let length = try boundedLength(try readArgument(major: 2), maximum: Self.maximumStringBytes)
        return try readBytes(count: length)
    }

    private mutating func readText() throws -> String {
        let length = try boundedLength(try readArgument(major: 3), maximum: Self.maximumStringBytes)
        let encoded = try readBytes(count: length)
        guard let value = String(data: Data(encoded), encoding: .utf8),
              Array(value.utf8) == encoded
        else {
            throw GateECBORAuthorityError.malformedCBOR
        }
        return value
    }

    private mutating func readTextArray() throws -> [String] {
        let count = try boundedLength(try readArgument(major: 4), maximum: Self.maximumArrayEntries)
        var values: [String] = []
        values.reserveCapacity(count)
        for _ in 0..<count {
            values.append(try readText())
        }
        return values
    }

    private mutating func boundedLength(_ value: UInt64, maximum: Int) throws -> Int {
        guard value <= UInt64(maximum), value <= UInt64(Int.max) else {
            throw GateECBORAuthorityError.malformedCBOR
        }
        return Int(value)
    }

    private mutating func readArgument(major expectedMajor: UInt8) throws -> UInt64 {
        let initial = try readByte()
        let major = initial >> 5
        let additional = initial & 0x1f
        guard major == expectedMajor else {
            throw GateECBORAuthorityError.malformedCBOR
        }

        switch additional {
        case 0...23:
            return UInt64(additional)
        case 24:
            let value = UInt64(try readByte())
            guard value >= 24 else { throw GateECBORAuthorityError.nonCanonicalCBOR }
            return value
        case 25:
            let value = try readBigEndian(count: 2)
            guard value > UInt64(UInt8.max) else { throw GateECBORAuthorityError.nonCanonicalCBOR }
            return value
        case 26:
            let value = try readBigEndian(count: 4)
            guard value > UInt64(UInt16.max) else { throw GateECBORAuthorityError.nonCanonicalCBOR }
            return value
        case 27:
            let value = try readBigEndian(count: 8)
            guard value > UInt64(UInt32.max) else { throw GateECBORAuthorityError.nonCanonicalCBOR }
            return value
        default:
            throw GateECBORAuthorityError.malformedCBOR
        }
    }

    private mutating func readBigEndian(count: Int) throws -> UInt64 {
        var result: UInt64 = 0
        for _ in 0..<count {
            result = (result << 8) | UInt64(try readByte())
        }
        return result
    }

    private mutating func readBytes(count: Int) throws -> [UInt8] {
        guard count >= 0, count <= bytes.count - offset else {
            throw GateECBORAuthorityError.malformedCBOR
        }
        let end = offset + count
        let result = Array(bytes[offset..<end])
        offset = end
        return result
    }

    private mutating func readByte() throws -> UInt8 {
        guard offset < bytes.count else {
            throw GateECBORAuthorityError.malformedCBOR
        }
        defer { offset += 1 }
        return bytes[offset]
    }
}

private enum AuthorityCandidateValidation {
    static func isLowerHex(_ value: String, count: Int) -> Bool {
        let encoded = Array(value.utf8)
        guard encoded.count == count else { return false }
        return encoded.allSatisfy { byte in
            (48...57).contains(byte) || (97...102).contains(byte)
        }
    }
}

private enum AuthorityCandidateEncoder {
    static func encode(_ model: GateECBORCandidateModel) -> [UInt8] {
        var output: [UInt8] = []
        appendHead(major: 5, value: 8, to: &output)
        appendUnsigned(0, to: &output)
        appendText(GateECBORStaticSchema.candidateSchema, to: &output)
        appendUnsigned(1, to: &output)
        appendText(model.sourceCommit, to: &output)
        appendUnsigned(2, to: &output)
        appendText(model.sourceTree, to: &output)
        appendUnsigned(3, to: &output)
        appendText(model.sourceIdentity, to: &output)
        appendUnsigned(4, to: &output)
        appendBytes(model.authorityVector, to: &output)
        appendUnsigned(5, to: &output)
        appendText(model.gateState, to: &output)
        appendUnsigned(6, to: &output)
        appendTextArray(model.roles, to: &output)
        appendUnsigned(7, to: &output)
        appendTextArray(model.predicates, to: &output)
        return output
    }

    private static func appendUnsigned(_ value: UInt64, to output: inout [UInt8]) {
        appendHead(major: 0, value: value, to: &output)
    }

    private static func appendBytes(_ value: [UInt8], to output: inout [UInt8]) {
        appendHead(major: 2, value: UInt64(value.count), to: &output)
        output.append(contentsOf: value)
    }

    private static func appendText(_ value: String, to output: inout [UInt8]) {
        let encoded = Array(value.utf8)
        appendHead(major: 3, value: UInt64(encoded.count), to: &output)
        output.append(contentsOf: encoded)
    }

    private static func appendTextArray(_ values: [String], to output: inout [UInt8]) {
        appendHead(major: 4, value: UInt64(values.count), to: &output)
        for value in values {
            appendText(value, to: &output)
        }
    }

    private static func appendHead(major: UInt8, value: UInt64, to output: inout [UInt8]) {
        let prefix = major << 5
        switch value {
        case 0...23:
            output.append(prefix | UInt8(value))
        case 24...UInt64(UInt8.max):
            output.append(prefix | 24)
            output.append(UInt8(value))
        case 256...UInt64(UInt16.max):
            output.append(prefix | 25)
            AuthorityBytes.appendBigEndian(value, byteCount: 2, to: &output)
        case 65_536...UInt64(UInt32.max):
            output.append(prefix | 26)
            AuthorityBytes.appendBigEndian(value, byteCount: 4, to: &output)
        default:
            output.append(prefix | 27)
            AuthorityBytes.appendBigEndian(value, byteCount: 8, to: &output)
        }
    }
}

private indirect enum AuthorityJSONValue {
    case null
    case string(String)
    case unsigned(UInt64)
    case array([AuthorityJSONValue])
    case object([(String, AuthorityJSONValue)])
}

private enum AuthorityCanonicalJSON {
    static func encode(_ value: AuthorityJSONValue) throws -> [UInt8] {
        var output: [UInt8] = []
        try append(value, to: &output)
        return output
    }

    private static func append(_ value: AuthorityJSONValue, to output: inout [UInt8]) throws {
        switch value {
        case .null:
            output.append(contentsOf: Array("null".utf8))
        case .string(let string):
            appendString(string, to: &output)
        case .unsigned(let number):
            output.append(contentsOf: Array(String(number).utf8))
        case .array(let values):
            output.append(91)
            for index in values.indices {
                if index != values.startIndex { output.append(44) }
                try append(values[index], to: &output)
            }
            output.append(93)
        case .object(let members):
            let sorted = members.sorted { lhs, rhs in
                AuthorityBytes.lexicographicallyPrecedes(Array(lhs.0.utf8), Array(rhs.0.utf8))
            }
            if sorted.count > 1 {
                for index in 1..<sorted.count {
                    guard Array(sorted[index - 1].0.utf8) != Array(sorted[index].0.utf8) else {
                        throw GateECBORAuthorityError.invalidGraphFrame
                    }
                }
            }
            output.append(123)
            for index in sorted.indices {
                if index != sorted.startIndex { output.append(44) }
                appendString(sorted[index].0, to: &output)
                output.append(58)
                try append(sorted[index].1, to: &output)
            }
            output.append(125)
        }
    }

    private static func appendString(_ value: String, to output: inout [UInt8]) {
        output.append(34)
        for byte in value.utf8 {
            switch byte {
            case 34:
                output.append(contentsOf: [92, 34])
            case 92:
                output.append(contentsOf: [92, 92])
            case 8:
                output.append(contentsOf: [92, 98])
            case 9:
                output.append(contentsOf: [92, 116])
            case 10:
                output.append(contentsOf: [92, 110])
            case 12:
                output.append(contentsOf: [92, 102])
            case 13:
                output.append(contentsOf: [92, 114])
            case 0...31:
                output.append(contentsOf: [92, 117, 48, 48])
                output.append(AuthorityBytes.hexDigit(byte >> 4))
                output.append(AuthorityBytes.hexDigit(byte & 0x0f))
            default:
                output.append(byte)
            }
        }
        output.append(34)
    }
}

private struct AuthorityGraphProjection {
    let graphFrame: [UInt8]
    let graphMerkleRoot: String
    let semanticRoot: String
}

private struct AuthorityFact {
    let body: AuthorityJSONValue
    let id: String
    let subtype: String

    var row: AuthorityJSONValue {
        .object([
            ("body", body),
            ("id", .string(id)),
            ("partition", .string("FACT")),
            ("subtype", .string(subtype)),
        ])
    }
}

private struct AuthorityRelation {
    let body: AuthorityJSONValue
    let id: String

    var row: AuthorityJSONValue {
        .object([
            ("body", body),
            ("id", .string(id)),
            ("partition", .string("RELATION")),
            ("subtype", .string("TRANSITION")),
        ])
    }
}

private struct AuthorityEdge {
    let id: String
    let ordinal: UInt64
    let role: String
    let sourceID: String
    let targetID: String

    var row: AuthorityJSONValue {
        .object([
            ("id", .string(id)),
            ("ordinal", .unsigned(ordinal)),
            ("role", .string(role)),
            ("source_id", .string(sourceID)),
            ("target_id", .string(targetID)),
        ])
    }
}

private enum AuthorityGraphProjector {
    static func project(_ model: GateECBORCandidateModel) throws -> AuthorityGraphProjection {
        let logicalModel = AuthorityJSONValue.object([
            ("authority_vector", .string("00000000")),
            ("gate_state", .string(model.gateState)),
            ("predicates", .array(model.predicates.map(AuthorityJSONValue.string))),
            ("roles", .array(model.roles.map(AuthorityJSONValue.string))),
            ("schema", .string(GateECBORStaticSchema.candidateSchema)),
            ("source_commit", .string(model.sourceCommit)),
            ("source_identity", .string(model.sourceIdentity)),
            ("source_tree", .string(model.sourceTree)),
        ])
        let logicalBytes = try AuthorityCanonicalJSON.encode(logicalModel)
        let semanticRoot = AuthorityHash.hex(AuthorityHash.domainHash(
            GateECBORStaticSchema.semanticDomain,
            fields: [logicalBytes]
        ))

        let preBody = AuthorityJSONValue.object([
            ("authority_vector", .string("00000000")),
            ("gate_state", .string(model.gateState)),
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
            ("roles", .array(model.roles.map(AuthorityJSONValue.string))),
        ]))
        let predicates = try fact(subtype: "WITNESS", body: .object([
            ("kind", .string("PREDICATE_SET")),
            ("predicates", .array(model.predicates.map(AuthorityJSONValue.string))),
        ]))
        let vector = try fact(subtype: "WITNESS", body: .object([
            ("authority_vector", .string("00000000")),
            ("gate_state", .string(model.gateState)),
            ("kind", .string("AUTHORITY_PRESTATE")),
        ]))
        let witnesses = [source, roles, predicates, vector]

        let relationBody = AuthorityJSONValue.object([
            ("from_state_id", .string(pre.id)),
            ("predicate", .string("CANDIDATE_SCHEMA_ROLE_PREDICATE_AND_PRESTATE_EXACT")),
            ("result", .string("PROVED")),
            ("witness_ids", .array(witnesses.map { .string($0.id) })),
        ])
        let relationBodyBytes = try AuthorityCanonicalJSON.encode(relationBody)
        let relation = AuthorityRelation(
            body: relationBody,
            id: AuthorityHash.hex(AuthorityHash.domainHash(
                GateECBORStaticSchema.relationDomain,
                fields: [relationBodyBytes]
            ))
        )

        let post = try fact(subtype: "STATE", body: .object([
            ("authority_vector", .string("00000000")),
            ("gate_state", .string(model.gateState)),
            ("predecessor_state_id_or_null", .string(pre.id)),
            ("prior_transition_id_or_null", .string(relation.id)),
            ("state_class", .string("STATIC_READY")),
        ]))

        var edges: [AuthorityEdge] = []
        edges.append(edge(
            role: "STATE_FACT_TO_TRANSITION_RELATION_FROM",
            sourceID: pre.id,
            targetID: relation.id,
            ordinal: 0
        ))
        for (ordinal, witness) in witnesses.enumerated() {
            edges.append(edge(
                role: "WITNESS_FACT_TO_TRANSITION_RELATION_WITNESS",
                sourceID: witness.id,
                targetID: relation.id,
                ordinal: UInt64(ordinal)
            ))
        }
        edges.append(edge(
            role: "TRANSITION_RELATION_TO_STATE_FACT_TO",
            sourceID: relation.id,
            targetID: post.id,
            ordinal: 0
        ))

        let sortedFacts = try sortRows([pre] + witnesses + [post], row: { $0.row })
        let sortedRelations = try sortRows([relation], row: { $0.row })
        let sortedEdges = try sortRows(edges, row: { $0.row })
        var allRows = try sortedFacts.map { try AuthorityCanonicalJSON.encode($0.row) }
        allRows.append(contentsOf: try sortedRelations.map { try AuthorityCanonicalJSON.encode($0.row) })
        allRows.append(contentsOf: try sortedEdges.map { try AuthorityCanonicalJSON.encode($0.row) })
        allRows.sort(by: AuthorityBytes.lexicographicallyPrecedes)
        let graphMerkleRoot = AuthorityHash.hex(merkleRoot(rows: allRows))

        let graph = AuthorityJSONValue.object([
            ("authority_vector_expectation", .string("00000000")),
            ("edges", .array(sortedEdges.map(\.row))),
            ("facts", .array(sortedFacts.map(\.row))),
            ("gate_state", .string(model.gateState)),
            ("graph_merkle_root", .string(graphMerkleRoot)),
            ("relations", .array(sortedRelations.map(\.row))),
            ("schema", .string(GateECBORStaticSchema.graphSchema)),
            ("semantic_root", .string(semanticRoot)),
        ])
        return AuthorityGraphProjection(
            graphFrame: try AuthorityCanonicalJSON.encode(graph),
            graphMerkleRoot: graphMerkleRoot,
            semanticRoot: semanticRoot
        )
    }

    private static func fact(subtype: String, body: AuthorityJSONValue) throws -> AuthorityFact {
        let bodyBytes = try AuthorityCanonicalJSON.encode(body)
        let identifier = AuthorityHash.hex(AuthorityHash.domainHash(
            GateECBORStaticSchema.factDomain,
            fields: [Array(subtype.utf8), bodyBytes]
        ))
        return AuthorityFact(body: body, id: identifier, subtype: subtype)
    }

    private static func edge(
        role: String,
        sourceID: String,
        targetID: String,
        ordinal: UInt64
    ) -> AuthorityEdge {
        let identifier = AuthorityHash.hex(AuthorityHash.domainHash(
            GateECBORStaticSchema.edgeDomain,
            fields: [
                Array(role.utf8),
                Array(sourceID.utf8),
                Array(targetID.utf8),
                Array(String(ordinal).utf8),
            ]
        ))
        return AuthorityEdge(
            id: identifier,
            ordinal: ordinal,
            role: role,
            sourceID: sourceID,
            targetID: targetID
        )
    }

    private static func sortRows<T>(
        _ values: [T],
        row: (T) -> AuthorityJSONValue
    ) throws -> [T] {
        var encoded: [(value: T, bytes: [UInt8])] = []
        encoded.reserveCapacity(values.count)
        for value in values {
            encoded.append((value, try AuthorityCanonicalJSON.encode(row(value))))
        }
        encoded.sort { AuthorityBytes.lexicographicallyPrecedes($0.bytes, $1.bytes) }
        return encoded.map(\.value)
    }

    private static func merkleRoot(rows: [[UInt8]]) -> [UInt8] {
        guard !rows.isEmpty else {
            return AuthorityHash.domainHash(GateECBORStaticSchema.merkleEmptyDomain, fields: [])
        }
        var level = rows.map {
            AuthorityHash.domainHash(GateECBORStaticSchema.merkleLeafDomain, fields: [$0])
        }
        while level.count > 1 {
            var next: [[UInt8]] = []
            next.reserveCapacity((level.count + 1) / 2)
            var index = 0
            while index < level.count {
                let left = level[index]
                let right = index + 1 < level.count ? level[index + 1] : left
                next.append(AuthorityHash.domainHash(
                    GateECBORStaticSchema.merkleNodeDomain,
                    fields: [left, right]
                ))
                index += 2
            }
            level = next
        }
        return level[0]
    }
}

private enum AuthorityHash {
    static func sha256(_ bytes: [UInt8]) -> [UInt8] {
        Array(SHA256.hash(data: Data(bytes)))
    }

    static func domainHash(_ domain: String, fields: [[UInt8]]) -> [UInt8] {
        var preimage = Array(domain.utf8)
        preimage.append(0)
        for field in fields {
            AuthorityBytes.appendBigEndian(UInt64(field.count), byteCount: 8, to: &preimage)
            preimage.append(contentsOf: field)
        }
        return sha256(preimage)
    }

    static func hex(_ bytes: [UInt8]) -> String {
        var output: [UInt8] = []
        output.reserveCapacity(bytes.count * 2)
        for byte in bytes {
            output.append(AuthorityBytes.hexDigit(byte >> 4))
            output.append(AuthorityBytes.hexDigit(byte & 0x0f))
        }
        return String(decoding: output, as: UTF8.self)
    }
}

private enum AuthorityBytes {
    static func appendBigEndian(_ value: UInt64, byteCount: Int, to output: inout [UInt8]) {
        for shift in stride(from: (byteCount - 1) * 8, through: 0, by: -8) {
            output.append(UInt8((value >> UInt64(shift)) & 0xff))
        }
    }

    static func lexicographicallyPrecedes(_ lhs: [UInt8], _ rhs: [UInt8]) -> Bool {
        let sharedCount = min(lhs.count, rhs.count)
        for index in 0..<sharedCount {
            if lhs[index] != rhs[index] { return lhs[index] < rhs[index] }
        }
        return lhs.count < rhs.count
    }

    static func hexDigit(_ nibble: UInt8) -> UInt8 {
        nibble < 10 ? 48 + nibble : 87 + nibble
    }
}
