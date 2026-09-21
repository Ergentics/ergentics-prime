// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin
import Dispatch
import Foundation

/// Fixed, source-sealed bare repositories replace only the two locked remote
/// locations. This helper creates no child, credentials, environment overlay,
/// build authority, or mutable dependency source.
final class PrimeValidationDriverV2LockedDependencies {
    static let sourcePrefix = "Tests/PrimeValidationWorkflow/Fixtures/LockedDependencies"
    static let mirrorPath = "config/mirrors.json"
    private static let maximumOperationNanoseconds: UInt64 = 30_000_000_000
    private let source: Tree
    private let mirrors: Tree
    private let workspaceRoot: PrimeArtifactRoot
    private let mirrorBinding: PrimeArtifactBinding
    private let lock = NSLock()
    private var poisoned = false

    struct Specification {
        let path: String
        let count: UInt64
        let hash: String
    }

    // Literal content pins cover the reachable Git histories, index files,
    // locked refs and the no-hooks/no-remotes bare repository configuration.
    static let specifications: [Specification] = [
        .init(path: "Tests/PrimeValidationWorkflow/Fixtures/LockedDependencies/ergentics-mlx-swift/HEAD", count: 23,
              hash: "b424db4ffe076ceb6875fad3c1ec1f99c26ac889ebda62f93585dba8c7a6b413"),
        .init(path: "Tests/PrimeValidationWorkflow/Fixtures/LockedDependencies/ergentics-mlx-swift/config", count: 75,
              hash: "48ba82d2a34cec9d5195eab7c5b08caf195c4e0dd1883f94967c9fc8eb13816d"),
        .init(path: "Tests/PrimeValidationWorkflow/Fixtures/LockedDependencies/ergentics-mlx-swift/objects/pack/pack-377fb9931fc0329ae17cc200ffe1ce7ea15c6e9d.idx", count: 155576,
              hash: "df4399009559031a098d8f4c404fa5c6d609b22c7f2e32a57c2d925cc3e44384"),
        .init(path: "Tests/PrimeValidationWorkflow/Fixtures/LockedDependencies/ergentics-mlx-swift/objects/pack/pack-377fb9931fc0329ae17cc200ffe1ce7ea15c6e9d.pack", count: 3965470,
              hash: "82912fbacda2cb0ec7ab7825af47215cd1dc75d81722f44a87f1202cd5e9e08a"),
        .init(path: "Tests/PrimeValidationWorkflow/Fixtures/LockedDependencies/ergentics-mlx-swift/objects/pack/pack-377fb9931fc0329ae17cc200ffe1ce7ea15c6e9d.rev", count: 22124,
              hash: "bf7029e08b6d69e386666b5832340176af337b256ba7f19da8cd967557e27aa2"),
        .init(path: "Tests/PrimeValidationWorkflow/Fixtures/LockedDependencies/ergentics-mlx-swift/refs/heads/locked", count: 41,
              hash: "8482a78ce367764ac6fb5ce07be4b00101c305022a19109f081935d09de8716f"),
        .init(path: "Tests/PrimeValidationWorkflow/Fixtures/LockedDependencies/swift-numerics/HEAD", count: 23,
              hash: "b424db4ffe076ceb6875fad3c1ec1f99c26ac889ebda62f93585dba8c7a6b413"),
        .init(path: "Tests/PrimeValidationWorkflow/Fixtures/LockedDependencies/swift-numerics/config", count: 75,
              hash: "48ba82d2a34cec9d5195eab7c5b08caf195c4e0dd1883f94967c9fc8eb13816d"),
        .init(path: "Tests/PrimeValidationWorkflow/Fixtures/LockedDependencies/swift-numerics/objects/pack/pack-6a50bf407e41fc67443de10b529bf7faf7c0c020.idx", count: 68384,
              hash: "3d766935591b38e2d4afd54c5c6bbcd6b535f55a886a2a392997bb4a95252c54"),
        .init(path: "Tests/PrimeValidationWorkflow/Fixtures/LockedDependencies/swift-numerics/objects/pack/pack-6a50bf407e41fc67443de10b529bf7faf7c0c020.pack", count: 659500,
              hash: "3d530b0a4d60551671410bfbf64d0c7a756f6524bf384936b963837dac0e42dd"),
        .init(path: "Tests/PrimeValidationWorkflow/Fixtures/LockedDependencies/swift-numerics/objects/pack/pack-6a50bf407e41fc67443de10b529bf7faf7c0c020.rev", count: 9668,
              hash: "e994e01ba968ec664311d057aca11fd4afa09502bf0dca52f89811c5ff5310f0"),
        .init(path: "Tests/PrimeValidationWorkflow/Fixtures/LockedDependencies/swift-numerics/refs/heads/locked", count: 41,
              hash: "d462f34670b57c60523a9c4c568ee8e93491b80b52d09d042276f901e408fed4"),
        .init(path: "Tests/PrimeValidationWorkflow/Fixtures/LockedDependencies/swift-numerics/refs/tags/1.1.1", count: 41,
              hash: "d462f34670b57c60523a9c4c568ee8e93491b80b52d09d042276f901e408fed4"),
    ]

