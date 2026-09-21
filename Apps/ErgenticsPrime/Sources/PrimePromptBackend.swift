import CoreFoundation
import Darwin
import Foundation

struct PrimePromptReport: Sendable {
    let renderedOutput: String
    let decodedText: String?
    let generatedTokenIDs: [Int]
    let elapsedSeconds: Double
    /// Exact helper JSONL, including token/logit rows and the final native result.
    let nativeEvidence: Data
    /// Exact final JSONL row, including the sandbox synchronization evidence.
    let resultJSON: Data
    let sessionRoot: URL
}

enum PrimePromptBackend {
    static func generate(question: String, maximumNewTokens: Int = 128, checkpointRoot: URL,
                         cancellation: PrimeRuntimeCancellation,
                         onProgress: @escaping @Sendable (String) -> Void) throws -> PrimePromptReport {
        if cancellation.isCancelled { throw CancellationError() }
        guard !question.isEmpty, question.utf8.count <= 4096,
              question.precomposedStringWithCanonicalMapping.utf8.count <= 1023,
              (1...256).contains(maximumNewTokens), checkpointRoot.isFileURL else {
            throw PrimeRuntimeFailure(message: "Enter a question of at most 1023 UTF-8 bytes and choose 1–256 output tokens.")
        }
        let helper = Bundle.main.bundleURL.appendingPathComponent("Contents/Helpers/PrimeRuntime/ErgenticsPrimeRuntime")
        try PrimeRuntimeBackend.verifyHelper(helper)
        let bindingURL = Bundle.main.bundleURL.appendingPathComponent("Contents/Resources/PrimePromptCheckpoint.json")
        let bindingData = try Data(contentsOf: bindingURL)
        guard bindingData.count <= 1024 * 1024,
              let checkpoint = try JSONSerialization.jsonObject(with: bindingData) as? [String: Any],
              checkpoint["load_authoritative"] as? Bool == true,
              checkpoint["set_role"] as? String == "baseline_checkpoint",
              let commit = checkpoint["commit_manifest_canonical_sha256"] as? String,
              let weights = (checkpoint["weights_external_binding"] as? [String: Any])?["artifact_binding"] as? [String: Any]
        else { throw PrimeRuntimeFailure(message: "The app's retained checkpoint binding is incomplete.") }

        let support = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask,
                                                 appropriateFor: nil, create: true)
        let sessions = support.appendingPathComponent("PrimePromptSessions", isDirectory: true)
        try privateDirectory(sessions, exclusive: false)
        let root = sessions.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try privateDirectory(root, exclusive: true)
        let request = try JSONSerialization.data(withJSONObject: [
            "question": question, "maximumNewTokens": maximumNewTokens, "checkpointRoot": checkpointRoot.path,
        ], options: [.sortedKeys, .withoutEscapingSlashes])
        let requestURL = root.appendingPathComponent("request.json")
        try writePrivate(request, to: requestURL)
        let transcriptURL = root.appendingPathComponent("transcript.jsonl")
        let fd = open(transcriptURL.path, O_WRONLY | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC, 0o600)
        guard fd >= 0 else { throw PrimeRuntimeFailure(message: "Could not retain Prime's output (\(errno)).") }
        defer { close(fd) }
        let stream = PrimePromptStream(question: question, maximumNewTokens: maximumNewTokens,
            expectedCommit: commit, expectedWeights: weights, descriptor: fd,
            cancellation: cancellation, onProgress: onProgress)
        let process: PrimeRuntimeBackend.ExecutionResult
        do {
            process = try PrimeRuntimeBackend.execute(helper: helper, arguments: ["--generate", requestURL.path],
                root: root, cancellation: cancellation, timeoutSeconds: 300, outputLimit: 4 * 1024 * 1024,
                onOutput: { stream.consume($0) })
        } catch {
            // Failed cleanup always wins over cancellation or malformed output;
            // the shared admission remains blocked in that case.
            if error is PrimeRuntimeBackend.CleanupFailure { throw error }
            if let failure = stream.failure { throw failure }
            throw error
        }
        guard fsync(fd) == 0 else { throw PrimeRuntimeFailure(message: "Could not finish retaining Prime's output (\(errno)).") }
        let value = try stream.finish()
        try writePrivate(value.finalLine, to: root.appendingPathComponent("result.json"))
        return PrimePromptReport(renderedOutput: value.renderedOutput, decodedText: value.decodedText,
            generatedTokenIDs: value.tokens, elapsedSeconds: process.elapsedSeconds,
            nativeEvidence: process.standardOutput, resultJSON: value.finalLine, sessionRoot: root)
    }

    private static func privateDirectory(_ url: URL, exclusive: Bool) throws {
        let created = mkdir(url.path, 0o700)
        guard created == 0 || (!exclusive && errno == EEXIST) else {
            throw PrimeRuntimeFailure(message: "Could not create private Prime prompt storage (\(errno)).")
        }
        let fd = open(url.path, O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC)
        guard fd >= 0 else { throw PrimeRuntimeFailure(message: "Could not safely open Prime prompt storage (\(errno)).") }
        defer { close(fd) }
        var held = stat(), named = stat()
        guard fstat(fd, &held) == 0, lstat(url.path, &named) == 0,
              held.st_dev == named.st_dev, held.st_ino == named.st_ino,
              held.st_mode & S_IFMT == S_IFDIR, held.st_uid == geteuid(),
              held.st_mode & 0o7777 == 0o700 else {
            throw PrimeRuntimeFailure(message: "Prime prompt storage has an unexpected owner, mode, or identity.")
        }
    }

    private static func writePrivate(_ data: Data, to url: URL) throws {
        let fd = open(url.path, O_WRONLY | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC, 0o600)
        guard fd >= 0 else { throw PrimeRuntimeFailure(message: "Could not create a private Prime request or result (\(errno)).") }
        defer { close(fd) }
        try writeAll(data, to: fd)
        guard fsync(fd) == 0 else { throw PrimeRuntimeFailure(message: "Could not retain the Prime request or result (\(errno)).") }
    }

    fileprivate static func writeAll(_ data: Data, to fd: Int32) throws {
        try data.withUnsafeBytes { bytes in
            var offset = 0
            while offset < bytes.count {
                let count = Darwin.write(fd, bytes.baseAddress!.advanced(by: offset), bytes.count - offset)
                if count < 0 && errno == EINTR { continue }
                guard count > 0 else { throw PrimeRuntimeFailure(message: "Could not retain Prime output (\(errno)).") }
                offset += count
            }
        }
    }
}

