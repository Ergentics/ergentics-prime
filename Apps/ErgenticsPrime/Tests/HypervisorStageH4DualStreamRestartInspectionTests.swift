import Darwin
import Dispatch
import Foundation
import SQLite3
import XCTest

final class HypervisorStageH4DualStreamRestartInspectionTests: XCTestCase {
    private typealias H4 = HypervisorStageH4Privacy
    private typealias H4C = HypervisorStageH4CanonicalStreams
    private typealias H4D = HypervisorStageH4OwnerBinding
    private typealias H4D3 = HypervisorStageH4DualStreamPersistence
    private typealias H4D3b = HypervisorStageH4DualStreamRestartInspection

    private let epoch = "44444444-4444-4444-8444-444444444444"
    private let outputLimit = 4_096
    private let operationNanoseconds: UInt64 = 4_000_000_000
    private let hardNanoseconds: UInt64 = 5_000_000_000

    private enum HarnessFailure: Error {
        case fixture
        case helperAdmission
        case mutation
        case sqlite(Int32)
        case pipe(Int32)
        case spawn(Int32)
        case read(Int32)
        case wait(Int32)
        case outputBound
        case deadlineOverflow
        case containmentUnproven
    }

    private struct FileWitness: Equatable {
        let device: UInt64
        let inode: UInt64
        let mode: UInt16
        let uid: UInt32
        let gid: UInt32
        let linkCount: UInt16
        let size: Int64
        let flags: UInt32
        let modificationSeconds: Int64
        let modificationNanoseconds: Int64
        let changeSeconds: Int64
        let changeNanoseconds: Int64

        init(_ value: stat) {
            device = UInt64(value.st_dev)
            inode = UInt64(value.st_ino)
            mode = UInt16(value.st_mode)
            uid = UInt32(value.st_uid)
            gid = UInt32(value.st_gid)
            linkCount = UInt16(value.st_nlink)
            size = Int64(value.st_size)
            flags = UInt32(value.st_flags)
            modificationSeconds = Int64(value.st_mtimespec.tv_sec)
            modificationNanoseconds = Int64(value.st_mtimespec.tv_nsec)
            changeSeconds = Int64(value.st_ctimespec.tv_sec)
            changeNanoseconds = Int64(value.st_ctimespec.tv_nsec)
        }
    }

    private struct HelperAdmission {
        let path: String
        let descriptor: Int32
        let witness: FileWitness
    }

    private struct ChildResult {
        let parentPID: pid_t
        let pid: pid_t
        let status: Int32
        let reaped: Bool
        let stdout: Data
        let stderr: Data
        let stdoutEOF: Bool
        let stderrEOF: Bool
        let timedOut: Bool
        let killAttempts: Int
        let elapsedNanoseconds: UInt64
        let reapElapsedNanoseconds: UInt64?

        var exited: Bool { status & 0x7f == 0 }
        var exitCode: Int32 { exited ? (status >> 8) & 0xff : -1 }
        var signal: Int32 { exited ? 0 : status & 0x7f }
    }

    private enum ImageMutation {
        case coherentSubstitution
        case scalarMismatch
        case jsonCorrupt
        case jsonNoncanonical
        case jsonTrailing
        case jsonAlias
        case jsonUnknownField
        case jsonDuplicateField
        case cborCorrupt
        case cborNoncanonical
        case cborTrailing
        case cborAlias
        case cborUnknownField
        case cborDuplicateField
        case wrongUserVersion
        case wrongApplicationID
        case extraSchemaObject
        case extraColumn
        case extraRow
        case v2Schema
        case wrongScalarStorage
        case alteredTableSQL
    }

    private func source() -> H4.Source {
        H4.Source(
            origin: .h3StructuralFixture,
            disposition: .contractOnly,
            subject: .h3Checkpoint,
            epoch: epoch,
            receiptRoot: String(repeating: "a", count: 64),
            claimState: .observedNonPass,
            predicateCount: 19,
            authorityVector: "00000000",
            rawDiagnostic: nil
        )
    }

    private func bound() throws -> H4D.OwnerBoundCanonicalProjection {
        let input = source()
        let capability = try XCTUnwrap(H4.issueTestCapability(
            source: input,
            validThroughTick: .max
        ))
        let dispatcher = try XCTUnwrap(H4.consumeTestDispatcher(
            capability: capability,
            request: H4.fixedRequest(epoch: input.epoch),
            source: input,
            deliveryTick: { mach_continuous_time() }
        ))
        return try dispatcher.bindCanonicalStreams().get()
    }

