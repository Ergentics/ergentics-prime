import Foundation

enum DisposalR19OBS11ReceiptKind: String, Sendable {
    case start = "START"
    case stepIntent = "STEP_INTENT"
    case stepResult = "STEP_RESULT"
    case terminalSuccess = "TERMINAL_SUCCESS"
    case terminalFailure = "TERMINAL_FAILURE"
}

struct DisposalR19OBS11ReceiptFrame: Equatable, Sendable {
    let chainOrdinal: Int
    let leafName: String
    let payload: Data
    let payloadSHA256: String
    let previousFrameWithLFSHA256: String?
    let bytesWithoutLF: Data
    let bytesWithLF: Data
    let frameSHA256: String
    let frameWithLFSHA256: String
}

enum DisposalR19OBS11ReceiptCodec {
    static let schema = "ergentics_r19_obs11_chain_receipt_frame_v1"
    static let payloadHashRule =
        "SHA256_CANONICAL_RFC8259_EXACT_NUMBER_LEXEMES_NO_TRAILING_LF"

    static func make(
        chainOrdinal: Int,
        leafName: String,
        previousFrameWithLFSHA256: String?,
        payloadMembers: [String: DisposalJSONValue]
    ) throws -> DisposalR19OBS11ReceiptFrame {
        try disposalRequireProjection(chainOrdinal >= 0, "OBS11_RECEIPT_ORDINAL")
        try disposalRequireProjection(
            leafName == DisposalR19OBS11FrozenPlan.terminalLeaf
                ? (1...DisposalR19OBS11FrozenPlan.ordinaryLeaves.count).contains(chainOrdinal)
                : DisposalR19OBS11FrozenPlan.ordinaryLeaves.indices.contains(chainOrdinal) &&
                    DisposalR19OBS11FrozenPlan.ordinaryLeaves[chainOrdinal] == leafName,
            "OBS11_RECEIPT_LEAF_ORDINAL_JOIN")
        try disposalRequireProjection(
            chainOrdinal == 0
                ? previousFrameWithLFSHA256 == nil
                : previousFrameWithLFSHA256.map {
                    disposalIsLowerHex($0, count: 64)
                } == true,
            "OBS11_RECEIPT_PREVIOUS_SHAPE")

        let payload = disposalCanonicalObject(payloadMembers)
        let payloadSHA256 = disposalSHA256(payload)
        var parser = DisposalCanonicalJSONParser(
            data: payload,
            frameOrdinal: chainOrdinal,
            journalByteOffset: 0)
        let payloadValue = try parser.parse()
        try disposalRequireProjection(
            payloadValue.canonicalData() == payload,
            "OBS11_RECEIPT_PAYLOAD_CANONICAL")

        let frame = disposalCanonicalObject([
            "chain_ordinal": disposalJSONNumber(chainOrdinal),
            "payload": payloadValue,
            "payload_hash_rule": disposalJSONString(payloadHashRule),
            "payload_sha256": disposalJSONString(payloadSHA256),
            "previous_frame_with_lf_sha256": disposalJSONOptionalString(
                previousFrameWithLFSHA256),
            "receipt_leaf_name": disposalJSONString(leafName),
            "schema": disposalJSONString(schema),
        ])
        var frameWithLF = frame
        frameWithLF.append(0x0a)
        return .init(
            chainOrdinal: chainOrdinal,
            leafName: leafName,
            payload: payload,
            payloadSHA256: payloadSHA256,
            previousFrameWithLFSHA256: previousFrameWithLFSHA256,
            bytesWithoutLF: frame,
            bytesWithLF: frameWithLF,
            frameSHA256: disposalSHA256(frame),
            frameWithLFSHA256: disposalSHA256(frameWithLF))
    }

