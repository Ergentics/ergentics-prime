import CryptoKit
import Darwin
import Foundation

enum PrimeLatinArtifactReadError: Error, Equatable, Sendable {
    case invalidRelativePath(String)
    case untrustedDirectory(String)
    case unsafeArtifact(String)
    case artifactTooLarge(String)
    case hashMismatch(String)
    case byteCountMismatch(String)
    case nonCanonicalJSON(String)
    case posix(operation: String, path: String, code: Int32)
}

enum PrimeLatinCanonicalJSON {
    static func encode<Value: Encodable>(_ value: Value) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(value)
    }

    static func decode<Value: Codable>(
        _ type: Value.Type,
        from data: Data,
        artifact: String
    ) throws -> Value {
        let value = try JSONDecoder().decode(type, from: data)
        guard try encode(value) == data else {
            throw PrimeLatinArtifactReadError.nonCanonicalJSON(artifact)
        }
        return value
    }
}

enum PrimeLatinSHA256 {
    private static let hexadecimal = Array("0123456789abcdef".utf8)

    static func hexDigest(of data: Data) -> String {
        encode(SHA256.hash(data: data))
    }

    fileprivate static func encode<Digest: Sequence>(
        _ digest: Digest
    ) -> String where Digest.Element == UInt8 {
        var bytes = [UInt8]()
        bytes.reserveCapacity(64)
        for byte in digest {
            bytes.append(hexadecimal[Int(byte >> 4)])
            bytes.append(hexadecimal[Int(byte & 0x0f)])
        }
        return String(decoding: bytes, as: UTF8.self)
    }
}

enum PrimeLatinArtifactPurpose: String, Equatable, Sendable {
    case immutableData = "immutable_data"

    fileprivate var mode: mode_t { mode_t(0o444) }
}

struct PrimeLatinCapturedArtifactBinding: Equatable, Sendable {
    let relativePath: String
    let sha256: String
    let byteCount: UInt64
    let purpose: PrimeLatinArtifactPurpose

    func validateDeclaration() throws {
        _ = try PrimeLatinArtifactRoot.components(of: relativePath)
        guard sha256.utf8.count == 64,
              sha256.utf8.allSatisfy({
                  ($0 >= 48 && $0 <= 57) || ($0 >= 97 && $0 <= 102)
              }) else {
            throw PrimeLatinArtifactReadError.unsafeArtifact(relativePath)
        }
    }
}

struct PrimeLatinVerifiedPublicationArtifact: Equatable, Sendable {
    let binding: PrimeLatinCapturedArtifactBinding
    let deviceID: UInt64
    let inode: UInt64
    let actualMode: UInt16
    let modificationSeconds: Int64
    let modificationNanoseconds: Int64
    let statusChangeSeconds: Int64
    let statusChangeNanoseconds: Int64
}

struct PrimeLatinVerifiedPublicationRead: Equatable, Sendable {
    let artifact: PrimeLatinVerifiedPublicationArtifact
    let data: Data
}

struct PrimeLatinArtifactRootIdentity: Equatable, Sendable {
    let deviceID: UInt64
    let inode: UInt64
    let ownerUserID: UInt32
    let ownerGroupID: UInt32
    let actualMode: UInt16
    let linkCount: UInt64
    let modificationSeconds: Int64
    let modificationNanoseconds: Int64
    let statusChangeSeconds: Int64
    let statusChangeNanoseconds: Int64
}

/// Read-only descriptor capability for one already-published Latin pair root.
/// It exposes no filesystem mutation or publication operation.
final class PrimeLatinArtifactRoot: @unchecked Sendable {
    private enum DescriptorKind {
        case directory
        case artifact

        func error(path: String) -> PrimeLatinArtifactReadError {
            switch self {
            case .directory:
                .untrustedDirectory(path)
            case .artifact:
                .unsafeArtifact(path)
            }
        }
    }

    private static let permittedSystemExtendedAttributes: Set<String> = [
        "com.apple.provenance",
    ]

    private let descriptor: Int32
    private let directoryURL: URL

