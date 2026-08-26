import Foundation

private let disposalRationalMathSemantics = """
ergentics-disposal-rational-math-v1
delta-cpu-ticks=delta-user-ticks+delta-system-ticks
cpu-time-ns=delta-cpu-ticks*timebase-numerator/timebase-denominator
cpu-percent=cpu-time-ns*100/elapsed-ns
joules=delta-energy-nj/1000000000
ergs=delta-energy-nj/100
watts=delta-energy-nj/elapsed-ns
bounds=elapsed-max->lower;elapsed-midpoint->estimated;elapsed-min->upper
arithmetic=unbounded-base2^32-wide-unsigned;reduced-rational;no-floating-authority
"""

private struct DisposalRusageField: Sendable {
    let name: String
    let offset: Int?
    let width: Int?
    let value: UInt64?
    let unit: String
    let grade: String
    let sourcePointer: String?
}

private struct DisposalRusageSample: Sendable {
    let sampleID: String
    let frameID: String
    let frameSHA256: String
    let targetID: String
    let label: String
    let round: Int
    let pid: Int
    let uniqueID: UInt64?
    let idVersion: UInt64?
    let sid: Int?
    let pgid: Int?
    let processUUID: String?
    let rusageUUID: String?
    let processStart: UInt64?
    let rawState: String
    let rawSHA256: String?
    let raw: Data?
    let joinState: String
    let entryNS: UInt64?
    let returnNS: UInt64?
    let timebaseNumerator: UInt64?
    let timebaseDenominator: UInt64?
    let fields: [DisposalRusageField]

    func field(_ name: String) -> UInt64? {
        fields.first(where: { $0.name == name })?.value
    }
}

private struct DisposalMetricRow: Sendable {
    let id: String
    let intervalID: String
    let name: String
    let bound: String
    let rational: DisposalRational
    let approximation: String?
    let sourceGrade: String
    let premise: String
    let pointer: String
}

