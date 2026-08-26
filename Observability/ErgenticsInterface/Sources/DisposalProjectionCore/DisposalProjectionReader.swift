import Darwin
import DisposalProjectionPrimitivesC
import Foundation

public enum DisposalProjectionReader {
    public static func loadDefault() -> DisposalProjectionAvailability {
        load(environment: ProcessInfo.processInfo.environment)
    }

    public static func load(environment: [String: String]) -> DisposalProjectionAvailability {
        let root = environment["ERGENTICS_DISPOSAL_PROJECTION_ROOT"]
        let seal = environment["ERGENTICS_DISPOSAL_PROJECTION_SEAL_SHA256"]
        if root == nil && seal == nil { return .empty }
        guard let root, !root.isEmpty,
              let seal, disposalIsLowerHex(seal, count: 64)
        else {
            return .rejected(.init(
                code: "DISPOSAL_READER_ENVIRONMENT_PARTIAL",
                detail: "root and exact seal SHA-256 are both required"))
        }
        return load(rootPath: root, expectedSealSHA256: seal)
    }

    public static func load(
        rootPath: String,
        expectedSealSHA256: String
    ) -> DisposalProjectionAvailability {
        do {
            try disposalRequireProjection(
                disposalIsLowerHex(expectedSealSHA256, count: 64),
                "DISPOSAL_READER_EXPECTED_SEAL_SHA256")
            let held = try DisposalHeldProjectionSet(
                rootPath: rootPath,
                expectedSealSHA256: expectedSealSHA256)
            return .admitted(try disposalDecodeProjection(held))
        } catch is DisposalProjectionMissing {
            return .empty
        } catch let rejection as DisposalProjectionRejection {
            return .rejected(rejection)
        } catch let failure as DisposalSQLiteFailure {
            switch failure {
            case .rejected(let code, let detail):
                return .rejected(.init(code: code, detail: detail))
            }
        } catch {
            return .rejected(.init(
                code: "DISPOSAL_READER_INTERNAL",
                detail: String(describing: error)))
        }
    }
}

private struct DisposalProjectionMissing: Error {}

private struct DisposalSidecarDatabase {
    let applicationID: Int64
    let bytes: Int
    let projectionID: String
    let exportSHA256: String
    let sha256: String
}

private func disposalDecodeProjection(
    _ held: DisposalHeldProjectionSet
) throws -> DisposalProjectionSnapshot {
    var parser = DisposalCanonicalJSONParser(
        data: held.seal,
        frameOrdinal: -1,
        journalByteOffset: 0)
    let sidecar = try parser.parse()
    try disposalRequireProjection(
        sidecar.canonicalData() == held.seal,
        "DISPOSAL_READER_SEAL_NONCANONICAL")
    try disposalRequireProjection(
        try disposalReaderString(sidecar, "schema") ==
            "ergentics_disposal_projection_set_sidecar_v1",
        "DISPOSAL_READER_SEAL_SCHEMA")
    let status = try disposalReaderString(sidecar, "status")
    try disposalRequireProjection(
        [
            "PASS_NONAUTHORITATIVE_TERMINAL_PROJECTION",
            "ABSTAIN_NONTERMINAL_PREFIX_PROJECTION",
            "ABSTAIN_SEALED_SOURCE_NO_DISPOSAL_TERMINAL",
        ].contains(status),
        "DISPOSAL_READER_SEAL_STATUS")
    try disposalRequireProjection(
        try disposalReaderString(sidecar, "authority_vector") == "00000000",
        "DISPOSAL_READER_AUTHORITY_VECTOR")
    try disposalRequireProjection(
        try disposalReaderBoolean(sidecar, "authoritative") == false,
        "DISPOSAL_READER_AUTHORITATIVE")
    try disposalRequireProjection(
        try disposalReaderBoolean(sidecar, "may_feed_controller") == false,
        "DISPOSAL_READER_CONTROLLER_FEED")
    try disposalRequireProjection(
        try disposalReaderBoolean(sidecar, "prose_may_supply_fact") == false,
        "DISPOSAL_READER_PROSE_FACT")
    try disposalRequireProjection(
        try disposalReaderString(sidecar, "unavailable_behavior") ==
            "EMPTY_OR_EXPLICIT_ABSTAIN_NO_STALE_FALLBACK",
        "DISPOSAL_READER_UNAVAILABLE_BEHAVIOR")

    let projectionID = try disposalReaderLowerSHA(sidecar, "projection_id")
    let predecessor = try disposalReaderOptionalLowerSHA(
        sidecar, "predecessor_projection_id")
    let source = try disposalReaderObject(sidecar, "source")
    let sourceSHA256 = try disposalReaderLowerSHA(source, "sha256")
    let sourceBytes = try disposalReaderInt(source, "bytes")
    let frameCount = try disposalReaderInt(source, "frame_count")
    let sourceSealed = try disposalReaderBoolean(source, "is_source_sealed")
    let terminal = try disposalReaderBoolean(source, "is_terminal")
    let sourceKind = try disposalReaderString(source, "source_kind")
    let logicalPath = try disposalReaderString(source, "logical_path")
    try disposalRequireProjection(
        terminal == (status == "PASS_NONAUTHORITATIVE_TERMINAL_PROJECTION"),
        "DISPOSAL_READER_STATUS_TERMINAL_JOIN")

    let databases = try disposalReaderObject(sidecar, "databases")
    let evidenceSidecar = try disposalReaderDatabase(databases, role: "evidence")
    let metricsSidecar = try disposalReaderDatabase(databases, role: "metrics")
    let graphSidecar = try disposalReaderDatabase(databases, role: "graph")
    try disposalValidateSidecarDatabase(
        evidenceSidecar, bytes: held.evidence, expectedApplicationID: 1_162_105_649)
    try disposalValidateSidecarDatabase(
        metricsSidecar, bytes: held.metrics, expectedApplicationID: 1_162_104_113)
    try disposalValidateSidecarDatabase(
        graphSidecar, bytes: held.graph, expectedApplicationID: 1_162_102_577)

    let evidence = try DisposalSQLiteConnection(serializedReadOnly: held.evidence)
    let metrics = try DisposalSQLiteConnection(serializedReadOnly: held.metrics)
    let graph = try DisposalSQLiteConnection(serializedReadOnly: held.graph)
    try disposalValidateDatabase(
        evidence,
        applicationID: evidenceSidecar.applicationID,
        policySchema: "ergentics_disposal_evidence_v1",
        sealTable: "evidence_seal",
        projectionID: evidenceSidecar.projectionID)
    try disposalValidateDatabase(
        metrics,
        applicationID: metricsSidecar.applicationID,
        policySchema: "ergentics_disposal_metrics_v1",
        sealTable: "metrics_seal",
        projectionID: metricsSidecar.projectionID)
    try disposalValidateDatabase(
        graph,
        applicationID: graphSidecar.applicationID,
        policySchema: "ergentics_disposal_graph_v1",
        sealTable: "graph_seal",
        projectionID: graphSidecar.projectionID)

    let artifact = try evidence.prepare(
        "SELECT a.logical_path,a.byte_count,a.raw_sha256,a.raw_bytes " +
            "FROM input_artifacts a JOIN invocations i ON i.source_artifact_id=a.artifact_id")
    try disposalRequireProjection(
        try artifact.step(), "DISPOSAL_READER_SOURCE_ARTIFACT_ABSENT")
    let embeddedLogicalPath = try disposalReaderRequiredText(artifact, 0, "SOURCE_LOGICAL_PATH")
    let embeddedBytes = Int(artifact.int64(1))
    let embeddedSHA256 = try disposalReaderRequiredText(artifact, 2, "SOURCE_SHA256")
    guard let journal = artifact.data(3) else {
        throw DisposalProjectionRejection(code: "DISPOSAL_READER_SOURCE_BYTES")
    }
    try disposalRequireProjection(
        !(try artifact.step()), "DISPOSAL_READER_SOURCE_ARTIFACT_MULTIPLE")
    try disposalRequireProjection(
        embeddedLogicalPath == logicalPath && embeddedBytes == sourceBytes &&
            embeddedSHA256 == sourceSHA256 && journal.count == sourceBytes &&
            disposalSHA256(journal) == sourceSHA256,
        "DISPOSAL_READER_SOURCE_JOIN")

    let reconstructed = try DisposalProjectionSetBuilder.makeMaterial(request: .init(
        journal: journal,
        journalLogicalPath: logicalPath,
        predecessorProjectionID: predecessor))
    try disposalRequireProjection(
        reconstructed.projectionID == projectionID,
        "DISPOSAL_READER_PROJECTION_RECONSTRUCTED_ID")
    try disposalRequireProjection(
        reconstructed.evidence == held.evidence,
        "DISPOSAL_READER_EVIDENCE_RECONSTRUCTED_BYTES")
    try disposalRequireProjection(
        reconstructed.metrics == held.metrics,
        "DISPOSAL_READER_METRICS_RECONSTRUCTED_BYTES")
    try disposalRequireProjection(
        reconstructed.graph == held.graph,
        "DISPOSAL_READER_GRAPH_RECONSTRUCTED_BYTES")
    try disposalRequireProjection(
        reconstructed.seal == held.seal,
        "DISPOSAL_READER_SEAL_RECONSTRUCTED_BYTES")
    try disposalRequireProjection(
        reconstructed.frameCount == frameCount && reconstructed.terminal == terminal,
        "DISPOSAL_READER_SOURCE_RECONSTRUCTED_COUNTS")

    try disposalRequireProjection(
        try metrics.scalarText(
            "SELECT evidence_database_sha256 FROM evidence_input WHERE singleton=1") ==
            evidenceSidecar.sha256,
        "DISPOSAL_READER_EVIDENCE_METRICS_JOIN")
    try disposalRequireProjection(
        try graph.scalarInt(
            "SELECT count(*) FROM input_databases WHERE " +
                "(database_role='EVIDENCE' AND database_sha256='\(evidenceSidecar.sha256)') OR " +
                "(database_role='METRICS' AND database_sha256='\(metricsSidecar.sha256)')") == 2,
        "DISPOSAL_READER_GRAPH_INPUT_JOIN")

    let decodedJournal = try DisposalProjectionSourceAdapter.decode(journal)
    try disposalRequireProjection(
        decodedJournal.sourceKind.rawValue == sourceKind &&
            decodedJournal.sourceSealed == sourceSealed &&
            decodedJournal.isTerminal == terminal,
        "DISPOSAL_READER_SOURCE_KIND_SEAL_TERMINAL_JOIN")
    let frames = try disposalReadFrames(evidence, decoded: decodedJournal)
    let processRows = try disposalReadProcessRows(evidence)
    let riskWindows = try disposalReadRiskWindows(evidence)
    let missing = try disposalReadMissingEvidence(evidence)
    let metricRows = try disposalReadMetrics(metrics)
    let graphNodes = try disposalReadGraphNodes(graph)
    let graphEdges = try disposalReadGraphEdges(graph)
    let machineStates = try disposalReadMachineStates(graph)
    let machineTransitions = try disposalReadMachineTransitions(graph)
    let machineWitnesses = try disposalReadMachineWitnesses(graph)
    let machinePredicates = try disposalReadMachinePredicates(graph)
    let machineMerkleLeaves = try disposalReadMachineMerkleLeaves(graph)
    let machineEdges = try disposalReadMachineEdges(graph)
    let sourceConservationSets = try disposalReadSourceConservationSets(evidence)
    let sourceConservationMemberships = try disposalReadSourceConservationMemberships(evidence)
    let sourceConservationProofNodes = try disposalReadSourceConservationProofNodes(evidence)
    let sourceConservationMappings = try disposalReadSourceConservationMappings(evidence)
    try disposalValidateSourceConservationSemanticRoundTrip(
        sets: sourceConservationSets,
        memberships: sourceConservationMemberships,
        proofNodes: sourceConservationProofNodes,
        mappings: sourceConservationMappings,
        requiresCompleteMappingCoverage: machineTransitions.contains {
            $0.matchedRuleID == "D50" || $0.matchedRuleID == "D60"
        })
    let sampleCount = Int(try metrics.scalarInt("SELECT count(*) FROM rusage_samples"))

    return .init(
        metadata: .init(
            projectionID: projectionID,
            sourceSHA256: sourceSHA256,
            sourceBytes: sourceBytes,
            frameCount: frameCount,
            sourceKind: sourceKind,
            sourceSealed: sourceSealed,
            terminal: terminal,
            status: status,
            evidenceSHA256: evidenceSidecar.sha256,
            metricsSHA256: metricsSidecar.sha256,
            graphSHA256: graphSidecar.sha256,
            sealSHA256: disposalSHA256(held.seal),
            predecessorProjectionID: predecessor,
            authorityVector: "00000000",
            authoritative: false,
            mayFeedController: false),
        counts: .init(
            frames: frames.count,
            processRows: processRows.count,
            riskWindows: riskWindows.count,
            missingEvidence: missing.count,
            samples: sampleCount,
            metrics: metricRows.count,
            graphNodes: graphNodes.count,
            graphEdges: graphEdges.count,
            machineStates: machineStates.count,
            machineTransitions: machineTransitions.count,
            machineWitnesses: machineWitnesses.count,
            machinePredicates: machinePredicates.count,
            machineMerkleLeaves: machineMerkleLeaves.count,
            machineEdges: machineEdges.count,
            sourceConservationSets: sourceConservationSets.count,
            sourceConservationMemberships: sourceConservationMemberships.count,
            sourceConservationProofNodes: sourceConservationProofNodes.count,
            sourceConservationMappings: sourceConservationMappings.count),
        frames: frames,
        processRows: processRows,
        riskWindows: riskWindows,
        missingEvidence: missing,
        metrics: metricRows,
        graphNodes: graphNodes,
        graphEdges: graphEdges,
        machineStates: machineStates,
        machineTransitions: machineTransitions,
        machineWitnesses: machineWitnesses,
        machinePredicates: machinePredicates,
        machineMerkleLeaves: machineMerkleLeaves,
        machineEdges: machineEdges,
        sourceConservationSets: sourceConservationSets,
        sourceConservationMemberships: sourceConservationMemberships,
        sourceConservationProofNodes: sourceConservationProofNodes,
        sourceConservationMappings: sourceConservationMappings)
}

