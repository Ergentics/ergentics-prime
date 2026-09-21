import Darwin
import Foundation

private let projectionSchema = "ergentics_ledger_projection_v1"
private let extractorSemantics = """
ergentics-ledger-projector-v1
source=exact-held-prefix
json=RFC8259-grammar;duplicate-keys-rejected;number-lexeme-preserved
canonical=recursive-UTF8-lexicographic-object-keys;compact;no-number-normalization
facts=JSON-frame-data-only
graph=structural-computed-sha256-lexical-equality-only
authority=0
may-feed-controller=0
"""

struct BuiltGraphNode: Sendable {
    let id: String
    let kind: String
    let canonicalKey: String
    let label: String
    let recordOrdinal: Int?
    let jsonPointer: String?
}

struct BuiltGraphEdge: Sendable {
    let id: String
    let from: String
    let predicate: String
    let to: String
    let sourceRecordOrdinal: Int?
    let sourceJSONPointer: String?
    let evidenceGrade: String
}

struct BuiltGraph: Sendable {
    let nodes: [BuiltGraphNode]
    let edges: [BuiltGraphEdge]
}

struct LedgerProjectionMaterial: Sendable {
    let database: Data
    let seal: Data
    let databaseSHA256: String
    let sealSHA256: String
    let projectionID: String
    let ddlSHA256: String
    let adapterSHA256: String
    let extractorSHA256: String
    let relationalExportSHA256: String
    let graphExportSHA256: String
    let counts: LedgerProjectionCounts
}

public enum LedgerProjectionBuilder {
    public static func buildPinnedProjection(
        outputRootPath: String = PinnedLedgerProjectionV1.outputRootPath
    ) throws -> LedgerProjectionBuildReport {
        let scan = try LedgerPrefixScanner.scanPinnedSource()
        let material = try makeProjectionMaterial(scan: scan)
        let root = try ExclusiveProjectionRoot(path: outputRootPath)
        try root.writeExclusive(leaf: PinnedLedgerProjectionV1.databaseLeaf, data: material.database)
        try root.writeExclusive(leaf: PinnedLedgerProjectionV1.sealLeaf, data: material.seal)
        try root.seal(expectedLeaves: [PinnedLedgerProjectionV1.databaseLeaf, PinnedLedgerProjectionV1.sealLeaf])
        return .init(
            outputRootPath: outputRootPath,
            databasePath: outputRootPath + "/" + PinnedLedgerProjectionV1.databaseLeaf,
            sealPath: outputRootPath + "/" + PinnedLedgerProjectionV1.sealLeaf,
            databaseBytes: material.database.count,
            databaseSHA256: material.databaseSHA256,
            sealSHA256: material.sealSHA256,
            projectionID: material.projectionID,
            counts: material.counts)
    }

    static func buildForTesting(source: Data) throws -> (scan: LedgerScanResult, graph: BuiltGraph) {
        let scan = try LedgerPrefixScanner.scan(source: source)
        return (scan, makeGraph(scan))
    }
}

func reconstructPinnedProjection(source: Data) throws -> LedgerProjectionMaterial {
    try require(source.count == PinnedLedgerProjectionV1.sourceBytes, "RECONSTRUCT_SOURCE_BYTES")
    try require(ledgerSHA256(source) == PinnedLedgerProjectionV1.sourceSHA256, "RECONSTRUCT_SOURCE_SHA256")
    return try makeProjectionMaterial(scan: LedgerPrefixScanner.scan(source: source))
}

