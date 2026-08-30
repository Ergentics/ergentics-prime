import CryptoKit
import Foundation

public enum GateEDualGraphJoinError: Error, Equatable, Sendable {
    case empty
    case size
    case syntax
    case duplicateKey
    case nonCanonical
    case schema
    case mismatch
    case graph
}

public struct GateEDualGraphJoinResult: Equatable, Sendable {
    public let joinReceipt: [UInt8]
    public let authoritativeGraph: [UInt8]

    public init(joinReceipt: [UInt8], authoritativeGraph: [UInt8]) {
        self.joinReceipt = joinReceipt
        self.authoritativeGraph = authoritativeGraph
    }
}

public enum GateEDualGraphJoin {
    private static let exactRoles = [
        "prime_head_pre", "prime_object_format", "prime_status_pre",
        "prime_tree_discovery", "prime_tree_replay", "prime_status_post",
        "prime_head_post", "companion_head_pre", "companion_object_format",
        "companion_status_pre", "companion_tree_discovery",
        "companion_tree_replay", "companion_status_post",
        "companion_head_post", "swift_version", "swift_target_info",
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

    public static func join(
        jsonGraph: [UInt8],
        jsonVerifier: [UInt8],
        jsonRoundTrip: [UInt8],
        cborGraph: [UInt8],
        cborVerifier: [UInt8],
        cborRoundTrip: [UInt8]
    ) throws -> GateEDualGraphJoinResult {
        guard jsonGraph == cborGraph else {
            throw GateEDualGraphJoinError.mismatch
        }
        let graph = try JoinCanonicalJSON.decodeCanonical(jsonGraph)
        let graphIdentity = try validateGraph(graph, bytes: jsonGraph)
        let jsonVerifierCandidate = try validateVerifier(
            jsonVerifier,
            authority: "JSON",
            graphSHA256: graphIdentity.frameSHA256,
            semanticRoot: graphIdentity.semanticRoot,
            graphRoot: graphIdentity.graphRoot
        )
        let cborVerifierCandidate = try validateVerifier(
            cborVerifier,
            authority: "CBOR",
            graphSHA256: graphIdentity.frameSHA256,
            semanticRoot: graphIdentity.semanticRoot,
            graphRoot: graphIdentity.graphRoot
        )
        let jsonRoundTripCandidate = try validateRoundTrip(
            jsonRoundTrip,
            authority: "JSON",
            graphSHA256: graphIdentity.frameSHA256,
            semanticRoot: graphIdentity.semanticRoot,
            graphRoot: graphIdentity.graphRoot
        )
        let cborRoundTripCandidate = try validateRoundTrip(
            cborRoundTrip,
            authority: "CBOR",
            graphSHA256: graphIdentity.frameSHA256,
            semanticRoot: graphIdentity.semanticRoot,
            graphRoot: graphIdentity.graphRoot
        )
        guard jsonVerifierCandidate == jsonRoundTripCandidate,
              cborVerifierCandidate == cborRoundTripCandidate
        else { throw GateEDualGraphJoinError.mismatch }

        let receipt: JoinJSONValue = .object([
            ("authority_vector", .string("00000000")),
            ("cbor_graph_frame_sha256", .string(graphIdentity.frameSHA256)),
            ("graph_merkle_root", .string(graphIdentity.graphRoot)),
            ("json_graph_frame_sha256", .string(graphIdentity.frameSHA256)),
            ("projection_write_mask", .string("00000000")),
            ("result", .string("PASS")),
            ("schema", .string("ergentics.gate-e.static.dual-graph-join-receipt.v1")),
            ("semantic_root", .string(graphIdentity.semanticRoot)),
        ])
        return GateEDualGraphJoinResult(
            joinReceipt: try JoinCanonicalJSON.encode(receipt),
            authoritativeGraph: jsonGraph
        )
    }

    private struct GraphIdentity {
        let frameSHA256: String
        let semanticRoot: String
        let graphRoot: String
    }

    private static func validateGraph(
        _ graph: JoinJSONValue,
        bytes: [UInt8]
    ) throws -> GraphIdentity {
        guard exactKeys(graph, [
            "authority_vector_expectation", "edges", "facts", "gate_state",
            "graph_merkle_root", "relations", "schema", "semantic_root",
        ]),
        string("schema", graph) == "ergentics.gate-e.static.graph-frame.v1",
        string("authority_vector_expectation", graph) == "00000000",
        string("gate_state", graph) == "ABSTAIN",
        let semanticRoot = string("semantic_root", graph),
        isHex(semanticRoot, count: 64),
        let statedGraphRoot = string("graph_merkle_root", graph),
        isHex(statedGraphRoot, count: 64),
        case .array(let facts)? = graph.field("facts"),
        case .array(let relations)? = graph.field("relations"),
        case .array(let edges)? = graph.field("edges"),
        facts.count == 6,
        relations.count == 1,
        edges.count == 6
        else { throw GateEDualGraphJoinError.graph }

        var factIDs: [String: String] = [:]
        var preStateID: String?
        var postStateID: String?
        var postStateBody: JoinJSONValue?
        var sourceWitnessID: String?
        var rolesWitnessID: String?
        var predicatesWitnessID: String?
        var vectorWitnessID: String?
        var sourceCommit: String?
        var sourceTree: String?
        var sourceIdentity: String?
        var allRows: [[UInt8]] = []
        let factRows = try facts.map { row -> [UInt8] in
            guard exactKeys(row, ["body", "id", "partition", "subtype"]),
                  string("partition", row) == "FACT",
                  let subtype = string("subtype", row),
                  subtype == "STATE" || subtype == "WITNESS",
                  let body = row.field("body"),
                  let id = string("id", row)
            else { throw GateEDualGraphJoinError.graph }
            let expected = JoinHash.hex(JoinHash.domain(
                "ERGENTICS-GATE-E-STATIC-FACT-V1",
                [Array(subtype.utf8), try JoinCanonicalJSON.encode(body)]
            ))
            guard id == expected, factIDs.updateValue(subtype, forKey: id) == nil
            else { throw GateEDualGraphJoinError.graph }
            if subtype == "STATE" {
                guard exactKeys(body, [
                    "authority_vector", "gate_state",
                    "predecessor_state_id_or_null", "prior_transition_id_or_null",
                    "state_class",
                ]),
                string("authority_vector", body) == "00000000",
                string("gate_state", body) == "ABSTAIN",
                let stateClass = string("state_class", body)
                else { throw GateEDualGraphJoinError.graph }
                switch stateClass {
                case "STATIC_INPUT":
                    guard preStateID == nil,
                          isNull("predecessor_state_id_or_null", body),
                          isNull("prior_transition_id_or_null", body)
                    else { throw GateEDualGraphJoinError.graph }
                    preStateID = id
                case "STATIC_READY":
                    guard postStateID == nil else {
                        throw GateEDualGraphJoinError.graph
                    }
                    postStateID = id
                    postStateBody = body
                default:
                    throw GateEDualGraphJoinError.graph
                }
            } else {
                guard let kind = string("kind", body) else {
                    throw GateEDualGraphJoinError.graph
                }
                switch kind {
                case "SOURCE_BINDING":
                    guard sourceWitnessID == nil,
                          exactKeys(body, [
                            "kind", "source_commit", "source_identity", "source_tree",
                          ]),
                          let commit = string("source_commit", body),
                          let tree = string("source_tree", body),
                          let identity = string("source_identity", body),
                          isHex(commit, count: 40), isHex(tree, count: 40),
                          isHex(identity, count: 64)
                    else { throw GateEDualGraphJoinError.graph }
                    sourceWitnessID = id
                    sourceCommit = commit
                    sourceTree = tree
                    sourceIdentity = identity
                case "ROLE_ORDER":
                    guard rolesWitnessID == nil,
                          exactKeys(body, ["kind", "roles"]),
                          strings("roles", body) == exactRoles
                    else { throw GateEDualGraphJoinError.graph }
                    rolesWitnessID = id
                case "PREDICATE_SET":
                    guard predicatesWitnessID == nil,
                          exactKeys(body, ["kind", "predicates"]),
                          strings("predicates", body) == exactPredicates
                    else { throw GateEDualGraphJoinError.graph }
                    predicatesWitnessID = id
                case "AUTHORITY_PRESTATE":
                    guard vectorWitnessID == nil,
                          exactKeys(body, ["authority_vector", "gate_state", "kind"]),
                          string("authority_vector", body) == "00000000",
                          string("gate_state", body) == "ABSTAIN"
                    else { throw GateEDualGraphJoinError.graph }
                    vectorWitnessID = id
                default:
                    throw GateEDualGraphJoinError.graph
                }
            }
            return try JoinCanonicalJSON.encode(row)
        }
        try requireStrictOrder(factRows)
        allRows.append(contentsOf: factRows)

        guard let preStateID, let postStateID, let postStateBody,
              let sourceWitnessID, let rolesWitnessID,
              let predicatesWitnessID, let vectorWitnessID,
              let sourceCommit, let sourceTree, let sourceIdentity
        else { throw GateEDualGraphJoinError.graph }
        let orderedWitnessIDs = [
            sourceWitnessID, rolesWitnessID, predicatesWitnessID, vectorWitnessID,
        ]

        var relationID: String?
        var relationIDs = Set<String>()
        let relationRows = try relations.map { row -> [UInt8] in
            guard exactKeys(row, ["body", "id", "partition", "subtype"]),
                  string("partition", row) == "RELATION",
                  string("subtype", row) == "TRANSITION",
                  let body = row.field("body"),
                  let id = string("id", row)
            else { throw GateEDualGraphJoinError.graph }
            let expected = JoinHash.hex(JoinHash.domain(
                "ERGENTICS-GATE-E-STATIC-RELATION-V1",
                [try JoinCanonicalJSON.encode(body)]
            ))
            guard id == expected, relationIDs.insert(id).inserted,
                  relationID == nil,
                  exactKeys(body, [
                    "from_state_id", "predicate", "result", "witness_ids",
                  ]),
                  string("from_state_id", body) == preStateID,
                  string("result", body) == "PROVED",
                  string("predicate", body)
                    == "CANDIDATE_SCHEMA_ROLE_PREDICATE_AND_PRESTATE_EXACT",
                  strings("witness_ids", body) == orderedWitnessIDs
            else { throw GateEDualGraphJoinError.graph }
            relationID = id
            return try JoinCanonicalJSON.encode(row)
        }
        try requireStrictOrder(relationRows)
        allRows.append(contentsOf: relationRows)
        guard let relationID,
              string("predecessor_state_id_or_null", postStateBody) == preStateID,
              string("prior_transition_id_or_null", postStateBody) == relationID
        else { throw GateEDualGraphJoinError.graph }

        var edgeIDs = Set<String>()
        var observedEdges = Set<String>()
        let edgeRows = try edges.map { row -> [UInt8] in
            guard exactKeys(row, ["id", "ordinal", "role", "source_id", "target_id"]),
                  let id = string("id", row),
                  let role = string("role", row),
                  let source = string("source_id", row),
                  let target = string("target_id", row),
                  let ordinal = unsigned("ordinal", row)
            else { throw GateEDualGraphJoinError.graph }
            let expected = JoinHash.hex(JoinHash.domain(
                "ERGENTICS-GATE-E-STATIC-EDGE-V1",
                [Array(role.utf8), Array(source.utf8), Array(target.utf8),
                 Array(String(ordinal).utf8)]
            ))
            guard id == expected, edgeIDs.insert(id).inserted else {
                throw GateEDualGraphJoinError.graph
            }
            let tuple = "\(role)\u{0}\(source)\u{0}\(target)\u{0}\(ordinal)"
            guard observedEdges.insert(tuple).inserted else {
                throw GateEDualGraphJoinError.graph
            }
            switch role {
            case "STATE_FACT_TO_TRANSITION_RELATION_FROM":
                guard factIDs[source] == "STATE", relationIDs.contains(target),
                      ordinal == 0 else { throw GateEDualGraphJoinError.graph }
            case "WITNESS_FACT_TO_TRANSITION_RELATION_WITNESS":
                guard factIDs[source] == "WITNESS", relationIDs.contains(target),
                      ordinal < 4 else { throw GateEDualGraphJoinError.graph }
            case "TRANSITION_RELATION_TO_STATE_FACT_TO":
                guard relationIDs.contains(source), factIDs[target] == "STATE",
                      ordinal == 0 else { throw GateEDualGraphJoinError.graph }
            default:
                throw GateEDualGraphJoinError.graph
            }
            return try JoinCanonicalJSON.encode(row)
        }
        try requireStrictOrder(edgeRows)
        let expectedEdges = Set(
            ["STATE_FACT_TO_TRANSITION_RELATION_FROM\u{0}\(preStateID)\u{0}\(relationID)\u{0}0"]
            + orderedWitnessIDs.enumerated().map {
                "WITNESS_FACT_TO_TRANSITION_RELATION_WITNESS\u{0}\($0.element)\u{0}\(relationID)\u{0}\($0.offset)"
            }
            + ["TRANSITION_RELATION_TO_STATE_FACT_TO\u{0}\(relationID)\u{0}\(postStateID)\u{0}0"]
        )
        guard observedEdges == expectedEdges else {
            throw GateEDualGraphJoinError.graph
        }
        allRows.append(contentsOf: edgeRows)
        let logicalModel: JoinJSONValue = .object([
            ("authority_vector", .string("00000000")),
            ("gate_state", .string("ABSTAIN")),
            ("predicates", .array(exactPredicates.map { .string($0) })),
            ("roles", .array(exactRoles.map { .string($0) })),
            ("schema", .string("ergentics.gate-e.static.candidate.v1")),
            ("source_commit", .string(sourceCommit)),
            ("source_identity", .string(sourceIdentity)),
            ("source_tree", .string(sourceTree)),
        ])
        let computedSemanticRoot = JoinHash.hex(JoinHash.domain(
            "ERGENTICS-GATE-E-STATIC-SEMANTIC-V1",
            [try JoinCanonicalJSON.encode(logicalModel)]
        ))
        guard computedSemanticRoot == semanticRoot else {
            throw GateEDualGraphJoinError.graph
        }
        allRows.sort { $0.lexicographicallyPrecedes($1) }
        let computedRoot = JoinHash.hex(merkle(allRows))
        guard computedRoot == statedGraphRoot else {
            throw GateEDualGraphJoinError.graph
        }
        return GraphIdentity(
            frameSHA256: JoinHash.sha256Hex(bytes),
            semanticRoot: semanticRoot,
            graphRoot: statedGraphRoot
        )
    }

    private static func validateVerifier(
        _ bytes: [UInt8],
        authority: String,
        graphSHA256: String,
        semanticRoot: String,
        graphRoot: String
    ) throws -> String {
        let value = try JoinCanonicalJSON.decodeCanonical(bytes)
        guard exactKeys(value, [
            "candidate_sha256", "graph_frame_sha256", "graph_merkle_root",
            "result", "schema", "semantic_root", "source_authority",
        ]),
        string("schema", value) == "ergentics.gate-e.static.verifier-receipt.v1",
        string("source_authority", value) == authority,
        string("result", value) == "PASS",
        string("graph_frame_sha256", value) == graphSHA256,
        string("semantic_root", value) == semanticRoot,
        string("graph_merkle_root", value) == graphRoot,
        let candidate = string("candidate_sha256", value), isHex(candidate, count: 64)
        else { throw GateEDualGraphJoinError.mismatch }
        return candidate
    }

    private static func validateRoundTrip(
        _ bytes: [UInt8],
        authority: String,
        graphSHA256: String,
        semanticRoot: String,
        graphRoot: String
    ) throws -> String {
        let value = try JoinCanonicalJSON.decodeCanonical(bytes)
        guard exactKeys(value, [
            "candidate_sha256", "graph_frame_sha256", "graph_merkle_root",
            "original_semantic_root", "reconstructed_candidate_sha256",
            "reconstructed_graph_frame_sha256", "reconstructed_semantic_root",
            "result", "schema", "source_authority",
        ]),
        string("schema", value) == "ergentics.gate-e.static.round-trip-receipt.v1",
        string("source_authority", value) == authority,
        string("result", value) == "PASS",
        string("candidate_sha256", value)
            == string("reconstructed_candidate_sha256", value),
        string("graph_frame_sha256", value) == graphSHA256,
        string("reconstructed_graph_frame_sha256", value) == graphSHA256,
        string("graph_merkle_root", value) == graphRoot,
        string("original_semantic_root", value) == semanticRoot,
        string("reconstructed_semantic_root", value) == semanticRoot
        else { throw GateEDualGraphJoinError.mismatch }
        guard let candidate = string("candidate_sha256", value) else {
            throw GateEDualGraphJoinError.mismatch
        }
        return candidate
    }

    private static func merkle(_ rows: [[UInt8]]) -> [UInt8] {
        guard !rows.isEmpty else {
            return JoinHash.domain("ERGENTICS-GATE-E-STATIC-MERKLE-EMPTY-V1", [])
        }
        var level = rows.map {
            JoinHash.domain("ERGENTICS-GATE-E-STATIC-MERKLE-LEAF-V1", [$0])
        }
        while level.count > 1 {
            var next: [[UInt8]] = []
            var index = 0
            while index < level.count {
                let right = index + 1 < level.count ? level[index + 1] : level[index]
                next.append(JoinHash.domain(
                    "ERGENTICS-GATE-E-STATIC-MERKLE-NODE-V1",
                    [level[index], right]
                ))
                index += 2
            }
            level = next
        }
        return level[0]
    }

    private static func requireStrictOrder(_ rows: [[UInt8]]) throws {
        for index in rows.indices.dropFirst() where
            !rows[index - 1].lexicographicallyPrecedes(rows[index])
        { throw GateEDualGraphJoinError.graph }
    }

    private static func exactKeys(_ value: JoinJSONValue, _ keys: [String]) -> Bool {
        guard case .object(let fields) = value else { return false }
        return Set(fields.map { $0.0 }) == Set(keys)
    }

    private static func string(_ name: String, _ value: JoinJSONValue) -> String? {
        guard case .string(let result)? = value.field(name) else { return nil }
        return result
    }

    private static func unsigned(_ name: String, _ value: JoinJSONValue) -> UInt64? {
        guard case .unsigned(let result)? = value.field(name) else { return nil }
        return result
    }

    private static func strings(_ name: String, _ value: JoinJSONValue) -> [String]? {
        guard case .array(let values)? = value.field(name) else { return nil }
        var result: [String] = []
        for value in values {
            guard case .string(let string) = value else { return nil }
            result.append(string)
        }
        return result
    }

    private static func isNull(_ name: String, _ value: JoinJSONValue) -> Bool {
        guard case .null? = value.field(name) else { return false }
        return true
    }

    private static func isHex(_ value: String, count: Int) -> Bool {
        value.utf8.count == count && value.utf8.allSatisfy {
            (0x30 ... 0x39).contains($0) || (0x61 ... 0x66).contains($0)
        }
    }
}

private indirect enum JoinJSONValue {
    case null
    case bool(Bool)
    case unsigned(UInt64)
    case string(String)
    case array([JoinJSONValue])
    case object([(String, JoinJSONValue)])

    func field(_ name: String) -> JoinJSONValue? {
        guard case .object(let fields) = self else { return nil }
        return fields.first(where: { $0.0 == name })?.1
    }
}

private enum JoinCanonicalJSON {
    static func decodeCanonical(_ bytes: [UInt8]) throws -> JoinJSONValue {
        guard !bytes.isEmpty else { throw GateEDualGraphJoinError.empty }
        guard bytes.count <= 16 * 1024 * 1024 else {
            throw GateEDualGraphJoinError.size
        }
        var parser = Parser(bytes)
        let value = try parser.document()
        guard parser.atEnd, try encode(value) == bytes else {
            throw GateEDualGraphJoinError.nonCanonical
        }
        return value
    }

