import CryptoKit
import Foundation

public enum GateECBORReconstructor {
    public static func reconstructAndReceipt(
        candidate: [UInt8],
        graphFrame: [UInt8]
    ) throws -> [UInt8] {
        var candidateReader = ReconstructionCandidateReader(input: candidate)
        let original = try candidateReader.read()
        guard ReconstructionCandidateWriter.write(original) == candidate else {
            throw GateECBORAuthorityError.nonCanonicalCBOR
        }

        let reconstructed = try ReconstructionGraphExtractor.extract(from: graphFrame)
        guard reconstructed == original else {
            throw GateECBORAuthorityError.reconstructionMismatch
        }
        let reconstructedCandidate = ReconstructionCandidateWriter.write(reconstructed)
        guard reconstructedCandidate == candidate else {
            throw GateECBORAuthorityError.reconstructionMismatch
        }

        let originalProjection = try ReconstructionGraphBuilder.build(original)
        let reconstructedProjection = try ReconstructionGraphBuilder.build(reconstructed)
        guard originalProjection.frame == graphFrame,
              reconstructedProjection.frame == graphFrame,
              originalProjection.semanticRoot == reconstructedProjection.semanticRoot,
              originalProjection.merkleRoot == reconstructedProjection.merkleRoot
        else {
            throw GateECBORAuthorityError.reconstructionMismatch
        }

        return try ReconstructionJSONEncoder.encode(.object([
            ("candidate_sha256", .string(ReconstructionDigest.hex(ReconstructionDigest.sha256(candidate)))),
            ("graph_frame_sha256", .string(ReconstructionDigest.hex(ReconstructionDigest.sha256(graphFrame)))),
            ("graph_merkle_root", .string(originalProjection.merkleRoot)),
            ("original_semantic_root", .string(originalProjection.semanticRoot)),
            ("reconstructed_candidate_sha256", .string(ReconstructionDigest.hex(ReconstructionDigest.sha256(reconstructedCandidate)))),
            ("reconstructed_graph_frame_sha256", .string(ReconstructionDigest.hex(ReconstructionDigest.sha256(reconstructedProjection.frame)))),
            ("reconstructed_semantic_root", .string(reconstructedProjection.semanticRoot)),
            ("result", .string("PASS")),
            ("schema", .string(GateECBORStaticSchema.roundTripReceiptSchema)),
            ("source_authority", .string("CBOR")),
        ]))
    }
}

private struct ReconstructionModel: Equatable {
    let sourceCommit: String
    let sourceTree: String
    let sourceIdentity: String
    let authorityVector: [UInt8]
    let gateState: String
    let roles: [String]
    let predicates: [String]
}

private struct ReconstructionCandidateReader {
    private static let maximumCandidateBytes = 4 * 1_024 * 1_024
    private static let maximumValueBytes = 4 * 1_024 * 1_024
    private static let maximumArrayEntries = 65_536

    let input: [UInt8]
    private var cursor = 0

    init(input: [UInt8]) {
        self.input = input
    }

    mutating func read() throws -> ReconstructionModel {
        guard !input.isEmpty, input.count <= Self.maximumCandidateBytes else {
            throw GateECBORAuthorityError.candidateTooLarge
        }
        guard try argument(requiredMajor: 5) == 8 else {
            throw GateECBORAuthorityError.invalidCandidate
        }

        // Recheck complete encoded-key unsigned-byte ordering independently.
        // For this closed map, the canonical key encodings are 00 through 07.
        try key(0)
        let schema = try text()
        try key(1)
        let commit = try text()
        try key(2)
        let tree = try text()
        try key(3)
        let identity = try text()
        try key(4)
        let vector = try byteString()
        try key(5)
        let gate = try text()
        try key(6)
        let roles = try textList()
        try key(7)
        let predicates = try textList()

        guard cursor == input.count else {
            throw GateECBORAuthorityError.nonCanonicalCBOR
        }
        let model = ReconstructionModel(
            sourceCommit: commit,
            sourceTree: tree,
            sourceIdentity: identity,
            authorityVector: vector,
            gateState: gate,
            roles: roles,
            predicates: predicates
        )
        guard schema == GateECBORStaticSchema.candidateSchema,
              ReconstructionValidation.accepts(model)
        else {
            throw GateECBORAuthorityError.invalidCandidate
        }
        return model
    }

