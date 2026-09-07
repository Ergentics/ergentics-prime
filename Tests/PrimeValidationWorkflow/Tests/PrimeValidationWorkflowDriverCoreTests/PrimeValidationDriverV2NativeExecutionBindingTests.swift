// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
@_spi(PrimeValidationDriverV2RoleFacade) import PrimeCore
import PrimeValidationWorkflowContracts
@testable import PrimeValidationWorkflowDriverCore
import XCTest

/// These decoded fixtures test pure joins. They never construct a native
/// owner, start a process, or claim their process values were observed.
final class PrimeValidationDriverV2NativeExecutionBindingTests: XCTestCase {
    private typealias V = PrimeValidationDriverV2NativeExecutionValidation

    func testNativeExecutionClosedScheduleMatchesEveryOriginalPlannerShard() throws {
        let x = try Data(contentsOf: XCTUnwrap(Bundle.module.url(forResource: "xctest", withExtension: "list")))
        let s = try Data(contentsOf: XCTUnwrap(Bundle.module.url(forResource: "swift-testing", withExtension: "list")))
        let inventory = try PrimeValidationInventory.parse(xctestList: x, swiftTestingList: s)
        let original = try PrimeValidationShardPlannerV2.plan(inventory: inventory, runID: "run-native-h-fixture")
        let native = try PrimeValidationDriverV2ClosedShardSchedule.observeFrozenLists(
            runID: "run-native-h-fixture", xctestData: x, swiftTestingData: s)
        XCTAssertEqual(native.canonicalInventoryData, try PrimeCanonicalJSON.encode(inventory))
        XCTAssertEqual(native.canonicalShardsData, try PrimeCanonicalJSON.encode(original))
        XCTAssertEqual(native.shards.count, original.count)
        for index in original.indices {
            try V.validateShardProjection(native.shards[index], original: original[index], index: index)
        }
        XCTAssertThrowsError(try PrimeValidationDriverV2ClosedShardSchedule.observeFrozenLists(
            runID: "run-native-h-fixture", xctestData: x + Data([10]), swiftTestingData: s))
    }

    func testNativeExecutionShardProjectionRejectsEveryIdentityMutation() throws {
        let (original, observed) = try shard()
        try V.validateShardProjection(observed, original: original, index: 0)
        let mutations: [(String, Any)] = [
            ("ordinal", 2), ("arm", "candidate"), ("lane", "sequential_xctest"), ("index", 1),
            ("shardID", String(repeating: "0", count: 64)),
            ("selectedIdentifiers", ["PrimeCoreTests.Other/testOther"]),
            ("filterPattern", ".*"), ("canonicalPlanData", Data("{}".utf8).base64EncodedString()),
        ]
        for (key, value) in mutations {
            var fields = try object(observed); fields[key] = value
            let changed: PrimeValidationDriverV2ClosedShardObservation = try decode(fields)
            XCTAssertThrowsError(try V.validateShardProjection(changed, original: original, index: 0), key)
        }
        XCTAssertThrowsError(try V.validateShardProjection(observed, original: original, index: 1))
    }

    func testNativeExecutionLifecycleJoinsSupervisorBudgetWaitAndStreams() throws {
        try V.validateNativeProcess(process(), supervisorPID: 99)
        let mutations: [(String, Any)] = [
            ("processIdentifier", 99), ("sessionIdentifier", 101), ("parentProcessIdentifier", 98),
            ("processGroupIdentifier", 99), ("mappedImageJoined", false),
            ("exactSuspendedWorkingDirectoryJoin", false), ("appliedSpawnFlags", 0), ("spawnReturnCode", 1),
            ("deadlineStartedAtUptimeNanoseconds", 0), ("deadlineStartedAtUptimeNanoseconds", UInt64.max),
            ("deadlineExpiresAtUptimeNanoseconds", UInt64(300_000_001_000)),
            ("deadlineExpiresAtUptimeNanoseconds", UInt64.max),
            ("spawnReturnedUptimeNanoseconds", 999), ("resumedAtUptimeNanoseconds", 1099),
            ("deathObservedUptimeNanoseconds", 1199), ("waitReturnedUptimeNanoseconds", 1299),
            ("waitReturnedUptimeNanoseconds", UInt64(1_800_000_001_000)),
            ("preReapProcessGroupMemberIdentifiers", [101, 102]), ("requestedWaitProcessIdentifier", 102),
            ("returnedWaitProcessIdentifier", 102), ("exactReapCount", 2), ("cleanupInitiated", true),
            ("waitOptions", 1), ("rawWaitStatus", 1), ("exitedNormally", false),
            ("exitStatus", 256), ("terminationSignal", 9), ("coreDumped", true),
            ("processGroupEmptyAfterReap", false),
        ]
        for (key, value) in mutations {
            var fields = processFields(); fields[key] = value
            XCTAssertThrowsError(try V.validateNativeProcess(decode(fields), supervisorPID: 99), key)
        }
        var failed = processFields(); failed["exitStatus"] = 1; failed["rawWaitStatus"] = 256
        // A valid failed process fact is retained for the parser's stop
        // decision. Native acceptance separately prohibits its continuation.
        XCTAssertNoThrow(try V.validateNativeProcess(decode(failed), supervisorPID: 99))
        for key in ["standardOutput", "standardError"] {
            var fields = processFields(), stream = try XCTUnwrap(fields[key] as? [String: Any])
            stream["reachedEOF"] = false; fields[key] = stream
            XCTAssertThrowsError(try V.validateNativeProcess(decode(fields), supervisorPID: 99))
        }
    }

