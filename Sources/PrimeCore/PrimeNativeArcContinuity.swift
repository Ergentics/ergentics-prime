import Foundation

public enum PrimeNativeArcArtifactDisposition:
    String,
    Codable,
    Equatable,
    Sendable
{
    case checkedInSourceFixture =
        "checked_in_source_fixture"
    case checkedInHistoricalEvidence =
        "checked_in_historical_evidence"
    case checkedInContractEvidence =
        "checked_in_contract_evidence"
    case localOnlyPendingOffDeviceDurability =
        "local_only_pending_off_device_durability"
}

public enum PrimeNativeArcArtifactLocatorScope:
    String,
    Codable,
    Equatable,
    Sendable
{
    case repositoryRelativeAtPinnedRevision =
        "repository_relative_at_pinned_revision"
    case codexTaskOutputsRelative =
        "codex_task_outputs_relative"
}

public struct PrimeNativeArcArtifact:
    Codable,
    Equatable,
    Sendable
{
    public let artifactID: String
    public let authorityOwner: String
    public let locatorScope:
        PrimeNativeArcArtifactLocatorScope
    public let locator: String
    public let sha256: String
    public let disposition:
        PrimeNativeArcArtifactDisposition
}

public enum PrimeNativeArcContinuityError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
}

/// Typed cross-repository inventory for the native Prime model arc.
///
/// This value fails closed on in-process plan drift. It does not itself
/// resolve git revisions, local roots, or artifact bytes. The current AdamW
/// slice separately verifies only its four Prime-owned exact-3B/CPU bindings
/// and the Prime/private-MLX runtime; full cross-repository replay is
/// deferred. The inventory prevents a later task from rebuilding the model,
/// tokenizer, corpus, evaluator, or NeuralKit research gate merely because
/// they live in another repository.
public struct PrimeNativeArcContinuityPlan:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let arcID: String
    public let companionRepository: String
    public let companionRevision: String
    public let companionHistoricalRole: String
    public let companionWriteAuthorized: Bool
    public let companionRuntimeDependencyAuthorized: Bool
    public let primeRepository: String
    public let primeBaselineRevision: String
    public let primeTrainingAuthority: String
    public let primeOwnsNewNativeRuntime: Bool
    public let historicalRuntimeDonorRoot: String
    public let neuralKitRoot: String
    public let neuralKitRole: String
    public let neuralKitIntegrationMode: String
    public let productInferenceFacade: String
    public let productVerificationAuthority: String
    public let productRecommendationAuthority: String
    public let evidenceDirection: String
    public let primeTensorCoreImportsNeuralKit: Bool
    public let continuationProfileID: String
    public let continuationProfileSelectionAuthority: String
    public let historicalProfileComparisonVerdict: String
    public let historicalThreeBillionScaleAuthorized: Bool
    public let continuationScope: String
    /// Exact implementation used by the completed bounded mechanics receipt.
    ///
    /// This historical field does not select the implementation for future
    /// functional training. `PrimeNativeDecoderAuthorityPlan.frozenV1`
    /// supersedes that interpretation without rewriting the receipt.
    public let continuationModelImplementation: String
    public let continuationInitializationContract: String
    public let initializationEvidenceArtifactID: String
    public let seedDomainEvidenceArtifactID: String
    public let pretrainedWeightImportAuthorized: Bool
    public let newModelFamilyAuthorized: Bool
    public let tokenizerRebuildAuthorized: Bool
    public let corpusRebuildAuthorized: Bool
    public let evaluationContractRebuildAuthorized: Bool
    public let longTrainingAuthorized: Bool
    public let productPromotionAuthorized: Bool
    public let crossRepositoryArtifactResolutionComplete:
        Bool
    public let continuationInterruptionStep: Int
    public let continuationComparisonStep: Int
    public let artifacts: [PrimeNativeArcArtifact]
    public let artifactRepositoryRevisions:
        [String: String]
    public let currentSliceScope: String
    public let currentSliceRequiredArtifactIDs: [String]
    public let nativeContractAdapterMigrationAuthorizedInCurrentSlice:
        Bool
    public let neuralKitExecutionAuthorizedInCurrentSlice: Bool
    public let completedEvidenceIDs: [String]
    public let unresolvedEvidenceIDs: [String]
    public let orderedNextActions: [String]

    public static let frozenV1 = Self(
        schemaVersion: 1,
        arcID:
            "ergentics_prime_native_neuralkit_continuity_v1",
        companionRepository:
            "Ergentics/pmhnp-companion-ergentics",
        companionRevision:
            "163fc100710ece48119bc25954452d10f6a84f7f",
        companionHistoricalRole:
            "read_only_migration_oracle_and_historical_evidence",
        companionWriteAuthorized: false,
        companionRuntimeDependencyAuthorized: false,
        primeRepository: "Ergentics/ergentics-prime",
        primeBaselineRevision:
            "ddf0f96a3ec73c60810a297b32fc6ea26d32ca5f",
        primeTrainingAuthority: "ergentics-prime",
        primeOwnsNewNativeRuntime: true,
        historicalRuntimeDonorRoot: "prime-runtime",
        neuralKitRoot: "neural-kit",
        neuralKitRole:
            "downstream_synthetic_and_research_artifact_regrade",
        neuralKitIntegrationMode:
            "versioned_cross_repository_artifact_contract_no_tensor_core_dependency",
        productInferenceFacade:
            "NeuralKit.PrimeAskBrain",
        productVerificationAuthority:
            "PMHNP_app_PrimeChatModelEndpoint",
        productRecommendationAuthority:
            "PMHNP_EngineV21_plus_Recommender.recommend",
        evidenceDirection:
            "prime_emits_versioned_evidence_neuralkit_independently_regrades_research_artifacts",
        primeTensorCoreImportsNeuralKit: false,
        continuationProfileID:
            PrimeNativeProfiles.exact3B.profileID,
        continuationProfileSelectionAuthority:
            "operator_selected_bounded_mechanics_only",
        historicalProfileComparisonVerdict: "ABSTAIN",
        historicalThreeBillionScaleAuthorized: false,
        continuationScope:
            "two_step_optimizer_restore_mechanics_only",
        continuationModelImplementation:
            "MLXLLM.LlamaModel",
        continuationInitializationContract:
            "source_bound_factorized_seed_random_initialization_no_weight_import",
        initializationEvidenceArtifactID:
            "prime_exact_3b_fp32_source_snapshot",
        seedDomainEvidenceArtifactID:
            "prime_exact_3b_fp32_mechanics_receipt",
        pretrainedWeightImportAuthorized: false,
        newModelFamilyAuthorized: false,
        tokenizerRebuildAuthorized: false,
        corpusRebuildAuthorized: false,
        evaluationContractRebuildAuthorized: false,
        longTrainingAuthorized: false,
        productPromotionAuthorized: false,
        crossRepositoryArtifactResolutionComplete: false,
        continuationInterruptionStep: 1,
        continuationComparisonStep: 2,
        artifacts: [
            PrimeNativeArcArtifact(
                artifactID: "native_byte_tokenizer_manifest",
                authorityOwner:
                    "Ergentics/pmhnp-companion-ergentics",
                locatorScope:
                    .repositoryRelativeAtPinnedRevision,
                locator:
                    "content-staging/prime-native-byte-tokenizer-manifest.v1.json",
                sha256:
                    "5e3db93d26535cbb66b14f0170b1e04882aa942560af3c8b571d76dfaaa9f302",
                disposition: .checkedInSourceFixture
            ),
            PrimeNativeArcArtifact(
                artifactID:
                    "native_compositional_corpus_manifest",
                authorityOwner:
                    "Ergentics/pmhnp-companion-ergentics",
                locatorScope:
                    .repositoryRelativeAtPinnedRevision,
                locator:
                    "content-staging/prime-native-text-corpus-manifest.v1.json",
                sha256:
                    "fbb7362ee63b5825d1914815e8ff93c26a2c9a7de8be19347ccec3e449de8031",
                disposition: .checkedInSourceFixture
            ),
            PrimeNativeArcArtifact(
                artifactID: "native_10m_metal_mechanics_report",
                authorityOwner:
                    "Ergentics/pmhnp-companion-ergentics",
                locatorScope:
                    .repositoryRelativeAtPinnedRevision,
                locator:
                    "content-staging/prime-native-metal-language-canary-report.latest.json",
                sha256:
                    "686bc619ca2019e0960a887b35a8e7dc853172b0d24d27cfbba01e5624c7360c",
                disposition: .checkedInHistoricalEvidence
            ),
            PrimeNativeArcArtifact(
                artifactID:
                    "native_schema4_profile_screen_archive",
                authorityOwner:
                    "Ergentics/pmhnp-companion-ergentics",
                locatorScope:
                    .repositoryRelativeAtPinnedRevision,
                locator:
                    "content-staging/prime-native-language-schema4-profile-screen.v1.tar.xz",
                sha256:
                    "0830920b1e1d57e2fa20731d1caae89899802fec286bbca2e6ee58cbfb5cc903",
                disposition: .checkedInHistoricalEvidence
            ),
            PrimeNativeArcArtifact(
                artifactID:
                    "native_schema6_profile_screen_audit",
                authorityOwner:
                    "Ergentics/pmhnp-companion-ergentics",
                locatorScope:
                    .repositoryRelativeAtPinnedRevision,
                locator:
                    "content-staging/prime-native-language-schema6-profile-screen-audit.v1.json",
                sha256:
                    "4d7e696344770f57779cc72e1c6f58cb5ea6ce1b3ef0f86f1b571a3f10e84612",
                disposition: .checkedInHistoricalEvidence
            ),
            PrimeNativeArcArtifact(
                artifactID:
                    "native_schema6_truth_projection",
                authorityOwner:
                    "Ergentics/pmhnp-companion-ergentics",
                locatorScope:
                    .repositoryRelativeAtPinnedRevision,
                locator:
                    "content-staging/prime-native-language-schema6-profile-screen-truth-projection.v1.json",
                sha256:
                    "7d1c190659cec310e52e5823b1b752cba31f5a64a43cb25dfd1469d41155378a",
                disposition: .checkedInHistoricalEvidence
            ),
            PrimeNativeArcArtifact(
                artifactID:
                    "neuralkit_native_language_verify_abstain_receipt",
                authorityOwner:
                    "Ergentics/pmhnp-companion-ergentics",
                locatorScope:
                    .repositoryRelativeAtPinnedRevision,
                locator:
                    "content-staging/prime-native-language-schema4-verify-abstain-receipt.v1.json",
                sha256:
                    "91c6fd5f26492357cad938dcab1926356bc33914cc281c5ccd2297f1759b0b0a",
                disposition: .checkedInContractEvidence
            ),
            PrimeNativeArcArtifact(
                artifactID: "neuralkit_package_lock",
                authorityOwner:
                    "Ergentics/pmhnp-companion-ergentics",
                locatorScope:
                    .repositoryRelativeAtPinnedRevision,
                locator: "neural-kit/Package.resolved",
                sha256:
                    "cf1ba313dcb0c959e80ba09d6cbe0c56bcd921523bda5cec2c682c8ae7696ab3",
                disposition: .checkedInSourceFixture
            ),
            PrimeNativeArcArtifact(
                artifactID: "prime_exact_3b_fp32_mechanics_receipt",
                authorityOwner:
                    "Ergentics/ergentics-prime",
                locatorScope:
                    .repositoryRelativeAtPinnedRevision,
                locator:
                    "artifacts/exact-3b-fp32-canary-865073a-20260729T183120Z/prime-gpu-calibration-receipt.v2.json",
                sha256:
                    "da4b743f01264e60d6432a52bf141c2d840d299f90a52b489529aea1f83c304b",
                disposition: .checkedInHistoricalEvidence
            ),
            PrimeNativeArcArtifact(
                artifactID:
                    "prime_exact_3b_fp32_execution_configuration",
                authorityOwner:
                    "Ergentics/ergentics-prime",
                locatorScope:
                    .repositoryRelativeAtPinnedRevision,
                locator:
                    "artifacts/exact-3b-fp32-canary-865073a-20260729T183120Z/prime-3b-fp32-execution-configuration.v2.json",
                sha256:
                    "fd17bf1ceda6024533ce289e454fd3dc103fc9afa363b50928a767d425b9162c",
                disposition: .checkedInHistoricalEvidence
            ),
            PrimeNativeArcArtifact(
                artifactID:
                    "prime_exact_3b_fp32_source_snapshot",
                authorityOwner:
                    "Ergentics/ergentics-prime",
                locatorScope:
                    .repositoryRelativeAtPinnedRevision,
                locator:
                    "artifacts/exact-3b-fp32-canary-865073a-20260729T183120Z/prime-swift-source-snapshot.v1.json",
                sha256:
                    "a6b18f5e1670ac8241c4c35333d06f99d958505c79ef60c1ff4e56ec57673c34",
                disposition: .checkedInHistoricalEvidence
            ),
            PrimeNativeArcArtifact(
                artifactID:
                    "prime_typed_optimizer_restore_receipt",
                authorityOwner:
                    "Ergentics/ergentics-prime",
                locatorScope:
                    .repositoryRelativeAtPinnedRevision,
                locator:
                    "artifacts/typed-optimizer-restore-6465beb-20260729T184600Z/prime-typed-optimizer-restore-receipt.v2.json",
                sha256:
                    "fafc7d236a8a9b8f857d4a5bd9f34a3ed12012dd061a8a4c984fe85876fb569d",
                disposition: .checkedInContractEvidence
            ),
        ],
        artifactRepositoryRevisions: [
            "native_byte_tokenizer_manifest":
                "163fc100710ece48119bc25954452d10f6a84f7f",
            "native_compositional_corpus_manifest":
                "163fc100710ece48119bc25954452d10f6a84f7f",
            "native_10m_metal_mechanics_report":
                "163fc100710ece48119bc25954452d10f6a84f7f",
            "native_schema4_profile_screen_archive":
                "163fc100710ece48119bc25954452d10f6a84f7f",
            "native_schema6_profile_screen_audit":
                "163fc100710ece48119bc25954452d10f6a84f7f",
            "native_schema6_truth_projection":
                "163fc100710ece48119bc25954452d10f6a84f7f",
            "neuralkit_native_language_verify_abstain_receipt":
                "163fc100710ece48119bc25954452d10f6a84f7f",
            "neuralkit_package_lock":
                "163fc100710ece48119bc25954452d10f6a84f7f",
            "prime_exact_3b_fp32_mechanics_receipt":
                "ddf0f96a3ec73c60810a297b32fc6ea26d32ca5f",
            "prime_exact_3b_fp32_execution_configuration":
                "ddf0f96a3ec73c60810a297b32fc6ea26d32ca5f",
            "prime_exact_3b_fp32_source_snapshot":
                "ddf0f96a3ec73c60810a297b32fc6ea26d32ca5f",
            "prime_typed_optimizer_restore_receipt":
                "3481ffc24f3a81a26197fc8625510cab66e6e29b",
        ],
        currentSliceScope:
            "exact_3b_typed_adamw_metal_interrupted_continuation_only",
        currentSliceRequiredArtifactIDs: [
            "prime_exact_3b_fp32_mechanics_receipt",
            "prime_exact_3b_fp32_execution_configuration",
            "prime_exact_3b_fp32_source_snapshot",
            "prime_typed_optimizer_restore_receipt",
        ],
        nativeContractAdapterMigrationAuthorizedInCurrentSlice:
            false,
        neuralKitExecutionAuthorizedInCurrentSlice: false,
        completedEvidenceIDs: [
            "first_party_tokenizer_manifest_and_replay",
            "first_party_compositional_corpus_and_disjoint_splits",
            "native_10m_swift_mlx_metal_mechanics",
            "native_300m_1b_3b_fifteen_trial_profile_screen",
            "synthetic_neuralkit_sz_triadic_verify_abstain_contract",
            "exact_3b_fp32_allocation_forward_backward_adamw_step",
            "typed_adamw_cpu_fresh_process_n_plus_1",
            "typed_adamw_cpu_receipt_off_device_durability",
        ],
        unresolvedEvidenceIDs: [
            "cross_repository_artifact_resolution_and_compatibility_replay",
            "exact_3b_typed_adamw_metal_interrupted_trajectory",
            "physical_native_checkpoint_and_evaluation_shard_binding",
            "trained_checkpoint_fixed_cap64_eos_cached_uncached_regrade",
            "real_three_seed_neuralkit_functional_regrade",
        ],
        orderedNextActions: [
            "resolve_and_verify_current_slice_prime_exact_3b_and_cpu_evidence_bindings",
            "implement_exact_3b_typed_adamw_metal_interrupted_continuation_with_scoped_runtime_compatibility_replay",
        ]
    )

    public func validate() throws {
        let expected = Self.frozenV1
        let artifactIDs = artifacts.map(\.artifactID)
        let artifactHashes = artifacts.map(\.sha256)
        let knownArtifactIDs = Set(artifactIDs)
        let repositoryArtifactIDs = Set(
            artifacts
                .filter({
                    $0.locatorScope
                        == .repositoryRelativeAtPinnedRevision
                })
                .map(\.artifactID)
        )
        guard self == expected,
              schemaVersion == 1,
              [companionRevision, primeBaselineRevision]
                .allSatisfy({
                    $0.count == 40
                        && $0.allSatisfy {
                            "0123456789abcdef".contains($0)
                        }
                }),
              companionHistoricalRole
                == "read_only_migration_oracle_and_historical_evidence",
              !companionWriteAuthorized,
              !companionRuntimeDependencyAuthorized,
              primeOwnsNewNativeRuntime,
              neuralKitIntegrationMode
                == "versioned_cross_repository_artifact_contract_no_tensor_core_dependency",
              continuationProfileID
                == PrimeNativeProfiles.exact3B.profileID,
              continuationProfileSelectionAuthority
                == "operator_selected_bounded_mechanics_only",
              historicalProfileComparisonVerdict
                == "ABSTAIN",
              !historicalThreeBillionScaleAuthorized,
              continuationScope
                == "two_step_optimizer_restore_mechanics_only",
              continuationModelImplementation
                == "MLXLLM.LlamaModel",
              !pretrainedWeightImportAuthorized,
              !newModelFamilyAuthorized,
              !tokenizerRebuildAuthorized,
              !corpusRebuildAuthorized,
              !evaluationContractRebuildAuthorized,
              !primeTensorCoreImportsNeuralKit,
              !longTrainingAuthorized,
              !productPromotionAuthorized,
              !crossRepositoryArtifactResolutionComplete,
              currentSliceScope
                == "exact_3b_typed_adamw_metal_interrupted_continuation_only",
              !nativeContractAdapterMigrationAuthorizedInCurrentSlice,
              !neuralKitExecutionAuthorizedInCurrentSlice,
              continuationInterruptionStep == 1,
              continuationComparisonStep == 2,
              Set(artifactIDs).count == artifactIDs.count,
              Set(artifactRepositoryRevisions.keys)
                == repositoryArtifactIDs,
              artifactRepositoryRevisions.values
                .allSatisfy({
                    $0.count == 40
                        && $0.allSatisfy {
                            "0123456789abcdef".contains($0)
                        }
                }),
              knownArtifactIDs.contains(
                  initializationEvidenceArtifactID
              ),
              knownArtifactIDs.contains(
                  seedDomainEvidenceArtifactID
              ),
              Set(currentSliceRequiredArtifactIDs)
                .isSubset(of: knownArtifactIDs),
              artifacts
                .filter({
                    Set(currentSliceRequiredArtifactIDs)
                        .contains($0.artifactID)
                })
                .allSatisfy({
                    $0.authorityOwner
                        == "Ergentics/ergentics-prime"
                }),
              artifactHashes.allSatisfy({
                  $0.count == 64
                    && $0.allSatisfy {
                        "0123456789abcdef".contains($0)
                    }
              }),
              artifacts.allSatisfy({
                  !$0.locator.isEmpty
                    && !$0.locator.hasPrefix("/")
                    && !$0.locator.contains("..")
              }),
              artifacts.contains(where: {
                  $0.artifactID
                    == "neuralkit_native_language_verify_abstain_receipt"
              }),
              artifacts.contains(where: {
                  $0.artifactID
                    == "prime_typed_optimizer_restore_receipt"
                    && $0.locatorScope
                        == .repositoryRelativeAtPinnedRevision
                    && $0.disposition
                        == .checkedInContractEvidence
                    && $0.sha256
                        == "fafc7d236a8a9b8f857d4a5bd9f34a3ed12012dd061a8a4c984fe85876fb569d"
              }),
              artifactRepositoryRevisions[
                  "prime_typed_optimizer_restore_receipt"
              ] == "3481ffc24f3a81a26197fc8625510cab66e6e29b",
              !unresolvedEvidenceIDs.contains(
                  "typed_restore_receipt_off_device_durability"
              ),
              unresolvedEvidenceIDs.contains(
                  "exact_3b_typed_adamw_metal_interrupted_trajectory"
              ),
              orderedNextActions == [
                  "resolve_and_verify_current_slice_prime_exact_3b_and_cpu_evidence_bindings",
                  "implement_exact_3b_typed_adamw_metal_interrupted_continuation_with_scoped_runtime_compatibility_replay",
              ]
        else {
            throw PrimeNativeArcContinuityError
                .contractDrift
        }
    }
}
