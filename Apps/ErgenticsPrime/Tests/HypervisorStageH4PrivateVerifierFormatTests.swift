import CryptoKit
import Foundation
import XCTest

final class HypervisorStageH4PrivateVerifierFormatTests: XCTestCase {
    private typealias F = HypervisorStageH4PrivateVerifierFormat
    private typealias V = F.Value

    private let issuerSeed = Data([
        0x9d, 0x61, 0xb1, 0x9d, 0xef, 0xfd, 0x5a, 0x60,
        0xba, 0x84, 0x4a, 0xf4, 0x92, 0xec, 0x2c, 0xc4,
        0x44, 0x49, 0xc5, 0x69, 0x7b, 0x32, 0x69, 0x19,
        0x70, 0x3b, 0xac, 0x03, 0x1c, 0xae, 0x7f, 0x60,
    ])
    private let verifierSeed = Data([
        0x4c, 0xcd, 0x08, 0x9b, 0x28, 0xff, 0x96, 0xda,
        0x9d, 0xb6, 0xc3, 0x46, 0xec, 0x11, 0x4e, 0x0f,
        0x5b, 0x8a, 0x31, 0x9f, 0x35, 0xab, 0xa6, 0x24,
        0xda, 0x8c, 0xf6, 0xed, 0x4f, 0xb8, 0xa6, 0xfb,
    ])

    private func hex(_ value: String) -> Data {
        precondition(value.count.isMultiple(of: 2))
        var output = Data()
        output.reserveCapacity(value.count / 2)
        var index = value.startIndex
        while index < value.endIndex {
            let next = value.index(index, offsetBy: 2)
            output.append(UInt8(value[index..<next], radix: 16)!)
            index = next
        }
        return output
    }

    private func data32(_ byte: UInt8) -> Data { Data(repeating: byte, count: 32) }
    private func b32(_ byte: UInt8) -> V { .bytes(data32(byte)) }
    private var storageKey: Data { Data((0...31).map { UInt8($0) }) }
    private var migratedStorageKey: Data { Data((32...63).map { UInt8($0) }) }
    private func text(_ maximum: Bool, short: String) -> V {
        .text(maximum ? String(repeating: "x", count: 128) : short)
    }
    private func u(_ value: UInt64) -> V { .unsigned(value) }

    private func independentArgument(major: UInt8, value: UInt64) -> Data {
        var bytes = Data()
        if value < 24 {
            bytes.append((major << 5) | UInt8(value))
        } else {
            let width: Int
            let additional: UInt8
            if value <= 0xff { width = 1; additional = 24 }
            else if value <= 0xffff { width = 2; additional = 25 }
            else if value <= 0xffff_ffff { width = 4; additional = 26 }
            else { width = 8; additional = 27 }
            bytes.append((major << 5) | additional)
            for index in (0..<width).reversed() {
                bytes.append(UInt8(truncatingIfNeeded: value >> UInt64(index * 8)))
            }
        }
        return bytes
    }

    private func independentEncode(_ value: V) -> Data {
        switch value {
        case .unsigned(let number):
            return independentArgument(major: 0, value: number)
        case .bytes(let bytes):
            return independentArgument(major: 2, value: UInt64(bytes.count)) + bytes
        case .text(let text):
            let bytes = Data(text.utf8)
            return independentArgument(major: 3, value: UInt64(bytes.count)) + bytes
        case .array(let values):
            return independentArgument(major: 4, value: UInt64(values.count)) +
                values.reduce(into: Data()) { $0.append(independentEncode($1)) }
        case .map(let values):
            let entries = values.map { entry in
                (independentEncode(.text(entry.key)), independentEncode(entry.value))
            }.sorted { $0.0.lexicographicallyPrecedes($1.0) }
            return independentArgument(major: 5, value: UInt64(entries.count)) +
                entries.reduce(into: Data()) {
                    $0.append($1.0)
                    $0.append($1.1)
                }
        case .bool(let value):
            return Data([value ? 0xf5 : 0xf4])
        }
    }

    private func independentFrame(domain: F.Domain, payload: Data) -> Data {
        let domainBytes = Data(domain.rawValue.utf8)
        var bytes = Data("EPRH4PV1".utf8)
        bytes.append(UInt8(domainBytes.count >> 8))
        bytes.append(UInt8(domainBytes.count & 0xff))
        bytes.append(domainBytes)
        let count = UInt64(payload.count)
        for index in (0..<8).reversed() {
            bytes.append(UInt8(truncatingIfNeeded: count >> UInt64(index * 8)))
        }
        bytes.append(payload)
        return bytes
    }

    private func independentCommitment(domain: F.Domain, payload: Data) -> Data {
        Data(SHA256.hash(data: independentFrame(domain: domain, payload: payload)))
    }

    private func independentAuthenticationCode(
        key: Data,
        domain: F.Domain,
        payload: Data
    ) -> Data {
        Data(HMAC<SHA256>.authenticationCode(
            for: independentFrame(domain: domain, payload: payload),
            using: SymmetricKey(data: key)
        ))
    }

    private var structuralSignature: Data {
        hex(
            "e5564300c360ac729086e2cc806e828a84877f1eb8e5d974d873e06522490155" +
            "5fb8821590a33bacc61e39701cf9b46bd25bf5f0595bbe24655141438e7a100b"
        )
    }

    private func common(_ schema: F.Schema) -> [String: V] {
        ["schema": .text(schema.rawValue)]
    }

    private func genesis(
        _ schema: F.Schema,
        maximum: Bool,
        policyCommitment: Data? = nil,
        policyByteCount: Int? = nil,
        storageKey: Data? = nil
    ) throws -> [String: V] {
        let verifierPublicKey = try F.publicKey(seed: verifierSeed)
        let issuerPublicKey = try F.publicKey(seed: issuerSeed)
        let declaredStorageKey = storageKey ?? self.storageKey
        var fields = common(schema)
        fields.merge([
            "suite_id": .text(F.suiteID),
            "lineage_format_id": .text(F.lineageFormatID),
            "policy_commitment": .bytes(policyCommitment ?? data32(0x21)),
            "policy_byte_count": u(UInt64(policyByteCount ?? (maximum ? 16_384 : 1))),
            "verifier_public_key": .bytes(verifierPublicKey),
            "verifier_id": .bytes(try F.verifierKeyID(publicKey: verifierPublicKey)),
            "verifier_key_position": u(0),
            "issuer_public_key": .bytes(issuerPublicKey),
            "issuer_key_id": .bytes(try F.issuerKeyID(publicKey: issuerPublicKey)),
            "issuer_key_position": u(0),
            "storage_key_id": .bytes(try F.storageKeyID(key: declaredStorageKey)),
            "storage_key_position": u(0),
            "lineage_id": b32(0x23),
            "epoch_id": b32(0x24),
            "genesis_nonce": b32(0x25),
            "origin_code": u(schema == .genesisInitial ? 0 : 1),
        ], uniquingKeysWith: { _, new in new })
        if schema == .genesisMigrationIntent {
            fields["expected_old_verifier_id"] = b32(0x26)
            fields["expected_old_trusted_genesis_commitment"] = b32(0x27)
            fields["migration_nonce"] = b32(0x28)
        }
        return fields
    }

    private func persistent(
        _ schema: F.Schema,
        kind: UInt64,
        lifecycle: UInt64,
        maximum: Bool
    ) -> [String: V] {
        var fields = common(schema)
        fields.merge([
            "suite_id": .text(F.suiteID),
            "record_kind": u(kind),
            "record_index": u(maximum ? 4_099 : 1),
            "previous_authority_tip_commitment": b32(0x31),
            "trusted_genesis_commitment": b32(0x32),
            "policy_commitment": b32(0x33),
            "verifier_id": b32(0x34),
            "lineage_id": b32(0x35),
            "epoch_id": b32(0x36),
            "lifecycle_after": u(lifecycle),
        ], uniquingKeysWith: { _, new in new })
        return fields
    }

    private func validFields(for schema: F.Schema, maximum: Bool) throws -> [String: V] {
        switch schema {
        case .privateTokenDescriptor:
            var fields = common(schema)
            let kind: UInt64 = maximum ? 6 : 0
            fields.merge([
                "lineage_format_id": .text(F.lineageFormatID),
                "product_id": text(maximum, short: "p"),
                "roadmap_stage_id": text(maximum, short: "r"),
                "stage_id": text(maximum, short: "s"),
                "durable_schema_id": text(maximum, short: "d"),
                "purpose_id": text(maximum, short: "u"),
                "lineage_id": b32(0x11),
                "epoch_id": b32(0x12),
                "sequence": u(maximum ? 4_096 : 0),
                "field_kind": u(kind),
                "field_ordinal": u(maximum ? 4_095 : 0),
                "byte_count": u(maximum ? 1_048_576 : 0),
                "member_count_0": u(maximum ? 0 : 4),
                "member_count_1": u(0),
                "member_count_2": u(0),
                "deterministic_preimage_sha256": b32(0x20),
            ], uniquingKeysWith: { _, new in new })
            return fields

        case .disclosureModeTable:
            var fields = common(schema)
            fields.merge([
                "lineage_format_id": .text(F.lineageFormatID),
                "context_identifiers_mode": u(1),
                "verifier_audience_policy_issuer_key_mode": u(1),
                "lineage_epoch_sequence_predecessor_mode": u(1),
                "assertion_instance_nonce_mode": u(1),
                "counts_mode": u(1),
                "predicate_token_inventory_mode": u(2),
                "predicate_result_vector_mode": u(1),
                "claim_nonclaim_authority_mode": u(1),
                "d3_semantic_mode": u(2),
                "canonical_json_mode": u(2),
                "deterministic_cbor_mode": u(2),
                "indexed_scalar_mode": u(2),
                "state_witness_transition_graph_mode": u(2),
                "predicate_identifier_mode": u(2),
                "predicate_evidence_mode": u(2),
                "raw_payload_mode": u(0),
                "source_build_tree_host_session_environment_mode": u(0),
                "unrestricted_diagnostic_timestamp_telemetry_log_mode": u(0),
                "h4c_structural_reconstruction_inference_accepted": .bool(true),
            ], uniquingKeysWith: { _, new in new })
            return fields

        case .policy:
            var fields = common(schema)
            fields.merge([
                "suite_id": .text(F.suiteID),
                "lineage_format_id": .text(F.lineageFormatID),
                "product_id": text(maximum, short: "p"),
                "roadmap_stage_id": text(maximum, short: "r"),
                "stage_id": text(maximum, short: "s"),
                "durable_schema_id": text(maximum, short: "d"),
                "purpose_id": text(maximum, short: "u"),
                "audience_id": b32(0x13),
                "disclosure_mode_table_commitment": b32(0x14),
                "disclosure_mode_table_byte_count": u(maximum ? 4_096 : 1),
                "assurance_code": u(1),
                "claim_code": u(0),
                "authority_vector": .text("00000000"),
                "predicate_count_max": u(4_096),
                "accepted_transition_max": u(4_096),
                "private_token_mode": u(1),
                "hidden_semantic_verification": u(0),
                "in_epoch_rotation": u(0),
                "backup_or_replica": u(0),
            ], uniquingKeysWith: { _, new in new })
            return fields

        case .genesisInitial, .genesisMigrationIntent:
            return try genesis(schema, maximum: maximum)

        case .uninitializedRecord:
            let policyFields = try validFields(for: .policy, maximum: maximum)
            let policyBytes = try F.encode(policyFields, as: .policy)
            let policyCommitment = try F.commitment(domain: .policy, payload: policyBytes)
            let genesisSchema: F.Schema = maximum ? .genesisMigrationIntent : .genesisInitial
            let genesisFields = try genesis(
                genesisSchema,
                maximum: maximum,
                policyCommitment: policyCommitment,
                policyByteCount: policyBytes.count
            )
            let genesisBytes = try F.encode(genesisFields, as: genesisSchema)
            let genesisCommitment = try F.commitment(
                domain: genesisSchema.commitmentDomain!,
                payload: genesisBytes
            )
            let predecessor = try F.fixedPredecessor(
                trustedGenesisCommitment: genesisCommitment
            )
            var fields = common(schema)
            fields.merge([
                "suite_id": .text(F.suiteID),
                "record_kind": u(1),
                "record_index": u(0),
                "previous_authority_tip_commitment": .bytes(predecessor),
                "lifecycle_code": u(1),
                "trusted_genesis_body": .bytes(genesisBytes),
                "trusted_genesis_commitment": .bytes(genesisCommitment),
                "policy_body": .bytes(policyBytes),
                "policy_commitment": .bytes(policyCommitment),
                "verifier_id": genesisFields["verifier_id"]!,
                "lineage_id": genesisFields["lineage_id"]!,
                "epoch_id": genesisFields["epoch_id"]!,
                "fixed_predecessor": .bytes(predecessor),
                "accepted_sequence": u(0),
                "accepted_present": .bool(false),
                "accepted_record_commitment": .bytes(predecessor),
                "accepted_lineage_state_commitment": .bytes(predecessor),
                "migration_binding_present": .bool(maximum),
                "migration_authorization_envelope_commitment": maximum ? b32(0x29) : .bytes(predecessor),
            ], uniquingKeysWith: { _, new in new })
            return fields

        case .lineageState:
            var fields = common(schema)
            let count = maximum ? 4_096 : 1
            fields.merge([
                "lineage_format_id": .text(F.lineageFormatID),
                "product_id": text(maximum, short: "p"),
                "roadmap_stage_id": text(maximum, short: "r"),
                "stage_id": text(maximum, short: "s"),
                "durable_schema_id": text(maximum, short: "d"),
                "purpose_id": text(maximum, short: "u"),
                "lineage_id": b32(0x11),
                "epoch_id": b32(0x12),
                "sequence": u(maximum ? 4_096 : 0),
                "predecessor_lineage_state_commitment": b32(0x30),
                "d3_semantic_private_token": b32(0x31),
                "d3_semantic_member_count": u(4),
                "canonical_json_private_token": b32(0x32),
                "canonical_json_byte_count": u(maximum ? 158 : 1),
                "deterministic_cbor_private_token": b32(0x33),
                "deterministic_cbor_byte_count": u(maximum ? 158 : 1),
                "indexed_scalar_private_token": b32(0x34),
                "indexed_scalar_member_count": u(4),
                "graph_private_token": b32(0x35),
                "graph_state_count": u(maximum ? 4_096 : 0),
                "graph_witness_count": u(maximum ? 4_096 : 0),
                "graph_transition_count": u(maximum ? 4_096 : 0),
                "predicate_count": u(UInt64(count)),
                "predicate_identifier_tokens": .bytes(Data(repeating: 0x36, count: count * 32)),
                "predicate_result_codes": .bytes(Data(repeating: maximum ? 3 : 0, count: count)),
                "predicate_evidence_tokens": .bytes(Data(repeating: 0x37, count: count * 32)),
                "claim_code": u(0),
                "nonclaim_bits": u(1_023),
                "authority_vector": .text("00000000"),
            ], uniquingKeysWith: { _, new in new })
            return fields

        case .issuerAssertion:
            var fields = common(schema)
            fields.merge([
                "suite_id": .text(F.suiteID),
                "trusted_genesis_commitment": b32(0x20),
                "policy_commitment": b32(0x21),
                "verifier_id": b32(0x22),
                "audience_id": b32(0x23),
                "issuer_key_id": b32(0x24),
                "issuer_key_position": u(0),
                "assertion_instance_nonce": b32(0x25),
                "lineage_id": b32(0x11),
                "epoch_id": b32(0x12),
                "sequence": u(maximum ? 4_096 : 0),
                "predecessor_lineage_state_commitment": b32(0x30),
                "lineage_state_commitment": b32(0x31),
                "lineage_state_byte_count": u(maximum ? 524_288 : 1),
                "claim_code": u(0),
                "nonclaim_bits": u(1_023),
                "authority_vector": .text("00000000"),
            ], uniquingKeysWith: { _, new in new })
            return fields

        case .issuerSignatureEnvelope:
            var fields = common(schema)
            fields.merge([
                "suite_id": .text(F.suiteID),
                "signature_algorithm": u(1),
                "issuer_key_id": b32(0x24),
                "issuer_key_position": u(0),
                "assertion_body_commitment": b32(0x25),
                "assertion_body_byte_count": u(maximum ? 16_384 : 1),
                "signature": .bytes(structuralSignature),
            ], uniquingKeysWith: { _, new in new })
            return fields

        case .challenge:
            var fields = common(schema)
            fields.merge([
                "suite_id": .text(F.suiteID),
                "verifier_id": b32(0x22),
                "verifier_key_id": b32(0x22),
                "verifier_key_position": u(0),
                "policy_commitment": b32(0x21),
                "audience_id": b32(0x23),
                "challenge_nonce": b32(0x26),
                "challenge_purpose": u(1),
            ], uniquingKeysWith: { _, new in new })
            return fields

        case .verifierSignatureEnvelope:
            var fields = common(schema)
            fields.merge([
                "suite_id": .text(F.suiteID),
                "signed_body_kind": u(maximum ? 3 : 1),
                "verifier_key_id": b32(0x22),
                "verifier_key_position": u(0),
                "signed_body_commitment": b32(0x27),
                "signed_body_byte_count": u(maximum ? 16_384 : 1),
                "signature": .bytes(structuralSignature),
            ], uniquingKeysWith: { _, new in new })
            return fields

        case .assertionRequest:
            return try assertionRequestFields(maximum: maximum)

        case .verifierDecision:
            var fields = common(schema)
            let prior = maximum
            fields.merge([
                "suite_id": .text(F.suiteID),
                "verifier_id": b32(0x20),
                "policy_commitment": b32(0x21),
                "request_commitment": b32(0x22),
                "challenge_body_commitment": b32(0x23),
                "lifecycle_before": u(maximum ? 5 : 1),
                "prior_authority_pointer_commitment": b32(0x24),
                "prior_authority_generation": u(maximum ? 4_099 : 0),
                "prior_authority_tip_commitment": b32(0x25),
                "prior_accepted_present": .bool(prior),
                "prior_accepted_sequence": u(maximum ? 4_095 : 0),
                "prior_accepted_record_commitment": b32(maximum ? 0x26 : 0x27),
                "prior_lineage_state_commitment": b32(maximum ? 0x28 : 0x27),
                "candidate_sequence": u(maximum ? 4_096 : 0),
                "candidate_predecessor_commitment": b32(0x29),
                "candidate_lineage_state_commitment": b32(0x2a),
                "candidate_assertion_body_commitment": b32(0x2b),
                "candidate_signature_envelope_commitment": b32(0x2c),
                "internal_decision_code": u(maximum ? 27 : 1),
                "proposed_persistent_record_kind": u(maximum ? 0 : 2),
            ], uniquingKeysWith: { _, new in new })
            return fields

        case .acceptedTransition:
            var fields = persistent(schema, kind: 2, lifecycle: 2, maximum: maximum)
            fields.merge([
                "sequence": u(maximum ? 4_095 : 0),
                "predecessor_lineage_state_commitment": b32(0x41),
                "lineage_state_commitment": b32(0x42),
                "issuer_assertion_body_commitment": b32(0x43),
                "issuer_signature_envelope_commitment": b32(0x44),
                "verifier_decision_commitment": b32(0x45),
                "issuer_key_position": u(0),
                "verifier_key_position": u(0),
                "prior_accepted_record_commitment": b32(0x46),
            ], uniquingKeysWith: { _, new in new })
            return fields

        case .conflictTombstone:
            var fields = persistent(schema, kind: 3, lifecycle: 3, maximum: maximum)
            fields.merge([
                "occupied_sequence": u(maximum ? 4_095 : 0),
                "common_predecessor_lineage_state_commitment": b32(0x41),
                "accepted_record_commitment": b32(0x42),
                "accepted_lineage_state_commitment": b32(0x43),
                "accepted_assertion_body_commitment": b32(0x44),
                "accepted_signature_envelope_commitment": b32(0x45),
                "accepted_decision_commitment": b32(0x46),
                "competing_lineage_state_commitment": b32(0x47),
                "competing_assertion_body_commitment": b32(0x48),
                "competing_signature_envelope_commitment": b32(0x49),
                "competing_decision_commitment": b32(0x4a),
                "issuer_key_position": u(0),
                "conflict_lock_code": u(1),
            ], uniquingKeysWith: { _, new in new })
            return fields

        case .storageFaultLatch:
            var fields = persistent(schema, kind: 4, lifecycle: 4, maximum: maximum)
            fields.merge([
                "last_authenticated_authority_tip_commitment": b32(0x31),
                "last_authenticated_accepted_record_or_fixed_predecessor": b32(0x42),
                "attempted_record_body_commitment": b32(0x43),
                "attempted_record_kind": u(maximum ? 6 : 2),
                "fault_code": u(maximum ? 4 : 1),
                "fault_lock_code": u(1),
            ], uniquingKeysWith: { _, new in new })
            return fields

        case .terminalClose:
            var fields = persistent(schema, kind: 5, lifecycle: 5, maximum: maximum)
            let predecessor = try F.fixedPredecessor(
                trustedGenesisCommitment: data32(0x32)
            )
            fields.merge([
                "terminal_request_commitment": b32(0x41),
                "accepted_present": .bool(maximum),
                "accepted_sequence": u(maximum ? 4_095 : 0),
                "accepted_record_or_fixed_predecessor": maximum ? b32(0x42) : .bytes(predecessor),
                "accepted_lineage_state_or_fixed_predecessor": maximum ? b32(0x44) : .bytes(predecessor),
                "terminal_reason": u(maximum ? 4 : 1),
                "continuity_code": u(0),
            ], uniquingKeysWith: { _, new in new })
            return fields

        case .terminalMigration:
            var fields = persistent(schema, kind: 6, lifecycle: 5, maximum: maximum)
            fields.merge([
                "terminal_request_commitment": b32(0x41),
                "accepted_present": .bool(true),
                "accepted_sequence": u(maximum ? 4_095 : 0),
                "accepted_record_commitment": b32(0x42),
                "accepted_lineage_state_commitment": b32(0x43),
                "new_genesis_intent_commitment": b32(0x44),
                "new_verifier_id": b32(0x45),
                "migration_nonce": b32(0x46),
                "terminal_reason": u(5),
                "continuity_code": u(1),
            ], uniquingKeysWith: { _, new in new })
            return fields

        case .storageRecordWrapper:
            var fields = common(schema)
            fields.merge([
                "suite_id": .text(F.suiteID),
                "record_kind": u(maximum ? 6 : 1),
                "record_index": u(maximum ? 4_099 : 0),
                "previous_record_auth_tag": b32(0x31),
                "record_body_commitment": b32(0x41),
                "record_body_byte_count": u(maximum ? 65_536 : 1),
            ], uniquingKeysWith: { _, new in new })
            return fields

        case .authorityPointer:
            var fields = common(schema)
            let accepted = maximum
            let predecessor = try F.fixedPredecessor(
                trustedGenesisCommitment: data32(0x31)
            )
            fields.merge([
                "suite_id": .text(F.suiteID),
                "trusted_genesis_commitment": b32(0x31),
                "policy_commitment": b32(0x32),
                "lineage_id": b32(0x33),
                "epoch_id": b32(0x34),
                "authority_generation": u(maximum ? 4_099 : 0),
                "authority_tip_record_index": u(maximum ? 4_099 : 0),
                "authority_tip_record_kind": u(maximum ? 6 : 1),
                "authority_tip_record_commitment": b32(0x41),
                "authority_tip_record_auth_tag": b32(0x42),
                "lifecycle_code": u(maximum ? 5 : 1),
                "accepted_present": .bool(accepted),
                "accepted_sequence": u(maximum ? 4_095 : 0),
                "accepted_record_or_fixed_predecessor": maximum ? b32(0x43) : .bytes(predecessor),
                "accepted_lineage_state_or_fixed_predecessor": maximum ? b32(0x45) : .bytes(predecessor),
            ], uniquingKeysWith: { _, new in new })
            return fields

        case .terminalCloseRequest:
            var fields = common(schema)
            fields.merge([
                "suite_id": .text(F.suiteID),
                "verifier_id": b32(0x31),
                "trusted_genesis_commitment": b32(0x32),
                "expected_authority_pointer_commitment": b32(0x33),
                "terminal_kind": u(0),
                "terminal_reason": u(maximum ? 4 : 1),
            ], uniquingKeysWith: { _, new in new })
            return fields

        case .terminalMigrationRequest:
            var fields = common(schema)
            fields.merge([
                "suite_id": .text(F.suiteID),
                "verifier_id": b32(0x31),
                "trusted_genesis_commitment": b32(0x32),
                "expected_authority_pointer_commitment": b32(0x33),
                "terminal_kind": u(1),
                "terminal_reason": u(5),
                "new_genesis_intent_commitment": b32(0x34),
                "new_verifier_id": b32(0x35),
                "migration_nonce": b32(0x36),
            ], uniquingKeysWith: { _, new in new })
            return fields

        case .migrationAuthorization:
            let publicKey = try F.publicKey(seed: issuerSeed)
            var fields = common(schema)
            fields.merge([
                "suite_id": .text(F.suiteID),
                "old_verifier_id": .bytes(try F.verifierKeyID(publicKey: publicKey)),
                "old_verifier_public_key": .bytes(publicKey),
                "old_verifier_key_position": u(0),
                "old_trusted_genesis_commitment": b32(0x32),
                "old_terminal_migration_record_commitment": b32(0x33),
                "old_terminal_record_index": u(maximum ? 4_099 : 1),
                "old_accepted_sequence": u(maximum ? 4_095 : 0),
                "old_accepted_lineage_state_commitment": b32(0x34),
                "new_verifier_id": b32(0x35),
                "new_genesis_intent_commitment": b32(0x36),
                "migration_nonce": b32(0x37),
                "continuity_code": u(1),
            ], uniquingKeysWith: { _, new in new })
            return fields

        case .receiptAcceptedCurrent:
            var fields = common(schema)
            fields.merge([
                "suite_id": .text(F.suiteID),
                "verifier_id": b32(0x31),
                "verifier_key_id": b32(0x31),
                "verifier_key_position": u(0),
                "policy_commitment": b32(0x32),
                "audience_id": b32(0x33),
                "challenge_body_commitment": b32(0x34),
                "request_commitment": b32(0x35),
                "decision_commitment": b32(0x36),
                "outcome_code": u(maximum ? 2 : 1),
                "accepted_sequence": u(maximum ? 4_095 : 0),
                "accepted_record_commitment": b32(0x37),
                "accepted_lineage_state_commitment": b32(0x38),
                "authority_pointer_commitment": b32(0x39),
                "authority_tip_commitment": b32(0x3a),
                "authority_generation": u(maximum ? 4_099 : 1),
                "claim_code": u(0),
                "nonclaim_bits": u(1_023),
                "authority_vector": .text("00000000"),
            ], uniquingKeysWith: { _, new in new })
            return fields

        case .receiptMinimized:
            var fields = common(schema)
            fields.merge([
                "suite_id": .text(F.suiteID),
                "verifier_id": b32(0x31),
                "verifier_key_id": b32(0x31),
                "verifier_key_position": u(0),
                "policy_commitment": b32(0x32),
                "audience_id": b32(0x33),
                "challenge_body_commitment": b32(0x34),
                "request_commitment": b32(0x35),
                "outcome_code": u(maximum ? 5 : 3),
                "claim_code": u(0),
                "nonclaim_bits": u(1_023),
                "authority_vector": .text("00000000"),
            ], uniquingKeysWith: { _, new in new })
            return fields

        case .receiptTerminal:
            var fields = common(schema)
            fields.merge([
                "suite_id": .text(F.suiteID),
                "verifier_id": b32(0x31),
                "verifier_key_id": b32(0x31),
                "verifier_key_position": u(0),
                "policy_commitment": b32(0x32),
                "terminal_request_commitment": b32(0x33),
                "outcome_code": u(maximum ? 6 : 5),
                "terminal_kind": u(maximum ? 1 : 0),
                "result_record_kind": u(maximum ? 6 : 4),
                "result_record_commitment": b32(0x34),
                "continuity_code": u(maximum ? 1 : 0),
            ], uniquingKeysWith: { _, new in new })
            return fields
        }
    }

