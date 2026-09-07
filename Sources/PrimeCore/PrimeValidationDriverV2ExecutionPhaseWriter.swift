// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary
import Darwin
import Dispatch
import Foundation

/// Native writer of the additive history. The first three entries explicitly
/// project retained predecessor evidence at H entry; their new prefix files
/// never purport to have existed during E/F/G. No public constructor exists.
final class PrimeValidationDriverV2ExecutionPhaseWriter {
    private struct Entry: Codable, Equatable {
        let phase: String
        let ordinal: Int
        let evidenceOrigin: String
        let predecessorPrefixSHA256: String
        let disposition = "succeeded"
        let start: PrimeArtifactBinding
        let terminal: PrimeArtifactBinding
        let acceptedOutputBindings: [PrimeArtifactBinding]
        let activeNanoseconds: UInt64
    }
    private struct Prefix: Codable, Equatable {
        let schemaVersion = 1
        let runID: String
        let intentSHA256: String
        let sequence: UInt64
        let previousPrefixSHA256: String
        let recordedAtUptimeNanoseconds: UInt64
        let entries: [Entry]
    }
    private struct History: Encodable {
        let schemaVersion = 1
        let runID: String
        let intentSHA256: String
        let prefixes: [Prefix]
        let immutablePrefixBindings: [PrimeArtifactBinding]
    }
    private static let phases = ["source_admission", "build", "inventory", "execution_plan",
        "reference_execution", "candidate_execution", "reconciliation", "comparison"]
    private static let limits: [UInt64] = [30, 900, 300, 30, 1800, 1800, 120, 60].map { $0 * 1_000_000_000 }
    private let staging: PrimeValidationDriverV2ExecutionStaging
    private let state: PrimeValidationDriverV2InventoryExecutionState
    private let inventory: PrimeValidationDriverV2InventoryStaging
    private let plan: PrimeValidationDriverV2ExecutionPlanObservation
    private var prefixes: [Prefix] = []
    private(set) var orderedPrefixBindings: [PrimeArtifactBinding] = []
    private var observedBindings: [(PrimeArtifactRoot, PrimeArtifactBinding)] = []
    private var eRoot: PrimeArtifactRoot?
    private var eFiles: [HeldPredecessorFile] = []
    private var active: (ordinal: Int, start: PrimeArtifactBinding, deadline: PrimeSecureChildPhaseDeadline)?
    private var poisoned = false

    init(staging: PrimeValidationDriverV2ExecutionStaging, state: PrimeValidationDriverV2InventoryExecutionState,
         inventory: PrimeValidationDriverV2InventoryStaging, planObservation: PrimeValidationDriverV2ExecutionPlanObservation) throws {
        self.staging = staging; self.state = state; self.inventory = inventory; plan = planObservation
        let intent = try HJSON.object(plan.canonicalIntentData)
        guard let budgets = intent["phaseBudgets"] as? [[String: Any]],
              budgets.count == 9 else { throw hRejected("phase_budgets") }
        for (index, phase) in Self.phases.enumerated() {
            let matches = budgets.filter { $0["phase"] as? String == phase }
            guard matches.count == 1, let value = matches[0]["maximumActiveNanoseconds"],
                  try HJSON.encode([value]) == HJSON.encode([Self.limits[index]]) else { throw hRejected("phase_budget_" + phase) }
        }
    }

    var historyData: Data {
        get throws {
            guard !poisoned, active == nil, prefixes.count == 8 else { throw hRejected("phase_history_incomplete") }
            try revalidate()
            for file in eFiles { _ = try file.read() }
            try revalidate()
            return try PrimeCanonicalJSON.encode(History(runID: state.context.evidenceRunID,
                intentSHA256: PrimeSHA256.hexDigest(of: plan.canonicalIntentData), prefixes: prefixes,
                immutablePrefixBindings: orderedPrefixBindings))
        }
    }

