import CryptoKit
import Foundation

public enum GateEJSONReconstructor {
    public static func reconstructAndReceipt(
        candidate: [UInt8],
        graphFrame: [UInt8]
    ) throws -> [UInt8] {
        let candidateValue = try GateECanonicalJSON.decodeCanonical(candidate)
        let originalModel = try GateEStaticModel(json: candidateValue)
        let graph = try GateECanonicalJSON.decodeCanonical(graphFrame)
        let reconstructed = try model(fromGraph: graph)
        guard reconstructed == originalModel else {
            throw GateEJSONAuthorityError.graph
        }

        let reconstructedCandidate = try GateECanonicalJSON.encode(
            reconstructed.canonicalValue
        )
        guard reconstructedCandidate == candidate else {
            throw GateEJSONAuthorityError.nonCanonical
        }
        let reprojection = try GateEJSONIndependentReprojector.project(reconstructed)
        guard reprojection.graphFrame == graphFrame else {
            throw GateEJSONAuthorityError.graph
        }
        guard let semanticRoot = stringField("semantic_root", in: graph),
              let graphRoot = stringField("graph_merkle_root", in: graph),
              semanticRoot == reprojection.semanticRoot,
              graphRoot == reprojection.graphMerkleRoot
        else { throw GateEJSONAuthorityError.graph }

        let receipt: GateEJSONValue = .object([
            ("candidate_sha256", .string(GateEStaticHash.sha256Hex(candidate))),
            ("graph_frame_sha256", .string(GateEStaticHash.sha256Hex(graphFrame))),
            ("graph_merkle_root", .string(graphRoot)),
            ("original_semantic_root", .string(semanticRoot)),
            ("reconstructed_candidate_sha256", .string(
                GateEStaticHash.sha256Hex(reconstructedCandidate)
            )),
            ("reconstructed_graph_frame_sha256", .string(
                GateEStaticHash.sha256Hex(reprojection.graphFrame)
            )),
            ("reconstructed_semantic_root", .string(reprojection.semanticRoot)),
            ("result", .string("PASS")),
            ("schema", .string("ergentics.gate-e.static.round-trip-receipt.v1")),
            ("source_authority", .string("JSON")),
        ])
        return try GateECanonicalJSON.encode(receipt)
    }

    private static func model(
        fromGraph graph: GateEJSONValue
    ) throws -> GateEStaticModel {
        guard exactKeys(graph, [
            "authority_vector_expectation", "edges", "facts", "gate_state",
            "graph_merkle_root", "relations", "schema", "semantic_root",
        ]),
        stringField("schema", in: graph) == GateEStaticGraphProjector.graphSchema,
        stringField("authority_vector_expectation", in: graph) == "00000000",
        stringField("gate_state", in: graph) == "ABSTAIN",
        case .array(let facts)? = graph.field("facts")
        else { throw GateEJSONAuthorityError.graph }

        var sourceCommit: String?
        var sourceTree: String?
        var sourceIdentity: String?
        var roles: [String]?
        var predicates: [String]?
        var vectorWitness = false

        for fact in facts {
            guard stringField("partition", in: fact) == "FACT",
                  let subtype = stringField("subtype", in: fact),
                  subtype == "STATE" || subtype == "WITNESS",
                  let body = fact.field("body"),
                  let id = stringField("id", in: fact)
            else { throw GateEJSONAuthorityError.graph }
            let bodyBytes = try GateECanonicalJSON.encode(body)
            let expectedID = GateEStaticHash.hex(GateEStaticHash.domain(
                GateEStaticGraphProjector.factDomain,
                [Array(subtype.utf8), bodyBytes]
            ))
            guard id == expectedID else { throw GateEJSONAuthorityError.graph }
            guard subtype == "WITNESS" else { continue }
            switch stringField("kind", in: body) {
            case "SOURCE_BINDING":
                sourceCommit = stringField("source_commit", in: body)
                sourceTree = stringField("source_tree", in: body)
                sourceIdentity = stringField("source_identity", in: body)
            case "ROLE_ORDER":
                roles = stringsField("roles", in: body)
            case "PREDICATE_SET":
                predicates = stringsField("predicates", in: body)
            case "AUTHORITY_PRESTATE":
                vectorWitness = stringField("authority_vector", in: body) == "00000000"
                    && stringField("gate_state", in: body) == "ABSTAIN"
            default:
                throw GateEJSONAuthorityError.graph
            }
        }
        guard let sourceCommit, let sourceTree, let sourceIdentity,
              roles == GateEStaticModel.roles,
              predicates == GateEStaticModel.predicates,
              vectorWitness
        else { throw GateEJSONAuthorityError.graph }
        return try GateEStaticModel(
            sourceCommit: sourceCommit,
            sourceTree: sourceTree,
            sourceIdentity: sourceIdentity
        )
    }

