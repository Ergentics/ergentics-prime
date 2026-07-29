import XCTest
@testable import PrimeCore

final class PrimeNative3BProfileTests: XCTestCase {
    func testExact3BProfileIsFrozen() {
        let profile = PrimeNativeProfiles.exact3B

        XCTAssertEqual(
            profile.profileID,
            "ergentics_prime_native_3b_gqa_v1"
        )
        XCTAssertEqual(profile.vocabularySize, 512)
        XCTAssertEqual(profile.modelDimension, 3_072)
        XCTAssertEqual(profile.layerCount, 28)
        XCTAssertEqual(profile.attentionHeads, 24)
        XCTAssertEqual(profile.keyValueHeads, 8)
        XCTAssertEqual(profile.headDimension, 128)
        XCTAssertEqual(
            profile.feedForwardDimension,
            8_192
        )
        XCTAssertEqual(profile.maximumSequenceLength, 2_048)
        XCTAssertEqual(profile.ropeBase, 500_000)
        XCTAssertEqual(profile.parameterCount, 2_820_320_256)
    }
}
