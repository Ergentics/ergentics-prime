// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary
import Foundation
@_spi(PrimeValidationDriverV2RoleFacade) import PrimeCore
import PrimeValidationWorkflowContracts
@testable import PrimeValidationWorkflowDriverCore
import XCTest

/// Value mutations only. These fixtures neither own a native permit nor write
/// an evidence namespace; the parsed conclusion uses the actual strict adapter.
final class PrimeValidationDriverV2PublicationBindingTests: XCTestCase {
    private typealias Raw = PrimeValidationDriverV2BoundRawArtifact
    private typealias History = PrimeValidationDriverV2PublicationPhaseHistoryV1
    private typealias Prefix = PrimeValidationDriverV2PublicationPhasePrefixV1
    private typealias Manifest = PrimeValidationDriverV2EvidenceManifestV1
    private typealias Entry = PrimeValidationDriverV2EvidenceManifestEntryV1
    private typealias Envelope = PrimeValidationDriverV2OuterPublicationEnvelopeV1

    func testPhaseHistoryRequiresExactOrderedImmutablePrefixes() throws {
        let f = try fixture(), history = try history(f.intent)
        XCTAssertNoThrow(try history.validate(intent: f.intent, requireComplete: true))
        XCTAssertEqual(try PrimeCanonicalJSON.decode(History.self, from: PrimeCanonicalJSON.encode(history)), history)
        for count in 1...7 {
            let prefix = History(schemaVersion: 1, runID: history.runID, intentSHA256: history.intentSHA256,
                prefixes: Array(history.prefixes.prefix(count)), immutablePrefixBindings: Array(history.immutablePrefixBindings.prefix(count)))
            XCTAssertNoThrow(try prefix.validate(intent: f.intent, requireComplete: false))
            XCTAssertThrowsError(try prefix.validate(intent: f.intent, requireComplete: true))
        }
        for field in ["schemaVersion", "runID", "intentSHA256"] {
            let changed: History = try mutated(history) { $0[field] = field == "schemaVersion" ? 2 : "changed" }
            XCTAssertThrowsError(try changed.validate(intent: f.intent, requireComplete: true))
        }
        var bindings = history.immutablePrefixBindings
        bindings.swapAt(0, 1)
        XCTAssertThrowsError(try History(schemaVersion: 1, runID: history.runID, intentSHA256: history.intentSHA256,
            prefixes: history.prefixes, immutablePrefixBindings: bindings).validate(intent: f.intent, requireComplete: true))
    }

    func testPhasePrefixesRejectRewrittenPastFailureClockAndOrigin() throws {
        let f = try fixture(), h = try history(f.intent), p = h.prefixes[3], prior = h.prefixes[2]
        for key in ["previousPrefixSHA256", "sequence", "recordedAtUptimeNanoseconds"] {
            let changed: Prefix = try mutated(p) {
                if key == "previousPrefixSHA256" { $0[key] = String(repeating: "0", count: 64) }
                else { $0[key] = 0 }
            }
            XCTAssertThrowsError(try changed.validate(intent: f.intent, previous: prior))
        }
        for key in ["ordinal", "activeNanoseconds", "evidenceOrigin", "disposition", "terminal", "acceptedOutputBindings"] {
            let changed: Prefix = try mutated(p) { fields in
                var entries = fields["entries"] as! [[String: Any]]
                switch key {
                case "ordinal": entries[0][key] = -1
                case "activeNanoseconds": entries[0][key] = 0
                case "evidenceOrigin": entries[0][key] = "live_h_phase"
                case "disposition": entries[0][key] = "failed"
                case "terminal": entries[0].removeValue(forKey: key)
                default: entries[0][key] = []
                }
                fields["entries"] = entries
            }
            XCTAssertThrowsError(try changed.validate(intent: f.intent, previous: prior))
        }
        let failed: Prefix = try mutated(h.prefixes[0]) { fields in
            var entries = fields["entries"] as! [[String: Any]]; entries[0]["disposition"] = "failed"; fields["entries"] = entries
        }
        XCTAssertNoThrow(try failed.validate(intent: f.intent, previous: nil))
        XCTAssertThrowsError(try h.prefixes[1].validate(intent: f.intent, previous: failed))
        let unfinished: Prefix = try mutated(failed) { fields in
            var entries = fields["entries"] as! [[String: Any]]; entries[0]["disposition"] = "incomplete"
            entries[0].removeValue(forKey: "terminal"); fields["entries"] = entries
        }
        XCTAssertNoThrow(try unfinished.validate(intent: f.intent, previous: nil))
        XCTAssertThrowsError(try h.prefixes[1].validate(intent: f.intent, previous: unfinished))
    }

