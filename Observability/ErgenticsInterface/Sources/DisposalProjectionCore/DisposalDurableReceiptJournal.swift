import Darwin
import DisposalProjectionPrimitivesC
import Foundation

final class DisposalDurableReceiptJournal {
    static let finalPath =
        "/private/tmp/ergentics-r19-obs11-eaf9b76-chain-receipt-v1"
    static let stagingPath =
        "/private/tmp/.ergentics-r19-obs11-receipt-staging-" +
        "f73a8ace6f22922f9bdf21c1b4cb715cf23fefac53928c636879571a8ef312d4"

    private static let parentPath = "/private/tmp"
    private static let finalLeaf = "ergentics-r19-obs11-eaf9b76-chain-receipt-v1"
    private static let stagingLeaf =
        ".ergentics-r19-obs11-receipt-staging-" +
        "f73a8ace6f22922f9bdf21c1b4cb715cf23fefac53928c636879571a8ef312d4"
    private static let ordinaryLeaves = [
        "00-start.json",
        "01-f01-intent.json", "02-f01-result.json",
        "03-f02-intent.json", "04-f02-result.json",
        "05-f03-intent.json", "06-f03-result.json",
        "07-f04-intent.json", "08-f04-result.json",
        "09-f05-intent.json", "10-f05-result.json",
        "11-f06-intent.json", "12-f06-result.json",
        "13-f07-intent.json", "14-f07-result.json",
        "15-f08-intent.json", "16-f08-result.json",
    ]
    private static let terminalLeaf = "99-terminal.json"
    private static let maximumFrameBytes = 1 * 1_024 * 1_024

    private struct HeldLeaf {
        let descriptor: Int32
        let admittedState: stat
        let bytes: Data
        let sha256: String
    }

    private let parentDescriptor: Int32
    private let rootDescriptor: Int32
    private let admittedParentState: stat
    private let admittedRootIdentity: stat
    private var heldLeaves: [String: HeldLeaf] = [:]
    private(set) var durableLeafNames: [String] = []
    private var poisoned = false
    private var published = false

    static func admitFrozenOBS11() throws -> DisposalDurableReceiptJournal {
        try DisposalDurableReceiptJournal()
    }

