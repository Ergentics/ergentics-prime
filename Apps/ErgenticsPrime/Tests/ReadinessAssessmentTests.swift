#if DEBUG
import Foundation
import XCTest

final class ReadinessAssessmentTests: XCTestCase {
    private let identity = UUID(uuidString: "5D4C7B02-A2DA-4BE0-9F44-0FC197B86A00")!

    private func startup(admitted: Bool = true, title: String = "Synthetic window",
                         width: Double = 1120) -> DevelopmentReadinessReport {
        DevelopmentReadinessReport(pid: 123, bundleIdentifier: "com.ergentics.provenance",
            executablePath: "/synthetic/not-executed", team: "TESTONLY00", signatureAdmitted: admitted,
            signingStatus: "fabricated", environmentCountAtProbeStart: 0, environmentCountAtObservation: 0,
            environmentNamesAtProbeStart: [], environmentNamesAtObservation: [], visibleWindowCount: 1,
            contentWindowAttached: true, observedWindowTitle: title, windowWidth: width, windowHeight: 780,
            labStartupSkipped: true, capabilityQueriesSkipped: true, guestModelIdle: true, primeGitModelIdle: true,
            pollingCanceled: false, startTicks: "9007199254740993", observationTicks: "9007199254740994",
            timebaseStatus: 0, timebaseNumerator: 125, timebaseDenominator: 3)
    }

    private func snapshot(phase: AppLifecyclePolicy.ReadinessPhase = .working,
                          start: UInt64 = 1, end: UInt64 = 2, numerator: UInt32 = 1, denominator: UInt32 = 1,
                          clockValid: Bool = true, expired: Bool = false, canceled: Bool = false,
                          completed: Bool = false, armed: Bool = true) -> AppLifecyclePolicy.ReadinessSnapshot {
        AppLifecyclePolicy.ReadinessSnapshot(runID: identity, phase: phase, workBudgetExpired: expired,
            canceled: canceled, workCompleted: completed, startTicks: start, observationTicks: end,
            timebaseNumerator: numerator, timebaseDenominator: denominator, clockValid: clockValid, fallbackArmed: armed)
    }

    private func assessment(_ sample: AppLifecyclePolicy.ReadinessSnapshot? = nil,
                            startup value: DevelopmentReadinessReport? = nil) -> ReadinessAssessment {
        ReadinessAssessment(startup: value ?? startup(), functionality: FunctionalReadiness.run(),
                            lifecycle: sample ?? snapshot())
    }

    private func object(_ value: ReadinessAssessment) throws -> [String: Any] {
        try XCTUnwrap(JSONSerialization.jsonObject(with: JSONEncoder().encode(value)) as? [String: Any])
    }

    func testKnownAnswerIsOnlyPreparedSyntheticReadiness() throws {
        let value = assessment()
        XCTAssertTrue(value.functionality.passed)
        XCTAssertTrue(value.preparedChecksPassed)
        let json = try object(value)
        XCTAssertEqual(json["guestExecution"] as? String, "NOT_RUN")
        XCTAssertEqual(json["guestTeardown"] as? String, "NOT_RUN")
        XCTAssertEqual(json["journalPersistence"] as? String, "NOT_TESTED")
        XCTAssertEqual(json["outputRetention"] as? String, "NOT_OBSERVED_IN_PREPARED_FRAME")
        XCTAssertEqual(json["processExit"] as? String, "NOT_OBSERVED_IN_PREPARED_FRAME")
        XCTAssertEqual(json["hostIntegrity"] as? String, "NOT_ATTESTED")
        XCTAssertEqual(json["gateE"] as? String, "ABSTAIN")
        XCTAssertEqual(json["authorityVector"] as? String, "00000000")
    }

    func testFunctionalityDoesNotSubstituteForStartup() throws {
        let value = assessment(startup: startup(admitted: false))
        XCTAssertTrue(value.functionality.passed)
        XCTAssertFalse(value.preparedChecksPassed)
        let json = try object(value)
        XCTAssertEqual(json["startupReady"] as? Bool, false)
        XCTAssertEqual(json["syntheticFunctionalityPassed"] as? Bool, true)
    }

