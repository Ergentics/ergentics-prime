// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreGraphics
import Metal
import MLX
import XCTest

@testable import PrimeNativeDecoderTraining

final class PrimeNativeDecoderTrainingTests: XCTestCase {
    func testTinyCPUTrainEvaluateMechanicsAreExactAndFailClosed() throws {
        let configuration =
            PrimeNativeDecoderTinyCPUTrainEvaluateConfigurationV1.frozenV1
        XCTAssertEqual(configuration.vocabularySize, 32)
        XCTAssertEqual(configuration.modelWidth, 16)
        XCTAssertEqual(configuration.layerCount, 2)
        XCTAssertEqual(configuration.queryHeadCount, 4)
        XCTAssertEqual(configuration.keyValueHeadCount, 2)
        XCTAssertEqual(configuration.headWidth, 4)
        XCTAssertEqual(configuration.intermediateWidth, 32)
        XCTAssertEqual(configuration.maximumSequenceLength, 16)
        XCTAssertEqual(configuration.maximumBatchSize, 2)
        XCTAssertEqual(configuration.paddingTokenID, 0)
        XCTAssertEqual(configuration.initializationSeed, 7)
        XCTAssertEqual(configuration.uniqueParameterCount, 5_200)
        XCTAssertEqual(configuration.trainableParameterPathCount, 20)
        XCTAssertEqual(configuration.maximumGlobalStep, 2)
        XCTAssertEqual(
            configuration.learningRateFloat32BitPattern,
            Float(1e-4).bitPattern)
        XCTAssertEqual(
            configuration.beta1Float32BitPattern,
            Float(0.9).bitPattern)
        XCTAssertEqual(
            configuration.beta2Float32BitPattern,
            Float(0.999).bitPattern)
        XCTAssertEqual(
            configuration.epsilonFloat32BitPattern,
            Float(1e-8).bitPattern)
        XCTAssertEqual(
            configuration.weightDecayFloat32BitPattern,
            Float(0.01).bitPattern)
        XCTAssertEqual(
            configuration.maximumGradientNormFloat32BitPattern,
            Float(1).bitPattern)
        XCTAssertEqual(
            configuration.gradientNormEpsilonFloat32BitPattern,
            Float(1e-6).bitPattern)
        XCTAssertEqual(
            configuration.tensorLogicalDigestAlgorithmID,
            "sha256_domain_utf8_path_u32be_rank_u32be_dimensions_"
                + "u64be_count_f32_bits_u32be_v1")
        XCTAssertEqual(
            configuration.stateLogicalDigestAlgorithmID,
            "sha256_domain_utf8_role_u32be_tensor_count_then_"
                + "canonical_tensor_records_v1")
        XCTAssertGreaterThan(
            configuration.queryHeadCount,
            configuration.keyValueHeadCount)
        XCTAssertEqual(
            configuration.queryHeadCount
                / configuration.keyValueHeadCount,
            2)

        assertBatchRejections()
        try assertClipPolicyBoundaries()

        let validPrefixZero =
            try PrimeNativeDecoderTinyCPUTrainEvaluateBatchV1(
                tokenIDs: [[1, 0, 2, 0]],
                validTokenCounts: [3],
                completionMask: [[false, false, true, false]])
        XCTAssertEqual(validPrefixZero.validTokenCounts, [3])
        XCTAssertEqual(validPrefixZero.selectedTargetCount, 1)

        let firstBatch = try PrimeNativeDecoderTinyCPUTrainEvaluateBatchV1(
            tokenIDs: [
                [1, 1, 1, 2, 3, 0],
                [4, 5, 6, 7, 8, 9],
            ],
            validTokenCounts: [5, 6],
            completionMask: [
                [false, false, false, true, true, false],
                [false, false, true, true, true, true],
            ])
        let secondBatch = try PrimeNativeDecoderTinyCPUTrainEvaluateBatchV1(
            tokenIDs: [
                [10, 11, 12, 13, 0, 0],
                [14, 15, 15, 15, 16, 0],
            ],
            validTokenCounts: [4, 5],
            completionMask: [
                [false, true, true, true, false, false],
                [false, false, false, true, true, false],
            ])
        let evaluationBatch =
            try PrimeNativeDecoderTinyCPUTrainEvaluateBatchV1(
                tokenIDs: [
                    [17, 18, 19, 0, 0, 0],
                    [17, 18, 19, 20, 21, 22],
                ],
                validTokenCounts: [3, 6],
                completionMask: [
                    [false, true, true, false, false, false],
                    [false, true, true, true, true, true],
                ])
        XCTAssertEqual(firstBatch.selectedTargetCount, 6)
        XCTAssertEqual(secondBatch.selectedTargetCount, 5)
        XCTAssertEqual(evaluationBatch.selectedTargetCount, 7)

        // The pinned MLX scheduler initializes one Metal stream even when the
        // selected tensor device is CPU. These calls only make that compiled
        // runtime bootstrap visible; no tensor is submitted to Metal here.
        _ = CGColorSpaceCreateDeviceRGB()
        let metalDevices = MTLCopyAllDevices()
        let defaultMetalDevice = MTLCreateSystemDefaultDevice()
        guard !metalDevices.isEmpty,
              defaultMetalDevice != nil else {
            throw XCTSkip(
                "pinned MLX CPU scheduler bootstrap unavailable: "
                    + "MTLCopyAllDevices count=\(metalDevices.count), "
                    + "MTLCreateSystemDefaultDevice nil="
                    + "\(defaultMetalDevice == nil); no MLX Device/static "
                    + "runtime or train/evaluate mechanics executed")
        }

        try Device.withDefaultDevice(.cpu) {
            XCTAssertEqual(Device.defaultDevice().deviceType, .cpu)

            let first = try PrimeNativeDecoderTinyCPUTrainEvaluateTrainerV1()
            let second = try PrimeNativeDecoderTinyCPUTrainEvaluateTrainerV1()
            XCTAssertFalse(first === second)

            let initialFirst = try first.validationSnapshot()
            let initialSecond = try second.validationSnapshot()
            XCTAssertEqual(initialFirst, initialSecond)
            assertInitialSnapshot(initialFirst)

            let firstStepFirst = try first.train(batch: firstBatch)
            XCTAssertEqual(
                try second.validationSnapshot(),
                initialSecond,
                "the first control must not alias the second control")
            let firstStepSecond = try second.train(batch: firstBatch)
            XCTAssertEqual(firstStepFirst, firstStepSecond)
            assertActiveClippedStep(
                firstStepFirst,
                expectedGlobalStep: 1,
                expectedSelectedTargetCount: 6)
            assertGlobalMeanLoss(firstStepFirst)

            let afterFirstStepFirst = try first.validationSnapshot()
            let afterFirstStepSecond = try second.validationSnapshot()
            XCTAssertEqual(afterFirstStepFirst, afterFirstStepSecond)
            XCTAssertNotEqual(
                afterFirstStepFirst.parameterStateSHA256,
                initialFirst.parameterStateSHA256)
            assertCompletedStepSnapshot(
                afterFirstStepFirst,
                result: firstStepFirst)

            let secondStepFirst = try first.train(batch: secondBatch)
            XCTAssertEqual(
                try second.validationSnapshot(),
                afterFirstStepSecond,
                "the first control's second step must not mutate the second")
            let secondStepSecond = try second.train(batch: secondBatch)
            XCTAssertEqual(secondStepFirst, secondStepSecond)
            assertActiveClippedStep(
                secondStepFirst,
                expectedGlobalStep: 2,
                expectedSelectedTargetCount: 5)
            assertGlobalMeanLoss(secondStepFirst)

            let afterSecondStepFirst = try first.validationSnapshot()
            let afterSecondStepSecond = try second.validationSnapshot()
            XCTAssertEqual(afterSecondStepFirst, afterSecondStepSecond)
            XCTAssertNotEqual(
                afterSecondStepFirst.parameterStateSHA256,
                afterFirstStepFirst.parameterStateSHA256)
            XCTAssertNotEqual(
                afterSecondStepFirst.firstMomentStateSHA256,
                afterFirstStepFirst.firstMomentStateSHA256)
            XCTAssertNotEqual(
                afterSecondStepFirst.secondMomentStateSHA256,
                afterFirstStepFirst.secondMomentStateSHA256)
            assertCompletedStepSnapshot(
                afterSecondStepFirst,
                result: secondStepFirst)

            let beforeEvaluationFirst = try first.validationSnapshot()
            let beforeEvaluationSecond = try second.validationSnapshot()
            let evaluationFirst = try first.evaluate(batch: evaluationBatch)
            let evaluationSecond = try second.evaluate(batch: evaluationBatch)
            XCTAssertEqual(evaluationFirst, evaluationSecond)
            XCTAssertEqual(
                try first.validationSnapshot(),
                beforeEvaluationFirst)
            XCTAssertEqual(
                try second.validationSnapshot(),
                beforeEvaluationSecond)
            XCTAssertTrue(beforeEvaluationFirst.decoderTrainingMode)
            XCTAssertTrue(beforeEvaluationSecond.decoderTrainingMode)
            XCTAssertEqual(evaluationFirst.globalStep, 2)
            XCTAssertEqual(evaluationFirst.selectedTargetCount, 7)
            XCTAssertEqual(
                evaluationFirst.parameterStateSHA256,
                beforeEvaluationFirst.parameterStateSHA256)
            XCTAssertEqual(
                evaluationFirst.firstMomentStateSHA256,
                beforeEvaluationFirst.firstMomentStateSHA256)
            XCTAssertEqual(
                evaluationFirst.secondMomentStateSHA256,
                beforeEvaluationFirst.secondMomentStateSHA256)
            assertFinitePositive(
                evaluationFirst.lossFloat32BitPattern,
                scope: "evaluation mean loss")
            XCTAssertEqual(
                evaluationFirst.selectedLossFloat32BitPatterns.count,
                7)
            for bits in evaluationFirst.selectedLossFloat32BitPatterns {
                assertFinitePositive(bits, scope: "evaluation selected loss")
            }
            assertGlobalMeanLoss(
                meanBitPattern: evaluationFirst.lossFloat32BitPattern,
                selectedLossBitPatterns:
                    evaluationFirst.selectedLossFloat32BitPatterns)
            XCTAssertEqual(
                evaluationFirst.selectedLossFloat32BitPatterns[0],
                evaluationFirst.selectedLossFloat32BitPatterns[2])
            XCTAssertEqual(
                evaluationFirst.selectedLossFloat32BitPatterns[1],
                evaluationFirst.selectedLossFloat32BitPatterns[3])

            let beforeRejectedThirdFirst = try first.validationSnapshot()
            assertTrainingError(
                .maximumGlobalStepReached(maximum: 2, observed: 2)
            ) {
                try first.train(batch: firstBatch)
            }
            XCTAssertEqual(
                try first.validationSnapshot(),
                beforeRejectedThirdFirst)

            let beforeRejectedThirdSecond = try second.validationSnapshot()
            assertTrainingError(
                .maximumGlobalStepReached(maximum: 2, observed: 2)
            ) {
                try second.train(batch: secondBatch)
            }
            XCTAssertEqual(
                try second.validationSnapshot(),
                beforeRejectedThirdSecond)
        }
    }

