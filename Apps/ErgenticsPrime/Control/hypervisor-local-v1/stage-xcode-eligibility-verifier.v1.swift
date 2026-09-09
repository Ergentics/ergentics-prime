import CoreFoundation
import CryptoKit
import Darwin
import Foundation

@main
enum StageXcodeEligibilityVerifierV1 {
    static let jsonPath = "Control/hypervisor-local-v1/h1-xcode-product-eligibility-graph.v1.json"
    static let cborPath = "Control/hypervisor-local-v1/h1-xcode-product-eligibility-graph.v1.cbor"
    static let resultPath = "Control/hypervisor-local-v1/h1-xcode-build-archive-continuity-result.v1.json"
    static let resultChecksumPath = "Control/hypervisor-local-v1/h1-xcode-build-archive-continuity-result.v1.sha256"
    static let sourceManifestPath = "Control/hypervisor-local-v1/h1-xcode-product-source-manifest.v1.json"
    static let sourceManifestChecksumPath = "Control/hypervisor-local-v1/h1-xcode-product-source-manifest.v1.sha256"
    static let stageResultPath = "Control/hypervisor-local-v1/h1-pure-contract-result.v1.json"
    static let stageResultChecksumPath = "Control/hypervisor-local-v1/h1-pure-contract-result.v1.sha256"
    static let expectedResultSHA256 = "908ea5d0fc095b2c3df17a0465400b4a0fdb4d44e896ca43bc7edce4eec6da07"
    static let expectedSourceManifestSHA256 = "f4b4a093354dc1a12818b4daeb1d026bb6ce4386281b45fc34a9611a627c798c"
    static let expectedStageResultSHA256 = "deea60ee59ce64e01de29d207bb7d67902da7195cbe7a58c833bfc94d12ff428"
    static let resultCheckpointCommit = "603a789085c7ef9db061641c54f9259bfbc0948b"
    static let resultCheckpointTree = "f9e28f335d054da5e00a8394ec6d67eeec0ab208"
    static let expectedJSONSHA256 = "f615485593777d6022d1e76b9fab275f2857bc5d68a8fc84f2478cf591f90768"
    static let expectedCBORSHA256 = "51ffda46233533dcc281af9e9db560a9658cb26f3813c54ffa5255389718dd2b"
    static let expectedAggregateRoot = "23fdbc75aa627f6d0ea28dfcc0971f82f2d036268b49cf12e5945fef5d336cb1"
    static let expectedStageRoot = "5afb4febb330a5ca6049a9c0c8c71d6a68e963d19615859ee8b441ad7017b46c"
    static let expectedWitnessRoot = "8347175f9e6470fc10b93b6129ce2b61b472f405a3fac8f6b30665ca0528b005"
    static let expectedTransitionRoot = "4852bb589cba2f7d0d9f52a385e3934d362f8995e339f5d4be2960041f46c596"
    static let expectedStateRoot = "ec47f37f9efbf34a6471a1c3a79b7184e6d4f5b10a21f092a000f473c75b72cc"

