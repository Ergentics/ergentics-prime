import Darwin
import Foundation
@testable import DisposalProjectionCore
import XCTest

final class DisposalTypedProcessEvidenceTests: XCTestCase {
    func testR19ExactSchemasPopulateTypedProcessTablesAndStableIDs() throws {
        let fixture = typedR19Journal()
        let first = try typedExtract(fixture.journal)
        let second = try typedExtract(fixture.journal)

        XCTAssertEqual(first.insertion.ids, second.insertion.ids)
        XCTAssertEqual(first.insertion.ids.targetIDs.count, 3)
        XCTAssertEqual(first.insertion.ids.processReceiptIDs.count, 3)
        XCTAssertEqual(first.insertion.ids.domainSnapshotIDs.count, 10)
        XCTAssertEqual(first.insertion.ids.targetSnapshotIDs.count, 2)
        XCTAssertEqual(first.insertion.ids.snapshotPairIDs.count, 2)
        XCTAssertEqual(first.insertion.ids.namespaceObservationIDs.count, 1)
        XCTAssertEqual(first.insertion.ids.commitmentIDs.count, 1)
        XCTAssertEqual(first.insertion.ids.signalCallIDs.count, 1)
        XCTAssertEqual(first.insertion.ids.signalZeroCallIDs.count, 4)
        XCTAssertEqual(first.insertion.ids.absenceProofIDs.count, 2)
        XCTAssertEqual(first.insertion.ids.conservationIDs.count, 2)
        XCTAssertEqual(first.insertion.ids.waitCallIDs, [])
        XCTAssertEqual(first.insertion.ids.reapIDs, [])
        XCTAssertNotNil(first.insertion.guardianConservationID)
        XCTAssertNotNil(first.insertion.fixtureConservationID)
        XCTAssertEqual(first.insertion.missingEvidence.count, 3)
        XCTAssertTrue(first.insertion.missingEvidence.contains {
            $0.reasonCode ==
                "LEGACY_SNAPSHOT_HAS_VNODE_METADATA_WITHOUT_EMBEDDED_RAW_HELD_ARTIFACT"
        })

        let database = first.database
        XCTAssertEqual(try database.scalarInt("SELECT count(*) FROM targets"), 3)
        XCTAssertEqual(
            try database.scalarText(
                "SELECT group_concat(target_role,',') FROM (SELECT target_role FROM targets ORDER BY target_role)"),
            "DISPOSAL_CONTROLLER,R19_FIXTURE,R19_GUARDIAN")
        XCTAssertEqual(
            try database.scalarText("SELECT delivery_class FROM signal_calls"),
            "DELIVERED")
        XCTAssertEqual(
            try database.scalarText("SELECT operation||':'||signal_number FROM commitments"),
            "KILL:9")
        XCTAssertEqual(
            try database.scalarInt(
                "SELECT count(*) FROM conservations WHERE completion_state='COMPLETE' AND generation_absent=1 AND group_empty=1 AND session_empty=1 AND two_signal_zero_esrch=1"),
            2)
        XCTAssertEqual(
            try database.scalarInt(
                "SELECT count(*) FROM snapshot_pairs WHERE evidence_shape='SOURCE_ASSERTED_EQUAL_COLLAPSED' AND equality_state='EQUAL'"),
            2)
        XCTAssertEqual(
            try database.scalarInt(
                "SELECT count(*) FROM absence_attempts WHERE candidate_state='ACCEPTED_CANDIDATE'"),
            4)
        XCTAssertEqual(
            try database.scalarInt(
                "SELECT count(*) FROM conservation_set_conservation_states WHERE merkle_state='ABSENT_UNKNOWN'"),
            2)
        XCTAssertEqual(
            try database.scalarText(
                "SELECT obligation_state FROM commitment_obligation_projection"),
            "ABSTAIN")
        XCTAssertEqual(try database.scalarInt("SELECT count(*) FROM target_provenance"), 3)
        XCTAssertEqual(try database.scalarInt("SELECT count(*) FROM frame_adapter_coverage"), 7)
    }

    func testR18ExactReapMapsWaitAndReapWithoutInventingSessionConservation() throws {
        let start = typedObject(["schema": typedString("unknown/raw-only/v1")])
        let worker = typedLegacyReceipt(pid: 5_741, uniqueID: 8_864_228, idVersion: 17_278_502)
        let terminal = typedObject([
            "lineage": typedObject([
                "worker_exact_reap": typedObject([
                    "exit_status": typedNull(),
                    "exited": typedBoolean(false),
                    "pid": typedNumber("5741"),
                    "raw_status": typedNumber("9"),
                    "signaled": typedBoolean(true),
                    "term_signal": typedNumber("9"),
                ]),
                "worker_postexec": worker,
            ]),
            "schema": typedString("prime-driver-v2-r18-process-actuation-canary/v1"),
            "status": typedString("R18_PROCESS_ACTUATION_CANARY_PASS"),
        ])
        let journal = typedJournal([
            (.start, start),
            (.terminal, terminal),
        ])
        let extracted = try typedExtract(journal)
        XCTAssertEqual(extracted.insertion.ids.targetIDs.count, 1)
        XCTAssertEqual(extracted.insertion.ids.processReceiptIDs.count, 1)
        XCTAssertEqual(extracted.insertion.ids.waitCallIDs.count, 1)
        XCTAssertEqual(extracted.insertion.ids.reapIDs.count, 1)
        XCTAssertEqual(extracted.insertion.ids.conservationIDs, [])
        XCTAssertTrue(extracted.insertion.missingEvidence.contains {
            $0.evidenceKind == "R18_SESSION_CONSERVATION_INVENTORY"
        })
        XCTAssertEqual(
            try extracted.database.scalarText(
                "SELECT wait_ownership||':'||wait_api||':'||return_state FROM wait_calls"),
            "CONTROLLER_DIRECT_CHILD:WAITPID:RETURNED")
        XCTAssertEqual(
            try extracted.database.scalarText(
                "SELECT signaled||':'||termination_signal||':'||exact_wait_owner_join FROM reap_results"),
            "1:9:1")
    }

    func testUnknownSchemaRemainsRawOnlyAndKnownSchemaMismatchRejects() throws {
        let unknown = typedJournal([
            (.start, typedObject([
                "controller_pid": typedNumber("7000"),
                "schema": typedString("not-in-frozen-adapter/v1"),
            ])),
        ])
        let rawOnly = try typedExtract(unknown)
        XCTAssertEqual(rawOnly.insertion.ids.targetIDs, [])
        XCTAssertEqual(rawOnly.insertion.ids.commitmentIDs, [])
        XCTAssertEqual(rawOnly.insertion.ids.conservationIDs, [])
        XCTAssertEqual(rawOnly.insertion.ids.frameAdapterCoverageIDs.count, 1)
        XCTAssertEqual(try rawOnly.database.scalarInt("SELECT count(*) FROM targets"), 0)
        XCTAssertEqual(rawOnly.insertion.missingEvidence.count, 1)

        let mismatch = typedJournal([
            (.start, typedObject(["schema": typedString("unknown/raw-only/v1")])),
            (.snapshot, typedObject([
                "controller_pid": typedNumber("7000"),
                "fixed_fixture_generation": typedArray([
                    typedNumber("7002"), typedNumber("9002"), typedNumber("10002")]),
                "fixed_guardian_generation": typedArray([
                    typedNumber("7001"), typedNumber("9001"), typedNumber("10001")]),
                "schema": typedString("prime-driver-v2-r19-coordinated-disposal-start/v1"),
            ])),
        ])
        XCTAssertThrowsError(try typedExtract(mismatch)) { error in
            XCTAssertEqual((error as? DisposalProjectionRejection)?.code, "TYPED_SCHEMA_EVENT_TYPE")
        }

        let missing = typedJournal([
            (.start, typedObject([
                "schema": typedString("prime-driver-v2-r19-coordinated-disposal-start/v1"),
            ])),
        ])
        XCTAssertThrowsError(try typedExtract(missing)) { error in
            XCTAssertEqual((error as? DisposalProjectionRejection)?.code, "TYPED_REQUIRED_MEMBER")
        }
    }