    private func assertBatchRejections(
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        assertBatchError(.emptyBatch, file: file, line: line) {
            try .init(tokenIDs: [], validTokenCounts: [], completionMask: [])
        }
        assertBatchError(
            .batchTooLarge(observed: 3, maximum: 2),
            file: file,
            line: line
        ) {
            try .init(
                tokenIDs: [[1, 2], [3, 4], [5, 6]],
                validTokenCounts: [2, 2, 2],
                completionMask: [
                    [false, true],
                    [false, true],
                    [false, true],
                ])
        }
        assertBatchError(.sequenceTooShort(1), file: file, line: line) {
            try .init(
                tokenIDs: [[1]],
                validTokenCounts: [1],
                completionMask: [[false]])
        }
        assertBatchError(
            .sequenceTooLong(observed: 17, maximum: 16),
            file: file,
            line: line
        ) {
            try .init(
                tokenIDs: [Array(repeating: 1, count: 17)],
                validTokenCounts: [17],
                completionMask: [
                    [false] + Array(repeating: true, count: 16),
                ])
        }
        assertBatchError(
            .raggedTokenRow(row: 1, expected: 2, observed: 3),
            file: file,
            line: line
        ) {
            try .init(
                tokenIDs: [[1, 2], [3, 4, 5]],
                validTokenCounts: [2, 3],
                completionMask: [[false, true], [false, true, true]])
        }
        assertBatchError(
            .validTokenCountCountMismatch(expected: 1, observed: 0),
            file: file,
            line: line
        ) {
            try .init(
                tokenIDs: [[1, 2]],
                validTokenCounts: [],
                completionMask: [[false, true]])
        }
        assertBatchError(
            .completionMaskRowCountMismatch(expected: 1, observed: 0),
            file: file,
            line: line
        ) {
            try .init(
                tokenIDs: [[1, 2]],
                validTokenCounts: [2],
                completionMask: [])
        }
        assertBatchError(
            .invalidValidTokenCount(row: 0, observed: 1, sequenceLength: 2),
            file: file,
            line: line
        ) {
            try .init(
                tokenIDs: [[1, 2]],
                validTokenCounts: [1],
                completionMask: [[false, true]])
        }
        assertBatchError(
            .invalidValidTokenCount(row: 0, observed: 4, sequenceLength: 3),
            file: file,
            line: line
        ) {
            try .init(
                tokenIDs: [[1, 2, 0]],
                validTokenCounts: [4],
                completionMask: [[false, true, false]])
        }
        assertBatchError(
            .raggedCompletionMaskRow(row: 0, expected: 3, observed: 2),
            file: file,
            line: line
        ) {
            try .init(
                tokenIDs: [[1, 2, 0]],
                validTokenCounts: [2],
                completionMask: [[false, true]])
        }
        assertBatchError(
            .tokenIDOutOfRange(row: 0, column: 1, value: 32),
            file: file,
            line: line
        ) {
            try .init(
                tokenIDs: [[1, 32]],
                validTokenCounts: [2],
                completionMask: [[false, true]])
        }
        assertBatchError(
            .tokenIDOutOfRange(row: 0, column: 1, value: -1),
            file: file,
            line: line
        ) {
            try .init(
                tokenIDs: [[1, -1]],
                validTokenCounts: [2],
                completionMask: [[false, true]])
        }
        assertBatchError(
            .nonPaddingToken(
                row: 0,
                column: 2,
                observed: 7,
                expected: 0),
            file: file,
            line: line
        ) {
            try .init(
                tokenIDs: [[1, 2, 7]],
                validTokenCounts: [2],
                completionMask: [[false, true, false]])
        }
        assertBatchError(
            .completionMaskSelectsPadding(row: 0, column: 2),
            file: file,
            line: line
        ) {
            try .init(
                tokenIDs: [[1, 2, 0]],
                validTokenCounts: [2],
                completionMask: [[false, true, true]])
        }
        assertBatchError(
            .completionMaskSelectsFirstToken(row: 0),
            file: file,
            line: line
        ) {
            try .init(
                tokenIDs: [[1, 2]],
                validTokenCounts: [2],
                completionMask: [[true, true]])
        }
        assertBatchError(.emptyCompletion(row: 0), file: file, line: line) {
            try .init(
                tokenIDs: [[1, 2]],
                validTokenCounts: [2],
                completionMask: [[false, false]])
        }
        assertBatchError(
            .nonContiguousCompletionSuffix(row: 0, column: 2),
            file: file,
            line: line
        ) {
            try .init(
                tokenIDs: [[1, 2, 3, 4]],
                validTokenCounts: [4],
                completionMask: [[false, true, false, true]])
        }
    }