    private func assertionRequestFields(maximum: Bool) throws -> [String: V] {
        let lineageFields = try validFields(for: .lineageState, maximum: maximum)
        let lineageBytes = try F.encode(lineageFields, as: .lineageState)
        let lineageCommitment = try F.commitment(domain: .lineageState, payload: lineageBytes)

        let challengeFields = try validFields(for: .challenge, maximum: maximum)
        let challengeBytes = try F.encode(challengeFields, as: .challenge)
        let challengeCommitment = try F.commitment(domain: .challengeBody, payload: challengeBytes)

        var assertionFields = try validFields(for: .issuerAssertion, maximum: maximum)
        for key in ["lineage_id", "epoch_id", "predecessor_lineage_state_commitment"] {
            assertionFields[key] = lineageFields[key]
        }
        assertionFields["sequence"] = lineageFields["sequence"]
        assertionFields["claim_code"] = lineageFields["claim_code"]
        assertionFields["nonclaim_bits"] = lineageFields["nonclaim_bits"]
        assertionFields["authority_vector"] = lineageFields["authority_vector"]
        for key in ["verifier_id", "policy_commitment", "audience_id"] {
            assertionFields[key] = challengeFields[key]
        }
        assertionFields["lineage_state_commitment"] = .bytes(lineageCommitment)
        assertionFields["lineage_state_byte_count"] = u(UInt64(lineageBytes.count))
        let assertionBytes = try F.encode(assertionFields, as: .issuerAssertion)
        let assertionCommitment = try F.commitment(domain: .assertionBody, payload: assertionBytes)

        var challengeEnvelopeFields = try validFields(
            for: .verifierSignatureEnvelope,
            maximum: false
        )
        challengeEnvelopeFields["signed_body_kind"] = u(1)
        challengeEnvelopeFields["verifier_key_id"] = challengeFields["verifier_key_id"]
        challengeEnvelopeFields["signed_body_commitment"] = .bytes(challengeCommitment)
        challengeEnvelopeFields["signed_body_byte_count"] = u(UInt64(challengeBytes.count))
        let challengeEnvelopeBytes = try F.encode(
            challengeEnvelopeFields,
            as: .verifierSignatureEnvelope
        )

        var issuerEnvelopeFields = try validFields(
            for: .issuerSignatureEnvelope,
            maximum: false
        )
        issuerEnvelopeFields["issuer_key_id"] = assertionFields["issuer_key_id"]
        issuerEnvelopeFields["assertion_body_commitment"] = .bytes(assertionCommitment)
        issuerEnvelopeFields["assertion_body_byte_count"] = u(UInt64(assertionBytes.count))
        let issuerEnvelopeBytes = try F.encode(
            issuerEnvelopeFields,
            as: .issuerSignatureEnvelope
        )

        var fields = common(.assertionRequest)
        fields.merge([
            "suite_id": .text(F.suiteID),
            "challenge_body": .bytes(challengeBytes),
            "challenge_envelope": .bytes(challengeEnvelopeBytes),
            "lineage_state_body": .bytes(lineageBytes),
            "issuer_assertion_body": .bytes(assertionBytes),
            "issuer_signature_envelope": .bytes(issuerEnvelopeBytes),
        ], uniquingKeysWith: { _, new in new })
        return fields
    }

    private func provisionedFixture() throws -> (
        context: F.ProvisionedContext,
        table: Data,
        policy: Data,
        genesis: Data
    ) {
        let table = try F.encode(
            validFields(for: .disclosureModeTable, maximum: false),
            as: .disclosureModeTable
        )
        let tableCommitment = try F.commitment(
            domain: .disclosureModeTable,
            payload: table
        )
        var policyFields = try validFields(for: .policy, maximum: false)
        policyFields["disclosure_mode_table_commitment"] = .bytes(tableCommitment)
        policyFields["disclosure_mode_table_byte_count"] = u(UInt64(table.count))
        let policy = try F.encode(policyFields, as: .policy)
        let policyCommitment = try F.commitment(domain: .policy, payload: policy)
        let genesis = try F.encode(
            genesis(
                .genesisInitial,
                maximum: false,
                policyCommitment: policyCommitment,
                policyByteCount: policy.count
            ),
            as: .genesisInitial
        )
        return (
            try F.makeProvisionedContext(
                disclosureModeTable: table,
                policy: policy,
                trustedGenesis: genesis
            ),
            table,
            policy,
            genesis
        )
    }

    private func authenticatedRequestFixture() throws -> (
        context: F.ProvisionedContext,
        challenge: Data,
        challengeEnvelope: Data,
        lineage: Data,
        assertion: Data,
        issuerEnvelope: Data,
        request: Data
    ) {
        let provisioned = try provisionedFixture()
        let context = provisioned.context
        let predecessor = try F.fixedPredecessor(
            trustedGenesisCommitment: context.trustedGenesisCommitment.bytes
        )

        var lineageFields = try validFields(for: .lineageState, maximum: false)
        for key in [
            "product_id", "roadmap_stage_id", "stage_id",
            "durable_schema_id", "purpose_id",
        ] {
            lineageFields[key] = context.policy.fields[key]
        }
        lineageFields["lineage_id"] = .bytes(context.lineageID.bytes)
        lineageFields["epoch_id"] = .bytes(context.epochID.bytes)
        lineageFields["predecessor_lineage_state_commitment"] = .bytes(predecessor)
        let lineage = try F.encode(lineageFields, as: .lineageState)
        let lineageCommitment = try F.commitment(domain: .lineageState, payload: lineage)

        var assertionFields = try validFields(for: .issuerAssertion, maximum: false)
        assertionFields["trusted_genesis_commitment"] =
            .bytes(context.trustedGenesisCommitment.bytes)
        assertionFields["policy_commitment"] = .bytes(context.policyCommitment.bytes)
        assertionFields["verifier_id"] = .bytes(context.verifierID.bytes)
        assertionFields["audience_id"] = .bytes(context.audienceID.bytes)
        assertionFields["issuer_key_id"] = .bytes(context.issuerKeyID.bytes)
        assertionFields["lineage_id"] = .bytes(context.lineageID.bytes)
        assertionFields["epoch_id"] = .bytes(context.epochID.bytes)
        assertionFields["predecessor_lineage_state_commitment"] = .bytes(predecessor)
        assertionFields["lineage_state_commitment"] = .bytes(lineageCommitment)
        assertionFields["lineage_state_byte_count"] = u(UInt64(lineage.count))
        let assertion = try F.encode(assertionFields, as: .issuerAssertion)
        let assertionCommitment = try F.commitment(
            domain: .assertionBody,
            payload: assertion
        )

        var challengeFields = try validFields(for: .challenge, maximum: false)
        challengeFields["verifier_id"] = .bytes(context.verifierID.bytes)
        challengeFields["verifier_key_id"] = .bytes(context.verifierID.bytes)
        challengeFields["policy_commitment"] = .bytes(context.policyCommitment.bytes)
        challengeFields["audience_id"] = .bytes(context.audienceID.bytes)
        let challenge = try F.encode(challengeFields, as: .challenge)
        let challengeCommitment = try F.commitment(
            domain: .challengeBody,
            payload: challenge
        )

        var challengeEnvelopeFields = try validFields(
            for: .verifierSignatureEnvelope,
            maximum: false
        )
        challengeEnvelopeFields["signed_body_kind"] = u(1)
        challengeEnvelopeFields["verifier_key_id"] = .bytes(context.verifierID.bytes)
        challengeEnvelopeFields["signed_body_commitment"] = .bytes(challengeCommitment)
        challengeEnvelopeFields["signed_body_byte_count"] = u(UInt64(challenge.count))
        challengeEnvelopeFields["signature"] = .bytes(hex(
            "991c2e58556418f3b0b3fa095899dd453fc10aae89282c3e433b12f07b3ab53" +
            "bdb24528f4357415314acf67ece402c8d014ed7c5375b143c180f2dca16ff4b09"
        ))
        let challengeEnvelope = try F.encode(
            challengeEnvelopeFields,
            as: .verifierSignatureEnvelope
        )

        var issuerEnvelopeFields = try validFields(
            for: .issuerSignatureEnvelope,
            maximum: false
        )
        issuerEnvelopeFields["issuer_key_id"] = .bytes(context.issuerKeyID.bytes)
        issuerEnvelopeFields["assertion_body_commitment"] = .bytes(assertionCommitment)
        issuerEnvelopeFields["assertion_body_byte_count"] = u(UInt64(assertion.count))
        issuerEnvelopeFields["signature"] = .bytes(hex(
            "92046e93e7a3bc3e57481a985989cfc1049fda6f49d792d36154d03f3e701d5b" +
            "acc13f7af17158fd4a4a95624d4ae44114693e20758fa4810b0a22cb84322100"
        ))
        let issuerEnvelope = try F.encode(
            issuerEnvelopeFields,
            as: .issuerSignatureEnvelope
        )

        let request = try F.encode([
            "schema": .text(F.Schema.assertionRequest.rawValue),
            "suite_id": .text(F.suiteID),
            "challenge_body": .bytes(challenge),
            "challenge_envelope": .bytes(challengeEnvelope),
            "lineage_state_body": .bytes(lineage),
            "issuer_assertion_body": .bytes(assertion),
            "issuer_signature_envelope": .bytes(issuerEnvelope),
        ], as: .assertionRequest)
        return (
            context,
            challenge,
            challengeEnvelope,
            lineage,
            assertion,
            issuerEnvelope,
            request
        )
    }

    private func tokenDescriptor(kind: UInt64, ordinal: UInt64? = nil) throws -> Data {
        var fields = try validFields(for: .privateTokenDescriptor, maximum: false)
        fields["field_kind"] = u(kind)
        fields["field_ordinal"] = u(ordinal ?? (kind == 6 ? 4_095 : 0))
        fields["byte_count"] = u(kind == 1 || kind == 2 ? 1 : 0)
        fields["member_count_0"] = u(kind == 0 || kind == 3 ? 4 : 0)
        fields["member_count_1"] = u(0)
        fields["member_count_2"] = u(0)
        return try F.encode(fields, as: .privateTokenDescriptor)
    }

    private func privateTokenPrimitive(blind: Data, descriptor: Data) throws -> Data {
        try F.validate(descriptor, as: .privateTokenDescriptor)
        return try F.authenticationCode(
            key: blind,
            domain: .privateToken,
            payload: descriptor
        )
    }

    private func expectedJSON(predicateCount: UInt32) -> Data {
        Data((
            "{\"authority_vector\":\"00000000\"," +
            "\"claim_state\":\"OBSERVED_NONPASS\"," +
            "\"predicate_count\":\(predicateCount)," +
            "\"schema\":\"com.ergentics.provenance.hypervisor.h4.canonical-receipt.v1\"}"
        ).utf8)
    }

    private func expectedCBOR(predicateCount: UInt32) -> Data {
        let count: [UInt8]
        switch predicateCount {
        case 1: count = [0x01]
        case 4_096: count = [0x19, 0x10, 0x00]
        default: preconditionFailure("Missing fixed H4-C count vector")
        }
        var bytes = Data([0xa4, 0x66])
        bytes.append(Data("schema".utf8))
        bytes.append(contentsOf: [0x78, 0x3b])
        bytes.append(Data(
            "com.ergentics.provenance.hypervisor.h4.canonical-receipt.v1".utf8
        ))
        bytes.append(0x6b)
        bytes.append(Data("claim_state".utf8))
        bytes.append(0x70)
        bytes.append(Data("OBSERVED_NONPASS".utf8))
        bytes.append(0x6f)
        bytes.append(Data("predicate_count".utf8))
        bytes.append(contentsOf: count)
        bytes.append(0x70)
        bytes.append(Data("authority_vector".utf8))
        bytes.append(0x68)
        bytes.append(Data("00000000".utf8))
        return bytes
    }

