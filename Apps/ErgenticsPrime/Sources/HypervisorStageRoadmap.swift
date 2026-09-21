import CoreFoundation
import Foundation

enum HypervisorStageRoadmapFailure: Error, Equatable, Sendable {
    case rejected(String)
}

enum HypervisorStageH1Predicate: String, CaseIterable, Sendable {
    case namespace = "namespace_new_and_product_local"
    case stageOrder = "stage_order_exact"
    case predecessorDAG = "predecessor_dag_exact"
    case authorityCeiling = "authority_ceiling_zero"
    case historicalComparators = "historical_comparators_non_authoritative"
    case semanticJoin = "json_cbor_semantic_join"
    case merkleAncestry = "merkle_ancestry_exact"
    case noLiveEffects = "no_live_effects"
}

struct HypervisorStageProjection: Equatable, Sendable {
    let json: Data
    let cbor: Data
    let root: String
}

struct HypervisorStageNode: Equatable, Sendable {
    let projection: HypervisorStageProjection
}

struct HypervisorStageH1Receipt: Equatable, Sendable {
    let inputState: HypervisorStageNode
    let witnesses: [HypervisorStageNode]
    let transition: HypervisorStageNode
    let outputState: HypervisorStageNode
    let root: String
}

struct HypervisorStageH1VerifiedResult: Equatable, Sendable {
    let outcome: String
    let receiptRoot: String
    let gateE: String
    let authorityVector: String
    let vmDisposition: String
    let nextStageAuthorized: Bool
}

private enum HypervisorStageProjectionRole: String {
    case state
    case transition
    case witness

    var jsonLabel: String { "\(rawValue).json" }
    var cborLabel: String { "\(rawValue).cbor" }
}

/// Pure, fixed Stage-0/H1 graph mechanics for the product-local Hypervisor
/// roadmap. This file has no file, process, clock, environment, UI, SQLite,
/// native guest or Hypervisor API. Its H1 result is a schema/contract result;
/// it cannot authorize H2, create a VM, or close Prime Gate E.
enum HypervisorStageRoadmap {
    static let roadmapID = "ergentics.provenance.hypervisor-local-v1"
    static let productID = "com.ergentics.provenance"
    static let sourceCommit = "ba1750406bfab63afcdf83252c1f907829d78ac5"
    static let sourceTree = "21a75ec7cfc47b9b8351f6d0023cb9a91af319af"
    static let controlFreezeSHA256 = "459a830f72910236ec8d7c430229f3d82d974c1cc9396d3b4a551bc14c7487f7"
    static let maximumStreamBytes = 65_536

    static let stateSchema = "ergentics.provenance.hypervisor-stage.state.v1"
    static let witnessSchema = "ergentics.provenance.hypervisor-stage.witness.v1"
    static let transitionSchema = "ergentics.provenance.hypervisor-stage.transition.v1"
    static let receiptSchema = "ergentics.provenance.hypervisor-stage.receipt.v1"

    static let stageIDs = [
        "hypervisor_product_schema_and_pure_contract_v1",
        "hypervisor_tiny_fixed_guest_mechanics_v1",
        "hypervisor_explicit_state_cursor_resume_v1",
        "hypervisor_durable_receipt_fault_injection_v1",
        "hypervisor_repeated_same_host_resume_determinism_v1",
        "hypervisor_signed_product_resource_probe_v1",
        "hypervisor_bounded_product_checkpoint_execution_v1",
        "hypervisor_retained_product_provenance_and_admission_v1",
    ]

    static func stage0() throws -> HypervisorStageNode {
        HypervisorStageNode(projection: try project(stage0Semantic(), schema: stateSchema,
                                                    role: .state))
    }