    private func assertClipPolicyBoundaries(
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        XCTAssertEqual(
            try PrimeNativeDecoderTinyCPUTrainEvaluateTrainerV1
                .validationClipScale(globalNorm: 0).bitPattern,
            Float(1).bitPattern,
            file: file,
            line: line)
        XCTAssertEqual(
            try PrimeNativeDecoderTinyCPUTrainEvaluateTrainerV1
                .validationClipScale(globalNorm: Float(1).nextDown)
                .bitPattern,
            Float(1).bitPattern,
            file: file,
            line: line)

        let equalityScale =
            try PrimeNativeDecoderTinyCPUTrainEvaluateTrainerV1
            .validationClipScale(globalNorm: 1)
        XCTAssertEqual(
            equalityScale.bitPattern,
            (Float(1) / (Float(1) + Float(1e-6))).bitPattern,
            file: file,
            line: line)
        XCTAssertLessThan(equalityScale, 1, file: file, line: line)

        let aboveScale =
            try PrimeNativeDecoderTinyCPUTrainEvaluateTrainerV1
            .validationClipScale(globalNorm: 2)
        XCTAssertEqual(
            aboveScale.bitPattern,
            (Float(1) / (Float(2) + Float(1e-6))).bitPattern,
            file: file,
            line: line)
        XCTAssertGreaterThan(aboveScale, 0, file: file, line: line)
        XCTAssertLessThan(aboveScale, 1, file: file, line: line)

        for invalid: Float in [-0.25, .infinity, .nan] {
            assertTrainingError(
                .invalidGlobalGradientNorm(invalid.bitPattern),
                file: file,
                line: line
            ) {
                try PrimeNativeDecoderTinyCPUTrainEvaluateTrainerV1
                    .validationClipScale(globalNorm: invalid)
            }
        }
    }