    func capturePredecessors() throws {
        try operation {
            guard self.prefixes.isEmpty, let e = self.state.executionPredecessorObservation else { throw hRejected("phase_E_missing") }
            try self.planningTime()
            let root = try PrimeArtifactRoot(directoryURL: URL(fileURLWithPath:
                self.state.context.workspaceRootAbsolutePath + ".driver-v2-gate-e-journal"))
            try root.requirePrivateRootMode()
            let fd = try root.duplicateTrustedRootDescriptorForInventory(); defer { close(fd) }
            let expectedLeaves = [e.prestartLeaf] + e.orderedProcesses.flatMap { [$0.startLeaf, $0.terminalLeaf] } + [e.rawTerminalLeaf]
            guard e.orderedProcesses.count == 16, expectedLeaves.count == 34,
                  Set(expectedLeaves.map(\.leaf)).count == 34,
                  try PrimeValidationDriverV2ExecutionStaging.entries(fd) == Set(expectedLeaves.map(\.leaf)) else { throw hRejected("phase_E_exact_prefix") }
            let first = try HeldPredecessorFile(parent: fd, expected: e.prestartLeaf),
                last = try HeldPredecessorFile(parent: fd, expected: e.rawTerminalLeaf)
            let firstData = try first.read(), lastData = try last.read()
            guard firstData.last == 0x0a, lastData.last == 0x0a else { throw hRejected("phase_E_frame") }
            let record = try HJSON.object(Data(firstData.dropLast()))
            _ = try HJSON.object(Data(lastData.dropLast()))
            guard let identity = record["journalIdentity"] as? [String: Any] else { throw hRejected("phase_E_root_record") }
            let observed = try root.verifiedRootIdentity()
            try Self.validateCompletedEJournalRoot(identity: identity, observed: observed,
                absolutePath: root.directoryURL.path)
            self.eRoot = root; self.eFiles = [first]
            for expected in expectedLeaves.dropFirst().dropLast() {
                try self.planningTime()
                let held = try HeldPredecessorFile(parent: fd, expected: expected)
                _ = try held.read(); self.eFiles.append(held)
            }
            self.eFiles.append(last)
            let start = try self.staging.publishPredecessorEFrame(firstData, path: "predecessor-e-start.json")
            let terminal = try self.staging.publishPredecessorEFrame(lastData, path: "predecessor-e-terminal.json")
            let projection = try self.staging.publishData(HJSON.encode([
                "schema": "prime_driver_v2_gate_h_predecessor_e_readback_v1",
                "readbackAtUptimeNanoseconds": DispatchTime.now().uptimeNanoseconds,
                "originalPrestartLeaf": ["relativePath": e.prestartLeaf.leaf, "byteCount": e.prestartLeaf.byteCount,
                    "sha256": e.prestartLeaf.sha256, "deviceID": e.prestartLeaf.deviceID, "inode": e.prestartLeaf.inode],
                "originalTerminalLeaf": ["relativePath": e.rawTerminalLeaf.leaf, "byteCount": e.rawTerminalLeaf.byteCount,
                    "sha256": e.rawTerminalLeaf.sha256, "deviceID": e.rawTerminalLeaf.deviceID, "inode": e.rawTerminalLeaf.inode],
                "observedDeadlineStartedAtUptimeNanoseconds": e.deadlineStartedAtUptimeNanoseconds,
                "observedExecutorTerminalUptimeNanoseconds": e.executorTerminalUptimeNanoseconds
            ]), path: "predecessor-e-readback.json")
            try self.append(ordinal: 0, start: self.scope(start, "execution"), terminal: self.scope(terminal, "execution"),
                outputs: [self.scope(projection, "execution")], started: e.deadlineStartedAtUptimeNanoseconds,
                ended: e.executorTerminalUptimeNanoseconds)
            let f = self.state.buildStaging.buildRoot
            let fStart = try self.bind(f, "start.json"), fTerminal = try self.bind(f, "terminal.json"),
                fPrestart = try self.bind(f, "prestart.json"), fBinding = try self.bind(f, "binding.json")
            let fPre = try HJSON.object(f.readVerified(fPrestart, maximumByteCount: 16 * 1024 * 1024))
            let fEnd = try HJSON.object(f.readVerified(fTerminal, maximumByteCount: 16 * 1024 * 1024))
            guard let process = fEnd["process"] as? [String: Any] else { throw hRejected("phase_F_process") }
            try self.append(ordinal: 1, start: self.scope(fStart, "build"), terminal: self.scope(fTerminal, "build"),
                outputs: [self.scope(fBinding, "build")], started: try self.uptime(fPre, "deadlineStartedAtUptimeNanoseconds"),
                ended: try self.uptime(process, "waitReturnedUptimeNanoseconds"))
            let g = self.inventory.root
            let gStart = try self.bind(g, "01-xctest-start.json"), gPre = try self.bind(g, "01-xctest-prestart.json"),
                gLast = try self.bind(g, "02-swift-testing-terminal.json"), gTerminal = try self.bind(g, "terminal.json"),
                gBinding = try self.bind(g, "binding.json")
            let pre = try HJSON.object(g.readVerified(gPre, maximumByteCount: 16 * 1024 * 1024))
            let end = try HJSON.object(g.readVerified(gLast, maximumByteCount: 16 * 1024 * 1024))
            guard let process = end["process"] as? [String: Any] else { throw hRejected("phase_G_process") }
            try self.append(ordinal: 2, start: self.scope(gStart, "inventory"), terminal: self.scope(gTerminal, "inventory"),
                outputs: [self.scope(gBinding, "inventory")], started: try self.uptime(pre, "deadlineStartedAtUptimeNanoseconds"),
                ended: try self.uptime(process, "waitReturnedUptimeNanoseconds"))
            try self.planningTime()
        }
    }

