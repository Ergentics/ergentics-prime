@testable import DisposalProjectionCore
import XCTest

final class DisposalGraphStateMachineTests: XCTestCase {
    func testFirstMatchLatticeDoesNotLetTerminalMaskContainment() throws {
        var input = DisposalGraphLatticeTestInput()
        input.commitmentCount = 1
        input.signalResultCount = 1
        input.enteredSignalWithoutCompleteConservation = true
        input.enteredSignalCount = 1
        input.terminalCount = 1
        input.exactTerminalCount = 1
        let result = try disposalGraphEvaluateForTesting(input)
        XCTAssertEqual(result.ruleID, "D30")
        XCTAssertEqual(result.stateClass, "CONTAINMENT_REQUIRED")
    }

    func testOrderedRelationalAcceptanceCases() throws {
        var commitmentOnly = DisposalGraphLatticeTestInput()
        commitmentOnly.commitmentCount = 1
        XCTAssertEqual(
            try disposalGraphEvaluateForTesting(commitmentOnly).ruleID,
            "D20")

        var conserved = DisposalGraphLatticeTestInput()
        conserved.commitmentCount = 1
        conserved.signalResultCount = 1
        conserved.exactPreconservationObligationSetCommitment = true
        conserved.allCommittedObligationsConserved = true
        XCTAssertEqual(
            try disposalGraphEvaluateForTesting(conserved).ruleID,
            "D50")

        var terminal = conserved
        terminal.terminalCount = 1
        terminal.exactTerminalCount = 1
        XCTAssertEqual(
            try disposalGraphEvaluateForTesting(terminal).ruleID,
            "D60")

        var rejected = DisposalGraphLatticeTestInput()
        rejected.terminalCount = 1
        rejected.exactTerminalCount = 1
        rejected.preactuationRejectionTerminalCount = 1
        XCTAssertEqual(
            try disposalGraphEvaluateForTesting(rejected).ruleID,
            "D70")
    }

    func testZeroObligationAndLegacyConservationCannotReachTerminalRecorded() throws {
        var zeroObligation = DisposalGraphLatticeTestInput()
        zeroObligation.terminalCount = 1
        zeroObligation.exactTerminalCount = 1
        zeroObligation.exactPreconservationObligationSetCommitment = true
        zeroObligation.allCommittedObligationsConserved = true
        XCTAssertEqual(
            try disposalGraphEvaluateForTesting(zeroObligation).ruleID,
            "D80")

        var legacy = DisposalGraphLatticeTestInput()
        legacy.commitmentCount = 1
        legacy.signalResultCount = 1
        legacy.terminalCount = 1
        legacy.exactTerminalCount = 1
        legacy.exactPreconservationObligationSetCommitment = nil
        legacy.allCommittedObligationsConserved = nil
        XCTAssertEqual(
            try disposalGraphEvaluateForTesting(legacy).ruleID,
            "D80")
    }

    func testD40IsReservedAndCannotBeSelectedByTheActiveEvaluator() throws {
        var impossibleReturnedWithoutEntry = DisposalGraphLatticeTestInput()
        impossibleReturnedWithoutEntry.commitmentCount = 1
        impossibleReturnedWithoutEntry.signalResultCount = 1
        XCTAssertEqual(
            try disposalGraphEvaluateForTesting(impossibleReturnedWithoutEntry).ruleID,
            "D80")

        var admittedReturnedSignal = impossibleReturnedWithoutEntry
        admittedReturnedSignal.enteredSignalWithoutCompleteConservation = true
        admittedReturnedSignal.enteredSignalCount = 1
        XCTAssertEqual(
            try disposalGraphEvaluateForTesting(admittedReturnedSignal).ruleID,
            "D30")
    }

    func testMachineContentAddressEncodingIsUnambiguousAcrossNULBoundaries() {
        XCTAssertNotEqual(
            disposalMachineIDForTesting("test", ["a\0b"]),
            disposalMachineIDForTesting("test", ["a", "b"]))
        XCTAssertNotEqual(
            disposalMachineIDForTesting("test\0x", ["a"]),
            disposalMachineIDForTesting("test", ["x", "a"]))
        XCTAssertEqual(
            disposalMachineIDForTesting("test", ["", "a"]),
            disposalMachineIDForTesting("test", ["", "a"]))
    }

