#if DEBUG
import Foundation

/// Closed predicate identifiers and explicitly selected operands only. Never
/// put localized error descriptions, NSError.userInfo or environment values here.
struct DeltaPUGUICheckFailure: Error, Codable, Equatable, Sendable {
    let category: String
    let predicate: String
    let operands: [String: String]

    /// A string preserves finite values, signed zero and every NaN payload
    /// without asking JSON to represent nonfinite numbers.
    static func binary64(_ value: Double) -> String {
        let digits = String(value.bitPattern, radix: 16)
        return "binary64:0x" + String(repeating: "0", count: 16 - digits.count) + digits
    }
}

private func requireGUI(_ accepted: @autoclosure () -> Bool, category: String,
                        predicate: String, operands: @autoclosure () -> [String: String]) throws {
    guard accepted() else {
        throw DeltaPUGUICheckFailure(category: category, predicate: predicate, operands: operands())
    }
}

private func compareGUI<T: Encodable & Equatable>(_ actual: T, _ expected: T,
                                                  category: String, predicate: String) throws {
    guard actual != expected else { return }
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
    throw DeltaPUGUICheckFailure(category: category, predicate: predicate, operands: [
        "actual": String(decoding: try encoder.encode(actual), as: UTF8.self),
        "expected": String(decoding: try encoder.encode(expected), as: UTF8.self)
    ])
}

/// A separate failure-only stderr frame. It does not amend a successful
/// frame, claim PASS/exit/retention, or grant execution/distribution authority.
struct DeltaPUGUIFailureReceipt: Codable, Equatable, Sendable {
    static let expectedSchema = "com.ergentics.provenance.deltapu-gui-failure.v1"
    static let prefix = "ERGENTICS_DELTAPU_GUI_FAILURE_V1 "
    static let maximumFrameBytes = 65_536
    static let expectedScope = "Caught local readiness failure; not PASS, process exit, retention, guest execution or authority"

    let schema: String
    let scope: String
    let status: String
    let pid: Int32
    let runID: String
    let stage: String
    let clock: String
    let caughtTicks: String
    let errorType: String
    let errorDomain: String
    let errorCode: Int
    let failure: DeltaPUGUICheckFailure?
    let gateE: String
    let authorityVector: String

    init(pid: Int32, runID: UUID, stage: String, caughtTicks: UInt64, error: Error) {
        schema = Self.expectedSchema; scope = Self.expectedScope; status = "INCOMPLETE"
        self.pid = pid; self.runID = runID.uuidString.lowercased(); self.stage = stage
        clock = "mach_continuous_time"; self.caughtTicks = String(caughtTicks)
        errorType = String(reflecting: type(of: error))
        let native = error as NSError
        errorDomain = native.domain; errorCode = native.code
        failure = error as? DeltaPUGUICheckFailure
        gateE = "ABSTAIN"; authorityVector = "00000000"
    }

    enum Failure: Error, Equatable { case frame, identity, policy, bounds }

    func frame() throws -> Data {
        guard schema == Self.expectedSchema, scope == Self.expectedScope, status == "INCOMPLETE",
              clock == "mach_continuous_time", gateE == "ABSTAIN", authorityVector == "00000000" else {
            throw Failure.policy
        }
        guard pid > 0, let uuid = UUID(uuidString: runID), uuid.uuidString.lowercased() == runID,
              let ticks = UInt64(caughtTicks), String(ticks) == caughtTicks else { throw Failure.identity }
        guard !stage.isEmpty, stage.utf8.count <= 256, !errorType.isEmpty,
              errorType.utf8.count <= 1_024, errorDomain.utf8.count <= 1_024 else { throw Failure.bounds }
        if let failure {
            guard !failure.category.isEmpty, failure.category.utf8.count <= 128,
                  !failure.predicate.isEmpty, failure.predicate.utf8.count <= 1_024,
                  failure.operands.count <= 128 else { throw Failure.bounds }
            var operandBytes = 0
            for (key, value) in failure.operands {
                for count in [key.utf8.count, value.utf8.count] {
                    guard count <= Self.maximumFrameBytes - operandBytes else { throw Failure.bounds }
                    operandBytes += count
                }
            }
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        var bytes = Data(Self.prefix.utf8)
        bytes.append(try encoder.encode(self)); bytes.append(10)
        guard bytes.count <= Self.maximumFrameBytes else { throw Failure.bounds }
        return bytes
    }

    static func decodeFrame(_ bytes: Data) throws -> Self {
        let prefix = Data(Self.prefix.utf8)
        guard bytes.count <= maximumFrameBytes, bytes.count > prefix.count + 1,
              bytes.starts(with: prefix), bytes.last == 10 else { throw Failure.frame }
        let decoded = try JSONDecoder().decode(Self.self, from: Data(bytes.dropFirst(prefix.count).dropLast()))
        guard try decoded.frame() == bytes else { throw Failure.frame }
        return decoded
    }
}

struct DeltaPUGUISurface: Codable, Equatable, Sendable {
    let role: String
    let windowNumber: Int
    let attached: Bool
    let visibleWindow: Bool
    let miniaturized: Bool
    let hidden: Bool
    let boundsX: Double
    let boundsY: Double
    let width: Double
    let height: Double
    let visibleX: Double
    let visibleY: Double
    let visibleWidth: Double
    let visibleHeight: Double
    let clipsToBounds: Bool
    let boundStateID: String
    let boundRowIDs: [UInt32]

