import CryptoKit
import Darwin
import DisposalProjectionPrimitivesC
import Foundation

struct DisposalPublishedArtifact: Equatable, Sendable {
    let leaf: String
    let bytes: Int
    let sha256: String
    let device: UInt64
    let inode: UInt64
    let mode: UInt16
    let linkCount: UInt64
}

final class DisposalSealedArtifactSet {
    let path: String
    private let parentPath: String
    private let leaf: String
    private let parentDescriptor: Int32
    private let rootDescriptor: Int32
    private let initialRootState: stat
    private var heldLeaves: [String: (descriptor: Int32, state: stat, sha256: String)] = [:]

    init(path: String) throws {
        self.path = path
        let url = URL(fileURLWithPath: path)
        parentPath = url.deletingLastPathComponent().path
        leaf = url.lastPathComponent
        try disposalRequire(path.hasPrefix("/private/tmp/"), "OUTPUT_NOT_PRIVATE_TMP")
        try disposalRequire(!leaf.isEmpty && !leaf.contains("/"), "OUTPUT_ROOT_LEAF")

        var resolved = [CChar](repeating: 0, count: Int(PATH_MAX))
        guard realpath(parentPath, &resolved) != nil else {
            throw DisposalSQLiteFailure.rejected(
                "OUTPUT_PARENT_REALPATH", String(cString: strerror(errno)))
        }
        let resolvedPath = String(
            decoding: resolved.prefix { $0 != 0 }.map { UInt8(bitPattern: $0) },
            as: UTF8.self)
        try disposalRequire(resolvedPath == parentPath, "OUTPUT_PARENT_ALIAS")

        let openedParent = Darwin.open(
            parentPath,
            O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW_ANY)
        guard openedParent >= 0 else {
            throw DisposalSQLiteFailure.rejected(
                "OUTPUT_PARENT_OPEN", String(cString: strerror(errno)))
        }
        var closeParent = true
        defer { if closeParent { _ = Darwin.close(openedParent) } }

        var existing = stat()
        errno = 0
        let prior = fstatat(openedParent, leaf, &existing, AT_SYMLINK_NOFOLLOW)
        try disposalRequire(prior != 0 && errno == ENOENT, "OUTPUT_ROOT_NOT_ABSENT")
        guard mkdirat(openedParent, leaf, 0o700) == 0 else {
            throw DisposalSQLiteFailure.rejected(
                "OUTPUT_ROOT_MKDIR", String(cString: strerror(errno)))
        }
        let openedRoot = leaf.withCString {
            disposal_projection_openat_directory_no_follow(openedParent, $0)
        }
        guard openedRoot >= 0 else {
            throw DisposalSQLiteFailure.rejected(
                "OUTPUT_ROOT_OPEN", String(cString: strerror(errno)))
        }
        var closeRoot = true
        defer { if closeRoot { _ = Darwin.close(openedRoot) } }

        var state = stat()
        guard fstat(openedRoot, &state) == 0 else {
            throw DisposalSQLiteFailure.rejected(
                "OUTPUT_ROOT_FSTAT", String(cString: strerror(errno)))
        }
        try disposalRequire((state.st_mode & S_IFMT) == S_IFDIR, "OUTPUT_ROOT_TYPE")
        try disposalRequire((state.st_mode & 0o7777) == 0o700, "OUTPUT_ROOT_MODE")
        try disposalRequire(state.st_uid == geteuid(), "OUTPUT_ROOT_OWNER")
        try disposalRequire(state.st_nlink == 2, "OUTPUT_ROOT_INITIAL_LINK_COUNT")

        parentDescriptor = openedParent
        rootDescriptor = openedRoot
        initialRootState = state
        try disposalSyncDirectory(openedParent)
        closeRoot = false
        closeParent = false
    }

    deinit {
        for value in heldLeaves.values { _ = Darwin.close(value.descriptor) }
        _ = Darwin.close(rootDescriptor)
        _ = Darwin.close(parentDescriptor)
    }

