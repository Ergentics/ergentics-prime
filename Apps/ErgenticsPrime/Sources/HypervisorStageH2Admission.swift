import CoreFoundation
import CryptoKit
import Foundation

enum HypervisorStageH2AdmissionFailure: Error, Equatable, Sendable {
    case rejected(String)
}

enum HypervisorStageH2Predicate: String, CaseIterable, Sendable {
    case h1Receipt = "h1_receipt_reconstructed_exact"
    case h1Authority = "h1_authority_ceiling_preserved"
    case imageBytes = "fixed_guest_image_bytes_exact"
    case nativeMetadata = "fixed_guest_native_metadata_exact"
    case frames = "fixed_request_reply_exact"
    case capabilityPlan = "fixed_capability_and_register_plan_exact"
    case snapshot = "fixed_snapshot_commitment_exact"
    case noEffects = "no_live_or_persistence_effects"
}

struct HypervisorStageH2Receipt: Equatable, Sendable {
    let inputState: HypervisorStageNode
    let witnesses: [HypervisorStageNode]
    let transition: HypervisorStageNode
    let outputState: HypervisorStageNode
    let root: String
}

struct HypervisorStageH2VerifiedResult: Equatable, Sendable {
    let outcome: String
    let receiptRoot: String
    let inputReceiptRoot: String
    let inputStateRoot: String
    let outputStateRoot: String
    let gateE: String
    let authorityVector: String
    let vmDisposition: String
    let liveExecutionAuthorized: Bool
    let stageCompleted: Bool
}

private enum HypervisorStageH2ProjectionRole: String {
    case state
    case transition
    case witness

    var jsonLabel: String { "\(rawValue).json" }
    var cborLabel: String { "\(rawValue).cbor" }
}

private struct HypervisorStageH2NativeObservation: Equatable {
    let image: Data
    let size: Int
    let loadIPA: UInt64
    let doorbellOffset: UInt64
}

private struct HypervisorStageH2Region: Equatable {
    let objectID: UInt64
    let role: String
    let ipa: UInt64
    let length: UInt64
    let rights: UInt64
    let rightsName: String
}

/// Zero-argument, static-only H2 admission. The only native calls are four
/// immutable image accessors. This type has no VM/run/reservation/cancellation,
/// filesystem, process, clock, environment, journal, SQLite, UI or network
/// surface. A PASS is a data-integrity result only: it cannot authorize live H2,
/// complete H2, select a candidate, or move Gate E away from ABSTAIN/00000000.
enum HypervisorStageH2Admission {
    static let roadmapID = "ergentics.provenance.hypervisor-local-v1"
    static let productID = "com.ergentics.provenance"
    static let stageID = "hypervisor_tiny_fixed_guest_mechanics_v1"
    static let maximumStreamBytes = 65_536

    static let inputStateSchema = "ergentics.provenance.hypervisor-stage.state.v1"
    static let outputStateSchema = "ergentics.provenance.hypervisor-stage.h2-static.state.v1"
    static let witnessSchema = "ergentics.provenance.hypervisor-stage.h2-static.witness.v1"
    static let transitionSchema = "ergentics.provenance.hypervisor-stage.h2-static.transition.v1"
    static let receiptSchema = "ergentics.provenance.hypervisor-stage.h2-static.receipt.v1"

    static let h1ReceiptRoot = "159c6e01499532cd47c41d3f5f0d9f5594bfe2ab5a31de6e8d8f6f7e6a10db94"
    static let h1OutputStateRoot = "5afb4febb330a5ca6049a9c0c8c71d6a68e963d19615859ee8b441ad7017b46c"
    static let guestImageSHA256 = "67290a73b53047374096142356a35338f6722d724586cc10373dfecab9a4cc44"
    static let snapshotRoot = "37b6aa19da562bf99810c8169e091357bc4e789a82b50366e0752ffb1a9d89df"

