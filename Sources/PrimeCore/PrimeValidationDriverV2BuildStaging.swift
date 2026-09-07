// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin
import Foundation

/// A namespace derived exclusively from the roots retained through Gate E.
/// SwiftPM may change descendants of its nine directories. It may never
/// replace those directories or add entries to either admitted root.
final class PrimeValidationDriverV2BuildStaging {
    private let admission: PrimeValidationSwiftPMRetainedAdmissionState
    private let workspaceDescriptor: Int32
    private let evidenceDescriptor: Int32
    private let workspaceIdentity: PrimeArtifactRootIdentity
    private let evidenceIdentity: PrimeArtifactRootIdentity
    private var directories: [String: Directory] = [:]
    private let runDirectory: Directory
    private let buildDirectory: Directory
    private let artifactsDirectory: Directory
    private var inventoryDirectory: Directory?
    let context: PrimeValidationDriverV2RoleContext
    let artifactRoot: PrimeArtifactRoot
    let buildRoot: PrimeArtifactRoot
    var workspaceRoot: PrimeArtifactRoot { admission.workspaceRoot.root }
    private var buildLeaves = Set<String>()
    private var streams: [String: Stream] = [:]
    private let lockedDependencies: PrimeValidationDriverV2LockedDependencies

    init(state: PrimeValidationDriverV2BuildExecutionState) throws {
        admission = state.retainedState.admission
        context = state.context
        let runID = context.evidenceRunID
        guard Self.safeLeaf(runID),
              context.requiredPinnedMetallibByteCount > 0,
              context.requiredPinnedMetallibSHA256.utf8.count == 64,
              context.requiredPinnedMetallibSHA256.utf8.allSatisfy({
                  (48...57).contains($0) || (97...102).contains($0)
              })
        else { throw Self.rejected("context") }
        try admission.workspaceRoot.requirePrivateAndEmpty()
        try admission.evidenceRoot.requirePrivateAndEmpty()
        let workspaceFD = try admission.workspaceRoot.root
            .duplicateTrustedRootDescriptorForInventory()
        let evidenceFD: Int32
        do {
            evidenceFD = try admission.evidenceRoot.root
                .duplicateTrustedRootDescriptorForInventory()
        } catch { close(workspaceFD); throw error }
        workspaceDescriptor = workspaceFD
        evidenceDescriptor = evidenceFD
        do {
            for leaf in Self.workspaceLeaves {
                directories[leaf] = try Directory.create(
                    parent: workspaceFD, leaf: leaf,
                    path: context.workspaceRootAbsolutePath + "/" + leaf
                )
            }
            runDirectory = try Directory.create(
                parent: evidenceFD, leaf: runID,
                path: context.evidenceRootAbsolutePath + "/" + runID
            )
            buildDirectory = try Directory.create(
                parent: runDirectory.descriptor, leaf: "build",
                path: runDirectory.path + "/build"
            )
            artifactsDirectory = try Directory.create(
                parent: runDirectory.descriptor, leaf: "artifacts",
                path: runDirectory.path + "/artifacts"
            )
            artifactRoot = try PrimeArtifactRoot(
                heldDirectoryDescriptor: artifactsDirectory.descriptor,
                displayURL: URL(fileURLWithPath: artifactsDirectory.path)
            )
            buildRoot = try PrimeArtifactRoot(
                heldDirectoryDescriptor: buildDirectory.descriptor,
                displayURL: URL(fileURLWithPath: buildDirectory.path)
            )
            workspaceIdentity = try admission.workspaceRoot.root
                .verifiedRootIdentity()
            evidenceIdentity = try admission.evidenceRoot.root
                .verifiedRootIdentity()
            lockedDependencies = try PrimeValidationDriverV2LockedDependencies.prepare(
                admission: admission, context: context,
                workspaceRoot: admission.workspaceRoot.root)
        } catch {
            close(workspaceFD); close(evidenceFD)
            throw error
        }
        try runDirectory.freezeMetadata()
        try buildDirectory.freezeMetadata()
        try revalidate(against: admission)
    }

    deinit {
        close(workspaceDescriptor)
        close(evidenceDescriptor)
    }

