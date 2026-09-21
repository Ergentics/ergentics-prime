import Darwin
import Foundation
@testable import DisposalProjectionCore
import XCTest

final class DisposalProjectionCoreTests: XCTestCase {
    func testCanonicalJournalPreservesFramesPayloadsHashesSpansAndNumberLexemes() throws {
        let payload = object([
            "event_id": string("event-0"),
            "monotonic_ns": number("42"),
            "numbers": array([number("1.2300"), number("1e+02"), number("-0")]),
            "phase": string("preflight"),
            "status": string("PASS_STATIC_DATA_ONLY"),
            "target_label": string("fixture"),
        ])
        let source = frame(ordinal: 0, eventType: "start", payload: payload)

        let journal = try DisposalEventJournal.decode(source)
        XCTAssertEqual(journal.source, source)
        XCTAssertEqual(journal.sourceSHA256, disposalSHA256(source))
        XCTAssertFalse(journal.isTerminal)
        XCTAssertEqual(journal.completion, .incomplete(.prefixEndingAtOrdinal(0)))
        XCTAssertEqual(journal.frames.count, 1)

        let decoded = try XCTUnwrap(journal.frames.first)
        XCTAssertEqual(decoded.ordinal, 0)
        XCTAssertEqual(decoded.eventType, .start)
        XCTAssertEqual(decoded.phase, "preflight")
        XCTAssertEqual(decoded.targetLabel, "fixture")
        XCTAssertEqual(decoded.status, "PASS_STATIC_DATA_ONLY")
        XCTAssertEqual(decoded.monotonicNanoseconds, 42)
        XCTAssertEqual(decoded.rawWithLF, source)
        XCTAssertEqual(decoded.raw, Data(source.dropLast()))
        XCTAssertEqual(decoded.rawSHA, disposalSHA256(decoded.raw))
        XCTAssertEqual(decoded.rawWithLFSHA, disposalSHA256(source))
        XCTAssertEqual(decoded.payloadSHA, disposalSHA256(decoded.payload))
        XCTAssertNil(decoded.previousSHA)

        let lexemes = ["1.2300", "1e+02", "-0"]
        for (index, expected) in lexemes.enumerated() {
            let pointer = "/payload/numbers/\(index)"
            let node = try XCTUnwrap(decoded.nodes.first { $0.jsonPointer == pointer })
            XCTAssertEqual(node.kind, .number)
            XCTAssertEqual(node.scalar, .numberLexeme(expected))
            XCTAssertEqual(node.raw, Data(expected.utf8))
            XCTAssertEqual(node.rawSHA256, disposalSHA256(Data(expected.utf8)))
            XCTAssertEqual(
                decoded.raw.subdata(in:
                    node.frameRelativeByteOffset..<(node.frameRelativeByteOffset + node.byteCount)),
                node.raw)
            XCTAssertEqual(
                node.journalByteOffset,
                decoded.journalByteOffset + node.frameRelativeByteOffset)
        }
        XCTAssertEqual(decoded.nodes.first?.jsonPointer, "")
        XCTAssertEqual(decoded.nodes.first?.raw, decoded.raw)
        XCTAssertTrue(decoded.nodes.contains { $0.jsonPointer == "/payload" && $0.raw == decoded.payload })
    }

    func testEmptyAndCompleteFramePrefixesRemainExplicitlyIncompleteWithoutPassInference() throws {
        let empty = try DisposalEventJournal.decode(Data())
        XCTAssertFalse(empty.isTerminal)
        XCTAssertEqual(empty.frames, [])
        XCTAssertEqual(empty.completion, .incomplete(.emptySource))

        let prefix = frame(
            ordinal: 0,
            eventType: "start",
            payload: object(["status": string("PASS_NOT_A_TERMINAL")]))
        let decoded = try DisposalEventJournal.decode(prefix)
        XCTAssertEqual(decoded.frames.first?.status, "PASS_NOT_A_TERMINAL")
        XCTAssertFalse(decoded.isTerminal)
        XCTAssertEqual(decoded.completion, .incomplete(.prefixEndingAtOrdinal(0)))
    }

    func testEveryFrozenEventTypeAdmitsInOneSequentialHashChain() throws {
        let types = DisposalEventType.allCases
        var source = Data()
        var previous: String?
        for (ordinal, type) in types.enumerated() {
            var members = [
                "phase": string("phase-\(ordinal)"),
                "status": string(type == .terminal ? "ABSTAIN_DATA_ONLY" : "RECORDED"),
            ]
            if type == .terminal { members["gate_e_outcome"] = string("ABSTAIN") }
            let next = frame(
                ordinal: ordinal,
                eventType: type.rawValue,
                payload: object(members),
                previousFrameSHA256: previous)
            source.append(next)
            previous = disposalSHA256(next)
        }

        let decoded = try DisposalEventJournal.decode(source)
        XCTAssertTrue(decoded.isTerminal)
        XCTAssertEqual(decoded.frames.map(\.eventType), types)
        XCTAssertEqual(
            decoded.completion,
            .terminalFramePresent(ordinal: types.count - 1, exactStatus: "ABSTAIN_DATA_ONLY"))
        for ordinal in 1..<decoded.frames.count {
            XCTAssertEqual(
                decoded.frames[ordinal].previousSHA,
                decoded.frames[ordinal - 1].rawWithLFSHA)
        }
    }

