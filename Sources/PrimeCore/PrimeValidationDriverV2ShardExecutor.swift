// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary
// DRAFT: the native child lifecycle is adapted directly from the retained G executor.
import Darwin
import Dispatch
import Foundation

@_spi(PrimeValidationDriverV2RoleFacade)
public struct PrimeValidationDriverV2ExecutionPrestartV1: Codable, Equatable, Sendable {
    public let schema: String
    public let executionPlanSHA256: String
    public let shardID: String
    public let runID: String
    public let ordinal: Int
    public let role: String
    public let predecessorSHA256: String
    public let deadlineStartedAtUptimeNanoseconds: UInt64
    public let deadlineExpiresAtUptimeNanoseconds: UInt64
    public let executableAbsolutePath: String
    public let executableSHA256: String
    public let logicalArgumentZero: String
    /// Absent in historical records; new native records bind the exact syscall argv[0].
    public let physicalArgumentZero: String?
    public let arguments: [String]
    public let orderedEnvironment: [[String]]
    public let workingDirectoryAbsolutePath: String
}

enum PrimeValidationDriverV2ShardExecutor {
    @available(macOS 26.0, *)
    static func execute(owner: PrimeValidationDriverV2ExecutionOwner) throws -> PrimeValidationDriverV2ShardRawCapability {
        let (state, shard, policy, deadline, predecessorSHA256) = try owner.beginNext()
        var succeeded = false
        defer { if !succeeded { owner.poison() } }
        let staging = owner.staging
        let ordinal = shard.ordinal
        let executable = state.retainedState.admission.toolchain.swiftPackageExecutable
        let stdoutLeaf = "stdout.log", stderrLeaf = "stderr.log"
        let fd = try state.retainedState.admission.primeRepository.root
            .duplicateTrustedRootDescriptorForInventory()
        defer { close(fd) }
        let cwd = try PrimeSecureChildDarwinProcessProof.snapshotHeldDirectory(
            descriptor: fd, openedWithNoSymbolicLinksInPath: true,
            context: .validationWorkingDirectory
        )
        let prestart = try staging.publish(PrimeValidationDriverV2ExecutionPrestartV1(
            schema: "prime_driver_v2_gate_h_shard_prestart_v1", executionPlanSHA256: owner.planSHA256, shardID: shard.shardID,
            runID: state.context.evidenceRunID,
            ordinal: ordinal, role: "shard", predecessorSHA256: predecessorSHA256,
            deadlineStartedAtUptimeNanoseconds: deadline.startUptimeNanoseconds,
            deadlineExpiresAtUptimeNanoseconds: deadline.expiresAtUptimeNanoseconds,
            executableAbsolutePath: policy.physicalExecutableAbsolutePath,
            executableSHA256: executable.observation.sha256,
            logicalArgumentZero: policy.logicalArgumentZero,
            physicalArgumentZero: policy.physicalArgumentZero,
            arguments: policy.physicalArguments,
            orderedEnvironment: policy.completeReplacementEnvironment.map { [$0.0, $0.1] },
            workingDirectoryAbsolutePath: policy.physicalWorkingDirectoryAbsolutePath
        ), path: shard.relativeRoot + "/prestart.json")
        let stdoutFD = try staging.createStream(stdoutLeaf)
        let stderrFD: Int32
        do { stderrFD = try staging.createStream(stderrLeaf) }
        catch { close(stdoutFD); throw error }
        let spawn: PrimeSecureChildSpawnHandle
        do {
            try owner.revalidateContinuity()
            spawn = try PrimeSecureChildDarwinSubstrate.spawnDriverV2FixedProbeSuspended(
                executableAbsolutePath: policy.physicalExecutableAbsolutePath,
                argumentZero: policy.physicalArgumentZero,
                workingDirectoryDescriptor: cwd.descriptor,
                exactArguments: policy.physicalArguments,
                orderedEnvironment: policy.completeReplacementEnvironment
            )
        } catch { close(stdoutFD); close(stderrFD); throw error }
        let supervision = PrimeSecureChildSupervisionCapability.adoptFileBacked(
            spawn: spawn, phaseDeadline: deadline,
            standardOutputDescriptor: stdoutFD, standardErrorDescriptor: stderrFD,
            maximumByteCount: policy.standardOutputMaximumByteCount
        )
        var descendantCleanup: PrimeValidationDriverV2ShardDescendantCleanup?
        do {
            let pid = supervision.processIdentifier
            guard supervision.spawnReturnCode == 0,
                  let sid = supervision.establishDriverV2DedicatedGroupWithinSupervisorSession(),
                  sid == getpid()
            else { throw hRejected("spawn_group") }
            var bsd = proc_bsdinfo()
            let bsdSize = Int32(MemoryLayout<proc_bsdinfo>.size)
            let bsdReturned = withUnsafeMutablePointer(to: &bsd) {
                proc_pidinfo(pid, PROC_PIDTBSDINFO, 0, $0, bsdSize)
            }
            guard bsdReturned == bsdSize, bsd.pbi_pid == UInt32(pid),
                  bsd.pbi_ppid == UInt32(sid), bsd.pbi_pgid == UInt32(pid)
            else { throw hRejected("parent_join") }
            descendantCleanup = try .captureSuspendedLeader(processIdentifier: pid)
            let cwdProof = try PrimeSecureChildDarwinProcessProof.captureSuspendedWorkingDirectory(
                processIdentifier: pid, heldDirectory: cwd
            )
            let mapped = try PrimeSecureChildDarwinProcessProof.captureMappedExecutable(
                processIdentifier: pid,
                heldExecutable: PrimeSecureChildDarwinProcessProof.snapshotHeldExecutable(
                    deviceID: executable.observation.deviceID,
                    inode: executable.observation.inode,
                    expectedCanonicalAbsolutePath: executable.observation.canonicalAbsolutePath
                )
            )
            try owner.revalidateContinuity()
            let start = try staging.publish(PrimeValidationDriverV2InventoryStartV1(
                schema: "prime_driver_v2_gate_h_shard_start_v1", role: "shard",
                prestartSHA256: prestart.sha256,
                processIdentifier: pid, sessionIdentifier: sid, processGroupIdentifier: pid,
                appliedSpawnFlags: supervision.appliedFlags,
                spawnReturnedUptimeNanoseconds: supervision.spawnReturnedMonotonicNanoseconds,
                mappedExecutablePathTelemetry: mapped.mappedExecutablePathTelemetry,
                exactSuspendedWorkingDirectoryJoin: cwdProof.exactDescriptorJoinObserved
            ), path: shard.relativeRoot + "/start.json")
            try owner.revalidateContinuity()
            let beforeResume = DispatchTime.now().uptimeNanoseconds
            let resumedAt: UInt64
            switch try supervision.resume(notBeforeUptimeNanoseconds: beforeResume) {
            case let .resumed(time): resumedAt = time
            default: throw hRejected("resume")
            }
            guard case .observed = try supervision.observeDeath(),
                  let deathAt = supervision.deathObservedMonotonicNanoseconds()
            else { throw hRejected("death_deadline") }
            let drains: PrimeSecureChildDrainEvidence
            switch try supervision.waitForPhaseDrainCompletion(notBeforeUptimeNanoseconds: deathAt) {
            case let .completed(value): drains = value
            default: throw hRejected("drain_deadline")
            }
            guard let members = supervision.processGroupMemberIdentifiers(), members == [pid]
            else { throw hRejected("descendants_before_reap") }
            let wait: PrimeSecureChildExactPIDWaitObservation
            switch supervision.reapAfterObservedDeath() {
            case let .reaped(value): wait = value
            case .mustFailStop: Darwin._exit(99)
            }
            guard wait.requestedProcessIdentifier == pid,
                  wait.returnedProcessIdentifier == pid,
                  wait.waitOptions == 0,
                  case let .fileBacked(stdout, stderr) = drains
            else { throw hRejected("wait_or_drain_kind") }
            try owner.revalidateContinuity()
            let process = PrimeValidationDriverV2BuildProcessObservation(
                logicalArgumentZero: policy.logicalArgumentZero,
                physicalArgumentZero: policy.physicalArgumentZero,
                arguments: policy.physicalArguments,
                orderedEnvironment: policy.completeReplacementEnvironment.map { [$0.0, $0.1] },
                workingDirectoryAbsolutePath: policy.physicalWorkingDirectoryAbsolutePath,
                workingDirectoryDeviceID: cwd.deviceID, workingDirectoryInode: cwd.inode,
                executableAbsolutePath: executable.observation.canonicalAbsolutePath,
                executableDeviceID: executable.observation.deviceID,
                executableInode: executable.observation.inode,
                executableByteCount: executable.observation.byteCount,
                executableSHA256: executable.observation.sha256,
                mappedImageJoined: true,
                exactSuspendedWorkingDirectoryJoin: cwdProof.exactDescriptorJoinObserved,
                processIdentifier: pid, sessionIdentifier: sid, processGroupIdentifier: pid,
                parentProcessIdentifier: Int32(bsd.pbi_ppid),
                exactReapCount: 1,
                cleanupInitiated: false,
                appliedSpawnFlags: supervision.appliedFlags,
                spawnReturnCode: supervision.spawnReturnCode,
                deadlineStartedAtUptimeNanoseconds: deadline.startUptimeNanoseconds,
                deadlineExpiresAtUptimeNanoseconds: deadline.expiresAtUptimeNanoseconds,
                spawnReturnedUptimeNanoseconds: supervision.spawnReturnedMonotonicNanoseconds,
                resumedAtUptimeNanoseconds: resumedAt,
                deathObservedUptimeNanoseconds: deathAt,
                waitReturnedUptimeNanoseconds: wait.returnedMonotonicNanoseconds,
                preReapProcessGroupMemberIdentifiers: members,
                requestedWaitProcessIdentifier: wait.requestedProcessIdentifier,
                returnedWaitProcessIdentifier: wait.returnedProcessIdentifier,
                waitOptions: wait.waitOptions, rawWaitStatus: wait.rawWaitStatus,
                exitStatus: wait.exitStatus, terminationSignal: wait.terminationSignal,
                exitedNormally: wait.exitedNormally, coreDumped: wait.coreDumped,
                processGroupEmptyAfterReap: true,
                standardOutput: .init(stdout), standardError: .init(stderr)
            )
            let streamBindings = try staging.freezeStreams(process)
            let stdoutBinding = streamBindings[0], stderrBinding = streamBindings[1]
            let result = try staging.captureResultAfterExactReap()
            let terminal = try staging.publish(PrimeValidationDriverV2InventoryTerminalV1(
                schema: "prime_driver_v2_gate_h_shard_terminal_v1",
                role: "shard", startSHA256: start.sha256, process: process),
                path: shard.relativeRoot + "/terminal.json")
            try owner.revalidateContinuity()
            let raw = PrimeValidationDriverV2ShardRawObservation(shard: shard, executionPlanSHA256: owner.planSHA256, process: process,
                prestartBinding: prestart, startBinding: start, terminalBinding: terminal,
                standardOutputBinding: stdoutBinding, standardErrorBinding: stderrBinding,
                standardOutputData: try staging.read(stdoutBinding), standardErrorData: try staging.read(stderrBinding),
                resultBinding: result?.0, resultData: result?.1)
            succeeded = true
            return .init(observation: raw, owner: owner)
        } catch {
            if let descendantCleanup {
                do {
                    try descendantCleanup.contain(
                        leaderAlreadyReaped: supervision.exactPIDWaitObservation != nil
                    ) {
                        switch supervision.cleanupRejectedCapture() {
                        case .contained: return true
                        case .mustFailStop: return false
                        }
                    }
                } catch { Darwin._exit(99) }
            } else {
                // No descendant can have started before the suspended leader
                // identity is retained above.
                switch supervision.cleanupRejectedCapture() {
                case .contained: break
                case .mustFailStop: Darwin._exit(99)
                }
            }
            throw error
        }
    }
}

