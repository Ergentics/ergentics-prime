// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CryptoKit
import Darwin
import Foundation

@_silgen_name("_NSGetEnviron")
private func primeR19NativeLeafAdmissionNSGetEnviron()
    -> UnsafeMutablePointer<
        UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?
    >

private enum PrimeR19NativeLeafAdmissionFailure: Error {
    case rejected
}

private struct PrimeR19NativeLeafAdmissionIdentity: Equatable {
    let device: dev_t
    let inode: ino_t
}

private struct PrimeR19NativeLeafAdmissionStableMetadata: Equatable {
    let identity: PrimeR19NativeLeafAdmissionIdentity
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

    init(_ metadata: stat) {
        identity = PrimeR19NativeLeafAdmissionIdentity(
            device: metadata.st_dev,
            inode: metadata.st_ino
        )
        mode = metadata.st_mode
        links = metadata.st_nlink
        owner = metadata.st_uid
        group = metadata.st_gid
        size = metadata.st_size
        flags = metadata.st_flags
        generation = metadata.st_gen
        modifiedSeconds = Int64(metadata.st_mtimespec.tv_sec)
        modifiedNanoseconds = Int64(metadata.st_mtimespec.tv_nsec)
        changedSeconds = Int64(metadata.st_ctimespec.tv_sec)
        changedNanoseconds = Int64(metadata.st_ctimespec.tv_nsec)
        createdSeconds = Int64(metadata.st_birthtimespec.tv_sec)
        createdNanoseconds = Int64(metadata.st_birthtimespec.tv_nsec)
    }
}

private enum PrimeR19NativeLeafAdmission {
    static let privateTmpPath = "/private/tmp"
    static let privateTmpDevice = dev_t(16_777_231)
    static let privateTmpInode = ino_t(774_813)

    static let canaryRootLeaf =
        "gate-e1-4-r19-native-leaf-primitive-canary-3a46a037-17452840"
    static let canaryRootPath = privateTmpPath + "/" + canaryRootLeaf
    static let canaryLeaf = "00-native-leaf-canary.json"
    static let canaryFileCap = 16_384

    static let definitiveBuildRootLeaf =
        "prime-driver-v2-r19-native-leaf-build-a-e9b6f7bd"
    static let definitiveBuildRootPath =
        privateTmpPath + "/" + definitiveBuildRootLeaf
    static let definitiveBuildRootInode = ino_t(17_453_507)
    static let definitiveSDKDirectoryLeaf = "sdk26_5_fdflags"
    static let definitiveSDKDirectoryPath =
        definitiveBuildRootPath + "/" + definitiveSDKDirectoryLeaf
    static let definitiveSDKDirectoryInode = ino_t(17_454_452)
    static let definitiveImageLeaf =
        "PrimeDriverV2R19NativeLeafPrimitiveCanary"
    static let definitiveImagePath =
        definitiveSDKDirectoryPath + "/" + definitiveImageLeaf
    static let definitiveImageDevice = dev_t(16_777_231)
    static let definitiveImageInode = ino_t(17_454_586)
    static let definitiveImageBytes = 89_976
    static let definitiveImageSHA256 =
        "e826ff9251906e2ff92921fcbaa8b27eff32e227838ce217c62017c9461b10d3"
    static let definitiveImageUUID = [UInt8](
        [0x25, 0x0D, 0x80, 0xB3, 0xE1, 0x9B, 0x3B, 0x12,
         0xAC, 0x3A, 0xD2, 0x25, 0xB5, 0xFF, 0x5B, 0xEB]
    )
    static let definitiveImageCodeDirectorySHA256 =
        "f4e81281906a06354b1cd604d178102337b47360c5cc298f6ebc2109cccc045d"

    static let auditorFrameCap = 4_096
    static let descriptorSnapshotCapacity = 4

