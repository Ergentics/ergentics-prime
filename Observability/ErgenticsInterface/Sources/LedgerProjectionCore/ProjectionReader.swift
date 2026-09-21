import Darwin
import Foundation

public enum LedgerProjectionReader {
    public static func loadDefault() -> LedgerProjectionAvailability {
        load(environment: ProcessInfo.processInfo.environment)
    }

    public static func load(environment: [String: String]) -> LedgerProjectionAvailability {
        let root = environment["ERGENTICS_LEDGER_PROJECTION_ROOT"]
        let sealSHA256 = environment["ERGENTICS_LEDGER_PROJECTION_SEAL_SHA256"]
        if root == nil && sealSHA256 == nil {
            return .empty
        }
        guard let root, !root.isEmpty, let sealSHA256, isLowerSHA256(sealSHA256) else {
            return .rejected(.init(code: "PROJECTION_ENVIRONMENT_PARTIAL", detail: "root and exact seal SHA-256 are both required"))
        }
        return load(rootPath: root, expectedSealSHA256: sealSHA256)
    }

    public static func load(
        rootPath: String,
        expectedSealSHA256: String
    ) -> LedgerProjectionAvailability {
        do {
            try require(isLowerSHA256(expectedSealSHA256), "EXPECTED_SEAL_SHA256")
            let held = try HeldProjectionArtifacts(
                rootPath: rootPath,
                expectedSealSHA256: expectedSealSHA256)
            return .admitted(try decodeSnapshot(database: held.database, seal: held.seal))
        } catch let error as LedgerProjectionMissing {
            _ = error
            return .empty
        } catch let error as LedgerProjectionRejection {
            return .rejected(error)
        } catch {
            return .rejected(.init(code: "READER_INTERNAL", detail: String(describing: error)))
        }
    }
}

private struct LedgerProjectionMissing: Error {}

