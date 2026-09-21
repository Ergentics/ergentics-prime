// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary
// DRAFT: integrated only through the retained G -> H transition.
import Darwin
import Foundation

final class PrimeValidationDriverV2ExecutionStaging {
    typealias Directory = PrimeValidationDriverV2BuildStaging.Directory
    typealias Stream = PrimeValidationDriverV2BuildStaging.Stream
    let root: PrimeArtifactRoot
    let directory: Directory
    private let outputRoot: PrimeArtifactRoot
    private let outputFD: Int32
    private let outputPath: String
    private var evidenceDirectories: [String: Directory] = [:]
    private var outputDirectories: [String: Directory] = [:]
    private var names: [String: Set<String>] = ["": []]
    private var outputNames: [String: Set<String>] = ["": []]
    private var bindings: [PrimeArtifactBinding] = []
    private var outputBindings: [PrimeArtifactBinding] = []
    private var resultWitnesses: [String: ResultWitness] = [:]
    private var streams: [String: Stream] = [:]
    private var openShard: PrimeValidationDriverV2ClosedShardObservation?

    init(build: PrimeValidationDriverV2BuildStaging) throws {
        outputPath = build.context.outputAbsolutePath
        directory = try build.createExecutionDirectory()
        root = try PrimeArtifactRoot(heldDirectoryDescriptor: directory.descriptor,
            displayURL: URL(fileURLWithPath: directory.path))
        let workspaceFD = try build.workspaceRoot.duplicateTrustedRootDescriptorForInventory()
        defer { close(workspaceFD) }
        let fd = openat(workspaceFD, "output", O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC)
        guard fd >= 3 else { if fd >= 0 { close(fd) }; throw hRejected("output_root") }
        do {
            outputRoot = try PrimeArtifactRoot(heldDirectoryDescriptor: fd,
                displayURL: URL(fileURLWithPath: build.context.outputAbsolutePath))
            guard try Self.entries(fd).isEmpty else { throw hRejected("output_not_fresh") }
        } catch { close(fd); throw error }
        outputFD = fd
        try revalidate()
    }
    deinit { close(outputFD) }

    static func entries(_ fd: Int32) throws -> Set<String> {
        let dup = openat(fd, ".", O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC)
        guard dup >= 3 else { if dup >= 0 { close(dup) }; throw hRejected("directory_census_open") }
        guard let stream = fdopendir(dup) else { close(dup); throw hRejected("directory_census_stream") }
        defer { closedir(stream) }
        var names = Set<String>()
        while true {
            errno = 0
            guard let entry = readdir(stream) else {
                guard errno == 0 else { throw hRejected("directory_census") }; return names
            }
            let name = withUnsafePointer(to: entry.pointee.d_name) {
                $0.withMemoryRebound(to: CChar.self, capacity: Int(MAXNAMLEN) + 1) { String(cString: $0) }
            }
            if name == "." || name == ".." { continue }
            guard names.count < 1024, !name.isEmpty, name.utf8.count <= Int(MAXNAMLEN),
                  name.utf8.allSatisfy({ (33...126).contains($0) && $0 != 47 && $0 != 92 }),
                  names.insert(name).inserted else { throw hRejected("directory_census_bound") }
        }
    }

    func revalidate() throws {
        try directory.revalidate()
        _ = try root.verifiedRootIdentity(); _ = try outputRoot.verifiedRootIdentity()
        for (path, expected) in names {
            let fd = path.isEmpty ? directory.descriptor : evidenceDirectories[path]!.descriptor
            try evidenceDirectories[path]?.revalidate()
            guard try Self.entries(fd) == expected else { throw hRejected("evidence_ledger") }
        }
        for (path, expected) in outputNames {
            let fd = path.isEmpty ? outputFD : outputDirectories[path]!.descriptor
            // The active output leaf is the single child-produced xUnit namespace.
            // It is admitted only after exact reap; other output directories freeze.
            if path != openShard?.relativeRoot { try outputDirectories[path]?.revalidate() }
            if path != openShard?.relativeRoot {
                guard try Self.entries(fd) == expected else { throw hRejected("output_ledger") }
            }
        }
        for binding in bindings { try root.verify(binding) }
        for binding in outputBindings { try outputRoot.verify(binding) }
        for (path, witness) in resultWitnesses {
            let parent = String(path.dropLast("/result.xml".count))
            try witness.revalidate(parent: outputDirectories[parent]!.descriptor)
        }
        for (path, stream) in streams {
            let parent = String(path.dropLast(URL(fileURLWithPath: path).lastPathComponent.count + 1))
            try stream.revalidate(parent: evidenceDirectories[parent]!.descriptor,
                leaf: URL(fileURLWithPath: path).lastPathComponent)
        }
    }