    func testConservationSetDDLRejectsSourceStreamInvocationAndEpochContradictions() throws {
        let database = try DisposalSQLiteConnection()
        defer { try? database.close() }
        let ddl = try disposalResourceData("001-evidence", extension: "sql")
        try database.execute(String(decoding: ddl, as: UTF8.self))

        let artifactID = String(repeating: "1", count: 64)
        let invocationA = String(repeating: "2", count: 64)
        let invocationB = String(repeating: "3", count: 64)
        let streamID = String(repeating: "4", count: 64)
        let frameID = String(repeating: "5", count: 64)
        let digest = String(repeating: "6", count: 64)
        try database.execute(
            "INSERT INTO input_artifacts(" +
                "artifact_id,artifact_role,logical_path,availability,admission_grade," +
                "byte_count,raw_sha256,raw_bytes) VALUES(" +
                "'\(artifactID)','DISPOSAL_JOURNAL','retained/test.jsonl'," +
                "'LEDGER_EMBEDDED_COPY','CANONICAL_JOURNAL_FRAME_EXACT',2," +
                "'\(digest)',X'7B7D')")
        for (invocationID, epoch) in [(invocationA, "EPOCH_A"), (invocationB, "EPOCH_B")] {
            try database.execute(
                "INSERT INTO invocations(" +
                    "invocation_id,arc_label,epoch_label,source_artifact_id," +
                    "consumption_state,retry_authorized,authority_vector) VALUES(" +
                    "'\(invocationID)','TEST','\(epoch)','\(artifactID)'," +
                    "'ABSTAIN_NOT_RECORDED',0,'00000000')")
        }
        try database.execute(
            "INSERT INTO streams VALUES(" +
                "'\(streamID)','\(invocationA)','\(artifactID)','DISPOSAL_JOURNAL'," +
                "'RETAINED_PREFIX_NONTERMINAL','\(digest)',2)")
        try database.execute(
            "INSERT INTO frames VALUES(" +
                "'\(frameID)','\(streamID)','\(artifactID)',0,NULL,NULL,0,2,0,X'7B7D'," +
                "'\(digest)',NULL,'\(digest)',NULL,'test/v1',NULL)")

        func insertion(setID: String, invocationID: String, epoch: String) -> String {
            "INSERT INTO conservation_set_commitments VALUES(" +
                "'\(setID)','\(frameID)','\(invocationID)','\(epoch)'," +
                "'COMPLETE_ACTUATION_OBLIGATION_SET'," +
                "'INVOCATION_ACTUATION_OBLIGATIONS','\(invocationID)','SHA256'," +
                "'ERGENTICS_DISPOSAL_CONSERVATION_SET_LENGTH_FRAMED_V1'," +
                "'OBLIGATION_KEY_SHA256_RAW_ASC','REJECT_DUPLICATE_OBLIGATION_KEY'," +
                "'RFC6962_LARGEST_POWER_OF_TWO_SPLIT_WITH_ERGENTICS_LENGTH_FRAMED_HASHES'," +
                "'RFC6962_NO_DUPLICATION','\(digest)',1,'EXPLICIT_PRECONSERVATION')"
        }
        func assertJoinRejected(_ sql: String, file: StaticString = #filePath, line: UInt = #line) {
            XCTAssertThrowsError(try database.execute(sql), file: file, line: line) { error in
                guard case let DisposalSQLiteFailure.rejected(code, detail) = error else {
                    return XCTFail("unexpected error: \(error)", file: file, line: line)
                }
                XCTAssertEqual(code, "SQLITE_EXEC", file: file, line: line)
                XCTAssertTrue(
                    detail.contains("merkle-set-source-invocation-epoch-join"),
                    detail,
                    file: file,
                    line: line)
            }
        }

        assertJoinRejected(insertion(
            setID: String(repeating: "7", count: 64),
            invocationID: invocationB,
            epoch: "EPOCH_B"))
        assertJoinRejected(insertion(
            setID: String(repeating: "8", count: 64),
            invocationID: invocationA,
            epoch: "WRONG_EPOCH"))
        try database.execute(insertion(
            setID: String(repeating: "9", count: 64),
            invocationID: invocationA,
            epoch: "EPOCH_A"))
        XCTAssertEqual(try database.scalarInt("SELECT count(*) FROM conservation_set_commitments"), 1)
    }

    func testExplicitPriorConservationSetMerkleCommitmentJoinsExactly() throws {
        let extracted = try typedExtract(typedMerkleJournal())
        XCTAssertEqual(extracted.insertion.ids.conservationSetCommitmentIDs.count, 1)
        XCTAssertEqual(extracted.insertion.ids.conservationSetMembershipIDs.count, 1)
        XCTAssertEqual(extracted.insertion.ids.conservationSetMappingIDs.count, 1)
        XCTAssertEqual(
            try extracted.database.scalarText(
                "SELECT merkle_state FROM conservation_set_conservation_states"),
            "VERIFIED_PRIOR_EXACT")
        XCTAssertEqual(
            try extracted.database.scalarInt(
                "SELECT count(*) FROM conservation_set_obligation_mappings WHERE mapping_state='EXPLICIT_SAME_GENERATION'"),
            1)
        XCTAssertEqual(
            try extracted.database.scalarText(
                "SELECT tree_shape FROM conservation_set_commitments"),
            DisposalConservationSetMerkle.treeShape)
        XCTAssertEqual(
            try extracted.database.scalarText(
                "SELECT obligation_state FROM commitment_obligation_projection"),
            "CONSERVED")

        let membershipID = try extracted.database.scalarText(
            "SELECT membership_id FROM conservation_set_memberships")
        let controllerTargetID = try extracted.database.scalarText(
            "SELECT target_id FROM targets WHERE target_role='DISPOSAL_CONTROLLER'")
        let conservationID = try extracted.database.scalarText(
            "SELECT conservation_id FROM conservation_set_conservation_states " +
                "WHERE merkle_state='VERIFIED_PRIOR_EXACT'")
        let setID = try extracted.database.scalarText(
            "SELECT conservation_set_commitment_id FROM conservation_set_commitments")
        let setFrameID = try extracted.database.scalarText(
            "SELECT source_frame_id FROM conservation_set_commitments")
        XCTAssertThrowsError(try extracted.database.execute(
            "INSERT INTO conservation_set_membership_proof_nodes VALUES(" +
                "'\(membershipID)',0,'LEFT','\(String(repeating: "0", count: 64))')"))
        XCTAssertThrowsError(try extracted.database.execute(
            "INSERT INTO conservation_set_memberships " +
                "SELECT '\(String(repeating: "a", count: 64))'," +
                "conservation_set_commitment_id,leaf_ordinal+1,obligation_key_sha256," +
                "obligation_commitment_id,'\(controllerTargetID)',target_role,target_form," +
                "expected_uniqueid_text,expected_idversion_text,operation,numeric_argument," +
                "signal_number,budget_ordinal,commitment_source_frame_id," +
                "commitment_frame_lf_sha256,leaf_sha256,proof_sha256,proof_depth " +
                "FROM conservation_set_memberships WHERE membership_id='\(membershipID)'"))
        XCTAssertThrowsError(try extracted.database.execute(
            "INSERT INTO conservation_set_conservation_states VALUES(" +
                "'\(conservationID)','\(setFrameID)','\(setID)','VERIFIED_PRIOR_EXACT')"))
        XCTAssertThrowsError(try extracted.database.execute(
            "INSERT INTO conservation_set_obligation_mappings VALUES(" +
                "'\(String(repeating: "b", count: 64))','\(conservationID)','\(setID)'," +
                "'\(membershipID)','\(controllerTargetID)','EXPLICIT_SAME_GENERATION')"))
    }

    func testRichTypedMerkleGraphIsPrefixStableAndReachesD50() throws {
        let journal = typedRichMerkleJournal()
        let decoded = try DisposalEventJournal.decode(journal)
        let logicalPath = "retained/typed-rich-merkle-prefix.jsonl"
        let full = try DisposalProjectionSetBuilder.makeMaterial(request: .init(
            journal: journal,
            journalLogicalPath: logicalPath))
        let fullGraph = try DisposalSQLiteConnection(serializedReadOnly: full.graph)
        defer { try? fullGraph.close() }

        XCTAssertEqual(
            try fullGraph.scalarText(
                "SELECT matched_rule_id||':'||state_class FROM machine_states " +
                    "ORDER BY prefix_ordinal DESC LIMIT 1"),
            "D50:CONSERVATION_RECORDED")
        XCTAssertEqual(
            try fullGraph.scalarText(
                "SELECT t.preconservation_merkle_committed||':'||w.witness_kind " +
                    "FROM machine_transitions t JOIN machine_states s ON s.state_id=t.to_state_id " +
                    "JOIN machine_witnesses w ON w.witness_id=t.preconservation_commitment_witness_id " +
                    "WHERE s.prefix_ordinal=\(decoded.frames.count - 1)"),
            "TRUE:conservation_set_commitments")
        XCTAssertEqual(
            try typedGraphRows(
                fullGraph,
                "SELECT p.predicate_clause,p.actual_scalar,p.normalized_state " +
                    "FROM machine_transition_predicates p JOIN machine_transitions t " +
                    "ON t.transition_id=p.transition_id JOIN machine_states s " +
                    "ON s.state_id=t.to_state_id WHERE s.prefix_ordinal=\(decoded.frames.count - 1) " +
                    "AND p.rule_id='D50' ORDER BY p.clause_ordinal",
                columns: 3),
            [
                ["actuation_obligation_count>0", "2", "TRUE"],
                ["exact_preconservation_obligation_set_commitment=true", "true", "TRUE"],
                ["all_committed_obligations_conserved=true", "true", "TRUE"],
                ["terminal_count=0", "0", "TRUE"],
            ])
        XCTAssertEqual(
            try fullGraph.scalarText(
                "SELECT matched_rule_id FROM machine_states WHERE prefix_ordinal=2"),
            "D20")
        XCTAssertEqual(
            try fullGraph.scalarText(
                "SELECT matched_rule_id FROM machine_states WHERE prefix_ordinal=3"),
            "D30")
        XCTAssertEqual(
            try fullGraph.scalarText(
                "SELECT preconservation_merkle_committed FROM machine_transitions t " +
                    "JOIN machine_states s ON s.state_id=t.to_state_id WHERE s.prefix_ordinal=7"),
            "UNKNOWN")
        XCTAssertNotEqual(
            try fullGraph.scalarText(
                "SELECT matched_rule_id FROM machine_states WHERE prefix_ordinal=7"),
            "D50")

        for prefixOrdinal in decoded.frames.indices {
            let prefix = decoded.frames[0...prefixOrdinal].reduce(into: Data()) {
                $0.append($1.rawWithLF)
            }
            let truncated = try DisposalProjectionSetBuilder.makeMaterial(request: .init(
                journal: prefix,
                journalLogicalPath: logicalPath))
            let truncatedGraph = try DisposalSQLiteConnection(
                serializedReadOnly: truncated.graph)
            defer { try? truncatedGraph.close() }
            XCTAssertEqual(
                try typedGraphPrefixStateRows(fullGraph, prefixOrdinal: prefixOrdinal),
                try typedGraphPrefixStateRows(truncatedGraph, prefixOrdinal: prefixOrdinal),
                "state prefix \(prefixOrdinal)")
            XCTAssertEqual(
                try typedGraphPrefixSemanticRows(fullGraph, prefixOrdinal: prefixOrdinal),
                try typedGraphPrefixSemanticRows(truncatedGraph, prefixOrdinal: prefixOrdinal),
                "semantic prefix \(prefixOrdinal)")

            let evidence = try DisposalSQLiteConnection(serializedReadOnly: truncated.evidence)
            defer { try? evidence.close() }
            XCTAssertEqual(
                try evidence.scalarInt(
                    "SELECT count(*) FROM missing_evidence WHERE evidence_kind='TERMINAL_FRAME' " +
                        "AND source_frame_id IS NULL AND evidence_scope='PROJECTION_GLOBAL_NON_PREFIX'"),
                1)
            if prefixOrdinal == 3 {
                XCTAssertEqual(
                    try evidence.scalarInt(
                        "SELECT count(*) FROM missing_evidence " +
                            "WHERE evidence_kind='POST_SIGNAL_CONSERVATION' " +
                            "AND source_frame_id IS NULL " +
                            "AND evidence_scope='PROJECTION_GLOBAL_NON_PREFIX'"),
                    1)
            }
            if prefixOrdinal == 7 {
                XCTAssertEqual(
                    try evidence.scalarInt(
                        "SELECT count(*) FROM commitment_obligation_projection " +
                            "WHERE obligation_state='CONTAINMENT_REQUIRED'"),
                    2)
            }
            if prefixOrdinal == 8 {
                XCTAssertEqual(
                    try evidence.scalarInt(
                        "SELECT count(*) FROM commitment_obligation_projection " +
                            "WHERE obligation_state='CONSERVED'"),
                    1)
                XCTAssertEqual(
                    try evidence.scalarInt(
                        "SELECT count(*) FROM commitment_obligation_projection " +
                            "WHERE obligation_state='CONTAINMENT_REQUIRED'"),
                    1)
            }
            if prefixOrdinal == 9 {
                XCTAssertEqual(
                    try evidence.scalarInt(
                        "SELECT count(*) FROM commitment_obligation_projection " +
                            "WHERE obligation_state='CONSERVED'"),
                    2)
            }
        }
    }