    private static let imageLoadIPA: UInt64 = 0x1000_0000
    private static let doorbellOffset: UInt64 = 80
    private static let doorbellIPA: UInt64 = 0x1000_c000
    private static let stackTop: UInt64 = 0x1000_bff0
    private static let initialSCTLR: UInt64 = 0x30d0_0800
    private static let initialCPSR: UInt64 = 0x3c5
    private static let imageWords: [UInt32] = [
        0xd2880000, 0xf2a20000, 0xd2900001, 0xf2a20001,
        0xd2980003, 0xf2a20003, 0xc8dffc04, 0xf100049f,
        0x540001c1, 0xf9400405, 0xf10004bf, 0x54000161,
        0xf9400806, 0xf9400c07, 0x8b0700c6, 0xf9000425,
        0xf9000826, 0xf9000c3f, 0xc89ffc24, 0xd5033f9f,
        0xb9000064, 0xd43bd5a0, 0xd42175a0,
    ]
    private static let regions = [
        HypervisorStageH2Region(objectID: 1, role: "code", ipa: 0x1000_0000,
                                length: 16_384, rights: 5, rightsName: "READ_EXECUTE"),
        HypervisorStageH2Region(objectID: 2, role: "request", ipa: 0x1000_4000,
                                length: 16_384, rights: 1, rightsName: "READ_ONLY"),
        HypervisorStageH2Region(objectID: 3, role: "reply", ipa: 0x1000_8000,
                                length: 16_384, rights: 3, rightsName: "READ_WRITE"),
    ]

    /// The sole observational production entry for this slice.
    static func runStaticAdmission() throws -> HypervisorStageH2Receipt {
        let h1 = try reconstructedH1()
        let native = try captureNativeObservation()
        let results = HypervisorStageH2Predicate.allCases.map {
            evaluate($0, h1: h1, native: native)
        }
        guard results.allSatisfy({ $0 }) else { throw failure("predicate") }
        let receipt = try constructReceipt(h1: h1, native: native, results: results)
        _ = try verifyStaticReceipt(receipt)
        return receipt
    }

    /// Pure receipt reconstruction for mutation tests and later readers. This
    /// accepts data but never turns verified data into an execution capability.
    /// It performs no native call and reconstructs only the frozen static facts.
    static func verifyStaticReceipt(
        _ receipt: HypervisorStageH2Receipt
    ) throws -> HypervisorStageH2VerifiedResult {
        let h1 = try reconstructedH1()
        guard receipt.inputState == h1.outputState else { throw failure("input.exact") }
        let input = try verifyProjection(receipt.inputState.projection,
                                         schema: inputStateSchema, role: .state)
        let expectedInput = try verifyProjection(h1.outputState.projection,
                                                 schema: inputStateSchema, role: .state)
        guard input == expectedInput else { throw failure("input.semantic") }

        let native = literalNativeObservation()
        let results = HypervisorStageH2Predicate.allCases.map {
            evaluate($0, h1: h1, native: native)
        }
        guard results.allSatisfy({ $0 }),
              receipt.witnesses.count == HypervisorStageH2Predicate.allCases.count else {
            throw failure("witness.inventory")
        }
        for index in HypervisorStageH2Predicate.allCases.indices {
            let actual = try verifyProjection(receipt.witnesses[index].projection,
                                              schema: witnessSchema, role: .witness)
            let expected = witnessSemantic(predicate: HypervisorStageH2Predicate.allCases[index],
                                           position: index, h1: h1, native: native,
                                           satisfied: results[index])
            guard actual == expected else { throw failure("witness.\(index)") }
        }

        let transition = try verifyProjection(receipt.transition.projection,
                                              schema: transitionSchema, role: .transition)
        guard transition == transitionSemantic(witnesses: receipt.witnesses) else {
            throw failure("transition.exact")
        }
        let output = try verifyProjection(receipt.outputState.projection,
                                          schema: outputStateSchema, role: .state)
        guard output == outputStateSemantic(transitionRoot: receipt.transition.projection.root) else {
            throw failure("output.exact")
        }
        let leaves = try receiptLeaves(input: receipt.inputState,
                                       witnesses: receipt.witnesses,
                                       transition: receipt.transition,
                                       output: receipt.outputState)
        guard try MerkleGenesis.verify(leaves, expectedRoot: receipt.root) else {
            throw failure("receipt.root")
        }
        return HypervisorStageH2VerifiedResult(
            outcome: "PASS_H2_STATIC_ADMISSION_ONLY",
            receiptRoot: receipt.root,
            inputReceiptRoot: h1ReceiptRoot,
            inputStateRoot: h1OutputStateRoot,
            outputStateRoot: receipt.outputState.projection.root,
            gateE: "ABSTAIN",
            authorityVector: "00000000",
            vmDisposition: "NOT_CREATED",
            liveExecutionAuthorized: false,
            stageCompleted: false)
    }