private func disposalValidateSidecarDatabase(
    _ sidecar: DisposalSidecarDatabase,
    bytes: Data,
    expectedApplicationID: Int64
) throws {
    try disposalRequireProjection(
        sidecar.applicationID == expectedApplicationID,
        "DISPOSAL_READER_SIDECAR_APPLICATION_ID")
    try disposalRequireProjection(
        sidecar.bytes == bytes.count,
        "DISPOSAL_READER_SIDECAR_DATABASE_BYTES")
    try disposalRequireProjection(
        disposalSHA256(bytes) == sidecar.sha256,
        "DISPOSAL_READER_SIDECAR_DATABASE_SHA256")
}

private func disposalValidateDatabase(
    _ database: DisposalSQLiteConnection,
    applicationID: Int64,
    policySchema: String,
    sealTable: String,
    projectionID: String
) throws {
    try disposalRequireProjection(
        try database.scalarText("PRAGMA quick_check") == "ok",
        "DISPOSAL_READER_QUICK_CHECK")
    try disposalRequireProjection(
        try database.scalarInt("SELECT count(*) FROM pragma_foreign_key_check") == 0,
        "DISPOSAL_READER_FOREIGN_KEY_CHECK")
    try disposalRequireProjection(
        try database.scalarInt("PRAGMA application_id") == applicationID,
        "DISPOSAL_READER_APPLICATION_ID")
    try disposalRequireProjection(
        try database.scalarInt("PRAGMA user_version") == 1,
        "DISPOSAL_READER_USER_VERSION")
    let policy = try database.prepare(
        "SELECT count(*) FROM projection_policy WHERE singleton=1 AND " +
            "projection_schema=? AND authority_vector='00000000' AND " +
            "authoritative=0 AND may_feed_controller=0 AND prose_may_supply_fact=0 AND " +
            "unavailable_behavior='EMPTY_OR_EXPLICIT_ABSTAIN_NO_STALE_FALLBACK'")
    try policy.bind(1, text: policySchema)
    try disposalRequireProjection(
        try policy.step() && policy.int64(0) == 1 && !(try policy.step()),
        "DISPOSAL_READER_POLICY")
    let seal = try database.prepare(
        "SELECT count(*) FROM \(sealTable) WHERE singleton=1 AND projection_id=? AND " +
            "authority_vector='00000000' AND authoritative=0 AND may_feed_controller=0")
    try seal.bind(1, text: projectionID)
    try disposalRequireProjection(
        try seal.step() && seal.int64(0) == 1 && !(try seal.step()),
        "DISPOSAL_READER_DATABASE_SEAL")
}