    private func ensureDirectory(_ path: String, output: Bool) throws {
        var prefix = ""
        for part in path.split(separator: "/").map(String.init) {
            let next = prefix.isEmpty ? part : prefix + "/" + part
            if (output ? outputDirectories[next] : evidenceDirectories[next]) == nil {
                try revalidate()
                let fd = prefix.isEmpty ? (output ? outputFD : directory.descriptor)
                    : (output ? outputDirectories[prefix]! : evidenceDirectories[prefix]!).descriptor
                let base = output ? outputPath : directory.path
                let new = try Directory.create(parent: fd, leaf: part, path: base + "/" + next)
                if output {
                    outputDirectories[next] = new; outputNames[prefix, default: []].insert(part); outputNames[next] = []
                    try outputDirectories[prefix]?.freezeMetadata()
                } else {
                    evidenceDirectories[next] = new; names[prefix, default: []].insert(part); names[next] = []
                    if prefix.isEmpty { try directory.freezeMetadata() } else { try evidenceDirectories[prefix]?.freezeMetadata() }
                }
                try new.freezeMetadata(); try PrimeValidationDriverV2BuildStaging.synchronize(fd)
            }
            prefix = next
        }
    }

    func beginShard(_ shard: PrimeValidationDriverV2ClosedShardObservation) throws {
        guard openShard == nil, evidenceDirectories[shard.relativeRoot] == nil,
              outputDirectories[shard.relativeRoot] == nil else { throw hRejected("shard_namespace_reuse") }
        try ensureDirectory(shard.relativeRoot, output: false)
        if shard.requiresXUnit { try ensureDirectory(shard.relativeRoot, output: true) }
        openShard = shard
        try revalidate()
    }

    @discardableResult
    func publish<Value: Encodable>(_ value: Value, path: String) throws -> PrimeArtifactBinding {
        try publishData(PrimeCanonicalJSON.encode(value), path: path)
    }
    @discardableResult
    func publishData(_ data: Data, path: String,
        observingCreatedDescriptor: ((Int32) throws -> Void)? = nil) throws -> PrimeArtifactBinding {
        _ = try HJSON.object(data)
        return try publishBytes(data, path: path, observingCreatedDescriptor: observingCreatedDescriptor)
    }
    static func validatePredecessorEFrame(_ data: Data, path: String) throws {
        guard ["predecessor-e-start.json", "predecessor-e-terminal.json"].contains(path),
              data.count <= 16 * 1024 * 1024, data.last == 0x0a else {
            throw hRejected("predecessor_E_frame")
        }
        _ = try HJSON.object(Data(data.dropLast()))
    }
    func publishPredecessorEFrame(_ data: Data, path: String) throws -> PrimeArtifactBinding {
        try Self.validatePredecessorEFrame(data, path: path)
        return try publishBytes(data, path: path)
    }
    private func publishBytes(_ data: Data, path: String,
        observingCreatedDescriptor: ((Int32) throws -> Void)? = nil) throws -> PrimeArtifactBinding {
        let url = URL(fileURLWithPath: path), leaf = url.lastPathComponent
        let parent = path.contains("/") ? String(path.dropLast(leaf.count + 1)) : ""
        guard names[parent] != nil, !names[parent]!.contains(leaf), data.count <= 16 * 1024 * 1024 else {
            throw hRejected("publish_leaf")
        }
        try revalidate()
        let binding = try root.publishGeneratedFile(at: path, purpose: .immutableData,
            maximumByteCount: UInt64(data.count)) { fd in
            try data.withUnsafeBytes { bytes in
                var offset = 0
                while offset < bytes.count {
                    let n = Darwin.write(fd, bytes.baseAddress!.advanced(by: offset), bytes.count - offset)
                    if n < 0 && errno == EINTR { continue }
                    guard n > 0 else { throw hRejected("publish_write") }; offset += n
                }
            }
            // Internal publication code may retain a duplicate of this actual
            // created descriptor. PrimeArtifactRoot still owns mode/fsync and
            // the exclusive link; this callback cannot select a launch.
            try observingCreatedDescriptor?(fd)
        }
        bindings.append(binding); names[parent]!.insert(leaf)
        try (parent.isEmpty ? directory : evidenceDirectories[parent]!).freezeMetadata()
        try revalidate(); return binding
    }

