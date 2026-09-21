import Darwin
import Foundation
import Security

public enum PrimeMetalDeviceLeaseError:
    Error,
    Equatable,
    Sendable
{
    case invalidLeaseURL
    case parentIsSymbolicLink
    case parentOpenFailed(errno: Int32)
    case parentChangedDuringValidation
    case parentIsNotDirectory
    case untrustedParentOwner(
        expected: UInt32,
        actual: UInt32
    )
    case untrustedParentPermissions(mode: UInt16)
    case parentHasAccessControlList
    case parentHasExtendedAttributes
    case parentMetadataReadFailed(errno: Int32)
    case leaseIsSymbolicLink
    case leaseOpenFailed(errno: Int32)
    case leaseIsNotRegularFile
    case untrustedLeaseOwner(
        expected: UInt32,
        actual: UInt32
    )
    case invalidLeaseLinkCount(actual: UInt64)
    case invalidLeasePermissions(mode: UInt16)
    case leaseHasAccessControlList
    case leaseHasExtendedAttributes
    case leaseMetadataReadFailed(errno: Int32)
    case leaseNameChangedDuringAcquisition
    case invalidLeaseDescriptorFlags
    case busy
    case lockFailed(errno: Int32)
    case sandboxApplicationIdentityRejected(stage: String, status: Int32)
    case sandboxSynchronizationMetadataChanged
}

/// App-container synchronization only; this is not the historical global lease
/// or an admission of downloaded files, models, executable code, or receipts.
public struct PrimeSandboxApplicationSynchronizationLeaseEvidence: Codable, Equatable, Sendable {
    public let policy: String
    public let filePath: String
    public let applicationIdentifier: String
    public let helperIdentifier: String
    public let parentProcessIdentifier: Int32
    public let parentDevice: Int32
    public let parentInode: UInt64
    public let fileDevice: Int32
    public let fileInode: UInt64
    public let parentAttributeSHA256: [String: String]
    public let fileAttributeSHA256: [String: String]
    public let parentAttributeByteCounts: [String: Int]
    public let fileAttributeByteCounts: [String: Int]
}

/// A process-wide, advisory lease for exclusive use of one named Prime
/// resource.
///
/// The caller must supply a lock-file URL whose immediate parent is a
/// dedicated directory owned by the effective user and not writable by group
/// or other users. Acquisition opens that parent and the lock file without
/// following their final symbolic-link components, validates both open
/// descriptors, and holds non-blocking exclusive `flock` values on both the
/// dedicated parent directory and lease file for this object's lifetime. The
/// parent lock prevents cooperating processes from splitting across different
/// leaf inodes if the leaf name is replaced. Prime uses distinct instances
/// for Metal-device allocation and supervisor authority over one artifact
/// root.
///
/// The lock file is intentionally never unlinked, truncated, or interpreted as
/// authority. In particular, stale PID text cannot cause deletion or lease
/// takeover: only the kernel lock determines ownership.
public final class PrimeMetalDeviceLease: @unchecked Sendable {
    public let fileURL: URL

    private let stateLock = NSLock()
    private var descriptor: Int32
    private var parentDescriptor: Int32
    private var sandboxSynchronization: SandboxSynchronization?

    private init(
        fileURL: URL,
        descriptor: Int32,
        parentDescriptor: Int32
    ) {
        self.fileURL = fileURL
        self.descriptor = descriptor
        self.parentDescriptor = parentDescriptor
    }

    public static func acquire(
        at fileURL: URL
    ) throws -> PrimeMetalDeviceLease {
        try acquire(at: fileURL, sandboxIdentity: nil)
    }

    /// Only the signed, sandbox-inheriting Prime helper with its live signed
    /// parent may select this fixed internal namespace. No caller path or xattr
    /// allowlist can select this policy.
    public static func acquireForSandboxApplicationSynchronization() throws -> PrimeMetalDeviceLease {
        let identity = try SandboxIdentity.capture()
        return try acquire(at: identity.fileURL, sandboxIdentity: identity)
    }

    /// Validates the helper protocol's declared path before any GPU work. The
    /// path is only a consistency assertion, never the lease's authority.
    public static func validateSandboxApplicationSynchronizationRequest(directoryPath: String) throws {
        let identity = try SandboxIdentity.capture()
        guard directoryPath == identity.fileURL.deletingLastPathComponent().path else {
            throw PrimeMetalDeviceLeaseError.sandboxApplicationIdentityRejected(stage: "request_directory", status: 0)
        }
    }

