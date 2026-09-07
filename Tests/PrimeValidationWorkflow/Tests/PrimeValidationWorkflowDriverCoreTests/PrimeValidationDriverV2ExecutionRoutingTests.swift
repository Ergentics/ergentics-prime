// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary
import Foundation
import PrimeCore
import PrimeValidationWorkflowContracts
@testable import PrimeValidationWorkflowDriverCore
import XCTest

/// Pure request/expectation tests. No process or live authority is constructed.
final class PrimeValidationDriverV2ExecutionRoutingTests: XCTestCase {
    private struct LegacyRequest: Encodable {
        let schemaVersion = 1
        let artifactKind = "ergentics_prime_validation_driver_v2_supervisor_launch_request_v1"
        let intent: PrimeValidationRunIntentV2
        let leaseDirectoryAbsolutePath: String
        let terminalGate: PrimeValidationDriverV2TerminalGate?
        enum CodingKeys: String, CodingKey {
            case schemaVersion = "schema_version"
            case artifactKind = "artifact_kind"
            case intent
            case leaseDirectoryAbsolutePath = "lease_directory_absolute_path"
            case terminalGate = "terminal_gate"
        }
    }

    func testHFieldsAreAbsentAndLegacyEFGRequestBytesStayIdentical() throws {
        let intent = try requestIntent()
        for gate in [PrimeValidationDriverV2TerminalGate.gateE, .gateF, .gateG] {
            let request = PrimeValidationDriverV2SupervisorLaunchRequestV1(intent: intent,
                leaseDirectoryAbsolutePath: "/private/tmp/h-routing-lease", terminalGate: gate)
            try request.validate()
            let bytes = try PrimeCanonicalJSON.encode(request)
            XCTAssertEqual(bytes, try PrimeCanonicalJSON.encode(LegacyRequest(intent: intent,
                leaseDirectoryAbsolutePath: "/private/tmp/h-routing-lease", terminalGate: gate == .gateE ? nil : gate)))
            let object = try XCTUnwrap(JSONSerialization.jsonObject(with: bytes) as? [String: Any])
            XCTAssertNil(object["execution_go_scope_data"])
            XCTAssertNil(object["accepted_capsule_sha256"])
        }
    }

    func testExplicitHRequestRoundTripsExactDeclaredScopeAndCapsuleIdentity() throws {
        let intent = try requestIntent()
        let scope = try scopeData(intent)
        let request = PrimeValidationDriverV2SupervisorLaunchRequestV1(intent: intent,
            leaseDirectoryAbsolutePath: "/private/tmp/h-routing-lease", terminalGate: .gateH,
            executionGoScopeData: scope, acceptedCapsuleSHA256: String(repeating: "c", count: 64))
        try request.validate()
        let data = try PrimeCanonicalJSON.encode(request)
        let decoded = try PrimeCanonicalJSON.decode(PrimeValidationDriverV2SupervisorLaunchRequestV1.self, from: data)
        try decoded.validate()
        XCTAssertEqual(decoded, request)
        XCTAssertEqual(decoded.executionGoScopeData, scope)
        // A request validates the SHA's shape; the outer boundary separately
        // joins it to the actual accepted capsule bytes.
        XCTAssertEqual(decoded.acceptedCapsuleSHA256, String(repeating: "c", count: 64))
    }

    func testHRequestRejectsMissingMalformedOrWrongIntentScopeAndUnknownGate() throws {
        let intent = try requestIntent()
        let scope = try scopeData(intent)
        func request(_ gate: PrimeValidationDriverV2TerminalGate = .gateH,
                     _ data: Data?, _ sha: String?) -> PrimeValidationDriverV2SupervisorLaunchRequestV1 {
            .init(intent: intent, leaseDirectoryAbsolutePath: "/private/tmp/h-routing-lease",
                  terminalGate: gate, executionGoScopeData: data, acceptedCapsuleSHA256: sha)
        }
        let sha = String(repeating: "c", count: 64)
        for bad in [request(.gateH, nil, sha), request(.gateH, scope, nil),
                    request(.gateH, scope, "wrong"), request(.gateH, scope + Data([10]), sha),
                    request(.gateE, scope, sha), request(.gateF, scope, sha), request(.gateG, scope, sha)] {
            XCTAssertThrowsError(try bad.validate())
        }
        let mutations: [(String, Any)] = [
            ("intentSHA256", String(repeating: "f", count: 64)),
            ("sourceTreeReplaySHA256", String(repeating: "a", count: 40)),
            ("candidateScope", "all-tests"), ("referenceMaximumActiveNanoseconds", 1)
        ]
        for (key, value) in mutations {
            var object = try XCTUnwrap(JSONSerialization.jsonObject(with: scope) as? [String: Any])
            object[key] = value
            let typed = try JSONDecoder().decode(PrimeValidationDriverV2DeclaredExecutionScopeV1.self,
                from: JSONSerialization.data(withJSONObject: object))
            XCTAssertThrowsError(try request(.gateH, PrimeCanonicalJSON.encode(typed), sha).validate())
        }
        let valid = try PrimeCanonicalJSON.encode(request(.gateH, scope, sha))
        let unknown = Data(String(decoding: valid, as: UTF8.self)
            .replacingOccurrences(of: "\"terminal_gate\":\"H\"", with: "\"terminal_gate\":\"X\"").utf8)
        XCTAssertNotEqual(unknown, valid)
        XCTAssertThrowsError(try PrimeCanonicalJSON.decode(PrimeValidationDriverV2SupervisorLaunchRequestV1.self, from: unknown))
    }

    private func scopeData(_ intent: PrimeValidationRunIntentV2) throws -> Data {
        try PrimeCanonicalJSON.encode(PrimeValidationDriverV2DeclaredExecutionScopeV1(
            intent: intent, sourceCommit: String(repeating: "a", count: 40),
            sourceTree: String(repeating: "b", count: 40), sourceTreeReplaySHA256: String(repeating: "d", count: 64),
            sourceIdentitySHA256: String(repeating: "e", count: 64),
            governorExecutable: .init(absolutePath: "/private/tmp/h-routing-governor", content: .init(data: Data("governor".utf8))),
            supervisorExecutable: intent.driverExecutable))
    }

    func testHOuterBudgetIsExactly5100AndDoesNotRelaxEarlierGates() throws {
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
        XCTAssertEqual(PrimeValidationDriverV2TerminalGate.gateHOuterDurationNanoseconds, 5_100_000_000_000)
        try check(.gateH, duration: 5_100_000_000_000, waitOffset: 1_260_000_000_001, expected: "leaf_order")
        try check(.gateH, duration: 1_260_000_000_000, waitOffset: 1, expected: "expectation_or_exit")
        try check(.gateG, duration: 5_100_000_000_000, waitOffset: 1, expected: "expectation_or_exit")
        try check(.gateE, duration: 5_100_000_000_000, waitOffset: 1, expected: "expectation_or_exit")
        try check(.gateH, duration: 5_100_000_000_000, waitOffset: 5_100_000_000_001, expected: "expectation_or_exit")
        try check(.gateH, duration: 5_100_000_000_000, waitOffset: 0, expected: "expectation_or_exit", started: UInt64.max)
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
            phaseBudgets: PrimeValidationExecutorAdmissionPolicyV2.frozenV1.phaseBudgets, environmentPolicy: .make(roots: roots, pinnedMetallib: metal),
            optionalSkipPolicySHA256: try PrimeValidationOptionalSkipPolicy.identitySHA256())
        try intent.validate()
        return intent
    }

}
