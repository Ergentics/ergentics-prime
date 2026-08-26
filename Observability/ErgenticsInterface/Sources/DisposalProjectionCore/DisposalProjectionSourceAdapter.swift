import Foundation

struct DisposalProjectionSourceIdentity: Equatable, Sendable {
    let invocationID: String
    let arcLabel: String
    let epochLabel: String
    let consumptionState: String
    let retryAuthorized: Bool
    let controlCommit: String?
    let controlTree: String?
    let implementationCommit: String?
    let implementationTree: String?
    let artifactRole: String
    let streamKind: String
}

enum DisposalProjectionSourceAdapter {
    static func decode(_ source: Data) throws -> DisposalDecodedJournal {
        try decode(
            source,
            r19MaximumTotalNodes: DisposalEventJournal.maximumTotalNodes)
    }

    static func decodeForTesting(
        _ source: Data,
        r19MaximumTotalNodes: Int
    ) throws -> DisposalDecodedJournal {
        try disposalRequireProjection(
            r19MaximumTotalNodes >= 0 &&
                r19MaximumTotalNodes <= DisposalEventJournal.maximumTotalNodes,
            "R19_TEST_TOTAL_NODE_LIMIT")
        return try decode(source, r19MaximumTotalNodes: r19MaximumTotalNodes)
    }

    static func identity(
        of journal: DisposalDecodedJournal
    ) throws -> DisposalProjectionSourceIdentity {
        guard let start = journal.frames.first else {
            throw DisposalProjectionRejection(code: "SOURCE_IDENTITY_EMPTY")
        }
        switch journal.sourceKind {
        case .disposalEvent:
            return .init(
                invocationID: try start.requiredString(at: "/payload/invocation_id"),
                arcLabel: try start.requiredString(at: "/payload/arc_label"),
                epochLabel: try start.requiredString(at: "/payload/epoch_label"),
                consumptionState: try start.requiredString(at: "/payload/consumption_state"),
                retryAuthorized: try start.requiredBoolean(at: "/payload/retry_authorized"),
                controlCommit: try start.optionalString(at: "/payload/control_commit"),
                controlTree: try start.optionalString(at: "/payload/control_tree"),
                implementationCommit: try start.optionalString(
                    at: "/payload/implementation_commit"),
                implementationTree: try start.optionalString(
                    at: "/payload/implementation_tree"),
                artifactRole: "DISPOSAL_JOURNAL",
                streamKind: "DISPOSAL_JOURNAL")
        case .r19Observability:
            let sessionID = try start.requiredString(at: "/session_id")
            let controlCommit = try start.requiredString(at: "/payload/control_commit")
            let controlTree = try start.requiredString(at: "/payload/control_tree")
            return .init(
                invocationID: disposalLengthFramedID(
                    "ergentics-r19-observability-invocation-v1",
                    [sessionID, start.rawWithLFSHA256, controlCommit, controlTree]),
                arcLabel: "R19_OBSERVABILITY_PRESENTATION",
                epochLabel: sessionID,
                consumptionState: "ABSTAIN_NOT_RECORDED",
                retryAuthorized: false,
                controlCommit: controlCommit,
                controlTree: controlTree,
                implementationCommit: nil,
                implementationTree: nil,
                artifactRole: "OBSERVABILITY_JOURNAL",
                streamKind: "OBSERVABILITY")
        }
    }

    private static func decode(
        _ source: Data,
        r19MaximumTotalNodes: Int
    ) throws -> DisposalDecodedJournal {
        guard !source.isEmpty else { return try DisposalEventJournal.decode(source) }
        try disposalRequireProjection(
            source.count <= DisposalEventJournal.maximumSourceBytes,
            "SOURCE_CAP")
        guard let newline = source.firstIndex(of: 0x0a), newline > 0 else {
            throw DisposalProjectionRejection(code: "SOURCE_FIRST_FRAME")
        }
        try disposalRequireProjection(
            newline <= DisposalEventJournal.maximumFrameBytes,
            "SOURCE_FIRST_FRAME_CAP")
        let firstRaw = source.subdata(in: 0..<newline)
        var parser = DisposalCanonicalJSONParser(
            data: firstRaw,
            frameOrdinal: 0,
            journalByteOffset: 0)
        let first = try parser.parse()
        guard case .object = first,
              first.canonicalData() == firstRaw,
              let schema = first.member("schema")?.stringValue()
        else {
            throw DisposalProjectionRejection(code: "SOURCE_FIRST_FRAME_SCHEMA")
        }
        switch schema {
        case DisposalEventJournal.frameSchema:
            return try DisposalEventJournal.decode(source)
        case R19ObservabilityJournalAdapter.frameSchema:
            return try R19ObservabilityJournalAdapter.decode(
                source,
                maximumTotalNodes: r19MaximumTotalNodes)
        default:
            throw DisposalProjectionRejection(code: "SOURCE_FRAME_SCHEMA", detail: schema)
        }
    }
}