/// H rejection cleanup only. The ordinary child owner still owns exact wait
/// and stream closure. This owner retains the separately grouped worker tree
/// before stopping it, and never treats direct-PGID cleanup as a session proof.
/// Internal operation injection permits pure generation/race regression tests;
/// no public initializer or serialized value restores native authority.
final class PrimeValidationDriverV2ShardDescendantCleanup {
    struct Identity: Equatable {
        let pid: Int32
        let parent: Int32
        let session: Int32
        let group: Int32
        let uid: UInt32
        let startSeconds: UInt64
        let startMicroseconds: UInt64
        let status: UInt32

        func sameGenerationAndRelation(as other: Self) -> Bool {
            pid == other.pid && parent == other.parent && session == other.session
                && group == other.group && uid == other.uid
                && startSeconds == other.startSeconds && startMicroseconds == other.startMicroseconds
        }
        func sameGeneration(as other: Self) -> Bool {
            pid == other.pid && startSeconds == other.startSeconds && startMicroseconds == other.startMicroseconds
        }
    }
    struct Operations {
        let now: () -> UInt64
        let snapshot: (UInt64) throws -> [Identity]
        let identity: (Int32, UInt64) throws -> Identity?
        let signal: (Int32, Int32) -> Bool
        let groupAbsent: (Int32) -> Bool
        let pause: () -> Void
    }
    // One compound rejection-only allowance: at most 2s to freeze the tree,
    // the unchanged native supervision callback's at-most-9s cleanup timeline,
    // then at most 3s for generation/group settlement. No phase work is added.
    private static let freezeNanoseconds: UInt64 = 2_000_000_000
    private static let settlementNanoseconds: UInt64 = 3_000_000_000
    private static let cleanupNanoseconds: UInt64 = 14_000_000_000
    private static let maximumPolls = 4096
    private let leader: Identity
    private let operations: Operations
    private var used = false
    private(set) var captured: [Identity] = []