private func disposalReadFrames(
    _ database: DisposalSQLiteConnection,
    decoded: DisposalDecodedJournal
) throws -> [DisposalFramePresentation] {
    let statement = try database.prepare(
        "SELECT frame_id,ordinal,raw_json,raw_sha256_no_lf,raw_sha256_with_lf," +
            "payload_sha256,schema_text,status_text FROM frames ORDER BY ordinal")
    var rows: [DisposalFramePresentation] = []
    while try statement.step() {
        let ordinal = Int(statement.int64(1))
        try disposalRequireProjection(
            ordinal == rows.count && ordinal < decoded.frames.count,
            "DISPOSAL_READER_FRAME_ORDINAL")
        guard let raw = statement.data(2), let rawJSON = String(data: raw, encoding: .utf8) else {
            throw DisposalProjectionRejection(code: "DISPOSAL_READER_FRAME_RAW")
        }
        let source = decoded.frames[ordinal]
        rows.append(.init(
            id: try disposalReaderRequiredText(statement, 0, "FRAME_ID"),
            ordinal: ordinal,
            eventType: source.eventType.rawValue,
            phase: source.phase,
            targetLabel: source.targetLabel,
            status: statement.optionalText(7),
            schema: try disposalReaderRequiredText(statement, 6, "FRAME_SCHEMA"),
            rawSHA256: try disposalReaderRequiredText(statement, 3, "FRAME_SHA"),
            rawWithLFSHA256: try disposalReaderRequiredText(statement, 4, "FRAME_LF_SHA"),
            payloadSHA256: try disposalReaderRequiredText(statement, 5, "FRAME_PAYLOAD_SHA"),
            rawJSON: rawJSON))
    }
    try disposalRequireProjection(
        rows.count == decoded.frames.count,
        "DISPOSAL_READER_FRAME_COUNT")
    return rows
}

private struct DisposalProcessQuery {
    let category: String
    let sql: String
    let fieldKeys: [String]
}

private func disposalReadProcessRows(
    _ database: DisposalSQLiteConnection
) throws -> [DisposalProcessPresentation] {
    let queries = [
        DisposalProcessQuery(
            category: "TARGET",
            sql: "SELECT target_id,NULL,target_id,target_form,target_role,numeric_pid,expected_uniqueid_text,expected_idversion_text,expected_sid,expected_pgid,expected_uuid_hex FROM targets",
            fieldKeys: ["target_role","numeric_pid","expected_uniqueid","expected_idversion","expected_sid","expected_pgid","expected_uuid_hex"]),
        DisposalProcessQuery(
            category: "PROCESS_RECEIPT",
            sql: "SELECT receipt_id,source_frame_id,target_id,observation_kind,pid,attempt_count,uniqueid_text,idversion_text,ppid,pgid,sid,process_status,uuid_hex FROM process_receipts",
            fieldKeys: ["pid","attempt_count","uniqueid","idversion","ppid","pgid","sid","process_status","uuid_hex"]),
        DisposalProcessQuery(
            category: "VNODE_JOIN",
            sql: "SELECT v.join_id,v.source_frame_id,r.target_id,v.join_state,v.join_kind,v.observed_path,v.observed_device_text,v.observed_inode_text,v.held_device_text,v.held_inode_text,v.named_device_text,v.named_inode_text FROM vnode_joins v JOIN process_receipts r ON r.receipt_id=v.receipt_id",
            fieldKeys: ["join_kind","observed_path","observed_device","observed_inode","held_device","held_inode","named_device","named_inode"]),
        DisposalProcessQuery(
            category: "DOMAIN_SNAPSHOT",
            sql: "SELECT domain_snapshot_id,source_frame_id,target_id,snapshot_result,domain_kind,numeric_domain,member_count,members_sha256 FROM domain_snapshots",
            fieldKeys: ["domain_kind","numeric_domain","member_count","members_sha256"]),
        DisposalProcessQuery(
            category: "TARGET_SNAPSHOT",
            sql: "SELECT snapshot_id,source_frame_id,target_id,snapshot_kind,snapshot_phase,receipt_id,image_join_id,cwd_join_id,group_snapshot_id,session_snapshot_id,snapshot_sha256 FROM target_snapshots",
            fieldKeys: ["snapshot_phase","receipt_id","image_join_id","cwd_join_id","group_snapshot_id","session_snapshot_id","snapshot_sha256"]),
        DisposalProcessQuery(
            category: "SNAPSHOT_PAIR",
            sql: "SELECT pair_id,source_frame_id,target_id,equality_state,pair_phase,evidence_shape,first_snapshot_id,second_snapshot_id,certificate_sha256,issued_monotonic_ns_text,maximum_age_ns_text FROM snapshot_pairs",
            fieldKeys: ["pair_phase","evidence_shape","first_snapshot_id","second_snapshot_id","certificate_sha256","issued_monotonic_ns","maximum_age_ns"]),
        DisposalProcessQuery(
            category: "NAMESPACE",
            sql: "SELECT namespace_observation_id,source_frame_id,NULL,observation_state,namespace_kind,artifact_id,inventory_sha256 FROM namespace_observations",
            fieldKeys: ["namespace_kind","artifact_id","inventory_sha256"]),
        DisposalProcessQuery(
            category: "COMMITMENT",
            sql: "SELECT commitment_id,source_frame_id,target_id,operation,target_form,numeric_argument,signal_number,prestate_pair_id,prestate_sha256,budget_ordinal,call_may_enter_after_record,missing_result_means_may_have_entered,retry_authorized FROM commitments",
            fieldKeys: ["target_form","numeric_argument","signal_number","prestate_pair_id","prestate_sha256","budget_ordinal","call_may_enter_after_record","missing_result_means_may_have_entered","retry_authorized"]),
        DisposalProcessQuery(
            category: "SIGNAL_CALL",
            sql: "SELECT s.signal_call_id,s.source_frame_id,c.target_id,s.delivery_class,s.entry_state,s.return_state,s.numeric_argument,s.signal_number,s.return_value,s.errno_value,s.certificate_age_ns_text,s.certificate_max_age_ns_text FROM signal_calls s JOIN commitments c ON c.commitment_id=s.commitment_id",
            fieldKeys: ["entry_state","return_state","numeric_argument","signal_number","return_value","errno_value","certificate_age_ns","certificate_max_age_ns"]),
        DisposalProcessQuery(
            category: "SIGNAL_ZERO",
            sql: "SELECT signal_zero_call_id,source_frame_id,target_id,result_class,entry_state,return_state,numeric_argument,return_value,errno_value FROM signal_zero_calls",
            fieldKeys: ["entry_state","return_state","numeric_argument","return_value","errno_value"]),
        DisposalProcessQuery(
            category: "WAIT",
            sql: "SELECT wait_call_id,source_frame_id,target_id,return_state,wait_ownership,wait_api,options_text,entry_state,requested_pid,returned_pid,return_value,errno_value FROM wait_calls",
            fieldKeys: ["wait_ownership","wait_api","options","entry_state","requested_pid","returned_pid","return_value","errno_value"]),
        DisposalProcessQuery(
            category: "REAP",
            sql: "SELECT reap_id,source_frame_id,target_id,CASE WHEN exited=1 THEN 'EXITED' ELSE 'SIGNALED' END,returned_pid,raw_wait_status,exited,exit_status,signaled,termination_signal,core_dumped,exact_wait_owner_join FROM reap_results",
            fieldKeys: ["returned_pid","raw_wait_status","exited","exit_status","signaled","termination_signal","core_dumped","exact_wait_owner_join"]),
        DisposalProcessQuery(
            category: "ABSENCE_PROOF",
            sql: "SELECT absence_proof_id,source_frame_id,target_id,proof_kind,attempt_detail_availability,transient_fault_count,discarded_candidate_round_count,required_consecutive_rounds FROM absence_proofs",
            fieldKeys: ["attempt_detail_availability","transient_fault_count","discarded_candidate_round_count","required_consecutive_rounds"]),
        DisposalProcessQuery(
            category: "CONSERVATION",
            sql: "SELECT conservation_id,source_frame_id,target_id,completion_state,conservation_basis,absence_proof_id,reap_id,exact_reap_required,exact_reap_satisfied,generation_absent,group_empty,session_empty,two_signal_zero_esrch FROM conservations",
            fieldKeys: ["conservation_basis","absence_proof_id","reap_id","exact_reap_required","exact_reap_satisfied","generation_absent","group_empty","session_empty","two_signal_zero_esrch"]),
        DisposalProcessQuery(
            category: "TERMINAL",
            sql: "SELECT terminal_outcome_id,terminal_frame_id,NULL,completion_class,status_text,exit_code,capture_state,gate_c_conservation_id,guardian_conservation_id,wrapper_conservation_id,fixture_conservation_id,gate_e_outcome,authority_vector FROM terminal_outcomes",
            fieldKeys: ["status","exit_code","capture_state","gate_c_conservation_id","guardian_conservation_id","wrapper_conservation_id","fixture_conservation_id","gate_e_outcome","authority_vector"]),
    ]
    var rows: [DisposalProcessPresentation] = []
    for query in queries {
        let statement = try database.prepare(query.sql)
        while try statement.step() {
            let id = try disposalReaderRequiredText(statement, 0, "PROCESS_ROW_ID")
            rows.append(.init(
                id: query.category + ":" + id,
                category: query.category,
                sourceFrameID: statement.optionalText(1),
                targetID: statement.optionalText(2),
                exactState: statement.optionalText(3) ?? "ABSENT",
                fields: query.fieldKeys.enumerated().map { index, key in
                    .init(key: key, value: statement.optionalText(Int32(index + 4)))
                }))
        }
    }
    return rows.sorted {
        if $0.category != $1.category { return $0.category < $1.category }
        return $0.id < $1.id
    }
}