    func createStream(_ suffix: String) throws -> Int32 {
        guard let shard = openShard, ["stdout.log", "stderr.log"].contains(suffix),
              !names[shard.relativeRoot]!.contains(suffix) else { throw hRejected("stream_reuse") }
        try revalidate()
        let parent = evidenceDirectories[shard.relativeRoot]!, path = shard.relativeRoot + "/" + suffix
        let fd = openat(parent.descriptor, suffix, O_RDWR | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC, 0o600)
        guard fd >= 3 else { if fd >= 0 { close(fd) }; throw hRejected("stream_open") }
        do {
            guard fchmod(fd, 0o600) == 0 else { throw hRejected("stream_mode") }
            streams[path] = try Stream(outputDescriptor: fd, parent: parent.descriptor, leaf: suffix)
            names[shard.relativeRoot]!.insert(suffix)
            try parent.freezeMetadata(); try PrimeValidationDriverV2BuildStaging.synchronize(parent.descriptor)
            try revalidate(); return fd
        } catch { close(fd); throw error }
    }

    func freezeStreams(_ process: PrimeValidationDriverV2BuildProcessObservation) throws -> [PrimeArtifactBinding] {
        guard let shard = openShard else { throw hRejected("no_open_shard") }
        var result: [PrimeArtifactBinding] = []
        for (suffix, observed) in [("stdout.log", process.standardOutput), ("stderr.log", process.standardError)] {
            let path = shard.relativeRoot + "/" + suffix
            guard let stream = streams[path], observed.clean else { throw hRejected("stream_incomplete") }
            try stream.revalidate(parent: evidenceDirectories[shard.relativeRoot]!.descriptor, leaf: suffix)
            let binding = try root.bindExisting(at: path, purpose: .immutableData, maximumByteCount: 16 * 1024 * 1024)
            guard binding.byteCount == observed.outputByteCount, binding.sha256 == observed.outputSHA256,
                  observed.outputDeviceID == UInt64(bitPattern: Int64(stream.original.st_dev)),
                  observed.outputInode == stream.original.st_ino else { throw hRejected("stream_join") }
            try stream.freeze(binding: binding); bindings.append(binding); result.append(binding)
        }
        try revalidate(); return result
    }