    private static func acquire(
        at fileURL: URL, sandboxIdentity: SandboxIdentity?
    ) throws -> PrimeMetalDeviceLease {
        let sandboxApplication = sandboxIdentity != nil
        let path = fileURL.path
        let name = fileURL.lastPathComponent
        let parentURL = fileURL.deletingLastPathComponent()
        let parentPath = parentURL.path

        guard
            fileURL.isFileURL,
            path.hasPrefix("/"),
            !name.isEmpty,
            name != ".",
            name != "..",
            !name.contains("/"),
            parentPath != path
        else {
            throw PrimeMetalDeviceLeaseError.invalidLeaseURL
        }

        let expectedOwner = geteuid()
        var parentPathStatus = stat()
        errno = 0
        guard lstat(parentPath, &parentPathStatus) == 0 else {
            throw PrimeMetalDeviceLeaseError.parentOpenFailed(
                errno: errno
            )
        }
        guard
            parentPathStatus.st_mode & S_IFMT != S_IFLNK
        else {
            throw PrimeMetalDeviceLeaseError.parentIsSymbolicLink
        }

        let parentDescriptor = open(
            parentPath,
            O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC
        )
        guard parentDescriptor >= 0 else {
            if errno == ELOOP {
                throw PrimeMetalDeviceLeaseError
                    .parentIsSymbolicLink
            }
            throw PrimeMetalDeviceLeaseError.parentOpenFailed(
                errno: errno
            )
        }
        var keepParentDescriptor = false
        var parentLockHeld = false
        defer {
            if !keepParentDescriptor {
                if parentLockHeld {
                    flock(parentDescriptor, LOCK_UN)
                }
                close(parentDescriptor)
            }
        }

        var parentDescriptorStatus = stat()
        guard fstat(
            parentDescriptor,
            &parentDescriptorStatus
        ) == 0 else {
            throw PrimeMetalDeviceLeaseError
                .parentMetadataReadFailed(errno: errno)
        }
        guard
            parentDescriptorStatus.st_dev
                == parentPathStatus.st_dev,
            parentDescriptorStatus.st_ino
                == parentPathStatus.st_ino
        else {
            throw PrimeMetalDeviceLeaseError
                .parentChangedDuringValidation
        }
        try validateParent(
            descriptor: parentDescriptor,
            status: parentDescriptorStatus,
            expectedOwner: expectedOwner,
            sandboxApplication: sandboxApplication
        )
        let initialParent = sandboxApplication ? try SandboxNode.capture(parentDescriptor) : nil
        if let initialParent {
            guard initialParent.sameStat(parentDescriptorStatus) else {
                throw PrimeMetalDeviceLeaseError.sandboxSynchronizationMetadataChanged
            }
        }
        guard flock(
            parentDescriptor,
            LOCK_EX | LOCK_NB
        ) == 0 else {
            if errno == EWOULDBLOCK || errno == EAGAIN {
                throw PrimeMetalDeviceLeaseError.busy
            }
            throw PrimeMetalDeviceLeaseError.lockFailed(
                errno: errno
            )
        }
        parentLockHeld = true
        do {
            var lockedParentStatus = stat()
            var reboundParentStatus = stat()
            guard fstat(
                parentDescriptor,
                &lockedParentStatus
            ) == 0 else {
                throw PrimeMetalDeviceLeaseError
                    .parentMetadataReadFailed(errno: errno)
            }
            guard lstat(
                parentPath,
                &reboundParentStatus
            ) == 0 else {
                throw PrimeMetalDeviceLeaseError
                    .parentOpenFailed(errno: errno)
            }
            guard reboundParentStatus.st_mode & S_IFMT
                    != S_IFLNK,
                  lockedParentStatus.st_dev
                    == reboundParentStatus.st_dev,
                  lockedParentStatus.st_ino
                    == reboundParentStatus.st_ino else {
                throw PrimeMetalDeviceLeaseError
                    .parentChangedDuringValidation
            }
            try validateParent(
                descriptor: parentDescriptor,
                status: lockedParentStatus,
                expectedOwner: expectedOwner,
                sandboxApplication: sandboxApplication
            )
            if let initialParent {
                try initialParent.requireUnchanged(parentDescriptor)
            }
        } catch {
            flock(parentDescriptor, LOCK_UN)
            parentLockHeld = false
            throw error
        }

        // App acquisition distinguishes its own creation from opening an
        // existing leaf, so directory publication cannot hide metadata drift.
        var createdSandboxLeaf = false
        let openedDescriptor = name.withCString { namePointer in
            if sandboxApplication {
                let created = openat(parentDescriptor, namePointer,
                    O_RDWR | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC, mode_t(0o600))
                if created >= 0 { createdSandboxLeaf = true; return created }
                guard errno == EEXIST else { return Int32(-1) }
                return openat(parentDescriptor, namePointer, O_RDWR | O_NOFOLLOW | O_CLOEXEC)
            }
            return openat(
                parentDescriptor,
                namePointer,
                O_RDWR | O_CREAT | O_NOFOLLOW | O_CLOEXEC,
                mode_t(S_IRUSR | S_IWUSR)
            )
        }
        guard openedDescriptor >= 0 else {
            if errno == ELOOP {
                throw PrimeMetalDeviceLeaseError
                    .leaseIsSymbolicLink
            }
            throw PrimeMetalDeviceLeaseError.leaseOpenFailed(
                errno: errno
            )
        }

        var keepDescriptor = false
        defer {
            if !keepDescriptor {
                close(openedDescriptor)
            }
        }

        try validateLeaseFile(
            descriptor: openedDescriptor,
            expectedOwner: expectedOwner,
            sandboxApplication: sandboxApplication
        )
        let initialFile = sandboxApplication ? try SandboxNode.capture(openedDescriptor) : nil
        let publishedParent: SandboxNode?
        if let initialParent {
            let current = try SandboxNode.capture(parentDescriptor)
            guard initialParent.matches(current, allowingOwnFileCreation: createdSandboxLeaf) else {
                throw PrimeMetalDeviceLeaseError.sandboxSynchronizationMetadataChanged
            }
            publishedParent = current
        } else { publishedParent = nil }
        try validateDescriptorFlags(openedDescriptor)

        guard flock(
            openedDescriptor,
            LOCK_EX | LOCK_NB
        ) == 0 else {
            if errno == EWOULDBLOCK || errno == EAGAIN {
                throw PrimeMetalDeviceLeaseError.busy
            }
            throw PrimeMetalDeviceLeaseError.lockFailed(
                errno: errno
            )
        }

        do {
            // Revalidate after locking so the lease is never returned from a
            // descriptor whose metadata changed during acquisition.
            try validateLeaseFile(
                descriptor: openedDescriptor,
                expectedOwner: expectedOwner,
                sandboxApplication: sandboxApplication
            )
            var descriptorStatus = stat()
            var namedStatus = stat()
            guard fstat(
                openedDescriptor,
                &descriptorStatus
            ) == 0,
            name.withCString({
                fstatat(
                    parentDescriptor,
                    $0,
                    &namedStatus,
                    AT_SYMLINK_NOFOLLOW
                )
            }) == 0,
            descriptorStatus.st_dev == namedStatus.st_dev,
            descriptorStatus.st_ino == namedStatus.st_ino
            else {
                throw PrimeMetalDeviceLeaseError
                    .leaseNameChangedDuringAcquisition
            }
            try initialFile?.requireUnchanged(openedDescriptor)
            try publishedParent?.requireUnchanged(parentDescriptor)
        } catch {
            flock(openedDescriptor, LOCK_UN)
            throw error
        }

        let lease = PrimeMetalDeviceLease(
            fileURL: fileURL,
            descriptor: openedDescriptor,
            parentDescriptor: parentDescriptor
        )
        keepDescriptor = true
        keepParentDescriptor = true
        if let sandboxIdentity, let publishedParent, let initialFile {
            lease.sandboxSynchronization = SandboxSynchronization(
                identity: sandboxIdentity, parent: publishedParent, file: initialFile)
            _ = try lease.revalidateSandboxApplicationSynchronization()
        }
        return lease
    }