    func testFullBuildPrefixStateEqualsIndependentTruncatedProjection() throws {
        let fixture = machinePrefixJournal()
        let full = try DisposalProjectionSetBuilder.makeMaterial(request: .init(
            journal: fixture.journal,
            journalLogicalPath: "retained/machine-prefix.jsonl"))
        for prefixOrdinal in fixture.frames.indices {
            let truncatedJournal = fixture.frames[0...prefixOrdinal].reduce(into: Data()) {
                $0.append($1)
            }
            let truncated = try DisposalProjectionSetBuilder.makeMaterial(request: .init(
                journal: truncatedJournal,
                journalLogicalPath: "retained/machine-prefix.jsonl"))
            let fullDB = try DisposalSQLiteConnection(serializedReadOnly: full.graph)
            let truncatedDB = try DisposalSQLiteConnection(serializedReadOnly: truncated.graph)
            defer {
                try? fullDB.close()
                try? truncatedDB.close()
            }
            XCTAssertEqual(
                try machineRows(
                    fullDB,
                    "SELECT state_id,prefix_ordinal,predecessor_state_id,ancestry_sha256," +
                        "high_water_frame_lf_sha256,matched_rule_id,predicate_vector_sha256," +
                        "state_class,derived_post_hoc_witness_merkle_root_sha256," +
                        "derived_post_hoc_witness_leaf_count,merkle_algorithm,merkle_domain_tag," +
                        "merkle_leaf_ordering,merkle_duplicate_policy,merkle_odd_leaf_rule " +
                        "FROM machine_states WHERE prefix_ordinal=\(prefixOrdinal)",
                    columns: 15),
                try machineRows(
                    truncatedDB,
                    "SELECT state_id,prefix_ordinal,predecessor_state_id,ancestry_sha256," +
                        "high_water_frame_lf_sha256,matched_rule_id,predicate_vector_sha256," +
                        "state_class,derived_post_hoc_witness_merkle_root_sha256," +
                        "derived_post_hoc_witness_leaf_count,merkle_algorithm,merkle_domain_tag," +
                        "merkle_leaf_ordering,merkle_duplicate_policy,merkle_odd_leaf_rule " +
                        "FROM machine_states WHERE prefix_ordinal=\(prefixOrdinal)",
                    columns: 15))
            XCTAssertEqual(
                try machinePrefixSemanticRows(fullDB, prefixOrdinal: prefixOrdinal),
                try machinePrefixSemanticRows(truncatedDB, prefixOrdinal: prefixOrdinal))
        }

        let database = try DisposalSQLiteConnection(serializedReadOnly: full.graph)
        defer { try? database.close() }
        XCTAssertEqual(
            try database.scalarInt(
                "SELECT count(*) FROM machine_overlay_edges e " +
                    "JOIN machine_nodes f ON f.machine_node_id=e.from_node_id " +
                    "JOIN machine_nodes t ON t.machine_node_id=e.to_node_id " +
                    "WHERE f.partition_kind=t.partition_kind"),
            0)
        XCTAssertEqual(
            try database.scalarInt(
                "SELECT count(*) FROM machine_transitions t WHERE " +
                    "(SELECT count(*) FROM machine_overlay_edges e WHERE " +
                    "e.edge_role='PREDECESSOR' AND e.to_node_id=t.transition_id)<>1 OR " +
                    "(SELECT count(*) FROM machine_overlay_edges e WHERE " +
                    "e.edge_role='SUCCESSOR' AND e.from_node_id=t.transition_id)<>1"),
            0)
        XCTAssertEqual(
            try database.scalarInt(
                "SELECT count(*) FROM machine_states s WHERE s.prefix_ordinal>=0 AND " +
                    "(SELECT count(*) FROM machine_transitions t " +
                    "WHERE t.to_state_id=s.state_id)<>1"),
            0)
        XCTAssertEqual(
            try database.scalarInt(
                "SELECT count(*) FROM machine_merkle_leaves l " +
                    "JOIN machine_witnesses w ON w.witness_id=l.witness_id " +
                    "JOIN machine_states s ON s.state_id=l.state_id " +
                    "WHERE w.visible_prefix_ordinal>s.prefix_ordinal"),
            0)
        XCTAssertEqual(
            try database.scalarInt(
                "SELECT count(*) FROM machine_transitions t " +
                    "JOIN machine_states s ON s.state_id=t.to_state_id WHERE " +
                    "(SELECT count(*) FROM machine_overlay_edges e " +
                    "WHERE e.edge_role='SUPPORTS' AND e.to_node_id=t.transition_id)<>" +
                    "s.derived_post_hoc_witness_leaf_count"),
            0)
        let d80StateCount = try database.scalarInt(
            "SELECT count(*) FROM machine_states " +
                "WHERE prefix_ordinal>=0 AND matched_rule_id='D80' " +
                "AND state_class='ABSTAIN_INCOMPLETE'")
        XCTAssertEqual(d80StateCount, Int64(fixture.frames.count))
        let unknownPredicateCount = try database.scalarInt(
            "SELECT count(*) FROM machine_transition_predicates " +
                "WHERE normalized_state='UNKNOWN'")
        XCTAssertGreaterThan(unknownPredicateCount, 0)
        for view in [
            "ui_state_machine_states", "ui_state_machine_transitions",
            "ui_state_machine_witnesses",
        ] {
            _ = try database.scalarInt("SELECT count(*) FROM \(view)")
        }
    }

