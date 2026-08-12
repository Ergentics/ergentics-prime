// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
@testable import PrimeCore
import XCTest

final class
    PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairAuthorityTests:
    XCTestCase
{
    private typealias Authority =
        PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairAuthorityV1

    func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndRepairCeiling()
        throws
    {
        let authority = Authority.frozenV1
        XCTAssertNoThrow(try authority.validate())
        XCTAssertNoThrow(try authority.validateExactV1())
        XCTAssertEqual(authority.schemaVersion, 1)
        XCTAssertEqual(
            authority.authorityID,
            "ergentics_prime_native_decoder_tiny_cpu_train_evaluate_mechanics_default_metallib_bootstrap_fresh_metallib_evidence_surface_repair_authority_v1"
        )
        XCTAssertEqual(
            authority.authorityKind,
            "exact_main_direct_successor_bounded_fresh_metallib_evidence_surface_repair_and_one_replacement_stage2_execution_authority"
        )

        let green = authority.greenPrerequisite
        XCTAssertEqual(green.repository, "Ergentics/ergentics-prime")
        XCTAssertEqual(
            green.mergeRevision,
            "075922cec8361c0085d5b2c6d000828e3c0bfc35")
        XCTAssertEqual(
            green.mergeTree,
            "c6bd910b13796bb12098834c5e7daab83cba8668")
        XCTAssertEqual(
            green.orderedParentRevisions,
            [
                "050c0e4c60df4a1d0bd3dbba1f194f425609cb1b",
                "35726475e1ce8af0ce406148f1a3025b1de1388b",
            ])
        XCTAssertEqual(green.mergedAt, "2026-08-12T03:30:08Z")
        XCTAssertTrue(green.historyPreservingTwoParentMergeObserved)
        XCTAssertTrue(green.mergeTreeEqualsReviewedHeadTree)
        XCTAssertTrue(green.mergeCommitSignatureVerified)
        XCTAssertEqual(green.mergeCommitSignatureReason, "valid")
        XCTAssertEqual(
            green.embeddedSourceIdentitySHA256,
            "dad2151f1481acb742b9c3e885acae2029fc0c83259e2eb2dbe8b48949049956"
        )
        XCTAssertEqual(green.workflowID, 329_017_041)
        XCTAssertEqual(green.runID, 31_560_270_980)
        XCTAssertEqual(green.runNumber, 77)
        XCTAssertEqual(green.runAttempt, 1)
        XCTAssertEqual(green.checkSuiteID, 85_610_747_095)
        XCTAssertEqual(green.exactHeadPushRunCount, 1)
        XCTAssertTrue(green.previousAttemptURLAbsent)
        XCTAssertEqual(green.secondAttemptEndpointHTTPStatus, 404)
        XCTAssertEqual(green.rerunCount, 0)
        XCTAssertEqual(green.runConclusion, "success")
        XCTAssertEqual(green.activeRootJobID, 94_000_965_034)
        XCTAssertEqual(green.activeRootRunnerID, 1_000_001_706)
        XCTAssertEqual(green.reviewedMainJobID, 94_001_351_745)
        XCTAssertEqual(green.reviewedMainRunnerID, 1_000_001_707)
        XCTAssertEqual(green.activeRootCompletedStepCount, 7)
        XCTAssertEqual(green.reviewedMainCompletedStepCount, 7)
        XCTAssertEqual(green.runnerArchitecture, "arm64")
        XCTAssertEqual(green.reviewedRunnerOperatingSystem, "macOS 26.5.2")
        XCTAssertEqual(green.xcodeVersion, "26.6")
        XCTAssertEqual(green.swiftVersion, "6.3.3")

        XCTAssertEqual(
            green.secureFetchWorkflowBlockSHA256,
            "ef783783f50147161e2420fc8be7efd48b42d57ed1ebd79281033ab85ce90847"
        )
        XCTAssertEqual(green.secureFetchCommandCount, 1)
        XCTAssertEqual(green.recursiveSubmoduleUpdateCommandCount, 1)
        XCTAssertEqual(green.workflowAuthoredRetryCount, 0)
        XCTAssertEqual(green.separateSecureFetchRetryStepCount, 0)
        XCTAssertEqual(green.gitInternalSubmoduleRetryScheduledCount, 0)
        XCTAssertEqual(green.mlxSubmoduleCloneAttemptCount, 1)
        XCTAssertEqual(green.mlxCSubmoduleCloneAttemptCount, 1)
        XCTAssertEqual(green.gitSubmoduleTLSFailureCount, 0)
        XCTAssertEqual(green.tlsVerificationBypassCount, 0)
        XCTAssertEqual(green.customCAInstallationCount, 0)
        XCTAssertEqual(
            green.mlxRevision,
            "d37885a278f1c37484a94d0f401a418735e66519")

        XCTAssertEqual(
            [
                green.focusedRootTestCount,
                green.focusedRootFailureCount,
                green.focusedRootSkipCount,
                green.focusedWholeStepTestCount,
                green.focusedWholeStepFailureCount,
                green.focusedWholeStepSkipCount,
            ],
            [42, 0, 0, 48, 0, 0])
        XCTAssertEqual(green.isolatedFocusedGroupTestCounts, [1, 1, 2, 2])
        XCTAssertEqual(
            green.retainedLiveSequence,
            ["metal", "maintained_runtime", "tokenizer"])
        XCTAssertEqual(green.retainedLiveInvocationCounts, [1, 1, 1])
        XCTAssertEqual(green.metallibBuildInvocationCount, 1)
        XCTAssertEqual(green.metallibBuildCompletionCount, 1)
        XCTAssertEqual(green.metallibByteCount, 6_292_652)
        XCTAssertEqual(
            green.metallibSHA256,
            "026a9cb2e57091ea50d51f037ec94735d04941d4115adc567dace16d629c65b7"
        )
        XCTAssertEqual(
            [
                green.metalTestCount,
                green.metalFailureCount,
                green.metalSkipCount,
                green.runtimeTestCount,
                green.runtimeFailureCount,
                green.runtimeSkipCount,
                green.tokenizerTestCount,
                green.tokenizerFailureCount,
                green.tokenizerSkipCount,
                green.preStage2CompletedTestCount,
                green.preStage2FailureCount,
                green.preStage2SkipCount,
            ],
            [44, 0, 0, 1, 0, 0, 1, 0, 0, 94, 0, 0])
        XCTAssertEqual(green.runtimeReceipt.count, 1)
        XCTAssertEqual(green.tokenizerReceipt.count, 1)
        XCTAssertEqual(
            green.runtimeReceipt.metallibSHA256,
            green.metallibSHA256)
        XCTAssertEqual(
            green.tokenizerReceipt.metallibSHA256,
            green.metallibSHA256)
        XCTAssertEqual(green.tokenizerReceipt.executedRevision, green.mergeRevision)
        XCTAssertEqual(green.tokenizerReceipt.executedTree, green.mergeTree)
        XCTAssertEqual(
            green.tokenizerReceipt.executedEmbeddedSourceIdentitySHA256,
            green.embeddedSourceIdentitySHA256)
        XCTAssertEqual(
            [
                green.stage2LauncherInvocationCount,
                green.stage2BuildInvocationCount,
                green.stage2MetallibCopyCount,
                green.stage2DirectXCTestInvocationCount,
                green.stage2TestStartCount,
                green.stage2TestPassCount,
                green.stage2TestFailureCount,
                green.stage2TestSkipCount,
                green.stage2ReceiptCount,
                green.actionsArtifactsTotalCount,
            ],
            Array(repeating: 0, count: 10))
        XCTAssertTrue(green.actionsArtifactsArrayExactlyEmpty)
        XCTAssertEqual(green.runLogArchiveByteCount, 1_344_159)
        XCTAssertEqual(green.runLogArchiveMemberCount, 18)
        XCTAssertEqual(green.runLogArchiveUncompressedByteCount, 20_983_497)
        XCTAssertEqual(
            green.runLogArchiveSHA256,
            "8112ede2cb0c1caaa325495a55481e7b6f15491c3919a0013ab11a6dfc038ef3"
        )
        XCTAssertEqual(green.rawLogs.count, 5)
        XCTAssertTrue(green.rawLogs.allSatisfy(\.startsWithUTF8BOM))
        XCTAssertTrue(green.rawLogs.allSatisfy(\.usesLFOnly))
        XCTAssertTrue(green.rawLogs.allSatisfy(\.endsWithLF))
        XCTAssertTrue(green.exactGreenPrerequisiteSatisfied)

        let consumed = authority.consumedFailure
        XCTAssertEqual(
            consumed.failureObservationID,
            PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibCrossBindingExecutionFailureObservationV1
                .frozenV1.observationID)
        XCTAssertEqual(
            consumed.failureObservationCanonicalSHA256,
            "6c0f9a82ff61e30abc9122faca47fdace203deecd464431d41fd84d0709d382f"
        )
        XCTAssertEqual(consumed.exhaustedRunID, 31_555_440_908)
        XCTAssertEqual(consumed.exhaustedRunAttempt, 1)
        XCTAssertEqual(
            consumed.failedLauncherGitBlob,
            "45fc1f82ecfe14a6a9e98c345706f75b37c2d1cb")
        XCTAssertEqual(consumed.failedLauncherByteCount, 44_691)
        XCTAssertEqual(
            consumed.failedLauncherSHA256,
            "3b8a0790b521de9c6ca03760aef8e9bbece4d46f6d1f8505dae44fc9a559d185"
        )
        XCTAssertEqual(
            consumed.failureClassification,
            "deterministic_evidence_capture_scope_mismatch_after_fresh_metallib_discovery_no_identity_divergence"
        )
        XCTAssertEqual(consumed.aggregateMetalIdentityCount, 1)
        XCTAssertEqual(consumed.metalXCTestLogIdentityCount, 0)
        XCTAssertTrue(consumed.runtimeReceiptMetallibIdentityMatched)
        XCTAssertTrue(consumed.tokenizerReceiptMetallibIdentityMatched)
        XCTAssertFalse(consumed.metallibIdentityDivergenceObserved)
        XCTAssertEqual(consumed.stage2FreshMetallibDiscoveryCount, 1)
        XCTAssertEqual(
            [
                consumed.stage2BuildInvocationCount,
                consumed.stage2MetallibCopyCount,
                consumed.stage2DirectXCTestInvocationCount,
                consumed.stage2TestStartCount,
                consumed.stage2TestPassCount,
                consumed.stage2TestFailureCount,
                consumed.stage2TestSkipCount,
                consumed.stage2ReceiptCount,
            ],
            Array(repeating: 0, count: 8))
        XCTAssertTrue(consumed.predecessorExecutionAuthorityConsumed)
        XCTAssertTrue(consumed.predecessorExecutionAuthorityExhausted)
        XCTAssertFalse(consumed.failedRunRecoverable)
        XCTAssertTrue(consumed.consumedLiveInvocationRetired)
        XCTAssertTrue(consumed.launcherSourcePreservedForAudit)
        XCTAssertTrue(consumed.distinctRepairAuthorityRequired)

        let bindings = authority.observedBaseSourceBindings
        XCTAssertEqual(bindings.count, 16)
        XCTAssertEqual(Set(bindings.map(\.path)).count, 16)
        XCTAssertTrue(bindings.allSatisfy { $0.gitBlob.count == 40 })
        XCTAssertTrue(bindings.allSatisfy { $0.sha256.count == 64 })
        XCTAssertTrue(bindings.allSatisfy { $0.byteCount > 0 })
        XCTAssertTrue(
            bindings.allSatisfy {
                $0.gitMode == "100644" || $0.gitMode == "100755"
            })

        let design = authority.repairDesign
        XCTAssertEqual(design.authorizedBaseRevision, green.mergeRevision)
        XCTAssertEqual(design.authorizedBaseTree, green.mergeTree)
        XCTAssertEqual(design.requiredExecutionCommitParentCount, 2)
        XCTAssertEqual(design.requiredFirstParentRevision, green.mergeRevision)
        XCTAssertTrue(design.executionMergeTreeMustEqualSecondParentTree)
        XCTAssertEqual(design.activeRootCheckoutFetchDepth, 1)
        XCTAssertEqual(design.reviewedMainCheckoutFetchDepth, 2)
        XCTAssertEqual(
            design.exactDirectSuccessorChangedPaths,
            [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/scripts/prime-ci-native-decoder-stage2-metallib-bootstrap-repair.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                "Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairAuthority.swift",
                "Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairAuthorityTests.swift",
            ])
        XCTAssertEqual(
            design.exactDirectSuccessorChangedStatuses,
            ["M", "M", "M", "M", "A", "A"])
        XCTAssertEqual(design.launcherNetworkFetchCommandCount, 0)
        XCTAssertEqual(
            design.receiptPrefix,
            "PRIME_NATIVE_DECODER_STAGE2_METALLIB_BOOTSTRAP_FRESH_METALLIB_EVIDENCE_SURFACE_REPAIR_RECEIPT="
        )
        XCTAssertEqual(
            design.receiptID,
            "ergentics_prime_native_decoder_stage2_metallib_bootstrap_fresh_metallib_evidence_surface_repair_receipt_v1"
        )
        XCTAssertEqual(
            design.receiptStatus,
            "PASS_exact_main_stage2_same_job_fresh_metallib_evidence_surface_repair_one_test_zero_failure_zero_skip"
        )
        XCTAssertEqual(design.impossibleMetalXCTestIdentityGrepRemovalCount, 1)
        XCTAssertEqual(
            design.metalFullOutputLogRelativeToRunnerTemp,
            "prime-native-decoder-metal-full-output.log")
        XCTAssertTrue(design.metalFullOutputLogCaptureAdded)
        XCTAssertEqual(design.metalFullOutputLogCaptureInvocationCount, 1)
        XCTAssertEqual(design.metalFullOutputLogTeeInvocationCount, 1)
        XCTAssertTrue(design.metalFullOutputLogInitialAbsenceRequired)
        XCTAssertTrue(design.metalFullOutputLogRegularFileRequired)
        XCTAssertTrue(design.metalFullOutputLogSymbolicLinkForbidden)
        XCTAssertEqual(design.metalFullOutputLogRequiredHardLinkCount, 1)
        XCTAssertEqual(design.requiredMetalLauncherPipeStatus, 0)
        XCTAssertEqual(design.requiredMetalFullOutputTeePipeStatus, 0)
        XCTAssertTrue(design.metalLauncherExitAndTeeExitValidated)
        XCTAssertEqual(design.metalFullOutputLogIdentityPrefixCount, 1)
        XCTAssertEqual(design.metalFullOutputLogFreshIdentityCount, 1)
        XCTAssertEqual(design.metalXCTestLogIdentityPrefixCount, 0)
        XCTAssertEqual(design.metalXCTestLogFreshIdentityCount, 0)
        XCTAssertFalse(design.metalLauncherSourceChanged)
        XCTAssertEqual(design.metalLauncherMutationCount, 0)
        XCTAssertEqual(design.predecessorLogClassifierMutationCount, 0)
        XCTAssertEqual(
            [
                design.requiredPredecessorLogCount,
                design.requiredClassifierScannedLogCount,
                design.classifierAcceptedFixtureCount,
                design.classifierRejectedFixtureCount,
                design.requiredPredecessorReceiptCount,
            ],
            [11, 8, 8, 5, 2])
        XCTAssertEqual(
            [
                design.requiredFocusedRootTestCount,
                design.requiredFocusedIsolatedTestCount,
                design.requiredFocusedWholeStepTestCount,
                design.requiredMetalTestCount,
                design.requiredRuntimeTestCount,
                design.requiredTokenizerTestCount,
                design.requiredPreStage2CompletedTestCount,
                design.requiredTrustedCompletedTestCount,
            ],
            [43, 6, 49, 44, 1, 1, 95, 96])
        XCTAssertEqual(design.freshSourceCandidateCount, 1)
        XCTAssertTrue(design.freshSourceFileIdentityValidated)
        XCTAssertEqual(design.requiredMetallibIdentityInventoryCount, 5)
        XCTAssertEqual(design.requiredMetalBundleCandidateCount, 2)
        XCTAssertEqual(design.metalBundleByteIdentityMatchCount, 2)
        XCTAssertEqual(design.requiredRuntimeBundleCandidateCount, 1)
        XCTAssertEqual(design.requiredTokenizerBundleCandidateCount, 1)
        XCTAssertEqual(design.requiredByteIdenticalComparisonCount, 5)
        XCTAssertEqual(design.requiredByteCountEqualityCount, 5)
        XCTAssertEqual(design.requiredSHA256EqualityCount, 5)
        XCTAssertTrue(design.metalXCTestLogStillRequiredForExact44GreenTests)
        XCTAssertFalse(design.metalXCTestLogRequiredToContainAggregateIdentityLine)
        XCTAssertEqual(design.runtimeReceiptCount, 1)
        XCTAssertEqual(design.runtimeReceiptIdentityMatchCount, 1)
        XCTAssertEqual(design.tokenizerReceiptCount, 1)
        XCTAssertEqual(design.tokenizerReceiptIdentityMatchCount, 1)
        XCTAssertTrue(design.receiptIdentityCrossBindingEstablished)
        XCTAssertFalse(design.loadedMetallibPathInferred)
        XCTAssertEqual(design.predecessorArtifactSnapshotCount, 16)
        XCTAssertEqual(design.predecessorArtifactRevalidationCountAfterXCTest, 16)
        XCTAssertEqual(design.swiftBuildInvocationCount, 1)
        XCTAssertEqual(design.stagedMetallibCopyCount, 2)
        XCTAssertEqual(design.stagedMetallibPermissionMode, "444")
        XCTAssertEqual(design.directXCTestInvocationCount, 1)
        XCTAssertEqual(design.rebuildAfterStagingInvocationCount, 0)
        XCTAssertEqual(
            [
                design.requiredStage2TestCount,
                design.requiredStage2FailureCount,
                design.requiredStage2SkipCount,
            ],
            [1, 0, 0])
        XCTAssertTrue(design.oneDistinctExecutionAttemptAuthorized)
        XCTAssertTrue(design.githubRunAttemptMustEqualOne)
        XCTAssertTrue(design.successorOutcomeMustRetireLiveInvocation)

        XCTAssertTrue(authority.exactGreenPrerequisiteConsumed)
        XCTAssertTrue(authority.failureObservationConsumedWithoutRecovery)
        XCTAssertTrue(authority.boundedEvidenceSurfaceRepairAuthorized)
        XCTAssertTrue(authority.impossibleMetalXCTestLogBindingRemovalAuthorized)
        XCTAssertTrue(authority.fixedMetalFullOutputLogCaptureAuthorized)
        XCTAssertTrue(authority.mechanicalLauncherGateWorkflowAndProvenancePinsAuthorized)
        XCTAssertTrue(authority.sameJobFreshMetallibConsumptionAuthorized)
        XCTAssertTrue(authority.exactReceiptCrossBindingAuthorized)
        XCTAssertTrue(authority.twoCopyMetallibStagingAuthorized)
        XCTAssertTrue(authority.directBuiltXCTestExecutionAuthorized)
        XCTAssertTrue(authority.exactOneDirectSuccessorAttemptAuthorized)
        XCTAssertTrue(falseClaims(authority.authorityCeiling).allSatisfy { !$0 })
        XCTAssertEqual(authority.orderedRequiredActions.count, 8)

        try assertPureFoundationSourceAndSingleTestMethod()
        requireSendable(Authority.self)
        let canonical = try authority.canonicalData()
        XCTAssertEqual(canonical, try PrimeCanonicalJSON.encode(authority))
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: canonical),
            "bc6aa0630196e1c02814834ffb3f8502ae51bcdc751ecbc37cb9bb5dd22c502a")
        let decoded = try Authority.decodeCanonical(canonical)
        XCTAssertEqual(decoded, authority)
        XCTAssertEqual(try decoded.canonicalData(), canonical)
        XCTAssertNoThrow(try decoded.validateExactV1())

        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical) as? [String: Any])
        let valuePaths = allValuePaths(in: object)
        let dictionaryPaths = allDictionaryPaths(in: object)
        let scalarPaths = allScalarPaths(in: object)
        XCTAssertGreaterThan(valuePaths.count, 300)
        XCTAssertGreaterThan(dictionaryPaths.count, 20)
        XCTAssertGreaterThan(scalarPaths.count, 225)

        var regularDecodedDriftCount = 0
        var mutationCount = 0
        var nullCount = 0
        var removalCount = 0
        for path in valuePaths {
            let mutationData = try assertCanonicalRejects(
                replacingValue(
                    in: object,
                    at: path,
                    with: mutateJSONValue),
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
                        "unknown_fresh_metallib_evidence_surface_repair_field_\(index)"
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

    private func assertPureFoundationSourceAndSingleTestMethod() throws {
        let testURL = URL(fileURLWithPath: #filePath)
        let repositoryRoot = testURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let sourceURL = repositoryRoot.appendingPathComponent(
            "Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairAuthority.swift"
        )
        let sourceText = try String(contentsOf: sourceURL, encoding: .utf8)
        let importLines = sourceText.split(separator: "\n")
            .map(String.init)
            .filter { $0.hasPrefix("import ") }
        XCTAssertEqual(importLines, ["import Foundation"])
        for forbidden in [
            "Process(", "FileManager.", "URLSession", "NSWorkspace",
            "import Metal", "import MLX", "import Darwin", "import Glibc",
        ] {
            XCTAssertFalse(sourceText.contains(forbidden), forbidden)
        }

        let testText = try String(contentsOf: testURL, encoding: .utf8)
        XCTAssertEqual(
            testText.components(separatedBy: "func " + "test").count - 1,
            1)
    }

    private func falseClaims(
        _ ceiling:
            PrimeNativeDecoderStage2FreshMetallibEvidenceSurfaceRepairCeilingV1
    ) -> [Bool] {
        [
            ceiling.failureObservationMutationAuthorized,
            ceiling.predecessorAuthorityMutationAuthorized,
            ceiling.metalLauncherMutationAuthorized,
            ceiling.runtimeLauncherMutationAuthorized,
            ceiling.tokenizerLauncherMutationAuthorized,
            ceiling.productionTrainingSourceMutationAuthorized,
            ceiling.validationManifestMutationAuthorized,
            ceiling.validationLockMutationAuthorized,
            ceiling.validationTestMutationAuthorized,
            ceiling.secureFetchMutationAuthorized,
            ceiling.additionalLogCaptureBeyondFixedMetalFullOutputAuthorized,
            ceiling.tlsVerificationBypassAuthorized,
            ceiling.customCAInstallationAuthorized,
            ceiling.workflowAuthoredRetryAuthorized,
            ceiling.gitInternalRetryBehaviorMutationAuthorized,
            ceiling.rerunAuthorized,
            ceiling.failedRunRecoveryAuthorized,
            ceiling.newMetallibBuildAuthorized,
            ceiling.xcodebuildAuthorizedInRepairLauncher,
            ceiling.swiftTestAuthorizedInRepairLauncher,
            ceiling.postStagingRebuildAuthorized,
            ceiling.networkFetchAuthorizedInRepairLauncher,
            ceiling.additionalStage2AttemptBeyondOneAuthorized,
            ceiling.repairImplementationObservedByThisAuthority,
            ceiling.repairExecutionObservedByThisAuthority,
            ceiling.stage2SuccessEstablished,
            ceiling.checkpointReadAuthorized,
            ceiling.checkpointWriteAuthorized,
            ceiling.checkpointArtifactAuthorized,
            ceiling.checkpointArtifactUploadAuthorized,
            ceiling.checkpointResumeAuthorized,
            ceiling.native300MAllocationAuthorized,
            ceiling.native300MTrainingAuthorized,
            ceiling.trainingResumeAuthorized,
            ceiling.trajectoryExactResumeAuthorized,
            ceiling.modelQualityEstablished,
            ceiling.candidateAdmissionGranted,
            ceiling.trialAuthorized,
            ceiling.canaryReplacementAuthorized,
            ceiling.quantizationAuthorized,
            ceiling.productUseAuthorized,
            ceiling.publicationAuthorized,
            ceiling.stage3AuthorityEstablished,
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
        XCTAssertThrowsError(try Authority.decodeCanonical(slashEscapedData))

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