    private mutating func key(_ expected: UInt64) throws {
        guard try argument(requiredMajor: 0) == expected else {
            throw GateECBORAuthorityError.invalidCandidate
        }
    }

    private mutating func byteString() throws -> [UInt8] {
        let count = try checkedCount(try argument(requiredMajor: 2), limit: Self.maximumValueBytes)
        return try take(count)
    }

    private mutating func text() throws -> String {
        let count = try checkedCount(try argument(requiredMajor: 3), limit: Self.maximumValueBytes)
        let encoded = try take(count)
        guard let decoded = String(data: Data(encoded), encoding: .utf8),
              Array(decoded.utf8) == encoded
        else {
            throw GateECBORAuthorityError.malformedCBOR
        }
        return decoded
    }

    private mutating func textList() throws -> [String] {
        let count = try checkedCount(try argument(requiredMajor: 4), limit: Self.maximumArrayEntries)
        var result: [String] = []
        result.reserveCapacity(count)
        for _ in 0..<count {
            result.append(try text())
        }
        return result
    }

    private mutating func argument(requiredMajor: UInt8) throws -> UInt64 {
        let head = try next()
        guard head >> 5 == requiredMajor else {
            throw GateECBORAuthorityError.malformedCBOR
        }
        switch head & 31 {
        case 0...23:
            return UInt64(head & 31)
        case 24:
            let result = UInt64(try next())
            guard result >= 24 else { throw GateECBORAuthorityError.nonCanonicalCBOR }
            return result
        case 25:
            let result = try integer(byteCount: 2)
            guard result >= 256 else { throw GateECBORAuthorityError.nonCanonicalCBOR }
            return result
        case 26:
            let result = try integer(byteCount: 4)
            guard result >= 65_536 else { throw GateECBORAuthorityError.nonCanonicalCBOR }
            return result
        case 27:
            let result = try integer(byteCount: 8)
            guard result >= 4_294_967_296 else { throw GateECBORAuthorityError.nonCanonicalCBOR }
            return result
        default:
            throw GateECBORAuthorityError.malformedCBOR
        }
    }

    private mutating func integer(byteCount: Int) throws -> UInt64 {
        var result: UInt64 = 0
        for _ in 0..<byteCount {
            result = result << 8 | UInt64(try next())
        }
        return result
    }

    private mutating func checkedCount(_ value: UInt64, limit: Int) throws -> Int {
        guard value <= UInt64(limit), value <= UInt64(Int.max) else {
            throw GateECBORAuthorityError.malformedCBOR
        }
        return Int(value)
    }

    private mutating func take(_ count: Int) throws -> [UInt8] {
        guard count >= 0, count <= input.count - cursor else {
            throw GateECBORAuthorityError.malformedCBOR
        }
        let end = cursor + count
        defer { cursor = end }
        return Array(input[cursor..<end])
    }

    private mutating func next() throws -> UInt8 {
        guard cursor < input.count else {
            throw GateECBORAuthorityError.malformedCBOR
        }
        defer { cursor += 1 }
        return input[cursor]
    }
}