    private init(source: Tree, mirrors: Tree, workspaceRoot: PrimeArtifactRoot,
                 mirrorBinding: PrimeArtifactBinding) {
        self.source = source; self.mirrors = mirrors
        self.workspaceRoot = workspaceRoot; self.mirrorBinding = mirrorBinding
    }

    static func prepare(admission: PrimeValidationSwiftPMRetainedAdmissionState,
                        context: PrimeValidationDriverV2RoleContext,
                        workspaceRoot: PrimeArtifactRoot) throws -> PrimeValidationDriverV2LockedDependencies {
        guard context.repositoryRootAbsolutePath == admission.primeRepository.root.directoryURL.path,
              context.workspaceRootAbsolutePath == workspaceRoot.directoryURL.path else {
            throw rejected("root_context")
        }
        return try prepare(primeRoot: admission.primeRepository.root,
            sourceSnapshot: admission.sourceSnapshot, workspaceRoot: workspaceRoot,
            primeRootAbsolutePath: context.repositoryRootAbsolutePath)
    }

    /// Internal filesystem entry for bounded tests; it cannot mint a build
    /// owner. Production supplies the roots and snapshot retained through E.
    static func prepare(primeRoot: PrimeArtifactRoot, sourceSnapshot: PrimeSwiftSourceSnapshot,
                        workspaceRoot: PrimeArtifactRoot, primeRootAbsolutePath: String) throws
        -> PrimeValidationDriverV2LockedDependencies {
        let deadline = try operationDeadline()
        try validateSnapshot(sourceSnapshot)
        guard primeRoot.directoryURL.path == primeRootAbsolutePath else { throw rejected("prime_path") }
        let sourceFD = try primeRoot.duplicateTrustedRootDescriptorForInventory()
        defer { close(sourceFD) }
        let source = try Tree(rootDescriptor: sourceFD, specifications: specifications,
                              exactBelow: sourcePrefix, immutable: false, deadline: deadline)
        let data = try mirrorsData(primeRootAbsolutePath: primeRootAbsolutePath)
        try workspaceRoot.requirePrivateRootMode()
        try workspaceRoot.requireAbsent(at: mirrorPath)
        let workspaceFD = try workspaceRoot.duplicateTrustedRootDescriptorForInventory()
        defer { close(workspaceFD) }
        let configFD = try opened(openat(workspaceFD, "config",
            O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC))
        defer { close(configFD) }
        try PrimeArtifactRoot.requireTrustedInventoryDirectoryDescriptor(configFD, path: "config")
        let originalConfig = try status(configFD)
        guard originalConfig.st_mode & 0o7777 == 0o700,
              try names(configFD).isEmpty else { throw rejected("config_not_private_empty") }
        var createdDevice: dev_t = 0
        var createdInode: ino_t = 0
        let binding = try workspaceRoot.publishGeneratedFile(at: mirrorPath,
            purpose: .immutableData, maximumByteCount: UInt64(data.count)) { fd in
                let created = try status(fd)
                createdDevice = created.st_dev; createdInode = created.st_ino
                try data.withUnsafeBytes { buffer in
                    var offset = 0
                    while offset < buffer.count {
                        try check(deadline)
                        let n = Darwin.write(fd, buffer.baseAddress!.advanced(by: offset), buffer.count - offset)
                        if n < 0 && errno == EINTR { continue }
                        guard n > 0 else { throw rejected("mirror_write") }
                        offset += n
                    }
                }
            }
        let configAfter = try status(configFD)
        var namedConfig = stat()
        guard configAfter.st_dev == originalConfig.st_dev,
              configAfter.st_ino == originalConfig.st_ino,
              configAfter.st_mode == originalConfig.st_mode,
              configAfter.st_uid == originalConfig.st_uid,
              configAfter.st_gid == originalConfig.st_gid,
              configAfter.st_flags == originalConfig.st_flags,
              fstatat(workspaceFD, "config", &namedConfig, AT_SYMLINK_NOFOLLOW) == 0,
              same(configAfter, namedConfig),
              binding.byteCount == data.count, binding.sha256 == PrimeSHA256.hexDigest(of: data),
              fsync(configFD) == 0, fcntl(configFD, F_FULLFSYNC) == 0 else {
            throw rejected("mirror_publication")
        }
        let mirrors = try Tree(rootDescriptor: workspaceFD,
            specifications: [.init(path: mirrorPath, count: UInt64(data.count), hash: binding.sha256)],
            exactBelow: "config", immutable: true, deadline: deadline)
        guard let mirror = mirrors.files[mirrorPath],
              mirror.original.st_dev == createdDevice, mirror.original.st_ino == createdInode else {
            throw rejected("mirror_created_inode")
        }
        try source.revalidate(deadline: deadline)
        try mirrors.revalidate(deadline: deadline)
        return .init(source: source, mirrors: mirrors, workspaceRoot: workspaceRoot, mirrorBinding: binding)
    }