    func testBuiltGraphCoversD60D70D80AndD40IsReservedUnreachable() throws {
        let terminal = typedObject([
            "capture_state": typedString("EXACT_RETAINED"),
            "completion_class": typedString("CONSERVATION_COMPLETE"),
            "gate_e_outcome": typedString("ABSTAIN"),
            "schema": typedString("prime-driver-v2-r19-coordinated-disposal/v1"),
            "status": typedString("TYPED_D60_TERMINAL"),
        ])
        let d60Journal = typedAppendFrame(
            typedRichMerkleJournal(), eventType: .terminal, payload: terminal)
        XCTAssertEqual(
            try typedFinalMachineState(d60Journal),
            "D60:TERMINAL_RECORDED")

        let d70Journal = typedJournal([
            (.start, typedMinimalR19Start()),
            (.terminal, typedObject([
                "capture_state": typedString("EXACT_RETAINED"),
                "completion_class": typedString("PREACTUATION_REJECTED"),
                "gate_e_outcome": typedString("ABSTAIN"),
                "schema": typedString("prime-driver-v2-r19-coordinated-disposal/v1"),
                "status": typedString("TYPED_D70_TERMINAL"),
            ])),
        ])
        XCTAssertEqual(try typedFinalMachineState(d70Journal), "D70:REJECTED")
        XCTAssertEqual(
            try typedFinalMachineState(typedR19Journal().journal),
            "D80:ABSTAIN_INCOMPLETE")

        let notEntered = try DisposalEventJournal.decode(
            typedMerkleJournal(signalCallEntered: false))
        let notEnteredPrefix = notEntered.frames[0...3].reduce(into: Data()) {
            $0.append($1.rawWithLF)
        }
        let material = try DisposalProjectionSetBuilder.makeMaterial(request: .init(
            journal: notEnteredPrefix,
            journalLogicalPath: "retained/typed-d40-unreachable.jsonl"))
        let evidence = try DisposalSQLiteConnection(serializedReadOnly: material.evidence)
        let graph = try DisposalSQLiteConnection(serializedReadOnly: material.graph)
        defer {
            try? evidence.close()
            try? graph.close()
        }
        XCTAssertEqual(
            try evidence.scalarText(
                "SELECT entry_state||':'||return_state FROM signal_calls"),
            "NOT_ENTERED:NOT_RETURNED")
        XCTAssertEqual(
            try graph.scalarText(
                "SELECT matched_rule_id||':'||state_class FROM machine_states " +
                    "ORDER BY prefix_ordinal DESC LIMIT 1"),
            "D80:ABSTAIN_INCOMPLETE")
        XCTAssertEqual(
            try graph.scalarInt(
                "SELECT count(*) FROM machine_states WHERE matched_rule_id='D40'"),
            0)
    }

    func testRichTypedMerkleProjectionReaderAdmitsExactSourceRoundTrip() throws {
        let root = "/private/tmp/ergentics-rich-reader-" +
            UUID().uuidString.lowercased()
        defer { typedRemoveProjection(root) }
        let report = try DisposalProjectionSetBuilder.build(
            request: .init(
                journal: typedRichMerkleJournal(),
                journalLogicalPath: "retained/typed-rich-reader.jsonl"),
            outputRootPath: root)
        guard case .admitted(let snapshot) = DisposalProjectionReader.load(
            rootPath: root,
            expectedSealSHA256: report.sealSHA256)
        else {
            XCTFail("rich typed projection did not admit")
            return
        }

        XCTAssertEqual(snapshot.counts.sourceConservationSets, 1)
        XCTAssertEqual(snapshot.counts.sourceConservationMemberships, 2)
        XCTAssertEqual(snapshot.counts.sourceConservationProofNodes, 2)
        XCTAssertEqual(snapshot.counts.sourceConservationMappings, 2)
        XCTAssertEqual(snapshot.sourceConservationSets.count, 1)
        XCTAssertEqual(snapshot.sourceConservationMemberships.count, 2)
        XCTAssertEqual(snapshot.sourceConservationProofNodes.count, 2)
        XCTAssertEqual(snapshot.sourceConservationMappings.count, 2)

        let evidence = try DisposalSQLiteConnection(serializedReadOnly: Data(
            contentsOf: URL(fileURLWithPath: report.evidencePath)))
        defer { try? evidence.close() }
        XCTAssertEqual(
            snapshot.sourceConservationSets.map {
                [
                    $0.id, $0.sourceFrameID, $0.sourceFrameLFSHA256,
                    $0.invocationID, $0.epochLabel, $0.purpose, $0.scopeKind,
                    $0.scopeID, $0.algorithm, $0.domainTag, $0.leafOrdering,
                    $0.duplicatePolicy, $0.treeShape, $0.oddLeafRule,
                    $0.witnessRootSHA256, String($0.leafCount), $0.temporalState,
                ]
            },
            try typedGraphRows(
                evidence,
                "SELECT s.conservation_set_commitment_id,s.source_frame_id," +
                    "f.raw_sha256_with_lf,s.invocation_id,s.epoch_label,s.purpose," +
                    "s.scope_kind,s.scope_id,s.algorithm,s.domain_tag,s.leaf_ordering," +
                    "s.duplicate_policy,s.tree_shape,s.odd_leaf_rule," +
                    "s.witness_root_sha256,s.leaf_count,s.temporal_state " +
                    "FROM conservation_set_commitments s JOIN frames f " +
                    "ON f.frame_id=s.source_frame_id ORDER BY s.source_frame_id",
                columns: 17))
        XCTAssertEqual(
            snapshot.sourceConservationMemberships.map {
                [
                    $0.id, $0.conservationSetID, String($0.leafOrdinal),
                    $0.obligationKeySHA256, $0.obligationCommitmentID, $0.targetID,
                    $0.targetRole, $0.targetForm, $0.expectedUniqueID,
                    $0.expectedIDVersion, $0.operation, String($0.numericArgument),
                    String($0.signalNumber), String($0.budgetOrdinal),
                    $0.commitmentFrameLFSHA256, $0.leafSHA256, $0.proofSHA256,
                    String($0.proofDepth),
                ]
            },
            try typedGraphRows(
                evidence,
                "SELECT membership_id,conservation_set_commitment_id,leaf_ordinal," +
                    "obligation_key_sha256,obligation_commitment_id,target_id,target_role," +
                    "target_form,expected_uniqueid_text,expected_idversion_text,operation," +
                    "numeric_argument,signal_number,budget_ordinal," +
                    "commitment_frame_lf_sha256,leaf_sha256,proof_sha256,proof_depth " +
                    "FROM conservation_set_memberships " +
                    "ORDER BY conservation_set_commitment_id,leaf_ordinal",
                columns: 18))
        XCTAssertEqual(
            snapshot.sourceConservationProofNodes.map {
                [
                    $0.membershipID, String($0.proofOrdinal),
                    $0.siblingPosition, $0.siblingSHA256,
                ]
            },
            try typedGraphRows(
                evidence,
                "SELECT membership_id,proof_ordinal,sibling_position,sibling_sha256 " +
                    "FROM conservation_set_membership_proof_nodes " +
                    "ORDER BY membership_id,proof_ordinal",
                columns: 4))
        XCTAssertEqual(
            snapshot.sourceConservationMappings.map {
                [
                    $0.id, $0.conservationID, $0.conservationSetID,
                    $0.membershipID, $0.targetID, $0.mappingState,
                    $0.merkleState, $0.conservationCompletionState,
                    $0.conservationSourceFrameLFSHA256,
                ]
            },
            try typedGraphRows(
                evidence,
                "SELECT m.mapping_id,m.conservation_id," +
                    "m.conservation_set_commitment_id,m.membership_id,m.target_id," +
                    "m.mapping_state,s.merkle_state,c.completion_state," +
                    "f.raw_sha256_with_lf FROM conservation_set_obligation_mappings m " +
                    "JOIN conservation_set_conservation_states s " +
                    "ON s.conservation_id=m.conservation_id " +
                    "AND s.conservation_set_commitment_id=" +
                    "m.conservation_set_commitment_id " +
                    "JOIN conservations c ON c.conservation_id=m.conservation_id " +
                    "JOIN frames f ON f.frame_id=c.source_frame_id ORDER BY m.mapping_id",
                columns: 9))

        let set = try XCTUnwrap(snapshot.sourceConservationSets.first)
        let memberships = snapshot.sourceConservationMemberships.sorted {
            $0.leafOrdinal < $1.leafOrdinal
        }
        XCTAssertEqual(set.leafCount, 2)
        XCTAssertEqual(set.temporalState, "EXPLICIT_PRECONSERVATION")
        XCTAssertEqual(set.algorithm, DisposalConservationSetMerkle.algorithm)
        XCTAssertEqual(set.domainTag, DisposalConservationSetMerkle.domainTag)
        XCTAssertEqual(
            set.witnessRootSHA256,
            try DisposalConservationSetMerkle.root(
                canonicalObligationKeys: memberships.map(\.obligationKeySHA256)))
        XCTAssertEqual(Set(memberships.map(\.conservationSetID)), Set([set.id]))
        XCTAssertEqual(Set(memberships.map(\.proofDepth)), Set([1]))
        XCTAssertEqual(
            Set(snapshot.sourceConservationMappings.map(\.membershipID)),
            Set(memberships.map(\.id)))
        XCTAssertEqual(
            Set(snapshot.sourceConservationMappings.map(\.mappingState)),
            Set(["EXPLICIT_SAME_GENERATION"]))
        XCTAssertEqual(
            Set(snapshot.sourceConservationMappings.map(\.merkleState)),
            Set(["VERIFIED_PRIOR_EXACT"]))
        XCTAssertEqual(
            Set(snapshot.sourceConservationMappings.map(\.conservationCompletionState)),
            Set(["COMPLETE"]))
        let finalTransition = try XCTUnwrap(
            snapshot.machineTransitions.first { $0.matchedRuleID == "D50" })
        let witnessID = try XCTUnwrap(finalTransition.preconservationCommitmentWitnessID)
        XCTAssertEqual(finalTransition.preconservationMerkleCommitted, "TRUE")
        XCTAssertEqual(
            snapshot.machineWitnesses.first { $0.id == witnessID }?.kind,
            "conservation_set_commitments")
        XCTAssertThrowsError(try disposalValidateSourceConservationSemanticRoundTrip(
            sets: snapshot.sourceConservationSets,
            memberships: snapshot.sourceConservationMemberships,
            proofNodes: snapshot.sourceConservationProofNodes,
            mappings: Array(snapshot.sourceConservationMappings.dropLast()),
            requiresCompleteMappingCoverage: true)) { error in
                XCTAssertEqual(
                    (error as? DisposalProjectionRejection)?.code,
                    "DISPOSAL_READER_MAPPING_COVERAGE")
            }
    }

