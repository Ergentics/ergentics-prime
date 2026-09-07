// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin
import Dispatch
import Foundation

@_spi(PrimeValidationDriverV2RoleFacade)
public struct PrimeValidationDriverV2BuildStreamObservation: Codable, Equatable, Sendable {
    public let totalByteCount: UInt64
    public let capturedByteCount: UInt64
    public let reachedEOF: Bool
    public let overflowed: Bool
    public let workerFinished: Bool
    public let readErrorNumber: Int32
    public let writeErrorNumber: Int32
    public let finalizationErrorNumber: Int32
    public let closeErrorNumber: Int32
    public let descriptorsClosed: Bool
    public let outputDeviceID: UInt64
    public let outputInode: UInt64
    public let outputByteCount: UInt64
    public let outputPermissionMode: UInt16
    public let outputSHA256: String
    public let outputMetadataObserved: Bool
    public let terminalReason: String

    init(_ value: PrimeSecureChildFileBackedDrainSnapshot) {
        totalByteCount = value.totalByteCount
        capturedByteCount = value.capturedByteCount
        reachedEOF = value.reachedEOF
        overflowed = value.overflowed
        workerFinished = value.workerFinished
        readErrorNumber = value.readErrorNumber
        writeErrorNumber = value.writeErrorNumber
        finalizationErrorNumber = value.finalizationErrorNumber
        closeErrorNumber = value.closeErrorNumber
        descriptorsClosed = value.descriptorsClosed
        outputDeviceID = value.outputDeviceID
        outputInode = value.outputInode
        outputByteCount = value.outputByteCount
        outputPermissionMode = value.outputPermissionMode
        outputSHA256 = value.outputSHA256
        outputMetadataObserved = value.outputMetadataObserved
        terminalReason = value.terminalReason.rawValue
    }

    var clean: Bool {
        reachedEOF && !overflowed && workerFinished && descriptorsClosed
            && readErrorNumber == 0 && writeErrorNumber == 0
            && finalizationErrorNumber == 0 && closeErrorNumber == 0
            && totalByteCount == capturedByteCount
            && capturedByteCount == outputByteCount
            && outputMetadataObserved && outputPermissionMode == 0o444
            && terminalReason == "end_of_file"
    }
}

@_spi(PrimeValidationDriverV2RoleFacade)
public struct PrimeValidationDriverV2BuildProcessObservation: Codable, Equatable, Sendable {
    public let logicalArgumentZero: String
    public let arguments: [String]
    public let orderedEnvironment: [[String]]
    public let workingDirectoryAbsolutePath: String
    public let workingDirectoryDeviceID: UInt64
    public let workingDirectoryInode: UInt64
    public let executableAbsolutePath: String
    public let executableDeviceID: UInt64
    public let executableInode: UInt64
    public let executableByteCount: UInt64
    public let executableSHA256: String
    public let mappedImageJoined: Bool
    public let exactSuspendedWorkingDirectoryJoin: Bool
    public let processIdentifier: Int32
    public let sessionIdentifier: Int32
    public let processGroupIdentifier: Int32
    public let parentProcessIdentifier: Int32
    public let exactReapCount: Int
    public let cleanupInitiated: Bool
    public let appliedSpawnFlags: UInt16
    public let spawnReturnCode: Int32
    public let deadlineStartedAtUptimeNanoseconds: UInt64
    public let deadlineExpiresAtUptimeNanoseconds: UInt64
    public let spawnReturnedUptimeNanoseconds: UInt64
    public let resumedAtUptimeNanoseconds: UInt64
    public let deathObservedUptimeNanoseconds: UInt64
    public let waitReturnedUptimeNanoseconds: UInt64
    public let preReapProcessGroupMemberIdentifiers: [Int32]
    public let requestedWaitProcessIdentifier: Int32
    public let returnedWaitProcessIdentifier: Int32
    public let waitOptions: Int32
    public let rawWaitStatus: Int32
    public let exitStatus: Int32
    public let terminationSignal: Int32
    public let exitedNormally: Bool
    public let coreDumped: Bool
    public let processGroupEmptyAfterReap: Bool
    public let standardOutput: PrimeValidationDriverV2BuildStreamObservation
    public let standardError: PrimeValidationDriverV2BuildStreamObservation
}

