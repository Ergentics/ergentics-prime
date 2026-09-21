import CryptoKit
import Darwin
import Foundation
import SQLite3

indirect enum GuestCBORValue: Equatable, Sendable {
    case unsigned(UInt64)
    case text(String)
    case bytes(Data)
    case array([GuestCBORValue])
    case map([String: GuestCBORValue])
    case bool(Bool)
}

struct GuestJournalFailure: Error, CustomStringConvertible {
    let description: String
    init(_ description: String) { self.description = description }
}

// RFC 8949 core deterministic encoding: shortest arguments, definite lengths,
// bytewise ordering of encoded map keys. No floating point, tags or null values.
enum GuestCBOR {
    static let maximumBytes = 1_048_576
    static let maximumDepth = 16
    static let maximumCollectionCount = 256
    static let maximumNodes = 8_192

    static func encode(_ value: GuestCBORValue) throws -> Data {
        var encoder = Encoder()
        try encoder.put(value, depth: 0)
        return encoder.output
    }

    // Parsing independently reads CBOR arguments; it never uses the encoder's
    // framing helper. Exact re-encoding additionally rejects representational
    // aliases. UTF-8 map-key aliases that collide as Swift Strings reject.
    static func decode(_ bytes: Data) throws -> GuestCBORValue {
        guard !bytes.isEmpty, bytes.count <= maximumBytes else {
            throw GuestJournalFailure("CBOR frame size is outside the bound")
        }
        var decoder = Decoder(bytes: Array(bytes))
        let value = try decoder.take(depth: 0)
        guard decoder.offset == bytes.count, try encode(value) == bytes else {
            throw GuestJournalFailure("CBOR is trailing or not core deterministic")
        }
        return value
    }

    private struct Encoder {
        var output = Data()
        var nodes = 0

        mutating func add(_ bytes: Data) throws {
            guard bytes.count <= maximumBytes - output.count else {
                throw GuestJournalFailure("CBOR exceeds the byte bound")
            }
            output.append(bytes)
        }
        mutating func argument(_ major: UInt8, _ value: UInt64) throws {
            var frame = Data()
            if value < 24 {
                frame.append((major << 5) | UInt8(value))
            } else {
                let width: Int = value <= 0xff ? 1 : value <= 0xffff ? 2 : value <= 0xffff_ffff ? 4 : 8
                let additional: UInt8 = width == 1 ? 24 : width == 2 ? 25 : width == 4 ? 26 : 27
                frame.append((major << 5) | additional)
                for index in (0..<width).reversed() {
                    frame.append(UInt8(truncatingIfNeeded: value >> (index * 8)))
                }
            }
            try add(frame)
        }
        mutating func put(_ value: GuestCBORValue, depth: Int) throws {
            guard depth <= maximumDepth, nodes < maximumNodes else {
                throw GuestJournalFailure("CBOR nesting or node count exceeds the bound")
            }
            nodes += 1
            switch value {
            case .unsigned(let value): try argument(0, value)
            case .bool(let value): try add(Data([value ? 0xf5 : 0xf4]))
            case .bytes(let bytes):
                try argument(2, UInt64(bytes.count))
                try add(bytes)
            case .text(let text):
                guard text.utf8.count <= maximumBytes - output.count else {
                    throw GuestJournalFailure("CBOR text exceeds the byte bound")
                }
                let bytes = Data(text.utf8)
                try argument(3, UInt64(bytes.count))
                try add(bytes)
            case .array(let values):
                guard values.count <= maximumCollectionCount else {
                    throw GuestJournalFailure("CBOR array exceeds the entry bound")
                }
                try argument(4, UInt64(values.count))
                for value in values { try put(value, depth: depth + 1) }
            case .map(let values):
                guard values.count <= maximumCollectionCount else {
                    throw GuestJournalFailure("CBOR map exceeds the entry bound")
                }
                var entries: [(key: Data, value: GuestCBORValue)] = []
                var keyBytes = 0
                for (key, value) in values {
                    var keyEncoder = Encoder()
                    try keyEncoder.put(.text(key), depth: depth + 1)
                    guard keyEncoder.output.count <= maximumBytes - keyBytes else {
                        throw GuestJournalFailure("CBOR map keys exceed the byte bound")
                    }
                    keyBytes += keyEncoder.output.count
                    entries.append((keyEncoder.output, value))
                }
                entries.sort { $0.key.lexicographicallyPrecedes($1.key) }
                try argument(5, UInt64(entries.count))
                for entry in entries {
                    guard nodes < maximumNodes else { throw GuestJournalFailure("CBOR node bound") }
                    nodes += 1
                    try add(entry.key)
                    try put(entry.value, depth: depth + 1)
                }
            }
        }
    }

    private struct Decoder {
        let bytes: [UInt8]
        var offset = 0
        var nodes = 0