// Access is serial: execute invokes consume on its owning worker thread, and
// finish is called on that same thread only after exact child cleanup returns.
final class PrimePromptStream: @unchecked Sendable {
    struct Value {
        let renderedOutput: String
        let decodedText: String?
        let tokens: [Int]
        let finalLine: Data
    }
    private let question: String
    private let maximumNewTokens: Int
    private let expectedCommit: String
    private let expectedWeights: [String: Any]
    private let descriptor: Int32
    private let cancellation: PrimeRuntimeCancellation
    private let onProgress: @Sendable (String) -> Void
    private var pending = Data()
    private var received = 0
    private var tokens: [Int] = []
    private var observedEvents: [[String: Any]] = []
    private var lastOutput = ""
    private var final: Value?
    private(set) var failure: PrimeRuntimeFailure?

    init(question: String, maximumNewTokens: Int, expectedCommit: String, expectedWeights: [String: Any],
         descriptor: Int32, cancellation: PrimeRuntimeCancellation,
         onProgress: @escaping @Sendable (String) -> Void) {
        self.question = question; self.maximumNewTokens = maximumNewTokens
        self.expectedCommit = expectedCommit; self.expectedWeights = expectedWeights
        self.descriptor = descriptor; self.cancellation = cancellation; self.onProgress = onProgress
    }