    func testNativeExecutionContentJoinRejectsPurposePathBytesHashAndCount() throws {
        let bytes = Data("raw-result".utf8), binding = artifact("shards/result.xml", Data("raw-result".utf8))
        _ = try V.bound(binding, name: "result", path: binding.relativePath, data: bytes)
        XCTAssertThrowsError(try V.bound(binding, name: "result", path: "shards/other.xml", data: bytes))
        XCTAssertThrowsError(try V.bound(binding, name: "result", path: binding.relativePath, data: bytes + Data([10])))
        for changed in [
            PrimeArtifactBinding(relativePath: binding.relativePath, sha256: binding.sha256,
                byteCount: UInt64.max, purpose: .immutableData),
            PrimeArtifactBinding(relativePath: binding.relativePath, sha256: String(repeating: "0", count: 64),
                byteCount: binding.byteCount, purpose: .immutableData),
            PrimeArtifactBinding(relativePath: binding.relativePath, sha256: binding.sha256,
                byteCount: binding.byteCount, purpose: .executable),
        ] { XCTAssertThrowsError(try V.bound(changed, name: "result", path: binding.relativePath, data: bytes)) }
    }

    func testNativeExecutionSupervisedShardProjectionRetainsSIDAndExactInvocation() throws {
        let (shard, _) = try shard(), root = V.shardRoot(shard), empty = PrimeValidationContentBinding(data: Data())
        let invocation = PrimeValidationInvocationV2(runID: shard.key.runID, role: .shard,
            shardKey: shard.key, shardID: shard.shardID,
            executable: .init(absolutePath: "/fixture/swift", content: .init(data: Data([1]))),
            arguments: ["test", "--skip-build"], orderedEnvironment: [],
            workingDirectoryAbsolutePath: "/fixture/repository", primaryResult: .file(relativePath: root + "/result.xml"),
            standardOutputRelativePath: root + "/stdout.log", standardErrorRelativePath: root + "/stderr.log")
        let out = PrimeValidationDriverArtifactBindingV2(name: "standard_output", relativePath: invocation.standardOutputRelativePath, content: empty)
        let err = PrimeValidationDriverArtifactBindingV2(name: "standard_error", relativePath: invocation.standardErrorRelativePath, content: empty)
        let primary = PrimeValidationObservedPrimaryResultV2.file(.init(name: "primary_result", relativePath: root + "/result.xml", content: empty))
        let child = try V.makeChild(invocation: invocation, primary: primary, process: process(),
            intervalStartedAt: 1000, matchedCount: 1, stdout: out, stderr: err, supervisorPID: 99)
        try child.validate(expectedInvocation: invocation, maximumActiveNanoseconds: 1_800_000_000_000)
        XCTAssertEqual(child.process.supervisorSessionIdentifier, 99)
        XCTAssertEqual(child.process.sessionIdentifier, 99)
        XCTAssertEqual(child.process.processIdentifier, 101)
        XCTAssertEqual(child.activeNanoseconds, 400)
        XCTAssertThrowsError(try V.makeChild(invocation: invocation, primary: primary, process: process(),
            intervalStartedAt: 1000, matchedCount: 1, stdout: out, stderr: err, supervisorPID: 98))
        var fields = try object(invocation); fields["arguments"] = ["test", "--filter", ".*"]
        let changed: PrimeValidationInvocationV2 = try decode(fields)
        XCTAssertThrowsError(try child.validate(expectedInvocation: changed, maximumActiveNanoseconds: 1_800_000_000_000))
        XCTAssertThrowsError(try V.makeChild(invocation: invocation, primary: primary, process: process(),
            intervalStartedAt: UInt64.max, matchedCount: 1, stdout: out, stderr: err, supervisorPID: 99))
    }