    private static func reconstructedH1() throws -> HypervisorStageH1Receipt {
        let h1 = try HypervisorStageRoadmap.runH1PureContract()
        let verified = try HypervisorStageRoadmap.verifyH1(h1)
        guard h1.root == h1ReceiptRoot,
              h1.outputState.projection.root == h1OutputStateRoot,
              verified.outcome == "PASS_PURE_CONTRACT_ONLY",
              verified.receiptRoot == h1ReceiptRoot,
              verified.gateE == "ABSTAIN",
              verified.authorityVector == "00000000",
              verified.vmDisposition == "NOT_CREATED",
              !verified.nextStageAuthorized else {
            throw failure("h1.reconstruction")
        }
        return h1
    }

    private static func captureNativeObservation() throws -> HypervisorStageH2NativeObservation {
        let pointer = epr_guest_image_bytes()
        let size = epr_guest_image_size()
        let loadIPA = epr_guest_image_load_address()
        let offset = epr_guest_doorbell_instruction_offset()
        guard let pointer, size == 92 else { throw failure("native.copy_size") }

        // One owned copy closes the native pointer lifetime before any identity
        // predicate is evaluated. The pointer is never retained or reread.
        let image = Data(bytes: pointer, count: size)
        let observation = HypervisorStageH2NativeObservation(
            image: image, size: size, loadIPA: loadIPA, doorbellOffset: offset)
        guard observation == literalNativeObservation() else {
            throw failure("native.exact")
        }
        return observation
    }

    private static func literalNativeObservation() -> HypervisorStageH2NativeObservation {
        let image = literalImage()
        return HypervisorStageH2NativeObservation(
            image: image, size: image.count, loadIPA: imageLoadIPA,
            doorbellOffset: doorbellOffset)
    }

    private static func constructReceipt(
        h1: HypervisorStageH1Receipt,
        native: HypervisorStageH2NativeObservation,
        results: [Bool]
    ) throws -> HypervisorStageH2Receipt {
        let witnesses = try zip(HypervisorStageH2Predicate.allCases, results).enumerated().map {
            index, pair in
            HypervisorStageNode(projection: try project(
                witnessSemantic(predicate: pair.0, position: index, h1: h1,
                                native: native, satisfied: pair.1),
                schema: witnessSchema, role: .witness))
        }
        let transition = HypervisorStageNode(projection: try project(
            transitionSemantic(witnesses: witnesses), schema: transitionSchema,
            role: .transition))
        let output = HypervisorStageNode(projection: try project(
            outputStateSemantic(transitionRoot: transition.projection.root),
            schema: outputStateSchema, role: .state))
        let partial = HypervisorStageH2Receipt(
            inputState: h1.outputState, witnesses: witnesses,
            transition: transition, outputState: output, root: "")
        let root = try MerkleGenesis.commit(receiptLeaves(
            input: partial.inputState, witnesses: partial.witnesses,
            transition: partial.transition, output: partial.outputState)).root
        return HypervisorStageH2Receipt(
            inputState: partial.inputState, witnesses: partial.witnesses,
            transition: partial.transition, outputState: partial.outputState, root: root)
    }

