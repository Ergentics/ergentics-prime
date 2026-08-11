// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
@testable import PrimeCore
import XCTest

final class PrimeNativeDecoderTrajectoryDesignReviewedMainTimeoutObservationTests:
    XCTestCase
{
    private typealias Observation =
        PrimeNativeDecoderTrajectoryDesignReviewedMainTimeoutObservationV1

    func testFrozenV1CanonicalCodableRecursiveMutationAndAuthorityCeiling()
        throws
    {
        let observation = Observation.frozenV1

        XCTAssertNoThrow(try observation.validate())
        XCTAssertNoThrow(try observation.validateExactV1())
        XCTAssertEqual(observation.schemaVersion, 1)
        XCTAssertEqual(
            observation.classification,
            "timeout_incomplete_not_semantic_failure"
        )
        XCTAssertTrue(observation.timeoutIncompleteNotSemanticFailure)
        XCTAssertTrue(
            observation.partialSuccessDoesNotCompleteReviewedMainJob
        )
        XCTAssertTrue(observation.aRerunWouldBeNewExecutionNotRecovery)

        let repository = observation.repositoryIdentity
        XCTAssertEqual(repository.pullRequestNumber, 81)
        XCTAssertEqual(
            repository.mergeRevision,
            "5eeba9e6483bafd1bbb5c96753491b3dd1609ea0"
        )
        XCTAssertEqual(
            repository.mergeTree,
            "aeae7b7f0c7ab1eb0236a6a2216789c62a082ea1"
        )
        XCTAssertEqual(
            repository.orderedParentRevisions,
            [
                "3ab523afa0a50fbea42dd3e3ead1f010b7e1b800",
                "646e853a7814c96ab61d97ff7540a8838ada1173",
            ]
        )
        XCTAssertTrue(repository.historyPreservingTwoParentMergeObserved)
        XCTAssertTrue(repository.mergeTreeEqualsReviewedHeadTree)

        XCTAssertEqual(observation.runID, 31_509_046_898)
        XCTAssertEqual(observation.runNumber, 59)
        XCTAssertEqual(observation.runAttempt, 1)
        XCTAssertEqual(observation.runEvent, "push")
        XCTAssertEqual(observation.runStatus, "completed")
        XCTAssertEqual(observation.runConclusion, "cancelled")
        XCTAssertEqual(observation.configuredReviewedMainTimeoutMinutes, 45)
        XCTAssertTrue(observation.configuredTimeoutBoundaryReached)
        XCTAssertEqual(observation.exactCancellationErrorLineCount, 1)
        XCTAssertEqual(
            observation.exactCancellationErrorLine,
            "2026-08-11T16:36:34.9237830Z ##[error]The operation was canceled."
        )
        XCTAssertEqual(observation.exactTimeoutAnnotationCount, 1)
        XCTAssertEqual(
            observation.exactTimeoutAnnotation,
            "The job has exceeded the maximum execution time of 45m0s"
        )

        XCTAssertEqual(observation.activeRootJob.jobID, 93_837_901_444)
        XCTAssertEqual(observation.activeRootJob.conclusion, "success")
        XCTAssertEqual(observation.activeRootJob.steps.count, 7)
        XCTAssertTrue(
            observation.activeRootJob.steps.allSatisfy {
                $0.status == "completed" && $0.conclusion == "success"
            }
        )
        XCTAssertEqual(observation.activeRootLatinTestCount, 116)
        XCTAssertEqual(observation.activeRootLatinFailureCount, 0)

        XCTAssertEqual(observation.reviewedMainJob.jobID, 93_838_685_818)
        XCTAssertEqual(observation.reviewedMainJob.conclusion, "cancelled")
        XCTAssertEqual(
            observation.reviewedMainJob.steps.map(\.conclusion),
            [
                "success",
                "success",
                "success",
                "success",
                "success",
                "cancelled",
                "success",
            ]
        )

        XCTAssertEqual(observation.focusedTests.totalTestCount, 38)
        XCTAssertEqual(
            observation.focusedTests.groupTestCounts,
            [32, 1, 1, 2, 2]
        )
        XCTAssertEqual(observation.focusedTests.failureCount, 0)
        XCTAssertEqual(observation.focusedTests.skipCount, 0)
        XCTAssertTrue(observation.focusedTests.allFiveCommandsCompleted)
        XCTAssertFalse(observation.focusedTests.publicCheckpointV2IOExecuted)
        XCTAssertFalse(observation.focusedTests.modelAllocated)

        XCTAssertEqual(
            observation.liveCommandOrder,
            [
                "prime-ci-native-decoder-metal.sh",
                "prime-ci-native-decoder-runtime-closure.sh",
                "prime-ci-native-decoder-tokenizer-compatibility.sh",
            ]
        )
        XCTAssertEqual(observation.metal.deviceName, "Apple Paravirtual device")
        XCTAssertEqual(observation.metal.metallibByteCount, 6_292_764)
        XCTAssertEqual(
            observation.metal.metallibSHA256,
            "01ef9960491bbf2505aee29f1a7cff683c874133c2544138109adfaeb45a68ae"
        )
        XCTAssertEqual(observation.metal.testCount, 44)
        XCTAssertEqual(observation.metal.failureCount, 0)
        XCTAssertEqual(observation.metal.skipCount, 0)
        XCTAssertTrue(observation.metal.suiteCompleted)
        XCTAssertEqual(observation.metal.syntheticCheckpointTestCount, 14)
        XCTAssertFalse(observation.metal.publicCheckpointV2IOExecuted)

        XCTAssertEqual(observation.maintainedRuntime.receiptCount, 1)
        XCTAssertTrue(
            observation.maintainedRuntime.maintainedDependencyClosureEstablished
        )
        XCTAssertTrue(
            observation.maintainedRuntime.boundedMLXInitializationEstablished
        )
        XCTAssertTrue(observation.maintainedRuntime.commandCompleted)
        XCTAssertFalse(observation.maintainedRuntime.checkpointIOObserved)
        XCTAssertFalse(observation.maintainedRuntime.decoderForwardObserved)
        XCTAssertFalse(observation.maintainedRuntime.trainingExecutionObserved)

        XCTAssertEqual(
            observation.tokenizer.phaseOutcome,
            "tokenizer_authority_test_build_cancelled_before_test_execution"
        )
        XCTAssertTrue(observation.tokenizer.probeProductBuildCompleted)
        XCTAssertEqual(
            observation.tokenizer.probeProductBuildReportedDurationMilliseconds,
            527_150
        )
        XCTAssertEqual(
            observation.tokenizer.authorityTestBuildLastProgress,
            "[3/7] Write swift-version"
        )
        XCTAssertFalse(observation.tokenizer.authorityTestBuildCompleted)
        XCTAssertFalse(observation.tokenizer.testExecutionStarted)
        XCTAssertEqual(observation.tokenizer.executedTestCount, 0)
        XCTAssertFalse(observation.tokenizer.probeExecuted)
        XCTAssertFalse(observation.tokenizer.native300MModelAllocated)
        XCTAssertFalse(observation.tokenizer.decoderForwardObserved)
        XCTAssertEqual(observation.tokenizer.receiptCount, 0)
        XCTAssertFalse(observation.tokenizer.successMarkerObserved)
        XCTAssertFalse(observation.tokenizer.semanticFailureObserved)

        let logs = observation.artifactAndLogEvidence
        XCTAssertEqual(logs.rawRunLogZIPByteCount, 1_342_624)
        XCTAssertEqual(
            logs.rawRunLogZIPSHA256,
            "4c486e32f9b8a70034157e67db700a3f78ff556bf4c772ed4b7d5cab050d1232"
        )
        XCTAssertEqual(logs.rawRunLogZIPMemberCount, 18)
        XCTAssertEqual(logs.rawRunLogZIPUncompressedByteCount, 20_896_693)
        XCTAssertTrue(logs.rawRunLogZIPMemberTimestampsAreDOSZero)
        XCTAssertEqual(
            logs.decodedJobLogs.map(\.archiveMemberPath),
            [
                "1_First-party MLX _ active-root quarantine.txt",
                "0_Reviewed main _ focused source contracts.txt",
            ]
        )
        XCTAssertEqual(logs.decodedJobLogs.map(\.byteCount), [227_498, 10_220_130])
        XCTAssertEqual(logs.decodedJobLogs.map(\.lineCount), [1_723, 78_313])
        XCTAssertEqual(logs.exactStepMembers.map(\.byteCount), [329_706, 9_879_300])
        XCTAssertEqual(logs.exactStepMembers.map(\.lineCount), [3_253, 74_917])
        XCTAssertFalse(logs.logsRetainedInRepository)
        XCTAssertEqual(logs.publishedWorkflowArtifactCount, 0)
        XCTAssertTrue(logs.workflowArtifactAPIResponseWasExactEmptyArray)
        XCTAssertFalse(logs.artifactUploadStepPresent)

        XCTAssertEqual(observation.retiredSeed42LauncherCommandCount, 0)
        XCTAssertEqual(observation.retiredSeed43LauncherCommandCount, 0)
        XCTAssertEqual(
            Set(observation.checkpointReceiptMarkerCounts.values),
            [0]
        )
        XCTAssertEqual(observation.checkpointReceiptMarkerCounts.count, 6)
        XCTAssertEqual(
            Set(observation.retiredCheckpointArtifactFilenameCounts.values),
            [0]
        )
        XCTAssertEqual(
            observation.retiredCheckpointArtifactFilenameCounts.count,
            2
        )
        XCTAssertFalse(observation.publicCheckpointV2IOExecuted)
        XCTAssertTrue(observation.onlyPureOrSyntheticCheckpointTestsObserved)

        XCTAssertEqual(observation.allowedSourceImports, ["Foundation"])
        XCTAssertFalse(observation.mlxImportedByObservationSource)
        XCTAssertFalse(observation.modelImportedByObservationSource)
        XCTAssertFalse(observation.processExecutionUsedByObservationSource)
        XCTAssertFalse(observation.filesystemIOUsedByObservationSource)
        XCTAssertFalse(observation.networkIOUsedByObservationSource)
        XCTAssertFalse(observation.observationRuntimeExecutionPerformed)

        let ceiling = observation.authorityCeiling
        for value in [
            ceiling.semanticFailureEstablished,
            ceiling.trajectoryDesignInvalidated,
            ceiling.timeoutRepairImplementedByThisObservation,
            ceiling.workflowMutationAuthorizedByThisObservation,
            ceiling.rerunAuthorizedByThisObservation,
            ceiling.rerunObserved,
            ceiling.exactResumeImplementationEstablished,
            ceiling.exactResumeExecutionObserved,
            ceiling.tinyCPUTrainEvaluateMechanicsObserved,
            ceiling.trajectoryCheckpointWriteObserved,
            ceiling.trajectoryCheckpointLoadObserved,
            ceiling.trajectoryArtifactAvailable,
            ceiling.trajectoryArtifactRetentionEstablished,
            ceiling.trajectoryArtifactProvenanceEstablished,
            ceiling.checkpointAdmissionGranted,
            ceiling.trainingResumeEstablished,
            ceiling.native300MCheckpointWriteObserved,
            ceiling.native300MCheckpointLoadObserved,
            ceiling.native300MTrainingObserved,
            ceiling.native300MTrainingAuthorized,
            ceiling.modelQualityEstablished,
            ceiling.functionalTrainingAuthorized,
            ceiling.longTrainingAuthorized,
            ceiling.candidateAdmissionGranted,
            ceiling.trialAuthorized,
            ceiling.canaryReplacementAuthorized,
            ceiling.productUseAuthorized,
            ceiling.publicationAuthorized,
            ceiling.pullRequestMergeAuthorizedByThisObservation,
        ] {
            XCTAssertFalse(value)
        }
        XCTAssertTrue(observation.status.hasPrefix("ABSTAIN_"))

        let canonical = try observation.canonicalData()
        XCTAssertEqual(
            try JSONDecoder().decode(Observation.self, from: canonical),
            observation
        )
        XCTAssertEqual(try Observation.decodeCanonical(canonical), observation)

        let root = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical) as? [String: Any]
        )
        let drifts = recursiveDrifts(root, path: "$")
        XCTAssertGreaterThan(drifts.count, 250)
        XCTAssertTrue(drifts.contains { $0.kind == "remove" })
        XCTAssertTrue(drifts.contains { $0.kind == "mutate" })
        XCTAssertTrue(drifts.contains { $0.kind == "unknown" })

        for drift in drifts {
            let data = try JSONSerialization.data(
                withJSONObject: drift.value,
                options: [.sortedKeys, .withoutEscapingSlashes]
            )
            if let decoded = try? JSONDecoder().decode(
                Observation.self,
                from: data
            ) {
                if decoded == observation {
                    XCTAssertEqual(
                        drift.kind,
                        "unknown",
                        "only an ignored Codable unknown key may decode to the frozen value at \(drift.path)"
                    )
                } else {
                    XCTAssertThrowsError(
                        try decoded.validateExactV1(),
                        "accepted \(drift.kind) at \(drift.path)"
                    )
                }
            }
            XCTAssertThrowsError(
                try Observation.decodeCanonical(data),
                "canonical decoder accepted \(drift.kind) at \(drift.path)"
            )
        }

        var rootUnknown = root
        rootUnknown["unknown_future_execution_authority"] = true
        let rootUnknownData = try JSONSerialization.data(
            withJSONObject: rootUnknown,
            options: [.sortedKeys, .withoutEscapingSlashes]
        )
        XCTAssertNoThrow(
            try JSONDecoder().decode(Observation.self, from: rootUnknownData),
            "plain Codable decoding ignores unknown keys"
        )
        XCTAssertThrowsError(
            try Observation.decodeCanonical(rootUnknownData),
            "canonical decoding must reject an ignored unknown key"
        )

        let pretty = try JSONSerialization.data(
            withJSONObject: root,
            options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        )
        XCTAssertNoThrow(try JSONDecoder().decode(Observation.self, from: pretty))
        XCTAssertThrowsError(
            try Observation.decodeCanonical(pretty),
            "noncanonical whitespace must not retain authority"
        )
    }

    private typealias Drift = (kind: String, path: String, value: Any)

    private func recursiveDrifts(
        _ value: Any,
        path: String
    ) -> [Drift] {
        if let object = value as? [String: Any] {
            var result: [Drift] = []
            if !object.keys.contains("unknown_future_authority") {
                var unknown = object
                unknown["unknown_future_authority"] = true
                result.append(("unknown", path, unknown))
            }
            for key in object.keys.sorted() {
                var removed = object
                removed.removeValue(forKey: key)
                result.append(("remove", "\(path).\(key)", removed))
                guard let child = object[key] else {
                    continue
                }
                for drift in recursiveDrifts(
                    child,
                    path: "\(path).\(key)"
                ) {
                    var changed = object
                    changed[key] = drift.value
                    result.append((drift.kind, drift.path, changed))
                }
            }
            return result
        }
        if let array = value as? [Any] {
            var result: [Drift] = []
            for index in array.indices {
                var removed = array
                removed.remove(at: index)
                result.append(("remove", "\(path)[\(index)]", removed))
                for drift in recursiveDrifts(
                    array[index],
                    path: "\(path)[\(index)]"
                ) {
                    var changed = array
                    changed[index] = drift.value
                    result.append((drift.kind, drift.path, changed))
                }
            }
            return result
        }
        if let number = value as? NSNumber {
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                return [("mutate", path, !number.boolValue)]
            }
            return [("mutate", path, number.int64Value + 1)]
        }
        if let string = value as? String {
            return [("mutate", path, string + "__mutation")]
        }
        return [("mutate", path, NSNull())]
    }
}