private func decodeSnapshot(database databaseBytes: Data, seal sealWithLF: Data) throws
    -> LedgerProjectionSnapshot
{
    try require(sealWithLF.last == 0x0a, "SEAL_TERMINAL_LF")
    let seal = sealWithLF.dropLast()
    var parser = LedgerCanonicalJSONParser(data: Data(seal))
    let sealValue = try parser.parse()
    try require(sealValue.canonicalData() == seal, "SEAL_NONCANONICAL")
    try require(sealValue.member("schema")?.stringValue() == "ergentics_ledger_projection_sidecar_v1", "SEAL_SCHEMA")
    try require(sealValue.member("status")?.stringValue() == "PASS_NONAUTHORITATIVE_PROJECTION", "SEAL_STATUS")
    try require(sealValue.member("authority_vector")?.stringValue() == "00000000", "SEAL_AUTHORITY_VECTOR")
    try require(sealValue.member("authoritative")?.boolValue() == false, "SEAL_AUTHORITATIVE")
    try require(sealValue.member("may_feed_controller")?.boolValue() == false, "SEAL_CONTROLLER_FEED")
    let databaseBytesText = try requiredNumber(sealValue, "database_bytes")
    try require(Int(databaseBytesText) == databaseBytes.count, "SEAL_DATABASE_BYTES")
    let databaseSHA256 = try requiredString(sealValue, "database_sha256")
    try require(ledgerSHA256(databaseBytes) == databaseSHA256, "SEAL_DATABASE_SHA256")
    let projectionID = try requiredString(sealValue, "projection_id")
    let adapterSHA256 = try requiredString(sealValue, "adapter_manifest_sha256")
    let ddlSHA256 = try requiredString(sealValue, "ddl_sha256")
    let extractorSHA256 = try requiredString(sealValue, "extractor_semantics_sha256")
    let adapter = try readerResourceData(name: "adapters.v1", extension: "json")
    try require(ledgerSHA256(adapter) == adapterSHA256, "READER_ADAPTER_SHA256")
    let relationalExportSHA256 = try requiredString(sealValue, "relational_export_sha256")
    let graphExportSHA256 = try requiredString(sealValue, "graph_export_sha256")
    guard let source = sealValue.member("source") else { throw rejection("SEAL_SOURCE") }
    try require(try requiredString(source, "commit") == PinnedLedgerProjectionV1.sourceCommit, "SEAL_SOURCE_COMMIT")
    try require(try requiredString(source, "tree") == PinnedLedgerProjectionV1.sourceTree, "SEAL_SOURCE_TREE")
    try require(try requiredString(source, "blob") == PinnedLedgerProjectionV1.sourceBlob, "SEAL_SOURCE_BLOB")
    try require(try requiredString(source, "sha256") == PinnedLedgerProjectionV1.sourceSHA256, "SEAL_SOURCE_SHA")
    try require(Int(try requiredNumber(source, "bytes")) == PinnedLedgerProjectionV1.sourceBytes, "SEAL_SOURCE_BYTES")

    let db = try LedgerSQLiteConnection(serializedReadOnly: databaseBytes)
    try require(try db.scalarText("PRAGMA quick_check") == "ok", "READER_QUICK_CHECK")
    try require(try db.scalarInt("SELECT count(*) FROM pragma_foreign_key_check") == 0, "READER_FOREIGN_KEY_CHECK")
    try require(try db.scalarInt("PRAGMA application_id") == 1_347_832_903, "READER_APPLICATION_ID")
    try require(try db.scalarInt("PRAGMA user_version") == 1, "READER_USER_VERSION")
    try require(try db.scalarInt("SELECT count(*) FROM projection_policy WHERE singleton=1 AND projection_schema='ergentics_ledger_projection_v1' AND authority_vector='00000000' AND authoritative=0 AND may_feed_controller=0 AND prose_may_supply_fact=0") == 1, "READER_POLICY")
    try require(try db.scalarInt("SELECT count(*) FROM projection_seal WHERE singleton=1") == 1, "READER_SEAL_COUNT")
    try require(try db.scalarText("SELECT projection_id FROM projection_seal WHERE singleton=1") == projectionID, "READER_PROJECTION_ID")
    try require(try db.scalarText("SELECT source_sha256 FROM projection_seal WHERE singleton=1") == PinnedLedgerProjectionV1.sourceSHA256, "READER_SOURCE_ID")
    try require(try db.scalarText("SELECT ddl_sha256 FROM projection_seal WHERE singleton=1") == ddlSHA256, "READER_DDL_ID")
    try require(try db.scalarText("SELECT adapter_manifest_sha256 FROM projection_seal WHERE singleton=1") == adapterSHA256, "READER_ADAPTER_ID")
    try require(try db.scalarText("SELECT extractor_semantics_sha256 FROM projection_seal WHERE singleton=1") == extractorSHA256, "READER_EXTRACTOR_ID")
    try require(try db.scalarText("SELECT preseal_relational_export_sha256 FROM projection_seal WHERE singleton=1") == relationalExportSHA256, "READER_RELATIONAL_EXPORT")
    try require(try db.scalarText("SELECT graph_export_sha256 FROM projection_seal WHERE singleton=1") == graphExportSHA256, "READER_GRAPH_EXPORT")
    let sourceStatement = try db.prepare("SELECT prefix_bytes,prefix_lf_count,raw_prefix FROM source_snapshot WHERE source_sha256=?")
    try sourceStatement.bind(1, text: PinnedLedgerProjectionV1.sourceSHA256)
    try require(try sourceStatement.step(), "READER_SOURCE_ROW")
    try require(sourceStatement.int64(0) == Int64(PinnedLedgerProjectionV1.sourceBytes), "READER_SOURCE_PREFIX_BYTES")
    try require(sourceStatement.int64(1) == Int64(PinnedLedgerProjectionV1.sourceLFCount), "READER_SOURCE_PREFIX_LF")
    let rawSource = sourceStatement.data(2)
    try require(ledgerSHA256(rawSource) == PinnedLedgerProjectionV1.sourceSHA256, "READER_RAW_SOURCE_SHA")
    try require(!(try sourceStatement.step()), "READER_SOURCE_MULTIPLE")

    let reconstructed = try reconstructPinnedProjection(source: rawSource)
    try require(reconstructed.ddlSHA256 == ddlSHA256, "READER_DDL_SHA256")
    try require(reconstructed.adapterSHA256 == adapterSHA256, "READER_ADAPTER_RECONSTRUCTED_SHA256")
    try require(reconstructed.extractorSHA256 == extractorSHA256, "READER_EXTRACTOR_SHA256")
    try require(reconstructed.projectionID == projectionID, "READER_PROJECTION_ID_RECONSTRUCTED")
    try require(reconstructed.relationalExportSHA256 == relationalExportSHA256, "READER_RELATIONAL_EXPORT_RECONSTRUCTED")
    try require(reconstructed.graphExportSHA256 == graphExportSHA256, "READER_GRAPH_EXPORT_RECONSTRUCTED")
    try require(reconstructed.database == databaseBytes, "READER_DATABASE_RECONSTRUCTED_BYTES")
    try require(reconstructed.seal == sealWithLF, "READER_SEAL_RECONSTRUCTED_BYTES")

    let counts = try readCounts(db)
    try validateActualTableCounts(db, against: counts)
    guard let countValue = sealValue.member("counts") else { throw rejection("SEAL_COUNTS") }
    try validateCounts(counts, against: countValue)
    return .init(
        metadata: .init(
            projectionID: projectionID,
            sourceCommit: PinnedLedgerProjectionV1.sourceCommit,
            sourceTree: PinnedLedgerProjectionV1.sourceTree,
            sourceBlob: PinnedLedgerProjectionV1.sourceBlob,
            sourceSHA256: PinnedLedgerProjectionV1.sourceSHA256,
            databaseSHA256: databaseSHA256,
            databaseBytes: databaseBytes.count,
            relationalExportSHA256: relationalExportSHA256,
            graphExportSHA256: graphExportSHA256,
            authorityVector: "00000000",
            authoritative: false,
            mayFeedController: false),
        counts: counts,
        timeline: try readTimeline(db),
        records: try readRecords(db),
        stateTokens: try readStates(db),
        graphNodes: try readGraphNodes(db),
        graphEdges: try readGraphEdges(db),
        energyFacts: try readEnergyFacts(db, adapterData: adapter))
}

