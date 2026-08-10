// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import PrimeCore
import Foundation
import CoreGraphics
import MLX
import MLXNN
import Metal
import XCTest

@testable import PrimeNativeDecoder

final class PrimeNativeGQADecoderTests: XCTestCase {
    func testSyntheticFixtureIsTrueGQAAndHasExactDerivedCount() throws {
        let configuration = try PrimeNativeGQADecoderConfiguration
            .syntheticFixture()

        XCTAssertEqual(
            PrimeNativeGQADecoderConfiguration.architectureSchema,
            PrimeNativeDecoderDerivedDeltaPlan.frozenV1.architectureSchema)
        XCTAssertEqual(
            PrimeNativeGQADecoderConfiguration.implementationID,
            PrimeNativeDecoderDerivedDeltaPlan.frozenV1
                .authoritativeImplementationID)
        XCTAssertEqual(configuration.vocabularySize, 32)
        XCTAssertEqual(configuration.modelWidth, 16)
        XCTAssertEqual(configuration.layerCount, 2)
        XCTAssertEqual(configuration.queryHeadCount, 4)
        XCTAssertEqual(configuration.keyValueHeadCount, 2)
        XCTAssertEqual(configuration.queryHeadsPerKeyValueHead, 2)
        XCTAssertEqual(configuration.keyValueProjectionWidth, 8)
        XCTAssertEqual(configuration.headWidth, 4)
        XCTAssertEqual(configuration.intermediateWidth, 32)
        XCTAssertEqual(configuration.maximumSequenceLength, 16)
        XCTAssertEqual(configuration.uniqueParameterCount, 5_200)
    }

    func testNative300MInventoryIsRepresentableWithoutAllocation() throws {
        let byte512 = try PrimeNativeGQADecoderConfiguration
            .native300MInventory(vocabularySize: 512)
        let latinBPE = try PrimeNativeGQADecoderConfiguration
            .native300MInventory(vocabularySize: 16_384)

        XCTAssertEqual(byte512.modelWidth, 1_024)
        XCTAssertEqual(byte512.layerCount, 24)
        XCTAssertEqual(byte512.queryHeadCount, 16)
        XCTAssertEqual(byte512.keyValueHeadCount, 4)
        XCTAssertEqual(byte512.headWidth, 64)
        XCTAssertEqual(byte512.intermediateWidth, 2_816)
        XCTAssertEqual(byte512.maximumSequenceLength, 2_048)
        XCTAssertEqual(byte512.ropeTheta, 10_000)
        XCTAssertEqual(byte512.uniqueParameterCount, 271_107_072)
        XCTAssertEqual(latinBPE.uniqueParameterCount, 287_360_000)
    }

    func testLogic10MGeometryIsRepresentableWithoutParityClaim() throws {
        let logic = try PrimeNativeGQADecoderConfiguration.logic10MInventory()

        XCTAssertEqual(logic.vocabularySize, 16_384)
        XCTAssertEqual(logic.modelWidth, 256)
        XCTAssertEqual(logic.layerCount, 8)
        XCTAssertEqual(logic.queryHeadCount, 4)
        XCTAssertEqual(logic.keyValueHeadCount, 4)
        XCTAssertEqual(logic.headWidth, 64)
        XCTAssertEqual(logic.intermediateWidth, 640)
        XCTAssertEqual(logic.maximumSequenceLength, 2_048)
        XCTAssertEqual(logic.ropeTheta, 10_000)
        XCTAssertEqual(logic.rmsNormEpsilon, 1e-6)
        XCTAssertEqual(logic.uniqueParameterCount, 10_227_968)
        XCTAssertEqual(
            PrimeNativeDecoderDerivedDeltaPlan.frozenV1
                .logic10MConformanceProfileDisposition,
            "representable_with_equal_query_and_kv_heads_parity_not_claimed")
    }