    static func main() throws {
        guard CommandLine.arguments.count == 1 else { throw Failure("arguments") }
        let json = try Data(contentsOf: URL(fileURLWithPath: jsonPath), options: [.mappedIfSafe])
        let cbor = try Data(contentsOf: URL(fileURLWithPath: cborPath), options: [.mappedIfSafe])
        guard !json.isEmpty, json.count <= 65_536, !cbor.isEmpty, cbor.count <= 65_536,
              digest(json) == expectedJSONSHA256, digest(cbor) == expectedCBORSHA256 else {
            throw Failure("stream_admission")
        }

        let jsonSemantic = try decodeCanonicalJSON(json)
        let cborSemantic = try GuestCBOR.decode(cbor)
        guard jsonSemantic == cborSemantic,
              try canonicalJSON(jsonSemantic) == json,
              try GuestCBOR.encode(cborSemantic) == cbor else { throw Failure("semantic_join") }
        let evidenceDerivedSemantic = try makeEvidenceDerivedGraph()
        guard jsonSemantic == evidenceDerivedSemantic else { throw Failure("evidence_derivation") }

        guard case .map(let graph) = jsonSemantic,
              text(graph["schema"]) == "ergentics.provenance.hypervisor.xcode-product-eligibility-graph.v1",
              text(graph["roadmap_id"]) == "ergentics.provenance.hypervisor-local-v1",
              text(graph["stage_id"]) == "hypervisor_product_schema_and_pure_contract_v1",
              text(graph["authority_vector"]) == "00000000",
              text(graph["gate_e"]) == "ABSTAIN",
              let encodedNodes = graph["nodes"], case .array(let nodes) = encodedNodes,
              nodes.count == 3 else { throw Failure("graph_header") }

        var nodeByKind: [String: (root: String, semantic: GuestCBORValue)] = [:]
        for node in nodes {
            guard case .map(let fields) = node,
                  let kind = text(fields["kind"]), let root = text(fields["root"]),
                  let semantic = fields["semantic"], nodeByKind[kind] == nil else {
                throw Failure("node_shape")
            }
            let expectedRole = kind == "xcode_product_witness" ? "witness" :
                kind == "eligibility_transition" ? "transition" :
                kind == "eligibility_state" ? "state" : ""
            guard !expectedRole.isEmpty, try verifyProjection(semantic, role: expectedRole, root: root) else {
                throw Failure("node_projection")
            }
            nodeByKind[kind] = (root, semantic)
        }
        guard nodeByKind["xcode_product_witness"]?.root == expectedWitnessRoot,
              nodeByKind["eligibility_transition"]?.root == expectedTransitionRoot,
              nodeByKind["eligibility_state"]?.root == expectedStateRoot else {
            throw Failure("node_root")
        }

        guard let witnessNode = nodeByKind["xcode_product_witness"],
              case .map(let witness) = witnessNode.semantic,
              text(witness["result_sha256"]) == "908ea5d0fc095b2c3df17a0465400b4a0fdb4d44e896ca43bc7edce4eec6da07",
              text(witness["archive_privacy_manifest_sha256"]) == "ca7b9e01d281ddd388f7bfd621ec6220175a2f1029a9996525a79d43b1ecda77",
              text(witness["source_commit"]) == "f61051b8f870a1f31e6ce1e79a953d2edc014635",
              text(witness["source_tree"]) == "7a20fdf6f23acc11d7e36decb259fd968bfa7320",
              text(witness["result_checkpoint_commit"]) == "603a789085c7ef9db061641c54f9259bfbc0948b",
              text(witness["result_checkpoint_tree"]) == "f9e28f335d054da5e00a8394ec6d67eeec0ab208",
              text(witness["product_git_object_manifest_sha256"]) == "b3e66a86b7e7dbc212f6fe52e2784032f476d29050b9a7c15bf1c48480d56cd5",
              text(witness["source_manifest_file_sha256"]) == "f4b4a093354dc1a12818b4daeb1d026bb6ce4386281b45fc34a9611a627c798c",
              text(witness["source_manifest_root_sha256"]) == "3f039152fd0f6f903ed7c6375ca13233c2ccaf80a527fb9b2b73271f965060d6",
              text(witness["intermediate_source_join"]) == "SATISFIED",
              text(witness["stage_output_state_root"]) == expectedStageRoot,
              bool(witness["app_launch"]) == false,
              bool(witness["vm_launch"]) == false,
              bool(witness["distribution_action"]) == false,
              text(witness["authority_effect"]) == "NONE" else {
            throw Failure("witness_semantic")
        }

        guard let transitionNode = nodeByKind["eligibility_transition"],
              case .map(let transition) = transitionNode.semantic,
              text(transition["combiner"]) == "ALL_OF",
              text(transition["input_stage_output_state_root"]) == expectedStageRoot,
              text(transition["product_witness_root"]) == expectedWitnessRoot,
              text(transition["authority_delta"]) == "00000000",
              text(transition["authority_effect"]) == "NONE",
              text(transition["gate_e"]) == "ABSTAIN",
              let encodedPredicates = transition["predicate_results"],
              case .map(let predicates) = encodedPredicates,
              Set(predicates.keys) == expectedPredicateIDs,
              predicates.values.allSatisfy({ text($0) == "SATISFIED" }) else {
            throw Failure("transition_semantic")
        }

        guard let stateNode = nodeByKind["eligibility_state"],
              case .map(let state) = stateNode.semantic,
              text(state["stage_output_state_root"]) == expectedStageRoot,
              text(state["product_witness_root"]) == expectedWitnessRoot,
              text(state["eligibility_transition_root"]) == expectedTransitionRoot,
              bool(state["h2_freeze_recommendation_eligible"]) == true,
              bool(state["h2_execution_authorized"]) == false,
              text(state["authority_delta"]) == "00000000",
              text(state["authority_vector"]) == "00000000",
              text(state["authority_effect"]) == "NONE",
              text(state["gate_e"]) == "ABSTAIN",
              text(state["candidate_selection"]) == "NOT_EVALUATED",
              bool(state["scientific_authority"]) == false,
              bool(state["distribution_eligibility"]) == false,
              bool(state["product_check_may_authorize_execution"]) == false,
              bool(state["product_check_may_close_gate_e"]) == false,
              bool(state["product_check_may_mint_scientific_authority"]) == false,
              text(state["gui_role"]) == "PRESENTATION_ONLY",
              bool(state["app_launch"]) == false,
              bool(state["vm_launch"]) == false,
              bool(state["guest_entry"]) == false else { throw Failure("state_semantic") }

        guard let encodedEdges = graph["edges"], case .array(let edges) = encodedEdges,
              edges == expectedEdges() else { throw Failure("edges") }
        let leaves = [
            GenesisLeaf(label: "schema", payload: Data("ergentics.provenance.hypervisor.xcode-product-eligibility-graph.v1".utf8)),
            GenesisLeaf(label: "graph.json", payload: json),
            GenesisLeaf(label: "graph.cbor", payload: cbor),
        ]
        guard try MerkleGenesis.verify(leaves, expectedRoot: expectedAggregateRoot) else {
            throw Failure("aggregate_root")
        }
        print("PASS evidence_derivation json_cbor_round_trip semantic_join node_reconstruction aggregate_root")
    }