    /// The only production entry in this slice. It takes no observations or
    /// caller policy; every witness is derived from the frozen Stage-0 bytes.
    static func runH1PureContract() throws -> HypervisorStageH1Receipt {
        let input = try stage0()
        let inputSemantic = try verify(input.projection, schema: stateSchema, role: .state)
        guard inputSemantic == stage0Semantic() else { throw failure("stage0.semantic") }

        let results = HypervisorStageH1Predicate.allCases.map {
            evaluate($0, state: inputSemantic, projection: input.projection)
        }
        guard results.allSatisfy({ $0 }) else { throw failure("h1.internal_predicate") }

        let witnesses = try zip(HypervisorStageH1Predicate.allCases, results).enumerated().map {
            index, pair in
            HypervisorStageNode(projection: try project(
                witnessSemantic(predicate: pair.0, position: index, satisfied: pair.1),
                schema: witnessSchema, role: .witness))
        }
        let transition = HypervisorStageNode(projection: try project(
            transitionSemantic(inputRoot: input.projection.root, witnesses: witnesses),
            schema: transitionSchema, role: .transition))
        let output = HypervisorStageNode(projection: try project(
            outputStateSemantic(inputRoot: input.projection.root,
                                transitionRoot: transition.projection.root),
            schema: stateSchema, role: .state))
        let receipt = HypervisorStageH1Receipt(inputState: input, witnesses: witnesses,
            transition: transition, outputState: output,
            root: try MerkleGenesis.commit(receiptLeaves(input: input, witnesses: witnesses,
                                                         transition: transition,
                                                         output: output)).root)
        _ = try verifyH1(receipt)
        return receipt
    }

    /// Reconstructs only from the two byte streams and their roots. Reported
    /// labels, rehashed mutations and historical PASS text cannot substitute
    /// for the fixed predicates.
    static func verifyH1(_ receipt: HypervisorStageH1Receipt) throws -> HypervisorStageH1VerifiedResult {
        let input = try verify(receipt.inputState.projection, schema: stateSchema, role: .state)
        guard input == stage0Semantic() else { throw failure("stage0.exact") }
        let recomputed = HypervisorStageH1Predicate.allCases.map {
            evaluate($0, state: input, projection: receipt.inputState.projection)
        }
        guard recomputed.allSatisfy({ $0 }),
              receipt.witnesses.count == HypervisorStageH1Predicate.allCases.count else {
            throw failure("witness.inventory")
        }
        for index in HypervisorStageH1Predicate.allCases.indices {
            let actual = try verify(receipt.witnesses[index].projection, schema: witnessSchema,
                                    role: .witness)
            let expected = witnessSemantic(predicate: HypervisorStageH1Predicate.allCases[index],
                                           position: index, satisfied: recomputed[index])
            guard actual == expected else { throw failure("witness.\(index)") }
        }
        let transition = try verify(receipt.transition.projection, schema: transitionSchema,
                                    role: .transition)
        guard transition == transitionSemantic(inputRoot: receipt.inputState.projection.root,
                                                witnesses: receipt.witnesses) else {
            throw failure("transition.exact")
        }
        let output = try verify(receipt.outputState.projection, schema: stateSchema, role: .state)
        guard output == outputStateSemantic(inputRoot: receipt.inputState.projection.root,
                                            transitionRoot: receipt.transition.projection.root) else {
            throw failure("output.exact")
        }
        let leaves = try receiptLeaves(input: receipt.inputState,
                                       witnesses: receipt.witnesses,
                                       transition: receipt.transition,
                                       output: receipt.outputState)
        guard try MerkleGenesis.verify(leaves, expectedRoot: receipt.root) else {
            throw failure("receipt.root")
        }
        return HypervisorStageH1VerifiedResult(outcome: "PASS_PURE_CONTRACT_ONLY",
            receiptRoot: receipt.root, gateE: "ABSTAIN", authorityVector: "00000000",
            vmDisposition: "NOT_CREATED", nextStageAuthorized: false)
    }

    private static func stage0Semantic() -> GuestCBORValue {
        let stages: [GuestCBORValue] = stageIDs.enumerated().map { index, id in
            .map([
                "id": .text(id),
                "ordinal": .text(String(index + 1)),
                "predecessor": .text(index == 0 ? "NONE" : stageIDs[index - 1]),
            ])
        }
        return .map([
            "authority_delta": .text("00000000"),
            "authority_vector": .text("00000000"),
            "control_freeze_sha256": .text(controlFreezeSHA256),
            "effects": .map([
                "clock_read": .bool(false),
                "environment_read": .bool(false),
                "file_read": .bool(false),
                "file_write": .bool(false),
                "git_operation": .bool(false),
                "journal_open": .bool(false),
                "network": .bool(false),
                "process_launch": .bool(false),
                "vm_launch": .bool(false),
            ]),
            "execution_disposition": .text("NOT_ENTERED"),
            "gate_e": .text("ABSTAIN"),
            "high_value_ingress": .text("DENIED"),
            "historical_comparator_policy": .map([
                "admitted_comparators": .array([]),
                "may_authorize_transition": .bool(false),
                "may_set_authority_bit": .bool(false),
                "required_role": .text("NON_AUTHORITATIVE_COMPARATOR_ONLY"),
            ]),
            "lineage_disposition": .text("NEW_PRODUCT_LOCAL_NON_CONTINUATION"),
            "next_stage": .text("H1"),
            "parent_state_roots": .array([]),
            "product_id": .text(productID),
            "roadmap_id": .text(roadmapID),
            "schema": .text(stateSchema),
            "source_commit": .text(sourceCommit),
            "source_tree": .text(sourceTree),
            "stage_id": .text("H0"),
            "stages": .array(stages),
            "status": .text("GENESIS"),
            "trusted_egress": .text("DENIED"),
            "vm_entry_count": .text("0"),
        ])
    }

