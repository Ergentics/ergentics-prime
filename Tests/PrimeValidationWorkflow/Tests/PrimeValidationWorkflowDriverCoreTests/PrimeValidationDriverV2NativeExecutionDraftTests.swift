// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary
import Foundation
import Darwin
@_spi(PrimeValidationDriverV2RoleFacade) @testable import PrimeCore
import PrimeValidationWorkflowContracts
@testable import PrimeValidationWorkflowDriverCore
import XCTest

/// Pure actual-source projections and owner cursor. No process or native
/// capability is created, and no live Gate H execution is asserted.
final class PrimeValidationDriverV2NativeExecutionDraftTests: XCTestCase {
    func testHTimeoutCleanupKillsSeparateWorkerGroupsBeforeLeaderAndWaitsForReparentedZombies() throws {
        let model = HCleanupModel()
        let owner = try model.owner()
        try owner.contain(leaderAlreadyReaped: false) {
            model.events.append("leader_cleanup")
            XCTAssertTrue(model.events.contains("signal:20:9"))
            XCTAssertTrue(model.events.contains("signal:5:9"))
            XCTAssertLessThan(model.events.firstIndex(of: "signal:5:9")!, model.events.firstIndex(of: "signal:20:9")!)
            model.reapLeader()
            return true
        }
        XCTAssertEqual(model.leaderReaps, 1)
        XCTAssertGreaterThanOrEqual(model.settlingPauses, 2)
        XCTAssertEqual(Set(owner.captured.map(\.pid)), [5, 10, 20])
        XCTAssertFalse(model.events.contains(where: { $0.hasPrefix("signal:1:") }))
        XCTAssertThrowsError(try owner.contain(leaderAlreadyReaped: true) { XCTFail("second cleanup"); return true })
    }

    func testHTimeoutCleanupRejectsUnownedAncestrySessionUIDAndDuplicatePIDBeforeWorkerSignals() throws {
        typealias I = PrimeValidationDriverV2ShardDescendantCleanup.Identity
        let mutations: [(I) -> I] = [
            { HCleanupModel.changed($0, parent: 99) },
            { HCleanupModel.changed($0, session: 99) },
            { HCleanupModel.changed($0, uid: 0) },
            { HCleanupModel.changed($0, group: 1) },
            { HCleanupModel.changed($0, parent: 20) },
        ]
        for mutate in mutations {
            let model = HCleanupModel()
            model.members[20] = mutate(model.members[20]!)
            let owner = try model.owner()
            XCTAssertThrowsError(try owner.contain(leaderAlreadyReaped: false) { XCTFail("unowned tree reaped"); return true })
            XCTAssertFalse(model.events.contains(where: { $0.hasPrefix("signal:20:") || $0.hasPrefix("signal:5:") }))
        }
        let duplicate = HCleanupModel(); duplicate.duplicatePID = true
        XCTAssertThrowsError(try duplicate.owner().contain(leaderAlreadyReaped: false) { XCTFail("duplicate tree reaped"); return true })
    }

    func testHTimeoutCleanupRejectsGenerationOrParentChangeAtSignalWithoutActuatingReplacement() throws {
        for change in ["generation", "parent", "session", "group", "uid"] {
            let model = HCleanupModel(); model.identityMutation = change
            XCTAssertThrowsError(try model.owner().contain(leaderAlreadyReaped: false) { XCTFail("replacement tree reaped"); return true })
            XCTAssertFalse(model.events.contains(where: { $0.hasPrefix("signal:20:") }))
        }
    }

    func testHTimeoutCleanupRequiresActualGroupDisappearanceAndFailsClosedWithinOwnDeadline() throws {
        let model = HCleanupModel(); model.groupNeverDisappears = true; model.pauseStep = 100_000_000
        XCTAssertThrowsError(try model.owner().contain(leaderAlreadyReaped: false) { model.reapLeader(); return true })
        XCTAssertEqual(model.leaderReaps, 1)
        XCTAssertLessThanOrEqual(model.time, 15_000_000_000)
        let overrun = HCleanupModel()
        XCTAssertThrowsError(try overrun.owner().contain(leaderAlreadyReaped: false) {
            overrun.reapLeader(); overrun.time += 15_000_000_000; return true
        })
        let regression = HCleanupModel(); regression.regressClock = true
        XCTAssertThrowsError(try regression.owner().contain(leaderAlreadyReaped: false) { XCTFail("clock regression"); return true })
        let failed = HCleanupModel(); failed.failSignal = true
        XCTAssertThrowsError(try failed.owner().contain(leaderAlreadyReaped: false) { XCTFail("failed stop"); return true })
    }

