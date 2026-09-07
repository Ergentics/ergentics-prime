// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin
import Dispatch
import Foundation

@_spi(PrimeValidationDriverV2RoleFacade)
public struct PrimeValidationDriverV2PinnedBundleMetadataObservation: Codable, Equatable, Sendable {
    public let deviceID: UInt64
    public let inode: UInt64
    public let mode: UInt32
    public let ownerUserID: UInt32
    public let ownerGroupID: UInt32
    public let linkCount: UInt64
    public let specialDeviceID: UInt64
    public let byteCount: Int64
    public let allocatedBlocks: Int64
    public let blockSize: Int64
    public let flags: UInt32
    public let generation: UInt32
    public let modificationSeconds: Int64
    public let modificationNanoseconds: Int64
    public let statusChangeSeconds: Int64
    public let statusChangeNanoseconds: Int64
    public let birthSeconds: Int64
    public let birthNanoseconds: Int64

    fileprivate init(_ s: stat) {
        deviceID = UInt64(bitPattern: Int64(s.st_dev)); inode = UInt64(s.st_ino)
        mode = UInt32(s.st_mode); ownerUserID = s.st_uid; ownerGroupID = s.st_gid
        linkCount = UInt64(s.st_nlink); specialDeviceID = UInt64(bitPattern: Int64(s.st_rdev))
        byteCount = s.st_size; allocatedBlocks = s.st_blocks; blockSize = Int64(s.st_blksize)
        flags = s.st_flags; generation = s.st_gen
        modificationSeconds = Int64(s.st_mtimespec.tv_sec)
        modificationNanoseconds = Int64(s.st_mtimespec.tv_nsec)
        statusChangeSeconds = Int64(s.st_ctimespec.tv_sec)
        statusChangeNanoseconds = Int64(s.st_ctimespec.tv_nsec)
        birthSeconds = Int64(s.st_birthtimespec.tv_sec)
        birthNanoseconds = Int64(s.st_birthtimespec.tv_nsec)
    }
}

@_spi(PrimeValidationDriverV2RoleFacade)
public struct PrimeValidationDriverV2PinnedBundleFileObservation: Codable, Equatable, Sendable {
    public let relativePath: String
    public let byteCount: UInt64
    public let sha256: String
    public let metadata: PrimeValidationDriverV2PinnedBundleMetadataObservation
}

@_spi(PrimeValidationDriverV2RoleFacade)
public struct PrimeValidationDriverV2PinnedBundleInputObservation: Codable, Equatable, Sendable {
    public let files: [PrimeValidationDriverV2PinnedBundleFileObservation]
}

/// Transport data for copying the preserved calibration resource. This does
/// not claim that SwiftPM or a Metal compiler generated these historical bytes.
@_spi(PrimeValidationDriverV2RoleFacade)
public struct PrimeValidationDriverV2PinnedBundleStagingObservation: Codable, Equatable, Sendable {
    public let input: PrimeValidationDriverV2PinnedBundleInputObservation
    public let destinations: [PrimeValidationDriverV2PinnedBundleFileObservation]
    public let stagingStartedAtUptimeNanoseconds: UInt64
    public let stagingCompletedAtUptimeNanoseconds: UInt64
    public let exclusivePublicationObserved: Bool
    public let durableSynchronizationObserved: Bool
}

/// Internal input ownership comes only from the Prime root retained by E.
/// Opening or staging never executes source, donor applications, or model code.
final class PrimeValidationDriverV2PinnedBundleInput: @unchecked Sendable {
    static let sourcePrefix = "artifacts/optimizer-restore-gate-865073a-20260729T183341Z/"
        + "mlx-swift_Cmlx.bundle"
    static let sourceInfoPlist = sourcePrefix + "/Contents/Info.plist"
    static let sourceMetallib = sourcePrefix + "/Contents/Resources/default.metallib"
    static let releaseBin = "root-release-build/arm64-apple-macosx/release"
    static let testBundle = releaseBin + "/ErgenticsPrimePackageTests.xctest"
    static let testExecutable = testBundle + "/Contents/MacOS/ErgenticsPrimePackageTests"
    static let cliBundle = releaseBin + "/mlx-swift_Cmlx.bundle"
    static let testResourceBundle = testBundle + "/Contents/Resources/mlx-swift_Cmlx.bundle"
    private static let maximumOperationNanoseconds: UInt64 = 30_000_000_000

