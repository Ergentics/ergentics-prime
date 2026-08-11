// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
@testable import PrimeCore
import XCTest

final class
    PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairAuthorityTests:
    XCTestCase
{
    private typealias Authority =
        PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairAuthorityV1

    func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndRepairCeiling()
        throws
    {
        let authority = Authority.frozenV1
        XCTAssertNoThrow(try authority.validate())
        XCTAssertNoThrow(try authority.validateExactV1())
        XCTAssertEqual(authority.schemaVersion, 1)
        XCTAssertEqual(
            authority.authorityID,
            "ergentics_prime_native_decoder_tiny_cpu_train_evaluate_mechanics_default_metallib_bootstrap_repair_authority_v1"
        )
        XCTAssertEqual(
            authority.authorityKind,
            "exact_main_direct_successor_same_job_default_metallib_two_copy_direct_xctest_repair_authority"
        )

        let green = authority.greenPrerequisite
        XCTAssertEqual(green.repository, "Ergentics/ergentics-prime")
        XCTAssertEqual(
            green.mergeRevision,
            "8504f0af692e19d3337cec00f2c624537bc7386a")
        XCTAssertEqual(
            green.mergeTree,
            "1b2bd05d14287fbb145d5bf6af74eb537accca8f")
        XCTAssertEqual(
            green.orderedParentRevisions,
            [
                "2d0464ca35212d3d84781654b6a4e08158f27eab",
                "fafbf24554b0bb473e7862bfadf7eccdbb5ed6e3",
            ])
        XCTAssertTrue(green.historyPreservingTwoParentMergeObserved)
        XCTAssertTrue(green.mergeTreeEqualsReviewedHeadTree)
        XCTAssertEqual(green.workflowID, 329_017_041)
        XCTAssertEqual(green.runID, 31_538_639_561)
        XCTAssertEqual(green.runNumber, 69)
        XCTAssertEqual(green.runAttempt, 1)
        XCTAssertEqual(green.checkSuiteID, 85_554_232_445)
        XCTAssertTrue(green.previousAttemptURLAbsent)
        XCTAssertEqual(green.exactHeadPushRunCount, 1)
        XCTAssertEqual(green.secondAttemptEndpointHTTPStatus, 404)
        XCTAssertEqual(green.rerunCount, 0)
        XCTAssertFalse(green.rerunObserved)
        XCTAssertEqual(green.runCreatedAt, "2026-08-11T21:35:57Z")
        XCTAssertEqual(green.runStartedAt, "2026-08-11T21:35:57Z")
        XCTAssertEqual(green.runUpdatedAt, "2026-08-11T22:16:20Z")
        XCTAssertEqual(green.runStatus, "completed")
        XCTAssertEqual(green.runConclusion, "success")
        XCTAssertEqual(green.activeRootJobID, 93_935_689_373)
        XCTAssertEqual(green.activeRootRunnerID, 1_000_001_694)
        XCTAssertEqual(green.activeRootCompletedStepCount, 7)
        XCTAssertEqual(green.activeRootConclusion, "success")
        XCTAssertEqual(green.reviewedMainJobID, 93_936_362_324)
        XCTAssertEqual(green.reviewedMainRunnerID, 1_000_001_695)
        XCTAssertEqual(green.reviewedMainCompletedStepCount, 7)
        XCTAssertEqual(green.reviewedMainConclusion, "success")
        XCTAssertEqual(green.runnerArchitecture, "arm64")
        XCTAssertEqual(green.reviewedRunnerOperatingSystem, "macOS 26.5.2")
        XCTAssertEqual(green.xcodeVersion, "26.6")
        XCTAssertEqual(green.swiftVersion, "6.3.3")
        XCTAssertEqual(green.secureFetchInvocationCount, 1)
        XCTAssertEqual(green.secureFetchCompletionCount, 1)
        XCTAssertEqual(green.secureFetchRetryCount, 0)
        XCTAssertEqual(green.tlsVerificationBypassCount, 0)
        XCTAssertEqual(
            green.mlxRevision,
            "d37885a278f1c37484a94d0f401a418735e66519")
        XCTAssertEqual(
            green.mlxCoreRevision,
            "ce45c52505c8158ea48d2a54e8caae05efd86bfe")
        XCTAssertEqual(
            green.mlxCRevision,
            "0726ca922fc902c4c61ef9c27d94132be418e945")
        XCTAssertEqual(
            [
                green.focusedRootTestCount,
                green.focusedRootFailureCount,
                green.focusedRootSkipCount,
                green.focusedWholeStepTestCount,
                green.focusedWholeStepFailureCount,
                green.focusedWholeStepSkipCount,
            ],
            [38, 0, 0, 44, 0, 0]
        )
        XCTAssertEqual(
            green.retainedLiveSequence,
            [
                "metal_44_of_44",
                "maintained_runtime_receipt",
                "tokenizer_receipt",
            ])
        XCTAssertEqual(green.retainedLiveSequenceInvocationCounts, [1, 1, 1])
        XCTAssertEqual(green.metallibBuildInvocationCount, 1)
        XCTAssertEqual(green.metallibBuildCompletionCount, 1)
        XCTAssertEqual(green.metallibByteCount, 6_292_748)
        XCTAssertEqual(
            green.metallibSHA256,
            "38117775b78e1f1a7920501d433c43426ea73c204e94bc4f25fee758f02364a6"
        )
        XCTAssertEqual(
            [
                green.metalTestCount,
                green.metalFailureCount,
                green.metalSkipCount,
                green.runtimeTestCount,
                green.runtimeFailureCount,
                green.runtimeSkipCount,
                green.runtimeReceiptCount,
                green.tokenizerTestCount,
                green.tokenizerFailureCount,
                green.tokenizerSkipCount,
                green.tokenizerReceiptCount,
            ],
            [44, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1]
        )
        XCTAssertTrue(green.repairedMetalAuthorityTestPassed)
        XCTAssertEqual(
            green.tokenizerBoundEmbeddedSourceIdentitySHA256,
            "f6d9149d262916e50d3ccabaa4cd8c38d681a8e3d5e70f7cf82cd158d2aa95fc"
        )
        XCTAssertEqual(
            [
                green.retainedLiveCombinedTestCount,
                green.retainedLiveCombinedFailureCount,
                green.retainedLiveCombinedSkipCount,
            ],
            [46, 0, 0])
        XCTAssertEqual(
            [
                green.stage2ValidationPackageCommandCount,
                green.stage2ValidationFilterCount,
                green.stage2ValidationLogPathCount,
                green.stage2ValidationScratchPathCount,
                green.stage2InvocationCount,
                green.checkpointLiveCommandCount,
                green.checkpointReceiptMarkerCount,
                green.artifactUploadStepCount,
                green.actionsArtifactsTotalCount,
            ],
            Array(repeating: 0, count: 9))
        XCTAssertTrue(green.actionsArtifactsArrayExactlyEmpty)
        XCTAssertTrue(green.logsAreTransportNotActionsArtifacts)
        XCTAssertEqual(green.runLogArchiveByteCount, 1_341_162)
        XCTAssertEqual(green.runLogArchiveMemberCount, 18)
        XCTAssertEqual(green.runLogArchiveUncompressedByteCount, 20_953_181)
        XCTAssertEqual(
            green.runLogArchiveSHA256,
            "fe6f6edd5b091ded26f728cb81bbc1911140d1f7ddf6dd393cf5007021eef4b5"
        )
        XCTAssertEqual(green.activeJobLogByteCount, 233_627)
        XCTAssertEqual(green.activeJobLogLFByteCount, 1_745)
        XCTAssertEqual(green.reviewedJobLogByteCount, 10_242_245)
        XCTAssertEqual(green.reviewedJobLogLFByteCount, 78_420)
        XCTAssertEqual(green.focusedStepLogByteCount, 341_638)
        XCTAssertEqual(green.focusedStepLogLFByteCount, 3_335)
        XCTAssertEqual(green.liveStepLogByteCount, 9_889_559)
        XCTAssertEqual(green.liveStepLogLFByteCount, 74_943)
        XCTAssertEqual(green.secureFetchStepLogByteCount, 4_893)
        XCTAssertEqual(green.secureFetchStepLogLFByteCount, 54)
        XCTAssertTrue(green.exactGreenPrerequisiteSatisfied)
        XCTAssertFalse(green.stage2BootstrapRepairObservedInPrerequisite)

        let consumed = authority.failureConsumption
        XCTAssertEqual(
            consumed.failureObservationID,
            PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsExecutionFailureObservationV1
                .frozenV1.observationID)
        XCTAssertEqual(
            consumed.failureObservationCanonicalSHA256,
            "3822447081af914836f0c158adfb6fd5cbad611a24082ebffd516bffc0f0f002"
        )
        XCTAssertEqual(consumed.exhaustedRunID, 31_525_634_838)
        XCTAssertEqual(consumed.exhaustedRunAttempt, 1)
        XCTAssertEqual(
            consumed.failureClassification,
            "pinned_mlx_default_metallib_bootstrap_failure_before_cpu_mechanics"
        )
        XCTAssertTrue(consumed.defaultMetallibDiscoveryAttempted)
        XCTAssertEqual(consumed.stage2WorkflowMetallibBuildCommandCount, 0)
        XCTAssertEqual(consumed.stage2WorkflowMetallibStageCommandCount, 0)
        XCTAssertFalse(consumed.loadableDefaultMetallibDiscovered)
        XCTAssertFalse(consumed.cpuDeviceEstablished)
        XCTAssertEqual(
            [
                consumed.trainerConstructionCount,
                consumed.decoderModelAllocationCount,
                consumed.completedOptimizerStepCount,
                consumed.evaluationCompletionCount,
            ],
            [0, 0, 0, 0])
        XCTAssertTrue(consumed.predecessorExecutionAttemptConsumed)
        XCTAssertTrue(consumed.predecessorExecutionAuthorityExhausted)
        XCTAssertFalse(consumed.failedAttemptRecoverable)
        XCTAssertFalse(consumed.failedInvocationRemainsLive)
        XCTAssertTrue(consumed.exhaustedScratchPathsRemainRetired)
        XCTAssertTrue(consumed.exhaustedLogPathRemainsRetired)
        XCTAssertFalse(consumed.rerunAuthorized)
        XCTAssertTrue(consumed.distinctRepairRequired)

        let bindings = authority.observedBaseSourceBindings
        XCTAssertEqual(bindings.count, 17)
        XCTAssertEqual(Set(bindings.map(\.path)).count, 17)
        XCTAssertEqual(bindings.first?.path, "Package.swift")
        XCTAssertEqual(
            bindings.last?.path,
            ".github/workflows/prime-active-root-quarantine.yml")
        XCTAssertTrue(bindings.allSatisfy { $0.gitMode == "100644" || $0.gitMode == "100755" })
        XCTAssertTrue(bindings.allSatisfy { $0.byteCount > 0 })
        XCTAssertTrue(bindings.allSatisfy { $0.gitBlob.count == 40 })
        XCTAssertTrue(bindings.allSatisfy { $0.sha256.count == 64 })

        let recipe = authority.recipe
        XCTAssertEqual(recipe.authorizedBaseRevision, green.mergeRevision)
        XCTAssertEqual(recipe.authorizedBaseTree, green.mergeTree)
        XCTAssertEqual(recipe.requiredExecutionCommitParentCount, 2)
        XCTAssertEqual(recipe.requiredFirstParentRevision, green.mergeRevision)
        XCTAssertTrue(recipe.executionMergeTreeMustEqualSecondParentTree)
        XCTAssertEqual(recipe.activeRootCheckoutFetchDepth, 1)
        XCTAssertEqual(recipe.reviewedMainCheckoutFetchDepth, 2)
        XCTAssertEqual(recipe.launcherNetworkFetchCommandCount, 0)
        XCTAssertEqual(
            recipe.exactDirectSuccessorChangedPaths,
            [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/scripts/prime-ci-native-decoder-stage2-metallib-bootstrap-repair.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                "Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairAuthority.swift",
                "Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairAuthorityTests.swift",
            ])
        XCTAssertEqual(
            recipe.launcherInvocation,
            "bash .github/scripts/prime-ci-native-decoder-stage2-metallib-bootstrap-repair.sh"
        )
        XCTAssertEqual(
            recipe.receiptPrefix,
            "PRIME_NATIVE_DECODER_STAGE2_METALLIB_BOOTSTRAP_REPAIR_RECEIPT="
        )
        XCTAssertEqual(
            recipe.metallibProducerRootRelativeToRunnerTemp,
            "prime-native-decoder-metallib")
        XCTAssertEqual(
            recipe.validationPackagePath,
            "Tests/PrimeNativeDecoderTrainingValidation")
        XCTAssertEqual(recipe.stage2TestClass, "PrimeNativeDecoderTrainingTests")
        XCTAssertEqual(
            recipe.stage2TestMethod,
            "testTinyCPUTrainEvaluateMechanicsAreExactAndFailClosed")
        XCTAssertEqual(recipe.buildConfiguration, "debug")
        XCTAssertEqual(recipe.binaryPathRelativeToScratch, "arm64-apple-macosx/debug")
        XCTAssertEqual(
            recipe.testBundleRelativeToBinaryPath,
            "PrimeNativeDecoderTrainingValidationPackageTests.xctest")
        XCTAssertEqual(recipe.requiredExclusiveMLXEnvironment, ["MLX_ENABLE_TF32": "0"])
        XCTAssertEqual(
            recipe.forbiddenInheritedEnvironmentPrefixes,
            ["MLX_", "DYLD_", "LLVM_PROFILE_"])
        XCTAssertEqual(recipe.requiredMetallibFileName, "default.metallib")
        XCTAssertEqual(recipe.requiredSourceMetallibCount, 1)
        XCTAssertEqual(recipe.maximumMetallibByteCount, 67_108_864)
        XCTAssertEqual(recipe.stagedMetallibCopyCount, 2)
        XCTAssertEqual(recipe.requiredStagedMetallibCount, 2)
        XCTAssertEqual(
            [
                recipe.swiftBuildInvocationCount,
                recipe.swiftBuildTestsFlagCount,
                recipe.swiftShowBinPathInvocationCount,
                recipe.swiftTestInvocationCount,
                recipe.xcodebuildInvocationCount,
                recipe.directXCTestInvocationCount,
                recipe.rebuildAfterMetallibStagingInvocationCount,
            ],
            [1, 1, 0, 0, 0, 1, 0])
        XCTAssertTrue(recipe.directXCTestRunsAlreadyBuiltBundle)
        XCTAssertTrue(recipe.sourceAndStagedMetallibBytesMustMatch)
        XCTAssertTrue(recipe.sourceAndStagedMetallibSHA256MustMatch)
        XCTAssertEqual(
            [
                recipe.requiredStage2TestCount,
                recipe.requiredStage2FailureCount,
                recipe.requiredStage2SkipCount,
            ],
            [1, 0, 0])
        XCTAssertTrue(recipe.oneDistinctExecutionAttemptAuthorized)
        XCTAssertTrue(recipe.githubRunAttemptMustEqualOne)
        XCTAssertTrue(recipe.successorObservationMustRetireLiveInvocation)

        XCTAssertTrue(authority.exactGreenPrerequisiteConsumed)
        XCTAssertTrue(authority.predecessorFailureConsumedWithoutRecovery)
        XCTAssertTrue(authority.sameJobFreshMetallibConsumptionAuthorized)
        XCTAssertTrue(authority.twoCopyMetallibStagingAuthorized)
        XCTAssertTrue(authority.directBuiltXCTestExecutionAuthorized)
        XCTAssertTrue(authority.exactOneDirectSuccessorAttemptAuthorized)
        XCTAssertFalse(authority.repairImplementationObservedByThisAuthority)
        XCTAssertFalse(authority.repairExecutionObservedByThisAuthority)
        XCTAssertTrue(falseClaims(authority.authorityCeiling).allSatisfy { !$0 })
        XCTAssertEqual(
            authority.status,
            "AUTHORIZED_exact_one_direct_successor_stage2_same_job_fresh_metallib_two_copy_direct_built_xctest_repair_not_execution_no_rerun_artifact_checkpoint_or_downstream_authority"
        )
        XCTAssertEqual(authority.orderedRequiredActions.count, 7)
        XCTAssertEqual(
            authority.orderedRequiredActions.last,
            "keep_stage3_blocked_until_that_distinct_execution_observation")

        requireSendable(Authority.self)
        let canonical = try authority.canonicalData()
        XCTAssertEqual(canonical, try PrimeCanonicalJSON.encode(authority))
        let canonicalHash = PrimeSHA256.hexDigest(of: canonical)
        XCTAssertEqual(canonicalHash, "2c397195129a550817996f8914c036ae39ede13d5c67186fe0c74a2daf99f7de")
        let decoded = try Authority.decodeCanonical(canonical)
        XCTAssertEqual(decoded, authority)
        XCTAssertEqual(try decoded.canonicalData(), canonical)
        XCTAssertNoThrow(try decoded.validateExactV1())

        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical) as? [String: Any])
        let valuePaths = allValuePaths(in: object)
        let dictionaryPaths = allDictionaryPaths(in: object)
        let scalarPaths = allScalarPaths(in: object)
        XCTAssertGreaterThan(valuePaths.count, 350)
        XCTAssertGreaterThan(dictionaryPaths.count, 20)
        XCTAssertGreaterThan(scalarPaths.count, 250)

        var regularDecodedDriftCount = 0
        var mutationCount = 0
        var nullCount = 0
        var removalCount = 0
        for path in valuePaths {
            let mutated = replacingValue(
                in: object,
                at: path,
                with: mutateJSONValue)
            let mutationData = try assertCanonicalRejects(
                mutated,
                label: "mutated \(pathLabel(path))")
            mutationCount += 1
            if let loose = try? JSONDecoder().decode(
                Authority.self,
                from: mutationData
            ), loose != authority {
                regularDecodedDriftCount += 1
                XCTAssertThrowsError(try loose.validateExactV1())
            }

            _ = try assertCanonicalRejects(
                replacingValue(
                    in: object,
                    at: path,
                    with: { _ in NSNull() }),
                label: "null \(pathLabel(path))")
            nullCount += 1

            _ = try assertCanonicalRejects(
                removingValue(in: object, at: path),
                label: "removed \(pathLabel(path))")
            removalCount += 1
        }
        XCTAssertEqual(mutationCount, valuePaths.count)
        XCTAssertEqual(nullCount, valuePaths.count)
        XCTAssertEqual(removalCount, valuePaths.count)
        XCTAssertGreaterThan(regularDecodedDriftCount, 200)

        var unknownFieldCount = 0
        for (index, path) in dictionaryPaths.enumerated() {
            let unknown = replacingValue(
                in: object,
                at: path,
                with: { value in
                    var dictionary = value as! [String: Any]
                    dictionary[
                        "unknown_stage2_default_metallib_bootstrap_repair_field_\(index)"
                    ] = true
                    return dictionary
                })
            _ = try assertCanonicalRejects(
                unknown,
                label: "unknown field at \(pathLabel(path))")
            unknownFieldCount += 1
        }
        XCTAssertEqual(unknownFieldCount, dictionaryPaths.count)

        try assertNoncanonicalEncodingsReject(canonical, object: object)
    }

    private func falseClaims(
        _ ceiling:
            PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairCeilingV1
    ) -> [Bool] {
        [
            ceiling.predecessorFailureObservationMutationAuthorized,
            ceiling.predecessorAuthorityMutationAuthorized,
            ceiling.currentDecoderRepairAuthorityMutationAuthorized,
            ceiling.productionTrainingSourceMutationAuthorized,
            ceiling.validationManifestMutationAuthorized,
            ceiling.validationLockMutationAuthorized,
            ceiling.validationTestMutationAuthorized,
            ceiling.metalLauncherMutationAuthorized,
            ceiling.runtimeLauncherMutationAuthorized,
            ceiling.tokenizerLauncherMutationAuthorized,
            ceiling.secureFetchMutationAuthorized,
            ceiling.tlsVerificationBypassAuthorized,
            ceiling.customCAInstallationAuthorized,
            ceiling.retryAuthorized,
            ceiling.rerunAuthorized,
            ceiling.failedRunRecoveryAuthorized,
            ceiling.additionalMetallibBuildAuthorized,
            ceiling.xcodebuildAuthorizedInRepairLauncher,
            ceiling.swiftTestAuthorizedInRepairLauncher,
            ceiling.postStagingRebuildAuthorized,
            ceiling.networkFetchAuthorizedInRepairLauncher,
            ceiling.secondStage2AttemptAuthorized,
            ceiling.executionObservedByThisAuthority,
            ceiling.stage2SuccessEstablished,
            ceiling.stage3AuthorityEstablished,
            ceiling.checkpointReadAuthorized,
            ceiling.checkpointWriteAuthorized,
            ceiling.checkpointArtifactAuthorized,
            ceiling.checkpointArtifactUploadAuthorized,
            ceiling.checkpointResumeAuthorized,
            ceiling.explicitRNGStateAuthorized,
            ceiling.deterministicDataCursorAuthorized,
            ceiling.interruptionResumeAuthorized,
            ceiling.metalTensorExecutionAuthorized,
            ceiling.native300MAllocationAuthorized,
            ceiling.native300MTrainingAuthorized,
            ceiling.trajectoryResumeAuthorized,
            ceiling.modelQualityEstablished,
            ceiling.candidateAdmissionGranted,
            ceiling.trialAuthorized,
            ceiling.canaryReplacementAuthorized,
            ceiling.quantizationAuthorized,
            ceiling.productUseAuthorized,
            ceiling.publicationAuthorized,
        ]
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
                    prefix: prefix + [.key(key)])
            }
        }
        if let array = value as? [Any] {
            return array.indices.flatMap { index in
                allDictionaryPaths(
                    in: array[index],
                    prefix: prefix + [.index(index)])
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
                    prefix: prefix + [.key(key)])
            }
        }
        if let array = value as? [Any] {
            return array.indices.flatMap { index in
                allScalarPaths(
                    in: array[index],
                    prefix: prefix + [.index(index)])
            }
        }
        return [prefix]
    }

    private func replacingValue(
        in root: Any,
        at path: JSONPath,
        with transform: (Any) -> Any
    ) -> Any {
        guard let component = path.first else {
            return transform(root)
        }
        let remainder = Array(path.dropFirst())
        switch component {
        case let .key(key):
            var object = root as! [String: Any]
            object[key] = replacingValue(
                in: object[key]!,
                at: remainder,
                with: transform)
            return object
        case let .index(index):
            var array = root as! [Any]
            array[index] = replacingValue(
                in: array[index],
                at: remainder,
                with: transform)
            return array
        }
    }

    private func removingValue(
        in root: Any,
        at path: JSONPath
    ) -> Any {
        precondition(!path.isEmpty)
        let component = path[0]
        let remainder = Array(path.dropFirst())
        switch component {
        case let .key(key):
            var object = root as! [String: Any]
            if remainder.isEmpty {
                object.removeValue(forKey: key)
            } else {
                object[key] = removingValue(
                    in: object[key]!,
                    at: remainder)
            }
            return object
        case let .index(index):
            var array = root as! [Any]
            if remainder.isEmpty {
                array.remove(at: index)
            } else {
                array[index] = removingValue(
                    in: array[index],
                    at: remainder)
            }
            return array
        }
    }

    private func mutateJSONValue(_ value: Any) -> Any {
        if let boolean = value as? NSNumber,
           CFGetTypeID(boolean) == CFBooleanGetTypeID()
        {
            return !boolean.boolValue
        }
        if let number = value as? NSNumber {
            return number.int64Value + 1
        }
        if let string = value as? String {
            return string + "_mutated"
        }
        if var array = value as? [Any] {
            if array.isEmpty {
                array.append("mutated")
            } else {
                array.reverse()
                if array.count == 1 {
                    array.append(array[0])
                }
            }
            return array
        }
        if var object = value as? [String: Any] {
            object["mutated_container_field"] = true
            return object
        }
        return "mutated"
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
            options: [.sortedKeys, .withoutEscapingSlashes])
        XCTAssertThrowsError(
            try Authority.decodeCanonical(data),
            label,
            file: file,
            line: line)
        return data
    }

    private func assertNoncanonicalEncodingsReject(
        _ canonical: Data,
        object: [String: Any]
    ) throws {
        let prefixed = Data(" \n".utf8) + canonical
        XCTAssertThrowsError(try Authority.decodeCanonical(prefixed))

        var suffixed = canonical
        suffixed.append(contentsOf: "\n ".utf8)
        XCTAssertThrowsError(try Authority.decodeCanonical(suffixed))

        let pretty = try JSONSerialization.data(
            withJSONObject: object,
            options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
        XCTAssertThrowsError(try Authority.decodeCanonical(pretty))

        let canonicalString = try XCTUnwrap(
            String(data: canonical, encoding: .utf8))
        let slashEscaped = canonicalString.replacingOccurrences(
            of: "/",
            with: "\\/")
        let slashEscapedData = try XCTUnwrap(
            slashEscaped.data(using: .utf8))
        XCTAssertNotEqual(slashEscapedData, canonical)
        XCTAssertThrowsError(
            try Authority.decodeCanonical(slashEscapedData))

        let reorderedData = try reorderedTopLevelData(object)
        XCTAssertNotEqual(reorderedData, canonical)
        XCTAssertThrowsError(try Authority.decodeCanonical(reorderedData))

        let duplicateData = try duplicateTopLevelFieldData(canonicalString)
        XCTAssertThrowsError(try Authority.decodeCanonical(duplicateData))
    }

    private func reorderedTopLevelData(
        _ object: [String: Any]
    ) throws -> Data {
        let keys = object.keys.sorted().reversed()
        let fragments = try keys.map { key -> String in
            let keyData = try JSONSerialization.data(
                withJSONObject: [key],
                options: [.withoutEscapingSlashes])
            let keyArray = try XCTUnwrap(
                String(data: keyData, encoding: .utf8))
            let encodedKey = String(keyArray.dropFirst().dropLast())
            let valueData = try JSONSerialization.data(
                withJSONObject: [object[key]!],
                options: [.sortedKeys, .withoutEscapingSlashes])
            let valueArray = try XCTUnwrap(
                String(data: valueData, encoding: .utf8))
            let encodedValue = String(valueArray.dropFirst().dropLast())
            return encodedKey + ":" + encodedValue
        }
        return Data(("{" + fragments.joined(separator: ",") + "}").utf8)
    }

    private func duplicateTopLevelFieldData(
        _ canonical: String
    ) throws -> Data {
        let marker = "\"schemaVersion\":1"
        guard canonical.contains(marker) else {
            throw TestHelperError.missingMarker
        }
        let duplicated = canonical.replacingOccurrences(
            of: marker,
            with: marker + "," + marker)
        return Data(duplicated.utf8)
    }

    private enum TestHelperError: Error {
        case missingMarker
    }

    private func requireSendable<T: Sendable>(_: T.Type) {}
}