    func recordPlan(startBinding: PrimeArtifactBinding, planBinding: PrimeArtifactBinding,
        goBinding: PrimeArtifactBinding, completedAt: UInt64) throws {
        try operation {
            guard self.prefixes.count == 3, startBinding.relativePath == "phase-04-start.json" else { throw hRejected("phase_plan_start") }
            try self.planningTime(); try self.staging.root.verify(startBinding)
            let terminal = try self.staging.publishData(HJSON.encode([
                "schema": "prime_driver_v2_gate_h_phase_terminal_v1", "phase": "execution_plan",
                "startSHA256": startBinding.sha256, "completedAtUptimeNanoseconds": completedAt,
                "planSHA256": planBinding.sha256, "goSHA256": goBinding.sha256, "disposition": "succeeded"
            ]), path: "phase-04-terminal.json")
            try self.append(ordinal: 3, start: self.scope(startBinding, "execution"), terminal: self.scope(terminal, "execution"),
                outputs: [self.scope(planBinding, "execution"), self.scope(goBinding, "execution")],
                started: self.plan.planningStartedAtUptimeNanoseconds, ended: completedAt)
        }
    }

    func recordArm(arm: String, startedAt: UInt64, completedAt: UInt64, firstPrestart: PrimeArtifactBinding,
        lastTerminal: PrimeArtifactBinding, acceptances: [PrimeArtifactBinding]) throws {
        try operation {
            let ordinal: Int
            switch arm { case "reference": ordinal = 4; case "candidate": ordinal = 5; default: throw hRejected("phase_arm") }
            guard self.prefixes.count == ordinal, !acceptances.isEmpty else { throw hRejected("phase_arm_order") }
            for binding in [firstPrestart, lastTerminal] + acceptances { try self.staging.root.verify(binding) }
            try self.append(ordinal: ordinal, start: self.scope(firstPrestart, "execution"),
                terminal: self.scope(lastTerminal, "execution"), outputs: acceptances.map { self.scope($0, "execution") },
                started: startedAt, ended: completedAt)
        }
    }