private func disposalReadRiskWindows(
    _ database: DisposalSQLiteConnection
) throws -> [DisposalRiskWindowPresentation] {
    let statement = try database.prepare(
        "SELECT window_id,source_frame_id,target_id,window_kind,basis,closure_state," +
            "maximum_duration_ns_text,qualification_text FROM risk_windows ORDER BY window_id")
    var rows: [DisposalRiskWindowPresentation] = []
    while try statement.step() {
        rows.append(.init(
            id: try disposalReaderRequiredText(statement, 0, "WINDOW_ID"),
            sourceFrameID: try disposalReaderRequiredText(statement, 1, "WINDOW_FRAME"),
            targetID: statement.optionalText(2),
            kind: try disposalReaderRequiredText(statement, 3, "WINDOW_KIND"),
            basis: try disposalReaderRequiredText(statement, 4, "WINDOW_BASIS"),
            closureState: try disposalReaderRequiredText(statement, 5, "WINDOW_CLOSURE"),
            maximumDurationNanoseconds: statement.optionalText(6),
            qualification: try disposalReaderRequiredText(statement, 7, "WINDOW_QUALIFICATION")))
    }
    return rows
}

private func disposalReadMissingEvidence(
    _ database: DisposalSQLiteConnection
) throws -> [DisposalMissingEvidencePresentation] {
    let statement = try database.prepare(
        "SELECT missing_id,evidence_kind,target_role,source_frame_id,reason_code,value_state " +
            "FROM missing_evidence ORDER BY missing_id")
    var rows: [DisposalMissingEvidencePresentation] = []
    while try statement.step() {
        rows.append(.init(
            id: try disposalReaderRequiredText(statement, 0, "MISSING_ID"),
            evidenceKind: try disposalReaderRequiredText(statement, 1, "MISSING_KIND"),
            targetRole: statement.optionalText(2),
            sourceFrameID: statement.optionalText(3),
            reasonCode: try disposalReaderRequiredText(statement, 4, "MISSING_REASON"),
            valueState: try disposalReaderRequiredText(statement, 5, "MISSING_STATE")))
    }
    return rows
}

private func disposalReadMetrics(
    _ database: DisposalSQLiteConnection
) throws -> [DisposalMetricPresentation] {
    let statement = try database.prepare(
        "SELECT metric_id,interval_id,metric_name,bound_kind,numerator_text," +
            "denominator_text,unit,approximation_text,source_grade,premise_state,source_pointer " +
            "FROM metric_facts ORDER BY metric_name,bound_kind,metric_id")
    var rows: [DisposalMetricPresentation] = []
    while try statement.step() {
        let metricID = try disposalReaderRequiredText(statement, 0, "METRIC_ID")
        let qualificationsStatement = try database.prepare(
            "SELECT qualification_key,exact_value FROM metric_qualifications " +
                "WHERE metric_id=? ORDER BY qualification_key,exact_value")
        try qualificationsStatement.bind(1, text: metricID)
        var qualifications: [DisposalExactField] = []
        while try qualificationsStatement.step() {
            let key = try disposalReaderRequiredText(
                qualificationsStatement, 0, "QUALIFICATION_KEY")
            let value = try disposalReaderRequiredText(
                qualificationsStatement, 1, "QUALIFICATION_VALUE")
            qualifications.append(.init(
                key: key + ":" + value,
                value: value))
        }
        rows.append(.init(
            id: metricID,
            intervalID: try disposalReaderRequiredText(statement, 1, "METRIC_INTERVAL"),
            name: try disposalReaderRequiredText(statement, 2, "METRIC_NAME"),
            bound: try disposalReaderRequiredText(statement, 3, "METRIC_BOUND"),
            numerator: try disposalReaderRequiredText(statement, 4, "METRIC_NUMERATOR"),
            denominator: try disposalReaderRequiredText(statement, 5, "METRIC_DENOMINATOR"),
            unit: try disposalReaderRequiredText(statement, 6, "METRIC_UNIT"),
            approximation: statement.optionalText(7),
            sourceGrade: try disposalReaderRequiredText(statement, 8, "METRIC_GRADE"),
            premise: try disposalReaderRequiredText(statement, 9, "METRIC_PREMISE"),
            sourcePointer: try disposalReaderRequiredText(statement, 10, "METRIC_POINTER"),
            qualifications: qualifications))
    }
    return rows
}

private func disposalReadGraphNodes(
    _ database: DisposalSQLiteConnection
) throws -> [DisposalGraphNodePresentation] {
    let statement = try database.prepare(
        "SELECT node_id,node_kind,canonical_key,display_label,source_database_role," +
            "source_row_id FROM ui_graph_nodes")
    var rows: [DisposalGraphNodePresentation] = []
    while try statement.step() {
        rows.append(.init(
            id: try disposalReaderRequiredText(statement, 0, "GRAPH_NODE_ID"),
            kind: try disposalReaderRequiredText(statement, 1, "GRAPH_NODE_KIND"),
            canonicalKey: try disposalReaderRequiredText(statement, 2, "GRAPH_NODE_KEY"),
            label: try disposalReaderRequiredText(statement, 3, "GRAPH_NODE_LABEL"),
            sourceDatabaseRole: try disposalReaderRequiredText(statement, 4, "GRAPH_NODE_ROLE"),
            sourceRowID: try disposalReaderRequiredText(statement, 5, "GRAPH_NODE_ROW")))
    }
    return rows
}

private func disposalReadGraphEdges(
    _ database: DisposalSQLiteConnection
) throws -> [DisposalGraphEdgePresentation] {
    let statement = try database.prepare(
        "SELECT edge_id,from_node_id,predicate,to_node_id,source_database_role," +
            "source_row_id,source_pointer,evidence_grade FROM ui_graph_edges")
    var rows: [DisposalGraphEdgePresentation] = []
    while try statement.step() {
        rows.append(.init(
            id: try disposalReaderRequiredText(statement, 0, "GRAPH_EDGE_ID"),
            fromNodeID: try disposalReaderRequiredText(statement, 1, "GRAPH_EDGE_FROM"),
            predicate: try disposalReaderRequiredText(statement, 2, "GRAPH_EDGE_PREDICATE"),
            toNodeID: try disposalReaderRequiredText(statement, 3, "GRAPH_EDGE_TO"),
            sourceDatabaseRole: try disposalReaderRequiredText(statement, 4, "GRAPH_EDGE_ROLE"),
            sourceRowID: try disposalReaderRequiredText(statement, 5, "GRAPH_EDGE_ROW"),
            sourcePointer: statement.optionalText(6),
            evidenceGrade: try disposalReaderRequiredText(statement, 7, "GRAPH_EDGE_GRADE")))
    }
    return rows
}