    func testRegistryIsClosedUniqueAndRoleSeparated() throws {
        XCTAssertEqual(F.Domain.allCases.count, 37)
        XCTAssertEqual(Set(F.Domain.allCases.map(\.rawValue)).count, 37)
        for domain in F.Domain.allCases {
            let bytes = Data(domain.rawValue.utf8)
            XCTAssertTrue((1...127).contains(bytes.count))
            XCTAssertTrue(bytes.allSatisfy { (0x20...0x7e).contains($0) })
        }
        XCTAssertEqual(F.Schema.allCases.count, 26)
        XCTAssertEqual(Set(F.Schema.allCases.map(\.rawValue)).count, 26)
        XCTAssertNil(F.Schema.privateTokenDescriptor.commitmentDomain)
        XCTAssertNil(F.Schema.storageRecordWrapper.commitmentDomain)
        XCTAssertThrowsError(try F.commitment(domain: .privateToken, payload: Data()))
        XCTAssertThrowsError(try F.authenticationCode(
            key: data32(1), domain: .policy, payload: Data()
        ))
        XCTAssertThrowsError(try F.verify(
            signature: structuralSignature,
            publicKey: try F.publicKey(seed: issuerSeed),
            domain: .issuerKeyID,
            payload: Data()
        ))
    }

    func testEverySchemaMinimumAndMaximumFixtureRoundTripsExactly() throws {
        for schema in F.Schema.allCases {
            for maximum in [false, true] {
                let fields = try validFields(for: schema, maximum: maximum)
                let bytes = try F.encode(fields, as: schema)
                XCTAssertEqual(bytes, independentEncode(.map(fields)), schema.rawValue)
                XCTAssertFalse(bytes.isEmpty, schema.rawValue)
                XCTAssertLessThanOrEqual(bytes.count, schema.maximumBytes, schema.rawValue)
                let decoded = try F.decode(bytes, as: schema)
                XCTAssertEqual(decoded.schema, schema)
                XCTAssertEqual(decoded.fields, fields)
                XCTAssertEqual(decoded.bytes, bytes)
                XCTAssertEqual(try F.decode(bytes), decoded)
                XCTAssertNoThrow(try F.validate(bytes, as: schema))
                if let domain = schema.commitmentDomain {
                    XCTAssertEqual(
                        try F.commitment(decoded),
                        try F.commitment(domain: domain, payload: bytes)
                    )
                    XCTAssertEqual(
                        try F.commitment(decoded),
                        Data(SHA256.hash(data: independentFrame(domain: domain, payload: bytes)))
                    )
                } else {
                    XCTAssertThrowsError(try F.commitment(decoded))
                }
            }
        }
    }

    func testEverySchemaRejectsMissingUnknownWrongTypeAndOverRangeFields() throws {
        for schema in F.Schema.allCases {
            let fields = try validFields(for: schema, maximum: false)
            var unknown = fields
            unknown["unknown"] = u(0)
            XCTAssertThrowsError(try F.encode(unknown, as: schema), schema.rawValue)

            for key in fields.keys {
                var missing = fields
                missing.removeValue(forKey: key)
                XCTAssertThrowsError(try F.encode(missing, as: schema), "\(schema.rawValue).\(key)")

                var wrongType = fields
                wrongType[key] = .array([])
                XCTAssertThrowsError(try F.encode(wrongType, as: schema), "\(schema.rawValue).\(key)")

                switch fields[key]! {
                case .unsigned:
                    var over = fields
                    over[key] = .unsigned(.max)
                    XCTAssertThrowsError(try F.encode(over, as: schema), "\(schema.rawValue).\(key)")
                case .bytes:
                    var empty = fields
                    empty[key] = .bytes(Data())
                    XCTAssertThrowsError(try F.encode(empty, as: schema), "\(schema.rawValue).\(key)")
                case .text:
                    var empty = fields
                    empty[key] = .text("")
                    XCTAssertThrowsError(try F.encode(empty, as: schema), "\(schema.rawValue).\(key)")
                case .array, .map, .bool:
                    break
                }
            }
        }
    }

    func testCanonicalCBORKnownAnswersAndRepresentationalAliases() throws {
        let value: V = .map(["b": .bool(false), "aa": .bool(true)])
        let expected = hex("a26162f4626161f5")
        XCTAssertEqual(try F.encodeCanonical(value), expected)
        XCTAssertEqual(try F.decodeCanonical(expected), value)

        let invalid = [
            hex("a2626161f56162f4"),
            hex("a2616100616101"),
            hex("1800"),
            hex("9f00ff"),
            hex("f6"),
            hex("f4f4"),
        ]
        for bytes in invalid { XCTAssertThrowsError(try F.validateCanonical(bytes)) }
    }

    func testCanonicalCBORAllBoundsAreCheckedBeforeExpansion() throws {
        XCTAssertNoThrow(try F.encodeCanonical(.text(String(repeating: "x", count: 128))))
        XCTAssertThrowsError(try F.encodeCanonical(.text(String(repeating: "x", count: 129))))
        XCTAssertNoThrow(try F.encodeCanonical(.array(Array(repeating: .bool(false), count: 256))))
        XCTAssertThrowsError(try F.encodeCanonical(.array(Array(repeating: .bool(false), count: 257))))

        let map64 = Dictionary(uniqueKeysWithValues: (0..<64).map {
            (String(format: "k%02d", $0), V.unsigned(UInt64($0)))
        })
        let map65 = Dictionary(uniqueKeysWithValues: (0..<65).map {
            (String(format: "k%02d", $0), V.unsigned(UInt64($0)))
        })
        XCTAssertNoThrow(try F.encodeCanonical(.map(map64)))
        XCTAssertThrowsError(try F.encodeCanonical(.map(map65)))

        var depthEight: V = .bool(false)
        for _ in 0..<8 { depthEight = .array([depthEight]) }
        XCTAssertNoThrow(try F.encodeCanonical(depthEight))
        let depthNine: V = .array([depthEight])
        XCTAssertThrowsError(try F.encodeCanonical(depthNine))

        let exactNodes = V.array(
            Array(repeating: V.array(Array(repeating: .bool(false), count: 256)), count: 31) +
            [V.array(Array(repeating: .bool(false), count: 223))]
        )
        let excessNodes = V.array(
            Array(repeating: V.array(Array(repeating: .bool(false), count: 256)), count: 31) +
            [V.array(Array(repeating: .bool(false), count: 224))]
        )
        XCTAssertNoThrow(try F.encodeCanonical(exactNodes))
        XCTAssertThrowsError(try F.encodeCanonical(excessNodes))
        XCTAssertThrowsError(try F.validateCanonical(Data([0xb8, 0x41])))
        XCTAssertThrowsError(try F.validateCanonical(Data([0x99, 0x01, 0x01])))
    }

    func testSchemaAndPackedVectorBoundsPreflightBeforeMaterialization() throws {
        var tooWide = try validFields(for: .lineageState, maximum: false)
        tooWide["predicate_count"] = u(1)
        tooWide["predicate_identifier_tokens"] = .bytes(
            Data(repeating: 0x31, count: 131_072)
        )
        tooWide["predicate_evidence_tokens"] = .bytes(
            Data(repeating: 0x32, count: 131_072)
        )
        let tooWideBytes = try F.encodeCanonical(.map(tooWide))
        for operation in [
            { try F.decode(tooWideBytes, as: .lineageState) },
            { try F.decode(tooWideBytes) },
        ] {
            XCTAssertThrowsError(try operation()) {
                XCTAssertEqual($0 as? F.Failure, .crossField)
            }
        }

        var tooNarrow = try validFields(for: .lineageState, maximum: false)
        tooNarrow["predicate_count"] = u(4_096)
        let tooNarrowBytes = try F.encodeCanonical(.map(tooNarrow))
        XCTAssertThrowsError(try F.decode(tooNarrowBytes, as: .lineageState)) {
            XCTAssertEqual($0 as? F.Failure, .crossField)
        }

        var request = try validFields(for: .assertionRequest, maximum: false)
        request["lineage_state_body"] = .bytes(tooWideBytes)
        let nestedBytes = try F.encodeCanonical(.map(request))
        for operation in [
            { try F.decode(nestedBytes, as: .assertionRequest) },
            { try F.decode(nestedBytes) },
        ] {
            XCTAssertThrowsError(try operation()) {
                XCTAssertEqual($0 as? F.Failure, .crossField)
            }
        }

        let falselySmall = try F.encodeCanonical(.map([
            "schema": .text(F.Schema.issuerSignatureEnvelope.rawValue),
            "unknown": .bytes(Data(repeating: 0x55, count: 2_048)),
        ]))
        XCTAssertThrowsError(try F.decode(falselySmall)) {
            XCTAssertEqual($0 as? F.Failure, .bound)
        }

        let overlongSchema = Data([0xa1, 0x66]) + Data("schema".utf8) +
            Data([0x78, 0x81]) + Data(repeating: 0x73, count: 129)
        XCTAssertThrowsError(try F.decode(overlongSchema)) {
            XCTAssertEqual($0 as? F.Failure, .bound)
        }
        XCTAssertThrowsError(try F.checkedPredicateLengths(.max)) {
            XCTAssertEqual($0 as? F.Failure, .overflow)
        }
    }

    func testCommonFrameAndKeyIdentifierKnownAnswers() throws {
        let publicKey = try F.publicKey(seed: issuerSeed)
        XCTAssertEqual(
            publicKey,
            hex("d75a980182b10ab7d54bfed3c964073a0ee172f3daa62325af021a68f707511a")
        )
        let expectedFrame = hex(
            "4550524834505631002c" +
            "636f6d2e657267656e746963732e70726f76656e616e63652e68347076312e6b65792d69642e697373756572" +
            "0000000000000020" +
            "d75a980182b10ab7d54bfed3c964073a0ee172f3daa62325af021a68f707511a"
        )
        XCTAssertEqual(try F.frame(domain: .issuerKeyID, payload: publicKey), expectedFrame)
        XCTAssertEqual(
            try F.issuerKeyID(publicKey: publicKey),
            hex("f3dbc3f0ebf0cd65671bc96384bb0f62ee2c2d5b7d9c345e288533ae22d3b4b5")
        )
        XCTAssertEqual(
            try F.verifierKeyID(publicKey: publicKey),
            hex("6f783cc4bf69b0703d3ee8c038ace02b746779c2fb3de6b4e34288950910fb9b")
        )
        XCTAssertEqual(
            try F.storageKeyID(key: storageKey),
            hex("2ea81f2a3e5187fdc4b39d3876dd596ff0c3f13b1415ef02174066e5d851a91a")
        )
        XCTAssertEqual(try F.frame(
            domain: .request,
            payload: Data(repeating: 0, count: F.maximumCanonicalBytes)
        ).count, 8 + 2 + F.Domain.request.rawValue.utf8.count + 8 + F.maximumCanonicalBytes)
        XCTAssertThrowsError(try F.frame(
            domain: .request,
            payload: Data(repeating: 0, count: F.maximumCanonicalBytes + 1)
        ))
    }

    func testHMACAndPrivateTokenKnownAnswers() throws {
        let key = Data(repeating: 0x0b, count: 20) + Data(repeating: 0, count: 12)
        XCTAssertEqual(
            try F.authenticationCode(key: key, domain: .privateToken, payload: Data()),
            hex("5766309200da1f5392d4e8be4cf13fd7f4a5516056f9cf54ca7c3b5da336a533")
        )
        let expected = [
            "d0d06eb7863dfc708f4c5d22663a1aeb9f24b466634789f7b53e4fe9b82f19bb",
            "83143e70b96a597e84768b5e9d78fdf99614193fb7252d5f69b15ee16eb5c323",
            "85eb47b8ed9f82ae6b95366343ec3e95ab990a59e45afa65140ae3e625bdeedf",
            "cd3934e2b4f46e38d3b419e0c8693cde395d3f2d8636d41be3a7388b94e56ba1",
            "f4f4386ca72aee0cf3a250a751b6bae76e1c56e11af21d4a02a6e38a224ad9db",
            "698febbc89552b663814b8038c1dd6f8a982bc881724ee17ca0ba847492a3cf9",
            "b7890116b95e37a66905ae68909d671e8080d7dc60e5b9c20aa46f89d674ef69",
        ]
        for kind in 0...6 {
            let descriptor = try tokenDescriptor(kind: UInt64(kind))
            let blind = Data(repeating: UInt8(0x80 + kind), count: 32)
            let token = try privateTokenPrimitive(blind: blind, descriptor: descriptor)
            XCTAssertEqual(token, hex(expected[kind]))
            XCTAssertTrue(try F.verifyAuthenticationCode(
                token, key: blind, domain: .privateToken, payload: descriptor
            ))
        }
        let oppositeOrdinalBoundaries: [(UInt64, UInt64, String)] = [
            (
                5, 4_095,
                "73d4f6e3a50b2e269ac11173898a8c1ccd08bfaa16a0634c9029150e413687ff"
            ),
            (
                6, 0,
                "dc9015ff733b9c56274c65bdab3b342a1047f90bae089d8a7f5e973642712b4f"
            ),
        ]
        for (kind, ordinal, expectedToken) in oppositeOrdinalBoundaries {
            let descriptor = try tokenDescriptor(kind: kind, ordinal: ordinal)
            let blind = Data(repeating: UInt8(0x80 + kind), count: 32)
            XCTAssertEqual(
                try privateTokenPrimitive(blind: blind, descriptor: descriptor),
                hex(expectedToken)
            )
        }
        XCTAssertFalse(try F.verifyAuthenticationCode(
            Data(repeating: 0, count: 32), key: key, domain: .privateToken, payload: Data()
        ))
        XCTAssertThrowsError(try F.authenticationCode(
            key: Data(repeating: 0, count: 31), domain: .privateToken, payload: Data()
        ))
    }

    func testPrivateTokenOrderCountDisclosureAndOneUseRetryRules() throws {
        let descriptor0 = try tokenDescriptor(kind: 5, ordinal: 0)
        let descriptor1 = try tokenDescriptor(kind: 5, ordinal: 1)
        let blind0 = Data(repeating: 0xa0, count: 32)
        let blind1 = Data(repeating: 0xa1, count: 32)
        let token0 = try privateTokenPrimitive(blind: blind0, descriptor: descriptor0)
        let token1 = try privateTokenPrimitive(blind: blind1, descriptor: descriptor1)
        let ordered = token0 + token1
        let reversed = token1 + token0
        XCTAssertNotEqual(ordered, reversed)
        XCTAssertEqual(Data(ordered.prefix(32)), token0)
        XCTAssertEqual(Data(ordered.suffix(32)), token1)

        var wrongCountFields = try F.decode(
            descriptor0,
            as: .privateTokenDescriptor
        ).fields
        wrongCountFields["byte_count"] = u(1)
        let wrongCountDescriptor = try F.encode(
            wrongCountFields,
            as: .privateTokenDescriptor
        )
        XCTAssertFalse(try F.verifyAuthenticationCode(
            token0,
            key: blind0,
            domain: .privateToken,
            payload: wrongCountDescriptor
        ))
        XCTAssertFalse(try F.verifyAuthenticationCode(
            token0,
            key: blind0,
            domain: .storageRecordAuth,
            payload: descriptor0
        ))
        XCTAssertThrowsError(try privateTokenPrimitive(
            blind: Data(repeating: 0, count: 31),
            descriptor: descriptor0
        ))

        let hiddenDigest = Data(repeating: 0xde, count: 32)
        let hiddenBlind = Data(repeating: 0xad, count: 32)
        var hiddenDescriptorFields = try F.decode(
            descriptor0,
            as: .privateTokenDescriptor
        ).fields
        hiddenDescriptorFields["deterministic_preimage_sha256"] = .bytes(hiddenDigest)
        let hiddenDescriptor = try F.encode(
            hiddenDescriptorFields,
            as: .privateTokenDescriptor
        )
        let hiddenToken = try privateTokenPrimitive(
            blind: hiddenBlind,
            descriptor: hiddenDescriptor
        )
        var lineageFields = try validFields(for: .lineageState, maximum: false)
        lineageFields["predicate_identifier_tokens"] = .bytes(hiddenToken)
        let lineage = try F.encode(lineageFields, as: .lineageState)
        XCTAssertNil(lineage.range(of: hiddenDigest))
        XCTAssertNil(lineage.range(of: hiddenBlind))
        XCTAssertNil(lineage.range(of: hiddenDescriptor))

        var batchDescriptors: [Data] = []
        for kind in 0...4 {
            batchDescriptors.append(try tokenDescriptor(kind: UInt64(kind)))
        }
        batchDescriptors += [descriptor0, descriptor1]
        batchDescriptors += [
            try tokenDescriptor(kind: 6, ordinal: 0),
            try tokenDescriptor(kind: 6, ordinal: 1),
        ]
        let blindBytes = (0..<batchDescriptors.count).map {
            Data(repeating: UInt8(0xb0 + $0), count: 32)
        }
        func makeBlinds() throws -> [F.OneUseBlind] {
            try blindBytes.map { try F.OneUseBlind($0) }
        }
        let projectedCounts = F.PrivateTokenCountProjection(
            canonicalJSONByteCount: 1,
            deterministicCBORByteCount: 1,
            graphStateCount: 0,
            graphWitnessCount: 0,
            graphTransitionCount: 0,
            predicateIdentifierByteCounts: [0, 0],
            predicateEvidenceByteCounts: [0, 0]
        )
        var wrongOrder = batchDescriptors
        wrongOrder.swapAt(5, 6)
        let orderedBlinds = try makeBlinds()
        XCTAssertThrowsError(try F.completePrivateTokens(
            blinds: orderedBlinds,
            descriptors: wrongOrder,
            counts: projectedCounts
        ))
        let completedTokens = try F.completePrivateTokens(
            blinds: orderedBlinds,
            descriptors: batchDescriptors,
            counts: projectedCounts
        )
        XCTAssertThrowsError(try F.completePrivateTokens(
            blinds: orderedBlinds,
            descriptors: batchDescriptors,
            counts: projectedCounts
        ))
        XCTAssertEqual(completedTokens.counts.predicateCount, 2)
        XCTAssertEqual(completedTokens.predicateIdentifiers.count, 64)
        XCTAssertEqual(completedTokens.predicateEvidence.count, 64)
        XCTAssertEqual(
            Data(completedTokens.predicateIdentifiers.prefix(32)),
            try privateTokenPrimitive(
                blind: blindBytes[5],
                descriptor: batchDescriptors[5]
            )
        )
        XCTAssertEqual(
            Data(completedTokens.predicateIdentifiers.suffix(32)),
            try privateTokenPrimitive(
                blind: blindBytes[6],
                descriptor: batchDescriptors[6]
            )
        )

        let wrongCountBlinds = try makeBlinds()
        XCTAssertThrowsError(try F.completePrivateTokens(
            blinds: Array(wrongCountBlinds.dropLast()),
            descriptors: Array(batchDescriptors.dropLast()),
            counts: projectedCounts
        ))
        XCTAssertNoThrow(try F.completePrivateTokens(
            blinds: wrongCountBlinds,
            descriptors: batchDescriptors,
            counts: projectedCounts
        ))

        var repeatedCapabilityBlinds = try makeBlinds()
        repeatedCapabilityBlinds[8] = repeatedCapabilityBlinds[0]
        XCTAssertThrowsError(try F.completePrivateTokens(
            blinds: repeatedCapabilityBlinds,
            descriptors: batchDescriptors,
            counts: projectedCounts
        ))
        var duplicateBytesBlinds = try makeBlinds()
        duplicateBytesBlinds[8] = try F.OneUseBlind(blindBytes[0])
        XCTAssertThrowsError(try F.completePrivateTokens(
            blinds: duplicateBytesBlinds,
            descriptors: batchDescriptors,
            counts: projectedCounts
        ))
        duplicateBytesBlinds[8] = try F.OneUseBlind(blindBytes[8])
        XCTAssertNoThrow(try F.completePrivateTokens(
            blinds: duplicateBytesBlinds,
            descriptors: batchDescriptors,
            counts: projectedCounts
        ))

        var completedLineageFields = try validFields(
            for: .lineageState,
            maximum: false
        )
        completedLineageFields["d3_semantic_private_token"] =
            .bytes(completedTokens.d3Semantic.bytes)
        completedLineageFields["canonical_json_private_token"] =
            .bytes(completedTokens.canonicalJSON.bytes)
        completedLineageFields["deterministic_cbor_private_token"] =
            .bytes(completedTokens.deterministicCBOR.bytes)
        completedLineageFields["indexed_scalar_private_token"] =
            .bytes(completedTokens.indexedScalar.bytes)
        completedLineageFields["graph_private_token"] = .bytes(completedTokens.graph.bytes)
        completedLineageFields["predicate_count"] = u(2)
        completedLineageFields["predicate_identifier_tokens"] =
            .bytes(completedTokens.predicateIdentifiers)
        completedLineageFields["predicate_result_codes"] = .bytes(Data([0, 0]))
        completedLineageFields["predicate_evidence_tokens"] =
            .bytes(completedTokens.predicateEvidence)
        let completedLineage = try F.encode(
            completedLineageFields,
            as: .lineageState
        )
        XCTAssertNoThrow(try F.validateCompletedPrivateTokens(
            completedTokens,
            lineageStateBytes: completedLineage
        ))
        completedLineageFields["canonical_json_byte_count"] = u(2)
        let wrongPublicCountLineage = try F.encode(
            completedLineageFields,
            as: .lineageState
        )
        XCTAssertThrowsError(try F.validateCompletedPrivateTokens(
            completedTokens,
            lineageStateBytes: wrongPublicCountLineage
        ))
        completedLineageFields["canonical_json_byte_count"] = u(1)
        completedLineageFields["sequence"] = u(1)
        let wrongContextLineage = try F.encode(
            completedLineageFields,
            as: .lineageState
        )
        XCTAssertThrowsError(try F.validateCompletedPrivateTokens(
            completedTokens,
            lineageStateBytes: wrongContextLineage
        ))

        let requestFixture = try authenticatedRequestFixture()
        let completedAssertion = try F.completeAssertionForRetry(
            lineageStateBytes: requestFixture.lineage,
            assertionBytes: requestFixture.assertion,
            issuerEnvelopeBytes: requestFixture.issuerEnvelope,
            context: requestFixture.context
        )
        XCTAssertEqual(try F.requireExactRetry(
            of: completedAssertion,
            lineageStateBytes: requestFixture.lineage,
            assertionBytes: requestFixture.assertion,
            issuerEnvelopeBytes: requestFixture.issuerEnvelope
        ), completedAssertion)

        var reblindedFields = try F.decode(
            requestFixture.lineage,
            as: .lineageState
        ).fields
        reblindedFields["predicate_identifier_tokens"] = .bytes(try privateTokenPrimitive(
            blind: Data(repeating: 0xf1, count: 32),
            descriptor: descriptor0
        ))
        let reblindedLineage = try F.encode(reblindedFields, as: .lineageState)
        XCTAssertThrowsError(try F.requireExactRetry(
            of: completedAssertion,
            lineageStateBytes: reblindedLineage,
            assertionBytes: requestFixture.assertion,
            issuerEnvelopeBytes: requestFixture.issuerEnvelope
        ))
        XCTAssertNotEqual(
            try F.commitment(domain: .lineageState, payload: reblindedLineage),
            try F.commitment(
                domain: .lineageState,
                payload: completedAssertion.lineageState.bytes
            )
        )
    }

