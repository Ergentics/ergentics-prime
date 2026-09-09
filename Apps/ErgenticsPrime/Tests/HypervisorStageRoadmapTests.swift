import CryptoKit
import Foundation
import XCTest

final class HypervisorStageRoadmapTests: XCTestCase {
    private func hex(_ data: Data) -> String {
        data.map { String(format: "%02x", $0) }.joined()
    }

    private func digest(_ data: Data) -> String {
        hex(Data(SHA256.hash(data: data)))
    }

    private func schema(_ projection: HypervisorStageProjection) throws -> String {
        guard case .map(let values) = try GuestCBOR.decode(projection.cbor),
              case .text(let schema)? = values["schema"] else {
            throw HypervisorStageRoadmapFailure.rejected("test.schema")
        }
        return schema
    }

    private func root(json: Data, cbor: Data, schema: String) throws -> String {
        let role: String
        switch schema {
        case HypervisorStageRoadmap.stateSchema: role = "state"
        case HypervisorStageRoadmap.transitionSchema: role = "transition"
        case HypervisorStageRoadmap.witnessSchema: role = "witness"
        default: throw HypervisorStageRoadmapFailure.rejected("test.schema_role")
        }
        return try MerkleGenesis.commit([
            GenesisLeaf(label: "schema", payload: Data(schema.utf8)),
            GenesisLeaf(label: "\(role).json", payload: json),
            GenesisLeaf(label: "\(role).cbor", payload: cbor),
        ]).root
    }

    private func jsonObject(_ value: GuestCBORValue) throws -> Any {
        switch value {
        case .text(let text): return text
        case .bool(let value): return value
        case .array(let values): return try values.map(jsonObject)
        case .map(let values):
            return try Dictionary(uniqueKeysWithValues: values.map { key, value in
                (key, try jsonObject(value))
            })
        case .bytes, .unsigned:
            throw HypervisorStageRoadmapFailure.rejected("test.json_type")
        }
    }

    private func reproject(_ projection: HypervisorStageProjection,
                           mutate: (inout [String: GuestCBORValue]) -> Void) throws -> HypervisorStageProjection {
        guard case .map(var values) = try GuestCBOR.decode(projection.cbor),
              case .text(let schema)? = values["schema"] else {
            throw HypervisorStageRoadmapFailure.rejected("test.map")
        }
        mutate(&values)
        let semantic = GuestCBORValue.map(values)
        let json = try JSONSerialization.data(withJSONObject: jsonObject(semantic),
                                               options: [.sortedKeys, .withoutEscapingSlashes])
        let cbor = try GuestCBOR.encode(semantic)
        return HypervisorStageProjection(json: json, cbor: cbor,
            root: try root(json: json, cbor: cbor, schema: schema))
    }

    private func rehash(_ projection: HypervisorStageProjection,
                        json: Data? = nil, cbor: Data? = nil) throws -> HypervisorStageProjection {
        let json = json ?? projection.json
        let cbor = cbor ?? projection.cbor
        return HypervisorStageProjection(json: json, cbor: cbor,
            root: try root(json: json, cbor: cbor, schema: try schema(projection)))
    }

    private func receiptRoot(_ receipt: HypervisorStageH1Receipt) throws -> String {
        let input = try GuestCBOR.decode(receipt.inputState.projection.cbor)
        let output = try GuestCBOR.decode(receipt.outputState.projection.cbor)
        let transition = try GuestCBOR.decode(receipt.transition.projection.cbor)
        let witnesses = try receipt.witnesses.map { try GuestCBOR.decode($0.projection.cbor) }
        let stateValue = GuestCBORValue.array([input, output])
        let witnessValue = GuestCBORValue.array(witnesses)
        let stateJSON = try JSONSerialization.data(withJSONObject: jsonObject(stateValue),
                                                   options: [.sortedKeys, .withoutEscapingSlashes])
        let transitionJSON = try JSONSerialization.data(withJSONObject: jsonObject(transition),
                                                        options: [.sortedKeys, .withoutEscapingSlashes])
        let witnessesJSON = try JSONSerialization.data(withJSONObject: jsonObject(witnessValue),
                                                       options: [.sortedKeys, .withoutEscapingSlashes])
        return try MerkleGenesis.commit([
            GenesisLeaf(label: "schema", payload: Data(HypervisorStageRoadmap.receiptSchema.utf8)),
            GenesisLeaf(label: "state.json", payload: stateJSON),
            GenesisLeaf(label: "state.cbor", payload: try GuestCBOR.encode(stateValue)),
            GenesisLeaf(label: "transition.json", payload: transitionJSON),
            GenesisLeaf(label: "transition.cbor", payload: try GuestCBOR.encode(transition)),
            GenesisLeaf(label: "witnesses.json", payload: witnessesJSON),
            GenesisLeaf(label: "witnesses.cbor", payload: try GuestCBOR.encode(witnessValue)),
        ]).root
    }