private func makeProjectionMaterial(scan: LedgerScanResult) throws -> LedgerProjectionMaterial {
    let ddl = try resourceData(name: "001-initial", extension: "sql")
    let adapters = try resourceData(name: "adapters.v1", extension: "json")
    try require(adapters.last == 0x0a, "ADAPTER_MANIFEST_TERMINAL_LF")
    let adapterFrame = Data(adapters.dropLast())
    var adapterParser = LedgerCanonicalJSONParser(data: adapterFrame)
    let adapterValue = try adapterParser.parse()
    try require(adapterValue.canonicalData() == adapterFrame, "ADAPTER_MANIFEST_NONCANONICAL")
    let ddlSHA256 = ledgerSHA256(ddl)
    let adapterSHA256 = ledgerSHA256(adapters)
    let extractorSHA256 = ledgerSHA256(Data(extractorSemantics.utf8))
    let projectionID = projectionIdentity(
        ddlSHA256: ddlSHA256,
        adapterSHA256: adapterSHA256,
        extractorSHA256: extractorSHA256)
    let graph = makeGraph(scan)
    try require(graph.edges.count <= 262_144, "GRAPH_EDGE_CAP")
    let relationalExportSHA256 = relationalExportHash(scan: scan)
    let graphExportSHA256 = graphExportHash(graph)
    let counts = LedgerProjectionCounts(
        sections: scan.sections.count,
        fences: scan.fenceCount,
        records: scan.records.count,
        canonicalRecords: scan.canonicalRecordCount,
        legacyRecords: scan.legacyRecordCount,
        jsonNodes: scan.jsonNodeCount,
        stateTokens: scan.stateTokenCount,
        digestOccurrences: scan.digestOccurrenceCount,
        graphNodes: graph.nodes.count,
        graphEdges: graph.edges.count)
    let database = try buildDatabase(
        scan: scan,
        graph: graph,
        ddl: ddl,
        ddlSHA256: ddlSHA256,
        adapterSHA256: adapterSHA256,
        extractorSHA256: extractorSHA256,
        projectionID: projectionID,
        relationalExportSHA256: relationalExportSHA256,
        graphExportSHA256: graphExportSHA256,
        counts: counts)
    let databaseSHA256 = ledgerSHA256(database)
    let seal = makeSidecar(
        projectionID: projectionID,
        database: database,
        databaseSHA256: databaseSHA256,
        ddlSHA256: ddlSHA256,
        adapterSHA256: adapterSHA256,
        extractorSHA256: extractorSHA256,
        relationalExportSHA256: relationalExportSHA256,
        graphExportSHA256: graphExportSHA256,
        counts: counts)
    return .init(
        database: database,
        seal: seal,
        databaseSHA256: databaseSHA256,
        sealSHA256: ledgerSHA256(seal),
        projectionID: projectionID,
        ddlSHA256: ddlSHA256,
        adapterSHA256: adapterSHA256,
        extractorSHA256: extractorSHA256,
        relationalExportSHA256: relationalExportSHA256,
        graphExportSHA256: graphExportSHA256,
        counts: counts)
}

