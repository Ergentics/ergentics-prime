import Darwin
import Foundation
import PrimeCore
import PrimeNativeDecoderRuntime
import PrimeNativeDecoderCheckpoint
import PrimeNativeGeneration

private struct GenerationRequest: Decodable {
    let question: String
    let maximumNewTokens: Int
    let checkpointRoot: String
}

private func readGenerationRequest(_ path: String) throws -> GenerationRequest {
    guard path.hasPrefix("/"), path.utf8.count <= 4096, !path.utf8.contains(0) else {
        throw CocoaError(.fileReadInvalidFileName)
    }
    let descriptor = open(path, O_RDONLY | O_CLOEXEC | O_NOFOLLOW_ANY)
    guard descriptor >= 0 else { throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO) }
    defer { close(descriptor) }
    var before = stat()
    guard fstat(descriptor, &before) == 0, before.st_mode & S_IFMT == S_IFREG,
          before.st_mode & 0o7777 == 0o600, before.st_uid == getuid(), before.st_nlink == 1,
          before.st_size > 0, before.st_size <= 16 * 1024 else { throw CocoaError(.fileReadCorruptFile) }
    var data = Data(count: Int(before.st_size))
    try data.withUnsafeMutableBytes { buffer in
        var offset = 0
        while offset < buffer.count {
            let count = pread(descriptor, buffer.baseAddress!.advanced(by: offset), buffer.count - offset, off_t(offset))
            guard count > 0 else { throw CocoaError(.fileReadCorruptFile) }
            offset += count
        }
    }
    var after = stat(), named = stat()
    guard fstat(descriptor, &after) == 0, lstat(path, &named) == 0,
          before.st_dev == after.st_dev, before.st_ino == after.st_ino,
          before.st_dev == named.st_dev, before.st_ino == named.st_ino,
          before.st_size == after.st_size, before.st_mode == after.st_mode,
          before.st_uid == after.st_uid, before.st_gid == after.st_gid, before.st_nlink == after.st_nlink,
          before.st_mtimespec.tv_sec == after.st_mtimespec.tv_sec,
          before.st_mtimespec.tv_nsec == after.st_mtimespec.tv_nsec,
          before.st_ctimespec.tv_sec == after.st_ctimespec.tv_sec,
          before.st_ctimespec.tv_nsec == after.st_ctimespec.tv_nsec,
          let object = try JSONSerialization.jsonObject(with: data) as? [String: Any],
          Set(object.keys) == ["question", "maximumNewTokens", "checkpointRoot"] else {
        throw CocoaError(.fileReadCorruptFile)
    }
    let request = try JSONDecoder().decode(GenerationRequest.self, from: data)
    guard !request.question.isEmpty, request.question.utf8.count <= 4096,
          (1...256).contains(request.maximumNewTokens),
          request.checkpointRoot.hasPrefix("/"), request.checkpointRoot.utf8.count <= 4096,
          !request.checkpointRoot.utf8.contains(0),
          !request.checkpointRoot.split(separator: "/", omittingEmptySubsequences: false).dropFirst()
            .contains(where: { $0.isEmpty || $0 == "." || $0 == ".." }) else {
        throw CocoaError(.fileReadCorruptFile)
    }
    return request
}

private func jsonObject<T: Encodable>(_ value: T) throws -> Any {
    try JSONSerialization.jsonObject(with: JSONEncoder().encode(value))
}

private func emit(_ object: [String: Any]) throws {
    var bytes = try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys, .withoutEscapingSlashes])
    guard bytes.count <= 4 * 1024 * 1024 else { throw CocoaError(.fileWriteInapplicableStringEncoding) }
    bytes.append(10)
    try FileHandle.standardOutput.write(contentsOf: bytes)
}