    private func replacing(_ receipt: HypervisorStageH1Receipt,
                           input: HypervisorStageNode? = nil,
                           witnesses: [HypervisorStageNode]? = nil,
                           transition: HypervisorStageNode? = nil,
                           output: HypervisorStageNode? = nil) throws -> HypervisorStageH1Receipt {
        let changed = HypervisorStageH1Receipt(inputState: input ?? receipt.inputState,
            witnesses: witnesses ?? receipt.witnesses,
            transition: transition ?? receipt.transition,
            outputState: output ?? receipt.outputState, root: "")
        return HypervisorStageH1Receipt(inputState: changed.inputState, witnesses: changed.witnesses,
            transition: changed.transition, outputState: changed.outputState,
            root: try receiptRoot(changed))
    }

    func testStage0AndH1AreDeterministicDualStreamGraphs() throws {
        let first = try HypervisorStageRoadmap.runH1PureContract()
        let second = try HypervisorStageRoadmap.runH1PureContract()
        XCTAssertEqual(first, second)
        XCTAssertEqual(first.inputState, try HypervisorStageRoadmap.stage0())
        XCTAssertEqual(first.witnesses.count, HypervisorStageH1Predicate.allCases.count)
        XCTAssertEqual(try receiptRoot(first), first.root)
        XCTAssertEqual(try HypervisorStageRoadmap.verifyH1(first).receiptRoot, first.root)
        XCTAssertEqual(digest(first.inputState.projection.json),
                       "02961fc59d904bc110f340847b0c44f1741b1e2b5f571bb91080ad5f68788b7d")
        XCTAssertEqual(digest(first.inputState.projection.cbor),
                       "a9af1fae892d4f96e52d69d997d3aacf2b91576bd55662d7cc1c4aba73a85def")
        XCTAssertEqual(first.inputState.projection.root,
                       "7d1b5ac0bfaa03f4237a873baeb01dc2581d490a96832bc5284ba5aeb8f3850d")
        XCTAssertEqual(first.root,
                       "159c6e01499532cd47c41d3f5f0d9f5594bfe2ab5a31de6e8d8f6f7e6a10db94")
    }

    func testVerifiedResultHasTheNarrowNonLiveCeiling() throws {
        let result = try HypervisorStageRoadmap.verifyH1(HypervisorStageRoadmap.runH1PureContract())
        XCTAssertEqual(result.outcome, "PASS_PURE_CONTRACT_ONLY")
        XCTAssertEqual(result.gateE, "ABSTAIN")
        XCTAssertEqual(result.authorityVector, "00000000")
        XCTAssertEqual(result.vmDisposition, "NOT_CREATED")
        XCTAssertFalse(result.nextStageAuthorized)
    }

    func testEachProjectionIndependentlyRoundTripsToTheSameSemanticValue() throws {
        let receipt = try HypervisorStageRoadmap.runH1PureContract()
        let projections = [receipt.inputState.projection] + receipt.witnesses.map(\.projection) +
            [receipt.transition.projection, receipt.outputState.projection]
        for projection in projections {
            let cbor = try GuestCBOR.decode(projection.cbor)
            let object = try JSONSerialization.jsonObject(with: projection.json)
            let json = try JSONSerialization.data(withJSONObject: object,
                                                  options: [.sortedKeys, .withoutEscapingSlashes])
            XCTAssertEqual(json, projection.json)
            XCTAssertEqual(try GuestCBOR.encode(cbor), projection.cbor)
        }
    }

    func testCanonicalJSONWhitespaceDuplicateAndUnknownFieldsRejectAfterRehash() throws {
        let receipt = try HypervisorStageRoadmap.runH1PureContract()
        let base = receipt.inputState.projection
        var whitespace = base.json; whitespace.append(10)
        let whitespaceNode = HypervisorStageNode(projection: try rehash(base, json: whitespace))
        XCTAssertThrowsError(try HypervisorStageRoadmap.verifyH1(try replacing(receipt, input: whitespaceNode)))

        let body = try XCTUnwrap(String(data: base.json, encoding: .utf8))
        let duplicate = Data(("{\"schema\":\"\(HypervisorStageRoadmap.stateSchema)\"," + body.dropFirst()).utf8)
        let duplicateNode = HypervisorStageNode(projection: try rehash(base, json: duplicate))
        XCTAssertThrowsError(try HypervisorStageRoadmap.verifyH1(try replacing(receipt, input: duplicateNode)))

        let unknown = try reproject(base) { $0["reported_pass"] = .bool(true) }
        XCTAssertThrowsError(try HypervisorStageRoadmap.verifyH1(
            try replacing(receipt, input: HypervisorStageNode(projection: unknown))))
    }

