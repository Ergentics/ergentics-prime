import Foundation

struct DisposalTypedMissingEvidence: Sendable {
    let evidenceKind: String
    let targetRole: String?
    let sourceFrameID: String?
    let reasonCode: String
}

struct DisposalTypedEvidenceInsertion: Sendable {
    let ids: DisposalTypedEvidenceIDs
    let guardianConservationID: String?
    let fixtureConservationID: String?
    let missingEvidence: [DisposalTypedMissingEvidence]
}

enum DisposalTypedProcessEvidence {
    static func insert(
        database: DisposalSQLiteConnection,
        journal: DisposalDecodedJournal,
        invocationID: String,
        epochLabel: String,
        adapterManifestSHA256: String,
        frameIDs: [String]
    ) throws -> DisposalTypedEvidenceInsertion {
        let extractor = Extractor(
            database: database,
            journal: journal,
            invocationID: invocationID,
            epochLabel: epochLabel,
            adapterManifestSHA256: adapterManifestSHA256,
            frameIDs: frameIDs)
        return try extractor.run()
    }
}

private final class Extractor {
    private struct TargetContext {
        let id: String
        let role: String
        let label: String
        let pid: Int
        let targetForm: String
        let uniqueID: UInt64?
        let idVersion: UInt64?
        let sid: Int?
        let pgid: Int?
    }

    private struct PairContext {
        let id: String
        let certificateSHA256: String
    }

    private struct CommitmentContext {
        let id: String
        let target: TargetContext
        let numericArgument: Int
        let signalNumber: Int
        let operation: String
        let budgetOrdinal: Int
        let sourceOrdinal: Int
        let sourceFrameID: String
        let sourceFrameLFSHA256: String
        let obligationKeySHA256: String
    }

    private struct ConservationSetMembershipContext {
        let id: String
        let obligationKeySHA256: String
        let obligationCommitmentID: String
        let target: TargetContext
    }

    private struct ConservationSetContext {
        let id: String
        let sourceOrdinal: Int
        let sourceFrameLFSHA256: String
        let scopeKind: String
        let scopeID: String
        let witnessRootSHA256: String
        let leafCount: Int
        let membershipsByObligationKey: [String: ConservationSetMembershipContext]
    }

    private let database: DisposalSQLiteConnection
    private let journal: DisposalDecodedJournal
    private let invocationID: String
    private let epochLabel: String
    private let adapterManifestSHA256: String
    private let frameIDs: [String]
    private var targets: [String: TargetContext] = [:]
    private var prestatePairs: [String: PairContext] = [:]
    private var commitmentsByID: [String: CommitmentContext] = [:]
    private var latestCommitmentByLabel: [String: CommitmentContext] = [:]
    private var conservationSet: ConservationSetContext?
    private var guardianConservationID: String?
    private var fixtureConservationID: String?
    private var missingEvidence: [DisposalTypedMissingEvidence] = []

    private var targetIDs: [String] = []
    private var frameAdapterCoverageIDs: [String] = []
    private var processReceiptIDs: [String] = []
    private var vnodeJoinIDs: [String] = []
    private var domainSnapshotIDs: [String] = []
    private var targetSnapshotIDs: [String] = []
    private var snapshotPairIDs: [String] = []
    private var namespaceObservationIDs: [String] = []
    private var commitmentIDs: [String] = []
    private var signalCallIDs: [String] = []
    private var signalZeroCallIDs: [String] = []
    private var waitCallIDs: [String] = []
    private var reapIDs: [String] = []
    private var absenceProofIDs: [String] = []
    private var conservationIDs: [String] = []
    private var conservationSetCommitmentIDs: [String] = []
    private var conservationSetMembershipIDs: [String] = []
    private var conservationSetMappingIDs: [String] = []

    init(
        database: DisposalSQLiteConnection,
        journal: DisposalDecodedJournal,
        invocationID: String,
        epochLabel: String,
        adapterManifestSHA256: String,
        frameIDs: [String]
    ) {
        self.database = database
        self.journal = journal
        self.invocationID = invocationID
        self.epochLabel = epochLabel
        self.adapterManifestSHA256 = adapterManifestSHA256
        self.frameIDs = frameIDs
    }

    func run() throws -> DisposalTypedEvidenceInsertion {
        try validateAdapterManifestInventory()
        for frame in journal.frames {
            let schema = try frame.optionalString(at: "/payload/schema")
            let coverage = adapterCoverage(schema: schema, eventType: frame.eventType)
            try insertAdapterCoverage(
                frame: frame,
                schema: schema ?? "ABSENT",
                state: coverage.state,
                scope: coverage.scope)
            if coverage.state == "UNKNOWN_RAW_ONLY" && coverage.scope == "LIFECYCLE" {
                missingEvidence.append(.init(
                    evidenceKind: "UNKNOWN_TYPED_PAYLOAD_SCHEMA",
                    targetRole: frame.targetLabel,
                    sourceFrameID: frameIDs[frame.ordinal],
                    reasonCode: "SCHEMA_NOT_IN_FROZEN_TYPED_ADAPTER:" + (schema ?? "ABSENT")))
            }
            guard let schema else { continue }
            switch schema {
            case "prime-driver-v2-r19-coordinated-disposal-start/v1":
                try requireEvent(frame, .start, schema)
                try insertR19Start(frame)
            case "prime-driver-v2-r19-coordinated-disposal-prestate/v1":
                try requireEvent(frame, .snapshot, schema)
                try insertR19GuardianPrestate(frame)
            case "prime-driver-v2-r19-fixture-prestate/v1":
                try requireEvent(frame, .snapshot, schema)
                try insertR19FixturePrestate(frame)
            case "prime-driver-v2-r19-kill-commitment/v1":
                try requireEvent(frame, .commitment, schema)
                try insertR19Commitment(frame)
            case "prime-driver-v2-r19-kill-result/v1":
                try requireEvent(frame, .signalCall, schema)
                try insertR19SignalResult(frame)
            case DisposalConservationSetMerkle.schema:
                try requireEvent(frame, .commitment, schema)
                try insertConservationSetCommitment(frame)
            case "prime-driver-v2-r19-guardian-conservation/v1":
                try requireEvent(frame, .conservation, schema)
                guardianConservationID = try insertR19Conservation(frame, label: "guardian")
            case "prime-driver-v2-r19-fixture-conservation/v1":
                try requireEvent(frame, .conservation, schema)
                fixtureConservationID = try insertR19Conservation(frame, label: "fixture")
            case "prime_driver_v2_r19_observability_frame_v1":
                try requireEvent(frame, .resource, schema)
                try insertObservabilityFrame(frame)
            case "prime_driver_v2_r19_process_energy_observation_v1":
                try requireEvent(frame, .resource, schema)
                try insertDirectObservabilityFrame(frame)
            case "prime-driver-v2-r18-process-actuation-canary/v1":
                try requireEvent(frame, .terminal, schema)
                try insertR18Terminal(frame)
            case "prime-driver-v2-r19-coordinated-disposal/v1",
                 "prime_driver_v2_r19_observability_session_v1",
                 "prime_driver_v2_r19_observability_seal_v1",
                 "prime_driver_v2_r19_observability_cpu_overlay_frame_v1",
                 "prime_driver_v2_r19_observability_cpu_overlay_interval_v1":
                // These known schemas carry terminal or derived presentation facts,
                // but no additional process row is representable without inference.
                let expected: DisposalEventType = schema == "prime-driver-v2-r19-coordinated-disposal/v1"
                    ? .terminal : .resource
                try requireEvent(frame, expected, schema)
                continue
            default:
                // Frozen adapter rule: coverage and exact raw nodes are retained;
                // operational uncertainty was anchored above at this frame.
                continue
            }
        }
        return .init(
            ids: .init(
                frameAdapterCoverageIDs: frameAdapterCoverageIDs.sorted(),
                targetIDs: targetIDs.sorted(),
                processReceiptIDs: processReceiptIDs.sorted(),
                vnodeJoinIDs: vnodeJoinIDs.sorted(),
                domainSnapshotIDs: domainSnapshotIDs.sorted(),
                targetSnapshotIDs: targetSnapshotIDs.sorted(),
                snapshotPairIDs: snapshotPairIDs.sorted(),
                namespaceObservationIDs: namespaceObservationIDs.sorted(),
                commitmentIDs: commitmentIDs.sorted(),
                signalCallIDs: signalCallIDs.sorted(),
                signalZeroCallIDs: signalZeroCallIDs.sorted(),
                waitCallIDs: waitCallIDs.sorted(),
                reapIDs: reapIDs.sorted(),
                absenceProofIDs: absenceProofIDs.sorted(),
                conservationIDs: conservationIDs.sorted(),
                conservationSetCommitmentIDs: conservationSetCommitmentIDs.sorted(),
                conservationSetMembershipIDs: conservationSetMembershipIDs.sorted(),
                conservationSetMappingIDs: conservationSetMappingIDs.sorted()),
            guardianConservationID: guardianConservationID,
            fixtureConservationID: fixtureConservationID,
            missingEvidence: missingEvidence)
    }

    private func adapterCoverage(
        schema: String?,
        eventType: DisposalEventType
    ) -> (state: String, scope: String) {
        let state: String
        if let schema, typedAdapterSchemas.contains(schema) {
            state = "KNOWN_TYPED"
        } else if let schema, knownNoProcessAdapterSchemas.contains(schema) {
            state = "KNOWN_NO_PROCESS_FACTS"
        } else {
            state = "UNKNOWN_RAW_ONLY"
        }
        let lifecycle: [DisposalEventType] = [
            .start, .snapshot, .commitment, .signalCall, .waitReap,
            .absence, .conservation, .terminal,
        ]
        return (state, lifecycle.contains(eventType) ? "LIFECYCLE" : "NON_LIFECYCLE")
    }

    private var typedAdapterSchemas: Set<String> {
        [
            "prime-driver-v2-r18-process-actuation-canary/v1",
            "prime-driver-v2-r19-coordinated-disposal-start/v1",
            "prime-driver-v2-r19-coordinated-disposal-prestate/v1",
            "prime-driver-v2-r19-fixture-prestate/v1",
            "prime-driver-v2-r19-kill-commitment/v1",
            "prime-driver-v2-r19-kill-result/v1",
            "prime-driver-v2-r19-guardian-conservation/v1",
            "prime-driver-v2-r19-fixture-conservation/v1",
            "prime_driver_v2_r19_observability_frame_v1",
            "prime_driver_v2_r19_process_energy_observation_v1",
            DisposalConservationSetMerkle.schema,
        ]
    }

    private var knownNoProcessAdapterSchemas: Set<String> {
        [
            "prime-driver-v2-r19-coordinated-disposal/v1",
            "prime_driver_v2_r19_observability_session_v1",
            "prime_driver_v2_r19_observability_seal_v1",
            "prime_driver_v2_r19_observability_cpu_overlay_frame_v1",
            "prime_driver_v2_r19_observability_cpu_overlay_interval_v1",
        ]
    }