    private static func evaluate(
        _ predicate: HypervisorStageH2Predicate,
        h1: HypervisorStageH1Receipt,
        native: HypervisorStageH2NativeObservation
    ) -> Bool {
        switch predicate {
        case .h1Receipt:
            return h1.root == h1ReceiptRoot &&
                h1.outputState.projection.root == h1OutputStateRoot
        case .h1Authority:
            guard let verified = try? HypervisorStageRoadmap.verifyH1(h1) else { return false }
            return verified.gateE == "ABSTAIN" && verified.authorityVector == "00000000" &&
                verified.vmDisposition == "NOT_CREATED" && !verified.nextStageAuthorized
        case .imageBytes:
            return native.image == literalImage() && native.size == 92 &&
                digest(native.image) == guestImageSHA256
        case .nativeMetadata:
            return native.loadIPA == imageLoadIPA && native.doorbellOffset == doorbellOffset &&
                native.image.count == native.size && native.image.count >= 84 &&
                Data(native.image[80..<84]) == Data([0x64, 0x00, 0x00, 0xb9])
        case .frames:
            let request = frame([1, 1, 19, 23])
            let reply = frame([1, 1, 42, 0])
            return request.count == 32 && reply.count == 32 &&
                request == GuestContract.request && reply == GuestContract.reply &&
                GuestContract.schema == "ergentics.hypervisor.guest.snapshot.v1"
        case .capabilityPlan:
            return capabilityPlanIsExact()
        case .snapshot:
            guard let root = try? snapshotCommitment(image: native.image) else { return false }
            return root == snapshotRoot &&
                (try? GuestContract.validateSnapshot(
                    image: native.image, request: frame([1, 1, 19, 23]),
                    reply: frame([1, 1, 42, 0]), expectedRoot: root)) == true
        case .noEffects:
            return effectSemantic().allSatisfy { key, value in
                key == "native_image_accessor_read" ? value == .bool(true) : value == .bool(false)
            }
        }
    }

    private static func witnessSemantic(
        predicate: HypervisorStageH2Predicate,
        position: Int,
        h1: HypervisorStageH1Receipt,
        native: HypervisorStageH2NativeObservation,
        satisfied: Bool
    ) -> GuestCBORValue {
        .map([
            "authority_delta": .text("00000000"),
            "evidence": evidenceSemantic(predicate: predicate, h1: h1, native: native),
            "observed": .bool(satisfied),
            "outcome": .text(satisfied ? "SATISFIED" : "REJECTED"),
            "position": .text(String(position)),
            "predicate_id": .text(predicate.rawValue),
            "producer_scope": .text("PURE_DETERMINISTIC_IN_IMAGE_RECONSTRUCTION"),
            "roadmap_id": .text(roadmapID),
            "schema": .text(witnessSchema),
            "stage_id": .text(stageID),
            "vm_disposition": .text("NOT_CREATED"),
        ])
    }

    private static func evidenceSemantic(
        predicate: HypervisorStageH2Predicate,
        h1: HypervisorStageH1Receipt,
        native: HypervisorStageH2NativeObservation
    ) -> GuestCBORValue {
        switch predicate {
        case .h1Receipt:
            return .map([
                "h1_outcome": .text("PASS_PURE_CONTRACT_ONLY"),
                "h1_receipt_root": .text(h1.root),
                "h1_state_root": .text(h1.outputState.projection.root),
                "verification": .text("EXACT_DUAL_STREAM_RECEIPT_RECONSTRUCTION"),
            ])
        case .h1Authority:
            return .map([
                "authority_delta": .text("00000000"),
                "authority_vector": .text("00000000"),
                "gate_e": .text("ABSTAIN"),
                "high_value_ingress": .text("DENIED"),
                "next_stage_authorized": .bool(false),
                "trusted_egress": .text("DENIED"),
                "vm_disposition": .text("NOT_CREATED"),
                "vm_entry_count": .text("0"),
            ])
        case .imageBytes:
            return .map([
                "byte_count": .text(String(native.image.count)),
                "image_hex": .text(hex(native.image)),
                "instruction_count": .text(String(imageWords.count)),
                "instruction_words": .array(imageWords.map { .text(hexWord($0)) }),
                "sha256": .text(digest(native.image)),
            ])
        case .nativeMetadata:
            return .map([
                "allowed_calls": .array([
                    .text("epr_guest_image_bytes"),
                    .text("epr_guest_image_size"),
                    .text("epr_guest_image_load_address"),
                    .text("epr_guest_doorbell_instruction_offset"),
                ]),
                "call_count": .text("4"),
                "copied_image_count": .text("1"),
                "doorbell_instruction_hex": .text("640000b9"),
                "doorbell_instruction_offset": .text(String(native.doorbellOffset)),
                "image_size": .text(String(native.size)),
                "load_ipa": .text(hexAddress(native.loadIPA)),
            ])
        case .frames:
            return .map([
                "reply_little_endian_hex": .text(hex(frame([1, 1, 42, 0]))),
                "reply_words_u64": .array([1, 1, 42, 0].map { .text(String($0)) }),
                "request_little_endian_hex": .text(hex(frame([1, 1, 19, 23]))),
                "request_words_u64": .array([1, 1, 19, 23].map { .text(String($0)) }),
                "schema": .text(GuestContract.schema),
            ])
        case .capabilityPlan:
            return capabilityEvidenceSemantic()
        case .snapshot:
            return .map([
                "leaf_labels": .array(["guest_image", "reply", "request", "schema"].map { .text($0) }),
                "merkle_root": .text((try? snapshotCommitment(image: native.image)) ?? "REJECTED"),
                "schema": .text(GuestContract.schema),
            ])
        case .noEffects:
            return .map([
                "authority_delta": .text("00000000"),
                "authority_vector": .text("00000000"),
                "effects": .map(effectSemantic()),
                "execution_disposition": .text("NOT_ENTERED"),
                "gate_e": .text("ABSTAIN"),
                "h2_live_execution_authorized": .bool(false),
                "stage_complete": .bool(false),
                "vm_disposition": .text("NOT_CREATED"),
                "vm_entry_count": .text("0"),
            ])
        }
    }

