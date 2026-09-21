import Darwin
import Foundation
@testable import LedgerProjectionCore
import XCTest

final class LedgerProjectionTests: XCTestCase {
    func testPinnedPrefixGoldenInventoryAndLexicalNumbers() throws {
        let scan = try LedgerPrefixScanner.scanPinnedSource()
        XCTAssertEqual(scan.source.count, 2_262_434)
        XCTAssertEqual(scan.sections.count, 174)
        XCTAssertEqual(scan.fenceCount, 73)
        XCTAssertEqual(scan.records.count, 76)
        XCTAssertEqual(scan.canonicalRecordCount, 67)
        XCTAssertEqual(scan.legacyRecordCount, 9)
        XCTAssertEqual(scan.jsonNodeCount, 22_576)
        XCTAssertEqual(scan.stateTokenCount, 490)
        XCTAssertEqual(scan.digestOccurrenceCount, 1_292)
        XCTAssertEqual(scan.records.filter { $0.payloadPresent }.count, 48)
        XCTAssertEqual(scan.records.filter { $0.payloadHashState == "MATCH" }.count, 45)
        XCTAssertEqual(scan.records.filter { $0.payloadHashState == "ABSENT_DECLARATION" }.count, 3)
        XCTAssertEqual(scan.records.filter { $0.payloadHashState == "NOT_APPLICABLE" }.count, 28)
        XCTAssertEqual(
            scan.records.flatMap(\.nodes).filter {
                $0.kind == "NUMBER" && (($0.decodedText?.contains(".") ?? false) ||
                    ($0.decodedText?.lowercased().contains("e") ?? false))
            }.count,
            14)
        let classes = Dictionary(grouping: scan.records.flatMap(\.states), by: \.stateClass)
            .mapValues(\.count)
        XCTAssertEqual(classes["PASS"], 191)
        XCTAssertEqual(classes["FAIL"], 33)
        XCTAssertEqual(classes["ABSTAIN"], 266)
    }

