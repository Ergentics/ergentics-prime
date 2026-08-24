// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CryptoKit
import Darwin
import Foundation

private enum PrimeR19NativeLeafFailure: Error {
    case rejected
}

private struct PrimeR19NativeLeafIdentity: Equatable {
    let device: dev_t
    let inode: ino_t
}

private enum PrimeR19NativeLeafPrimitive {
    static let privateTmpPath = "/private/tmp"
    static let rootLeaf =
        "gate-e1-4-r19-native-leaf-primitive-canary-3a46a037-17452840"
    static let rootPath = privateTmpPath + "/" + rootLeaf
    static let fixedLeaf = "00-native-leaf-canary.json"
    static let fileCap = 16_384

    static func run() throws {
        guard CommandLine.argc == 1 else {
            throw PrimeR19NativeLeafFailure.rejected
        }

        _ = umask(mode_t(0o077))

        let privateTmp = Darwin.open(
            privateTmpPath,
            O_RDONLY | O_DIRECTORY | O_NOFOLLOW_ANY | O_CLOEXEC
        )
        guard privateTmp >= 3 else {
            throw PrimeR19NativeLeafFailure.rejected
        }
        defer { _ = Darwin.close(privateTmp) }

        let privateTmpMetadata = try requirePrivateTmp(privateTmp)
        guard rootLeaf.withCString({
            mkdirat(privateTmp, $0, mode_t(0o700))
        }) == 0 else {
            // EEXIST and every other failure consume a future invocation;
            // no existing namespace is opened, repaired, or reused.
            throw PrimeR19NativeLeafFailure.rejected
        }

        let root = rootLeaf.withCString {
            Darwin.openat(
                privateTmp,
                $0,
                O_RDONLY | O_DIRECTORY | O_NOFOLLOW_ANY | O_CLOEXEC
            )
        }
        guard root >= 3 else {
            throw PrimeR19NativeLeafFailure.rejected
        }
        defer { _ = Darwin.close(root) }

        let rootMetadata = try requireRoot(
            root,
            privateTmp: privateTmp,
            privateTmpMetadata: privateTmpMetadata
        )
        try requireInventory(root, exactLeaf: nil)
        try fullSync(root)
        try fullSync(privateTmp)

        let leaf = fixedLeaf.withCString {
            prime_driver_v2_r19_create_exclusive_poisoned_leaf(root, $0)
        }
        guard leaf >= 3 else {
            throw PrimeR19NativeLeafFailure.rejected
        }
        defer { _ = Darwin.close(leaf) }

        let initial = try requireLeaf(
            leaf,
            parent: root,
            parentMetadata: rootMetadata,
            expectedIdentity: nil,
            expectedMode: mode_t(0o000),
            expectedSize: 0
        )
        let initialIdentity = PrimeR19NativeLeafIdentity(
            device: initial.st_dev,
            inode: initial.st_ino
        )
        try requireInventory(root, exactLeaf: fixedLeaf)

        let bytes = try canonicalRecord(
            rootMetadata: rootMetadata,
            leafMetadata: initial
        )
        try writeAll(bytes, descriptor: leaf)
        try requireReadback(bytes, descriptor: leaf)
        _ = try requireLeaf(
            leaf,
            parent: root,
            parentMetadata: rootMetadata,
            expectedIdentity: initialIdentity,
            expectedMode: mode_t(0o000),
            expectedSize: bytes.count
        )
        try fullSync(leaf)

        // This is the sole affine publication transition. A failure before
        // this call retains a mode-0000 poison. A failure or crash after the
        // call may retain a mode-0400 incomplete candidate; mode alone never
        // establishes success without exit zero and outer re-admission.
        guard fchmod(leaf, mode_t(0o400)) == 0 else {
            throw PrimeR19NativeLeafFailure.rejected
        }

        _ = try requireLeaf(
            leaf,
            parent: root,
            parentMetadata: rootMetadata,
            expectedIdentity: initialIdentity,
            expectedMode: mode_t(0o400),
            expectedSize: bytes.count
        )
        try requireReadback(bytes, descriptor: leaf)
        try requireInventory(root, exactLeaf: fixedLeaf)
        _ = try requireRoot(
            root,
            privateTmp: privateTmp,
            privateTmpMetadata: privateTmpMetadata
        )
        _ = try requireLeaf(
            leaf,
            parent: root,
            parentMetadata: rootMetadata,
            expectedIdentity: initialIdentity,
            expectedMode: mode_t(0o400),
            expectedSize: bytes.count
        )
        try fullSync(leaf)
        try fullSync(root)
    }