    func testOverlayDDLRejectsPresealSubtypePartitionBindingFutureAndIncompleteSeal() throws {
        let database = try DisposalSQLiteConnection()
        defer { try? database.close() }
        let ddl = try disposalResourceData("001-graph", extension: "sql")
        try database.execute(String(decoding: ddl, as: UTF8.self))

        let invocationNode = String(repeating: "1", count: 64)
        let genesisState = String(repeating: "2", count: 64)
        let nextState = String(repeating: "3", count: 64)
        let witness = String(repeating: "4", count: 64)
        let digest = String(repeating: "5", count: 64)
        let badState = String(repeating: "a", count: 64)
        let transition = String(repeating: "b", count: 64)
        let badTransition = String(repeating: "c", count: 64)
        try database.execute(
            "INSERT INTO input_databases VALUES('EVIDENCE','\(digest)'," +
                "'\(String(repeating: "6", count: 64))',1," +
                "'\(String(repeating: "7", count: 64))')")
        try database.execute(
            "INSERT INTO graph_nodes VALUES('\(invocationNode)','INVOCATION','invocation'," +
                "'invocation','EVIDENCE','invocation',0)")
        try database.execute(
            "INSERT INTO machine_nodes VALUES('\(genesisState)','OBJECT','STATE',0,0)")
        try database.execute(
            "INSERT INTO machine_nodes VALUES('\(nextState)','OBJECT','STATE',0,0)")
        try database.execute(
            "INSERT INTO machine_nodes VALUES('\(witness)','OBJECT','WITNESS',0,0)")
        try database.execute(
            "INSERT INTO machine_nodes VALUES('\(badState)','OBJECT','STATE',0,0)")
        try database.execute(
            "INSERT INTO machine_nodes VALUES('\(transition)','RELATION','TRANSITION',0,0)")
        try database.execute(
            "INSERT INTO machine_nodes VALUES('\(badTransition)'," +
                "'RELATION','TRANSITION',0,0)")
        XCTAssertThrowsError(try database.execute(
            "INSERT INTO machine_states VALUES('\(witness)',-1,NULL,'\(digest)',NULL," +
                "'D00','\(digest)','EMPTY','\(digest)',0,'SHA256'," +
                "'ERGENTICS_DISPOSAL_DERIVED_POST_HOC_WITNESS_PREFIX_V1'," +
                "'CANONICAL_LEAF_KEY_BYTES_ASC','REJECT_DUPLICATES'," +
                "'RFC6962_LARGEST_POWER_OF_TWO_SPLIT','00000000',0,0)"))
        try database.execute(
            "INSERT INTO machine_states VALUES('\(genesisState)',-1,NULL,'\(digest)',NULL," +
                "'D00','\(digest)','EMPTY','\(digest)',0,'SHA256'," +
                "'ERGENTICS_DISPOSAL_DERIVED_POST_HOC_WITNESS_PREFIX_V1'," +
                "'CANONICAL_LEAF_KEY_BYTES_ASC','REJECT_DUPLICATES'," +
                "'RFC6962_LARGEST_POWER_OF_TWO_SPLIT','00000000',0,0)")
        XCTAssertThrowsError(try database.execute(
            "INSERT INTO machine_states VALUES('\(badState)',0,'\(genesisState)'," +
                "'\(digest)','\(digest)','D00','\(digest)','EMPTY','\(digest)',0,'SHA256'," +
                "'ERGENTICS_DISPOSAL_DERIVED_POST_HOC_WITNESS_PREFIX_V1'," +
                "'CANONICAL_LEAF_KEY_BYTES_ASC','REJECT_DUPLICATES'," +
                "'RFC6962_LARGEST_POWER_OF_TWO_SPLIT','00000000',0,0)")) { error in
            XCTAssertTrue(String(describing: error).contains("invalid-state-rule-class-join"))
        }
        try database.execute(
            "INSERT INTO machine_states VALUES('\(nextState)',0,'\(genesisState)'," +
                "'\(digest)','\(digest)','D80','\(digest)','ABSTAIN_INCOMPLETE'," +
                "'\(digest)',0,'SHA256'," +
                "'ERGENTICS_DISPOSAL_DERIVED_POST_HOC_WITNESS_PREFIX_V1'," +
                "'CANONICAL_LEAF_KEY_BYTES_ASC','REJECT_DUPLICATES'," +
                "'RFC6962_LARGEST_POWER_OF_TWO_SPLIT','00000000',0,0)")
        XCTAssertThrowsError(try database.execute(
            "INSERT INTO machine_transitions VALUES('\(badTransition)','\(genesisState)'," +
                "'\(nextState)','\(digest)','D00','EMPTY','\(digest)','\(digest)'," +
                "'\(digest)',0,'FALSE',NULL,'00000000',0,0)"))
        try database.execute(
            "INSERT INTO machine_transitions VALUES('\(transition)','\(genesisState)'," +
                "'\(nextState)','\(digest)','D80','ABSTAIN_INCOMPLETE','\(digest)'," +
                "'\(digest)','\(digest)',0,'FALSE',NULL,'00000000',0,0)")
        XCTAssertThrowsError(try database.execute(
            "INSERT INTO machine_transition_predicates VALUES('\(transition)',5,3," +
                "'D60',1,'exact_preconservation_obligation_set_commitment=true'," +
                "'exact_preconservation_obligation_set_commitment','=','true','true'," +
                "'TRUE',0,'\(digest)','\(digest)')")) { error in
            XCTAssertTrue(String(describing: error).contains(
                "invalid-machine-predicate-join"))
        }
        XCTAssertThrowsError(try database.execute(
            "INSERT INTO machine_transition_predicates VALUES('\(transition)',9,4," +
                "'D50',1,'exact_preconservation_obligation_set_commitment=true'," +
                "'exact_preconservation_obligation_set_commitment','=','true','UNKNOWN'," +
                "'FALSE',0,'\(digest)','\(digest)')")) { error in
            XCTAssertTrue(String(describing: error).contains(
                "invalid-machine-predicate-join"))
        }
        XCTAssertThrowsError(try database.execute(
            "INSERT INTO machine_transition_predicates VALUES('\(transition)',0,0," +
                "'D00',0,'input_set_admitted=false','terminal_count','=','false','false'," +
                "'TRUE',0,'\(digest)','\(digest)')")) { error in
            XCTAssertTrue(String(describing: error).contains(
                "invalid-machine-predicate-join"))
        }
        try database.execute(
            "INSERT INTO machine_transition_predicates VALUES('\(transition)',4,3," +
                "'D60',0,'actuation_obligation_count>0','actuation_obligation_count'," +
                "'>','0','1','TRUE',0,'\(digest)','\(digest)')")
        XCTAssertThrowsError(try database.execute(
            "INSERT INTO machine_transition_predicates VALUES('\(transition)',8,4," +
                "'D50',0,'actuation_obligation_count>0','actuation_obligation_count'," +
                "'>','0','2','TRUE',0,'\(digest)','\(digest)')")) { error in
            XCTAssertTrue(String(describing: error).contains(
                "duplicate-machine-predicate-semantic-mismatch"))
        }
        try database.execute(
            "INSERT INTO machine_witnesses VALUES('\(witness)','targets'," +
                "'\(String(repeating: "8", count: 64))',NULL,1,0,0)")
        XCTAssertThrowsError(try database.execute(
            "INSERT INTO machine_overlay_edges VALUES(" +
                "'\(String(repeating: "9", count: 64))','\(genesisState)'," +
                "'\(witness)','SUPPORTS',0,0)"))
        XCTAssertThrowsError(try database.execute(
            "INSERT INTO machine_witness_bindings VALUES('\(witness)','EVIDENCE'," +
                "'commitments','row','\(digest)',NULL)"))
        XCTAssertThrowsError(try database.execute(
            "INSERT INTO machine_merkle_leaves VALUES('\(nextState)',0," +
                "'\(witness)','\(digest)')"))
        XCTAssertThrowsError(try database.execute(
            "INSERT INTO graph_seal VALUES(1,'\(digest)','\(digest)','\(digest)'," +
                "'\(digest)','\(digest)','\(digest)','\(digest)',0,0,0," +
                "'00000000',0,0)"))
    }
}