    func consume(_ data: Data) {
        guard failure == nil else { return }
        do {
            received += data.count
            guard received <= 4 * 1024 * 1024 else { throw invalid("output size") }
            try PrimePromptBackend.writeAll(data, to: descriptor)
            pending.append(data)
            while let newline = pending.firstIndex(of: 10) {
                let line = Data(pending[..<newline])
                pending.removeSubrange(...newline)
                try consumeLine(line)
            }
        } catch {
            failure = error as? PrimeRuntimeFailure ?? invalid(error.localizedDescription)
            cancellation.cancel()
        }
    }

    func finish() throws -> Value {
        if let failure { throw failure }
        guard pending.isEmpty, let final else { throw invalid("missing complete result") }
        return final
    }

    private func invalid(_ detail: String) -> PrimeRuntimeFailure {
        PrimeRuntimeFailure(message: "Prime returned an incomplete or inconsistent generation result (\(detail)).")
    }

    private func integer(_ value: Any?) -> Int? {
        guard let number = value as? NSNumber, CFGetTypeID(number) != CFBooleanGetTypeID(),
              !["f", "d"].contains(String(cString: number.objCType)),
              number.compare(NSNumber(value: Int.min)) != .orderedAscending,
              number.compare(NSNumber(value: Int.max)) != .orderedDescending else { return nil }
        return number.intValue
    }

    private func consumeLine(_ line: Data) throws {
        guard final == nil, !line.isEmpty,
              let object = try JSONSerialization.jsonObject(with: line) as? [String: Any],
              let type = object["type"] as? String else { throw invalid("JSONL framing") }
        if type == "token" {
            guard let event = object["event"] as? [String: Any],
                  integer(event["ordinal"]) == tokens.count,
                  let token = integer(event["tokenID"]), (0...511).contains(token),
                  tokens.count < maximumNewTokens,
                  let rendered = object["renderedOutput"] as? String, rendered.utf8.count <= 16_384 else {
                throw invalid("token sequence")
            }
            tokens.append(token); observedEvents.append(event); lastOutput = rendered; onProgress(rendered)
            return
        }
        guard type == "result", !tokens.isEmpty,
              let result = object["result"] as? [String: Any],
              result["schema"] as? String == "prime_current_local_native300m_generation_v1",
              result["question"] as? String == question,
              result["canonicalQuestion"] as? String == question.precomposedStringWithCanonicalMapping,
              result["checkpointCommitSHA256"] as? String == expectedCommit,
              let weights = result["weightsBinding"] as? [String: Any], NSDictionary(dictionary: weights).isEqual(to: expectedWeights),
              let rawTokens = result["generatedTokenIDs"] as? [Any],
              rawTokens.count == tokens.count, rawTokens.compactMap({ integer($0) }) == tokens,
              let events = result["events"] as? [[String: Any]], events.count == tokens.count,
              events.enumerated().allSatisfy({ NSDictionary(dictionary: $0.element).isEqual(to: observedEvents[$0.offset]) }),
              let rendered = result["renderedOutput"] as? String, rendered == lastOutput,
              let stop = result["stopReason"] as? String,
              (stop == "endOfSequence" && tokens.last == 70) || (stop == "tokenLimit" && tokens.count == maximumNewTokens && tokens.last != 70),
              let lease = object["sandbox_application_synchronization_lease"] as? [String: Any],
              lease["policy"] as? String == "signed_sandbox_application_internal_synchronization_v1",
              lease["applicationIdentifier"] as? String == "com.ergentics.provenance",
              lease["helperIdentifier"] as? String == "com.ergentics.provenance.prime-runtime" else {
            throw invalid("final result, checkpoint, or lease binding")
        }
        final = Value(renderedOutput: rendered, decodedText: result["decodedText"] as? String,
            tokens: tokens, finalLine: line)
    }
}
