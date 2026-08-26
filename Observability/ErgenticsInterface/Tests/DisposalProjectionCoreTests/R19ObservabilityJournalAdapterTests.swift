import Darwin
import Foundation
@testable import DisposalProjectionCore
import XCTest

final class R19ObservabilityJournalAdapterTests: XCTestCase {
    private let sourceSHA256 =
        "6f90d4709ad136c356d75ee28ba49a71854215ed386721e734a42eac86f56743"

    func testExactRetainedSourceProjectsSealedObservationWithoutDisposalAuthority() throws {
        let source = try fixture()
        XCTAssertEqual(source.count, 17_557)
        XCTAssertEqual(disposalSHA256(source), sourceSHA256)

        let journal = try DisposalProjectionSourceAdapter.decode(source)
        XCTAssertEqual(journal.source, source)
        XCTAssertEqual(journal.sourceKind, .r19Observability)
        XCTAssertTrue(journal.sourceSealed)
        XCTAssertFalse(journal.isTerminal)
        XCTAssertEqual(
            journal.completion,
            .sealedPresentationSource(
                ordinal: 7,
                exactStatus: "PASS_TELEMETRY_JOURNAL_SEALED_PROJECTION_PENDING_NOT_AUTHORITY"))
        XCTAssertEqual(
            journal.frames.map(\.sourceFrameKind),
            [.r19ObservabilitySession] +
                Array(repeating: .r19ObservabilitySample, count: 6) +
                [.r19ObservabilitySeal])
        XCTAssertEqual(
            journal.frames.reduce(into: Data()) { $0.append($1.rawWithLF) },
            source)

        let material = try DisposalProjectionSetBuilder.makeMaterial(request: .init(
            journal: source,
            journalLogicalPath: "retained/r19-observations.v1.jsonl"))
        XCTAssertEqual(material.frameCount, 8)
        XCTAssertFalse(material.terminal)

        let evidence = try DisposalSQLiteConnection(serializedReadOnly: material.evidence)
        defer { try? evidence.close() }
        for (table, expected) in [
            ("frame_adapter_coverage", 8), ("targets", 3), ("process_receipts", 6),
            ("target_snapshots", 6), ("snapshot_pairs", 6), ("commitments", 0),
            ("signal_calls", 0), ("wait_calls", 0), ("reap_results", 0),
            ("conservations", 0), ("missing_evidence", 9),
        ] {
            XCTAssertEqual(
                try evidence.scalarInt("SELECT count(*) FROM " + table),
                Int64(expected),
                table)
        }
        XCTAssertEqual(
            try evidence.scalarInt(
                "SELECT count(*) FROM missing_evidence WHERE " +
                    "evidence_scope='FRAME_PREFIX' AND " +
                    "evidence_kind='RAW_RUSAGE_INFO_V6_464' AND " +
                    "reason_code='LEGACY_OBSERVABILITY_RAW_464_NOT_RETAINED'"),
            6)
        XCTAssertEqual(
            try evidence.scalarInt(
                "SELECT count(*) FROM missing_evidence WHERE " +
                    "evidence_scope='PROJECTION_GLOBAL_NON_PREFIX'"),
            3)
        XCTAssertEqual(
            try evidence.scalarInt(
                "SELECT count(*) FROM missing_evidence WHERE " +
                    "evidence_kind='TERMINAL_FRAME' AND " +
                    "reason_code='SEALED_OBSERVABILITY_SOURCE_HAS_NO_DISPOSAL_TERMINAL'"),
            1)
        XCTAssertEqual(
            try rows(
                evidence,
                "SELECT CAST(f.ordinal AS TEXT),t.target_role,p.certificate_sha256 " +
                    "FROM snapshot_pairs p " +
                    "JOIN frames f ON f.frame_id=p.source_frame_id " +
                    "JOIN targets t ON t.target_id=p.target_id " +
                    "ORDER BY f.ordinal",
                columns: 3),
            [
                ["1", "R19_WAIT_WRAPPER", "b768954c32349c1c9f8e947cd381db8ee26dd2aad3363b207764284ecd264cd1"],
                ["2", "R19_GUARDIAN", "16b2b4af34687a135d8f2fd4cc5bc67b88086cca1fdc3a90586f7a0a257f58d1"],
                ["3", "R19_FIXTURE", "96be7cce3469b7cdd31de8e70b8b1bdd42fb58942dc8ea8c49e09f30caaaffc8"],
                ["4", "R19_WAIT_WRAPPER", "aa942b696e60a5cf642e01e95c708860054d179afb0a465fd6ef32a3c11f9bbd"],
                ["5", "R19_GUARDIAN", "10642f5d302c93ba82df1ba66997bbba399202eb9f041c66eeb16dacd916a664"],
                ["6", "R19_FIXTURE", "6e8d16963f172e77d281c43a31f0bc4f6e7fea7a459d72a400996c65904bb550"],
            ])

        let metrics = try DisposalSQLiteConnection(serializedReadOnly: material.metrics)
        defer { try? metrics.close() }
        XCTAssertEqual(try metrics.scalarInt("SELECT count(*) FROM rusage_samples"), 6)
        XCTAssertEqual(try metrics.scalarInt("SELECT count(*) FROM rusage_fields"), 84)
        XCTAssertEqual(try metrics.scalarInt("SELECT count(*) FROM metric_intervals"), 3)
        XCTAssertEqual(
            try metrics.scalarInt(
                "SELECT count(*) FROM metric_intervals WHERE interval_state='ABSTAIN_MISSING_INPUT'"),
            3)
        XCTAssertEqual(
            try metrics.scalarInt(
                "SELECT count(*) FROM metric_intervals WHERE join_state='ABSTAIN'"),
            3)
        XCTAssertEqual(
            try metrics.scalarInt(
                "SELECT count(*) FROM metric_intervals WHERE " +
                    "join_state='DRIFT' OR interval_state LIKE 'INVALID_%'"),
            0)
        XCTAssertEqual(try metrics.scalarInt("SELECT count(*) FROM metric_facts"), 0)
        XCTAssertEqual(try metrics.scalarInt("SELECT count(*) FROM metric_qualifications"), 0)
        XCTAssertEqual(
            try metrics.scalarInt(
                "SELECT count(*) FROM rusage_samples WHERE " +
                    "raw_buffer_state='PARSED_FIELDS_ONLY_RAW_ABSENT' AND " +
                    "generation_join_state='PARTIAL_JOIN'"),
            6)

        let graph = try DisposalSQLiteConnection(serializedReadOnly: material.graph)
        defer { try? graph.close() }
        XCTAssertEqual(try graph.scalarInt("SELECT count(*) FROM graph_nodes"), 56)
        XCTAssertEqual(try graph.scalarInt("SELECT count(*) FROM graph_edges"), 97)
        XCTAssertEqual(try graph.scalarInt("SELECT count(*) FROM machine_states"), 9)
        XCTAssertEqual(try graph.scalarInt("SELECT count(*) FROM machine_transitions"), 8)
        XCTAssertEqual(try graph.scalarInt("SELECT count(*) FROM machine_witnesses"), 26)
        XCTAssertEqual(try graph.scalarInt("SELECT count(*) FROM machine_transition_predicates"), 144)
        XCTAssertEqual(try graph.scalarInt("SELECT count(*) FROM machine_merkle_leaves"), 126)
        XCTAssertEqual(try graph.scalarInt("SELECT count(*) FROM machine_overlay_edges"), 142)
        XCTAssertEqual(
            try graph.scalarText(
                "SELECT matched_rule_id FROM machine_states " +
                    "ORDER BY prefix_ordinal DESC LIMIT 1"),
            "D80")
        XCTAssertEqual(
            try graph.scalarText(
                "SELECT state_class FROM machine_states " +
                    "ORDER BY prefix_ordinal DESC LIMIT 1"),
            "ABSTAIN_INCOMPLETE")
        XCTAssertEqual(
            try graph.scalarInt(
                "SELECT count(*) FROM machine_states WHERE prefix_ordinal>=0 " +
                    "AND (matched_rule_id<>'D80' OR state_class<>'ABSTAIN_INCOMPLETE')"),
            0)
        XCTAssertEqual(
            try graph.scalarInt(
                "SELECT count(*) FROM machine_transition_predicates " +
                    "WHERE normalized_state='TRUE'"),
            16)
        XCTAssertEqual(
            try graph.scalarInt(
                "SELECT count(*) FROM machine_transition_predicates " +
                    "WHERE normalized_state='FALSE'"),
            8)
        XCTAssertEqual(
            try graph.scalarInt(
                "SELECT count(*) FROM machine_transition_predicates " +
                    "WHERE normalized_state='UNKNOWN'"),
            120)
        XCTAssertEqual(
            try graph.scalarInt(
                "SELECT count(*) FROM machine_transitions WHERE " +
                    "preconservation_merkle_committed='UNKNOWN' AND " +
                    "preconservation_commitment_witness_id IS NULL"),
            8)
    }