private func machinePrefixSemanticRows(
    _ database: DisposalSQLiteConnection,
    prefixOrdinal: Int
) throws -> [[String]] {
    var result: [[String]] = []
    let queries: [(String, Int)] = [
        ("SELECT transition_id,from_state_id,to_state_id,accepted_frame_lf_sha256," +
            "matched_rule_id,state_class,predicate_vector_sha256," +
            "derived_post_hoc_source_set_sha256," +
            "predecessor_derived_post_hoc_witness_merkle_root_sha256," +
            "predecessor_derived_post_hoc_witness_leaf_count," +
            "preconservation_merkle_committed,coalesce(preconservation_commitment_witness_id,'NULL') " +
            "FROM machine_transitions WHERE to_state_id=(SELECT state_id FROM machine_states " +
            "WHERE prefix_ordinal=\(prefixOrdinal))", 12),
        ("SELECT p.rule_ordinal,p.rule_id,p.clause_ordinal,p.predicate_clause,p.normalized_lhs," +
            "p.normalized_operator,p.normalized_rhs,p.actual_scalar,p.normalized_state," +
            "p.source_count,p.source_set_sha256,p.predicate_sha256 " +
            "FROM machine_transition_predicates p JOIN machine_transitions t " +
            "ON t.transition_id=p.transition_id JOIN machine_states s ON s.state_id=t.to_state_id " +
            "WHERE s.prefix_ordinal=\(prefixOrdinal) ORDER BY p.predicate_ordinal", 12),
        ("SELECT witness_id,witness_kind,normalized_fact_sha256," +
            "coalesce(intrinsic_source_frame_lf_sha256,'NULL'),visible_prefix_ordinal " +
            "FROM machine_witnesses WHERE visible_prefix_ordinal<=\(prefixOrdinal) " +
            "ORDER BY witness_id", 5),
        ("SELECT leaf_ordinal,witness_id,normalized_leaf_sha256 FROM machine_merkle_leaves " +
            "WHERE state_id=(SELECT state_id FROM machine_states " +
            "WHERE prefix_ordinal=\(prefixOrdinal)) ORDER BY leaf_ordinal", 3),
        ("SELECT e.overlay_edge_id,e.from_node_id,e.to_node_id,e.edge_role " +
            "FROM machine_overlay_edges e JOIN machine_transitions t ON " +
            "((e.edge_role IN('PREDECESSOR','SUPPORTS') AND t.transition_id=e.to_node_id) " +
            "OR (e.edge_role='SUCCESSOR' AND t.transition_id=e.from_node_id)) " +
            "JOIN machine_states s ON s.state_id=t.to_state_id " +
            "WHERE s.prefix_ordinal=\(prefixOrdinal) " +
            "ORDER BY e.edge_role,e.overlay_edge_id", 4),
    ]
    for (sql, columns) in queries {
        result.append(["QUERY", sql])
        result.append(contentsOf: try machineRows(database, sql, columns: columns))
    }
    return result
}

