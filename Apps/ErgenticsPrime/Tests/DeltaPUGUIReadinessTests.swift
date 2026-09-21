import Foundation
import XCTest

final class DeltaPUGUIReadinessLaunchTests: XCTestCase {
    func testNewArgumentIsExactAndDebugOnly() {
        #if DEBUG
        XCTAssertTrue(DevelopmentLaunch.isDeltaPUReadiness(arguments: ["--deltapu-readiness"]))
        #else
        XCTAssertFalse(DevelopmentLaunch.isDeltaPUReadiness(arguments: ["--deltapu-readiness"]))
        #endif
        for arguments in [[], ["--deltapu-readiness="], ["--deltapu-readiness", "extra"],
                          ["--deltapu-readiness", "--deltapu-readiness"]] {
            XCTAssertFalse(DevelopmentLaunch.isDeltaPUReadiness(arguments: arguments))
        }
    }

    func testCompositeCannotEnterAnyDevelopmentMode() {
        let flags = ["--deltapu-readiness", "--prime-git-readiness", "--run-rust-bootstrap-once"]
        for first in flags {
            for second in flags {
                let arguments = [first, second]
                XCTAssertFalse(DevelopmentLaunch.isDeltaPUReadiness(arguments: arguments))
                XCTAssertFalse(DevelopmentLaunch.isReadinessProbe(arguments: arguments))
                XCTAssertFalse(DevelopmentLaunch.isRustBoot(arguments: arguments))
            }
        }
    }
}

#if DEBUG
@MainActor
final class DeltaPUGUIReadinessTests: XCTestCase {
    private let identity = UUID(uuidString: "5D4C7B02-A2DA-4BE0-9F44-0FC197B86A00")!

    private func lifecycle(start: UInt64 = 100, end: UInt64 = 101,
                           numerator: UInt32 = 125, denominator: UInt32 = 3) -> DeltaPUGUILifecycle {
        DeltaPUGUILifecycle(AppLifecyclePolicy.ReadinessSnapshot(runID: identity, phase: .working,
            workBudgetExpired: false, canceled: false, workCompleted: false,
            startTicks: start, observationTicks: end, timebaseNumerator: numerator,
            timebaseDenominator: denominator, clockValid: true, fallbackArmed: true))
    }

    private func report(_ demo: DeltaPUDemoReport, clock: DeltaPUGUILifecycle? = nil,
                        width: Double = 640) -> DeltaPUGUIReadinessReport {
        func surface(_ role: String, before: Bool = false) -> DeltaPUGUISurface {
            DeltaPUGUISurface(role: role, windowNumber: 37, attached: true, visibleWindow: true,
                miniaturized: false, hidden: false, boundsX: 0, boundsY: 0, width: width, height: 480,
                visibleX: 0, visibleY: 0, visibleWidth: width, visibleHeight: 480, clipsToBounds: true,
                boundStateID: before ? "" : demo.transition.snapshot.stateID,
                boundRowIDs: before ? [] : Array(UInt32(1)...64))
        }
        return DeltaPUGUIReadinessReport(pid: 123, bundleIdentifier: "com.ergentics.provenance",
            executablePath: "/synthetic/not-executed", team: "ZCQ435U8JP", signatureAdmitted: true,
            environmentNamesAtStart: [], environmentNamesAtObservation: ["__CF_USER_TEXT_ENCODING"],
            lifecycle: clock ?? lifecycle(), pageBefore: surface("page", before: true), pageAfter: surface("page"),
            result: surface("result"), table: surface("table"), sameWindowIdentity: true, initialDemoIdle: true,
            labStartupSkipped: true, capabilityQueriesSkipped: true, guestIdle: true, gitIdle: true,
            fixture: DeltaPUGUIFixture(demo))
    }

    /// Direct construction preserves every binary64 payload, including values
    /// JSON cannot carry. These synthetic observations never mount an NSView.
    private func surface(boundsX: Double = 0, boundsY: Double = 0, width: Double = 640,
                         height: Double = 480, visibleX: Double = 0, visibleY: Double = 0,
                         visibleWidth: Double = 640, visibleHeight: Double = 480,
                         clipsToBounds: Bool = true) -> DeltaPUGUISurface {
        DeltaPUGUISurface(role: "table", windowNumber: 37, attached: true, visibleWindow: true,
            miniaturized: false, hidden: false, boundsX: boundsX, boundsY: boundsY,
            width: width, height: height, visibleX: visibleX, visibleY: visibleY,
            visibleWidth: visibleWidth, visibleHeight: visibleHeight, clipsToBounds: clipsToBounds,
            boundStateID: "synthetic-state", boundRowIDs: [1, 2, 3])
    }

    private func surfaceFailure(_ surface: DeltaPUGUISurface) -> DeltaPUGUICheckFailure? {
        surface.validationFailure(field: "table", expectedRole: "table",
                                  expectedStateID: "synthetic-state", expectedRowIDs: [1, 2, 3])
    }