    private static func expectedEdges() -> [GuestCBORValue] {
        [
            edge(from: expectedStageRoot, predicate: "stage_output_state_enters_transition",
                 to: expectedTransitionRoot),
            edge(from: expectedWitnessRoot, predicate: "product_witness_enters_transition",
                 to: expectedTransitionRoot),
            edge(from: expectedTransitionRoot, predicate: "transition_derives_state",
                 to: expectedStateRoot),
        ]
    }

    private static let expectedPredicateIDs: Set<String> = [
        "archive_exit_zero",
        "archive_inventory_closed",
        "build_exit_zero",
        "bundle_identifier_exact",
        "captures_complete",
        "dsym_uuid_join",
        "effective_entitlements_exact",
        "hardened_runtime",
        "host_signature_valid",
        "implementation_product_manifest_join",
        "intermediate_source_join_exact",
        "no_build_archive_app_or_vm_launch",
        "no_distribution_action",
        "privacy_manifest_output_exact",
        "product_input_hashes_exact",
        "result_bundle_inventory_closed",
        "source_pre_post_join_exact",
        "stage_receipt_json_cbor_semantic_join",
        "stage_receipt_merkle_ancestry_exact",
        "stage_result_verified",
        "team_identifier_exact",
    ]

    private struct Evidence {
        let result: [String: Any]
        let manifest: [String: Any]
    }