    private func validateAdapterManifestInventory() throws {
        let bytes = try disposalResourceData("disposal-adapters.v1", extension: "json")
        try disposalRequireProjection(
            bytes.last == 0x0a && disposalSHA256(bytes) == adapterManifestSHA256,
            "TYPED_ADAPTER_MANIFEST_IDENTITY")
        var body = bytes
        body.removeLast()
        var parser = DisposalCanonicalJSONParser(
            data: body,
            frameOrdinal: 0,
            journalByteOffset: 0)
        let root = try parser.parse()
        try disposalRequireProjection(
            root.canonicalData() == body,
            "TYPED_ADAPTER_MANIFEST_CANONICAL")
        guard let merkle = root.member("conservation_set_merkle_rules"),
              case .object(let merkleMembers, _) = merkle
        else { throw DisposalProjectionRejection(code: "TYPED_ADAPTER_MERKLE_RULES") }
        let expectedMerkle: [String: String] = [
            "algorithm": DisposalConservationSetMerkle.algorithm,
            "domain_tag": DisposalConservationSetMerkle.domainTag,
            "domain_tag_binding": "FIRST_COMPONENT_OF_OBLIGATION_LEAF_NODE_PROOF_HASHES",
            "duplicate_policy": DisposalConservationSetMerkle.duplicatePolicy,
            "hash_encoding": "MAGIC_UTF8_DOMAIN_LENGTH_U64BE_DOMAIN_UTF8_COMPONENT_COUNT_U64BE_COMPONENT_LENGTH_U64BE_COMPONENT_UTF8",
            "hash_magic": "ERGENTICS_DISPOSAL_MERKLE_ID_V1",
            "leaf_domain": "disposal-conservation-set-leaf-v1",
            "leaf_ordering": DisposalConservationSetMerkle.leafOrdering,
            "membership_proof": "RFC6962_INCLUSION_PATH_EXPLICIT_SIBLING_POSITION",
            "node_domain": "disposal-conservation-set-node-v1",
            "obligation_key_domain": "disposal-conservation-obligation-key-v1",
            "odd_leaf_rule": DisposalConservationSetMerkle.oddLeafRule,
            "proof_domain": "disposal-conservation-set-proof-v1",
            "purpose": DisposalConservationSetMerkle.purpose,
            "scope_kind": DisposalConservationSetMerkle.scopeKind,
            "tree_shape": DisposalConservationSetMerkle.treeShape,
        ]
        try disposalRequireProjection(
            Set(merkleMembers.map(\.key)) == Set(expectedMerkle.keys) &&
                expectedMerkle.allSatisfy { merkle.member($0.key)?.stringValue() == $0.value },
            "TYPED_ADAPTER_MERKLE_CONTRACT")
        guard let sourceRules = root.member("source_decoder_rules"),
              case .object(let sourceRuleMembers, _) = sourceRules
        else { throw DisposalProjectionRejection(code: "TYPED_ADAPTER_SOURCE_RULES") }
        let expectedSourceRules: [String: String] = [
            "collapsed_evidence_certificate":
                "DOMAIN_SEPARATED_FRAME_LF_AVAILABILITY_PROCESS_MONOTONIC_BOUNDS",
            "cpu_derived_field_promotion": "RAW_JSON_ONLY_NOT_PROMOTED",
            "legacy_exact_outer_keys":
                "frame_kind,ordinal,payload,payload_hash_rule,payload_sha256," +
                "previous_frame_sha256,schema,session_id",
            "legacy_frame_schema": "prime_driver_v2_r19_observability_frame_v1",
            "legacy_hash_chain":
                "PREVIOUS_FRAME_SHA256_EQUALS_PRIOR_RAW_WITH_LF_SHA256",
            "legacy_payload_hash_rule":
                "SHA256_COMPACT_RECURSIVE_LEXICOGRAPHIC_KEYS_UTF8_NO_TRAILING_LF",
            "legacy_sequence":
                "SESSION_THEN_UP_TO_SIX_ROUND_ORDERED_SAMPLES_THEN_OPTIONAL_POSITION_7_SEAL",
            "legacy_session_join":
                "EVERY_FRAME_OUTER_SESSION_ID_EQUALS_ORDINAL_ZERO",
            "legacy_source_completion":
                "SEAL_MEANS_SOURCE_SEALED_NOT_DISPOSAL_TERMINAL",
            "promotion": "DIRECT_EXACT_BYTES_NO_SYNTHETIC_EVENTS",
        ]
        try disposalRequireProjection(
            Set(sourceRuleMembers.map(\.key)) == Set(expectedSourceRules.keys) &&
                expectedSourceRules.allSatisfy {
                    sourceRules.member($0.key)?.stringValue() == $0.value
                },
            "TYPED_ADAPTER_SOURCE_RULE_CONTRACT")
        guard let rules = root.member("decoder_rules"), case .array(let values, _) = rules else {
            throw DisposalProjectionRejection(code: "TYPED_ADAPTER_RULES_ARRAY")
        }
        var schemas: [String] = []
        for value in values {
            guard case .object(let members, _) = value,
                  Set(members.map(\.key)) == Set(["promotion", "schema"]),
                  value.member("promotion")?.stringValue() == "TYPED_EXACT_POINTERS_ONLY",
                  let schema = value.member("schema")?.stringValue()
            else { throw DisposalProjectionRejection(code: "TYPED_ADAPTER_RULE_SHAPE") }
            schemas.append(schema)
        }
        let expected = typedAdapterSchemas.union(knownNoProcessAdapterSchemas)
        try disposalRequireProjection(
            Set(schemas).count == schemas.count && Set(schemas) == expected,
            "TYPED_ADAPTER_SWITCH_INVENTORY")
    }

    private func insertAdapterCoverage(
        frame: DisposalDecodedFrame,
        schema: String,
        state: String,
        scope: String
    ) throws {
        let statement = try database.prepare(
            "INSERT INTO frame_adapter_coverage VALUES(?,?,?,?,?,?)")
        try statement.bind(1, text: frameIDs[frame.ordinal])
        try statement.bind(2, text: schema)
        try statement.bind(3, text: frame.eventType.rawValue)
        try statement.bind(4, text: state)
        try statement.bind(5, text: scope)
        try statement.bind(6, text: adapterManifestSHA256)
        try statement.stepDone()
        frameAdapterCoverageIDs.append(frameIDs[frame.ordinal])
    }

    private func requireEvent(
        _ frame: DisposalDecodedFrame,
        _ expected: DisposalEventType,
        _ schema: String
    ) throws {
        try disposalRequireProjection(
            frame.eventType == expected,
            "TYPED_SCHEMA_EVENT_TYPE",
            frameOrdinal: frame.ordinal,
            detail: "\(schema):expected=\(expected.rawValue):actual=\(frame.eventType.rawValue)")
    }

    private func insertR19Start(_ frame: DisposalDecodedFrame) throws {
        let payload = try frame.payloadValue()
        let controllerPID = try requiredInt(payload, "controller_pid", frame, "/payload")
        _ = try ensureTarget(
            sourceFrame: frame,
            label: "controller",
            role: "DISPOSAL_CONTROLLER",
            pid: controllerPID,
            targetForm: "OBSERVATION_ONLY",
            uniqueID: nil,
            idVersion: nil,
            sid: nil,
            pgid: nil,
            uuidHex: nil,
            parentUniqueID: nil,
            parentIDVersion: nil,
            uid: nil,
            gid: nil)
        try insertFixedGenerationTarget(
            payload: payload,
            key: "fixed_guardian_generation",
            label: "guardian",
            role: "R19_GUARDIAN",
            targetForm: "POSITIVE_PID",
            frame: frame)
        try insertFixedGenerationTarget(
            payload: payload,
            key: "fixed_fixture_generation",
            label: "fixture",
            role: "R19_FIXTURE",
            targetForm: "NEGATIVE_PGID",
            frame: frame)
    }

    private func insertFixedGenerationTarget(
        payload: DisposalJSONValue,
        key: String,
        label: String,
        role: String,
        targetForm: String,
        frame: DisposalDecodedFrame
    ) throws {
        let values = try requiredArray(payload, key, frame, "/payload")
        try disposalRequireProjection(
            values.count == 3,
            "TYPED_FIXED_GENERATION_COUNT",
            frameOrdinal: frame.ordinal,
            detail: key)
        let pid = try integer(values[0], frame, "/payload/\(key)/0")
        let uniqueID = try unsigned(values[1], frame, "/payload/\(key)/1")
        let idVersion = try unsigned(values[2], frame, "/payload/\(key)/2")
        _ = try ensureTarget(
            sourceFrame: frame,
            label: label,
            role: role,
            pid: pid,
            targetForm: targetForm,
            uniqueID: uniqueID,
            idVersion: idVersion,
            sid: pid,
            pgid: pid,
            uuidHex: nil,
            parentUniqueID: nil,
            parentIDVersion: nil,
            uid: nil,
            gid: nil)
    }

    private func insertR19GuardianPrestate(_ frame: DisposalDecodedFrame) throws {
        let payload = try frame.payloadValue()
        if let namespace = payload.member("guardian_terminal_namespace") {
            try insertNamespace(frame: frame, value: namespace)
        }
        guard let snapshot = payload.member("guardian") else {
            throw rejection("TYPED_GUARDIAN_SNAPSHOT_ABSENT", frame)
        }
        if case .string = snapshot { return }
        try insertR19Snapshot(frame: frame, value: snapshot, label: "guardian")
    }

    private func insertR19FixturePrestate(_ frame: DisposalDecodedFrame) throws {
        let payload = try frame.payloadValue()
        guard let snapshot = payload.member("fixture") else {
            throw rejection("TYPED_FIXTURE_SNAPSHOT_ABSENT", frame)
        }
        try insertR19Snapshot(frame: frame, value: snapshot, label: "fixture")
    }

    private func insertNamespace(
        frame: DisposalDecodedFrame,
        value: DisposalJSONValue
    ) throws {
        let kind = try requiredString(value, "kind", frame, "/payload/guardian_terminal_namespace")
        let state: String
        switch kind {
        case "absent": state = "ABSENT"
        case "present": state = "PRESENT_VALID"
        default:
            throw rejection("TYPED_NAMESPACE_KIND", frame, kind)
        }
        let rawSHA = try rawSHA256(
            frame: frame,
            pointer: "/payload/guardian_terminal_namespace")
        let id = disposalID(
            "disposal-namespace-observation-v1",
            [frameIDs[frame.ordinal], "GUARDIAN_TERMINAL", rawSHA])
        let statement = try database.prepare("INSERT INTO namespace_observations VALUES(?,?,?,?,?,?,?)")
        try statement.bind(1, text: id)
        try statement.bind(2, text: frameIDs[frame.ordinal])
        try statement.bind(3, text: invocationID)
        try statement.bind(4, text: "GUARDIAN_TERMINAL")
        try statement.bind(5, text: state)
        try statement.bind(6, text: nil)
        try statement.bind(7, text: rawSHA)
        try statement.stepDone()
        namespaceObservationIDs.append(id)
    }