private func readCounts(_ db: LedgerSQLiteConnection) throws -> LedgerProjectionCounts {
    let statement = try db.prepare("SELECT section_count,fence_count,record_count,canonical_record_count,legacy_record_count,json_node_count,state_token_count,digest_occurrence_count,graph_node_count,graph_edge_count FROM projection_seal WHERE singleton=1")
    try require(try statement.step(), "READER_COUNTS")
    let values = (0..<10).map { Int(statement.int64(Int32($0))) }
    try require(!(try statement.step()), "READER_COUNTS_MULTIPLE")
    return .init(
        sections: values[0], fences: values[1], records: values[2],
        canonicalRecords: values[3], legacyRecords: values[4], jsonNodes: values[5],
        stateTokens: values[6], digestOccurrences: values[7], graphNodes: values[8],
        graphEdges: values[9])
}

private func validateCounts(_ counts: LedgerProjectionCounts, against value: LedgerJSONValue) throws {
    let expected: [(String, Int)] = [
        ("sections", counts.sections), ("fences", counts.fences),
        ("records", counts.records), ("canonical_records", counts.canonicalRecords),
        ("legacy_records", counts.legacyRecords), ("json_nodes", counts.jsonNodes),
        ("state_tokens", counts.stateTokens), ("digest_occurrences", counts.digestOccurrences),
        ("graph_nodes", counts.graphNodes), ("graph_edges", counts.graphEdges),
    ]
    for (key, expectedValue) in expected {
        try require(Int(try requiredNumber(value, key)) == expectedValue, "SEAL_COUNT_\(key.uppercased())")
    }
}