    static func prepareCandidateFrame() throws -> Data {
        guard CommandLine.argc == 1 else {
            throw PrimeR19NativeLeafAdmissionFailure.rejected
        }
        try requireEmptyEnvironment()
        try requireRootWorkingDirectory()
        try requireStandardDescriptors()
        try requireNoInheritedDescriptors()

        let privateTmp = Darwin.open(
            privateTmpPath,
            O_RDONLY | O_DIRECTORY | O_NOFOLLOW_ANY | O_CLOEXEC
        )
        guard privateTmp >= 3 else {
            throw PrimeR19NativeLeafAdmissionFailure.rejected
        }
        defer { _ = Darwin.close(privateTmp) }

        let privateTmpMetadata = try requirePrivateTmp(privateTmp)
        let buildRoot = definitiveBuildRootLeaf.withCString {
            Darwin.openat(
                privateTmp,
                $0,
                O_RDONLY | O_DIRECTORY | O_NOFOLLOW_ANY | O_CLOEXEC
            )
        }
        guard buildRoot >= 3 else {
            throw PrimeR19NativeLeafAdmissionFailure.rejected
        }
        defer { _ = Darwin.close(buildRoot) }

        let initialBuildRoot = try requirePinnedImageDirectory(
            buildRoot,
            parent: privateTmp,
            parentMetadata: privateTmpMetadata,
            leaf: definitiveBuildRootLeaf,
            inode: definitiveBuildRootInode
        )
        let buildRootStable =
            PrimeR19NativeLeafAdmissionStableMetadata(initialBuildRoot)
        let sdkDirectory = definitiveSDKDirectoryLeaf.withCString {
            Darwin.openat(
                buildRoot,
                $0,
                O_RDONLY | O_DIRECTORY | O_NOFOLLOW_ANY | O_CLOEXEC
            )
        }
        guard sdkDirectory >= 3 else {
            throw PrimeR19NativeLeafAdmissionFailure.rejected
        }
        defer { _ = Darwin.close(sdkDirectory) }

        let initialSDKDirectory = try requirePinnedImageDirectory(
            sdkDirectory,
            parent: buildRoot,
            parentMetadata: initialBuildRoot,
            leaf: definitiveSDKDirectoryLeaf,
            inode: definitiveSDKDirectoryInode
        )
        let sdkDirectoryStable =
            PrimeR19NativeLeafAdmissionStableMetadata(initialSDKDirectory)
        let image = definitiveImageLeaf.withCString {
            Darwin.openat(
                sdkDirectory,
                $0,
                O_RDONLY | O_NOFOLLOW_ANY | O_CLOEXEC
            )
        }
        guard image >= 3 else {
            throw PrimeR19NativeLeafAdmissionFailure.rejected
        }
        defer { _ = Darwin.close(image) }

        let initialImage = try requireDefinitiveImage(
            image,
            sdkDirectory: sdkDirectory,
            sdkDirectoryMetadata: initialSDKDirectory
        )
        let imageBytes = try readExact(
            descriptor: image,
            expectedSize: definitiveImageBytes,
            cap: definitiveImageBytes
        )
        guard sha256Hex(imageBytes) == definitiveImageSHA256 else {
            throw PrimeR19NativeLeafAdmissionFailure.rejected
        }
        try requireMachOIdentity(imageBytes)
        _ = try requireDefinitiveImage(
            image,
            sdkDirectory: sdkDirectory,
            sdkDirectoryMetadata: initialSDKDirectory,
            expected: PrimeR19NativeLeafAdmissionStableMetadata(initialImage)
        )
        let root = canaryRootLeaf.withCString {
            Darwin.openat(
                privateTmp,
                $0,
                O_RDONLY | O_DIRECTORY | O_NOFOLLOW_ANY | O_CLOEXEC
            )
        }
        guard root >= 3 else {
            throw PrimeR19NativeLeafAdmissionFailure.rejected
        }
        defer { _ = Darwin.close(root) }

        let initialRoot = try requireCanaryRoot(
            root,
            privateTmp: privateTmp,
            privateTmpMetadata: privateTmpMetadata
        )
        let rootStable = PrimeR19NativeLeafAdmissionStableMetadata(initialRoot)
        try requireInventory(root, exactLeaf: canaryLeaf)

        let namedLeaf = try requireNamedLeafBeforeOpen(
            root,
            rootMetadata: initialRoot
        )
        let leaf = canaryLeaf.withCString {
            Darwin.openat(
                root,
                $0,
                O_RDONLY | O_NOFOLLOW_ANY | O_CLOEXEC
            )
        }
        guard leaf >= 3 else {
            throw PrimeR19NativeLeafAdmissionFailure.rejected
        }
        defer { _ = Darwin.close(leaf) }

        let initialLeaf = try requireCanaryLeaf(
            leaf,
            root: root,
            rootMetadata: initialRoot,
            expected: PrimeR19NativeLeafAdmissionStableMetadata(namedLeaf)
        )
        let leafStable = PrimeR19NativeLeafAdmissionStableMetadata(initialLeaf)
        let expectedCanaryFrame = try canonicalCanaryFrame(
            rootMetadata: initialRoot,
            leafMetadata: initialLeaf
        )
        guard initialLeaf.st_size == off_t(expectedCanaryFrame.count) else {
            throw PrimeR19NativeLeafAdmissionFailure.rejected
        }

        let observedCanaryFrame = try readExact(
            descriptor: leaf,
            expectedSize: expectedCanaryFrame.count,
            cap: canaryFileCap
        )
        guard observedCanaryFrame == expectedCanaryFrame,
              SHA256.hash(data: observedCanaryFrame) ==
                  SHA256.hash(data: expectedCanaryFrame)
        else {
            throw PrimeR19NativeLeafAdmissionFailure.rejected
        }

        _ = try requireCanaryLeaf(
            leaf,
            root: root,
            rootMetadata: initialRoot,
            expected: leafStable
        )
        try requireInventory(root, exactLeaf: canaryLeaf)
        _ = try requireCanaryRoot(
            root,
            privateTmp: privateTmp,
            privateTmpMetadata: privateTmpMetadata,
            expected: rootStable
        )
        _ = try requirePrivateTmp(privateTmp)
        _ = try requireDefinitiveImage(
            image,
            sdkDirectory: sdkDirectory,
            sdkDirectoryMetadata: initialSDKDirectory,
            expected: PrimeR19NativeLeafAdmissionStableMetadata(initialImage)
        )
        _ = try requirePinnedImageDirectory(
            sdkDirectory,
            parent: buildRoot,
            parentMetadata: initialBuildRoot,
            leaf: definitiveSDKDirectoryLeaf,
            inode: definitiveSDKDirectoryInode,
            expected: sdkDirectoryStable
        )
        _ = try requirePinnedImageDirectory(
            buildRoot,
            parent: privateTmp,
            parentMetadata: privateTmpMetadata,
            leaf: definitiveBuildRootLeaf,
            inode: definitiveBuildRootInode,
            expected: buildRootStable
        )
        _ = try requirePrivateTmp(privateTmp)

        return try canonicalAuditorFrame(
            canaryFrame: observedCanaryFrame,
            rootMetadata: initialRoot,
            leafMetadata: initialLeaf
        )
    }