    func revalidate() throws {
        lock.lock(); defer { lock.unlock() }
        guard !poisoned else { throw Self.rejected("poisoned") }
        do {
            let deadline = try Self.operationDeadline()
            try source.revalidate(deadline: deadline)
            try mirrors.revalidate(deadline: deadline)
            _ = try workspaceRoot.verify(mirrorBinding)
            try Self.check(deadline)
        } catch { poisoned = true; throw error }
    }

    static func validateSnapshot(_ snapshot: PrimeSwiftSourceSnapshot) throws {
        let admitted = snapshot.files.filter { $0.relativePath.hasPrefix(sourcePrefix + "/") }
        guard admitted.count == specifications.count,
              Set(admitted.map(\.relativePath)) == Set(specifications.map(\.path)) else {
            throw rejected("snapshot_inventory")
        }
        for spec in specifications {
            guard let value = admitted.first(where: { $0.relativePath == spec.path }),
                  value.byteCount == spec.count, value.sha256 == spec.hash,
                  UInt64(value.contents.count) == spec.count,
                  PrimeSHA256.hexDigest(of: value.contents) == spec.hash else {
                throw rejected("snapshot_pin")
            }
        }
    }

    static func mirrorsData(primeRootAbsolutePath: String) throws -> Data {
        // Keep the physical spelling supplied by the held root. Foundation's
        // standardizedFileURL can shorten /private/tmp to the /tmp alias.
        let components = primeRootAbsolutePath.split(separator: "/", omittingEmptySubsequences: false)
        guard primeRootAbsolutePath.hasPrefix("/"), !primeRootAbsolutePath.hasSuffix("/"),
              primeRootAbsolutePath.utf8.count <= 16 * 1024,
              !primeRootAbsolutePath.utf8.contains(0),
              !primeRootAbsolutePath.contains("\\"),
              components.dropFirst().allSatisfy({ !$0.isEmpty && $0 != "." && $0 != ".." }) else {
            throw rejected("mirror_root_path")
        }
        struct Mirror: Encodable { let original: String; let mirror: String }
        struct Mirrors: Encodable { let object: [Mirror]; let version: Int }
        let pairs = [
            ("ergentics-mlx-swift", "https://github.com/Ergentics/ergentics-mlx-swift"),
            ("swift-numerics", "https://github.com/apple/swift-numerics"),
        ]
        return try PrimeCanonicalJSON.encode(Mirrors(object: pairs.map { name, original in
            Mirror(original: original, mirror: URL(fileURLWithPath:
                primeRootAbsolutePath + "/" + sourcePrefix + "/" + name).absoluteString)
        }, version: 1))
    }