        mutating func argument(_ additional: UInt8) throws -> UInt64 {
            if additional < 24 { return UInt64(additional) }
            let width: Int
            switch additional {
            case 24: width = 1
            case 25: width = 2
            case 26: width = 4
            case 27: width = 8
            default: throw GuestJournalFailure("Unsupported or indefinite CBOR argument")
            }
            guard width <= bytes.count - offset else { throw GuestJournalFailure("Truncated CBOR argument") }
            var value: UInt64 = 0
            for _ in 0..<width { value = (value << 8) | UInt64(bytes[offset]); offset += 1 }
            let minimum: UInt64 = width == 1 ? 24 : width == 2 ? 256 : width == 4 ? 65_536 : 4_294_967_296
            guard value >= minimum else { throw GuestJournalFailure("Nonminimal CBOR argument") }
            return value
        }
        mutating func take(depth: Int) throws -> GuestCBORValue {
            guard depth <= maximumDepth, nodes < maximumNodes, offset < bytes.count else {
                throw GuestJournalFailure("CBOR nesting, node or input bound")
            }
            nodes += 1
            let initial = bytes[offset]
            offset += 1
            if initial == 0xf4 { return .bool(false) }
            if initial == 0xf5 { return .bool(true) }
            let major = initial >> 5
            guard major <= 5, major != 1 else { throw GuestJournalFailure("Unsupported CBOR type") }
            let count = try argument(initial & 31)
            switch major {
            case 0: return .unsigned(count)
            case 2, 3:
                guard count <= UInt64(bytes.count - offset) else { throw GuestJournalFailure("Truncated CBOR bytes") }
                let data = Data(bytes[offset..<(offset + Int(count))])
                offset += Int(count)
                if major == 2 { return .bytes(data) }
                guard let text = String(data: data, encoding: .utf8) else { throw GuestJournalFailure("Invalid CBOR UTF-8") }
                return .text(text)
            case 4:
                guard count <= UInt64(maximumCollectionCount) else { throw GuestJournalFailure("CBOR array bound") }
                var result: [GuestCBORValue] = []
                for _ in 0..<Int(count) { result.append(try take(depth: depth + 1)) }
                return .array(result)
            case 5:
                guard count <= UInt64(maximumCollectionCount) else { throw GuestJournalFailure("CBOR map bound") }
                var result: [String: GuestCBORValue] = [:]
                var previous: Data?
                for _ in 0..<Int(count) {
                    let keyStart = offset
                    guard case .text(let key) = try take(depth: depth + 1) else {
                        throw GuestJournalFailure("CBOR map key must be text")
                    }
                    let encodedKey = Data(bytes[keyStart..<offset])
                    if let previous, !previous.lexicographicallyPrecedes(encodedKey) {
                        throw GuestJournalFailure("CBOR map keys duplicate or out of order")
                    }
                    guard result[key] == nil else { throw GuestJournalFailure("Duplicate CBOR String key") }
                    previous = encodedKey
                    result[key] = try take(depth: depth + 1)
                }
                return .map(result)
            default: throw GuestJournalFailure("Unsupported CBOR major type")
            }
        }
    }
}

struct GuestJournalEvent: Equatable, Sendable {
    let runID: String
    let sequence: Int
    let kind: String
    // Full canonical event CBOR, including its schema, ancestry and payload map.
    let payload: Data
    let digest: String
    let parent: String?
}

// Host-owned development journal. No guest/VM calls or independent CBOR file
// writes. SQLite's WAL/SHM/recovery files belong with this database; use SQLite
// backup rather than copying the main file alone while it is open.
//
// Private-directory and named-vnode checks bracket operations. SQLite's system
// VFS still opens named paths, not our held descriptors: this is not an atomic
// descriptor-rooted VFS, ancestor watch, or protection from the same-user host.
final class GuestJournal: @unchecked Sendable {
    static let schema = "ergentics.guest-journal.event.v1"
    static let maximumEventsPerRun = 4_096
    static let maximumReplayBytes = 64 * 1_048_576

    private let url: URL
    private let parentPath: String
    private let filename: String
    private let retentionGrant: GuestSupervisorRetentionGrant?
    private let owner = DispatchQueue(label: "com.ergentics.provenance.guest-journal")
    private var database: OpaquePointer?
    private var directoryFD: Int32 = -1
    private var identityFD: Int32 = -1
    private var requiresReopen = false

    private static let tableSQL = """
        CREATE TABLE events (
          run_id TEXT NOT NULL,
          sequence INTEGER NOT NULL CHECK(sequence >= 0 AND sequence < 4096),
          kind TEXT NOT NULL,
          cbor BLOB NOT NULL CHECK(length(cbor) > 0 AND length(cbor) <= 1048576),
          digest TEXT NOT NULL UNIQUE CHECK(length(digest) = 64),
          parent TEXT REFERENCES events(digest),
          PRIMARY KEY(run_id, sequence),
          CHECK((sequence = 0 AND parent IS NULL) OR (sequence > 0 AND parent IS NOT NULL))
        )
        """
    private static let updateSQL = """
        CREATE TRIGGER immutable_events_update BEFORE UPDATE ON events
        BEGIN SELECT RAISE(ABORT, 'journal events are immutable'); END
        """
    private static let deleteSQL = """
        CREATE TRIGGER immutable_events_delete BEFORE DELETE ON events
        BEGIN SELECT RAISE(ABORT, 'journal events are immutable'); END
        """
    private struct SchemaEntry: Hashable {
        let type: String
        let name: String
        let table: String
        let rootPage: Int64
        let sql: String?
    }
    private static let exactSchemaCatalog: Set<SchemaEntry> = [
        SchemaEntry(type: "table", name: "events", table: "events", rootPage: 2, sql: tableSQL),
        SchemaEntry(type: "index", name: "sqlite_autoindex_events_1", table: "events", rootPage: 3, sql: nil),
        SchemaEntry(type: "index", name: "sqlite_autoindex_events_2", table: "events", rootPage: 4, sql: nil),
        SchemaEntry(type: "trigger", name: "immutable_events_update", table: "events", rootPage: 0, sql: updateSQL),
        SchemaEntry(type: "trigger", name: "immutable_events_delete", table: "events", rootPage: 0, sql: deleteSQL),
    ]

    #if EPR_GUEST_JOURNAL_TESTS
    /// Hostless fixture seam. This initializer is absent from the app binary.
    convenience init(url: URL) throws {
        try self.init(url: url, retentionGrant: nil)
    }
    #endif

    convenience init(retentionGrant: GuestSupervisorRetentionGrant) throws {
        guard retentionGrant.isDescriptorBound else {
            throw GuestJournalFailure("Production journal requires a descriptor-bound retention grant")
        }
        try self.init(url: retentionGrant.journalURL, retentionGrant: retentionGrant)
    }