    private func expectedSurfaceOperands(_ value: DeltaPUGUISurface, expectedRole: String,
                                         expectedStateID: String, expectedRowIDs: [UInt32]) -> [String: String] {
        ["role": value.role, "expectedRole": expectedRole, "windowNumber": String(value.windowNumber),
         "attached": String(value.attached), "visibleWindow": String(value.visibleWindow),
         "miniaturized": String(value.miniaturized), "hidden": String(value.hidden),
         "clipsToBounds": String(value.clipsToBounds),
         "boundsX": DeltaPUGUICheckFailure.binary64(value.boundsX),
         "boundsY": DeltaPUGUICheckFailure.binary64(value.boundsY),
         "width": DeltaPUGUICheckFailure.binary64(value.width),
         "height": DeltaPUGUICheckFailure.binary64(value.height),
         "visibleX": DeltaPUGUICheckFailure.binary64(value.visibleX),
         "visibleY": DeltaPUGUICheckFailure.binary64(value.visibleY),
         "visibleWidth": DeltaPUGUICheckFailure.binary64(value.visibleWidth),
         "visibleHeight": DeltaPUGUICheckFailure.binary64(value.visibleHeight),
         "boundsMaxX": DeltaPUGUICheckFailure.binary64(value.boundsX + value.width),
         "boundsMaxY": DeltaPUGUICheckFailure.binary64(value.boundsY + value.height),
         "visibleMaxX": DeltaPUGUICheckFailure.binary64(value.visibleX + value.visibleWidth),
         "visibleMaxY": DeltaPUGUICheckFailure.binary64(value.visibleY + value.visibleHeight),
         "stateID": value.boundStateID, "expectedStateID": expectedStateID,
         "rowIDs": value.boundRowIDs.map(String.init).joined(separator: ","),
         "expectedRowIDs": expectedRowIDs.map(String.init).joined(separator: ",")]
    }

    private func object<T: Encodable>(_ report: T) throws -> [String: Any] {
        try XCTUnwrap(JSONSerialization.jsonObject(with: JSONEncoder().encode(report)) as? [String: Any])
    }

    private func changed(_ report: DeltaPUGUIReadinessReport,
                         _ mutate: (inout [String: Any]) -> Void) throws -> DeltaPUGUIReadinessReport {
        var value = try object(report); mutate(&value)
        return try JSONDecoder().decode(DeltaPUGUIReadinessReport.self,
            from: JSONSerialization.data(withJSONObject: value, options: [.sortedKeys, .withoutEscapingSlashes]))
    }

    private func frame(_ value: [String: Any]) throws -> Data {
        var result = Data(DeltaPUGUIReadinessReport.prefix.utf8)
        result.append(try JSONSerialization.data(withJSONObject: value, options: [.sortedKeys, .withoutEscapingSlashes]))
        result.append(10)
        return result
    }

    private func failure(_ operation: () throws -> Void) throws -> DeltaPUGUICheckFailure {
        var caught: Error?
        do { try operation() } catch { caught = error }
        return try XCTUnwrap(caught as? DeltaPUGUICheckFailure)
    }

    private func failureFrame(_ value: [String: Any]) throws -> Data {
        var result = Data(DeltaPUGUIFailureReceipt.prefix.utf8)
        result.append(try JSONSerialization.data(withJSONObject: value, options: [.sortedKeys, .withoutEscapingSlashes]))
        result.append(10)
        return result
    }

    func testKnownPreparedFrameBindsRawFixtureAndDoesNotClaimExit() async throws {
        let demo = try await DeltaPUDemonstration.run(.sparse)
        let value = report(demo)
        try value.validate(expectedDemo: demo)
        let bytes = try value.frame()
        XCTAssertEqual(try DeltaPUGUIReadinessReport.decodeFrame(bytes), value)
        XCTAssertEqual(bytes, try value.frame())
        XCTAssertLessThanOrEqual(bytes.count, 65_536)
        XCTAssertEqual(bytes.last, 10)
        XCTAssertEqual(value.fixture.beforeContentCBOR, demo.before.contentCBOR)
        XCTAssertEqual(value.fixture.deltaCBOR, demo.transition.deltaCBOR)
        XCTAssertEqual(value.fixture.afterVersionCBOR, demo.transition.snapshot.versionCBOR)
        XCTAssertEqual(value.fixture.work.nodesEvaluated, 3)
        XCTAssertEqual(value.fixture.afterNodeEvaluations, 64)
        XCTAssertEqual(value.fixture.rows.filter { $0.statusRaw == "Cached / unaffected" }.count, 61)
        XCTAssertEqual(value.processExit, "NOT_OBSERVED_IN_PREPARED_FRAME")
        XCTAssertEqual(value.outputRetention, "NOT_OBSERVED_IN_PREPARED_FRAME")
        XCTAssertEqual(value.guestExecution, "NOT_RUN")
        XCTAssertEqual(value.energyErgs, "UNMEASURED")
        XCTAssertEqual(value.authorityVector, "00000000")
        XCTAssertEqual(value.gateE, "ABSTAIN")
        XCTAssertEqual(value.schema, "com.ergentics.provenance.deltapu-gui-readiness.v2")
        XCTAssertEqual(DeltaPUGUIReadinessReport.prefix, "ERGENTICS_DELTAPU_GUI_READINESS_V2 ")
        for surface in [value.pageBefore, value.pageAfter, value.result, value.table] {
            XCTAssertEqual(surface.boundsX, 0)
            XCTAssertEqual(surface.boundsY, 0)
            XCTAssertEqual(surface.visibleX, 0)
            XCTAssertEqual(surface.visibleY, 0)
            XCTAssertTrue(surface.clipsToBounds)
        }
    }