private enum R19ObservabilityJournalAdapter {
    static let frameSchema = "prime_driver_v2_r19_observability_frame_v1"
    private static let payloadHashRule =
        "SHA256_COMPACT_RECURSIVE_LEXICOGRAPHIC_KEYS_UTF8_NO_TRAILING_LF"
    private static let exactOuterKeys = Set([
        "frame_kind", "ordinal", "payload", "payload_hash_rule",
        "payload_sha256", "previous_frame_sha256", "schema", "session_id",
    ])

    private struct InventoryTarget: Equatable {
        let label: String
        let pid: Int
        let uniqueID: UInt64
        let idVersion: UInt64
        let sid: Int
        let pgid: Int
    }

    private struct SessionContext {
        let sessionID: String
        let controlSHA256: String
        let inventorySHA256: String
        let targets: [InventoryTarget]
    }

    private struct SampleContext: Equatable {
        let target: InventoryTarget
        let processUUID: String
        let processStart: UInt64
        let processSHA256: String
        let monotonicBefore: UInt64
        let monotonicAfter: UInt64
        let counters: [String: UInt64]
    }

    static func decode(
        _ source: Data,
        maximumTotalNodes: Int
    ) throws -> DisposalDecodedJournal {
        try require(source.count <= DisposalEventJournal.maximumSourceBytes, "R19_SOURCE_CAP")
        try require(source.last == 0x0a, "R19_TERMINAL_LF")
        let bytes = [UInt8](source)
        var frames: [DisposalDecodedFrame] = []
        var lineStart = 0
        var lineNumber = 1
        var sealed = false
        var totalNodes = 0

        for newline in bytes.indices where bytes[newline] == 0x0a {
            let ordinal = frames.count
            try require(ordinal < DisposalEventJournal.maximumFrames, "R19_FRAME_CAP", ordinal)
            try require(newline > lineStart, "R19_EMPTY_LINE", ordinal)
            try require(
                newline - lineStart <= DisposalEventJournal.maximumFrameBytes,
                "R19_FRAME_BYTE_CAP",
                ordinal)
            try require(!sealed, "R19_FRAME_AFTER_SEAL", ordinal)
            let raw = Data(bytes[lineStart..<newline])
            var rawWithLF = raw
            rawWithLF.append(0x0a)
            let frame = try decodeFrame(
                raw: raw,
                rawWithLF: rawWithLF,
                expectedOrdinal: ordinal,
                lineNumber: lineNumber,
                journalByteOffset: lineStart,
                priorFrameWithLFSHA256: frames.last?.rawWithLFSHA256)
            let (nextTotalNodes, overflow) = totalNodes.addingReportingOverflow(frame.nodes.count)
            try require(
                !overflow && nextTotalNodes <= maximumTotalNodes,
                "R19_TOTAL_NODE_CAP",
                ordinal)
            totalNodes = nextTotalNodes
            sealed = frame.sourceFrameKind == .r19ObservabilitySeal
            frames.append(frame)
            lineStart = newline + 1
            lineNumber += 1
        }
        try require(lineStart == bytes.count, "R19_UNFRAMED_SUFFIX", frames.count)
        try require(!frames.isEmpty, "R19_EMPTY_SOURCE")
        try validateSequence(frames: frames, source: source)
        let last = frames.last!
        if sealed {
            return .init(
                source: source,
                sourceSHA256: disposalSHA256(source),
                frames: frames,
                sourceKind: .r19Observability,
                sourceSealed: true,
                isTerminal: false,
                completion: .sealedPresentationSource(
                    ordinal: last.ordinal,
                    exactStatus: last.status ?? "ABSENT"))
        }
        return .init(
            source: source,
            sourceSHA256: disposalSHA256(source),
            frames: frames,
            sourceKind: .r19Observability,
            sourceSealed: false,
            isTerminal: false,
            completion: .incomplete(.prefixEndingAtOrdinal(last.ordinal)))
    }

