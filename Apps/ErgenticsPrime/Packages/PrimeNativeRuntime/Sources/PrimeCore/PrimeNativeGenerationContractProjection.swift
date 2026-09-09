import Foundation

public enum PrimeNativeGenerationContractProjectionError:
    Error,
    Equatable,
    LocalizedError,
    Sendable
{
    case invalidSourceBinding(String)
    case invalidPlan
    case invalidFieldProjection(String)
    case invalidProjection(String)
    case invalidRawGenerationObservation(String)
    case invalidMutationRecord(String)

    public var errorDescription: String? {
        switch self {
        case let .invalidSourceBinding(detail):
            "native generation source binding is invalid: \(detail)"
        case .invalidPlan:
            "native generation contract plan drifted"
        case let .invalidFieldProjection(detail):
            "native generation field projection drifted: \(detail)"
        case let .invalidProjection(detail):
            "native generation contract projection drifted: \(detail)"
        case let .invalidRawGenerationObservation(detail):
            "native raw generation observation is invalid: \(detail)"
        case let .invalidMutationRecord(detail):
            "native generation mutation record is invalid: \(detail)"
        }
    }
}

private enum PrimeNativeGenerationContractHex {
    static func isLowercaseHex(
        _ value: String,
        byteCount: Int
    ) -> Bool {
        value.utf8.count == byteCount * 2
            && value.utf8.allSatisfy {
                ($0 >= 48 && $0 <= 57)
                    || ($0 >= 97 && $0 <= 102)
            }
    }
}

public enum PrimeNativeGenerationContractSourceRole:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Sendable
{
    case contractAuthority = "contract_authority"
    case independentAcceptanceGate =
        "independent_acceptance_gate"
    case operationalSwiftExecutor =
        "operational_swift_executor"
}