    private static func makeEvidenceDerivedGraph() throws -> GuestCBORValue {
        let evidence = try loadEvidence()
        let witness = try makeWitness(result: evidence.result, manifest: evidence.manifest)
        let witnessRoot = try projectionRoot(witness, role: "witness")
        let predicates = try makePredicateResults(result: evidence.result)
        let stageRoot = try string(evidence.result, ["lineage", "h1_semantic_result_checkpoint", "h1_state_root"])
        let stageID = try string(evidence.result, ["stage_id"])
        let transition = GuestCBORValue.map([
            "schema": .text("ergentics.provenance.hypervisor.xcode-eligibility-transition.v1"),
            "combiner": .text("ALL_OF"),
            "input_stage_output_state_root": .text(stageRoot),
            "product_witness_root": .text(witnessRoot),
            "predicate_results": .map(predicates),
            "authority_delta": .text("00000000"),
            "authority_effect": .text("NONE"),
            "gate_e": .text("ABSTAIN"),
        ])
        let transitionRoot = try projectionRoot(transition, role: "transition")
        let state = GuestCBORValue.map([
            "schema": .text("ergentics.provenance.hypervisor.xcode-eligibility-state.v1"),
            "roadmap_id": .text("ergentics.provenance.hypervisor-local-v1"),
            "stage_id": .text(stageID),
            "stage_output_state_root": .text(stageRoot),
            "product_witness_root": .text(witnessRoot),
            "eligibility_transition_root": .text(transitionRoot),
            "status": .text("H1_PRODUCT_CHECK_SATISFIED"),
            "h2_freeze_recommendation_eligible": .bool(true),
            "h2_execution_authorized": .bool(false),
            "authority_delta": .text("00000000"),
            "authority_vector": .text("00000000"),
            "authority_effect": .text("NONE"),
            "gate_e": .text("ABSTAIN"),
            "candidate_selection": .text("NOT_EVALUATED"),
            "scientific_authority": .bool(false),
            "distribution_eligibility": .bool(false),
            "product_check_may_authorize_execution": .bool(false),
            "product_check_may_close_gate_e": .bool(false),
            "product_check_may_mint_scientific_authority": .bool(false),
            "gui_role": .text("PRESENTATION_ONLY"),
            "app_launch": .bool(false),
            "vm_launch": .bool(false),
            "guest_entry": .bool(false),
        ])
        let stateRoot = try projectionRoot(state, role: "state")
        guard witnessRoot == expectedWitnessRoot,
              transitionRoot == expectedTransitionRoot,
              stateRoot == expectedStateRoot else { throw Failure("derived_root") }
        return .map([
            "schema": .text("ergentics.provenance.hypervisor.xcode-product-eligibility-graph.v1"),
            "roadmap_id": .text("ergentics.provenance.hypervisor-local-v1"),
            "stage_id": .text(stageID),
            "nodes": .array([
                node(kind: "xcode_product_witness", root: witnessRoot, semantic: witness),
                node(kind: "eligibility_transition", root: transitionRoot, semantic: transition),
                node(kind: "eligibility_state", root: stateRoot, semantic: state),
            ]),
            "edges": .array([
                edge(from: stageRoot, predicate: "stage_output_state_enters_transition", to: transitionRoot),
                edge(from: witnessRoot, predicate: "product_witness_enters_transition", to: transitionRoot),
                edge(from: transitionRoot, predicate: "transition_derives_state", to: stateRoot),
            ]),
            "authority_vector": .text("00000000"),
            "gate_e": .text("ABSTAIN"),
        ])
    }

