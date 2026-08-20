// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
@testable import PrimeCore
import XCTest

final class PrimeSecureChildValidationFixtureIdentityMeasurementAuthorityTests:
    XCTestCase
{
    private typealias Authority =
        PrimeSecureChildValidationFixtureIdentityMeasurementAuthorityV1

    func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndAuthorityCeiling()
        throws
    {
        requireSendable(Authority.self)
        let authority = Authority.frozenV1

        XCTAssertEqual(authority.schemaVersion, 1)
        XCTAssertEqual(
            authority.schemaID,
            "prime_secure_child_validation_fixture_identity_measurement_authority_v1"
        )
        XCTAssertEqual(
            authority.authorityID,
            "ergentics_prime_secure_child_validation_fixture_identity_measurement_authority_v1"
        )
        XCTAssertEqual(
            authority.authorityKind,
            "pure_authority_for_one_later_native_repeat_build_validation_fixture_identity_measurement"
        )
        XCTAssertEqual(
            authority.status,
            "AUTHORITY_ONLY_future_exact5_native_fixture_identity_measurement_no_current_mechanics_pin_repair_canary_false"
        )

        XCTAssertEqual(authority.predecessorFiles.count, 5)
        XCTAssertEqual(
            authority.predecessorFiles.map(\.path),
            [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                "Sources/PrimeCore/PrimeMonitorHeldLeaseSecureChildContainment.swift",
                "Tests/PrimeCoreTests/PrimeMonitorHeldLeaseSecureChildContainmentTests.swift",
            ]
        )
        XCTAssertEqual(
            authority.predecessorFiles.map(\.gitStatus),
            ["M", "M", "M", "A", "A"]
        )
        XCTAssertEqual(
            authority.predecessorFiles.map(\.gitMode),
            ["100755", "100644", "100644", "100644", "100644"]
        )
        XCTAssertEqual(
            authority.predecessorFiles.map(\.gitBlob),
            [
                "70d8946fb5fae117b67426a2c6b9c13935d4bee8",
                "c2473bf53462e44e837429b7140320cede65d020",
                "9be87f801ed0290659d612c6fd6453137a47a46c",
                "bc101249a70522ec0080c3064be7668c5cff1425",
                "e16b70540ad3215984bf3389b4cb109e09c16368",
            ]
        )
        XCTAssertEqual(
            authority.predecessorFiles.map(\.byteCount),
            [1_324_722, 164_657, 546, 3_940, 4_018]
        )
        XCTAssertEqual(
            authority.predecessorFiles.map(\.lfByteCount),
            [21_670, 726, 13, 108, 116]
        )
        XCTAssertEqual(
            authority.predecessorFiles.map(\.sha256),
            [
                "3b6d68f95d98cd181aee28c2cb0d8be644a621493c93679136d7fef0bcc99c27",
                "cb8505522cf8bbff51517ae0158408048798cd41b9b2b632ebb1c0ddabbf7ce5",
                "7b6ab69f587fb8b0b336cc983e126e7ea8b71664ec2a26e6f66dd794d2cc8cac",
                "5253f74c363825617dc25e8ef66f0fda95e285969d4b24fee0d975585fba7dba",
                "069e1091461ce680938185bfeca3001a3a164018d491a805782b52690109933c",
            ]
        )
        XCTAssertEqual(Set(authority.predecessorFiles.map(\.path)).count, 5)

        let repository = authority.predecessorRepositoryClosure
        XCTAssertEqual(repository.repository, "Ergentics/ergentics-prime")
        XCTAssertEqual(repository.pullRequestNumber, 128)
        XCTAssertEqual(
            repository.baseRevision,
            "3ad8087ed6e403ba81f46bba97ceb5d440979e0a"
        )
        XCTAssertEqual(
            repository.reviewedHeadRevision,
            "e1f9fa486ee5fadccc62cb795fea11fbf85ff394"
        )
        XCTAssertEqual(
            repository.reviewedHeadSoleParentRevision,
            repository.baseRevision
        )
        XCTAssertEqual(
            repository.reviewedHeadTree,
            "c3c325a0b24513030fd3e5228926094371f7a3a4"
        )
        XCTAssertEqual(
            repository.mergeRevision,
            "75b14056b75e8af6af0c070453f7ef14ac10a063"
        )
        XCTAssertEqual(repository.mergeTree, repository.reviewedHeadTree)
        XCTAssertEqual(
            repository.orderedMergeParentRevisions,
            [repository.baseRevision, repository.reviewedHeadRevision]
        )
        XCTAssertTrue(repository.mergeTreeEqualsReviewedHeadTree)
        XCTAssertTrue(repository.reviewedHeadHasExactlyOneParentEqualBase)
        XCTAssertTrue(repository.historyPreservingTwoParentMergeObserved)
        XCTAssertTrue(repository.githubSignatureVerified)
        XCTAssertEqual(repository.githubSignatureReason, "valid")
        XCTAssertEqual(
            repository.githubSignatureVerifiedAt,
            "2026-08-20T08:24:07Z"
        )
        XCTAssertEqual(repository.mergedAt, "2026-08-20T08:24:07Z")

        assertRun(
            authority.predecessorPullRequestRun,
            id: 32_347_997_651,
            number: 155,
            suite: 87_689_058_666,
            event: "pull_request",
            ref: "refs/pull/128/merge",
            head: repository.reviewedHeadRevision,
            activeJob: 96_360_762_572,
            reviewedJob: 96_361_700_232,
            reviewedConclusion: "skipped",
            reviewedSteps: 0,
            root: 0,
            isolated: [],
            focused: 0,
            live: 0,
            aggregate: 0,
            soleTestStarts: 0,
            created: "2026-08-20T08:16:30Z",
            updated: "2026-08-20T08:20:14Z"
        )
        assertRun(
            authority.predecessorPushMainRun,
            id: 32_348_627_200,
            number: 156,
            suite: 87_690_727_033,
            event: "push",
            ref: "refs/heads/main",
            head: repository.mergeRevision,
            activeJob: 96_362_688_446,
            reviewedJob: 96_363_809_495,
            reviewedConclusion: "success",
            reviewedSteps: 7,
            root: 84,
            isolated: [1, 1, 2, 2],
            focused: 90,
            live: 46,
            aggregate: 136,
            soleTestStarts: 1,
            created: "2026-08-20T08:24:09Z",
            updated: "2026-08-20T09:22:12Z"
        )

        let mismatch = authority.pinMismatchPredecessor
        XCTAssertEqual(
            mismatch.observationID,
            "prime_secure_child_process_evidence_closed_fixture_canary_pin_mismatch_execution_observation_v1"
        )
        XCTAssertEqual(mismatch.observationCanonicalByteCount, 12_604)
        XCTAssertEqual(
            mismatch.observationCanonicalSHA256,
            "327a3fedcd1fed6a936aa053c3882c770a106db7e2662e76815a2b5d21333e16"
        )
        XCTAssertEqual(
            mismatch.observationSource.gitBlob,
            "bd84b810a1842635b7e874826b7c58cf42baacda"
        )
        XCTAssertEqual(mismatch.observationSource.byteCount, 52_517)
        XCTAssertEqual(mismatch.observationSource.lfByteCount, 1_103)
        XCTAssertEqual(
            mismatch.mechanicsMergeRevision,
            "d825c5366135cc6ef8d0c9dc7d26d3d2e4300ba6"
        )
        XCTAssertEqual(mismatch.workflowRunID, 31_974_943_697)
        XCTAssertEqual(mismatch.workflowRunNumber, 143)
        XCTAssertEqual(mismatch.workflowRunAttempt, 1)
        XCTAssertEqual(mismatch.checkSuiteID, 86_694_964_833)
        XCTAssertEqual(mismatch.activeRootJobID, 95_232_879_059)
        XCTAssertEqual(mismatch.reviewedMainJobID, 95_233_206_587)
        XCTAssertEqual(mismatch.workflowConclusion, "failure")
        XCTAssertEqual(mismatch.hostedRecordCount, 1)
        XCTAssertEqual(mismatch.resultCode, "PIN_MISMATCH")
        XCTAssertEqual(mismatch.configuredFixtureByteCount, 89_632)
        XCTAssertEqual(
            mismatch.configuredFixtureSHA256,
            "eae9573027fe736cab0d4aa319ae43f22231eaef9c55af91d73fbe3d87bc9ebd"
        )
        XCTAssertFalse(mismatch.measuredFixtureByteCountPublished)
        XCTAssertFalse(mismatch.measuredFixtureSHA256Published)
        XCTAssertFalse(mismatch.mismatchDimensionEstablished)
        XCTAssertEqual(mismatch.adapterCommandAttemptCount, 0)
        XCTAssertEqual(mismatch.fixtureProcessExecutionCount, 0)
        XCTAssertTrue(mismatch.mechanicsOpportunityRetired)
        XCTAssertFalse(mismatch.retryAuthorized)
        XCTAssertFalse(mismatch.rerunAuthorized)
        XCTAssertTrue(mismatch.distinctMeasurementAuthorityRequired)

        let origin = authority.historicalPINOrigin
        XCTAssertEqual(origin.pullRequestNumber, 50)
        XCTAssertEqual(
            origin.integrationRevision,
            "3605a076d119c2b0da4f592de1f950d071500c81"
        )
        XCTAssertEqual(
            origin.integrationTree,
            "633f74843024cd94bbe929dfc3b7615478a14fb0"
        )
        XCTAssertEqual(
            origin.orderedParentRevisions,
            ["d436c4f0c116d07ee8b4baea3ae4070207b8e325"]
        )
        XCTAssertEqual(
            origin.integrationKind,
            "signed_one_parent_integration_revision"
        )
        XCTAssertTrue(origin.githubSignatureVerified)
        XCTAssertEqual(origin.githubSignatureReason, "valid")
        XCTAssertEqual(origin.githubSignatureVerifiedAt, "2026-08-03T11:49:49Z")
        XCTAssertEqual(origin.configuredFixtureByteCount, 89_632)
        XCTAssertEqual(
            origin.configuredFixtureSHA256,
            mismatch.configuredFixtureSHA256
        )
        XCTAssertEqual(
            origin.historicalDocumentationReportedMachOUUID,
            "6ABE4B24-C019-3372-8144-C85CCEE5BA19"
        )
        XCTAssertFalse(origin.historicalMachOUUIDIsAcceptanceCriterion)
        XCTAssertEqual(
            origin.historicalManifest.gitBlob,
            "fe98104c7e812d0c44ee1e38dcc10857455bf54f"
        )
        XCTAssertEqual(
            origin.historicalPackageLock.gitBlob,
            "8f2126bdbb71142e78c69b5e4c670efac58daf37"
        )
        XCTAssertEqual(
            origin.historicalMirrorConfiguration.gitBlob,
            "92e6bf7a3f31367f87f6a4c69d7269d5c07848a0"
        )
        XCTAssertEqual(
            origin.historicalFixtureSource.gitBlob,
            "5e45832ed046da7bfd4541ad362018fad97371f5"
        )
        XCTAssertEqual(
            origin.historicalPINSource.gitBlob,
            "b675cd443c5684933a3636d1e937aab74ed4b5dc"
        )
        XCTAssertTrue(origin.manifestBlobUnchangedAtCurrentClosure)
        XCTAssertTrue(origin.fixtureSourceBlobUnchangedAtCurrentClosure)
        XCTAssertFalse(origin.packageLockBlobUnchangedAtCurrentClosure)
        XCTAssertFalse(origin.mirrorBlobUnchangedAtCurrentClosure)
        XCTAssertFalse(origin.compilerIdentityFrozenByHistoricalPIN)
        XCTAssertFalse(origin.sdkIdentityFrozenByHistoricalPIN)
        XCTAssertFalse(origin.buildEnvironmentFrozenByHistoricalPIN)
        XCTAssertFalse(origin.run143MismatchCauseEstablished)
        XCTAssertEqual(origin.unresolvedCauseEnvelope.count, 4)

        let inventory = authority.fixtureInputInventory
        XCTAssertEqual(inventory.exactFileCount, 5)
        XCTAssertEqual(inventory.orderedFiles.count, 5)
        XCTAssertEqual(Set(inventory.orderedFiles.map(\.path)).count, 5)
        XCTAssertEqual(
            inventory.orderedFiles.map(\.gitBlob),
            [
                "fe98104c7e812d0c44ee1e38dcc10857455bf54f",
                "69919288b1a5da256ff408a4d65106b23abc8f89",
                "be0c6cc4685f3fde2b5c747118478397bc34dcf8",
                "5e45832ed046da7bfd4541ad362018fad97371f5",
                "bfa381796b9647863e704006dbaa1406c533c7c5",
            ]
        )
        XCTAssertEqual(
            inventory.orderedFiles.map(\.byteCount),
            [2_587, 645, 37, 19_353, 83_657]
        )
        XCTAssertEqual(
            inventory.orderedFiles.map(\.lfByteCount),
            [88, 23, 4, 614, 2_327]
        )
        XCTAssertEqual(inventory.packagePath, "Tests/PrimeValidationWorkflow")
        XCTAssertEqual(
            inventory.fixtureProductName,
            "PrimeValidationWorkflowFixtureChild"
        )
        XCTAssertEqual(inventory.fixtureTargetName, inventory.fixtureProductName)
        XCTAssertEqual(inventory.fixtureExecutableLeaf, inventory.fixtureProductName)
        XCTAssertEqual(inventory.currentAcceptancePinByteCount, 89_632)
        XCTAssertEqual(
            inventory.currentAcceptancePinSHA256,
            mismatch.configuredFixtureSHA256
        )
        XCTAssertEqual(
            inventory.currentAcceptancePinSourceType,
            "PrimeSecureChildFixtureBinaryPin"
        )
        XCTAssertTrue(inventoryMutations(authority).allSatisfy { !$0 })

        let scope = authority.authorityScope
        assertExactFive(
            scope.exactOrderedPaths,
            source:
                "Sources/PrimeCore/PrimeSecureChildValidationFixtureIdentityMeasurementAuthority.swift",
            test:
                "Tests/PrimeCoreTests/PrimeSecureChildValidationFixtureIdentityMeasurementAuthorityTests.swift"
        )
        XCTAssertEqual(scope.exactPathCount, 5)
        XCTAssertEqual(scope.activeRootLatinTestCount, 116)
        XCTAssertEqual(scope.rootTestCount, 85)
        XCTAssertEqual(scope.isolatedGroupTestCounts, [1, 1, 2, 2])
        XCTAssertEqual(scope.isolatedTestCount, 6)
        XCTAssertEqual(scope.focusedWholeTestCount, 91)
        XCTAssertEqual(scope.rootTestCount + scope.isolatedTestCount, 91)
        XCTAssertEqual(scope.retainedLiveTestCount, 46)
        XCTAssertEqual(scope.aggregateTestCount, 137)
        XCTAssertEqual(
            scope.focusedWholeTestCount + scope.retainedLiveTestCount,
            scope.aggregateTestCount
        )
        XCTAssertEqual(scope.embeddedProvenanceRecordCount, 521)
        XCTAssertEqual(
            scope.soleAuthorityTestClassName,
            "PrimeSecureChildValidationFixtureIdentityMeasurementAuthorityTests"
        )
        XCTAssertEqual(
            scope.soleAuthorityTestMethodName,
            "testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndAuthorityCeiling"
        )
        XCTAssertEqual(scope.soleAuthorityTestExpectedStartCount, 1)
        XCTAssertEqual(scope.soleAuthorityTestExpectedPassCount, 1)
        XCTAssertEqual(scope.addedProofOnlyHistoricalWant, repository.baseRevision)
        XCTAssertEqual(scope.addedProofOnlyWantCountPerExistingFetch, 1)
        XCTAssertTrue(scope.exactPrimeFetchInvocationCountPerCheckoutRemainsOne)
        XCTAssertTrue(scope.fetchDepthRemainsTwo)
        XCTAssertTrue(scope.workflowJobAndStepTopologyMustRemainUnchanged)
        XCTAssertTrue(scope.retainedLiveCommandsMustRemainByteIdentical)
        XCTAssertTrue(scope.packageManifestMustRemainByteIdentical)
        XCTAssertTrue(scope.packageLockMustRemainByteIdentical)
        XCTAssertTrue(scope.mirrorMustRemainByteIdentical)
        XCTAssertTrue(scope.fixtureSourceMustRemainByteIdentical)
        XCTAssertTrue(scope.secureChildKernelMustRemainByteIdentical)
        XCTAssertTrue(scope.a2ImplementationPairMustRemainByteIdentical)
        XCTAssertFalse(scope.implementationIncludedInThisPatch)
        XCTAssertTrue(scope.measurementAuthorizedOnlyAfterAuthorityExactMainGreen)
        XCTAssertFalse(scope.authorityExactMainGreenObservedAtAuthoring)

        let future = authority.futureMeasurementContract
        XCTAssertEqual(future.exactPathCount, 5)
        XCTAssertEqual(future.modifiedExistingPathCount, 3)
        XCTAssertEqual(future.addedPathCount, 2)
        XCTAssertEqual(
            future.exactOrderedPaths.map(\.gitStatus),
            ["M", "M", "M", "A", "A"]
        )
        XCTAssertEqual(
            future.exactOrderedPaths.map(\.path),
            [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                ".github/scripts/prime-ci-secure-child-validation-fixture-identity-measurement.sh",
                "Tests/PrimeValidationWorkflow/Tools/PrimeSecureChildValidationFixtureIdentityEvaluator.swift",
            ]
        )
        XCTAssertEqual(
            future.shellLauncherPath,
            future.exactOrderedPaths[3].path
        )
        XCTAssertTrue(future.authorizedOnlyAfterAuthorityExactMainGreen)
        XCTAssertFalse(future.currentAuthorityExecutesMeasurement)
        XCTAssertTrue(future.mainPushOnly)
        XCTAssertEqual(future.requiredRepository, "Ergentics/ergentics-prime")
        XCTAssertEqual(future.requiredEvent, "push")
        XCTAssertEqual(future.requiredRef, "refs/heads/main")
        XCTAssertEqual(future.requiredRunAttempt, 1)
        XCTAssertTrue(future.mechanicsRevisionMustBeDirectSuccessorOfAuthorityClosure)
        XCTAssertTrue(future.mechanicsFirstParentMustEqualAuthorityClosureRevision)
        XCTAssertTrue(future.mechanicsFirstParentTreeMustEqualAuthorityClosureTree)
        XCTAssertEqual(future.expectedMechanicsMergeParentCount, 2)
        XCTAssertTrue(future.exactFiveDeltaRequired)
        XCTAssertTrue(future.cleanDetachedCheckoutRequired)
        XCTAssertTrue(future.twoDisjointExactTreeSourceRootsRequired)
        XCTAssertTrue(future.sourceRootDeviceInodeIdentityTupleDisjointRequired)
        XCTAssertTrue(future.sourceRootsMustShareTrustedLocalDevice)
        XCTAssertTrue(future.sourceRootInodesMustDiffer)
        XCTAssertTrue(future.sourceRootsMustResolveToExactRevisionAndTree)
        XCTAssertFalse(future.sourceRootHardLinkSharingAuthorized)
        XCTAssertTrue(future.twoDisjointBuildRootSetsRequired)
        XCTAssertEqual(
            future.buildRootRoles,
            ["scratch", "cache", "config", "security"]
        )
        XCTAssertEqual(future.buildRootMode, "0700")
        XCTAssertTrue(future.buildRootsMustInitiallyNotExistOrBeSymbolicLinks)
        XCTAssertEqual(
            future.measurementCreatedRootSetRoles,
            [
                "measurement_private_base",
                "exact_tree_source_a",
                "exact_tree_source_b",
                "fixture_build_root_set_a",
                "fixture_build_root_set_b",
                "evaluator_private_root",
            ]
        )
        XCTAssertEqual(future.measurementCreatedRootSetCount, 6)
        XCTAssertEqual(
            future.measurementCreatedRootLauncherCleanupInvocationCount,
            0
        )
        XCTAssertTrue(
            future
                .measurementCreatedRootsRetainedOnlyUntilOrdinaryEphemeralRunnerTeardown
        )
        XCTAssertFalse(future.measurementCreatedRootResidualFilesAreEvidence)
        XCTAssertFalse(future.measurementCreatedRootReuseOrRetryAuthorized)
        XCTAssertTrue(
            future.boundedRecordProjectionIsFinalDataProducingLauncherAction
        )
        XCTAssertTrue(
            future.boundedRecordProjectionUsesSingleBashBuiltinPrintf
        )
        XCTAssertTrue(
            future
                .onlyPostProjectionControlActionIsExactExitWithFrozenResultStatus
        )
        XCTAssertEqual(future.successResultLauncherExitStatus, 0)
        XCTAssertEqual(future.failureResultLauncherExitStatus, 1)
        XCTAssertEqual(future.buildConfiguration, "release")
        XCTAssertTrue(
            future.buildArgumentsMustMatchRetiredCanaryFixtureBuildExactly
        )
        XCTAssertEqual(future.additionalFixtureCompilerFlagCount, 0)
        XCTAssertFalse(future.debugPrefixMapAuthorized)
        XCTAssertEqual(future.expectedFixtureProductBuildCommandCount, 2)
        XCTAssertEqual(future.expectedShowBinPathCommandCount, 2)
        XCTAssertEqual(
            [
                future.expectedSwiftRunCommandCount,
                future.expectedSwiftTestCommandCount,
                future.expectedFixtureExecutableInvocationCount,
                future.expectedAdapterInvocationCount,
                future.expectedLeaseAcquisitionCount,
                future.expectedModelExecutionCount,
                future.expectedMLXExecutionCount,
                future.expectedMetalExecutionCount,
                future.dependencyNetworkInvocationCount,
            ],
            Array(repeating: 0, count: 9)
        )
        XCTAssertTrue(future.exactLocalMirrorReuseRequired)
        XCTAssertTrue(future.forceResolvedVersionsRequired)
        XCTAssertTrue(future.swiftPMSandboxRetained)
        XCTAssertEqual(future.fixtureTargetDirectDependencyCount, 0)
        XCTAssertEqual(future.fixturePackagePluginTargetCount, 0)
        XCTAssertEqual(future.fixturePackageMacroTargetCount, 0)
        XCTAssertEqual(future.fixturePackageBinaryTargetCount, 0)
        XCTAssertFalse(
            future
                .fixtureBuildGraphExecutesPackagePluginMacroOrBinaryTargetCode
        )
        XCTAssertTrue(
            future
                .allFixtureBuildAndShowBinSubprocessesMustBeWaitedAndReapedBeforeEvaluatorSourceAdmission
        )
        XCTAssertFalse(
            future.hostileConcurrentSameEffectiveUIDMutationWithinThreatScope
        )
        XCTAssertFalse(
            future
                .privateMode0700ClaimedToProtectAgainstHostileSameEffectiveUID
        )
        XCTAssertTrue(
            future
                .residualNameOpenTOCTOUAcceptedOnlyUnderTrustedNoHostileConcurrentSameUIDBoundary
        )
        XCTAssertTrue(future.releaseBuildAAndBByteIdentityCompared)
        XCTAssertTrue(future.releaseBuildAAndBSHA256Compared)
        XCTAssertTrue(future.releaseBuildAAndBMachOIdentityCompared)
        XCTAssertTrue(future.buildAndCompilerSubprocessesAreNotFixtureExecution)
        XCTAssertTrue(future.measurementAttemptConsumedImmediatelyBeforeFirstBuild)
        XCTAssertFalse(future.preBuildRefusalConsumesMeasurementAttempt)
        XCTAssertTrue(future.everyPostConsumptionOutcomeRetiresOpportunity)
        XCTAssertTrue(
            future
                .everyAdmissionSetupBuildEvaluatorOrAbsentOutcomeRetiresOpportunity
        )
        XCTAssertFalse(future.automaticRetryAuthorized)
        XCTAssertFalse(future.workflowRerunAuthorized)
        XCTAssertFalse(future.replacementMeasurementAuthorized)
        XCTAssertEqual(future.expectedActiveRootLatinTestCount, 116)
        XCTAssertEqual(future.expectedRootTestCount, 85)
        XCTAssertEqual(future.expectedIsolatedTestCount, 6)
        XCTAssertEqual(future.expectedFocusedWholeTestCount, 91)
        XCTAssertEqual(future.expectedRetainedLiveTestCount, 46)
        XCTAssertEqual(future.expectedAggregateTestCount, 137)
        XCTAssertEqual(future.expectedEmbeddedProvenanceRecordCount, 522)
        XCTAssertTrue(
            future.observationMustFreezeExistingSanitizedToolchainStepValues
        )
        XCTAssertTrue(future.observationMustFreezeReviewedJobLogIdentity)
        XCTAssertFalse(future.lcBuildVersionEstablishesSameCompilerIdentity)

        let roots = future.measurementRoots
        XCTAssertEqual(roots.runnerTempEnvironmentKey, "RUNNER_TEMP")
        XCTAssertEqual(roots.runnerTempMaximumUTF8ByteCount, 1_024)
        XCTAssertTrue(
            roots.runnerTempMustBeNonemptyCanonicalAbsolutePhysicalDirectory
        )
        XCTAssertTrue(roots.runnerTempMustBeNonlinkAndOwnedByEffectiveUser)
        XCTAssertTrue(roots.runnerTempPhysicalDeviceIdentityCaptured)
        XCTAssertTrue(
            roots
                .runnerTempDeviceMustEqualFixedCanonicalExactCheckoutRootDevice
        )
        XCTAssertTrue(
            roots
                .fixedCanonicalExactCheckoutRootDeviceIsTrustedLocalBoundary
        )
        XCTAssertTrue(
            roots
                .fixedCanonicalExactCheckoutRootNameAndDescriptorJoinRequired
        )
        XCTAssertTrue(
            roots
                .fixedCanonicalExactCheckoutRootJoinAlsoBindsEvaluatorSourceAnchor
        )
        XCTAssertEqual(
            roots.privateBaseLeaf,
            "prime-secure-child-validation-fixture-identity-measurement-root-v1"
        )
        XCTAssertEqual(roots.privateBaseMode, "0700")
        XCTAssertTrue(roots.privateBaseMustInitiallyBeAbsentAndNonlink)
        XCTAssertTrue(roots.privateBaseCreatedExclusivelyWithOwnerOnlyUmask)
        XCTAssertTrue(roots.privateBaseMustBeCanonicalAbsolutePhysicalDirectory)
        XCTAssertTrue(
            roots.privateBaseMustBeOwnedByEffectiveUserAndShareRunnerTempDevice
        )
        XCTAssertTrue(roots.privateBaseExactModeRequired)
        XCTAssertEqual(roots.directoryAdmissionDescriptorNumber, 9)
        XCTAssertEqual(roots.metadataExecutablePath, "/usr/bin/stat")
        XCTAssertEqual(roots.metadataExactLocaleEnvironment, "LC_ALL=C")
        XCTAssertEqual(roots.metadataFormat, "%d:%i:%u:%Lp")
        XCTAssertEqual(
            roots.orderedDescriptorMetadataArguments,
            ["literal_-f", "literal_%d:%i:%u:%Lp"]
        )
        XCTAssertTrue(
            roots
                .descriptorMetadataUsesNoFileOperandAndStdinRedirectedFromFixedDirectoryFD
        )
        XCTAssertEqual(
            roots.orderedNameMetadataArgumentPrefix,
            ["literal_-f", "literal_%d:%i:%u:%Lp", "literal_--"]
        )
        XCTAssertTrue(
            roots.nameMetadataUsesOneFixedCanonicalAbsoluteDirectoryOperand
        )
        XCTAssertEqual(roots.exactDirectoryIdentityJoinCount, 8)
        XCTAssertEqual(roots.exactMetadataInvocationCountPerIdentityJoin, 2)
        XCTAssertEqual(roots.exactMetadataInvocationAndCaptureCount, 16)
        XCTAssertEqual(
            roots.exactDirectoryIdentityJoinCount
                * roots.exactMetadataInvocationCountPerIdentityJoin,
            roots.exactMetadataInvocationAndCaptureCount
        )
        XCTAssertEqual(
            roots.metadataProducerMaximumByteCountIncludingTerminalLF,
            58
        )
        XCTAssertEqual(roots.normalizedMetadataMaximumByteCount, 57)
        XCTAssertEqual(
            roots.metadataProducerMaximumByteCountIncludingTerminalLF,
            roots.normalizedMetadataMaximumByteCount + 1
        )
        XCTAssertEqual(
            roots.normalizedMetadataExactASCIIGrammar,
            "^(0|[1-9][0-9]{0,19}):(0|[1-9][0-9]{0,19}):(0|[1-9][0-9]{0,9}):[0-7]{3,4}$"
        )
        XCTAssertEqual(
            roots.metadataNumericConversionsUseCheckedExactWidths,
            "device_UInt64_inode_UInt64_owner_UInt32_mode_UInt16"
        )
        XCTAssertTrue(
            roots
                .metadataProducerEmitsOneLFAndBashSubstitutionStripsOnlyThatLF
        )
        XCTAssertTrue(
            roots
                .directCommandSubstitutionAuthorizedOnlyForProvenFixedFormatBound
        )
        XCTAssertEqual(roots.metadataRawPathOutputFieldCount, 0)
        XCTAssertEqual(
            roots
                .metadataNonzeroStatusOverflowGrammarOrIdentityMismatchFailureMappingByRole,
            [
                "fixed_canonical_exact_checkout_root:MEASUREMENT_ROOT_REFUSED",
                "runner_temp_or_private_base:MEASUREMENT_ROOT_REFUSED",
                "exact_tree_source_a_or_b:SOURCE_ROOT_REFUSED",
                "fixture_build_root_set_a_or_b:BUILD_ROOT_REFUSED",
                "evaluator_root:EVALUATOR_ROOT_REFUSED",
            ]
        )
        XCTAssertTrue(
            roots
                .runnerTempAndPrivateBaseNameAndDescriptorStatRequiredAtAdmission
        )
        XCTAssertTrue(
            roots
                .runnerTempAndPrivateBaseDescriptorNameDeviceInodeJoinRequired
        )
        XCTAssertTrue(
            roots
                .admittedDirectoryIdentityStabilityReliesOnTrustedNoHostileConcurrentSameUIDBoundary
        )
        XCTAssertEqual(
            roots.exactTreeSourceRootLeaves,
            ["exact-tree-source-a-v1", "exact-tree-source-b-v1"]
        )
        XCTAssertEqual(
            roots.fixtureBuildRootSetLeaves,
            ["fixture-build-root-set-a-v1", "fixture-build-root-set-b-v1"]
        )
        XCTAssertEqual(roots.exactDirectChildRootLeafCount, 5)
        let derivedRootLeaves = roots.exactTreeSourceRootLeaves
            + roots.fixtureBuildRootSetLeaves + [roots.evaluatorRootLeaf]
        XCTAssertEqual(derivedRootLeaves.count, roots.exactDirectChildRootLeafCount)
        XCTAssertEqual(Set(derivedRootLeaves).count, derivedRootLeaves.count)
        XCTAssertTrue(
            derivedRootLeaves.allSatisfy {
                !$0.isEmpty && $0 != "." && $0 != ".." && !$0.contains("/")
            }
        )
        XCTAssertEqual(roots.derivedRootMode, "0700")
        XCTAssertTrue(
            roots
                .everyDerivedRootLeafMustBeSingleComponentWithoutSeparatorDotOrDotDot
        )
        XCTAssertTrue(
            roots.everyDerivedRootMustBeCanonicalAbsoluteDirectChildOfPrivateBase
        )
        XCTAssertTrue(roots.everyDerivedRootInitiallyAbsentAndNonlink)
        XCTAssertTrue(roots.everyDerivedRootCreatedExclusivelyAsApplicable)
        XCTAssertTrue(
            roots
                .everyDerivedRootOwnerDeviceModeAndDescriptorNameJoinRequired
        )
        XCTAssertTrue(roots.everyDerivedRootMustSharePrivateBaseDevice)
        XCTAssertTrue(
            roots
                .derivedRootDeviceInodeIdentityTuplesMustBePairwiseDistinct
        )
        XCTAssertFalse(roots.derivedRootHardLinkSharingAuthorized)
        XCTAssertFalse(
            roots.directoryLinkCountUsedAsStablePredicateAfterChildCreation
        )
        XCTAssertTrue(
            roots
                .evaluatorExecutableAbsolutePathMustDeriveOnlyFromPrivateBaseEvaluatorRootAndFixedLeaf
        )
        XCTAssertTrue(
            roots
                .allDirectoryAdmissionDescriptorsClosedBeforeEverySubsequentExternalCommand
        )
        XCTAssertTrue(
            roots.hostileConcurrentSameEffectiveUIDMutationOutsideThreatScope
        )

        let evaluator = future.evaluator
        XCTAssertEqual(evaluator.sourcePath, future.exactOrderedPaths[4].path)
        XCTAssertEqual(
            evaluator.requiredImports,
            ["CryptoKit", "Darwin", "Foundation", "MachO"]
        )
        XCTAssertEqual(evaluator.compilerExecutablePath, "/usr/bin/xcrun")
        XCTAssertEqual(evaluator.orderedCompilerArgumentPrefix, ["swiftc"])
        XCTAssertEqual(
            evaluator.orderedCompilerArgumentRolesAfterPrefix,
            [
                "fixed_canonical_absolute_evaluator_source_under_exact_checkout_root",
                "literal_-o",
                "fixed_private_evaluator_output_path",
            ]
        )
        XCTAssertEqual(evaluator.compilerAdditionalArgumentCount, 0)
        XCTAssertEqual(evaluator.compilerInvocationCount, 1)
        XCTAssertEqual(evaluator.evaluatorInvocationCount, 1)
        XCTAssertTrue(
            evaluator
                .compilerRunsAfterArtifactBAdmissionImmediatelyBeforeEvaluatorAdmissionAndInvocation
        )
        XCTAssertTrue(
            evaluator
                .evaluatorTrackedSourceMustMatchExactMechanicsRevisionImmediatelyBeforeCompiler
        )
        XCTAssertEqual(
            evaluator.evaluatorSourceExpectedIdentitySource,
            "exact_embedded_mechanics_provenance_git_blob_byte_count_and_sha256"
        )
        XCTAssertEqual(evaluator.evaluatorSourceExpectedGitMode, "100644")
        XCTAssertEqual(
            evaluator.evaluatorSourceAdmissionExecutablePath,
            "/usr/bin/git"
        )
        XCTAssertEqual(
            evaluator.orderedEvaluatorSourceAdmissionArgumentRoles,
            [
                "literal_-C",
                "fixed_canonical_exact_checkout_root",
                "literal_diff",
                "literal_--quiet",
                "literal_--no-ext-diff",
                "literal_--no-textconv",
                "exact_mechanics_revision",
                "literal_--",
                "fixed_evaluator_source_path",
            ]
        )
        XCTAssertEqual(evaluator.evaluatorSourceAdmissionInvocationCount, 1)
        XCTAssertEqual(evaluator.evaluatorSourceAdmissionRawOutputByteCount, 0)
        XCTAssertTrue(
            evaluator
                .evaluatorSourceAdmissionUsesStatusOnlyNoExternalDiffOrTextConversion
        )
        XCTAssertTrue(
            evaluator
                .evaluatorSourceAdmissionAndCompilerUseSameFixedCanonicalExactCheckoutRoot
        )
        XCTAssertTrue(
            evaluator
                .evaluatorSourceAdmissionImmediatelyPrecedesFixedCompilerInvocation
        )
        XCTAssertEqual(
            evaluator.evaluatorSourceAdmissionFailureResultCode,
            "EVALUATOR_SOURCE_REFUSED"
        )
        XCTAssertTrue(
            evaluator.evaluatorExecutableMustBeCanonicalAbsolutePrivateLeaf
        )
        XCTAssertEqual(
            evaluator.evaluatorPrivateRootLeaf,
            "prime-secure-child-validation-fixture-identity-evaluator-root-v1"
        )
        XCTAssertEqual(evaluator.evaluatorPrivateRootLeaf, roots.evaluatorRootLeaf)
        XCTAssertEqual(
            evaluator.evaluatorExecutableLeaf,
            "prime-secure-child-validation-fixture-identity-evaluator-v1"
        )
        XCTAssertEqual(evaluator.evaluatorPrivateRootMode, "0700")
        XCTAssertTrue(
            evaluator.evaluatorPrivateRootInitiallyAbsentAndNonlinkRequired
        )
        XCTAssertTrue(evaluator.evaluatorPrivateRootExclusiveCreationRequired)
        XCTAssertTrue(
            evaluator.evaluatorPrivateRootPhysicalOwnerDeviceAdmissionRequired
        )
        XCTAssertTrue(
            evaluator.evaluatorExecutableMustNotExistBeforeCompilerInvocation
        )
        XCTAssertEqual(
            evaluator.evaluatorPrivateRootLauncherCleanupInvocationCount,
            0
        )
        XCTAssertTrue(
            evaluator
                .evaluatorPrivateRootRetainedOnlyUntilOrdinaryEphemeralRunnerTeardown
        )
        XCTAssertFalse(evaluator.evaluatorPrivateRootResidualFilesAreEvidence)
        XCTAssertFalse(evaluator.evaluatorPrivateRootReuseOrRetryAuthorized)
        XCTAssertTrue(
            evaluator
                .evaluatorExecutableRegularNonlinkSingleLinkOwnerExecutableRequired
        )
        XCTAssertEqual(evaluator.evaluatorEnvironmentLauncherPath, "/usr/bin/env")
        XCTAssertEqual(evaluator.evaluatorEnvironmentLauncherFixedArguments, ["-i"])
        XCTAssertEqual(evaluator.evaluatorEnvironmentLauncherInvocationCount, 1)
        XCTAssertTrue(evaluator.evaluatorEnvironmentMustBeEmpty)
        XCTAssertEqual(evaluator.evaluatorAllowedEnvironmentKeys, [])
        XCTAssertEqual(evaluator.evaluatorStdinPath, "/dev/null")
        XCTAssertEqual(evaluator.evaluatorStdoutTransport, "bounded_anonymous_pipe")
        XCTAssertEqual(evaluator.evaluatorStderrPath, "/dev/null")
        XCTAssertTrue(evaluator.unrelatedFileDescriptorsMustBeClosed)
        XCTAssertEqual(
            evaluator.orderedInvocationModes,
            ["measure_fixture_identity"]
        )
        XCTAssertEqual(
            evaluator.orderedArgumentCountsExcludingArgumentZero,
            [3]
        )
        XCTAssertEqual(evaluator.orderedArgumentRolesByInvocation.count, 1)
        XCTAssertEqual(evaluator.orderedArgumentRolesByInvocation[0].count, 3)
        XCTAssertFalse(evaluator.acceptsArbitraryExecutableAuthority)
        XCTAssertEqual(evaluator.measuredFixtureExecutionCount, 0)
        XCTAssertEqual(
            evaluator.openFlags,
            ["O_RDONLY", "O_NOFOLLOW", "O_CLOEXEC"]
        )
        XCTAssertTrue(evaluator.descriptorMustBeCloseOnExec)
        XCTAssertTrue(evaluator.pathMustBeCanonicalAbsolute)
        XCTAssertTrue(evaluator.pathLStatRequired)
        XCTAssertTrue(evaluator.descriptorPreAndPostFStatRequired)
        XCTAssertTrue(evaluator.descriptorIdentityMustRemainStable)
        XCTAssertTrue(evaluator.descriptorAndNameIdentityJoinRequired)
        XCTAssertTrue(evaluator.descriptorAndNameJoinRequiredBeforeAndAfterRead)
        XCTAssertTrue(evaluator.distinctBuildDeviceInodeIdentityTupleRequired)
        XCTAssertTrue(evaluator.buildArtifactsMustShareTrustedLocalDevice)
        XCTAssertTrue(evaluator.buildArtifactInodesMustDiffer)
        XCTAssertTrue(evaluator.regularFileRequired)
        XCTAssertFalse(evaluator.symbolicLinkAuthorized)
        XCTAssertFalse(evaluator.hardLinkAuthorized)
        XCTAssertEqual(evaluator.exactLinkCount, 1)
        XCTAssertTrue(evaluator.ownerMustEqualEffectiveUser)
        XCTAssertTrue(evaluator.executableOwnerBitRequired)
        XCTAssertEqual(evaluator.maximumFixtureExecutableByteCount, 4_194_304)
        XCTAssertTrue(
            evaluator
                .signedOffTFileSizeMustBePositiveAndConvertExactlyThroughUInt64ToInt
        )
        XCTAssertTrue(
            evaluator.allocationAndOffsetArithmeticOnlyAfterSizeAdmission
        )
        XCTAssertTrue(evaluator.boundedStreamingReadRequired)
        XCTAssertEqual(evaluator.maximumReadChunkByteCount, 65_536)
        XCTAssertTrue(evaluator.accumulatedByteCountUsesCheckedArithmetic)
        XCTAssertTrue(evaluator.exactEOFRequiredAfterAdmittedByteCount)
        XCTAssertTrue(evaluator.exactFileByteCountReadRequired)
        XCTAssertTrue(evaluator.cryptoKitSHA256Required)
        XCTAssertTrue(evaluator.fullByteEqualityRequired)
        XCTAssertTrue(evaluator.thinMachORequired)
        XCTAssertFalse(evaluator.fatMachOAccepted)
        XCTAssertEqual(evaluator.requiredMachOMagic, "MH_MAGIC_64")
        XCTAssertEqual(evaluator.requiredCPUType, "CPU_TYPE_ARM64")
        XCTAssertEqual(evaluator.requiredFileType, "MH_EXECUTE")
        XCTAssertTrue(evaluator.loadCommandRegionBoundsChecked)
        XCTAssertTrue(evaluator.loadCommandWalkUsesCheckedIntegerArithmetic)
        XCTAssertTrue(evaluator.loadCommandCountAndRegionSizeMustMatchExactly)
        XCTAssertTrue(evaluator.eachLoadCommandHeaderAndCommandSizeBoundsChecked)
        XCTAssertTrue(
            evaluator.eachLoadCommandSizeAtLeastHeaderAndEightByteAligned
        )
        XCTAssertEqual(evaluator.minimumLoadCommandSizeByteCount, 8)
        XCTAssertEqual(evaluator.loadCommandSizeAlignmentByteCount, 8)
        XCTAssertTrue(
            evaluator
                .loadCommandOffsetSizeAndEndArithmeticUsesReportingOverflow
        )
        XCTAssertEqual(evaluator.exactLCUUIDCount, 1)
        XCTAssertEqual(evaluator.exactLCUUIDCommandSize, 24)
        XCTAssertEqual(evaluator.exactLCBuildVersionCount, 1)
        XCTAssertEqual(evaluator.minimumLCBuildVersionCommandSize, 24)
        XCTAssertTrue(evaluator.lcBuildVersionToolCountAndCommandSizeMustAgree)
        XCTAssertEqual(evaluator.lcBuildVersionToolEntryByteCount, 8)
        XCTAssertEqual(
            evaluator.lcBuildVersionExactCommandSizeFormula,
            "24_plus_ntools_times_8"
        )
        XCTAssertTrue(
            evaluator.lcBuildVersionSizeArithmeticUsesCheckedMultiplyAndAdd
        )
        XCTAssertTrue(
            evaluator.entireLCBuildVersionCommandBytesEqualityRequired
        )
        XCTAssertEqual(evaluator.exactLCCodeSignatureCount, 1)
        XCTAssertEqual(evaluator.exactLCCodeSignatureCommandSize, 16)
        XCTAssertTrue(evaluator.codeSignatureDataRangeBoundsChecked)
        XCTAssertFalse(evaluator.codeSignatureValidityEstablished)
        XCTAssertFalse(evaluator.launchabilityEstablished)
        XCTAssertEqual(evaluator.requiredBuildPlatform, "PLATFORM_MACOS")
        XCTAssertTrue(evaluator.buildMinimumOSObserved)
        XCTAssertTrue(evaluator.buildSDKObserved)
        XCTAssertTrue(evaluator.UUIDEqualityRequired)
        XCTAssertTrue(evaluator.buildVersionEqualityRequired)
        XCTAssertTrue(evaluator.evaluatorOutputCanonicalJSONOnly)
        XCTAssertEqual(evaluator.rawPathFieldCount, 0)
        XCTAssertEqual(evaluator.rawBuildOutputFieldCount, 0)
        XCTAssertEqual(evaluator.pythonImportOrInvocationCount, 0)
        XCTAssertEqual(evaluator.cppSourceOrInvocationCount, 0)

        let evaluatorOutput = future.evaluatorOutput
        XCTAssertEqual(
            evaluatorOutput.schemaID,
            "prime_secure_child_validation_fixture_identity_evaluator_output_v1"
        )
        XCTAssertEqual(evaluatorOutput.schemaVersion, 1)
        XCTAssertTrue(evaluatorOutput.canonicalJSONRequired)
        XCTAssertFalse(evaluatorOutput.terminalLFPermitted)
        XCTAssertEqual(evaluatorOutput.maximumCanonicalJSONByteCount, 2_048)
        XCTAssertEqual(evaluatorOutput.logicalFieldTypeContracts.count, 18)
        XCTAssertEqual(evaluatorOutput.exactCanonicalWireOrderedKeys.count, 18)
        XCTAssertEqual(evaluatorOutput.exactFieldCount, 18)
        XCTAssertEqual(
            Set(evaluatorOutput.logicalFieldTypeContracts).count,
            evaluatorOutput.exactFieldCount
        )
        XCTAssertEqual(
            evaluatorOutput.exactCanonicalWireOrderedKeys,
            evaluatorOutput.exactCanonicalWireOrderedKeys.sorted()
        )
        XCTAssertEqual(evaluatorOutput.exactIdentityFieldCountPerArtifact, 6)
        XCTAssertEqual(evaluatorOutput.exactComparisonFieldCount, 4)
        XCTAssertEqual(
            evaluatorOutput.packedMachOVersionRepresentation,
            "unsigned_32_bit_wire_value_0_through_UInt32_max"
        )
        XCTAssertTrue(
            evaluatorOutput.comparisonBooleansMustEqualDirectEvaluatorResults
        )
        XCTAssertTrue(
            evaluatorOutput
                .machoIdentityComparisonIncludesExactLCUUIDAndEntireLCBuildVersion
        )
        XCTAssertTrue(
            evaluatorOutput.fullByteInequalityIsAuthoritativeForNondeterminism
        )
        XCTAssertTrue(
            evaluatorOutput.fullBytesTrueRequiresAllOtherComparisonsTrue
        )
        XCTAssertTrue(
            evaluatorOutput.publishedIdentityEqualityMustMatchComparisonBooleans
        )
        XCTAssertEqual(
            evaluatorOutput.impossibleCrossFieldCombinationResultCode,
            "EVALUATOR_CONTRACT_REFUSED"
        )
        XCTAssertEqual(evaluatorOutput.rawPathFieldCount, 0)
        XCTAssertEqual(evaluatorOutput.rawBuildOutputOrErrorFieldCount, 0)
        XCTAssertFalse(evaluatorOutput.launcherUsesGenericJSONDecoder)
        XCTAssertTrue(
            evaluatorOutput.launcherUsesExactBash32ASCIIHexLexicalParser
        )
        XCTAssertTrue(evaluatorOutput.exactBash32ExtendedRegex.hasPrefix("^\\{"))
        XCTAssertTrue(evaluatorOutput.exactBash32ExtendedRegex.hasSuffix("\\}$"))
        XCTAssertEqual(evaluatorOutput.exactBash32CaptureGroupCount, 16)
        XCTAssertEqual(evaluatorOutput.orderedPostRegexNumericChecks.count, 6)
        XCTAssertTrue(
            evaluatorOutput.launcherMustReconstructAndByteCompareCanonicalASCII
        )
        XCTAssertTrue(
            evaluatorOutput.launcherProjectionPreservesIdentityAndComparisonValues
        )

        let capture = future.boundedCapture
        XCTAssertEqual(
            capture.transport,
            "anonymous_pipe_cap_plus_one_then_fixed_hex_encoding_before_command_substitution"
        )
        XCTAssertEqual(capture.captureFilesystemPathCount, 0)
        XCTAssertFalse(capture.captureFilesystemCleanupRequired)
        XCTAssertTrue(capture.captureFilesystemAbsenceByConstruction)
        XCTAssertEqual(capture.boundedReaderExecutablePath, "/usr/bin/head")
        XCTAssertEqual(capture.exactBoundedReaderInvocationCount, 3)
        XCTAssertEqual(capture.byteEncoderExecutablePath, "/usr/bin/od")
        XCTAssertEqual(capture.orderedByteEncoderArguments, ["-An", "-tx1", "-v"])
        XCTAssertEqual(capture.byteEncoderExactLocaleEnvironment, "LC_ALL=C")
        XCTAssertEqual(capture.exactByteEncoderInvocationCount, 3)
        XCTAssertEqual(
            capture.byteEncoderOutputByteCountFormula,
            "raw_count_zero_yields_zero_else_74_times_ceiling_raw_count_divided_by_16_plus_1"
        )
        XCTAssertTrue(capture.byteEncoderSizeArithmeticUsesCheckedOperations)
        XCTAssertEqual(capture.exactPipelineStatusEnvelopeByteCount, 19)
        XCTAssertTrue(capture.pipelineStatusesCapturedImmediatelyInsideSubshell)
        XCTAssertTrue(capture.producerNonzeroClassificationPrecedesOutputValidation)
        XCTAssertTrue(capture.capOverflowMayProduceSIGPIPENonzeroProducerStatus)
        XCTAssertEqual(
            capture.nonzeroProducerStatusResultCodes,
            [
                "SHOW_BIN_A_REFUSED",
                "SHOW_BIN_B_REFUSED",
                "EVALUATOR_COMMAND_REFUSED",
            ]
        )
        XCTAssertFalse(capture.rawProducerBytesEnterCommandSubstitution)
        XCTAssertTrue(
            capture.fixedCaptureToolsAndNullDeviceAdmittedBeforeAttemptConsumption
        )
        XCTAssertEqual(
            capture.preAttemptCaptureAdmissionFailureResultCode,
            "INVOCATION_ADMISSION_REFUSED"
        )
        XCTAssertEqual(capture.showBinCaptureCount, 2)
        XCTAssertEqual(capture.showBinMaximumAcceptedByteCount, 1_024)
        XCTAssertEqual(capture.showBinReaderLimitByteCount, 1_025)
        XCTAssertEqual(
            capture.showBinByteEncoderOutputAtReaderLimitByteCount,
            4_811
        )
        XCTAssertEqual(capture.showBinMaximumEncodedCaptureByteCount, 4_830)
        XCTAssertEqual(
            capture.showBinMaximumEncodedCaptureByteCount,
            capture.showBinByteEncoderOutputAtReaderLimitByteCount
                + capture.exactPipelineStatusEnvelopeByteCount
        )
        XCTAssertEqual(
            capture.showBinReaderLimitByteCount,
            capture.showBinMaximumAcceptedByteCount + 1
        )
        XCTAssertTrue(
            capture.showBinBytesPreservedBeforeShellStringNormalization
        )
        XCTAssertTrue(
            capture.showBinTerminalLFValidatedAsHex0ABeforePathBodyDecode
        )
        XCTAssertEqual(
            capture.showBinZeroProducerStatusOutputValidationFailureResultCodes,
            ["ARTIFACT_A_ADMISSION_REFUSED", "ARTIFACT_B_ADMISSION_REFUSED"]
        )
        XCTAssertEqual(
            capture.showBinUnavailableTransportResultCodes,
            ["SHOW_BIN_A_TRANSPORT_REFUSED", "SHOW_BIN_B_TRANSPORT_REFUSED"]
        )
        XCTAssertEqual(capture.evaluatorStdoutMaximumAcceptedByteCount, 2_048)
        XCTAssertEqual(capture.evaluatorStdoutReaderLimitByteCount, 2_049)
        XCTAssertEqual(
            capture.evaluatorByteEncoderOutputAtReaderLimitByteCount,
            9_547
        )
        XCTAssertEqual(
            capture.evaluatorStdoutMaximumEncodedCaptureByteCount,
            9_566
        )
        XCTAssertEqual(
            capture.evaluatorStdoutMaximumEncodedCaptureByteCount,
            capture.evaluatorByteEncoderOutputAtReaderLimitByteCount
                + capture.exactPipelineStatusEnvelopeByteCount
        )
        XCTAssertEqual(
            capture.evaluatorStdoutMaximumAcceptedByteCount,
            evaluatorOutput.maximumCanonicalJSONByteCount
        )
        XCTAssertEqual(
            capture.evaluatorStdoutReaderLimitByteCount,
            capture.evaluatorStdoutMaximumAcceptedByteCount + 1
        )
        XCTAssertFalse(capture.evaluatorStdoutTerminalLFPermitted)
        XCTAssertEqual(
            capture
                .evaluatorZeroProducerStatusReaderEncoderOrCapFailureResultCode,
            "CAPTURE_REFUSED"
        )
        XCTAssertEqual(
            capture.evaluatorUnavailableTransportResultCode,
            "EVALUATOR_TRANSPORT_REFUSED"
        )
        XCTAssertEqual(capture.nonRecordRawStdoutForwardingByteCount, 0)
        XCTAssertEqual(capture.nonRecordRawStderrForwardingByteCount, 0)
        XCTAssertEqual(capture.nullDevicePath, "/dev/null")
        XCTAssertTrue(capture.nullDeviceNameAndDescriptorJoinRequired)
        XCTAssertTrue(capture.nullDeviceCharacterDeviceRequired)
        XCTAssertTrue(capture.evaluatorStdinUsesVerifiedNullDevice)
        XCTAssertTrue(capture.evaluatorStderrUsesVerifiedNullDevice)
        XCTAssertTrue(capture.showBinStderrUsesVerifiedNullDevice)
        XCTAssertTrue(
            capture.fixtureBuildAndCompilerStdoutStderrUseVerifiedNullDevice
        )
        XCTAssertEqual(
            capture.fixtureBuildAndCompilerRawOutputForwardingByteCount,
            0
        )
        XCTAssertTrue(capture.encodedCaptureExactASCIIHexTokenGrammarRequired)
        XCTAssertTrue(
            capture.encodedCaptureReconstructedOnlyAfterByteGrammarAdmission
        )
        XCTAssertTrue(capture.overflowDetectionUsesCapPlusOneByte)
        XCTAssertTrue(
            capture.noCommandSubstitutionMayReceiveUnboundedProducerOutput
        )

        let timing = future.timingAdmission
        XCTAssertEqual(timing.predecessorRunID, 32_348_627_200)
        XCTAssertEqual(timing.predecessorReviewedJobObservedDurationSeconds, 3_210)
        XCTAssertEqual(timing.currentReviewedJobTimeoutMinutes, 75)
        XCTAssertEqual(timing.authorizedReviewedJobTimeoutMinutes, 90)
        XCTAssertEqual(timing.activeRootJobTimeoutMinutesRemains, 45)
        XCTAssertTrue(timing.soleWorkflowTimeoutMutationRequired)
        XCTAssertEqual(timing.workflowJobAdditionCount, 0)
        XCTAssertEqual(timing.workflowStepAdditionCount, 1)
        XCTAssertEqual(timing.authorizedReviewedJobCeilingSeconds, 5_400)
        XCTAssertTrue(
            timing.authorizedTimeoutIsPlatformCeilingNotCompletionGuarantee
        )
        XCTAssertFalse(timing.timingMechanismIsWatchdog)
        XCTAssertEqual(timing.additionalTimingStatePathCount, 0)
        XCTAssertEqual(timing.preBuildTimingRefusalResultCodeCount, 0)
        XCTAssertEqual(
            timing
                .timeoutCancellationOrAbruptTerminationHostedRecordCardinality,
            "zero_or_one_based_on_whether_bounded_projection_completed_before_external_termination"
        )
        XCTAssertTrue(
            timing
                .timeoutCancellationOrAbruptTerminationObservedOnlyFromActionsMetadata
        )
        XCTAssertEqual(
            timing
                .timeoutCancellationOrAbruptTerminationMeasurementAttemptConsumption,
            "unavailable_unless_separately_proved_by_sanitized_launcher_record_or_reviewed_log"
        )
        XCTAssertFalse(
            timing.timeoutCancellationOrAbruptTerminationEstablishesMeasurement
        )
        XCTAssertFalse(
            timing
                .timeoutCancellationOrAbruptTerminationEstablishesFixtureIdentity
        )
        XCTAssertTrue(
            timing
                .presentRecordUnderExternalTerminationRequiresMatchingCompletedWorkflowConclusionToBeAccepting
        )
        XCTAssertTrue(
            timing.timeoutCancellationOrAbruptTerminationRetiresOpportunity
        )

        let record = future.hostedRecord
        XCTAssertEqual(
            record.prefix,
            "prime-secure-child validation-fixture-identity measurement: "
        )
        XCTAssertEqual(Data(record.prefix.utf8).count, 60)
        XCTAssertEqual(record.schemaVersion, 1)
        XCTAssertTrue(record.canonicalJSONRequired)
        XCTAssertEqual(record.exactLineCountWhenPresent, 1)
        XCTAssertTrue(record.terminalLFRequiredWhenPresent)
        XCTAssertEqual(record.maximumCanonicalJSONByteCount, 4_035)
        XCTAssertEqual(record.maximumTotalLineByteCount, 4_096)
        XCTAssertLessThanOrEqual(
            Data(record.prefix.utf8).count
                + record.maximumCanonicalJSONByteCount + 1,
            record.maximumTotalLineByteCount
        )
        XCTAssertEqual(record.logicalFieldTypeContracts.count, 43)
        XCTAssertEqual(record.exactCanonicalWireOrderedKeys.count, 43)
        XCTAssertEqual(record.exactFieldCount, 43)
        XCTAssertEqual(Set(record.logicalFieldTypeContracts).count, 43)
        XCTAssertEqual(
            record.exactCanonicalWireOrderedKeys,
            record.exactCanonicalWireOrderedKeys.sorted()
        )
        XCTAssertTrue(
            record.logicalFieldTypeContracts.contains(
                "fixture_a_minimum_os_packed:null_or_uint32"
            )
        )
        XCTAssertTrue(
            record.logicalFieldTypeContracts.contains(
                "fixture_b_sdk_packed:null_or_uint32"
            )
        )
        XCTAssertEqual(record.exactResultCodes.count, 25)
        XCTAssertEqual(Set(record.exactResultCodes).count, 25)
        XCTAssertEqual(
            record.commandStateMembers,
            ["not_attempted", "succeeded", "failed", "unavailable"]
        )
        XCTAssertEqual(
            record.executionObservationMembers,
            ["observed_false", "observed_true", "unavailable"]
        )
        XCTAssertEqual(
            record.comparisonStateMembers,
            ["false", "true", "unavailable"]
        )
        XCTAssertTrue(
            record
                .evaluatorCommandExecutionAndWaitFieldsApplyOnlyToSoleFixtureIdentityInvocation
        )
        XCTAssertEqual(record.exactResultStateInvariants.count, 25)
        XCTAssertEqual(
            record.exactResultStateInvariants.map(\.resultCode),
            record.exactResultCodes
        )
        XCTAssertTrue(record.everyResultCodeCoveredExactlyOnce)
        for invariant in record.exactResultStateInvariants {
            XCTAssertTrue(
                [
                    invariant.buildACommandState,
                    invariant.showBinACommandState,
                    invariant.buildBCommandState,
                    invariant.showBinBCommandState,
                    invariant.evaluatorCompileState,
                    invariant.evaluatorCommandState,
                ].allSatisfy(record.commandStateMembers.contains)
            )
            XCTAssertTrue(
                record.executionObservationMembers.contains(
                    invariant.evaluatorExecutionObservation
                )
            )
        }
        XCTAssertEqual(record.successResultCodes.count, 2)
        XCTAssertEqual(record.failureResultCodes.count, 23)
        XCTAssertEqual(
            record.successResultCodes + record.failureResultCodes,
            record.exactResultCodes
        )
        XCTAssertTrue(record.onlySuccessResultCodesMayConcludeWorkflowSuccess)
        XCTAssertTrue(
            record.everyFailureResultCodeRequiresNonzeroWorkflowConclusion
        )
        XCTAssertTrue(
            record
                .presentRecordAcceptingOnlyWhenWorkflowConclusionMatchesResultInvariant
        )
        let passCurrent = record.exactResultStateInvariants[0]
        let passDifferent = record.exactResultStateInvariants[1]
        for pass in [passCurrent, passDifferent] {
            XCTAssertEqual(pass.workflowConclusion, "success")
            XCTAssertTrue(pass.measurementAttemptConsumed)
            XCTAssertEqual(pass.buildACommandState, "succeeded")
            XCTAssertEqual(pass.showBinACommandState, "succeeded")
            XCTAssertEqual(pass.buildBCommandState, "succeeded")
            XCTAssertEqual(pass.showBinBCommandState, "succeeded")
            XCTAssertEqual(pass.evaluatorCompileState, "succeeded")
            XCTAssertEqual(pass.evaluatorCommandState, "succeeded")
            XCTAssertEqual(pass.evaluatorExecutionObservation, "observed_true")
            XCTAssertEqual(pass.evaluatorShellWaitStatusContract, "uint8_zero")
            XCTAssertEqual(pass.identityFieldContract, "both_artifacts_complete")
            XCTAssertEqual(pass.buildABComparisonContract, "all_four_true")
        }
        XCTAssertEqual(passCurrent.currentPinComparisonContract, "all_three_true")
        XCTAssertEqual(
            passDifferent.currentPinComparisonContract,
            "all_three_boolean_full_false_and_at_least_one_dimension_false"
        )
        let nondeterministic = record.exactResultStateInvariants[2]
        XCTAssertEqual(nondeterministic.workflowConclusion, "failure")
        XCTAssertTrue(nondeterministic.measurementAttemptConsumed)
        XCTAssertEqual(nondeterministic.identityFieldContract, "both_artifacts_complete")
        XCTAssertEqual(
            nondeterministic.buildABComparisonContract,
            "all_four_boolean_and_full_bytes_false_other_three_may_be_either_boolean"
        )
        XCTAssertEqual(
            nondeterministic.currentPinComparisonContract,
            "all_three_unavailable"
        )
        for invariant in record.exactResultStateInvariants.dropFirst(2) {
            XCTAssertEqual(invariant.workflowConclusion, "failure")
        }
        let invariants = Dictionary(
            uniqueKeysWithValues: record.exactResultStateInvariants.map {
                ($0.resultCode, $0)
            }
        )
        for code in [
            "INVOCATION_ADMISSION_REFUSED",
            "MEASUREMENT_ROOT_REFUSED",
            "SOURCE_ROOT_REFUSED",
            "BUILD_ROOT_REFUSED",
            "MIRROR_REFUSED",
            "UNCLASSIFIED",
        ] {
            let refusal = try XCTUnwrap(invariants[code])
            XCTAssertFalse(refusal.measurementAttemptConsumed)
            XCTAssertEqual(refusal.buildACommandState, "not_attempted")
            XCTAssertEqual(refusal.showBinACommandState, "not_attempted")
            XCTAssertEqual(refusal.buildBCommandState, "not_attempted")
            XCTAssertEqual(refusal.showBinBCommandState, "not_attempted")
            XCTAssertEqual(refusal.evaluatorCommandState, "not_attempted")
            XCTAssertEqual(refusal.identityFieldContract, "all_identity_fields_null")
            XCTAssertEqual(refusal.buildABComparisonContract, "all_four_unavailable")
            XCTAssertEqual(refusal.currentPinComparisonContract, "all_three_unavailable")
        }
        for code in [
            "EVALUATOR_ROOT_REFUSED",
            "EVALUATOR_SOURCE_REFUSED",
        ] {
            let refusal = try XCTUnwrap(invariants[code])
            XCTAssertTrue(refusal.measurementAttemptConsumed)
            XCTAssertEqual(refusal.buildACommandState, "succeeded")
            XCTAssertEqual(refusal.showBinACommandState, "succeeded")
            XCTAssertEqual(refusal.buildBCommandState, "succeeded")
            XCTAssertEqual(refusal.showBinBCommandState, "succeeded")
            XCTAssertEqual(refusal.evaluatorCompileState, "not_attempted")
            XCTAssertEqual(refusal.evaluatorCommandState, "not_attempted")
        }
        let evaluatorCompile = try XCTUnwrap(
            invariants["EVALUATOR_COMPILE_REFUSED"]
        )
        XCTAssertTrue(evaluatorCompile.measurementAttemptConsumed)
        XCTAssertEqual(evaluatorCompile.buildACommandState, "succeeded")
        XCTAssertEqual(evaluatorCompile.showBinACommandState, "succeeded")
        XCTAssertEqual(evaluatorCompile.buildBCommandState, "succeeded")
        XCTAssertEqual(evaluatorCompile.showBinBCommandState, "succeeded")
        XCTAssertEqual(evaluatorCompile.evaluatorCompileState, "failed")
        let evaluatorAdmission = try XCTUnwrap(
            invariants["EVALUATOR_ADMISSION_REFUSED"]
        )
        XCTAssertTrue(evaluatorAdmission.measurementAttemptConsumed)
        XCTAssertEqual(evaluatorAdmission.buildACommandState, "succeeded")
        XCTAssertEqual(evaluatorAdmission.showBinACommandState, "succeeded")
        XCTAssertEqual(evaluatorAdmission.buildBCommandState, "succeeded")
        XCTAssertEqual(evaluatorAdmission.showBinBCommandState, "succeeded")
        XCTAssertEqual(evaluatorAdmission.evaluatorCompileState, "succeeded")
        for code in [
            "BUILD_A_REFUSED",
            "SHOW_BIN_A_REFUSED",
            "SHOW_BIN_A_TRANSPORT_REFUSED",
            "ARTIFACT_A_ADMISSION_REFUSED",
            "BUILD_B_REFUSED",
            "SHOW_BIN_B_REFUSED",
            "SHOW_BIN_B_TRANSPORT_REFUSED",
            "ARTIFACT_B_ADMISSION_REFUSED",
        ] {
            XCTAssertEqual(
                invariants[code]?.evaluatorCompileState,
                "not_attempted"
            )
        }
        XCTAssertEqual(invariants["BUILD_A_REFUSED"]?.buildACommandState, "failed")
        XCTAssertEqual(invariants["SHOW_BIN_A_REFUSED"]?.showBinACommandState, "failed")
        XCTAssertEqual(
            invariants["SHOW_BIN_A_TRANSPORT_REFUSED"]?.showBinACommandState,
            "unavailable"
        )
        XCTAssertEqual(
            invariants["ARTIFACT_A_ADMISSION_REFUSED"]?.showBinACommandState,
            "succeeded"
        )
        XCTAssertEqual(invariants["BUILD_B_REFUSED"]?.buildBCommandState, "failed")
        XCTAssertEqual(invariants["SHOW_BIN_B_REFUSED"]?.showBinBCommandState, "failed")
        XCTAssertEqual(
            invariants["SHOW_BIN_B_TRANSPORT_REFUSED"]?.showBinBCommandState,
            "unavailable"
        )
        XCTAssertEqual(
            invariants["ARTIFACT_B_ADMISSION_REFUSED"]?.showBinBCommandState,
            "succeeded"
        )
        let evaluatorTransport = try XCTUnwrap(
            invariants["EVALUATOR_TRANSPORT_REFUSED"]
        )
        XCTAssertEqual(evaluatorTransport.evaluatorCommandState, "unavailable")
        XCTAssertEqual(
            evaluatorTransport.evaluatorExecutionObservation,
            "unavailable"
        )
        XCTAssertEqual(
            evaluatorTransport.evaluatorShellWaitStatusContract,
            "null"
        )
        let evaluatorCommand = try XCTUnwrap(
            invariants["EVALUATOR_COMMAND_REFUSED"]
        )
        XCTAssertEqual(evaluatorCommand.evaluatorCommandState, "failed")
        XCTAssertEqual(
            evaluatorCommand.evaluatorExecutionObservation,
            "unavailable"
        )
        XCTAssertEqual(
            evaluatorCommand.evaluatorShellWaitStatusContract,
            "uint8_nonzero"
        )
        for code in ["EVALUATOR_CONTRACT_REFUSED", "CAPTURE_REFUSED"] {
            let refusal = try XCTUnwrap(invariants[code])
            XCTAssertEqual(refusal.evaluatorCommandState, "succeeded")
            XCTAssertEqual(refusal.evaluatorShellWaitStatusContract, "uint8_zero")
            XCTAssertEqual(refusal.identityFieldContract, "all_identity_fields_null")
        }
        XCTAssertTrue(record.identityFieldsNullableBeforeMeasurement)
        XCTAssertTrue(
            record.identityFieldsRequiredAfterSuccessfulAcceptedEvaluatorReturn
        )
        XCTAssertTrue(
            record
                .currentPinComparisonRequiredAfterFullyIdenticalEvaluatorReturn
        )
        XCTAssertEqual(
            record.currentPinComparisonSemantics,
            "only_after_full_byte_identity_both_artifacts_individually_match_current_byte_count_and_sha256_else_unavailable"
        )
        XCTAssertEqual(record.rawAbsolutePathFieldCount, 0)
        XCTAssertEqual(record.rawBuildOutputOrErrorFieldCount, 0)
        XCTAssertEqual(record.exactRecordCountForEveryLauncherControlledOutcome, 1)
        XCTAssertTrue(
            record.launcherControlledReturnAlwaysProjectsExactlyOneRecord
        )
        XCTAssertEqual(record.maximumRecordCountPerWorkflowRun, 1)
        XCTAssertEqual(record.exactRecordCountOnReachedTerminalEvaluatorPath, 1)
        XCTAssertTrue(record.boundedExitProjectionRequired)
        XCTAssertTrue(record.exitProjectionMustBeIdempotentAndAtMostOnce)
        XCTAssertFalse(record.preEvaluatorBuildOrCompileFailureMayHaveNoRecord)
        XCTAssertTrue(
            record
                .recordMayBeAbsentOnExternalTimeoutCancellationAbruptProcessHostOrRunnerTerminationBeforeOrAfterLauncherStart
        )
        XCTAssertEqual(record.launcherNotReachedHostedRecordCount, 0)
        XCTAssertTrue(record.launcherNotReachedObservedOnlyFromActionsMetadata)
        XCTAssertFalse(record.launcherNotReachedEstablishesMeasurementOrIdentity)
        XCTAssertTrue(record.launcherNotReachedRetiresOpportunity)
        XCTAssertEqual(record.actionsArtifactCount, 0)
        XCTAssertEqual(record.scientificOutcome, "not_established")
        XCTAssertFalse(record.durableEvidence)
        XCTAssertFalse(record.pinMutationPerformed)
        XCTAssertFalse(record.canaryExecutionPerformed)
        XCTAssertEqual(
            record.absentExternalTerminationMeasurementAttemptConsumption,
            "unavailable_unless_separately_proved_by_sanitized_launcher_record_or_reviewed_log"
        )
        XCTAssertFalse(record.absentRecordEstablishesMeasurement)
        XCTAssertFalse(record.absentRecordEstablishesFixtureIdentity)
        XCTAssertTrue(record.everyRecordOrAbsentRecordOutcomeRetiresOpportunity)

        let retirement = authority.retirementBoundary
        XCTAssertEqual(
            retirement.disposition,
            "observe_once_then_irrevocably_retire"
        )
        XCTAssertTrue(retirement.appendOnlyObservationRequiredAfterEveryOutcome)
        XCTAssertTrue(retirement.successRequiresObservationAndRetirement)
        XCTAssertTrue(retirement.buildFailureRequiresObservationAndRetirement)
        XCTAssertTrue(retirement.evaluatorFailureRequiresObservationAndRetirement)
        XCTAssertTrue(retirement.mismatchRequiresObservationAndRetirement)
        XCTAssertTrue(retirement.cancellationRequiresObservationAndRetirement)
        XCTAssertTrue(retirement.abruptHostLossRequiresObservationFromActionsMetadata)
        XCTAssertTrue(retirement.observationAndRetirementMustBeNextAuthorizedChange)
        XCTAssertTrue(retirement.launcherSourceRetainedForAuditAfterRetirement)
        XCTAssertTrue(retirement.evaluatorSourceRetainedForAuditAfterRetirement)
        XCTAssertTrue(
            retirement
                .currentPinPassRequiresSeparateNoMutationConfirmationAuthority
        )
        XCTAssertEqual(retirement.currentPinPassConfirmationPinMutationCount, 0)
        XCTAssertTrue(retirement.pinRepairAuthorityMustBeSeparate)
        XCTAssertTrue(retirement.pinRepairImplementationMustNotLaunchFixture)
        XCTAssertTrue(
            retirement
                .pinRepairExactMainIndependentHostedRemeasurementRequired
        )
        XCTAssertEqual(retirement.pinRepairConfirmationFixtureExecutionCount, 0)
        XCTAssertEqual(
            retirement.crossRunIdentityConfirmationFields,
            [
                "within_each_run_build_a_b_full_byte_equality",
                "cross_run_byte_count",
                "cross_run_sha256",
                "cross_run_macho_uuid",
                "cross_run_macho_platform_minimum_os_packed_sdk_packed",
            ]
        )
        XCTAssertTrue(
            retirement
                .crossRunSHA256EqualityCoversEveryArtifactByteIncludingLCBuildVersionTools
        )
        XCTAssertTrue(
            retirement.crossRunIdentityMatchRequiredBeforeCanaryAuthority
        )
        XCTAssertTrue(
            retirement.bothSuccessResultBranchesRequireCrossRunConfirmation
        )
        XCTAssertTrue(
            retirement
                .successBranchConfirmationObservationAndRetirementRequired
        )
        XCTAssertFalse(retirement.automaticRetryAuthorized)
        XCTAssertFalse(retirement.workflowRerunAuthorized)
        XCTAssertFalse(retirement.replacementMeasurementAuthorized)
        XCTAssertEqual(retirement.orderedLaterBoundaries.count, 8)

        let language = authority.languageBoundary
        XCTAssertEqual(language.authorityLanguage, "swift_foundation_codable_data_only")
        XCTAssertEqual(language.laterLauncherLanguage, "closed_bash")
        XCTAssertEqual(language.laterEvaluatorLanguage, "standalone_swift")
        XCTAssertTrue(language.evaluatorUsesCryptoKit)
        XCTAssertFalse(language.pythonPermitted)
        XCTAssertEqual(language.pythonInvocationCount, 0)
        XCTAssertEqual(language.pythonSourcePathCount, 0)
        XCTAssertFalse(language.cppPermitted)
        XCTAssertEqual(language.cppInvocationCount, 0)
        XCTAssertEqual(language.cppSourcePathCount, 0)

        let ceiling = authority.authorityCeiling
        XCTAssertTrue(ceiling.measurementAuthorityEstablished)
        XCTAssertTrue(ceiling.laterExactFiveMeasurementAuthorizedAfterClosure)
        XCTAssertTrue(authorityFalseClaims(ceiling).allSatisfy { !$0 })
        XCTAssertEqual(authority.orderedRequiredSeparateActions.count, 9)

        XCTAssertNoThrow(try authority.validate())
        let canonical = try authority.canonicalData()
        XCTAssertEqual(canonical, try PrimeCanonicalJSON.encode(authority))
        if Authority.canonicalByteCount == 0 {
            XCTFail(
                "canonical freeze byte_count=\(canonical.count) sha256="
                    + PrimeSHA256.hexDigest(of: canonical)
            )
            return
        }
        XCTAssertEqual(canonical.count, Authority.canonicalByteCount)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: canonical),
            Authority.canonicalSHA256
        )
        XCTAssertNoThrow(try authority.validateExactV1())
        let decoded = try Authority.decodeCanonical(canonical)
        XCTAssertEqual(decoded, authority)
        XCTAssertEqual(try decoded.canonicalData(), canonical)

        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical) as? [String: Any]
        )
        let valuePaths = allValuePaths(in: object)
        let dictionaryPaths = allDictionaryPaths(in: object)
        XCTAssertGreaterThan(valuePaths.count, 300)
        XCTAssertGreaterThan(dictionaryPaths.count, 15)

        var looseDecodedDriftCount = 0
        for path in valuePaths {
            let mutatedData = try assertCanonicalRejects(
                replacingValue(in: object, at: path, with: mutateJSONValue)
            )
            if assertLooseDecodedDriftRejects(mutatedData, authority: authority) {
                looseDecodedDriftCount += 1
            }
            let nullData = try assertCanonicalRejects(
                replacingValue(in: object, at: path, with: { value in
                    if value is NSNull { return "__null_mutation" }
                    return NSNull()
                })
            )
            if assertLooseDecodedDriftRejects(nullData, authority: authority) {
                looseDecodedDriftCount += 1
            }
            let removedData = try assertCanonicalRejects(
                removingValue(in: object, at: path)
            )
            if assertLooseDecodedDriftRejects(removedData, authority: authority) {
                looseDecodedDriftCount += 1
            }
        }
        XCTAssertGreaterThan(looseDecodedDriftCount, 250)

        var reorderedArrayCount = 0
        for path in allArrayPaths(in: object) {
            var changed = false
            let reordered = replacingValue(
                in: object,
                at: path,
                with: { value in
                    var array = value as! [Any]
                    guard array.count >= 2 else { return array }
                    for left in 0 ..< array.count {
                        for right in (left + 1) ..< array.count
                        where canonicalJSONFragment(array[left])
                            != canonicalJSONFragment(array[right])
                        {
                            array.swapAt(left, right)
                            changed = true
                            return array
                        }
                    }
                    return array
                }
            )
            if changed {
                let reorderedData = try assertCanonicalRejects(reordered)
                XCTAssertTrue(
                    assertLooseDecodedDriftRejects(
                        reorderedData,
                        authority: authority
                    )
                )
                reorderedArrayCount += 1
            }
        }
        XCTAssertGreaterThan(reorderedArrayCount, 8)

        for (index, path) in dictionaryPaths.enumerated() {
            let unknown = replacingValue(
                in: object,
                at: path,
                with: { value in
                    var dictionary = value as! [String: Any]
                    dictionary["unknown_measurement_authority_field_\(index)"] = true
                    return dictionary
                }
            )
            let unknownData = try assertCanonicalRejects(unknown)
            XCTAssertEqual(
                try JSONDecoder().decode(Authority.self, from: unknownData),
                authority
            )
        }

        var maximumIntegerObject = object
        maximumIntegerObject["schemaVersion"] = NSNumber(value: Int.max)
        let maximumIntegerData = try assertCanonicalRejects(maximumIntegerObject)
        XCTAssertTrue(
            assertLooseDecodedDriftRejects(
                maximumIntegerData,
                authority: authority
            )
        )

        try assertNoncanonicalEncodingsReject(canonical, object: object)
        let oversized = Data(repeating: 0x20, count: 131_073)
        XCTAssertThrowsError(try Authority.decodeCanonical(oversized)) { error in
            XCTAssertEqual(
                error as?
                    PrimeSecureChildValidationFixtureIdentityMeasurementAuthorityError,
                .oversizedEncoding
            )
        }
    }

    private func inventoryMutations(_ authority: Authority) -> [Bool] {
        let inventory = authority.fixtureInputInventory
        return [
            inventory.packageMutationAuthorized,
            inventory.lockMutationAuthorized,
            inventory.mirrorMutationAuthorized,
            inventory.fixtureSourceMutationAuthorized,
            inventory.kernelMutationAuthorized,
            inventory.pinMutationAuthorized,
        ]
    }

    private func authorityFalseClaims(_ ceiling: Authority.AuthorityCeiling)
        -> [Bool]
    {
        [
            ceiling.measurementMechanicsPerformed,
            ceiling.launcherSourceAdded,
            ceiling.evaluatorSourceAdded,
            ceiling.compilerInvocationAuthorizedInThisPatch,
            ceiling.evaluatorInvocationAuthorizedInThisPatch,
            ceiling.filesystemReadAuthorizedInThisPatch,
            ceiling.filesystemWriteAuthorizedInThisPatch,
            ceiling.descriptorInspectionAuthorizedInThisPatch,
            ceiling.processExecutionAuthorizedInThisPatch,
            ceiling.fixtureBuildAuthorizedInThisPatch,
            ceiling.fixtureExecutionAuthorizedInThisPatch,
            ceiling.adapterExecutionAuthorizedInThisPatch,
            ceiling.leaseAcquisitionAuthorizedInThisPatch,
            ceiling.modelExecutionAuthorizedInThisPatch,
            ceiling.networkAuthorizedInThisPatch,
            ceiling.measuredFixtureIdentityEstablished,
            ceiling.repeatBuildDeterminismEstablished,
            ceiling.currentPinMatchEstablished,
            ceiling.fixturePinMutationAuthorized,
            ceiling.fixturePinMutationPerformed,
            ceiling.fixturePinRepairAuthorityEstablished,
            ceiling.fixturePinRepairImplementationAuthorized,
            ceiling.layerAMutationAuthorized,
            ceiling.monitorHeldLeaseCanaryAuthorized,
            ceiling.monitorHeldLeaseCanaryPerformed,
            ceiling.durableEvidenceEstablished,
            ceiling.childLifetimeContinuityEstablished,
            ceiling.physicalMetalReservationEstablished,
            ceiling.mlxDeviceIdentityEstablished,
            ceiling.mlxExecutionAuthorized,
            ceiling.metalExecutionAuthorized,
            ceiling.native300MExecutionAuthorized,
            ceiling.pythonAuthorized,
            ceiling.cppAuthorized,
            ceiling.checkpointAdmissionGranted,
            ceiling.generalTrainingResumeAuthorized,
            ceiling.modelQualityEstablished,
            ceiling.productUseAuthorized,
            ceiling.publicationAuthorized,
        ]
    }

    private func assertExactFive(
        _ paths: [Authority.PathContract],
        source: String,
        test: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(paths.count, 5, file: file, line: line)
        XCTAssertEqual(
            paths.map(\.ordinal),
            [1, 2, 3, 4, 5],
            file: file,
            line: line
        )
        XCTAssertEqual(
            paths.map(\.gitStatus),
            ["M", "M", "M", "A", "A"],
            file: file,
            line: line
        )
        XCTAssertEqual(paths[3].path, source, file: file, line: line)
        XCTAssertEqual(paths[4].path, test, file: file, line: line)
        XCTAssertEqual(Set(paths.map(\.path)).count, 5, file: file, line: line)
    }

    private func assertRun(
        _ run: Authority.WorkflowClosure,
        id: Int,
        number: Int,
        suite: Int,
        event: String,
        ref: String,
        head: String,
        activeJob: Int,
        reviewedJob: Int,
        reviewedConclusion: String,
        reviewedSteps: Int,
        root: Int,
        isolated: [Int],
        focused: Int,
        live: Int,
        aggregate: Int,
        soleTestStarts: Int,
        created: String,
        updated: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(run.workflowName, "Prime active-root quarantine", file: file, line: line)
        XCTAssertEqual(run.runID, id, file: file, line: line)
        XCTAssertEqual(run.runNumber, number, file: file, line: line)
        XCTAssertEqual(run.runAttempt, 1, file: file, line: line)
        XCTAssertEqual(run.checkSuiteID, suite, file: file, line: line)
        XCTAssertEqual(run.event, event, file: file, line: line)
        XCTAssertEqual(run.ref, ref, file: file, line: line)
        XCTAssertEqual(run.headSHA, head, file: file, line: line)
        XCTAssertEqual(run.status, "completed", file: file, line: line)
        XCTAssertEqual(run.conclusion, "success", file: file, line: line)
        XCTAssertNil(run.previousAttemptURL, file: file, line: line)
        XCTAssertEqual(run.matchingRunCountForHead, 1, file: file, line: line)
        XCTAssertEqual(run.retryCount, 0, file: file, line: line)
        XCTAssertEqual(run.rerunCount, 0, file: file, line: line)
        XCTAssertEqual(run.actionsArtifactCount, 0, file: file, line: line)
        XCTAssertEqual(run.activeRootJobID, activeJob, file: file, line: line)
        XCTAssertEqual(run.activeRootJobConclusion, "success", file: file, line: line)
        XCTAssertEqual(run.reviewedMainJobID, reviewedJob, file: file, line: line)
        XCTAssertEqual(run.reviewedMainJobConclusion, reviewedConclusion, file: file, line: line)
        XCTAssertEqual(run.reviewedMainJobStepCount, reviewedSteps, file: file, line: line)
        XCTAssertEqual(run.activeRootLatinTestCount, 116, file: file, line: line)
        XCTAssertEqual(run.rootTestCount, root, file: file, line: line)
        XCTAssertEqual(run.isolatedGroupTestCounts, isolated, file: file, line: line)
        XCTAssertEqual(run.isolatedTestCount, isolated.reduce(0, +), file: file, line: line)
        XCTAssertEqual(run.focusedWholeTestCount, focused, file: file, line: line)
        XCTAssertEqual(run.retainedLiveTestCount, live, file: file, line: line)
        XCTAssertEqual(run.aggregateTestCount, aggregate, file: file, line: line)
        XCTAssertEqual(run.failureCount, 0, file: file, line: line)
        XCTAssertEqual(run.skipCount, 0, file: file, line: line)
        XCTAssertEqual(run.soleA2ImplementationTestStartCount, soleTestStarts, file: file, line: line)
        XCTAssertEqual(run.soleA2ImplementationTestPassCount, soleTestStarts, file: file, line: line)
        XCTAssertEqual(run.createdAt, created, file: file, line: line)
        XCTAssertEqual(run.startedAt, created, file: file, line: line)
        XCTAssertEqual(run.updatedAt, updated, file: file, line: line)
        if event == "push" {
            XCTAssertEqual(run.retainedMetalTestCount, 44, file: file, line: line)
            XCTAssertEqual(run.retainedMaintainedRuntimeTestCount, 1, file: file, line: line)
            XCTAssertEqual(run.retainedTokenizerTestCount, 1, file: file, line: line)
        } else {
            XCTAssertEqual(run.retainedMetalTestCount, 0, file: file, line: line)
            XCTAssertEqual(run.retainedMaintainedRuntimeTestCount, 0, file: file, line: line)
            XCTAssertEqual(run.retainedTokenizerTestCount, 0, file: file, line: line)
        }
    }

    private enum JSONPathComponent: Equatable {
        case key(String)
        case index(Int)
    }

    private typealias JSONPath = [JSONPathComponent]

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

    private func allArrayPaths(
        in value: Any,
        prefix: JSONPath = []
    ) -> [JSONPath] {
        if let object = value as? [String: Any] {
            return object.keys.sorted().flatMap { key in
                allArrayPaths(
                    in: object[key]!,
                    prefix: prefix + [.key(key)]
                )
            }
        }
        if let array = value as? [Any] {
            return [prefix] + array.indices.flatMap { index in
                allArrayPaths(
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
        guard let component = path.first else { return transform(value) }
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
        let remainder = Array(path.dropFirst())
        switch path[0] {
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

    private func canonicalJSONFragment(_ value: Any) -> Data {
        (try? JSONSerialization.data(
            withJSONObject: [value],
            options: [.sortedKeys, .withoutEscapingSlashes]
        )) ?? Data()
    }

    private func canonicalJSONData(_ value: Any) throws -> Data {
        try JSONSerialization.data(
            withJSONObject: value,
            options: [.sortedKeys, .withoutEscapingSlashes]
        )
    }

    private func mutateJSONValue(_ value: Any) -> Any {
        if value is NSNull { return "__was_null_mutation" }
        if let string = value as? String { return string + "__mutation" }
        if let number = value as? NSNumber {
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                return !number.boolValue
            }
            let integer = number.int64Value
            let incremented = integer.addingReportingOverflow(1)
            return NSNumber(
                value: incremented.overflow ? integer - 1 : incremented.partialValue
            )
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

    private func assertCanonicalRejects(
        _ object: Any,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> Data {
        let data = try canonicalJSONData(object)
        XCTAssertThrowsError(
            try Authority.decodeCanonical(data),
            file: file,
            line: line
        )
        return data
    }

    @discardableResult
    private func assertLooseDecodedDriftRejects(
        _ data: Data,
        authority: Authority,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Bool {
        guard let loose = try? JSONDecoder().decode(Authority.self, from: data),
              loose != authority
        else {
            return false
        }
        XCTAssertThrowsError(try loose.validate(), file: file, line: line)
        XCTAssertThrowsError(try loose.validateExactV1(), file: file, line: line)
        return true
    }

    private func assertNoncanonicalEncodingsReject(
        _ canonical: Data,
        object: [String: Any]
    ) throws {
        var prefixed = Data([0x20])
        prefixed.append(canonical)
        XCTAssertThrowsError(try Authority.decodeCanonical(prefixed))

        var suffixed = canonical
        suffixed.append(0x0A)
        XCTAssertThrowsError(try Authority.decodeCanonical(suffixed))

        let pretty = try JSONSerialization.data(
            withJSONObject: object,
            options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        )
        XCTAssertThrowsError(try Authority.decodeCanonical(pretty))

        var slashEscaped = try XCTUnwrap(String(data: canonical, encoding: .utf8))
        let slashIndex = try XCTUnwrap(slashEscaped.firstIndex(of: "/"))
        slashEscaped.replaceSubrange(slashIndex ... slashIndex, with: "\\/")
        let slashData = try XCTUnwrap(slashEscaped.data(using: .utf8))
        XCTAssertThrowsError(try Authority.decodeCanonical(slashData))

        var reordered = try XCTUnwrap(String(data: canonical, encoding: .utf8))
        let schemaField = "\"schemaVersion\":1,"
        let schemaRange = try XCTUnwrap(reordered.range(of: schemaField))
        reordered.removeSubrange(schemaRange)
        let opening = try XCTUnwrap(reordered.firstIndex(of: "{"))
        reordered.insert(contentsOf: schemaField, at: reordered.index(after: opening))
        let reorderedData = try XCTUnwrap(reordered.data(using: .utf8))
        XCTAssertThrowsError(try Authority.decodeCanonical(reorderedData))

        var duplicate = try XCTUnwrap(String(data: canonical, encoding: .utf8))
        let duplicateOpening = try XCTUnwrap(duplicate.firstIndex(of: "{"))
        duplicate.insert(
            contentsOf: schemaField,
            at: duplicate.index(after: duplicateOpening)
        )
        let duplicateData = try XCTUnwrap(duplicate.data(using: .utf8))
        XCTAssertThrowsError(try Authority.decodeCanonical(duplicateData))
    }

    private func requireSendable<T: Sendable>(_: T.Type) {}
}