    public func revalidateSandboxApplicationSynchronization() throws -> PrimeSandboxApplicationSynchronizationLeaseEvidence {
        stateLock.lock(); defer { stateLock.unlock() }
        guard descriptor >= 0, parentDescriptor >= 0, let retained = sandboxSynchronization else {
            throw PrimeMetalDeviceLeaseError.sandboxApplicationIdentityRejected(stage: "app_lease_not_held", status: 0)
        }
        try retained.identity.revalidate()
        try retained.parent.requireUnchanged(parentDescriptor)
        try retained.file.requireUnchanged(descriptor)
        var parentNamed = stat(), fileNamed = stat()
        guard lstat(fileURL.deletingLastPathComponent().path, &parentNamed) == 0,
              fstatat(parentDescriptor, "metal.lock", &fileNamed, AT_SYMLINK_NOFOLLOW) == 0,
              retained.parent.sameStat(parentNamed), retained.file.sameStat(fileNamed) else {
            throw PrimeMetalDeviceLeaseError.sandboxSynchronizationMetadataChanged
        }
        return PrimeSandboxApplicationSynchronizationLeaseEvidence(
            policy: "signed_sandbox_application_internal_synchronization_v1",
            filePath: fileURL.path, applicationIdentifier: SandboxIdentity.application,
            helperIdentifier: SandboxIdentity.helper, parentProcessIdentifier: retained.identity.parentPID,
            parentDevice: retained.parent.status.st_dev, parentInode: UInt64(retained.parent.status.st_ino),
            fileDevice: retained.file.status.st_dev, fileInode: UInt64(retained.file.status.st_ino),
            parentAttributeSHA256: retained.parent.attributes.mapValues { PrimeSHA256.hexDigest(of: $0) },
            fileAttributeSHA256: retained.file.attributes.mapValues { PrimeSHA256.hexDigest(of: $0) },
            parentAttributeByteCounts: retained.parent.attributes.mapValues(\.count),
            fileAttributeByteCounts: retained.file.attributes.mapValues(\.count))
    }