    private static func requireEmptyEnvironment() throws {
        guard let environment =
                primeR19NativeLeafAdmissionNSGetEnviron().pointee,
              environment.pointee == nil
        else {
            throw PrimeR19NativeLeafAdmissionFailure.rejected
        }
    }

    private static func requireRootWorkingDirectory() throws {
        var buffer = [CChar](repeating: 0, count: Int(PATH_MAX))
        let result = buffer.withUnsafeMutableBufferPointer { pointer in
            getcwd(pointer.baseAddress, pointer.count)
        }
        guard result != nil,
              buffer[0] == CChar(UInt8(ascii: "/")),
              buffer[1] == 0
        else {
            throw PrimeR19NativeLeafAdmissionFailure.rejected
        }
    }

    private static func requireStandardDescriptors() throws {
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
              isatty(STDIN_FILENO) == 0,
              output.st_mode & mode_t(S_IFMT) == mode_t(S_IFIFO),
              error.st_mode & mode_t(S_IFMT) == mode_t(S_IFIFO),
              output.st_dev != error.st_dev || output.st_ino != error.st_ino,
              isatty(STDOUT_FILENO) == 0,
              isatty(STDERR_FILENO) == 0
        else {
            throw PrimeR19NativeLeafAdmissionFailure.rejected
        }

        let inputFlags = fcntl(STDIN_FILENO, F_GETFL)
        let outputFlags = fcntl(STDOUT_FILENO, F_GETFL)
        let errorFlags = fcntl(STDERR_FILENO, F_GETFL)
        guard inputFlags == O_RDONLY,
              outputFlags >= 0,
              errorFlags >= 0,
              outputFlags == O_WRONLY,
              errorFlags == O_WRONLY,
              fpathconf(STDOUT_FILENO, _PC_PIPE_BUF) == 512,
              fpathconf(STDERR_FILENO, _PC_PIPE_BUF) == 512
        else {
            throw PrimeR19NativeLeafAdmissionFailure.rejected
        }
    }

    private static func requireNoInheritedDescriptors() throws {
        let entryBytes = MemoryLayout<proc_fdinfo>.stride
        guard MemoryLayout<proc_fdinfo>.size == 8,
              entryBytes == 8
        else {
            throw PrimeR19NativeLeafAdmissionFailure.rejected
        }

        var snapshot = [proc_fdinfo](
            repeating: proc_fdinfo(),
            count: descriptorSnapshotCapacity
        )
        let returned = snapshot.withUnsafeMutableBufferPointer { entries in
            proc_pidinfo(
                getpid(),
                PROC_PIDLISTFDS,
                0,
                entries.baseAddress,
                Int32(entries.count * entryBytes)
            )
        }
        guard returned == Int32(3 * entryBytes) else {
            throw PrimeR19NativeLeafAdmissionFailure.rejected
        }

        let observed = snapshot.prefix(3).map(\.proc_fd).sorted()
        guard observed == [STDIN_FILENO, STDOUT_FILENO, STDERR_FILENO] else {
            throw PrimeR19NativeLeafAdmissionFailure.rejected
        }
    }