    func testManifestEnforcesParentsImmutableModesAndReceiptLastExclusions() throws {
        let f = try fixture(), h = try history(f.intent), inner = Data("{\"receipt\":1}".utf8), m = try manifest(f.intent, h, inner)
        XCTAssertNoThrow(try m.validate(intent: f.intent, history: h, innerFinalReceiptData: inner))
        XCTAssertEqual(m.finalNamespacePaths.count, m.entries.count + 2)
        for path in [Manifest.path, Manifest.envelopePath] {
            let changed = Manifest(schemaVersion: 1, runID: m.runID, intentSHA256: m.intentSHA256,
                phaseHistorySHA256: m.phaseHistorySHA256,
                entries: (m.entries + [Entry(relativePath: path, kind: "immutable_file", mode: 0o444, content: .init(data: inner))]).sorted { $0.relativePath < $1.relativePath })
            XCTAssertThrowsError(try changed.validate(intent: f.intent, history: h, innerFinalReceiptData: inner))
        }
        for index in m.entries.indices {
            let omitted = Manifest(schemaVersion: 1, runID: m.runID, intentSHA256: m.intentSHA256,
                phaseHistorySHA256: m.phaseHistorySHA256, entries: m.entries.enumerated().filter { $0.offset != index }.map(\.element))
            XCTAssertThrowsError(try omitted.validate(intent: f.intent, history: h, innerFinalReceiptData: inner))
        }
        for mode in [0o644, 0o755, 0o777] {
            XCTAssertThrowsError(try Entry(relativePath: "execution/raw", kind: "immutable_file", mode: UInt16(mode), content: .init(data: inner)).validate())
        }
        XCTAssertThrowsError(try m.validate(intent: f.intent, history: h, innerFinalReceiptData: inner + Data([10])))
    }

    func testManifestMustEqualActualNativeInventoryAndPlannedInnerBytes() throws {
        let f = try fixture(), h = try history(f.intent), inner = Data("{\"receipt\":1}".utf8), m = try manifest(f.intent, h, inner)
        let observed = try m.entries.filter { $0.relativePath != Manifest.finalReceiptPath }.map { entry -> PrimeValidationDriverV2PublicationNamespaceEntry in
            var fields: [String: Any] = ["relativePath": entry.relativePath, "kind": entry.kind, "mode": entry.mode]
            if let content = entry.content { fields["byteCount"] = content.byteCount; fields["sha256"] = content.sha256 }
            return try PrimeCanonicalJSON.decode(PrimeValidationDriverV2PublicationNamespaceEntry.self,
                from: JSONSerialization.data(withJSONObject: fields, options: [.sortedKeys, .withoutEscapingSlashes]))
        }
        let planned = binding(Manifest.finalReceiptPath, inner)
        XCTAssertNoThrow(try m.validateObservedInventory(observed, plannedInner: planned))
        XCTAssertThrowsError(try m.validateObservedInventory(Array(observed.dropLast()), plannedInner: planned))
        XCTAssertThrowsError(try m.validateObservedInventory(observed + [observed[0]], plannedInner: planned))
        XCTAssertThrowsError(try m.validateObservedInventory(observed, plannedInner: binding(Manifest.finalReceiptPath, Data())))
    }