    init(directoryURL: URL) throws {
        guard directoryURL.isFileURL else {
            throw PrimeLatinArtifactReadError.untrustedDirectory(
                directoryURL.absoluteString)
        }
        let opened = try Self.openAbsoluteDirectory(at: directoryURL.path)
        do {
            try Self.requireTrustedDirectory(
                opened,
                path: directoryURL.path)
        } catch {
            _ = close(opened)
            throw error
        }
        descriptor = opened
        self.directoryURL = directoryURL
    }

    deinit {
        _ = close(descriptor)
    }

    func verifiedRootIdentity() throws -> PrimeLatinArtifactRootIdentity {
        var before = stat()
        guard fstat(descriptor, &before) == 0 else {
            throw Self.posix(
                "fstat Latin artifact root identity",
                directoryURL.path)
        }
        try Self.requireTrustedDirectory(
            descriptor,
            path: directoryURL.path)
        var after = stat()
        guard fstat(descriptor, &after) == 0,
              before.st_dev == after.st_dev,
              before.st_ino == after.st_ino,
              before.st_uid == after.st_uid,
              before.st_gid == after.st_gid,
              before.st_mode == after.st_mode,
              before.st_nlink == after.st_nlink,
              before.st_mtimespec.tv_sec == after.st_mtimespec.tv_sec,
              before.st_mtimespec.tv_nsec == after.st_mtimespec.tv_nsec,
              before.st_ctimespec.tv_sec == after.st_ctimespec.tv_sec,
              before.st_ctimespec.tv_nsec == after.st_ctimespec.tv_nsec else {
            throw PrimeLatinArtifactReadError.untrustedDirectory(
                directoryURL.path)
        }
        return PrimeLatinArtifactRootIdentity(
            deviceID: UInt64(bitPattern: Int64(after.st_dev)),
            inode: UInt64(after.st_ino),
            ownerUserID: after.st_uid,
            ownerGroupID: after.st_gid,
            actualMode: UInt16(after.st_mode & mode_t(0o777)),
            linkCount: UInt64(after.st_nlink),
            modificationSeconds: Int64(after.st_mtimespec.tv_sec),
            modificationNanoseconds: Int64(after.st_mtimespec.tv_nsec),
            statusChangeSeconds: Int64(after.st_ctimespec.tv_sec),
            statusChangeNanoseconds: Int64(after.st_ctimespec.tv_nsec))
    }

    func bindExisting(
        at relativePath: String,
        purpose: PrimeLatinArtifactPurpose,
        maximumByteCount: UInt64
    ) throws -> PrimeLatinCapturedArtifactBinding {
        let parsed = try Self.components(of: relativePath)
        return try withParentDescriptor(
            components: parsed.parents,
            relativePath: relativePath
        ) { parent in
            let opened = try openArtifact(
                parent: parent,
                leaf: parsed.leaf,
                relativePath: relativePath)
            defer { _ = close(opened) }

            var initial = stat()
            guard fstat(opened, &initial) == 0,
                  initial.st_size >= 0 else {
                throw Self.posix("fstat existing artifact", relativePath)
            }
            let byteCount = UInt64(initial.st_size)
            guard byteCount <= maximumByteCount else {
                throw PrimeLatinArtifactReadError.artifactTooLarge(relativePath)
            }
            let before = try Self.artifactMetadata(
                opened,
                parent: parent,
                leaf: parsed.leaf,
                path: relativePath,
                purpose: purpose,
                expectedByteCount: byteCount)
            let digest = try Self.streamDigest(
                opened,
                path: relativePath,
                expectedByteCount: byteCount)
            let after = try Self.artifactMetadata(
                opened,
                parent: parent,
                leaf: parsed.leaf,
                path: relativePath,
                purpose: purpose,
                expectedByteCount: byteCount)
            try Self.requireStableFile(before, after, path: relativePath)
            return PrimeLatinCapturedArtifactBinding(
                relativePath: relativePath,
                sha256: digest,
                byteCount: byteCount,
                purpose: purpose)
        }
    }