    func testNativeExecutionAcceptanceBindsRawObservationAndExactNextOnly() throws {
        let raw = try rawObservation(), nextID = String(repeating: "a", count: 64)
        let data = try V.acceptance(raw, transition: .nextShard(shardID: nextID,
            pendingSequentialShardIDs: [nextID]), nextOriginalShardID: nextID)
        let fields = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(Set(fields.keys), ["schema", "executionPlanSHA256", "rawObservationSHA256",
            "shardID", "nextShardID", "semanticTransition"])
        XCTAssertEqual(fields["rawObservationSHA256"] as? String,
            PrimeSHA256.hexDigest(of: try PrimeCanonicalJSON.encode(raw)))
        XCTAssertEqual(fields["nextShardID"] as? String, nextID)
        XCTAssertThrowsError(try V.acceptance(raw,
            transition: .nextShard(shardID: nextID, pendingSequentialShardIDs: []), nextOriginalShardID: "wrong"))
        XCTAssertThrowsError(try V.acceptance(raw, transition: .readyForConclusion, nextOriginalShardID: nextID))
        XCTAssertThrowsError(try V.acceptance(raw, transition: .stoppedAtFailedTerminal, nextOriginalShardID: ""))
        let final = try V.acceptance(raw, transition: .readyForConclusion, nextOriginalShardID: "")
        let finalFields = try XCTUnwrap(JSONSerialization.jsonObject(with: final) as? [String: Any])
        XCTAssertEqual(finalFields["semanticTransition"] as? String, "ready_for_conclusion")
        XCTAssertEqual(finalFields["nextShardID"] as? String, "")
    }

    func testNativeExecutionPrestartJournalUsesActualCoreEncoding() throws {
        let raw = try rawObservation(), p = raw.process
        let fields: [String: Any] = ["schema": "prime_driver_v2_gate_h_shard_prestart_v1",
            "executionPlanSHA256": raw.executionPlanSHA256, "shardID": raw.shard.shardID,
            "runID": "run-native-h-fixture", "ordinal": 1, "role": "shard",
            "predecessorSHA256": String(repeating: "b", count: 64),
            "deadlineStartedAtUptimeNanoseconds": p.deadlineStartedAtUptimeNanoseconds,
            "deadlineExpiresAtUptimeNanoseconds": p.deadlineExpiresAtUptimeNanoseconds,
            "executableAbsolutePath": p.executableAbsolutePath, "executableSHA256": p.executableSHA256,
            "logicalArgumentZero": p.logicalArgumentZero, "physicalArgumentZero": try XCTUnwrap(p.physicalArgumentZero), "arguments": p.arguments,
            "orderedEnvironment": p.orderedEnvironment, "workingDirectoryAbsolutePath": p.workingDirectoryAbsolutePath]
        let prestart: PrimeValidationDriverV2ExecutionPrestartV1 = try decode(fields)
        let binding = artifact("shards/fixture/prestart.json", try PrimeCanonicalJSON.encode(prestart))
        try PrimeValidationDriverV2InventoryDurableBindingEnvelopeV1.validateJournalBinding(binding,
            path: binding.relativePath, type: PrimeValidationDriverV2ExecutionPrestartV1.self, object: fields)
        for alternate in ["swift-test", "/fixture/swift-build", ""] {
            var changed = fields; changed["physicalArgumentZero"] = alternate
            XCTAssertThrowsError(try PrimeValidationDriverV2InventoryDurableBindingEnvelopeV1.validateJournalBinding(binding,
                path: binding.relativePath, type: PrimeValidationDriverV2ExecutionPrestartV1.self, object: changed))
        }
        var missing = fields; missing.removeValue(forKey: "physicalArgumentZero")
        XCTAssertThrowsError(try PrimeValidationDriverV2InventoryDurableBindingEnvelopeV1.validateJournalBinding(binding,
            path: binding.relativePath, type: PrimeValidationDriverV2ExecutionPrestartV1.self, object: missing))
        var changed = fields; changed["predecessorSHA256"] = String(repeating: "c", count: 64)
        XCTAssertThrowsError(try PrimeValidationDriverV2InventoryDurableBindingEnvelopeV1.validateJournalBinding(binding,
            path: binding.relativePath, type: PrimeValidationDriverV2ExecutionPrestartV1.self, object: changed))
    }