    func testCBORNonminimalTrailingAndUnknownFieldsRejectAfterRehash() throws {
        let receipt = try HypervisorStageRoadmap.runH1PureContract()
        let base = receipt.inputState.projection
        let first = try XCTUnwrap(base.cbor.first)
        XCTAssertTrue((0xa0...0xb7).contains(first))
        var nonminimal = Data([0xb8, first & 0x1f])
        nonminimal.append(base.cbor.dropFirst())
        let nonminimalNode = HypervisorStageNode(projection: try rehash(base, cbor: nonminimal))
        let nonminimalReceipt = HypervisorStageH1Receipt(inputState: nonminimalNode,
            witnesses: receipt.witnesses, transition: receipt.transition,
            outputState: receipt.outputState, root: receipt.root)
        XCTAssertThrowsError(try HypervisorStageRoadmap.verifyH1(
            nonminimalReceipt))

        var trailing = base.cbor; trailing.append(0)
        let trailingNode = HypervisorStageNode(projection: try rehash(base, cbor: trailing))
        let trailingReceipt = HypervisorStageH1Receipt(inputState: trailingNode,
            witnesses: receipt.witnesses, transition: receipt.transition,
            outputState: receipt.outputState, root: receipt.root)
        XCTAssertThrowsError(try HypervisorStageRoadmap.verifyH1(trailingReceipt))

        let unknown = try reproject(base) { $0["github_pass"] = .text("PASS") }
        XCTAssertThrowsError(try HypervisorStageRoadmap.verifyH1(
            try replacing(receipt, input: HypervisorStageNode(projection: unknown))))
    }

    func testCanonicalJSONAndCBORSemanticDivergenceRejectsWithFreshMerkleRoot() throws {
        let receipt = try HypervisorStageRoadmap.runH1PureContract()
        let base = receipt.inputState.projection
        let divergent = try reproject(base) { $0["authority_vector"] = .text("10000000") }
        let mixed = try rehash(base, json: divergent.json, cbor: base.cbor)
        XCTAssertThrowsError(try HypervisorStageRoadmap.verifyH1(
            try replacing(receipt, input: HypervisorStageNode(projection: mixed))))
    }

    func testCanonicalJSONDepthBoundRejectsBeforeSemanticJoin() throws {
        let receipt = try HypervisorStageRoadmap.runH1PureContract()
        let base = receipt.inputState.projection
        var object = try XCTUnwrap(try JSONSerialization.jsonObject(with: base.json) as? [String: Any])
        var nested: Any = "bounded"
        for _ in 0...GuestCBOR.maximumDepth { nested = [nested] }
        object["adversarial_depth"] = nested
        let json = try JSONSerialization.data(withJSONObject: object,
                                              options: [.sortedKeys, .withoutEscapingSlashes])
        let mixed = try rehash(base, json: json, cbor: base.cbor)
        XCTAssertThrowsError(try HypervisorStageRoadmap.verifyH1(
            try replacing(receipt, input: HypervisorStageNode(projection: mixed)))) { error in
            XCTAssertEqual(error as? HypervisorStageRoadmapFailure,
                           .rejected("json.structure_bound"))
        }
    }

    func testHistoricalPassCannotReplaceTheProductLocalGenesisEvenWhenFullyRehashed() throws {
        let receipt = try HypervisorStageRoadmap.runH1PureContract()
        let changed = try reproject(receipt.inputState.projection) {
            $0["lineage_disposition"] = .text("GITHUB_HISTORICAL_CONTINUATION")
            $0["authority_vector"] = .text("11111111")
            $0["gate_e"] = .text("PASS")
        }
        XCTAssertThrowsError(try HypervisorStageRoadmap.verifyH1(
            try replacing(receipt, input: HypervisorStageNode(projection: changed))))
    }