    private static func exactKeys(
        _ value: GateEJSONValue,
        _ keys: [String]
    ) -> Bool {
        guard let fields = value.objectFields else { return false }
        return Set(fields.map { $0.0 }) == Set(keys)
    }

    private static func stringField(
        _ name: String,
        in value: GateEJSONValue
    ) -> String? {
        guard case .string(let string)? = value.field(name) else { return nil }
        return string
    }

    private static func stringsField(
        _ name: String,
        in value: GateEJSONValue
    ) -> [String]? {
        guard case .array(let values)? = value.field(name) else { return nil }
        var result: [String] = []
        for value in values {
            guard case .string(let string) = value else { return nil }
            result.append(string)
        }
        return result
    }
}

private enum GateEJSONIndependentReprojector {
    private struct Row {
        let value: GateEJSONValue
        let bytes: [UInt8]
        let id: String
    }

    static func project(_ model: GateEStaticModel) throws
        -> GateEStaticGraphProjection
    {
        let semanticBytes = try GateECanonicalJSON.encode(model.canonicalValue)
        let semanticRoot = GateEStaticHash.hex(GateEStaticHash.domain(
            "ERGENTICS-GATE-E-STATIC-SEMANTIC-V1", [semanticBytes]
        ))
        let pre = try fact("STATE", .object([
            ("authority_vector", .string("00000000")),
            ("gate_state", .string("ABSTAIN")),
            ("predecessor_state_id_or_null", .null),
            ("prior_transition_id_or_null", .null),
            ("state_class", .string("STATIC_INPUT")),
        ]))
        let source = try fact("WITNESS", .object([
            ("kind", .string("SOURCE_BINDING")),
            ("source_commit", .string(model.sourceCommit)),
            ("source_identity", .string(model.sourceIdentity)),
            ("source_tree", .string(model.sourceTree)),
        ]))
        let roles = try fact("WITNESS", .object([
            ("kind", .string("ROLE_ORDER")),
            ("roles", .array(GateEStaticModel.roles.map { .string($0) })),
        ]))
        let predicates = try fact("WITNESS", .object([
            ("kind", .string("PREDICATE_SET")),
            ("predicates", .array(GateEStaticModel.predicates.map { .string($0) })),
        ]))
        let vector = try fact("WITNESS", .object([
            ("authority_vector", .string("00000000")),
            ("gate_state", .string("ABSTAIN")),
            ("kind", .string("AUTHORITY_PRESTATE")),
        ]))
        let witnesses = [source, roles, predicates, vector]
        let relation = try transition(.object([
            ("from_state_id", .string(pre.id)),
            ("predicate", .string("CANDIDATE_SCHEMA_ROLE_PREDICATE_AND_PRESTATE_EXACT")),
            ("result", .string("PROVED")),
            ("witness_ids", .array(witnesses.map { .string($0.id) })),
        ]))
        let post = try fact("STATE", .object([
            ("authority_vector", .string("00000000")),
            ("gate_state", .string("ABSTAIN")),
            ("predecessor_state_id_or_null", .string(pre.id)),
            ("prior_transition_id_or_null", .string(relation.id)),
            ("state_class", .string("STATIC_READY")),
        ]))

        var facts = [pre, post] + witnesses
        var relations = [relation]
        var edges = [try edge(
            "STATE_FACT_TO_TRANSITION_RELATION_FROM", pre.id, relation.id, 0
        )]
        for (index, witness) in witnesses.enumerated() {
            edges.append(try edge(
                "WITNESS_FACT_TO_TRANSITION_RELATION_WITNESS",
                witness.id, relation.id, UInt64(index)
            ))
        }
        edges.append(try edge(
            "TRANSITION_RELATION_TO_STATE_FACT_TO", relation.id, post.id, 0
        ))
        facts.sort { $0.bytes.lexicographicallyPrecedes($1.bytes) }
        relations.sort { $0.bytes.lexicographicallyPrecedes($1.bytes) }
        edges.sort { $0.bytes.lexicographicallyPrecedes($1.bytes) }
        let rows = (facts + relations + edges).sorted {
            $0.bytes.lexicographicallyPrecedes($1.bytes)
        }
        let graphRoot = GateEStaticHash.hex(merkle(rows.map(\.bytes)))
        let frame: GateEJSONValue = .object([
            ("authority_vector_expectation", .string("00000000")),
            ("edges", .array(edges.map(\.value))),
            ("facts", .array(facts.map(\.value))),
            ("gate_state", .string("ABSTAIN")),
            ("graph_merkle_root", .string(graphRoot)),
            ("relations", .array(relations.map(\.value))),
            ("schema", .string("ergentics.gate-e.static.graph-frame.v1")),
            ("semantic_root", .string(semanticRoot)),
        ])
        return GateEStaticGraphProjection(
            graphFrame: try GateECanonicalJSON.encode(frame),
            semanticRoot: semanticRoot,
            graphMerkleRoot: graphRoot
        )
    }