private func buildDatabase(
    scan: LedgerScanResult,
    graph: BuiltGraph,
    ddl: Data,
    ddlSHA256: String,
    adapterSHA256: String,
    extractorSHA256: String,
    projectionID: String,
    relationalExportSHA256: String,
    graphExportSHA256: String,
    counts: LedgerProjectionCounts
) throws -> Data {
    guard let sql = String(data: ddl, encoding: .utf8) else { throw rejection("DDL_UTF8") }
    let db = try LedgerSQLiteConnection(memory: true)
    try db.execute(sql)
    try db.execute("BEGIN IMMEDIATE")
    do {
        let policy = try db.prepare("INSERT INTO projection_policy VALUES(1,?,?,?,?,?,?)")
        try policy.bind(1, text: projectionSchema)
        try policy.bind(2, text: "00000000")
        try policy.bind(3, int: 0)
        try policy.bind(4, int: 0)
        try policy.bind(5, int: 0)
        try policy.bind(6, text: "NO_FINAL_DB_NO_STALE_FALLBACK_EMPTY_UI")
        try policy.stepDone()

        let source = try db.prepare("INSERT INTO source_snapshot VALUES(?,?,?,?,?,?,?,?,?)")
        try source.bind(1, text: PinnedLedgerProjectionV1.sourceSHA256)
        try source.bind(2, text: "docs/PRIME-SWIFT-VALIDATION-DRIVER-V2-DURABLE-PHASE-CONTROL-2026-08-22.md")
        try source.bind(3, text: PinnedLedgerProjectionV1.sourceCommit)
        try source.bind(4, text: PinnedLedgerProjectionV1.sourceTree)
        try source.bind(5, text: PinnedLedgerProjectionV1.sourceBlob)
        try source.bind(6, int: scan.source.count)
        try source.bind(7, int: scan.source.filter { $0 == 0x0a }.count)
        try source.bind(8, int: 1)
        try source.bind(9, data: scan.source)
        try source.stepDone()

        let migration = try db.prepare("INSERT INTO schema_migrations VALUES(1,NULL,?,?,?)")
        try migration.bind(1, text: "001-initial.sql")
        try migration.bind(2, text: ddlSHA256)
        try migration.bind(3, text: extractorSHA256)
        try migration.stepDone()

        let sectionStatement = try db.prepare("INSERT INTO sections VALUES(?,?,?,?,?,?,?,?)")
        for section in scan.sections {
            sectionStatement.reset()
            try sectionStatement.bind(1, text: PinnedLedgerProjectionV1.sourceSHA256)
            try sectionStatement.bind(2, int: section.ordinal)
            try sectionStatement.bind(3, int: section.level)
            try sectionStatement.bind(4, int: section.headingLine)
            try sectionStatement.bind(5, int: section.headingByteOffset)
            try sectionStatement.bind(6, int: section.contentEndByteOffset)
            try sectionStatement.bind(7, text: section.headingText)
            try sectionStatement.bind(8, text: section.headingSHA256)
            try sectionStatement.stepDone()
        }

        let recordStatement = try db.prepare(
            "INSERT INTO appendix_records VALUES(" + String(repeating: "?,", count: 20) + "?)")
        let nodeStatement = try db.prepare(
            "INSERT INTO json_nodes VALUES(" + String(repeating: "?,", count: 9) + "?)")
        let stateStatement = try db.prepare(
            "INSERT INTO state_tokens VALUES(?,?,?,?,'EXACT_OR_UNDERSCORE_PREFIX_V1_PRESENTATION_ONLY',?)")
        let digestStatement = try db.prepare("INSERT INTO digest_occurrences VALUES(?,?,?,?,?)")
        for record in scan.records {
            recordStatement.reset()
            try recordStatement.bind(1, int: record.ordinal)
            try recordStatement.bind(2, text: PinnedLedgerProjectionV1.sourceSHA256)
            try recordStatement.bind(3, optionalInt: record.sectionOrdinal)
            try recordStatement.bind(4, int: record.fenceOrdinal)
            try recordStatement.bind(5, int: record.ordinalInFence)
            try recordStatement.bind(6, int: record.lineNumber)
            try recordStatement.bind(7, int: record.byteOffset)
            try recordStatement.bind(8, int: record.raw.count)
            try recordStatement.bind(9, int: 1)
            try recordStatement.bind(10, data: record.raw)
            try recordStatement.bind(11, text: record.rawSHA256NoLF)
            try recordStatement.bind(12, text: record.rawSHA256WithLF)
            try recordStatement.bind(13, text: record.canonicalState)
            try recordStatement.bind(14, text: record.canonicalJSONSHA256)
            try recordStatement.bind(15, text: record.schema)
            try recordStatement.bind(16, text: record.status)
            try recordStatement.bind(17, int: record.payloadPresent ? 1 : 0)
            try recordStatement.bind(18, text: record.payloadHashRule)
            try recordStatement.bind(19, text: record.declaredPayloadSHA256)
            try recordStatement.bind(20, text: record.computedPayloadSHA256)
            try recordStatement.bind(21, text: record.payloadHashState)
            try recordStatement.stepDone()

            for node in record.nodes {
                nodeStatement.reset()
                try nodeStatement.bind(1, int: record.ordinal)
                try nodeStatement.bind(2, text: node.pointer)
                try nodeStatement.bind(3, text: node.parentPointer)
                try nodeStatement.bind(4, int: node.childOrdinal)
                try nodeStatement.bind(5, text: node.kind)
                try nodeStatement.bind(6, text: node.decodedText)
                try nodeStatement.bind(7, int: node.relativeByteOffset)
                try nodeStatement.bind(8, int: node.byteCount)
                try nodeStatement.bind(9, text: node.rawSHA256)
                try nodeStatement.bind(10, int: node.childCount)
                try nodeStatement.stepDone()
            }
            for state in record.states {
                stateStatement.reset()
                try stateStatement.bind(1, int: record.ordinal)
                try stateStatement.bind(2, text: state.pointer)
                try stateStatement.bind(3, text: state.exactValue)
                try stateStatement.bind(4, text: state.stateClass)
                try stateStatement.bind(5, int: record.canonicalState == "CANONICAL_EXACT" ? 1 : 0)
                try stateStatement.stepDone()
            }
            for digest in record.digests {
                digestStatement.reset()
                try digestStatement.bind(1, int: record.ordinal)
                try digestStatement.bind(2, text: digest.pointer)
                try digestStatement.bind(3, int: digest.widthBits)
                try digestStatement.bind(4, text: digest.exactHex)
                try digestStatement.bind(5, text: digest.declaredAlgorithm)
                try digestStatement.stepDone()
            }
        }

        let graphNodeStatement = try db.prepare("INSERT INTO graph_nodes VALUES(?,?,?,?,?,?,0)")
        for node in graph.nodes {
            graphNodeStatement.reset()
            try graphNodeStatement.bind(1, text: node.id)
            try graphNodeStatement.bind(2, text: node.kind)
            try graphNodeStatement.bind(3, text: node.canonicalKey)
            try graphNodeStatement.bind(4, text: node.label)
            try graphNodeStatement.bind(5, optionalInt: node.recordOrdinal)
            try graphNodeStatement.bind(6, text: node.jsonPointer)
            try graphNodeStatement.stepDone()
        }
        let graphEdgeStatement = try db.prepare("INSERT INTO graph_edges VALUES(?,?,?,?,?,?,?,0,0)")
        for edge in graph.edges {
            graphEdgeStatement.reset()
            try graphEdgeStatement.bind(1, text: edge.id)
            try graphEdgeStatement.bind(2, text: edge.from)
            try graphEdgeStatement.bind(3, text: edge.predicate)
            try graphEdgeStatement.bind(4, text: edge.to)
            try graphEdgeStatement.bind(5, optionalInt: edge.sourceRecordOrdinal)
            try graphEdgeStatement.bind(6, text: edge.sourceJSONPointer)
            try graphEdgeStatement.bind(7, text: edge.evidenceGrade)
            try graphEdgeStatement.stepDone()
        }

        let seal = try db.prepare("INSERT INTO projection_seal VALUES(1,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)")
        try seal.bind(1, text: projectionID)
        try seal.bind(2, text: PinnedLedgerProjectionV1.sourceSHA256)
        try seal.bind(3, text: ddlSHA256)
        try seal.bind(4, text: adapterSHA256)
        try seal.bind(5, text: extractorSHA256)
        try seal.bind(6, text: relationalExportSHA256)
        try seal.bind(7, text: graphExportSHA256)
        try seal.bind(8, int: counts.sections)
        try seal.bind(9, int: counts.fences)
        try seal.bind(10, int: counts.records)
        try seal.bind(11, int: counts.canonicalRecords)
        try seal.bind(12, int: counts.legacyRecords)
        try seal.bind(13, int: counts.jsonNodes)
        try seal.bind(14, int: counts.stateTokens)
        try seal.bind(15, int: counts.digestOccurrences)
        try seal.bind(16, int: counts.graphNodes)
        try seal.bind(17, int: counts.graphEdges)
        try seal.stepDone()
        try db.execute("COMMIT")
    } catch {
        try? db.execute("ROLLBACK")
        throw error
    }
    try require(try db.scalarText("PRAGMA quick_check") == "ok", "SQLITE_QUICK_CHECK")
    try require(try db.scalarInt("SELECT count(*) FROM pragma_foreign_key_check") == 0, "SQLITE_FOREIGN_KEY_CHECK")
    return try db.serialized()
}