    private func insertR19Snapshot(
        frame: DisposalDecodedFrame,
        value: DisposalJSONValue,
        label: String
    ) throws {
        let basePointer = label == "guardian" ? "/payload/guardian" : "/payload/fixture"
        let kind = try requiredString(value, "kind", frame, basePointer)
        let target: TargetContext
        if let existing = targets[label] {
            target = existing
        } else if kind == "present", let process = value.member("process") {
            target = try ensureTargetFromLegacyReceipt(
                frame: frame,
                process: process,
                pointer: basePointer + "/process",
                label: label)
        } else {
            throw rejection("TYPED_TARGET_PREDECESSOR_ABSENT", frame, label)
        }
        let snapshotKind: String
        let receiptID: String?
        let groupID: String?
        let sessionID: String?
        switch kind {
        case "present":
            let process = try requiredMember(value, "process", frame, basePointer)
            receiptID = try insertLegacyReceipt(
                frame: frame,
                value: process,
                pointer: basePointer + "/process",
                target: target,
                observationKind: "JOINED")
            let groupMembers = try requiredMember(value, "group_members", frame, basePointer)
            groupID = try insertDomain(
                frame: frame,
                value: groupMembers,
                pointer: basePointer + "/group_members",
                kind: "GROUP",
                numericDomain: target.pgid ?? target.pid,
                target: target)
            let sessionMembers = try requiredMember(value, "session_members", frame, basePointer)
            sessionID = try insertDomain(
                frame: frame,
                value: sessionMembers,
                pointer: basePointer + "/session_members",
                kind: "SESSION",
                numericDomain: target.sid ?? target.pid,
                target: target)
            snapshotKind = "PRESENT"
            missingEvidence.append(.init(
                evidenceKind: "HELD_IMAGE_AND_CWD_RAW_ARTIFACTS",
                targetRole: target.role,
                sourceFrameID: frameIDs[frame.ordinal],
                reasonCode: "LEGACY_SNAPSHOT_HAS_VNODE_METADATA_WITHOUT_EMBEDDED_RAW_HELD_ARTIFACT"))
        case "absent":
            receiptID = nil
            groupID = nil
            sessionID = nil
            snapshotKind = "ABSENT"
        case "rebound":
            let observed = try requiredMember(value, "observed", frame, basePointer)
            receiptID = try insertLegacyReceipt(
                frame: frame,
                value: observed,
                pointer: basePointer + "/observed",
                target: target,
                observationKind: "REBOUND")
            groupID = nil
            sessionID = nil
            snapshotKind = "REBOUND"
        default:
            throw rejection("TYPED_SNAPSHOT_KIND", frame, kind)
        }
        let snapshotSHA = try rawSHA256(frame: frame, pointer: basePointer)
        let snapshotID = disposalID(
            "disposal-target-snapshot-v1",
            [frameIDs[frame.ordinal], target.id, "PRESTATE", snapshotSHA])
        let statement = try database.prepare("INSERT INTO target_snapshots VALUES(?,?,?,?,?,?,?,?,?,?,?)")
        try statement.bind(1, text: snapshotID)
        try statement.bind(2, text: frameIDs[frame.ordinal])
        try statement.bind(3, text: target.id)
        try statement.bind(4, text: "PRESTATE")
        try statement.bind(5, text: snapshotKind)
        try statement.bind(6, text: receiptID)
        try statement.bind(7, text: nil)
        try statement.bind(8, text: nil)
        try statement.bind(9, text: groupID)
        try statement.bind(10, text: sessionID)
        try statement.bind(11, text: snapshotSHA)
        try statement.stepDone()
        targetSnapshotIDs.append(snapshotID)

        let equality = snapshotKind == "REBOUND" ? "DRIFT" : "EQUAL"
        let shape = snapshotKind == "REBOUND" ? "SINGLE_ONLY" : "SOURCE_ASSERTED_EQUAL_COLLAPSED"
        let pairID = disposalID(
            "disposal-snapshot-pair-v1",
            [frameIDs[frame.ordinal], target.id, "PRESTATE_DOUBLE", snapshotSHA, shape])
        let pair = try database.prepare("INSERT INTO snapshot_pairs VALUES(?,?,?,?,?,?,?,?,?,?,?)")
        try pair.bind(1, text: pairID)
        try pair.bind(2, text: frameIDs[frame.ordinal])
        try pair.bind(3, text: target.id)
        try pair.bind(4, text: "PRESTATE_DOUBLE")
        try pair.bind(5, text: snapshotID)
        try pair.bind(6, text: nil)
        try pair.bind(7, text: equality)
        try pair.bind(8, text: shape)
        try pair.bind(9, text: snapshotKind == "REBOUND" ? nil : snapshotSHA)
        try pair.bind(10, text: nil)
        try pair.bind(11, text: nil)
        try pair.stepDone()
        snapshotPairIDs.append(pairID)
        prestatePairs[label] = .init(id: pairID, certificateSHA256: snapshotSHA)
    }

    private func insertR19Commitment(_ frame: DisposalDecodedFrame) throws {
        try disposalRequireProjection(
            conservationSet == nil,
            "TYPED_MERKLE_LATER_UNCOMMITTED_OBLIGATION",
            frameOrdinal: frame.ordinal)
        let payload = try frame.payloadValue()
        let label = try requiredString(payload, "role", frame, "/payload")
        guard let target = targets[label], let pair = prestatePairs[label] else {
            throw rejection("TYPED_COMMITMENT_PRESTATE_ABSENT", frame, label)
        }
        let numericArgument = try requiredInt(payload, "target", frame, "/payload")
        let expected = label == "guardian" ? target.pid : -target.pid
        try disposalRequireProjection(
            numericArgument == expected,
            "TYPED_COMMITMENT_TARGET",
            frameOrdinal: frame.ordinal,
            detail: label)
        let generation = try requiredArray(payload, "generation", frame, "/payload")
        try disposalRequireProjection(generation.count == 2, "TYPED_COMMITMENT_GENERATION", frameOrdinal: frame.ordinal)
        let observedUniqueID = try unsigned(generation[0], frame, "/payload/generation/0")
        let observedIDVersion = try unsigned(generation[1], frame, "/payload/generation/1")
        try disposalRequireProjection(
            observedUniqueID == target.uniqueID && observedIDVersion == target.idVersion,
            "TYPED_COMMITMENT_GENERATION_JOIN",
            frameOrdinal: frame.ordinal)
        let prestateSHA = try requiredString(payload, "prestate_sha256", frame, "/payload")
        try disposalRequireProjection(
            prestateSHA == pair.certificateSHA256,
            "TYPED_COMMITMENT_PRESTATE_SHA",
            frameOrdinal: frame.ordinal)
        try requireFalse(payload, "retry_authorized", frame)
        try requireFalse(payload, "atomic_generation_bound_signal_available", frame)
        try requireTrue(payload, "call_may_enter_after_this_record", frame)
        try requireTrue(payload, "missing_result_means_may_have_entered", frame)
        let id = disposalID(
            "disposal-commitment-v1",
            [frameIDs[frame.ordinal], target.id, "KILL", String(numericArgument), prestateSHA])
        let statement = try database.prepare("INSERT INTO commitments VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?)")
        try statement.bind(1, text: id)
        try statement.bind(2, text: frameIDs[frame.ordinal])
        try statement.bind(3, text: target.id)
        try statement.bind(4, text: "KILL")
        try statement.bind(5, text: target.targetForm)
        try statement.bind(6, int: numericArgument)
        try statement.bind(7, int: 9)
        try statement.bind(8, text: pair.id)
        try statement.bind(9, text: prestateSHA)
        try statement.bind(10, int: 1)
        try statement.bind(11, int: 1)
        try statement.bind(12, int: 1)
        try statement.bind(13, int: 0)
        try statement.bind(14, int: 0)
        try statement.stepDone()
        commitmentIDs.append(id)
        guard let targetUniqueID = target.uniqueID, let targetIDVersion = target.idVersion else {
            throw rejection("TYPED_MERKLE_TARGET_GENERATION_ABSENT", frame, label)
        }
        let obligationKey = DisposalConservationSetMerkle.obligationKey(
            commitmentFrameLFSHA256: frame.rawWithLFSHA256,
            targetRole: target.role,
            targetForm: target.targetForm,
            targetPID: target.pid,
            targetUniqueID: targetUniqueID,
            targetIDVersion: targetIDVersion,
            operation: "KILL",
            numericArgument: numericArgument,
            signalNumber: 9,
            budgetOrdinal: 1)
        let context = CommitmentContext(
            id: id,
            target: target,
            numericArgument: numericArgument,
            signalNumber: 9,
            operation: "KILL",
            budgetOrdinal: 1,
            sourceOrdinal: frame.ordinal,
            sourceFrameID: frameIDs[frame.ordinal],
            sourceFrameLFSHA256: frame.rawWithLFSHA256,
            obligationKeySHA256: obligationKey)
        commitmentsByID[id] = context
        latestCommitmentByLabel[label] = context
    }

