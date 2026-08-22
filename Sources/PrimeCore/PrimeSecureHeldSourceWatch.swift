// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin
import Dispatch
import Foundation

/// Domain-neutral immutable file bytes used by the maintained held-watch
/// implementation. Prime provenance and companion continuity construct this
/// value through separate snapshot authorities.
struct PrimeSecureHeldFileSnapshot:
    Codable,
    Equatable,
    Sendable
{
    let relativePath: String
    let sha256: String
    let byteCount: UInt64
    let contents: Data

    init(
        relativePath: String,
        sha256: String,
        byteCount: UInt64,
        contents: Data
    ) {
        self.relativePath = relativePath
        self.sha256 = sha256
        self.byteCount = byteCount
        self.contents = contents
    }

    init(_ source: PrimeSwiftSourceFileSnapshot) {
        self.init(
            relativePath: source.relativePath,
            sha256: source.sha256,
            byteCount: source.byteCount,
            contents: source.contents
        )
    }

    private enum CodingKeys: String, CodingKey {
        case relativePath = "relative_path"
        case sha256
        case byteCount = "byte_count"
        case contents
    }
}

/// Exact admission-time metadata used only to close the capture-to-watch
/// window. Directory ctime/mtime detects even a create/remove that restores
/// the original inventory before kqueue registration; file identity detects
/// byte restoration or same-path replacement in that same window.
struct PrimeSecureHeldNodeIdentity:
    Codable,
    Equatable,
    Sendable
{
    let deviceID: Int32
    let inode: UInt64
    let ownerUserID: UInt32
    let groupID: UInt32
    let mode: UInt32
    let linkCount: UInt64
    let byteCount: Int64
    let modificationSeconds: Int64
    let modificationNanoseconds: Int64
    let statusChangeSeconds: Int64
    let statusChangeNanoseconds: Int64

    init(_ value: stat) {
        deviceID = Int32(value.st_dev)
        inode = UInt64(value.st_ino)
        ownerUserID = UInt32(value.st_uid)
        groupID = UInt32(value.st_gid)
        mode = UInt32(value.st_mode)
        linkCount = UInt64(value.st_nlink)
        byteCount = Int64(value.st_size)
        modificationSeconds = Int64(value.st_mtimespec.tv_sec)
        modificationNanoseconds = Int64(value.st_mtimespec.tv_nsec)
        statusChangeSeconds = Int64(value.st_ctimespec.tv_sec)
        statusChangeNanoseconds = Int64(value.st_ctimespec.tv_nsec)
    }

    func matches(_ value: stat) -> Bool {
        self == Self(value)
    }

    private enum CodingKeys: String, CodingKey {
        case deviceID = "device_id"
        case inode
        case ownerUserID = "owner_user_id"
        case groupID = "group_id"
        case mode
        case linkCount = "link_count"
        case byteCount = "byte_count"
        case modificationSeconds = "modification_seconds"
        case modificationNanoseconds = "modification_nanoseconds"
        case statusChangeSeconds = "status_change_seconds"
        case statusChangeNanoseconds = "status_change_nanoseconds"
    }
}

/// Live-only metadata baseline for Prime's existing file-derived topology.
/// This does not widen `PrimeSwiftSourceSnapshot` or add empty directories;
/// it prevents admitted file/directory metadata from being rebaselined before
/// the legacy Prime watch is armed.
struct PrimeSecureHeldLegacySourceIdentitySnapshot:
    Equatable,
    Sendable
{
    let directoryIdentities:
        [String: PrimeSecureHeldNodeIdentity]
    let fileIdentities:
        [String: PrimeSecureHeldNodeIdentity]
}