    func testConfigurationValidationFailsClosed() throws {
        XCTAssertThrowsError(
            try configuration(modelWidth: 15)
        ) { error in
            XCTAssertEqual(
                error as? PrimeNativeGQADecoderConfigurationError,
                .modelWidthMismatch(expected: 16, observed: 15))
        }

        XCTAssertThrowsError(
            try configuration(
                modelWidth: 24,
                queryHeadCount: 6,
                keyValueHeadCount: 4,
                headWidth: 4)
        ) { error in
            XCTAssertEqual(
                error as? PrimeNativeGQADecoderConfigurationError,
                .queryHeadGroupingInvalid(queryHeads: 6, keyValueHeads: 4))
        }

        XCTAssertThrowsError(
            try configuration(
                modelWidth: 15,
                queryHeadCount: 3,
                keyValueHeadCount: 1,
                headWidth: 5)
        ) { error in
            XCTAssertEqual(
                error as? PrimeNativeGQADecoderConfigurationError,
                .rotaryHeadWidthMustBeEven(5))
        }

        XCTAssertThrowsError(
            try configuration(vocabularySize: 0)
        ) { error in
            XCTAssertEqual(
                error as? PrimeNativeGQADecoderConfigurationError,
                .nonPositive("vocabulary_size"))
        }

        XCTAssertThrowsError(
            try configuration(rmsNormEpsilon: .nan)
        ) { error in
            guard case .invalidRMSNormEpsilon(let value) =
                    error as? PrimeNativeGQADecoderConfigurationError
            else {
                return XCTFail("unexpected error: \(error)")
            }
            XCTAssertTrue(value.isNaN)
        }

        XCTAssertThrowsError(
            try configuration(ropeTheta: .infinity)
        ) { error in
            XCTAssertEqual(
                error as? PrimeNativeGQADecoderConfigurationError,
                .invalidRoPETheta(.infinity))
        }

        XCTAssertThrowsError(
            try configuration(
                modelWidth: 1,
                queryHeadCount: Int.max,
                keyValueHeadCount: 1,
                headWidth: 2)
        ) { error in
            XCTAssertEqual(
                error as? PrimeNativeGQADecoderConfigurationError,
                .parameterCountOverflow)
        }

        XCTAssertThrowsError(
            try configuration(
                vocabularySize: 1,
                modelWidth: 2_000_000_000,
                layerCount: 1,
                queryHeadCount: 1,
                keyValueHeadCount: 1,
                headWidth: 2_000_000_000,
                intermediateWidth: 2_000_000_000,
                maximumSequenceLength: 1)
        ) { error in
            XCTAssertEqual(
                error as? PrimeNativeGQADecoderConfigurationError,
                .parameterCountOverflow)
        }

        let outsideInt32 = Int(Int32.max) + 1
        XCTAssertThrowsError(
            try configuration(vocabularySize: outsideInt32)
        ) { error in
            XCTAssertEqual(
                error as? PrimeNativeGQADecoderConfigurationError,
                .runtimeDimensionExceedsInt32(
                    name: "vocabulary_size",
                    value: outsideInt32))
        }
        XCTAssertThrowsError(
            try configuration(maximumSequenceLength: outsideInt32)
        ) { error in
            XCTAssertEqual(
                error as? PrimeNativeGQADecoderConfigurationError,
                .runtimeDimensionExceedsInt32(
                    name: "maximum_sequence_length",
                    value: outsideInt32))
        }
    }

    func testCacheArithmeticIsPureAndFailClosedWithoutMetal() throws {
        XCTAssertEqual(
            try PrimeNativeGQADecoderCache.validatedBatchSize(1),
            1)
        XCTAssertThrowsError(
            try PrimeNativeGQADecoderCache.validatedBatchSize(0)
        ) { error in
            XCTAssertEqual(
                error as? PrimeNativeGQADecoderCacheError,
                .nonPositiveBatchSize(0))
        }
        let outsideInt32 = Int(Int32.max) + 1
        XCTAssertThrowsError(
            try PrimeNativeGQADecoderCache.validatedBatchSize(
                outsideInt32)
        ) { error in
            XCTAssertEqual(
                error as? PrimeNativeGQADecoderCacheError,
                .batchSizeExceedsInt32(outsideInt32))
        }

        XCTAssertEqual(
            PrimeNativeGQALayerCacheState.storageCapacity(
                required: 1,
                maximum: 2_048),
            256)
        XCTAssertEqual(
            PrimeNativeGQALayerCacheState.storageCapacity(
                required: 257,
                maximum: 2_048),
            512)
        XCTAssertEqual(
            PrimeNativeGQALayerCacheState.storageCapacity(
                required: 2_048,
                maximum: 2_048),
            2_048)
        XCTAssertEqual(
            PrimeNativeGQALayerCacheState.storageCapacity(
                required: 3,
                maximum: 16),
            16)

        XCTAssertEqual(
            try PrimeNativeGQADecoderCache.validatedNextPosition(
                current: 3,
                appending: 2,
                maximum: 16),
            5)
        XCTAssertThrowsError(
            try PrimeNativeGQADecoderCache.validatedNextPosition(
                current: 15,
                appending: 2,
                maximum: 16)
        ) { error in
            XCTAssertEqual(
                error as? PrimeNativeGQADecoderInputError,
                .sequenceExceedsMaximum(
                    offset: 15,
                    count: 2,
                    maximum: 16))
        }
    }

