// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
import PrimeCore
import PrimeValidationWorkflowContracts
@testable import PrimeValidationWorkflowDriverCore
import XCTest

/// Value fixtures only: no native process, filesystem ownership or execution
/// claim. Full-plan fixtures use the exact retained frozen inventory bytes.
final class PrimeValidationDriverV2ExecutionBindingTests: XCTestCase {
    private typealias Raw = PrimeValidationDriverV2BoundRawArtifact
    private typealias Parser = PrimeValidationDriverV2ParsedRawResults
    private let xID = "PrimeCoreTests.ExampleTests/testOne"
    private let sID = "PrimeCoreTests.ExampleTests/testOne()"

    func testExecutionRawBindingRejectsByteHashCountAndPathMutation() throws {
        let data = Data("raw".utf8)
        let good = artifact("result", "results/raw.xml", data)
        XCTAssertNoThrow(try Raw(binding: good, data: data))
        XCTAssertThrowsError(try Raw(binding: good, data: Data("raw!".utf8)))
        XCTAssertThrowsError(try Raw(binding: artifact("result", "../raw.xml", data), data: data))
        XCTAssertThrowsError(try Raw(binding: .init(name: "result", relativePath: "results/raw.xml",
            content: .init(data: Data())), data: data))
    }

    func testExecutionStrictXUnitRejectsDuplicateUnexpectedAndMalformedIDs() throws {
        let ids = try [testID(xID, .xctest)]
        for data in [xml([xID, xID]), xml(["PrimeCoreTests.ExampleTests/testOther"]),
                     Data("<not-xunit/>".utf8), Data([0xff]),
                     xml([xID]) + Data([0])] {
            XCTAssertThrowsError(try Parser.parse(lane: .parallelXCTest, expectedIDs: ids,
                raw: raw("result", "result.xml", data)))
        }
        XCTAssertNoThrow(try Parser.parse(lane: .parallelXCTest, expectedIDs: ids,
            raw: raw("result", "result.xml", xml([xID]))))
    }

    func testExecutionSequentialParserRejectsMutationAndIncompleteTransitions() throws {
        let ids = try [testID(xID, .xctest)]
        let valid = transcript([xID])
        XCTAssertNoThrow(try Parser.parse(lane: .sequentialXCTest, expectedIDs: ids,
            raw: raw("result", "stdout.log", valid)))
        for data in [valid + Data([13]), valid + Data([27]),
                     transcript([xID, xID]), transcript(["PrimeCoreTests.ExampleTests/testOther"]),
                     Data("Test Suite 'All tests' started at now\n".utf8)] {
            XCTAssertThrowsError(try Parser.parse(lane: .sequentialXCTest, expectedIDs: ids,
                raw: raw("result", "stdout.log", data)))
        }
    }

    func testExecutionSwiftTestingUsesStrictParserAndRequiresObservedSkipReason() throws {
        let ids = try [testID(sID, .swiftTesting)]
        XCTAssertNoThrow(try Parser.parse(lane: .swiftTesting, expectedIDs: ids,
            raw: raw("result", "result.xml", xml([sID], failures: [sID]))))
        XCTAssertNoThrow(try Parser.parse(lane: .swiftTesting, expectedIDs: ids,
            raw: raw("result", "result.xml", xml([sID], skips: [sID: "required capability missing"]))))
        let noReason = String(decoding: xml([sID], skips: [sID: "reason"]), as: UTF8.self)
            .replacingOccurrences(of: " message=\"reason\"", with: "")
        XCTAssertThrowsError(try Parser.parse(lane: .swiftTesting, expectedIDs: ids,
            raw: raw("result", "result.xml", Data(noReason.utf8))))
        XCTAssertThrowsError(try Parser.parse(lane: .swiftTesting, expectedIDs: ids,
            raw: raw("result", "result.xml", xml([sID, sID]))))
    }

    func testExecutionAdapterRequiresExactFullyAdmittedPlan() throws {
        let f = try fixture()
        _ = try f.adapter()
        var fields = try XCTUnwrap(JSONSerialization.jsonObject(with: PrimeCanonicalJSON.encode(f.plan)) as? [String: Any])
        for (key, value) in [("inventorySHA256", String(repeating: "0", count: 64)),
                             ("buildReceiptSHA256", String(repeating: "1", count: 64))] {
            fields[key] = value
            let changed = try PrimeCanonicalJSON.decode(PrimeValidationExecutionPlanV2.self,
                from: JSONSerialization.data(withJSONObject: fields, options: [.sortedKeys, .withoutEscapingSlashes]))
            XCTAssertThrowsError(try PrimeValidationDriverV2ExecutionBinding(
                intent: f.intent, build: f.build, inventory: f.inventory, plan: changed))
        }
    }