    /// One predicate for the polling sample and the final prepared frame.
    /// These are raw marker-local rectangles, not corrected intersections or
    /// proof that content pixels are unobscured or that every row is visible.
    func validationFailure(field: String, expectedRole: String, expectedStateID: String,
                           expectedRowIDs: [UInt32]) -> DeltaPUGUICheckFailure? {
        let boundsMaxX = boundsX + width, boundsMaxY = boundsY + height
        let visibleMaxX = visibleX + visibleWidth, visibleMaxY = visibleY + visibleHeight
        let operands = [
            "role": role, "expectedRole": expectedRole, "windowNumber": String(windowNumber),
            "attached": String(attached), "visibleWindow": String(visibleWindow),
            "miniaturized": String(miniaturized), "hidden": String(hidden),
            "clipsToBounds": String(clipsToBounds),
            "boundsX": DeltaPUGUICheckFailure.binary64(boundsX),
            "boundsY": DeltaPUGUICheckFailure.binary64(boundsY),
            "width": DeltaPUGUICheckFailure.binary64(width),
            "height": DeltaPUGUICheckFailure.binary64(height),
            "visibleX": DeltaPUGUICheckFailure.binary64(visibleX),
            "visibleY": DeltaPUGUICheckFailure.binary64(visibleY),
            "visibleWidth": DeltaPUGUICheckFailure.binary64(visibleWidth),
            "visibleHeight": DeltaPUGUICheckFailure.binary64(visibleHeight),
            "boundsMaxX": DeltaPUGUICheckFailure.binary64(boundsMaxX),
            "boundsMaxY": DeltaPUGUICheckFailure.binary64(boundsMaxY),
            "visibleMaxX": DeltaPUGUICheckFailure.binary64(visibleMaxX),
            "visibleMaxY": DeltaPUGUICheckFailure.binary64(visibleMaxY),
            "stateID": boundStateID, "expectedStateID": expectedStateID,
            "rowIDs": boundRowIDs.map(String.init).joined(separator: ","),
            "expectedRowIDs": expectedRowIDs.map(String.init).joined(separator: ",")
        ]
        func failure(_ predicate: String, actual: Double? = nil,
                     exclusiveMinimum: Double? = nil) -> DeltaPUGUICheckFailure {
            var retained = operands
            if let actual { retained["actual"] = DeltaPUGUICheckFailure.binary64(actual) }
            if let exclusiveMinimum {
                retained["exclusiveMinimum"] = DeltaPUGUICheckFailure.binary64(exclusiveMinimum)
            }
            return DeltaPUGUICheckFailure(category: "surface", predicate: "\(field).\(predicate)", operands: retained)
        }
        for (predicate, accepted) in [
            ("role", role == expectedRole), ("windowNumber.positive", windowNumber > 0),
            ("attached", attached), ("visibleWindow", visibleWindow),
            ("miniaturized", !miniaturized), ("hidden", !hidden), ("clipsToBounds", clipsToBounds)
        ] where !accepted { return failure(predicate) }
        for (name, value) in [("boundsX", boundsX), ("boundsY", boundsY),
                              ("visibleX", visibleX), ("visibleY", visibleY),
                              ("width", width), ("height", height),
                              ("visibleWidth", visibleWidth), ("visibleHeight", visibleHeight)] {
            if !value.isFinite { return failure("\(name).finite", actual: value) }
        }
        for (name, value) in [("width", width), ("height", height),
                              ("visibleWidth", visibleWidth), ("visibleHeight", visibleHeight)] {
            if value <= 0 { return failure("\(name).positive", actual: value, exclusiveMinimum: 0) }
        }
        for (name, endpoint, origin) in [("boundsMaxX", boundsMaxX, boundsX),
                                        ("boundsMaxY", boundsMaxY, boundsY),
                                        ("visibleMaxX", visibleMaxX, visibleX),
                                        ("visibleMaxY", visibleMaxY, visibleY)] {
            if !endpoint.isFinite { return failure("\(name).finite", actual: endpoint) }
            // Reject a positive dimension lost to binary64 addition as well
            // as nonpositive extents; do not silently standardize a rectangle.
            if endpoint <= origin {
                return failure("\(name).positiveExtent", actual: endpoint, exclusiveMinimum: origin)
            }
        }
        for (predicate, accepted) in [
            ("visibleWidth.withinWidth", visibleWidth <= width),
            ("visibleHeight.withinHeight", visibleHeight <= height),
            ("visibleX.withinBoundsMinX", visibleX >= boundsX),
            ("visibleY.withinBoundsMinY", visibleY >= boundsY),
            ("visibleMaxX.withinBoundsMaxX", visibleMaxX <= boundsMaxX),
            ("visibleMaxY.withinBoundsMaxY", visibleMaxY <= boundsMaxY),
            ("boundStateID", boundStateID == expectedStateID),
            ("boundRowIDs", boundRowIDs == expectedRowIDs)
        ] where !accepted { return failure(predicate) }
        return nil
    }
}

struct DeltaPUGUIRow: Codable, Equatable, Sendable {
    let id: UInt32
    let oldValue: Int64?
    let newValue: Int64?
    let definitionChanged: Bool
    let statusRaw: String