/// Exact Git-object identity for one historical source of generation
/// semantics. A source binding is lineage evidence; it is not executable
/// authority inside Prime.
public struct PrimeNativeGenerationContractSourceBinding:
    Codable,
    Equatable,
    Sendable
{
    public let role:
        PrimeNativeGenerationContractSourceRole
    public let repositoryRelativePath: String
    public let mode: String
    public let objectType: String
    public let gitBlobOID: String
    public let byteCount: UInt64
    public let sha256: String

    public init(
        role:
            PrimeNativeGenerationContractSourceRole,
        repositoryRelativePath: String,
        mode: String,
        objectType: String,
        gitBlobOID: String,
        byteCount: UInt64,
        sha256: String
    ) {
        self.role = role
        self.repositoryRelativePath =
            repositoryRelativePath
        self.mode = mode
        self.objectType = objectType
        self.gitBlobOID = gitBlobOID
        self.byteCount = byteCount
        self.sha256 = sha256
    }

    public func validate() throws {
        guard !repositoryRelativePath.isEmpty,
              !repositoryRelativePath.hasPrefix("/"),
              !repositoryRelativePath.contains(".."),
              !repositoryRelativePath.contains("\0"),
              mode == "100644",
              objectType == "blob",
              PrimeNativeGenerationContractHex
                .isLowercaseHex(
                    gitBlobOID,
                    byteCount: 20
                ),
              byteCount > 0,
              PrimeNativeGenerationContractHex
                .isLowercaseHex(
                    sha256,
                    byteCount: 32
                )
        else {
            throw PrimeNativeGenerationContractProjectionError
                .invalidSourceBinding(role.rawValue)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case role
        case repositoryRelativePath =
            "repository_relative_path"
        case mode
        case objectType = "object_type"
        case gitBlobOID = "git_blob_oid"
        case byteCount = "byte_count"
        case sha256
    }
}

/// Frozen publication plan for the standalone generation-contract
/// projection.
///
/// All three source pins are required because the authority file declares
/// the contract, the gate declares its independent acceptance checks, and
/// the Swift executor contains the operational allowed-support greedy
/// selection.
public struct PrimeNativeGenerationContractPlan:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let planID: String
    public let claimScope: String
    public let companionRepository: String
    public let companionRemoteURL: String
    public let companionRevision: String
    public let companionTreeOID: String
    public let sourceBindings:
        [PrimeNativeGenerationContractSourceBinding]
    public let requiredSourcePinCount: Int
    public let operationalSemanticsClaimRequiresAllSourcePins:
        Bool
    public let sourceBindingsAreDeclaredContentAuditedLineage:
        Bool
    public let sourceBlobEvidenceResolvedAtExecution:
        Bool
    public let freshVerifierSourceIdentityPolicy:
        String
    public let projectionRelativePath: String
    public let scientificAuthorityLanguage: String
    public let companionRuntimeDependencyAuthorized:
        Bool
    public let companionExecutionAuthorized: Bool
    public let neuralKitExecutionAuthorized: Bool
    public let modelExecutionAuthorized: Bool
    public let existingAdapterMutationAuthorized: Bool
    public let authorityStatement: String

    public static let frozenV1 = Self(
        schemaVersion: 1,
        planID:
            "ergentics_prime_native_fixed_cap_eos_kv_v2_generation_contract_projection_v1",
        claimScope:
            "source_pinned_schema4_fixed_cap_eos_kv_v2_generation_contract_projection_only",
        companionRepository:
            "Ergentics/pmhnp-companion-ergentics",
        companionRemoteURL:
            "https://github.com/Ergentics/pmhnp-companion-ergentics.git",
        companionRevision:
            "163fc100710ece48119bc25954452d10f6a84f7f",
        companionTreeOID:
            "9009daa4f8a07fbd5897e00b9571cef44ec292db",
        sourceBindings: [
            PrimeNativeGenerationContractSourceBinding(
                role: .contractAuthority,
                repositoryRelativePath:
                    "prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsNativeLanguageCanary.swift",
                mode: "100644",
                objectType: "blob",
                gitBlobOID:
                    "027a25b49dde1acfb4cd8af970e05ecd8241f427",
                byteCount: 216_815,
                sha256:
                    "8706343bf93c1dac70f5c263f7111667574da751cd27d6c3321a92fd822f063f"
            ),
            PrimeNativeGenerationContractSourceBinding(
                role: .independentAcceptanceGate,
                repositoryRelativePath:
                    "neural-kit/Sources/NeuralKit/PrimeNeuralNativeLanguageVerifyAbstainGate.swift",
                mode: "100644",
                objectType: "blob",
                gitBlobOID:
                    "795fff7c458ec68ba4562b6cd1c674fe8de7ffc4",
                byteCount: 368_918,
                sha256:
                    "c3c93c637cb15f3a6944e78d8d44c0045f873f7df54f6121ee2d25e4f166b0f6"
            ),
            PrimeNativeGenerationContractSourceBinding(
                role: .operationalSwiftExecutor,
                repositoryRelativePath:
                    "prime-runtime/Sources/PrimeNativeLanguageSwiftCanary/main.swift",
                mode: "100644",
                objectType: "blob",
                gitBlobOID:
                    "94227842cdff73434c926527a6081aaf20f37155",
                byteCount: 174_006,
                sha256:
                    "7a3ba9477a7ac82dccfe6dcc7ec09af738b40298cdab6b259ddf1e9d36ec15b4"
            ),
        ],
        requiredSourcePinCount: 3,
        operationalSemanticsClaimRequiresAllSourcePins:
            true,
        sourceBindingsAreDeclaredContentAuditedLineage:
            true,
        sourceBlobEvidenceResolvedAtExecution:
            false,
        freshVerifierSourceIdentityPolicy:
            "same_source_identity_release_binary_required_v1",
        projectionRelativePath:
            "generation-contract/prime-native-fixed-cap-eos-generation-contract-projection.v1.json",
        scientificAuthorityLanguage: "swift",
        companionRuntimeDependencyAuthorized: false,
        companionExecutionAuthorized: false,
        neuralKitExecutionAuthorized: false,
        modelExecutionAuthorized: false,
        existingAdapterMutationAuthorized: false,
        authorityStatement:
            "This Swift plan freezes a standalone projection of the exact source-pinned schema-4 fixed-cap/EOS and KV-cache generation boundary. It records three content-audited Git object identities needed to trace declared, independently gated, and operational Swift semantics; those source blobs are lineage declarations and are not runtime-resolved evidence in this slice. Fresh verification requires a Release verifier built from the same Prime source identity. It does not import or execute companion runtime code, NeuralKit, an executor, a model, or generation artifacts, and it does not mutate or promote the existing resolved-contract adapter."
    )

    public static let requiredSourcePaths =
        frozenV1.sourceBindings.map(
            \.repositoryRelativePath
        )

    public init(
        schemaVersion: Int,
        planID: String,
        claimScope: String,
        companionRepository: String,
        companionRemoteURL: String,
        companionRevision: String,
        companionTreeOID: String,
        sourceBindings:
            [PrimeNativeGenerationContractSourceBinding],
        requiredSourcePinCount: Int,
        operationalSemanticsClaimRequiresAllSourcePins:
            Bool,
        sourceBindingsAreDeclaredContentAuditedLineage:
            Bool,
        sourceBlobEvidenceResolvedAtExecution:
            Bool,
        freshVerifierSourceIdentityPolicy:
            String,
        projectionRelativePath: String,
        scientificAuthorityLanguage: String,
        companionRuntimeDependencyAuthorized:
            Bool,
        companionExecutionAuthorized: Bool,
        neuralKitExecutionAuthorized: Bool,
        modelExecutionAuthorized: Bool,
        existingAdapterMutationAuthorized: Bool,
        authorityStatement: String
    ) {
        self.schemaVersion = schemaVersion
        self.planID = planID
        self.claimScope = claimScope
        self.companionRepository =
            companionRepository
        self.companionRemoteURL =
            companionRemoteURL
        self.companionRevision = companionRevision
        self.companionTreeOID = companionTreeOID
        self.sourceBindings = sourceBindings
        self.requiredSourcePinCount =
            requiredSourcePinCount
        self
            .operationalSemanticsClaimRequiresAllSourcePins =
            operationalSemanticsClaimRequiresAllSourcePins
        self
            .sourceBindingsAreDeclaredContentAuditedLineage =
            sourceBindingsAreDeclaredContentAuditedLineage
        self.sourceBlobEvidenceResolvedAtExecution =
            sourceBlobEvidenceResolvedAtExecution
        self.freshVerifierSourceIdentityPolicy =
            freshVerifierSourceIdentityPolicy
        self.projectionRelativePath =
            projectionRelativePath
        self.scientificAuthorityLanguage =
            scientificAuthorityLanguage
        self.companionRuntimeDependencyAuthorized =
            companionRuntimeDependencyAuthorized
        self.companionExecutionAuthorized =
            companionExecutionAuthorized
        self.neuralKitExecutionAuthorized =
            neuralKitExecutionAuthorized
        self.modelExecutionAuthorized =
            modelExecutionAuthorized
        self.existingAdapterMutationAuthorized =
            existingAdapterMutationAuthorized
        self.authorityStatement = authorityStatement
    }

    public func validate() throws {
        guard self == .frozenV1,
              requiredSourcePinCount
                == sourceBindings.count,
              Set(sourceBindings.map(\.role))
                == Set(
                    PrimeNativeGenerationContractSourceRole
                        .allCases
                ),
              Set(
                  sourceBindings.map(
                      \.repositoryRelativePath
                  )
              ).count == sourceBindings.count,
              Set(sourceBindings.map(\.gitBlobOID)).count
                == sourceBindings.count,
              operationalSemanticsClaimRequiresAllSourcePins,
              sourceBindingsAreDeclaredContentAuditedLineage,
              !sourceBlobEvidenceResolvedAtExecution,
              freshVerifierSourceIdentityPolicy
                == "same_source_identity_release_binary_required_v1",
              !companionRuntimeDependencyAuthorized,
              !companionExecutionAuthorized,
              !neuralKitExecutionAuthorized,
              !modelExecutionAuthorized,
              !existingAdapterMutationAuthorized
        else {
            throw PrimeNativeGenerationContractProjectionError
                .invalidPlan
        }
        try sourceBindings.forEach {
            try $0.validate()
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case planID = "plan_id"
        case claimScope = "claim_scope"
        case companionRepository =
            "companion_repository"
        case companionRemoteURL =
            "companion_remote_url"
        case companionRevision =
            "companion_revision"
        case companionTreeOID =
            "companion_tree_oid"
        case sourceBindings = "source_bindings"
        case requiredSourcePinCount =
            "required_source_pin_count"
        case operationalSemanticsClaimRequiresAllSourcePins =
            "operational_semantics_claim_requires_all_source_pins"
        case sourceBindingsAreDeclaredContentAuditedLineage =
            "source_bindings_are_declared_content_audited_lineage"
        case sourceBlobEvidenceResolvedAtExecution =
            "source_blob_evidence_resolved_at_execution"
        case freshVerifierSourceIdentityPolicy =
            "fresh_verifier_source_identity_policy"
        case projectionRelativePath =
            "projection_relative_path"
        case scientificAuthorityLanguage =
            "scientific_authority_language"
        case companionRuntimeDependencyAuthorized =
            "companion_runtime_dependency_authorized"
        case companionExecutionAuthorized =
            "companion_execution_authorized"
        case neuralKitExecutionAuthorized =
            "neuralkit_execution_authorized"
        case modelExecutionAuthorized =
            "model_execution_authorized"
        case existingAdapterMutationAuthorized =
            "existing_adapter_mutation_authorized"
        case authorityStatement =
            "authority_statement"
    }
}

public struct PrimeNativeGenerationPromptOnlyFieldProjection:
    Codable,
    Equatable,
    Sendable
{
    public let primeRequestFields: [String]
    public let historicalBoundaryFields: [String]
    public let contractBoundFields: [String]
    public let modelVisibleFields: [String]
    public let forbiddenTargetAndRegradeFields:
        [String]
    public let historicalSerializedRequestSchemaExists:
        Bool
    public let seedBoundOutsideHistoricalRow: Bool
    public let promptPassedToExecutorAsText: Bool
    public let targetFeasibilityPrecheckOccursBeforeGeneration:
        Bool
    public let targetFeasibilityPrecheckPolicy:
        String
    public let targetControlsStoppingLength: Bool
    public let targetVisibleToGenerationLoop: Bool

    public static let frozenV1 = Self(
        primeRequestFields: [
            "row_id",
            "seed",
            "prompt_text",
            "prompt_token_ids",
            "prompt_grouping_key",
        ],
        historicalBoundaryFields: [
            "row_id",
            "prompt_text",
            "prompt_grouping_key",
            "generation_decision_budget",
        ],
        contractBoundFields: [
            "prompt_grouping_key_id",
            "generation_decision_budget",
            "allowed_completion_token_set_sha256",
            "eos_available_at_every_decision",
            "target_independent_decision_budget",
        ],
        modelVisibleFields: [
            "prompt_token_ids",
        ],
        forbiddenTargetAndRegradeFields: [
            "corpus_row_sha256",
            "evaluation_row_sha256",
            "split",
            "semantic_family",
            "invariant_ids",
            "mutation_id",
            "abstention_reason",
            "target",
            "target_token_ids",
            "expected_completion",
            "expected_completion_token_ids",
            "exact_match",
            "semantic_verifier_pass",
            "abstention_decision",
        ],
        historicalSerializedRequestSchemaExists:
            false,
        seedBoundOutsideHistoricalRow: true,
        promptPassedToExecutorAsText: true,
        targetFeasibilityPrecheckOccursBeforeGeneration:
            true,
        targetFeasibilityPrecheckPolicy:
            "global_reject_when_target_byte_count_plus_eos_exceeds_fixed_cap_not_a_stopping_length_v1",
        targetControlsStoppingLength: false,
        targetVisibleToGenerationLoop: false
    )

    public init(
        primeRequestFields: [String],
        historicalBoundaryFields: [String],
        contractBoundFields: [String],
        modelVisibleFields: [String],
        forbiddenTargetAndRegradeFields:
            [String],
        historicalSerializedRequestSchemaExists:
            Bool,
        seedBoundOutsideHistoricalRow: Bool,
        promptPassedToExecutorAsText: Bool,
        targetFeasibilityPrecheckOccursBeforeGeneration:
            Bool,
        targetFeasibilityPrecheckPolicy:
            String,
        targetControlsStoppingLength: Bool,
        targetVisibleToGenerationLoop: Bool
    ) {
        self.primeRequestFields =
            primeRequestFields
        self.historicalBoundaryFields =
            historicalBoundaryFields
        self.contractBoundFields =
            contractBoundFields
        self.modelVisibleFields = modelVisibleFields
        self.forbiddenTargetAndRegradeFields =
            forbiddenTargetAndRegradeFields
        self.historicalSerializedRequestSchemaExists =
            historicalSerializedRequestSchemaExists
        self.seedBoundOutsideHistoricalRow =
            seedBoundOutsideHistoricalRow
        self.promptPassedToExecutorAsText =
            promptPassedToExecutorAsText
        self
            .targetFeasibilityPrecheckOccursBeforeGeneration =
            targetFeasibilityPrecheckOccursBeforeGeneration
        self.targetFeasibilityPrecheckPolicy =
            targetFeasibilityPrecheckPolicy
        self.targetControlsStoppingLength =
            targetControlsStoppingLength
        self.targetVisibleToGenerationLoop =
            targetVisibleToGenerationLoop
    }

    public func validateFrozenV1() throws {
        guard self == .frozenV1,
              Set(primeRequestFields).count
                == primeRequestFields.count,
              Set(historicalBoundaryFields).count
                == historicalBoundaryFields.count,
              Set(contractBoundFields).count
                == contractBoundFields.count,
              Set(modelVisibleFields)
                .isSubset(
                    of: Set(primeRequestFields)
                ),
              Set(forbiddenTargetAndRegradeFields)
                .isDisjoint(
                    with: Set(primeRequestFields)
                )
        else {
            throw PrimeNativeGenerationContractProjectionError
                .invalidFieldProjection(
                    "prompt-only boundary"
                )
        }
    }

    private enum CodingKeys: String, CodingKey {
        case primeRequestFields =
            "prime_request_fields"
        case historicalBoundaryFields =
            "historical_boundary_fields"
        case contractBoundFields =
            "contract_bound_fields"
        case modelVisibleFields =
            "model_visible_fields"
        case forbiddenTargetAndRegradeFields =
            "forbidden_target_and_regrade_fields"
        case historicalSerializedRequestSchemaExists =
            "historical_serialized_request_schema_exists"
        case seedBoundOutsideHistoricalRow =
            "seed_bound_outside_historical_row"
        case promptPassedToExecutorAsText =
            "prompt_passed_to_executor_as_text"
        case targetFeasibilityPrecheckOccursBeforeGeneration =
            "target_feasibility_precheck_occurs_before_generation"
        case targetFeasibilityPrecheckPolicy =
            "target_feasibility_precheck_policy"
        case targetControlsStoppingLength =
            "target_controls_stopping_length"
        case targetVisibleToGenerationLoop =
            "target_visible_to_generation_loop"
    }
}

/// Exact KV-cache execution and acceptance-witness requirements carried by
/// generation contract `greedy_native_bytes_eos_fixed_cap64_kv_v2`.
///
/// These are projected requirements, not observations that a Prime model has
/// satisfied them. The receipt keeps all model, logits, and behavior
/// observations false.
public struct PrimeNativeGenerationKVCacheMechanicsProjection:
    Codable,
    Equatable,
    Sendable
{
    public let generationUsesKVCache: Bool
    public let cacheScopePolicy: String
    public let promptPrefillPolicy: String
    public let promptBatchGeometryPolicy: String
    public let decodeStepPolicy: String
    public let decodeStepInputTokenCount: Int
    public let contextCapacityPolicy: String
    public let generationContextMatchesProfileMaximumSequenceLengthRequired:
        Bool
    public let insufficientGenerationContextRowIDsMustBeEmpty:
        Bool
    public let singleStepParityFixturePolicy:
        String
    public let singleStepFixtureTokenIDs: [Int]
    public let singleStepLogitDeltaMustBeFinite:
        Bool
    public let singleStepMaximumLogitDeltaUpperBound:
        Double
    public let singleStepGreedyComparisonDomain:
        String
    public let singleStepGreedyTokenParityRequired:
        Bool
    public let multiStepParityFixturePolicy:
        String
    public let multiStepPromptTokenIDPaths:
        [[Int]]
    public let multiStepContinuationTokenIDPaths:
        [[Int]]
    public let multiStepLogitDeltaMustBeFinite:
        Bool
    public let multiStepLogitDeltaMustBeNonnegative:
        Bool
    public let multiStepMaximumLogitDeltaUpperBound:
        Double
    public let multiStepGreedyComparisonDomain:
        String
    public let multiStepGreedyTokenParityRequired:
        Bool
    public let multiStepComparedDecisionCount:
        Int
    public let multiStepContinuationDecisionCounts:
        [Int]
    public let multiStepUnevenEOSRequired: Bool
    public let cacheParityWitnessValuesObserved:
        Bool

    public static let frozenV1 = Self(
        generationUsesKVCache: true,
        cacheScopePolicy:
            "one_new_cache_per_equal_prompt_length_generation_batch_v1",
        promptPrefillPolicy:
            "one_cached_batched_prompt_prefill_including_bos_before_decision_loop_v1",
        promptBatchGeometryPolicy:
            "all_batched_prompt_sequences_have_equal_token_count_including_bos_v1",
        decodeStepPolicy:
            "cached_one_token_per_batch_row_for_each_subsequent_active_decision_v1",
        decodeStepInputTokenCount: 1,
        contextCapacityPolicy:
            "prompt_token_count_including_bos_plus_fixed_64_decisions_lte_maximum_sequence_length_v1",
        generationContextMatchesProfileMaximumSequenceLengthRequired:
            true,
        insufficientGenerationContextRowIDsMustBeEmpty:
            true,
        singleStepParityFixturePolicy:
            "uncached_full_sequence_last_logit_vs_cached_prefix_then_one_token_last_logit_v1",
        singleStepFixtureTokenIDs:
            [1, 321, 322, 323, 324, 325, 326, 70],
        singleStepLogitDeltaMustBeFinite:
            true,
        singleStepMaximumLogitDeltaUpperBound:
            1e-4,
        singleStepGreedyComparisonDomain:
            "full_vocabulary_512_v1",
        singleStepGreedyTokenParityRequired:
            true,
        multiStepParityFixturePolicy:
            "two_prompt_only_cached_paths_each_compared_to_uncached_full_prefix_at_every_decision_v1",
        multiStepPromptTokenIDPaths: [
            [1, 300, 301],
            [1, 310, 311, 312, 313],
        ],
        multiStepContinuationTokenIDPaths: [
            [321, 70],
            [341, 342, 343, 70],
        ],
        multiStepLogitDeltaMustBeFinite:
            true,
        multiStepLogitDeltaMustBeNonnegative:
            true,
        multiStepMaximumLogitDeltaUpperBound:
            1e-4,
        multiStepGreedyComparisonDomain:
            "ordered_allowed_completion_support_v1",
        multiStepGreedyTokenParityRequired:
            true,
        multiStepComparedDecisionCount: 6,
        multiStepContinuationDecisionCounts:
            [2, 4],
        multiStepUnevenEOSRequired: true,
        cacheParityWitnessValuesObserved:
            false
    )

    public func validateFrozenV1() throws {
        guard self == .frozenV1,
              generationUsesKVCache,
              decodeStepInputTokenCount == 1,
              generationContextMatchesProfileMaximumSequenceLengthRequired,
              insufficientGenerationContextRowIDsMustBeEmpty,
              singleStepFixtureTokenIDs
                == [1, 321, 322, 323, 324, 325, 326, 70],
              singleStepLogitDeltaMustBeFinite,
              singleStepMaximumLogitDeltaUpperBound
                == 1e-4,
              singleStepGreedyTokenParityRequired,
              multiStepLogitDeltaMustBeFinite,
              multiStepLogitDeltaMustBeNonnegative,
              multiStepMaximumLogitDeltaUpperBound
                == 1e-4,
              multiStepGreedyTokenParityRequired,
              multiStepPromptTokenIDPaths
                == [
                    [1, 300, 301],
                    [1, 310, 311, 312, 313],
                ],
              multiStepContinuationTokenIDPaths
                == [
                    [321, 70],
                    [341, 342, 343, 70],
                ],
              multiStepComparedDecisionCount == 6,
              multiStepContinuationDecisionCounts
                == [2, 4],
              multiStepContinuationTokenIDPaths
                .map(\.count)
                == multiStepContinuationDecisionCounts,
              multiStepContinuationDecisionCounts
                .reduce(0, +)
                == multiStepComparedDecisionCount,
              Set(multiStepContinuationDecisionCounts)
                .count > 1,
              multiStepContinuationTokenIDPaths
                .allSatisfy({
                    $0.last
                        == PrimeNativeByteTokenizer
                        .endOfSequenceTokenID
                }),
              multiStepUnevenEOSRequired,
              !cacheParityWitnessValuesObserved
        else {
            throw PrimeNativeGenerationContractProjectionError
                .invalidFieldProjection(
                    "KV-cache mechanics"
                )
        }
    }

    private enum CodingKeys: String, CodingKey {
        case generationUsesKVCache =
            "generation_uses_kv_cache"
        case cacheScopePolicy =
            "cache_scope_policy"
        case promptPrefillPolicy =
            "prompt_prefill_policy"
        case promptBatchGeometryPolicy =
            "prompt_batch_geometry_policy"
        case decodeStepPolicy =
            "decode_step_policy"
        case decodeStepInputTokenCount =
            "decode_step_input_token_count"
        case contextCapacityPolicy =
            "context_capacity_policy"
        case generationContextMatchesProfileMaximumSequenceLengthRequired =
            "generation_context_matches_profile_maximum_sequence_length_required"
        case insufficientGenerationContextRowIDsMustBeEmpty =
            "insufficient_generation_context_row_ids_must_be_empty"
        case singleStepParityFixturePolicy =
            "single_step_parity_fixture_policy"
        case singleStepFixtureTokenIDs =
            "single_step_fixture_token_ids"
        case singleStepLogitDeltaMustBeFinite =
            "single_step_logit_delta_must_be_finite"
        case singleStepMaximumLogitDeltaUpperBound =
            "single_step_maximum_logit_delta_upper_bound"
        case singleStepGreedyComparisonDomain =
            "single_step_greedy_comparison_domain"
        case singleStepGreedyTokenParityRequired =
            "single_step_greedy_token_parity_required"
        case multiStepParityFixturePolicy =
            "multi_step_parity_fixture_policy"
        case multiStepPromptTokenIDPaths =
            "multi_step_prompt_token_id_paths"
        case multiStepContinuationTokenIDPaths =
            "multi_step_continuation_token_id_paths"
        case multiStepLogitDeltaMustBeFinite =
            "multi_step_logit_delta_must_be_finite"
        case multiStepLogitDeltaMustBeNonnegative =
            "multi_step_logit_delta_must_be_nonnegative"
        case multiStepMaximumLogitDeltaUpperBound =
            "multi_step_maximum_logit_delta_upper_bound"
        case multiStepGreedyComparisonDomain =
            "multi_step_greedy_comparison_domain"
        case multiStepGreedyTokenParityRequired =
            "multi_step_greedy_token_parity_required"
        case multiStepComparedDecisionCount =
            "multi_step_compared_decision_count"
        case multiStepContinuationDecisionCounts =
            "multi_step_continuation_decision_counts"
        case multiStepUnevenEOSRequired =
            "multi_step_uneven_eos_required"
        case cacheParityWitnessValuesObserved =
            "cache_parity_witness_values_observed"
    }
}

/// Exact unrestricted-vocabulary diagnostic computation carried alongside
/// allowed-support generation. These values diagnose how much the allowed
/// support assists generation; they do not change the selected-token rule.
public struct PrimeNativeGenerationFullVocabularyWitnessProjection:
    Codable,
    Equatable,
    Sendable
{
    public let logitsExtractionPrecisionPolicy:
        String
    public let logSoftmaxPolicy: String
    public let logProbabilityExtractionPrecisionPolicy:
        String
    public let rawFullVocabularyArgmaxPolicy:
        String
    public let parityAccumulationPolicy: String
    public let disallowedArgmaxCountPolicy: String
    public let disallowedTokenSetPolicy: String
    public let disallowedProbabilityMassPerDecisionPolicy:
        String
    public let maximumDisallowedProbabilityMassPolicy:
        String
    public let maximumDisallowedProbabilityMassAcceptanceLowerBound:
        Double
    public let maximumDisallowedProbabilityMassAcceptanceUpperBound:
        Double
    public let witnessValuesRecomputedFromLogits:
        Bool

    public static let frozenV1 = Self(
        logitsExtractionPrecisionPolicy:
            "mlx_logits_extracted_as_float32_v1",
        logSoftmaxPolicy:
            "mlx_logsoftmax_axis_minus_one_over_full_512_token_vocabulary_v1",
        logProbabilityExtractionPrecisionPolicy:
            "mlx_logsoftmax_values_extracted_as_float32_then_promoted_to_double_v1",
        rawFullVocabularyArgmaxPolicy:
            "ordered_argmax_over_float32_logits_for_token_ids_0_through_511_v1",
        parityAccumulationPolicy:
            "running_and_of_raw_full_vocabulary_argmax_equals_allowed_support_selection_over_active_decisions_v1",
        disallowedArgmaxCountPolicy:
            "count_active_decisions_whose_raw_full_vocabulary_argmax_is_outside_allowed_support_v1",
        disallowedTokenSetPolicy:
            "token_ids_0_through_511_minus_allowed_completion_support_v1",
        disallowedProbabilityMassPerDecisionPolicy:
            "sum_foundation_exp_of_double_promoted_float32_full_vocabulary_logsoftmax_for_every_disallowed_token_v1",
        maximumDisallowedProbabilityMassPolicy:
            "maximum_per_decision_disallowed_probability_mass_over_active_decisions_only_v1",
        maximumDisallowedProbabilityMassAcceptanceLowerBound:
            0,
        maximumDisallowedProbabilityMassAcceptanceUpperBound:
            1.000_001,
        witnessValuesRecomputedFromLogits:
            false
    )

    public func validateFrozenV1() throws {
        guard self == .frozenV1,
              maximumDisallowedProbabilityMassAcceptanceLowerBound
                == 0,
              maximumDisallowedProbabilityMassAcceptanceUpperBound
                == 1.000_001,
              !witnessValuesRecomputedFromLogits
        else {
            throw PrimeNativeGenerationContractProjectionError
                .invalidFieldProjection(
                    "full-vocabulary support witness"
                )
        }
    }

    private enum CodingKeys: String, CodingKey {
        case logitsExtractionPrecisionPolicy =
            "logits_extraction_precision_policy"
        case logSoftmaxPolicy =
            "log_softmax_policy"
        case logProbabilityExtractionPrecisionPolicy =
            "log_probability_extraction_precision_policy"
        case rawFullVocabularyArgmaxPolicy =
            "raw_full_vocabulary_argmax_policy"
        case parityAccumulationPolicy =
            "parity_accumulation_policy"
        case disallowedArgmaxCountPolicy =
            "disallowed_argmax_count_policy"
        case disallowedTokenSetPolicy =
            "disallowed_token_set_policy"
        case disallowedProbabilityMassPerDecisionPolicy =
            "disallowed_probability_mass_per_decision_policy"
        case maximumDisallowedProbabilityMassPolicy =
            "maximum_disallowed_probability_mass_policy"
        case maximumDisallowedProbabilityMassAcceptanceLowerBound =
            "maximum_disallowed_probability_mass_acceptance_lower_bound"
        case maximumDisallowedProbabilityMassAcceptanceUpperBound =
            "maximum_disallowed_probability_mass_acceptance_upper_bound"
        case witnessValuesRecomputedFromLogits =
            "witness_values_recomputed_from_logits"
    }
}

public struct PrimeNativeGenerationRawShardFieldProjection:
    Codable,
    Equatable,
    Sendable
{
    public let shardSchemaVersion: String
    public let phases: [String]
    public let shardEnvelopeFields: [String]
    public let entryFields: [String]
    public let generatedFields: [String]

    public static let frozenV1 = Self(
        shardSchemaVersion: "2",
        phases: [
            "zero_shot",
            "trained",
            "reloaded",
        ],
        shardEnvelopeFields: [
            "schema_version",
            "phase",
            "profile_id",
            "seed",
            "corpus_manifest_sha256",
            "generation_contract_id",
            "maximum_generation_token_decisions",
            "model_binding_sha256",
            "first_row_id",
            "last_row_id",
            "entries",
        ],
        entryFields: [
            "row_id",
            "generated",
        ],
        generatedFields: [
            "text",
            "tokenIDs",
            "tokenLogProbabilities",
            "meanLogProbability",
            "terminatedByEOS",
            "terminationReason",
            "utf8Valid",
            "eosLogProbability",
            "rawFullVocabularyAllowedSupportGreedyTokenParity",
            "disallowedFullVocabularyArgmaxCount",
            "maximumDisallowedTokenProbabilityMass",
            "latencySeconds",
        ]
    )

    public init(
        shardSchemaVersion: String,
        phases: [String],
        shardEnvelopeFields: [String],
        entryFields: [String],
        generatedFields: [String]
    ) {
        self.shardSchemaVersion =
            shardSchemaVersion
        self.phases = phases
        self.shardEnvelopeFields =
            shardEnvelopeFields
        self.entryFields = entryFields
        self.generatedFields = generatedFields
    }

    public func validateFrozenV1() throws {
        guard self == .frozenV1,
              Set(phases).count == phases.count,
              Set(shardEnvelopeFields).count
                == shardEnvelopeFields.count,
              Set(entryFields).count
                == entryFields.count,
              Set(generatedFields).count
                == generatedFields.count
        else {
            throw PrimeNativeGenerationContractProjectionError
                .invalidFieldProjection(
                    "raw shard"
                )
        }
    }

    private enum CodingKeys: String, CodingKey {
        case shardSchemaVersion =
            "shard_schema_version"
        case phases
        case shardEnvelopeFields =
            "shard_envelope_fields"
        case entryFields = "entry_fields"
        case generatedFields = "generated_fields"
    }
}

public struct PrimeNativeGenerationSchema4RegradeFieldProjection:
    Codable,
    Equatable,
    Sendable
{
    public let reportSchemaVersion: String
    public let authorityFields: [String]
    public let generationContractBindingFields:
        [String]
    public let zeroShotRawFields: [String]
    public let zeroShotRegradeFields: [String]
    public let trainedRawFields: [String]
    public let trainedRegradeFields: [String]
    public let orderedRecordFields: [String]

    public static let frozenV1 = Self(
        reportSchemaVersion: "4",
        authorityFields: [
            "row_id",
            "corpus_row_sha256",
            "evaluation_row_sha256",
            "split",
            "semantic_family",
            "invariant_ids",
            "mutation_id",
            "abstention_reason",
            "prompt",
            "prompt_token_ids",
            "target",
            "target_token_ids",
        ],
        generationContractBindingFields: [
            "prompt_grouping_key_id",
            "prompt_grouping_key",
            "generation_decision_budget",
            "allowed_completion_token_set_sha256",
            "eos_available_at_every_decision",
            "target_independent_decision_budget",
        ],
        zeroShotRawFields: [
            "zero_shot_decisions_executed",
            "zero_shot_prediction",
            "zero_shot_prediction_token_ids",
            "zero_shot_mean_log_probability",
            "zero_shot_token_log_probabilities",
            "zero_shot_terminated_by_eos",
            "zero_shot_termination_reason",
            "zero_shot_utf8_valid",
            "zero_shot_eos_log_probability",
            "zero_shot_raw_full_vocabulary_allowed_support_greedy_token_parity",
            "zero_shot_disallowed_full_vocabulary_argmax_count",
            "zero_shot_maximum_disallowed_token_probability_mass",
            "zero_shot_latency_seconds",
        ],
        zeroShotRegradeFields: [
            "zero_shot_exact_match",
            "zero_shot_semantic_verifier_pass",
            "zero_shot_abstention_decision",
        ],
        trainedRawFields: [
            "trained_prediction",
            "trained_prediction_token_ids",
            "trained_mean_log_probability",
            "trained_token_log_probabilities",
            "trained_terminated_by_eos",
            "trained_termination_reason",
            "trained_utf8_valid",
            "trained_eos_log_probability",
            "trained_raw_full_vocabulary_allowed_support_greedy_token_parity",
            "trained_disallowed_full_vocabulary_argmax_count",
            "trained_maximum_disallowed_token_probability_mass",
            "trained_latency_seconds",
            "trained_decisions_executed",
        ],
        trainedRegradeFields: [
            "trained_exact_match",
            "trained_semantic_verifier_pass",
            "trained_abstention_decision",
        ],
        orderedRecordFields: [
            "row_id",
            "corpus_row_sha256",
            "evaluation_row_sha256",
            "split",
            "semantic_family",
            "invariant_ids",
            "mutation_id",
            "abstention_reason",
            "prompt",
            "prompt_token_ids",
            "target",
            "target_token_ids",
            "prompt_grouping_key_id",
            "prompt_grouping_key",
            "generation_decision_budget",
            "allowed_completion_token_set_sha256",
            "eos_available_at_every_decision",
            "target_independent_decision_budget",
            "zero_shot_decisions_executed",
            "zero_shot_prediction",
            "zero_shot_prediction_token_ids",
            "zero_shot_mean_log_probability",
            "zero_shot_token_log_probabilities",
            "zero_shot_terminated_by_eos",
            "zero_shot_termination_reason",
            "zero_shot_utf8_valid",
            "zero_shot_eos_log_probability",
            "zero_shot_raw_full_vocabulary_allowed_support_greedy_token_parity",
            "zero_shot_disallowed_full_vocabulary_argmax_count",
            "zero_shot_maximum_disallowed_token_probability_mass",
            "zero_shot_exact_match",
            "zero_shot_semantic_verifier_pass",
            "zero_shot_abstention_decision",
            "zero_shot_latency_seconds",
            "trained_prediction",
            "trained_prediction_token_ids",
            "trained_mean_log_probability",
            "trained_token_log_probabilities",
            "trained_terminated_by_eos",
            "trained_termination_reason",
            "trained_utf8_valid",
            "trained_eos_log_probability",
            "trained_raw_full_vocabulary_allowed_support_greedy_token_parity",
            "trained_disallowed_full_vocabulary_argmax_count",
            "trained_maximum_disallowed_token_probability_mass",
            "trained_exact_match",
            "trained_semantic_verifier_pass",
            "trained_abstention_decision",
            "trained_latency_seconds",
            "trained_decisions_executed",
        ]
    )

    public init(
        reportSchemaVersion: String,
        authorityFields: [String],
        generationContractBindingFields:
            [String],
        zeroShotRawFields: [String],
        zeroShotRegradeFields: [String],
        trainedRawFields: [String],
        trainedRegradeFields: [String],
        orderedRecordFields: [String]
    ) {
        self.reportSchemaVersion =
            reportSchemaVersion
        self.authorityFields = authorityFields
        self.generationContractBindingFields =
            generationContractBindingFields
        self.zeroShotRawFields = zeroShotRawFields
        self.zeroShotRegradeFields =
            zeroShotRegradeFields
        self.trainedRawFields = trainedRawFields
        self.trainedRegradeFields =
            trainedRegradeFields
        self.orderedRecordFields =
            orderedRecordFields
    }

    public func validateFrozenV1() throws {
        let partitions =
            authorityFields
            + generationContractBindingFields
            + zeroShotRawFields
            + zeroShotRegradeFields
            + trainedRawFields
            + trainedRegradeFields
        guard self == .frozenV1,
              Set(partitions).count == partitions.count,
              Set(partitions)
                == Set(orderedRecordFields),
              orderedRecordFields.count
                == partitions.count
        else {
            throw PrimeNativeGenerationContractProjectionError
                .invalidFieldProjection(
                    "schema-4 regrade"
                )
        }
    }

    private enum CodingKeys: String, CodingKey {
        case reportSchemaVersion =
            "report_schema_version"
        case authorityFields =
            "authority_fields"
        case generationContractBindingFields =
            "generation_contract_binding_fields"
        case zeroShotRawFields =
            "zero_shot_raw_fields"
        case zeroShotRegradeFields =
            "zero_shot_regrade_fields"
        case trainedRawFields =
            "trained_raw_fields"
        case trainedRegradeFields =
            "trained_regrade_fields"
        case orderedRecordFields =
            "ordered_record_fields"
    }
}

public struct PrimeNativeGenerationContractNonclaims:
    Codable,
    Equatable,
    Sendable
{
    public let companionSourceExecuted: Bool
    public let companionRuntimeDependencyAdded:
        Bool
    public let neuralKitExecuted: Bool
    public let modelExecuted: Bool
    public let logitsObserved: Bool
    public let greedyChoicesRecomputedFromLogits:
        Bool
    public let physicalGenerationShardsObserved:
        Bool
    public let generationBehaviorCompatibilityComplete:
        Bool
    public let corpusRowsRegenerated: Bool
    public let corpusSemanticRegradePerformed: Bool
    public let independentRegradeExecuted: Bool
    public let phaseThreeCompatibilityComplete: Bool
    public let trainingPerformed: Bool
    public let quantizationPerformed: Bool
    public let productPromotionAuthorized: Bool
    public let independentScientificOracleClaimed:
        Bool
    public let existingAdapterModified: Bool
    public let archiveExpanded: Bool
    public let donorExecuted: Bool

    public static let frozenV1 = Self(
        companionSourceExecuted: false,
        companionRuntimeDependencyAdded: false,
        neuralKitExecuted: false,
        modelExecuted: false,
        logitsObserved: false,
        greedyChoicesRecomputedFromLogits: false,
        physicalGenerationShardsObserved: false,
        generationBehaviorCompatibilityComplete: false,
        corpusRowsRegenerated: false,
        corpusSemanticRegradePerformed: false,
        independentRegradeExecuted: false,
        phaseThreeCompatibilityComplete: false,
        trainingPerformed: false,
        quantizationPerformed: false,
        productPromotionAuthorized: false,
        independentScientificOracleClaimed: false,
        existingAdapterModified: false,
        archiveExpanded: false,
        donorExecuted: false
    )

    public init(
        companionSourceExecuted: Bool,
        companionRuntimeDependencyAdded: Bool,
        neuralKitExecuted: Bool,
        modelExecuted: Bool,
        logitsObserved: Bool,
        greedyChoicesRecomputedFromLogits: Bool,
        physicalGenerationShardsObserved: Bool,
        generationBehaviorCompatibilityComplete:
            Bool,
        corpusRowsRegenerated: Bool,
        corpusSemanticRegradePerformed: Bool,
        independentRegradeExecuted: Bool,
        phaseThreeCompatibilityComplete: Bool,
        trainingPerformed: Bool,
        quantizationPerformed: Bool,
        productPromotionAuthorized: Bool,
        independentScientificOracleClaimed:
            Bool,
        existingAdapterModified: Bool,
        archiveExpanded: Bool,
        donorExecuted: Bool
    ) {
        self.companionSourceExecuted =
            companionSourceExecuted
        self.companionRuntimeDependencyAdded =
            companionRuntimeDependencyAdded
        self.neuralKitExecuted = neuralKitExecuted
        self.modelExecuted = modelExecuted
        self.logitsObserved = logitsObserved
        self.greedyChoicesRecomputedFromLogits =
            greedyChoicesRecomputedFromLogits
        self.physicalGenerationShardsObserved =
            physicalGenerationShardsObserved
        self
            .generationBehaviorCompatibilityComplete =
            generationBehaviorCompatibilityComplete
        self.corpusRowsRegenerated =
            corpusRowsRegenerated
        self.corpusSemanticRegradePerformed =
            corpusSemanticRegradePerformed
        self.independentRegradeExecuted =
            independentRegradeExecuted
        self.phaseThreeCompatibilityComplete =
            phaseThreeCompatibilityComplete
        self.trainingPerformed = trainingPerformed
        self.quantizationPerformed =
            quantizationPerformed
        self.productPromotionAuthorized =
            productPromotionAuthorized
        self.independentScientificOracleClaimed =
            independentScientificOracleClaimed
        self.existingAdapterModified =
            existingAdapterModified
        self.archiveExpanded = archiveExpanded
        self.donorExecuted = donorExecuted
    }

    public func validateFrozenV1() throws {
        guard self == .frozenV1 else {
            throw PrimeNativeGenerationContractProjectionError
                .invalidProjection(
                    "nonclaims"
                )
        }
    }

    private enum CodingKeys: String, CodingKey {
        case companionSourceExecuted =
            "companion_source_executed"
        case companionRuntimeDependencyAdded =
            "companion_runtime_dependency_added"
        case neuralKitExecuted =
            "neuralkit_executed"
        case modelExecuted = "model_executed"
        case logitsObserved = "logits_observed"
        case greedyChoicesRecomputedFromLogits =
            "greedy_choices_recomputed_from_logits"
        case physicalGenerationShardsObserved =
            "physical_generation_shards_observed"
        case generationBehaviorCompatibilityComplete =
            "generation_behavior_compatibility_complete"
        case corpusRowsRegenerated =
            "corpus_rows_regenerated"
        case corpusSemanticRegradePerformed =
            "corpus_semantic_regrade_performed"
        case independentRegradeExecuted =
            "independent_regrade_executed"
        case phaseThreeCompatibilityComplete =
            "phase_three_compatibility_complete"
        case trainingPerformed =
            "training_performed"
        case quantizationPerformed =
            "quantization_performed"
        case productPromotionAuthorized =
            "product_promotion_authorized"
        case independentScientificOracleClaimed =
            "independent_scientific_oracle_claimed"
        case existingAdapterModified =
            "existing_adapter_modified"
        case archiveExpanded =
            "archive_expanded"
        case donorExecuted = "donor_executed"
    }
}

/// Standalone, source-pinned projection of the exact historical operational
/// generation boundary. This is a contract artifact, not evidence that any
/// model produced compatible behavior.
public struct PrimeNativeGenerationContractProjection:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let artifactKind: String
    public let projectionID: String
    public let claimScope: String
    public let plan:
        PrimeNativeGenerationContractPlan
    public let generationContractID: String
    public let tokenizerID: String
    public let tokenizerManifestSHA256: String
    public let tokenizerVocabularySize: Int
    public let beginningOfSequenceTokenID: Int
    public let endOfSequenceTokenID: Int
    public let byteTokenLowerBound: Int
    public let byteTokenUpperBound: Int
    public let allowedCompletionTokenIDs: [Int]
    public let allowedCompletionTokenSetSerialization:
        String
    public let allowedCompletionTokenSetSHA256:
        String
    public let allowedSupportOrderOperational: Bool
    public let greedySelectionPolicy: String
    public let greedyComparatorExpression: String
    public let greedyEqualLogitTiePolicy: String
    public let rawFullVocabularyEqualLogitTiePolicy:
        String
    public let fullVocabularySupportAuditRequired:
        Bool
    public let fullVocabularyWitness:
        PrimeNativeGenerationFullVocabularyWitnessProjection
    public let selectedTokenLogProbabilityPolicy:
        String
    public let allowedSupportRenormalizationApplied:
        Bool
    public let terminatedBatchFillerTokenPolicy:
        String
    public let kvCacheMechanics:
        PrimeNativeGenerationKVCacheMechanicsProjection
    public let promptGroupingKeyID: String
    public let maximumGenerationTokenDecisions:
        Int
    public let targetIndependentDecisionBudget:
        Bool
    public let eosAvailableAtEveryDecision: Bool
    public let eosTerminationReason: String
    public let fixedCapTerminationReason: String
    public let eosCountsAsExecutedDecision: Bool
    public let eosExcludedFromGeneratedTokenIDs:
        Bool
    public let meanLogProbabilityPolicy: String
    public let immediateEOSMeanPolicy: String
    public let invalidUTF8EvidencePolicy: String
    public let generatedTextComparisonPolicy:
        String
    public let primeByteExactGeneratedTextHardeningApplied:
        Bool
    public let optionalNilKeyEncoding: String
    public let optionalDecoderMissingAndNullEquivalent:
        Bool
    public let donorUnknownKeyDecodingPolicy: String
    public let primeStrictRawValidatorUnknownKeyPolicy:
        String
    public let logProbabilityValidationPolicy: String
    public let primeNonPositiveLogProbabilityHardeningApplied:
        Bool
    public let promptOnlyFields:
        PrimeNativeGenerationPromptOnlyFieldProjection
    public let rawShardFields:
        PrimeNativeGenerationRawShardFieldProjection
    public let schema4RegradeFields:
        PrimeNativeGenerationSchema4RegradeFieldProjection
    public let exactOperationalSemanticsSourcePinned:
        Bool
    public let standaloneProjectionComplete: Bool
    public let existingAdapterFixedCapEOSGenerationContractBound:
        Bool
    public let nonclaims:
        PrimeNativeGenerationContractNonclaims
    public let nextMissingPrerequisite: String

    public static let frozenV1 = Self(
        schemaVersion: 1,
        artifactKind:
            "prime_native_fixed_cap_eos_kv_v2_generation_contract_projection",
        projectionID:
            "ergentics_prime_native_fixed_cap_eos_kv_v2_generation_contract_projection_v1",
        claimScope:
            PrimeNativeGenerationContractPlan
            .frozenV1.claimScope,
        plan: .frozenV1,
        generationContractID:
            "greedy_native_bytes_eos_fixed_cap64_kv_v2",
        tokenizerID:
            PrimeNativeByteTokenizer.tokenizerID,
        tokenizerManifestSHA256:
            "f9f768268edb488aaf7168453b703f2d2a78a1036572368c76f53f4f436434c7",
        tokenizerVocabularySize:
            PrimeNativeByteTokenizer
            .boundModelVocabularySize,
        beginningOfSequenceTokenID:
            PrimeNativeByteTokenizer
            .beginningOfSequenceTokenID,
        endOfSequenceTokenID:
            PrimeNativeByteTokenizer
            .endOfSequenceTokenID,
        byteTokenLowerBound:
            PrimeNativeByteTokenizer
            .byteTokenRange.lowerBound,
        byteTokenUpperBound:
            PrimeNativeByteTokenizer
            .byteTokenRange.upperBound,
        allowedCompletionTokenIDs:
            [
                PrimeNativeByteTokenizer
                    .endOfSequenceTokenID,
            ] + Array(
                PrimeNativeByteTokenizer
                    .byteTokenRange
            ),
        allowedCompletionTokenSetSerialization:
            "decimal_token_ids_joined_by_lf_without_trailing_lf_v1",
        allowedCompletionTokenSetSHA256:
            "e3c1f6e4fc7b0329c2df97af2a32bff273d5534d7ccf54eaa1ef00b78b0d1768",
        allowedSupportOrderOperational: true,
        greedySelectionPolicy:
            "argmax_over_ordered_allowed_support_from_full_vocabulary_logits_v1",
        greedyComparatorExpression:
            "score[left] < score[right]",
        greedyEqualLogitTiePolicy:
            "first_ordered_support_entry_wins_equal_logit_tie_eos70_v1",
        rawFullVocabularyEqualLogitTiePolicy:
            "first_vocabulary_token_wins_equal_logit_tie_token0_v1",
        fullVocabularySupportAuditRequired:
            true,
        fullVocabularyWitness: .frozenV1,
        selectedTokenLogProbabilityPolicy:
            "selected_allowed_token_log_probability_from_full_512_token_logsoftmax_v1",
        allowedSupportRenormalizationApplied:
            false,
        terminatedBatchFillerTokenPolicy:
            "eos_filler_for_subsequent_batch_cache_steps_with_later_logits_ignored_v1",
        kvCacheMechanics: .frozenV1,
        promptGroupingKeyID:
            "prompt_byte_token_count_excluding_bos_v1",
        maximumGenerationTokenDecisions: 64,
        targetIndependentDecisionBudget: true,
        eosAvailableAtEveryDecision: true,
        eosTerminationReason: "eos",
        fixedCapTerminationReason: "fixed_cap",
        eosCountsAsExecutedDecision: true,
        eosExcludedFromGeneratedTokenIDs: true,
        meanLogProbabilityPolicy:
            "arithmetic_mean_of_all_executed_decision_log_probabilities_including_eos_v1",
        immediateEOSMeanPolicy:
            "single_eos_log_probability_is_mean_v1",
        invalidUTF8EvidencePolicy:
            "preserve_token_ids_with_nil_text_and_utf8_valid_false_v1",
        generatedTextComparisonPolicy:
            "swift_string_canonical_equivalence_against_utf8_decoded_token_bytes_v1",
        primeByteExactGeneratedTextHardeningApplied:
            false,
        optionalNilKeyEncoding: "omitted",
        optionalDecoderMissingAndNullEquivalent:
            true,
        donorUnknownKeyDecodingPolicy: "ignored",
        primeStrictRawValidatorUnknownKeyPolicy:
            "rejected",
        logProbabilityValidationPolicy:
            "finite_only_v1",
        primeNonPositiveLogProbabilityHardeningApplied:
            false,
        promptOnlyFields: .frozenV1,
        rawShardFields: .frozenV1,
        schema4RegradeFields: .frozenV1,
        exactOperationalSemanticsSourcePinned:
            true,
        standaloneProjectionComplete: true,
        existingAdapterFixedCapEOSGenerationContractBound:
            false,
        nonclaims: .frozenV1,
        nextMissingPrerequisite:
            "source_pinned_full_swift_corpus_generator_transplant_replay"
    )

    public init(
        schemaVersion: Int,
        artifactKind: String,
        projectionID: String,
        claimScope: String,
        plan: PrimeNativeGenerationContractPlan,
        generationContractID: String,
        tokenizerID: String,
        tokenizerManifestSHA256: String,
        tokenizerVocabularySize: Int,
        beginningOfSequenceTokenID: Int,
        endOfSequenceTokenID: Int,
        byteTokenLowerBound: Int,
        byteTokenUpperBound: Int,
        allowedCompletionTokenIDs: [Int],
        allowedCompletionTokenSetSerialization:
            String,
        allowedCompletionTokenSetSHA256: String,
        allowedSupportOrderOperational: Bool,
        greedySelectionPolicy: String,
        greedyComparatorExpression: String,
        greedyEqualLogitTiePolicy: String,
        rawFullVocabularyEqualLogitTiePolicy:
            String,
        fullVocabularySupportAuditRequired:
            Bool,
        fullVocabularyWitness:
            PrimeNativeGenerationFullVocabularyWitnessProjection,
        selectedTokenLogProbabilityPolicy:
            String,
        allowedSupportRenormalizationApplied:
            Bool,
        terminatedBatchFillerTokenPolicy:
            String,
        kvCacheMechanics:
            PrimeNativeGenerationKVCacheMechanicsProjection,
        promptGroupingKeyID: String,
        maximumGenerationTokenDecisions: Int,
        targetIndependentDecisionBudget: Bool,
        eosAvailableAtEveryDecision: Bool,
        eosTerminationReason: String,
        fixedCapTerminationReason: String,
        eosCountsAsExecutedDecision: Bool,
        eosExcludedFromGeneratedTokenIDs: Bool,
        meanLogProbabilityPolicy: String,
        immediateEOSMeanPolicy: String,
        invalidUTF8EvidencePolicy: String,
        generatedTextComparisonPolicy: String,
        primeByteExactGeneratedTextHardeningApplied:
            Bool,
        optionalNilKeyEncoding: String,
        optionalDecoderMissingAndNullEquivalent:
            Bool,
        donorUnknownKeyDecodingPolicy: String,
        primeStrictRawValidatorUnknownKeyPolicy:
            String,
        logProbabilityValidationPolicy: String,
        primeNonPositiveLogProbabilityHardeningApplied:
            Bool,
        promptOnlyFields:
            PrimeNativeGenerationPromptOnlyFieldProjection,
        rawShardFields:
            PrimeNativeGenerationRawShardFieldProjection,
        schema4RegradeFields:
            PrimeNativeGenerationSchema4RegradeFieldProjection,
        exactOperationalSemanticsSourcePinned:
            Bool,
        standaloneProjectionComplete: Bool,
        existingAdapterFixedCapEOSGenerationContractBound:
            Bool,
        nonclaims:
            PrimeNativeGenerationContractNonclaims,
        nextMissingPrerequisite: String
    ) {
        self.schemaVersion = schemaVersion
        self.artifactKind = artifactKind
        self.projectionID = projectionID
        self.claimScope = claimScope
        self.plan = plan
        self.generationContractID =
            generationContractID
        self.tokenizerID = tokenizerID
        self.tokenizerManifestSHA256 =
            tokenizerManifestSHA256
        self.tokenizerVocabularySize =
            tokenizerVocabularySize
        self.beginningOfSequenceTokenID =
            beginningOfSequenceTokenID
        self.endOfSequenceTokenID =
            endOfSequenceTokenID
        self.byteTokenLowerBound =
            byteTokenLowerBound
        self.byteTokenUpperBound =
            byteTokenUpperBound
        self.allowedCompletionTokenIDs =
            allowedCompletionTokenIDs
        self.allowedCompletionTokenSetSerialization =
            allowedCompletionTokenSetSerialization
        self.allowedCompletionTokenSetSHA256 =
            allowedCompletionTokenSetSHA256
        self.allowedSupportOrderOperational =
            allowedSupportOrderOperational
        self.greedySelectionPolicy =
            greedySelectionPolicy
        self.greedyComparatorExpression =
            greedyComparatorExpression
        self.greedyEqualLogitTiePolicy =
            greedyEqualLogitTiePolicy
        self.rawFullVocabularyEqualLogitTiePolicy =
            rawFullVocabularyEqualLogitTiePolicy
        self.fullVocabularySupportAuditRequired =
            fullVocabularySupportAuditRequired
        self.fullVocabularyWitness =
            fullVocabularyWitness
        self.selectedTokenLogProbabilityPolicy =
            selectedTokenLogProbabilityPolicy
        self.allowedSupportRenormalizationApplied =
            allowedSupportRenormalizationApplied
        self.terminatedBatchFillerTokenPolicy =
            terminatedBatchFillerTokenPolicy
        self.kvCacheMechanics = kvCacheMechanics
        self.promptGroupingKeyID =
            promptGroupingKeyID
        self.maximumGenerationTokenDecisions =
            maximumGenerationTokenDecisions
        self.targetIndependentDecisionBudget =
            targetIndependentDecisionBudget
        self.eosAvailableAtEveryDecision =
            eosAvailableAtEveryDecision
        self.eosTerminationReason =
            eosTerminationReason
        self.fixedCapTerminationReason =
            fixedCapTerminationReason
        self.eosCountsAsExecutedDecision =
            eosCountsAsExecutedDecision
        self.eosExcludedFromGeneratedTokenIDs =
            eosExcludedFromGeneratedTokenIDs
        self.meanLogProbabilityPolicy =
            meanLogProbabilityPolicy
        self.immediateEOSMeanPolicy =
            immediateEOSMeanPolicy
        self.invalidUTF8EvidencePolicy =
            invalidUTF8EvidencePolicy
        self.generatedTextComparisonPolicy =
            generatedTextComparisonPolicy
        self
            .primeByteExactGeneratedTextHardeningApplied =
            primeByteExactGeneratedTextHardeningApplied
        self.optionalNilKeyEncoding =
            optionalNilKeyEncoding
        self.optionalDecoderMissingAndNullEquivalent =
            optionalDecoderMissingAndNullEquivalent
        self.donorUnknownKeyDecodingPolicy =
            donorUnknownKeyDecodingPolicy
        self.primeStrictRawValidatorUnknownKeyPolicy =
            primeStrictRawValidatorUnknownKeyPolicy
        self.logProbabilityValidationPolicy =
            logProbabilityValidationPolicy
        self
            .primeNonPositiveLogProbabilityHardeningApplied =
            primeNonPositiveLogProbabilityHardeningApplied
        self.promptOnlyFields = promptOnlyFields
        self.rawShardFields = rawShardFields
        self.schema4RegradeFields =
            schema4RegradeFields
        self.exactOperationalSemanticsSourcePinned =
            exactOperationalSemanticsSourcePinned
        self.standaloneProjectionComplete =
            standaloneProjectionComplete
        self
            .existingAdapterFixedCapEOSGenerationContractBound =
            existingAdapterFixedCapEOSGenerationContractBound
        self.nonclaims = nonclaims
        self.nextMissingPrerequisite =
            nextMissingPrerequisite
    }

    public static func allowedCompletionTokenSetSHA256(
        _ tokenIDs: [Int]
    ) -> String {
        let material = tokenIDs
            .map(String.init)
            .joined(separator: "\n")
        return PrimeSHA256.hexDigest(
            of: Data(material.utf8)
        )
    }

    public func validate() throws {
        try plan.validate()
        try promptOnlyFields.validateFrozenV1()
        try kvCacheMechanics.validateFrozenV1()
        try fullVocabularyWitness
            .validateFrozenV1()
        try rawShardFields.validateFrozenV1()
        try schema4RegradeFields
            .validateFrozenV1()
        try nonclaims.validateFrozenV1()
        let expectedSupport = [
            PrimeNativeByteTokenizer
                .endOfSequenceTokenID,
        ] + Array(
            PrimeNativeByteTokenizer.byteTokenRange
        )
        guard self == .frozenV1,
              plan.sourceBindings.count == 3,
              exactOperationalSemanticsSourcePinned,
              standaloneProjectionComplete,
              !existingAdapterFixedCapEOSGenerationContractBound,
              generationContractID
                == "greedy_native_bytes_eos_fixed_cap64_kv_v2",
              tokenizerID
                == PrimeNativeByteTokenizer.tokenizerID,
              tokenizerVocabularySize
                == PrimeNativeByteTokenizer
                .boundModelVocabularySize,
              beginningOfSequenceTokenID
                == PrimeNativeByteTokenizer
                .beginningOfSequenceTokenID,
              endOfSequenceTokenID
                == PrimeNativeByteTokenizer
                .endOfSequenceTokenID,
              byteTokenLowerBound
                == PrimeNativeByteTokenizer
                .byteTokenRange.lowerBound,
              byteTokenUpperBound
                == PrimeNativeByteTokenizer
                .byteTokenRange.upperBound,
              allowedCompletionTokenIDs
                == expectedSupport,
              Set(allowedCompletionTokenIDs).count
                == allowedCompletionTokenIDs.count,
              Self.allowedCompletionTokenSetSHA256(
                  allowedCompletionTokenIDs
              ) == allowedCompletionTokenSetSHA256,
              maximumGenerationTokenDecisions == 64,
              targetIndependentDecisionBudget,
              eosAvailableAtEveryDecision,
              eosCountsAsExecutedDecision,
              eosExcludedFromGeneratedTokenIDs,
              fullVocabularySupportAuditRequired,
              !fullVocabularyWitness
                .witnessValuesRecomputedFromLogits,
              selectedTokenLogProbabilityPolicy
                == "selected_allowed_token_log_probability_from_full_512_token_logsoftmax_v1",
              !allowedSupportRenormalizationApplied,
              terminatedBatchFillerTokenPolicy
                == "eos_filler_for_subsequent_batch_cache_steps_with_later_logits_ignored_v1",
              generatedTextComparisonPolicy
                == "swift_string_canonical_equivalence_against_utf8_decoded_token_bytes_v1",
              !primeByteExactGeneratedTextHardeningApplied,
              optionalNilKeyEncoding == "omitted",
              optionalDecoderMissingAndNullEquivalent,
              donorUnknownKeyDecodingPolicy
                == "ignored",
              primeStrictRawValidatorUnknownKeyPolicy
                == "rejected",
              logProbabilityValidationPolicy
                == "finite_only_v1",
              !primeNonPositiveLogProbabilityHardeningApplied
        else {
            throw PrimeNativeGenerationContractProjectionError
                .invalidProjection(
                    "frozen operational contract"
                )
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case artifactKind = "artifact_kind"
        case projectionID = "projection_id"
        case claimScope = "claim_scope"
        case plan
        case generationContractID =
            "generation_contract_id"
        case tokenizerID = "tokenizer_id"
        case tokenizerManifestSHA256 =
            "tokenizer_manifest_sha256"
        case tokenizerVocabularySize =
            "tokenizer_vocabulary_size"
        case beginningOfSequenceTokenID =
            "beginning_of_sequence_token_id"
        case endOfSequenceTokenID =
            "end_of_sequence_token_id"
        case byteTokenLowerBound =
            "byte_token_lower_bound"
        case byteTokenUpperBound =
            "byte_token_upper_bound"
        case allowedCompletionTokenIDs =
            "allowed_completion_token_ids"
        case allowedCompletionTokenSetSerialization =
            "allowed_completion_token_set_serialization"
        case allowedCompletionTokenSetSHA256 =
            "allowed_completion_token_set_sha256"
        case allowedSupportOrderOperational =
            "allowed_support_order_operational"
        case greedySelectionPolicy =
            "greedy_selection_policy"
        case greedyComparatorExpression =
            "greedy_comparator_expression"
        case greedyEqualLogitTiePolicy =
            "greedy_equal_logit_tie_policy"
        case rawFullVocabularyEqualLogitTiePolicy =
            "raw_full_vocabulary_equal_logit_tie_policy"
        case fullVocabularySupportAuditRequired =
            "full_vocabulary_support_audit_required"
        case fullVocabularyWitness =
            "full_vocabulary_witness"
        case selectedTokenLogProbabilityPolicy =
            "selected_token_log_probability_policy"
        case allowedSupportRenormalizationApplied =
            "allowed_support_renormalization_applied"
        case terminatedBatchFillerTokenPolicy =
            "terminated_batch_filler_token_policy"
        case kvCacheMechanics =
            "kv_cache_mechanics"
        case promptGroupingKeyID =
            "prompt_grouping_key_id"
        case maximumGenerationTokenDecisions =
            "maximum_generation_token_decisions"
        case targetIndependentDecisionBudget =
            "target_independent_decision_budget"
        case eosAvailableAtEveryDecision =
            "eos_available_at_every_decision"
        case eosTerminationReason =
            "eos_termination_reason"
        case fixedCapTerminationReason =
            "fixed_cap_termination_reason"
        case eosCountsAsExecutedDecision =
            "eos_counts_as_executed_decision"
        case eosExcludedFromGeneratedTokenIDs =
            "eos_excluded_from_generated_token_ids"
        case meanLogProbabilityPolicy =
            "mean_log_probability_policy"
        case immediateEOSMeanPolicy =
            "immediate_eos_mean_policy"
        case invalidUTF8EvidencePolicy =
            "invalid_utf8_evidence_policy"
        case generatedTextComparisonPolicy =
            "generated_text_comparison_policy"
        case primeByteExactGeneratedTextHardeningApplied =
            "prime_byte_exact_generated_text_hardening_applied"
        case optionalNilKeyEncoding =
            "optional_nil_key_encoding"
        case optionalDecoderMissingAndNullEquivalent =
            "optional_decoder_missing_and_null_equivalent"
        case donorUnknownKeyDecodingPolicy =
            "donor_unknown_key_decoding_policy"
        case primeStrictRawValidatorUnknownKeyPolicy =
            "prime_strict_raw_validator_unknown_key_policy"
        case logProbabilityValidationPolicy =
            "log_probability_validation_policy"
        case primeNonPositiveLogProbabilityHardeningApplied =
            "prime_non_positive_log_probability_hardening_applied"
        case promptOnlyFields =
            "prompt_only_fields"
        case rawShardFields = "raw_shard_fields"
        case schema4RegradeFields =
            "schema4_regrade_fields"
        case exactOperationalSemanticsSourcePinned =
            "exact_operational_semantics_source_pinned"
        case standaloneProjectionComplete =
            "standalone_projection_complete"
        case existingAdapterFixedCapEOSGenerationContractBound =
            "existing_adapter_fixed_cap_eos_generation_contract_bound"
        case nonclaims
        case nextMissingPrerequisite =
            "next_missing_prerequisite"
    }
}

public enum PrimeNativeHistoricalGenerationTermination:
    String,
    Codable,
    Equatable,
    Sendable
{
    case eos
    case fixedCap = "fixed_cap"
}

private struct PrimeNativeGenerationDynamicCodingKey:
    CodingKey
{
    let stringValue: String
    let intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
        intValue = nil
    }

    init?(intValue: Int) {
        stringValue = String(intValue)
        self.intValue = intValue
    }
}

