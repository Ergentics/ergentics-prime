// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin
import Dispatch
import Foundation

enum PrimeValidationDriverV2IsolatedSpawnCanaryState:
    String,
    Equatable,
    Sendable
{
    case available
    case running
    case observed
    case poisoned
}

struct PrimeValidationDriverV2IsolatedSpawnCanaryObservation:
    Equatable,
    Sendable
{
    let processIdentifier: Int32
    let appliedSpawnFlags: UInt16
    let sessionIdentifier: Int32
    let processGroupIdentifier: Int32
    let resumedAtUptimeNanoseconds: UInt64
    let executableDeviceID: UInt64
    let executableInode: UInt64
    let executableByteCount: UInt64
    let executableSHA256: String
    let workingDirectoryDeviceID: UInt64
    let workingDirectoryInode: UInt64
    let mappedImageJoined: Bool
    let exactPIDWait:
        PrimeSecureChildExactPIDWaitObservation
    let standardOutputByteCount: UInt64
    let standardErrorByteCount: UInt64
    let standardOutputReachedEOF: Bool
    let standardErrorReachedEOF: Bool
    let processGroupEmptyAfterReap: Bool
    let combinedSourceWatcherDescriptorCount: Int
    let startLeafByteCount: UInt64
    let startLeafSHA256: String
    let terminalLeafByteCount: UInt64
    let terminalLeafSHA256: String
    let workspaceEmptyAfterReap: Bool
    let productionSupervisorImageEligible: Bool
}

/// Deterministic XCTest-only pause after durable start publication and before
/// the final continuity checkpoint. It carries no closure, path, role, child
/// plan, deadline, or production authority.
final class PrimeValidationDriverV2IsolatedSpawnCanaryTestInterlock:
    @unchecked Sendable
{
    private let lock = NSLock()
    private let startPublished = DispatchSemaphore(value: 0)
    private let resumePermitted = DispatchSemaphore(value: 0)
    private var publicationSignaled = false
    private var resumeSignaled = false

    func waitForDurableStartPublication() -> Bool {
        startPublished.wait(
            timeout: .now() + .seconds(5)
        ) == .success
    }

    func permitResume() {
        lock.lock()
        let shouldSignal = !resumeSignaled
        resumeSignaled = true
        lock.unlock()
        if shouldSignal { resumePermitted.signal() }
    }

    fileprivate func pauseBeforeFinalContinuityCheckpoint() throws {
        lock.lock()
        let shouldSignal = !publicationSignaled
        publicationSignaled = true
        lock.unlock()
        if shouldSignal { startPublished.signal() }
        guard resumePermitted.wait(
            timeout: .now() + .seconds(4)
        ) == .success else {
            throw primeValidationDriverV2CanaryRejected(
                "test_interlock_timeout"
            )
        }
    }
}

