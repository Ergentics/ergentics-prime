import CryptoKit
import Foundation
import XCTest
@testable import GateECBORAuthority

final class GateECBORAuthorityTests: XCTestCase {
    func testPublicCanonicalCandidateMatchesIndependentKnownShape() throws {
        let candidate = try GateECBORAuthority.canonicalCandidate(
            sourceCommit: "272baaba5e4e3be3f17f6c1704e4622b514b12d8",
            sourceTree: "fdbf508d3a461f4e5ba5098453c6c1f8351f75b1",
            sourceIdentity: "36fed0d96845ea8f5304cd762f21cbf487d278fd00c90080e4b35ffffbcb18c0"
        )
        XCTAssertEqual(candidate, CandidateFixture.make())
        XCTAssertEqual(GateECBORAuthority.roles, CandidateFixture.roles)
        XCTAssertEqual(GateECBORAuthority.predicates, CandidateFixture.predicates)
    }

    func testCanonicalCandidateProjectsDeterministicBipartiteGraph() throws {
        let candidate = CandidateFixture.make()
        let first = try GateECBORAuthority.projectAndVerify(candidate: candidate)
        let second = try GateECBORAuthority.projectAndVerify(candidate: candidate)

        XCTAssertEqual(first, second)
        XCTAssertFalse(first.graphFrame.contains(10))
        XCTAssertFalse(first.graphFrame.contains(13))

        let receipt = try jsonObject(first.verifierReceipt)
        XCTAssertEqual(receipt["schema"] as? String, "ergentics.gate-e.static.verifier-receipt.v1")
        XCTAssertEqual(receipt["source_authority"] as? String, "CBOR")
        XCTAssertEqual(receipt["result"] as? String, "PASS")
        XCTAssertEqual(receipt["candidate_sha256"] as? String, digestHex(candidate))
        XCTAssertEqual(receipt["graph_frame_sha256"] as? String, digestHex(first.graphFrame))

        let graph = try jsonObject(first.graphFrame)
        XCTAssertEqual(graph["schema"] as? String, "ergentics.gate-e.static.graph-frame.v1")
        XCTAssertEqual(graph["authority_vector_expectation"] as? String, "00000000")
        XCTAssertEqual(graph["gate_state"] as? String, "ABSTAIN")
        XCTAssertEqual(graph["semantic_root"] as? String, receipt["semantic_root"] as? String)
        XCTAssertEqual(graph["graph_merkle_root"] as? String, receipt["graph_merkle_root"] as? String)

        let facts = try XCTUnwrap(graph["facts"] as? [[String: Any]])
        let relations = try XCTUnwrap(graph["relations"] as? [[String: Any]])
        let edges = try XCTUnwrap(graph["edges"] as? [[String: Any]])
        XCTAssertEqual(facts.count, 6)
        XCTAssertEqual(relations.count, 1)
        XCTAssertEqual(edges.count, 6)
        XCTAssertEqual(facts.filter { $0["subtype"] as? String == "STATE" }.count, 2)
        XCTAssertEqual(facts.filter { $0["subtype"] as? String == "WITNESS" }.count, 4)
        XCTAssertEqual(relations.first?["subtype"] as? String, "TRANSITION")

        let factIDs = Set(try facts.map { try requiredHexID($0) })
        let relationIDs = Set(try relations.map { try requiredHexID($0) })
        XCTAssertTrue(factIDs.isDisjoint(with: relationIDs))
        for edge in edges {
            _ = try requiredHexID(edge)
            let role = try XCTUnwrap(edge["role"] as? String)
            let source = try XCTUnwrap(edge["source_id"] as? String)
            let target = try XCTUnwrap(edge["target_id"] as? String)
            switch role {
            case "STATE_FACT_TO_TRANSITION_RELATION_FROM",
                 "WITNESS_FACT_TO_TRANSITION_RELATION_WITNESS":
                XCTAssertTrue(factIDs.contains(source))
                XCTAssertTrue(relationIDs.contains(target))
            case "TRANSITION_RELATION_TO_STATE_FACT_TO":
                XCTAssertTrue(relationIDs.contains(source))
                XCTAssertTrue(factIDs.contains(target))
            default:
                XCTFail("Unexpected edge role: \(role)")
            }
        }
    }

    func testIndependentReconstructionProvesCarrierGraphAndRootsByteExact() throws {
        let candidate = CandidateFixture.make()
        let projection = try GateECBORAuthority.projectAndVerify(candidate: candidate)
        let receiptBytes = try GateECBORReconstructor.reconstructAndReceipt(
            candidate: candidate,
            graphFrame: projection.graphFrame
        )

        let verifier = try jsonObject(projection.verifierReceipt)
        let roundTrip = try jsonObject(receiptBytes)
        XCTAssertEqual(roundTrip["schema"] as? String, "ergentics.gate-e.static.round-trip-receipt.v1")
        XCTAssertEqual(roundTrip["source_authority"] as? String, "CBOR")
        XCTAssertEqual(roundTrip["result"] as? String, "PASS")
        XCTAssertEqual(roundTrip["candidate_sha256"] as? String, digestHex(candidate))
        XCTAssertEqual(roundTrip["reconstructed_candidate_sha256"] as? String, digestHex(candidate))
        XCTAssertEqual(roundTrip["graph_frame_sha256"] as? String, digestHex(projection.graphFrame))
        XCTAssertEqual(roundTrip["reconstructed_graph_frame_sha256"] as? String, digestHex(projection.graphFrame))
        XCTAssertEqual(roundTrip["graph_merkle_root"] as? String, verifier["graph_merkle_root"] as? String)
        XCTAssertEqual(roundTrip["original_semantic_root"] as? String, verifier["semantic_root"] as? String)
        XCTAssertEqual(roundTrip["reconstructed_semantic_root"] as? String, verifier["semantic_root"] as? String)
    }