func buildDisposalMetrics(
    journal: DisposalDecodedJournal,
    evidence: DisposalEvidenceMaterial
) throws -> DisposalMetricsMaterial {
    let ddl = try disposalResourceData("001-metrics", extension: "sql")
    let ddlSHA256 = disposalSHA256(ddl)
    let rationalMathSHA256 = disposalSHA256(Data(disposalRationalMathSemantics.utf8))
    let samples = try journal.frames.compactMap { frame -> DisposalRusageSample? in
        guard frame.eventType == .resource else { return nil }
        return try decodeDisposalRusageSample(
            frame: frame,
            frameID: evidence.frameIDs[frame.ordinal])
    }.sorted {
        if $0.label != $1.label { return $0.label < $1.label }
        if $0.round != $1.round { return $0.round < $1.round }
        return $0.sampleID < $1.sampleID
    }
    let intervals = try buildDisposalIntervals(samples: samples)
    let relationalExportSHA256 = disposalMetricsRelationalExport(
        evidence: evidence,
        samples: samples,
        intervals: intervals)
    let projectionID = disposalID(
        "ergentics-disposal-metrics-projection-v1",
        [
            evidence.projectionID,
            evidence.databaseSHA256,
            ddlSHA256,
            evidence.adapterSHA256,
            evidence.latticeSHA256,
            rationalMathSHA256,
            relationalExportSHA256,
        ])

    let database = try DisposalSQLiteConnection()
    guard let ddlText = String(data: ddl, encoding: .utf8) else {
        throw DisposalProjectionRejection(code: "METRICS_DDL_UTF8")
    }
    try database.execute(ddlText)
    let applicationID = try database.scalarInt("PRAGMA application_id")
    let userVersion = try database.scalarInt("PRAGMA user_version")
    try disposalRequireProjection(
        applicationID == 1_162_104_113,
        "METRICS_APPLICATION_ID")
    try disposalRequireProjection(
        userVersion == 1,
        "METRICS_USER_VERSION")
    try database.execute("BEGIN IMMEDIATE")
    do {
        let policy = try database.prepare(
            "INSERT INTO projection_policy VALUES(1,?,?,?,?,?,?)")
        try policy.bind(1, text: "ergentics_disposal_metrics_v1")
        try policy.bind(2, text: "00000000")
        try policy.bind(3, int: 0)
        try policy.bind(4, int: 0)
        try policy.bind(5, int: 0)
        try policy.bind(6, text: "EMPTY_OR_EXPLICIT_ABSTAIN_NO_STALE_FALLBACK")
        try policy.stepDone()

        let evidenceInput = try database.prepare(
            "INSERT INTO evidence_input VALUES(1,?,?,?,?,?,?)")
        try evidenceInput.bind(1, text: evidence.projectionID)
        try evidenceInput.bind(2, text: evidence.databaseSHA256)
        try evidenceInput.bind(3, int: evidence.database.count)
        try evidenceInput.bind(4, text: evidence.relationalExportSHA256)
        try evidenceInput.bind(5, text: evidence.adapterSHA256)
        try evidenceInput.bind(6, text: evidence.latticeSHA256)
        try evidenceInput.stepDone()

        let sampleStatement = try database.prepare(
            "INSERT INTO rusage_samples VALUES(" + String(repeating: "?,", count: 17) + "?)")
        let fieldStatement = try database.prepare(
            "INSERT INTO rusage_fields VALUES(?,?,?,?,?,?,?,?)")
        for sample in samples {
            sampleStatement.reset()
            try sampleStatement.bind(1, text: sample.sampleID)
            try sampleStatement.bind(2, text: sample.frameID)
            try sampleStatement.bind(3, text: sample.frameSHA256)
            try sampleStatement.bind(4, text: sample.targetID)
            try sampleStatement.bind(5, text: sample.label)
            try sampleStatement.bind(6, int: sample.round)
            try sampleStatement.bind(7, int: sample.pid)
            try sampleStatement.bind(8, text: sample.uniqueID.map(String.init))
            try sampleStatement.bind(9, text: sample.idVersion.map(String.init))
            try sampleStatement.bind(10, optionalInt: sample.sid)
            try sampleStatement.bind(11, optionalInt: sample.pgid)
            try sampleStatement.bind(12, text: sample.processUUID)
            try sampleStatement.bind(13, text: sample.rusageUUID)
            try sampleStatement.bind(14, text: sample.processStart.map(String.init))
            try sampleStatement.bind(15, text: sample.rawState)
            try sampleStatement.bind(16, text: sample.rawSHA256)
            try sampleStatement.bind(17, data: sample.raw)
            try sampleStatement.bind(18, text: sample.joinState)
            try sampleStatement.stepDone()

            for field in sample.fields.sorted(by: { $0.name < $1.name }) {
                fieldStatement.reset()
                try fieldStatement.bind(1, text: sample.sampleID)
                try fieldStatement.bind(2, text: field.name)
                try fieldStatement.bind(3, optionalInt: field.offset)
                try fieldStatement.bind(4, optionalInt: field.width)
                try fieldStatement.bind(5, text: field.value.map(String.init))
                try fieldStatement.bind(6, text: field.unit)
                try fieldStatement.bind(7, text: field.grade)
                try fieldStatement.bind(8, text: field.sourcePointer)
                try fieldStatement.stepDone()
            }
        }

        let intervalStatement = try database.prepare(
            "INSERT INTO metric_intervals VALUES(?,?,?,?,?,?,?,?,?,?,?)")
        let metricStatement = try database.prepare(
            "INSERT INTO metric_facts VALUES(?,?,?,?,?,?,?,?,?,?,?)")
        let qualificationStatement = try database.prepare(
            "INSERT INTO metric_qualifications VALUES(?,?,?,?,?)")
        var metricRows: [DisposalMetricRow] = []
        for interval in intervals {
            intervalStatement.reset()
            try intervalStatement.bind(1, text: interval.id)
            try intervalStatement.bind(2, text: interval.before.sampleID)
            try intervalStatement.bind(3, text: interval.after.sampleID)
            try intervalStatement.bind(4, text: interval.before.label)
            try intervalStatement.bind(5, text: interval.joinState)
            try intervalStatement.bind(6, text: interval.timebaseNumerator.map(String.init))
            try intervalStatement.bind(7, text: interval.timebaseDenominator.map(String.init))
            try intervalStatement.bind(8, text: interval.elapsedMinimum.map(String.init))
            try intervalStatement.bind(9, text: interval.elapsedEstimate.map(String.init))
            try intervalStatement.bind(10, text: interval.elapsedMaximum.map(String.init))
            try intervalStatement.bind(11, text: interval.state)
            try intervalStatement.stepDone()

            let rows = try interval.metrics()
            for row in rows {
                metricStatement.reset()
                try metricStatement.bind(1, text: row.id)
                try metricStatement.bind(2, text: row.intervalID)
                try metricStatement.bind(3, text: row.name)
                try metricStatement.bind(4, text: row.bound)
                try metricStatement.bind(5, text: row.rational.numerator.description)
                try metricStatement.bind(6, text: row.rational.denominator.description)
                try metricStatement.bind(7, text: row.rational.unit)
                try metricStatement.bind(8, text: row.approximation)
                try metricStatement.bind(9, text: row.sourceGrade)
                try metricStatement.bind(10, text: row.premise)
                try metricStatement.bind(11, text: row.pointer)
                try metricStatement.stepDone()
                metricRows.append(row)

                for qualification in disposalMetricQualifications(row: row, interval: interval) {
                    qualificationStatement.reset()
                    try qualificationStatement.bind(1, text: row.id)
                    try qualificationStatement.bind(2, text: qualification.0)
                    try qualificationStatement.bind(3, text: qualification.1)
                    try qualificationStatement.bind(4, text: row.pointer)
                    try qualificationStatement.bind(5, text: qualification.2)
                    try qualificationStatement.stepDone()
                }
            }
        }

        let qualificationCount = try database.scalarInt(
            "SELECT count(*) FROM metric_qualifications")
        let seal = try database.prepare(
            "INSERT INTO metrics_seal VALUES(" + String(repeating: "?,", count: 16) + "?)")
        try seal.bind(1, int: 1)
        try seal.bind(2, text: projectionID)
        try seal.bind(3, text: evidence.databaseSHA256)
        try seal.bind(4, text: ddlSHA256)
        try seal.bind(5, text: evidence.adapterSHA256)
        try seal.bind(6, text: evidence.extractorSHA256)
        try seal.bind(7, text: rationalMathSHA256)
        try seal.bind(8, text: relationalExportSHA256)
        try seal.bind(9, int: samples.count)
        try seal.bind(10, int: samples.filter { $0.rawState == "RAW_464_VERIFIED" }.count)
        try seal.bind(11, int: intervals.count)
        try seal.bind(12, int: 0)
        try seal.bind(13, int: metricRows.count)
        try seal.bind(14, int64: qualificationCount)
        try seal.bind(15, text: "00000000")
        try seal.bind(16, int: 0)
        try seal.bind(17, int: 0)
        try seal.stepDone()

        try database.execute("COMMIT")
        let integrityCheck = try database.scalarText("PRAGMA integrity_check")
        let foreignKeyFailures = try database.scalarInt(
            "SELECT count(*) FROM pragma_foreign_key_check")
        try disposalRequireProjection(
            integrityCheck == "ok",
            "METRICS_INTEGRITY_CHECK")
        try disposalRequireProjection(
            foreignKeyFailures == 0,
            "METRICS_FOREIGN_KEY_CHECK")
        let serialized = try database.serialized()
        try database.close()
        return .init(
            database: serialized,
            databaseSHA256: disposalSHA256(serialized),
            projectionID: projectionID,
            relationalExportSHA256: relationalExportSHA256,
            sampleIDs: samples.map(\.sampleID),
            metricIDs: metricRows.map(\.id),
            ddlSHA256: ddlSHA256,
            rationalMathSHA256: rationalMathSHA256)
    } catch {
        try? database.execute("ROLLBACK")
        throw error
    }
}