@_spi(PrimeValidationDriverV2RoleFacade)
public struct PrimeValidationDriverV2BuildRawObservation {
    public let process: PrimeValidationDriverV2BuildProcessObservation
    public let artifacts: PrimeValidationDriverV2BuildArtifactsObservation
    public let pinnedBundle: PrimeValidationDriverV2PinnedBundleStagingObservation
    public let toolchain: PrimeValidationSwiftPMToolchainObservation
    public let swiftPackageExecutableData: Data
    public let swiftBuildPersonalityIdentity:
        PrimeValidationDriverV2FixedProbePersonalityIdentityObservation
    public let swiftTestPersonalityIdentity:
        PrimeValidationDriverV2FixedProbePersonalityIdentityObservation
    public let swiftPackageDescriptorJoined: Bool
    public let swiftPackageNamedPathJoined: Bool
    public let swiftBuildPersonalityReadlinkObserved: Bool
    public let swiftTestPersonalityReadlinkObserved: Bool
    public let swiftBuildPersonalityResolvedExecutableJoined: Bool
    public let swiftTestPersonalityResolvedExecutableJoined: Bool
    public let sourceSnapshot: Data
    public let packageResolvedBinding: PrimeArtifactBinding
    public let terminalBinding: PrimeArtifactBinding
}

/// Raw data never reconstitutes the live source/staging/artifact owner.
/// Failure, rejection or dropping this value permanently consumes its run.
@_spi(PrimeValidationDriverV2RoleFacade)
public final class PrimeValidationDriverV2BuildRawCapability: @unchecked Sendable {
    public let observation: PrimeValidationDriverV2BuildRawObservation
    private let lock = NSLock()
    private var lifetime: PrimeValidationDriverV2BuildBoundLifetime?

    init(observation: PrimeValidationDriverV2BuildRawObservation,
         owner: PrimeValidationDriverV2BuildOwner,
         staging: PrimeValidationDriverV2BuildStaging,
         artifacts: PrimeValidationDriverV2BuildArtifacts) {
        self.observation = observation
        lifetime = PrimeValidationDriverV2BuildBoundLifetime(
            owner: owner, staging: staging, artifacts: artifacts
        )
    }

    public func consumeValidatedBindingLifetime(bindingData: Data) throws
        -> PrimeValidationDriverV2BuildBoundLifetime
    {
        lock.lock(); defer { lock.unlock() }
        guard let retained = lifetime else { throw buildRejected("raw_consumed") }
        lifetime = nil
        try retained.revalidateContinuity()
        try retained.publishBindingData(bindingData)
        try retained.revalidateContinuity()
        return retained
    }

    public func rejectValidatedBindingLifetime() {
        lock.lock(); defer { lock.unlock() }
        lifetime?.poison()
        lifetime = nil
    }

    deinit { lifetime?.poison() }
}

@_spi(PrimeValidationDriverV2RoleFacade)
public final class PrimeValidationDriverV2BuildBoundLifetime: @unchecked Sendable {
    private let lock = NSLock()
    private let owner: PrimeValidationDriverV2BuildOwner
    private let staging: PrimeValidationDriverV2BuildStaging
    private let artifacts: PrimeValidationDriverV2BuildArtifacts
    private var valid = true

    fileprivate init(owner: PrimeValidationDriverV2BuildOwner,
                     staging: PrimeValidationDriverV2BuildStaging,
                     artifacts: PrimeValidationDriverV2BuildArtifacts) {
        self.owner = owner; self.staging = staging; self.artifacts = artifacts
    }
    public func revalidateContinuity() throws {
        lock.lock(); defer { lock.unlock() }
        guard valid else { throw buildRejected("bound_poisoned") }
        do {
            try owner.revalidateContinuity(staging: staging)
            try artifacts.revalidate()
            try owner.revalidateContinuity(staging: staging)
        } catch { valid = false; owner.poison(); throw error }
    }
    /// Permanently consumes the validated build lifetime before its deadline.
    /// No decoded receipt can call this constructor or reacquire its guards.
    public func consumeForInventory() throws -> PrimeValidationDriverV2InventoryOwner {
        lock.lock(); defer { lock.unlock() }
        guard valid else { throw buildRejected("bound_poisoned") }
        valid = false
        do {
            return try owner.consumeForInventory(staging: staging, artifacts: artifacts)
        } catch { owner.poison(); throw error }
    }
    fileprivate func poison() {
        lock.lock(); defer { lock.unlock() }
        valid = false; owner.poison()
    }
    fileprivate func publishBindingData(_ data: Data) throws {
        lock.lock(); defer { lock.unlock() }
        guard valid else { throw buildRejected("bound_poisoned") }
        do {
            try owner.revalidateContinuity(staging: staging)
            try staging.publishBindingData(data)
            try owner.revalidateContinuity(staging: staging)
        } catch { valid = false; owner.poison(); throw error }
    }
    deinit { owner.poison() }
}