    func testH4CFramedSourceDigestKnownAnswers() throws {
        let vectors: [(UInt32, String, String)] = [
            (
                1,
                "eed176b0f2397177ac03f329795fa6528497646bdb54bb8b4fa3c3affae39a33",
                "45cd9dc92ac088dde7e8281763ad783f5896f2fcd826d3dec74c2fa70bd055ee"
            ),
            (
                4_096,
                "b19e928e8ee3d3339f4ada0aa1383bad2f6d5e9d89c51262ced0092d57ca42a5",
                "b533c50818c28555acfb78893b622f4e927dc6931e20cc761348520c9a7c9930"
            ),
        ]
        for (count, jsonDigest, cborDigest) in vectors {
            XCTAssertEqual(
                try F.canonicalJSONPreimageDigest(expectedJSON(predicateCount: count)),
                hex(jsonDigest)
            )
            XCTAssertEqual(
                try F.deterministicCBORPreimageDigest(expectedCBOR(predicateCount: count)),
                hex(cborDigest)
            )
        }
        XCTAssertThrowsError(try F.canonicalJSONPreimageDigest(
            Data(" {\"predicate_count\":1}".utf8)
        ))
        var reorderedCBOR = expectedCBOR(predicateCount: 1)
        reorderedCBOR.swapAt(1, 69)
        XCTAssertThrowsError(try F.deterministicCBORPreimageDigest(reorderedCBOR))
    }

    func testEd25519ProtocolKnownAnswerAndDomainBinding() throws {
        let publicKey = try F.publicKey(seed: issuerSeed)
        let expectedFrame = hex(
            "45505248345056310039" +
            "636f6d2e657267656e746963732e70726f76656e616e63652e68347076312e" +
            "7369676e61747572652e6973737565722d617373657274696f6e" +
            "0000000000000000"
        )
        XCTAssertEqual(
            try F.frame(domain: .issuerSignature, payload: Data()),
            expectedFrame
        )
        let expectedSignature = hex(
            "e69d6a086a760f9565d6291f4cae08bb182da42e49966c33a65d8f8061da7733" +
            "abd55a3d569f6526286f0ee9b542d26f4dcea7104e269e4e3ede564b89e83605"
        )
        XCTAssertTrue(try F.verify(
            signature: expectedSignature,
            publicKey: publicKey,
            domain: .issuerSignature,
            payload: Data()
        ))
        XCTAssertFalse(try F.verify(
            signature: expectedSignature,
            publicKey: publicKey,
            domain: .challengeSignature,
            payload: Data()
        ))
        XCTAssertFalse(try F.verify(
            signature: expectedSignature,
            publicKey: publicKey,
            domain: .issuerSignature,
            payload: Data([0])
        ))
        for index in expectedSignature.indices {
            var mutated = expectedSignature
            mutated[index] ^= 1
            XCTAssertFalse(try F.verify(
                signature: mutated,
                publicKey: publicKey,
                domain: .issuerSignature,
                payload: Data()
            ), "signature byte \(index)")
        }
    }

    func testVerifierOwnedSignatureDomainKnownAnswers() throws {
        let publicKey = try F.publicKey(seed: verifierSeed)
        XCTAssertEqual(
            publicKey,
            hex("3d4017c3e843895a92b70aa74d1b7ebc9c982ccf2ec4968cc0cd55f12af4660c")
        )
        XCTAssertEqual(
            try F.verifierKeyID(publicKey: publicKey),
            hex("30b3f52a007b691e8f3858f5c42b93c888101f6496bd5a26c6ea68294f5f73cb")
        )
        let vectors: [(F.Domain, String, String)] = [
            (
                .challengeSignature,
                "45505248345056310032636f6d2e657267656e746963732e70726f76656e616e63652e68347076312e7369676e61747572652e6368616c6c656e67650000000000000000",
                "24a6945d74fae4f3836c73e39b544d0d42957deb9c9d0707b025250041c198fca450978b5173fb24dc1a67c6247314d37e16a857a84e943f9123a784cfcd5b0a"
            ),
            (
                .migrationSignature,
                "45505248345056310032636f6d2e657267656e746963732e70726f76656e616e63652e68347076312e7369676e61747572652e6d6967726174696f6e0000000000000000",
                "e4b5c24e7082a6e73bb165ee856c8185fbb521b770f5690c35cedad5665d3443619941a8d967624c5e660ee2340029d9be168622bbc15b6c666ac279ed043c02"
            ),
            (
                .receiptSignature,
                "45505248345056310030636f6d2e657267656e746963732e70726f76656e616e63652e68347076312e7369676e61747572652e726563656970740000000000000000",
                "40f993ed6460212915797c22d973de19514951217e5d6de5c8338a46d7f296c11dfbaaab1af79a0279c4ee4d01a0c462d5e132ab657af3fbe6749fc671b73a00"
            ),
        ]
        for (domain, frame, signature) in vectors {
            XCTAssertEqual(try F.frame(domain: domain, payload: Data()), hex(frame))
            XCTAssertTrue(try F.verify(
                signature: hex(signature),
                publicKey: publicKey,
                domain: domain,
                payload: Data()
            ))
        }
    }

    func testEd25519StrictEncodingRejectionsPrecedeCryptoKit() throws {
        let publicKey = try F.publicKey(seed: issuerSeed)
        let valid = hex(
            "e69d6a086a760f9565d6291f4cae08bb182da42e49966c33a65d8f8061da7733" +
            "abd55a3d569f6526286f0ee9b542d26f4dcea7104e269e4e3ede564b89e83605"
        )
        let validS = Data(valid.suffix(32))
        let validR = Data(valid.prefix(32))
        let firstOrderEight = hex(
            "26e8958fc2b227b045c3f489f2ef98f0d5dfac05d3c63339b13802886d53fc05"
        )
        let secondOrderEight = hex(
            "c7176a703d4dd84fba3c0b760d10670f2a2053fa2c39ccc64ec7fd7792ac037a"
        )
        var firstNegative = firstOrderEight
        firstNegative[31] |= 0x80
        var secondNegative = secondOrderEight
        secondNegative[31] |= 0x80
        let smallOrder = [
            Data(repeating: 0, count: 32),
            Data(repeating: 0, count: 31) + Data([0x80]),
            Data([1]) + Data(repeating: 0, count: 31),
            Data([0xec]) + Data(repeating: 0xff, count: 30) + Data([0x7f]),
            firstOrderEight, firstNegative, secondOrderEight, secondNegative,
        ]
        for point in smallOrder {
            XCTAssertFalse(try F.verify(
                signature: valid, publicKey: point,
                domain: .issuerSignature, payload: Data()
            ))
            XCTAssertFalse(try F.verify(
                signature: point + validS, publicKey: publicKey,
                domain: .issuerSignature, payload: Data()
            ))
        }

        let fieldPrime = Data([0xed])
            + Data(repeating: 0xff, count: 30) + Data([0x7f])
        let fieldPrimePlusOne = Data([0xee])
            + Data(repeating: 0xff, count: 30) + Data([0x7f])
        let maximumFieldEncoding = Data(repeating: 0xff, count: 31)
            + Data([0x7f])
        let nonzeroXWithNegativeSign = Data([0x01])
            + Data(repeating: 0, count: 30) + Data([0x80])
        let fieldPrimeMinusOneWithNegativeSign = Data([0xec])
            + Data(repeating: 0xff, count: 31)
        let noncanonicalPoints: [Data] = [
            fieldPrime,
            fieldPrimePlusOne,
            maximumFieldEncoding,
            nonzeroXWithNegativeSign,
            fieldPrimeMinusOneWithNegativeSign,
        ]
        for point in noncanonicalPoints {
            XCTAssertFalse(try F.verify(
                signature: valid, publicKey: point,
                domain: .issuerSignature, payload: Data()
            ))
            XCTAssertFalse(try F.verify(
                signature: point + validS, publicKey: publicKey,
                domain: .issuerSignature, payload: Data()
            ))
        }

        let order = hex(
            "edd3f55c1a631258d69cf7a2def9de1400000000000000000000000000000010"
        )
        var orderPlusOne = order
        orderPlusOne[0] = 0xee
        for scalar in [order, orderPlusOne, Data(repeating: 0xff, count: 32)] {
            XCTAssertFalse(try F.verify(
                signature: validR + scalar, publicKey: publicKey,
                domain: .issuerSignature, payload: Data()
            ))
        }
        XCTAssertFalse(try F.verify(
            signature: Data(valid.dropLast()), publicKey: publicKey,
            domain: .issuerSignature, payload: Data()
        ))
        XCTAssertFalse(try F.verify(
            signature: valid, publicKey: Data(publicKey.dropLast()),
            domain: .issuerSignature, payload: Data()
        ))
    }

    func testStorageAuthenticationAndPointerKnownAnswers() throws {
        let key = storageKey
        let trustedGenesis = data32(0x31)
        let genesisTag = try F.storageGenesisTag(
            key: key,
            trustedGenesisCommitment: trustedGenesis
        )
        XCTAssertEqual(
            genesisTag,
            hex("5567013b773dc83d6ec8210e976a32df001cf35e34a497e279b74fa97d73d892")
        )
        let predecessor = try F.fixedPredecessor(
            trustedGenesisCommitment: trustedGenesis
        )
        XCTAssertEqual(
            predecessor,
            hex("732381958ceb8dd52a1dd09edc8ee108b00c2284bff5b6fb28d6d6aa3fd762ac")
        )

        var wrapperFields = try validFields(for: .storageRecordWrapper, maximum: false)
        wrapperFields["previous_record_auth_tag"] = .bytes(genesisTag)
        wrapperFields["record_body_commitment"] = b32(0x41)
        let wrapper = try F.encode(wrapperFields, as: .storageRecordWrapper)
        let wrapperTag = try F.storageRecordAuthenticationCode(key: key, wrapper: wrapper)
        XCTAssertEqual(
            wrapperTag,
            hex("a3458f5c050244f03797b3e5767254d9797282d0101a6d1a66f892f494a95b50")
        )

        var pointerFields = try validFields(for: .authorityPointer, maximum: false)
        pointerFields["trusted_genesis_commitment"] = .bytes(trustedGenesis)
        pointerFields["policy_commitment"] = b32(0x32)
        pointerFields["lineage_id"] = b32(0x33)
        pointerFields["epoch_id"] = b32(0x34)
        pointerFields["authority_tip_record_commitment"] = b32(0x41)
        pointerFields["authority_tip_record_auth_tag"] = .bytes(wrapperTag)
        pointerFields["accepted_record_or_fixed_predecessor"] = .bytes(predecessor)
        pointerFields["accepted_lineage_state_or_fixed_predecessor"] = .bytes(predecessor)
        let pointer = try F.encode(pointerFields, as: .authorityPointer)
        XCTAssertEqual(
            try F.authorityPointerCommitment(pointer),
            hex("dec0688d615fec6b7f44960f3eb842f3c6728941f8e4de45da1947045f25160c")
        )
        XCTAssertEqual(
            try F.authorityPointerAuthenticationCode(key: key, pointer: pointer),
            hex("cf3b357cb95789ef39a595d5afea3316ca55b5aec545f93dbb9a2f685679b23b")
        )
    }