    func testStrictCanonicalMalformedHashChainAndAuthorityInputsReject() throws {
        let payload = object(["lexeme": number("1"), "status": string("RECORDED")])
        let valid = frame(ordinal: 0, eventType: "start", payload: payload)

        assertReject(Data(valid.dropLast()), code: "JOURNAL_TERMINAL_LF")

        let raw = String(decoding: valid, as: UTF8.self)
        assertReject(
            Data(raw.replacingOccurrences(
                of: "{\"authoritative\"",
                with: "{ \"authoritative\"").utf8),
            code: "FRAME_NOT_CANONICAL")
        assertReject(
            Data(raw.replacingOccurrences(
                of: "{\"authoritative\":false",
                with: "{\"authoritative\":false,\"authoritative\":false").utf8),
            code: "JSON_DUPLICATE_KEY")
        assertReject(
            Data(raw.replacingOccurrences(of: "\"lexeme\":1", with: "\"lexeme\":01").utf8),
            code: "JSON_NUMBER_LEADING_ZERO")

        assertReject(
            frame(
                ordinal: 0,
                eventType: "start",
                payload: payload,
                payloadSHA256: String(repeating: "0", count: 64)),
            code: "FRAME_PAYLOAD_SHA256_MISMATCH")
        assertReject(
            frame(ordinal: 1, eventType: "start", payload: payload),
            code: "FRAME_ORDINAL_SEQUENCE")
        assertReject(
            frame(ordinal: 0, eventType: "policy", payload: payload),
            code: "JOURNAL_FIRST_EVENT_NOT_START")
        assertReject(
            frame(ordinal: 0, eventType: "start", payload: payload, authorityVector: "10000000"),
            code: "FRAME_AUTHORITY_VECTOR")
        assertReject(
            frame(ordinal: 0, eventType: "start", payload: payload, authoritative: true),
            code: "FRAME_AUTHORITATIVE")
        assertReject(
            frame(ordinal: 0, eventType: "start", payload: payload, mayFeedController: true),
            code: "FRAME_CONTROLLER_FEED")
        assertReject(
            frame(ordinal: 0, eventType: "start", payload: payload, proseMaySupplyFact: true),
            code: "FRAME_PROSE_FACT")

        let first = frame(ordinal: 0, eventType: "start", payload: payload)
        let second = frame(
            ordinal: 1,
            eventType: "clocks",
            payload: payload,
            previousFrameSHA256: String(repeating: "f", count: 64))
        assertReject(first + second, code: "FRAME_HASH_CHAIN", frameOrdinal: 1)

        let terminalWithoutStatus = frame(
            ordinal: 1,
            eventType: "terminal",
            payload: object(["phase": string("terminal")]),
            previousFrameSHA256: disposalSHA256(first))
        assertReject(first + terminalWithoutStatus, code: "TERMINAL_STATUS_ABSENT", frameOrdinal: 1)

        let terminal = frame(
            ordinal: 1,
            eventType: "terminal",
            payload: object(["status": string("ABSTAIN")]),
            previousFrameSHA256: disposalSHA256(first))
        let afterTerminal = frame(
            ordinal: 2,
            eventType: "clocks",
            payload: payload,
            previousFrameSHA256: disposalSHA256(terminal))
        assertReject(first + terminal + afterTerminal, code: "JOURNAL_FRAME_AFTER_TERMINAL", frameOrdinal: 2)
    }

    func testExact125Over3RationalCorrection() throws {
        let correction = try disposalCPUTime(
            ticks: 86_666_027,
            timebaseNumerator: 125,
            timebaseDenominator: 3)
        XCTAssertEqual(correction.numerator.description, "10833253375")
        XCTAssertEqual(correction.denominator.description, "3")
        XCTAssertEqual(correction.unit, "nanoseconds")
        XCTAssertEqual(try correction.approximation(), "3611084458.333333333333")
    }