    private func assertInitialSnapshot(
        _ snapshot: PrimeNativeDecoderTinyCPUTrainEvaluateValidationSnapshotV1,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(snapshot.globalStep, 0, file: file, line: line)
        XCTAssertTrue(snapshot.decoderTrainingMode, file: file, line: line)
        assertCatalog(
            snapshot.modelParameters,
            requiresNonzeroPerPath: true,
            file: file,
            line: line)
        XCTAssertTrue(snapshot.firstMoments.isEmpty, file: file, line: line)
        XCTAssertTrue(snapshot.secondMoments.isEmpty, file: file, line: line)
        XCTAssertTrue(
            snapshot.lastRawGradients.isEmpty,
            file: file,
            line: line)
        XCTAssertTrue(
            snapshot.lastClippedGradients.isEmpty,
            file: file,
            line: line)
        XCTAssertNil(snapshot.lastTrainResult, file: file, line: line)
        assertSHA256(snapshot.parameterStateSHA256, file: file, line: line)
        assertSHA256(snapshot.firstMomentStateSHA256, file: file, line: line)
        assertSHA256(snapshot.secondMomentStateSHA256, file: file, line: line)
        XCTAssertFalse(
            snapshot.modelParameters.map(\.path).contains {
                $0.contains("lm_head")
            },
            file: file,
            line: line)
    }