private func validateActualTableCounts(
    _ db: LedgerSQLiteConnection,
    against counts: LedgerProjectionCounts
) throws {
    let actual: [(String, Int64, Int)] = [
        ("SECTIONS", try db.scalarInt("SELECT count(*) FROM sections"), counts.sections),
        ("FENCES", try db.scalarInt("SELECT count(DISTINCT fence_ordinal) FROM appendix_records"), counts.fences),
        ("RECORDS", try db.scalarInt("SELECT count(*) FROM appendix_records"), counts.records),
        ("CANONICAL_RECORDS", try db.scalarInt("SELECT count(*) FROM appendix_records WHERE canonical_state='CANONICAL_EXACT'"), counts.canonicalRecords),
        ("LEGACY_RECORDS", try db.scalarInt("SELECT count(*) FROM appendix_records WHERE canonical_state='PARSED_LEGACY_NONCANONICAL'"), counts.legacyRecords),
        ("JSON_NODES", try db.scalarInt("SELECT count(*) FROM json_nodes"), counts.jsonNodes),
        ("STATE_TOKENS", try db.scalarInt("SELECT count(*) FROM state_tokens"), counts.stateTokens),
        ("DIGEST_OCCURRENCES", try db.scalarInt("SELECT count(*) FROM digest_occurrences"), counts.digestOccurrences),
        ("GRAPH_NODES", try db.scalarInt("SELECT count(*) FROM graph_nodes"), counts.graphNodes),
        ("GRAPH_EDGES", try db.scalarInt("SELECT count(*) FROM graph_edges"), counts.graphEdges),
    ]
    for (name, observed, sealed) in actual {
        try require(observed == Int64(sealed), "READER_ACTUAL_COUNT_\(name)")
    }
    try require(
        counts.canonicalRecords + counts.legacyRecords == counts.records,
        "READER_RECORD_CLASS_PARTITION")
}

private func readTimeline(_ db: LedgerSQLiteConnection) throws -> [LedgerTimelineEntry] {
    let statement = try db.prepare("SELECT record_ordinal,line_number,section_title,schema_text,status_text,canonical_state,raw_sha256_no_lf,computed_payload_sha256,payload_hash_state FROM ui_timeline ORDER BY record_ordinal")
    var result: [LedgerTimelineEntry] = []
    while try statement.step() {
        result.append(.init(
            recordOrdinal: Int(statement.int64(0)),
            lineNumber: Int(statement.int64(1)),
            sectionTitle: statement.optionalText(2),
            schema: statement.optionalText(3),
            status: statement.optionalText(4),
            canonicalState: statement.optionalText(5) ?? "",
            frameSHA256: statement.optionalText(6) ?? "",
            payloadSHA256: statement.optionalText(7),
            payloadHashState: statement.optionalText(8) ?? ""))
    }
    return result
}

private func readRecords(_ db: LedgerSQLiteConnection) throws -> [LedgerRawRecord] {
    let statement = try db.prepare("SELECT record_ordinal,line_number,schema_text,status_text,canonical_state,raw_json,raw_sha256_no_lf FROM appendix_records ORDER BY record_ordinal")
    var result: [LedgerRawRecord] = []
    while try statement.step() {
        let raw = statement.data(5)
        guard let text = String(data: raw, encoding: .utf8) else { throw rejection("READER_RAW_RECORD_UTF8") }
        result.append(.init(
            recordOrdinal: Int(statement.int64(0)), lineNumber: Int(statement.int64(1)),
            schema: statement.optionalText(2), status: statement.optionalText(3),
            canonicalState: statement.optionalText(4) ?? "", rawJSON: text,
            frameSHA256: statement.optionalText(6) ?? ""))
    }
    return result
}

private func readStates(_ db: LedgerSQLiteConnection) throws -> [LedgerStateToken] {
    let statement = try db.prepare("SELECT record_ordinal,json_pointer,exact_value,state_class,canonical_source FROM ui_state_tokens")
    var result: [LedgerStateToken] = []
    while try statement.step() {
        result.append(.init(
            recordOrdinal: Int(statement.int64(0)), jsonPointer: statement.optionalText(1) ?? "",
            exactValue: statement.optionalText(2) ?? "", stateClass: statement.optionalText(3) ?? "",
            canonicalSource: statement.int64(4) == 1))
    }
    return result
}

