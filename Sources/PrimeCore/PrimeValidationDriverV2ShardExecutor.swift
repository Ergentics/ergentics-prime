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
            switch supervision.cleanupRejectedCapture() {
            case .contained: break
            case .mustFailStop: Darwin._exit(99)
            }
            throw error
        }
    }
}