    init(_ row: DeltaPUVerifiedNode) {
        id = row.id; oldValue = row.oldValue; newValue = row.newValue
        definitionChanged = row.definitionChanged; statusRaw = row.status.rawValue
    }
}

struct DeltaPUGUIWork: Codable, Equatable, Sendable {
    let submittedEdits: Int
    let changedDefinitions: Int
    let nodesValidated: Int
    let operandEdgesValidated: Int
    let invalidatedNodes: Int
    let invalidationEdgesVisited: Int
    let nodesEvaluated: Int
    let operandReads: Int
    let valuesReused: Int
    let outputComparisons: Int
    let commitmentPayloadBytes: Int

    init(_ work: DeltaPUWork) {
        submittedEdits = work.submittedEdits; changedDefinitions = work.changedDefinitions
        nodesValidated = work.nodesValidated; operandEdgesValidated = work.operandEdgesValidated
        invalidatedNodes = work.invalidatedNodes; invalidationEdgesVisited = work.invalidationEdgesVisited
        nodesEvaluated = work.nodesEvaluated; operandReads = work.operandReads; valuesReused = work.valuesReused
        outputComparisons = work.outputComparisons; commitmentPayloadBytes = work.commitmentPayloadBytes
    }
}

struct DeltaPUGUIFixture: Codable, Equatable, Sendable {
    let scenario: String
    let scenarioTitle: String
    let beforeStateID: String
    let afterStateID: String
    let beforeContentRoot: String
    let afterContentRoot: String
    let deltaID: String
    let beforeContentCBOR: Data
    let beforeVersionCBOR: Data
    let deltaCBOR: Data
    let afterContentCBOR: Data
    let afterVersionCBOR: Data
    let rows: [DeltaPUGUIRow]
    let work: DeltaPUGUIWork
    let beforeNodeEvaluations: Int
    let afterNodeEvaluations: Int
    let afterOperandReads: Int