    private static func loadEvidence() throws -> Evidence {
        let resultBytes = try boundedData(path: resultPath, maximum: 262_144)
        let manifestBytes = try boundedData(path: sourceManifestPath, maximum: 1_048_576)
        let stageResultBytes = try boundedData(path: stageResultPath, maximum: 262_144)
        guard digest(resultBytes) == expectedResultSHA256,
              digest(manifestBytes) == expectedSourceManifestSHA256,
              digest(stageResultBytes) == expectedStageResultSHA256 else {
            throw Failure("evidence_digest")
        }
        try verifyDetached(path: resultChecksumPath, digest: expectedResultSHA256,
                           basename: "h1-xcode-build-archive-continuity-result.v1.json")
        try verifyDetached(path: sourceManifestChecksumPath, digest: expectedSourceManifestSHA256,
                           basename: "h1-xcode-product-source-manifest.v1.json")
        try verifyDetached(path: stageResultChecksumPath, digest: expectedStageResultSHA256,
                           basename: "h1-pure-contract-result.v1.json")
        guard let result = try JSONSerialization.jsonObject(with: resultBytes) as? [String: Any],
              let manifest = try JSONSerialization.jsonObject(with: manifestBytes) as? [String: Any],
              let stageResult = try JSONSerialization.jsonObject(with: stageResultBytes) as? [String: Any] else {
            throw Failure("evidence_json")
        }
        guard try string(result, ["schema"]) == "ergentics.provenance.hypervisor-stage-xcode-build-archive-continuity-result.v1",
              try string(result, ["roadmap_id"]) == "ergentics.provenance.hypervisor-local-v1",
              try string(result, ["stage_id"]) == "hypervisor_product_schema_and_pure_contract_v1",
              try integer(result, ["stage_ordinal"]) == 1,
              try string(result, ["status"]) == "PASS_XCODE_RELEASE_BUILD_ARCHIVE_WITH_THREE_POINT_SOURCE_JOIN",
              try string(manifest, ["schema"]) == "ergentics.provenance.hypervisor.xcode-product-source-manifest.v1",
              try string(result, ["source_join", "descriptor_rooted_manifest_file"]) == sourceManifestPath,
              try string(result, ["source_join", "descriptor_rooted_manifest_file_sha256"]) == expectedSourceManifestSHA256,
              try string(result, ["source_join", "pre_build_manifest_file_sha256"]) == expectedSourceManifestSHA256,
              try string(result, ["source_join", "intermediate_manifest_file_sha256"]) == expectedSourceManifestSHA256,
              try string(result, ["source_join", "post_archive_manifest_file_sha256"]) == expectedSourceManifestSHA256,
              try string(result, ["source_join", "three_point_join"]) == "SATISFIED",
              try string(result, ["source_join", "manifest_root_sha256"]) == string(manifest, ["manifest_root_sha256"]),
              try integer(result, ["source_join", "entry_count"]) == decimalStringInteger(manifest, ["entry_count"]),
              try integer(result, ["source_join", "file_count"]) == decimalStringInteger(manifest, ["file_count"]),
              try integer(result, ["source_join", "directory_count"]) == decimalStringInteger(manifest, ["directory_count"]),
              try integer(result, ["source_join", "regular_file_bytes"]) == decimalStringInteger(manifest, ["regular_file_bytes"]),
              try integer(result, ["source_join", "symlink_count"]) == decimalStringInteger(manifest, ["symlink_count"]),
              try integer(result, ["source_join", "special_count"]) == decimalStringInteger(manifest, ["special_count"]),
              try stringArray(result, ["lineage", "product_git_object_manifest", "fixed_roots"]) == stringArray(manifest, ["fixed_roots"]),
              try string(result, ["authority", "authority_vector"]) == "00000000",
              try string(result, ["authority", "authority_delta"]) == "00000000",
              try string(result, ["authority", "authority_effect"]) == "NONE",
              try string(result, ["authority", "gate_e"]) == "ABSTAIN",
              try boolean(result, ["authority", "h2_execution_authorized"]) == false,
              try boolean(result, ["authority", "scientific_authority"]) == false,
              try string(result, ["lineage", "h1_semantic_result_checkpoint", "h1_result_sha256"]) == expectedStageResultSHA256,
              try string(stageResult, ["outcome"]) == "PASS_PURE_CONTRACT_ONLY",
              try string(stageResult, ["canonical_streams", "h1", "output_state_root"]) == string(result, ["lineage", "h1_semantic_result_checkpoint", "h1_state_root"]),
              try string(stageResult, ["canonical_streams", "h1", "receipt_root"]) == string(result, ["lineage", "h1_semantic_result_checkpoint", "h1_receipt_root"]),
              try string(stageResult, ["authority", "authority_vector"]) == "00000000",
              try string(stageResult, ["authority", "authority_delta"]) == "00000000",
              try string(stageResult, ["authority", "gate_e"]) == "ABSTAIN" else {
            throw Failure("evidence_join")
        }
        _ = try makePredicateResults(result: result)
        return Evidence(result: result, manifest: manifest)
    }