    func testMetricsProjectionRetainsBothRaw464ByteBuffersAndExactCorrection() throws {
        let fixture = resourceJournalFixture()
        let decoded = try DisposalEventJournal.decode(fixture.journal)
        XCTAssertFalse(decoded.isTerminal)
        XCTAssertEqual(decoded.completion, .incomplete(.prefixEndingAtOrdinal(2)))
        XCTAssertEqual(decoded.frames.filter { $0.eventType == .resource }.count, 2)

        let material = try DisposalProjectionSetBuilder.makeMaterial(request: .init(
            journal: fixture.journal,
            journalLogicalPath: "retained/r19-resource-prefix.jsonl"))
        let metrics = try DisposalSQLiteConnection(serializedReadOnly: material.metrics)
        XCTAssertEqual(try metrics.scalarInt("SELECT count(*) FROM rusage_samples"), 2)
        XCTAssertEqual(
            try metrics.scalarInt(
                "SELECT count(*) FROM rusage_samples WHERE raw_buffer_state='RAW_464_VERIFIED' AND length(raw_buffer)=464"),
            2)

        let samples = try metrics.prepare(
            "SELECT sample_round,raw_buffer_sha256,raw_buffer FROM rusage_samples ORDER BY sample_round")
        var retained: [Data] = []
        while try samples.step() {
            let round = Int(samples.int64(0))
            let bytes = try XCTUnwrap(samples.data(2))
            XCTAssertEqual(bytes.count, 464)
            XCTAssertEqual(samples.optionalText(1), disposalSHA256(bytes))
            XCTAssertEqual(bytes, round == 0 ? fixture.before : fixture.after)
            retained.append(bytes)
        }
        XCTAssertEqual(retained, [fixture.before, fixture.after])

        XCTAssertEqual(
            try metrics.scalarText(
                "SELECT numerator_text FROM metric_facts WHERE metric_name='cpu_time_nanoseconds'"),
            "10833253375")
        XCTAssertEqual(
            try metrics.scalarText(
                "SELECT denominator_text FROM metric_facts WHERE metric_name='cpu_time_nanoseconds'"),
            "3")
        XCTAssertEqual(
            try metrics.scalarText(
                "SELECT source_grade FROM metric_facts WHERE metric_name='cpu_time_nanoseconds'"),
            "RAW_BUFFER_EXACT_RATIONAL")
        XCTAssertEqual(
            try metrics.scalarText(
                "SELECT premise_state FROM metric_facts WHERE metric_name='delta_energy_joules'"),
            "POSITIVE_KERNEL_TASK_ATTRIBUTED_DELTA_SCOPE_QUALIFIED")
    }

    func testTwoDisjointProjectionRootsHaveIdenticalBytesHashesAndSealedModes() throws {
        let fixture = resourceJournalFixture()
        let suffix = UUID().uuidString.lowercased()
        let matrixRoot = ProcessInfo.processInfo.environment[
            "ERGENTICS_DISPOSAL_TEST_RETAINED_MATRIX_ROOT"]
        let rootA = matrixRoot.map { $0 + "-a" }
            ?? "/private/tmp/ergentics-disposal-projection-test-a-\(suffix)"
        let rootB = matrixRoot.map { $0 + "-b" }
            ?? "/private/tmp/ergentics-disposal-projection-test-b-\(suffix)"
        defer {
            if matrixRoot == nil {
                removeProjection(rootA)
                removeProjection(rootB)
            }
        }
        let request = DisposalProjectionSetRequest(
            journal: fixture.journal,
            journalLogicalPath: "retained/r19-resource-prefix.jsonl")
        let a = try DisposalProjectionSetBuilder.build(request: request, outputRootPath: rootA)
        let b = try DisposalProjectionSetBuilder.build(request: request, outputRootPath: rootB)

        XCTAssertEqual(a.projectionID, b.projectionID)
        XCTAssertEqual(a.evidenceSHA256, b.evidenceSHA256)
        XCTAssertEqual(a.metricsSHA256, b.metricsSHA256)
        XCTAssertEqual(a.graphSHA256, b.graphSHA256)
        XCTAssertEqual(a.sealSHA256, b.sealSHA256)
        XCTAssertEqual(a.frameCount, 3)
        XCTAssertFalse(a.terminal)
        XCTAssertEqual(a.authorityVector, "00000000")
        XCTAssertEqual(try fileMode(rootA), 0o500)
        XCTAssertEqual(try fileMode(rootB), 0o500)

        let leaves = [
            DisposalProjectionSetV1.evidenceLeaf,
            DisposalProjectionSetV1.metricsLeaf,
            DisposalProjectionSetV1.graphLeaf,
            DisposalProjectionSetV1.sealLeaf,
        ]
        for leaf in leaves {
            let pathA = rootA + "/" + leaf
            let pathB = rootB + "/" + leaf
            let bytesA = try Data(contentsOf: URL(fileURLWithPath: pathA))
            let bytesB = try Data(contentsOf: URL(fileURLWithPath: pathB))
            XCTAssertEqual(bytesA, bytesB, leaf)
            XCTAssertEqual(disposalSHA256(bytesA), disposalSHA256(bytesB), leaf)
            XCTAssertEqual(try fileMode(pathA), 0o400, leaf)
            XCTAssertEqual(try fileMode(pathB), 0o400, leaf)
        }

        let sidecarBytes = try Data(contentsOf: URL(fileURLWithPath: a.sealPath))
        var sidecarParser = DisposalCanonicalJSONParser(
            data: sidecarBytes,
            frameOrdinal: -1,
            journalByteOffset: 0)
        let sidecar = try sidecarParser.parse()
        XCTAssertEqual(
            sidecar.member("status")?.stringValue(),
            "ABSTAIN_NONTERMINAL_PREFIX_PROJECTION")
        XCTAssertEqual(sidecar.member("authority_vector")?.stringValue(), "00000000")
        XCTAssertEqual(sidecar.member("authoritative")?.booleanValue(), false)
        XCTAssertEqual(sidecar.member("may_feed_controller")?.booleanValue(), false)
        XCTAssertEqual(sidecar.member("prose_may_supply_fact")?.booleanValue(), false)
    }