    private init(url: URL, retentionGrant: GuestSupervisorRetentionGrant?) throws {
        let path = url.path
        guard url.isFileURL, path.hasPrefix("/"), !path.utf8.contains(0),
              !path.contains("//"), !path.split(separator: "/").contains(where: { $0 == "." || $0 == ".." }),
              !url.lastPathComponent.isEmpty, url.lastPathComponent != ".",
              url.lastPathComponent != "..", !url.hasDirectoryPath else {
            throw GuestJournalFailure("Journal must name an absolute, unaliased file path")
        }
        self.url = url
        self.parentPath = url.deletingLastPathComponent().path
        self.filename = url.lastPathComponent
        self.retentionGrant = retentionGrant
        do {
            try openPrivateFiles()
            try owner.sync { try openDatabase() }
        } catch {
            releaseResources()
            throw error
        }
    }

    deinit { owner.sync { releaseResources() } }

    func append(runID: String, kind: String, payload: [String: GuestCBORValue]) throws -> GuestJournalEvent {
        try Self.validateIdentifier(runID, maximum: 128)
        try Self.validateIdentifier(kind, maximum: 64)
        return try owner.sync {
            try usable()
            try validatePaths()
            try execute("BEGIN IMMEDIATE")
            var commitEntered = false
            var committed = false
            do {
                try validateSchema()
                let previous = try loadEvents(runID: runID)
                guard previous.count < Self.maximumEventsPerRun else {
                    throw GuestJournalFailure("Run reached the journal event bound")
                }
                let sequence = previous.count
                let parent = previous.last?.digest
                let value: GuestCBORValue = .map([
                    "schema": .text(Self.schema), "run_id": .text(runID),
                    "sequence": .unsigned(UInt64(sequence)), "kind": .text(kind),
                    "parent": .bytes(parent.map(Self.digestBytes) ?? Data()),
                    "payload": .map(payload),
                ])
                let bytes = try GuestCBOR.encode(value)
                guard previous.reduce(0, { $0 + $1.payload.count }) <= Self.maximumReplayBytes - bytes.count else {
                    throw GuestJournalFailure("Run reached the journal replay byte bound")
                }
                guard try GuestCBOR.decode(bytes) == value else {
                    throw GuestJournalFailure("Independent CBOR reconstruction mismatch")
                }
                let event = GuestJournalEvent(runID: runID, sequence: sequence, kind: kind,
                    payload: bytes, digest: Self.hash(bytes), parent: parent)
                let statement = try prepare("INSERT INTO events(run_id,sequence,kind,cbor,digest,parent) VALUES(?,?,?,?,?,?)")
                do {
                    defer { sqlite3_finalize(statement) }
                    try bind(runID, at: 1, to: statement)
                    try checked(sqlite3_bind_int64(statement, 2, Int64(sequence)), "bind sequence")
                    try bind(kind, at: 3, to: statement)
                    try bind(bytes, at: 4, to: statement)
                    try bind(event.digest, at: 5, to: statement)
                    if let parent { try bind(parent, at: 6, to: statement) }
                    else { try checked(sqlite3_bind_null(statement, 6), "bind parent") }
                    guard sqlite3_step(statement) == SQLITE_DONE else { throw sqlFailure("insert event") }
                    guard sqlite3_changes(database) == 1 else { throw GuestJournalFailure("Insert did not add exactly one event") }
                }
                // Read SQLite's actual stored bytes/projection before committing.
                let tail = try prepare("SELECT run_id,sequence,kind,cbor,digest,parent FROM events WHERE run_id=? ORDER BY sequence DESC LIMIT 1")
                do {
                    defer { sqlite3_finalize(tail) }
                    try bind(runID, at: 1, to: tail)
                    guard sqlite3_step(tail) == SQLITE_ROW, try Self.storedEvent(tail) == event,
                          sqlite3_step(tail) == SQLITE_DONE else {
                        throw GuestJournalFailure("Inserted event readback mismatch")
                    }
                }
                try validatePaths()
                commitEntered = true
                try execute("COMMIT")
                committed = true
                try validatePaths()
                return event
            } catch {
                if !committed, sqlite3_get_autocommit(database) == 0 {
                    do { try execute("ROLLBACK") }
                    catch { requiresReopen = true }
                }
                if commitEntered {
                    requiresReopen = true
                    throw GuestJournalFailure("Journal commit/readback outcome requires reopen inspection; guest outcome is unchanged: \(error)")
                }
                throw error
            }
        }
    }

    func events(runID: String) throws -> [GuestJournalEvent] {
        try Self.validateIdentifier(runID, maximum: 128)
        return try owner.sync { try readTransaction { try loadEvents(runID: runID) } }
    }

    // UI recency only; row insertion order is not an external timestamp proof.
    // Reading a run ID does not validate its events: call events(runID:) next.
    func runIDs() throws -> [String] {
        try owner.sync {
            try readTransaction {
                let statement = try prepare("SELECT run_id,MAX(rowid) FROM events GROUP BY run_id ORDER BY MAX(rowid) DESC,run_id COLLATE BINARY ASC LIMIT 20")
                defer { sqlite3_finalize(statement) }
                var result: [String] = []
                while true {
                    let status = sqlite3_step(statement)
                    if status == SQLITE_DONE { break }
                    guard status == SQLITE_ROW else { throw sqlFailure("list journal runs") }
                    let id = try Self.text(statement, column: 0, maximum: 128)
                    try Self.validateIdentifier(id, maximum: 128)
                    result.append(id)
                }
                return result
            }
        }
    }

    private func readTransaction<T>(_ body: () throws -> T) throws -> T {
        try usable()
        try validatePaths()
        try execute("BEGIN")
        do {
            try validateSchema()
            let value = try body()
            try execute("COMMIT")
            try validatePaths()
            return value
        } catch {
            if sqlite3_get_autocommit(database) == 0 {
                do { try execute("ROLLBACK") } catch { requiresReopen = true }
            }
            throw error
        }
    }