    private static func makeWitness(result: [String: Any],
                                    manifest: [String: Any]) throws -> GuestCBORValue {
        let appLaunch = try integer(result, ["effects", "app_launches"]) != 0
        let vmLaunch = try integer(result, ["effects", "vm_launches"]) != 0
        let distributionAction = try ["exports", "uploads", "notarizations", "provisioning_updates_requested"]
            .contains { try integer(result, ["effects", $0]) != 0 }
        return .map([
            "schema": .text("ergentics.provenance.hypervisor.xcode-product-witness.v1"),
            "stage_id": .text(try string(result, ["stage_id"])),
            "stage_ordinal": .text(String(try integer(result, ["stage_ordinal"]))),
            "source_commit": .text(try string(result, ["lineage", "execution_checkpoint", "commit"])),
            "source_tree": .text(try string(result, ["lineage", "execution_checkpoint", "tree"])),
            "result_checkpoint_commit": .text(resultCheckpointCommit),
            "result_checkpoint_tree": .text(resultCheckpointTree),
            "stage_output_state_root": .text(try string(result, ["lineage", "h1_semantic_result_checkpoint", "h1_state_root"])),
            "stage_receipt_root": .text(try string(result, ["lineage", "h1_semantic_result_checkpoint", "h1_receipt_root"])),
            "result_sha256": .text(expectedResultSHA256),
            "result": .text(try string(result, ["status"])),
            "product_git_object_manifest_sha256": .text(try string(result, ["lineage", "product_git_object_manifest", "live_execution_checkpoint_sha256"])),
            "source_manifest_file_sha256": .text(expectedSourceManifestSHA256),
            "source_manifest_root_sha256": .text(try string(manifest, ["manifest_root_sha256"])),
            "intermediate_source_join": .text(try string(result, ["verification_predicates", "intermediate_source_join_exact"])),
            "release_build_result_bundle_root": .text(try string(result, ["release_build", "action", "result_bundle", "inventory_root_sha256"])),
            "release_archive_result_bundle_root": .text(try string(result, ["release_archive", "action", "result_bundle", "inventory_root_sha256"])),
            "release_build_executable_sha256": .text(try string(result, ["release_build", "app", "executable_sha256"])),
            "release_build_macho_uuid": .text(try string(result, ["release_build", "app", "macho_uuid"])),
            "archive_executable_sha256": .text(try string(result, ["release_archive", "app", "executable_sha256"])),
            "archive_macho_uuid": .text(try string(result, ["release_archive", "app", "macho_uuid"])),
            "archive_dsym_uuid": .text(try string(result, ["release_archive", "dSYM", "macho_uuid"])),
            "archive_inventory_root": .text(try string(result, ["release_archive", "archive", "inventory_root_sha256"])),
            "archive_privacy_manifest_sha256": .text(try string(result, ["release_archive", "app", "privacy_manifest_sha256"])),
            "bundle_identifier": .text(try string(result, ["product_inputs", "bundle_identifier"])),
            "team_identifier": .text(try string(result, ["signing_postflight", "team_identifier"])),
            "effective_entitlements_sha256": .text(try string(result, ["signing_postflight", "effective_entitlements", "canonical_json_sha256"])),
            "hardened_runtime": .bool(try boolean(result, ["signing_postflight", "hardened_runtime"])),
            "app_launch": .bool(appLaunch),
            "vm_launch": .bool(vmLaunch),
            "distribution_action": .bool(distributionAction),
            "authority_effect": .text(try string(result, ["authority", "authority_effect"])),
        ])
    }

    private static func makePredicateResults(result: [String: Any]) throws -> [String: GuestCBORValue] {
        let predicates = try object(result, ["verification_predicates"])
        guard Set(predicates.keys) == expectedPredicateIDs else { throw Failure("predicate_set") }
        return try Dictionary(uniqueKeysWithValues: predicates.map { key, value in
            guard let text = value as? String,
                  ["SATISFIED", "REJECTED", "UNKNOWN"].contains(text) else {
                throw Failure("predicate_value")
            }
            return (key, .text(text))
        })
    }

    private static func projectionRoot(_ semantic: GuestCBORValue,
                                       role: String) throws -> String {
        guard case .map(let fields) = semantic, let schema = text(fields["schema"]) else {
            throw Failure("projection_schema")
        }
        return try MerkleGenesis.commit([
            GenesisLeaf(label: "schema", payload: Data(schema.utf8)),
            GenesisLeaf(label: "\(role).json", payload: canonicalJSON(semantic)),
            GenesisLeaf(label: "\(role).cbor", payload: GuestCBOR.encode(semantic)),
        ]).root
    }

