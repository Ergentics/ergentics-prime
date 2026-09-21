import Foundation
import SQLite3

private let sqliteTransient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

final class LedgerSQLiteConnection {
    private(set) var handle: OpaquePointer?

    init(memory: Bool) throws {
        var database: OpaquePointer?
        let path = memory ? ":memory:" : ""
        let flags = SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_FULLMUTEX
        let result = sqlite3_open_v2(path, &database, flags, nil)
        guard result == SQLITE_OK, let database else {
            let message = database.map { String(cString: sqlite3_errmsg($0)) } ?? "no handle"
            if let database { sqlite3_close(database) }
            throw rejection("SQLITE_OPEN", "\(result):\(message)")
        }
        handle = database
        sqlite3_extended_result_codes(database, 1)
        sqlite3_busy_timeout(database, 30_000)
    }

    init(serializedReadOnly data: Data) throws {
        var database: OpaquePointer?
        let result = sqlite3_open_v2(
            ":memory:",
            &database,
            SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_FULLMUTEX,
            nil)
        guard result == SQLITE_OK, let database else {
            let message = database.map { String(cString: sqlite3_errmsg($0)) } ?? "no handle"
            if let database { sqlite3_close(database) }
            throw rejection("SQLITE_DESERIALIZE_OPEN", "\(result):\(message)")
        }
        handle = database
        sqlite3_extended_result_codes(database, 1)
        sqlite3_busy_timeout(database, 5_000)
        guard let allocation = sqlite3_malloc64(sqlite3_uint64(data.count)) else {
            throw rejection("SQLITE_DESERIALIZE_ALLOCATION")
        }
        data.withUnsafeBytes { source in
            if let base = source.baseAddress { memcpy(allocation, base, source.count) }
        }
        let deserialize = sqlite3_deserialize(
            database,
            "main",
            allocation.assumingMemoryBound(to: UInt8.self),
            sqlite3_int64(data.count),
            sqlite3_int64(data.count),
            UInt32(SQLITE_DESERIALIZE_FREEONCLOSE | SQLITE_DESERIALIZE_READONLY))
        guard deserialize == SQLITE_OK else {
            sqlite3_free(allocation)
            throw rejection("SQLITE_DESERIALIZE", "result=\(deserialize)")
        }
        try execute("PRAGMA query_only=ON")
        try execute("PRAGMA trusted_schema=OFF")
        try execute("PRAGMA foreign_keys=ON")
    }

    deinit { if let handle { sqlite3_close(handle) } }

    func close() throws {
        guard let handle else { return }
        let result = sqlite3_close(handle)
        guard result == SQLITE_OK else { throw sqliteError("SQLITE_CLOSE", result) }
        self.handle = nil
    }

    func execute(_ sql: String) throws {
        guard let handle else { throw rejection("SQLITE_CLOSED") }
        var errorMessage: UnsafeMutablePointer<CChar>?
        let result = sqlite3_exec(handle, sql, nil, nil, &errorMessage)
        let message = errorMessage.map { String(cString: $0) } ?? String(cString: sqlite3_errmsg(handle))
        if let errorMessage { sqlite3_free(errorMessage) }
        guard result == SQLITE_OK else { throw rejection("SQLITE_EXEC", "\(result):\(message)") }
    }

    func prepare(_ sql: String) throws -> LedgerSQLiteStatement {
        guard let handle else { throw rejection("SQLITE_CLOSED") }
        var statement: OpaquePointer?
        let result = sqlite3_prepare_v2(handle, sql, -1, &statement, nil)
        guard result == SQLITE_OK, let statement else { throw sqliteError("SQLITE_PREPARE", result) }
        return LedgerSQLiteStatement(connection: self, handle: statement)
    }

    func scalarText(_ sql: String) throws -> String {
        let statement = try prepare(sql)
        guard try statement.step() else { throw rejection("SQLITE_SCALAR_TEXT_EMPTY") }
        guard let value = statement.optionalText(0) else { throw rejection("SQLITE_SCALAR_TEXT_NULL") }
        try require(!(try statement.step()), "SQLITE_SCALAR_TEXT_MULTIPLE")
        return value
    }

