// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin
import Foundation
import PrimeCore
import PrimeNativeDecoderCheckpoint

/// Current-local science; the process controller separately binds the actual
/// source, images, library, process lifetimes and strict device lease. This
/// entry does not admit the retired hosted launcher or mint its receipts.
public enum PrimeNativeDecoderCurrentLocalNative300MExecution {
    public static let baselineResultFileName = "stage7-baseline.json"
    public static let stage7ResultFileName = "stage7-result.json"
    public static let stage8ResultFileName = "stage8-result.json"
    public static let parameterCount: UInt64 = 271_107_072
    public static let vocabularySize = 512
    public static let modelSeed: UInt64 = 44
    public static let maximumResultByteCount = 4 * 1024 * 1024
    public static let requiredArtifactPaths =
        PrimeNativeDecoderNative300MTrajectoryCheckpointSetRoleV1.allCases.flatMap { role in
            ["weights.safetensors", "optimizer_moments.safetensors",
             "control_state.json", "commit.json"].map { role.rawValue + "/" + $0 }
        }
}

/// Per-set captures avoid the generic inventory's 8-GiB aggregate ceiling:
/// the real three-set experiment exceeds it. Each set keeps the existing
/// checkpoint verifier and its descriptor/content/metadata guards unchanged.
final class PrimeCurrentLocalNative300MRetainedInventory {
    private let root: PrimeArtifactRoot
    private let descriptor: Int32
    private let identity: PrimeArtifactRootIdentity
    private let directories: [String]
    private let captures: [PrimeTrustedArtifactInventoryCapture]

    init(root: PrimeArtifactRoot,
         bindings: [PrimeNativeDecoderNative300MTrajectoryExternalCommitBindingV1]) throws {
        self.root = root
        try root.requirePrivateRootMode()
        let roles = PrimeNativeDecoderNative300MTrajectoryCheckpointSetRoleV1.allCases
        guard bindings.count == 2 || bindings.count == 3,
              bindings.map(\.setRole) == Array(roles.prefix(bindings.count)) else {
            throw Failure.rejected("retained checkpoint roles")
        }
        identity = try root.verifiedRootIdentity()
        directories = bindings.map(\.directory).sorted()
        let fd = open(root.directoryURL.path, O_RDONLY | O_DIRECTORY | O_NOFOLLOW_ANY | O_CLOEXEC)
        guard fd >= 0 else { throw Failure.rejected("retained root open") }
        descriptor = fd
        do {
            try Self.join(fd, identity: identity)
            try Self.requireNames(fd, names: directories)
            var held: [PrimeTrustedArtifactInventoryCapture] = []
            for binding in bindings {
                try PrimeNativeDecoderNative300MTrajectoryCheckpointV1.validateExternalBinding(binding)
                try PrimeNativeDecoderNative300MTrajectoryCheckpointV1.verify(root: root, externalCommitBinding: binding)
                held.append(try root.captureTrustedInventory(rolePrefix: binding.directory,
                    expectedArtifacts: binding.orderedLeafBindings.map(\.artifact)))
            }
            captures = held
            try Self.join(fd, identity: identity)
            try Self.requireNames(fd, names: directories)
            guard try root.verifiedRootIdentity() == identity else {
                throw Failure.rejected("retained root changed during capture")
            }
        } catch {
            close(fd)
            throw error
        }
    }

    deinit { close(descriptor) }

    func revalidate() throws {
        try Self.join(descriptor, identity: identity)
        try joinNamedRoot()
        guard try root.verifiedRootIdentity() == identity else {
            throw Failure.rejected("retained root changed")
        }
        try Self.requireNames(descriptor, names: directories)
        for capture in captures { _ = try capture.recaptureAndValidateUnchanged() }
        try Self.join(descriptor, identity: identity)
        try Self.requireNames(descriptor, names: directories)
        try joinNamedRoot()
        guard try root.verifiedRootIdentity() == identity else {
            throw Failure.rejected("retained root changed after verification")
        }
    }

    private func joinNamedRoot() throws {
        let named = open(root.directoryURL.path, O_RDONLY | O_DIRECTORY | O_NOFOLLOW_ANY | O_CLOEXEC)
        guard named >= 0 else { throw Failure.rejected("retained root named rejoin") }
        defer { close(named) }
        try Self.join(named, identity: identity)
    }

    private static func join(_ fd: Int32, identity: PrimeArtifactRootIdentity) throws {
        var value = stat()
        guard fstat(fd, &value) == 0, value.st_mode & S_IFMT == S_IFDIR,
              UInt64(bitPattern: Int64(value.st_dev)) == identity.deviceID, UInt64(value.st_ino) == identity.inode,
              value.st_uid == identity.ownerUserID, value.st_gid == identity.ownerGroupID,
              value.st_mode & 0o777 == identity.actualMode, UInt64(value.st_nlink) == identity.linkCount,
              Int64(value.st_mtimespec.tv_sec) == identity.modificationSeconds,
              Int64(value.st_mtimespec.tv_nsec) == identity.modificationNanoseconds,
              Int64(value.st_ctimespec.tv_sec) == identity.statusChangeSeconds,
              Int64(value.st_ctimespec.tv_nsec) == identity.statusChangeNanoseconds else {
            throw Failure.rejected("retained named/held root identity")
        }
    }

    private static func requireNames(_ fd: Int32, names: [String]) throws {
        let copy = fcntl(fd, F_DUPFD_CLOEXEC, 3)
        guard copy >= 3 else { throw Failure.rejected("retained root descriptor copy") }
        guard lseek(copy, 0, SEEK_SET) >= 0, let stream = fdopendir(copy) else {
            close(copy); throw Failure.rejected("retained root enumeration")
        }
        defer { closedir(stream) }
        var observed: [String] = []
        errno = 0
        while let entry = readdir(stream) {
            let name = withUnsafePointer(to: entry.pointee.d_name) {
                $0.withMemoryRebound(to: CChar.self, capacity: Int(MAXNAMLEN) + 1) { String(cString: $0) }
            }
            if name != "." && name != ".." { observed.append(name) }
            guard observed.count <= 3 else { throw Failure.rejected("unexpected retained root entry") }
            errno = 0
        }
        guard errno == 0, observed.sorted() == names else {
            throw Failure.rejected("retained root exact inventory")
        }
    }

    enum Failure: Error { case rejected(String) }
}