    let observation: PrimeValidationDriverV2PinnedBundleInputObservation
    private let source: Tree
    private let deadlineNanoseconds: UInt64
    private let lock = NSLock()
    private var stagingAttempted = false
    private var poisoned = false
    private var staged: Tree?

    private typealias Metadata = PrimeValidationDriverV2PinnedBundleMetadataObservation
    private typealias FileObservation = PrimeValidationDriverV2PinnedBundleFileObservation

    private final class FD {
        let value: Int32
        init(_ value: Int32) { self.value = value }
        deinit { _ = close(value) }
    }

    /// Exact protected metadata omits only access time. The fixed parent
    /// chains are retained, including the caller's duplicated root descriptor.
    private final class Node {
        let descriptor: FD
        let path: String
        let parent: Node?
        let leaf: String?
        let metadata: Metadata
        let provenance: Data?
        let filesystem: String

        init(fd: Int32, path: String, parent: Node?, leaf: String?) throws {
            descriptor = FD(fd); self.path = path; self.parent = parent; self.leaf = leaf
            let s = try status(fd)
            metadata = Metadata(s)
            provenance = try requireMetadata(fd, s, path: path)
            filesystem = try filesystemIdentity(fd, s)
            if let parent {
                guard filesystem == parent.filesystem else { throw rejected("filesystem_join") }
            }
            try revalidate()
        }

        func revalidate() throws {
            let value = try status(descriptor.value)
            guard Metadata(value) == metadata,
                  try requireMetadata(descriptor.value, value, path: path) == provenance,
                  try filesystemIdentity(descriptor.value, value) == filesystem else {
                throw rejected("held_metadata")
            }
            if let parent, let leaf {
                guard try Metadata(status(parent.descriptor.value)) == parent.metadata else {
                    throw rejected("parent_metadata")
                }
                var named = stat()
                guard fstatat(parent.descriptor.value, leaf, &named, AT_SYMLINK_NOFOLLOW) == 0,
                      Metadata(named) == metadata else { throw rejected("named_rejoin") }
            }
            guard try Metadata(status(descriptor.value)) == metadata else {
                throw rejected("final_held_metadata")
            }
        }
    }

    private final class Tree {
        let nodes: [Node]
        let files: [String: Node]
        let observations: [FileObservation]
        let directoryNames: [String: [String]]

        init(rootDescriptor: Int32, specifications: [(String, UInt64, String)],
             exactDirectories: [String: [String]] = [:], immutable: Bool,
             deadline: UInt64) throws {
            let root = try Node(fd: duplicate(rootDescriptor), path: "", parent: nil, leaf: nil)
            var nodes = [root]
            var index = ["": root]
            var files = [String: Node]()
            var observed = [FileObservation]()
            for (path, count, hash) in specifications.sorted(by: { $0.0 < $1.0 }) {
                try check(deadline)
                var parent = root
                var prefix = ""
                let parts = path.split(separator: "/").map(String.init)
                for (offset, leaf) in parts.enumerated() {
                    prefix = prefix.isEmpty ? leaf : prefix + "/" + leaf
                    if let held = index[prefix] { parent = held; continue }
                    try parent.revalidate()
                    let isFile = offset == parts.count - 1
                    let fd = try opened(openat(parent.descriptor.value, leaf,
                        O_RDONLY | O_NOFOLLOW | O_CLOEXEC | O_NONBLOCK | (isFile ? 0 : O_DIRECTORY)))
                    let node = try Node(fd: fd, path: prefix, parent: parent, leaf: leaf)
                    guard isFile
                        ? node.metadata.mode & UInt32(S_IFMT) == UInt32(S_IFREG)
                        : node.metadata.mode & UInt32(S_IFMT) == UInt32(S_IFDIR) else {
                        throw rejected("node_type")
                    }
                    nodes.append(node); index[prefix] = node; parent = node
                }
                guard parent.metadata.byteCount == Int64(count),
                      parent.metadata.mode & 0o111 == 0,
                      !immutable || parent.metadata.mode & 0o7777 == 0o444 else {
                    throw rejected("file_size_or_mode")
                }
                let bytes = try read(parent, expectedCount: count, deadline: deadline)
                guard PrimeSHA256.hexDigest(of: bytes) == hash else { throw rejected("content_pin") }
                files[path] = parent
                observed.append(.init(relativePath: path, byteCount: count, sha256: hash,
                    metadata: parent.metadata))
            }
            for (path, expected) in exactDirectories {
                guard let node = index[path], node.metadata.mode & 0o7777 == 0o700,
                      try names(node.descriptor.value) == expected.sorted() else {
                    throw rejected("resource_inventory")
                }
            }
            self.nodes = nodes; self.files = files; observations = observed
            directoryNames = exactDirectories
            try revalidate(deadline: deadline, readContents: true)
        }