    static func encode(_ value: JoinJSONValue) throws -> [UInt8] {
        var bytes: [UInt8] = []
        try append(value, to: &bytes)
        return bytes
    }

    private static func append(_ value: JoinJSONValue, to bytes: inout [UInt8]) throws {
        switch value {
        case .null: bytes.append(contentsOf: "null".utf8)
        case .bool(false): bytes.append(contentsOf: "false".utf8)
        case .bool(true): bytes.append(contentsOf: "true".utf8)
        case .unsigned(let number): bytes.append(contentsOf: String(number).utf8)
        case .string(let string): try appendString(string, to: &bytes)
        case .array(let values):
            bytes.append(0x5b)
            for index in values.indices {
                if index > values.startIndex { bytes.append(0x2c) }
                try append(values[index], to: &bytes)
            }
            bytes.append(0x5d)
        case .object(let fields):
            var seen = Set<String>()
            let ordered = try fields.map { field -> (String, JoinJSONValue) in
                guard seen.insert(field.0).inserted else {
                    throw GateEDualGraphJoinError.duplicateKey
                }
                return field
            }.sorted {
                Array($0.0.utf8).lexicographicallyPrecedes(Array($1.0.utf8))
            }
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

    private static func appendString(_ string: String, to bytes: inout [UInt8]) throws {
        guard !string.unicodeScalars.contains(where: { $0.value == 0 }) else {
            throw GateEDualGraphJoinError.schema
        }
        bytes.append(0x22)
        for byte in string.utf8 {
            switch byte {
            case 0x22: bytes.append(contentsOf: [0x5c, 0x22])
            case 0x5c: bytes.append(contentsOf: [0x5c, 0x5c])
            case 0x08: bytes.append(contentsOf: [0x5c, 0x62])
            case 0x0c: bytes.append(contentsOf: [0x5c, 0x66])
            case 0x0a: bytes.append(contentsOf: [0x5c, 0x6e])
            case 0x0d: bytes.append(contentsOf: [0x5c, 0x72])
            case 0x09: bytes.append(contentsOf: [0x5c, 0x74])
            case 0x00 ... 0x1f: throw GateEDualGraphJoinError.schema
            default: bytes.append(byte)
            }
        }
        bytes.append(0x22)
    }

    private struct Parser {
        let bytes: [UInt8]
        var offset = 0
        init(_ bytes: [UInt8]) { self.bytes = bytes }
        var atEnd: Bool { offset == bytes.count }

        mutating func document() throws -> JoinJSONValue {
            skipSpace()
            let result = try value(depth: 0)
            skipSpace()
            return result
        }

        mutating func value(depth: Int) throws -> JoinJSONValue {
            guard depth <= 64, let byte = peek() else {
                throw GateEDualGraphJoinError.syntax
            }
            switch byte {
            case 0x7b: return try object(depth + 1)
            case 0x5b: return try array(depth + 1)
            case 0x22: return .string(try string())
            case 0x74: try literal("true"); return .bool(true)
            case 0x66: try literal("false"); return .bool(false)
            case 0x6e: try literal("null"); return .null
            case 0x30 ... 0x39: return .unsigned(try number())
            default: throw GateEDualGraphJoinError.syntax
            }
        }

        mutating func object(_ depth: Int) throws -> JoinJSONValue {
            try consume(0x7b); skipSpace()
            if take(0x7d) { return .object([]) }
            var fields: [(String, JoinJSONValue)] = []
            var keys = Set<String>()
            while true {
                let key = try string()
                guard keys.insert(key).inserted else {
                    throw GateEDualGraphJoinError.duplicateKey
                }
                skipSpace(); try consume(0x3a); skipSpace()
                fields.append((key, try value(depth: depth)))
                skipSpace()
                if take(0x7d) { return .object(fields) }
                try consume(0x2c); skipSpace()
            }
        }

        mutating func array(_ depth: Int) throws -> JoinJSONValue {
            try consume(0x5b); skipSpace()
            if take(0x5d) { return .array([]) }
            var values: [JoinJSONValue] = []
            while true {
                values.append(try value(depth: depth)); skipSpace()
                if take(0x5d) { return .array(values) }
                try consume(0x2c); skipSpace()
            }
        }

        mutating func string() throws -> String {
            try consume(0x22)
            var output: [UInt8] = []
            while let byte = peek() {
                offset += 1
                if byte == 0x22 {
                    guard let string = String(bytes: output, encoding: .utf8),
                          !string.unicodeScalars.contains(where: { $0.value == 0 })
                    else { throw GateEDualGraphJoinError.syntax }
                    return string
                }
                if byte == 0x5c {
                    guard let escape = peek() else {
                        throw GateEDualGraphJoinError.syntax
                    }
                    offset += 1
                    switch escape {
                    case 0x22, 0x5c, 0x2f: output.append(escape)
                    case 0x62: output.append(0x08)
                    case 0x66: output.append(0x0c)
                    case 0x6e: output.append(0x0a)
                    case 0x72: output.append(0x0d)
                    case 0x74: output.append(0x09)
                    case 0x75:
                        let first = try quad()
                        let scalar: UInt32
                        if (0xd800 ... 0xdbff).contains(first) {
                            try consume(0x5c); try consume(0x75)
                            let second = try quad()
                            guard (0xdc00 ... 0xdfff).contains(second) else {
                                throw GateEDualGraphJoinError.syntax
                            }
                            scalar = 0x10000 + (UInt32(first - 0xd800) << 10)
                                + UInt32(second - 0xdc00)
                        } else {
                            guard !(0xdc00 ... 0xdfff).contains(first) else {
                                throw GateEDualGraphJoinError.syntax
                            }
                            scalar = UInt32(first)
                        }
                        guard let unicode = UnicodeScalar(scalar) else {
                            throw GateEDualGraphJoinError.syntax
                        }
                        output.append(contentsOf: String(unicode).utf8)
                    default: throw GateEDualGraphJoinError.syntax
                    }
                } else {
                    guard byte >= 0x20 else { throw GateEDualGraphJoinError.syntax }
                    output.append(byte)
                }
            }
            throw GateEDualGraphJoinError.syntax
        }

        mutating func number() throws -> UInt64 {
            let first = peek()
            var digits: [UInt8] = []
            while let byte = peek(), (0x30 ... 0x39).contains(byte) {
                digits.append(byte); offset += 1
            }
            guard !digits.isEmpty, !(first == 0x30 && digits.count > 1),
                  let value = UInt64(String(decoding: digits, as: UTF8.self))
            else { throw GateEDualGraphJoinError.syntax }
            return value
        }

        mutating func quad() throws -> UInt16 {
            var result: UInt16 = 0
            for _ in 0 ..< 4 {
                guard let byte = peek(), let digit = hex(byte) else {
                    throw GateEDualGraphJoinError.syntax
                }
                offset += 1; result = (result << 4) | UInt16(digit)
            }
            return result
        }

        func hex(_ byte: UInt8) -> UInt8? {
            switch byte {
            case 0x30 ... 0x39: return byte - 0x30
            case 0x41 ... 0x46: return byte - 0x41 + 10
            case 0x61 ... 0x66: return byte - 0x61 + 10
            default: return nil
            }
        }

        mutating func literal(_ text: String) throws {
            let literal = Array(text.utf8)
            guard offset + literal.count <= bytes.count,
                  Array(bytes[offset ..< offset + literal.count]) == literal
            else { throw GateEDualGraphJoinError.syntax }
            offset += literal.count
        }

        mutating func skipSpace() {
            while let byte = peek(),
                  byte == 0x20 || byte == 0x09 || byte == 0x0a || byte == 0x0d
            { offset += 1 }
        }
        func peek() -> UInt8? { offset < bytes.count ? bytes[offset] : nil }
        mutating func take(_ byte: UInt8) -> Bool {
            guard peek() == byte else { return false }
            offset += 1; return true
        }
        mutating func consume(_ byte: UInt8) throws {
            guard take(byte) else { throw GateEDualGraphJoinError.syntax }
        }
    }
}

private enum JoinHash {
    static func sha256(_ bytes: [UInt8]) -> [UInt8] {
        Array(SHA256.hash(data: Data(bytes)))
    }
    static func sha256Hex(_ bytes: [UInt8]) -> String { hex(sha256(bytes)) }
    static func hex(_ bytes: [UInt8]) -> String {
        let digits = Array("0123456789abcdef".utf8)
        var result: [UInt8] = []
        for byte in bytes {
            result.append(digits[Int(byte >> 4)])
            result.append(digits[Int(byte & 15)])
        }
        return String(decoding: result, as: UTF8.self)
    }
    static func domain(_ name: String, _ fields: [[UInt8]]) -> [UInt8] {
        var bytes = Array(name.utf8); bytes.append(0)
        for field in fields {
            append(UInt64(field.count), to: &bytes)
            bytes.append(contentsOf: field)
        }
        return sha256(bytes)
    }
    static func append(_ value: UInt64, to bytes: inout [UInt8]) {
        for shift in stride(from: 56, through: 0, by: -8) {
            bytes.append(UInt8((value >> UInt64(shift)) & 0xff))
        }
    }
}