    func testEnvelopeJoinsEveryIdentityToActualParsedConclusion() throws {
        let f = try fixture(), adapter = try f.adapter()
        let conclusion = try adapter.conclude(f.plan.shards.indices.map { try admit(adapter, makeInput(f, index: $0)) })
        let h = try history(f.intent), inner = try PrimeCanonicalJSON.encode(conclusion.finalReceipt), m = try manifest(f.intent, h, inner)
        let source = PrimeValidationDriverV2PublicationSourceV1(sourceCommit: String(repeating: "a", count: 40),
            sourceTree: String(repeating: "b", count: 40), sourceTreeReplaySHA256: String(repeating: "f", count: 64),
            sourceIdentitySHA256: String(repeating: "c", count: 64),
            sourceSnapshotSHA256: f.intent.sourceSnapshot.sha256, governorExecutable: f.intent.driverExecutable,
            supervisorExecutable: f.intent.driverExecutable, swiftPackageExecutable: f.intent.swiftExecutable)
        let live = String(repeating: "d", count: 64), capsule = String(repeating: "e", count: 64)
        let e = Envelope(schemaVersion: 1, artifactKind: "prime_driver_v2_outer_publication_envelope_v1",
            runID: f.intent.runID, intentSHA256: try f.intent.identitySHA256(), liveAdmissionIdentitySHA256: live,
            acceptedCapsuleSHA256: capsule, finalPhaseLedgerSHA256: try hash(h), preEnvelopeManifestSHA256: try hash(m),
            buildReceiptSHA256: try f.build.identitySHA256(against: f.intent),
            inventoryReceiptSHA256: try f.inventory.identitySHA256(intent: f.intent, buildReceipt: f.build),
            executionPlanSHA256: try f.plan.identitySHA256(intent: f.intent, buildReceipt: f.build, inventoryReceipt: f.inventory),
            referenceAggregateSHA256: try hash(conclusion.reference), candidateAggregateSHA256: try hash(conclusion.candidate),
            comparisonReceiptSHA256: try hash(conclusion.comparison), innerFinalReceiptSHA256: PrimeSHA256.hexDigest(of: inner),
            source: source, disposition: conclusion.finalReceipt.disposition, publicationSequence: 9,
            publicationStartedAtUptimeNanoseconds: 100, publicationDeadlineUptimeNanoseconds: 30_000_000_100)
        func validate(_ value: Envelope) throws {
            try value.validate(intent: f.intent, build: f.build, inventory: f.inventory, plan: f.plan,
                conclusion: conclusion, history: h, manifest: m, expectedLiveAdmissionIdentitySHA256: live,
                expectedAcceptedCapsuleSHA256: capsule, expectedSource: source)
        }
        XCTAssertNoThrow(try validate(e))
        XCTAssertNoThrow(try validate(PrimeCanonicalJSON.decode(Envelope.self, from: PrimeCanonicalJSON.encode(e))))
        let hashes = ["intentSHA256", "liveAdmissionIdentitySHA256", "acceptedCapsuleSHA256", "finalPhaseLedgerSHA256",
            "preEnvelopeManifestSHA256", "buildReceiptSHA256", "inventoryReceiptSHA256", "executionPlanSHA256",
            "referenceAggregateSHA256", "candidateAggregateSHA256", "comparisonReceiptSHA256", "innerFinalReceiptSHA256"]
        for key in hashes {
            let changed: Envelope = try mutated(e) { $0[key] = String(repeating: "0", count: 64) }
            XCTAssertThrowsError(try validate(changed), key)
        }
        for key in ["schemaVersion", "publicationSequence", "publicationStartedAtUptimeNanoseconds", "publicationDeadlineUptimeNanoseconds"] {
            let changed: Envelope = try mutated(e) { $0[key] = 0 }; XCTAssertThrowsError(try validate(changed), key)
        }
        let incomplete: Envelope = try mutated(e) { $0["disposition"] = "incomplete" }
        XCTAssertThrowsError(try validate(incomplete))
        let changedSource: Envelope = try mutated(e) { fields in
            var s = fields["source"] as! [String: Any]; s["sourceCommit"] = String(repeating: "f", count: 40); fields["source"] = s
        }
        XCTAssertThrowsError(try validate(changedSource))
        let changedReplay: Envelope = try mutated(e) { fields in
            var s = fields["source"] as! [String: Any]
            s["sourceTreeReplaySHA256"] = String(repeating: "0", count: 64); fields["source"] = s
        }
        XCTAssertThrowsError(try validate(changedReplay))
    }