    func testExecutionAdmissionJoinsInvocationPrimaryStreamsAndObservedProcess() throws {
        let f = try fixture(), adapter = try f.adapter()
        let index = try XCTUnwrap(f.plan.shards.firstIndex { $0.key.arm == .candidate && $0.key.lane == .parallelXCTest })
        let input = try makeInput(f, index: index)
        let accepted = try admit(adapter, input)
        XCTAssertEqual(accepted.evidence.receipt.process, input.child.process)
        XCTAssertEqual(accepted.evidence.receipt.semanticResults.map(\.testID), input.start.shard.testIDs)
        XCTAssertThrowsError(try adapter.admit(start: input.start, observedChild: input.child,
            result: raw("result", "wrong/result.xml", input.result.data),
            standardOutput: input.stdout, standardError: input.stderr))
        XCTAssertThrowsError(try adapter.admit(start: input.start, observedChild: input.child,
            result: input.result, standardOutput: raw("standard_output", input.stdout.binding.relativePath, Data("changed".utf8)),
            standardError: input.stderr))
        let badChild = observed(input.child.invocation, stdout: input.stdout.data, stderr: input.stderr.data,
            result: input.result.data, matched: input.start.shard.testIDs.count - 1)
        XCTAssertThrowsError(try adapter.admit(start: input.start, observedChild: badChild,
            result: input.result, standardOutput: input.stdout, standardError: input.stderr))
    }

    func testExecutionCompleteAndResumePublicAPIsRemainFailClosed() throws {
        let f = try fixture(), adapter = try f.adapter(), input = try makeInput(f, index: 0)
        let parsed = try admit(adapter, input)
        XCTAssertEqual(try adapter.resumeDecision(for: parsed), .reuseSucceededTerminal)
        XCTAssertEqual(try adapter.startedWithoutTerminal(input.start), .permanentlyIncomplete)
        XCTAssertThrowsError(try parsed.evidence.receipt.validate(start: input.start,
            expectedRunID: f.plan.runID, expectedExecutionPlanSHA256: adapter.planSHA256,
            maximumActiveNanoseconds: f.plan.maximumReferenceShardActiveNanoseconds))
        XCTAssertThrowsError(try PrimeValidationResumeStateMachineV2.decideShard(
            start: input.start, terminal: parsed.evidence.receipt,
            expectedRunID: f.plan.runID, expectedExecutionPlanSHA256: adapter.planSHA256,
            maximumActiveNanoseconds: f.plan.maximumReferenceShardActiveNanoseconds))
    }

    func testExecutionFailedParsedTerminalIsReusedOnlyAsFailure() throws {
        let f = try fixture(), adapter = try f.adapter()
        let input = try makeInput(f, index: 0, failing: f.plan.shards[0].testIDs[0].rawValue)
        let parsed = try admit(adapter, input)
        XCTAssertEqual(try adapter.resumeDecision(for: parsed), .reuseFailedTerminal)
        XCTAssertEqual(parsed.evidence.receipt.process.exitCode, 1)
    }

    func testExecutionParallelSkipNeedsSameArmSequentialRawAuthority() throws {
        let f = try fixture(), adapter = try f.adapter()
        let p = try XCTUnwrap(f.plan.shards.firstIndex { $0.key.arm == .reference && $0.key.lane == .parallelXCTest })
        let s = try XCTUnwrap(f.plan.shards.firstIndex { $0.key.arm == .reference && $0.key.lane == .sequentialXCTest })
        let admission = try XCTUnwrap(PrimeValidationOptionalSkipPolicy.admissions.first)
        let parallel = try admit(adapter, makeInput(f, index: p, skipping: admission.rawID, reason: "non-authoritative"))
        XCTAssertThrowsError(try adapter.resumeDecision(for: parallel))
        let sequential = try admit(adapter, makeInput(f, index: s, skipping: admission.rawID, reason: admission.exactReason))
        XCTAssertEqual(try adapter.resumeDecision(for: parallel, sequentialEvidence: [sequential]), .reuseSucceededTerminal)
        XCTAssertEqual(try adapter.resumeDecision(for: sequential), .reuseSucceededTerminal)
        let requiredSkip = try admit(adapter, makeInput(f, index: s, skipping: admission.rawID, reason: "different observed reason"))
        XCTAssertEqual(try adapter.resumeDecision(for: requiredSkip), .reuseFailedTerminal)
        let sequentialPass = try admit(adapter, makeInput(f, index: s))
        XCTAssertThrowsError(try adapter.resumeDecision(for: parallel, sequentialEvidence: [sequentialPass]))
    }