    private func insertConservationSetCommitment(
        _ frame: DisposalDecodedFrame
    ) throws {
        try disposalRequireProjection(
            conservationSet == nil,
            "TYPED_MERKLE_DUPLICATE_SET_COMMITMENT",
            frameOrdinal: frame.ordinal)
        try disposalRequireProjection(
            conservationIDs.isEmpty,
            "TYPED_MERKLE_NOT_PRECONSERVATION",
            frameOrdinal: frame.ordinal)
        let payload = try frame.payloadValue()
        try requireExactKeys(
            payload,
            [
                "algorithm", "domain_tag", "duplicate_policy", "epoch_label",
                "invocation_id", "leaf_count", "leaf_ordering", "memberships",
                "odd_leaf_rule", "purpose", "schema", "scope_id", "scope_kind",
                "tree_shape", "witness_root_sha256",
            ],
            frame,
            "/payload")
        try requireExactString(payload, "invocation_id", invocationID, frame)
        try requireExactString(payload, "epoch_label", epochLabel, frame)
        try requireExactString(payload, "purpose", DisposalConservationSetMerkle.purpose, frame)
        try requireExactString(payload, "scope_kind", DisposalConservationSetMerkle.scopeKind, frame)
        try requireExactString(payload, "scope_id", invocationID, frame)
        try requireExactString(payload, "algorithm", DisposalConservationSetMerkle.algorithm, frame)
        try requireExactString(payload, "domain_tag", DisposalConservationSetMerkle.domainTag, frame)
        try requireExactString(payload, "leaf_ordering", DisposalConservationSetMerkle.leafOrdering, frame)
        try requireExactString(payload, "duplicate_policy", DisposalConservationSetMerkle.duplicatePolicy, frame)
        try requireExactString(payload, "tree_shape", DisposalConservationSetMerkle.treeShape, frame)
        try requireExactString(payload, "odd_leaf_rule", DisposalConservationSetMerkle.oddLeafRule, frame)

        let leafCount = try requiredInt(payload, "leaf_count", frame, "/payload")
        try disposalRequireProjection(
            leafCount > 0,
            "TYPED_MERKLE_EMPTY_SET",
            frameOrdinal: frame.ordinal)
        let membershipValues = try requiredArray(payload, "memberships", frame, "/payload")
        try disposalRequireProjection(
            membershipValues.count == leafCount,
            "TYPED_MERKLE_LEAF_COUNT",
            frameOrdinal: frame.ordinal)
        let obligations = commitmentsByID.values.sorted {
            $0.obligationKeySHA256.utf8.lexicographicallyPrecedes(
                $1.obligationKeySHA256.utf8)
        }
        try disposalRequireProjection(
            obligations.count == leafCount,
            "TYPED_MERKLE_NOT_FULL_OBLIGATION_SET",
            frameOrdinal: frame.ordinal)
        try disposalRequireProjection(
            Set(obligations.map(\.obligationKeySHA256)).count == obligations.count,
            "TYPED_MERKLE_DUPLICATE_OBLIGATION_KEY",
            frameOrdinal: frame.ordinal)
        let leafHashes = obligations.map {
            DisposalConservationSetMerkle.leafSHA256(
                obligationKeySHA256: $0.obligationKeySHA256)
        }
        let canonicalObligationKeys = obligations.map(\.obligationKeySHA256)
        let derivedRoot = try DisposalConservationSetMerkle.root(
            canonicalObligationKeys: canonicalObligationKeys)
        let witnessRoot = try requiredString(
            payload, "witness_root_sha256", frame, "/payload")
        try requireLowerSHA256(witnessRoot, frame, "/payload/witness_root_sha256")
        try disposalRequireProjection(
            witnessRoot == derivedRoot,
            "TYPED_MERKLE_ROOT_MISMATCH",
            frameOrdinal: frame.ordinal)

        let setID = DisposalConservationSetMerkle.semanticID(
            "disposal-conservation-set-commitment-v1",
            [
                frameIDs[frame.ordinal], invocationID, epochLabel,
                DisposalConservationSetMerkle.purpose,
                DisposalConservationSetMerkle.scopeKind,
                invocationID,
                DisposalConservationSetMerkle.algorithm,
                DisposalConservationSetMerkle.domainTag,
                DisposalConservationSetMerkle.leafOrdering,
                DisposalConservationSetMerkle.duplicatePolicy,
                DisposalConservationSetMerkle.treeShape,
                DisposalConservationSetMerkle.oddLeafRule,
                witnessRoot,
                String(leafCount),
            ])
        let setStatement = try database.prepare(
            "INSERT INTO conservation_set_commitments VALUES(" +
                String(repeating: "?,", count: 15) + "?)")
        try setStatement.bind(1, text: setID)
        try setStatement.bind(2, text: frameIDs[frame.ordinal])
        try setStatement.bind(3, text: invocationID)
        try setStatement.bind(4, text: epochLabel)
        try setStatement.bind(5, text: DisposalConservationSetMerkle.purpose)
        try setStatement.bind(6, text: DisposalConservationSetMerkle.scopeKind)
        try setStatement.bind(7, text: invocationID)
        try setStatement.bind(8, text: DisposalConservationSetMerkle.algorithm)
        try setStatement.bind(9, text: DisposalConservationSetMerkle.domainTag)
        try setStatement.bind(10, text: DisposalConservationSetMerkle.leafOrdering)
        try setStatement.bind(11, text: DisposalConservationSetMerkle.duplicatePolicy)
        try setStatement.bind(12, text: DisposalConservationSetMerkle.treeShape)
        try setStatement.bind(13, text: DisposalConservationSetMerkle.oddLeafRule)
        try setStatement.bind(14, text: witnessRoot)
        try setStatement.bind(15, int: leafCount)
        try setStatement.bind(16, text: "EXPLICIT_PRECONSERVATION")
        try setStatement.stepDone()
        conservationSetCommitmentIDs.append(setID)

        var membershipsByKey: [String: ConservationSetMembershipContext] = [:]
        for ordinal in obligations.indices {
            let obligation = obligations[ordinal]
            let value = membershipValues[ordinal]
            let pointer = "/payload/memberships/\(ordinal)"
            try requireExactKeys(
                value,
                [
                    "budget_ordinal", "commitment_frame_lf_sha256",
                    "commitment_frame_ordinal", "expected_idversion",
                    "expected_uniqueid", "leaf_ordinal", "leaf_sha256",
                    "numeric_argument", "obligation_key_sha256", "operation",
                    "proof", "signal_number", "target_form", "target_pid",
                    "target_role",
                ],
                frame,
                pointer)
            let target = obligation.target
            guard let uniqueID = target.uniqueID, let idVersion = target.idVersion else {
                throw rejection("TYPED_MERKLE_TARGET_GENERATION_ABSENT", frame, target.label)
            }
            try requireExactInt(value, "leaf_ordinal", ordinal, frame, pointer)
            try requireExactString(
                value, "obligation_key_sha256", obligation.obligationKeySHA256, frame, pointer)
            try requireExactString(value, "target_role", target.role, frame, pointer)
            try requireExactString(value, "target_form", target.targetForm, frame, pointer)
            try requireExactInt(value, "target_pid", target.pid, frame, pointer)
            try requireExactUnsigned(value, "expected_uniqueid", uniqueID, frame, pointer)
            try requireExactUnsigned(value, "expected_idversion", idVersion, frame, pointer)
            try requireExactString(value, "operation", obligation.operation, frame, pointer)
            try requireExactInt(
                value, "numeric_argument", obligation.numericArgument, frame, pointer)
            try requireExactInt(value, "signal_number", obligation.signalNumber, frame, pointer)
            try requireExactInt(value, "budget_ordinal", obligation.budgetOrdinal, frame, pointer)
            try requireExactInt(
                value, "commitment_frame_ordinal", obligation.sourceOrdinal, frame, pointer)
            try requireExactString(
                value,
                "commitment_frame_lf_sha256",
                obligation.sourceFrameLFSHA256,
                frame,
                pointer)
            let leafSHA = try requiredString(value, "leaf_sha256", frame, pointer)
            try disposalRequireProjection(
                leafSHA == leafHashes[ordinal],
                "TYPED_MERKLE_LEAF_HASH",
                frameOrdinal: frame.ordinal,
                detail: String(ordinal))
            let proof = try parseMerkleProof(
                value: try requiredMember(value, "proof", frame, pointer),
                frame: frame,
                pointer: pointer + "/proof")
            let expectedProof = try DisposalConservationSetMerkle.proof(
                leafOrdinal: ordinal,
                canonicalObligationKeys: canonicalObligationKeys)
            try disposalRequireProjection(
                proof == expectedProof,
                "TYPED_MERKLE_PROOF_MISMATCH",
                frameOrdinal: frame.ordinal,
                detail: String(ordinal))
            try disposalRequireProjection(
                DisposalConservationSetMerkle.verify(
                    leafSHA256: leafSHA,
                    proof: proof,
                    rootSHA256: witnessRoot),
                "TYPED_MERKLE_PROOF_ROOT",
                frameOrdinal: frame.ordinal,
                detail: String(ordinal))
            let proofSHA = DisposalConservationSetMerkle.proofSHA256(proof)
            let membershipID = DisposalConservationSetMerkle.semanticID(
                "disposal-conservation-set-membership-v1",
                [
                    setID, String(ordinal), obligation.obligationKeySHA256,
                    leafSHA, proofSHA,
                ])
            let memberStatement = try database.prepare(
                "INSERT INTO conservation_set_memberships VALUES(" +
                    String(repeating: "?,", count: 18) + "?)")
            try memberStatement.bind(1, text: membershipID)
            try memberStatement.bind(2, text: setID)
            try memberStatement.bind(3, int: ordinal)
            try memberStatement.bind(4, text: obligation.obligationKeySHA256)
            try memberStatement.bind(5, text: obligation.id)
            try memberStatement.bind(6, text: target.id)
            try memberStatement.bind(7, text: target.role)
            try memberStatement.bind(8, text: target.targetForm)
            try memberStatement.bind(9, text: String(uniqueID))
            try memberStatement.bind(10, text: String(idVersion))
            try memberStatement.bind(11, text: obligation.operation)
            try memberStatement.bind(12, int: obligation.numericArgument)
            try memberStatement.bind(13, int: obligation.signalNumber)
            try memberStatement.bind(14, int: obligation.budgetOrdinal)
            try memberStatement.bind(15, text: obligation.sourceFrameID)
            try memberStatement.bind(16, text: obligation.sourceFrameLFSHA256)
            try memberStatement.bind(17, text: leafSHA)
            try memberStatement.bind(18, text: proofSHA)
            try memberStatement.bind(19, int: proof.count)
            try memberStatement.stepDone()
            for proofOrdinal in proof.indices {
                let node = proof[proofOrdinal]
                let nodeStatement = try database.prepare(
                    "INSERT INTO conservation_set_membership_proof_nodes VALUES(?,?,?,?)")
                try nodeStatement.bind(1, text: membershipID)
                try nodeStatement.bind(2, int: proofOrdinal)
                try nodeStatement.bind(3, text: node.siblingPosition)
                try nodeStatement.bind(4, text: node.siblingSHA256)
                try nodeStatement.stepDone()
            }
            conservationSetMembershipIDs.append(membershipID)
            membershipsByKey[obligation.obligationKeySHA256] = .init(
                id: membershipID,
                obligationKeySHA256: obligation.obligationKeySHA256,
                obligationCommitmentID: obligation.id,
                target: target)
        }
        conservationSet = .init(
            id: setID,
            sourceOrdinal: frame.ordinal,
            sourceFrameLFSHA256: frame.rawWithLFSHA256,
            scopeKind: DisposalConservationSetMerkle.scopeKind,
            scopeID: invocationID,
            witnessRootSHA256: witnessRoot,
            leafCount: leafCount,
            membershipsByObligationKey: membershipsByKey)
    }

    private func insertR19SignalResult(_ frame: DisposalDecodedFrame) throws {
        let payload = try frame.payloadValue()
        let result = payload.member("result")
        let label: String
        let callEntered: Bool
        let returnValue: Int?
        let errnoValue: Int?
        let delivered: Bool
        let retried: Bool
        let certificateAge: String?
        let certificateMaximum: String?
        if let result, case .object = result {
            label = try requiredString(result, "role", frame, "/payload/result")
            callEntered = try requiredBoolean(result, "call_entered", frame, "/payload/result")
            returnValue = try optionalInt(result, "return", frame, "/payload/result")
            errnoValue = try optionalInt(result, "errno", frame, "/payload/result")
            delivered = try requiredBoolean(result, "delivered", frame, "/payload/result")
            retried = try requiredBoolean(result, "retried", frame, "/payload/result")
            certificateAge = try optionalUnsignedText(
                result, "certificate_age_ns_at_preentry_check", frame, "/payload/result")
            certificateMaximum = try optionalUnsignedText(
                result, "certificate_max_age_ns", frame, "/payload/result")
        } else {
            label = try requiredString(payload, "role", frame, "/payload")
            callEntered = try requiredBoolean(payload, "call_entered", frame, "/payload")
            returnValue = nil
            errnoValue = nil
            delivered = false
            retried = false
            certificateAge = nil
            certificateMaximum = nil
        }
        guard let commitment = latestCommitmentByLabel[label] else {
            throw rejection("TYPED_SIGNAL_COMMITMENT_ABSENT", frame, label)
        }
        try disposalRequireProjection(!retried, "TYPED_SIGNAL_RETRIED", frameOrdinal: frame.ordinal)
        if callEntered {
            try disposalRequireProjection(
                returnValue != nil && errnoValue != nil,
                "TYPED_SIGNAL_RETURN_ABSENT",
                frameOrdinal: frame.ordinal)
        }
        let delivery: String
        if !callEntered {
            delivery = "NOT_ENTERED"
        } else if delivered {
            delivery = "DELIVERED"
        } else if returnValue == -1 && errnoValue == 3 {
            delivery = "ESRCH"
        } else {
            delivery = "FAILED"
        }
        let id = disposalID(
            "disposal-signal-call-v1",
            [frameIDs[frame.ordinal], commitment.id, callEntered ? "ENTERED" : "NOT_ENTERED", delivery])
        let statement = try database.prepare("INSERT INTO signal_calls VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?)")
        try statement.bind(1, text: id)
        try statement.bind(2, text: commitment.id)
        try statement.bind(3, text: frameIDs[frame.ordinal])
        try statement.bind(4, text: nil)
        try statement.bind(5, text: callEntered ? "ENTERED" : "NOT_ENTERED")
        try statement.bind(6, text: callEntered ? "RETURNED" : "NOT_RETURNED")
        try statement.bind(7, int: commitment.numericArgument)
        try statement.bind(8, int: commitment.signalNumber)
        try statement.bind(9, text: certificateAge)
        try statement.bind(10, text: certificateMaximum)
        try statement.bind(11, optionalInt: returnValue)
        try statement.bind(12, optionalInt: errnoValue)
        try statement.bind(13, text: delivery)
        try statement.bind(14, int: 0)
        try statement.stepDone()
        signalCallIDs.append(id)
    }

