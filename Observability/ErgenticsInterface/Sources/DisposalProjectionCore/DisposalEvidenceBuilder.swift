import Foundation

private let disposalEvidenceExtractorSemantics = """
ergentics-disposal-evidence-v1
source=exact-canonical-jsonl-prefix-or-exact-r19-observability-jsonl-prefix
frames=terminal-lf;ordinal-contiguous;lf-frame-sha-chain;payload-sha-exact
json=rfc8259;duplicate-keys-rejected;number-lexeme-preserved
authority=00000000;authoritative=0;may-feed-controller=0;prose-may-supply-fact=0
completion=incomplete-prefix-explicit;no-pass-inference
identity=artifact-content-addressed;stream=invocation-epoch-kind-logical-path-stable;frame=stream-ordinal-lf-sha-prefix-stable
missing-evidence-id=invocation-kind-target-frame-reason-scope-content-addressed
reap=external-processes-none-not-parent
typed-process-evidence=exact-event-type-plus-adapter-schema-plus-json-pointer-only
unknown-schema=raw-only;missing-held-artifact-bytes=abstain;no-inference
adapter-coverage=one-row-per-frame;unknown-lifecycle=frame-prefix-abstain
legacy-r19-observability=sealed-presentation-source-not-disposal-terminal;direct-exact-byte-adapter;no-synthetic-events
legacy-r19-energy=parsed-counters-only;source-cpu-derived-fields-not-promoted;raw-rusage-buffers-unavailable
target-provenance=exact-first-source-frame-and-ordinal
conservation-set-schema=ergentics-disposal-conservation-set-commitment-v1
conservation-set-hash=sha256;magic=ERGENTICS_DISPOSAL_MERKLE_ID_V1;domain-length-u64be;component-count-u64be;component-length-u64be
conservation-set-domain=ERGENTICS_DISPOSAL_CONSERVATION_SET_LENGTH_FRAMED_V1;bound-as-first-component-of-obligation-leaf-node-proof
conservation-set-obligation-key=commitment-frame-lf-sha256,target-role,target-form,pid,uniqueid,idversion,operation,numeric-argument,signal,budget
conservation-set-order=obligation-key-sha256-raw-ascending;duplicates-rejected;nonzero-full-current-obligation-set
conservation-set-tree=rfc6962-largest-power-of-two-split-only;ergentics-length-framed-leaf-node-hashes;no-odd-duplication
conservation-set-temporal=explicit-prior-frame-only;exact-invocation-epoch-purpose-scope-root-count-policy
conservation-set-resolution=explicit-obligation-membership-to-same-generation-conservation-mapping-only
"""