private func disposalReadMachineStates(
    _ database: DisposalSQLiteConnection
) throws -> [DisposalMachineStatePresentation] {
    let statement = try database.prepare(
        "SELECT state_id,prefix_ordinal,predecessor_state_id,ancestry_sha256," +
            "high_water_frame_node_id,high_water_frame_lf_sha256,matched_rule_id," +
            "predicate_vector_sha256,state_class," +
            "derived_post_hoc_witness_merkle_root_sha256," +
            "derived_post_hoc_witness_leaf_count,merkle_algorithm,merkle_domain_tag," +
            "merkle_leaf_ordering,merkle_duplicate_policy,merkle_odd_leaf_rule " +
            "FROM ui_state_machine_states ORDER BY prefix_ordinal")
    var rows: [DisposalMachineStatePresentation] = []
    while try statement.step() {
        rows.append(.init(
            id: try disposalReaderRequiredText(statement, 0, "MACHINE_STATE_ID"),
            prefixOrdinal: Int(statement.int64(1)),
            predecessorStateID: statement.optionalText(2),
            ancestrySHA256: try disposalReaderRequiredText(statement, 3, "MACHINE_ANCESTRY"),
            highWaterFrameNodeID: statement.optionalText(4),
            highWaterFrameLFSHA256: statement.optionalText(5),
            matchedRuleID: try disposalReaderRequiredText(statement, 6, "MACHINE_STATE_RULE"),
            predicateVectorSHA256: try disposalReaderRequiredText(
                statement, 7, "MACHINE_STATE_PREDICATES"),
            stateClass: try disposalReaderRequiredText(statement, 8, "MACHINE_STATE_CLASS"),
            derivedWitnessMerkleRootSHA256: try disposalReaderRequiredText(
                statement, 9, "MACHINE_STATE_MERKLE_ROOT"),
            derivedWitnessLeafCount: Int(statement.int64(10)),
            merkleAlgorithm: try disposalReaderRequiredText(
                statement, 11, "MACHINE_STATE_MERKLE_ALGORITHM"),
            merkleDomainTag: try disposalReaderRequiredText(
                statement, 12, "MACHINE_STATE_MERKLE_DOMAIN"),
            merkleLeafOrdering: try disposalReaderRequiredText(
                statement, 13, "MACHINE_STATE_MERKLE_ORDER"),
            merkleDuplicatePolicy: try disposalReaderRequiredText(
                statement, 14, "MACHINE_STATE_MERKLE_DUPLICATE"),
            merkleOddLeafRule: try disposalReaderRequiredText(
                statement, 15, "MACHINE_STATE_MERKLE_ODD")))
    }
    return rows
}

private func disposalReadMachineTransitions(
    _ database: DisposalSQLiteConnection
) throws -> [DisposalMachineTransitionPresentation] {
    let statement = try database.prepare(
        "SELECT transition_id,from_state_id,to_state_id,accepted_frame_node_id," +
            "accepted_frame_lf_sha256,matched_rule_id,state_class," +
            "predicate_vector_sha256,derived_post_hoc_source_set_sha256," +
            "predecessor_derived_post_hoc_witness_merkle_root_sha256," +
            "predecessor_derived_post_hoc_witness_leaf_count," +
            "preconservation_merkle_committed,preconservation_commitment_witness_id " +
            "FROM ui_state_machine_transitions ORDER BY transition_id")
    var rows: [DisposalMachineTransitionPresentation] = []
    while try statement.step() {
        rows.append(.init(
            id: try disposalReaderRequiredText(statement, 0, "MACHINE_TRANSITION_ID"),
            fromStateID: try disposalReaderRequiredText(statement, 1, "MACHINE_FROM_STATE"),
            toStateID: try disposalReaderRequiredText(statement, 2, "MACHINE_TO_STATE"),
            acceptedFrameNodeID: try disposalReaderRequiredText(
                statement, 3, "MACHINE_ACCEPTED_FRAME"),
            acceptedFrameLFSHA256: try disposalReaderRequiredText(
                statement, 4, "MACHINE_ACCEPTED_FRAME_SHA"),
            matchedRuleID: try disposalReaderRequiredText(statement, 5, "MACHINE_RULE"),
            stateClass: try disposalReaderRequiredText(statement, 6, "MACHINE_CLASS"),
            predicateVectorSHA256: try disposalReaderRequiredText(
                statement, 7, "MACHINE_PREDICATE_VECTOR"),
            derivedSourceSetSHA256: try disposalReaderRequiredText(
                statement, 8, "MACHINE_SOURCE_SET"),
            predecessorWitnessMerkleRootSHA256: try disposalReaderRequiredText(
                statement, 9, "MACHINE_PREDECESSOR_MERKLE"),
            predecessorWitnessLeafCount: Int(statement.int64(10)),
            preconservationMerkleCommitted: try disposalReaderRequiredText(
                statement, 11, "MACHINE_PRECONSERVATION_MERKLE"),
            preconservationCommitmentWitnessID: statement.optionalText(12)))
    }
    return rows
}

private func disposalReadMachineWitnesses(
    _ database: DisposalSQLiteConnection
) throws -> [DisposalMachineWitnessPresentation] {
    let statement = try database.prepare(
        "SELECT witness_id,witness_kind,source_table,source_row_id,exact_row_sha256," +
            "normalized_fact_sha256,intrinsic_source_frame_lf_sha256," +
            "source_frame_node_id,visible_prefix_ordinal " +
            "FROM ui_state_machine_witnesses ORDER BY visible_prefix_ordinal,witness_id")
    var rows: [DisposalMachineWitnessPresentation] = []
    while try statement.step() {
        rows.append(.init(
            id: try disposalReaderRequiredText(statement, 0, "MACHINE_WITNESS_ID"),
            kind: try disposalReaderRequiredText(statement, 1, "MACHINE_WITNESS_KIND"),
            sourceTable: try disposalReaderRequiredText(statement, 2, "MACHINE_WITNESS_TABLE"),
            sourceRowID: try disposalReaderRequiredText(statement, 3, "MACHINE_WITNESS_ROW"),
            exactRowSHA256: try disposalReaderRequiredText(
                statement, 4, "MACHINE_WITNESS_EXACT_SHA"),
            normalizedFactSHA256: try disposalReaderRequiredText(
                statement, 5, "MACHINE_WITNESS_FACT_SHA"),
            intrinsicSourceFrameLFSHA256: statement.optionalText(6),
            sourceFrameNodeID: statement.optionalText(7),
            visiblePrefixOrdinal: Int(statement.int64(8))))
    }
    return rows
}

private func disposalReadMachinePredicates(
    _ database: DisposalSQLiteConnection
) throws -> [DisposalMachinePredicatePresentation] {
    let statement = try database.prepare(
        "SELECT transition_id,predicate_ordinal,rule_ordinal,rule_id,clause_ordinal," +
            "predicate_clause,normalized_lhs,normalized_operator,normalized_rhs," +
            "actual_scalar,normalized_state,source_count,source_set_sha256," +
            "predicate_sha256 FROM machine_transition_predicates " +
            "ORDER BY transition_id,predicate_ordinal")
    var rows: [DisposalMachinePredicatePresentation] = []
    while try statement.step() {
        rows.append(.init(
            transitionID: try disposalReaderRequiredText(
                statement, 0, "MACHINE_PREDICATE_TRANSITION"),
            predicateOrdinal: Int(statement.int64(1)),
            ruleOrdinal: Int(statement.int64(2)),
            ruleID: try disposalReaderRequiredText(statement, 3, "MACHINE_PREDICATE_RULE"),
            clauseOrdinal: Int(statement.int64(4)),
            clause: try disposalReaderRequiredText(statement, 5, "MACHINE_PREDICATE_CLAUSE"),
            lhs: try disposalReaderRequiredText(statement, 6, "MACHINE_PREDICATE_LHS"),
            comparisonOperator: try disposalReaderRequiredText(
                statement, 7, "MACHINE_PREDICATE_OPERATOR"),
            rhs: try disposalReaderRequiredText(statement, 8, "MACHINE_PREDICATE_RHS"),
            actualScalar: try disposalReaderRequiredText(
                statement, 9, "MACHINE_PREDICATE_ACTUAL"),
            normalizedState: try disposalReaderRequiredText(
                statement, 10, "MACHINE_PREDICATE_STATE"),
            sourceCount: Int(statement.int64(11)),
            sourceSetSHA256: try disposalReaderRequiredText(
                statement, 12, "MACHINE_PREDICATE_SOURCE_SET"),
            predicateSHA256: try disposalReaderRequiredText(
                statement, 13, "MACHINE_PREDICATE_SHA")))
    }
    return rows
}

private func disposalReadMachineMerkleLeaves(
    _ database: DisposalSQLiteConnection
) throws -> [DisposalMachineMerkleLeafPresentation] {
    let statement = try database.prepare(
        "SELECT state_id,leaf_ordinal,witness_id,normalized_leaf_sha256 " +
            "FROM machine_merkle_leaves ORDER BY state_id,leaf_ordinal")
    var rows: [DisposalMachineMerkleLeafPresentation] = []
    while try statement.step() {
        rows.append(.init(
            stateID: try disposalReaderRequiredText(statement, 0, "MACHINE_LEAF_STATE"),
            leafOrdinal: Int(statement.int64(1)),
            witnessID: try disposalReaderRequiredText(statement, 2, "MACHINE_LEAF_WITNESS"),
            normalizedLeafSHA256: try disposalReaderRequiredText(
                statement, 3, "MACHINE_LEAF_SHA")))
    }
    return rows
}