final class PrimeValidationDriverV2IsolatedSpawnCanaryHeldExecutable:
    @unchecked Sendable
{
    static let executableLeaf =
        "PrimeValidationWorkflowDriverV2SpawnCanary"
    static let expectedByteCount: UInt64 = 33_784
    static let expectedSHA256 =
        "ced48ad5cb41a3a2e13c779f57ca008b213425d6e02ea7dc827bdd6ddfd6988e"
    static let measuredMachOUUID =
        "2970B4C8-7A39-30C2-B576-383FF950C1D3"
    static let measuredPlatform = "macos"
    static let measuredMinimumOS = "14.0"
    static let measuredSDK = "26.5"
    static let measuredLoadCommandTranscriptSHA256 =
        "7b1ba98f32973d7c9a2ec356fcbadb0d4601d599261f4eee692c041dfc256474"

    let absolutePath: String
    private(set) var descriptor: Int32
    let snapshot:
        PrimeNativeNeuralGateExecutableDescriptorSnapshot

    static func production(
        retainedState:
            PrimeValidationSwiftPMRetainedGuardedPreExecutorState
    ) throws -> Self {
        guard retainedState.productionSupervisorImageEligible,
              URL(
                  fileURLWithPath:
                    retainedState.currentProcessImage
                    .canonicalAbsolutePath
              ).lastPathComponent
                == "PrimeValidationWorkflowDriverV2Supervisor"
        else {
            throw primeValidationDriverV2CanaryRejected(
                "production_supervisor_image"
            )
        }
        let supervisorURL = URL(
            fileURLWithPath:
                retainedState.currentProcessImage
                .canonicalAbsolutePath
        )
        let path = supervisorURL.deletingLastPathComponent()
            .appendingPathComponent(executableLeaf)
            .path
        let opened = Darwin.open(
            path,
            O_RDONLY | O_NOFOLLOW_ANY | O_CLOEXEC
        )
        guard opened >= 3 else {
            if opened >= 0 { _ = Darwin.close(opened) }
            throw primeValidationDriverV2CanaryRejected(
                "production_executable_open_\(errno)"
            )
        }
        return try Self(adopting: opened)
    }

    convenience init(duplicatingTestDescriptor descriptor: Int32) throws {
        let duplicated = fcntl(
            descriptor,
            F_DUPFD_CLOEXEC,
            3
        )
        guard duplicated >= 3 else {
            if duplicated >= 0 { _ = Darwin.close(duplicated) }
            throw primeValidationDriverV2CanaryRejected(
                "test_executable_duplicate_\(errno)"
            )
        }
        try self.init(adopting: duplicated)
    }

    private init(adopting descriptor: Int32) throws {
        self.descriptor = descriptor
        do {
            absolutePath = try Self.path(for: descriptor)
            snapshot = try Self.readSnapshot(
                descriptor: descriptor,
                absolutePath: absolutePath
            )
        } catch {
            _ = Darwin.close(descriptor)
            self.descriptor = -1
            throw error
        }
    }

    deinit {
        if descriptor >= 3 { _ = Darwin.close(descriptor) }
    }

    func revalidate() throws {
        let replay = try Self.readSnapshot(
            descriptor: descriptor,
            absolutePath: absolutePath
        )
        guard replay == snapshot else {
            throw primeValidationDriverV2CanaryRejected(
                "executable_changed"
            )
        }
    }

    private static func path(for descriptor: Int32) throws -> String {
        var information = vnode_fdinfowithpath()
        errno = 0
        let result = withUnsafeMutablePointer(to: &information) {
            proc_pidfdinfo(
                getpid(),
                descriptor,
                PROC_PIDFDVNODEPATHINFO,
                $0,
                Int32(MemoryLayout<vnode_fdinfowithpath>.size)
            )
        }
        var pathStorage = information.pvip.vip_path
        let value: String? = withUnsafeBytes(of: &pathStorage) { bytes in
            guard let terminator = bytes.firstIndex(of: 0),
                  terminator > 0,
                  terminator < bytes.count
            else { return nil }
            return String(
                bytes: bytes[0 ..< terminator],
                encoding: .utf8
            )
        }
        guard result
                == Int32(MemoryLayout<vnode_fdinfowithpath>.size),
              let value
        else {
            throw primeValidationDriverV2CanaryRejected(
                "executable_getpath_\(errno)"
            )
        }
        guard value.hasPrefix("/"),
              URL(fileURLWithPath: value).lastPathComponent
                == executableLeaf,
              try PrimeSecureChildPath.canonicalPath(value) == value
        else {
            throw primeValidationDriverV2CanaryRejected(
                "executable_path"
            )
        }
        return value
    }

    private static func readSnapshot(
        descriptor: Int32,
        absolutePath: String
    ) throws -> PrimeNativeNeuralGateExecutableDescriptorSnapshot {
        var before = stat()
        var named = stat()
        guard descriptor >= 3,
              fstat(descriptor, &before) == 0,
              lstat(absolutePath, &named) == 0,
              sameIdentity(before, named),
              before.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
              before.st_uid == geteuid(),
              before.st_nlink == 1,
              before.st_size > 0,
              UInt64(before.st_size) == expectedByteCount,
              before.st_mode & mode_t(0o7777) == mode_t(0o755),
              fcntl(descriptor, F_GETFD) & FD_CLOEXEC != 0
        else {
            throw primeValidationDriverV2CanaryRejected(
                "executable_metadata"
            )
        }
        do {
            try PrimeArtifactRoot
                .requireTrustedInventoryArtifactDescriptor(
                    descriptor,
                    path: absolutePath
                )
        } catch {
            throw primeValidationDriverV2CanaryRejected(
                "executable_trust"
            )
        }
        let data: Data
        do {
            data = try PrimeSecureChildPath.readExact(
                descriptor: descriptor,
                byteCount: Int(before.st_size)
            )
        } catch {
            throw primeValidationDriverV2CanaryRejected(
                "executable_read"
            )
        }
        var after = stat()
        guard PrimeSHA256.hexDigest(of: data) == expectedSHA256,
              fstat(descriptor, &after) == 0,
              sameIdentity(before, after)
        else {
            throw primeValidationDriverV2CanaryRejected(
                "executable_digest_or_change"
            )
        }
        return PrimeNativeNeuralGateExecutableDescriptorSnapshot(
            deviceID: UInt64(bitPattern: Int64(after.st_dev)),
            inode: UInt64(after.st_ino),
            byteCount: UInt64(after.st_size),
            sha256: expectedSHA256,
            ownerUserID: after.st_uid,
            ownerGroupID: after.st_gid,
            permissionMode: UInt16(after.st_mode & mode_t(0o7777)),
            linkCount: UInt64(after.st_nlink),
            modificationTimeSeconds: Int64(after.st_mtimespec.tv_sec),
            modificationTimeNanoseconds:
                Int64(after.st_mtimespec.tv_nsec),
            statusChangeTimeSeconds: Int64(after.st_ctimespec.tv_sec),
            statusChangeTimeNanoseconds:
                Int64(after.st_ctimespec.tv_nsec),
            regularFile: true,
            openedWithNoSymbolicLinksInPath: true,
            closeOnExec: true
        )
    }

    private static func sameIdentity(_ lhs: stat, _ rhs: stat) -> Bool {
        lhs.st_dev == rhs.st_dev
            && lhs.st_ino == rhs.st_ino
            && lhs.st_size == rhs.st_size
            && lhs.st_uid == rhs.st_uid
            && lhs.st_gid == rhs.st_gid
            && lhs.st_mode == rhs.st_mode
            && lhs.st_nlink == rhs.st_nlink
            && lhs.st_mtimespec.tv_sec == rhs.st_mtimespec.tv_sec
            && lhs.st_mtimespec.tv_nsec == rhs.st_mtimespec.tv_nsec
            && lhs.st_ctimespec.tv_sec == rhs.st_ctimespec.tv_sec
            && lhs.st_ctimespec.tv_nsec == rhs.st_ctimespec.tv_nsec
    }
}

private struct PrimeValidationDriverV2CanaryJournalLeaf:
    Equatable,
    Sendable
{
    let leaf: String
    let byteCount: UInt64
    let sha256: String
    let deviceID: UInt64
    let inode: UInt64
    let ownerUserID: UInt32
    let ownerGroupID: UInt32
    let permissionMode: UInt16
    let linkCount: UInt64
    let modificationTimeSeconds: Int64
    let modificationTimeNanoseconds: Int64
    let statusChangeTimeSeconds: Int64
    let statusChangeTimeNanoseconds: Int64
}

