// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin
import Dispatch
import Foundation
import MachO
import PrimeCore
import PrimeNativeDecoderCheckpoint
import PrimeNativeDecoderRuntime
import PrimeNativeDecoderTraining

private typealias Generation = PrimeNativeDecoderCurrentLocalGeneration
private enum GenerationWorkerError: Error { case rejected(String) }
private let maximumResultBytes: UInt64 = 4 * 1024 * 1024

private func emit(_ message: String) {
    let data = Data((message + "\n").utf8)
    data.withUnsafeBytes { bytes in _ = Darwin.write(STDERR_FILENO, bytes.baseAddress, bytes.count) }
}

/// The UI supplies declarations; the worker rejoins the actual source bytes,
/// its running image, and the externally bound baseline before model work.
private struct GenerationRequest: Codable {
    let schema: String
    let sourceCommitDeclaration: String
    let sourceRoot: String
    let sourceFiles: [PrimeArtifactBinding]
    let executableAbsolutePath: String
    let executableSHA256: String
    let executableByteCount: UInt64
    let metallib: PrimeNativeDecoderMaintainedRuntimeMetallibExpectationV1
    let checkpointRoot: String
    let checkpoint: PrimeNativeDecoderNative300MTrajectoryExternalCommitBindingV1
    let question: String
    let maximumNewTokens: Int
    let runRoot: String

    func validate() throws {
        func hex(_ text: String, count: Int) -> Bool {
            text.utf8.count == count && text.utf8.allSatisfy { (48...57).contains($0) || (97...102).contains($0) }
        }
        guard schema == "prime_current_local_native300m_generation_request_v1",
              hex(sourceCommitDeclaration, count: 40), hex(executableSHA256, count: 64),
              executableByteCount > 0, executableByteCount <= 256 * 1024 * 1024,
              !question.isEmpty, question.utf8.count <= 4096,
              !question.precomposedStringWithCanonicalMapping.isEmpty,
              question.precomposedStringWithCanonicalMapping.utf8.count <= Generation.maximumPromptByteTokens,
              (1...Generation.maximumGeneratedTokens).contains(maximumNewTokens)
        else { throw GenerationWorkerError.rejected("request_shape_or_token_bound") }
        for path in [sourceRoot, executableAbsolutePath, checkpointRoot, runRoot] {
            guard path.hasPrefix("/"), let resolved = realpath(path, nil) else {
                throw GenerationWorkerError.rejected("request_path_realpath")
            }
            let actual = String(cString: resolved); free(resolved)
            guard actual == path else { throw GenerationWorkerError.rejected("request_path_alias") }
        }
        guard runRoot != checkpointRoot, !runRoot.hasPrefix(checkpointRoot + "/"),
              runRoot != sourceRoot, !runRoot.hasPrefix(sourceRoot + "/"),
              checkpoint.setRole == .baselineCheckpoint, checkpoint.loadAuthoritative
        else { throw GenerationWorkerError.rejected("request_roots_or_checkpoint_role") }
        try metallib.validate()
        try PrimeNativeDecoderNative300MTrajectoryCheckpointV1.validateExternalBinding(checkpoint)
        try validateSources()
    }

    func validateSources() throws {
        guard sourceFiles.map(\.relativePath) == (try PrimeCurrentLocalNative300MLaunch.sourcePaths(root: URL(fileURLWithPath: sourceRoot)))
        else { throw GenerationWorkerError.rejected("source_inventory") }
        for binding in sourceFiles {
            guard binding.purpose == .immutableData, binding.byteCount <= 16 * 1024 * 1024 else {
                throw GenerationWorkerError.rejected("source_binding")
            }
            let held = try HeldFile(path: sourceRoot + "/" + binding.relativePath,
                maximum: 16 * 1024 * 1024, modes: [0o444, 0o644, 0o555, 0o755])
            guard UInt64(held.data.count) == binding.byteCount,
                  PrimeSHA256.hexDigest(of: held.data) == binding.sha256
            else { throw GenerationWorkerError.rejected("source_hash_" + binding.relativePath) }
        }
    }
}