/// Exact row-level `Generated` shape from the historical schema-2 shard,
/// with schema-4 decision-count semantics derived rather than trusted.
///
/// Invalid UTF-8 is preserved as token evidence with `text == nil` and
/// `utf8Valid == false`. It is not discarded at the transport boundary.
public struct PrimeNativeHistoricalRawGenerationObservation:
    Codable,
    Equatable,
    Sendable
{
    public static let meanTolerance = 1e-12

    public let text: String?
    public let tokenIDs: [Int]
    public let tokenLogProbabilities: [Double]
    public let meanLogProbability: Double
    public let terminatedByEOS: Bool
    public let terminationReason:
        PrimeNativeHistoricalGenerationTermination
    public let utf8Valid: Bool
    public let eosLogProbability: Double?
    public let rawFullVocabularyAllowedSupportGreedyTokenParity:
        Bool
    public let disallowedFullVocabularyArgmaxCount:
        Int
    public let maximumDisallowedTokenProbabilityMass:
        Double
    public let latencySeconds: Double

    public var decisionsExecuted: Int {
        tokenIDs.count + (terminatedByEOS ? 1 : 0)
    }

    public init(
        text: String?,
        tokenIDs: [Int],
        tokenLogProbabilities: [Double],
        meanLogProbability: Double,
        terminatedByEOS: Bool,
        terminationReason:
            PrimeNativeHistoricalGenerationTermination,
        utf8Valid: Bool,
        eosLogProbability: Double?,
        rawFullVocabularyAllowedSupportGreedyTokenParity:
            Bool,
        disallowedFullVocabularyArgmaxCount:
            Int,
        maximumDisallowedTokenProbabilityMass:
            Double,
        latencySeconds: Double
    ) throws {
        self.text = text
        self.tokenIDs = tokenIDs
        self.tokenLogProbabilities =
            tokenLogProbabilities
        self.meanLogProbability =
            meanLogProbability
        self.terminatedByEOS = terminatedByEOS
        self.terminationReason =
            terminationReason
        self.utf8Valid = utf8Valid
        self.eosLogProbability =
            eosLogProbability
        self
            .rawFullVocabularyAllowedSupportGreedyTokenParity =
            rawFullVocabularyAllowedSupportGreedyTokenParity
        self.disallowedFullVocabularyArgmaxCount =
            disallowedFullVocabularyArgmaxCount
        self.maximumDisallowedTokenProbabilityMass =
            maximumDisallowedTokenProbabilityMass
        self.latencySeconds = latencySeconds
        try validate()
    }

    public func validate(
        declaredDecisionsExecuted: Int? = nil
    ) throws {
        let budget =
            PrimeNativeGenerationContractProjection
            .frozenV1
            .maximumGenerationTokenDecisions
        guard tokenIDs.allSatisfy({
            PrimeNativeByteTokenizer.byteTokenRange
                .contains($0)
        }) else {
            throw PrimeNativeGenerationContractProjectionError
                .invalidRawGenerationObservation(
                    "generated token outside byte support"
                )
        }
        guard tokenLogProbabilities.count
                == tokenIDs.count,
              tokenLogProbabilities
                .allSatisfy(\.isFinite),
              meanLogProbability.isFinite
        else {
            throw PrimeNativeGenerationContractProjectionError
                .invalidRawGenerationObservation(
                    "log-probability shape or finiteness"
                )
        }
        switch terminationReason {
        case .eos:
            guard terminatedByEOS,
                  tokenIDs.count < budget,
                  eosLogProbability?.isFinite == true
            else {
                throw PrimeNativeGenerationContractProjectionError
                    .invalidRawGenerationObservation(
                        "EOS termination"
                    )
            }
        case .fixedCap:
            guard !terminatedByEOS,
                  tokenIDs.count == budget,
                  eosLogProbability == nil
            else {
                throw PrimeNativeGenerationContractProjectionError
                    .invalidRawGenerationObservation(
                        "fixed-cap termination"
                    )
            }
        }
        guard decisionsExecuted >= 1,
              decisionsExecuted <= budget,
              declaredDecisionsExecuted
                .map({ $0 == decisionsExecuted })
                ?? true
        else {
            throw PrimeNativeGenerationContractProjectionError
                .invalidRawGenerationObservation(
                    "executed decision count"
                )
        }
        var executed =
            tokenLogProbabilities
        if let eosLogProbability {
            executed.append(eosLogProbability)
        }
        let sum = executed.reduce(0, +)
        let expectedMean =
            sum / Double(executed.count)
        guard sum.isFinite,
              expectedMean.isFinite,
              abs(
                  meanLogProbability - expectedMean
              ) <= Self.meanTolerance
        else {
            throw PrimeNativeGenerationContractProjectionError
                .invalidRawGenerationObservation(
                    "executed-decision mean"
                )
        }
        let bytes: [UInt8]
        do {
            bytes = try tokenIDs.map {
                try PrimeNativeByteTokenizer.byte(
                    forTokenID: $0
                )
            }
        } catch {
            throw PrimeNativeGenerationContractProjectionError
                .invalidRawGenerationObservation(
                    "byte decode"
                )
        }
        let decoded = String(
            data: Data(bytes),
            encoding: .utf8
        )
        if utf8Valid {
            guard decoded != nil,
                  let text,
                  text == decoded
            else {
                throw PrimeNativeGenerationContractProjectionError
                    .invalidRawGenerationObservation(
                        "valid UTF-8 evidence"
                    )
            }
        } else {
            guard decoded == nil,
                  text == nil else {
                throw PrimeNativeGenerationContractProjectionError
                    .invalidRawGenerationObservation(
                        "invalid UTF-8 evidence"
                    )
            }
        }
        guard disallowedFullVocabularyArgmaxCount
                >= 0,
              disallowedFullVocabularyArgmaxCount
                <= decisionsExecuted,
              rawFullVocabularyAllowedSupportGreedyTokenParity
                == (
                    disallowedFullVocabularyArgmaxCount
                        == 0
                ),
              maximumDisallowedTokenProbabilityMass
                .isFinite,
              maximumDisallowedTokenProbabilityMass
                >= 0,
              maximumDisallowedTokenProbabilityMass
                <= 1.000_001
        else {
            throw PrimeNativeGenerationContractProjectionError
                .invalidRawGenerationObservation(
                    "full-vocabulary support witness"
                )
        }
        guard latencySeconds.isFinite,
              latencySeconds > 0 else {
            throw PrimeNativeGenerationContractProjectionError
                .invalidRawGenerationObservation(
                    "positive finite latency"
                )
        }
    }

    public init(from decoder: Decoder) throws {
        let dynamic = try decoder.container(
            keyedBy:
                PrimeNativeGenerationDynamicCodingKey
                .self
        )
        let admitted = Set(
            CodingKeys.allCases.map(\.rawValue)
        )
        let unknown = dynamic.allKeys
            .map(\.stringValue)
            .filter { !admitted.contains($0) }
            .sorted()
        guard unknown.isEmpty else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: decoder.codingPath,
                    debugDescription:
                        "unadmitted raw generation keys: \(unknown.joined(separator: ", "))"
                )
            )
        }
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )
        self = try Self(
            text: container.decodeIfPresent(
                String.self,
                forKey: .text
            ),
            tokenIDs: container.decode(
                [Int].self,
                forKey: .tokenIDs
            ),
            tokenLogProbabilities:
                container.decode(
                    [Double].self,
                    forKey:
                        .tokenLogProbabilities
                ),
            meanLogProbability:
                container.decode(
                    Double.self,
                    forKey: .meanLogProbability
                ),
            terminatedByEOS:
                container.decode(
                    Bool.self,
                    forKey: .terminatedByEOS
                ),
            terminationReason:
                container.decode(
                    PrimeNativeHistoricalGenerationTermination
                        .self,
                    forKey: .terminationReason
                ),
            utf8Valid: container.decode(
                Bool.self,
                forKey: .utf8Valid
            ),
            eosLogProbability:
                container.decodeIfPresent(
                    Double.self,
                    forKey: .eosLogProbability
                ),
            rawFullVocabularyAllowedSupportGreedyTokenParity:
                container.decode(
                    Bool.self,
                    forKey:
                        .rawFullVocabularyAllowedSupportGreedyTokenParity
                ),
            disallowedFullVocabularyArgmaxCount:
                container.decode(
                    Int.self,
                    forKey:
                        .disallowedFullVocabularyArgmaxCount
                ),
            maximumDisallowedTokenProbabilityMass:
                container.decode(
                    Double.self,
                    forKey:
                        .maximumDisallowedTokenProbabilityMass
                ),
            latencySeconds: container.decode(
                Double.self,
                forKey: .latencySeconds
            )
        )
    }

    private enum CodingKeys:
        String,
        CodingKey,
        CaseIterable
    {
        case text
        case tokenIDs
        case tokenLogProbabilities
        case meanLogProbability
        case terminatedByEOS
        case terminationReason
        case utf8Valid
        case eosLogProbability
        case rawFullVocabularyAllowedSupportGreedyTokenParity =
            "rawFullVocabularyAllowedSupportGreedyTokenParity"
        case disallowedFullVocabularyArgmaxCount =
            "disallowedFullVocabularyArgmaxCount"
        case maximumDisallowedTokenProbabilityMass =
            "maximumDisallowedTokenProbabilityMass"
        case latencySeconds
    }
}