    func readVerifiedArtifact(
        _ binding: PrimeLatinCapturedArtifactBinding,
        maximumByteCount: UInt64
    ) throws -> PrimeLatinVerifiedPublicationRead {
        guard binding.byteCount <= maximumByteCount else {
            throw PrimeLatinArtifactReadError.artifactTooLarge(
                binding.relativePath)
        }
        try binding.validateDeclaration()
        let parsed = try Self.components(of: binding.relativePath)
        return try withParentDescriptor(
            components: parsed.parents,
            relativePath: binding.relativePath
        ) { parent in
            let opened = try openArtifact(
                parent: parent,
                leaf: parsed.leaf,
                relativePath: binding.relativePath)
            defer { _ = close(opened) }
            let before = try Self.artifactMetadata(
                opened,
                parent: parent,
                leaf: parsed.leaf,
                path: binding.relativePath,
                purpose: binding.purpose,
                expectedByteCount: binding.byteCount)
            guard lseek(opened, 0, SEEK_SET) >= 0 else {
                throw Self.posix("seek artifact", binding.relativePath)
            }
            var data = Data()
            data.reserveCapacity(Int(binding.byteCount))
            var hasher = SHA256()
            var buffer = [UInt8](repeating: 0, count: 64 * 1024)
            while true {
                let count = buffer.withUnsafeMutableBytes {
                    read(opened, $0.baseAddress, $0.count)
                }
                if count < 0, errno == EINTR { continue }
                guard count >= 0 else {
                    throw Self.posix("read artifact", binding.relativePath)
                }
                if count == 0 { break }
                let chunk = Data(buffer[0 ..< count])
                hasher.update(data: chunk)
                data.append(chunk)
                guard UInt64(data.count) <= binding.byteCount,
                      UInt64(data.count) <= maximumByteCount else {
                    throw PrimeLatinArtifactReadError.artifactTooLarge(
                        binding.relativePath)
                }
            }
            let after = try Self.artifactMetadata(
                opened,
                parent: parent,
                leaf: parsed.leaf,
                path: binding.relativePath,
                purpose: binding.purpose,
                expectedByteCount: binding.byteCount)
            try Self.requireStableFile(
                before,
                after,
                path: binding.relativePath)
            guard UInt64(data.count) == binding.byteCount else {
                throw PrimeLatinArtifactReadError.byteCountMismatch(
                    binding.relativePath)
            }
            guard PrimeLatinSHA256.encode(hasher.finalize())
                    == binding.sha256 else {
                throw PrimeLatinArtifactReadError.hashMismatch(
                    binding.relativePath)
            }
            return PrimeLatinVerifiedPublicationRead(
                artifact: PrimeLatinVerifiedPublicationArtifact(
                    binding: binding,
                    deviceID: UInt64(bitPattern: Int64(after.st_dev)),
                    inode: UInt64(after.st_ino),
                    actualMode: UInt16(after.st_mode & mode_t(0o777)),
                    modificationSeconds: Int64(after.st_mtimespec.tv_sec),
                    modificationNanoseconds: Int64(after.st_mtimespec.tv_nsec),
                    statusChangeSeconds: Int64(after.st_ctimespec.tv_sec),
                    statusChangeNanoseconds: Int64(after.st_ctimespec.tv_nsec)),
                data: data)
        }
    }

    static func components(
        of relativePath: String
    ) throws -> (parents: ArraySlice<String>, leaf: String) {
        guard !relativePath.isEmpty,
              !relativePath.hasPrefix("/"),
              !relativePath.utf8.contains(0) else {
            throw PrimeLatinArtifactReadError.invalidRelativePath(relativePath)
        }
        let values = relativePath.split(
            separator: "/",
            omittingEmptySubsequences: false).map(String.init)
        guard let leaf = values.last,
              !leaf.isEmpty,
              values.allSatisfy({
                  !$0.isEmpty && $0 != "." && $0 != ".."
                    && !$0.utf8.contains(0) && $0.utf8.count <= 255
              }) else {
            throw PrimeLatinArtifactReadError.invalidRelativePath(relativePath)
        }
        return (values.dropLast(), leaf)
    }