    func testAllThreeDatabasesAreStrictImmutableJoinedAndNonAuthoritative() throws {
        let material = try DisposalProjectionSetBuilder.makeMaterial(request: .init(
            journal: resourceJournalFixture().journal,
            journalLogicalPath: "retained/r19-resource-prefix.jsonl"))
        let databases: [(Data, Int64, Int64, Int64)] = [
            (material.evidence, 1_162_105_649, 34, 112),
            (material.metrics, 1_162_104_113, 9, 27),
            (material.graph, 1_162_102_577, 17, 68),
        ]
        for (bytes, applicationID, tableCount, triggerCount) in databases {
            let database = try DisposalSQLiteConnection(serializedReadOnly: bytes)
            XCTAssertEqual(try database.scalarInt("PRAGMA application_id"), applicationID)
            XCTAssertEqual(try database.scalarInt("PRAGMA user_version"), 1)
            XCTAssertEqual(try database.scalarText("PRAGMA integrity_check"), "ok")
            XCTAssertEqual(
                try database.scalarInt("SELECT count(*) FROM pragma_foreign_key_check"),
                0)
            XCTAssertEqual(
                try database.scalarInt(
                    "SELECT count(*) FROM sqlite_schema WHERE type='table' AND name NOT LIKE 'sqlite_%'"),
                tableCount)
            XCTAssertEqual(
                try database.scalarInt("SELECT count(*) FROM sqlite_schema WHERE type='trigger'"),
                triggerCount)
            XCTAssertEqual(
                try database.scalarInt(
                    "SELECT count(*) FROM pragma_table_list WHERE schema='main' AND type='table' AND name NOT LIKE 'sqlite_%' AND strict!=1"),
                0)
            XCTAssertEqual(
                try database.scalarInt(
                    "SELECT count(*) FROM projection_policy WHERE authority_vector='00000000' AND authoritative=0 AND may_feed_controller=0 AND prose_may_supply_fact=0"),
                1)
        }
        let graph = try DisposalSQLiteConnection(serializedReadOnly: material.graph)
        XCTAssertEqual(
            try graph.scalarInt(
                "SELECT count(*) FROM graph_nodes n WHERE n.node_kind='RUSAGE_SAMPLE' AND NOT EXISTS(SELECT 1 FROM graph_edges e WHERE e.to_node_id=n.node_id AND e.predicate='FRAME_REPORTS_ENTITY')"),
            0)
        XCTAssertEqual(
            try graph.scalarInt(
                "SELECT count(*) FROM graph_nodes n WHERE n.node_kind='METRIC' AND (SELECT count(*) FROM graph_edges e WHERE e.from_node_id=n.node_id AND e.predicate='METRIC_USES_SAMPLE')!=2"),
            0)
        XCTAssertEqual(
            try graph.scalarInt(
                "SELECT count(*) FROM graph_edges WHERE predicate='METRIC_USES_SAMPLE'"),
            26)
    }

    func testProjectionImplementationContainsNoActuationSurface() throws {
        let packageRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let roots = [
            packageRoot.appendingPathComponent("Sources/DisposalProjectionCore"),
            packageRoot.appendingPathComponent("Sources/DisposalProjectionPrimitivesC"),
            packageRoot.appendingPathComponent("Sources/ErgenticsDisposalProjector"),
        ]
        let forbidden = [
            "posix_spawn", "waitpid(", "Process.kill", "kill(", "libproc",
            "PROC_PID", "swift-package", "SwiftPM", "URLSession", "Process(",
        ]
        let manager = FileManager.default
        for root in roots {
            let enumerator = try XCTUnwrap(
                manager.enumerator(
                    at: root,
                    includingPropertiesForKeys: [.isRegularFileKey],
                    options: [.skipsHiddenFiles]))
            for case let file as URL in enumerator where ["swift", "c", "h"].contains(file.pathExtension) {
                let source = try String(contentsOf: file, encoding: .utf8)
                for token in forbidden {
                    XCTAssertFalse(source.contains(token), "\(file.lastPathComponent): \(token)")
                }
            }
        }
    }
}