private final class PrimeValidationDriverV2CanaryJournal:
    @unchecked Sendable
{
    static let startLeaf = "v2-spawn-01-start.json"
    static let terminalLeaf = "v2-spawn-01-terminal.json"
    static let siblingSuffix = ".v2-spawn-01-journal"
    static let maximumLeafByteCount = 64 * 1024

    private let root: PrimeArtifactRoot
    private(set) var descriptor: Int32
    let absolutePath: String
    private var expectedRootIdentity: PrimeArtifactRootIdentity
    private var leaves: [String: PrimeValidationDriverV2CanaryJournalLeaf] =
        [:]
    private var heldLeafDescriptors: [String: Int32] = [:]

    init(
        retainedState:
            PrimeValidationSwiftPMRetainedGuardedPreExecutorState
    ) throws {
        let admission = retainedState.admission
        let workspace = admission.workspaceRoot.observation
        let path = workspace.canonicalAbsolutePath + Self.siblingSuffix
        let protectedPaths = [
            admission.primeRepository.observation.canonicalAbsolutePath,
            admission.companionRepository.observation.canonicalAbsolutePath,
            workspace.canonicalAbsolutePath,
            admission.evidenceRoot.observation.canonicalAbsolutePath,
            admission.leaseDirectory.observation.canonicalAbsolutePath,
        ]
        guard path.utf8.count <= Int(PATH_MAX) - 1,
              protectedPaths.allSatisfy({ Self.disjoint(path, $0) }),
              try PrimeSecureChildPath.canonicalPath(path) == path
        else {
            throw primeValidationDriverV2CanaryRejected("journal_path")
        }
        let openedRoot: PrimeArtifactRoot
        do {
            openedRoot = try PrimeArtifactRoot(
                directoryURL: URL(fileURLWithPath: path, isDirectory: true)
            )
            try openedRoot.requirePrivateRootMode()
            try openedRoot.requireEmpty()
        } catch {
            throw primeValidationDriverV2CanaryRejected("journal_root")
        }
        root = openedRoot
        absolutePath = path
        descriptor = try openedRoot
            .duplicateTrustedRootDescriptorForInventory()
        do {
            _ = try PrimeNativeNeuralGateHeldSourceClosure.requireLocalAPFS(
                rootDescriptor: descriptor
            )
        } catch {
            _ = Darwin.close(descriptor)
            descriptor = -1
            throw primeValidationDriverV2CanaryRejected(
                "journal_filesystem"
            )
        }
        do {
            expectedRootIdentity = try openedRoot.verifiedRootIdentity()
        } catch {
            _ = Darwin.close(descriptor)
            descriptor = -1
            throw primeValidationDriverV2CanaryRejected(
                "journal_root_identity"
            )
        }
        guard expectedRootIdentity.ownerUserID == geteuid(),
              expectedRootIdentity.ownerGroupID == workspace.ownerGroupID,
              expectedRootIdentity.actualMode == UInt16(0o700),
              expectedRootIdentity.linkCount == 2,
              fcntl(descriptor, F_GETFD) & FD_CLOEXEC != 0
        else {
            _ = Darwin.close(descriptor)
            descriptor = -1
            throw primeValidationDriverV2CanaryRejected(
                "journal_metadata"
            )
        }
        try revalidate(expectedLeafCount: 0)
    }

    deinit {
        for held in heldLeafDescriptors.values where held >= 3 {
            _ = Darwin.close(held)
        }
        if descriptor >= 3 { _ = Darwin.close(descriptor) }
    }

    func publishStart<Value: Encodable>(
        _ value: Value
    ) throws -> PrimeValidationDriverV2CanaryJournalLeaf {
        try publish(
            value,
            leaf: Self.startLeaf,
            expectedPriorCount: 0
        )
    }

    func publishTerminal<Value: Encodable>(
        _ value: Value
    ) throws -> PrimeValidationDriverV2CanaryJournalLeaf {
        guard leaves[Self.startLeaf] != nil else {
            throw primeValidationDriverV2CanaryRejected(
                "terminal_without_start"
            )
        }
        return try publish(
            value,
            leaf: Self.terminalLeaf,
            expectedPriorCount: 1
        )
    }

    func revalidateStarted() throws {
        try revalidate(expectedLeafCount: 1)
        guard leaves[Self.startLeaf] != nil,
              leaves[Self.terminalLeaf] == nil
        else {
            throw primeValidationDriverV2CanaryRejected(
                "journal_started_state"
            )
        }
    }

    func revalidateTerminal() throws {
        try revalidate(expectedLeafCount: 2)
        guard leaves[Self.startLeaf] != nil,
              leaves[Self.terminalLeaf] != nil
        else {
            throw primeValidationDriverV2CanaryRejected(
                "journal_terminal_state"
            )
        }
    }

    private func publish<Value: Encodable>(
        _ value: Value,
        leaf: String,
        expectedPriorCount: Int
    ) throws -> PrimeValidationDriverV2CanaryJournalLeaf {
        try revalidate(expectedLeafCount: expectedPriorCount)
        guard leaves[leaf] == nil else {
            throw primeValidationDriverV2CanaryRejected(
                "journal_leaf_reused"
            )
        }
        var data: Data
        do {
            data = try PrimeCanonicalJSON.encode(value)
        } catch {
            throw primeValidationDriverV2CanaryRejected(
                "journal_canonical_encoding"
            )
        }
        data.append(0x0a)
        guard !data.isEmpty,
              data.count <= Self.maximumLeafByteCount
        else {
            throw primeValidationDriverV2CanaryRejected(
                "journal_leaf_size"
            )
        }
        let opened = leaf.withCString {
            openat(
                descriptor,
                $0,
                O_RDWR | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC,
                mode_t(0o600)
            )
        }
        guard opened >= 3 else {
            if opened >= 0 { _ = Darwin.close(opened) }
            throw primeValidationDriverV2CanaryRejected(
                "journal_leaf_open_\(errno)"
            )
        }
        defer { _ = Darwin.close(opened) }
        var created = stat()
        guard fstat(opened, &created) == 0,
              created.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
              created.st_uid == geteuid(),
              created.st_gid == expectedRootIdentity.ownerGroupID,
              created.st_nlink == 1,
              created.st_mode & mode_t(0o7777) == mode_t(0o600),
              created.st_size == 0,
              fcntl(opened, F_GETFD) & FD_CLOEXEC != 0
        else {
            throw primeValidationDriverV2CanaryRejected(
                "journal_leaf_created_metadata"
            )
        }
        try Self.writeAll(data, descriptor: opened)
        try Self.synchronize(opened, detail: "journal_leaf_data")
        guard fchmod(opened, mode_t(0o400)) == 0 else {
            throw primeValidationDriverV2CanaryRejected(
                "journal_leaf_chmod_\(errno)"
            )
        }
        try Self.synchronize(opened, detail: "journal_leaf_read_only")
        try Self.synchronize(descriptor, detail: "journal_namespace")

        var frozen = stat()
        guard fstat(opened, &frozen) == 0,
              frozen.st_dev == created.st_dev,
              frozen.st_ino == created.st_ino,
              frozen.st_uid == created.st_uid,
              frozen.st_gid == created.st_gid,
              frozen.st_nlink == 1,
              frozen.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
              frozen.st_mode & mode_t(0o7777) == mode_t(0o400),
              frozen.st_size == off_t(data.count)
        else {
            throw primeValidationDriverV2CanaryRejected(
                "journal_leaf_frozen_metadata"
            )
        }
        let rebound = leaf.withCString {
            openat(
                descriptor,
                $0,
                O_RDONLY | O_NOFOLLOW | O_CLOEXEC
            )
        }
        guard rebound >= 3 else {
            if rebound >= 0 { _ = Darwin.close(rebound) }
            throw primeValidationDriverV2CanaryRejected(
                "journal_leaf_reopen_\(errno)"
            )
        }
        var reboundRetained = false
        defer {
            if !reboundRetained { _ = Darwin.close(rebound) }
        }
        var reboundStatus = stat()
        let reboundData: Data
        do {
            reboundData = try PrimeSecureChildPath.readExact(
                descriptor: rebound,
                byteCount: data.count
            )
        } catch {
            throw primeValidationDriverV2CanaryRejected(
                "journal_leaf_readback"
            )
        }
        guard fstat(rebound, &reboundStatus) == 0,
              reboundStatus.st_dev == frozen.st_dev,
              reboundStatus.st_ino == frozen.st_ino,
              reboundStatus.st_mode == frozen.st_mode,
              reboundStatus.st_size == frozen.st_size,
              fcntl(rebound, F_GETFL) & O_ACCMODE == O_RDONLY,
              fcntl(rebound, F_GETFD) & FD_CLOEXEC != 0,
              reboundData == data
        else {
            throw primeValidationDriverV2CanaryRejected(
                "journal_leaf_rebound"
            )
        }
        let binding = PrimeValidationDriverV2CanaryJournalLeaf(
            leaf: leaf,
            byteCount: UInt64(data.count),
            sha256: PrimeSHA256.hexDigest(of: data),
            deviceID: UInt64(bitPattern: Int64(frozen.st_dev)),
            inode: UInt64(frozen.st_ino),
            ownerUserID: frozen.st_uid,
            ownerGroupID: frozen.st_gid,
            permissionMode:
                UInt16(frozen.st_mode & mode_t(0o7777)),
            linkCount: UInt64(frozen.st_nlink),
            modificationTimeSeconds:
                Int64(frozen.st_mtimespec.tv_sec),
            modificationTimeNanoseconds:
                Int64(frozen.st_mtimespec.tv_nsec),
            statusChangeTimeSeconds:
                Int64(frozen.st_ctimespec.tv_sec),
            statusChangeTimeNanoseconds:
                Int64(frozen.st_ctimespec.tv_nsec)
        )
        leaves[leaf] = binding
        heldLeafDescriptors[leaf] = rebound
        reboundRetained = true
        try acceptAuthorizedRootTransition(
            expectedLeafCount: expectedPriorCount + 1
        )
        return binding
    }

    private func revalidate(expectedLeafCount: Int) throws {
        guard leaves.count == expectedLeafCount else {
            throw primeValidationDriverV2CanaryRejected(
                "journal_ledger_count"
            )
        }
        var current = stat()
        guard descriptor >= 3,
              fstat(descriptor, &current) == 0,
              Self.matchesRoot(current, expectedRootIdentity),
              fcntl(descriptor, F_GETFD) & FD_CLOEXEC != 0
        else {
            throw primeValidationDriverV2CanaryRejected(
                "journal_descriptor_changed"
            )
        }
        let rebound: PrimeArtifactRoot
        do {
            rebound = try PrimeArtifactRoot(
                directoryURL: URL(
                    fileURLWithPath: absolutePath,
                    isDirectory: true
                )
            )
        } catch {
            throw primeValidationDriverV2CanaryRejected(
                "journal_named_rebound"
            )
        }
        let reboundIdentity: PrimeArtifactRootIdentity
        do {
            reboundIdentity = try rebound.verifiedRootIdentity()
        } catch {
            throw primeValidationDriverV2CanaryRejected(
                "journal_named_identity"
            )
        }
        guard reboundIdentity == expectedRootIdentity,
              try inventory() == Set(leaves.keys)
        else {
            throw primeValidationDriverV2CanaryRejected(
                "journal_inventory"
            )
        }
        for binding in leaves.values {
            try verify(binding)
        }
    }

    private func acceptAuthorizedRootTransition(
        expectedLeafCount: Int
    ) throws {
        guard leaves.count == expectedLeafCount,
              heldLeafDescriptors.count == expectedLeafCount,
              try inventory() == Set(leaves.keys)
        else {
            throw primeValidationDriverV2CanaryRejected(
                "journal_authorized_inventory"
            )
        }
        let before = try root.verifiedRootIdentity()
        guard Self.sameStableRootCapability(
            before,
            expectedRootIdentity,
            expectedLeafCount: expectedLeafCount
        ) else {
            throw primeValidationDriverV2CanaryRejected(
                "journal_authorized_root"
            )
        }
        for binding in leaves.values { try verify(binding) }
        let after = try root.verifiedRootIdentity()
        guard after == before else {
            throw primeValidationDriverV2CanaryRejected(
                "journal_authorized_root_changed"
            )
        }
        let rebound = try PrimeArtifactRoot(
            directoryURL: URL(
                fileURLWithPath: absolutePath,
                isDirectory: true
            )
        ).verifiedRootIdentity()
        guard rebound == after else {
            throw primeValidationDriverV2CanaryRejected(
                "journal_authorized_root_rebound"
            )
        }
        expectedRootIdentity = after
    }

    private func inventory() throws -> Set<String> {
        let duplicate = fcntl(descriptor, F_DUPFD_CLOEXEC, 3)
        guard duplicate >= 3,
              lseek(duplicate, 0, SEEK_SET) >= 0,
              let directory = fdopendir(duplicate)
        else {
            if duplicate >= 0 { _ = Darwin.close(duplicate) }
            throw primeValidationDriverV2CanaryRejected(
                "journal_inventory_open"
            )
        }
        defer { _ = closedir(directory) }
        var values = Set<String>()
        errno = 0
        while let entry = readdir(directory) {
            let name = withUnsafePointer(to: entry.pointee.d_name) {
                $0.withMemoryRebound(
                    to: CChar.self,
                    capacity: Int(MAXNAMLEN) + 1
                ) { String(cString: $0) }
            }
            if name != "." && name != ".." {
                guard name == Self.startLeaf || name == Self.terminalLeaf,
                      values.insert(name).inserted
                else {
                    throw primeValidationDriverV2CanaryRejected(
                        "journal_inventory_entry"
                    )
                }
            }
            errno = 0
        }
        guard errno == 0 else {
            throw primeValidationDriverV2CanaryRejected(
                "journal_inventory_read_\(errno)"
            )
        }
        return values
    }

    private func verify(
        _ binding: PrimeValidationDriverV2CanaryJournalLeaf
    ) throws {
        guard let held = heldLeafDescriptors[binding.leaf],
              held >= 3
        else {
            throw primeValidationDriverV2CanaryRejected(
                "journal_verify_held_missing"
            )
        }
        let opened = binding.leaf.withCString {
            openat(
                descriptor,
                $0,
                O_RDONLY | O_NOFOLLOW | O_CLOEXEC
            )
        }
        guard opened >= 3 else {
            if opened >= 0 { _ = Darwin.close(opened) }
            throw primeValidationDriverV2CanaryRejected(
                "journal_verify_open"
            )
        }
        defer { _ = Darwin.close(opened) }
        var heldStatus = stat()
        var namedStatus = stat()
        guard fstat(held, &heldStatus) == 0,
              fstat(opened, &namedStatus) == 0,
              Self.matchesLeaf(heldStatus, binding),
              Self.matchesLeaf(namedStatus, binding),
              fcntl(held, F_GETFL) & O_ACCMODE == O_RDONLY,
              fcntl(held, F_GETFD) & FD_CLOEXEC != 0,
              fcntl(opened, F_GETFL) & O_ACCMODE == O_RDONLY,
              fcntl(opened, F_GETFD) & FD_CLOEXEC != 0,
              binding.byteCount <= UInt64(Self.maximumLeafByteCount)
        else {
            throw primeValidationDriverV2CanaryRejected(
                "journal_verify_metadata"
            )
        }
        do {
            try PrimeArtifactRoot
                .requireTrustedInventoryArtifactDescriptor(
                    held,
                    path: absolutePath + "/" + binding.leaf
                )
            try PrimeArtifactRoot
                .requireTrustedInventoryArtifactDescriptor(
                    opened,
                    path: absolutePath + "/" + binding.leaf
                )
        } catch {
            throw primeValidationDriverV2CanaryRejected(
                "journal_verify_trust"
            )
        }
        let heldData: Data
        let namedData: Data
        do {
            heldData = try PrimeSecureChildPath.readExact(
                descriptor: held,
                byteCount: Int(binding.byteCount)
            )
            namedData = try PrimeSecureChildPath.readExact(
                descriptor: opened,
                byteCount: Int(binding.byteCount)
            )
        } catch {
            throw primeValidationDriverV2CanaryRejected(
                "journal_verify_read"
            )
        }
        guard heldData == namedData,
              heldData.last == 0x0a,
              PrimeSHA256.hexDigest(of: heldData) == binding.sha256
        else {
            throw primeValidationDriverV2CanaryRejected(
                "journal_verify_digest"
            )
        }
    }

    private static func matchesRoot(
        _ status: stat,
        _ identity: PrimeArtifactRootIdentity
    ) -> Bool {
        status.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR)
            && UInt64(bitPattern: Int64(status.st_dev)) == identity.deviceID
            && UInt64(status.st_ino) == identity.inode
            && status.st_uid == identity.ownerUserID
            && status.st_gid == identity.ownerGroupID
            && UInt16(status.st_mode & mode_t(0o7777))
                == identity.actualMode
            && UInt64(status.st_nlink) == identity.linkCount
            && Int64(status.st_mtimespec.tv_sec)
                == identity.modificationSeconds
            && Int64(status.st_mtimespec.tv_nsec)
                == identity.modificationNanoseconds
            && Int64(status.st_ctimespec.tv_sec)
                == identity.statusChangeSeconds
            && Int64(status.st_ctimespec.tv_nsec)
                == identity.statusChangeNanoseconds
    }

    private static func sameStableRootCapability(
        _ lhs: PrimeArtifactRootIdentity,
        _ rhs: PrimeArtifactRootIdentity,
        expectedLeafCount: Int
    ) -> Bool {
        guard expectedLeafCount == 1 || expectedLeafCount == 2 else {
            return false
        }
        let priorLinkCount = UInt64(expectedLeafCount + 1)
        let currentLinkCount = UInt64(expectedLeafCount + 2)
        return lhs.deviceID == rhs.deviceID
            && lhs.inode == rhs.inode
            && lhs.ownerUserID == rhs.ownerUserID
            && lhs.ownerGroupID == rhs.ownerGroupID
            && lhs.actualMode == rhs.actualMode
            && rhs.linkCount == priorLinkCount
            && lhs.linkCount == currentLinkCount
    }

    private static func matchesLeaf(
        _ status: stat,
        _ binding: PrimeValidationDriverV2CanaryJournalLeaf
    ) -> Bool {
        status.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG)
            && UInt64(bitPattern: Int64(status.st_dev)) == binding.deviceID
            && UInt64(status.st_ino) == binding.inode
            && status.st_uid == binding.ownerUserID
            && status.st_gid == binding.ownerGroupID
            && UInt16(status.st_mode & mode_t(0o7777))
                == binding.permissionMode
            && UInt64(status.st_nlink) == binding.linkCount
            && UInt64(status.st_size) == binding.byteCount
            && Int64(status.st_mtimespec.tv_sec)
                == binding.modificationTimeSeconds
            && Int64(status.st_mtimespec.tv_nsec)
                == binding.modificationTimeNanoseconds
            && Int64(status.st_ctimespec.tv_sec)
                == binding.statusChangeTimeSeconds
            && Int64(status.st_ctimespec.tv_nsec)
                == binding.statusChangeTimeNanoseconds
    }

    private static func writeAll(
        _ data: Data,
        descriptor: Int32
    ) throws {
        var offset = 0
        try data.withUnsafeBytes { bytes in
            while offset < bytes.count {
                let result = Darwin.write(
                    descriptor,
                    bytes.baseAddress!.advanced(by: offset),
                    bytes.count - offset
                )
                if result < 0 && errno == EINTR { continue }
                guard result > 0 else {
                    throw primeValidationDriverV2CanaryRejected(
                        "journal_write_\(errno)"
                    )
                }
                offset += result
            }
        }
    }

    private static func synchronize(
        _ descriptor: Int32,
        detail: String
    ) throws {
        guard fsync(descriptor) == 0,
              fcntl(descriptor, F_FULLFSYNC) == 0
        else {
            throw primeValidationDriverV2CanaryRejected(
                "\(detail)_sync_\(errno)"
            )
        }
    }

    private static func disjoint(_ lhs: String, _ rhs: String) -> Bool {
        lhs != rhs
            && !lhs.hasPrefix(rhs + "/")
            && !rhs.hasPrefix(lhs + "/")
    }
}