    private static func requirePinnedImageDirectory(
        _ descriptor: Int32,
        parent: Int32,
        parentMetadata: stat,
        leaf: String,
        inode: ino_t,
        expected: PrimeR19NativeLeafAdmissionStableMetadata? = nil
    ) throws -> stat {
        try requireCloseOnExec(descriptor)
        var held = stat()
        var named = stat()
        guard fstat(descriptor, &held) == 0,
              leaf.withCString({
                  fstatat(parent, $0, &named, AT_SYMLINK_NOFOLLOW)
              }) == 0,
              held.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
              named.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
              held.st_dev == parentMetadata.st_dev,
              held.st_dev == named.st_dev,
              held.st_ino == inode,
              held.st_ino == named.st_ino,
              held.st_uid == 501,
              held.st_uid == named.st_uid,
              held.st_gid == 0,
              held.st_gid == named.st_gid,
              held.st_mode & mode_t(0o7777) == mode_t(0o700),
              named.st_mode & mode_t(0o7777) == mode_t(0o700),
              held.st_flags == 0,
              named.st_flags == 0
        else {
            throw PrimeR19NativeLeafAdmissionFailure.rejected
        }
        if let expected {
            guard PrimeR19NativeLeafAdmissionStableMetadata(held) == expected,
                  PrimeR19NativeLeafAdmissionStableMetadata(named) == expected
            else {
                throw PrimeR19NativeLeafAdmissionFailure.rejected
            }
        }
        return held
    }

    private static func requireDefinitiveImage(
        _ descriptor: Int32,
        sdkDirectory: Int32,
        sdkDirectoryMetadata: stat,
        expected: PrimeR19NativeLeafAdmissionStableMetadata? = nil
    ) throws -> stat {
        try requireCloseOnExec(descriptor)
        var held = stat()
        var named = stat()
        guard fstat(descriptor, &held) == 0,
              definitiveImageLeaf.withCString({
                  fstatat(sdkDirectory, $0, &named, AT_SYMLINK_NOFOLLOW)
              }) == 0,
              held.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
              named.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
              held.st_dev == definitiveImageDevice,
              held.st_dev == sdkDirectoryMetadata.st_dev,
              held.st_dev == named.st_dev,
              held.st_ino == definitiveImageInode,
              held.st_ino == named.st_ino,
              held.st_uid == 501,
              held.st_uid == named.st_uid,
              held.st_gid == 0,
              held.st_gid == named.st_gid,
              held.st_mode & mode_t(0o7777) == mode_t(0o755),
              named.st_mode & mode_t(0o7777) == mode_t(0o755),
              held.st_nlink == 1,
              named.st_nlink == 1,
              held.st_flags == 0,
              named.st_flags == 0,
              held.st_size == off_t(definitiveImageBytes),
              named.st_size == off_t(definitiveImageBytes)
        else {
            throw PrimeR19NativeLeafAdmissionFailure.rejected
        }
        if let expected {
            guard PrimeR19NativeLeafAdmissionStableMetadata(held) == expected,
                  PrimeR19NativeLeafAdmissionStableMetadata(named) == expected
            else {
                throw PrimeR19NativeLeafAdmissionFailure.rejected
            }
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
            throw PrimeR19NativeLeafAdmissionFailure.rejected
        }

        var filesystem = statfs()
        guard fstatfs(descriptor, &filesystem) == 0,
              filesystem.f_flags & UInt32(MNT_LOCAL) != 0
        else {
            throw PrimeR19NativeLeafAdmissionFailure.rejected
        }
        var typeField = filesystem.f_fstypename
        let typeBytes = withUnsafeBytes(of: &typeField) {
            Array($0.prefix { $0 != 0 })
        }
        guard typeBytes == Array("apfs".utf8) else {
            throw PrimeR19NativeLeafAdmissionFailure.rejected
        }
        return held
    }

    private static func requireCanaryRoot(
        _ descriptor: Int32,
        privateTmp: Int32,
        privateTmpMetadata: stat,
        expected: PrimeR19NativeLeafAdmissionStableMetadata? = nil
    ) throws -> stat {
        try requireCloseOnExec(descriptor)
        var held = stat()
        var named = stat()
        guard fstat(descriptor, &held) == 0,
              canaryRootLeaf.withCString({
                  fstatat(privateTmp, $0, &named, AT_SYMLINK_NOFOLLOW)
              }) == 0,
              held.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
              named.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
              held.st_dev == privateTmpMetadata.st_dev,
              held.st_dev == named.st_dev,
              held.st_ino != 0,
              held.st_ino == named.st_ino,
              held.st_uid == 501,
              held.st_uid == named.st_uid,
              held.st_gid == privateTmpMetadata.st_gid,
              held.st_gid == named.st_gid,
              held.st_mode & mode_t(0o7777) == mode_t(0o700),
              named.st_mode & mode_t(0o7777) == mode_t(0o700),
              held.st_flags == 0,
              named.st_flags == 0
        else {
            throw PrimeR19NativeLeafAdmissionFailure.rejected
        }
        if let expected {
            guard PrimeR19NativeLeafAdmissionStableMetadata(held) == expected,
                  PrimeR19NativeLeafAdmissionStableMetadata(named) == expected
            else {
                throw PrimeR19NativeLeafAdmissionFailure.rejected
            }
        }
        return held
    }