    func testIdentityAndSkipPredicateMutationsReject() async throws {
        let demo = try await DeltaPUDemonstration.run(.sparse), value = report(demo)
        for key in ["signatureAdmitted", "sameWindowIdentity", "initialDemoIdle", "labStartupSkipped",
                    "capabilityQueriesSkipped", "guestIdle", "gitIdle"] {
            XCTAssertThrowsError(try changed(value) { $0[key] = false }.validate(expectedDemo: demo))
        }
        for (key, replacement) in [("team", "WRONGTEAM1"), ("bundleIdentifier", "other.bundle"),
                                   ("executablePath", "relative"), ("schema", "unknown"), ("scope", "PASS"),
                                   ("processExit", "PASS"), ("authorityVector", "11111111"), ("energyErgs", "1")] {
            XCTAssertThrowsError(try changed(value) { $0[key] = replacement }.validate(expectedDemo: demo))
        }
        XCTAssertThrowsError(try changed(value) { $0["pid"] = 0 }.validate(expectedDemo: demo))
    }

    func testEveryViewMustBeVisibleAttachedAndInTheSameWindow() async throws {
        let demo = try await DeltaPUDemonstration.run(.sparse), value = report(demo)
        for role in ["pageBefore", "pageAfter", "result", "table"] {
            let cases: [(String, Any)] = [("attached", false), ("visibleWindow", false), ("hidden", true),
                ("miniaturized", true), ("windowNumber", 0), ("role", "other"), ("width", 0),
                ("height", -1), ("visibleWidth", 0), ("visibleHeight", 481), ("clipsToBounds", false)]
            for (key, replacement) in cases {
                XCTAssertThrowsError(try changed(value) {
                    var surface = $0[role] as! [String: Any]; surface[key] = replacement; $0[role] = surface
                }.validate(expectedDemo: demo))
            }
        }
        XCTAssertThrowsError(try changed(value) {
            var surface = $0["table"] as! [String: Any]; surface["windowNumber"] = 38; $0["table"] = surface
        }.validate(expectedDemo: demo))
        XCTAssertThrowsError(try report(demo, width: .infinity).validate(expectedDemo: demo))
        XCTAssertThrowsError(try report(demo, width: .nan).frame())
    }

    func testBindingsCannotBeMissingStaleReorderedOrPremature() async throws {
        let demo = try await DeltaPUDemonstration.run(.sparse), value = report(demo)
        for role in ["pageAfter", "result", "table"] {
            for (key, replacement) in [("boundStateID", demo.before.stateID as Any),
                                       ("boundRowIDs", [] as [Int]), ("boundRowIDs", Array((1...64).reversed()))] {
                XCTAssertThrowsError(try changed(value) {
                    var surface = $0[role] as! [String: Any]; surface[key] = replacement; $0[role] = surface
                }.validate(expectedDemo: demo))
            }
        }
        XCTAssertThrowsError(try changed(value) {
            var surface = $0["pageBefore"] as! [String: Any]
            surface["boundStateID"] = demo.before.stateID; $0["pageBefore"] = surface
        }.validate(expectedDemo: demo))
    }

    func testNamesOnlyMayChangeButMustBeSortedUnique() async throws {
        let demo = try await DeltaPUDemonstration.run(.sparse), value = report(demo)
        try changed(value) {
            $0["environmentNamesAtStart"] = ["HOME", "PATH"]
            $0["environmentNamesAtObservation"] = ["HOME", "PATH", "__CF_USER_TEXT_ENCODING"]
        }.validate(expectedDemo: demo)
        for names in [["PATH", "HOME"], ["HOME", "HOME"], [""], ["SECRET=value"]] {
            XCTAssertThrowsError(try changed(value) { $0["environmentNamesAtStart"] = names }.validate(expectedDemo: demo))
        }
        let json = try object(value)
        XCTAssertNil(json["environmentValues"])
        XCTAssertNil(json["environmentValueHashes"])
    }

    func testRational125Over3BoundaryAndLargeTicksRemainExact() async throws {
        let demo = try await DeltaPUDemonstration.run(.sparse)
        try report(demo, clock: lifecycle(start: 0, end: 239_999_999)).validate(expectedDemo: demo)
        XCTAssertThrowsError(try report(demo, clock: lifecycle(start: 0, end: 240_000_000)).validate(expectedDemo: demo))
        let start = UInt64.max - 1
        let large = report(demo, clock: lifecycle(start: start, end: UInt64.max))
        try large.validate(expectedDemo: demo)
        XCTAssertEqual(try DeltaPUGUIReadinessReport.decodeFrame(large.frame()).lifecycle.startTicks, String(start))
        for clock in [lifecycle(start: 2, end: 1), lifecycle(numerator: 0), lifecycle(denominator: 0),
                      lifecycle(start: 0, end: UInt64.max, numerator: UInt32.max)] {
            XCTAssertThrowsError(try report(demo, clock: clock).validate(expectedDemo: demo))
        }
    }

    func testLifecycleFlagsAndClockNamesCannotOverrideExactPredicate() async throws {
        let demo = try await DeltaPUDemonstration.run(.sparse), value = report(demo)
        let mutations: [(String, Any)] = [("clock", "mach_absolute_time"), ("phase", "completedAwaitingExit"),
            ("runID", "not-a-uuid"), ("startTicks", "0100"), ("clockValid", false),
            ("workBudgetExpired", true), ("canceled", true), ("workCompleted", true), ("fallbackArmed", false)]
        for (key, replacement) in mutations {
            XCTAssertThrowsError(try changed(value) {
                var clock = $0["lifecycle"] as! [String: Any]; clock[key] = replacement; $0["lifecycle"] = clock
            }.validate(expectedDemo: demo))
        }
    }