    static func validateExact(
        frameWithLF: Data,
        chainOrdinal: Int,
        leafName: String,
        previousFrameWithLFSHA256: String?
    ) throws -> String {
        try disposalRequireProjection(
            !frameWithLF.isEmpty && frameWithLF.last == 0x0a &&
                !frameWithLF.dropLast().contains(0x0a),
            "OBS11_RECEIPT_FRAME_SHAPE")
        let body = Data(frameWithLF.dropLast())
        var parser = DisposalCanonicalJSONParser(
            data: body,
            frameOrdinal: chainOrdinal,
            journalByteOffset: 0)
        let root = try parser.parse()
        try disposalRequireProjection(
            root.canonicalData() == body,
            "OBS11_RECEIPT_FRAME_CANONICAL")
        guard case .object(let members, _) = root else {
            throw DisposalProjectionRejection(code: "OBS11_RECEIPT_FRAME_OBJECT")
        }
        let values = Dictionary(uniqueKeysWithValues: members.map { ($0.key, $0.value) })
        try disposalRequireProjection(
            Set(values.keys) == Set([
                "chain_ordinal", "payload", "payload_hash_rule", "payload_sha256",
                "previous_frame_with_lf_sha256", "receipt_leaf_name", "schema",
            ]),
            "OBS11_RECEIPT_FRAME_KEYS")
        try disposalRequireProjection(
            values["chain_ordinal"]?.numberLexeme() == String(chainOrdinal) &&
                values["receipt_leaf_name"]?.stringValue() == leafName &&
                values["schema"]?.stringValue() == schema &&
                values["payload_hash_rule"]?.stringValue() == payloadHashRule,
            "OBS11_RECEIPT_FRAME_IDENTITY")
        let observedPrevious: String?
        switch values["previous_frame_with_lf_sha256"] {
        case .some(.null(_)): observedPrevious = nil
        case .some(.string(let value, _)): observedPrevious = value
        default:
            throw DisposalProjectionRejection(code: "OBS11_RECEIPT_PREVIOUS_TYPE")
        }
        try disposalRequireProjection(
            observedPrevious == previousFrameWithLFSHA256 &&
                (observedPrevious.map { disposalIsLowerHex($0, count: 64) } ?? true),
            "OBS11_RECEIPT_PREVIOUS_JOIN")
        guard let payload = values["payload"] else {
            throw DisposalProjectionRejection(code: "OBS11_RECEIPT_PAYLOAD_ABSENT")
        }
        let payloadBytes = payload.canonicalData()
        try disposalRequireProjection(
            values["payload_sha256"]?.stringValue() == disposalSHA256(payloadBytes),
            "OBS11_RECEIPT_PAYLOAD_SHA256")
        try validateFrozenPayloadPolicy(payload, leafName: leafName, chainOrdinal: chainOrdinal)
        return disposalSHA256(frameWithLF)
    }

    private static func validateFrozenPayloadPolicy(
        _ payload: DisposalJSONValue,
        leafName: String,
        chainOrdinal: Int
    ) throws {
        let expectedKinds: Set<String>
        if leafName == DisposalR19OBS11FrozenPlan.terminalLeaf {
            try disposalRequireProjection(
                (1...DisposalR19OBS11FrozenPlan.ordinaryLeaves.count).contains(chainOrdinal),
                "OBS11_RECEIPT_TERMINAL_ORDINAL")
            expectedKinds = chainOrdinal == DisposalR19OBS11FrozenPlan.ordinaryLeaves.count
                ? [
                    DisposalR19OBS11ReceiptKind.terminalSuccess.rawValue,
                    DisposalR19OBS11ReceiptKind.terminalFailure.rawValue,
                ]
                : [DisposalR19OBS11ReceiptKind.terminalFailure.rawValue]
        } else if chainOrdinal == 0 {
            expectedKinds = [DisposalR19OBS11ReceiptKind.start.rawValue]
        } else if chainOrdinal.isMultiple(of: 2) {
            expectedKinds = [DisposalR19OBS11ReceiptKind.stepResult.rawValue]
        } else {
            expectedKinds = [DisposalR19OBS11ReceiptKind.stepIntent.rawValue]
        }
        let receiptKind = payload.member("receipt_kind")?.stringValue()
        try disposalRequireProjection(
            payload.member("authority_vector")?.stringValue() == "00000000" &&
                payload.member("authoritative")?.booleanValue() == false &&
                payload.member("may_feed_controller")?.booleanValue() == false &&
                payload.member("prose_may_supply_fact")?.booleanValue() == false &&
                payload.member("gate_e")?.stringValue() == "ABSTAIN" &&
                payload.member("scientific_outcome")?.stringValue() == "ABSTAIN" &&
                payload.member("checkpoint_id")?.stringValue() ==
                    DisposalR19OBS11FrozenPlan.checkpointID &&
                payload.member("c0_sha256")?.stringValue() ==
                    DisposalR19OBS11FrozenPlan.c0SHA256 &&
                payload.member("c0_blob")?.stringValue() ==
                    DisposalR19OBS11FrozenPlan.c0Blob &&
                payload.member("chain_id")?.stringValue() ==
                    DisposalR19OBS11FrozenPlan.chainID &&
                receiptKind.map {
                    expectedKinds.contains($0)
                } == true,
            "OBS11_RECEIPT_PAYLOAD_POLICY")
        if receiptKind == DisposalR19OBS11ReceiptKind.stepResult.rawValue {
            let step = chainOrdinal / 2
            try disposalRequireProjection(
                chainOrdinal >= 2 && chainOrdinal.isMultiple(of: 2) &&
                    payload.member("step")?.numberLexeme() == String(step) &&
                    payload.member("machine_prefix_join")?.stringValue() == (step == 1
                        ? "NOT_APPLICABLE_GENESIS_NO_PREDECESSOR"
                        : "PASS_EXACT"),
                "OBS11_RECEIPT_RESULT_MACHINE_PREFIX_POLICY")
        }
        if receiptKind == DisposalR19OBS11ReceiptKind.terminalFailure.rawValue {
            let origin = payload.member("current_namespace_origin_proof")?.stringValue()
            let snapshotValue = payload.member("current_namespace_snapshot_sha256")
            let componentsValue = payload.member("current_namespace_snapshot_components")
            let snapshot: String?
            let snapshotWasNull: Bool
            let components: [String]?
            let componentsWereNull: Bool
            switch snapshotValue {
            case .some(.null(_)):
                snapshot = nil
                snapshotWasNull = true
            case .some(.string(let value, _)):
                snapshot = value
                snapshotWasNull = false
            default:
                throw DisposalProjectionRejection(
                    code: "OBS11_RECEIPT_FAILURE_NAMESPACE_SNAPSHOT_TYPE")
            }
            switch componentsValue {
            case .some(.null(_)):
                components = nil
                componentsWereNull = true
            case .some(.array(let values, _)):
                let strings = values.compactMap { $0.stringValue() }
                try disposalRequireProjection(
                    strings.count == values.count && !strings.isEmpty &&
                        strings.count <= 80 &&
                        strings.allSatisfy { $0.utf8.count <= 1_024 } &&
                        strings.reduce(0) { $0 + $1.utf8.count } <= 32_768,
                    "OBS11_RECEIPT_FAILURE_NAMESPACE_COMPONENTS_SHAPE")
                components = strings
                componentsWereNull = false
            default:
                throw DisposalProjectionRejection(
                    code: "OBS11_RECEIPT_FAILURE_NAMESPACE_COMPONENTS_TYPE")
            }
            let permittedOrigins = [
                "NOT_APPLICABLE_NO_CURRENT_STEP",
                "ABSENT_BOTH_NAMES_DESCRIPTOR_REVALIDATED",
                "BUILDER_PREPARED_DURABLE_NAMESPACE_DESCRIPTOR_JOIN",
            ]
            try disposalRequireProjection(
                origin.map { permittedOrigins.contains($0) } == true &&
                    (origin == "NOT_APPLICABLE_NO_CURRENT_STEP"
                        ? snapshotWasNull && componentsWereNull
                        : snapshot.map { disposalIsLowerHex($0, count: 64) } == true &&
                            components?.dropFirst(3).first == origin &&
                            components.map {
                                disposalLengthFramedID(
                                    "ergentics-r19-obs11-retained-namespace-snapshot-v1",
                                    $0)
                            } == snapshot),
                "OBS11_RECEIPT_FAILURE_NAMESPACE_POLICY")
        }
    }
}