    init(_ report: DeltaPUDemoReport) {
        scenario = report.scenario.rawValue; scenarioTitle = report.scenario.title
        beforeStateID = report.before.stateID; afterStateID = report.transition.snapshot.stateID
        beforeContentRoot = report.before.contentRoot; afterContentRoot = report.transition.snapshot.contentRoot
        deltaID = report.transition.deltaID
        beforeContentCBOR = report.before.contentCBOR; beforeVersionCBOR = report.before.versionCBOR
        deltaCBOR = report.transition.deltaCBOR
        afterContentCBOR = report.transition.snapshot.contentCBOR; afterVersionCBOR = report.transition.snapshot.versionCBOR
        rows = report.verification.rows.map(DeltaPUGUIRow.init)
        work = DeltaPUGUIWork(report.transition.work)
        beforeNodeEvaluations = report.verification.beforeNodeEvaluations
        afterNodeEvaluations = report.verification.afterNodeEvaluations
        afterOperandReads = report.verification.afterOperandReads
    }
}

/// Separate Codable projection: the existing ReadinessAssessment observation
/// is Encodable-only. No lifecycle controller is invoked by this value type.
struct DeltaPUGUILifecycle: Codable, Equatable, Sendable {
    let clock: String
    let runID: String
    let phase: String
    let startTicks: String
    let observationTicks: String
    let timebaseNumerator: UInt32
    let timebaseDenominator: UInt32
    let clockValid: Bool
    let workBudgetExpired: Bool
    let canceled: Bool
    let workCompleted: Bool
    let fallbackArmed: Bool

    init(_ value: AppLifecyclePolicy.ReadinessSnapshot) {
        clock = "mach_continuous_time"
        runID = value.runID.uuidString.lowercased(); phase = value.phase.rawValue
        startTicks = String(value.startTicks); observationTicks = String(value.observationTicks)
        timebaseNumerator = value.timebaseNumerator; timebaseDenominator = value.timebaseDenominator
        clockValid = value.clockValid; workBudgetExpired = value.workBudgetExpired
        canceled = value.canceled; workCompleted = value.workCompleted; fallbackArmed = value.fallbackArmed
    }

    var withinWorkBudgetAtPreparation: Bool {
        do { try validateForPreparation(); return true } catch { return false }
    }

    /// Same strict rational budget and predicates as the Boolean projection,
    /// with the first rejected operand retained for the diagnostic frame.
    func validateForPreparation() throws {
        try compareGUI(clock, "mach_continuous_time", category: "lifecycle", predicate: "lifecycle.clock")
        guard let uuid = UUID(uuidString: runID) else {
            throw DeltaPUGUICheckFailure(category: "lifecycle", predicate: "lifecycle.runID.uuid",
                                         operands: ["actual": runID])
        }
        try compareGUI(runID, uuid.uuidString.lowercased(), category: "lifecycle", predicate: "lifecycle.runID.canonical")
        try compareGUI(phase, "working", category: "lifecycle", predicate: "lifecycle.phase")
        for (field, actual, expected) in [("clockValid", clockValid, true),
            ("workBudgetExpired", workBudgetExpired, false), ("canceled", canceled, false),
            ("workCompleted", workCompleted, false), ("fallbackArmed", fallbackArmed, true)] {
            try compareGUI(actual, expected, category: "lifecycle", predicate: "lifecycle.\(field)")
        }
        try requireGUI(timebaseNumerator > 0, category: "lifecycle", predicate: "lifecycle.timebaseNumerator.positive",
                       operands: ["actual": String(timebaseNumerator), "exclusiveMinimum": "0"])
        try requireGUI(timebaseDenominator > 0, category: "lifecycle", predicate: "lifecycle.timebaseDenominator.positive",
                       operands: ["actual": String(timebaseDenominator), "exclusiveMinimum": "0"])
        guard let start = UInt64(startTicks) else {
            throw DeltaPUGUICheckFailure(category: "lifecycle", predicate: "lifecycle.startTicks.uint64",
                                         operands: ["actual": startTicks])
        }
        try compareGUI(startTicks, String(start), category: "lifecycle", predicate: "lifecycle.startTicks.canonical")
        guard let end = UInt64(observationTicks) else {
            throw DeltaPUGUICheckFailure(category: "lifecycle", predicate: "lifecycle.observationTicks.uint64",
                                         operands: ["actual": observationTicks])
        }
        try compareGUI(observationTicks, String(end), category: "lifecycle", predicate: "lifecycle.observationTicks.canonical")
        try requireGUI(end >= start, category: "lifecycle", predicate: "lifecycle.ticks.monotonic",
                       operands: ["start": String(start), "end": String(end)])
        let elapsed = (end - start).multipliedFullWidth(by: UInt64(timebaseNumerator))
        let budget = UInt64(10_000_000_000).multipliedFullWidth(by: UInt64(timebaseDenominator))
        try requireGUI(elapsed.high < budget.high || (elapsed.high == budget.high && elapsed.low < budget.low),
                       category: "lifecycle", predicate: "lifecycle.elapsed.strictlyWithinWorkBudget",
                       operands: ["startTicks": String(start), "observationTicks": String(end),
                           "timebaseNumerator": String(timebaseNumerator), "timebaseDenominator": String(timebaseDenominator),
                           "workBudgetNanoseconds": "10000000000", "elapsedHigh": String(elapsed.high),
                           "elapsedLow": String(elapsed.low), "budgetHigh": String(budget.high), "budgetLow": String(budget.low)])
    }
}

/// Prepared mounted-view observations only. Exact process exit, capture
/// retention and child reap are necessarily external, later observations.
struct DeltaPUGUIReadinessReport: Codable, Equatable, Sendable {
    static let expectedSchema = "com.ergentics.provenance.deltapu-gui-readiness.v2"
    static let prefix = "ERGENTICS_DELTAPU_GUI_READINESS_V2 "
    static let maximumFrameBytes = 65_536
    static let expectedScope = "Prepared programmatic sparse workflow and mounted-view bindings; not physical input, cell pixels, process exit, guest execution or authority"