private struct PrimeValidationDriverV2CanaryStartRecordV1: Encodable {
    let schema = "prime_driver_v2_isolated_spawn_canary_start_v1"
    let stage = "V2-SPAWN-01"
    let embeddedPrimeSourceIdentitySHA256: String
    let processIdentifier: Int32
    let sessionIdentifier: Int32
    let processGroupIdentifier: Int32
    let appliedSpawnFlags: UInt16
    let spawnReturnCode: Int32
    let spawnReturnedUptimeNanoseconds: UInt64
    let deadlineStartedAtUptimeNanoseconds: UInt64
    let deadlineExpiresAtUptimeNanoseconds: UInt64
    let executableDeviceID: UInt64
    let executableInode: UInt64
    let executableByteCount: UInt64
    let executableSHA256: String
    let workingDirectoryDeviceID: UInt64
    let workingDirectoryInode: UInt64
    let childWorkingDirectoryDeviceID: UInt64
    let childWorkingDirectoryInode: UInt64
    let exactWorkingDirectoryJoin: Bool
    let mappedExecutablePathTelemetry: String
    let mappedExecutableQueryCount: Int
    let mappedExecutableTerminalErrno: Int32
    let exactMappedExecutableJoin: Bool
    let combinedSourceWatcherDescriptorCount: Int