private struct DisposalInterval: Sendable {
    let id: String
    let before: DisposalRusageSample
    let after: DisposalRusageSample
    let joinState: String
    let timebaseNumerator: UInt64?
    let timebaseDenominator: UInt64?
    let elapsedMinimum: UInt64?
    let elapsedEstimate: UInt64?
    let elapsedMaximum: UInt64?
    let state: String

    func metrics() throws -> [DisposalMetricRow] {
        guard state == "VALID_MONOTONIC_COUNTER_INTERVAL",
              let timebaseNumerator,
              let timebaseDenominator,
              let elapsedMinimum,
              let elapsedEstimate,
              let elapsedMaximum,
              let beforeUser = before.field("user_time_ticks"),
              let afterUser = after.field("user_time_ticks"),
              let beforeSystem = before.field("system_time_ticks"),
              let afterSystem = after.field("system_time_ticks"),
              let beforeEnergy = before.field("energy_nj"),
              let afterEnergy = after.field("energy_nj")
        else { return [] }

        let deltaUser = try disposalDelta(afterUser, beforeUser)
        let deltaSystem = try disposalDelta(afterSystem, beforeSystem)
        let deltaCPU = try disposalSum(deltaUser, deltaSystem)
        let deltaEnergy = try disposalDelta(afterEnergy, beforeEnergy)
        let rawGrade = before.rawState == "RAW_464_VERIFIED" &&
            after.rawState == "RAW_464_VERIFIED"
            ? "RAW_BUFFER_EXACT_RATIONAL"
            : "PARSED_FIELDS_EXACT_RATIONAL"
        let cpuPremise = "VALID_UNDER_PINNED_TIMEBASE_AND_SCOPE"
        let energyPremise: String
        if deltaEnergy > 0 {
            energyPremise = "POSITIVE_KERNEL_TASK_ATTRIBUTED_DELTA_SCOPE_QUALIFIED"
        } else if deltaCPU > 0 {
            energyPremise = "INVALID"
        } else {
            energyPremise = "ABSTAIN_ZERO_DELTA_NO_POSITIVE_METER_SUPPORT_EVIDENCE"
        }
        let values: [(String, String, DisposalRational, String, String)] = [
            ("delta_user_ticks", "EXACT", try DisposalRational(DisposalWideUInt(deltaUser), DisposalWideUInt(1), unit: "mach_absolute_time_ticks"), cpuPremise, "/resource_sample/fields/user_time_ticks"),
            ("delta_system_ticks", "EXACT", try DisposalRational(DisposalWideUInt(deltaSystem), DisposalWideUInt(1), unit: "mach_absolute_time_ticks"), cpuPremise, "/resource_sample/fields/system_time_ticks"),
            ("delta_cpu_ticks", "EXACT", try DisposalRational(DisposalWideUInt(deltaCPU), DisposalWideUInt(1), unit: "mach_absolute_time_ticks"), cpuPremise, "/derived/delta_cpu_ticks"),
            ("cpu_time_nanoseconds", "EXACT", try disposalCPUTime(ticks: deltaCPU, timebaseNumerator: timebaseNumerator, timebaseDenominator: timebaseDenominator), cpuPremise, "/derived/cpu_time_nanoseconds"),
            ("cpu_percent_lower", "LOWER", try disposalCPUPercent(ticks: deltaCPU, elapsedNanoseconds: elapsedMaximum, timebaseNumerator: timebaseNumerator, timebaseDenominator: timebaseDenominator), cpuPremise, "/derived/cpu_percent_lower"),
            ("cpu_percent_estimated", "ESTIMATED", try disposalCPUPercent(ticks: deltaCPU, elapsedNanoseconds: elapsedEstimate, timebaseNumerator: timebaseNumerator, timebaseDenominator: timebaseDenominator), cpuPremise, "/derived/cpu_percent_estimated"),
            ("cpu_percent_upper", "UPPER", try disposalCPUPercent(ticks: deltaCPU, elapsedNanoseconds: elapsedMinimum, timebaseNumerator: timebaseNumerator, timebaseDenominator: timebaseDenominator), cpuPremise, "/derived/cpu_percent_upper"),
            ("delta_energy_nj", "EXACT", try DisposalRational(DisposalWideUInt(deltaEnergy), DisposalWideUInt(1), unit: "nanojoules"), energyPremise, "/resource_sample/fields/energy_nj"),
            ("delta_energy_joules", "EXACT", try disposalEnergyJoules(deltaEnergy), energyPremise, "/derived/delta_energy_joules"),
            ("delta_energy_ergs", "EXACT", try disposalEnergyErgs(deltaEnergy), energyPremise, "/derived/delta_energy_ergs"),
            ("power_w_lower", "LOWER", try disposalPower(nanojoules: deltaEnergy, elapsedNanoseconds: elapsedMaximum), energyPremise, "/derived/power_w_lower"),
            ("power_w_estimated", "ESTIMATED", try disposalPower(nanojoules: deltaEnergy, elapsedNanoseconds: elapsedEstimate), energyPremise, "/derived/power_w_estimated"),
            ("power_w_upper", "UPPER", try disposalPower(nanojoules: deltaEnergy, elapsedNanoseconds: elapsedMinimum), energyPremise, "/derived/power_w_upper"),
        ]
        return try values.map { value in
            let approximation = try value.2.approximation()
            return .init(
                id: disposalID(
                    "disposal-metric-v1",
                    [id, value.0, value.1, value.2.numerator.description, value.2.denominator.description]),
                intervalID: id,
                name: value.0,
                bound: value.1,
                rational: value.2,
                approximation: approximation,
                sourceGrade: rawGrade,
                premise: value.3,
                pointer: value.4)
        }
    }
}