func buildDisposalEvidence(
    request: DisposalProjectionMaterialRequest,
    journal: DisposalDecodedJournal,
    resources: DisposalProjectionRuleResources
) throws -> DisposalEvidenceMaterial {
    try disposalRequireProjection(!journal.frames.isEmpty, "EVIDENCE_EMPTY_JOURNAL")
    try disposalRequireProjection(
        !request.journalLogicalPath.isEmpty,
        "EVIDENCE_LOGICAL_PATH_EMPTY")
    if let predecessor = request.recordedPredecessorProjectionID {
        try disposalRequireProjection(
            disposalIsLowerHex(predecessor, count: 64),
            "EVIDENCE_PREDECESSOR_ID")
    }

    let identity = try DisposalProjectionSourceAdapter.identity(of: journal)
    let invocationID = identity.invocationID
    try disposalRequireProjection(
        disposalIsLowerHex(invocationID, count: 64),
        "EVIDENCE_INVOCATION_ID",
        frameOrdinal: 0)
    let arcLabel = identity.arcLabel
    let epochLabel = identity.epochLabel
    let consumptionState = identity.consumptionState
    try disposalRequireProjection(
        ["UNCONSUMED", "CONSUMED_SOURCE_DECLARED", "ABSTAIN_NOT_RECORDED"]
            .contains(consumptionState),
        "EVIDENCE_CONSUMPTION_STATE",
        frameOrdinal: 0)
    let retryAuthorized = identity.retryAuthorized
    try disposalRequireProjection(
        retryAuthorized == false,
        "EVIDENCE_RETRY_AUTHORIZED",
        frameOrdinal: 0)

    let controlCommit = identity.controlCommit
    let controlTree = identity.controlTree
    let implementationCommit = identity.implementationCommit
    let implementationTree = identity.implementationTree
    for (value, code) in [
        (controlCommit, "EVIDENCE_CONTROL_COMMIT"),
        (controlTree, "EVIDENCE_CONTROL_TREE"),
        (implementationCommit, "EVIDENCE_IMPLEMENTATION_COMMIT"),
        (implementationTree, "EVIDENCE_IMPLEMENTATION_TREE"),
    ] {
        if let value {
            try disposalRequireProjection(
                disposalIsLowerHex(value, count: 40),
                code,
                frameOrdinal: 0)
        }
    }

    let ddl = resources.evidenceDDL
    let adapters = resources.adapters
    let lattice = resources.lattice
    try disposalRequireProjection(adapters.last == 0x0a, "EVIDENCE_ADAPTER_LF")
    try disposalRequireProjection(lattice.last == 0x0a, "EVIDENCE_LATTICE_LF")
    let ddlSHA256 = disposalSHA256(ddl)
    let adapterSHA256 = disposalSHA256(adapters)
    let latticeSHA256 = disposalSHA256(lattice)
    let extractorSHA256 = disposalSHA256(Data(disposalEvidenceExtractorSemantics.utf8))
    let artifactID = disposalID(
        "disposal-input-artifact-v1",
        [identity.artifactRole, request.journalLogicalPath, journal.sourceSHA256])
    let streamID = disposalID(
        "disposal-prefix-stable-stream-v1",
        [invocationID, epochLabel, identity.streamKind, request.journalLogicalPath])
    let frameIDs = journal.frames.map {
        disposalID(
            "disposal-frame-v1",
            [streamID, String($0.ordinal), $0.rawWithLFSHA256])
    }
    let inputInventorySHA256 = disposalID(
        "disposal-input-inventory-v1",
        [artifactID, journal.sourceSHA256, String(journal.source.count)])
    let relationalExportSHA256 = disposalEvidenceRelationalExport(
        artifactID: artifactID,
        invocationID: invocationID,
        streamID: streamID,
        journal: journal,
        frameIDs: frameIDs)
    let projectionID = disposalID(
        "ergentics-disposal-evidence-projection-v1",
        [
            journal.sourceSHA256,
            ddlSHA256,
            adapterSHA256,
            latticeSHA256,
            extractorSHA256,
            relationalExportSHA256,
            request.recordedPredecessorProjectionID ?? "ABSENT",
        ])

    let database = try DisposalSQLiteConnection()
    guard let ddlText = String(data: ddl, encoding: .utf8) else {
        throw DisposalProjectionRejection(code: "EVIDENCE_DDL_UTF8")
    }
    try database.execute(ddlText)
    let applicationID = try database.scalarInt("PRAGMA application_id")
    let userVersion = try database.scalarInt("PRAGMA user_version")
    try disposalRequireProjection(
        applicationID == 1_162_105_649,
        "EVIDENCE_APPLICATION_ID")
    try disposalRequireProjection(
        userVersion == 1,
        "EVIDENCE_USER_VERSION")
    try database.execute("BEGIN IMMEDIATE")
    do {
        let policy = try database.prepare(
            "INSERT INTO projection_policy VALUES(1,?,?,?,?,?,?)")
        try policy.bind(1, text: "ergentics_disposal_evidence_v1")
        try policy.bind(2, text: "00000000")
        try policy.bind(3, int: 0)
        try policy.bind(4, int: 0)
        try policy.bind(5, int: 0)
        try policy.bind(6, text: "EMPTY_OR_EXPLICIT_ABSTAIN_NO_STALE_FALLBACK")
        try policy.stepDone()

        let artifact = try database.prepare(
            "INSERT INTO input_artifacts VALUES(" +
                String(repeating: "?,", count: 14) + "?)")
        try artifact.bind(1, text: artifactID)
        try artifact.bind(2, text: identity.artifactRole)
        try artifact.bind(3, text: request.journalLogicalPath)
        try artifact.bind(4, text: "LEDGER_EMBEDDED_COPY")
        try artifact.bind(5, text: "CANONICAL_JOURNAL_FRAME_EXACT")
        try artifact.bind(6, text: nil)
        try artifact.bind(7, text: nil)
        try artifact.bind(8, text: nil)
        try artifact.bind(9, optionalInt: nil)
        try artifact.bind(10, optionalInt: nil)
        try artifact.bind(11, text: nil)
        try artifact.bind(12, optionalInt: nil)
        try artifact.bind(13, int: journal.source.count)
        try artifact.bind(14, text: journal.sourceSHA256)
        try artifact.bind(15, data: journal.source)
        try artifact.stepDone()

        let invocation = try database.prepare(
            "INSERT INTO invocations VALUES(" + String(repeating: "?,", count: 10) + "?)")
        try invocation.bind(1, text: invocationID)
        try invocation.bind(2, text: arcLabel)
        try invocation.bind(3, text: epochLabel)
        try invocation.bind(4, text: artifactID)
        try invocation.bind(5, text: controlCommit)
        try invocation.bind(6, text: controlTree)
        try invocation.bind(7, text: implementationCommit)
        try invocation.bind(8, text: implementationTree)
        try invocation.bind(9, text: consumptionState)
        try invocation.bind(10, int: 0)
        try invocation.bind(11, text: "00000000")
        try invocation.stepDone()

        let streamExact = try database.prepare(
            "INSERT INTO streams(" +
                "stream_id,invocation_id,source_artifact_id,stream_kind,completeness," +
                "stream_sha256,stream_bytes) VALUES(?,?,?,?,?,?,?)")
        try streamExact.bind(1, text: streamID)
        try streamExact.bind(2, text: invocationID)
        try streamExact.bind(3, text: artifactID)
        try streamExact.bind(4, text: identity.streamKind)
        try streamExact.bind(
            5,
            text: journal.sourceSealed ? "COMPLETE_SEALED" : "RETAINED_PREFIX_NONTERMINAL")
        try streamExact.bind(6, text: journal.sourceSHA256)
        try streamExact.bind(7, int: journal.source.count)
        try streamExact.stepDone()

        let frameStatement = try database.prepare(
            "INSERT INTO frames VALUES(" + String(repeating: "?,", count: 15) + "?)")
        let nodeStatement = try database.prepare(
            "INSERT INTO json_nodes VALUES(" + String(repeating: "?,", count: 9) + "?)")
        for frame in journal.frames {
            frameStatement.reset()
            try frameStatement.bind(1, text: frameIDs[frame.ordinal])
            try frameStatement.bind(2, text: streamID)
            try frameStatement.bind(3, text: artifactID)
            try frameStatement.bind(4, int: frame.ordinal)
            try frameStatement.bind(
                5,
                text: frame.ordinal == 0 ? nil : frameIDs[frame.ordinal - 1])
            try frameStatement.bind(6, text: request.journalLogicalPath)
            try frameStatement.bind(7, int: frame.journalByteOffset)
            try frameStatement.bind(8, int: frame.raw.count)
            try frameStatement.bind(9, int: 1)
            try frameStatement.bind(10, data: frame.raw)
            try frameStatement.bind(11, text: frame.rawSHA256)
            try frameStatement.bind(12, text: frame.rawWithLFSHA256)
            try frameStatement.bind(13, text: frame.rawSHA256)
            try frameStatement.bind(14, text: frame.payloadSHA256)
            try frameStatement.bind(15, text: frame.schema)
            try frameStatement.bind(16, text: frame.status)
            try frameStatement.stepDone()

            for node in frame.nodes {
                nodeStatement.reset()
                try nodeStatement.bind(1, text: frameIDs[frame.ordinal])
                try nodeStatement.bind(2, text: node.jsonPointer)
                try nodeStatement.bind(3, text: node.parentPointer)
                try nodeStatement.bind(4, int: node.childOrdinal)
                try nodeStatement.bind(5, text: node.kind.rawValue)
                try nodeStatement.bind(6, text: disposalDecodedText(node.scalar))
                try nodeStatement.bind(7, int: node.frameRelativeByteOffset)
                try nodeStatement.bind(8, int: node.byteCount)
                try nodeStatement.bind(9, text: node.rawSHA256)
                try nodeStatement.bind(10, int: node.childCount)
                try nodeStatement.stepDone()
            }
        }

        let typedEvidence = try DisposalTypedProcessEvidence.insert(
            database: database,
            journal: journal,
            invocationID: invocationID,
            epochLabel: epochLabel,
            adapterManifestSHA256: adapterSHA256,
            adapterManifest: adapters,
            frameIDs: frameIDs)
        let riskWindowIDs = try insertDisposalRiskWindows(
            database: database,
            journal: journal,
            frameIDs: frameIDs)
        let missingEvidenceCount = try insertDisposalMissingEvidence(
            database: database,
            journal: journal,
            invocationID: invocationID,
            frameIDs: frameIDs,
            typedMissingEvidence: typedEvidence.missingEvidence)
        try insertDisposalTerminalOutcome(
            database: database,
            journal: journal,
            invocationID: invocationID,
            frameIDs: frameIDs,
            typedEvidence: typedEvidence)

        let seal = try database.prepare(
            "INSERT INTO evidence_seal(" +
                "singleton,projection_id,predecessor_projection_id,input_inventory_sha256," +
                "ddl_sha256,adapter_sha256,extractor_sha256,lattice_sha256," +
                "relational_export_sha256,high_water_frame_id,artifact_count,invocation_count," +
                "frame_count,frame_adapter_coverage_count,target_count,target_provenance_count," +
                "commitment_count,signal_call_count,wait_call_count,conservation_count," +
                "conservation_set_commitment_count,conservation_set_membership_count," +
                "conservation_set_mapping_count,risk_window_count,missing_evidence_count,authority_vector," +
                "authoritative,may_feed_controller) VALUES(" +
                String(repeating: "?,", count: 27) + "?)")
        try seal.bind(1, int: 1)
        try seal.bind(2, text: projectionID)
        try seal.bind(3, text: request.recordedPredecessorProjectionID)
        try seal.bind(4, text: inputInventorySHA256)
        try seal.bind(5, text: ddlSHA256)
        try seal.bind(6, text: adapterSHA256)
        try seal.bind(7, text: extractorSHA256)
        try seal.bind(8, text: latticeSHA256)
        try seal.bind(9, text: relationalExportSHA256)
        try seal.bind(10, text: frameIDs.last)
        try seal.bind(11, int: 1)
        try seal.bind(12, int: 1)
        try seal.bind(13, int: journal.frames.count)
        try seal.bind(14, int: typedEvidence.ids.frameAdapterCoverageIDs.count)
        try seal.bind(15, int: typedEvidence.ids.targetIDs.count)
        try seal.bind(16, int: typedEvidence.ids.targetIDs.count)
        try seal.bind(17, int: typedEvidence.ids.commitmentIDs.count)
        try seal.bind(18, int: typedEvidence.ids.signalCallIDs.count)
        try seal.bind(19, int: typedEvidence.ids.waitCallIDs.count)
        try seal.bind(20, int: typedEvidence.ids.conservationIDs.count)
        try seal.bind(21, int: typedEvidence.ids.conservationSetCommitmentIDs.count)
        try seal.bind(22, int: typedEvidence.ids.conservationSetMembershipIDs.count)
        try seal.bind(23, int: typedEvidence.ids.conservationSetMappingIDs.count)
        try seal.bind(24, int: riskWindowIDs.count)
        try seal.bind(25, int: missingEvidenceCount)
        try seal.bind(26, text: "00000000")
        try seal.bind(27, int: 0)
        try seal.bind(28, int: 0)
        try seal.stepDone()

        try database.execute("COMMIT")
        let integrityCheck = try database.scalarText("PRAGMA integrity_check")
        let foreignKeyFailures = try database.scalarInt(
            "SELECT count(*) FROM pragma_foreign_key_check")
        try disposalRequireProjection(
            integrityCheck == "ok",
            "EVIDENCE_INTEGRITY_CHECK")
        try disposalRequireProjection(
            foreignKeyFailures == 0,
            "EVIDENCE_FOREIGN_KEY_CHECK")

        let serialized = try database.serialized()
        try database.close()
        return .init(
            database: serialized,
            databaseSHA256: disposalSHA256(serialized),
            projectionID: projectionID,
            relationalExportSHA256: relationalExportSHA256,
            invocationID: invocationID,
            epochLabel: epochLabel,
            streamID: streamID,
            artifactID: artifactID,
            frameIDs: frameIDs,
            riskWindowIDs: riskWindowIDs,
            typedEvidenceIDs: typedEvidence.ids,
            missingEvidenceCount: missingEvidenceCount,
            ddlSHA256: ddlSHA256,
            adapterSHA256: adapterSHA256,
            latticeSHA256: latticeSHA256,
            extractorSHA256: extractorSHA256)
    } catch {
        try? database.execute("ROLLBACK")
        throw error
    }
}