    private func insertR19Conservation(
        _ frame: DisposalDecodedFrame,
        label: String
    ) throws -> String {
        guard let target = targets[label] else {
            throw rejection("TYPED_CONSERVATION_TARGET_ABSENT", frame, label)
        }
        let payload = try frame.payloadValue()
        let proof = try requiredMember(payload, "proof", frame, "/payload")
        let kind = try requiredString(proof, "kind", frame, "/payload/proof")
        try disposalRequireProjection(
            kind == "external_conservation",
            "TYPED_CONSERVATION_KIND",
            frameOrdinal: frame.ordinal)
        let preexisting = try requiredBoolean(
            proof, "preexisting_absence", frame, "/payload/proof")
        let rounds = try requiredArray(proof, "rounds", frame, "/payload/proof")
        try disposalRequireProjection(
            rounds.count == 2,
            "TYPED_CONSERVATION_ACCEPTED_ROUND_COUNT",
            frameOrdinal: frame.ordinal)
        let enteredCount = try requiredInt(
            proof, "signal_zero_entered_count", frame, "/payload/proof")
        try disposalRequireProjection(
            enteredCount >= 2,
            "TYPED_CONSERVATION_SIGNAL_ZERO_COUNT",
            frameOrdinal: frame.ordinal)
        let transientFaults = try optionalInt(
            proof, "transient_fault_count", frame, "/payload/proof") ?? 0
        let retainedAttemptOrdinals = [enteredCount - 1, enteredCount]
        var roundFacts: [(Int, String, String, String)] = []
        for index in rounds.indices {
            let pointer = "/payload/proof/rounds/\(index)"
            let round = rounds[index]
            let pid = try requiredInt(round, "pid", frame, pointer)
            let uniqueID = try requiredUnsigned(round, "uniqueid", frame, pointer)
            try disposalRequireProjection(
                pid == target.pid && uniqueID == target.uniqueID,
                "TYPED_CONSERVATION_GENERATION",
                frameOrdinal: frame.ordinal)
            try disposalRequireProjection(
                try requiredString(round, "generation", frame, pointer) == "ESRCH",
                "TYPED_CONSERVATION_GENERATION_STATE",
                frameOrdinal: frame.ordinal)
            let group = try requiredMember(round, "group_projection", frame, pointer)
            let groupID = try insertDomain(
                frame: frame,
                value: group,
                pointer: pointer + "/group_projection",
                kind: "GROUP",
                numericDomain: target.pgid ?? target.pid,
                target: target)
            let session = try requiredMember(round, "session_projection", frame, pointer)
            let sessionID = try insertDomain(
                frame: frame,
                value: session,
                pointer: pointer + "/session_projection",
                kind: "SESSION",
                numericDomain: target.sid ?? target.pid,
                target: target)
            let probe = try requiredMember(round, "signal_zero", frame, pointer)
            try requireTrue(probe, "entered", frame, pointer: pointer + "/signal_zero")
            let returned = try requiredInt(probe, "return", frame, pointer + "/signal_zero")
            let error = try requiredInt(probe, "errno", frame, pointer + "/signal_zero")
            let esrch = try requiredBoolean(
                probe, "esrch", frame, pointer + "/signal_zero")
            try disposalRequireProjection(
                returned == -1 && error == 3 && esrch,
                "TYPED_CONSERVATION_SIGNAL_ZERO_ESRCH",
                frameOrdinal: frame.ordinal)
            let signalZeroRawSHA = try rawSHA256(
                frame: frame,
                pointer: pointer + "/signal_zero")
            let signalZeroID = disposalID(
                "disposal-signal-zero-call-v1",
                [frameIDs[frame.ordinal], target.id, String(retainedAttemptOrdinals[index]), signalZeroRawSHA])
            let signalStatement = try database.prepare("INSERT INTO signal_zero_calls VALUES(?,?,?,?,?,?,?,?,?)")
            try signalStatement.bind(1, text: signalZeroID)
            try signalStatement.bind(2, text: frameIDs[frame.ordinal])
            try signalStatement.bind(3, text: target.id)
            try signalStatement.bind(4, int: -(target.pgid ?? target.pid))
            try signalStatement.bind(5, text: "ENTERED")
            try signalStatement.bind(6, text: "RETURNED")
            try signalStatement.bind(7, int: returned)
            try signalStatement.bind(8, int: error)
            try signalStatement.bind(9, text: "ESRCH")
            try signalStatement.stepDone()
            signalZeroCallIDs.append(signalZeroID)
            roundFacts.append((retainedAttemptOrdinals[index], groupID, sessionID, signalZeroID))
        }
        let availability = enteredCount == 2 && transientFaults == 0
            ? "ALL_ATTEMPTS_RETAINED"
            : "FINAL_TWO_PLUS_COUNTS_ONLY"
        let proofID = disposalID(
            "disposal-absence-proof-v1",
            [frameIDs[frame.ordinal], target.id, preexisting ? "PREEXISTING" : "POST_SIGNAL", String(enteredCount)])
        let proofStatement = try database.prepare("INSERT INTO absence_proofs VALUES(?,?,?,?,?,?,?,?)")
        try proofStatement.bind(1, text: proofID)
        try proofStatement.bind(2, text: frameIDs[frame.ordinal])
        try proofStatement.bind(3, text: target.id)
        try proofStatement.bind(4, text: preexisting ? "PREEXISTING" : "POST_SIGNAL")
        try proofStatement.bind(5, text: availability)
        try proofStatement.bind(6, int: transientFaults)
        try proofStatement.bind(7, int: max(0, enteredCount - 2))
        try proofStatement.bind(8, int: 2)
        try proofStatement.stepDone()
        absenceProofIDs.append(proofID)
        for (acceptedIndex, fact) in roundFacts.enumerated() {
            let attempt = try database.prepare("INSERT INTO absence_attempts VALUES(?,?,?,?,?,?,?)")
            try attempt.bind(1, text: proofID)
            try attempt.bind(2, int: fact.0)
            try attempt.bind(3, text: "ESRCH")
            try attempt.bind(4, text: fact.1)
            try attempt.bind(5, text: fact.2)
            try attempt.bind(6, text: fact.3)
            try attempt.bind(7, text: "ACCEPTED_CANDIDATE")
            try attempt.stepDone()
            let accepted = try database.prepare("INSERT INTO accepted_absence_rounds VALUES(?,?,?)")
            try accepted.bind(1, text: proofID)
            try accepted.bind(2, int: acceptedIndex + 1)
            try accepted.bind(3, int: fact.0)
            try accepted.stepDone()
        }
        let conservationID = disposalID(
            "disposal-conservation-v1",
            [frameIDs[frame.ordinal], target.id, proofID])
        let conservation = try database.prepare("INSERT INTO conservations VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)")
        try conservation.bind(1, text: conservationID)
        try conservation.bind(2, text: frameIDs[frame.ordinal])
        try conservation.bind(3, text: target.id)
        try conservation.bind(4, text: proofID)
        try conservation.bind(5, text: nil)
        try conservation.bind(6, text: preexisting ? "PREEXISTING_EXTERNAL_ABSENCE" : "POST_SIGNAL_EXTERNAL_ABSENCE")
        try conservation.bind(7, int: 0)
        try conservation.bind(8, int: 0)
        try conservation.bind(9, int: 1)
        try conservation.bind(10, int: 1)
        try conservation.bind(11, int: 1)
        try conservation.bind(12, int: 1)
        try conservation.bind(13, text: "COMPLETE")
        try conservation.stepDone()
        conservationIDs.append(conservationID)
        try insertConservationSetState(
            frame: frame,
            target: target,
            conservationID: conservationID,
            proof: proof)
        return conservationID
    }

    private func insertConservationSetState(
        frame: DisposalDecodedFrame,
        target: TargetContext,
        conservationID: String,
        proof: DisposalJSONValue
    ) throws {
        guard let reference = proof.member("conservation_set_reference") else {
            let state = try database.prepare(
                "INSERT INTO conservation_set_conservation_states VALUES(?,?,?,?)")
            try state.bind(1, text: conservationID)
            try state.bind(2, text: frameIDs[frame.ordinal])
            try state.bind(3, text: nil)
            try state.bind(4, text: "ABSENT_UNKNOWN")
            try state.stepDone()
            missingEvidence.append(.init(
                evidenceKind: "PRECONSERVATION_CONSERVATION_SET_COMMITMENT",
                targetRole: target.role,
                sourceFrameID: frameIDs[frame.ordinal],
                reasonCode: "CONSERVATION_FRAME_HAS_NO_PRIOR_EXPLICIT_MERKLE_REFERENCE"))
            return
        }
        let pointer = "/payload/proof/conservation_set_reference"
        try requireExactKeys(
            reference,
            [
                "algorithm", "commitment_frame_lf_sha256", "commitment_frame_ordinal",
                "domain_tag", "duplicate_policy", "epoch_label", "invocation_id",
                "leaf_count", "leaf_ordering", "obligation_keys", "odd_leaf_rule",
                "purpose", "scope_id", "scope_kind", "tree_shape",
                "witness_root_sha256",
            ],
            frame,
            pointer)
        let sourceOrdinal = try requiredInt(
            reference, "commitment_frame_ordinal", frame, pointer)
        try disposalRequireProjection(
            sourceOrdinal >= 0 && sourceOrdinal < frame.ordinal,
            "TYPED_MERKLE_TEMPORAL_ORDER",
            frameOrdinal: frame.ordinal)
        guard let set = conservationSet, set.sourceOrdinal == sourceOrdinal else {
            throw rejection("TYPED_MERKLE_COMMITMENT_PREDECESSOR_ABSENT", frame)
        }
        try disposalRequireProjection(
            Set(commitmentsByID.values.map(\.obligationKeySHA256)) ==
                Set(set.membershipsByObligationKey.keys),
            "TYPED_MERKLE_LATER_UNCOMMITTED_OBLIGATION",
            frameOrdinal: frame.ordinal)
        try requireExactString(
            reference,
            "commitment_frame_lf_sha256",
            set.sourceFrameLFSHA256,
            frame,
            pointer)
        try requireExactString(reference, "invocation_id", invocationID, frame, pointer)
        try requireExactString(reference, "epoch_label", epochLabel, frame, pointer)
        try requireExactString(
            reference, "purpose", DisposalConservationSetMerkle.purpose, frame, pointer)
        try requireExactString(reference, "scope_kind", set.scopeKind, frame, pointer)
        try requireExactString(reference, "scope_id", set.scopeID, frame, pointer)
        try requireExactString(
            reference, "algorithm", DisposalConservationSetMerkle.algorithm, frame, pointer)
        try requireExactString(
            reference, "domain_tag", DisposalConservationSetMerkle.domainTag, frame, pointer)
        try requireExactString(
            reference,
            "leaf_ordering",
            DisposalConservationSetMerkle.leafOrdering,
            frame,
            pointer)
        try requireExactString(
            reference,
            "duplicate_policy",
            DisposalConservationSetMerkle.duplicatePolicy,
            frame,
            pointer)
        try requireExactString(
            reference, "tree_shape", DisposalConservationSetMerkle.treeShape, frame, pointer)
        try requireExactString(
            reference,
            "odd_leaf_rule",
            DisposalConservationSetMerkle.oddLeafRule,
            frame,
            pointer)
        try requireExactString(
            reference, "witness_root_sha256", set.witnessRootSHA256, frame, pointer)
        try requireExactInt(reference, "leaf_count", set.leafCount, frame, pointer)

        let keys = try requiredArray(reference, "obligation_keys", frame, pointer)
            .enumerated()
            .map { index, value -> String in
                guard let key = value.stringValue() else {
                    throw rejection(
                        "TYPED_MERKLE_OBLIGATION_KEY",
                        frame,
                        pointer + "/obligation_keys/\(index)")
                }
                try requireLowerSHA256(
                    key, frame, pointer + "/obligation_keys/\(index)")
                return key
            }
        try disposalRequireProjection(
            !keys.isEmpty &&
                keys == keys.sorted {
                    $0.utf8.lexicographicallyPrecedes($1.utf8)
                } &&
                Set(keys).count == keys.count,
            "TYPED_MERKLE_MAPPING_KEY_SET",
            frameOrdinal: frame.ordinal)
        let state = try database.prepare(
            "INSERT INTO conservation_set_conservation_states VALUES(?,?,?,?)")
        try state.bind(1, text: conservationID)
        try state.bind(2, text: frameIDs[frame.ordinal])
        try state.bind(3, text: set.id)
        try state.bind(4, text: "VERIFIED_PRIOR_EXACT")
        try state.stepDone()
        for key in keys {
            guard let membership = set.membershipsByObligationKey[key] else {
                throw rejection("TYPED_MERKLE_MAPPING_MEMBERSHIP_ABSENT", frame, key)
            }
            try disposalRequireProjection(
                membership.target.id == target.id &&
                    membership.target.pid == target.pid &&
                    membership.target.uniqueID == target.uniqueID &&
                    membership.target.idVersion == target.idVersion,
                "TYPED_MERKLE_MAPPING_GENERATION",
                frameOrdinal: frame.ordinal,
                detail: key)
            let mappingID = DisposalConservationSetMerkle.semanticID(
                "disposal-conservation-set-obligation-mapping-v1",
                [conservationID, set.id, membership.id, key])
            let mapping = try database.prepare(
                "INSERT INTO conservation_set_obligation_mappings VALUES(?,?,?,?,?,?)")
            try mapping.bind(1, text: mappingID)
            try mapping.bind(2, text: conservationID)
            try mapping.bind(3, text: set.id)
            try mapping.bind(4, text: membership.id)
            try mapping.bind(5, text: target.id)
            try mapping.bind(6, text: "EXPLICIT_SAME_GENERATION")
            try mapping.stepDone()
            conservationSetMappingIDs.append(mappingID)
        }
    }

