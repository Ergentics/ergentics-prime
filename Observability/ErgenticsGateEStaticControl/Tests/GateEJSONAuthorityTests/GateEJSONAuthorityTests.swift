import Testing
@testable import GateEJSONAuthority

@Suite("Gate E independent JSON static authority")
struct GateEJSONAuthorityTests {
    @Test("canonical carrier projects and reconstructs byte exactly")
    func roundTrip() throws {
        let candidate = canonicalCandidate()
        let first = try GateEJSONAuthority.projectAndVerify(candidate: candidate)
        let second = try GateEJSONAuthority.projectAndVerify(candidate: candidate)
        let receipt = try GateEJSONReconstructor.reconstructAndReceipt(
            candidate: candidate,
            graphFrame: first.graphFrame
        )

        #expect(first == second)
        #expect(String(decoding: first.verifierReceipt, as: UTF8.self)
            .contains("\"result\":\"PASS\""))
        #expect(String(decoding: receipt, as: UTF8.self)
            .contains("\"source_authority\":\"JSON\""))
        #expect(String(decoding: receipt, as: UTF8.self)
            .contains("\"result\":\"PASS\""))
    }

    @Test("graph is bipartite and projection cannot write authority")
    func graphSurface() throws {
        let result = try GateEJSONAuthority.projectAndVerify(
            candidate: canonicalCandidate()
        )
        let graph = String(decoding: result.graphFrame, as: UTF8.self)
        #expect(graph.contains("\"authority_vector_expectation\":\"00000000\""))
        #expect(graph.contains("\"gate_state\":\"ABSTAIN\""))
        #expect(graph.contains("\"partition\":\"FACT\""))
        #expect(graph.contains("\"partition\":\"RELATION\""))
        #expect(graph.contains("\"subtype\":\"STATE\""))
        #expect(graph.contains("\"subtype\":\"WITNESS\""))
        #expect(graph.contains("\"subtype\":\"TRANSITION\""))
        #expect(graph.contains("STATE_FACT_TO_TRANSITION_RELATION_FROM"))
        #expect(graph.contains("WITNESS_FACT_TO_TRANSITION_RELATION_WITNESS"))
        #expect(graph.contains("TRANSITION_RELATION_TO_STATE_FACT_TO"))
        #expect(!graph.contains("11110000"))
    }

    @Test("noncanonical whitespace and duplicate keys reject")
    func strictCarrier() {
        let canonical = canonicalCandidate()
        #expect(throws: GateEJSONAuthorityError.self) {
            _ = try GateEJSONAuthority.projectAndVerify(candidate: [0x20] + canonical)
        }
        let duplicate = Array(
            "{\"authority_vector\":\"00000000\",\"authority_vector\":\"00000000\"}"
                .utf8
        )
        #expect(throws: GateEJSONAuthorityError.self) {
            _ = try GateEJSONAuthority.projectAndVerify(candidate: duplicate)
        }
    }

    @Test("role order and graph ancestry are bound")
    func mutationRejects() throws {
        let canonical = canonicalCandidate()
        let altered = String(decoding: canonical, as: UTF8.self)
            .replacingOccurrences(of: "prime_head_pre", with: "prime_head_bad")
        #expect(throws: GateEJSONAuthorityError.self) {
            _ = try GateEJSONAuthority.projectAndVerify(
                candidate: Array(altered.utf8)
            )
        }

        let projection = try GateEJSONAuthority.projectAndVerify(candidate: canonical)
        var graph = projection.graphFrame
        graph[graph.count / 2] ^= 1
        #expect(throws: GateEJSONAuthorityError.self) {
            _ = try GateEJSONReconstructor.reconstructAndReceipt(
                candidate: canonical,
                graphFrame: graph
            )
        }
    }

    private func canonicalCandidate() -> [UInt8] {
        let predicates = GateEJSONAuthority.predicates
            .map { "\"\($0)\"" }.joined(separator: ",")
        let roles = GateEJSONAuthority.roles
            .map { "\"\($0)\"" }.joined(separator: ",")
        return Array((
            "{\"authority_vector\":\"00000000\","
            + "\"gate_state\":\"ABSTAIN\","
            + "\"predicates\":[\(predicates)],"
            + "\"roles\":[\(roles)],"
            + "\"schema\":\"ergentics.gate-e.static.candidate.v1\","
            + "\"source_commit\":\"1111111111111111111111111111111111111111\","
            + "\"source_identity\":\"3333333333333333333333333333333333333333333333333333333333333333\","
            + "\"source_tree\":\"2222222222222222222222222222222222222222\"}"
        ).utf8)
    }
}