    private enum CodingKeys: String, CodingKey {
        case schema
        case stage
        case embeddedPrimeSourceIdentitySHA256 =
            "embedded_prime_source_identity_sha256"
        case processIdentifier = "process_identifier"
        case sessionIdentifier = "session_identifier"
        case processGroupIdentifier = "process_group_identifier"
        case appliedSpawnFlags = "applied_spawn_flags"
        case spawnReturnCode = "spawn_return_code"
        case spawnReturnedUptimeNanoseconds =
            "spawn_returned_uptime_nanoseconds"
        case deadlineStartedAtUptimeNanoseconds =
            "deadline_started_at_uptime_nanoseconds"
        case deadlineExpiresAtUptimeNanoseconds =
            "deadline_expires_at_uptime_nanoseconds"
        case executableDeviceID = "executable_device_id"
        case executableInode = "executable_inode"
        case executableByteCount = "executable_byte_count"
        case executableSHA256 = "executable_sha256"
        case workingDirectoryDeviceID = "working_directory_device_id"
        case workingDirectoryInode = "working_directory_inode"
        case childWorkingDirectoryDeviceID =
            "child_working_directory_device_id"
        case childWorkingDirectoryInode =
            "child_working_directory_inode"
        case exactWorkingDirectoryJoin = "exact_working_directory_join"
        case mappedExecutablePathTelemetry =
            "mapped_executable_path_telemetry"
        case mappedExecutableQueryCount = "mapped_executable_query_count"
        case mappedExecutableTerminalErrno =
            "mapped_executable_terminal_errno"
        case exactMappedExecutableJoin = "exact_mapped_executable_join"
        case combinedSourceWatcherDescriptorCount =
            "combined_source_watcher_descriptor_count"
    }
}