private func disposalEvidenceRelationalExport(
    artifactID: String,
    invocationID: String,
    streamID: String,
    journal: DisposalDecodedJournal,
    frameIDs: [String]
) -> String {
    var bytes = Data()
    for value in [artifactID, invocationID, streamID, journal.sourceSHA256] {
        bytes.append(contentsOf: value.utf8)
        bytes.append(0x0a)
    }
    for frame in journal.frames {
        let fields = [
            frameIDs[frame.ordinal], String(frame.ordinal), frame.eventType.rawValue,
            frame.rawSHA256, frame.rawWithLFSHA256, frame.payloadSHA256,
            frame.previousSHA256 ?? "NULL", frame.status ?? "NULL",
        ]
        bytes.append(contentsOf: fields.joined(separator: "\t").utf8)
        bytes.append(0x0a)
        for node in frame.nodes.sorted(by: { $0.jsonPointer < $1.jsonPointer }) {
            bytes.append(contentsOf: [
                frameIDs[frame.ordinal], node.jsonPointer, node.kind.rawValue,
                disposalDecodedText(node.scalar) ?? "NULL", node.rawSHA256,
            ].joined(separator: "\t").utf8)
            bytes.append(0x0a)
        }
    }
    return disposalSHA256(bytes)
}

private func insertDisposalRiskWindows(
    database: DisposalSQLiteConnection,
    journal: DisposalDecodedJournal,
    frameIDs: [String]
) throws -> [String] {
    let statement = try database.prepare(
        "INSERT INTO risk_windows(" +
            "window_id,source_frame_id,target_id,window_kind,start_frame_id,end_frame_id," +
            "commitment_id,signal_call_id,maximum_duration_ns_text,basis,closure_state," +
            "qualification_text) VALUES(" + String(repeating: "?,", count: 11) + "?)")
    var result: [String] = []
    for frame in journal.frames where frame.eventType == .riskWindow {
        let windowKind = try frame.requiredString(at: "/payload/window_kind")
        let basis = try frame.requiredString(at: "/payload/basis")
        let closureState = try frame.requiredString(at: "/payload/closure_state")
        let qualification = try frame.requiredString(at: "/payload/qualification")
        let startOrdinal = try frame.optionalUInt64(at: "/payload/start_frame_ordinal")
        let endOrdinal = try frame.optionalUInt64(at: "/payload/end_frame_ordinal")
        let maximumDuration = try frame.optionalString(at: "/payload/maximum_duration_ns")
        if let startOrdinal {
            try disposalRequireProjection(
                startOrdinal < UInt64(frameIDs.count),
                "RISK_START_FRAME",
                frameOrdinal: frame.ordinal)
        }
        if let endOrdinal {
            try disposalRequireProjection(
                endOrdinal < UInt64(frameIDs.count),
                "RISK_END_FRAME",
                frameOrdinal: frame.ordinal)
        }
        let windowID = disposalID(
            "disposal-risk-window-v1",
            [frameIDs[frame.ordinal], windowKind, String(result.count)])
        statement.reset()
        try statement.bind(1, text: windowID)
        try statement.bind(2, text: frameIDs[frame.ordinal])
        try statement.bind(3, text: nil)
        try statement.bind(4, text: windowKind)
        try statement.bind(5, text: startOrdinal.map { frameIDs[Int($0)] })
        try statement.bind(6, text: endOrdinal.map { frameIDs[Int($0)] })
        try statement.bind(7, text: nil)
        try statement.bind(8, text: nil)
        try statement.bind(9, text: maximumDuration)
        try statement.bind(10, text: basis)
        try statement.bind(11, text: closureState)
        try statement.bind(12, text: qualification)
        try statement.stepDone()
        result.append(windowID)
    }
    return result
}