    private final class Descriptor {
        let value: Int32
        init(_ value: Int32) { self.value = value }
        deinit { close(value) }
    }
    private final class Node {
        private let descriptor: Descriptor
        var fd: Int32 { descriptor.value }
        let path: String
        let parent: Node?
        let leaf: String?
        let original: stat
        let provenance: Data?
        init(fd: Int32, path: String, parent: Node?, leaf: String?) throws {
            descriptor = Descriptor(fd); self.path = path; self.parent = parent; self.leaf = leaf
            original = try status(fd)
            provenance = try metadata(fd, original, path: path)
            if let parent, original.st_dev != parent.original.st_dev { throw rejected("cross_device") }
            try revalidate()
        }
        func revalidate() throws {
            let held = try status(fd)
            guard same(held, original), try metadata(fd, held, path: path) == provenance else {
                throw rejected("held_metadata")
            }
            if let parent, let leaf {
                guard same(try status(parent.fd), parent.original) else { throw rejected("parent_metadata") }
                var named = stat()
                guard fstatat(parent.fd, leaf, &named, AT_SYMLINK_NOFOLLOW) == 0,
                      same(named, original) else { throw rejected("named_rejoin") }
            }
            guard same(try status(fd), original) else { throw rejected("final_metadata") }
        }
    }