private struct PrimeValidationDriverV2CanaryTerminalRecordV1: Encodable {
    let schema = "prime_driver_v2_isolated_spawn_canary_terminal_v1"
    let stage = "V2-SPAWN-01"
    let startLeafByteCount: UInt64
    let startLeafSHA256: String
    let processIdentifier: Int32
    let resumedAtUptimeNanoseconds: UInt64
    let requestedWaitProcessIdentifier: Int32
    let returnedWaitProcessIdentifier: Int32
    let waitOptions: Int32
    let rawWaitStatus: Int32
    let waitReturnedUptimeNanoseconds: UInt64
    let exitedNormally: Bool
    let exitStatus: Int32
    let terminationSignal: Int32
    let coreDumped: Bool
    let standardOutputByteCount: UInt64
    let standardOutputReachedEOF: Bool
    let standardOutputDescriptorsClosed: Bool
    let standardErrorByteCount: UInt64
    let standardErrorReachedEOF: Bool
    let standardErrorDescriptorsClosed: Bool
    let processGroupEmptyAfterReap: Bool
    let postReapContinuityRevalidated: Bool
    let workspaceEmptyAfterReap: Bool
    let combinedSourceWatcherDescriptorCount: Int

    private enum CodingKeys: String, CodingKey {
        case schema
        case stage
        case startLeafByteCount = "start_leaf_byte_count"
        case startLeafSHA256 = "start_leaf_sha256"
        case processIdentifier = "process_identifier"
        case resumedAtUptimeNanoseconds = "resumed_at_uptime_nanoseconds"
        case requestedWaitProcessIdentifier =
            "requested_wait_process_identifier"
        case returnedWaitProcessIdentifier =
            "returned_wait_process_identifier"
        case waitOptions = "wait_options"
        case rawWaitStatus = "raw_wait_status"
        case waitReturnedUptimeNanoseconds =
            "wait_returned_uptime_nanoseconds"
        case exitedNormally = "exited_normally"
        case exitStatus = "exit_status"
        case terminationSignal = "termination_signal"
        case coreDumped = "core_dumped"
        case standardOutputByteCount = "standard_output_byte_count"
        case standardOutputReachedEOF = "standard_output_reached_eof"
        case standardOutputDescriptorsClosed =
            "standard_output_descriptors_closed"
        case standardErrorByteCount = "standard_error_byte_count"
        case standardErrorReachedEOF = "standard_error_reached_eof"
        case standardErrorDescriptorsClosed =
            "standard_error_descriptors_closed"
        case processGroupEmptyAfterReap = "process_group_empty_after_reap"
        case postReapContinuityRevalidated =
            "post_reap_continuity_revalidated"
        case workspaceEmptyAfterReap = "workspace_empty_after_reap"
        case combinedSourceWatcherDescriptorCount =
            "combined_source_watcher_descriptor_count"
    }
}

enum PrimeValidationDriverV2IsolatedSpawnCanaryExecutor {
    static let logicalArgumentZero = "prime-driver-v2-spawn-canary-v1"
    static let maximumWallNanoseconds: UInt64 = 5_000_000_000
    static let streamMaximumByteCount: UInt64 = 4_096
    static let drainChunkByteCount = 4_096
    static let requiredSpawnFlags: UInt16 = 0x448c

