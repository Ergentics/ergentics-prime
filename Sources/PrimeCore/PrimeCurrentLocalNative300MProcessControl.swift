// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin
import Dispatch
import Foundation

public enum PrimeCurrentLocalNative300MRole: String, Codable, CaseIterable {
    case baseline = "stage7-baseline"
    case resume = "stage7-resume"
    case verify = "stage8-verify"
}

public struct PrimeCurrentLocalNative300MLaunch: Codable {
    public let schema: String
    public let runID: String
    /// Declaration joined to exact current source bytes below, not invented hosted ancestry.
    public let sourceCommitDeclaration: String
    public let sourceRoot: String
    public let sourceFiles: [PrimeArtifactBinding]
    public let executableAbsolutePath: String
    public let executableSHA256: String
    public let executableByteCount: UInt64
    public let metallib: PrimeNativeDecoderMaintainedRuntimeMetallibExpectationV1
    public let runRoot: String
    public let stage7WorkerSeconds: UInt64
    public let stage7SupervisorSeconds: UInt64
    public let stage8WorkerSeconds: UInt64
    public let stage8SupervisorSeconds: UInt64

    public static func sourcePaths(root: URL) throws -> [String] {
        guard root.isFileURL, let resolvedRoot = realpath(root.path, nil) else {
            throw Local300MError.rejected("source_root_realpath")
        }
        defer { free(resolvedRoot) }
        let canonicalRoot = String(cString: resolvedRoot)
        guard root.path == canonicalRoot else {
            throw Local300MError.rejected("source_root_alias")
        }
        let sourcePrefix = canonicalRoot + "/"
        var paths = ["Package.swift", "Tests/PrimeNativeDecoderTrainingValidation/Package.swift"]
        for relative in ["Sources", "Tests/PrimeNativeDecoderTrainingValidation/Sources"] {
            let base = root.appendingPathComponent(relative)
            guard let iterator = FileManager.default.enumerator(at: base,
                includingPropertiesForKeys: [.isRegularFileKey, .isDirectoryKey, .isSymbolicLinkKey])
            else { throw Local300MError.rejected("source_enumeration") }
            for case let url as URL in iterator {
                guard url.path.hasPrefix(sourcePrefix) else {
                    throw Local300MError.rejected("source_enumeration_prefix")
                }
                let value = try url.resourceValues(forKeys: [.isRegularFileKey, .isDirectoryKey, .isSymbolicLinkKey])
                guard value.isSymbolicLink != true else { throw Local300MError.rejected("source_symlink") }
                if value.isRegularFile == true {
                    paths.append(String(url.path.dropFirst(sourcePrefix.count)))
                } else if value.isDirectory != true { throw Local300MError.rejected("source_node") }
                guard paths.count <= 5000 else { throw Local300MError.rejected("source_count") }
            }
        }
        let resolved = "Tests/PrimeNativeDecoderTrainingValidation/Package.resolved"
        if FileManager.default.fileExists(atPath: root.appendingPathComponent(resolved).path) { paths.append(resolved) }
        return paths.sorted()
    }