    private static func requirePrivateTmp(_ descriptor: Int32) throws -> stat {
        try requireCloseOnExec(descriptor)
        var metadata = stat()
        guard fstat(descriptor, &metadata) == 0,
              metadata.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
              metadata.st_uid == 0,
              metadata.st_gid == 0,
              metadata.st_mode & mode_t(0o7777) == mode_t(0o1777)
        else {
            throw PrimeR19NativeLeafFailure.rejected
        }

        var filesystem = statfs()
        guard fstatfs(descriptor, &filesystem) == 0,
              filesystem.f_flags & UInt32(MNT_LOCAL) != 0
        else {
            throw PrimeR19NativeLeafFailure.rejected
        }
        var typeField = filesystem.f_fstypename
        let typeBytes = withUnsafeBytes(of: &typeField) {
            Array($0.prefix { $0 != 0 })
        }
        guard typeBytes == Array("apfs".utf8) else {
            throw PrimeR19NativeLeafFailure.rejected
        }
        return metadata
    }

    private static func requireRoot(
        _ descriptor: Int32,
        privateTmp: Int32,
        privateTmpMetadata: stat
    ) throws -> stat {
        try requireCloseOnExec(descriptor)
        var held = stat()
        var named = stat()
        guard fstat(descriptor, &held) == 0,
              rootLeaf.withCString({
                  fstatat(privateTmp, $0, &named, AT_SYMLINK_NOFOLLOW)
              }) == 0,
              held.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
              named.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
              held.st_dev == privateTmpMetadata.st_dev,
              held.st_dev == named.st_dev,
              held.st_ino != 0,
              held.st_ino == named.st_ino,
              held.st_uid == geteuid(),
              held.st_gid == privateTmpMetadata.st_gid,
              held.st_mode & mode_t(0o7777) == mode_t(0o700),
              held.st_flags == 0,
              named.st_flags == 0
        else {
            throw PrimeR19NativeLeafFailure.rejected
        }
        return held
    }

    private static func requireLeaf(
        _ descriptor: Int32,
        parent: Int32,
        parentMetadata: stat,
        expectedIdentity: PrimeR19NativeLeafIdentity?,
        expectedMode: mode_t,
        expectedSize: Int
    ) throws -> stat {
        try requireCloseOnExec(descriptor)
        var held = stat()
        var named = stat()
        guard fstat(descriptor, &held) == 0,
              fixedLeaf.withCString({
                  fstatat(parent, $0, &named, AT_SYMLINK_NOFOLLOW)
              }) == 0,
              held.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
              named.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
              held.st_dev == parentMetadata.st_dev,
              held.st_dev == named.st_dev,
              held.st_ino != 0,
              held.st_ino == named.st_ino,
              held.st_uid == geteuid(),
              held.st_gid == parentMetadata.st_gid,
              held.st_nlink == 1,
              named.st_nlink == 1,
              held.st_flags == 0,
              named.st_flags == 0,
              held.st_mode & mode_t(0o7777) == expectedMode,
              named.st_mode & mode_t(0o7777) == expectedMode,
              held.st_size == off_t(expectedSize),
              named.st_size == off_t(expectedSize)
        else {
            throw PrimeR19NativeLeafFailure.rejected
        }
        if let expectedIdentity {
            guard expectedIdentity == PrimeR19NativeLeafIdentity(
                device: held.st_dev,
                inode: held.st_ino
            ) else {
                throw PrimeR19NativeLeafFailure.rejected
            }
        }
        return held
    }

    private static func requireCloseOnExec(_ descriptor: Int32) throws {
        guard descriptor >= 3 else {
            throw PrimeR19NativeLeafFailure.rejected
        }
        let flags = fcntl(descriptor, F_GETFD)
        guard flags >= 0,
              flags & FD_CLOEXEC != 0
        else {
            throw PrimeR19NativeLeafFailure.rejected
        }
    }