    func testConservationSetReferenceSameFrameFutureAndMismatchReject() throws {
        for (mutation, expectedCode) in [
            (TypedMerkleMutation.sameFrame, "TYPED_MERKLE_TEMPORAL_ORDER"),
            (.futureFrame, "TYPED_MERKLE_TEMPORAL_ORDER"),
            (.rootMismatch, "TYPED_EXACT_STRING"),
            (.scopeMismatch, "TYPED_EXACT_STRING"),
            (.algorithmMismatch, "TYPED_EXACT_STRING"),
            (.treeMismatch, "TYPED_EXACT_STRING"),
            (.leafMismatch, "TYPED_MERKLE_LEAF_HASH"),
            (.wrongTarget, "TYPED_EXACT_INTEGER"),
            (.omittedObligation, "TYPED_MERKLE_EMPTY_SET"),
            (.extraObligation, "TYPED_MERKLE_NOT_FULL_OBLIGATION_SET"),
            (.laterObligation, "TYPED_MERKLE_LATER_UNCOMMITTED_OBLIGATION"),
        ] {
            XCTAssertThrowsError(try typedExtract(typedMerkleJournal(mutation: mutation))) { error in
                XCTAssertEqual(
                    (error as? DisposalProjectionRejection)?.code,
                    expectedCode,
                    "mutation=\(mutation)")
            }
        }
    }

    func testMerkleSplitProofsZeroThroughFiveAndLengthFraming() throws {
        XCTAssertThrowsError(
            try DisposalConservationSetMerkle.root(canonicalObligationKeys: []))
        for count in 1...5 {
            let keys = (0..<count).map {
                DisposalConservationSetMerkle.semanticID("test-leaf-v1", [String($0)])
            }.sorted()
            let leaves = keys.map {
                DisposalConservationSetMerkle.leafSHA256(obligationKeySHA256: $0)
            }
            let root = try DisposalConservationSetMerkle.root(
                canonicalObligationKeys: keys)
            for index in leaves.indices {
                let proof = try DisposalConservationSetMerkle.proof(
                    leafOrdinal: index,
                    canonicalObligationKeys: keys)
                XCTAssertTrue(DisposalConservationSetMerkle.verify(
                    leafSHA256: leaves[index], proof: proof, rootSHA256: root))
                if !proof.isEmpty {
                    var mutated = proof
                    mutated[0] = .init(
                        siblingPosition: proof[0].siblingPosition == "LEFT" ? "RIGHT" : "LEFT",
                        siblingSHA256: proof[0].siblingSHA256)
                    XCTAssertFalse(DisposalConservationSetMerkle.verify(
                        leafSHA256: leaves[index], proof: mutated, rootSHA256: root))
                }
            }
        }
        let first = DisposalConservationSetMerkle.semanticID("key-v1", ["first"])
        let second = DisposalConservationSetMerkle.semanticID("key-v1", ["second"])
        let ordered = [first, second].sorted()
        XCTAssertThrowsError(try DisposalConservationSetMerkle.root(
            canonicalObligationKeys: Array(ordered.reversed())))
        XCTAssertThrowsError(try DisposalConservationSetMerkle.root(
            canonicalObligationKeys: [ordered[0], ordered[0]]))
        XCTAssertThrowsError(try DisposalConservationSetMerkle.root(
            canonicalObligationKeys: ["not-a-sha256"]))
        let validLeaf = DisposalConservationSetMerkle.leafSHA256(
            obligationKeySHA256: ordered[0])
        XCTAssertFalse(DisposalConservationSetMerkle.verify(
            leafSHA256: validLeaf,
            proof: [.init(siblingPosition: "SIDEWAYS", siblingSHA256: ordered[1])],
            rootSHA256: ordered[0]))
        XCTAssertNotEqual(
            DisposalConservationSetMerkle.semanticID("d", ["a\0b", "c"]),
            DisposalConservationSetMerkle.semanticID("d", ["a", "b\0c"]))
        XCTAssertNotEqual(
            DisposalConservationSetMerkle.semanticID("d", ["ab", "c"]),
            DisposalConservationSetMerkle.semanticID("d", ["a", "bc"]))
    }
}

private enum TypedMerkleMutation: Equatable, CustomStringConvertible {
    case none
    case sameFrame
    case futureFrame
    case rootMismatch
    case scopeMismatch
    case algorithmMismatch
    case treeMismatch
    case leafMismatch
    case wrongTarget
    case omittedObligation
    case extraObligation
    case laterObligation

    var description: String {
        switch self {
        case .none: return "none"
        case .sameFrame: return "sameFrame"
        case .futureFrame: return "futureFrame"
        case .rootMismatch: return "rootMismatch"
        case .scopeMismatch: return "scopeMismatch"
        case .algorithmMismatch: return "algorithmMismatch"
        case .treeMismatch: return "treeMismatch"
        case .leafMismatch: return "leafMismatch"
        case .wrongTarget: return "wrongTarget"
        case .omittedObligation: return "omittedObligation"
        case .extraObligation: return "extraObligation"
        case .laterObligation: return "laterObligation"
        }
    }
}