    private static func openAbsoluteDirectory(at path: String) throws -> Int32 {
        let walkedPath = normalizedSystemRootAlias(path)
        let values = walkedPath.split(
            separator: "/",
            omittingEmptySubsequences: true).map(String.init)
        guard walkedPath.hasPrefix("/"),
              !walkedPath.utf8.contains(0),
              walkedPath == "/" + values.joined(separator: "/"),
              values.allSatisfy({
                  $0 != "." && $0 != ".." && !$0.utf8.contains(0)
                    && $0.utf8.count <= 255
              }) else {
            throw PrimeLatinArtifactReadError.untrustedDirectory(path)
        }
        let flags = O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC
        var current = "/".withCString { open($0, flags) }
        guard current >= 0 else {
            throw posix("open filesystem root", path)
        }
        for component in values {
            let next = component.withCString {
                openat(current, $0, flags)
            }
            let code = errno
            guard next >= 0 else {
                _ = close(current)
                throw PrimeLatinArtifactReadError.posix(
                    operation: "openat Latin artifact root component",
                    path: path,
                    code: code)
            }
            _ = close(current)
            current = next
        }
        return current
    }

    private static func normalizedSystemRootAlias(_ path: String) -> String {
        for name in ["tmp", "var", "etc"] {
            let alias = "/\(name)"
            if path == alias { return "/private/\(name)" }
            if path.hasPrefix(alias + "/") {
                return "/private/\(name)" +
                    String(path.dropFirst(alias.utf8.count))
            }
        }
        return path
    }

    private func withParentDescriptor<Result>(
        components: ArraySlice<String>,
        relativePath: String,
        operation: (Int32) throws -> Result
    ) throws -> Result {
        let duplicated = fcntl(descriptor, F_DUPFD_CLOEXEC, 0)
        guard duplicated >= 0 else {
            throw Self.posix("duplicate Latin artifact root", directoryURL.path)
        }
        var current = duplicated
        defer { _ = close(current) }
        try Self.requireTrustedDirectory(current, path: directoryURL.path)
        for component in components {
            let next = component.withCString {
                openat(
                    current,
                    $0,
                    O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC)
            }
            guard next >= 0 else {
                throw Self.posix("openat artifact parent", relativePath)
            }
            do {
                try Self.requireTrustedDirectory(next, path: relativePath)
            } catch {
                _ = close(next)
                throw error
            }
            _ = close(current)
            current = next
        }
        return try operation(current)
    }

    private func openArtifact(
        parent: Int32,
        leaf: String,
        relativePath: String
    ) throws -> Int32 {
        let opened = leaf.withCString {
            openat(
                parent,
                $0,
                O_RDONLY | O_NONBLOCK | O_NOFOLLOW | O_CLOEXEC)
        }
        guard opened >= 0 else {
            throw Self.posix("openat artifact", relativePath)
        }
        return opened
    }

    private static func artifactMetadata(
        _ descriptor: Int32,
        parent: Int32,
        leaf: String,
        path: String,
        purpose: PrimeLatinArtifactPurpose,
        expectedByteCount: UInt64
    ) throws -> stat {
        var opened = stat()
        guard fstat(descriptor, &opened) == 0 else {
            throw posix("fstat artifact", path)
        }
        var bound = stat()
        let status = leaf.withCString {
            fstatat(parent, $0, &bound, AT_SYMLINK_NOFOLLOW)
        }
        guard status == 0,
              opened.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
              bound.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
              opened.st_uid == geteuid(),
              bound.st_uid == geteuid(),
              opened.st_nlink == 1,
              bound.st_nlink == 1,
              opened.st_dev == bound.st_dev,
              opened.st_ino == bound.st_ino,
              opened.st_size >= 0,
              UInt64(opened.st_size) == expectedByteCount,
              opened.st_mode & mode_t(0o7777) == purpose.mode,
              bound.st_mode & mode_t(0o7777) == purpose.mode else {
            if opened.st_size >= 0,
               UInt64(opened.st_size) != expectedByteCount {
                throw PrimeLatinArtifactReadError.byteCountMismatch(path)
            }
            throw PrimeLatinArtifactReadError.unsafeArtifact(path)
        }
        try requireStableFile(opened, bound, path: path)
        try requireTrustedDescriptorMetadata(
            descriptor,
            path: path,
            kind: .artifact)
        return opened
    }