private enum ReconstructionValidation {
    private static let exactRoles = [
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

    private static let exactPredicates = [
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

    static func accepts(_ model: ReconstructionModel) -> Bool {
        lowerHex(model.sourceCommit, count: 40)
            && lowerHex(model.sourceTree, count: 40)
            && lowerHex(model.sourceIdentity, count: 64)
            && model.authorityVector == [0]
            && model.gateState == "ABSTAIN"
            && model.roles == exactRoles
            && model.predicates == exactPredicates
    }

    private static func lowerHex(_ value: String, count: Int) -> Bool {
        let bytes = Array(value.utf8)
        return bytes.count == count && bytes.allSatisfy {
            (48...57).contains($0) || (97...102).contains($0)
        }
    }
}

private enum ReconstructionCandidateWriter {
    static func write(_ model: ReconstructionModel) -> [UInt8] {
        var result: [UInt8] = []
        head(major: 5, value: 8, into: &result)
        unsigned(0, into: &result)
        text(GateECBORStaticSchema.candidateSchema, into: &result)
        unsigned(1, into: &result)
        text(model.sourceCommit, into: &result)
        unsigned(2, into: &result)
        text(model.sourceTree, into: &result)
        unsigned(3, into: &result)
        text(model.sourceIdentity, into: &result)
        unsigned(4, into: &result)
        bytes(model.authorityVector, into: &result)
        unsigned(5, into: &result)
        text(model.gateState, into: &result)
        unsigned(6, into: &result)
        textList(model.roles, into: &result)
        unsigned(7, into: &result)
        textList(model.predicates, into: &result)
        return result
    }

    private static func unsigned(_ value: UInt64, into result: inout [UInt8]) {
        head(major: 0, value: value, into: &result)
    }

    private static func bytes(_ value: [UInt8], into result: inout [UInt8]) {
        head(major: 2, value: UInt64(value.count), into: &result)
        result.append(contentsOf: value)
    }

    private static func text(_ value: String, into result: inout [UInt8]) {
        let encoded = Array(value.utf8)
        head(major: 3, value: UInt64(encoded.count), into: &result)
        result.append(contentsOf: encoded)
    }

    private static func textList(_ values: [String], into result: inout [UInt8]) {
        head(major: 4, value: UInt64(values.count), into: &result)
        for value in values {
            text(value, into: &result)
        }
    }

    private static func head(major: UInt8, value: UInt64, into result: inout [UInt8]) {
        let prefix = major << 5
        if value < 24 {
            result.append(prefix | UInt8(value))
        } else if value <= UInt64(UInt8.max) {
            result.append(prefix | 24)
            result.append(UInt8(value))
        } else if value <= UInt64(UInt16.max) {
            result.append(prefix | 25)
            ReconstructionBytes.bigEndian(value, count: 2, into: &result)
        } else if value <= UInt64(UInt32.max) {
            result.append(prefix | 26)
            ReconstructionBytes.bigEndian(value, count: 4, into: &result)
        } else {
            result.append(prefix | 27)
            ReconstructionBytes.bigEndian(value, count: 8, into: &result)
        }
    }
}

private enum ReconstructionGraphExtractor {
    private static let maximumGraphBytes = 16 * 1_024 * 1_024

    static func extract(from graphFrame: [UInt8]) throws -> ReconstructionModel {
        guard !graphFrame.isEmpty,
              graphFrame.count <= maximumGraphBytes,
              !graphFrame.contains(10),
              !graphFrame.contains(13),
              let object = try JSONSerialization.jsonObject(
                  with: Data(graphFrame),
                  options: []
              ) as? [String: Any],
              exactKeys(object, [
                  "authority_vector_expectation",
                  "edges",
                  "facts",
                  "gate_state",
                  "graph_merkle_root",
                  "relations",
                  "schema",
                  "semantic_root",
              ]),
              object["authority_vector_expectation"] as? String == "00000000",
              object["gate_state"] as? String == "ABSTAIN",
              object["schema"] as? String == GateECBORStaticSchema.graphSchema,
              let facts = object["facts"] as? [Any]
        else {
            throw GateECBORAuthorityError.invalidGraphFrame
        }

        var source: (String, String, String)?
        var roles: [String]?
        var predicates: [String]?
        var prestate: (String, String)?

        for rawFact in facts {
            guard let fact = rawFact as? [String: Any],
                  exactKeys(fact, ["body", "id", "partition", "subtype"]),
                  fact["partition"] as? String == "FACT",
                  let subtype = fact["subtype"] as? String,
                  let body = fact["body"] as? [String: Any]
            else {
                throw GateECBORAuthorityError.invalidGraphFrame
            }
            if subtype == "STATE" {
                continue
            }
            guard subtype == "WITNESS", let kind = body["kind"] as? String else {
                throw GateECBORAuthorityError.invalidGraphFrame
            }
            switch kind {
            case "SOURCE_BINDING":
                guard source == nil,
                      exactKeys(body, ["kind", "source_commit", "source_identity", "source_tree"]),
                      let commit = body["source_commit"] as? String,
                      let identity = body["source_identity"] as? String,
                      let tree = body["source_tree"] as? String
                else { throw GateECBORAuthorityError.invalidGraphFrame }
                source = (commit, identity, tree)
            case "ROLE_ORDER":
                guard roles == nil,
                      exactKeys(body, ["kind", "roles"]),
                      let rawRoles = body["roles"] as? [Any]
                else { throw GateECBORAuthorityError.invalidGraphFrame }
                roles = try strings(rawRoles)
            case "PREDICATE_SET":
                guard predicates == nil,
                      exactKeys(body, ["kind", "predicates"]),
                      let rawPredicates = body["predicates"] as? [Any]
                else { throw GateECBORAuthorityError.invalidGraphFrame }
                predicates = try strings(rawPredicates)
            case "AUTHORITY_PRESTATE":
                guard prestate == nil,
                      exactKeys(body, ["authority_vector", "gate_state", "kind"]),
                      let vector = body["authority_vector"] as? String,
                      let gate = body["gate_state"] as? String
                else { throw GateECBORAuthorityError.invalidGraphFrame }
                prestate = (vector, gate)
            default:
                throw GateECBORAuthorityError.invalidGraphFrame
            }
        }

        guard facts.count == 6,
              let source,
              let roles,
              let predicates,
              let prestate,
              prestate.0 == "00000000",
              prestate.1 == "ABSTAIN"
        else {
            throw GateECBORAuthorityError.invalidGraphFrame
        }
        let model = ReconstructionModel(
            sourceCommit: source.0,
            sourceTree: source.2,
            sourceIdentity: source.1,
            authorityVector: [0],
            gateState: prestate.1,
            roles: roles,
            predicates: predicates
        )
        guard ReconstructionValidation.accepts(model) else {
            throw GateECBORAuthorityError.invalidGraphFrame
        }
        return model
    }

    private static func strings(_ values: [Any]) throws -> [String] {
        var result: [String] = []
        result.reserveCapacity(values.count)
        for value in values {
            guard let string = value as? String else {
                throw GateECBORAuthorityError.invalidGraphFrame
            }
            result.append(string)
        }
        return result
    }

    private static func exactKeys(_ object: [String: Any], _ keys: [String]) -> Bool {
        object.count == keys.count && Set(object.keys) == Set(keys)
    }
}

private indirect enum ReconstructionJSONValue {
    case null
    case string(String)
    case number(UInt64)
    case array([ReconstructionJSONValue])
    case object([(String, ReconstructionJSONValue)])
}

private enum ReconstructionJSONEncoder {
    static func encode(_ value: ReconstructionJSONValue) throws -> [UInt8] {
        var destination: [UInt8] = []
        try emit(value, into: &destination)
        return destination
    }

    private static func emit(_ value: ReconstructionJSONValue, into destination: inout [UInt8]) throws {
        switch value {
        case .null:
            destination.append(contentsOf: [110, 117, 108, 108])
        case .string(let string):
            quoted(string, into: &destination)
        case .number(let number):
            destination.append(contentsOf: Array(String(number).utf8))
        case .array(let elements):
            destination.append(91)
            for (index, element) in elements.enumerated() {
                if index > 0 { destination.append(44) }
                try emit(element, into: &destination)
            }
            destination.append(93)
        case .object(let unsorted):
            let members = unsorted.sorted {
                ReconstructionBytes.less(Array($0.0.utf8), Array($1.0.utf8))
            }
            if members.count > 1 {
                for index in 1..<members.count where members[index - 1].0 == members[index].0 {
                    throw GateECBORAuthorityError.invalidGraphFrame
                }
            }
            destination.append(123)
            for (index, member) in members.enumerated() {
                if index > 0 { destination.append(44) }
                quoted(member.0, into: &destination)
                destination.append(58)
                try emit(member.1, into: &destination)
            }
            destination.append(125)
        }
    }

    private static func quoted(_ string: String, into destination: inout [UInt8]) {
        destination.append(34)
        for byte in string.utf8 {
            switch byte {
            case 34: destination.append(contentsOf: [92, 34])
            case 92: destination.append(contentsOf: [92, 92])
            case 8: destination.append(contentsOf: [92, 98])
            case 9: destination.append(contentsOf: [92, 116])
            case 10: destination.append(contentsOf: [92, 110])
            case 12: destination.append(contentsOf: [92, 102])
            case 13: destination.append(contentsOf: [92, 114])
            case 0...31:
                destination.append(contentsOf: [92, 117, 48, 48])
                destination.append(ReconstructionBytes.hex(byte >> 4))
                destination.append(ReconstructionBytes.hex(byte & 15))
            default: destination.append(byte)
            }
        }
        destination.append(34)
    }
}

private struct ReconstructionFact {
    let body: ReconstructionJSONValue
    let id: String
    let subtype: String

    var row: ReconstructionJSONValue {
        .object([
            ("body", body),
            ("id", .string(id)),
            ("partition", .string("FACT")),
            ("subtype", .string(subtype)),
        ])
    }
}

private struct ReconstructionRelation {
    let body: ReconstructionJSONValue
    let id: String

    var row: ReconstructionJSONValue {
        .object([
            ("body", body),
            ("id", .string(id)),
            ("partition", .string("RELATION")),
            ("subtype", .string("TRANSITION")),
        ])
    }
}

private struct ReconstructionEdge {
    let id: String
    let ordinal: UInt64
    let role: String
    let source: String
    let target: String

    var row: ReconstructionJSONValue {
        .object([
            ("id", .string(id)),
            ("ordinal", .number(ordinal)),
            ("role", .string(role)),
            ("source_id", .string(source)),
            ("target_id", .string(target)),
        ])
    }
}

private struct ReconstructionProjection {
    let frame: [UInt8]
    let merkleRoot: String
    let semanticRoot: String
}

private enum ReconstructionGraphBuilder {
    static func build(_ model: ReconstructionModel) throws -> ReconstructionProjection {
        let logical = ReconstructionJSONValue.object([
            ("authority_vector", .string("00000000")),
            ("gate_state", .string(model.gateState)),
            ("predicates", .array(model.predicates.map(ReconstructionJSONValue.string))),
            ("roles", .array(model.roles.map(ReconstructionJSONValue.string))),
            ("schema", .string(GateECBORStaticSchema.candidateSchema)),
            ("source_commit", .string(model.sourceCommit)),
            ("source_identity", .string(model.sourceIdentity)),
            ("source_tree", .string(model.sourceTree)),
        ])
        let semanticBytes = try ReconstructionJSONEncoder.encode(logical)
        let semanticRoot = ReconstructionDigest.hex(ReconstructionDigest.domain(
            GateECBORStaticSchema.semanticDomain,
            fields: [semanticBytes]
        ))

        let input = try makeFact("STATE", .object([
            ("authority_vector", .string("00000000")),
            ("gate_state", .string(model.gateState)),
            ("predecessor_state_id_or_null", .null),
            ("prior_transition_id_or_null", .null),
            ("state_class", .string("STATIC_INPUT")),
        ]))
        let source = try makeFact("WITNESS", .object([
            ("kind", .string("SOURCE_BINDING")),
            ("source_commit", .string(model.sourceCommit)),
            ("source_identity", .string(model.sourceIdentity)),
            ("source_tree", .string(model.sourceTree)),
        ]))
        let roleOrder = try makeFact("WITNESS", .object([
            ("kind", .string("ROLE_ORDER")),
            ("roles", .array(model.roles.map(ReconstructionJSONValue.string))),
        ]))
        let predicateSet = try makeFact("WITNESS", .object([
            ("kind", .string("PREDICATE_SET")),
            ("predicates", .array(model.predicates.map(ReconstructionJSONValue.string))),
        ]))
        let authority = try makeFact("WITNESS", .object([
            ("authority_vector", .string("00000000")),
            ("gate_state", .string(model.gateState)),
            ("kind", .string("AUTHORITY_PRESTATE")),
        ]))
        let witnesses = [source, roleOrder, predicateSet, authority]

        let relationBody = ReconstructionJSONValue.object([
            ("from_state_id", .string(input.id)),
            ("predicate", .string("CANDIDATE_SCHEMA_ROLE_PREDICATE_AND_PRESTATE_EXACT")),
            ("result", .string("PROVED")),
            ("witness_ids", .array(witnesses.map { .string($0.id) })),
        ])
        let relationBytes = try ReconstructionJSONEncoder.encode(relationBody)
        let relation = ReconstructionRelation(
            body: relationBody,
            id: ReconstructionDigest.hex(ReconstructionDigest.domain(
                GateECBORStaticSchema.relationDomain,
                fields: [relationBytes]
            ))
        )
        let ready = try makeFact("STATE", .object([
            ("authority_vector", .string("00000000")),
            ("gate_state", .string(model.gateState)),
            ("predecessor_state_id_or_null", .string(input.id)),
            ("prior_transition_id_or_null", .string(relation.id)),
            ("state_class", .string("STATIC_READY")),
        ]))

        var edges: [ReconstructionEdge] = [makeEdge(
            "STATE_FACT_TO_TRANSITION_RELATION_FROM",
            input.id,
            relation.id,
            0
        )]
        for (ordinal, witness) in witnesses.enumerated() {
            edges.append(makeEdge(
                "WITNESS_FACT_TO_TRANSITION_RELATION_WITNESS",
                witness.id,
                relation.id,
                UInt64(ordinal)
            ))
        }
        edges.append(makeEdge(
            "TRANSITION_RELATION_TO_STATE_FACT_TO",
            relation.id,
            ready.id,
            0
        ))

        let facts = try sort([input] + witnesses + [ready], row: { $0.row })
        let relations = try sort([relation], row: { $0.row })
        let sortedEdges = try sort(edges, row: { $0.row })
        var rows = try facts.map { try ReconstructionJSONEncoder.encode($0.row) }
        rows.append(contentsOf: try relations.map { try ReconstructionJSONEncoder.encode($0.row) })
        rows.append(contentsOf: try sortedEdges.map { try ReconstructionJSONEncoder.encode($0.row) })
        rows.sort(by: ReconstructionBytes.less)
        let root = ReconstructionDigest.hex(merkle(rows))

        let frame = try ReconstructionJSONEncoder.encode(.object([
            ("authority_vector_expectation", .string("00000000")),
            ("edges", .array(sortedEdges.map(\.row))),
            ("facts", .array(facts.map(\.row))),
            ("gate_state", .string(model.gateState)),
            ("graph_merkle_root", .string(root)),
            ("relations", .array(relations.map(\.row))),
            ("schema", .string(GateECBORStaticSchema.graphSchema)),
            ("semantic_root", .string(semanticRoot)),
        ]))
        return ReconstructionProjection(frame: frame, merkleRoot: root, semanticRoot: semanticRoot)
    }

    private static func makeFact(
        _ subtype: String,
        _ body: ReconstructionJSONValue
    ) throws -> ReconstructionFact {
        let bytes = try ReconstructionJSONEncoder.encode(body)
        let id = ReconstructionDigest.hex(ReconstructionDigest.domain(
            GateECBORStaticSchema.factDomain,
            fields: [Array(subtype.utf8), bytes]
        ))
        return ReconstructionFact(body: body, id: id, subtype: subtype)
    }

    private static func makeEdge(
        _ role: String,
        _ source: String,
        _ target: String,
        _ ordinal: UInt64
    ) -> ReconstructionEdge {
        let id = ReconstructionDigest.hex(ReconstructionDigest.domain(
            GateECBORStaticSchema.edgeDomain,
            fields: [
                Array(role.utf8),
                Array(source.utf8),
                Array(target.utf8),
                Array(String(ordinal).utf8),
            ]
        ))
        return ReconstructionEdge(id: id, ordinal: ordinal, role: role, source: source, target: target)
    }

    private static func sort<T>(
        _ values: [T],
        row: (T) -> ReconstructionJSONValue
    ) throws -> [T] {
        var pairs: [(T, [UInt8])] = []
        for value in values {
            pairs.append((value, try ReconstructionJSONEncoder.encode(row(value))))
        }
        pairs.sort { ReconstructionBytes.less($0.1, $1.1) }
        return pairs.map(\.0)
    }

    private static func merkle(_ rows: [[UInt8]]) -> [UInt8] {
        guard !rows.isEmpty else {
            return ReconstructionDigest.domain(GateECBORStaticSchema.merkleEmptyDomain, fields: [])
        }
        var hashes = rows.map {
            ReconstructionDigest.domain(GateECBORStaticSchema.merkleLeafDomain, fields: [$0])
        }
        while hashes.count > 1 {
            var next: [[UInt8]] = []
            var index = 0
            while index < hashes.count {
                let left = hashes[index]
                let right = index + 1 < hashes.count ? hashes[index + 1] : left
                next.append(ReconstructionDigest.domain(
                    GateECBORStaticSchema.merkleNodeDomain,
                    fields: [left, right]
                ))
                index += 2
            }
            hashes = next
        }
        return hashes[0]
    }
}

private enum ReconstructionDigest {
    static func sha256(_ input: [UInt8]) -> [UInt8] {
        Array(SHA256.hash(data: Data(input)))
    }

    static func domain(_ name: String, fields: [[UInt8]]) -> [UInt8] {
        var input = Array(name.utf8)
        input.append(0)
        for field in fields {
            ReconstructionBytes.bigEndian(UInt64(field.count), count: 8, into: &input)
            input.append(contentsOf: field)
        }
        return sha256(input)
    }

    static func hex(_ input: [UInt8]) -> String {
        var result: [UInt8] = []
        result.reserveCapacity(input.count * 2)
        for byte in input {
            result.append(ReconstructionBytes.hex(byte >> 4))
            result.append(ReconstructionBytes.hex(byte & 15))
        }
        return String(decoding: result, as: UTF8.self)
    }
}

private enum ReconstructionBytes {
    static func bigEndian(_ value: UInt64, count: Int, into output: inout [UInt8]) {
        for position in stride(from: count - 1, through: 0, by: -1) {
            output.append(UInt8((value >> UInt64(position * 8)) & 255))
        }
    }

    static func less(_ lhs: [UInt8], _ rhs: [UInt8]) -> Bool {
        for index in 0..<min(lhs.count, rhs.count) {
            if lhs[index] != rhs[index] { return lhs[index] < rhs[index] }
        }
        return lhs.count < rhs.count
    }

    static func hex(_ nibble: UInt8) -> UInt8 {
        nibble < 10 ? nibble + 48 : nibble + 87
    }
}
