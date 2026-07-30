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
        #if os(macOS)
        var requiredSize: UInt32 = 0
        _ = _NSGetExecutablePath(nil, &requiredSize)
        guard requiredSize > 1 else {
            throw PrimeSecureRunningExecutableCaptureError
                .invalidExecutable("path")
        }
        var pathBuffer = [CChar](
            repeating: 0,
            count: Int(requiredSize)
        )
        guard _NSGetExecutablePath(
            &pathBuffer,
            &requiredSize
        ) == 0 else {
            throw PrimeSecureRunningExecutableCaptureError
                .invalidExecutable("path")
        }
        let url = URL(
            fileURLWithPath: String(cString: pathBuffer)
        ).resolvingSymlinksInPath().standardizedFileURL
        let loaded =
            try PrimeNative3BLoadedExecutableVnode
                .observeCurrentProcess()

        var pathMetadata = stat()
        guard lstat(url.path, &pathMetadata) == 0,
              pathMetadata.st_mode & mode_t(S_IFMT)
                == mode_t(S_IFREG),
              pathMetadata.st_uid == geteuid(),
              pathMetadata.st_mode & mode_t(0o022) == 0,
              pathMetadata.st_nlink == 1,
              pathMetadata.st_size > 0,
              UInt64(pathMetadata.st_size)
                <= maximumByteCount else {
            throw PrimeSecureRunningExecutableCaptureError
                .invalidExecutable("path metadata")
        }

        let descriptor = open(
            url.path,
            O_RDONLY | O_NOFOLLOW | O_CLOEXEC
        )
        guard descriptor >= 0 else {
            throw PrimeSecureRunningExecutableCaptureError
                .invalidExecutable("open")
        }
        defer {
            _ = close(descriptor)
        }

        var before = stat()
        guard fstat(descriptor, &before) == 0,
              before.st_mode & mode_t(S_IFMT)
                == mode_t(S_IFREG),
              before.st_uid == geteuid(),
              before.st_mode & mode_t(0o022) == 0,
              before.st_nlink == 1,
              before.st_size > 0,
              UInt64(before.st_size)
                <= maximumByteCount,
              before.st_dev == pathMetadata.st_dev,
              before.st_ino == pathMetadata.st_ino,
              before.st_size == pathMetadata.st_size else {
            throw PrimeSecureRunningExecutableCaptureError
                .invalidExecutable("descriptor identity")
        }
        try loaded.requireMatches(
            deviceID:
                UInt64(bitPattern: Int64(before.st_dev)),
            inode: UInt64(before.st_ino)
        )

        var result = Data()
        result.reserveCapacity(Int(before.st_size))
        var buffer = [UInt8](
            repeating: 0,
            count: 64 * 1024
        )
        while true {
            let count = buffer.withUnsafeMutableBytes {
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
                throw PrimeSecureRunningExecutableCaptureError
                    .invalidExecutable("read")
            }
            if count == 0 {
                break
            }
            result.append(
                contentsOf: buffer[0 ..< count]
            )
            guard UInt64(result.count)
                    <= maximumByteCount else {
                throw PrimeSecureRunningExecutableCaptureError
                    .invalidExecutable("size")
            }
        }

        var after = stat()
        guard fstat(descriptor, &after) == 0,
              before.st_dev == after.st_dev,
              before.st_ino == after.st_ino,
              before.st_size == after.st_size,
              before.st_mtimespec.tv_sec
                == after.st_mtimespec.tv_sec,
              before.st_mtimespec.tv_nsec
                == after.st_mtimespec.tv_nsec,
              before.st_ctimespec.tv_sec
                == after.st_ctimespec.tv_sec,
              before.st_ctimespec.tv_nsec
                == after.st_ctimespec.tv_nsec,
              result.count == Int(after.st_size) else {
            throw PrimeSecureRunningExecutableCaptureError
                .invalidExecutable("changed during read")
        }
        return result
        #else
        throw PrimeSecureRunningExecutableCaptureError
            .invalidExecutable("unsupported platform")
        #endif
    }
}