    func testFixtureBytesRowsAndEveryCounterRequireExactMatch() async throws {
        let demo = try await DeltaPUDemonstration.run(.sparse), value = report(demo)
        for key in ["beforeContentCBOR", "beforeVersionCBOR", "deltaCBOR", "afterContentCBOR", "afterVersionCBOR"] {
            XCTAssertThrowsError(try changed(value) {
                var fixture = $0["fixture"] as! [String: Any]; fixture[key] = Data([0]).base64EncodedString(); $0["fixture"] = fixture
            }.validate(expectedDemo: demo))
        }
        for key in ["submittedEdits", "changedDefinitions", "nodesValidated", "operandEdgesValidated", "invalidatedNodes",
                    "invalidationEdgesVisited", "nodesEvaluated", "operandReads", "valuesReused", "outputComparisons", "commitmentPayloadBytes"] {
            XCTAssertThrowsError(try changed(value) {
                var fixture = $0["fixture"] as! [String: Any], work = fixture["work"] as! [String: Any]
                work[key] = -1; fixture["work"] = work; $0["fixture"] = fixture
            }.validate(expectedDemo: demo))
        }
        XCTAssertThrowsError(try changed(value) {
            var fixture = $0["fixture"] as! [String: Any], rows = fixture["rows"] as! [[String: Any]]
            rows[0]["newValue"] = 999; fixture["rows"] = rows; $0["fixture"] = fixture
        }.validate(expectedDemo: demo))
        XCTAssertThrowsError(try changed(value) {
            var fixture = $0["fixture"] as! [String: Any]; fixture["afterNodeEvaluations"] = 3; $0["fixture"] = fixture
        }.validate(expectedDemo: demo))
        let dense = try await DeltaPUDemonstration.run(.dense)
        XCTAssertThrowsError(try report(dense).validate(expectedDemo: dense))
        XCTAssertThrowsError(try value.validate(expectedDemo: dense))
    }

    func testCanonicalFrameRejectsExtraFieldsDuplicateKeysAndTrailingBytes() async throws {
        let demo = try await DeltaPUDemonstration.run(.sparse), value = report(demo)
        let bytes = try value.frame()
        for target in ["", "lifecycle", "fixture", "table"] {
            var json = try object(value)
            if target.isEmpty { json["extra"] = true }
            else { var nested = json[target] as! [String: Any]; nested["extra"] = true; json[target] = nested }
            XCTAssertThrowsError(try DeltaPUGUIReadinessReport.decodeFrame(frame(json)))
        }
        var duplicated = Data(DeltaPUGUIReadinessReport.prefix.utf8)
        duplicated.append(Data("{\"pid\":123,".utf8))
        duplicated.append(bytes.dropFirst(DeltaPUGUIReadinessReport.prefix.utf8.count + 1))
        for malformed in [Data(bytes.dropLast()), bytes + Data([10]), bytes + Data([32]), duplicated,
                          Data("WRONG ".utf8) + bytes, Data(repeating: 0, count: 65_537)] {
            XCTAssertThrowsError(try DeltaPUGUIReadinessReport.decodeFrame(malformed))
        }
    }

    func testV2RejectsLegacyV1AndEveryMissingRequiredGeometryField() async throws {
        let demo = try await DeltaPUDemonstration.run(.sparse), value = report(demo)
        let required = ["boundsX", "boundsY", "visibleX", "visibleY", "clipsToBounds"]
        for role in ["pageBefore", "pageAfter", "result", "table"] {
            for key in required {
                for replacement in [nil, NSNull()] as [NSNull?] {
                    var json = try object(value), surface = json[role] as! [String: Any]
                    if let replacement { surface[key] = replacement }
                    else { surface.removeValue(forKey: key) }
                    json[role] = surface
                    let body = try JSONSerialization.data(withJSONObject: json, options: [.sortedKeys, .withoutEscapingSlashes])
                    XCTAssertThrowsError(try JSONDecoder().decode(DeltaPUGUIReadinessReport.self, from: body), "\(role).\(key)")
                    XCTAssertThrowsError(try DeltaPUGUIReadinessReport.decodeFrame(frame(json)), "\(role).\(key)")
                }
            }
        }
        var legacy = try object(value)
        legacy["schema"] = "com.ergentics.provenance.deltapu-gui-readiness.v1"
        // A v1 schema cannot become v2 merely by using the new frame prefix.
        XCTAssertThrowsError(try DeltaPUGUIReadinessReport.decodeFrame(frame(legacy)))
        for role in ["pageBefore", "pageAfter", "result", "table"] {
            var surface = legacy[role] as! [String: Any]
            for key in required { surface.removeValue(forKey: key) }
            legacy[role] = surface
        }
        var oldFrame = Data("ERGENTICS_DELTAPU_GUI_READINESS_V1 ".utf8)
        oldFrame.append(try JSONSerialization.data(withJSONObject: legacy, options: [.sortedKeys, .withoutEscapingSlashes]))
        oldFrame.append(10)
        XCTAssertThrowsError(try DeltaPUGUIReadinessReport.decodeFrame(oldFrame))
        let newFrame = try value.frame()
        let relabeled = Data("ERGENTICS_DELTAPU_GUI_READINESS_V1 ".utf8)
            + newFrame.dropFirst(DeltaPUGUIReadinessReport.prefix.utf8.count)
        XCTAssertThrowsError(try DeltaPUGUIReadinessReport.decodeFrame(relabeled))
    }

