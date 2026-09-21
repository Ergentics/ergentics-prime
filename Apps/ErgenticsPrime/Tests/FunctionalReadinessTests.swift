import Foundation
import XCTest

// Pure in-memory self-tests/report validation. No journal initializer, file,
// native accessor, app/guest entry, clock, environment or process is invoked.
final class FunctionalReadinessTests: XCTestCase {
    private func changed(_ update: (inout [String: Any]) -> Void) throws -> Data {
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: FunctionalReadiness.run().encoded()) as? [String: Any])
        update(&object)
        return try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys, .withoutEscapingSlashes])
    }

    func testAllFixedChecksPassWithExactManifest() {
        let result = FunctionalReadiness.run()
        XCTAssertTrue(result.passed)
        XCTAssertEqual(result.checks.count, 17)
        XCTAssertEqual(result.checks.map(\.id), FunctionalReadinessCheck.ID.allCases)
        XCTAssertTrue(result.checks.allSatisfy { $0.outcome == .passed })
    }

    func testDeterministicRepeatedRunAndEncoding() throws {
        let first = FunctionalReadiness.run(), second = FunctionalReadiness.run()
        XCTAssertEqual(first, second)
        XCTAssertEqual(try first.encoded(), try second.encoded())
        XCTAssertEqual(try FunctionalReadinessResult.decode(first.encoded()), first)
    }

    func testScopeNeverClaimsGuestOrStorageExecution() throws {
        let result = FunctionalReadiness.run()
        XCTAssertEqual(result.schema, FunctionalReadinessResult.expectedSchema)
        XCTAssertEqual(result.scope, FunctionalReadinessResult.expectedScope)
        XCTAssertFalse(result.guestExecuted)
        XCTAssertFalse(result.storageVerified)
        XCTAssertTrue(result.scope.contains("92-byte assembly baseline"))
        XCTAssertTrue(result.scope.contains("not the 164-byte Rust guest"))
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: result.encoded()) as? [String: Any])
        for absent in ["guestPID", "processExited", "teardown_pass", "energy_ergs", "environmentValues", "timestamp"] {
            XCTAssertNil(object[absent])
        }
    }

    func testFailedCheckCannotKeepFlatPass() throws {
        let bytes = try changed { object in
            var checks = object["checks"] as! [[String: Any]]
            checks[0]["outcome"] = "failed"; object["checks"] = checks
        }
        XCTAssertThrowsError(try FunctionalReadinessResult.decode(bytes))
    }

    func testConsistentFailureRemainsFailure() throws {
        let bytes = try changed { object in
            var checks = object["checks"] as! [[String: Any]]
            checks[0]["outcome"] = "failed"; object["checks"] = checks; object["passed"] = false
        }
        let result = try FunctionalReadinessResult.decode(bytes)
        XCTAssertFalse(result.passed)
        XCTAssertEqual(result.checks[0].outcome, .failed)
    }

    func testOmittedCheckRejectsEvenWithAllRemainingPassing() throws {
        let bytes = try changed { object in
            var checks = object["checks"] as! [[String: Any]]; checks.removeLast(); object["checks"] = checks
        }
        XCTAssertThrowsError(try FunctionalReadinessResult.decode(bytes))
    }

    func testDuplicateReorderedAndAdditionalChecksReject() throws {
        for mutation in 0..<3 {
            let bytes = try changed { object in
                var checks = object["checks"] as! [[String: Any]]
                if mutation == 0 { checks[1] = checks[0] }
                if mutation == 1 { checks.swapAt(0, 1) }
                if mutation == 2 { checks.append(checks[0]) }
                object["checks"] = checks
            }
            XCTAssertThrowsError(try FunctionalReadinessResult.decode(bytes))
        }
    }

    func testUnknownIDOutcomeAndCheckFieldsReject() throws {
        for mutation in 0..<3 {
            let bytes = try changed { object in
                var checks = object["checks"] as! [[String: Any]]
                if mutation == 0 { checks[0]["id"] = "unfrozen" }
                if mutation == 1 { checks[0]["outcome"] = "skipped" }
                if mutation == 2 { checks[0]["authority"] = true }
                object["checks"] = checks
            }
            XCTAssertThrowsError(try FunctionalReadinessResult.decode(bytes))
        }
    }

    func testSchemaScopeAndNoExecutionFlagsAreMandatoryPins() throws {
        for key in ["schema", "scope", "guestExecuted", "storageVerified"] {
            let bytes = try changed { object in
                if key == "schema" || key == "scope" { object[key] = "different" }
                else { object[key] = true }
            }
            XCTAssertThrowsError(try FunctionalReadinessResult.decode(bytes))
        }
    }

    func testMissingAndUnknownTopLevelFieldsReject() throws {
        for key in ["schema", "scope", "guestExecuted", "storageVerified", "checks", "passed"] {
            XCTAssertThrowsError(try FunctionalReadinessResult.decode(changed { $0.removeValue(forKey: key) }))
        }
        XCTAssertThrowsError(try FunctionalReadinessResult.decode(changed { $0["unfrozen"] = true }))
    }

    func testNumericBooleanAndFlatPassTamperingReject() throws {
        XCTAssertThrowsError(try FunctionalReadinessResult.decode(changed { $0["passed"] = 1 }))
        XCTAssertThrowsError(try FunctionalReadinessResult.decode(changed { $0["passed"] = false }))
        XCTAssertThrowsError(try FunctionalReadinessResult.decode(changed { $0["guestExecuted"] = 0 }))
    }

    func testFrameBoundsTrailingBytesAndDuplicateJSONKeysReject() throws {
        let bytes = try FunctionalReadiness.run().encoded()
        for bad in [Data(), Data(bytes.dropLast()), bytes + Data([10]), bytes + bytes,
                    Data(repeating: 0x20, count: FunctionalReadinessResult.maximumEncodedBytes + 1)] {
            XCTAssertThrowsError(try FunctionalReadinessResult.decode(bad))
        }
        var duplicate = Data("{\"guestExecuted\":true,".utf8)
        duplicate.append(bytes.dropFirst())
        XCTAssertThrowsError(try FunctionalReadinessResult.decode(duplicate))
    }
}