    func testHTimeoutCleanupAfterLeaderReapDoesNotSignalOrAcquireLateMemberAuthority() throws {
        let empty = HCleanupModel(); empty.members = [:]
        try empty.owner().contain(leaderAlreadyReaped: true) { empty.leaderReaps += 1; return true }
        XCTAssertEqual(empty.leaderReaps, 1)
        XCTAssertFalse(empty.events.contains(where: { $0.hasPrefix("signal:") }))
        let late = HCleanupModel(); late.members.removeValue(forKey: 10)
        XCTAssertThrowsError(try late.owner().contain(leaderAlreadyReaped: true) { true })
        XCTAssertFalse(late.events.contains(where: { $0.hasPrefix("signal:") }))
    }

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
        let intent = try HJSON.encode(["driverExecutable": image,
            "phaseBudgets": JSONSerialization.jsonObject(with:
                PrimeValidationDriverV2ExecutionBudgetProfile.frozenV1.canonicalPhaseBudgetsData)])
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

private final class HCleanupModel {
    typealias Owner = PrimeValidationDriverV2ShardDescendantCleanup
    typealias I = Owner.Identity
    let leader = I(pid: 10, parent: 1, session: 1, group: 10, uid: 501,
        startSeconds: 100, startMicroseconds: 1, status: 4)
    var members: [Int32: I] = [:]
    var time: UInt64 = 1_000_000_000
    var pauseStep: UInt64 = 1_000_000
    var events: [String] = []
    var leaderReaps = 0
    var settlingPauses = 0
    var duplicatePID = false
    var identityMutation: String?
    var groupNeverDisappears = false
    var failSignal = false
    var regressClock = false
    private var clockReads = 0

    init() {
        members = [10: leader,
            20: I(pid: 20, parent: 10, session: 1, group: 20, uid: 501,
                startSeconds: 101, startMicroseconds: 2, status: 2),
            5: I(pid: 5, parent: 20, session: 1, group: 5, uid: 501,
                startSeconds: 102, startMicroseconds: 3, status: 2)]
    }
    static func changed(_ p: I, parent: Int32? = nil, session: Int32? = nil,
        group: Int32? = nil, uid: UInt32? = nil, start: UInt64? = nil, status: UInt32? = nil) -> I {
        I(pid: p.pid, parent: parent ?? p.parent, session: session ?? p.session,
          group: group ?? p.group, uid: uid ?? p.uid, startSeconds: start ?? p.startSeconds,
          startMicroseconds: p.startMicroseconds, status: status ?? p.status)
    }
    func owner() throws -> Owner {
        try Owner(leader: leader, operations: .init(now: {
            self.clockReads += 1
            return self.regressClock && self.clockReads > 1 ? 0 : self.time
        }, snapshot: { _ in
            var result = Array(self.members.values)
            if self.duplicatePID, let leader = self.members[10] { result.append(leader) }
            return result
        }, identity: { pid, _ in
            guard let p = self.members[pid] else { return nil }
            guard pid == 20 else { return p }
            switch self.identityMutation {
            case "generation": return Self.changed(p, start: p.startSeconds + 1)
            case "parent": return Self.changed(p, parent: 1)
            case "session": return Self.changed(p, session: 99)
            case "group": return Self.changed(p, group: 99)
            case "uid": return Self.changed(p, uid: 0)
            default: return p
            }
        }, signal: { pid, signal in
            self.events.append("signal:\(pid):\(signal)")
            if self.failSignal { return false }
            if let p = self.members[pid] {
                self.members[pid] = Self.changed(p, status: signal == SIGSTOP ? 4 : 5)
            }
            if signal == SIGKILL {
                for (child, p) in self.members where p.parent == pid {
                    self.members[child] = Self.changed(p, parent: 1)
                }
            }
            return true
        }, groupAbsent: { group in
            !self.groupNeverDisappears && !self.members.values.contains(where: { $0.group == group })
        }, pause: {
            self.time += self.pauseStep
            if self.leaderReaps > 0 {
                self.settlingPauses += 1
                if self.settlingPauses >= 2 { self.members.removeAll() }
            }
        }))
    }
    func reapLeader() {
        leaderReaps += 1
        members.removeValue(forKey: 10)
        for (pid, p) in members { members[pid] = Self.changed(p, parent: 1, status: 5) }
    }
}