public enum PrimeNativeGenerationContractMutation:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Sendable
{
    case sourcePinSetDrift =
        "source_pin_set_drift"
    case sourcePathDrift =
        "source_path_drift"
    case sourceBlobOIDDrift =
        "source_blob_oid_drift"
    case sourceSHA256Drift =
        "source_sha256_drift"
    case sourceByteCountDrift =
        "source_byte_count_drift"
    case sourceBlobResolutionOverclaim =
        "source_blob_resolution_overclaim"
    case freshVerifierIdentityPolicyDrift =
        "fresh_verifier_identity_policy_drift"
    case parentAdapterReceiptBindingDrift =
        "parent_adapter_receipt_binding_drift"
    case generationContractIDDrift =
        "generation_contract_id_drift"
    case promptGroupingIDDrift =
        "prompt_grouping_id_drift"
    case allowedSupportDrift =
        "allowed_support_drift"
    case allowedSupportHashDrift =
        "allowed_support_hash_drift"
    case asciiConstrainedSupport =
        "ascii_constrained_support"
    case allowedSupportTieRuleDrift =
        "allowed_support_tie_rule_drift"
    case rawFullVocabularyTieRuleDrift =
        "raw_full_vocabulary_tie_rule_drift"
    case selectedLogProbabilityPolicyDrift =
        "selected_log_probability_policy_drift"
    case fullVocabularyLogSoftmaxPrecisionDrift =
        "full_vocabulary_logsoftmax_precision_drift"
    case disallowedProbabilityMassComputationDrift =
        "disallowed_probability_mass_computation_drift"
    case fullVocabularyWitnessObservationOverclaim =
        "full_vocabulary_witness_observation_overclaim"
    case terminatedBatchFillerPolicyDrift =
        "terminated_batch_filler_policy_drift"
    case cachedPromptPrefillPolicyDrift =
        "cached_prompt_prefill_policy_drift"
    case cachedDecodeStepWidthDrift =
        "cached_decode_step_width_drift"
    case batchGeometryGuardRemoved =
        "batch_geometry_guard_removed"
    case contextCapacityGuardRemoved =
        "context_capacity_guard_removed"
    case cacheParityFixtureDrift =
        "cache_parity_fixture_drift"
    case singleStepCacheParityThresholdDrift =
        "single_step_cache_parity_threshold_drift"
    case multiStepCacheParityThresholdDrift =
        "multi_step_cache_parity_threshold_drift"
    case multiStepCacheParityDecisionCountDrift =
        "multi_step_cache_parity_decision_count_drift"
    case multiStepUnevenEOSRequirementRemoved =
        "multi_step_uneven_eos_requirement_removed"
    case cacheParityObservationOverclaim =
        "cache_parity_observation_overclaim"
    case generatedTextComparisonPolicyDrift =
        "generated_text_comparison_policy_drift"
    case promptTargetLeakage =
        "prompt_target_leakage"
    case targetDependentPromptGrouping =
        "target_dependent_prompt_grouping"
    case targetDependentDecisionBudget =
        "target_dependent_decision_budget"
    case decisionBudgetUpperDrift =
        "decision_budget_upper_drift"
    case eosUnavailable = "eos_unavailable"
    case shortFixedCap = "short_fixed_cap"
    case terminationInconsistency =
        "termination_inconsistency"
    case immediateEOSMeanOmission =
        "immediate_eos_mean_omission"
    case invalidUTF8EvidenceErasure =
        "invalid_utf8_evidence_erasure"
    case decisionLogProbabilityCountMismatch =
        "decision_log_probability_count_mismatch"
    case supportWitnessInconsistency =
        "support_witness_inconsistency"
    case zeroLatency =
        "zero_latency"
    case optionalNilPolicyDrift =
        "optional_nil_policy_drift"
    case rawShardFieldListDrift =
        "raw_shard_field_list_drift"
    case schema4FieldListDrift =
        "schema4_field_list_drift"
    case regradeAuthorityLeakage =
        "regrade_authority_leakage"
    case projectionAuthorityExpansion =
        "projection_authority_expansion"