    func testEveryExactPrefixRemainsUnsealedAndStrictDecoderIsNotRelaxed() throws {
        let source = try fixture()
        let lines = source.split(separator: 0x0a, omittingEmptySubsequences: true)
        XCTAssertEqual(lines.count, 8)
        for count in 1...7 {
            var prefix = Data()
            for line in lines.prefix(count) {
                prefix.append(contentsOf: line)
                prefix.append(0x0a)
            }
            let decoded = try DisposalProjectionSourceAdapter.decode(prefix)
            XCTAssertEqual(decoded.frames.count, count)
            XCTAssertEqual(decoded.sourceKind, .r19Observability)
            XCTAssertFalse(decoded.sourceSealed)
            XCTAssertFalse(decoded.isTerminal)
            XCTAssertEqual(
                decoded.frames.reduce(into: Data()) { $0.append($1.rawWithLF) },
                prefix)
        }

        do {
            _ = try DisposalEventJournal.decode(source)
            XCTFail("current disposal-event decoder accepted legacy observability bytes")
        } catch let rejection as DisposalProjectionRejection {
            XCTAssertEqual(rejection.code, "FRAME_OUTER_KEY_SET")
            XCTAssertEqual(rejection.frameOrdinal, 0)
        }
    }

    func testIndependentPrefixProjectionsPreserveDataCountsAndD80Semantics() throws {
        let source = try fixture()
        let fullMaterial = try DisposalProjectionSetBuilder.makeMaterial(request: .init(
            journal: source,
            journalLogicalPath: "retained/r19-observations.v1.jsonl"))
        let fullGraph = try DisposalSQLiteConnection(serializedReadOnly: fullMaterial.graph)
        defer { try? fullGraph.close() }
        let expectedJSONNodes = [57, 136, 215, 294, 373, 452, 531, 567]
        let expectedTargets = [0, 1, 2, 3, 3, 3, 3, 3]
        let expectedMissing = [3, 4, 5, 6, 7, 8, 9, 9]
        let expectedSamples = [0, 1, 2, 3, 4, 5, 6, 6]
        let expectedFields = [0, 14, 28, 42, 56, 70, 84, 84]
        let expectedIntervals = [0, 0, 0, 0, 1, 2, 3, 3]
        let expectedGraphNodes = [9, 17, 25, 33, 40, 47, 54, 56]
        let expectedGraphEdges = [7, 22, 37, 52, 66, 80, 94, 97]
        let expectedWitnesses = [1, 6, 11, 16, 19, 22, 25, 26]
        let expectedMerkleLeaves = [1, 7, 18, 34, 53, 75, 100, 126]
        let expectedOverlayEdges = [3, 11, 24, 42, 63, 87, 114, 142]

        for count in 1...8 {
            let material = try DisposalProjectionSetBuilder.makeMaterial(request: .init(
                journal: prefix(source, frameCount: count),
                journalLogicalPath: "retained/r19-observations.v1.jsonl"))
            let evidence = try DisposalSQLiteConnection(serializedReadOnly: material.evidence)
            defer { try? evidence.close() }
            XCTAssertEqual(
                try evidence.scalarInt("SELECT count(*) FROM json_nodes"),
                Int64(expectedJSONNodes[count - 1]))
            XCTAssertEqual(
                try evidence.scalarInt("SELECT count(*) FROM targets"),
                Int64(expectedTargets[count - 1]))
            XCTAssertEqual(
                try evidence.scalarInt("SELECT count(*) FROM missing_evidence"),
                Int64(expectedMissing[count - 1]))

            let metrics = try DisposalSQLiteConnection(serializedReadOnly: material.metrics)
            defer { try? metrics.close() }
            XCTAssertEqual(
                try metrics.scalarInt("SELECT count(*) FROM rusage_samples"),
                Int64(expectedSamples[count - 1]))
            XCTAssertEqual(
                try metrics.scalarInt("SELECT count(*) FROM rusage_fields"),
                Int64(expectedFields[count - 1]))
            XCTAssertEqual(
                try metrics.scalarInt("SELECT count(*) FROM metric_intervals"),
                Int64(expectedIntervals[count - 1]))

            let graph = try DisposalSQLiteConnection(serializedReadOnly: material.graph)
            defer { try? graph.close() }
            XCTAssertEqual(
                try graph.scalarInt("SELECT count(*) FROM graph_nodes"),
                Int64(expectedGraphNodes[count - 1]))
            XCTAssertEqual(
                try graph.scalarInt("SELECT count(*) FROM graph_edges"),
                Int64(expectedGraphEdges[count - 1]))
            XCTAssertEqual(
                try graph.scalarInt("SELECT count(*) FROM machine_witnesses"),
                Int64(expectedWitnesses[count - 1]))
            XCTAssertEqual(
                try graph.scalarInt("SELECT count(*) FROM machine_merkle_leaves"),
                Int64(expectedMerkleLeaves[count - 1]))
            XCTAssertEqual(
                try graph.scalarInt("SELECT count(*) FROM machine_overlay_edges"),
                Int64(expectedOverlayEdges[count - 1]))
            XCTAssertEqual(
                try graph.scalarText(
                    "SELECT matched_rule_id FROM machine_states " +
                        "ORDER BY prefix_ordinal DESC LIMIT 1"),
                "D80")
            XCTAssertEqual(
                try graph.scalarText(
                    "SELECT state_class FROM machine_states " +
                        "ORDER BY prefix_ordinal DESC LIMIT 1"),
                "ABSTAIN_INCOMPLETE")
            try assertExactMachinePrefix(
                full: fullGraph,
                independent: graph,
                maximumPrefixOrdinal: count - 1)
        }
    }

