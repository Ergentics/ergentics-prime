// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreGraphics
import Foundation
import Metal
import MLX
import XCTest
import PrimeCore
import PrimeNativeDecoderCheckpoint

@testable import PrimeNativeDecoderTraining

final class PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionTests:
    XCTestCase
{
    func testTinyDurableMultileafCommitIsExactAndFailClosed() throws {
        _ = CGColorSpaceCreateDeviceRGB()
        let metalDevices = MTLCopyAllDevices()
        let defaultMetalDevice = MTLCreateSystemDefaultDevice()
        guard !metalDevices.isEmpty,
              defaultMetalDevice != nil else {
            throw XCTSkip(
                "pinned MLX CPU scheduler bootstrap unavailable; no Stage-4 "
                    + "trainer, publication, load, or fault injection executed")
        }

        let rootURL = try requiredEphemeralRoot()
        defer {
            try? reclaimChildren(of: rootURL)
        }
        let suppliedRoot = try PrimeArtifactRoot(directoryURL: rootURL)
        try suppliedRoot.requirePrivateRootMode()
        try suppliedRoot.requireEmpty()

        try Device.withDefaultDevice(.cpu) {
            XCTAssertEqual(Device.defaultDevice().deviceType, .cpu)
            let control =
                try PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeSessionV1()
            let source =
                try PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeSessionV1()
            XCTAssertEqual(try control.trainNext(), try source.trainNext())
            XCTAssertEqual(
                try control.checkedEvaluate(),
                try source.checkedEvaluate())

            let immediateControlState = try control.validationState()
            let immediateControlTensors = try control.exactTensorState()
            let payload = try source.exportTinyDurableMultileafPayload()
            XCTAssertEqual(
                try source.validationState(),
                immediateControlState)
            XCTAssertEqual(
                try source.exactTensorState(),
                immediateControlTensors)
            let controlData = try payload.controlState.canonicalJSONData()
            XCTAssertEqual(
                try PrimeNativeDecoderTinyDurableMultileafControlStateV1
                    .decodeCanonicalJSON(controlData),
                payload.controlState)
            XCTAssertEqual(payload.weights.count, 20)
            XCTAssertEqual(payload.optimizerMoments.count, 40)

            let weightsData = try MLX.saveToData(
                arrays: payload.weights,
                metadata: [
                    "encoding": "safetensors_tiny_fixture_v1",
                    "role": "weights_v2",
                ])
            let optimizerData = try MLX.saveToData(
                arrays: payload.optimizerMoments,
                metadata: [
                    "encoding": "safetensors_tiny_fixture_v1",
                    "role": "optimizer_moments",
                ])

            for (ordinal, fault) in
                PrimeNativeDecoderTrajectoryCheckpointFaultV1.allCases
                    .enumerated()
            {
                let attemptURL = rootURL.appendingPathComponent(
                    "fault-\(ordinal + 1)-root",
                    isDirectory: true)
                let root = try makeAttemptRoot(at: attemptURL)
                let directory = "checkpoint"
                do {
                    _ = try PrimeNativeDecoderTrajectoryCheckpointV1.publish(
                        root: root,
                        directory: directory,
                        weightsSafetensors: weightsData,
                        optimizerMomentsSafetensors: optimizerData,
                        controlState: controlData,
                        fault: fault)
                    XCTFail("fault unexpectedly published a commit")
                } catch {
                    guard let checkpointError =
                            error as?
                                PrimeNativeDecoderTrajectoryCheckpointV1Error,
                          case let .injectedFailure(quarantine) =
                            checkpointError
                    else {
                        XCTFail("unexpected fault result: \(error)")
                        throw error
                    }
                    XCTAssertEqual(quarantine.directory, directory)
                    XCTAssertEqual(quarantine.fault, fault)
                    try PrimeNativeDecoderTrajectoryCheckpointV1
                        .requireQuarantined(
                            root: root,
                            quarantine: quarantine)
                    XCTAssertEqual(
                        PrimeNativeDecoderTrajectoryCheckpointV1
                            .publishedLeafRoles(quarantine: quarantine),
                        expectedPublishedRoles(before: fault))
                }
                try FileManager.default.removeItem(at: attemptURL)
            }

            let successRootURL = rootURL.appendingPathComponent(
                "success-root",
                isDirectory: true)
            let root = try makeAttemptRoot(at: successRootURL)
            let successDirectory = "checkpoint"
            let binding = try PrimeNativeDecoderTrajectoryCheckpointV1.publish(
                root: root,
                directory: successDirectory,
                weightsSafetensors: weightsData,
                optimizerMomentsSafetensors: optimizerData,
                controlState: controlData)
            XCTAssertEqual(binding.schemaVersion, 1)
            XCTAssertEqual(binding.directory, successDirectory)
            XCTAssertEqual(
                binding.orderedLeafBindings.map(\.role),
                PrimeNativeDecoderCheckpoint
                    .PrimeNativeDecoderTrajectoryCheckpointLeafRoleV1
                    .allCases)
            XCTAssertEqual(
                binding.orderedLeafBindings.map(\.publicationOrdinal),
                [1, 2, 3, 4])
            XCTAssertEqual(
                binding.orderedLeafBindings.map(\.artifact.relativePath),
                [
                    "checkpoint/weights.safetensors",
                    "checkpoint/optimizer_moments.safetensors",
                    "checkpoint/control_state.json",
                    "checkpoint/commit.json",
                ])

            let loaded = try PrimeNativeDecoderTrajectoryCheckpointV1.load(
                root: root,
                externalCommitBinding: binding)
            let loadedWeights = try MLX.loadArraysAndMetadata(
                data: loaded.weightsSafetensors,
                stream: .cpu)
            let loadedOptimizer = try MLX.loadArraysAndMetadata(
                data: loaded.optimizerMomentsSafetensors,
                stream: .cpu)
            try checkedEval(
                Array(loadedWeights.0.values),
                Array(loadedOptimizer.0.values))
            XCTAssertEqual(
                loadedWeights.1,
                [
                    "encoding": "safetensors_tiny_fixture_v1",
                    "role": "weights_v2",
                ])
            XCTAssertEqual(
                loadedOptimizer.1,
                [
                    "encoding": "safetensors_tiny_fixture_v1",
                    "role": "optimizer_moments",
                ])
            let loadedControl =
                try PrimeNativeDecoderTinyDurableMultileafControlStateV1
                    .decodeCanonicalJSON(loaded.controlState)
            XCTAssertEqual(loadedControl, payload.controlState)

            let restored = try
                PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeSessionV1(
                    restoringTinyDurableMultileafPayload: .init(
                        weights: loadedWeights.0,
                        optimizerMoments: loadedOptimizer.0,
                        controlState: loadedControl))
            XCTAssertFalse(restored === source)
            assertRestorableStateEqual(
                try restored.validationState(),
                immediateControlState)
            XCTAssertEqual(
                try restored.exactTensorState(),
                immediateControlTensors)

            let sourceStep2 = try source.trainNext()
            let controlStep2 = try control.trainNext()
            let restoredStep2 = try restored.trainNext()
            XCTAssertEqual(sourceStep2, controlStep2)
            XCTAssertEqual(restoredStep2, controlStep2)
            let sourceTerminal = try source.checkedEvaluate()
            let controlTerminal = try control.checkedEvaluate()
            let restoredTerminal = try restored.checkedEvaluate()
            XCTAssertEqual(sourceTerminal, controlTerminal)
            XCTAssertEqual(restoredTerminal, controlTerminal)
            XCTAssertEqual(
                try source.validationState(),
                try control.validationState())
            XCTAssertEqual(
                try restored.validationState(),
                try control.validationState())
            XCTAssertEqual(
                try source.exactTensorState(),
                try control.exactTensorState())
            XCTAssertEqual(
                try restored.exactTensorState(),
                try control.exactTensorState())

            XCTAssertEqual(
                try PrimeNativeDecoderTrajectoryCheckpointV1.load(
                    root: root,
                    externalCommitBinding: binding),
                loaded)

            try assertExternalBindingMutationsRejected(binding, root: root)
            XCTAssertThrowsError(
                try root.publish(
                    Data("replacement-forbidden".utf8),
                    at: binding.orderedLeafBindings[0]
                        .artifact.relativePath,
                    purpose: .immutableData))
            XCTAssertNoThrow(
                try PrimeNativeDecoderTrajectoryCheckpointV1.load(
                    root: root,
                    externalCommitBinding: binding))
            try assertExtraInventoryRejected(
                binding,
                root: root,
                rootURL: successRootURL)
            XCTAssertThrowsError(
                try PrimeNativeDecoderTrajectoryCheckpointV1.publish(
                    root: root,
                    directory: successDirectory,
                    weightsSafetensors: weightsData,
                    optimizerMomentsSafetensors: optimizerData,
                    controlState: controlData))
        }

        try reclaimChildren(of: rootURL)
        try suppliedRoot.requireEmpty()
        XCTAssertTrue(
            try FileManager.default.contentsOfDirectory(
                atPath: rootURL.path).isEmpty)
    }

    private func expectedPublishedRoles(
        before fault: PrimeNativeDecoderTrajectoryCheckpointFaultV1
    ) -> [PrimeNativeDecoderCheckpoint
        .PrimeNativeDecoderTrajectoryCheckpointLeafRoleV1]
    {
        switch fault {
        case .duringWeights:
            []
        case .afterWeights, .duringOptimizerMoments:
            [.weightsV2]
        case .afterOptimizerMoments, .duringControlState:
            [.weightsV2, .optimizerMoments]
        case .afterControlState, .duringCommitManifest:
            [.weightsV2, .optimizerMoments, .controlStateManifest]
        }
    }

    private func assertRestorableStateEqual(
        _ lhs: PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeValidationStateV1,
        _ rhs: PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeValidationStateV1,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(lhs.trainer.globalStep, rhs.trainer.globalStep,
                       file: file, line: line)
        XCTAssertEqual(lhs.trainer.decoderTrainingMode,
                       rhs.trainer.decoderTrainingMode,
                       file: file, line: line)
        XCTAssertEqual(lhs.trainer.modelParameters, rhs.trainer.modelParameters,
                       file: file, line: line)
        XCTAssertEqual(lhs.trainer.firstMoments, rhs.trainer.firstMoments,
                       file: file, line: line)
        XCTAssertEqual(lhs.trainer.secondMoments, rhs.trainer.secondMoments,
                       file: file, line: line)
        XCTAssertEqual(lhs.trainer.parameterStateSHA256,
                       rhs.trainer.parameterStateSHA256,
                       file: file, line: line)
        XCTAssertEqual(lhs.trainer.firstMomentStateSHA256,
                       rhs.trainer.firstMomentStateSHA256,
                       file: file, line: line)
        XCTAssertEqual(lhs.trainer.secondMomentStateSHA256,
                       rhs.trainer.secondMomentStateSHA256,
                       file: file, line: line)
        XCTAssertEqual(lhs.randomRecords, rhs.randomRecords,
                       file: file, line: line)
        XCTAssertEqual(lhs.cursor, rhs.cursor, file: file, line: line)
        XCTAssertEqual(lhs.evaluationCheckedAtCurrentStep,
                       rhs.evaluationCheckedAtCurrentStep,
                       file: file, line: line)
    }

    private func assertExternalBindingMutationsRejected(
        _ binding: PrimeNativeDecoderTrajectoryExternalCommitBindingV1,
        root: PrimeArtifactRoot,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let canonical = try PrimeCanonicalJSON.encode(binding)
        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical) as? [String: Any],
            file: file,
            line: line)

        var missing = object
        var missingLeaves = missing["ordered_leaf_bindings"] as! [[String: Any]]
        missingLeaves.remove(at: 1)
        missing["ordered_leaf_bindings"] = missingLeaves
        assertExternalBindingRejected(missing, root: root,
                                      file: file, line: line)

        var extra = object
        var extraLeaves = extra["ordered_leaf_bindings"] as! [[String: Any]]
        extraLeaves.append(extraLeaves[0])
        extra["ordered_leaf_bindings"] = extraLeaves
        assertExternalBindingRejected(extra, root: root,
                                      file: file, line: line)

        var altered = object
        altered["commit_manifest_canonical_sha256"] = String(repeating: "0", count: 64)
        assertExternalBindingRejected(altered, root: root,
                                      file: file, line: line)

        var alteredLeaf = object
        var alteredLeaves =
            alteredLeaf["ordered_leaf_bindings"] as! [[String: Any]]
        var alteredFirst = alteredLeaves[0]
        var alteredArtifact = alteredFirst["artifact"] as! [String: Any]
        alteredArtifact["sha256"] = String(repeating: "0", count: 64)
        alteredFirst["artifact"] = alteredArtifact
        alteredLeaves[0] = alteredFirst
        alteredLeaf["ordered_leaf_bindings"] = alteredLeaves
        assertExternalBindingRejected(alteredLeaf, root: root,
                                      file: file, line: line)

        var reordered = object
        var reorderedLeaves = reordered["ordered_leaf_bindings"] as! [[String: Any]]
        reorderedLeaves.swapAt(0, 1)
        reordered["ordered_leaf_bindings"] = reorderedLeaves
        assertExternalBindingRejected(reordered, root: root,
                                      file: file, line: line)
    }

    private func assertExternalBindingRejected(
        _ object: [String: Any],
        root: PrimeArtifactRoot,
        file: StaticString,
        line: UInt
    ) {
        do {
            let data = try JSONSerialization.data(
                withJSONObject: object,
                options: [.sortedKeys, .withoutEscapingSlashes])
            let mutated = try PrimeCanonicalJSON.decode(
                PrimeNativeDecoderTrajectoryExternalCommitBindingV1.self,
                from: data)
            XCTAssertThrowsError(
                try PrimeNativeDecoderTrajectoryCheckpointV1.load(
                    root: root,
                    externalCommitBinding: mutated),
                file: file,
                line: line)
        } catch {
            XCTFail("mutation construction failed: \(error)",
                    file: file, line: line)
        }
    }

    private func assertExtraInventoryRejected(
        _ binding: PrimeNativeDecoderTrajectoryExternalCommitBindingV1,
        root: PrimeArtifactRoot,
        rootURL: URL,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let extraURL = rootURL
            .appendingPathComponent(binding.directory, isDirectory: true)
            .appendingPathComponent("unexpected-leaf")
        try Data("not-authoritative".utf8).write(to: extraURL)
        XCTAssertEqual(chmod(extraURL.path, 0o444), 0,
                       file: file, line: line)
        XCTAssertThrowsError(
            try PrimeNativeDecoderTrajectoryCheckpointV1.load(
                root: root,
                externalCommitBinding: binding),
            file: file,
            line: line)
    }

    private func requiredEphemeralRoot() throws -> URL {
        let key = "PRIME_NATIVE_DECODER_STAGE4_ARTIFACT_ROOT"
        guard let path = ProcessInfo.processInfo.environment[key],
              path.hasPrefix("/"),
              !path.isEmpty else {
            throw XCTSkip("\(key) is required for the one-shot Stage-4 test")
        }
        let url = URL(fileURLWithPath: path, isDirectory: true)
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(
                atPath: url.path,
                isDirectory: &isDirectory),
              isDirectory.boolValue,
              try FileManager.default.contentsOfDirectory(
                atPath: url.path).isEmpty
        else {
            throw NSError(
                domain: "PrimeNativeDecoderStage4Test",
                code: 1)
        }
        return url
    }

    private func makeAttemptRoot(at url: URL) throws -> PrimeArtifactRoot {
        try FileManager.default.createDirectory(
            at: url,
            withIntermediateDirectories: false,
            attributes: [.posixPermissions: NSNumber(value: 0o700)])
        guard chmod(url.path, 0o700) == 0 else {
            throw POSIXError(POSIXErrorCode(rawValue: errno)!)
        }
        let root = try PrimeArtifactRoot(directoryURL: url)
        try root.requirePrivateRootMode()
        try root.requireEmpty()
        return root
    }

    private func reclaimChildren(of root: URL) throws {
        for child in try FileManager.default.contentsOfDirectory(
            at: root,
            includingPropertiesForKeys: nil,
            options: [])
        {
            try FileManager.default.removeItem(at: child)
        }
    }

}