    private func privateRoot(
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> URL {
        var template = Array("/private/tmp/epr-h4d3b.XXXXXX\0".utf8)
        let path = template.withUnsafeMutableBufferPointer { buffer -> String? in
            guard let base = buffer.baseAddress, let created = mkdtemp(base) else {
                return nil
            }
            return String(validatingCString: created)
        }
        let value = try XCTUnwrap(path, file: file, line: line)
        XCTAssertEqual(chmod(value, mode_t(0o700)), 0, file: file, line: line)
        let root = URL(fileURLWithPath: value, isDirectory: true)
        addTeardownBlock {
            try? FileManager.default.removeItem(at: root)
            for suffix in [".h4d3b-displaced", ".h4d3b-named-displaced"] {
                try? FileManager.default.removeItem(atPath: value + suffix)
            }
        }
        return root
    }

    @inline(never)
    private func publishOnly(to root: URL) throws {
        let coordinator = try H4D3.makeTestCoordinator(
            bound: bound(),
            rootURL: root
        )
        guard case .admitted = coordinator.persist() else {
            throw HarnessFailure.fixture
        }
    }

    @inline(never)
    private func publishedRoot(
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> String {
        let root = try privateRoot(file: file, line: line)
        try publishOnly(to: root)
        try assertExclusiveLeaseReleased(root.path, file: file, line: line)
        return root.path
    }

    private func assertExclusiveLeaseReleased(
        _ rootPath: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let descriptor = open(rootPath, O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW)
        XCTAssertGreaterThanOrEqual(descriptor, 0, file: file, line: line)
        guard descriptor >= 0 else { throw HarnessFailure.fixture }
        defer { XCTAssertEqual(close(descriptor), 0, file: file, line: line) }
        XCTAssertEqual(flock(descriptor, LOCK_EX | LOCK_NB), 0, file: file, line: line)
        guard flock(descriptor, LOCK_UN) == 0 else {
            XCTFail("exclusive root lease could not be released", file: file, line: line)
            throw HarnessFailure.fixture
        }
    }

    private func exec(_ database: OpaquePointer?, _ sql: String) throws {
        var message: UnsafeMutablePointer<CChar>?
        let status = sqlite3_exec(database, sql, nil, nil, &message)
        if let message { sqlite3_free(message) }
        guard status == SQLITE_OK else { throw HarnessFailure.sqlite(status) }
    }

    private func openMutableImage(_ image: Data) throws -> OpaquePointer {
        var database: OpaquePointer?
        let flags = SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE |
            SQLITE_OPEN_MEMORY | SQLITE_OPEN_FULLMUTEX |
            SQLITE_OPEN_PRIVATECACHE | SQLITE_OPEN_EXRESCODE
        let openStatus = sqlite3_open_v2(":memory:", &database, flags, nil)
        guard openStatus == SQLITE_OK, let database else {
            if let database { _ = sqlite3_close_v2(database) }
            throw HarnessFailure.sqlite(openStatus)
        }
        let deserializeStatus = image.withUnsafeBytes { bytes in
            epr_h4d3_deserialize_mutable_image(
                UnsafeMutableRawPointer(database),
                bytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                Int64(image.count)
            )
        }
        guard deserializeStatus == SQLITE_OK else {
            _ = sqlite3_close_v2(database)
            throw HarnessFailure.sqlite(deserializeStatus)
        }
        return database
    }

    private func serialize(_ database: OpaquePointer?) throws -> Data {
        var image = Data(count: H4D3b.maximumImageBytes)
        var count: Int64 = 0
        let status = image.withUnsafeMutableBytes { bytes in
            epr_h4d3_sqlite_serialize_main(
                UnsafeMutableRawPointer(database),
                bytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                &count
            )
        }
        guard status == SQLITE_OK,
              let exact = Int(exactly: count),
              exact > 0,
              exact <= image.count else {
            throw HarnessFailure.sqlite(status)
        }
        image.removeSubrange(exact..<image.count)
        return image
    }

    private func updateBlob(
        _ database: OpaquePointer?,
        column: String,
        value: Data
    ) throws {
        guard ["canonical_json", "canonical_cbor"].contains(column) else {
            throw HarnessFailure.mutation
        }
        var statement: OpaquePointer?
        let sql = "UPDATE h4_dual_receipts SET \(column)=? WHERE singleton=1"
        guard sqlite3_prepare_v3(
            database,
            sql,
            -1,
            UInt32(SQLITE_PREPARE_NO_VTAB),
            &statement,
            nil
        ) == SQLITE_OK, let statement else {
            throw HarnessFailure.mutation
        }
        defer { _ = sqlite3_finalize(statement) }
        let transient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        let bindStatus = value.withUnsafeBytes {
            sqlite3_bind_blob(
                statement,
                1,
                $0.baseAddress,
                Int32($0.count),
                transient
            )
        }
        guard bindStatus == SQLITE_OK,
              sqlite3_step(statement) == SQLITE_DONE,
              sqlite3_changes(database) == 1 else {
            throw HarnessFailure.mutation
        }
    }

    private func jsonNoncanonical(_ canonical: Data) throws -> Data {
        guard canonical.first == UInt8(ascii: "{") else {
            throw HarnessFailure.mutation
        }
        var result = canonical
        result.insert(UInt8(ascii: " "), at: result.startIndex + 1)
        return result
    }

    private func jsonAlias(_ canonical: Data) throws -> Data {
        let marker = Data("\"predicate_count\":".utf8)
        guard let range = canonical.range(of: marker) else {
            throw HarnessFailure.mutation
        }
        var result = canonical
        result.insert(UInt8(ascii: "0"), at: range.upperBound)
        return result
    }

    private func jsonUnknownField(_ canonical: Data) throws -> Data {
        let known = Data("\"schema\"".utf8)
        let unknown = Data("\"xchema\"".utf8)
        guard let range = canonical.range(of: known),
              canonical[range.upperBound...].range(of: known) == nil else {
            throw HarnessFailure.mutation
        }
        var result = canonical
        result.replaceSubrange(range, with: unknown)
        return result
    }

    private func jsonDuplicateField() throws -> Data {
        let result = Data((
            "{\"authority_vector\":\"00000000\"," +
            "\"predicate_count\":19,\"predicate_count\":19," +
            "\"schema\":\"\(H4C.semanticSchema)\"}"
        ).utf8)
        guard result.count <= H4D3b.maximumStreamBytes else {
            throw HarnessFailure.mutation
        }
        return result
    }

    private func cborNoncanonical(_ canonical: Data) throws -> Data {
        guard canonical.first == 0xa4 else { throw HarnessFailure.mutation }
        return Data([0xb8, 0x04]) + Data(canonical.dropFirst())
    }

    private func cborAlias(_ canonical: Data) throws -> Data {
        var marker = Data([0x6f])
        marker.append(Data("predicate_count".utf8))
        guard let range = canonical.range(of: marker),
              range.upperBound < canonical.endIndex,
              canonical[range.upperBound] < 24 else {
            throw HarnessFailure.mutation
        }
        var result = canonical
        let value = result[range.upperBound]
        result.replaceSubrange(range.upperBound...range.upperBound, with: [0x18, value])
        return result
    }

    private func cborUnknownField(_ canonical: Data) throws -> Data {
        guard canonical.first == 0xa4 else { throw HarnessFailure.mutation }
        var result = canonical
        result[result.startIndex] = 0xa5
        result.append(contentsOf: [0x61, UInt8(ascii: "x"), 0x00])
        return result
    }

    private func cborDuplicateField(_ canonical: Data) throws -> Data {
        guard let schema = canonical.range(of: Data("schema".utf8)),
              let claim = canonical.range(of: Data("claim_state".utf8)),
              let predicate = canonical.range(of: Data("predicate_count".utf8)),
              let authority = canonical.range(of: Data("authority_vector".utf8)),
              schema.lowerBound > canonical.startIndex,
              claim.lowerBound > schema.lowerBound,
              predicate.lowerBound > claim.lowerBound,
              authority.lowerBound > predicate.lowerBound else {
            throw HarnessFailure.mutation
        }
        let schemaPair = canonical[
            (schema.lowerBound - 1)..<(claim.lowerBound - 1)
        ]
        let claimPair = canonical[
            (claim.lowerBound - 1)..<(predicate.lowerBound - 1)
        ]
        let authorityPair = canonical[
            (authority.lowerBound - 1)..<canonical.endIndex
        ]
        var result = Data([0xa4])
        result.append(schemaPair)
        result.append(claimPair)
        result.append(claimPair)
        result.append(authorityPair)
        guard result.count <= H4D3b.maximumStreamBytes else {
            throw HarnessFailure.mutation
        }
        return result
    }

    private func replaceUniqueBytes(
        _ source: Data,
        needle: Data,
        replacement: Data
    ) throws -> Data {
        guard !needle.isEmpty,
              needle.count == replacement.count,
              let range = source.range(of: needle),
              source[range.upperBound...].range(of: needle) == nil else {
            throw HarnessFailure.mutation
        }
        var result = source
        result.replaceSubrange(range, with: replacement)
        return result
    }

    @inline(never)
    private func mutatePublishedImage(
        rootPath: String,
        mutation: ImageMutation
    ) throws {
        let root = URL(fileURLWithPath: rootPath, isDirectory: true)
        let final = root.appendingPathComponent(H4D3b.finalLeafName)
        let original = try Data(contentsOf: final, options: [.mappedIfSafe])
        let snapshot = try H4D3.inspectTestStore(rootURL: root)
        var database: OpaquePointer? = try openMutableImage(original)
        defer {
            if let database { _ = sqlite3_close_v2(database) }
        }
        try exec(database, "PRAGMA ignore_check_constraints=ON")
        var directlySerialized: Data?
        switch mutation {
        case .coherentSubstitution:
            let substitute = try H4C.d3SelfConsistentSubstitutionTestVector(
                from: try bound().canonicalTest
            )
            try updateBlob(database, column: "canonical_json", value: substitute.json)
            try updateBlob(database, column: "canonical_cbor", value: substitute.cbor)
            try exec(
                database,
                "UPDATE h4_dual_receipts SET predicate_count=" +
                    "\(substitute.predicateCount)"
            )
        case .scalarMismatch:
            try exec(
                database,
                "UPDATE h4_dual_receipts SET predicate_count=predicate_count+1"
            )
        case .jsonCorrupt:
            try updateBlob(
                database,
                column: "canonical_json",
                value: Data([UInt8(ascii: "{")])
            )
        case .jsonNoncanonical:
            try updateBlob(
                database,
                column: "canonical_json",
                value: try jsonNoncanonical(snapshot.canonicalJSON)
            )
        case .jsonTrailing:
            try updateBlob(
                database,
                column: "canonical_json",
                value: snapshot.canonicalJSON + Data([UInt8(ascii: " ")])
            )
        case .jsonAlias:
            try updateBlob(
                database,
                column: "canonical_json",
                value: try jsonAlias(snapshot.canonicalJSON)
            )
        case .jsonUnknownField:
            try updateBlob(
                database,
                column: "canonical_json",
                value: try jsonUnknownField(snapshot.canonicalJSON)
            )
        case .jsonDuplicateField:
            try updateBlob(
                database,
                column: "canonical_json",
                value: try jsonDuplicateField()
            )
        case .cborCorrupt:
            try updateBlob(
                database,
                column: "canonical_cbor",
                value: Data([0xff])
            )
        case .cborNoncanonical:
            try updateBlob(
                database,
                column: "canonical_cbor",
                value: try cborNoncanonical(snapshot.canonicalCBOR)
            )
        case .cborTrailing:
            try updateBlob(
                database,
                column: "canonical_cbor",
                value: snapshot.canonicalCBOR + Data([0x00])
            )
        case .cborAlias:
            try updateBlob(
                database,
                column: "canonical_cbor",
                value: try cborAlias(snapshot.canonicalCBOR)
            )
        case .cborUnknownField:
            try updateBlob(
                database,
                column: "canonical_cbor",
                value: try cborUnknownField(snapshot.canonicalCBOR)
            )
        case .cborDuplicateField:
            try updateBlob(
                database,
                column: "canonical_cbor",
                value: try cborDuplicateField(snapshot.canonicalCBOR)
            )
        case .wrongUserVersion:
            try exec(database, "PRAGMA user_version=3")
        case .wrongApplicationID:
            try exec(database, "PRAGMA application_id=1")
        case .extraSchemaObject:
            try exec(database, "CREATE TABLE h4_d3b_extra(value INTEGER)")
        case .extraColumn:
            try exec(
                database,
                "ALTER TABLE h4_dual_receipts ADD COLUMN extra INTEGER"
            )
        case .extraRow:
            try exec(
                database,
                "INSERT INTO h4_dual_receipts(" +
                    "singleton,semantic_schema,claim_state,predicate_count," +
                    "authority_vector,canonical_json,canonical_cbor) " +
                    "SELECT 2,semantic_schema,claim_state,predicate_count," +
                    "authority_vector,canonical_json,canonical_cbor " +
                    "FROM h4_dual_receipts WHERE singleton=1"
            )
        case .v2Schema:
            try exec(
                database,
                "CREATE TEMP TABLE h4_d3b_v2 AS SELECT singleton," +
                    "semantic_schema,claim_state,predicate_count," +
                    "authority_vector,canonical_cbor FROM h4_dual_receipts"
            )
            try exec(database, "DROP TABLE h4_dual_receipts")
            try exec(
                database,
                "CREATE TABLE h4_receipts(" +
                    "singleton INTEGER PRIMARY KEY CHECK(singleton=1)," +
                    "semantic_schema TEXT NOT NULL CHECK(semantic_schema='" +
                    H4C.semanticSchema + "')," +
                    "claim_state TEXT NOT NULL CHECK(claim_state='OBSERVED_NONPASS')," +
                    "predicate_count INTEGER NOT NULL " +
                    "CHECK(predicate_count>0 AND predicate_count<=4096)," +
                    "authority_vector TEXT NOT NULL " +
                    "CHECK(authority_vector='00000000')," +
                    "canonical_cbor BLOB NOT NULL " +
                    "CHECK(length(canonical_cbor)>0 AND " +
                    "length(canonical_cbor)<=158)) STRICT, WITHOUT ROWID"
            )
            try exec(
                database,
                "INSERT INTO h4_receipts SELECT * FROM temp.h4_d3b_v2"
            )
        case .wrongScalarStorage:
            try exec(
                database,
                "CREATE TEMP TABLE h4_d3b_wrong_storage AS SELECT singleton," +
                    "semantic_schema,claim_state,CAST(predicate_count AS TEXT) " +
                    "AS predicate_count,authority_vector,canonical_json," +
                    "canonical_cbor FROM h4_dual_receipts"
            )
            try exec(database, "DROP TABLE h4_dual_receipts")
            let relaxedSQL =
                "CREATE TABLE h4_dual_receipts(" +
                "singleton INTEGER PRIMARY KEY CHECK(singleton=1)," +
                "semantic_schema TEXT NOT NULL CHECK(semantic_schema='" +
                H4C.semanticSchema + "')," +
                "claim_state TEXT NOT NULL CHECK(claim_state='OBSERVED_NONPASS')," +
                "predicate_count ANY     NOT NULL " +
                "CHECK(predicate_count>0 AND predicate_count<=4096)," +
                "authority_vector TEXT NOT NULL " +
                "CHECK(authority_vector='00000000')," +
                "canonical_json BLOB NOT NULL " +
                "CHECK(length(canonical_json)>0 AND length(canonical_json)<=158)," +
                "canonical_cbor BLOB NOT NULL " +
                "CHECK(length(canonical_cbor)>0 AND length(canonical_cbor)<=158)) " +
                "STRICT, WITHOUT ROWID"
            try exec(database, relaxedSQL)
            try exec(
                database,
                "INSERT INTO h4_dual_receipts SELECT * " +
                    "FROM temp.h4_d3b_wrong_storage"
            )
            let relaxed = try serialize(database)
            directlySerialized = try replaceUniqueBytes(
                relaxed,
                needle: Data("predicate_count ANY    ".utf8),
                replacement: Data("predicate_count INTEGER".utf8)
            )
        case .alteredTableSQL:
            try exec(
                database,
                "CREATE TEMP TABLE h4_d3b_altered AS SELECT * " +
                    "FROM h4_dual_receipts"
            )
            try exec(database, "DROP TABLE h4_dual_receipts")
            let alteredSQL =
                "CREATE TABLE h4_dual_receipts(" +
                "singleton INTEGER PRIMARY KEY CHECK(singleton=1)," +
                "semantic_schema TEXT NOT NULL CHECK(semantic_schema='" +
                H4C.semanticSchema + "')," +
                "claim_state TEXT NOT NULL CHECK(claim_state='OBSERVED_NONPASS')," +
                "predicate_count INTEGER NOT NULL " +
                    "CHECK(predicate_count>=1 AND predicate_count<=4096)," +
                "authority_vector TEXT NOT NULL " +
                "CHECK(authority_vector='00000000')," +
                "canonical_json BLOB NOT NULL " +
                "CHECK(length(canonical_json)>0 AND length(canonical_json)<=158)," +
                "canonical_cbor BLOB NOT NULL " +
                "CHECK(length(canonical_cbor)>0 AND length(canonical_cbor)<=158)) " +
                "STRICT, WITHOUT ROWID"
            try exec(database, alteredSQL)
            try exec(
                database,
                "INSERT INTO h4_dual_receipts SELECT * FROM temp.h4_d3b_altered"
            )
        }
        let result = try directlySerialized ?? serialize(database)
        guard sqlite3_close(database) == SQLITE_OK else {
            throw HarnessFailure.mutation
        }
        database = nil
        try installImage(result, rootPath: rootPath, acquireLease: true)
    }

    private func installImage(
        _ image: Data,
        rootPath: String,
        acquireLease: Bool
    ) throws {
        var root = open(
            rootPath,
            O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW
        )
        guard root >= 0 else { throw HarnessFailure.mutation }
        var locked = false
        var staging: Int32 = -1
        var renamed = false
        let leaf = ".h4d3b-test-image"
        defer {
            if staging >= 0 { _ = close(staging) }
            if !renamed { _ = unlinkat(root, leaf, 0) }
            if locked { _ = flock(root, LOCK_UN) }
            if root >= 0 { _ = close(root); root = -1 }
        }
        if acquireLease {
            guard flock(root, LOCK_EX | LOCK_NB) == 0 else {
                throw HarnessFailure.mutation
            }
            locked = true
        }
        staging = openat(
            root,
            leaf,
            O_WRONLY | O_CREAT | O_EXCL | O_CLOEXEC | O_NOFOLLOW,
            mode_t(0o600)
        )
        guard staging >= 0 else { throw HarnessFailure.mutation }
        var offset = 0
        while offset < image.count {
            let written = image.withUnsafeBytes { bytes -> Int in
                guard let base = bytes.baseAddress else { return -1 }
                return Darwin.pwrite(
                    staging,
                    base.advanced(by: offset),
                    bytes.count - offset,
                    off_t(offset)
                )
            }
            if written < 0, errno == EINTR { continue }
            guard written > 0 else { throw HarnessFailure.mutation }
            offset += written
        }
        guard fchmod(staging, mode_t(0o400)) == 0,
              fsync(staging) == 0,
              close(staging) == 0 else {
            throw HarnessFailure.mutation
        }
        staging = -1
        let renameStatus = H4D3b.finalLeafName.withCString { finalName in
            leaf.withCString { stagingName in
                renameat(root, stagingName, root, finalName)
            }
        }
        guard renameStatus == 0, fsync(root) == 0 else {
            throw HarnessFailure.mutation
        }
        renamed = true
    }

    private func replaceFinalWithSameBytesWithoutLease(
        rootPath: String
    ) throws {
        let final = URL(fileURLWithPath: rootPath, isDirectory: true)
            .appendingPathComponent(H4D3b.finalLeafName)
        try installImage(
            Data(contentsOf: final, options: [.mappedIfSafe]),
            rootPath: rootPath,
            acquireLease: false
        )
    }

    private func reboundRootWithoutLease(_ rootPath: String) throws {
        let displaced = rootPath + ".h4d3b-displaced"
        guard rename(rootPath, displaced) == 0,
              mkdir(rootPath, mode_t(0o700)) == 0,
              chmod(rootPath, mode_t(0o700)) == 0 else {
            throw HarnessFailure.mutation
        }
    }

    private func helperURL() throws -> URL {
        let candidate = Bundle(for: Self.self).bundleURL
            .deletingLastPathComponent()
            .appendingPathComponent("H4D3bRestartReader", isDirectory: false)
        guard FileManager.default.fileExists(atPath: candidate.path) else {
            throw HarnessFailure.helperAdmission
        }
        return candidate
    }

    private func statDescriptor(_ descriptor: Int32) throws -> stat {
        var value = stat()
        guard fstat(descriptor, &value) == 0 else {
            throw HarnessFailure.helperAdmission
        }
        return value
    }

    private func statNamed(_ path: String) throws -> stat {
        var value = stat()
        guard lstat(path, &value) == 0 else {
            throw HarnessFailure.helperAdmission
        }
        return value
    }

    private func admitHelper(_ url: URL) throws -> HelperAdmission {
        guard let resolved = realpath(url.path, nil) else {
            throw HarnessFailure.helperAdmission
        }
        defer { free(resolved) }
        let path = String(cString: resolved)
        let named = try statNamed(path)
        let descriptor = open(path, O_RDONLY | O_CLOEXEC | O_NOFOLLOW)
        guard descriptor >= 0 else { throw HarnessFailure.helperAdmission }
        do {
            let held = try statDescriptor(descriptor)
            guard helperMetadataIsValid(named),
                  helperMetadataIsValid(held),
                  FileWitness(named) == FileWitness(held) else {
                throw HarnessFailure.helperAdmission
            }
            return HelperAdmission(
                path: path,
                descriptor: descriptor,
                witness: FileWitness(held)
            )
        } catch {
            close(descriptor)
            throw error
        }
    }

    private func helperMetadataIsValid(_ value: stat) -> Bool {
        value.st_mode & S_IFMT == S_IFREG &&
            value.st_mode & 0o7777 == 0o755 &&
            value.st_uid == geteuid() &&
            value.st_nlink == 1 &&
            value.st_size > 0 &&
            value.st_size <= 32 * 1_024 * 1_024
    }

    private func revalidate(_ admission: HelperAdmission) throws {
        let named = try statNamed(admission.path)
        let held = try statDescriptor(admission.descriptor)
        guard helperMetadataIsValid(named),
              helperMetadataIsValid(held),
              FileWitness(named) == admission.witness,
              FileWitness(held) == admission.witness else {
            throw HarnessFailure.helperAdmission
        }
    }

    private func makePipe() throws -> [Int32] {
        var descriptors = [Int32](repeating: -1, count: 2)
        guard pipe(&descriptors) == 0 else { throw HarnessFailure.pipe(errno) }
        do {
            for index in descriptors.indices {
                if descriptors[index] <= STDERR_FILENO {
                    let replacement = fcntl(descriptors[index], F_DUPFD_CLOEXEC, 10)
                    guard replacement >= 0 else { throw HarnessFailure.pipe(errno) }
                    close(descriptors[index])
                    descriptors[index] = replacement
                } else {
                    let flags = fcntl(descriptors[index], F_GETFD)
                    guard flags >= 0,
                          fcntl(descriptors[index], F_SETFD, flags | FD_CLOEXEC) == 0 else {
                        throw HarnessFailure.pipe(errno)
                    }
                }
            }
            return descriptors
        } catch {
            closePair(descriptors)
            throw error
        }
    }

    private func setNonblocking(_ descriptor: Int32) throws {
        let flags = fcntl(descriptor, F_GETFL)
        guard flags >= 0,
              fcntl(descriptor, F_SETFL, flags | O_NONBLOCK) == 0 else {
            throw HarnessFailure.pipe(errno)
        }
    }

    private func drainAvailable(_ descriptor: Int32, into result: inout Data) throws -> Bool {
        var buffer = [UInt8](repeating: 0, count: 256)
        while true {
            let count = buffer.withUnsafeMutableBytes {
                Darwin.read(descriptor, $0.baseAddress, $0.count)
            }
            if count == 0 { return true }
            if count < 0 {
                if errno == EINTR { continue }
                if errno == EAGAIN || errno == EWOULDBLOCK { return false }
                throw HarnessFailure.read(errno)
            }
            guard count <= outputLimit - result.count else {
                throw HarnessFailure.outputBound
            }
            result.append(contentsOf: buffer.prefix(count))
        }
    }

    private func closeDescriptor(_ descriptor: inout Int32) {
        if descriptor >= 0 {
            _ = close(descriptor)
            descriptor = -1
        }
    }

    private func closePair(_ descriptors: [Int32]) {
        for descriptor in descriptors where descriptor >= 0 {
            _ = close(descriptor)
        }
    }

    private func killAndReap(
        _ pid: pid_t,
        status: inout Int32,
        killAttempts: inout Int,
        hardDeadline: UInt64
    ) throws {
        while true {
            let waited = waitpid(pid, &status, WNOHANG)
            if waited == pid { return }
            if waited < 0 {
                if errno == EINTR { continue }
                throw HarnessFailure.wait(errno)
            }
            break
        }
        guard pid > 0, killAttempts == 0 else {
            throw HarnessFailure.containmentUnproven
        }
        killAttempts += 1
        if kill(pid, SIGKILL) != 0, errno != ESRCH {
            throw HarnessFailure.wait(errno)
        }
        while DispatchTime.now().uptimeNanoseconds < hardDeadline {
            let waited = waitpid(pid, &status, WNOHANG)
            if waited == pid { return }
            if waited < 0, errno == EINTR { continue }
            if waited < 0 { throw HarnessFailure.wait(errno) }
            _ = Darwin.poll(nil, 0, 1)
        }
        throw HarnessFailure.containmentUnproven
    }

    private func containChildAfterParentError(
        _ pid: pid_t,
        status: inout Int32,
        reaped: inout Bool,
        killAttempts: inout Int,
        operationDeadline: UInt64,
        hardDeadline: UInt64
    ) throws {
        while !reaped {
            let waited = waitpid(pid, &status, WNOHANG)
            if waited == pid {
                reaped = true
                return
            }
            if waited < 0 {
                if errno == EINTR { continue }
                throw HarnessFailure.wait(errno)
            }
            let now = DispatchTime.now().uptimeNanoseconds
            if now >= operationDeadline {
                try killAndReap(
                    pid,
                    status: &status,
                    killAttempts: &killAttempts,
                    hardDeadline: hardDeadline
                )
                reaped = true
                return
            }
            let remaining = operationDeadline - now
            let milliseconds = max(
                1,
                min(10, Int((remaining + 999_999) / 1_000_000))
            )
            let pollStatus = Darwin.poll(nil, 0, Int32(milliseconds))
            if pollStatus < 0, errno != EINTR {
                throw HarnessFailure.wait(errno)
            }
        }
    }

    private func runHelper(
        arguments: [String],
        startSuspended: Bool = false
    ) throws -> ChildResult {
        let admission = try admitHelper(try helperURL())
        defer { _ = close(admission.descriptor) }
        var output = try makePipe()
        var stderrPipe: [Int32]
        do {
            stderrPipe = try makePipe()
        } catch {
            closePair(output)
            throw error
        }
        var parentDescriptorsOpen = true
        defer {
            if parentDescriptorsOpen {
                closePair(output)
                closePair(stderrPipe)
            }
        }
        try setNonblocking(output[0])
        try setNonblocking(stderrPipe[0])

        var actions: posix_spawn_file_actions_t?
        var attributes: posix_spawnattr_t?
        let actionsStatus = posix_spawn_file_actions_init(&actions)
        guard actionsStatus == 0 else { throw HarnessFailure.spawn(actionsStatus) }
        let attributesStatus = posix_spawnattr_init(&attributes)
        guard attributesStatus == 0 else {
            posix_spawn_file_actions_destroy(&actions)
            throw HarnessFailure.spawn(attributesStatus)
        }
        defer {
            posix_spawn_file_actions_destroy(&actions)
            posix_spawnattr_destroy(&attributes)
        }
        let stdinStatus = "/dev/null".withCString {
            posix_spawn_file_actions_addopen(
                &actions,
                STDIN_FILENO,
                $0,
                O_RDONLY,
                0
            )
        }
        guard stdinStatus == 0 else { throw HarnessFailure.spawn(stdinStatus) }
        for value in [
            posix_spawn_file_actions_adddup2(&actions, output[1], STDOUT_FILENO),
            posix_spawn_file_actions_adddup2(&actions, stderrPipe[1], STDERR_FILENO),
        ] where value != 0 {
            throw HarnessFailure.spawn(value)
        }
        for descriptor in [output[0], output[1], stderrPipe[0], stderrPipe[1]] {
            let value = posix_spawn_file_actions_addclose(&actions, descriptor)
            guard value == 0 else { throw HarnessFailure.spawn(value) }
        }
        let chdirStatus = "/private/var/empty".withCString {
            posix_spawn_file_actions_addchdir(&actions, $0)
        }
        guard chdirStatus == 0 else { throw HarnessFailure.spawn(chdirStatus) }

        var emptyMask = sigset_t()
        var defaultSignals = sigset_t()
        guard sigemptyset(&emptyMask) == 0,
              sigfillset(&defaultSignals) == 0,
              sigdelset(&defaultSignals, SIGKILL) == 0,
              sigdelset(&defaultSignals, SIGSTOP) == 0 else {
            throw HarnessFailure.spawn(errno)
        }
        for value in [
            posix_spawnattr_setsigmask(&attributes, &emptyMask),
            posix_spawnattr_setsigdefault(&attributes, &defaultSignals),
        ] where value != 0 {
            throw HarnessFailure.spawn(value)
        }
        var flags = POSIX_SPAWN_CLOEXEC_DEFAULT |
            POSIX_SPAWN_SETSIGMASK |
            POSIX_SPAWN_SETSIGDEF
        if startSuspended { flags |= POSIX_SPAWN_START_SUSPENDED }
        let flagsStatus = posix_spawnattr_setflags(&attributes, Int16(flags))
        guard flagsStatus == 0 else { throw HarnessFailure.spawn(flagsStatus) }

        let strings = [admission.path] + arguments
        let allocated = strings.map { strdup($0) }
        guard allocated.allSatisfy({ $0 != nil }) else {
            for value in allocated { free(value) }
            throw HarnessFailure.spawn(ENOMEM)
        }
        defer { for value in allocated { free(value) } }
        var argv: [UnsafeMutablePointer<CChar>?] = allocated + [nil]
        var environment: [UnsafeMutablePointer<CChar>?] = [nil]
        let start = DispatchTime.now().uptimeNanoseconds
        let (operationDeadline, operationOverflow) = start.addingReportingOverflow(
            operationNanoseconds
        )
        let (hardDeadline, hardOverflow) = start.addingReportingOverflow(
            hardNanoseconds
        )
        guard !operationOverflow, !hardOverflow else {
            throw HarnessFailure.deadlineOverflow
        }
        var pid: pid_t = 0
        try revalidate(admission)
        let spawnStatus = admission.path.withCString { executable in
            argv.withUnsafeMutableBufferPointer { arguments in
                environment.withUnsafeMutableBufferPointer { envp in
                    posix_spawn(
                        &pid,
                        executable,
                        &actions,
                        &attributes,
                        arguments.baseAddress,
                        envp.baseAddress
                    )
                }
            }
        }
        closeDescriptor(&output[1])
        closeDescriptor(&stderrPipe[1])
        guard spawnStatus == 0, pid > 0 else {
            throw HarnessFailure.spawn(spawnStatus)
        }

        let parentPID = getpid()
        var status: Int32 = 0
        var reaped = false
        var stdout = Data()
        var stderr = Data()
        var stdoutEOF = false
        var stderrEOF = false
        var timedOut = false
        var killAttempts = 0
        var reapElapsedNanoseconds: UInt64?
        var completion = start
        do {
            try revalidate(admission)
            while true {
                if output[0] >= 0 {
                    stdoutEOF = try drainAvailable(output[0], into: &stdout)
                    if stdoutEOF { closeDescriptor(&output[0]) }
                }
                if stderrPipe[0] >= 0 {
                    stderrEOF = try drainAvailable(stderrPipe[0], into: &stderr)
                    if stderrEOF { closeDescriptor(&stderrPipe[0]) }
                }
                if !reaped {
                    let waited = waitpid(pid, &status, WNOHANG)
                    if waited == pid {
                        reaped = true
                        let reapedAt = DispatchTime.now().uptimeNanoseconds
                        reapElapsedNanoseconds = reapedAt >= start ? reapedAt - start : nil
                        try revalidate(admission)
                    } else if waited < 0, errno != EINTR {
                        throw HarnessFailure.wait(errno)
                    }
                }
                let now = DispatchTime.now().uptimeNanoseconds
                if now >= operationDeadline {
                    timedOut = true
                    if !reaped {
                        try killAndReap(
                            pid,
                            status: &status,
                            killAttempts: &killAttempts,
                            hardDeadline: hardDeadline
                        )
                        reaped = true
                        let reapedAt = DispatchTime.now().uptimeNanoseconds
                        reapElapsedNanoseconds = reapedAt >= start ? reapedAt - start : nil
                        try revalidate(admission)
                    }
                    if output[0] >= 0 {
                        stdoutEOF = try drainAvailable(output[0], into: &stdout)
                        closeDescriptor(&output[0])
                    }
                    if stderrPipe[0] >= 0 {
                        stderrEOF = try drainAvailable(stderrPipe[0], into: &stderr)
                        closeDescriptor(&stderrPipe[0])
                    }
                    break
                }
                if reaped && stdoutEOF && stderrEOF { break }
                let remaining = operationDeadline - now
                let milliseconds = max(
                    1,
                    min(10, Int((remaining + 999_999) / 1_000_000))
                )
                var polls = [
                    pollfd(
                        fd: output[0],
                        events: output[0] >= 0 ? Int16(POLLIN | POLLHUP) : 0,
                        revents: 0
                    ),
                    pollfd(
                        fd: stderrPipe[0],
                        events: stderrPipe[0] >= 0 ? Int16(POLLIN | POLLHUP) : 0,
                        revents: 0
                    ),
                ]
                let pollStatus = polls.withUnsafeMutableBufferPointer {
                    Darwin.poll($0.baseAddress, nfds_t($0.count), Int32(milliseconds))
                }
                if pollStatus < 0, errno != EINTR {
                    throw HarnessFailure.wait(errno)
                }
            }
            try revalidate(admission)
            completion = DispatchTime.now().uptimeNanoseconds
            if completion >= operationDeadline { timedOut = true }
        } catch let primaryError {
            var containmentError: Error?
            closeDescriptor(&output[0])
            closeDescriptor(&stderrPipe[0])
            if !reaped {
                do {
                    try containChildAfterParentError(
                        pid,
                        status: &status,
                        reaped: &reaped,
                        killAttempts: &killAttempts,
                        operationDeadline: operationDeadline,
                        hardDeadline: hardDeadline
                    )
                    let reapedAt = DispatchTime.now().uptimeNanoseconds
                    reapElapsedNanoseconds = reapedAt >= start ? reapedAt - start : nil
                    do {
                        try revalidate(admission)
                    } catch {
                        // Preserve the first parent-side error once exact-child
                        // containment has been proven.
                    }
                } catch {
                    containmentError = error
                }
            }
            parentDescriptorsOpen = false
            if let containmentError { throw containmentError }
            throw primaryError
        }

        closeDescriptor(&output[0])
        closeDescriptor(&stderrPipe[0])
        parentDescriptorsOpen = false
        try revalidate(admission)
        completion = DispatchTime.now().uptimeNanoseconds
        if completion >= operationDeadline { timedOut = true }
        let elapsed = completion >= start ? completion - start : UInt64.max
        return ChildResult(
            parentPID: parentPID,
            pid: pid,
            status: status,
            reaped: reaped,
            stdout: stdout,
            stderr: stderr,
            stdoutEOF: stdoutEOF,
            stderrEOF: stderrEOF,
            timedOut: timedOut,
            killAttempts: killAttempts,
            elapsedNanoseconds: elapsed,
            reapElapsedNanoseconds: reapElapsedNanoseconds
        )
    }

    private func assertTerminal(
        _ result: ChildResult,
        exitCode: Int32,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertTrue(
            terminalAdmitted(result, expectedExitCode: exitCode),
            file: file,
            line: line
        )
        XCTAssertGreaterThan(result.pid, 0, file: file, line: line)
        XCTAssertNotEqual(result.pid, result.parentPID, file: file, line: line)
        XCTAssertTrue(result.reaped, file: file, line: line)
        XCTAssertTrue(result.exited, file: file, line: line)
        XCTAssertEqual(result.exitCode, exitCode, file: file, line: line)
        XCTAssertEqual(result.signal, 0, file: file, line: line)
        XCTAssertTrue(result.stdout.isEmpty, file: file, line: line)
        XCTAssertTrue(result.stderr.isEmpty, file: file, line: line)
        XCTAssertTrue(result.stdoutEOF, file: file, line: line)
        XCTAssertTrue(result.stderrEOF, file: file, line: line)
        XCTAssertFalse(result.timedOut, file: file, line: line)
        XCTAssertEqual(result.killAttempts, 0, file: file, line: line)
        XCTAssertLessThan(
            result.elapsedNanoseconds,
            operationNanoseconds,
            file: file,
            line: line
        )
    }

    private func terminalAdmitted(
        _ result: ChildResult,
        expectedExitCode: Int32,
        streamsWithinBounds: Bool = true
    ) -> Bool {
        result.pid > 0 &&
            result.pid != result.parentPID &&
            result.reaped &&
            result.exited &&
            result.exitCode == expectedExitCode &&
            result.signal == 0 &&
            streamsWithinBounds &&
            result.stdout.count <= outputLimit &&
            result.stderr.count <= outputLimit &&
            result.stdout.isEmpty &&
            result.stderr.isEmpty &&
            result.stdoutEOF &&
            result.stderrEOF &&
            !result.timedOut &&
            result.killAttempts == 0 &&
            result.elapsedNanoseconds < operationNanoseconds &&
            result.reapElapsedNanoseconds != nil &&
            result.reapElapsedNanoseconds! < operationNanoseconds
    }

    private func assertRejected(
        _ rootPath: String,
        fault: H4D3b.TestFault,
        expected: H4D3b.Failure,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(
            H4D3b.inspectForTest(rootPath: rootPath, fault: fault),
            .rejected(expected),
            "fault: \(fault)",
            file: file,
            line: line
        )
    }

    private func finalReplacementHooks(
        rootPath: String,
        point: H4D3b.TestHookPoint
    ) -> H4D3b.TestHooks {
        let replace = { try self.replaceFinalWithSameBytesWithoutLease(
            rootPath: rootPath
        ) }
        switch point {
        case .afterNamedFinalBeforeOpen:
            return .init(afterNamedFinalBeforeOpen: replace)
        case .afterHeaderReadBeforeMetadataJoin:
            return .init(afterHeaderReadBeforeMetadataJoin: replace)
        case .afterImageReadBeforeMetadataJoin:
            return .init(afterImageReadBeforeMetadataJoin: replace)
        case .afterSQLiteCloseBeforeFinalJoin:
            return .init(afterSQLiteCloseBeforeFinalJoin: replace)
        case .afterPrecloseFinalJoin:
            return .init(afterPrecloseFinalJoin: replace)
        case .afterFinalCloseBeforeNamedJoin:
            return .init(afterFinalCloseBeforeNamedJoin: replace)
        case .afterPostcloseNamedJoinBeforeTerminal:
            return .init(afterPostcloseNamedJoinBeforeTerminal: replace)
        case .afterNamedRootBeforeOpen, .afterInitialInventory:
            preconditionFailure("final identity is not yet sampled")
        }
    }

    private func rootReboundHooks(
        rootPath: String,
        point: H4D3b.TestHookPoint
    ) -> H4D3b.TestHooks {
        let rebound = { try self.reboundRootWithoutLease(rootPath) }
        switch point {
        case .afterNamedRootBeforeOpen:
            return .init(afterNamedRootBeforeOpen: rebound)
        case .afterInitialInventory:
            return .init(afterInitialInventory: rebound)
        case .afterNamedFinalBeforeOpen:
            return .init(afterNamedFinalBeforeOpen: rebound)
        case .afterHeaderReadBeforeMetadataJoin:
            return .init(afterHeaderReadBeforeMetadataJoin: rebound)
        case .afterImageReadBeforeMetadataJoin:
            return .init(afterImageReadBeforeMetadataJoin: rebound)
        case .afterSQLiteCloseBeforeFinalJoin:
            return .init(afterSQLiteCloseBeforeFinalJoin: rebound)
        case .afterPrecloseFinalJoin:
            return .init(afterPrecloseFinalJoin: rebound)
        case .afterFinalCloseBeforeNamedJoin:
            return .init(afterFinalCloseBeforeNamedJoin: rebound)
        case .afterPostcloseNamedJoinBeforeTerminal:
            return .init(afterPostcloseNamedJoinBeforeTerminal: rebound)
        }
    }

    func testNestedPublicationLifetimeReleasesWriterAndFreshHelperAccepts() throws {
        let rootPath = try publishedRoot()
        guard case .validV3DualStreamThreeWayJoin(let receipt) =
                H4D3b.inspect(rootPath: rootPath) else {
            return XCTFail("expected retained representation admission")
        }
        XCTAssertEqual(receipt.classification, H4D3b.result)
        XCTAssertTrue(receipt.v3ImageAdmitted)
        XCTAssertTrue(receipt.canonicalJSONCBORIndexedScalarJoin)
        XCTAssertTrue(receipt.representationAdmissionOnly)
        XCTAssertFalse(receipt.historicalProducerIdentityRecovered)
        XCTAssertFalse(receipt.restartAuthenticityEstablished)
        XCTAssertFalse(receipt.h4Entered)
        XCTAssertEqual(receipt.authorityVector, "00000000")
        XCTAssertEqual(Mirror(reflecting: receipt).children.count, 0)

        let child = try runHelper(arguments: [rootPath])
        assertTerminal(child, exitCode: 0)
    }

    func testFaultScheduleIsFailClosedAtEachBoundary() throws {
        let rootPath = try publishedRoot()
        let schedule: [(H4D3b.TestFault, H4D3b.Failure)] = [
            (.rootOpenRejected, .rootRejected),
            (.rootLockRejected, .rootRejected),
            (.directoryScanRejected, .namespaceRejected),
            (.finalOpenRejected, .finalOpenRejected),
            (.headerReadZero, .readRejected),
            (.headerReadRejected, .readRejected),
            (.imageReadZero, .readRejected),
            (.imageReadRejected, .readRejected),
            (.eofReadNonzero, .readRejected),
            (.imageAllocationRejected, .allocationRejected),
            (.sqliteOpenRejected, .sqliteOpenRejected),
            (.sqliteAllocationRejected, .allocationRejected),
            (.deserializeRejected, .sqlitePolicyRejected),
            (.readerHardeningRejected, .sqlitePolicyRejected),
            (.queryOnlyRejected, .sqlitePolicyRejected),
            (.filenameRejected, .sqlitePolicyRejected),
            (.integrityRejected, .integrityRejected),
            (.schemaRejected, .schemaRejected),
            (.authorizerRejected, .sqlitePolicyRejected),
            (.rowRejected, .rowRejected),
            (.jsonRejected, .jsonRejected),
            (.cborRejected, .cborRejected),
            (.scalarRejected, .semanticMismatch),
            (.statementLeak, .closeRejected),
            (.databaseCloseResponseLost, .closeRejected),
            (.finalCloseResponseLost, .closeRejected),
            (.rootCloseResponseLost, .closeRejected),
        ]
        for (fault, expected) in schedule {
            assertRejected(rootPath, fault: fault, expected: expected)
        }
    }

    func testReadRetriesAndHeaderPrecedesImageAllocation() throws {
        let rootPath = try publishedRoot()
        for fault in [
            H4D3b.TestFault.headerReadInterruptedOnce,
            .headerReadShortOnce,
            .imageReadInterruptedOnce,
            .imageReadShortOnce,
            .eofReadInterruptedOnce,
        ] {
            let retryEvents = H4D3b.TestEvents()
            let retryOutcome = H4D3b.inspectForTest(
                rootPath: rootPath,
                fault: fault,
                events: retryEvents
            )
            guard case .validV3DualStreamThreeWayJoin = retryOutcome else {
                return XCTFail(
                    "retry fault did not recover: \(fault); outcome: " +
                    "\(retryOutcome); events: \(retryEvents.snapshot())"
                )
            }
        }

        let events = H4D3b.TestEvents()
        let outcome = H4D3b.inspectForTest(
            rootPath: rootPath,
            events: events
        )
        guard case .validV3DualStreamThreeWayJoin = outcome else {
            return XCTFail(
                "baseline inspection rejected: \(outcome); events: \(events.snapshot())"
            )
        }
        let values = events.snapshot()
        let header = try XCTUnwrap(values.firstIndex(of: .headerValidated))
        let allocation = try XCTUnwrap(values.firstIndex(where: {
            if case .imageAllocationEntered = $0 { return true }
            return false
        }))
        let sqlite = try XCTUnwrap(values.firstIndex(of: .sqliteOpenEntered))
        XCTAssertLessThan(header, allocation)
        XCTAssertLessThan(allocation, sqlite)

        let rejectedEvents = H4D3b.TestEvents()
        XCTAssertEqual(
            H4D3b.inspectForTest(
                rootPath: rootPath,
                fault: .imageAllocationRejected,
                events: rejectedEvents
            ),
            .rejected(.allocationRejected)
        )
        let rejectedValues = rejectedEvents.snapshot()
        XCTAssertTrue(rejectedValues.contains(.headerValidated))
        XCTAssertTrue(rejectedValues.contains(where: {
            if case .imageAllocationEntered = $0 { return true }
            return false
        }))
        XCTAssertFalse(rejectedValues.contains(.sqliteOpenEntered))
    }

    func testCopiedMetadataPredicatesRejectOwnerTypeAndShapeButNotDevice() throws {
        let rootPath = try publishedRoot()
        var root = stat()
        XCTAssertEqual(lstat(rootPath, &root), 0)
        XCTAssertTrue(H4D3b.rootMetadataIsValidForTest(root))
        var copiedRoot = root
        copiedRoot.st_dev = dev_t(bitPattern: UInt32(truncatingIfNeeded: root.st_dev) ^ 1)
        XCTAssertTrue(H4D3b.rootMetadataIsValidForTest(copiedRoot))
        copiedRoot.st_uid = geteuid() == 0 ? 1 : 0
        XCTAssertFalse(H4D3b.rootMetadataIsValidForTest(copiedRoot))
        copiedRoot = root
        copiedRoot.st_mode = (copiedRoot.st_mode & ~mode_t(0o7777)) | mode_t(0o755)
        XCTAssertFalse(H4D3b.rootMetadataIsValidForTest(copiedRoot))

        let finalPath = URL(fileURLWithPath: rootPath)
            .appendingPathComponent(H4D3b.finalLeafName).path
        var final = stat()
        XCTAssertEqual(lstat(finalPath, &final), 0)
        let size = Int(final.st_size)
        XCTAssertTrue(H4D3b.finalMetadataIsValidForTest(final, expectedSize: size))
        var copiedFinal = final
        copiedFinal.st_dev = dev_t(bitPattern: UInt32(truncatingIfNeeded: final.st_dev) ^ 1)
        XCTAssertTrue(H4D3b.finalMetadataIsValidForTest(
            copiedFinal,
            expectedSize: size
        ))
        copiedFinal = final
        copiedFinal.st_nlink = 2
        XCTAssertFalse(H4D3b.finalMetadataIsValidForTest(
            copiedFinal,
            expectedSize: size
        ))
        for type in [S_IFDIR, S_IFIFO, S_IFCHR, S_IFBLK, S_IFSOCK] {
            copiedFinal = final
            copiedFinal.st_mode = (copiedFinal.st_mode & ~S_IFMT) | type
            XCTAssertFalse(H4D3b.finalMetadataIsValidForTest(
                copiedFinal,
                expectedSize: size
            ))
        }
        copiedFinal = final
        copiedFinal.st_mode =
            (copiedFinal.st_mode & ~mode_t(0o7777)) | mode_t(0o600)
        XCTAssertFalse(H4D3b.finalMetadataIsValidForTest(
            copiedFinal,
            expectedSize: size
        ))
        copiedFinal = final
        copiedFinal.st_size += 1
        XCTAssertFalse(H4D3b.finalMetadataIsValidForTest(
            copiedFinal,
            expectedSize: Int(copiedFinal.st_size)
        ))
    }

    func testCanonicalNamespaceAndSpecialFilesAreRejected() throws {
        let rootPath = try publishedRoot()
        let root = URL(fileURLWithPath: rootPath, isDirectory: true)
        let extra = root.appendingPathComponent("extra")
        XCTAssertTrue(FileManager.default.createFile(atPath: extra.path, contents: Data()))
        XCTAssertEqual(H4D3b.inspect(rootPath: rootPath), .rejected(.namespaceRejected))
        try FileManager.default.removeItem(at: extra)

        let aliasPath = rootPath + ".h4d3b-alias"
        addTeardownBlock { try? FileManager.default.removeItem(atPath: aliasPath) }
        XCTAssertEqual(symlink(rootPath, aliasPath), 0)
        XCTAssertEqual(H4D3b.inspect(rootPath: aliasPath), .rejected(.rootRejected))

        let regular = root.appendingPathComponent("regular-root")
        XCTAssertTrue(FileManager.default.createFile(atPath: regular.path, contents: Data()))
        XCTAssertEqual(H4D3b.inspect(rootPath: regular.path), .rejected(.rootRejected))

        for noncanonical in [
            rootPath + "/",
            rootPath.replacingOccurrences(of: "/private/tmp/", with: "/private//tmp/"),
            "/private/tmp/./" + URL(fileURLWithPath: rootPath).lastPathComponent,
            "/private/tmp/../tmp/" + URL(fileURLWithPath: rootPath).lastPathComponent,
            String(rootPath.dropFirst()),
        ] {
            XCTAssertEqual(
                H4D3b.inspect(rootPath: noncanonical),
                .rejected(.rootRejected),
                "path: \(noncanonical)"
            )
        }

        let wrongModeRoot = try publishedRoot()
        XCTAssertEqual(chmod(wrongModeRoot, mode_t(0o755)), 0)
        XCTAssertEqual(
            H4D3b.inspect(rootPath: wrongModeRoot),
            .rejected(.rootRejected)
        )
    }

    func testCoherentSubstitutionIsRepresentationValidButMismatchRejects() throws {
        let coherentRoot = try publishedRoot()
        try mutatePublishedImage(
            rootPath: coherentRoot,
            mutation: .coherentSubstitution
        )
        guard case .validV3DualStreamThreeWayJoin = H4D3b.inspect(
            rootPath: coherentRoot
        ) else {
            return XCTFail("coherent three-field representation was rejected")
        }
        assertTerminal(
            try runHelper(arguments: [coherentRoot]),
            exitCode: 0
        )

        let mismatchRoot = try publishedRoot()
        try mutatePublishedImage(
            rootPath: mismatchRoot,
            mutation: .scalarMismatch
        )
        XCTAssertEqual(
            H4D3b.inspect(rootPath: mismatchRoot),
            .rejected(.semanticMismatch)
        )
        assertTerminal(
            try runHelper(arguments: [mismatchRoot]),
            exitCode: 70
        )
    }

    func testJSONAndCBORMutationsRejectBeforeSemanticAdmission() throws {
        let cases: [(ImageMutation, H4D3b.Failure)] = [
            (.jsonCorrupt, .jsonRejected),
            (.jsonNoncanonical, .jsonRejected),
            (.jsonTrailing, .jsonRejected),
            (.jsonAlias, .jsonRejected),
            (.jsonUnknownField, .jsonRejected),
            (.jsonDuplicateField, .jsonRejected),
            (.cborCorrupt, .cborRejected),
            (.cborNoncanonical, .cborRejected),
            (.cborTrailing, .cborRejected),
            (.cborAlias, .cborRejected),
            (.cborUnknownField, .cborRejected),
            (.cborDuplicateField, .cborRejected),
        ]
        for (mutation, expected) in cases {
            let rootPath = try publishedRoot()
            try mutatePublishedImage(rootPath: rootPath, mutation: mutation)
            XCTAssertEqual(
                H4D3b.inspect(rootPath: rootPath),
                .rejected(expected),
                "mutation: \(mutation)"
            )
        }
    }

    func testSchemaRowAndStorageMutationsAreFailClosed() throws {
        let cases: [ImageMutation] = [
            .wrongUserVersion,
            .wrongApplicationID,
            .extraSchemaObject,
            .extraColumn,
            .v2Schema,
            .extraRow,
            .wrongScalarStorage,
            .alteredTableSQL,
        ]
        for mutation in cases {
            let rootPath = try publishedRoot()
            try mutatePublishedImage(rootPath: rootPath, mutation: mutation)
            guard case .rejected = H4D3b.inspect(rootPath: rootPath) else {
                return XCTFail("mutation admitted: \(mutation)")
            }
        }
    }

    func testMalformedHeadersRejectBeforeImageAllocation() throws {
        let mutations: [(inout Data) -> Void] = [
            { $0[0] ^= 1 },
            { $0[16] = 0 },
            { $0[17] = 1 },
            { $0[18] = 2 },
            { $0[19] = 2 },
            { $0.replaceSubrange(28...31, with: [0, 0, 0, 0]) },
            { $0.replaceSubrange(28...31, with: [0, 0, 0, 65]) },
            { $0[31] ^= 1 },
        ]
        for mutate in mutations {
            let rootPath = try publishedRoot()
            let final = URL(fileURLWithPath: rootPath, isDirectory: true)
                .appendingPathComponent(H4D3b.finalLeafName)
            var image = try Data(contentsOf: final)
            mutate(&image)
            try installImage(image, rootPath: rootPath, acquireLease: true)
            let events = H4D3b.TestEvents()
            XCTAssertEqual(
                H4D3b.inspectForTest(rootPath: rootPath, events: events),
                .rejected(.headerRejected)
            )
            XCTAssertFalse(events.snapshot().contains(where: {
                if case .imageAllocationEntered = $0 { return true }
                return false
            }))
        }

        let oversizedRoot = try publishedRoot()
        let oversized = Data(
            repeating: 0,
            count: H4D3b.maximumImageBytes + Int(H4D3b.pageSize)
        )
        try installImage(
            oversized,
            rootPath: oversizedRoot,
            acquireLease: true
        )
        let events = H4D3b.TestEvents()
        XCTAssertEqual(
            H4D3b.inspectForTest(rootPath: oversizedRoot, events: events),
            .rejected(.identityRejected)
        )
        XCTAssertFalse(events.snapshot().contains(where: {
            if case .imageAllocationEntered = $0 { return true }
            return false
        }))

        let misalignedRoot = try publishedRoot()
        let misalignedFinal = URL(
            fileURLWithPath: misalignedRoot,
            isDirectory: true
        ).appendingPathComponent(H4D3b.finalLeafName)
        var misaligned = try Data(contentsOf: misalignedFinal)
        misaligned.removeLast()
        try installImage(
            misaligned,
            rootPath: misalignedRoot,
            acquireLease: true
        )
        let misalignedEvents = H4D3b.TestEvents()
        XCTAssertEqual(
            H4D3b.inspectForTest(
                rootPath: misalignedRoot,
                events: misalignedEvents
            ),
            .rejected(.identityRejected)
        )
        XCTAssertFalse(misalignedEvents.snapshot().contains(where: {
            if case .imageAllocationEntered = $0 { return true }
            return false
        }))
    }

    func testRootLeaseAndFinalSpecialFilesRejectWithoutBlocking() throws {
        let lockedRoot = try publishedRoot()
        let lock = open(
            lockedRoot,
            O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW
        )
        XCTAssertGreaterThanOrEqual(lock, 0)
        guard lock >= 0 else { return }
        XCTAssertEqual(flock(lock, LOCK_EX | LOCK_NB), 0)
        XCTAssertEqual(
            H4D3b.inspect(rootPath: lockedRoot),
            .rejected(.rootRejected)
        )
        XCTAssertEqual(flock(lock, LOCK_UN), 0)
        XCTAssertEqual(close(lock), 0)

        let fifoRoot = try publishedRoot()
        let fifo = URL(fileURLWithPath: fifoRoot, isDirectory: true)
            .appendingPathComponent(H4D3b.finalLeafName).path
        XCTAssertEqual(unlink(fifo), 0)
        XCTAssertEqual(mkfifo(fifo, mode_t(0o400)), 0)
        XCTAssertEqual(
            H4D3b.inspect(rootPath: fifoRoot),
            .rejected(.identityRejected)
        )

        let symlinkRoot = try publishedRoot()
        let link = URL(fileURLWithPath: symlinkRoot, isDirectory: true)
            .appendingPathComponent(H4D3b.finalLeafName).path
        XCTAssertEqual(unlink(link), 0)
        XCTAssertEqual(symlink("/dev/null", link), 0)
        XCTAssertEqual(
            H4D3b.inspect(rootPath: symlinkRoot),
            .rejected(.identityRejected)
        )

        let directoryRoot = try publishedRoot()
        let directory = URL(fileURLWithPath: directoryRoot, isDirectory: true)
            .appendingPathComponent(H4D3b.finalLeafName).path
        XCTAssertEqual(unlink(directory), 0)
        XCTAssertEqual(mkdir(directory, mode_t(0o700)), 0)
        XCTAssertEqual(
            H4D3b.inspect(rootPath: directoryRoot),
            .rejected(.identityRejected)
        )

        let modeRoot = try publishedRoot()
        let modeLeaf = URL(fileURLWithPath: modeRoot, isDirectory: true)
            .appendingPathComponent(H4D3b.finalLeafName).path
        XCTAssertEqual(chmod(modeLeaf, mode_t(0o600)), 0)
        XCTAssertEqual(
            H4D3b.inspect(rootPath: modeRoot),
            .rejected(.identityRejected)
        )

        let linkedRoot = try publishedRoot()
        let linkedLeaf = URL(fileURLWithPath: linkedRoot, isDirectory: true)
            .appendingPathComponent(H4D3b.finalLeafName).path
        let secondLink = linkedRoot + ".h4d3b-second-link"
        addTeardownBlock { try? FileManager.default.removeItem(atPath: secondLink) }
        XCTAssertEqual(Darwin.link(linkedLeaf, secondLink), 0)
        XCTAssertEqual(
            H4D3b.inspect(rootPath: linkedRoot),
            .rejected(.identityRejected)
        )
    }

    func testEveryPostSamplingFinalVnodeIntersticeRejectsReplacement() throws {
        let points: [H4D3b.TestHookPoint] = [
            .afterNamedFinalBeforeOpen,
            .afterHeaderReadBeforeMetadataJoin,
            .afterImageReadBeforeMetadataJoin,
            .afterSQLiteCloseBeforeFinalJoin,
            .afterPrecloseFinalJoin,
            .afterFinalCloseBeforeNamedJoin,
            .afterPostcloseNamedJoinBeforeTerminal,
        ]
        for point in points {
            let rootPath = try publishedRoot()
            let events = H4D3b.TestEvents()
            XCTAssertEqual(
                H4D3b.inspectForTest(
                    rootPath: rootPath,
                    hooks: finalReplacementHooks(
                        rootPath: rootPath,
                        point: point
                    ),
                    events: events
                ),
                .rejected(.identityRejected),
                "hook: \(point)"
            )
            XCTAssertTrue(
                events.snapshot().contains(.hookEntered(point)),
                "hook: \(point)"
            )
        }
    }

    func testEveryRootIntersticeRejectsNamedRootRebound() throws {
        let points: [H4D3b.TestHookPoint] = [
            .afterNamedRootBeforeOpen,
            .afterInitialInventory,
            .afterNamedFinalBeforeOpen,
            .afterHeaderReadBeforeMetadataJoin,
            .afterImageReadBeforeMetadataJoin,
            .afterSQLiteCloseBeforeFinalJoin,
            .afterPrecloseFinalJoin,
            .afterFinalCloseBeforeNamedJoin,
            .afterPostcloseNamedJoinBeforeTerminal,
        ]
        for point in points {
            let rootPath = try publishedRoot()
            let events = H4D3b.TestEvents()
            XCTAssertEqual(
                H4D3b.inspectForTest(
                    rootPath: rootPath,
                    hooks: rootReboundHooks(rootPath: rootPath, point: point),
                    events: events
                ),
                .rejected(.rootRejected),
                "hook: \(point)"
            )
            XCTAssertTrue(
                events.snapshot().contains(.hookEntered(point)),
                "hook: \(point)"
            )
        }
    }

    func testTerminalAdmissionRejectsEveryNonExactTerminalShape() {
        func sample(
            parentPID: pid_t = 1,
            pid: pid_t = 2,
            status: Int32 = 0,
            reaped: Bool = true,
            stdout: Data = Data(),
            stderr: Data = Data(),
            stdoutEOF: Bool = true,
            stderrEOF: Bool = true,
            timedOut: Bool = false,
            killAttempts: Int = 0,
            elapsed: UInt64 = 1,
            reapElapsed: UInt64? = 1
        ) -> ChildResult {
            ChildResult(
                parentPID: parentPID,
                pid: pid,
                status: status,
                reaped: reaped,
                stdout: stdout,
                stderr: stderr,
                stdoutEOF: stdoutEOF,
                stderrEOF: stderrEOF,
                timedOut: timedOut,
                killAttempts: killAttempts,
                elapsedNanoseconds: elapsed,
                reapElapsedNanoseconds: reapElapsed
            )
        }

        XCTAssertTrue(terminalAdmitted(sample(), expectedExitCode: 0))
        XCTAssertFalse(terminalAdmitted(
            sample(pid: 1),
            expectedExitCode: 0
        ))
        XCTAssertFalse(terminalAdmitted(
            sample(status: 70 << 8),
            expectedExitCode: 0
        ))
        XCTAssertFalse(terminalAdmitted(
            sample(status: SIGTERM),
            expectedExitCode: 0
        ))
        XCTAssertFalse(terminalAdmitted(
            sample(reaped: false),
            expectedExitCode: 0
        ))
        XCTAssertFalse(terminalAdmitted(
            sample(stdout: Data([1])),
            expectedExitCode: 0
        ))
        XCTAssertFalse(terminalAdmitted(
            sample(stderr: Data([1])),
            expectedExitCode: 0
        ))
        XCTAssertFalse(terminalAdmitted(
            sample(stdout: Data(repeating: 1, count: outputLimit + 1)),
            expectedExitCode: 0,
            streamsWithinBounds: false
        ))
        XCTAssertFalse(terminalAdmitted(
            sample(stdoutEOF: false),
            expectedExitCode: 0
        ))
        XCTAssertFalse(terminalAdmitted(
            sample(stderrEOF: false),
            expectedExitCode: 0
        ))
        XCTAssertFalse(terminalAdmitted(
            sample(timedOut: true),
            expectedExitCode: 0
        ))
        XCTAssertFalse(terminalAdmitted(
            sample(killAttempts: 1),
            expectedExitCode: 0
        ))
        XCTAssertFalse(terminalAdmitted(
            sample(elapsed: operationNanoseconds),
            expectedExitCode: 0
        ))
        XCTAssertFalse(terminalAdmitted(
            sample(reapElapsed: nil),
            expectedExitCode: 0
        ))
        XCTAssertFalse(terminalAdmitted(
            sample(reapElapsed: operationNanoseconds),
            expectedExitCode: 0
        ))
    }

    func testHelperSourceMembershipAndBinaryExcludeAuthoritySurfaces() throws {
        let repository = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let mainSource = try String(
            contentsOf: repository.appendingPathComponent(
                "Sources/H4D3bRestartReaderMain.swift"
            ),
            encoding: .utf8
        )
        let project = try String(
            contentsOf: repository.appendingPathComponent(
                "ErgenticsProvenance.xcodeproj/project.pbxproj"
            ),
            encoding: .utf8
        )
        let sourceStart = try XCTUnwrap(project.range(
            of: "B50000000000000000000007 /* Sources */ = {"
        ))
        let sourceTail = project[sourceStart.lowerBound...]
        let sourceEnd = try XCTUnwrap(sourceTail.range(
            of: "runOnlyForDeploymentPostprocessing = 0;"
        ))
        let helperSources = String(sourceTail[..<sourceEnd.upperBound])
        XCTAssertTrue(helperSources.contains(
            "HypervisorStageH4DualStreamRestartInspection.swift in Sources"
        ))
        XCTAssertTrue(helperSources.contains(
            "H4D3bRestartReaderMain.swift in Sources"
        ))
        for forbidden in [
            "HypervisorStageH4Privacy.swift",
            "HypervisorStageH4OwnerBinding.swift",
            "HypervisorStageH4CanonicalStreams.swift",
            "HypervisorStageH4DualStreamPersistence.swift",
            "HypervisorStageH4DualStreamRestartInspectionTests.swift",
        ] {
            XCTAssertFalse(helperSources.contains(forbidden), forbidden)
        }

        let forbiddenStrings = [
            "Hypervisor.framework",
            "com.apple.security.hypervisor",
            "EPR_H4_PRIVACY_TESTS",
            "TestFault",
            "OwnerBoundCanonicalProjection",
            "DualStreamPersistenceCoordinator",
            "posix_spawn",
            "waitpid",
            "SIGKILL",
        ]
        let binary = try Data(contentsOf: try helperURL())
        for forbidden in forbiddenStrings {
            XCTAssertFalse(
                mainSource.contains(forbidden),
                "main source: \(forbidden)"
            )
            XCTAssertNil(
                binary.range(of: Data(forbidden.utf8)),
                "helper binary: \(forbidden)"
            )
        }
    }

    func testWrongArgumentCountsRejectInFreshProcesses() throws {
        assertTerminal(try runHelper(arguments: []), exitCode: 70)
        let rootPath = try publishedRoot()
        assertTerminal(
            try runHelper(arguments: [rootPath, "unexpected"]),
            exitCode: 70
        )
    }

    func testSuspendedChildTimesOutWithOneExactPIDKillAndReap() throws {
        let rootPath = try publishedRoot()
        let result = try runHelper(
            arguments: [rootPath],
            startSuspended: true
        )
        XCTAssertGreaterThan(result.pid, 0)
        XCTAssertNotEqual(result.pid, result.parentPID)
        XCTAssertTrue(result.timedOut)
        XCTAssertTrue(result.reaped)
        XCTAssertFalse(result.exited)
        XCTAssertEqual(result.signal, SIGKILL)
        XCTAssertEqual(result.killAttempts, 1)
        XCTAssertTrue(result.stdout.isEmpty)
        XCTAssertTrue(result.stderr.isEmpty)
        XCTAssertTrue(result.stdoutEOF)
        XCTAssertTrue(result.stderrEOF)
        XCTAssertGreaterThanOrEqual(
            result.elapsedNanoseconds,
            operationNanoseconds
        )
        XCTAssertLessThan(result.elapsedNanoseconds, hardNanoseconds)
        XCTAssertNotNil(result.reapElapsedNanoseconds)
        XCTAssertGreaterThanOrEqual(
            result.reapElapsedNanoseconds ?? 0,
            operationNanoseconds
        )
        XCTAssertLessThan(
            result.reapElapsedNanoseconds ?? .max,
            hardNanoseconds
        )
    }
}