    func revalidate(
        against candidate: PrimeValidationSwiftPMRetainedAdmissionState
    ) throws {
        guard candidate === admission,
              try workspaceRoot.verifiedRootIdentity() == workspaceIdentity,
              try admission.evidenceRoot.root.verifiedRootIdentity()
                == evidenceIdentity,
              try Self.entries(workspaceDescriptor) == Set(Self.workspaceLeaves),
              try Self.entries(evidenceDescriptor) == [context.evidenceRunID],
              try Self.entries(runDirectory.descriptor)
                == (inventoryDirectory == nil
                    ? Set(["artifacts", "build"])
                    : Set(["artifacts", "build", "inventory"])),
              try Self.entries(buildDirectory.descriptor) == buildLeaves
        else { throw Self.rejected("root_ledger") }
        for directory in directories.values { try directory.revalidate() }
        try runDirectory.revalidate()
        try buildDirectory.revalidate()
        try artifactsDirectory.revalidate()
        try inventoryDirectory?.revalidate()
        try lockedDependencies.revalidate()
        for (leaf, stream) in streams {
            try stream.revalidate(parent: buildDirectory.descriptor, leaf: leaf)
            if let binding = stream.binding { try buildRoot.verify(binding) }
        }
    }

    /// One exclusive next-phase namespace transition. Completed build and
    /// copied artifact leaves remain immutable under their existing owners.
    func createInventoryDirectory() throws -> Directory {
        guard inventoryDirectory == nil,
              buildLeaves == Set(["prestart.json", "start.json", "terminal.json",
                                  "stdout.log", "stderr.log", "binding.json"]),
              streams.count == 2,
              streams.values.allSatisfy({ $0.binding != nil })
        else { throw Self.rejected("inventory_transfer_precondition") }
        try revalidate(against: admission)
        let directory = try Directory.create(
            parent: runDirectory.descriptor, leaf: "inventory",
            path: runDirectory.path + "/inventory"
        )
        inventoryDirectory = directory
        try Self.synchronize(runDirectory.descriptor)
        try runDirectory.freezeMetadata()
        try directory.freezeMetadata()
        try revalidate(against: admission)
        return directory
    }

    /// The drain becomes the sole descriptor owner on successful adoption.
    /// The caller closes it if spawning fails before adoption.
    func createStream(_ leaf: String) throws -> Int32 {
        guard ["stdout.log", "stderr.log"].contains(leaf),
              !buildLeaves.contains(leaf)
        else { throw Self.rejected("stream_leaf") }
        try revalidate(against: admission)
        let fd = openat(buildDirectory.descriptor, leaf,
                        O_RDWR | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC, 0o600)
        guard fd >= 3 else {
            if fd >= 0 { close(fd) }
            throw Self.rejected("stream_open_\(errno)")
        }
        do {
            guard fchmod(fd, 0o600) == 0 else {
                throw Self.rejected("stream_mode")
            }
            streams[leaf] = try Stream(
                outputDescriptor: fd, parent: buildDirectory.descriptor, leaf: leaf
            )
            try Self.synchronize(buildDirectory.descriptor)
            buildLeaves.insert(leaf)
            try buildDirectory.freezeMetadata()
            try revalidate(against: admission)
            return fd
        } catch { close(fd); throw error }
    }

    @discardableResult
    func publish<Value: Encodable>(_ value: Value, leaf: String) throws
        -> PrimeArtifactBinding
    {
        guard ["prestart.json", "start.json", "terminal.json"].contains(leaf),
              !buildLeaves.contains(leaf)
        else { throw Self.rejected("journal_leaf") }
        try revalidate(against: admission)
        let binding = try buildRoot.publishCanonicalExclusively(
            value, at: leaf
        )
        buildLeaves.insert(leaf)
        try buildDirectory.freezeMetadata()
        try revalidate(against: admission)
        return binding
    }

    private static let workspaceLeaves = [
        "cache", "clang-module-cache", "config", "home", "output",
        "root-release-build", "security", "swiftpm-module-cache", "temporary",
    ]

    func verifyCompletedStreams(_ process: PrimeValidationDriverV2BuildProcessObservation) throws {
        try revalidate(against: admission)
        for (leaf, observed) in [
            ("stdout.log", process.standardOutput), ("stderr.log", process.standardError)
        ] {
            guard let stream = streams[leaf], observed.clean else {
                throw Self.rejected("stream_completion")
            }
            try stream.revalidate(parent: buildDirectory.descriptor, leaf: leaf)
            let binding = try buildRoot.bindExisting(
                at: leaf, purpose: .immutableData, maximumByteCount: 16 * 1024 * 1024
            )
            guard observed.outputDeviceID == UInt64(bitPattern: Int64(stream.original.st_dev)),
                  observed.outputInode == UInt64(stream.original.st_ino),
                  observed.outputByteCount == binding.byteCount,
                  observed.outputSHA256 == binding.sha256
            else { throw Self.rejected("stream_named_output_join") }
            try stream.freeze(binding: binding)
        }
        try revalidate(against: admission)
    }

    func freezeCapturedArtifactRoot(_ observation: PrimeValidationDriverV2BuildArtifactsObservation) throws {
        guard try artifactRoot.verifiedRootIdentity() == observation.artifactRootIdentity else {
            throw Self.rejected("artifact_root_join")
        }
        try artifactsDirectory.freezeMetadata()
        try revalidate(against: admission)
    }