    public var isHeld: Bool {
        stateLock.lock()
        defer {
            stateLock.unlock()
        }
        return descriptor >= 0
            && parentDescriptor >= 0
    }

    /// Releases the kernel lock and closes the descriptor. This operation is
    /// idempotent. The persistent lock file is deliberately left in place.
    public func release() {
        let descriptorToClose: Int32
        let parentDescriptorToClose: Int32
        stateLock.lock()
        if descriptor >= 0 {
            descriptorToClose = descriptor
            descriptor = -1
            parentDescriptorToClose =
                parentDescriptor
            parentDescriptor = -1
        } else {
            descriptorToClose = -1
            parentDescriptorToClose = -1
        }
        stateLock.unlock()

        guard descriptorToClose >= 0 else {
            return
        }
        flock(descriptorToClose, LOCK_UN)
        close(descriptorToClose)
        if parentDescriptorToClose >= 0 {
            flock(parentDescriptorToClose, LOCK_UN)
            close(parentDescriptorToClose)
        }
    }

    deinit {
        release()
    }

    private static func validateParent(
        descriptor: Int32,
        status: stat,
        expectedOwner: uid_t,
        sandboxApplication: Bool = false
    ) throws {
        guard status.st_mode & S_IFMT == S_IFDIR else {
            throw PrimeMetalDeviceLeaseError
                .parentIsNotDirectory
        }
        guard status.st_uid == expectedOwner else {
            throw PrimeMetalDeviceLeaseError
                .untrustedParentOwner(
                    expected: UInt32(expectedOwner),
                    actual: UInt32(status.st_uid)
                )
        }

        let permissionBits = status.st_mode & mode_t(0o7777)
        guard permissionBits & mode_t(0o022) == 0,
              !sandboxApplication || permissionBits == mode_t(0o700) else {
            throw PrimeMetalDeviceLeaseError
                .untrustedParentPermissions(
                    mode: UInt16(permissionBits)
                )
        }
        try validateNoAccessControlList(
            descriptor: descriptor,
            accessControlListError:
                .parentHasAccessControlList,
            metadataError: {
                .parentMetadataReadFailed(errno: $0)
            }
        )
        try validateExtendedAttributes(
            descriptor: descriptor,
            allowedNames: sandboxApplication ? permittedSystemExtendedAttributes.union(["com.apple.quarantine"]) : permittedSystemExtendedAttributes,
            extendedAttributesError:
                .parentHasExtendedAttributes,
            metadataError: {
                .parentMetadataReadFailed(errno: $0)
            }
        )
    }

    private static func validateLeaseFile(
        descriptor: Int32,
        expectedOwner: uid_t,
        sandboxApplication: Bool = false
    ) throws {
        var status = stat()
        guard fstat(descriptor, &status) == 0 else {
            throw PrimeMetalDeviceLeaseError
                .leaseMetadataReadFailed(errno: errno)
        }
        guard status.st_mode & S_IFMT == S_IFREG else {
            throw PrimeMetalDeviceLeaseError
                .leaseIsNotRegularFile
        }
        guard status.st_uid == expectedOwner else {
            throw PrimeMetalDeviceLeaseError
                .untrustedLeaseOwner(
                    expected: UInt32(expectedOwner),
                    actual: UInt32(status.st_uid)
                )
        }
        guard status.st_nlink == 1 else {
            throw PrimeMetalDeviceLeaseError
                .invalidLeaseLinkCount(
                    actual: UInt64(status.st_nlink)
                )
        }

        let permissionBits = status.st_mode & mode_t(0o7777)
        guard permissionBits == mode_t(0o600) else {
            throw PrimeMetalDeviceLeaseError
                .invalidLeasePermissions(
                    mode: UInt16(permissionBits)
                )
        }
        try validateNoAccessControlList(
            descriptor: descriptor,
            accessControlListError:
                .leaseHasAccessControlList,
            metadataError: {
                .leaseMetadataReadFailed(errno: $0)
            }
        )
        try validateExtendedAttributes(
            descriptor: descriptor,
            allowedNames: sandboxApplication ? permittedSystemExtendedAttributes.union(["com.apple.quarantine"]) : permittedSystemExtendedAttributes,
            extendedAttributesError:
                .leaseHasExtendedAttributes,
            metadataError: {
                .leaseMetadataReadFailed(errno: $0)
            }
        )
    }

