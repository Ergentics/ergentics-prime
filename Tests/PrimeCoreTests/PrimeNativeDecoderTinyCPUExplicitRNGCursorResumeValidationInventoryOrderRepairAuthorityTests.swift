import CoreFoundation
import Foundation
@testable import PrimeCore
import XCTest

final class PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeValidationInventoryOrderRepairAuthorityTests: XCTestCase {
    typealias Authority = PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeValidationInventoryOrderRepairAuthorityV1

    func testFrozenV1CanonicalCodableRecursiveMutationAndRepairCeiling() throws {
        let authority = Authority.frozenV1
        try authority.validateExactV1()
        let canonical = try authority.canonicalData()
        XCTAssertEqual(try Authority.decodeCanonical(canonical), authority)
        XCTAssertEqual(PrimeSHA256.hexDigest(of: canonical), Authority.canonicalSHA256)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: canonical) as? [String: Any])
        var mutations = 0
        for path in leafPaths(object) {
            var copy: Any = object
            XCTAssertTrue(mutate(&copy, path))
            let data = try JSONSerialization.data(withJSONObject: copy, options: [.sortedKeys, .withoutEscapingSlashes])
            XCTAssertThrowsError(try Authority.decodeCanonical(data))
            mutations += 1
        }
        XCTAssertGreaterThan(mutations, 45)
        XCTAssertEqual(authority.inventory.exactSortedPaths, authority.inventory.exactSortedPaths.sorted())
        XCTAssertNotEqual(authority.inventory.incorrectExpectedPaths, authority.inventory.exactSortedPaths)
        XCTAssertFalse(authority.inventory.packageInventoryMutationObserved)
        XCTAssertTrue(authority.inventory.failureWasBeforeStage3Build)
        XCTAssertFalse(authority.inventory.stage3MechanicsFailureEstablished)
        XCTAssertEqual(authority.repair.inventoryExpectedOrderReplacementCount, 1)
        XCTAssertFalse(authority.repair.retryOrRerunAuthorized)
        XCTAssertFalse(authority.ceiling.stage3ExecutionEstablished)
        XCTAssertFalse(authority.ceiling.stage4Authorized)
        XCTAssertTrue(authority.ceiling.terminalOutcomeObservationRequired)
        XCTAssertThrowsError(try Authority.decodeCanonical(Data([0x20]) + canonical))
        XCTAssertThrowsError(try Authority.decodeCanonical(canonical + Data([0x0a])))
    }

    private func leafPaths(_ value: Any, _ prefix: [AnyHashable] = []) -> [[AnyHashable]] {
        if let d = value as? [String: Any] { return d.keys.sorted().flatMap { leafPaths(d[$0] as Any, prefix + [$0]) } }
        if let a = value as? [Any] { return a.indices.flatMap { leafPaths(a[$0], prefix + [$0]) } }
        return [prefix]
    }

    private func mutate(_ value: inout Any, _ path: [AnyHashable]) -> Bool {
        guard let head = path.first else {
            if let b = value as? Bool { value = !b }
            else if let n = value as? NSNumber { value = n.intValue + 1 }
            else if let s = value as? String { value = s + "_mutation" }
            else { return false }
            return true
        }
        if let key = head as? String, var d = value as? [String: Any], var child = d[key] {
            guard mutate(&child, Array(path.dropFirst())) else { return false }
            d[key] = child; value = d; return true
        }
        if let index = head as? Int, var a = value as? [Any], a.indices.contains(index) {
            var child = a[index]
            guard mutate(&child, Array(path.dropFirst())) else { return false }
            a[index] = child; value = a; return true
        }
        return false
    }
}
