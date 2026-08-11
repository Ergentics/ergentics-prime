import CoreFoundation
import Foundation
import XCTest
@testable import PrimeCore

final class PrimeSwiftSourceProvenanceTests:
    XCTestCase
{
    func testLiveRepositoryMatchesEmbeddedSourceIdentity()
        throws
    {
        let root = URL(
            fileURLWithPath:
                FileManager.default
                .currentDirectoryPath,
            isDirectory: true
        )
        let expectation =
            PrimeSwiftSourceProvenanceExpectation(
                sourceIdentitySHA256:
                    PrimeEmbeddedBuildProvenance
                    .sourceIdentitySHA256,
                buildConfiguration: "release"
            )
        let snapshot =
            try PrimeSwiftSourceProvenance.capture(
                at: root,
                requiredRelativePaths: [],
                expectation: expectation
            )
        XCTAssertEqual(
            snapshot.sourceIdentitySHA256,
            expectation.sourceIdentitySHA256
        )

        let decoderMetalCorrection =
            PrimeNativeDecoderMetalExecutionObservationCorrectionV1
                .frozenV1
        XCTAssertNoThrow(
            try decoderMetalCorrection.validateExactV1()
        )
        XCTAssertFalse(
            decoderMetalCorrection
                .predecessorStandaloneConsumptionAllowed
        )
        XCTAssertFalse(
            decoderMetalCorrection
                .activeRootQuarantineGateCompleted
        )
        XCTAssertFalse(
            decoderMetalCorrection
                .exactHeadAndCleanGateSequenceCompleted
        )
        XCTAssertTrue(
            decoderMetalCorrection
                .predecessorMetalMechanicsProjectionRetained
        )
        XCTAssertEqual(
            decoderMetalCorrection.retainedTotalTestCount,
            44
        )
        XCTAssertFalse(
            decoderMetalCorrection.gateRepairExecutionObserved
        )

        let decoderGateRepairObservation =
            PrimeNativeDecoderGateRepairExecutionObservationV1
                .frozenV1
        XCTAssertNoThrow(
            try decoderGateRepairObservation.validateExactV1()
        )
        XCTAssertTrue(
            decoderGateRepairObservation
                .activeRootQuarantineGateCompleted
        )
        XCTAssertFalse(
            decoderGateRepairObservation
                .exactHeadAndCleanGateSequenceCompleted
        )
        XCTAssertTrue(
            decoderGateRepairObservation
                .correctedActiveRootAndLatinGateSequenceObserved
        )
        XCTAssertTrue(
            decoderGateRepairObservation
                .gateRepairExecutionObserved
        )
        XCTAssertFalse(
            decoderGateRepairObservation.githubHostedMetalObserved
        )
        XCTAssertFalse(
            decoderGateRepairObservation.functionalTrainingAuthorized
        )

        let observationData =
            try PrimeCanonicalJSON.encode(
                decoderGateRepairObservation
            )
        let observationObject = try XCTUnwrap(
            try JSONSerialization.jsonObject(
                with: observationData
            ) as? [String: Any]
        )
        let booleanKeys = observationObject.compactMap {
            key,
            value -> String? in
            guard let number = value as? NSNumber,
                  CFGetTypeID(number) == CFBooleanGetTypeID()
            else {
                return nil
            }
            return key
        }
        XCTAssertEqual(booleanKeys.count, 53)
        for key in booleanKeys {
            var mutation = observationObject
            let value = try XCTUnwrap(
                mutation[key] as? NSNumber
            )
            mutation[key] = !value.boolValue
            let mutated = try JSONDecoder().decode(
                PrimeNativeDecoderGateRepairExecutionObservationV1
                    .self,
                from: JSONSerialization.data(
                    withJSONObject: mutation,
                    options: [
                        .sortedKeys,
                        .withoutEscapingSlashes,
                    ]
                )
            )
            XCTAssertThrowsError(
                try mutated.validateExactV1(),
                "boolean mutation must fail closed: \(key)"
            )
        }
        for (key, replacement) in [
            (
                "observedRevision",
                "0000000000000000000000000000000000000000" as Any
            ),
            (
                "observedTree",
                "0000000000000000000000000000000000000000" as Any
            ),
            (
                "observedEmbeddedSourceIdentitySHA256",
                String(repeating: "0", count: 64) as Any
            ),
            (
                "predecessorCorrectionSourceSHA256",
                String(repeating: "0", count: 64) as Any
            ),
            (
                "observedWorkflowSHA256",
                String(repeating: "0", count: 64) as Any
            ),
            (
                "observedGateSHA256",
                String(repeating: "0", count: 64) as Any
            ),
            (
                "observedLatinGateSHA256",
                String(repeating: "0", count: 64) as Any
            ),
            (
                "automaticRunID",
                31_359_522_951 as Any
            ),
            (
                "automaticJobID",
                93_365_459_115 as Any
            ),
            (
                "requiredSuccessfulStepNames",
                ["mutated"] as Any
            ),
            (
                "status",
                "PASS" as Any
            ),
            (
                "orderedNextActions",
                ["train_now"] as Any
            ),
        ] {
            var mutation = observationObject
            XCTAssertNotNil(mutation[key])
            mutation[key] = replacement
            let mutated = try JSONDecoder().decode(
                PrimeNativeDecoderGateRepairExecutionObservationV1
                    .self,
                from: JSONSerialization.data(
                    withJSONObject: mutation,
                    options: [
                        .sortedKeys,
                        .withoutEscapingSlashes,
                    ]
                )
            )
            XCTAssertThrowsError(
                try mutated.validateExactV1(),
                "bound mutation must fail closed: \(key)"
            )
        }

        let reviewedMainMetalObservation =
            PrimeNativeDecoderReviewedMainMetalExecutionObservationV1
                .frozenV1
        XCTAssertNoThrow(
            try reviewedMainMetalObservation.validateExactV1()
        )
        XCTAssertTrue(
            reviewedMainMetalObservation
                .historyPreservingTwoParentMergeObserved
        )
        XCTAssertTrue(
            reviewedMainMetalObservation
                .exactHeadAndCleanGateSequenceCompleted
        )
        XCTAssertTrue(
            reviewedMainMetalObservation.githubHostedMetalObserved
        )
        XCTAssertTrue(
            reviewedMainMetalObservation
                .freshMetallibBuildProvenanceObserved
        )
        XCTAssertEqual(
            reviewedMainMetalObservation.executedTotalTestCount,
            44
        )
        XCTAssertEqual(reviewedMainMetalObservation.failureCount, 0)
        XCTAssertEqual(reviewedMainMetalObservation.skipCount, 0)
        XCTAssertFalse(
            reviewedMainMetalObservation
                .runtimeLoadedExactStagedMetallibIdentityIndependentlyObserved
        )
        XCTAssertFalse(
            reviewedMainMetalObservation
                .repairedCheckpointCompatibilityIdentityEstablished
        )
        XCTAssertFalse(
            reviewedMainMetalObservation
                .admittedRuntimeComputePolicyEstablished
        )
        XCTAssertFalse(
            reviewedMainMetalObservation.functionalTrainingAuthorized
        )

        let reviewedMainObservationData =
            try PrimeCanonicalJSON.encode(
                reviewedMainMetalObservation
            )
        let reviewedMainObservationObject = try XCTUnwrap(
            try JSONSerialization.jsonObject(
                with: reviewedMainObservationData
            ) as? [String: Any]
        )
        let reviewedMainBooleanKeys =
            reviewedMainObservationObject.compactMap {
                key,
                value -> String? in
                guard let number = value as? NSNumber,
                      CFGetTypeID(number) == CFBooleanGetTypeID()
                else {
                    return nil
                }
                return key
            }
        XCTAssertEqual(reviewedMainBooleanKeys.count, 83)
        for key in reviewedMainBooleanKeys {
            var mutation = reviewedMainObservationObject
            let value = try XCTUnwrap(
                mutation[key] as? NSNumber
            )
            mutation[key] = !value.boolValue
            let mutated = try JSONDecoder().decode(
                PrimeNativeDecoderReviewedMainMetalExecutionObservationV1
                    .self,
                from: JSONSerialization.data(
                    withJSONObject: mutation,
                    options: [
                        .sortedKeys,
                        .withoutEscapingSlashes,
                    ]
                )
            )
            XCTAssertThrowsError(
                try mutated.validateExactV1(),
                "hosted observation boolean mutation must fail closed: \(key)"
            )
        }

        for (key, replacement) in [
            (
                "observedRevision",
                "0000000000000000000000000000000000000000" as Any
            ),
            (
                "observedOrderedParentRevisions",
                ["0000000000000000000000000000000000000000"] as Any
            ),
            (
                "observedTree",
                "0000000000000000000000000000000000000000" as Any
            ),
            (
                "observedEmbeddedSourceIdentitySHA256",
                String(repeating: "0", count: 64) as Any
            ),
            (
                "predecessorSourceSHA256",
                String(repeating: "0", count: 64) as Any
            ),
            (
                "observedWorkflowSHA256",
                String(repeating: "0", count: 64) as Any
            ),
            (
                "observedActiveGateSHA256",
                String(repeating: "0", count: 64) as Any
            ),
            (
                "observedLatinGateSHA256",
                String(repeating: "0", count: 64) as Any
            ),
            (
                "observedMetalLauncherSHA256",
                String(repeating: "0", count: 64) as Any
            ),
            (
                "observedDecoderSourceSHA256",
                String(repeating: "0", count: 64) as Any
            ),
            (
                "observedCheckpointSourceSHA256",
                String(repeating: "0", count: 64) as Any
            ),
            (
                "observedAuthorityTestSourceSHA256",
                String(repeating: "0", count: 64) as Any
            ),
            (
                "observedCheckpointTestSourceSHA256",
                String(repeating: "0", count: 64) as Any
            ),
            (
                "observedDecoderTestSourceSHA256",
                String(repeating: "0", count: 64) as Any
            ),
            ("runID", 31_361_320_314 as Any),
            ("activeRootJobID", 93_370_610_367 as Any),
            ("reviewedMainJobID", 93_370_967_152 as Any),
            (
                "activeJobDownloadedLogSHA256",
                String(repeating: "0", count: 64) as Any
            ),
            (
                "reviewedMainJobDownloadedLogSHA256",
                String(repeating: "0", count: 64) as Any
            ),
            ("activeJobDownloadedLogByteCount", 1 as Any),
            ("reviewedMainJobDownloadedLogByteCount", 1 as Any),
            ("downloadedJobLogBindingKind", "mutated" as Any),
            ("publishedWorkflowArtifactCount", 1 as Any),
            ("runnerImage", "mutated" as Any),
            ("metalDeviceName", "mutated" as Any),
            (
                "exactMLXRevision",
                "0000000000000000000000000000000000000000" as Any
            ),
            (
                "exactMLXCoreRevision",
                "0000000000000000000000000000000000000000" as Any
            ),
            (
                "exactMLXCRevision",
                "0000000000000000000000000000000000000000" as Any
            ),
            (
                "generatedMetallibSHA256",
                String(repeating: "0", count: 64) as Any
            ),
            ("generatedMetallibByteCount", 1 as Any),
            ("focusedSourceContractTestCount", 30 as Any),
            ("executedAuthorityTestCount", 10 as Any),
            ("executedCheckpointTestCount", 13 as Any),
            ("executedDecoderTestCount", 18 as Any),
            ("executedTotalTestCount", 43 as Any),
            ("requiredLiveMetalTestNames", ["mutated"] as Any),
            ("status", "PASS" as Any),
            ("orderedNextActions", ["train_now"] as Any),
        ] {
            var mutation = reviewedMainObservationObject
            XCTAssertNotNil(mutation[key])
            mutation[key] = replacement
            let mutated = try JSONDecoder().decode(
                PrimeNativeDecoderReviewedMainMetalExecutionObservationV1
                    .self,
                from: JSONSerialization.data(
                    withJSONObject: mutation,
                    options: [
                        .sortedKeys,
                        .withoutEscapingSlashes,
                    ]
                )
            )
            XCTAssertThrowsError(
                try mutated.validateExactV1(),
                "hosted observation binding mutation must fail closed: \(key)"
            )
        }

        var policyMutation = reviewedMainObservationObject
        var policy = try XCTUnwrap(
            policyMutation["ciMechanicsPolicy"] as? [String: Any]
        )
        policy["requiredEnvironmentValue"] = "1"
        policyMutation["ciMechanicsPolicy"] = policy
        let mutatedPolicyObservation = try JSONDecoder().decode(
            PrimeNativeDecoderReviewedMainMetalExecutionObservationV1.self,
            from: JSONSerialization.data(
                withJSONObject: policyMutation,
                options: [
                    .sortedKeys,
                    .withoutEscapingSlashes,
                ]
            )
        )
        XCTAssertThrowsError(
            try mutatedPolicyObservation.validateExactV1()
        )

        let maintainedRuntimeObservation =
            PrimeNativeDecoderMaintainedRuntimeExecutionObservationV1
                .frozenV1
        XCTAssertNoThrow(
            try maintainedRuntimeObservation.validateExactV1()
        )
        XCTAssertTrue(
            maintainedRuntimeObservation
                .exactReviewedMainRuntimeClosureObserved
        )
        XCTAssertTrue(
            maintainedRuntimeObservation
                .runtimeDependencyClosureEstablished
        )
        XCTAssertTrue(
            maintainedRuntimeObservation
                .sourcePinnedExclusiveCandidateInferenceEstablished
        )
        XCTAssertTrue(
            maintainedRuntimeObservation
                .runtimeMetalDeviceIdentityEstablished
        )
        XCTAssertTrue(
            maintainedRuntimeObservation
                .boundedMLXRuntimeInitializationEstablished
        )
        XCTAssertFalse(
            maintainedRuntimeObservation
                .runtimeLoadedExactMetallibIdentityEstablished
        )
        XCTAssertFalse(
            maintainedRuntimeObservation
                .runtimeLoadedMetallibPathIndependentlyObserved
        )
        XCTAssertFalse(
            maintainedRuntimeObservation
                .callerExpectationIsArtifactAdmission
        )
        XCTAssertFalse(
            maintainedRuntimeObservation
                .metallibArtifactProvenanceEstablished
        )
        XCTAssertFalse(
            maintainedRuntimeObservation.physicalGPUIdentityEstablished
        )
        XCTAssertFalse(
            maintainedRuntimeObservation.tf32StaticValueDirectlyObserved
        )
        XCTAssertFalse(
            maintainedRuntimeObservation.naxTF32ConsumerPathObserved
        )
        XCTAssertFalse(
            maintainedRuntimeObservation.decoderModelAllocationObserved
        )
        XCTAssertFalse(
            maintainedRuntimeObservation.decoderExecutionObserved
        )
        XCTAssertFalse(
            maintainedRuntimeObservation.checkpointIOObserved
        )
        XCTAssertFalse(
            maintainedRuntimeObservation.v2ManifestDefined
        )
        XCTAssertFalse(
            maintainedRuntimeObservation.v2CodecDefined
        )
        XCTAssertFalse(
            maintainedRuntimeObservation
                .tokenizerFunctionalCompatibilityEstablished
        )
        XCTAssertFalse(
            maintainedRuntimeObservation
                .modelFunctionalCompatibilityEstablished
        )
        XCTAssertFalse(
            maintainedRuntimeObservation.trainingResumeEstablished
        )
        XCTAssertFalse(
            maintainedRuntimeObservation.trainEvaluateSurfaceEstablished
        )
        XCTAssertFalse(
            maintainedRuntimeObservation.trainingExecutionObserved
        )
        XCTAssertFalse(
            maintainedRuntimeObservation.candidateAdmissionGranted
        )
        XCTAssertFalse(
            maintainedRuntimeObservation.trialAuthorized
        )
        XCTAssertFalse(
            maintainedRuntimeObservation.canaryReplacementAuthorized
        )
        XCTAssertFalse(
            maintainedRuntimeObservation.quantizationAuthorized
        )
        XCTAssertFalse(
            maintainedRuntimeObservation.productUseAuthorized
        )

        let maintainedRuntimeObservationData =
            try PrimeCanonicalJSON.encode(
                maintainedRuntimeObservation
            )
        let maintainedRuntimeObservationObject = try XCTUnwrap(
            try JSONSerialization.jsonObject(
                with: maintainedRuntimeObservationData
            ) as? [String: Any]
        )

        func assertMaintainedRuntimeObservationRejects(
            _ mutation: [String: Any],
            _ message: String
        ) throws {
            let mutated = try JSONDecoder().decode(
                PrimeNativeDecoderMaintainedRuntimeExecutionObservationV1
                    .self,
                from: JSONSerialization.data(
                    withJSONObject: mutation,
                    options: [
                        .sortedKeys,
                        .withoutEscapingSlashes,
                    ]
                )
            )
            XCTAssertThrowsError(
                try mutated.validateExactV1(),
                message
            )
        }

        let maintainedRuntimeBooleanKeys =
            maintainedRuntimeObservationObject.compactMap {
                key,
                value -> String? in
                guard let number = value as? NSNumber,
                      CFGetTypeID(number) == CFBooleanGetTypeID()
                else {
                    return nil
                }
                return key
            }
        XCTAssertEqual(maintainedRuntimeBooleanKeys.count, 100)
        for key in maintainedRuntimeBooleanKeys {
            var mutation = maintainedRuntimeObservationObject
            let value = try XCTUnwrap(
                mutation[key] as? NSNumber
            )
            mutation[key] = !value.boolValue
            try assertMaintainedRuntimeObservationRejects(
                mutation,
                "runtime observation boolean mutation must fail closed: \(key)"
            )
        }

        let sourceBindingKeys = [
            "predecessorSource",
            "observedWorkflowSource",
            "observedActiveGateSource",
            "observedFrozenMetalLauncherSource",
            "observedRuntimeClosureLauncherSource",
            "observedRootPackageManifestSource",
            "observedRootPackageResolvedSource",
            "observedRuntimeSource",
            "observedRuntimeValidationManifestSource",
            "observedRuntimeValidationResolvedSource",
            "observedRuntimeValidationProbeSource",
            "observedRuntimeValidationTestSource",
        ]
        for sourceKey in sourceBindingKeys {
            let source = try XCTUnwrap(
                maintainedRuntimeObservationObject[sourceKey]
                    as? [String: Any]
            )
            let sourceMode = try XCTUnwrap(
                source["gitMode"] as? String
            )
            let mutatedSourceMode =
                sourceMode == "100755" ? "100644" : "100755"
            for (field, replacement) in [
                ("path", "mutated" as Any),
                ("gitMode", mutatedSourceMode as Any),
                (
                    "gitBlob",
                    String(repeating: "0", count: 40) as Any
                ),
                ("byteCount", 1 as Any),
                (
                    "sha256",
                    String(repeating: "0", count: 64) as Any
                ),
            ] {
                var mutation = maintainedRuntimeObservationObject
                var mutatedSource = source
                XCTAssertNotNil(mutatedSource[field])
                mutatedSource[field] = replacement
                mutation[sourceKey] = mutatedSource
                try assertMaintainedRuntimeObservationRejects(
                    mutation,
                    "runtime observation source mutation must fail closed: \(sourceKey).\(field)"
                )
            }
        }

        let maintainedPolicy = try XCTUnwrap(
            maintainedRuntimeObservationObject[
                "maintainedEnvironmentPolicy"
            ] as? [String: Any]
        )
        let maintainedPolicyBooleanKeys =
            maintainedPolicy.compactMap {
                key,
                value -> String? in
                guard let number = value as? NSNumber,
                      CFGetTypeID(number) == CFBooleanGetTypeID()
                else {
                    return nil
                }
                return key
            }
        XCTAssertEqual(maintainedPolicyBooleanKeys.count, 1)
        for key in maintainedPolicyBooleanKeys {
            var mutation = maintainedRuntimeObservationObject
            var mutatedPolicy = maintainedPolicy
            let value = try XCTUnwrap(
                mutatedPolicy[key] as? NSNumber
            )
            mutatedPolicy[key] = !value.boolValue
            mutation["maintainedEnvironmentPolicy"] = mutatedPolicy
            try assertMaintainedRuntimeObservationRejects(
                mutation,
                "runtime observation policy boolean mutation must fail closed: \(key)"
            )
        }
        for (field, replacement) in [
            ("schemaVersion", 2 as Any),
            ("policyID", "mutated" as Any),
            ("policyVersion", 2 as Any),
            ("scope", "mutated" as Any),
            ("predecessorPolicyID", "mutated" as Any),
            ("predecessorPolicyVersion", 2 as Any),
            (
                "exactMLXRevision",
                String(repeating: "0", count: 40) as Any
            ),
            ("requiredEnvironmentKey", "MLX_MUTATED" as Any),
            ("requiredEnvironmentValue", "1" as Any),
            ("exclusiveEnvironmentKeyPrefix", "MUTATED_" as Any),
            ("forbiddenEnvironmentKeyPrefixes", ["MUTATED_"] as Any),
            ("numericMode", "mutated" as Any),
            ("comparisonPolicy", "mutated" as Any),
            ("authorityCeiling", "mutated" as Any),
        ] {
            var mutation = maintainedRuntimeObservationObject
            var mutatedPolicy = maintainedPolicy
            XCTAssertNotNil(mutatedPolicy[field])
            mutatedPolicy[field] = replacement
            mutation["maintainedEnvironmentPolicy"] = mutatedPolicy
            try assertMaintainedRuntimeObservationRejects(
                mutation,
                "runtime observation policy mutation must fail closed: \(field)"
            )
        }

        for (key, replacement) in [
            ("schemaVersion", 2 as Any),
            ("observationID", "mutated" as Any),
            ("observationKind", "mutated" as Any),
            ("predecessorAuthorityID", "mutated" as Any),
            ("authoritativeRepository", "mutated" as Any),
            ("observedPullRequestNumber", 73 as Any),
            ("observedRef", "refs/heads/mutated" as Any),
            (
                "observedRevision",
                String(repeating: "0", count: 40) as Any
            ),
            (
                "observedOrderedParentRevisions",
                [String(repeating: "0", count: 40)] as Any
            ),
            (
                "observedTree",
                String(repeating: "0", count: 40) as Any
            ),
            (
                "reviewedPullRequestHeadRevision",
                String(repeating: "0", count: 40) as Any
            ),
            (
                "reviewedPullRequestHeadTree",
                String(repeating: "0", count: 40) as Any
            ),
            (
                "observedEmbeddedSourceIdentitySHA256",
                String(repeating: "0", count: 64) as Any
            ),
            ("workflowID", 1 as Any),
            ("workflowName", "mutated" as Any),
            ("runID", 1 as Any),
            ("runNumber", 1 as Any),
            ("runAttempt", 2 as Any),
            ("runEvent", "workflow_dispatch" as Any),
            ("runURL", "https://example.invalid" as Any),
            ("runActor", "mutated" as Any),
            ("runTriggeringActor", "mutated" as Any),
            ("runCreatedAt", "1970-01-01T00:00:00Z" as Any),
            ("runStartedAt", "1970-01-01T00:00:00Z" as Any),
            ("runUpdatedAt", "1970-01-01T00:00:00Z" as Any),
            ("runStatus", "queued" as Any),
            ("runConclusion", "failure" as Any),
            ("publishedWorkflowArtifactCount", 1 as Any),
            ("activeRootJobID", 1 as Any),
            ("activeRootJobName", "mutated" as Any),
            ("activeRootJobURL", "https://example.invalid" as Any),
            (
                "activeRootJobStartedAt",
                "1970-01-01T00:00:00Z" as Any
            ),
            (
                "activeRootJobCompletedAt",
                "1970-01-01T00:00:00Z" as Any
            ),
            ("activeRootJobStatus", "queued" as Any),
            ("activeRootJobConclusion", "failure" as Any),
            ("activeRootRunnerLabel", "mutated" as Any),
            ("activeRootRunnerName", "mutated" as Any),
            ("activeRootRunnerGroupName", "mutated" as Any),
            ("activeRootRequiredSuccessfulStepNames", ["mutated"] as Any),
            ("reviewedMainJobID", 1 as Any),
            ("reviewedMainJobName", "mutated" as Any),
            ("reviewedMainJobURL", "https://example.invalid" as Any),
            (
                "reviewedMainJobStartedAt",
                "1970-01-01T00:00:00Z" as Any
            ),
            (
                "reviewedMainJobCompletedAt",
                "1970-01-01T00:00:00Z" as Any
            ),
            ("reviewedMainJobStatus", "queued" as Any),
            ("reviewedMainJobConclusion", "failure" as Any),
            ("reviewedMainRunnerLabel", "mutated" as Any),
            ("reviewedMainRunnerName", "mutated" as Any),
            ("reviewedMainRunnerGroupName", "mutated" as Any),
            (
                "reviewedMainRequiredSuccessfulStepNames",
                ["mutated"] as Any
            ),
            ("activeJobTransportDecodedUTF8LogByteCount", 1 as Any),
            (
                "activeJobTransportDecodedUTF8LogSHA256",
                String(repeating: "0", count: 64) as Any
            ),
            (
                "reviewedMainJobTransportDecodedUTF8LogByteCount",
                1 as Any
            ),
            (
                "reviewedMainJobTransportDecodedUTF8LogSHA256",
                String(repeating: "0", count: 64) as Any
            ),
            ("decodedJobLogBindingKind", "mutated" as Any),
            ("localGHCLIRunLogZIPByteCount", 1 as Any),
            (
                "localGHCLIRunLogZIPSHA256",
                String(repeating: "0", count: 64) as Any
            ),
            ("runnerVersion", "mutated" as Any),
            ("runnerProvisionerVersion", "mutated" as Any),
            (
                "runnerProvisionerCommit",
                String(repeating: "0", count: 40) as Any
            ),
            ("activeRunnerImage", "mutated" as Any),
            ("activeRunnerImageVersion", "mutated" as Any),
            ("activeOperatingSystemVersion", "mutated" as Any),
            ("activeOperatingSystemBuild", "mutated" as Any),
            ("reviewedRunnerImage", "mutated" as Any),
            ("reviewedRunnerImageVersion", "mutated" as Any),
            ("reviewedOperatingSystemVersion", "mutated" as Any),
            ("reviewedOperatingSystemBuild", "mutated" as Any),
            ("reviewedArchitecture", "x86_64" as Any),
            ("xcodeVersion", "mutated" as Any),
            ("xcodeBuildVersion", "mutated" as Any),
            ("swiftVersion", "mutated" as Any),
            ("swiftTarget", "mutated" as Any),
            ("macOSSDKVersion", "mutated" as Any),
            ("swiftDriverVersion", "mutated" as Any),
            ("exactMLXRepository", "mutated" as Any),
            (
                "exactMLXRevision",
                String(repeating: "0", count: 40) as Any
            ),
            (
                "exactMLXCoreRevision",
                String(repeating: "0", count: 40) as Any
            ),
            (
                "exactMLXCRevision",
                String(repeating: "0", count: 40) as Any
            ),
            (
                "exactSwiftNumericsRevision",
                String(repeating: "0", count: 40) as Any
            ),
            ("generatedMetallibArtifactKind", "mutated" as Any),
            ("generatedMetallibByteCount", 1 as Any),
            (
                "generatedMetallibSHA256",
                String(repeating: "0", count: 64) as Any
            ),
            ("metallibArtifactRelativePath", "mutated" as Any),
            ("metallibDeviceID", 1 as Any),
            ("metallibInode", 1 as Any),
            ("uniqueCandidateCountBeforeExecution", 1 as Any),
            ("uniqueCandidateCountAfterExecution", 1 as Any),
            ("existingCandidateCountBeforeExecution", 0 as Any),
            ("existingCandidateCountAfterExecution", 0 as Any),
            ("sourcePinnedLoaderIdentityClaimKind", "mutated" as Any),
            ("metalDeviceEnumerationAPI", "mutated" as Any),
            ("metalDefaultDeviceAPI", "mutated" as Any),
            ("metalDeviceName", "mutated" as Any),
            ("metalDeviceArchitectureName", "mutated" as Any),
            ("metalDeviceRegistryID", 1 as Any),
            ("enumeratedMetalDeviceCount", 2 as Any),
            ("mlxDeviceIdentityClaimKind", "mutated" as Any),
            ("focusedSourceContractTestCount", 30 as Any),
            ("focusedSourceContractFailureCount", 1 as Any),
            ("checkpointCompatibilityTestCount", 0 as Any),
            ("checkpointCompatibilityFailureCount", 1 as Any),
            ("frozenAuthorityTestCount", 10 as Any),
            ("frozenCheckpointTestCount", 13 as Any),
            ("frozenDecoderTestCount", 18 as Any),
            ("frozenTotalTestCount", 43 as Any),
            ("frozenFailureCount", 1 as Any),
            ("frozenSkipCount", 1 as Any),
            ("runtimeAuthorityTestName", "mutated" as Any),
            ("runtimeAuthorityTestCount", 0 as Any),
            ("runtimeAuthorityFailureCount", 1 as Any),
            ("runtimeAuthoritySkipCount", 1 as Any),
            ("receiptMarker", "mutated" as Any),
            ("receiptJSONPayloadByteCount", 1 as Any),
            (
                "receiptJSONPayloadSHA256",
                String(repeating: "0", count: 64) as Any
            ),
            ("receiptCount", 0 as Any),
            ("receiptSchemaVersion", 2 as Any),
            ("receiptEvidenceID", "mutated" as Any),
            ("receiptAuthorityID", "mutated" as Any),
            ("receiptPlanID", "mutated" as Any),
            ("receiptExecutableName", "mutated" as Any),
            ("receiptExecutableByteCount", 1 as Any),
            (
                "receiptExecutableSHA256",
                String(repeating: "0", count: 64) as Any
            ),
            ("receiptExecutableDeviceID", 1 as Any),
            ("receiptExecutableInode", 1 as Any),
            ("receiptExecutableCaptureMethod", "mutated" as Any),
            (
                "receiptReleaseInstrumentationInspectedImageScope",
                "mutated" as Any
            ),
            (
                "receiptCompatibilityIdentityCanonicalByteCount",
                1 as Any
            ),
            (
                "receiptCompatibilityIdentitySHA256",
                String(repeating: "0", count: 64) as Any
            ),
            ("receiptNativeConfigurationParameterCount", 1 as Any),
            ("mlxInitializationDeviceType", "cpu" as Any),
            ("mlxInitializationDeviceIndex", 1 as Any),
            ("mlxInitializationOperation", "mutated" as Any),
            ("mlxInitializationDType", "float16" as Any),
            ("mlxInitializationShape", [1] as Any),
            ("mlxInitializationLeftFloat32BitPatterns", [0] as Any),
            ("mlxInitializationRightFloat32BitPatterns", [0] as Any),
            ("mlxInitializationOutputFloat32BitPatterns", [0] as Any),
            ("mlxInitializationEvaluationAPI", "mutated" as Any),
            ("mlxInitializationReadbackAPI", "mutated" as Any),
            ("status", "PASS" as Any),
            ("orderedNextActions", ["train_now"] as Any),
        ] {
            var mutation = maintainedRuntimeObservationObject
            XCTAssertNotNil(mutation[key])
            mutation[key] = replacement
            try assertMaintainedRuntimeObservationRejects(
                mutation,
                "runtime observation binding mutation must fail closed: \(key)"
            )
        }
    }

    func testCapturePreservesCanonicalSnapshotContract()
        throws
    {
        let fixture = try makeFixture()
        defer {
            try? FileManager.default.removeItem(
                at: fixture.root
            )
        }
        let snapshot =
            try PrimeSwiftSourceProvenance.capture(
                at: fixture.root,
                requiredRelativePaths: [
                    "Sources/Fixture.swift",
                ],
                expectation:
                    fixture.expectation
            )

        XCTAssertEqual(snapshot.schemaVersion, 1)
        XCTAssertEqual(
            snapshot.artifactKind,
            "ergentics_prime_swift_source_snapshot"
        )
        XCTAssertEqual(
            snapshot.sourceIdentitySHA256,
            fixture.expectation
                .sourceIdentitySHA256
        )
        XCTAssertEqual(
            snapshot.embeddedSourceIdentitySHA256,
            fixture.expectation
                .sourceIdentitySHA256
        )
        XCTAssertEqual(
            snapshot.buildConfiguration,
            "release"
        )
        XCTAssertEqual(
            snapshot.files.map(\.relativePath),
            snapshot.files.map(\.relativePath).sorted()
        )
        XCTAssertTrue(
            snapshot.files.contains(where: {
                $0.relativePath == ".gitignore"
            })
        )
        XCTAssertTrue(
            snapshot.files.contains(where: {
                $0.relativePath
                    == ".swiftpm/configuration/mirrors.json"
            })
        )
        XCTAssertTrue(
            snapshot.files.contains(where: {
                $0.relativePath
                    == "Tests/PrimeTypedOptimizerRestoreMechanicsValidation/.swiftpm/configuration/mirrors.json"
            })
        )
        XCTAssertTrue(
            snapshot.files.contains(where: {
                $0.relativePath
                    == "Tests/PrimeNativeNeuralGateMLXValidation/.swiftpm/configuration/mirrors.json"
            })
        )
        XCTAssertTrue(
            snapshot.files.contains(where: {
                $0.relativePath
                    == "Tests/PrimeValidationWorkflow/.swiftpm/configuration/mirrors.json"
            })
        )
        XCTAssertNoThrow(
            try PrimeSwiftSourceProvenance.validate(
                snapshot,
                requiredRelativePaths: [
                    "Sources/Fixture.swift",
                ],
                expectation:
                    fixture.expectation
            )
        )

        let encoded =
            try PrimeCanonicalJSON.encode(snapshot)
        let object = try XCTUnwrap(
            try JSONSerialization.jsonObject(
                with: encoded
            ) as? [String: Any]
        )
        XCTAssertEqual(
            Set(object.keys),
            [
                "schema_version",
                "artifact_kind",
                "source_identity_sha256",
                "embedded_source_identity_sha256",
                "build_configuration",
                "files",
            ]
        )
    }

    func testArbitrarySelfConsistentReleaseSnapshotCannotCreateHistoricalAuthority()
        throws
    {
        let fixture = try makeFixture()
        defer {
            try? FileManager.default.removeItem(
                at: fixture.root
            )
        }
        let snapshot =
            try PrimeSwiftSourceProvenance.capture(
                at: fixture.root,
                requiredRelativePaths: [
                    "Sources/Fixture.swift",
                ],
                expectation:
                    fixture.expectation
            )

        for pin in [
            PrimePinnedHistoricalReleaseSource
                .nativeGenerationContractProjection20260730,
            .nativeFullCorpusReplay20260730,
            .nativeNeuralGateContractProjection20260730,
        ] {
            XCTAssertThrowsError(
                try PrimeSwiftSourceProvenance
                    .validatePinnedReleaseEvidence(
                        snapshot,
                        requiredRelativePaths: [
                            "Sources/Fixture.swift",
                        ],
                        pin: pin
                    )
            ) { error in
                guard case
                    .sourceIdentityMismatch =
                        error as?
                        PrimeSwiftSourceProvenanceError
                else {
                    return XCTFail(
                        "unexpected error: \(error)"
                    )
                }
            }
        }
    }

    func testNonEmbeddedMutationChangesIdentityAndFailsClosed()
        throws
    {
        let fixture = try makeFixture()
        defer {
            try? FileManager.default.removeItem(
                at: fixture.root
            )
        }
        let snapshot =
            try PrimeSwiftSourceProvenance.capture(
                at: fixture.root,
                requiredRelativePaths: [],
                expectation:
                    fixture.expectation
            )
        let files = snapshot.files.map { file in
            guard file.relativePath
                == "Sources/Fixture.swift"
            else {
                return file
            }
            let contents =
                file.contents + Data([0x0a])
            return PrimeSwiftSourceFileSnapshot(
                relativePath: file.relativePath,
                sha256:
                    PrimeSHA256.hexDigest(of: contents),
                byteCount: UInt64(contents.count),
                contents: contents
            )
        }
        let mutation = PrimeSwiftSourceSnapshot(
            sourceIdentitySHA256:
                snapshot.sourceIdentitySHA256,
            embeddedSourceIdentitySHA256:
                snapshot
                .embeddedSourceIdentitySHA256,
            buildConfiguration:
                snapshot.buildConfiguration,
            files: files
        )

        XCTAssertThrowsError(
            try PrimeSwiftSourceProvenance.validate(
                mutation,
                requiredRelativePaths: [],
                expectation:
                    fixture.expectation
            )
        ) { error in
            guard case
                .sourceIdentityMismatch =
                    error as?
                    PrimeSwiftSourceProvenanceError
            else {
                return XCTFail(
                    "unexpected error: \(error)"
                )
            }
        }
    }

    func testEmbeddedMutationIsRejectedDespiteIdentityExclusion()
        throws
    {
        let fixture = try makeFixture()
        defer {
            try? FileManager.default.removeItem(
                at: fixture.root
            )
        }
        let snapshot =
            try PrimeSwiftSourceProvenance.capture(
                at: fixture.root,
                requiredRelativePaths: [],
                expectation:
                    fixture.expectation
            )
        let files = snapshot.files.map { file in
            guard file.relativePath
                == PrimeSwiftSourceProvenance
                .embeddedProvenanceRelativePath
            else {
                return file
            }
            let contents =
                file.contents + Data([0x0a])
            return PrimeSwiftSourceFileSnapshot(
                relativePath: file.relativePath,
                sha256:
                    PrimeSHA256.hexDigest(of: contents),
                byteCount: UInt64(contents.count),
                contents: contents
            )
        }
        let mutation = PrimeSwiftSourceSnapshot(
            sourceIdentitySHA256:
                snapshot.sourceIdentitySHA256,
            embeddedSourceIdentitySHA256:
                snapshot
                .embeddedSourceIdentitySHA256,
            buildConfiguration:
                snapshot.buildConfiguration,
            files: files
        )

        XCTAssertThrowsError(
            try PrimeSwiftSourceProvenance.validate(
                mutation,
                requiredRelativePaths: [],
                expectation:
                    fixture.expectation
            )
        ) { error in
            XCTAssertEqual(
                error as?
                    PrimeSwiftSourceProvenanceError,
                .unsafeSourceFile(
                    PrimeSwiftSourceProvenance
                        .embeddedProvenanceRelativePath
                )
            )
        }
    }

    func testDependencyMirrorMutationFailsSourceIdentity()
        throws
    {
        let fixture = try makeFixture()
        defer {
            try? FileManager.default.removeItem(
                at: fixture.root
            )
        }
        let snapshot =
            try PrimeSwiftSourceProvenance.capture(
                at: fixture.root,
                requiredRelativePaths: [],
                expectation:
                    fixture.expectation
            )
        let files = snapshot.files.map { file in
            guard file.relativePath
                == ".swiftpm/configuration/mirrors.json"
            else {
                return file
            }
            let contents =
                file.contents + Data([0x0a])
            return PrimeSwiftSourceFileSnapshot(
                relativePath: file.relativePath,
                sha256:
                    PrimeSHA256.hexDigest(of: contents),
                byteCount: UInt64(contents.count),
                contents: contents
            )
        }
        let mutation = PrimeSwiftSourceSnapshot(
            sourceIdentitySHA256:
                snapshot.sourceIdentitySHA256,
            embeddedSourceIdentitySHA256:
                snapshot
                .embeddedSourceIdentitySHA256,
            buildConfiguration:
                snapshot.buildConfiguration,
            files: files
        )

        XCTAssertThrowsError(
            try PrimeSwiftSourceProvenance.validate(
                mutation,
                requiredRelativePaths: [],
                expectation:
                    fixture.expectation
            )
        ) { error in
            guard case
                .sourceIdentityMismatch =
                    error as?
                    PrimeSwiftSourceProvenanceError
            else {
                return XCTFail(
                    "unexpected error: \(error)"
                )
            }
        }
    }

    func testMissingDependencyMirrorFailsCapture()
        throws
    {
        let fixture = try makeFixture()
        defer {
            try? FileManager.default.removeItem(
                at: fixture.root
            )
        }
        try FileManager.default.removeItem(
            at: fixture.root.appendingPathComponent(
                ".swiftpm/configuration/mirrors.json"
            )
        )

        XCTAssertThrowsError(
            try PrimeSwiftSourceProvenance.capture(
                at: fixture.root,
                requiredRelativePaths: [],
                expectation:
                    fixture.expectation
            )
        ) { error in
            guard case let .unsafeSourceFile(path) =
                error as?
                    PrimeSwiftSourceProvenanceError
            else {
                return XCTFail(
                    "unexpected error: \(error)"
                )
            }
            XCTAssertTrue(
                path.hasSuffix(
                    ".swiftpm/configuration/mirrors.json"
                )
            )
        }
    }

    func testDebugBuildExpectationIsRejected()
        throws
    {
        let fixture = try makeFixture()
        defer {
            try? FileManager.default.removeItem(
                at: fixture.root
            )
        }
        let debugExpectation =
            PrimeSwiftSourceProvenanceExpectation(
                sourceIdentitySHA256:
                    fixture.expectation
                    .sourceIdentitySHA256,
                buildConfiguration: "debug"
            )

        XCTAssertThrowsError(
            try PrimeSwiftSourceProvenance.capture(
                at: fixture.root,
                requiredRelativePaths: [],
                expectation: debugExpectation
            )
        ) { error in
            XCTAssertEqual(
                error as?
                    PrimeSwiftSourceProvenanceError,
                .releaseBuildRequired("debug")
            )
        }
    }

    func testCaptureRejectsRelativeDepthAboveMaximum()
        throws
    {
        let fixture = try makeFixture()
        defer {
            try? FileManager.default.removeItem(
                at: fixture.root
            )
        }
        let relativeComponents =
            ["Sources"] +
            Array(
                repeating: "nested",
                count:
                    PrimeSwiftSourceProvenance
                    .maximumSnapshotRelativeDepth
            )
        XCTAssertEqual(
            relativeComponents.count,
            PrimeSwiftSourceProvenance
                .maximumSnapshotRelativeDepth + 1
        )
        try FileManager.default.createDirectory(
            at: fixture.root.appendingPathComponent(
                relativeComponents.joined(
                    separator: "/"
                ),
                isDirectory: true
            ),
            withIntermediateDirectories: true
        )

        XCTAssertThrowsError(
            try PrimeSwiftSourceProvenance.capture(
                at: fixture.root,
                requiredRelativePaths: [],
                expectation:
                    fixture.expectation
            )
        ) { error in
            XCTAssertEqual(
                error as?
                    PrimeSwiftSourceProvenanceError,
                .incompleteSourceSnapshot
            )
        }
    }

    func testCaptureRejectsFileCountAboveMaximum()
        throws
    {
        let fixture = try makeFixture()
        defer {
            try? FileManager.default.removeItem(
                at: fixture.root
            )
        }
        let baseline =
            try PrimeSwiftSourceProvenance.capture(
                at: fixture.root,
                requiredRelativePaths: [],
                expectation:
                    fixture.expectation
            )
        let addedFileCount =
            PrimeSwiftSourceProvenance
            .maximumSnapshotFileCount + 1
            - baseline.files.count
        XCTAssertGreaterThan(addedFileCount, 0)
        XCTAssertEqual(
            baseline.files.count + addedFileCount,
            PrimeSwiftSourceProvenance
                .maximumSnapshotFileCount + 1
        )
        let docs = fixture.root.appendingPathComponent(
            "docs",
            isDirectory: true
        )
        for index in 0 ..< addedFileCount {
            try Data().write(
                to: docs.appendingPathComponent(
                    String(
                        format:
                            "limit-%04d.md",
                        index
                    )
                )
            )
        }

        XCTAssertThrowsError(
            try PrimeSwiftSourceProvenance.capture(
                at: fixture.root,
                requiredRelativePaths: [],
                expectation:
                    fixture.expectation
            )
        ) { error in
            guard case let .unsafeSourceFile(path) =
                    error as?
                    PrimeSwiftSourceProvenanceError
            else {
                return XCTFail(
                    "unexpected error: \(error)"
                )
            }
            XCTAssertTrue(
                path.contains("/docs/limit-")
                    && path.hasSuffix(".md")
            )
        }
    }

    func testCaptureRejectsSparseFileAbovePerFileLimit()
        throws
    {
        let fixture = try makeFixture()
        defer {
            try? FileManager.default.removeItem(
                at: fixture.root
            )
        }
        let oversizedByteCount:
            UInt64 = 8 * 1024 * 1024 + 1
        let oversized = fixture.root
            .appendingPathComponent(
                "Sources/Oversized.swift"
            )
        XCTAssertTrue(
            FileManager.default.createFile(
                atPath: oversized.path,
                contents: Data()
            )
        )
        let handle = try FileHandle(
            forWritingTo: oversized
        )
        try handle.truncate(
            atOffset: oversizedByteCount
        )
        try handle.close()
        let attributes =
            try FileManager.default.attributesOfItem(
                atPath: oversized.path
            )
        XCTAssertEqual(
            (attributes[.size] as? NSNumber)?
                .uint64Value,
            oversizedByteCount
        )

        XCTAssertThrowsError(
            try PrimeSwiftSourceProvenance.capture(
                at: fixture.root,
                requiredRelativePaths: [],
                expectation:
                    fixture.expectation
            )
        ) { error in
            guard case let .unsafeSourceFile(path) =
                    error as?
                    PrimeSwiftSourceProvenanceError
            else {
                return XCTFail(
                    "unexpected error: \(error)"
                )
            }
            XCTAssertTrue(
                path.hasSuffix(
                    "/Sources/Oversized.swift"
                )
            )
        }
    }

    private struct Fixture {
        let root: URL
        let expectation:
            PrimeSwiftSourceProvenanceExpectation
    }

    private struct IdentityRecord: Codable {
        let relativePath: String
        let sha256: String
        let byteCount: UInt64

        private enum CodingKeys:
            String,
            CodingKey
        {
            case relativePath = "relative_path"
            case sha256
            case byteCount = "byte_count"
        }
    }

    private func makeFixture() throws -> Fixture {
        let root = FileManager.default
            .temporaryDirectory
            .appendingPathComponent(
                "prime-source-provenance-" +
                    UUID().uuidString,
                isDirectory: true
            )
        for directory in [
            ".swiftpm/configuration",
            "Tests/PrimeTypedOptimizerRestoreMechanicsValidation/.swiftpm/configuration",
            "Tests/PrimeNativeNeuralGateMLXValidation/.swiftpm/configuration",
            "Tests/PrimeValidationWorkflow/.swiftpm/configuration",
            "Sources/PrimeCore",
            "Tests",
            "docs",
        ] {
            try FileManager.default.createDirectory(
                at: root.appendingPathComponent(
                    directory,
                    isDirectory: true
                ),
                withIntermediateDirectories: true
            )
        }
        var contents: [String: Data] = [
            ".gitignore": Data(".build/\n".utf8),
            ".swiftpm/configuration/mirrors.json":
                Data(
                    """
                    {
                      "object" : [
                        {
                          "mirror" : "https://github.com/Ergentics/ergentics-mlx-swift",
                          "original" : "https://github.com/ml-explore/mlx-swift"
                        }
                      ],
                      "version" : 1
                    }

                    """.utf8
                ),
            "Tests/PrimeTypedOptimizerRestoreMechanicsValidation/.swiftpm/configuration/mirrors.json":
                Data(
                    """
                    {
                      "object" : [
                        {
                          "mirror" : "https://github.com/Ergentics/ergentics-mlx-swift",
                          "original" : "https://github.com/ml-explore/mlx-swift"
                        }
                      ],
                      "version" : 1
                    }

                    """.utf8
                ),
            "Tests/PrimeNativeNeuralGateMLXValidation/.swiftpm/configuration/mirrors.json":
                Data(
                    """
                    {
                      "object" : [
                        {
                          "mirror" : "https://github.com/Ergentics/ergentics-mlx-swift",
                          "original" : "https://github.com/ml-explore/mlx-swift"
                        }
                      ],
                      "version" : 1
                    }

                    """.utf8
                ),
            "Tests/PrimeValidationWorkflow/.swiftpm/configuration/mirrors.json":
                Data(
                    """
                    {
                      "object" : [
                        {
                          "mirror" : "https://github.com/Ergentics/ergentics-mlx-swift",
                          "original" : "https://github.com/ml-explore/mlx-swift"
                        }
                      ],
                      "version" : 1
                    }

                    """.utf8
                ),
            "LICENSE": Data("first-party\n".utf8),
            "Package.swift":
                Data("// swift-tools-version: 5.10\n".utf8),
            "Package.resolved": Data("{}\n".utf8),
            "README.md": Data("# Fixture\n".utf8),
            "THIRD_PARTY_NOTICES.md":
                Data("# Notices\n".utf8),
            "Sources/Fixture.swift":
                Data("struct Fixture {}\n".utf8),
            "Tests/FixtureTests.swift":
                Data("import XCTest\n".utf8),
            "docs/ARCHITECTURE.md":
                Data("# Architecture\n".utf8),
        ]
        for (relativePath, data) in contents {
            try data.write(
                to: root.appendingPathComponent(
                    relativePath
                )
            )
        }
        let records = contents
            .map {
                IdentityRecord(
                    relativePath: $0.key,
                    sha256:
                        PrimeSHA256.hexDigest(
                            of: $0.value
                        ),
                    byteCount: UInt64($0.value.count)
                )
            }
            .sorted {
                $0.relativePath < $1.relativePath
            }
        let identity = PrimeSHA256.hexDigest(
            of: try PrimeCanonicalJSON.encode(
                records
            )
        )
        let embedded =
            PrimeSwiftSourceProvenance
                .canonicalEmbeddedProvenanceSource(
                    sourceIdentitySHA256: identity
                )
        contents[
            PrimeSwiftSourceProvenance
                .embeddedProvenanceRelativePath
        ] = embedded
        try embedded.write(
            to: root.appendingPathComponent(
                PrimeSwiftSourceProvenance
                    .embeddedProvenanceRelativePath
            )
        )
        return Fixture(
            root: root,
            expectation:
                PrimeSwiftSourceProvenanceExpectation(
                    sourceIdentitySHA256: identity,
                    buildConfiguration: "release"
                )
        )
    }
}
