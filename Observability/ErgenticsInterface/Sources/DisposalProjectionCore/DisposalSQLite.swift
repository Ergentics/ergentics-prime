import Foundation
import SQLite3

private let disposalSQLiteTransient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

enum DisposalSQLiteFailure: Error, Equatable {
    case rejected(String, String)
}

@inline(__always)
func disposalRequire(
    _ condition: @autoclosure () throws -> Bool,
    _ code: String,
    _ detail: String = ""
) throws {
    guard try condition() else { throw DisposalSQLiteFailure.rejected(code, detail) }
}

final class DisposalSQLiteConnection {
    private(set) var handle: OpaquePointer?

    init(memory: Bool = true) throws {
        var database: OpaquePointer?
        let path = memory ? ":memory:" : ""
        let result = sqlite3_open_v2(
            path,
            &database,
            SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_FULLMUTEX,
            nil)
        guard result == SQLITE_OK, let database else {
            let message = database.map { String(cString: sqlite3_errmsg($0)) } ?? "no handle"
            if let database { sqlite3_close(database) }
            throw DisposalSQLiteFailure.rejected("SQLITE_OPEN", "\(result):\(message)")
        }
        handle = database
        sqlite3_extended_result_codes(database, 1)
        sqlite3_busy_timeout(database, 30_000)
    }

    init(serializedReadOnly bytes: Data) throws {
        var database: OpaquePointer?
        let result = sqlite3_open_v2(
            ":memory:",
            &database,
            SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_FULLMUTEX,
            nil)
        guard result == SQLITE_OK, let database else {
            let message = database.map { String(cString: sqlite3_errmsg($0)) } ?? "no handle"
            if let database { sqlite3_close(database) }
            throw DisposalSQLiteFailure.rejected(
                "SQLITE_DESERIALIZE_OPEN", "\(result):\(message)")
        }
        handle = database
        sqlite3_extended_result_codes(database, 1)
        sqlite3_busy_timeout(database, 5_000)
        guard !bytes.isEmpty,
              let rawAllocation = sqlite3_malloc64(sqlite3_uint64(bytes.count))
        else {
            throw DisposalSQLiteFailure.rejected("SQLITE_DESERIALIZE_ALLOCATION", "")
        }
        bytes.withUnsafeBytes { source in
            if let base = source.baseAddress { memcpy(rawAllocation, base, source.count) }
        }
        let deserialize = sqlite3_deserialize(
            database,
            "main",
            rawAllocation.assumingMemoryBound(to: UInt8.self),
            sqlite3_int64(bytes.count),
            sqlite3_int64(bytes.count),
            UInt32(SQLITE_DESERIALIZE_FREEONCLOSE | SQLITE_DESERIALIZE_READONLY))
        guard deserialize == SQLITE_OK else {
            sqlite3_free(rawAllocation)
            throw DisposalSQLiteFailure.rejected(
                "SQLITE_DESERIALIZE", "result=\(deserialize)")
        }
        try execute("PRAGMA query_only=ON")
        try execute("PRAGMA trusted_schema=OFF")
        try execute("PRAGMA foreign_keys=ON")
    }

    deinit {
        if let handle { sqlite3_close_v2(handle) }
    }

    func close() throws {
        guard let handle else { return }
        let result = sqlite3_close_v2(handle)
        guard result == SQLITE_OK else { throw sqliteError("SQLITE_CLOSE", result) }
        self.handle = nil
    }

    func execute(_ sql: String) throws {
        guard let handle else {
            throw DisposalSQLiteFailure.rejected("SQLITE_CLOSED", "")
        }
        var errorMessage: UnsafeMutablePointer<CChar>?
        let result = sqlite3_exec(handle, sql, nil, nil, &errorMessage)
        let message = errorMessage.map { String(cString: $0) }
            ?? String(cString: sqlite3_errmsg(handle))
        if let errorMessage { sqlite3_free(errorMessage) }
        guard result == SQLITE_OK else {
            throw DisposalSQLiteFailure.rejected(
                "SQLITE_EXEC", "\(result):\(message)")
        }
    }

    func prepare(_ sql: String) throws -> DisposalSQLiteStatement {
        guard let handle else {
            throw DisposalSQLiteFailure.rejected("SQLITE_CLOSED", "")
        }
        var statement: OpaquePointer?
        let result = sqlite3_prepare_v2(handle, sql, -1, &statement, nil)
        guard result == SQLITE_OK, let statement else {
            throw sqliteError("SQLITE_PREPARE", result)
        }
        return DisposalSQLiteStatement(connection: self, handle: statement)
    }

    func scalarText(_ sql: String) throws -> String {
        let statement = try prepare(sql)
        guard try statement.step() else {
            throw DisposalSQLiteFailure.rejected("SQLITE_SCALAR_TEXT_EMPTY", "")
        }
        guard let value = statement.optionalText(0) else {
            throw DisposalSQLiteFailure.rejected("SQLITE_SCALAR_TEXT_NULL", "")
        }
        try disposalRequire(!(try statement.step()), "SQLITE_SCALAR_TEXT_MULTIPLE")
        return value
    }

