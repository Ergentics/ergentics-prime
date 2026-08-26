import Darwin
import DisposalProjectionPrimitivesC
import Foundation

final class DisposalHeldR19Source {
    static let journalPath =
        "/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/" +
        "r19-observability-eaf9b76-v1/r19-observations.v1.jsonl"
    static let sqlitePath =
        "/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/" +
        "r19-observability-eaf9b76-v1/r19-observations.v1.sqlite3"

    private static let parentPath =
        "/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45"
    private static let rootLeaf = "r19-observability-eaf9b76-v1"
    private static let rootPath = parentPath + "/" + rootLeaf
    private static let journalLeaf = "r19-observations.v1.jsonl"
    private static let sqliteLeaf = "r19-observations.v1.sqlite3"

    private struct FrozenState: Sendable {
        let device: dev_t
        let inode: ino_t
        let generation: UInt32
        let mode: mode_t
        let uid: uid_t
        let gid: gid_t
        let linkCount: nlink_t
        let bytes: off_t

        func matches(_ value: stat) -> Bool {
            value.st_dev == device && value.st_ino == inode &&
                value.st_gen == generation && value.st_mode == mode &&
                value.st_uid == uid && value.st_gid == gid &&
                value.st_nlink == linkCount && value.st_size == bytes
        }
    }

    private struct HeldLeaf {
        let descriptor: Int32
        let admittedState: stat
        let bytes: Data
        let sha256: String
    }

    private static let frozenParent = FrozenState(
        device: 16_777_231,
        inode: 13_612_594,
        generation: 0,
        mode: mode_t(S_IFDIR | 0o755),
        uid: 501,
        gid: 20,
        linkCount: 37,
        bytes: 1_184)
    private static let frozenRoot = FrozenState(
        device: 16_777_231,
        inode: 17_509_052,
        generation: 0,
        mode: mode_t(S_IFDIR | 0o500),
        uid: 501,
        gid: 20,
        linkCount: 4,
        bytes: 128)
    private static let frozenJournal = FrozenState(
        device: 16_777_231,
        inode: 17_509_053,
        generation: 0,
        mode: mode_t(S_IFREG | 0o400),
        uid: 501,
        gid: 20,
        linkCount: 1,
        bytes: 17_557)
    private static let frozenSQLite = FrozenState(
        device: 16_777_231,
        inode: 17_509_057,
        generation: 0,
        mode: mode_t(S_IFREG | 0o400),
        uid: 501,
        gid: 20,
        linkCount: 1,
        bytes: 1_802_240)
    private static let journalSHA256 =
        "6f90d4709ad136c356d75ee28ba49a71854215ed386721e734a42eac86f56743"
    private static let sqliteSHA256 =
        "cc3cc4489b4dee8218173721051ebc0d9be12a26a8ff1f8e3fe4e7fa6f5b4032"

    let journal: Data
    let sqlite: Data

    private let parentDescriptor: Int32
    private let rootDescriptor: Int32
    private let admittedParentState: stat
    private let admittedRootState: stat
    private let heldJournal: HeldLeaf
    private let heldSQLite: HeldLeaf

    static func admitFrozenOBS11() throws -> DisposalHeldR19Source {
        try DisposalHeldR19Source()
    }

