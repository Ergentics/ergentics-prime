// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreGraphics
import Metal
import MLX
import MLXNN
import MLXOptimizers
import XCTest

@testable import PrimeNativeDecoderTraining

final class PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeTests:
    XCTestCase
{
    func testTinyCPUExplicitRNGCursorResumeIsExactAndFailClosed() throws {
        _ = CGColorSpaceCreateDeviceRGB()
        let metalDevices = MTLCopyAllDevices()
        let defaultMetalDevice = MTLCreateSystemDefaultDevice()
        guard !metalDevices.isEmpty,
              defaultMetalDevice != nil else {
            throw XCTSkip(
                "pinned MLX CPU scheduler bootstrap unavailable; no Stage-3 "
                    + "trainer, snapshot, restore, or trajectory executed")
        }

        try Device.withDefaultDevice(.cpu) {
            XCTAssertEqual(Device.defaultDevice().deviceType, .cpu)
            let control =
                try PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeSessionV1()
            let source =
                try PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeSessionV1()
            XCTAssertFalse(control === source)
            XCTAssertEqual(
                try control.validationState(),
                try source.validationState())

            let controlStep1 = try control.trainNext()
            let sourceStep1 = try source.trainNext()
            XCTAssertEqual(controlStep1, sourceStep1)
            XCTAssertEqual(controlStep1.globalStep, 1)
            XCTAssertEqual(controlStep1.selectedTargetCount, 6)

            let controlEvaluation1 = try control.checkedEvaluate()
            let sourceEvaluation1 = try source.checkedEvaluate()
            XCTAssertEqual(controlEvaluation1, sourceEvaluation1)
            XCTAssertEqual(controlEvaluation1.globalStep, 1)
            XCTAssertEqual(
                try control.exactTensorState(),
                try source.exactTensorState())

            let beforeExport = try source.validationState()
            let beforeExportExactTensors = try source.exactTensorState()
            let snapshot = try source.exportInMemoryResumeSnapshot()
            assertSnapshotBoundary(snapshot)

            // Advancing the source after export must not mutate the immutable
            // snapshot's tensor wrappers or cursor/RNG value state.
            let sourceStep2 = try source.trainNext()
            let restored =
                try PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeSessionV1(
                    restoring: snapshot)
            XCTAssertFalse(restored === source)
            assertRestorableStateEqual(
                try restored.validationState(),
                beforeExport)
            XCTAssertEqual(
                try restored.exactTensorState(),
                beforeExportExactTensors)
            XCTAssertNotEqual(
                try source.exactTensorState(),
                beforeExportExactTensors)

            let controlStep2 = try control.trainNext()
            let restoredStep2 = try restored.trainNext()
            XCTAssertEqual(sourceStep2, controlStep2)
            XCTAssertEqual(restoredStep2, controlStep2)
            XCTAssertEqual(controlStep2.globalStep, 2)
            XCTAssertEqual(controlStep2.selectedTargetCount, 5)
            XCTAssertEqual(
                controlStep2.lossFloat32BitPattern,
                restoredStep2.lossFloat32BitPattern)
            XCTAssertEqual(
                controlStep2.selectedLossFloat32BitPatterns,
                restoredStep2.selectedLossFloat32BitPatterns)
            XCTAssertEqual(
                controlStep2.rawGlobalGradientNormFloat32BitPattern,
                restoredStep2.rawGlobalGradientNormFloat32BitPattern)
            XCTAssertEqual(
                controlStep2.gradientClipScaleFloat32BitPattern,
                restoredStep2.gradientClipScaleFloat32BitPattern)
            XCTAssertEqual(
                controlStep2.clippedGlobalGradientNormFloat32BitPattern,
                restoredStep2.clippedGlobalGradientNormFloat32BitPattern)

            let controlEvaluation2 = try control.checkedEvaluate()
            let sourceEvaluation2 = try source.checkedEvaluate()
            let restoredEvaluation2 = try restored.checkedEvaluate()
            XCTAssertEqual(controlEvaluation2, sourceEvaluation2)
            XCTAssertEqual(controlEvaluation2, restoredEvaluation2)
            XCTAssertEqual(
                try control.validationState(),
                try source.validationState())
            XCTAssertEqual(
                try control.validationState(),
                try restored.validationState())
            XCTAssertEqual(
                try control.exactTensorState(),
                try source.exactTensorState())
            XCTAssertEqual(
                try control.exactTensorState(),
                try restored.exactTensorState())

            assertTerminalRandomAndCursorState(control)
            assertMalformedSnapshotsFailClosed(snapshot)
            assertLifecycleRejections(snapshot)
            try assertSourceBoundary()
        }
    }

    private func assertSnapshotBoundary(
        _ snapshot: PrimeNativeDecoderTinyCPUInMemoryResumeSnapshotV1,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(snapshot.schemaVersion, 1, file: file, line: line)
        XCTAssertEqual(snapshot.globalStep, 1, file: file, line: line)
        XCTAssertEqual(snapshot.modelTensorCount, 20, file: file, line: line)
        XCTAssertEqual(
            snapshot.optimizerMomentTensorCount,
            40,
            file: file,
            line: line)
        XCTAssertEqual(
            snapshot.scheduleID,
            "constant_float32_learning_rate_v1",
            file: file,
            line: line)
        XCTAssertEqual(snapshot.accumulationPhase, 0, file: file, line: line)
        XCTAssertEqual(
            snapshot.pendingGradientTensorCount,
            0,
            file: file,
            line: line)
        XCTAssertEqual(
            snapshot.pendingPrefetchItemCount,
            0,
            file: file,
            line: line)
        XCTAssertEqual(snapshot.kvCacheEntryCount, 0, file: file, line: line)
        XCTAssertEqual(
            snapshot.randomRecords.map(\.domain),
            PrimeNativeDecoderTinyCPUExplicitRNGDomainV1.allCases,
            file: file,
            line: line)
        XCTAssertEqual(
            snapshot.randomRecords.map(\.counter),
            [1, 1, 0, 0],
            file: file,
            line: line)
        XCTAssertEqual(
            Set(snapshot.randomRecords.map(\.keySHA256)).count,
            4,
            file: file,
            line: line)
        XCTAssertEqual(snapshot.cursor.epoch, 0, file: file, line: line)
        XCTAssertEqual(
            snapshot.cursor.nextBatchOrdinal,
            1,
            file: file,
            line: line)
        XCTAssertEqual(snapshot.cursor.nextRowIndex, 2, file: file, line: line)
        XCTAssertEqual(
            snapshot.cursor.nextRowIDs,
            ["train_row_2", "train_row_3"],
            file: file,
            line: line)
        let digests = [
            snapshot.parameterStateSHA256,
            snapshot.firstMomentStateSHA256,
            snapshot.secondMomentStateSHA256,
            snapshot.cursor.nextBatchTokenAndMaskSHA256,
        ] + snapshot.randomRecords.flatMap {
            [$0.keySHA256, $0.consumptionSHA256]
        }
        for digest in digests {
            XCTAssertEqual(digest.count, 64, file: file, line: line)
            XCTAssertTrue(
                digest.allSatisfy { $0.isHexDigit && !$0.isUppercase },
                file: file,
                line: line)
        }
    }

    private func assertRestorableStateEqual(
        _ lhs: PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeValidationStateV1,
        _ rhs: PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeValidationStateV1,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(lhs.trainer.globalStep, rhs.trainer.globalStep, file: file, line: line)
        XCTAssertEqual(lhs.trainer.decoderTrainingMode, rhs.trainer.decoderTrainingMode, file: file, line: line)
        XCTAssertEqual(lhs.trainer.modelParameters, rhs.trainer.modelParameters, file: file, line: line)
        XCTAssertEqual(lhs.trainer.firstMoments, rhs.trainer.firstMoments, file: file, line: line)
        XCTAssertEqual(lhs.trainer.secondMoments, rhs.trainer.secondMoments, file: file, line: line)
        XCTAssertEqual(lhs.trainer.parameterStateSHA256, rhs.trainer.parameterStateSHA256, file: file, line: line)
        XCTAssertEqual(lhs.trainer.firstMomentStateSHA256, rhs.trainer.firstMomentStateSHA256, file: file, line: line)
        XCTAssertEqual(lhs.trainer.secondMomentStateSHA256, rhs.trainer.secondMomentStateSHA256, file: file, line: line)
        XCTAssertEqual(lhs.randomRecords, rhs.randomRecords, file: file, line: line)
        XCTAssertEqual(lhs.cursor, rhs.cursor, file: file, line: line)
        XCTAssertEqual(lhs.evaluationCheckedAtCurrentStep, rhs.evaluationCheckedAtCurrentStep, file: file, line: line)
        XCTAssertTrue(lhs.trainer.lastRawGradients.isEmpty, file: file, line: line)
        XCTAssertTrue(lhs.trainer.lastClippedGradients.isEmpty, file: file, line: line)
        XCTAssertNil(lhs.trainer.lastTrainResult, file: file, line: line)
    }

    private func assertTerminalRandomAndCursorState(
        _ session: PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeSessionV1,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(session.globalStep, 2, file: file, line: line)
        XCTAssertEqual(
            session.randomRecords.map(\.counter),
            [1, 2, 0, 0],
            file: file,
            line: line)
        XCTAssertEqual(session.cursor.epoch, 1, file: file, line: line)
        XCTAssertEqual(
            session.cursor.nextBatchOrdinal,
            2,
            file: file,
            line: line)
        XCTAssertEqual(session.cursor.nextRowIndex, 4, file: file, line: line)
        XCTAssertTrue(session.cursor.nextRowIDs.isEmpty, file: file, line: line)
    }

    private func assertMalformedSnapshotsFailClosed(
        _ snapshot: PrimeNativeDecoderTinyCPUInMemoryResumeSnapshotV1,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        var model = Dictionary(
            uniqueKeysWithValues: snapshot.modelParameters.flattened().map {
                ($0.0, $0.1)
            })
        model.removeValue(forKey: model.keys.sorted()[0])
        let missingModel = PrimeNativeDecoderTinyCPUInMemoryResumeSnapshotV1(
            globalStep: 1,
            modelParameters: ModuleParameters.unflattened(model),
            optimizerState: snapshot.optimizerState,
            parameterStateSHA256: snapshot.parameterStateSHA256,
            firstMomentStateSHA256: snapshot.firstMomentStateSHA256,
            secondMomentStateSHA256: snapshot.secondMomentStateSHA256,
            randomRecords: snapshot.randomRecords,
            cursor: snapshot.cursor)
        assertRestoreRejectedWithoutMutation(
            missingModel,
            file: file,
            line: line)

        let wrongCursor = PrimeNativeDecoderTinyCPUDataCursorV1(
            epoch: 0,
            nextBatchOrdinal: 0,
            nextRowIndex: 0,
            nextRowIDs: ["train_row_0", "train_row_1"],
            nextBatchTokenAndMaskSHA256:
                snapshot.cursor.nextBatchTokenAndMaskSHA256)
        let cursorDrift = PrimeNativeDecoderTinyCPUInMemoryResumeSnapshotV1(
            globalStep: 1,
            modelParameters: snapshot.modelParameters,
            optimizerState: snapshot.optimizerState,
            parameterStateSHA256: snapshot.parameterStateSHA256,
            firstMomentStateSHA256: snapshot.firstMomentStateSHA256,
            secondMomentStateSHA256: snapshot.secondMomentStateSHA256,
            randomRecords: snapshot.randomRecords,
            cursor: wrongCursor)
        assertRestoreRejectedWithoutMutation(
            cursorDrift,
            file: file,
            line: line)
    }

    private func assertRestoreRejectedWithoutMutation(
        _ snapshot: PrimeNativeDecoderTinyCPUInMemoryResumeSnapshotV1,
        file: StaticString,
        line: UInt
    ) {
        XCTAssertNoThrow(
            try Device.withDefaultDevice(.cpu) {
                let target =
                    try PrimeNativeDecoderTinyCPUTrainEvaluateTrainerV1()
                let before = try target.validationSnapshot()
                XCTAssertThrowsError(
                    try target.restoreInMemoryResumeSnapshot(snapshot),
                    file: file,
                    line: line)
                XCTAssertEqual(
                    try target.validationSnapshot(),
                    before,
                    file: file,
                    line: line)
            },
            file: file,
            line: line)
    }

    private func assertLifecycleRejections(
        _ snapshot: PrimeNativeDecoderTinyCPUInMemoryResumeSnapshotV1,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertNoThrow(
            try Device.withDefaultDevice(.cpu) {
                let session =
                    try PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeSessionV1()
                XCTAssertThrowsError(
                    try session.exportInMemoryResumeSnapshot(),
                    file: file,
                    line: line)
                _ = try session.trainNext()
                XCTAssertThrowsError(
                    try session.trainNext(),
                    file: file,
                    line: line)

                let restored =
                    try PrimeNativeDecoderTinyCPUTrainEvaluateTrainerV1()
                try restored.restoreInMemoryResumeSnapshot(snapshot)
                XCTAssertThrowsError(
                    try restored.restoreInMemoryResumeSnapshot(snapshot),
                    file: file,
                    line: line)
            },
            file: file,
            line: line)
    }

    private func assertSourceBoundary() throws {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let source = try String(
            contentsOf: root.appendingPathComponent(
                "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderTraining.swift"),
            encoding: .utf8)
        for required in [
            "PrimeNativeDecoderTinyCPUInMemoryResumeSnapshotV1",
            "PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeSessionV1",
            "func trainNext()",
            "func exportInMemoryResumeSnapshot()",
            "func restoreInMemoryResumeSnapshot(",
            "optimizer.update(",
            "verify: .all",
            "sha256_counter_stream_v1",
            "cursor.nextBatchOrdinal == trainer.globalStep",
        ] {
            XCTAssertTrue(source.contains(required), required)
        }
        for forbidden in [
            "func trainNext(batch:",
            "PrimeArtifactRoot",
            "PrimeNativeDecoderCheckpoint",
            "FileManager",
            "FileHandle",
            "URLSession",
            "Process(",
            "writeNative300M",
            "loadNative300M",
        ] {
            XCTAssertFalse(source.contains(forbidden), forbidden)
        }
    }
}