    private func shard() throws -> (PrimeValidationShardPlanV2, PrimeValidationDriverV2ClosedShardObservation) {
        let id = try PrimeValidationTestID.parse("PrimeCoreTests.ExampleTests/testOne", framework: .xctest)
        let original = try PrimeValidationShardPlanV2.make(key: .init(runID: "run-native-h-fixture",
            arm: .reference, lane: .parallelXCTest, index: 0), selectionMode: .allInventory,
            testIDs: [id], filterPattern: "")
        let fields: [String: Any] = ["ordinal": 1, "arm": "reference", "lane": "parallel_xctest", "index": 0,
            "shardID": original.shardID, "selectedIdentifiers": [id.rawValue], "filterPattern": "",
            "canonicalPlanData": try PrimeCanonicalJSON.encode(original).base64EncodedString()]
        return (original, try decode(fields))
    }
    private func rawObservation() throws -> PrimeValidationDriverV2ShardRawObservation {
        let (_, shard) = try shard(), empty = Data()
        return try decode(["shard": object(shard), "executionPlanSHA256": String(repeating: "d", count: 64),
            "process": processFields(), "prestartBinding": object(artifact("prestart.json", empty)),
            "startBinding": object(artifact("start.json", empty)), "terminalBinding": object(artifact("terminal.json", empty)),
            "standardOutputBinding": object(artifact("stdout.log", empty)),
            "standardErrorBinding": object(artifact("stderr.log", empty)),
            "standardOutputData": empty.base64EncodedString(), "standardErrorData": empty.base64EncodedString()])
    }
    private func artifact(_ path: String, _ data: Data) -> PrimeArtifactBinding {
        .init(relativePath: path, sha256: PrimeSHA256.hexDigest(of: data), byteCount: UInt64(data.count), purpose: .immutableData)
    }
    private func object<T: Encodable>(_ value: T) throws -> [String: Any] {
        try XCTUnwrap(JSONSerialization.jsonObject(with: PrimeCanonicalJSON.encode(value)) as? [String: Any])
    }
    private func decode<T: Codable>(_ fields: [String: Any]) throws -> T {
        let value = try JSONDecoder().decode(T.self, from: JSONSerialization.data(withJSONObject: fields))
        return try PrimeCanonicalJSON.decode(T.self, from: PrimeCanonicalJSON.encode(value))
    }
    private func process() throws -> PrimeValidationDriverV2BuildProcessObservation { try decode(processFields()) }
    private func processFields() -> [String: Any] {
        func stream(_ inode: UInt64) -> [String: Any] {
            ["reachedEOF": true, "overflowed": false, "workerFinished": true, "descriptorsClosed": true,
             "readErrorNumber": 0, "writeErrorNumber": 0, "finalizationErrorNumber": 0, "closeErrorNumber": 0,
             "outputMetadataObserved": true, "outputPermissionMode": 0o444, "outputDeviceID": 1, "outputInode": inode,
             "totalByteCount": 0, "capturedByteCount": 0, "outputByteCount": 0,
             "outputSHA256": PrimeSHA256.hexDigest(of: Data()), "terminalReason": "end_of_file"]
        }
        return ["logicalArgumentZero": "swift-test", "physicalArgumentZero": "/fixture/swift-test", "arguments": PrimeValidationDriverV2SwiftPMPhysicalArguments.testabilityPrefix + ["--skip-build"], "orderedEnvironment": [],
            "workingDirectoryAbsolutePath": "/fixture/repository", "workingDirectoryDeviceID": 1, "workingDirectoryInode": 10,
            "executableAbsolutePath": "/fixture/swift-package", "executableDeviceID": 1, "executableInode": 11,
            "executableByteCount": 1, "executableSHA256": PrimeSHA256.hexDigest(of: Data([1])),
            "mappedImageJoined": true, "exactSuspendedWorkingDirectoryJoin": true,
            "processIdentifier": 101, "sessionIdentifier": 99, "parentProcessIdentifier": 99, "processGroupIdentifier": 101,
            "appliedSpawnFlags": 16_526, "spawnReturnCode": 0,
            "deadlineStartedAtUptimeNanoseconds": 1000, "deadlineExpiresAtUptimeNanoseconds": UInt64(1_800_000_001_000),
            "spawnReturnedUptimeNanoseconds": 1100, "resumedAtUptimeNanoseconds": 1200,
            "deathObservedUptimeNanoseconds": 1300, "waitReturnedUptimeNanoseconds": 1400,
            "preReapProcessGroupMemberIdentifiers": [101], "requestedWaitProcessIdentifier": 101,
            "returnedWaitProcessIdentifier": 101, "exactReapCount": 1, "cleanupInitiated": false,
            "waitOptions": 0, "rawWaitStatus": 0, "exitStatus": 0, "terminationSignal": 0,
            "exitedNormally": true, "coreDumped": false, "processGroupEmptyAfterReap": true,
            "standardOutput": stream(201), "standardError": stream(202)]
    }
}