private func makeGraph(_ scan: LedgerScanResult) -> BuiltGraph {
    var nodes: [String: BuiltGraphNode] = [:]
    var edges: [String: BuiltGraphEdge] = [:]

    @discardableResult
    func node(
        kind: String,
        key: String,
        label: String,
        recordOrdinal: Int? = nil,
        pointer: String? = nil
    ) -> String {
        let id = identityHash(["node", kind, key])
        nodes[key] = .init(
            id: id,
            kind: kind,
            canonicalKey: key,
            label: label,
            recordOrdinal: recordOrdinal,
            jsonPointer: pointer)
        return id
    }

    func edge(
        from: String,
        predicate: String,
        to: String,
        recordOrdinal: Int? = nil,
        pointer: String? = nil,
        grade: String
    ) {
        let id = identityHash([
            "edge", from, predicate, to,
            recordOrdinal.map(String.init) ?? "",
            pointer ?? "",
            grade,
        ])
        edges[id] = .init(
            id: id,
            from: from,
            predicate: predicate,
            to: to,
            sourceRecordOrdinal: recordOrdinal,
            sourceJSONPointer: pointer,
            evidenceGrade: grade)
    }

    let sourceID = node(
        kind: "SOURCE",
        key: "source:" + PinnedLedgerProjectionV1.sourceSHA256,
        label: "Ledger through CRS32")
    var sectionIDs: [Int: String] = [:]
    for section in scan.sections {
        let id = node(
            kind: "SECTION",
            key: "section:\(PinnedLedgerProjectionV1.sourceSHA256):\(section.ordinal)",
            label: section.headingText)
        sectionIDs[section.ordinal] = id
        edge(from: sourceID, predicate: "SOURCE_CONTAINS_SECTION", to: id, grade: "STRUCTURAL_EXACT")
    }
    for record in scan.records {
        let recordID = node(
            kind: "RECORD",
            key: "record:\(PinnedLedgerProjectionV1.sourceSHA256):\(record.byteOffset):\(record.rawSHA256NoLF)",
            label: record.status ?? record.schema ?? "Record \(record.ordinal)",
            recordOrdinal: record.ordinal)
        if let sectionOrdinal = record.sectionOrdinal, let sectionID = sectionIDs[sectionOrdinal] {
            edge(
                from: sectionID,
                predicate: "SECTION_CONTAINS_RECORD",
                to: recordID,
                recordOrdinal: record.ordinal,
                grade: "STRUCTURAL_EXACT")
        }
        for state in record.states {
            let stateID = node(
                kind: "STATE",
                key: "state:\(record.ordinal):\(state.pointer):\(state.exactValue)",
                label: state.exactValue,
                recordOrdinal: record.ordinal,
                pointer: state.pointer)
            edge(
                from: recordID,
                predicate: "RECORD_CONTAINS_STATE",
                to: stateID,
                recordOrdinal: record.ordinal,
                pointer: state.pointer,
                grade: "STRUCTURAL_EXACT")
        }
        for digest in record.digests {
            let digestID = node(
                kind: "DIGEST",
                key: "digest:\(digest.widthBits):\(digest.exactHex)",
                label: digest.exactHex)
            edge(
                from: recordID,
                predicate: "RECORD_MENTIONS_DIGEST",
                to: digestID,
                recordOrdinal: record.ordinal,
                pointer: digest.pointer,
                grade: "LEXICAL_EQUALITY_ONLY")
        }
        for (predicate, digest) in [
            ("RECORD_HASHES_TO", record.rawSHA256NoLF),
            ("RECORD_WITH_LF_HASHES_TO", record.rawSHA256WithLF),
        ] {
            let digestID = node(kind: "DIGEST", key: "digest:256:\(digest)", label: digest)
            edge(
                from: recordID,
                predicate: predicate,
                to: digestID,
                recordOrdinal: record.ordinal,
                grade: "COMPUTED_SHA256_EXACT")
        }
        if let payload = record.computedPayloadSHA256 {
            let digestID = node(kind: "DIGEST", key: "digest:256:\(payload)", label: payload)
            edge(
                from: recordID,
                predicate: "PAYLOAD_HASHES_TO",
                to: digestID,
                recordOrdinal: record.ordinal,
                pointer: "/payload",
                grade: "COMPUTED_SHA256_EXACT")
        }
    }
    return .init(
        nodes: nodes.values.sorted { $0.id < $1.id },
        edges: edges.values.sorted { $0.id < $1.id })
}

