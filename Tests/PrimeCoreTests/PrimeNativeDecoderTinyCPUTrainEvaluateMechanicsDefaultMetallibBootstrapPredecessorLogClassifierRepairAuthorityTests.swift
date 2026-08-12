// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
@testable import PrimeCore
import XCTest

final class
    PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapPredecessorLogClassifierRepairAuthorityTests:
    XCTestCase
{
    private typealias Authority =
        PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapPredecessorLogClassifierRepairAuthorityV1

    func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndRepairCeiling()
        throws
    {
        let authority = Authority.frozenV1
        XCTAssertNoThrow(try authority.validate())
        XCTAssertNoThrow(try authority.validateExactV1())
        XCTAssertEqual(authority.schemaVersion, 1)
        XCTAssertEqual(
            authority.authorityID,
            "ergentics_prime_native_decoder_tiny_cpu_train_evaluate_mechanics_default_metallib_bootstrap_predecessor_log_classifier_repair_authority_v1"
        )
        XCTAssertEqual(
            authority.authorityKind,
            "exact_main_direct_successor_bounded_predecessor_log_classifier_repair_and_one_replacement_stage2_execution_authority"
        )

        let green = authority.greenPrerequisite
        XCTAssertEqual(green.repository, "Ergentics/ergentics-prime")
        XCTAssertEqual(
            green.mergeRevision,
            "775b247fb8c1f0e3c28d01fce281d8d29bbb4dd1")
        XCTAssertEqual(
            green.mergeTree,
            "817405a8710ad24245721689e7a6736c55a0b06c")
        XCTAssertEqual(
            green.orderedParentRevisions,
            [
                "6b5233ae0589de539e91f613e7990de3ca5b5833",
                "0dde0f2e3cd3e87e46c864782b0f42dfe2e2d86b",
            ])
        XCTAssertTrue(green.historyPreservingTwoParentMergeObserved)
        XCTAssertTrue(green.mergeTreeEqualsReviewedHeadTree)
        XCTAssertEqual(green.workflowID, 329_017_041)
        XCTAssertEqual(green.runID, 31_550_007_242)
        XCTAssertEqual(green.runNumber, 73)
        XCTAssertEqual(green.runAttempt, 1)
        XCTAssertEqual(green.checkSuiteID, 85_584_105_952)
        XCTAssertTrue(green.previousAttemptURLAbsent)
        XCTAssertEqual(green.exactHeadPushRunCount, 1)
        XCTAssertEqual(green.secondAttemptEndpointHTTPStatus, 404)
        XCTAssertEqual(green.rerunCount, 0)
        XCTAssertFalse(green.rerunObserved)
        XCTAssertEqual(green.runCreatedAt, "2026-08-12T00:23:17Z")
        XCTAssertEqual(green.runStartedAt, "2026-08-12T00:23:17Z")
        XCTAssertEqual(green.runUpdatedAt, "2026-08-12T01:08:57Z")
        XCTAssertEqual(green.runStatus, "completed")
        XCTAssertEqual(green.runConclusion, "success")
        XCTAssertEqual(green.activeRootJobID, 93_970_479_466)
        XCTAssertEqual(green.activeRootRunnerID, 1_000_001_700)
        XCTAssertEqual(green.activeRootStartedAt, "2026-08-12T00:23:22Z")
        XCTAssertEqual(green.activeRootCompletedAt, "2026-08-12T00:26:30Z")
        XCTAssertEqual(green.activeRootConclusion, "success")
        XCTAssertEqual(green.activeRootCompletedStepCount, 7)
        XCTAssertEqual(green.activeRootRunnerLabel, "macos-15")
        XCTAssertEqual(green.reviewedMainJobID, 93_971_547_565)
        XCTAssertEqual(green.reviewedMainRunnerID, 1_000_001_701)
        XCTAssertEqual(green.reviewedMainStartedAt, "2026-08-12T00:29:33Z")
        XCTAssertEqual(green.reviewedMainCompletedAt, "2026-08-12T01:08:57Z")
        XCTAssertEqual(green.reviewedMainConclusion, "success")
        XCTAssertEqual(green.reviewedMainCompletedStepCount, 7)
        XCTAssertEqual(green.reviewedMainRunnerLabel, "macos-26")
        XCTAssertEqual(green.runnerArchitecture, "arm64")
        XCTAssertEqual(green.reviewedRunnerOperatingSystem, "macOS 26.5.2")
        XCTAssertEqual(green.xcodeVersion, "26.6")
        XCTAssertEqual(green.xcodeBuildVersion, "17F113")
        XCTAssertEqual(green.swiftVersion, "6.3.3")
        XCTAssertEqual(green.swiftTarget, "arm64-apple-macosx26.0")
        XCTAssertEqual(green.sdkVersion, "26.5")

        XCTAssertEqual(green.secureFetchWorkflowStepCount, 1)
        XCTAssertEqual(green.secureFetchWorkflowStepCompletionCount, 1)
        XCTAssertEqual(green.privateDependencyFetchCommandCount, 1)
        XCTAssertEqual(green.recursiveSubmoduleUpdateCommandCount, 1)
        XCTAssertEqual(green.workflowAuthoredRetryCount, 0)
        XCTAssertEqual(green.separateSecureFetchRetryStepCount, 0)
        XCTAssertEqual(green.gitInternalSubmoduleRetryScheduledCount, 1)
        XCTAssertEqual(green.mlxSubmoduleCloneAttemptCount, 2)
        XCTAssertEqual(green.mlxCSubmoduleCloneAttemptCount, 1)
        XCTAssertEqual(green.gitSubmoduleTLSFailureCount, 1)
        XCTAssertEqual(
            green.initialFailedSubmoduleURL,
            "https://github.com/ml-explore/mlx/")
        XCTAssertEqual(
            green.exactTLSDiagnostic,
            "fatal: unable to access 'https://github.com/ml-explore/mlx/': SSL certificate problem: self signed certificate"
        )
        XCTAssertEqual(
            green.exactGitInternalRetryDiagnostic,
            "Failed to clone 'Source/Cmlx/mlx'. Retry scheduled")
        XCTAssertTrue(green.eventualPinnedSubmoduleCheckoutCompleted)
        XCTAssertEqual(
            green.secureFetchWorkflowBlockSHA256,
            "ef783783f50147161e2420fc8be7efd48b42d57ed1ebd79281033ab85ce90847"
        )
        XCTAssertEqual(green.tlsVerificationBypassCount, 0)
        XCTAssertEqual(green.customCAInstallationCount, 0)
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
            [40, 0, 0, 46, 0, 0])
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
            "79d9760782ab6cc86028be1ec62b93106a146650f7c3121467121875a97de1cc"
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
            [44, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1])
        XCTAssertTrue(green.repairedMetalAuthorityTestPassed)
        XCTAssertEqual(green.tokenizerBoundRevision, green.mergeRevision)
        XCTAssertEqual(green.tokenizerBoundTree, green.mergeTree)
        XCTAssertEqual(
            green.tokenizerBoundEmbeddedSourceIdentitySHA256,
            "4c893cdf9dbc51cd8d16fb24d4d0c24992eb84217d4a2206072ac67ea7b0313f"
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
        XCTAssertEqual(green.runLogArchiveByteCount, 1_346_320)
        XCTAssertEqual(green.runLogArchiveMemberCount, 18)
        XCTAssertEqual(green.runLogArchiveUncompressedByteCount, 20_969_927)
        XCTAssertEqual(
            green.runLogArchiveSHA256,
            "fe29e04c59fef1c6e494bb608b0ebff835bddafdd974e2f7a8ad361e542bc888"
        )
        XCTAssertEqual(
            [
                green.activeJobLogByteCount,
                green.activeJobLogLFByteCount,
                green.reviewedJobLogByteCount,
                green.reviewedJobLogLFByteCount,
                green.focusedStepLogByteCount,
                green.focusedStepLogLFByteCount,
                green.liveStepLogByteCount,
                green.liveStepLogLFByteCount,
                green.secureFetchStepLogByteCount,
                green.secureFetchStepLogLFByteCount,
            ],
            [
                235_436, 1_751,
                10_248_809, 78_458,
                347_205, 3_369,
                9_889_931, 74_942,
                5_510, 59,
            ])
        XCTAssertTrue(green.exactGreenPrerequisiteSatisfied)
        XCTAssertFalse(green.stage2BootstrapRepairObservedInPrerequisite)

        let consumed = authority.failureConsumption
        XCTAssertEqual(
            consumed.failureObservationID,
            PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairExecutionFailureObservationV1
                .frozenV1.observationID)
        XCTAssertEqual(
            consumed.failureObservationCanonicalSHA256,
            "2184710f59bc2b4625bb0a74f5f835c859fada79406ffc957b5ffca4861a9926"
        )
        XCTAssertEqual(consumed.exhaustedRunID, 31_544_702_133)
        XCTAssertEqual(consumed.exhaustedRunAttempt, 1)
        XCTAssertEqual(
            consumed.failureClassification,
            "predecessor_log_validation_false_positive_after_green_predecessors_before_stage2_metallib_discovery_or_build"
        )
        XCTAssertEqual(
            consumed.failedLauncherPath,
            ".github/scripts/prime-ci-native-decoder-stage2-metallib-bootstrap-repair.sh"
        )
        XCTAssertEqual(
            consumed.failedLauncherGitBlob,
            "fd339c3819059050dcd31112023e169e22f9fbac")
        XCTAssertEqual(consumed.failedLauncherByteCount, 40_231)
        XCTAssertEqual(
            consumed.failedLauncherSHA256,
            "a7d363ebe108aedaed1a83bc79429e87e60f5a1f9d3b992704b5a4617add9367"
        )
        XCTAssertEqual(consumed.failedLauncherInvocationCount, 1)
        XCTAssertEqual(
            consumed.retiredCaseInsensitiveRegex,
            "^Test (Case|Suite).*failed|^error:|skipped|Test skipped")
        XCTAssertEqual(
            consumed.passingTestIdentifier,
            "testFailedAttemptObservationIsExactExhaustedAndPure")
        XCTAssertEqual(consumed.predecessorLogInventoryCount, 10)
        XCTAssertEqual(consumed.predecessorReceiptCount, 2)
        XCTAssertTrue(consumed.predecessorTestsPassed)
        XCTAssertTrue(consumed.sameJobFreshMetallibAvailable)
        XCTAssertFalse(consumed.sameJobFreshMetallibInspectedByFailedLauncher)
        XCTAssertEqual(
            [
                consumed.stage2BuildInvocationCount,
                consumed.stage2MetallibCopyCount,
                consumed.stage2DirectXCTestInvocationCount,
                consumed.stage2TestStartCount,
                consumed.stage2TestPassCount,
                consumed.stage2TestFailureCount,
                consumed.stage2TestSkipCount,
                consumed.stage2RepairReceiptCount,
            ],
            Array(repeating: 0, count: 8))
        XCTAssertFalse(consumed.predecessorTestFailureObserved)
        XCTAssertFalse(consumed.stage2MechanicsFailureObserved)
        XCTAssertTrue(consumed.predecessorExecutionAttemptConsumed)
        XCTAssertTrue(consumed.predecessorExecutionAuthorityExhausted)
        XCTAssertFalse(consumed.failedAttemptRecoverable)
        XCTAssertFalse(consumed.failedInvocationRemainsLive)
        XCTAssertTrue(consumed.exhaustedScratchPathsRemainRetired)
        XCTAssertTrue(consumed.exhaustedLogPathRemainsRetired)
        XCTAssertFalse(consumed.rerunAuthorized)
        XCTAssertTrue(consumed.distinctRepairRequired)

        let bindings = authority.observedBaseSourceBindings
        XCTAssertEqual(bindings.count, 21)
        XCTAssertEqual(Set(bindings.map(\.path)).count, 21)
        XCTAssertEqual(bindings.first?.path, "Package.swift")
        XCTAssertEqual(
            bindings.last?.path,
            ".github/workflows/prime-active-root-quarantine.yml")
        XCTAssertTrue(
            bindings.allSatisfy {
                $0.gitMode == "100644" || $0.gitMode == "100755"
            })
        XCTAssertTrue(bindings.allSatisfy { $0.byteCount > 0 })
        XCTAssertTrue(bindings.allSatisfy { $0.gitBlob.count == 40 })
        XCTAssertTrue(bindings.allSatisfy { $0.sha256.count == 64 })

        let classifier = authority.classifierRepair
        XCTAssertEqual(classifier.classifierCommand, "grep -Eq")
        XCTAssertTrue(classifier.matchingIsCaseSensitive)
        XCTAssertTrue(
            classifier
                .quotedXCTestCaseAndSuiteOutcomeMarkersRequireClosedIdentity)
        XCTAssertEqual(
            classifier.exactFailureOrSkipPatterns,
            [
                "^Test Case '[^']+' failed \\(",
                "^Test Suite '[^']+' failed at ",
                "^error:",
                "^Test Case '[^']+' skipped \\(",
                " : Test skipped - ",
            ])
        XCTAssertEqual(classifier.exactPassingRegressionFixtures.count, 8)
        XCTAssertEqual(classifier.exactRejectingRegressionFixtures.count, 5)
        XCTAssertEqual(classifier.passingFixtureMatchCount, 0)
        XCTAssertEqual(classifier.rejectingFixtureMatchCount, 5)
        for fixture in classifier.exactPassingRegressionFixtures {
            XCTAssertFalse(
                try classifierMatches(fixture, patterns: classifier.exactFailureOrSkipPatterns),
                fixture)
        }
        for fixture in classifier.exactRejectingRegressionFixtures {
            XCTAssertTrue(
                try classifierMatches(fixture, patterns: classifier.exactFailureOrSkipPatterns),
                fixture)
        }
        XCTAssertEqual(classifier.requiredPredecessorLogCount, 10)
        XCTAssertEqual(classifier.requiredPredecessorReceiptCount, 2)
        XCTAssertEqual(
            [
                classifier.requiredRootTestCount,
                classifier.requiredFocusedIsolatedTestCount,
                classifier.requiredFocusedWholeStepTestCount,
                classifier.requiredMetalTestCount,
                classifier.requiredRuntimeTestCount,
                classifier.requiredTokenizerTestCount,
                classifier.requiredPreStage2CompletedTestCount,
            ],
            [41, 6, 47, 44, 1, 1, 93])

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
                "Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapPredecessorLogClassifierRepairAuthority.swift",
                "Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapPredecessorLogClassifierRepairAuthorityTests.swift",
            ])
        XCTAssertEqual(
            recipe.receiptPrefix,
            "PRIME_NATIVE_DECODER_STAGE2_METALLIB_BOOTSTRAP_PREDECESSOR_LOG_CLASSIFIER_REPAIR_RECEIPT="
        )
        XCTAssertEqual(
            recipe.receiptID,
            "ergentics_prime_native_decoder_stage2_metallib_bootstrap_predecessor_log_classifier_repair_receipt_v1"
        )
        XCTAssertEqual(
            recipe.receiptStatus,
            "PASS_exact_main_stage2_same_job_fresh_metallib_bootstrap_predecessor_log_classifier_repair_one_test_zero_failure_zero_skip"
        )
        XCTAssertEqual(
            recipe.launcherInvocation,
            "bash .github/scripts/prime-ci-native-decoder-stage2-metallib-bootstrap-repair.sh"
        )
        XCTAssertEqual(
            recipe.validationPackagePath,
            "Tests/PrimeNativeDecoderTrainingValidation")
        XCTAssertEqual(recipe.stage2TestClass, "PrimeNativeDecoderTrainingTests")
        XCTAssertEqual(
            recipe.stage2TestMethod,
            "testTinyCPUTrainEvaluateMechanicsAreExactAndFailClosed")
        XCTAssertEqual(recipe.requiredExclusiveMLXEnvironment, ["MLX_ENABLE_TF32": "0"])
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
        XCTAssertTrue(authority.boundedPredecessorLogClassifierRepairAuthorized)
        XCTAssertTrue(authority.classifierMechanicalPinUpdatesAuthorized)
        XCTAssertTrue(authority.sameJobFreshMetallibConsumptionAuthorized)
        XCTAssertTrue(authority.twoCopyMetallibStagingAuthorized)
        XCTAssertTrue(authority.directBuiltXCTestExecutionAuthorized)
        XCTAssertTrue(authority.exactOneDirectSuccessorAttemptAuthorized)
        XCTAssertFalse(authority.repairImplementationObservedByThisAuthority)
        XCTAssertFalse(authority.repairExecutionObservedByThisAuthority)
        XCTAssertTrue(falseClaims(authority.authorityCeiling).allSatisfy { !$0 })
        XCTAssertEqual(authority.orderedRequiredActions.count, 7)
        XCTAssertEqual(
            authority.orderedRequiredActions.last,
            "retire_that_live_invocation_in_a_separate_outcome_observation_and_keep_stage3_blocked"
        )

        requireSendable(Authority.self)
        let canonical = try authority.canonicalData()
        XCTAssertEqual(canonical, try PrimeCanonicalJSON.encode(authority))
        let canonicalHash = PrimeSHA256.hexDigest(of: canonical)
        XCTAssertEqual(
            canonicalHash,
            "9c94ceeca77c3fc5173adfa41f9965d33c3a78f8d975b639dd3dc0aa2c2ed99b")
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
                        "unknown_stage2_predecessor_log_classifier_repair_field_\(index)"
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

    private func classifierMatches(
        _ line: String,
        patterns: [String]
    ) throws -> Bool {
        let range = NSRange(line.startIndex..<line.endIndex, in: line)
        for pattern in patterns {
            let expression = try NSRegularExpression(pattern: pattern)
            if expression.firstMatch(in: line, range: range) != nil {
                return true
            }
        }
        return false
    }

    private func falseClaims(
        _ ceiling:
            PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapPredecessorLogClassifierRepairCeilingV1
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
            ceiling.workflowAuthoredRetryAuthorized,
            ceiling.gitInternalRetryBehaviorMutationAuthorized,
            ceiling.rerunAuthorized,
            ceiling.failedRunRecoveryAuthorized,
            ceiling.additionalMetallibBuildAuthorized,
            ceiling.xcodebuildAuthorizedInRepairLauncher,
            ceiling.swiftTestAuthorizedInRepairLauncher,
            ceiling.postStagingRebuildAuthorized,
            ceiling.networkFetchAuthorizedInRepairLauncher,
            ceiling.additionalStage2AttemptBeyondOneReplacementAuthorized,
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