private func readGraphNodes(_ db: LedgerSQLiteConnection) throws -> [LedgerGraphNode] {
    let statement = try db.prepare("SELECT node_id,node_kind,canonical_key,display_label,record_ordinal,json_pointer FROM ui_graph_nodes")
    var result: [LedgerGraphNode] = []
    while try statement.step() {
        result.append(.init(
            nodeID: statement.optionalText(0) ?? "", kind: statement.optionalText(1) ?? "",
            canonicalKey: statement.optionalText(2) ?? "", label: statement.optionalText(3) ?? "",
            recordOrdinal: statement.optionalText(4).flatMap(Int.init),
            jsonPointer: statement.optionalText(5)))
    }
    return result
}

private func readGraphEdges(_ db: LedgerSQLiteConnection) throws -> [LedgerGraphEdge] {
    let statement = try db.prepare("SELECT edge_id,from_node_id,predicate,to_node_id,source_record_ordinal,source_json_pointer,evidence_grade FROM ui_graph_edges")
    var result: [LedgerGraphEdge] = []
    while try statement.step() {
        result.append(.init(
            edgeID: statement.optionalText(0) ?? "", fromNodeID: statement.optionalText(1) ?? "",
            predicate: statement.optionalText(2) ?? "", toNodeID: statement.optionalText(3) ?? "",
            sourceRecordOrdinal: sqliteOptionalInt(statement, 4),
            sourceJSONPointer: statement.optionalText(5), evidenceGrade: statement.optionalText(6) ?? ""))
    }
    return result
}

private func readEnergyFacts(
    _ db: LedgerSQLiteConnection,
    adapterData: Data
) throws -> [LedgerEnergyFact] {
    var adapterParser = LedgerCanonicalJSONParser(data: adapterData)
    let adapter = try adapterParser.parse()
    let tokens = try requiredStringArray(adapter, "energy_pointer_tokens")
    let unitKeys = try requiredStringArray(adapter, "energy_unit_sibling_keys")
    let qualificationKeys = try requiredStringArray(adapter, "energy_qualification_sibling_keys")
    let statement = try db.prepare("SELECT record_ordinal,json_pointer,decoded_text FROM json_nodes WHERE decoded_text IS NOT NULL ORDER BY record_ordinal,json_pointer")
    var rows: [(record: Int, pointer: String, value: String)] = []
    while try statement.step() {
        rows.append((Int(statement.int64(0)), statement.optionalText(1) ?? "", statement.optionalText(2) ?? ""))
    }
    let lookup = Dictionary(uniqueKeysWithValues: rows.map { ("\($0.record):\($0.pointer)", $0.value) })
    var result: [LedgerEnergyFact] = []
    for row in rows {
        let lower = row.pointer.lowercased()
        guard tokens.contains(where: { lower.contains($0.lowercased()) }) else { continue }
        let parent = row.pointer.split(separator: "/", omittingEmptySubsequences: false).dropLast().joined(separator: "/")
        let unit = unitKeys.lazy.compactMap { lookup["\(row.record):\(parent)/\($0)"] }.first
        let qualification = qualificationKeys.lazy.compactMap { lookup["\(row.record):\(parent)/\($0)"] }.first
        result.append(.init(
            recordOrdinal: row.record,
            jsonPointer: row.pointer,
            exactValue: row.value,
            unit: unit,
            qualification: qualification,
            evidenceGrade: "DIGEST_PINNED_POINTER_SELECTION_EXACT_JSON_SCALAR_NO_RECOMPUTATION"))
    }
    return result
}

private func sqliteOptionalInt(_ statement: LedgerSQLiteStatement, _ index: Int32) -> Int? {
    statement.optionalText(index).flatMap(Int.init)
}

private func requiredString(_ value: LedgerJSONValue, _ key: String) throws -> String {
    guard let result = value.member(key)?.stringValue() else { throw rejection("SEAL_STRING", key) }
    return result
}

private func requiredNumber(_ value: LedgerJSONValue, _ key: String) throws -> String {
    guard let result = value.member(key)?.numberValue() else { throw rejection("SEAL_NUMBER", key) }
    return result
}