    private static func requireNamedLeafBeforeOpen(
        _ root: Int32,
        rootMetadata: stat
    ) throws -> stat {
        var named = stat()
        guard canaryLeaf.withCString({
                  fstatat(root, $0, &named, AT_SYMLINK_NOFOLLOW)
              }) == 0,
              named.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
              named.st_dev == rootMetadata.st_dev,
              named.st_ino != 0,
              named.st_uid == 501,
              named.st_gid == rootMetadata.st_gid,
              named.st_nlink == 1,
              named.st_flags == 0,
              named.st_mode & mode_t(0o7777) == mode_t(0o400),
              named.st_size > 0,
              named.st_size <= off_t(canaryFileCap)
        else {
            throw PrimeR19NativeLeafAdmissionFailure.rejected
        }
        return named
    }

    private static func requireCanaryLeaf(
        _ descriptor: Int32,
        root: Int32,
        rootMetadata: stat,
        expected: PrimeR19NativeLeafAdmissionStableMetadata
    ) throws -> stat {
        try requireCloseOnExec(descriptor)
        var held = stat()
        var named = stat()
        guard fstat(descriptor, &held) == 0,
              canaryLeaf.withCString({
                  fstatat(root, $0, &named, AT_SYMLINK_NOFOLLOW)
              }) == 0,
              held.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
              named.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
              held.st_dev == rootMetadata.st_dev,
              held.st_dev == named.st_dev,
              held.st_ino != 0,
              held.st_ino == named.st_ino,
              held.st_uid == 501,
              held.st_uid == named.st_uid,
              held.st_gid == rootMetadata.st_gid,
              held.st_gid == named.st_gid,
              held.st_nlink == 1,
              named.st_nlink == 1,
              held.st_flags == 0,
              named.st_flags == 0,
              held.st_mode & mode_t(0o7777) == mode_t(0o400),
              named.st_mode & mode_t(0o7777) == mode_t(0o400),
              held.st_size > 0,
              held.st_size <= off_t(canaryFileCap),
              held.st_size == named.st_size,
              PrimeR19NativeLeafAdmissionStableMetadata(held) == expected,
              PrimeR19NativeLeafAdmissionStableMetadata(named) == expected
        else {
            throw PrimeR19NativeLeafAdmissionFailure.rejected
        }
        return held
    }

    private static func requireCloseOnExec(_ descriptor: Int32) throws {
        guard descriptor >= 3 else {
            throw PrimeR19NativeLeafAdmissionFailure.rejected
        }
        let flags = fcntl(descriptor, F_GETFD)
        guard flags >= 0,
              flags & FD_CLOEXEC != 0
        else {
            throw PrimeR19NativeLeafAdmissionFailure.rejected
        }
    }

    private static func requireInventory(
        _ descriptor: Int32,
        exactLeaf: String
    ) throws {
        let independent = Darwin.openat(
            descriptor,
            ".",
            O_RDONLY | O_DIRECTORY | O_NOFOLLOW_ANY | O_CLOEXEC
        )
        guard independent >= 3 else {
            throw PrimeR19NativeLeafAdmissionFailure.rejected
        }
        guard let directory = fdopendir(independent) else {
            _ = Darwin.close(independent)
            throw PrimeR19NativeLeafAdmissionFailure.rejected
        }
        defer { _ = closedir(directory) }

        let expected = Data(exactLeaf.utf8)
        var observed: Data?
        while true {
            errno = 0
            guard let pointer = readdir(directory) else {
                guard errno == 0 else {
                    throw PrimeR19NativeLeafAdmissionFailure.rejected
                }
                break
            }
            let entry = pointer.pointee
            let length = Int(entry.d_namlen)
            guard length > 0, length <= Int(MAXNAMLEN) else {
                throw PrimeR19NativeLeafAdmissionFailure.rejected
            }
            var nameField = entry.d_name
            let name = withUnsafeBytes(of: &nameField) {
                Data($0.prefix(length))
            }
            if name == Data(".".utf8) || name == Data("..".utf8) {
                continue
            }
            guard observed == nil else {
                throw PrimeR19NativeLeafAdmissionFailure.rejected
            }
            observed = name
        }
        guard observed == expected else {
            throw PrimeR19NativeLeafAdmissionFailure.rejected
        }
    }