    private static func readSource(_ url: URL, expectedCount: UInt64) throws -> Data {
        let fd = open(url.path, O_RDONLY | O_NOFOLLOW_ANY | O_CLOEXEC)
        guard fd >= 0 else { throw Local300MError.rejected("source_open_\(errno)") }
        defer { close(fd) }
        var before = stat()
        guard fstat(fd, &before) == 0, before.st_mode & S_IFMT == S_IFREG,
              before.st_uid == geteuid(), before.st_nlink == 1, before.st_size >= 0,
              UInt64(before.st_size) == expectedCount,
              [mode_t(0o444), 0o644, 0o555, 0o755].contains(before.st_mode & 0o7777)
        else { throw Local300MError.rejected("source_metadata") }
        let readStart = DispatchTime.now().uptimeNanoseconds; var interruptions = 0
        var bytes = Data(); var chunk = [UInt8](repeating: 0, count: 64 * 1024)
        while bytes.count < Int(expectedCount) {
            guard DispatchTime.now().uptimeNanoseconds - readStart < 30_000_000_000 else { throw Local300MError.rejected("source_read_deadline") }
            let amount = read(fd, &chunk, min(chunk.count, Int(expectedCount) - bytes.count))
            if amount < 0 && errno == EINTR { interruptions += 1; guard interruptions <= 8 else { throw Local300MError.rejected("source_read_interruptions") }; continue }
            guard amount > 0 else { throw Local300MError.rejected("source_read_\(errno)") }
            bytes.append(contentsOf: chunk.prefix(amount))
        }
        var after = stat(); var named = stat()
        guard fstat(fd, &after) == 0, lstat(url.path, &named) == 0,
              before.st_dev == after.st_dev, before.st_ino == after.st_ino,
              before.st_mode == after.st_mode, before.st_uid == after.st_uid,
              before.st_gid == after.st_gid, before.st_nlink == after.st_nlink,
              before.st_size == after.st_size,
              before.st_mtimespec.tv_sec == after.st_mtimespec.tv_sec,
              before.st_mtimespec.tv_nsec == after.st_mtimespec.tv_nsec,
              before.st_ctimespec.tv_sec == after.st_ctimespec.tv_sec,
              before.st_ctimespec.tv_nsec == after.st_ctimespec.tv_nsec,
              named.st_dev == after.st_dev, named.st_ino == after.st_ino,
              named.st_mode == after.st_mode, named.st_size == after.st_size
        else { throw Local300MError.rejected("source_rejoin") }
        return bytes
    }

    public func validateSources() throws {

        guard schema == "prime_current_local_native300m_launch_v1",
              !runID.isEmpty, runID.utf8.count <= 128,
              sourceCommitDeclaration.utf8.count == 40,
              sourceCommitDeclaration.utf8.allSatisfy({ (48...57).contains($0) || (97...102).contains($0) }),
              stage7WorkerSeconds == 4800, stage7SupervisorSeconds == 5100,
              stage8WorkerSeconds == 4800, stage8SupervisorSeconds == 5100,
              executableByteCount > 0, executableByteCount <= 256 * 1024 * 1024,
              executableSHA256.count == 64,
              [sourceRoot, runRoot, executableAbsolutePath].allSatisfy({ $0.hasPrefix("/") && !$0.contains("/../") && !$0.contains("/./") }),
              sourceFiles.map(\.relativePath) == (try Self.sourcePaths(root: URL(fileURLWithPath: sourceRoot))),
              sourceFiles.allSatisfy({ $0.purpose == .immutableData && $0.byteCount <= 16 * 1024 * 1024 })
        else { throw Local300MError.rejected("launch_shape_or_inventory") }
        try metallib.validate()
        _ = try PrimeArtifactRoot(directoryURL: URL(fileURLWithPath: sourceRoot))
        for file in sourceFiles {
            let data = try Self.readSource(URL(fileURLWithPath: sourceRoot).appendingPathComponent(file.relativePath), expectedCount: file.byteCount)
            guard PrimeSHA256.hexDigest(of: data) == file.sha256 else { throw Local300MError.rejected("source_hash_" + file.relativePath) }
        }
    }
}

public enum Local300MError: Error { case rejected(String) }

public struct PrimeCurrentLocalNative300MWorkerTicket: Codable {
    public let role: PrimeCurrentLocalNative300MRole
    public let launchSHA256: String
    public let supervisorPID: Int32
    public let workerPID: Int32
    public let sharedPhaseEpochNanoseconds: UInt64
    public let workerDeadlineNanoseconds: UInt64
    public let controllerDeadlineNanoseconds: UInt64
    public let inputResult: PrimeArtifactBinding?
    public let mappedImageJoined: Bool
    public let suspendedWorkingDirectoryJoined: Bool
}

