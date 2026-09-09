import CryptoKit
import Darwin
import Foundation
import SQLite3
import XCTest

final class GuestJournalTests: XCTestCase {
    private func withDirectory(_ body: (URL) throws -> Void) throws {
        // Foundation's URL resolver preserves /var on this platform; POSIX
        // realpath provides the physical parent required by SQLite NOFOLLOW.
        guard let resolved = realpath(FileManager.default.temporaryDirectory.path, nil) else {
            throw GuestJournalFailure("Cannot resolve the test temporary base")
        }
        let physicalBase = String(cString: resolved)
        free(resolved)
        let directory = URL(fileURLWithPath: physicalBase, isDirectory: true)
            .appendingPathComponent("GuestJournalTests-" + UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: false,
            attributes: [.posixPermissions: 0o700])
        // Normal test cleanup of only the exact directory created above.
        // No production/history paths or VM/process APIs are used in this suite.
        defer { try? FileManager.default.removeItem(at: directory) }
        try body(directory)
    }
    private func withDatabase(_ url: URL, _ body: (OpaquePointer) throws -> Void) throws {
        var connection: OpaquePointer?
        let status = sqlite3_open_v2(url.path, &connection, SQLITE_OPEN_READWRITE | SQLITE_OPEN_NOFOLLOW, nil)
        guard status == SQLITE_OK, let connection else {
            if let connection { sqlite3_close(connection) }
            throw GuestJournalFailure("Test database open failed")
        }
        defer { sqlite3_close(connection) }
        try body(connection)
    }
    private func execute(_ sql: String, on connection: OpaquePointer) throws {
        guard sqlite3_exec(connection, sql, nil, nil, nil) == SQLITE_OK else {
            throw GuestJournalFailure("Test SQL failed: " + String(cString: sqlite3_errmsg(connection)))
        }
    }
    private func tamper(_ url: URL, _ body: (OpaquePointer) throws -> Void) throws {
        try withDatabase(url) { connection in
            var statement: OpaquePointer?
            guard sqlite3_prepare_v2(connection,
                "SELECT sql FROM sqlite_schema WHERE name='immutable_events_update'", -1, &statement, nil) == SQLITE_OK,
                  let statement else { throw GuestJournalFailure("Missing test trigger") }
            let restoreSQL: String
            do {
                defer { sqlite3_finalize(statement) }
                guard sqlite3_step(statement) == SQLITE_ROW,
                      let bytes = sqlite3_column_text(statement, 0) else { throw GuestJournalFailure("Missing test trigger SQL") }
                restoreSQL = String(cString: bytes)
            }
            try execute("DROP TRIGGER immutable_events_update", on: connection)
            try body(connection)
            try execute(restoreSQL, on: connection)
        }
    }

    func testCBORUnsignedBoundaryVectors() throws {
        let vectors: [(UInt64, [UInt8])] = [
            (0, [0x00]), (23, [0x17]), (24, [0x18, 0x18]),
            (255, [0x18, 0xff]), (256, [0x19, 0x01, 0x00]),
            (65_535, [0x19, 0xff, 0xff]), (65_536, [0x1a, 0, 1, 0, 0]),
            (4_294_967_296, [0x1b, 0, 0, 0, 1, 0, 0, 0, 0]),
            (UInt64.max, [0x1b, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]),
        ]
        for (value, bytes) in vectors {
            XCTAssertEqual(try GuestCBOR.encode(.unsigned(value)), Data(bytes))
            XCTAssertEqual(try GuestCBOR.decode(Data(bytes)), .unsigned(value))
        }
    }

    func testCBORAllSupportedTypesRoundTrip() throws {
        let value: GuestCBORValue = .map([
            "schema": .text("test.v1"), "unicode": .text("e\u{301} 😀"),
            "raw": .bytes(Data([0, 0xff, 0x80])), "integer": .unsigned(UInt64.max),
            "states": .array([.bool(true), .bool(false), .map([:]), .array([])]),
        ])
        let bytes = try GuestCBOR.encode(value)
        XCTAssertEqual(try GuestCBOR.decode(bytes), value)
        XCTAssertEqual(try GuestCBOR.encode(GuestCBOR.decode(bytes)), bytes)
    }