    private static func readExact(
        descriptor: Int32,
        expectedSize: Int,
        cap: Int
    ) throws -> Data {
        guard expectedSize > 0, expectedSize <= cap else {
            throw PrimeR19NativeLeafAdmissionFailure.rejected
        }
        var result = Data(count: expectedSize)
        var offset = 0
        try result.withUnsafeMutableBytes { raw in
            guard let base = raw.baseAddress else {
                throw PrimeR19NativeLeafAdmissionFailure.rejected
            }
            while offset < raw.count {
                let count = pread(
                    descriptor,
                    base.advanced(by: offset),
                    raw.count - offset,
                    off_t(offset)
                )
                if count < 0, errno == EINTR {
                    continue
                }
                guard count > 0 else {
                    throw PrimeR19NativeLeafAdmissionFailure.rejected
                }
                offset += count
            }
        }
        var trailing: UInt8 = 0
        let trailingCount = pread(
            descriptor,
            &trailing,
            1,
            off_t(expectedSize)
        )
        guard trailingCount == 0 else {
            throw PrimeR19NativeLeafAdmissionFailure.rejected
        }
        return result
    }

    private static func requireMachOIdentity(_ bytes: Data) throws {
        guard bytes.count == definitiveImageBytes,
              try readUInt32LittleEndian(bytes, at: 0) == 0xFEED_FACF,
              try readUInt32LittleEndian(bytes, at: 4) == 0x0100_000C,
              try readUInt32LittleEndian(bytes, at: 8) == 0,
              try readUInt32LittleEndian(bytes, at: 12) == 2,
              try readUInt32LittleEndian(bytes, at: 16) == 28,
              try readUInt32LittleEndian(bytes, at: 20) == 2_928
        else {
            throw PrimeR19NativeLeafAdmissionFailure.rejected
        }

        let commandEnd = 32 + 2_928
        var cursor = 32
        var uuidCount = 0
        var buildVersionCount = 0
        var codeSignatureCount = 0
        var codeSignatureOffset = 0
        var codeSignatureSize = 0

        for _ in 0..<28 {
            let command = try readUInt32LittleEndian(bytes, at: cursor)
            let commandSize = Int(
                try readUInt32LittleEndian(bytes, at: cursor + 4)
            )
            guard commandSize >= 8,
                  commandSize % 8 == 0,
                  cursor <= commandEnd - commandSize
            else {
                throw PrimeR19NativeLeafAdmissionFailure.rejected
            }

            switch command {
            case 0x1B:
                guard commandSize == 24,
                      Array(bytes[(cursor + 8)..<(cursor + 24)]) ==
                          definitiveImageUUID
                else {
                    throw PrimeR19NativeLeafAdmissionFailure.rejected
                }
                uuidCount += 1
            case 0x32:
                guard commandSize == 32,
                      try readUInt32LittleEndian(bytes, at: cursor + 8) == 1,
                      try readUInt32LittleEndian(bytes, at: cursor + 12) ==
                          0x000E_0000,
                      try readUInt32LittleEndian(bytes, at: cursor + 16) ==
                          0x001A_0500,
                      try readUInt32LittleEndian(bytes, at: cursor + 20) == 1,
                      try readUInt32LittleEndian(bytes, at: cursor + 24) == 3,
                      try readUInt32LittleEndian(bytes, at: cursor + 28) ==
                          0x04F3_0000
                else {
                    throw PrimeR19NativeLeafAdmissionFailure.rejected
                }
                buildVersionCount += 1
            case 0x1D:
                guard commandSize == 16 else {
                    throw PrimeR19NativeLeafAdmissionFailure.rejected
                }
                codeSignatureOffset = Int(
                    try readUInt32LittleEndian(bytes, at: cursor + 8)
                )
                codeSignatureSize = Int(
                    try readUInt32LittleEndian(bytes, at: cursor + 12)
                )
                codeSignatureCount += 1
            default:
                break
            }
            cursor += commandSize
        }

        guard cursor == commandEnd,
              uuidCount == 1,
              buildVersionCount == 1,
              codeSignatureCount == 1,
              codeSignatureOffset == 89_120,
              codeSignatureSize == 856
        else {
            throw PrimeR19NativeLeafAdmissionFailure.rejected
        }
        try requireEmbeddedCodeDirectory(
            bytes,
            signatureOffset: codeSignatureOffset,
            signatureSize: codeSignatureSize
        )
    }