    func testParameterInventoryIsExactAndOutputProjectionIsTied() throws {
        try requireMetal()
        let configuration = try PrimeNativeGQADecoderConfiguration
            .syntheticFixture()
        let model = PrimeNativeGQADecoder.make(
            configuration: configuration,
            seed: 7)
        eval(model)

        let parameters = model.parameters().flattened()
        let observedShapes = Dictionary(
            uniqueKeysWithValues: parameters.map { ($0.0, $0.1.shape) })
        var expectedShapes: [String: [Int]] = [
            "token_embedding.weight": [32, 16],
            "final_norm.weight": [16],
        ]
        for layer in 0 ..< 2 {
            let prefix = "layers.\(layer)"
            expectedShapes["\(prefix).attention_norm.weight"] = [16]
            expectedShapes["\(prefix).attention.query_projection.weight"] = [16, 16]
            expectedShapes["\(prefix).attention.key_projection.weight"] = [8, 16]
            expectedShapes["\(prefix).attention.value_projection.weight"] = [8, 16]
            expectedShapes["\(prefix).attention.output_projection.weight"] = [16, 16]
            expectedShapes["\(prefix).feed_forward_norm.weight"] = [16]
            expectedShapes["\(prefix).feed_forward.gate_projection.weight"] = [32, 16]
            expectedShapes["\(prefix).feed_forward.up_projection.weight"] = [32, 16]
            expectedShapes["\(prefix).feed_forward.down_projection.weight"] = [16, 32]
        }

        XCTAssertEqual(observedShapes, expectedShapes)
        XCTAssertFalse(observedShapes.keys.contains { $0.contains("position") })
        XCTAssertFalse(observedShapes.keys.contains { $0.contains("lm_head") })
        XCTAssertFalse(observedShapes.keys.contains { $0.contains("bias") })
        let observedCount = parameters.reduce(Int64(0)) {
            $0 + Int64($1.1.size)
        }
        XCTAssertEqual(observedCount, configuration.uniqueParameterCount)
        XCTAssertTrue(parameters.allSatisfy { $0.1.dtype == .float32 })
        XCTAssertTrue(
            parameters.allSatisfy {
                $0.1.asArray(Float.self).allSatisfy { $0.isFinite }
            })
    }

    func testUnequalHeadGQAForwardIsFiniteAndCausal() throws {
        try requireMetal()
        let configuration = try PrimeNativeGQADecoderConfiguration
            .syntheticFixture()
        let model = PrimeNativeGQADecoder.make(
            configuration: configuration,
            seed: 19)
        eval(model)

        let prefix = try model.forward(tokenIDs: [1, 2, 3])
        let extended = try model.forward(tokenIDs: [1, 2, 3, 4, 5])
        let extendedPrefix = extended[0..., 0 ..< 3, 0...]
        eval(prefix, extended, extendedPrefix)

        XCTAssertEqual(prefix.shape, [1, 3, 32])
        XCTAssertEqual(extended.shape, [1, 5, 32])
        XCTAssertTrue(
            extended.asArray(Float.self).allSatisfy { $0.isFinite })

        let prefixValues = prefix.asArray(Float.self)
        let extendedPrefixValues = extendedPrefix.asArray(Float.self)
        XCTAssertEqual(prefixValues.count, extendedPrefixValues.count)
        for (lhs, rhs) in zip(prefixValues, extendedPrefixValues) {
            XCTAssertEqual(lhs, rhs, accuracy: 1e-5)
        }
    }

    func testProjectedQKVHasExactHeadShapesAndRoPEOffsetScope() throws {
        try requireMetal()
        let configuration = try PrimeNativeGQADecoderConfiguration
            .syntheticFixture()
        let attention = withRandomState(
            MLXRandom.RandomState(seed: 31)
        ) {
            PrimeNativeGQAAttention(configuration: configuration)
        }
        let input = MLXArray(
            (0 ..< 48).map { Float($0 - 24) / 16 },
            [1, 3, 16])
        let atZero = attention.projectedQueriesKeysValues(
            input,
            positionOffset: 0)
        let shifted = attention.projectedQueriesKeysValues(
            input,
            positionOffset: 3)
        eval(
            atZero.queries,
            atZero.keys,
            atZero.values,
            shifted.queries,
            shifted.keys,
            shifted.values)

        XCTAssertEqual(atZero.queries.shape, [1, 4, 3, 4])
        XCTAssertEqual(atZero.keys.shape, [1, 2, 3, 4])
        XCTAssertEqual(atZero.values.shape, [1, 2, 3, 4])
        XCTAssertNotEqual(
            atZero.queries.asArray(Float.self),
            shifted.queries.asArray(Float.self))
        XCTAssertNotEqual(
            atZero.keys.asArray(Float.self),
            shifted.keys.asArray(Float.self))
        XCTAssertEqual(
            atZero.values.asArray(Float.self),
            shifted.values.asArray(Float.self))

        let firstOneTokenRow = (0 ..< 16).map {
            Float($0 - 8) / 8
        }
        let secondOneTokenRow = (0 ..< 16).map {
            Float(16 - $0) / 9
        }
        let batchedOneToken = MLXArray(
            firstOneTokenRow + secondOneTokenRow,
            [2, 1, 16])
        let batchedShifted = attention.projectedQueriesKeysValues(
            batchedOneToken,
            positionOffset: 3)
        let firstShifted = attention.projectedQueriesKeysValues(
            MLXArray(firstOneTokenRow, [1, 1, 16]),
            positionOffset: 3)
        let secondShifted = attention.projectedQueriesKeysValues(
            MLXArray(secondOneTokenRow, [1, 1, 16]),
            positionOffset: 3)
        eval(
            batchedShifted.queries,
            batchedShifted.keys,
            batchedShifted.values,
            firstShifted.queries,
            firstShifted.keys,
            firstShifted.values,
            secondShifted.queries,
            secondShifted.keys,
            secondShifted.values)
        assertClose(batchedShifted.queries[0], firstShifted.queries[0])
        assertClose(batchedShifted.keys[0], firstShifted.keys[0])
        assertClose(batchedShifted.values[0], firstShifted.values[0])
        assertClose(batchedShifted.queries[1], secondShifted.queries[0])
        assertClose(batchedShifted.keys[1], secondShifted.keys[0])
        assertClose(batchedShifted.values[1], secondShifted.values[0])
    }

