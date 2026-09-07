// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
@_spi(PrimeValidationDriverV2RoleFacade) import PrimeCore
import PrimeValidationWorkflowContracts
@testable import PrimeValidationWorkflowDriverCore
import XCTest

final class PrimeValidationDriverV2BuildBindingTests: XCTestCase {
    func testLegacyProcessAuditKeepsCanonicalBytesAndIsolatedSession() throws {
        let legacy = Data(#"{"deadlineDisposition":"completed","exactReturnedProcessIdentifier":101,"matchedTestCount":0,"preReapProcessGroupMembers":[101],"processGroupEmptyAfterReap":true,"processGroupIdentifier":101,"processIdentifier":101,"rawWaitStatus":0,"sessionIdentifier":101,"sigkillDelivery":{"notAttempted":{}},"sigtermDelivery":{"notAttempted":{}},"standardError":{"capturedByteCount":0,"eofObserved":true,"overflowObserved":false,"readErrorNumber":0,"totalByteCount":0,"writeErrorNumber":0},"standardOutput":{"capturedByteCount":0,"eofObserved":true,"overflowObserved":false,"readErrorNumber":0,"totalByteCount":0,"writeErrorNumber":0},"waitTermination":{"exited":{"_0":0}}}"#.utf8)
        let decoded = try PrimeCanonicalJSON.decode(
            PrimeValidationProcessAuditV2.self, from: legacy
        )
        XCTAssertNil(decoded.supervisorSessionIdentifier)
        XCTAssertEqual(decoded, audit(session: 101))
        XCTAssertTrue(decoded.completeSafetyObserved)
        XCTAssertEqual(try PrimeCanonicalJSON.encode(decoded), legacy)
    }

    func testSupervisedProcessAuditRequiresExplicitMatchingSession() throws {
        let empty = PrimeValidationContentBinding(data: Data())
        let arbitrary = audit(session: 99)
        try arbitrary.validate(
            standardOutputContent: empty, standardErrorContent: empty
        )
        XCTAssertFalse(arbitrary.completeSafetyObserved)

        let supervised = audit(session: 99, supervisor: 99)
        try supervised.validate(
            standardOutputContent: empty, standardErrorContent: empty
        )
        XCTAssertTrue(supervised.completeSafetyObserved)
        let bytes = try PrimeCanonicalJSON.encode(supervised)
        XCTAssertEqual(
            try PrimeCanonicalJSON.decode(
                PrimeValidationProcessAuditV2.self, from: bytes
            ),
            supervised
        )
        XCTAssertFalse(
            audit(session: 99, supervisor: 99, group: 99)
                .completeSafetyObserved
        )
    }

    func testSupervisedProcessAuditRejectsInvalidOrSelfSession() throws {
        let empty = PrimeValidationContentBinding(data: Data())
        let invalidSessions: [(Int32, Int32)] = [
            (99, 0), (99, -1), (99, 98), (101, 101),
        ]
        for (session, supervisor) in invalidSessions {
            let value = audit(session: session, supervisor: supervisor)
            XCTAssertThrowsError(
                try value.validate(
                    standardOutputContent: empty,
                    standardErrorContent: empty
                )
            )
            XCTAssertFalse(value.completeSafetyObserved)
        }
    }

    func testSupervisedSessionAcceptsOnlyClosedBuildAndInventoryChildRoles() throws {
        let empty = PrimeValidationContentBinding(data: Data())
        for role in [PrimeValidationInvocationRoleV2.listXCTest, .listSwiftTesting] {
            let invocation = PrimeValidationInvocationV2(
                runID: "run-session-policy", role: role, shardKey: nil, shardID: "",
                executable: .init(absolutePath: "/fixture/swift", content: .init(data: Data([1]))),
                arguments: ["test", "list"], orderedEnvironment: [],
                workingDirectoryAbsolutePath: "/fixture/repository",
                primaryResult: .standardOutput,
                standardOutputRelativePath: "inventory/stdout.log",
                standardErrorRelativePath: "inventory/stderr.log"
            )
            func child(_ process: PrimeValidationProcessAuditV2)
                -> PrimeValidationObservedChildReceiptV2 {
                .init(invocation: invocation, primaryResult: .standardOutput,
                      standardOutputArtifact: .init(name: "standard_output",
                          relativePath: invocation.standardOutputRelativePath, content: empty),
                      standardErrorArtifact: .init(name: "standard_error",
                          relativePath: invocation.standardErrorRelativePath, content: empty),
                      process: process, activeNanoseconds: 1)
            }
            let isolated = child(audit(session: 101))
            try isolated.validate(expectedInvocation: invocation, maximumActiveNanoseconds: 10)
            try isolated.requireCompleteSuccess(expectedMatchedTestCount: 0)
            let supervised = child(audit(session: 99, supervisor: 99))
            try supervised.validate(expectedInvocation: invocation, maximumActiveNanoseconds: 10)
            try supervised.requireCompleteSuccess(expectedMatchedTestCount: 0)
            XCTAssertFalse(child(audit(session: 99)).process.completeSafetyObserved)
        }
        // Retain this existing test identifier. H extends the supervised
        // data-role set to shards; identity/session joins still reject drift.
        let testID = try PrimeValidationTestID.parse(
            "PrimeCoreTests.ExampleTests/testOne", framework: .xctest)
        func plan(_ index: Int) throws -> PrimeValidationShardPlanV2 {
            try .make(key: .init(runID: "run-session-policy", arm: .reference,
                lane: .sequentialXCTest, index: index), selectionMode: .allInventory,
                testIDs: [testID], filterPattern: "")
        }
        func shardInvocation(_ plan: PrimeValidationShardPlanV2,
                             arguments: [String] = ["test", "--skip-build"])
            -> PrimeValidationInvocationV2 {
            .init(runID: plan.key.runID, role: .shard, shardKey: plan.key, shardID: plan.shardID,
                executable: .init(absolutePath: "/fixture/swift", content: .init(data: Data([1]))),
                arguments: arguments, orderedEnvironment: [],
                workingDirectoryAbsolutePath: "/fixture/repository", primaryResult: .standardOutput,
                standardOutputRelativePath: "shards/stdout.log", standardErrorRelativePath: "shards/stderr.log")
        }
        let planned = try plan(0), invocation = shardInvocation(planned)
        try invocation.validate()
        func shardChild(_ process: PrimeValidationProcessAuditV2) -> PrimeValidationObservedChildReceiptV2 {
            .init(invocation: invocation, primaryResult: .standardOutput,
                standardOutputArtifact: .init(name: "standard_output",
                    relativePath: invocation.standardOutputRelativePath, content: empty),
                standardErrorArtifact: .init(name: "standard_error",
                    relativePath: invocation.standardErrorRelativePath, content: empty),
                process: process, activeNanoseconds: 1)
        }
        let supervised = shardChild(audit(session: 99, supervisor: 99))
        try supervised.validate(expectedInvocation: invocation, maximumActiveNanoseconds: 10)
        XCTAssertThrowsError(try shardChild(audit(session: 99, supervisor: 98))
            .validate(expectedInvocation: invocation, maximumActiveNanoseconds: 10)) { error in
            XCTAssertEqual(error as? PrimeValidationDriverV2Error, .invalidShardReceipt)
        }
        let wrongInvocation = shardInvocation(planned, arguments: ["test", "--filter", ".*"])
        let wrongPlan = shardInvocation(try plan(1))
        for changed in [wrongInvocation, wrongPlan] {
            try changed.validate()
            XCTAssertThrowsError(try supervised.validate(expectedInvocation: changed,
                maximumActiveNanoseconds: 10)) { error in
                XCTAssertEqual(error as? PrimeValidationDriverV2Error, .invalidBinding("observed_child"))
            }
        }
        // This verifies a recorded process/invocation projection only. It
        // neither parses selected test results nor authorizes completion.
    }

    func testSupervisorRequestPreservesLegacyEBytesAndRequiresExplicitF() throws {
        let intent = try requestIntent()
        let legacy = PrimeValidationDriverV2SupervisorLaunchRequestV1(
            intent: intent, leaseDirectoryAbsolutePath: "/private/tmp/prime-f-lease")
        let explicitE = PrimeValidationDriverV2SupervisorLaunchRequestV1(
            intent: intent, leaseDirectoryAbsolutePath: "/private/tmp/prime-f-lease",
            terminalGate: .gateE)
        let bytes = try PrimeCanonicalJSON.encode(legacy)
        XCTAssertEqual(bytes, try PrimeCanonicalJSON.encode(explicitE))
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: bytes) as? [String: Any])
        XCTAssertEqual(Set(object.keys), Set([
            "schema_version", "artifact_kind", "intent", "lease_directory_absolute_path"
        ]))
        XCTAssertEqual(try PrimeCanonicalJSON.decode(
            PrimeValidationDriverV2SupervisorLaunchRequestV1.self, from: bytes).terminalGate, .gateE)
        let f = PrimeValidationDriverV2SupervisorLaunchRequestV1(
            intent: intent, leaseDirectoryAbsolutePath: "/private/tmp/prime-f-lease",
            terminalGate: .gateF)
        try f.validate()
        let fBytes = try PrimeCanonicalJSON.encode(f)
        XCTAssertNotEqual(bytes, fBytes)
        let fObject = try XCTUnwrap(JSONSerialization.jsonObject(with: fBytes) as? [String: Any])
        XCTAssertEqual(fObject["terminal_gate"] as? String, "F")
        XCTAssertEqual(try PrimeCanonicalJSON.decode(
            PrimeValidationDriverV2SupervisorLaunchRequestV1.self, from: fBytes), f)
        let g = PrimeValidationDriverV2SupervisorLaunchRequestV1(
            intent: intent, leaseDirectoryAbsolutePath: "/private/tmp/prime-f-lease",
            terminalGate: .gateG)
        try g.validate()
        let gBytes = try PrimeCanonicalJSON.encode(g)
        let gObject = try XCTUnwrap(JSONSerialization.jsonObject(with: gBytes) as? [String: Any])
        XCTAssertEqual(gObject["terminal_gate"] as? String, "G")
        XCTAssertNotEqual(gBytes, bytes)
        XCTAssertNotEqual(gBytes, fBytes)
        XCTAssertEqual(try PrimeCanonicalJSON.decode(
            PrimeValidationDriverV2SupervisorLaunchRequestV1.self, from: gBytes), g)
        // H is now an explicitly admitted gate. Change only the enum token
        // in already-canonical F bytes; JSONSerialization key collation must
        // not be the reason this unknown-gate case is rejected.
        let unknown = Data(String(decoding: fBytes, as: UTF8.self)
            .replacingOccurrences(of: "\"terminal_gate\":\"F\"",
                                  with: "\"terminal_gate\":\"X\"").utf8)
        XCTAssertNotEqual(unknown, fBytes)
        XCTAssertEqual(unknown.count, fBytes.count)
        XCTAssertThrowsError(try JSONDecoder().decode(
            PrimeValidationDriverV2SupervisorLaunchRequestV1.self, from: unknown
        )) { error in
            guard case DecodingError.dataCorrupted(let context) = error else {
                return XCTFail("Expected unknown terminal_gate enum rejection, got \(error)")
            }
            XCTAssertEqual(context.codingPath.map(\.stringValue), ["terminal_gate"])
        }
        XCTAssertThrowsError(try PrimeCanonicalJSON.decode(
            PrimeValidationDriverV2SupervisorLaunchRequestV1.self, from: unknown))
    }

    func testDurableOuterBudgetRequiresExplicitFBeforeLeafValidation() throws {
        let intent = try requestIntent()
        let start: UInt64 = 1_000
        func check(_ gate: PrimeValidationDriverV2TerminalGate, duration: UInt64,
                   waitOffset: UInt64, expected: String,
                   started: UInt64 = 1_000) throws {
            let expectation = PrimeValidationDriverV2FixedProbeJournalReceiptExpectationV2(
                intent: intent, repositoryCommit: String(repeating: "a", count: 40),
                sourceIdentitySHA256: String(repeating: "b", count: 64),
                journalRoot: .init(absolutePath: intent.roots.workspaceRoot.absolutePath
                    + ".driver-v2-gate-e-journal", deviceID: 1, inode: 50, ownerUserID: 501, mode: 0o700),
                leaseRoot: .init(absolutePath: "/private/tmp/prime-f-lease", deviceID: 1,
                                 inode: 60, ownerUserID: 501, mode: 0o700),
                gitExecutable: .init(absolutePath: "/usr/bin/git", content: .init(data: Data([1]))),
                swiftFrontendExecutable: .init(
                    absolutePath: "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-frontend",
                    content: intent.swiftExecutable.content),
                supervisorExecutableVnode: .init(deviceID: 1, inode: 100),
                gitExecutableVnode: .init(deviceID: 1, inode: 101),
                swiftFrontendExecutableVnode: .init(deviceID: 1, inode: 102),
                supervisorProcessIdentifier: 99,
                outerDeadlineStartedAtUptimeNanoseconds: started,
                outerDeadlineExpiresAtUptimeNanoseconds: started.addingReportingOverflow(duration).partialValue,
                terminalGate: gate)
            let witness = PrimeValidationDriverV2FixedProbeSupervisorExitWitnessV2(
                requestedProcessIdentifier: 99, returnedProcessIdentifier: 99,
                waitOptions: 0, rawWaitStatus: 0,
                returnedAtUptimeNanoseconds: started.addingReportingOverflow(waitOffset).partialValue,
                exitedNormally: true, exitStatus: 0, terminationSignal: 0, coreDumped: false)
            XCTAssertThrowsError(try PrimeValidationDriverV2FixedProbeDurableJournalValidatorV2.validate(
                orderedLeaves: [], expectation: expectation, supervisorExit: witness
            )) { error in
                XCTAssertEqual(error as? PrimeValidationDriverV2Error,
                               .invalidBinding("fixed_probe_durable_journal_" + expected))
            }
        }
        XCTAssertEqual(start, 1_000)
        // leaf_order proves the actual preceding expectation guard accepted;
        // none of these cases claims a complete journal or native run.
        try check(.gateE, duration: 60_000_000_000, waitOffset: 1, expected: "leaf_order")
        try check(.gateF, duration: 960_000_000_000, waitOffset: 60_000_000_001, expected: "leaf_order")
        try check(.gateE, duration: 960_000_000_000, waitOffset: 1, expected: "expectation_or_exit")
        try check(.gateF, duration: 60_000_000_000, waitOffset: 1, expected: "expectation_or_exit")
        try check(.gateF, duration: 960_000_000_000, waitOffset: 960_000_000_001, expected: "expectation_or_exit")
        try check(.gateF, duration: 960_000_000_000, waitOffset: 0,
                  expected: "expectation_or_exit", started: UInt64.max)
        try check(.gateG, duration: 1_260_000_000_000, waitOffset: 960_000_000_001, expected: "leaf_order")
        try check(.gateF, duration: 1_260_000_000_000, waitOffset: 1, expected: "expectation_or_exit")
        try check(.gateG, duration: 960_000_000_000, waitOffset: 1, expected: "expectation_or_exit")
        try check(.gateG, duration: 1_260_000_000_000, waitOffset: 1_260_000_000_001, expected: "expectation_or_exit")
        try check(.gateG, duration: 1_260_000_000_000, waitOffset: 0,
                  expected: "expectation_or_exit", started: UInt64.max)
    }

    func testPinnedBundleBindingRequiresPreservedSourceAndExactFilePins() throws {
        let (pinned, artifacts) = pinnedBundleFixture()
        try checkPinnedBundle(pinned, artifacts)
        let decoded = try decodeFixture(PrimeValidationDriverV2PinnedBundleStagingObservation.self, pinned)
        XCTAssertEqual(try PrimeCanonicalJSON.decode(
            PrimeValidationDriverV2PinnedBundleStagingObservation.self,
            from: PrimeCanonicalJSON.encode(decoded)), decoded)
        XCTAssertThrowsError(try checkPinnedBundle(pinned, artifacts, preservedIntent: false))
        let mutations: [([String], Any)] = [
            (["input", "files", "0", "relativePath"], "other/Contents/Info.plist"),
            (["input", "files", "1", "sha256"], String(repeating: "f", count: 64)),
            (["input", "files", "0", "byteCount"], 1_130),
            (["input", "files", "0", "sha256"], PrimePinnedMLXMetallib.expectedXcodeDonorInfoPlistSHA256),
            (["destinations", "0", "relativePath"], "../mlx-swift_Cmlx.bundle/Contents/Info.plist"),
            (["destinations", "0", "sha256"], String(repeating: "a", count: 64)),
            (["destinations", "1", "byteCount"], 3_817_917),
            (["destinations", "2", "sha256"], PrimePinnedMLXMetallib.expectedXcodeDonorInfoPlistSHA256),
            (["destinations", "3", "sha256"], String(repeating: "f", count: 64)),
        ]
        for (path, replacement) in mutations {
            XCTAssertThrowsError(try checkPinnedBundle(replacing(pinned, path, replacement), artifacts), path.joined(separator: "."))
        }
        let inputs = try XCTUnwrap((pinned["input"] as? [String: Any])?["files"] as? [[String: Any]])
        let destinations = try XCTUnwrap(pinned["destinations"] as? [[String: Any]])
        for files in [Array(inputs.reversed()), Array(inputs.dropLast()), inputs + [inputs[0]]] {
            XCTAssertThrowsError(try checkPinnedBundle(replacing(pinned, ["input", "files"], files), artifacts))
        }
        for files in [Array(destinations.reversed()), Array(destinations.dropLast()), destinations + [destinations[0]]] {
            XCTAssertThrowsError(try checkPinnedBundle(replacing(pinned, ["destinations"], files), artifacts))
        }
    }

    func testPinnedBundleBindingRejectsAliasedOrUnsafeMetadata() throws {
        let (pinned, artifacts) = pinnedBundleFixture()
        let mutations: [([String], Any)] = [
            (["destinations", "0", "metadata", "inode"], 100),
            (["destinations", "1", "metadata", "inode"], 200),
            (["input", "files", "1", "metadata", "deviceID"], 2),
            (["destinations", "0", "metadata", "deviceID"], 2),
            (["input", "files", "0", "metadata", "ownerUserID"], 502),
            (["input", "files", "0", "metadata", "mode"], 0o100755),
            (["destinations", "0", "metadata", "mode"], 0o100644),
            (["input", "files", "0", "metadata", "linkCount"], 2),
            (["input", "files", "0", "metadata", "flags"], 32),
            (["input", "files", "0", "metadata", "byteCount"], -1),
            (["input", "files", "0", "metadata", "byteCount"], Int64.max),
            (["input", "files", "0", "metadata", "specialDeviceID"], 1),
            (["input", "files", "0", "metadata", "modificationNanoseconds"], 1_000_000_000),
        ]
        for (path, replacement) in mutations {
            XCTAssertThrowsError(try checkPinnedBundle(replacing(pinned, path, replacement), artifacts), path.joined(separator: "."))
        }
    }

    func testPinnedBundleBindingRequiresReapStagingCaptureOrder() throws {
        let (pinned, artifacts) = pinnedBundleFixture()
        for (key, value) in [
            ("stagingStartedAtUptimeNanoseconds", UInt64(9)),
            ("stagingCompletedAtUptimeNanoseconds", UInt64(20)),
            ("stagingCompletedAtUptimeNanoseconds", UInt64(31)),
            ("stagingStartedAtUptimeNanoseconds", UInt64.max),
            ("stagingCompletedAtUptimeNanoseconds", UInt64.max),
        ] {
            XCTAssertThrowsError(try checkPinnedBundle(replacing(pinned, [key], value), artifacts))
        }
        for key in ["exclusivePublicationObserved", "durableSynchronizationObserved"] {
            XCTAssertThrowsError(try checkPinnedBundle(replacing(pinned, [key], false), artifacts))
        }
        XCTAssertThrowsError(try checkPinnedBundle(pinned, artifacts, wait: 0))
        XCTAssertThrowsError(try checkPinnedBundle(pinned, artifacts, deadline: 30))
        XCTAssertThrowsError(try checkPinnedBundle(pinned,
            replacing(artifacts, ["captureStartedAtUptimeNanoseconds"], 24)))
    }

    func testPinnedBundleBindingJoinsBothResourceFilesToArtifactCapture() throws {
        let (pinned, artifacts) = pinnedBundleFixture()
        let mutations: [([String], Any)] = [
            (["metallibRelativePath"], "other/default.metallib"),
            (["metallibByteCount"], 3_817_917),
            (["metallibSHA256"], String(repeating: "f", count: 64)),
            (["bundleEntries", "0", "sha256"], PrimePinnedMLXMetallib.expectedXcodeDonorInfoPlistSHA256),
            (["bundleEntries", "1", "kind"], "executable"),
            (["bundleEntries", "1", "byteCount"], 1),
            (["capturedArtifactMetadata", "default.metallib", "inode"], 100),
        ]
        for (path, replacement) in mutations {
            XCTAssertThrowsError(try checkPinnedBundle(pinned, replacing(artifacts, path, replacement)), path.joined(separator: "."))
        }
        let entries = try XCTUnwrap(artifacts["bundleEntries"] as? [[String: Any]])
        XCTAssertThrowsError(try checkPinnedBundle(pinned, replacing(artifacts, ["bundleEntries"], Array(entries.dropFirst()))))
        // Every protected field must rejoin across the staging and artifact
        // observations, including the Info.plist inside the XCTest bundle.
        let metadata = try XCTUnwrap(artifacts["metallibMetadata"] as? [String: Any])
        for field in metadata.keys.sorted() {
            let previous = try XCTUnwrap(metadata[field] as? NSNumber).int64Value
            XCTAssertThrowsError(try checkPinnedBundle(pinned,
                replacing(artifacts, ["metallibMetadata", field], previous + 1)), field)
            let entryMetadata = try XCTUnwrap(entries[0]["sourceMetadata"] as? [String: Any])
            let prior = try XCTUnwrap(entryMetadata[field] as? NSNumber).int64Value
            XCTAssertThrowsError(try checkPinnedBundle(pinned,
                replacing(artifacts, ["bundleEntries", "0", "sourceMetadata", field], prior + 1)), field)
        }
    }

    private func checkPinnedBundle(
        _ pinned: [String: Any], _ artifacts: [String: Any],
        wait: UInt64 = 10, deadline: UInt64 = 40, preservedIntent: Bool = true
    ) throws {
        try PrimeValidationDriverV2BuildDurableBindingEnvelopeV1.validatePinnedBundle(
            decodeFixture(PrimeValidationDriverV2PinnedBundleStagingObservation.self, pinned),
            intent: requestIntent(preservedBundle: preservedIntent), childWaitUptimeNanoseconds: wait,
            artifacts: decodeFixture(PrimeValidationDriverV2BuildArtifactsObservation.self, artifacts),
            deadlineExpiresAtUptimeNanoseconds: deadline)
    }

    private func decodeFixture<T: Codable>(_ type: T.Type, _ object: [String: Any]) throws -> T {
        // Build synthetic transport with the production encoder's canonical
        // ordering; JSONSerialization uses a different sorted-key order.
        let value = try JSONDecoder().decode(type, from: JSONSerialization.data(
            withJSONObject: object, options: [.withoutEscapingSlashes]))
        return try PrimeCanonicalJSON.decode(type, from: PrimeCanonicalJSON.encode(value))
    }

    private func replacing(_ object: [String: Any], _ path: [String], _ value: Any) throws -> [String: Any] {
        func replace(_ object: Any, _ path: ArraySlice<String>) throws -> Any {
            guard let head = path.first else { return value }
            if var dictionary = object as? [String: Any] {
                dictionary[head] = try replace(XCTUnwrap(dictionary[head]), path.dropFirst())
                return dictionary
            }
            var array = try XCTUnwrap(object as? [Any])
            let index = try XCTUnwrap(Int(head))
            guard array.indices.contains(index) else { throw PrimeValidationDriverV2Error.invalidBuildReceipt }
            array[index] = try replace(array[index], path.dropFirst())
            return array
        }
        return try XCTUnwrap(replace(object, path[...]) as? [String: Any])
    }

    private func pinnedBundleFixture() -> ([String: Any], [String: Any]) {
        func metadata(_ inode: Int, _ count: UInt64, _ mode: Int = 0o100444) -> [String: Any] {
            ["deviceID": 1, "inode": inode, "mode": mode, "ownerUserID": 501,
             "ownerGroupID": 20, "linkCount": 1, "specialDeviceID": 0, "byteCount": count,
             "allocatedBlocks": 8, "blockSize": 4096, "flags": 0, "generation": 0,
             "modificationSeconds": 1, "modificationNanoseconds": 2,
             "statusChangeSeconds": 3, "statusChangeNanoseconds": 4,
             "birthSeconds": 5, "birthNanoseconds": 6]
        }
        let source = "artifacts/optimizer-restore-gate-865073a-20260729T183341Z/"
        let release = "root-release-build/arm64-apple-macosx/release/"
        let test = release + "ErgenticsPrimePackageTests.xctest/"
        let plist = PrimePinnedMLXMetallib.infoPlistSourceRelativePath
        let metal = PrimePinnedMLXMetallib.sourceBundleRelativePath
        func file(_ path: String, _ inode: Int, source: Bool = false) -> [String: Any] {
            let isMetal = path.hasSuffix("default.metallib")
            let count = isMetal ? PrimePinnedMLXMetallib.expectedByteCount : PrimePinnedMLXMetallib.expectedInfoPlistByteCount
            return ["relativePath": path, "byteCount": count,
                    "sha256": isMetal ? PrimePinnedMLXMetallib.expectedSHA256 : PrimePinnedMLXMetallib.expectedInfoPlistSHA256,
                    "metadata": metadata(inode, count, source ? 0o100644 : 0o100444)]
        }
        let destinations = [test + "Contents/Resources/" + plist, test + "Contents/Resources/" + metal,
                            release + plist, release + metal].enumerated().map { file($0.element, 200 + $0.offset) }
        let pinned: [String: Any] = [
            "input": ["files": [file(source + plist, 100, source: true), file(source + metal, 101, source: true)]],
            "destinations": destinations, "stagingStartedAtUptimeNanoseconds": 20,
            "stagingCompletedAtUptimeNanoseconds": 25,
            "exclusivePublicationObserved": true, "durableSynchronizationObserved": true,
        ]
        let entries: [[String: Any]] = destinations.prefix(2).map { value in
            ["relativePath": String((value["relativePath"] as! String).dropFirst(test.count)),
             "kind": "regular_file", "mode": 0o444, "byteCount": value["byteCount"]!,
             "sha256": value["sha256"]!, "sourceMetadata": value["metadata"]!]
        }
        let artifacts: [String: Any] = [
            "testBundleRelativePath": String(test.dropLast()), "testBundleMetadata": metadata(300, 1, 0o40700),
            "capturedBundleRelativePath": "test-bundle", "bundleEntries": entries,
            "metallibRelativePath": release + metal, "metallibByteCount": PrimePinnedMLXMetallib.expectedByteCount,
            "metallibSHA256": PrimePinnedMLXMetallib.expectedSHA256, "metallibMetadata": destinations[3]["metadata"]!,
            "capturedMetallib": ["relativePath": "default.metallib", "byteCount": PrimePinnedMLXMetallib.expectedByteCount,
                "sha256": PrimePinnedMLXMetallib.expectedSHA256, "purpose": "immutable_data"],
            "artifactRootIdentity": ["deviceID": 1, "inode": 400, "ownerUserID": 501, "ownerGroupID": 20,
                "actualMode": 0o700, "linkCount": 1, "modificationSeconds": 1, "modificationNanoseconds": 2,
                "statusChangeSeconds": 3, "statusChangeNanoseconds": 4],
            "immutableArtifactBindings": [], "capturedArtifactMetadata": ["default.metallib": metadata(401, PrimePinnedMLXMetallib.expectedByteCount)],
            "captureStartedAtUptimeNanoseconds": 30, "captureCompletedAtUptimeNanoseconds": 35,
            "exclusivePublicationObserved": true, "durableSynchronizationObserved": true,
            "sourceNamesAndDescriptorsRejoined": true,
        ]
        return (pinned, artifacts)
    }

    private func requestIntent(preservedBundle: Bool = false) throws -> PrimeValidationRunIntentV2 {
        func directory(_ leaf: String, _ inode: UInt64, _ mode: UInt16)
            -> PrimeValidationDirectoryBindingV2 {
            .init(absolutePath: "/private/tmp/prime-f-" + leaf,
                  deviceID: 1, inode: inode, ownerUserID: 501, mode: mode)
        }
        let roots = PrimeValidationDriverRootLayoutV2(
            repositoryRoot: directory("repository", 10, 0o755),
            companionRoot: directory("companion", 20, 0o755),
            workspaceRoot: directory("workspace", 30, 0o700),
            evidenceRoot: directory("evidence", 40, 0o700),
            scratchRelativePath: "root-release-build", cacheRelativePath: "cache",
            configRelativePath: "config", securityRelativePath: "security",
            clangModuleCacheRelativePath: "clang-module-cache", homeRelativePath: "home",
            swiftPMModuleCacheRelativePath: "swiftpm-module-cache",
            temporaryRelativePath: "temporary", outputRelativePath: "output")
        let metal = PrimeValidationRequiredMetallibV2(
            relativePath: "root-release-build/arm64-apple-macosx/release/mlx-swift_Cmlx.bundle/Contents/Resources/default.metallib",
            content: preservedBundle ? try decodeFixture(PrimeValidationContentBinding.self, [
                "byteCount": PrimePinnedMLXMetallib.expectedByteCount,
                "sha256": PrimePinnedMLXMetallib.expectedSHA256,
            ]) : .init(data: Data("metal".utf8)))
        let intent = PrimeValidationRunIntentV2(
            runID: "run-f-request", roots: roots,
            sourceSnapshot: .init(data: Data("source".utf8)),
            packageLock: .init(data: Data("lock".utf8)),
            driverExecutable: .init(absolutePath: "/private/tmp/prime-f-driver",
                                    content: .init(data: Data("driver".utf8))),
            swiftExecutable: .init(
                absolutePath: "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift",
                content: .init(data: Data("swift".utf8))),
            companionCommit: PrimeValidationRunIntentV2.requiredCompanionCommit,
            requiredPinnedMetallib: metal, baseline: .init(),
            phaseBudgets: PrimeValidationDriverPhaseV2.allCases.map {
                .init(phase: $0, maximumActiveNanoseconds: 900_000_000_000)
            }, environmentPolicy: .make(roots: roots, pinnedMetallib: metal),
            optionalSkipPolicySHA256: try PrimeValidationOptionalSkipPolicy.identitySHA256())
        try intent.validate()
        return intent
    }

    private func audit(
        session: Int32,
        supervisor: Int32? = nil,
        group: Int32 = 101
    ) -> PrimeValidationProcessAuditV2 {
        let stream = PrimeValidationStreamAuditV2(
            eofObserved: true, totalByteCount: 0, capturedByteCount: 0,
            overflowObserved: false, readErrorNumber: 0, writeErrorNumber: 0
        )
        return .init(
            processIdentifier: 101, sessionIdentifier: session,
            processGroupIdentifier: group, deadlineDisposition: .completed,
            sigtermDelivery: .notAttempted, sigkillDelivery: .notAttempted,
            preReapProcessGroupMembers: [101], exactReturnedProcessIdentifier: 101,
            rawWaitStatus: 0, waitTermination: .exited(0),
            processGroupEmptyAfterReap: true, standardOutput: stream,
            standardError: stream, matchedTestCount: 0,
            supervisorSessionIdentifier: supervisor
        )
    }
}