private func insertDisposalMissingEvidence(
    database: DisposalSQLiteConnection,
    journal: DisposalDecodedJournal,
    invocationID: String,
    frameIDs: [String],
    typedMissingEvidence: [DisposalTypedMissingEvidence]
) throws -> Int {
    var rows: [(String, String?, String?, String)] = []
    if !journal.isTerminal {
        let reason: String
        switch journal.sourceKind {
        case .disposalEvent:
            reason = "JOURNAL_PREFIX_NONTERMINAL"
        case .r19Observability:
            reason = journal.sourceSealed
                ? "SEALED_OBSERVABILITY_SOURCE_HAS_NO_DISPOSAL_TERMINAL"
                : "OBSERVABILITY_PREFIX_HAS_NO_DISPOSAL_TERMINAL"
        }
        rows.append(("TERMINAL_FRAME", nil, nil, reason))
    }
    for frame in journal.frames where frame.eventType == .resource {
        if frame.sourceFrameKind == .r19ObservabilitySample {
            rows.append((
                "RAW_RUSAGE_INFO_V6_464",
                frame.targetLabel,
                frameIDs[frame.ordinal],
                "LEGACY_OBSERVABILITY_RAW_464_NOT_RETAINED"))
        } else if frame.sourceFrameKind == .disposalEvent {
            let rawState = try frame.optionalString(at: "/payload/resource_sample/raw_buffer_state")
            if rawState != "RAW_464_VERIFIED" {
                rows.append((
                    "RAW_RUSAGE_INFO_V6_464",
                    frame.targetLabel,
                    frameIDs[frame.ordinal],
                    rawState == nil ? "RESOURCE_RAW_BUFFER_STATE_ABSENT" : "RESOURCE_RAW_BUFFER_NOT_VERIFIED"))
            }
        }
    }
    if journal.sourceKind == .r19Observability {
        rows.append((
            "DISPOSAL_LIFECYCLE_TERMINAL",
            nil,
            nil,
            journal.sourceSealed
                ? "OBSERVABILITY_SEAL_IS_NOT_DISPOSAL_TERMINAL"
                : "OBSERVABILITY_PREFIX_HAS_NO_DISPOSAL_TERMINAL"))
        rows.append((
            "SOURCE_RETRY_AUTHORIZATION",
            nil,
            nil,
            "OBSERVABILITY_SOURCE_DOES_NOT_RECORD_RETRY_AUTHORIZATION"))
    }
    if journal.frames.contains(where: { $0.eventType == .signalCall }) &&
        !journal.frames.contains(where: { $0.eventType == .conservation })
    {
        rows.append((
            "POST_SIGNAL_CONSERVATION",
            nil,
            nil,
            "SIGNAL_CALL_WITHOUT_CONSERVATION_FRAME"))
    }
    rows.append(contentsOf: typedMissingEvidence.map {
        ($0.evidenceKind, $0.targetRole, $0.sourceFrameID, $0.reasonCode)
    })
    let statement = try database.prepare(
        "INSERT INTO missing_evidence VALUES(?,?,?,?,?,?,?,?)")
    for row in rows {
        let scope = row.2 == nil ? "PROJECTION_GLOBAL_NON_PREFIX" : "FRAME_PREFIX"
        let missingID = disposalID(
            "disposal-missing-evidence-v2",
            [invocationID, row.0, row.1 ?? "NO_TARGET", row.2 ?? "NO_FRAME", row.3, scope])
        statement.reset()
        try statement.bind(1, text: missingID)
        try statement.bind(2, text: invocationID)
        try statement.bind(3, text: row.0)
        try statement.bind(4, text: row.1)
        try statement.bind(5, text: row.2)
        try statement.bind(6, text: row.3)
        try statement.bind(7, text: "ABSTAIN")
        try statement.bind(
            8,
            text: scope)
        try statement.stepDone()
    }
    return rows.count
}