    func testSharedSurfacePredicateAndFinalReportRejectTheSameObservation() async throws {
        let demo = try await DeltaPUDemonstration.run(.sparse), value = report(demo)
        let cases: [(String, Any)] = [("boundsX", 1), ("boundsY", 1), ("visibleX", 1), ("visibleY", 1),
            ("width", 0), ("height", -1), ("visibleWidth", Double(640).nextUp), ("visibleHeight", 481),
            ("clipsToBounds", false), ("attached", false), ("visibleWindow", false), ("hidden", true),
            ("miniaturized", true), ("role", "other"), ("boundStateID", "stale"), ("boundRowIDs", [1, 2, 3])]
        for (key, replacement) in cases {
            let bad = try changed(value) {
                var surface = $0["table"] as! [String: Any]; surface[key] = replacement; $0["table"] = surface
            }
            let shared = try XCTUnwrap(bad.table.validationFailure(field: "table", expectedRole: "table",
                expectedStateID: demo.transition.snapshot.stateID, expectedRowIDs: Array(UInt32(1)...64)))
            XCTAssertEqual(try failure { try bad.validate(expectedDemo: demo) }, shared, key)
            XCTAssertEqual(try failure { _ = try bad.frame() }, shared, key)
        }
        XCTAssertNil(value.table.validationFailure(field: "table", expectedRole: "table",
            expectedStateID: demo.transition.snapshot.stateID, expectedRowIDs: Array(UInt32(1)...64)))
        XCTAssertNil(value.pageBefore.validationFailure(field: "pageBefore", expectedRole: "page",
            expectedStateID: "", expectedRowIDs: []))
    }

    func testFullRectanglesAreRetainedWithoutRebasingOrIntersection() async throws {
        let demo = try await DeltaPUDemonstration.run(.sparse)
        let value = try changed(report(demo)) { json in
            for role in ["pageBefore", "pageAfter", "result", "table"] {
                var surface = json[role] as! [String: Any]
                surface["boundsX"] = -320; surface["boundsY"] = -240
                surface["visibleX"] = -160; surface["visibleY"] = -120
                surface["visibleWidth"] = 320; surface["visibleHeight"] = 240
                json[role] = surface
            }
        }
        try value.validate(expectedDemo: demo)
        let decoded = try DeltaPUGUIReadinessReport.decodeFrame(value.frame())
        XCTAssertEqual(decoded, value)
        for observed in [decoded.pageBefore, decoded.pageAfter, decoded.result, decoded.table] {
            XCTAssertEqual(observed.boundsX, -320); XCTAssertEqual(observed.boundsY, -240)
            XCTAssertEqual(observed.width, 640); XCTAssertEqual(observed.height, 480)
            XCTAssertEqual(observed.visibleX, -160); XCTAssertEqual(observed.visibleY, -120)
            XCTAssertEqual(observed.visibleWidth, 320); XCTAssertEqual(observed.visibleHeight, 240)
            XCTAssertTrue(observed.clipsToBounds)
        }
    }

    func testClipContractAndHistorical1120Versus894RemainExactRejects() throws {
        let unclipped = try XCTUnwrap(surfaceFailure(surface(clipsToBounds: false)))
        XCTAssertEqual(unclipped.category, "surface")
        XCTAssertEqual(unclipped.predicate, "table.clipsToBounds")
        XCTAssertEqual(unclipped.operands["clipsToBounds"], "false")
        for clipping in [true, false] {
            let historical = try XCTUnwrap(surfaceFailure(surface(width: 894, visibleWidth: 1120, clipsToBounds: clipping)))
            XCTAssertEqual(historical.operands["width"], "binary64:0x408bf00000000000")
            XCTAssertEqual(historical.operands["visibleWidth"], "binary64:0x4091800000000000")
            XCTAssertEqual(historical.operands["clipsToBounds"], String(clipping))
            if clipping { XCTAssertEqual(historical.predicate, "table.visibleWidth.withinWidth") }
        }
        XCTAssertNil(surfaceFailure(surface(width: 894, visibleWidth: 894)))
    }

    func testEveryRawRectangleComponentMustBeFiniteWithExactDiagnosticBits() throws {
        let mutations: [(String, (Double) -> DeltaPUGUISurface)] = [
            ("boundsX", { self.surface(boundsX: $0) }), ("boundsY", { self.surface(boundsY: $0) }),
            ("width", { self.surface(width: $0) }), ("height", { self.surface(height: $0) }),
            ("visibleX", { self.surface(visibleX: $0) }), ("visibleY", { self.surface(visibleY: $0) }),
            ("visibleWidth", { self.surface(visibleWidth: $0) }),
            ("visibleHeight", { self.surface(visibleHeight: $0) })]
        for (field, mutate) in mutations {
            for bits: UInt64 in [0x7ff0_0000_0000_0000, 0xfff0_0000_0000_0000, 0x7ff8_0000_0000_00ab] {
                let caught = try XCTUnwrap(surfaceFailure(mutate(Double(bitPattern: bits))))
                let exact = "binary64:0x" + String(bits, radix: 16)
                XCTAssertEqual(caught.category, "surface")
                XCTAssertEqual(caught.predicate, "table.\(field).finite")
                XCTAssertEqual(caught.operands[field], exact)
                let receipt = DeltaPUGUIFailureReceipt(pid: 123, runID: identity, stage: "syntheticGeometry",
                                                      caughtTicks: 101, error: caught)
                XCTAssertEqual(try DeltaPUGUIFailureReceipt.decodeFrame(receipt.frame()), receipt)
            }
        }
    }