    func testPinnedCausalSDPAMatchesScalarGQAReference() throws {
        try requireMetal()
        let queryHeadCount = 4
        let keyValueHeadCount = 2
        let sequenceLength = 3
        let headWidth = 2
        let queries = (0 ..< 24).map { Float(($0 % 7) - 3) / 4 }
        let keys = (0 ..< 12).map { Float(($0 % 5) - 2) / 3 }
        let values = (0 ..< 12).map { Float($0 - 5) / 5 }
        let scale = 1 / sqrt(Float(headWidth))

        let observed = MLXFast.scaledDotProductAttention(
            queries: MLXArray(
                queries,
                [1, queryHeadCount, sequenceLength, headWidth]),
            keys: MLXArray(
                keys,
                [1, keyValueHeadCount, sequenceLength, headWidth]),
            values: MLXArray(
                values,
                [1, keyValueHeadCount, sequenceLength, headWidth]),
            scale: scale,
            mask: .causal)
        eval(observed)

        let expected = scalarCausalGQA(
            queries: queries,
            keys: keys,
            values: values,
            queryHeadCount: queryHeadCount,
            keyValueHeadCount: keyValueHeadCount,
            sequenceLength: sequenceLength,
            headWidth: headWidth,
            scale: scale)
        let actual = observed.asArray(Float.self)
        XCTAssertEqual(actual.count, expected.count)
        for (lhs, rhs) in zip(actual, expected) {
            XCTAssertEqual(lhs, rhs, accuracy: 1e-5)
        }
    }

    func testSeededConstructionIsDeterministicAndSeedSensitive() throws {
        try requireMetal()
        let configuration = try PrimeNativeGQADecoderConfiguration
            .syntheticFixture()
        let first = PrimeNativeGQADecoder.make(
            configuration: configuration,
            seed: 1618)
        let replay = PrimeNativeGQADecoder.make(
            configuration: configuration,
            seed: 1618)
        let alternate = PrimeNativeGQADecoder.make(
            configuration: configuration,
            seed: 1619)
        eval(first, replay, alternate)

        let firstParameters = first.parameters().flattened()
        let replayParameters = replay.parameters().flattened()
        let alternateParameters = alternate.parameters().flattened()
        XCTAssertEqual(firstParameters.map(\.0), replayParameters.map(\.0))
        XCTAssertEqual(firstParameters.map(\.0), alternateParameters.map(\.0))

        var alternateDifferenceObserved = false
        for index in firstParameters.indices {
            let lhs = firstParameters[index].1.asArray(Float.self)
            let replayed = replayParameters[index].1.asArray(Float.self)
            let changed = alternateParameters[index].1.asArray(Float.self)
            XCTAssertEqual(lhs, replayed)
            if lhs != changed {
                alternateDifferenceObserved = true
            }
        }
        XCTAssertTrue(alternateDifferenceObserved)

        let firstLogits = try first.forward(tokenIDs: [2, 4, 6, 8])
        let replayLogits = try replay.forward(tokenIDs: [2, 4, 6, 8])
        eval(firstLogits, replayLogits)
        XCTAssertEqual(
            firstLogits.asArray(Float.self),
            replayLogits.asArray(Float.self))
    }

    func testInputValidationRejectsUnsupportedSequences() throws {
        try requireMetal()
        let configuration = try PrimeNativeGQADecoderConfiguration
            .syntheticFixture()
        let model = PrimeNativeGQADecoder.make(
            configuration: configuration)

        XCTAssertThrowsError(try model.forward(tokenIDs: [])) { error in
            XCTAssertEqual(
                error as? PrimeNativeGQADecoderInputError,
                .emptyTokenSequence)
        }
        XCTAssertThrowsError(try model.forward(tokenIDs: [0, 32])) { error in
            XCTAssertEqual(
                error as? PrimeNativeGQADecoderInputError,
                .tokenIDOutOfRange(index: 1, value: 32, vocabularySize: 32))
        }
        XCTAssertThrowsError(
            try model.forward(tokenIDs: [1, 2], positionOffset: -1)
        ) { error in
            XCTAssertEqual(
                error as? PrimeNativeGQADecoderInputError,
                .negativePositionOffset(-1))
        }
        XCTAssertThrowsError(
            try model.forward(tokenIDs: [1, 2], positionOffset: 1)
        ) { error in
            XCTAssertEqual(
                error as? PrimeNativeGQADecoderInputError,
                .nonZeroPositionOffsetRequiresCache(1))
        }
        XCTAssertThrowsError(
            try model.forward(
                tokenIDs: Array(repeating: 1, count: 17))
        ) { error in
            XCTAssertEqual(
                error as? PrimeNativeGQADecoderInputError,
                .sequenceExceedsMaximum(offset: 0, count: 17, maximum: 16))
        }
    }