enum DisposalR19OBS11ReceiptMerkle {
    static let chainDomain = "ERGENTICS_R19_OBS11_RECEIPT_CHAIN_V1"
    static let leafDomain = "ergentics-r19-obs11-receipt-merkle-leaf-v1"
    static let nodeDomain = "ergentics-r19-obs11-receipt-merkle-node-v1"

    static func root(resultFrameWithLFSHA256 digests: [String]) throws -> String {
        try disposalRequireProjection(digests.count == 8, "OBS11_MERKLE_LEAF_COUNT")
        try disposalRequireProjection(
            digests.allSatisfy { disposalIsLowerHex($0, count: 64) },
            "OBS11_MERKLE_LEAF_SHAPE")
        let leaves = digests.enumerated().map { index, digest in
            disposalLengthFramedID(
                leafDomain,
                [chainDomain, String(index + 1), digest])
        }
        return try subtreeRoot(leaves)
    }

    private static func subtreeRoot(_ hashes: [String]) throws -> String {
        try disposalRequireProjection(!hashes.isEmpty, "OBS11_MERKLE_EMPTY")
        if hashes.count == 1 { return hashes[0] }
        let split = largestPowerOfTwoLessThan(hashes.count)
        let left = try subtreeRoot(Array(hashes[..<split]))
        let right = try subtreeRoot(Array(hashes[split...]))
        return disposalLengthFramedID(nodeDomain, [chainDomain, left, right])
    }

    private static func largestPowerOfTwoLessThan(_ count: Int) -> Int {
        precondition(count > 1)
        var power = 1
        while power * 2 < count { power *= 2 }
        return power
    }
}

func disposalR19OBS11JSONArray(_ values: [DisposalJSONValue]) -> DisposalJSONValue {
    .array(values, disposalZeroSpan)
}

func disposalR19OBS11JSONObject(
    _ members: [String: DisposalJSONValue]
) -> DisposalJSONValue {
    .object(
        members.map { DisposalJSONObjectMember(key: $0.key, value: $0.value) },
        disposalZeroSpan)
}

func disposalR19OBS11JSONUInt64(_ value: UInt64) -> DisposalJSONValue {
    .number(String(value), disposalZeroSpan)
}
