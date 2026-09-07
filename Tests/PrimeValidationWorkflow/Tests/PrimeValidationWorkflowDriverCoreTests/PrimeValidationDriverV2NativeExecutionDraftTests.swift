// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary
import Foundation
@_spi(PrimeValidationDriverV2RoleFacade) @testable import PrimeCore
import PrimeValidationWorkflowContracts
@testable import PrimeValidationWorkflowDriverCore
import XCTest

/// Pure actual-source projections and owner cursor. No process or native
/// capability is created, and no live Gate H execution is asserted.
final class PrimeValidationDriverV2NativeExecutionDraftTests: XCTestCase {
    func testNativeScheduleExactlyMatchesOriginalPlannerEveryShardAndHash() throws {
        let (x, s) = try lists()
        let inventory = try PrimeValidationInventory.parse(xctestList: x, swiftTestingList: s)
        for run in ["native-H-parity", "H_20260907", String(repeating: "a", count: 128)] {
            let observed = try PrimeValidationDriverV2ClosedShardSchedule.observeFrozenLists(
                runID: run, xctestData: x, swiftTestingData: s)
            let original = try PrimeValidationShardPlannerV2.plan(inventory: inventory, runID: run)
            XCTAssertEqual(observed.canonicalInventoryData, try PrimeCanonicalJSON.encode(inventory))
            XCTAssertEqual(observed.canonicalShardsData, try PrimeCanonicalJSON.encode(original))
            XCTAssertEqual(observed.shards.count, original.count)
            XCTAssertEqual(observed.shards.filter { $0.arm == "reference" }.count, 3)
            for (index, pair) in zip(observed.shards, original).enumerated() {
                XCTAssertEqual(pair.0.ordinal, index + 1)
                XCTAssertEqual(pair.0.canonicalPlanData, try PrimeCanonicalJSON.encode(pair.1))
                XCTAssertEqual(pair.0.shardID, pair.1.shardID)
                XCTAssertEqual(pair.0.filterPattern, pair.1.filterPattern)
                XCTAssertEqual(pair.0.selectedIdentifiers, pair.1.testIDs.map(\.rawValue))
                if pair.0.arm == "candidate" {
                    XCTAssertLessThanOrEqual(pair.0.selectedIdentifiers.count, 32)
                    XCTAssertLessThanOrEqual(pair.0.filterPattern.utf8.count, 16_384)
                }
            }
            let slow = PrimeValidationShardPolicyV2.slowV20Suite + "/"
            let dedicated = observed.shards.filter { $0.arm == "candidate"
                && $0.selectedIdentifiers.contains(where: { $0.hasPrefix(slow) }) }
            XCTAssertEqual(dedicated.count, 2)
            XCTAssertTrue(dedicated.allSatisfy { $0.selectedIdentifiers.allSatisfy { $0.hasPrefix(slow) } })
        }
    }

    func testNativeScheduleRejectsChangedFrozenRawListsAndUnsafeRunID() throws {
        let (x, s) = try lists()
        for mutated in [x + Data([10]), Data(x.dropLast()), Data([0xff]) + x.dropFirst(), s] {
            XCTAssertThrowsError(try PrimeValidationDriverV2ClosedShardSchedule.observeFrozenLists(
                runID: "H", xctestData: mutated, swiftTestingData: s))
        }
        for mutated in [s + Data([10]), Data(s.dropLast()), x] {
            XCTAssertThrowsError(try PrimeValidationDriverV2ClosedShardSchedule.observeFrozenLists(
                runID: "H", xctestData: x, swiftTestingData: mutated))
        }
        for run in ["", "../H", "H\n", String(repeating: "a", count: 129)] {
            XCTAssertThrowsError(try PrimeValidationDriverV2ClosedShardSchedule.observeFrozenLists(
                runID: run, xctestData: x, swiftTestingData: s))
        }
    }

    func testNativeCursorConsumesBeforeStartAndCannotRetryIncompleteOrFailedShard() throws {
        var incomplete = PrimeValidationDriverV2ExecutionCursor(count: 3)
        XCTAssertEqual(try incomplete.begin(), 0)
        XCTAssertEqual(incomplete.next, 1)
        XCTAssertTrue(incomplete.awaiting)
        XCTAssertThrowsError(try incomplete.begin())
        XCTAssertTrue(incomplete.poisoned)
        XCTAssertThrowsError(try incomplete.accept(index: 0))
        var failed = PrimeValidationDriverV2ExecutionCursor(count: 3)
        _ = try failed.begin(); failed.stop()
        XCTAssertThrowsError(try failed.begin())
        XCTAssertFalse(failed.allAccepted)
    }

