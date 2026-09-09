import Darwin
import Foundation
import XCTest

final class PrimePromptTests: XCTestCase {
    // Synthetic protocol fixtures only. No model, weights, helper process, or
    // scientific inference result is constructed or validated by these tests.
    private let commit = String(repeating: "a", count: 64)
    private var weights: [String: Any] {
        ["relativePath": "baseline_checkpoint/weights.safetensors", "byteCount": 1,
         "purpose": "immutable_data", "sha256": String(repeating: "b", count: 64)]
    }

    private func rows() -> [[String: Any]] {
        let events: [[String: Any]] = (0..<2).map { ordinal in
            ["ordinal": ordinal, "tokenID": 100 + ordinal, "cachePosition": 5 + ordinal,
             "logitFloat32Bits": Array(repeating: 0, count: 512),
             "logitFloat32LittleEndianSHA256": String(repeating: "c", count: 64)]
        }
        return [
            ["type": "token", "event": events[0], "renderedOutput": "ré", "decodedText": "ré"],
            ["type": "token", "event": events[1], "renderedOutput": "résultat", "decodedText": "résultat"],
            ["type": "result", "result": [
                "schema": "prime_current_local_native300m_generation_v1", "question": "synthetic question",
                "canonicalQuestion": "synthetic question", "checkpointCommitSHA256": commit,
                "weightsBinding": weights, "generatedTokenIDs": [100, 101], "events": events,
                "renderedOutput": "résultat", "decodedText": "résultat", "stopReason": "tokenLimit",
            ], "sandbox_application_synchronization_lease": [
                "policy": "signed_sandbox_application_internal_synchronization_v1",
                "applicationIdentifier": "com.ergentics.provenance",
                "helperIdentifier": "com.ergentics.provenance.prime-runtime",
            ]],
        ]
    }

    private func encode(_ value: [String: Any]) throws -> Data {
        try JSONSerialization.data(withJSONObject: value, options: [.sortedKeys, .withoutEscapingSlashes])
    }

    private func encodedRows(_ rows: [[String: Any]]) throws -> Data {
        try rows.reduce(into: Data()) { result, row in result.append(try encode(row)); result.append(10) }
    }

    private func withStream(_ body: (PrimePromptStream, PrimeRuntimeCancellation, PromptProgressRecorder) throws -> Void) throws {
        let fd = open("/dev/null", O_WRONLY | O_CLOEXEC)
        XCTAssertGreaterThanOrEqual(fd, 0)
        guard fd >= 0 else { return }
        defer { close(fd) }
        let cancellation = PrimeRuntimeCancellation()
        let progress = PromptProgressRecorder()
        let stream = PrimePromptStream(question: "synthetic question", maximumNewTokens: 2,
            expectedCommit: commit, expectedWeights: weights, descriptor: fd,
            cancellation: cancellation, onProgress: { progress.append($0) })
        try body(stream, cancellation, progress)
    }

    func testPromptStreamAcceptsChunkedJSONLAndPreservesExactFinalRow() throws {
        let original = rows()
        let bytes = try encodedRows(original)
        try withStream { stream, cancellation, progress in
            // Includes cuts within JSON values, escaped fields, and UTF-8.
            var offset = 0
            let sizes = [1, 2, 7, 31]
            while offset < bytes.count {
                let end = min(bytes.count, offset + sizes[offset % sizes.count])
                stream.consume(Data(bytes[offset..<end])); offset = end
            }
            let result = try stream.finish()
            XCTAssertEqual(result.tokens, [100, 101])
            XCTAssertEqual(result.renderedOutput, "résultat")
            XCTAssertEqual(result.decodedText, "résultat")
            XCTAssertEqual(result.finalLine, try encode(original[2]))
            XCTAssertEqual(progress.values, ["ré", "résultat"])
            XCTAssertNil(stream.failure)
            XCTAssertFalse(cancellation.isCancelled)
        }
    }

    func testPromptStreamRejectsTokenAndFinalBindingMismatches() throws {
        let original = rows()
        var cases: [[[String: Any]]] = []
        for (field, value) in [("ordinal", 1 as Any), ("tokenID", true as Any)] {
            var changed = original
            var event = changed[0]["event"] as! [String: Any]
            event[field] = value; changed[0]["event"] = event; cases.append(changed)
        }
        for field in ["checkpointCommitSHA256", "weightsBinding", "events", "generatedTokenIDs", "renderedOutput"] {
            var changed = original
            var final = changed[2]["result"] as! [String: Any]
            switch field {
            case "checkpointCommitSHA256": final[field] = String(repeating: "d", count: 64)
            case "weightsBinding": var binding = weights; binding["byteCount"] = 2; final[field] = binding
            case "events":
                var events = final[field] as! [[String: Any]]
                events[1]["logitFloat32Bits"] = Array(repeating: 1, count: 512)
                final[field] = events
            case "generatedTokenIDs": final[field] = [100, 102]
            default: final[field] = "different output"
            }
            changed[2]["result"] = final; cases.append(changed)
        }
        for (index, rows) in cases.enumerated() {
            try withStream { stream, cancellation, _ in
                stream.consume(try encodedRows(rows))
                XCTAssertThrowsError(try stream.finish(), "mutation \(index)")
                XCTAssertNotNil(stream.failure, "mutation \(index)")
                XCTAssertTrue(cancellation.isCancelled, "mutation \(index)")
            }
        }
    }

    func testPromptStreamRejectsMissingTruncatedAndUnterminatedResponses() throws {
        let original = rows()
        let complete = try encodedRows(original)
        let partials = [try encodedRows(Array(original.prefix(2))), Data(complete.dropLast()),
                        Data(complete.dropLast(17)), complete + Data("trailing fragment".utf8)]
        for bytes in partials {
            try withStream { stream, _, _ in
                stream.consume(bytes)
                XCTAssertThrowsError(try stream.finish())
            }
        }
    }

    func testPromptStreamRetainsInvalidOutputFailureAfterCancellationAndLaterBytes() throws {
        try withStream { stream, cancellation, progress in
            stream.consume(Data("{invalid JSON}\n".utf8))
            let failure = try XCTUnwrap(stream.failure)
            XCTAssertTrue(cancellation.isCancelled)
            stream.consume(try encodedRows(rows()))
            XCTAssertEqual(stream.failure?.message, failure.message)
            XCTAssertTrue(progress.values.isEmpty)
            XCTAssertThrowsError(try stream.finish()) { error in
                XCTAssertFalse(error is CancellationError)
                XCTAssertEqual((error as? PrimeRuntimeFailure)?.message, failure.message)
            }
        }
    }
}

private final class PromptProgressRecorder: @unchecked Sendable {
    private let lock = NSLock()
    private var entries: [String] = []
    func append(_ text: String) { lock.lock(); entries.append(text); lock.unlock() }
    var values: [String] { lock.lock(); defer { lock.unlock() }; return entries }
}