private func requiredStringArray(_ value: LedgerJSONValue, _ key: String) throws -> [String] {
    guard let member = value.member(key), case .array(let values, _) = member else {
        throw rejection("ADAPTER_STRING_ARRAY", key)
    }
    return try values.map {
        guard let string = $0.stringValue() else { throw rejection("ADAPTER_STRING_ARRAY_VALUE", key) }
        return string
    }
}

private final class HeldProjectionArtifacts {
    let rootDescriptor: Int32
    let database: Data
    let seal: Data

    init(rootPath: String, expectedSealSHA256: String) throws {
        try require(rootPath.hasPrefix("/private/tmp/"), "READER_ROOT_SCOPE")
        var resolved = [CChar](repeating: 0, count: Int(PATH_MAX))
        errno = 0
        if realpath(rootPath, &resolved) == nil && errno == ENOENT { throw LedgerProjectionMissing() }
        guard resolved.first != 0 else { throw rejection("READER_ROOT_REALPATH", String(cString: strerror(errno))) }
        let resolvedPath = String(
            decoding: resolved.prefix { $0 != 0 }.map { UInt8(bitPattern: $0) },
            as: UTF8.self)
        try require(resolvedPath == rootPath, "READER_ROOT_ALIAS")
        errno = 0
        let openedRoot = Darwin.open(
            rootPath,
            O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW_ANY)
        if openedRoot < 0 && errno == ENOENT { throw LedgerProjectionMissing() }
        guard openedRoot >= 0 else { throw rejection("READER_ROOT_OPEN", String(cString: strerror(errno))) }
        var closeOnFailure = true
        defer { if closeOnFailure { _ = Darwin.close(openedRoot) } }
        var rootState = stat()
        guard fstat(openedRoot, &rootState) == 0 else { throw rejection("READER_ROOT_FSTAT") }
        try require((rootState.st_mode & S_IFMT) == S_IFDIR, "READER_ROOT_TYPE")
        try require((rootState.st_mode & 0o7777) == 0o500, "READER_ROOT_MODE")
        try require(rootState.st_uid == geteuid(), "READER_ROOT_OWNER")
        let entries = try readerDirectoryEntries(openedRoot).sorted()
        try require(entries == [PinnedLedgerProjectionV1.databaseLeaf, PinnedLedgerProjectionV1.sealLeaf].sorted(), "READER_ROOT_INVENTORY")
        let readDatabase = try readHeldLeaf(
            rootDescriptor: openedRoot,
            leaf: PinnedLedgerProjectionV1.databaseLeaf,
            maximumBytes: 64 * 1_024 * 1_024)
        let readSeal = try readHeldLeaf(
            rootDescriptor: openedRoot,
            leaf: PinnedLedgerProjectionV1.sealLeaf,
            maximumBytes: 1 * 1_024 * 1_024)
        try require(ledgerSHA256(readSeal) == expectedSealSHA256, "READER_SEAL_SHA256")
        var after = stat()
        var named = stat()
        guard fstat(openedRoot, &after) == 0,
              lstat(rootPath, &named) == 0
        else { throw rejection("READER_ROOT_REVALIDATE") }
        try require(readerSameState(rootState, after), "READER_ROOT_DRIFT")
        try require(readerSameState(after, named), "READER_ROOT_REBOUND")
        try require(try readerDirectoryEntries(openedRoot).sorted() == entries, "READER_ROOT_INVENTORY_DRIFT")
        rootDescriptor = openedRoot
        database = readDatabase
        seal = readSeal
        closeOnFailure = false
    }

    deinit { _ = Darwin.close(rootDescriptor) }
}