    func testStartupCannotOverrideAConsistentFunctionalFailure() throws {
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: FunctionalReadiness.run().encoded()) as? [String: Any])
        var checks = try XCTUnwrap(object["checks"] as? [[String: Any]])
        checks[0]["outcome"] = "failed"
        object["checks"] = checks
        object["passed"] = false
        let bytes = try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys, .withoutEscapingSlashes])
        let failed = try FunctionalReadinessResult.decode(bytes)
        let value = ReadinessAssessment(startup: startup(), functionality: failed, lifecycle: snapshot())
        XCTAssertTrue(value.startup.startupReady)
        XCTAssertFalse(value.preparedChecksPassed)
        XCTAssertEqual(try self.object(value)["syntheticFunctionalityPassed"] as? Bool, false)
    }

    func testEveryNonWorkingOrCanceledStateRejectsPreparedPass() {
        for sample in [snapshot(phase: .grace), snapshot(phase: .completedAwaitingExit), snapshot(phase: .forced),
                       snapshot(clockValid: false), snapshot(expired: true), snapshot(canceled: true),
                       snapshot(completed: true), snapshot(armed: false)] {
            XCTAssertFalse(assessment(sample).preparedChecksPassed)
        }
    }

    func testExactWorkBudgetBoundaryRejectsEvenWithAffirmingPhase() {
        XCTAssertTrue(assessment(snapshot(start: 0, end: 9_999_999_999)).preparedChecksPassed)
        XCTAssertFalse(assessment(snapshot(start: 0, end: 10_000_000_000)).preparedChecksPassed)
        XCTAssertFalse(assessment(snapshot(start: 0, end: 10_000_000_001)).preparedChecksPassed)
    }

    func testRationalTimebaseBoundaryIsNotRounded() {
        XCTAssertTrue(assessment(snapshot(start: 0, end: 239_999_999, numerator: 125, denominator: 3)).preparedChecksPassed)
        XCTAssertFalse(assessment(snapshot(start: 0, end: 240_000_000, numerator: 125, denominator: 3)).preparedChecksPassed)
    }

    func testInvalidClockAndRegressingObservationReject() {
        for sample in [snapshot(start: 2, end: 1), snapshot(numerator: 0), snapshot(denominator: 0)] {
            XCTAssertFalse(assessment(sample).preparedChecksPassed)
        }
    }

    func testLargeTicksRemainExactDecimalStrings() throws {
        let start = UInt64.max - 2
        let value = assessment(snapshot(start: start, end: start + 1))
        XCTAssertTrue(value.preparedChecksPassed)
        let json = try object(value)
        let clock = try XCTUnwrap(json["lifecycle"] as? [String: Any])
        XCTAssertEqual(clock["startTicks"] as? String, String(start))
        XCTAssertEqual(clock["observationTicks"] as? String, String(start + 1))
        XCTAssertEqual(clock["runID"] as? String, identity.uuidString.lowercased())
        XCTAssertEqual(clock["clock"] as? String, "mach_continuous_time")
        XCTAssertEqual(json["startupTimingClock"] as? String, "mach_absolute_time")
    }

    func testFullWidthElapsedCannotOverflowIntoPass() {
        XCTAssertFalse(assessment(snapshot(start: 0, end: UInt64.max, numerator: UInt32.max)).preparedChecksPassed)
    }

    func testNewFrameIsDeterministicVersionedAndBounded() throws {
        let value = assessment()
        let first = try value.frame()
        XCTAssertEqual(first, try value.frame())
        XCTAssertTrue(first.starts(with: Data(ReadinessAssessment.prefix.utf8)))
        XCTAssertFalse(first.starts(with: Data("ERGENTICS_GUI_READINESS ".utf8)))
        XCTAssertEqual(first.last, 10)
        XCTAssertEqual(first.filter { $0 == 10 }.count, 1)
        XCTAssertLessThanOrEqual(first.count, ReadinessAssessment.maximumFrameBytes)
        let body = first.dropFirst(ReadinessAssessment.prefix.utf8.count).dropLast()
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: Data(body)) as? [String: Any])
        XCTAssertEqual(json["schema"] as? String, ReadinessAssessment.schema)
        XCTAssertEqual(json["workBudgetNanoseconds"] as? String, "10000000000")
        XCTAssertEqual(json["shutdownGraceNanoseconds"] as? String, "5000000000")
    }

    func testOversizedFrameRejectsInsteadOfWritingPrefix() {
        let value = assessment(startup: startup(title: String(repeating: "x", count: ReadinessAssessment.maximumFrameBytes)))
        XCTAssertThrowsError(try value.frame())
    }

    func testNonFiniteWindowCannotBecomeAReportPass() {
        let value = assessment(startup: startup(width: .nan))
        XCTAssertFalse(value.preparedChecksPassed)
        XCTAssertThrowsError(try value.frame())
    }
}
#endif