        func revalidate(deadline: UInt64, readContents: Bool) throws {
            for node in nodes { try check(deadline); try node.revalidate() }
            for (path, expected) in directoryNames {
                guard let node = nodes.first(where: { $0.path == path }),
                      try names(node.descriptor.value) == expected.sorted() else {
                    throw rejected("resource_inventory_changed")
                }
            }
            if readContents {
                for value in observations {
                    guard let node = files[value.relativePath],
                          try PrimeSHA256.hexDigest(of: read(node, expectedCount: value.byteCount,
                            deadline: deadline)) == value.sha256 else { throw rejected("content_changed") }
                }
            }
            for node in nodes { try check(deadline); try node.revalidate() }
        }
    }

    private init(source: Tree, deadlineNanoseconds: UInt64) {
        self.source = source; self.deadlineNanoseconds = deadlineNanoseconds
        observation = .init(files: source.observations)
    }

    static func capture(primeRoot: PrimeArtifactRoot, deadlineNanoseconds: UInt64) throws
        -> PrimeValidationDriverV2PinnedBundleInput {
        let deadline = try operationDeadline(deadlineNanoseconds)
        let fd = try primeRoot.duplicateTrustedRootDescriptorForInventory()
        defer { _ = close(fd) }
        let source = try Tree(rootDescriptor: fd, specifications: sourceSpecifications,
            immutable: false, deadline: deadline)
        return .init(source: source, deadlineNanoseconds: deadlineNanoseconds)
    }

    func revalidate() throws { try validate(readContents: true) }

    /// For repeated ownership checkpoints only. Full byte validation remains
    /// mandatory at input admission, staging, and final revalidate().
    func checkpointMetadata() throws { try validate(readContents: false) }

    /// Read-only continuation of the same source and staged descriptors.
    /// The live build owner must be consumed before this phase is reachable.
    func revalidateAfterBuild(deadlineNanoseconds: UInt64) throws {
        lock.lock(); defer { lock.unlock() }
        guard !poisoned, stagingAttempted, let staged else {
            throw Self.rejected("staged_continuation_unavailable")
        }
        do {
            let deadline = try Self.operationDeadline(deadlineNanoseconds)
            try source.revalidate(deadline: deadline, readContents: true)
            try staged.revalidate(deadline: deadline, readContents: true)
        } catch { poisoned = true; throw error }
    }

    private func validate(readContents: Bool) throws {
        lock.lock(); defer { lock.unlock() }
        guard !poisoned else { throw Self.rejected("poisoned") }
        do {
            let deadline = try Self.operationDeadline(deadlineNanoseconds)
            try source.revalidate(deadline: deadline, readContents: readContents)
            try staged?.revalidate(deadline: deadline, readContents: readContents)
        } catch { poisoned = true; throw error }
    }

