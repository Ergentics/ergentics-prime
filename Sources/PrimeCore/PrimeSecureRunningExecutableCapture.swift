#if canImport(Darwin)
import Darwin
import MachO
#else
import Glibc
#endif
import Foundation

public enum PrimeSecureRunningExecutableCaptureError:
    Error,
    Equatable,
    Sendable
{
    case invalidExecutable(String)
}

/// A retained, descriptor-backed observation of the current process's loaded
/// main image.
///
/// This is module-internal live authority. It is intentionally non-Codable,
/// has no public initializer, and keeps the authenticated descriptor open so
/// later guard checkpoints can prove that the mapped image and its named path
/// still join to the same immutable bytes.
final class PrimeSecureHeldRunningExecutable: @unchecked Sendable {
    let canonicalAbsolutePath: String
    let data: Data
    let deviceID: UInt64
    let inode: UInt64
    let ownerUserID: UInt32
    let ownerGroupID: UInt32
    let permissionMode: UInt16
    let linkCount: UInt64
    let byteCount: UInt64
    let modificationSeconds: Int64
    let modificationNanoseconds: Int64
    let statusChangeSeconds: Int64
    let statusChangeNanoseconds: Int64

    private let descriptor: Int32
    private let initialStatus: stat

    init(allowRootOwnerForTesting: Bool = false) throws {
        #if os(macOS)
        var requiredSize: UInt32 = 0
        _ = _NSGetExecutablePath(nil, &requiredSize)
        guard requiredSize > 1 else {
            throw Self.invalid("path")
        }
        var pathBuffer = [CChar](
            repeating: 0,
            count: Int(requiredSize)
        )
        guard _NSGetExecutablePath(
            &pathBuffer,
            &requiredSize
        ) == 0 else {
            throw Self.invalid("path")
        }
        let url = URL(
            fileURLWithPath: String(cString: pathBuffer)
        ).resolvingSymlinksInPath().standardizedFileURL
        let loaded = try PrimeNative3BLoadedExecutableVnode
            .observeCurrentProcess()

        var pathMetadata = stat()
        guard lstat(url.path, &pathMetadata) == 0 else {
            throw Self.invalid("path stat \(errno)")
        }
        guard Self.isAdmittedExecutable(
            pathMetadata,
            allowRootOwnerForTesting: allowRootOwnerForTesting
        ) else {
            throw Self.invalid(
                "path metadata mode=\(pathMetadata.st_mode) " +
                    "uid=\(pathMetadata.st_uid) euid=\(geteuid()) " +
                    "links=\(pathMetadata.st_nlink) " +
                    "size=\(pathMetadata.st_size)"
            )
        }

        let opened = open(
            url.path,
            O_RDONLY | O_NOFOLLOW | O_CLOEXEC
        )
        guard opened >= 0 else {
            throw Self.invalid("open")
        }
        descriptor = opened

        do {
            var before = stat()
            guard fstat(descriptor, &before) == 0,
                  Self.isAdmittedExecutable(
                      before,
                      allowRootOwnerForTesting: allowRootOwnerForTesting
                  ),
                  Self.sameIdentityAndMetadata(before, pathMetadata),
                  fcntl(descriptor, F_GETFD) & FD_CLOEXEC != 0
            else {
                throw Self.invalid("descriptor identity")
            }
            try loaded.requireMatches(
                deviceID: UInt64(bitPattern: Int64(before.st_dev)),
                inode: UInt64(before.st_ino)
            )

            let captured = try Self.readExact(
                descriptor: descriptor,
                byteCount: Int(before.st_size)
            )
            var after = stat()
            guard fstat(descriptor, &after) == 0,
                  Self.sameIdentityAndMetadata(before, after),
                  captured.count == Int(after.st_size)
            else {
                throw Self.invalid("changed during read")
            }

            canonicalAbsolutePath = url.path
            data = captured
            initialStatus = after
            deviceID = UInt64(bitPattern: Int64(after.st_dev))
            inode = UInt64(after.st_ino)
            ownerUserID = after.st_uid
            ownerGroupID = after.st_gid
            permissionMode = UInt16(after.st_mode & mode_t(0o777))
            linkCount = UInt64(after.st_nlink)
            byteCount = UInt64(after.st_size)
            modificationSeconds = Int64(after.st_mtimespec.tv_sec)
            modificationNanoseconds = Int64(after.st_mtimespec.tv_nsec)
            statusChangeSeconds = Int64(after.st_ctimespec.tv_sec)
            statusChangeNanoseconds = Int64(after.st_ctimespec.tv_nsec)
        } catch {
            _ = close(descriptor)
            throw error
        }
        #else
        throw Self.invalid("unsupported platform")
        #endif
    }

    deinit {
        _ = close(descriptor)
    }