    private static func requireEmbeddedCodeDirectory(
        _ bytes: Data,
        signatureOffset: Int,
        signatureSize: Int
    ) throws {
        guard signatureOffset >= 0,
              signatureSize == 856,
              signatureOffset <= bytes.count - signatureSize,
              try readUInt32BigEndian(bytes, at: signatureOffset) ==
                  0xFADE_0CC0,
              try readUInt32BigEndian(bytes, at: signatureOffset + 4) == 854,
              try readUInt32BigEndian(bytes, at: signatureOffset + 8) == 1,
              try readUInt32BigEndian(bytes, at: signatureOffset + 12) == 0,
              try readUInt32BigEndian(bytes, at: signatureOffset + 16) == 20,
              bytes[(signatureOffset + 854)..<(signatureOffset + 856)]
                  .allSatisfy({ $0 == 0 })
        else {
            throw PrimeR19NativeLeafAdmissionFailure.rejected
        }

        let codeDirectoryOffset = signatureOffset + 20
        let codeDirectoryLength = 834
        guard try readUInt32BigEndian(bytes, at: codeDirectoryOffset) ==
                  0xFADE_0C02,
              try readUInt32BigEndian(bytes, at: codeDirectoryOffset + 4) ==
                  UInt32(codeDirectoryLength),
              try readUInt32BigEndian(bytes, at: codeDirectoryOffset + 8) ==
                  0x0002_0400,
              try readUInt32BigEndian(bytes, at: codeDirectoryOffset + 12) ==
                  0x0002_0002,
              try readUInt32BigEndian(bytes, at: codeDirectoryOffset + 24) ==
                  0,
              try readUInt32BigEndian(bytes, at: codeDirectoryOffset + 28) ==
                  22,
              try readUInt32BigEndian(bytes, at: codeDirectoryOffset + 32) ==
                  UInt32(signatureOffset),
              bytes[codeDirectoryOffset + 36] == 32,
              bytes[codeDirectoryOffset + 37] == 2,
              bytes[codeDirectoryOffset + 39] == 12
        else {
            throw PrimeR19NativeLeafAdmissionFailure.rejected
        }

        let hashOffset = Int(
            try readUInt32BigEndian(bytes, at: codeDirectoryOffset + 16)
        )
        let identifierOffset = Int(
            try readUInt32BigEndian(bytes, at: codeDirectoryOffset + 20)
        )
        let expectedIdentifier =
            Data("PrimeDriverV2R19NativeLeafPrimitiveCanary\0".utf8)
        let identifierStart = codeDirectoryOffset + identifierOffset
        let identifierEnd = identifierStart + expectedIdentifier.count
        guard identifierOffset >= 0,
              identifierOffset <= codeDirectoryLength - expectedIdentifier.count,
              bytes[identifierStart ..< identifierEnd] == expectedIdentifier,
              hashOffset >= 0,
              hashOffset <= codeDirectoryLength - (22 * 32)
        else {
            throw PrimeR19NativeLeafAdmissionFailure.rejected
        }

        let codeDirectory = Data(
            bytes[codeDirectoryOffset..<(codeDirectoryOffset +
                                        codeDirectoryLength)]
        )
        guard sha256Hex(codeDirectory) ==
                  definitiveImageCodeDirectorySHA256
        else {
            throw PrimeR19NativeLeafAdmissionFailure.rejected
        }

        for slot in 0..<22 {
            let pageStart = slot * 4_096
            let pageEnd = min(pageStart + 4_096, signatureOffset)
            guard pageStart < pageEnd else {
                throw PrimeR19NativeLeafAdmissionFailure.rejected
            }
            let observedHash = Data(
                SHA256.hash(data: Data(bytes[pageStart..<pageEnd]))
            )
            let expectedHashStart =
                codeDirectoryOffset + hashOffset + (slot * 32)
            let expectedHashEnd = expectedHashStart + 32
            guard expectedHashEnd <= codeDirectoryOffset + codeDirectoryLength,
                  bytes[expectedHashStart..<expectedHashEnd] == observedHash
            else {
                throw PrimeR19NativeLeafAdmissionFailure.rejected
            }
        }
    }

    private static func readUInt32LittleEndian(
        _ bytes: Data,
        at offset: Int
    ) throws -> UInt32 {
        guard offset >= 0, offset <= bytes.count - 4 else {
            throw PrimeR19NativeLeafAdmissionFailure.rejected
        }
        return UInt32(bytes[offset]) |
            (UInt32(bytes[offset + 1]) << 8) |
            (UInt32(bytes[offset + 2]) << 16) |
            (UInt32(bytes[offset + 3]) << 24)
    }

    private static func readUInt32BigEndian(
        _ bytes: Data,
        at offset: Int
    ) throws -> UInt32 {
        guard offset >= 0, offset <= bytes.count - 4 else {
            throw PrimeR19NativeLeafAdmissionFailure.rejected
        }
        return (UInt32(bytes[offset]) << 24) |
            (UInt32(bytes[offset + 1]) << 16) |
            (UInt32(bytes[offset + 2]) << 8) |
            UInt32(bytes[offset + 3])
    }