    private static func fact(
        _ subtype: String,
        _ body: GateEJSONValue
    ) throws -> Row {
        let id = GateEStaticHash.hex(GateEStaticHash.domain(
            "ERGENTICS-GATE-E-STATIC-FACT-V1",
            [Array(subtype.utf8), try GateECanonicalJSON.encode(body)]
        ))
        let value: GateEJSONValue = .object([
            ("body", body), ("id", .string(id)),
            ("partition", .string("FACT")), ("subtype", .string(subtype)),
        ])
        return Row(value: value, bytes: try GateECanonicalJSON.encode(value), id: id)
    }

    private static func transition(_ body: GateEJSONValue) throws -> Row {
        let id = GateEStaticHash.hex(GateEStaticHash.domain(
            "ERGENTICS-GATE-E-STATIC-RELATION-V1",
            [try GateECanonicalJSON.encode(body)]
        ))
        let value: GateEJSONValue = .object([
            ("body", body), ("id", .string(id)),
            ("partition", .string("RELATION")),
            ("subtype", .string("TRANSITION")),
        ])
        return Row(value: value, bytes: try GateECanonicalJSON.encode(value), id: id)
    }

    private static func edge(
        _ role: String,
        _ source: String,
        _ target: String,
        _ ordinal: UInt64
    ) throws -> Row {
        let id = GateEStaticHash.hex(GateEStaticHash.domain(
            "ERGENTICS-GATE-E-STATIC-EDGE-V1",
            [Array(role.utf8), Array(source.utf8), Array(target.utf8),
             Array(String(ordinal).utf8)]
        ))
        let value: GateEJSONValue = .object([
            ("id", .string(id)), ("ordinal", .unsigned(ordinal)),
            ("role", .string(role)), ("source_id", .string(source)),
            ("target_id", .string(target)),
        ])
        return Row(value: value, bytes: try GateECanonicalJSON.encode(value), id: id)
    }

    private static func merkle(_ rows: [[UInt8]]) -> [UInt8] {
        guard !rows.isEmpty else {
            return GateEStaticHash.domain(
                "ERGENTICS-GATE-E-STATIC-MERKLE-EMPTY-V1", []
            )
        }
        var level = rows.map {
            GateEStaticHash.domain("ERGENTICS-GATE-E-STATIC-MERKLE-LEAF-V1", [$0])
        }
        while level.count > 1 {
            var next: [[UInt8]] = []
            var index = 0
            while index < level.count {
                let right = index + 1 < level.count ? level[index + 1] : level[index]
                next.append(GateEStaticHash.domain(
                    "ERGENTICS-GATE-E-STATIC-MERKLE-NODE-V1",
                    [level[index], right]
                ))
                index += 2
            }
            level = next
        }
        return level[0]
    }
}