    func testDeclaredScopeSeparatelyBindsTreePinAndObservedReplayBytes() throws {
        let f = try fixture()
        let source = PrimeValidationDriverV2PublicationSourceV1(sourceCommit: String(repeating: "a", count: 40),
            sourceTree: String(repeating: "b", count: 40),
            sourceTreeReplaySHA256: PrimeSHA256.hexDigest(of: Data("exact NUL-delimited ls-tree fixture\0".utf8)),
            sourceIdentitySHA256: String(repeating: "c", count: 64), sourceSnapshotSHA256: f.intent.sourceSnapshot.sha256,
            governorExecutable: f.intent.driverExecutable, supervisorExecutable: f.intent.driverExecutable,
            swiftPackageExecutable: f.intent.swiftExecutable)
        var scope: [String: Any] = ["schema": "prime_driver_v2_gate_h_declared_execution_scope_v1",
            "intentSHA256": try f.intent.identitySHA256(), "sourceCommit": source.sourceCommit,
            "sourceTree": source.sourceTree, "sourceTreeReplaySHA256": source.sourceTreeReplaySHA256,
            "sourceIdentitySHA256": source.sourceIdentitySHA256,
            "governorExecutable": try JSONSerialization.jsonObject(with: PrimeCanonicalJSON.encode(source.governorExecutable)),
            "supervisorExecutable": try JSONSerialization.jsonObject(with: PrimeCanonicalJSON.encode(source.supervisorExecutable)),
            "referenceScopes": ["parallel_xctest", "sequential_xctest", "swift_testing"],
            "candidateScope": "frozen_suite_contiguous_32_original_planner",
            "referenceMaximumActiveNanoseconds": UInt64(1_800_000_000_000),
            "candidateMaximumActiveNanoseconds": UInt64(1_800_000_000_000)]
        func encode(_ value: [String: Any]) throws -> Data {
            try JSONSerialization.data(withJSONObject: value, options: [.sortedKeys, .withoutEscapingSlashes])
        }
        XCTAssertNoThrow(try source.validateDeclaredScope(encode(scope), intent: f.intent))
        for replacement in [String(repeating: "0", count: 64), source.sourceTree, ""] {
            var changed = scope; changed["sourceTreeReplaySHA256"] = replacement
            XCTAssertThrowsError(try source.validateDeclaredScope(encode(changed), intent: f.intent))
        }
        var changedPin = scope; changedPin["sourceTree"] = String(repeating: "d", count: 40)
        XCTAssertThrowsError(try source.validateDeclaredScope(encode(changedPin), intent: f.intent))
        scope.removeValue(forKey: "sourceTreeReplaySHA256")
        XCTAssertThrowsError(try source.validateDeclaredScope(encode(scope), intent: f.intent))
        let malformed: PrimeValidationDriverV2PublicationSourceV1 = try mutated(source) { $0["sourceTreeReplaySHA256"] = "wrong" }
        XCTAssertThrowsError(try malformed.validate())
    }

    private func history(_ intent: PrimeValidationRunIntentV2) throws -> History {
        var prefixes: [Prefix] = [], bindings: [PrimeArtifactBinding] = []
        for (index, phase) in PrimeValidationDriverPhaseV2.allCases.prefix(8).enumerated() {
            let previous = bindings.last?.sha256 ?? String(repeating: "0", count: 64)
            let entry = PrimeValidationDriverV2PublicationPhaseEntryV1(phase: phase, ordinal: index,
                evidenceOrigin: index < 3 ? "retained_predecessor_projection" : "live_h_phase",
                predecessorPrefixSHA256: previous, disposition: .succeeded,
                start: binding("execution/phase-\(index)-start.json", Data("start\(index)".utf8)),
                terminal: binding("execution/phase-\(index)-terminal.json", Data("terminal\(index)".utf8)),
                acceptedOutputBindings: [binding("execution/phase-\(index)-result.json", Data("result\(index)".utf8))], activeNanoseconds: 1)
            let prefix = Prefix(schemaVersion: 1, runID: intent.runID, intentSHA256: try intent.identitySHA256(),
                sequence: UInt64(index + 1), previousPrefixSHA256: previous, recordedAtUptimeNanoseconds: UInt64(index + 1),
                entries: (prefixes.last?.entries ?? []) + [entry])
            prefixes.append(prefix); bindings.append(binding(String(format: "execution/phase-ledger-%02d.json", index + 1), try PrimeCanonicalJSON.encode(prefix)))
        }
        return .init(schemaVersion: 1, runID: intent.runID, intentSHA256: try intent.identitySHA256(), prefixes: prefixes, immutablePrefixBindings: bindings)
    }