/// Private requests remain 0600/0400. The descriptor is held across inference;
/// reading does not change their permissions or import their metadata.
private final class HeldFile {
    let path: String
    let data: Data
    private let descriptor: Int32
    private let metadata: stat

    init(path: String, maximum: UInt64, modes: [mode_t]) throws {
        let fd = open(path, O_RDONLY | O_NOFOLLOW_ANY | O_CLOEXEC)
        guard fd >= 0 else { throw GenerationWorkerError.rejected("file_open_\(errno)") }
        var keep = false
        defer { if !keep { close(fd) } }
        var before = stat()
        guard fstat(fd, &before) == 0, before.st_mode & S_IFMT == S_IFREG,
              before.st_uid == geteuid(), before.st_nlink == 1,
              modes.contains(before.st_mode & 0o7777), before.st_size >= 0,
              UInt64(before.st_size) <= maximum
        else { throw GenerationWorkerError.rejected("file_metadata") }
        var bytes = Data(); var chunk = [UInt8](repeating: 0, count: 64 * 1024)
        var interruptions = 0
        let startedAt = DispatchTime.now().uptimeNanoseconds
        while bytes.count < Int(before.st_size) {
            guard DispatchTime.now().uptimeNanoseconds - startedAt < 30_000_000_000 else {
                throw GenerationWorkerError.rejected("file_read_deadline")
            }
            let count = read(fd, &chunk, min(chunk.count, Int(before.st_size) - bytes.count))
            if count < 0 && errno == EINTR {
                interruptions += 1
                guard interruptions <= 8 else { throw GenerationWorkerError.rejected("file_read_interruptions") }
                continue
            }
            guard count > 0 else { throw GenerationWorkerError.rejected("file_read_\(errno)") }
            bytes.append(contentsOf: chunk.prefix(count))
        }
        var after = stat(); var named = stat()
        guard fstat(fd, &after) == 0, lstat(path, &named) == 0,
              Self.same(before, after), Self.same(before, named)
        else { throw GenerationWorkerError.rejected("file_rejoin") }
        self.path = path; self.data = bytes; self.descriptor = fd; self.metadata = before
        keep = true
    }

    deinit { close(descriptor) }

    private static func same(_ a: stat, _ b: stat) -> Bool {
            a.st_dev == b.st_dev && a.st_ino == b.st_ino && a.st_mode == b.st_mode &&
            a.st_uid == b.st_uid && a.st_gid == b.st_gid && a.st_nlink == b.st_nlink &&
            a.st_size == b.st_size && a.st_flags == b.st_flags &&
            a.st_mtimespec.tv_sec == b.st_mtimespec.tv_sec && a.st_mtimespec.tv_nsec == b.st_mtimespec.tv_nsec &&
            a.st_ctimespec.tv_sec == b.st_ctimespec.tv_sec && a.st_ctimespec.tv_nsec == b.st_ctimespec.tv_nsec
    }

    func revalidate() throws {
        var held = stat(); var named = stat()
        guard fstat(descriptor, &held) == 0, lstat(path, &named) == 0,
              Self.same(metadata, held), Self.same(metadata, named)
        else { throw GenerationWorkerError.rejected("file_rejoin") }
    }
}

private func currentExecutablePath() throws -> String {
    var size: UInt32 = 0; _ = _NSGetExecutablePath(nil, &size)
    guard size > 1, size <= 16 * 1024 else { throw GenerationWorkerError.rejected("image_path_size") }
    var bytes = [CChar](repeating: 0, count: Int(size))
    guard _NSGetExecutablePath(&bytes, &size) == 0, let resolved = realpath(String(cString: bytes), nil) else {
        throw GenerationWorkerError.rejected("image_path")
    }
    defer { free(resolved) }
    return String(cString: resolved)
}