    @available(macOS 26.0, *)
    static func execute(
        retainedState:
            PrimeValidationSwiftPMRetainedGuardedPreExecutorState,
        testHeldExecutable:
            PrimeValidationDriverV2IsolatedSpawnCanaryHeldExecutable?,
        testInterlock:
            PrimeValidationDriverV2IsolatedSpawnCanaryTestInterlock?
    ) throws -> PrimeValidationDriverV2IsolatedSpawnCanaryObservation {
        let deadline: PrimeSecureChildPhaseDeadline
        do {
            deadline = try PrimeSecureChildPhaseDeadline(
                startUptimeNanoseconds:
                    DispatchTime.now().uptimeNanoseconds,
                durationNanoseconds: maximumWallNanoseconds
            )
        } catch {
            throw primeValidationDriverV2CanaryRejected(
                "deadline_overflow"
            )
        }
        try retainedState.revalidate()
        let executable = try testHeldExecutable
            ?? .production(retainedState: retainedState)
        try executable.revalidate()
        let workingDescriptor = try retainedState.admission.workspaceRoot.root
            .duplicateTrustedRootDescriptorForInventory()
        defer { _ = Darwin.close(workingDescriptor) }
        let workingSnapshot:
            PrimeSecureChildDarwinProcessProof.HeldDirectorySnapshot
        do {
            workingSnapshot = try PrimeSecureChildDarwinProcessProof
                .snapshotHeldDirectory(
                    descriptor: workingDescriptor,
                    openedWithNoSymbolicLinksInPath: true,
                    context: .validationWorkingDirectory
                )
        } catch {
            throw primeValidationDriverV2CanaryRejected(
                "working_directory_snapshot"
            )
        }
        let journal = try PrimeValidationDriverV2CanaryJournal(
            retainedState: retainedState
        )
        try retainedState.revalidate()
        try executable.revalidate()
        do {
            try PrimeSecureChildDarwinProcessProof
                .requireHeldDirectoryUnchanged(workingSnapshot)
        } catch {
            throw primeValidationDriverV2CanaryRejected(
                "working_directory_changed"
            )
        }
        guard try deadline.authorizesNewWork(
            observedAtUptimeNanoseconds:
                DispatchTime.now().uptimeNanoseconds
        ) else {
            throw primeValidationDriverV2CanaryRejected(
                "deadline_before_spawn"
            )
        }

        let spawn: PrimeSecureChildSpawnHandle
        do {
            spawn = try PrimeSecureChildDarwinSubstrate.spawnSuspended(
                executableAbsolutePath: executable.absolutePath,
                argumentZero: logicalArgumentZero,
                workingDirectoryDescriptor: workingDescriptor,
                exactArguments: [],
                orderedEnvironment: []
            )
        } catch let rejection as PrimeSecureChildDarwinSubstrate.Rejection {
            throw primeValidationDriverV2CanaryRejected(rejection.detail)
        }
        let supervision = PrimeSecureChildSupervisionCapability.adoptMemory(
            spawn: spawn,
            phaseDeadline: deadline,
            standardOutputMaximumByteCount: streamMaximumByteCount,
            standardErrorMaximumByteCount: streamMaximumByteCount,
            chunkByteCount: drainChunkByteCount
        )

        do {
            guard supervision.appliedFlags == requiredSpawnFlags,
                  supervision.spawnReturnCode == 0,
                  supervision.establishIsolatedSessionAndDedicatedGroup()
            else {
                throw primeValidationDriverV2CanaryRejected(
                    "spawn_or_group"
                )
            }
            let pid = supervision.processIdentifier
            let cwdProof: PrimeSecureChildDarwinProcessProof
                .SuspendedWorkingDirectoryProof
            let mappedProof: PrimeSecureChildDarwinProcessProof
                .MappedExecutableProof
            do {
                cwdProof = try PrimeSecureChildDarwinProcessProof
                    .captureSuspendedWorkingDirectory(
                        processIdentifier: pid,
                        heldDirectory: workingSnapshot
                    )
                mappedProof = try PrimeSecureChildDarwinProcessProof
                    .captureMappedExecutable(
                        processIdentifier: pid,
                        heldExecutable:
                            try PrimeSecureChildDarwinProcessProof
                            .snapshotHeldExecutable(
                                deviceID: executable.snapshot.deviceID,
                                inode: executable.snapshot.inode,
                                expectedCanonicalAbsolutePath:
                                    executable.absolutePath
                            )
                    )
            } catch let rejection as
                PrimeSecureChildDarwinProcessProof.Rejection
            {
                throw primeValidationDriverV2CanaryRejected(
                    rejection.detail
                )
            }
            try executable.revalidate()
            try retainedState.revalidate()
            do {
                try PrimeSecureChildDarwinProcessProof
                    .requireHeldDirectoryUnchanged(workingSnapshot)
            } catch {
                throw primeValidationDriverV2CanaryRejected(
                    "working_directory_changed_before_start"
                )
            }
            let watcherCount =
                retainedState.combinedSourceWatcherDescriptorCount
            let start = try journal.publishStart(
                PrimeValidationDriverV2CanaryStartRecordV1(
                    embeddedPrimeSourceIdentitySHA256:
                        PrimeEmbeddedBuildProvenance.sourceIdentitySHA256,
                    processIdentifier: pid,
                    sessionIdentifier: pid,
                    processGroupIdentifier: pid,
                    appliedSpawnFlags: supervision.appliedFlags,
                    spawnReturnCode: supervision.spawnReturnCode,
                    spawnReturnedUptimeNanoseconds:
                        supervision.spawnReturnedMonotonicNanoseconds,
                    deadlineStartedAtUptimeNanoseconds:
                        deadline.startUptimeNanoseconds,
                    deadlineExpiresAtUptimeNanoseconds:
                        deadline.expiresAtUptimeNanoseconds,
                    executableDeviceID: executable.snapshot.deviceID,
                    executableInode: executable.snapshot.inode,
                    executableByteCount: executable.snapshot.byteCount,
                    executableSHA256: executable.snapshot.sha256,
                    workingDirectoryDeviceID:
                        workingSnapshot.deviceID,
                    workingDirectoryInode: workingSnapshot.inode,
                    childWorkingDirectoryDeviceID:
                        cwdProof.suspendedChildCurrentDirectoryDeviceID,
                    childWorkingDirectoryInode:
                        cwdProof.suspendedChildCurrentDirectoryInode,
                    exactWorkingDirectoryJoin:
                        cwdProof.exactDescriptorJoinObserved,
                    mappedExecutablePathTelemetry:
                        mappedProof.mappedExecutablePathTelemetry,
                    mappedExecutableQueryCount: mappedProof.queries.count,
                    mappedExecutableTerminalErrno:
                        mappedProof.terminalErrno,
                    exactMappedExecutableJoin: true,
                    combinedSourceWatcherDescriptorCount: watcherCount
                )
            )
            let startPublishedAt =
                DispatchTime.now().uptimeNanoseconds
            try testInterlock?
                .pauseBeforeFinalContinuityCheckpoint()
            try retainedState.revalidate()
            try executable.revalidate()
            try journal.revalidateStarted()
            do {
                try PrimeSecureChildDarwinProcessProof
                    .requireHeldDirectoryUnchanged(workingSnapshot)
            } catch {
                throw primeValidationDriverV2CanaryRejected(
                    "working_directory_changed_before_resume"
                )
            }
            let resumedAt: UInt64
            switch try supervision.resume(
                notBeforeUptimeNanoseconds: startPublishedAt
            ) {
            case let .resumed(deliveredAtUptimeNanoseconds):
                resumedAt = deliveredAtUptimeNanoseconds
            case .deadlineExpired:
                throw primeValidationDriverV2CanaryRejected(
                    "deadline_before_resume"
                )
            case let .signalFailed(errorNumber):
                throw primeValidationDriverV2CanaryRejected(
                    "resume_signal_\(errorNumber)"
                )
            case .stateRejected:
                throw primeValidationDriverV2CanaryRejected(
                    "resume_state"
                )
            }

            let deathObservedAt: UInt64
            switch try supervision.observeDeath() {
            case .observed:
                guard let value = supervision
                    .deathObservedMonotonicNanoseconds()
                else {
                    throw primeValidationDriverV2CanaryRejected(
                        "death_timestamp"
                    )
                }
                deathObservedAt = value
            case .deadlineExpired:
                throw primeValidationDriverV2CanaryRejected(
                    "deadline_waiting_for_death"
                )
            case .stateRejected:
                throw primeValidationDriverV2CanaryRejected(
                    "death_state"
                )
            }
            let drains: PrimeSecureChildDrainEvidence
            switch try supervision.waitForPhaseDrainCompletion(
                notBeforeUptimeNanoseconds: deathObservedAt
            ) {
            case let .completed(value):
                drains = value
            case .deadlineExpired:
                throw primeValidationDriverV2CanaryRejected(
                    "deadline_waiting_for_drains"
                )
            case .stateRejected:
                throw primeValidationDriverV2CanaryRejected(
                    "drain_state"
                )
            }
            guard supervision.processGroupMemberIdentifiers() == [pid]
            else {
                throw primeValidationDriverV2CanaryRejected(
                    "pre_reap_group_members"
                )
            }
            let exactWait: PrimeSecureChildExactPIDWaitObservation
            switch supervision.reapAfterObservedDeath() {
            case let .reaped(value):
                exactWait = value
            case let .mustFailStop(reason):
                primeValidationDriverV2CanaryFailStop(reason)
            }
            guard try deadline.acceptsCompletion(
                observedAtUptimeNanoseconds:
                    exactWait.returnedMonotonicNanoseconds
            ) else {
                throw primeValidationDriverV2CanaryRejected(
                    "deadline_after_reap"
                )
            }
            let stdout: PrimeSecureChildMemoryDrainSnapshot
            let stderr: PrimeSecureChildMemoryDrainSnapshot
            switch drains {
            case let .memory(standardOutput, standardError):
                stdout = standardOutput
                stderr = standardError
            case .fileBacked:
                throw primeValidationDriverV2CanaryRejected(
                    "file_backed_drain"
                )
            }
            guard Self.cleanEmptyEOF(stdout),
                  Self.cleanEmptyEOF(stderr),
                  exactWait.requestedProcessIdentifier == pid,
                  exactWait.returnedProcessIdentifier == pid,
                  exactWait.waitOptions == 0,
                  exactWait.exitedNormally,
                  exactWait.exitStatus == 0,
                  exactWait.terminationSignal == 0,
                  !exactWait.coreDumped
            else {
                throw primeValidationDriverV2CanaryRejected(
                    "terminal_process_contract"
                )
            }
            try retainedState.revalidate()
            try executable.revalidate()
            do {
                try PrimeSecureChildDarwinProcessProof
                    .requireHeldDirectoryUnchanged(workingSnapshot)
            } catch {
                throw primeValidationDriverV2CanaryRejected(
                    "working_directory_changed_after_reap"
                )
            }
            try journal.revalidateStarted()
            let terminal = try journal.publishTerminal(
                PrimeValidationDriverV2CanaryTerminalRecordV1(
                    startLeafByteCount: start.byteCount,
                    startLeafSHA256: start.sha256,
                    processIdentifier: pid,
                    resumedAtUptimeNanoseconds: resumedAt,
                    requestedWaitProcessIdentifier:
                        exactWait.requestedProcessIdentifier,
                    returnedWaitProcessIdentifier:
                        exactWait.returnedProcessIdentifier,
                    waitOptions: exactWait.waitOptions,
                    rawWaitStatus: exactWait.rawWaitStatus,
                    waitReturnedUptimeNanoseconds:
                        exactWait.returnedMonotonicNanoseconds,
                    exitedNormally: exactWait.exitedNormally,
                    exitStatus: exactWait.exitStatus,
                    terminationSignal: exactWait.terminationSignal,
                    coreDumped: exactWait.coreDumped,
                    standardOutputByteCount: stdout.totalByteCount,
                    standardOutputReachedEOF: stdout.reachedEOF,
                    standardOutputDescriptorsClosed:
                        stdout.descriptorsClosed,
                    standardErrorByteCount: stderr.totalByteCount,
                    standardErrorReachedEOF: stderr.reachedEOF,
                    standardErrorDescriptorsClosed:
                        stderr.descriptorsClosed,
                    processGroupEmptyAfterReap: true,
                    postReapContinuityRevalidated: true,
                    workspaceEmptyAfterReap: true,
                    combinedSourceWatcherDescriptorCount:
                        retainedState
                        .combinedSourceWatcherDescriptorCount
                )
            )
            try journal.revalidateTerminal()
            return PrimeValidationDriverV2IsolatedSpawnCanaryObservation(
                processIdentifier: pid,
                appliedSpawnFlags: supervision.appliedFlags,
                sessionIdentifier: pid,
                processGroupIdentifier: pid,
                resumedAtUptimeNanoseconds: resumedAt,
                executableDeviceID: executable.snapshot.deviceID,
                executableInode: executable.snapshot.inode,
                executableByteCount: executable.snapshot.byteCount,
                executableSHA256: executable.snapshot.sha256,
                workingDirectoryDeviceID: workingSnapshot.deviceID,
                workingDirectoryInode: workingSnapshot.inode,
                mappedImageJoined: true,
                exactPIDWait: exactWait,
                standardOutputByteCount: stdout.totalByteCount,
                standardErrorByteCount: stderr.totalByteCount,
                standardOutputReachedEOF: stdout.reachedEOF,
                standardErrorReachedEOF: stderr.reachedEOF,
                processGroupEmptyAfterReap: true,
                combinedSourceWatcherDescriptorCount:
                    retainedState.combinedSourceWatcherDescriptorCount,
                startLeafByteCount: start.byteCount,
                startLeafSHA256: start.sha256,
                terminalLeafByteCount: terminal.byteCount,
                terminalLeafSHA256: terminal.sha256,
                workspaceEmptyAfterReap: true,
                productionSupervisorImageEligible:
                    retainedState.productionSupervisorImageEligible
            )
        } catch {
            primeValidationDriverV2CanaryContainOrFailStop(supervision)
            throw error
        }
    }