    public var detectorID: String {
        switch self {
        case .sourcePinSetDrift:
            "three_source_operational_semantics_pin_gate_v1"
        case .sourcePathDrift:
            "source_path_identity_gate_v1"
        case .sourceBlobOIDDrift:
            "source_git_blob_identity_gate_v1"
        case .sourceSHA256Drift:
            "source_sha256_identity_gate_v1"
        case .sourceByteCountDrift:
            "source_byte_count_identity_gate_v1"
        case .sourceBlobResolutionOverclaim:
            "declared_lineage_not_runtime_resolved_gate_v1"
        case .freshVerifierIdentityPolicyDrift:
            "same_source_release_verifier_identity_gate_v1"
        case .parentAdapterReceiptBindingDrift:
            "parent_adapter_receipt_binding_gate_v1"
        case .generationContractIDDrift:
            "generation_contract_id_gate_v1"
        case .promptGroupingIDDrift:
            "prompt_grouping_id_gate_v1"
        case .allowedSupportDrift:
            "ordered_allowed_support_gate_v1"
        case .allowedSupportHashDrift:
            "allowed_support_hash_recompute_v1"
        case .asciiConstrainedSupport:
            "unconstrained_byte_support_gate_v1"
        case .allowedSupportTieRuleDrift:
            "ordered_support_tie_rule_gate_v1"
        case .rawFullVocabularyTieRuleDrift:
            "raw_full_vocabulary_tie_rule_gate_v1"
        case .selectedLogProbabilityPolicyDrift:
            "full_vocabulary_logsoftmax_policy_gate_v1"
        case .fullVocabularyLogSoftmaxPrecisionDrift:
            "full_vocabulary_float32_logsoftmax_precision_gate_v1"
        case .disallowedProbabilityMassComputationDrift:
            "disallowed_probability_mass_computation_gate_v1"
        case .fullVocabularyWitnessObservationOverclaim:
            "full_vocabulary_witness_nonobservation_gate_v1"
        case .terminatedBatchFillerPolicyDrift:
            "terminated_batch_eos_filler_policy_gate_v1"
        case .cachedPromptPrefillPolicyDrift:
            "cached_prompt_prefill_policy_gate_v1"
        case .cachedDecodeStepWidthDrift:
            "cached_one_token_decode_step_gate_v1"
        case .batchGeometryGuardRemoved:
            "equal_prompt_batch_geometry_gate_v1"
        case .contextCapacityGuardRemoved:
            "fixed_cap_context_capacity_gate_v1"
        case .cacheParityFixtureDrift:
            "exact_cached_uncached_fixture_gate_v1"
        case .singleStepCacheParityThresholdDrift:
            "single_step_cached_uncached_parity_gate_v1"
        case .multiStepCacheParityThresholdDrift:
            "multi_step_cached_uncached_parity_gate_v1"
        case .multiStepCacheParityDecisionCountDrift:
            "multi_step_six_decision_witness_gate_v1"
        case .multiStepUnevenEOSRequirementRemoved:
            "multi_step_uneven_eos_witness_gate_v1"
        case .cacheParityObservationOverclaim:
            "cache_parity_observation_nonclaim_gate_v1"
        case .generatedTextComparisonPolicyDrift:
            "canonical_string_generation_text_gate_v1"
        case .promptTargetLeakage:
            "target_unrepresentable_prompt_boundary_v1"
        case .targetDependentPromptGrouping:
            "target_independent_prompt_grouping_gate_v1"
        case .targetDependentDecisionBudget:
            "target_independent_fixed_budget_gate_v1"
        case .decisionBudgetUpperDrift:
            "exact_fixed_budget_upper_gate_v1"
        case .eosUnavailable:
            "eos_every_decision_gate_v1"
        case .shortFixedCap:
            "exact_fixed_cap64_gate_v1"
        case .terminationInconsistency:
            "eos_fixed_cap_termination_gate_v1"
        case .immediateEOSMeanOmission:
            "executed_decision_mean_gate_v1"
        case .invalidUTF8EvidenceErasure:
            "raw_utf8_evidence_preservation_gate_v1"
        case .decisionLogProbabilityCountMismatch:
            "decision_log_probability_shape_gate_v1"
        case .supportWitnessInconsistency:
            "full_vocabulary_support_witness_gate_v1"
        case .zeroLatency:
            "positive_latency_gate_v1"
        case .optionalNilPolicyDrift:
            "donor_optional_nil_semantics_gate_v1"
        case .rawShardFieldListDrift:
            "schema2_generated_field_projection_gate_v1"
        case .schema4FieldListDrift:
            "schema4_raw_regrade_field_projection_gate_v1"
        case .regradeAuthorityLeakage:
            "post_generation_regrade_separation_gate_v1"
        case .projectionAuthorityExpansion:
            "generation_projection_non_authority_gate_v1"
        }
    }
}

