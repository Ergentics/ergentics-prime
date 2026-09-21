import CryptoKit
import Foundation
import XCTest

final class HypervisorStageH2AdmissionTests: XCTestCase {
    private let words: [UInt32] = [
        0xd2880000, 0xf2a20000, 0xd2900001, 0xf2a20001,
        0xd2980003, 0xf2a20003, 0xc8dffc04, 0xf100049f,
        0x540001c1, 0xf9400405, 0xf10004bf, 0x54000161,
        0xf9400806, 0xf9400c07, 0x8b0700c6, 0xf9000425,
        0xf9000826, 0xf9000c3f, 0xc89ffc24, 0xd5033f9f,
        0xb9000064, 0xd43bd5a0, 0xd42175a0,
    ]

    private var image: Data {
        var result = Data()
        for word in words {
            result.append(UInt8(truncatingIfNeeded: word))
            result.append(UInt8(truncatingIfNeeded: word >> 8))
            result.append(UInt8(truncatingIfNeeded: word >> 16))
            result.append(UInt8(truncatingIfNeeded: word >> 24))
        }
        return result
    }

    private func frame(_ words: [UInt64]) -> Data {
        var result = Data()
        for word in words {
            for index in 0..<8 {
                result.append(UInt8(truncatingIfNeeded: word >> (index * 8)))
            }
        }
        return result
    }

    private func hex(_ data: Data) -> String {
        data.map { String(format: "%02x", $0) }.joined()
    }