    private static func validateDescriptorFlags(
        _ descriptor: Int32
    ) throws {
        let descriptorFlags = fcntl(descriptor, F_GETFD)
        let statusFlags = fcntl(descriptor, F_GETFL)
        guard
            descriptorFlags >= 0,
            descriptorFlags & FD_CLOEXEC != 0,
            statusFlags >= 0,
            statusFlags & O_ACCMODE == O_RDWR
        else {
            throw PrimeMetalDeviceLeaseError
                .invalidLeaseDescriptorFlags
        }
    }

    private static func validateNoAccessControlList(
        descriptor: Int32,
        accessControlListError: PrimeMetalDeviceLeaseError,
        metadataError: (Int32) -> PrimeMetalDeviceLeaseError
    ) throws {
        errno = 0
        guard let accessControlList = acl_get_fd_np(
            descriptor,
            ACL_TYPE_EXTENDED
        ) else {
            if errno == ENOENT || errno == ENOTSUP {
                return
            }
            throw metadataError(errno)
        }
        acl_free(
            UnsafeMutableRawPointer(accessControlList)
        )
        throw accessControlListError
    }

    private struct SandboxSynchronization {
        let identity: SandboxIdentity
        let parent: SandboxNode
        let file: SandboxNode
    }

    private struct SandboxNode {
        let status: stat
        let attributes: [String: Data]
        let directoryEntries: [String]?

        static func capture(_ descriptor: Int32) throws -> Self {
            var initial = stat(), final = stat()
            guard fstat(descriptor, &initial) == 0, initial.st_flags == 0,
                  initial.st_uid == geteuid(),
                  (initial.st_mode & S_IFMT == S_IFDIR && initial.st_mode & 0o7777 == 0o700) ||
                  (initial.st_mode & S_IFMT == S_IFREG && initial.st_mode & 0o7777 == 0o600 &&
                   initial.st_nlink == 1 && initial.st_size == 0) else {
                throw PrimeMetalDeviceLeaseError.sandboxSynchronizationMetadataChanged
            }
            try validateNoAccessControlList(descriptor: descriptor,
                accessControlListError: .sandboxSynchronizationMetadataChanged,
                metadataError: { _ in .sandboxSynchronizationMetadataChanged })
            let size = flistxattr(descriptor, nil, 0, 0)
            guard size >= 0, size <= 512 else {
                throw PrimeMetalDeviceLeaseError.sandboxSynchronizationMetadataChanged
            }
            var names = [UInt8](repeating: 0, count: max(1, size))
            let actual = names.withUnsafeMutableBytes {
                flistxattr(descriptor, $0.baseAddress?.assumingMemoryBound(to: CChar.self), size, 0)
            }
            guard actual == size, size == 0 || names[size - 1] == 0 else {
                throw PrimeMetalDeviceLeaseError.sandboxSynchronizationMetadataChanged
            }
            var attributes: [String: Data] = [:]
            for bytes in names.prefix(size).split(separator: 0, omittingEmptySubsequences: false).dropLast() {
                guard let name = String(bytes: bytes, encoding: .utf8),
                      ["com.apple.provenance", "com.apple.quarantine"].contains(name),
                      attributes[name] == nil else {
                    throw PrimeMetalDeviceLeaseError.sandboxSynchronizationMetadataChanged
                }
                let count = fgetxattr(descriptor, name, nil, 0, 0, 0)
                guard count > 0, count <= 4096 else {
                    throw PrimeMetalDeviceLeaseError.sandboxSynchronizationMetadataChanged
                }
                var data = Data(count: count)
                let read = data.withUnsafeMutableBytes { fgetxattr(descriptor, name, $0.baseAddress, count, 0, 0) }
                guard read == count else {
                    throw PrimeMetalDeviceLeaseError.sandboxSynchronizationMetadataChanged
                }
                attributes[name] = data
            }
            let entries = initial.st_mode & S_IFMT == S_IFDIR ? try namesInDirectory(descriptor) : nil
            let node = Self(status: initial, attributes: attributes, directoryEntries: entries)
            guard fstat(descriptor, &final) == 0, node.sameStat(final) else {
                throw PrimeMetalDeviceLeaseError.sandboxSynchronizationMetadataChanged
            }
            return node
        }