    func testReaderRoundTripsExactSourceAndSurfacesBothCompletionAxes() throws {
        let source = try fixture()
        let root = "/private/tmp/ergentics-r19-observability-adapter-" +
            UUID().uuidString.lowercased()
        defer { removeProjection(root) }
        let report = try DisposalProjectionSetBuilder.build(
            request: .init(
                journal: source,
                journalLogicalPath: "retained/r19-observations.v1.jsonl"),
            outputRootPath: root)
        let availability = DisposalProjectionReader.load(
            rootPath: root,
            expectedSealSHA256: report.sealSHA256)
        guard case .admitted(let snapshot) = availability else {
            return XCTFail("exact sealed projection did not read back: \(availability)")
        }
        XCTAssertEqual(snapshot.metadata.sourceKind, "R19_OBSERVABILITY_JOURNAL")
        XCTAssertTrue(snapshot.metadata.sourceSealed)
        XCTAssertFalse(snapshot.metadata.terminal)
        XCTAssertEqual(
            snapshot.metadata.status,
            "ABSTAIN_SEALED_SOURCE_NO_DISPOSAL_TERMINAL")
        XCTAssertEqual(snapshot.metadata.authorityVector, "00000000")
        XCTAssertFalse(snapshot.metadata.authoritative)
        XCTAssertFalse(snapshot.metadata.mayFeedController)
        XCTAssertEqual(
            snapshot.frames.reduce(into: Data()) { result, frame in
                result.append(contentsOf: frame.rawJSON.utf8)
                result.append(0x0a)
            },
            source)
        guard case .rejected(let rejection) = DisposalProjectionReader.load(
            rootPath: root,
            expectedSealSHA256: String(repeating: "0", count: 64))
        else {
            return XCTFail("wrong external seal was not rejected")
        }
        XCTAssertEqual(rejection.code, "DISPOSAL_READER_SEAL_SHA256")
    }