private func disposalReadMachineEdges(
    _ database: DisposalSQLiteConnection
) throws -> [DisposalMachineEdgePresentation] {
    let statement = try database.prepare(
        "SELECT overlay_edge_id,from_node_id,to_node_id,edge_role " +
            "FROM machine_overlay_edges ORDER BY overlay_edge_id")
    var rows: [DisposalMachineEdgePresentation] = []
    while try statement.step() {
        rows.append(.init(
            id: try disposalReaderRequiredText(statement, 0, "MACHINE_EDGE_ID"),
            fromNodeID: try disposalReaderRequiredText(statement, 1, "MACHINE_EDGE_FROM"),
            toNodeID: try disposalReaderRequiredText(statement, 2, "MACHINE_EDGE_TO"),
            role: try disposalReaderRequiredText(statement, 3, "MACHINE_EDGE_ROLE")))
    }
    return rows
}

private func disposalReadSourceConservationSets(
    _ database: DisposalSQLiteConnection
) throws -> [DisposalSourceConservationSetPresentation] {
    let statement = try database.prepare(
        "SELECT s.conservation_set_commitment_id,s.source_frame_id," +
            "f.raw_sha256_with_lf,s.invocation_id,s.epoch_label,s.purpose,s.scope_kind," +
            "s.scope_id,s.algorithm,s.domain_tag,s.leaf_ordering,s.duplicate_policy," +
            "s.tree_shape,s.odd_leaf_rule,s.witness_root_sha256,s.leaf_count," +
            "s.temporal_state FROM conservation_set_commitments s JOIN frames f " +
            "ON f.frame_id=s.source_frame_id ORDER BY s.source_frame_id")
    var rows: [DisposalSourceConservationSetPresentation] = []
    while try statement.step() {
        rows.append(.init(
            id: try disposalReaderRequiredText(statement, 0, "SOURCE_SET_ID"),
            sourceFrameID: try disposalReaderRequiredText(statement, 1, "SOURCE_SET_FRAME"),
            sourceFrameLFSHA256: try disposalReaderRequiredText(
                statement, 2, "SOURCE_SET_FRAME_LF_SHA"),
            invocationID: try disposalReaderRequiredText(statement, 3, "SOURCE_SET_INVOCATION"),
            epochLabel: try disposalReaderRequiredText(statement, 4, "SOURCE_SET_EPOCH"),
            purpose: try disposalReaderRequiredText(statement, 5, "SOURCE_SET_PURPOSE"),
            scopeKind: try disposalReaderRequiredText(statement, 6, "SOURCE_SET_SCOPE_KIND"),
            scopeID: try disposalReaderRequiredText(statement, 7, "SOURCE_SET_SCOPE_ID"),
            algorithm: try disposalReaderRequiredText(statement, 8, "SOURCE_SET_ALGORITHM"),
            domainTag: try disposalReaderRequiredText(statement, 9, "SOURCE_SET_DOMAIN"),
            leafOrdering: try disposalReaderRequiredText(statement, 10, "SOURCE_SET_ORDER"),
            duplicatePolicy: try disposalReaderRequiredText(
                statement, 11, "SOURCE_SET_DUPLICATE"),
            treeShape: try disposalReaderRequiredText(statement, 12, "SOURCE_SET_TREE"),
            oddLeafRule: try disposalReaderRequiredText(statement, 13, "SOURCE_SET_ODD"),
            witnessRootSHA256: try disposalReaderRequiredText(statement, 14, "SOURCE_SET_ROOT"),
            leafCount: Int(statement.int64(15)),
            temporalState: try disposalReaderRequiredText(statement, 16, "SOURCE_SET_TEMPORAL")))
    }
    return rows
}

private func disposalReadSourceConservationMemberships(
    _ database: DisposalSQLiteConnection
) throws -> [DisposalSourceConservationMembershipPresentation] {
    let statement = try database.prepare(
        "SELECT membership_id,conservation_set_commitment_id,leaf_ordinal," +
            "obligation_key_sha256,obligation_commitment_id,target_id,target_role," +
            "target_form,expected_uniqueid_text,expected_idversion_text,operation," +
            "numeric_argument,signal_number,budget_ordinal,commitment_frame_lf_sha256," +
            "leaf_sha256,proof_sha256,proof_depth FROM conservation_set_memberships " +
            "ORDER BY conservation_set_commitment_id,leaf_ordinal")
    var rows: [DisposalSourceConservationMembershipPresentation] = []
    while try statement.step() {
        rows.append(.init(
            id: try disposalReaderRequiredText(statement, 0, "SOURCE_MEMBER_ID"),
            conservationSetID: try disposalReaderRequiredText(statement, 1, "SOURCE_MEMBER_SET"),
            leafOrdinal: Int(statement.int64(2)),
            obligationKeySHA256: try disposalReaderRequiredText(statement, 3, "SOURCE_MEMBER_KEY"),
            obligationCommitmentID: try disposalReaderRequiredText(
                statement, 4, "SOURCE_MEMBER_COMMITMENT"),
            targetID: try disposalReaderRequiredText(statement, 5, "SOURCE_MEMBER_TARGET"),
            targetRole: try disposalReaderRequiredText(statement, 6, "SOURCE_MEMBER_ROLE"),
            targetForm: try disposalReaderRequiredText(statement, 7, "SOURCE_MEMBER_FORM"),
            expectedUniqueID: try disposalReaderRequiredText(statement, 8, "SOURCE_MEMBER_UNIQUE"),
            expectedIDVersion: try disposalReaderRequiredText(
                statement, 9, "SOURCE_MEMBER_IDVERSION"),
            operation: try disposalReaderRequiredText(statement, 10, "SOURCE_MEMBER_OPERATION"),
            numericArgument: Int(statement.int64(11)),
            signalNumber: Int(statement.int64(12)),
            budgetOrdinal: Int(statement.int64(13)),
            commitmentFrameLFSHA256: try disposalReaderRequiredText(
                statement, 14, "SOURCE_MEMBER_FRAME_LF_SHA"),
            leafSHA256: try disposalReaderRequiredText(statement, 15, "SOURCE_MEMBER_LEAF_SHA"),
            proofSHA256: try disposalReaderRequiredText(statement, 16, "SOURCE_MEMBER_PROOF_SHA"),
            proofDepth: Int(statement.int64(17))))
    }
    return rows
}

private func disposalReadSourceConservationProofNodes(
    _ database: DisposalSQLiteConnection
) throws -> [DisposalSourceConservationProofNodePresentation] {
    let statement = try database.prepare(
        "SELECT membership_id,proof_ordinal,sibling_position,sibling_sha256 " +
            "FROM conservation_set_membership_proof_nodes " +
            "ORDER BY membership_id,proof_ordinal")
    var rows: [DisposalSourceConservationProofNodePresentation] = []
    while try statement.step() {
        rows.append(.init(
            membershipID: try disposalReaderRequiredText(statement, 0, "SOURCE_PROOF_MEMBER"),
            proofOrdinal: Int(statement.int64(1)),
            siblingPosition: try disposalReaderRequiredText(statement, 2, "SOURCE_PROOF_POSITION"),
            siblingSHA256: try disposalReaderRequiredText(statement, 3, "SOURCE_PROOF_SIBLING")))
    }
    return rows
}

private func disposalReadSourceConservationMappings(
    _ database: DisposalSQLiteConnection
) throws -> [DisposalSourceConservationMappingPresentation] {
    let statement = try database.prepare(
        "SELECT m.mapping_id,m.conservation_id,m.conservation_set_commitment_id," +
            "m.membership_id,m.target_id,m.mapping_state,s.merkle_state," +
            "c.completion_state,f.raw_sha256_with_lf " +
            "FROM conservation_set_obligation_mappings m " +
            "JOIN conservation_set_conservation_states s " +
            "ON s.conservation_id=m.conservation_id " +
            "AND s.conservation_set_commitment_id=m.conservation_set_commitment_id " +
            "JOIN conservations c ON c.conservation_id=m.conservation_id " +
            "JOIN frames f ON f.frame_id=c.source_frame_id ORDER BY m.mapping_id")
    var rows: [DisposalSourceConservationMappingPresentation] = []
    while try statement.step() {
        rows.append(.init(
            id: try disposalReaderRequiredText(statement, 0, "SOURCE_MAPPING_ID"),
            conservationID: try disposalReaderRequiredText(statement, 1, "SOURCE_MAPPING_CONSERVATION"),
            conservationSetID: try disposalReaderRequiredText(statement, 2, "SOURCE_MAPPING_SET"),
            membershipID: try disposalReaderRequiredText(statement, 3, "SOURCE_MAPPING_MEMBER"),
            targetID: try disposalReaderRequiredText(statement, 4, "SOURCE_MAPPING_TARGET"),
            mappingState: try disposalReaderRequiredText(statement, 5, "SOURCE_MAPPING_STATE"),
            merkleState: try disposalReaderRequiredText(statement, 6, "SOURCE_MAPPING_MERKLE"),
            conservationCompletionState: try disposalReaderRequiredText(
                statement, 7, "SOURCE_MAPPING_COMPLETION"),
            conservationSourceFrameLFSHA256: try disposalReaderRequiredText(
                statement, 8, "SOURCE_MAPPING_FRAME_LF_SHA")))
    }
    return rows
}