    func testExecutionAggregateUsesOnlyParsedExactPlanEvidence() throws {
        let f = try fixture(), adapter = try f.adapter()
        let parsed = try f.plan.shards.indices.map { try admit(adapter, makeInput(f, index: $0)) }
        let conclusion = try adapter.conclude(parsed)
        XCTAssertEqual(conclusion.reference.disposition, .completePass)
        XCTAssertEqual(conclusion.candidate.disposition, .completePass)
        XCTAssertEqual(conclusion.finalReceipt.disposition, .completePass)
        XCTAssertEqual(conclusion.finalReceipt.authority, .frozenPlannerV2)
        XCTAssertThrowsError(try adapter.conclude(parsed + [parsed[0]]))
        let missing = try adapter.conclude(Array(parsed.dropLast()))
        XCTAssertEqual(missing.finalReceipt.disposition, .incomplete)
        XCTAssertThrowsError(try conclusion.finalReceipt.validate(comparison: conclusion.comparison,
            reference: conclusion.reference, candidate: conclusion.candidate,
            executionPlan: f.plan, executionPlanSHA256: adapter.planSHA256))
    }

    func testExecutionTransitionCarriesOnlyExactSequentialSkipObligations() throws {
        let f = try fixture(), adapter = try f.adapter()
        let admission = try XCTUnwrap(PrimeValidationOptionalSkipPolicy.admissions.first)
        XCTAssertEqual(f.plan.shards[0].key.lane, .parallelXCTest)
        XCTAssertEqual(f.plan.shards[1].key.lane, .sequentialXCTest)
        let parallel = try admit(adapter, makeInput(f, index: 0, skipping: admission.rawID, reason: "marker"))
        XCTAssertEqual(try adapter.transition(after: [parallel]),
            .nextShard(shardID: f.plan.shards[1].shardID, pendingSequentialShardIDs: [f.plan.shards[1].shardID]))
        let sequential = try admit(adapter, makeInput(f, index: 1, skipping: admission.rawID, reason: admission.exactReason))
        XCTAssertEqual(try adapter.transition(after: [parallel, sequential]),
            .nextShard(shardID: f.plan.shards[2].shardID, pendingSequentialShardIDs: []))
        XCTAssertThrowsError(try adapter.transition(after: []))
        XCTAssertThrowsError(try adapter.transition(after: [sequential]))
        XCTAssertThrowsError(try adapter.transition(after: [parallel, parallel]))
        let disagree = try admit(adapter, makeInput(f, index: 1))
        XCTAssertThrowsError(try adapter.transition(after: [parallel, disagree]))
    }

    func testExecutionTransitionNeverFollowsFailedTerminal() throws {
        let f = try fixture(), adapter = try f.adapter()
        let first = try admit(adapter, makeInput(f, index: 0, failing: f.plan.shards[0].testIDs[0].rawValue))
        XCTAssertEqual(try adapter.transition(after: [first]), .stoppedAtFailedTerminal)
        let second = try admit(adapter, makeInput(f, index: 1))
        XCTAssertThrowsError(try adapter.transition(after: [first, second]))
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
            ? transcript(ids, failing: failing, skipping: skipping, reason: reason)
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

    private func fixture() throws -> Fixture {
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
            baseline: .init(), phaseBudgets: PrimeValidationDriverPhaseV2.allCases.map {
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
        let x = try Data(contentsOf: XCTUnwrap(Bundle.module.url(forResource: "xctest", withExtension: "list")))
        let s = try Data(contentsOf: XCTUnwrap(Bundle.module.url(forResource: "swift-testing", withExtension: "list")))
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
    private func transcript(_ ids: [String], failing: String? = nil, skipping: String? = nil, reason: String = "") -> Data {
        var lines = ["Test Suite 'All tests' started at 2026-09-07 00:00:00.000"]
        for id in ids {
            let parts = id.split(separator: "/", maxSplits: 1)
            let prefix = "Test Case '-[\(parts[0]) \(parts[1])]'"
            lines.append(prefix + " started.")
            if id == skipping { lines.append("/fixture/Test.swift:1: -[\(parts[0]) \(parts[1])] : Test skipped - " + reason) }
            lines.append(prefix + " \(id == failing ? "failed" : id == skipping ? "skipped" : "passed") (0.001 seconds).")
        }
        lines.append("Test Suite 'All tests' \(failing == nil ? "passed" : "failed") at 2026-09-07 00:00:01.000")
        lines.append("Executed \(ids.count) tests, with \(skipping == nil ? 0 : 1) tests skipped and \(failing == nil ? 0 : 1) failures (0 unexpected) in 0.001 (0.001) seconds")
        return Data((lines.joined(separator: "\n") + "\n").utf8)
    }
}