final class DisposalProjectionReaderTests: XCTestCase {
    func testReaderExposesExactMachineRowsAndSwiftUICounts() throws {
        let root = "/private/tmp/ergentics-disposal-reader-test-" +
            UUID().uuidString.lowercased()
        defer { removeProjection(root) }
        let fixture = resourceJournalFixture()
        let report = try DisposalProjectionSetBuilder.build(
            request: .init(
                journal: fixture.journal,
                journalLogicalPath: "retained/r19-reader-prefix.jsonl"),
            outputRootPath: root)
        let snapshot = try admittedSnapshot(
            DisposalProjectionReader.load(
                rootPath: root,
                expectedSealSHA256: report.sealSHA256))
        let graph = try DisposalSQLiteConnection(serializedReadOnly: Data(
            contentsOf: URL(fileURLWithPath: report.graphPath)))

        XCTAssertEqual(snapshot.machineStates.count, snapshot.frames.count + 1)
        XCTAssertEqual(snapshot.machineTransitions.count, snapshot.frames.count)
        XCTAssertFalse(snapshot.machineWitnesses.isEmpty)
        XCTAssertFalse(snapshot.machinePredicates.isEmpty)
        XCTAssertFalse(snapshot.machineMerkleLeaves.isEmpty)
        XCTAssertFalse(snapshot.machineEdges.isEmpty)
        XCTAssertEqual(snapshot.counts.machineStates, snapshot.machineStates.count)
        XCTAssertEqual(snapshot.counts.machineTransitions, snapshot.machineTransitions.count)
        XCTAssertEqual(snapshot.counts.machineWitnesses, snapshot.machineWitnesses.count)
        XCTAssertEqual(snapshot.counts.machinePredicates, snapshot.machinePredicates.count)
        XCTAssertEqual(snapshot.counts.machineMerkleLeaves, snapshot.machineMerkleLeaves.count)
        XCTAssertEqual(snapshot.counts.machineEdges, snapshot.machineEdges.count)
        XCTAssertEqual(
            snapshot.counts.sourceConservationSets,
            snapshot.sourceConservationSets.count)
        XCTAssertEqual(
            snapshot.counts.sourceConservationMemberships,
            snapshot.sourceConservationMemberships.count)
        XCTAssertEqual(
            snapshot.counts.sourceConservationProofNodes,
            snapshot.sourceConservationProofNodes.count)
        XCTAssertEqual(
            snapshot.counts.sourceConservationMappings,
            snapshot.sourceConservationMappings.count)
        XCTAssertEqual(snapshot.counts.graphNodes, snapshot.graphNodes.count)
        XCTAssertEqual(snapshot.counts.graphEdges, snapshot.graphEdges.count)

        XCTAssertEqual(
            snapshot.machineStates.map {
                [
                    $0.id, String($0.prefixOrdinal), $0.predecessorStateID,
                    $0.ancestrySHA256, $0.highWaterFrameNodeID,
                    $0.highWaterFrameLFSHA256, $0.matchedRuleID,
                    $0.predicateVectorSHA256, $0.stateClass,
                    $0.derivedWitnessMerkleRootSHA256,
                    String($0.derivedWitnessLeafCount), $0.merkleAlgorithm,
                    $0.merkleDomainTag, $0.merkleLeafOrdering,
                    $0.merkleDuplicatePolicy, $0.merkleOddLeafRule,
                ]
            },
            try readerSQLRows(
                graph,
                "SELECT state_id,prefix_ordinal,predecessor_state_id,ancestry_sha256," +
                    "high_water_frame_node_id,high_water_frame_lf_sha256,matched_rule_id," +
                    "predicate_vector_sha256,state_class," +
                    "derived_post_hoc_witness_merkle_root_sha256," +
                    "derived_post_hoc_witness_leaf_count,merkle_algorithm,merkle_domain_tag," +
                    "merkle_leaf_ordering,merkle_duplicate_policy,merkle_odd_leaf_rule " +
                    "FROM ui_state_machine_states ORDER BY prefix_ordinal",
                columns: 16))
        XCTAssertEqual(
            snapshot.machineTransitions.map {
                [
                    $0.id, $0.fromStateID, $0.toStateID, $0.acceptedFrameNodeID,
                    $0.acceptedFrameLFSHA256, $0.matchedRuleID, $0.stateClass,
                    $0.predicateVectorSHA256, $0.derivedSourceSetSHA256,
                    $0.predecessorWitnessMerkleRootSHA256,
                    String($0.predecessorWitnessLeafCount),
                    $0.preconservationMerkleCommitted,
                    $0.preconservationCommitmentWitnessID,
                ]
            },
            try readerSQLRows(
                graph,
                "SELECT transition_id,from_state_id,to_state_id,accepted_frame_node_id," +
                    "accepted_frame_lf_sha256,matched_rule_id,state_class," +
                    "predicate_vector_sha256,derived_post_hoc_source_set_sha256," +
                    "predecessor_derived_post_hoc_witness_merkle_root_sha256," +
                    "predecessor_derived_post_hoc_witness_leaf_count," +
                    "preconservation_merkle_committed,preconservation_commitment_witness_id " +
                    "FROM ui_state_machine_transitions ORDER BY transition_id",
                columns: 13))
        XCTAssertEqual(
            snapshot.machineWitnesses.map {
                [
                    $0.id, $0.kind, $0.sourceTable, $0.sourceRowID,
                    $0.exactRowSHA256, $0.normalizedFactSHA256,
                    $0.intrinsicSourceFrameLFSHA256, $0.sourceFrameNodeID,
                    String($0.visiblePrefixOrdinal),
                ]
            },
            try readerSQLRows(
                graph,
                "SELECT witness_id,witness_kind,source_table,source_row_id," +
                    "exact_row_sha256,normalized_fact_sha256," +
                    "intrinsic_source_frame_lf_sha256,source_frame_node_id," +
                    "visible_prefix_ordinal FROM ui_state_machine_witnesses " +
                    "ORDER BY visible_prefix_ordinal,witness_id",
                columns: 9))
        XCTAssertEqual(
            snapshot.machinePredicates.map {
                [
                    $0.transitionID, String($0.predicateOrdinal),
                    String($0.ruleOrdinal), $0.ruleID, String($0.clauseOrdinal),
                    $0.clause, $0.lhs, $0.comparisonOperator, $0.rhs,
                    $0.actualScalar, $0.normalizedState, String($0.sourceCount),
                    $0.sourceSetSHA256, $0.predicateSHA256,
                ]
            },
            try readerSQLRows(
                graph,
                "SELECT transition_id,predicate_ordinal,rule_ordinal,rule_id," +
                    "clause_ordinal,predicate_clause,normalized_lhs,normalized_operator," +
                    "normalized_rhs,actual_scalar,normalized_state,source_count," +
                    "source_set_sha256,predicate_sha256 FROM machine_transition_predicates " +
                    "ORDER BY transition_id,predicate_ordinal",
                columns: 14))
        XCTAssertEqual(
            snapshot.machineMerkleLeaves.map {
                [$0.stateID, String($0.leafOrdinal), $0.witnessID, $0.normalizedLeafSHA256]
            },
            try readerSQLRows(
                graph,
                "SELECT state_id,leaf_ordinal,witness_id,normalized_leaf_sha256 " +
                    "FROM machine_merkle_leaves ORDER BY state_id,leaf_ordinal",
                columns: 4))
        XCTAssertEqual(
            snapshot.machineEdges.map { [$0.id, $0.fromNodeID, $0.toNodeID, $0.role] },
            try readerSQLRows(
                graph,
                "SELECT overlay_edge_id,from_node_id,to_node_id,edge_role " +
                    "FROM machine_overlay_edges ORDER BY overlay_edge_id",
                columns: 4))
    }