    private func loadEvents(runID: String) throws -> [GuestJournalEvent] {
        let statement = try prepare("SELECT run_id,sequence,kind,cbor,digest,parent FROM events WHERE run_id=? ORDER BY sequence ASC")
        defer { sqlite3_finalize(statement) }
        try bind(runID, at: 1, to: statement)
        var events: [GuestJournalEvent] = []
        var byteCount = 0
        while true {
            let status = sqlite3_step(statement)
            if status == SQLITE_DONE { break }
            guard status == SQLITE_ROW else { throw sqlFailure("read journal run") }
            guard events.count < Self.maximumEventsPerRun else { throw GuestJournalFailure("Journal run event bound") }
            let event = try Self.storedEvent(statement)
            guard Self.exact(event.runID, runID), event.sequence == events.count,
                  event.parent == events.last?.digest,
                  event.payload.count <= Self.maximumReplayBytes - byteCount else {
                throw GuestJournalFailure("Journal projection, ancestry or replay bound mismatch")
            }
            byteCount += event.payload.count
            events.append(event)
        }
        return events
    }

    private static func storedEvent(_ statement: OpaquePointer) throws -> GuestJournalEvent {
        let runID = try text(statement, column: 0, maximum: 128)
        let kind = try text(statement, column: 2, maximum: 64)
        let digest = try text(statement, column: 4, maximum: 64)
        let parent: String?
        if sqlite3_column_type(statement, 5) == SQLITE_NULL { parent = nil }
        else { parent = try text(statement, column: 5, maximum: 64) }
        try Self.validateIdentifier(runID, maximum: 128)
        try Self.validateIdentifier(kind, maximum: 64)
        guard sqlite3_column_type(statement, 1) == SQLITE_INTEGER,
              sqlite3_column_type(statement, 3) == SQLITE_BLOB,
              Self.validDigest(digest), parent.map(Self.validDigest) ?? true else {
            throw GuestJournalFailure("Journal SQL projection types or digest are invalid")
        }
        let sequence = sqlite3_column_int64(statement, 1)
        let count = Int(sqlite3_column_bytes(statement, 3))
        guard sequence >= 0, sequence < Int64(Self.maximumEventsPerRun), count > 0,
              count <= GuestCBOR.maximumBytes, let pointer = sqlite3_column_blob(statement, 3) else {
            throw GuestJournalFailure("Journal row bounds are invalid")
        }
        let bytes = Data(bytes: pointer, count: count)
        guard Self.hash(bytes) == digest, case .map(let object) = try GuestCBOR.decode(bytes),
              Set(object.keys) == Set(["schema", "run_id", "sequence", "kind", "parent", "payload"]),
              object["schema"] == .text(Self.schema),
              case .text(let decodedRun)? = object["run_id"], Self.exact(decodedRun, runID),
              case .text(let decodedKind)? = object["kind"], Self.exact(decodedKind, kind),
              object["sequence"] == .unsigned(UInt64(sequence)),
              object["parent"] == .bytes(parent.map(Self.digestBytes) ?? Data()),
              case .map(_)? = object["payload"] else {
            throw GuestJournalFailure("Journal hash, independent CBOR or full projection mismatch")
        }
        return GuestJournalEvent(runID: runID, sequence: Int(sequence), kind: kind,
            payload: bytes, digest: digest, parent: parent)
    }

    private func openPrivateFiles() throws {
        // Foundation URL resolution can deliberately preserve /var or shorten
        // /private/tmp to /tmp. SQLite NOFOLLOW requires the physical parent,
        // so use POSIX realpath for admission, without silently retargeting it.
        guard let resolved = realpath(parentPath, nil) else {
            throw posixFailure("resolve physical journal parent")
        }
        let physicalParent = String(validatingCString: resolved)
        free(resolved)
        guard let physicalParent, Self.exact(physicalParent, parentPath) else {
            throw GuestJournalFailure("Journal parent must use its physical POSIX realpath, not an ancestor alias")
        }
        var named = stat()
        guard lstat(parentPath, &named) == 0 else { throw posixFailure("read private journal parent") }
        directoryFD = open(parentPath, O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC)
        guard directoryFD >= 0 else { throw posixFailure("open private journal parent") }
        var held = stat()
        guard fstat(directoryFD, &held) == 0 else { throw posixFailure("stat private journal parent") }
        try Self.privateDirectory(held)
        guard held.st_dev == named.st_dev, held.st_ino == named.st_ino,
              named.st_mode & S_IFMT == S_IFDIR else { throw GuestJournalFailure("Journal parent changed or is a symlink") }
        try retentionGrant?.revalidate(openedParentFD: directoryFD)
        try validateSidecars()
        identityFD = openat(directoryFD, filename, O_RDONLY | O_NOFOLLOW | O_NONBLOCK | O_CLOEXEC)
        if identityFD < 0, errno == ENOENT {
            identityFD = openat(directoryFD, filename,
                O_RDWR | O_CREAT | O_EXCL | O_NOFOLLOW | O_NONBLOCK | O_CLOEXEC, mode_t(0o600))
        }
        guard identityFD >= 0 else { throw posixFailure("open exclusive or existing journal file") }
        var file = stat()
        guard fstat(identityFD, &file) == 0 else { throw posixFailure("stat journal file") }
        try Self.privateFile(file)
        let flags = fcntl(identityFD, F_GETFL)
        guard flags >= 0, fcntl(identityFD, F_SETFL, flags & ~O_NONBLOCK) == 0 else {
            throw posixFailure("finish regular-file journal admission")
        }
        try validatePaths()
    }