    private func insertObservabilityFrame(_ frame: DisposalDecodedFrame) throws {
        let wrapper = try frame.payloadValue()
        guard let nested = wrapper.member("payload"), case .object = nested else { return }
        guard try optionalString(nested, "schema", frame, "/payload/payload") ==
            "prime_driver_v2_r19_process_energy_observation_v1"
        else { return }
        try insertObservabilityPayload(
            frame: frame,
            payload: nested,
            payloadPointer: "/payload/payload",
            sourceAssertedSandwich: false)
    }

    private func insertDirectObservabilityFrame(_ frame: DisposalDecodedFrame) throws {
        try insertObservabilityPayload(
            frame: frame,
            payload: frame.payloadValue(),
            payloadPointer: "/payload",
            sourceAssertedSandwich: true)
    }

    private func insertObservabilityPayload(
        frame: DisposalDecodedFrame,
        payload: DisposalJSONValue,
        payloadPointer: String,
        sourceAssertedSandwich: Bool
    ) throws {
        let label = try requiredString(payload, "label", frame, payloadPointer)
        let pid = try requiredInt(payload, "pid", frame, payloadPointer)
        let processPointer = payloadPointer + "/process"
        let process = try requiredMember(payload, "process", frame, payloadPointer)
        let targetRole: String
        switch label {
        case "wrapper": targetRole = "R19_WAIT_WRAPPER"
        case "guardian": targetRole = "R19_GUARDIAN"
        case "fixture": targetRole = "R19_FIXTURE"
        default: return
        }
        if case .null = process {
            let target = try ensureTarget(
                sourceFrame: frame,
                label: label,
                role: targetRole,
                pid: pid,
                targetForm: "OBSERVATION_ONLY",
                uniqueID: nil,
                idVersion: nil,
                sid: nil,
                pgid: nil,
                uuidHex: nil,
                parentUniqueID: nil,
                parentIDVersion: nil,
                uid: nil,
                gid: nil)
            _ = try insertObservationSnapshot(
                frame: frame,
                target: target,
                receiptID: nil,
                kind: "UNKNOWN",
                pointer: processPointer)
            return
        }
        let uniqueID = try requiredUnsigned(process, "unique_id", frame, processPointer)
        let idVersion = try requiredUnsigned(process, "idversion", frame, processPointer)
        let sid = try requiredInt(process, "sid", frame, processPointer)
        let pgid = try requiredInt(process, "pgid", frame, processPointer)
        let uuid = try requiredString(process, "uuid_hex", frame, processPointer)
        let target = try ensureTarget(
            sourceFrame: frame,
            label: label,
            role: targetRole,
            pid: pid,
            targetForm: "OBSERVATION_ONLY",
            uniqueID: uniqueID,
            idVersion: idVersion,
            sid: sid,
            pgid: pgid,
            uuidHex: uuid,
            parentUniqueID: try optionalUnsigned(process, "parent_unique_id", frame, processPointer),
            parentIDVersion: nil,
            uid: try optionalInt(process, "uid", frame, processPointer),
            gid: try optionalInt(process, "gid", frame, processPointer))
        let receiptID = try insertObservabilityReceipt(
            frame: frame,
            value: process,
            pointer: processPointer,
            target: target)
        let snapshotID = try insertObservationSnapshot(
            frame: frame,
            target: target,
            receiptID: receiptID,
            kind: "PRESENT",
            pointer: processPointer)
        if sourceAssertedSandwich {
            try insertCollapsedObservationPair(
                frame: frame,
                target: target,
                snapshotID: snapshotID,
                payloadPointer: payloadPointer)
        }
    }

    private func insertObservationSnapshot(
        frame: DisposalDecodedFrame,
        target: TargetContext,
        receiptID: String?,
        kind: String,
        pointer: String
    ) throws -> String {
        let sha = try rawSHA256(frame: frame, pointer: pointer)
        let id = disposalID(
            "disposal-target-snapshot-v1",
            [frameIDs[frame.ordinal], target.id, "POSTCALL", sha])
        let statement = try database.prepare("INSERT INTO target_snapshots VALUES(?,?,?,?,?,?,?,?,?,?,?)")
        try statement.bind(1, text: id)
        try statement.bind(2, text: frameIDs[frame.ordinal])
        try statement.bind(3, text: target.id)
        try statement.bind(4, text: "POSTCALL")
        try statement.bind(5, text: kind)
        try statement.bind(6, text: receiptID)
        try statement.bind(7, text: nil)
        try statement.bind(8, text: nil)
        try statement.bind(9, text: nil)
        try statement.bind(10, text: nil)
        try statement.bind(11, text: sha)
        try statement.stepDone()
        targetSnapshotIDs.append(id)
        return id
    }

    private func insertCollapsedObservationPair(
        frame: DisposalDecodedFrame,
        target: TargetContext,
        snapshotID: String,
        payloadPointer: String
    ) throws {
        guard let availability = frame.node(at: payloadPointer + "/availability"),
              let process = frame.node(at: payloadPointer + "/process"),
              let before = frame.node(at: payloadPointer + "/monotonic_before_ns"),
              let after = frame.node(at: payloadPointer + "/monotonic_after_ns")
        else {
            throw rejection("TYPED_OBSERVABILITY_COLLAPSED_CERTIFICATE", frame)
        }
        let certificateSHA256 = disposalLengthFramedID(
            "disposal-source-asserted-collapsed-sandwich-v1",
            [
                frame.rawWithLFSHA256,
                availability.rawSHA256,
                process.rawSHA256,
                String(decoding: before.raw, as: UTF8.self),
                String(decoding: after.raw, as: UTF8.self),
            ])
        let pairID = disposalID(
            "disposal-snapshot-pair-v1",
            [
                frameIDs[frame.ordinal], target.id, "POSTCALL_DOUBLE",
                "SOURCE_ASSERTED_EQUAL_COLLAPSED", certificateSHA256,
            ])
        let statement = try database.prepare(
            "INSERT INTO snapshot_pairs VALUES(?,?,?,?,?,?,?,?,?,?,?)")
        try statement.bind(1, text: pairID)
        try statement.bind(2, text: frameIDs[frame.ordinal])
        try statement.bind(3, text: target.id)
        try statement.bind(4, text: "POSTCALL_DOUBLE")
        try statement.bind(5, text: snapshotID)
        try statement.bind(6, text: nil)
        try statement.bind(7, text: "EQUAL")
        try statement.bind(8, text: "SOURCE_ASSERTED_EQUAL_COLLAPSED")
        try statement.bind(9, text: certificateSHA256)
        try statement.bind(10, text: nil)
        try statement.bind(11, text: nil)
        try statement.stepDone()
        snapshotPairIDs.append(pairID)
    }

    private func insertR18Terminal(_ frame: DisposalDecodedFrame) throws {
        let payload = try frame.payloadValue()
        guard let lineage = payload.member("lineage"),
              let worker = lineage.member("worker_postexec"),
              case .object = worker
        else { return }
        let target = try ensureTargetFromLegacyReceipt(
            frame: frame,
            process: worker,
            pointer: "/payload/lineage/worker_postexec",
            label: "r18_worker")
        _ = try insertLegacyReceipt(
            frame: frame,
            value: worker,
            pointer: "/payload/lineage/worker_postexec",
            target: target,
            observationKind: "JOINED")
        if let reap = lineage.member("worker_exact_reap"), case .object = reap {
            try insertR18WaitAndReap(frame: frame, target: target, value: reap)
        }
        missingEvidence.append(.init(
            evidenceKind: "R18_SESSION_CONSERVATION_INVENTORY",
            targetRole: target.role,
            sourceFrameID: frameIDs[frame.ordinal],
            reasonCode: "R18_MONOLITH_RETAINS_GENERATION_AND_GROUP_ABSENCE_BUT_NO_SESSION_ABSENCE_ROUNDS"))
    }

    private func insertR18WaitAndReap(
        frame: DisposalDecodedFrame,
        target: TargetContext,
        value: DisposalJSONValue
    ) throws {
        let returnedPID = try requiredInt(value, "pid", frame, "/payload/lineage/worker_exact_reap")
        try disposalRequireProjection(returnedPID == target.pid, "TYPED_R18_REAP_PID", frameOrdinal: frame.ordinal)
        let rawStatus = try requiredInt(value, "raw_status", frame, "/payload/lineage/worker_exact_reap")
        let exited = try requiredBoolean(value, "exited", frame, "/payload/lineage/worker_exact_reap")
        let signaled = try requiredBoolean(value, "signaled", frame, "/payload/lineage/worker_exact_reap")
        let exitStatus = try optionalInt(value, "exit_status", frame, "/payload/lineage/worker_exact_reap")
        let signal = try optionalInt(value, "term_signal", frame, "/payload/lineage/worker_exact_reap")
        let waitID = disposalID(
            "disposal-wait-call-v1",
            [frameIDs[frame.ordinal], target.id, String(returnedPID), String(rawStatus)])
        let wait = try database.prepare("INSERT INTO wait_calls VALUES(?,?,?,?,?,?,?,?,?,?,?,?)")
        try wait.bind(1, text: waitID)
        try wait.bind(2, text: frameIDs[frame.ordinal])
        try wait.bind(3, text: target.id)
        try wait.bind(4, text: "CONTROLLER_DIRECT_CHILD")
        try wait.bind(5, text: "WAITPID")
        try wait.bind(6, text: "0")
        try wait.bind(7, text: "ENTERED")
        try wait.bind(8, text: "RETURNED")
        try wait.bind(9, optionalInt: target.pid)
        try wait.bind(10, optionalInt: returnedPID)
        try wait.bind(11, optionalInt: returnedPID)
        try wait.bind(12, optionalInt: 0)
        try wait.stepDone()
        waitCallIDs.append(waitID)
        let reapID = disposalID("disposal-reap-v1", [waitID, String(rawStatus)])
        let reap = try database.prepare("INSERT INTO reap_results VALUES(?,?,?,?,?,?,?,?,?,?,?,?)")
        try reap.bind(1, text: reapID)
        try reap.bind(2, text: waitID)
        try reap.bind(3, text: frameIDs[frame.ordinal])
        try reap.bind(4, text: target.id)
        try reap.bind(5, int: returnedPID)
        try reap.bind(6, int: rawStatus)
        try reap.bind(7, int: exited ? 1 : 0)
        try reap.bind(8, optionalInt: exitStatus)
        try reap.bind(9, int: signaled ? 1 : 0)
        try reap.bind(10, optionalInt: signal)
        try reap.bind(11, int: 0)
        try reap.bind(12, int: 1)
        try reap.stepDone()
        reapIDs.append(reapID)
    }

