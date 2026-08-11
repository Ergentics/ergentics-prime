// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
@testable import PrimeCore
import XCTest

final class
    PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsExecutionFailureObservationTests:
    XCTestCase
{
    private typealias Observation =
        PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsExecutionFailureObservationV1

    func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndFailureCeiling()
        throws
    {
        let observation = Observation.frozenV1

        XCTAssertNoThrow(try observation.validate())
        XCTAssertNoThrow(try observation.validateExactV1())
        XCTAssertEqual(observation.schemaVersion, 1)
        XCTAssertEqual(
            observation.observationID,
            "ergentics_prime_native_decoder_tiny_cpu_train_evaluate_mechanics_execution_failure_observation_v1"
        )
        XCTAssertEqual(
            observation.predecessorAuthorityID,
            PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsAuthorityV1
                .frozenV1.authorityID
        )

        let repository = observation.repositoryIdentity
        XCTAssertEqual(repository.pullRequestNumber, 83)
        XCTAssertEqual(
            repository.revision,
            "8d544c34a09a770198b50126f50adb766f234a8f"
        )
        XCTAssertEqual(
            repository.orderedParentRevisions,
            [
                "605d47dde85715f356e4d6e11beb3a3262cc4e7e",
                "f13322ebc368c639a0f04b7570af093cc57ec22b",
            ]
        )
        XCTAssertEqual(
            repository.tree,
            "c5b776a9ad25375ef681de3041ef6259ac84dc4a"
        )
        XCTAssertEqual(repository.reviewedHeadTree, repository.tree)
        XCTAssertTrue(repository.mergeCommitSignatureVerified)
        XCTAssertEqual(repository.mergeCommitSignatureReason, "valid")
        XCTAssertTrue(repository.historyPreservingTwoParentMergeObserved)
        XCTAssertTrue(repository.mergeTreeEqualsReviewedHeadTree)
        XCTAssertTrue(repository.exactMainRefStillMatchedAtAudit)
        XCTAssertEqual(
            repository.embeddedSourceIdentitySHA256,
            "3d5316d3e3852eb205fee00ebd595a36f5cada16f404a1c3d05f2546b2e67f7e"
        )

        XCTAssertEqual(observation.observedSourceBindings.count, 12)
        XCTAssertEqual(
            observation.observedSourceBindings.map(\.path),
            [
                ".github/workflows/prime-active-root-quarantine.yml",
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                "Package.swift",
                "Package.resolved",
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                "Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsAuthority.swift",
                "Sources/PrimeNativeDecoder/PrimeNativeGQADecoder.swift",
                "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderTraining.swift",
                "Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsAuthorityTests.swift",
                "Tests/PrimeNativeDecoderTrainingValidation/Package.swift",
                "Tests/PrimeNativeDecoderTrainingValidation/Package.resolved",
                "Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTrainingTests.swift",
            ]
        )
        XCTAssertTrue(
            observation.observedSourceBindings.allSatisfy { binding in
                ["100644", "100755"].contains(binding.gitMode)
                    && binding.gitBlob.utf8.count == 40
                    && isLowercaseHex(binding.gitBlob)
                    && binding.byteCount > 0
                    && binding.sha256.utf8.count == 64
                    && isLowercaseHex(binding.sha256)
                    && !binding.claimScope.isEmpty
            }
        )

        let run = observation.runIdentity
        XCTAssertEqual(run.workflowID, 329_017_041)
        XCTAssertEqual(run.runID, 31_525_634_838)
        XCTAssertEqual(run.runNumber, 63)
        XCTAssertEqual(run.runAttempt, 1)
        XCTAssertEqual(run.event, "push")
        XCTAssertEqual(run.headBranch, "main")
        XCTAssertEqual(run.headRevision, repository.revision)
        XCTAssertEqual(run.actor, "psyop-archivist")
        XCTAssertEqual(run.triggeringActor, run.actor)
        XCTAssertEqual(run.createdAt, "2026-08-11T19:00:12Z")
        XCTAssertEqual(run.completedAt, "2026-08-11T19:24:50Z")
        XCTAssertEqual(run.status, "completed")
        XCTAssertEqual(run.conclusion, "failure")
        XCTAssertEqual(run.checkSuiteID, 85_517_285_576)
        XCTAssertEqual(run.exactHeadPushRunCount, 1)
        XCTAssertTrue(run.previousAttemptURLWasNull)
        XCTAssertEqual(run.secondAttemptEndpointHTTPStatus, 404)
        XCTAssertEqual(run.rerunCount, 0)
        XCTAssertFalse(run.rerunObserved)
        XCTAssertFalse(run.rerunAuthorized)

        let active = observation.activeRootJob
        XCTAssertEqual(active.id, 93_893_140_174)
        XCTAssertEqual(active.conclusion, "success")
        XCTAssertEqual(active.runnerLabel, "macos-15")
        XCTAssertEqual(active.runnerName, "GitHub Actions 1000001685")
        XCTAssertEqual(active.orderedSteps.map(\.number), Array(1 ... 7))
        XCTAssertTrue(
            active.orderedSteps.allSatisfy { $0.conclusion == "success" }
        )
        XCTAssertEqual(active.checkAnnotationCount, 0)

        let reviewed = observation.reviewedMainJob
        XCTAssertEqual(reviewed.id, 93_893_902_353)
        XCTAssertEqual(reviewed.conclusion, "failure")
        XCTAssertEqual(reviewed.runnerLabel, "macos-26")
        XCTAssertEqual(reviewed.runnerName, "GitHub Actions 1000001686")
        XCTAssertEqual(
            reviewed.orderedSteps.map(\.conclusion),
            [
                "success",
                "success",
                "success",
                "success",
                "failure",
                "skipped",
                "success",
            ]
        )
        XCTAssertEqual(reviewed.checkAnnotationCount, 1)
        XCTAssertEqual(reviewed.checkAnnotationPath, ".github")
        XCTAssertEqual(reviewed.checkAnnotationStartLine, 3_687)
        XCTAssertEqual(
            reviewed.checkAnnotationMessage,
            "Process completed with exit code 1."
        )

        let toolchain = observation.runnerToolchain
        XCTAssertEqual(toolchain.runnerVersion, "2.336.0")
        XCTAssertEqual(toolchain.runnerProvisionerVersion, "20260707.563")
        XCTAssertEqual(toolchain.reviewedRunnerImage, "macos-26-arm64")
        XCTAssertEqual(
            toolchain.reviewedRunnerImageVersion,
            "20260728.0273.1"
        )
        XCTAssertEqual(toolchain.reviewedOperatingSystemBuild, "25F84")
        XCTAssertEqual(toolchain.xcodeVersion, "26.6")
        XCTAssertEqual(toolchain.xcodeBuildVersion, "17F113")
        XCTAssertEqual(toolchain.swiftTarget, "arm64-apple-macosx26.0")
        XCTAssertEqual(toolchain.macOSSDKVersion, "26.5")
        XCTAssertTrue(toolchain.exactHostedRunnerImagesRecorded)
        XCTAssertFalse(toolchain.exactPhysicalRunnerIdentityRecorded)

        let activeLog = observation.activeRootRawLog
        XCTAssertEqual(activeLog.byteCount, 230_005)
        XCTAssertEqual(activeLog.lfByteCount, 1_733)
        XCTAssertEqual(activeLog.splitLineCountExcludingTerminalEmpty, 1_733)
        XCTAssertEqual(
            activeLog.newlineDelimitedComponentCountIncludingTerminalEmpty,
            1_734
        )
        XCTAssertEqual(activeLog.utf8BOMHex, "efbbbf")
        XCTAssertTrue(activeLog.startsWithUTF8BOM)
        XCTAssertTrue(activeLog.usesLFOnly)
        XCTAssertTrue(activeLog.endsWithLF)
        XCTAssertEqual(
            activeLog.sha256,
            "e1cc35d3a637432d22cbbb199b0227f1401d675f43231214081e00e30be11c65"
        )

        let reviewedLog = observation.reviewedMainRawLog
        XCTAssertEqual(reviewedLog.byteCount, 377_065)
        XCTAssertEqual(reviewedLog.lfByteCount, 3_829)
        XCTAssertEqual(
            reviewedLog.newlineDelimitedComponentCountIncludingTerminalEmpty,
            3_830
        )
        XCTAssertEqual(
            reviewedLog.sha256,
            "820af763e807444722af2390e29efa782ee12841ffbeeebc1591b751908527d4"
        )

        let archive = observation.rawLogArchive
        XCTAssertEqual(archive.byteCount, 168_501)
        XCTAssertEqual(
            archive.sha256,
            "431d7afb7ab70ce0b60b3b04da0969317a5734d562c2a461a2be7c5196b015ef"
        )
        XCTAssertEqual(archive.memberCount, 17)
        XCTAssertEqual(archive.members.count, archive.memberCount)
        XCTAssertEqual(
            archive.members.reduce(0) { $0 + $1.byteCount },
            archive.uncompressedByteCount
        )
        XCTAssertEqual(archive.uncompressedByteCount, 1_215_574)
        XCTAssertEqual(
            Set(archive.members.map(\.path)).count,
            archive.members.count
        )
        XCTAssertTrue(archive.repeatedDownloadsWereByteIdentical)
        XCTAssertTrue(archive.memberTimestampsAreDOSZero)
        XCTAssertTrue(archive.skippedReviewedStepMemberAbsent)
        XCTAssertEqual(
            archive.focusedStepMemberDiagnosticTimestamp,
            "2026-08-11T19:24:39.4258430Z"
        )
        XCTAssertEqual(
            archive.focusedStepMemberExitTimestamp,
            "2026-08-11T19:24:39.4416120Z"
        )

        let focused = observation.focusedExecution
        XCTAssertEqual(
            focused.completedGroups.map(\.completedTestCount),
            [34, 1, 1, 2, 2]
        )
        XCTAssertEqual(focused.completedTestCountBeforeStage2Termination, 40)
        XCTAssertEqual(focused.completedFailureCountBeforeStage2Termination, 0)
        XCTAssertEqual(focused.completedSkipCountBeforeStage2Termination, 0)
        XCTAssertEqual(
            focused.stage2TestMethod,
            "testTinyCPUTrainEvaluateMechanicsAreExactAndFailClosed"
        )
        XCTAssertEqual(focused.stage2TestInvocationCount, 1)
        XCTAssertEqual(focused.stage2TestStartCount, 1)
        XCTAssertEqual(focused.stage2CompletedPassCount, 0)
        XCTAssertEqual(focused.stage2CompletedFailureCount, 0)
        XCTAssertEqual(focused.stage2CompletedSkipCount, 0)
        XCTAssertEqual(focused.swiftTestingAuxiliaryTestCount, 0)
        XCTAssertEqual(focused.swiftTestingAuxiliarySuiteCount, 0)
        XCTAssertFalse(focused.swiftTestingAuxiliaryOutputIsStage2CompletionEvidence)
        XCTAssertFalse(focused.hostedStage2RequirementSatisfied)
        XCTAssertEqual(focused.retainedLiveSequenceInvocationCounts, [0, 0, 0])
        XCTAssertEqual(focused.runtimeReceiptCount, 0)
        XCTAssertEqual(focused.tokenizerReceiptCount, 0)
        XCTAssertEqual(focused.retiredSeed42CheckpointCommandCount, 0)
        XCTAssertEqual(focused.retiredSeed43CheckpointCommandCount, 0)
        XCTAssertEqual(focused.checkpointReceiptMarkerCount, 0)
        XCTAssertEqual(focused.artifactUploadStepCount, 0)

        let failure = observation.failureBoundary
        XCTAssertEqual(failure.failedJobStepNumber, 5)
        XCTAssertEqual(failure.skippedLiveStepNumber, 6)
        XCTAssertTrue(
            failure.derivedRunnerSourcePath.hasSuffix(
                "PrimeNativeDecoderTrainingValidationPackageTests.derived/runner.swift"
            )
        )
        XCTAssertEqual(
            failure.methodAggregateLogStartTimestamp,
            "2026-08-11T19:24:39.4257140Z"
        )
        XCTAssertEqual(
            failure.diagnosticFocusedArchiveMemberTimestamp,
            "2026-08-11T19:24:39.4258430Z"
        )
        XCTAssertEqual(
            failure.diagnosticAggregateLogTimestamp,
            "2026-08-11T19:24:39.4258460Z"
        )
        XCTAssertNotEqual(
            failure.diagnosticFocusedArchiveMemberTimestamp,
            failure.diagnosticAggregateLogTimestamp
        )
        XCTAssertEqual(failure.libraryNotFoundOccurrenceCount, 4)
        XCTAssertTrue(
            failure.exactDiagnostic.hasPrefix(
                "MLX error: Failed to load the default metallib."
            )
        )
        XCTAssertTrue(failure.exactDiagnostic.hasSuffix("stream.cpp:106"))
        XCTAssertEqual(failure.failureSourceRevision, "0726ca922fc902c4c61ef9c27d94132be418e945")
        XCTAssertEqual(failure.failureSourceLine, 106)
        XCTAssertEqual(
            failure.focusedArchiveMemberExitTimestamp,
            "2026-08-11T19:24:39.4416120Z"
        )
        XCTAssertEqual(
            failure.aggregateLogExitTimestamp,
            "2026-08-11T19:24:39.4416130Z"
        )
        XCTAssertNotEqual(
            failure.focusedArchiveMemberExitTimestamp,
            failure.aggregateLogExitTimestamp
        )
        XCTAssertEqual(failure.processExitCode, 1)
        XCTAssertTrue(failure.hostedBootstrapFailureObserved)
        XCTAssertFalse(failure.CPUTrainEvaluateSemanticFailureObserved)
        XCTAssertFalse(failure.CPUTrainEvaluateMechanicsPassObserved)

        let flow = observation.controlFlow
        XCTAssertEqual(flow.orderedPreMLXReturnedPhases.count, 12)
        XCTAssertTrue(flow.configurationAssertionsReturnedSourceInferred)
        XCTAssertEqual(flow.batchRejectionCallCountSourceInferred, 17)
        XCTAssertEqual(flow.gradientClipCallCountSourceInferred, 7)
        XCTAssertEqual(flow.validBatchConstructionCountSourceInferred, 4)
        XCTAssertTrue(flow.selectedTargetCountAssertionsReturnedSourceInferred)
        XCTAssertTrue(flow.coreGraphicsDiscoveryReturnedSourceInferred)
        XCTAssertTrue(flow.metalDeviceEnumerationReturnedSourceInferred)
        XCTAssertTrue(flow.metalDefaultDeviceDiscoveryReturnedSourceInferred)
        XCTAssertTrue(flow.metalCapabilityGuardAdmittedHostSourceInferred)
        XCTAssertFalse(flow.localNoMetalDeviceSkipPathTaken)
        XCTAssertFalse(flow.discoveryPerformedTensorComputation)
        XCTAssertTrue(
            flow.deviceWithDefaultDeviceCallExpressionReachedSourceInferred
        )
        XCTAssertTrue(flow.CPUDeviceArgumentEvaluationReachedSourceInferred)
        XCTAssertTrue(
            flow.pinnedSchedulerInitializesGPUDefaultStreamBeforeCPUStream
        )
        XCTAssertTrue(flow.defaultMetallibDiscoveryAttemptedSourceInferred)
        XCTAssertEqual(flow.stage2WorkflowMetallibBuildCommandCount, 0)
        XCTAssertEqual(flow.stage2WorkflowMetallibStageCommandCount, 0)
        XCTAssertFalse(flow.loadableDefaultMetallibDiscovered)
        XCTAssertEqual(
            [
                flow.withDefaultDeviceClosureEntryCount,
                flow.requireCPUDefaultInvocationCount,
                flow.trainerConstructionCount,
                flow.decoderModelAllocationCount,
                flow.validationSnapshotCount,
                flow.trainInvocationCount,
                flow.completedOptimizerStepCount,
                flow.evaluationInvocationCount,
                flow.evaluationCompletionCount,
                flow.twoTrainerEqualityAssertionCount,
                flow.initialSnapshotEqualityAssertionCount,
                flow.firstStepResultEqualityAssertionCount,
                flow.secondStepResultEqualityAssertionCount,
                flow.evaluationResultEqualityAssertionCount,
                flow.evaluationSharedPrefixSelectedLossEqualityAssertionCount,
                flow.globalMeanLossAssertionCount,
                flow.thirdStepRejectionGuardInvocationCount,
                flow.parameterDigestObservationCount,
                flow.momentDigestObservationCount,
                flow.gradientObservationCount,
                flow.observedRuntimeDigestValueCount,
                flow.observedFloat32BitPatternValueCount,
            ],
            Array(repeating: 0, count: 22)
        )
        XCTAssertFalse(flow.CPUDeviceEstablished)
        XCTAssertFalse(flow.CPUDefaultStreamEstablished)
        XCTAssertFalse(flow.MLXTensorComputationObserved)
        XCTAssertFalse(flow.metalTensorSubmissionObserved)
        XCTAssertTrue(flow.failurePrecedesCPUMechanics)

        let artifacts = observation.artifactBoundary
        XCTAssertEqual(artifacts.actionsArtifactsTotalCount, 0)
        XCTAssertTrue(artifacts.actionsArtifactsArrayExactlyEmpty)
        XCTAssertEqual(artifacts.publishedWorkflowArtifactCount, 0)
        XCTAssertEqual(artifacts.artifactUploadStepCount, 0)
        XCTAssertTrue(artifacts.runLogArchiveObserved)
        XCTAssertFalse(artifacts.runLogArchiveIsActionsArtifact)
        XCTAssertFalse(artifacts.jobLogsRetainedInRepository)
        XCTAssertFalse(artifacts.durableJobLogPublicationEstablished)
        XCTAssertTrue(artifactFalseClaims(artifacts).allSatisfy { !$0 })

        let ceiling = observation.authorityCeiling
        XCTAssertTrue(ceiling.predecessorAuthorityRemainsFrozen)
        XCTAssertTrue(ceiling.predecessorAuthorityValidatedForConsumption)
        XCTAssertTrue(ceiling.predecessorExecutionAttemptConsumed)
        XCTAssertTrue(ceiling.predecessorExecutionAuthorityExhausted)
        XCTAssertTrue(ceiling.implementationSourceRemainsFrozen)
        XCTAssertTrue(ceiling.validationManifestRemainsFrozen)
        XCTAssertTrue(ceiling.validationLockRemainsFrozen)
        XCTAssertTrue(ceiling.failedValidationSourceRemainsFrozen)
        XCTAssertTrue(ceiling.bootstrapRepairRequiredBeforeAnotherAttempt)
        XCTAssertTrue(ceiling.stage3Blocked)
        XCTAssertTrue(authorityFalseClaims(ceiling).allSatisfy { !$0 })
        XCTAssertTrue(observation.status.hasPrefix("ABSTAIN_stage2_attempt_consumed"))
        XCTAssertEqual(observation.orderedNextActions.count, 5)

        requireSendable(Observation.self)
        let canonical = try observation.canonicalData()
        XCTAssertEqual(canonical, try PrimeCanonicalJSON.encode(observation))
        let canonicalHash = PrimeSHA256.hexDigest(of: canonical)
        XCTAssertEqual(
            canonicalHash,
            "3822447081af914836f0c158adfb6fd5cbad611a24082ebffd516bffc0f0f002"
        )
        let decoded = try Observation.decodeCanonical(canonical)
        XCTAssertEqual(decoded, observation)
        XCTAssertEqual(try decoded.canonicalData(), canonical)
        XCTAssertNoThrow(try decoded.validateExactV1())

        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical)
                as? [String: Any]
        )
        let valuePaths = allValuePaths(in: object)
        let dictionaryPaths = allDictionaryPaths(in: object)
        let scalarPaths = allScalarPaths(in: object)
        XCTAssertGreaterThan(valuePaths.count, 450)
        XCTAssertGreaterThan(dictionaryPaths.count, 45)
        XCTAssertGreaterThan(scalarPaths.count, 350)

        var regularDecodedDriftCount = 0
        var mutationCount = 0
        var nullCount = 0
        var removalCount = 0
        for path in valuePaths {
            let mutated = replacingValue(
                in: object,
                at: path,
                with: mutateJSONValue
            )
            let mutationData = try assertCanonicalRejects(
                mutated,
                label: "mutated \(pathLabel(path))"
            )
            mutationCount += 1
            if let loose = try? JSONDecoder().decode(
                Observation.self,
                from: mutationData
            ), loose != observation {
                regularDecodedDriftCount += 1
                XCTAssertThrowsError(try loose.validateExactV1())
            }

            _ = try assertCanonicalRejects(
                replacingValue(
                    in: object,
                    at: path,
                    with: { _ in NSNull() }
                ),
                label: "null \(pathLabel(path))"
            )
            nullCount += 1

            _ = try assertCanonicalRejects(
                removingValue(in: object, at: path),
                label: "removed \(pathLabel(path))"
            )
            removalCount += 1
        }
        XCTAssertEqual(mutationCount, valuePaths.count)
        XCTAssertEqual(nullCount, valuePaths.count)
        XCTAssertEqual(removalCount, valuePaths.count)
        XCTAssertGreaterThan(regularDecodedDriftCount, 300)

        var unknownFieldCount = 0
        for (index, path) in dictionaryPaths.enumerated() {
            let unknown = replacingValue(
                in: object,
                at: path,
                with: { value in
                    var dictionary = value as! [String: Any]
                    dictionary["unknown_stage2_failure_field_\(index)"] = true
                    return dictionary
                }
            )
            let unknownData = try assertCanonicalRejects(
                unknown,
                label: "unknown field at \(pathLabel(path))"
            )
            let loose = try JSONDecoder().decode(
                Observation.self,
                from: unknownData
            )
            XCTAssertEqual(loose, observation)
            unknownFieldCount += 1
        }
        XCTAssertEqual(unknownFieldCount, dictionaryPaths.count)

        try assertNoncanonicalEncodingsReject(canonical, object: object)
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
                return [path]
                    + allValuePaths(in: object[key]!, prefix: path)
            }
        }
        if let array = value as? [Any] {
            return array.indices.flatMap { index in
                let path = prefix + [.index(index)]
                return [path]
                    + allValuePaths(in: array[index], prefix: path)
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

    private func removingValue(
        in value: Any,
        at path: JSONPath
    ) -> Any {
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

    @discardableResult
    private func assertCanonicalRejects(
        _ object: Any,
        label: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> Data {
        let data = try JSONSerialization.data(
            withJSONObject: object,
            options: [.sortedKeys, .withoutEscapingSlashes]
        )
        XCTAssertThrowsError(
            try Observation.decodeCanonical(data),
            label,
            file: file,
            line: line
        )
        return data
    }

    private func assertNoncanonicalEncodingsReject(
        _ canonical: Data,
        object: [String: Any]
    ) throws {
        var prefixed = Data([0x20])
        prefixed.append(canonical)
        XCTAssertThrowsError(try Observation.decodeCanonical(prefixed))

        var suffixed = canonical
        suffixed.append(0x0A)
        XCTAssertThrowsError(try Observation.decodeCanonical(suffixed))

        let pretty = try JSONSerialization.data(
            withJSONObject: object,
            options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        )
        XCTAssertNotEqual(pretty, canonical)
        XCTAssertThrowsError(try Observation.decodeCanonical(pretty))

        var slashEscaped = try XCTUnwrap(
            String(data: canonical, encoding: .utf8)
        )
        let slashIndex = try XCTUnwrap(slashEscaped.firstIndex(of: "/"))
        slashEscaped.replaceSubrange(slashIndex ... slashIndex, with: "\\/")
        let slashEscapedData = try XCTUnwrap(
            slashEscaped.data(using: .utf8)
        )
        XCTAssertThrowsError(
            try Observation.decodeCanonical(slashEscapedData)
        )

        var reordered = try XCTUnwrap(
            String(data: canonical, encoding: .utf8)
        )
        let schemaField = "\"schemaVersion\":1,"
        let schemaRange = try XCTUnwrap(reordered.range(of: schemaField))
        reordered.removeSubrange(schemaRange)
        let openingBrace = try XCTUnwrap(reordered.firstIndex(of: "{"))
        reordered.insert(
            contentsOf: schemaField,
            at: reordered.index(after: openingBrace)
        )
        let reorderedData = try XCTUnwrap(reordered.data(using: .utf8))
        XCTAssertNotEqual(reorderedData, canonical)
        XCTAssertThrowsError(try Observation.decodeCanonical(reorderedData))

        var duplicate = try XCTUnwrap(
            String(data: canonical, encoding: .utf8)
        )
        let duplicateOpening = try XCTUnwrap(duplicate.firstIndex(of: "{"))
        duplicate.insert(
            contentsOf: schemaField,
            at: duplicate.index(after: duplicateOpening)
        )
        let duplicateData = try XCTUnwrap(duplicate.data(using: .utf8))
        XCTAssertThrowsError(try Observation.decodeCanonical(duplicateData))
    }

    private func artifactFalseClaims(
        _ boundary: PrimeNativeDecoderTinyCPUFailureArtifactBoundaryV1
    ) -> [Bool] {
        [
            boundary.runtimeReceiptEmitted,
            boundary.tokenizerReceiptEmitted,
            boundary.checkpointReceiptEmitted,
            boundary.checkpointArtifactCreated,
            boundary.checkpointArtifactUploaded,
            boundary.checkpointArtifactRetained,
            boundary.checkpointArtifactProvenanceEstablished,
        ]
    }

    private func authorityFalseClaims(
        _ ceiling: PrimeNativeDecoderTinyCPUFailureAuthorityCeilingV1
    ) -> [Bool] {
        [
            ceiling.rerunObserved,
            ceiling.rerunAuthorized,
            ceiling.failedAttemptRecoverable,
            ceiling.replacementExecutionAuthorityEstablished,
            ceiling.failedWorkflowInvocationRemainsLive,
            ceiling.bootstrapRepairAuthorizedByThisObservation,
            ceiling.tinyCPUTrainEvaluateExecutionEstablished,
            ceiling.tinyCPUCPUDeviceEstablished,
            ceiling.tinyCPUTrainerInitializationEstablished,
            ceiling.tinyCPUModelAllocationEstablished,
            ceiling.tinyCPUOptimizerStepEstablished,
            ceiling.tinyCPUEvaluationEstablished,
            ceiling.explicitRNGStateEstablished,
            ceiling.deterministicDataCursorEstablished,
            ceiling.interruptionBoundaryEstablished,
            ceiling.resumeExecutionEstablished,
            ceiling.checkpointReadEstablished,
            ceiling.checkpointWriteEstablished,
            ceiling.checkpointRoundTripEstablished,
            ceiling.checkpointArtifactAvailabilityEstablished,
            ceiling.checkpointArtifactRetentionEstablished,
            ceiling.checkpointArtifactUploadAuthorized,
            ceiling.checkpointArtifactProvenanceEstablished,
            ceiling.checkpointAdmissionGranted,
            ceiling.metalTensorExecutionEstablished,
            ceiling.metalDeterminismEstablished,
            ceiling.native300MAllocationEstablished,
            ceiling.native300MTrainingEstablished,
            ceiling.trajectoryExactResumeEstablished,
            ceiling.trainingResumeEstablished,
            ceiling.modelQualityEstablished,
            ceiling.candidateAdmissionGranted,
            ceiling.trialAuthorized,
            ceiling.canaryReplacementAuthorized,
            ceiling.quantizationAuthorized,
            ceiling.productUseAuthorized,
            ceiling.publicationAuthorized,
        ]
    }

    private func isLowercaseHex(_ value: String) -> Bool {
        !value.isEmpty
            && value.unicodeScalars.allSatisfy {
                ($0.value >= 48 && $0.value <= 57)
                    || ($0.value >= 97 && $0.value <= 102)
            }
    }

    private func requireSendable<T: Sendable>(_: T.Type) {}
}