    func testAllFourExtentsMustRemainStrictlyPositiveIncludingNegativeZero() throws {
        let mutations: [(String, (Double) -> DeltaPUGUISurface)] = [
            ("width", { self.surface(width: $0) }), ("height", { self.surface(height: $0) }),
            ("visibleWidth", { self.surface(visibleWidth: $0) }),
            ("visibleHeight", { self.surface(visibleHeight: $0) })]
        for (field, mutate) in mutations {
            for value in [0.0, -0.0, -1.0] {
                let caught = try XCTUnwrap(surfaceFailure(mutate(value)))
                XCTAssertEqual(caught.predicate, "table.\(field).positive")
                XCTAssertEqual(caught.operands[field], DeltaPUGUICheckFailure.binary64(value))
                XCTAssertEqual(caught.operands["actual"], DeltaPUGUICheckFailure.binary64(value))
                XCTAssertEqual(caught.operands["exclusiveMinimum"], DeltaPUGUICheckFailure.binary64(0))
            }
        }
    }

    func testFiniteComponentsCannotOverflowOrCollapseTheirEndpoints() throws {
        let largest = Double.greatestFiniteMagnitude
        let overflowing: [(String, DeltaPUGUISurface)] = [
            ("boundsMaxX", surface(boundsX: largest, width: largest)),
            ("boundsMaxY", surface(boundsY: largest, height: largest)),
            ("visibleMaxX", surface(width: largest, visibleX: largest, visibleWidth: largest)),
            ("visibleMaxY", surface(height: largest, visibleY: largest, visibleHeight: largest))]
        for (field, observation) in overflowing {
            let caught = try XCTUnwrap(surfaceFailure(observation))
            XCTAssertEqual(caught.predicate, "table.\(field).finite")
            XCTAssertEqual(caught.operands[field], DeltaPUGUICheckFailure.binary64(.infinity))
        }
        let collapsed: [(String, DeltaPUGUISurface)] = [
            ("boundsMaxX", surface(boundsX: largest, width: 1, visibleX: largest, visibleWidth: 1)),
            ("boundsMaxY", surface(boundsY: largest, height: 1, visibleY: largest, visibleHeight: 1)),
            ("visibleMaxX", surface(width: largest, visibleX: largest, visibleWidth: 1)),
            ("visibleMaxY", surface(height: largest, visibleY: largest, visibleHeight: 1))]
        for (field, observation) in collapsed {
            let caught = try XCTUnwrap(surfaceFailure(observation))
            XCTAssertEqual(caught.predicate, "table.\(field).positiveExtent")
            XCTAssertEqual(caught.operands[field], DeltaPUGUICheckFailure.binary64(largest))
        }
    }

    func testFullRectangleContainmentAllowsNegativeOriginsAndExactEdgesOnly() throws {
        for observation in [surface(),
            surface(boundsX: -640, boundsY: -480, visibleX: -640, visibleY: -480),
            surface(boundsX: -320, boundsY: -240, visibleX: -160, visibleY: -120, visibleWidth: 320, visibleHeight: 240),
            surface(boundsX: 100, boundsY: 200, visibleX: 100, visibleY: 200),
            surface(visibleX: 1, visibleY: 1, visibleWidth: 639, visibleHeight: 479),
            surface(width: .leastNonzeroMagnitude, height: .leastNonzeroMagnitude,
                    visibleWidth: .leastNonzeroMagnitude, visibleHeight: .leastNonzeroMagnitude)] {
            XCTAssertNil(surfaceFailure(observation))
        }
        let positional: [(String, DeltaPUGUISurface)] = [
            ("visibleX.withinBoundsMinX", surface(boundsX: 1, visibleX: Double(1).nextDown)),
            ("visibleY.withinBoundsMinY", surface(boundsY: 1, visibleY: Double(1).nextDown)),
            ("visibleMaxX.withinBoundsMaxX", surface(width: 1, visibleX: Double.ulpOfOne, visibleWidth: 1)),
            ("visibleMaxY.withinBoundsMaxY", surface(height: 1, visibleY: Double.ulpOfOne, visibleHeight: 1))]
        for (predicate, observation) in positional {
            let caught = try XCTUnwrap(surfaceFailure(observation))
            XCTAssertEqual(caught.predicate, "table.\(predicate)")
        }
        let oneStep = try XCTUnwrap(surfaceFailure(surface(width: 1, visibleX: Double.ulpOfOne, visibleWidth: 1)))
        XCTAssertEqual(oneStep.operands["visibleMaxX"], DeltaPUGUICheckFailure.binary64(Double(1).nextUp))
        XCTAssertEqual(oneStep.operands["boundsMaxX"], DeltaPUGUICheckFailure.binary64(1))
    }

