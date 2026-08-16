// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
import XCTest
@testable import PrimeCore

final class PrimeSecureChildProcessEvidenceClosedFixtureCanaryAuthorityTests:
    XCTestCase
{
    func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndAuthorityCeiling()
        throws
    {
        typealias Authority =
            PrimeSecureChildProcessEvidenceClosedFixtureCanaryAuthorityV1
        let authority = Authority.frozenV1

        XCTAssertEqual(authority.schemaVersion, 1)
        XCTAssertEqual(
            authority.schemaID,
            "prime_secure_child_process_evidence_closed_fixture_canary_authority_schema_v1")
        XCTAssertEqual(
            authority.authorityID,
            "prime_secure_child_process_evidence_closed_fixture_canary_authority_v1")
        XCTAssertEqual(
            authority.authorityKind,
            "pure_exact5_authority_for_one_later_closed_fixture_canary_after_green_layer_a")

        let predecessor = authority.implementationAuthorityPredecessor
        XCTAssertEqual(
            predecessor.authorityID,
            PrimeSecureChildProcessEvidenceImplementationAuthorityV1
                .frozenV1.authorityID)
        XCTAssertEqual(
            predecessor.canonicalByteCount,
            PrimeSecureChildProcessEvidenceImplementationAuthorityV1
                .canonicalByteCount)
        XCTAssertEqual(
            predecessor.canonicalSHA256,
            PrimeSecureChildProcessEvidenceImplementationAuthorityV1
                .canonicalSHA256)
        XCTAssertTrue(predecessor.implementationAuthorityEstablished)
        XCTAssertTrue(predecessor.implementationPatchAuthorizedByPredecessor)
        XCTAssertFalse(predecessor.liveCanaryAuthorizedByPredecessor)
        XCTAssertTrue(predecessor.separateCanaryAuthorityRequired)

        let closure = authority.layerAExactMainClosure
        XCTAssertEqual(
            closure.mergeRevision,
            "232a17e8f58a297919366d963ee1d7bc38cdbaee")
        XCTAssertEqual(
            closure.mergeTree,
            "c2a351449824ec15bc3154158d10f28c8a8310ad")
        XCTAssertEqual(
            closure.orderedParents,
            [
                "a4d8583fa7c59f885002ee06a07c1d5264c0c223",
                "960c705028f56d5bd4522f354632f3f14c869647",
            ])
        XCTAssertEqual(closure.pullRequestNumber, 120)
        XCTAssertTrue(closure.signedMergeVerified)
        XCTAssertEqual(closure.mergeTimestampUTC, "2026-08-16T06:21:51Z")
        XCTAssertEqual(
            closure.signatureVerifiedAtUTC,
            "2026-08-16T06:21:52Z")
        XCTAssertEqual(closure.workflowRunID, 31_931_241_261)
        XCTAssertEqual(closure.workflowRunNumber, 138)
        XCTAssertEqual(closure.workflowAttempt, 1)
        XCTAssertEqual(closure.checkSuiteID, 86_594_321_030)
        XCTAssertEqual(closure.event, "push")
        XCTAssertTrue(closure.previousAttemptURLIsNull)
        XCTAssertEqual(closure.workflowRerunCount, 0)
        XCTAssertEqual(closure.workflowConclusion, "success")
        XCTAssertEqual(closure.workflowCreatedAtUTC, "2026-08-16T06:21:53Z")
        XCTAssertEqual(closure.workflowStartedAtUTC, "2026-08-16T06:21:53Z")
        XCTAssertEqual(closure.workflowUpdatedAtUTC, "2026-08-16T07:17:50Z")
        XCTAssertEqual(closure.activeJobID, 95_126_300_172)
        XCTAssertEqual(closure.activeJobConclusion, "success")
        XCTAssertEqual(closure.activeRunnerLabel, "macos-15")
        XCTAssertEqual(closure.activeLatinTestCount, 116)
        XCTAssertEqual(closure.activeLatinFailureCount, 0)
        XCTAssertEqual(closure.reviewedJobID, 95_126_735_634)
        XCTAssertEqual(closure.reviewedJobConclusion, "success")
        XCTAssertEqual(closure.reviewedRunnerLabel, "macos-26")
        XCTAssertEqual(closure.rootTestCount, 77)
        XCTAssertEqual(closure.isolatedGroupTestCounts, [1, 1, 2, 2])
        XCTAssertEqual(closure.isolatedTestCount, 6)
        XCTAssertEqual(closure.focusedWholeTestCount, 83)
        XCTAssertEqual(closure.retainedMetalTestCount, 44)
        XCTAssertEqual(closure.maintainedRuntimeTestCount, 1)
        XCTAssertEqual(closure.tokenizerTestCount, 1)
        XCTAssertEqual(closure.retainedLiveTestCount, 46)
        XCTAssertEqual(closure.aggregateTestCount, 129)
        XCTAssertEqual(closure.reviewedFailureCount, 0)
        XCTAssertEqual(closure.reviewedSkipCount, 0)
        XCTAssertEqual(closure.layerATestMethodStartCount, 12)
        XCTAssertEqual(closure.layerATestMethodPassCount, 12)
        XCTAssertEqual(closure.actionsArtifactCount, 0)
        XCTAssertEqual(closure.stage7JobCount, 0)
        XCTAssertEqual(closure.stage7LauncherInvocationCount, 0)
        XCTAssertEqual(closure.stage7ExecutableInvocationCount, 0)
        XCTAssertEqual(closure.stage7ReceiptCount, 0)
        XCTAssertEqual(closure.closedCanaryLauncherInvocationCount, 0)
        XCTAssertEqual(closure.integrationAdapterInvocationCount, 0)
        XCTAssertEqual(closure.capabilityPreparationCount, 0)
        XCTAssertEqual(closure.capabilityExecuteCallCount, 0)
        XCTAssertEqual(closure.successfulTopLevelCaptureCount, 0)
        XCTAssertEqual(closure.physicalFixtureProcessCount, 0)
        XCTAssertEqual(closure.leaseAcquisitionInvocationCount, 0)
        XCTAssertEqual(closure.pythonInterpreterInvocationCount, 0)
        XCTAssertEqual(closure.newCppImplementationInvocationCount, 0)
        XCTAssertEqual(closure.actionsArtifactUploadCount, 0)
        XCTAssertEqual(
            closure.embeddedSourceIdentitySHA256,
            "f9362d044dcac6120950be43d7e1a22094b38795dff456f0e81e698a91614b49")
        XCTAssertTrue(closure.exactMainClosureEstablished)

        let scaffold = authority.authorityScaffold
        XCTAssertEqual(scaffold.exactPathCount, 5)
        XCTAssertEqual(scaffold.exactOrderedChangedPaths.count, 5)
        XCTAssertEqual(Set(scaffold.exactOrderedChangedPaths).count, 5)
        XCTAssertEqual(
            scaffold.preservedIndexSHA256,
            "e8dd30060ea370f01e135f8c2e379ab2d9bb6138dca9d928c395cdd9f967f291")
        XCTAssertEqual(scaffold.activeLatinTestCount, 116)
        XCTAssertEqual(scaffold.rootTestCount, 78)
        XCTAssertEqual(scaffold.isolatedGroupTestCounts, [1, 1, 2, 2])
        XCTAssertEqual(scaffold.isolatedTestCount, 6)
        XCTAssertEqual(scaffold.focusedWholeTestCount, 84)
        XCTAssertEqual(scaffold.retainedLiveTestCount, 46)
        XCTAssertEqual(scaffold.aggregateTestCount, 130)
        XCTAssertEqual(scaffold.embeddedProvenanceRecordCount, 507)
        XCTAssertEqual(scaffold.authorityTestMethodCount, 1)
        XCTAssertEqual(scaffold.processMechanicsInvocationCount, 0)
        XCTAssertEqual(scaffold.fixtureInvocationCount, 0)
        XCTAssertEqual(scaffold.leaseInvocationCount, 0)
        XCTAssertEqual(scaffold.hostedDiagnosticEmissionCount, 0)
        XCTAssertEqual(scaffold.filesystemMutationCount, 0)
        XCTAssertEqual(scaffold.networkInvocationCount, 0)
        XCTAssertTrue(scaffold.onlyExactFivePathsAuthorized)

        let layerA = authority.frozenLayerAInventory
        XCTAssertEqual(layerA.exactIdentityCount, 11)
        XCTAssertEqual(layerA.orderedSourceIdentities.count, 11)
        XCTAssertEqual(
            Set(layerA.orderedSourceIdentities.map(\.path)).count,
            11)
        XCTAssertEqual(layerA.exactInternalTypeCount, 7)
        XCTAssertEqual(
            layerA.exactInternalTypeNames,
            [
                "PrimeSecureChildProcessPlanV1",
                "PrimeSecureChildProcessEvidenceV1",
                "PrimeTrustedSecureChildProcessCapture",
                "PrimeSecureChildExecutionKernel",
                "PrimeSecureChildDiagnosticEnvelopeV1",
                "PrimeSecureChildDiagnosticProjection",
                "PrimeSecureChildLeaseRetention",
            ])
        XCTAssertEqual(layerA.exactInjectedTestMethodCount, 12)
        XCTAssertEqual(layerA.publicFixtureModeCount, 9)
        XCTAssertTrue(layerA.publicFixtureAPISpellingsPreserved)
        XCTAssertTrue(layerA.newTypesRemainInternal)
        XCTAssertTrue(layerA.trustedCaptureExactlyOneShot)
        XCTAssertTrue(layerA.exactPIDReapRequired)
        XCTAssertTrue(layerA.processGroupEmptyRequired)
        XCTAssertTrue(layerA.terminalClosedDrainsRequired)
        XCTAssertTrue(layerA.fixtureSuccessRequiresCleanEOFAndZeroErrors)
        XCTAssertTrue(layerA.typedUnavailableDistinctFromObservedFalse)
        XCTAssertTrue(layerA.capturedPrefixDistinctFromFullStreamDigest)
        XCTAssertEqual(layerA.diagnosticMaximumCanonicalByteCount, 4_096)
        XCTAssertTrue(layerA.diagnosticConstructionOnlyAfterContainment)
        XCTAssertFalse(layerA.diagnosticEmissionAuthorized)
        XCTAssertTrue(
            layerA.leaseSeamOnlyRetainsExternallyOwnedOpaqueCapability)
        XCTAssertFalse(layerA.leaseSeamAcquiresOrTransfersCapability)
        XCTAssertFalse(layerA.layerAMutationAuthorizedByThisAuthority)

        let payload = authority.frozenValidationPayload
        XCTAssertEqual(
            payload.packageManifest.gitBlob,
            "fe98104c7e812d0c44ee1e38dcc10857455bf54f")
        XCTAssertEqual(
            payload.packageResolved.gitBlob,
            "69919288b1a5da256ff408a4d65106b23abc8f89")
        XCTAssertEqual(
            payload.fixtureChildSource.gitBlob,
            "5e45832ed046da7bfd4541ad362018fad97371f5")
        XCTAssertEqual(
            payload.integrationSource.gitBlob,
            "cce94e857f770f8108d7a694675ca75386a40ddb")
        XCTAssertEqual(
            payload.orderedProducts,
            [
                "PrimeValidationWorkflowFixtureChild",
                "PrimeValidationWorkflowSecureChildIntegration",
            ])
        XCTAssertFalse(payload.payloadSourceMutationAuthorized)
        XCTAssertFalse(payload.packageManifestMutationAuthorized)
        XCTAssertFalse(payload.packageResolvedMutationAuthorized)
        XCTAssertFalse(payload.newSwiftPMTargetAuthorized)
        XCTAssertFalse(payload.arbitraryExecutableAdapterAuthorized)

        let canary = authority.closedCanaryContract
        XCTAssertEqual(canary.exactModeCount, 9)
        XCTAssertEqual(canary.dynamicByteCountSentinel, -1)
        XCTAssertEqual(
            canary.orderedModeContracts.map(\.mode),
            [
                "pass", "logical-argument-zero", "nonzero-exit",
                "bounded-streams", "overflow", "hang", "self-signal",
                "descendant-retains-streams", "exit-without-result",
            ])
        XCTAssertEqual(
            canary.orderedModeContracts.map(\.expectedTopLevelCaptureCount),
            [2, 1, 1, 1, 1, 1, 1, 1, 1])
        XCTAssertEqual(
            canary.orderedModeContracts.map(\.maximumWallNanoseconds),
            [
                10_000_000_000, 10_000_000_000, 10_000_000_000,
                10_000_000_000, 10_000_000_000, 1_000_000_000,
                10_000_000_000, 1_000_000_000, 10_000_000_000,
            ])
        for mode in canary.orderedModeContracts {
            XCTAssertEqual(mode, authority.closedCanaryContract
                .orderedModeContracts[mode.ordinal - 1])
            XCTAssertFalse(mode.expectedCompletion.isEmpty)
            XCTAssertFalse(mode.expectedResult.isEmpty)
            XCTAssertFalse(mode.expectedArgumentZero.isEmpty)
            XCTAssertFalse(mode.expectedStandardOutputContract.isEmpty)
            XCTAssertFalse(mode.expectedStandardErrorContract.isEmpty)
            XCTAssertFalse(mode.expectedPreReapMembership.isEmpty)
            if mode.mode != "descendant-retains-streams" {
                XCTAssertGreaterThanOrEqual(
                    mode.expectedStandardOutputTotalByteCount,
                    0)
                XCTAssertGreaterThanOrEqual(
                    mode.expectedStandardOutputCapturedByteCount,
                    0)
            }
            XCTAssertGreaterThanOrEqual(
                mode.expectedStandardErrorTotalByteCount,
                0)
            XCTAssertGreaterThanOrEqual(
                mode.expectedStandardErrorCapturedByteCount,
                0)
        }
        let descendantMode = canary.orderedModeContracts[7]
        XCTAssertEqual(descendantMode.mode, "descendant-retains-streams")
        XCTAssertEqual(
            descendantMode.expectedResult,
            "dynamic_exact_fixture_result_with_descendant_pid_matching_stdout_and_membership")
        XCTAssertEqual(
            descendantMode.expectedStandardOutputTotalByteCount,
            canary.dynamicByteCountSentinel)
        XCTAssertEqual(
            descendantMode.expectedStandardOutputCapturedByteCount,
            canary.dynamicByteCountSentinel)
        XCTAssertEqual(descendantMode.expectedStandardErrorTotalByteCount, 0)
        XCTAssertEqual(descendantMode.expectedStandardErrorCapturedByteCount, 0)
        XCTAssertFalse(descendantMode.standardOutputOverflowExpected)
        XCTAssertFalse(descendantMode.standardErrorOverflowExpected)
        XCTAssertEqual(
            descendantMode.expectedStandardOutputContract,
            "spawned_descendant_pid_equals_positive_canonical_int32_then_one_lf_captured_equals_total")
        let descendantOutput = canary.descendantDynamicOutput
        XCTAssertEqual(descendantOutput.mode, descendantMode.mode)
        XCTAssertEqual(
            descendantOutput.standardOutputPrefix,
            "spawned_descendant_pid=")
        XCTAssertEqual(descendantOutput.standardOutputTerminator, "\n")
        XCTAssertEqual(descendantOutput.exactLineCount, 1)
        XCTAssertEqual(
            descendantOutput.suffixEncoding,
            "canonical_positive_base10_int32")
        XCTAssertTrue(descendantOutput.suffixDigitsOnly)
        XCTAssertFalse(descendantOutput.suffixLeadingZeroAllowed)
        XCTAssertFalse(descendantOutput.suffixPlusSignAllowed)
        XCTAssertFalse(descendantOutput.suffixMinusSignAllowed)
        XCTAssertEqual(descendantOutput.minimumSuffixValue, 1)
        XCTAssertEqual(descendantOutput.maximumSuffixValue, Int(Int32.max))
        XCTAssertEqual(descendantOutput.minimumTotalByteCount, 25)
        XCTAssertEqual(descendantOutput.maximumTotalByteCount, 34)
        XCTAssertTrue(
            descendantOutput.capturedByteCountEqualsTotalByteCount)
        XCTAssertFalse(descendantOutput.fixedTotalByteCountAvailable)
        XCTAssertFalse(descendantOutput.fixedCapturedByteCountAvailable)
        XCTAssertFalse(descendantOutput.overflowExpected)
        XCTAssertFalse(descendantOutput.fixedStreamSHA256Available)
        XCTAssertTrue(
            descendantOutput.resultPIDMatchesOutputPIDAndMembershipPID)
        XCTAssertEqual(canary.expectedLauncherInvocationCount, 1)
        XCTAssertEqual(canary.expectedIntegrationAdapterInvocationCount, 1)
        XCTAssertEqual(canary.expectedCapabilityPreparationCount, 11)
        XCTAssertEqual(canary.expectedCapabilityExecuteCallCount, 13)
        XCTAssertEqual(canary.expectedSuccessfulTopLevelCaptureCount, 10)
        XCTAssertEqual(canary.expectedTopLevelFixtureProcessCount, 10)
        XCTAssertEqual(canary.expectedPhysicalFixtureProcessCount, 11)
        XCTAssertEqual(canary.expectedInternalDescendantProcessCount, 1)
        XCTAssertEqual(canary.expectedRejectedExecuteCallCount, 3)
        XCTAssertEqual(canary.expectedPreSpawnReplacementRejectionCount, 1)
        XCTAssertEqual(
            canary.expectedSequentialAlreadyConsumedRejectionCount,
            1)
        XCTAssertEqual(canary.expectedConcurrentWinnerCount, 1)
        XCTAssertEqual(
            canary.expectedConcurrentAlreadyConsumedRejectionCount,
            1)
        XCTAssertTrue(canary.allRejectedExecuteCallsSpawnNoProcess)
        XCTAssertTrue(canary.everySuccessfulReturnRequiresModeRoundTrip)
        XCTAssertTrue(canary.everySuccessfulReturnRequiresFixtureContract)
        XCTAssertTrue(
            canary.everySuccessfulReturnRequiresSessionAndGroupEqualPID)
        XCTAssertTrue(
            canary.everySuccessfulReturnRequiresDescriptorBackedJoins)
        XCTAssertTrue(canary.everySuccessfulReturnRequiresExactPIDReap)
        XCTAssertTrue(canary.everySuccessfulReturnRequiresEmptyProcessGroup)
        XCTAssertTrue(
            canary.everySuccessfulReturnRequiresTerminalClosedDrains)
        XCTAssertTrue(canary.everySuccessfulReturnRequiresCleanEOFAndZeroErrors)
        XCTAssertTrue(canary.typedLayerAEvidenceValidatedInternally)
        XCTAssertTrue(canary.diagnosticConstructedOnlyAfterContainment)
        XCTAssertFalse(canary.diagnosticEmittedByCanary)
        XCTAssertEqual(canary.expectedSuccessStandardOutputByteCount, 121)
        XCTAssertEqual(canary.expectedSuccessStandardOutputLineCount, 1)
        XCTAssertEqual(
            canary.expectedSuccessStandardOutputSHA256,
            "933bf087c8b15408aef9aaca1447dfbc07c9685ca0fda451d9db7fda4c1198af")
        XCTAssertEqual(canary.expectedSuccessStandardErrorByteCount, 0)
        XCTAssertEqual(canary.expectedSuccessExitStatus, 0)
        XCTAssertTrue(canary.outputIsOperationalCompatibilityEvidenceOnly)
        XCTAssertFalse(canary.outputIsScientificEvidence)
        XCTAssertFalse(canary.outputIsDurableEvidence)

        let mechanics = authority.mechanicsSuccessor
        XCTAssertEqual(
            mechanics.orderedMechanicsSuccessorPaths,
            [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/scripts/prime-ci-secure-child-process-evidence-closed-fixture-canary.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
            ])
        XCTAssertEqual(
            mechanics.orderedMechanicsSuccessorPathContracts,
            [
                .init(
                    path: ".github/scripts/prime-ci-active-root-quarantine.sh",
                    gitStatus: "M",
                    gitMode: "100755"),
                .init(
                    path: ".github/scripts/prime-ci-secure-child-process-evidence-closed-fixture-canary.sh",
                    gitStatus: "A",
                    gitMode: "100755"),
                .init(
                    path: ".github/workflows/prime-active-root-quarantine.yml",
                    gitStatus: "M",
                    gitMode: "100644"),
            ])
        XCTAssertEqual(mechanics.exactPathCount, 3)
        XCTAssertEqual(mechanics.modifiedExistingPathCount, 2)
        XCTAssertEqual(mechanics.addedLauncherPathCount, 1)
        XCTAssertTrue(mechanics.authorityMayBeginAfterExactMainClosure)
        XCTAssertTrue(
            mechanics.authorizedOnlyAfterThisAuthorityExactMainGreen)
        XCTAssertFalse(mechanics.currentAuthorityExecutesMechanics)
        XCTAssertTrue(mechanics.mainPushOnly)
        XCTAssertTrue(mechanics.existingReviewedJobFinalForegroundStep)
        XCTAssertFalse(mechanics.newHostedJobAuthorized)
        XCTAssertEqual(
            mechanics.workflowFilePath,
            ".github/workflows/prime-active-root-quarantine.yml")
        XCTAssertEqual(mechanics.workflowName, "Prime active-root quarantine")
        XCTAssertEqual(mechanics.reviewedJobID, "trusted-main-compile")
        XCTAssertTrue(mechanics.reviewedJobNeedsActiveRootSuccess)
        XCTAssertEqual(mechanics.requiredGitHubEventName, "push")
        XCTAssertEqual(mechanics.requiredGitHubRef, "refs/heads/main")
        XCTAssertEqual(
            mechanics.requiredGitHubRepository,
            "Ergentics/ergentics-prime")
        XCTAssertEqual(mechanics.requiredGitHubRunAttempt, 1)
        XCTAssertTrue(
            mechanics.githubSHAEqualsExactRevisionAndCheckoutHEADRequired)
        XCTAssertTrue(mechanics.exactRevisionMustBeLowercaseGitSHA)
        XCTAssertTrue(
            mechanics.mechanicsRevisionMustBeDirectSuccessorOfAuthorityClosure)
        XCTAssertTrue(
            mechanics.mechanicsFirstParentMustEqualAuthorityClosureRevision)
        XCTAssertTrue(
            mechanics.mechanicsFirstParentTreeMustEqualAuthorityClosureTree)
        XCTAssertEqual(mechanics.expectedMechanicsMergeParentCount, 2)
        XCTAssertEqual(
            mechanics.authorityClosureRevisionAvailability,
            "unavailable_until_this_authority_exact_main_merge")
        XCTAssertEqual(
            mechanics.authorityClosureTreeAvailability,
            "unavailable_until_this_authority_exact_main_merge")
        XCTAssertTrue(mechanics.exactThreeDeltaMustEqualOrderedSuccessorPaths)
        XCTAssertTrue(
            mechanics.gateAndLauncherRevalidateExactStatusModeMapping)
        XCTAssertTrue(
            mechanics.gateAndLauncherFreezeClosureRevisionAndTreeAfterMerge)
        XCTAssertTrue(
            mechanics.launcherRevalidatesDirectParentAndExactThreeDelta)
        XCTAssertTrue(
            mechanics.laterDistinctMainPushMustRefuseBeforeAdapterInvocation)
        XCTAssertFalse(
            mechanics.laterDistinctMainPushAdapterInvocationAuthorized)
        XCTAssertTrue(
            mechanics.observationAndRetirementMustBeNextAuthorizedChange)
        let deferredClosure = mechanics.deferredAuthorityExactMainGreenEvidence
        XCTAssertEqual(
            deferredClosure.evidenceAvailability,
            "unavailable_until_this_authority_exact_main_green_closure")
        XCTAssertTrue(deferredClosure.signedAuthorityClosureRequired)
        XCTAssertTrue(
            deferredClosure.exactAuthorityClosureRevisionAndTreeRequired)
        XCTAssertEqual(deferredClosure.uniquePushWorkflowRunCount, 1)
        XCTAssertTrue(deferredClosure.exactWorkflowRunIDRequired)
        XCTAssertTrue(deferredClosure.exactWorkflowRunNumberRequired)
        XCTAssertTrue(deferredClosure.exactCheckSuiteIDRequired)
        XCTAssertEqual(deferredClosure.requiredWorkflowAttempt, 1)
        XCTAssertTrue(deferredClosure.previousAttemptURLMustBeNull)
        XCTAssertEqual(deferredClosure.workflowRerunCount, 0)
        XCTAssertEqual(deferredClosure.requiredWorkflowConclusion, "success")
        XCTAssertTrue(deferredClosure.exactActiveJobIDRequired)
        XCTAssertEqual(deferredClosure.requiredActiveJobConclusion, "success")
        XCTAssertEqual(deferredClosure.expectedActiveLatinTestCount, 116)
        XCTAssertEqual(deferredClosure.expectedActiveLatinFailureCount, 0)
        XCTAssertTrue(deferredClosure.exactReviewedJobIDRequired)
        XCTAssertEqual(
            deferredClosure.requiredReviewedJobConclusion,
            "success")
        XCTAssertEqual(deferredClosure.expectedRootTestCount, 78)
        XCTAssertEqual(deferredClosure.expectedIsolatedTestCount, 6)
        XCTAssertEqual(deferredClosure.expectedFocusedWholeTestCount, 84)
        XCTAssertEqual(deferredClosure.expectedRetainedLiveTestCount, 46)
        XCTAssertEqual(deferredClosure.expectedAggregateTestCount, 130)
        XCTAssertEqual(deferredClosure.expectedReviewedFailureCount, 0)
        XCTAssertEqual(deferredClosure.expectedReviewedSkipCount, 0)
        XCTAssertEqual(deferredClosure.expectedActionsArtifactCount, 0)
        XCTAssertTrue(
            deferredClosure.gateAndWorkflowFreezeExactValuesBeforeMechanics)
        XCTAssertEqual(
            deferredClosure.launcherClosureEvidenceAPIInvocationCount,
            0)
        XCTAssertEqual(
            deferredClosure.launcherClosureEvidenceNetworkInvocationCount,
            0)
        XCTAssertTrue(
            mechanics.cleanDetachedCheckoutRequiredImmediatelyBeforeLauncher)
        XCTAssertEqual(mechanics.reviewedCheckoutFetchDepth, 2)
        XCTAssertFalse(mechanics.concurrencyCancelInProgress)
        XCTAssertTrue(mechanics.launcherMustBeLiteralFinalWorkflowStep)
        XCTAssertFalse(mechanics.launcherContinueOnError)
        XCTAssertEqual(
            mechanics.invocationAdmissionMismatchResultCode,
            "INVOCATION_ADMISSION_REFUSED")
        XCTAssertFalse(
            mechanics.invocationAdmissionMismatchEstablishesAdapterInvocation)
        XCTAssertTrue(
            mechanics.invocationAdmissionMismatchRetiresMechanicsOpportunity)
        XCTAssertEqual(mechanics.buildConfiguration, "release")
        XCTAssertEqual(mechanics.requiredArchitecture, "arm64")
        XCTAssertEqual(mechanics.requiredOperatingSystem, "macos_26")
        XCTAssertEqual(
            mechanics.validationPackagePath,
            "Tests/PrimeValidationWorkflow")
        XCTAssertEqual(
            mechanics.validationPackagePhysicalPath,
            "$GITHUB_WORKSPACE/ergentics-prime/Tests/PrimeValidationWorkflow")
        XCTAssertTrue(mechanics.validationPackageMustBePhysicalDirectory)
        XCTAssertFalse(mechanics.validationPackageSymbolicLinkAuthorized)
        XCTAssertEqual(
            mechanics.orderedSwiftBuildProducts,
            [
                "PrimeValidationWorkflowFixtureChild",
                "PrimeValidationWorkflowSecureChildIntegration",
            ])
        XCTAssertEqual(mechanics.expectedSwiftBuildProductCommandCount, 2)
        XCTAssertEqual(mechanics.expectedSwiftShowBinPathCommandCount, 1)
        XCTAssertEqual(mechanics.expectedSwiftRunCommandCount, 0)
        XCTAssertEqual(mechanics.expectedSwiftTestCommandCount, 0)
        XCTAssertEqual(mechanics.expectedSwiftBuildTestsCommandCount, 0)
        XCTAssertEqual(
            mechanics.orderedSwiftPMCommandRoles,
            [
                "release_build_PrimeValidationWorkflowFixtureChild",
                "release_build_PrimeValidationWorkflowSecureChildIntegration",
                "release_show_bin_path_without_product_build",
            ])
        XCTAssertEqual(mechanics.exactSwiftPMCommandCount, 3)
        XCTAssertEqual(
            mechanics.orderedCommonSwiftPMArgumentTemplates,
            [
                "--package-path Tests/PrimeValidationWorkflow",
                "--configuration release",
                "--scratch-path $RUNNER_TEMP/prime-secure-child-process-evidence-closed-fixture-canary-scratch",
                "--cache-path $RUNNER_TEMP/prime-secure-child-process-evidence-closed-fixture-canary-cache",
                "--config-path $RUNNER_TEMP/prime-secure-child-process-evidence-closed-fixture-canary-config",
                "--security-path $RUNNER_TEMP/prime-secure-child-process-evidence-closed-fixture-canary-security",
                "--disable-dependency-cache",
                "--manifest-cache local",
                "--disable-netrc",
                "--disable-keychain",
                "--force-resolved-versions",
            ])
        XCTAssertEqual(
            mechanics.orderedRequiredLocalMirrorOrigins,
            [
                "https://github.com/Ergentics/ergentics-mlx-swift",
                "https://github.com/apple/swift-numerics",
            ])
        XCTAssertEqual(mechanics.expectedLocalBareMirrorCount, 2)
        XCTAssertEqual(mechanics.orderedRequiredLocalBareMirrors.count, 2)
        let mlxMirror = mechanics.orderedRequiredLocalBareMirrors[0]
        XCTAssertEqual(mlxMirror.dependencyIdentity, "ergentics_mlx_swift")
        XCTAssertEqual(
            mlxMirror.runnerTempPath,
            "$RUNNER_TEMP/ergentics-mlx-swift.git")
        XCTAssertEqual(
            mlxMirror.fileURL,
            "file://$RUNNER_TEMP/ergentics-mlx-swift.git/")
        XCTAssertEqual(
            mlxMirror.exactOriginURL,
            "https://github.com/Ergentics/ergentics-mlx-swift")
        XCTAssertEqual(
            mlxMirror.exactCommitSHA,
            "d37885a278f1c37484a94d0f401a418735e66519")
        XCTAssertEqual(
            mlxMirror.typedCommitExpression,
            "d37885a278f1c37484a94d0f401a418735e66519^{commit}")
        XCTAssertEqual(
            mlxMirror.pinnedRefExpression,
            "refs/heads/prime-pinned^{commit}")
        let numericsMirror = mechanics.orderedRequiredLocalBareMirrors[1]
        XCTAssertEqual(numericsMirror.dependencyIdentity, "swift_numerics")
        XCTAssertEqual(
            numericsMirror.runnerTempPath,
            "$RUNNER_TEMP/prime-active-root-build/repositories/swift-numerics-d936ec6c")
        XCTAssertEqual(
            numericsMirror.fileURL,
            "file://$RUNNER_TEMP/prime-active-root-build/repositories/swift-numerics-d936ec6c/")
        XCTAssertEqual(
            numericsMirror.exactOriginURL,
            "https://github.com/apple/swift-numerics")
        XCTAssertEqual(
            numericsMirror.exactCommitSHA,
            "0c0290ff6b24942dadb83a929ffaaa1481df04a2")
        XCTAssertEqual(
            numericsMirror.typedCommitExpression,
            "0c0290ff6b24942dadb83a929ffaaa1481df04a2^{commit}")
        XCTAssertEqual(
            numericsMirror.pinnedRefExpression,
            "refs/tags/1.1.1^{commit}")
        for mirror in [mlxMirror, numericsMirror] {
            XCTAssertTrue(mirror.pathMustExistAsDirectory)
            XCTAssertFalse(mirror.symbolicLinkAuthorized)
            XCTAssertTrue(
                mirror.physicalPathMustEqualExpandedRunnerTempPath)
            XCTAssertTrue(mirror.absoluteGitDirectoryMustEqualPhysicalPath)
            XCTAssertTrue(mirror.bareRepositoryRequired)
            XCTAssertEqual(mirror.soleRemoteName, "origin")
            XCTAssertEqual(mirror.exactOriginURLValueCount, 1)
            XCTAssertEqual(mirror.revisionObjectType, "commit")
            XCTAssertTrue(mirror.typedCommitMustResolveToExactCommit)
            XCTAssertTrue(mirror.pinnedRefMustResolveToExactCommit)
        }
        XCTAssertTrue(mechanics.alreadyValidatedLocalBareMirrorsRequired)
        XCTAssertTrue(mechanics.sameReviewedJobLocalBareMirrorsRequired)
        XCTAssertTrue(
            mechanics
                .localBareMirrorsRevalidatedImmediatelyBeforeMappingsAndBuilds)
        XCTAssertTrue(
            mechanics.runnerTempMustBeCanonicalAbsolutePhysicalDirectory)
        XCTAssertEqual(
            mechanics.orderedFileURLInsteadOfMappings,
            [
                .init(
                    localFileURL:
                        "file://$RUNNER_TEMP/ergentics-mlx-swift.git/",
                    remoteURL:
                        "https://github.com/Ergentics/ergentics-mlx-swift"),
                .init(
                    localFileURL:
                        "file://$RUNNER_TEMP/prime-active-root-build/repositories/swift-numerics-d936ec6c/",
                    remoteURL:
                        "https://github.com/apple/swift-numerics"),
            ])
        XCTAssertEqual(mechanics.exactFileURLInsteadOfMappingCount, 2)
        XCTAssertTrue(mechanics.protocolFileAllowAlwaysRequired)
        XCTAssertTrue(mechanics.forceResolvedVersionsRequired)
        XCTAssertTrue(mechanics.mirrorMismatchRequiresAppendOnlyObservation)
        XCTAssertTrue(mechanics.mirrorMismatchRetiresMechanicsOpportunity)
        XCTAssertFalse(mechanics.mirrorMismatchEstablishesAdapterInvocation)
        XCTAssertFalse(
            mechanics.mirrorMismatchPermitsRetryWithoutNewAuthority)
        XCTAssertEqual(
            mechanics.orderedFreshPrivateSwiftPMRootRoles,
            ["scratch", "cache", "config", "security"])
        XCTAssertEqual(
            mechanics.orderedFreshPrivateSwiftPMRootPaths,
            [
                "$RUNNER_TEMP/prime-secure-child-process-evidence-closed-fixture-canary-scratch",
                "$RUNNER_TEMP/prime-secure-child-process-evidence-closed-fixture-canary-cache",
                "$RUNNER_TEMP/prime-secure-child-process-evidence-closed-fixture-canary-config",
                "$RUNNER_TEMP/prime-secure-child-process-evidence-closed-fixture-canary-security",
            ])
        XCTAssertEqual(mechanics.freshPrivateSwiftPMRootCount, 4)
        XCTAssertEqual(mechanics.freshPrivateSwiftPMRootMode, "0700")
        XCTAssertTrue(
            mechanics
                .freshPrivateSwiftPMRootsMustNotPreexistOrBeSymbolicLinks)
        XCTAssertTrue(
            mechanics
                .freshPrivateSwiftPMRootsMustBeCanonicalPhysicalDirectories)
        XCTAssertTrue(mechanics.disableDependencyCacheRequired)
        XCTAssertEqual(mechanics.manifestCacheMode, "local")
        XCTAssertTrue(mechanics.disableNetrcRequired)
        XCTAssertTrue(mechanics.disableKeychainRequired)
        XCTAssertFalse(mechanics.disableSandboxAuthorized)
        XCTAssertTrue(
            mechanics.isolationFlagsRequiredOnEveryBuildAndShowBinPathCommand)
        XCTAssertTrue(
            mechanics.fileURLMappingsRequiredOnEveryBuildAndShowBinPathCommand)
        XCTAssertEqual(mechanics.swiftPMTMPDIR, "$RUNNER_TEMP")
        XCTAssertTrue(
            mechanics.canonicalBinPathMustBePhysicalDescendantOfScratchPath)
        XCTAssertEqual(mechanics.showBinPathExactOutputLineCount, 1)
        XCTAssertEqual(
            mechanics.orderedExpectedExecutableLeafNames,
            mechanics.orderedSwiftBuildProducts)
        XCTAssertEqual(mechanics.exactExpectedExecutableLeafCount, 2)
        XCTAssertTrue(mechanics.expectedExecutableLeavesMustBeRegular)
        XCTAssertFalse(
            mechanics.expectedExecutableLeafSymbolicLinksAuthorized)
        XCTAssertEqual(mechanics.expectedExecutableLeafLinkCount, 1)
        XCTAssertTrue(mechanics.expectedExecutableLeavesMustBeExecutable)
        XCTAssertTrue(
            mechanics.bothExecutableDescriptorMetadataAndSHA256Bound)
        XCTAssertTrue(
            mechanics.bothExecutableIdentitiesRevalidatedImmediatelyBeforeCall)
        XCTAssertEqual(mechanics.launcherFinalStepAfterRetainedLiveTestCount, 46)
        XCTAssertEqual(
            mechanics.dependencyNetworkInvocationCountAfterReviewedFetch,
            0)
        XCTAssertEqual(
            mechanics.directAdapterArgumentCountExcludingArgumentZero,
            1)
        XCTAssertEqual(
            mechanics.directAdapterProcessArgumentCountIncludingArgumentZero,
            2)
        XCTAssertEqual(
            mechanics.directAdapterOnlyArgumentRole,
            "canonical_absolute_path_to_measured_fixture_matching_existing_layer_a_pin")
        XCTAssertTrue(mechanics.adapterExecutableAbsolutePathRequired)
        XCTAssertTrue(mechanics.fixtureArgumentCanonicalAbsolutePathRequired)
        XCTAssertFalse(mechanics.callerControlledEnvironmentAuthorized)
        XCTAssertFalse(mechanics.callerControlledCommandAuthorized)
        XCTAssertEqual(mechanics.evalInvocationCount, 0)
        XCTAssertEqual(mechanics.arbitraryShellExecInvocationCount, 0)
        XCTAssertEqual(
            mechanics.requiredLayerAAcceptanceFixtureExecutableByteCount,
            89_632)
        XCTAssertEqual(
            mechanics.requiredLayerAAcceptanceFixtureExecutableSHA256,
            "eae9573027fe736cab0d4aa319ae43f22231eaef9c55af91d73fbe3d87bc9ebd")
        XCTAssertEqual(
            mechanics.acceptancePinKernelSourcePath,
            "Sources/PrimeCore/PrimeSecureChildKernel.swift")
        XCTAssertEqual(
            mechanics.acceptancePinHistoricalDocumentation.gitBlob,
            "f37e4c90281b689927bd777e14d61bb139c7108b")
        XCTAssertEqual(
            mechanics
                .historicalDocumentationReportedDisjointAbsolutePathReleaseBuildCount,
            2)
        XCTAssertTrue(
            mechanics.historicalDocumentationReportsReleaseBuildsByteIdentical)
        XCTAssertEqual(
            mechanics.historicalDocumentationReportedMachOUUID,
            "6ABE4B24-C019-3372-8144-C85CCEE5BA19")
        XCTAssertFalse(mechanics.historicalBinaryRetained)
        XCTAssertFalse(mechanics.futureHostedBuildMatchObserved)
        XCTAssertEqual(
            mechanics.futureHostedBuildMeasuredByteCount,
            "unavailable_until_exact_mechanics_lane_build")
        XCTAssertEqual(
            mechanics.futureHostedBuildMeasuredSHA256,
            "unavailable_until_exact_mechanics_lane_build")
        XCTAssertTrue(
            mechanics
                .fixtureExecutableBuildOutputIdentityCapturedImmediatelyBeforeInvocation)
        XCTAssertTrue(
            mechanics.fixtureExecutableDescriptorNameAndInodeJoinRequired)
        XCTAssertTrue(
            mechanics.measuredBuildMustMatchExistingLayerAAcceptancePin)
        XCTAssertTrue(
            mechanics.pinMismatchRefusesBeforeOneShotConsumption)
        XCTAssertEqual(
            mechanics.reviewedJobEpochFilePath,
            "$RUNNER_TEMP/prime-secure-child-process-evidence-closed-fixture-canary-reviewed-job-epoch")
        XCTAssertTrue(
            mechanics
                .reviewedJobEpochCreatedInFirstWorkflowUserStepBeforeToolchain)
        XCTAssertFalse(
            mechanics.reviewedJobEpochRepresentsGitHubJobStartTimestamp)
        XCTAssertTrue(
            mechanics
                .reviewedJobEpochFileMustInitiallyNotExistOrBeSymbolicLink)
        XCTAssertTrue(mechanics.reviewedJobEpochFileCreatedExclusiveNoClobber)
        XCTAssertFalse(mechanics.reviewedJobEpochFileKernelImmutableClaimed)
        XCTAssertTrue(mechanics.reviewedJobEpochFileReadOnlyByPolicy)
        XCTAssertTrue(mechanics.reviewedJobEpochFileMustBeRegular)
        XCTAssertFalse(mechanics.reviewedJobEpochFileSymbolicLinkAuthorized)
        XCTAssertEqual(mechanics.reviewedJobEpochFileMode, "0400")
        XCTAssertEqual(mechanics.reviewedJobEpochFileLinkCount, 1)
        XCTAssertTrue(mechanics.reviewedJobEpochFileOwnerUIDAndGIDBound)
        XCTAssertEqual(
            mechanics.reviewedJobEpochContentGrammar,
            "canonical_positive_base10_unix_epoch_seconds_lf")
        XCTAssertEqual(mechanics.reviewedJobEpochContentLineCount, 1)
        XCTAssertTrue(mechanics.reviewedJobEpochMustBePositive)
        XCTAssertFalse(mechanics.reviewedJobEpochLeadingZeroAuthorized)
        XCTAssertTrue(
            mechanics.reviewedJobEpochDescriptorIdentityBoundByLauncher)
        XCTAssertTrue(mechanics.reviewedJobEpochMetadataBoundByLauncher)
        XCTAssertTrue(mechanics.reviewedJobEpochSHA256BoundByLauncher)
        XCTAssertTrue(
            mechanics
                .reviewedJobEpochRevalidatedUnchangedImmediatelyBeforeOneShot)
        XCTAssertTrue(
            mechanics.reviewedJobEpochMustNotBeFutureAtRevalidation)
        XCTAssertTrue(mechanics.preInvocationElapsedUsesWallClockEpochDifference)
        XCTAssertFalse(mechanics.continuousThroughSystemSleepClaimed)
        XCTAssertEqual(mechanics.predecessorReviewedJobElapsedSeconds, 3_082)
        XCTAssertEqual(
            mechanics.predecessorRetainedLiveCompletionElapsedSeconds,
            3_073)
        XCTAssertEqual(mechanics.priorJobCeilingSeconds, 3_600)
        XCTAssertEqual(
            mechanics.predecessorRemainingSecondsUnderPriorCeiling,
            527)
        XCTAssertEqual(mechanics.priorPreInvocationCutoffSeconds, 3_300)
        XCTAssertEqual(
            mechanics.predecessorRemainingSecondsUnderPriorCutoff,
            227)
        XCTAssertFalse(mechanics.exactLaneReleaseBuildDurationBoundObserved)
        XCTAssertFalse(
            mechanics.sameJobDebugOrCacheStateEstablishesReleaseBuildBound)
        XCTAssertEqual(mechanics.expectedJobCeilingSeconds, 4_500)
        XCTAssertEqual(mechanics.maximumPreInvocationElapsedSeconds, 4_200)
        XCTAssertEqual(mechanics.requiredRemainingJobReserveSeconds, 300)
        XCTAssertEqual(mechanics.expectedCapturePhaseCeilingSeconds, 82)
        XCTAssertEqual(mechanics.expectedDeadlineCleanupCount, 2)
        XCTAssertEqual(mechanics.expectedPerDeadlineCleanupCeilingSeconds, 9)
        XCTAssertEqual(
            mechanics.expectedCaptureAndDeadlineCleanupBudgetSeconds,
            100)
        XCTAssertFalse(
            mechanics
                .capabilityPreparationHashFilesystemAndReadyBarrierIncludedInBudget)
        XCTAssertEqual(mechanics.concurrentReadyBarrierMaximumSeconds, 3)
        XCTAssertFalse(mechanics.wholeAdapterWallCeilingEstablished)
        XCTAssertTrue(
            mechanics.remainingJobReserveIsPracticalNonGuaranteedOuterEnvelope)
        XCTAssertTrue(mechanics.directForegroundInvocationRequired)
        XCTAssertFalse(mechanics.backgroundWatchdogAuthorized)
        XCTAssertFalse(mechanics.shellKillOrProcessScanAuthorized)
        XCTAssertTrue(
            mechanics
                .mechanicsOpportunityConsumedImmediatelyBeforeAdapterCommandAttempt)
        XCTAssertFalse(
            mechanics.preCommandRefusalConsumesAdapterCommandAttemptOneShot)
        XCTAssertFalse(mechanics.preCommandRefusalEstablishesAdapterExecution)
        XCTAssertTrue(
            mechanics.preCommandRefusalRetiresMechanicsOpportunity)
        XCTAssertFalse(
            mechanics.automaticRetryAfterPreInvocationFailureAuthorized)
        XCTAssertTrue(
            mechanics.everyPostCommandAttemptOutcomeConsumesMechanicsOpportunity)
        XCTAssertFalse(mechanics.workflowRerunAuthorized)
        XCTAssertFalse(mechanics.replacementExecutionAuthorized)
        XCTAssertEqual(mechanics.expectedRootTestCount, 78)
        XCTAssertEqual(mechanics.expectedIsolatedTestCount, 6)
        XCTAssertEqual(mechanics.expectedFocusedWholeTestCount, 84)
        XCTAssertEqual(mechanics.expectedRetainedLiveTestCount, 46)
        XCTAssertEqual(mechanics.expectedAggregateXTestCount, 130)
        XCTAssertEqual(
            mechanics.expectedEmbeddedProvenanceRecordCountWithLauncherPresent,
            507)
        XCTAssertTrue(mechanics.embeddedProvenanceBytesMustRemainIdentical)

        let outer = mechanics.outerLauncherObservation
        XCTAssertEqual(
            outer.privateCaptureRootPath,
            "$RUNNER_TEMP/prime-secure-child-process-evidence-closed-fixture-canary-outer-capture")
        XCTAssertTrue(
            outer.privateCaptureRootMustInitiallyNotExistOrBeSymbolicLink)
        XCTAssertTrue(
            outer.privateCaptureRootCreatedByExactPathMkdirWithoutParents)
        XCTAssertEqual(outer.privateCaptureRootMode, "0700")
        XCTAssertTrue(outer.privateCaptureRootMustBePhysicalDirectory)
        XCTAssertFalse(outer.privateCaptureRootSymbolicLinkAuthorized)
        XCTAssertEqual(
            outer.orderedCaptureStreamNames,
            ["standard_output", "standard_error"])
        XCTAssertEqual(
            outer.orderedFixedCaptureLeafNames,
            ["standard-output.capture", "standard-error.capture"])
        XCTAssertTrue(outer.fixedCaptureLeavesPrecreatedBeforeInvocation)
        XCTAssertEqual(outer.captureFileMode, "0600")
        XCTAssertTrue(outer.captureFilesMustBeRegular)
        XCTAssertFalse(outer.captureFileSymbolicLinksAuthorized)
        XCTAssertEqual(outer.captureFileLinkCount, 1)
        XCTAssertEqual(outer.perStreamCaptureByteCap, 131_072)
        XCTAssertEqual(outer.bash1024ByteFileSizeLimitBlockCount, 128)
        XCTAssertEqual(outer.layerACapturedPrefixByteCap, 65_536)
        XCTAssertTrue(outer.outerCaptureCapDistinctFromLayerACapturedPrefixCap)
        XCTAssertFalse(outer.rawStreamBytesForwarded)
        XCTAssertFalse(outer.rawStreamBytesIncludedInSummary)
        XCTAssertFalse(outer.rawStreamBytesUploadedAsArtifact)
        XCTAssertEqual(
            outer.exactAdapterCommandStates,
            ["not_attempted", "shell_command_returned"])
        XCTAssertEqual(
            outer.exactAdapterExecutionObservationStates,
            ["observed_true", "observed_false", "unavailable"])
        XCTAssertTrue(
            outer.shellWaitStatusObservationRequiredAfterSynchronousReturn)
        XCTAssertFalse(outer.shellWaitStatusAloneEstablishesAdapterExecution)
        XCTAssertTrue(
            outer.exactRecognizedAdapterEnvelopesMayEstablishExecution)
        XCTAssertTrue(
            outer.preCommandRefusalEstablishesAdapterExecutionObservedFalse)
        XCTAssertFalse(
            outer.noReportOrUnexpectedReportEstablishesAdapterExecution)
        XCTAssertFalse(outer.nativeWaiterUsed)
        XCTAssertFalse(outer.exactExitVersusSignalClassificationEstablished)
        XCTAssertEqual(outer.shellWaitStatusType, "null_or_uint8")
        XCTAssertEqual(outer.shellWaitStatusMinimum, 0)
        XCTAssertEqual(outer.shellWaitStatusMaximum, 255)
        XCTAssertTrue(
            outer.shellWaitStatusZeroRequiresExpectedOutputContractForPass)
        XCTAssertTrue(
            outer.shellWaitStatusNonzeroUsesClosedDiagnosticClassification)
        XCTAssertEqual(
            outer.adapterReportedFailureAllowedShellStatuses,
            [1, 2])
        XCTAssertEqual(
            outer.adapterReportedFailureStandardErrorPrefix,
            "prime-validation secure-child integration: FAIL ")
        XCTAssertEqual(
            outer.adapterReportedFailureStandardErrorPrefixByteCount,
            48)
        XCTAssertEqual(outer.layerAFailStopReportedShellStatus, 70)
        XCTAssertEqual(
            outer.layerAFailStopStandardErrorPrefix,
            "prime-secure-child fail-stop: ")
        XCTAssertEqual(
            outer.layerAFailStopStandardErrorPrefixByteCount,
            30)
        XCTAssertTrue(outer.reportedFailureRequiresExactlyOneTerminalLF)
        XCTAssertTrue(outer.reportedFailureRequiresEmptyStandardOutput)
        XCTAssertFalse(outer.reportedFailureAllowsAdditionalLine)
        XCTAssertFalse(outer.reportedFailureAllowsCaptureCapReached)
        XCTAssertTrue(outer.adapterNoReportRequiresEmptyStandardOutput)
        XCTAssertTrue(outer.adapterNoReportRequiresEmptyStandardError)
        XCTAssertEqual(
            outer.unmatchedNonzeroReportResultCode,
            "ADAPTER_UNEXPECTED_REPORT")
        XCTAssertEqual(
            outer.statusZeroWrongOutputContractResultCode,
            "ADAPTER_OUTPUT_CONTRACT_MISMATCH")
        XCTAssertTrue(outer.diagnosticClassifierUsesOnlyFixedByteOperations)
        XCTAssertTrue(outer.notAttemptedRequiresZeroCapturedByteCounts)
        XCTAssertEqual(
            outer.notAttemptedRequiredEmptyStreamSHA256,
            "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
        XCTAssertTrue(outer.notAttemptedRequiresCaptureCapNotReached)
        XCTAssertTrue(outer.perStreamCapturedByteCountRequired)
        XCTAssertTrue(outer.perStreamSHA256Required)
        XCTAssertTrue(outer.perStreamCaptureCapReachedStateRequired)
        XCTAssertTrue(
            outer.captureCapReachedTrueIffCapturedByteCountEqualsCap)
        XCTAssertFalse(
            outer.captureCapReachedEstablishesAttemptedExcessBytes)
        XCTAssertFalse(outer.outerStreamOverflowOrTruncationEstablished)
        XCTAssertEqual(
            outer.orderedProjectionPrerequisites,
            [
                "adapter_command_not_attempted_or_synchronous_shell_command_return_and_status",
                "both_stream_counts_hashes_and_capture_cap_reached_states_captured",
                "bounded_capture_cleanup_attempt_completed",
            ])
        XCTAssertTrue(outer.captureCleanupAttemptBounded)
        XCTAssertTrue(outer.captureCleanupBoundIsExactOperationTopology)
        XCTAssertEqual(outer.exactCaptureLeafUnlinkAttemptCount, 2)
        XCTAssertEqual(outer.exactCaptureRootRmdirAttemptCount, 1)
        XCTAssertEqual(outer.recursiveDeletionInvocationCount, 0)
        XCTAssertEqual(outer.wildcardCleanupPathCount, 0)
        XCTAssertEqual(outer.cleanupDirectoryScanInvocationCount, 0)
        XCTAssertFalse(outer.cleanupSuccessRequiredBeforeProjection)
        XCTAssertEqual(
            outer.exactCaptureCleanupAbsenceStates,
            ["observed_true", "observed_false", "unavailable"])
        XCTAssertEqual(
            outer.captureCleanupFailureResultCode,
            "CAPTURE_CLEANUP_FAILED")
        XCTAssertTrue(
            outer.captureCleanupFailureRequiresNonzeroLauncherExit)
        XCTAssertEqual(
            outer.captureSetupRefusalResultCode,
            "CAPTURE_SETUP_REFUSED")
        XCTAssertTrue(
            outer.captureSetupRefusalEstablishesAdapterExecutionObservedFalse)
        XCTAssertTrue(
            outer.cleanupFailureOverridesPrimaryResultOnlyWhenPrimaryWasPass)
        XCTAssertTrue(outer.nonPassPrimaryResultPreservedWhenCleanupFails)
        XCTAssertTrue(outer.cleanupFailureStillRecordsObservedFalseAbsence)
        XCTAssertEqual(
            outer.exactSanitizedResultCodes,
            [
                "PASS",
                "INVOCATION_ADMISSION_REFUSED",
                "EPOCH_REFUSED",
                "PREINVOCATION_CUTOFF",
                "PLATFORM_REFUSED",
                "MIRROR_REFUSED",
                "SWIFTPM_ROOT_REFUSED",
                "ADAPTER_IDENTITY_REFUSED",
                "BUILD_REFUSED",
                "PIN_MISMATCH",
                "CAPTURE_SETUP_REFUSED",
                "ADAPTER_REPORTED_FAILURE",
                "LAYER_A_FAIL_STOP_REPORTED",
                "ADAPTER_NO_REPORT",
                "ADAPTER_UNEXPECTED_REPORT",
                "ADAPTER_OUTPUT_CONTRACT_MISMATCH",
                "CAPTURE_CAP_REACHED",
                "CAPTURE_CLEANUP_FAILED",
                "UNCLASSIFIED",
            ])
        XCTAssertEqual(outer.unknownRawErrorResultCode, "UNCLASSIFIED")
        XCTAssertFalse(outer.rawErrorTextInterpolatedIntoProjection)
        XCTAssertEqual(
            outer.hostedRecordPrefix,
            "prime-secure-child closed-fixture-canary observation: ")
        XCTAssertEqual(outer.hostedRecordPrefixByteCount, 54)
        XCTAssertEqual(
            outer.hostedRecordSchemaID,
            "prime_secure_child_process_evidence_closed_fixture_canary_outer_observation_v1")
        XCTAssertEqual(outer.hostedRecordSchemaVersion, 1)
        XCTAssertTrue(outer.hostedRecordCanonicalJSONRequired)
        XCTAssertEqual(outer.hostedRecordExactLineCount, 1)
        XCTAssertTrue(outer.hostedRecordTerminalLFRequired)
        XCTAssertEqual(outer.hostedRecordTerminalLFByteCount, 1)
        XCTAssertEqual(
            outer.hostedRecordMaximumCanonicalJSONByteCount,
            4_041)
        XCTAssertEqual(outer.hostedRecordMaximumTotalLineByteCount, 4_096)
        XCTAssertEqual(
            outer.hostedRecordOrderedFieldTypeContracts,
            [
                "actions_artifact:bool",
                "adapter_command_attempt_one_shot_consumed:bool",
                "adapter_command_state:enum_not_attempted_shell_command_returned",
                "adapter_execution_observation:enum_observed_true_observed_false_unavailable",
                "adapter_executable_byte_count:null_or_positive_int",
                "adapter_executable_sha256:null_or_lowercase_hex_64",
                "authority_canonical_sha256:lowercase_hex_64",
                "authority_id:utf8_exact",
                "capture_cleanup_absence:enum_observed_true_observed_false_unavailable",
                "durable_evidence:bool",
                "exact_revision:lowercase_git_sha_40",
                "fixture_executable_byte_count:null_or_positive_int",
                "fixture_executable_sha256:null_or_lowercase_hex_64",
                "opportunity_state:enum_retired",
                "result_code:closed_enum",
                "schema_id:utf8_exact",
                "schema_version:positive_int",
                "scientific_outcome:enum_not_established",
                "shell_wait_status:null_or_uint8",
                "standard_error_byte_cap:positive_int",
                "standard_error_captured_byte_count:nonnegative_int",
                "standard_error_capture_cap_reached:bool",
                "standard_error_sha256:lowercase_hex_64",
                "standard_output_byte_cap:positive_int",
                "standard_output_captured_byte_count:nonnegative_int",
                "standard_output_capture_cap_reached:bool",
                "standard_output_sha256:lowercase_hex_64",
            ])
        XCTAssertEqual(outer.hostedRecordExactFieldCount, 27)
        XCTAssertTrue(
            outer
                .hostedRecordExecutableIdentityFieldsNullableForPreCommandRefusal)
        XCTAssertTrue(
            outer.commandAttemptRecordRequiresBothExecutableIdentities)
        XCTAssertTrue(
            outer.identityOrPinRefusalRecordsMeasuredIdentitiesWhenAvailable)
        XCTAssertTrue(
            outer.nonnullFixtureIdentityMustMatchLayerAAcceptancePin)
        XCTAssertEqual(
            outer.hostedRecordAuthorityID,
            authority.authorityID)
        XCTAssertEqual(
            outer.hostedRecordAuthorityCanonicalSHA256ValueSource,
            "PrimeSecureChildProcessEvidenceClosedFixtureCanaryAuthorityV1.canonicalSHA256")
        XCTAssertEqual(
            outer.hostedRecordExactRevisionValueSource,
            "GITHUB_SHA_of_exact3_mechanics_main_push")
        XCTAssertTrue(outer.hostedRecordExactRevisionMustBeLowercaseGitSHA)
        XCTAssertEqual(outer.hostedRecordOpportunityState, "retired")
        XCTAssertEqual(
            outer.hostedRecordScientificOutcome,
            "not_established")
        XCTAssertFalse(outer.hostedRecordDurableEvidenceValue)
        XCTAssertFalse(outer.hostedRecordActionsArtifactValue)
        XCTAssertEqual(outer.hostedRecordRawChildOutputOrErrorFieldCount, 0)
        XCTAssertEqual(
            outer.exactSanitizedOperationalRecordCountWhenProjectionSucceeds,
            1)
        XCTAssertTrue(
            outer.projectionIsOuterOperationalCompatibilityEvidenceOnly)
        XCTAssertFalse(outer.projectionIsLayerADiagnostic)
        XCTAssertFalse(outer.projectionIsScientificEvidence)
        XCTAssertFalse(outer.projectionIsDurableEvidence)
        XCTAssertTrue(
            outer.hostedCancellationOrTimeoutObservedOnlyFromActionsMetadata)
        XCTAssertTrue(
            outer.hostedOperationalRecordMayBeAbsentOnAbruptHostOrRunnerLoss)
        XCTAssertTrue(
            outer
                .hostedOperationalRecordMayBeAbsentOnActiveRootAdmissionRefusal)
        XCTAssertTrue(
            outer
                .hostedOperationalRecordMayBeAbsentOnPreLauncherReviewedJobFailure)
        XCTAssertTrue(
            outer
                .hostedOperationalRecordMayBeAbsentOnLauncherReachedProjectionFailure)
        XCTAssertEqual(
            outer.exactHostedOperationalRecordAbsenceStates,
            [
                "launcher_not_reached",
                "launcher_reached_record_absent",
                "abrupt_host_or_runner_loss",
            ])
        XCTAssertEqual(outer.absentHostedOperationalRecordCount, 0)
        XCTAssertEqual(
            outer.orderedLauncherNotReachedCauses,
            [
                "active_root_gate_failure_or_later_push_admission_refusal",
                "reviewed_toolchain_failure",
                "reviewed_checkout_failure",
                "reviewed_private_dependency_fetch_failure",
                "reviewed_focused_contract_failure",
                "reviewed_retained_live_failure",
            ])
        XCTAssertTrue(outer.launcherNotReachedEstablishesAdapterNotInvoked)
        XCTAssertEqual(outer.launcherNotReachedHostedOperationalRecordCount, 0)
        XCTAssertEqual(outer.launcherNotReachedAdapterCommandAttemptCount, 0)
        XCTAssertFalse(outer.launcherNotReachedEstablishesAdapterTerminalState)
        XCTAssertFalse(outer.launcherNotReachedEstablishesContainmentOrCleanup)
        XCTAssertTrue(outer.launcherNotReachedRetiresMechanicsOpportunity)
        XCTAssertFalse(outer.launcherNotReachedPermitsRetryOrRerun)
        XCTAssertEqual(
            outer.orderedLauncherReachedRecordAbsentCauses,
            [
                "ordinary_shell_failure",
                "hash_failure",
                "stat_failure",
                "canonical_json_projection_failure",
                "trap_projection_failure",
            ])
        XCTAssertTrue(outer.launcherTrapAttemptsUNCLASSIFIEDRecord)
        XCTAssertFalse(outer.launcherTrapRecordEmissionGuaranteed)
        XCTAssertFalse(
            outer.launcherReachedRecordAbsentEstablishesAdapterExecution)
        XCTAssertFalse(
            outer.launcherReachedRecordAbsentEstablishesAdapterTerminalState)
        XCTAssertFalse(
            outer.launcherReachedRecordAbsentEstablishesContainmentOrCleanup)
        XCTAssertTrue(
            outer.launcherReachedRecordAbsentRetiresMechanicsOpportunity)
        XCTAssertFalse(
            outer.launcherReachedRecordAbsentPermitsRetryOrRerun)
        XCTAssertTrue(
            outer
                .absentHostedRecordObservedOnlyFromActionsRunJobStepMetadataAndLogs)
        XCTAssertTrue(outer.activeRootAdmissionRefusalOccursBeforeReviewedJob)
        XCTAssertFalse(
            outer.activeRootAdmissionRefusalEstablishesAdapterInvocation)
        XCTAssertTrue(
            outer.activeRootAdmissionRefusalRetiresMechanicsOpportunity)
        XCTAssertFalse(outer.activeRootAdmissionRefusalPermitsRetryOrRerun)
        XCTAssertTrue(
            outer.preLauncherReviewedJobFailureEstablishesAdapterNotInvoked)
        XCTAssertTrue(
            outer.preLauncherReviewedJobFailureRetiresMechanicsOpportunity)
        XCTAssertFalse(
            outer.preLauncherReviewedJobFailurePermitsAutomaticRerun)
        XCTAssertFalse(outer.absentHostedRecordEstablishesAdapterTerminalState)
        XCTAssertFalse(
            outer.absentHostedRecordEstablishesFixtureOrProcessContainment)
        XCTAssertFalse(
            outer.absentHostedRecordEstablishesCaptureCleanupAbsence)
        XCTAssertTrue(outer.absentHostedRecordRetiresMechanicsOpportunity)
        XCTAssertFalse(outer.absentHostedRecordPermitsRetryOrRerun)
        XCTAssertFalse(
            outer.hostedCancellationOrTimeoutEstablishesContainment)
        XCTAssertEqual(outer.actionsArtifactCount, 0)

        let filesystem = authority.ephemeralFilesystemBoundary
        XCTAssertTrue(filesystem.laterMechanicsMayCreatePrivateTemporaryRoot)
        XCTAssertTrue(
            filesystem
                .laterMechanicsMayCreateFixtureWorkingAndResultDirectories)
        XCTAssertTrue(
            filesystem
                .laterMechanicsMayWriteFixtureResultAndCapturedPrefixFiles)
        XCTAssertTrue(
            filesystem.laterMechanicsMayCopyAndMutatePrivateFixtureExecutable)
        XCTAssertTrue(
            filesystem
                .replacementMutationExistsOnlyToProvePreSpawnRejection)
        XCTAssertFalse(filesystem.replacementExecutableMayRun)
        XCTAssertTrue(filesystem.successfulCanaryAttemptsCleanupBeforeReporting)
        XCTAssertFalse(
            filesystem.privateRootAbsenceEstablishedAsDurableEvidence)
        XCTAssertFalse(filesystem.fsyncUseEstablishesDurableEvidence)
        XCTAssertFalse(filesystem.localPersistenceAuthorizedBeyondInvocation)
        XCTAssertFalse(filesystem.actionsArtifactUploadAuthorized)
        XCTAssertFalse(filesystem.retentionAuthorized)

        let retirement = authority.retirementBoundary
        XCTAssertEqual(retirement.disposition, "observe_once_then_retire")
        XCTAssertTrue(
            retirement.appendOnlyObservationRequiredAfterEveryInvocation)
        XCTAssertTrue(retirement.successRequiresObservationAndRetirement)
        XCTAssertTrue(retirement.failureRequiresObservationAndRetirement)
        XCTAssertTrue(retirement.cancellationRequiresObservationAndRetirement)
        XCTAssertTrue(retirement.setupOutcomeRequiresObservation)
        XCTAssertTrue(retirement.setupOutcomeRetiresMechanicsOpportunity)
        XCTAssertFalse(retirement.setupOutcomeEstablishesCanaryExecution)
        XCTAssertFalse(
            retirement.setupOutcomePermitsRetryWithoutNewAuthority)
        XCTAssertFalse(retirement.monitorOrHostLossEstablishesContainment)
        XCTAssertFalse(retirement.automaticRetryAuthorized)
        XCTAssertFalse(retirement.workflowRerunAuthorized)
        XCTAssertFalse(retirement.replacementExecutionAuthorized)
        XCTAssertFalse(retirement.oldStage7WatchdogRepairAuthorized)
        XCTAssertEqual(retirement.orderedLaterBoundaries.count, 8)

        let language = authority.languageBoundary
        XCTAssertFalse(language.pythonPermitted)
        XCTAssertEqual(language.pythonInvocationCount, 0)
        XCTAssertEqual(language.pythonSourcePathCount, 0)
        XCTAssertEqual(language.cppNewImplementationInvocationCount, 0)
        XCTAssertEqual(language.cppNewSourcePathCount, 0)
        XCTAssertTrue(language.retainedBaselineCppDependencyCompilationMayOccur)
        XCTAssertTrue(
            language.cppFullNativeAlternativeSeparatelyPermissibleLater)
        XCTAssertTrue(
            language.cppSwiftCABIAlternativeSeparatelyPermissibleLater)
        XCTAssertFalse(language.cppAlternativeAuthorizedNow)
        XCTAssertTrue(language.cppAlternativeRequiresSeparateAuthority)

        let ceiling = authority.authorityCeiling
        XCTAssertTrue(ceiling.designAuthorityEstablished)
        XCTAssertTrue(ceiling.implementationAuthorityEstablished)
        XCTAssertTrue(ceiling.layerAExactMainClosureEstablished)
        XCTAssertTrue(ceiling.closedFixtureCanaryAuthorityEstablished)
        XCTAssertTrue(
            ceiling.exactThreeMechanicsSuccessorAuthorizedAfterClosure)
        XCTAssertTrue(authorityFalseClaims(ceiling).allSatisfy { !$0 })

        let repositoryRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let sourceURL = repositoryRoot.appendingPathComponent(
            "Sources/PrimeCore/PrimeSecureChildProcessEvidenceClosedFixtureCanaryAuthority.swift")
        let sourceText = try String(contentsOf: sourceURL, encoding: .utf8)
        let importLines = sourceText.split(separator: "\n").filter {
            $0.hasPrefix("import ")
        }.map(String.init)
        XCTAssertEqual(importLines, ["import Foundation"])
        for forbidden in [
            "import Darwin", "import Dispatch", "import Metal", "import MLX",
            "FileManager.", "FileHandle.", "URLSession", "Process" + "(",
            "posix_" + "spawn(", "wait" + "pid(", "kill" + "(",
            "flock" + "(", "exec" + "ve(", "python" + "3 ",
            "/usr/bin/" + "python", "clang" + "++ ", "g" + "++ ",
        ] {
            XCTAssertFalse(sourceText.contains(forbidden), forbidden)
        }
        let testText = try String(contentsOfFile: #filePath, encoding: .utf8)
        XCTAssertEqual(
            testText.components(separatedBy: "func " + "test").count - 1,
            1)

        requireSendable(Authority.self)
        let canonical = try authority.canonicalData()
        XCTAssertEqual(canonical, try PrimeCanonicalJSON.encode(authority))
        if Authority.canonicalSHA256 == "CANONICAL_SHA256_PLACEHOLDER" {
            XCTFail(
                "canonical freeze byte_count=\(canonical.count) sha256="
                    + PrimeSHA256.hexDigest(of: canonical))
            return
        }
        XCTAssertEqual(canonical.count, Authority.canonicalByteCount)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: canonical),
            Authority.canonicalSHA256)
        XCTAssertEqual(try Authority.decodeCanonical(canonical), authority)
        XCTAssertNoThrow(try authority.validateExactV1())

        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical) as? [String: Any])
        let valuePaths = allValuePaths(in: object)
        let dictionaryPaths = allDictionaryPaths(in: object)
        XCTAssertGreaterThan(valuePaths.count, 300)
        XCTAssertGreaterThan(dictionaryPaths.count, 15)

        for path in valuePaths {
            try assertCanonicalRejects(
                replacingValue(in: object, at: path, with: mutateJSONValue))
            try assertCanonicalRejects(
                replacingValue(in: object, at: path, with: { _ in NSNull() }))
            try assertCanonicalRejects(removingValue(in: object, at: path))
        }

        var reorderedArrayCount = 0
        for path in allArrayPaths(in: object) {
            var changed = false
            let reordered = replacingValue(
                in: object,
                at: path,
                with: { value in
                    var array = value as! [Any]
                    guard array.count >= 2 else { return array }
                    for left in array.indices {
                        for right in array.indices where right > left {
                            if canonicalFragment(array[left])
                                != canonicalFragment(array[right]) {
                                array.swapAt(left, right)
                                changed = true
                                return array
                            }
                        }
                    }
                    return array
                })
            if changed {
                try assertCanonicalRejects(reordered)
                reorderedArrayCount += 1
            }
        }
        XCTAssertGreaterThan(reorderedArrayCount, 8)

        for (index, path) in dictionaryPaths.enumerated() {
            try assertCanonicalRejects(
                replacingValue(
                    in: object,
                    at: path,
                    with: { value in
                        var dictionary = value as! [String: Any]
                        dictionary["unknown_canary_field_\(index)"] = true
                        return dictionary
                    }))
        }

        let pretty = try JSONSerialization.data(
            withJSONObject: object,
            options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
        XCTAssertThrowsError(try Authority.decodeCanonical(pretty))
        XCTAssertThrowsError(
            try Authority.decodeCanonical(Data([0x20]) + canonical))
        XCTAssertThrowsError(
            try Authority.decodeCanonical(canonical + Data([0x0a])))

        var slashEscaped = try XCTUnwrap(
            String(data: canonical, encoding: .utf8))
        let slashIndex = try XCTUnwrap(slashEscaped.firstIndex(of: "/"))
        slashEscaped.replaceSubrange(slashIndex ... slashIndex, with: "\\/")
        XCTAssertThrowsError(
            try Authority.decodeCanonical(Data(slashEscaped.utf8)))

        let schemaField = "\"schemaVersion\":1,"
        var reordered = try XCTUnwrap(
            String(data: canonical, encoding: .utf8))
        let schemaRange = try XCTUnwrap(reordered.range(of: schemaField))
        reordered.removeSubrange(schemaRange)
        let reorderedOpening = try XCTUnwrap(reordered.firstIndex(of: "{"))
        reordered.insert(
            contentsOf: schemaField,
            at: reordered.index(after: reorderedOpening))
        XCTAssertThrowsError(
            try Authority.decodeCanonical(Data(reordered.utf8)))

        var duplicate = try XCTUnwrap(
            String(data: canonical, encoding: .utf8))
        let duplicateOpening = try XCTUnwrap(duplicate.firstIndex(of: "{"))
        duplicate.insert(
            contentsOf: schemaField,
            at: duplicate.index(after: duplicateOpening))
        XCTAssertThrowsError(
            try Authority.decodeCanonical(Data(duplicate.utf8)))
    }

    private enum JSONPathComponent: Equatable {
        case key(String)
        case index(Int)
    }

    private typealias JSONPath = [JSONPathComponent]

    private func authorityFalseClaims(
        _ value:
            PrimeSecureChildProcessEvidenceClosedFixtureCanaryAuthorityV1
                .AuthorityCeiling
    ) -> [Bool] {
        [
            value.processExecutionAuthorizedInThisAuthorityPR,
            value.liveFixtureExecutionAuthorizedInThisAuthorityPR,
            value.integrationAdapterExecutionAuthorizedInThisAuthorityPR,
            value.publicGenericExecutableAuthorityAdded,
            value.publicArbitraryArgumentAuthorityAdded,
            value.publicArbitraryEnvironmentAuthorityAdded,
            value.publicFixtureAPIWideningAuthorized,
            value.layerAMutationAuthorized,
            value.duplicateSpawnWaitSignalImplementationAuthorized,
            value.customDescriptorTransportAuthorized,
            value.hostedDiagnosticProjectionAuthorized,
            value.hostedDiagnosticEmissionAuthorized,
            value.filesystemWriteAuthorizedInThisAuthorityPR,
            value.localEvidencePersistenceAuthorized,
            value.fsyncDurableEvidenceEstablished,
            value.actionsArtifactUploadAuthorized,
            value.retentionAuthorized,
            value.durableEvidenceEstablished,
            value.durableTransactionImplementationAuthorized,
            value.leaseAcquisitionAuthorized,
            value.leaseReleaseOrReacquisitionAuthorized,
            value.leaseDescriptorTransferAuthorized,
            value.leaseOwnerDeathContinuityEstablished,
            value.physicalMetalReservationEstablished,
            value.mlxDeviceIdentityEstablished,
            value.crossHostOrCrossJobLeaseContinuityEstablished,
            value.watchdogRepairAuthorized,
            value.oldLauncherMutationAuthorized,
            value.retryAuthorized,
            value.rerunAuthorized,
            value.replacementExecutionAuthorized,
            value.mlxAuthorized,
            value.metalAuthorized,
            value.native300MExecutionAuthorized,
            value.scientificOutcomeEstablished,
            value.checkpointAdmissionGranted,
            value.stage8Authorized,
            value.stage8AuthorityEstablished,
            value.generalTrainingResumeAuthorized,
            value.modelQualityEstablished,
            value.candidateAdmissionAuthorized,
            value.downstreamTrialAuthorized,
            value.productUseAuthorized,
            value.quantizationAuthorized,
            value.publicationAuthorized,
        ]
    }

    private func requireSendable<T: Sendable>(_: T.Type) {}

    private func allValuePaths(
        in value: Any,
        prefix: JSONPath = []
    ) -> [JSONPath] {
        if let object = value as? [String: Any] {
            return object.keys.sorted().flatMap { key in
                let path = prefix + [.key(key)]
                return [path] + allValuePaths(
                    in: object[key]!,
                    prefix: path)
            }
        }
        if let array = value as? [Any] {
            return array.indices.flatMap { index in
                let path = prefix + [.index(index)]
                return [path] + allValuePaths(
                    in: array[index],
                    prefix: path)
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

    private func allArrayPaths(
        in value: Any,
        prefix: JSONPath = []
    ) -> [JSONPath] {
        if let object = value as? [String: Any] {
            return object.keys.sorted().flatMap { key in
                allArrayPaths(
                    in: object[key]!,
                    prefix: prefix + [.key(key)])
            }
        }
        if let array = value as? [Any] {
            return [prefix] + array.indices.flatMap { index in
                allArrayPaths(
                    in: array[index],
                    prefix: prefix + [.index(index)])
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
                with: transform)
            return object
        case let .index(index):
            var array = value as! [Any]
            array[index] = replacingValue(
                in: array[index],
                at: remainder,
                with: transform)
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
                    at: remainder)
            }
            return object
        case let .index(index):
            var array = value as! [Any]
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
            array.append("__mutation")
            return array
        }
        if var object = value as? [String: Any] {
            object["__mutation"] = true
            return object
        }
        return "__mutation"
    }

    private func canonicalFragment(_ value: Any) -> Data {
        (try? JSONSerialization.data(
            withJSONObject: [value],
            options: [.sortedKeys, .withoutEscapingSlashes])) ?? Data()
    }

    private func assertCanonicalRejects(
        _ object: Any,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let data = try JSONSerialization.data(
            withJSONObject: object,
            options: [.sortedKeys, .withoutEscapingSlashes])
        XCTAssertThrowsError(
            try PrimeSecureChildProcessEvidenceClosedFixtureCanaryAuthorityV1
                .decodeCanonical(data),
            file: file,
            line: line)
    }
}