@available(macOS 26.0, *)
extension PrimeValidationDriverV2BuildOwner {
    public func executeBuild() throws -> PrimeValidationDriverV2BuildRawCapability {
        try PrimeValidationDriverV2BuildExecutor.execute(owner: self)
    }
}

private struct BuildPrestart: Encodable {
    let schema = "prime_driver_v2_gate_f_build_prestart_v1"
    let runID: String
    let deadlineStartedAtUptimeNanoseconds: UInt64
    let deadlineExpiresAtUptimeNanoseconds: UInt64
    let executableAbsolutePath: String
    let executableSHA256: String
    let logicalArgumentZero: String
    let arguments: [String]
    let orderedEnvironment: [[String]]
    let workingDirectoryAbsolutePath: String
}
private struct BuildStart: Encodable {
    let schema = "prime_driver_v2_gate_f_build_start_v1"
    let prestartSHA256: String
    let processIdentifier: Int32
    let sessionIdentifier: Int32
    let processGroupIdentifier: Int32
    let appliedSpawnFlags: UInt16
    let spawnReturnedUptimeNanoseconds: UInt64
    let mappedExecutablePathTelemetry: String
    let exactSuspendedWorkingDirectoryJoin: Bool
}
private struct BuildTerminal: Encodable {
    let schema = "prime_driver_v2_gate_f_build_terminal_v1"
    let startSHA256: String
    let process: PrimeValidationDriverV2BuildProcessObservation
}

enum PrimeValidationDriverV2BuildExecutor {
    @available(macOS 26.0, *)
    static func execute(owner: PrimeValidationDriverV2BuildOwner) throws
        -> PrimeValidationDriverV2BuildRawCapability
    {
        let state = try owner.beginExecution()
        var succeeded = false
        defer { if !succeeded { owner.poison() } }
        let staging = try PrimeValidationDriverV2BuildStaging(state: state)
        try owner.revalidateContinuity(staging: staging)
        let policy = state.buildPolicy
        let executable = state.retainedState.admission.toolchain.swiftPackageExecutable
        guard policy.role == .build,
              policy.physicalExecutableAbsolutePath
                == executable.observation.canonicalAbsolutePath,
              policy.logicalArgumentZero == "swift-build",
              policy.maximumWallNanoseconds == 900_000_000_000
        else { throw buildRejected("policy") }
        let process = try executeChild(
            owner: owner, state: state, staging: staging, executable: executable
        )
        // No result is admitted until the sole child and both streams are
        // finished and all input guards have been checked again.
        guard process.exitedNormally, process.exitStatus == 0,
              process.terminationSignal == 0, !process.coreDumped,
              process.standardOutput.clean, process.standardError.clean,
              process.processGroupEmptyAfterReap
        else { throw buildRejected("child_nonzero_or_stream_rejection") }
        try owner.revalidateContinuity(staging: staging)
        let prefix = state.context.workspaceRootAbsolutePath + "/"
        let metallib = state.context.requiredPinnedMetallibAbsolutePath
        guard metallib.hasPrefix(prefix) else { throw buildRejected("metallib_path") }
        // The root validation suite consumes the retained calibration bundle.
        // Its historical bytes are authenticated and copied after SwiftPM has
        // finished; this transition does not claim a new shader compilation.
        let scratchOwner = try staging.retainedSwiftPMScratchDirectory()
        let pinnedBundle = try state.pinnedBundleInput.stage(
            into: staging.workspaceRoot,
            deadlineNanoseconds: state.deadline.expiresAtUptimeNanoseconds,
            swiftPMScratchOwner: scratchOwner
        )
        try owner.revalidateContinuity(staging: staging)
        let artifacts = try PrimeValidationDriverV2BuildArtifacts.capture(
            workspaceRoot: staging.workspaceRoot,
            scratchRelativePath: "root-release-build",
            testBundleRelativePath:
                "root-release-build/arm64-apple-macosx/release/ErgenticsPrimePackageTests.xctest",
            metallibRelativePath: String(metallib.dropFirst(prefix.count)),
            expectedMetallibByteCount: state.context.requiredPinnedMetallibByteCount,
            expectedMetallibSHA256: state.context.requiredPinnedMetallibSHA256,
            artifactRoot: staging.artifactRoot,
            deadlineNanoseconds: state.deadline.expiresAtUptimeNanoseconds,
            swiftPMScratchOwner: scratchOwner
        )
        try staging.freezeCapturedArtifactRoot(artifacts.observation)
        try owner.revalidateContinuity(staging: staging)
        let terminal = try staging.buildRoot.bindExisting(
            at: "terminal.json", purpose: .immutableData, maximumByteCount: 64 * 1024
        )
        let admission = state.retainedState.admission
        try executable.revalidate()
        try admission.toolchain.swiftBuildPersonality.revalidate()
        try admission.toolchain.swiftTestPersonality.revalidate()
        guard admission.toolchain.swiftBuildPersonality.observation
                .canonicalExecutableAbsolutePath == executable.observation.canonicalAbsolutePath,
              admission.toolchain.swiftTestPersonality.observation
                .canonicalExecutableAbsolutePath == executable.observation.canonicalAbsolutePath
        else { throw buildRejected("package_personality_join") }
        let observation = PrimeValidationDriverV2BuildRawObservation(
            process: process, artifacts: artifacts.observation,
            pinnedBundle: pinnedBundle,
            toolchain: admission.toolchain.observation,
            swiftPackageExecutableData: executable.data,
            swiftBuildPersonalityIdentity:
                .init(admission.toolchain.swiftBuildPersonality.identity),
            swiftTestPersonalityIdentity:
                .init(admission.toolchain.swiftTestPersonality.identity),
            swiftPackageDescriptorJoined: true,
            swiftPackageNamedPathJoined: true,
            swiftBuildPersonalityReadlinkObserved: true,
            swiftTestPersonalityReadlinkObserved: true,
            swiftBuildPersonalityResolvedExecutableJoined: true,
            swiftTestPersonalityResolvedExecutableJoined: true,
            sourceSnapshot: try PrimeCanonicalJSON.encode(admission.sourceSnapshot),
            packageResolvedBinding: admission.packageResolvedBinding,
            terminalBinding: terminal
        )
        let result = PrimeValidationDriverV2BuildRawCapability(
            observation: observation, owner: owner, staging: staging, artifacts: artifacts
        )
        succeeded = true
        return result
    }