    func writeExclusive(leaf: String, data: Data) throws -> DisposalPublishedArtifact {
        try disposalRequire(!leaf.isEmpty && !leaf.contains("/"), "OUTPUT_FILE_LEAF")
        try disposalRequire(heldLeaves[leaf] == nil, "OUTPUT_FILE_DUPLICATE")
        let descriptor = leaf.withCString {
            disposal_projection_openat_create_exclusive_private(rootDescriptor, $0, 0o600)
        }
        guard descriptor >= 0 else {
            throw DisposalSQLiteFailure.rejected(
                "OUTPUT_FILE_CREATE", "\(leaf):\(String(cString: strerror(errno)))")
        }
        var closeOnFailure = true
        defer { if closeOnFailure { _ = Darwin.close(descriptor) } }

        var offset = 0
        while offset < data.count {
            let result = data.withUnsafeBytes { raw -> Int in
                guard let base = raw.baseAddress else { return -1 }
                return Darwin.write(
                    descriptor,
                    base.advanced(by: offset),
                    data.count - offset)
            }
            if result > 0 {
                offset += result
            } else if result < 0 && errno == EINTR {
                continue
            } else {
                throw DisposalSQLiteFailure.rejected(
                    "OUTPUT_FILE_WRITE", "\(leaf):\(String(cString: strerror(errno)))")
            }
        }
        try disposalSyncFile(descriptor)
        guard fchmod(descriptor, 0o400) == 0 else {
            throw DisposalSQLiteFailure.rejected(
                "OUTPUT_FILE_CHMOD", String(cString: strerror(errno)))
        }
        var state = stat()
        guard fstat(descriptor, &state) == 0 else {
            throw DisposalSQLiteFailure.rejected(
                "OUTPUT_FILE_FSTAT", String(cString: strerror(errno)))
        }
        try disposalRequire((state.st_mode & S_IFMT) == S_IFREG, "OUTPUT_FILE_TYPE")
        try disposalRequire((state.st_mode & 0o7777) == 0o400, "OUTPUT_FILE_MODE")
        try disposalRequire(state.st_nlink == 1, "OUTPUT_FILE_LINK_COUNT")
        try disposalRequire(state.st_size == off_t(data.count), "OUTPUT_FILE_SIZE")
        try disposalSyncFile(descriptor)

        let digest = disposalArtifactSHA256(data)
        heldLeaves[leaf] = (descriptor, state, digest)
        closeOnFailure = false
        try disposalSyncDirectory(rootDescriptor)
        return DisposalPublishedArtifact(
            leaf: leaf,
            bytes: data.count,
            sha256: digest,
            device: UInt64(state.st_dev),
            inode: UInt64(state.st_ino),
            mode: UInt16(state.st_mode & 0o7777),
            linkCount: UInt64(state.st_nlink))
    }

    func seal(expectedLeaves: [String]) throws {
        try disposalRequire(expectedLeaves.count == 4, "OUTPUT_EXACT_FOUR_LEAVES")
        try revalidateLeaves(expectedLeaves)
        var admittedRoot = stat()
        guard fstat(rootDescriptor, &admittedRoot) == 0 else {
            throw DisposalSQLiteFailure.rejected(
                "OUTPUT_ROOT_PRESEAL_FSTAT", String(cString: strerror(errno)))
        }
        try disposalRequire(
            admittedRoot.st_dev == initialRootState.st_dev &&
                admittedRoot.st_ino == initialRootState.st_ino,
            "OUTPUT_ROOT_PRESEAL_IDENTITY_DRIFT")
        try disposalRequire(
            (admittedRoot.st_mode & 0o7777) == 0o700,
            "OUTPUT_ROOT_PRESEAL_MODE")
        guard fchmod(rootDescriptor, 0o500) == 0 else {
            throw DisposalSQLiteFailure.rejected(
                "OUTPUT_ROOT_SEAL_MODE", String(cString: strerror(errno)))
        }
        try disposalSyncDirectory(rootDescriptor)
        try disposalSyncDirectory(parentDescriptor)

        var sealedRoot = stat()
        guard fstat(rootDescriptor, &sealedRoot) == 0 else {
            throw DisposalSQLiteFailure.rejected(
                "OUTPUT_ROOT_SEALED_FSTAT", String(cString: strerror(errno)))
        }
        try disposalRequire((sealedRoot.st_mode & 0o7777) == 0o500, "OUTPUT_ROOT_FINAL_MODE")
        try disposalRequire(
            sealedRoot.st_dev == initialRootState.st_dev &&
                sealedRoot.st_ino == initialRootState.st_ino,
            "OUTPUT_ROOT_IDENTITY_DRIFT")
        try disposalRequire(
            sealedRoot.st_nlink == admittedRoot.st_nlink,
            "OUTPUT_ROOT_FINAL_LINK_COUNT")

        try revalidateLeaves(expectedLeaves)
        var finalRoot = stat()
        var namedRoot = stat()
        guard fstat(rootDescriptor, &finalRoot) == 0,
              lstat(path, &namedRoot) == 0
        else {
            throw DisposalSQLiteFailure.rejected(
                "OUTPUT_ROOT_REVALIDATE", String(cString: strerror(errno)))
        }
        try disposalRequire(disposalSameState(sealedRoot, finalRoot), "OUTPUT_ROOT_POSTSEAL_DRIFT")
        try disposalRequire(disposalSameState(finalRoot, namedRoot), "OUTPUT_ROOT_REBOUND")
    }

