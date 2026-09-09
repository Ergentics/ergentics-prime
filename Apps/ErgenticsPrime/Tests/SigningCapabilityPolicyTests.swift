import Foundation
import XCTest

final class SigningCapabilityPolicyTests: XCTestCase {
    private let team = "ZCQ435U8JP"
    private var application: String { team + ".com.ergentics.provenance" }
    private var required: [String: Any] { [
        "com.apple.security.app-sandbox": true,
        "com.apple.security.files.user-selected.read-write": true,
        "com.apple.security.hypervisor": true,
        "com.apple.security.virtualization": true,
    ] }
    private func allowed(_ values: [String: Any]) -> Bool {
        epr_signing_capabilities_allowed(values as CFDictionary, team as CFString, application as CFString) == 1
    }
    func testExactProductCapabilitiesAndMatchingOptionalIdentityAreAccepted() {
        XCTAssertTrue(allowed(required))
        var values = required
        values["com.apple.developer.team-identifier"] = team
        values["com.apple.application-identifier"] = application
        values["application-identifier"] = application
        XCTAssertTrue(allowed(values))
    }
    func testEveryMissingFalseOrNonBooleanRequiredCapabilityRejects() {
        for key in required.keys {
            var values = required; values.removeValue(forKey: key); XCTAssertFalse(allowed(values))
            for invalid: Any in [false, "true", 1, NSNull()] {
                values = required; values[key] = invalid; XCTAssertFalse(allowed(values))
            }
        }
    }
    func testUnknownNetworkDebugAndLegacyFileCapabilitiesReject() {
        for key in ["com.apple.security.network.client", "com.apple.security.network.server",
                    "com.apple.security.get-task-allow", "com.apple.security.files.user-selected.read-only", "unknown"] {
            for value in [true, false] {
                var values = required; values[key] = value; XCTAssertFalse(allowed(values))
            }
        }
    }
    func testOptionalIdentityCannotBeSubstitutedOrMistyped() {
        for key in ["com.apple.developer.team-identifier", "com.apple.application-identifier", "application-identifier"] {
            for invalid: Any in ["OTHERTEAM1", "com.other.application", true, 1] {
                var values = required; values[key] = invalid; XCTAssertFalse(allowed(values))
            }
        }
    }
}