func disposalValidateSourceConservationSemanticRoundTrip(
    sets: [DisposalSourceConservationSetPresentation],
    memberships: [DisposalSourceConservationMembershipPresentation],
    proofNodes: [DisposalSourceConservationProofNodePresentation],
    mappings: [DisposalSourceConservationMappingPresentation],
    requiresCompleteMappingCoverage: Bool
) throws {
    let setIDs = Set(sets.map(\.id))
    let membershipIDs = Set(memberships.map(\.id))
    try disposalRequireProjection(setIDs.count == sets.count, "DISPOSAL_READER_SET_DUPLICATE")
    try disposalRequireProjection(
        membershipIDs.count == memberships.count,
        "DISPOSAL_READER_MEMBERSHIP_DUPLICATE")
    try disposalRequireProjection(
        memberships.allSatisfy { setIDs.contains($0.conservationSetID) },
        "DISPOSAL_READER_MEMBERSHIP_SET_JOIN")
    try disposalRequireProjection(
        proofNodes.allSatisfy { membershipIDs.contains($0.membershipID) },
        "DISPOSAL_READER_PROOF_MEMBERSHIP_JOIN")

    for set in sets {
        let ordered = memberships.filter { $0.conservationSetID == set.id }
            .sorted { $0.leafOrdinal < $1.leafOrdinal }
        try disposalRequireProjection(
            ordered.count == set.leafCount &&
                ordered.map(\.leafOrdinal) == Array(0..<set.leafCount),
            "DISPOSAL_READER_SET_CARDINALITY")
        let canonicalObligationKeys = try ordered.map { membership -> String in
            let leaf = DisposalConservationSetMerkle.leafSHA256(
                obligationKeySHA256: membership.obligationKeySHA256)
            try disposalRequireProjection(
                leaf == membership.leafSHA256,
                "DISPOSAL_READER_MEMBERSHIP_LEAF_ROUND_TRIP")
            let nodes = proofNodes.filter { $0.membershipID == membership.id }
                .sorted { $0.proofOrdinal < $1.proofOrdinal }
            try disposalRequireProjection(
                nodes.count == membership.proofDepth &&
                    nodes.map(\.proofOrdinal) == Array(0..<membership.proofDepth),
                "DISPOSAL_READER_PROOF_CARDINALITY")
            let proof = nodes.map {
                DisposalConservationMerkleProofNode(
                    siblingPosition: $0.siblingPosition,
                    siblingSHA256: $0.siblingSHA256)
            }
            try disposalRequireProjection(
                DisposalConservationSetMerkle.proofSHA256(proof) == membership.proofSHA256 &&
                    DisposalConservationSetMerkle.verify(
                        leafSHA256: leaf,
                        proof: proof,
                        rootSHA256: set.witnessRootSHA256),
                "DISPOSAL_READER_PROOF_ROUND_TRIP")
            return membership.obligationKeySHA256
        }
        try disposalRequireProjection(
            try DisposalConservationSetMerkle.root(
                canonicalObligationKeys: canonicalObligationKeys) == set.witnessRootSHA256,
            "DISPOSAL_READER_SET_ROOT_ROUND_TRIP")
    }

    var mappedMemberships: Set<String> = []
    for mapping in mappings {
        guard let membership = memberships.first(where: { $0.id == mapping.membershipID }) else {
            throw DisposalProjectionRejection(code: "DISPOSAL_READER_MAPPING_MEMBERSHIP_JOIN")
        }
        try disposalRequireProjection(
            mappedMemberships.insert(mapping.membershipID).inserted &&
                mapping.conservationSetID == membership.conservationSetID &&
                mapping.targetID == membership.targetID &&
                mapping.mappingState == "EXPLICIT_SAME_GENERATION" &&
                mapping.merkleState == "VERIFIED_PRIOR_EXACT" &&
                mapping.conservationCompletionState == "COMPLETE",
            "DISPOSAL_READER_MAPPING_SEMANTIC_ROUND_TRIP")
    }
    if requiresCompleteMappingCoverage {
        try disposalRequireProjection(
            mappedMemberships == membershipIDs,
            "DISPOSAL_READER_MAPPING_COVERAGE")
    }
}

private func disposalReaderDatabase(
    _ databases: DisposalJSONValue,
    role: String
) throws -> DisposalSidecarDatabase {
    let value = try disposalReaderObject(databases, role)
    return .init(
        applicationID: Int64(try disposalReaderInt(value, "application_id")),
        bytes: try disposalReaderInt(value, "bytes"),
        projectionID: try disposalReaderLowerSHA(value, "projection_id"),
        exportSHA256: try disposalReaderLowerSHA(value, "export_sha256"),
        sha256: try disposalReaderLowerSHA(value, "sha256"))
}

private func disposalReaderObject(
    _ object: DisposalJSONValue,
    _ key: String
) throws -> DisposalJSONValue {
    guard let value = object.member(key), case .object = value else {
        throw DisposalProjectionRejection(
            code: "DISPOSAL_READER_REQUIRED_OBJECT", detail: key)
    }
    return value
}

private func disposalReaderString(
    _ object: DisposalJSONValue,
    _ key: String
) throws -> String {
    guard let value = object.member(key)?.stringValue() else {
        throw DisposalProjectionRejection(
            code: "DISPOSAL_READER_REQUIRED_STRING", detail: key)
    }
    return value
}

private func disposalReaderLowerSHA(
    _ object: DisposalJSONValue,
    _ key: String
) throws -> String {
    let value = try disposalReaderString(object, key)
    try disposalRequireProjection(
        disposalIsLowerHex(value, count: 64),
        "DISPOSAL_READER_SHA256",
        detail: key)
    return value
}

private func disposalReaderOptionalLowerSHA(
    _ object: DisposalJSONValue,
    _ key: String
) throws -> String? {
    guard let member = object.member(key) else {
        throw DisposalProjectionRejection(
            code: "DISPOSAL_READER_OPTIONAL_SHA_ABSENT", detail: key)
    }
    if case .null = member { return nil }
    guard let value = member.stringValue(), disposalIsLowerHex(value, count: 64) else {
        throw DisposalProjectionRejection(
            code: "DISPOSAL_READER_OPTIONAL_SHA256", detail: key)
    }
    return value
}

private func disposalReaderInt(
    _ object: DisposalJSONValue,
    _ key: String
) throws -> Int {
    guard let lexeme = object.member(key)?.numberLexeme(),
          let value = Int(lexeme), String(value) == lexeme
    else {
        throw DisposalProjectionRejection(
            code: "DISPOSAL_READER_REQUIRED_INT", detail: key)
    }
    return value
}

private func disposalReaderBoolean(
    _ object: DisposalJSONValue,
    _ key: String
) throws -> Bool {
    guard let value = object.member(key)?.booleanValue() else {
        throw DisposalProjectionRejection(
            code: "DISPOSAL_READER_REQUIRED_BOOLEAN", detail: key)
    }
    return value
}

private func disposalReaderRequiredText(
    _ statement: DisposalSQLiteStatement,
    _ index: Int32,
    _ code: String
) throws -> String {
    guard let value = statement.optionalText(index) else {
        throw DisposalProjectionRejection(code: "DISPOSAL_READER_\(code)")
    }
    return value
}

private final class DisposalHeldProjectionSet {
    let rootDescriptor: Int32
    let evidence: Data
    let metrics: Data
    let graph: Data
    let seal: Data