    private static func witnessSemantic(predicate: HypervisorStageH1Predicate,
                                        position: Int, satisfied: Bool) -> GuestCBORValue {
        .map([
            "authority_delta": .text("00000000"),
            "observed": .bool(satisfied),
            "outcome": .text(satisfied ? "SATISFIED" : "REJECTED"),
            "position": .text(String(position)),
            "predicate_id": .text(predicate.rawValue),
            "producer_scope": .text("PURE_DETERMINISTIC_RECONSTRUCTION"),
            "roadmap_id": .text(roadmapID),
            "schema": .text(witnessSchema),
            "stage_id": .text("H1"),
            "vm_disposition": .text("NOT_CREATED"),
        ])
    }

    private static func transitionSemantic(inputRoot: String,
                                           witnesses: [HypervisorStageNode]) -> GuestCBORValue {
        let predicates = zip(HypervisorStageH1Predicate.allCases, witnesses).enumerated().map {
            index, pair in
            GuestCBORValue.map([
                "outcome": .text("SATISFIED"),
                "position": .text(String(index)),
                "predicate_id": .text(pair.0.rawValue),
                "witness_root": .text(pair.1.projection.root),
            ])
        }
        return .map([
            "authority_delta": .text("00000000"),
            "combiner": .text("ALL_OF"),
            "derived_outcome": .text("PASS_PURE_CONTRACT_ONLY"),
            "gate_e": .text("ABSTAIN"),
            "input_stage": .text("H0"),
            "input_state_root": .text(inputRoot),
            "output_stage": .text("H1"),
            "predicates": .array(predicates),
            "roadmap_id": .text(roadmapID),
            "schema": .text(transitionSchema),
            "successor_authorized": .bool(false),
            "vm_disposition": .text("NOT_CREATED"),
        ])
    }

    private static func outputStateSemantic(inputRoot: String,
                                            transitionRoot: String) -> GuestCBORValue {
        .map([
            "authority_delta": .text("00000000"),
            "authority_vector": .text("00000000"),
            "execution_disposition": .text("NOT_ENTERED"),
            "gate_e": .text("ABSTAIN"),
            "high_value_ingress": .text("DENIED"),
            "next_stage": .text("NONE"),
            "parent_state_roots": .array([.text(inputRoot)]),
            "product_id": .text(productID),
            "roadmap_id": .text(roadmapID),
            "schema": .text(stateSchema),
            "stage_id": .text("H1"),
            "status": .text("PASS_PURE_CONTRACT_ONLY"),
            "transition_root": .text(transitionRoot),
            "trusted_egress": .text("DENIED"),
            "vm_entry_count": .text("0"),
        ])
    }

