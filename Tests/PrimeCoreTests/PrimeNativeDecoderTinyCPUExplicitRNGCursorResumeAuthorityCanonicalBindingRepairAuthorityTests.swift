import CoreFoundation
import Foundation
@testable import PrimeCore
import XCTest

final class PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthorityCanonicalBindingRepairAuthorityTests: XCTestCase {
    typealias Authority = PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthorityCanonicalBindingRepairAuthorityV1

    func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndRepairCeiling() throws {
        let authority = Authority.frozenV1
        try authority.validateExactV1()
        let canonical = try authority.canonicalData()
        XCTAssertEqual(try Authority.decodeCanonical(canonical), authority)
        XCTAssertEqual(try Authority.decodeCanonical(canonical).canonicalData(), canonical)
        XCTAssertEqual(PrimeSHA256.hexDigest(of: canonical), Authority.canonicalSHA256)

        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: canonical) as? [String: Any])
        XCTAssertEqual(Set(object.keys), ["schemaVersion", "authorityID", "predecessorAuthorityID", "predecessorAuthorityCanonicalSHA256", "failure", "defect", "repair", "ceiling"])

        var mutationCount = 0
        for path in leafPaths(in: object) {
            var mutated: Any = object
            XCTAssertTrue(mutateLeaf(&mutated, path: path))
            let data = try JSONSerialization.data(withJSONObject: mutated, options: [.sortedKeys, .withoutEscapingSlashes])
            XCTAssertThrowsError(try Authority.decodeCanonical(data), "accepted mutation at \(path)")
            mutationCount += 1
        }
        XCTAssertGreaterThan(mutationCount, 60)

        for key in object.keys {
            var missing = object
            missing.removeValue(forKey: key)
            let data = try JSONSerialization.data(withJSONObject: missing, options: [.sortedKeys, .withoutEscapingSlashes])
            XCTAssertThrowsError(try Authority.decodeCanonical(data))
        }
        var unknown = object
        unknown["unknown"] = true
        let unknownData = try JSONSerialization.data(withJSONObject: unknown, options: [.sortedKeys, .withoutEscapingSlashes])
        XCTAssertThrowsError(try Authority.decodeCanonical(unknownData))
        XCTAssertThrowsError(try Authority.decodeCanonical(Data([0x20]) + canonical))
        XCTAssertThrowsError(try Authority.decodeCanonical(canonical + Data([0x0a])))

        XCTAssertEqual(authority.failure.workflowConclusion, "failure")
        XCTAssertEqual(authority.failure.stage3LauncherInvocationCount, 1)
        XCTAssertEqual(authority.failure.stage3BuildCount, 0)
        XCTAssertEqual(authority.failure.stage3DirectXCTestCount, 0)
        XCTAssertEqual(authority.failure.stage3ReceiptCount, 0)
        XCTAssertEqual(authority.defect.canonicalOccurrenceCountInAuthoritySource, 1)
        XCTAssertEqual(authority.defect.canonicalOccurrenceCountInAuthorityTest, 0)
        XCTAssertFalse(authority.defect.stage3MechanicsFailureEstablished)
        XCTAssertEqual(authority.repair.launcherCanonicalSearchReplacementCount, 1)
        XCTAssertTrue(authority.repair.distinctDirectMainSuccessorAttemptAuthorized)
        XCTAssertFalse(authority.repair.retryOrRerunAuthorized)
        XCTAssertFalse(authority.ceiling.stage3ExecutionEstablished)
        XCTAssertFalse(authority.ceiling.trainingResumeEstablished)
        XCTAssertFalse(authority.ceiling.stage4Authorized)
        XCTAssertTrue(authority.ceiling.outcomeObservationRequired)
    }

    private func leafPaths(in value: Any, prefix: [AnyHashable] = []) -> [[AnyHashable]] {
        if let dictionary = value as? [String: Any] {
            return dictionary.keys.sorted().flatMap { key in
                leafPaths(in: dictionary[key] as Any, prefix: prefix + [key])
            }
        }
        if let array = value as? [Any] {
            return array.indices.flatMap { index in
                leafPaths(in: array[index], prefix: prefix + [index])
            }
        }
        return [prefix]
    }

    private func mutateLeaf(_ value: inout Any, path: [AnyHashable]) -> Bool {
        guard let head = path.first else {
            if let boolean = value as? Bool {
                value = !boolean
            } else if let number = value as? NSNumber {
                value = number.intValue + 1
            } else if let string = value as? String {
                value = string + "_mutated"
            } else {
                return false
            }
            return true
        }
        if let key = head as? String, var dictionary = value as? [String: Any], var child = dictionary[key] {
            guard mutateLeaf(&child, path: Array(path.dropFirst())) else { return false }
            dictionary[key] = child
            value = dictionary
            return true
        }
        if let index = head as? Int, var array = value as? [Any], array.indices.contains(index) {
            var child = array[index]
            guard mutateLeaf(&child, path: Array(path.dropFirst())) else { return false }
            array[index] = child
            value = array
            return true
        }
        return false
    }
}