    private static func decodeFrame(
        raw: Data,
        rawWithLF: Data,
        expectedOrdinal: Int,
        lineNumber: Int,
        journalByteOffset: Int,
        priorFrameWithLFSHA256: String?
    ) throws -> DisposalDecodedFrame {
        var parser = DisposalCanonicalJSONParser(
            data: raw,
            frameOrdinal: expectedOrdinal,
            journalByteOffset: journalByteOffset)
        let root = try parser.parse()
        guard case .object(let members, _) = root else {
            throw rejection("R19_FRAME_ROOT", expectedOrdinal)
        }
        try require(root.canonicalData() == raw, "R19_FRAME_NOT_CANONICAL", expectedOrdinal)
        try require(Set(members.map(\.key)) == exactOuterKeys, "R19_FRAME_OUTER_KEYS", expectedOrdinal)
        try require(
            try string(root, "schema", expectedOrdinal) == frameSchema,
            "R19_FRAME_SCHEMA",
            expectedOrdinal)
        let ordinal = try integer(root, "ordinal", expectedOrdinal)
        try require(ordinal == expectedOrdinal, "R19_FRAME_ORDINAL", expectedOrdinal)
        try require(
            try string(root, "payload_hash_rule", ordinal) == payloadHashRule,
            "R19_PAYLOAD_HASH_RULE",
            ordinal)
        let sessionID = try string(root, "session_id", ordinal)
        try require(
            !sessionID.isEmpty && sessionID.utf8.count <= 128 && sessionID.utf8.allSatisfy {
                (0x61...0x7a).contains($0) || (0x30...0x39).contains($0) || $0 == 0x2d
            },
            "R19_SESSION_ID",
            ordinal)

        let frameKindText = try string(root, "frame_kind", ordinal)
        let sourceFrameKind: DisposalSourceFrameKind
        switch frameKindText {
        case "session": sourceFrameKind = .r19ObservabilitySession
        case "sample": sourceFrameKind = .r19ObservabilitySample
        case "seal": sourceFrameKind = .r19ObservabilitySeal
        default: throw rejection("R19_FRAME_KIND", ordinal, frameKindText)
        }

        guard let payloadValue = root.member("payload"), case .object = payloadValue else {
            throw rejection("R19_PAYLOAD_OBJECT", ordinal)
        }
        let span = payloadValue.span
        let payload = raw.subdata(in: span.lowerBound..<span.upperBound)
        try require(payloadValue.canonicalData() == payload, "R19_PAYLOAD_NOT_CANONICAL", ordinal)
        let payloadSHA256 = disposalSHA256(payload)
        let declaredPayloadSHA256 = try string(root, "payload_sha256", ordinal)
        try require(
            disposalIsLowerHex(declaredPayloadSHA256, count: 64),
            "R19_PAYLOAD_SHA_SHAPE",
            ordinal)
        try require(
            payloadSHA256 == declaredPayloadSHA256,
            "R19_PAYLOAD_SHA_MISMATCH",
            ordinal)

        let previousSHA256: String?
        guard let previous = root.member("previous_frame_sha256") else {
            throw rejection("R19_PREVIOUS_ABSENT", ordinal)
        }
        if case .null = previous {
            previousSHA256 = nil
        } else if let value = previous.stringValue() {
            try require(disposalIsLowerHex(value, count: 64), "R19_PREVIOUS_SHAPE", ordinal)
            previousSHA256 = value
        } else {
            throw rejection("R19_PREVIOUS_TYPE", ordinal)
        }
        try require(
            ordinal == 0 ? previousSHA256 == nil : previousSHA256 == priorFrameWithLFSHA256,
            "R19_FRAME_HASH_CHAIN",
            ordinal)

        var nodes: [DisposalJSONNode] = []
        flatten(
            root,
            raw: raw,
            journalByteOffset: journalByteOffset,
            pointer: "",
            parentPointer: nil,
            childOrdinal: 0,
            nodes: &nodes)
        return .init(
            schema: frameSchema,
            ordinal: ordinal,
            eventType: .resource,
            sourceFrameKind: sourceFrameKind,
            phase: frameKindText,
            targetLabel: payloadValue.member("label")?.stringValue(),
            status: payloadValue.member("status")?.stringValue(),
            eventID: nil,
            observedUTC: payloadValue.member("observed_utc")?.stringValue(),
            monotonicNanoseconds: try optionalUInt64(payloadValue, "monotonic_after_ns", ordinal),
            lineNumber: lineNumber,
            journalByteOffset: journalByteOffset,
            raw: raw,
            rawSHA256: disposalSHA256(raw),
            rawWithLF: rawWithLF,
            rawWithLFSHA256: disposalSHA256(rawWithLF),
            payload: payload,
            payloadSHA256: payloadSHA256,
            previousSHA256: previousSHA256,
            nodes: nodes)
    }

    private static func validateSequence(
        frames: [DisposalDecodedFrame],
        source: Data
    ) throws {
        try require(frames.count <= 8, "R19_FRAME_COUNT", frames.count)
        try require(
            frames[0].sourceFrameKind == .r19ObservabilitySession,
            "R19_FIRST_NOT_SESSION",
            0)
        let session = try validateSession(frames[0])
        var samples: [String: SampleContext] = [:]
        if frames.count > 1 {
            for ordinal in 1..<frames.count {
                let frame = frames[ordinal]
                if frame.sourceFrameKind == .r19ObservabilitySeal {
                    try require(ordinal == 7 && frames.count == 8, "R19_SEAL_POSITION", ordinal)
                    try validateSeal(
                        frame,
                        session: session,
                        frames: frames,
                        source: source)
                } else {
                    try require(
                        frame.sourceFrameKind == .r19ObservabilitySample && ordinal <= 6,
                        "R19_SAMPLE_POSITION",
                        ordinal)
                    let context = try validateSample(
                        frame,
                        sessionID: session.sessionID,
                        expected: session.targets[(ordinal - 1) % session.targets.count],
                        expectedRound: (ordinal - 1) / session.targets.count,
                        prior: samples[session.targets[(ordinal - 1) % session.targets.count].label])
                    samples[context.target.label] = context
                }
            }
        }
        if frames.last?.sourceFrameKind == .r19ObservabilitySeal {
            try require(samples.count == 3, "R19_SEAL_SAMPLE_TARGET_COUNT", 7)
        }
    }