private func readHeldLeaf(rootDescriptor: Int32, leaf: String, maximumBytes: Int) throws -> Data {
    let descriptor = Darwin.openat(
        rootDescriptor,
        leaf,
        O_RDONLY | O_CLOEXEC | O_NOFOLLOW_ANY)
    guard descriptor >= 0 else { throw rejection("READER_LEAF_OPEN", leaf) }
    defer { _ = Darwin.close(descriptor) }
    var before = stat()
    guard fstat(descriptor, &before) == 0 else { throw rejection("READER_LEAF_FSTAT", leaf) }
    try require((before.st_mode & S_IFMT) == S_IFREG, "READER_LEAF_TYPE", leaf)
    try require((before.st_mode & 0o7777) == 0o400, "READER_LEAF_MODE", leaf)
    try require(before.st_uid == geteuid() && before.st_nlink == 1, "READER_LEAF_IDENTITY", leaf)
    try require(before.st_size > 0 && before.st_size <= off_t(maximumBytes), "READER_LEAF_SIZE", leaf)
    let bytes = try readerPreadExact(descriptor: descriptor, count: Int(before.st_size))
    var after = stat()
    var named = stat()
    guard fstat(descriptor, &after) == 0,
          fstatat(rootDescriptor, leaf, &named, AT_SYMLINK_NOFOLLOW) == 0
    else { throw rejection("READER_LEAF_REVALIDATE", leaf) }
    try require(readerSameState(before, after), "READER_LEAF_DRIFT", leaf)
    try require(readerSameState(after, named), "READER_LEAF_REBOUND", leaf)
    return bytes
}

private func readerPreadExact(descriptor: Int32, count: Int) throws -> Data {
    var data = Data(count: count)
    var completed = 0
    while completed < count {
        let result = data.withUnsafeMutableBytes { raw -> Int in
            guard let base = raw.baseAddress else { return -1 }
            return pread(descriptor, base.advanced(by: completed), count - completed, off_t(completed))
        }
        if result > 0 { completed += result }
        else if result < 0 && errno == EINTR { continue }
        else { throw rejection("READER_PREAD") }
    }
    return data
}

private func readerDirectoryEntries(_ descriptor: Int32) throws -> [String] {
    let copied = dup(descriptor)
    guard copied >= 0, let directory = fdopendir(copied) else {
        if copied >= 0 { _ = Darwin.close(copied) }
        throw rejection("READER_FDOPENDIR")
    }
    defer { closedir(directory) }
    rewinddir(directory)
    var result: [String] = []
    errno = 0
    while let entry = readdir(directory) {
        let name = withUnsafePointer(to: &entry.pointee.d_name) {
            $0.withMemoryRebound(to: CChar.self, capacity: Int(NAME_MAX) + 1) { String(cString: $0) }
        }
        if name != "." && name != ".." { result.append(name) }
        errno = 0
    }
    try require(errno == 0, "READER_READDIR")
    return result
}

private func readerSameState(_ lhs: stat, _ rhs: stat) -> Bool {
    lhs.st_dev == rhs.st_dev && lhs.st_ino == rhs.st_ino && lhs.st_mode == rhs.st_mode &&
        lhs.st_nlink == rhs.st_nlink && lhs.st_uid == rhs.st_uid && lhs.st_gid == rhs.st_gid &&
        lhs.st_size == rhs.st_size && lhs.st_gen == rhs.st_gen &&
        lhs.st_mtimespec.tv_sec == rhs.st_mtimespec.tv_sec &&
        lhs.st_mtimespec.tv_nsec == rhs.st_mtimespec.tv_nsec &&
        lhs.st_ctimespec.tv_sec == rhs.st_ctimespec.tv_sec &&
        lhs.st_ctimespec.tv_nsec == rhs.st_ctimespec.tv_nsec
}

private func isLowerSHA256(_ value: String) -> Bool {
    value.utf8.count == 64 && value.utf8.allSatisfy {
        (0x30...0x39).contains($0) || (0x61...0x66).contains($0)
    }
}

private func readerResourceData(name: String, extension extensionName: String) throws -> Data {
    guard let url = Bundle.module.url(forResource: name, withExtension: extensionName) else {
        throw rejection("READER_RESOURCE_ABSENT", "\(name).\(extensionName)")
    }
    do { return try Data(contentsOf: url, options: [.mappedIfSafe]) }
    catch { throw rejection("READER_RESOURCE_READ", String(describing: error)) }
}