    private static func requireStableFile(
        _ before: stat,
        _ after: stat,
        path: String
    ) throws {
        guard before.st_dev == after.st_dev,
              before.st_ino == after.st_ino,
              before.st_size == after.st_size,
              before.st_mtimespec.tv_sec == after.st_mtimespec.tv_sec,
              before.st_mtimespec.tv_nsec == after.st_mtimespec.tv_nsec,
              before.st_ctimespec.tv_sec == after.st_ctimespec.tv_sec,
              before.st_ctimespec.tv_nsec == after.st_ctimespec.tv_nsec else {
            throw PrimeLatinArtifactReadError.unsafeArtifact(path)
        }
    }

    private static func streamDigest(
        _ descriptor: Int32,
        path: String,
        expectedByteCount: UInt64
    ) throws -> String {
        guard lseek(descriptor, 0, SEEK_SET) >= 0 else {
            throw posix("seek artifact", path)
        }
        var hasher = SHA256()
        var total: UInt64 = 0
        var buffer = [UInt8](repeating: 0, count: 64 * 1024)
        while true {
            let count = buffer.withUnsafeMutableBytes {
                read(descriptor, $0.baseAddress, $0.count)
            }
            if count < 0, errno == EINTR { continue }
            guard count >= 0 else { throw posix("read artifact", path) }
            if count == 0 { break }
            let (next, overflow) = total.addingReportingOverflow(UInt64(count))
            guard !overflow, next <= expectedByteCount else {
                throw PrimeLatinArtifactReadError.byteCountMismatch(path)
            }
            hasher.update(data: Data(buffer[0 ..< count]))
            total = next
        }
        guard total == expectedByteCount else {
            throw PrimeLatinArtifactReadError.byteCountMismatch(path)
        }
        return PrimeLatinSHA256.encode(hasher.finalize())
    }

    private static func requireTrustedDirectory(
        _ descriptor: Int32,
        path: String
    ) throws {
        var metadata = stat()
        guard fstat(descriptor, &metadata) == 0 else {
            throw posix("fstat artifact directory", path)
        }
        guard metadata.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
              metadata.st_uid == geteuid(),
              metadata.st_mode & mode_t(0o022) == 0,
              metadata.st_mode & mode_t(0o7000) == 0 else {
            throw PrimeLatinArtifactReadError.untrustedDirectory(path)
        }
        try requireTrustedDescriptorMetadata(
            descriptor,
            path: path,
            kind: .directory)
    }

    private static func requireTrustedDescriptorMetadata(
        _ descriptor: Int32,
        path: String,
        kind: DescriptorKind
    ) throws {
        errno = 0
        if let accessControlList = acl_get_fd_np(
            descriptor,
            ACL_TYPE_EXTENDED
        ) {
            acl_free(UnsafeMutableRawPointer(accessControlList))
            throw kind.error(path: path)
        } else if errno != ENOENT {
            throw kind.error(path: path)
        }

        errno = 0
        let requiredSize = flistxattr(descriptor, nil, 0, 0)
        guard requiredSize >= 0, requiredSize <= 65_536 else {
            throw kind.error(path: path)
        }
        guard requiredSize > 0 else { return }

        var names = [CChar](repeating: 0, count: requiredSize)
        let actualSize = names.withUnsafeMutableBufferPointer {
            flistxattr(descriptor, $0.baseAddress, $0.count, 0)
        }
        guard actualSize == requiredSize else {
            throw kind.error(path: path)
        }
        let bytes = names.prefix(actualSize).map { UInt8(bitPattern: $0) }
        var start = bytes.startIndex
        var observedNames = Set<String>()
        for index in bytes.indices where bytes[index] == 0 {
            guard start < index,
                  let name = String(
                    bytes: bytes[start ..< index],
                    encoding: .utf8) else {
                throw kind.error(path: path)
            }
            observedNames.insert(name)
            start = bytes.index(after: index)
        }
        guard start == bytes.endIndex,
              observedNames.isSubset(of: permittedSystemExtendedAttributes)
        else {
            throw kind.error(path: path)
        }
    }

    private static func posix(
        _ operation: String,
        _ path: String,
        code: Int32 = errno
    ) -> PrimeLatinArtifactReadError {
        .posix(operation: operation, path: path, code: code)
    }
}
