#if DEBUG
import Foundation

/// Prepared observations, not a terminal receipt. The process cannot include
/// evidence of its own later output retention or exit in this frame.
struct ReadinessAssessment: Encodable {
    static let schema = "com.ergentics.provenance.functional-readiness.v1"
    static let prefix = "ERGENTICS_FUNCTIONAL_READINESS_V1 "
    static let maximumFrameBytes = 65_536

    let startup: DevelopmentReadinessReport
    let functionality: FunctionalReadinessResult
    let lifecycle: LifecycleObservation

    init(startup: DevelopmentReadinessReport, functionality: FunctionalReadinessResult,
         lifecycle: AppLifecyclePolicy.ReadinessSnapshot) {
        self.startup = startup
        self.functionality = functionality
        self.lifecycle = LifecycleObservation(lifecycle)
    }

    var preparedChecksPassed: Bool {
        startup.startupReady && functionality.passed && lifecycle.withinWorkBudgetAtPreparation
    }

    struct LifecycleObservation: Encodable {
        let clock = "mach_continuous_time"
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
            runID = value.runID.uuidString.lowercased()
            phase = value.phase.rawValue
            startTicks = String(value.startTicks)
            observationTicks = String(value.observationTicks)
            timebaseNumerator = value.timebaseNumerator
            timebaseDenominator = value.timebaseDenominator
            clockValid = value.clockValid
            workBudgetExpired = value.workBudgetExpired
            canceled = value.canceled
            workCompleted = value.workCompleted
            fallbackArmed = value.fallbackArmed
        }

        var withinWorkBudgetAtPreparation: Bool {
            guard phase == "working", clockValid, !workBudgetExpired, !canceled,
                  !workCompleted, fallbackArmed, timebaseNumerator > 0, timebaseDenominator > 0,
                  let start = UInt64(startTicks), let end = UInt64(observationTicks), end >= start else { return false }
            // Independently check the exact observation interval, rather than
            // accepting a descriptive phase or a serialized Boolean as proof.
            let elapsed = (end - start).multipliedFullWidth(by: UInt64(timebaseNumerator))
            let limit = UInt64(10_000_000_000).multipliedFullWidth(by: UInt64(timebaseDenominator))
            return elapsed.high < limit.high || (elapsed.high == limit.high && elapsed.low < limit.low)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schema, scope, preparedChecksPassed, startupReady, startupTimingValid, startupTimingClock
        case syntheticFunctionalityPassed, withinWorkBudgetAtPreparation, startup, functionality, lifecycle
        case guestExecution, guestTeardown, journalPersistence, outputRetention, processExit, hostIntegrity
        case workBudgetNanoseconds, shutdownGraceNanoseconds, gateE, authorityVector
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(Self.schema, forKey: .schema)
        try c.encode("Signed GUI observation plus synthetic in-process checks; prepared before output and exit; no guest or journal access", forKey: .scope)
        try c.encode(preparedChecksPassed, forKey: .preparedChecksPassed)
        try c.encode(startup.startupReady, forKey: .startupReady)
        try c.encode(startup.timingValid, forKey: .startupTimingValid)
        try c.encode("mach_absolute_time", forKey: .startupTimingClock)
        try c.encode(functionality.passed, forKey: .syntheticFunctionalityPassed)
        try c.encode(lifecycle.withinWorkBudgetAtPreparation, forKey: .withinWorkBudgetAtPreparation)
        try c.encode(startup, forKey: .startup)
        try c.encode(functionality, forKey: .functionality)
        try c.encode(lifecycle, forKey: .lifecycle)
        try c.encode("NOT_RUN", forKey: .guestExecution)
        try c.encode("NOT_RUN", forKey: .guestTeardown)
        try c.encode("NOT_TESTED", forKey: .journalPersistence)
        try c.encode("NOT_OBSERVED_IN_PREPARED_FRAME", forKey: .outputRetention)
        try c.encode("NOT_OBSERVED_IN_PREPARED_FRAME", forKey: .processExit)
        try c.encode("NOT_ATTESTED", forKey: .hostIntegrity)
        try c.encode("10000000000", forKey: .workBudgetNanoseconds)
        try c.encode("5000000000", forKey: .shutdownGraceNanoseconds)
        try c.encode("ABSTAIN", forKey: .gateE)
        try c.encode("00000000", forKey: .authorityVector)
    }

    func frame() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        var bytes = Data(Self.prefix.utf8)
        bytes.append(try encoder.encode(self))
        bytes.append(10)
        guard bytes.count <= Self.maximumFrameBytes else { throw FrameError.tooLarge }
        return bytes
    }

    enum FrameError: Error { case tooLarge }
}
#endif