    private func openDatabase() throws {
        let flags = SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX | SQLITE_OPEN_NOFOLLOW
        try checked(sqlite3_open_v2(url.path, &database, flags, nil), "open SQLite journal")
        try checked(sqlite3_extended_result_codes(database, 1), "enable extended SQLite errors")
        try checked(sqlite3_busy_timeout(database, 2_000), "bound SQLite busy wait")
        sqlite3_limit(database, SQLITE_LIMIT_LENGTH, Int32(GuestCBOR.maximumBytes * 2))
        sqlite3_limit(database, SQLITE_LIMIT_SQL_LENGTH, 65_536)
        // Inspect schema before changing the journal mode of an existing file.
        let version = try scalarInteger("PRAGMA user_version")
        if version == 1 { try validateSchema() }
        else {
            guard version == 0,
                  try scalarInteger("SELECT count(*) FROM sqlite_schema") == 0 else {
                throw GuestJournalFailure("Refusing an unrelated or unsupported existing database")
            }
        }
        try execute("PRAGMA foreign_keys=ON")
        try execute("PRAGMA trusted_schema=OFF")
        try execute("PRAGMA temp_store=MEMORY")
        try execute("PRAGMA synchronous=FULL")
        try execute("PRAGMA fullfsync=ON")
        guard try scalarText("PRAGMA journal_mode=WAL") == "wal",
              try scalarInteger("PRAGMA synchronous") == 2,
              try scalarInteger("PRAGMA fullfsync") == 1,
              try scalarInteger("PRAGMA foreign_keys") == 1,
              try scalarInteger("PRAGMA trusted_schema") == 0,
              try scalarInteger("PRAGMA temp_store") == 2 else {
            throw GuestJournalFailure("SQLite durability or schema policy readback mismatch")
        }
        let persistenceStatus = epr_sqlite_disable_persistent_wal(UnsafeMutableRawPointer(database))
        guard persistenceStatus == SQLITE_OK else {
            throw sqlFailure("disable persistent SQLite WAL", status: persistenceStatus)
        }
        if version == 0 {
            try execute("BEGIN IMMEDIATE")
            do {
                guard try scalarInteger("SELECT count(*) FROM sqlite_schema") == 0 else {
                    throw GuestJournalFailure("Refusing to adopt an unrelated unversioned database")
                }
                try execute(Self.tableSQL)
                try execute(Self.updateSQL)
                try execute(Self.deleteSQL)
                try execute("PRAGMA user_version=1")
                try execute("COMMIT")
            } catch {
                if sqlite3_get_autocommit(database) == 0 { try? execute("ROLLBACK") }
                throw error
            }
        } else if version != 1 {
            throw GuestJournalFailure("Unsupported journal schema version")
        }
        try validateSchema()
        try validatePaths()
    }

    private func validateSchema() throws {
        guard try scalarInteger("PRAGMA user_version") == 1 else { throw GuestJournalFailure("Journal version changed") }
        let statement = try prepare("SELECT type,name,tbl_name,rootpage,sql FROM sqlite_schema LIMIT 6")
        defer { sqlite3_finalize(statement) }
        var seen = Set<SchemaEntry>()
        while true {
            let status = sqlite3_step(statement)
            if status == SQLITE_DONE { break }
            guard status == SQLITE_ROW else { throw sqlFailure("read journal schema") }
            let entry = try Self.schemaEntry(statement)
            guard seen.count < Self.exactSchemaCatalog.count,
                  seen.insert(entry).inserted else {
                throw GuestJournalFailure("Journal schema or immutability triggers changed")
            }
        }
        guard seen == Self.exactSchemaCatalog else { throw GuestJournalFailure("Journal schema is incomplete") }
    }