    init(leader: Identity, operations: Operations) throws {
        guard leader.pid > 0, leader.parent == leader.session, leader.session > 0,
              leader.pid != leader.session, leader.group == leader.pid,
              leader.startSeconds > 0, leader.startMicroseconds < 1_000_000,
              leader.status == 4 else { throw Self.rejected("leader") }
        self.leader = leader; self.operations = operations
    }

    func contain(leaderAlreadyReaped: Bool, cleanupLeader: () -> Bool) throws {
        guard !used else { throw Self.rejected("one_shot") }
        used = true
        let began = operations.now()
        let (expires, overflow) = began.addingReportingOverflow(Self.cleanupNanoseconds)
        guard began > 0, !overflow else { throw Self.rejected("deadline") }
        var stageDeadline = began + Self.freezeNanoseconds
        var lastTime = began
        func check() throws {
            let now = operations.now()
            guard now >= lastTime, now < stageDeadline, now < expires else { throw Self.rejected("deadline") }
            lastTime = now
        }
        func signalJoined(_ expected: Identity, _ signal: Int32) throws {
            try check()
            guard let current = try operations.identity(expected.pid, stageDeadline) else { return }
            guard expected.sameGenerationAndRelation(as: current), current.pid != leader.session else {
                throw Self.rejected("signal_generation")
            }
            guard operations.signal(current.pid, signal) else { throw Self.rejected("signal") }
            try check()
        }
        if !leaderAlreadyReaped {
            // Pin the direct leader while it is still our unreaped child, then
            // freeze every current descendant. Stopped ancestors cannot create
            // an unseen replacement worker after the fixed point below.
            try signalJoined(leader, SIGSTOP)
            var previous: [Identity]?
            var stopped: [Identity]?
            for _ in 0..<Self.maximumPolls {
                try check()
                let members = try operations.snapshot(stageDeadline).sorted { $0.pid < $1.pid }
                try validateOwnedTree(members, check: check)
                for member in members where member.status != 5 {
                    try signalJoined(member, SIGSTOP)
                }
                if members.allSatisfy({ $0.status == 4 || $0.status == 5 }), members == previous {
                    stopped = members; break
                }
                previous = members
                operations.pause()
            }
            guard let stopped else { throw Self.rejected("stopped_fixed_point") }
            captured = stopped
            // Workers may lead their own PGIDs (SwiftPM's XCTest runner does).
            // Actuate exact joined PIDs, never a historical numeric worker PGID
            // or the supervisor's own group. The leader cleanup follows them.
            let byPID = Dictionary(uniqueKeysWithValues: stopped.map { ($0.pid, $0) })
            var orderedWorkers: [(identity: Identity, depth: Int)] = []
            for worker in stopped where worker.pid != leader.pid {
                try check()
                var parent = worker.parent
                var depth = 1
                while parent != leader.pid {
                    try check()
                    guard depth < stopped.count, let ancestor = byPID[parent] else { throw Self.rejected("kill_ancestry") }
                    parent = ancestor.parent; depth += 1
                }
                orderedWorkers.append((identity: worker, depth: depth))
            }
            orderedWorkers.sort { first, second in
                if first.depth == second.depth { return first.identity.pid < second.identity.pid }
                return first.depth > second.depth
            }
            for (worker, _) in orderedWorkers where worker.status != 5 {
                try signalJoined(worker, SIGKILL)
            }
        }
        try check()
        // At least 12s remain because the freeze stage is capped at 2s.
        // The production callback is the existing bounded native supervision
        // cleanup; an injected callback that overruns can never yield success.
        stageDeadline = expires
        guard cleanupLeader() else { throw Self.rejected("leader_cleanup") }
        try check()
        let settlementStart = operations.now()
        let (settlementExpires, settlementOverflow) = settlementStart.addingReportingOverflow(Self.settlementNanoseconds)
        guard !settlementOverflow else { throw Self.rejected("deadline") }
        stageDeadline = min(expires, settlementExpires)
        let capturedByPID = Dictionary(uniqueKeysWithValues: captured.map { ($0.pid, $0) })
        var emptyCount = 0
        for _ in 0..<Self.maximumPolls {
            try check()
            let members = try operations.snapshot(stageDeadline)
            // No new authority is acquired after exact leader reap. Previously
            // killed workers may briefly remain (including reparented zombies);
            // wait for their actual disappearance, without signalling again.
            for current in members {
                try check()
                guard let previous = capturedByPID[current.pid], previous.sameGeneration(as: current),
                      previous.session == current.session, previous.group == current.group,
                      previous.uid == current.uid else { throw Self.rejected("late_session_member") }
            }
            var allGone = members.isEmpty
            for expected in captured {
                try check()
                if let current = try operations.identity(expected.pid, stageDeadline),
                   current.sameGeneration(as: expected) { allGone = false }
            }
            for group in Set(captured.map(\.group) + [leader.group]) {
                try check()
                if !operations.groupAbsent(group) { allGone = false }
            }
            emptyCount = allGone ? emptyCount + 1 : 0
            if emptyCount == 2 { try check(); return }
            operations.pause()
        }
        throw Self.rejected("unsettled")
    }