    private static func cleanEmptyEOF(
        _ value: PrimeSecureChildMemoryDrainSnapshot
    ) -> Bool {
        value.terminalReason == .endOfFile
            && value.data.isEmpty
            && value.totalByteCount == 0
            && !value.overflowed
            && value.workerFinished
            && value.reachedEOF
            && value.readErrorNumber == 0
            && value.writeErrorNumber == 0
            && value.finalizationErrorNumber == 0
            && value.closeErrorNumber == 0
            && value.descriptorsClosed
    }
}

private func primeValidationDriverV2CanaryContainOrFailStop(
    _ supervision: PrimeSecureChildSupervisionCapability
) {
    switch supervision.cleanupRejectedCapture() {
    case .contained:
        break
    case let .mustFailStop(reason):
        primeValidationDriverV2CanaryFailStop(reason)
    }
}

private func primeValidationDriverV2CanaryFailStop(
    _ reason: PrimeSecureChildContainmentFailureReason
) -> Never {
    let bytes = Array(
        "prime-driver-v2-canary fail-stop: \(reason.rawValue)\n".utf8
    )
    _ = bytes.withUnsafeBytes {
        Darwin.write(STDERR_FILENO, $0.baseAddress, $0.count)
    }
    Darwin._exit(70)
}

private func primeValidationDriverV2CanaryRejected(
    _ detail: String
) -> PrimeValidationSwiftPMBuildInventoryAdmissionError {
    .rejected("driver_v2_isolated_spawn_canary_\(detail)")
}