    func testStoredRecordAndAuthorityPointerJoinsAuthenticateTwoRecordChain() throws {
        let fixture = try provisionedFixture()
        let context = fixture.context
        let key = storageKey
        let predecessor = try F.fixedPredecessor(
            trustedGenesisCommitment: context.trustedGenesisCommitment.bytes
        )

        var uninitializedFields = try validFields(
            for: .uninitializedRecord,
            maximum: false
        )
        uninitializedFields["trusted_genesis_body"] = .bytes(fixture.genesis)
        uninitializedFields["trusted_genesis_commitment"] =
            .bytes(context.trustedGenesisCommitment.bytes)
        uninitializedFields["policy_body"] = .bytes(fixture.policy)
        uninitializedFields["policy_commitment"] = .bytes(context.policyCommitment.bytes)
        uninitializedFields["verifier_id"] = .bytes(context.verifierID.bytes)
        uninitializedFields["lineage_id"] = .bytes(context.lineageID.bytes)
        uninitializedFields["epoch_id"] = .bytes(context.epochID.bytes)
        for key in [
            "previous_authority_tip_commitment", "fixed_predecessor",
            "accepted_record_commitment", "accepted_lineage_state_commitment",
            "migration_authorization_envelope_commitment",
        ] {
            uninitializedFields[key] = .bytes(predecessor)
        }
        let uninitializedBody = try F.encode(
            uninitializedFields,
            as: .uninitializedRecord
        )
        let uninitializedCommitment = try F.commitment(
            domain: .uninitializedRecord,
            payload: uninitializedBody
        )
        XCTAssertEqual(
            uninitializedCommitment,
            independentCommitment(
                domain: .uninitializedRecord,
                payload: uninitializedBody
            )
        )
        let genesisTag = try F.storageGenesisTag(
            key: key,
            trustedGenesisCommitment: context.trustedGenesisCommitment.bytes
        )
        XCTAssertEqual(
            genesisTag,
            independentAuthenticationCode(
                key: key,
                domain: .storageGenesisTag,
                payload: context.trustedGenesisCommitment.bytes
            )
        )
        var wrapper0Fields = try validFields(for: .storageRecordWrapper, maximum: false)
        wrapper0Fields["previous_record_auth_tag"] = .bytes(genesisTag)
        wrapper0Fields["record_body_commitment"] = .bytes(uninitializedCommitment)
        wrapper0Fields["record_body_byte_count"] = u(UInt64(uninitializedBody.count))
        let wrapper0 = try F.encode(wrapper0Fields, as: .storageRecordWrapper)
        let wrapper0Tag = try F.storageRecordAuthenticationCode(key: key, wrapper: wrapper0)
        XCTAssertEqual(
            wrapper0Tag,
            independentAuthenticationCode(
                key: key,
                domain: .storageRecordAuth,
                payload: wrapper0
            )
        )
        let record0 = try F.verifyStoredRecord(
            bodyBytes: uninitializedBody,
            wrapperBytes: wrapper0,
            authenticationTag: wrapper0Tag,
            key: key,
            predecessor: .genesis(context)
        )
        XCTAssertEqual(context.storageKeyID.bytes, try F.storageKeyID(key: key))
        XCTAssertEqual(record0.epochAnchor.storageKeyID, context.storageKeyID)

        let wrongKey = migratedStorageKey
        let wrongKeyGenesisTag = try F.storageGenesisTag(
            key: wrongKey,
            trustedGenesisCommitment: context.trustedGenesisCommitment.bytes
        )
        var wrongKeyWrapper0Fields = wrapper0Fields
        wrongKeyWrapper0Fields["previous_record_auth_tag"] = .bytes(wrongKeyGenesisTag)
        let wrongKeyWrapper0 = try F.encode(
            wrongKeyWrapper0Fields,
            as: .storageRecordWrapper
        )
        let wrongKeyWrapper0Tag = try F.storageRecordAuthenticationCode(
            key: wrongKey,
            wrapper: wrongKeyWrapper0
        )
        XCTAssertThrowsError(try F.verifyStoredRecord(
            bodyBytes: uninitializedBody,
            wrapperBytes: wrongKeyWrapper0,
            authenticationTag: wrongKeyWrapper0Tag,
            key: wrongKey,
            predecessor: .genesis(context)
        )) {
            XCTAssertEqual($0 as? F.Failure, .crossField)
        }

        var pointer0Fields = try validFields(for: .authorityPointer, maximum: false)
        pointer0Fields["trusted_genesis_commitment"] =
            .bytes(context.trustedGenesisCommitment.bytes)
        pointer0Fields["policy_commitment"] = .bytes(context.policyCommitment.bytes)
        pointer0Fields["lineage_id"] = .bytes(context.lineageID.bytes)
        pointer0Fields["epoch_id"] = .bytes(context.epochID.bytes)
        pointer0Fields["authority_tip_record_commitment"] = .bytes(uninitializedCommitment)
        pointer0Fields["authority_tip_record_auth_tag"] = .bytes(wrapper0Tag)
        pointer0Fields["accepted_record_or_fixed_predecessor"] = .bytes(predecessor)
        pointer0Fields["accepted_lineage_state_or_fixed_predecessor"] = .bytes(predecessor)
        let pointer0 = try F.encode(pointer0Fields, as: .authorityPointer)
        let pointer0Tag = try F.authorityPointerAuthenticationCode(key: key, pointer: pointer0)
        let state0 = try F.verifyAuthorityPointer(
            pointerBytes: pointer0,
            authenticationTag: pointer0Tag,
            key: key,
            tip: record0,
            prior: nil,
            context: context
        )
        XCTAssertEqual(state0.epochAnchor, record0.epochAnchor)

        var acceptedFields = try validFields(for: .acceptedTransition, maximum: false)
        acceptedFields["previous_authority_tip_commitment"] = .bytes(uninitializedCommitment)
        acceptedFields["trusted_genesis_commitment"] =
            .bytes(context.trustedGenesisCommitment.bytes)
        acceptedFields["policy_commitment"] = .bytes(context.policyCommitment.bytes)
        acceptedFields["verifier_id"] = .bytes(context.verifierID.bytes)
        acceptedFields["lineage_id"] = .bytes(context.lineageID.bytes)
        acceptedFields["epoch_id"] = .bytes(context.epochID.bytes)
        acceptedFields["predecessor_lineage_state_commitment"] = .bytes(predecessor)
        acceptedFields["prior_accepted_record_commitment"] = .bytes(predecessor)
        let acceptedBody = try F.encode(acceptedFields, as: .acceptedTransition)
        let acceptedCommitment = try F.commitment(
            domain: .acceptedRecord,
            payload: acceptedBody
        )
        guard case .bytes(let acceptedLineage)? = acceptedFields["lineage_state_commitment"] else {
            return XCTFail("Missing accepted lineage commitment")
        }
        var wrapper1Fields = try validFields(for: .storageRecordWrapper, maximum: false)
        wrapper1Fields["record_kind"] = u(2)
        wrapper1Fields["record_index"] = u(1)
        wrapper1Fields["previous_record_auth_tag"] = .bytes(wrapper0Tag)
        wrapper1Fields["record_body_commitment"] = .bytes(acceptedCommitment)
        wrapper1Fields["record_body_byte_count"] = u(UInt64(acceptedBody.count))
        let wrapper1 = try F.encode(wrapper1Fields, as: .storageRecordWrapper)
        let wrapper1Tag = try F.storageRecordAuthenticationCode(key: key, wrapper: wrapper1)
        let record1 = try F.verifyStoredRecord(
            bodyBytes: acceptedBody,
            wrapperBytes: wrapper1,
            authenticationTag: wrapper1Tag,
            key: key,
            predecessor: .record(record0)
        )
        XCTAssertEqual(record1.epochAnchor, record0.epochAnchor)

        let wrongKeyWrapper1Tag = try F.storageRecordAuthenticationCode(
            key: wrongKey,
            wrapper: wrapper1
        )
        XCTAssertThrowsError(try F.verifyStoredRecord(
            bodyBytes: acceptedBody,
            wrapperBytes: wrapper1,
            authenticationTag: wrongKeyWrapper1Tag,
            key: wrongKey,
            predecessor: .record(record0)
        )) {
            XCTAssertEqual($0 as? F.Failure, .crossField)
        }

        var pointer1Fields = pointer0Fields
        pointer1Fields["authority_generation"] = u(1)
        pointer1Fields["authority_tip_record_index"] = u(1)
        pointer1Fields["authority_tip_record_kind"] = u(2)
        pointer1Fields["authority_tip_record_commitment"] = .bytes(acceptedCommitment)
        pointer1Fields["authority_tip_record_auth_tag"] = .bytes(wrapper1Tag)
        pointer1Fields["lifecycle_code"] = u(2)
        pointer1Fields["accepted_present"] = .bool(true)
        pointer1Fields["accepted_record_or_fixed_predecessor"] = .bytes(acceptedCommitment)
        pointer1Fields["accepted_lineage_state_or_fixed_predecessor"] = .bytes(acceptedLineage)
        let pointer1 = try F.encode(pointer1Fields, as: .authorityPointer)
        let pointer1Tag = try F.authorityPointerAuthenticationCode(key: key, pointer: pointer1)
        let state1 = try F.verifyAuthorityPointer(
            pointerBytes: pointer1,
            authenticationTag: pointer1Tag,
            key: key,
            tip: record1,
            prior: state0,
            context: context
        )
        XCTAssertEqual(state1.epochAnchor, state0.epochAnchor)

        let wrongKeyPointer1Tag = try F.authorityPointerAuthenticationCode(
            key: wrongKey,
            pointer: pointer1
        )
        XCTAssertThrowsError(try F.verifyAuthorityPointer(
            pointerBytes: pointer1,
            authenticationTag: wrongKeyPointer1Tag,
            key: wrongKey,
            tip: record1,
            prior: state0,
            context: context
        )) {
            XCTAssertEqual($0 as? F.Failure, .crossField)
        }

        var otherPolicyFields = context.policy.fields
        otherPolicyFields["audience_id"] = b32(0xa0)
        let otherPolicy = try F.encode(otherPolicyFields, as: .policy)
        let otherPolicyCommitment = try F.commitment(
            domain: .policy,
            payload: otherPolicy
        )
        var otherGenesisFields = context.trustedGenesis.fields
        otherGenesisFields["policy_commitment"] = .bytes(otherPolicyCommitment)
        otherGenesisFields["policy_byte_count"] = u(UInt64(otherPolicy.count))
        otherGenesisFields["lineage_id"] = b32(0xa1)
        otherGenesisFields["epoch_id"] = b32(0xa2)
        otherGenesisFields["genesis_nonce"] = b32(0xa3)
        let otherGenesis = try F.encode(otherGenesisFields, as: .genesisInitial)
        let otherContext = try F.makeProvisionedContext(
            disclosureModeTable: context.disclosureModeTable.bytes,
            policy: otherPolicy,
            trustedGenesis: otherGenesis
        )
        XCTAssertEqual(otherContext.storageKeyID, context.storageKeyID)
        XCTAssertNotEqual(otherContext.policyCommitment, context.policyCommitment)
        XCTAssertNotEqual(
            otherContext.trustedGenesisCommitment,
            context.trustedGenesisCommitment
        )

        let otherPredecessor = try F.fixedPredecessor(
            trustedGenesisCommitment: otherContext.trustedGenesisCommitment.bytes
        )
        var otherUninitializedFields = uninitializedFields
        otherUninitializedFields["trusted_genesis_body"] = .bytes(otherGenesis)
        otherUninitializedFields["trusted_genesis_commitment"] =
            .bytes(otherContext.trustedGenesisCommitment.bytes)
        otherUninitializedFields["policy_body"] = .bytes(otherPolicy)
        otherUninitializedFields["policy_commitment"] =
            .bytes(otherContext.policyCommitment.bytes)
        otherUninitializedFields["verifier_id"] = .bytes(otherContext.verifierID.bytes)
        otherUninitializedFields["lineage_id"] = .bytes(otherContext.lineageID.bytes)
        otherUninitializedFields["epoch_id"] = .bytes(otherContext.epochID.bytes)
        for field in [
            "previous_authority_tip_commitment", "fixed_predecessor",
            "accepted_record_commitment", "accepted_lineage_state_commitment",
            "migration_authorization_envelope_commitment",
        ] {
            otherUninitializedFields[field] = .bytes(otherPredecessor)
        }
        let otherUninitializedBody = try F.encode(
            otherUninitializedFields,
            as: .uninitializedRecord
        )
        let otherUninitializedCommitment = try F.commitment(
            domain: .uninitializedRecord,
            payload: otherUninitializedBody
        )
        let otherGenesisTag = try F.storageGenesisTag(
            key: key,
            trustedGenesisCommitment: otherContext.trustedGenesisCommitment.bytes
        )
        var otherWrapper0Fields = wrapper0Fields
        otherWrapper0Fields["previous_record_auth_tag"] = .bytes(otherGenesisTag)
        otherWrapper0Fields["record_body_commitment"] =
            .bytes(otherUninitializedCommitment)
        otherWrapper0Fields["record_body_byte_count"] =
            u(UInt64(otherUninitializedBody.count))
        let otherWrapper0 = try F.encode(
            otherWrapper0Fields,
            as: .storageRecordWrapper
        )
        let otherWrapper0Tag = try F.storageRecordAuthenticationCode(
            key: key,
            wrapper: otherWrapper0
        )
        let otherRecord0 = try F.verifyStoredRecord(
            bodyBytes: otherUninitializedBody,
            wrapperBytes: otherWrapper0,
            authenticationTag: otherWrapper0Tag,
            key: key,
            predecessor: .genesis(otherContext)
        )
        var otherPointer0Fields = pointer0Fields
        otherPointer0Fields["trusted_genesis_commitment"] =
            .bytes(otherContext.trustedGenesisCommitment.bytes)
        otherPointer0Fields["policy_commitment"] =
            .bytes(otherContext.policyCommitment.bytes)
        otherPointer0Fields["lineage_id"] = .bytes(otherContext.lineageID.bytes)
        otherPointer0Fields["epoch_id"] = .bytes(otherContext.epochID.bytes)
        otherPointer0Fields["authority_tip_record_commitment"] =
            .bytes(otherRecord0.bodyCommitment.bytes)
        otherPointer0Fields["authority_tip_record_auth_tag"] =
            .bytes(otherRecord0.authenticationTag.bytes)
        otherPointer0Fields["accepted_record_or_fixed_predecessor"] =
            .bytes(otherPredecessor)
        otherPointer0Fields["accepted_lineage_state_or_fixed_predecessor"] =
            .bytes(otherPredecessor)
        let otherPointer0 = try F.encode(otherPointer0Fields, as: .authorityPointer)
        let otherPointer0Tag = try F.authorityPointerAuthenticationCode(
            key: key,
            pointer: otherPointer0
        )
        let otherState0 = try F.verifyAuthorityPointer(
            pointerBytes: otherPointer0,
            authenticationTag: otherPointer0Tag,
            key: key,
            tip: otherRecord0,
            prior: nil,
            context: otherContext
        )
        XCTAssertThrowsError(try F.verifyAuthorityPointer(
            pointerBytes: pointer1,
            authenticationTag: pointer1Tag,
            key: key,
            tip: record1,
            prior: otherState0,
            context: context
        )) {
            XCTAssertEqual($0 as? F.Failure, .crossField)
        }

        var crossContextFields = acceptedFields
        crossContextFields["trusted_genesis_commitment"] =
            .bytes(otherContext.trustedGenesisCommitment.bytes)
        crossContextFields["policy_commitment"] = .bytes(otherContext.policyCommitment.bytes)
        crossContextFields["lineage_id"] = .bytes(otherContext.lineageID.bytes)
        crossContextFields["epoch_id"] = .bytes(otherContext.epochID.bytes)
        let crossContextBody = try F.encode(
            crossContextFields,
            as: .acceptedTransition
        )
        let crossContextCommitment = try F.commitment(
            domain: .acceptedRecord,
            payload: crossContextBody
        )
        var crossContextWrapperFields = wrapper1Fields
        crossContextWrapperFields["record_body_commitment"] =
            .bytes(crossContextCommitment)
        crossContextWrapperFields["record_body_byte_count"] =
            u(UInt64(crossContextBody.count))
        let crossContextWrapper = try F.encode(
            crossContextWrapperFields,
            as: .storageRecordWrapper
        )
        let crossContextTag = try F.storageRecordAuthenticationCode(
            key: key,
            wrapper: crossContextWrapper
        )
        XCTAssertThrowsError(try F.verifyStoredRecord(
            bodyBytes: crossContextBody,
            wrapperBytes: crossContextWrapper,
            authenticationTag: crossContextTag,
            key: key,
            predecessor: .record(record0)
        )) {
            XCTAssertEqual($0 as? F.Failure, .crossField)
        }
        XCTAssertThrowsError(try F.verifyAuthorityPointer(
            pointerBytes: pointer1,
            authenticationTag: pointer1Tag,
            key: key,
            tip: record1,
            prior: state0,
            context: otherContext
        )) {
            XCTAssertEqual($0 as? F.Failure, .crossField)
        }

        var mutatedBodyFields = acceptedFields
        mutatedBodyFields["lineage_state_commitment"] = b32(0xfe)
        let mutatedBody = try F.encode(mutatedBodyFields, as: .acceptedTransition)
        XCTAssertThrowsError(try F.verifyStoredRecord(
            bodyBytes: mutatedBody,
            wrapperBytes: wrapper1,
            authenticationTag: wrapper1Tag,
            key: key,
            predecessor: .record(record0)
        ))

        var invalidWrappers: [[String: V]] = []
        var invalid = wrapper1Fields
        invalid["record_kind"] = u(3)
        invalidWrappers.append(invalid)
        invalid = wrapper1Fields
        invalid["record_index"] = u(2)
        invalidWrappers.append(invalid)
        invalid = wrapper1Fields
        invalid["record_body_byte_count"] = u(UInt64(acceptedBody.count + 1))
        invalidWrappers.append(invalid)
        invalid = wrapper1Fields
        invalid["record_body_commitment"] = b32(0xff)
        invalidWrappers.append(invalid)
        invalid = wrapper1Fields
        invalid["previous_record_auth_tag"] = b32(0xff)
        invalidWrappers.append(invalid)
        for fields in invalidWrappers {
            let bytes = try F.encode(fields, as: .storageRecordWrapper)
            let tag = try F.storageRecordAuthenticationCode(key: key, wrapper: bytes)
            XCTAssertThrowsError(try F.verifyStoredRecord(
                bodyBytes: acceptedBody,
                wrapperBytes: bytes,
                authenticationTag: tag,
                key: key,
                predecessor: .record(record0)
            ))
        }
        var badWrapperTag = wrapper1Tag
        badWrapperTag[0] ^= 1
        XCTAssertThrowsError(try F.verifyStoredRecord(
            bodyBytes: acceptedBody,
            wrapperBytes: wrapper1,
            authenticationTag: badWrapperTag,
            key: key,
            predecessor: .record(record0)
        ))

        var invalidPointers: [[String: V]] = []
        var invalidPointer = pointer1Fields
        invalidPointer["policy_commitment"] = b32(0xff)
        invalidPointers.append(invalidPointer)
        invalidPointer = pointer1Fields
        invalidPointer["authority_tip_record_commitment"] = b32(0xff)
        invalidPointer["accepted_record_or_fixed_predecessor"] = b32(0xff)
        invalidPointers.append(invalidPointer)
        invalidPointer = pointer1Fields
        invalidPointer["authority_tip_record_auth_tag"] = b32(0xff)
        invalidPointers.append(invalidPointer)
        invalidPointer = pointer1Fields
        invalidPointer["accepted_lineage_state_or_fixed_predecessor"] = b32(0xff)
        invalidPointers.append(invalidPointer)
        invalidPointer = pointer1Fields
        invalidPointer["authority_generation"] = u(2)
        invalidPointer["authority_tip_record_index"] = u(2)
        invalidPointers.append(invalidPointer)
        for fields in invalidPointers {
            let bytes = try F.encode(fields, as: .authorityPointer)
            let tag = try F.authorityPointerAuthenticationCode(key: key, pointer: bytes)
            XCTAssertThrowsError(try F.verifyAuthorityPointer(
                pointerBytes: bytes,
                authenticationTag: tag,
                key: key,
                tip: record1,
                prior: state0,
                context: context
            ))
        }
        var badPointerTag = pointer1Tag
        badPointerTag[0] ^= 1
        XCTAssertThrowsError(try F.verifyAuthorityPointer(
            pointerBytes: pointer1,
            authenticationTag: badPointerTag,
            key: key,
            tip: record1,
            prior: state0,
            context: context
        ))
    }

    func testPackedAndConditionalCrossFieldRulesReject() throws {
        var descriptor = try validFields(for: .privateTokenDescriptor, maximum: false)
        descriptor["field_ordinal"] = u(1)
        XCTAssertThrowsError(try F.encode(descriptor, as: .privateTokenDescriptor))

        var lineage = try validFields(for: .lineageState, maximum: false)
        lineage["predicate_identifier_tokens"] = .bytes(Data(repeating: 1, count: 31))
        XCTAssertThrowsError(try F.encode(lineage, as: .lineageState))
        lineage = try validFields(for: .lineageState, maximum: false)
        lineage["predicate_result_codes"] = .bytes(Data([4]))
        XCTAssertThrowsError(try F.encode(lineage, as: .lineageState))

        var decision = try validFields(for: .verifierDecision, maximum: false)
        decision["proposed_persistent_record_kind"] = u(3)
        XCTAssertThrowsError(try F.encode(decision, as: .verifierDecision))

        var conflict = try validFields(for: .conflictTombstone, maximum: false)
        conflict["competing_lineage_state_commitment"] =
            conflict["accepted_lineage_state_commitment"]
        XCTAssertThrowsError(try F.encode(conflict, as: .conflictTombstone))

        var wrapper = try validFields(for: .storageRecordWrapper, maximum: false)
        wrapper["record_index"] = u(1)
        XCTAssertThrowsError(try F.encode(wrapper, as: .storageRecordWrapper))

        var fault = try validFields(for: .storageFaultLatch, maximum: false)
        fault["last_authenticated_authority_tip_commitment"] = b32(0xff)
        XCTAssertThrowsError(try F.encode(fault, as: .storageFaultLatch))
        fault = try validFields(for: .storageFaultLatch, maximum: false)
        fault["attempted_record_kind"] = u(3)
        XCTAssertThrowsError(try F.encode(fault, as: .storageFaultLatch))

        var pointer = try validFields(for: .authorityPointer, maximum: false)
        pointer["authority_generation"] = u(1)
        XCTAssertThrowsError(try F.encode(pointer, as: .authorityPointer))
        pointer = try validFields(for: .authorityPointer, maximum: false)
        pointer["lifecycle_code"] = u(2)
        XCTAssertThrowsError(try F.encode(pointer, as: .authorityPointer))

        pointer = try validFields(for: .authorityPointer, maximum: false)
        pointer["authority_generation"] = u(1)
        pointer["authority_tip_record_index"] = u(1)
        XCTAssertThrowsError(try F.encode(pointer, as: .authorityPointer))

        pointer = try validFields(for: .authorityPointer, maximum: false)
        pointer["authority_tip_record_kind"] = u(2)
        pointer["lifecycle_code"] = u(2)
        pointer["accepted_present"] = .bool(true)
        pointer["accepted_record_or_fixed_predecessor"] =
            pointer["authority_tip_record_commitment"]
        XCTAssertThrowsError(try F.encode(pointer, as: .authorityPointer))

        pointer = try validFields(for: .authorityPointer, maximum: false)
        pointer["accepted_present"] = .bool(true)
        XCTAssertThrowsError(try F.encode(pointer, as: .authorityPointer))

        for (kind, lifecycle) in [(UInt64(2), UInt64(2)), (3, 3), (6, 5)] {
            pointer = try validFields(for: .authorityPointer, maximum: false)
            pointer["authority_generation"] = u(1)
            pointer["authority_tip_record_index"] = u(1)
            pointer["authority_tip_record_kind"] = u(kind)
            pointer["lifecycle_code"] = u(lifecycle)
            XCTAssertThrowsError(try F.encode(pointer, as: .authorityPointer))
        }

        pointer = try validFields(for: .authorityPointer, maximum: false)
        pointer["accepted_record_or_fixed_predecessor"] = b32(0xff)
        pointer["accepted_lineage_state_or_fixed_predecessor"] = b32(0xff)
        XCTAssertThrowsError(try F.encode(pointer, as: .authorityPointer))

        pointer = try validFields(for: .authorityPointer, maximum: false)
        pointer["authority_generation"] = u(1)
        pointer["authority_tip_record_index"] = u(1)
        pointer["authority_tip_record_kind"] = u(2)
        pointer["lifecycle_code"] = u(2)
        pointer["accepted_present"] = .bool(true)
        pointer["accepted_record_or_fixed_predecessor"] = b32(0xff)
        pointer["accepted_lineage_state_or_fixed_predecessor"] = b32(0xfe)
        XCTAssertThrowsError(try F.encode(pointer, as: .authorityPointer))

        var close = try validFields(for: .terminalClose, maximum: false)
        close["accepted_record_or_fixed_predecessor"] = b32(0xff)
        close["accepted_lineage_state_or_fixed_predecessor"] = b32(0xff)
        XCTAssertThrowsError(try F.encode(close, as: .terminalClose))

        var terminal = try validFields(for: .receiptTerminal, maximum: true)
        terminal["result_record_kind"] = u(5)
        XCTAssertThrowsError(try F.encode(terminal, as: .receiptTerminal))
    }