    func testReaderFailsClosedWithoutStaleFallback() throws {
        XCTAssertEqual(DisposalProjectionReader.load(environment: [:]), .empty)
        assertRejected(
            DisposalProjectionReader.load(environment: [
                "ERGENTICS_DISPOSAL_PROJECTION_ROOT": "/private/tmp/absent",
            ]),
            code: "DISPOSAL_READER_ENVIRONMENT_PARTIAL")
        assertRejected(
            DisposalProjectionReader.load(environment: [
                "ERGENTICS_DISPOSAL_PROJECTION_SEAL_SHA256": String(repeating: "0", count: 64),
            ]),
            code: "DISPOSAL_READER_ENVIRONMENT_PARTIAL")
        XCTAssertEqual(
            DisposalProjectionReader.load(
                rootPath: "/private/tmp/ergentics-disposal-reader-missing-" +
                    UUID().uuidString.lowercased(),
                expectedSealSHA256: String(repeating: "0", count: 64)),
            .empty)

        let root = "/private/tmp/ergentics-disposal-reader-fail-" +
            UUID().uuidString.lowercased()
        defer { removeProjection(root) }
        let report = try DisposalProjectionSetBuilder.build(
            request: .init(
                journal: resourceJournalFixture().journal,
                journalLogicalPath: "retained/r19-reader-fail-prefix.jsonl"),
            outputRootPath: root)
        _ = try admittedSnapshot(DisposalProjectionReader.load(
            rootPath: root,
            expectedSealSHA256: report.sealSHA256))
        assertRejected(
            DisposalProjectionReader.load(
                rootPath: root,
                expectedSealSHA256: String(repeating: "0", count: 64)),
            code: "DISPOSAL_READER_SEAL_SHA256")
        assertRejected(
            DisposalProjectionReader.load(environment: [
                "ERGENTICS_DISPOSAL_PROJECTION_ROOT": root,
            ]),
            code: "DISPOSAL_READER_ENVIRONMENT_PARTIAL")
        XCTAssertEqual(
            DisposalProjectionReader.load(
                rootPath: "/private/tmp/ergentics-disposal-reader-missing-after-admit-" +
                    UUID().uuidString.lowercased(),
                expectedSealSHA256: report.sealSHA256),
            .empty)
    }