    func testSelfConsistentSessionIntervalAndSealMutationsReject() throws {
        let source = try fixture()
        var sessionLines = sourceLines(source)
        sessionLines[1] = sessionLines[1].replacingOccurrences(
            of: "\"session_id\":\"r19-observability-eaf9b76-v1\"",
            with: "\"session_id\":\"r19-observability-eaf9b76-v2\"")
        assertAdapterReject(try rehash(sessionLines), code: "R19_EXACT_STRING", ordinal: 1)

        var intervalLines = sourceLines(source)
        intervalLines[4] = intervalLines[4].replacingOccurrences(
            of: "\"elapsed_minimum_ns\":5016923125",
            with: "\"elapsed_minimum_ns\":5016923126")
        assertAdapterReject(try rehash(intervalLines), code: "R19_INTERVAL_DERIVATION", ordinal: 4)

        var sealLines = sourceLines(source)
        sealLines[7] = sealLines[7].replacingOccurrences(
            of: "\"preseal_journal_bytes\":16034",
            with: "\"preseal_journal_bytes\":16035")
        assertAdapterReject(try rehash(sealLines), code: "R19_EXACT_INTEGER", ordinal: 7)

        var authorityLines = sourceLines(source)
        authorityLines[1] = authorityLines[1].replacingOccurrences(
            of: "\"authority_vector\":\"00000000\"",
            with: "\"authority_vector\":\"10000000\"")
        assertAdapterReject(try rehash(authorityLines), code: "R19_EXACT_STRING", ordinal: 1)
    }