        func sameStat(_ other: stat, allowingOwnFileCreation: Bool = false) -> Bool {
            status.st_dev == other.st_dev && status.st_ino == other.st_ino &&
            status.st_mode == other.st_mode && status.st_uid == other.st_uid &&
            status.st_gid == other.st_gid &&
            (status.st_nlink == other.st_nlink || (allowingOwnFileCreation &&
                UInt64(other.st_nlink) == UInt64(status.st_nlink) + 1)) &&
            status.st_rdev == other.st_rdev && status.st_flags == other.st_flags &&
            status.st_gen == other.st_gen &&
            status.st_birthtimespec.tv_sec == other.st_birthtimespec.tv_sec &&
            status.st_birthtimespec.tv_nsec == other.st_birthtimespec.tv_nsec &&
            (allowingOwnFileCreation || (status.st_size == other.st_size &&
                status.st_blocks == other.st_blocks && status.st_blksize == other.st_blksize &&
                status.st_mtimespec.tv_sec == other.st_mtimespec.tv_sec &&
                status.st_mtimespec.tv_nsec == other.st_mtimespec.tv_nsec &&
                status.st_ctimespec.tv_sec == other.st_ctimespec.tv_sec &&
                status.st_ctimespec.tv_nsec == other.st_ctimespec.tv_nsec))
        }

        func matches(_ other: Self, allowingOwnFileCreation: Bool = false) -> Bool {
            sameStat(other.status, allowingOwnFileCreation: allowingOwnFileCreation) && attributes == other.attributes &&
            (allowingOwnFileCreation ? (directoryEntries == [] && other.directoryEntries == ["metal.lock"]) :
                directoryEntries == other.directoryEntries)
        }

        func requireUnchanged(_ descriptor: Int32) throws {
            guard matches(try Self.capture(descriptor)) else {
                throw PrimeMetalDeviceLeaseError.sandboxSynchronizationMetadataChanged
            }
        }

        private static func namesInDirectory(_ descriptor: Int32) throws -> [String] {
            // A separate open-file description avoids changing the held
            // directory's position. Only this one synchronization leaf exists.
            let scan = openat(descriptor, ".", O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC)
            guard scan >= 0 else { throw PrimeMetalDeviceLeaseError.sandboxSynchronizationMetadataChanged }
            guard let directory = fdopendir(scan) else {
                close(scan); throw PrimeMetalDeviceLeaseError.sandboxSynchronizationMetadataChanged
            }
            defer { closedir(directory) }
            var names: [String] = []
            var count = 0
            while true {
                errno = 0
                guard let entry = readdir(directory) else {
                    guard errno == 0 else { throw PrimeMetalDeviceLeaseError.sandboxSynchronizationMetadataChanged }
                    return names.sorted()
                }
                count += 1
                guard count <= 3 else { throw PrimeMetalDeviceLeaseError.sandboxSynchronizationMetadataChanged }
                let name = withUnsafePointer(to: &entry.pointee.d_name) {
                    $0.withMemoryRebound(to: CChar.self, capacity: Int(MAXNAMLEN) + 1) { String(cString: $0) }
                }
                if name == "." || name == ".." { continue }
                guard name == "metal.lock", names.isEmpty else {
                    throw PrimeMetalDeviceLeaseError.sandboxSynchronizationMetadataChanged
                }
                names.append(name)
            }
        }
    }

    private final class SandboxIdentity {
        static let application = "com.ergentics.provenance"
        static let helper = "com.ergentics.provenance.prime-runtime"
        static let team = "ZCQ435U8JP"
        let fileURL: URL
        let parentPID: Int32
        private let ownCode: SecCode
        private let parentCode: SecCode
        private let directories: [(descriptor: Int32, path: String, status: stat)]

        private init(fileURL: URL, parentPID: Int32, ownCode: SecCode, parentCode: SecCode,
                     directories: [(descriptor: Int32, path: String, status: stat)]) {
            self.fileURL = fileURL; self.parentPID = parentPID
            self.ownCode = ownCode; self.parentCode = parentCode; self.directories = directories
        }
        deinit { for directory in directories { close(directory.descriptor) } }