    func testNativeCursorAcceptsOnlyCurrentOrdinalAndAllTerminalsBeforePublication() throws {
        var cursor = PrimeValidationDriverV2ExecutionCursor(count: 3)
        XCTAssertFalse(cursor.allAccepted)
        for index in 0..<3 {
            XCTAssertEqual(try cursor.begin(), index)
            XCTAssertFalse(cursor.allAccepted)
            try cursor.accept(index: index)
            XCTAssertEqual(cursor.allAccepted, index == 2)
        }
        XCTAssertThrowsError(try cursor.begin())
        var wrong = PrimeValidationDriverV2ExecutionCursor(count: 3)
        _ = try wrong.begin()
        XCTAssertThrowsError(try wrong.accept(index: 1))
        XCTAssertThrowsError(try wrong.accept(index: 0))
        var empty = PrimeValidationDriverV2ExecutionCursor(count: 0)
        XCTAssertFalse(empty.allAccepted)
        XCTAssertThrowsError(try empty.begin())
    }

    func testNativePhysicalTestabilityPrefixPreservesOriginalLogicalPlan() throws {
        let body = ["--package-path", "/private/tmp/frozen", "--skip-build", "--no-parallel"]
        let prefix = PrimeValidationDriverV2SwiftPMPhysicalArguments.testabilityPrefix
        XCTAssertEqual(prefix, ["-Xswiftc", "-enable-testing"])
        XCTAssertEqual(try PrimeValidationDriverV2ClosedExecutionPolicy.originalLogicalArguments(
            physical: prefix + body), ["test"] + body)
        for wrong in [body, Array(prefix.reversed()) + body,
                      ["-Xswiftc", "-disable-testing"] + body, prefix] {
            XCTAssertThrowsError(try PrimeValidationDriverV2ClosedExecutionPolicy.originalLogicalArguments(physical: wrong))
        }
    }

    func testNativeGenericJSONUsesProductionIntegerAndKeyEncoding() throws {
        struct Values: Encodable {
            let uptime: UInt64 = 5_000_000_000_000_001
            let highest: UInt64 = .max
            let nested = ["key10": "/ten", "key2": "/two"]
            let flag = true
        }
        let bytes = try PrimeCanonicalJSON.encode(Values())
        let fields = try HJSON.object(bytes)
        XCTAssertEqual(try HJSON.encode(fields), bytes)
        for bad in [bytes + Data([10]), Data("{\"x\":1,\"x\":2}".utf8),
                    Data("{\"x\":1.5}".utf8), Data("{\"x\":1e3}".utf8), Data("[]".utf8)] {
            XCTAssertThrowsError(try HJSON.object(bad))
        }
    }