    func testContainmentFailureRetainsExactOperandsWithoutTolerance() async throws {
        let demo = try await DeltaPUDemonstration.run(.sparse), value = report(demo)
        let bad = try changed(value) {
            var surface = $0["table"] as! [String: Any]
            surface["visibleWidth"] = Double(640).nextUp; $0["table"] = surface
        }
        let caught = try failure { try bad.validate(expectedDemo: demo) }
        XCTAssertEqual(caught, DeltaPUGUICheckFailure(category: "surface", predicate: "table.visibleWidth.withinWidth",
            operands: expectedSurfaceOperands(bad.table, expectedRole: "table",
                expectedStateID: demo.transition.snapshot.stateID, expectedRowIDs: Array(UInt32(1)...64))))
        XCTAssertEqual(caught.operands["visibleWidth"], DeltaPUGUICheckFailure.binary64(Double(640).nextUp))
        XCTAssertEqual(caught.operands["width"], DeltaPUGUICheckFailure.binary64(640))
        // Equality remains accepted; the single representable step above it is not.
        try value.validate(expectedDemo: demo)
    }

    func testNonfiniteFailureRetainsEveryBinary64PayloadInAJSONSafeString() async throws {
        let demo = try await DeltaPUDemonstration.run(.sparse)
        for bits: UInt64 in [0x7ff0_0000_0000_0000, 0xfff0_0000_0000_0000, 0x7ff8_0000_0000_00ab] {
            let width = Double(bitPattern: bits)
            let value = report(demo, width: width)
            let caught = try failure { try value.validate(expectedDemo: demo) }
            let exact = "binary64:0x" + String(bits, radix: 16)
            XCTAssertEqual(caught.category, "surface")
            XCTAssertEqual(caught.predicate, "pageBefore.width.finite")
            var operands = expectedSurfaceOperands(value.pageBefore, expectedRole: "page", expectedStateID: "", expectedRowIDs: [])
            operands["actual"] = exact
            XCTAssertEqual(caught.operands, operands)
            let receipt = DeltaPUGUIFailureReceipt(pid: 123, runID: identity, stage: "reportValidation",
                                                 caughtTicks: UInt64.max, error: caught)
            let bytes = try receipt.frame()
            XCTAssertEqual(try DeltaPUGUIFailureReceipt.decodeFrame(bytes), receipt)
            XCTAssertEqual(try object(receipt)["caughtTicks"] as? String, String(UInt64.max))
            XCTAssertTrue(String(decoding: bytes, as: UTF8.self).contains(exact))
        }
        XCTAssertEqual(DeltaPUGUICheckFailure.binary64(-0.0), "binary64:0x8000000000000000")
        XCTAssertEqual(DeltaPUGUICheckFailure.binary64(0), "binary64:0x0000000000000000")
        let zero = try failure { _ = try report(demo, width: -0.0).frame() }
        XCTAssertEqual(zero.predicate, "pageBefore.width.positive")
        XCTAssertEqual(zero.operands["actual"], "binary64:0x8000000000000000")
    }

    func testLifecycleFailureNamesExactStrictRationalBoundary() async throws {
        let demo = try await DeltaPUDemonstration.run(.sparse)
        let caught = try failure {
            try report(demo, clock: lifecycle(start: 0, end: 240_000_000)).validate(expectedDemo: demo)
        }
        XCTAssertEqual(caught.category, "lifecycle")
        XCTAssertEqual(caught.predicate, "lifecycle.elapsed.strictlyWithinWorkBudget")
        XCTAssertEqual(caught.operands, ["startTicks": "0", "observationTicks": "240000000",
            "timebaseNumerator": "125", "timebaseDenominator": "3", "workBudgetNanoseconds": "10000000000",
            "elapsedHigh": "0", "elapsedLow": "30000000000", "budgetHigh": "0", "budgetLow": "30000000000"])
        XCTAssertFalse(lifecycle(start: 0, end: 240_000_000).withinWorkBudgetAtPreparation)
        XCTAssertTrue(lifecycle(start: 0, end: 239_999_999).withinWorkBudgetAtPreparation)
    }

    func testFixtureFailureNamesSpecificCounterAndRowOperands() async throws {
        let demo = try await DeltaPUDemonstration.run(.sparse), value = report(demo)
        let counter = try changed(value) {
            var fixture = $0["fixture"] as! [String: Any], work = fixture["work"] as! [String: Any]
            work["nodesEvaluated"] = 4; fixture["work"] = work; $0["fixture"] = fixture
        }
        XCTAssertEqual(try failure { try counter.validate(expectedDemo: demo) },
            DeltaPUGUICheckFailure(category: "fixture", predicate: "fixture.work.nodesEvaluated.exactMatch",
                                  operands: ["actual": "4", "expected": "3"]))
        let row = try changed(value) {
            var fixture = $0["fixture"] as! [String: Any], rows = fixture["rows"] as! [[String: Any]]
            rows[0]["newValue"] = 999; fixture["rows"] = rows; $0["fixture"] = fixture
        }
        XCTAssertEqual(try failure { try row.validate(expectedDemo: demo) },
            DeltaPUGUICheckFailure(category: "fixture", predicate: "fixture.rows[0].newValue",
                                  operands: ["actual": "999", "expected": "7"]))
    }

    func testInvalidEnvironmentNameNeverEchoesPossibleValue() async throws {
        let demo = try await DeltaPUDemonstration.run(.sparse), value = report(demo)
        let bad = try changed(value) { $0["environmentNamesAtStart"] = ["SECRET=do-not-export-this-value"] }
        let caught = try failure { try bad.validate(expectedDemo: demo) }
        XCTAssertEqual(caught, DeltaPUGUICheckFailure(category: "environment", predicate: "environmentNamesAtStart[0].nameOnly",
                                                     operands: ["index": "0", "containsEquals": "true"]))
        let bytes = try DeltaPUGUIFailureReceipt(pid: 123, runID: identity, stage: "reportValidation",
                                                caughtTicks: 101, error: caught).frame()
        XCTAssertFalse(String(decoding: bytes, as: UTF8.self).contains("SECRET"))
        XCTAssertFalse(String(decoding: bytes, as: UTF8.self).contains("do-not-export-this-value"))
    }