    func revalidate() throws {
        #if os(macOS)
        let loaded = try PrimeNative3BLoadedExecutableVnode
            .observeCurrentProcess()
        var held = stat()
        guard fstat(descriptor, &held) == 0,
              Self.sameIdentityAndMetadata(initialStatus, held),
              fcntl(descriptor, F_GETFD) & FD_CLOEXEC != 0
        else {
            throw Self.invalid("held descriptor changed")
        }
        try loaded.requireMatches(
            deviceID: deviceID,
            inode: inode
        )

        let rebound = open(
            canonicalAbsolutePath,
            O_RDONLY | O_NOFOLLOW | O_CLOEXEC
        )
        guard rebound >= 0 else {
            throw Self.invalid("path rebound open")
        }
        defer { _ = close(rebound) }
        var named = stat()
        guard fstat(rebound, &named) == 0,
              Self.sameIdentityAndMetadata(initialStatus, named),
              try Self.readExact(
                  descriptor: descriptor,
                  byteCount: Int(initialStatus.st_size)
              ) == data,
              try Self.readExact(
                  descriptor: rebound,
                  byteCount: Int(initialStatus.st_size)
              ) == data
        else {
            throw Self.invalid("path rebound changed")
        }
        #else
        throw Self.invalid("unsupported platform")
        #endif
    }

    private static func isAdmittedExecutable(
        _ value: stat,
        allowRootOwnerForTesting: Bool
    ) -> Bool {
        value.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG)
            && (value.st_uid == geteuid()
                || (allowRootOwnerForTesting && value.st_uid == 0))
            && value.st_mode & mode_t(0o022) == 0
            && value.st_mode & mode_t(0o111) != 0
            && value.st_nlink == 1
            && value.st_size > 0
            && UInt64(value.st_size)
                <= PrimeSecureRunningExecutableCapture.maximumByteCount
    }

    private static func sameIdentityAndMetadata(
        _ lhs: stat,
        _ rhs: stat
    ) -> Bool {
        lhs.st_dev == rhs.st_dev
            && lhs.st_ino == rhs.st_ino
            && lhs.st_mode == rhs.st_mode
            && lhs.st_uid == rhs.st_uid
            && lhs.st_gid == rhs.st_gid
            && lhs.st_nlink == rhs.st_nlink
            && lhs.st_size == rhs.st_size
            && lhs.st_mtimespec.tv_sec == rhs.st_mtimespec.tv_sec
            && lhs.st_mtimespec.tv_nsec == rhs.st_mtimespec.tv_nsec
            && lhs.st_ctimespec.tv_sec == rhs.st_ctimespec.tv_sec
            && lhs.st_ctimespec.tv_nsec == rhs.st_ctimespec.tv_nsec
    }

    private static func readExact(
        descriptor: Int32,
        byteCount: Int
    ) throws -> Data {
        guard byteCount > 0,
              UInt64(byteCount)
                <= PrimeSecureRunningExecutableCapture.maximumByteCount
        else {
            throw invalid("size")
        }
        var result = Data()
        result.reserveCapacity(byteCount)
        var offset = 0
        var buffer = [UInt8](repeating: 0, count: 64 * 1024)
        while offset < byteCount {
            let wanted = min(buffer.count, byteCount - offset)
            let count = buffer.withUnsafeMutableBytes {
                pread(descriptor, $0.baseAddress, wanted, off_t(offset))
            }
            if count < 0, errno == EINTR { continue }
            guard count > 0 else {
                throw invalid("read")
            }
            result.append(contentsOf: buffer[0 ..< count])
            offset += count
        }
        var trailing: UInt8 = 0
        let trailingCount = withUnsafeMutablePointer(to: &trailing) {
            pread(descriptor, $0, 1, off_t(byteCount))
        }
        guard trailingCount == 0 else {
            throw invalid("trailing bytes")
        }
        return result
    }

    private static func invalid(
        _ detail: String
    ) -> PrimeSecureRunningExecutableCaptureError {
        .invalidExecutable(detail)
    }
}

extension PrimeSecureRunningExecutableCaptureError:
    LocalizedError
{
    public var errorDescription: String? {
        switch self {
        case let .invalidExecutable(detail):
            "running executable capture rejected: \(detail)"
        }
    }
}

/// Captures the exact regular file backing the current process's loaded main
/// image.
///
/// The pathname is admitted only after its descriptor identity is matched to
/// the vnode reported for the loaded Mach-O image. The open descriptor is
/// then read with bounded size and stable metadata checks. This utility does
/// not launch another process and does not resolve or execute donor code.
public enum PrimeSecureRunningExecutableCapture {
    public static let maximumByteCount: UInt64 =
        256 * 1024 * 1024

    public static func data() throws -> Data {
        try heldExecutable().data
    }

    static func heldExecutable() throws
        -> PrimeSecureHeldRunningExecutable
    {
        try PrimeSecureHeldRunningExecutable()
    }

    static func heldExecutableAllowingRootOwnerForTesting() throws
        -> PrimeSecureHeldRunningExecutable
    {
        try PrimeSecureHeldRunningExecutable(
            allowRootOwnerForTesting: true
        )
    }
}