    private static func capabilityEvidenceSemantic() -> GuestCBORValue {
        .map([
            "architectural_channels": .text("UNASSESSED"),
            "architectural_channels_raw": .text("0"),
            "endpoint": .text(hexAddress(doorbellIPA)),
            "mapped_regions": .array(regions.map { region in .map([
                "ipa": .text(hexAddress(region.ipa)),
                "length": .text(String(region.length)),
                "object_id": .text(String(region.objectID)),
                "role": .text(region.role),
                "rights": .text(region.rightsName),
                "rights_raw": .text(String(region.rights)),
            ]) }),
            "profile": .text("1"),
            "region_count": .text("3"),
            "register_plan": .map([
                "cpsr": .text(hexAddress(initialCPSR)),
                "general_registers_before_entry": .text("X0_THROUGH_X30_ZERO"),
                "pc": .text(hexAddress(imageLoadIPA)),
                "sctlr_el1": .text(hexAddress(initialSCTLR)),
                "sp_el1": .text(hexAddress(stackTop)),
                "vbar_el1": .text("0x0"),
            ]),
            "stack_top": .text(hexAddress(stackTop)),
            "store_pc": .text(hexAddress(imageLoadIPA + doorbellOffset)),
            "store_value": .text("1"),
            "store_width_bytes": .text("4"),
            "version": .text("1"),
        ])
    }

    private static func transitionSemantic(witnesses: [HypervisorStageNode]) -> GuestCBORValue {
        let predicates = zip(HypervisorStageH2Predicate.allCases, witnesses).enumerated().map {
            index, pair in GuestCBORValue.map([
                "outcome": .text("SATISFIED"),
                "position": .text(String(index)),
                "predicate_id": .text(pair.0.rawValue),
                "witness_root": .text(pair.1.projection.root),
            ])
        }
        return .map([
            "authority_delta": .text("00000000"),
            "combiner": .text("ALL_OF"),
            "derived_outcome": .text("PASS_H2_STATIC_ADMISSION_ONLY"),
            "gate_e": .text("ABSTAIN"),
            "input_receipt_root": .text(h1ReceiptRoot),
            "input_stage": .text("H1"),
            "input_state_root": .text(h1OutputStateRoot),
            "output_stage": .text(stageID),
            "predicates": .array(predicates),
            "roadmap_id": .text(roadmapID),
            "schema": .text(transitionSchema),
            "successor_authorized": .bool(false),
            "vm_disposition": .text("NOT_CREATED"),
        ])
    }