private struct Local300MStream: Codable {
    let totalBytes: UInt64
    let capturedBytes: UInt64
    let reachedEOF: Bool
    let overflowed: Bool
    let readError: Int32
    let writeError: Int32
    let finalizationError: Int32
    let descriptorsClosed: Bool
    let outputSHA256: String
    let outputByteCount: UInt64
    let outputDeviceID: UInt64
    let outputInode: UInt64
    let terminalReason: String
    init(_ value: PrimeSecureChildFileBackedDrainSnapshot) {
        totalBytes = value.totalByteCount; capturedBytes = value.capturedByteCount
        reachedEOF = value.reachedEOF; overflowed = value.overflowed
        readError = value.readErrorNumber; writeError = value.writeErrorNumber
        finalizationError = value.finalizationErrorNumber; descriptorsClosed = value.descriptorsClosed
        outputSHA256 = value.outputSHA256; outputByteCount = value.outputByteCount
        outputDeviceID = value.outputDeviceID; outputInode = value.outputInode
        terminalReason = value.terminalReason.rawValue
    }
    var clean: Bool { reachedEOF && !overflowed && readError == 0 && writeError == 0 && finalizationError == 0 && descriptorsClosed && totalBytes == capturedBytes && capturedBytes == outputByteCount && terminalReason == "end_of_file" }
}

private struct Local300MProcessReceipt: Codable {
    let schema = "prime_current_local_native300m_process_v1"
    let role: PrimeCurrentLocalNative300MRole
    let launchSHA256: String
    let supervisorPID: Int32
    let workerPID: Int32
    let sessionIdentifier: Int32
    let processGroupIdentifier: Int32
    let epochNanoseconds: UInt64
    let deadlineNanoseconds: UInt64
    let spawnReturnedNanoseconds: UInt64
    let resumedNanoseconds: UInt64?
    let deathObservedNanoseconds: UInt64?
    let waitReturnedNanoseconds: UInt64?
    let returnedWaitPID: Int32?
    let rawWaitStatus: Int32?
    let exactReapCount: Int
    let cleanupInitiated: Bool
    let cleanupContained: Bool
    let failure: String?
    let standardOutput: Local300MStream
    let standardError: Local300MStream
}

/// One local supervisor owns a fixed next-only three-worker sequence. No decoded
/// ticket or scientific result constructs this retained process owner.
@available(macOS 26.0, *)
public final class PrimeCurrentLocalNative300MProcessControl {
    public let launch: PrimeCurrentLocalNative300MLaunch
    public let launchSHA256: String
    public let output: PrimeArtifactRoot
    private let executable: PrimeSecureHeldRunningExecutable
    private let working: PrimeArtifactRoot
    private let stopLock = NSLock()
    private var stopped = false
    private var ordinal = 0
    private let stage7Epoch: UInt64
    private var stage8Epoch: UInt64?
    private let launchPath: String

    public init(launchURL: URL) throws {
        let bytes = try Self.readBounded(launchURL, maximum: 64 * 1024 * 1024)
        launch = try PrimeCanonicalJSON.decode(PrimeCurrentLocalNative300MLaunch.self, from: bytes)
        try launch.validateSources()
        executable = try PrimeSecureRunningExecutableCapture.heldExecutable()
        guard executable.canonicalAbsolutePath == launch.executableAbsolutePath,
              executable.byteCount == launch.executableByteCount,
              PrimeSHA256.hexDigest(of: executable.data) == launch.executableSHA256
        else { throw Local300MError.rejected("current_image") }
        working = try PrimeArtifactRoot(directoryURL: URL(fileURLWithPath: launch.sourceRoot))
        output = try PrimeArtifactRoot(directoryURL: URL(fileURLWithPath: launch.runRoot))
        try output.requirePrivateRootMode(); try output.requireEmpty()
        for dir in ["artifacts", "control", "synchronization"] { try output.ensurePrivateDirectory(at: dir) }
        launchSHA256 = PrimeSHA256.hexDigest(of: bytes)
        _ = try output.publish(bytes, at: "launch.json", purpose: .immutableData)
        launchPath = launch.runRoot + "/launch.json"
        stage7Epoch = DispatchTime.now().uptimeNanoseconds
    }

    public func validateFinalBoundary() throws {
        guard ordinal == 3, let epoch = stage8Epoch, !stopRequested else { throw Local300MError.rejected("final_sequence_or_stop") }
        let deadline = try PrimeSecureChildPhaseDeadline(startUptimeNanoseconds: epoch, durationSeconds: 5100)
        try executable.revalidate(); try launch.validateSources()
        guard try deadline.authorizesNewWork(observedAtUptimeNanoseconds: DispatchTime.now().uptimeNanoseconds) else { throw Local300MError.rejected("final_controller_deadline") }
    }
    public func requestStop() { stopLock.lock(); stopped = true; stopLock.unlock() }
    private var stopRequested: Bool { stopLock.lock(); defer { stopLock.unlock() }; return stopped }