public struct PrimeNativeGenerationContractMutationRecord:
    Codable,
    Equatable,
    Sendable
{
    public let mutation:
        PrimeNativeGenerationContractMutation
    public let detectorID: String
    public let detected: Bool
    public let restored: Bool
    public let independentScientificOracleClaimed:
        Bool

    public init(
        mutation:
            PrimeNativeGenerationContractMutation,
        detectorID: String,
        detected: Bool,
        restored: Bool,
        independentScientificOracleClaimed:
            Bool
    ) {
        self.mutation = mutation
        self.detectorID = detectorID
        self.detected = detected
        self.restored = restored
        self.independentScientificOracleClaimed =
            independentScientificOracleClaimed
    }

    public static func detectedAndRestored(
        _ mutation:
            PrimeNativeGenerationContractMutation
    ) -> Self {
        Self(
            mutation: mutation,
            detectorID: mutation.detectorID,
            detected: true,
            restored: true,
            independentScientificOracleClaimed:
                false
        )
    }

    public func validate() throws {
        guard detectorID == mutation.detectorID,
              detected,
              restored,
              !independentScientificOracleClaimed
        else {
            throw PrimeNativeGenerationContractProjectionError
                .invalidMutationRecord(
                    mutation.rawValue
                )
        }
    }

    private enum CodingKeys: String, CodingKey {
        case mutation
        case detectorID = "detector_id"
        case detected
        case restored
        case independentScientificOracleClaimed =
            "independent_scientific_oracle_claimed"
    }
}

public extension PrimeNativeGenerationContractMutation {
    static var frozenDetectedAndRestoredRecords:
        [PrimeNativeGenerationContractMutationRecord]
    {
        allCases.map {
            .detectedAndRestored($0)
        }
    }
}