    func testNativeGoScopeRequiresExactIntentSourceImageScopeAndBudgets() throws {
        let source = String(repeating: "a", count: 64)
        let image: [String: Any] = ["absolutePath": "/private/tmp/held-supervisor",
            "content": ["byteCount": UInt64(123), "sha256": String(repeating: "b", count: 64)]]
        let intent = try HJSON.encode(["driverExecutable": image])
        let good: [String: Any] = ["schema": "prime_driver_v2_gate_h_declared_execution_scope_v1",
            "intentSHA256": PrimeSHA256.hexDigest(of: intent), "sourceCommit": String(repeating: "c", count: 40),
            "sourceTree": String(repeating: "d", count: 40), "sourceIdentitySHA256": source,
            "sourceTreeReplaySHA256": String(repeating: "e", count: 64),
            "governorExecutable": image, "supervisorExecutable": image,
            "referenceScopes": ["parallel_xctest", "sequential_xctest", "swift_testing"],
            "candidateScope": "frozen_suite_contiguous_32_original_planner",
            "referenceMaximumActiveNanoseconds": UInt64(1_800_000_000_000),
            "candidateMaximumActiveNanoseconds": UInt64(1_800_000_000_000)]
        func validate(_ data: Data) throws {
            try PrimeValidationDriverV2ExecutionGoScope.validate(data, intentData: intent,
                retainedSourceIdentitySHA256: source)
        }
        XCTAssertNoThrow(try validate(HJSON.encode(good)))
        XCTAssertThrowsError(try validate(Data()))
        XCTAssertThrowsError(try validate(HJSON.encode(good) + Data([10])))
        let mutations: [(String, Any)] = [
            ("intentSHA256", source), ("sourceIdentitySHA256", String(repeating: "e", count: 64)),
            ("sourceCommit", "HEAD"), ("sourceTree", String(repeating: "d", count: 39)),
            ("sourceTreeReplaySHA256", String(repeating: "e", count: 63)),
            ("referenceScopes", ["parallel_xctest"]), ("candidateScope", "caller_selected"),
            ("referenceMaximumActiveNanoseconds", UInt64(1_800_000_000_001)),
            ("candidateMaximumActiveNanoseconds", true),
            ("supervisorExecutable", ["absolutePath": "/changed", "content": image["content"]!]),
            ("governorExecutable", ["absolutePath": "/../changed", "content": image["content"]!]),
            ("unexpected", true)]
        for (key, value) in mutations {
            var changed = good; changed[key] = value
            XCTAssertThrowsError(try validate(HJSON.encode(changed)), key)
        }
        var missing = good; missing.removeValue(forKey: "sourceTree")
        XCTAssertThrowsError(try validate(HJSON.encode(missing)))
    }

    func testNativePredecessorEFramingPreservesOneLFAndRejectsOtherPaths() throws {
        let canonical = try HJSON.encode(["schema": "fixture", "value": 1])
        for path in ["predecessor-e-start.json", "predecessor-e-terminal.json"] {
            XCTAssertNoThrow(try PrimeValidationDriverV2ExecutionStaging.validatePredecessorEFrame(
                canonical + Data([10]), path: path))
            for bad in [canonical, canonical + Data([10, 10]), canonical + Data([13, 10]), Data([10])] {
                XCTAssertThrowsError(try PrimeValidationDriverV2ExecutionStaging.validatePredecessorEFrame(bad, path: path))
            }
        }
        for path in ["go.json", "../predecessor-e-start.json", "predecessor-e-start.json/child"] {
            XCTAssertThrowsError(try PrimeValidationDriverV2ExecutionStaging.validatePredecessorEFrame(
                canonical + Data([10]), path: path))
        }
    }

    func testNativeGoJoinsBothActualHeadsAndExactReplayedTreeBytes() throws {
        let commit = String(repeating: "a", count: 40), head = Data((commit + "\n").utf8)
        let tree = Data(("100644 blob " + String(repeating: "b", count: 40) + "\tSources/Fixture.swift\0").utf8)
        let digest = PrimeSHA256.hexDigest(of: tree)
        func validate(_ a: Data, _ b: Data, _ discovery: Data, _ replay: Data, _ hash: String = "") throws {
            try PrimeValidationDriverV2ExecutionGoScope.joinPrimeBytes(commit: commit,
                treeDigest: hash.isEmpty ? digest : hash, headPre: a, headPost: b, discovery: discovery, replay: replay)
        }
        XCTAssertNoThrow(try validate(head, head, tree, tree))
        for bad in [Data(head.dropLast()), head + Data([10]), Data((String(repeating: "c", count: 40) + "\n").utf8)] {
            XCTAssertThrowsError(try validate(bad, head, tree, tree))
            XCTAssertThrowsError(try validate(head, bad, tree, tree))
        }
        XCTAssertThrowsError(try validate(head, head, tree + Data([0]), tree))
        XCTAssertThrowsError(try validate(head, head, tree, tree + Data([0])))
        XCTAssertThrowsError(try validate(head, head, tree, tree, String(repeating: "0", count: 64)))
        XCTAssertThrowsError(try validate(head, head, Data(), Data(), PrimeSHA256.hexDigest(of: Data())))
    }

    private func lists() throws -> (Data, Data) {
        (try Data(contentsOf: XCTUnwrap(Bundle.module.url(forResource: "xctest", withExtension: "list"))),
         try Data(contentsOf: XCTUnwrap(Bundle.module.url(forResource: "swift-testing", withExtension: "list"))))
    }
}