    func stage(into workspaceRoot: PrimeArtifactRoot, deadlineNanoseconds: UInt64) throws
        -> PrimeValidationDriverV2PinnedBundleStagingObservation {
        lock.lock(); defer { lock.unlock() }
        guard !poisoned, !stagingAttempted else { throw Self.rejected("stage_consumed") }
        stagingAttempted = true
        do {
            let started = DispatchTime.now().uptimeNanoseconds
            let deadline = try Self.operationDeadline(min(self.deadlineNanoseconds, deadlineNanoseconds))
            try source.revalidate(deadline: deadline, readContents: true)
            try workspaceRoot.requirePrivateRootMode()
            let workspaceFD = FD(try Self.opened(workspaceRoot.duplicateTrustedRootDescriptorForInventory()))
            let workspaceStatus = try Self.status(workspaceFD.value)
            guard source.nodes.allSatisfy({
                $0.metadata.deviceID != UInt64(bitPattern: Int64(workspaceStatus.st_dev))
                    || $0.metadata.inode != UInt64(workspaceStatus.st_ino)
            }) else { throw Self.rejected("source_destination_alias") }
            var directories = [String: FD](dictionaryLiteral: ("", workspaceFD))
            var identities = [String: Metadata](dictionaryLiteral: ("", Metadata(workspaceStatus)))
            // These paths are generated by the completed build, never created here.
            _ = try Self.directory(Self.releaseBin, under: workspaceFD.value,
                createLeaf: false, directories: &directories, identities: &identities, deadline: deadline)
            _ = try Self.directory(Self.testBundle + "/Contents/MacOS", under: workspaceFD.value,
                createLeaf: false, directories: &directories, identities: &identities, deadline: deadline)
            let executableFD = FD(try Self.opened(openat(
                directories[Self.testBundle + "/Contents/MacOS"]!.value,
                "ErgenticsPrimePackageTests", O_RDONLY | O_NOFOLLOW | O_NONBLOCK | O_CLOEXEC)))
            let executableStatus = try Self.status(executableFD.value)
            _ = try Self.requireMetadata(executableFD.value, executableStatus, path: Self.testExecutable)
            guard executableStatus.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
                  executableStatus.st_size > 0, executableStatus.st_mode & 0o100 != 0 else {
                throw Self.rejected("generated_test_executable")
            }
            // Require both bundle names absent before changing either destination.
            try workspaceRoot.requireAbsent(at: Self.cliBundle)
            let resources = Self.testBundle + "/Contents/Resources"
            let resourcesParent = directories[Self.testBundle + "/Contents"]!.value
            var resourcesStatus = stat()
            let resourcesResult = fstatat(resourcesParent, "Resources", &resourcesStatus, AT_SYMLINK_NOFOLLOW)
            if resourcesResult == 0 {
                _ = try Self.directory(resources, under: workspaceFD.value, createLeaf: false,
                    directories: &directories, identities: &identities, deadline: deadline)
                try workspaceRoot.requireAbsent(at: Self.testResourceBundle)
            } else {
                guard errno == ENOENT else { throw Self.rejected("test_resources_stat") }
                _ = try Self.directory(resources, under: workspaceFD.value, createLeaf: true,
                    directories: &directories, identities: &identities, deadline: deadline)
            }
            for bundle in [Self.cliBundle, Self.testResourceBundle] {
                for path in [bundle, bundle + "/Contents", bundle + "/Contents/Resources"] {
                    _ = try Self.directory(path, under: workspaceFD.value, createLeaf: true,
                        directories: &directories, identities: &identities, deadline: deadline)
                }
            }
            var publishedInodes = [String: (UInt64, UInt64)]()
            for (destination, count, hash) in Self.destinationSpecifications {
                try Self.check(deadline)
                try Self.rejoinDirectories(directories, identities: identities)
                let sourcePath = destination.hasSuffix("Info.plist") ? Self.sourceInfoPlist : Self.sourceMetallib
                guard let held = source.files[sourcePath] else { throw Self.rejected("source_binding") }
                let bytes = try Self.read(held, expectedCount: count, deadline: deadline)
                guard PrimeSHA256.hexDigest(of: bytes) == hash else { throw Self.rejected("stage_source_pin") }
                let binding = try workspaceRoot.publishGeneratedFile(at: destination,
                    purpose: .immutableData, maximumByteCount: count) { fd in
                        let s = try Self.status(fd)
                        publishedInodes[destination] = (UInt64(bitPattern: Int64(s.st_dev)), UInt64(s.st_ino))
                        try Self.write(bytes, to: fd, deadline: deadline)
                    }
                guard binding.sha256 == hash, binding.byteCount == count else {
                    throw Self.rejected("published_pin")
                }
                try Self.rejoinDirectories(directories, identities: identities)
            }
            for path in directories.keys.sorted().reversed() {
                try Self.synchronize(directories[path]!.value, deadline: deadline)
            }
            try Self.rejoinDirectories(directories, identities: identities)
            guard try Metadata(Self.status(executableFD.value)) == Metadata(executableStatus) else {
                throw Self.rejected("generated_executable_changed")
            }
            var namedExecutable = stat()
            guard fstatat(directories[Self.testBundle + "/Contents/MacOS"]!.value,
                "ErgenticsPrimePackageTests", &namedExecutable, AT_SYMLINK_NOFOLLOW) == 0,
                  Metadata(namedExecutable) == Metadata(executableStatus) else {
                throw Self.rejected("generated_executable_rejoin")
            }
            let staged = try Tree(rootDescriptor: workspaceFD.value,
                specifications: Self.destinationSpecifications,
                exactDirectories: Self.resourceDirectories, immutable: true, deadline: deadline)
            for value in staged.observations {
                guard let created = publishedInodes[value.relativePath],
                      created.0 == value.metadata.deviceID, created.1 == value.metadata.inode else {
                    throw Self.rejected("published_inode_join")
                }
            }
            try source.revalidate(deadline: deadline, readContents: true)
            try staged.revalidate(deadline: deadline, readContents: true)
            let completed = DispatchTime.now().uptimeNanoseconds
            try Self.check(deadline)
            self.staged = staged
            return .init(input: observation, destinations: staged.observations,
                stagingStartedAtUptimeNanoseconds: started,
                stagingCompletedAtUptimeNanoseconds: completed,
                exclusivePublicationObserved: true, durableSynchronizationObserved: true)
        } catch { poisoned = true; throw error }
    }

