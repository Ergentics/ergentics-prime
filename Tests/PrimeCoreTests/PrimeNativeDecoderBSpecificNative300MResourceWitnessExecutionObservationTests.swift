// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
@testable import PrimeCore
import XCTest

final class
    PrimeNativeDecoderBSpecificNative300MResourceWitnessExecutionObservationTests:
    XCTestCase
{
    private typealias Observation =
        PrimeNativeDecoderBSpecificNative300MResourceWitnessExecutionObservationV1

    func testBSpecificNative300MResourceWitnessPASSExecutionObservationIsExactAndRejectsEveryRecursiveMutation()
        throws
    {
        requireSendable(Observation.self)
        let observation = Observation.frozenV1
        XCTAssertNoThrow(try observation.validate())
        XCTAssertNoThrow(try observation.validateExactV1())

        XCTAssertEqual(observation.schemaVersion, 1)
        XCTAssertEqual(
            observation.observationID,
            "ergentics_prime_native_decoder_b_specific_native300m_resource_witness_execution_observation_v1"
        )
        XCTAssertEqual(
            observation.predecessorAuthorityID,
            PrimeNativeDecoderBSpecificNative300MResourceWitnessAuthorityV1
                .frozenV1.authorityID
        )
        XCTAssertEqual(
            observation.predecessorAuthorityCanonicalSHA256,
            PrimeNativeDecoderBSpecificNative300MResourceWitnessAuthorityV1
                .canonicalSHA256
        )

        let repository = observation.repositoryIdentity
        XCTAssertEqual(repository.pullRequestNumber, 113)
        XCTAssertEqual(
            repository.mergeRevision,
            "bf98ddb13f6f6128a185b2f553b5cb3f1e30904b"
        )
        XCTAssertEqual(
            repository.mergeTree,
            "2ef7501506f19b9d9734dbc63ccacc62182c3952"
        )
        XCTAssertEqual(
            repository.orderedParentRevisions,
            [
                "b1695b17523068e2b720066d84c422cbe2e67975",
                "09c47cba0c9b2c69568bbe7e2a7c25f89fe3cbb3",
            ]
        )
        XCTAssertTrue(repository.mergeCommitSignatureVerified)
        XCTAssertEqual(repository.mergeCommitSignatureReason, "valid")
        XCTAssertEqual(observation.observedSourceBindings.count, 8)
        XCTAssertEqual(
            observation.observedSourceBindings.map(\.path),
            [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/scripts/prime-ci-native-decoder-b-specific-native300m-resource-witness.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderBSpecificNative300MResourceWitness.swift",
                "Tests/PrimeNativeDecoderTrainingValidation/Package.swift",
                "Tests/PrimeNativeDecoderTrainingValidation/Sources/PrimeNativeDecoderBSpecificNative300MResourceWitness/main.swift",
                "Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderBSpecificNative300MResourceWitnessContractTests.swift",
            ]
        )
        XCTAssertEqual(
            observation.observedSourceBindings.map(\.gitMode),
            [
                "100755", "100755", "100644", "100644",
                "100644", "100644", "100644", "100644",
            ]
        )

        let pr = observation.pullRequestLane
        XCTAssertEqual(pr.runID, 31_859_411_371)
        XCTAssertEqual(pr.runNumber, 122)
        XCTAssertEqual(pr.runAttempt, 1)
        XCTAssertEqual(pr.checkSuiteID, 86_430_890_995)
        XCTAssertEqual(
            pr.headRevision,
            "09c47cba0c9b2c69568bbe7e2a7c25f89fe3cbb3"
        )
        XCTAssertEqual(
            pr.orderedParentRevisions,
            ["b1695b17523068e2b720066d84c422cbe2e67975"]
        )
        XCTAssertEqual(pr.activeRootJob.id, 94_949_960_837)
        XCTAssertEqual(pr.activeRootJob.conclusion, "success")
        XCTAssertEqual(pr.reviewedMainJob.id, 94_950_338_938)
        XCTAssertEqual(pr.reviewedMainJob.conclusion, "skipped")
        XCTAssertTrue(pr.reviewedMainJob.orderedStepNames.isEmpty)
        XCTAssertEqual(pr.artifactCount, 0)
        XCTAssertEqual(pr.launcherInvocationCount, 0)
        XCTAssertEqual(pr.directExecutableProbeCount, 0)
        XCTAssertEqual(pr.witnessExecutionCount, 0)
        XCTAssertEqual(pr.metalExecutionCount, 0)
        XCTAssertEqual(pr.native300MMechanicsExecutionCount, 0)
        XCTAssertEqual(pr.relevantReceiptCount, 0)

        let run = observation.runIdentity
        XCTAssertEqual(run.runID, 31_859_699_200)
        XCTAssertEqual(run.runNumber, 123)
        XCTAssertEqual(run.runAttempt, 1)
        XCTAssertEqual(run.checkSuiteID, 86_431_552_971)
        XCTAssertEqual(run.status, "completed")
        XCTAssertEqual(run.conclusion, "success")
        XCTAssertEqual(run.exactHeadPushRunCount, 1)
        XCTAssertTrue(run.previousAttemptURLWasNull)
        XCTAssertEqual(run.retryCount, 0)
        XCTAssertEqual(run.rerunCount, 0)
        XCTAssertEqual(run.artifactCount, 0)
        XCTAssertEqual(observation.activeRootJob.id, 94_950_745_364)
        XCTAssertEqual(observation.reviewedMainJob.id, 94_951_238_266)
        XCTAssertEqual(observation.activeRootJob.conclusion, "success")
        XCTAssertEqual(observation.reviewedMainJob.conclusion, "success")
        XCTAssertEqual(
            observation.activeRootRawLog.sha256,
            "0a68ea617ea5c574f8ee430fd319ea958ca52c8dfdfd359225afdf29ed059ee3"
        )
        XCTAssertEqual(
            observation.reviewedMainRawLog.sha256,
            "39559916cb1f930c0c2e07ed1cd669ebfad26f30349d3dd05bbb7834d339f71b"
        )

        let topology = observation.testTopology
        XCTAssertEqual(topology.focusedStepXCTestCount, 67)
        XCTAssertEqual(topology.liveStepXCTestCount, 47)
        XCTAssertEqual(topology.totalXCTestCount, 114)
        XCTAssertEqual(topology.totalFailureCount, 0)
        XCTAssertEqual(topology.totalSkipCount, 0)
        XCTAssertEqual(topology.bContractStartCount, 2)
        XCTAssertEqual(topology.bContractPassCount, 2)
        XCTAssertEqual(topology.launcherInvocationCount, 1)
        XCTAssertEqual(topology.directExecutableProbeCount, 1)
        XCTAssertEqual(topology.privateCandidateCount, 1)
        XCTAssertEqual(topology.privateTerminalCount, 1)
        XCTAssertEqual(topology.publicReceiptCount, 1)

        let retirement = observation.retirementBoundary
        XCTAssertTrue(retirement.retirementRequired)
        XCTAssertFalse(retirement.retirementObserved)
        XCTAssertTrue(retirement.successfulAttemptConsumed)
        XCTAssertEqual(
            retirement.exactChangedPaths.map(\.path),
            [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                "Sources/PrimeCore/PrimeNativeDecoderBSpecificNative300MResourceWitnessExecutionObservation.swift",
                "Tests/PrimeCoreTests/PrimeNativeDecoderBSpecificNative300MResourceWitnessExecutionObservationTests.swift",
            ]
        )
        XCTAssertEqual(
            retirement.exactChangedPaths.map(\.gitMode),
            ["100755", "100644", "100644", "100644", "100644"]
        )
        XCTAssertEqual(retirement.expectedRootTestCount, 61)
        XCTAssertEqual(retirement.expectedIsolatedTestCount, 6)
        XCTAssertEqual(retirement.expectedFocusedWholeTestCount, 67)
        XCTAssertEqual(retirement.expectedLiveStepXCTestCount, 46)
        XCTAssertEqual(retirement.expectedTotalXCTestCount, 113)
        XCTAssertEqual(retirement.expectedBFocusedContractTestCount, 0)
        XCTAssertEqual(retirement.expectedBLauncherLocalContractTestCount, 0)
        XCTAssertEqual(retirement.expectedBDirectExecutableProbeCount, 0)
        XCTAssertEqual(retirement.expectedBLauncherInvocationCount, 0)
        XCTAssertEqual(retirement.expectedBInternalCandidatePrefixCount, 0)
        XCTAssertEqual(retirement.expectedBInternalTerminalPrefixCount, 0)
        XCTAssertEqual(retirement.expectedBPublicReceiptCount, 0)
        XCTAssertEqual(
            retirement.expectedOriginalStage5LauncherInvocationCount,
            0
        )
        XCTAssertEqual(
            retirement.expectedReplacementStage5LauncherInvocationCount,
            0
        )
        XCTAssertEqual(
            retirement.expectedHistoricalStage6LauncherInvocationCount,
            0
        )
        XCTAssertEqual(retirement.expectedOriginalStage5ReceiptCount, 0)
        XCTAssertEqual(retirement.expectedReplacementStage5ReceiptCount, 0)
        XCTAssertEqual(retirement.expectedHistoricalStage6ReceiptCount, 0)

        let receipt = observation.receiptIdentity
        let receiptData = Data(receipt.canonicalJSON.utf8)
        XCTAssertEqual(receipt.prefixByteCount, 71)
        XCTAssertEqual(receiptData.count, 14_493)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: receiptData),
            "600df63cec92063a3e6099075397b674ae238589c5232fb3cfa16cabc6212d54"
        )
        XCTAssertEqual(receipt.prefixedCanonicalByteCount, 14_564)
        XCTAssertEqual(
            receipt.prefixedCanonicalSHA256,
            "92e16737351eaa261409f3e5edb282a9bed633dd5377041cd2bbfae777d59dc9"
        )
        XCTAssertEqual(receipt.prefixedCanonicalLFByteCount, 14_565)
        XCTAssertEqual(
            receipt.prefixedCanonicalLFSHA256,
            "408a3d343ae13dcfbdd85fd187a45c80555463edf9de4ed6f388a308ee2dd5db"
        )
        XCTAssertEqual(receipt.logLineNumber, 79_482)
        XCTAssertEqual(receipt.exactOccurrenceCount, 1)
        XCTAssertEqual(receipt.topLevelKeyCount, 39)
        XCTAssertEqual(receipt.candidateCanonicalByteCount, 8_397)
        XCTAssertEqual(
            receipt.candidateSHA256,
            "aad81c55024652ef594e65dfbfbbba74f34176c6cf1792b45676cbbdaacfbba8"
        )
        XCTAssertEqual(receipt.terminalCanonicalByteCount, 2_425)
        XCTAssertEqual(
            receipt.terminalSHA256,
            "ec960f822eab44b516273f19205246de5cb4bd544da7312b1396f60ceb48c2a4"
        )

        let receiptObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: receiptData)
                as? [String: Any]
        )
        XCTAssertEqual(
            try canonicalJSONData(receiptObject),
            receiptData
        )
        XCTAssertNil(receiptObject["mechanics_success"])
        XCTAssertNil(receiptObject["workflow_success"])
        let candidateObject = try XCTUnwrap(
            receiptObject["validated_private_candidate"]
                as? [String: Any]
        )
        let terminalObject = try XCTUnwrap(
            receiptObject["validated_private_terminal"]
                as? [String: Any]
        )
        let candidateData = try canonicalJSONData(candidateObject)
        let terminalData = try canonicalJSONData(terminalObject)
        XCTAssertEqual(candidateData.count, 8_397)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: candidateData),
            receipt.candidateSHA256
        )
        XCTAssertEqual(terminalData.count, 2_425)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: terminalData),
            receipt.terminalSHA256
        )

        let resource = observation.resourcePassBoundary
        XCTAssertEqual(resource.candidateScientificStatus, "PASS")
        XCTAssertTrue(resource.resourceProbeExecuted)
        XCTAssertTrue(resource.resourceEnvelopeEstablished)
        XCTAssertTrue(resource.bSpecificNative300MResourceWitnessEstablished)
        XCTAssertTrue(
            resource.bSpecificNative300MResourceClearanceEstablished
        )
        XCTAssertEqual(resource.directPackageBTrainingLogitsAPICallCount, 1)
        XCTAssertEqual(resource.maintainedGatherTrainingLogitsCount, 0)
        XCTAssertEqual(resource.checkedEvaluationBarrierCount, 6)
        XCTAssertEqual(resource.gpuSynchronizationBarrierCount, 6)
        XCTAssertEqual(resource.mlxMemoryHeadroomBytes, 220_029_148)

        let integrity = observation.integrityPassBoundary
        XCTAssertEqual(integrity.terminalStatus, "PASS")
        XCTAssertTrue(integrity.leaseAcquired)
        XCTAssertTrue(integrity.releaseVerifierExitZero)
        XCTAssertEqual(integrity.supervisorIntegrityGuardCount, 13)
        XCTAssertNil(integrity.firstFailedGuardID)
        XCTAssertNil(integrity.errno)
        XCTAssertFalse(integrity.actualMetadataPresent)
        XCTAssertTrue(integrity.leaseTupleStableThroughVerifier)
        XCTAssertTrue(
            integrity.parentStableFieldsMatchPreflightAndVerifier
        )

        let workflow = observation.workflowClosureBoundary
        XCTAssertEqual(workflow.workflowConclusion, "success")
        XCTAssertEqual(workflow.launcherExitCode, 0)
        XCTAssertTrue(workflow.launcherExitedZero)
        XCTAssertTrue(workflow.launcherClosureEstablished)
        XCTAssertTrue(workflow.publicReceiptWasLastLauncherOutput)
        XCTAssertTrue(workflow.receiptDoesNotClaimMechanicsSuccess)
        XCTAssertTrue(workflow.receiptDoesNotClaimWorkflowSuccess)
        XCTAssertFalse(workflow.artifactUploadInvoked)
        XCTAssertFalse(workflow.retryObserved)
        XCTAssertFalse(workflow.rerunObserved)
        XCTAssertTrue(workflow.outerJobClosedAfterReceipt)

        let ceiling = observation.authorityCeiling
        XCTAssertTrue(ceiling.oneShotConsumed)
        XCTAssertTrue(ceiling.oneShotExhausted)
        XCTAssertTrue(ceiling.stage5MechanicsSuccessEstablished)
        XCTAssertTrue(ceiling.stage5ResultEstablished)
        XCTAssertTrue(ceiling.stage5AssayClearanceEstablished)
        XCTAssertTrue(ceiling.repeatedSameDeviceBPathDeterminismEstablished)
        XCTAssertTrue(ceiling.exactSameDeviceBPathGradientBytesEstablished)
        XCTAssertTrue(ceiling.bSpecificNative300MResourceWitnessEstablished)
        XCTAssertTrue(ceiling.bSpecificNative300MResourceClearanceEstablished)
        XCTAssertTrue(
            ceiling.historicalStage6ResourceClearanceRemainsEstablished
        )
        XCTAssertFalse(ceiling.additionalExecutionAuthorized)
        XCTAssertFalse(ceiling.replacementExecutionAuthorized)
        XCTAssertFalse(ceiling.additionalNative300MAllocationAuthorized)
        XCTAssertFalse(ceiling.additionalNative300MExecutionAuthorized)
        XCTAssertFalse(
            ceiling.additionalBResourceWitnessExecutionAuthorized
        )
        XCTAssertFalse(ceiling.retryAuthorized)
        XCTAssertFalse(ceiling.rerunAuthorized)
        XCTAssertFalse(ceiling.artifactUploadAuthorized)
        XCTAssertFalse(ceiling.ordinaryJobFitEstablished)
        XCTAssertFalse(
            ceiling.historicalStage6ResourceClearanceAppliesToBPath
        )
        XCTAssertFalse(ceiling.broadNative300MTrainingAuthorized)
        XCTAssertFalse(ceiling.generalTrainingResumeEstablished)
        XCTAssertFalse(
            ceiling.native300MTrajectoryTrainingResumeEstablished
        )
        XCTAssertFalse(ceiling.durableCheckpointIOAuthorized)
        XCTAssertFalse(ceiling.checkpointAdmissionGranted)
        XCTAssertFalse(ceiling.candidateAdmissionGranted)
        XCTAssertFalse(ceiling.modelQualityEstablished)
        XCTAssertFalse(ceiling.downstreamTrialAuthorized)
        XCTAssertFalse(ceiling.canaryAuthorized)
        XCTAssertFalse(ceiling.quantizationAuthorized)
        XCTAssertFalse(ceiling.productUseAuthorized)
        XCTAssertFalse(ceiling.publicationAuthorized)
        XCTAssertTrue(ceiling.stage7RequiresSeparateAuthorityAfterWitness)
        XCTAssertFalse(ceiling.stage7AuthorityEstablished)
        XCTAssertFalse(ceiling.stage7Authorized)

        let sourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Sources/PrimeCore")
            .appendingPathComponent(
                "PrimeNativeDecoderBSpecificNative300MResourceWitnessExecutionObservation.swift"
            )
        let sourceText = try String(contentsOf: sourceURL, encoding: .utf8)
        XCTAssertEqual(
            sourceText.components(separatedBy: "import Foundation").count - 1,
            1
        )
        for forbidden in [
            "import Metal",
            "import MLX",
            "Process(",
            "URLSession",
            "FileHandle(",
        ] {
            XCTAssertFalse(sourceText.contains(forbidden), forbidden)
        }

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
        XCTAssertGreaterThan(observationValuePaths.count, 175)
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
                        object["unknown_b_observation_\(index)"] = true
                        return object
                    }
                ),
                label: "unknown observation field \(pathLabel(path))"
            )
        }

        var reorderedSourcesObservation = observationObject
        var reorderedSources =
            reorderedSourcesObservation["observedSourceBindings"] as! [Any]
        reorderedSources.swapAt(0, 1)
        reorderedSourcesObservation["observedSourceBindings"] =
            reorderedSources
        try assertObservationRejects(
            reorderedSourcesObservation,
            label: "same-cardinality source-identity reorder"
        )

        var reorderedParentsObservation = observationObject
        var reorderedRepository =
            reorderedParentsObservation["repositoryIdentity"]
                as! [String: Any]
        var reorderedParents =
            reorderedRepository["orderedParentRevisions"] as! [Any]
        reorderedParents.swapAt(0, 1)
        reorderedRepository["orderedParentRevisions"] = reorderedParents
        reorderedParentsObservation["repositoryIdentity"] =
            reorderedRepository
        try assertObservationRejects(
            reorderedParentsObservation,
            label: "same-cardinality merge-parent reorder"
        )

        let receiptValuePaths = allValuePaths(in: receiptObject)
        let receiptDictionaryPaths = allDictionaryPaths(in: receiptObject)
        XCTAssertEqual(receiptValuePaths.count, 386)
        XCTAssertGreaterThan(receiptDictionaryPaths.count, 20)
        for path in receiptValuePaths {
            try assertReceiptSubstitutionRejects(
                replacingValue(
                    in: receiptObject,
                    at: path,
                    with: mutateJSONValue
                ),
                in: observationObject,
                label: "mutated receipt \(pathLabel(path))"
            )
            try assertReceiptSubstitutionRejects(
                removingValue(in: receiptObject, at: path),
                in: observationObject,
                label: "removed receipt \(pathLabel(path))"
            )
        }
        for (index, path) in receiptDictionaryPaths.enumerated() {
            try assertReceiptSubstitutionRejects(
                replacingValue(
                    in: receiptObject,
                    at: path,
                    with: { value in
                        var object = value as! [String: Any]
                        object["unknown_b_receipt_\(index)"] = true
                        return object
                    }
                ),
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
                object[key] = removingValue(
                    in: object[key]!,
                    at: remainder
                )
            }
            return object
        case let .index(index):
            var array = value as! [Any]
            if remainder.isEmpty {
                array.remove(at: index)
            } else {
                array[index] = removingValue(
                    in: array[index],
                    at: remainder
                )
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
        var receipt =
            mutatedObservation["receiptIdentity"] as! [String: Any]
        receipt["canonicalJSON"] = mutatedReceiptText
        mutatedObservation["receiptIdentity"] = receipt
        try assertObservationRejects(
            mutatedObservation,
            label: label,
            file: file,
            line: line
        )
    }
}