/// Internal, non-authoritative baseline for complete companion working-tree
/// continuity. It contains every regular file and directory, including hidden
/// entries and empty directories, except descendants of the exact root `.git`
/// directory. Gate D/E separately own tracked-tree and Git observations.
struct PrimeSecureHeldWorkingTreeSnapshot:
    Equatable,
    Sendable
{
    static let maximumFileCount = 4_096
    static let maximumDirectoryCount = 4_096
    static let maximumFileByteCount:
        UInt64 = 64 * 1024 * 1024
    static let maximumAggregateByteCount:
        UInt64 = 512 * 1024 * 1024
    static let maximumRelativeDepth = 32
    static let maximumDirectoryEntryCount = 16_384
    static let maximumAggregateDirectoryEntryCount = 65_536
    static let maximumCaptureNanoseconds:
        UInt64 = 30 * 1_000_000_000

    let directoryRelativePaths: [String]
    let files: [PrimeSecureHeldFileSnapshot]
    let directoryIdentities:
        [String: PrimeSecureHeldNodeIdentity]
    let fileIdentities:
        [String: PrimeSecureHeldNodeIdentity]
    let excludedRootGitDirectoryDeviceID: Int32
    let excludedRootGitDirectoryInode: UInt64
    let identitySHA256: String

    private struct IdentityDirectory: Codable {
        let relativePath: String
        let identity: PrimeSecureHeldNodeIdentity

        private enum CodingKeys: String, CodingKey {
            case relativePath = "relative_path"
            case identity
        }
    }

    private struct IdentityFile: Codable {
        let relativePath: String
        let sha256: String
        let byteCount: UInt64
        let identity: PrimeSecureHeldNodeIdentity

        private enum CodingKeys: String, CodingKey {
            case relativePath = "relative_path"
            case sha256
            case byteCount = "byte_count"
            case identity
        }
    }

    private struct IdentityPayload: Codable {
        let artifactKind: String
        let schemaVersion: Int
        let directoryRelativePaths: [String]
        let directories: [IdentityDirectory]
        let files: [IdentityFile]
        let excludedRootGitDirectoryDeviceID: Int32
        let excludedRootGitDirectoryInode: UInt64

        private enum CodingKeys: String, CodingKey {
            case artifactKind = "artifact_kind"
            case schemaVersion = "schema_version"
            case directoryRelativePaths = "directory_relative_paths"
            case directories
            case files
            case excludedRootGitDirectoryDeviceID =
                "excluded_root_git_directory_device_id"
            case excludedRootGitDirectoryInode =
                "excluded_root_git_directory_inode"
        }
    }

    private struct CaptureState {
        var directoryRelativePaths: [String] = [""]
        var directoryIdentities:
            [String: PrimeSecureHeldNodeIdentity] = [:]
        var files: [PrimeSecureHeldFileSnapshot] = []
        var fileIdentities:
            [String: PrimeSecureHeldNodeIdentity] = [:]
        var aggregateFileByteCount: UInt64 = 0
        var aggregateDirectoryEntryCount = 0
        var excludedRootGitDirectoryDeviceID: Int32?
        var excludedRootGitDirectoryInode: UInt64?
    }

    private struct DirectoryEntry {
        let name: String
    }

    static func capture(
        rootDescriptor: Int32
    ) throws -> Self {
        let started = DispatchTime.now().uptimeNanoseconds
        let deadline = started.addingReportingOverflow(
            maximumCaptureNanoseconds
        )
        guard !deadline.overflow,
              rootDescriptor >= 3,
              fcntl(rootDescriptor, F_GETFD) & FD_CLOEXEC != 0
        else {
            throw rejected("root_descriptor")
        }
        var rootStatus = stat()
        guard fstat(rootDescriptor, &rootStatus) == 0,
              isSafeDirectory(rootStatus),
              rootStatus.st_ino > 0
        else {
            throw rejected("root_directory")
        }
        _ = try PrimeNativeNeuralGateHeldSourceClosure.requireLocalAPFS(
            rootDescriptor: rootDescriptor
        )

        var state = CaptureState()
        try captureDirectory(
            descriptor: rootDescriptor,
            relativePath: "",
            expectedDevice: rootStatus.st_dev,
            deadlineNanoseconds: deadline.partialValue,
            state: &state
        )
        try requireBeforeDeadline(deadline.partialValue)
        guard let gitDeviceID =
                state.excludedRootGitDirectoryDeviceID,
              let gitInode =
                state.excludedRootGitDirectoryInode,
              state.files.count <= maximumFileCount,
              state.directoryRelativePaths.count
                <= maximumDirectoryCount,
              state.directoryIdentities.count
                == state.directoryRelativePaths.count,
              state.fileIdentities.count == state.files.count,
              state.aggregateFileByteCount
                <= maximumAggregateByteCount,
              state.aggregateDirectoryEntryCount
                <= maximumAggregateDirectoryEntryCount
        else {
            throw rejected("complete_snapshot")
        }

        state.directoryRelativePaths.sort(
            by: directoryPathPrecedes
        )
        state.files.sort {
            rawUTF8Precedes(
                $0.relativePath,
                $1.relativePath
            )
        }
        let identityDirectories = try
            state.directoryRelativePaths.map { path in
                guard let identity = state.directoryIdentities[path]
                else {
                    throw rejected("directory_identity")
                }
                return IdentityDirectory(
                    relativePath: path,
                    identity: identity
                )
            }
        let identityFiles = try state.files.map { file in
            guard let identity =
                    state.fileIdentities[file.relativePath]
            else {
                throw rejected("file_identity")
            }
            return IdentityFile(
                relativePath: file.relativePath,
                sha256: file.sha256,
                byteCount: file.byteCount,
                identity: identity
            )
        }
        let identityPayload = IdentityPayload(
            artifactKind:
                "prime_secure_companion_working_tree_snapshot",
            schemaVersion: 1,
            directoryRelativePaths:
                state.directoryRelativePaths,
            directories: identityDirectories,
            files: identityFiles,
            excludedRootGitDirectoryDeviceID: gitDeviceID,
            excludedRootGitDirectoryInode: gitInode
        )
        let identityData = try PrimeCanonicalJSON.encode(
            identityPayload
        )
        try requireBeforeDeadline(deadline.partialValue)
        let identitySHA256 = PrimeSHA256.hexDigest(
            of: identityData
        )
        try requireBeforeDeadline(deadline.partialValue)
        return Self(
            directoryRelativePaths:
                state.directoryRelativePaths,
            files: state.files,
            directoryIdentities:
                state.directoryIdentities,
            fileIdentities: state.fileIdentities,
            excludedRootGitDirectoryDeviceID: gitDeviceID,
            excludedRootGitDirectoryInode: gitInode,
            identitySHA256: identitySHA256
        )
    }

    static func captureLegacyPrimeSourceIdentity(
        rootDescriptor: Int32,
        sourceSnapshot: PrimeSwiftSourceSnapshot
    ) throws -> PrimeSecureHeldLegacySourceIdentitySnapshot {
        let started = DispatchTime.now().uptimeNanoseconds
        let deadline = started.addingReportingOverflow(
            maximumCaptureNanoseconds
        )
        guard !deadline.overflow,
              rootDescriptor >= 3,
              fcntl(rootDescriptor, F_GETFD) & FD_CLOEXEC != 0
        else {
            throw primeIdentityRejected("root_descriptor")
        }
        _ = try PrimeNativeNeuralGateHeldSourceClosure.requireLocalAPFS(
            rootDescriptor: rootDescriptor
        )

        var directoryPaths: Set<String> = [""]
        for file in sourceSnapshot.files {
            let components = file.relativePath.split(separator: "/")
            for count in 1 ..< components.count {
                directoryPaths.insert(
                    components.prefix(count).joined(separator: "/")
                )
            }
        }
        let orderedDirectories = directoryPaths.sorted {
            let lhsDepth = $0.isEmpty
                ? 0 : $0.split(separator: "/").count
            let rhsDepth = $1.isEmpty
                ? 0 : $1.split(separator: "/").count
            if lhsDepth != rhsDepth {
                return lhsDepth < rhsDepth
            }
            return $0 < $1
        }
        guard orderedDirectories.count <= maximumDirectoryCount,
              sourceSnapshot.files.count <= maximumFileCount
        else {
            throw primeIdentityRejected("count")
        }

        var directoryDescriptors: [String: Int32] = [:]
        var directoryStatuses: [String: stat] = [:]
        var fileDescriptors: [String: Int32] = [:]
        var fileStatuses: [String: stat] = [:]
        defer {
            for descriptor in fileDescriptors.values {
                _ = Darwin.close(descriptor)
            }
            for descriptor in directoryDescriptors.values {
                _ = Darwin.close(descriptor)
            }
        }

        let heldRoot = try openRelative(
            directory: rootDescriptor,
            leaf: ".",
            isDirectory: true,
            permitsDot: true
        )
        var rootStatus = stat()
        guard fstat(heldRoot, &rootStatus) == 0,
              isSafeDirectory(rootStatus)
        else {
            _ = Darwin.close(heldRoot)
            throw primeIdentityRejected("root_directory")
        }
        directoryDescriptors[""] = heldRoot
        directoryStatuses[""] = rootStatus
        let expectedDevice = rootStatus.st_dev

        for path in orderedDirectories where !path.isEmpty {
            try requireBeforeDeadline(deadline.partialValue)
            let components = path.split(separator: "/")
            guard let leafComponent = components.last else {
                throw primeIdentityRejected("directory_path")
            }
            let leaf = String(leafComponent)
            let parent = components.dropLast().joined(separator: "/")
            guard let parentDescriptor = directoryDescriptors[parent]
            else {
                throw primeIdentityRejected("directory_parent")
            }
            let descriptor = try openRelative(
                directory: parentDescriptor,
                leaf: leaf,
                isDirectory: true
            )
            var descriptorTransferred = false
            defer {
                if !descriptorTransferred {
                    _ = Darwin.close(descriptor)
                }
            }
            var status = stat()
            guard fstat(descriptor, &status) == 0,
                  status.st_dev == expectedDevice,
                  isSafeDirectory(status),
                  directoryDescriptors[path] == nil
            else {
                throw primeIdentityRejected("directory_join")
            }
            directoryDescriptors[path] = descriptor
            descriptorTransferred = true
            directoryStatuses[path] = status
        }

        for file in sourceSnapshot.files {
            try requireBeforeDeadline(deadline.partialValue)
            let components = file.relativePath.split(separator: "/")
            guard let leafComponent = components.last else {
                throw primeIdentityRejected("file_path")
            }
            let parent = components.dropLast().joined(separator: "/")
            guard let parentDescriptor = directoryDescriptors[parent]
            else {
                throw primeIdentityRejected("file_parent")
            }
            let descriptor = try openRelative(
                directory: parentDescriptor,
                leaf: String(leafComponent),
                isDirectory: false
            )
            var descriptorTransferred = false
            defer {
                if !descriptorTransferred {
                    _ = Darwin.close(descriptor)
                }
            }
            var before = stat()
            guard fstat(descriptor, &before) == 0,
                  before.st_dev == expectedDevice,
                  isSafeRegularFile(before),
                  before.st_size >= 0,
                  UInt64(before.st_size) == file.byteCount,
                  file.byteCount <= 8 * 1024 * 1024
            else {
                throw primeIdentityRejected("file_join")
            }
            let data = try readExactDescriptor(
                descriptor,
                byteCount: file.byteCount,
                deadlineNanoseconds: deadline.partialValue
            )
            var after = stat()
            guard fstat(descriptor, &after) == 0,
                  sameRegularFileIdentity(before, after),
                  data == file.contents,
                  PrimeSHA256.hexDigest(of: data) == file.sha256,
                  fileDescriptors[file.relativePath] == nil
            else {
                throw primeIdentityRejected("file_bytes_or_identity")
            }
            fileDescriptors[file.relativePath] = descriptor
            descriptorTransferred = true
            fileStatuses[file.relativePath] = after
        }

        for (path, descriptor) in directoryDescriptors {
            var after = stat()
            guard let before = directoryStatuses[path],
                  fstat(descriptor, &after) == 0,
                  sameDirectoryIdentity(before, after)
            else {
                throw primeIdentityRejected("directory_capture_race")
            }
        }
        for (path, descriptor) in fileDescriptors {
            var after = stat()
            guard let before = fileStatuses[path],
                  fstat(descriptor, &after) == 0,
                  sameRegularFileIdentity(before, after)
            else {
                throw primeIdentityRejected("file_capture_race")
            }
        }
        try requireBeforeDeadline(deadline.partialValue)
        return PrimeSecureHeldLegacySourceIdentitySnapshot(
            directoryIdentities: directoryStatuses.mapValues(
                PrimeSecureHeldNodeIdentity.init
            ),
            fileIdentities: fileStatuses.mapValues(
                PrimeSecureHeldNodeIdentity.init
            )
        )
    }

    private static func captureDirectory(
        descriptor: Int32,
        relativePath: String,
        expectedDevice: dev_t,
        deadlineNanoseconds: UInt64,
        state: inout CaptureState
    ) throws {
        try requireBeforeDeadline(deadlineNanoseconds)
        var directoryBefore = stat()
        guard fstat(descriptor, &directoryBefore) == 0,
              directoryBefore.st_dev == expectedDevice,
              isSafeDirectory(directoryBefore)
        else {
            throw rejected("directory_metadata")
        }
        let entries = try directoryEntries(
            descriptor: descriptor,
            deadlineNanoseconds: deadlineNanoseconds
        )
        let nextEntryCount = state.aggregateDirectoryEntryCount
            .addingReportingOverflow(entries.count)
        guard !nextEntryCount.overflow,
              entries.count <= maximumDirectoryEntryCount,
              nextEntryCount.partialValue
                <= maximumAggregateDirectoryEntryCount
        else {
            throw rejected("directory_entry_count")
        }
        state.aggregateDirectoryEntryCount =
            nextEntryCount.partialValue

        for entry in entries {
            try requireBeforeDeadline(deadlineNanoseconds)
            let childRelativePath = relativePath.isEmpty
                ? entry.name
                : relativePath + "/" + entry.name
            let depth = childRelativePath.split(
                separator: "/"
            ).count
            guard depth <= maximumRelativeDepth
            else {
                throw rejected("relative_depth")
            }
            var named = stat()
            let namedResult = entry.name.withCString {
                fstatat(
                    descriptor,
                    $0,
                    &named,
                    AT_SYMLINK_NOFOLLOW
                )
            }
            guard namedResult == 0,
                  named.st_dev == expectedDevice,
                  named.st_ino > 0,
                  named.st_uid == geteuid(),
                  named.st_mode & mode_t(0o022) == 0
            else {
                throw rejected("entry_metadata")
            }

            if relativePath.isEmpty,
               entry.name == ".git"
            {
                guard named.st_mode & mode_t(S_IFMT)
                        == mode_t(S_IFDIR),
                      state.excludedRootGitDirectoryInode == nil
                else {
                    throw rejected("root_git_directory")
                }
                state.excludedRootGitDirectoryDeviceID =
                    Int32(named.st_dev)
                state.excludedRootGitDirectoryInode =
                    UInt64(named.st_ino)
                continue
            }

            switch named.st_mode & mode_t(S_IFMT) {
            case mode_t(S_IFDIR):
                guard state.directoryRelativePaths.count + 1
                        <= maximumDirectoryCount
                else {
                    throw rejected("directory_count")
                }
                let child = try openRelative(
                    directory: descriptor,
                    leaf: entry.name,
                    isDirectory: true
                )
                defer { _ = Darwin.close(child) }
                var opened = stat()
                guard fstat(child, &opened) == 0,
                      sameDirectoryIdentity(named, opened),
                      isSafeDirectory(opened)
                else {
                    throw rejected("directory_join")
                }
                state.directoryRelativePaths.append(
                    childRelativePath
                )
                try captureDirectory(
                    descriptor: child,
                    relativePath: childRelativePath,
                    expectedDevice: expectedDevice,
                    deadlineNanoseconds: deadlineNanoseconds,
                    state: &state
                )
                var childAfter = stat()
                var namedAfter = stat()
                let namedAfterResult = entry.name.withCString {
                    fstatat(
                        descriptor,
                        $0,
                        &namedAfter,
                        AT_SYMLINK_NOFOLLOW
                    )
                }
                guard fstat(child, &childAfter) == 0,
                      namedAfterResult == 0,
                      sameDirectoryIdentity(opened, childAfter),
                      sameDirectoryIdentity(opened, namedAfter)
                else {
                    throw rejected("directory_read_race")
                }
            case mode_t(S_IFREG):
                guard state.files.count + 1
                        <= maximumFileCount,
                      named.st_nlink == 1,
                      named.st_size >= 0,
                      UInt64(named.st_size)
                        <= maximumFileByteCount
                else {
                    throw rejected("file_metadata")
                }
                let child = try openRelative(
                    directory: descriptor,
                    leaf: entry.name,
                    isDirectory: false
                )
                defer { _ = Darwin.close(child) }
                var opened = stat()
                guard fstat(child, &opened) == 0,
                      sameRegularFileIdentity(named, opened),
                      isSafeRegularFile(opened)
                else {
                    throw rejected("file_join")
                }
                let byteCount = UInt64(opened.st_size)
                let nextAggregate = state.aggregateFileByteCount
                    .addingReportingOverflow(byteCount)
                guard !nextAggregate.overflow,
                      nextAggregate.partialValue
                        <= maximumAggregateByteCount
                else {
                    throw rejected("file_aggregate")
                }
                let data = try readExactDescriptor(
                    child,
                    byteCount: byteCount,
                    deadlineNanoseconds: deadlineNanoseconds
                )
                var childAfter = stat()
                var namedAfter = stat()
                let namedAfterResult = entry.name.withCString {
                    fstatat(
                        descriptor,
                        $0,
                        &namedAfter,
                        AT_SYMLINK_NOFOLLOW
                    )
                }
                guard fstat(child, &childAfter) == 0,
                      namedAfterResult == 0,
                      sameRegularFileIdentity(opened, childAfter),
                      sameRegularFileIdentity(opened, namedAfter)
                else {
                    throw rejected("file_read_race")
                }
                state.aggregateFileByteCount =
                    nextAggregate.partialValue
                state.files.append(
                    PrimeSecureHeldFileSnapshot(
                        relativePath: childRelativePath,
                        sha256:
                            PrimeSHA256.hexDigest(of: data),
                        byteCount: byteCount,
                        contents: data
                    )
                )
                guard state.fileIdentities.updateValue(
                    PrimeSecureHeldNodeIdentity(childAfter),
                    forKey: childRelativePath
                ) == nil else {
                    throw rejected("duplicate_file_identity")
                }
            default:
                throw rejected("unsupported_entry")
            }
        }
        var directoryAfter = stat()
        guard fstat(descriptor, &directoryAfter) == 0,
              sameDirectoryIdentity(
                  directoryBefore,
                  directoryAfter
              )
        else {
            throw rejected("directory_capture_race")
        }
        guard state.directoryIdentities.updateValue(
            PrimeSecureHeldNodeIdentity(directoryAfter),
            forKey: relativePath
        ) == nil else {
            throw rejected("duplicate_directory_identity")
        }
    }

    private static func directoryEntries(
        descriptor: Int32,
        deadlineNanoseconds: UInt64
    ) throws -> [DirectoryEntry] {
        let independent = try openRelative(
            directory: descriptor,
            leaf: ".",
            isDirectory: true,
            permitsDot: true
        )
        guard let directory = fdopendir(independent)
        else {
            let failure = errno
            _ = Darwin.close(independent)
            throw rejected("fdopendir_\(failure)")
        }
        defer { _ = closedir(directory) }
        var entries: [DirectoryEntry] = []
        while true {
            try requireBeforeDeadline(deadlineNanoseconds)
            errno = 0
            guard let pointer = readdir(directory)
            else {
                guard errno == 0 else {
                    throw rejected("readdir_\(errno)")
                }
                break
            }
            let value = pointer.pointee
            let length = Int(value.d_namlen)
            guard length > 0,
                  length <= Int(MAXNAMLEN)
            else {
                throw rejected("entry_name_length")
            }
            var field = value.d_name
            let bytes = withUnsafeBytes(of: &field) {
                Array($0.prefix(length))
            }
            guard bytes.allSatisfy({
                $0 >= 0x20 && $0 <= 0x7e
            }),
            let name = String(
                bytes: bytes,
                encoding: .utf8
            ),
            !name.isEmpty,
            name != ".",
            name != "..",
            !name.contains("/"),
            !name.utf8.contains(0)
            else {
                if bytes == [0x2e]
                    || bytes == [0x2e, 0x2e]
                {
                    continue
                }
                throw rejected("entry_name")
            }
            entries.append(DirectoryEntry(name: name))
            guard entries.count <= maximumDirectoryEntryCount
            else {
                throw rejected("directory_entry_count")
            }
        }
        entries.sort {
            rawUTF8Precedes($0.name, $1.name)
        }
        guard Set(entries.map(\.name)).count
                == entries.count
        else {
            throw rejected("duplicate_entry")
        }
        return entries
    }

    private static func openRelative(
        directory: Int32,
        leaf: String,
        isDirectory: Bool,
        permitsDot: Bool = false
    ) throws -> Int32 {
        guard directory >= 3,
              !leaf.isEmpty,
              !leaf.contains("/"),
              !leaf.utf8.contains(0),
              (permitsDot && leaf == "."
                  || leaf != "." && leaf != "..")
        else {
            throw rejected("relative_leaf")
        }
        let opened = leaf.withCString {
            openat(
                directory,
                $0,
                O_RDONLY
                    | O_NOFOLLOW_ANY
                    | O_CLOEXEC
                    | (isDirectory ? O_DIRECTORY : 0)
            )
        }
        guard opened >= 3,
              fcntl(opened, F_GETFD) & FD_CLOEXEC != 0
        else {
            let failure = errno
            if opened >= 0 {
                _ = Darwin.close(opened)
            }
            throw rejected("open_\(failure)")
        }
        return opened
    }

    private static func readExactDescriptor(
        _ descriptor: Int32,
        byteCount: UInt64,
        deadlineNanoseconds: UInt64
    ) throws -> Data {
        guard byteCount <= maximumFileByteCount,
              byteCount <= UInt64(Int.max)
        else {
            throw rejected("read_bound")
        }
        var result = Data()
        result.reserveCapacity(Int(byteCount))
        var offset: UInt64 = 0
        var buffer = [UInt8](
            repeating: 0,
            count: 64 * 1024
        )
        while offset < byteCount {
            try requireBeforeDeadline(deadlineNanoseconds)
            let request = min(
                buffer.count,
                Int(byteCount - offset)
            )
            errno = 0
            let count = buffer.withUnsafeMutableBytes {
                pread(
                    descriptor,
                    $0.baseAddress,
                    request,
                    off_t(offset)
                )
            }
            if count < 0, errno == EINTR {
                continue
            }
            guard count > 0 else {
                throw rejected("read_\(errno)")
            }
            result.append(contentsOf: buffer.prefix(count))
            offset += UInt64(count)
        }
        var trailing: UInt8 = 0
        let trailingCount = withUnsafeMutablePointer(to: &trailing) {
            pread(
                descriptor,
                $0,
                1,
                off_t(byteCount)
            )
        }
        guard trailingCount == 0,
              result.count == Int(byteCount)
        else {
            throw rejected("read_trailing")
        }
        return result
    }

    private static func isSafeDirectory(_ value: stat) -> Bool {
        value.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR)
            && value.st_uid == geteuid()
            && value.st_mode & mode_t(0o022) == 0
            && value.st_ino > 0
    }

    private static func isSafeRegularFile(_ value: stat) -> Bool {
        value.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG)
            && value.st_uid == geteuid()
            && value.st_mode & mode_t(0o022) == 0
            && value.st_nlink == 1
            && value.st_size >= 0
            && UInt64(value.st_size) <= maximumFileByteCount
            && value.st_ino > 0
    }

    private static func sameDirectoryIdentity(
        _ lhs: stat,
        _ rhs: stat
    ) -> Bool {
        lhs.st_dev == rhs.st_dev
            && lhs.st_ino == rhs.st_ino
            && lhs.st_uid == rhs.st_uid
            && lhs.st_gid == rhs.st_gid
            && lhs.st_mode == rhs.st_mode
            && lhs.st_nlink == rhs.st_nlink
            && lhs.st_mtimespec.tv_sec == rhs.st_mtimespec.tv_sec
            && lhs.st_mtimespec.tv_nsec == rhs.st_mtimespec.tv_nsec
            && lhs.st_ctimespec.tv_sec == rhs.st_ctimespec.tv_sec
            && lhs.st_ctimespec.tv_nsec == rhs.st_ctimespec.tv_nsec
    }

    private static func sameRegularFileIdentity(
        _ lhs: stat,
        _ rhs: stat
    ) -> Bool {
        sameDirectoryIdentity(lhs, rhs)
            && lhs.st_size == rhs.st_size
    }

    private static func directoryPathPrecedes(
        _ lhs: String,
        _ rhs: String
    ) -> Bool {
        let lhsDepth = lhs.isEmpty
            ? 0 : lhs.split(separator: "/").count
        let rhsDepth = rhs.isEmpty
            ? 0 : rhs.split(separator: "/").count
        if lhsDepth != rhsDepth {
            return lhsDepth < rhsDepth
        }
        return rawUTF8Precedes(lhs, rhs)
    }

    private static func rawUTF8Precedes(
        _ lhs: String,
        _ rhs: String
    ) -> Bool {
        lhs.utf8.lexicographicallyPrecedes(rhs.utf8)
    }

    private static func requireBeforeDeadline(
        _ deadlineNanoseconds: UInt64
    ) throws {
        guard DispatchTime.now().uptimeNanoseconds
                <= deadlineNanoseconds
        else {
            throw rejected("capture_deadline")
        }
    }

    private static func rejected(
        _ detail: String
    ) -> PrimeValidationSwiftPMBuildInventoryAdmissionError {
        .rejected("companion_working_tree_\(detail)")
    }

    private static func primeIdentityRejected(
        _ detail: String
    ) -> PrimeValidationSwiftPMBuildInventoryAdmissionError {
        .rejected("prime_source_identity_\(detail)")
    }
}