    private init() throws {
        try disposalRequireProjection(
            Self.rootPath + "/" + Self.journalLeaf == Self.journalPath &&
                Self.rootPath + "/" + Self.sqliteLeaf == Self.sqlitePath,
            "R19_SOURCE_FROZEN_PATH_JOIN")
        var resolvedParent = [CChar](repeating: 0, count: Int(PATH_MAX))
        guard realpath(Self.parentPath, &resolvedParent) != nil else {
            throw DisposalProjectionRejection(
                code: "R19_SOURCE_PARENT_REALPATH",
                detail: String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            disposalR19SourcePath(resolvedParent) == Self.parentPath,
            "R19_SOURCE_PARENT_ALIAS")

        var namedParent = stat()
        guard lstat(Self.parentPath, &namedParent) == 0 else {
            throw DisposalProjectionRejection(
                code: "R19_SOURCE_PARENT_LSTAT",
                detail: String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            Self.frozenParent.matches(namedParent),
            "R19_SOURCE_PARENT_FROZEN_STATE")
        let openedParent = Darwin.open(
            Self.parentPath,
            O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW_ANY)
        guard openedParent >= 0 else {
            throw DisposalProjectionRejection(
                code: "R19_SOURCE_PARENT_OPEN",
                detail: String(cString: strerror(errno)))
        }
        var openedRoot: Int32 = -1
        var openedLeaves: [Int32] = []
        var retainDescriptors = false
        defer {
            if !retainDescriptors {
                for descriptor in openedLeaves { _ = Darwin.close(descriptor) }
                if openedRoot >= 0 { _ = Darwin.close(openedRoot) }
                _ = Darwin.close(openedParent)
            }
        }

        var parentState = stat()
        guard fstat(openedParent, &parentState) == 0 else {
            throw DisposalProjectionRejection(
                code: "R19_SOURCE_PARENT_FSTAT",
                detail: String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            Self.frozenParent.matches(parentState) &&
                disposalR19SourceSameState(namedParent, parentState),
            "R19_SOURCE_PARENT_NAMED_HELD_JOIN")

        var namedRoot = stat()
        guard fstatat(
            openedParent,
            Self.rootLeaf,
            &namedRoot,
            AT_SYMLINK_NOFOLLOW) == 0
        else {
            throw DisposalProjectionRejection(
                code: "R19_SOURCE_ROOT_LSTAT",
                detail: String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            Self.frozenRoot.matches(namedRoot),
            "R19_SOURCE_ROOT_FROZEN_STATE")
        openedRoot = Self.rootLeaf.withCString {
            disposal_projection_openat_directory_no_follow(openedParent, $0)
        }
        guard openedRoot >= 0 else {
            throw DisposalProjectionRejection(
                code: "R19_SOURCE_ROOT_OPEN",
                detail: String(cString: strerror(errno)))
        }
        var rootState = stat()
        guard fstat(openedRoot, &rootState) == 0 else {
            throw DisposalProjectionRejection(
                code: "R19_SOURCE_ROOT_FSTAT",
                detail: String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            Self.frozenRoot.matches(rootState) &&
                disposalR19SourceSameState(namedRoot, rootState),
            "R19_SOURCE_ROOT_NAMED_HELD_JOIN")
        try disposalRequireProjection(
            try disposalR19SourceDirectoryEntries(openedRoot).sorted() ==
                [Self.journalLeaf, Self.sqliteLeaf],
            "R19_SOURCE_ROOT_INVENTORY")

        let admittedJournal = try Self.openLeaf(
            rootDescriptor: openedRoot,
            leaf: Self.journalLeaf,
            frozen: Self.frozenJournal,
            expectedSHA256: Self.journalSHA256)
        openedLeaves.append(admittedJournal.descriptor)
        let admittedSQLite = try Self.openLeaf(
            rootDescriptor: openedRoot,
            leaf: Self.sqliteLeaf,
            frozen: Self.frozenSQLite,
            expectedSHA256: Self.sqliteSHA256)
        openedLeaves.append(admittedSQLite.descriptor)

        parentDescriptor = openedParent
        rootDescriptor = openedRoot
        admittedParentState = parentState
        admittedRootState = rootState
        heldJournal = admittedJournal
        heldSQLite = admittedSQLite
        journal = admittedJournal.bytes
        sqlite = admittedSQLite.bytes
        try revalidate()
        retainDescriptors = true
    }

    deinit {
        _ = Darwin.close(heldJournal.descriptor)
        _ = Darwin.close(heldSQLite.descriptor)
        _ = Darwin.close(rootDescriptor)
        _ = Darwin.close(parentDescriptor)
    }

    func revalidate() throws {
        try revalidateParentAndRoot()
        try disposalRequireProjection(
            try disposalR19SourceDirectoryEntries(rootDescriptor).sorted() ==
                [Self.journalLeaf, Self.sqliteLeaf],
            "R19_SOURCE_ROOT_INVENTORY_DRIFT")
        try revalidateLeaf(
            heldJournal,
            leaf: Self.journalLeaf,
            frozen: Self.frozenJournal,
            expectedSHA256: Self.journalSHA256)
        try revalidateLeaf(
            heldSQLite,
            leaf: Self.sqliteLeaf,
            frozen: Self.frozenSQLite,
            expectedSHA256: Self.sqliteSHA256)
        try disposalRequireProjection(
            try disposalR19SourceDirectoryEntries(rootDescriptor).sorted() ==
                [Self.journalLeaf, Self.sqliteLeaf],
            "R19_SOURCE_ROOT_POSTREAD_INVENTORY_DRIFT")
        try revalidateParentAndRoot()
    }

    private func revalidateParentAndRoot() throws {
        var resolvedParent = [CChar](repeating: 0, count: Int(PATH_MAX))
        guard realpath(Self.parentPath, &resolvedParent) != nil else {
            throw DisposalProjectionRejection(
                code: "R19_SOURCE_PARENT_REALPATH_REVALIDATE",
                detail: String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            disposalR19SourcePath(resolvedParent) == Self.parentPath,
            "R19_SOURCE_PARENT_ALIAS_DRIFT")

        var heldParent = stat()
        var namedParent = stat()
        guard fstat(parentDescriptor, &heldParent) == 0,
              lstat(Self.parentPath, &namedParent) == 0
        else {
            throw DisposalProjectionRejection(
                code: "R19_SOURCE_PARENT_REVALIDATE",
                detail: String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            Self.frozenParent.matches(heldParent) &&
                disposalR19SourceSameState(admittedParentState, heldParent),
            "R19_SOURCE_PARENT_DRIFT")
        try disposalRequireProjection(
            disposalR19SourceSameState(heldParent, namedParent),
            "R19_SOURCE_PARENT_REBOUND")

        var heldRoot = stat()
        var namedRoot = stat()
        guard fstat(rootDescriptor, &heldRoot) == 0,
              fstatat(
                parentDescriptor,
                Self.rootLeaf,
                &namedRoot,
                AT_SYMLINK_NOFOLLOW) == 0
        else {
            throw DisposalProjectionRejection(
                code: "R19_SOURCE_ROOT_REVALIDATE",
                detail: String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            Self.frozenRoot.matches(heldRoot) &&
                disposalR19SourceSameState(admittedRootState, heldRoot),
            "R19_SOURCE_ROOT_DRIFT")
        try disposalRequireProjection(
            disposalR19SourceSameState(heldRoot, namedRoot),
            "R19_SOURCE_ROOT_REBOUND")
    }

    private static func openLeaf(
        rootDescriptor: Int32,
        leaf: String,
        frozen: FrozenState,
        expectedSHA256: String
    ) throws -> HeldLeaf {
        let descriptor = leaf.withCString {
            disposal_projection_openat_readonly_no_follow(rootDescriptor, $0)
        }
        guard descriptor >= 0 else {
            throw DisposalProjectionRejection(
                code: "R19_SOURCE_LEAF_OPEN",
                detail: leaf + ":" + String(cString: strerror(errno)))
        }
        var closeOnFailure = true
        defer { if closeOnFailure { _ = Darwin.close(descriptor) } }
        var before = stat()
        guard fstat(descriptor, &before) == 0 else {
            throw DisposalProjectionRejection(
                code: "R19_SOURCE_LEAF_FSTAT",
                detail: leaf + ":" + String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            frozen.matches(before),
            "R19_SOURCE_LEAF_FROZEN_STATE",
            detail: leaf)
        let bytes = try disposalR19SourcePread(
            descriptor: descriptor,
            count: Int(frozen.bytes),
            leaf: leaf)
        var after = stat()
        var named = stat()
        guard fstat(descriptor, &after) == 0,
              fstatat(rootDescriptor, leaf, &named, AT_SYMLINK_NOFOLLOW) == 0
        else {
            throw DisposalProjectionRejection(
                code: "R19_SOURCE_LEAF_REVALIDATE",
                detail: leaf + ":" + String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            disposalR19SourceSameState(before, after) &&
                disposalR19SourceSameState(after, named),
            "R19_SOURCE_LEAF_NAMED_HELD_JOIN",
            detail: leaf)
        let digest = disposalSHA256(bytes)
        try disposalRequireProjection(
            digest == expectedSHA256,
            "R19_SOURCE_LEAF_SHA256",
            detail: leaf)
        closeOnFailure = false
        return .init(
            descriptor: descriptor,
            admittedState: after,
            bytes: bytes,
            sha256: digest)
    }

    private func revalidateLeaf(
        _ leafState: HeldLeaf,
        leaf: String,
        frozen: FrozenState,
        expectedSHA256: String
    ) throws {
        var before = stat()
        var namedBefore = stat()
        guard fstat(leafState.descriptor, &before) == 0,
              fstatat(rootDescriptor, leaf, &namedBefore, AT_SYMLINK_NOFOLLOW) == 0
        else {
            throw DisposalProjectionRejection(
                code: "R19_SOURCE_LEAF_REVALIDATE",
                detail: leaf + ":" + String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            frozen.matches(before) &&
                disposalR19SourceSameState(leafState.admittedState, before) &&
                disposalR19SourceSameState(before, namedBefore),
            "R19_SOURCE_LEAF_DRIFT",
            detail: leaf)
        let fresh = try disposalR19SourcePread(
            descriptor: leafState.descriptor,
            count: Int(frozen.bytes),
            leaf: leaf)
        var after = stat()
        var namedAfter = stat()
        guard fstat(leafState.descriptor, &after) == 0,
              fstatat(rootDescriptor, leaf, &namedAfter, AT_SYMLINK_NOFOLLOW) == 0
        else {
            throw DisposalProjectionRejection(
                code: "R19_SOURCE_LEAF_POSTREAD_REVALIDATE",
                detail: leaf + ":" + String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            disposalR19SourceSameState(before, after) &&
                disposalR19SourceSameState(after, namedAfter) && fresh == leafState.bytes &&
                disposalSHA256(fresh) == expectedSHA256 && expectedSHA256 == leafState.sha256,
            "R19_SOURCE_LEAF_POSTREAD_DRIFT",
            detail: leaf)
    }
}

private func disposalR19SourcePath(_ buffer: [CChar]) -> String {
    String(
        decoding: buffer.prefix { $0 != 0 }.map { UInt8(bitPattern: $0) },
        as: UTF8.self)
}

private func disposalR19SourcePread(
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
                code: "R19_SOURCE_PREAD",
                detail: leaf + ":" + String(cString: strerror(errno)))
        }
    }
    return data
}

private func disposalR19SourceDirectoryEntries(_ descriptor: Int32) throws -> [String] {
    let copied = dup(descriptor)
    guard copied >= 0 else {
        throw DisposalProjectionRejection(
            code: "R19_SOURCE_ROOT_DUP",
            detail: String(cString: strerror(errno)))
    }
    guard let directory = fdopendir(copied) else {
        _ = Darwin.close(copied)
        throw DisposalProjectionRejection(
            code: "R19_SOURCE_ROOT_FDOPENDIR",
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
            code: "R19_SOURCE_ROOT_READDIR",
            detail: String(cString: strerror(errno)))
    }
    return entries
}

private func disposalR19SourceSameState(_ lhs: stat, _ rhs: stat) -> Bool {
    lhs.st_dev == rhs.st_dev && lhs.st_ino == rhs.st_ino &&
        lhs.st_mode == rhs.st_mode && lhs.st_nlink == rhs.st_nlink &&
        lhs.st_uid == rhs.st_uid && lhs.st_gid == rhs.st_gid &&
        lhs.st_size == rhs.st_size && lhs.st_gen == rhs.st_gen &&
        lhs.st_mtimespec.tv_sec == rhs.st_mtimespec.tv_sec &&
        lhs.st_mtimespec.tv_nsec == rhs.st_mtimespec.tv_nsec &&
        lhs.st_ctimespec.tv_sec == rhs.st_ctimespec.tv_sec &&
        lhs.st_ctimespec.tv_nsec == rhs.st_ctimespec.tv_nsec
}