private func publish(_ data: Data, root: PrimeArtifactRoot, path: String) throws -> PrimeArtifactBinding {
    guard UInt64(data.count) <= maximumResultBytes else { throw GenerationWorkerError.rejected("result_size") }
    return try root.publishGeneratedFile(at: path, purpose: .immutableData, maximumByteCount: UInt64(data.count)) { fd in
        try data.withUnsafeBytes { bytes in
            var offset = 0
            while offset < bytes.count {
                let count = Darwin.write(fd, bytes.baseAddress!.advanced(by: offset), bytes.count - offset)
                if count < 0 && errno == EINTR { continue }
                guard count > 0 else { throw GenerationWorkerError.rejected("result_write_\(errno)") }
                offset += count
            }
        }
    }
}

@available(macOS 26.0, *)
private func run(requestPath: String) throws {
    let parent = getppid()
    let startedAt = DispatchTime.now().uptimeNanoseconds
    let (deadline, overflow) = startedAt.addingReportingOverflow(Generation.maximumDurationNanoseconds)
    guard parent > 1, !overflow else { throw GenerationWorkerError.rejected("parent_or_deadline") }
    if getsid(0) != getpid() {
        guard setsid() == getpid() else { throw GenerationWorkerError.rejected("setsid_\(errno)") }
    }
    guard getpgrp() == getpid() else { throw GenerationWorkerError.rejected("process_group") }
    let watchdog = DispatchSource.makeTimerSource(queue: DispatchQueue.global(qos: .userInitiated))
    watchdog.schedule(deadline: .now(), repeating: .milliseconds(200))
    watchdog.setEventHandler {
        if getppid() != parent || DispatchTime.now().uptimeNanoseconds >= deadline {
            emit("prime_generation_parent_or_deadline_lost")
            Darwin._exit(124)
        }
    }
    watchdog.resume()
    defer { watchdog.cancel() }
    let requestFile = try HeldFile(path: requestPath, maximum: 4 * 1024 * 1024, modes: [0o600, 0o400])
    let request = try PrimeCanonicalJSON.decode(GenerationRequest.self, from: requestFile.data)
    try request.validate()
    guard getppid() == parent, try currentExecutablePath() == request.executableAbsolutePath else {
        throw GenerationWorkerError.rejected("parent_or_current_image_path")
    }
    let imageData = try PrimeSecureRunningExecutableCapture.data()
    guard UInt64(imageData.count) == request.executableByteCount,
          PrimeSHA256.hexDigest(of: imageData) == request.executableSHA256
    else { throw GenerationWorkerError.rejected("current_image_bytes") }
    let output = try PrimeArtifactRoot(directoryURL: URL(fileURLWithPath: request.runRoot))
    try output.requirePrivateRootMode(); try output.requireEmpty()
    do {
        try output.ensurePrivateDirectory(at: "progress")
        try output.ensurePrivateDirectory(at: "synchronization")
        let artifacts = try PrimeArtifactRoot(directoryURL: URL(fileURLWithPath: request.checkpointRoot))
        let leaseURL = URL(fileURLWithPath: request.runRoot + "/synchronization/metal.lock")
        emit("prime_generation_runtime_preflight_started")
        let runtime = try PrimeNativeDecoderRuntime.initializeCurrentProcess(metallibExpectation: request.metallib, metalLeaseURL: leaseURL)
        try runtime.validate()
        guard runtime.executable.sha256 == request.executableSHA256,
              runtime.executable.byteCount == request.executableByteCount,
              runtime.metallibExpectation == request.metallib
        else { throw GenerationWorkerError.rejected("runtime_binding") }
        let runtimeBinding = try publish(PrimeCanonicalJSON.encode(runtime), root: output, path: "runtime.json")
        // Runtime initialization releases its own lease. This separate strict
        // lease remains held throughout the actual model and result operations.
        let lease = try PrimeMetalDeviceLease.acquire(at: leaseURL)
        defer { lease.release() }
        emit("prime_generation_loading_retained_weights")
        var tokens: [Int] = []
        struct Progress: Codable {
            let ordinal: Int
            let tokenID: Int
            let renderedOutput: String
            let decodedText: String?
        }
        let result = try Generation.generate(artifactRoot: artifacts, checkpoint: request.checkpoint,
            question: request.question, maximumNewTokens: request.maximumNewTokens,
            deadlineNanoseconds: deadline, lease: lease) { event in
                guard event.ordinal == tokens.count, tokens.count < request.maximumNewTokens,
                      getppid() == parent, lease.isHeld, DispatchTime.now().uptimeNanoseconds < deadline
                else { throw GenerationWorkerError.rejected("token_sequence_or_lifetime") }
                tokens.append(event.tokenID)
                let rendered = try Generation.render(tokenIDs: tokens)
                let progress = Progress(ordinal: event.ordinal, tokenID: event.tokenID,
                    renderedOutput: rendered.renderedOutput, decodedText: rendered.decodedText)
                _ = try publish(PrimeCanonicalJSON.encode(progress), root: output,
                    path: "progress/" + String(format: "%04d.json", event.ordinal + 1))
                emit("prime_generation_token_\(event.ordinal + 1)")
            }
        try requestFile.revalidate()
        try request.validateSources()
        let finalImage = try PrimeSecureRunningExecutableCapture.data()
        guard UInt64(finalImage.count) == request.executableByteCount,
              PrimeSHA256.hexDigest(of: finalImage) == request.executableSHA256,
              tokens == result.generatedTokenIDs, getppid() == parent,
              lease.isHeld, DispatchTime.now().uptimeNanoseconds < deadline
        else { throw GenerationWorkerError.rejected("final_continuity") }
        let resultBinding = try publish(PrimeCanonicalJSON.encode(result), root: output, path: "result.json")
        struct Complete: Codable {
            let schema = "prime_current_local_native300m_generation_complete_v1"
            let status = "GENERATED_FROM_VERIFIED_NATIVE_CHECKPOINT"
            let requestSHA256: String
            let sourceCommitDeclaration: String
            let processIdentifier: Int32
            let parentProcessIdentifier: Int32
            let sessionIdentifier: Int32
            let runtime: PrimeArtifactBinding
            let result: PrimeArtifactBinding
            let startedAtUptimeNanoseconds: UInt64
            let deadlineUptimeNanoseconds: UInt64
            let completedAtUptimeNanoseconds: UInt64
            let trainedLanguageQualityClaimed = false
        }
        _ = try output.publishCanonicalExclusively(Complete(requestSHA256: PrimeSHA256.hexDigest(of: requestFile.data),
            sourceCommitDeclaration: request.sourceCommitDeclaration,
            processIdentifier: getpid(), parentProcessIdentifier: parent, sessionIdentifier: getsid(0),
            runtime: runtimeBinding, result: resultBinding, startedAtUptimeNanoseconds: startedAt,
            deadlineUptimeNanoseconds: deadline, completedAtUptimeNanoseconds: DispatchTime.now().uptimeNanoseconds), at: "complete.json")
        FileHandle.standardOutput.write(Data((result.renderedOutput + "\n").utf8))
        emit("GENERATED_FROM_VERIFIED_NATIVE_CHECKPOINT")
    } catch {
        struct Failure: Codable {
            let schema = "prime_current_local_native300m_generation_failure_v1"
            let error: String
            let observedAtUptimeNanoseconds: UInt64
        }
        _ = try? output.publishCanonicalExclusively(Failure(error: String(reflecting: error),
            observedAtUptimeNanoseconds: DispatchTime.now().uptimeNanoseconds), at: "failure.json")
        throw error
    }
}

if #available(macOS 26.0, *) {
    do {
        guard CommandLine.arguments.count == 3, CommandLine.arguments[1] == "--request",
              CommandLine.arguments[2].hasPrefix("/") else {
            throw GenerationWorkerError.rejected("usage: --request /absolute/private-request.json")
        }
        try run(requestPath: CommandLine.arguments[2])
    } catch {
        emit("prime_generation_failed: " + String(reflecting: error))
        Darwin.exit(71)
    }
} else {
    emit("prime_generation_requires_macos26")
    Darwin.exit(64)
}