    let schema: String
    let scope: String
    let pid: Int32
    let bundleIdentifier: String
    let executablePath: String
    let team: String
    let signatureAdmitted: Bool
    let environmentNamesAtStart: [String]
    let environmentNamesAtObservation: [String]
    let lifecycle: DeltaPUGUILifecycle
    let pageBefore: DeltaPUGUISurface
    let pageAfter: DeltaPUGUISurface
    let result: DeltaPUGUISurface
    let table: DeltaPUGUISurface
    let sameWindowIdentity: Bool
    let initialDemoIdle: Bool
    let labStartupSkipped: Bool
    let capabilityQueriesSkipped: Bool
    let guestIdle: Bool
    let gitIdle: Bool
    let fixture: DeltaPUGUIFixture
    let processExit: String
    let outputRetention: String
    let guestExecution: String
    let energyErgs: String
    let gateE: String
    let authorityVector: String

    init(pid: Int32, bundleIdentifier: String, executablePath: String, team: String,
         signatureAdmitted: Bool, environmentNamesAtStart: [String], environmentNamesAtObservation: [String],
         lifecycle: DeltaPUGUILifecycle, pageBefore: DeltaPUGUISurface, pageAfter: DeltaPUGUISurface,
         result: DeltaPUGUISurface, table: DeltaPUGUISurface, sameWindowIdentity: Bool,
         initialDemoIdle: Bool, labStartupSkipped: Bool, capabilityQueriesSkipped: Bool,
         guestIdle: Bool, gitIdle: Bool, fixture: DeltaPUGUIFixture) {
        schema = Self.expectedSchema; scope = Self.expectedScope
        self.pid = pid; self.bundleIdentifier = bundleIdentifier; self.executablePath = executablePath
        self.team = team; self.signatureAdmitted = signatureAdmitted
        self.environmentNamesAtStart = environmentNamesAtStart
        self.environmentNamesAtObservation = environmentNamesAtObservation
        self.lifecycle = lifecycle; self.pageBefore = pageBefore; self.pageAfter = pageAfter
        self.result = result; self.table = table; self.sameWindowIdentity = sameWindowIdentity
        self.initialDemoIdle = initialDemoIdle; self.labStartupSkipped = labStartupSkipped
        self.capabilityQueriesSkipped = capabilityQueriesSkipped; self.guestIdle = guestIdle; self.gitIdle = gitIdle
        self.fixture = fixture
        processExit = "NOT_OBSERVED_IN_PREPARED_FRAME"; outputRetention = "NOT_OBSERVED_IN_PREPARED_FRAME"
        guestExecution = "NOT_RUN"; energyErgs = "UNMEASURED"; gateE = "ABSTAIN"; authorityVector = "00000000"
    }