    func scalarInt(_ sql: String) throws -> Int64 {
        let statement = try prepare(sql)
        guard try statement.step() else { throw rejection("SQLITE_SCALAR_INT_EMPTY") }
        let value = statement.int64(0)
        try require(!(try statement.step()), "SQLITE_SCALAR_INT_MULTIPLE")
        return value
    }

    func serialized() throws -> Data {
        guard let handle else { throw rejection("SQLITE_CLOSED") }
        var count: sqlite3_int64 = 0
        guard let pointer = sqlite3_serialize(handle, "main", &count, 0) else {
            throw sqliteError("SQLITE_SERIALIZE", sqlite3_errcode(handle))
        }
        defer { sqlite3_free(pointer) }
        try require(count > 0 && count <= 64 * 1_024 * 1_024, "SQLITE_SERIALIZED_CAP")
        return Data(bytes: pointer, count: Int(count))
    }

    private func sqliteError(_ code: String, _ result: Int32) -> LedgerProjectionRejection {
        let message = handle.map { String(cString: sqlite3_errmsg($0)) } ?? "closed"
        return rejection(code, "\(result):\(message)")
    }
}

final class LedgerSQLiteStatement {
    private unowned let connection: LedgerSQLiteConnection
    let handle: OpaquePointer

    init(connection: LedgerSQLiteConnection, handle: OpaquePointer) {
        self.connection = connection
        self.handle = handle
    }

    deinit { sqlite3_finalize(handle) }

    func reset() {
        sqlite3_reset(handle)
        sqlite3_clear_bindings(handle)
    }

    func bind(_ index: Int32, text: String?) throws {
        let result: Int32
        if let text {
            result = sqlite3_bind_text(handle, index, text, -1, sqliteTransient)
        } else {
            result = sqlite3_bind_null(handle, index)
        }
        try require(result == SQLITE_OK, "SQLITE_BIND_TEXT", "index=\(index) result=\(result)")
    }

    func bind(_ index: Int32, int: Int) throws {
        try bind(index, int64: Int64(int))
    }

    func bind(_ index: Int32, optionalInt: Int?) throws {
        if let optionalInt {
            try bind(index, int: optionalInt)
        } else {
            let result = sqlite3_bind_null(handle, index)
            try require(result == SQLITE_OK, "SQLITE_BIND_NULL", "index=\(index) result=\(result)")
        }
    }

    func bind(_ index: Int32, int64: Int64) throws {
        let result = sqlite3_bind_int64(handle, index, int64)
        try require(result == SQLITE_OK, "SQLITE_BIND_INT", "index=\(index) result=\(result)")
    }

    func bind(_ index: Int32, data: Data) throws {
        let result = data.withUnsafeBytes { raw in
            sqlite3_bind_blob(handle, index, raw.baseAddress, Int32(raw.count), sqliteTransient)
        }
        try require(result == SQLITE_OK, "SQLITE_BIND_BLOB", "index=\(index) result=\(result)")
    }

    func stepDone() throws {
        let result = sqlite3_step(handle)
        try require(result == SQLITE_DONE, "SQLITE_STEP_DONE", "result=\(result)")
    }

    func step() throws -> Bool {
        let result = sqlite3_step(handle)
        if result == SQLITE_ROW { return true }
        if result == SQLITE_DONE { return false }
        throw rejection("SQLITE_STEP", "result=\(result)")
    }

    func int64(_ index: Int32) -> Int64 { sqlite3_column_int64(handle, index) }

    func optionalText(_ index: Int32) -> String? {
        guard sqlite3_column_type(handle, index) != SQLITE_NULL,
              let text = sqlite3_column_text(handle, index)
        else { return nil }
        return String(cString: text)
    }

    func data(_ index: Int32) -> Data {
        let count = Int(sqlite3_column_bytes(handle, index))
        guard count > 0, let pointer = sqlite3_column_blob(handle, index) else { return Data() }
        return Data(bytes: pointer, count: count)
    }
}