    private static func outputStateSemantic(transitionRoot: String) -> GuestCBORValue {
        .map([
            "authority_delta": .text("00000000"),
            "authority_vector": .text("00000000"),
            "execution_disposition": .text("NOT_ENTERED"),
            "gate_e": .text("ABSTAIN"),
            "h2_live_execution_authorized": .bool(false),
            "high_value_ingress": .text("DENIED"),
            "next_stage": .text("NONE"),
            "parent_receipt_root": .text(h1ReceiptRoot),
            "parent_state_roots": .array([.text(h1OutputStateRoot)]),
            "product_id": .text(productID),
            "roadmap_id": .text(roadmapID),
            "schema": .text(outputStateSchema),
            "stage_complete": .bool(false),
            "stage_id": .text(stageID),
            "status": .text("PASS_H2_STATIC_ADMISSION_ONLY"),
            "transition_root": .text(transitionRoot),
            "trusted_egress": .text("DENIED"),
            "vm_disposition": .text("NOT_CREATED"),
            "vm_entry_count": .text("0"),
        ])
    }

    private static func capabilityPlanIsExact() -> Bool {
        guard regions.count == 3,
              imageLoadIPA + doorbellOffset == 0x1000_0050,
              stackTop == 0x1000_bff0,
              initialSCTLR == 0x30d0_0800,
              initialCPSR == 0x3c5 else { return false }
        var objects = Set<UInt64>()
        for (index, region) in regions.enumerated() {
            guard objects.insert(region.objectID).inserted,
                  region.length == 16_384,
                  region.ipa % 16_384 == 0,
                  region.length % 16_384 == 0,
                  region.ipa <= UInt64.max - region.length,
                  (region.rights & 6) != 6,
                  !(doorbellIPA >= region.ipa && doorbellIPA < region.ipa + region.length) else {
                return false
            }
            for prior in regions[..<index] {
                guard !(region.ipa < prior.ipa + prior.length &&
                        prior.ipa < region.ipa + region.length) else { return false }
            }
        }
        return regions.map(\.objectID) == [1, 2, 3] &&
            regions.map(\.ipa) == [0x1000_0000, 0x1000_4000, 0x1000_8000] &&
            regions.map(\.rights) == [5, 1, 3]
    }

    private static func effectSemantic() -> [String: GuestCBORValue] {
        [
            "app_launch": .bool(false),
            "clock_read": .bool(false),
            "environment_read": .bool(false),
            "file_read": .bool(false),
            "file_write": .bool(false),
            "git_operation": .bool(false),
            "hypervisor_call": .bool(false),
            "journal_open": .bool(false),
            "native_image_accessor_read": .bool(true),
            "network": .bool(false),
            "process_launch": .bool(false),
            "sqlite_open": .bool(false),
            "ui_entry": .bool(false),
            "vm_launch": .bool(false),
        ]
    }

    private static func literalImage() -> Data {
        var bytes = Data()
        bytes.reserveCapacity(imageWords.count * 4)
        for word in imageWords {
            bytes.append(UInt8(truncatingIfNeeded: word))
            bytes.append(UInt8(truncatingIfNeeded: word >> 8))
            bytes.append(UInt8(truncatingIfNeeded: word >> 16))
            bytes.append(UInt8(truncatingIfNeeded: word >> 24))
        }
        return bytes
    }

    private static func frame(_ words: [UInt64]) -> Data {
        var bytes = Data()
        bytes.reserveCapacity(words.count * 8)
        for word in words {
            for index in 0..<8 {
                bytes.append(UInt8(truncatingIfNeeded: word >> (index * 8)))
            }
        }
        return bytes
    }

    private static func snapshotCommitment(image: Data) throws -> String {
        try MerkleGenesis.commit([
            GenesisLeaf(label: "guest_image", payload: image),
            GenesisLeaf(label: "reply", payload: frame([1, 1, 42, 0])),
            GenesisLeaf(label: "request", payload: frame([1, 1, 19, 23])),
            GenesisLeaf(label: "schema", payload: Data(GuestContract.schema.utf8)),
        ]).root
    }