    private static func requireInventory(
        _ descriptor: Int32,
        exactLeaf: String?
    ) throws {
        let independent = Darwin.openat(
            descriptor,
            ".",
            O_RDONLY | O_DIRECTORY | O_NOFOLLOW_ANY | O_CLOEXEC
        )
        guard independent >= 3,
              let directory = fdopendir(independent)
        else {
            if independent >= 0 {
                _ = Darwin.close(independent)
            }
            throw PrimeR19NativeLeafFailure.rejected
        }
        defer { _ = closedir(directory) }

        let expected = exactLeaf.map { Data($0.utf8) }
        var observed: Data?
        while true {
            errno = 0
            guard let pointer = readdir(directory) else {
                guard errno == 0 else {
                    throw PrimeR19NativeLeafFailure.rejected
                }
                break
            }
            let entry = pointer.pointee
            let length = Int(entry.d_namlen)
            guard length > 0, length <= Int(MAXNAMLEN) else {
                throw PrimeR19NativeLeafFailure.rejected
            }
            var nameField = entry.d_name
            let name = withUnsafeBytes(of: &nameField) {
                Data($0.prefix(length))
            }
            if name == Data(".".utf8) || name == Data("..".utf8) {
                continue
            }
            guard observed == nil else {
                throw PrimeR19NativeLeafFailure.rejected
            }
            observed = name
        }
        guard observed == expected else {
            throw PrimeR19NativeLeafFailure.rejected
        }
    }

    private static func canonicalRecord(
        rootMetadata: stat,
        leafMetadata: stat
    ) throws -> Data {
        let payload =
            "{" +
            "\"authority_closure_authorized\":false," +
            "\"authority_vector\":\"00000000\"," +
            "\"canary_root\":\"\(rootPath)\"," +
            "\"file_cap_bytes\":\(fileCap)," +
            "\"fixed_leaf\":\"\(fixedLeaf)\"," +
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
        let payloadSHA256 = sha256Hex(payloadBytes)
        let frame =
            "{\"payload\":\(payload)," +
            "\"payload_sha256\":\"\(payloadSHA256)\"}\n"
        let bytes = Data(frame.utf8)
        guard !bytes.isEmpty,
              bytes.count <= fileCap,
              bytes.last == 0x0A
        else {
            throw PrimeR19NativeLeafFailure.rejected
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

    private static func writeAll(
        _ bytes: Data,
        descriptor: Int32
    ) throws {
        try bytes.withUnsafeBytes { raw in
            guard let base = raw.baseAddress else {
                throw PrimeR19NativeLeafFailure.rejected
            }
            var offset = 0
            while offset < raw.count {
                let written = pwrite(
                    descriptor,
                    base.advanced(by: offset),
                    raw.count - offset,
                    off_t(offset)
                )
                if written < 0, errno == EINTR {
                    continue
                }
                guard written > 0 else {
                    throw PrimeR19NativeLeafFailure.rejected
                }
                offset += written
            }
        }
    }

    private static func requireReadback(
        _ expected: Data,
        descriptor: Int32
    ) throws {
        var result = Data(count: expected.count)
        var offset = 0
        try result.withUnsafeMutableBytes { raw in
            guard let base = raw.baseAddress else {
                throw PrimeR19NativeLeafFailure.rejected
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
                    throw PrimeR19NativeLeafFailure.rejected
                }
                offset += count
            }
        }
        var trailing: UInt8 = 0
        let trailingCount = pread(
            descriptor,
            &trailing,
            1,
            off_t(expected.count)
        )
        guard trailingCount == 0,
              result == expected,
              SHA256.hash(data: result) == SHA256.hash(data: expected)
        else {
            throw PrimeR19NativeLeafFailure.rejected
        }
    }

    private static func fullSync(_ descriptor: Int32) throws {
        guard fsync(descriptor) == 0,
              fcntl(descriptor, F_FULLFSYNC) == 0
        else {
            throw PrimeR19NativeLeafFailure.rejected
        }
    }
}

@main
private struct PrimeDriverV2R19NativeLeafPrimitiveCanary {
    static func main() {
        do {
            try PrimeR19NativeLeafPrimitive.run()
            Darwin._exit(0)
        } catch {
            Darwin._exit(70)
        }
    }
}