    private static func boundedData(path: String, maximum: Int) throws -> Data {
        let descriptor = Darwin.open(path, O_RDONLY | O_NOFOLLOW | O_CLOEXEC)
        guard descriptor >= 0 else { throw Failure("evidence_open_\(errno)") }
        defer { _ = Darwin.close(descriptor) }
        var before = stat()
        guard Darwin.fstat(descriptor, &before) == 0,
              before.st_mode & S_IFMT == S_IFREG,
              before.st_nlink == 1,
              before.st_size > 0, before.st_size <= maximum else {
            throw Failure("evidence_stat")
        }
        var data = Data(count: Int(before.st_size))
        var offset = 0
        try data.withUnsafeMutableBytes { raw in
            while offset < raw.count {
                let count = Darwin.read(descriptor, raw.baseAddress!.advanced(by: offset), raw.count - offset)
                if count < 0 && errno == EINTR { continue }
                guard count > 0 else { throw Failure("evidence_read_\(errno)") }
                offset += count
            }
        }
        var after = stat()
        guard Darwin.fstat(descriptor, &after) == 0,
              before.st_dev == after.st_dev, before.st_ino == after.st_ino,
              before.st_size == after.st_size,
              before.st_mtimespec.tv_sec == after.st_mtimespec.tv_sec,
              before.st_mtimespec.tv_nsec == after.st_mtimespec.tv_nsec,
              before.st_ctimespec.tv_sec == after.st_ctimespec.tv_sec,
              before.st_ctimespec.tv_nsec == after.st_ctimespec.tv_nsec else {
            throw Failure("evidence_changed")
        }
        let rebound = Darwin.open(path, O_RDONLY | O_NOFOLLOW | O_CLOEXEC)
        guard rebound >= 0 else { throw Failure("evidence_rebound_open_\(errno)") }
        defer { _ = Darwin.close(rebound) }
        var reboundStat = stat()
        guard Darwin.fstat(rebound, &reboundStat) == 0,
              reboundStat.st_dev == before.st_dev,
              reboundStat.st_ino == before.st_ino else { throw Failure("evidence_rebound") }
        return data
    }

    private static func verifyDetached(path: String, digest: String,
                                       basename: String) throws {
        let bytes = try boundedData(path: path, maximum: 256)
        guard bytes == Data("\(digest)  \(basename)\n".utf8) else {
            throw Failure("detached_checksum")
        }
    }

    private static func value(_ root: [String: Any], _ path: [String]) throws -> Any {
        var current: Any = root
        for component in path {
            guard let object = current as? [String: Any], let next = object[component] else {
                throw Failure("missing_\(path.joined(separator: "."))")
            }
            current = next
        }
        return current
    }

    private static func object(_ root: [String: Any], _ path: [String]) throws -> [String: Any] {
        guard let result = try value(root, path) as? [String: Any] else { throw Failure("object_type") }
        return result
    }

    private static func string(_ root: [String: Any], _ path: [String]) throws -> String {
        guard let result = try value(root, path) as? String,
              result.utf8.count <= 4096 else { throw Failure("string_type") }
        return result
    }

    private static func stringArray(_ root: [String: Any], _ path: [String]) throws -> [String] {
        guard let result = try value(root, path) as? [String], result.count <= 4096,
              result.allSatisfy({ $0.utf8.count <= 4096 }) else { throw Failure("string_array_type") }
        return result
    }

    private static func integer(_ root: [String: Any], _ path: [String]) throws -> Int {
        guard let number = try value(root, path) as? NSNumber,
              CFGetTypeID(number) != CFBooleanGetTypeID(),
              number.doubleValue.rounded() == number.doubleValue,
              number.int64Value >= 0, number.int64Value <= Int64.max else {
            throw Failure("integer_type")
        }
        return Int(number.int64Value)
    }

    private static func decimalStringInteger(_ root: [String: Any], _ path: [String]) throws -> Int {
        let text = try string(root, path)
        guard !text.isEmpty, text.allSatisfy({ $0.isNumber }), let result = Int(text) else {
            throw Failure("decimal_string")
        }
        return result
    }