    /// Full admission requires independently rechecking the provided closed
    /// sparse fixture; caller-supplied verification rows are not trusted alone.
    func validate(expectedDemo: DeltaPUDemoReport) throws {
        try validateObservations()
        try compareGUI(expectedDemo.scenario.rawValue, "sparse", category: "fixture", predicate: "expectedDemo.scenario")
        let checked: DeltaPUVerifiedTransition
        do {
            checked = try DeltaPUDemonstration.verify(scenario: .sparse, before: expectedDemo.before,
                delta: expectedDemo.delta, transition: expectedDemo.transition)
        } catch {
            let native = error as NSError
            throw DeltaPUGUICheckFailure(category: "fixture", predicate: "expectedDemo.independentVerification",
                operands: ["errorType": String(reflecting: type(of: error)), "errorDomain": native.domain,
                           "errorCode": String(native.code), "beforeStateID": expectedDemo.before.stateID,
                           "afterStateID": expectedDemo.transition.snapshot.stateID,
                           "deltaID": expectedDemo.transition.deltaID])
        }
        try compareRows(checked.rows.map(DeltaPUGUIRow.init), expectedDemo.verification.rows.map(DeltaPUGUIRow.init),
                        path: "expectedDemo.verification.rows")
        try compareGUI(checked.beforeNodeEvaluations, expectedDemo.verification.beforeNodeEvaluations,
                       category: "fixture", predicate: "expectedDemo.verification.beforeNodeEvaluations")
        try compareGUI(checked.afterNodeEvaluations, expectedDemo.verification.afterNodeEvaluations,
                       category: "fixture", predicate: "expectedDemo.verification.afterNodeEvaluations")
        try compareGUI(checked.afterOperandReads, expectedDemo.verification.afterOperandReads,
                       category: "fixture", predicate: "expectedDemo.verification.afterOperandReads")
        // Preserve whole-value equality as a fail-closed backstop if either
        // value type gains a field before its detailed diagnostic is added.
        try requireGUI(checked == expectedDemo.verification, category: "fixture", predicate: "expectedDemo.verification.wholeValue",
                       operands: ["explicitFieldChecks": "matched", "wholeValueEqual": "false"])
        let expectedFixture = DeltaPUGUIFixture(expectedDemo)
        try validateFixtureMatches(expectedFixture)
        try requireGUI(fixture == expectedFixture, category: "fixture", predicate: "fixture.wholeValue",
                       operands: ["explicitFieldChecks": "matched", "wholeValueEqual": "false"])
    }

    func frame() throws -> Data {
        try validateObservations()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        var bytes = Data(Self.prefix.utf8)
        bytes.append(try encoder.encode(self)); bytes.append(10)
        try requireGUI(bytes.count <= Self.maximumFrameBytes, category: "frame", predicate: "frame.maximumBytes",
                       operands: ["actualBytes": String(bytes.count), "maximumBytes": String(Self.maximumFrameBytes)])
        return bytes
    }

    static func decodeFrame(_ bytes: Data) throws -> DeltaPUGUIReadinessReport {
        let prefix = Data(Self.prefix.utf8)
        guard bytes.count <= maximumFrameBytes, bytes.count > prefix.count + 1,
              bytes.starts(with: prefix), bytes.last == 10 else { throw Failure.frame }
        let body = Data(bytes.dropFirst(prefix.count).dropLast())
        let decoded = try JSONDecoder().decode(Self.self, from: body)
        // Re-encoding rejects ignored unknown keys at every nesting level,
        // duplicate keys, noncanonical numeric spelling, whitespace and tails.
        guard try decoded.frame() == bytes else { throw Failure.frame }
        return decoded
    }

    enum Failure: Error, Equatable { case identity, environment, lifecycle, surface, fixture, frame, policy }

