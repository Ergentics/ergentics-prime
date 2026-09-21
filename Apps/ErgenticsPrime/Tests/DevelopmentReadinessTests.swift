import Foundation
import XCTest

final class DevelopmentReadinessTests: XCTestCase {
    func testLaunchGrammarIsClosedAndUnknownInputsAreInvalid() {
        XCTAssertEqual(DevelopmentLaunch.parse(arguments: []), .ordinary)
        for arguments in [
            [""], ["--unknown"], ["-NSDocumentRevisionsDebugMode", "YES"],
            ["--prime-git-readiness\u{2010}"], ["plain"], ["--prime-git-readiness=true"],
            ["--prime-git-readiness", "extra"],
            ["--run-fixed-guest-once", "--prime-git-readiness"],
            ["--run-fixed-guest-once", "--run-fixed-guest-once"]
        ] {
            XCTAssertEqual(DevelopmentLaunch.parse(arguments: arguments), .invalid)
        }
    }

    func testEveryDebugSelectorRequiresOneExactArgument() {
        let selectors = [
            "--deltapu-readiness", "--run-rust-bootstrap-once",
            "--prime-git-readiness", "--run-fixed-guest-once"
        ]
        #if DEBUG
        XCTAssertEqual(DevelopmentLaunch.parse(arguments: ["--deltapu-readiness"]), .deltaPUReadiness)
        XCTAssertEqual(DevelopmentLaunch.parse(arguments: ["--run-rust-bootstrap-once"]), .rustBootstrapOnce)
        XCTAssertEqual(DevelopmentLaunch.parse(arguments: ["--prime-git-readiness"]), .primeGitReadiness)
        XCTAssertEqual(DevelopmentLaunch.parse(arguments: ["--run-fixed-guest-once"]), .fixedGuestOnce)
        for first in selectors {
            for second in selectors {
                XCTAssertEqual(DevelopmentLaunch.parse(arguments: [first, second]), .invalid)
            }
        }
        #else
        for selector in selectors {
            XCTAssertEqual(DevelopmentLaunch.parse(arguments: [selector]), .invalid)
        }
        #endif
    }

    func testOnlyExactDebugRustBootArgumentIsRecognized() {
        #if DEBUG
        XCTAssertTrue(DevelopmentLaunch.isRustBoot(arguments: ["--run-rust-bootstrap-once"]))
        #else
        XCTAssertFalse(DevelopmentLaunch.isRustBoot(arguments: ["--run-rust-bootstrap-once"]))
        #endif
    }

    func testRustBootRejectsCompositeDuplicateAndOtherArguments() {
        for arguments in [[], ["--run-fixed-guest-once"], ["--prime-git-readiness"],
                          ["--run-rust-bootstrap-once", "extra"],
                          ["--run-rust-bootstrap-once", "--run-rust-bootstrap-once"],
                          ["--run-rust-bootstrap-once", "--run-fixed-guest-once"],
                          ["--prime-git-readiness", "--run-rust-bootstrap-once"],
                          ["--run-rust-bootstrap-once=true"]] {
            XCTAssertFalse(DevelopmentLaunch.isRustBoot(arguments: arguments))
        }
        XCTAssertFalse(DevelopmentLaunch.isReadinessProbe(arguments: ["--run-rust-bootstrap-once"]))
    }

    func testOnlyExactDebugReadinessArgumentIsRecognized() {
        #if DEBUG
        XCTAssertTrue(DevelopmentLaunch.isReadinessProbe(arguments: ["--prime-git-readiness"]))
        #else
        XCTAssertFalse(DevelopmentLaunch.isReadinessProbe(arguments: ["--prime-git-readiness"]))
        #endif
    }

    func testNoCompositeOrGuestArgumentEntersReadiness() {
        for arguments in [[], ["--run-fixed-guest-once"], ["--prime-git-readiness", "extra"],
                          ["--prime-git-readiness", "--run-fixed-guest-once"],
                          ["--prime-git-readiness", "--prime-git-readiness"],
                          ["--prime-git-readiness=true"]] {
            XCTAssertFalse(DevelopmentLaunch.isReadinessProbe(arguments: arguments))
        }
    }

    #if DEBUG
    private func report(signature: Bool = true, bundle: String = "com.ergentics.provenance",
                        windows: Int = 1, attached: Bool = true, width: Double = 1120, height: Double = 780,
                        skippedLab: Bool = true, skippedCapability: Bool = true,
                        idleGuest: Bool = true, idleGit: Bool = true, canceled: Bool = false,
                        environment: Int = 0, environmentNames: [String]? = nil,
                        start: String = "9007199254740993",
                        end: String = "9007199254740994", timebaseStatus: Int32 = 0,
                        numerator: UInt32 = 125, denominator: UInt32 = 3) -> DevelopmentReadinessReport {
        let names = environmentNames ?? (0..<environment).map { "ENV_\($0)" }.sorted()
        return DevelopmentReadinessReport(pid: 123, bundleIdentifier: bundle, executablePath: "/test/app",
            team: "TESTONLY00", signatureAdmitted: signature, signingStatus: "test fixture",
            environmentCountAtProbeStart: environment, environmentCountAtObservation: environment,
            environmentNamesAtProbeStart: names, environmentNamesAtObservation: names,
            visibleWindowCount: windows, contentWindowAttached: attached, observedWindowTitle: "test title",
            windowWidth: width, windowHeight: height,
            labStartupSkipped: skippedLab, capabilityQueriesSkipped: skippedCapability,
            guestModelIdle: idleGuest, primeGitModelIdle: idleGit, pollingCanceled: canceled,
            startTicks: start, observationTicks: end,
            timebaseStatus: timebaseStatus, timebaseNumerator: numerator, timebaseDenominator: denominator)
    }