private func projectionIdentity(
    ddlSHA256: String,
    adapterSHA256: String,
    extractorSHA256: String
) -> String {
    let span = LedgerJSONSpan(lowerBound: 0, upperBound: 0)
    return ledgerSHA256(ledgerCanonicalObject([
        "adapter_manifest_sha256": .string(adapterSHA256, span),
        "ddl_sha256": .string(ddlSHA256, span),
        "extractor_semantics_sha256": .string(extractorSHA256, span),
        "projection_schema": .string(projectionSchema, span),
        "source_bytes": .number(String(PinnedLedgerProjectionV1.sourceBytes), span),
        "source_sha256": .string(PinnedLedgerProjectionV1.sourceSHA256, span),
    ]))
}

private func identityHash(_ fields: [String]) -> String {
    let span = LedgerJSONSpan(lowerBound: 0, upperBound: 0)
    return ledgerSHA256(LedgerJSONValue.array(fields.map { .string($0, span) }, span).canonicalData())
}

private struct SemanticHasher {
    var data = Data()

    mutating func append(table: String, fields: [String?]) {
        appendField(table)
        for field in fields {
            if let field { appendField(field) } else { appendField(nil) }
        }
        data.append(0x0a)
    }

    private mutating func appendField(_ value: String?) {
        if let value {
            let bytes = Data(value.utf8)
            data.append(contentsOf: String(bytes.count).utf8)
            data.append(0x3a)
            data.append(bytes)
        } else {
            data.append(contentsOf: "-1:".utf8)
        }
        data.append(0x00)
    }
}

private func relationalExportHash(scan: LedgerScanResult) -> String {
    var hasher = SemanticHasher()
    for section in scan.sections {
        hasher.append(table: "sections", fields: [
            String(section.ordinal), String(section.level), String(section.headingLine),
            String(section.headingByteOffset), String(section.contentEndByteOffset),
            section.headingText, section.headingSHA256,
        ])
    }
    for record in scan.records {
        hasher.append(table: "appendix_records", fields: [
            String(record.ordinal), record.sectionOrdinal.map(String.init),
            String(record.fenceOrdinal), String(record.ordinalInFence), String(record.lineNumber),
            String(record.byteOffset), String(record.raw.count), record.rawSHA256NoLF,
            record.rawSHA256WithLF, record.canonicalState, record.canonicalJSONSHA256,
            record.schema, record.status, record.payloadHashRule, record.declaredPayloadSHA256,
            record.computedPayloadSHA256, record.payloadHashState,
        ])
        for node in record.nodes {
            hasher.append(table: "json_nodes", fields: [
                String(record.ordinal), node.pointer, node.parentPointer,
                String(node.childOrdinal), node.kind, node.decodedText,
                String(node.relativeByteOffset), String(node.byteCount), node.rawSHA256,
                String(node.childCount),
            ])
        }
        for state in record.states {
            hasher.append(table: "state_tokens", fields: [
                String(record.ordinal), state.pointer, state.exactValue, state.stateClass,
                record.canonicalState == "CANONICAL_EXACT" ? "1" : "0",
            ])
        }
        for digest in record.digests {
            hasher.append(table: "digest_occurrences", fields: [
                String(record.ordinal), digest.pointer, String(digest.widthBits),
                digest.exactHex, digest.declaredAlgorithm,
            ])
        }
    }
    return ledgerSHA256(hasher.data)
}

private func graphExportHash(_ graph: BuiltGraph) -> String {
    var hasher = SemanticHasher()
    for node in graph.nodes {
        hasher.append(table: "graph_nodes", fields: [
            node.id, node.kind, node.canonicalKey, node.label,
            node.recordOrdinal.map(String.init), node.jsonPointer,
        ])
    }
    for edge in graph.edges {
        hasher.append(table: "graph_edges", fields: [
            edge.id, edge.from, edge.predicate, edge.to,
            edge.sourceRecordOrdinal.map(String.init), edge.sourceJSONPointer,
            edge.evidenceGrade,
        ])
    }
    return ledgerSHA256(hasher.data)
}

