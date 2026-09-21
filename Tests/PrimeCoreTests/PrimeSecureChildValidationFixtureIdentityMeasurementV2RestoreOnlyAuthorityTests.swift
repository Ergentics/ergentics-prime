// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
@testable import PrimeCore
import XCTest

final class PrimeSecureChildValidationFixtureIdentityMeasurementV2RestoreOnlyAuthorityTests: XCTestCase {
    private typealias Authority = PrimeSecureChildValidationFixtureIdentityMeasurementV2RestoreOnlyAuthorityV1

    func testFrozenV1CanonicalMutationAndRestoreOnlyCeiling() throws {
        requireSendable(Authority.self)
        let authority = Authority.frozenV1
        XCTAssertNoThrow(try authority.validate())
        XCTAssertNoThrow(try authority.validateExactV1())

        let canonical = try authority.canonicalData()
        XCTAssertEqual(canonical.count, Authority.canonicalByteCount)
        XCTAssertEqual(PrimeSHA256.hexDigest(of: canonical), Authority.canonicalSHA256)
        XCTAssertEqual(try Authority.decodeCanonical(canonical), authority)

        XCTAssertEqual(authority.targetReviewedMainTimeoutMinutes, 90)
        XCTAssertEqual(authority.predecessorCanonicalSHA256, "b77598fda922e6f3a925a4948ff834286664cf7df7bf4edcff1dadd275b2961c")
        XCTAssertEqual(authority.predecessorExactMainRun174Revision, "3f69d6e911ca48c39edc55508e93fed64fc48732")
        XCTAssertEqual(authority.timingRepairMergeRevision, "a6f76bd3f246a443ef96e21fa4c769499a62b875")
        XCTAssertEqual(authority.broaderSurfaceTrigger, "mechanics_is_abandoned_or_requires_broader_surface")
        XCTAssertEqual(authority.existingFivePathModeContract.map(\.ordinal), [1, 2, 3, 4, 5])
        XCTAssertEqual(authority.existingFivePathModeContract.map(\.gitStatus), ["M", "M", "M", "A", "A"])
        XCTAssertEqual(authority.existingFivePathModeContract.map(\.gitMode), ["100755", "100644", "100644", "100644", "100644"])
        XCTAssertTrue(authority.appendOnly)
        XCTAssertTrue(authority.restoreOnly)
        XCTAssertFalse([
            authority.mechanicsAttemptConsumed,
            authority.mechanicsAttemptCreated,
            authority.measurementOpportunityConsumed,
            authority.measurementOpportunityCreated,
            authority.mechanicsAuthorized,
            authority.measurementAuthorized,
            authority.retryOrRerunAuthorized,
            authority.executionPerformed,
        ].contains(true))

        try assertEveryLeafMutationAndStructuralChangeRejects(canonical)
        try assertNoncanonicalEncodingsReject(canonical)
    }

    private enum JSONPathComponent {
        case key(String)
        case index(Int)
    }

    private func assertEveryLeafMutationAndStructuralChangeRejects(_ canonical: Data) throws {
        let root = try XCTUnwrap(JSONSerialization.jsonObject(with: canonical) as? [String: Any])
        let leafPaths = allLeafPaths(root)
        XCTAssertGreaterThan(leafPaths.count, 40)
        for path in leafPaths {
            let original = try value(at: path, in: root)
            let changed = try replacingValue(in: root, at: path, with: mutatedLeaf(original))
            try assertCanonicalRejects(changed, context: "replace \(describe(path))")
        }

        for path in allContainerPaths(root) {
            if let dictionary = try value(at: path, in: root) as? [String: Any] {
                for key in dictionary.keys.sorted() {
                    try assertCanonicalRejects(
                        removingValue(in: root, at: path + [.key(key)]),
                        context: "remove \(describe(path + [.key(key)]))"
                    )
                }
                var unknown = dictionary
                unknown["unknownRestoreOnlyMutation"] = true
                try assertCanonicalRejects(
                    replacingValue(in: root, at: path, with: unknown),
                    context: "add key \(describe(path))"
                )
            }
            if let array = try value(at: path, in: root) as? [Any] {
                for index in array.indices {
                    try assertCanonicalRejects(
                        removingValue(in: root, at: path + [.index(index)]),
                        context: "remove \(describe(path + [.index(index)]))"
                    )
                }
                if array.count >= 2 {
                    var reordered = array
                    reordered.swapAt(0, 1)
                    try assertCanonicalRejects(
                        replacingValue(in: root, at: path, with: reordered),
                        context: "reorder \(describe(path))"
                    )
                }
            }
        }
    }