    func testCachePrefillAndSingleTokenDecodeMatchFullPrefix() throws {
        try requireMetal()
        let configuration = try PrimeNativeGQADecoderConfiguration
            .syntheticFixture()
        let model = PrimeNativeGQADecoder.make(
            configuration: configuration,
            seed: 101)
        let cache = try model.makeCache(batchSize: 1)
        XCTAssertTrue(cache.isEmpty)
        XCTAssertEqual(cache.position, 0)
        XCTAssertEqual(cache.layerCount, configuration.layerCount)
        XCTAssertEqual(
            cache.keyValueHeadCount,
            configuration.keyValueHeadCount)
        XCTAssertEqual(cache.headWidth, configuration.headWidth)

        var prefix = [1, 2, 3]
        let cachedPrefill = try model.forward(
            tokenIDs: prefix,
            cache: cache)
        let fullPrefill = try model.forward(tokenIDs: prefix)
        XCTAssertTrue(cache.isMaterializationPending)
        try cache.materialize()
        XCTAssertFalse(cache.isMaterializationPending)
        eval(fullPrefill)
        assertClose(cachedPrefill, fullPrefill)
        XCTAssertFalse(cache.isEmpty)
        XCTAssertEqual(cache.position, 3)
        assertCacheShapes(
            cache,
            batchSize: 1,
            sequenceLength: 3,
            configuration: configuration)

        for token in [4, 5, 6] {
            let cached = try model.forward(
                tokenIDs: [token],
                cache: cache)
            prefix.append(token)
            let full = try model.forward(tokenIDs: prefix)
            let cachedLast = cached[0, -1, 0...]
            let fullLast = full[0, -1, 0...]
            try cache.materialize()
            eval(fullLast)
            assertClose(cachedLast, fullLast)
            XCTAssertEqual(cache.position, prefix.count)
            assertCacheShapes(
                cache,
                batchSize: 1,
                sequenceLength: prefix.count,
                configuration: configuration)
        }
    }

    func testCacheSupportsRectangularBatchAndCausalChunkContinuation() throws {
        try requireMetal()
        let configuration = try PrimeNativeGQADecoderConfiguration
            .syntheticFixture()
        let model = PrimeNativeGQADecoder.make(
            configuration: configuration,
            seed: 103)
        let cache = try model.makeCache(batchSize: 2)
        var prefixes = [
            [1, 2, 3],
            [7, 8, 9],
        ]

        let cachedPrefill = try model.forward(
            batchTokenIDs: prefixes,
            cache: cache)
        let fullPrefill = model(
            MLXArray(prefixes.flatMap { $0 }).reshaped(2, 3))
        try cache.materialize()
        eval(fullPrefill)
        assertClose(cachedPrefill, fullPrefill)

        let oneToken = [[4], [10]]
        let cachedToken = try model.forward(
            batchTokenIDs: oneToken,
            cache: cache)
        for row in prefixes.indices {
            prefixes[row].append(oneToken[row][0])
        }
        let fullAfterToken = model(
            MLXArray(prefixes.flatMap { $0 }).reshaped(2, 4))
        try cache.materialize()
        eval(fullAfterToken)
        assertClose(
            cachedToken[0..., -1, 0...],
            fullAfterToken[0..., -1, 0...])

        let twoTokenChunk = [
            [5, 6],
            [11, 12],
        ]
        let cachedChunk = try model.forward(
            batchTokenIDs: twoTokenChunk,
            cache: cache)
        for row in prefixes.indices {
            prefixes[row].append(contentsOf: twoTokenChunk[row])
        }
        let fullAfterChunk = model(
            MLXArray(prefixes.flatMap { $0 }).reshaped(2, 6))
        try cache.materialize()
        eval(fullAfterChunk)
        assertClose(
            cachedChunk,
            fullAfterChunk[0..., 4 ..< 6, 0...])
        XCTAssertEqual(cache.position, 6)
        assertCacheShapes(
            cache,
            batchSize: 2,
            sequenceLength: 6,
            configuration: configuration)
    }