    func publishBindingData(_ data: Data) throws {
        guard !data.isEmpty, data.count <= 16 * 1024 * 1024,
              data.first == 0x7b, data.last == 0x7d,
              !buildLeaves.contains("binding.json"),
              let object = try JSONSerialization.jsonObject(with: data)
                as? [String: Any],
              try JSONSerialization.data(
                withJSONObject: object, options: [.sortedKeys, .withoutEscapingSlashes]
              ) == data
        else { throw Self.rejected("binding_frame") }
        try revalidate(against: admission)
        _ = try buildRoot.publishGeneratedFile(
            at: "binding.json", purpose: .immutableData,
            maximumByteCount: UInt64(data.count)
        ) { fd in
            try data.withUnsafeBytes { bytes in
                var offset = 0
                while offset < bytes.count {
                    let count = Darwin.write(
                        fd, bytes.baseAddress!.advanced(by: offset), bytes.count - offset
                    )
                    if count < 0 && errno == EINTR { continue }
                    guard count > 0 else { throw Self.rejected("binding_write") }
                    offset += count
                }
            }
        }
        buildLeaves.insert("binding.json")
        try buildDirectory.freezeMetadata()
        try revalidate(against: admission)
    }

    final class Stream {
        let descriptor: Int32
        let original: stat
        private var final: stat?
        private(set) var binding: PrimeArtifactBinding?
        init(outputDescriptor: Int32, parent: Int32, leaf: String) throws {
            let fd = fcntl(outputDescriptor, F_DUPFD_CLOEXEC, 3)
            guard fd >= 3 else { throw rejected("stream_duplicate") }
            var value = stat()
            guard fstat(fd, &value) == 0, value.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
                  value.st_nlink == 1, value.st_size == 0, value.st_uid == geteuid(),
                  value.st_mode & 0o7777 == 0o600, value.st_flags == 0 else {
                close(fd); throw rejected("stream_initial_metadata")
            }
            descriptor = fd; original = value
        }
        deinit { close(descriptor) }
        func revalidate(parent: Int32, leaf: String) throws {
            var held = stat(); var named = stat()
            guard fstat(descriptor, &held) == 0,
                  fstatat(parent, leaf, &named, AT_SYMLINK_NOFOLLOW) == 0,
                  held.st_dev == original.st_dev, held.st_ino == original.st_ino,
                  held.st_dev == named.st_dev, held.st_ino == named.st_ino,
                  held.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
                  named.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
                  held.st_uid == original.st_uid, named.st_uid == original.st_uid,
                  held.st_gid == original.st_gid, named.st_gid == original.st_gid,
                  held.st_nlink == 1, named.st_nlink == 1,
                  held.st_flags == 0, named.st_flags == 0,
                  [mode_t(0o600), mode_t(0o444)].contains(held.st_mode & 0o7777),
                  [mode_t(0o600), mode_t(0o444)].contains(named.st_mode & 0o7777)
            else { throw rejected("stream_replaced") }
            if let final {
                guard sameProtectedMetadata(held, final),
                      sameProtectedMetadata(named, final) else {
                    throw rejected("stream_frozen_metadata")
                }
            }
        }
        func freeze(binding: PrimeArtifactBinding) throws {
            guard final == nil else { throw rejected("stream_already_frozen") }
            var value = stat()
            guard fstat(descriptor, &value) == 0, value.st_mode & 0o7777 == 0o444,
                  value.st_size >= 0, UInt64(value.st_size) == binding.byteCount else {
                throw rejected("stream_freeze")
            }
            final = value
            self.binding = binding
        }
    }

    final class Directory {
        let descriptor: Int32
        let parent: Int32
        let leaf: String
        let path: String
        private let original: stat
        private var frozen: stat?

        private init(descriptor: Int32, parent: Int32, leaf: String,
                     path: String, original: stat) {
            self.descriptor = descriptor; self.parent = parent
            self.leaf = leaf; self.path = path; self.original = original
        }
        deinit { close(descriptor) }