        static func capture() throws -> SandboxIdentity {
            let parentPID = getppid()
            var ownCode: SecCode?, parentCode: SecCode?
            guard parentPID > 1 else {
                throw PrimeMetalDeviceLeaseError.sandboxApplicationIdentityRejected(stage: "live_parent", status: 0)
            }
            try requireStatus(SecCodeCopySelf([], &ownCode), "copy_self")
            try requireStatus(SecCodeCopyGuestWithAttributes(nil,
                [kSecGuestAttributePid as String: NSNumber(value: parentPID)] as CFDictionary,
                [], &parentCode), "copy_parent")
            guard let ownCode, let parentCode else {
                throw PrimeMetalDeviceLeaseError.sandboxApplicationIdentityRejected(stage: "missing_code_identity", status: 0)
            }
            try validateCode(ownCode, identifier: helper, inherited: true)
            try validateCode(parentCode, identifier: application, inherited: false)
            // Derive the real user's container path from the account database,
            // never HOME, CFFIXED_USER_HOME, argv, or a caller-selected URL.
            var record = passwd(), result: UnsafeMutablePointer<passwd>?
            var buffer = [CChar](repeating: 0, count: 16_384)
            let code = buffer.withUnsafeMutableBufferPointer {
                getpwuid_r(geteuid(), &record, $0.baseAddress, $0.count, &result)
            }
            guard code == 0, result != nil, let directory = record.pw_dir else {
                throw PrimeMetalDeviceLeaseError.sandboxApplicationIdentityRejected(stage: "getpwuid_r", status: code)
            }
            let home = String(cString: directory)
            guard home.hasPrefix("/"), home != "/", !home.hasSuffix("/") else {
                throw PrimeMetalDeviceLeaseError.sandboxApplicationIdentityRejected(stage: "account_home", status: 0)
            }
            var held: [(descriptor: Int32, path: String, status: stat)] = []
            var keep = false
            defer { if !keep { for value in held { close(value.descriptor) } } }
            // The container's outer directory holds system-managed metadata
            // and need not be readable by the sandboxed application. Start at
            // its fixed Data root; O_NOFOLLOW_ANY still checks every preceding
            // component, without listing the outer container directory.
            let containerData = home + "/Library/Containers/" + application + "/Data"
            var path = containerData
            let components = ["Library", "Application Support"]
            for component in [""] + components {
                let fd: Int32
                if let parent = held.last {
                    path += "/" + component
                    fd = openat(parent.descriptor, component, O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC)
                } else {
                    // Reject symlinks in the entire fixed prefix without
                    // requiring directory-listing access above our container.
                    // O_NOFOLLOW_ANY covers the final component too; Darwin
                    // rejects combining it with O_NOFOLLOW (EINVAL).
                    fd = open(containerData, O_RDONLY | O_DIRECTORY | O_NOFOLLOW_ANY | O_CLOEXEC)
                }
                guard fd >= 0 else {
                    throw PrimeMetalDeviceLeaseError.sandboxApplicationIdentityRejected(stage: "open_container_component:\(component)", status: errno)
                }
                var status = stat()
                let statResult = fstat(fd, &status)
                let statError = errno
                guard statResult == 0, status.st_mode & S_IFMT == S_IFDIR,
                      status.st_uid == geteuid(), status.st_mode & 0o022 == 0 else {
                    close(fd)
                    throw PrimeMetalDeviceLeaseError.sandboxApplicationIdentityRejected(
                        stage: "container_component_metadata:\(component)", status: statResult == 0 ? 0 : statError)
                }
                held.append((fd, path, status))
            }
            let identity = SandboxIdentity(fileURL: URL(fileURLWithPath: path)
                .appendingPathComponent("PrimeRuntimeSynchronization/metal.lock"),
                parentPID: parentPID, ownCode: ownCode, parentCode: parentCode, directories: held)
            keep = true
            try identity.revalidate()
            return identity
        }

        func revalidate() throws {
            guard getppid() == parentPID else { throw PrimeMetalDeviceLeaseError.sandboxApplicationIdentityRejected(stage: "parent_changed", status: 0) }
            try Self.validateCode(ownCode, identifier: Self.helper, inherited: true)
            try Self.validateCode(parentCode, identifier: Self.application, inherited: false)
            for directory in directories {
                var held = stat(), named = stat()
                guard fstat(directory.descriptor, &held) == 0, lstat(directory.path, &named) == 0,
                      held.st_dev == directory.status.st_dev, held.st_ino == directory.status.st_ino,
                      held.st_uid == directory.status.st_uid, held.st_gid == directory.status.st_gid,
                      held.st_mode == directory.status.st_mode, held.st_flags == directory.status.st_flags,
                      named.st_dev == held.st_dev, named.st_ino == held.st_ino, named.st_mode == held.st_mode else {
                    throw PrimeMetalDeviceLeaseError.sandboxSynchronizationMetadataChanged
                }
            }
            guard getppid() == parentPID else { throw PrimeMetalDeviceLeaseError.sandboxApplicationIdentityRejected(stage: "parent_changed", status: 0) }
        }

        private static func requireStatus(_ status: OSStatus, _ stage: String) throws {
            guard status == errSecSuccess else {
                throw PrimeMetalDeviceLeaseError.sandboxApplicationIdentityRejected(stage: stage, status: status)
            }
        }