    private static var sourceSpecifications: [(String, UInt64, String)] {
        [(sourceInfoPlist, PrimePinnedMLXMetallib.expectedInfoPlistByteCount,
          PrimePinnedMLXMetallib.expectedInfoPlistSHA256),
         (sourceMetallib, PrimePinnedMLXMetallib.expectedByteCount, PrimePinnedMLXMetallib.expectedSHA256)]
    }
    private static var destinationSpecifications: [(String, UInt64, String)] {
        [cliBundle, testResourceBundle].flatMap { bundle in
            [(bundle + "/Contents/Info.plist", PrimePinnedMLXMetallib.expectedInfoPlistByteCount,
              PrimePinnedMLXMetallib.expectedInfoPlistSHA256),
             (bundle + "/Contents/Resources/default.metallib", PrimePinnedMLXMetallib.expectedByteCount,
              PrimePinnedMLXMetallib.expectedSHA256)]
        }.sorted { $0.0 < $1.0 }
    }
    private static var resourceDirectories: [String: [String]] {
        var result = [String: [String]]()
        for bundle in [cliBundle, testResourceBundle] {
            result[bundle] = ["Contents"]
            result[bundle + "/Contents"] = ["Info.plist", "Resources"]
            result[bundle + "/Contents/Resources"] = ["default.metallib"]
        }
        return result
    }

    private static func directory(_ path: String, under root: Int32, createLeaf: Bool,
        directories: inout [String: FD], identities: inout [String: Metadata], deadline: UInt64) throws -> Int32 {
        var prefix = ""
        var parent = root
        let parts = path.split(separator: "/").map(String.init)
        for (index, leaf) in parts.enumerated() {
            try check(deadline)
            prefix = prefix.isEmpty ? leaf : prefix + "/" + leaf
            if let held = directories[prefix] {
                guard !(createLeaf && index == parts.count - 1) else { throw rejected("destination_exists") }
                parent = held.value; continue
            }
            let create = createLeaf && index == parts.count - 1
            if create {
                guard mkdirat(parent, leaf, 0o700) == 0 else { throw rejected("mkdir_exclusive") }
            }
            let fd = FD(try opened(openat(parent, leaf, O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC)))
            let s = try status(fd.value)
            _ = try requireMetadata(fd.value, s, path: prefix)
            guard s.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
                  !create || s.st_mode & 0o7777 == 0o700,
                  try filesystemIdentity(fd.value, s) == filesystemIdentity(root, status(root)) else {
                throw rejected("destination_directory")
            }
            var named = stat()
            guard fstatat(parent, leaf, &named, AT_SYMLINK_NOFOLLOW) == 0,
                  Metadata(named) == Metadata(s) else { throw rejected("created_directory_join") }
            if create {
                guard try names(fd.value).isEmpty else { throw rejected("created_directory_not_empty") }
                try synchronize(fd.value, deadline: deadline); try synchronize(parent, deadline: deadline)
            }
            directories[prefix] = fd; identities[prefix] = Metadata(s); parent = fd.value
        }
        return parent
    }

