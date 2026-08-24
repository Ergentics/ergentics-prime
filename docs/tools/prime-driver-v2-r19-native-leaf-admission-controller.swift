// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CryptoKit
import Darwin
import Dispatch
import Foundation

@_silgen_name("_NSGetEnviron")
private func primeR19AdmissionControllerNSGetEnviron()
    -> UnsafeMutablePointer<
        UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?
    >

private enum PrimeR19AdmissionControllerFailure: Error {
    case rejected
}

private struct PrimeR19AdmissionIdentity: Equatable {
    let device: dev_t
    let inode: ino_t
}

private struct PrimeR19AdmissionStableMetadata: Equatable {
    let identity: PrimeR19AdmissionIdentity
    let mode: mode_t
    let links: nlink_t
    let owner: uid_t
    let group: gid_t
    let size: off_t
    let flags: UInt32
    let generation: UInt32
    let modifiedSeconds: Int64
    let modifiedNanoseconds: Int64
    let changedSeconds: Int64
    let changedNanoseconds: Int64
    let createdSeconds: Int64
    let createdNanoseconds: Int64

    init(_ value: stat) {
        identity = PrimeR19AdmissionIdentity(
            device: value.st_dev,
            inode: value.st_ino
        )
        mode = value.st_mode
        links = value.st_nlink
        owner = value.st_uid
        group = value.st_gid
        size = value.st_size
        flags = value.st_flags
        generation = value.st_gen
        modifiedSeconds = Int64(value.st_mtimespec.tv_sec)
        modifiedNanoseconds = Int64(value.st_mtimespec.tv_nsec)
        changedSeconds = Int64(value.st_ctimespec.tv_sec)
        changedNanoseconds = Int64(value.st_ctimespec.tv_nsec)
        createdSeconds = Int64(value.st_birthtimespec.tv_sec)
        createdNanoseconds = Int64(value.st_birthtimespec.tv_nsec)
    }
}

private struct PrimeR19UniqueProcessIdentity: Equatable {
    let uuid: [UInt8]
    let uniqueID: UInt64
    let parentUniqueID: UInt64
    let idVersion: UInt32
    let originalParentIDVersion: UInt32
}

private struct PrimeR19ShortProcessIdentity: Equatable {
    let pid: UInt32
    let parentPID: UInt32
    let processGroup: UInt32
    let status: UInt32
    let command: [UInt8]
    let userID: UInt32
    let groupID: UInt32
    let realUserID: UInt32
    let realGroupID: UInt32
    let savedUserID: UInt32
    let savedGroupID: UInt32

    func sameIdentity(as other: Self) -> Bool {
        pid == other.pid
            && parentPID == other.parentPID
            && processGroup == other.processGroup
            && command == other.command
            && userID == other.userID
            && groupID == other.groupID
            && realUserID == other.realUserID
            && realGroupID == other.realGroupID
            && savedUserID == other.savedUserID
            && savedGroupID == other.savedGroupID
    }
}

private struct PrimeR19JoinedProcess: Equatable {
    let unique: PrimeR19UniqueProcessIdentity
    let short: PrimeR19ShortProcessIdentity
    let session: pid_t
    let processGroup: pid_t

    func sameIdentity(as other: Self) -> Bool {
        unique == other.unique
            && short.sameIdentity(as: other.short)
            && session == other.session
            && processGroup == other.processGroup
    }
}

private struct PrimeR19Deadline {
    static let durationNanoseconds: UInt64 = 30_000_000_000
    let absoluteNanoseconds: UInt64

    init() throws {
        let now = DispatchTime.now().uptimeNanoseconds
        let sum = now.addingReportingOverflow(Self.durationNanoseconds)
        guard !sum.overflow else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        absoluteNanoseconds = sum.partialValue
    }

    var expired: Bool {
        DispatchTime.now().uptimeNanoseconds >= absoluteNanoseconds
    }

    func remainingTimespec() -> timespec {
        let now = DispatchTime.now().uptimeNanoseconds
        guard now < absoluteNanoseconds else {
            return timespec(tv_sec: 0, tv_nsec: 0)
        }
        let remaining = absoluteNanoseconds - now
        return timespec(
            tv_sec: Int(remaining / 1_000_000_000),
            tv_nsec: Int(remaining % 1_000_000_000)
        )
    }
}

private final class PrimeR19Pipe {
    private(set) var readDescriptor: Int32
    private(set) var writeDescriptor: Int32

    init() throws {
        var descriptors: [Int32] = [-1, -1]
        let result = descriptors.withUnsafeMutableBufferPointer {
            Darwin.pipe($0.baseAddress)
        }
        guard result == 0,
              descriptors[0] >= 3,
              descriptors[1] >= 3,
              descriptors[0] != descriptors[1]
        else {
            if descriptors[0] >= 0 { _ = Darwin.close(descriptors[0]) }
            if descriptors[1] >= 0 { _ = Darwin.close(descriptors[1]) }
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        readDescriptor = descriptors[0]
        writeDescriptor = descriptors[1]
        do {
            try Self.requireCloseOnExec(readDescriptor)
            try Self.requireCloseOnExec(writeDescriptor)
            let readFlags = fcntl(readDescriptor, F_GETFL)
            let writeFlags = fcntl(writeDescriptor, F_GETFL)
            guard readFlags == O_RDONLY,
                  writeFlags == O_WRONLY,
                  fcntl(readDescriptor, F_SETFL, readFlags | O_NONBLOCK) == 0,
                  fcntl(readDescriptor, F_GETFL) == (O_RDONLY | O_NONBLOCK),
                  fcntl(writeDescriptor, F_GETFL) == O_WRONLY
            else {
                throw PrimeR19AdmissionControllerFailure.rejected
            }
        } catch {
            closeAll()
            throw error
        }
    }

    func closeWriteEnd() {
        if writeDescriptor >= 0 {
            _ = Darwin.close(writeDescriptor)
            writeDescriptor = -1
        }
    }

    func closeAll() {
        if readDescriptor >= 0 {
            _ = Darwin.close(readDescriptor)
            readDescriptor = -1
        }
        closeWriteEnd()
    }

    deinit { closeAll() }

    private static func requireCloseOnExec(_ descriptor: Int32) throws {
        let existing = fcntl(descriptor, F_GETFD)
        guard existing >= 0,
              fcntl(descriptor, F_SETFD, existing | FD_CLOEXEC) == 0,
              fcntl(descriptor, F_GETFD) & FD_CLOEXEC != 0
        else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
    }
}

private struct PrimeR19StreamCapture {
    static let cap = 4_096
    static let drainReadQuantum = 16
    static let drainByteQuantum = 65_536
    var bytes: [UInt8] = []
    var overflow = false
    var eof = false

