import CoreFoundation
import Foundation
@testable import PrimeCore
import XCTest

final class PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeExecutionObservationTests: XCTestCase {
    typealias Observation = PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeExecutionObservationV1

    func testFrozenV1CanonicalCodableRecursiveMutationAndSuccessCeiling() throws {
        let observation = Observation.frozenV1
        try observation.validateExactV1()
        let canonical = try observation.canonicalData()
        XCTAssertEqual(try Observation.decodeCanonical(canonical), observation)
        XCTAssertEqual(PrimeSHA256.hexDigest(of: canonical), Observation.canonicalSHA256)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: canonical) as? [String: Any])
        var mutationCount = 0
        for path in leafPaths(object) {
            var copy: Any = object
            XCTAssertTrue(mutate(&copy, path))
            let data = try JSONSerialization.data(withJSONObject: copy, options: [.sortedKeys, .withoutEscapingSlashes])
            XCTAssertThrowsError(try Observation.decodeCanonical(data))
            mutationCount += 1
        }
        XCTAssertGreaterThan(mutationCount, 55)
        XCTAssertEqual(observation.run.terminalConclusion, "success")
        XCTAssertEqual(observation.stage3.startedCount, 1)
        XCTAssertEqual(observation.stage3.passedCount, 1)
        XCTAssertEqual(observation.stage3.failureCount, 0)
        XCTAssertEqual(observation.stage3.skipCount, 0)
        XCTAssertTrue(observation.stage3.typedInMemorySnapshotExportRestoreEstablished)
        XCTAssertFalse(observation.metallib.loadedPathInferred)
        XCTAssertFalse(observation.metallib.independentlyObservedLoadedIdentity)
        XCTAssertEqual(observation.retirement.stage3LauncherInvocationCount, 0)
        XCTAssertTrue(observation.retirement.stage3LauncherSourcePreserved)
        XCTAssertFalse(observation.retirement.stage4Authorized)
        XCTAssertFalse(observation.retirement.retryOrRerunAuthorized)
        XCTAssertTrue(observation.retirement.exactMainRetirementClosureRequired)
        XCTAssertThrowsError(try Observation.decodeCanonical(Data([0x20]) + canonical))
        XCTAssertThrowsError(try Observation.decodeCanonical(canonical + Data([0x0a])))
    }

    private func leafPaths(_ value: Any, _ prefix: [AnyHashable] = []) -> [[AnyHashable]] {
        if let dictionary = value as? [String: Any] {
            return dictionary.keys.sorted().flatMap { leafPaths(dictionary[$0] as Any, prefix + [$0]) }
        }
        if let array = value as? [Any] {
            return array.indices.flatMap { leafPaths(array[$0], prefix + [$0]) }
        }
        return [prefix]
    }

    private func mutate(_ value: inout Any, _ path: [AnyHashable]) -> Bool {
        guard let head = path.first else {
            if let bool = value as? Bool { value = !bool }
            else if let number = value as? NSNumber { value = number.intValue + 1 }
            else if let string = value as? String { value = string + "_mutation" }
            else { return false }
            return true
        }
        if let key = head as? String, var dictionary = value as? [String: Any], var child = dictionary[key] {
            guard mutate(&child, Array(path.dropFirst())) else { return false }
            dictionary[key] = child
            value = dictionary
            return true
        }
        if let index = head as? Int, var array = value as? [Any], array.indices.contains(index) {
            var child = array[index]
            guard mutate(&child, Array(path.dropFirst())) else { return false }
            array[index] = child
            value = array
            return true
        }
        return false
    }
}