private func typedMerkleJournal(
    mutation: TypedMerkleMutation = .none,
    signalCallEntered: Bool = true
) -> Data {
    let invocationID = String(repeating: "1", count: 64)
    let receipt = typedLegacyReceipt(pid: 7_001, uniqueID: 9_001, idVersion: 10_001)
    let snapshot = typedObject([
        "cwd": typedObject([
            "device": typedNumber("16"), "inode": typedNumber("31"),
            "path": typedString("/private/tmp/control"),
        ]),
        "group_members": typedArray([receipt]),
        "kind": typedString("present"),
        "mapped_image": typedObject([
            "device": typedNumber("16"), "inode": typedNumber("30"),
        ]),
        "path": typedString("/usr/bin/ruby"),
        "process": receipt,
        "role": typedString("guardian"),
        "session_members": typedArray([receipt]),
    ])
    let certificate = disposalSHA256(snapshot.canonicalData())
    let start = typedObject([
        "arc_label": typedString("TYPED_MERKLE_TEST"),
        "consumption_state": typedString("ABSTAIN_NOT_RECORDED"),
        "controller_pid": typedNumber("7000"),
        "epoch_label": typedString("TYPED_TEST_EPOCH"),
        "fixed_fixture_generation": typedArray([
            typedNumber("7002"), typedNumber("9002"), typedNumber("10002")]),
        "fixed_guardian_generation": typedArray([
            typedNumber("7001"), typedNumber("9001"), typedNumber("10001")]),
        "invocation_id": typedString(invocationID),
        "retry_authorized": typedBoolean(false),
        "schema": typedString("prime-driver-v2-r19-coordinated-disposal-start/v1"),
    ])
    let prestate = typedObject([
        "guardian": snapshot,
        "guardian_terminal_namespace": typedObject([
            "kind": typedString("absent"), "staging": typedArray([]),
        ]),
        "schema": typedString("prime-driver-v2-r19-coordinated-disposal-prestate/v1"),
    ])
    let commitment = typedObject([
        "atomic_generation_bound_signal_available": typedBoolean(false),
        "call_may_enter_after_this_record": typedBoolean(true),
        "generation": typedArray([typedNumber("9001"), typedNumber("10001")]),
        "missing_result_means_may_have_entered": typedBoolean(true),
        "prestate_sha256": typedString(certificate),
        "retry_authorized": typedBoolean(false),
        "role": typedString("guardian"),
        "schema": typedString("prime-driver-v2-r19-kill-commitment/v1"),
        "target": typedNumber("7001"),
    ])
    var signalResultMembers = [
        "call_entered": typedBoolean(signalCallEntered),
        "certificate_age_ns_at_preentry_check": typedNumber("20"),
        "certificate_max_age_ns": typedNumber("5000000"),
        "delivered": typedBoolean(signalCallEntered),
        "retried": typedBoolean(false),
        "role": typedString("guardian"),
    ]
    if signalCallEntered {
        signalResultMembers["errno"] = typedNumber("0")
        signalResultMembers["return"] = typedNumber("0")
    }
    let signal = typedObject([
        "result": typedObject(signalResultMembers),
        "schema": typedString("prime-driver-v2-r19-kill-result/v1"),
    ])
    let prefix = typedJournal([
        (.start, start), (.snapshot, prestate), (.commitment, commitment),
    ])
    let commitmentFrame = try! DisposalEventJournal.decode(prefix).frames[2]
    let obligationKey = DisposalConservationSetMerkle.obligationKey(
        commitmentFrameLFSHA256: commitmentFrame.rawWithLFSHA256,
        targetRole: "R19_GUARDIAN",
        targetForm: "POSITIVE_PID",
        targetPID: 7_001,
        targetUniqueID: 9_001,
        targetIDVersion: 10_001,
        operation: "KILL",
        numericArgument: 7_001,
        signalNumber: 9,
        budgetOrdinal: 1)
    let leaf = DisposalConservationSetMerkle.leafSHA256(
        obligationKeySHA256: obligationKey)
    let membership = typedObject([
        "budget_ordinal": typedNumber("1"),
        "commitment_frame_lf_sha256": typedString(commitmentFrame.rawWithLFSHA256),
        "commitment_frame_ordinal": typedNumber("2"),
        "expected_idversion": typedNumber("10001"),
        "expected_uniqueid": typedNumber("9001"),
        "leaf_ordinal": typedNumber("0"),
        "leaf_sha256": typedString(
            mutation == .leafMismatch ? String(repeating: "0", count: 64) : leaf),
        "numeric_argument": typedNumber("7001"),
        "obligation_key_sha256": typedString(obligationKey),
        "operation": typedString("KILL"),
        "proof": typedArray([]),
        "signal_number": typedNumber("9"),
        "target_form": typedString("POSITIVE_PID"),
        "target_pid": typedNumber(mutation == .wrongTarget ? "7002" : "7001"),
        "target_role": typedString("R19_GUARDIAN"),
    ])
    let membershipValues: [DisposalJSONValue]
    switch mutation {
    case .omittedObligation: membershipValues = []
    case .extraObligation: membershipValues = [membership, membership]
    default: membershipValues = [membership]
    }
    let merkle = typedObject([
        "algorithm": typedString(
            mutation == .algorithmMismatch ? "SHA512" : DisposalConservationSetMerkle.algorithm),
        "domain_tag": typedString(DisposalConservationSetMerkle.domainTag),
        "duplicate_policy": typedString(DisposalConservationSetMerkle.duplicatePolicy),
        "epoch_label": typedString("TYPED_TEST_EPOCH"),
        "invocation_id": typedString(invocationID),
        "leaf_count": typedNumber(String(membershipValues.count)),
        "leaf_ordering": typedString(DisposalConservationSetMerkle.leafOrdering),
        "memberships": typedArray(membershipValues),
        "odd_leaf_rule": typedString(DisposalConservationSetMerkle.oddLeafRule),
        "purpose": typedString(DisposalConservationSetMerkle.purpose),
        "schema": typedString(DisposalConservationSetMerkle.schema),
        "scope_id": typedString(invocationID),
        "scope_kind": typedString(DisposalConservationSetMerkle.scopeKind),
        "tree_shape": typedString(
            mutation == .treeMismatch ? "RFC6962_STANDARD_HASHING" :
                DisposalConservationSetMerkle.treeShape),
        "witness_root_sha256": typedString(leaf),
    ])
    let merklePrefix = typedJournal([
        (.start, start), (.snapshot, prestate), (.commitment, commitment),
        (.signalCall, signal), (.commitment, merkle),
    ])
    let merkleFrame = try! DisposalEventJournal.decode(merklePrefix).frames[4]
    let referenceOrdinal: Int
    switch mutation {
    case .sameFrame: referenceOrdinal = 5
    case .futureFrame: referenceOrdinal = 6
    default: referenceOrdinal = 4
    }
    let reference = typedObject([
        "algorithm": typedString(DisposalConservationSetMerkle.algorithm),
        "commitment_frame_lf_sha256": typedString(merkleFrame.rawWithLFSHA256),
        "commitment_frame_ordinal": typedNumber(String(referenceOrdinal)),
        "domain_tag": typedString(DisposalConservationSetMerkle.domainTag),
        "duplicate_policy": typedString(DisposalConservationSetMerkle.duplicatePolicy),
        "epoch_label": typedString("TYPED_TEST_EPOCH"),
        "invocation_id": typedString(invocationID),
        "leaf_count": typedNumber("1"),
        "leaf_ordering": typedString(DisposalConservationSetMerkle.leafOrdering),
        "obligation_keys": typedArray([typedString(obligationKey)]),
        "odd_leaf_rule": typedString(DisposalConservationSetMerkle.oddLeafRule),
        "purpose": typedString(DisposalConservationSetMerkle.purpose),
        "scope_id": typedString(
            mutation == .scopeMismatch ? String(repeating: "2", count: 64) : invocationID),
        "scope_kind": typedString(DisposalConservationSetMerkle.scopeKind),
        "tree_shape": typedString(DisposalConservationSetMerkle.treeShape),
        "witness_root_sha256": typedString(
            mutation == .rootMismatch ? String(repeating: "0", count: 64) : leaf),
    ])
    let round = typedObject([
        "generation": typedString("ESRCH"),
        "group_projection": typedArray([]),
        "pid": typedNumber("7001"),
        "session_projection": typedArray([]),
        "signal_zero": typedObject([
            "entered": typedBoolean(true), "errno": typedNumber("3"),
            "esrch": typedBoolean(true), "return": typedNumber("-1"),
        ]),
        "uniqueid": typedNumber("9001"),
    ])
    let conservation = typedObject([
        "proof": typedObject([
            "conservation_set_reference": reference,
            "kind": typedString("external_conservation"),
            "preexisting_absence": typedBoolean(false),
            "rounds": typedArray([round, round]),
            "signal_zero_entered_count": typedNumber("2"),
            "transient_fault_count": typedNumber("0"),
        ]),
        "schema": typedString("prime-driver-v2-r19-guardian-conservation/v1"),
        "signal_call_entered": typedBoolean(true),
        "signal_delivered": typedBoolean(true),
    ])
    var frames: [(DisposalEventType, DisposalJSONValue)] = [
        (.start, start), (.snapshot, prestate), (.commitment, commitment),
        (.signalCall, signal), (.commitment, merkle),
    ]
    if mutation == .laterObligation { frames.append((.commitment, commitment)) }
    frames.append((.conservation, conservation))
    return typedJournal(frames)
}

private struct TypedRichObligation {
    let key: String
    let role: String
    let form: String
    let pid: Int
    let uniqueID: UInt64
    let idVersion: UInt64
    let numericArgument: Int
    let commitmentOrdinal: Int
    let commitmentFrameLFSHA256: String
}