private func machineRows(
    _ database: DisposalSQLiteConnection,
    _ sql: String,
    columns: Int
) throws -> [[String]] {
    let statement = try database.prepare(sql)
    var rows: [[String]] = []
    while try statement.step() {
        rows.append((0..<columns).map { statement.optionalText(Int32($0)) ?? "NULL" })
    }
    return rows
}

private func machinePrefixJournal() -> (journal: Data, frames: [Data]) {
    let start = machineObject([
        "arc_label": machineString("machine-prefix-test"),
        "consumption_state": machineString("ABSTAIN_NOT_RECORDED"),
        "epoch_label": machineString("machine-prefix-epoch"),
        "invocation_id": machineString(
            "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"),
        "retry_authorized": machineBoolean(false),
        "schema": machineString("unknown-machine-start/v1"),
    ])
    let middle = machineObject([
        "schema": machineString("unknown-machine-resource/v1"),
    ])
    let terminal = machineObject([
        "capture_state": machineString("ABSTAIN"),
        "completion_class": machineString("ABSTAIN_INCOMPLETE"),
        "gate_e_outcome": machineString("ABSTAIN"),
        "schema": machineString("unknown-machine-terminal/v1"),
        "status": machineString("ABSTAIN_TEST_ONLY"),
    ])
    var previous: String?
    var frames: [Data] = []
    for (ordinal, value) in [
        (DisposalEventType.start, start),
        (DisposalEventType.policy, middle),
        (DisposalEventType.terminal, terminal),
    ].enumerated() {
        let payload = value.1.canonicalData()
        let outer = machineObject([
            "authoritative": machineBoolean(false),
            "authority_vector": machineString("00000000"),
            "event_type": machineString(value.0.rawValue),
            "may_feed_controller": machineBoolean(false),
            "ordinal": machineNumber(String(ordinal)),
            "payload": value.1,
            "payload_hash_rule": machineString(DisposalEventJournal.payloadHashRule),
            "payload_sha256": machineString(disposalSHA256(payload)),
            "previous_frame_sha256": previous.map(machineString) ?? machineNull(),
            "prose_may_supply_fact": machineBoolean(false),
            "schema": machineString(DisposalEventJournal.frameSchema),
        ])
        var frame = outer.canonicalData()
        frame.append(0x0a)
        frames.append(frame)
        previous = disposalSHA256(frame)
    }
    return (frames.reduce(into: Data()) { $0.append($1) }, frames)
}

private func machineObject(_ members: [String: DisposalJSONValue]) -> DisposalJSONValue {
    .object(
        members.map { DisposalJSONObjectMember(key: $0.key, value: $0.value) },
        disposalZeroSpan)
}

private func machineString(_ value: String) -> DisposalJSONValue {
    .string(value, disposalZeroSpan)
}

private func machineNumber(_ value: String) -> DisposalJSONValue {
    .number(value, disposalZeroSpan)
}

private func machineBoolean(_ value: Bool) -> DisposalJSONValue {
    .boolean(value, disposalZeroSpan)
}

private func machineNull() -> DisposalJSONValue {
    .null(disposalZeroSpan)
}