    func captureResultAfterExactReap() throws -> (PrimeArtifactBinding, Data)? {
        guard let shard = openShard else { throw hRejected("no_open_shard") }
        guard shard.requiresXUnit else { return nil }
        let parent = outputDirectories[shard.relativeRoot]!
        let observedNames = try Self.entries(parent.descriptor)
        guard observedNames == [] || observedNames == ["result.xml"] else { throw hRejected("unexpected_xunit_output") }
        guard observedNames == ["result.xml"] else { return nil }
        let fd = openat(parent.descriptor, "result.xml", O_RDWR | O_NONBLOCK | O_NOFOLLOW | O_CLOEXEC)
        guard fd >= 3 else { if fd >= 0 { close(fd) }; throw hRejected("result_open") }
        defer { close(fd) }
        var before = stat(), named = stat()
        guard fstat(fd, &before) == 0, fstatat(parent.descriptor, "result.xml", &named, AT_SYMLINK_NOFOLLOW) == 0,
              before.st_mode & S_IFMT == S_IFREG, before.st_nlink == 1, before.st_uid == geteuid(),
              before.st_mode & 0o7133 == 0, before.st_flags == 0,
              before.st_size > 0, before.st_size <= 16 * 1024 * 1024,
              PrimeValidationDriverV2BuildStaging.sameProtectedMetadata(before, named),
              fchmod(fd, 0o444) == 0, fsync(fd) == 0, fcntl(fd, F_FULLFSYNC) == 0 else { throw hRejected("result_metadata") }
        let path = shard.relativeRoot + "/result.xml"
        let witness = try ResultWitness(descriptor: fd, original: before, parent: parent.descriptor)
        let source = try outputRoot.bindExisting(at: path, purpose: .immutableData, maximumByteCount: 16 * 1024 * 1024)
        let data = try outputRoot.readVerified(source, maximumByteCount: 16 * 1024 * 1024)
        try witness.revalidate(parent: parent.descriptor)
        resultWitnesses[path] = witness
        outputBindings.append(source); outputNames[shard.relativeRoot] = ["result.xml"]
        try parent.freezeMetadata()
        let copy = try publishBytes(data, path: path, observingCreatedDescriptor: { created in
            var copied = stat()
            guard fstat(created, &copied) == 0,
                  copied.st_dev != before.st_dev || copied.st_ino != before.st_ino else {
                throw hRejected("result_copy_alias")
            }
        })
        guard source.byteCount == copy.byteCount, source.sha256 == copy.sha256 else { throw hRejected("result_copy") }
        return (copy, data)
    }

    func closeShard() throws {
        guard let shard = openShard else { throw hRejected("no_open_shard") }
        if shard.requiresXUnit { try outputDirectories[shard.relativeRoot]!.freezeMetadata() }
        openShard = nil
        try revalidate()
    }
    func read(_ binding: PrimeArtifactBinding) throws -> Data {
        try root.readVerified(binding, maximumByteCount: 16 * 1024 * 1024)
    }
    func completedBindings() throws -> [PrimeArtifactBinding] {
        guard openShard == nil else { throw hRejected("unfinished_shard") }
        try revalidate()
        return bindings.sorted { $0.relativePath < $1.relativePath }
    }

    private final class ResultWitness {
        let descriptor: Int32
        let final: stat
        init(descriptor: Int32, original: stat, parent: Int32) throws {
            let fd = fcntl(descriptor, F_DUPFD_CLOEXEC, 3)
            guard fd >= 3 else { throw hRejected("result_duplicate") }
            var held = stat(), named = stat()
            guard fstat(fd, &held) == 0,
                  fstatat(parent, "result.xml", &named, AT_SYMLINK_NOFOLLOW) == 0,
                  held.st_dev == original.st_dev, held.st_ino == original.st_ino,
                  held.st_mode & 0o7777 == 0o444,
                  PrimeValidationDriverV2BuildStaging.sameProtectedMetadata(held, named) else {
                close(fd); throw hRejected("result_held_join")
            }
            // Our sole authorized mutation was chmod to 0444 (and its ctime).
            // Everything else must still join the post-reap original stat.
            var expected = original
            expected.st_mode = held.st_mode; expected.st_ctimespec = held.st_ctimespec
            guard PrimeValidationDriverV2BuildStaging.sameProtectedMetadata(held, expected) else {
                close(fd); throw hRejected("result_chmod_join")
            }
            self.descriptor = fd; final = held
        }
        deinit { close(descriptor) }
        func revalidate(parent: Int32) throws {
            var held = stat(), named = stat()
            guard fstat(descriptor, &held) == 0,
                  fstatat(parent, "result.xml", &named, AT_SYMLINK_NOFOLLOW) == 0,
                  PrimeValidationDriverV2BuildStaging.sameProtectedMetadata(held, final),
                  PrimeValidationDriverV2BuildStaging.sameProtectedMetadata(named, final) else {
                throw hRejected("result_frozen_join")
            }
        }
    }
}