private func typedRichMerkleJournal() -> Data {
    let invocationID = String(repeating: "1", count: 64)
    let guardianReceipt = typedLegacyReceipt(
        pid: 7_001, uniqueID: 9_001, idVersion: 10_001)
    let fixtureReceipt = typedLegacyReceipt(
        pid: 7_002, uniqueID: 9_002, idVersion: 10_002)

    func snapshot(_ receipt: DisposalJSONValue, path: String) -> DisposalJSONValue {
        typedObject([
            "cwd": typedObject([
                "device": typedNumber("16"), "inode": typedNumber("31"),
                "path": typedString("/private/tmp/control"),
            ]),
            "group_members": typedArray([receipt]),
            "kind": typedString("present"),
            "mapped_image": typedObject([
                "device": typedNumber("16"), "inode": typedNumber("30"),
            ]),
            "path": typedString(path),
            "process": receipt,
            "role": typedString(path.contains("fixture") ? "fixture" : "guardian"),
            "session_members": typedArray([receipt]),
        ])
    }
    func commitment(
        role: String,
        target: Int,
        uniqueID: UInt64,
        idVersion: UInt64,
        certificate: String
    ) -> DisposalJSONValue {
        typedObject([
            "atomic_generation_bound_signal_available": typedBoolean(false),
            "call_may_enter_after_this_record": typedBoolean(true),
            "generation": typedArray([
                typedNumber(String(uniqueID)), typedNumber(String(idVersion)),
            ]),
            "missing_result_means_may_have_entered": typedBoolean(true),
            "prestate_sha256": typedString(certificate),
            "retry_authorized": typedBoolean(false),
            "role": typedString(role),
            "schema": typedString("prime-driver-v2-r19-kill-commitment/v1"),
            "target": typedNumber(String(target)),
        ])
    }
    func signal(_ role: String) -> DisposalJSONValue {
        typedObject([
            "result": typedObject([
                "call_entered": typedBoolean(true),
                "certificate_age_ns_at_preentry_check": typedNumber("20"),
                "certificate_max_age_ns": typedNumber("5000000"),
                "delivered": typedBoolean(true),
                "errno": typedNumber("0"),
                "return": typedNumber("0"),
                "retried": typedBoolean(false),
                "role": typedString(role),
            ]),
            "schema": typedString("prime-driver-v2-r19-kill-result/v1"),
        ])
    }

    let guardianSnapshot = snapshot(guardianReceipt, path: "/usr/bin/ruby")
    let fixtureSnapshot = snapshot(fixtureReceipt, path: "/private/tmp/fixture")
    let valuesBeforeSet: [(DisposalEventType, DisposalJSONValue)] = [
        (.start, typedMinimalR19Start()),
        (.snapshot, typedObject([
            "guardian": guardianSnapshot,
            "guardian_terminal_namespace": typedObject([
                "kind": typedString("absent"), "staging": typedArray([]),
            ]),
            "schema": typedString("prime-driver-v2-r19-coordinated-disposal-prestate/v1"),
        ])),
        (.commitment, commitment(
            role: "guardian", target: 7_001, uniqueID: 9_001, idVersion: 10_001,
            certificate: disposalSHA256(guardianSnapshot.canonicalData()))),
        (.signalCall, signal("guardian")),
        (.snapshot, typedObject([
            "fixture": fixtureSnapshot,
            "schema": typedString("prime-driver-v2-r19-fixture-prestate/v1"),
        ])),
        (.commitment, commitment(
            role: "fixture", target: -7_002, uniqueID: 9_002, idVersion: 10_002,
            certificate: disposalSHA256(fixtureSnapshot.canonicalData()))),
        (.signalCall, signal("fixture")),
    ]
    let beforeSet = try! DisposalEventJournal.decode(typedJournal(valuesBeforeSet))
    let guardianCommitment = beforeSet.frames[2]
    let fixtureCommitment = beforeSet.frames[5]
    let obligations = [
        TypedRichObligation(
            key: DisposalConservationSetMerkle.obligationKey(
                commitmentFrameLFSHA256: guardianCommitment.rawWithLFSHA256,
                targetRole: "R19_GUARDIAN", targetForm: "POSITIVE_PID",
                targetPID: 7_001, targetUniqueID: 9_001, targetIDVersion: 10_001,
                operation: "KILL", numericArgument: 7_001, signalNumber: 9,
                budgetOrdinal: 1),
            role: "R19_GUARDIAN", form: "POSITIVE_PID", pid: 7_001,
            uniqueID: 9_001, idVersion: 10_001, numericArgument: 7_001,
            commitmentOrdinal: 2,
            commitmentFrameLFSHA256: guardianCommitment.rawWithLFSHA256),
        TypedRichObligation(
            key: DisposalConservationSetMerkle.obligationKey(
                commitmentFrameLFSHA256: fixtureCommitment.rawWithLFSHA256,
                targetRole: "R19_FIXTURE", targetForm: "NEGATIVE_PGID",
                targetPID: 7_002, targetUniqueID: 9_002, targetIDVersion: 10_002,
                operation: "KILL", numericArgument: -7_002, signalNumber: 9,
                budgetOrdinal: 1),
            role: "R19_FIXTURE", form: "NEGATIVE_PGID", pid: 7_002,
            uniqueID: 9_002, idVersion: 10_002, numericArgument: -7_002,
            commitmentOrdinal: 5,
            commitmentFrameLFSHA256: fixtureCommitment.rawWithLFSHA256),
    ].sorted { $0.key < $1.key }
    let leaves = obligations.map {
        DisposalConservationSetMerkle.leafSHA256(obligationKeySHA256: $0.key)
    }
    let memberships = obligations.enumerated().map { ordinal, obligation in
        let proof = try! DisposalConservationSetMerkle.proof(
            leafOrdinal: ordinal,
            canonicalObligationKeys: obligations.map(\.key))
        return typedObject([
            "budget_ordinal": typedNumber("1"),
            "commitment_frame_lf_sha256": typedString(
                obligation.commitmentFrameLFSHA256),
            "commitment_frame_ordinal": typedNumber(String(obligation.commitmentOrdinal)),
            "expected_idversion": typedNumber(String(obligation.idVersion)),
            "expected_uniqueid": typedNumber(String(obligation.uniqueID)),
            "leaf_ordinal": typedNumber(String(ordinal)),
            "leaf_sha256": typedString(leaves[ordinal]),
            "numeric_argument": typedNumber(String(obligation.numericArgument)),
            "obligation_key_sha256": typedString(obligation.key),
            "operation": typedString("KILL"),
            "proof": typedArray(proof.map {
                typedObject([
                    "sibling_position": typedString($0.siblingPosition),
                    "sibling_sha256": typedString($0.siblingSHA256),
                ])
            }),
            "signal_number": typedNumber("9"),
            "target_form": typedString(obligation.form),
            "target_pid": typedNumber(String(obligation.pid)),
            "target_role": typedString(obligation.role),
        ])
    }
    let root = try! DisposalConservationSetMerkle.root(
        canonicalObligationKeys: obligations.map(\.key))
    let setPayload = typedObject([
        "algorithm": typedString(DisposalConservationSetMerkle.algorithm),
        "domain_tag": typedString(DisposalConservationSetMerkle.domainTag),
        "duplicate_policy": typedString(DisposalConservationSetMerkle.duplicatePolicy),
        "epoch_label": typedString("TYPED_TEST_EPOCH"),
        "invocation_id": typedString(invocationID),
        "leaf_count": typedNumber("2"),
        "leaf_ordering": typedString(DisposalConservationSetMerkle.leafOrdering),
        "memberships": typedArray(memberships),
        "odd_leaf_rule": typedString(DisposalConservationSetMerkle.oddLeafRule),
        "purpose": typedString(DisposalConservationSetMerkle.purpose),
        "schema": typedString(DisposalConservationSetMerkle.schema),
        "scope_id": typedString(invocationID),
        "scope_kind": typedString(DisposalConservationSetMerkle.scopeKind),
        "tree_shape": typedString(DisposalConservationSetMerkle.treeShape),
        "witness_root_sha256": typedString(root),
    ])
    let valuesWithSet = valuesBeforeSet + [(.commitment, setPayload)]
    let setFrame = try! DisposalEventJournal.decode(typedJournal(valuesWithSet)).frames[7]
    func reference(obligationKey: String) -> DisposalJSONValue {
        typedObject([
            "algorithm": typedString(DisposalConservationSetMerkle.algorithm),
            "commitment_frame_lf_sha256": typedString(setFrame.rawWithLFSHA256),
            "commitment_frame_ordinal": typedNumber("7"),
            "domain_tag": typedString(DisposalConservationSetMerkle.domainTag),
            "duplicate_policy": typedString(DisposalConservationSetMerkle.duplicatePolicy),
            "epoch_label": typedString("TYPED_TEST_EPOCH"),
            "invocation_id": typedString(invocationID),
            "leaf_count": typedNumber("2"),
            "leaf_ordering": typedString(DisposalConservationSetMerkle.leafOrdering),
            "obligation_keys": typedArray([typedString(obligationKey)]),
            "odd_leaf_rule": typedString(DisposalConservationSetMerkle.oddLeafRule),
            "purpose": typedString(DisposalConservationSetMerkle.purpose),
            "scope_id": typedString(invocationID),
            "scope_kind": typedString(DisposalConservationSetMerkle.scopeKind),
            "tree_shape": typedString(DisposalConservationSetMerkle.treeShape),
            "witness_root_sha256": typedString(root),
        ])
    }
    func conservation(
        schema: String,
        pid: Int,
        uniqueID: UInt64,
        obligationKey: String
    ) -> DisposalJSONValue {
        let round = typedObject([
            "generation": typedString("ESRCH"),
            "group_projection": typedArray([]),
            "pid": typedNumber(String(pid)),
            "session_projection": typedArray([]),
            "signal_zero": typedObject([
                "entered": typedBoolean(true), "errno": typedNumber("3"),
                "esrch": typedBoolean(true), "return": typedNumber("-1"),
            ]),
            "uniqueid": typedNumber(String(uniqueID)),
        ])
        return typedObject([
            "proof": typedObject([
                "conservation_set_reference": reference(obligationKey: obligationKey),
                "kind": typedString("external_conservation"),
                "preexisting_absence": typedBoolean(false),
                "rounds": typedArray([round, round]),
                "signal_zero_entered_count": typedNumber("2"),
                "transient_fault_count": typedNumber("0"),
            ]),
            "schema": typedString(schema),
            "signal_call_entered": typedBoolean(true),
            "signal_delivered": typedBoolean(true),
        ])
    }
    return typedJournal(valuesWithSet + [
        (.conservation, conservation(
            schema: "prime-driver-v2-r19-guardian-conservation/v1",
            pid: 7_001, uniqueID: 9_001,
            obligationKey: obligations.first { $0.role == "R19_GUARDIAN" }!.key)),
        (.conservation, conservation(
            schema: "prime-driver-v2-r19-fixture-conservation/v1",
            pid: 7_002, uniqueID: 9_002,
            obligationKey: obligations.first { $0.role == "R19_FIXTURE" }!.key)),
    ])
}