    mutating func drain(_ descriptor: Int32) throws {
        guard !eof else { return }
        var buffer = [UInt8](repeating: 0, count: 8_192)
        var reads = 0
        var drainedBytes = 0
        while reads < Self.drainReadQuantum,
              drainedBytes < Self.drainByteQuantum {
            let requested = min(
                buffer.count,
                Self.drainByteQuantum - drainedBytes
            )
            errno = 0
            let count = buffer.withUnsafeMutableBytes {
                Darwin.read(descriptor, $0.baseAddress, requested)
            }
            reads += 1
            if count > 0 {
                drainedBytes += count
                let available = max(0, Self.cap - bytes.count)
                let retained = min(available, count)
                if retained > 0 {
                    bytes.append(contentsOf: buffer[0..<retained])
                }
                if retained != count { overflow = true }
                continue
            }
            if count == 0 {
                eof = true
                return
            }
            if errno == EINTR { continue }
            if errno == EAGAIN || errno == EWOULDBLOCK { return }
            throw PrimeR19AdmissionControllerFailure.rejected
        }
    }
}

private enum PrimeR19ReapConservationState: Equatable {
    case unreaped
    case reapedUnconserved
    case conserved
}

private final class PrimeR19HeldAuthorities {
    static let privateTmpPath = "/private/tmp"
    static let privateTmpDevice = dev_t(16_777_231)
    static let privateTmpInode = ino_t(774_813)
    static let rootPath = "/"
    static let rootDevice = dev_t(16_777_231)
    static let rootInode = ino_t(2)
    static let rootFlags: UInt32 = 1_048_576
    static let buildRootLeaf =
        "prime-driver-v2-r19-native-leaf-admission-repair1-build-a-c414eac5"
    static let buildRootInode = ino_t(17_458_990)
    static let imageLeaf = "PrimeDriverV2R19NativeLeafAdmission"
    static let imagePath =
        "/private/tmp/prime-driver-v2-r19-native-leaf-admission-repair1-build-a-c414eac5/PrimeDriverV2R19NativeLeafAdmission"
    static let imageDevice = dev_t(16_777_231)
    static let imageInode = ino_t(17_459_126)
    static let imageByteCount = 114_384
    static let imageSHA256 =
        "aee14f52c66378c4fd27b2d0fe70c62ca8f3ddb7837acda9d49ff7b960f9f8a2"
    static let imageUUID: [UInt8] = [
        0xA1, 0x8B, 0xE2, 0xE3, 0x3D, 0xE0, 0x37, 0x95,
        0x96, 0xBE, 0x1E, 0xA9, 0x31, 0xC3, 0xF6, 0x4B,
    ]
    static let codeDirectorySHA256 =
        "3cc3b1ad0ea7e76167c747907cb3f75846d4dbced10f8a9cdf360787e364b87e"
    static let provenanceName = "com.apple.provenance"
    static let provenanceValue: [UInt8] = [
        0x01, 0x02, 0x00, 0x49, 0xB5, 0xCB,
        0x68, 0x4F, 0x79, 0x58, 0x3C,
    ]

    let rootDescriptor: Int32
    let privateTmpDescriptor: Int32
    let buildRootDescriptor: Int32
    let imageDescriptor: Int32
    let nullDescriptor: Int32
    private let buildRootInitial: PrimeR19AdmissionStableMetadata
    private let imageInitial: PrimeR19AdmissionStableMetadata

    static func prepare() throws -> PrimeR19HeldAuthorities {
        let root = Darwin.open(
            rootPath,
            O_RDONLY | O_DIRECTORY | O_NOFOLLOW_ANY | O_CLOEXEC
        )
        guard root >= 3 else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        var owned: [Int32] = [root]
        do {
            let rootMetadata = try requireRoot(root)
            let privateTmp = Darwin.open(
                privateTmpPath,
                O_RDONLY | O_DIRECTORY | O_NOFOLLOW_ANY | O_CLOEXEC
            )
            guard privateTmp >= 3 else {
                throw PrimeR19AdmissionControllerFailure.rejected
            }
            owned.append(privateTmp)
            let privateTmpMetadata = try requirePrivateTmp(privateTmp)
            let buildRoot = buildRootLeaf.withCString {
                Darwin.openat(
                    privateTmp,
                    $0,
                    O_RDONLY | O_DIRECTORY | O_NOFOLLOW_ANY | O_CLOEXEC
                )
            }
            guard buildRoot >= 3 else {
                throw PrimeR19AdmissionControllerFailure.rejected
            }
            owned.append(buildRoot)
            let buildRootMetadata = try requireBuildRoot(
                buildRoot,
                parent: privateTmp,
                parentMetadata: privateTmpMetadata
            )
            try requireBuildRootInventory(buildRoot)
            try requireExactProvenance(buildRoot)
            let image = imageLeaf.withCString {
                Darwin.openat(
                    buildRoot,
                    $0,
                    O_RDONLY | O_NOFOLLOW_ANY | O_CLOEXEC
                )
            }
            guard image >= 3 else {
                throw PrimeR19AdmissionControllerFailure.rejected
            }
            owned.append(image)
            let imageMetadata = try requireImage(
                image,
                parent: buildRoot,
                parentMetadata: buildRootMetadata
            )
            try requireImageBytes(image)
            try requireExactProvenance(image)
            try requireNoExtendedACL(image)
            let null = Darwin.open(
                "/dev/null",
                O_RDONLY | O_NOFOLLOW_ANY | O_CLOEXEC
            )
            guard null >= 3 else {
                throw PrimeR19AdmissionControllerFailure.rejected
            }
            owned.append(null)
            try requireNull(null)
            return PrimeR19HeldAuthorities(
                rootDescriptor: root,
                privateTmpDescriptor: privateTmp,
                buildRootDescriptor: buildRoot,
                imageDescriptor: image,
                nullDescriptor: null,
                buildRootInitial: PrimeR19AdmissionStableMetadata(buildRootMetadata),
                imageInitial: PrimeR19AdmissionStableMetadata(imageMetadata)
            )
        } catch {
            for descriptor in owned.reversed() { _ = Darwin.close(descriptor) }
            throw error
        }
    }

    private init(
        rootDescriptor: Int32,
        privateTmpDescriptor: Int32,
        buildRootDescriptor: Int32,
        imageDescriptor: Int32,
        nullDescriptor: Int32,
        buildRootInitial: PrimeR19AdmissionStableMetadata,
        imageInitial: PrimeR19AdmissionStableMetadata
    ) {
        self.rootDescriptor = rootDescriptor
        self.privateTmpDescriptor = privateTmpDescriptor
        self.buildRootDescriptor = buildRootDescriptor
        self.imageDescriptor = imageDescriptor
        self.nullDescriptor = nullDescriptor
        self.buildRootInitial = buildRootInitial
        self.imageInitial = imageInitial
    }

    deinit {
        _ = Darwin.close(nullDescriptor)
        _ = Darwin.close(imageDescriptor)
        _ = Darwin.close(buildRootDescriptor)
        _ = Darwin.close(privateTmpDescriptor)
        _ = Darwin.close(rootDescriptor)
    }

    func revalidateBeforeResume() throws {
        _ = try Self.requireRoot(rootDescriptor)
        let privateTmp = try Self.requirePrivateTmp(privateTmpDescriptor)
        let buildRoot = try Self.requireBuildRoot(
            buildRootDescriptor,
            parent: privateTmpDescriptor,
            parentMetadata: privateTmp,
            expected: buildRootInitial
        )
        try Self.requireBuildRootInventory(buildRootDescriptor)
        try Self.requireExactProvenance(buildRootDescriptor)
        _ = try Self.requireImage(
            imageDescriptor,
            parent: buildRootDescriptor,
            parentMetadata: buildRoot,
            expected: imageInitial
        )
        try Self.requireImageBytes(imageDescriptor)
        try Self.requireExactProvenance(imageDescriptor)
        try Self.requireNoExtendedACL(imageDescriptor)
        try Self.requireNull(nullDescriptor)
    }

    func revalidateAfterReap() throws {
        try revalidateBeforeResume()
    }

