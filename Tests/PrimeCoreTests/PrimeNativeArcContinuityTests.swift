import XCTest
@testable import PrimeCore

final class PrimeNativeArcContinuityTests:
    XCTestCase
{
    func testFrozenNativeArcContinuityPlanValidates()
        throws
    {
        try PrimeNativeArcContinuityPlan.frozenV1
            .validate()
    }

    func testContinuationUsesOperatorSelectedExisting3BGeometry()
        throws
    {
        let plan =
            PrimeNativeArcContinuityPlan.frozenV1
        XCTAssertEqual(
            plan.continuationProfileID,
            PrimeNativeProfiles.exact3B.profileID
        )
        XCTAssertEqual(
            plan.continuationProfileSelectionAuthority,
            "operator_selected_bounded_mechanics_only"
        )
        XCTAssertEqual(
            plan.historicalProfileComparisonVerdict,
            "ABSTAIN"
        )
        XCTAssertFalse(
            plan.historicalThreeBillionScaleAuthorized
        )
        XCTAssertFalse(plan.newModelFamilyAuthorized)
        XCTAssertFalse(
            plan.pretrainedWeightImportAuthorized
        )
    }

    func testNeuralKitResearchRoleDoesNotReplaceProductVerify()
        throws
    {
        let plan =
            PrimeNativeArcContinuityPlan.frozenV1
        XCTAssertEqual(plan.neuralKitRoot, "neural-kit")
        XCTAssertFalse(
            plan.primeTensorCoreImportsNeuralKit
        )
        XCTAssertEqual(
            plan.neuralKitRole,
            "downstream_synthetic_and_research_artifact_regrade"
        )
        XCTAssertEqual(
            plan.productInferenceFacade,
            "NeuralKit.PrimeAskBrain"
        )
        XCTAssertEqual(
            plan.productVerificationAuthority,
            "PMHNP_app_PrimeChatModelEndpoint"
        )
        XCTAssertEqual(
            plan.productRecommendationAuthority,
            "PMHNP_EngineV21_plus_Recommender.recommend"
        )
        XCTAssertEqual(
            plan.neuralKitIntegrationMode,
            "versioned_cross_repository_artifact_contract_no_tensor_core_dependency"
        )
    }

    func testPMHNPIsReadOnlyHistoryNotPrimeRuntime()
        throws
    {
        let plan =
            PrimeNativeArcContinuityPlan.frozenV1
        XCTAssertEqual(
            plan.companionHistoricalRole,
            "read_only_migration_oracle_and_historical_evidence"
        )
        XCTAssertFalse(plan.companionWriteAuthorized)
        XCTAssertFalse(
            plan.companionRuntimeDependencyAuthorized
        )
        XCTAssertTrue(plan.primeOwnsNewNativeRuntime)
    }

    func testCompletedFoundationCannotBeReclassifiedAsPending()
        throws
    {
        let plan =
            PrimeNativeArcContinuityPlan.frozenV1
        XCTAssertFalse(plan.tokenizerRebuildAuthorized)
        XCTAssertFalse(plan.corpusRebuildAuthorized)
        XCTAssertFalse(
            plan.evaluationContractRebuildAuthorized
        )
        XCTAssertTrue(
            plan.completedEvidenceIDs.contains(
                "native_300m_1b_3b_fifteen_trial_profile_screen"
            )
        )
        XCTAssertTrue(
            plan.completedEvidenceIDs.contains(
                "synthetic_neuralkit_sz_triadic_verify_abstain_contract"
            )
        )
    }

    func testDurabilityAndResolutionPrecedeMetalContinuation()
        throws
    {
        let plan =
            PrimeNativeArcContinuityPlan.frozenV1
        XCTAssertEqual(
            plan.orderedNextActions,
            [
                "preserve_typed_adamw_cpu_receipt_off_device",
                "resolve_and_verify_current_slice_prime_exact_3b_and_cpu_evidence_bindings",
                "implement_exact_3b_typed_adamw_metal_interrupted_continuation_with_scoped_runtime_compatibility_replay",
            ]
        )
        XCTAssertEqual(
            plan.continuationInterruptionStep,
            1
        )
        XCTAssertEqual(
            plan.continuationComparisonStep,
            2
        )
        XCTAssertFalse(plan.longTrainingAuthorized)
        XCTAssertFalse(plan.productPromotionAuthorized)
    }

    func testCurrentSliceDoesNotImportHistoricalSubsystems()
        throws
    {
        let plan =
            PrimeNativeArcContinuityPlan.frozenV1
        XCTAssertEqual(
            plan.currentSliceScope,
            "exact_3b_typed_adamw_metal_interrupted_continuation_only"
        )
        XCTAssertFalse(
            plan.nativeContractAdapterMigrationAuthorizedInCurrentSlice
        )
        XCTAssertFalse(
            plan.neuralKitExecutionAuthorizedInCurrentSlice
        )
        let artifactsByID = Dictionary(
            uniqueKeysWithValues:
                plan.artifacts.map {
                    ($0.artifactID, $0)
                }
        )
        XCTAssertTrue(
            try plan.currentSliceRequiredArtifactIDs
                .allSatisfy {
                    try XCTUnwrap(
                        artifactsByID[$0]
                    ).authorityOwner
                        == "Ergentics/ergentics-prime"
                }
        )
    }

    func testTypedRestoreLocalLocatorAndDurabilityGapAreExplicit()
        throws
    {
        let artifact =
            try XCTUnwrap(
                PrimeNativeArcContinuityPlan
                    .frozenV1
                    .artifacts
                    .first(where: {
                        $0.artifactID
                            == "prime_typed_optimizer_restore_receipt"
                    })
            )
        XCTAssertEqual(
            artifact.locatorScope,
            .codexTaskOutputsRelative
        )
        XCTAssertEqual(
            artifact.locator,
            "prime-typed-restore-eeea8abe/prime-typed-optimizer-restore-receipt.v2.json"
        )
        XCTAssertEqual(
            artifact.disposition,
            .localOnlyPendingOffDeviceDurability
        )
        XCTAssertTrue(
            PrimeNativeArcContinuityPlan
                .frozenV1
                .unresolvedEvidenceIDs
                .contains(
                    "typed_restore_receipt_off_device_durability"
                )
        )
    }

    func testPrimeCheckedInArtifactsResolveWithExactBytes()
        throws
    {
        let plan =
            PrimeNativeArcContinuityPlan.frozenV1
        let repositoryRoot = URL(
            fileURLWithPath:
                FileManager.default.currentDirectoryPath,
            isDirectory: true
        )
        let primeArtifacts = plan.artifacts.filter {
            $0.authorityOwner
                == "Ergentics/ergentics-prime"
                && $0.locatorScope
                    == .repositoryRelativeAtPinnedRevision
        }
        XCTAssertFalse(primeArtifacts.isEmpty)
        for artifact in primeArtifacts {
            XCTAssertTrue(
                artifact.locator.hasPrefix("artifacts/")
            )
            let data = try Data(
                contentsOf:
                    repositoryRoot.appendingPathComponent(
                        artifact.locator,
                        isDirectory: false
                    ),
                options: .mappedIfSafe
            )
            XCTAssertEqual(
                PrimeSHA256.hexDigest(of: data),
                artifact.sha256
            )
        }
    }

    func testSourceAndSeedClaimsReferenceFrozenEvidence()
        throws
    {
        let plan =
            PrimeNativeArcContinuityPlan.frozenV1
        let artifactIDs = Set(
            plan.artifacts.map(\.artifactID)
        )
        XCTAssertTrue(
            artifactIDs.contains(
                plan.initializationEvidenceArtifactID
            )
        )
        XCTAssertTrue(
            artifactIDs.contains(
                plan.seedDomainEvidenceArtifactID
            )
        )
        XCTAssertEqual(
            plan.continuationInitializationContract,
            "source_bound_factorized_seed_random_initialization_no_weight_import"
        )
    }

    func testStaticInventoryDoesNotClaimArtifactResolution()
        throws
    {
        let plan =
            PrimeNativeArcContinuityPlan.frozenV1
        XCTAssertFalse(
            plan.crossRepositoryArtifactResolutionComplete
        )
        XCTAssertTrue(
            plan.unresolvedEvidenceIDs.contains(
                "cross_repository_artifact_resolution_and_compatibility_replay"
            )
        )
    }
}
