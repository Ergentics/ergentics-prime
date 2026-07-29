import Darwin
import Foundation

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
            expectedOwner: expectedOwner
        )
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
                expectedOwner: expectedOwner
            )
        } catch {
            flock(parentDescriptor, LOCK_UN)
            parentLockHeld = false
            throw error
        }

        let openedDescriptor = name.withCString { namePointer in
            openat(
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
            expectedOwner: expectedOwner
        )
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
                expectedOwner: expectedOwner
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
        } catch {
            flock(openedDescriptor, LOCK_UN)
            throw error
        }

        keepDescriptor = true
        keepParentDescriptor = true
        return PrimeMetalDeviceLease(
            fileURL: fileURL,
            descriptor: openedDescriptor,
            parentDescriptor: parentDescriptor
        )
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
        expectedOwner: uid_t
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
        guard permissionBits & mode_t(0o022) == 0 else {
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
            allowedNames: permittedSystemExtendedAttributes,
            extendedAttributesError:
                .parentHasExtendedAttributes,
            metadataError: {
                .parentMetadataReadFailed(errno: $0)
            }
        )
    }

    private static func validateLeaseFile(
        descriptor: Int32,
        expectedOwner: uid_t
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
            allowedNames: permittedSystemExtendedAttributes,
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
        defer {
            acl_free(
                UnsafeMutableRawPointer(accessControlList)
            )
        }

        var entry: acl_entry_t?
        let result = acl_get_entry(
            accessControlList,
            Int32(ACL_FIRST_ENTRY.rawValue),
            &entry
        )
        if result > 0 {
            throw accessControlListError
        }
        if result < 0 {
            throw metadataError(errno)
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