    func testCBORMapOrderUsesEncodedKeys() throws {
        let value: GuestCBORValue = .map(["b": .unsigned(1), "aa": .unsigned(2), "a": .unsigned(3)])
        XCTAssertEqual(try GuestCBOR.encode(value), Data([0xa3, 0x61, 0x61, 3, 0x61, 0x62, 1, 0x62, 0x61, 0x61, 2]))
    }

    func testCBORRejectsNonminimalTruncatedUnsupportedAndTrailingFrames() {
        let frames: [[UInt8]] = [
            [], [0x18, 0], [0x19, 0, 24], [0x58, 0], [0x78, 1, 0x61],
            [0x98, 0], [0x19, 1], [0x1b, 0], [0x43, 1, 2], [0x61, 0xff],
            [0x00, 0x00], [0x9f, 0xff], [0x20], [0xf6], [0xf9, 0, 0], [0xc0, 0],
        ]
        for bytes in frames { XCTAssertThrowsError(try GuestCBOR.decode(Data(bytes)), "frame=\(bytes)") }
    }

    func testCBORRejectsDuplicateOutOfOrderAndNontextMapKeys() {
        let frames: [[UInt8]] = [
            [0xa2, 0x61, 0x61, 0, 0x61, 0x61, 1],
            [0xa2, 0x61, 0x62, 0, 0x61, 0x61, 1],
            [0xa1, 0, 1],
            [0xa2, 0x62, 0xc3, 0xa9, 0, 0x63, 0x65, 0xcc, 0x81, 1],
        ]
        for bytes in frames { XCTAssertThrowsError(try GuestCBOR.decode(Data(bytes))) }
    }

    func testCBORSizeDepthAndCollectionLimits() {
        XCTAssertThrowsError(try GuestCBOR.encode(.bytes(Data(repeating: 0, count: GuestCBOR.maximumBytes))))
        XCTAssertThrowsError(try GuestCBOR.decode(Data(repeating: 0, count: GuestCBOR.maximumBytes + 1)))
        XCTAssertThrowsError(try GuestCBOR.encode(.array(Array(repeating: .unsigned(0), count: GuestCBOR.maximumCollectionCount + 1))))
        var nested: GuestCBORValue = .unsigned(0)
        for _ in 0...GuestCBOR.maximumDepth { nested = .array([nested]) }
        XCTAssertThrowsError(try GuestCBOR.encode(nested))
        XCTAssertThrowsError(try GuestCBOR.decode(Data(Array(repeating: UInt8(0x81), count: GuestCBOR.maximumDepth + 1) + [0])))
    }

    func testNewDatabaseIsEmptyAndPrivate() throws {
        try withDirectory { root in
            let url = root.appendingPathComponent("journal.sqlite3")
            let journal = try GuestJournal(url: url)
            XCTAssertEqual(try journal.runIDs(), [])
            XCTAssertEqual(try journal.events(runID: "absent"), [])
            let permissions = try FileManager.default.attributesOfItem(atPath: url.path)[.posixPermissions] as? NSNumber
            XCTAssertEqual(permissions?.intValue, 0o600)
        }
    }

    func testAppendReopenAndIndependentProjectionReplay() throws {
        try withDirectory { root in
            let url = root.appendingPathComponent("journal.sqlite3")
            var journal: GuestJournal? = try GuestJournal(url: url)
            let first = try journal!.append(runID: "run-a", kind: "start", payload: ["ticks": .unsigned(UInt64.max)])
            let second = try journal!.append(runID: "run-a", kind: "observation", payload: ["request": .bytes(Data([1, 2, 3]))])
            let terminal = try journal!.append(runID: "run-a", kind: "terminal", payload: ["guest_result": .bool(true)])
            XCTAssertEqual(first.sequence, 0)
            XCTAssertNil(first.parent)
            XCTAssertEqual(second.sequence, 1)
            XCTAssertEqual(second.parent, first.digest)
            XCTAssertEqual(terminal.parent, second.digest)
            XCTAssertEqual(try journal!.events(runID: "run-a"), [first, second, terminal])
            journal = nil
            journal = try GuestJournal(url: url)
            XCTAssertEqual(try journal!.events(runID: "run-a"), [first, second, terminal])
            guard case .map(let event) = try GuestCBOR.decode(first.payload), case .map(let payload)? = event["payload"] else {
                return XCTFail("Expected canonical event map")
            }
            XCTAssertEqual(event["sequence"], .unsigned(0))
            XCTAssertEqual(event["parent"], .bytes(Data()))
            XCTAssertEqual(payload["ticks"], .unsigned(UInt64.max))
            journal = nil
        }
    }