private func insertDisposalTerminalOutcome(
    database: DisposalSQLiteConnection,
    journal: DisposalDecodedJournal,
    invocationID: String,
    frameIDs: [String],
    typedEvidence: DisposalTypedEvidenceInsertion
) throws {
    guard journal.isTerminal, let terminal = journal.frames.last else { return }
    let status = try terminal.requiredString(at: "/payload/status")
    let exitCode = try terminal.optionalUInt64(at: "/payload/exit_code")
    if let exitCode {
        try disposalRequireProjection(
            exitCode <= UInt64(Int.max),
            "TERMINAL_EXIT_CODE",
            frameOrdinal: terminal.ordinal)
    }
    let captureState = try terminal.requiredString(at: "/payload/capture_state")
    let completionClass = try terminal.requiredString(at: "/payload/completion_class")
    let gateEOutcome = try terminal.requiredString(at: "/payload/gate_e_outcome")
    try disposalRequireProjection(
        gateEOutcome == "ABSTAIN",
        "TERMINAL_GATE_E_OUTCOME",
        frameOrdinal: terminal.ordinal)
    let outcomeID = disposalID(
        "disposal-terminal-outcome-v1",
        [invocationID, frameIDs[terminal.ordinal], status, completionClass])
    let statement = try database.prepare(
        "INSERT INTO terminal_outcomes VALUES(" + String(repeating: "?,", count: 12) + "?)")
    try statement.bind(1, text: outcomeID)
    try statement.bind(2, text: invocationID)
    try statement.bind(3, text: frameIDs[terminal.ordinal])
    try statement.bind(4, text: status)
    try statement.bind(5, optionalInt: exitCode.map(Int.init))
    try statement.bind(6, text: captureState)
    try statement.bind(7, text: nil)
    try statement.bind(8, text: typedEvidence.guardianConservationID)
    try statement.bind(9, text: nil)
    try statement.bind(10, text: typedEvidence.fixtureConservationID)
    try statement.bind(11, text: completionClass)
    try statement.bind(12, text: "00000000")
    try statement.bind(13, text: "ABSTAIN")
    try statement.stepDone()
}