    private static func schemaEntry(_ statement: OpaquePointer) throws -> SchemaEntry {
        guard sqlite3_column_type(statement, 3) == SQLITE_INTEGER else {
            throw GuestJournalFailure("Journal schema rootpage type mismatch")
        }
        let sql: String?
        if sqlite3_column_type(statement, 4) == SQLITE_NULL { sql = nil }
        else {
            sql = try Self.text(statement, column: 4, maximum: 8_192)
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return SchemaEntry(type: try Self.text(statement, column: 0, maximum: 32),
            name: try Self.text(statement, column: 1, maximum: 128),
            table: try Self.text(statement, column: 2, maximum: 128),
            rootPage: sqlite3_column_int64(statement, 3), sql: sql)
    }

    private func validatePaths() throws {
        var heldParent = stat(), namedParent = stat(), heldFile = stat(), namedFile = stat()
        guard fstat(directoryFD, &heldParent) == 0, lstat(parentPath, &namedParent) == 0,
              fstat(identityFD, &heldFile) == 0,
              fstatat(directoryFD, filename, &namedFile, AT_SYMLINK_NOFOLLOW) == 0 else {
            throw posixFailure("revalidate journal path")
        }
        try Self.privateDirectory(heldParent)
        try Self.privateDirectory(namedParent)
        try Self.privateFile(heldFile)
        try Self.privateFile(namedFile)
        guard heldParent.st_dev == namedParent.st_dev, heldParent.st_ino == namedParent.st_ino,
              heldFile.st_dev == namedFile.st_dev, heldFile.st_ino == namedFile.st_ino else {
            throw GuestJournalFailure("Journal parent or file was replaced")
        }
        try retentionGrant?.revalidate(openedParentFD: directoryFD)
        try validateSidecars()
    }

    private func validateSidecars() throws {
        for suffix in ["-wal", "-shm", "-journal"] {
            var metadata = stat()
            if fstatat(directoryFD, filename + suffix, &metadata, AT_SYMLINK_NOFOLLOW) != 0 {
                if errno == ENOENT { continue }
                throw posixFailure("inspect journal sidecar")
            }
            try Self.privateFile(metadata)
        }
    }

    private static func privateDirectory(_ value: stat) throws {
        guard value.st_mode & S_IFMT == S_IFDIR, value.st_mode & 0o7777 == 0o700,
              value.st_uid == geteuid() else { throw GuestJournalFailure("Journal parent must be self-owned mode 0700") }
    }
    private static func privateFile(_ value: stat) throws {
        guard value.st_mode & S_IFMT == S_IFREG, value.st_mode & 0o7777 == 0o600,
              value.st_uid == geteuid(), value.st_nlink == 1 else {
            throw GuestJournalFailure("Journal files must be unaliased, self-owned regular mode 0600")
        }
    }
    private func usable() throws {
        guard database != nil, !requiresReopen else { throw GuestJournalFailure("Journal needs close/reopen and inspection") }
    }
    private func releaseResources() {
        if let database { sqlite3_close_v2(database); self.database = nil }
        if identityFD >= 0 { close(identityFD); identityFD = -1 }
        if directoryFD >= 0 { close(directoryFD); directoryFD = -1 }
    }
    private func execute(_ sql: String) throws {
        try checked(sqlite3_exec(database, sql, nil, nil, nil), "execute journal SQL")
    }
    private func prepare(_ sql: String) throws -> OpaquePointer {
        var statement: OpaquePointer?
        try checked(sqlite3_prepare_v2(database, sql, -1, &statement, nil), "prepare journal SQL")
        guard let statement else { throw GuestJournalFailure("SQLite returned no prepared statement") }
        return statement
    }
    private func scalarInteger(_ sql: String) throws -> Int64 {
        let statement = try prepare(sql)
        defer { sqlite3_finalize(statement) }
        guard sqlite3_step(statement) == SQLITE_ROW, sqlite3_column_type(statement, 0) == SQLITE_INTEGER else {
            throw sqlFailure("read integer policy")
        }
        let value = sqlite3_column_int64(statement, 0)
        guard sqlite3_step(statement) == SQLITE_DONE else { throw sqlFailure("finish integer policy") }
        return value
    }
    private func scalarText(_ sql: String) throws -> String {
        let statement = try prepare(sql)
        defer { sqlite3_finalize(statement) }
        guard sqlite3_step(statement) == SQLITE_ROW else { throw sqlFailure("read text policy") }
        let value = try Self.text(statement, column: 0, maximum: 128)
        guard sqlite3_step(statement) == SQLITE_DONE else { throw sqlFailure("finish text policy") }
        return value
    }
    private static func text(_ statement: OpaquePointer, column: Int32, maximum: Int) throws -> String {
        guard sqlite3_column_type(statement, column) == SQLITE_TEXT else { throw GuestJournalFailure("SQL text type mismatch") }
        let count = Int(sqlite3_column_bytes(statement, column))
        guard count > 0, count <= maximum, let pointer = sqlite3_column_text(statement, column),
              let text = String(data: Data(bytes: pointer, count: count), encoding: .utf8),
              !text.utf8.contains(0) else { throw GuestJournalFailure("SQL text encoding or bound mismatch") }
        return text
    }
    private var transient: sqlite3_destructor_type { unsafeBitCast(-1, to: sqlite3_destructor_type.self) }
    private func bind(_ value: String, at index: Int32, to statement: OpaquePointer) throws {
        let count = value.utf8.count
        guard count <= 8_192 else { throw GuestJournalFailure("SQL text bind bound") }
        try value.withCString { pointer in
            try checked(sqlite3_bind_text(statement, index, pointer, Int32(count), transient), "bind text")
        }
    }
    private func bind(_ value: Data, at index: Int32, to statement: OpaquePointer) throws {
        guard value.count <= GuestCBOR.maximumBytes else { throw GuestJournalFailure("SQL byte bind bound") }
        try value.withUnsafeBytes { bytes in
            try checked(sqlite3_bind_blob(statement, index, bytes.baseAddress, Int32(bytes.count), transient), "bind CBOR bytes")
        }
    }
    private func checked(_ status: Int32, _ context: String) throws {
        guard status == SQLITE_OK else { throw sqlFailure(context, status: status) }
    }
    private func sqlFailure(_ context: String, status: Int32? = nil) -> GuestJournalFailure {
        let code = status ?? sqlite3_extended_errcode(database)
        let extended = sqlite3_extended_errcode(database)
        let system = sqlite3_system_errno(database)
        let detail = database.flatMap { sqlite3_errmsg($0) }.map { String(cString: $0) } ?? "no connection"
        return GuestJournalFailure("\(context): SQLite \(code), extended \(extended), system errno \(system): \(detail)")
    }
    private func posixFailure(_ context: String) -> GuestJournalFailure {
        GuestJournalFailure("\(context): errno \(errno)")
    }
    private static func validateIdentifier(_ value: String, maximum: Int) throws {
        guard !value.isEmpty, value.utf8.count <= maximum, !value.utf8.contains(0) else {
            throw GuestJournalFailure("Journal identifier is empty, oversized or contains NUL")
        }
    }
    private static func exact(_ left: String, _ right: String) -> Bool { left.utf8.elementsEqual(right.utf8) }
    private static func hash(_ bytes: Data) -> String { SHA256.hash(data: bytes).map { String(format: "%02x", $0) }.joined() }
    private static func validDigest(_ value: String) -> Bool {
        value.utf8.count == 64 && value.utf8.allSatisfy { (48...57).contains($0) || (97...102).contains($0) }
    }
    private static func digestBytes(_ value: String) -> Data {
        let bytes = Array(value.utf8)
        func nibble(_ byte: UInt8) -> UInt8 { byte <= 57 ? byte - 48 : byte - 87 }
        return Data(stride(from: 0, to: bytes.count, by: 2).map { nibble(bytes[$0]) * 16 + nibble(bytes[$0 + 1]) })
    }
}

/// A bounded reconstruction from one descriptor-held main-database snapshot.
/// The digest always covers the original on-disk bytes; the private SQLite
/// buffer alone receives the WAL-header normalization needed by deserialize.
struct GuestJournalReadOnlySnapshot: Sendable {
    let runs: [GuestSupervisorRetainedRun]
    let journalSHA256: String
}

private final class GuestSQLiteWorkBudget {
    var remainingCallbacks = 50_000
}

private let guestSQLiteProgress: @convention(c) (UnsafeMutableRawPointer?) -> Int32 = { context in
    guard let context else { return 1 }
    let budget = Unmanaged<GuestSQLiteWorkBudget>.fromOpaque(context).takeUnretainedValue()
    guard budget.remainingCallbacks > 0 else { return 1 }
    budget.remainingCallbacks -= 1
    return 0
}

extension GuestJournal {
    private static let readOnlyMaximumDatabaseBytes = 128 * 1_048_576
    private static let readOnlyMaximumEvents = 60
    private static let readOnlyMaximumEventsPerRun = 3
    private static let readOnlyMaximumAggregateCBORBytes = 60 * 1_048_576

