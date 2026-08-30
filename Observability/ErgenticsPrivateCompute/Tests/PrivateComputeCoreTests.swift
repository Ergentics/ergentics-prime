import Foundation
import XCTest
@testable import PrivateComputeCore

final class PrivateComputeCoreTests: XCTestCase {
    private func inputs() throws -> StaticInputs {
        let bundle = Bundle(for: Self.self)
        let json = try XCTUnwrap(bundle.url(forResource: "gate-e-static-bootstrap-json-input.v1", withExtension: "hex"))
        let cbor = try XCTUnwrap(bundle.url(forResource: "gate-e-static-bootstrap-cbor-input.v1", withExtension: "hex"))
        return try PrivateComputeCore.admitCarriers(json: Data(contentsOf: json), cbor: Data(contentsOf: cbor))
    }

    func testIndependentStreamsAndRoundTripsJoin() throws {
        let result = try PrivateComputeCore.compute(inputs())
        XCTAssertEqual(result.artifacts.count, 10)
        XCTAssertEqual(result.semanticRoot, PrivateComputeCore.semanticRoot)
        XCTAssertEqual(result.artifacts["11-json-graph.json"], result.artifacts["21-cbor-graph.json"])
        XCTAssertEqual(result.artifacts["31-authoritative-graph.json"], result.artifacts["11-json-graph.json"])
        let graph = try XCTUnwrap(try JSONSerialization.jsonObject(with: XCTUnwrap(result.artifacts["31-authoritative-graph.json"])) as? [String: Any])
        XCTAssertEqual(graph["gate_state"] as? String, "ABSTAIN")
        XCTAssertEqual(graph["authority_vector_expectation"] as? String, "00000000")
        XCTAssertEqual((graph["facts"] as? [Any])?.count, 6)
        XCTAssertEqual((graph["relations"] as? [Any])?.count, 1)
        XCTAssertEqual((graph["edges"] as? [Any])?.count, 6)
    }

    func testJSONMutationRejects() throws {
        let original = try inputs()
        var changed = original.json; changed[0] ^= 1
        XCTAssertThrowsError(try PrivateComputeCore.compute(StaticInputs(json: changed, cbor: original.cbor)))
    }

    func testCBORMutationRejects() throws {
        let original = try inputs()
        var changed = original.cbor; changed[0] ^= 1
        XCTAssertThrowsError(try PrivateComputeCore.compute(StaticInputs(json: original.json, cbor: changed)))
    }

    func testSwappedCarriersReject() throws {
        let bundle = Bundle(for: Self.self)
        let json = try Data(contentsOf: XCTUnwrap(bundle.url(forResource: "gate-e-static-bootstrap-json-input.v1", withExtension: "hex")))
        let cbor = try Data(contentsOf: XCTUnwrap(bundle.url(forResource: "gate-e-static-bootstrap-cbor-input.v1", withExtension: "hex")))
        XCTAssertThrowsError(try PrivateComputeCore.admitCarriers(json: cbor, cbor: json))
    }

    func testMalformedHexRejects() {
        for frame in ["00", "00\n\n", "0\n", "FF\n", "gg\n", "\n"] {
            XCTAssertThrowsError(try PrivateComputeCore.decodeHex(Data(frame.utf8)))
        }
    }

    func testReadOnlyReplayJoinsIdenticalBytes() throws {
        let result = try PrivateComputeCore.compute(inputs())
        let replay = try PrivateComputeCore.validateRetained(result.artifacts)
        XCTAssertEqual(replay.graphHash, result.graphHash)
        XCTAssertEqual(replay.merkleRoot, result.merkleRoot)
    }

    func testRetainedGraphMutationRejects() throws {
        var artifacts = try PrivateComputeCore.compute(inputs()).artifacts
        artifacts["31-authoritative-graph.json"]![0] ^= 1
        XCTAssertThrowsError(try PrivateComputeCore.validateRetained(artifacts))
    }

    func testRetainedRoundTripMutationRejects() throws {
        var artifacts = try PrivateComputeCore.compute(inputs()).artifacts
        artifacts["22-cbor-roundtrip.json"]![0] ^= 1
        XCTAssertThrowsError(try PrivateComputeCore.validateRetained(artifacts))
    }

    func testExactRationalTimebasePreserved() throws {
        XCTAssertEqual(try PrivateComputeCore.exactNanoseconds(start: 100, end: 101, numerator: 125, denominator: 3), "125 / 3 ns")
        XCTAssertEqual(try PrivateComputeCore.exactNanoseconds(start: 100, end: 103, numerator: 125, denominator: 3), "375 / 3 ns")
    }

    func testConsistentButUnpinnedCandidateReceiptRejects() throws {
        var artifacts = try PrivateComputeCore.compute(inputs()).artifacts
        for leaf in ["20-cbor-verifier.json", "22-cbor-roundtrip.json"] {
            let bytes = try XCTUnwrap(artifacts[leaf])
            let text = String(decoding: bytes, as: UTF8.self)
                .replacingOccurrences(of: PrivateComputeCore.cborHash, with: String(repeating: "a", count: 64))
            artifacts[leaf] = Data(text.utf8)
        }
        XCTAssertThrowsError(try PrivateComputeCore.validateRetained(artifacts))
    }

    func testInvalidClockRejects() {
        XCTAssertThrowsError(try PrivateComputeCore.exactNanoseconds(start: 2, end: 1, numerator: 1, denominator: 1))
        XCTAssertThrowsError(try PrivateComputeCore.exactNanoseconds(start: 1, end: 2, numerator: 1, denominator: 0))
    }

    func testOverflowKeepsExactExpression() throws {
        XCTAssertEqual(try PrivateComputeCore.exactNanoseconds(start: 0, end: UInt64.max, numerator: 125, denominator: 3),
                       "\(UInt64.max) × 125 / 3 ns")
    }
}