    func testCacheCapacityGrowthPreservesPrefixAndParity() throws {
        try requireMetal()
        let configuration = try configuration(
            maximumSequenceLength: 512)
        let model = PrimeNativeGQADecoder.make(
            configuration: configuration,
            seed: 105)
        let cache = try model.makeCache(batchSize: 1)
        var prefix = (0 ..< 256).map {
            $0 % configuration.vocabularySize
        }

        _ = try model.forward(tokenIDs: prefix, cache: cache)
        try cache.materialize()
        XCTAssertEqual(cache.position, 256)
        assertCacheShapes(
            cache,
            batchSize: 1,
            sequenceLength: 256,
            configuration: configuration)

        let continuation = [7, 11]
        let cached = try model.forward(
            tokenIDs: continuation,
            cache: cache)
        prefix.append(contentsOf: continuation)
        let full = try model.forward(tokenIDs: prefix)
        try cache.materialize()
        eval(full)
        assertClose(cached, full[0..., 256 ..< 258, 0...])
        XCTAssertEqual(cache.position, 258)
        assertCacheShapes(
            cache,
            batchSize: 1,
            sequenceLength: 258,
            configuration: configuration)
    }

    func testCacheRejectsParameterRevisionMixingUntilReset() throws {
        try requireMetal()
        let configuration = try PrimeNativeGQADecoderConfiguration
            .syntheticFixture()
        let model = PrimeNativeGQADecoder.make(
            configuration: configuration,
            seed: 106)
        let cache = try model.makeCache(batchSize: 1)
        _ = try model.forward(tokenIDs: [1, 2, 3], cache: cache)
        try cache.materialize()

        _ = model.apply { parameter in
            parameter + Float(0.001)
        }
        XCTAssertThrowsError(
            try model.forward(tokenIDs: [4], cache: cache)
        ) { error in
            guard case .modelParametersChanged(
                let expected,
                let observed
            ) = error as? PrimeNativeGQADecoderCacheError else {
                return XCTFail("unexpected error: \(error)")
            }
            XCTAssertEqual(expected, 0)
            XCTAssertGreaterThan(observed, expected)
        }
        XCTAssertEqual(cache.position, 3)

        cache.reset()
        _ = try model.forward(
            tokenIDs: [1, 2, 3],
            cache: cache)
        _ = model.apply { parameter in
            parameter + Float(0.001)
        }
        XCTAssertThrowsError(try cache.materialize()) { error in
            guard case .modelParametersChanged(
                let expected,
                let observed
            ) = error as? PrimeNativeGQADecoderCacheError else {
                return XCTFail("unexpected error: \(error)")
            }
            XCTAssertGreaterThan(observed, expected)
        }
        XCTAssertTrue(cache.isPoisoned)
        XCTAssertThrowsError(
            try model.forward(tokenIDs: [4], cache: cache)
        ) { error in
            XCTAssertEqual(
                error as? PrimeNativeGQADecoderCacheError,
                .cachePoisoned)
        }

        cache.reset()
        _ = try model.forward(
            tokenIDs: [1, 2, 3],
            cache: cache)
        try cache.materialize()
        XCTAssertFalse(cache.isPoisoned)
        XCTAssertEqual(cache.position, 3)
    }

    func testCacheValidationFailsBeforeMutationAndResetReplays() throws {
        try requireMetal()
        let configuration = try PrimeNativeGQADecoderConfiguration
            .syntheticFixture()
        let model = PrimeNativeGQADecoder.make(
            configuration: configuration,
            seed: 107)
        let otherModel = PrimeNativeGQADecoder.make(
            configuration: configuration,
            seed: 109)

        XCTAssertThrowsError(try model.makeCache(batchSize: 0)) { error in
            XCTAssertEqual(
                error as? PrimeNativeGQADecoderCacheError,
                .nonPositiveBatchSize(0))
        }

        let cache = try model.makeCache(batchSize: 1)
        let first = try model.forward(tokenIDs: [1, 2, 3], cache: cache)
        XCTAssertTrue(cache.isMaterializationPending)
        XCTAssertThrowsError(
            try model.forward(tokenIDs: [4], cache: cache)
        ) { error in
            XCTAssertEqual(
                error as? PrimeNativeGQADecoderCacheError,
                .materializationRequired(position: 3))
        }
        try cache.materialize()
        XCTAssertFalse(cache.isMaterializationPending)
        XCTAssertThrowsError(
            try cache.materialize()
        ) { error in
            XCTAssertEqual(
                error as? PrimeNativeGQADecoderCacheError,
                .noMaterializationPending)
        }
        XCTAssertEqual(cache.position, 3)

        XCTAssertThrowsError(
            try otherModel.forward(tokenIDs: [4], cache: cache)
        ) { error in
            XCTAssertEqual(
                error as? PrimeNativeGQADecoderCacheError,
                .decoderIdentityMismatch)
        }
        XCTAssertEqual(cache.position, 3)

        XCTAssertThrowsError(
            try model.forward(batchTokenIDs: [[4], [5]], cache: cache)
        ) { error in
            XCTAssertEqual(
                error as? PrimeNativeGQADecoderCacheError,
                .batchSizeMismatch(expected: 1, observed: 2))
        }
        XCTAssertEqual(cache.position, 3)

        XCTAssertThrowsError(
            try model.forward(tokenIDs: [32], cache: cache)
        ) { error in
            XCTAssertEqual(
                error as? PrimeNativeGQADecoderInputError,
                .tokenIDOutOfRange(
                    index: 0,
                    value: 32,
                    vocabularySize: 32))
        }
        XCTAssertEqual(cache.position, 3)

        let batchCache = try model.makeCache(batchSize: 2)
        XCTAssertThrowsError(
            try model.forward(
                batchTokenIDs: [[1, 2], [3]],
                cache: batchCache)
        ) { error in
            XCTAssertEqual(
                error as? PrimeNativeGQADecoderInputError,
                .raggedTokenBatch(row: 1, expected: 2, observed: 1))
        }
        XCTAssertTrue(batchCache.isEmpty)

        cache.reset()
        XCTAssertTrue(cache.isEmpty)
        XCTAssertEqual(cache.position, 0)
        XCTAssertTrue(cache.layerStateShapes.allSatisfy { $0 == nil })
        let replay = try model.forward(tokenIDs: [1, 2, 3], cache: cache)
        try cache.materialize()
        assertClose(first, replay)
    }