    private func assertCompletedStepSnapshot(
        _ snapshot: PrimeNativeDecoderTinyCPUTrainEvaluateValidationSnapshotV1,
        result: PrimeNativeDecoderTinyCPUTrainEvaluateStepResultV1,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(
            snapshot.globalStep,
            result.globalStep,
            file: file,
            line: line)
        XCTAssertTrue(snapshot.decoderTrainingMode, file: file, line: line)
        XCTAssertEqual(snapshot.lastTrainResult, result, file: file, line: line)
        XCTAssertEqual(
            snapshot.parameterStateSHA256,
            result.parameterStateSHA256,
            file: file,
            line: line)
        XCTAssertEqual(
            snapshot.firstMomentStateSHA256,
            result.firstMomentStateSHA256,
            file: file,
            line: line)
        XCTAssertEqual(
            snapshot.secondMomentStateSHA256,
            result.secondMomentStateSHA256,
            file: file,
            line: line)

        for catalog in [
            snapshot.modelParameters,
            snapshot.firstMoments,
            snapshot.secondMoments,
            snapshot.lastRawGradients,
            snapshot.lastClippedGradients,
        ] {
            assertCatalog(
                catalog,
                requiresNonzeroPerPath: true,
                file: file,
                line: line)
        }
        XCTAssertEqual(
            snapshot.firstMoments.count,
            20,
            file: file,
            line: line)
        XCTAssertEqual(
            snapshot.secondMoments.count,
            20,
            file: file,
            line: line)
        XCTAssertEqual(
            snapshot.lastRawGradients.map(\.path),
            snapshot.lastClippedGradients.map(\.path),
            file: file,
            line: line)
        for (raw, clipped) in zip(
            snapshot.lastRawGradients,
            snapshot.lastClippedGradients)
        {
            XCTAssertNotEqual(
                raw.logicalSHA256,
                clipped.logicalSHA256,
                "active clipping must change every nonzero gradient tensor",
                file: file,
                line: line)
        }
    }