    func testDispatchEnforcesFirstFrameCapBeforeParsing() {
        var oversized = Data(repeating: 0x61, count: DisposalEventJournal.maximumFrameBytes + 1)
        oversized.append(0x0a)
        assertAdapterReject(oversized, code: "SOURCE_FIRST_FRAME_CAP", ordinal: nil)
    }

    func testR19CumulativeNodeCapRejectsAtFirstCrossingFrame() throws {
        let source = try fixture()
        do {
            _ = try DisposalProjectionSourceAdapter.decodeForTesting(
                source,
                r19MaximumTotalNodes: 57)
            XCTFail("expected cumulative node cap rejection")
        } catch let rejection as DisposalProjectionRejection {
            XCTAssertEqual(rejection.code, "R19_TOTAL_NODE_CAP")
            XCTAssertEqual(rejection.frameOrdinal, 1)
        }
    }

    private func fixture() throws -> Data {
        let url = try XCTUnwrap(Bundle.module.url(
            forResource: "r19-observations.v1",
            withExtension: "jsonl",
            subdirectory: "Fixtures"))
        return try Data(contentsOf: url)
    }

    private func sourceLines(_ source: Data) -> [String] {
        source.split(separator: 0x0a, omittingEmptySubsequences: true).map {
            String(decoding: $0, as: UTF8.self)
        }
    }

    private func prefix(_ source: Data, frameCount: Int) -> Data {
        var result = Data()
        for line in source.split(separator: 0x0a, omittingEmptySubsequences: true)
            .prefix(frameCount)
        {
            result.append(contentsOf: line)
            result.append(0x0a)
        }
        return result
    }

    private func rehash(_ input: [String]) throws -> Data {
        var output = Data()
        var previous: String?
        for (ordinal, original) in input.enumerated() {
            var line = original
            var parser = DisposalCanonicalJSONParser(
                data: Data(line.utf8),
                frameOrdinal: ordinal,
                journalByteOffset: output.count)
            var root = try parser.parse()
            let payload = try XCTUnwrap(root.member("payload"))
            let declaredPayloadSHA = try XCTUnwrap(root.member("payload_sha256")?.stringValue())
            line = line.replacingOccurrences(
                of: "\"payload_sha256\":\"\(declaredPayloadSHA)\"",
                with: "\"payload_sha256\":\"\(disposalSHA256(payload.canonicalData()))\"")

            parser = DisposalCanonicalJSONParser(
                data: Data(line.utf8),
                frameOrdinal: ordinal,
                journalByteOffset: output.count)
            root = try parser.parse()
            if let previous {
                let declaredPrevious = try XCTUnwrap(
                    root.member("previous_frame_sha256")?.stringValue())
                line = line.replacingOccurrences(
                    of: "\"previous_frame_sha256\":\"\(declaredPrevious)\"",
                    with: "\"previous_frame_sha256\":\"\(previous)\"")
            }
            var rawWithLF = Data(line.utf8)
            rawWithLF.append(0x0a)
            output.append(rawWithLF)
            previous = disposalSHA256(rawWithLF)
        }
        return output
    }