    private func validateOwnedTree(_ members: [Identity], check: () throws -> Void) throws {
        try check()
        guard Set(members.map(\.pid)).count == members.count,
              let currentLeader = members.first(where: { $0.pid == leader.pid }),
              currentLeader.sameGenerationAndRelation(as: leader),
              members.allSatisfy({ $0.pid != leader.session && $0.session == leader.session
                  && $0.uid == leader.uid && $0.pid > 0 && $0.group > 0
                  && $0.group != leader.session && $0.startSeconds > 0 && $0.startMicroseconds < 1_000_000 })
        else { throw Self.rejected("tree_identity") }
        let byPID = Dictionary(uniqueKeysWithValues: members.map { ($0.pid, $0) })
        for member in members where member.pid != leader.pid {
            try check()
            var parent = member.parent
            var seen = Set<Int32>()
            while parent != leader.pid {
                try check()
                guard seen.insert(parent).inserted, let ancestor = byPID[parent] else {
                    throw Self.rejected("tree_ancestry")
                }
                parent = ancestor.parent
            }
        }
    }

    static func captureSuspendedLeader(processIdentifier: Int32) throws -> PrimeValidationDriverV2ShardDescendantCleanup {
        let session = getpid()
        guard getsid(session) == session, getpgid(session) == session else { throw rejected("supervisor_session") }
        let now = DispatchTime.now().uptimeNanoseconds
        let (expires, overflow) = now.addingReportingOverflow(cleanupNanoseconds)
        guard !overflow, let leader = try readIdentity(processIdentifier, deadline: expires),
              leader.session == session, leader.uid == geteuid() else { throw rejected("capture_leader") }
        let ops = Operations(now: { DispatchTime.now().uptimeNanoseconds }, snapshot: { deadline in
            try snapshot(session: session, deadline: deadline)
        }, identity: { pid, deadline in try readIdentity(pid, deadline: deadline) }, signal: { pid, signal in
            errno = 0
            return Darwin.kill(pid, signal) == 0 || errno == ESRCH
        }, groupAbsent: { group in
            errno = 0
            return Darwin.kill(-group, 0) == -1 && errno == ESRCH
        }, pause: { _ = Darwin.usleep(1_000) })
        return try .init(leader: leader, operations: ops)
    }