    private static func project(
        _ semantic: GuestCBORValue,
        schema: String,
        role: HypervisorStageH2ProjectionRole
    ) throws -> HypervisorStageProjection {
        let json = try HypervisorStageH2CanonicalJSON.encode(semantic)
        let cbor = try GuestCBOR.encode(semantic)
        guard json.count <= maximumStreamBytes, cbor.count <= maximumStreamBytes else {
            throw failure("projection.bound")
        }
        let partial = HypervisorStageProjection(json: json, cbor: cbor, root: "")
        let root = try MerkleGenesis.commit(projectionLeaves(
            schema: schema, projection: partial, role: role)).root
        let projection = HypervisorStageProjection(json: json, cbor: cbor, root: root)
        guard try verifyProjection(projection, schema: schema, role: role) == semantic else {
            throw failure("projection.self_verify")
        }
        return projection
    }

    private static func verifyProjection(
        _ projection: HypervisorStageProjection,
        schema: String,
        role: HypervisorStageH2ProjectionRole
    ) throws -> GuestCBORValue {
        guard !projection.json.isEmpty, !projection.cbor.isEmpty,
              projection.json.count <= maximumStreamBytes,
              projection.cbor.count <= maximumStreamBytes else {
            throw failure("projection.bound")
        }
        let json = try HypervisorStageH2CanonicalJSON.decode(projection.json)
        let cbor = try GuestCBOR.decode(projection.cbor)
        guard json == cbor, case .map(let values) = json,
              values["schema"] == .text(schema),
              try MerkleGenesis.verify(projectionLeaves(
                schema: schema, projection: projection, role: role),
                expectedRoot: projection.root) else {
            throw failure("projection.join")
        }
        return json
    }

    private static func projectionLeaves(
        schema: String,
        projection: HypervisorStageProjection,
        role: HypervisorStageH2ProjectionRole
    ) -> [GenesisLeaf] {
        [
            GenesisLeaf(label: "schema", payload: Data(schema.utf8)),
            GenesisLeaf(label: role.jsonLabel, payload: projection.json),
            GenesisLeaf(label: role.cborLabel, payload: projection.cbor),
        ]
    }

    private static func receiptLeaves(
        input: HypervisorStageNode,
        witnesses: [HypervisorStageNode],
        transition: HypervisorStageNode,
        output: HypervisorStageNode
    ) throws -> [GenesisLeaf] {
        let inputSemantic = try verifyProjection(input.projection,
                                                 schema: inputStateSchema, role: .state)
        let witnessSemantics = try witnesses.map {
            try verifyProjection($0.projection, schema: witnessSchema, role: .witness)
        }
        let transitionSemantic = try verifyProjection(transition.projection,
                                                      schema: transitionSchema, role: .transition)
        let outputSemantic = try verifyProjection(output.projection,
                                                  schema: outputStateSchema, role: .state)
        let state = GuestCBORValue.array([inputSemantic, outputSemantic])
        let witnessSet = GuestCBORValue.array(witnessSemantics)
        let stateJSON = try HypervisorStageH2CanonicalJSON.encode(state)
        let stateCBOR = try GuestCBOR.encode(state)
        let transitionJSON = try HypervisorStageH2CanonicalJSON.encode(transitionSemantic)
        let transitionCBOR = try GuestCBOR.encode(transitionSemantic)
        let witnessesJSON = try HypervisorStageH2CanonicalJSON.encode(witnessSet)
        let witnessesCBOR = try GuestCBOR.encode(witnessSet)
        guard [stateJSON, stateCBOR, transitionJSON, transitionCBOR,
               witnessesJSON, witnessesCBOR].allSatisfy({ $0.count <= maximumStreamBytes }),
              try HypervisorStageH2CanonicalJSON.decode(stateJSON) == state,
              try GuestCBOR.decode(stateCBOR) == state,
              try HypervisorStageH2CanonicalJSON.decode(transitionJSON) == transitionSemantic,
              try GuestCBOR.decode(transitionCBOR) == transitionSemantic,
              try HypervisorStageH2CanonicalJSON.decode(witnessesJSON) == witnessSet,
              try GuestCBOR.decode(witnessesCBOR) == witnessSet else {
            throw failure("receipt.semantic_join")
        }
        return [
            GenesisLeaf(label: "schema", payload: Data(receiptSchema.utf8)),
            GenesisLeaf(label: "state.json", payload: stateJSON),
            GenesisLeaf(label: "state.cbor", payload: stateCBOR),
            GenesisLeaf(label: "transition.json", payload: transitionJSON),
            GenesisLeaf(label: "transition.cbor", payload: transitionCBOR),
            GenesisLeaf(label: "witnesses.json", payload: witnessesJSON),
            GenesisLeaf(label: "witnesses.cbor", payload: witnessesCBOR),
        ]
    }