    /// Directories on the destination path may change times/link counts only
    /// while this synchronous operation creates its declared descendants.
    private static func rejoinDirectories(_ directories: [String: FD], identities: [String: Metadata]) throws {
        for (path, fd) in directories {
            guard let original = identities[path] else { throw rejected("directory_identity_missing") }
            let s = try status(fd.value)
            let current = Metadata(s)
            _ = try requireMetadata(fd.value, s, path: path)
            guard current.deviceID == original.deviceID, current.inode == original.inode,
                  current.mode == original.mode, current.ownerUserID == original.ownerUserID,
                  current.ownerGroupID == original.ownerGroupID, current.flags == original.flags,
                  current.birthSeconds == original.birthSeconds,
                  current.birthNanoseconds == original.birthNanoseconds else { throw rejected("directory_identity_changed") }
            if !path.isEmpty {
                let parts = path.split(separator: "/").map(String.init)
                let parent = parts.dropLast().joined(separator: "/")
                guard let parentFD = directories[parent] else { throw rejected("directory_parent_missing") }
                var named = stat()
                guard fstatat(parentFD.value, parts.last!, &named, AT_SYMLINK_NOFOLLOW) == 0,
                      Metadata(named) == current else { throw rejected("directory_name_changed") }
            }
        }
    }

    private static func read(_ node: Node, expectedCount: UInt64, deadline: UInt64) throws -> Data {
        try node.revalidate()
        guard expectedCount <= PrimePinnedMLXMetallib.expectedByteCount,
              node.metadata.byteCount == Int64(expectedCount), lseek(node.descriptor.value, 0, SEEK_SET) == 0
        else { throw rejected("read_extent") }
        var data = Data(); data.reserveCapacity(Int(expectedCount))
        var bytes = [UInt8](repeating: 0, count: 65_536)
        while true {
            try check(deadline)
            let count = bytes.withUnsafeMutableBytes { Darwin.read(node.descriptor.value, $0.baseAddress, $0.count) }
            if count < 0 && errno == EINTR { continue }
            guard count >= 0 else { throw rejected("read") }
            if count == 0 { break }
            guard data.count + count <= Int(expectedCount) else { throw rejected("read_excess") }
            data.append(contentsOf: bytes.prefix(count))
        }
        guard data.count == Int(expectedCount) else { throw rejected("read_short") }
        try node.revalidate(); try check(deadline)
        return data
    }

    private static func write(_ data: Data, to fd: Int32, deadline: UInt64) throws {
        try data.withUnsafeBytes { bytes in
            var offset = 0
            while offset < bytes.count {
                try check(deadline)
                let count = Darwin.write(fd, bytes.baseAddress!.advanced(by: offset), min(65_536, bytes.count - offset))
                if count < 0 && errno == EINTR { continue }
                guard count > 0 else { throw rejected("write") }
                offset += count
            }
        }
    }

    private static func names(_ fd: Int32) throws -> [String] {
        let copy = try opened(openat(fd, ".", O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC))
        guard let stream = fdopendir(copy) else { _ = close(copy); throw rejected("directory_stream") }
        defer { _ = closedir(stream) }
        var result = [String]()
        while true {
            errno = 0
            guard let entry = readdir(stream) else {
                guard errno == 0 else { throw rejected("directory_read") }
                return result.sorted()
            }
            let name = withUnsafePointer(to: entry.pointee.d_name) {
                $0.withMemoryRebound(to: CChar.self, capacity: Int(MAXNAMLEN) + 1) { String(cString: $0) }
            }
            if name == "." || name == ".." { continue }
            guard result.count < 8, !result.contains(name) else { throw rejected("resource_entry_count") }
            result.append(name)
        }
    }