    func testFailureReceiptCanonicalRoundtripAndNoSuccessOrErrorUserInfo() throws {
        let error = NSError(domain: "SyntheticReadiness", code: -12,
                            userInfo: [NSLocalizedDescriptionKey: "do-not-export-this-description",
                                       "environmentValues": "do-not-export-this-value"])
        let receipt = DeltaPUGUIFailureReceipt(pid: 123, runID: identity, stage: "syntheticFailure",
                                               caughtTicks: UInt64.max, error: error)
        let bytes = try receipt.frame()
        XCTAssertEqual(try DeltaPUGUIFailureReceipt.decodeFrame(bytes), receipt)
        XCTAssertEqual(bytes, try receipt.frame())
        XCTAssertLessThanOrEqual(bytes.count, 65_536)
        XCTAssertEqual(receipt.errorDomain, "SyntheticReadiness")
        XCTAssertEqual(receipt.errorCode, -12)
        XCTAssertEqual(receipt.status, "INCOMPLETE")
        XCTAssertEqual(receipt.gateE, "ABSTAIN")
        XCTAssertEqual(receipt.authorityVector, "00000000")
        XCTAssertEqual(receipt.schema, "com.ergentics.provenance.deltapu-gui-failure.v1")
        XCTAssertEqual(DeltaPUGUIFailureReceipt.prefix, "ERGENTICS_DELTAPU_GUI_FAILURE_V1 ")
        XCTAssertNil(receipt.failure)
        let json = try object(receipt)
        XCTAssertNil(json["localizedDescription"])
        XCTAssertNil(json["userInfo"])
        XCTAssertNil(json["environmentValues"])
        XCTAssertNil(json["processExit"])
        XCTAssertNil(json["outputRetention"])
        let text = String(decoding: bytes, as: UTF8.self)
        XCTAssertFalse(text.contains("do-not-export-this-description"))
        XCTAssertFalse(text.contains("do-not-export-this-value"))
        XCTAssertThrowsError(try DeltaPUGUIReadinessReport.decodeFrame(bytes))
    }

    func testFailureReceiptRejectsUnknownDuplicateAndNoncanonicalFields() throws {
        let error = DeltaPUGUICheckFailure(category: "surface", predicate: "table.width.positive", operands: ["actual": "0"])
        let receipt = DeltaPUGUIFailureReceipt(pid: 123, runID: identity, stage: "reportValidation", caughtTicks: 101, error: error)
        let bytes = try receipt.frame()
        for target in ["", "failure"] {
            var json = try object(receipt)
            if target.isEmpty { json["extra"] = true }
            else { var nested = json[target] as! [String: Any]; nested["extra"] = true; json[target] = nested }
            XCTAssertThrowsError(try DeltaPUGUIFailureReceipt.decodeFrame(failureFrame(json)))
        }
        for (key, replacement) in [("status", "PASS"), ("schema", "other"), ("gateE", "PASS"),
                                   ("authorityVector", "11111111"), ("caughtTicks", "0101"), ("runID", identity.uuidString)] {
            var json = try object(receipt); json[key] = replacement
            XCTAssertThrowsError(try DeltaPUGUIFailureReceipt.decodeFrame(failureFrame(json)))
        }
        var duplicated = Data(DeltaPUGUIFailureReceipt.prefix.utf8)
        duplicated.append(Data("{\"pid\":123,".utf8))
        duplicated.append(bytes.dropFirst(DeltaPUGUIFailureReceipt.prefix.utf8.count + 1))
        for malformed in [Data(bytes.dropLast()), bytes + Data([10]), bytes + Data([32]), duplicated,
                          Data("WRONG ".utf8) + bytes, Data(repeating: 0, count: 65_537)] {
            XCTAssertThrowsError(try DeltaPUGUIFailureReceipt.decodeFrame(malformed))
        }
    }

    func testFailureReceiptEnforcesExactFrameLimitIncludingEscaping() throws {
        func receipt(_ payload: String) -> DeltaPUGUIFailureReceipt {
            DeltaPUGUIFailureReceipt(pid: 123, runID: identity, stage: "syntheticFailure", caughtTicks: 101,
                error: DeltaPUGUICheckFailure(category: "test", predicate: "bounded", operands: ["payload": payload]))
        }
        let overhead = try receipt("").frame().count
        let remaining = DeltaPUGUIFailureReceipt.maximumFrameBytes - overhead
        let exact = try receipt(String(repeating: "x", count: remaining)).frame()
        XCTAssertEqual(exact.count, 65_536)
        XCTAssertEqual(try DeltaPUGUIFailureReceipt.decodeFrame(exact).failure?.operands["payload"]?.utf8.count, remaining)
        XCTAssertThrowsError(try receipt(String(repeating: "x", count: remaining + 1)).frame())
        XCTAssertThrowsError(try receipt(String(repeating: "\u{0000}", count: 12_000)).frame())
        XCTAssertThrowsError(try DeltaPUGUIFailureReceipt(pid: 0, runID: identity, stage: "syntheticFailure",
                                                        caughtTicks: 101, error: NSError(domain: "test", code: 1)).frame())
    }
}
#endif