    private func revalidateLeaves(_ expectedLeaves: [String]) throws {
        let actual = try disposalDirectoryEntries(rootDescriptor).sorted()
        try disposalRequire(actual == expectedLeaves.sorted(), "OUTPUT_INVENTORY")
        try disposalRequire(heldLeaves.keys.sorted() == expectedLeaves.sorted(), "OUTPUT_HELD_LEAVES")
        for leaf in expectedLeaves {
            guard let expected = heldLeaves[leaf] else {
                throw DisposalSQLiteFailure.rejected("OUTPUT_HELD_LEAF_ABSENT", leaf)
            }
            var held = stat()
            var named = stat()
            guard fstat(expected.descriptor, &held) == 0,
                  fstatat(rootDescriptor, leaf, &named, AT_SYMLINK_NOFOLLOW) == 0
            else {
                throw DisposalSQLiteFailure.rejected("OUTPUT_LEAF_FINAL_REVALIDATE", leaf)
            }
            try disposalRequire(disposalSameState(expected.state, held), "OUTPUT_LEAF_DRIFT", leaf)
            try disposalRequire(disposalSameState(held, named), "OUTPUT_LEAF_REBOUND", leaf)
            let bytes = try disposalPreadExact(
                descriptor: expected.descriptor,
                count: Int(held.st_size))
            try disposalRequire(
                disposalArtifactSHA256(bytes) == expected.sha256,
                "OUTPUT_LEAF_FINAL_SHA",
                leaf)
        }
    }
}

private func disposalArtifactSHA256(_ data: Data) -> String {
    SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
}

private func disposalDirectoryEntries(_ descriptor: Int32) throws -> [String] {
    let copied = dup(descriptor)
    guard copied >= 0 else {
        throw DisposalSQLiteFailure.rejected(
            "OUTPUT_ROOT_DUP", String(cString: strerror(errno)))
    }
    guard let directory = fdopendir(copied) else {
        _ = Darwin.close(copied)
        throw DisposalSQLiteFailure.rejected(
            "OUTPUT_ROOT_FDOPENDIR", String(cString: strerror(errno)))
    }
    defer { closedir(directory) }
    rewinddir(directory)
    var result: [String] = []
    errno = 0
    while let entry = readdir(directory) {
        let name = withUnsafePointer(to: &entry.pointee.d_name) {
            $0.withMemoryRebound(to: CChar.self, capacity: Int(NAME_MAX) + 1) {
                String(cString: $0)
            }
        }
        if name != "." && name != ".." { result.append(name) }
        errno = 0
    }
    try disposalRequire(errno == 0, "OUTPUT_ROOT_READDIR", String(cString: strerror(errno)))
    return result
}

private func disposalSyncFile(_ descriptor: Int32) throws {
    guard fsync(descriptor) == 0 else {
        throw DisposalSQLiteFailure.rejected("FSYNC", String(cString: strerror(errno)))
    }
    guard fcntl(descriptor, F_FULLFSYNC) == 0 else {
        throw DisposalSQLiteFailure.rejected("FULLFSYNC", String(cString: strerror(errno)))
    }
}

private func disposalSyncDirectory(_ descriptor: Int32) throws {
    guard fsync(descriptor) == 0 else {
        throw DisposalSQLiteFailure.rejected(
            "DIRECTORY_FSYNC", String(cString: strerror(errno)))
    }
}

private func disposalSameState(_ lhs: stat, _ rhs: stat) -> Bool {
    lhs.st_dev == rhs.st_dev &&
        lhs.st_ino == rhs.st_ino &&
        lhs.st_mode == rhs.st_mode &&
        lhs.st_nlink == rhs.st_nlink &&
        lhs.st_uid == rhs.st_uid &&
        lhs.st_gid == rhs.st_gid &&
        lhs.st_size == rhs.st_size &&
        lhs.st_gen == rhs.st_gen &&
        lhs.st_mtimespec.tv_sec == rhs.st_mtimespec.tv_sec &&
        lhs.st_mtimespec.tv_nsec == rhs.st_mtimespec.tv_nsec &&
        lhs.st_ctimespec.tv_sec == rhs.st_ctimespec.tv_sec &&
        lhs.st_ctimespec.tv_nsec == rhs.st_ctimespec.tv_nsec
}

private func disposalPreadExact(descriptor: Int32, count: Int) throws -> Data {
    var data = Data(count: count)
    var completed = 0
    while completed < count {
        let result = data.withUnsafeMutableBytes { raw -> Int in
            guard let base = raw.baseAddress else { return -1 }
            return pread(
                descriptor,
                base.advanced(by: completed),
                count - completed,
                off_t(completed))
        }
        if result > 0 {
            completed += result
        } else if result < 0 && errno == EINTR {
            continue
        } else if result == 0 && completed == count {
            break
        } else {
            throw DisposalSQLiteFailure.rejected(
                "OUTPUT_LEAF_FINAL_PREAD", String(cString: strerror(errno)))
        }
    }
    return data
}