    func testGovernorIncompleteObservationCannotInventFinalReceiptOrSuccessor() throws {
        typealias Incomplete = PrimeValidationDriverV2GovernorIncompleteObservationV1
        let start = binding("execution/shard/start.json", Data("start".utf8))
        let intent = String(repeating: "a", count: 64), capsule = String(repeating: "b", count: 64)
        let good = Incomplete(schemaVersion: 1, artifactKind: "prime_driver_v2_gate_h_governor_incomplete_observation_v1",
            runID: "run-incomplete", intentSHA256: intent, acceptedCapsuleSHA256: capsule, disposition: .incomplete,
            reason: .startedWithoutTerminal, immutablePrefixBindings: [], observedStartBindings: [start],
            observedTerminalBindings: [], supervisorExitCode: 68, observedAtUptimeNanoseconds: 100,
            successorAuthorized: false)
        func validate(_ value: Incomplete) throws {
            try value.validate(expectedRunID: "run-incomplete", expectedIntentSHA256: intent,
                expectedAcceptedCapsuleSHA256: capsule, actualPrefixBindings: [], actualStartBindings: [start],
                actualTerminalBindings: [], actualSupervisorExitCode: 68, actualObservedAtUptimeNanoseconds: 100,
                actualReason: .startedWithoutTerminal)
        }
        XCTAssertNoThrow(try validate(good))
        for key in ["successorAuthorized", "disposition", "reason", "supervisorExitCode", "observedAtUptimeNanoseconds"] {
            let changed: Incomplete = try mutated(good) { fields in
                switch key {
                case "successorAuthorized": fields[key] = true
                case "disposition": fields[key] = "complete_pass"
                case "reason": fields[key] = "failedTerminal"
                default: fields[key] = 0
                }
            }
            XCTAssertThrowsError(try validate(changed), key)
        }
        let fields = try XCTUnwrap(JSONSerialization.jsonObject(with: PrimeCanonicalJSON.encode(good)) as? [String: Any])
        XCTAssertNil(fields["innerFinalReceiptSHA256"])
        XCTAssertNil(fields["referenceAggregateSHA256"])
        XCTAssertNil(fields["candidateAggregateSHA256"])
    }
    private func manifest(_ intent: PrimeValidationRunIntentV2, _ history: History, _ inner: Data) throws -> Manifest {
        var bindings = history.immutablePrefixBindings + [binding(Manifest.historyPath, try PrimeCanonicalJSON.encode(history)), binding(Manifest.finalReceiptPath, inner)]
        for entry in history.prefixes.last!.entries { bindings += [entry.start, entry.terminal!] + entry.acceptedOutputBindings }
        var entries = [Entry(relativePath: "execution", kind: "directory", mode: 0o700, content: nil)]
        for b in bindings {
            struct Fields: Encodable { let byteCount: UInt64; let sha256: String }
            let content = try PrimeCanonicalJSON.decode(PrimeValidationContentBinding.self, from: PrimeCanonicalJSON.encode(Fields(byteCount: b.byteCount, sha256: b.sha256)))
            entries.append(.init(relativePath: b.relativePath, kind: "immutable_file", mode: 0o444, content: content))
        }
        return .init(schemaVersion: 1, runID: intent.runID, intentSHA256: try intent.identitySHA256(),
            phaseHistorySHA256: try hash(history), entries: entries.sorted { $0.relativePath < $1.relativePath })
    }
    private func binding(_ path: String, _ data: Data) -> PrimeArtifactBinding {
        .init(relativePath: path, sha256: PrimeSHA256.hexDigest(of: data), byteCount: UInt64(data.count), purpose: .immutableData)
    }
    private func hash<T: Encodable>(_ value: T) throws -> String { PrimeSHA256.hexDigest(of: try PrimeCanonicalJSON.encode(value)) }
    private func mutated<T: Codable>(_ value: T, _ change: (inout [String: Any]) -> Void) throws -> T {
        var fields = try XCTUnwrap(JSONSerialization.jsonObject(with: PrimeCanonicalJSON.encode(value)) as? [String: Any]); change(&fields)
        return try PrimeCanonicalJSON.decode(T.self, from: JSONSerialization.data(withJSONObject: fields, options: [.sortedKeys, .withoutEscapingSlashes]))
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
            baseline: .init(), phaseBudgets: PrimeValidationDriverPhaseV2.allCases.enumerated().map {
                .init(phase: $0.element, maximumActiveNanoseconds: UInt64([30, 900, 300, 30, 1800, 1800, 120, 60, 30][$0.offset]) * 1_000_000_000)
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
