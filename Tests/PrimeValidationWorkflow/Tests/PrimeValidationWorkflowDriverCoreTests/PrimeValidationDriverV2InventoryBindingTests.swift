// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
@_spi(PrimeValidationDriverV2RoleFacade) import PrimeCore
import PrimeValidationWorkflowContracts
@testable import PrimeValidationWorkflowDriverCore
import XCTest

/// Decoded value fixtures test the actual pure binder checks. No owner or child
/// process is created, and these values are never presented as native evidence.
final class PrimeValidationDriverV2InventoryBindingTests: XCTestCase {
    private typealias Envelope = PrimeValidationDriverV2InventoryDurableBindingEnvelopeV1

    func testHistoricalPhysicalArgumentZeroIsAbsentAndCannotAuthorizeNewNativeProcess() throws {
        let old = try process()
        XCTAssertNil(old.physicalArgumentZero)
        XCTAssertThrowsError(try old.validatePhysicalArgumentZero())
        let encoded = try PrimeCanonicalJSON.encode(old)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        XCTAssertNil(object["physicalArgumentZero"])
        XCTAssertEqual(try PrimeCanonicalJSON.encode(PrimeCanonicalJSON.decode(
            PrimeValidationDriverV2BuildProcessObservation.self, from: encoded)), encoded)
        // Exact old canonical prestart bytes remain valid for historical
        // decoding/re-encoding; absence is never inferred as a new argv[0].
        let historical = Data(#"{"arguments":[],"deadlineExpiresAtUptimeNanoseconds":2,"deadlineStartedAtUptimeNanoseconds":1,"executableAbsolutePath":"/fixture/swift-package","executableSHA256":"a","logicalArgumentZero":"swift-test","orderedEnvironment":[],"ordinal":1,"predecessorSHA256":"b","role":"list_xctest","runID":"r","schema":"s","workingDirectoryAbsolutePath":"/fixture"}"#.utf8)
        let prestart = try PrimeCanonicalJSON.decode(PrimeValidationDriverV2InventoryPrestartV1.self, from: historical)
        XCTAssertNil(prestart.physicalArgumentZero)
        XCTAssertEqual(try PrimeCanonicalJSON.encode(prestart), historical)
    }

    func testNativePhysicalArgumentZeroRequiresExactClosedAliasAndBindsTerminalBytes() throws {
        for logical in ["swift-build", "swift-test"] {
            var fields = processFields()
            fields["logicalArgumentZero"] = logical
            fields["physicalArgumentZero"] = "/fixture/" + logical
            let good = try decode(fields)
            try good.validatePhysicalArgumentZero()
            let canonical = try PrimeCanonicalJSON.encode(good)
            XCTAssertEqual(try PrimeCanonicalJSON.decode(PrimeValidationDriverV2BuildProcessObservation.self,
                from: canonical).physicalArgumentZero, "/fixture/" + logical)
            for alternate in [logical, "/fixture/swift-package", "/wrong/" + logical,
                              "/fixture/./" + logical, "/fixture/" + logical + "/",
                              "/fixture/" + (logical == "swift-build" ? "swift-test" : "swift-build"), ""] {
                var changed = fields; changed["physicalArgumentZero"] = alternate
                let invalid = try decode(changed)
                XCTAssertThrowsError(try invalid.validatePhysicalArgumentZero(), alternate)
                XCTAssertNotEqual(try PrimeCanonicalJSON.encode(invalid), canonical)
            }
            for missing in [NSNull() as Any] {
                var changed = fields; changed["physicalArgumentZero"] = missing
                XCTAssertThrowsError(try decode(changed).validatePhysicalArgumentZero())
            }
        }
    }

    func testPhysicalArgumentZeroIsPartOfNativePrestartBinding() throws {
        var fields: [String: Any] = ["schema": "prime_driver_v2_gate_g_inventory_prestart_v1",
            "runID": "r", "ordinal": 1, "role": "list_xctest", "predecessorSHA256": "b",
            "deadlineStartedAtUptimeNanoseconds": 1, "deadlineExpiresAtUptimeNanoseconds": 2,
            "executableAbsolutePath": "/fixture/swift-package", "executableSHA256": "a",
            "logicalArgumentZero": "swift-test", "physicalArgumentZero": "/fixture/swift-test",
            "arguments": [], "orderedEnvironment": [], "workingDirectoryAbsolutePath": "/fixture"]
        let value = try JSONDecoder().decode(PrimeValidationDriverV2InventoryPrestartV1.self,
            from: JSONSerialization.data(withJSONObject: fields))
        let bytes = try PrimeCanonicalJSON.encode(value)
        let binding = PrimeArtifactBinding(relativePath: "01-xctest-prestart.json",
            sha256: PrimeSHA256.hexDigest(of: bytes), byteCount: UInt64(bytes.count), purpose: .immutableData)
        try Envelope.validateJournalBinding(binding, path: binding.relativePath,
            type: PrimeValidationDriverV2InventoryPrestartV1.self, object: fields)
        fields["physicalArgumentZero"] = "swift-test"
        XCTAssertThrowsError(try Envelope.validateJournalBinding(binding, path: binding.relativePath,
            type: PrimeValidationDriverV2InventoryPrestartV1.self, object: fields))
        fields.removeValue(forKey: "physicalArgumentZero")
        XCTAssertThrowsError(try Envelope.validateJournalBinding(binding, path: binding.relativePath,
            type: PrimeValidationDriverV2InventoryPrestartV1.self, object: fields))
    }

    func testInventoryJournalBindingUsesNativeTypedEncoderBytes() throws {
        let fields: [String: Any] = [
            "schema": "prime_driver_v2_gate_g_inventory_child_terminal_v1",
            "role": "list_xctest", "startSHA256": String(repeating: "a", count: 64),
            "process": processFields(),
        ]
        let value = try JSONDecoder().decode(PrimeValidationDriverV2InventoryTerminalV1.self,
            from: JSONSerialization.data(withJSONObject: fields))
        let native = try PrimeCanonicalJSON.encode(value)
        let binding = PrimeArtifactBinding(relativePath: "01-xctest-terminal.json",
            sha256: PrimeSHA256.hexDigest(of: native), byteCount: UInt64(native.count), purpose: .immutableData)
        let alternate = try JSONSerialization.data(withJSONObject: fields,
            options: [.sortedKeys, .withoutEscapingSlashes])
        XCTAssertNotEqual(native, alternate)
        try Envelope.validateJournalBinding(binding, path: binding.relativePath,
            type: PrimeValidationDriverV2InventoryTerminalV1.self, object: fields)
        var mutation = fields
        var changedProcess = processFields(); changedProcess["exitStatus"] = 1
        mutation["process"] = changedProcess
        XCTAssertThrowsError(try Envelope.validateJournalBinding(binding, path: binding.relativePath,
            type: PrimeValidationDriverV2InventoryTerminalV1.self, object: mutation))
        XCTAssertThrowsError(try Envelope.validateJournalBinding(binding, path: "02-swift-testing-terminal.json",
            type: PrimeValidationDriverV2InventoryTerminalV1.self, object: fields))
    }

    func testInventoryNativeLifecycleRequiresExactSharedBudgetAndReap() throws {
        try Envelope.validateNativeProcess(process(), supervisorPID: 99)
        let mutations: [(String, Any)] = [
            ("processIdentifier", 99), ("sessionIdentifier", 101),
            ("parentProcessIdentifier", 98), ("processGroupIdentifier", 99),
            ("mappedImageJoined", false), ("exactSuspendedWorkingDirectoryJoin", false),
            ("appliedSpawnFlags", 0), ("spawnReturnCode", 1),
            ("deadlineStartedAtUptimeNanoseconds", 0),
            ("deadlineStartedAtUptimeNanoseconds", UInt64.max),
            ("deadlineExpiresAtUptimeNanoseconds", 999),
            ("deadlineExpiresAtUptimeNanoseconds", UInt64.max),
            ("spawnReturnedUptimeNanoseconds", 999),
            ("resumedAtUptimeNanoseconds", 1099),
            ("deathObservedUptimeNanoseconds", 1199),
            ("waitReturnedUptimeNanoseconds", 1299),
            ("waitReturnedUptimeNanoseconds", UInt64(300_000_001_000)),
            ("preReapProcessGroupMemberIdentifiers", [101, 102]),
            ("requestedWaitProcessIdentifier", 102), ("returnedWaitProcessIdentifier", 102),
            ("exactReapCount", 2), ("cleanupInitiated", true),
            ("waitOptions", 1), ("rawWaitStatus", 256),
            ("exitedNormally", false), ("exitStatus", 1),
            ("terminationSignal", 9), ("coreDumped", true),
            ("processGroupEmptyAfterReap", false),
        ]
        for (key, value) in mutations {
            var fields = processFields(); fields[key] = value
            XCTAssertThrowsError(try Envelope.validateNativeProcess(decode(fields), supervisorPID: 99), key)
        }
        XCTAssertThrowsError(try Envelope.validateNativeProcess(process(), supervisorPID: 0))
    }

    func testInventoryNativeStreamRejectsIncompleteOrAliasedAccounting() throws {
        let mutations: [(String, Any)] = [
            ("reachedEOF", false), ("overflowed", true), ("workerFinished", false),
            ("descriptorsClosed", false), ("readErrorNumber", 5), ("writeErrorNumber", 5),
            ("finalizationErrorNumber", 5), ("closeErrorNumber", 5),
            ("outputMetadataObserved", false), ("outputPermissionMode", 0o644),
            ("outputDeviceID", 0), ("outputInode", 0),
            ("capturedByteCount", 1), ("outputByteCount", 1),
            ("terminalReason", "cancelled"), ("outputSHA256", String(repeating: "z", count: 64)),
        ]
        for key in ["standardOutput", "standardError"] {
            for (field, value) in mutations {
                var fields = processFields(); var stream = try XCTUnwrap(fields[key] as? [String: Any])
                stream[field] = value; fields[key] = stream
                XCTAssertThrowsError(try Envelope.validateNativeProcess(decode(fields), supervisorPID: 99), key + ":" + field)
            }
            var fields = processFields(); var stream = try XCTUnwrap(fields[key] as? [String: Any])
            for field in ["totalByteCount", "capturedByteCount", "outputByteCount"] { stream[field] = 16 * 1024 * 1024 + 1 }
            fields[key] = stream
            XCTAssertThrowsError(try Envelope.validateNativeProcess(decode(fields), supervisorPID: 99))
        }
    }

    func testInventoryArtifactBindingRejectsPathCountHashAndPurposeDrift() throws {
        let data = Data("native-list\n".utf8), path = "xctest-list.stdout.log"
        let good = PrimeArtifactBinding(relativePath: path, sha256: PrimeSHA256.hexDigest(of: data),
            byteCount: UInt64(data.count), purpose: .immutableData)
        try Envelope.validateArtifact(good, path: path, data: data)
        for mutation in [
            PrimeArtifactBinding(relativePath: "swift-testing-list.stdout.log", sha256: good.sha256, byteCount: good.byteCount, purpose: .immutableData),
            PrimeArtifactBinding(relativePath: path, sha256: String(repeating: "0", count: 64), byteCount: good.byteCount, purpose: .immutableData),
            PrimeArtifactBinding(relativePath: path, sha256: good.sha256, byteCount: UInt64.max, purpose: .immutableData),
            PrimeArtifactBinding(relativePath: path, sha256: good.sha256, byteCount: good.byteCount, purpose: .executable),
        ] {
            XCTAssertThrowsError(try Envelope.validateArtifact(mutation, path: path, data: data))
        }
    }

    func testInventoryReceiptIntervalsRejectUnderflowAndDoNotDoubleCount() throws {
        let first = try process()
        let a = try Envelope.makeChild(invocation: invocation(.listXCTest), process: first,
            intervalStartedAt: 1000, matchedCount: 0, supervisorPID: 99)
        XCTAssertEqual(a.activeNanoseconds, 400)
        try a.validate(expectedInvocation: invocation(.listXCTest), maximumActiveNanoseconds: 300_000_000_000)
        try a.requireCompleteSuccess(expectedMatchedTestCount: 0)
        var fields = processFields(); fields["waitReturnedUptimeNanoseconds"] = 1800
        let b = try Envelope.makeChild(invocation: invocation(.listSwiftTesting), process: decode(fields),
            intervalStartedAt: first.waitReturnedUptimeNanoseconds, matchedCount: 0, supervisorPID: 99)
        XCTAssertEqual(b.activeNanoseconds, 400)
        XCTAssertEqual(a.activeNanoseconds + b.activeNanoseconds, 800)
        for invalid in [UInt64(999), UInt64(1400), UInt64.max] {
            XCTAssertThrowsError(try Envelope.makeChild(invocation: invocation(.listXCTest), process: first,
                intervalStartedAt: invalid, matchedCount: 0, supervisorPID: 99))
        }
    }

    func testSupervisedInventoryReceiptDoesNotAdmitShardRole() throws {
        let base = invocation(.listXCTest)
        let plan = try PrimeValidationShardPlanV2.make(
            key: .init(runID: base.runID, arm: .reference, lane: .sequentialXCTest, index: 0),
            selectionMode: .allInventory,
            testIDs: [.parse("PrimeCoreTests.ExampleTests/testOne", framework: .xctest)],
            filterPattern: "")
        let shard = PrimeValidationInvocationV2(runID: base.runID, role: .shard,
            shardKey: plan.key, shardID: plan.shardID, executable: base.executable,
            arguments: ["test", "--skip-build"], orderedEnvironment: base.orderedEnvironment,
            workingDirectoryAbsolutePath: base.workingDirectoryAbsolutePath,
            primaryResult: .standardOutput,
            standardOutputRelativePath: "shards/stdout.log",
            standardErrorRelativePath: "shards/stderr.log")
        try shard.validate()
        XCTAssertThrowsError(try Envelope.makeChild(invocation: shard, process: process(),
            intervalStartedAt: 1000, matchedCount: 0, supervisorPID: 99)) { error in
            XCTAssertEqual(error as? PrimeValidationDriverV2Error, .invalidInventoryReceipt)
        }
    }

    func testInventoryFrozenRawListAnchorsRemainExact() throws {
        let x = try Data(contentsOf: XCTUnwrap(Bundle.module.url(forResource: "xctest", withExtension: "list")))
        let s = try Data(contentsOf: XCTUnwrap(Bundle.module.url(forResource: "swift-testing", withExtension: "list")))
        let parsed = try PrimeValidationInventory.parse(xctestList: x, swiftTestingList: s)
        let baseline = PrimeValidationBaselineAnchorV2()
        XCTAssertEqual(parsed.xctestIDs.count, baseline.expectedXCTestCount)
        XCTAssertEqual(parsed.swiftTestingIDs.count, baseline.expectedSwiftTestingCount)
        XCTAssertEqual(PrimeSHA256.hexDigest(of: x), baseline.expectedXCTestListSHA256)
        XCTAssertEqual(PrimeSHA256.hexDigest(of: s), baseline.expectedSwiftTestingListSHA256)
        XCTAssertEqual(x.count, Int(baseline.expectedXCTestListByteCount))
        XCTAssertEqual(s.count, Int(baseline.expectedSwiftTestingListByteCount))
    }

    private func invocation(_ role: PrimeValidationInvocationRoleV2) -> PrimeValidationInvocationV2 {
        .init(runID: "run-g-value-fixture", role: role, shardKey: nil, shardID: "",
            executable: .init(absolutePath: "/fixture/swift", content: .init(data: Data([1]))),
            arguments: ["test", "list"], orderedEnvironment: [], workingDirectoryAbsolutePath: "/fixture/repository",
            primaryResult: .standardOutput, standardOutputRelativePath: "inventory/stdout.log",
            standardErrorRelativePath: "inventory/stderr.log")
    }

    private func process() throws -> PrimeValidationDriverV2BuildProcessObservation { try decode(processFields()) }
    private func decode(_ fields: [String: Any]) throws -> PrimeValidationDriverV2BuildProcessObservation {
        // JSONSerialization and JSONEncoder use different key collation.
        // These are value fixtures; establish canonical bytes with the same
        // encoder as production before exercising the actual binder checks.
        let value = try JSONDecoder().decode(PrimeValidationDriverV2BuildProcessObservation.self,
            from: JSONSerialization.data(withJSONObject: fields, options: [.sortedKeys, .withoutEscapingSlashes]))
        return try PrimeCanonicalJSON.decode(PrimeValidationDriverV2BuildProcessObservation.self,
            from: PrimeCanonicalJSON.encode(value))
    }
    private func processFields() -> [String: Any] {
        func stream(_ inode: UInt64) -> [String: Any] {
            ["reachedEOF": true, "overflowed": false, "workerFinished": true, "descriptorsClosed": true,
             "readErrorNumber": 0, "writeErrorNumber": 0, "finalizationErrorNumber": 0, "closeErrorNumber": 0,
             "outputMetadataObserved": true, "outputPermissionMode": 0o444, "outputDeviceID": 1, "outputInode": inode,
             "totalByteCount": 0, "capturedByteCount": 0, "outputByteCount": 0,
             "outputSHA256": PrimeSHA256.hexDigest(of: Data()), "terminalReason": "end_of_file"]
        }
        return ["logicalArgumentZero": "swift-test", "arguments": ["list"], "orderedEnvironment": [],
            "workingDirectoryAbsolutePath": "/fixture/repository", "workingDirectoryDeviceID": 1, "workingDirectoryInode": 10,
            "executableAbsolutePath": "/fixture/swift-package", "executableDeviceID": 1, "executableInode": 11,
            "executableByteCount": 1, "executableSHA256": PrimeSHA256.hexDigest(of: Data([1])),
            "mappedImageJoined": true, "exactSuspendedWorkingDirectoryJoin": true,
            "processIdentifier": 101, "sessionIdentifier": 99, "parentProcessIdentifier": 99, "processGroupIdentifier": 101,
            "appliedSpawnFlags": 16_526, "spawnReturnCode": 0,
            "deadlineStartedAtUptimeNanoseconds": 1000, "deadlineExpiresAtUptimeNanoseconds": UInt64(300_000_001_000),
            "spawnReturnedUptimeNanoseconds": 1100, "resumedAtUptimeNanoseconds": 1200,
            "deathObservedUptimeNanoseconds": 1300, "waitReturnedUptimeNanoseconds": 1400,
            "preReapProcessGroupMemberIdentifiers": [101], "requestedWaitProcessIdentifier": 101,
            "returnedWaitProcessIdentifier": 101, "exactReapCount": 1, "cleanupInitiated": false,
            "waitOptions": 0, "rawWaitStatus": 0, "exitStatus": 0, "terminationSignal": 0,
            "exitedNormally": true, "coreDumped": false, "processGroupEmptyAfterReap": true,
            "standardOutput": stream(201), "standardError": stream(202)]
    }
}