    private func ensureTargetFromLegacyReceipt(
        frame: DisposalDecodedFrame,
        process: DisposalJSONValue,
        pointer: String,
        label: String
    ) throws -> TargetContext {
        let pid = try requiredInt(process, "pid", frame, pointer)
        let role: String
        let form: String
        switch label {
        case "guardian": role = "R19_GUARDIAN"; form = "POSITIVE_PID"
        case "fixture": role = "R19_FIXTURE"; form = "NEGATIVE_PGID"
        case "r18_worker": role = "PRIVATE_CHILD"; form = "NEGATIVE_PGID"
        default: role = "OBSERVER"; form = "OBSERVATION_ONLY"
        }
        let credentials = try optionalIntegerArray(process, "credentials", frame, pointer)
        return try ensureTarget(
            sourceFrame: frame,
            label: label,
            role: role,
            pid: pid,
            targetForm: form,
            uniqueID: try optionalUnsigned(process, "uniqueid", frame, pointer),
            idVersion: try optionalUnsigned(process, "idversion", frame, pointer),
            sid: try optionalInt(process, "sid", frame, pointer),
            pgid: try optionalInt(process, "pgid", frame, pointer),
            uuidHex: try optionalString(process, "uuid_hex", frame, pointer),
            parentUniqueID: try optionalUnsigned(process, "puniqueid", frame, pointer),
            parentIDVersion: try optionalUnsigned(process, "orig_ppidversion", frame, pointer),
            uid: credentials?.count == 6 ? credentials?[0] : try optionalInt(process, "uid", frame, pointer),
            gid: credentials?.count == 6 ? credentials?[1] : try optionalInt(process, "gid", frame, pointer))
    }

    private func ensureTarget(
        sourceFrame: DisposalDecodedFrame,
        label: String,
        role: String,
        pid: Int,
        targetForm: String,
        uniqueID: UInt64?,
        idVersion: UInt64?,
        sid: Int?,
        pgid: Int?,
        uuidHex: String?,
        parentUniqueID: UInt64?,
        parentIDVersion: UInt64?,
        uid: Int?,
        gid: Int?
    ) throws -> TargetContext {
        try disposalRequireProjection(pid > 1, "TYPED_TARGET_PID", detail: label)
        if let existing = targets[label] {
            try disposalRequireProjection(
                existing.pid == pid &&
                    (uniqueID == nil || existing.uniqueID == nil || existing.uniqueID == uniqueID) &&
                    (idVersion == nil || existing.idVersion == nil || existing.idVersion == idVersion) &&
                    (sid == nil || existing.sid == nil || existing.sid == sid) &&
                    (pgid == nil || existing.pgid == nil || existing.pgid == pgid),
                "TYPED_TARGET_DRIFT",
                detail: label)
            return existing
        }
        if let uuidHex {
            try disposalRequireProjection(
                disposalIsLowerHex(uuidHex, count: 32),
                "TYPED_TARGET_UUID",
                detail: label)
        }
        let id = disposalTargetID(
            invocationID: invocationID,
            role: role,
            label: label,
            pid: pid,
            uniqueID: uniqueID,
            idVersion: idVersion)
        let statement = try database.prepare("INSERT INTO targets VALUES(" + String(repeating: "?,", count: 15) + "?)")
        try statement.bind(1, text: id)
        try statement.bind(2, text: invocationID)
        try statement.bind(3, text: role)
        try statement.bind(4, int: pid)
        try statement.bind(5, text: targetForm)
        try statement.bind(6, text: uniqueID.map(String.init))
        try statement.bind(7, text: idVersion.map(String.init))
        try statement.bind(8, text: parentUniqueID.map(String.init))
        try statement.bind(9, text: parentIDVersion.map(String.init))
        try statement.bind(10, optionalInt: sid)
        try statement.bind(11, optionalInt: pgid)
        try statement.bind(12, text: uuidHex)
        try statement.bind(13, optionalInt: uid)
        try statement.bind(14, optionalInt: gid)
        try statement.bind(15, text: nil)
        try statement.bind(16, text: nil)
        try statement.stepDone()
        let provenance = try database.prepare("INSERT INTO target_provenance VALUES(?,?,?)")
        try provenance.bind(1, text: id)
        try provenance.bind(2, text: frameIDs[sourceFrame.ordinal])
        try provenance.bind(3, int: sourceFrame.ordinal)
        try provenance.stepDone()
        let context = TargetContext(
            id: id,
            role: role,
            label: label,
            pid: pid,
            targetForm: targetForm,
            uniqueID: uniqueID,
            idVersion: idVersion,
            sid: sid,
            pgid: pgid)
        targets[label] = context
        targetIDs.append(id)
        return context
    }

    private func insertLegacyReceipt(
        frame: DisposalDecodedFrame,
        value: DisposalJSONValue,
        pointer: String,
        target: TargetContext,
        observationKind: String
    ) throws -> String {
        let credentials = try optionalIntegerArray(value, "credentials", frame, pointer)
        let rawSHA = try rawSHA256(frame: frame, pointer: pointer)
        let id = disposalID(
            "disposal-process-receipt-v1",
            [frameIDs[frame.ordinal], target.id, pointer, rawSHA])
        try insertReceipt(
            id: id,
            frame: frame,
            targetID: target.id,
            observationKind: observationKind,
            pid: try requiredInt(value, "pid", frame, pointer),
            attempts: try optionalInt(value, "attempts", frame, pointer) ?? 1,
            uuidHex: try optionalString(value, "uuid_hex", frame, pointer),
            uniqueID: try optionalUnsigned(value, "uniqueid", frame, pointer),
            idVersion: try optionalUnsigned(value, "idversion", frame, pointer),
            parentUniqueID: try optionalUnsigned(value, "puniqueid", frame, pointer),
            parentIDVersion: try optionalUnsigned(value, "orig_ppidversion", frame, pointer),
            parentPID: try optionalInt(value, "ppid", frame, pointer),
            pgid: try optionalInt(value, "pgid", frame, pointer),
            sid: try optionalInt(value, "sid", frame, pointer),
            status: try optionalInt(value, "status", frame, pointer),
            flags: try optionalInt(value, "flags", frame, pointer),
            commandHex: try optionalString(value, "comm_hex", frame, pointer),
            uid: credentials?.count == 6 ? credentials?[0] : try optionalInt(value, "uid", frame, pointer),
            gid: credentials?.count == 6 ? credentials?[1] : try optionalInt(value, "gid", frame, pointer),
            realUID: credentials?.count == 6 ? credentials?[2] : try optionalInt(value, "ruid", frame, pointer),
            realGID: credentials?.count == 6 ? credentials?[3] : try optionalInt(value, "rgid", frame, pointer),
            savedUID: credentials?.count == 6 ? credentials?[4] : try optionalInt(value, "svuid", frame, pointer),
            savedGID: credentials?.count == 6 ? credentials?[5] : try optionalInt(value, "svgid", frame, pointer),
            rawSHA: rawSHA)
        return id
    }

    private func insertObservabilityReceipt(
        frame: DisposalDecodedFrame,
        value: DisposalJSONValue,
        pointer: String,
        target: TargetContext
    ) throws -> String {
        let rawSHA = try rawSHA256(frame: frame, pointer: pointer)
        let id = disposalID(
            "disposal-process-receipt-v1",
            [frameIDs[frame.ordinal], target.id, pointer, rawSHA])
        try insertReceipt(
            id: id,
            frame: frame,
            targetID: target.id,
            observationKind: "JOINED",
            pid: target.pid,
            attempts: 1,
            uuidHex: try optionalString(value, "uuid_hex", frame, pointer),
            uniqueID: try optionalUnsigned(value, "unique_id", frame, pointer),
            idVersion: try optionalUnsigned(value, "idversion", frame, pointer),
            parentUniqueID: try optionalUnsigned(value, "parent_unique_id", frame, pointer),
            parentIDVersion: nil,
            parentPID: try optionalInt(value, "parent_pid", frame, pointer),
            pgid: try optionalInt(value, "pgid", frame, pointer),
            sid: try optionalInt(value, "sid", frame, pointer),
            status: try optionalInt(value, "status", frame, pointer),
            flags: try optionalInt(value, "flags", frame, pointer),
            commandHex: try optionalString(value, "command_hex", frame, pointer),
            uid: try optionalInt(value, "uid", frame, pointer),
            gid: try optionalInt(value, "gid", frame, pointer),
            realUID: try optionalInt(value, "real_uid", frame, pointer),
            realGID: try optionalInt(value, "real_gid", frame, pointer),
            savedUID: try optionalInt(value, "saved_uid", frame, pointer),
            savedGID: try optionalInt(value, "saved_gid", frame, pointer),
            rawSHA: rawSHA)
        return id
    }

    private func insertReceipt(
        id: String,
        frame: DisposalDecodedFrame,
        targetID: String?,
        observationKind: String,
        pid: Int,
        attempts: Int,
        uuidHex: String?,
        uniqueID: UInt64?,
        idVersion: UInt64?,
        parentUniqueID: UInt64?,
        parentIDVersion: UInt64?,
        parentPID: Int?,
        pgid: Int?,
        sid: Int?,
        status: Int?,
        flags: Int?,
        commandHex: String?,
        uid: Int?,
        gid: Int?,
        realUID: Int?,
        realGID: Int?,
        savedUID: Int?,
        savedGID: Int?,
        rawSHA: String
    ) throws {
        try disposalRequireProjection(pid > 0 && attempts > 0, "TYPED_RECEIPT_CARDINAL")
        if let uuidHex {
            try disposalRequireProjection(disposalIsLowerHex(uuidHex, count: 32), "TYPED_RECEIPT_UUID")
        }
        let statement = try database.prepare("INSERT INTO process_receipts VALUES(" + String(repeating: "?,", count: 23) + "?)")
        try statement.bind(1, text: id)
        try statement.bind(2, text: frameIDs[frame.ordinal])
        try statement.bind(3, text: targetID)
        try statement.bind(4, text: observationKind)
        try statement.bind(5, int: pid)
        try statement.bind(6, int: attempts)
        try statement.bind(7, text: uuidHex)
        try statement.bind(8, text: uniqueID.map(String.init))
        try statement.bind(9, text: idVersion.map(String.init))
        try statement.bind(10, text: parentUniqueID.map(String.init))
        try statement.bind(11, text: parentIDVersion.map(String.init))
        try statement.bind(12, optionalInt: parentPID)
        try statement.bind(13, optionalInt: pgid)
        try statement.bind(14, optionalInt: sid)
        try statement.bind(15, optionalInt: status)
        try statement.bind(16, optionalInt: flags)
        try statement.bind(17, text: commandHex)
        try statement.bind(18, optionalInt: uid)
        try statement.bind(19, optionalInt: gid)
        try statement.bind(20, optionalInt: realUID)
        try statement.bind(21, optionalInt: realGID)
        try statement.bind(22, optionalInt: savedUID)
        try statement.bind(23, optionalInt: savedGID)
        try statement.bind(24, text: rawSHA)
        try statement.stepDone()
        processReceiptIDs.append(id)
    }