private func decodeDisposalRusageSample(
    frame: DisposalDecodedFrame,
    frameID: String
) throws -> DisposalRusageSample {
    let payload = try frame.payloadValue()
    guard let sample = payload.member("resource_sample"), case .object = sample else {
        throw DisposalProjectionRejection(
            code: "RESOURCE_SAMPLE_OBJECT",
            frameOrdinal: frame.ordinal)
    }
    let label = try disposalObjectString(sample, "target_label", frame: frame)
    let round = try disposalObjectInt(sample, "sample_round", frame: frame)
    let pid = try disposalObjectInt(sample, "pid", frame: frame)
    let targetID = try disposalObjectOptionalString(sample, "target_id", frame: frame)
        ?? disposalID("disposal-target-v1", [label, String(pid)])
    try disposalRequireProjection(
        disposalIsLowerHex(targetID, count: 64),
        "RESOURCE_TARGET_ID",
        frameOrdinal: frame.ordinal)
    let uniqueID = try disposalObjectOptionalUIntString(sample, "uniqueid", frame: frame)
    let idVersion = try disposalObjectOptionalUIntString(sample, "idversion", frame: frame)
    let sid = try disposalObjectOptionalInt(sample, "sid", frame: frame)
    let pgid = try disposalObjectOptionalInt(sample, "pgid", frame: frame)
    let processUUID = try disposalObjectOptionalString(sample, "process_uuid_hex", frame: frame)
    let rusageUUID = try disposalObjectOptionalString(sample, "rusage_uuid_hex", frame: frame)
    for uuid in [processUUID, rusageUUID].compactMap({ $0 }) {
        try disposalRequireProjection(
            disposalIsLowerHex(uuid, count: 32),
            "RESOURCE_UUID",
            frameOrdinal: frame.ordinal)
    }
    let processStart = try disposalObjectOptionalUIntString(
        sample, "process_start_abstime", frame: frame)
    let rawState = try disposalObjectString(sample, "raw_buffer_state", frame: frame)
    let rawSHA = try disposalObjectOptionalString(sample, "raw_buffer_sha256", frame: frame)
    let rawBase64 = try disposalObjectOptionalString(sample, "raw_buffer_base64", frame: frame)
    let raw: Data?
    if rawState == "RAW_464_VERIFIED" {
        guard let rawSHA, let rawBase64, let decoded = Data(base64Encoded: rawBase64) else {
            throw DisposalProjectionRejection(
                code: "RESOURCE_RAW_BUFFER_REQUIRED",
                frameOrdinal: frame.ordinal)
        }
        try disposalRequireProjection(
            decoded.base64EncodedString() == rawBase64,
            "RESOURCE_RAW_BUFFER_BASE64_CANONICAL",
            frameOrdinal: frame.ordinal)
        try disposalRequireProjection(decoded.count == 464, "RESOURCE_RAW_BUFFER_SIZE", frameOrdinal: frame.ordinal)
        try disposalRequireProjection(
            disposalSHA256(decoded) == rawSHA,
            "RESOURCE_RAW_BUFFER_SHA256",
            frameOrdinal: frame.ordinal)
        raw = decoded
    } else {
        try disposalRequireProjection(
            rawSHA == nil && rawBase64 == nil,
            "RESOURCE_RAW_BUFFER_ABSENT_PAIR",
            frameOrdinal: frame.ordinal)
        raw = nil
    }
    let joinState = try disposalObjectString(sample, "generation_join_state", frame: frame)
    let entryNS = try disposalObjectOptionalUIntString(sample, "entry_monotonic_ns", frame: frame)
    let returnNS = try disposalObjectOptionalUIntString(sample, "return_monotonic_ns", frame: frame)
    if let entryNS, let returnNS {
        try disposalRequireProjection(
            entryNS <= returnNS,
            "RESOURCE_CALL_TIME_ORDER",
            frameOrdinal: frame.ordinal)
    }
    let timebaseNumerator = try disposalObjectOptionalUIntString(
        sample, "timebase_numerator", frame: frame)
    let timebaseDenominator = try disposalObjectOptionalUIntString(
        sample, "timebase_denominator", frame: frame)
    if timebaseNumerator != nil || timebaseDenominator != nil {
        try disposalRequireProjection(
            (timebaseNumerator ?? 0) > 0 && (timebaseDenominator ?? 0) > 0,
            "RESOURCE_TIMEBASE",
            frameOrdinal: frame.ordinal)
    }
    let fields = try disposalDecodeRusageFields(sample: sample, frame: frame, raw: raw)
    let sampleID = disposalID(
        "disposal-rusage-sample-v1",
        [frameID, label, String(round), rawSHA ?? "RAW_ABSENT"])
    return .init(
        sampleID: sampleID,
        frameID: frameID,
        frameSHA256: frame.rawWithLFSHA256,
        targetID: targetID,
        label: label,
        round: round,
        pid: pid,
        uniqueID: uniqueID,
        idVersion: idVersion,
        sid: sid,
        pgid: pgid,
        processUUID: processUUID,
        rusageUUID: rusageUUID,
        processStart: processStart,
        rawState: rawState,
        rawSHA256: rawSHA,
        raw: raw,
        joinState: joinState,
        entryNS: entryNS,
        returnNS: returnNS,
        timebaseNumerator: timebaseNumerator,
        timebaseDenominator: timebaseDenominator,
        fields: fields)
}

