// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
@testable import PrimeCore
import XCTest

final class
    PrimeNativeDecoderNative300MResourceOnlyOneStepProbeExecutionObservationTests:
    XCTestCase
{
    private typealias Observation =
        PrimeNativeDecoderNative300MResourceOnlyOneStepProbeExecutionObservationV1

    func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndSuccessCeiling()
        throws
    {
        let observation = Observation.frozenV1
        XCTAssertNoThrow(try observation.validateExactV1())
        requireSendable(Observation.self)

        XCTAssertEqual(observation.schemaVersion, 1)
        XCTAssertEqual(
            observation.observationID,
            "ergentics_prime_native_decoder_native300m_resource_only_one_step_probe_execution_observation_v1"
        )

        let run = observation.run
        XCTAssertEqual(run.repository, "Ergentics/ergentics-prime")
        XCTAssertEqual(run.ref, "refs/heads/main")
        XCTAssertEqual(
            run.mergeRevision,
            "437acb46a5af63f6c604e5f5c50f3b63eaa296f2"
        )
        XCTAssertEqual(
            run.mergeTree,
            "f87272ed850cd2ac1898bd6c5d4cbefd2c664bb0"
        )
        XCTAssertEqual(
            run.orderedParentRevisions,
            [
                "7dd21f2b8c79ebe53f62eab1945ac41b104c2b27",
                "5164075dc6f83242563ee804caea24e9599eb71d",
            ]
        )
        XCTAssertEqual(run.workflowRunID, 31_784_730_175)
        XCTAssertEqual(run.workflowRunNumber, 111)
        XCTAssertEqual(run.checkSuiteID, 86_228_325_084)
        XCTAssertEqual(run.runAttempt, 1)
        XCTAssertEqual(run.exactHeadPushRunCount, 1)
        XCTAssertTrue(run.previousAttemptURLWasNull)
        XCTAssertEqual(run.rerunCount, 0)
        XCTAssertEqual(run.artifactCount, 0)
        XCTAssertEqual(run.status, "completed")
        XCTAssertEqual(run.conclusion, "success")
        XCTAssertEqual(run.activeRootJob.id, 94_718_000_573)
        XCTAssertEqual(run.activeRootJob.runnerImage, "macos-15")
        XCTAssertEqual(run.activeRootJob.orderedStepCount, 7)
        XCTAssertEqual(run.activeRootJob.successfulStepCount, 7)
        XCTAssertEqual(run.reviewedMainJob.id, 94_718_575_857)
        XCTAssertEqual(run.reviewedMainJob.runnerImage, "macos-26")
        XCTAssertEqual(run.reviewedMainJob.orderedStepCount, 7)
        XCTAssertEqual(run.reviewedMainJob.successfulStepCount, 7)

        let predecessor = observation.predecessor
        XCTAssertTrue(predecessor.stage5MechanicsExecuted)
        XCTAssertTrue(predecessor.stage5OneShotConsumed)
        XCTAssertTrue(predecessor.stage5LifecycleCompletedAndRetired)
        XCTAssertFalse(predecessor.stage5ResultEstablished)
        XCTAssertFalse(predecessor.stage5MechanicsSuccessEstablished)
        XCTAssertFalse(predecessor.stage5AssayClearanceEstablished)
        XCTAssertFalse(predecessor.repeatedTrajectoryDeterminismEstablished)
        XCTAssertFalse(predecessor.exactMetalGradientBytesEstablished)
        XCTAssertFalse(predecessor.metalDeterminismEstablished)
        XCTAssertFalse(predecessor.stage5ReplacementExecutionAuthorized)
        XCTAssertEqual(
            predecessor.stage6AuthorityCanonicalSHA256,
            "2627ffc0dd6499a9a1b20fa217b7f1c4a9723a6fd6332ef24a9ee251b5b0bf56"
        )
        XCTAssertEqual(predecessor.authorityClosureRunID, 31_773_463_958)
        XCTAssertEqual(predecessor.authorityClosureRunNumber, 109)
        XCTAssertEqual(
            predecessor.authorityClosureCheckSuiteID,
            86_198_647_430
        )
        XCTAssertEqual(predecessor.authorityClosureRunAttempt, 1)
        XCTAssertEqual(predecessor.authorityClosureArtifactCount, 0)
        XCTAssertEqual(predecessor.authorityClosureRerunCount, 0)
        XCTAssertEqual(predecessor.authorityClosureConclusion, "success")

        let suite = observation.suite
        XCTAssertEqual(suite.rootTestCount, 55)
        XCTAssertEqual(suite.isolatedGroupTestCounts, [1, 1, 2, 2])
        XCTAssertEqual(suite.isolatedTestCount, 6)
        XCTAssertEqual(suite.focusedStage6PureContractXCTestCount, 1)
        XCTAssertEqual(suite.focusedStepXCTestCount, 62)
        XCTAssertEqual(suite.metalTestCount, 44)
        XCTAssertEqual(suite.maintainedRuntimeTestCount, 1)
        XCTAssertEqual(suite.maintainedRuntimeReceiptCount, 1)
        XCTAssertEqual(suite.tokenizerTestCount, 1)
        XCTAssertEqual(suite.tokenizerReceiptCount, 1)
        XCTAssertEqual(suite.stage6LauncherPureContractXCTestCount, 1)
        XCTAssertEqual(suite.liveStepXCTestCount, 47)
        XCTAssertEqual(suite.totalXCTestCount, 109)
        XCTAssertEqual(suite.totalXCTestFailureCount, 0)
        XCTAssertEqual(suite.totalXCTestSkipCount, 0)
        XCTAssertEqual(suite.stage6LauncherInvocationCount, 1)
        XCTAssertEqual(suite.stage6BuildCount, 1)
        XCTAssertEqual(suite.stage6DirectXCTestCount, 1)
        XCTAssertEqual(suite.stage6DirectExecutableProbeCount, 1)
        XCTAssertEqual(suite.stage6ReceiptCount, 1)
        XCTAssertEqual(suite.stage6AggregateInvocationCount, 3)
        XCTAssertEqual(
            suite.exactLiveOrder,
            ["metal", "maintained_runtime", "tokenizer", "stage6"]
        )
        XCTAssertEqual(
            suite.exactStage6InternalOrder,
            [
                "stage6_pure_contract_xctest",
                "stage6_resource_probe_executable",
            ]
        )

        let fetch = observation.secureFetch
        XCTAssertEqual(fetch.invocationCount, 1)
        XCTAssertEqual(fetch.completionCount, 1)
        XCTAssertEqual(fetch.authenticatedDepthOneFetchCount, 1)
        XCTAssertEqual(fetch.submoduleUpdateCount, 1)
        XCTAssertEqual(fetch.mlxCloneCount, 1)
        XCTAssertEqual(fetch.mlxCCloneCount, 1)
        XCTAssertEqual(
            [
                fetch.workflowAuthoredRetryCount,
                fetch.gitInternalRetryCount,
                fetch.tlsFailureCount,
                fetch.sslFailureCount,
                fetch.certificateFailureCount,
                fetch.dnsFailureCount,
                fetch.tlsVerificationBypassCount,
                fetch.customCAInstallationCount,
            ],
            Array(repeating: 0, count: 8)
        )

        XCTAssertEqual(observation.metallib.byteCount, 6_292_716)
        XCTAssertEqual(
            observation.metallib.sha256,
            "835c4bb71b0693022a8a9565b2131f3a6bd478e78f03737b6b0cc373401f05be"
        )
        XCTAssertEqual(observation.metallib.freshCandidateCount, 1)
        XCTAssertEqual(observation.metallib.stagedCopyCount, 1)
        XCTAssertEqual(observation.metallib.stagedPermissionMode, "444")
        XCTAssertFalse(observation.metallib.retainedAfterJob)
        XCTAssertFalse(observation.metallib.artifactUploadInvoked)

        let receipt = observation.receipt
        let receiptData = Data(receipt.canonicalJSON.utf8)
        XCTAssertEqual(receipt.rawJSONByteCount, 17_435)
        XCTAssertEqual(receiptData.count, receipt.rawJSONByteCount)
        XCTAssertEqual(receipt.rawJSONLFByteCount, 0)
        XCTAssertFalse(receipt.rawJSONEndsWithLF)
        XCTAssertEqual(receipt.anchoredOccurrenceCount, 1)
        XCTAssertEqual(receipt.totalOccurrenceCount, 1)
        XCTAssertTrue(receipt.rawJSONWasCanonical)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: receiptData),
            "104f3579f2caf19f27cbbe694f8a854cc8927d9188af055075c11b1fe1c94c55"
        )
        let prefixedLine = Data((receipt.prefix + receipt.canonicalJSON).utf8)
        XCTAssertEqual(prefixedLine.count, 17_505)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: prefixedLine),
            "454b623ce9a95131de9b2f03f5a1e4100ef52023bc0ccaf644567d6d4eda2185"
        )
        let receiptObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: receiptData)
                as? [String: Any]
        )
        XCTAssertEqual(
            try canonicalJSONData(receiptObject),
            receiptData
        )
        XCTAssertEqual(receiptObject["schema_version"] as? Int, 1)
        XCTAssertEqual(
            receiptObject["receipt_id"] as? String,
            receipt.receiptID
        )

        let outcome = observation.outcome
        XCTAssertEqual(outcome.status, "PASS")
        XCTAssertEqual(outcome.classification, "pass")
        XCTAssertTrue(outcome.oneShotConsumed)
        XCTAssertTrue(outcome.workerCandidatePresent)
        XCTAssertTrue(outcome.resourceProbeExecuted)
        XCTAssertTrue(outcome.resourceEnvelopeEstablished)
        XCTAssertTrue(outcome.resourceClearanceEstablished)
        XCTAssertTrue(outcome.runnerMemoryCapacityEstablished)
        XCTAssertTrue(outcome.updateOccurred)
        XCTAssertTrue(outcome.postflightDeviceIdentityMatchesPreflight)
        XCTAssertTrue(outcome.postflightMLXPolicyAndLimitsMatchPreflight)
        XCTAssertEqual(outcome.lossFloat32Bits, 1_088_043_293)
        XCTAssertEqual(outcome.rawGradientNormFloat32Bits, 1_101_890_567)
        XCTAssertEqual(outcome.gradientClipScaleFloat32Bits, 1_027_397_872)
        XCTAssertNotEqual(
            outcome.parameterFingerprintBefore,
            outcome.parameterFingerprintAfter
        )
        XCTAssertEqual(outcome.parameterFingerprintSampleCount, 654)
        XCTAssertEqual(outcome.operationCounts.modelAllocationCount, 1)
        XCTAssertEqual(outcome.operationCounts.modelMaterializationCount, 1)
        XCTAssertEqual(outcome.operationCounts.valueAndGradCount, 1)
        XCTAssertEqual(outcome.operationCounts.backwardCount, 1)
        XCTAssertEqual(outcome.operationCounts.gradientNormCount, 1)
        XCTAssertEqual(outcome.operationCounts.gradientClipCount, 1)
        XCTAssertEqual(outcome.operationCounts.optimizerStepCount, 1)
        XCTAssertEqual(outcome.operationCounts.adamWUpdateCount, 1)
        XCTAssertEqual(
            outcome.operationCounts.checkedEvaluationBarrierCount,
            5
        )
        XCTAssertEqual(
            outcome.operationCounts.gpuSynchronizationBarrierCount,
            5
        )
        XCTAssertEqual(outcome.operationCounts.evaluationForwardPassCount, 0)
        XCTAssertEqual(outcome.operationCounts.kvCacheAllocationCount, 0)

        XCTAssertTrue(observation.lease.workerOwned)
        XCTAssertTrue(observation.lease.acquiredNonblocking)
        XCTAssertTrue(
            observation.lease.acquiredBeforeCoreGraphicsMetalOrMLX
        )
        XCTAssertTrue(observation.lease.heldThroughCandidateFlush)
        XCTAssertTrue(observation.lease.heldThroughPostflight)
        XCTAssertTrue(observation.lease.supervisorReacquireReleaseProved)
        XCTAssertEqual(observation.limits.weightsLogicalBytes, 1_084_428_288)
        XCTAssertEqual(
            observation.limits.optimizerMomentLogicalBytes,
            2_168_856_576
        )
        XCTAssertEqual(
            observation.limits.minimumStatePlusGradientBytes,
            4_337_713_152
        )
        XCTAssertEqual(
            observation.limits.configuredMemoryLimitBytes,
            5_010_800_640
        )
        XCTAssertEqual(
            observation.limits.availableFilesystemFloorBytes,
            12_884_901_888
        )
        XCTAssertTrue(observation.limits.mlxLimitIsNotRSSLimit)
        XCTAssertTrue(observation.limits.statfsIsObservationalOnly)

        XCTAssertEqual(observation.phaseMetrics.count, 6)
        XCTAssertEqual(
            observation.phaseMetrics.map(\.phase),
            [
                "preflight",
                "post_model_materialization",
                "post_forward_backward",
                "post_norm_clip",
                "post_adam_update_full_evaluation",
                "post_lexical_deallocation_and_clear_cache",
            ]
        )
        XCTAssertTrue(
            observation.phaseMetrics.allSatisfy {
                $0.availability == "observed" && $0.unavailableReason == nil
            }
        )
        XCTAssertEqual(
            observation.phaseMetrics.map(\.mlxPeakBytes),
            [0, 1_084_432_344, 2_190_878_848, 3_253_285_660,
             4_781_317_844, 4_781_317_844]
        )

        XCTAssertTrue(observation.retirement.required)
        XCTAssertFalse(observation.retirement.observed)
        XCTAssertTrue(observation.retirement.successfulAttemptConsumed)
        XCTAssertTrue(
            observation.retirement.exactMainRetirementClosureRequired
        )
        XCTAssertEqual(observation.retirement.exactChangedPaths.count, 5)
        XCTAssertEqual(observation.retirement.expectedRootTestCount, 56)
        XCTAssertEqual(
            observation.retirement.expectedIsolatedGroupTestCounts,
            [1, 1, 2, 2]
        )
        XCTAssertEqual(
            observation.retirement.expectedFocusedWholeTestCount,
            62
        )
        XCTAssertEqual(observation.retirement.expectedTotalTestCount, 108)
        XCTAssertEqual(
            observation.retirement.expectedLiveOrder,
            ["metal", "maintained_runtime", "tokenizer"]
        )
        XCTAssertEqual(
            observation.retirement.expectedStage6LauncherInvocationCount,
            0
        )
        XCTAssertEqual(observation.retirement.expectedStage6ReceiptCount, 0)
        XCTAssertTrue(observation.retirement.launcherSourcePreservedForAudit)

        let ceiling = observation.ceiling
        let falseCeilings = [
            ceiling.additionalExecutionOrRerunAuthorized,
            ceiling.additionalNative300MAllocationAuthorized,
            ceiling.additionalResourceProbeExecutionAuthorized,
            ceiling.artifactUploadAuthorized,
            ceiling.broadNative300MTrainingAuthorized,
            ceiling.canaryAuthorized,
            ceiling.candidateAdmissionGranted,
            ceiling.checkpointAdmissionGranted,
            ceiling.downstreamTrialAuthorized,
            ceiling.durableCheckpointIOAuthorized,
            ceiling.exactMetalGradientBytesEstablished,
            ceiling.generalTrainingResumeEstablished,
            ceiling.metalDeterminismEstablished,
            ceiling.modelQualityEstablished,
            ceiling.native300MTrajectoryTrainingResumeEstablished,
            ceiling.ordinaryJobFitEstablished,
            ceiling.productUseAuthorized,
            ceiling.publicationAuthorized,
            ceiling.quantizationAuthorized,
            ceiling.repeatedTrajectoryDeterminismEstablished,
            ceiling.retainedArtifactAuthorized,
            ceiling.stage5AssayClearanceEstablished,
            ceiling.stage5MechanicsSuccessEstablished,
            ceiling.stage5ReplacementExecutionAuthorized,
            ceiling.stage5ResultEstablished,
            ceiling.stage7AuthorityEstablished,
            ceiling.stage7Authorized,
        ]
        XCTAssertEqual(falseCeilings.count, 27)
        XCTAssertTrue(falseCeilings.allSatisfy { !$0 })
        XCTAssertTrue(
            ceiling.stage7RequiresStage5AssayAndStage6ResourceClearance
        )
        XCTAssertTrue(ceiling.stage5AssayClearanceMissingBlocksStage7)
        XCTAssertFalse(ceiling.stage5ResultEstablished)
        XCTAssertFalse(ceiling.stage5AssayClearanceEstablished)
        XCTAssertFalse(ceiling.stage5MechanicsSuccessEstablished)
        XCTAssertFalse(
            ceiling.repeatedTrajectoryDeterminismEstablished
        )
        XCTAssertFalse(ceiling.additionalNative300MAllocationAuthorized)
        XCTAssertFalse(ceiling.additionalResourceProbeExecutionAuthorized)
        XCTAssertFalse(ceiling.stage7AuthorityEstablished)
        XCTAssertFalse(ceiling.stage7Authorized)
        XCTAssertFalse(
            ceiling.additionalExecutionOrRerunAuthorized
        )

        let sourceRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let sourceURL = sourceRoot.appendingPathComponent(
            "Sources/PrimeCore/PrimeNativeDecoderNative300MResourceOnlyOneStepProbeExecutionObservation.swift"
        )
        let sourceText = try String(contentsOf: sourceURL, encoding: .utf8)
        XCTAssertEqual(
            sourceText.split(separator: "\n").filter {
                $0.hasPrefix("import ")
            }.map(String.init),
            ["import Foundation"]
        )
        for forbidden in [
            "import CoreGraphics", "import Metal", "import MLX",
            "FileManager.", "FileHandle.", "URLSession", "Process(",
            "posix_spawn", "execve(", "Memory.clearCache(",
        ] {
            XCTAssertFalse(sourceText.contains(forbidden), forbidden)
        }
        let testText = try String(contentsOfFile: #filePath, encoding: .utf8)
        XCTAssertEqual(
            testText.components(separatedBy: "func " + "test").count - 1,
            1
        )

        let canonical = try observation.canonicalData()
        XCTAssertEqual(canonical, try PrimeCanonicalJSON.encode(observation))
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: canonical),
            Observation.canonicalSHA256
        )
        XCTAssertEqual(
            try Observation.decodeCanonical(canonical),
            observation
        )
        XCTAssertThrowsError(
            try Observation.decodeCanonical(Data([0x20]) + canonical)
        )
        XCTAssertThrowsError(
            try Observation.decodeCanonical(canonical + Data([0x0A]))
        )

        let observationObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical)
                as? [String: Any]
        )
        let observationValuePaths = allValuePaths(in: observationObject)
        let observationDictionaryPaths = allDictionaryPaths(
            in: observationObject
        )
        XCTAssertGreaterThan(observationValuePaths.count, 225)
        XCTAssertGreaterThan(observationDictionaryPaths.count, 15)
        for path in observationValuePaths {
            try assertObservationRejects(
                replacingValue(
                    in: observationObject,
                    at: path,
                    with: mutateJSONValue
                ),
                label: "mutated observation \(pathLabel(path))"
            )
            try assertObservationRejects(
                removingValue(in: observationObject, at: path),
                label: "removed observation \(pathLabel(path))"
            )
        }
        for (index, path) in observationDictionaryPaths.enumerated() {
            try assertObservationRejects(
                replacingValue(
                    in: observationObject,
                    at: path,
                    with: { value in
                        var object = value as! [String: Any]
                        object["unknown_stage6_observation_\(index)"] = true
                        return object
                    }
                ),
                label: "unknown observation field \(pathLabel(path))"
            )
        }

        var reorderedParentsObservation = observationObject
        var reorderedRun = reorderedParentsObservation["run"]
            as! [String: Any]
        var reorderedParents = reorderedRun["orderedParentRevisions"]
            as! [Any]
        reorderedParents.swapAt(0, 1)
        reorderedRun["orderedParentRevisions"] = reorderedParents
        reorderedParentsObservation["run"] = reorderedRun
        try assertObservationRejects(
            reorderedParentsObservation,
            label: "same-cardinality ordered-parent reorder"
        )

        var reorderedPhasesObservation = observationObject
        var reorderedPhases = reorderedPhasesObservation["phaseMetrics"]
            as! [Any]
        reorderedPhases.swapAt(0, 1)
        reorderedPhasesObservation["phaseMetrics"] = reorderedPhases
        try assertObservationRejects(
            reorderedPhasesObservation,
            label: "same-cardinality phase-metric reorder"
        )

        let receiptScalarPaths = allScalarPaths(in: receiptObject)
        let receiptDictionaryPaths = allDictionaryPaths(in: receiptObject)
        XCTAssertEqual(receiptScalarPaths.count, 391)
        XCTAssertGreaterThan(receiptDictionaryPaths.count, 20)
        for path in receiptScalarPaths {
            let mutatedReceipt = replacingValue(
                in: receiptObject,
                at: path,
                with: mutateJSONValue
            )
            try assertReceiptSubstitutionRejects(
                mutatedReceipt,
                in: observationObject,
                label: "mutated receipt \(pathLabel(path))"
            )
            let removedReceipt = removingValue(in: receiptObject, at: path)
            try assertReceiptSubstitutionRejects(
                removedReceipt,
                in: observationObject,
                label: "removed receipt \(pathLabel(path))"
            )
        }
        for (index, path) in receiptDictionaryPaths.enumerated() {
            let unknownReceipt = replacingValue(
                in: receiptObject,
                at: path,
                with: { value in
                    var object = value as! [String: Any]
                    object["unknown_stage6_receipt_\(index)"] = true
                    return object
                }
            )
            try assertReceiptSubstitutionRejects(
                unknownReceipt,
                in: observationObject,
                label: "unknown receipt field \(pathLabel(path))"
            )
        }

        let pretty = try JSONSerialization.data(
            withJSONObject: observationObject,
            options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        )
        XCTAssertNotEqual(pretty, canonical)
        XCTAssertThrowsError(try Observation.decodeCanonical(pretty))
    }

    private enum JSONPathComponent: Equatable {
        case key(String)
        case index(Int)

        var label: String {
            switch self {
            case let .key(key):
                return key
            case let .index(index):
                return "[\(index)]"
            }
        }
    }

    private typealias JSONPath = [JSONPathComponent]

    private func requireSendable<T: Sendable>(_: T.Type) {}

    private func pathLabel(_ path: JSONPath) -> String {
        path.isEmpty ? "<root>" : path.map(\.label).joined(separator: ".")
    }

    private func allValuePaths(
        in value: Any,
        prefix: JSONPath = []
    ) -> [JSONPath] {
        if let object = value as? [String: Any] {
            return object.keys.sorted().flatMap { key in
                let path = prefix + [.key(key)]
                return [path] + allValuePaths(in: object[key]!, prefix: path)
            }
        }
        if let array = value as? [Any] {
            return array.indices.flatMap { index in
                let path = prefix + [.index(index)]
                return [path] + allValuePaths(in: array[index], prefix: path)
            }
        }
        return []
    }

    private func allDictionaryPaths(
        in value: Any,
        prefix: JSONPath = []
    ) -> [JSONPath] {
        if let object = value as? [String: Any] {
            return [prefix] + object.keys.sorted().flatMap { key in
                allDictionaryPaths(
                    in: object[key]!,
                    prefix: prefix + [.key(key)]
                )
            }
        }
        if let array = value as? [Any] {
            return array.indices.flatMap { index in
                allDictionaryPaths(
                    in: array[index],
                    prefix: prefix + [.index(index)]
                )
            }
        }
        return []
    }

    private func allScalarPaths(
        in value: Any,
        prefix: JSONPath = []
    ) -> [JSONPath] {
        if let object = value as? [String: Any] {
            return object.keys.sorted().flatMap { key in
                allScalarPaths(
                    in: object[key]!,
                    prefix: prefix + [.key(key)]
                )
            }
        }
        if let array = value as? [Any] {
            return array.indices.flatMap { index in
                allScalarPaths(
                    in: array[index],
                    prefix: prefix + [.index(index)]
                )
            }
        }
        return [prefix]
    }

    private func replacingValue(
        in value: Any,
        at path: JSONPath,
        with transform: (Any) -> Any
    ) -> Any {
        guard let component = path.first else {
            return transform(value)
        }
        let remainder = Array(path.dropFirst())
        switch component {
        case let .key(key):
            var object = value as! [String: Any]
            object[key] = replacingValue(
                in: object[key]!,
                at: remainder,
                with: transform
            )
            return object
        case let .index(index):
            var array = value as! [Any]
            array[index] = replacingValue(
                in: array[index],
                at: remainder,
                with: transform
            )
            return array
        }
    }

    private func removingValue(in value: Any, at path: JSONPath) -> Any {
        precondition(!path.isEmpty)
        let component = path[0]
        let remainder = Array(path.dropFirst())
        switch component {
        case let .key(key):
            var object = value as! [String: Any]
            if remainder.isEmpty {
                object.removeValue(forKey: key)
            } else {
                object[key] = removingValue(in: object[key]!, at: remainder)
            }
            return object
        case let .index(index):
            var array = value as! [Any]
            if remainder.isEmpty {
                array.remove(at: index)
            } else {
                array[index] = removingValue(in: array[index], at: remainder)
            }
            return array
        }
    }

    private func mutateJSONValue(_ value: Any) -> Any {
        if value is NSNull {
            return "__mutation_from_null"
        }
        if let string = value as? String {
            return string + "__mutation"
        }
        if let number = value as? NSNumber {
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                return !number.boolValue
            }
            return NSNumber(value: number.int64Value + 1)
        }
        if var array = value as? [Any] {
            array.append(array.first ?? "__mutation")
            return array
        }
        if var object = value as? [String: Any] {
            object["unknown_recursive_mutation"] = true
            return object
        }
        XCTFail("unsupported canonical JSON value: \(value)")
        return value
    }

    private func canonicalJSONData(_ object: Any) throws -> Data {
        try JSONSerialization.data(
            withJSONObject: object,
            options: [.sortedKeys, .withoutEscapingSlashes]
        )
    }

    private func assertObservationRejects(
        _ object: Any,
        label: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let data = try canonicalJSONData(object)
        XCTAssertThrowsError(
            try Observation.decodeCanonical(data),
            label,
            file: file,
            line: line
        )
    }

    private func assertReceiptSubstitutionRejects(
        _ receiptObject: Any,
        in observationObject: [String: Any],
        label: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let mutatedReceiptData = try canonicalJSONData(receiptObject)
        let mutatedReceiptText = try XCTUnwrap(
            String(data: mutatedReceiptData, encoding: .utf8),
            file: file,
            line: line
        )
        var mutatedObservation = observationObject
        var receipt = mutatedObservation["receipt"] as! [String: Any]
        receipt["canonicalJSON"] = mutatedReceiptText
        mutatedObservation["receipt"] = receipt
        try assertObservationRejects(
            mutatedObservation,
            label: label,
            file: file,
            line: line
        )
    }
}