    private static func validateSession(_ frame: DisposalDecodedFrame) throws -> SessionContext {
        let root = try rootValue(frame)
        let payload = try frame.payloadValue()
        try exactKeys(payload, [
            "actuation_calls", "authority_vector", "clock_delay_entries", "control_blob",
            "control_commit", "control_sha256", "control_tree", "exec_entries_inside_observer",
            "gate_e_clearance", "gate_e_mechanics_outcome", "gate_e_scientific_outcome",
            "interval_nanoseconds", "journal_leaf", "observation_root", "observer_children",
            "process_enumeration_calls", "process_wait_entries", "sample_rounds", "schema",
            "scientific_authorities_closed", "signal_entries", "started_utc", "status",
            "target_inventory", "target_inventory_sha256", "target_sampling_horizon_nanoseconds",
            "target_wait_entries",
        ], frame.ordinal, "R19_SESSION_KEYS")
        try exactString(payload, "schema", "prime_driver_v2_r19_observability_session_v1", frame.ordinal)
        try exactString(payload, "status", "PRESENTATION_CAPTURE_NOT_IN_AUTHORITY_PREDICATE", frame.ordinal)
        try validateNonauthority(payload, frame.ordinal)
        for key in [
            "actuation_calls", "exec_entries_inside_observer", "observer_children",
            "process_enumeration_calls", "process_wait_entries", "signal_entries",
            "target_wait_entries",
        ] {
            try exactInt(payload, key, 0, frame.ordinal)
        }
        try exactInt(payload, "clock_delay_entries", 1, frame.ordinal)
        try exactInt(payload, "sample_rounds", 2, frame.ordinal)
        try exactInt(payload, "interval_nanoseconds", 5_000_000_000, frame.ordinal)
        try exactInt(payload, "target_sampling_horizon_nanoseconds", 15_000_000_000, frame.ordinal)
        try require(
            try string(payload, "journal_leaf", frame.ordinal) == "r19-observations.v1.jsonl",
            "R19_SESSION_JOURNAL_LEAF",
            frame.ordinal)
        let controlSHA = try string(payload, "control_sha256", frame.ordinal)
        try require(disposalIsLowerHex(controlSHA, count: 64), "R19_CONTROL_SHA", frame.ordinal)
        for key in ["control_blob", "control_commit", "control_tree"] {
            try require(
                disposalIsLowerHex(try string(payload, key, frame.ordinal), count: 40),
                "R19_CONTROL_GIT_ID",
                frame.ordinal,
                key)
        }
        let inventoryValue = try member(payload, "target_inventory", frame.ordinal)
        guard case .array(let values, _) = inventoryValue, values.count == 3 else {
            throw rejection("R19_TARGET_INVENTORY_COUNT", frame.ordinal)
        }
        let expectedLabels = ["wrapper", "guardian", "fixture"]
        var targets: [InventoryTarget] = []
        for index in values.indices {
            let value = values[index]
            try exactKeys(
                value,
                ["idversion", "label", "pgid", "pid", "sid", "unique_id"],
                frame.ordinal,
                "R19_TARGET_INVENTORY_KEYS")
            let label = try string(value, "label", frame.ordinal)
            let pid = try integer(value, "pid", frame.ordinal)
            let sid = try integer(value, "sid", frame.ordinal)
            let pgid = try integer(value, "pgid", frame.ordinal)
            let uniqueID = try unsigned(value, "unique_id", frame.ordinal)
            let idVersion = try unsigned(value, "idversion", frame.ordinal)
            try require(label == expectedLabels[index], "R19_TARGET_LABEL_ORDER", frame.ordinal)
            try require(pid > 1 && sid == pid && pgid == pid, "R19_TARGET_PRIVATE_DOMAIN", frame.ordinal)
            try require(uniqueID > 0 && idVersion > 0, "R19_TARGET_GENERATION", frame.ordinal)
            targets.append(.init(
                label: label,
                pid: pid,
                uniqueID: uniqueID,
                idVersion: idVersion,
                sid: sid,
                pgid: pgid))
        }
        try require(Set(targets.map(\.pid)).count == 3, "R19_TARGET_PID_UNIQUE", frame.ordinal)
        guard let inventoryNode = frame.node(at: "/payload/target_inventory") else {
            throw rejection("R19_TARGET_INVENTORY_NODE", frame.ordinal)
        }
        let inventorySHA = try string(payload, "target_inventory_sha256", frame.ordinal)
        try require(
            inventoryNode.rawSHA256 == inventorySHA,
            "R19_TARGET_INVENTORY_SHA",
            frame.ordinal)
        return .init(
            sessionID: try string(root, "session_id", frame.ordinal),
            controlSHA256: controlSHA,
            inventorySHA256: inventorySHA,
            targets: targets)
    }