    private static func status(_ fd: Int32) throws -> stat {
        var s = stat(); guard fstat(fd, &s) == 0 else { throw rejected("fstat") }; return s
    }
    private static func duplicate(_ fd: Int32) throws -> Int32 { try opened(fcntl(fd, F_DUPFD_CLOEXEC, 3)) }
    private static func opened(_ fd: Int32) throws -> Int32 {
        guard fd >= 0 else { throw rejected("open") }
        if fd < 3 { let copy = fcntl(fd, F_DUPFD_CLOEXEC, 3); _ = close(fd); return try opened(copy) }
        let flags = fcntl(fd, F_GETFD)
        guard flags >= 0, flags & FD_CLOEXEC != 0 else { _ = close(fd); throw rejected("cloexec") }
        return fd
    }
    private static func filesystemIdentity(_ fd: Int32, _ s: stat) throws -> String {
        var fs = statfs()
        guard fstatfs(fd, &fs) == 0, fs.f_flags & UInt32(MNT_LOCAL) != 0 else { throw rejected("filesystem_local") }
        var field = fs.f_fstypename
        let name = withUnsafeBytes(of: &field) { String(bytes: $0.prefix { $0 != 0 }, encoding: .utf8) }
        guard name == "apfs" else { throw rejected("filesystem_apfs") }
        return "\(s.st_dev):\(fs.f_fsid.val.0):\(fs.f_fsid.val.1)"
    }
    private static func requireMetadata(_ fd: Int32, _ s: stat, path: String) throws -> Data? {
        guard s.st_uid == geteuid(), s.st_flags == 0, s.st_mode & 0o7022 == 0 else { throw rejected("metadata") }
        if s.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR) {
            guard s.st_mode & 0o500 == 0o500 else { throw rejected("directory_mode") }
            try PrimeArtifactRoot.requireTrustedInventoryDirectoryDescriptor(fd, path: path)
        } else {
            guard s.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG), s.st_nlink == 1,
                  s.st_size > 0, s.st_mode & 0o400 != 0 else { throw rejected("regular_file") }
            try PrimeArtifactRoot.requireTrustedInventoryArtifactDescriptor(fd, path: path)
        }
        let count = fgetxattr(fd, "com.apple.provenance", nil, 0, 0, 0)
        if count < 0 { guard errno == ENOATTR else { throw rejected("xattr") }; return nil }
        guard count <= 4096 else { throw rejected("xattr_cap") }
        var data = Data(count: max(1, count))
        let actual = data.withUnsafeMutableBytes { fgetxattr(fd, "com.apple.provenance", $0.baseAddress, count, 0, 0) }
        guard actual == count, fgetxattr(fd, "com.apple.provenance", nil, 0, 0, 0) == count else {
            throw rejected("xattr_changed")
        }
        return data.prefix(count)
    }
    private static func synchronize(_ fd: Int32, deadline: UInt64) throws {
        try check(deadline)
        guard fsync(fd) == 0, fcntl(fd, F_FULLFSYNC) == 0 else { throw rejected("sync") }
        try check(deadline)
    }
    private static func operationDeadline(_ outer: UInt64) throws -> UInt64 {
        let now = DispatchTime.now().uptimeNanoseconds
        let (local, overflow) = now.addingReportingOverflow(maximumOperationNanoseconds)
        guard !overflow, now < outer else { throw rejected("deadline") }
        return min(local, outer)
    }
    private static func check(_ deadline: UInt64) throws {
        guard DispatchTime.now().uptimeNanoseconds < deadline else { throw rejected("deadline") }
    }
    private static func rejected(_ detail: String) -> Error {
        PrimeValidationSwiftPMBuildInventoryAdmissionError.rejected("driver_v2_pinned_bundle_" + detail)
    }

    fileprivate static func inputReadback(primeRootDescriptor: Int32, deadlineNanoseconds: UInt64)
        throws -> (PrimeValidationDriverV2PinnedBundleInputObservation,
                   (Bool) throws -> PrimeValidationDriverV2PinnedBundleInputObservation) {
        let deadline = try operationDeadline(deadlineNanoseconds)
        let tree = try Tree(rootDescriptor: primeRootDescriptor, specifications: sourceSpecifications,
            immutable: false, deadline: deadline)
        let observation = PrimeValidationDriverV2PinnedBundleInputObservation(files: tree.observations)
        return (observation, { readContents in
            try tree.revalidate(deadline: operationDeadline(deadlineNanoseconds), readContents: readContents)
            return observation
        })
    }

    fileprivate static func readback(primeRootDescriptor: Int32, workspaceRootDescriptor: Int32,
        expected: PrimeValidationDriverV2PinnedBundleStagingObservation, deadlineNanoseconds: UInt64)
        throws -> () throws -> PrimeValidationDriverV2PinnedBundleStagingObservation {
        let deadline = try operationDeadline(deadlineNanoseconds)
        guard expected.exclusivePublicationObserved, expected.durableSynchronizationObserved,
              expected.stagingStartedAtUptimeNanoseconds > 0,
              expected.stagingCompletedAtUptimeNanoseconds > expected.stagingStartedAtUptimeNanoseconds,
              expected.stagingCompletedAtUptimeNanoseconds <= DispatchTime.now().uptimeNanoseconds else {
            throw rejected("readback_declaration")
        }
        let source = try Tree(rootDescriptor: primeRootDescriptor, specifications: sourceSpecifications,
            immutable: false, deadline: deadline)
        let staged = try Tree(rootDescriptor: workspaceRootDescriptor, specifications: destinationSpecifications,
            exactDirectories: resourceDirectories, immutable: true, deadline: deadline)
        guard source.observations == expected.input.files, staged.observations == expected.destinations else {
            throw rejected("readback_identity")
        }
        return {
            let current = try operationDeadline(deadlineNanoseconds)
            try source.revalidate(deadline: current, readContents: true)
            try staged.revalidate(deadline: current, readContents: true)
            return expected
        }
    }
}