        static func create(parent: Int32, leaf: String, path: String) throws
            -> Directory
        {
            guard safeLeaf(leaf), mkdirat(parent, leaf, 0o700) == 0 else {
                throw rejected("mkdir_exclusive_\(errno)")
            }
            let fd = openat(parent, leaf,
                            O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC)
            guard fd >= 3 else {
                if fd >= 0 { close(fd) }
                throw rejected("directory_open_\(errno)")
            }
            do {
                try PrimeArtifactRoot.requireTrustedInventoryDirectoryDescriptor(
                    fd, path: path
                )
                var value = stat()
                guard fstat(fd, &value) == 0,
                      value.st_mode & 0o7777 == 0o700,
                      value.st_uid == geteuid(),
                      value.st_flags == 0,
                      try entries(fd).isEmpty
                else { throw rejected("directory_metadata") }
                try synchronize(fd)
                try synchronize(parent)
                let result = Directory(
                    descriptor: fd, parent: parent, leaf: leaf,
                    path: path, original: value
                )
                return result
            } catch { close(fd); throw error }
        }

        func revalidate() throws {
            var held = stat(); var named = stat()
            guard fstat(descriptor, &held) == 0,
                  fstatat(parent, leaf, &named, AT_SYMLINK_NOFOLLOW) == 0,
                  held.st_dev == original.st_dev,
                  held.st_ino == original.st_ino,
                  held.st_dev == named.st_dev, held.st_ino == named.st_ino,
                  held.st_mode == original.st_mode,
                  named.st_mode == original.st_mode,
                  held.st_uid == original.st_uid, named.st_uid == original.st_uid,
                  held.st_gid == original.st_gid, named.st_gid == original.st_gid,
                  held.st_flags == original.st_flags,
                  named.st_flags == original.st_flags,
                  fcntl(descriptor, F_GETFD) & FD_CLOEXEC != 0
            else { throw rejected("directory_replaced") }
            try PrimeArtifactRoot.requireTrustedInventoryDirectoryDescriptor(
                descriptor, path: path
            )
            if let frozen {
                guard sameProtectedMetadata(held, frozen),
                      sameProtectedMetadata(named, frozen) else {
                    throw rejected("directory_frozen_metadata")
                }
            }
        }
        func freezeMetadata() throws {
            var value = stat()
            guard fstat(descriptor, &value) == 0 else { throw rejected("directory_freeze") }
            frozen = value
        }
    }

    static func entries(_ fd: Int32) throws -> Set<String> {
        let duplicate = openat(fd, ".", O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC)
        guard duplicate >= 3 else {
            if duplicate >= 0 { close(duplicate) }
            throw rejected("inventory_open")
        }
        guard let stream = fdopendir(duplicate) else {
            close(duplicate); throw rejected("inventory_stream")
        }
        defer { closedir(stream) }
        var result = Set<String>()
        while true {
            errno = 0
            guard let entry = readdir(stream) else {
                guard errno == 0 else { throw rejected("inventory_read") }
                return result
            }
            let name = withUnsafePointer(to: entry.pointee.d_name) {
                $0.withMemoryRebound(to: CChar.self, capacity: Int(MAXNAMLEN) + 1) {
                    String(cString: $0)
                }
            }
            if name == "." || name == ".." { continue }
            guard result.count < 32, safeLeaf(name), result.insert(name).inserted
            else { throw rejected("inventory_bound") }
        }
    }

    private static func safeLeaf(_ value: String) -> Bool {
        !value.isEmpty && value != "." && value != ".."
            && value.utf8.count <= Int(MAXNAMLEN)
            && value.utf8.allSatisfy { $0 >= 0x21 && $0 <= 0x7e && $0 != 47 && $0 != 92 }
    }
    static func synchronize(_ fd: Int32) throws {
        guard fsync(fd) == 0, fcntl(fd, F_FULLFSYNC) == 0 else {
            throw rejected("directory_sync")
        }
    }
    static func sameProtectedMetadata(_ a: stat, _ b: stat) -> Bool {
        a.st_dev == b.st_dev && a.st_ino == b.st_ino && a.st_mode == b.st_mode
            && a.st_uid == b.st_uid && a.st_gid == b.st_gid
            && a.st_nlink == b.st_nlink && a.st_flags == b.st_flags
            && a.st_size == b.st_size
            && a.st_rdev == b.st_rdev && a.st_gen == b.st_gen
            && a.st_blocks == b.st_blocks && a.st_blksize == b.st_blksize
            && a.st_birthtimespec.tv_sec == b.st_birthtimespec.tv_sec
            && a.st_birthtimespec.tv_nsec == b.st_birthtimespec.tv_nsec
            && a.st_mtimespec.tv_sec == b.st_mtimespec.tv_sec
            && a.st_mtimespec.tv_nsec == b.st_mtimespec.tv_nsec
            && a.st_ctimespec.tv_sec == b.st_ctimespec.tv_sec
            && a.st_ctimespec.tv_nsec == b.st_ctimespec.tv_nsec
    }
    private static func rejected(_ reason: String) -> Error {
        PrimeValidationSwiftPMBuildInventoryAdmissionError
            .rejected("driver_v2_build_staging_" + reason)
    }
}