    private static func validateSample(
        _ frame: DisposalDecodedFrame,
        sessionID: String,
        expected: InventoryTarget,
        expectedRound: Int,
        prior: SampleContext?
    ) throws -> SampleContext {
        let root = try rootValue(frame)
        try exactString(root, "session_id", sessionID, frame.ordinal)
        let payload = try frame.payloadValue()
        try exactKeys(payload, [
            "authority_vector", "availability", "error", "gate_e_clearance",
            "gate_e_mechanics_outcome", "gate_e_scientific_outcome", "interval", "label",
            "monotonic_after_ns", "monotonic_before_ns", "observed_utc", "pid", "process",
            "process_actuation_calls", "round", "rusage_v6", "schema",
            "scientific_authorities_closed", "signal_entries", "status",
        ], frame.ordinal, "R19_SAMPLE_KEYS")
        try exactString(payload, "schema", "prime_driver_v2_r19_process_energy_observation_v1", frame.ordinal)
        try exactString(
            payload,
            "status",
            "OBSERVED_PRESENTATION_ONLY_NOT_IN_AUTHORITY_PREDICATE",
            frame.ordinal)
        try validateNonauthority(payload, frame.ordinal)
        try exactInt(payload, "process_actuation_calls", 0, frame.ordinal)
        try exactInt(payload, "signal_entries", 0, frame.ordinal)
        try exactString(payload, "availability", "AVAILABLE_EXACT_GENERATION_SANDWICHED", frame.ordinal)
        try requireNull(payload, "error", frame.ordinal)
        try exactString(payload, "label", expected.label, frame.ordinal)
        try exactInt(payload, "pid", expected.pid, frame.ordinal)
        try exactInt(payload, "round", expectedRound, frame.ordinal)
        let before = try unsigned(payload, "monotonic_before_ns", frame.ordinal)
        let after = try unsigned(payload, "monotonic_after_ns", frame.ordinal)
        try require(before <= after, "R19_SAMPLE_MONOTONIC_ORDER", frame.ordinal)

        let process = try member(payload, "process", frame.ordinal)
        try exactKeys(process, [
            "command_hex", "flags", "gid", "idversion", "parent_pid", "parent_unique_id",
            "pgid", "real_gid", "real_uid", "saved_gid", "saved_uid", "sid", "status",
            "uid", "unique_id", "uuid_hex",
        ], frame.ordinal, "R19_PROCESS_KEYS")
        try require(
            try unsigned(process, "idversion", frame.ordinal) == expected.idVersion,
            "R19_PROCESS_IDVERSION",
            frame.ordinal)
        try require(
            try unsigned(process, "unique_id", frame.ordinal) == expected.uniqueID,
            "R19_PROCESS_UNIQUE_ID",
            frame.ordinal)
        try exactInt(process, "pgid", expected.pgid, frame.ordinal)
        try exactInt(process, "sid", expected.sid, frame.ordinal)
        let uid = try integer(process, "uid", frame.ordinal)
        let gid = try integer(process, "gid", frame.ordinal)
        try exactInt(process, "real_uid", uid, frame.ordinal)
        try exactInt(process, "saved_uid", uid, frame.ordinal)
        try exactInt(process, "real_gid", gid, frame.ordinal)
        try exactInt(process, "saved_gid", gid, frame.ordinal)
        let processUUID = try string(process, "uuid_hex", frame.ordinal)
        try require(disposalIsLowerHex(processUUID, count: 32), "R19_PROCESS_UUID", frame.ordinal)
        guard let processNode = frame.node(at: "/payload/process") else {
            throw rejection("R19_PROCESS_NODE", frame.ordinal)
        }

        let rusage = try member(payload, "rusage_v6", frame.ordinal)
        let counterKeys = [
            "cycles", "energy_nj", "instructions", "pcycles", "penergy_nj",
            "physical_footprint_bytes", "pinstructions", "process_exit_abstime",
            "process_start_abstime", "runnable_time", "system_ptime", "system_time",
            "user_ptime", "user_time",
        ]
        try exactKeys(rusage, counterKeys + ["uuid_hex"], frame.ordinal, "R19_RUSAGE_KEYS")
        try exactString(rusage, "uuid_hex", processUUID, frame.ordinal)
        var counters: [String: UInt64] = [:]
        for key in counterKeys { counters[key] = try unsigned(rusage, key, frame.ordinal) }
        try require(counters["process_exit_abstime"] == 0, "R19_PROCESS_EXIT_ABSTIME", frame.ordinal)
        let processStart = counters["process_start_abstime"]!
        try require(processStart > 0, "R19_PROCESS_START_ABSTIME", frame.ordinal)
        let context = SampleContext(
            target: expected,
            processUUID: processUUID,
            processStart: processStart,
            processSHA256: processNode.rawSHA256,
            monotonicBefore: before,
            monotonicAfter: after,
            counters: counters)
        if let prior {
            try require(
                prior.target == context.target && prior.processUUID == context.processUUID &&
                    prior.processStart == context.processStart &&
                    prior.processSHA256 == context.processSHA256,
                "R19_SAMPLE_GENERATION_DRIFT",
                frame.ordinal)
        }
        try validateInterval(
            try member(payload, "interval", frame.ordinal),
            frame: frame,
            round: expectedRound,
            prior: prior,
            current: context)
        return context
    }