    func testRejectsNonShortestAndNonBytewiseOrderedMaps() {
        let valid = CandidateFixture.make()
        var nonShortestMap = valid
        nonShortestMap.replaceSubrange(0...0, with: [0xb8, 0x08])

        var nonShortestKey = valid
        nonShortestKey.replaceSubrange(1...1, with: [0x18, 0x00])

        var nonShortestText = valid
        let sourceMarker = try! XCTUnwrap(index(of: [0x01, 0x78, 0x28], in: nonShortestText))
        nonShortestText.replaceSubrange(
            (sourceMarker + 1)...(sourceMarker + 2),
            with: [0x79, 0x00, 0x28]
        )

        let reversedKeys = CandidateFixture.make(keys: [1, 0, 2, 3, 4, 5, 6, 7])
        let duplicateKey = CandidateFixture.make(keys: [0, 1, 2, 3, 4, 5, 6, 6])
        let unknownKey = CandidateFixture.make(keys: [0, 1, 2, 3, 4, 5, 6, 8])

        for (name, malformed) in [
            ("non-shortest map", nonShortestMap),
            ("non-shortest key", nonShortestKey),
            ("non-shortest text", nonShortestText),
            ("reversed encoded-key order", reversedKeys),
            ("duplicate key", duplicateKey),
            ("unknown key", unknownKey),
        ] {
            XCTAssertThrowsError(
                try GateECBORAuthority.projectAndVerify(candidate: malformed),
                "Accepted \(name)"
            )
        }
    }

    func testRejectsMalformedUTF8ForbiddenFormsIndefiniteAndTrailingBytes() throws {
        let valid = CandidateFixture.make()
        var invalidUTF8 = valid
        let sourceMarker = try XCTUnwrap(index(of: [0x01, 0x78, 0x28], in: invalidUTF8))
        invalidUTF8[sourceMarker + 3] = 0xff

        var indefiniteRoles = valid
        let rolesMarker = try XCTUnwrap(index(of: [0x06, 0x90], in: indefiniteRoles))
        indefiniteRoles[rolesMarker + 1] = 0x9f

        var trailing = valid
        trailing.append(0)
        var truncated = valid
        truncated.removeLast()

        let cases: [(String, [UInt8])] = [
            ("invalid UTF-8", invalidUTF8),
            ("indefinite array", indefiniteRoles),
            ("indefinite map", [0xbf] + Array(valid.dropFirst())),
            ("tag", [0xc0] + valid),
            ("float", [0xf9, 0x00, 0x00]),
            ("undefined", [0xf7]),
            ("trailing bytes", trailing),
            ("truncation", truncated),
            ("empty", []),
        ]
        for (name, malformed) in cases {
            XCTAssertThrowsError(
                try GateECBORAuthority.projectAndVerify(candidate: malformed),
                "Accepted \(name)"
            )
        }
    }

    func testRejectsSemanticallyInvalidCanonicalCandidate() throws {
        let valid = CandidateFixture.make()

        var nonzeroVector = valid
        let vectorMarker = try XCTUnwrap(index(of: [0x04, 0x41, 0x00, 0x05], in: nonzeroVector))
        nonzeroVector[vectorMarker + 2] = 1

        var uppercaseCommit = valid
        let sourceMarker = try XCTUnwrap(index(of: [0x01, 0x78, 0x28], in: uppercaseCommit))
        uppercaseCommit[sourceMarker + 3] = 65

        let wrongRole = CandidateFixture.make(roles: ["wrong_role"] + Array(CandidateFixture.roles.dropFirst()))
        let wrongPredicate = CandidateFixture.make(
            predicates: ["WRONG_PREDICATE"] + Array(CandidateFixture.predicates.dropFirst())
        )

        for candidate in [nonzeroVector, uppercaseCommit, wrongRole, wrongPredicate] {
            XCTAssertThrowsError(try GateECBORAuthority.projectAndVerify(candidate: candidate))
        }
    }