private func disposalDecodeRusageFields(
    sample: DisposalJSONValue,
    frame: DisposalDecodedFrame,
    raw: Data?
) throws -> [DisposalRusageField] {
    guard let value = sample.member("fields"), case .array(let entries, _) = value else {
        throw DisposalProjectionRejection(
            code: "RESOURCE_FIELDS_ARRAY",
            frameOrdinal: frame.ordinal)
    }
    var names = Set<String>()
    var fields: [DisposalRusageField] = []
    for entry in entries {
        guard case .object = entry else {
            throw DisposalProjectionRejection(
                code: "RESOURCE_FIELD_OBJECT",
                frameOrdinal: frame.ordinal)
        }
        let name = try disposalObjectString(entry, "name", frame: frame)
        try disposalRequireProjection(
            names.insert(name).inserted,
            "RESOURCE_FIELD_DUPLICATE",
            frameOrdinal: frame.ordinal,
            detail: name)
        let offset = try disposalObjectOptionalInt(entry, "byte_offset", frame: frame)
        let width = try disposalObjectOptionalInt(entry, "byte_width", frame: frame)
        let unsigned = try disposalObjectOptionalUIntString(entry, "unsigned_decimal", frame: frame)
        let unit = try disposalObjectString(entry, "unit", frame: frame)
        let grade = try disposalObjectString(entry, "raw_verification_grade", frame: frame)
        let pointer = try disposalObjectOptionalString(entry, "source_json_pointer", frame: frame)
        if grade == "RAW_464_OFFSET_VERIFIED" {
            guard let raw, let offset, let width, width == 8, let unsigned else {
                throw DisposalProjectionRejection(
                    code: "RESOURCE_FIELD_RAW_REQUIREMENTS",
                    frameOrdinal: frame.ordinal,
                    detail: name)
            }
            try disposalRequireProjection(
                offset >= 0 && offset + width <= raw.count,
                "RESOURCE_FIELD_RAW_RANGE",
                frameOrdinal: frame.ordinal,
                detail: name)
            let decoded = raw.subdata(in: offset..<(offset + width)).withUnsafeBytes {
                $0.loadUnaligned(as: UInt64.self).littleEndian
            }
            try disposalRequireProjection(
                decoded == unsigned,
                "RESOURCE_FIELD_RAW_VALUE",
                frameOrdinal: frame.ordinal,
                detail: name)
        }
        fields.append(.init(
            name: name,
            offset: offset,
            width: width,
            value: unsigned,
            unit: unit,
            grade: grade,
            sourcePointer: pointer))
    }
    return fields
}