    private static func boolean(_ root: [String: Any], _ path: [String]) throws -> Bool {
        guard let number = try value(root, path) as? NSNumber,
              CFGetTypeID(number) == CFBooleanGetTypeID() else { throw Failure("bool_type") }
        return number.boolValue
    }

    private static func node(kind: String, root: String,
                             semantic: GuestCBORValue) -> GuestCBORValue {
        .map(["kind": .text(kind), "root": .text(root), "semantic": semantic])
    }

    private static func edge(from: String, predicate: String, to: String) -> GuestCBORValue {
        .map(["from": .text(from), "predicate": .text(predicate), "to": .text(to)])
    }

    private static func verifyProjection(_ semantic: GuestCBORValue, role: String,
                                         root: String) throws -> Bool {
        guard case .map(let fields) = semantic, let schema = text(fields["schema"]) else {
            return false
        }
        let json = try canonicalJSON(semantic)
        let cbor = try GuestCBOR.encode(semantic)
        return try MerkleGenesis.verify([
            GenesisLeaf(label: "schema", payload: Data(schema.utf8)),
            GenesisLeaf(label: "\(role).json", payload: json),
            GenesisLeaf(label: "\(role).cbor", payload: cbor),
        ], expectedRoot: root)
    }

    private static func text(_ value: GuestCBORValue?) -> String? {
        guard let value, case .text(let text) = value else { return nil }
        return text
    }

    private static func bool(_ value: GuestCBORValue?) -> Bool? {
        guard let value, case .bool(let boolean) = value else { return nil }
        return boolean
    }

    private static func digest(_ data: Data) -> String {
        Data(SHA256.hash(data: data)).map { String(format: "%02x", $0) }.joined()
    }

    private static func canonicalJSON(_ value: GuestCBORValue) throws -> Data {
        let object = try foundation(value)
        guard JSONSerialization.isValidJSONObject(object) else { throw Failure("json_object") }
        return try JSONSerialization.data(withJSONObject: object,
                                          options: [.sortedKeys, .withoutEscapingSlashes])
    }

    private static func foundation(_ value: GuestCBORValue) throws -> Any {
        switch value {
        case .text(let value): return value
        case .bool(let value): return value
        case .array(let values): return try values.map(foundation)
        case .map(let values):
            return try Dictionary(uniqueKeysWithValues: values.map { ($0.key, try foundation($0.value)) })
        case .unsigned, .bytes: throw Failure("json_type")
        }
    }

    private static func decodeCanonicalJSON(_ bytes: Data) throws -> GuestCBORValue {
        let object = try JSONSerialization.jsonObject(with: bytes)
        var nodes = 0
        let semantic = try semantic(object, depth: 0, nodes: &nodes)
        guard try canonicalJSON(semantic) == bytes else { throw Failure("json_not_canonical") }
        return semantic
    }

    private static func semantic(_ object: Any, depth: Int,
                                 nodes: inout Int) throws -> GuestCBORValue {
        guard depth <= GuestCBOR.maximumDepth, nodes < GuestCBOR.maximumNodes else {
            throw Failure("json_bound")
        }
        nodes += 1
        if CFGetTypeID(object as CFTypeRef) == CFBooleanGetTypeID(), let number = object as? NSNumber {
            return .bool(number.boolValue)
        }
        if let value = object as? String { return .text(value) }
        if let values = object as? [Any] {
            guard values.count <= GuestCBOR.maximumCollectionCount else { throw Failure("json_collection") }
            return .array(try values.map { try semantic($0, depth: depth + 1, nodes: &nodes) })
        }
        if let values = object as? [String: Any] {
            guard values.count <= GuestCBOR.maximumCollectionCount else { throw Failure("json_collection") }
            return .map(try Dictionary(uniqueKeysWithValues: values.map {
                ($0.key, try semantic($0.value, depth: depth + 1, nodes: &nodes))
            }))
        }
        throw Failure("json_type")
    }

    private struct Failure: Error {
        let reason: String
        init(_ reason: String) { self.reason = reason }
    }
}