    func testSwiftUIMachineSurfaceConsumesEveryAdmittedCollectionAndCount() throws {
        let packageRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let source = try String(
            contentsOf: packageRoot.appendingPathComponent(
                "Sources/ErgenticsInterface/DisposalProjectionViews.swift"),
            encoding: .utf8)
        let requiredSnapshotCollections = [
            "snapshot.machineStates",
            "snapshot.machineTransitions",
            "snapshot.machineWitnesses",
            "snapshot.machinePredicates",
            "snapshot.machineMerkleLeaves",
            "snapshot.machineEdges",
            "snapshot.sourceConservationSets",
            "snapshot.sourceConservationMemberships",
            "snapshot.sourceConservationProofNodes",
            "snapshot.sourceConservationMappings",
        ]
        let requiredSnapshotCounts = [
            "snapshot.counts.machineStates",
            "snapshot.counts.machineTransitions",
            "snapshot.counts.machineWitnesses",
            "snapshot.counts.machinePredicates",
            "snapshot.counts.sourceConservationSets",
            "snapshot.counts.sourceConservationMemberships",
            "snapshot.counts.sourceConservationProofNodes",
            "snapshot.counts.sourceConservationMappings",
        ]
        for token in requiredSnapshotCollections + requiredSnapshotCounts {
            XCTAssertTrue(source.contains(token), "SwiftUI machine surface omitted \(token)")
        }
        XCTAssertTrue(source.contains("No stale process, metric, or graph rows are displayed."))
        XCTAssertTrue(source.contains("No process state is inferred."))
    }

    private func admittedSnapshot(
        _ availability: DisposalProjectionAvailability
    ) throws -> DisposalProjectionSnapshot {
        guard case .admitted(let snapshot) = availability else {
            XCTFail("expected admitted, got \(availability)")
            throw DisposalProjectionRejection(code: "TEST_READER_NOT_ADMITTED")
        }
        return snapshot
    }

    private func assertRejected(
        _ availability: DisposalProjectionAvailability,
        code: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard case .rejected(let rejection) = availability else {
            XCTFail("expected rejection, got \(availability)", file: file, line: line)
            return
        }
        XCTAssertEqual(rejection.code, code, file: file, line: line)
    }
}

private struct ResourceFixture {
    let journal: Data
    let before: Data
    let after: Data
}

private func readerSQLRows(
    _ database: DisposalSQLiteConnection,
    _ sql: String,
    columns: Int
) throws -> [[String?]] {
    let statement = try database.prepare(sql)
    var rows: [[String?]] = []
    while try statement.step() {
        rows.append((0..<columns).map { statement.optionalText(Int32($0)) })
    }
    return rows
}

private func resourceJournalFixture() -> ResourceFixture {
    let before = rusageBuffer(user: 100, system: 200, energy: 1_000)
    let after = rusageBuffer(
        user: 86_666_127,
        system: 200,
        energy: 20_815_537_440)
    let startPayload = object([
        "arc_label": string("R19_DATA_PROJECTION_TEST"),
        "consumption_state": string("ABSTAIN_NOT_RECORDED"),
        "epoch_label": string("R19_TEST_EPOCH"),
        "invocation_id": string(String(repeating: "1", count: 64)),
        "retry_authorized": boolean(false),
        "status": string("ABSTAIN_TEST_FIXTURE"),
    ])

    let start = frame(ordinal: 0, eventType: "start", payload: startPayload)
    let firstResource = frame(
        ordinal: 1,
        eventType: "resource",
        payload: resourcePayload(raw: before, round: 0, entry: 1_000_000_000, returned: 1_000_000_100),
        previousFrameSHA256: disposalSHA256(start))
    let secondResource = frame(
        ordinal: 2,
        eventType: "resource",
        payload: resourcePayload(raw: after, round: 1, entry: 6_018_000_100, returned: 6_018_000_200),
        previousFrameSHA256: disposalSHA256(firstResource))
    return .init(journal: start + firstResource + secondResource, before: before, after: after)
}