    func testDescriptorSnapshotReconstructsInPrivateReadOnlyMemoryWithoutChangingSourceBytes() throws {
        try withDirectory { root in
            let url = root.appendingPathComponent("journal.sqlite3")
            var journal: GuestJournal? = try GuestJournal(url: url)
            let event = try journal!.append(runID: "run-a", kind: "start", payload: [:])
            journal = nil
            let before = try Data(contentsOf: url)
            XCTAssertEqual(Array(before.prefix(16)), Array("SQLite format 3\0".utf8))
            XCTAssertEqual(before[18], 2)
            XCTAssertEqual(before[19], 2)

            let snapshot = try GuestJournal.reconstructReadOnlySnapshot(databaseBytes: before)
            XCTAssertEqual(snapshot.journalSHA256, GuestContract.hash(before))
            XCTAssertEqual(snapshot.runs.count, 1)
            XCTAssertEqual(snapshot.runs.first?.runID, "run-a")
            XCTAssertEqual(snapshot.runs.first?.events, [event])
            XCTAssertEqual(try Data(contentsOf: url), before)
        }
    }

    func testReadOnlySnapshotRejectsAnyNonWALHeaderWithoutNormalizingEvidence() throws {
        try withDirectory { root in
            let url = root.appendingPathComponent("journal.sqlite3")
            var journal: GuestJournal? = try GuestJournal(url: url)
            _ = try journal!.append(runID: "run-a", kind: "start", payload: [:])
            journal = nil
            let original = try Data(contentsOf: url)
            for pair: (UInt8, UInt8) in [(1, 1), (1, 2), (2, 1), (3, 3)] {
                var changed = original
                changed[18] = pair.0
                changed[19] = pair.1
                XCTAssertThrowsError(try GuestJournal.reconstructReadOnlySnapshot(databaseBytes: changed))
            }
            XCTAssertEqual(try Data(contentsOf: url), original)
        }
    }

    func testReadOnlySnapshotRejectsSchemaDriftAndFourEventRun() throws {
        try withDirectory { root in
            let url = root.appendingPathComponent("schema.sqlite3")
            var journal: GuestJournal? = try GuestJournal(url: url)
            _ = try journal!.append(runID: "run-a", kind: "start", payload: [:])
            journal = nil
            try withDatabase(url) { try execute("DROP TRIGGER immutable_events_delete", on: $0) }
            XCTAssertThrowsError(try GuestJournal.reconstructReadOnlySnapshot(
                databaseBytes: Data(contentsOf: url)))
        }
        try withDirectory { root in
            let url = root.appendingPathComponent("four-events.sqlite3")
            var journal: GuestJournal? = try GuestJournal(url: url)
            for kind in ["start", "observation", "terminal", "extra"] {
                _ = try journal!.append(runID: "run-a", kind: kind, payload: [:])
            }
            journal = nil
            XCTAssertThrowsError(try GuestJournal.reconstructReadOnlySnapshot(
                databaseBytes: Data(contentsOf: url)))
        }
    }

    func testWriterAndReadOnlySnapshotRejectResidualSQLiteCatalogRows() throws {
        try withDirectory { root in
            let url = root.appendingPathComponent("journal.sqlite3")
            var journal: GuestJournal? = try GuestJournal(url: url)
            _ = try journal!.append(runID: "run-a", kind: "start", payload: [:])
            journal = nil
            try withDatabase(url) { try execute("ANALYZE", on: $0) }
            let bytes = try Data(contentsOf: url)
            XCTAssertThrowsError(try GuestJournal.reconstructReadOnlySnapshot(databaseBytes: bytes))
            XCTAssertThrowsError(try GuestJournal(url: url))
            XCTAssertEqual(try Data(contentsOf: url), bytes)
        }
    }