/// Domain-neutral live wrapper over Prime's maintained descriptor and kqueue
/// source-closure mechanics.
///
/// The underlying implementation predates the validation executor and keeps
/// its historical type name for source compatibility. This wrapper prevents
/// the new validation boundary from duplicating that security-sensitive
/// implementation or treating a neural-gate receipt as its authority.
final class PrimeSecureHeldSourceWatch {
    private let implementation:
        PrimeNativeNeuralGateHeldSourceClosure

    init(
        rootDescriptor: Int32,
        sourceSnapshot: PrimeSwiftSourceSnapshot,
        admissionIdentitySnapshot:
            PrimeSecureHeldLegacySourceIdentitySnapshot? = nil
    ) throws {
        implementation = try
            PrimeNativeNeuralGateHeldSourceClosure(
                rootDescriptor: rootDescriptor,
                sourceSnapshot: sourceSnapshot,
                sourceAdmissionStartedMonotonicNanoseconds:
                    DispatchTime.now().uptimeNanoseconds,
                sourceAdmissionMaximumSeconds: 30,
                admissionIdentitySnapshot:
                    admissionIdentitySnapshot
            )
    }

    static func expectedWatcherDescriptorCount(
        sourceSnapshot: PrimeSwiftSourceSnapshot
    ) -> Int {
        var directories: Set<String> = [""]
        for file in sourceSnapshot.files {
            let components = file.relativePath.split(separator: "/")
            for count in 1 ..< components.count {
                directories.insert(
                    components.prefix(count).joined(separator: "/")
                )
            }
        }
        return sourceSnapshot.files.count + directories.count
    }