    private static func evaluate(_ predicate: HypervisorStageH1Predicate,
                                 state: GuestCBORValue,
                                 projection: HypervisorStageProjection) -> Bool {
        guard case .map(let values) = state else { return false }
        switch predicate {
        case .namespace:
            return values["roadmap_id"] == .text(roadmapID) &&
                values["product_id"] == .text(productID) &&
                values["lineage_disposition"] == .text("NEW_PRODUCT_LOCAL_NON_CONTINUATION")
        case .stageOrder:
            guard let encodedStages = values["stages"], case .array(let stages) = encodedStages,
                  stages.count == stageIDs.count else { return false }
            return zip(stages, stageIDs).enumerated().allSatisfy { index, pair in
                guard case .map(let stage) = pair.0 else { return false }
                return stage["id"] == .text(pair.1) && stage["ordinal"] == .text(String(index + 1))
            }
        case .predecessorDAG:
            guard let encodedStages = values["stages"], case .array(let stages) = encodedStages,
                  stages.count == stageIDs.count else { return false }
            return stages.enumerated().allSatisfy { index, value in
                guard case .map(let stage) = value else { return false }
                return stage["predecessor"] == .text(index == 0 ? "NONE" : stageIDs[index - 1])
            }
        case .authorityCeiling:
            return values["authority_vector"] == .text("00000000") &&
                values["authority_delta"] == .text("00000000") &&
                values["gate_e"] == .text("ABSTAIN") &&
                values["high_value_ingress"] == .text("DENIED") &&
                values["trusted_egress"] == .text("DENIED")
        case .historicalComparators:
            guard let encodedPolicy = values["historical_comparator_policy"],
                  case .map(let policy) = encodedPolicy else { return false }
            return policy == [
                "admitted_comparators": .array([]),
                "may_authorize_transition": .bool(false),
                "may_set_authority_bit": .bool(false),
                "required_role": .text("NON_AUTHORITATIVE_COMPARATOR_ONLY"),
            ]
        case .semanticJoin:
            return (try? StageCanonicalJSON.decode(projection.json)) == state &&
                (try? GuestCBOR.decode(projection.cbor)) == state
        case .merkleAncestry:
            guard values["parent_state_roots"] == .array([]), values["root"] == nil else { return false }
            return (try? MerkleGenesis.verify(projectionLeaves(schema: stateSchema,
                                                                projection: projection,
                                                                role: .state),
                                              expectedRoot: projection.root)) == true
        case .noLiveEffects:
            guard let encodedEffects = values["effects"], case .map(let effects) = encodedEffects else { return false }
            return effects.count == 9 && effects.values.allSatisfy { $0 == .bool(false) } &&
                values["execution_disposition"] == .text("NOT_ENTERED") &&
                values["vm_entry_count"] == .text("0")
        }
    }

    private static func project(_ semantic: GuestCBORValue,
                                schema: String,
                                role: HypervisorStageProjectionRole) throws -> HypervisorStageProjection {
        let json = try StageCanonicalJSON.encode(semantic)
        let cbor = try GuestCBOR.encode(semantic)
        guard json.count <= maximumStreamBytes, cbor.count <= maximumStreamBytes else {
            throw failure("projection.bound")
        }
        let partial = HypervisorStageProjection(json: json, cbor: cbor, root: "")
        let root = try MerkleGenesis.commit(projectionLeaves(schema: schema, projection: partial,
                                                             role: role)).root
        let projection = HypervisorStageProjection(json: json, cbor: cbor, root: root)
        guard try verify(projection, schema: schema, role: role) == semantic else {
            throw failure("projection.self_verify")
        }
        return projection
    }

    private static func verify(_ projection: HypervisorStageProjection,
                               schema: String,
                               role: HypervisorStageProjectionRole) throws -> GuestCBORValue {
        guard !projection.json.isEmpty, !projection.cbor.isEmpty,
              projection.json.count <= maximumStreamBytes,
              projection.cbor.count <= maximumStreamBytes else {
            throw failure("projection.bound")
        }
        let json = try StageCanonicalJSON.decode(projection.json)
        let cbor = try GuestCBOR.decode(projection.cbor)
        guard json == cbor, case .map(let values) = json,
              values["schema"] == .text(schema),
              try MerkleGenesis.verify(projectionLeaves(schema: schema, projection: projection,
                                                         role: role),
                                        expectedRoot: projection.root) else {
            throw failure("projection.join")
        }
        return json
    }

    private static func projectionLeaves(schema: String,
                                         projection: HypervisorStageProjection,
                                         role: HypervisorStageProjectionRole) -> [GenesisLeaf] {
        [GenesisLeaf(label: "schema", payload: Data(schema.utf8)),
         GenesisLeaf(label: role.jsonLabel, payload: projection.json),
         GenesisLeaf(label: role.cborLabel, payload: projection.cbor)]
    }