    /// Gate E records the empty private root before publication. Its exact
    /// completed namespace has 34 immutable regular leaves (links 2 -> 36).
    /// The caller independently acquires all 34 exact names and content joins.
    static func validateCompletedEJournalRoot(identity: [String: Any],
        observed: PrimeArtifactRootIdentity, absolutePath: String) throws {
        guard (identity["deviceID"] as? NSNumber)?.uint64Value == observed.deviceID,
              (identity["inode"] as? NSNumber)?.uint64Value == observed.inode,
              (identity["ownerUserID"] as? NSNumber)?.uint32Value == observed.ownerUserID,
              (identity["ownerGroupID"] as? NSNumber)?.uint32Value == observed.ownerGroupID,
              (identity["permissionMode"] as? NSNumber)?.uint16Value == observed.actualMode,
              (identity["linkCount"] as? NSNumber)?.uint64Value == 2,
              observed.linkCount == 2 + 34,
              (identity["absolutePath"] as? String) == absolutePath else { throw hRejected("phase_E_root_join") }
    }

    func beginReconciliation() throws { try begin(6) }
    func finishReconciliation(validatedResultData: Data) throws { try finish(6, validatedResultData) }
    func beginComparison() throws { try begin(7) }
    func finishComparison(validatedResultData: Data) throws { try finish(7, validatedResultData) }
    func activeDeadline() throws -> PrimeSecureChildPhaseDeadline {
        guard !poisoned, let active else { throw hRejected("phase_not_active") }; return active.deadline
    }
    func revalidate() throws {
        guard !poisoned else { throw hRejected("phase_poisoned") }
        _ = try eRoot?.verifiedRootIdentity()
        if let eRoot {
            let fd = try eRoot.duplicateTrustedRootDescriptorForInventory(); defer { close(fd) }
            guard try PrimeValidationDriverV2ExecutionStaging.entries(fd) == Set(eFiles.map { $0.expected.leaf }) else { throw hRejected("phase_E_changed_namespace") }
        }
        for file in eFiles { try file.revalidateMetadata() }
        for (root, binding) in observedBindings { try root.verify(binding) }
        for binding in orderedPrefixBindings {
            try staging.root.verify(.init(relativePath: String(binding.relativePath.dropFirst("execution/".count)),
                sha256: binding.sha256, byteCount: binding.byteCount, purpose: binding.purpose))
        }
    }
    private func begin(_ ordinal: Int) throws {
        try operation {
            guard self.prefixes.count == ordinal, self.active == nil else { throw hRejected("phase_begin_order") }
            let deadline = try PrimeSecureChildPhaseDeadline(startUptimeNanoseconds: DispatchTime.now().uptimeNanoseconds,
                durationNanoseconds: Self.limits[ordinal])
            let start = try self.staging.publishData(HJSON.encode([
                "schema": "prime_driver_v2_gate_h_phase_start_v1", "phase": Self.phases[ordinal],
                "runID": self.state.context.evidenceRunID,
                "startedAtUptimeNanoseconds": deadline.startUptimeNanoseconds,
                "expiresAtUptimeNanoseconds": deadline.expiresAtUptimeNanoseconds,
                "predecessorPrefixSHA256": self.orderedPrefixBindings.last!.sha256
            ]), path: String(format: "phase-%02d-start.json", ordinal + 1))
            self.active = (ordinal, start, deadline)
            try self.requireTime(deadline)
        }
    }
    private func finish(_ ordinal: Int, _ data: Data) throws {
        try operation {
            guard let active = self.active, active.ordinal == ordinal, self.prefixes.count == ordinal else { throw hRejected("phase_finish_order") }
            try self.requireTime(active.deadline)
            let result = try self.staging.publishData(data, path: String(format: "phase-%02d-result.json", ordinal + 1))
            let completed = DispatchTime.now().uptimeNanoseconds
            let terminal = try self.staging.publishData(HJSON.encode([
                "schema": "prime_driver_v2_gate_h_phase_terminal_v1", "phase": Self.phases[ordinal],
                "startSHA256": active.start.sha256, "resultSHA256": result.sha256,
                "completedAtUptimeNanoseconds": completed, "disposition": "succeeded"
            ]), path: String(format: "phase-%02d-terminal.json", ordinal + 1))
            try self.append(ordinal: ordinal, start: self.scope(active.start, "execution"),
                terminal: self.scope(terminal, "execution"), outputs: [self.scope(result, "execution")],
                started: active.deadline.startUptimeNanoseconds, ended: completed)
            try self.requireTime(active.deadline); self.active = nil
        }
    }
    private func append(ordinal: Int, start: PrimeArtifactBinding, terminal: PrimeArtifactBinding,
        outputs: [PrimeArtifactBinding], started: UInt64, ended: UInt64) throws {
        guard prefixes.count == ordinal, started > 0, ended > started, ended - started <= Self.limits[ordinal],
              DispatchTime.now().uptimeNanoseconds >= ended, !outputs.isEmpty else { throw hRejected("phase_interval") }
        let previous = orderedPrefixBindings.last?.sha256 ?? String(repeating: "0", count: 64)
        let entry = Entry(phase: Self.phases[ordinal], ordinal: ordinal,
            evidenceOrigin: ordinal < 3 ? "retained_predecessor_projection" : "live_h_phase",
            predecessorPrefixSHA256: previous, start: start, terminal: terminal,
            acceptedOutputBindings: outputs.sorted { $0.relativePath < $1.relativePath }, activeNanoseconds: ended - started)
        let now = DispatchTime.now().uptimeNanoseconds
        guard now > (prefixes.last?.recordedAtUptimeNanoseconds ?? 0) else { throw hRejected("phase_prefix_clock") }
        let prefix = Prefix(runID: state.context.evidenceRunID, intentSHA256: PrimeSHA256.hexDigest(of: plan.canonicalIntentData),
            sequence: UInt64(ordinal + 1), previousPrefixSHA256: previous, recordedAtUptimeNanoseconds: now,
            entries: (prefixes.last?.entries ?? []) + [entry])
        let binding = try staging.publishData(PrimeCanonicalJSON.encode(prefix), path: String(format: "phase-ledger-%02d.json", ordinal + 1))
        prefixes.append(prefix); orderedPrefixBindings.append(scope(binding, "execution")); try revalidate()
    }
    private func bind(_ root: PrimeArtifactRoot, _ path: String) throws -> PrimeArtifactBinding {
        let result = try root.bindExisting(at: path, purpose: .immutableData, maximumByteCount: 16 * 1024 * 1024)
        observedBindings.append((root, result)); return result
    }
    private func scope(_ value: PrimeArtifactBinding, _ parent: String) -> PrimeArtifactBinding {
        .init(relativePath: parent + "/" + value.relativePath, sha256: value.sha256, byteCount: value.byteCount, purpose: value.purpose)
    }
    private func uptime(_ value: [String: Any], _ key: String) throws -> UInt64 {
        guard let n = value[key] as? NSNumber, n.uint64Value > 0,
              try HJSON.encode([n]) == HJSON.encode([n.uint64Value]) else { throw hRejected("phase_observed_time") }; return n.uint64Value
    }
    private func planningTime() throws {
        guard DispatchTime.now().uptimeNanoseconds < plan.planningExpiresAtUptimeNanoseconds else { throw hRejected("phase_planning_deadline") }
    }
    private func requireTime(_ deadline: PrimeSecureChildPhaseDeadline) throws {
        guard try deadline.authorizesNewWork(observedAtUptimeNanoseconds: DispatchTime.now().uptimeNanoseconds) else { throw hRejected("phase_deadline") }
    }
    private func operation(_ body: () throws -> Void) throws {
        guard !poisoned else { throw hRejected("phase_poisoned") }
        do { try revalidate(); try body(); try revalidate() } catch { poisoned = true; throw error }
    }