    private final class Tree {
        let nodes: [Node]
        let files: [String: Node]
        let specifications: [Specification]
        let directoryNames: [String: Set<String>]
        init(rootDescriptor: Int32, specifications: [Specification], exactBelow: String,
             immutable: Bool, deadline: UInt64) throws {
            let root = try Node(fd: opened(fcntl(rootDescriptor, F_DUPFD_CLOEXEC, 3)),
                                path: "", parent: nil, leaf: nil)
            var nodes = [root], index = ["": root], files = [String: Node]()
            var directoryNames = [String: Set<String>]()
            for spec in specifications {
                guard spec.count > 0, spec.count <= 5 * 1024 * 1024 else { throw rejected("file_cap") }
                var parent = root, prefix = ""
                let parts = spec.path.split(separator: "/").map(String.init)
                for (offset, leaf) in parts.enumerated() {
                    try check(deadline)
                    guard !leaf.isEmpty, leaf != ".", leaf != "..", !leaf.contains("\\") else {
                        throw rejected("path_component")
                    }
                    if prefix == exactBelow || prefix.hasPrefix(exactBelow + "/") {
                        directoryNames[prefix, default: []].insert(leaf)
                    }
                    prefix = prefix.isEmpty ? leaf : prefix + "/" + leaf
                    if let existing = index[prefix] { parent = existing; continue }
                    try parent.revalidate()
                    let isFile = offset == parts.count - 1
                    let fd = try opened(openat(parent.fd, leaf, O_RDONLY | O_NOFOLLOW | O_NONBLOCK
                        | O_CLOEXEC | (isFile ? 0 : O_DIRECTORY)))
                    let node = try Node(fd: fd, path: prefix, parent: parent, leaf: leaf)
                    guard isFile
                        ? node.original.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG)
                        : node.original.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR) else {
                        throw rejected("node_type")
                    }
                    nodes.append(node); index[prefix] = node; parent = node
                }
                guard parent.original.st_size == Int64(spec.count),
                      parent.original.st_mode & 0o111 == 0,
                      !immutable || parent.original.st_mode & 0o7777 == 0o444 else {
                    throw rejected("file_mode_size")
                }
                files[spec.path] = parent
            }
            self.nodes = nodes; self.files = files; self.specifications = specifications
            self.directoryNames = directoryNames
            try revalidate(deadline: deadline)
        }
        func revalidate(deadline: UInt64, readContents: Bool = true) throws {
            for node in nodes { try check(deadline); try node.revalidate() }
            for (path, expected) in directoryNames {
                guard let node = nodes.first(where: { $0.path == path }),
                      try names(node.fd) == expected else { throw rejected("directory_inventory") }
            }
            if readContents {
                for spec in specifications {
                    guard let node = files[spec.path],
                          PrimeSHA256.hexDigest(of: try read(node, count: spec.count, deadline: deadline)) == spec.hash else {
                        throw rejected("file_pin")
                    }
                }
            }
            for node in nodes { try check(deadline); try node.revalidate() }
        }
    }

    private static func read(_ node: Node, count: UInt64, deadline: UInt64) throws -> Data {
        try node.revalidate()
        var data = Data(count: Int(count)), offset = 0
        try data.withUnsafeMutableBytes { buffer in
            while offset < buffer.count {
                try check(deadline)
                let n = pread(node.fd, buffer.baseAddress!.advanced(by: offset),
                    min(64 * 1024, buffer.count - offset), off_t(offset))
                if n < 0 && errno == EINTR { continue }
                guard n > 0 else { throw rejected("read") }
                offset += n
            }
        }
        try node.revalidate()
        return data
    }
    private static func names(_ fd: Int32) throws -> Set<String> {
        let duplicate = try opened(openat(fd, ".", O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC))
        guard let stream = fdopendir(duplicate) else { close(duplicate); throw rejected("fdopendir") }
        defer { closedir(stream) }
        var result = Set<String>()
        while true {
            errno = 0
            guard let entry = readdir(stream) else {
                guard errno == 0 else { throw rejected("readdir") }; return result
            }
            let name = withUnsafePointer(to: entry.pointee.d_name) {
                $0.withMemoryRebound(to: CChar.self, capacity: Int(MAXNAMLEN) + 1) { String(cString: $0) }
            }
            if name == "." || name == ".." { continue }
            guard result.count < 32, result.insert(name).inserted else { throw rejected("entry_cap") }
        }
    }
    private static func status(_ fd: Int32) throws -> stat {
        var value = stat(); guard fstat(fd, &value) == 0 else { throw rejected("fstat") }; return value
    }
    private static func same(_ a: stat, _ b: stat) -> Bool {
        PrimeValidationDriverV2BuildStaging.sameProtectedMetadata(a, b)
    }
    private static func opened(_ fd: Int32) throws -> Int32 {
        guard fd >= 0 else { throw rejected("open") }
        if fd < 3 { let dup = fcntl(fd, F_DUPFD_CLOEXEC, 3); close(fd); return try opened(dup) }
        return fd
    }
    private static func metadata(_ fd: Int32, _ s: stat, path: String) throws -> Data? {
        var fs = statfs()
        guard fstatfs(fd, &fs) == 0, fs.f_flags & UInt32(MNT_LOCAL) != 0,
              s.st_uid == geteuid(), s.st_flags == 0, s.st_mode & 0o7022 == 0 else { throw rejected("metadata") }
        var type = fs.f_fstypename
        guard withUnsafeBytes(of: &type, { String(bytes: $0.prefix { $0 != 0 }, encoding: .utf8) }) == "apfs" else {
            throw rejected("filesystem")
        }
        if s.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR) {
            guard s.st_mode & 0o500 == 0o500 else { throw rejected("directory_mode") }
            try PrimeArtifactRoot.requireTrustedInventoryDirectoryDescriptor(fd, path: path)
        } else {
            guard s.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG), s.st_nlink == 1,
                  s.st_size > 0, s.st_mode & 0o400 != 0 else { throw rejected("file_metadata") }
            try PrimeArtifactRoot.requireTrustedInventoryArtifactDescriptor(fd, path: path)
        }
        let count = fgetxattr(fd, "com.apple.provenance", nil, 0, 0, 0)
        if count < 0 { guard errno == ENOATTR else { throw rejected("xattr") }; return nil }
        guard count <= 4096 else { throw rejected("xattr_cap") }
        var data = Data(count: max(1, count))
        let actual = data.withUnsafeMutableBytes { fgetxattr(fd, "com.apple.provenance", $0.baseAddress, count, 0, 0) }
        guard actual == count, fgetxattr(fd, "com.apple.provenance", nil, 0, 0, 0) == count else {
            throw rejected("xattr_race")
        }
        return data.prefix(count)
    }
    private static func operationDeadline(_ outer: UInt64 = UInt64.max) throws -> UInt64 {
        let now = DispatchTime.now().uptimeNanoseconds
        let (deadline, overflow) = now.addingReportingOverflow(maximumOperationNanoseconds)
        guard !overflow, now < outer else { throw rejected("deadline_overflow_or_expired") }
        return min(deadline, outer)
    }
    private static func check(_ deadline: UInt64) throws {
        guard DispatchTime.now().uptimeNanoseconds < deadline else { throw rejected("deadline") }
    }
    private static func rejected(_ reason: String) -> Error {
        PrimeValidationSwiftPMBuildInventoryAdmissionError.rejected("driver_v2_locked_dependencies_" + reason)
    }

    fileprivate static func inputReadback(primeRootDescriptor: Int32,
        primeRootAbsolutePath: String, deadlineNanoseconds: UInt64) throws -> (Bool) throws -> Void {
        _ = try mirrorsData(primeRootAbsolutePath: primeRootAbsolutePath)
        var pathBytes = [CChar](repeating: 0, count: Int(MAXPATHLEN))
        let pathResult = pathBytes.withUnsafeMutableBufferPointer {
            fcntl(primeRootDescriptor, F_GETPATH, $0.baseAddress!)
        }
        guard pathResult == 0,
              String(cString: pathBytes) == primeRootAbsolutePath else { throw rejected("readback_root_join") }
        let source = try Tree(rootDescriptor: primeRootDescriptor, specifications: specifications,
            exactBelow: sourcePrefix, immutable: false, deadline: operationDeadline(deadlineNanoseconds))
        return { readContents in
            try source.revalidate(deadline: operationDeadline(deadlineNanoseconds), readContents: readContents)
        }
    }

    fileprivate static func mirrorReadback(workspaceRootDescriptor: Int32,
        primeRootAbsolutePath: String, deadlineNanoseconds: UInt64) throws -> (Bool) throws -> Void {
        let data = try mirrorsData(primeRootAbsolutePath: primeRootAbsolutePath)
        let mirrors = try Tree(rootDescriptor: workspaceRootDescriptor,
            specifications: [.init(path: mirrorPath, count: UInt64(data.count), hash: PrimeSHA256.hexDigest(of: data))],
            exactBelow: "config", immutable: true, deadline: operationDeadline(deadlineNanoseconds))
        guard let config = mirrors.nodes.first(where: { $0.path == "config" }),
              config.original.st_mode & 0o7777 == 0o700 else { throw rejected("readback_config_mode") }
        return { readContents in
            try mirrors.revalidate(deadline: operationDeadline(deadlineNanoseconds), readContents: readContents)
        }
    }
}