private func buildDisposalIntervals(samples: [DisposalRusageSample]) throws -> [DisposalInterval] {
    let groups = Dictionary(grouping: samples, by: \.label)
    var result: [DisposalInterval] = []
    for label in groups.keys.sorted() {
        let ordered = groups[label]!.sorted { $0.round < $1.round }
        guard ordered.count >= 2 else { continue }
        for index in 1..<ordered.count {
            let before = ordered[index - 1]
            let after = ordered[index]
            guard after.round == before.round + 1 else { continue }
            let join = before.pid == after.pid &&
                before.uniqueID != nil && before.uniqueID == after.uniqueID &&
                before.idVersion != nil && before.idVersion == after.idVersion &&
                before.sid != nil && before.sid == after.sid &&
                before.pgid != nil && before.pgid == after.pgid &&
                before.rusageUUID != nil && before.rusageUUID == after.rusageUUID &&
                before.processStart != nil && before.processStart == after.processStart &&
                before.joinState == "EXACT_GENERATION_SESSION_GROUP_UUID_START_JOIN" &&
                after.joinState == "EXACT_GENERATION_SESSION_GROUP_UUID_START_JOIN"
            let timebaseMatch = before.timebaseNumerator != nil &&
                before.timebaseNumerator == after.timebaseNumerator &&
                before.timebaseDenominator != nil &&
                before.timebaseDenominator == after.timebaseDenominator
            var elapsedMinimum: UInt64?
            var elapsedEstimate: UInt64?
            var elapsedMaximum: UInt64?
            var state = "ABSTAIN_MISSING_INPUT"
            if join, timebaseMatch,
               let beforeEntry = before.entryNS,
               let beforeReturn = before.returnNS,
               let afterEntry = after.entryNS,
               let afterReturn = after.returnNS,
               beforeEntry <= beforeReturn,
               beforeReturn < afterEntry,
               afterEntry <= afterReturn
            {
                elapsedMinimum = try disposalDelta(afterEntry, beforeReturn)
                elapsedMaximum = try disposalDelta(afterReturn, beforeEntry)
                let beforeMid = beforeEntry + (beforeReturn - beforeEntry) / 2
                let afterMid = afterEntry + (afterReturn - afterEntry) / 2
                elapsedEstimate = try disposalDelta(afterMid, beforeMid)
                if let elapsedMinimum, let elapsedEstimate, let elapsedMaximum,
                   elapsedMinimum > 0,
                   elapsedMinimum <= elapsedEstimate,
                   elapsedEstimate <= elapsedMaximum
                {
                    let required = [
                        before.field("user_time_ticks"), after.field("user_time_ticks"),
                        before.field("system_time_ticks"), after.field("system_time_ticks"),
                        before.field("energy_nj"), after.field("energy_nj"),
                    ]
                    if required.allSatisfy({ $0 != nil }) {
                        do {
                            _ = try disposalDelta(after.field("user_time_ticks")!, before.field("user_time_ticks")!)
                            _ = try disposalDelta(after.field("system_time_ticks")!, before.field("system_time_ticks")!)
                            _ = try disposalDelta(after.field("energy_nj")!, before.field("energy_nj")!)
                            state = "VALID_MONOTONIC_COUNTER_INTERVAL"
                        } catch {
                            state = "INVALID_COUNTER_REGRESSION"
                        }
                    }
                } else {
                    state = "INVALID_TIME_BOUND_ORDER"
                }
            } else if !join {
                state = "INVALID_GENERATION_JOIN"
            }
            result.append(.init(
                id: disposalID(
                    "disposal-metric-interval-v1",
                    [before.sampleID, after.sampleID, state]),
                before: before,
                after: after,
                joinState: join
                    ? "EXACT_GENERATION_SESSION_GROUP_UUID_START_JOIN"
                    : "DRIFT",
                timebaseNumerator: timebaseMatch ? before.timebaseNumerator : nil,
                timebaseDenominator: timebaseMatch ? before.timebaseDenominator : nil,
                elapsedMinimum: elapsedMinimum,
                elapsedEstimate: elapsedEstimate,
                elapsedMaximum: elapsedMaximum,
                state: state))
        }
    }
    return result.sorted { $0.id < $1.id }
}