private func makeSidecar(
    projectionID: String,
    database: Data,
    databaseSHA256: String,
    ddlSHA256: String,
    adapterSHA256: String,
    extractorSHA256: String,
    relationalExportSHA256: String,
    graphExportSHA256: String,
    counts: LedgerProjectionCounts
) -> Data {
    let span = LedgerJSONSpan(lowerBound: 0, upperBound: 0)
    let countObject = LedgerJSONValue.object([
        .init(key: "canonical_records", value: .number(String(counts.canonicalRecords), span)),
        .init(key: "digest_occurrences", value: .number(String(counts.digestOccurrences), span)),
        .init(key: "fences", value: .number(String(counts.fences), span)),
        .init(key: "graph_edges", value: .number(String(counts.graphEdges), span)),
        .init(key: "graph_nodes", value: .number(String(counts.graphNodes), span)),
        .init(key: "json_nodes", value: .number(String(counts.jsonNodes), span)),
        .init(key: "legacy_records", value: .number(String(counts.legacyRecords), span)),
        .init(key: "records", value: .number(String(counts.records), span)),
        .init(key: "sections", value: .number(String(counts.sections), span)),
        .init(key: "state_tokens", value: .number(String(counts.stateTokens), span)),
    ], span)
    let sourceObject = LedgerJSONValue.object([
        .init(key: "blob", value: .string(PinnedLedgerProjectionV1.sourceBlob, span)),
        .init(key: "bytes", value: .number(String(PinnedLedgerProjectionV1.sourceBytes), span)),
        .init(key: "commit", value: .string(PinnedLedgerProjectionV1.sourceCommit, span)),
        .init(key: "lf_count", value: .number(String(PinnedLedgerProjectionV1.sourceLFCount), span)),
        .init(key: "sha256", value: .string(PinnedLedgerProjectionV1.sourceSHA256, span)),
        .init(key: "tree", value: .string(PinnedLedgerProjectionV1.sourceTree, span)),
    ], span)
    var result = ledgerCanonicalObject([
        "adapter_manifest_sha256": .string(adapterSHA256, span),
        "authority_vector": .string("00000000", span),
        "authoritative": .bool(false, span),
        "counts": countObject,
        "database_bytes": .number(String(database.count), span),
        "database_sha256": .string(databaseSHA256, span),
        "ddl_sha256": .string(ddlSHA256, span),
        "extractor_semantics_sha256": .string(extractorSHA256, span),
        "graph_export_sha256": .string(graphExportSHA256, span),
        "may_feed_controller": .bool(false, span),
        "projection_id": .string(projectionID, span),
        "relational_export_sha256": .string(relationalExportSHA256, span),
        "schema": .string("ergentics_ledger_projection_sidecar_v1", span),
        "source": sourceObject,
        "status": .string("PASS_NONAUTHORITATIVE_PROJECTION", span),
    ])
    result.append(0x0a)
    return result
}

private func resourceData(name: String, extension extensionName: String) throws -> Data {
    guard let url = Bundle.module.url(forResource: name, withExtension: extensionName) else {
        throw rejection("RESOURCE_ABSENT", "\(name).\(extensionName)")
    }
    do { return try Data(contentsOf: url, options: [.mappedIfSafe]) }
    catch { throw rejection("RESOURCE_READ", String(describing: error)) }
}

private final class ExclusiveProjectionRoot {
    let path: String
    let parentPath: String
    let leaf: String
    let parentDescriptor: Int32
    let rootDescriptor: Int32
    let initialRootState: stat
    private var heldLeaves: [String: (descriptor: Int32, state: stat, sha256: String)] = [:]