    func testNestedObjectCommitmentAndCountJoinsReject() throws {
        var uninitialized = try validFields(for: .uninitializedRecord, maximum: false)
        uninitialized["fixed_predecessor"] = b32(0xff)
        XCTAssertThrowsError(try F.encode(uninitialized, as: .uninitializedRecord))

        var request = try validFields(for: .assertionRequest, maximum: false)
        let envelopeBytes: Data
        guard case .bytes(let originalEnvelope)? = request["challenge_envelope"] else {
            XCTFail("Missing challenge envelope")
            return
        }
        var envelope = try F.decode(originalEnvelope, as: .verifierSignatureEnvelope).fields
        envelope["signed_body_commitment"] = b32(0xff)
        envelopeBytes = try F.encode(envelope, as: .verifierSignatureEnvelope)
        request["challenge_envelope"] = .bytes(envelopeBytes)
        XCTAssertThrowsError(try F.encode(request, as: .assertionRequest))

        let validPolicy = try F.encode(
            validFields(for: .policy, maximum: false),
            as: .policy
        )
        XCTAssertThrowsError(try F.decode(validPolicy + Data([0]), as: .policy))
        XCTAssertThrowsError(try F.decode(validPolicy, as: .challenge))
    }

    func testClosedSchemasRejectRecordDecisionAndReceiptCycles() throws {
        let forbiddenEdges: [(F.Schema, String)] = [
            (.acceptedTransition, "record_self_commitment"),
            (.verifierDecision, "future_record_commitment"),
            (.acceptedTransition, "receipt_feedback_commitment"),
            (.receiptAcceptedCurrent, "receipt_self_commitment"),
        ]
        for (schema, edge) in forbiddenEdges {
            var fields = try validFields(for: schema, maximum: false)
            fields[edge] = b32(0xee)
            let bytes = try F.encodeCanonical(.map(fields))
            XCTAssertThrowsError(try F.decode(bytes, as: schema), edge) {
                XCTAssertEqual($0 as? F.Failure, .fieldInventory)
            }
        }
    }

    func testGenesisAndEnvelopeCryptographicShapeJoinsReject() throws {
        var genesis = try validFields(for: .genesisInitial, maximum: false)
        genesis["issuer_key_id"] = b32(0xff)
        XCTAssertThrowsError(try F.encode(genesis, as: .genesisInitial))
        genesis = try validFields(for: .genesisInitial, maximum: false)
        genesis["issuer_public_key"] = .bytes(Data(repeating: 0, count: 32))
        XCTAssertThrowsError(try F.encode(genesis, as: .genesisInitial))

        var envelope = try validFields(for: .issuerSignatureEnvelope, maximum: false)
        let order = hex(
            "edd3f55c1a631258d69cf7a2def9de1400000000000000000000000000000010"
        )
        envelope["signature"] = .bytes(Data(structuralSignature.prefix(32)) + order)
        XCTAssertThrowsError(try F.encode(envelope, as: .issuerSignatureEnvelope))

        var challengeEnvelope = try validFields(
            for: .verifierSignatureEnvelope,
            maximum: false
        )
        challengeEnvelope["signed_body_byte_count"] = u(4_097)
        XCTAssertThrowsError(try F.encode(
            challengeEnvelope,
            as: .verifierSignatureEnvelope
        ))

        var policy = try validFields(for: .policy, maximum: false)
        policy["disclosure_mode_table_commitment"] = .bytes(Data(repeating: 0, count: 32))
        XCTAssertThrowsError(try F.encode(policy, as: .policy))
        XCTAssertThrowsError(try F.issuerKeyID(publicKey: Data(repeating: 0, count: 32)))
    }

    func testAuthenticatedRequestStageOrderingAndEnvelopeBindings() throws {
        let fixture = try authenticatedRequestFixture()
        let verifiedChallenge = try F.verifyVerifierEnvelope(
            bodyBytes: fixture.challenge,
            envelopeBytes: fixture.challengeEnvelope,
            verifierPublicKey: fixture.context.verifierPublicKey.bytes,
            expectedVerifierID: fixture.context.verifierID.bytes
        )
        let verifiedIssuer = try F.verifyIssuerEnvelope(
            assertionBytes: fixture.assertion,
            envelopeBytes: fixture.issuerEnvelope,
            issuerPublicKey: fixture.context.issuerPublicKey.bytes,
            expectedIssuerKeyID: fixture.context.issuerKeyID.bytes
        )
        XCTAssertEqual(verifiedChallenge.body.schema, .challenge)
        XCTAssertEqual(verifiedIssuer.body.schema, .issuerAssertion)

        var consumed: [F.ChallengeReference] = []
        let result = F.authenticateAssertionRequest(
            fixture.request,
            context: fixture.context
        ) {
            consumed.append($0)
            return true
        }
        guard case .eligible(let eligible) = result else {
            XCTFail("A correctly authenticated request was not eligible")
            return
        }
        XCTAssertEqual(consumed, [eligible.binding.challenge])
        XCTAssertEqual(
            eligible.binding.requestCommitment.bytes,
            try F.commitment(domain: .request, payload: fixture.request)
        )
        XCTAssertEqual(eligible.lineageStateCommitment.bytes, try F.commitment(
            domain: .lineageState,
            payload: fixture.lineage
        ))
        XCTAssertEqual(eligible.assertionBodyCommitment, verifiedIssuer.bodyCommitment)
        XCTAssertEqual(eligible.issuerEnvelopeCommitment, verifiedIssuer.envelopeCommitment)

        var trailingByteRequest = fixture.request
        trailingByteRequest.append(0)
        var trailingByteCalls = 0
        XCTAssertEqual(
            F.authenticateAssertionRequest(
                trailingByteRequest,
                context: fixture.context
            ) { _ in
                trailingByteCalls += 1
                return true
            },
            .noAuthenticatedResponse
        )
        XCTAssertEqual(trailingByteCalls, 0)

        let slicedRequest = (Data([0xff]) + fixture.request).dropFirst()
        XCTAssertEqual(slicedRequest.startIndex, 1)
        var slicedCalls = 0
        let slicedResult = F.authenticateAssertionRequest(
            slicedRequest,
            context: fixture.context
        ) { challenge in
            slicedCalls += 1
            return challenge == eligible.binding.challenge
        }
        guard case .eligible(let slicedEligible) = slicedResult else {
            XCTFail("A valid nonzero-startIndex Data slice was not eligible")
            return
        }
        XCTAssertEqual(slicedCalls, 1)
        XCTAssertEqual(slicedEligible.binding.requestCommitment, eligible.binding.requestCommitment)

        var reuseCalls = 0
        XCTAssertEqual(
            F.authenticateAssertionRequest(fixture.request, context: fixture.context) { _ in
                reuseCalls += 1
                return false
            },
            .noAuthenticatedResponse
        )
        XCTAssertEqual(reuseCalls, 1)

        func requestReplacing(
            _ key: String,
            with nested: Data,
            validateNested: Bool = true
        ) throws -> Data {
            var fields = try F.decode(fixture.request, as: .assertionRequest).fields
            fields[key] = .bytes(nested)
            return validateNested
                ? try F.encode(fields, as: .assertionRequest)
                : independentEncode(.map(fields))
        }

        var challengeEnvelopeFields = try F.decode(
            fixture.challengeEnvelope,
            as: .verifierSignatureEnvelope
        ).fields
        guard case .bytes(var badChallengeSignature)? =
                challengeEnvelopeFields["signature"] else {
            XCTFail("Missing challenge signature")
            return
        }
        badChallengeSignature[63] ^= 1
        challengeEnvelopeFields["signature"] = .bytes(badChallengeSignature)
        let badChallengeEnvelope = try F.encode(
            challengeEnvelopeFields,
            as: .verifierSignatureEnvelope
        )
        let unauthenticated = try requestReplacing(
            "challenge_envelope",
            with: badChallengeEnvelope
        )
        var preAuthenticationCalls = 0
        XCTAssertEqual(
            F.authenticateAssertionRequest(
                unauthenticated,
                context: fixture.context
            ) { _ in
                preAuthenticationCalls += 1
                return true
            },
            .noAuthenticatedResponse
        )
        XCTAssertEqual(preAuthenticationCalls, 0)

        var issuerEnvelopeFields = try F.decode(
            fixture.issuerEnvelope,
            as: .issuerSignatureEnvelope
        ).fields
        guard case .bytes(var badIssuerSignature)? = issuerEnvelopeFields["signature"] else {
            XCTFail("Missing issuer signature")
            return
        }
        badIssuerSignature[63] ^= 1
        issuerEnvelopeFields["signature"] = .bytes(badIssuerSignature)
        let badIssuerEnvelope = try F.encode(
            issuerEnvelopeFields,
            as: .issuerSignatureEnvelope
        )
        let postAuthenticationFailure = try requestReplacing(
            "issuer_signature_envelope",
            with: badIssuerEnvelope
        )
        var postAuthenticationCalls = 0
        let rejected = F.authenticateAssertionRequest(
            postAuthenticationFailure,
            context: fixture.context
        ) { _ in
            postAuthenticationCalls += 1
            return true
        }
        guard case .authenticatedRejected(let rejectedBinding) = rejected else {
            XCTFail("An issuer failure after challenge authentication was not classified")
            return
        }
        XCTAssertEqual(postAuthenticationCalls, 1)
        XCTAssertEqual(
            rejectedBinding.challenge.bodyCommitment,
            verifiedChallenge.bodyCommitment
        )

        var hiddenLineageFields = try F.decode(
            fixture.lineage,
            as: .lineageState
        ).fields
        hiddenLineageFields["raw_payload"] = .bytes(Data([0]))
        let hiddenFullD3 = try requestReplacing(
            "lineage_state_body",
            with: independentEncode(.map(hiddenLineageFields)),
            validateNested: false
        )
        var hiddenCalls = 0
        let hiddenResult = F.authenticateAssertionRequest(
            hiddenFullD3,
            context: fixture.context
        ) { _ in
            hiddenCalls += 1
            return true
        }
        guard case .authenticatedRejected = hiddenResult else {
            XCTFail("A hidden full-D3 field was not rejected after authentication")
            return
        }
        XCTAssertEqual(hiddenCalls, 1)

        var detachedLineageFields = try F.decode(
            fixture.lineage,
            as: .lineageState
        ).fields
        detachedLineageFields["d3_semantic_private_token"] = b32(0x99)
        let detachedLineage = try F.encode(
            detachedLineageFields,
            as: .lineageState
        )
        let detachedLineageRequest = try requestReplacing(
            "lineage_state_body",
            with: detachedLineage,
            validateNested: false
        )
        var detachedLineageCalls = 0
        let detachedLineageResult = F.authenticateAssertionRequest(
            detachedLineageRequest,
            context: fixture.context
        ) { _ in
            detachedLineageCalls += 1
            return true
        }
        guard case .authenticatedRejected = detachedLineageResult else {
            XCTFail("A lineage detached from its signed assertion was not rejected")
            return
        }
        XCTAssertEqual(detachedLineageCalls, 1)

        var mismatchedPackedFields = try F.decode(
            fixture.lineage,
            as: .lineageState
        ).fields
        mismatchedPackedFields["predicate_identifier_tokens"] = .bytes(
            Data(repeating: 0x31, count: 64)
        )
        let mismatchedPackedRequest = try requestReplacing(
            "lineage_state_body",
            with: independentEncode(.map(mismatchedPackedFields)),
            validateNested: false
        )
        var packedCalls = 0
        let packedResult = F.authenticateAssertionRequest(
            mismatchedPackedRequest,
            context: fixture.context
        ) { _ in
            packedCalls += 1
            return true
        }
        guard case .authenticatedRejected = packedResult else {
            XCTFail("Packed-vector mismatch did not reject after challenge authentication")
            return
        }
        XCTAssertEqual(packedCalls, 1)

        var wrongEnvelopeFields = try F.decode(
            fixture.challengeEnvelope,
            as: .verifierSignatureEnvelope
        ).fields
        wrongEnvelopeFields["verifier_key_id"] = b32(0xee)
        XCTAssertThrowsError(try F.verifyVerifierEnvelope(
            bodyBytes: fixture.challenge,
            envelopeBytes: try F.encode(
                wrongEnvelopeFields,
                as: .verifierSignatureEnvelope
            ),
            verifierPublicKey: fixture.context.verifierPublicKey.bytes,
            expectedVerifierID: fixture.context.verifierID.bytes
        ))
        XCTAssertThrowsError(try F.verifyVerifierEnvelope(
            bodyBytes: fixture.challenge,
            envelopeBytes: fixture.challengeEnvelope,
            verifierPublicKey: fixture.context.issuerPublicKey.bytes,
            expectedVerifierID: fixture.context.verifierID.bytes
        ))
        XCTAssertThrowsError(try F.verifyVerifierEnvelope(
            bodyBytes: fixture.challenge,
            envelopeBytes: fixture.challengeEnvelope,
            verifierPublicKey: fixture.context.verifierPublicKey.bytes,
            expectedVerifierID: data32(0xee)
        ))

        for (key, value) in [
            ("suite_id", V.text("wrong-suite")),
            ("verifier_key_position", V.unsigned(1)),
        ] {
            var structurallyInvalid = try F.decode(
                fixture.challengeEnvelope,
                as: .verifierSignatureEnvelope
            ).fields
            structurallyInvalid[key] = value
            XCTAssertThrowsError(try F.verifyVerifierEnvelope(
                bodyBytes: fixture.challenge,
                envelopeBytes: independentEncode(.map(structurallyInvalid)),
                verifierPublicKey: fixture.context.verifierPublicKey.bytes,
                expectedVerifierID: fixture.context.verifierID.bytes
            ))
        }
    }

    func testReceiptAndMigrationEnvelopeKnownAnswersAndCachedReceiptJoins() throws {
        let fixture = try authenticatedRequestFixture()
        let challengeCommitment = try F.commitment(
            domain: .challengeBody,
            payload: fixture.challenge
        )
        let requestCommitment = try F.commitment(
            domain: .request,
            payload: fixture.request
        )
        var receiptFields = try validFields(for: .receiptMinimized, maximum: false)
        receiptFields["verifier_id"] = .bytes(fixture.context.verifierID.bytes)
        receiptFields["verifier_key_id"] = .bytes(fixture.context.verifierID.bytes)
        receiptFields["policy_commitment"] = .bytes(fixture.context.policyCommitment.bytes)
        receiptFields["audience_id"] = .bytes(fixture.context.audienceID.bytes)
        receiptFields["challenge_body_commitment"] = .bytes(challengeCommitment)
        receiptFields["request_commitment"] = .bytes(requestCommitment)
        let receipt = try F.encode(receiptFields, as: .receiptMinimized)
        XCTAssertEqual(receipt.count, 561)
        XCTAssertEqual(
            Data(SHA256.hash(data: receipt)),
            hex("e884c6d13917564834d59759268b080ef323a049a48c116fd5d30890cb8a3599")
        )
        XCTAssertEqual(
            Data(SHA256.hash(data: try F.frame(
                domain: .receiptSignature,
                payload: receipt
            ))),
            hex("2f23a34d8c0db2003ac7fa05f4844408d5788b3b0a992bab78d0085f06b69784")
        )
        let receiptSignature = hex(
            "066d4ac3704b06349ce00f2802b82c2e3c391600485b81b8175330fe576036de" +
            "b07eace31f8974875b39d042f30546573628265445145c04dda89c04d0b5c007"
        )
        let receiptCommitment = try F.commitment(
            domain: .receiptMinimized,
            payload: receipt
        )
        XCTAssertEqual(
            receiptCommitment,
            hex("1fef896a8cd401d673cd3251cb8623b061c22d2213d1978a1e25e83507dee963")
        )
        var receiptEnvelopeFields = try validFields(
            for: .verifierSignatureEnvelope,
            maximum: false
        )
        receiptEnvelopeFields["signed_body_kind"] = u(2)
        receiptEnvelopeFields["verifier_key_id"] =
            .bytes(fixture.context.verifierID.bytes)
        receiptEnvelopeFields["signed_body_commitment"] = .bytes(receiptCommitment)
        receiptEnvelopeFields["signed_body_byte_count"] = u(UInt64(receipt.count))
        receiptEnvelopeFields["signature"] = .bytes(receiptSignature)
        let receiptEnvelope = try F.encode(
            receiptEnvelopeFields,
            as: .verifierSignatureEnvelope
        )
        let verifiedReceipt = try F.verifyAssertionReceipt(
            bodyBytes: receipt,
            envelopeBytes: receiptEnvelope,
            context: fixture.context,
            expectedChallenge: try F.Fixed32(challengeCommitment),
            expectedRequest: try F.Fixed32(requestCommitment)
        )
        XCTAssertEqual(verifiedReceipt.body.schema, .receiptMinimized)
        XCTAssertThrowsError(try F.verifyAssertionReceipt(
            bodyBytes: receipt,
            envelopeBytes: receiptEnvelope,
            context: fixture.context,
            expectedChallenge: try F.Fixed32(data32(0xee)),
            expectedRequest: try F.Fixed32(requestCommitment)
        ))
        XCTAssertThrowsError(try F.verifyAssertionReceipt(
            bodyBytes: receipt,
            envelopeBytes: receiptEnvelope,
            context: fixture.context,
            expectedChallenge: try F.Fixed32(challengeCommitment),
            expectedRequest: try F.Fixed32(data32(0xee))
        ))

        var migrationFields = try validFields(
            for: .migrationAuthorization,
            maximum: false
        )
        migrationFields["old_verifier_id"] = .bytes(fixture.context.verifierID.bytes)
        migrationFields["old_verifier_public_key"] =
            .bytes(fixture.context.verifierPublicKey.bytes)
        migrationFields["old_trusted_genesis_commitment"] =
            .bytes(fixture.context.trustedGenesisCommitment.bytes)
        let migration = try F.encode(migrationFields, as: .migrationAuthorization)
        XCTAssertEqual(migration.count, 751)
        XCTAssertEqual(
            Data(SHA256.hash(data: migration)),
            hex("a13442469b5dd22a4fa7b3fd0eb7419112eeda42e538733902aa96f589ac0384")
        )
        XCTAssertEqual(
            Data(SHA256.hash(data: try F.frame(
                domain: .migrationSignature,
                payload: migration
            ))),
            hex("048802b313b993c5efb3bf7e92757bc2ffbf3998dd654eb84c088986add1ef03")
        )
        let migrationSignature = hex(
            "66b9b3e4d6399a889527c59eaab661559e474062963a07af48dd01bb14b12a49" +
            "8e4a07659ffa8ae3b9515c75014b5dfaffc4a60a8071fabe005c72be7e4e9f07"
        )
        let migrationCommitment = try F.commitment(
            domain: .migrationBody,
            payload: migration
        )
        XCTAssertEqual(
            migrationCommitment,
            hex("82ceedd1d48e66ffd7101e1817989de51bcd091589c54c8cc4b98c35f89aae10")
        )
        var migrationEnvelopeFields = try validFields(
            for: .verifierSignatureEnvelope,
            maximum: false
        )
        migrationEnvelopeFields["signed_body_kind"] = u(3)
        migrationEnvelopeFields["verifier_key_id"] =
            .bytes(fixture.context.verifierID.bytes)
        migrationEnvelopeFields["signed_body_commitment"] = .bytes(migrationCommitment)
        migrationEnvelopeFields["signed_body_byte_count"] = u(UInt64(migration.count))
        migrationEnvelopeFields["signature"] = .bytes(migrationSignature)
        let migrationEnvelope = try F.encode(
            migrationEnvelopeFields,
            as: .verifierSignatureEnvelope
        )
        let verifiedMigration = try F.verifyVerifierEnvelope(
            bodyBytes: migration,
            envelopeBytes: migrationEnvelope,
            verifierPublicKey: fixture.context.verifierPublicKey.bytes,
            expectedVerifierID: fixture.context.verifierID.bytes
        )
        XCTAssertEqual(verifiedMigration.body.schema, .migrationAuthorization)

        migrationEnvelopeFields["signature"] = .bytes(receiptSignature)
        XCTAssertThrowsError(try F.verifyVerifierEnvelope(
            bodyBytes: migration,
            envelopeBytes: try F.encode(
                migrationEnvelopeFields,
                as: .verifierSignatureEnvelope
            ),
            verifierPublicKey: fixture.context.verifierPublicKey.bytes,
            expectedVerifierID: fixture.context.verifierID.bytes
        ))
        receiptEnvelopeFields["signature"] = .bytes(migrationSignature)
        XCTAssertThrowsError(try F.verifyAssertionReceipt(
            bodyBytes: receipt,
            envelopeBytes: try F.encode(
                receiptEnvelopeFields,
                as: .verifierSignatureEnvelope
            ),
            context: fixture.context,
            expectedChallenge: try F.Fixed32(challengeCommitment),
            expectedRequest: try F.Fixed32(requestCommitment)
        ))
    }