    private static func requireRoot(_ descriptor: Int32) throws -> stat {
        try requireCloseOnExec(descriptor)
        var held = stat()
        var named = stat()
        guard fstat(descriptor, &held) == 0,
              rootPath.withCString({
                  fstatat(AT_FDCWD, $0, &named, AT_SYMLINK_NOFOLLOW)
              }) == 0,
              held.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
              named.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
              held.st_dev == rootDevice,
              held.st_dev == named.st_dev,
              held.st_ino == rootInode,
              held.st_ino == named.st_ino,
              held.st_uid == 0,
              named.st_uid == 0,
              held.st_gid == 0,
              named.st_gid == 0,
              held.st_mode & mode_t(0o7777) == mode_t(0o755),
              named.st_mode & mode_t(0o7777) == mode_t(0o755),
              held.st_flags == rootFlags,
              named.st_flags == rootFlags
        else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        var filesystem = statfs()
        guard fstatfs(descriptor, &filesystem) == 0,
              filesystem.f_flags & UInt32(MNT_LOCAL) != 0,
              filesystem.f_flags & UInt32(MNT_RDONLY) != 0,
              filesystemType(filesystem) == Array("apfs".utf8)
        else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        return held
    }

    private static func requirePrivateTmp(_ descriptor: Int32) throws -> stat {
        try requireCloseOnExec(descriptor)
        var held = stat()
        var named = stat()
        guard fstat(descriptor, &held) == 0,
              privateTmpPath.withCString({
                  fstatat(AT_FDCWD, $0, &named, AT_SYMLINK_NOFOLLOW)
              }) == 0,
              held.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
              named.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
              held.st_dev == privateTmpDevice,
              held.st_dev == named.st_dev,
              held.st_ino == privateTmpInode,
              held.st_ino == named.st_ino,
              held.st_uid == 0,
              named.st_uid == 0,
              held.st_gid == 0,
              named.st_gid == 0,
              held.st_mode & mode_t(0o7777) == mode_t(0o1777),
              named.st_mode & mode_t(0o7777) == mode_t(0o1777),
              held.st_flags == 0,
              named.st_flags == 0
        else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        var filesystem = statfs()
        guard fstatfs(descriptor, &filesystem) == 0,
              filesystem.f_flags & UInt32(MNT_LOCAL) != 0,
              filesystemType(filesystem) == Array("apfs".utf8)
        else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        return held
    }

    private static func requireBuildRoot(
        _ descriptor: Int32,
        parent: Int32,
        parentMetadata: stat,
        expected: PrimeR19AdmissionStableMetadata? = nil
    ) throws -> stat {
        try requireCloseOnExec(descriptor)
        var held = stat()
        var named = stat()
        guard fstat(descriptor, &held) == 0,
              buildRootLeaf.withCString({
                  fstatat(parent, $0, &named, AT_SYMLINK_NOFOLLOW)
              }) == 0,
              held.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
              named.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
              held.st_dev == parentMetadata.st_dev,
              held.st_dev == named.st_dev,
              held.st_ino == buildRootInode,
              held.st_ino == named.st_ino,
              held.st_uid == 501,
              named.st_uid == 501,
              held.st_gid == 0,
              named.st_gid == 0,
              held.st_mode & mode_t(0o7777) == mode_t(0o700),
              named.st_mode & mode_t(0o7777) == mode_t(0o700),
              held.st_nlink == 5,
              named.st_nlink == 5,
              held.st_size == 160,
              named.st_size == 160,
              held.st_flags == 0,
              named.st_flags == 0
        else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        if let expected {
            guard PrimeR19AdmissionStableMetadata(held) == expected,
                  PrimeR19AdmissionStableMetadata(named) == expected
            else {
                throw PrimeR19AdmissionControllerFailure.rejected
            }
        }
        return held
    }

    private static func requireImage(
        _ descriptor: Int32,
        parent: Int32,
        parentMetadata: stat,
        expected: PrimeR19AdmissionStableMetadata? = nil
    ) throws -> stat {
        try requireCloseOnExec(descriptor)
        var held = stat()
        var named = stat()
        guard fstat(descriptor, &held) == 0,
              imageLeaf.withCString({
                  fstatat(parent, $0, &named, AT_SYMLINK_NOFOLLOW)
              }) == 0,
              held.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
              named.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
              held.st_dev == imageDevice,
              held.st_dev == parentMetadata.st_dev,
              held.st_dev == named.st_dev,
              held.st_ino == imageInode,
              held.st_ino == named.st_ino,
              held.st_uid == 501,
              named.st_uid == 501,
              held.st_gid == 0,
              named.st_gid == 0,
              held.st_mode & mode_t(0o7777) == mode_t(0o700),
              named.st_mode & mode_t(0o7777) == mode_t(0o700),
              held.st_nlink == 1,
              named.st_nlink == 1,
              held.st_size == off_t(imageByteCount),
              named.st_size == off_t(imageByteCount),
              held.st_flags == 0,
              named.st_flags == 0
        else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        if let expected {
            guard PrimeR19AdmissionStableMetadata(held) == expected,
                  PrimeR19AdmissionStableMetadata(named) == expected
            else {
                throw PrimeR19AdmissionControllerFailure.rejected
            }
        }
        return held
    }

    private static func requireNull(_ descriptor: Int32) throws {
        try requireCloseOnExec(descriptor)
        var value = stat()
        guard fstat(descriptor, &value) == 0,
              value.st_mode & mode_t(S_IFMT) == mode_t(S_IFCHR),
              UInt32(bitPattern: value.st_dev) == 3_836_289_247,
              value.st_ino == ino_t(336),
              value.st_rdev == dev_t(50_331_650),
              value.st_uid == 0,
              value.st_gid == 0,
              value.st_mode & mode_t(0o7777) == mode_t(0o666),
              fcntl(descriptor, F_GETFL) == O_RDONLY,
              isatty(descriptor) == 0
        else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
    }