    public static func readBounded(_ url: URL, maximum: UInt64) throws -> Data {
        let root = try PrimeArtifactRoot(directoryURL: url.deletingLastPathComponent())
        let binding = try root.bindExisting(at: url.lastPathComponent, purpose: .immutableData, maximumByteCount: maximum)
        return try root.readVerified(binding, maximumByteCount: maximum)
    }

    public static func admitWorker(launchURL: URL, role: PrimeCurrentLocalNative300MRole) throws
        -> (PrimeCurrentLocalNative300MLaunch, PrimeCurrentLocalNative300MWorkerTicket) {
        let bytes = try readBounded(launchURL, maximum: 64 * 1024 * 1024)
        let launch = try PrimeCanonicalJSON.decode(PrimeCurrentLocalNative300MLaunch.self, from: bytes)
        try launch.validateSources()
        let ticketData = try readBounded(URL(fileURLWithPath: launch.runRoot + "/control/" + role.rawValue + "-start.json"), maximum: 64 * 1024)
        let ticket = try JSONDecoder().decode(PrimeCurrentLocalNative300MWorkerTicket.self, from: ticketData)
        let image = try PrimeSecureRunningExecutableCapture.heldExecutable()
        guard ticket.role == role, ticket.workerPID == getpid(), ticket.supervisorPID == getppid(),
              getsid(0) == ticket.supervisorPID, getpgrp() == getpid(),
              ticket.launchSHA256 == PrimeSHA256.hexDigest(of: bytes),
              ticket.mappedImageJoined, ticket.suspendedWorkingDirectoryJoined,
              image.canonicalAbsolutePath == launch.executableAbsolutePath,
              image.byteCount == launch.executableByteCount,
              PrimeSHA256.hexDigest(of: image.data) == launch.executableSHA256,
              DispatchTime.now().uptimeNanoseconds < ticket.workerDeadlineNanoseconds
        else { throw Local300MError.rejected("worker_native_parent_image_ticket") }
        return (launch, ticket)
    }

    /// The file-backed drain both writes and reads this held descriptor: its
    /// finalization hashes the exact retained bytes before closing it.
    static func createStreamDescriptor(at path: String) throws -> Int32 {
        let value = open(path, O_RDWR | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC, 0o600)
        guard value >= 0 else { throw Local300MError.rejected("stream_open_\(errno)") }
        return value
    }

