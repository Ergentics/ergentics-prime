#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif
import CryptoKit
import Dispatch
import Foundation

/// A live, non-serializable proof that an exact artifact inventory was
/// observed through the already-admitted `PrimeArtifactRoot` descriptor.
///
/// The Codable inventory is transport data. It cannot be upgraded to
/// authority by setting its Boolean fields. Only this closed capability can
/// establish that Prime performed the descriptor-rooted observation.
public final class PrimeTrustedArtifactInventoryCapture:
    @unchecked Sendable
{
    public let inventory:
        PrimeNativeNeuralGateRealizedFilesystemInventory

    private let anchorDescriptor: Int32
    private let scopedDescriptor: Int32
    private let rootRelativePath: String?
    private let expectedArtifacts:
        [PrimeArtifactBinding]
    private let scopedIdentity: DescriptorIdentity
    private let nodeIdentities:
        [String: DescriptorIdentity]
    private let filesystemIdentity:
        LocalAPFSFilesystemIdentity

    private static let maximumArtifactCount =
        8_192
    private static let maximumDirectoryCount =
        8_192
    private static let maximumAggregateByteCount:
        UInt64 = 8 * 1024 * 1024 * 1024
    private static let maximumCaptureNanoseconds:
        UInt64 = 300 * 1_000_000_000

    fileprivate init(
        anchorDescriptor: Int32,
        rootRelativePath: String?,
        expectedArtifacts: [PrimeArtifactBinding]
    ) throws {
        self.anchorDescriptor = anchorDescriptor
        self.rootRelativePath = rootRelativePath
        self.expectedArtifacts =
            try Self.normalizedExpectedArtifacts(
                expectedArtifacts,
                rootRelativePath: rootRelativePath
            )
        do {
            let anchorStatus =
                try Self.requirePrivateDirectory(
                    anchorDescriptor,
                    path: "<artifact-root>"
                )
            filesystemIdentity =
                try Self.localAPFSFilesystemIdentity(
                    descriptor:
                        anchorDescriptor,
                    status: anchorStatus,
                    path: "<artifact-root>"
                )
            scopedDescriptor =
                try Self.openScopedRoot(
                    anchorDescriptor:
                        anchorDescriptor,
                    rootRelativePath:
                        rootRelativePath,
                    expectedFilesystem:
                        filesystemIdentity
                )
            do {
                let scopedStatus =
                    try Self.requirePrivateDirectory(
                        scopedDescriptor,
                        path:
                            rootRelativePath
                                ?? "<artifact-root>"
                    )
                try Self.requireFilesystemIdentity(
                    descriptor:
                        scopedDescriptor,
                    status: scopedStatus,
                    expected:
                        filesystemIdentity,
                    path:
                        rootRelativePath
                            ?? "<artifact-root>"
                )
                scopedIdentity =
                    Self.identity(scopedStatus)
                let snapshot =
                    try Self.captureInventory(
                        scopedDescriptor:
                            scopedDescriptor,
                        rootRelativePath:
                            rootRelativePath,
                        expectedArtifacts:
                            self.expectedArtifacts,
                        expectedFilesystem:
                            filesystemIdentity
                    )
                inventory = snapshot.inventory
                nodeIdentities =
                    snapshot.nodeIdentities
            } catch {
                _ = close(scopedDescriptor)
                throw error
            }
        } catch {
            _ = close(anchorDescriptor)
            throw error
        }
    }

    deinit {
        _ = close(scopedDescriptor)
        _ = close(anchorDescriptor)
    }

    /// Re-opens the scope below the retained root capability and requires the
    /// same root inode and exact immutable inventory to remain present.
    @discardableResult
    public func recaptureAndValidateUnchanged()
        throws
        -> PrimeNativeNeuralGateRealizedFilesystemInventory
    {
        let reopened = try Self.openScopedRoot(
            anchorDescriptor:
                anchorDescriptor,
            rootRelativePath:
                rootRelativePath,
            expectedFilesystem:
                filesystemIdentity
        )
        defer { _ = close(reopened) }
        let reopenedStatus =
            try Self.requirePrivateDirectory(
                reopened,
                path:
                    rootRelativePath
                        ?? "<artifact-root>"
            )
        try Self.requireFilesystemIdentity(
            descriptor: reopened,
            status: reopenedStatus,
            expected: filesystemIdentity,
            path:
                rootRelativePath
                    ?? "<artifact-root>"
        )
        let reopenedIdentity =
            Self.identity(reopenedStatus)
        guard reopenedIdentity == scopedIdentity else {
            throw Self.invalid(
                "trusted_inventory_root_identity_changed"
            )
        }
        let recaptured =
            try Self.captureInventory(
                scopedDescriptor: reopened,
                rootRelativePath:
                    rootRelativePath,
                expectedArtifacts:
                    expectedArtifacts,
                expectedFilesystem:
                    filesystemIdentity
            )
        guard recaptured.inventory == inventory,
              recaptured.nodeIdentities
                == nodeIdentities
        else {
            throw Self.invalid(
                "trusted_inventory_changed"
            )
        }
        return recaptured.inventory
    }

    /// Requires a decoded transport inventory to equal a fresh observation
    /// made through this retained capability.
    public func validateCurrentInventory(
        equals declared:
            PrimeNativeNeuralGateRealizedFilesystemInventory
    ) throws {
        let current =
            try recaptureAndValidateUnchanged()
        guard current == declared else {
            throw Self.invalid(
                "trusted_inventory_declared_value_mismatch"
            )
        }
    }

    private struct DescriptorIdentity:
        Equatable
    {
        let device: UInt64
        let inode: UInt64
        let mode: UInt32
        let owner: UInt32
        let linkCount: UInt64
        let byteCount: Int64
        let modificationSeconds: Int64
        let modificationNanoseconds: Int64
        let statusChangeSeconds: Int64
        let statusChangeNanoseconds: Int64
    }

    private struct LocalAPFSFilesystemIdentity:
        Equatable
    {
        let device: UInt64
        let fsidWord0: Int32
        let fsidWord1: Int32
    }

    private struct CapturedSnapshot {
        let inventory:
            PrimeNativeNeuralGateRealizedFilesystemInventory
        let nodeIdentities:
            [String: DescriptorIdentity]
    }

    private static func normalizedExpectedArtifacts(
        _ artifacts: [PrimeArtifactBinding],
        rootRelativePath: String?
    ) throws -> [PrimeArtifactBinding] {
        guard artifacts.count
                <= maximumArtifactCount
        else {
            throw invalid(
                "trusted_inventory_artifact_count_bound"
            )
        }
        try artifacts.forEach {
            try $0.validateDeclaration()
        }
        let sorted = artifacts.sorted {
            rawUTF8Less(
                $0.relativePath,
                $1.relativePath
            )
        }
        let aggregateBytes =
            sorted.reduce(
                UInt64(0)
            ) {
                partial, artifact in
                let (next, overflow) =
                    partial
                    .addingReportingOverflow(
                        artifact.byteCount
                    )
                return overflow
                    ? UInt64.max : next
            }
        guard aggregateBytes
                <= maximumAggregateByteCount,
              Set(
                  sorted.map(\.relativePath)
              ).count == sorted.count,
              sorted.allSatisfy({
                  $0.relativePath.utf8.count
                      <= 4_096
                      && (
                          try? safeComponents(
                              $0.relativePath
                          ).count <= 32
                      ) == true
              })
        else {
            throw invalid(
                "trusted_inventory_expected_bounds_or_identity"
            )
        }
        if let rootRelativePath {
            let rootComponents =
                try safeComponents(
                    rootRelativePath
                )
            guard sorted.allSatisfy({
                guard let components =
                        try? safeComponents(
                            $0.relativePath
                        )
                else {
                    return false
                }
                return components.count
                        > rootComponents.count
                    && Array(
                        components.prefix(
                            rootComponents.count
                        )
                    ) == rootComponents
            }) else {
                throw invalid(
                    "trusted_inventory_expected_path_outside_scope"
                )
            }
        }
        return sorted
    }

    private static func openScopedRoot(
        anchorDescriptor: Int32,
        rootRelativePath: String?,
        expectedFilesystem:
            LocalAPFSFilesystemIdentity
    ) throws -> Int32 {
        var current = fcntl(
            anchorDescriptor,
            F_DUPFD_CLOEXEC,
            0
        )
        guard current >= 0 else {
            throw posix(
                "duplicate trusted inventory anchor",
                rootRelativePath
                    ?? "<artifact-root>"
            )
        }
        do {
            let anchorStatus =
                try requirePrivateDirectory(
                current,
                path: "<artifact-root>"
            )
            try requireFilesystemIdentity(
                descriptor: current,
                status: anchorStatus,
                expected:
                    expectedFilesystem,
                path: "<artifact-root>"
            )
            guard let rootRelativePath else {
                return current
            }
            for component in
                try safeComponents(rootRelativePath)
            {
                let next =
                    component.withCString {
                        openat(
                            current,
                            $0,
                            O_RDONLY
                                | O_DIRECTORY
                                | O_NOFOLLOW
                                | O_CLOEXEC
                        )
                    }
                guard next >= 0 else {
                    throw posix(
                        "open trusted inventory scope",
                        rootRelativePath
                    )
                }
                _ = close(current)
                current = next
                let componentStatus =
                    try requirePrivateDirectory(
                    current,
                    path:
                        rootRelativePath
                )
                try requireFilesystemIdentity(
                    descriptor: current,
                    status: componentStatus,
                    expected:
                        expectedFilesystem,
                    path: rootRelativePath
                )
            }
            return current
        } catch {
            _ = close(current)
            throw error
        }
    }

    private static func captureInventory(
        scopedDescriptor: Int32,
        rootRelativePath: String?,
        expectedArtifacts:
            [PrimeArtifactBinding],
        expectedFilesystem:
            LocalAPFSFilesystemIdentity
    ) throws
        -> CapturedSnapshot
    {
        let expectedByPath =
            Dictionary(
                uniqueKeysWithValues:
                    expectedArtifacts.map {
                        ($0.relativePath, $0)
                    }
            )
        let expectedDirectoryPaths =
            Set(
                PrimeNativeNeuralGateRealizedFilesystemInventory
                    .requiredDirectoryRelativePaths(
                        forFileRelativePaths:
                            expectedArtifacts
                            .map(\.relativePath),
                        excludingRootRelativePath:
                            rootRelativePath
                    )
            )
        guard expectedDirectoryPaths.count
                <= maximumDirectoryCount
        else {
            throw invalid(
                "trusted_inventory_directory_bound"
            )
        }
        var observedDirectories =
            [PrimeNativeNeuralGateRealizedDirectoryEntry]()
        var observedFiles =
            [PrimeNativeNeuralGateRealizedOutputEntry]()
        var unsupportedPaths = [String]()
        var observedPaths = Set<String>()
        var nodeIdentities =
            [String: DescriptorIdentity]()
        let deadline =
            try captureDeadline()

        try enumerate(
            descriptor: scopedDescriptor,
            relativeDirectory:
                rootRelativePath,
            expectedByPath:
                expectedByPath,
            expectedDirectoryPaths:
                expectedDirectoryPaths,
            observedDirectories:
                &observedDirectories,
            observedFiles: &observedFiles,
            unsupportedPaths:
                &unsupportedPaths,
            observedPaths: &observedPaths,
            nodeIdentities:
                &nodeIdentities,
            expectedFilesystem:
                expectedFilesystem,
            maximumObservedNodeCount:
                expectedByPath.count
                    + expectedDirectoryPaths.count,
            deadlineNanoseconds:
                deadline,
            depth: 0
        )

        let expectedPaths =
            Set(expectedArtifacts.map(\.relativePath))
                .union(expectedDirectoryPaths)
        guard observedPaths == expectedPaths else {
            throw invalid(
                "trusted_inventory_node_closure"
            )
        }
        observedDirectories.sort {
            rawUTF8Less(
                $0.relativePath,
                $1.relativePath
            )
        }
        observedFiles.sort {
            rawUTF8Less(
                $0.artifact.relativePath,
                $1.artifact.relativePath
            )
        }
        unsupportedPaths.sort(
            by: rawUTF8Less
        )
        let inventory =
            PrimeNativeNeuralGateRealizedFilesystemInventory(
                rootRelativePath:
                    rootRelativePath,
                directoryEntries:
                    observedDirectories,
                fileEntries: observedFiles,
                unsupportedNodeRelativePaths:
                    unsupportedPaths,
                enumerationIncludesAllNodeTypes:
                    true,
                symbolicLinksFollowed: false
            )
        let expectedEntries =
            expectedArtifacts.map {
                PrimeNativeNeuralGateRealizedOutputEntry(
                    artifact: $0,
                    posixMode:
                        modeString(
                            for: $0.purpose
                        ),
                    fileType: "regular_file",
                    linkCount: 1,
                    ownerMatchesCurrentEffectiveUser:
                        true,
                    capturedFromDescriptor: true
                )
            }
        try inventory.validateExactNodeClosure(
            expectedFileEntries:
                expectedEntries
        )
        return CapturedSnapshot(
            inventory: inventory,
            nodeIdentities:
                nodeIdentities
        )
    }

    private static func enumerate(
        descriptor: Int32,
        relativeDirectory: String?,
        expectedByPath:
            [String: PrimeArtifactBinding],
        expectedDirectoryPaths: Set<String>,
        observedDirectories:
            inout [PrimeNativeNeuralGateRealizedDirectoryEntry],
        observedFiles:
            inout [PrimeNativeNeuralGateRealizedOutputEntry],
        unsupportedPaths: inout [String],
        observedPaths: inout Set<String>,
        nodeIdentities:
            inout [String: DescriptorIdentity],
        expectedFilesystem:
            LocalAPFSFilesystemIdentity,
        maximumObservedNodeCount: Int,
        deadlineNanoseconds: UInt64,
        depth: Int
    ) throws {
        try requireBeforeDeadline(
            deadlineNanoseconds
        )
        guard depth <= 32 else {
            throw invalid(
                "trusted_inventory_depth_bound"
            )
        }
        let before =
            try requirePrivateDirectory(
                descriptor,
                path:
                    relativeDirectory
                        ?? "<artifact-root>"
            )
        try requireFilesystemIdentity(
            descriptor: descriptor,
            status: before,
            expected:
                expectedFilesystem,
            path:
                relativeDirectory
                    ?? "<artifact-root>"
        )
        let names =
            try directoryEntryNames(
                descriptor,
                path:
                    relativeDirectory
                        ?? "<artifact-root>",
                maximumEntryCount:
                    max(
                        1,
                        maximumObservedNodeCount
                    ),
                deadlineNanoseconds:
                    deadlineNanoseconds
            )
        for name in names {
            let path: String
            if let relativeDirectory {
                path =
                    relativeDirectory
                    + "/"
                    + name
            } else {
                path = name
            }
            guard observedPaths.insert(path)
                    .inserted,
                  observedPaths.count
                    <= maximumObservedNodeCount
            else {
                throw invalid(
                    "trusted_inventory_duplicate_observed_path"
                )
            }
            var named = stat()
            let status =
                name.withCString {
                    fstatat(
                        descriptor,
                        $0,
                        &named,
                        AT_SYMLINK_NOFOLLOW
                    )
                }
            guard status == 0 else {
                throw posix(
                    "inspect trusted inventory node",
                    path
                )
            }
            switch named.st_mode & mode_t(S_IFMT) {
            case mode_t(S_IFDIR):
                guard expectedDirectoryPaths
                        .contains(path) else {
                    throw invalid(
                        "trusted_inventory_unexpected_directory"
                    )
                }
                let child =
                    name.withCString {
                        openat(
                            descriptor,
                            $0,
                            O_RDONLY
                                | O_DIRECTORY
                                | O_NOFOLLOW
                                | O_CLOEXEC
                        )
                    }
                guard child >= 0 else {
                    throw posix(
                        "open trusted inventory directory",
                        path
                    )
                }
                do {
                    let opened =
                        try requirePrivateDirectory(
                            child,
                            path: path
                        )
                    try requireFilesystemIdentity(
                        descriptor: child,
                        status: opened,
                        expected:
                            expectedFilesystem,
                        path: path
                    )
                    try requireSameNode(
                        opened: opened,
                        named: named,
                        path: path
                    )
                    observedDirectories.append(
                        .init(
                            relativePath: path,
                            posixMode: "0700",
                            ownerMatchesCurrentEffectiveUser:
                                true,
                            capturedFromDescriptor:
                                true
                        )
                    )
                    nodeIdentities[path] =
                        identity(opened)
                    try enumerate(
                        descriptor: child,
                        relativeDirectory:
                            path,
                        expectedByPath:
                            expectedByPath,
                        expectedDirectoryPaths:
                            expectedDirectoryPaths,
                        observedDirectories:
                            &observedDirectories,
                        observedFiles:
                            &observedFiles,
                        unsupportedPaths:
                            &unsupportedPaths,
                        observedPaths:
                            &observedPaths,
                        nodeIdentities:
                            &nodeIdentities,
                        expectedFilesystem:
                            expectedFilesystem,
                        maximumObservedNodeCount:
                            maximumObservedNodeCount,
                        deadlineNanoseconds:
                            deadlineNanoseconds,
                        depth: depth + 1
                    )
                    try requireStableNamedNode(
                        descriptor: child,
                        parentDescriptor:
                            descriptor,
                        leaf: name,
                        before: opened,
                        path: path
                    )
                } catch {
                    _ = close(child)
                    throw error
                }
                _ = close(child)
            case mode_t(S_IFREG):
                guard let expected =
                        expectedByPath[path] else {
                    throw invalid(
                        "trusted_inventory_unexpected_file"
                    )
                }
                let captured =
                    try captureFile(
                        parentDescriptor:
                            descriptor,
                        leaf: name,
                        path: path,
                        named: named,
                        expected: expected,
                        expectedFilesystem:
                            expectedFilesystem,
                        deadlineNanoseconds:
                            deadlineNanoseconds
                    )
                observedFiles.append(
                    captured.entry
                )
                nodeIdentities[path] =
                    captured.identity
            default:
                unsupportedPaths.append(path)
            }
        }
        let after =
            try requirePrivateDirectory(
                descriptor,
                path:
                    relativeDirectory
                        ?? "<artifact-root>"
            )
        try requireFilesystemIdentity(
            descriptor: descriptor,
            status: after,
            expected:
                expectedFilesystem,
            path:
                relativeDirectory
                    ?? "<artifact-root>"
        )
        try requireStableMetadata(
            before,
            after,
            path:
                relativeDirectory
                    ?? "<artifact-root>"
        )
        guard unsupportedPaths.isEmpty else {
            throw invalid(
                "trusted_inventory_unsupported_node"
            )
        }
    }

    private static func captureFile(
        parentDescriptor: Int32,
        leaf: String,
        path: String,
        named: stat,
        expected: PrimeArtifactBinding,
        expectedFilesystem:
            LocalAPFSFilesystemIdentity,
        deadlineNanoseconds: UInt64
    ) throws
        -> (
            entry:
                PrimeNativeNeuralGateRealizedOutputEntry,
            identity: DescriptorIdentity
        )
    {
        let opened =
            leaf.withCString {
                openat(
                    parentDescriptor,
                    $0,
                    O_RDONLY
                        | O_NONBLOCK
                        | O_NOFOLLOW
                        | O_CLOEXEC
                )
            }
        guard opened >= 0 else {
            throw posix(
                "open trusted inventory file",
                path
            )
        }
        defer { _ = close(opened) }
        var before = stat()
        guard fstat(opened, &before) == 0,
              before.st_size >= 0 else {
            throw posix(
                "inspect trusted inventory file",
                path
            )
        }
        try requireSameNode(
            opened: before,
            named: named,
            path: path
        )
        try requireFilesystemIdentity(
            descriptor: opened,
            status: before,
            expected:
                expectedFilesystem,
            path: path
        )
        let expectedMode =
            expected.purpose == .executable
                ? mode_t(0o555)
                : mode_t(0o444)
        guard before.st_mode & mode_t(S_IFMT)
                == mode_t(S_IFREG),
              before.st_uid == geteuid(),
              before.st_nlink == 1,
              before.st_mode & mode_t(0o7777)
                == expectedMode,
              UInt64(before.st_size)
                == expected.byteCount
        else {
            throw PrimeDurableArtifactError
                .unsafeArtifact(path)
        }
        try PrimeArtifactRoot
            .requireTrustedInventoryArtifactDescriptor(
                opened,
                path: path
            )
        try requireBoundedOpaqueProvenance(
            opened,
            path: path
        )
        let observedDigest =
            try digest(
                descriptor: opened,
                expectedByteCount:
                    expected.byteCount,
                path: path,
                deadlineNanoseconds:
                    deadlineNanoseconds
            )
        guard observedDigest == expected.sha256 else {
            throw PrimeDurableArtifactError
                .hashMismatch(
                    path: path,
                    expected: expected.sha256,
                    actual: observedDigest
                )
        }
        try requireStableNamedNode(
            descriptor: opened,
            parentDescriptor:
                parentDescriptor,
            leaf: leaf,
            before: before,
            path: path
        )
        return (
            .init(
                artifact: expected,
                posixMode:
                    modeString(
                        for: expected.purpose
                    ),
                fileType: "regular_file",
                linkCount:
                    UInt64(before.st_nlink),
                ownerMatchesCurrentEffectiveUser:
                    true,
                capturedFromDescriptor: true
            ),
            identity(before)
        )
    }

    private static func directoryEntryNames(
        _ descriptor: Int32,
        path: String,
        maximumEntryCount: Int,
        deadlineNanoseconds: UInt64
    ) throws -> [String] {
        let independent =
            ".".withCString {
                openat(
                    descriptor,
                    $0,
                    O_RDONLY
                        | O_DIRECTORY
                        | O_NOFOLLOW
                        | O_CLOEXEC
                )
            }
        guard independent >= 0 else {
            throw posix(
                "open independent trusted inventory directory",
                path
            )
        }
        guard let directory = fdopendir(independent)
        else {
            let openError = errno
            _ = close(independent)
            throw PrimeDurableArtifactError.posix(
                operation:
                    "enumerate trusted inventory directory",
                path: path,
                code: openError
            )
        }
        defer { _ = closedir(directory) }
        var names = [String]()
        errno = 0
        while let entry = readdir(directory) {
            try requireBeforeDeadline(
                deadlineNanoseconds
            )
            let name =
                try exactDirectoryEntryName(
                    entry
                )
            if name != ".", name != ".." {
                guard !name.isEmpty,
                      !name.contains("/"),
                      !name.utf8.contains(0)
                else {
                    throw invalid(
                        "trusted_inventory_invalid_directory_entry"
                    )
                }
                names.append(name)
                guard names.count
                        <= maximumEntryCount
                else {
                    throw invalid(
                        "trusted_inventory_directory_entry_bound"
                    )
                }
            }
            errno = 0
        }
        guard errno == 0 else {
            throw posix(
                "enumerate trusted inventory directory",
                path
            )
        }
        names.sort(
            by: rawUTF8Less
        )
        return names
    }

    private static func requirePrivateDirectory(
        _ descriptor: Int32,
        path: String
    ) throws -> stat {
        try PrimeArtifactRoot
            .requireTrustedInventoryDirectoryDescriptor(
                descriptor,
                path: path
            )
        try requireBoundedOpaqueProvenance(
            descriptor,
            path: path
        )
        var metadata = stat()
        guard fstat(descriptor, &metadata) == 0,
              metadata.st_mode & mode_t(S_IFMT)
                == mode_t(S_IFDIR),
              metadata.st_uid == geteuid(),
              metadata.st_mode & mode_t(0o7777)
                == mode_t(0o700)
        else {
            throw PrimeDurableArtifactError
                .untrustedDirectory(path)
        }
        return metadata
    }

    private static func requireSameNode(
        opened: stat,
        named: stat,
        path: String
    ) throws {
        guard opened.st_dev == named.st_dev,
              opened.st_ino == named.st_ino,
              opened.st_mode & mode_t(S_IFMT)
                == named.st_mode & mode_t(S_IFMT)
        else {
            throw PrimeDurableArtifactError
                .unsafeArtifact(path)
        }
    }

    private static func requireStableNamedNode(
        descriptor: Int32,
        parentDescriptor: Int32,
        leaf: String,
        before: stat,
        path: String
    ) throws {
        var after = stat()
        var named = stat()
        let namedStatus =
            leaf.withCString {
                fstatat(
                    parentDescriptor,
                    $0,
                    &named,
                    AT_SYMLINK_NOFOLLOW
                )
            }
        guard fstat(descriptor, &after) == 0,
              namedStatus == 0 else {
            throw posix(
                "reinspect trusted inventory node",
                path
            )
        }
        try requireSameNode(
            opened: after,
            named: named,
            path: path
        )
        try requireStableMetadata(
            before,
            after,
            path: path
        )
    }

    private static func requireStableMetadata(
        _ before: stat,
        _ after: stat,
        path: String
    ) throws {
        #if canImport(Darwin)
        let timesStable =
            before.st_mtimespec.tv_sec
                == after.st_mtimespec.tv_sec
            && before.st_mtimespec.tv_nsec
                == after.st_mtimespec.tv_nsec
            && before.st_ctimespec.tv_sec
                == after.st_ctimespec.tv_sec
            && before.st_ctimespec.tv_nsec
                == after.st_ctimespec.tv_nsec
        #else
        let timesStable = true
        #endif
        guard before.st_dev == after.st_dev,
              before.st_ino == after.st_ino,
              before.st_mode == after.st_mode,
              before.st_uid == after.st_uid,
              before.st_nlink == after.st_nlink,
              before.st_size == after.st_size,
              timesStable
        else {
            throw PrimeDurableArtifactError
                .unsafeArtifact(path)
        }
    }

    private static func digest(
        descriptor: Int32,
        expectedByteCount: UInt64,
        path: String,
        deadlineNanoseconds: UInt64
    ) throws -> String {
        guard lseek(descriptor, 0, SEEK_SET) >= 0
        else {
            throw posix(
                "seek trusted inventory file",
                path
            )
        }
        var hasher = SHA256()
        var total: UInt64 = 0
        var buffer = [UInt8](
            repeating: 0,
            count: 1024 * 1024
        )
        while true {
            try requireBeforeDeadline(
                deadlineNanoseconds
            )
            let count =
                buffer.withUnsafeMutableBytes {
                    read(
                        descriptor,
                        $0.baseAddress,
                        $0.count
                    )
                }
            if count < 0, errno == EINTR {
                continue
            }
            guard count >= 0 else {
                throw posix(
                    "read trusted inventory file",
                    path
                )
            }
            if count == 0 {
                break
            }
            let (next, overflow) =
                total.addingReportingOverflow(
                    UInt64(count)
                )
            guard !overflow,
                  next <= expectedByteCount
            else {
                throw PrimeDurableArtifactError
                    .byteCountMismatch(
                        path: path,
                        expected:
                            expectedByteCount,
                        actual:
                            overflow
                                ? UInt64.max
                                : next
                    )
            }
            hasher.update(
                data: Data(
                    buffer[0 ..< count]
                )
            )
            total = next
        }
        guard total == expectedByteCount else {
            throw PrimeDurableArtifactError
                .byteCountMismatch(
                    path: path,
                    expected:
                        expectedByteCount,
                    actual: total
                )
        }
        return hexadecimal(
            hasher.finalize()
        )
    }

    private static func safeComponents(
        _ relativePath: String
    ) throws -> [String] {
        guard !relativePath.isEmpty,
              !relativePath.hasPrefix("/"),
              !relativePath.utf8.contains(0)
        else {
            throw PrimeDurableArtifactError
                .invalidRelativePath(
                    relativePath
                )
        }
        let components =
            relativePath.split(
                separator: "/",
                omittingEmptySubsequences:
                    false
            ).map(String.init)
        guard relativePath.utf8.count <= 4_096,
              components.count <= 32,
              components.allSatisfy({
            !$0.isEmpty
                && $0 != "."
                && $0 != ".."
                && $0 != ".git"
                && !$0.utf8.contains(0)
                && $0.utf8.count <= 255
                && $0.utf8.allSatisfy {
                    $0 >= 0x21
                        && $0 <= 0x7e
                }
        }) else {
            throw PrimeDurableArtifactError
                .invalidRelativePath(
                    relativePath
                )
        }
        return components
    }

    private static func modeString(
        for purpose: PrimeArtifactPurpose
    ) -> String {
        purpose == .executable
            ? "0555" : "0444"
    }

    private static func invalid(
        _ detail: String
    ) -> PrimeDurableArtifactError {
        .invalidSemantics(detail)
    }

    private static func posix(
        _ operation: String,
        _ path: String
    ) -> PrimeDurableArtifactError {
        .posix(
            operation: operation,
            path: path,
            code: errno
        )
    }

    private static func identity(
        _ metadata: stat
    ) -> DescriptorIdentity {
        #if canImport(Darwin)
        let modificationSeconds =
            Int64(
                metadata.st_mtimespec.tv_sec
            )
        let modificationNanoseconds =
            Int64(
                metadata.st_mtimespec.tv_nsec
            )
        let statusChangeSeconds =
            Int64(
                metadata.st_ctimespec.tv_sec
            )
        let statusChangeNanoseconds =
            Int64(
                metadata.st_ctimespec.tv_nsec
            )
        #else
        let modificationSeconds: Int64 = 0
        let modificationNanoseconds: Int64 = 0
        let statusChangeSeconds: Int64 = 0
        let statusChangeNanoseconds: Int64 = 0
        #endif
        return DescriptorIdentity(
            device: UInt64(metadata.st_dev),
            inode: UInt64(metadata.st_ino),
            mode: UInt32(metadata.st_mode),
            owner: UInt32(metadata.st_uid),
            linkCount:
                UInt64(metadata.st_nlink),
            byteCount: Int64(metadata.st_size),
            modificationSeconds:
                modificationSeconds,
            modificationNanoseconds:
                modificationNanoseconds,
            statusChangeSeconds:
                statusChangeSeconds,
            statusChangeNanoseconds:
                statusChangeNanoseconds
        )
    }

    private static func rawUTF8Less(
        _ lhs: String,
        _ rhs: String
    ) -> Bool {
        lhs.utf8.lexicographicallyPrecedes(
            rhs.utf8
        )
    }

    private static func hexadecimal<
        Bytes: Sequence
    >(
        _ bytes: Bytes
    ) -> String where Bytes.Element == UInt8 {
        let digits =
            Array("0123456789abcdef".utf8)
        var result = [UInt8]()
        result.reserveCapacity(64)
        for byte in bytes {
            result.append(
                digits[Int(byte >> 4)]
            )
            result.append(
                digits[Int(byte & 0x0f)]
            )
        }
        return String(
            decoding: result,
            as: UTF8.self
        )
    }

    private static func exactDirectoryEntryName(
        _ entry:
            UnsafeMutablePointer<dirent>
    ) throws -> String {
        #if canImport(Darwin)
        let length =
            Int(entry.pointee.d_namlen)
        #else
        let length = withUnsafePointer(
            to: entry.pointee.d_name
        ) {
            $0.withMemoryRebound(
                to: CChar.self,
                capacity: Int(MAXNAMLEN) + 1
            ) {
                strnlen(
                    $0,
                    Int(MAXNAMLEN) + 1
                )
            }
        }
        #endif
        guard length > 0,
              length <= Int(MAXNAMLEN)
        else {
            throw invalid(
                "trusted_inventory_directory_entry_length"
            )
        }
        let bytes: [UInt8] =
            withUnsafePointer(
                to: entry.pointee.d_name
            ) {
                $0.withMemoryRebound(
                    to: UInt8.self,
                    capacity:
                        Int(MAXNAMLEN) + 1
                ) {
                    Array(
                        UnsafeBufferPointer(
                            start: $0,
                            count: length
                        )
                    )
                }
            }
        guard let name =
                String(
                    bytes: bytes,
                    encoding: .utf8
                ),
              Array(name.utf8) == bytes,
              bytes.allSatisfy({
                  $0 >= 0x21
                      && $0 <= 0x7e
              })
        else {
            throw invalid(
                "trusted_inventory_directory_entry_utf8"
            )
        }
        return name
    }

    private static func localAPFSFilesystemIdentity(
        descriptor: Int32,
        status: stat,
        path: String
    ) throws -> LocalAPFSFilesystemIdentity {
        #if canImport(Darwin)
        var filesystem = statfs()
        guard fstatfs(
            descriptor,
            &filesystem
        ) == 0 else {
            throw posix(
                "inspect trusted inventory filesystem",
                path
            )
        }
        guard filesystem.f_flags
                & UInt32(MNT_LOCAL) != 0
        else {
            throw invalid(
                "trusted_inventory_filesystem_not_local"
            )
        }
        var typeField =
            filesystem.f_fstypename
        let typeData =
            withUnsafeBytes(of: &typeField) {
                Data(
                    $0.prefix {
                        $0 != 0
                    }
                )
            }
        guard let type =
                String(
                    data: typeData,
                    encoding: .utf8
                ),
              type == "apfs"
        else {
            throw invalid(
                "trusted_inventory_filesystem_not_apfs"
            )
        }
        return LocalAPFSFilesystemIdentity(
            device: UInt64(status.st_dev),
            fsidWord0:
                filesystem.f_fsid.val.0,
            fsidWord1:
                filesystem.f_fsid.val.1
        )
        #else
        throw PrimeDurableArtifactError
            .unsupportedPlatform(
                "trusted inventory capture requires local APFS"
            )
        #endif
    }

    private static func requireFilesystemIdentity(
        descriptor: Int32,
        status: stat,
        expected:
            LocalAPFSFilesystemIdentity,
        path: String
    ) throws {
        let observed =
            try localAPFSFilesystemIdentity(
                descriptor: descriptor,
                status: status,
                path: path
            )
        guard observed == expected else {
            throw invalid(
                "trusted_inventory_filesystem_identity"
            )
        }
    }

    private static func captureDeadline()
        throws -> UInt64
    {
        let now =
            DispatchTime.now()
            .uptimeNanoseconds
        let (deadline, overflow) =
            now.addingReportingOverflow(
                maximumCaptureNanoseconds
            )
        guard !overflow else {
            throw invalid(
                "trusted_inventory_deadline_overflow"
            )
        }
        return deadline
    }

    private static func requireBeforeDeadline(
        _ deadline: UInt64
    ) throws {
        guard DispatchTime.now()
                .uptimeNanoseconds
                <= deadline
        else {
            throw invalid(
                "trusted_inventory_deadline"
            )
        }
    }

    private static func requireBoundedOpaqueProvenance(
        _ descriptor: Int32,
        path: String
    ) throws {
        #if canImport(Darwin)
        let name = "com.apple.provenance"
        errno = 0
        let required =
            name.withCString {
                fgetxattr(
                    descriptor,
                    $0,
                    nil,
                    0,
                    0,
                    0
                )
            }
        if required < 0 {
            guard errno == ENOATTR else {
                throw PrimeDurableArtifactError
                    .unsafeArtifact(path)
            }
            return
        }
        guard required <= 4_096 else {
            throw PrimeDurableArtifactError
                .unsafeArtifact(path)
        }
        var value = [UInt8](
            repeating: 0,
            count: required
        )
        let actual =
            name.withCString {
                namePointer in
                value.withUnsafeMutableBytes {
                    fgetxattr(
                        descriptor,
                        namePointer,
                        $0.baseAddress,
                        $0.count,
                        0,
                        0
                    )
                }
            }
        errno = 0
        let after =
            name.withCString {
                fgetxattr(
                    descriptor,
                    $0,
                    nil,
                    0,
                    0,
                    0
                )
            }
        guard actual == required,
              after == required else {
            throw PrimeDurableArtifactError
                .unsafeArtifact(path)
        }
        #else
        throw PrimeDurableArtifactError
            .unsupportedPlatform(
                "trusted inventory provenance validation requires Darwin"
            )
        #endif
    }
}

public extension PrimeArtifactRoot {
    func captureTrustedInventory(
        expectedArtifacts:
            [PrimeArtifactBinding]
    ) throws
        -> PrimeTrustedArtifactInventoryCapture
    {
        try PrimeTrustedArtifactInventoryCapture(
            anchorDescriptor:
                duplicateTrustedRootDescriptorForInventory(),
            rootRelativePath: nil,
            expectedArtifacts:
                expectedArtifacts
        )
    }

    func captureTrustedInventory(
        rolePrefix: String,
        expectedArtifacts:
            [PrimeArtifactBinding]
    ) throws
        -> PrimeTrustedArtifactInventoryCapture
    {
        try PrimeTrustedArtifactInventoryCapture(
            anchorDescriptor:
                duplicateTrustedRootDescriptorForInventory(),
            rootRelativePath: rolePrefix,
            expectedArtifacts:
                expectedArtifacts
        )
    }
}
