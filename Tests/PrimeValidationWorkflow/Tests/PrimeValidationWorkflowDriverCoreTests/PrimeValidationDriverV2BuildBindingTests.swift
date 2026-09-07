// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
import PrimeCore
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

    func testSupervisedSessionCannotBroadenInventoryChildReceipt() throws {
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
            XCTAssertThrowsError(try child(audit(session: 99, supervisor: 99)).validate(
                expectedInvocation: invocation, maximumActiveNanoseconds: 10
            )) { error in
                XCTAssertEqual(error as? PrimeValidationDriverV2Error, .invalidBinding("observed_child"))
            }
        }
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
        var fObject = try XCTUnwrap(JSONSerialization.jsonObject(with: fBytes) as? [String: Any])
        XCTAssertEqual(fObject["terminal_gate"] as? String, "F")
        XCTAssertEqual(try PrimeCanonicalJSON.decode(
            PrimeValidationDriverV2SupervisorLaunchRequestV1.self, from: fBytes), f)
        fObject["terminal_gate"] = "G"
        XCTAssertThrowsError(try PrimeCanonicalJSON.decode(
            PrimeValidationDriverV2SupervisorLaunchRequestV1.self,
            from: JSONSerialization.data(withJSONObject: fObject, options: [.sortedKeys, .withoutEscapingSlashes])))
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
    }

    private func requestIntent() throws -> PrimeValidationRunIntentV2 {
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
            content: .init(data: Data("metal".utf8)))
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