    /// Returns only after exact reap and both persistent drains finish. Every
    /// failure permanently stops the sequence; cleanup gets no success budget.
    public func execute(_ role: PrimeCurrentLocalNative300MRole, inputResult: PrimeArtifactBinding? = nil) throws {
        guard ordinal < 3, PrimeCurrentLocalNative300MRole.allCases[ordinal] == role, !stopRequested
        else { throw Local300MError.rejected("sequence_or_stop") }
        var completed = false
        defer { if !completed { requestStop() } }
        let expectedInputPath: String? = role == .baseline ? nil : (role == .resume ? "stage7-baseline.json" : "stage7-result.json")
        guard inputResult?.relativePath == expectedInputPath,
              inputResult == nil || inputResult?.purpose == .immutableData
        else { throw Local300MError.rejected("input_binding_role") }
        if let inputResult { _ = try output.verify(inputResult) }
        ordinal += 1
        if role == .verify { stage8Epoch = DispatchTime.now().uptimeNanoseconds }
        let epoch = stage8Epoch ?? stage7Epoch
        let deadline = try PrimeSecureChildPhaseDeadline(startUptimeNanoseconds: epoch, durationSeconds: 4800)
        let controller = try PrimeSecureChildPhaseDeadline(startUptimeNanoseconds: epoch, durationSeconds: 5100)
        try launch.validateSources(); try executable.revalidate()
        guard try deadline.authorizesNewWork(observedAtUptimeNanoseconds: DispatchTime.now().uptimeNanoseconds)
        else { requestStop(); throw Local300MError.rejected("shared_worker_deadline") }
        let fd = try working.duplicateTrustedRootDescriptorForInventory(); defer { close(fd) }
        let cwd = try PrimeSecureChildDarwinProcessProof.snapshotHeldDirectory(descriptor: fd, openedWithNoSymbolicLinksInPath: true, context: .validationWorkingDirectory)
        let environment: [(String, String)] = [("HOME", launch.runRoot), ("LANG", "C"), ("LC_ALL", "C"), ("MLX_ENABLE_TF32", "0"), ("PATH", "/usr/bin:/bin"), ("TMPDIR", launch.runRoot + "/")]
        struct Prestart: Codable { let role: PrimeCurrentLocalNative300MRole; let executable: String; let arguments: [String]; let environment: [[String]]; let epoch: UInt64; let expires: UInt64; let launchSHA256: String }
        let arguments = ["--worker", role.rawValue, launchPath]
        _ = try output.publishCanonicalExclusively(Prestart(role: role, executable: launch.executableAbsolutePath, arguments: arguments, environment: environment.map { [$0.0, $0.1] }, epoch: epoch, expires: deadline.expiresAtUptimeNanoseconds, launchSHA256: launchSHA256), at: "control/" + role.rawValue + "-prestart.json")
        func stream(_ suffix: String) throws -> Int32 {
            try Self.createStreamDescriptor(at: launch.runRoot + "/control/" + role.rawValue + suffix)
        }
        let stdout = try stream("-stdout.log")
        let stderr: Int32
        do { stderr = try stream("-stderr.log") } catch { close(stdout); throw error }
        let spawned: PrimeSecureChildSpawnHandle
        do { spawned = try PrimeSecureChildDarwinSubstrate.spawnDriverV2FixedProbeSuspended(executableAbsolutePath: launch.executableAbsolutePath, argumentZero: launch.executableAbsolutePath, workingDirectoryDescriptor: fd, exactArguments: arguments, orderedEnvironment: environment) }
        catch { close(stdout); close(stderr); requestStop(); throw error }
        let owner = PrimeSecureChildSupervisionCapability.adoptFileBacked(spawn: spawned, phaseDeadline: deadline, standardOutputDescriptor: stdout, standardErrorDescriptor: stderr, maximumByteCount: 16 * 1024 * 1024)
        var resumed: UInt64?
        func persist(failure: String?, cleanup: Bool, contained: Bool) throws {
            guard case let .fileBacked(out, err) = owner.drainEvidence() else { throw Local300MError.rejected("drain_kind") }
            let wait = owner.exactPIDWaitObservation
            _ = try output.publishCanonicalExclusively(Local300MProcessReceipt(role: role, launchSHA256: launchSHA256, supervisorPID: getpid(), workerPID: owner.processIdentifier, sessionIdentifier: getpid(), processGroupIdentifier: owner.processIdentifier, epochNanoseconds: epoch, deadlineNanoseconds: deadline.expiresAtUptimeNanoseconds, spawnReturnedNanoseconds: owner.spawnReturnedMonotonicNanoseconds, resumedNanoseconds: resumed, deathObservedNanoseconds: owner.deathObservedMonotonicNanoseconds(), waitReturnedNanoseconds: wait?.returnedMonotonicNanoseconds, returnedWaitPID: wait?.returnedProcessIdentifier, rawWaitStatus: wait?.rawWaitStatus, exactReapCount: wait == nil ? 0 : 1, cleanupInitiated: cleanup, cleanupContained: contained, failure: failure, standardOutput: .init(out), standardError: .init(err)), at: "control/" + role.rawValue + "-terminal.json")
        }
        do {
            let pid = owner.processIdentifier
            guard owner.spawnReturnCode == 0, owner.establishDriverV2DedicatedGroupWithinSupervisorSession() == getpid()
            else { throw Local300MError.rejected("spawn_session") }
            let cwdProof = try PrimeSecureChildDarwinProcessProof.captureSuspendedWorkingDirectory(processIdentifier: pid, heldDirectory: cwd)
            _ = try PrimeSecureChildDarwinProcessProof.captureMappedExecutable(processIdentifier: pid, heldExecutable: PrimeSecureChildDarwinProcessProof.snapshotHeldExecutable(deviceID: executable.deviceID, inode: executable.inode, expectedCanonicalAbsolutePath: executable.canonicalAbsolutePath))
            _ = try output.publishCanonicalExclusively(PrimeCurrentLocalNative300MWorkerTicket(role: role, launchSHA256: launchSHA256, supervisorPID: getpid(), workerPID: pid, sharedPhaseEpochNanoseconds: epoch, workerDeadlineNanoseconds: deadline.expiresAtUptimeNanoseconds, controllerDeadlineNanoseconds: controller.expiresAtUptimeNanoseconds, inputResult: inputResult, mappedImageJoined: true, suspendedWorkingDirectoryJoined: cwdProof.exactDescriptorJoinObserved), at: "control/" + role.rawValue + "-start.json")
            let queue = kqueue()
            guard queue >= 0 else { throw Local300MError.rejected("death_queue_\(errno)") }
            defer { close(queue) }
            var registration = kevent(ident: UInt(pid), filter: Int16(EVFILT_PROC), flags: UInt16(EV_ADD | EV_ENABLE | EV_ONESHOT), fflags: UInt32(NOTE_EXIT), data: 0, udata: nil)
            guard kevent(queue, &registration, 1, nil, 0, nil) == 0 else { throw Local300MError.rejected("death_registration_\(errno)") }
            switch try owner.resume(notBeforeUptimeNanoseconds: DispatchTime.now().uptimeNanoseconds) {
            case let .resumed(time): resumed = time
            default: throw Local300MError.rejected("resume")
            }
            while true {
                if stopRequested { throw Local300MError.rejected("stop_requested") }
                guard try deadline.authorizesNewWork(observedAtUptimeNanoseconds: DispatchTime.now().uptimeNanoseconds) else { throw Local300MError.rejected("worker_deadline") }
                if case let .fileBacked(out, err) = owner.drainEvidence(), out.overflowed || err.overflowed { throw Local300MError.rejected("stream_overflow") }
                var event = kevent(); var timeout = timespec(tv_sec: 0, tv_nsec: 200_000_000)
                let observed = kevent(queue, nil, 0, &event, 1, &timeout)
                if observed < 0 && errno == EINTR { continue }
                guard observed >= 0 else { throw Local300MError.rejected("death_poll_\(errno)") }
                if observed == 1 {
                    guard event.ident == UInt(pid), event.filter == Int16(EVFILT_PROC), event.flags & UInt16(EV_ERROR) == 0, event.fflags & UInt32(NOTE_EXIT) != 0 else { throw Local300MError.rejected("death_event") }
                    break
                }
            }
            guard case .observed = try owner.observeDeath(), let death = owner.deathObservedMonotonicNanoseconds(),
                  case let .completed(.fileBacked(out, err)) = try owner.waitForPhaseDrainCompletion(notBeforeUptimeNanoseconds: death),
                  Local300MStream(out).clean, Local300MStream(err).clean,
                  owner.processGroupMemberIdentifiers() == [pid]
            else { throw Local300MError.rejected("death_drain_or_group") }
            switch owner.reapAfterObservedDeath() {
            case let .reaped(wait):
                guard wait.returnedProcessIdentifier == pid, wait.waitOptions == 0 else { throw Local300MError.rejected("exact_reap") }
                try persist(failure: wait.exitedNormally && wait.exitStatus == 0 ? nil : "worker_nonzero", cleanup: false, contained: true)
                guard wait.exitedNormally, wait.exitStatus == 0 else { requestStop(); throw Local300MError.rejected("worker_nonzero_\(wait.rawWaitStatus)") }
            case .mustFailStop:
                try? persist(failure: "reap_fail_stop", cleanup: true, contained: false)
                Darwin._exit(95)
            }
            try executable.revalidate(); try launch.validateSources()
            guard try controller.authorizesNewWork(observedAtUptimeNanoseconds: DispatchTime.now().uptimeNanoseconds) else { throw Local300MError.rejected("controller_deadline") }
            completed = true
        } catch {
            requestStop()
            let contained: Bool
            switch owner.cleanupRejectedCapture() { case .contained: contained = true; case .mustFailStop: contained = false }
            // A previously completed exact-reap receipt remains immutable.
            try? persist(failure: String(reflecting: error), cleanup: true, contained: contained)
            if !contained { Darwin._exit(95) }
            throw error
        }
    }
}
