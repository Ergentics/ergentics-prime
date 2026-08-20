import XCTest
@testable import PrimeCore

private final class InMemoryFakeExclusiveResourceLeaseCapability:
    PrimeExclusiveResourceLeaseCapability
{}

final class PrimeExclusiveResourceLeaseTests: XCTestCase {
    func testAliasesAndTypedRetentionRemainPureAndTruthful() {
        XCTAssertEqual(
            ObjectIdentifier(PrimeExclusiveResourceLease.self),
            ObjectIdentifier(PrimeMetalDeviceLease.self)
        )
        XCTAssertEqual(
            ObjectIdentifier(PrimeExclusiveResourceLeaseError.self),
            ObjectIdentifier(PrimeMetalDeviceLeaseError.self)
        )

        let neutralError: PrimeExclusiveResourceLeaseError = .busy
        XCTAssertEqual(neutralError, PrimeMetalDeviceLeaseError.busy)

        weak var weakFirst: InMemoryFakeExclusiveResourceLeaseCapability?
        do {
            var first: InMemoryFakeExclusiveResourceLeaseCapability? = .init()
            let second = InMemoryFakeExclusiveResourceLeaseCapability()
            weakFirst = first

            let retention = PrimeExclusiveResourceLeaseRetention(first!)
            XCTAssertTrue(retention.retains(first!))
            XCTAssertFalse(retention.retains(second))

            first = nil
            XCTAssertNotNil(weakFirst)
        }
        XCTAssertNil(weakFirst)
    }
}