    private func validateObservations() throws {
        for (field, actual, expected) in [("schema", schema, Self.expectedSchema), ("scope", scope, Self.expectedScope),
            ("processExit", processExit, "NOT_OBSERVED_IN_PREPARED_FRAME"),
            ("outputRetention", outputRetention, "NOT_OBSERVED_IN_PREPARED_FRAME"),
            ("guestExecution", guestExecution, "NOT_RUN"), ("energyErgs", energyErgs, "UNMEASURED"),
            ("gateE", gateE, "ABSTAIN"), ("authorityVector", authorityVector, "00000000")] {
            try compareGUI(actual, expected, category: "policy", predicate: field)
        }
        try requireGUI(pid > 0, category: "identity", predicate: "pid.positive",
                       operands: ["actual": String(pid), "exclusiveMinimum": "0"])
        try compareGUI(bundleIdentifier, "com.ergentics.provenance", category: "identity", predicate: "bundleIdentifier")
        try compareGUI(team, "ZCQ435U8JP", category: "identity", predicate: "team")
        try compareGUI(signatureAdmitted, true, category: "identity", predicate: "signatureAdmitted")
        try requireGUI(executablePath.hasPrefix("/"), category: "identity", predicate: "executablePath.absolute",
                       operands: ["actual": executablePath, "requiredPrefix": "/"])
        try requireGUI(executablePath.utf8.count <= 4096, category: "identity", predicate: "executablePath.maximumBytes",
                       operands: ["actualBytes": String(executablePath.utf8.count), "maximumBytes": "4096"])
        try requireGUI(!executablePath.utf8.contains(0), category: "identity", predicate: "executablePath.noNUL",
                       operands: ["containsNUL": "true"])
        for (field, names) in [("environmentNamesAtStart", environmentNamesAtStart),
                               ("environmentNamesAtObservation", environmentNamesAtObservation)] {
            // Counts and predicate booleans are enough here. An invalid name
            // could actually be NAME=value, so never echo the rejected string.
            try requireGUI(names == Set(names).sorted(), category: "environment", predicate: "\(field).sortedUnique",
                           operands: ["count": String(names.count), "uniqueCount": String(Set(names).count),
                                      "sorted": String(names == names.sorted())])
            for (index, name) in names.enumerated() {
                try requireGUI(!name.isEmpty, category: "environment", predicate: "\(field)[\(index)].nonempty",
                               operands: ["index": String(index), "utf8Bytes": String(name.utf8.count)])
                try requireGUI(!name.utf8.contains(0), category: "environment", predicate: "\(field)[\(index)].noNUL",
                               operands: ["index": String(index), "containsNUL": "true"])
                try requireGUI(!name.contains("="), category: "environment", predicate: "\(field)[\(index)].nameOnly",
                               operands: ["index": String(index), "containsEquals": "true"])
            }
        }
        try lifecycle.validateForPreparation()
        for (field, actual) in [("initialDemoIdle", initialDemoIdle), ("labStartupSkipped", labStartupSkipped),
            ("capabilityQueriesSkipped", capabilityQueriesSkipped), ("guestIdle", guestIdle), ("gitIdle", gitIdle)] {
            try compareGUI(actual, true, category: "policy", predicate: field)
        }
        let ids = Array(UInt32(1)...64)
        try compareGUI(fixture.scenario, "sparse", category: "fixture", predicate: "fixture.scenario")
        try compareGUI(fixture.scenarioTitle, "Sparse change", category: "fixture", predicate: "fixture.scenarioTitle")
        try compareGUI(fixture.rows.map(\.id), ids, category: "fixture", predicate: "fixture.rows.ids")
        for (field, bytes) in [("beforeContentCBOR", fixture.beforeContentCBOR), ("beforeVersionCBOR", fixture.beforeVersionCBOR),
            ("deltaCBOR", fixture.deltaCBOR), ("afterContentCBOR", fixture.afterContentCBOR), ("afterVersionCBOR", fixture.afterVersionCBOR)] {
            try requireGUI(!bytes.isEmpty, category: "fixture", predicate: "fixture.\(field).nonempty",
                           operands: ["actualBytes": String(bytes.count)])
            try requireGUI(bytes.count <= Self.maximumFrameBytes, category: "fixture", predicate: "fixture.\(field).maximumBytes",
                           operands: ["actualBytes": String(bytes.count), "maximumBytes": String(Self.maximumFrameBytes)])
        }
        for (field, value) in [("beforeStateID", fixture.beforeStateID), ("afterStateID", fixture.afterStateID),
            ("beforeContentRoot", fixture.beforeContentRoot), ("afterContentRoot", fixture.afterContentRoot), ("deltaID", fixture.deltaID)] {
            try requireGUI(value.utf8.count == 64, category: "fixture", predicate: "fixture.\(field).hexLength",
                           operands: ["actualBytes": String(value.utf8.count), "expectedBytes": "64"])
            try requireGUI(value.utf8.allSatisfy({ (48...57).contains($0) || (97...102).contains($0) }),
                           category: "fixture", predicate: "fixture.\(field).lowercaseHex", operands: ["actual": value])
        }
        try compareGUI(sameWindowIdentity, true, category: "surface", predicate: "sameWindowIdentity")
        try requireGUI(pageBefore.windowNumber > 0, category: "surface", predicate: "pageBefore.windowNumber.positive",
                       operands: ["actual": String(pageBefore.windowNumber), "exclusiveMinimum": "0"])
        for (field, surface) in [("pageAfter", pageAfter), ("result", result), ("table", table)] {
            try compareGUI(surface.windowNumber, pageBefore.windowNumber, category: "surface", predicate: "\(field).sameWindowNumber")
        }
        for (field, surface, role, stateID, rowIDs) in [
            ("pageBefore", pageBefore, "page", "", [UInt32]()),
            ("pageAfter", pageAfter, "page", fixture.afterStateID, ids),
            ("result", result, "result", fixture.afterStateID, ids),
            ("table", table, "table", fixture.afterStateID, ids)
        ] {
            if let failure = surface.validationFailure(field: field, expectedRole: role,
                                                       expectedStateID: stateID, expectedRowIDs: rowIDs) {
                throw failure
            }
        }
    }

