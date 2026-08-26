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
    static let stagingLeafPrefix = ".ergentics-disposal-staging-"

    let path: String
    let stagingPath: String
    private let parentPath: String
    private let finalLeaf: String
    private let stagingLeaf: String
    private let parentDescriptor: Int32
    private let rootDescriptor: Int32
    private let admittedParentState: stat
    private let initialRootState: stat
    private var heldLeaves: [String: (descriptor: Int32, state: stat, sha256: String)] = [:]
    private var preparedLeaves: [String]?
    private var preparedRootState: stat?
    private var publicationPrepared = false
    private var published = false

    static func stagingPath(for finalPath: String) -> String {
        let url = URL(fileURLWithPath: finalPath)
        return url.deletingLastPathComponent().path + "/" + stagingLeaf(for: finalPath)
    }

    private static func stagingLeaf(for finalPath: String) -> String {
        stagingLeafPrefix + disposalArtifactSHA256(Data(finalPath.utf8))
    }

    init(path: String) throws {
        self.path = path
        try disposalRequire(path.hasPrefix("/private/tmp/"), "OUTPUT_NOT_PRIVATE_TMP")
        try disposalRequire(!path.utf8.contains(0), "OUTPUT_ROOT_PATH_SHAPE")
        let lexicalComponents = path.split(
            separator: "/",
            omittingEmptySubsequences: false)
        try disposalRequire(
            lexicalComponents.first?.isEmpty == true &&
                lexicalComponents.dropFirst().allSatisfy {
                    !$0.isEmpty && $0 != "." && $0 != ".."
                },
            "OUTPUT_ROOT_PATH_SHAPE")
        let url = URL(fileURLWithPath: path)
        parentPath = url.deletingLastPathComponent().path
        finalLeaf = url.lastPathComponent
        stagingLeaf = Self.stagingLeaf(for: path)
        stagingPath = parentPath + "/" + stagingLeaf
        try disposalRequire(
            !finalLeaf.isEmpty && finalLeaf != "." && finalLeaf != ".." &&
                !finalLeaf.contains("/") &&
                parentPath + "/" + finalLeaf == path,
            "OUTPUT_ROOT_PATH_SHAPE")
        try disposalRequire(
            !finalLeaf.hasPrefix(Self.stagingLeafPrefix),
            "OUTPUT_ROOT_RESERVED_LEAF")

        var resolved = [CChar](repeating: 0, count: Int(PATH_MAX))
        guard realpath(parentPath, &resolved) != nil else {
            throw DisposalSQLiteFailure.rejected(
                "OUTPUT_PARENT_REALPATH", String(cString: strerror(errno)))
        }
        let resolvedPath = String(
            decoding: resolved.prefix { $0 != 0 }.map { UInt8(bitPattern: $0) },
            as: UTF8.self)
        try disposalRequire(resolvedPath == parentPath, "OUTPUT_PARENT_ALIAS")

        var namedParentBefore = stat()
        guard lstat(parentPath, &namedParentBefore) == 0 else {
            throw DisposalSQLiteFailure.rejected(
                "OUTPUT_PARENT_LSTAT", String(cString: strerror(errno)))
        }
        try disposalRequire(
            (namedParentBefore.st_mode & S_IFMT) == S_IFDIR,
            "OUTPUT_PARENT_NAMED_TYPE")

        let openedParent = Darwin.open(
            parentPath,
            O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW_ANY)
        guard openedParent >= 0 else {
            throw DisposalSQLiteFailure.rejected(
                "OUTPUT_PARENT_OPEN", String(cString: strerror(errno)))
        }
        var closeParent = true
        defer { if closeParent { _ = Darwin.close(openedParent) } }

        var parentState = stat()
        guard fstat(openedParent, &parentState) == 0 else {
            throw DisposalSQLiteFailure.rejected(
                "OUTPUT_PARENT_FSTAT", String(cString: strerror(errno)))
        }
        try disposalRequire(
            disposalSameIdentity(namedParentBefore, parentState),
            "OUTPUT_PARENT_NAMED_HELD_JOIN")

        for (candidate, code) in [
            (finalLeaf, "OUTPUT_ROOT_NOT_ABSENT"),
            (stagingLeaf, "OUTPUT_STAGING_NOT_ABSENT"),
        ] {
            var existing = stat()
            errno = 0
            let prior = fstatat(openedParent, candidate, &existing, AT_SYMLINK_NOFOLLOW)
            try disposalRequire(prior != 0 && errno == ENOENT, code)
        }
        guard mkdirat(openedParent, stagingLeaf, 0o700) == 0 else {
            throw DisposalSQLiteFailure.rejected(
                "OUTPUT_STAGING_MKDIR", String(cString: strerror(errno)))
        }
        let openedRoot = stagingLeaf.withCString {
            disposal_projection_openat_directory_no_follow(openedParent, $0)
        }
        guard openedRoot >= 0 else {
            throw DisposalSQLiteFailure.rejected(
                "OUTPUT_STAGING_OPEN", String(cString: strerror(errno)))
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
        admittedParentState = parentState
        initialRootState = state
        try disposalSyncDirectory(openedParent)
        try revalidateParentIdentity()
        closeRoot = false
        closeParent = false
    }

    deinit {
        for value in heldLeaves.values { _ = Darwin.close(value.descriptor) }
        _ = Darwin.close(rootDescriptor)
        _ = Darwin.close(parentDescriptor)
    }

    func writeExclusive(leaf: String, data: Data) throws -> DisposalPublishedArtifact {
        try disposalRequire(
            !publicationPrepared && !published,
            "OUTPUT_WRITE_AFTER_PUBLICATION_PREPARATION")
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

    func prepareForPublication(expectedLeaves: [String]) throws {
        try disposalRequire(
            !publicationPrepared && !published,
            "OUTPUT_PUBLICATION_ALREADY_PREPARED")
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
        try disposalSyncDirectory(rootDescriptor)
        try disposalSyncDirectory(parentDescriptor)
        try revalidateLeaves(expectedLeaves)
        var presealRoot = stat()
        var namedRoot = stat()
        guard fstat(rootDescriptor, &presealRoot) == 0,
              fstatat(
                parentDescriptor,
                stagingLeaf,
                &namedRoot,
                AT_SYMLINK_NOFOLLOW) == 0
        else {
            throw DisposalSQLiteFailure.rejected(
                "OUTPUT_ROOT_PREPUBLICATION_REVALIDATE", String(cString: strerror(errno)))
        }
        try disposalRequire(
            disposalSameState(admittedRoot, presealRoot),
            "OUTPUT_ROOT_PREPUBLICATION_DRIFT")
        try disposalRequire(
            disposalSameState(presealRoot, namedRoot),
            "OUTPUT_ROOT_PREPUBLICATION_REBOUND")

        guard fchmod(rootDescriptor, 0o500) == 0 else {
            throw DisposalSQLiteFailure.rejected(
                "OUTPUT_STAGING_SEAL_MODE", String(cString: strerror(errno)))
        }
        try disposalSyncDirectory(rootDescriptor)
        try disposalSyncDirectory(parentDescriptor)
        try revalidateLeaves(expectedLeaves)
        var sealedRoot = stat()
        var namedSealedRoot = stat()
        guard fstat(rootDescriptor, &sealedRoot) == 0,
              fstatat(
                parentDescriptor,
                stagingLeaf,
                &namedSealedRoot,
                AT_SYMLINK_NOFOLLOW) == 0
        else {
            throw DisposalSQLiteFailure.rejected(
                "OUTPUT_STAGING_SEALED_REVALIDATE", String(cString: strerror(errno)))
        }
        try disposalRequire(
            sealedRoot.st_dev == presealRoot.st_dev &&
                sealedRoot.st_ino == presealRoot.st_ino &&
                sealedRoot.st_gen == presealRoot.st_gen &&
                sealedRoot.st_nlink == presealRoot.st_nlink &&
                (sealedRoot.st_mode & 0o7777) == 0o500,
            "OUTPUT_STAGING_SEALED_STATE")
        try disposalRequire(
            disposalSameState(sealedRoot, namedSealedRoot),
            "OUTPUT_STAGING_SEALED_REBOUND")
        preparedLeaves = expectedLeaves.sorted()
        preparedRootState = sealedRoot
        publicationPrepared = true
    }

    func publish(
        afterPreparedOutputRevalidation finalPredecessorCheck: () throws -> Void
    ) throws {
        try disposalRequire(
            publicationPrepared && !published,
            "OUTPUT_PUBLICATION_NOT_PREPARED")
        guard let expectedLeaves = preparedLeaves,
              let expectedRoot = preparedRootState
        else {
            throw DisposalSQLiteFailure.rejected("OUTPUT_PREPARED_STATE_ABSENT", "")
        }
        try revalidateParentIdentity()
        try revalidateLeaves(expectedLeaves)
        var heldRoot = stat()
        var namedStagingRoot = stat()
        guard fstat(rootDescriptor, &heldRoot) == 0,
              fstatat(
                parentDescriptor,
                stagingLeaf,
                &namedStagingRoot,
                AT_SYMLINK_NOFOLLOW) == 0
        else {
            throw DisposalSQLiteFailure.rejected(
                "OUTPUT_STAGING_FINAL_REVALIDATE", String(cString: strerror(errno)))
        }
        try disposalRequire(
            disposalSameState(expectedRoot, heldRoot),
            "OUTPUT_STAGING_FINAL_DRIFT")
        try disposalRequire(
            disposalSameState(heldRoot, namedStagingRoot),
            "OUTPUT_STAGING_FINAL_REBOUND")
        try finalPredecessorCheck()

        // The predecessor check can be arbitrarily expensive. Repeat the held
        // output and named-parent joins after it so neither object can be
        // deterministically changed by the check itself and still publish.
        try revalidateLeaves(expectedLeaves)
        var heldRootAfterPredecessor = stat()
        var namedRootAfterPredecessor = stat()
        guard fstat(rootDescriptor, &heldRootAfterPredecessor) == 0,
              fstatat(
                parentDescriptor,
                stagingLeaf,
                &namedRootAfterPredecessor,
                AT_SYMLINK_NOFOLLOW) == 0
        else {
            throw DisposalSQLiteFailure.rejected(
                "OUTPUT_STAGING_POSTPREDECESSOR_REVALIDATE",
                String(cString: strerror(errno)))
        }
        try disposalRequire(
            disposalSameState(expectedRoot, heldRootAfterPredecessor),
            "OUTPUT_STAGING_POSTPREDECESSOR_DRIFT")
        try disposalRequire(
            disposalSameState(heldRootAfterPredecessor, namedRootAfterPredecessor),
            "OUTPUT_STAGING_POSTPREDECESSOR_REBOUND")
        try revalidateParentIdentity()

        // Exclusive rename is the publication linearization point. The staging
        // namespace is reader-ineligible, and no fallible operation follows a
        // successful rename in this builder invocation.
        let result = stagingLeaf.withCString { staging in
            finalLeaf.withCString { final in
                disposal_projection_renameat_exclusive(
                    parentDescriptor,
                    staging,
                    final)
            }
        }
        guard result == 0 else {
            throw DisposalSQLiteFailure.rejected(
                "OUTPUT_ROOT_EXCLUSIVE_PUBLISH", String(cString: strerror(errno)))
        }
        published = true
    }

    private func revalidateParentIdentity() throws {
        var resolvedParent = [CChar](repeating: 0, count: Int(PATH_MAX))
        guard realpath(parentPath, &resolvedParent) != nil else {
            throw DisposalSQLiteFailure.rejected(
                "OUTPUT_PARENT_REALPATH_REVALIDATE",
                String(cString: strerror(errno)))
        }
        let canonicalParent = String(
            decoding: resolvedParent.prefix { $0 != 0 }.map { UInt8(bitPattern: $0) },
            as: UTF8.self)
        try disposalRequire(
            canonicalParent == parentPath,
            "OUTPUT_PARENT_ALIAS_DRIFT")

        var heldParent = stat()
        var namedParent = stat()
        guard fstat(parentDescriptor, &heldParent) == 0,
              lstat(parentPath, &namedParent) == 0
        else {
            throw DisposalSQLiteFailure.rejected(
                "OUTPUT_PARENT_REVALIDATE", String(cString: strerror(errno)))
        }
        try disposalRequire(
            disposalSameIdentity(admittedParentState, heldParent),
            "OUTPUT_PARENT_IDENTITY_DRIFT")
        try disposalRequire(
            disposalSameIdentity(heldParent, namedParent),
            "OUTPUT_PARENT_REBOUND")
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

private func disposalSameIdentity(_ lhs: stat, _ rhs: stat) -> Bool {
    lhs.st_dev == rhs.st_dev &&
        lhs.st_ino == rhs.st_ino &&
        lhs.st_gen == rhs.st_gen &&
        lhs.st_mode == rhs.st_mode &&
        lhs.st_uid == rhs.st_uid &&
        lhs.st_gid == rhs.st_gid
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