private func disposalMetricQualifications(
    row: DisposalMetricRow,
    interval: DisposalInterval
) -> [(String, String, String)] {
    var values: [(String, String, String)] = [
        ("RAW_BUFFER_STATE", interval.before.rawState + "+" + interval.after.rawState, "SOURCE_POINTER_EXACT"),
    ]
    if row.name.contains("energy") || row.name.contains("power") {
        values.append(("ATTRIBUTION", "KERNEL_RECOUNT_DIRECT_TASK_ATTRIBUTION_AT_CONTEXT_SWITCH_GRANULARITY", "OFFLINE_RULE_EXACT"))
        for exclusion in ["NOT_WALL_PLUG", "NOT_PACKAGE", "NOT_GPU", "NOT_ANE"] {
            values.append(("EXCLUDES", exclusion, "OFFLINE_RULE_EXACT"))
        }
        values.append(("SCOPE", "PER_PROCESS_COUNTER_NOT_PHYSICALLY_CONSERVED_TOTAL", "OFFLINE_RULE_EXACT"))
    } else {
        values.append(("TIMEBASE", "CAPTURED_NUMERATOR_DENOMINATOR_REQUIRED", "OFFLINE_RULE_EXACT"))
    }
    return values
}

private func disposalMetricsRelationalExport(
    evidence: DisposalEvidenceMaterial,
    samples: [DisposalRusageSample],
    intervals: [DisposalInterval]
) -> String {
    var data = Data()
    for field in [evidence.projectionID, evidence.databaseSHA256, evidence.relationalExportSHA256] {
        data.append(contentsOf: field.utf8)
        data.append(0x0a)
    }
    for sample in samples {
        data.append(contentsOf: [
            sample.sampleID, sample.frameID, sample.label, String(sample.round),
            String(sample.pid), sample.uniqueID.map(String.init) ?? "NULL",
            sample.idVersion.map(String.init) ?? "NULL", sample.rawState,
            sample.rawSHA256 ?? "NULL", sample.joinState,
        ].joined(separator: "\t").utf8)
        data.append(0x0a)
        for field in sample.fields.sorted(by: { $0.name < $1.name }) {
            data.append(contentsOf: [
                sample.sampleID, field.name, field.value.map(String.init) ?? "NULL",
                field.unit, field.grade,
            ].joined(separator: "\t").utf8)
            data.append(0x0a)
        }
    }
    for interval in intervals {
        data.append(contentsOf: [
            interval.id, interval.before.sampleID, interval.after.sampleID,
            interval.state, interval.joinState,
        ].joined(separator: "\t").utf8)
        data.append(0x0a)
    }
    return disposalSHA256(data)
}