    func testCandidateSelfPromotionCannotOverrideDerivedOutput() throws {
        let receipt = try HypervisorStageRoadmap.runH1PureContract()
        let promoted = try reproject(receipt.outputState.projection) {
            $0["status"] = .text("PASS_PRODUCT_ADMISSION")
            $0["authority_vector"] = .text("10000000")
            $0["next_stage"] = .text("H2")
        }
        XCTAssertThrowsError(try HypervisorStageRoadmap.verifyH1(
            try replacing(receipt, output: HypervisorStageNode(projection: promoted))))
    }

    func testStageReorderAndPredecessorMutationRejectAfterBothStreamsAndRootChange() throws {
        let receipt = try HypervisorStageRoadmap.runH1PureContract()
        let reordered = try reproject(receipt.inputState.projection) { values in
            if case .array(var stages)? = values["stages"] {
                stages.swapAt(0, 1); values["stages"] = .array(stages)
            }
        }
        XCTAssertThrowsError(try HypervisorStageRoadmap.verifyH1(
            try replacing(receipt, input: HypervisorStageNode(projection: reordered))))

        let rebound = try reproject(receipt.inputState.projection) { values in
            if case .array(var stages)? = values["stages"], case .map(var second) = stages[1] {
                second["predecessor"] = .text("NONE"); stages[1] = .map(second)
                values["stages"] = .array(stages)
            }
        }
        XCTAssertThrowsError(try HypervisorStageRoadmap.verifyH1(
            try replacing(receipt, input: HypervisorStageNode(projection: rebound))))
    }

    func testWitnessReorderMissingAndCrossStageReuseReject() throws {
        let receipt = try HypervisorStageRoadmap.runH1PureContract()
        var reordered = receipt.witnesses; reordered.swapAt(0, 1)
        XCTAssertThrowsError(try HypervisorStageRoadmap.verifyH1(
            try replacing(receipt, witnesses: reordered)))
        XCTAssertThrowsError(try HypervisorStageRoadmap.verifyH1(
            try replacing(receipt, witnesses: Array(receipt.witnesses.dropLast()))))

        let reused = try reproject(receipt.witnesses[0].projection) {
            $0["stage_id"] = .text("H2")
            $0["predicate_id"] = .text("fixed_guest_mechanics")
        }
        var witnesses = receipt.witnesses
        witnesses[0] = HypervisorStageNode(projection: reused)
        XCTAssertThrowsError(try HypervisorStageRoadmap.verifyH1(
            try replacing(receipt, witnesses: witnesses)))
    }

    func testTransitionAndAncestrySubstitutionRejectEvenWhenRehashed() throws {
        let receipt = try HypervisorStageRoadmap.runH1PureContract()
        let changedTransition = try reproject(receipt.transition.projection) {
            $0["derived_outcome"] = .text("PASS_GATE_E")
            $0["successor_authorized"] = .bool(true)
        }
        XCTAssertThrowsError(try HypervisorStageRoadmap.verifyH1(
            try replacing(receipt, transition: HypervisorStageNode(projection: changedTransition))))

        let changedOutput = try reproject(receipt.outputState.projection) {
            $0["parent_state_roots"] = .array([.text(String(repeating: "0", count: 64))])
        }
        XCTAssertThrowsError(try HypervisorStageRoadmap.verifyH1(
            try replacing(receipt, output: HypervisorStageNode(projection: changedOutput))))
    }

    func testMerkleAndReceiptRootsRejectUppercaseAndBitChanges() throws {
        let receipt = try HypervisorStageRoadmap.runH1PureContract()
        let upper = HypervisorStageProjection(json: receipt.inputState.projection.json,
            cbor: receipt.inputState.projection.cbor,
            root: receipt.inputState.projection.root.uppercased())
        XCTAssertThrowsError(try HypervisorStageRoadmap.verifyH1(
            try replacing(receipt, input: HypervisorStageNode(projection: upper))))
        let wrong = HypervisorStageH1Receipt(inputState: receipt.inputState,
            witnesses: receipt.witnesses, transition: receipt.transition,
            outputState: receipt.outputState, root: String(repeating: "0", count: 64))
        XCTAssertThrowsError(try HypervisorStageRoadmap.verifyH1(wrong))
    }

    func testPureCoreHasNoLiveOrPersistenceSurface() throws {
        let source = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
            .deletingLastPathComponent().appendingPathComponent("Sources/HypervisorStageRoadmap.swift")
        let text = try String(contentsOf: source, encoding: .utf8)
        for forbidden in ["hv_vcpu_run", "epr_guest_run", "FileManager", "Process(",
                          "SQLite3", "SwiftUI", "AppKit", "CommandLine", "Date(", "UUID("] {
            XCTAssertFalse(text.contains(forbidden), forbidden)
        }
    }
}
