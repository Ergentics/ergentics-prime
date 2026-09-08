// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
import PrimeCore
@testable import PrimeNativeDecoderTraining
import XCTest

final class PrimeNativeDecoderCurrentLocalGenerationTests: XCTestCase {
    typealias Generation = PrimeNativeDecoderCurrentLocalGeneration

    func testArbitraryPromptUsesNFCBytesAndBOSWithoutEOSOrTemplate() throws {
        let question = "e\u{301}\r\nHow?\0🙂"
        let value = try Generation.preparePrompt(question, maximumNewTokens: 8)
        XCTAssertEqual(value.canonical, "é\r\nHow?\0🙂")
        XCTAssertEqual(value.tokenIDs, [1] + value.canonical.utf8.map { 256 + Int($0) })
        XCTAssertFalse(value.tokenIDs.contains(70))
        XCTAssertNotEqual(value.tokenIDs, try Generation.preparePrompt("Different question", maximumNewTokens: 8).tokenIDs)
        for count in [0, 257, Int.max] {
            XCTAssertThrowsError(try Generation.preparePrompt("question", maximumNewTokens: count))
        }
        XCTAssertThrowsError(try Generation.preparePrompt("", maximumNewTokens: 1))
        XCTAssertThrowsError(try Generation.preparePrompt(String(repeating: "a", count: 1024), maximumNewTokens: 1))
        XCTAssertEqual(try Generation.preparePrompt(String(repeating: "a", count: 1023), maximumNewTokens: 256).tokenIDs.count, 1024)
    }

    func testGreedySelectionUsesAll512SymbolsAndLowestIDTieWithoutMasking() throws {
        var logits = [Float](repeating: -2, count: 512)
        logits[511] = 1
        XCTAssertEqual(try Generation.greedyToken(logits), 511)
        logits[2] = 1 // Reserved symbolic IDs remain valid model predictions.
        XCTAssertEqual(try Generation.greedyToken(logits), 2)
        logits[70] = 2
        XCTAssertEqual(try Generation.greedyToken(logits), 70)
        for invalid in [Float.nan, .infinity, -.infinity] {
            var changed = logits; changed[400] = invalid
            XCTAssertThrowsError(try Generation.greedyToken(changed))
        }
        XCTAssertThrowsError(try Generation.greedyToken(Array(logits.dropLast())))
        XCTAssertThrowsError(try Generation.greedyToken(logits + [0]))
    }

    func testActualSchedulingPrefillsThenFeedsOnlyPredictedTokensAndStopsAtEOS() throws {
        let prompt = try Generation.preparePrompt("Any question?", maximumNewTokens: 8).tokenIDs
        let predicted = [321, 2, 70]
        var chunks: [[Int]] = []
        var emitted: [Generation.TokenEvent] = []
        let result = try Generation.decode(promptTokenIDs: prompt, maximumNewTokens: 8,
            checkpoint: {}, forward: { chunk in
                chunks.append(chunk)
                var row = [Float](repeating: -1, count: 512)
                row[predicted[chunks.count - 1]] = Float(chunks.count)
                return row
            }, recordToken: { emitted.append($0) })
        XCTAssertEqual(chunks, [prompt, [321], [2]])
        XCTAssertEqual(result.tokens, predicted)
        XCTAssertEqual(result.stopReason, .endOfSequence)
        XCTAssertEqual(result.events, emitted)
        XCTAssertEqual(emitted.map(\.cachePosition), [prompt.count, prompt.count + 1, prompt.count + 2])
        XCTAssertEqual(emitted.map(\.ordinal), [0, 1, 2])
        for (event, selected) in zip(emitted, predicted) {
            XCTAssertEqual(event.logitFloat32Bits.count, 512)
            XCTAssertEqual(try Generation.greedyToken(event.logitFloat32Bits.map(Float.init(bitPattern:))), selected)
            var bytes = Data()
            for value in event.logitFloat32Bits {
                var little = value.littleEndian
                withUnsafeBytes(of: &little) { bytes.append(contentsOf: $0) }
            }
            XCTAssertEqual(event.logitFloat32LittleEndianSHA256, PrimeSHA256.hexDigest(of: bytes))
            XCTAssertEqual(try PrimeCanonicalJSON.decode(Generation.TokenEvent.self, from: PrimeCanonicalJSON.encode(event)), event)
        }
    }

    func testTokenLimitAndFailureDoNotDispatchAnExtraForward() throws {
        enum TestFailure: Error { case stop }
        var forwards = 0
        let row = [Float](repeating: 0, count: 512)
        let result = try Generation.decode(promptTokenIDs: [1, 321], maximumNewTokens: 2,
            checkpoint: {}, forward: { _ in forwards += 1; return row }, recordToken: { _ in })
        XCTAssertEqual(forwards, 2)
        XCTAssertEqual(result.tokens, [0, 0])
        XCTAssertEqual(result.stopReason, .tokenLimit)
        forwards = 0
        XCTAssertThrowsError(try Generation.decode(promptTokenIDs: [1, 321], maximumNewTokens: 2,
            checkpoint: { throw TestFailure.stop }, forward: { _ in forwards += 1; return row }, recordToken: { _ in }))
        XCTAssertEqual(forwards, 0)
        XCTAssertThrowsError(try Generation.decode(promptTokenIDs: [1, 321], maximumNewTokens: 2,
            checkpoint: {}, forward: { _ in forwards += 1; return row }, recordToken: { _ in throw TestFailure.stop }))
        XCTAssertEqual(forwards, 1)
        var checkpoints = 0
        forwards = 0
        XCTAssertThrowsError(try Generation.decode(promptTokenIDs: [1, 321], maximumNewTokens: 2,
            checkpoint: { checkpoints += 1; if checkpoints == 2 { throw TestFailure.stop } },
            forward: { _ in forwards += 1; return row }, recordToken: { _ in XCTFail("Expired forward must not emit") }))
        XCTAssertEqual(forwards, 1)
    }

    func testRenderingPreservesReservedTokensInvalidBytesAndUnnormalizedOutput() throws {
        let decomposed = "e\u{301}"
        let tokens = decomposed.utf8.map { 256 + Int($0) }
        let output = try Generation.render(tokenIDs: tokens + [70])
        XCTAssertEqual(Array(try XCTUnwrap(output.decodedText).utf8), Array(decomposed.utf8))
        XCTAssertEqual(output.renderedOutput, decomposed + "⟦token:70⟧")
        let symbolic = try Generation.render(tokenIDs: [321, 2, 322])
        XCTAssertEqual(symbolic.renderedOutput, "A⟦token:2⟧B")
        XCTAssertNil(symbolic.decodedText)
        let invalid = try Generation.render(tokenIDs: [511, 70])
        XCTAssertEqual(invalid.renderedOutput, "⟦bytes:ff⟧⟦token:70⟧")
        XCTAssertNil(invalid.decodedText)
        XCTAssertNil(try Generation.render(tokenIDs: [70, 321]).decodedText)
        XCTAssertThrowsError(try Generation.render(tokenIDs: [-1]))
        XCTAssertThrowsError(try Generation.render(tokenIDs: [512]))
        XCTAssertThrowsError(try Generation.render(tokenIDs: Array(repeating: 321, count: 257)))
    }
}