private func typedMinimalR19Start() -> DisposalJSONValue {
    typedObject([
        "arc_label": typedString("TYPED_GRAPH_TEST"),
        "consumption_state": typedString("ABSTAIN_NOT_RECORDED"),
        "controller_pid": typedNumber("7000"),
        "epoch_label": typedString("TYPED_TEST_EPOCH"),
        "fixed_fixture_generation": typedArray([
            typedNumber("7002"), typedNumber("9002"), typedNumber("10002"),
        ]),
        "fixed_guardian_generation": typedArray([
            typedNumber("7001"), typedNumber("9001"), typedNumber("10001"),
        ]),
        "invocation_id": typedString(String(repeating: "1", count: 64)),
        "retry_authorized": typedBoolean(false),
        "schema": typedString("prime-driver-v2-r19-coordinated-disposal-start/v1"),
    ])
}

private struct TypedR19Fixture {
    let journal: Data
}

private func typedR19Journal() -> TypedR19Fixture {
    let invocationID = String(repeating: "1", count: 64)
    let guardianReceipt = typedLegacyReceipt(pid: 7_001, uniqueID: 9_001, idVersion: 10_001)
    let guardianSnapshot = typedObject([
        "cwd": typedObject(["device": typedNumber("16"), "inode": typedNumber("31"), "path": typedString("/private/tmp/control")]),
        "group_members": typedArray([guardianReceipt]),
        "kind": typedString("present"),
        "mapped_image": typedObject(["device": typedNumber("16"), "inode": typedNumber("30")]),
        "path": typedString("/usr/bin/ruby"),
        "process": guardianReceipt,
        "role": typedString("guardian"),
        "session_members": typedArray([guardianReceipt]),
    ])
    let guardianCertificate = disposalSHA256(guardianSnapshot.canonicalData())
    let start = typedObject([
        "arc_label": typedString("TYPED_R19_TEST"),
        "consumption_state": typedString("ABSTAIN_NOT_RECORDED"),
        "controller_pid": typedNumber("7000"),
        "epoch_label": typedString("TYPED_TEST_EPOCH"),
        "fixed_fixture_generation": typedArray([
            typedNumber("7002"), typedNumber("9002"), typedNumber("10002")]),
        "fixed_guardian_generation": typedArray([
            typedNumber("7001"), typedNumber("9001"), typedNumber("10001")]),
        "invocation_id": typedString(invocationID),
        "retry_authorized": typedBoolean(false),
        "schema": typedString("prime-driver-v2-r19-coordinated-disposal-start/v1"),
    ])
    let guardianPrestate = typedObject([
        "guardian": guardianSnapshot,
        "guardian_terminal_namespace": typedObject([
            "kind": typedString("absent"),
            "staging": typedArray([]),
        ]),
        "schema": typedString("prime-driver-v2-r19-coordinated-disposal-prestate/v1"),
    ])
    let commitment = typedObject([
        "atomic_generation_bound_signal_available": typedBoolean(false),
        "call_may_enter_after_this_record": typedBoolean(true),
        "generation": typedArray([typedNumber("9001"), typedNumber("10001")]),
        "missing_result_means_may_have_entered": typedBoolean(true),
        "prestate_sha256": typedString(guardianCertificate),
        "retry_authorized": typedBoolean(false),
        "role": typedString("guardian"),
        "schema": typedString("prime-driver-v2-r19-kill-commitment/v1"),
        "target": typedNumber("7001"),
    ])
    let signalResult = typedObject([
        "certificate_issued_monotonic_ns": typedNumber("1000000"),
        "certificate_sha256": typedString(guardianCertificate),
        "result": typedObject([
            "call_entered": typedBoolean(true),
            "certificate_age_ns_at_preentry_check": typedNumber("20"),
            "certificate_max_age_ns": typedNumber("5000000"),
            "delivered": typedBoolean(true),
            "errno": typedNumber("0"),
            "return": typedNumber("0"),
            "retried": typedBoolean(false),
            "role": typedString("guardian"),
            "signal": typedString("KILL"),
            "signal_number": typedNumber("9"),
            "target": typedNumber("7001"),
        ]),
        "schema": typedString("prime-driver-v2-r19-kill-result/v1"),
    ])
    let fixturePrestate = typedObject([
        "fixture": typedObject([
            "kind": typedString("absent"),
            "role": typedString("fixture"),
        ]),
        "schema": typedString("prime-driver-v2-r19-fixture-prestate/v1"),
    ])
    let guardianConservation = typedConservationPayload(
        schema: "prime-driver-v2-r19-guardian-conservation/v1",
        pid: 7_001,
        uniqueID: 9_001,
        preexisting: false)
    let fixtureConservation = typedConservationPayload(
        schema: "prime-driver-v2-r19-fixture-conservation/v1",
        pid: 7_002,
        uniqueID: 9_002,
        preexisting: true)
    return .init(journal: typedJournal([
        (.start, start),
        (.snapshot, guardianPrestate),
        (.commitment, commitment),
        (.signalCall, signalResult),
        (.conservation, guardianConservation),
        (.snapshot, fixturePrestate),
        (.conservation, fixtureConservation),
    ]))
}

private func typedConservationPayload(
    schema: String,
    pid: Int,
    uniqueID: UInt64,
    preexisting: Bool
) -> DisposalJSONValue {
    func round() -> DisposalJSONValue {
        typedObject([
            "generation": typedString("ESRCH"),
            "group_projection": typedArray([]),
            "pid": typedNumber(String(pid)),
            "session_projection": typedArray([]),
            "signal_zero": typedObject([
                "entered": typedBoolean(true),
                "errno": typedNumber("3"),
                "esrch": typedBoolean(true),
                "return": typedNumber("-1"),
            ]),
            "uniqueid": typedNumber(String(uniqueID)),
        ])
    }
    return typedObject([
        "proof": typedObject([
            "kind": typedString("external_conservation"),
            "preexisting_absence": typedBoolean(preexisting),
            "rounds": typedArray([round(), round()]),
            "signal_zero_entered_count": typedNumber("2"),
            "transient_fault_count": typedNumber("0"),
        ]),
        "schema": typedString(schema),
        "signal_call_entered": typedBoolean(!preexisting),
        "signal_delivered": typedBoolean(!preexisting),
    ])
}

private func typedLegacyReceipt(
    pid: Int,
    uniqueID: UInt64,
    idVersion: UInt64
) -> DisposalJSONValue {
    typedObject([
        "attempts": typedNumber("1"),
        "comm_hex": typedString("72756279"),
        "credentials": typedArray([
            typedNumber("501"), typedNumber("20"), typedNumber("501"),
            typedNumber("20"), typedNumber("501"), typedNumber("20"),
        ]),
        "flags": typedNumber("0"),
        "idversion": typedNumber(String(idVersion)),
        "orig_ppidversion": typedNumber("8000"),
        "pgid": typedNumber(String(pid)),
        "pid": typedNumber(String(pid)),
        "ppid": typedNumber("6999"),
        "puniqueid": typedNumber("8001"),
        "sid": typedNumber(String(pid)),
        "status": typedNumber("2"),
        "uniqueid": typedNumber(String(uniqueID)),
        "uuid_hex": typedString(String(repeating: "a", count: 32)),
    ])
}

private struct TypedExtraction {
    let database: DisposalSQLiteConnection
    let insertion: DisposalTypedEvidenceInsertion
}

private func typedExtract(_ source: Data) throws -> TypedExtraction {
    let journal = try DisposalEventJournal.decode(source)
    let database = try DisposalSQLiteConnection()
    let ddl = try disposalResourceData("001-evidence", extension: "sql")
    try database.execute(try XCTUnwrap(String(data: ddl, encoding: .utf8)))
    let artifactID = disposalID("typed-test-artifact-v1", [journal.sourceSHA256])
    let invocationID = String(repeating: "1", count: 64)
    let streamID = disposalID("typed-test-stream-v1", [journal.sourceSHA256])
    let frameIDs = journal.frames.map {
        disposalID("typed-test-frame-v1", [String($0.ordinal), $0.rawWithLFSHA256])
    }

    let artifact = try database.prepare(
        "INSERT INTO input_artifacts VALUES(" + String(repeating: "?,", count: 14) + "?)")
    try artifact.bind(1, text: artifactID)
    try artifact.bind(2, text: "DISPOSAL_JOURNAL")
    try artifact.bind(3, text: "typed-test.jsonl")
    try artifact.bind(4, text: "LEDGER_EMBEDDED_COPY")
    try artifact.bind(5, text: "CANONICAL_JOURNAL_FRAME_EXACT")
    for index in 6...8 { try artifact.bind(Int32(index), text: nil) }
    try artifact.bind(9, optionalInt: nil)
    try artifact.bind(10, optionalInt: nil)
    try artifact.bind(11, text: nil)
    try artifact.bind(12, optionalInt: nil)
    try artifact.bind(13, int: source.count)
    try artifact.bind(14, text: journal.sourceSHA256)
    try artifact.bind(15, data: source)
    try artifact.stepDone()

    let invocation = try database.prepare(
        "INSERT INTO invocations VALUES(" + String(repeating: "?,", count: 10) + "?)")
    try invocation.bind(1, text: invocationID)
    try invocation.bind(2, text: "TYPED_TEST")
    try invocation.bind(3, text: "TYPED_TEST_EPOCH")
    try invocation.bind(4, text: artifactID)
    for index in 5...8 { try invocation.bind(Int32(index), text: nil) }
    try invocation.bind(9, text: "ABSTAIN_NOT_RECORDED")
    try invocation.bind(10, int: 0)
    try invocation.bind(11, text: "00000000")
    try invocation.stepDone()

    let stream = try database.prepare("INSERT INTO streams VALUES(?,?,?,?,?,?,?)")
    try stream.bind(1, text: streamID)
    try stream.bind(2, text: invocationID)
    try stream.bind(3, text: artifactID)
    try stream.bind(4, text: "DISPOSAL_JOURNAL")
    try stream.bind(5, text: journal.isTerminal ? "COMPLETE_SEALED" : "RETAINED_PREFIX_NONTERMINAL")
    try stream.bind(6, text: journal.sourceSHA256)
    try stream.bind(7, int: source.count)
    try stream.stepDone()

    for frame in journal.frames {
        let statement = try database.prepare(
            "INSERT INTO frames VALUES(" + String(repeating: "?,", count: 15) + "?)")
        try statement.bind(1, text: frameIDs[frame.ordinal])
        try statement.bind(2, text: streamID)
        try statement.bind(3, text: artifactID)
        try statement.bind(4, int: frame.ordinal)
        try statement.bind(5, text: frame.ordinal == 0 ? nil : frameIDs[frame.ordinal - 1])
        try statement.bind(6, text: "typed-test.jsonl")
        try statement.bind(7, int: frame.journalByteOffset)
        try statement.bind(8, int: frame.raw.count)
        try statement.bind(9, int: 1)
        try statement.bind(10, data: frame.raw)
        try statement.bind(11, text: frame.rawSHA256)
        try statement.bind(12, text: frame.rawWithLFSHA256)
        try statement.bind(13, text: frame.rawSHA256)
        try statement.bind(14, text: frame.payloadSHA256)
        try statement.bind(15, text: frame.schema)
        try statement.bind(16, text: frame.status)
        try statement.stepDone()
    }
    let insertion = try DisposalTypedProcessEvidence.insert(
        database: database,
        journal: journal,
        invocationID: invocationID,
        epochLabel: "TYPED_TEST_EPOCH",
        adapterManifestSHA256: disposalSHA256(
            try disposalResourceData("disposal-adapters.v1", extension: "json")),
        frameIDs: frameIDs)
    return .init(database: database, insertion: insertion)
}