    private func assertNoncanonicalEncodingsReject(_ canonical: Data) throws {
        var bom = Data([0xEF, 0xBB, 0xBF])
        bom.append(canonical)
        XCTAssertThrowsError(try Authority.decodeCanonical(bom))

        var terminalWhitespace = canonical
        terminalWhitespace.append(0x20)
        XCTAssertThrowsError(try Authority.decodeCanonical(terminalWhitespace))

        var leadingWhitespace = Data([0x20])
        leadingWhitespace.append(canonical)
        XCTAssertThrowsError(try Authority.decodeCanonical(leadingWhitespace))

        var oversized = Data(repeating: 0x20, count: 131_073)
        oversized[0] = 0x7B
        XCTAssertThrowsError(try Authority.decodeCanonical(oversized)) { error in
            XCTAssertEqual(
                error as? PrimeSecureChildValidationFixtureIdentityMeasurementV2RestoreOnlyAuthorityError,
                .oversizedEncoding
            )
        }
    }

    private func allLeafPaths(_ root: Any) -> [[JSONPathComponent]] {
        var paths: [[JSONPathComponent]] = []
        func visit(_ value: Any, _ path: [JSONPathComponent]) {
            if let dictionary = value as? [String: Any] {
                for key in dictionary.keys.sorted() { visit(dictionary[key]!, path + [.key(key)]) }
            } else if let array = value as? [Any] {
                for (index, item) in array.enumerated() { visit(item, path + [.index(index)]) }
            } else {
                paths.append(path)
            }
        }
        visit(root, [])
        return paths
    }

    private func allContainerPaths(_ root: Any) -> [[JSONPathComponent]] {
        var paths: [[JSONPathComponent]] = []
        func visit(_ value: Any, _ path: [JSONPathComponent]) {
            if let dictionary = value as? [String: Any] {
                paths.append(path)
                for key in dictionary.keys.sorted() { visit(dictionary[key]!, path + [.key(key)]) }
            } else if let array = value as? [Any] {
                paths.append(path)
                for (index, item) in array.enumerated() { visit(item, path + [.index(index)]) }
            }
        }
        visit(root, [])
        return paths
    }

    private func value(at path: [JSONPathComponent], in root: Any) throws -> Any {
        var current = root
        for component in path {
            switch component {
            case let .key(key): current = try XCTUnwrap((current as? [String: Any])?[key])
            case let .index(index): current = try XCTUnwrap((current as? [Any])?[index])
            }
        }
        return current
    }

    private func replacingValue(in root: Any, at path: [JSONPathComponent], with replacement: Any) throws -> Any {
        guard let first = path.first else { return replacement }
        switch first {
        case let .key(key):
            var dictionary = try XCTUnwrap(root as? [String: Any])
            dictionary[key] = try replacingValue(in: try XCTUnwrap(dictionary[key]), at: Array(path.dropFirst()), with: replacement)
            return dictionary
        case let .index(index):
            var array = try XCTUnwrap(root as? [Any])
            array[index] = try replacingValue(in: array[index], at: Array(path.dropFirst()), with: replacement)
            return array
        }
    }

    private func removingValue(in root: Any, at path: [JSONPathComponent]) throws -> Any {
        guard let first = path.first else { throw MutationError.rootRemoval }
        if path.count == 1 {
            switch first {
            case let .key(key):
                var dictionary = try XCTUnwrap(root as? [String: Any])
                dictionary.removeValue(forKey: key)
                return dictionary
            case let .index(index):
                var array = try XCTUnwrap(root as? [Any])
                array.remove(at: index)
                return array
            }
        }
        switch first {
        case let .key(key):
            var dictionary = try XCTUnwrap(root as? [String: Any])
            dictionary[key] = try removingValue(in: try XCTUnwrap(dictionary[key]), at: Array(path.dropFirst()))
            return dictionary
        case let .index(index):
            var array = try XCTUnwrap(root as? [Any])
            array[index] = try removingValue(in: array[index], at: Array(path.dropFirst()))
            return array
        }
    }

    private func mutatedLeaf(_ value: Any) -> Any {
        if let string = value as? String { return string + "__mutation" }
        if let number = value as? NSNumber {
            if CFGetTypeID(number) == CFBooleanGetTypeID() { return !number.boolValue }
            return number.int64Value == Int64.max ? number.int64Value - 1 : number.int64Value + 1
        }
        XCTFail("unsupported JSON leaf \(type(of: value))")
        return "__unsupported_mutation"
    }

    private func assertCanonicalRejects(_ object: Any, context: String) throws {
        let data = try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys, .withoutEscapingSlashes])
        XCTAssertThrowsError(try Authority.decodeCanonical(data), context)
    }

    private func describe(_ path: [JSONPathComponent]) -> String {
        path.reduce("$") { result, component in
            switch component {
            case let .key(key): return result + "." + key
            case let .index(index): return result + "[\(index)]"
            }
        }
    }

    private func requireSendable<T: Sendable>(_: T.Type) {}

    private enum MutationError: Error { case rootRemoval }
}