    init(path: String) throws {
        self.path = path
        let url = URL(fileURLWithPath: path)
        parentPath = url.deletingLastPathComponent().path
        leaf = url.lastPathComponent
        try require(path.hasPrefix("/private/tmp/"), "OUTPUT_NOT_OUTSIDE_REPOSITORY")
        try require(!leaf.isEmpty && !leaf.contains("/"), "OUTPUT_LEAF")

        var resolved = [CChar](repeating: 0, count: Int(PATH_MAX))
        guard realpath(parentPath, &resolved) != nil else {
            throw rejection("OUTPUT_PARENT_REALPATH", String(cString: strerror(errno)))
        }
        let resolvedPath = String(
            decoding: resolved.prefix { $0 != 0 }.map { UInt8(bitPattern: $0) },
            as: UTF8.self)
        try require(resolvedPath == parentPath, "OUTPUT_PARENT_ALIAS")
        let openedParent = Darwin.open(
            parentPath,
            O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW_ANY)
        guard openedParent >= 0 else {
            throw rejection("OUTPUT_PARENT_OPEN", String(cString: strerror(errno)))
        }
        var closeParent = true
        defer { if closeParent { _ = Darwin.close(openedParent) } }
        var existing = stat()
        errno = 0
        let prior = fstatat(openedParent, leaf, &existing, AT_SYMLINK_NOFOLLOW)
        try require(prior != 0 && errno == ENOENT, "OUTPUT_ROOT_NOT_ABSENT")
        guard mkdirat(openedParent, leaf, 0o700) == 0 else {
            throw rejection("OUTPUT_ROOT_MKDIR", String(cString: strerror(errno)))
        }
        let openedRoot = Darwin.openat(
            openedParent,
            leaf,
            O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW_ANY)
        guard openedRoot >= 0 else {
            throw rejection("OUTPUT_ROOT_OPEN", String(cString: strerror(errno)))
        }
        var closeRoot = true
        defer { if closeRoot { _ = Darwin.close(openedRoot) } }
        var state = stat()
        guard fstat(openedRoot, &state) == 0 else {
            throw rejection("OUTPUT_ROOT_FSTAT", String(cString: strerror(errno)))
        }
        try require((state.st_mode & S_IFMT) == S_IFDIR, "OUTPUT_ROOT_TYPE")
        try require((state.st_mode & 0o7777) == 0o700, "OUTPUT_ROOT_MODE")
        try require(state.st_uid == geteuid(), "OUTPUT_ROOT_OWNER")
        parentDescriptor = openedParent
        rootDescriptor = openedRoot
        initialRootState = state
        try syncDirectory(openedParent)
        closeRoot = false
        closeParent = false
    }

    deinit {
        for value in heldLeaves.values { _ = Darwin.close(value.descriptor) }
        _ = Darwin.close(rootDescriptor)
        _ = Darwin.close(parentDescriptor)
    }

    func writeExclusive(leaf: String, data: Data) throws {
        try require(!leaf.isEmpty && !leaf.contains("/"), "OUTPUT_FILE_LEAF")
        let descriptor = Darwin.openat(
            rootDescriptor,
            leaf,
            O_RDWR | O_CREAT | O_EXCL | O_CLOEXEC | O_NOFOLLOW_ANY,
            mode_t(0o600))
        guard descriptor >= 0 else {
            throw rejection("OUTPUT_FILE_CREATE", "\(leaf):\(String(cString: strerror(errno)))")
        }
        var closeOnFailure = true
        defer { if closeOnFailure { _ = Darwin.close(descriptor) } }
        var offset = 0
        while offset < data.count {
            let result = data.withUnsafeBytes { raw -> Int in
                guard let base = raw.baseAddress else { return -1 }
                return Darwin.write(descriptor, base.advanced(by: offset), data.count - offset)
            }
            if result > 0 { offset += result }
            else if result < 0 && errno == EINTR { continue }
            else { throw rejection("OUTPUT_FILE_WRITE", "\(leaf):\(String(cString: strerror(errno)))") }
        }
        try syncFile(descriptor)
        guard fchmod(descriptor, 0o400) == 0 else {
            throw rejection("OUTPUT_FILE_CHMOD", String(cString: strerror(errno)))
        }
        var state = stat()
        guard fstat(descriptor, &state) == 0 else {
            throw rejection("OUTPUT_FILE_FSTAT", String(cString: strerror(errno)))
        }
        try require((state.st_mode & S_IFMT) == S_IFREG, "OUTPUT_FILE_TYPE")
        try require((state.st_mode & 0o7777) == 0o400, "OUTPUT_FILE_MODE")
        try require(state.st_nlink == 1, "OUTPUT_FILE_LINK_COUNT")
        try require(state.st_size == off_t(data.count), "OUTPUT_FILE_SIZE")
        try syncFile(descriptor)
        heldLeaves[leaf] = (descriptor, state, ledgerSHA256(data))
        closeOnFailure = false
        try syncDirectory(rootDescriptor)
    }

    func seal(expectedLeaves: [String]) throws {
        try revalidateLeaves(expectedLeaves)
        guard fchmod(rootDescriptor, 0o500) == 0 else {
            throw rejection("OUTPUT_ROOT_SEAL_MODE", String(cString: strerror(errno)))
        }
        try syncDirectory(rootDescriptor)
        try syncDirectory(parentDescriptor)
        var sealedRoot = stat()
        guard fstat(rootDescriptor, &sealedRoot) == 0 else {
            throw rejection("OUTPUT_ROOT_SEALED_FSTAT", String(cString: strerror(errno)))
        }
        try require((sealedRoot.st_mode & 0o7777) == 0o500, "OUTPUT_ROOT_FINAL_MODE")
        try require(
            sealedRoot.st_dev == initialRootState.st_dev && sealedRoot.st_ino == initialRootState.st_ino,
            "OUTPUT_ROOT_IDENTITY_DRIFT")

        try revalidateLeaves(expectedLeaves)
        var finalRoot = stat()
        var namedRoot = stat()
        guard fstat(rootDescriptor, &finalRoot) == 0,
              lstat(path, &namedRoot) == 0
        else { throw rejection("OUTPUT_ROOT_REVALIDATE", String(cString: strerror(errno))) }
        try require(outputSameState(sealedRoot, finalRoot), "OUTPUT_ROOT_POSTSEAL_DRIFT")
        try require(outputSameState(finalRoot, namedRoot), "OUTPUT_ROOT_REBOUND")
    }