    private func digest(_ data: Data) -> String {
        hex(Data(SHA256.hash(data: data)))
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
            throw HypervisorStageH2AdmissionFailure.rejected("test.json_type")
        }
    }

    private func schema(_ projection: HypervisorStageProjection) throws -> String {
        guard case .map(let values) = try GuestCBOR.decode(projection.cbor),
              case .text(let schema)? = values["schema"] else {
            throw HypervisorStageH2AdmissionFailure.rejected("test.schema")
        }
        return schema
    }

    private func role(for schema: String) throws -> String {
        switch schema {
        case HypervisorStageH2Admission.inputStateSchema,
             HypervisorStageH2Admission.outputStateSchema:
            return "state"
        case HypervisorStageH2Admission.transitionSchema:
            return "transition"
        case HypervisorStageH2Admission.witnessSchema:
            return "witness"
        default:
            throw HypervisorStageH2AdmissionFailure.rejected("test.schema_role")
        }
    }

    private func projectionRoot(json: Data, cbor: Data, schema: String) throws -> String {
        let role = try role(for: schema)
        return try MerkleGenesis.commit([
            GenesisLeaf(label: "schema", payload: Data(schema.utf8)),
            GenesisLeaf(label: "\(role).json", payload: json),
            GenesisLeaf(label: "\(role).cbor", payload: cbor),
        ]).root
    }

    private func reproject(
        _ projection: HypervisorStageProjection,
        mutate: (inout [String: GuestCBORValue]) -> Void
    ) throws -> HypervisorStageProjection {
        guard case .map(var values) = try GuestCBOR.decode(projection.cbor),
              case .text(let schema)? = values["schema"] else {
            throw HypervisorStageH2AdmissionFailure.rejected("test.map")
        }
        mutate(&values)
        let semantic = GuestCBORValue.map(values)
        let json = try JSONSerialization.data(withJSONObject: jsonObject(semantic),
                                               options: [.sortedKeys, .withoutEscapingSlashes])
        let cbor = try GuestCBOR.encode(semantic)
        let changedSchema: String
        if case .text(let value)? = values["schema"] { changedSchema = value } else { changedSchema = schema }
        return HypervisorStageProjection(
            json: json, cbor: cbor,
            root: try projectionRoot(json: json, cbor: cbor, schema: changedSchema))
    }

    private func rehash(
        _ projection: HypervisorStageProjection,
        json: Data? = nil,
        cbor: Data? = nil
    ) throws -> HypervisorStageProjection {
        let json = json ?? projection.json
        let cbor = cbor ?? projection.cbor
        let schema = try schema(projection)
        return HypervisorStageProjection(
            json: json, cbor: cbor,
            root: try projectionRoot(json: json, cbor: cbor, schema: schema))
    }

    private func receiptRoot(_ receipt: HypervisorStageH2Receipt) throws -> String {
        let input = try GuestCBOR.decode(receipt.inputState.projection.cbor)
        let output = try GuestCBOR.decode(receipt.outputState.projection.cbor)
        let transition = try GuestCBOR.decode(receipt.transition.projection.cbor)
        let witnesses = try receipt.witnesses.map { try GuestCBOR.decode($0.projection.cbor) }
        let state = GuestCBORValue.array([input, output])
        let witnessSet = GuestCBORValue.array(witnesses)
        let stateJSON = try JSONSerialization.data(withJSONObject: jsonObject(state),
                                                   options: [.sortedKeys, .withoutEscapingSlashes])
        let transitionJSON = try JSONSerialization.data(withJSONObject: jsonObject(transition),
                                                        options: [.sortedKeys, .withoutEscapingSlashes])
        let witnessJSON = try JSONSerialization.data(withJSONObject: jsonObject(witnessSet),
                                                     options: [.sortedKeys, .withoutEscapingSlashes])
        return try MerkleGenesis.commit([
            GenesisLeaf(label: "schema", payload: Data(HypervisorStageH2Admission.receiptSchema.utf8)),
            GenesisLeaf(label: "state.json", payload: stateJSON),
            GenesisLeaf(label: "state.cbor", payload: try GuestCBOR.encode(state)),
            GenesisLeaf(label: "transition.json", payload: transitionJSON),
            GenesisLeaf(label: "transition.cbor", payload: try GuestCBOR.encode(transition)),
            GenesisLeaf(label: "witnesses.json", payload: witnessJSON),
            GenesisLeaf(label: "witnesses.cbor", payload: try GuestCBOR.encode(witnessSet)),
        ]).root
    }

    private func replacing(
        _ receipt: HypervisorStageH2Receipt,
        input: HypervisorStageNode? = nil,
        witnesses: [HypervisorStageNode]? = nil,
        transition: HypervisorStageNode? = nil,
        output: HypervisorStageNode? = nil
    ) throws -> HypervisorStageH2Receipt {
        let changed = HypervisorStageH2Receipt(
            inputState: input ?? receipt.inputState,
            witnesses: witnesses ?? receipt.witnesses,
            transition: transition ?? receipt.transition,
            outputState: output ?? receipt.outputState,
            root: "")
        return HypervisorStageH2Receipt(
            inputState: changed.inputState, witnesses: changed.witnesses,
            transition: changed.transition, outputState: changed.outputState,
            root: try receiptRoot(changed))
    }

    private func map(_ projection: HypervisorStageProjection) throws -> [String: GuestCBORValue] {
        guard case .map(let values) = try GuestCBOR.decode(projection.cbor) else {
            throw HypervisorStageH2AdmissionFailure.rejected("test.not_map")
        }
        return values
    }

    func testStaticAdmissionIsDeterministicAndNonAuthoritative() throws {
        let first = try HypervisorStageH2Admission.runStaticAdmission()
        let second = try HypervisorStageH2Admission.runStaticAdmission()
        XCTAssertEqual(first, second)
        XCTAssertEqual(first.witnesses.count, 8)
        XCTAssertEqual(first.witnesses.count, HypervisorStageH2Predicate.allCases.count)
        XCTAssertEqual(try receiptRoot(first), first.root)
        XCTAssertEqual(first.witnesses.map(\.projection.root), [
            "1a4a51d63a6d24c5e2dba69fd3a24e392f1adbf3d4fb2bf4aaf665bbf791c810",
            "f793e59c68b418dcad2a6c110c9f268e3cc9972a14aeaa48885ed211a62a2c90",
            "2aa8385efb8a06e4602738ed5de93c596e4f02fb85585eccf54b34d2cbeb2da5",
            "1affe61cf11a9dcd23eabe808f5d89060fe8fed5ad8aea53a85133b9c86722c1",
            "d24c8ec285440f165c11ec143699ac49cb654faecd56fe88aa9ca4607125d437",
            "be0e3ce833bef606fa2a89ee7716d6514c61212c47f9c744237391b4984898e5",
            "fa78e9a3311c35c9536d1596b6d1883d755f87a77ea5a3534c329c5fe1636938",
            "3b0b38a252c626b334d0b6e188015ebd140f9c9f90804796432bdb8e11e2e8b2",
        ])
        XCTAssertEqual(first.transition.projection.root,
                       "10ceb9ba81e866a8dc21ad6b8e8ab0f06143dd14d87e66e1cdec344c4628cf1c")
        XCTAssertEqual(first.outputState.projection.root,
                       "6b880870ce4216c9c0793ef198695920323ff23cf6e79b0d8a6cca1f2d8d5d66")
        XCTAssertEqual(first.root,
                       "50a3a244914f5987c3552a0d68faaedef29d17d856d7d645f6d834b5e32c20ca")

        let verified = try HypervisorStageH2Admission.verifyStaticReceipt(first)
        XCTAssertEqual(verified.outcome, "PASS_H2_STATIC_ADMISSION_ONLY")
        XCTAssertEqual(verified.inputReceiptRoot, HypervisorStageH2Admission.h1ReceiptRoot)
        XCTAssertEqual(verified.inputStateRoot, HypervisorStageH2Admission.h1OutputStateRoot)
        XCTAssertEqual(verified.gateE, "ABSTAIN")
        XCTAssertEqual(verified.authorityVector, "00000000")
        XCTAssertEqual(verified.vmDisposition, "NOT_CREATED")
        XCTAssertFalse(verified.liveExecutionAuthorized)
        XCTAssertFalse(verified.stageCompleted)

        let output = try map(first.outputState.projection)
        XCTAssertEqual(output["next_stage"], .text("NONE"))
        XCTAssertEqual(output["vm_entry_count"], .text("0"))
        XCTAssertEqual(output["h2_live_execution_authorized"], .bool(false))
        XCTAssertEqual(output["stage_complete"], .bool(false))
    }

    func testFrozenH1GuestNativeFramesPlanAndSnapshotJoin() throws {
        let receipt = try HypervisorStageH2Admission.runStaticAdmission()
        XCTAssertEqual(receipt.inputState.projection.root,
                       "5afb4febb330a5ca6049a9c0c8c71d6a68e963d19615859ee8b441ad7017b46c")
        XCTAssertEqual(image.count, 92)
        XCTAssertEqual(words.count, 23)
        XCTAssertEqual(digest(image),
                       "67290a73b53047374096142356a35338f6722d724586cc10373dfecab9a4cc44")
        XCTAssertEqual(Data(image[80..<84]), Data([0x64, 0x00, 0x00, 0xb9]))

        let pointer = try XCTUnwrap(epr_guest_image_bytes())
        let size = epr_guest_image_size()
        XCTAssertEqual(size, 92)
        XCTAssertEqual(Data(bytes: pointer, count: size), image)
        XCTAssertEqual(epr_guest_image_load_address(), 0x1000_0000)
        XCTAssertEqual(epr_guest_doorbell_instruction_offset(), 80)
        XCTAssertEqual(frame([1, 1, 19, 23]), GuestContract.request)
        XCTAssertEqual(frame([1, 1, 42, 0]), GuestContract.reply)

        let commitment = try MerkleGenesis.commit([
            GenesisLeaf(label: "guest_image", payload: image),
            GenesisLeaf(label: "reply", payload: frame([1, 1, 42, 0])),
            GenesisLeaf(label: "request", payload: frame([1, 1, 19, 23])),
            GenesisLeaf(label: "schema", payload: Data(GuestContract.schema.utf8)),
        ])
        XCTAssertEqual(commitment.root,
                       "37b6aa19da562bf99810c8169e091357bc4e789a82b50366e0752ffb1a9d89df")

        let planWitness = try map(receipt.witnesses[5].projection)
        guard case .map(let evidence)? = planWitness["evidence"] else { return XCTFail("evidence") }
        XCTAssertEqual(evidence["architectural_channels"], .text("UNASSESSED"))
        XCTAssertEqual(evidence["architectural_channels_raw"], .text("0"))
        XCTAssertEqual(evidence["endpoint"], .text("0x1000c000"))
        XCTAssertEqual(evidence["store_pc"], .text("0x10000050"))
        XCTAssertEqual(evidence["stack_top"], .text("0x1000bff0"))
        guard case .array(let regions)? = evidence["mapped_regions"] else { return XCTFail("regions") }
        XCTAssertEqual(regions.count, 3)
    }

    func testEveryProjectionAndOuterReceiptRoundTripsIndependently() throws {
        let receipt = try HypervisorStageH2Admission.runStaticAdmission()
        let projections = [receipt.inputState.projection] + receipt.witnesses.map(\.projection) +
            [receipt.transition.projection, receipt.outputState.projection]
        for projection in projections {
            let cbor = try GuestCBOR.decode(projection.cbor)
            XCTAssertEqual(try GuestCBOR.encode(cbor), projection.cbor)
            let object = try JSONSerialization.jsonObject(with: projection.json)
            let json = try JSONSerialization.data(withJSONObject: object,
                                                  options: [.sortedKeys, .withoutEscapingSlashes])
            XCTAssertEqual(json, projection.json)
            XCTAssertEqual(projection.root, try projectionRoot(
                json: projection.json, cbor: projection.cbor, schema: try schema(projection)))
            XCTAssertLessThanOrEqual(projection.json.count, 65_536)
            XCTAssertLessThanOrEqual(projection.cbor.count, 65_536)
        }
        XCTAssertEqual(receipt.root, try receiptRoot(receipt))

        let original = receipt.witnesses[0].projection
        let changedCBOR = try reproject(original) {
            $0["outcome"] = .text("REJECTED")
        }.cbor
        let mismatched = try rehash(original, cbor: changedCBOR)
        var witnesses = receipt.witnesses
        witnesses[0] = HypervisorStageNode(projection: mismatched)
        XCTAssertThrowsError(try HypervisorStageH2Admission.verifyStaticReceipt(
            try replacing(receipt, witnesses: witnesses)))

        let predicates = try receipt.witnesses.enumerated().map { index, witness -> String in
            let values = try map(witness.projection)
            XCTAssertEqual(values["position"], .text(String(index)))
            guard case .text(let predicate)? = values["predicate_id"] else {
                throw HypervisorStageH2AdmissionFailure.rejected("test.predicate")
            }
            return predicate
        }
        XCTAssertEqual(predicates, HypervisorStageH2Predicate.allCases.map(\.rawValue))
    }

    func testFreshRootH1LineageSubstitutionRejects() throws {
        let receipt = try HypervisorStageH2Admission.runStaticAdmission()
        let changed = try reproject(receipt.inputState.projection) {
            $0["status"] = .text("PASS_GATE_E")
            $0["authority_vector"] = .text("11111111")
            $0["gate_e"] = .text("PASS")
        }
        let candidate = try replacing(
            receipt, input: HypervisorStageNode(projection: changed))
        XCTAssertThrowsError(try HypervisorStageH2Admission.verifyStaticReceipt(candidate))
    }

    func testFreshRootAuthorityVMAndSuccessorSelfPromotionReject() throws {
        let receipt = try HypervisorStageH2Admission.runStaticAdmission()
        let mutations: [(String, GuestCBORValue)] = [
            ("authority_delta", .text("10000000")),
            ("authority_vector", .text("10000000")),
            ("gate_e", .text("PASS")),
            ("high_value_ingress", .text("ALLOWED")),
            ("trusted_egress", .text("ALLOWED")),
            ("vm_disposition", .text("CREATED")),
            ("vm_entry_count", .text("1")),
            ("next_stage", .text("H2_LIVE")),
            ("h2_live_execution_authorized", .bool(true)),
            ("stage_complete", .bool(true)),
        ]
        for (field, value) in mutations {
            let changed = try reproject(receipt.outputState.projection) { $0[field] = value }
            let candidate = try replacing(
                receipt, output: HypervisorStageNode(projection: changed))
            XCTAssertThrowsError(
                try HypervisorStageH2Admission.verifyStaticReceipt(candidate), field)
        }
        let transition = try reproject(receipt.transition.projection) {
            $0["successor_authorized"] = .bool(true)
            $0["derived_outcome"] = .text("PASS_GATE_E")
        }
        XCTAssertThrowsError(try HypervisorStageH2Admission.verifyStaticReceipt(
            try replacing(receipt, transition: HypervisorStageNode(projection: transition))))
    }

    func testWitnessInventoryRoleAndEachFactMutationReject() throws {
        let receipt = try HypervisorStageH2Admission.runStaticAdmission()
        var reordered = receipt.witnesses
        reordered.swapAt(0, 1)
        XCTAssertThrowsError(try HypervisorStageH2Admission.verifyStaticReceipt(
            try replacing(receipt, witnesses: reordered)))
        XCTAssertThrowsError(try HypervisorStageH2Admission.verifyStaticReceipt(
            try replacing(receipt, witnesses: Array(receipt.witnesses.dropLast()))))
        XCTAssertThrowsError(try HypervisorStageH2Admission.verifyStaticReceipt(
            try replacing(receipt, witnesses: receipt.witnesses + [receipt.witnesses[0]])))

        let evidenceFields = [
            "h1_receipt_root", "authority_vector", "sha256", "load_ipa",
            "request_little_endian_hex", "architectural_channels", "merkle_root", "gate_e",
        ]
        for index in receipt.witnesses.indices {
            let changed = try reproject(receipt.witnesses[index].projection) { values in
                guard case .map(var evidence)? = values["evidence"] else { return }
                evidence[evidenceFields[index]] = .text("MUTATED")
                values["evidence"] = .map(evidence)
            }
            var witnesses = receipt.witnesses
            witnesses[index] = HypervisorStageNode(projection: changed)
            XCTAssertThrowsError(try HypervisorStageH2Admission.verifyStaticReceipt(
                try replacing(receipt, witnesses: witnesses)), "witness \(index)")
        }

        let crossRole = try reproject(receipt.witnesses[0].projection) {
            $0["schema"] = .text(HypervisorStageH2Admission.outputStateSchema)
        }
        var witnesses = receipt.witnesses
        witnesses[0] = HypervisorStageNode(projection: crossRole)
        XCTAssertThrowsError(try HypervisorStageH2Admission.verifyStaticReceipt(
            try replacing(receipt, witnesses: witnesses)))
    }

    func testCanonicalAmbiguityBoundsUnknownFieldsAndRootsReject() throws {
        let receipt = try HypervisorStageH2Admission.runStaticAdmission()
        let base = receipt.witnesses[0].projection

        var whitespace = base.json
        whitespace.append(10)
        var witnesses = receipt.witnesses
        witnesses[0] = HypervisorStageNode(projection: try rehash(base, json: whitespace))
        XCTAssertThrowsError(try HypervisorStageH2Admission.verifyStaticReceipt(
            try replacing(receipt, witnesses: witnesses)))

        var trailing = base.cbor
        trailing.append(0)
        witnesses = receipt.witnesses
        witnesses[0] = HypervisorStageNode(projection: try rehash(base, cbor: trailing))
        XCTAssertThrowsError(try HypervisorStageH2Admission.verifyStaticReceipt(
            try replacing(receipt, witnesses: witnesses)))

        let first = try XCTUnwrap(base.cbor.first)
        XCTAssertTrue((0xa0...0xb7).contains(first))
        var nonminimal = Data([0xb8, first & 0x1f])
        nonminimal.append(base.cbor.dropFirst())
        witnesses = receipt.witnesses
        witnesses[0] = HypervisorStageNode(projection: try rehash(base, cbor: nonminimal))
        XCTAssertThrowsError(try HypervisorStageH2Admission.verifyStaticReceipt(
            try replacing(receipt, witnesses: witnesses)))

        let unknown = try reproject(base) { $0["reported_pass"] = .bool(true) }
        witnesses = receipt.witnesses
        witnesses[0] = HypervisorStageNode(projection: unknown)
        XCTAssertThrowsError(try HypervisorStageH2Admission.verifyStaticReceipt(
            try replacing(receipt, witnesses: witnesses)))

        let uppercase = HypervisorStageProjection(
            json: base.json, cbor: base.cbor, root: base.root.uppercased())
        witnesses = receipt.witnesses
        witnesses[0] = HypervisorStageNode(projection: uppercase)
        XCTAssertThrowsError(try HypervisorStageH2Admission.verifyStaticReceipt(
            try replacing(receipt, witnesses: witnesses)))

        let oversized = HypervisorStageProjection(
            json: Data(repeating: 0x20, count: 65_537), cbor: base.cbor,
            root: String(repeating: "0", count: 64))
        witnesses = receipt.witnesses
        witnesses[0] = HypervisorStageNode(projection: oversized)
        XCTAssertThrowsError(try HypervisorStageH2Admission.verifyStaticReceipt(
            HypervisorStageH2Receipt(
                inputState: receipt.inputState, witnesses: witnesses,
                transition: receipt.transition, outputState: receipt.outputState,
                root: receipt.root)))
    }

    func testConcurrentStaticAdmissionsRemainValueIdentical() async throws {
        let expected = try HypervisorStageH2Admission.runStaticAdmission()
        let values = try await withThrowingTaskGroup(
            of: HypervisorStageH2Receipt.self,
            returning: [HypervisorStageH2Receipt].self
        ) { group in
            for _ in 0..<8 {
                group.addTask { try HypervisorStageH2Admission.runStaticAdmission() }
            }
            var results: [HypervisorStageH2Receipt] = []
            for try await value in group { results.append(value) }
            return results
        }
        XCTAssertEqual(values.count, 8)
        XCTAssertTrue(values.allSatisfy { $0 == expected })
    }

    func testSourceAndProjectHaveOnlyTheFrozenStaticSurface() throws {
        let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
        let source = try String(contentsOf: root.appendingPathComponent(
            "Sources/HypervisorStageH2Admission.swift"), encoding: .utf8)
        for call in [
            "epr_guest_image_bytes()", "epr_guest_image_size()",
            "epr_guest_image_load_address()", "epr_guest_doorbell_instruction_offset()",
        ] {
            XCTAssertEqual(source.components(separatedBy: call).count - 1, 1, call)
        }
        for forbidden in [
            "epr_guest_run(", "epr_rust_guest_run(", "epr_guest_reserve(",
            "epr_guest_cancel(", "epr_guest_reservation_", "hv_", "import Hypervisor",
            "FileManager", "Process(", "SQLite3", "SwiftUI", "AppKit", "CommandLine",
            "Date(", "UUID(", "getenv(", "dlopen(", "dlsym(",
        ] {
            XCTAssertFalse(source.contains(forbidden), forbidden)
        }

        let project = try String(contentsOf: root.appendingPathComponent(
            "ErgenticsProvenance.xcodeproj/project.pbxproj"), encoding: .utf8)
        for id in [
            "B10000000000000000000170", "B10000000000000000000171",
            "B20000000000000000000170", "B20000000000000000000171",
            "B20000000000000000000172", "B20000000000000000000173",
        ] {
            XCTAssertTrue(project.contains(id), id)
        }
        XCTAssertEqual(project.components(separatedBy: "DEAD_CODE_STRIPPING = YES;").count - 1, 2)
        XCTAssertTrue(project.contains(
            "COMPILER_FLAGS = \"-fno-autolink -ffunction-sections -fvisibility=hidden\""))
        let testFrameworkStart = try XCTUnwrap(project.range(
            of: "B50000000000000000000005 /* Frameworks */"))
        let testFrameworkTail = project[testFrameworkStart.lowerBound...]
        let testFrameworkEnd = try XCTUnwrap(testFrameworkTail.range(of: "/* End PBXFrameworksBuildPhase section */"))
        let testFrameworkBlock = testFrameworkTail[..<testFrameworkEnd.lowerBound]
        XCTAssertFalse(testFrameworkBlock.contains("Hypervisor.framework"))
    }
}