    private static func digest(_ bytes: Data) -> String {
        hex(Data(SHA256.hash(data: bytes)))
    }

    private static func hex(_ bytes: Data) -> String {
        bytes.map { String(format: "%02x", $0) }.joined()
    }

    private static func hexWord(_ value: UInt32) -> String {
        String(format: "0x%08x", value)
    }

    private static func hexAddress(_ value: UInt64) -> String {
        String(format: "0x%llx", value)
    }

    private static func failure(_ predicate: String) -> HypervisorStageH2AdmissionFailure {
        .rejected(predicate)
    }
}

/// The H2 graph uses the same closed JSON subset as H1 but keeps an independent
/// codec so H1's file-private implementation and schema roles remain unchanged.
private enum HypervisorStageH2CanonicalJSON {
    static func encode(_ value: GuestCBORValue) throws -> Data {
        let object = try foundation(value)
        guard JSONSerialization.isValidJSONObject(object) else {
            throw HypervisorStageH2AdmissionFailure.rejected("json.object")
        }
        return try JSONSerialization.data(withJSONObject: object,
                                          options: [.sortedKeys, .withoutEscapingSlashes])
    }

    static func decode(_ bytes: Data) throws -> GuestCBORValue {
        guard !bytes.isEmpty, bytes.count <= HypervisorStageH2Admission.maximumStreamBytes else {
            throw HypervisorStageH2AdmissionFailure.rejected("json.bound")
        }
        let object = try JSONSerialization.jsonObject(with: bytes)
        var nodes = 0
        let value = try semantic(object, depth: 0, nodes: &nodes)
        guard try encode(value) == bytes else {
            throw HypervisorStageH2AdmissionFailure.rejected("json.canonical")
        }
        return value
    }

    private static func foundation(_ value: GuestCBORValue) throws -> Any {
        switch value {
        case .text(let text): return text
        case .bool(let boolean): return boolean
        case .array(let values): return try values.map(foundation)
        case .map(let values):
            return try Dictionary(uniqueKeysWithValues: values.map { key, value in
                (key, try foundation(value))
            })
        case .unsigned, .bytes:
            throw HypervisorStageH2AdmissionFailure.rejected("json.type")
        }
    }

    private static func semantic(
        _ object: Any,
        depth: Int,
        nodes: inout Int
    ) throws -> GuestCBORValue {
        guard depth <= GuestCBOR.maximumDepth, nodes < GuestCBOR.maximumNodes else {
            throw HypervisorStageH2AdmissionFailure.rejected("json.structure_bound")
        }
        nodes += 1
        if CFGetTypeID(object as CFTypeRef) == CFBooleanGetTypeID(),
           let number = object as? NSNumber {
            return .bool(number.boolValue)
        }
        if let text = object as? String { return .text(text) }
        if let array = object as? [Any] {
            guard array.count <= GuestCBOR.maximumCollectionCount else {
                throw HypervisorStageH2AdmissionFailure.rejected("json.collection_bound")
            }
            return .array(try array.map {
                try semantic($0, depth: depth + 1, nodes: &nodes)
            })
        }
        if let map = object as? [String: Any] {
            guard map.count <= GuestCBOR.maximumCollectionCount else {
                throw HypervisorStageH2AdmissionFailure.rejected("json.collection_bound")
            }
            return .map(try Dictionary(uniqueKeysWithValues: map.map { key, value in
                (key, try semantic(value, depth: depth + 1, nodes: &nodes))
            }))
        }
        throw HypervisorStageH2AdmissionFailure.rejected("json.type")
    }
}