// Each invocation owns one runtime initialization and then exits. The native
// environment rules remain unchanged. The explicit signed-app initializer
// selects its own internal synchronization directory and records that policy.
let parent = getppid()
guard parent > 1 else { Darwin._exit(75) }
let watchdog = DispatchSource.makeTimerSource(queue: DispatchQueue(label: "com.ergentics.prime.parent"))
watchdog.schedule(deadline: .now(), repeating: .milliseconds(200))
watchdog.setEventHandler { @Sendable [parent] in
    if getppid() != parent { Darwin._exit(75) }
}
watchdog.resume()
let generationRequested = CommandLine.arguments.count == 3 && CommandLine.arguments[1] == "--generate"
alarm(generationRequested ? 300 : 30)
let startedAt = DispatchTime.now().uptimeNanoseconds
do {
    guard CommandLine.arguments.count == 3,
          CommandLine.arguments[1] == "--check-runtime" || generationRequested else {
        throw NSError(domain: "PrimeRuntime", code: 64, userInfo: [NSLocalizedDescriptionKey: "Unsupported Prime runtime request."])
    }
    let generationRequest: GenerationRequest?
    if generationRequested {
        generationRequest = try readGenerationRequest(CommandLine.arguments[2])
    } else {
        generationRequest = nil
        try PrimeMetalDeviceLease.validateSandboxApplicationSynchronizationRequest(directoryPath: CommandLine.arguments[2])
    }
    let directory = URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent()
    let contents = directory.deletingLastPathComponent().deletingLastPathComponent()
    let expectationData = try Data(contentsOf: contents.appendingPathComponent("Resources/PrimeRuntimeMetallib.json"))
    guard expectationData.count < 4096 else { throw CocoaError(.fileReadCorruptFile) }
    let expectation = try JSONDecoder().decode(PrimeNativeDecoderMaintainedRuntimeMetallibExpectationV1.self, from: expectationData)
    let evidence = try PrimeNativeDecoderRuntime.initializeSandboxApplicationCurrentProcess(
        metallibExpectation: expectation)
    if let request = generationRequest {
        let bindingData = try Data(contentsOf: contents.appendingPathComponent("Resources/PrimePromptCheckpoint.json"))
        guard !bindingData.isEmpty, bindingData.count <= 1024 * 1024 else { throw CocoaError(.fileReadCorruptFile) }
        let baseline = try PrimeCanonicalJSON.decode(
            PrimeNativeDecoderNative300MTrajectoryExternalCommitBindingV1.self, from: bindingData)
        let artifactRoot = try PrimeArtifactRoot(directoryURL: URL(fileURLWithPath: request.checkpointRoot))
        let lease = try PrimeMetalDeviceLease.acquireForSandboxApplicationSynchronization()
        defer { lease.release() }
        var tokens: [Int] = []
        let deadline = startedAt.addingReportingOverflow(300_000_000_000)
        guard !deadline.overflow else { throw CocoaError(.fileReadCorruptFile) }
        let result = try PrimeNativeDecoderCurrentLocalGeneration.generate(
            artifactRoot: artifactRoot, checkpoint: baseline, question: request.question,
            maximumNewTokens: request.maximumNewTokens, deadlineNanoseconds: deadline.partialValue,
            lease: lease, recordToken: { event in
                tokens.append(event.tokenID)
                let output = try PrimeNativeDecoderCurrentLocalGeneration.render(tokenIDs: tokens)
                try emit(["type": "token", "event": jsonObject(event),
                          "renderedOutput": output.renderedOutput,
                          "decodedText": output.decodedText as Any? ?? NSNull()])
            })
        let retainedLease = try lease.revalidateSandboxApplicationSynchronization()
        try emit(["type": "result", "result": jsonObject(result),
                  "sandbox_application_synchronization_lease": jsonObject(retainedLease)])
        lease.release()
        Darwin._exit(0)
    }
    // Preserve the runtime projection expected by the app and explicitly add
    // the different, native-observed lease policy. This is not a strict-lease
    // or historical runtime receipt.
    let runtimeData = try JSONEncoder().encode(evidence.initialization)
    guard var report = try JSONSerialization.jsonObject(with: runtimeData) as? [String: Any] else {
        throw CocoaError(.fileReadCorruptFile)
    }
    report["sandbox_application_synchronization_lease"] = try JSONSerialization.jsonObject(
        with: JSONEncoder().encode(evidence.synchronizationLease))
    let output = try JSONSerialization.data(withJSONObject: report, options: [.sortedKeys])
    try FileHandle.standardOutput.write(contentsOf: output)
    Darwin._exit(0)
} catch {
    let description = (error as? LocalizedError)?.errorDescription ?? String(reflecting: error)
    var detail = ""
    if !generationRequested, error is PrimeMetalDeviceLeaseError, CommandLine.arguments.count == 3 {
        var names = [CChar](repeating: 0, count: 4096)
        let count = listxattr(CommandLine.arguments[2], &names, names.count, XATTR_NOFOLLOW)
        if count > 0 {
            let text = String(decoding: names.prefix(count).map { UInt8(bitPattern: $0) }, as: UTF8.self)
            detail = " Directory attributes: " + text.replacingOccurrences(of: "\0", with: ", ")
        }
    }
    let message = String((description + detail).prefix(4096)) + "\n"
    try? FileHandle.standardError.write(contentsOf: Data(message.utf8))
    Darwin._exit(70)
}