    private func validateFixtureMatches(_ expected: DeltaPUGUIFixture) throws {
        for (field, actual, wanted) in [("scenario", fixture.scenario, expected.scenario),
            ("scenarioTitle", fixture.scenarioTitle, expected.scenarioTitle), ("beforeStateID", fixture.beforeStateID, expected.beforeStateID),
            ("afterStateID", fixture.afterStateID, expected.afterStateID), ("beforeContentRoot", fixture.beforeContentRoot, expected.beforeContentRoot),
            ("afterContentRoot", fixture.afterContentRoot, expected.afterContentRoot), ("deltaID", fixture.deltaID, expected.deltaID)] {
            try compareGUI(actual, wanted, category: "fixture", predicate: "fixture.\(field).exactMatch")
        }
        for (field, actual, wanted) in [("beforeContentCBOR", fixture.beforeContentCBOR, expected.beforeContentCBOR),
            ("beforeVersionCBOR", fixture.beforeVersionCBOR, expected.beforeVersionCBOR), ("deltaCBOR", fixture.deltaCBOR, expected.deltaCBOR),
            ("afterContentCBOR", fixture.afterContentCBOR, expected.afterContentCBOR), ("afterVersionCBOR", fixture.afterVersionCBOR, expected.afterVersionCBOR)] {
            try compareGUI(actual, wanted, category: "fixture", predicate: "fixture.\(field).exactMatch")
        }
        try compareRows(fixture.rows, expected.rows, path: "fixture.rows")
        let a = fixture.work, b = expected.work
        for (field, actual, wanted) in [("submittedEdits", a.submittedEdits, b.submittedEdits),
            ("changedDefinitions", a.changedDefinitions, b.changedDefinitions), ("nodesValidated", a.nodesValidated, b.nodesValidated),
            ("operandEdgesValidated", a.operandEdgesValidated, b.operandEdgesValidated), ("invalidatedNodes", a.invalidatedNodes, b.invalidatedNodes),
            ("invalidationEdgesVisited", a.invalidationEdgesVisited, b.invalidationEdgesVisited), ("nodesEvaluated", a.nodesEvaluated, b.nodesEvaluated),
            ("operandReads", a.operandReads, b.operandReads), ("valuesReused", a.valuesReused, b.valuesReused),
            ("outputComparisons", a.outputComparisons, b.outputComparisons), ("commitmentPayloadBytes", a.commitmentPayloadBytes, b.commitmentPayloadBytes)] {
            try compareGUI(actual, wanted, category: "fixture", predicate: "fixture.work.\(field).exactMatch")
        }
        for (field, actual, wanted) in [("beforeNodeEvaluations", fixture.beforeNodeEvaluations, expected.beforeNodeEvaluations),
            ("afterNodeEvaluations", fixture.afterNodeEvaluations, expected.afterNodeEvaluations),
            ("afterOperandReads", fixture.afterOperandReads, expected.afterOperandReads)] {
            try compareGUI(actual, wanted, category: "fixture", predicate: "fixture.\(field).exactMatch")
        }
    }

    private func compareRows(_ actual: [DeltaPUGUIRow], _ expected: [DeltaPUGUIRow], path: String) throws {
        try compareGUI(actual.count, expected.count, category: "fixture", predicate: "\(path).count")
        for (index, pair) in zip(actual, expected).enumerated() {
            try compareGUI(pair.0.id, pair.1.id, category: "fixture", predicate: "\(path)[\(index)].id")
            try compareGUI(pair.0.oldValue, pair.1.oldValue, category: "fixture", predicate: "\(path)[\(index)].oldValue")
            try compareGUI(pair.0.newValue, pair.1.newValue, category: "fixture", predicate: "\(path)[\(index)].newValue")
            try compareGUI(pair.0.definitionChanged, pair.1.definitionChanged, category: "fixture", predicate: "\(path)[\(index)].definitionChanged")
            try compareGUI(pair.0.statusRaw, pair.1.statusRaw, category: "fixture", predicate: "\(path)[\(index)].statusRaw")
        }
    }
}
#endif