    private func assertActiveClippedStep(
        _ result: PrimeNativeDecoderTinyCPUTrainEvaluateStepResultV1,
        expectedGlobalStep: Int,
        expectedSelectedTargetCount: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(
            result.globalStep,
            expectedGlobalStep,
            file: file,
            line: line)
        XCTAssertEqual(
            result.selectedTargetCount,
            expectedSelectedTargetCount,
            file: file,
            line: line)
        XCTAssertEqual(
            result.selectedLossFloat32BitPatterns.count,
            expectedSelectedTargetCount,
            file: file,
            line: line)
        assertFinitePositive(
            result.lossFloat32BitPattern,
            scope: "training mean loss",
            file: file,
            line: line)
        for bits in result.selectedLossFloat32BitPatterns {
            assertFinitePositive(
                bits,
                scope: "training selected loss",
                file: file,
                line: line)
        }

        let rawNorm = Float(
            bitPattern: result.rawGlobalGradientNormFloat32BitPattern)
        let scale = Float(
            bitPattern: result.gradientClipScaleFloat32BitPattern)
        let clippedNorm = Float(
            bitPattern: result.clippedGlobalGradientNormFloat32BitPattern)
        XCTAssertTrue(rawNorm.isFinite, file: file, line: line)
        XCTAssertGreaterThanOrEqual(rawNorm, 1, file: file, line: line)
        XCTAssertTrue(scale.isFinite, file: file, line: line)
        XCTAssertGreaterThan(scale, 0, file: file, line: line)
        XCTAssertLessThan(scale, 1, file: file, line: line)
        XCTAssertTrue(clippedNorm.isFinite, file: file, line: line)
        XCTAssertGreaterThan(clippedNorm, 0, file: file, line: line)
        XCTAssertLessThanOrEqual(clippedNorm, 1.000_01, file: file, line: line)
        assertSHA256(result.parameterStateSHA256, file: file, line: line)
        assertSHA256(result.firstMomentStateSHA256, file: file, line: line)
        assertSHA256(result.secondMomentStateSHA256, file: file, line: line)
    }

    private func assertGlobalMeanLoss(
        _ result: PrimeNativeDecoderTinyCPUTrainEvaluateStepResultV1,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        assertGlobalMeanLoss(
            meanBitPattern: result.lossFloat32BitPattern,
            selectedLossBitPatterns: result.selectedLossFloat32BitPatterns,
            file: file,
            line: line)
    }

    private func assertGlobalMeanLoss(
        meanBitPattern: UInt32,
        selectedLossBitPatterns: [UInt32],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let selected = selectedLossBitPatterns.map {
            Float(bitPattern: $0)
        }
        let reconstructed = selected.reduce(Float(0), +)
            / Float(selected.count)
        XCTAssertEqual(
            Float(bitPattern: meanBitPattern),
            reconstructed,
            accuracy: 1e-6,
            file: file,
            line: line)
    }