/// Retains the two calibrated inputs before the supervised run begins. This
/// read-only value cannot stage resources or reconstruct a build owner.
@_spi(PrimeValidationDriverV2RoleFacade)
public final class PrimeValidationDriverV2PinnedBundleInputReadback: @unchecked Sendable {
    public let observation: PrimeValidationDriverV2PinnedBundleInputObservation
    private let validate: (Bool) throws -> PrimeValidationDriverV2PinnedBundleInputObservation
    private let lock = NSLock()
    private var poisoned = false
    private init(_ observation: PrimeValidationDriverV2PinnedBundleInputObservation,
        validate: @escaping (Bool) throws -> PrimeValidationDriverV2PinnedBundleInputObservation) {
        self.observation = observation; self.validate = validate
    }
    public static func capture(primeRootDescriptor: Int32, deadlineNanoseconds: UInt64) throws
        -> PrimeValidationDriverV2PinnedBundleInputReadback {
        let value = try PrimeValidationDriverV2PinnedBundleInput.inputReadback(
            primeRootDescriptor: primeRootDescriptor, deadlineNanoseconds: deadlineNanoseconds)
        return .init(value.0, validate: value.1)
    }
    @discardableResult public func revalidate() throws -> PrimeValidationDriverV2PinnedBundleInputObservation {
        try checked(readContents: true)
    }
    @discardableResult public func checkpointMetadata() throws -> PrimeValidationDriverV2PinnedBundleInputObservation {
        try checked(readContents: false)
    }
    private func checked(readContents: Bool) throws -> PrimeValidationDriverV2PinnedBundleInputObservation {
        lock.lock(); defer { lock.unlock() }
        guard !poisoned else {
            throw PrimeValidationSwiftPMBuildInventoryAdmissionError.rejected("driver_v2_pinned_bundle_input_readback_poisoned")
        }
        do { return try validate(readContents) } catch { poisoned = true; throw error }
    }
}

/// Read-only acquisition by the governor, independent of the consumed staging
/// owner. Decoded expectations cannot launch a build or publish resources.
@_spi(PrimeValidationDriverV2RoleFacade)
public final class PrimeValidationDriverV2PinnedBundleReadback: @unchecked Sendable {
    private let lock = NSLock()
    private let validate: () throws -> PrimeValidationDriverV2PinnedBundleStagingObservation
    private var poisoned = false
    private init(_ validate: @escaping () throws -> PrimeValidationDriverV2PinnedBundleStagingObservation) {
        self.validate = validate
    }
    public static func capture(primeRootDescriptor: Int32, workspaceRootDescriptor: Int32,
        expected: PrimeValidationDriverV2PinnedBundleStagingObservation, deadlineNanoseconds: UInt64) throws
        -> PrimeValidationDriverV2PinnedBundleReadback {
        .init(try PrimeValidationDriverV2PinnedBundleInput.readback(primeRootDescriptor: primeRootDescriptor,
            workspaceRootDescriptor: workspaceRootDescriptor, expected: expected,
            deadlineNanoseconds: deadlineNanoseconds))
    }
    @discardableResult public func revalidate() throws -> PrimeValidationDriverV2PinnedBundleStagingObservation {
        lock.lock(); defer { lock.unlock() }
        guard !poisoned else {
            throw PrimeValidationSwiftPMBuildInventoryAdmissionError.rejected("driver_v2_pinned_bundle_readback_poisoned")
        }
        do { return try validate() } catch { poisoned = true; throw error }
    }
}