    private static func receiptLeaves(input: HypervisorStageNode,
                                      witnesses: [HypervisorStageNode],
                                      transition: HypervisorStageNode,
                                      output: HypervisorStageNode) throws -> [GenesisLeaf] {
        let inputSemantic = try verify(input.projection, schema: stateSchema, role: .state)
        let witnessSemantics = try witnesses.map {
            try verify($0.projection, schema: witnessSchema, role: .witness)
        }
        let transitionSemantic = try verify(transition.projection, schema: transitionSchema,
                                            role: .transition)
        let outputSemantic = try verify(output.projection, schema: stateSchema, role: .state)

        // The outer receipt uses exactly the seven labels frozen at Stage 0.
        // `state` is the ordered H0/H1 pair; `witnesses` is the ordered H1
        // predicate array. Each pair is independently encoded as canonical
        // JSON and deterministic CBOR before the Merkle commitment.
        let state = GuestCBORValue.array([inputSemantic, outputSemantic])
        let witnessSet = GuestCBORValue.array(witnessSemantics)
        let stateJSON = try StageCanonicalJSON.encode(state)
        let stateCBOR = try GuestCBOR.encode(state)
        let transitionJSON = try StageCanonicalJSON.encode(transitionSemantic)
        let transitionCBOR = try GuestCBOR.encode(transitionSemantic)
        let witnessesJSON = try StageCanonicalJSON.encode(witnessSet)
        let witnessesCBOR = try GuestCBOR.encode(witnessSet)
        guard [stateJSON, stateCBOR, transitionJSON, transitionCBOR,
               witnessesJSON, witnessesCBOR].allSatisfy({ $0.count <= maximumStreamBytes }) else {
            throw failure("receipt.bound")
        }
        guard try StageCanonicalJSON.decode(stateJSON) == state,
              try GuestCBOR.decode(stateCBOR) == state,
              try StageCanonicalJSON.decode(transitionJSON) == transitionSemantic,
              try GuestCBOR.decode(transitionCBOR) == transitionSemantic,
              try StageCanonicalJSON.decode(witnessesJSON) == witnessSet,
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

    private static func failure(_ predicate: String) -> HypervisorStageRoadmapFailure {
        .rejected(predicate)
    }
}

/// A deliberately small canonical JSON profile for the stage graph. Stage
/// values use only maps, arrays, text and booleans; JSON numbers, null and byte
/// strings are rejected. Decode then exact re-encode rejects duplicate keys,
/// aliases, whitespace and trailing bytes.
// Shared by later product-local roadmap stages. This remains a closed profile:
// making the codec module-visible does not add a file, command or authority
// surface, and every consumer must still compare against its exact semantics.
enum StageCanonicalJSON {
    static func encode(_ value: GuestCBORValue) throws -> Data {
        let object = try foundation(value)
        guard JSONSerialization.isValidJSONObject(object) else {
            throw HypervisorStageRoadmapFailure.rejected("json.object")
        }
        return try JSONSerialization.data(withJSONObject: object,
                                          options: [.sortedKeys, .withoutEscapingSlashes])
    }

    static func decode(_ bytes: Data) throws -> GuestCBORValue {
        guard !bytes.isEmpty, bytes.count <= HypervisorStageRoadmap.maximumStreamBytes else {
            throw HypervisorStageRoadmapFailure.rejected("json.bound")
        }
        let object = try JSONSerialization.jsonObject(with: bytes)
        var nodes = 0
        let value = try semantic(object, depth: 0, nodes: &nodes)
        guard try encode(value) == bytes else {
            throw HypervisorStageRoadmapFailure.rejected("json.canonical")
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
            throw HypervisorStageRoadmapFailure.rejected("json.type")
        }
    }

    private static func semantic(_ object: Any, depth: Int,
                                 nodes: inout Int) throws -> GuestCBORValue {
        guard depth <= GuestCBOR.maximumDepth, nodes < GuestCBOR.maximumNodes else {
            throw HypervisorStageRoadmapFailure.rejected("json.structure_bound")
        }
        nodes += 1
        if CFGetTypeID(object as CFTypeRef) == CFBooleanGetTypeID(), let number = object as? NSNumber {
            return .bool(number.boolValue)
        }
        if let text = object as? String { return .text(text) }
        if let array = object as? [Any] {
            guard array.count <= GuestCBOR.maximumCollectionCount else {
                throw HypervisorStageRoadmapFailure.rejected("json.collection_bound")
            }
            return .array(try array.map { try semantic($0, depth: depth + 1, nodes: &nodes) })
        }
        if let map = object as? [String: Any] {
            guard map.count <= GuestCBOR.maximumCollectionCount else {
                throw HypervisorStageRoadmapFailure.rejected("json.collection_bound")
            }
            return .map(try Dictionary(uniqueKeysWithValues: map.map { key, value in
                (key, try semantic(value, depth: depth + 1, nodes: &nodes))
            }))
        }
        throw HypervisorStageRoadmapFailure.rejected("json.type")
    }
}