    func testCacheContextLimitFailsWithoutAdvancingState() throws {
        try requireMetal()
        let configuration = try PrimeNativeGQADecoderConfiguration
            .syntheticFixture()
        let model = PrimeNativeGQADecoder.make(
            configuration: configuration,
            seed: 113)
        let cache = try model.makeCache(batchSize: 1)
        let prefix = Array(repeating: 1, count: 15)
        _ = try model.forward(tokenIDs: prefix, cache: cache)
        try cache.materialize()
        XCTAssertEqual(cache.position, 15)

        XCTAssertThrowsError(
            try model.forward(tokenIDs: [2, 3], cache: cache)
        ) { error in
            XCTAssertEqual(
                error as? PrimeNativeGQADecoderInputError,
                .sequenceExceedsMaximum(offset: 15, count: 2, maximum: 16))
        }
        XCTAssertEqual(cache.position, 15)
        assertCacheShapes(
            cache,
            batchSize: 1,
            sequenceLength: 15,
            configuration: configuration)
    }

    func testCausalGQAAndRoPEAreDifferentiableWithoutTraining() throws {
        try requireMetal()
        let configuration = try PrimeNativeGQADecoderConfiguration
            .syntheticFixture()
        let model = PrimeNativeGQADecoder.make(
            configuration: configuration,
            seed: 23)
        eval(model)

        let input = MLXArray([Int32(1), 2, 3, 4]).reshaped(1, 4)
        let targets = MLXArray([Int32(2), 3, 4, 5]).reshaped(1, 4)
        func loss(
            model: PrimeNativeGQADecoder,
            input: MLXArray,
            targets: MLXArray
        ) -> MLXArray {
            crossEntropy(
                logits: model(input),
                targets: targets,
                axis: -1,
                reduction: .mean)
        }

        let valueAndGradient = valueAndGrad(model: model, loss)
        let (value, gradients) = valueAndGradient(model, input, targets)
        eval(value, gradients)

        XCTAssertTrue(value.item(Float.self).isFinite)
        let flattenedGradients = gradients.flattened()
        XCTAssertEqual(
            flattenedGradients.map(\.0),
            model.parameters().flattened().map(\.0))
        XCTAssertTrue(
            flattenedGradients.allSatisfy {
                $0.1.asArray(Float.self).allSatisfy { $0.isFinite }
            })
        XCTAssertTrue(
            flattenedGradients.contains {
                $0.1.asArray(Float.self).contains { abs($0) > 0 }
            })
        let gradientsByName = Dictionary(
            uniqueKeysWithValues: flattenedGradients)
        for layer in 0 ..< configuration.layerCount {
            for projection in [
                "query_projection",
                "key_projection",
                "value_projection",
                "output_projection",
            ] {
                let name = "layers.\(layer).attention.\(projection).weight"
                let values = try XCTUnwrap(gradientsByName[name])
                    .asArray(Float.self)
                XCTAssertTrue(
                    values.contains { abs($0) > 0 },
                    "expected a nonzero gradient for \(name)")
            }
        }
    }

    func testSeededFactoryDoesNotConsumeGlobalRandomState() throws {
        try requireMetal()
        let configuration = try PrimeNativeGQADecoderConfiguration
            .syntheticFixture()

        MLXRandom.seed(2_718)
        let expected = MLXRandom.uniform(Float(0) ..< Float(1), [8])
        eval(expected)

        MLXRandom.seed(2_718)
        _ = PrimeNativeGQADecoder.make(
            configuration: configuration,
            seed: 3_141)
        let observed = MLXRandom.uniform(Float(0) ..< Float(1), [8])
        eval(observed)

        XCTAssertEqual(
            observed.asArray(Float.self),
            expected.asArray(Float.self))
    }