    func testReadyRequiresSigningAndExactBundle() {
        XCTAssertTrue(report().startupReady)
        XCTAssertFalse(report(signature: false).startupReady)
        XCTAssertFalse(report(bundle: "example.other").startupReady)
    }

    func testReadyRequiresVisibleFiniteNonemptyWindow() {
        XCTAssertFalse(report(windows: 0).startupReady)
        XCTAssertFalse(report(attached: false).startupReady)
        for value in [0, -1, Double.infinity, Double.nan] {
            XCTAssertFalse(report(width: value).startupReady)
            XCTAssertFalse(report(height: value).startupReady)
        }
    }

    func testReadyRequiresEveryIdleBoundary() {
        XCTAssertFalse(report(skippedLab: false).startupReady)
        XCTAssertFalse(report(skippedCapability: false).startupReady)
        XCTAssertFalse(report(idleGuest: false).startupReady)
        XCTAssertFalse(report(idleGit: false).startupReady)
    }

    func testCanceledPollingCannotPass() {
        XCTAssertFalse(report(canceled: true).startupReady)
    }

    func testEnvironmentIsAnObservationNotIsolationPredicate() {
        XCTAssertTrue(report(environment: 0).startupReady)
        XCTAssertTrue(report(environment: 17).startupReady)
    }

    func testEnvironmentProjectionSortsKeysAndDerivesCountFromSameSnapshot() {
        let capture = DevelopmentEnvironmentNames(environment: ["Z_KEY": "value z", "A_KEY": "value a"])
        XCTAssertEqual(capture.names, ["A_KEY", "Z_KEY"])
        XCTAssertEqual(capture.count, 2)
        let empty = DevelopmentEnvironmentNames(environment: [:])
        XCTAssertEqual(empty.names, [])
        XCTAssertEqual(empty.count, 0)
    }

    func testEnvironmentValuesCannotReachEncodedReport() throws {
        let secret = "DO_NOT_RETAIN_fixture_secret_72c3"
        let capture = DevelopmentEnvironmentNames(environment: ["TOKEN_NAME_ONLY": secret])
        let bytes = try JSONEncoder().encode(report(environment: capture.count, environmentNames: capture.names))
        let text = try XCTUnwrap(String(data: bytes, encoding: .utf8))
        XCTAssertFalse(text.contains(secret))
        let value = try XCTUnwrap(JSONSerialization.jsonObject(with: bytes) as? [String: Any])
        XCTAssertEqual(value["environmentNamesAtProbeStart"] as? [String], ["TOKEN_NAME_ONLY"])
        XCTAssertEqual(value["environmentNamesAtObservation"] as? [String], ["TOKEN_NAME_ONLY"])
        XCTAssertEqual(value["schema"] as? String, "com.ergentics.provenance.gui-readiness.v2")
        XCTAssertNil(value["environmentValues"])
        XCTAssertNil(value["environmentValueHashes"])
    }

    func testEnvironmentReportRejectsCountMismatchUnsortedOrRepeatedNames() {
        for value in [report(environment: 2, environmentNames: ["A"]),
                      report(environment: 2, environmentNames: ["Z", "A"]),
                      report(environment: 2, environmentNames: ["A", "A"])] {
            XCTAssertFalse(value.environmentNamesConsistent)
            XCTAssertFalse(value.startupReady)
        }
    }

    func testTimingRequiresValidTimebaseAndOrderedExactTicks() {
        for value in [report(start: "invalid"), report(start: "2", end: "1"),
                      report(timebaseStatus: -1), report(numerator: 0), report(denominator: 0)] {
            XCTAssertFalse(value.timingValid)
            XCTAssertFalse(value.startupReady)
        }
        XCTAssertTrue(report(start: "5", end: "5").timingValid)
    }

    func testReportPreservesExactTicksAndSeparatesQuitRequest() throws {
        let value = try XCTUnwrap(JSONSerialization.jsonObject(with: JSONEncoder().encode(report())) as? [String: Any])
        XCTAssertEqual(value["startTicks"] as? String, "9007199254740993")
        XCTAssertEqual(value["observationTicks"] as? String, "9007199254740994")
        XCTAssertEqual(value["timebaseNumerator"] as? Int, 125)
        XCTAssertEqual(value["timebaseDenominator"] as? Int, 3)
        XCTAssertEqual(value["normalQuitPlanned"] as? Bool, true)
        XCTAssertNil(value["processExited"])
    }
    #endif
}