    // Internal read-only witness permits producer/consumer filesystem tests;
    // it cannot construct a phase owner or authorize any execution.
    final class HeldPredecessorFile {
        let rootFD: Int32
        let fd: Int32
        let expected: PrimeValidationDriverV2FixedProbeJournalLeafObservation
        let original: stat
        init(parent: Int32, expected: PrimeValidationDriverV2FixedProbeJournalLeafObservation) throws {
            guard !expected.leaf.contains("/"), expected.byteCount > 0, expected.byteCount <= 16 * 1024 * 1024 else { throw hRejected("phase_E_leaf") }
            let parentCopy = fcntl(parent, F_DUPFD_CLOEXEC, 3)
            guard parentCopy >= 3 else { throw hRejected("phase_E_parent") }
            let opened = openat(parentCopy, expected.leaf, O_RDONLY | O_CLOEXEC | O_NOFOLLOW | O_NONBLOCK)
            guard opened >= 3 else { if opened >= 0 { close(opened) }; close(parentCopy); throw hRejected("phase_E_open") }
            var value = stat()
            do {
                guard fstat(opened, &value) == 0, UInt64(value.st_dev) == expected.deviceID,
                      UInt64(value.st_ino) == expected.inode, value.st_mode & S_IFMT == S_IFREG,
                      value.st_mode & 0o7777 == 0o400, value.st_nlink == 1,
                      value.st_uid == geteuid(), value.st_flags == 0, value.st_size >= 0,
                      UInt64(value.st_size) == expected.byteCount else { throw hRejected("phase_E_identity") }
                try PrimeArtifactRoot.requireTrustedInventoryArtifactDescriptor(opened, path: expected.leaf)
            } catch { close(opened); close(parentCopy); throw error }
            rootFD = parentCopy; fd = opened; self.expected = expected; original = value
        }
        deinit { close(fd); close(rootFD) }
        func revalidateMetadata() throws {
            var held = stat(), named = stat()
            guard fstat(fd, &held) == 0, fstatat(rootFD, expected.leaf, &named, AT_SYMLINK_NOFOLLOW) == 0,
                  PrimeValidationDriverV2BuildStaging.sameProtectedMetadata(held, original),
                  PrimeValidationDriverV2BuildStaging.sameProtectedMetadata(held, named) else { throw hRejected("phase_E_rejoin") }
            try PrimeArtifactRoot.requireTrustedInventoryArtifactDescriptor(fd, path: expected.leaf)
        }
        func read() throws -> Data {
            let (deadline, overflow) = DispatchTime.now().uptimeNanoseconds.addingReportingOverflow(5_000_000_000)
            guard !overflow else { throw hRejected("phase_E_read_deadline") }
            try revalidateMetadata()
            var data = Data(count: Int(expected.byteCount))
            try data.withUnsafeMutableBytes { bytes in
                var offset = 0, interruptions = 0
                while offset < bytes.count {
                    guard DispatchTime.now().uptimeNanoseconds < deadline else { throw hRejected("phase_E_read_deadline") }
                    let n = pread(fd, bytes.baseAddress!.advanced(by: offset), min(64 * 1024, bytes.count - offset), off_t(offset))
                    if n < 0 && errno == EINTR {
                        interruptions += 1
                        guard interruptions <= 8 else { throw hRejected("phase_E_read_interrupted") }
                        continue
                    }
                    guard n > 0 else { throw hRejected("phase_E_read") }; offset += n
                }
            }
            var after = stat(), finalNamed = stat()
            guard PrimeSHA256.hexDigest(of: data) == expected.sha256,
                  fstat(fd, &after) == 0, fstatat(rootFD, expected.leaf, &finalNamed, AT_SYMLINK_NOFOLLOW) == 0,
                  PrimeValidationDriverV2BuildStaging.sameProtectedMetadata(after, original),
                  PrimeValidationDriverV2BuildStaging.sameProtectedMetadata(after, finalNamed),
                  DispatchTime.now().uptimeNanoseconds < deadline else { throw hRejected("phase_E_content") }
            return data
        }
    }
}