private func typedFinalMachineState(_ journal: Data) throws -> String {
    let material = try DisposalProjectionSetBuilder.makeMaterial(request: .init(
        journal: journal,
        journalLogicalPath: "retained/typed-state-integration.jsonl"))
    let database = try DisposalSQLiteConnection(serializedReadOnly: material.graph)
    defer { try? database.close() }
    return try database.scalarText(
        "SELECT matched_rule_id||':'||state_class FROM machine_states " +
            "ORDER BY prefix_ordinal DESC LIMIT 1")
}

private func typedAppendFrame(
    _ journal: Data,
    eventType: DisposalEventType,
    payload: DisposalJSONValue
) -> Data {
    let decoded = try! DisposalEventJournal.decode(journal)
    let payloadBytes = payload.canonicalData()
    let outer = typedObject([
        "authoritative": typedBoolean(false),
        "authority_vector": typedString("00000000"),
        "event_type": typedString(eventType.rawValue),
        "may_feed_controller": typedBoolean(false),
        "ordinal": typedNumber(String(decoded.frames.count)),
        "payload": payload,
        "payload_hash_rule": typedString(DisposalEventJournal.payloadHashRule),
        "payload_sha256": typedString(disposalSHA256(payloadBytes)),
        "previous_frame_sha256": typedOptionalString(
            decoded.frames.last?.rawWithLFSHA256),
        "prose_may_supply_fact": typedBoolean(false),
        "schema": typedString(DisposalEventJournal.frameSchema),
    ])
    var result = journal
    result.append(outer.canonicalData())
    result.append(0x0a)
    return result
}

private func typedGraphPrefixStateRows(
    _ database: DisposalSQLiteConnection,
    prefixOrdinal: Int
) throws -> [[String]] {
    try typedGraphRows(
        database,
        "SELECT state_id,prefix_ordinal,coalesce(predecessor_state_id,'NULL')," +
            "ancestry_sha256,coalesce(high_water_frame_lf_sha256,'NULL'),matched_rule_id," +
            "predicate_vector_sha256,state_class," +
            "derived_post_hoc_witness_merkle_root_sha256," +
            "derived_post_hoc_witness_leaf_count,merkle_algorithm,merkle_domain_tag," +
            "merkle_leaf_ordering,merkle_duplicate_policy,merkle_odd_leaf_rule " +
            "FROM machine_states WHERE prefix_ordinal=\(prefixOrdinal)",
        columns: 15)
}

private func typedGraphPrefixSemanticRows(
    _ database: DisposalSQLiteConnection,
    prefixOrdinal: Int
) throws -> [[String]] {
    let queries: [(String, Int)] = [
        ("SELECT transition_id,from_state_id,to_state_id,accepted_frame_lf_sha256," +
            "matched_rule_id,state_class,predicate_vector_sha256," +
            "derived_post_hoc_source_set_sha256," +
            "predecessor_derived_post_hoc_witness_merkle_root_sha256," +
            "predecessor_derived_post_hoc_witness_leaf_count," +
            "preconservation_merkle_committed," +
            "coalesce(preconservation_commitment_witness_id,'NULL') " +
            "FROM machine_transitions WHERE to_state_id=(SELECT state_id " +
            "FROM machine_states WHERE prefix_ordinal=\(prefixOrdinal))", 12),
        ("SELECT p.rule_ordinal,p.rule_id,p.clause_ordinal,p.predicate_clause," +
            "p.normalized_lhs,p.normalized_operator,p.normalized_rhs,p.actual_scalar," +
            "p.normalized_state,p.source_count,p.source_set_sha256,p.predicate_sha256 " +
            "FROM machine_transition_predicates p JOIN machine_transitions t " +
            "ON t.transition_id=p.transition_id JOIN machine_states s " +
            "ON s.state_id=t.to_state_id WHERE s.prefix_ordinal=\(prefixOrdinal) " +
            "ORDER BY p.predicate_ordinal", 12),
        ("SELECT witness_id,witness_kind,normalized_fact_sha256," +
            "coalesce(intrinsic_source_frame_lf_sha256,'NULL'),visible_prefix_ordinal " +
            "FROM machine_witnesses WHERE visible_prefix_ordinal<=\(prefixOrdinal) " +
            "ORDER BY witness_id", 5),
        ("SELECT leaf_ordinal,witness_id,normalized_leaf_sha256 " +
            "FROM machine_merkle_leaves WHERE state_id=(SELECT state_id " +
            "FROM machine_states WHERE prefix_ordinal=\(prefixOrdinal)) " +
            "ORDER BY leaf_ordinal", 3),
        ("SELECT e.overlay_edge_id,e.from_node_id,e.to_node_id,e.edge_role " +
            "FROM machine_overlay_edges e JOIN machine_transitions t ON " +
            "((e.edge_role IN('PREDECESSOR','SUPPORTS') AND t.transition_id=e.to_node_id) " +
            "OR (e.edge_role='SUCCESSOR' AND t.transition_id=e.from_node_id)) " +
            "JOIN machine_states s ON s.state_id=t.to_state_id " +
            "WHERE s.prefix_ordinal=\(prefixOrdinal) " +
            "ORDER BY e.edge_role,e.overlay_edge_id", 4),
    ]
    var result: [[String]] = []
    for (sql, columns) in queries {
        result.append(["QUERY", sql])
        result.append(contentsOf: try typedGraphRows(database, sql, columns: columns))
    }
    return result
}

private func typedGraphRows(
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

private func typedRemoveProjection(_ root: String) {
    for leaf in [
        DisposalProjectionSetV1.evidenceLeaf,
        DisposalProjectionSetV1.metricsLeaf,
        DisposalProjectionSetV1.graphLeaf,
        DisposalProjectionSetV1.sealLeaf,
    ] {
        let path = root + "/" + leaf
        _ = chmod(path, 0o600)
        _ = unlink(path)
    }
    _ = chmod(root, 0o700)
    _ = rmdir(root)
}

private func typedJournal(
    _ values: [(DisposalEventType, DisposalJSONValue)]
) -> Data {
    var result = Data()
    var previous: String?
    for (ordinal, value) in values.enumerated() {
        let payload = value.1
        let payloadBytes = payload.canonicalData()
        let outer = typedObject([
            "authoritative": typedBoolean(false),
            "authority_vector": typedString("00000000"),
            "event_type": typedString(value.0.rawValue),
            "may_feed_controller": typedBoolean(false),
            "ordinal": typedNumber(String(ordinal)),
            "payload": payload,
            "payload_hash_rule": typedString(DisposalEventJournal.payloadHashRule),
            "payload_sha256": typedString(disposalSHA256(payloadBytes)),
            "previous_frame_sha256": typedOptionalString(previous),
            "prose_may_supply_fact": typedBoolean(false),
            "schema": typedString(DisposalEventJournal.frameSchema),
        ])
        var frame = outer.canonicalData()
        frame.append(0x0a)
        result.append(frame)
        previous = disposalSHA256(frame)
    }
    return result
}

private func typedObject(_ members: [String: DisposalJSONValue]) -> DisposalJSONValue {
    .object(
        members.map { DisposalJSONObjectMember(key: $0.key, value: $0.value) },
        disposalZeroSpan)
}

private func typedArray(_ values: [DisposalJSONValue]) -> DisposalJSONValue {
    .array(values, disposalZeroSpan)
}

private func typedString(_ value: String) -> DisposalJSONValue {
    .string(value, disposalZeroSpan)
}

private func typedNumber(_ value: String) -> DisposalJSONValue {
    .number(value, disposalZeroSpan)
}

private func typedBoolean(_ value: Bool) -> DisposalJSONValue {
    .boolean(value, disposalZeroSpan)
}

private func typedNull() -> DisposalJSONValue {
    .null(disposalZeroSpan)
}

private func typedOptionalString(_ value: String?) -> DisposalJSONValue {
    value.map(typedString) ?? typedNull()
}