    private func assertExactMachinePrefix(
        full: DisposalSQLiteConnection,
        independent: DisposalSQLiteConnection,
        maximumPrefixOrdinal: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let ordinal = String(maximumPrefixOrdinal)
        let comparisons: [(String, String, Int)] = [
            (
                "SELECT * FROM machine_states WHERE prefix_ordinal<=" + ordinal +
                    " ORDER BY prefix_ordinal",
                "SELECT * FROM machine_states ORDER BY prefix_ordinal",
                18),
            (
                "SELECT t.* FROM machine_transitions t " +
                    "JOIN machine_states s ON s.state_id=t.to_state_id " +
                    "WHERE s.prefix_ordinal<=" + ordinal + " ORDER BY t.transition_id",
                "SELECT * FROM machine_transitions ORDER BY transition_id",
                15),
            (
                "SELECT p.* FROM machine_transition_predicates p " +
                    "JOIN machine_transitions t ON t.transition_id=p.transition_id " +
                    "JOIN machine_states s ON s.state_id=t.to_state_id " +
                    "WHERE s.prefix_ordinal<=" + ordinal +
                    " ORDER BY p.transition_id,p.predicate_ordinal",
                "SELECT * FROM machine_transition_predicates " +
                    "ORDER BY transition_id,predicate_ordinal",
                14),
            (
                "SELECT * FROM machine_witnesses WHERE visible_prefix_ordinal<=" + ordinal +
                    " ORDER BY witness_id",
                "SELECT * FROM machine_witnesses ORDER BY witness_id",
                7),
            (
                "SELECT l.* FROM machine_merkle_leaves l " +
                    "JOIN machine_states s ON s.state_id=l.state_id " +
                    "WHERE s.prefix_ordinal<=" + ordinal +
                    " ORDER BY l.state_id,l.leaf_ordinal",
                "SELECT * FROM machine_merkle_leaves ORDER BY state_id,leaf_ordinal",
                4),
        ]
        for (fullSQL, independentSQL, columnCount) in comparisons {
            XCTAssertEqual(
                try rows(full, fullSQL, columns: columnCount),
                try rows(independent, independentSQL, columns: columnCount),
                file: file,
                line: line)
        }

        let allowed =
            "SELECT state_id AS node_id FROM machine_states WHERE prefix_ordinal<=" + ordinal +
            " UNION SELECT t.transition_id FROM machine_transitions t " +
            "JOIN machine_states s ON s.state_id=t.to_state_id WHERE s.prefix_ordinal<=" + ordinal +
            " UNION SELECT witness_id FROM machine_witnesses WHERE visible_prefix_ordinal<=" + ordinal
        let fullOverlaySQL =
            "WITH allowed AS (" + allowed + ") SELECT e.* FROM machine_overlay_edges e " +
            "WHERE e.from_node_id IN (SELECT node_id FROM allowed) " +
            "AND e.to_node_id IN (SELECT node_id FROM allowed) ORDER BY e.overlay_edge_id"
        XCTAssertEqual(
            try rows(full, fullOverlaySQL, columns: 6),
            try rows(
                independent,
                "SELECT * FROM machine_overlay_edges ORDER BY overlay_edge_id",
                columns: 6),
            file: file,
            line: line)
    }

    private func rows(
        _ database: DisposalSQLiteConnection,
        _ sql: String,
        columns: Int
    ) throws -> [[String?]] {
        let statement = try database.prepare(sql)
        var result: [[String?]] = []
        while try statement.step() {
            result.append((0..<columns).map { statement.optionalText(Int32($0)) })
        }
        return result
    }

    private func assertAdapterReject(
        _ source: @autoclosure () throws -> Data,
        code: String,
        ordinal: Int?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        do {
            _ = try DisposalProjectionSourceAdapter.decode(try source())
            XCTFail("expected rejection \(code)", file: file, line: line)
        } catch let rejection as DisposalProjectionRejection {
            XCTAssertEqual(rejection.code, code, file: file, line: line)
            XCTAssertEqual(rejection.frameOrdinal, ordinal, file: file, line: line)
        } catch {
            XCTFail("unexpected error \(error)", file: file, line: line)
        }
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
}