    private init() throws {
        try disposalRequireProjection(
            Self.parentPath + "/" + Self.finalLeaf == Self.finalPath &&
                Self.parentPath + "/" + Self.stagingLeaf == Self.stagingPath,
            "RECEIPT_FROZEN_PATH_JOIN")
        var resolvedParent = [CChar](repeating: 0, count: Int(PATH_MAX))
        guard realpath(Self.parentPath, &resolvedParent) != nil else {
            throw DisposalProjectionRejection(
                code: "RECEIPT_PARENT_REALPATH",
                detail: String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            disposalReceiptPath(resolvedParent) == Self.parentPath,
            "RECEIPT_PARENT_ALIAS")
        var namedParent = stat()
        guard lstat(Self.parentPath, &namedParent) == 0 else {
            throw DisposalProjectionRejection(
                code: "RECEIPT_PARENT_LSTAT",
                detail: String(cString: strerror(errno)))
        }
        let openedParent = Darwin.open(
            Self.parentPath,
            O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW_ANY)
        guard openedParent >= 0 else {
            throw DisposalProjectionRejection(
                code: "RECEIPT_PARENT_OPEN",
                detail: String(cString: strerror(errno)))
        }
        var openedRoot: Int32 = -1
        var retainDescriptors = false
        defer {
            if !retainDescriptors {
                if openedRoot >= 0 { _ = Darwin.close(openedRoot) }
                _ = Darwin.close(openedParent)
            }
        }
        var parentState = stat()
        guard fstat(openedParent, &parentState) == 0 else {
            throw DisposalProjectionRejection(
                code: "RECEIPT_PARENT_FSTAT",
                detail: String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            disposalReceiptSameIdentity(namedParent, parentState) &&
                (parentState.st_mode & S_IFMT) == S_IFDIR &&
                (parentState.st_mode & 0o7777) == 0o1777 &&
                parentState.st_uid == 0 && parentState.st_gid == 0,
            "RECEIPT_PARENT_POLICY")

        for (leaf, code) in [
            (Self.finalLeaf, "RECEIPT_FINAL_NOT_ABSENT"),
            (Self.stagingLeaf, "RECEIPT_STAGING_NOT_ABSENT"),
        ] {
            var existing = stat()
            errno = 0
            let result = fstatat(openedParent, leaf, &existing, AT_SYMLINK_NOFOLLOW)
            try disposalRequireProjection(result != 0 && errno == ENOENT, code)
        }
        guard mkdirat(openedParent, Self.stagingLeaf, 0o700) == 0 else {
            throw DisposalProjectionRejection(
                code: "RECEIPT_STAGING_MKDIR",
                detail: String(cString: strerror(errno)))
        }
        openedRoot = Self.stagingLeaf.withCString {
            disposal_projection_openat_directory_no_follow(openedParent, $0)
        }
        guard openedRoot >= 0 else {
            throw DisposalProjectionRejection(
                code: "RECEIPT_STAGING_OPEN",
                detail: String(cString: strerror(errno)))
        }
        var rootState = stat()
        var namedRoot = stat()
        guard fstat(openedRoot, &rootState) == 0,
              fstatat(openedParent, Self.stagingLeaf, &namedRoot, AT_SYMLINK_NOFOLLOW) == 0
        else {
            throw DisposalProjectionRejection(
                code: "RECEIPT_STAGING_FSTAT",
                detail: String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            disposalReceiptSameState(rootState, namedRoot) &&
                (rootState.st_mode & S_IFMT) == S_IFDIR &&
                (rootState.st_mode & 0o7777) == 0o700 &&
                rootState.st_uid == geteuid() && rootState.st_nlink == 2,
            "RECEIPT_STAGING_POLICY")
        try disposalRequireProjection(
            try disposalReceiptDirectoryEntries(openedRoot).isEmpty,
            "RECEIPT_STAGING_INITIAL_INVENTORY")
        var heldParentBeforeSync = stat()
        var namedParentBeforeSync = stat()
        guard fstat(openedParent, &heldParentBeforeSync) == 0,
              lstat(Self.parentPath, &namedParentBeforeSync) == 0
        else {
            throw DisposalProjectionRejection(
                code: "RECEIPT_PARENT_PRESYNC_REVALIDATE",
                detail: String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            disposalReceiptSameIdentity(parentState, heldParentBeforeSync) &&
                disposalReceiptSameIdentity(heldParentBeforeSync, namedParentBeforeSync),
            "RECEIPT_PARENT_PRESYNC_REBOUND")
        try disposalReceiptSyncDirectory(openedParent)

        parentDescriptor = openedParent
        rootDescriptor = openedRoot
        admittedParentState = parentState
        admittedRootIdentity = rootState
        try revalidateParentIdentity()
        try revalidateRoot(expectedMode: 0o700, expectedLeaves: [])
        retainDescriptors = true
    }

    deinit {
        for leaf in heldLeaves.values { _ = Darwin.close(leaf.descriptor) }
        _ = Darwin.close(rootDescriptor)
        _ = Darwin.close(parentDescriptor)
    }

    func appendExact(leaf: String, frameWithLF: Data) throws -> String {
        try disposalRequireProjection(!poisoned && !published, "RECEIPT_APPEND_CLOSED")
        do {
            try disposalRequireProjection(
                !frameWithLF.isEmpty &&
                    frameWithLF.count <= Self.maximumFrameBytes &&
                    frameWithLF.last == 0x0a &&
                    !frameWithLF.dropLast().contains(0x0a),
                "RECEIPT_FRAME_SHAPE")
            let expectedOrdinary = durableLeafNames.count < Self.ordinaryLeaves.count
                ? Self.ordinaryLeaves[durableLeafNames.count]
                : nil
            let isOrdinary = expectedOrdinary.map { leaf == $0 } ?? false
            let isTerminal = leaf == Self.terminalLeaf &&
                !durableLeafNames.isEmpty &&
                durableLeafNames.count <= Self.ordinaryLeaves.count
            try disposalRequireProjection(isOrdinary || isTerminal, "RECEIPT_LEAF_ORDER")
            try disposalRequireProjection(
                heldLeaves[leaf] == nil && !durableLeafNames.contains(Self.terminalLeaf),
                "RECEIPT_LEAF_DUPLICATE_OR_AFTER_TERMINAL")
            let previousSHA256 = durableLeafNames.last.flatMap {
                heldLeaves[$0]?.sha256
            }
            let validatedDigest = try DisposalR19OBS11ReceiptCodec.validateExact(
                frameWithLF: frameWithLF,
                chainOrdinal: durableLeafNames.count,
                leafName: leaf,
                previousFrameWithLFSHA256: previousSHA256)

            let descriptor = leaf.withCString {
                disposal_projection_openat_create_exclusive_private(
                    rootDescriptor,
                    $0,
                    0o600)
            }
            guard descriptor >= 0 else {
                throw DisposalProjectionRejection(
                    code: "RECEIPT_LEAF_CREATE",
                    detail: leaf + ":" + String(cString: strerror(errno)))
            }
            var closeOnFailure = true
            defer { if closeOnFailure { _ = Darwin.close(descriptor) } }
            var offset = 0
            while offset < frameWithLF.count {
                let written = frameWithLF.withUnsafeBytes { raw -> Int in
                    guard let base = raw.baseAddress else { return -1 }
                    return Darwin.write(
                        descriptor,
                        base.advanced(by: offset),
                        frameWithLF.count - offset)
                }
                if written > 0 {
                    offset += written
                } else if written < 0 && errno == EINTR {
                    continue
                } else {
                    throw DisposalProjectionRejection(
                        code: "RECEIPT_LEAF_WRITE",
                        detail: leaf + ":" + String(cString: strerror(errno)))
                }
            }
            try revalidatePendingLeaf(
                descriptor: descriptor,
                leaf: leaf,
                expectedMode: 0o600,
                expectedBytes: frameWithLF)
            try disposalReceiptSyncFile(descriptor)
            try revalidatePendingLeaf(
                descriptor: descriptor,
                leaf: leaf,
                expectedMode: 0o600,
                expectedBytes: frameWithLF)
            guard fchmod(descriptor, 0o400) == 0 else {
                throw DisposalProjectionRejection(
                    code: "RECEIPT_LEAF_CHMOD",
                    detail: leaf + ":" + String(cString: strerror(errno)))
            }
            try revalidatePendingLeaf(
                descriptor: descriptor,
                leaf: leaf,
                expectedMode: 0o400,
                expectedBytes: frameWithLF)
            try disposalReceiptSyncFile(descriptor)
            var finalState = stat()
            guard fstat(descriptor, &finalState) == 0 else {
                throw DisposalProjectionRejection(
                    code: "RECEIPT_LEAF_FINAL_FSTAT",
                    detail: leaf + ":" + String(cString: strerror(errno)))
            }
            try revalidatePendingLeaf(
                descriptor: descriptor,
                leaf: leaf,
                expectedMode: 0o400,
                expectedBytes: frameWithLF)
            heldLeaves[leaf] = .init(
                descriptor: descriptor,
                admittedState: finalState,
                bytes: frameWithLF,
                sha256: validatedDigest)
            closeOnFailure = false
            try revalidateParentIdentity()
            try revalidateRoot(
                expectedMode: 0o700,
                expectedLeaves: durableLeafNames + [leaf])
            try disposalReceiptSyncDirectory(rootDescriptor)
            try revalidateRoot(
                expectedMode: 0o700,
                expectedLeaves: durableLeafNames + [leaf])
            try revalidateParentIdentity()
            try disposalReceiptSyncDirectory(parentDescriptor)
            try revalidateParentIdentity()
            try revalidateRoot(
                expectedMode: 0o700,
                expectedLeaves: durableLeafNames + [leaf])
            durableLeafNames.append(leaf)
            return validatedDigest
        } catch {
            poisoned = true
            throw error
        }
    }

    func publish(
        expectedLeaves: [String],
        afterPreparedRevalidation: () throws -> Void
    ) throws {
        try disposalRequireProjection(!poisoned && !published, "RECEIPT_PUBLISH_CLOSED")
        do {
            try disposalRequireProjection(
                expectedLeaves == durableLeafNames &&
                    expectedLeaves.last == Self.terminalLeaf,
                "RECEIPT_PUBLISH_EXPECTED_LEAVES")
            let ordinaryPrefix = Array(expectedLeaves.dropLast())
            try disposalRequireProjection(
                !ordinaryPrefix.isEmpty && ordinaryPrefix.count <= Self.ordinaryLeaves.count &&
                    ordinaryPrefix == Array(Self.ordinaryLeaves.prefix(ordinaryPrefix.count)),
                "RECEIPT_PUBLISH_CONTIGUOUS_PREFIX")
            try revalidateParentIdentity()
            try revalidateRoot(expectedMode: 0o700, expectedLeaves: expectedLeaves)
            guard fchmod(rootDescriptor, 0o500) == 0 else {
                throw DisposalProjectionRejection(
                    code: "RECEIPT_ROOT_CHMOD",
                    detail: String(cString: strerror(errno)))
            }
            try revalidateRoot(expectedMode: 0o500, expectedLeaves: expectedLeaves)
            try revalidateParentIdentity()
            try disposalReceiptSyncDirectory(rootDescriptor)
            try revalidateRoot(expectedMode: 0o500, expectedLeaves: expectedLeaves)
            try revalidateParentIdentity()
            try disposalReceiptSyncDirectory(parentDescriptor)
            try revalidateRoot(expectedMode: 0o500, expectedLeaves: expectedLeaves)
            try revalidateParentIdentity()

            try afterPreparedRevalidation()

            try revalidateRoot(expectedMode: 0o500, expectedLeaves: expectedLeaves)
            try revalidateParentIdentity()
            var namedFinal = stat()
            errno = 0
            let finalStatus = fstatat(
                parentDescriptor,
                Self.finalLeaf,
                &namedFinal,
                AT_SYMLINK_NOFOLLOW)
            try disposalRequireProjection(
                finalStatus != 0 && errno == ENOENT,
                "RECEIPT_FINAL_NOT_ABSENT")
            var heldRoot = stat()
            var namedStaging = stat()
            guard fstat(rootDescriptor, &heldRoot) == 0,
                  fstatat(
                    parentDescriptor,
                    Self.stagingLeaf,
                    &namedStaging,
                    AT_SYMLINK_NOFOLLOW) == 0
            else {
                throw DisposalProjectionRejection(
                    code: "RECEIPT_STAGING_FINAL_REVALIDATE",
                    detail: String(cString: strerror(errno)))
            }
            try disposalRequireProjection(
                disposalReceiptSameState(heldRoot, namedStaging),
                "RECEIPT_STAGING_FINAL_REBOUND")
            try revalidateParentIdentity()
            let result = Self.stagingLeaf.withCString { staging in
                Self.finalLeaf.withCString { final in
                    disposal_projection_renameat_exclusive(
                        parentDescriptor,
                        staging,
                        final)
                }
            }
            guard result == 0 else {
                throw DisposalProjectionRejection(
                    code: "RECEIPT_EXCLUSIVE_PUBLISH",
                    detail: String(cString: strerror(errno)))
            }
            published = true
        } catch {
            poisoned = true
            throw error
        }
    }

    private func revalidatePendingLeaf(
        descriptor: Int32,
        leaf: String,
        expectedMode: mode_t,
        expectedBytes: Data
    ) throws {
        var held = stat()
        var named = stat()
        guard fstat(descriptor, &held) == 0,
              fstatat(rootDescriptor, leaf, &named, AT_SYMLINK_NOFOLLOW) == 0
        else {
            throw DisposalProjectionRejection(
                code: "RECEIPT_LEAF_REVALIDATE",
                detail: leaf + ":" + String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            disposalReceiptSameState(held, named) &&
                (held.st_mode & S_IFMT) == S_IFREG &&
                (held.st_mode & 0o7777) == expectedMode &&
                held.st_uid == geteuid() && held.st_nlink == 1 &&
                held.st_size == off_t(expectedBytes.count),
            "RECEIPT_LEAF_POLICY",
            detail: leaf)
        let fresh = try disposalReceiptPread(
            descriptor: descriptor,
            count: expectedBytes.count,
            leaf: leaf)
        try disposalRequireProjection(
            fresh == expectedBytes,
            "RECEIPT_LEAF_BYTES",
            detail: leaf)
        var after = stat()
        var namedAfter = stat()
        guard fstat(descriptor, &after) == 0,
              fstatat(rootDescriptor, leaf, &namedAfter, AT_SYMLINK_NOFOLLOW) == 0
        else {
            throw DisposalProjectionRejection(
                code: "RECEIPT_LEAF_POSTREAD_REVALIDATE",
                detail: leaf + ":" + String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            disposalReceiptSameState(held, after) &&
                disposalReceiptSameState(after, namedAfter),
            "RECEIPT_LEAF_POSTREAD_DRIFT",
            detail: leaf)
    }

    private func revalidateRoot(
        expectedMode: mode_t,
        expectedLeaves: [String]
    ) throws {
        try disposalRequireProjection(
            try disposalReceiptDirectoryEntries(rootDescriptor).sorted() ==
                expectedLeaves.sorted() && heldLeaves.keys.sorted() == expectedLeaves.sorted(),
            "RECEIPT_ROOT_INVENTORY")
        var heldRoot = stat()
        var namedRoot = stat()
        guard fstat(rootDescriptor, &heldRoot) == 0,
              fstatat(
                parentDescriptor,
                Self.stagingLeaf,
                &namedRoot,
                AT_SYMLINK_NOFOLLOW) == 0
        else {
            throw DisposalProjectionRejection(
                code: "RECEIPT_ROOT_REVALIDATE",
                detail: String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            disposalReceiptSameVnodeIdentity(admittedRootIdentity, heldRoot) &&
                disposalReceiptSameState(heldRoot, namedRoot) &&
                (heldRoot.st_mode & S_IFMT) == S_IFDIR &&
                (heldRoot.st_mode & 0o7777) == expectedMode &&
                heldRoot.st_uid == geteuid() &&
                heldRoot.st_nlink == nlink_t(2 + expectedLeaves.count),
            "RECEIPT_ROOT_DRIFT")
        for leaf in expectedLeaves {
            guard let expected = heldLeaves[leaf] else {
                throw DisposalProjectionRejection(
                    code: "RECEIPT_HELD_LEAF_ABSENT",
                    detail: leaf)
            }
            var held = stat()
            var named = stat()
            guard fstat(expected.descriptor, &held) == 0,
                  fstatat(rootDescriptor, leaf, &named, AT_SYMLINK_NOFOLLOW) == 0
            else {
                throw DisposalProjectionRejection(
                    code: "RECEIPT_HELD_LEAF_REVALIDATE",
                    detail: leaf + ":" + String(cString: strerror(errno)))
            }
            try disposalRequireProjection(
                disposalReceiptSameState(expected.admittedState, held) &&
                    disposalReceiptSameState(held, named) &&
                    (held.st_mode & 0o7777) == 0o400 &&
                    held.st_uid == geteuid() && held.st_nlink == 1,
                "RECEIPT_HELD_LEAF_DRIFT",
                detail: leaf)
            let fresh = try disposalReceiptPread(
                descriptor: expected.descriptor,
                count: expected.bytes.count,
                leaf: leaf)
            var after = stat()
            var namedAfter = stat()
            guard fstat(expected.descriptor, &after) == 0,
                  fstatat(rootDescriptor, leaf, &namedAfter, AT_SYMLINK_NOFOLLOW) == 0
            else {
                throw DisposalProjectionRejection(
                    code: "RECEIPT_HELD_LEAF_POSTREAD_REVALIDATE",
                    detail: leaf + ":" + String(cString: strerror(errno)))
            }
            try disposalRequireProjection(
                disposalReceiptSameState(held, after) &&
                    disposalReceiptSameState(after, namedAfter) &&
                    fresh == expected.bytes && disposalSHA256(fresh) == expected.sha256,
                "RECEIPT_HELD_LEAF_POSTREAD_DRIFT",
                detail: leaf)
        }
        try disposalRequireProjection(
            try disposalReceiptDirectoryEntries(rootDescriptor).sorted() ==
                expectedLeaves.sorted(),
            "RECEIPT_ROOT_POSTREAD_INVENTORY")
    }

    private func revalidateParentIdentity() throws {
        var resolvedParent = [CChar](repeating: 0, count: Int(PATH_MAX))
        guard realpath(Self.parentPath, &resolvedParent) != nil else {
            throw DisposalProjectionRejection(
                code: "RECEIPT_PARENT_REALPATH_REVALIDATE",
                detail: String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            disposalReceiptPath(resolvedParent) == Self.parentPath,
            "RECEIPT_PARENT_ALIAS_DRIFT")
        var heldParent = stat()
        var namedParent = stat()
        guard fstat(parentDescriptor, &heldParent) == 0,
              lstat(Self.parentPath, &namedParent) == 0
        else {
            throw DisposalProjectionRejection(
                code: "RECEIPT_PARENT_REVALIDATE",
                detail: String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            disposalReceiptSameIdentity(admittedParentState, heldParent),
            "RECEIPT_PARENT_IDENTITY_DRIFT")
        try disposalRequireProjection(
            disposalReceiptSameIdentity(heldParent, namedParent),
            "RECEIPT_PARENT_REBOUND")
    }
}

private func disposalReceiptPath(_ buffer: [CChar]) -> String {
    String(
        decoding: buffer.prefix { $0 != 0 }.map { UInt8(bitPattern: $0) },
        as: UTF8.self)
}

private func disposalReceiptPread(
    descriptor: Int32,
    count: Int,
    leaf: String
) throws -> Data {
    var data = Data(count: count)
    var offset = 0
    while offset < count {
        let result = data.withUnsafeMutableBytes { raw -> Int in
            guard let base = raw.baseAddress else { return -1 }
            return pread(
                descriptor,
                base.advanced(by: offset),
                count - offset,
                off_t(offset))
        }
        if result > 0 {
            offset += result
        } else if result < 0 && errno == EINTR {
            continue
        } else {
            throw DisposalProjectionRejection(
                code: "RECEIPT_PREAD",
                detail: leaf + ":" + String(cString: strerror(errno)))
        }
    }
    return data
}

private func disposalReceiptDirectoryEntries(_ descriptor: Int32) throws -> [String] {
    let copied = dup(descriptor)
    guard copied >= 0 else {
        throw DisposalProjectionRejection(
            code: "RECEIPT_ROOT_DUP",
            detail: String(cString: strerror(errno)))
    }
    guard let directory = fdopendir(copied) else {
        _ = Darwin.close(copied)
        throw DisposalProjectionRejection(
            code: "RECEIPT_ROOT_FDOPENDIR",
            detail: String(cString: strerror(errno)))
    }
    defer { closedir(directory) }
    rewinddir(directory)
    var entries: [String] = []
    errno = 0
    while let entry = readdir(directory) {
        let name = withUnsafePointer(to: &entry.pointee.d_name) {
            $0.withMemoryRebound(to: CChar.self, capacity: Int(NAME_MAX) + 1) {
                String(cString: $0)
            }
        }
        if name != "." && name != ".." { entries.append(name) }
        errno = 0
    }
    guard errno == 0 else {
        throw DisposalProjectionRejection(
            code: "RECEIPT_ROOT_READDIR",
            detail: String(cString: strerror(errno)))
    }
    return entries
}

private func disposalReceiptSyncFile(_ descriptor: Int32) throws {
    guard fsync(descriptor) == 0 else {
        throw DisposalProjectionRejection(
            code: "RECEIPT_FILE_FSYNC",
            detail: String(cString: strerror(errno)))
    }
    guard fcntl(descriptor, F_FULLFSYNC) == 0 else {
        throw DisposalProjectionRejection(
            code: "RECEIPT_FILE_FULLFSYNC",
            detail: String(cString: strerror(errno)))
    }
}

private func disposalReceiptSyncDirectory(_ descriptor: Int32) throws {
    guard fsync(descriptor) == 0 else {
        throw DisposalProjectionRejection(
            code: "RECEIPT_DIRECTORY_FSYNC",
            detail: String(cString: strerror(errno)))
    }
}

private func disposalReceiptSameIdentity(_ lhs: stat, _ rhs: stat) -> Bool {
    disposalReceiptSameVnodeIdentity(lhs, rhs) &&
        lhs.st_mode == rhs.st_mode && lhs.st_uid == rhs.st_uid && lhs.st_gid == rhs.st_gid
}

private func disposalReceiptSameVnodeIdentity(_ lhs: stat, _ rhs: stat) -> Bool {
    lhs.st_dev == rhs.st_dev && lhs.st_ino == rhs.st_ino && lhs.st_gen == rhs.st_gen
}

private func disposalReceiptSameState(_ lhs: stat, _ rhs: stat) -> Bool {
    disposalReceiptSameIdentity(lhs, rhs) && lhs.st_nlink == rhs.st_nlink &&
        lhs.st_size == rhs.st_size &&
        lhs.st_mtimespec.tv_sec == rhs.st_mtimespec.tv_sec &&
        lhs.st_mtimespec.tv_nsec == rhs.st_mtimespec.tv_nsec &&
        lhs.st_ctimespec.tv_sec == rhs.st_ctimespec.tv_sec &&
        lhs.st_ctimespec.tv_nsec == rhs.st_ctimespec.tv_nsec
}