    func testNumberLexemeIsPreservedWithoutNormalization() throws {
        let raw = Data(#"{"a":1.2300,"b":1e+02,"c":-0,"d":0}"#.utf8)
        var parser = LedgerCanonicalJSONParser(data: raw)
        let value = try parser.parse()
        XCTAssertEqual(value.canonicalData(), raw)
        guard case .object(let members, _) = value else { return XCTFail("object") }
        XCTAssertEqual(members.compactMap(\.value.decodedText), ["1.2300", "1e+02", "-0", "0"])
    }

    func testInvalidNumbersAndDuplicateKeysReject() {
        for text in [#"{"a":01}"#, #"{"a":1.}"#, #"{"a":1e}"#, #"{"a":1,"a":2}"#] {
            XCTAssertThrowsError(try parse(Data(text.utf8)), text)
        }
    }

    func testAbsentNullAndExplicitAbstainRemainDistinct() throws {
        let source = Data("""
        ## Data
        ```json
        {"a":null,"b":"ABSTAIN_EXACT","c":1.2}
        ```
        """.utf8)
        let scan = try LedgerPrefixScanner.scan(source: source)
        XCTAssertEqual(scan.records.count, 1)
        let record = try XCTUnwrap(scan.records.first)
        XCTAssertNil(record.nodes.first { $0.pointer == "/missing" })
        XCTAssertEqual(record.nodes.first { $0.pointer == "/a" }?.kind, "JSON_NULL")
        XCTAssertNil(record.nodes.first { $0.pointer == "/a" }?.decodedText)
        XCTAssertEqual(record.states.first?.exactValue, "ABSTAIN_EXACT")
        XCTAssertEqual(record.states.first?.stateClass, "ABSTAIN")
        XCTAssertEqual(record.nodes.first { $0.pointer == "/c" }?.decodedText, "1.2")
    }

    func testProseCannotChangeStateTokens() throws {
        let frame = #"{"status":"ABSTAIN_DATA_ONLY"}"#
        let one = Data("## Prose says PASS\n```json\n\(frame)\n```\n".utf8)
        let two = Data("## Prose says FAIL\n```json\n\(frame)\n```\n".utf8)
        let first = try LedgerPrefixScanner.scan(source: one)
        let second = try LedgerPrefixScanner.scan(source: two)
        XCTAssertEqual(first.records.first?.rawSHA256NoLF, second.records.first?.rawSHA256NoLF)
        XCTAssertEqual(first.records.first?.states.first?.exactValue, "ABSTAIN_DATA_ONLY")
        XCTAssertEqual(second.records.first?.states.first?.exactValue, "ABSTAIN_DATA_ONLY")
    }

    func testGraphUsesOnlyClosedExactPredicates() throws {
        let source = Data("""
        ## Graph
        ```json
        {"sha256":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","status":"PASS_DATA"}
        ```
        """.utf8)
        let built = try LedgerProjectionBuilder.buildForTesting(source: source)
        let allowedPredicates = Set([
            "SOURCE_CONTAINS_SECTION", "SECTION_CONTAINS_RECORD", "RECORD_CONTAINS_STATE",
            "RECORD_MENTIONS_DIGEST", "RECORD_HASHES_TO", "RECORD_WITH_LF_HASHES_TO",
            "PAYLOAD_HASHES_TO",
        ])
        let allowedGrades = Set(["STRUCTURAL_EXACT", "COMPUTED_SHA256_EXACT", "LEXICAL_EQUALITY_ONLY"])
        XCTAssertTrue(built.graph.edges.allSatisfy { allowedPredicates.contains($0.predicate) })
        XCTAssertTrue(built.graph.edges.allSatisfy { allowedGrades.contains($0.evidenceGrade) })
    }

    func testEnvironmentAdmissionIsEmptyPartialOrDigestBound() throws {
        XCTAssertEqual(LedgerProjectionReader.load(environment: [:]), .empty)
        guard case .rejected(let partial) = LedgerProjectionReader.load(environment: [
            "ERGENTICS_LEDGER_PROJECTION_ROOT": "/private/tmp/missing",
        ]) else { return XCTFail("partial environment must reject") }
        XCTAssertEqual(partial.code, "PROJECTION_ENVIRONMENT_PARTIAL")

        let root = "/private/tmp/ergentics-ledger-projection-test-\(UUID().uuidString.lowercased())"
        defer { removeTestProjection(root) }
        let report = try LedgerProjectionBuilder.buildPinnedProjection(outputRootPath: root)
        let availability = LedgerProjectionReader.load(
            rootPath: root,
            expectedSealSHA256: report.sealSHA256)
        guard case .admitted(let snapshot) = availability
        else { return XCTFail("exact projection should admit: \(availability)") }
        XCTAssertEqual(snapshot.counts.records, 76)
        XCTAssertEqual(snapshot.metadata.databaseSHA256, report.databaseSHA256)
        XCTAssertFalse(snapshot.metadata.authoritative)
        XCTAssertFalse(snapshot.metadata.mayFeedController)

        let wrong = String(repeating: "0", count: 64)
        guard case .rejected(let rejection) = LedgerProjectionReader.load(
            rootPath: root,
            expectedSealSHA256: wrong)
        else { return XCTFail("wrong seal digest must reject") }
        XCTAssertEqual(rejection.code, "READER_SEAL_SHA256")

        XCTAssertEqual(LedgerProjectionReader.load(environment: [
            "ERGENTICS_LEDGER_PROJECTION_ROOT": "/private/tmp/ergentics-ledger-projection-absent",
            "ERGENTICS_LEDGER_PROJECTION_SEAL_SHA256": report.sealSHA256,
        ]), .empty)
    }

    func testTwoDisjointBuildsAreByteAndSemanticIdentical() throws {
        let rootA = "/private/tmp/ergentics-ledger-projection-test-a-\(UUID().uuidString.lowercased())"
        let rootB = "/private/tmp/ergentics-ledger-projection-test-b-\(UUID().uuidString.lowercased())"
        defer {
            removeTestProjection(rootA)
            removeTestProjection(rootB)
        }
        let a = try LedgerProjectionBuilder.buildPinnedProjection(outputRootPath: rootA)
        let b = try LedgerProjectionBuilder.buildPinnedProjection(outputRootPath: rootB)
        XCTAssertEqual(a.databaseSHA256, b.databaseSHA256)
        XCTAssertEqual(a.sealSHA256, b.sealSHA256)
        XCTAssertEqual(a.projectionID, b.projectionID)
        XCTAssertEqual(a.counts, b.counts)

        let availabilityA = LedgerProjectionReader.load(
            rootPath: rootA,
            expectedSealSHA256: a.sealSHA256)
        let availabilityB = LedgerProjectionReader.load(
            rootPath: rootB,
            expectedSealSHA256: b.sealSHA256)
        guard case .admitted(let snapshotA) = availabilityA,
              case .admitted(let snapshotB) = availabilityB
        else { return XCTFail("both disjoint projections must admit: A=\(availabilityA) B=\(availabilityB)") }
        XCTAssertEqual(snapshotA.metadata.relationalExportSHA256, snapshotB.metadata.relationalExportSHA256)
        XCTAssertEqual(snapshotA.metadata.graphExportSHA256, snapshotB.metadata.graphExportSHA256)
        XCTAssertEqual(snapshotA.counts, snapshotB.counts)
        XCTAssertEqual(snapshotA.timeline, snapshotB.timeline)
        XCTAssertEqual(snapshotA.stateTokens, snapshotB.stateTokens)
        XCTAssertEqual(snapshotA.graphNodes, snapshotB.graphNodes)
        XCTAssertEqual(snapshotA.graphEdges, snapshotB.graphEdges)
    }

    func testCoreAndProjectorContainNoAuthorityBearingSurfaces() throws {
        let packageRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let roots = [
            packageRoot.appendingPathComponent("Sources/LedgerProjectionCore"),
            packageRoot.appendingPathComponent("Sources/ErgenticsLedgerProjector"),
        ]
        let forbidden = [
            "import PrimeCore", "import DriverCore", "import Network", "URLSession",
            "posix_spawn", "/usr/bin/git", "swift-package", "Process(", "system(",
        ]
        for root in roots {
            let files = try FileManager.default.subpathsOfDirectory(atPath: root.path)
                .filter { $0.hasSuffix(".swift") }
            for relative in files {
                let text = try String(contentsOf: root.appendingPathComponent(relative), encoding: .utf8)
                for token in forbidden {
                    XCTAssertFalse(text.contains(token), "forbidden \(token) in \(relative)")
                }
            }
        }
    }

    private func parse(_ data: Data) throws -> LedgerJSONValue {
        var parser = LedgerCanonicalJSONParser(data: data)
        return try parser.parse()
    }

    private func removeTestProjection(_ root: String) {
        let database = root + "/" + PinnedLedgerProjectionV1.databaseLeaf
        let seal = root + "/" + PinnedLedgerProjectionV1.sealLeaf
        _ = chmod(database, 0o600)
        _ = chmod(seal, 0o600)
        _ = chmod(root, 0o700)
        _ = unlink(database)
        _ = unlink(seal)
        _ = rmdir(root)
    }
}