private func resourcePayload(
    raw: Data,
    round: Int,
    entry: UInt64,
    returned: UInt64
) -> DisposalJSONValue {
    let values = [
        ("user_time_ticks", 0, rawUInt64(raw, offset: 0), "mach_absolute_time_ticks"),
        ("system_time_ticks", 8, rawUInt64(raw, offset: 8), "mach_absolute_time_ticks"),
        ("energy_nj", 16, rawUInt64(raw, offset: 16), "nanojoules"),
    ]
    let fields = values.map { name, offset, value, unit in
        object([
            "byte_offset": number(String(offset)),
            "byte_width": number("8"),
            "name": string(name),
            "raw_verification_grade": string("RAW_464_OFFSET_VERIFIED"),
            "source_json_pointer": string("/resource_sample/fields/\(name)"),
            "unit": string(unit),
            "unsigned_decimal": string(String(value)),
        ])
    }
    let sample = object([
        "entry_monotonic_ns": string(String(entry)),
        "fields": array(fields),
        "generation_join_state": string("EXACT_GENERATION_SESSION_GROUP_UUID_START_JOIN"),
        "idversion": string("7"),
        "pgid": number("4242"),
        "pid": number("4242"),
        "process_start_abstime": string("999999"),
        "process_uuid_hex": string(String(repeating: "a", count: 32)),
        "raw_buffer_base64": string(raw.base64EncodedString()),
        "raw_buffer_sha256": string(disposalSHA256(raw)),
        "raw_buffer_state": string("RAW_464_VERIFIED"),
        "return_monotonic_ns": string(String(returned)),
        "rusage_uuid_hex": string(String(repeating: "b", count: 32)),
        "sample_round": number(String(round)),
        "sid": number("4242"),
        "target_label": string("R19_GUARDIAN"),
        "timebase_denominator": string("3"),
        "timebase_numerator": string("125"),
        "uniqueid": string("123456789"),
    ])
    return object([
        "phase": string(round == 0 ? "before" : "after"),
        "resource_sample": sample,
        "status": string("RECORDED_RAW_464"),
        "target_label": string("R19_GUARDIAN"),
    ])
}

private func rusageBuffer(user: UInt64, system: UInt64, energy: UInt64) -> Data {
    var result = Data(repeating: 0, count: 464)
    writeUInt64(user, to: &result, offset: 0)
    writeUInt64(system, to: &result, offset: 8)
    writeUInt64(energy, to: &result, offset: 16)
    return result
}

private func writeUInt64(_ value: UInt64, to data: inout Data, offset: Int) {
    var littleEndian = value.littleEndian
    withUnsafeBytes(of: &littleEndian) { bytes in
        data.replaceSubrange(offset..<(offset + 8), with: bytes)
    }
}

private func rawUInt64(_ data: Data, offset: Int) -> UInt64 {
    data.subdata(in: offset..<(offset + 8)).withUnsafeBytes {
        $0.loadUnaligned(as: UInt64.self).littleEndian
    }
}

private func frame(
    ordinal: Int,
    eventType: String,
    payload: DisposalJSONValue,
    previousFrameSHA256: String? = nil,
    payloadSHA256: String? = nil,
    authorityVector: String = "00000000",
    authoritative: Bool = false,
    mayFeedController: Bool = false,
    proseMaySupplyFact: Bool = false
) -> Data {
    let payloadBytes = payload.canonicalData()
    let outer = object([
        "authoritative": boolean(authoritative),
        "authority_vector": string(authorityVector),
        "event_type": string(eventType),
        "may_feed_controller": boolean(mayFeedController),
        "ordinal": number(String(ordinal)),
        "payload": payload,
        "payload_hash_rule": string(DisposalEventJournal.payloadHashRule),
        "payload_sha256": string(payloadSHA256 ?? disposalSHA256(payloadBytes)),
        "previous_frame_sha256": optionalString(previousFrameSHA256),
        "prose_may_supply_fact": boolean(proseMaySupplyFact),
        "schema": string(DisposalEventJournal.frameSchema),
    ])
    var bytes = outer.canonicalData()
    bytes.append(0x0a)
    return bytes
}

private func object(_ members: [String: DisposalJSONValue]) -> DisposalJSONValue {
    .object(
        members.map { DisposalJSONObjectMember(key: $0.key, value: $0.value) },
        disposalZeroSpan)
}

private func array(_ values: [DisposalJSONValue]) -> DisposalJSONValue {
    .array(values, disposalZeroSpan)
}

private func string(_ value: String) -> DisposalJSONValue {
    .string(value, disposalZeroSpan)
}

private func number(_ lexeme: String) -> DisposalJSONValue {
    .number(lexeme, disposalZeroSpan)
}

private func boolean(_ value: Bool) -> DisposalJSONValue {
    .boolean(value, disposalZeroSpan)
}

private func optionalString(_ value: String?) -> DisposalJSONValue {
    value.map(string) ?? .null(disposalZeroSpan)
}

private func assertReject(
    _ source: Data,
    code: String,
    frameOrdinal: Int? = nil,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    do {
        _ = try DisposalEventJournal.decode(source)
        XCTFail("expected rejection \(code)", file: file, line: line)
    } catch let rejection as DisposalProjectionRejection {
        XCTAssertEqual(rejection.code, code, file: file, line: line)
        if let frameOrdinal {
            XCTAssertEqual(rejection.frameOrdinal, frameOrdinal, file: file, line: line)
        }
    } catch {
        XCTFail("unexpected error \(error)", file: file, line: line)
    }
}

private func fileMode(_ path: String) throws -> Int {
    var state = stat()
    guard lstat(path, &state) == 0 else {
        throw DisposalProjectionRejection(
            code: "TEST_LSTAT",
            detail: "\(path):\(String(cString: strerror(errno)))")
    }
    return Int(state.st_mode & 0o7777)
}

private func removeProjection(_ root: String) {
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