    private func assertCatalog(
        _ catalog: [PrimeNativeDecoderTinyCPUTrainEvaluateTensorDigestV1],
        requiresNonzeroPerPath: Bool,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let expected = expectedParameterShapes
        let expectedPaths = expected.keys.sorted(by: utf8Less)
        XCTAssertEqual(catalog.count, 20, file: file, line: line)
        XCTAssertEqual(catalog.map(\.path), expectedPaths, file: file, line: line)
        XCTAssertEqual(
            Dictionary(uniqueKeysWithValues: catalog.map { ($0.path, $0.shape) }),
            expected,
            file: file,
            line: line)
        XCTAssertEqual(
            catalog.reduce(0) { $0 + $1.valueCount },
            5_200,
            file: file,
            line: line)
        for tensor in catalog {
            XCTAssertTrue(tensor.allFinite, tensor.path, file: file, line: line)
            XCTAssertGreaterThan(
                tensor.valueCount,
                0,
                tensor.path,
                file: file,
                line: line)
            XCTAssertLessThanOrEqual(
                tensor.nonzeroValueCount,
                tensor.valueCount,
                tensor.path,
                file: file,
                line: line)
            if requiresNonzeroPerPath {
                XCTAssertGreaterThan(
                    tensor.nonzeroValueCount,
                    0,
                    tensor.path,
                    file: file,
                    line: line)
            }
            assertSHA256(tensor.logicalSHA256, file: file, line: line)
        }
    }

    private func assertFinitePositive(
        _ bitPattern: UInt32,
        scope: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let value = Float(bitPattern: bitPattern)
        XCTAssertTrue(value.isFinite, scope, file: file, line: line)
        XCTAssertGreaterThan(value, 0, scope, file: file, line: line)
    }

    private func assertSHA256(
        _ value: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(value.utf8.count, 64, file: file, line: line)
        XCTAssertTrue(
            value.utf8.allSatisfy {
                (UInt8(ascii: "0") ... UInt8(ascii: "9")).contains($0)
                    || (UInt8(ascii: "a") ... UInt8(ascii: "f")).contains($0)
            },
            file: file,
            line: line)
    }

    private func assertBatchError(
        _ expected: PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ body: () throws -> PrimeNativeDecoderTinyCPUTrainEvaluateBatchV1
    ) {
        do {
            _ = try body()
            XCTFail("expected \(expected)", file: file, line: line)
        } catch let error as PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1 {
            XCTAssertEqual(error, expected, file: file, line: line)
        } catch {
            XCTFail("unexpected error \(error)", file: file, line: line)
        }
    }

    private func assertTrainingError<T>(
        _ expected: PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ body: () throws -> T
    ) {
        do {
            _ = try body()
            XCTFail("expected \(expected)", file: file, line: line)
        } catch let error as PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1 {
            XCTAssertEqual(error, expected, file: file, line: line)
        } catch {
            XCTFail("unexpected error \(error)", file: file, line: line)
        }
    }

    private var expectedParameterShapes: [String: [Int]] {
        var result: [String: [Int]] = [
            "final_norm.weight": [16],
            "token_embedding.weight": [32, 16],
        ]
        for layer in 0 ..< 2 {
            let prefix = "layers.\(layer)"
            result["\(prefix).attention_norm.weight"] = [16]
            result["\(prefix).attention.key_projection.weight"] = [8, 16]
            result["\(prefix).attention.output_projection.weight"] = [16, 16]
            result["\(prefix).attention.query_projection.weight"] = [16, 16]
            result["\(prefix).attention.value_projection.weight"] = [8, 16]
            result["\(prefix).feed_forward_norm.weight"] = [16]
            result["\(prefix).feed_forward.down_projection.weight"] = [16, 32]
            result["\(prefix).feed_forward.gate_projection.weight"] = [32, 16]
            result["\(prefix).feed_forward.up_projection.weight"] = [32, 16]
        }
        return result
    }

    private func utf8Less(_ lhs: String, _ rhs: String) -> Bool {
        lhs.utf8.lexicographicallyPrecedes(rhs.utf8)
    }
}