    init(rootPath: String, expectedSealSHA256: String) throws {
        try disposalRequireProjection(
            rootPath.hasPrefix("/private/tmp/"),
            "DISPOSAL_READER_ROOT_SCOPE")
        var resolved = [CChar](repeating: 0, count: Int(PATH_MAX))
        errno = 0
        if realpath(rootPath, &resolved) == nil && errno == ENOENT {
            throw DisposalProjectionMissing()
        }
        guard resolved.first != 0 else {
            throw DisposalProjectionRejection(
                code: "DISPOSAL_READER_ROOT_REALPATH",
                detail: String(cString: strerror(errno)))
        }
        let resolvedPath = String(
            decoding: resolved.prefix { $0 != 0 }.map { UInt8(bitPattern: $0) },
            as: UTF8.self)
        try disposalRequireProjection(
            resolvedPath == rootPath,
            "DISPOSAL_READER_ROOT_ALIAS")
        let openedRoot = Darwin.open(
            rootPath,
            O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW_ANY)
        guard openedRoot >= 0 else {
            throw DisposalProjectionRejection(
                code: "DISPOSAL_READER_ROOT_OPEN",
                detail: String(cString: strerror(errno)))
        }
        var closeOnFailure = true
        defer { if closeOnFailure { _ = Darwin.close(openedRoot) } }
        var before = stat()
        guard fstat(openedRoot, &before) == 0 else {
            throw DisposalProjectionRejection(code: "DISPOSAL_READER_ROOT_FSTAT")
        }
        try disposalRequireProjection(
            (before.st_mode & S_IFMT) == S_IFDIR,
            "DISPOSAL_READER_ROOT_TYPE")
        try disposalRequireProjection(
            (before.st_mode & 0o7777) == 0o500,
            "DISPOSAL_READER_ROOT_MODE")
        try disposalRequireProjection(
            before.st_uid == geteuid(),
            "DISPOSAL_READER_ROOT_OWNER")
        let expectedLeaves = [
            DisposalProjectionSetV1.evidenceLeaf,
            DisposalProjectionSetV1.metricsLeaf,
            DisposalProjectionSetV1.graphLeaf,
            DisposalProjectionSetV1.sealLeaf,
        ].sorted()
        let initialInventory = try disposalReaderDirectoryEntries(openedRoot).sorted()
        try disposalRequireProjection(
            initialInventory == expectedLeaves,
            "DISPOSAL_READER_ROOT_INVENTORY")
        evidence = try disposalReaderHeldLeaf(
            root: openedRoot,
            leaf: DisposalProjectionSetV1.evidenceLeaf,
            maximumBytes: 128 * 1_024 * 1_024)
        metrics = try disposalReaderHeldLeaf(
            root: openedRoot,
            leaf: DisposalProjectionSetV1.metricsLeaf,
            maximumBytes: 128 * 1_024 * 1_024)
        graph = try disposalReaderHeldLeaf(
            root: openedRoot,
            leaf: DisposalProjectionSetV1.graphLeaf,
            maximumBytes: 128 * 1_024 * 1_024)
        seal = try disposalReaderHeldLeaf(
            root: openedRoot,
            leaf: DisposalProjectionSetV1.sealLeaf,
            maximumBytes: 1 * 1_024 * 1_024)
        try disposalRequireProjection(
            disposalSHA256(seal) == expectedSealSHA256,
            "DISPOSAL_READER_SEAL_SHA256")
        var after = stat()
        var named = stat()
        guard fstat(openedRoot, &after) == 0, lstat(rootPath, &named) == 0 else {
            throw DisposalProjectionRejection(code: "DISPOSAL_READER_ROOT_REVALIDATE")
        }
        try disposalRequireProjection(
            disposalReaderSameState(before, after),
            "DISPOSAL_READER_ROOT_DRIFT")
        try disposalRequireProjection(
            disposalReaderSameState(after, named),
            "DISPOSAL_READER_ROOT_REBOUND")
        try disposalRequireProjection(
            try disposalReaderDirectoryEntries(openedRoot).sorted() == initialInventory,
            "DISPOSAL_READER_ROOT_INVENTORY_DRIFT")
        rootDescriptor = openedRoot
        closeOnFailure = false
    }

    deinit { _ = Darwin.close(rootDescriptor) }
}

private func disposalReaderHeldLeaf(
    root: Int32,
    leaf: String,
    maximumBytes: Int
) throws -> Data {
    let descriptor = leaf.withCString {
        disposal_projection_openat_readonly_no_follow(root, $0)
    }
    guard descriptor >= 0 else {
        throw DisposalProjectionRejection(
            code: "DISPOSAL_READER_LEAF_OPEN", detail: leaf)
    }
    defer { _ = Darwin.close(descriptor) }
    var before = stat()
    guard fstat(descriptor, &before) == 0 else {
        throw DisposalProjectionRejection(
            code: "DISPOSAL_READER_LEAF_FSTAT", detail: leaf)
    }
    try disposalRequireProjection(
        (before.st_mode & S_IFMT) == S_IFREG,
        "DISPOSAL_READER_LEAF_TYPE",
        detail: leaf)
    try disposalRequireProjection(
        (before.st_mode & 0o7777) == 0o400,
        "DISPOSAL_READER_LEAF_MODE",
        detail: leaf)
    try disposalRequireProjection(
        before.st_uid == geteuid() && before.st_nlink == 1,
        "DISPOSAL_READER_LEAF_IDENTITY",
        detail: leaf)
    try disposalRequireProjection(
        before.st_size > 0 && before.st_size <= off_t(maximumBytes),
        "DISPOSAL_READER_LEAF_SIZE",
        detail: leaf)
    let bytes = try disposalReaderPread(
        descriptor: descriptor,
        count: Int(before.st_size))
    var after = stat()
    var named = stat()
    guard fstat(descriptor, &after) == 0,
          fstatat(root, leaf, &named, AT_SYMLINK_NOFOLLOW) == 0
    else {
        throw DisposalProjectionRejection(
            code: "DISPOSAL_READER_LEAF_REVALIDATE", detail: leaf)
    }
    try disposalRequireProjection(
        disposalReaderSameState(before, after),
        "DISPOSAL_READER_LEAF_DRIFT",
        detail: leaf)
    try disposalRequireProjection(
        disposalReaderSameState(after, named),
        "DISPOSAL_READER_LEAF_REBOUND",
        detail: leaf)
    return bytes
}

private func disposalReaderPread(descriptor: Int32, count: Int) throws -> Data {
    var data = Data(count: count)
    var offset = 0
    while offset < count {
        let result = data.withUnsafeMutableBytes { raw -> Int in
            guard let base = raw.baseAddress else { return -1 }
            return pread(
                descriptor,
                base.advanced(by: offset),
                count - offset,
                off_t(offset))
        }
        if result > 0 { offset += result }
        else if result < 0 && errno == EINTR { continue }
        else {
            throw DisposalProjectionRejection(code: "DISPOSAL_READER_PREAD")
        }
    }
    return data
}

private func disposalReaderDirectoryEntries(_ descriptor: Int32) throws -> [String] {
    let copied = dup(descriptor)
    guard copied >= 0, let directory = fdopendir(copied) else {
        if copied >= 0 { _ = Darwin.close(copied) }
        throw DisposalProjectionRejection(code: "DISPOSAL_READER_FDOPENDIR")
    }
    defer { closedir(directory) }
    rewinddir(directory)
    var result: [String] = []
    errno = 0
    while let entry = readdir(directory) {
        let name = withUnsafePointer(to: &entry.pointee.d_name) {
            $0.withMemoryRebound(to: CChar.self, capacity: Int(NAME_MAX) + 1) {
                String(cString: $0)
            }
        }
        if name != "." && name != ".." { result.append(name) }
        errno = 0
    }
    try disposalRequireProjection(
        errno == 0,
        "DISPOSAL_READER_READDIR")
    return result
}

private func disposalReaderSameState(_ lhs: stat, _ rhs: stat) -> Bool {
    lhs.st_dev == rhs.st_dev && lhs.st_ino == rhs.st_ino &&
        lhs.st_mode == rhs.st_mode && lhs.st_nlink == rhs.st_nlink &&
        lhs.st_uid == rhs.st_uid && lhs.st_gid == rhs.st_gid &&
        lhs.st_size == rhs.st_size && lhs.st_gen == rhs.st_gen &&
        lhs.st_mtimespec.tv_sec == rhs.st_mtimespec.tv_sec &&
        lhs.st_mtimespec.tv_nsec == rhs.st_mtimespec.tv_nsec &&
        lhs.st_ctimespec.tv_sec == rhs.st_ctimespec.tv_sec &&
        lhs.st_ctimespec.tv_nsec == rhs.st_ctimespec.tv_nsec
}