    func testRejectedAppendRollsBackAndRetainsPriorPrefix() throws {
        try withDirectory { root in
            let journal = try GuestJournal(url: root.appendingPathComponent("journal.sqlite3"))
            let first = try journal.append(runID: "run-a", kind: "start", payload: [:])
            let oversized: GuestCBORValue = .array(Array(repeating: .bool(false), count: 257))
            XCTAssertThrowsError(try journal.append(runID: "run-a", kind: "observation", payload: ["too_many": oversized]))
            XCTAssertEqual(try journal.events(runID: "run-a"), [first])
            let second = try journal.append(runID: "run-a", kind: "terminal", payload: [:])
            XCTAssertEqual(second.sequence, 1)
            XCTAssertEqual(second.parent, first.digest)
        }
    }

    func testRunIDsAreLatestTwentyAndRunsHaveSeparateAncestry() throws {
        try withDirectory { root in
            let journal = try GuestJournal(url: root.appendingPathComponent("journal.sqlite3"))
            for index in 0..<22 {
                let event = try journal.append(runID: "run-\(index)", kind: "start", payload: [:])
                XCTAssertEqual(event.sequence, 0)
                XCTAssertNil(event.parent)
            }
            XCTAssertEqual(try journal.runIDs(), Array((2..<22).reversed()).map { "run-\($0)" })
            _ = try journal.append(runID: "run-0", kind: "terminal", payload: [:])
            XCTAssertEqual(try journal.runIDs().first, "run-0")
        }
    }

    func testSQLUpdateDeleteAndDuplicateInsertReject() throws {
        try withDirectory { root in
            let url = root.appendingPathComponent("journal.sqlite3")
            let journal = try GuestJournal(url: url)
            let event = try journal.append(runID: "run-a", kind: "start", payload: [:])
            try withDatabase(url) { db in
                XCTAssertNotEqual(sqlite3_exec(db, "UPDATE events SET kind='changed'", nil, nil, nil), SQLITE_OK)
                XCTAssertNotEqual(sqlite3_exec(db, "DELETE FROM events", nil, nil, nil), SQLITE_OK)
                XCTAssertNotEqual(sqlite3_exec(db, "INSERT INTO events SELECT * FROM events", nil, nil, nil), SQLITE_OK)
            }
            XCTAssertEqual(try journal.events(runID: "run-a"), [event])
        }
    }

    func testTamperedBytesAndProjectionRejectOnReplay() throws {
        for sql in ["UPDATE events SET cbor=x'a0'", "UPDATE events SET kind='changed'"] {
            try withDirectory { root in
                let url = root.appendingPathComponent("journal.sqlite3")
                var journal: GuestJournal? = try GuestJournal(url: url)
                _ = try journal!.append(runID: "run-a", kind: "start", payload: [:])
                journal = nil
                try tamper(url) { try execute(sql, on: $0) }
                journal = try GuestJournal(url: url)
                XCTAssertThrowsError(try journal!.events(runID: "run-a"))
                journal = nil
            }
        }
    }

    func testSelfConsistentRehashedWrongAncestryStillRejects() throws {
        try withDirectory { root in
            let url = root.appendingPathComponent("journal.sqlite3")
            var journal: GuestJournal? = try GuestJournal(url: url)
            _ = try journal!.append(runID: "run-a", kind: "start", payload: [:])
            let second = try journal!.append(runID: "run-a", kind: "terminal", payload: [:])
            journal = nil
            guard case .map(var object) = try GuestCBOR.decode(second.payload) else { return XCTFail("Event map missing") }
            object["parent"] = .bytes(Data(repeating: 0xa5, count: 32))
            let changed = try GuestCBOR.encode(.map(object))
            let digest = SHA256.hash(data: changed).map { String(format: "%02x", $0) }.joined()
            try tamper(url) { db in
                var statement: OpaquePointer?
                guard sqlite3_prepare_v2(db, "UPDATE events SET cbor=?,digest=?,parent=? WHERE sequence=1", -1, &statement, nil) == SQLITE_OK,
                      let statement else { throw GuestJournalFailure("Test mutation prepare failed") }
                defer { sqlite3_finalize(statement) }
                let transient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
                XCTAssertEqual(changed.withUnsafeBytes { sqlite3_bind_blob(statement, 1, $0.baseAddress, Int32($0.count), transient) }, SQLITE_OK)
                XCTAssertEqual(digest.withCString { sqlite3_bind_text(statement, 2, $0, -1, transient) }, SQLITE_OK)
                XCTAssertEqual(String(repeating: "a5", count: 32).withCString { sqlite3_bind_text(statement, 3, $0, -1, transient) }, SQLITE_OK)
                XCTAssertEqual(sqlite3_step(statement), SQLITE_DONE)
            }
            journal = try GuestJournal(url: url)
            XCTAssertThrowsError(try journal!.events(runID: "run-a"))
            journal = nil
        }
    }