    private static func validateInterval(
        _ interval: DisposalJSONValue,
        frame: DisposalDecodedFrame,
        round: Int,
        prior: SampleContext?,
        current: SampleContext
    ) throws {
        let nullableDerived = [
            "average_power_at_estimated_interval_w_approx",
            "average_power_at_maximum_interval_w_approx",
            "average_power_at_minimum_interval_w_approx",
            "cpu_percent_at_estimated_interval_approx",
            "cpu_percent_at_maximum_interval_approx",
            "cpu_percent_at_minimum_interval_approx",
            "delta_cpu_ns", "delta_cycles", "delta_energy_nj", "delta_ergs",
            "delta_instructions", "delta_joules", "elapsed_estimate_ns",
            "elapsed_maximum_ns", "elapsed_minimum_ns",
        ]
        try exactKeys(
            interval,
            nullableDerived + [
                "energy_interpretation", "energy_interpretation_valid", "reason", "valid",
            ],
            frame.ordinal,
            "R19_INTERVAL_KEYS")
        if round == 0 {
            try exactBoolean(interval, "valid", false, frame.ordinal)
            try exactBoolean(interval, "energy_interpretation_valid", false, frame.ordinal)
            try exactString(interval, "reason", "NO_PREDECESSOR", frame.ordinal)
            try exactString(interval, "energy_interpretation", "ABSTAIN_INTERVAL_UNAVAILABLE", frame.ordinal)
            for key in nullableDerived { try requireNull(interval, key, frame.ordinal) }
            try require(prior == nil, "R19_INTERVAL_UNEXPECTED_PREDECESSOR", frame.ordinal)
            return
        }
        guard let prior else { throw rejection("R19_INTERVAL_PREDECESSOR_ABSENT", frame.ordinal) }
        try exactBoolean(interval, "valid", true, frame.ordinal)
        try exactBoolean(interval, "energy_interpretation_valid", true, frame.ordinal)
        try exactString(
            interval,
            "reason",
            "MONOTONIC_GENERATION_JOINED_COUNTER_INTERVAL_VALID",
            frame.ordinal)
        try exactString(
            interval,
            "energy_interpretation",
            "AVAILABLE_KERNEL_RUSAGE_V6_TASK_ENERGY_DELTA",
            frame.ordinal)
        let minimum = try unsigned(interval, "elapsed_minimum_ns", frame.ordinal)
        let estimate = try unsigned(interval, "elapsed_estimate_ns", frame.ordinal)
        let maximum = try unsigned(interval, "elapsed_maximum_ns", frame.ordinal)
        try require(
            current.monotonicBefore >= prior.monotonicAfter &&
                current.monotonicAfter >= prior.monotonicBefore,
            "R19_INTERVAL_MONOTONIC_REGRESSION",
            frame.ordinal)
        let derivedMinimum = current.monotonicBefore - prior.monotonicAfter
        let derivedMaximum = current.monotonicAfter - prior.monotonicBefore
        let priorMidpoint = prior.monotonicBefore +
            (prior.monotonicAfter - prior.monotonicBefore) / 2
        let currentMidpoint = current.monotonicBefore +
            (current.monotonicAfter - current.monotonicBefore) / 2
        let derivedEstimate = currentMidpoint - priorMidpoint
        try require(
            minimum > 0 && minimum <= estimate && estimate <= maximum,
            "R19_INTERVAL_BOUNDS",
            frame.ordinal)
        try require(
            minimum == derivedMinimum && estimate == derivedEstimate && maximum == derivedMaximum,
            "R19_INTERVAL_DERIVATION",
            frame.ordinal)
        for (field, intervalKey) in [
            ("cycles", "delta_cycles"),
            ("energy_nj", "delta_energy_nj"),
            ("instructions", "delta_instructions"),
        ] {
            let before = prior.counters[field]!
            let after = current.counters[field]!
            try require(after >= before, "R19_INTERVAL_COUNTER_REGRESSION", frame.ordinal, field)
            try exactUnsigned(interval, intervalKey, after - before, frame.ordinal)
        }
        // CPU-derived fields are deliberately retained only as raw JSON lexemes.
        // Their historical nanosecond interpretation is not promoted here.
        _ = try integer(interval, "delta_cpu_ns", frame.ordinal)
    }