    func scalarInt(_ sql: String) throws -> Int64 {
        let statement = try prepare(sql)
        guard try statement.step() else {
            throw DisposalSQLiteFailure.rejected("SQLITE_SCALAR_INT_EMPTY", "")
        }
        let value = statement.int64(0)
        try disposalRequire(!(try statement.step()), "SQLITE_SCALAR_INT_MULTIPLE")
        return value
    }

    func serialized() throws -> Data {
        guard let handle else {
            throw DisposalSQLiteFailure.rejected("SQLITE_CLOSED", "")
        }
        var count: sqlite3_int64 = 0
        guard let pointer = sqlite3_serialize(handle, "main", &count, 0) else {
            throw sqliteError("SQLITE_SERIALIZE", sqlite3_errcode(handle))
        }
        defer { sqlite3_free(pointer) }
        try disposalRequire(
            count > 0 && count <= 128 * 1_024 * 1_024,
            "SQLITE_SERIALIZED_CAP")
        return Data(bytes: pointer, count: Int(count))
    }

    private func sqliteError(_ code: String, _ result: Int32) -> DisposalSQLiteFailure {
        let message = handle.map { String(cString: sqlite3_errmsg($0)) } ?? "closed"
        return .rejected(code, "\(result):\(message)")
    }
}

final class DisposalSQLiteStatement {
    private unowned let connection: DisposalSQLiteConnection
    let handle: OpaquePointer

    init(connection: DisposalSQLiteConnection, handle: OpaquePointer) {
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
            result = text.utf8CString.withUnsafeBufferPointer { bytes in
                sqlite3_bind_text(
                    handle,
                    index,
                    bytes.baseAddress,
                    Int32(bytes.count - 1),
                    disposalSQLiteTransient)
            }
        } else {
            result = sqlite3_bind_null(handle, index)
        }
        try disposalRequire(
            result == SQLITE_OK,
            "SQLITE_BIND_TEXT",
            "index=\(index) result=\(result)")
    }

    func bind(_ index: Int32, int: Int) throws {
        try bind(index, int64: Int64(int))
    }

    func bind(_ index: Int32, optionalInt: Int?) throws {
        if let optionalInt {
            try bind(index, int: optionalInt)
        } else {
            let result = sqlite3_bind_null(handle, index)
            try disposalRequire(
                result == SQLITE_OK,
                "SQLITE_BIND_NULL",
                "index=\(index) result=\(result)")
        }
    }

    func bind(_ index: Int32, int64: Int64) throws {
        let result = sqlite3_bind_int64(handle, index, int64)
        try disposalRequire(
            result == SQLITE_OK,
            "SQLITE_BIND_INT",
            "index=\(index) result=\(result)")
    }

    func bind(_ index: Int32, data: Data?) throws {
        guard let data else {
            let result = sqlite3_bind_null(handle, index)
            try disposalRequire(
                result == SQLITE_OK,
                "SQLITE_BIND_NULL",
                "index=\(index) result=\(result)")
            return
        }
        let result = data.withUnsafeBytes { raw in
            sqlite3_bind_blob(
                handle,
                index,
                raw.baseAddress,
                Int32(raw.count),
                disposalSQLiteTransient)
        }
        try disposalRequire(
            result == SQLITE_OK,
            "SQLITE_BIND_BLOB",
            "index=\(index) result=\(result)")
    }

    func stepDone() throws {
        let result = sqlite3_step(handle)
        let message = connection.handle.map { String(cString: sqlite3_errmsg($0)) }
            ?? "closed"
        try disposalRequire(
            result == SQLITE_DONE,
            "SQLITE_STEP_DONE",
            "result=\(result):\(message)")
    }

    func step() throws -> Bool {
        let result = sqlite3_step(handle)
        if result == SQLITE_ROW { return true }
        if result == SQLITE_DONE { return false }
        let message = connection.handle.map { String(cString: sqlite3_errmsg($0)) }
            ?? "closed"
        throw DisposalSQLiteFailure.rejected(
            "SQLITE_STEP", "result=\(result):\(message)")
    }

    func int64(_ index: Int32) -> Int64 {
        sqlite3_column_int64(handle, index)
    }

    func optionalText(_ index: Int32) -> String? {
        guard sqlite3_column_type(handle, index) != SQLITE_NULL,
              let pointer = sqlite3_column_text(handle, index)
        else { return nil }
        let count = Int(sqlite3_column_bytes(handle, index))
        return String(decoding: UnsafeBufferPointer(start: pointer, count: count), as: UTF8.self)
    }

    func data(_ index: Int32) -> Data? {
        guard sqlite3_column_type(handle, index) != SQLITE_NULL else { return nil }
        let count = Int(sqlite3_column_bytes(handle, index))
        if count == 0 { return Data() }
        guard let pointer = sqlite3_column_blob(handle, index) else { return nil }
        return Data(bytes: pointer, count: count)
    }
}