    /// No pathname reaches SQLite. The caller must have completed the stable,
    /// descriptor-held, sidecar-free snapshot and vnode rebound first.
    static func reconstructReadOnlySnapshot(databaseBytes: Data) throws -> GuestJournalReadOnlySnapshot {
        let header = Data("SQLite format 3\0".utf8)
        guard databaseBytes.count >= 100,
              databaseBytes.count <= readOnlyMaximumDatabaseBytes,
              databaseBytes.prefix(header.count) == header,
              databaseBytes[databaseBytes.startIndex + 18] == 2,
              databaseBytes[databaseBytes.startIndex + 19] == 2 else {
            throw GuestJournalFailure("Read-only journal snapshot is not an exact bounded WAL main database")
        }
        let originalDigest = Self.hash(databaseBytes)
        var database: OpaquePointer?
        let openFlags = SQLITE_OPEN_READONLY | SQLITE_OPEN_MEMORY |
            SQLITE_OPEN_FULLMUTEX | SQLITE_OPEN_PRIVATECACHE
        let openStatus = sqlite3_open_v2(":memory:", &database, openFlags, nil)
        guard openStatus == SQLITE_OK, let database else {
            if let database { sqlite3_close_v2(database) }
            throw GuestJournalFailure("Private SQLite reconstruction open failed (\(openStatus))")
        }
        defer { sqlite3_close_v2(database) }
        guard sqlite3_extended_result_codes(database, 1) == SQLITE_OK,
              sqlite3_busy_timeout(database, 0) == SQLITE_OK else {
            throw readOnlySQLFailure(database, "configure private SQLite reconstruction")
        }

        guard let allocation = sqlite3_malloc64(UInt64(databaseBytes.count)) else {
            throw GuestJournalFailure("Private SQLite reconstruction allocation failed")
        }
        let allocationBytes = allocation.assumingMemoryBound(to: UInt8.self)
        databaseBytes.copyBytes(to: allocationBytes, count: databaseBytes.count)
        // Normalize only SQLite's private allocation. The held evidence bytes
        // and their digest remain untouched and therefore independently joined.
        allocationBytes[18] = 1
        allocationBytes[19] = 1
        // The fixed C bridge always consumes the buffer and hardcodes main,
        // N == M, FREEONCLOSE and READONLY. Never free after this invocation.
        let deserializeStatus = epr_sqlite_deserialize_readonly(
            UnsafeMutableRawPointer(database), allocationBytes, Int64(databaseBytes.count))
        guard deserializeStatus == SQLITE_OK else {
            throw readOnlySQLFailure(database, "deserialize private journal", status: deserializeStatus)
        }

        let budget = Unmanaged.passRetained(GuestSQLiteWorkBudget())
        sqlite3_progress_handler(database, 1_000, guestSQLiteProgress,
            budget.toOpaque())
        defer {
            sqlite3_progress_handler(database, 0, nil, nil)
            budget.release()
        }
        try installReadOnlyLimits(database)
        var policy = EPRSQLiteReadOnlyPolicy()
        let policyStatus = epr_sqlite_harden_readonly(UnsafeMutableRawPointer(database), &policy)
        guard policyStatus == SQLITE_OK, policy.defensive == 1,
              policy.trusted_schema == 0, policy.dqs_ddl == 0, policy.dqs_dml == 0 else {
            throw readOnlySQLFailure(database, "harden private SQLite policy", status: policyStatus)
        }
        try readOnlyExecute(database, "PRAGMA query_only=ON")
        try readOnlyExecute(database, "PRAGMA trusted_schema=OFF")
        try readOnlyExecute(database, "PRAGMA temp_store=MEMORY")
        try readOnlyExecute(database, "PRAGMA foreign_keys=ON")
        try readOnlyExecute(database, "PRAGMA cell_size_check=ON")
        guard try readOnlyInteger(database, "PRAGMA main.user_version") == 1,
              try readOnlyInteger(database, "PRAGMA query_only") == 1,
              try readOnlyInteger(database, "PRAGMA trusted_schema") == 0,
              try readOnlyInteger(database, "PRAGMA temp_store") == 2,
              try readOnlyInteger(database, "PRAGMA foreign_keys") == 1,
              try readOnlyInteger(database, "PRAGMA cell_size_check") == 1 else {
            throw GuestJournalFailure("Private SQLite policy readback mismatch")
        }

        try validateReadOnlySchema(database)
        guard try readOnlyText(database, "PRAGMA main.integrity_check(1)") == "ok" else {
            throw GuestJournalFailure("Private SQLite integrity check failed")
        }
        guard epr_sqlite_install_readonly_authorizer(UnsafeMutableRawPointer(database)) == SQLITE_OK else {
            throw readOnlySQLFailure(database, "install private SQLite authorizer")
        }

        let rows = try readOnlyEvents(database)
        return GuestJournalReadOnlySnapshot(runs: rows, journalSHA256: originalDigest)
    }

    private static func installReadOnlyLimits(_ database: OpaquePointer) throws {
        let limits: [(Int32, Int32)] = [
            (SQLITE_LIMIT_LENGTH, Int32(GuestCBOR.maximumBytes * 2)),
            (SQLITE_LIMIT_SQL_LENGTH, 65_536),
            (SQLITE_LIMIT_COLUMN, 64), (SQLITE_LIMIT_EXPR_DEPTH, 32),
            (SQLITE_LIMIT_COMPOUND_SELECT, 4), (SQLITE_LIMIT_VDBE_OP, 100_000),
            (SQLITE_LIMIT_FUNCTION_ARG, 16), (SQLITE_LIMIT_ATTACHED, 0),
            (SQLITE_LIMIT_TRIGGER_DEPTH, 0), (SQLITE_LIMIT_WORKER_THREADS, 0),
        ]
        for (identifier, requested) in limits {
            guard sqlite3_limit(database, identifier, requested) >= 0,
                  sqlite3_limit(database, identifier, -1) == requested else {
                throw GuestJournalFailure("Private SQLite resource limit readback mismatch")
            }
        }
    }