    @available(macOS 26.0, *)
    private static func executeChild(
        owner: PrimeValidationDriverV2BuildOwner,
        state: PrimeValidationDriverV2BuildExecutionState,
        staging: PrimeValidationDriverV2BuildStaging,
        executable: PrimeValidationSwiftPMHeldSystemFile
    ) throws -> PrimeValidationDriverV2BuildProcessObservation {
        let policy = state.buildPolicy
        let fd = try state.retainedState.admission.primeRepository.root
            .duplicateTrustedRootDescriptorForInventory()
        defer { close(fd) }
        let cwd = try PrimeSecureChildDarwinProcessProof.snapshotHeldDirectory(
            descriptor: fd, openedWithNoSymbolicLinksInPath: true,
            context: .validationWorkingDirectory
        )
        let prestart = try staging.publish(BuildPrestart(
            runID: state.context.evidenceRunID,
            deadlineStartedAtUptimeNanoseconds: state.deadline.startUptimeNanoseconds,
            deadlineExpiresAtUptimeNanoseconds: state.deadline.expiresAtUptimeNanoseconds,
            executableAbsolutePath: policy.physicalExecutableAbsolutePath,
            executableSHA256: executable.observation.sha256,
            logicalArgumentZero: policy.logicalArgumentZero,
            arguments: policy.physicalArguments,
            orderedEnvironment: policy.completeReplacementEnvironment.map { [$0.0, $0.1] },
            workingDirectoryAbsolutePath: policy.physicalWorkingDirectoryAbsolutePath
        ), leaf: "prestart.json")
        let stdoutFD = try staging.createStream("stdout.log")
        let stderrFD: Int32
        do { stderrFD = try staging.createStream("stderr.log") }
        catch { close(stdoutFD); throw error }
        let spawn: PrimeSecureChildSpawnHandle
        do {
            try owner.revalidateContinuity(staging: staging)
            spawn = try PrimeSecureChildDarwinSubstrate.spawnDriverV2FixedProbeSuspended(
                executableAbsolutePath: policy.physicalExecutableAbsolutePath,
                argumentZero: policy.logicalArgumentZero,
                workingDirectoryDescriptor: cwd.descriptor,
                exactArguments: policy.physicalArguments,
                orderedEnvironment: policy.completeReplacementEnvironment
            )
        } catch { close(stdoutFD); close(stderrFD); throw error }
        let supervision = PrimeSecureChildSupervisionCapability.adoptFileBacked(
            spawn: spawn, phaseDeadline: state.deadline,
            standardOutputDescriptor: stdoutFD, standardErrorDescriptor: stderrFD,
            maximumByteCount: policy.standardOutputMaximumByteCount
        )
        do {
            let pid = supervision.processIdentifier
            guard supervision.spawnReturnCode == 0,
                  let sid = supervision.establishDriverV2DedicatedGroupWithinSupervisorSession(),
                  sid == getpid()
            else { throw buildRejected("spawn_group") }
            var bsd = proc_bsdinfo()
            let bsdSize = Int32(MemoryLayout<proc_bsdinfo>.size)
            let bsdReturned = withUnsafeMutablePointer(to: &bsd) {
                proc_pidinfo(pid, PROC_PIDTBSDINFO, 0, $0, bsdSize)
            }
            guard bsdReturned == bsdSize, bsd.pbi_pid == UInt32(pid),
                  bsd.pbi_ppid == UInt32(sid), bsd.pbi_pgid == UInt32(pid)
            else { throw buildRejected("parent_join") }
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
            try owner.revalidateContinuity(staging: staging)
            let start = try staging.publish(BuildStart(
                prestartSHA256: prestart.sha256,
                processIdentifier: pid, sessionIdentifier: sid, processGroupIdentifier: pid,
                appliedSpawnFlags: supervision.appliedFlags,
                spawnReturnedUptimeNanoseconds: supervision.spawnReturnedMonotonicNanoseconds,
                mappedExecutablePathTelemetry: mapped.mappedExecutablePathTelemetry,
                exactSuspendedWorkingDirectoryJoin: cwdProof.exactDescriptorJoinObserved
            ), leaf: "start.json")
            try owner.revalidateContinuity(staging: staging)
            let beforeResume = DispatchTime.now().uptimeNanoseconds
            let resumedAt: UInt64
            switch try supervision.resume(notBeforeUptimeNanoseconds: beforeResume) {
            case let .resumed(time): resumedAt = time
            default: throw buildRejected("resume")
            }
            guard case .observed = try supervision.observeDeath(),
                  let deathAt = supervision.deathObservedMonotonicNanoseconds()
            else { throw buildRejected("death_deadline") }
            let drains: PrimeSecureChildDrainEvidence
            switch try supervision.waitForPhaseDrainCompletion(notBeforeUptimeNanoseconds: deathAt) {
            case let .completed(value): drains = value
            default: throw buildRejected("drain_deadline")
            }
            guard let members = supervision.processGroupMemberIdentifiers(), members == [pid]
            else { throw buildRejected("descendants_before_reap") }
            let wait: PrimeSecureChildExactPIDWaitObservation
            switch supervision.reapAfterObservedDeath() {
            case let .reaped(value): wait = value
            case .mustFailStop: Darwin._exit(95)
            }
            guard wait.requestedProcessIdentifier == pid,
                  wait.returnedProcessIdentifier == pid,
                  wait.waitOptions == 0,
                  case let .fileBacked(stdout, stderr) = drains
            else { throw buildRejected("wait_or_drain_kind") }
            try owner.revalidateContinuity(staging: staging)
            let process = PrimeValidationDriverV2BuildProcessObservation(
                logicalArgumentZero: policy.logicalArgumentZero,
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
                deadlineStartedAtUptimeNanoseconds: state.deadline.startUptimeNanoseconds,
                deadlineExpiresAtUptimeNanoseconds: state.deadline.expiresAtUptimeNanoseconds,
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
            try staging.verifyCompletedStreams(process)
            try staging.publish(BuildTerminal(startSHA256: start.sha256, process: process),
                                leaf: "terminal.json")
            return process
        } catch {
            switch supervision.cleanupRejectedCapture() {
            case .contained: break
            case .mustFailStop: Darwin._exit(95)
            }
            throw error
        }
    }
}

private func buildRejected(_ reason: String) -> Error {
    PrimeValidationSwiftPMBuildInventoryAdmissionError.rejected("driver_v2_build_" + reason)
}
