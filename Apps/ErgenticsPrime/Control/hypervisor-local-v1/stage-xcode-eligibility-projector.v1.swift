import CoreFoundation
import CryptoKit
import Darwin
import Foundation

@main
enum StageXcodeEligibilityProjectorV1 {
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

    static func main() throws {
        guard CommandLine.arguments.count == 1 else { throw Failure("arguments") }
        guard !FileManager.default.fileExists(atPath: jsonPath),
              !FileManager.default.fileExists(atPath: cborPath) else {
            throw Failure("output_exists")
        }

        let evidence = try loadEvidence()
        let witness = try makeWitness(result: evidence.result, manifest: evidence.manifest)
        let witnessProjection = try project(witness, role: "witness")

        let predicateResults = try makePredicateResults(result: evidence.result)
        let stageRoot = try string(evidence.result, ["lineage", "h1_semantic_result_checkpoint", "h1_state_root"])
        let stageID = try string(evidence.result, ["stage_id"])
        let transition = GuestCBORValue.map([
            "schema": .text("ergentics.provenance.hypervisor.xcode-eligibility-transition.v1"),
            "combiner": .text("ALL_OF"),
            "input_stage_output_state_root": .text(stageRoot),
            "product_witness_root": .text(witnessProjection.root),
            "predicate_results": .map(predicateResults),
            "authority_delta": .text("00000000"),
            "authority_effect": .text("NONE"),
            "gate_e": .text("ABSTAIN"),
        ])
        let transitionProjection = try project(transition, role: "transition")

        let state = GuestCBORValue.map([
            "schema": .text("ergentics.provenance.hypervisor.xcode-eligibility-state.v1"),
            "roadmap_id": .text("ergentics.provenance.hypervisor-local-v1"),
            "stage_id": .text(stageID),
            "stage_output_state_root": .text(stageRoot),
            "product_witness_root": .text(witnessProjection.root),
            "eligibility_transition_root": .text(transitionProjection.root),
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
        let stateProjection = try project(state, role: "state")

        let graph = GuestCBORValue.map([
            "schema": .text("ergentics.provenance.hypervisor.xcode-product-eligibility-graph.v1"),
            "roadmap_id": .text("ergentics.provenance.hypervisor-local-v1"),
            "stage_id": .text(stageID),
            "nodes": .array([
                node(kind: "xcode_product_witness", root: witnessProjection.root, semantic: witness),
                node(kind: "eligibility_transition", root: transitionProjection.root, semantic: transition),
                node(kind: "eligibility_state", root: stateProjection.root, semantic: state),
            ]),
            "edges": .array([
                edge(from: stageRoot,
                     predicate: "stage_output_state_enters_transition", to: transitionProjection.root),
                edge(from: witnessProjection.root, predicate: "product_witness_enters_transition",
                     to: transitionProjection.root),
                edge(from: transitionProjection.root, predicate: "transition_derives_state",
                     to: stateProjection.root),
            ]),
            "authority_vector": .text("00000000"),
            "gate_e": .text("ABSTAIN"),
        ])

        let json = try canonicalJSON(graph)
        let cbor = try GuestCBOR.encode(graph)
        guard try decodeCanonicalJSON(json) == graph,
              try GuestCBOR.decode(cbor) == graph,
              try canonicalJSON(decodeCanonicalJSON(json)) == json,
              try GuestCBOR.encode(GuestCBOR.decode(cbor)) == cbor else {
            throw Failure("round_trip")
        }
        try exclusiveWrite(json, to: jsonPath)
        try exclusiveWrite(cbor, to: cborPath)
        let aggregate = try MerkleGenesis.commit([
            GenesisLeaf(label: "schema", payload: Data("ergentics.provenance.hypervisor.xcode-product-eligibility-graph.v1".utf8)),
            GenesisLeaf(label: "graph.json", payload: json),
            GenesisLeaf(label: "graph.cbor", payload: cbor),
        ])
        FileHandle.standardOutput.write(Data(([
            "witness_root=\(witnessProjection.root)",
            "transition_root=\(transitionProjection.root)",
            "state_root=\(stateProjection.root)",
            "json_sha256=\(hex(Data(SHA256.hash(data: json))))",
            "cbor_sha256=\(hex(Data(SHA256.hash(data: cbor))))",
            "aggregate_root=\(aggregate.root)",
            "json_bytes=\(json.count)",
            "cbor_bytes=\(cbor.count)",
        ].joined(separator: "\n") + "\n").utf8))
    }

    private struct Evidence {
        let result: [String: Any]
        let manifest: [String: Any]
    }

    private static let expectedPredicateIDs: Set<String> = [
        "archive_exit_zero", "archive_inventory_closed", "build_exit_zero",
        "bundle_identifier_exact", "captures_complete", "dsym_uuid_join",
        "effective_entitlements_exact", "hardened_runtime", "host_signature_valid",
        "implementation_product_manifest_join", "intermediate_source_join_exact",
        "no_build_archive_app_or_vm_launch", "no_distribution_action",
        "privacy_manifest_output_exact", "product_input_hashes_exact",
        "result_bundle_inventory_closed", "source_pre_post_join_exact",
        "stage_receipt_json_cbor_semantic_join", "stage_receipt_merkle_ancestry_exact",
        "stage_result_verified", "team_identifier_exact",
    ]

    private static func loadEvidence() throws -> Evidence {
        let resultBytes = try boundedData(path: resultPath, maximum: 262_144)
        let manifestBytes = try boundedData(path: sourceManifestPath, maximum: 1_048_576)
        let stageResultBytes = try boundedData(path: stageResultPath, maximum: 262_144)
        guard hex(Data(SHA256.hash(data: resultBytes))) == expectedResultSHA256,
              hex(Data(SHA256.hash(data: manifestBytes))) == expectedSourceManifestSHA256,
              hex(Data(SHA256.hash(data: stageResultBytes))) == expectedStageResultSHA256 else {
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

    private static func project(_ semantic: GuestCBORValue,
                                role: String) throws -> (json: Data, cbor: Data, root: String) {
        let json = try canonicalJSON(semantic)
        let cbor = try GuestCBOR.encode(semantic)
        guard try decodeCanonicalJSON(json) == semantic,
              try GuestCBOR.decode(cbor) == semantic else { throw Failure("projection_round_trip") }
        let schema: String
        guard case .map(let fields) = semantic,
              let encodedSchema = fields["schema"], case .text(let actualSchema) = encodedSchema else {
            throw Failure("projection_schema")
        }
        schema = actualSchema
        let commitment = try MerkleGenesis.commit([
            GenesisLeaf(label: "schema", payload: Data(schema.utf8)),
            GenesisLeaf(label: "\(role).json", payload: json),
            GenesisLeaf(label: "\(role).cbor", payload: cbor),
        ])
        return (json, cbor, commitment.root)
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

    private static func exclusiveWrite(_ bytes: Data, to path: String) throws {
        let descriptor = Darwin.open(path, O_WRONLY | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC, 0o644)
        guard descriptor >= 0 else { throw Failure("open_\(errno)") }
        defer { _ = Darwin.close(descriptor) }
        var offset = 0
        try bytes.withUnsafeBytes { raw in
            while offset < raw.count {
                let wrote = Darwin.write(descriptor, raw.baseAddress!.advanced(by: offset), raw.count - offset)
                if wrote < 0 && errno == EINTR { continue }
                guard wrote > 0 else { throw Failure("write_\(errno)") }
                offset += wrote
            }
        }
        guard Darwin.fsync(descriptor) == 0 else { throw Failure("fsync_\(errno)") }
    }

    private static func hex(_ data: Data) -> String {
        data.map { String(format: "%02x", $0) }.joined()
    }

    private struct Failure: Error {
        let reason: String
        init(_ reason: String) { self.reason = reason }
    }
}