private func disposalObjectString(
    _ object: DisposalJSONValue,
    _ key: String,
    frame: DisposalDecodedFrame
) throws -> String {
    guard let value = object.member(key)?.stringValue() else {
        throw DisposalProjectionRejection(
            code: "RESOURCE_REQUIRED_STRING",
            frameOrdinal: frame.ordinal,
            detail: key)
    }
    return value
}

private func disposalObjectOptionalString(
    _ object: DisposalJSONValue,
    _ key: String,
    frame: DisposalDecodedFrame
) throws -> String? {
    guard let member = object.member(key) else { return nil }
    if case .null = member { return nil }
    guard let value = member.stringValue() else {
        throw DisposalProjectionRejection(
            code: "RESOURCE_OPTIONAL_STRING",
            frameOrdinal: frame.ordinal,
            detail: key)
    }
    return value
}

private func disposalObjectInt(
    _ object: DisposalJSONValue,
    _ key: String,
    frame: DisposalDecodedFrame
) throws -> Int {
    guard let lexeme = object.member(key)?.numberLexeme(),
          let value = Int(lexeme), String(value) == lexeme
    else {
        throw DisposalProjectionRejection(
            code: "RESOURCE_REQUIRED_INT",
            frameOrdinal: frame.ordinal,
            detail: key)
    }
    return value
}

private func disposalObjectOptionalInt(
    _ object: DisposalJSONValue,
    _ key: String,
    frame: DisposalDecodedFrame
) throws -> Int? {
    guard let member = object.member(key) else { return nil }
    if case .null = member { return nil }
    guard let lexeme = member.numberLexeme(),
          let value = Int(lexeme), String(value) == lexeme
    else {
        throw DisposalProjectionRejection(
            code: "RESOURCE_OPTIONAL_INT",
            frameOrdinal: frame.ordinal,
            detail: key)
    }
    return value
}

private func disposalObjectOptionalUIntString(
    _ object: DisposalJSONValue,
    _ key: String,
    frame: DisposalDecodedFrame
) throws -> UInt64? {
    guard let member = object.member(key) else { return nil }
    if case .null = member { return nil }
    guard let lexeme = member.stringValue(),
          let value = UInt64(lexeme), String(value) == lexeme
    else {
        throw DisposalProjectionRejection(
            code: "RESOURCE_OPTIONAL_UINT_STRING",
            frameOrdinal: frame.ordinal,
            detail: key)
    }
    return value
}