    private func revalidateLeaves(_ expectedLeaves: [String]) throws {
        let actual = try directoryEntries(rootDescriptor).sorted()
        try require(actual == expectedLeaves.sorted(), "OUTPUT_INVENTORY")
        try require(heldLeaves.keys.sorted() == expectedLeaves.sorted(), "OUTPUT_HELD_LEAVES")
        for leaf in expectedLeaves {
            guard let expected = heldLeaves[leaf] else { throw rejection("OUTPUT_HELD_LEAF_ABSENT", leaf) }
            var held = stat()
            var named = stat()
            guard fstat(expected.descriptor, &held) == 0,
                  fstatat(rootDescriptor, leaf, &named, AT_SYMLINK_NOFOLLOW) == 0
            else { throw rejection("OUTPUT_LEAF_FINAL_REVALIDATE", leaf) }
            try require(outputSameState(expected.state, held), "OUTPUT_LEAF_DRIFT", leaf)
            try require(outputSameState(held, named), "OUTPUT_LEAF_REBOUND", leaf)
            let bytes = try outputPreadExact(descriptor: expected.descriptor, count: Int(held.st_size))
            try require(ledgerSHA256(bytes) == expected.sha256, "OUTPUT_LEAF_FINAL_SHA", leaf)
        }
    }
}

private func directoryEntries(_ descriptor: Int32) throws -> [String] {
    let copied = dup(descriptor)
    guard copied >= 0 else { throw rejection("OUTPUT_ROOT_DUP", String(cString: strerror(errno))) }
    guard let directory = fdopendir(copied) else {
        _ = Darwin.close(copied)
        throw rejection("OUTPUT_ROOT_FDOPENDIR", String(cString: strerror(errno)))
    }
    defer { closedir(directory) }
    rewinddir(directory)
    var result: [String] = []
    errno = 0
    while let entry = readdir(directory) {
        let name = withUnsafePointer(to: &entry.pointee.d_name) {
            $0.withMemoryRebound(to: CChar.self, capacity: Int(NAME_MAX) + 1) {
                String(cString: $0)
            }
        }
        if name != "." && name != ".." { result.append(name) }
        errno = 0
    }
    try require(errno == 0, "OUTPUT_ROOT_READDIR", String(cString: strerror(errno)))
    return result
}

private func syncFile(_ descriptor: Int32) throws {
    guard fsync(descriptor) == 0 else { throw rejection("FSYNC", String(cString: strerror(errno))) }
    guard fcntl(descriptor, F_FULLFSYNC) == 0 else {
        throw rejection("FULLFSYNC", String(cString: strerror(errno)))
    }
}

private func syncDirectory(_ descriptor: Int32) throws {
    guard fsync(descriptor) == 0 else {
        throw rejection("DIRECTORY_FSYNC", String(cString: strerror(errno)))
    }
}

private func outputSameState(_ lhs: stat, _ rhs: stat) -> Bool {
    lhs.st_dev == rhs.st_dev && lhs.st_ino == rhs.st_ino && lhs.st_mode == rhs.st_mode &&
        lhs.st_nlink == rhs.st_nlink && lhs.st_uid == rhs.st_uid && lhs.st_gid == rhs.st_gid &&
        lhs.st_size == rhs.st_size && lhs.st_gen == rhs.st_gen &&
        lhs.st_mtimespec.tv_sec == rhs.st_mtimespec.tv_sec &&
        lhs.st_mtimespec.tv_nsec == rhs.st_mtimespec.tv_nsec &&
        lhs.st_ctimespec.tv_sec == rhs.st_ctimespec.tv_sec &&
        lhs.st_ctimespec.tv_nsec == rhs.st_ctimespec.tv_nsec
}

private func outputPreadExact(descriptor: Int32, count: Int) throws -> Data {
    var data = Data(count: count)
    var completed = 0
    while completed < count {
        let result = data.withUnsafeMutableBytes { raw -> Int in
            guard let base = raw.baseAddress else { return -1 }
            return pread(descriptor, base.advanced(by: completed), count - completed, off_t(completed))
        }
        if result > 0 { completed += result }
        else if result < 0 && errno == EINTR { continue }
        else { throw rejection("OUTPUT_LEAF_FINAL_PREAD") }
    }
    return data
}