    private static func requireTime(_ deadline: UInt64) throws {
        guard DispatchTime.now().uptimeNanoseconds < deadline else { throw rejected("native_deadline") }
    }
    private static func readIdentity(_ pid: Int32, deadline: UInt64) throws -> Identity? {
        try requireTime(deadline)
        var first = proc_bsdinfo(), second = proc_bsdinfo()
        let size = Int32(MemoryLayout<proc_bsdinfo>.size)
        errno = 0
        let count = withUnsafeMutablePointer(to: &first) { proc_pidinfo(pid, PROC_PIDTBSDINFO, 0, $0, size) }
        if count <= 0 && errno == ESRCH { return nil }
        guard count == size else { throw rejected("native_bsd") }
        errno = 0
        let session = getsid(pid)
        if session < 0 && errno == ESRCH { return nil }
        guard session > 0 else { throw rejected("native_sid") }
        errno = 0
        let repeated = withUnsafeMutablePointer(to: &second) { proc_pidinfo(pid, PROC_PIDTBSDINFO, 0, $0, size) }
        if repeated <= 0 && errno == ESRCH { return nil }
        guard repeated == size, first.pbi_pid == UInt32(pid), second.pbi_pid == first.pbi_pid,
              first.pbi_ppid == second.pbi_ppid, first.pbi_pgid == second.pbi_pgid,
              first.pbi_uid == second.pbi_uid, first.pbi_start_tvsec == second.pbi_start_tvsec,
              first.pbi_start_tvusec == second.pbi_start_tvusec,
              getsid(pid) == session else { throw rejected("native_generation") }
        try requireTime(deadline)
        return .init(pid: pid, parent: Int32(second.pbi_ppid), session: session,
            group: Int32(second.pbi_pgid), uid: second.pbi_uid,
            startSeconds: second.pbi_start_tvsec, startMicroseconds: second.pbi_start_tvusec,
            status: second.pbi_status)
    }
    private static func snapshot(session: Int32, deadline: UInt64) throws -> [Identity] {
        try requireTime(deadline)
        var pids = [Int32](repeating: 0, count: 131_072)
        let capacity = pids.count * MemoryLayout<Int32>.size
        let bytes = pids.withUnsafeMutableBytes { proc_listpids(UInt32(PROC_ALL_PIDS), 0, $0.baseAddress, Int32($0.count)) }
        guard bytes > 0, Int(bytes) < capacity, Int(bytes) % MemoryLayout<Int32>.size == 0 else { throw rejected("native_capacity") }
        let selected = pids.prefix(Int(bytes) / MemoryLayout<Int32>.size).filter { $0 > 0 }
        guard Set(selected).count == selected.count else { throw rejected("native_duplicate") }
        var result: [Identity] = []
        for pid in selected where pid != session {
            try requireTime(deadline)
            errno = 0
            let sid = getsid(pid)
            if sid < 0 && errno == ESRCH { continue }
            guard sid >= 0 else { throw rejected("native_sid_prefilter") }
            if sid != session { continue }
            if let value = try readIdentity(pid, deadline: deadline) {
                guard value.session == session else { throw rejected("native_sid_changed") }
                result.append(value)
            }
        }
        try requireTime(deadline)
        return result
    }
    private static func rejected(_ reason: String) -> PrimeDurableArtifactError {
        .invalidSemantics("driver_v2_gate_h_descendant_cleanup_" + reason)
    }
}
