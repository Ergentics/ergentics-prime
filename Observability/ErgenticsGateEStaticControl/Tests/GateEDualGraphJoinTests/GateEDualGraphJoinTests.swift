import Testing
import GateECBORAuthority
import GateEJSONAuthority
@testable import GateEDualGraphJoin

@Suite("Gate E independent dual graph join")
struct GateEDualGraphJoinTests {
    @Test("equal independently labelled streams join without authority credit")
    func joins() throws {
        let jsonCandidate = canonicalCandidate()
        let cborCandidate = try GateECBORAuthority.canonicalCandidate(
            sourceCommit: sourceCommit,
            sourceTree: sourceTree,
            sourceIdentity: sourceIdentity
        )
        let json = try GateEJSONAuthority.projectAndVerify(candidate: jsonCandidate)
        let cbor = try GateECBORAuthority.projectAndVerify(candidate: cborCandidate)
        let jsonRoundTrip = try GateEJSONReconstructor.reconstructAndReceipt(
            candidate: jsonCandidate,
            graphFrame: json.graphFrame
        )
        let cborRoundTrip = try GateECBORReconstructor.reconstructAndReceipt(
            candidate: cborCandidate,
            graphFrame: cbor.graphFrame
        )
        let result = try GateEDualGraphJoin.join(
            jsonGraph: json.graphFrame,
            jsonVerifier: json.verifierReceipt,
            jsonRoundTrip: jsonRoundTrip,
            cborGraph: cbor.graphFrame,
            cborVerifier: cbor.verifierReceipt,
            cborRoundTrip: cborRoundTrip
        )
        let receipt = String(decoding: result.joinReceipt, as: UTF8.self)
        #expect(result.authoritativeGraph == json.graphFrame)
        #expect(receipt.contains("\"result\":\"PASS\""))
        #expect(receipt.contains("\"authority_vector\":\"00000000\""))
        #expect(receipt.contains("\"projection_write_mask\":\"00000000\""))
        #expect(!receipt.contains("11110000"))
    }

    @Test("graph mismatch rejects before receipt interpretation")
    func graphMismatch() throws {
        let fixture = try fixture()
        var changed = fixture.graph
        changed[changed.count / 2] ^= 1
        #expect(throws: GateEDualGraphJoinError.self) {
            _ = try GateEDualGraphJoin.join(
                jsonGraph: fixture.graph,
                jsonVerifier: fixture.jsonVerifier,
                jsonRoundTrip: fixture.jsonRoundTrip,
                cborGraph: changed,
                cborVerifier: fixture.cborVerifier,
                cborRoundTrip: fixture.cborRoundTrip
            )
        }
    }

    @Test("a mismatched verifier or round-trip cannot fall back")
    func receiptMismatch() throws {
        let fixture = try fixture()
        let badRoundTrip = Array(String(
            decoding: fixture.cborRoundTrip,
            as: UTF8.self
        ).replacingOccurrences(
            of: "\"result\":\"PASS\"",
            with: "\"result\":\"FAIL\""
        ).utf8)
        #expect(throws: GateEDualGraphJoinError.self) {
            _ = try GateEDualGraphJoin.join(
                jsonGraph: fixture.graph,
                jsonVerifier: fixture.jsonVerifier,
                jsonRoundTrip: fixture.jsonRoundTrip,
                cborGraph: fixture.graph,
                cborVerifier: fixture.cborVerifier,
                cborRoundTrip: badRoundTrip
            )
        }
    }

    @Test("each verifier and round-trip bind the same carrier")
    func carrierBinding() throws {
        let fixture = try fixture()
        let receipt = String(decoding: fixture.cborRoundTrip, as: UTF8.self)
        let marker = "\"candidate_sha256\":\""
        let valueStart = try #require(receipt.range(of: marker)?.upperBound)
        let valueEnd = try #require(
            receipt.index(valueStart, offsetBy: 64, limitedBy: receipt.endIndex)
        )
        let original = String(receipt[valueStart..<valueEnd])
        let replacement = String(repeating: original.first == "0" ? "1" : "0", count: 64)
        let internallyConsistentButDifferentCarrier = Array(
            receipt.replacingOccurrences(of: original, with: replacement).utf8
        )

        #expect(throws: GateEDualGraphJoinError.self) {
            _ = try GateEDualGraphJoin.join(
                jsonGraph: fixture.graph,
                jsonVerifier: fixture.jsonVerifier,
                jsonRoundTrip: fixture.jsonRoundTrip,
                cborGraph: fixture.graph,
                cborVerifier: fixture.cborVerifier,
                cborRoundTrip: internallyConsistentButDifferentCarrier
            )
        }
    }

    private func fixture() throws -> (
        graph: [UInt8],
        jsonVerifier: [UInt8],
        jsonRoundTrip: [UInt8],
        cborVerifier: [UInt8],
        cborRoundTrip: [UInt8]
    ) {
        let jsonCandidate = canonicalCandidate()
        let cborCandidate = try GateECBORAuthority.canonicalCandidate(
            sourceCommit: sourceCommit,
            sourceTree: sourceTree,
            sourceIdentity: sourceIdentity
        )
        let json = try GateEJSONAuthority.projectAndVerify(candidate: jsonCandidate)
        let cbor = try GateECBORAuthority.projectAndVerify(candidate: cborCandidate)
        #expect(json.graphFrame == cbor.graphFrame)
        return (
            json.graphFrame,
            json.verifierReceipt,
            try GateEJSONReconstructor.reconstructAndReceipt(
                candidate: jsonCandidate,
                graphFrame: json.graphFrame
            ),
            cbor.verifierReceipt,
            try GateECBORReconstructor.reconstructAndReceipt(
                candidate: cborCandidate,
                graphFrame: cbor.graphFrame
            )
        )
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
            + "\"source_commit\":\"\(sourceCommit)\","
            + "\"source_identity\":\"\(sourceIdentity)\","
            + "\"source_tree\":\"\(sourceTree)\"}"
        ).utf8)
    }

    private let sourceCommit = "1111111111111111111111111111111111111111"
    private let sourceTree = "2222222222222222222222222222222222222222"
    private let sourceIdentity =
        "3333333333333333333333333333333333333333333333333333333333333333"
}