        private static func validateCode(_ code: SecCode, identifier: String, inherited: Bool) throws {
            var requirement: SecRequirement?, staticCode: SecStaticCode?, information: CFDictionary?
            let rule = "anchor apple generic and identifier \"\(identifier)\" and certificate leaf[subject.OU] = \"\(team)\""
            try requireStatus(SecRequirementCreateWithString(rule as CFString, [], &requirement), "requirement:\(identifier)")
            guard let requirement else { throw PrimeMetalDeviceLeaseError.sandboxApplicationIdentityRejected(stage: "missing_requirement", status: 0) }
            try requireStatus(SecCodeCheckValidity(code, [.noNetworkAccess], requirement), "validity:\(identifier)")
            try requireStatus(SecCodeCopyStaticCode(code, [], &staticCode), "static_code:\(identifier)")
            guard let staticCode else { throw PrimeMetalDeviceLeaseError.sandboxApplicationIdentityRejected(stage: "missing_static_code", status: 0) }
            try requireStatus(SecCodeCopySigningInformation(staticCode, SecCSFlags(rawValue: kSecCSSigningInformation), &information), "signing_information:\(identifier)")
            guard let info = information as? [String: Any],
                  info[kSecCodeInfoIdentifier as String] as? String == identifier,
                  info[kSecCodeInfoTeamIdentifier as String] as? String == team,
                  let flags = info[kSecCodeInfoFlags as String] as? NSNumber,
                  flags.uint32Value & SecCodeSignatureFlags.runtime.rawValue != 0,
                  let entitlements = info[kSecCodeInfoEntitlementsDict as String] as? [String: Any] else {
                throw PrimeMetalDeviceLeaseError.sandboxApplicationIdentityRejected(stage: "signed_identity_metadata:\(identifier)", status: 0)
            }
            let required: Set<String> = inherited ? ["com.apple.security.app-sandbox", "com.apple.security.inherit"] :
                ["com.apple.security.app-sandbox", "com.apple.security.files.user-selected.read-write",
                 "com.apple.security.hypervisor", "com.apple.security.virtualization"]
            guard required.isSubset(of: Set(entitlements.keys)) else {
                throw PrimeMetalDeviceLeaseError.sandboxApplicationIdentityRejected(stage: "required_entitlements:\(identifier)", status: 0)
            }
            for (key, value) in entitlements {
                if required.contains(key) {
                    guard let number = value as? NSNumber, CFGetTypeID(number) == CFBooleanGetTypeID(), number.boolValue else {
                        throw PrimeMetalDeviceLeaseError.sandboxApplicationIdentityRejected(stage: "entitlement:\(key)", status: 0)
                    }
                } else if key == "com.apple.developer.team-identifier" {
                    guard value as? String == team else { throw PrimeMetalDeviceLeaseError.sandboxApplicationIdentityRejected(stage: "team_entitlement", status: 0) }
                } else if key == "com.apple.application-identifier" || key == "application-identifier" {
                    guard value as? String == team + "." + identifier else { throw PrimeMetalDeviceLeaseError.sandboxApplicationIdentityRejected(stage: "application_entitlement", status: 0) }
                } else { throw PrimeMetalDeviceLeaseError.sandboxApplicationIdentityRejected(stage: "unexpected_entitlement:\(key)", status: 0) }
            }
        }
    }

    private static let permittedSystemExtendedAttributes:
        Set<String> = [
            // APFS/macOS may attach this opaque provenance marker to files
            // created by a signed process. It does not grant filesystem
            // access; ACLs and mode bits remain separately fail-closed.
            "com.apple.provenance",
        ]

    private static func validateExtendedAttributes(
        descriptor: Int32,
        allowedNames: Set<String>,
        extendedAttributesError: PrimeMetalDeviceLeaseError,
        metadataError: (Int32) -> PrimeMetalDeviceLeaseError
    ) throws {
        errno = 0
        let size = flistxattr(descriptor, nil, 0, 0)
        if size < 0, errno != ENOTSUP {
            throw metadataError(errno)
        }
        guard size > 0 else {
            return
        }
        guard size <= 65_536 else {
            throw extendedAttributesError
        }

        var names = [CChar](
            repeating: 0,
            count: size
        )
        errno = 0
        let actualSize = names.withUnsafeMutableBufferPointer {
            flistxattr(
                descriptor,
                $0.baseAddress,
                $0.count,
                0
            )
        }
        guard actualSize >= 0 else {
            throw metadataError(errno)
        }

        let bytes = names.prefix(actualSize).map {
            UInt8(bitPattern: $0)
        }
        var start = bytes.startIndex
        var observedNames = Set<String>()
        for index in bytes.indices where bytes[index] == 0 {
            guard start < index else {
                throw metadataError(EIO)
            }
            observedNames.insert(
                String(
                    decoding: bytes[start..<index],
                    as: UTF8.self
                )
            )
            start = bytes.index(after: index)
        }
        guard start == bytes.endIndex else {
            throw metadataError(EIO)
        }
        guard observedNames.isSubset(of: allowedNames) else {
            throw extendedAttributesError
        }
    }
}

/// Names the same descriptor-anchored lease mechanism when it protects
/// supervisor/receipt authority rather than the Metal device.
public typealias PrimeExclusiveProcessLease =
    PrimeMetalDeviceLease