    private static func validateSeal(
        _ frame: DisposalDecodedFrame,
        session: SessionContext,
        frames: [DisposalDecodedFrame],
        source: Data
    ) throws {
        let root = try rootValue(frame)
        let payload = try frame.payloadValue()
        try exactKeys(payload, [
            "authority_vector", "build_entries", "completed_utc", "control_sha256",
            "expected_final_frame_count", "expected_sample_count", "gate_e_clearance",
            "gate_e_mechanics_outcome", "gate_e_promotions", "gate_e_scientific_outcome",
            "git_entries", "observer_children", "preseal_frame_count", "preseal_journal_bytes",
            "preseal_journal_sha256", "preseal_tail_frame_sha256", "process_actuation_calls",
            "recovery_entries", "sample_count", "schema", "scientific_authorities_closed",
            "session_id", "signal_entries", "source_bytes", "source_sha256", "status",
            "target_inventory_sha256",
        ], frame.ordinal, "R19_SEAL_KEYS")
        try exactString(payload, "schema", "prime_driver_v2_r19_observability_seal_v1", frame.ordinal)
        try exactString(
            payload,
            "status",
            "PASS_TELEMETRY_JOURNAL_SEALED_PROJECTION_PENDING_NOT_AUTHORITY",
            frame.ordinal)
        try validateNonauthority(payload, frame.ordinal)
        for key in [
            "build_entries", "gate_e_promotions", "git_entries", "observer_children",
            "process_actuation_calls", "recovery_entries", "signal_entries",
        ] {
            try exactInt(payload, key, 0, frame.ordinal)
        }
        try exactInt(payload, "expected_final_frame_count", 8, frame.ordinal)
        try exactInt(payload, "expected_sample_count", 6, frame.ordinal)
        try exactInt(payload, "preseal_frame_count", 7, frame.ordinal)
        try exactInt(payload, "sample_count", 6, frame.ordinal)
        try exactString(payload, "session_id", session.sessionID, frame.ordinal)
        try exactString(payload, "control_sha256", session.controlSHA256, frame.ordinal)
        // This digest names the observer/controller source, not this JSONL artifact.
        try exactString(payload, "source_sha256", session.controlSHA256, frame.ordinal)
        try exactString(payload, "target_inventory_sha256", session.inventorySHA256, frame.ordinal)
        try require(
            try string(root, "session_id", frame.ordinal) == session.sessionID,
            "R19_SEAL_OUTER_SESSION",
            frame.ordinal)
        let prefix = frames.prefix(7).reduce(into: Data()) { $0.append($1.rawWithLF) }
        try exactInt(payload, "preseal_journal_bytes", prefix.count, frame.ordinal)
        try exactString(payload, "preseal_journal_sha256", disposalSHA256(prefix), frame.ordinal)
        try exactString(
            payload,
            "preseal_tail_frame_sha256",
            frames[6].rawWithLFSHA256,
            frame.ordinal)
        try require(source == prefix + frame.rawWithLF, "R19_SEAL_SOURCE_JOIN", frame.ordinal)
        try require(try integer(payload, "source_bytes", frame.ordinal) > 0, "R19_OBSERVER_SOURCE_BYTES", frame.ordinal)
    }

    private static func validateNonauthority(
        _ payload: DisposalJSONValue,
        _ ordinal: Int
    ) throws {
        try exactString(payload, "authority_vector", "00000000", ordinal)
        try exactInt(payload, "gate_e_clearance", 0, ordinal)
        try exactString(payload, "gate_e_mechanics_outcome", "ABSTAIN", ordinal)
        try exactString(payload, "gate_e_scientific_outcome", "ABSTAIN", ordinal)
        try exactInt(payload, "scientific_authorities_closed", 0, ordinal)
    }

    private static func rootValue(_ frame: DisposalDecodedFrame) throws -> DisposalJSONValue {
        var parser = DisposalCanonicalJSONParser(
            data: frame.raw,
            frameOrdinal: frame.ordinal,
            journalByteOffset: frame.journalByteOffset)
        return try parser.parse()
    }

    private static func exactKeys(
        _ object: DisposalJSONValue,
        _ keys: [String],
        _ ordinal: Int,
        _ code: String
    ) throws {
        guard case .object(let members, _) = object else { throw rejection(code, ordinal) }
        try require(Set(members.map(\.key)) == Set(keys), code, ordinal)
    }

    private static func member(
        _ object: DisposalJSONValue,
        _ key: String,
        _ ordinal: Int
    ) throws -> DisposalJSONValue {
        guard let value = object.member(key) else { throw rejection("R19_MEMBER_ABSENT", ordinal, key) }
        return value
    }

    private static func string(
        _ object: DisposalJSONValue,
        _ key: String,
        _ ordinal: Int
    ) throws -> String {
        guard let value = object.member(key)?.stringValue() else {
            throw rejection("R19_STRING", ordinal, key)
        }
        return value
    }

    private static func integer(
        _ object: DisposalJSONValue,
        _ key: String,
        _ ordinal: Int
    ) throws -> Int {
        guard let lexeme = object.member(key)?.numberLexeme(),
              let value = Int(lexeme),
              String(value) == lexeme
        else { throw rejection("R19_INTEGER", ordinal, key) }
        return value
    }