    private static func canonicalCanaryFrame(
        rootMetadata: stat,
        leafMetadata: stat
    ) throws -> Data {
        let payload =
            "{" +
            "\"authority_closure_authorized\":false," +
            "\"authority_vector\":\"00000000\"," +
            "\"canary_root\":\"\(canaryRootPath)\"," +
            "\"file_cap_bytes\":\(canaryFileCap)," +
            "\"fixed_leaf\":\"\(canaryLeaf)\"," +
            "\"gate_e_clearance\":0," +
            "\"gate_e_mechanics_outcome\":\"ABSTAIN\"," +
            "\"gate_e_promotion_authorized\":false," +
            "\"gate_e_scientific_outcome\":\"ABSTAIN\"," +
            "\"initial_mode\":\"0000\"," +
            "\"leaf_device\":\(leafMetadata.st_dev)," +
            "\"leaf_inode\":\(leafMetadata.st_ino)," +
            "\"native_boundary\":\"in_image_fixed_arity_c_wrapper\"," +
            "\"outer_admission_required\":true," +
            "\"publication_mode\":\"0400\"," +
            "\"root_device\":\(rootMetadata.st_dev)," +
            "\"root_inode\":\(rootMetadata.st_ino)," +
            "\"schema\":\"prime_driver_v2_r19_native_leaf_primitive_canary_v1\"," +
            "\"scientific_authorities_closed\":0," +
            "\"status\":\"R19_NATIVE_FIXED_ARITY_LEAF_PRIMITIVE_CANDIDATE\"" +
            "}"
        let payloadBytes = Data(payload.utf8)
        let frame =
            "{\"payload\":\(payload)," +
            "\"payload_sha256\":\"\(sha256Hex(payloadBytes))\"}\n"
        let bytes = Data(frame.utf8)
        guard !bytes.isEmpty,
              bytes.count <= canaryFileCap,
              bytes.last == 0x0A
        else {
            throw PrimeR19NativeLeafAdmissionFailure.rejected
        }
        return bytes
    }

    private static func canonicalAuditorFrame(
        canaryFrame: Data,
        rootMetadata: stat,
        leafMetadata: stat
    ) throws -> Data {
        let payload =
            "{" +
            "\"authority_vector\":\"00000000\"," +
            "\"canary_frame_bytes\":\(canaryFrame.count)," +
            "\"canary_frame_sha256\":\"\(sha256Hex(canaryFrame))\"," +
            "\"canary_root\":\"\(canaryRootPath)\"," +
            "\"definitive_image_sha256\":\"\(definitiveImageSHA256)\"," +
            "\"gate_e_clearance\":0," +
            "\"gate_e_mechanics_outcome\":\"ABSTAIN\"," +
            "\"gate_e_scientific_outcome\":\"ABSTAIN\"," +
            "\"leaf_device\":\(leafMetadata.st_dev)," +
            "\"leaf_inode\":\(leafMetadata.st_ino)," +
            "\"root_device\":\(rootMetadata.st_dev)," +
            "\"root_inode\":\(rootMetadata.st_ino)," +
            "\"schema\":\"prime_driver_v2_r19_native_leaf_admission_candidate_v1\"," +
            "\"scientific_authorities_closed\":0," +
            "\"status\":\"R19_NATIVE_FIXED_ARITY_LEAF_ADMISSION_PASS_CANDIDATE\"" +
            "}"
        let payloadBytes = Data(payload.utf8)
        let frame =
            "{\"payload\":\(payload)," +
            "\"payload_sha256\":\"\(sha256Hex(payloadBytes))\"}\n"
        let bytes = Data(frame.utf8)
        guard !bytes.isEmpty,
              bytes.count <= auditorFrameCap,
              bytes.last == 0x0A
        else {
            throw PrimeR19NativeLeafAdmissionFailure.rejected
        }
        return bytes
    }

    private static func sha256Hex(_ bytes: Data) -> String {
        let alphabet = Array("0123456789abcdef".utf8)
        var encoded = [UInt8]()
        encoded.reserveCapacity(64)
        for byte in SHA256.hash(data: bytes) {
            encoded.append(alphabet[Int(byte >> 4)])
            encoded.append(alphabet[Int(byte & 0x0F)])
        }
        return String(decoding: encoded, as: UTF8.self)
    }
}

@main
private struct PrimeDriverV2R19NativeLeafAdmission {
    static func main() {
        do {
            let candidate = try PrimeR19NativeLeafAdmission.prepareCandidateFrame()
            guard fcntl(STDOUT_FILENO, F_SETNOSIGPIPE, 1) == 0 else {
                Darwin._exit(70)
            }
            let written = candidate.withUnsafeBytes { raw in
                guard let base = raw.baseAddress else {
                    return -1
                }
                return Darwin.write(STDOUT_FILENO, base, raw.count)
            }
            guard written == candidate.count else {
                Darwin._exit(70)
            }
            Darwin._exit(0)
        } catch {
            Darwin._exit(70)
        }
    }
}
