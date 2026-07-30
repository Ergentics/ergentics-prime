import Foundation
import XCTest
@testable import PrimeCore

final class PrimeNativeNeuralGateFixtureReplayPlanTests:
    XCTestCase
{
    private typealias Plan =
        PrimeNativeNeuralGateFixtureReplayPlan

    func testFrozenPlanValidatesAndIsCanonical()
        throws
    {
        let plan = Plan.frozenV1

        XCTAssertNoThrow(try plan.validate())
        XCTAssertEqual(plan.schemaVersion, 1)
        XCTAssertEqual(
            plan.status,
            "contract_frozen_execution_not_implemented"
        )
        XCTAssertFalse(plan.executionImplemented)
        XCTAssertFalse(plan.projectionReceiptAuthorized)
        XCTAssertEqual(
            try plan.contentSHA256(),
            "d9af927fd7b6056aa0f1e61b7828b82e6bf7f1a630f2e9efa9df5bedc23019f6"
        )

        let first =
            try PrimeCanonicalJSON.encode(plan)
        let second =
            try PrimeCanonicalJSON.encode(plan)
        XCTAssertEqual(first, second)
    }

    func testStageAParentUsesClosedHistoricalAuthority()
        throws
    {
        let parent = Plan.frozenV1.stageAParent

        XCTAssertNoThrow(try parent.validate())
        XCTAssertEqual(
            parent.receiptSHA256,
            "2e523c459faca835a8d0b1b43a6d6f770923d451516f4477df2f18fd4f7b2aed"
        )
        XCTAssertEqual(parent.receiptByteCount, 3_193)
        XCTAssertEqual(
            parent.claimScope,
            "source_pinned_neuralkit_native_language_gate_contract_projection_only"
        )
        XCTAssertEqual(
            parent.primeRevision,
            "a1ff82f092eed2093ab8062ef1bbea66f03cb3a3"
        )
        XCTAssertEqual(
            parent.primeTreeOID,
            "617c70e258e393cacc88896962f16b684480958a"
        )
        XCTAssertEqual(
            parent.sourceSnapshotRelativePath,
            "neural-gate-contract/prime-swift-source-snapshot.v1.json"
        )
        XCTAssertEqual(
            parent.sourceSnapshotByteCount,
            3_684_142
        )
        XCTAssertEqual(
            parent.sourceSnapshotSHA256,
            "5c433cf3a84c46c83b250fd6391ab5644252e5979eabc179f59cf1a1be5d0179"
        )
        XCTAssertEqual(
            parent.sourceIdentitySHA256,
            PrimePinnedHistoricalReleaseSource
                .nativeNeuralGateContractProjection20260730
                .sourceIdentitySHA256
        )
    }

    func testElevenInputsRemainExactAndInOrder()
        throws
    {
        let plan = Plan.frozenV1
        let pins = plan.inputPins

        XCTAssertEqual(pins.count, 11)
        XCTAssertEqual(
            pins.map(\.ordinal),
            Array(1 ... 11)
        )
        XCTAssertEqual(
            pins.map(\.role),
            PrimeNativeNeuralGateFixtureInputRole
                .allCases
        )
        XCTAssertEqual(
            pins.map(\.byteCount).reduce(0, +),
            1_232_537
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(
                    pins
                )
            ),
            plan.inputCatalogSHA256
        )
        XCTAssertTrue(
            pins.allSatisfy {
                !$0.dynamicallyCompiledOrExecuted
            }
        )
        XCTAssertEqual(
            pins.last?.repositoryRelativePath,
            "neural-kit/Package.resolved"
        )
        XCTAssertEqual(
            pins.last?.gitBlobOID,
            "18aef69512c82c3e6cdff192f3aa0a6ee13c702e"
        )
        XCTAssertEqual(
            pins.last?.sha256,
            "cf1ba313dcb0c959e80ba09d6cbe0c56bcd921523bda5cec2c682c8ae7696ab3"
        )

        try pins.forEach {
            try $0.validate()
        }
        XCTAssertNoThrow(
            try plan.adaptationProof.validate(
                against: pins
            )
        )
        XCTAssertEqual(
            plan.adaptationProof.entries.map(
                \.donorSHA256
            ),
            pins.map(\.sha256)
        )
        XCTAssertEqual(
            plan.adaptationProof.entries.map {
                $0.derivation.expectedOutputByteCount
            },
            [
                368_918,
                21_320,
                177_032,
                216_815,
                18_069,
                51_514,
                16_567,
                190_002,
                2_397,
                88_141,
                1_949,
            ]
        )
        XCTAssertEqual(
            plan.adaptationProof.entries[8]
                .derivation.expectedOutputSHA256,
            "4d9847738c6e3079d8951a3ade21355d6d5be56c193b98a6151b634930e2e51f"
        )
        XCTAssertEqual(
            plan.adaptationProof.entries[9]
                .derivation.expectedOutputSHA256,
            "e04daaf783f0cb79958daea9a70579fc959b47ceea4ae913bcb69cdc458fcf99"
        )
        XCTAssertEqual(
            plan.adaptationProof.entries[9]
                .derivation.requiredInputOrdinals,
            [
                10,
                11,
            ]
        )
        XCTAssertEqual(
            plan.adaptationProof.entries[1]
                .primeDestinationRelativePath,
            "Sources/ErgenticsPrimeRuntime/PrimeNativeByteTokenizer.swift"
        )
        XCTAssertEqual(
            plan.adaptationProof
                .historicalFixtureInheritedTryBangCount,
            11
        )
        XCTAssertTrue(
            plan.adaptationProof
                .historicalFixtureContainsAdditionalTrapSites
        )
        XCTAssertFalse(
            plan.adaptationProof
                .historicalFixtureWhollyFailClosed
        )
        XCTAssertTrue(
            plan.adaptationProof
                .historicalFixtureFreshProcessContainmentRequired
        )
    }

    func testHistoricalLeakCannotGroundTargetIndependence()
        throws
    {
        let plan = Plan.frozenV1
        let historical = plan.arms[0]
        let corrected = plan.arms[1]

        XCTAssertEqual(
            plan.historicalLeakFindings.map(
                \.findingID
            ),
            [
                "historical_zero_shot_length_uses_target_count",
                "historical_trained_prediction_copies_expected_completion",
                "historical_target_independence_declaration_conflicts_with_construction",
                "historical_decision_count_uses_target_count",
            ]
        )
        XCTAssertEqual(
            historical.arm,
            .historicalForensic
        )
        XCTAssertEqual(
            historical.predictionProvenance,
            "synthetic_oracle_forged"
        )
        XCTAssertFalse(
            historical.targetIndependenceEligible
        )
        XCTAssertFalse(
            historical
                .terminalStageBPassAloneEligible
        )
        XCTAssertEqual(
            historical
                .targetIndependenceDisposition,
            .mandatoryAbstainKnownHistoricalLeak
        )
        XCTAssertTrue(
            historical.forensicMechanicsPassEligible
        )
        XCTAssertTrue(
            historical
                .terminalMechanicsContributionRequired
        )

        XCTAssertEqual(
            corrected.arm,
            .correctedFixedCapEOS
        )
        XCTAssertTrue(corrected.promptOnlyGeneration)
        XCTAssertTrue(corrected.fixedCapEOSGeneration)
        XCTAssertTrue(
            corrected.targetIndependenceEligible
        )
        XCTAssertFalse(
            corrected
                .terminalStageBPassAloneEligible
        )
        XCTAssertEqual(
            corrected.targetIndependenceDisposition,
            .requiresObservedPass
        )
        XCTAssertTrue(
            corrected
                .terminalMechanicsContributionRequired
        )
        XCTAssertNotEqual(
            historical.fingerprintNamespace,
            corrected.fingerprintNamespace
        )
    }

    func testHistoricalEnvelopeCannotNominateExpectedRecordsOrResidues()
        throws
    {
        let plan = Plan.frozenV1

        XCTAssertEqual(
            plan.historicalSummaryRecordCount,
            59_497
        )
        XCTAssertFalse(
            plan
                .historicalSummaryMaySupplyExpectedRecordsOrResidues
        )
        XCTAssertTrue(
            plan.requiredFalseClaims.contains(
                .historicalResidueParityEstablished
            )
        )
        XCTAssertTrue(
            plan.requiredFalseClaims.contains(
                .historicalPerMutationParityEstablished
            )
        )
    }

    func testInvariantPublicationIsRawByteFramedAndSHAAuthoritative()
        throws
    {
        let contract =
            Plan.frozenV1.invariantSerialization

        XCTAssertNoThrow(try contract.validate())
        XCTAssertEqual(
            contract.recordOrdering,
            "raw_utf8_lexicographic_ascending"
        )
        XCTAssertEqual(
            contract.recordLengthEncoding,
            "uint64_big_endian"
        )
        XCTAssertEqual(
            contract.maximumRecordsPerChunk,
            4_096
        )
        XCTAssertEqual(contract.chunkOrdinalBase, 0)
        XCTAssertFalse(contract.emptyChunkPermitted)
        XCTAssertTrue(contract.preserveDuplicates)
        XCTAssertFalse(
            contract.unicodeNormalizationPermitted
        )
        XCTAssertFalse(
            contract.lineDelimiterEncodingUsed
        )
        XCTAssertTrue(contract.chunkSHA256Required)
        XCTAssertTrue(
            contract
                .orderedMultisetStreamSHA256Required
        )
        XCTAssertFalse(
            contract
                .finiteFieldFingerprintIsArtifactIdentity
        )
    }

    func testAcceleratedFingerprintCannotReplaceDirectFingerprint()
        throws
    {
        let contract =
            Plan.frozenV1.fingerprintReplay

        XCTAssertNoThrow(try contract.validate())
        XCTAssertTrue(
            contract.directRecomputedInEveryProcess
        )
        XCTAssertTrue(
            contract.acceleratedRecomputedInEveryProcess
        )
        XCTAssertTrue(
            contract.exactDirectAcceleratedEquality
        )
        XCTAssertTrue(
            contract.cacheRequiresRawByteEquality
        )
        XCTAssertTrue(
            contract.staleCacheMutationRequired
        )
        XCTAssertTrue(
            contract.directFingerprintIsSupplemental
        )
        XCTAssertTrue(
            contract.affineCompositionEquation
                .contains(
                    "left.addend_times_right.multiplier_plus_right.addend"
                )
        )
    }

    func testMutationCatalogRemainsExactStageAOrder()
        throws
    {
        let plan = Plan.frozenV1
        let projection =
            PrimeNativeNeuralGateContractProjection
            .frozenV1

        XCTAssertEqual(
            plan.requiredMutationIDs.count,
            46
        )
        XCTAssertEqual(
            plan.requiredMutationIDs,
            projection.mutationCatalog.map(
                \.mutationID
            )
        )
        XCTAssertEqual(
            plan.requiredMutationExpectedLegs,
            projection.mutationCatalog.map(
                \.expectedFailedLeg
            )
        )
        let catalogSHA256 =
            PrimeSHA256.hexDigest(
                of:
                try PrimeCanonicalJSON.encode(
                    projection.mutationCatalog
                )
            )
        XCTAssertEqual(
            catalogSHA256,
            plan.historicalMutationCatalogSHA256
        )
    }

    func testCorrectedExecutorAndMutationCatalogAreExact()
        throws
    {
        let plan = Plan.frozenV1
        let executor = plan.correctedExecutor

        XCTAssertNoThrow(try executor.validate())
        XCTAssertEqual(
            executor.generationContractID,
            "greedy_native_bytes_eos_fixed_cap64_kv_v2"
        )
        XCTAssertEqual(
            executor.maximumGenerationTokenDecisions,
            64
        )
        XCTAssertTrue(
            executor.eosAvailableAtEveryDecision
        )
        XCTAssertFalse(
            executor.targetVisibleToExecutionLoop
        )
        XCTAssertFalse(
            executor.targetDerivedOutputPermitted
        )
        XCTAssertFalse(
            executor.completionSupportMayNarrow
        )
        XCTAssertEqual(
            plan.correctedMutationCatalog.map(
                \.mutation
            ),
            PrimeNativeNeuralGateCorrectedFixtureMutation
                .allCases
        )
        XCTAssertTrue(
            plan.correctedMutationCatalog
                .allSatisfy {
                    $0.arm == .correctedFixedCapEOS
                        && $0
                        .fingerprintDivergenceRequired
                        && $0
                        .recordExactRestorationRequired
                        && $0
                        .fingerprintExactRestorationRequired
                }
        )
        XCTAssertNoThrow(
            try plan.mutationOutcome.validate()
        )
    }

    func testEveryArmMustRecomputeGateStatisticsAndCountVerdict()
        throws
    {
        let plan = Plan.frozenV1
        let gate = plan.gateObservation

        XCTAssertNoThrow(try gate.validate())
        XCTAssertEqual(gate.criticalLegs.count, 10)
        XCTAssertTrue(gate.requiredForEveryArm)
        XCTAssertTrue(
            gate.tenCriticalLegOutcomesRecomputed
        )
        XCTAssertTrue(
            gate.projectedLossStatisticsRecomputed
        )
        XCTAssertTrue(
            gate.fixedPromptRunnerUpMarginRecomputed
        )
        XCTAssertTrue(
            gate.countDerivedLabelRecomputed
        )
        XCTAssertTrue(
            gate.allCriticalVerdictRecomputed
        )
        XCTAssertFalse(
            gate.candidateDeclaredAggregatesAreAuthority
        )
        XCTAssertFalse(
            gate.countLabelIsIndependentTriad
        )
        XCTAssertFalse(
            gate.guardedStatisticalEntanglementPerformed
        )
        XCTAssertFalse(
            gate.verdict
                .agentContractKitFourTierAuditPerformed
        )
    }

    func testTruthBoundaryRequiresCorrectedArmAndKeepsPhysicalClaimsFalse()
        throws
    {
        let plan = Plan.frozenV1
        let requiredTrue =
            Set(plan.requiredTrueClaims)
        let requiredFalse =
            Set(plan.requiredFalseClaims)

        XCTAssertTrue(
            requiredTrue.contains(
                .historicalForensicReplayExecuted
            )
        )
        XCTAssertTrue(
            requiredTrue.contains(
                .correctedFixedCapEOSReplayExecuted
            )
        )
        XCTAssertTrue(
            requiredTrue.contains(
                .correctedTargetIndependenceEstablished
            )
        )
        XCTAssertTrue(
            requiredTrue.contains(
                .historicalFortySixMutationsDetectedDivergentAndExactlyRestored
            )
        )
        XCTAssertTrue(
            requiredTrue.contains(
                .correctedInvariantRecordsMaterialized
            )
        )
        XCTAssertTrue(
            requiredTrue.contains(
                .correctedDirectAcceleratedFingerprintEqual
            )
        )
        XCTAssertTrue(
            requiredTrue.contains(
                .correctedLeakageMutationsDetectedDivergentAndExactlyRestored
            )
        )
        XCTAssertTrue(
            requiredTrue.contains(
                .historicalTenCriticalLegsRecomputed
            )
        )
        XCTAssertTrue(
            requiredTrue.contains(
                .correctedTenCriticalLegsRecomputed
            )
        )
        XCTAssertTrue(
            requiredTrue.contains(
                .companionSourceStateUnchanged
            )
        )
        for claim in [
            PrimeNativeNeuralGateReplayClaim
                .adapterSourceContractsValidated,
            .stageAParentEvidenceCopiedAndRevalidated,
            .currentPrimeSourceClosureBound,
            .currentPrimeSourceStateUnchanged,
            .compiledTargetSourceClosureValidated,
            .releaseSourceExecutableIdentitiesJoined,
            .probeReleaseExecutableBound,
            .verifierReleaseExecutableBound,
            .probeVerifierProcessesDistinct,
            .probeVerifierExecutableImagesDistinct,
        ] {
            XCTAssertTrue(
                requiredTrue.contains(claim)
            )
        }
        XCTAssertTrue(
            requiredFalse.contains(
                .historicalFixtureTargetIndependent
            )
        )
        XCTAssertTrue(
            requiredFalse.contains(
                .historicalForensicMaterializerWhollyFailClosed
            )
        )
        XCTAssertTrue(
            requiredFalse.contains(
                .neuralKitModuleExecuted
            )
        )
        XCTAssertTrue(
            requiredFalse.contains(
                .modelExecutionPerformed
            )
        )
        XCTAssertTrue(
            requiredFalse.contains(
                .physicalCheckpointObserved
            )
        )
        XCTAssertTrue(
            requiredFalse.contains(
                .reproducibleBuildProvenanceEstablished
            )
        )
        XCTAssertTrue(
            requiredFalse.contains(
                .diagonalHessianEvaluated
            )
        )
        XCTAssertTrue(
            requiredTrue.isDisjoint(
                with: requiredFalse
            )
        )
        XCTAssertNoThrow(
            try plan.outcomeComposition.validate()
        )
        XCTAssertEqual(
            plan.outcomeComposition
                .historicalTargetIndependenceRequired,
            .abstain
        )
        XCTAssertEqual(
            plan.outcomeComposition
                .modelCapabilityOutcome,
            .abstain
        )
        XCTAssertTrue(
            plan.outcomeComposition
                .terminalPassRequiresAllArms
        )
    }

    func testCLITargetAndNextPrerequisiteAreFrozen()
        throws
    {
        let plan = Plan.frozenV1

        XCTAssertEqual(
            plan.probeArguments,
            [
                "--stage-a-root",
                "--companion-root",
                "--prime-root",
                "--artifact-root",
            ]
        )
        XCTAssertEqual(
            plan.verifierArguments,
            [
                "--prime-root",
                "--artifact-root",
            ]
        )
        XCTAssertEqual(
            plan.targetGraph.map(\.target),
            [
                "ErgenticsPrimeRuntime",
                "PrimeNativeNeuralGateReplayMechanics",
                "PrimeNativeNeuralGateReplay",
                "PrimeNativeNeuralGateHistoricalFixtureWorker",
                "PrimeNativeNeuralGateReplayProbe",
                "PrimeNativeNeuralGateReplayVerifier",
            ]
        )
        XCTAssertEqual(
            plan.immediateImplementationPrerequisite,
            "implement_stage_b_primecore_trusted_external_child_factory_direct_swift_package_executable_suspended_full_region_query_transcript_mapped_vnode_descriptor_read_fstat_hash_capability_calibration_raw_exact_pid_wait_fail_closed_stream_lifecycle_historical_worker_typed_artifact_recomputation_corrected_fixed_cap_eos_probe_verifier_and_exact_path_metadata_inventory"
        )
        XCTAssertEqual(
            plan.postPassNextPrerequisite,
            "physical_native_checkpoint_and_evaluation_shard_binding"
        )
        XCTAssertEqual(
            plan.failurePrecedence,
            [
                "output_root_path_type_owner_link_mode_and_relationship_safety",
                "current_clean_prime_release_source_snapshot_and_probe_executable_binding",
                "independent_direct_swift_package_executable_describe_trusted_capture_capability_initial_suspended_full_region_query_transcript_mapped_vnode_preopened_descriptor_stable_bytes_capability_calibration_no_overflow_raw_exact_pid_wait_reap_and_authority_subgraph_reconciliation",
                "six_process_topology_worker_death_reap_and_exact_role_prefix_inventory",
                "closed_stage_a_parent_and_source_identity",
                "lossless_stage_a_parent_evidence_copy_and_revalidation",
                "companion_revision_tree_eleven_input_pins_and_unchanged_pre_post_state",
                "copied_donor_byte_bindings",
                "adapter_source_contract_mapping_and_recomputed_proof",
                "historical_fixture_exact_forensic_reconstruction",
                "corrected_prompt_only_fixed_cap_eos_construction",
                "per_arm_complete_raw_utf8_invariant_multiset_publication",
                "per_arm_direct_accelerated_fingerprint_exact_equality",
                "per_arm_ordered_mutation_detection_expected_leg_divergence_and_exact_restoration",
                "distinct_release_verifier_executable_source_closure_and_full_reconstruction",
                "exclusive_receipt_last_publication",
            ]
        )
        XCTAssertNoThrow(try plan.rootPolicy.validate())
        XCTAssertNoThrow(
            try plan.outputContract.validate()
        )
        XCTAssertNoThrow(
            try plan.sourceExecutionBinding
                .validate()
        )
        XCTAssertTrue(
            plan.rootPolicy
                .companionRootReadOnlyDuringRun
        )
        XCTAssertTrue(
            plan.rootPolicy.stageAArtifactDisjoint
        )
        XCTAssertEqual(
            plan.outputContract
                .copiedSourceBlobRelativePaths.count,
            11
        )
        XCTAssertEqual(
            plan.outputContract
                .stageAParentReachableDescriptorBindingCount,
            35
        )
        XCTAssertEqual(
            plan.outputContract
                .stageAParentReachableImmutableDataBindingCount,
            28
        )
        XCTAssertEqual(
            plan.outputContract
                .stageAParentReachableExecutableBindingCount,
            7
        )
        XCTAssertEqual(
            plan.outputContract
                .stageAParentTerminalReceiptCount,
            1
        )
        XCTAssertEqual(
            plan.outputContract
                .stageAParentTotalCopiedArtifactCount,
            36
        )
        XCTAssertEqual(
            plan.outputContract
                .stageAParentTotalCopiedImmutableDataCount,
            29
        )
        XCTAssertEqual(
            plan.outputContract
                .stageAParentTotalCopiedExecutableCount,
            7
        )
        XCTAssertEqual(
            plan.outputContract
                .stageAParentAllowedPurposes,
            [
                .immutableData,
                .executable,
            ]
        )
        XCTAssertEqual(
            plan.outputContract
                .ordinaryArtifactPurpose,
            .immutableData
        )
        XCTAssertEqual(
            plan.outputContract.ordinaryArtifactMode,
            "0444"
        )
        XCTAssertEqual(
            plan.outputContract
                .runningExecutablePurpose,
            .executable
        )
        XCTAssertEqual(
            plan.outputContract.runningExecutableMode,
            "0555"
        )
        XCTAssertEqual(
            plan.outputContract
                .executableBindingManifestPurpose,
            .immutableData
        )
        XCTAssertEqual(
            plan.outputContract
                .executableBindingManifestMode,
            "0444"
        )
        XCTAssertTrue(
            plan.outputContract
                .stageAParentPathClassOverridesOrdinary
        )
        XCTAssertTrue(
            plan.outputContract
                .runningExecutablePathClassOverridesOrdinary
        )
        XCTAssertEqual(
            plan.outputContract
                .terminalReceiptPurpose,
            .immutableData
        )
        XCTAssertEqual(
            plan.outputContract.terminalReceiptMode,
            "0444"
        )
        XCTAssertTrue(
            plan.outputContract
                .stageAParentExactBindingEqualityRequired
        )
        XCTAssertTrue(
            plan.outputContract
                .outputPathNamespaceClassificationRequired
        )
        XCTAssertTrue(
            plan.outputContract
                .exactPreReceiptRealizedPathAndMetadataInventoryRequired
        )
        XCTAssertNoThrow(
            try plan.outputContract
                .pathClassification.validate()
        )
        XCTAssertEqual(
            plan.outputContract.pathClassification
                .classification(
                    for:
                        "neural-gate-replay/historical/probe/invariant-chunks/00000001.v1.bin"
                ),
            .ordinaryImmutableData
        )
        XCTAssertEqual(
            plan.outputContract.pathClassification
                .classification(
                    for:
                        "neural-gate-replay/parent/stage-a/prime-native-neural-gate-contract-projection-receipt.v1.json"
                ),
            .stageAParentCopiedArtifact
        )
        XCTAssertEqual(
            plan.fixedOutputRelativePaths.last,
            plan.outputContract.receiptRelativePath
        )
        XCTAssertEqual(
            plan.outputContract
                .adaptationProofManifestRelativePath,
            plan.adaptationProof
                .proofManifestRelativePath
        )
        XCTAssertTrue(
            plan.fixedOutputRelativePaths.contains(
                plan.outputContract
                    .primeSourceSnapshotRelativePath
            )
        )
        XCTAssertTrue(
            plan.fixedOutputRelativePaths.contains(
                plan.outputContract
                    .probeRunningExecutableRelativePath
            )
        )
        XCTAssertTrue(
            plan.fixedOutputRelativePaths.contains(
                plan.outputContract
                    .verifierRunningExecutableRelativePath
            )
        )
        XCTAssertTrue(
            plan.fixedOutputRelativePaths.contains(
                plan.sourceExecutionBinding
                    .swiftPackageDescribeRelativePath
            )
        )
        XCTAssertTrue(
            Set(plan.fixedOutputRelativePaths)
                .isSuperset(
                    of: Set(
                        plan.sourceExecutionBinding
                            .swiftPackageDescribeCaptureRecordRelativePaths
                    )
                )
        )
        XCTAssertTrue(
            plan.fixedOutputRelativePaths.contains(
                plan.sourceExecutionBinding
                    .compiledSourceClosureRelativePath
            )
        )
        XCTAssertTrue(
            Set(plan.fixedOutputRelativePaths)
                .isSuperset(
                    of: Set(
                        plan.outputContract
                            .copiedSourceBlobRelativePaths
                    )
                )
        )
    }

    func testReleaseSourceClosureAndRunningImagesAreJoined()
        throws
    {
        let contract =
            Plan.frozenV1.sourceExecutionBinding

        XCTAssertNoThrow(try contract.validate())
        XCTAssertEqual(
            contract.requiredBuildConfiguration,
            "release"
        )
        XCTAssertEqual(
            contract.targetClosureRules.map(
                \.targetName
            ),
            [
                "PrimeCore",
                "PrimeNativeCorpusReplayMechanics",
                "PrimeNativeCorpusReplay",
                "PrimeNativeNeuralGateContract",
                "ErgenticsPrimeRuntime",
                "PrimeNativeNeuralGateReplayMechanics",
                "PrimeNativeNeuralGateReplay",
                "PrimeNativeNeuralGateHistoricalFixtureWorker",
                "PrimeNativeNeuralGateReplayProbe",
                "PrimeNativeNeuralGateReplayVerifier",
            ]
        )
        XCTAssertEqual(
            contract.processBindingRules.map(\.role),
            [
                .probe,
                .verifier,
            ]
        )
        XCTAssertTrue(
            contract.targetClosureRules.allSatisfy {
                $0.completeSortedSwiftFileEnumerationRequired
                    && $0.fileIdentitiesDerivedOnlyFromSourceSnapshot
            }
        )
        XCTAssertTrue(
            contract
                .sourceSnapshotIdentityEqualsEmbeddedIdentity
        )
        XCTAssertTrue(
            contract
                .processIdentityEqualsSnapshotIdentity
        )
        XCTAssertTrue(
            contract
                .processSnapshotBindingEqualsClosureSnapshotBinding
        )
        XCTAssertTrue(
            contract.runningExecutableBindingFromSameProcess
        )
        XCTAssertTrue(
            contract.probeVerifierProcessIDsDistinct
        )
        XCTAssertTrue(
            contract
                .probeVerifierExecutableSHA256Distinct
        )
        XCTAssertTrue(
            contract.verifierRecomputesProbeBindings
        )
        XCTAssertTrue(
            contract
                .exactAuthorityTargetSubgraphRequired
        )
        XCTAssertTrue(
            contract
                .swiftPackageDescribeCaptureImplementationRequiredBeforeExecution
        )
        XCTAssertEqual(
            contract.swiftPackageDescribeCapturePolicy,
            "direct_swift_package_executable_describe_type_json_empty_environment_start_suspended_full_region_transcript_descriptor_join_trusted_capture_bounded_output_raw_exact_pid_wait_no_shell_fail_closed_lifecycle_v3"
        )
        XCTAssertEqual(
            contract
                .swiftPackageDescribeExecutableIdentityAuthority,
            "frozen_regular_file_full_file_sha256_byte_count_root_owner_mode_link_no_symlink_any_cloexec_and_live_mapped_vnode_descriptor_join_v2"
        )
        XCTAssertEqual(
            contract
                .swiftPackageDescribeExpectedExecutableSHA256,
            "dc1a5f5bd4f05be81b8cc4a4bc6e0fd8846210e4cb829062d0fed3d03f79b753"
        )
        XCTAssertEqual(
            contract
                .swiftPackageDescribeExpectedExecutableByteCount,
            23_293_616
        )
        XCTAssertEqual(
            contract
                .swiftPackageDescribeExpectedExecutableOwnerUserID,
            0
        )
        XCTAssertEqual(
            contract
                .swiftPackageDescribeExpectedExecutableOwnerGroupID,
            0
        )
        XCTAssertEqual(
            contract
                .swiftPackageDescribeExpectedExecutablePermissionMode,
            0o755
        )
        XCTAssertEqual(
            contract
                .swiftPackageDescribeExpectedExecutableLinkCount,
            1
        )
        XCTAssertEqual(
            contract.swiftPackageDescribeExactArguments,
            [
                "describe",
                "--type",
                "json",
            ]
        )
        XCTAssertFalse(
            contract
                .swiftPackageDescribeOutputAcceptedWithoutValidatedCapture
        )
        XCTAssertTrue(
            contract
                .swiftPackageDescribeMappedChildImageCaptureRequired
        )
        XCTAssertEqual(
            contract
                .swiftPackageDescribeMappedChildImageCaptureAuthority,
            "primecore_trusted_external_child_descriptor_open_start_suspended_full_region_query_transcript_mapped_vnode_join_pre_resume_stability_sigcont_raw_exact_pid_wait_reap_post_reap_stability_v3"
        )
        XCTAssertEqual(
            contract
                .swiftPackageDescribeMappedRegionEnumerationPolicy,
            "proc_pidregionpathinfo_full_query_transcript_address_plus_size_progression_terminal_zero_errno_zero_nonprogress_overflow_error_fail_closed_v2"
        )
        XCTAssertTrue(
            contract
                .swiftPackageDescribeCaptureCapabilityCalibrationRequired
        )
        XCTAssertEqual(
            contract
                .swiftPackageDescribeCaptureCapabilityCalibrationPolicy,
            "runtime_constants_struct_size_same_child_start_suspended_full_region_transcript_descriptor_join_sigcont_raw_exact_pid_wait_reap_no_escalation_v2"
        )
        XCTAssertTrue(
            contract
                .swiftPackageDescribeTrustedCaptureCapabilityRequired
        )
        XCTAssertEqual(
            contract
                .swiftPackageDescribeTrustedCaptureCapabilityAuthority,
            "primecore_non_codable_factory_result_binding_role_launch_descriptor_read_bytes_fstat_region_transcript_waitpid_and_stream_lifecycle_v2"
        )
        XCTAssertTrue(
            contract
                .swiftPackageDescribeExactPIDWaitObservationRequired
        )
        XCTAssertFalse(
            contract
                .swiftPackageDescribeProcPIDPathAuthoritative
        )
        XCTAssertFalse(
            contract
                .swiftPackageDescribeLaunchPathAloneAuthoritative
        )
        XCTAssertEqual(
            contract
                .swiftPackageDescribeDirectExecutableLeafName,
            "swift-package"
        )
        XCTAssertTrue(
            contract
                .swiftPackageDescribeInitialMappedImageMustEqualLaunchDescriptor
        )
        XCTAssertEqual(
            contract
                .swiftPackageDescribeCaptureRecordRelativePaths
                .count,
            2
        )
        XCTAssertFalse(
            contract.reproducibleBuildProvenanceClaimed
        )
    }

    func testPreReceiptPathAndMetadataInventoryRejectsInvalidNodesAndGaps()
        throws
    {
        let output = Plan.frozenV1.outputContract
        let classifier = output.pathClassification
        let stageAArtifacts =
            (0 ..< 36).map { ordinal in
                binding(
                    String(
                        format:
                            "neural-gate-replay/parent/stage-a/evidence-%02d.bin",
                        ordinal
                    ),
                    payload: "stage-a-\(ordinal)",
                    purpose:
                        ordinal < 29
                        ? .immutableData
                        : .executable
                )
            }
        func chunk(
            _ path: String
        ) -> PrimeArtifactBinding {
            binding(
                path,
                payload: "chunk"
            )
        }
        let probeChunks = [
            chunk(
                "neural-gate-replay/historical/probe/invariant-chunks/00000000.v1.bin"
            ),
        ]
        let verifierChunks = [
            chunk(
                "neural-gate-replay/historical/verifier/invariant-chunks/00000000.v1.bin"
            ),
        ]
        let correctedChunks = [
            chunk(
                "neural-gate-replay/corrected/invariant-chunks/00000000.v1.bin"
            ),
        ]
        let fixedBindings =
            classifier
            .ordinaryFixedRelativePaths
            .map {
                binding(
                    $0,
                    payload: "fixed:\($0)"
                )
            }
            + classifier
            .runningExecutableRelativePaths
            .map {
                binding(
                    $0,
                    payload: "executable:\($0)",
                    purpose: .executable
                )
            }
        let entries =
            (
                fixedBindings
                + stageAArtifacts
                + probeChunks
                + verifierChunks
                + correctedChunks
            )
            .map {
                PrimeNativeNeuralGateRealizedOutputEntry(
                    artifact: $0,
                    posixMode:
                        $0.purpose == .executable
                        ? "0555"
                        : "0444",
                    fileType: "regular_file",
                    linkCount: 1,
                    ownerMatchesCurrentEffectiveUser:
                        true,
                    capturedFromDescriptor: true
                )
            }
            .sorted {
                $0.artifact.relativePath
                    < $1.artifact.relativePath
            }
        func inventory(
            _ fileEntries:
                [PrimeNativeNeuralGateRealizedOutputEntry],
            unsupportedNodeRelativePaths:
                [String] = []
        ) -> PrimeNativeNeuralGateRealizedFilesystemInventory {
            let directories =
                PrimeNativeNeuralGateRealizedFilesystemInventory
                .requiredDirectoryRelativePaths(
                    forFileRelativePaths:
                        fileEntries.map {
                            $0.artifact
                                .relativePath
                        },
                    excludingRootRelativePath:
                        nil
                )
                .map {
                    PrimeNativeNeuralGateRealizedDirectoryEntry(
                        relativePath: $0,
                        posixMode: "0700",
                        ownerMatchesCurrentEffectiveUser:
                            true,
                        capturedFromDescriptor:
                            true
                    )
                }
            return .init(
                rootRelativePath: nil,
                directoryEntries: directories,
                fileEntries: fileEntries,
                unsupportedNodeRelativePaths:
                    unsupportedNodeRelativePaths,
                enumerationIncludesAllNodeTypes:
                    true,
                symbolicLinksFollowed: false
            )
        }
        let baselineInventory =
            inventory(entries)
        XCTAssertNoThrow(
            try output
                .validatePreReceiptRealizedPathAndMetadataInventory(
                    baselineInventory,
                    authenticatedStageACopiedArtifacts:
                        stageAArtifacts,
                    historicalProbeChunks:
                        probeChunks,
                    historicalVerifierChunks:
                        verifierChunks,
                    correctedChunks:
                        correctedChunks
                )
        )
        func assertBaselineBindingsReject(
            _ candidate:
                PrimeNativeNeuralGateRealizedFilesystemInventory,
            file: StaticString = #filePath,
            line: UInt = #line
        ) {
            XCTAssertThrowsError(
                try output
                    .validatePreReceiptRealizedPathAndMetadataInventory(
                        candidate,
                        authenticatedStageACopiedArtifacts:
                            stageAArtifacts,
                        historicalProbeChunks:
                            probeChunks,
                        historicalVerifierChunks:
                            verifierChunks,
                        correctedChunks:
                            correctedChunks
                    ),
                file: file,
                line: line
            )
        }
        assertBaselineBindingsReject(
            .init(
                rootRelativePath:
                    "neural-gate-replay",
                directoryEntries:
                    baselineInventory
                    .directoryEntries
                    .filter {
                        $0.relativePath
                            != "neural-gate-replay"
                    },
                fileEntries:
                    baselineInventory.fileEntries,
                unsupportedNodeRelativePaths: [],
                enumerationIncludesAllNodeTypes:
                    true,
                symbolicLinksFollowed: false
            )
        )
        let missingFixedPath =
            try XCTUnwrap(
                fixedBindings.first
            ).relativePath
        assertBaselineBindingsReject(
            inventory(
                entries.filter {
                    $0.artifact.relativePath
                        != missingFixedPath
                }
            )
        )
        let prematureReceipt =
            PrimeNativeNeuralGateRealizedOutputEntry(
                artifact:
                    binding(
                        output.receiptRelativePath,
                        payload: "premature-receipt"
                    ),
                posixMode: "0444",
                fileType: "regular_file",
                linkCount: 1,
                ownerMatchesCurrentEffectiveUser:
                    true,
                capturedFromDescriptor: true
            )
        assertBaselineBindingsReject(
            inventory(
                (entries + [prematureReceipt])
                    .sorted {
                        $0.artifact.relativePath
                            < $1.artifact.relativePath
                    }
            )
        )
        let extraDirectory =
            PrimeNativeNeuralGateRealizedDirectoryEntry(
                relativePath:
                    "neural-gate-replay/extra-empty-directory",
                posixMode: "0700",
                ownerMatchesCurrentEffectiveUser:
                    true,
                capturedFromDescriptor: true
            )
        assertBaselineBindingsReject(
            .init(
                rootRelativePath:
                    baselineInventory.rootRelativePath,
                directoryEntries:
                    (
                        baselineInventory.directoryEntries
                            + [extraDirectory]
                    ).sorted {
                        $0.relativePath
                            < $1.relativePath
                    },
                fileEntries:
                    baselineInventory.fileEntries,
                unsupportedNodeRelativePaths: [],
                enumerationIncludesAllNodeTypes:
                    true,
                symbolicLinksFollowed: false
            )
        )
        let metadataTarget =
            try XCTUnwrap(entries.first)
        let invalidFileMetadataEntries = [
            PrimeNativeNeuralGateRealizedOutputEntry(
                artifact: metadataTarget.artifact,
                posixMode: "0600",
                fileType: "regular_file",
                linkCount: 1,
                ownerMatchesCurrentEffectiveUser:
                    true,
                capturedFromDescriptor: true
            ),
            PrimeNativeNeuralGateRealizedOutputEntry(
                artifact: metadataTarget.artifact,
                posixMode: metadataTarget.posixMode,
                fileType: "symbolic_link",
                linkCount: 1,
                ownerMatchesCurrentEffectiveUser:
                    true,
                capturedFromDescriptor: true
            ),
            PrimeNativeNeuralGateRealizedOutputEntry(
                artifact: metadataTarget.artifact,
                posixMode: metadataTarget.posixMode,
                fileType: "regular_file",
                linkCount: 2,
                ownerMatchesCurrentEffectiveUser:
                    true,
                capturedFromDescriptor: true
            ),
            PrimeNativeNeuralGateRealizedOutputEntry(
                artifact: metadataTarget.artifact,
                posixMode: metadataTarget.posixMode,
                fileType: "regular_file",
                linkCount: 1,
                ownerMatchesCurrentEffectiveUser:
                    false,
                capturedFromDescriptor: true
            ),
            PrimeNativeNeuralGateRealizedOutputEntry(
                artifact: metadataTarget.artifact,
                posixMode: metadataTarget.posixMode,
                fileType: "regular_file",
                linkCount: 1,
                ownerMatchesCurrentEffectiveUser:
                    true,
                capturedFromDescriptor: false
            ),
        ]
        for replacement in invalidFileMetadataEntries {
            let candidateEntries =
                entries.map {
                    $0.artifact.relativePath
                            == metadataTarget
                            .artifact.relativePath
                        ? replacement
                        : $0
                }
            assertBaselineBindingsReject(
                inventory(candidateEntries)
            )
        }
        let firstDirectory =
            try XCTUnwrap(
                baselineInventory
                    .directoryEntries.first
            )
        let invalidDirectoryEntries = [
            PrimeNativeNeuralGateRealizedDirectoryEntry(
                relativePath:
                    firstDirectory.relativePath,
                posixMode: "0755",
                ownerMatchesCurrentEffectiveUser:
                    true,
                capturedFromDescriptor: true
            ),
            PrimeNativeNeuralGateRealizedDirectoryEntry(
                relativePath:
                    firstDirectory.relativePath,
                posixMode: "0700",
                ownerMatchesCurrentEffectiveUser:
                    false,
                capturedFromDescriptor: true
            ),
            PrimeNativeNeuralGateRealizedDirectoryEntry(
                relativePath:
                    firstDirectory.relativePath,
                posixMode: "0700",
                ownerMatchesCurrentEffectiveUser:
                    true,
                capturedFromDescriptor: false
            ),
        ]
        for replacement in invalidDirectoryEntries {
            let candidateDirectories =
                baselineInventory
                .directoryEntries.map {
                    $0.relativePath
                            == firstDirectory.relativePath
                        ? replacement
                        : $0
                }
            assertBaselineBindingsReject(
                .init(
                    rootRelativePath:
                        baselineInventory
                        .rootRelativePath,
                    directoryEntries:
                        candidateDirectories,
                    fileEntries:
                        baselineInventory.fileEntries,
                    unsupportedNodeRelativePaths: [],
                    enumerationIncludesAllNodeTypes:
                        true,
                    symbolicLinksFollowed: false
                )
            )
        }
        XCTAssertNil(
            classifier.classification(
                for:
                    "neural-gate-replay/parent/stage-a/README.md"
            )
        )
        let extra = binding(
            "neural-gate-replay/parent/stage-a/unbound-extra.bin",
            payload: "extra"
        )
        XCTAssertThrowsError(
            try output
                .validatePreReceiptRealizedPathAndMetadataInventory(
                    inventory(
                        (
                            entries
                            + [
                                .init(
                                    artifact: extra,
                                    posixMode:
                                        "0444",
                                    fileType:
                                        "regular_file",
                                    linkCount: 1,
                                    ownerMatchesCurrentEffectiveUser:
                                        true,
                                    capturedFromDescriptor:
                                        true
                                ),
                            ]
                        ).sorted {
                            $0.artifact.relativePath
                                < $1.artifact.relativePath
                        }
                    ),
                    authenticatedStageACopiedArtifacts:
                        stageAArtifacts,
                    historicalProbeChunks:
                        probeChunks,
                    historicalVerifierChunks:
                        verifierChunks,
                    correctedChunks:
                        correctedChunks
                )
        )
        XCTAssertThrowsError(
            try output
                .validatePreReceiptRealizedPathAndMetadataInventory(
                    inventory(entries),
                    authenticatedStageACopiedArtifacts:
                        stageAArtifacts,
                    historicalProbeChunks: [
                        chunk(
                            "neural-gate-replay/historical/probe/invariant-chunks/00000001.v1.bin"
                        ),
                    ],
                    historicalVerifierChunks:
                        verifierChunks,
                    correctedChunks:
                        correctedChunks
                )
        )
        XCTAssertThrowsError(
            try output
                .validatePreReceiptRealizedPathAndMetadataInventory(
                    inventory(
                        entries,
                        unsupportedNodeRelativePaths: [
                            "neural-gate-replay/historical/probe/unexpected-link",
                        ]
                    ),
                    authenticatedStageACopiedArtifacts:
                        stageAArtifacts,
                    historicalProbeChunks:
                        probeChunks,
                    historicalVerifierChunks:
                        verifierChunks,
                    correctedChunks:
                        correctedChunks
                )
        )
    }

    func testObservedSourceClosureAndProcessRecordsJoinExactImages()
        throws
    {
        let contract =
            Plan.frozenV1.sourceExecutionBinding
        let fixture =
            try observedSourceClosureFixture()
        let planSHA =
            fixture.closure.planSHA256

        XCTAssertTrue(
            contract
                .swiftPackageDescribeOutputOverflowRejected
        )
        XCTAssertTrue(
            contract
                .swiftPackageDescribeChildDeathObservedBeforeContinuationRequired
        )
        XCTAssertTrue(
            contract
                .swiftPackageDescribeChildReapBeforeContinuationRequired
        )
        XCTAssertEqual(
            contract
                .swiftPackageDescribeTerminationEscalationPolicy,
            "deadline_then_sigterm_wait_2s_then_sigkill_then_waitpid_observe_death_and_reap_v1"
        )
        XCTAssertNoThrow(
            try fixture.closure.validate(
                against: contract,
                expectedPlanSHA256: planSHA,
                snapshot: fixture.snapshot,
                swiftPackageDescribeData:
                    fixture
                    .swiftPackageDescribeData,
                expectedEmbeddedSourceIdentitySHA256:
                    fixture.sourceIdentity
            )
        )
        XCTAssertEqual(
            fixture.closure.targets.count,
            10
        )
        XCTAssertEqual(
            try fixture.closure
                .transitiveTargetNames(
                    for:
                        "PrimeNativeNeuralGateHistoricalFixtureWorker",
                    against: contract
                ),
            [
                "PrimeCore",
                "PrimeNativeCorpusReplayMechanics",
                "PrimeNativeCorpusReplay",
                "PrimeNativeNeuralGateContract",
                "ErgenticsPrimeRuntime",
                "PrimeNativeNeuralGateReplayMechanics",
                "PrimeNativeNeuralGateReplay",
                "PrimeNativeNeuralGateHistoricalFixtureWorker",
            ]
        )

        var targets = fixture.closure.targets
        let first = targets[0]
        targets[0] =
            PrimeNativeNeuralGateCompiledTargetSourceClosureRecord(
                targetName: first.targetName,
                sourceDirectoryRelativePath:
                    first
                    .sourceDirectoryRelativePath,
                directLocalDependencyNames:
                    first
                    .directLocalDependencyNames,
                sourceFiles:
                    Array(
                        first.sourceFiles.dropLast()
                    )
            )
        let truncated =
            PrimeNativeNeuralGateCompiledSourceClosureRecord(
                planSHA256: planSHA,
                primeSourceSnapshot:
                    fixture.snapshotBinding,
                swiftPackageDescribe:
                    fixture
                    .swiftPackageDescribeBinding,
                packageManifest:
                    fixture.closure.packageManifest,
                sourceIdentitySHA256:
                    fixture.sourceIdentity,
                embeddedSourceIdentitySHA256:
                    fixture.sourceIdentity,
                buildConfiguration: "release",
                targets: targets
            )
        XCTAssertThrowsError(
            try truncated.validate(
                against: contract,
                expectedPlanSHA256: planSHA,
                snapshot: fixture.snapshot,
                swiftPackageDescribeData:
                    fixture
                    .swiftPackageDescribeData,
                expectedEmbeddedSourceIdentitySHA256:
                    fixture.sourceIdentity
            )
        )

        let sourceState =
            PrimeNativeNeuralGatePrimeGitStateRecord(
                remoteURL:
                    "https://github.com/Ergentics/ergentics-prime.git",
                revision:
                    String(repeating: "1", count: 40),
                treeOID:
                    String(repeating: "2", count: 40),
                clean: true
            )
        let probeData = Data("probe-image".utf8)
        let verifierData =
            Data("verifier-image".utf8)
        func process(
            _ role:
                PrimeNativeNeuralGateReleaseProcessRole,
            pid: Int32,
            executableData: Data
        ) throws
            -> (
                PrimeNativeNeuralGateReleaseProcessBindingRecord,
                PrimeNativeNeuralGateSwiftPackageDescribeCaptureRecord,
                PrimeNativeNeuralGateTrustedExternalChildCapture
            )
        {
            let rule = try XCTUnwrap(
                contract.processBindingRules.first {
                    $0.role == role
                }
            )
            let executable =
                PrimeArtifactBinding(
                    relativePath:
                        rule
                        .runningExecutableRelativePath,
                    sha256:
                        PrimeSHA256.hexDigest(
                            of: executableData
                        ),
                    byteCount:
                        UInt64(executableData.count),
                    purpose: .executable
                )
            let captureEvidence =
                externalChildCaptureEvidence(
                    contract: contract,
                    supervisorProcessIdentifier:
                        pid,
                    childProcessIdentifier:
                        pid + 1_000
                )
            let describeCapture =
                PrimeNativeNeuralGateSwiftPackageDescribeCaptureRecord(
                    role: role,
                    planSHA256: planSHA,
                    supervisorProcessIdentifier:
                        pid,
                    childProcessIdentifier:
                        pid + 1_000,
                    swiftPackageExecutableAbsolutePath:
                        "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-package",
                    mappedChildMainImageAbsolutePath:
                        "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-package",
                    workingDirectoryAbsolutePath:
                        "/private/tmp/ergentics-prime",
                    externalChildCaptureEvidence:
                        captureEvidence,
                    standardOutput:
                        fixture
                        .swiftPackageDescribeBinding,
                    prePrimeSourceState:
                        sourceState,
                    postPrimeSourceState:
                        sourceState,
                    primeSourceSnapshot:
                        fixture.snapshotBinding,
                    packageManifest:
                        fixture
                        .closure.packageManifest,
                    contract: contract
                )
            let trustedCapture =
                try trustedExternalChildCapture(
                    evidence: captureEvidence,
                    role: role,
                    standardOutputData:
                        fixture
                        .swiftPackageDescribeData
                )
            let describeCaptureBinding =
                try describeCapture
                .artifactBinding()
            let value =
                PrimeNativeNeuralGateReleaseProcessBindingRecord(
                    recordRelativePath:
                        rule
                        .executableBindingRelativePath,
                    planSHA256: planSHA,
                    role: role,
                    processIdentifier: pid,
                    executableTargetName:
                        rule.executableTargetName,
                    exactTransitiveLocalTargetNames:
                        rule
                        .exactTransitiveLocalTargetNames,
                    prePrimeSourceState:
                        sourceState,
                    postPrimeSourceState:
                        sourceState,
                    preSourceSnapshotSHA256:
                        fixture.snapshotBinding
                        .sha256,
                    postSourceSnapshotSHA256:
                        fixture.snapshotBinding
                        .sha256,
                    primeSourceSnapshot:
                        fixture.snapshotBinding,
                    compiledSourceClosure:
                        fixture.closureBinding,
                    swiftPackageDescribeCapture:
                        describeCaptureBinding,
                    sourceIdentitySHA256:
                        fixture.sourceIdentity,
                    embeddedSourceIdentitySHA256:
                        fixture.sourceIdentity,
                    buildConfiguration:
                        "release",
                    runningExecutable:
                        executable
                )
            try value.validate(
                against: contract,
                trustedExternalChildCapture:
                    trustedCapture,
                expectedPlanSHA256: planSHA,
                closure: fixture.closure,
                closureBinding:
                    fixture.closureBinding,
                describeCapture:
                    describeCapture,
                describeCaptureBinding:
                    describeCaptureBinding,
                snapshot: fixture.snapshot,
                swiftPackageDescribeData:
                    fixture
                    .swiftPackageDescribeData,
                capturedRunningExecutableData:
                    executableData,
                expectedEmbeddedSourceIdentitySHA256:
                    fixture.sourceIdentity,
                expectedBuildConfiguration:
                    "release"
            )
            return (
                value,
                describeCapture,
                trustedCapture
            )
        }

        let (
            probe,
            probeDescribeCapture,
            _
        ) =
            try process(
                .probe,
                pid: 301,
                executableData: probeData
            )
        let (
            verifier,
            verifierDescribeCapture,
            verifierTrustedCapture
        ) = try process(
            .verifier,
            pid: 302,
            executableData: verifierData
        )
        func launchObservation(
            role:
                PrimeNativeNeuralGateReleaseProcessRole =
                    .verifier,
            exactArguments: [String]? = nil
        )
            -> PrimeNativeNeuralGateTrustedExternalChildLaunchObservation
        {
            PrimeNativeNeuralGateTrustedExternalChildLaunchObservation(
                role: role,
                exactArguments:
                    exactArguments
                    ?? verifierDescribeCapture
                    .exactArguments,
                directProcessWithoutShell:
                    verifierDescribeCapture
                    .directProcessWithoutShell,
                workingDirectoryAbsolutePath:
                    verifierDescribeCapture
                    .workingDirectoryAbsolutePath,
                workingDirectoryIsValidatedPrimeRoot:
                    verifierDescribeCapture
                    .workingDirectoryIsValidatedPrimeRoot,
                environmentKeyCount:
                    verifierDescribeCapture
                    .environmentKeyCount,
                standardInputPolicy:
                    verifierDescribeCapture
                    .standardInputPolicy,
                maximumWallSeconds:
                    verifierDescribeCapture
                    .maximumWallSeconds,
                terminationControlPolicy:
                    verifierDescribeCapture
                    .terminationControlPolicy
            )
        }
        func streamLifecycleObservation(
            maximumStandardOutputBytes:
                UInt64? = nil,
            standardOutputDrainCompleted:
                Bool? = nil
        )
            -> PrimeNativeNeuralGateTrustedExternalChildStreamLifecycleObservation
        {
            PrimeNativeNeuralGateTrustedExternalChildStreamLifecycleObservation(
                maximumStandardOutputBytes:
                    maximumStandardOutputBytes
                    ?? verifierDescribeCapture
                    .maximumStandardOutputBytes,
                standardOutputOverflowed:
                    verifierDescribeCapture
                    .standardOutputOverflowed,
                standardOutputDrainCompleted:
                    standardOutputDrainCompleted
                    ?? verifierDescribeCapture
                    .standardOutputDrainCompleted,
                maximumStandardErrorBytes:
                    verifierDescribeCapture
                    .maximumStandardErrorBytes,
                standardErrorOverflowed:
                    verifierDescribeCapture
                    .standardErrorOverflowed,
                standardErrorDrainCompleted:
                    verifierDescribeCapture
                    .standardErrorDrainCompleted
            )
        }
        func validateTrustedCaptureOnly(
            _ trustedCapture:
                PrimeNativeNeuralGateTrustedExternalChildCapture
        ) throws {
            try trustedCapture.validate(
                evidence:
                    verifierDescribeCapture
                    .externalChildCaptureEvidence,
                contract: contract,
                expectedSwiftPackageExecutableAbsolutePath:
                    verifierDescribeCapture
                    .swiftPackageExecutableAbsolutePath,
                expectedMappedChildMainImageAbsolutePath:
                    verifierDescribeCapture
                    .mappedChildMainImageAbsolutePath,
                standardOutputData:
                    fixture
                    .swiftPackageDescribeData,
                captureLaunchObservation:
                    launchObservation(),
                captureStreamLifecycleObservation:
                    streamLifecycleObservation()
            )
        }
        XCTAssertNoThrow(
            try validateTrustedCaptureOnly(
                verifierTrustedCapture
            )
        )
        var oneByteMutatedDescriptorData =
            try frozenSwiftPackageExecutableData()
        let mutatedDescriptorIndex =
            oneByteMutatedDescriptorData.startIndex
        oneByteMutatedDescriptorData[
            mutatedDescriptorIndex
        ] =
            oneByteMutatedDescriptorData[
                mutatedDescriptorIndex
            ] ^ 0x01
        let truncatedDescriptorData =
            Data(
                (try frozenSwiftPackageExecutableData())
                    .dropLast()
            )
        for descriptorReadData in [
            oneByteMutatedDescriptorData,
            truncatedDescriptorData,
        ] {
            let mismatchedDescriptorCapture =
                try trustedExternalChildCapture(
                    evidence:
                        verifierDescribeCapture
                        .externalChildCaptureEvidence,
                    role: .verifier,
                    standardOutputData:
                        fixture
                        .swiftPackageDescribeData,
                    descriptorReadDataOverride:
                        descriptorReadData
                )
            XCTAssertThrowsError(
                try validateTrustedCaptureOnly(
                    mismatchedDescriptorCapture
                )
            )
        }
        let wrongRoleTrustedCapture =
            try trustedExternalChildCapture(
                evidence:
                    verifierDescribeCapture
                    .externalChildCaptureEvidence,
                role: .verifier,
                standardOutputData:
                    fixture
                    .swiftPackageDescribeData,
                launchObservationOverride:
                    launchObservation(role: .probe)
            )
        XCTAssertThrowsError(
            try validateTrustedCaptureOnly(
                wrongRoleTrustedCapture
            )
        )
        let wrongArgumentsTrustedCapture =
            try trustedExternalChildCapture(
                evidence:
                    verifierDescribeCapture
                    .externalChildCaptureEvidence,
                role: .verifier,
                standardOutputData:
                    fixture
                    .swiftPackageDescribeData,
                launchObservationOverride:
                    launchObservation(
                        exactArguments: [
                            "package",
                            "describe",
                            "--type",
                            "json",
                        ]
                    )
            )
        XCTAssertThrowsError(
            try validateTrustedCaptureOnly(
                wrongArgumentsTrustedCapture
            )
        )
        let incompleteDrainTrustedCapture =
            try trustedExternalChildCapture(
                evidence:
                    verifierDescribeCapture
                    .externalChildCaptureEvidence,
                role: .verifier,
                standardOutputData:
                    fixture
                    .swiftPackageDescribeData,
                streamLifecycleObservationOverride:
                    streamLifecycleObservation(
                        standardOutputDrainCompleted:
                            false
                    )
            )
        XCTAssertThrowsError(
            try validateTrustedCaptureOnly(
                incompleteDrainTrustedCapture
            )
        )
        let alteredOutputBoundTrustedCapture =
            try trustedExternalChildCapture(
                evidence:
                    verifierDescribeCapture
                    .externalChildCaptureEvidence,
                role: .verifier,
                standardOutputData:
                    fixture
                    .swiftPackageDescribeData,
                streamLifecycleObservationOverride:
                    streamLifecycleObservation(
                        maximumStandardOutputBytes:
                            verifierDescribeCapture
                            .maximumStandardOutputBytes
                            + 1
                    )
            )
        XCTAssertThrowsError(
            try validateTrustedCaptureOnly(
                alteredOutputBoundTrustedCapture
            )
        )
        XCTAssertNoThrow(
            try PrimeNativeNeuralGateSwiftPackageDescribeCaptureRecord
                .validateProbeVerifierPairOfPrevalidatedRecords(
                    probe:
                        probeDescribeCapture,
                    verifier:
                        verifierDescribeCapture
                )
        )
        func mutatedVerifierCaptureObject(
            _ mutate:
                (inout [String: Any]) throws
                    -> Void
        ) throws
            -> PrimeNativeNeuralGateSwiftPackageDescribeCaptureRecord
        {
            let source =
                try PrimeCanonicalJSON.encode(
                    verifierDescribeCapture
                )
            var object = try XCTUnwrap(
                try JSONSerialization.jsonObject(
                    with: source
                ) as? [String: Any]
            )
            try mutate(&object)
            let data = try JSONSerialization.data(
                withJSONObject: object,
                options: [
                    .sortedKeys,
                    .withoutEscapingSlashes,
                ]
            )
            return try JSONDecoder().decode(
                PrimeNativeNeuralGateSwiftPackageDescribeCaptureRecord
                    .self,
                from: data
            )
        }
        func mutatedVerifierCapture(
            key: String,
            value: Any
        ) throws
            -> PrimeNativeNeuralGateSwiftPackageDescribeCaptureRecord
        {
            try mutatedVerifierCaptureObject {
                $0[key] = value
            }
        }
        func mutatedVerifierCaptureEvidence(
            key: String,
            value: Any
        ) throws
            -> PrimeNativeNeuralGateSwiftPackageDescribeCaptureRecord
        {
            try mutatedVerifierCaptureObject {
                object in
                var evidence = try XCTUnwrap(
                    object[
                        "external_child_capture_evidence"
                    ] as? [String: Any]
                )
                evidence[key] = value
                object[
                    "external_child_capture_evidence"
                ] = evidence
            }
        }
        func validateVerifierCapture(
            _ capture:
                PrimeNativeNeuralGateSwiftPackageDescribeCaptureRecord,
            useMatchingTrustedEvidence: Bool =
                false
        ) throws {
            let trustedCapture =
                useMatchingTrustedEvidence
                ? try trustedExternalChildCapture(
                    evidence:
                        capture
                        .externalChildCaptureEvidence,
                    role: capture.role,
                    standardOutputData:
                        fixture
                        .swiftPackageDescribeData,
                    swiftPackageExecutableAbsolutePath:
                        capture
                        .swiftPackageExecutableAbsolutePath,
                    mappedChildMainImageAbsolutePath:
                        capture
                        .mappedChildMainImageAbsolutePath,
                    workingDirectoryAbsolutePath:
                        capture
                        .workingDirectoryAbsolutePath
                )
                : verifierTrustedCapture
            try capture.validateForRunningRelease(
                against: contract,
                trustedExternalChildCapture:
                    trustedCapture,
                expectedPlanSHA256: planSHA,
                expectedSupervisorProcessIdentifier:
                    302,
                expectedPrimeSourceState:
                    sourceState,
                expectedPrimeSourceSnapshot:
                    fixture.snapshotBinding,
                expectedPackageManifest:
                    fixture
                    .closure.packageManifest,
                expectedStandardOutput:
                    fixture
                    .swiftPackageDescribeBinding,
                standardOutputData:
                    fixture
                    .swiftPackageDescribeData
            )
        }
        let rejectedCaptureMutations:
            [(String, Any)] = [
                (
                    "swift_package_executable_absolute_path",
                    "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../bin/swift-package"
                ),
                (
                    "swift_package_executable_absolute_path",
                    "/usr/bin/swift-package"
                ),
                (
                    "mapped_child_main_image_absolute_path",
                    "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../bin/swift-package"
                ),
                (
                    "mapped_child_main_image_absolute_path",
                    "/usr/bin/swift-package"
                ),
                (
                    "mapped_child_main_image_descriptor_opened_with_no_symbolic_links_in_path",
                    false
                ),
                (
                    "capture_capability_calibration_passed",
                    false
                ),
                (
                    "proc_pidpath_used_only_as_telemetry",
                    false
                ),
                (
                    "exact_arguments",
                    [
                        "package",
                        "describe",
                        "--type",
                        "json",
                    ]
                ),
                ("direct_process_without_shell", false),
                (
                    "working_directory_absolute_path",
                    "/private/tmp/not-ergentics-prime"
                ),
                (
                    "working_directory_is_validated_prime_root",
                    false
                ),
                ("environment_key_count", 1),
                ("standard_input_policy", "inherit_v1"),
                ("standard_output_overflowed", true),
                ("standard_output_drain_completed", false),
                ("standard_error_overflowed", true),
                ("standard_error_drain_completed", false),
                (
                    "termination_control_policy",
                    "unbounded_wait_v1"
                ),
                ("child_termination_observed", false),
                ("child_reaped", false),
            ]
        for (key, value) in
            rejectedCaptureMutations
        {
            let mutated =
                try mutatedVerifierCapture(
                    key: key,
                    value: value
                )
            XCTAssertThrowsError(
                try validateVerifierCapture(
                    mutated
                )
            )
            XCTAssertThrowsError(
                try PrimeNativeNeuralGateSwiftPackageDescribeCaptureRecord
                    .validateProbeVerifierPairOfPrevalidatedRecords(
                        probe:
                            probeDescribeCapture,
                        verifier: mutated
                )
            )
        }
        let inconsistentObservedWall =
            try mutatedVerifierCapture(
                key:
                    "observed_monotonic_wall_nanoseconds",
                value: 1
            )
        XCTAssertThrowsError(
            try validateVerifierCapture(
                inconsistentObservedWall
            )
        )
        let rejectedEvidenceMutations:
            [(String, Any)] = [
                (
                    "capability_calibration_passed",
                    false
                ),
                (
                    "mapped_region_enumeration_policy",
                    "first_executable_region_only"
                ),
                (
                    "applied_spawn_flags",
                    0x4000
                ),
                (
                    "posix_spawn_return_code",
                    1
                ),
                (
                    "proc_regionwithpathinfo_byte_count",
                    0
                ),
                (
                    "mapped_region_captured_monotonic_nanoseconds",
                    6_000
                ),
                (
                    "sigcont_return_code",
                    1
                ),
                (
                    "proc_pidpath_used_only_as_telemetry",
                    false
                ),
                (
                    "mapped_region_enumeration_completed",
                    false
                ),
                (
                    "terminal_mapped_region_query_return_byte_count",
                    1_272
                ),
                (
                    "terminal_mapped_region_query_errno",
                    1
                ),
                ("deadline_expired", true),
                ("sigterm_delivered", true),
                ("sigkill_delivered", true),
            ]
        for (key, value) in
            rejectedEvidenceMutations
        {
            XCTAssertThrowsError(
                try validateVerifierCapture(
                    try
                        mutatedVerifierCaptureEvidence(
                            key: key,
                            value: value
                        ),
                    useMatchingTrustedEvidence:
                        true
                )
            )
        }
        let nonprogressingEnumerationCapture =
            try mutatedVerifierCaptureObject {
                object in
                var evidence = try XCTUnwrap(
                    object[
                        "external_child_capture_evidence"
                    ] as? [String: Any]
                )
                var queries = try XCTUnwrap(
                    evidence[
                        "all_mapped_region_queries"
                    ] as? [[String: Any]]
                )
                queries[1]["query_address"] =
                    0x2_001
                evidence[
                    "all_mapped_region_queries"
                ] = queries
                object[
                    "external_child_capture_evidence"
                ] = evidence
            }
        XCTAssertThrowsError(
            try validateVerifierCapture(
                nonprogressingEnumerationCapture,
                useMatchingTrustedEvidence: true
            )
        )
        let mismatchedWaitPIDCapture =
            try mutatedVerifierCaptureObject {
                object in
                var evidence = try XCTUnwrap(
                    object[
                        "external_child_capture_evidence"
                    ] as? [String: Any]
                )
                var wait = try XCTUnwrap(
                    evidence[
                        "exact_pid_wait_observation"
                    ] as? [String: Any]
                )
                wait[
                    "returned_process_identifier"
                ] = 9_999
                evidence[
                    "exact_pid_wait_observation"
                ] = wait
                object[
                    "external_child_capture_evidence"
                ] = evidence
            }
        XCTAssertThrowsError(
            try validateVerifierCapture(
                mismatchedWaitPIDCapture,
                useMatchingTrustedEvidence: true
            )
        )
        let nonzeroRawWaitStatusCapture =
            try mutatedVerifierCaptureObject {
                object in
                var evidence = try XCTUnwrap(
                    object[
                        "external_child_capture_evidence"
                    ] as? [String: Any]
                )
                var wait = try XCTUnwrap(
                    evidence[
                        "exact_pid_wait_observation"
                    ] as? [String: Any]
                )
                wait["raw_wait_status"] = 256
                evidence[
                    "exact_pid_wait_observation"
                ] = wait
                object[
                    "external_child_capture_evidence"
                ] = evidence
            }
        XCTAssertThrowsError(
            try validateVerifierCapture(
                nonzeroRawWaitStatusCapture,
                useMatchingTrustedEvidence: true
            )
        )
        for unsafeDescriptorField in [
            "regular_file",
            "opened_with_no_symbolic_links_in_path",
            "close_on_exec",
        ] {
            let unsafeDescriptorCapture =
                try mutatedVerifierCaptureObject {
                    object in
                    var evidence =
                        try XCTUnwrap(
                            object[
                                "external_child_capture_evidence"
                            ] as? [String: Any]
                        )
                    for key in [
                        "pre_spawn_descriptor",
                        "pre_resume_descriptor",
                        "post_reap_descriptor",
                    ] {
                        var descriptor =
                            try XCTUnwrap(
                                evidence[key]
                                    as? [String: Any]
                            )
                        descriptor[
                            unsafeDescriptorField
                        ] = false
                        evidence[key] = descriptor
                    }
                    object[
                        "external_child_capture_evidence"
                    ] = evidence
                }
            XCTAssertThrowsError(
                try validateVerifierCapture(
                    unsafeDescriptorCapture,
                    useMatchingTrustedEvidence:
                        true
                )
            )
        }
        let unstableDescriptorCapture =
            try mutatedVerifierCaptureObject {
                object in
                var evidence = try XCTUnwrap(
                    object[
                        "external_child_capture_evidence"
                    ] as? [String: Any]
                )
                var descriptor = try XCTUnwrap(
                    evidence[
                        "pre_resume_descriptor"
                    ] as? [String: Any]
                )
                descriptor["sha256"] =
                    String(repeating: "a", count: 64)
                evidence[
                    "pre_resume_descriptor"
                ] = descriptor
                object[
                    "external_child_capture_evidence"
                ] = evidence
            }
        XCTAssertThrowsError(
            try validateVerifierCapture(
                unstableDescriptorCapture,
                useMatchingTrustedEvidence: true
            )
        )
        let noHeaderRegionCapture =
            try mutatedVerifierCaptureObject {
                object in
                var evidence = try XCTUnwrap(
                    object[
                        "external_child_capture_evidence"
                    ] as? [String: Any]
                )
                var regions = try XCTUnwrap(
                    evidence[
                        "matching_mapped_regions"
                    ] as? [[String: Any]]
                )
                for index in regions.indices {
                    regions[index]["file_offset"] =
                        4_096 * (index + 1)
                }
                evidence[
                    "matching_mapped_regions"
                ] = regions
                object[
                    "external_child_capture_evidence"
                ] = evidence
            }
        XCTAssertThrowsError(
            try validateVerifierCapture(
                noHeaderRegionCapture,
                useMatchingTrustedEvidence: true
            )
        )
        let coordinatedExecutableSubstitution =
            try mutatedVerifierCaptureObject {
                object in
                let replacementSHA =
                    String(repeating: "b", count: 64)
                object[
                    "swift_package_executable_absolute_path"
                ] = "/tmp/swift-package"
                object[
                    "mapped_child_main_image_absolute_path"
                ] = "/tmp/swift-package"
                object[
                    "swift_package_executable_sha256"
                ] = replacementSHA
                object[
                    "mapped_child_main_image_sha256"
                ] = replacementSHA
                var evidence = try XCTUnwrap(
                    object[
                        "external_child_capture_evidence"
                    ] as? [String: Any]
                )
                for key in [
                    "pre_spawn_descriptor",
                    "pre_resume_descriptor",
                    "post_reap_descriptor",
                ] {
                    var descriptor =
                        try XCTUnwrap(
                            evidence[key]
                                as? [String: Any]
                        )
                    descriptor["sha256"] =
                        replacementSHA
                    evidence[key] = descriptor
                }
                object[
                    "external_child_capture_evidence"
                ] = evidence
            }
        XCTAssertThrowsError(
            try validateVerifierCapture(
                coordinatedExecutableSubstitution,
                useMatchingTrustedEvidence: true
            )
        )
        let pathOnlyExecutableSubstitution =
            try mutatedVerifierCaptureObject {
                object in
                object[
                    "swift_package_executable_absolute_path"
                ] = "/tmp/swift-package"
                object[
                    "mapped_child_main_image_absolute_path"
                ] = "/tmp/swift-package"
            }
        XCTAssertThrowsError(
            try validateVerifierCapture(
                pathOnlyExecutableSubstitution
            )
        )
        let mismatchedMappedVnodeCapture =
            PrimeNativeNeuralGateSwiftPackageDescribeCaptureRecord(
                role: .verifier,
                planSHA256: planSHA,
                supervisorProcessIdentifier: 302,
                childProcessIdentifier: 1_302,
                swiftPackageExecutableAbsolutePath:
                    "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-package",
                mappedChildMainImageAbsolutePath:
                    "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-package",
                workingDirectoryAbsolutePath:
                    "/private/tmp/ergentics-prime",
                externalChildCaptureEvidence:
                    externalChildCaptureEvidence(
                        contract: contract,
                        supervisorProcessIdentifier:
                            302,
                        childProcessIdentifier:
                            1_302,
                        descriptorDeviceID: 8,
                        descriptorInode: 11,
                        mappedDeviceID: 7,
                        mappedInode: 11
                    ),
                standardOutput:
                    fixture
                    .swiftPackageDescribeBinding,
                prePrimeSourceState: sourceState,
                postPrimeSourceState: sourceState,
                primeSourceSnapshot:
                    fixture.snapshotBinding,
                packageManifest:
                    fixture.closure.packageManifest,
                contract: contract
            )
        XCTAssertThrowsError(
            try mismatchedMappedVnodeCapture
                .validateForRunningRelease(
                    against: contract,
                    trustedExternalChildCapture:
                        try trustedExternalChildCapture(
                            evidence:
                                mismatchedMappedVnodeCapture
                                .externalChildCaptureEvidence,
                            role: .verifier,
                            standardOutputData:
                                fixture
                                .swiftPackageDescribeData
                        ),
                    expectedPlanSHA256: planSHA,
                    expectedSupervisorProcessIdentifier:
                        302,
                    expectedPrimeSourceState:
                        sourceState,
                    expectedPrimeSourceSnapshot:
                        fixture.snapshotBinding,
                    expectedPackageManifest:
                        fixture
                        .closure.packageManifest,
                    expectedStandardOutput:
                        fixture
                        .swiftPackageDescribeBinding,
                    standardOutputData:
                        fixture
                        .swiftPackageDescribeData
                )
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateSwiftPackageDescribeCaptureRecord
                .validateProbeVerifierPairOfPrevalidatedRecords(
                    probe: probeDescribeCapture,
                    verifier:
                        mismatchedMappedVnodeCapture
                )
        )
        let relabeledVerifierCapture =
            try mutatedVerifierCaptureObject {
                object in
                object["role"] =
                    PrimeNativeNeuralGateReleaseProcessRole
                    .probe.rawValue
                object["record_relative_path"] =
                    contract
                    .swiftPackageDescribeCaptureRecordRelativePath(
                        for: .probe
                    )
            }
        let relabeledVerifierCaptureBinding =
            try relabeledVerifierCapture
            .artifactBinding()
        let relabeledVerifierProcess =
            PrimeNativeNeuralGateReleaseProcessBindingRecord(
                recordRelativePath:
                    verifier.recordRelativePath,
                planSHA256:
                    verifier.planSHA256,
                role: verifier.role,
                processIdentifier:
                    verifier.processIdentifier,
                executableTargetName:
                    verifier.executableTargetName,
                exactTransitiveLocalTargetNames:
                    verifier
                    .exactTransitiveLocalTargetNames,
                prePrimeSourceState:
                    verifier.prePrimeSourceState,
                postPrimeSourceState:
                    verifier.postPrimeSourceState,
                preSourceSnapshotSHA256:
                    verifier
                    .preSourceSnapshotSHA256,
                postSourceSnapshotSHA256:
                    verifier
                    .postSourceSnapshotSHA256,
                primeSourceSnapshot:
                    verifier.primeSourceSnapshot,
                compiledSourceClosure:
                    verifier.compiledSourceClosure,
                swiftPackageDescribeCapture:
                    relabeledVerifierCaptureBinding,
                sourceIdentitySHA256:
                    verifier.sourceIdentitySHA256,
                embeddedSourceIdentitySHA256:
                    verifier
                    .embeddedSourceIdentitySHA256,
                buildConfiguration:
                    verifier.buildConfiguration,
                runningExecutable:
                    verifier.runningExecutable
            )
        let relabeledVerifierTrustedCapture =
            try trustedExternalChildCapture(
                evidence:
                    relabeledVerifierCapture
                    .externalChildCaptureEvidence,
                role: .probe,
                standardOutputData:
                    fixture
                    .swiftPackageDescribeData,
                swiftPackageExecutableAbsolutePath:
                    relabeledVerifierCapture
                    .swiftPackageExecutableAbsolutePath,
                mappedChildMainImageAbsolutePath:
                    relabeledVerifierCapture
                    .mappedChildMainImageAbsolutePath,
                workingDirectoryAbsolutePath:
                    relabeledVerifierCapture
                    .workingDirectoryAbsolutePath
            )
        XCTAssertThrowsError(
            try relabeledVerifierProcess.validate(
                against: contract,
                trustedExternalChildCapture:
                    relabeledVerifierTrustedCapture,
                expectedPlanSHA256: planSHA,
                closure: fixture.closure,
                closureBinding:
                    fixture.closureBinding,
                describeCapture:
                    relabeledVerifierCapture,
                describeCaptureBinding:
                    relabeledVerifierCaptureBinding,
                snapshot: fixture.snapshot,
                swiftPackageDescribeData:
                    fixture
                    .swiftPackageDescribeData,
                capturedRunningExecutableData:
                    verifierData,
                expectedEmbeddedSourceIdentitySHA256:
                    fixture.sourceIdentity,
                expectedBuildConfiguration:
                    "release"
            )
        )
        XCTAssertNoThrow(
            try PrimeNativeNeuralGateReleaseProcessBindingRecord
                .validateProbeVerifierPairOfPrevalidatedRecords(
                    probe: probe,
                    verifier: verifier
                )
        )
        let samePIDVerifier =
            PrimeNativeNeuralGateReleaseProcessBindingRecord(
                recordRelativePath:
                    verifier.recordRelativePath,
                planSHA256:
                    verifier.planSHA256,
                role: verifier.role,
                processIdentifier:
                    probe.processIdentifier,
                executableTargetName:
                    verifier.executableTargetName,
                exactTransitiveLocalTargetNames:
                    verifier
                    .exactTransitiveLocalTargetNames,
                prePrimeSourceState:
                    verifier.prePrimeSourceState,
                postPrimeSourceState:
                    verifier.postPrimeSourceState,
                preSourceSnapshotSHA256:
                    verifier
                    .preSourceSnapshotSHA256,
                postSourceSnapshotSHA256:
                    verifier
                    .postSourceSnapshotSHA256,
                primeSourceSnapshot:
                    verifier.primeSourceSnapshot,
                compiledSourceClosure:
                    verifier.compiledSourceClosure,
                swiftPackageDescribeCapture:
                    verifier
                    .swiftPackageDescribeCapture,
                sourceIdentitySHA256:
                    verifier.sourceIdentitySHA256,
                embeddedSourceIdentitySHA256:
                    verifier
                    .embeddedSourceIdentitySHA256,
                buildConfiguration:
                    verifier.buildConfiguration,
                runningExecutable:
                    verifier.runningExecutable
            )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateReleaseProcessBindingRecord
                .validateProbeVerifierPairOfPrevalidatedRecords(
                    probe: probe,
                    verifier: samePIDVerifier
                )
        )
    }

    func testHistoricalWorkerContainmentIsTypedAndRoleSeparated()
        throws
    {
        let plan = Plan.frozenV1
        let contract = plan.historicalWorker

        XCTAssertNoThrow(
            try contract.validate(
                adaptationProof:
                    plan.adaptationProof,
                sourceExecutionBinding:
                    plan.sourceExecutionBinding
            )
        )
        XCTAssertEqual(
            contract.exactCLIArgumentNames,
            [
                "--artifact-root",
                "--invocation-role",
                "--request-sha256",
            ]
        )
        XCTAssertEqual(
            contract.maximumWallSeconds,
            600
        )
        XCTAssertEqual(
            contract.maximumStandardOutputBytes,
            1_048_576
        )
        XCTAssertEqual(
            contract.maximumStandardErrorBytes,
            1_048_576
        )
        XCTAssertTrue(
            contract
                .trapBearingFixtureRemainsInWorker
        )
        XCTAssertTrue(
            contract.workerOwnsCompleteHistoricalArm
        )
        XCTAssertFalse(
            contract.fixtureCodableTransportPermitted
        )
        XCTAssertFalse(
            contract.stdoutEvidenceTransportPermitted
        )
        XCTAssertFalse(
            contract.poisonedRootRetryPermitted
        )
        XCTAssertEqual(
            contract
                .abnormalTerminationInternalDisposition,
            .abstain
        )
        XCTAssertEqual(
            contract
                .abnormalTerminationPublicationPolicy,
            "poison_root_accept_no_worker_result_as_evidence_publish_no_successful_execution_record_publish_no_terminal_receipt_no_retry_v1"
        )
        XCTAssertEqual(
            contract
                .supervisorOwnedFixedOutputLeafPaths,
            [
                "worker-request.v1.json",
                "worker-execution.v1.json",
            ]
        )
        XCTAssertFalse(
            contract
                .workerResultCanEstablishMechanicsPass
        )
        XCTAssertTrue(
            contract
                .terminalVerifierMustDecodeAndRecomputeEveryWorkerArtifact
        )
        XCTAssertTrue(
            contract
                .workerDeathObservedBeforeContinuationRequired
        )
        XCTAssertTrue(
            contract
                .workerReapBeforeContinuationRequired
        )
        XCTAssertTrue(
            contract
                .preLaunchAndPostExitDescriptorEnumerationRequired
        )

        let planSHA =
            String(repeating: "a", count: 64)
        let sourceSnapshot = binding(
            "neural-gate-replay/source/prime-swift-source-snapshot.v1.json",
            payload: "snapshot"
        )
        let sourceClosure = binding(
            "neural-gate-replay/source/compiled-target-source-closure.v1.json",
            payload: "closure"
        )
        let packageLock = binding(
            "neural-gate-replay/source/blobs/11.blob",
            payload: "package-lock"
        )
        let workerExecutable = binding(
            contract.executableRelativePath,
            payload: "sealed-worker",
            purpose: .executable
        )
        let sourceIdentity =
            String(repeating: "b", count: 64)

        func request(
            _ role:
                PrimeNativeNeuralGateHistoricalWorkerInvocationRole
        ) throws -> (
            PrimeNativeNeuralGateHistoricalWorkerRequest,
            PrimeArtifactBinding
        ) {
            let value =
                PrimeNativeNeuralGateHistoricalWorkerRequest(
                    invocationRole: role,
                    planSHA256: planSHA,
                    primeSourceSnapshot:
                        sourceSnapshot,
                    compiledSourceClosure:
                        sourceClosure,
                    embeddedSourceIdentitySHA256:
                        sourceIdentity,
                    copiedPackageLock:
                        packageLock,
                    sealedWorkerExecutable:
                        workerExecutable,
                    workerContract: contract
                )
            try value.validate(
                against: contract,
                expectedPlanSHA256: planSHA,
                expectedSourceSnapshot:
                    sourceSnapshot,
                expectedCompiledSourceClosure:
                    sourceClosure,
                expectedEmbeddedSourceIdentitySHA256:
                    sourceIdentity,
                expectedCopiedPackageLock:
                    packageLock,
                expectedWorkerExecutable:
                    workerExecutable
            )
            return (
                value,
                try value.artifactBinding(
                    contract: contract
                )
            )
        }

        func result(
            role:
                PrimeNativeNeuralGateHistoricalWorkerInvocationRole,
            workerPID: Int32,
            request:
                PrimeNativeNeuralGateHistoricalWorkerRequest,
            requestBinding:
                PrimeArtifactBinding
        ) throws -> (
            PrimeNativeNeuralGateHistoricalWorkerResult,
            PrimeArtifactBinding,
            PrimeNativeNeuralGateHistoricalWorkerProcessBindingRecord,
            PrimeArtifactBinding
        ) {
            let prefix =
                contract.outputPrefix(for: role)
            let workerProcess =
                PrimeNativeNeuralGateHistoricalWorkerProcessBindingRecord(
                    invocationRole: role,
                    planSHA256: planSHA,
                    processIdentifier:
                        workerPID,
                    exactTransitiveLocalTargetNames: [
                        "PrimeCore",
                        "PrimeNativeCorpusReplayMechanics",
                        "PrimeNativeCorpusReplay",
                        "PrimeNativeNeuralGateContract",
                        "ErgenticsPrimeRuntime",
                        "PrimeNativeNeuralGateReplayMechanics",
                        "PrimeNativeNeuralGateReplay",
                        "PrimeNativeNeuralGateHistoricalFixtureWorker",
                    ],
                    primeSourceSnapshot:
                        sourceSnapshot,
                    compiledSourceClosure:
                        sourceClosure,
                    sourceIdentitySHA256:
                        sourceIdentity,
                    embeddedSourceIdentitySHA256:
                        sourceIdentity,
                    buildConfiguration:
                        "release",
                    sealedWorkerExecutable:
                        workerExecutable,
                    runningWorkerExecutable:
                        workerExecutable,
                    workerContract: contract
                )
            let workerProcessBinding =
                try workerProcess.artifactBinding()
            let value =
                PrimeNativeNeuralGateHistoricalWorkerResult(
                    invocationRole: role,
                    workerProcessIdentifier:
                        workerPID,
                    request: requestBinding,
                    workerProcessBinding:
                        workerProcessBinding,
                    runningWorkerExecutable:
                        workerExecutable,
                    primeSourceSnapshot:
                        sourceSnapshot,
                    compiledSourceClosure:
                        sourceClosure,
                    embeddedSourceIdentitySHA256:
                        sourceIdentity,
                    copiedPackageLock:
                        packageLock,
                    materialIdentityManifest:
                        binding(
                            prefix
                                + "/material-identity-manifest.v1.json",
                            payload: "material"
                        ),
                    gateObservation:
                        binding(
                            prefix
                                + "/gate-observation.v1.json",
                            payload: "gate"
                        ),
                    invariantRecordManifest:
                        binding(
                            prefix
                                + "/invariant-records-manifest.v1.json",
                            payload: "manifest"
                        ),
                    invariantGlobalStream:
                        binding(
                            prefix
                                + "/invariant-records.v1.bin",
                            payload: "records"
                        ),
                    orderedInvariantChunks: [
                        binding(
                            prefix
                                + "/invariant-chunks/00000000.v1.bin",
                            payload: "chunk"
                        ),
                    ],
                    fingerprintObservation:
                        binding(
                            prefix
                                + "/fingerprint-observation.v1.json",
                            payload: "fingerprint"
                        ),
                    mutationObservations:
                        binding(
                            prefix
                                + "/mutation-observations.v1.json",
                            payload: "mutations"
                        ),
                    statisticsVerdictObservation:
                        binding(
                            prefix
                                + "/statistics-verdict-observation.v1.json",
                            payload: "statistics"
                        ),
                    fixtureDurationNanoseconds:
                        1_000,
                    gateDurationNanoseconds:
                        2_000,
                    historicalMechanicsDisposition:
                        .pass
                )
            try value
                .validateAgainstPrevalidatedWorkerProcess(
                    request: request,
                    requestBinding: requestBinding,
                    workerProcess: workerProcess,
                    workerProcessBinding:
                        workerProcessBinding,
                    contract: contract
                )
            return (
                value,
                try value.artifactBinding(
                    contract: contract
                ),
                workerProcess,
                workerProcessBinding
            )
        }

        let (probeRequest, probeRequestBinding) =
            try request(.probe)
        let (
            verifierRequest,
            verifierRequestBinding
        ) = try request(.verifier)
        let (
            probeResult,
            probeResultBinding,
            probeWorkerProcess,
            probeWorkerProcessBinding
        ) =
            try result(
                role: .probe,
                workerPID: 102,
                request: probeRequest,
                requestBinding:
                    probeRequestBinding
            )
        let (
            verifierResult,
            verifierResultBinding,
            verifierWorkerProcess,
            _
        ) = try result(
            role: .verifier,
            workerPID: 202,
            request: verifierRequest,
            requestBinding:
                verifierRequestBinding
        )
        XCTAssertEqual(
            probeResult
                .historicalMechanicsDisposition,
            .pass
        )
        XCTAssertFalse(
            probeResult
                .mechanicsDispositionAuthoritative
        )
        XCTAssertTrue(
            plan.requiredTrueClaims.contains(
                .historicalWorkerArtifactsDecodedAndRecomputed
            )
        )
        XCTAssertTrue(
            plan.requiredTrueClaims.contains(
                .exactPreReceiptRealizedPathAndMetadataInventoryValidated
            )
        )
        XCTAssertTrue(
            plan.requiredTrueClaims.contains(
                .allPreReceiptArtifactContentValidatedByTypedContracts
            )
        )
        XCTAssertNotEqual(
            PrimeNativeNeuralGateReplayClaim
                .exactPreReceiptRealizedPathAndMetadataInventoryValidated
                .rawValue,
            PrimeNativeNeuralGateReplayClaim
                .allPreReceiptArtifactContentValidatedByTypedContracts
                .rawValue
        )

        func execution(
            role:
                PrimeNativeNeuralGateHistoricalWorkerInvocationRole,
            supervisorPID: Int32,
            request:
                PrimeNativeNeuralGateHistoricalWorkerRequest,
            result:
                PrimeNativeNeuralGateHistoricalWorkerResult,
            resultBinding:
                PrimeArtifactBinding,
            requestBinding:
                PrimeArtifactBinding
        ) throws
            -> PrimeNativeNeuralGateHistoricalWorkerSuccessfulExecutionRecord
        {
            func observed(
                _ artifact: PrimeArtifactBinding
            ) -> PrimeNativeNeuralGateRealizedOutputEntry {
                .init(
                    artifact: artifact,
                    posixMode: "0444",
                    fileType: "regular_file",
                    linkCount: 1,
                    ownerMatchesCurrentEffectiveUser:
                        true,
                    capturedFromDescriptor: true
                )
            }
            func inventory(
                _ artifacts:
                    [PrimeArtifactBinding]
            ) -> PrimeNativeNeuralGateRealizedFilesystemInventory {
                let fileEntries =
                    artifacts.map(observed)
                    .sorted {
                        $0.artifact.relativePath
                            < $1.artifact.relativePath
                    }
                let root =
                    contract.outputPrefix(
                        for: role
                    )
                let directories =
                    PrimeNativeNeuralGateRealizedFilesystemInventory
                    .requiredDirectoryRelativePaths(
                        forFileRelativePaths:
                            fileEntries.map {
                                $0.artifact
                                    .relativePath
                            },
                        excludingRootRelativePath:
                            root
                    )
                    .map {
                        PrimeNativeNeuralGateRealizedDirectoryEntry(
                            relativePath: $0,
                            posixMode: "0700",
                            ownerMatchesCurrentEffectiveUser:
                                true,
                            capturedFromDescriptor:
                                true
                        )
                    }
                return .init(
                    rootRelativePath: root,
                    directoryEntries:
                        directories,
                    fileEntries: fileEntries,
                    unsupportedNodeRelativePaths:
                        [],
                    enumerationIncludesAllNodeTypes:
                        true,
                    symbolicLinksFollowed:
                        false
                )
            }
            let workerArtifacts =
                (
                    result
                        .preResultProducedArtifactInventory
                    + [resultBinding]
                ).sorted {
                    $0.relativePath < $1.relativePath
                }
            let value =
                PrimeNativeNeuralGateHistoricalWorkerSuccessfulExecutionRecord(
                    supervisorRole: role,
                    supervisorProcessIdentifier:
                        supervisorPID,
                    workerProcessIdentifier:
                        result
                        .workerProcessIdentifier,
                    sealedWorkerExecutable:
                        workerExecutable,
                    request: requestBinding,
                    workerResult:
                        resultBinding,
                    observedMonotonicWallNanoseconds:
                        3_000,
                    standardOutput:
                        .emptyDrained,
                    standardError:
                        .emptyDrained,
                    termination:
                        .cleanExitZero,
                    workerTerminationObserved:
                        true,
                    workerReaped: true,
                    preLaunchRolePrefixInventory:
                        inventory([
                            requestBinding,
                        ]),
                    postExitRolePrefixInventory:
                        inventory(
                            [requestBinding]
                                + workerArtifacts
                        ),
                    contract: contract
                )
            try value
                .validateSuccessfulAgainstPrevalidatedRequestAndResult(
                    request: request,
                    result: result,
                    resultBinding: resultBinding,
                    requestBinding: requestBinding,
                    contract: contract
                )
            return value
        }

        let probeExecution = try execution(
            role: .probe,
            supervisorPID: 101,
            request: probeRequest,
            result: probeResult,
            resultBinding: probeResultBinding,
            requestBinding: probeRequestBinding
        )
        let verifierExecution = try execution(
            role: .verifier,
            supervisorPID: 201,
            request: verifierRequest,
            result: verifierResult,
            resultBinding:
                verifierResultBinding,
            requestBinding:
                verifierRequestBinding
        )
        XCTAssertNoThrow(
            try PrimeNativeNeuralGateHistoricalWorkerSuccessfulExecutionRecord
                .validateRoleNeutralTransportPair(
                    probeExecution:
                        probeExecution,
                    probeResult: probeResult,
                    verifierExecution:
                        verifierExecution,
                    verifierResult:
                        verifierResult,
                    contract: contract
                )
        )
        let forgedRequestBinding = binding(
            contract.requestRelativePath(
                for: .probe
            ),
            payload: "forged-request"
        )
        let encodedForgedRequestBinding =
            try PrimeCanonicalJSON.encode(
                forgedRequestBinding
            )
        let forgedRequestObject =
            try XCTUnwrap(
                try JSONSerialization.jsonObject(
                    with:
                        encodedForgedRequestBinding
                ) as? [String: Any]
            )
        let encodedProbeResult =
            try PrimeCanonicalJSON.encode(
                probeResult
            )
        var forgedProbeResultObject =
            try XCTUnwrap(
                try JSONSerialization.jsonObject(
                    with: encodedProbeResult
                ) as? [String: Any]
            )
        forgedProbeResultObject["request"] =
            forgedRequestObject
        let forgedProbeResultData =
            try JSONSerialization.data(
                withJSONObject:
                    forgedProbeResultObject,
                options: [
                    .sortedKeys,
                    .withoutEscapingSlashes,
                ]
            )
        let forgedProbeResult =
            try JSONDecoder().decode(
                PrimeNativeNeuralGateHistoricalWorkerResult
                    .self,
                from: forgedProbeResultData
            )
        XCTAssertThrowsError(
            try forgedProbeResult
                .validateAgainstPrevalidatedWorkerProcess(
                    request: probeRequest,
                    requestBinding:
                        forgedRequestBinding,
                    workerProcess:
                        probeWorkerProcess,
                    workerProcessBinding:
                        probeWorkerProcessBinding,
                    contract: contract
                )
        )
        let forgedProbeResultBinding =
            try forgedProbeResult.artifactBinding(
                contract: contract
            )
        XCTAssertThrowsError(
            try execution(
                role: .probe,
                supervisorPID: 101,
                request: probeRequest,
                result: forgedProbeResult,
                resultBinding:
                    forgedProbeResultBinding,
                requestBinding:
                    forgedRequestBinding
            )
        )

        let encodedWorkerContract =
            try PrimeCanonicalJSON.encode(
                contract
            )
        var mutatedWorkerContractObject =
            try XCTUnwrap(
                try JSONSerialization.jsonObject(
                    with: encodedWorkerContract
                ) as? [String: Any]
            )
        mutatedWorkerContractObject[
            "maximum_result_bytes"
        ] = 2_097_152
        let mutatedWorkerContractData =
            try JSONSerialization.data(
                withJSONObject:
                    mutatedWorkerContractObject,
                options: [
                    .sortedKeys,
                    .withoutEscapingSlashes,
                ]
            )
        let mutatedWorkerContract =
            try JSONDecoder().decode(
                PrimeNativeNeuralGateHistoricalWorkerContract
                    .self,
                from: mutatedWorkerContractData
            )
        XCTAssertThrowsError(
            try mutatedWorkerContract.validate(
                adaptationProof:
                    plan.adaptationProof,
                sourceExecutionBinding:
                    plan.sourceExecutionBinding
            )
        )
        XCTAssertThrowsError(
            try probeRequest.validate(
                against: mutatedWorkerContract,
                expectedPlanSHA256: planSHA,
                expectedSourceSnapshot:
                    sourceSnapshot,
                expectedCompiledSourceClosure:
                    sourceClosure,
                expectedEmbeddedSourceIdentitySHA256:
                    sourceIdentity,
                expectedCopiedPackageLock:
                    packageLock,
                expectedWorkerExecutable:
                    workerExecutable
            )
        )
        XCTAssertThrowsError(
            try probeResult
                .validateAgainstPrevalidatedWorkerProcess(
                    request: probeRequest,
                    requestBinding:
                        probeRequestBinding,
                    workerProcess:
                        probeWorkerProcess,
                    workerProcessBinding:
                        probeWorkerProcessBinding,
                    contract:
                        mutatedWorkerContract
                )
        )
        XCTAssertThrowsError(
            try probeExecution
                .validateSuccessfulAgainstPrevalidatedRequestAndResult(
                    request: probeRequest,
                    result: probeResult,
                    resultBinding:
                        probeResultBinding,
                    requestBinding:
                        probeRequestBinding,
                    contract:
                        mutatedWorkerContract
                )
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateHistoricalWorkerSuccessfulExecutionRecord
                .validateRoleNeutralTransportPair(
                    probeExecution:
                        probeExecution,
                    probeResult: probeResult,
                    verifierExecution:
                        verifierExecution,
                    verifierResult:
                        verifierResult,
                    contract:
                        mutatedWorkerContract
                )
        )
        let alternateProbeResult =
            PrimeNativeNeuralGateHistoricalWorkerResult(
                invocationRole:
                    probeResult.invocationRole,
                workerProcessIdentifier:
                    probeResult
                    .workerProcessIdentifier,
                request: probeResult.request,
                workerProcessBinding:
                    probeResult
                    .workerProcessBinding,
                runningWorkerExecutable:
                    probeResult
                    .runningWorkerExecutable,
                primeSourceSnapshot:
                    probeResult
                    .primeSourceSnapshot,
                compiledSourceClosure:
                    probeResult
                    .compiledSourceClosure,
                embeddedSourceIdentitySHA256:
                    probeResult
                    .embeddedSourceIdentitySHA256,
                copiedPackageLock:
                    probeResult
                    .copiedPackageLock,
                materialIdentityManifest:
                    probeResult
                    .materialIdentityManifest,
                gateObservation:
                    probeResult.gateObservation,
                invariantRecordManifest:
                    probeResult
                    .invariantRecordManifest,
                invariantGlobalStream:
                    probeResult
                    .invariantGlobalStream,
                orderedInvariantChunks:
                    probeResult
                    .orderedInvariantChunks,
                fingerprintObservation:
                    probeResult
                    .fingerprintObservation,
                mutationObservations:
                    probeResult
                    .mutationObservations,
                statisticsVerdictObservation:
                    probeResult
                    .statisticsVerdictObservation,
                fixtureDurationNanoseconds:
                    probeResult
                        .fixtureDurationNanoseconds
                        + 1,
                gateDurationNanoseconds:
                    probeResult
                    .gateDurationNanoseconds,
                historicalMechanicsDisposition:
                    probeResult
                    .historicalMechanicsDisposition
            )
        XCTAssertNoThrow(
            try alternateProbeResult
                .validateAgainstPrevalidatedWorkerProcess(
                    request: probeRequest,
                    requestBinding:
                        probeRequestBinding,
                    workerProcess:
                        probeWorkerProcess,
                    workerProcessBinding:
                        probeWorkerProcessBinding,
                    contract: contract
                )
        )
        XCTAssertThrowsError(
            try probeExecution
                .validateSuccessfulAgainstPrevalidatedRequestAndResult(
                    request: probeRequest,
                    result: alternateProbeResult,
                    resultBinding:
                        probeResultBinding,
                    requestBinding:
                        probeRequestBinding,
                    contract: contract
                )
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateHistoricalWorkerSuccessfulExecutionRecord
                .validateRoleNeutralTransportPair(
                    probeExecution:
                        probeExecution,
                    probeResult:
                        alternateProbeResult,
                    verifierExecution:
                        verifierExecution,
                    verifierResult:
                        verifierResult,
                    contract: contract
                )
        )
        let primeState =
            PrimeNativeNeuralGatePrimeGitStateRecord(
                remoteURL:
                    "https://github.com/Ergentics/ergentics-prime.git",
                revision:
                    String(repeating: "1", count: 40),
                treeOID:
                    String(repeating: "2", count: 40),
                clean: true
            )
        let describeOutput = binding(
            plan.sourceExecutionBinding
                .swiftPackageDescribeRelativePath,
            payload: "described-package"
        )
        let packageManifest =
            PrimeNativeNeuralGateSourceFileIdentity(
                relativePath: "Package.swift",
                sha256:
                    String(
                        repeating: "c",
                        count: 64
                    ),
                byteCount: 1
            )
        func describeCapture(
            _ role:
                PrimeNativeNeuralGateReleaseProcessRole,
            supervisorPID: Int32,
            childPID: Int32
        ) -> PrimeNativeNeuralGateSwiftPackageDescribeCaptureRecord {
            PrimeNativeNeuralGateSwiftPackageDescribeCaptureRecord(
                role: role,
                planSHA256: planSHA,
                supervisorProcessIdentifier:
                    supervisorPID,
                childProcessIdentifier:
                    childPID,
                swiftPackageExecutableAbsolutePath:
                    "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-package",
                mappedChildMainImageAbsolutePath:
                    "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-package",
                workingDirectoryAbsolutePath:
                    "/private/tmp/ergentics-prime",
                externalChildCaptureEvidence:
                    externalChildCaptureEvidence(
                        contract:
                            plan
                            .sourceExecutionBinding,
                        supervisorProcessIdentifier:
                            supervisorPID,
                        childProcessIdentifier:
                            childPID
                    ),
                standardOutput:
                    describeOutput,
                prePrimeSourceState:
                    primeState,
                postPrimeSourceState:
                    primeState,
                primeSourceSnapshot:
                    sourceSnapshot,
                packageManifest:
                    packageManifest,
                contract:
                    plan.sourceExecutionBinding
            )
        }
        let probeDescribeCapture =
            describeCapture(
                .probe,
                supervisorPID: 101,
                childPID: 103
            )
        let verifierDescribeCapture =
            describeCapture(
                .verifier,
                supervisorPID: 201,
                childPID: 203
            )
        func supervisorProcess(
            _ role:
                PrimeNativeNeuralGateReleaseProcessRole,
            pid: Int32,
            describeCapture:
                PrimeNativeNeuralGateSwiftPackageDescribeCaptureRecord
        ) throws
            -> PrimeNativeNeuralGateReleaseProcessBindingRecord
        {
            let rule = try XCTUnwrap(
                plan.sourceExecutionBinding
                    .processBindingRules.first {
                        $0.role == role
                    }
            )
            return PrimeNativeNeuralGateReleaseProcessBindingRecord(
                recordRelativePath:
                    rule
                    .executableBindingRelativePath,
                planSHA256: planSHA,
                role: role,
                processIdentifier: pid,
                executableTargetName:
                    rule.executableTargetName,
                exactTransitiveLocalTargetNames:
                    rule
                    .exactTransitiveLocalTargetNames,
                prePrimeSourceState: primeState,
                postPrimeSourceState: primeState,
                preSourceSnapshotSHA256:
                    sourceSnapshot.sha256,
                postSourceSnapshotSHA256:
                    sourceSnapshot.sha256,
                primeSourceSnapshot:
                    sourceSnapshot,
                compiledSourceClosure:
                    sourceClosure,
                swiftPackageDescribeCapture:
                    try describeCapture
                    .artifactBinding(),
                sourceIdentitySHA256:
                    sourceIdentity,
                embeddedSourceIdentitySHA256:
                    sourceIdentity,
                buildConfiguration: "release",
                runningExecutable:
                    binding(
                        rule
                        .runningExecutableRelativePath,
                        payload:
                            "supervisor-\(role.rawValue)",
                        purpose: .executable
                    )
            )
        }
        let probeProcess =
            try supervisorProcess(
                .probe,
                pid: 101,
                describeCapture:
                    probeDescribeCapture
            )
        let verifierProcess =
            try supervisorProcess(
                .verifier,
                pid: 201,
                describeCapture:
                    verifierDescribeCapture
            )
        XCTAssertNoThrow(
            try PrimeNativeNeuralGateHistoricalWorkerSuccessfulExecutionRecord
                .validateCompleteProcessTopologyOfPrevalidatedRecords(
                    probeProcess: probeProcess,
                    probeDescribeCapture:
                        probeDescribeCapture,
                    probeWorkerProcess:
                        probeWorkerProcess,
                    probeExecution:
                        probeExecution,
                    probeResult: probeResult,
                    verifierProcess:
                        verifierProcess,
                    verifierDescribeCapture:
                        verifierDescribeCapture,
                    verifierWorkerProcess:
                        verifierWorkerProcess,
                    verifierExecution:
                        verifierExecution,
                    verifierResult:
                        verifierResult,
                    workerContract: contract
                )
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateHistoricalWorkerSuccessfulExecutionRecord
                .validateCompleteProcessTopologyOfPrevalidatedRecords(
                    probeProcess: probeProcess,
                    probeDescribeCapture:
                        probeDescribeCapture,
                    probeWorkerProcess:
                        probeWorkerProcess,
                    probeExecution:
                        probeExecution,
                    probeResult: probeResult,
                    verifierProcess:
                        verifierProcess,
                    verifierDescribeCapture:
                        verifierDescribeCapture,
                    verifierWorkerProcess:
                        verifierWorkerProcess,
                    verifierExecution:
                        verifierExecution,
                    verifierResult:
                        verifierResult,
                    workerContract:
                        mutatedWorkerContract
                )
        )
        let wrongSupervisorExecution =
            try execution(
                role: .probe,
                supervisorPID: 999,
                request: probeRequest,
                result: probeResult,
                resultBinding:
                    probeResultBinding,
                requestBinding:
                    probeRequestBinding
            )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateHistoricalWorkerSuccessfulExecutionRecord
                .validateCompleteProcessTopologyOfPrevalidatedRecords(
                    probeProcess: probeProcess,
                    probeDescribeCapture:
                        probeDescribeCapture,
                    probeWorkerProcess:
                        probeWorkerProcess,
                    probeExecution:
                        wrongSupervisorExecution,
                    probeResult: probeResult,
                    verifierProcess:
                        verifierProcess,
                    verifierDescribeCapture:
                        verifierDescribeCapture,
                    verifierWorkerProcess:
                        verifierWorkerProcess,
                    verifierExecution:
                        verifierExecution,
                    verifierResult:
                        verifierResult,
                    workerContract: contract
                )
        )

        let nonempty = Data("x".utf8)
        let invalidExecution =
            PrimeNativeNeuralGateHistoricalWorkerSuccessfulExecutionRecord(
                supervisorRole: .probe,
                supervisorProcessIdentifier:
                    101,
                workerProcessIdentifier: 102,
                sealedWorkerExecutable:
                    workerExecutable,
                request: probeRequestBinding,
                workerResult:
                    probeResultBinding,
                observedMonotonicWallNanoseconds:
                    3_000,
                standardOutput:
                    .init(
                        byteCount: 1,
                        sha256:
                            PrimeSHA256.hexDigest(
                                of: nonempty
                            ),
                        overflowed: false,
                        drainCompleted: true
                    ),
                standardError: .emptyDrained,
                termination: .cleanExitZero,
                workerTerminationObserved:
                    true,
                workerReaped: true,
                preLaunchRolePrefixInventory:
                    probeExecution
                    .preLaunchRolePrefixInventory,
                postExitRolePrefixInventory:
                    probeExecution
                    .postExitRolePrefixInventory,
                contract: contract
            )
        XCTAssertThrowsError(
            try invalidExecution
                .validateSuccessfulAgainstPrevalidatedRequestAndResult(
                    request: probeRequest,
                    result: probeResult,
                    resultBinding:
                        probeResultBinding,
                    requestBinding:
                        probeRequestBinding,
                    contract: contract
                )
        )

        func otherwiseValidExecution(
            termination:
                PrimeNativeNeuralGateHistoricalWorkerTerminationDisposition =
                    .cleanExitZero,
            workerTerminationObserved:
                Bool = true,
            workerReaped: Bool = true
        ) -> PrimeNativeNeuralGateHistoricalWorkerSuccessfulExecutionRecord {
            .init(
                supervisorRole: .probe,
                supervisorProcessIdentifier: 101,
                workerProcessIdentifier: 102,
                sealedWorkerExecutable:
                    workerExecutable,
                request: probeRequestBinding,
                workerResult:
                    probeResultBinding,
                observedMonotonicWallNanoseconds:
                    3_000,
                standardOutput: .emptyDrained,
                standardError: .emptyDrained,
                termination: termination,
                workerTerminationObserved:
                    workerTerminationObserved,
                workerReaped: workerReaped,
                preLaunchRolePrefixInventory:
                    probeExecution
                    .preLaunchRolePrefixInventory,
                postExitRolePrefixInventory:
                    probeExecution
                    .postExitRolePrefixInventory,
                contract: contract
            )
        }
        let abnormalTerminations:
            [PrimeNativeNeuralGateHistoricalWorkerTerminationDisposition] =
            [
                .nonzeroExit(status: 1),
                .signal(number: 9),
                .timedOutAfterEscalation,
                .launchFailure(
                    reasonSHA256:
                        String(
                            repeating: "f",
                            count: 64
                        )
                ),
                .outputDrainFailure,
                .outputOverflow,
            ]
        for termination in abnormalTerminations {
            XCTAssertThrowsError(
                try otherwiseValidExecution(
                    termination: termination
                ).validateSuccessfulAgainstPrevalidatedRequestAndResult(
                    request: probeRequest,
                    result: probeResult,
                    resultBinding:
                        probeResultBinding,
                    requestBinding:
                        probeRequestBinding,
                    contract: contract
                )
            )
        }
        XCTAssertThrowsError(
            try otherwiseValidExecution(
                workerTerminationObserved: false
            ).validateSuccessfulAgainstPrevalidatedRequestAndResult(
                request: probeRequest,
                result: probeResult,
                resultBinding:
                    probeResultBinding,
                requestBinding:
                    probeRequestBinding,
                contract: contract
            )
        )
        XCTAssertThrowsError(
            try otherwiseValidExecution(
                workerReaped: false
            ).validateSuccessfulAgainstPrevalidatedRequestAndResult(
                request: probeRequest,
                result: probeResult,
                resultBinding:
                    probeResultBinding,
                requestBinding:
                    probeRequestBinding,
                contract: contract
            )
        )
    }

    func testCheckoutModeNormalizationIsExactAndNonrecursive()
        throws
    {
        let plan = Plan.frozenV1

        XCTAssertEqual(
            plan.stageAParentModePins.count,
            5
        )
        XCTAssertEqual(
            plan.stageAParentModePins.map(
                \.relativePath
            ),
            [
                "neural-gate-contract/prime-native-neural-gate-contract-projection.v1.json",
                "neural-gate-contract/probe-candidate.v1.json",
                "neural-gate-contract/probe-observation.v1.json",
                "neural-gate-contract/verifier-observation.v1.json",
                "prime-native-neural-gate-contract-projection-receipt.v1.json",
            ]
        )
        XCTAssertEqual(
            plan.stageAParentModePins.map(
                \.byteCount
            ),
            [
                17_137,
                7_258,
                4_114,
                4_114,
                3_193,
            ]
        )
        XCTAssertEqual(
            plan.stageAParentModePins.map(
                \.sha256
            ),
            [
                "890d96d67267606048d3dfebb0bc29fe118c086d111b7b39de8501a6120bac48",
                "17319547d44b5ef6821c0cd69068586127b9831992b4c8d273fe50af0d6205b6",
                "09f72adf2e14ebd2c36572ed6d94ea35bdfda305a48d1f19dd868dcc83722a04",
                "09f72adf2e14ebd2c36572ed6d94ea35bdfda305a48d1f19dd868dcc83722a04",
                "2e523c459faca835a8d0b1b43a6d6f770923d451516f4477df2f18fd4f7b2aed",
            ]
        )
        XCTAssertTrue(
            plan.stageAParentModePins.allSatisfy {
                $0.requiredMode == "0444"
                    && $0.byteCount > 0
                    && $0.sha256.count == 64
            }
        )
        XCTAssertEqual(
            plan.modeNormalizationPolicy,
            "verify_current_user_single_link_regular_file_exact_bytes_and_sha256_then_chmod_only_listed_files_to_0444_never_recursive"
        )
    }

    func testContractOnlySliceAddsNoReplayTargetOrReceipt()
        throws
    {
        let package = try String(
            contentsOfFile: "Package.swift",
            encoding: .utf8
        )
        for forbiddenTarget in
            Plan.frozenV1.targetGraph.map(\.target)
        {
            XCTAssertFalse(
                package.contains(
                    #"name: "\#(forbiddenTarget)""#
                ),
                "contract-only slice implemented target: \(forbiddenTarget)"
            )
            XCTAssertFalse(
                FileManager.default.fileExists(
                    atPath: "Sources/\(forbiddenTarget)"
                )
            )
        }
    }

    func testFingerprintKnownAnswerPinsAreIndependentlyRecomputed()
        throws
    {
        let known =
            Plan.frozenV1.fingerprintReplay
            .knownAnswer
        let records =
            try known.inputRecordUTF8Hex.map(
                bytesFromHex
            )
        let canonical = records.sorted {
            $0.lexicographicallyPrecedes($1)
        }
        XCTAssertEqual(
            canonical.map {
                $0.map {
                    String(
                        format: "%02x",
                        $0
                    )
                }.joined()
            },
            known.canonicalRecordUTF8Hex
        )
        let global =
            framedGlobalStream(canonical)
        let chunk =
            framedChunk(
                ordinal: 0,
                records: canonical
            )
        let residues =
            directFingerprint(canonical)
        let accelerated =
            acceleratedFingerprint(canonical)

        XCTAssertEqual(
            residues,
            accelerated
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: global),
            known.globalStreamSHA256
        )
        XCTAssertEqual(
            global.count,
            known.globalStreamByteCount
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: chunk),
            known.firstChunkSHA256
        )
        XCTAssertEqual(
            chunk.count,
            known.firstChunkByteCount
        )
        XCTAssertEqual(
            residues,
            known.finiteFieldResidues
        )
        let production =
            try Plan.frozenV1.finiteField
            .fingerprint(
                records: [
                    "\u{00E9}",
                    "A",
                    "",
                    "e\u{0301}",
                    "A",
                ]
            )
        XCTAssertEqual(
            production.residues,
            known.finiteFieldResidues
        )
    }

    func testPlanMutationsFailClosed() throws {
        try assertMutationRejected { object in
            object["execution_implemented"] = true
        }
        try assertMutationRejected { object in
            object[
                "historical_summary_may_supply_expected_records_or_residues"
            ] = true
        }
        try assertMutationRejected { object in
            var pins = object["input_pins"]
                as! [[String: Any]]
            pins.removeLast()
            object["input_pins"] = pins
        }
        try assertMutationRejected { object in
            var pins = object["input_pins"]
                as! [[String: Any]]
            pins[0]["sha256"] =
                String(repeating: "0", count: 64)
            object["input_pins"] = pins
        }
        try assertMutationRejected { object in
            var arms = object["arms"]
                as! [[String: Any]]
            arms[0][
                "target_independence_eligible"
            ] = true
            object["arms"] = arms
        }
        try assertMutationRejected { object in
            var claims = object[
                "required_false_claims"
            ] as! [String]
            claims.removeAll {
                $0
                    == PrimeNativeNeuralGateReplayClaim
                    .historicalFixtureTargetIndependent
                    .rawValue
            }
            object["required_false_claims"] = claims
        }
        try assertMutationRejected { object in
            var executor = object[
                "corrected_executor"
            ] as! [String: Any]
            executor[
                "maximum_generation_token_decisions"
            ] = 63
            object["corrected_executor"] = executor
        }
        try assertMutationRejected { object in
            var root = object["root_policy"]
                as! [String: Any]
            root[
                "stage_a_artifact_disjoint"
            ] = false
            object["root_policy"] = root
        }
        try assertMutationRejected { object in
            var gate = object["gate_observation"]
                as! [String: Any]
            gate[
                "candidate_declared_aggregates_are_authority"
            ] = true
            object["gate_observation"] = gate
        }
        try assertMutationRejected { object in
            var proof = object["adaptation_proof"]
                as! [String: Any]
            proof[
                "behavioral_replay_may_replace_source_proof"
            ] = true
            object["adaptation_proof"] = proof
        }
        try assertMutationRejected { object in
            var proof = object["adaptation_proof"]
                as! [String: Any]
            var entries = proof["entries"]
                as! [[String: Any]]
            var derivation = entries[8]["derivation"]
                as! [String: Any]
            derivation[
                "expected_output_sha256"
            ] = String(repeating: "0", count: 64)
            entries[8]["derivation"] = derivation
            proof["entries"] = entries
            object["adaptation_proof"] = proof
        }
        try assertMutationRejected { object in
            var proof = object["adaptation_proof"]
                as! [String: Any]
            proof[
                "historical_fixture_wholly_fail_closed"
            ] = true
            object["adaptation_proof"] = proof
        }
        try assertMutationRejected { object in
            var binding = object[
                "source_execution_binding"
            ] as! [String: Any]
            binding[
                "required_build_configuration"
            ] = "debug"
            object[
                "source_execution_binding"
            ] = binding
        }
        try assertMutationRejected { object in
            var binding = object[
                "source_execution_binding"
            ] as! [String: Any]
            binding[
                "swift_package_describe_expected_executable_sha256"
            ] = String(repeating: "0", count: 64)
            object[
                "source_execution_binding"
            ] = binding
        }
        try assertMutationRejected { object in
            var binding = object[
                "source_execution_binding"
            ] as! [String: Any]
            binding[
                "swift_package_describe_capture_capability_calibration_policy"
            ] = "caller_asserted_v1"
            object[
                "source_execution_binding"
            ] = binding
        }
        try assertMutationRejected { object in
            var binding = object[
                "source_execution_binding"
            ] as! [String: Any]
            binding[
                "swift_package_describe_proc_pidpath_authoritative"
            ] = true
            object[
                "source_execution_binding"
            ] = binding
        }
        try assertMutationRejected { object in
            var binding = object[
                "source_execution_binding"
            ] as! [String: Any]
            binding[
                "swift_package_describe_trusted_capture_capability_required"
            ] = false
            object[
                "source_execution_binding"
            ] = binding
        }
        try assertMutationRejected { object in
            var output = object[
                "output_contract"
            ] as! [String: Any]
            output["ordinary_artifact_mode"] =
                "0644"
            object["output_contract"] = output
        }
        try assertMutationRejected { object in
            var output = object[
                "output_contract"
            ] as! [String: Any]
            output["running_executable_mode"] =
                "0444"
            object["output_contract"] = output
        }
        try assertMutationRejected { object in
            var output = object[
                "output_contract"
            ] as! [String: Any]
            output[
                "executable_binding_manifest_mode"
            ] = "0555"
            object["output_contract"] = output
        }
        try assertMutationRejected { object in
            var output = object[
                "output_contract"
            ] as! [String: Any]
            output[
                "stage_a_parent_reachable_descriptor_binding_count"
            ] = 36
            object["output_contract"] = output
        }
        try assertMutationRejected { object in
            var catalog = object[
                "corrected_mutation_catalog"
            ] as! [[String: Any]]
            catalog.removeLast()
            object[
                "corrected_mutation_catalog"
            ] = catalog
        }
    }

    private struct SyntheticSourceIdentityRecord:
        Codable
    {
        let relativePath: String
        let sha256: String
        let byteCount: UInt64

        private enum CodingKeys: String, CodingKey {
            case relativePath = "relative_path"
            case sha256
            case byteCount = "byte_count"
        }
    }

    private struct ObservedSourceClosureFixture {
        let snapshot: PrimeSwiftSourceSnapshot
        let snapshotBinding: PrimeArtifactBinding
        let swiftPackageDescribeData: Data
        let swiftPackageDescribeBinding:
            PrimeArtifactBinding
        let closure:
            PrimeNativeNeuralGateCompiledSourceClosureRecord
        let closureBinding: PrimeArtifactBinding
        let sourceIdentity: String
    }

    private func observedSourceClosureFixture()
        throws -> ObservedSourceClosureFixture
    {
        let contract =
            Plan.frozenV1.sourceExecutionBinding
        var dataByPath: [String: Data] = [
            ".gitignore": Data("build\n".utf8),
            ".swiftpm/configuration/mirrors.json":
                Data("{}".utf8),
            "Tests/PrimeTypedOptimizerRestoreMechanicsValidation/.swiftpm/configuration/mirrors.json":
                Data("{}".utf8),
            "LICENSE": Data("license\n".utf8),
            "Package.swift":
                Data("// swift-tools-version: 5.10\n".utf8),
            "Package.resolved": Data("{}".utf8),
            "README.md": Data("readme\n".utf8),
            "THIRD_PARTY_NOTICES.md":
                Data("notices\n".utf8),
        ]
        for rule in contract.targetClosureRules {
            dataByPath[
                rule.sourceDirectoryRelativePath
                    + "/ContractFixture.swift"
            ] = Data(
                "enum \(rule.targetName)ContractFixture {}\n"
                    .utf8
            )
        }
        var files = dataByPath.map {
            path, data in
            PrimeSwiftSourceFileSnapshot(
                relativePath: path,
                sha256:
                    PrimeSHA256.hexDigest(of: data),
                byteCount: UInt64(data.count),
                contents: data
            )
        }.sorted {
            $0.relativePath < $1.relativePath
        }
        let identityRecords = files.map {
            SyntheticSourceIdentityRecord(
                relativePath: $0.relativePath,
                sha256: $0.sha256,
                byteCount: $0.byteCount
            )
        }
        let sourceIdentity =
            PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(
                    identityRecords
                )
            )
        let embeddedPath =
            PrimeSwiftSourceProvenance
            .embeddedProvenanceRelativePath
        let embeddedData =
            PrimeSwiftSourceProvenance
            .canonicalEmbeddedProvenanceSource(
                sourceIdentitySHA256:
                    sourceIdentity
            )
        files.append(
            PrimeSwiftSourceFileSnapshot(
                relativePath: embeddedPath,
                sha256:
                    PrimeSHA256.hexDigest(
                        of: embeddedData
                    ),
                byteCount:
                    UInt64(embeddedData.count),
                contents: embeddedData
            )
        )
        files.sort {
            $0.relativePath < $1.relativePath
        }
        let snapshot =
            PrimeSwiftSourceSnapshot(
                sourceIdentitySHA256:
                    sourceIdentity,
                embeddedSourceIdentitySHA256:
                    sourceIdentity,
                buildConfiguration: "release",
                files: files
            )
        try PrimeSwiftSourceProvenance.validate(
            snapshot,
            requiredRelativePaths:
                Set(
                    contract.targetClosureRules.map {
                        $0
                        .sourceDirectoryRelativePath
                            + "/ContractFixture.swift"
                    }
                ),
            expectation:
                PrimeSwiftSourceProvenanceExpectation(
                    sourceIdentitySHA256:
                        sourceIdentity,
                    buildConfiguration:
                        "release"
                )
        )
        let snapshotData =
            try PrimeCanonicalJSON.encode(snapshot)
        let snapshotBinding =
            PrimeArtifactBinding(
                relativePath:
                    contract
                    .sourceSnapshotRelativePath,
                sha256:
                    PrimeSHA256.hexDigest(
                        of: snapshotData
                    ),
                byteCount:
                    UInt64(snapshotData.count),
                purpose: .immutableData
            )
        let swiftPackageDescribeData =
            try JSONSerialization.data(
                withJSONObject: [
                    "dependencies": [],
                    "targets":
                        contract.targetClosureRules
                        .map { rule in
                            [
                                "name":
                                    rule.targetName,
                                "path":
                                    rule
                                    .sourceDirectoryRelativePath,
                                "product_dependencies":
                                    [],
                                "sources":
                                    snapshot.files
                                    .filter {
                                        $0.relativePath
                                        .hasPrefix(
                                            rule
                                            .sourceDirectoryRelativePath
                                                + "/"
                                        )
                                            && $0
                                            .relativePath
                                            .hasSuffix(
                                                ".swift"
                                            )
                                    }
                                    .map {
                                        String(
                                            $0
                                            .relativePath
                                            .dropFirst(
                                                rule
                                                .sourceDirectoryRelativePath
                                                .count + 1
                                            )
                                        )
                                    }
                                    .sorted(),
                                "target_dependencies":
                                    rule
                                    .directLocalDependencyNames,
                                "type":
                                    rule.targetName
                                    .hasSuffix("Probe")
                                        || rule.targetName
                                        .hasSuffix("Verifier")
                                        || rule.targetName
                                        .hasSuffix("Worker")
                                    ? "executable"
                                    : "library",
                            ] as [String: Any]
                        },
                ] as [String: Any],
                options: [.sortedKeys]
            )
        let swiftPackageDescribeBinding =
            PrimeArtifactBinding(
                relativePath:
                    contract
                    .swiftPackageDescribeRelativePath,
                sha256:
                    PrimeSHA256.hexDigest(
                        of:
                            swiftPackageDescribeData
                    ),
                byteCount:
                    UInt64(
                        swiftPackageDescribeData
                            .count
                    ),
                purpose: .immutableData
            )
        let package = try XCTUnwrap(
            snapshot.files.first {
                $0.relativePath
                    == contract
                    .packageManifestRelativePath
            }
        )
        let planSHA =
            String(repeating: "d", count: 64)
        let closure =
            PrimeNativeNeuralGateCompiledSourceClosureRecord(
                planSHA256: planSHA,
                primeSourceSnapshot:
                    snapshotBinding,
                swiftPackageDescribe:
                    swiftPackageDescribeBinding,
                packageManifest:
                    .init(snapshot: package),
                sourceIdentitySHA256:
                    sourceIdentity,
                embeddedSourceIdentitySHA256:
                    sourceIdentity,
                buildConfiguration: "release",
                targets:
                    contract.targetClosureRules.map {
                        .init(
                            rule: $0,
                            snapshot: snapshot
                        )
                    }
            )
        try closure.validate(
            against: contract,
            expectedPlanSHA256: planSHA,
            snapshot: snapshot,
            swiftPackageDescribeData:
                swiftPackageDescribeData,
            expectedEmbeddedSourceIdentitySHA256:
                sourceIdentity
        )
        let closureBinding =
            try closure.artifactBinding(
                relativePath:
                    contract
                    .compiledSourceClosureRelativePath
            )
        return ObservedSourceClosureFixture(
            snapshot: snapshot,
            snapshotBinding: snapshotBinding,
            swiftPackageDescribeData:
                swiftPackageDescribeData,
            swiftPackageDescribeBinding:
                swiftPackageDescribeBinding,
            closure: closure,
            closureBinding: closureBinding,
            sourceIdentity: sourceIdentity
        )
    }

    private func binding(
        _ relativePath: String,
        payload: String,
        purpose: PrimeArtifactPurpose =
            .immutableData
    ) -> PrimeArtifactBinding {
        let data = Data(payload.utf8)
        return PrimeArtifactBinding(
            relativePath: relativePath,
            sha256:
                PrimeSHA256.hexDigest(of: data),
            byteCount: UInt64(data.count),
            purpose: purpose
        )
    }

    private func bytesFromHex(
        _ hex: String
    ) throws -> Data {
        guard hex.utf8.count.isMultiple(of: 2)
        else {
            throw CocoaError(
                .fileReadCorruptFile
            )
        }
        let characters = Array(hex.utf8)
        var bytes: [UInt8] = []
        bytes.reserveCapacity(characters.count / 2)
        var index = 0
        while index < characters.count {
            guard let high =
                    hexadecimalNibble(characters[index]),
                  let low =
                    hexadecimalNibble(
                        characters[index + 1]
                    )
            else {
                throw CocoaError(
                    .fileReadCorruptFile
                )
            }
            bytes.append(high << 4 | low)
            index += 2
        }
        return Data(bytes)
    }

    private func hexadecimalNibble(
        _ byte: UInt8
    ) -> UInt8? {
        switch byte {
        case 48 ... 57:
            byte - 48
        case 97 ... 102:
            byte - 87
        default:
            nil
        }
    }

    private func framedGlobalStream(
        _ records: [Data]
    ) -> Data {
        var data = Data("PRIMEIRM1".utf8)
        appendBigEndian(
            UInt64(records.count),
            to: &data
        )
        appendFramed(records, to: &data)
        return data
    }

    private func externalChildCaptureEvidence(
        contract:
            PrimeNativeNeuralGateSourceExecutionBindingContract,
        supervisorProcessIdentifier: Int32,
        childProcessIdentifier: Int32,
        descriptorDeviceID: UInt64 = 7,
        descriptorInode: UInt64 = 11,
        mappedDeviceID: UInt64? = nil,
        mappedInode: UInt64? = nil
    ) -> PrimeNativeNeuralGateExternalChildCaptureEvidence {
        let descriptor =
            PrimeNativeNeuralGateExecutableDescriptorSnapshot(
                deviceID: descriptorDeviceID,
                inode: descriptorInode,
                byteCount:
                    contract
                    .swiftPackageDescribeExpectedExecutableByteCount,
                sha256:
                    contract
                    .swiftPackageDescribeExpectedExecutableSHA256,
                ownerUserID:
                    contract
                    .swiftPackageDescribeExpectedExecutableOwnerUserID,
                ownerGroupID:
                    contract
                    .swiftPackageDescribeExpectedExecutableOwnerGroupID,
                permissionMode:
                    contract
                    .swiftPackageDescribeExpectedExecutablePermissionMode,
                linkCount:
                    contract
                    .swiftPackageDescribeExpectedExecutableLinkCount,
                modificationTimeSeconds: 100,
                modificationTimeNanoseconds: 200,
                statusChangeTimeSeconds: 300,
                statusChangeTimeNanoseconds: 400,
                regularFile: true,
                openedWithNoSymbolicLinksInPath:
                    true,
                closeOnExec: true
            )
        let regionDeviceID =
            mappedDeviceID ?? descriptorDeviceID
        let regionInode =
            mappedInode ?? descriptorInode
        return PrimeNativeNeuralGateExternalChildCaptureEvidence(
            supervisorProcessIdentifier:
                supervisorProcessIdentifier,
            childProcessIdentifier:
                childProcessIdentifier,
            capabilityCalibrationPassed: true,
            posixSpawnStartSuspendedFlag:
                0x0080,
            posixSpawnCloseOnExecDefaultFlag:
                0x4000,
            appliedSpawnFlags: 0x4080,
            posixSpawnReturnCode: 0,
            procPIDRegionPathInfoFlavor: 8,
            procRegionWithPathInfoByteCount:
                1_272,
            descriptorOpenedMonotonicNanoseconds:
                1_000,
            spawnReturnedMonotonicNanoseconds:
                2_000,
            mappedRegionCapturedMonotonicNanoseconds:
                3_000,
            descriptorRevalidatedBeforeResumeMonotonicNanoseconds:
                4_000,
            sigcontDeliveredMonotonicNanoseconds:
                5_000,
            sigcontReturnCode: 0,
            childTerminationObservedMonotonicNanoseconds:
                6_000,
            childReapedMonotonicNanoseconds:
                6_000,
            descriptorRevalidatedAfterReapMonotonicNanoseconds:
                7_000,
            preSpawnDescriptor: descriptor,
            preResumeDescriptor: descriptor,
            postReapDescriptor: descriptor,
            allMappedRegionQueries: [
                PrimeNativeNeuralGateMappedRegionQueryObservation(
                    queryAddress: 0,
                    returnedByteCount: 1_272,
                    region:
                        PrimeNativeNeuralGateMappedExecutableRegionObservation(
                            address: 0x1_000,
                            byteCount: 0x1_000,
                            fileOffset: 0,
                            protection: 5,
                            deviceID: regionDeviceID,
                            inode: regionInode
                        )
                ),
                PrimeNativeNeuralGateMappedRegionQueryObservation(
                    queryAddress: 0x2_000,
                    returnedByteCount: 1_272,
                    region:
                        PrimeNativeNeuralGateMappedExecutableRegionObservation(
                            address: 0x2_000,
                            byteCount: 0x1_000,
                            fileOffset: 0x1_000,
                            protection: 1,
                            deviceID: regionDeviceID,
                            inode: regionInode
                        )
                ),
            ],
            terminalMappedRegionQueryAddress:
                0x3_000,
            terminalMappedRegionQueryReturnByteCount:
                0,
            terminalMappedRegionQueryErrno:
                0,
            mappedRegionEnumerationCompleted:
                true,
            exactPIDWaitObservation:
                PrimeNativeNeuralGateExactPIDWaitObservation(
                    requestedProcessIdentifier:
                        childProcessIdentifier,
                    returnedProcessIdentifier:
                        childProcessIdentifier,
                    waitOptions: 0,
                    rawWaitStatus: 0,
                    returnedMonotonicNanoseconds:
                        6_000
                ),
            deadlineExpired: false,
            sigtermDelivered: false,
            sigkillDelivered: false,
            procPIDPathUsedOnlyAsTelemetry:
                true,
            contract: contract
        )
    }

    private func trustedExternalChildCapture(
        evidence:
            PrimeNativeNeuralGateExternalChildCaptureEvidence,
        role:
            PrimeNativeNeuralGateReleaseProcessRole,
        standardOutputData: Data,
        swiftPackageExecutableAbsolutePath:
            String =
                "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-package",
        mappedChildMainImageAbsolutePath:
            String =
                "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-package",
        workingDirectoryAbsolutePath:
            String =
                "/private/tmp/ergentics-prime",
        descriptorReadDataOverride: Data? = nil,
        launchObservationOverride:
            PrimeNativeNeuralGateTrustedExternalChildLaunchObservation?
                = nil,
        streamLifecycleObservationOverride:
            PrimeNativeNeuralGateTrustedExternalChildStreamLifecycleObservation?
                = nil
    ) throws
        -> PrimeNativeNeuralGateTrustedExternalChildCapture
    {
        let contract =
            Plan.frozenV1.sourceExecutionBinding
        let descriptorReadData: Data
        if let descriptorReadDataOverride {
            descriptorReadData =
                descriptorReadDataOverride
        } else {
            descriptorReadData =
                try frozenSwiftPackageExecutableData()
        }
        let launchObservation =
            launchObservationOverride
            ?? PrimeNativeNeuralGateTrustedExternalChildLaunchObservation(
                role: role,
                exactArguments:
                    contract
                    .swiftPackageDescribeExactArguments,
                directProcessWithoutShell:
                    true,
                workingDirectoryAbsolutePath:
                    workingDirectoryAbsolutePath,
                workingDirectoryIsValidatedPrimeRoot:
                    true,
                environmentKeyCount: 0,
                standardInputPolicy: "eof_v1",
                maximumWallSeconds:
                    contract
                    .swiftPackageDescribeMaximumWallSeconds,
                terminationControlPolicy:
                    contract
                    .swiftPackageDescribeTerminationEscalationPolicy
            )
        let streamLifecycleObservation =
            streamLifecycleObservationOverride
            ?? PrimeNativeNeuralGateTrustedExternalChildStreamLifecycleObservation(
                maximumStandardOutputBytes:
                    contract
                    .swiftPackageDescribeMaximumStandardOutputBytes,
                standardOutputOverflowed: false,
                standardOutputDrainCompleted: true,
                maximumStandardErrorBytes:
                    contract
                    .swiftPackageDescribeMaximumStandardErrorBytes,
                standardErrorOverflowed: false,
                standardErrorDrainCompleted: true
            )
        return try PrimeNativeNeuralGateTrustedExternalChildCapture(
            evidence: evidence,
            swiftPackageExecutableAbsolutePath:
                swiftPackageExecutableAbsolutePath,
            mappedChildMainImageAbsolutePath:
                mappedChildMainImageAbsolutePath,
            descriptorReadSnapshot:
                evidence.preSpawnDescriptor,
            descriptorReadData:
                descriptorReadData,
            standardOutputData:
                standardOutputData,
            standardErrorData: Data(),
            launchObservation:
                launchObservation,
            streamLifecycleObservation:
                streamLifecycleObservation
        )
    }

    private func frozenSwiftPackageExecutableData()
        throws -> Data
    {
        try Data(
            contentsOf: URL(
                fileURLWithPath:
                    "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-package"
            )
        )
    }

    private func framedChunk(
        ordinal: UInt32,
        records: [Data]
    ) -> Data {
        var data = Data("PRIMEIRC1".utf8)
        appendBigEndian(ordinal, to: &data)
        appendBigEndian(
            UInt32(records.count),
            to: &data
        )
        appendFramed(records, to: &data)
        return data
    }

    private func appendFramed(
        _ records: [Data],
        to output: inout Data
    ) {
        for record in records {
            appendBigEndian(
                UInt64(record.count),
                to: &output
            )
            output.append(record)
        }
    }

    private func appendBigEndian<
        Value: FixedWidthInteger
    >(
        _ value: Value,
        to output: inout Data
    ) {
        var encoded = value.bigEndian
        withUnsafeBytes(of: &encoded) {
            output.append(contentsOf: $0)
        }
    }

    private func directFingerprint(
        _ records: [Data]
    ) -> [UInt64] {
        let field = Plan.frozenV1.finiteField
        return field.evaluationPoints.map {
            point in
            var accumulator =
                field.accumulatorSeed
            for record in records {
                var length =
                    UInt64(record.count).bigEndian
                withUnsafeBytes(of: &length) {
                    for byte in $0 {
                        accumulator =
                            (
                                accumulator * point
                                    + UInt64(byte)
                                    + field.byteOffset
                            ) % field.prime
                    }
                }
                for byte in record {
                    accumulator =
                        (
                            accumulator * point
                                + UInt64(byte)
                                + field.byteOffset
                        ) % field.prime
                }
            }
            return accumulator
        }
    }

    private func acceleratedFingerprint(
        _ records: [Data]
    ) -> [UInt64] {
        let field = Plan.frozenV1.finiteField
        var stream = Data()
        appendFramed(records, to: &stream)
        return field.evaluationPoints.map {
            point in
            let root = stream.reduce(
                (multiplier: UInt64(1),
                 addend: UInt64(0))
            ) { accumulated, byte in
                let right = (
                    multiplier: point,
                    addend:
                        (
                            UInt64(byte)
                                + field.byteOffset
                        ) % field.prime
                )
                return (
                    multiplier:
                        (
                            accumulated.multiplier
                                * right.multiplier
                        ) % field.prime,
                    addend:
                        (
                            accumulated.addend
                                * right.multiplier
                                + right.addend
                        ) % field.prime
                )
            }
            return (
                field.accumulatorSeed
                    * root.multiplier
                    + root.addend
            ) % field.prime
        }
    }

    private func assertMutationRejected(
        _ mutate:
            (inout [String: Any]) -> Void
    ) throws {
        let source =
            try PrimeCanonicalJSON.encode(
                Plan.frozenV1
            )
        var object = try XCTUnwrap(
            try JSONSerialization.jsonObject(
                with: source
            ) as? [String: Any]
        )
        mutate(&object)
        let data = try JSONSerialization.data(
            withJSONObject: object,
            options: [
                .sortedKeys,
                .withoutEscapingSlashes,
            ]
        )
        let decoded = try JSONDecoder().decode(
            Plan.self,
            from: data
        )
        XCTAssertThrowsError(try decoded.validate())
    }
}