    private func requireMetal() throws {
        try PrimeNativeDecoderCIMLXComputeEnvironmentPolicy
            .validateLaunched(
                environment: ProcessInfo.processInfo.environment)
        // Apple documents a CoreGraphics link requirement for default-device
        // discovery in nongraphical macOS executables. Referencing a concrete
        // symbol keeps that framework in this XCTest executable; it does not
        // bypass process-level Metal restrictions.
        _ = CGColorSpaceCreateDeviceRGB()
        guard MTLCreateSystemDefaultDevice() != nil else {
            throw XCTSkip(
                "Metal is unavailable in this process; run the execution "
                    + "tests from a Metal-capable macOS test host.")
        }
    }

    private func assertClose(
        _ lhs: MLXArray,
        _ rhs: MLXArray,
        accuracy: Float = 1e-5,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        eval(lhs, rhs)
        XCTAssertEqual(lhs.shape, rhs.shape, file: file, line: line)
        let left = lhs.asArray(Float.self)
        let right = rhs.asArray(Float.self)
        XCTAssertEqual(left.count, right.count, file: file, line: line)
        for (observed, expected) in zip(left, right) {
            XCTAssertEqual(
                observed,
                expected,
                accuracy: accuracy,
                file: file,
                line: line)
        }
    }

    private func assertCacheShapes(
        _ cache: PrimeNativeGQADecoderCache,
        batchSize: Int,
        sequenceLength: Int,
        configuration: PrimeNativeGQADecoderConfiguration,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(
            cache.layerStateShapes.count,
            configuration.layerCount,
            file: file,
            line: line)
        let expected = [
            batchSize,
            configuration.keyValueHeadCount,
            sequenceLength,
            configuration.headWidth,
        ]
        for state in cache.layerStateShapes {
            XCTAssertEqual(state?.keys, expected, file: file, line: line)
            XCTAssertEqual(state?.values, expected, file: file, line: line)
        }
        let roundedCapacity = min(
            configuration.maximumSequenceLength,
            ((sequenceLength
                + PrimeNativeGQALayerCacheState.capacityStep - 1)
                / PrimeNativeGQALayerCacheState.capacityStep)
                * PrimeNativeGQALayerCacheState.capacityStep)
        XCTAssertTrue(
            cache.layerStateCapacities.allSatisfy {
                $0 == roundedCapacity
            },
            file: file,
            line: line)
    }

    private func scalarCausalGQA(
        queries: [Float],
        keys: [Float],
        values: [Float],
        queryHeadCount: Int,
        keyValueHeadCount: Int,
        sequenceLength: Int,
        headWidth: Int,
        scale: Float
    ) -> [Float] {
        let queryHeadsPerKeyValueHead =
            queryHeadCount / keyValueHeadCount
        var result = Array(
            repeating: Float.zero,
            count: queryHeadCount * sequenceLength * headWidth)

        func index(_ head: Int, _ position: Int, _ dimension: Int) -> Int {
            (head * sequenceLength + position) * headWidth + dimension
        }

        for queryHead in 0 ..< queryHeadCount {
            let keyValueHead = queryHead / queryHeadsPerKeyValueHead
            for queryPosition in 0 ..< sequenceLength {
                var scores: [Float] = []
                for keyPosition in 0 ... queryPosition {
                    var dot = Float.zero
                    for dimension in 0 ..< headWidth {
                        dot += queries[
                            index(queryHead, queryPosition, dimension)]
                            * keys[
                                index(
                                    keyValueHead,
                                    keyPosition,
                                    dimension)]
                    }
                    scores.append(dot * scale)
                }
                let maximum = scores.max() ?? 0
                let exponentials = scores.map {
                    Float(Foundation.exp(Double($0 - maximum)))
                }
                let denominator = exponentials.reduce(0, +)
                for dimension in 0 ..< headWidth {
                    var weighted = Float.zero
                    for keyPosition in 0 ... queryPosition {
                        weighted += exponentials[keyPosition] / denominator
                            * values[
                                index(
                                    keyValueHead,
                                    keyPosition,
                                    dimension)]
                    }
                    result[index(
                        queryHead,
                        queryPosition,
                        dimension)] = weighted
                }
            }
        }
        return result
    }

    private func configuration(
        vocabularySize: Int = 32,
        modelWidth: Int = 16,
        layerCount: Int = 2,
        queryHeadCount: Int = 4,
        keyValueHeadCount: Int = 2,
        headWidth: Int = 4,
        intermediateWidth: Int = 32,
        maximumSequenceLength: Int = 16,
        ropeTheta: Float = 10_000,
        rmsNormEpsilon: Float = 1e-5
    ) throws -> PrimeNativeGQADecoderConfiguration {
        try PrimeNativeGQADecoderConfiguration(
            vocabularySize: vocabularySize,
            modelWidth: modelWidth,
            layerCount: layerCount,
            queryHeadCount: queryHeadCount,
            keyValueHeadCount: keyValueHeadCount,
            headWidth: headWidth,
            intermediateWidth: intermediateWidth,
            maximumSequenceLength: maximumSequenceLength,
            ropeTheta: ropeTheta,
            rmsNormEpsilon: rmsNormEpsilon)
    }
}