/// Read-only independent governor ownership. Capture precedes the supervisor;
/// the single mirrors join follows F. No decoded data can spawn or stage work.
@_spi(PrimeValidationDriverV2RoleFacade)
public final class PrimeValidationDriverV2LockedDependencyReadback: @unchecked Sendable {
    private let primeRootAbsolutePath: String
    private let deadlineNanoseconds: UInt64
    private let input: (Bool) throws -> Void
    private var mirrors: ((Bool) throws -> Void)?
    private let lock = NSLock()
    private var bindAttempted = false
    private var poisoned = false
    private init(primeRootAbsolutePath: String, deadlineNanoseconds: UInt64,
                 input: @escaping (Bool) throws -> Void) {
        self.primeRootAbsolutePath = primeRootAbsolutePath
        self.deadlineNanoseconds = deadlineNanoseconds; self.input = input
    }
    public static func capture(primeRootDescriptor: Int32, primeRootAbsolutePath: String,
                               deadlineNanoseconds: UInt64) throws -> PrimeValidationDriverV2LockedDependencyReadback {
        .init(primeRootAbsolutePath: primeRootAbsolutePath, deadlineNanoseconds: deadlineNanoseconds,
              input: try PrimeValidationDriverV2LockedDependencies.inputReadback(
                primeRootDescriptor: primeRootDescriptor, primeRootAbsolutePath: primeRootAbsolutePath,
                deadlineNanoseconds: deadlineNanoseconds))
    }
    public func bindExistingMirrors(workspaceRootDescriptor: Int32) throws {
        lock.lock(); defer { lock.unlock() }
        guard !poisoned, !bindAttempted else { poisoned = true; throw Self.rejected }
        bindAttempted = true
        do {
            try input(true)
            let value = try PrimeValidationDriverV2LockedDependencies.mirrorReadback(
                workspaceRootDescriptor: workspaceRootDescriptor, primeRootAbsolutePath: primeRootAbsolutePath,
                deadlineNanoseconds: deadlineNanoseconds)
            try input(true); try value(true)
            mirrors = value
        } catch { poisoned = true; throw error }
    }
    public func revalidate() throws { try checked(readContents: true, requireMirrors: false) }
    public func checkpointMetadata() throws { try checked(readContents: false, requireMirrors: false) }
    public func revalidateBoundMirrors() throws { try checked(readContents: true, requireMirrors: true) }
    private func checked(readContents: Bool, requireMirrors: Bool) throws {
        lock.lock(); defer { lock.unlock() }
        guard !poisoned, !requireMirrors || mirrors != nil else { poisoned = true; throw Self.rejected }
        do { try input(readContents); try mirrors?(readContents) }
        catch { poisoned = true; throw error }
    }
    private static var rejected: Error {
        PrimeValidationSwiftPMBuildInventoryAdmissionError.rejected("driver_v2_locked_dependencies_readback_poisoned")
    }
}