    private static func unsigned(
        _ object: DisposalJSONValue,
        _ key: String,
        _ ordinal: Int
    ) throws -> UInt64 {
        guard let lexeme = object.member(key)?.numberLexeme(),
              let value = UInt64(lexeme),
              String(value) == lexeme
        else { throw rejection("R19_UNSIGNED", ordinal, key) }
        return value
    }

    private static func optionalUInt64(
        _ object: DisposalJSONValue,
        _ key: String,
        _ ordinal: Int
    ) throws -> UInt64? {
        guard let value = object.member(key) else { return nil }
        if case .null = value { return nil }
        return try unsigned(object, key, ordinal)
    }

    private static func exactString(
        _ object: DisposalJSONValue,
        _ key: String,
        _ expected: String,
        _ ordinal: Int
    ) throws {
        try require(try string(object, key, ordinal) == expected, "R19_EXACT_STRING", ordinal, key)
    }

    private static func exactInt(
        _ object: DisposalJSONValue,
        _ key: String,
        _ expected: Int,
        _ ordinal: Int
    ) throws {
        try require(try integer(object, key, ordinal) == expected, "R19_EXACT_INTEGER", ordinal, key)
    }

    private static func exactUnsigned(
        _ object: DisposalJSONValue,
        _ key: String,
        _ expected: UInt64,
        _ ordinal: Int
    ) throws {
        try require(
            try unsigned(object, key, ordinal) == expected,
            "R19_EXACT_UNSIGNED",
            ordinal,
            key)
    }

    private static func exactBoolean(
        _ object: DisposalJSONValue,
        _ key: String,
        _ expected: Bool,
        _ ordinal: Int
    ) throws {
        guard let value = object.member(key)?.booleanValue() else {
            throw rejection("R19_BOOLEAN", ordinal, key)
        }
        try require(value == expected, "R19_EXACT_BOOLEAN", ordinal, key)
    }

    private static func requireNull(
        _ object: DisposalJSONValue,
        _ key: String,
        _ ordinal: Int
    ) throws {
        guard let value = object.member(key), case .null = value else {
            throw rejection("R19_NULL", ordinal, key)
        }
    }

    private static func require(
        _ condition: @autoclosure () throws -> Bool,
        _ code: String,
        _ ordinal: Int? = nil,
        _ detail: String = ""
    ) throws {
        guard try condition() else { throw rejection(code, ordinal, detail) }
    }

    private static func rejection(
        _ code: String,
        _ ordinal: Int? = nil,
        _ detail: String = ""
    ) -> DisposalProjectionRejection {
        .init(code: code, frameOrdinal: ordinal, detail: detail)
    }

    private static func flatten(
        _ value: DisposalJSONValue,
        raw: Data,
        journalByteOffset: Int,
        pointer: String,
        parentPointer: String?,
        childOrdinal: Int,
        nodes: inout [DisposalJSONNode]
    ) {
        let span = value.span
        let nodeRaw = raw.subdata(in: span.lowerBound..<span.upperBound)
        let kind: DisposalJSONNodeKind
        let scalar: DisposalJSONScalar?
        switch value {
        case .object:
            kind = .object
            scalar = nil
        case .array:
            kind = .array
            scalar = nil
        case .string(let value, _):
            kind = .string
            scalar = .string(value)
        case .number(let lexeme, _):
            kind = .number
            scalar = .numberLexeme(lexeme)
        case .boolean(let value, _):
            kind = .boolean
            scalar = .boolean(value)
        case .null:
            kind = .null
            scalar = .null
        }
        nodes.append(.init(
            jsonPointer: pointer,
            parentPointer: parentPointer,
            childOrdinal: childOrdinal,
            kind: kind,
            scalar: scalar,
            childCount: value.childCount,
            frameRelativeByteOffset: span.lowerBound,
            journalByteOffset: journalByteOffset + span.lowerBound,
            byteCount: span.count,
            raw: nodeRaw,
            rawSHA256: disposalSHA256(nodeRaw)))
        switch value {
        case .object(let members, _):
            for (index, member) in members.enumerated() {
                flatten(
                    member.value,
                    raw: raw,
                    journalByteOffset: journalByteOffset,
                    pointer: pointer + "/" + escapePointer(member.key),
                    parentPointer: pointer,
                    childOrdinal: index,
                    nodes: &nodes)
            }
        case .array(let values, _):
            for (index, child) in values.enumerated() {
                flatten(
                    child,
                    raw: raw,
                    journalByteOffset: journalByteOffset,
                    pointer: pointer + "/" + String(index),
                    parentPointer: pointer,
                    childOrdinal: index,
                    nodes: &nodes)
            }
        default: break
        }
    }

    private static func escapePointer(_ token: String) -> String {
        token.replacingOccurrences(of: "~", with: "~0")
            .replacingOccurrences(of: "/", with: "~1")
    }
}