    func testDroppedImmutabilityTriggerRejectsAtOpen() throws {
        try withDirectory { root in
            let url = root.appendingPathComponent("journal.sqlite3")
            var journal: GuestJournal? = try GuestJournal(url: url)
            _ = try journal!.append(runID: "run-a", kind: "start", payload: [:])
            journal = nil
            try withDatabase(url) { try execute("DROP TRIGGER immutable_events_update", on: $0) }
            XCTAssertThrowsError(try GuestJournal(url: url))
        }
    }

    func testUnsafeParentRejectsBeforeDatabaseCreation() throws {
        try withDirectory { root in
            try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: root.path)
            let url = root.appendingPathComponent("journal.sqlite3")
            XCTAssertThrowsError(try GuestJournal(url: url))
            XCTAssertFalse(FileManager.default.fileExists(atPath: url.path))
        }
    }

    func testSymlinkAndSymlinkSidecarRejectWithoutTouchingTarget() throws {
        try withDirectory { root in
            let target = root.appendingPathComponent("sentinel")
            let sentinel = Data("do not modify".utf8)
            XCTAssertTrue(FileManager.default.createFile(atPath: target.path, contents: sentinel, attributes: [.posixPermissions: 0o600]))
            let alias = root.appendingPathComponent("alias.sqlite3")
            try FileManager.default.createSymbolicLink(at: alias, withDestinationURL: target)
            XCTAssertThrowsError(try GuestJournal(url: alias))
            let database = root.appendingPathComponent("sidecar.sqlite3")
            try FileManager.default.createSymbolicLink(at: root.appendingPathComponent("sidecar.sqlite3-wal"), withDestinationURL: target)
            XCTAssertThrowsError(try GuestJournal(url: database))
            XCTAssertFalse(FileManager.default.fileExists(atPath: database.path))
            XCTAssertEqual(try Data(contentsOf: target), sentinel)
        }
    }

    func testHardlinkedDatabaseRejects() throws {
        try withDirectory { root in
            let url = root.appendingPathComponent("journal.sqlite3")
            var journal: GuestJournal? = try GuestJournal(url: url)
            _ = try journal!.append(runID: "run-a", kind: "start", payload: [:])
            journal = nil
            try FileManager.default.linkItem(at: url, to: root.appendingPathComponent("alias.sqlite3"))
            XCTAssertThrowsError(try GuestJournal(url: url))
        }
    }

    func testAncestorAliasRejectsBeforeDatabaseCreation() throws {
        try withDirectory { root in
            let actual = root.appendingPathComponent("actual", isDirectory: true)
            let alias = root.appendingPathComponent("alias", isDirectory: true)
            try FileManager.default.createDirectory(at: actual, withIntermediateDirectories: false,
                attributes: [.posixPermissions: 0o700])
            try FileManager.default.createSymbolicLink(at: alias, withDestinationURL: actual)
            XCTAssertThrowsError(try GuestJournal(url: alias.appendingPathComponent("journal.sqlite3")))
            XCTAssertFalse(FileManager.default.fileExists(atPath: actual.appendingPathComponent("journal.sqlite3").path))
        }
    }

    func testEmptyOversizedAndNULIdentifiersReject() throws {
        try withDirectory { root in
            let journal = try GuestJournal(url: root.appendingPathComponent("journal.sqlite3"))
            for run in ["", "a\0b", String(repeating: "x", count: 129)] {
                XCTAssertThrowsError(try journal.append(runID: run, kind: "start", payload: [:]))
            }
            XCTAssertThrowsError(try journal.append(runID: "run", kind: "", payload: [:]))
            XCTAssertEqual(try journal.runIDs(), [])
        }
    }
}