    private static func validateReadOnlySchema(_ database: OpaquePointer) throws {
        let statement = try readOnlyPrepare(database,
            "SELECT type,name,tbl_name,rootpage,sql FROM main.sqlite_schema LIMIT 6")
        defer { sqlite3_finalize(statement) }
        var observed = Set<SchemaEntry>()
        while true {
            let status = sqlite3_step(statement)
            if status == SQLITE_DONE { break }
            guard status == SQLITE_ROW else { throw readOnlySQLFailure(database, "scan private SQLite schema") }
            let entry = try Self.schemaEntry(statement)
            guard observed.count < Self.exactSchemaCatalog.count,
                  observed.insert(entry).inserted else {
                throw GuestJournalFailure("Private SQLite schema contains duplicate identities")
            }
        }
        guard observed == Self.exactSchemaCatalog else {
            throw GuestJournalFailure("Private SQLite schema is not the frozen journal schema and rootpage topology")
        }
    }

    private static func readOnlyEvents(_ database: OpaquePointer) throws -> [GuestSupervisorRetainedRun] {
        let statement = try readOnlyPrepare(database,
            "SELECT run_id,sequence,kind,cbor,digest,parent,rowid FROM main.events NOT INDEXED LIMIT 61")
        defer { sqlite3_finalize(statement) }
        var grouped: [String: [(event: GuestJournalEvent, rowID: Int64)]] = [:]
        var totalEvents = 0
        var totalBytes = 0
        while true {
            let status = sqlite3_step(statement)
            if status == SQLITE_DONE { break }
            guard status == SQLITE_ROW else { throw readOnlySQLFailure(database, "scan private SQLite events") }
            guard totalEvents < readOnlyMaximumEvents,
                  sqlite3_column_type(statement, 6) == SQLITE_INTEGER else {
                throw GuestJournalFailure("Private SQLite event-count or rowid bound exceeded")
            }
            let event = try Self.storedEvent(statement)
            let rowID = sqlite3_column_int64(statement, 6)
            guard rowID > 0, event.payload.count <= readOnlyMaximumAggregateCBORBytes - totalBytes else {
                throw GuestJournalFailure("Private SQLite rowid or aggregate CBOR bound exceeded")
            }
            totalEvents += 1
            totalBytes += event.payload.count
            grouped[event.runID, default: []].append((event, rowID))
            guard grouped.count <= GuestSupervisorHistoryGrant.maximumRuns,
                  grouped[event.runID]!.count <= readOnlyMaximumEventsPerRun else {
                throw GuestJournalFailure("Private SQLite run or per-run event bound exceeded")
            }
        }

        var reconstructed: [(run: GuestSupervisorRetainedRun, newest: Int64)] = []
        for (runID, values) in grouped {
            let ordered = values.sorted {
                if $0.event.sequence != $1.event.sequence { return $0.event.sequence < $1.event.sequence }
                return $0.rowID < $1.rowID
            }
            guard Set(ordered.map(\.rowID)).count == ordered.count,
                  ordered.enumerated().allSatisfy({ index, value in
                      value.event.sequence == index && value.event.parent == (index == 0 ? nil : ordered[index - 1].event.digest)
                  }) else {
                throw GuestJournalFailure("Private SQLite event ancestry or order mismatch")
            }
            reconstructed.append((GuestSupervisorRetainedRun(runID: runID,
                events: ordered.map(\.event)), ordered.map(\.rowID).max()!))
        }
        reconstructed.sort {
            if $0.newest != $1.newest { return $0.newest > $1.newest }
            return Data($0.run.runID.utf8).lexicographicallyPrecedes(Data($1.run.runID.utf8))
        }
        return reconstructed.map(\.run)
    }

    private static func readOnlyExecute(_ database: OpaquePointer, _ sql: String) throws {
        let statement = try readOnlyPrepare(database, sql)
        defer { sqlite3_finalize(statement) }
        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw readOnlySQLFailure(database, "execute private SQLite policy")
        }
    }

    private static func readOnlyInteger(_ database: OpaquePointer, _ sql: String) throws -> Int64 {
        let statement = try readOnlyPrepare(database, sql)
        defer { sqlite3_finalize(statement) }
        guard sqlite3_step(statement) == SQLITE_ROW,
              sqlite3_column_type(statement, 0) == SQLITE_INTEGER else {
            throw readOnlySQLFailure(database, "read private SQLite integer")
        }
        let value = sqlite3_column_int64(statement, 0)
        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw readOnlySQLFailure(database, "finish private SQLite integer")
        }
        return value
    }

    private static func readOnlyText(_ database: OpaquePointer, _ sql: String) throws -> String {
        let statement = try readOnlyPrepare(database, sql)
        defer { sqlite3_finalize(statement) }
        guard sqlite3_step(statement) == SQLITE_ROW else {
            throw readOnlySQLFailure(database, "read private SQLite text")
        }
        let value = try Self.text(statement, column: 0, maximum: 128)
        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw readOnlySQLFailure(database, "finish private SQLite text")
        }
        return value
    }

    private static func readOnlyPrepare(_ database: OpaquePointer, _ sql: String) throws -> OpaquePointer {
        var statement: OpaquePointer?
        let flags = UInt32(SQLITE_PREPARE_NO_VTAB | SQLITE_PREPARE_DONT_LOG)
        let status = sqlite3_prepare_v3(database, sql, -1, flags, &statement, nil)
        guard status == SQLITE_OK, let statement else {
            throw readOnlySQLFailure(database, "prepare fixed private SQLite query", status: status)
        }
        return statement
    }

    private static func readOnlySQLFailure(_ database: OpaquePointer, _ context: String,
                                           status: Int32? = nil) -> GuestJournalFailure {
        let code = status ?? sqlite3_extended_errcode(database)
        let detail = String(cString: sqlite3_errmsg(database))
        return GuestJournalFailure("\(context): SQLite \(code), extended \(sqlite3_extended_errcode(database)), system errno \(sqlite3_system_errno(database)): \(detail)")
    }
}