    func testFullNoncircularCommitmentGraphAndMigrationAnchors() throws {
        let fixture = try authenticatedRequestFixture()
        let context = fixture.context
        let authentication = F.authenticateAssertionRequest(
            fixture.request,
            context: context,
            consumeChallenge: { _ in true }
        )
        guard case .eligible(let eligible) = authentication else {
            return XCTFail("Expected eligible graph fixture")
        }
        XCTAssertEqual(
            context.policy.fields["disclosure_mode_table_commitment"],
            .bytes(independentCommitment(
                domain: .disclosureModeTable,
                payload: context.disclosureModeTable.bytes
            ))
        )
        XCTAssertEqual(
            context.policy.fields["disclosure_mode_table_byte_count"],
            u(UInt64(context.disclosureModeTable.bytes.count))
        )
        XCTAssertEqual(
            context.policyCommitment.bytes,
            independentCommitment(domain: .policy, payload: context.policy.bytes)
        )
        XCTAssertEqual(
            context.trustedGenesisCommitment.bytes,
            independentCommitment(
                domain: .genesisInitial,
                payload: context.trustedGenesis.bytes
            )
        )
        XCTAssertEqual(
            context.trustedGenesis.fields["policy_commitment"],
            .bytes(context.policyCommitment.bytes)
        )
        XCTAssertEqual(
            context.trustedGenesis.fields["policy_byte_count"],
            u(UInt64(context.policy.bytes.count))
        )
        XCTAssertEqual(
            context.verifierID.bytes,
            independentCommitment(
                domain: .verifierKeyID,
                payload: context.verifierPublicKey.bytes
            )
        )
        XCTAssertEqual(
            context.issuerKeyID.bytes,
            independentCommitment(
                domain: .issuerKeyID,
                payload: context.issuerPublicKey.bytes
            )
        )
        XCTAssertEqual(
            eligible.lineageStateCommitment.bytes,
            independentCommitment(domain: .lineageState, payload: fixture.lineage)
        )
        XCTAssertEqual(
            eligible.assertionBodyCommitment.bytes,
            independentCommitment(domain: .assertionBody, payload: fixture.assertion)
        )
        XCTAssertEqual(
            eligible.issuerEnvelopeCommitment.bytes,
            independentCommitment(domain: .issuerEnvelope, payload: fixture.issuerEnvelope)
        )
        XCTAssertEqual(
            eligible.binding.challenge.bodyCommitment.bytes,
            independentCommitment(domain: .challengeBody, payload: fixture.challenge)
        )
        XCTAssertEqual(
            eligible.binding.challenge.envelopeCommitment.bytes,
            independentCommitment(
                domain: .verifierEnvelope,
                payload: fixture.challengeEnvelope
            )
        )
        XCTAssertEqual(
            eligible.binding.requestCommitment.bytes,
            independentCommitment(domain: .request, payload: fixture.request)
        )
        let key = storageKey
        let predecessor = try F.fixedPredecessor(
            trustedGenesisCommitment: context.trustedGenesisCommitment.bytes
        )
        XCTAssertEqual(
            predecessor,
            independentCommitment(
                domain: .fixedPredecessor,
                payload: context.trustedGenesisCommitment.bytes
            )
        )

        var uninitializedFields = try validFields(
            for: .uninitializedRecord,
            maximum: false
        )
        uninitializedFields["trusted_genesis_body"] = .bytes(context.trustedGenesis.bytes)
        uninitializedFields["trusted_genesis_commitment"] =
            .bytes(context.trustedGenesisCommitment.bytes)
        uninitializedFields["policy_body"] = .bytes(context.policy.bytes)
        uninitializedFields["policy_commitment"] = .bytes(context.policyCommitment.bytes)
        uninitializedFields["verifier_id"] = .bytes(context.verifierID.bytes)
        uninitializedFields["lineage_id"] = .bytes(context.lineageID.bytes)
        uninitializedFields["epoch_id"] = .bytes(context.epochID.bytes)
        for field in [
            "previous_authority_tip_commitment", "fixed_predecessor",
            "accepted_record_commitment", "accepted_lineage_state_commitment",
            "migration_authorization_envelope_commitment",
        ] {
            uninitializedFields[field] = .bytes(predecessor)
        }
        let uninitializedBody = try F.encode(
            uninitializedFields,
            as: .uninitializedRecord
        )
        let uninitializedCommitment = try F.commitment(
            domain: .uninitializedRecord,
            payload: uninitializedBody
        )
        XCTAssertEqual(
            uninitializedCommitment,
            independentCommitment(
                domain: .uninitializedRecord,
                payload: uninitializedBody
            )
        )
        let genesisTag = try F.storageGenesisTag(
            key: key,
            trustedGenesisCommitment: context.trustedGenesisCommitment.bytes
        )
        XCTAssertEqual(
            genesisTag,
            independentAuthenticationCode(
                key: key,
                domain: .storageGenesisTag,
                payload: context.trustedGenesisCommitment.bytes
            )
        )
        var wrapper0Fields = try validFields(
            for: .storageRecordWrapper,
            maximum: false
        )
        wrapper0Fields["previous_record_auth_tag"] = .bytes(genesisTag)
        wrapper0Fields["record_body_commitment"] = .bytes(uninitializedCommitment)
        wrapper0Fields["record_body_byte_count"] = u(UInt64(uninitializedBody.count))
        let wrapper0 = try F.encode(wrapper0Fields, as: .storageRecordWrapper)
        let wrapper0Tag = try F.storageRecordAuthenticationCode(key: key, wrapper: wrapper0)
        XCTAssertEqual(
            wrapper0Tag,
            independentAuthenticationCode(
                key: key,
                domain: .storageRecordAuth,
                payload: wrapper0
            )
        )
        let record0 = try F.verifyStoredRecord(
            bodyBytes: uninitializedBody,
            wrapperBytes: wrapper0,
            authenticationTag: wrapper0Tag,
            key: key,
            predecessor: .genesis(context)
        )
        var pointer0Fields = try validFields(for: .authorityPointer, maximum: false)
        pointer0Fields["trusted_genesis_commitment"] =
            .bytes(context.trustedGenesisCommitment.bytes)
        pointer0Fields["policy_commitment"] = .bytes(context.policyCommitment.bytes)
        pointer0Fields["lineage_id"] = .bytes(context.lineageID.bytes)
        pointer0Fields["epoch_id"] = .bytes(context.epochID.bytes)
        pointer0Fields["authority_tip_record_commitment"] =
            .bytes(uninitializedCommitment)
        pointer0Fields["authority_tip_record_auth_tag"] = .bytes(wrapper0Tag)
        pointer0Fields["accepted_record_or_fixed_predecessor"] = .bytes(predecessor)
        pointer0Fields["accepted_lineage_state_or_fixed_predecessor"] =
            .bytes(predecessor)
        let pointer0 = try F.encode(pointer0Fields, as: .authorityPointer)
        let pointer0Tag = try F.authorityPointerAuthenticationCode(
            key: key,
            pointer: pointer0
        )
        XCTAssertEqual(
            pointer0Tag,
            independentAuthenticationCode(
                key: key,
                domain: .authorityPointerAuth,
                payload: pointer0
            )
        )
        let state0 = try F.verifyAuthorityPointer(
            pointerBytes: pointer0,
            authenticationTag: pointer0Tag,
            key: key,
            tip: record0,
            prior: nil,
            context: context
        )
        XCTAssertEqual(
            state0.pointerCommitment.bytes,
            independentCommitment(domain: .authorityPointer, payload: pointer0)
        )

        var decisionFields = try validFields(for: .verifierDecision, maximum: false)
        decisionFields["verifier_id"] = .bytes(context.verifierID.bytes)
        decisionFields["policy_commitment"] = .bytes(context.policyCommitment.bytes)
        decisionFields["request_commitment"] = .bytes(eligible.binding.requestCommitment.bytes)
        decisionFields["challenge_body_commitment"] =
            .bytes(eligible.binding.challenge.bodyCommitment.bytes)
        decisionFields["prior_authority_pointer_commitment"] =
            .bytes(state0.pointerCommitment.bytes)
        decisionFields["prior_authority_tip_commitment"] =
            .bytes(record0.bodyCommitment.bytes)
        decisionFields["prior_accepted_record_commitment"] = .bytes(predecessor)
        decisionFields["prior_lineage_state_commitment"] = .bytes(predecessor)
        decisionFields["candidate_sequence"] = u(eligible.sequence)
        decisionFields["candidate_predecessor_commitment"] =
            .bytes(eligible.predecessorLineageStateCommitment.bytes)
        decisionFields["candidate_lineage_state_commitment"] =
            .bytes(eligible.lineageStateCommitment.bytes)
        decisionFields["candidate_assertion_body_commitment"] =
            .bytes(eligible.assertionBodyCommitment.bytes)
        decisionFields["candidate_signature_envelope_commitment"] =
            .bytes(eligible.issuerEnvelopeCommitment.bytes)
        let decision = try F.encode(decisionFields, as: .verifierDecision)
        let decisionCommitment = try F.commitment(domain: .decision, payload: decision)
        XCTAssertEqual(
            decisionCommitment,
            independentCommitment(domain: .decision, payload: decision)
        )

        var acceptedFields = try validFields(for: .acceptedTransition, maximum: false)
        acceptedFields["previous_authority_tip_commitment"] =
            .bytes(record0.bodyCommitment.bytes)
        acceptedFields["trusted_genesis_commitment"] =
            .bytes(context.trustedGenesisCommitment.bytes)
        acceptedFields["policy_commitment"] = .bytes(context.policyCommitment.bytes)
        acceptedFields["verifier_id"] = .bytes(context.verifierID.bytes)
        acceptedFields["lineage_id"] = .bytes(context.lineageID.bytes)
        acceptedFields["epoch_id"] = .bytes(context.epochID.bytes)
        acceptedFields["sequence"] = u(eligible.sequence)
        acceptedFields["predecessor_lineage_state_commitment"] =
            .bytes(eligible.predecessorLineageStateCommitment.bytes)
        acceptedFields["lineage_state_commitment"] =
            .bytes(eligible.lineageStateCommitment.bytes)
        acceptedFields["issuer_assertion_body_commitment"] =
            .bytes(eligible.assertionBodyCommitment.bytes)
        acceptedFields["issuer_signature_envelope_commitment"] =
            .bytes(eligible.issuerEnvelopeCommitment.bytes)
        acceptedFields["verifier_decision_commitment"] = .bytes(decisionCommitment)
        acceptedFields["prior_accepted_record_commitment"] = .bytes(predecessor)
        let acceptedBody = try F.encode(acceptedFields, as: .acceptedTransition)
        let acceptedCommitment = try F.commitment(
            domain: .acceptedRecord,
            payload: acceptedBody
        )
        XCTAssertEqual(
            acceptedCommitment,
            independentCommitment(domain: .acceptedRecord, payload: acceptedBody)
        )
        var wrapper1Fields = wrapper0Fields
        wrapper1Fields["record_kind"] = u(2)
        wrapper1Fields["record_index"] = u(1)
        wrapper1Fields["previous_record_auth_tag"] = .bytes(record0.authenticationTag.bytes)
        wrapper1Fields["record_body_commitment"] = .bytes(acceptedCommitment)
        wrapper1Fields["record_body_byte_count"] = u(UInt64(acceptedBody.count))
        let wrapper1 = try F.encode(wrapper1Fields, as: .storageRecordWrapper)
        let wrapper1Tag = try F.storageRecordAuthenticationCode(key: key, wrapper: wrapper1)
        XCTAssertEqual(
            wrapper1Tag,
            independentAuthenticationCode(
                key: key,
                domain: .storageRecordAuth,
                payload: wrapper1
            )
        )
        let record1 = try F.verifyStoredRecord(
            bodyBytes: acceptedBody,
            wrapperBytes: wrapper1,
            authenticationTag: wrapper1Tag,
            key: key,
            predecessor: .record(record0)
        )
        var pointer1Fields = pointer0Fields
        pointer1Fields["authority_generation"] = u(1)
        pointer1Fields["authority_tip_record_index"] = u(1)
        pointer1Fields["authority_tip_record_kind"] = u(2)
        pointer1Fields["authority_tip_record_commitment"] = .bytes(acceptedCommitment)
        pointer1Fields["authority_tip_record_auth_tag"] = .bytes(wrapper1Tag)
        pointer1Fields["lifecycle_code"] = u(2)
        pointer1Fields["accepted_present"] = .bool(true)
        pointer1Fields["accepted_record_or_fixed_predecessor"] =
            .bytes(acceptedCommitment)
        pointer1Fields["accepted_lineage_state_or_fixed_predecessor"] =
            .bytes(eligible.lineageStateCommitment.bytes)
        let pointer1 = try F.encode(pointer1Fields, as: .authorityPointer)
        let pointer1Tag = try F.authorityPointerAuthenticationCode(
            key: key,
            pointer: pointer1
        )
        XCTAssertEqual(
            pointer1Tag,
            independentAuthenticationCode(
                key: key,
                domain: .authorityPointerAuth,
                payload: pointer1
            )
        )
        let state1 = try F.verifyAuthorityPointer(
            pointerBytes: pointer1,
            authenticationTag: pointer1Tag,
            key: key,
            tip: record1,
            prior: state0,
            context: context
        )
        XCTAssertEqual(
            state1.pointerCommitment.bytes,
            independentCommitment(domain: .authorityPointer, payload: pointer1)
        )

        var acceptedReceiptFields = try validFields(
            for: .receiptAcceptedCurrent,
            maximum: false
        )
        acceptedReceiptFields["verifier_id"] = .bytes(context.verifierID.bytes)
        acceptedReceiptFields["verifier_key_id"] = .bytes(context.verifierID.bytes)
        acceptedReceiptFields["policy_commitment"] = .bytes(context.policyCommitment.bytes)
        acceptedReceiptFields["audience_id"] = .bytes(context.audienceID.bytes)
        acceptedReceiptFields["challenge_body_commitment"] =
            .bytes(eligible.binding.challenge.bodyCommitment.bytes)
        acceptedReceiptFields["request_commitment"] =
            .bytes(eligible.binding.requestCommitment.bytes)
        acceptedReceiptFields["decision_commitment"] = .bytes(decisionCommitment)
        acceptedReceiptFields["accepted_sequence"] = u(eligible.sequence)
        acceptedReceiptFields["accepted_record_commitment"] =
            .bytes(record1.bodyCommitment.bytes)
        acceptedReceiptFields["accepted_lineage_state_commitment"] =
            .bytes(eligible.lineageStateCommitment.bytes)
        acceptedReceiptFields["authority_pointer_commitment"] =
            .bytes(state1.pointerCommitment.bytes)
        acceptedReceiptFields["authority_tip_commitment"] =
            .bytes(state1.tip.bodyCommitment.bytes)
        acceptedReceiptFields["authority_generation"] = u(state1.tip.index)
        let acceptedReceipt = try F.encode(
            acceptedReceiptFields,
            as: .receiptAcceptedCurrent
        )
        XCTAssertEqual(acceptedReceipt.count, 918)
        XCTAssertEqual(
            Data(SHA256.hash(data: acceptedReceipt)),
            hex("f4ead32f31e874d1934d68ebdc10ca44f616c0034faccacd7bc23bcb7e9a1aa3")
        )
        XCTAssertEqual(
            Data(SHA256.hash(data: independentFrame(
                domain: .receiptSignature,
                payload: acceptedReceipt
            ))),
            hex("3b650ff5de409127bef391a4134b97b82c792fe003d8776df0e744f5e699db6f")
        )
        let acceptedReceiptSignature = hex(
            "f6ac85b1d291234cd9b01c3b7596e2754e3cb0797eef7fe40246354cf6b867c5" +
            "125674869a18992ef87706c024479d3beffb5014e70693e6b42fceb0656d7902"
        )
        XCTAssertTrue(try F.verify(
            signature: acceptedReceiptSignature,
            publicKey: context.verifierPublicKey.bytes,
            domain: .receiptSignature,
            payload: acceptedReceipt
        ))
        let acceptedReceiptCommitment = independentCommitment(
            domain: .receiptAcceptedCurrent,
            payload: acceptedReceipt
        )
        XCTAssertEqual(
            acceptedReceiptCommitment,
            hex("44bbc8ab39cac783a25bf1ad1aee342d76ff75ee1d5e675fe7ebe81e42db6f37")
        )
        var acceptedReceiptEnvelopeFields = try validFields(
            for: .verifierSignatureEnvelope,
            maximum: false
        )
        acceptedReceiptEnvelopeFields["signed_body_kind"] = u(2)
        acceptedReceiptEnvelopeFields["verifier_key_id"] =
            .bytes(context.verifierID.bytes)
        acceptedReceiptEnvelopeFields["signed_body_commitment"] =
            .bytes(acceptedReceiptCommitment)
        acceptedReceiptEnvelopeFields["signed_body_byte_count"] =
            u(UInt64(acceptedReceipt.count))
        acceptedReceiptEnvelopeFields["signature"] = .bytes(acceptedReceiptSignature)
        let acceptedReceiptEnvelope = try F.encode(
            acceptedReceiptEnvelopeFields,
            as: .verifierSignatureEnvelope
        )
        let verifiedAcceptedReceipt = try F.verifyAssertionReceipt(
            bodyBytes: acceptedReceipt,
            envelopeBytes: acceptedReceiptEnvelope,
            context: context,
            expectedChallenge: eligible.binding.challenge.bodyCommitment,
            expectedRequest: eligible.binding.requestCommitment
        )
        XCTAssertEqual(
            verifiedAcceptedReceipt.bodyCommitment.bytes,
            acceptedReceiptCommitment
        )
        XCTAssertEqual(
            verifiedAcceptedReceipt.envelopeCommitment.bytes,
            independentCommitment(
                domain: .verifierEnvelope,
                payload: acceptedReceiptEnvelope
            )
        )

        let newVerifierPublicKey = try F.publicKey(seed: data32(0x6d))
        let newVerifierID = try F.verifierKeyID(publicKey: newVerifierPublicKey)
        let migrationNonce = data32(0x77)
        var newGenesisFields = try genesis(
            .genesisMigrationIntent,
            maximum: false,
            policyCommitment: context.policyCommitment.bytes,
            policyByteCount: context.policy.bytes.count,
            storageKey: migratedStorageKey
        )
        newGenesisFields["verifier_public_key"] = .bytes(newVerifierPublicKey)
        newGenesisFields["verifier_id"] = .bytes(newVerifierID)
        newGenesisFields["lineage_id"] = b32(0x61)
        newGenesisFields["epoch_id"] = b32(0x62)
        newGenesisFields["genesis_nonce"] = b32(0x63)
        newGenesisFields["expected_old_verifier_id"] = .bytes(context.verifierID.bytes)
        newGenesisFields["expected_old_trusted_genesis_commitment"] =
            .bytes(context.trustedGenesisCommitment.bytes)
        newGenesisFields["migration_nonce"] = .bytes(migrationNonce)
        let newGenesis = try F.encode(
            newGenesisFields,
            as: .genesisMigrationIntent
        )
        let newContext = try F.makeProvisionedContext(
            disclosureModeTable: context.disclosureModeTable.bytes,
            policy: context.policy.bytes,
            trustedGenesis: newGenesis
        )
        XCTAssertNotEqual(newContext.verifierPublicKey, context.verifierPublicKey)
        XCTAssertNotEqual(newContext.verifierPublicKey, context.issuerPublicKey)
        XCTAssertNotEqual(newContext.storageKeyID, context.storageKeyID)
        XCTAssertEqual(
            newContext.storageKeyID.bytes,
            independentCommitment(domain: .storageKeyID, payload: migratedStorageKey)
        )
        XCTAssertEqual(
            newContext.verifierID.bytes,
            independentCommitment(
                domain: .verifierKeyID,
                payload: newVerifierPublicKey
            )
        )
        XCTAssertEqual(
            newContext.trustedGenesisCommitment.bytes,
            independentCommitment(
                domain: .genesisMigrationIntent,
                payload: newGenesis
            )
        )

        var terminalRequestFields = try validFields(
            for: .terminalMigrationRequest,
            maximum: false
        )
        terminalRequestFields["verifier_id"] = .bytes(context.verifierID.bytes)
        terminalRequestFields["trusted_genesis_commitment"] =
            .bytes(context.trustedGenesisCommitment.bytes)
        terminalRequestFields["expected_authority_pointer_commitment"] =
            .bytes(state1.pointerCommitment.bytes)
        terminalRequestFields["new_genesis_intent_commitment"] =
            .bytes(newContext.trustedGenesisCommitment.bytes)
        terminalRequestFields["new_verifier_id"] = .bytes(newContext.verifierID.bytes)
        terminalRequestFields["migration_nonce"] = .bytes(migrationNonce)
        let terminalRequest = try F.encode(
            terminalRequestFields,
            as: .terminalMigrationRequest
        )
        let terminalRequestCommitment = try F.commitment(
            domain: .terminalRequest,
            payload: terminalRequest
        )
        XCTAssertEqual(
            terminalRequestCommitment,
            independentCommitment(domain: .terminalRequest, payload: terminalRequest)
        )

        var terminalFields = try validFields(for: .terminalMigration, maximum: false)
        terminalFields["record_index"] = u(2)
        terminalFields["previous_authority_tip_commitment"] =
            .bytes(record1.bodyCommitment.bytes)
        terminalFields["trusted_genesis_commitment"] =
            .bytes(context.trustedGenesisCommitment.bytes)
        terminalFields["policy_commitment"] = .bytes(context.policyCommitment.bytes)
        terminalFields["verifier_id"] = .bytes(context.verifierID.bytes)
        terminalFields["lineage_id"] = .bytes(context.lineageID.bytes)
        terminalFields["epoch_id"] = .bytes(context.epochID.bytes)
        terminalFields["terminal_request_commitment"] =
            .bytes(terminalRequestCommitment)
        terminalFields["accepted_sequence"] = u(eligible.sequence)
        terminalFields["accepted_record_commitment"] =
            .bytes(record1.bodyCommitment.bytes)
        terminalFields["accepted_lineage_state_commitment"] =
            .bytes(eligible.lineageStateCommitment.bytes)
        terminalFields["new_genesis_intent_commitment"] =
            .bytes(newContext.trustedGenesisCommitment.bytes)
        terminalFields["new_verifier_id"] = .bytes(newContext.verifierID.bytes)
        terminalFields["migration_nonce"] = .bytes(migrationNonce)
        let terminalBody = try F.encode(terminalFields, as: .terminalMigration)
        let terminalCommitment = try F.commitment(
            domain: .terminalMigration,
            payload: terminalBody
        )
        XCTAssertEqual(
            terminalCommitment,
            independentCommitment(domain: .terminalMigration, payload: terminalBody)
        )
        var wrapper2Fields = wrapper1Fields
        wrapper2Fields["record_kind"] = u(6)
        wrapper2Fields["record_index"] = u(2)
        wrapper2Fields["previous_record_auth_tag"] = .bytes(record1.authenticationTag.bytes)
        wrapper2Fields["record_body_commitment"] = .bytes(terminalCommitment)
        wrapper2Fields["record_body_byte_count"] = u(UInt64(terminalBody.count))
        let wrapper2 = try F.encode(wrapper2Fields, as: .storageRecordWrapper)
        let wrapper2Tag = try F.storageRecordAuthenticationCode(key: key, wrapper: wrapper2)
        XCTAssertEqual(
            wrapper2Tag,
            independentAuthenticationCode(
                key: key,
                domain: .storageRecordAuth,
                payload: wrapper2
            )
        )
        let record2 = try F.verifyStoredRecord(
            bodyBytes: terminalBody,
            wrapperBytes: wrapper2,
            authenticationTag: wrapper2Tag,
            key: key,
            predecessor: .record(record1)
        )
        var pointer2Fields = pointer1Fields
        pointer2Fields["authority_generation"] = u(2)
        pointer2Fields["authority_tip_record_index"] = u(2)
        pointer2Fields["authority_tip_record_kind"] = u(6)
        pointer2Fields["authority_tip_record_commitment"] = .bytes(terminalCommitment)
        pointer2Fields["authority_tip_record_auth_tag"] = .bytes(wrapper2Tag)
        pointer2Fields["lifecycle_code"] = u(5)
        let pointer2 = try F.encode(pointer2Fields, as: .authorityPointer)
        let pointer2Tag = try F.authorityPointerAuthenticationCode(
            key: key,
            pointer: pointer2
        )
        XCTAssertEqual(
            pointer2Tag,
            independentAuthenticationCode(
                key: key,
                domain: .authorityPointerAuth,
                payload: pointer2
            )
        )
        let state2 = try F.verifyAuthorityPointer(
            pointerBytes: pointer2,
            authenticationTag: pointer2Tag,
            key: key,
            tip: record2,
            prior: state1,
            context: context
        )
        XCTAssertEqual(
            state2.pointerCommitment.bytes,
            independentCommitment(domain: .authorityPointer, payload: pointer2)
        )

        var migrationFields = try validFields(
            for: .migrationAuthorization,
            maximum: false
        )
        migrationFields["old_verifier_id"] = .bytes(context.verifierID.bytes)
        migrationFields["old_verifier_public_key"] =
            .bytes(context.verifierPublicKey.bytes)
        migrationFields["old_trusted_genesis_commitment"] =
            .bytes(context.trustedGenesisCommitment.bytes)
        migrationFields["old_terminal_migration_record_commitment"] =
            .bytes(record2.bodyCommitment.bytes)
        migrationFields["old_terminal_record_index"] = u(record2.index)
        migrationFields["old_accepted_sequence"] = u(eligible.sequence)
        migrationFields["old_accepted_lineage_state_commitment"] =
            .bytes(eligible.lineageStateCommitment.bytes)
        migrationFields["new_verifier_id"] = .bytes(newContext.verifierID.bytes)
        migrationFields["new_genesis_intent_commitment"] =
            .bytes(newContext.trustedGenesisCommitment.bytes)
        migrationFields["migration_nonce"] = .bytes(migrationNonce)
        let migration = try F.encode(migrationFields, as: .migrationAuthorization)
        XCTAssertEqual(migration.count, 751)
        XCTAssertEqual(
            Data(SHA256.hash(data: migration)),
            hex("1bdb43d806bf08349979787c40ceb18bbf786f184047e90b35cf54b84a5e16b4")
        )
        XCTAssertEqual(
            Data(SHA256.hash(data: independentFrame(
                domain: .migrationSignature,
                payload: migration
            ))),
            hex("7c7be8595ab01213f7bb158a8cf98c3868b896541805294f1dd3ca565f3ba28d")
        )
        let migrationSignature = hex(
            "f02102c75d188fe053e5a4129fa1c9f8db242aed6f8606f2ed820ddb63bb4e6d" +
            "bb37e2e0b719547784389f078c98abfe313c3b1431868c9dbd477fd06266de02"
        )
        XCTAssertTrue(try F.verify(
            signature: migrationSignature,
            publicKey: context.verifierPublicKey.bytes,
            domain: .migrationSignature,
            payload: migration
        ))
        let migrationCommitment = independentCommitment(
            domain: .migrationBody,
            payload: migration
        )
        XCTAssertEqual(
            migrationCommitment,
            hex("53207e5f88b6801621862363d5a46abe81558bc38cc9f24a2674e7454c9673ab")
        )
        var migrationEnvelopeFields = try validFields(
            for: .verifierSignatureEnvelope,
            maximum: false
        )
        migrationEnvelopeFields["signed_body_kind"] = u(3)
        migrationEnvelopeFields["verifier_key_id"] = .bytes(context.verifierID.bytes)
        migrationEnvelopeFields["signed_body_commitment"] = .bytes(migrationCommitment)
        migrationEnvelopeFields["signed_body_byte_count"] = u(UInt64(migration.count))
        migrationEnvelopeFields["signature"] = .bytes(migrationSignature)
        let migrationEnvelope = try F.encode(
            migrationEnvelopeFields,
            as: .verifierSignatureEnvelope
        )
        let verifiedMigration = try F.verifyMigrationAuthorization(
            bodyBytes: migration,
            envelopeBytes: migrationEnvelope,
            oldContext: context,
            oldTerminalState: state2,
            newContext: newContext
        )
        XCTAssertEqual(verifiedMigration.bodyCommitment.bytes, migrationCommitment)
        XCTAssertEqual(
            verifiedMigration.envelopeCommitment.bytes,
            independentCommitment(domain: .verifierEnvelope, payload: migrationEnvelope)
        )
        XCTAssertThrowsError(try F.verifyMigrationAuthorization(
            bodyBytes: migration,
            envelopeBytes: migrationEnvelope,
            oldContext: newContext,
            oldTerminalState: state2,
            newContext: newContext
        ))
        var otherNewGenesisFields = newGenesisFields
        otherNewGenesisFields["migration_nonce"] = b32(0x78)
        let otherNewGenesis = try F.encode(
            otherNewGenesisFields,
            as: .genesisMigrationIntent
        )
        let otherNewContext = try F.makeProvisionedContext(
            disclosureModeTable: context.disclosureModeTable.bytes,
            policy: context.policy.bytes,
            trustedGenesis: otherNewGenesis
        )
        XCTAssertThrowsError(try F.verifyMigrationAuthorization(
            bodyBytes: migration,
            envelopeBytes: migrationEnvelope,
            oldContext: context,
            oldTerminalState: state2,
            newContext: otherNewContext
        ))

        var terminalReceiptFields = try validFields(for: .receiptTerminal, maximum: true)
        terminalReceiptFields["verifier_id"] = .bytes(context.verifierID.bytes)
        terminalReceiptFields["verifier_key_id"] = .bytes(context.verifierID.bytes)
        terminalReceiptFields["policy_commitment"] =
            .bytes(context.policyCommitment.bytes)
        terminalReceiptFields["terminal_request_commitment"] =
            .bytes(terminalRequestCommitment)
        terminalReceiptFields["result_record_commitment"] =
            .bytes(state2.tip.bodyCommitment.bytes)
        let terminalReceipt = try F.encode(
            terminalReceiptFields,
            as: .receiptTerminal
        )
        XCTAssertEqual(terminalReceipt.count, 520)
        XCTAssertEqual(
            Data(SHA256.hash(data: terminalReceipt)),
            hex("90a5b7dd18eeaff9aff84c11c09beada23b8d3fcfb1c95b5678623afb8ce2fed")
        )
        XCTAssertEqual(
            Data(SHA256.hash(data: independentFrame(
                domain: .receiptSignature,
                payload: terminalReceipt
            ))),
            hex("138f7d5a50ed18c4eb98185e9aa27c09891bcb67c03103c851aebf8d27777a26")
        )
        let terminalReceiptSignature = hex(
            "db5f83ae879c86044c407c9c686c177081c5d9065abeb55bb68b61a5288c2036" +
            "9816176e21235286fff440f4ffbb42f40d93d1e627b58654a6bf6b6fe506e404"
        )
        XCTAssertTrue(try F.verify(
            signature: terminalReceiptSignature,
            publicKey: context.verifierPublicKey.bytes,
            domain: .receiptSignature,
            payload: terminalReceipt
        ))
        let terminalReceiptCommitment = independentCommitment(
            domain: .receiptTerminal,
            payload: terminalReceipt
        )
        XCTAssertEqual(
            terminalReceiptCommitment,
            hex("29afda39994ba27a96e23672105aabfc0ec4ebdaf82c732c66ac1f8a1910936b")
        )
        var terminalReceiptEnvelopeFields = try validFields(
            for: .verifierSignatureEnvelope,
            maximum: false
        )
        terminalReceiptEnvelopeFields["signed_body_kind"] = u(2)
        terminalReceiptEnvelopeFields["verifier_key_id"] = .bytes(context.verifierID.bytes)
        terminalReceiptEnvelopeFields["signed_body_commitment"] =
            .bytes(terminalReceiptCommitment)
        terminalReceiptEnvelopeFields["signed_body_byte_count"] =
            u(UInt64(terminalReceipt.count))
        terminalReceiptEnvelopeFields["signature"] = .bytes(terminalReceiptSignature)
        let terminalReceiptEnvelope = try F.encode(
            terminalReceiptEnvelopeFields,
            as: .verifierSignatureEnvelope
        )
        let verifiedTerminalReceipt = try F.verifyTerminalReceipt(
            bodyBytes: terminalReceipt,
            envelopeBytes: terminalReceiptEnvelope,
            context: context,
            expectedRequest: try F.Fixed32(terminalRequestCommitment),
            currentState: state2
        )
        XCTAssertEqual(
            verifiedTerminalReceipt.bodyCommitment.bytes,
            terminalReceiptCommitment
        )
        XCTAssertEqual(
            verifiedTerminalReceipt.envelopeCommitment.bytes,
            independentCommitment(
                domain: .verifierEnvelope,
                payload: terminalReceiptEnvelope
            )
        )
        XCTAssertThrowsError(try F.verifyAssertionReceipt(
            bodyBytes: terminalReceipt,
            envelopeBytes: terminalReceiptEnvelope,
            context: context,
            expectedChallenge: eligible.binding.challenge.bodyCommitment,
            expectedRequest: eligible.binding.requestCommitment
        )) {
            XCTAssertEqual($0 as? F.Failure, .unsupported)
        }

        let newPredecessor = try F.fixedPredecessor(
            trustedGenesisCommitment: newContext.trustedGenesisCommitment.bytes
        )
        XCTAssertEqual(
            newPredecessor,
            independentCommitment(
                domain: .fixedPredecessor,
                payload: newContext.trustedGenesisCommitment.bytes
            )
        )
        var migratedFields = try validFields(
            for: .uninitializedRecord,
            maximum: false
        )
        migratedFields["trusted_genesis_body"] = .bytes(newContext.trustedGenesis.bytes)
        migratedFields["trusted_genesis_commitment"] =
            .bytes(newContext.trustedGenesisCommitment.bytes)
        migratedFields["policy_body"] = .bytes(newContext.policy.bytes)
        migratedFields["policy_commitment"] = .bytes(newContext.policyCommitment.bytes)
        migratedFields["verifier_id"] = .bytes(newContext.verifierID.bytes)
        migratedFields["lineage_id"] = .bytes(newContext.lineageID.bytes)
        migratedFields["epoch_id"] = .bytes(newContext.epochID.bytes)
        for field in [
            "previous_authority_tip_commitment", "fixed_predecessor",
            "accepted_record_commitment", "accepted_lineage_state_commitment",
        ] {
            migratedFields[field] = .bytes(newPredecessor)
        }
        migratedFields["migration_binding_present"] = .bool(true)
        migratedFields["migration_authorization_envelope_commitment"] =
            .bytes(verifiedMigration.envelopeCommitment.bytes)
        let migratedBody = try F.encode(migratedFields, as: .uninitializedRecord)
        let migratedCommitment = independentCommitment(
            domain: .uninitializedRecord,
            payload: migratedBody
        )
        XCTAssertEqual(
            try F.commitment(domain: .uninitializedRecord, payload: migratedBody),
            migratedCommitment
        )
        let migratedGenesisTag = independentAuthenticationCode(
            key: migratedStorageKey,
            domain: .storageGenesisTag,
            payload: newContext.trustedGenesisCommitment.bytes
        )
        XCTAssertEqual(
            try F.storageGenesisTag(
                key: migratedStorageKey,
                trustedGenesisCommitment: newContext.trustedGenesisCommitment.bytes
            ),
            migratedGenesisTag
        )
        var migratedWrapperFields = try validFields(
            for: .storageRecordWrapper,
            maximum: false
        )
        migratedWrapperFields["previous_record_auth_tag"] = .bytes(migratedGenesisTag)
        migratedWrapperFields["record_body_commitment"] = .bytes(migratedCommitment)
        migratedWrapperFields["record_body_byte_count"] = u(UInt64(migratedBody.count))
        let migratedWrapper = try F.encode(
            migratedWrapperFields,
            as: .storageRecordWrapper
        )
        let migratedWrapperTag = independentAuthenticationCode(
            key: migratedStorageKey,
            domain: .storageRecordAuth,
            payload: migratedWrapper
        )
        XCTAssertEqual(
            try F.storageRecordAuthenticationCode(
                key: migratedStorageKey,
                wrapper: migratedWrapper
            ),
            migratedWrapperTag
        )
        let migratedRecord = try F.verifyMigratedUninitializedRecord(
            bodyBytes: migratedBody,
            wrapperBytes: migratedWrapper,
            authenticationTag: migratedWrapperTag,
            key: migratedStorageKey,
            context: newContext,
            authorization: verifiedMigration
        )
        var migratedPointerFields = try validFields(
            for: .authorityPointer,
            maximum: false
        )
        migratedPointerFields["trusted_genesis_commitment"] =
            .bytes(newContext.trustedGenesisCommitment.bytes)
        migratedPointerFields["policy_commitment"] =
            .bytes(newContext.policyCommitment.bytes)
        migratedPointerFields["lineage_id"] = .bytes(newContext.lineageID.bytes)
        migratedPointerFields["epoch_id"] = .bytes(newContext.epochID.bytes)
        migratedPointerFields["authority_tip_record_commitment"] =
            .bytes(migratedRecord.bodyCommitment.bytes)
        migratedPointerFields["authority_tip_record_auth_tag"] =
            .bytes(migratedRecord.authenticationTag.bytes)
        migratedPointerFields["accepted_record_or_fixed_predecessor"] =
            .bytes(newPredecessor)
        migratedPointerFields["accepted_lineage_state_or_fixed_predecessor"] =
            .bytes(newPredecessor)
        let migratedPointer = try F.encode(
            migratedPointerFields,
            as: .authorityPointer
        )
        let migratedPointerTag = independentAuthenticationCode(
            key: migratedStorageKey,
            domain: .authorityPointerAuth,
            payload: migratedPointer
        )
        XCTAssertEqual(
            try F.authorityPointerAuthenticationCode(
                key: migratedStorageKey,
                pointer: migratedPointer
            ),
            migratedPointerTag
        )
        let migratedState = try F.verifyAuthorityPointer(
            pointerBytes: migratedPointer,
            authenticationTag: migratedPointerTag,
            key: migratedStorageKey,
            tip: migratedRecord,
            prior: nil,
            context: newContext
        )
        XCTAssertEqual(
            migratedState.pointerCommitment.bytes,
            independentCommitment(domain: .authorityPointer, payload: migratedPointer)
        )

        var wrongBindingFields = migratedFields
        wrongBindingFields["migration_authorization_envelope_commitment"] = b32(0xee)
        let wrongBindingBody = try F.encode(
            wrongBindingFields,
            as: .uninitializedRecord
        )
        let wrongBindingCommitment = independentCommitment(
            domain: .uninitializedRecord,
            payload: wrongBindingBody
        )
        var wrongBindingWrapperFields = migratedWrapperFields
        wrongBindingWrapperFields["record_body_commitment"] =
            .bytes(wrongBindingCommitment)
        wrongBindingWrapperFields["record_body_byte_count"] =
            u(UInt64(wrongBindingBody.count))
        let wrongBindingWrapper = try F.encode(
            wrongBindingWrapperFields,
            as: .storageRecordWrapper
        )
        let wrongBindingTag = independentAuthenticationCode(
            key: migratedStorageKey,
            domain: .storageRecordAuth,
            payload: wrongBindingWrapper
        )
        XCTAssertNoThrow(try F.verifyStoredRecord(
            bodyBytes: wrongBindingBody,
            wrapperBytes: wrongBindingWrapper,
            authenticationTag: wrongBindingTag,
            key: migratedStorageKey,
            predecessor: .genesis(newContext)
        ))
        XCTAssertThrowsError(try F.verifyMigratedUninitializedRecord(
            bodyBytes: wrongBindingBody,
            wrapperBytes: wrongBindingWrapper,
            authenticationTag: wrongBindingTag,
            key: migratedStorageKey,
            context: newContext,
            authorization: verifiedMigration
        )) {
            XCTAssertEqual($0 as? F.Failure, .crossField)
        }
    }
}