    private static func requireBuildRootInventory(_ descriptor: Int32) throws {
        let independent = Darwin.openat(
            descriptor,
            ".",
            O_RDONLY | O_DIRECTORY | O_NOFOLLOW_ANY | O_CLOEXEC
        )
        guard independent >= 3 else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        guard let directory = fdopendir(independent) else {
            _ = Darwin.close(independent)
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        defer { _ = closedir(directory) }
        var observed = Set<Data>()
        while true {
            errno = 0
            guard let pointer = readdir(directory) else {
                guard errno == 0 else {
                    throw PrimeR19AdmissionControllerFailure.rejected
                }
                break
            }
            let entry = pointer.pointee
            let count = Int(entry.d_namlen)
            guard count > 0, count <= Int(MAXNAMLEN) else {
                throw PrimeR19AdmissionControllerFailure.rejected
            }
            var field = entry.d_name
            let name = withUnsafeBytes(of: &field) { Data($0.prefix(count)) }
            if name == Data(".".utf8) || name == Data("..".utf8) { continue }
            guard observed.insert(name).inserted else {
                throw PrimeR19AdmissionControllerFailure.rejected
            }
        }
        guard observed == Set([
            Data(imageLeaf.utf8),
            Data("module-cache".utf8),
            Data("tmp".utf8),
        ]) else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
    }

    private static func requireImageBytes(_ descriptor: Int32) throws {
        let bytes = try readExact(descriptor, count: imageByteCount)
        guard sha256Hex(bytes) == imageSHA256 else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        try requireMachO(bytes)
    }

    private static func requireExactProvenance(_ descriptor: Int32) throws {
        let expectedInventory = Array((provenanceName + "\0").utf8)
        for _ in 0..<2 {
            errno = 0
            let required = flistxattr(descriptor, nil, 0, 0)
            guard required == expectedInventory.count else {
                throw PrimeR19AdmissionControllerFailure.rejected
            }
            var inventory = [CChar](repeating: 0, count: required)
            errno = 0
            let returned = inventory.withUnsafeMutableBufferPointer {
                flistxattr(descriptor, $0.baseAddress, $0.count, 0)
            }
            guard returned == required else {
                throw PrimeR19AdmissionControllerFailure.rejected
            }
            let observedInventory = inventory.prefix(returned).map {
                UInt8(bitPattern: $0)
            }
            guard observedInventory == expectedInventory else {
                throw PrimeR19AdmissionControllerFailure.rejected
            }

            errno = 0
            let valueSize = provenanceName.withCString {
                fgetxattr(descriptor, $0, nil, 0, 0, 0)
            }
            guard valueSize == provenanceValue.count else {
                throw PrimeR19AdmissionControllerFailure.rejected
            }
            var value = [UInt8](repeating: 0, count: valueSize)
            errno = 0
            let valueReturned = provenanceName.withCString { name in
                value.withUnsafeMutableBytes {
                    fgetxattr(
                        descriptor,
                        name,
                        $0.baseAddress,
                        $0.count,
                        0,
                        0
                    )
                }
            }
            guard valueReturned == valueSize,
                  value == provenanceValue
            else {
                throw PrimeR19AdmissionControllerFailure.rejected
            }
        }
    }

    private static func requireNoExtendedACL(_ descriptor: Int32) throws {
        errno = 0
        if let accessControlList = acl_get_fd_np(
            descriptor,
            ACL_TYPE_EXTENDED
        ) {
            _ = acl_free(UnsafeMutableRawPointer(accessControlList))
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        guard errno == ENOENT else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
    }

    private static func readExact(_ descriptor: Int32, count: Int) throws -> Data {
        var result = Data(count: count)
        var offset = 0
        try result.withUnsafeMutableBytes { raw in
            guard let base = raw.baseAddress else {
                throw PrimeR19AdmissionControllerFailure.rejected
            }
            while offset < raw.count {
                let readCount = pread(
                    descriptor,
                    base.advanced(by: offset),
                    raw.count - offset,
                    off_t(offset)
                )
                if readCount < 0, errno == EINTR { continue }
                guard readCount > 0 else {
                    throw PrimeR19AdmissionControllerFailure.rejected
                }
                offset += readCount
            }
        }
        var extra: UInt8 = 0
        guard pread(descriptor, &extra, 1, off_t(count)) == 0 else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        return result
    }

    private static func requireMachO(_ bytes: Data) throws {
        guard bytes.count == imageByteCount,
              try little32(bytes, 0) == 0xFEED_FACF,
              try little32(bytes, 4) == 0x0100_000C,
              try little32(bytes, 8) == 0,
              try little32(bytes, 12) == 2,
              try little32(bytes, 16) == 29,
              try little32(bytes, 20) == 3_080,
              try little32(bytes, 24) & UInt32(MH_PIE) != 0
        else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        let commandEnd = 32 + 3_080
        var cursor = 32
        var uuidCount = 0
        var buildCount = 0
        var mainCount = 0
        var signatureCount = 0
        var signatureOffset = 0
        var signatureSize = 0
        for _ in 0..<29 {
            let command = try little32(bytes, cursor)
            let commandSize = Int(try little32(bytes, cursor + 4))
            guard commandSize >= 8,
                  commandSize % 8 == 0,
                  cursor <= commandEnd - commandSize
            else {
                throw PrimeR19AdmissionControllerFailure.rejected
            }
            switch command {
            case 0x1B:
                guard commandSize == 24,
                      Array(bytes[(cursor + 8)..<(cursor + 24)]) == imageUUID
                else { throw PrimeR19AdmissionControllerFailure.rejected }
                uuidCount += 1
            case 0x32:
                guard commandSize == 32,
                      try little32(bytes, cursor + 8) == 1,
                      try little32(bytes, cursor + 12) == 0x000E_0000,
                      try little32(bytes, cursor + 16) == 0x001A_0500,
                      try little32(bytes, cursor + 20) == 1,
                      try little32(bytes, cursor + 24) == 3,
                      try little32(bytes, cursor + 28) == 0x04F3_0000
                else { throw PrimeR19AdmissionControllerFailure.rejected }
                buildCount += 1
            case 0x8000_0028:
                guard commandSize == 24,
                      try little64(bytes, cursor + 8) == 5_008
                else { throw PrimeR19AdmissionControllerFailure.rejected }
                mainCount += 1
            case 0x1D:
                guard commandSize == 16 else {
                    throw PrimeR19AdmissionControllerFailure.rejected
                }
                signatureOffset = Int(try little32(bytes, cursor + 8))
                signatureSize = Int(try little32(bytes, cursor + 12))
                signatureCount += 1
            default:
                break
            }
            cursor += commandSize
        }
        guard cursor == commandEnd,
              uuidCount == 1,
              buildCount == 1,
              mainCount == 1,
              signatureCount == 1,
              signatureOffset == 113_344,
              signatureSize == 1_040,
              signatureOffset + signatureSize == bytes.count
        else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        try requireCodeDirectory(
            bytes,
            signatureOffset: signatureOffset,
            signatureSize: signatureSize
        )
    }

    private static func requireCodeDirectory(
        _ bytes: Data,
        signatureOffset: Int,
        signatureSize: Int
    ) throws {
        guard signatureSize == 1_040,
              try big32(bytes, signatureOffset) == 0xFADE_0CC0,
              try big32(bytes, signatureOffset + 4) == UInt32(signatureSize),
              try big32(bytes, signatureOffset + 8) == 1,
              try big32(bytes, signatureOffset + 12) == 0,
              try big32(bytes, signatureOffset + 16) == 20
        else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        let offset = signatureOffset + 20
        let length = 1_020
        guard try big32(bytes, offset) == 0xFADE_0C02,
              try big32(bytes, offset + 4) == UInt32(length),
              try big32(bytes, offset + 8) == 0x0002_0400,
              try big32(bytes, offset + 24) == 0,
              try big32(bytes, offset + 28) == 28,
              try big32(bytes, offset + 32) == UInt32(signatureOffset),
              bytes[offset + 36] == 32,
              bytes[offset + 37] == 2,
              bytes[offset + 39] == 12,
              offset + length == bytes.count
        else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        let codeDirectory = Data(bytes[offset..<(offset + length)])
        guard sha256Hex(codeDirectory) == codeDirectorySHA256 else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        let hashOffset = Int(try big32(bytes, offset + 16))
        guard hashOffset >= 0, hashOffset <= length - (28 * 32) else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        for slot in 0..<28 {
            let pageStart = slot * 4_096
            let pageEnd = min(pageStart + 4_096, signatureOffset)
            guard pageStart < pageEnd else {
                throw PrimeR19AdmissionControllerFailure.rejected
            }
            let hash = Data(SHA256.hash(data: Data(bytes[pageStart..<pageEnd])))
            let expectedStart = offset + hashOffset + (slot * 32)
            guard bytes[expectedStart..<(expectedStart + 32)] == hash else {
                throw PrimeR19AdmissionControllerFailure.rejected
            }
        }
    }

    private static func little32(_ bytes: Data, _ offset: Int) throws -> UInt32 {
        guard offset >= 0, offset <= bytes.count - 4 else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        return UInt32(bytes[offset])
            | (UInt32(bytes[offset + 1]) << 8)
            | (UInt32(bytes[offset + 2]) << 16)
            | (UInt32(bytes[offset + 3]) << 24)
    }

    private static func little64(_ bytes: Data, _ offset: Int) throws -> UInt64 {
        UInt64(try little32(bytes, offset))
            | (UInt64(try little32(bytes, offset + 4)) << 32)
    }

    private static func big32(_ bytes: Data, _ offset: Int) throws -> UInt32 {
        guard offset >= 0, offset <= bytes.count - 4 else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        return (UInt32(bytes[offset]) << 24)
            | (UInt32(bytes[offset + 1]) << 16)
            | (UInt32(bytes[offset + 2]) << 8)
            | UInt32(bytes[offset + 3])
    }

    private static func sha256Hex(_ bytes: Data) -> String {
        let alphabet = Array("0123456789abcdef".utf8)
        var result = [UInt8]()
        result.reserveCapacity(64)
        for byte in SHA256.hash(data: bytes) {
            result.append(alphabet[Int(byte >> 4)])
            result.append(alphabet[Int(byte & 0x0F)])
        }
        return String(decoding: result, as: UTF8.self)
    }

    private static func requireCloseOnExec(_ descriptor: Int32) throws {
        let flags = fcntl(descriptor, F_GETFD)
        guard descriptor >= 3, flags >= 0, flags & FD_CLOEXEC != 0 else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
    }

    private static func filesystemType(_ filesystem: statfs) -> [UInt8] {
        var field = filesystem.f_fstypename
        return withUnsafeBytes(of: &field) { Array($0.prefix { $0 != 0 }) }
    }
}

private enum PrimeR19ProcessProof {
    static let uniqueFlavor: Int32 = 17
    static let shortFlavor: Int32 = 13
    static let uniqueBytes = 56
    static let shortBytes = 64
    static let attempts = 4

    static func join(_ pid: pid_t) throws -> PrimeR19JoinedProcess? {
        for _ in 0..<attempts {
            guard let unique0 = try readUnique(pid),
                  let short0 = try readShort(pid),
                  let session0 = readDomain(pid, session: true),
                  let group0 = readDomain(pid, session: false),
                  let session1 = readDomain(pid, session: true),
                  let group1 = readDomain(pid, session: false),
                  let short1 = try readShort(pid),
                  let unique1 = try readUnique(pid)
            else { return nil }
            if unique0 == unique1,
               short0.sameIdentity(as: short1),
               session0 == session1,
               group0 == group1,
               group0 == pid_t(short0.processGroup),
               group1 == pid_t(short1.processGroup) {
                return PrimeR19JoinedProcess(
                    unique: unique1,
                    short: short1,
                    session: session1,
                    processGroup: group1
                )
            }
        }
        throw PrimeR19AdmissionControllerFailure.rejected
    }

    static func requirePrivateStoppedChild(
        _ joined: PrimeR19JoinedProcess,
        pid: pid_t
    ) throws {
        let expectedUID = UInt32(geteuid())
        let expectedGID = UInt32(getegid())
        guard joined.short.pid == UInt32(pid),
              joined.short.parentPID == UInt32(getpid()),
              joined.short.processGroup == UInt32(pid),
              joined.short.status == 4,
              joined.processGroup == pid,
              joined.session == pid,
              joined.short.userID == expectedUID,
              joined.short.realUserID == expectedUID,
              joined.short.savedUserID == expectedUID,
              joined.short.groupID == expectedGID,
              joined.short.realGroupID == expectedGID,
              joined.short.savedGroupID == expectedGID
        else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
    }

    static func requireSamePrivateChild(
        _ joined: PrimeR19JoinedProcess,
        baseline: PrimeR19JoinedProcess,
        pid: pid_t
    ) throws {
        guard joined.sameIdentity(as: baseline),
              joined.short.pid == UInt32(pid),
              joined.short.parentPID == UInt32(getpid()),
              joined.processGroup == pid,
              joined.session == pid
        else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
    }

    private static func readUnique(
        _ pid: pid_t
    ) throws -> PrimeR19UniqueProcessIdentity? {
        var bytes = [UInt8](repeating: 0, count: uniqueBytes)
        errno = 0
        let returned = bytes.withUnsafeMutableBytes {
            proc_pidinfo(pid, uniqueFlavor, 0, $0.baseAddress, Int32($0.count))
        }
        let observedErrno = errno
        if returned == 0, observedErrno == ESRCH { return nil }
        guard returned == Int32(uniqueBytes),
              little64(bytes, 16) != 0,
              little64(bytes, 40) == 0,
              little64(bytes, 48) == 0
        else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        return PrimeR19UniqueProcessIdentity(
            uuid: Array(bytes[0..<16]),
            uniqueID: little64(bytes, 16),
            parentUniqueID: little64(bytes, 24),
            idVersion: little32(bytes, 32),
            originalParentIDVersion: little32(bytes, 36)
        )
    }

    private static func readShort(
        _ pid: pid_t
    ) throws -> PrimeR19ShortProcessIdentity? {
        var bytes = [UInt8](repeating: 0, count: shortBytes)
        errno = 0
        let returned = bytes.withUnsafeMutableBytes {
            proc_pidinfo(pid, shortFlavor, 0, $0.baseAddress, Int32($0.count))
        }
        let observedErrno = errno
        if returned == 0, observedErrno == ESRCH { return nil }
        guard returned == Int32(shortBytes),
              little32(bytes, 0) == UInt32(pid),
              little32(bytes, 60) == 0
        else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        return PrimeR19ShortProcessIdentity(
            pid: little32(bytes, 0),
            parentPID: little32(bytes, 4),
            processGroup: little32(bytes, 8),
            status: little32(bytes, 12),
            command: Array(bytes[16..<32]),
            userID: little32(bytes, 36),
            groupID: little32(bytes, 40),
            realUserID: little32(bytes, 44),
            realGroupID: little32(bytes, 48),
            savedUserID: little32(bytes, 52),
            savedGroupID: little32(bytes, 56)
        )
    }

    private static func readDomain(
        _ pid: pid_t,
        session: Bool
    ) -> pid_t? {
        errno = 0
        let result = session ? getsid(pid) : getpgid(pid)
        if result >= 0 { return result }
        return nil
    }

    static func little32(_ bytes: [UInt8], _ offset: Int) -> UInt32 {
        UInt32(bytes[offset])
            | (UInt32(bytes[offset + 1]) << 8)
            | (UInt32(bytes[offset + 2]) << 16)
            | (UInt32(bytes[offset + 3]) << 24)
    }

    static func little64(_ bytes: [UInt8], _ offset: Int) -> UInt64 {
        UInt64(little32(bytes, offset))
            | (UInt64(little32(bytes, offset + 4)) << 32)
    }
}

private final class PrimeR19ChildOwner {
    private typealias DarwinKevent = Darwin.kevent
    private let pid: pid_t
    private let authorities: PrimeR19HeldAuthorities
    private let standardOutput: PrimeR19Pipe
    private let standardError: PrimeR19Pipe
    private let queue: Int32
    private let deadline: PrimeR19Deadline
    private let spawnReturnExpired: Bool
    private var outputCapture = PrimeR19StreamCapture()
    private var errorCapture = PrimeR19StreamCapture()
    private var eventsRegistered = false
    private var terminalObserved = false
    private var groupBaseline: PrimeR19JoinedProcess?
    private var suspendedAdmissionComplete = false
    private var contEntered = false
    private var killEntered = false
    private var reapConservationState = PrimeR19ReapConservationState.unreaped
    private var rawWaitStatus: Int32?
    private var veto = false

    init(
        pid: pid_t,
        authorities: PrimeR19HeldAuthorities,
        standardOutput: PrimeR19Pipe,
        standardError: PrimeR19Pipe,
        queue: Int32,
        deadline: PrimeR19Deadline,
        spawnReturnExpired: Bool
    ) {
        self.pid = pid
        self.authorities = authorities
        self.standardOutput = standardOutput
        self.standardError = standardError
        self.queue = queue
        self.deadline = deadline
        self.spawnReturnExpired = spawnReturnExpired
    }

    func run() throws -> Data {
        do {
            guard !spawnReturnExpired,
                  !deadline.expired
            else {
                throw PrimeR19AdmissionControllerFailure.rejected
            }
            try registerEvents()
            let before = try requireInitialJoin()
            groupBaseline = before
            try requireSuspendedCWD()
            try requireMappedImage()
            guard let after = try PrimeR19ProcessProof.join(pid) else {
                throw PrimeR19AdmissionControllerFailure.rejected
            }
            try PrimeR19ProcessProof.requirePrivateStoppedChild(after, pid: pid)
            try PrimeR19ProcessProof.requireSamePrivateChild(
                after,
                baseline: before,
                pid: pid
            )
            groupBaseline = after
            try authorities.revalidateBeforeResume()
            guard !deadline.expired else {
                throw PrimeR19AdmissionControllerFailure.rejected
            }
            suspendedAdmissionComplete = true
            contEntered = true
            guard Darwin.kill(pid, SIGCONT) == 0 else {
                throw PrimeR19AdmissionControllerFailure.rejected
            }
            try awaitTerminalAndEOF()
            try awaitConservationAndReap()
            try authorities.revalidateAfterReap()
            if deadline.expired { veto = true }
            guard !veto,
                  let status = rawWaitStatus,
                  status & 0x7F == 0,
                  (status >> 8) & 0xFF == 0,
                  outputCapture.eof,
                  errorCapture.eof,
                  !outputCapture.overflow,
                  !errorCapture.overflow,
                  !outputCapture.bytes.isEmpty,
                  outputCapture.bytes.count <= PrimeR19StreamCapture.cap,
                  outputCapture.bytes.last == 0x0A,
                  errorCapture.bytes.isEmpty,
                  !deadline.expired
            else {
                throw PrimeR19AdmissionControllerFailure.rejected
            }
            return Data(outputCapture.bytes)
        } catch {
            veto = true
            containFailure()
            throw PrimeR19AdmissionControllerFailure.rejected
        }
    }

    private func requireInitialJoin() throws -> PrimeR19JoinedProcess {
        guard let joined = try PrimeR19ProcessProof.join(pid) else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        try PrimeR19ProcessProof.requirePrivateStoppedChild(joined, pid: pid)
        return joined
    }

    private func registerEvents() throws {
        var changes = [
            DarwinKevent(
                ident: UInt(pid),
                filter: Int16(EVFILT_PROC),
                flags: UInt16(EV_ADD) | UInt16(EV_ENABLE) |
                    UInt16(EV_CLEAR) | UInt16(EV_RECEIPT),
                fflags: UInt32(NOTE_EXIT),
                data: 0,
                udata: nil
            ),
            DarwinKevent(
                ident: UInt(standardOutput.readDescriptor),
                filter: Int16(EVFILT_READ),
                flags: UInt16(EV_ADD) | UInt16(EV_ENABLE) |
                    UInt16(EV_CLEAR) | UInt16(EV_RECEIPT),
                fflags: 0,
                data: 0,
                udata: nil
            ),
            DarwinKevent(
                ident: UInt(standardError.readDescriptor),
                filter: Int16(EVFILT_READ),
                flags: UInt16(EV_ADD) | UInt16(EV_ENABLE) |
                    UInt16(EV_CLEAR) | UInt16(EV_RECEIPT),
                fflags: 0,
                data: 0,
                udata: nil
            ),
        ]
        var receipts = [DarwinKevent](repeating: DarwinKevent(), count: 3)
        let returned = changes.withUnsafeMutableBufferPointer { changeBuffer in
            receipts.withUnsafeMutableBufferPointer { receiptBuffer in
                kevent(
                    queue,
                    changeBuffer.baseAddress,
                    Int32(changeBuffer.count),
                    receiptBuffer.baseAddress,
                    Int32(receiptBuffer.count),
                    nil
                )
            }
        }
        guard returned == 3 else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        for index in 0..<3 {
            guard receipts[index].ident == changes[index].ident,
                  receipts[index].filter == changes[index].filter,
                  receipts[index].flags & UInt16(EV_ERROR) != 0,
                  receipts[index].data == 0
            else {
                throw PrimeR19AdmissionControllerFailure.rejected
            }
        }
        eventsRegistered = true
    }

    private func requireSuspendedCWD() throws {
        guard MemoryLayout<proc_vnodepathinfo>.size == 2_352 else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        var raw = proc_vnodepathinfo()
        errno = 0
        let returned = withUnsafeMutablePointer(to: &raw) {
            proc_pidinfo(pid, PROC_PIDVNODEPATHINFO, 0, $0, 2_352)
        }
        let status = raw.pvi_cdir.vip_vi.vi_stat
        guard returned == 2_352,
              UInt32(bitPattern: status.vst_dev) ==
                UInt32(bitPattern: PrimeR19HeldAuthorities.rootDevice),
              status.vst_ino == UInt64(PrimeR19HeldAuthorities.rootInode),
              status.vst_mode & UInt16(S_IFMT) == UInt16(S_IFDIR)
        else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
    }

    private func requireMappedImage() throws {
        guard MemoryLayout<proc_regionwithpathinfo>.size == 1_272 else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        let expectedPath = Array(PrimeR19HeldAuthorities.imagePath.utf8)
        var address: UInt64 = 0
        var matchingCount = 0
        var executableOffsetZero = false
        var writableExecutable = false
        for _ in 0..<65_536 {
            if deadline.expired {
                throw PrimeR19AdmissionControllerFailure.rejected
            }
            var bytes = [UInt8](repeating: 0, count: 1_272)
            errno = 0
            let returned = bytes.withUnsafeMutableBytes {
                proc_pidinfo(pid, PROC_PIDREGIONPATHINFO, address,
                             $0.baseAddress, Int32($0.count))
            }
            let observedErrno = errno
            if returned == 0 {
                guard observedErrno == EINVAL,
                      matchingCount > 0,
                      executableOffsetZero,
                      !writableExecutable
                else {
                    throw PrimeR19AdmissionControllerFailure.rejected
                }
                return
            }
            guard returned == 1_272 else {
                throw PrimeR19AdmissionControllerFailure.rejected
            }
            let protection = PrimeR19ProcessProof.little32(bytes, 0)
            let fileOffset = PrimeR19ProcessProof.little64(bytes, 16)
            let regionAddress = PrimeR19ProcessProof.little64(bytes, 80)
            let regionSize = PrimeR19ProcessProof.little64(bytes, 88)
            let device = PrimeR19ProcessProof.little32(bytes, 96)
            let inode = PrimeR19ProcessProof.little64(bytes, 104)
            guard regionAddress >= address, regionSize > 0 else {
                throw PrimeR19AdmissionControllerFailure.rejected
            }
            let following = regionAddress.addingReportingOverflow(regionSize)
            guard !following.overflow,
                  following.partialValue > regionAddress
            else {
                throw PrimeR19AdmissionControllerFailure.rejected
            }
            let pathField = Array(bytes[248..<1_272])
            guard let terminator = pathField.firstIndex(of: 0) else {
                throw PrimeR19AdmissionControllerFailure.rejected
            }
            let path = Array(pathField[0..<terminator])
            let vnodeMatches =
                device == UInt32(bitPattern: PrimeR19HeldAuthorities.imageDevice)
                && inode == UInt64(PrimeR19HeldAuthorities.imageInode)
            let pathMatches = path == expectedPath
            if vnodeMatches || pathMatches {
                guard vnodeMatches, pathMatches else {
                    throw PrimeR19AdmissionControllerFailure.rejected
                }
                matchingCount += 1
                if fileOffset == 0,
                   protection & UInt32(VM_PROT_EXECUTE) != 0 {
                    executableOffsetZero = true
                }
                if protection & UInt32(VM_PROT_EXECUTE) != 0,
                   protection & UInt32(VM_PROT_WRITE) != 0 {
                    writableExecutable = true
                }
            }
            address = following.partialValue
        }
        throw PrimeR19AdmissionControllerFailure.rejected
    }

    private func awaitTerminalAndEOF() throws {
        while !terminalObserved || !outputCapture.eof || !errorCapture.eof {
            try outputCapture.drain(standardOutput.readDescriptor)
            try errorCapture.drain(standardError.readDescriptor)
            if deadline.expired {
                veto = true
                try pollEvents(nonblocking: true)
                if !terminalObserved, !killEntered {
                    try enterGroupKill()
                }
            }
            if terminalObserved && outputCapture.eof && errorCapture.eof { break }
            try pollEvents(nonblocking: deadline.expired)
        }
    }

    private func pollEvents(nonblocking: Bool) throws {
        var events = [DarwinKevent](repeating: DarwinKevent(), count: 8)
        var timeout = nonblocking
            ? timespec(tv_sec: 0, tv_nsec: 1_000_000)
            : deadline.remainingTimespec()
        errno = 0
        let returned = events.withUnsafeMutableBufferPointer {
            kevent(queue, nil, 0, $0.baseAddress, Int32($0.count), &timeout)
        }
        if returned < 0, errno == EINTR { return }
        guard returned >= 0 else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        for event in events.prefix(Int(returned)) {
            guard event.flags & UInt16(EV_ERROR) == 0 else {
                throw PrimeR19AdmissionControllerFailure.rejected
            }
            if event.filter == Int16(EVFILT_PROC),
               event.ident == UInt(pid),
               event.fflags & UInt32(NOTE_EXIT) != 0 {
                terminalObserved = true
            } else if event.filter == Int16(EVFILT_READ),
                      event.ident == UInt(standardOutput.readDescriptor) {
                try outputCapture.drain(standardOutput.readDescriptor)
            } else if event.filter == Int16(EVFILT_READ),
                      event.ident == UInt(standardError.readDescriptor) {
                try errorCapture.drain(standardError.readDescriptor)
            } else {
                throw PrimeR19AdmissionControllerFailure.rejected
            }
        }
    }

    private func enterGroupKill() throws {
        while !terminalObserved && !killEntered {
            guard let baseline = groupBaseline,
                  let first = try PrimeR19ProcessProof.join(pid),
                  let second = try PrimeR19ProcessProof.join(pid)
            else {
                try pollEvents(nonblocking: true)
                continue
            }
            try PrimeR19ProcessProof.requireSamePrivateChild(
                first, baseline: baseline, pid: pid
            )
            try PrimeR19ProcessProof.requireSamePrivateChild(
                second, baseline: baseline, pid: pid
            )
            guard first.sameIdentity(as: second) else {
                continue
            }
            if first.short.status == 5 || second.short.status == 5 {
                try pollEvents(nonblocking: true)
                continue
            }
            killEntered = true
            _ = Darwin.kill(-pid, SIGKILL)
        }
    }

    private func enterPositiveKill() {
        while !terminalObserved && !killEntered {
            do {
                guard let joined = try PrimeR19ProcessProof.join(pid) else {
                    try pollEvents(nonblocking: true)
                    continue
                }
                try PrimeR19ProcessProof.requirePrivateStoppedChild(joined, pid: pid)
                groupBaseline = joined
                killEntered = true
                _ = Darwin.kill(pid, SIGKILL)
            } catch {
                try? pollEvents(nonblocking: true)
            }
        }
    }

    private func awaitConservationAndReap() throws {
        while true {
            if deadline.expired { veto = true }
            guard let baseline = groupBaseline else {
                throw PrimeR19AdmissionControllerFailure.rejected
            }
            var identifiers = [pid_t](repeating: 0, count: 65_536)
            errno = 0
            let returned = identifiers.withUnsafeMutableBytes {
                proc_listpids(
                    UInt32(PROC_PGRP_ONLY),
                    UInt32(pid),
                    $0.baseAddress,
                    Int32($0.count)
                )
            }
            guard returned >= 0,
                  Int(returned) < identifiers.count * MemoryLayout<pid_t>.stride,
                  Int(returned) % MemoryLayout<pid_t>.stride == 0
            else {
                veto = true
                try pollEvents(nonblocking: true)
                continue
            }
            let count = Int(returned) / MemoryLayout<pid_t>.stride
            let positive = identifiers.prefix(count).filter { $0 > 0 }
            guard Set(positive).count == positive.count else {
                veto = true
                try pollEvents(nonblocking: true)
                continue
            }
            var nonleaderPresent = false
            var uncertain = false
            for member in positive {
                if member == pid { continue }
                do {
                    guard let joined = try PrimeR19ProcessProof.join(member) else {
                        uncertain = true
                        break
                    }
                    guard joined.processGroup == pid,
                          joined.session == baseline.session
                    else {
                        uncertain = true
                        break
                    }
                    nonleaderPresent = true
                } catch {
                    uncertain = true
                    break
                }
            }
            if uncertain {
                veto = true
                try pollEvents(nonblocking: true)
                continue
            }
            if nonleaderPresent {
                try pollEvents(nonblocking: true)
                continue
            }
            break
        }
        var status: Int32 = 0
        while true {
            errno = 0
            let returned = Darwin.waitpid(pid, &status, 0)
            if returned == pid { break }
            if returned < 0, errno == EINTR { continue }
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        reapConservationState = .reapedUnconserved
        rawWaitStatus = status
        var absenceProved = true
        for _ in 0..<2 {
            errno = 0
            let result = Darwin.kill(-pid, 0)
            if result != -1 || errno != ESRCH {
                absenceProved = false
            }
        }
        guard absenceProved else {
            retainReapedUnconserved()
        }
        reapConservationState = .conserved
    }

    private func containFailure() {
        switch reapConservationState {
        case .conserved:
            return
        case .reapedUnconserved:
            retainReapedUnconserved()
        case .unreaped:
            break
        }
        if !terminalObserved && !killEntered {
            if suspendedAdmissionComplete || contEntered || groupBaseline != nil {
                while !terminalObserved && !killEntered {
                    do {
                        try enterGroupKill()
                    } catch {
                        try? pollEvents(nonblocking: true)
                    }
                }
            } else {
                enterPositiveKill()
            }
        }
        while !eventsRegistered {
            do { try registerEvents() } catch { continue }
        }
        while !terminalObserved || !outputCapture.eof || !errorCapture.eof {
            try? outputCapture.drain(standardOutput.readDescriptor)
            try? errorCapture.drain(standardError.readDescriptor)
            try? pollEvents(nonblocking: true)
        }
        while reapConservationState == .unreaped {
            do { try awaitConservationAndReap() } catch { continue }
        }
        switch reapConservationState {
        case .conserved:
            return
        case .reapedUnconserved:
            retainReapedUnconserved()
        case .unreaped:
            retainReapedUnconserved()
        }
    }

    private func retainReapedUnconserved() -> Never {
        while true {
            var event = DarwinKevent()
            errno = 0
            _ = withUnsafeMutablePointer(to: &event) {
                kevent(queue, nil, 0, $0, 1, nil)
            }
        }
    }
}

private enum PrimeR19AdmissionController {
    private typealias DarwinKevent = Darwin.kevent

    static func run() throws -> Data {
        try requireIngress()
        let authorities = try PrimeR19HeldAuthorities.prepare()
        let standardOutput = try PrimeR19Pipe()
        let standardError: PrimeR19Pipe
        do {
            standardError = try PrimeR19Pipe()
        } catch {
            standardOutput.closeAll()
            throw error
        }
        let queue = kqueue()
        guard queue >= 3 else {
            standardOutput.closeAll()
            standardError.closeAll()
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        defer { _ = Darwin.close(queue) }
        let queueFlags = fcntl(queue, F_GETFD)
        guard queueFlags >= 0,
              fcntl(queue, F_SETFD, queueFlags | FD_CLOEXEC) == 0
        else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        let deadline = try PrimeR19Deadline()
        guard !deadline.expired else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        let childPID = try spawn(
            authorities: authorities,
            standardOutput: standardOutput,
            standardError: standardError,
            deadline: deadline
        )
        let spawnReturnExpired = deadline.expired
        standardOutput.closeWriteEnd()
        standardError.closeWriteEnd()
        let owner = PrimeR19ChildOwner(
            pid: childPID,
            authorities: authorities,
            standardOutput: standardOutput,
            standardError: standardError,
            queue: queue,
            deadline: deadline,
            spawnReturnExpired: spawnReturnExpired
        )
        return try owner.run()
    }

    private static func requireIngress() throws {
        guard CommandLine.argc == 1,
              let environment = primeR19AdmissionControllerNSGetEnviron().pointee,
              environment.pointee == nil
        else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        var cwd = [CChar](repeating: 0, count: Int(PATH_MAX))
        let cwdResult = cwd.withUnsafeMutableBufferPointer {
            getcwd($0.baseAddress, $0.count)
        }
        guard cwdResult != nil,
              cwd[0] == CChar(UInt8(ascii: "/")),
              cwd[1] == 0
        else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        var input = stat()
        var output = stat()
        var error = stat()
        guard fstat(STDIN_FILENO, &input) == 0,
              fstat(STDOUT_FILENO, &output) == 0,
              fstat(STDERR_FILENO, &error) == 0,
              input.st_mode & mode_t(S_IFMT) == mode_t(S_IFCHR),
              UInt32(bitPattern: input.st_dev) == 3_836_289_247,
              input.st_ino == ino_t(336),
              input.st_rdev == dev_t(50_331_650),
              input.st_uid == 0,
              input.st_gid == 0,
              input.st_mode & mode_t(0o7777) == mode_t(0o666),
              output.st_mode & mode_t(S_IFMT) == mode_t(S_IFIFO),
              error.st_mode & mode_t(S_IFMT) == mode_t(S_IFIFO),
              output.st_dev != error.st_dev || output.st_ino != error.st_ino,
              isatty(STDIN_FILENO) == 0,
              isatty(STDOUT_FILENO) == 0,
              isatty(STDERR_FILENO) == 0,
              fcntl(STDIN_FILENO, F_GETFL) == O_RDONLY,
              fcntl(STDOUT_FILENO, F_GETFL) == O_WRONLY,
              fcntl(STDERR_FILENO, F_GETFL) == O_WRONLY,
              fpathconf(STDOUT_FILENO, _PC_PIPE_BUF) == 512,
              fpathconf(STDERR_FILENO, _PC_PIPE_BUF) == 512
        else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        guard MemoryLayout<proc_fdinfo>.size == 8,
              MemoryLayout<proc_fdinfo>.stride == 8
        else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        var snapshot = [proc_fdinfo](repeating: proc_fdinfo(), count: 4)
        let returned = snapshot.withUnsafeMutableBufferPointer {
            proc_pidinfo(
                getpid(),
                PROC_PIDLISTFDS,
                0,
                $0.baseAddress,
                Int32($0.count * MemoryLayout<proc_fdinfo>.stride)
            )
        }
        guard returned == 24,
              snapshot.prefix(3).map(\.proc_fd).sorted() ==
                [STDIN_FILENO, STDOUT_FILENO, STDERR_FILENO]
        else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
    }

    private static func spawn(
        authorities: PrimeR19HeldAuthorities,
        standardOutput: PrimeR19Pipe,
        standardError: PrimeR19Pipe,
        deadline: PrimeR19Deadline
    ) throws -> pid_t {
        var actions: posix_spawn_file_actions_t?
        var attributes: posix_spawnattr_t?
        guard posix_spawn_file_actions_init(&actions) == 0 else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        defer { _ = posix_spawn_file_actions_destroy(&actions) }
        guard posix_spawnattr_init(&attributes) == 0 else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        defer { _ = posix_spawnattr_destroy(&attributes) }
        let actionResults = [
            posix_spawn_file_actions_addinherit_np(
                &actions, authorities.rootDescriptor
            ),
            posix_spawn_file_actions_addfchdir_np(
                &actions, authorities.rootDescriptor
            ),
            posix_spawn_file_actions_addclose(
                &actions, authorities.rootDescriptor
            ),
            posix_spawn_file_actions_adddup2(
                &actions, authorities.nullDescriptor, STDIN_FILENO
            ),
            posix_spawn_file_actions_addclose(
                &actions, authorities.nullDescriptor
            ),
            posix_spawn_file_actions_addclose(
                &actions, standardOutput.readDescriptor
            ),
            posix_spawn_file_actions_adddup2(
                &actions, standardOutput.writeDescriptor, STDOUT_FILENO
            ),
            posix_spawn_file_actions_addclose(
                &actions, standardOutput.writeDescriptor
            ),
            posix_spawn_file_actions_addclose(
                &actions, standardError.readDescriptor
            ),
            posix_spawn_file_actions_adddup2(
                &actions, standardError.writeDescriptor, STDERR_FILENO
            ),
            posix_spawn_file_actions_addclose(
                &actions, standardError.writeDescriptor
            ),
        ]
        guard actionResults.allSatisfy({ $0 == 0 }) else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        var defaults = sigset_t()
        guard sigemptyset(&defaults) == 0 else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        for signal in 1..<NSIG where signal != SIGKILL && signal != SIGSTOP {
            guard sigaddset(&defaults, signal) == 0 else {
                throw PrimeR19AdmissionControllerFailure.rejected
            }
        }
        var mask = sigset_t()
        guard sigemptyset(&mask) == 0,
              posix_spawnattr_setsigdefault(&attributes, &defaults) == 0,
              posix_spawnattr_setsigmask(&attributes, &mask) == 0
        else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        let flags = UInt16(POSIX_SPAWN_START_SUSPENDED)
            | UInt16(POSIX_SPAWN_CLOEXEC_DEFAULT)
            | UInt16(POSIX_SPAWN_SETSID)
            | UInt16(POSIX_SPAWN_SETSIGDEF)
            | UInt16(POSIX_SPAWN_SETSIGMASK)
        guard flags == 0x448C,
              posix_spawnattr_setflags(
                  &attributes,
                  Int16(bitPattern: flags)
              ) == 0
        else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        guard let argumentZero = strdup(PrimeR19HeldAuthorities.imagePath) else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        defer { free(argumentZero) }
        var arguments: [UnsafeMutablePointer<CChar>?] = [argumentZero, nil]
        var environment: [UnsafeMutablePointer<CChar>?] = [nil]
        var child: pid_t = 0
        guard !deadline.expired else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        let result = PrimeR19HeldAuthorities.imagePath.withCString { path in
            arguments.withUnsafeMutableBufferPointer { argumentBuffer in
                environment.withUnsafeMutableBufferPointer { environmentBuffer in
                    posix_spawn(
                        &child,
                        path,
                        &actions,
                        &attributes,
                        argumentBuffer.baseAddress,
                        environmentBuffer.baseAddress
                    )
                }
            }
        }
        guard result == 0, child > 0 else {
            throw PrimeR19AdmissionControllerFailure.rejected
        }
        return child
    }
}

@main
private struct PrimeDriverV2R19NativeLeafAdmissionController {
    static func main() {
        do {
            let output = try PrimeR19AdmissionController.run()
            guard fcntl(STDOUT_FILENO, F_SETNOSIGPIPE, 1) == 0 else {
                Darwin._exit(70)
            }
            let written = output.withUnsafeBytes { raw in
                guard let base = raw.baseAddress else { return -1 }
                return Darwin.write(STDOUT_FILENO, base, raw.count)
            }
            guard written == output.count else {
                Darwin._exit(70)
            }
            Darwin._exit(0)
        } catch {
            Darwin._exit(70)
        }
    }
}
