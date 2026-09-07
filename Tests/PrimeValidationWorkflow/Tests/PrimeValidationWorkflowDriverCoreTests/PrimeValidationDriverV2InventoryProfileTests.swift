// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary
import Foundation
@_spi(PrimeValidationDriverV2RoleFacade) @testable import PrimeCore
import PrimeValidationWorkflowContracts
@testable import PrimeValidationWorkflowDriverCore
import XCTest

/// Pure closed-profile, original-planner and parser regression fixtures.
/// Process fields and result bytes below are synthetic test data, never native
/// execution evidence. A named profile cannot be chosen from incoming bytes.
final class PrimeValidationDriverV2InventoryProfileTests: XCTestCase {
    private typealias Raw = PrimeValidationDriverV2BoundRawArtifact
    private typealias Profile = PrimeValidationDriverV2InventoryProfile

    func testHistoricalDefaultBaselineBytesAndFullPlanRemainIdentical() throws {
        let baseline = PrimeValidationBaselineAnchorV2()
        let expected = Data(#"{"expectedSwiftTestingCount":12,"expectedSwiftTestingListByteCount":1287,"expectedSwiftTestingListSHA256":"487c601e9693d6a0fbc31d1b683ffd342ba0d10007c780f315af1113d825e8a3","expectedXCTestCount":892,"expectedXCTestListByteCount":114186,"expectedXCTestListSHA256":"93ccc091a0343ac4fed35b208447d7460eae27668ddec3e931f54b9a7769212b"}"#.utf8)
        XCTAssertEqual(try PrimeCanonicalJSON.encode(baseline), expected)
        let explicit = try PrimeCanonicalJSON.decode(PrimeValidationBaselineAnchorV2.self, from: expected)
        try explicit.validate()
        XCTAssertEqual(resolve(explicit), .historical904)
        let implicit = try fixture(), frozen = try fixture(baseline: explicit)
        XCTAssertEqual(try PrimeCanonicalJSON.encode(implicit.intent), try PrimeCanonicalJSON.encode(frozen.intent))
        XCTAssertEqual(try PrimeCanonicalJSON.encode(implicit.plan), try PrimeCanonicalJSON.encode(frozen.plan))
        let native = try PrimeValidationDriverV2ClosedShardSchedule.observeFrozenLists(
            runID: implicit.intent.runID, xctestData: implicit.inventory.xctestListData,
            swiftTestingData: implicit.inventory.swiftTestingListData)
        let explicitNative = try PrimeValidationDriverV2ClosedShardSchedule.observeFrozenLists(
            runID: implicit.intent.runID, xctestData: implicit.inventory.xctestListData,
            swiftTestingData: implicit.inventory.swiftTestingListData, profile: .historical904)
        XCTAssertEqual(native, explicitNative)
        XCTAssertEqual(native.canonicalShardsData, try PrimeCanonicalJSON.encode(implicit.plan.shards))
        XCTAssertEqual(native.shards.count, 72)
    }

    func testNamedCurrentProfileAdmitsOnlyItsCompleteSixFieldTuple() throws {
        let current = PrimeValidationBaselineAnchorV2.currentSourceInventoryV1
        try current.validate()
        XCTAssertEqual(resolve(current), .currentSourceInventoryV1)
        XCTAssertNotEqual(current, .init())
        XCTAssertEqual(current.expectedXCTestCount, 1068)
        XCTAssertEqual(current.expectedSwiftTestingCount, 12)
        XCTAssertEqual(current.expectedXCTestListByteCount, 139244)
        XCTAssertEqual(current.expectedXCTestListSHA256, "7428f3e1ebc8e76eb312c54feac209d0c70d8d741e1eb38cbab8b1d5b815ece2")
        XCTAssertEqual(current.expectedSwiftTestingListByteCount, 1287)
        XCTAssertEqual(current.expectedSwiftTestingListSHA256, "487c601e9693d6a0fbc31d1b683ffd342ba0d10007c780f315af1113d825e8a3")
        let object = try fields(current)
        XCTAssertEqual(Set(object.keys), Set(["expectedXCTestCount", "expectedSwiftTestingCount",
            "expectedXCTestListByteCount", "expectedXCTestListSHA256",
            "expectedSwiftTestingListByteCount", "expectedSwiftTestingListSHA256"]))
        XCTAssertNil(object["identifier"])
        XCTAssertEqual(try PrimeCanonicalJSON.decode(PrimeValidationBaselineAnchorV2.self,
            from: PrimeCanonicalJSON.encode(current)), current)
    }

    func testEveryTupleFieldMutationRejectsBothNamedProfiles() throws {
        for baseline in [PrimeValidationBaselineAnchorV2(), .currentSourceInventoryV1] {
            let original = try fields(baseline)
            for key in original.keys.sorted() {
                var changed = original
                if key.hasSuffix("SHA256") { changed[key] = String(repeating: "0", count: 64) }
                else { changed[key] = try XCTUnwrap(original[key] as? NSNumber).uint64Value + 1 }
                let value = try decodeBaseline(changed)
                XCTAssertNil(resolve(value), key)
                XCTAssertThrowsError(try value.validate(), key) { error in
                    XCTAssertEqual(error as? PrimeValidationDriverV2Error, .invalidBaseline)
                }
            }
        }
    }

    func testHistoricalCurrentXCTestTupleHybridsAreRejected() throws {
        let historical = try fields(PrimeValidationBaselineAnchorV2())
        let current = try fields(PrimeValidationBaselineAnchorV2.currentSourceInventoryV1)
        let xKeys = ["expectedXCTestCount", "expectedXCTestListByteCount", "expectedXCTestListSHA256"]
        // The Swift Testing tuple is currently identical in both profiles;
        // merely substituting identical values cannot be a mixed-pair error.
        for mask in 1..<7 {
            var mixed = historical
            for (index, key) in xKeys.enumerated() where mask & (1 << index) != 0 { mixed[key] = current[key] }
            let value = try decodeBaseline(mixed)
            XCTAssertNil(resolve(value))
            XCTAssertThrowsError(try value.validate()) { error in
                XCTAssertEqual(error as? PrimeValidationDriverV2Error, .invalidBaseline)
            }
        }
    }

    func testProfileSelectionNeverFallsBackToObservedListBytes() throws {
        let old = try fixture()
        let current = try fixture(baseline: .currentSourceInventoryV1, currentLists: true)
        XCTAssertThrowsError(try PrimeValidationDriverV2ClosedShardSchedule.observeFrozenLists(
            runID: old.intent.runID, xctestData: current.inventory.xctestListData,
            swiftTestingData: current.inventory.swiftTestingListData))
        XCTAssertThrowsError(try PrimeValidationDriverV2ClosedShardSchedule.observeFrozenLists(
            runID: old.intent.runID, xctestData: old.inventory.xctestListData,
            swiftTestingData: old.inventory.swiftTestingListData, profile: .currentSourceInventoryV1))
        XCTAssertThrowsError(try fixture(baseline: .currentSourceInventoryV1, currentLists: false))
        XCTAssertThrowsError(try fixture(baseline: .init(), currentLists: true))
        for profile in [Profile.historical904, .currentSourceInventoryV1] {
            let f = profile == .historical904 ? old : current
            XCTAssertThrowsError(try PrimeValidationDriverV2ClosedShardSchedule.observeFrozenLists(
                runID: f.intent.runID, xctestData: f.inventory.xctestListData + Data([10]),
                swiftTestingData: f.inventory.swiftTestingListData, profile: profile))
            XCTAssertThrowsError(try PrimeValidationDriverV2ClosedShardSchedule.observeFrozenLists(
                runID: f.intent.runID, xctestData: f.inventory.xctestListData,
                swiftTestingData: f.inventory.swiftTestingListData + Data([10]), profile: profile))
        }
    }

    func testCurrentFullOriginalPlanAndNativeScheduleHaveExactByteParity() throws {
        let f = try fixture(baseline: .currentSourceInventoryV1, currentLists: true)
        try f.plan.validate(intent: f.intent, buildReceipt: f.build, inventoryReceipt: f.inventory)
        let native = try PrimeValidationDriverV2ClosedShardSchedule.observeFrozenLists(
            runID: f.intent.runID, xctestData: f.inventory.xctestListData,
            swiftTestingData: f.inventory.swiftTestingListData, profile: .currentSourceInventoryV1)
        XCTAssertEqual(native.canonicalInventoryData, try PrimeCanonicalJSON.encode(f.plan.inventory))
        XCTAssertEqual(native.canonicalShardsData, try PrimeCanonicalJSON.encode(f.plan.shards))
        XCTAssertEqual(native.shards.count, f.plan.shards.count)
        for index in f.plan.shards.indices {
            XCTAssertEqual(native.shards[index].ordinal, index + 1)
            XCTAssertEqual(native.shards[index].canonicalPlanData, try PrimeCanonicalJSON.encode(f.plan.shards[index]))
            XCTAssertEqual(native.shards[index].selectedIdentifiers, f.plan.shards[index].testIDs.map(\.rawValue))
            XCTAssertEqual(native.shards[index].shardID, f.plan.shards[index].shardID)
        }
        XCTAssertEqual(f.plan.inventory.xctestIDs.count, 1068)
        XCTAssertEqual(f.plan.inventory.swiftTestingIDs.count, 12)
        XCTAssertEqual(f.plan.shards.filter { $0.key.arm == .reference }.count, 3)
    }

    func testComparisonCountsComeFromCurrentValidatedPlan() throws {
        let f = try fixture(baseline: .currentSourceInventoryV1, currentLists: true)
        let adapter = try f.adapter()
        let parsed = try f.plan.shards.indices.map { try admit(adapter, makeInput(f, index: $0)) }
        let conclusion = try adapter.conclude(parsed)
        XCTAssertEqual(conclusion.reference.disposition, .completePass)
        XCTAssertEqual(conclusion.candidate.disposition, .completePass)
        XCTAssertEqual(conclusion.comparison.expectedXCTestCount, 1068)
        XCTAssertEqual(conclusion.comparison.expectedSwiftTestingCount, 12)
        XCTAssertEqual(conclusion.reference.semanticResults.count, 1080)
        XCTAssertEqual(conclusion.candidate.semanticResults.count, 1080)
        XCTAssertEqual(conclusion.finalReceipt.authority, .frozenPlannerV2)
        // This is internal parser mechanics only; public completion stays shut.
        XCTAssertThrowsError(try conclusion.finalReceipt.validate(comparison: conclusion.comparison,
            reference: conclusion.reference, candidate: conclusion.candidate,
            executionPlan: f.plan, executionPlanSHA256: adapter.planSHA256))
    }

    func testNativeBaselineDecoderRejectsExtraKeysAndNonIntegerTupleValues() throws {
        for baseline in [PrimeValidationBaselineAnchorV2(), .currentSourceInventoryV1] {
            let data = try PrimeCanonicalJSON.encode(baseline)
            XCTAssertEqual(try Profile.resolve(canonicalBaselineData: data), resolve(baseline))
            let text = String(decoding: data, as: UTF8.self)
            let token = "\"expectedXCTestCount\":\(baseline.expectedXCTestCount)"
            for changedToken in ["\"expectedXCTestCount\":true", "\"expectedXCTestCount\":1.5",
                                 "\"expectedXCTestCount\":18446744073709551615"] {
                let changed = Data(text.replacingOccurrences(of: token, with: changedToken).utf8)
                XCTAssertNotEqual(changed, data)
                XCTAssertNil(try? Profile.resolve(canonicalBaselineData: changed))
            }
            let extraKey = Data((String(text.dropLast()) + ",\"extra\":1}").utf8)
            XCTAssertNil(try? Profile.resolve(canonicalBaselineData: extraKey))
            XCTAssertNil(try? Profile.resolve(canonicalBaselineData: data + Data([10])))
        }
    }

    private func resolve(_ b: PrimeValidationBaselineAnchorV2) -> Profile? {
        Profile.resolve(expectedXCTestCount: b.expectedXCTestCount,
            expectedSwiftTestingCount: b.expectedSwiftTestingCount,
            expectedXCTestListByteCount: b.expectedXCTestListByteCount,
            expectedXCTestListSHA256: b.expectedXCTestListSHA256,
            expectedSwiftTestingListByteCount: b.expectedSwiftTestingListByteCount,
            expectedSwiftTestingListSHA256: b.expectedSwiftTestingListSHA256)
    }
    private func fields(_ b: PrimeValidationBaselineAnchorV2) throws -> [String: Any] {
        try XCTUnwrap(JSONSerialization.jsonObject(with: PrimeCanonicalJSON.encode(b)) as? [String: Any])
    }
    private func decodeBaseline(_ object: [String: Any]) throws -> PrimeValidationBaselineAnchorV2 {
        let value = try JSONDecoder().decode(PrimeValidationBaselineAnchorV2.self,
            from: JSONSerialization.data(withJSONObject: object))
        return try PrimeCanonicalJSON.decode(PrimeValidationBaselineAnchorV2.self,
            from: PrimeCanonicalJSON.encode(value))
    }

    private struct Fixture {
        let intent: PrimeValidationRunIntentV2
        let build: PrimeValidationBuildReceiptV2
        let inventory: PrimeValidationInventoryReceiptV2
        let plan: PrimeValidationExecutionPlanV2
        func adapter() throws -> PrimeValidationDriverV2ExecutionBinding {
            try .init(intent: intent, build: build, inventory: inventory, plan: plan)
        }
    }
    private struct Input {
        let start: PrimeValidationShardStartV2
        let child: PrimeValidationObservedChildReceiptV2
        let result: Raw
        let stdout: Raw
        let stderr: Raw
    }
    private func admit(_ adapter: PrimeValidationDriverV2ExecutionBinding, _ input: Input) throws
        -> PrimeValidationDriverV2ParsedShardEvidence {
        try adapter.admit(start: input.start, observedChild: input.child, result: input.result,
            standardOutput: input.stdout, standardError: input.stderr)
    }
    private func makeInput(_ f: Fixture, index: Int, failing: String? = nil,
                       skipping: String? = nil, reason: String = "") throws -> Input {
        let shard = f.plan.shards[index], invocation = f.plan.shardInvocations[index]
        let ids = shard.testIDs.map(\.rawValue)
        let data = shard.key.lane == .sequentialXCTest
            ? transcript(ids, failing: failing, skipping: skipping, reason: reason, selected: shard.selectionMode == .exactFilter)
            : xml(ids, failures: failing.map { Set([$0]) } ?? [], skips: skipping.map { [$0: reason] } ?? [:])
        let stdout = shard.key.lane == .sequentialXCTest ? data : Data("bounded transcript\n".utf8)
        let child = observed(invocation, stdout: stdout, result: data,
            matched: ids.count, exit: failing == nil ? 0 : 1)
        let path: String
        switch invocation.primaryResult {
        case .standardOutput: path = invocation.standardOutputRelativePath
        case let .file(value): path = value
        case .none: throw PrimeValidationDriverV2Error.invalidExecutionPlan
        }
        return try .init(start: .init(runID: f.plan.runID,
            executionPlanSHA256: f.plan.identitySHA256(intent: f.intent, buildReceipt: f.build, inventoryReceipt: f.inventory),
            shard: shard), child: child,
            result: raw("result", path, data),
            stdout: raw("standard_output", invocation.standardOutputRelativePath, stdout),
            stderr: raw("standard_error", invocation.standardErrorRelativePath, Data()))
    }

    private func fixture(baseline: PrimeValidationBaselineAnchorV2 = .init(), currentLists: Bool = false) throws -> Fixture {
        func directory(_ name: String, _ inode: UInt64, _ mode: UInt16) -> PrimeValidationDirectoryBindingV2 {
            .init(absolutePath: "/private/tmp/h-parser-" + name, deviceID: 1, inode: inode, ownerUserID: 501, mode: mode)
        }
        let roots = PrimeValidationDriverRootLayoutV2(repositoryRoot: directory("source", 10, 0o755),
            companionRoot: directory("companion", 20, 0o755), workspaceRoot: directory("workspace", 30, 0o700),
            evidenceRoot: directory("evidence", 40, 0o700), scratchRelativePath: "root-release-build",
            cacheRelativePath: "cache", configRelativePath: "config", securityRelativePath: "security",
            clangModuleCacheRelativePath: "clang-module-cache", homeRelativePath: "home",
            swiftPMModuleCacheRelativePath: "swiftpm-module-cache", temporaryRelativePath: "tmp", outputRelativePath: "outputs")
        let metal = PrimeValidationRequiredMetallibV2(
            relativePath: "root-release-build/arm64-apple-macosx/release/mlx-swift_Cmlx.bundle/Contents/Resources/default.metallib",
            content: .init(data: Data("fixture metal".utf8)))
        let intent = PrimeValidationRunIntentV2(runID: "run-h-parser-fixture", roots: roots,
            sourceSnapshot: .init(data: Data("source".utf8)), packageLock: .init(data: Data("lock".utf8)),
            driverExecutable: .init(absolutePath: "/private/tmp/h-parser-driver", content: .init(data: Data("driver".utf8))),
            swiftExecutable: .init(absolutePath: "/usr/bin/swift", content: .init(data: Data("swift".utf8))),
            companionCommit: PrimeValidationRunIntentV2.requiredCompanionCommit, requiredPinnedMetallib: metal,
            baseline: baseline, phaseBudgets: PrimeValidationDriverPhaseV2.allCases.map {
                .init(phase: $0, maximumActiveNanoseconds: 1_000_000)
            }, environmentPolicy: .make(roots: roots, pinnedMetallib: metal),
            optionalSkipPolicySHA256: try PrimeValidationOptionalSkipPolicy.identitySHA256())
        let buildInvocation = try PrimeValidationInvocationFactoryV2.build(intent: intent)
        let tree = try PrimeValidationBundleTreeBindingV2.make(entries: [
            .init(relativePath: "Contents", kind: .directory, mode: 0o755, content: nil),
            .init(relativePath: "Contents/Info.plist", kind: .regularFile, mode: 0o644, content: .init(data: Data("plist".utf8))),
            .init(relativePath: "Contents/MacOS", kind: .directory, mode: 0o755, content: nil),
            .init(relativePath: "Contents/MacOS/PrimeTests", kind: .executable, mode: 0o755, content: .init(data: Data("test".utf8))),
        ])
        let build = PrimeValidationBuildReceiptV2(runID: intent.runID, intentSHA256: try intent.identitySHA256(),
            invocation: buildInvocation, observedChild: observed(buildInvocation, matched: 0),
            sourceSnapshotAfterBuild: intent.sourceSnapshot, packageLockAfterBuild: intent.packageLock,
            pinnedMetallibAfterBuild: metal, testBundle: tree, activeNanoseconds: 1)
        let x = try Data(contentsOf: XCTUnwrap(Bundle.module.url(forResource: currentLists ? "current-source-inventory-v1-xctest" : "xctest", withExtension: "list")))
        let s = try Data(contentsOf: XCTUnwrap(Bundle.module.url(forResource: currentLists ? "current-source-inventory-v1-swift-testing" : "swift-testing", withExtension: "list")))
        let parsed = try PrimeValidationInventory.parse(xctestList: x, swiftTestingList: s)
        let invocations = try PrimeValidationInvocationFactoryV2.inventory(intent: intent)
        let inventory = PrimeValidationInventoryReceiptV2(runID: intent.runID, intentSHA256: try intent.identitySHA256(),
            buildReceiptSHA256: try build.identitySHA256(against: intent), invocations: invocations,
            observedChildren: [observed(invocations[0], stdout: x, matched: parsed.xctestIDs.count),
                               observed(invocations[1], stdout: s, matched: parsed.swiftTestingIDs.count)],
            xctestListArtifact: artifact("xctest_list", invocations[0].standardOutputRelativePath, x),
            swiftTestingListArtifact: artifact("swift_testing_list", invocations[1].standardOutputRelativePath, s),
            xctestListData: x, swiftTestingListData: s, inventory: parsed, activeNanoseconds: 2)
        return try .init(intent: intent, build: build, inventory: inventory,
            plan: .make(intent: intent, buildReceipt: build, inventoryReceipt: inventory))
    }

    private func observed(_ invocation: PrimeValidationInvocationV2, stdout: Data = Data(), stderr: Data = Data(),
                          result: Data = Data(), matched: Int, exit: Int32 = 0) -> PrimeValidationObservedChildReceiptV2 {
        let out = artifact("standard_output", invocation.standardOutputRelativePath, stdout)
        let err = artifact("standard_error", invocation.standardErrorRelativePath, stderr)
        let primary: PrimeValidationObservedPrimaryResultV2
        switch invocation.primaryResult {
        case .none: primary = .none
        case .standardOutput: primary = .standardOutput
        case let .file(path): primary = .file(artifact("primary_result", path, result))
        }
        func stream(_ data: Data) -> PrimeValidationStreamAuditV2 {
            .init(eofObserved: true, totalByteCount: UInt64(data.count), capturedByteCount: UInt64(data.count),
                overflowObserved: false, readErrorNumber: 0, writeErrorNumber: 0)
        }
        let process = PrimeValidationProcessAuditV2(processIdentifier: 100, sessionIdentifier: 100,
            processGroupIdentifier: 100, deadlineDisposition: .completed, sigtermDelivery: .notAttempted,
            sigkillDelivery: .notAttempted, preReapProcessGroupMembers: [100], exactReturnedProcessIdentifier: 100,
            rawWaitStatus: exit << 8, waitTermination: .exited(exit), processGroupEmptyAfterReap: true,
            standardOutput: stream(stdout), standardError: stream(stderr), matchedTestCount: matched)
        return .init(invocation: invocation, primaryResult: primary, standardOutputArtifact: out,
            standardErrorArtifact: err, process: process, activeNanoseconds: 1)
    }
    private func artifact(_ name: String, _ path: String, _ data: Data) -> PrimeValidationDriverArtifactBindingV2 {
        .init(name: name, relativePath: path, content: .init(data: data))
    }
    private func raw(_ name: String, _ path: String, _ data: Data) throws -> Raw {
        try .init(binding: artifact(name, path, data), data: data)
    }
    private func testID(_ id: String, _ framework: PrimeValidationFramework) throws -> PrimeValidationTestID {
        try .parse(id, framework: framework)
    }
    private func xml(_ ids: [String], failures: Set<String> = [], skips: [String: String] = [:]) -> Data {
        let rows = ids.map { id in
            let parts = id.split(separator: "/", maxSplits: 1)
            let child = failures.contains(id) ? "<failure message=\"failed\"/>"
                : skips[id].map { "<skipped message=\"\($0)\"/>" } ?? ""
            return "<testcase classname=\"\(parts[0])\" name=\"\(parts[1])\" time=\"0.001\">\(child)</testcase>"
        }.joined()
        return Data("<testsuites><testsuite name=\"TestResults\" tests=\"\(ids.count)\" failures=\"\(failures.count)\" errors=\"0\" skipped=\"\(skips.count)\" time=\"0.001\">\(rows)</testsuite></testsuites>".utf8)
    }
    private func transcript(_ ids: [String], failing: String? = nil, skipping: String? = nil, reason: String = "", selected: Bool = false) -> Data {
        let suite = selected ? "Selected tests" : "All tests"
        var lines = ["Test Suite '\(suite)' started at 2026-09-07 00:00:00.000"]
        for id in ids {
            let parts = id.split(separator: "/", maxSplits: 1)
            let prefix = "Test Case '-[\(parts[0]) \(parts[1])]'"
            lines.append(prefix + " started.")
            if id == skipping { lines.append("/fixture/Test.swift:1: -[\(parts[0]) \(parts[1])] : Test skipped - " + reason) }
            lines.append(prefix + " \(id == failing ? "failed" : id == skipping ? "skipped" : "passed") (0.001 seconds).")
        }
        lines.append("Test Suite '\(suite)' \(failing == nil ? "passed" : "failed") at 2026-09-07 00:00:01.000")
        lines.append("Executed \(ids.count) tests, with \(skipping == nil ? 0 : 1) tests skipped and \(failing == nil ? 0 : 1) failures (0 unexpected) in 0.001 (0.001) seconds")
        return Data((lines.joined(separator: "\n") + "\n").utf8)
    }
}