    private func insertDomain(
        frame: DisposalDecodedFrame,
        value: DisposalJSONValue,
        pointer: String,
        kind: String,
        numericDomain: Int,
        target: TargetContext
    ) throws -> String {
        guard case .array(let members, _) = value else {
            throw rejection("TYPED_DOMAIN_ARRAY", frame, pointer)
        }
        try disposalRequireProjection(numericDomain > 1, "TYPED_DOMAIN_NUMERIC", frameOrdinal: frame.ordinal)
        let rawSHA = try rawSHA256(frame: frame, pointer: pointer)
        let id = disposalID(
            "disposal-domain-snapshot-v1",
            [frameIDs[frame.ordinal], target.id, kind, String(numericDomain), pointer, rawSHA])
        var memberIDs: [String] = []
        for index in members.indices {
            let memberPointer = pointer + "/\(index)"
            let member = members[index]
            let memberPID = try requiredInt(member, "pid", frame, memberPointer)
            let receiptTarget = memberPID == target.pid ? target : target
            memberIDs.append(try insertLegacyReceipt(
                frame: frame,
                value: member,
                pointer: memberPointer,
                target: receiptTarget,
                observationKind: "JOINED"))
        }
        let statement = try database.prepare("INSERT INTO domain_snapshots VALUES(?,?,?,?,?,?,?,?)")
        try statement.bind(1, text: id)
        try statement.bind(2, text: frameIDs[frame.ordinal])
        try statement.bind(3, text: target.id)
        try statement.bind(4, text: kind)
        try statement.bind(5, int: numericDomain)
        try statement.bind(6, text: members.isEmpty ? "EMPTY" : "JOINED")
        try statement.bind(7, int: members.count)
        try statement.bind(8, text: rawSHA)
        try statement.stepDone()
        domainSnapshotIDs.append(id)
        for (index, receiptID) in memberIDs.enumerated() {
            let member = try database.prepare("INSERT INTO domain_members VALUES(?,?,?)")
            try member.bind(1, text: id)
            try member.bind(2, int: index)
            try member.bind(3, text: receiptID)
            try member.stepDone()
        }
        return id
    }

    private func parseMerkleProof(
        value: DisposalJSONValue,
        frame: DisposalDecodedFrame,
        pointer: String
    ) throws -> [DisposalConservationMerkleProofNode] {
        guard case .array(let values, _) = value else {
            throw rejection("TYPED_MERKLE_PROOF_ARRAY", frame, pointer)
        }
        return try values.enumerated().map { index, node in
            let nodePointer = pointer + "/\(index)"
            try requireExactKeys(
                node,
                ["sibling_position", "sibling_sha256"],
                frame,
                nodePointer)
            let position = try requiredString(
                node, "sibling_position", frame, nodePointer)
            try disposalRequireProjection(
                position == "LEFT" || position == "RIGHT",
                "TYPED_MERKLE_PROOF_POSITION",
                frameOrdinal: frame.ordinal,
                detail: nodePointer)
            let sha = try requiredString(node, "sibling_sha256", frame, nodePointer)
            try requireLowerSHA256(sha, frame, nodePointer + "/sibling_sha256")
            return .init(siblingPosition: position, siblingSHA256: sha)
        }
    }

    private func requireExactKeys(
        _ value: DisposalJSONValue,
        _ expected: Set<String>,
        _ frame: DisposalDecodedFrame,
        _ pointer: String
    ) throws {
        guard case .object(let members, _) = value else {
            throw rejection("TYPED_EXACT_OBJECT", frame, pointer)
        }
        let observed = Set(members.map(\.key))
        try disposalRequireProjection(
            observed == expected && members.count == expected.count,
            "TYPED_EXACT_OBJECT_KEYS",
            frameOrdinal: frame.ordinal,
            detail: pointer)
    }

    private func requireExactString(
        _ object: DisposalJSONValue,
        _ key: String,
        _ expected: String,
        _ frame: DisposalDecodedFrame,
        _ pointer: String = "/payload"
    ) throws {
        let observed = try requiredString(object, key, frame, pointer)
        try disposalRequireProjection(
            observed == expected,
            "TYPED_EXACT_STRING",
            frameOrdinal: frame.ordinal,
            detail: pointer + "/" + key)
    }

    private func requireExactInt(
        _ object: DisposalJSONValue,
        _ key: String,
        _ expected: Int,
        _ frame: DisposalDecodedFrame,
        _ pointer: String
    ) throws {
        let observed = try requiredInt(object, key, frame, pointer)
        try disposalRequireProjection(
            observed == expected,
            "TYPED_EXACT_INTEGER",
            frameOrdinal: frame.ordinal,
            detail: pointer + "/" + key)
    }

    private func requireExactUnsigned(
        _ object: DisposalJSONValue,
        _ key: String,
        _ expected: UInt64,
        _ frame: DisposalDecodedFrame,
        _ pointer: String
    ) throws {
        let observed = try requiredUnsigned(object, key, frame, pointer)
        try disposalRequireProjection(
            observed == expected,
            "TYPED_EXACT_UNSIGNED",
            frameOrdinal: frame.ordinal,
            detail: pointer + "/" + key)
    }

    private func requireLowerSHA256(
        _ value: String,
        _ frame: DisposalDecodedFrame,
        _ pointer: String
    ) throws {
        try disposalRequireProjection(
            disposalIsLowerHex(value, count: 64),
            "TYPED_MERKLE_SHA256",
            frameOrdinal: frame.ordinal,
            detail: pointer)
    }

    private func requiredMember(
        _ object: DisposalJSONValue,
        _ key: String,
        _ frame: DisposalDecodedFrame,
        _ pointer: String
    ) throws -> DisposalJSONValue {
        guard let member = object.member(key) else {
            throw rejection("TYPED_REQUIRED_MEMBER", frame, pointer + "/" + key)
        }
        return member
    }

    private func requiredString(
        _ object: DisposalJSONValue,
        _ key: String,
        _ frame: DisposalDecodedFrame,
        _ pointer: String
    ) throws -> String {
        guard let value = object.member(key)?.stringValue() else {
            throw rejection("TYPED_REQUIRED_STRING", frame, pointer + "/" + key)
        }
        return value
    }

    private func optionalString(
        _ object: DisposalJSONValue,
        _ key: String,
        _ frame: DisposalDecodedFrame,
        _ pointer: String
    ) throws -> String? {
        guard let member = object.member(key) else { return nil }
        if case .null = member { return nil }
        guard let value = member.stringValue() else {
            throw rejection("TYPED_OPTIONAL_STRING", frame, pointer + "/" + key)
        }
        return value
    }

    private func requiredBoolean(
        _ object: DisposalJSONValue,
        _ key: String,
        _ frame: DisposalDecodedFrame,
        _ pointer: String
    ) throws -> Bool {
        guard let value = object.member(key)?.booleanValue() else {
            throw rejection("TYPED_REQUIRED_BOOLEAN", frame, pointer + "/" + key)
        }
        return value
    }

    private func requiredArray(
        _ object: DisposalJSONValue,
        _ key: String,
        _ frame: DisposalDecodedFrame,
        _ pointer: String
    ) throws -> [DisposalJSONValue] {
        guard let value = object.member(key), case .array(let result, _) = value else {
            throw rejection("TYPED_REQUIRED_ARRAY", frame, pointer + "/" + key)
        }
        return result
    }

    private func requiredInt(
        _ object: DisposalJSONValue,
        _ key: String,
        _ frame: DisposalDecodedFrame,
        _ pointer: String
    ) throws -> Int {
        try integer(try requiredMember(object, key, frame, pointer), frame, pointer + "/" + key)
    }

    private func optionalInt(
        _ object: DisposalJSONValue,
        _ key: String,
        _ frame: DisposalDecodedFrame,
        _ pointer: String
    ) throws -> Int? {
        guard let value = object.member(key) else { return nil }
        if case .null = value { return nil }
        return try integer(value, frame, pointer + "/" + key)
    }

    private func requiredUnsigned(
        _ object: DisposalJSONValue,
        _ key: String,
        _ frame: DisposalDecodedFrame,
        _ pointer: String
    ) throws -> UInt64 {
        try unsigned(try requiredMember(object, key, frame, pointer), frame, pointer + "/" + key)
    }

    private func optionalUnsigned(
        _ object: DisposalJSONValue,
        _ key: String,
        _ frame: DisposalDecodedFrame,
        _ pointer: String
    ) throws -> UInt64? {
        guard let value = object.member(key) else { return nil }
        if case .null = value { return nil }
        return try unsigned(value, frame, pointer + "/" + key)
    }

    private func optionalUnsignedText(
        _ object: DisposalJSONValue,
        _ key: String,
        _ frame: DisposalDecodedFrame,
        _ pointer: String
    ) throws -> String? {
        try optionalUnsigned(object, key, frame, pointer).map(String.init)
    }

    private func optionalIntegerArray(
        _ object: DisposalJSONValue,
        _ key: String,
        _ frame: DisposalDecodedFrame,
        _ pointer: String
    ) throws -> [Int]? {
        guard let value = object.member(key) else { return nil }
        if case .null = value { return nil }
        guard case .array(let values, _) = value else {
            throw rejection("TYPED_OPTIONAL_INT_ARRAY", frame, pointer + "/" + key)
        }
        return try values.enumerated().map {
            try integer($0.element, frame, pointer + "/" + key + "/\($0.offset)")
        }
    }

    private func integer(
        _ value: DisposalJSONValue,
        _ frame: DisposalDecodedFrame,
        _ pointer: String
    ) throws -> Int {
        guard let lexeme = value.numberLexeme(),
              let result = Int(lexeme),
              String(result) == lexeme
        else { throw rejection("TYPED_INTEGER", frame, pointer) }
        return result
    }

    private func unsigned(
        _ value: DisposalJSONValue,
        _ frame: DisposalDecodedFrame,
        _ pointer: String
    ) throws -> UInt64 {
        guard let lexeme = value.numberLexeme(),
              let result = UInt64(lexeme),
              String(result) == lexeme
        else { throw rejection("TYPED_UNSIGNED", frame, pointer) }
        return result
    }

    private func requireTrue(
        _ object: DisposalJSONValue,
        _ key: String,
        _ frame: DisposalDecodedFrame,
        pointer: String = "/payload"
    ) throws {
        try disposalRequireProjection(
            requiredBoolean(object, key, frame, pointer),
            "TYPED_REQUIRED_TRUE",
            frameOrdinal: frame.ordinal,
            detail: pointer + "/" + key)
    }

    private func requireFalse(
        _ object: DisposalJSONValue,
        _ key: String,
        _ frame: DisposalDecodedFrame,
        pointer: String = "/payload"
    ) throws {
        try disposalRequireProjection(
            !requiredBoolean(object, key, frame, pointer),
            "TYPED_REQUIRED_FALSE",
            frameOrdinal: frame.ordinal,
            detail: pointer + "/" + key)
    }

    private func rawSHA256(
        frame: DisposalDecodedFrame,
        pointer: String
    ) throws -> String {
        guard let sha256 = frame.node(at: pointer)?.rawSHA256 else {
            throw rejection("TYPED_SOURCE_POINTER_ABSENT", frame, pointer)
        }
        return sha256
    }

    private func rejection(
        _ code: String,
        _ frame: DisposalDecodedFrame,
        _ detail: String = ""
    ) -> DisposalProjectionRejection {
        .init(code: code, frameOrdinal: frame.ordinal, detail: detail)
    }
}