    func testRoundTripRejectsAnyNonCanonicalOrMismatchedGraphFrame() throws {
        let candidate = CandidateFixture.make()
        let projection = try GateECBORAuthority.projectAndVerify(candidate: candidate)

        var lineTerminated = projection.graphFrame
        lineTerminated.append(10)
        XCTAssertThrowsError(try GateECBORReconstructor.reconstructAndReceipt(
            candidate: candidate,
            graphFrame: lineTerminated
        ))

        var changedGraph = projection.graphFrame
        let marker = try XCTUnwrap(index(of: Array("STATIC_READY".utf8), in: changedGraph))
        changedGraph[marker] = 88
        XCTAssertThrowsError(try GateECBORReconstructor.reconstructAndReceipt(
            candidate: candidate,
            graphFrame: changedGraph
        ))

        let otherCandidate = CandidateFixture.make(
            sourceCommit: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        )
        XCTAssertThrowsError(try GateECBORReconstructor.reconstructAndReceipt(
            candidate: otherCandidate,
            graphFrame: projection.graphFrame
        ))
    }

    private func jsonObject(_ bytes: [UInt8]) throws -> [String: Any] {
        try XCTUnwrap(
            JSONSerialization.jsonObject(with: Data(bytes), options: []) as? [String: Any]
        )
    }

    private func requiredHexID(_ row: [String: Any]) throws -> String {
        let identifier = try XCTUnwrap(row["id"] as? String)
        XCTAssertEqual(identifier.utf8.count, 64)
        XCTAssertTrue(identifier.utf8.allSatisfy {
            (48...57).contains($0) || (97...102).contains($0)
        })
        return identifier
    }

    private func digestHex(_ bytes: [UInt8]) -> String {
        SHA256.hash(data: Data(bytes)).map { String(format: "%02x", $0) }.joined()
    }

    private func index(of needle: [UInt8], in haystack: [UInt8]) -> Int? {
        guard !needle.isEmpty, needle.count <= haystack.count else { return nil }
        for start in 0...(haystack.count - needle.count) {
            if Array(haystack[start..<(start + needle.count)]) == needle { return start }
        }
        return nil
    }
}

private enum CandidateFixture {
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

    static func make(
        sourceCommit: String = "272baaba5e4e3be3f17f6c1704e4622b514b12d8",
        sourceTree: String = "fdbf508d3a461f4e5ba5098453c6c1f8351f75b1",
        sourceIdentity: String = "36fed0d96845ea8f5304cd762f21cbf487d278fd00c90080e4b35ffffbcb18c0",
        authorityVector: [UInt8] = [0],
        gateState: String = "ABSTAIN",
        roles: [String] = CandidateFixture.roles,
        predicates: [String] = CandidateFixture.predicates,
        keys: [UInt64] = Array(0...7)
    ) -> [UInt8] {
        precondition(keys.count == 8)
        var result: [UInt8] = [0xa8]
        appendUnsigned(keys[0], to: &result)
        appendText("ergentics.gate-e.static.candidate.v1", to: &result)
        appendUnsigned(keys[1], to: &result)
        appendText(sourceCommit, to: &result)
        appendUnsigned(keys[2], to: &result)
        appendText(sourceTree, to: &result)
        appendUnsigned(keys[3], to: &result)
        appendText(sourceIdentity, to: &result)
        appendUnsigned(keys[4], to: &result)
        appendBytes(authorityVector, to: &result)
        appendUnsigned(keys[5], to: &result)
        appendText(gateState, to: &result)
        appendUnsigned(keys[6], to: &result)
        appendTextList(roles, to: &result)
        appendUnsigned(keys[7], to: &result)
        appendTextList(predicates, to: &result)
        return result
    }

    private static func appendUnsigned(_ value: UInt64, to output: inout [UInt8]) {
        appendHead(major: 0, value: value, to: &output)
    }

    private static func appendBytes(_ bytes: [UInt8], to output: inout [UInt8]) {
        appendHead(major: 2, value: UInt64(bytes.count), to: &output)
        output.append(contentsOf: bytes)
    }

    private static func appendText(_ value: String, to output: inout [UInt8]) {
        let bytes = Array(value.utf8)
        appendHead(major: 3, value: UInt64(bytes.count), to: &output)
        output.append(contentsOf: bytes)
    }

    private static func appendTextList(_ values: [String], to output: inout [UInt8]) {
        appendHead(major: 4, value: UInt64(values.count), to: &output)
        for value in values { appendText(value, to: &output) }
    }

    private static func appendHead(major: UInt8, value: UInt64, to output: inout [UInt8]) {
        let prefix = major << 5
        if value < 24 {
            output.append(prefix | UInt8(value))
        } else if value <= UInt64(UInt8.max) {
            output.append(prefix | 24)
            output.append(UInt8(value))
        } else if value <= UInt64(UInt16.max) {
            output.append(prefix | 25)
            output.append(UInt8((value >> 8) & 0xff))
            output.append(UInt8(value & 0xff))
        } else if value <= UInt64(UInt32.max) {
            output.append(prefix | 26)
            for shift in stride(from: 24, through: 0, by: -8) {
                output.append(UInt8((value >> UInt64(shift)) & 0xff))
            }
        } else {
            output.append(prefix | 27)
            for shift in stride(from: 56, through: 0, by: -8) {
                output.append(UInt8((value >> UInt64(shift)) & 0xff))
            }
        }
    }
}