    static func expectedWatcherDescriptorCount(
        completeWorkingTreeSnapshot:
            PrimeSecureHeldWorkingTreeSnapshot
    ) -> Int {
        completeWorkingTreeSnapshot.files.count
            + completeWorkingTreeSnapshot.directoryRelativePaths.count
    }

    init(
        rootDescriptor: Int32,
        completeWorkingTreeSnapshot:
            PrimeSecureHeldWorkingTreeSnapshot
    ) throws {
        implementation = try
            PrimeNativeNeuralGateHeldSourceClosure(
                rootDescriptor: rootDescriptor,
                completeWorkingTreeFiles:
                    completeWorkingTreeSnapshot.files,
                completeWorkingTreeDirectoryRelativePaths:
                    completeWorkingTreeSnapshot.directoryRelativePaths,
                excludedRootGitDirectoryInode:
                    completeWorkingTreeSnapshot
                    .excludedRootGitDirectoryInode,
                excludedRootGitDirectoryDeviceID:
                    completeWorkingTreeSnapshot
                    .excludedRootGitDirectoryDeviceID,
                expectedDirectoryIdentities:
                    completeWorkingTreeSnapshot.directoryIdentities,
                expectedFileIdentities:
                    completeWorkingTreeSnapshot.fileIdentities,
                snapshotIdentitySHA256:
                    completeWorkingTreeSnapshot.identitySHA256,
                maximumFileByteCount:
                    PrimeSecureHeldWorkingTreeSnapshot
                    .maximumFileByteCount
            )
    }

    func revalidateWhilePrepared() throws -> UInt64 {
        try implementation.validateWhilePrepared()
    }

    var heldWatcherDescriptorCount: Int {
        implementation.heldWatcherDescriptorCount
    }
}
