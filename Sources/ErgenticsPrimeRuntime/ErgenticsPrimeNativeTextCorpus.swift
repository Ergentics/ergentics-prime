import CryptoKit
import Foundation

/// First-party, losslessly replayable textual curriculum for the native Prime
/// line.
///
/// The corpus is generated entirely by this Swift authority. It does not read
/// external text, inherit a tokenizer, or bind to the earlier 10M symbolic
/// mechanics checkpoint. Every model-facing byte is encoded by
/// `PrimeNativeByteTokenizer`'s exact 512-token contract.
public enum ErgenticsPrimeNativeTextCorpus {
    public static let schemaVersion = "1"
    public static let corpusID =
        "ergentics_prime_native_compositional_text_v1"
    public static let generatorID =
        "ergentics_prime_swift_sha256_procedural_v1"
    public static let relativeManifestPath =
        "content-staging/prime-native-text-corpus-manifest.v1.json"
    public static let maximumSequenceTokenCount = 512
    /// One seed authority only: the executor/recommendation contract owns the
    /// frozen triad and this corpus exposes it without a second literal.
    public static var consensusSeeds: [Int] {
        ErgenticsNativeLanguageCanary.frozenSeeds
    }

    public enum Split: String, Codable, CaseIterable, Sendable {
        case train
        case refusalTrain = "refusal_train"
        case validation
        case refusalValidation = "refusal_validation"
        case combinationHoldout = "combination_holdout"
        case ood
        case mutation
        case abstention
    }

    public enum SemanticFamily: String, Codable, CaseIterable, Sendable {
        case arithmeticComposition = "arithmetic_composition"
        case negationComposition = "negation_composition"
        case conservedTransfer = "conserved_transfer"
        case sequenceOrdering = "sequence_ordering"
        case multiStepRelation = "multi_step_relation"
        case reversibleTransform = "reversible_transform"
    }

    public static let refusalReasonIDs = [
        "ambiguous_query",
        "contradictory_relation",
        "duplicate_entity",
        "invalid_number",
        "missing_history",
        "unknown_entity",
        "unknown_operation",
    ]

    public static let rowCounts: [Split: Int] = [
        .train: 131_072,
        .refusalTrain: 4_096,
        .validation: 4_096,
        .refusalValidation: 2_048,
        .combinationHoldout: 4_096,
        .ood: 4_096,
        .mutation: 4_096,
        .abstention: 2_048,
    ]

    public struct Codebook: Codable, Equatable, Sendable {
        public let id: String
        public let entityNames: [String]
        public let admittedSplits: [String]

        enum CodingKeys: String, CodingKey {
            case id
            case entityNames = "entity_names"
            case admittedSplits = "admitted_splits"
        }
    }

    public struct SurfaceForm: Codable, Equatable, Sendable {
        public let id: String
        public let openingStyle: String
        public let stepLeadStyle: String
        public let questionStyle: String
        public let admittedSplits: [String]

        enum CodingKeys: String, CodingKey {
            case id
            case openingStyle = "opening_style"
            case stepLeadStyle = "step_lead_style"
            case questionStyle = "question_style"
            case admittedSplits = "admitted_splits"
        }
    }

    /// A complete model-facing example plus its independent regrade bindings.
    ///
    /// Token arrays are intentionally regenerated rather than serialized. The
    /// exact byte/token hashes and counts make drift visible without inflating
    /// the committed manifest with tens of millions of integer instances.
    public struct Row: Codable, Equatable, Sendable {
        public let rowID: String
        public let split: String
        public let semanticFamily: String
        public let generatorIndex: Int
        public let generatorAttempt: Int
        public let difficulty: Int
        public let compositionDepth: Int
        public let codebookID: String
        public let surfaceFormID: String
        public let promptText: String
        public let expectedCompletion: String
        public let trainingText: String
        public let expectedSemanticAnswer: String
        public let semanticCanonical: String
        public let semanticSHA256: String
        public let promptSHA256: String
        public let completionSHA256: String
        public let sequenceTokenSHA256: String
        public let promptTokenCount: Int
        public let completionTokenCount: Int
        public let sequenceTokenCount: Int
        public let invariantIDs: [String]
        public let mutationID: String?
        public let counterfactualOfRowID: String?
        public let parentSemanticSHA256: String?
        public let abstentionReason: String?
        public let evaluationRowSHA256: String
        public let rowSHA256: String

        enum CodingKeys: String, CodingKey {
            case rowID = "row_id"
            case split
            case semanticFamily = "semantic_family"
            case generatorIndex = "generator_index"
            case generatorAttempt = "generator_attempt"
            case difficulty
            case compositionDepth = "composition_depth"
            case codebookID = "codebook_id"
            case surfaceFormID = "surface_form_id"
            case promptText = "prompt_text"
            case expectedCompletion = "expected_completion"
            case trainingText = "training_text"
            case expectedSemanticAnswer =
                "expected_semantic_answer"
            case semanticCanonical = "semantic_canonical"
            case semanticSHA256 = "semantic_sha256"
            case promptSHA256 = "prompt_sha256"
            case completionSHA256 = "completion_sha256"
            case sequenceTokenSHA256 = "sequence_token_sha256"
            case promptTokenCount = "prompt_token_count"
            case completionTokenCount = "completion_token_count"
            case sequenceTokenCount = "sequence_token_count"
            case invariantIDs = "invariant_ids"
            case mutationID = "mutation_id"
            case counterfactualOfRowID =
                "counterfactual_of_row_id"
            case parentSemanticSHA256 =
                "parent_semantic_sha256"
            case abstentionReason = "abstention_reason"
            case evaluationRowSHA256 =
                "evaluation_row_sha256"
            case rowSHA256 = "row_sha256"
        }
    }

    public struct RowVerification: Codable, Equatable, Sendable {
        public let rowID: String
        public let accepted: Bool
        public let expectedCompletion: String
        public let derivedCompletion: String?
        public let expectedSemanticAnswer: String
        public let derivedSemanticAnswer: String?
        public let expectedAbstentionReason: String?
        public let derivedAbstentionReason: String?
        public let verifierSHA256: String

        enum CodingKeys: String, CodingKey {
            case rowID = "row_id"
            case accepted
            case expectedCompletion = "expected_completion"
            case derivedCompletion = "derived_completion"
            case expectedSemanticAnswer =
                "expected_semantic_answer"
            case derivedSemanticAnswer =
                "derived_semantic_answer"
            case expectedAbstentionReason =
                "expected_abstention_reason"
            case derivedAbstentionReason =
                "derived_abstention_reason"
            case verifierSHA256 = "verifier_sha256"
        }
    }

    public struct GeneratedCompletionVerification:
        Codable, Equatable, Sendable
    {
        public let rowID: String
        public let exactMatch: Bool
        public let semanticMatch: Bool
        public let abstentionDecision: Bool
        public let expectedSemanticAnswer: String
        public let derivedSemanticAnswer: String?
        public let verificationSHA256: String

        enum CodingKeys: String, CodingKey {
            case rowID = "row_id"
            case exactMatch = "exact_match"
            case semanticMatch = "semantic_match"
            case abstentionDecision = "abstention_decision"
            case expectedSemanticAnswer =
                "expected_semantic_answer"
            case derivedSemanticAnswer =
                "derived_semantic_answer"
            case verificationSHA256 = "verification_sha256"
        }
    }

    public struct FamilyCount: Codable, Equatable, Sendable {
        public let semanticFamily: String
        public let rowCount: Int

        enum CodingKeys: String, CodingKey {
            case semanticFamily = "semantic_family"
            case rowCount = "row_count"
        }
    }

    public struct CoverageCount: Codable, Equatable, Sendable {
        public let id: String
        public let rowCount: Int

        enum CodingKeys: String, CodingKey {
            case id
            case rowCount = "row_count"
        }
    }

    public struct PairCount: Codable, Equatable, Sendable {
        public let codebookID: String
        public let surfaceFormID: String
        public let rowCount: Int

        enum CodingKeys: String, CodingKey {
            case codebookID = "codebook_id"
            case surfaceFormID = "surface_form_id"
            case rowCount = "row_count"
        }
    }

    /// Token terminology is deliberately explicit:
    /// - token types are vocabulary IDs;
    /// - token instances are positions in serialized sequences;
    /// - deduplicated instances count positions after identical sequences are
    ///   counted once.
    public struct SplitEvidence: Codable, Equatable, Sendable {
        public let split: String
        public let rowCount: Int
        public let uniquePromptCount: Int
        public let uniqueSequenceCount: Int
        public let uniqueSemanticCombinationCount: Int
        public let rawTokenInstances: Int
        public let deduplicatedSequenceTokenInstances: Int
        public let observedTokenTypeCount: Int
        public let minimumSequenceTokenCount: Int
        public let maximumSequenceTokenCount: Int
        public let familyCounts: [FamilyCount]
        public let invariantCounts: [CoverageCount]
        public let mutationCounts: [CoverageCount]
        public let codebookSurfacePairCounts: [PairCount]
        public let orderedRowsSHA256: String
        public let orderedEvaluationRowsSHA256: String
        public let semanticSetSHA256: String
        public let promptSetSHA256: String
        public let sequenceSetSHA256: String
        public let independentRegradeSHA256: String
        public let allRowsIndependentlyVerified: Bool

        enum CodingKeys: String, CodingKey {
            case split
            case rowCount = "row_count"
            case uniquePromptCount = "unique_prompt_count"
            case uniqueSequenceCount = "unique_sequence_count"
            case uniqueSemanticCombinationCount =
                "unique_semantic_combination_count"
            case rawTokenInstances = "raw_token_instances"
            case deduplicatedSequenceTokenInstances =
                "deduplicated_sequence_token_instances"
            case observedTokenTypeCount =
                "observed_token_type_count"
            case minimumSequenceTokenCount =
                "minimum_sequence_token_count"
            case maximumSequenceTokenCount =
                "maximum_sequence_token_count"
            case familyCounts = "family_counts"
            case invariantCounts = "invariant_counts"
            case mutationCounts = "mutation_counts"
            case codebookSurfacePairCounts =
                "codebook_surface_pair_counts"
            case orderedRowsSHA256 = "ordered_rows_sha256"
            case orderedEvaluationRowsSHA256 =
                "ordered_evaluation_rows_sha256"
            case semanticSetSHA256 = "semantic_set_sha256"
            case promptSetSHA256 = "prompt_set_sha256"
            case sequenceSetSHA256 = "sequence_set_sha256"
            case independentRegradeSHA256 =
                "independent_regrade_sha256"
            case allRowsIndependentlyVerified =
                "all_rows_independently_verified"
        }
    }

    public struct GeneratorContract: Codable, Equatable, Sendable {
        public let generatorID: String
        public let implementationLanguage: String
        public let implementationPath: String
        public let entropyPrimitive: String
        public let hostRandomness: Bool
        public let externalText: Bool
        public let inheritedTokenizer: Bool
        public let inheritedWeights: Bool
        public let fullRowsEmbedded: Bool
        public let losslessReplay: Bool
        public let canonicalTextNormalization: String
        public let sequenceConstruction: String
        public let maximumSequenceTokenCount: Int

        enum CodingKeys: String, CodingKey {
            case generatorID = "generator_id"
            case implementationLanguage = "implementation_language"
            case implementationPath = "implementation_path"
            case entropyPrimitive = "entropy_primitive"
            case hostRandomness = "host_randomness"
            case externalText = "external_text"
            case inheritedTokenizer = "inherited_tokenizer"
            case inheritedWeights = "inherited_weights"
            case fullRowsEmbedded = "full_rows_embedded"
            case losslessReplay = "lossless_replay"
            case canonicalTextNormalization =
                "canonical_text_normalization"
            case sequenceConstruction = "sequence_construction"
            case maximumSequenceTokenCount =
                "maximum_sequence_token_count"
        }
    }

    public struct TokenAccounting: Codable, Equatable, Sendable {
        public let vocabularyTokenTypeCount: Int
        public let observedTokenTypeCount: Int
        public let rawTokenInstances: Int
        public let deduplicatedSequenceTokenInstances: Int
        public let uniqueSequenceCount: Int
        public let uniqueSemanticCombinationCount: Int

        enum CodingKeys: String, CodingKey {
            case vocabularyTokenTypeCount =
                "vocabulary_token_type_count"
            case observedTokenTypeCount =
                "observed_token_type_count"
            case rawTokenInstances = "raw_token_instances"
            case deduplicatedSequenceTokenInstances =
                "deduplicated_sequence_token_instances"
            case uniqueSequenceCount = "unique_sequence_count"
            case uniqueSemanticCombinationCount =
                "unique_semantic_combination_count"
        }
    }

    public struct LeakageEvidence: Codable, Equatable, Sendable {
        public let trainEvaluationPromptOverlapCount: Int
        public let trainEvaluationSemanticOverlapCount: Int
        public let refusalTrainEvaluationPromptOverlapCount: Int
        public let refusalTrainEvaluationSemanticOverlapCount: Int
        public let refusalTrainAbstentionContractOverlapCount: Int
        public let trainCombinationPairOverlapCount: Int
        public let trainCombinationCodebookIDIntersectionCount: Int
        public let trainCombinationSurfaceIDIntersectionCount: Int
        public let trainOODCodebookIDIntersectionCount: Int
        public let trainOODSurfaceIDIntersectionCount: Int
        public let combinationComponentsSeenInTrain: Bool
        public let combinationPairsAbsentFromTrain: Bool
        public let exactLookupEvaluationHits: Int
        public let allRowIDsUnique: Bool
        public let allRowHashesUnique: Bool
        public let allValidSemanticsDisjointAcrossSplits: Bool

        enum CodingKeys: String, CodingKey {
            case trainEvaluationPromptOverlapCount =
                "train_evaluation_prompt_overlap_count"
            case trainEvaluationSemanticOverlapCount =
                "train_evaluation_semantic_overlap_count"
            case refusalTrainEvaluationPromptOverlapCount =
                "refusal_train_evaluation_prompt_overlap_count"
            case refusalTrainEvaluationSemanticOverlapCount =
                "refusal_train_evaluation_semantic_overlap_count"
            case refusalTrainAbstentionContractOverlapCount =
                "refusal_train_abstention_contract_overlap_count"
            case trainCombinationPairOverlapCount =
                "train_combination_pair_overlap_count"
            case trainCombinationCodebookIDIntersectionCount =
                "train_combination_codebook_id_intersection_count"
            case trainCombinationSurfaceIDIntersectionCount =
                "train_combination_surface_id_intersection_count"
            case trainOODCodebookIDIntersectionCount =
                "train_ood_codebook_id_intersection_count"
            case trainOODSurfaceIDIntersectionCount =
                "train_ood_surface_id_intersection_count"
            case combinationComponentsSeenInTrain =
                "combination_components_seen_in_train"
            case combinationPairsAbsentFromTrain =
                "combination_pairs_absent_from_train"
            case exactLookupEvaluationHits =
                "exact_lookup_evaluation_hits"
            case allRowIDsUnique = "all_row_ids_unique"
            case allRowHashesUnique = "all_row_hashes_unique"
            case allValidSemanticsDisjointAcrossSplits =
                "all_valid_semantics_disjoint_across_splits"
        }
    }

    public struct RefusalContractCount:
        Codable, Equatable, Sendable
    {
        public let abstentionReason: String
        public let mutationID: String
        public let surfaceFormID: String
        public let rowCount: Int

        enum CodingKeys: String, CodingKey {
            case abstentionReason = "abstention_reason"
            case mutationID = "mutation_id"
            case surfaceFormID = "surface_form_id"
            case rowCount = "row_count"
        }
    }

    /// Proves that malformed examples used to teach refusal are first-party,
    /// independently regraded, and held disjoint from the evaluation
    /// abstention contracts. Categories are taught in training, while tuning
    /// and final evaluation each reserve a distinct category + mutation +
    /// surface combination.
    public struct RefusalCurriculumEvidence:
        Codable, Equatable, Sendable
    {
        public let trainingSplit: String
        public let tuningSplit: String
        public let finalEvaluationSplit: String
        public let trainingRowCount: Int
        public let tuningRowCount: Int
        public let finalEvaluationRowCount: Int
        public let trainingReasonCounts: [CoverageCount]
        public let tuningReasonCounts: [CoverageCount]
        public let finalEvaluationReasonCounts: [CoverageCount]
        public let trainingContractCounts: [RefusalContractCount]
        public let tuningContractCounts: [RefusalContractCount]
        public let finalEvaluationContractCounts:
            [RefusalContractCount]
        public let trainingPromptSetSHA256: String
        public let tuningPromptSetSHA256: String
        public let finalEvaluationPromptSetSHA256: String
        public let trainingSemanticSetSHA256: String
        public let tuningSemanticSetSHA256: String
        public let finalEvaluationSemanticSetSHA256: String
        public let trainingIndependentRegradeSHA256: String
        public let tuningIndependentRegradeSHA256: String
        public let finalEvaluationIndependentRegradeSHA256: String
        public let trainingTuningPromptOverlapCount: Int
        public let trainingFinalEvaluationPromptOverlapCount: Int
        public let tuningFinalEvaluationPromptOverlapCount: Int
        public let trainingTuningSemanticOverlapCount: Int
        public let trainingFinalEvaluationSemanticOverlapCount: Int
        public let tuningFinalEvaluationSemanticOverlapCount: Int
        public let trainingTuningMutationContractOverlapCount: Int
        public let trainingFinalEvaluationMutationContractOverlapCount:
            Int
        public let tuningFinalEvaluationMutationContractOverlapCount:
            Int
        public let allReasonsTaughtBeforeTuningAndEvaluation: Bool
        public let allTuningAndEvaluationContractsHeldOut: Bool
        public let allRowsIndependentlyVerified: Bool

        enum CodingKeys: String, CodingKey {
            case trainingSplit = "training_split"
            case tuningSplit = "tuning_split"
            case finalEvaluationSplit = "final_evaluation_split"
            case trainingRowCount = "training_row_count"
            case tuningRowCount = "tuning_row_count"
            case finalEvaluationRowCount =
                "final_evaluation_row_count"
            case trainingReasonCounts = "training_reason_counts"
            case tuningReasonCounts = "tuning_reason_counts"
            case finalEvaluationReasonCounts =
                "final_evaluation_reason_counts"
            case trainingContractCounts = "training_contract_counts"
            case tuningContractCounts = "tuning_contract_counts"
            case finalEvaluationContractCounts =
                "final_evaluation_contract_counts"
            case trainingPromptSetSHA256 =
                "training_prompt_set_sha256"
            case tuningPromptSetSHA256 =
                "tuning_prompt_set_sha256"
            case finalEvaluationPromptSetSHA256 =
                "final_evaluation_prompt_set_sha256"
            case trainingSemanticSetSHA256 =
                "training_semantic_set_sha256"
            case tuningSemanticSetSHA256 =
                "tuning_semantic_set_sha256"
            case finalEvaluationSemanticSetSHA256 =
                "final_evaluation_semantic_set_sha256"
            case trainingIndependentRegradeSHA256 =
                "training_independent_regrade_sha256"
            case tuningIndependentRegradeSHA256 =
                "tuning_independent_regrade_sha256"
            case finalEvaluationIndependentRegradeSHA256 =
                "final_evaluation_independent_regrade_sha256"
            case trainingTuningPromptOverlapCount =
                "training_tuning_prompt_overlap_count"
            case trainingFinalEvaluationPromptOverlapCount =
                "training_final_evaluation_prompt_overlap_count"
            case tuningFinalEvaluationPromptOverlapCount =
                "tuning_final_evaluation_prompt_overlap_count"
            case trainingTuningSemanticOverlapCount =
                "training_tuning_semantic_overlap_count"
            case trainingFinalEvaluationSemanticOverlapCount =
                "training_final_evaluation_semantic_overlap_count"
            case tuningFinalEvaluationSemanticOverlapCount =
                "tuning_final_evaluation_semantic_overlap_count"
            case trainingTuningMutationContractOverlapCount =
                "training_tuning_mutation_contract_overlap_count"
            case trainingFinalEvaluationMutationContractOverlapCount =
                "training_final_evaluation_mutation_contract_overlap_count"
            case tuningFinalEvaluationMutationContractOverlapCount =
                "tuning_final_evaluation_mutation_contract_overlap_count"
            case allReasonsTaughtBeforeTuningAndEvaluation =
                "all_reasons_taught_before_tuning_and_evaluation"
            case allTuningAndEvaluationContractsHeldOut =
                "all_tuning_and_evaluation_contracts_held_out"
            case allRowsIndependentlyVerified =
                "all_rows_independently_verified"
        }
    }

    public struct FalsifierEvidence: Codable, Equatable, Sendable {
        public let id: String
        public let family: String
        public let detected: Bool
        public let trials: Int
        public let detections: Int
        public let detail: String
    }

    public struct EvaluationContract: Codable, Equatable, Sendable {
        public let promptField: String
        public let expectedCompletionField: String
        public let exactMatchNormalization: String
        public let causalLossMask: String
        public let abstentionCompletion: String
        /// Splits admitted while choosing a checkpoint. These are not all
        /// independent capability claims: `refusal_validation` is
        /// selection-only and must never appear in the final raw result set.
        public let selectionTuningSplits: [String]
        /// Exact splits required in the final raw autoregressive result set.
        public let requiredRawResultSplits: [String]
        public let requiredRawResultFields: [String]
        public let evaluationRowSHA256CanonicalFields: [String]
        public let evaluationRowAbsentMutationEncoding: String
        public let szCanonicalFields: [String]
        public let triadicWitnesses: [String]
        public let verifyAbstainMinimumIndependentWitnesses: Int
        public let verifyAbstainCriticalLegs: [String]
        public let multiSeedConsensusSeeds: [Int]

        enum CodingKeys: String, CodingKey {
            case promptField = "prompt_field"
            case expectedCompletionField =
                "expected_completion_field"
            case exactMatchNormalization =
                "exact_match_normalization"
            case causalLossMask = "causal_loss_mask"
            case abstentionCompletion = "abstention_completion"
            case selectionTuningSplits =
                "selection_tuning_splits"
            case requiredRawResultSplits =
                "required_raw_result_splits"
            case requiredRawResultFields =
                "required_raw_result_fields"
            case evaluationRowSHA256CanonicalFields =
                "evaluation_row_sha256_canonical_fields"
            case evaluationRowAbsentMutationEncoding =
                "evaluation_row_absent_mutation_encoding"
            case szCanonicalFields = "sz_canonical_fields"
            case triadicWitnesses = "triadic_witnesses"
            case verifyAbstainMinimumIndependentWitnesses =
                "verify_abstain_minimum_independent_witnesses"
            case verifyAbstainCriticalLegs =
                "verify_abstain_critical_legs"
            case multiSeedConsensusSeeds =
                "multi_seed_consensus_seeds"
        }
    }

    public struct Manifest: Codable, Equatable, Sendable {
        public let schemaVersion: String
        public let corpusID: String
        public let ownership: String
        public let license: String
        public let productAuthorization: String
        public let tokenizerID: String
        public let tokenizerManifestSHA256: String
        public let modelVocabularySize: Int
        public let generator: GeneratorContract
        public let codebooks: [Codebook]
        public let surfaceForms: [SurfaceForm]
        public let splitEvidence: [SplitEvidence]
        public let tokenAccounting: TokenAccounting
        public let leakageEvidence: LeakageEvidence
        public let refusalCurriculumEvidence:
            RefusalCurriculumEvidence
        public let falsifiers: [FalsifierEvidence]
        public let evaluationContract: EvaluationContract
        public let orderedCorpusRowsSHA256: String
        public let falsifierSHA256: String
        public let manifestSHA256: String

        enum CodingKeys: String, CodingKey {
            case schemaVersion = "schema_version"
            case corpusID = "corpus_id"
            case ownership
            case license
            case productAuthorization =
                "product_authorization"
            case tokenizerID = "tokenizer_id"
            case tokenizerManifestSHA256 =
                "tokenizer_manifest_sha256"
            case modelVocabularySize = "model_vocabulary_size"
            case generator
            case codebooks
            case surfaceForms = "surface_forms"
            case splitEvidence = "split_evidence"
            case tokenAccounting = "token_accounting"
            case leakageEvidence = "leakage_evidence"
            case refusalCurriculumEvidence =
                "refusal_curriculum_evidence"
            case falsifiers
            case evaluationContract = "evaluation_contract"
            case orderedCorpusRowsSHA256 =
                "ordered_corpus_rows_sha256"
            case falsifierSHA256 = "falsifier_sha256"
            case manifestSHA256 = "manifest_sha256"
        }
    }

    public enum CorpusError: Error, Equatable, LocalizedError {
        case unsupportedSplit(String)
        case rowReplayMismatch(String)
        case independentVerifierMismatch(String)
        case sequenceTooLong(String, Int)
        case manifestMismatch
        case manifestSHA256Mismatch
        case tokenizerMismatch
        case refusingOverwrite(String)

        public var errorDescription: String? {
            switch self {
            case .unsupportedSplit(let split):
                "Unsupported native corpus split: \(split)"
            case .rowReplayMismatch(let rowID):
                "Native corpus row replay mismatch: \(rowID)"
            case .independentVerifierMismatch(let rowID):
                "Independent semantic verifier rejected row: \(rowID)"
            case .sequenceTooLong(let rowID, let count):
                "Native corpus row \(rowID) has \(count) tokens; maximum is \(maximumSequenceTokenCount)."
            case .manifestMismatch:
                "Native text corpus manifest does not match the Swift authority."
            case .manifestSHA256Mismatch:
                "Native text corpus manifest content hash does not match."
            case .tokenizerMismatch:
                "Native text corpus is not bound to the exact 512-token byte tokenizer."
            case .refusingOverwrite(let path):
                "Refusing to overwrite a divergent native corpus artifact at \(path)."
            }
        }
    }
}

private enum NativeSemanticAnswer: Equatable {
    case number(Int)
    case boolean(Bool)
    case entity(Int?)

    var canonical: String {
        switch self {
        case .number(let value):
            "number:\(value)"
        case .boolean(let value):
            "boolean:\(value ? "yes" : "no")"
        case .entity(let slot):
            slot.map { "entity:\($0)" } ?? "entity:none"
        }
    }

    func display(using codebook: ErgenticsPrimeNativeTextCorpus.Codebook)
        -> String
    {
        switch self {
        case .number(let value):
            String(value)
        case .boolean(let value):
            value ? "yes" : "no"
        case .entity(let slot):
            slot.map { codebook.entityNames[$0] } ?? "none"
        }
    }
}

private enum NativeScalarOperation: Equatable {
    case add(Int)
    case subtract(Int)
    case negate
    case undo

    var canonical: String {
        switch self {
        case .add(let value):
            "add:\(value)"
        case .subtract(let value):
            "subtract:\(value)"
        case .negate:
            "negate"
        case .undo:
            "undo"
        }
    }
}

private struct NativeScalarProgram: Equatable {
    let initial: Int
    let operations: [NativeScalarOperation]

    func evaluate() -> NativeSemanticAnswer? {
        var value = initial
        var history: [NativeScalarOperation] = []
        for operation in operations {
            switch operation {
            case .add(let amount):
                value += amount
                history.append(operation)
            case .subtract(let amount):
                value -= amount
                history.append(operation)
            case .negate:
                value = -value
                history.append(operation)
            case .undo:
                guard let previous = history.popLast() else {
                    return nil
                }
                switch previous {
                case .add(let amount):
                    value -= amount
                case .subtract(let amount):
                    value += amount
                case .negate:
                    value = -value
                case .undo:
                    return nil
                }
            }
        }
        return .number(value)
    }

    var canonical: String {
        [
            "scalar",
            "initial=\(initial)",
            "operations=\(operations.map(\.canonical).joined(separator: ","))",
            "query=value:0",
        ].joined(separator: "|")
    }
}

private enum NativeTransferOperation: Equatable {
    case move(amount: Int, from: Int, to: Int)
    case undo

    var canonical: String {
        switch self {
        case .move(let amount, let source, let destination):
            "move:\(amount):\(source):\(destination)"
        case .undo:
            "undo"
        }
    }
}

private enum NativeTransferQuery: Equatable {
    case entity(Int)
    case total

    var canonical: String {
        switch self {
        case .entity(let slot):
            "entity:\(slot)"
        case .total:
            "total"
        }
    }
}

private struct NativeTransferProgram: Equatable {
    let initial: [Int]
    let operations: [NativeTransferOperation]
    let query: NativeTransferQuery

    func evaluate() -> NativeSemanticAnswer? {
        var values = initial
        var history: [NativeTransferOperation] = []
        for operation in operations {
            switch operation {
            case .move(let amount, let source, let destination):
                guard values.indices.contains(source),
                      values.indices.contains(destination),
                      source != destination,
                      amount > 0 else {
                    return nil
                }
                values[source] -= amount
                values[destination] += amount
                history.append(operation)
            case .undo:
                guard case .move(
                    let amount,
                    let source,
                    let destination
                ) = history.popLast() else {
                    return nil
                }
                values[source] += amount
                values[destination] -= amount
            }
        }
        switch query {
        case .entity(let slot):
            guard values.indices.contains(slot) else { return nil }
            return .number(values[slot])
        case .total:
            return .number(values.reduce(0, +))
        }
    }

    var canonical: String {
        [
            "transfer",
            "initial=\(initial.map(String.init).joined(separator: ","))",
            "operations=\(operations.map(\.canonical).joined(separator: ","))",
            "query=\(query.canonical)",
        ].joined(separator: "|")
    }
}

private enum NativeOrderingOperation: Equatable {
    case swap(Int, Int)
    case placeBefore(Int, Int)
    case reverse
    case undo

    var canonical: String {
        switch self {
        case .swap(let left, let right):
            "swap:\(left):\(right)"
        case .placeBefore(let moved, let anchor):
            "before:\(moved):\(anchor)"
        case .reverse:
            "reverse"
        case .undo:
            "undo"
        }
    }
}

private enum NativeOrderingQuery: Equatable {
    case immediatelyBefore(Int)
    case before(Int, Int)
    case position(Int)

    var canonical: String {
        switch self {
        case .immediatelyBefore(let slot):
            "immediately_before:\(slot)"
        case .before(let left, let right):
            "before:\(left):\(right)"
        case .position(let slot):
            "position:\(slot)"
        }
    }
}

private struct NativeOrderingProgram: Equatable {
    let initialOrder: [Int]
    let operations: [NativeOrderingOperation]
    let query: NativeOrderingQuery

    func evaluate() -> NativeSemanticAnswer? {
        var order = initialOrder
        var history: [[Int]] = []
        for operation in operations {
            switch operation {
            case .undo:
                guard let prior = history.popLast() else { return nil }
                order = prior
            case .swap(let left, let right):
                guard let leftIndex = order.firstIndex(of: left),
                      let rightIndex = order.firstIndex(of: right),
                      left != right else {
                    return nil
                }
                history.append(order)
                order.swapAt(leftIndex, rightIndex)
            case .placeBefore(let moved, let anchor):
                guard let movedIndex = order.firstIndex(of: moved),
                      order.contains(anchor),
                      moved != anchor else {
                    return nil
                }
                history.append(order)
                order.remove(at: movedIndex)
                guard let anchorIndex = order.firstIndex(of: anchor) else {
                    return nil
                }
                order.insert(moved, at: anchorIndex)
            case .reverse:
                history.append(order)
                order.reverse()
            }
        }
        switch query {
        case .immediatelyBefore(let slot):
            guard let index = order.firstIndex(of: slot) else { return nil }
            return .entity(index == order.startIndex ? nil : order[index - 1])
        case .before(let left, let right):
            guard let leftIndex = order.firstIndex(of: left),
                  let rightIndex = order.firstIndex(of: right) else {
                return nil
            }
            return .boolean(leftIndex < rightIndex)
        case .position(let slot):
            guard let index = order.firstIndex(of: slot) else { return nil }
            return .number(index + 1)
        }
    }

    var canonical: String {
        [
            "ordering",
            "initial=\(initialOrder.map(String.init).joined(separator: ","))",
            "operations=\(operations.map(\.canonical).joined(separator: ","))",
            "query=\(query.canonical)",
        ].joined(separator: "|")
    }
}

private enum NativeRelationQuery: Equatable {
    case signedDistance(from: Int, to: Int)
    case notRight(left: Int, right: Int)

    var canonical: String {
        switch self {
        case .signedDistance(let source, let destination):
            "distance:\(source):\(destination)"
        case .notRight(let left, let right):
            "not_right:\(left):\(right)"
        }
    }
}

private struct NativeRelationProgram: Equatable {
    /// Each tuple means `to` is `delta` signed steps from `from`.
    let edges: [(from: Int, to: Int, delta: Int)]
    let query: NativeRelationQuery

    static func == (
        lhs: NativeRelationProgram,
        rhs: NativeRelationProgram
    ) -> Bool {
        lhs.canonical == rhs.canonical
    }

    func coordinates() -> [Int: Int]? {
        guard let first = edges.first else { return nil }
        var coordinates = [first.from: 0]
        var changed = true
        while changed {
            changed = false
            for edge in edges {
                if let from = coordinates[edge.from] {
                    let proposed = from + edge.delta
                    if let current = coordinates[edge.to],
                       current != proposed {
                        return nil
                    }
                    if coordinates[edge.to] == nil {
                        coordinates[edge.to] = proposed
                        changed = true
                    }
                }
                if let to = coordinates[edge.to] {
                    let proposed = to - edge.delta
                    if let current = coordinates[edge.from],
                       current != proposed {
                        return nil
                    }
                    if coordinates[edge.from] == nil {
                        coordinates[edge.from] = proposed
                        changed = true
                    }
                }
            }
        }
        let mentioned = Set(edges.flatMap { [$0.from, $0.to] })
        guard mentioned.isSubset(of: Set(coordinates.keys)) else {
            return nil
        }
        return coordinates
    }

    func evaluate() -> NativeSemanticAnswer? {
        guard let coordinates = coordinates() else { return nil }
        switch query {
        case .signedDistance(let source, let destination):
            guard let sourceValue = coordinates[source],
                  let destinationValue = coordinates[destination] else {
                return nil
            }
            return .number(destinationValue - sourceValue)
        case .notRight(let left, let right):
            guard let leftValue = coordinates[left],
                  let rightValue = coordinates[right] else {
                return nil
            }
            return .boolean(leftValue <= rightValue)
        }
    }

    var canonical: String {
        let edgeText = edges.map {
            "\($0.from):\($0.to):\($0.delta)"
        }.joined(separator: ",")
        return [
            "relation",
            "edges=\(edgeText)",
            "query=\(query.canonical)",
        ].joined(separator: "|")
    }
}

private enum NativeProgram: Equatable {
    case scalar(NativeScalarProgram)
    case transfer(NativeTransferProgram)
    case ordering(NativeOrderingProgram)
    case relation(NativeRelationProgram)

    var canonical: String {
        switch self {
        case .scalar(let program):
            program.canonical
        case .transfer(let program):
            program.canonical
        case .ordering(let program):
            program.canonical
        case .relation(let program):
            program.canonical
        }
    }

    func evaluate() -> NativeSemanticAnswer? {
        switch self {
        case .scalar(let program):
            program.evaluate()
        case .transfer(let program):
            program.evaluate()
        case .ordering(let program):
            program.evaluate()
        case .relation(let program):
            program.evaluate()
        }
    }
}

private struct NativeGeneratedProgram {
    let family: ErgenticsPrimeNativeTextCorpus.SemanticFamily
    let program: NativeProgram
    let difficulty: Int
    let depth: Int
    let invariants: [String]
}

private struct NativeEntropy {
    let split: ErgenticsPrimeNativeTextCorpus.Split
    let index: Int
    let attempt: Int

    func uint64(_ key: String) -> UInt64 {
        let material = [
            ErgenticsPrimeNativeTextCorpus.generatorID,
            split.rawValue,
            String(index),
            String(attempt),
            key,
        ].joined(separator: "|")
        let digest = SHA256.hash(data: Data(material.utf8))
        return digest.prefix(8).reduce(UInt64(0)) {
            ($0 << 8) | UInt64($1)
        }
    }

    func integer(_ key: String, in range: ClosedRange<Int>) -> Int {
        precondition(range.lowerBound <= range.upperBound)
        let width = UInt64(range.upperBound - range.lowerBound + 1)
        return range.lowerBound + Int(uint64(key) % width)
    }

    func choice<T>(_ key: String, from values: [T]) -> T {
        values[integer(key, in: 0 ... values.count - 1)]
    }

    func permutation(_ key: String, count: Int) -> [Int] {
        (0 ..< count).sorted {
            let left = uint64("\(key)-\($0)")
            let right = uint64("\(key)-\($1)")
            return left == right ? $0 < $1 : left < right
        }
    }
}

extension ErgenticsPrimeNativeTextCorpus {
    public static let codebooks: [Codebook] = [
        Codebook(
            id: "field",
            entityNames: [
                "amber", "birch", "cobalt", "dune",
                "ember", "flint", "grove", "harbor",
            ],
            admittedSplits: [
                Split.train.rawValue,
                Split.refusalTrain.rawValue,
                Split.validation.rawValue,
                Split.refusalValidation.rawValue,
                Split.combinationHoldout.rawValue,
                Split.mutation.rawValue,
                Split.abstention.rawValue,
            ]
        ),
        Codebook(
            id: "coast",
            entityNames: [
                "atlas", "beacon", "coral", "drift",
                "estuary", "fjord", "gale", "haven",
            ],
            admittedSplits: [
                Split.train.rawValue,
                Split.refusalTrain.rawValue,
                Split.validation.rawValue,
                Split.refusalValidation.rawValue,
                Split.combinationHoldout.rawValue,
                Split.mutation.rawValue,
                Split.abstention.rawValue,
            ]
        ),
        Codebook(
            id: "light",
            entityNames: [
                "ion", "jade", "kite", "lumen",
                "mica", "nova", "opal", "quartz",
            ],
            admittedSplits: [
                Split.train.rawValue,
                Split.refusalTrain.rawValue,
                Split.validation.rawValue,
                Split.refusalValidation.rawValue,
                Split.combinationHoldout.rawValue,
                Split.mutation.rawValue,
                Split.abstention.rawValue,
            ]
        ),
        Codebook(
            id: "native_ood_a",
            entityNames: [
                "aster", "brin", "cassia", "dorun",
                "elara", "fen", "galen", "hyra",
            ],
            admittedSplits: [
                Split.ood.rawValue,
                Split.abstention.rawValue,
            ]
        ),
        Codebook(
            id: "native_ood_b",
            entityNames: [
                "axiom", "boson", "chirp", "dynamo",
                "epoch", "flux", "gluon", "helix",
            ],
            admittedSplits: [
                Split.ood.rawValue,
                Split.abstention.rawValue,
            ]
        ),
    ]

    public static let surfaceForms: [SurfaceForm] = [
        SurfaceForm(
            id: "initial",
            openingStyle: "Initially, ...",
            stepLeadStyle: "First/Then, ...",
            questionStyle: "What/Which/Is ...?",
            admittedSplits: [
                Split.train.rawValue,
                Split.refusalTrain.rawValue,
                Split.validation.rawValue,
                Split.refusalValidation.rawValue,
                Split.combinationHoldout.rawValue,
                Split.mutation.rawValue,
                Split.abstention.rawValue,
            ]
        ),
        SurfaceForm(
            id: "start",
            openingStyle: "At the start, ...",
            stepLeadStyle: "Apply/Continue, ...",
            questionStyle: "Return ...",
            admittedSplits: [
                Split.train.rawValue,
                Split.refusalTrain.rawValue,
                Split.validation.rawValue,
                Split.refusalValidation.rawValue,
                Split.combinationHoldout.rawValue,
                Split.mutation.rawValue,
                Split.abstention.rawValue,
            ]
        ),
        SurfaceForm(
            id: "opening",
            openingStyle: "The opening ...",
            stepLeadStyle: "In order/Next, ...",
            questionStyle: "Report ...",
            admittedSplits: [
                Split.train.rawValue,
                Split.refusalTrain.rawValue,
                Split.validation.rawValue,
                Split.refusalValidation.rawValue,
                Split.combinationHoldout.rawValue,
                Split.mutation.rawValue,
                Split.abstention.rawValue,
            ]
        ),
        SurfaceForm(
            id: "begin",
            openingStyle: "Begin with ...",
            stepLeadStyle: "Execute/Proceed, ...",
            questionStyle: "Give ...",
            admittedSplits: [
                Split.ood.rawValue,
                Split.abstention.rawValue,
            ]
        ),
        SurfaceForm(
            id: "record",
            openingStyle: "The record opens ...",
            stepLeadStyle: "Perform/Afterward, ...",
            questionStyle: "Determine ...",
            admittedSplits: [
                Split.ood.rawValue,
                Split.abstention.rawValue,
            ]
        ),
    ]

    private static let trainingPairs = [
        "field|initial",
        "field|start",
        "coast|start",
        "coast|opening",
        "light|initial",
        "light|opening",
    ]
    private static let combinationHoldoutPairs = [
        "field|opening",
        "coast|initial",
        "light|start",
    ]
    private static let oodPairs = [
        "native_ood_a|begin",
        "native_ood_a|record",
        "native_ood_b|begin",
        "native_ood_b|record",
    ]

    private static func codebook(id: String) -> Codebook {
        codebooks.first { $0.id == id }!
    }

    private static func surface(id: String) -> SurfaceForm {
        surfaceForms.first { $0.id == id }!
    }

    private static func pair(
        split: Split,
        entropy: NativeEntropy
    ) -> (Codebook, SurfaceForm) {
        let candidates: [String]
        switch split {
        case .train, .refusalTrain, .validation, .refusalValidation:
            candidates = trainingPairs
        case .combinationHoldout, .mutation:
            candidates = combinationHoldoutPairs
        case .ood:
            candidates = oodPairs
        case .abstention:
            candidates = trainingPairs + oodPairs
        }
        let value = entropy.choice("codebook-surface-pair", from: candidates)
        let pieces = value.split(separator: "|", omittingEmptySubsequences: false)
        return (
            codebook(id: String(pieces[0])),
            surface(id: String(pieces[1]))
        )
    }

    private static func family(index: Int) -> SemanticFamily {
        SemanticFamily.allCases[index % SemanticFamily.allCases.count]
    }

    private static func depth(
        split: Split,
        entropy: NativeEntropy,
        family: SemanticFamily
    ) -> Int {
        let bounds: ClosedRange<Int>
        switch split {
        case .train, .refusalTrain:
            bounds = 2 ... 6
        case .validation, .refusalValidation:
            bounds = 3 ... 7
        case .combinationHoldout, .mutation:
            bounds = 4 ... 8
        case .ood:
            bounds = 7 ... 10
        case .abstention:
            bounds = 3 ... 8
        }
        let proposed = entropy.integer("depth", in: bounds)
        if family == .multiStepRelation {
            return min(proposed, 7)
        }
        if family == .conservedTransfer
            || family == .sequenceOrdering
        {
            return min(proposed, 8)
        }
        return proposed
    }

    private static func generatedProgram(
        split: Split,
        index: Int,
        attempt: Int
    ) -> NativeGeneratedProgram {
        let entropy = NativeEntropy(
            split: split,
            index: index,
            attempt: attempt
        )
        let family = family(index: index)
        let depth = depth(split: split, entropy: entropy, family: family)
        let ood = split == .ood
        let magnitude = ood ? 12 : 7

        switch family {
        case .arithmeticComposition:
            let initial = entropy.integer(
                "scalar-initial",
                in: (ood ? -24 : -12) ... (ood ? 24 : 12)
            )
            let operations = (0 ..< depth).map { step in
                let amount = entropy.integer(
                    "scalar-amount-\(step)",
                    in: 1 ... magnitude
                )
                return entropy.integer(
                    "scalar-kind-\(step)",
                    in: 0 ... 1
                ) == 0
                    ? NativeScalarOperation.add(amount)
                    : NativeScalarOperation.subtract(amount)
            }
            return NativeGeneratedProgram(
                family: family,
                program: .scalar(
                    NativeScalarProgram(
                        initial: initial,
                        operations: operations
                    )
                ),
                difficulty: depth + (ood ? 3 : 0),
                depth: depth,
                invariants: [
                    "variable_composition",
                    "multi_step_execution",
                ]
            )

        case .negationComposition:
            let initial = entropy.integer(
                "negation-initial",
                in: (ood ? -18 : -9) ... (ood ? 18 : 9)
            )
            var operations: [NativeScalarOperation] = []
            for step in 0 ..< depth {
                if step == 1 || (
                    step > 1
                        && entropy.integer(
                            "negation-kind-\(step)",
                            in: 0 ... 4
                        ) == 0
                ) {
                    operations.append(.negate)
                } else {
                    let amount = entropy.integer(
                        "negation-amount-\(step)",
                        in: 1 ... magnitude
                    )
                    operations.append(
                        entropy.integer(
                            "negation-sign-\(step)",
                            in: 0 ... 1
                        ) == 0 ? .add(amount) : .subtract(amount)
                    )
                }
            }
            return NativeGeneratedProgram(
                family: family,
                program: .scalar(
                    NativeScalarProgram(
                        initial: initial,
                        operations: operations
                    )
                ),
                difficulty: depth + 2 + (ood ? 3 : 0),
                depth: depth,
                invariants: [
                    "variable_composition",
                    "negation",
                    "operation_order_sensitivity",
                    "multi_step_execution",
                ]
            )

        case .reversibleTransform:
            let initial = entropy.integer(
                "reversal-initial",
                in: (ood ? -24 : -12) ... (ood ? 24 : 12)
            )
            var operations: [NativeScalarOperation] = []
            var historyCount = 0
            for step in 0 ..< depth {
                let shouldUndo =
                    step == 1
                        || (
                            historyCount > 0
                                && step > 2
                                && entropy.integer(
                                    "reversal-kind-\(step)",
                                    in: 0 ... 3
                                ) == 0
                        )
                if shouldUndo, historyCount > 0 {
                    operations.append(.undo)
                    historyCount -= 1
                } else {
                    let amount = entropy.integer(
                        "reversal-amount-\(step)",
                        in: 1 ... magnitude
                    )
                    let operation: NativeScalarOperation
                    switch entropy.integer(
                        "reversal-action-\(step)",
                        in: 0 ... 2
                    ) {
                    case 0:
                        operation = .add(amount)
                    case 1:
                        operation = .subtract(amount)
                    default:
                        operation = .negate
                    }
                    operations.append(operation)
                    historyCount += 1
                }
            }
            return NativeGeneratedProgram(
                family: family,
                program: .scalar(
                    NativeScalarProgram(
                        initial: initial,
                        operations: operations
                    )
                ),
                difficulty: depth + 3 + (ood ? 3 : 0),
                depth: depth,
                invariants: [
                    "variable_composition",
                    "reversal",
                    "deterministic_replay",
                    "multi_step_execution",
                ]
            )

        case .conservedTransfer:
            let initial = (0 ..< 3).map {
                entropy.integer(
                    "transfer-initial-\($0)",
                    in: (ood ? -10 : 0) ... (ood ? 24 : 16)
                )
            }
            var operations: [NativeTransferOperation] = []
            var historyCount = 0
            for step in 0 ..< depth {
                let undo =
                    historyCount > 0
                        && step > 1
                        && entropy.integer(
                            "transfer-kind-\(step)",
                            in: 0 ... 7
                        ) == 0
                if undo {
                    operations.append(.undo)
                    historyCount -= 1
                } else {
                    let source = entropy.integer(
                        "transfer-source-\(step)",
                        in: 0 ... 2
                    )
                    var destination = entropy.integer(
                        "transfer-destination-\(step)",
                        in: 0 ... 1
                    )
                    if destination >= source { destination += 1 }
                    let amount = entropy.integer(
                        "transfer-amount-\(step)",
                        in: 1 ... (ood ? 9 : 5)
                    )
                    operations.append(
                        .move(
                            amount: amount,
                            from: source,
                            to: destination
                        )
                    )
                    historyCount += 1
                }
            }
            let query: NativeTransferQuery =
                entropy.integer("transfer-query", in: 0 ... 4) == 0
                    ? .total
                    : .entity(
                        entropy.integer(
                            "transfer-query-entity",
                            in: 0 ... 2
                        )
                    )
            var invariants = [
                "conservation",
                "variable_composition",
                "multi_step_execution",
            ]
            if operations.contains(where: {
                if case .undo = $0 { return true }
                return false
            }) {
                invariants.append("reversal")
            }
            return NativeGeneratedProgram(
                family: family,
                program: .transfer(
                    NativeTransferProgram(
                        initial: initial,
                        operations: operations,
                        query: query
                    )
                ),
                difficulty: depth + 2 + (ood ? 3 : 0),
                depth: depth,
                invariants: invariants.sorted()
            )

        case .sequenceOrdering:
            let initial = entropy.permutation(
                "ordering-initial",
                count: 5
            )
            var operations: [NativeOrderingOperation] = []
            var historyCount = 0
            for step in 0 ..< depth {
                let selector = entropy.integer(
                    "ordering-kind-\(step)",
                    in: 0 ... 9
                )
                if selector == 0, historyCount > 0 {
                    operations.append(.undo)
                    historyCount -= 1
                } else if selector <= 3 {
                    let left = entropy.integer(
                        "ordering-left-\(step)",
                        in: 0 ... 4
                    )
                    var right = entropy.integer(
                        "ordering-right-\(step)",
                        in: 0 ... 3
                    )
                    if right >= left { right += 1 }
                    operations.append(.swap(left, right))
                    historyCount += 1
                } else if selector <= 7 {
                    let moved = entropy.integer(
                        "ordering-moved-\(step)",
                        in: 0 ... 4
                    )
                    var anchor = entropy.integer(
                        "ordering-anchor-\(step)",
                        in: 0 ... 3
                    )
                    if anchor >= moved { anchor += 1 }
                    operations.append(.placeBefore(moved, anchor))
                    historyCount += 1
                } else {
                    operations.append(.reverse)
                    historyCount += 1
                }
            }
            let query: NativeOrderingQuery
            switch entropy.integer("ordering-query", in: 0 ... 2) {
            case 0:
                query = .immediatelyBefore(
                    entropy.integer("ordering-query-a", in: 0 ... 4)
                )
            case 1:
                let left = entropy.integer(
                    "ordering-query-left",
                    in: 0 ... 4
                )
                var right = entropy.integer(
                    "ordering-query-right",
                    in: 0 ... 3
                )
                if right >= left { right += 1 }
                query = .before(left, right)
            default:
                query = .position(
                    entropy.integer(
                        "ordering-query-position",
                        in: 0 ... 4
                    )
                )
            }
            var invariants = [
                "ordering",
                "operation_order_sensitivity",
                "multi_step_execution",
            ]
            if operations.contains(where: {
                switch $0 {
                case .reverse, .undo:
                    true
                default:
                    false
                }
            }) {
                invariants.append("reversal")
            }
            return NativeGeneratedProgram(
                family: family,
                program: .ordering(
                    NativeOrderingProgram(
                        initialOrder: initial,
                        operations: operations,
                        query: query
                    )
                ),
                difficulty: depth + 3 + (ood ? 3 : 0),
                depth: depth,
                invariants: invariants.sorted()
            )

        case .multiStepRelation:
            let edgeCount = min(depth, 7)
            let permutation = entropy.permutation(
                "relation-entities",
                count: 8
            )
            let edges = (0 ..< edgeCount).map { step in
                var delta = entropy.integer(
                    "relation-delta-\(step)",
                    in: (ood ? -9 : -5) ... (ood ? 9 : 5)
                )
                if delta == 0 { delta = step.isMultiple(of: 2) ? 1 : -1 }
                return (
                    from: permutation[step],
                    to: permutation[step + 1],
                    delta: delta
                )
            }
            let query: NativeRelationQuery
            let source = permutation[0]
            let destination = permutation[edgeCount]
            if entropy.integer("relation-query", in: 0 ... 2) == 0 {
                query = .notRight(left: destination, right: source)
            } else {
                query = .signedDistance(
                    from: source,
                    to: destination
                )
            }
            var invariants = [
                "multi_step_relations",
                "relation_composition",
                "operation_order_sensitivity",
            ]
            if case .notRight = query {
                invariants.append("negation")
            }
            return NativeGeneratedProgram(
                family: family,
                program: .relation(
                    NativeRelationProgram(
                        edges: edges,
                        query: query
                    )
                ),
                difficulty: edgeCount + 4 + (ood ? 3 : 0),
                depth: edgeCount,
                invariants: invariants.sorted()
            )
        }
    }

    private static func stepLead(
        surfaceID: String,
        index: Int
    ) -> String {
        switch surfaceID {
        case "initial":
            index == 0 ? "First" : "Then"
        case "start":
            index == 0 ? "Apply" : "Continue"
        case "opening":
            index == 0 ? "In order" : "Next"
        case "begin":
            index == 0 ? "Execute" : "Proceed"
        default:
            index == 0 ? "Perform" : "Afterward"
        }
    }

    private static func render(
        _ generated: NativeGeneratedProgram,
        codebook: Codebook,
        surface: SurfaceForm
    ) -> String {
        let opening: String
        let steps: [String]
        let question: String

        switch generated.program {
        case .scalar(let program):
            let entity = codebook.entityNames[0]
            switch surface.id {
            case "initial":
                opening = "Initially, \(entity) has value \(program.initial)."
            case "start":
                opening =
                    "At the start, \(entity)'s reading is \(program.initial)."
            case "opening":
                opening =
                    "The opening value of \(entity) is \(program.initial)."
            case "begin":
                opening = "Begin with \(entity) at \(program.initial)."
            default:
                opening =
                    "The record opens with \(entity) at \(program.initial)."
            }
            steps = program.operations.enumerated().map { offset, operation in
                let action: String
                switch operation {
                case .add(let amount):
                    action = "add \(amount) to \(entity)."
                case .subtract(let amount):
                    action = "subtract \(amount) from \(entity)."
                case .negate:
                    action = "negate \(entity)."
                case .undo:
                    action =
                        "undo the previous change to \(entity)."
                }
                return "\(stepLead(surfaceID: surface.id, index: offset)), \(action)"
            }
            switch surface.id {
            case "initial":
                question =
                    "What is the final value of \(entity)?"
            case "start":
                question =
                    "Return the final reading of \(entity)."
            case "opening":
                question =
                    "Report the terminal value of \(entity)."
            case "begin":
                question =
                    "Give the ending value of \(entity)."
            default:
                question =
                    "Determine the final value of \(entity)."
            }

        case .transfer(let program):
            let names = Array(codebook.entityNames.prefix(3))
            let assignments = zip(names, program.initial).map {
                "\($0.0) holds \($0.1)"
            }.joined(separator: "; ")
            switch surface.id {
            case "initial":
                opening = "Initially, \(assignments)."
            case "start":
                opening = "At the start, \(assignments)."
            case "opening":
                opening = "The opening ledger says \(assignments)."
            case "begin":
                opening = "Begin with \(assignments)."
            default:
                opening = "The record opens: \(assignments)."
            }
            steps = program.operations.enumerated().map { offset, operation in
                let action: String
                switch operation {
                case .move(let amount, let source, let destination):
                    action =
                        "move \(amount) from \(names[source]) to \(names[destination])."
                case .undo:
                    action = "undo the previous transfer."
                }
                return "\(stepLead(surfaceID: surface.id, index: offset)), \(action)"
            }
            switch program.query {
            case .entity(let slot):
                let name = names[slot]
                switch surface.id {
                case "initial":
                    question = "What does \(name) finally hold?"
                case "start":
                    question = "Return the final holding of \(name)."
                case "opening":
                    question = "Report \(name)'s terminal holding."
                case "begin":
                    question = "Give the ending holding of \(name)."
                default:
                    question = "Determine the final holding of \(name)."
                }
            case .total:
                switch surface.id {
                case "initial":
                    question = "What is the final total?"
                case "start":
                    question = "Return the final total."
                case "opening":
                    question = "Report the terminal total."
                case "begin":
                    question = "Give the ending total."
                default:
                    question = "Determine the final total."
                }
            }

        case .ordering(let program):
            let names = program.initialOrder.map {
                codebook.entityNames[$0]
            }
            let order = names.joined(separator: " before ")
            switch surface.id {
            case "initial":
                opening = "Initially, the order is \(order)."
            case "start":
                opening = "At the start, the order is \(order)."
            case "opening":
                opening = "The opening order is \(order)."
            case "begin":
                opening = "Begin with the order \(order)."
            default:
                opening = "The record opens in order: \(order)."
            }
            steps = program.operations.enumerated().map { offset, operation in
                let action: String
                switch operation {
                case .swap(let left, let right):
                    action =
                        "swap \(codebook.entityNames[left]) with \(codebook.entityNames[right])."
                case .placeBefore(let moved, let anchor):
                    action =
                        "place \(codebook.entityNames[moved]) immediately before \(codebook.entityNames[anchor])."
                case .reverse:
                    action = "reverse the complete order."
                case .undo:
                    action =
                        "undo the previous ordering change."
                }
                return "\(stepLead(surfaceID: surface.id, index: offset)), \(action)"
            }
            switch program.query {
            case .immediatelyBefore(let slot):
                let name = codebook.entityNames[slot]
                question =
                    "Which item is immediately before \(name)?"
            case .before(let left, let right):
                question =
                    "Is \(codebook.entityNames[left]) before \(codebook.entityNames[right])?"
            case .position(let slot):
                question =
                    "What is the one-based position of \(codebook.entityNames[slot])?"
            }

        case .relation(let program):
            opening = surface.id == "record"
                ? "The record contains these relations."
                : "Use these relations."
            steps = program.edges.enumerated().map { offset, edge in
                let direction = edge.delta >= 0 ? "right" : "left"
                let amount = abs(edge.delta)
                return [
                    stepLead(surfaceID: surface.id, index: offset),
                    "\(codebook.entityNames[edge.to]) is \(amount) steps \(direction) of \(codebook.entityNames[edge.from]).",
                ].joined(separator: ", ")
            }
            switch program.query {
            case .signedDistance(let source, let destination):
                question =
                    "What is the signed distance from \(codebook.entityNames[source]) to \(codebook.entityNames[destination])?"
            case .notRight(let left, let right):
                question =
                    "Is \(codebook.entityNames[left]) not right of \(codebook.entityNames[right])?"
            }
        }

        return ([opening] + steps + [question, "Answer:", ""])
            .joined(separator: "\n")
    }
}

private enum NativeParseFailure: String, Error {
    case invalidNumber = "invalid_number"
    case unknownOperation = "unknown_operation"
    case unknownEntity = "unknown_entity"
    case duplicateEntity = "duplicate_entity"
    case contradictoryRelation = "contradictory_relation"
    case missingHistory = "missing_history"
    case ambiguousQuery = "ambiguous_query"
    case malformedPrompt = "malformed_prompt"
}

private struct NativeParsedResult {
    let answer: NativeSemanticAnswer
    let codebook: ErgenticsPrimeNativeTextCorpus.Codebook
}

private enum NativeTextRegex {
    static let scalarOpenings = [
        try! NSRegularExpression(
            pattern: #"^Initially, ([a-z0-9_]+) has value (-?[0-9]+)\.$"#
        ),
        try! NSRegularExpression(
            pattern: #"^At the start, ([a-z0-9_]+)'s reading is (-?[0-9]+)\.$"#
        ),
        try! NSRegularExpression(
            pattern: #"^The opening value of ([a-z0-9_]+) is (-?[0-9]+)\.$"#
        ),
        try! NSRegularExpression(
            pattern: #"^Begin with ([a-z0-9_]+) at (-?[0-9]+)\.$"#
        ),
        try! NSRegularExpression(
            pattern: #"^The record opens with ([a-z0-9_]+) at (-?[0-9]+)\.$"#
        ),
    ]
    static let holding = try! NSRegularExpression(
        pattern: #"([a-z0-9_]+) holds (-?[0-9]+)"#
    )
    static let add = try! NSRegularExpression(
        pattern: #"^add ([0-9]+) to ([a-z0-9_]+)\.$"#
    )
    static let subtract = try! NSRegularExpression(
        pattern: #"^subtract ([0-9]+) from ([a-z0-9_]+)\.$"#
    )
    static let negate = try! NSRegularExpression(
        pattern: #"^negate ([a-z0-9_]+)\.$"#
    )
    static let undoScalar = try! NSRegularExpression(
        pattern: #"^undo the previous change to ([a-z0-9_]+)\.$"#
    )
    static let move = try! NSRegularExpression(
        pattern: #"^move ([0-9]+) from ([a-z0-9_]+) to ([a-z0-9_]+)\.$"#
    )
    static let swap = try! NSRegularExpression(
        pattern: #"^swap ([a-z0-9_]+) with ([a-z0-9_]+)\.$"#
    )
    static let placeBefore = try! NSRegularExpression(
        pattern: #"^place ([a-z0-9_]+) immediately before ([a-z0-9_]+)\.$"#
    )
    static let relation = try! NSRegularExpression(
        pattern: #"^([a-z0-9_]+) is ([0-9]+) steps (right|left) of ([a-z0-9_]+)\.$"#
    )

    static let scalarQuestions = [
        try! NSRegularExpression(
            pattern: #"^What is the final value of ([a-z0-9_]+)\?$"#
        ),
        try! NSRegularExpression(
            pattern: #"^Return the final reading of ([a-z0-9_]+)\.$"#
        ),
        try! NSRegularExpression(
            pattern: #"^Report the terminal value of ([a-z0-9_]+)\.$"#
        ),
        try! NSRegularExpression(
            pattern: #"^Give the ending value of ([a-z0-9_]+)\.$"#
        ),
        try! NSRegularExpression(
            pattern: #"^Determine the final value of ([a-z0-9_]+)\.$"#
        ),
    ]
    static let entityHoldingQuestions = [
        try! NSRegularExpression(
            pattern: #"^What does ([a-z0-9_]+) finally hold\?$"#
        ),
        try! NSRegularExpression(
            pattern: #"^Return the final holding of ([a-z0-9_]+)\.$"#
        ),
        try! NSRegularExpression(
            pattern: #"^Report ([a-z0-9_]+)'s terminal holding\.$"#
        ),
        try! NSRegularExpression(
            pattern: #"^Give the ending holding of ([a-z0-9_]+)\.$"#
        ),
        try! NSRegularExpression(
            pattern: #"^Determine the final holding of ([a-z0-9_]+)\.$"#
        ),
    ]
    static let immediatelyBeforeQuestion = try! NSRegularExpression(
        pattern: #"^Which item is immediately before ([a-z0-9_]+)\?$"#
    )
    static let beforeQuestion = try! NSRegularExpression(
        pattern: #"^Is ([a-z0-9_]+) before ([a-z0-9_]+)\?$"#
    )
    static let positionQuestion = try! NSRegularExpression(
        pattern: #"^What is the one-based position of ([a-z0-9_]+)\?$"#
    )
    static let distanceQuestion = try! NSRegularExpression(
        pattern: #"^What is the signed distance from ([a-z0-9_]+) to ([a-z0-9_]+)\?$"#
    )
    static let notRightQuestion = try! NSRegularExpression(
        pattern: #"^Is ([a-z0-9_]+) not right of ([a-z0-9_]+)\?$"#
    )

    static func captures(
        _ regex: NSRegularExpression,
        in text: String
    ) -> [String]? {
        let range = NSRange(text.startIndex ..< text.endIndex, in: text)
        guard let match = regex.firstMatch(
            in: text,
            options: [],
            range: range
        ), match.range == range else {
            return nil
        }
        return (1 ..< match.numberOfRanges).compactMap {
            Range(match.range(at: $0), in: text).map {
                String(text[$0])
            }
        }
    }

    static func allCaptures(
        _ regex: NSRegularExpression,
        in text: String
    ) -> [[String]] {
        let range = NSRange(text.startIndex ..< text.endIndex, in: text)
        return regex.matches(in: text, options: [], range: range).map {
            match in
            (1 ..< match.numberOfRanges).compactMap {
                Range(match.range(at: $0), in: text).map {
                    String(text[$0])
                }
            }
        }
    }

    static func firstCaptures(
        _ regexes: [NSRegularExpression],
        in text: String
    ) -> [String]? {
        for regex in regexes {
            if let values = captures(regex, in: text) {
                return values
            }
        }
        return nil
    }
}

private enum NativeIndependentTextVerifier {
    private static func codebook(
        containing names: [String]
    ) throws -> ErgenticsPrimeNativeTextCorpus.Codebook {
        let candidates = ErgenticsPrimeNativeTextCorpus.codebooks.filter {
            Set(names).isSubset(of: Set($0.entityNames))
        }
        guard candidates.count == 1, let value = candidates.first else {
            throw NativeParseFailure.unknownEntity
        }
        return value
    }

    private static func slot(
        _ name: String,
        codebook: ErgenticsPrimeNativeTextCorpus.Codebook
    ) throws -> Int {
        guard let slot = codebook.entityNames.firstIndex(of: name) else {
            throw NativeParseFailure.unknownEntity
        }
        return slot
    }

    private static func action(_ line: String) throws -> String {
        guard let comma = line.range(of: ", ") else {
            throw NativeParseFailure.unknownOperation
        }
        let value = String(line[comma.upperBound...])
        if value.contains(" many ") {
            throw NativeParseFailure.invalidNumber
        }
        if value.contains("add to ") || value.contains("move from ") {
            throw NativeParseFailure.invalidNumber
        }
        return value
    }

    private static func questionLike(_ line: String) -> Bool {
        [
            "What ", "Which ", "Is ", "Return ", "Report ",
            "Give ", "Determine ",
        ].contains { line.hasPrefix($0) }
    }

    static func parse(_ prompt: String) throws -> NativeParsedResult {
        let canonical = PrimeNativeByteTokenizer.canonicalize(prompt)
        var lines = canonical.split(
            separator: "\n",
            omittingEmptySubsequences: true
        ).map(String.init)
        guard lines.last == "Answer:" else {
            throw NativeParseFailure.malformedPrompt
        }
        lines.removeLast()
        let questionIndices = lines.indices.filter {
            questionLike(lines[$0])
        }
        guard questionIndices.count == 1,
              let questionIndex = questionIndices.first,
              questionIndex == lines.index(before: lines.endIndex),
              let opening = lines.first else {
            throw NativeParseFailure.ambiguousQuery
        }
        let question = lines[questionIndex]
        let actionLines = Array(lines.dropFirst().dropLast())

        if opening.contains("relations") {
            return try parseRelation(
                opening: opening,
                actions: actionLines,
                question: question
            )
        }
        if opening.contains("order") {
            return try parseOrdering(
                opening: opening,
                actions: actionLines,
                question: question
            )
        }
        if opening.contains(" holds ")
            || opening.contains("ledger")
            || opening.hasPrefix("The record opens:")
        {
            return try parseTransfer(
                opening: opening,
                actions: actionLines,
                question: question
            )
        }
        return try parseScalar(
            opening: opening,
            actions: actionLines,
            question: question
        )
    }

    private static func parseScalar(
        opening: String,
        actions: [String],
        question: String
    ) throws -> NativeParsedResult {
        guard let openingValues = NativeTextRegex.firstCaptures(
            NativeTextRegex.scalarOpenings,
            in: opening
        ), openingValues.count == 2 else {
            if opening.contains("many") {
                throw NativeParseFailure.invalidNumber
            }
            throw NativeParseFailure.malformedPrompt
        }
        let name = openingValues[0]
        guard let initial = Int(openingValues[1]) else {
            throw NativeParseFailure.invalidNumber
        }
        let codebook = try codebook(containing: [name])
        let entitySlot = try slot(name, codebook: codebook)
        guard entitySlot == 0 else {
            throw NativeParseFailure.unknownEntity
        }
        var operations: [NativeScalarOperation] = []
        for line in actions {
            let value = try action(line)
            if let captures = NativeTextRegex.captures(
                NativeTextRegex.add,
                in: value
            ), let amount = Int(captures[0]) {
                guard try slot(captures[1], codebook: codebook) == entitySlot
                else {
                    throw NativeParseFailure.unknownEntity
                }
                operations.append(.add(amount))
            } else if let captures = NativeTextRegex.captures(
                NativeTextRegex.subtract,
                in: value
            ), let amount = Int(captures[0]) {
                guard try slot(captures[1], codebook: codebook) == entitySlot
                else {
                    throw NativeParseFailure.unknownEntity
                }
                operations.append(.subtract(amount))
            } else if let captures = NativeTextRegex.captures(
                NativeTextRegex.negate,
                in: value
            ) {
                guard try slot(captures[0], codebook: codebook) == entitySlot
                else {
                    throw NativeParseFailure.unknownEntity
                }
                operations.append(.negate)
            } else if let captures = NativeTextRegex.captures(
                NativeTextRegex.undoScalar,
                in: value
            ) {
                guard try slot(captures[0], codebook: codebook) == entitySlot
                else {
                    throw NativeParseFailure.unknownEntity
                }
                operations.append(.undo)
            } else {
                throw NativeParseFailure.unknownOperation
            }
        }
        guard let queryValues = NativeTextRegex.firstCaptures(
            NativeTextRegex.scalarQuestions,
            in: question
        ), queryValues.count == 1,
              try slot(queryValues[0], codebook: codebook) == entitySlot else {
            throw NativeParseFailure.unknownEntity
        }
        let program = NativeScalarProgram(
            initial: initial,
            operations: operations
        )
        guard let answer = program.evaluate() else {
            throw NativeParseFailure.missingHistory
        }
        return NativeParsedResult(answer: answer, codebook: codebook)
    }

    private static func parseTransfer(
        opening: String,
        actions: [String],
        question: String
    ) throws -> NativeParsedResult {
        if opening.contains("many") {
            throw NativeParseFailure.invalidNumber
        }
        let assignments = NativeTextRegex.allCaptures(
            NativeTextRegex.holding,
            in: opening
        )
        guard assignments.count == 3,
              assignments.allSatisfy({ $0.count == 2 }) else {
            throw NativeParseFailure.malformedPrompt
        }
        let names = assignments.map { $0[0] }
        guard Set(names).count == names.count else {
            throw NativeParseFailure.duplicateEntity
        }
        let codebook = try codebook(containing: names)
        var initial = Array(repeating: 0, count: 3)
        for (index, assignment) in assignments.enumerated() {
            guard try slot(assignment[0], codebook: codebook) == index,
                  let value = Int(assignment[1]) else {
                throw NativeParseFailure.invalidNumber
            }
            initial[index] = value
        }
        var operations: [NativeTransferOperation] = []
        for line in actions {
            let value = try action(line)
            if let captures = NativeTextRegex.captures(
                NativeTextRegex.move,
                in: value
            ), let amount = Int(captures[0]) {
                let source = try slot(captures[1], codebook: codebook)
                let destination = try slot(captures[2], codebook: codebook)
                guard source < 3, destination < 3, source != destination
                else {
                    throw NativeParseFailure.unknownEntity
                }
                operations.append(
                    .move(
                        amount: amount,
                        from: source,
                        to: destination
                    )
                )
            } else if value == "undo the previous transfer." {
                operations.append(.undo)
            } else {
                throw NativeParseFailure.unknownOperation
            }
        }
        let query: NativeTransferQuery
        if [
            "What is the final total?",
            "Return the final total.",
            "Report the terminal total.",
            "Give the ending total.",
            "Determine the final total.",
        ].contains(question) {
            query = .total
        } else if let values = NativeTextRegex.firstCaptures(
            NativeTextRegex.entityHoldingQuestions,
            in: question
        ) {
            let entity = try slot(values[0], codebook: codebook)
            guard entity < 3 else {
                throw NativeParseFailure.unknownEntity
            }
            query = .entity(entity)
        } else {
            throw NativeParseFailure.unknownEntity
        }
        let program = NativeTransferProgram(
            initial: initial,
            operations: operations,
            query: query
        )
        guard let answer = program.evaluate() else {
            throw NativeParseFailure.missingHistory
        }
        return NativeParsedResult(answer: answer, codebook: codebook)
    }

    private static func parseOrdering(
        opening: String,
        actions: [String],
        question: String
    ) throws -> NativeParsedResult {
        let prefixes = [
            "Initially, the order is ",
            "At the start, the order is ",
            "The opening order is ",
            "Begin with the order ",
            "The record opens in order: ",
        ]
        guard let prefix = prefixes.first(where: {
            opening.hasPrefix($0)
        }), opening.hasSuffix(".") else {
            throw NativeParseFailure.malformedPrompt
        }
        let start = opening.index(
            opening.startIndex,
            offsetBy: prefix.count
        )
        let orderText = String(opening[start ..< opening.index(before: opening.endIndex)])
        let names = orderText.components(separatedBy: " before ")
        guard names.count == 5 else {
            throw NativeParseFailure.malformedPrompt
        }
        guard Set(names).count == names.count else {
            throw NativeParseFailure.duplicateEntity
        }
        let codebook = try codebook(containing: names)
        let initial = try names.map { try slot($0, codebook: codebook) }
        var operations: [NativeOrderingOperation] = []
        for line in actions {
            let value = try action(line)
            if let values = NativeTextRegex.captures(
                NativeTextRegex.swap,
                in: value
            ) {
                operations.append(
                    .swap(
                        try slot(values[0], codebook: codebook),
                        try slot(values[1], codebook: codebook)
                    )
                )
            } else if let values = NativeTextRegex.captures(
                NativeTextRegex.placeBefore,
                in: value
            ) {
                operations.append(
                    .placeBefore(
                        try slot(values[0], codebook: codebook),
                        try slot(values[1], codebook: codebook)
                    )
                )
            } else if value == "reverse the complete order." {
                operations.append(.reverse)
            } else if value == "undo the previous ordering change." {
                operations.append(.undo)
            } else {
                throw NativeParseFailure.unknownOperation
            }
        }
        let query: NativeOrderingQuery
        if let values = NativeTextRegex.captures(
            NativeTextRegex.immediatelyBeforeQuestion,
            in: question
        ) {
            query = .immediatelyBefore(
                try slot(values[0], codebook: codebook)
            )
        } else if let values = NativeTextRegex.captures(
            NativeTextRegex.beforeQuestion,
            in: question
        ) {
            query = .before(
                try slot(values[0], codebook: codebook),
                try slot(values[1], codebook: codebook)
            )
        } else if let values = NativeTextRegex.captures(
            NativeTextRegex.positionQuestion,
            in: question
        ) {
            query = .position(
                try slot(values[0], codebook: codebook)
            )
        } else {
            throw NativeParseFailure.unknownEntity
        }
        let program = NativeOrderingProgram(
            initialOrder: initial,
            operations: operations,
            query: query
        )
        guard let answer = program.evaluate() else {
            throw NativeParseFailure.missingHistory
        }
        return NativeParsedResult(answer: answer, codebook: codebook)
    }

    private static func parseRelation(
        opening _: String,
        actions: [String],
        question: String
    ) throws -> NativeParsedResult {
        var rawEdges: [(String, String, Int)] = []
        for line in actions {
            let value = try action(line)
            guard let captures = NativeTextRegex.captures(
                NativeTextRegex.relation,
                in: value
            ), let magnitude = Int(captures[1]) else {
                throw NativeParseFailure.unknownOperation
            }
            rawEdges.append(
                (
                    captures[3],
                    captures[0],
                    captures[2] == "right" ? magnitude : -magnitude
                )
            )
        }
        let names = rawEdges.flatMap { [$0.0, $0.1] }
        let codebook = try codebook(containing: names)
        let edges = try rawEdges.map {
            (
                from: try slot($0.0, codebook: codebook),
                to: try slot($0.1, codebook: codebook),
                delta: $0.2
            )
        }
        let query: NativeRelationQuery
        if let values = NativeTextRegex.captures(
            NativeTextRegex.distanceQuestion,
            in: question
        ) {
            query = .signedDistance(
                from: try slot(values[0], codebook: codebook),
                to: try slot(values[1], codebook: codebook)
            )
        } else if let values = NativeTextRegex.captures(
            NativeTextRegex.notRightQuestion,
            in: question
        ) {
            query = .notRight(
                left: try slot(values[0], codebook: codebook),
                right: try slot(values[1], codebook: codebook)
            )
        } else {
            throw NativeParseFailure.unknownEntity
        }
        let program = NativeRelationProgram(edges: edges, query: query)
        guard let answer = program.evaluate() else {
            throw NativeParseFailure.contradictoryRelation
        }
        return NativeParsedResult(answer: answer, codebook: codebook)
    }
}

private struct NativeEvaluationRowPayload: Encodable {
    let rowID: String
    let split: String
    let semanticFamily: String
    let mutationID: String?
    let prompt: String
    let target: String

    enum CodingKeys: String, CodingKey {
        case rowID = "row_id"
        case split
        case semanticFamily = "semantic_family"
        case mutationID = "mutation_id"
        case prompt
        case target
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(rowID, forKey: .rowID)
        try container.encode(split, forKey: .split)
        try container.encode(semanticFamily, forKey: .semanticFamily)
        if let mutationID {
            try container.encode(mutationID, forKey: .mutationID)
        } else {
            try container.encodeNil(forKey: .mutationID)
        }
        try container.encode(prompt, forKey: .prompt)
        try container.encode(target, forKey: .target)
    }
}

private struct NativeRowHashPayload: Encodable {
    let rowID: String
    let split: String
    let semanticFamily: String
    let generatorIndex: Int
    let generatorAttempt: Int
    let difficulty: Int
    let compositionDepth: Int
    let codebookID: String
    let surfaceFormID: String
    let promptText: String
    let expectedCompletion: String
    let trainingText: String
    let expectedSemanticAnswer: String
    let semanticCanonical: String
    let semanticSHA256: String
    let promptSHA256: String
    let completionSHA256: String
    let sequenceTokenSHA256: String
    let promptTokenCount: Int
    let completionTokenCount: Int
    let sequenceTokenCount: Int
    let invariantIDs: [String]
    let mutationID: String?
    let counterfactualOfRowID: String?
    let parentSemanticSHA256: String?
    let abstentionReason: String?
    let evaluationRowSHA256: String

    enum CodingKeys: String, CodingKey {
        case rowID = "row_id"
        case split
        case semanticFamily = "semantic_family"
        case generatorIndex = "generator_index"
        case generatorAttempt = "generator_attempt"
        case difficulty
        case compositionDepth = "composition_depth"
        case codebookID = "codebook_id"
        case surfaceFormID = "surface_form_id"
        case promptText = "prompt_text"
        case expectedCompletion = "expected_completion"
        case trainingText = "training_text"
        case expectedSemanticAnswer = "expected_semantic_answer"
        case semanticCanonical = "semantic_canonical"
        case semanticSHA256 = "semantic_sha256"
        case promptSHA256 = "prompt_sha256"
        case completionSHA256 = "completion_sha256"
        case sequenceTokenSHA256 = "sequence_token_sha256"
        case promptTokenCount = "prompt_token_count"
        case completionTokenCount = "completion_token_count"
        case sequenceTokenCount = "sequence_token_count"
        case invariantIDs = "invariant_ids"
        case mutationID = "mutation_id"
        case counterfactualOfRowID = "counterfactual_of_row_id"
        case parentSemanticSHA256 = "parent_semantic_sha256"
        case abstentionReason = "abstention_reason"
        case evaluationRowSHA256 = "evaluation_row_sha256"
    }
}

private struct NativeVerifierHashPayload: Encodable {
    let rowID: String
    let accepted: Bool
    let expectedCompletion: String
    let derivedCompletion: String?
    let expectedSemanticAnswer: String
    let derivedSemanticAnswer: String?
    let expectedAbstentionReason: String?
    let derivedAbstentionReason: String?
}

private struct NativeGeneratedCompletionHashPayload: Encodable {
    let rowID: String
    let exactMatch: Bool
    let semanticMatch: Bool
    let abstentionDecision: Bool
    let expectedSemanticAnswer: String
    let derivedSemanticAnswer: String?
}

extension ErgenticsPrimeNativeTextCorpus {
    public static func sha256(_ data: Data) -> String {
        SHA256.hash(data: data).map {
            String(format: "%02x", $0)
        }.joined()
    }

    public static func canonicalSHA256<T: Encodable>(
        _ value: T
    ) -> String {
        sha256(canonicalJSONData(value))
    }

    /// Exact cross-module row-material hash for executor, SZ, triadic, and
    /// VerifyAbstain regrade. Sorted-key JSON contains precisely:
    /// `{row_id,split,semantic_family,mutation_id,prompt,target}`.
    /// A missing mutation ID is encoded as JSON `null`, never omitted.
    public static func evaluationRowSHA256(_ row: Row) -> String {
        canonicalSHA256(
            NativeEvaluationRowPayload(
                rowID: row.rowID,
                split: row.split,
                semanticFamily: row.semanticFamily,
                mutationID: row.mutationID,
                prompt: row.promptText,
                target: row.expectedCompletion
            )
        )
    }

    private static func rowContentSHA256(_ row: Row) -> String {
        canonicalSHA256(
            NativeRowHashPayload(
                rowID: row.rowID,
                split: row.split,
                semanticFamily: row.semanticFamily,
                generatorIndex: row.generatorIndex,
                generatorAttempt: row.generatorAttempt,
                difficulty: row.difficulty,
                compositionDepth: row.compositionDepth,
                codebookID: row.codebookID,
                surfaceFormID: row.surfaceFormID,
                promptText: row.promptText,
                expectedCompletion: row.expectedCompletion,
                trainingText: row.trainingText,
                expectedSemanticAnswer:
                    row.expectedSemanticAnswer,
                semanticCanonical: row.semanticCanonical,
                semanticSHA256: row.semanticSHA256,
                promptSHA256: row.promptSHA256,
                completionSHA256: row.completionSHA256,
                sequenceTokenSHA256: row.sequenceTokenSHA256,
                promptTokenCount: row.promptTokenCount,
                completionTokenCount: row.completionTokenCount,
                sequenceTokenCount: row.sequenceTokenCount,
                invariantIDs: row.invariantIDs,
                mutationID: row.mutationID,
                counterfactualOfRowID:
                    row.counterfactualOfRowID,
                parentSemanticSHA256:
                    row.parentSemanticSHA256,
                abstentionReason: row.abstentionReason,
                evaluationRowSHA256:
                    row.evaluationRowSHA256
            )
        )
    }

    private static func canonicalJSONData<T: Encodable>(
        _ value: T
    ) -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return try! encoder.encode(value)
    }

    public static func verify(row: Row) -> RowVerification {
        let promptIDs = PrimeNativeByteTokenizer.encode(row.promptText)
        let completionIDs = PrimeNativeByteTokenizer.encode(
            row.expectedCompletion
        )
        let sequenceIDs = PrimeNativeByteTokenizer.encodeSequence(
            row.trainingText
        )
        let materialValid =
            row.trainingText == row.promptText + row.expectedCompletion
                && row.semanticSHA256
                    == sha256(Data(row.semanticCanonical.utf8))
                && row.promptSHA256
                    == sha256(Data(row.promptText.utf8))
                && row.completionSHA256
                    == sha256(Data(row.expectedCompletion.utf8))
                && row.sequenceTokenSHA256
                    == PrimeNativeByteTokenizer.tokenIDsSHA256(sequenceIDs)
                && row.promptTokenCount == promptIDs.count + 1
                && row.completionTokenCount == completionIDs.count + 1
                && row.sequenceTokenCount == sequenceIDs.count
                && row.sequenceTokenCount
                    == row.promptTokenCount + row.completionTokenCount
                && row.sequenceTokenCount <= maximumSequenceTokenCount
                && row.evaluationRowSHA256
                    == evaluationRowSHA256(row)
                && row.rowSHA256 == rowContentSHA256(row)

        let derivedCompletion: String?
        let derivedSemanticAnswer: String?
        let derivedReason: String?
        let semanticValid: Bool
        do {
            let parsed = try NativeIndependentTextVerifier.parse(
                row.promptText
            )
            let semantic = parsed.answer.canonical
            let completion =
                "Result: \(parsed.answer.display(using: parsed.codebook)).\n"
            derivedCompletion = completion
            derivedSemanticAnswer = semantic
            derivedReason = nil
            semanticValid =
                row.split != Split.abstention.rawValue
                    && row.split != Split.refusalTrain.rawValue
                    && row.split != Split.refusalValidation.rawValue
                    && row.abstentionReason == nil
                    && completion == row.expectedCompletion
                    && semantic == row.expectedSemanticAnswer
        } catch let failure as NativeParseFailure {
            derivedCompletion = "ABSTAIN\n"
            derivedSemanticAnswer = "abstain:\(failure.rawValue)"
            derivedReason = failure.rawValue
            semanticValid =
                (
                    row.split == Split.abstention.rawValue
                        || row.split == Split.refusalTrain.rawValue
                        || row.split
                            == Split.refusalValidation.rawValue
                )
                    && row.expectedCompletion == "ABSTAIN\n"
                    && row.abstentionReason == failure.rawValue
                    && row.expectedSemanticAnswer
                        == "abstain:\(failure.rawValue)"
        } catch {
            derivedCompletion = nil
            derivedSemanticAnswer = nil
            derivedReason = "unexpected_error"
            semanticValid = false
        }
        let accepted = materialValid && semanticValid
        let payload = NativeVerifierHashPayload(
            rowID: row.rowID,
            accepted: accepted,
            expectedCompletion: row.expectedCompletion,
            derivedCompletion: derivedCompletion,
            expectedSemanticAnswer: row.expectedSemanticAnswer,
            derivedSemanticAnswer: derivedSemanticAnswer,
            expectedAbstentionReason: row.abstentionReason,
            derivedAbstentionReason: derivedReason
        )
        return RowVerification(
            rowID: row.rowID,
            accepted: accepted,
            expectedCompletion: row.expectedCompletion,
            derivedCompletion: derivedCompletion,
            expectedSemanticAnswer: row.expectedSemanticAnswer,
            derivedSemanticAnswer: derivedSemanticAnswer,
            expectedAbstentionReason: row.abstentionReason,
            derivedAbstentionReason: derivedReason,
            verifierSHA256: canonicalSHA256(payload)
        )
    }

    /// Independently interprets a generated completion. Semantic correctness
    /// is not an alias for byte exact-match: for example `Result: 05.\n` can
    /// derive `number:5` while still failing the frozen exact-text contract.
    public static func verifyGeneratedCompletion(
        row: Row,
        completion: String
    ) -> GeneratedCompletionVerification {
        let canonical = PrimeNativeByteTokenizer.canonicalize(completion)
        let exact = canonical == row.expectedCompletion
        let abstained = canonical == "ABSTAIN\n"
        let derived: String?
        if abstained {
            derived = "abstain"
        } else if canonical.hasPrefix("Result: "),
                  canonical.hasSuffix(".\n") {
            let start = canonical.index(
                canonical.startIndex,
                offsetBy: "Result: ".count
            )
            let end = canonical.index(
                canonical.endIndex,
                offsetBy: -2
            )
            let value = String(canonical[start ..< end])
            if row.expectedSemanticAnswer.hasPrefix("number:"),
               let number = Int(value) {
                derived = "number:\(number)"
            } else if row.expectedSemanticAnswer.hasPrefix("boolean:"),
                      value == "yes" || value == "no" {
                derived = "boolean:\(value)"
            } else if row.expectedSemanticAnswer.hasPrefix("entity:") {
                if value == "none" {
                    derived = "entity:none"
                } else if let book = codebooks.first(where: {
                    $0.id == row.codebookID
                }), let slot = book.entityNames.firstIndex(of: value) {
                    derived = "entity:\(slot)"
                } else {
                    derived = nil
                }
            } else {
                derived = nil
            }
        } else {
            derived = nil
        }
        let semantic =
            row.split == Split.abstention.rawValue
                || row.split == Split.refusalTrain.rawValue
                || row.split == Split.refusalValidation.rawValue
                ? abstained
                : derived == row.expectedSemanticAnswer
        let payload = NativeGeneratedCompletionHashPayload(
            rowID: row.rowID,
            exactMatch: exact,
            semanticMatch: semantic,
            abstentionDecision: abstained,
            expectedSemanticAnswer: row.expectedSemanticAnswer,
            derivedSemanticAnswer: derived
        )
        return GeneratedCompletionVerification(
            rowID: row.rowID,
            exactMatch: exact,
            semanticMatch: semantic,
            abstentionDecision: abstained,
            expectedSemanticAnswer: row.expectedSemanticAnswer,
            derivedSemanticAnswer: derived,
            verificationSHA256: canonicalSHA256(payload)
        )
    }
}

private struct NativeGeneratedBase {
    let generated: NativeGeneratedProgram
    let codebook: ErgenticsPrimeNativeTextCorpus.Codebook
    let surface: ErgenticsPrimeNativeTextCorpus.SurfaceForm
    let row: ErgenticsPrimeNativeTextCorpus.Row
}

extension ErgenticsPrimeNativeTextCorpus {
    private static func finalizedRow(
        rowID: String,
        split: Split,
        family: SemanticFamily,
        generatorIndex: Int,
        generatorAttempt: Int,
        difficulty: Int,
        compositionDepth: Int,
        codebookID: String,
        surfaceFormID: String,
        promptText: String,
        expectedCompletion: String,
        expectedSemanticAnswer: String,
        semanticCanonical: String,
        invariantIDs: [String],
        mutationID: String? = nil,
        counterfactualOfRowID: String? = nil,
        parentSemanticSHA256: String? = nil,
        abstentionReason: String? = nil
    ) throws -> Row {
        let canonicalPrompt = PrimeNativeByteTokenizer.canonicalize(
            promptText
        )
        let canonicalCompletion = PrimeNativeByteTokenizer.canonicalize(
            expectedCompletion
        )
        let trainingText = canonicalPrompt + canonicalCompletion
        let promptIDs = PrimeNativeByteTokenizer.encode(canonicalPrompt)
        let completionIDs = PrimeNativeByteTokenizer.encode(
            canonicalCompletion
        )
        let sequenceIDs = PrimeNativeByteTokenizer.encodeSequence(
            trainingText
        )
        guard sequenceIDs.count <= maximumSequenceTokenCount else {
            throw CorpusError.sequenceTooLong(rowID, sequenceIDs.count)
        }
        let semanticHash = sha256(Data(semanticCanonical.utf8))
        let promptHash = sha256(Data(canonicalPrompt.utf8))
        let completionHash = sha256(Data(canonicalCompletion.utf8))
        let sequenceHash = PrimeNativeByteTokenizer.tokenIDsSHA256(
            sequenceIDs
        )

        func value(
            evaluationHash: String,
            rowHash: String
        ) -> Row {
            Row(
                rowID: rowID,
                split: split.rawValue,
                semanticFamily: family.rawValue,
                generatorIndex: generatorIndex,
                generatorAttempt: generatorAttempt,
                difficulty: difficulty,
                compositionDepth: compositionDepth,
                codebookID: codebookID,
                surfaceFormID: surfaceFormID,
                promptText: canonicalPrompt,
                expectedCompletion: canonicalCompletion,
                trainingText: trainingText,
                expectedSemanticAnswer: expectedSemanticAnswer,
                semanticCanonical: semanticCanonical,
                semanticSHA256: semanticHash,
                promptSHA256: promptHash,
                completionSHA256: completionHash,
                sequenceTokenSHA256: sequenceHash,
                promptTokenCount: promptIDs.count + 1,
                completionTokenCount: completionIDs.count + 1,
                sequenceTokenCount: sequenceIDs.count,
                invariantIDs: invariantIDs.sorted(),
                mutationID: mutationID,
                counterfactualOfRowID: counterfactualOfRowID,
                parentSemanticSHA256: parentSemanticSHA256,
                abstentionReason: abstentionReason,
                evaluationRowSHA256: evaluationHash,
                rowSHA256: rowHash
            )
        }
        let unhashed = value(evaluationHash: "", rowHash: "")
        let evaluationHash = evaluationRowSHA256(unhashed)
        let evaluationBound = value(
            evaluationHash: evaluationHash,
            rowHash: ""
        )
        let rowHash = rowContentSHA256(evaluationBound)
        let row = value(
            evaluationHash: evaluationHash,
            rowHash: rowHash
        )
        guard verify(row: row).accepted else {
            throw CorpusError.independentVerifierMismatch(rowID)
        }
        return row
    }

    private static func validBase(
        split: Split,
        index: Int,
        attempt: Int
    ) throws -> NativeGeneratedBase {
        let generated = generatedProgram(
            split: split,
            index: index,
            attempt: attempt
        )
        guard let answer = generated.program.evaluate() else {
            throw CorpusError.rowReplayMismatch(
                "\(split.rawValue)-\(index)"
            )
        }
        let entropy = NativeEntropy(
            split: split,
            index: index,
            attempt: attempt
        )
        let pair = pair(split: split, entropy: entropy)
        let prompt = render(
            generated,
            codebook: pair.0,
            surface: pair.1
        )
        let completion =
            "Result: \(answer.display(using: pair.0)).\n"
        let rowID = [
            split.rawValue,
            String(format: "%06d", index),
            generated.family.rawValue,
        ].joined(separator: "-")
        let row = try finalizedRow(
            rowID: rowID,
            split: split,
            family: generated.family,
            generatorIndex: index,
            generatorAttempt: attempt,
            difficulty: generated.difficulty,
            compositionDepth: generated.depth,
            codebookID: pair.0.id,
            surfaceFormID: pair.1.id,
            promptText: prompt,
            expectedCompletion: completion,
            expectedSemanticAnswer: answer.canonical,
            semanticCanonical: generated.program.canonical,
            invariantIDs: generated.invariants
        )
        return NativeGeneratedBase(
            generated: generated,
            codebook: pair.0,
            surface: pair.1,
            row: row
        )
    }

    private static func mutated(
        _ program: NativeProgram,
        variant: Int
    ) -> (NativeProgram, String) {
        switch program {
        case .scalar(let value):
            var operations = value.operations
            operations.append(.add(31 + variant))
            return (
                .scalar(
                    NativeScalarProgram(
                        initial: value.initial,
                        operations: operations
                    )
                ),
                "counterfactual_terminal_add"
            )
        case .transfer(let value):
            var operations = value.operations
            let queried: Int
            let query: NativeTransferQuery
            switch value.query {
            case .entity(let slot):
                queried = slot
                query = value.query
            case .total:
                queried = 0
                query = .entity(0)
            }
            operations.append(
                .move(
                    amount: 31 + variant,
                    from: queried,
                    to: (queried + 1) % 3
                )
            )
            return (
                .transfer(
                    NativeTransferProgram(
                        initial: value.initial,
                        operations: operations,
                        query: query
                    )
                ),
                "counterfactual_transfer_direction"
            )
        case .ordering(let value):
            let query: NativeOrderingQuery
            switch value.query {
            case .before:
                query = .position(variant % 5)
            case .position:
                query = .before(variant % 5, (variant + 1) % 5)
            case .immediatelyBefore:
                query = .position(variant % 5)
            }
            return (
                .ordering(
                    NativeOrderingProgram(
                        initialOrder: value.initialOrder,
                        operations: value.operations,
                        query: query
                    )
                ),
                "counterfactual_order_query"
            )
        case .relation(let value):
            let query: NativeRelationQuery
            switch value.query {
            case .signedDistance(let source, let destination):
                query = .notRight(left: destination, right: source)
            case .notRight(let left, let right):
                query = .signedDistance(from: right, to: left)
            }
            return (
                .relation(
                    NativeRelationProgram(
                        edges: value.edges,
                        query: query
                    )
                ),
                "counterfactual_relation_query"
            )
        }
    }

    private static func mutationBase(
        index: Int,
        parent: NativeGeneratedBase,
        attempt: Int
    ) throws -> NativeGeneratedBase {
        let mutation = mutated(
            parent.generated.program,
            variant: attempt
        )
        let generated = NativeGeneratedProgram(
            family: parent.generated.family,
            program: mutation.0,
            difficulty: parent.generated.difficulty + 1,
            depth: parent.generated.depth + 1,
            invariants: (
                parent.generated.invariants
                    + ["counterfactual_mutation"]
            ).sorted()
        )
        guard let answer = generated.program.evaluate(),
              answer.canonical
                != parent.generated.program.evaluate()?.canonical else {
            throw CorpusError.rowReplayMismatch(
                "mutation-\(index)-unchanged"
            )
        }
        let prompt = render(
            generated,
            codebook: parent.codebook,
            surface: parent.surface
        )
        let completion =
            "Result: \(answer.display(using: parent.codebook)).\n"
        let rowID = [
            Split.mutation.rawValue,
            String(format: "%06d", index),
            generated.family.rawValue,
        ].joined(separator: "-")
        let row = try finalizedRow(
            rowID: rowID,
            split: .mutation,
            family: generated.family,
            generatorIndex: index,
            generatorAttempt: attempt,
            difficulty: generated.difficulty,
            compositionDepth: generated.depth,
            codebookID: parent.codebook.id,
            surfaceFormID: parent.surface.id,
            promptText: prompt,
            expectedCompletion: completion,
            expectedSemanticAnswer: answer.canonical,
            semanticCanonical: generated.program.canonical,
            invariantIDs: generated.invariants,
            mutationID: mutation.1,
            counterfactualOfRowID: parent.row.rowID,
            parentSemanticSHA256: parent.row.semanticSHA256
        )
        return NativeGeneratedBase(
            generated: generated,
            codebook: parent.codebook,
            surface: parent.surface,
            row: row
        )
    }

    private static func specificRefusalFailure(
        for family: SemanticFamily
    ) -> NativeParseFailure {
        switch family {
        case .arithmeticComposition:
            .invalidNumber
        case .negationComposition:
            .unknownOperation
        case .conservedTransfer:
            .unknownEntity
        case .sequenceOrdering:
            .duplicateEntity
        case .multiStepRelation:
            .contradictoryRelation
        case .reversibleTransform:
            .missingHistory
        }
    }

    private static func refusalFailure(
        family: SemanticFamily,
        index: Int
    ) -> NativeParseFailure {
        let familyCycle = index / SemanticFamily.allCases.count
        return familyCycle.isMultiple(of: 2)
            ? .ambiguousQuery
            : specificRefusalFailure(for: family)
    }

    /// Every malformed category is taught, tuned, and finally evaluated on a
    /// different surface contract. The category itself transfers; the exact
    /// category + mutation + surface tuple does not.
    private static func refusalSurfaceID(
        for failure: NativeParseFailure,
        split: Split
    ) -> String {
        let categoryOffset: Int
        switch failure {
        case .ambiguousQuery:
            categoryOffset = 0
        case .invalidNumber, .unknownEntity, .contradictoryRelation:
            categoryOffset = 1
        case .unknownOperation, .duplicateEntity, .missingHistory:
            categoryOffset = 2
        case .malformedPrompt:
            preconditionFailure(
                "Generic malformed_prompt is not a refusal curriculum category."
            )
        }
        let poolOffset: Int
        switch split {
        case .refusalTrain:
            poolOffset = 0
        case .refusalValidation:
            poolOffset = 1
        case .abstention:
            poolOffset = 2
        default:
            preconditionFailure(
                "\(split.rawValue) is not a refusal curriculum split."
            )
        }
        let surfaces = ["initial", "start", "opening"]
        return surfaces[(categoryOffset + poolOffset) % surfaces.count]
    }

    private static func malformedPrompt(
        parent: NativeGeneratedBase,
        failure: NativeParseFailure
    ) -> (String, NativeParseFailure, String) {
        var lines = parent.row.promptText.split(
            separator: "\n",
            omittingEmptySubsequences: true
        ).map(String.init)

        if failure == .ambiguousQuery,
           let questionIndex = lines.indices.first(where: {
               NativeIndependentTextVerifierQuestion.isQuestionLike(
                   lines[$0]
               )
           })
        {
            lines.insert(lines[questionIndex], at: questionIndex + 1)
            return (
                lines.joined(separator: "\n") + "\n",
                .ambiguousQuery,
                "malformed_ambiguous_query"
            )
        }

        switch (parent.generated.family, failure) {
        case (.arithmeticComposition, .invalidNumber):
            if let actionIndex = lines.indices.first(where: {
                lines[$0].contains(", add ")
                    || lines[$0].contains(", subtract ")
            }) {
                let line = lines[actionIndex]
                let regex = try! NSRegularExpression(
                    pattern: #"(add|subtract) [0-9]+"#
                )
                let range = NSRange(
                    line.startIndex ..< line.endIndex,
                    in: line
                )
                lines[actionIndex] = regex.stringByReplacingMatches(
                    in: line,
                    options: [],
                    range: range,
                    withTemplate: "$1 many"
                )
            }
            return (
                lines.joined(separator: "\n") + "\n",
                .invalidNumber,
                "malformed_invalid_number"
            )

        case (.negationComposition, .unknownOperation):
            if let actionIndex = lines.indices.first(where: {
                lines[$0].contains(", negate ")
            }) {
                lines[actionIndex] = lines[actionIndex]
                    .replacingOccurrences(of: "negate", with: "rotate")
            }
            return (
                lines.joined(separator: "\n") + "\n",
                .unknownOperation,
                "malformed_unknown_operation"
            )

        case (.conservedTransfer, .unknownEntity):
            if let actionIndex = lines.indices.first(where: {
                lines[$0].contains(", move ")
            }) {
                let line = lines[actionIndex]
                if let range = line.range(of: " to "),
                   let period = line[range.upperBound...]
                    .firstIndex(of: ".")
                {
                    lines[actionIndex].replaceSubrange(
                        range.upperBound ..< period,
                        with: "unknown"
                    )
                }
            }
            return (
                lines.joined(separator: "\n") + "\n",
                .unknownEntity,
                "malformed_unknown_entity"
            )

        case (.sequenceOrdering, .duplicateEntity):
            let first = parent.codebook.entityNames[0]
            let second = parent.codebook.entityNames[1]
            lines[0] = lines[0].replacingOccurrences(
                of: second,
                with: first
            )
            return (
                lines.joined(separator: "\n") + "\n",
                .duplicateEntity,
                "malformed_duplicate_entity"
            )

        case (.multiStepRelation, .contradictoryRelation):
            if let relationIndex = lines.indices.first(where: {
                lines[$0].contains(" steps ")
                    && lines[$0].contains(" of ")
            }), let questionIndex = lines.indices.first(where: {
                NativeIndependentTextVerifierQuestion.isQuestionLike(
                    lines[$0]
                )
            }) {
                let action = String(
                    lines[relationIndex].split(
                        separator: ",",
                        maxSplits: 1
                    )[1]
                ).trimmingCharacters(in: .whitespaces)
                if let captures = NativeTextRegex.captures(
                    NativeTextRegex.relation,
                    in: action
                ), let amount = Int(captures[1]) {
                    let contradiction = [
                        "Then,",
                        "\(captures[0]) is \(amount + 1) steps \(captures[2]) of \(captures[3]).",
                    ].joined(separator: " ")
                    lines.insert(contradiction, at: questionIndex)
                }
            }
            return (
                lines.joined(separator: "\n") + "\n",
                .contradictoryRelation,
                "malformed_contradictory_relation"
            )

        case (.reversibleTransform, .missingHistory):
            if lines.count > 2 {
                lines[1] =
                    "First, undo the previous change to \(parent.codebook.entityNames[0])."
            }
            return (
                lines.joined(separator: "\n") + "\n",
                .missingHistory,
                "malformed_missing_history"
            )

        default:
            preconditionFailure(
                "Refusal category \(failure.rawValue) is invalid for \(parent.generated.family.rawValue)."
            )
        }
    }

    private static func refusalBase(
        index: Int,
        parent: NativeGeneratedBase,
        split: Split,
        failure: NativeParseFailure
    ) throws -> NativeGeneratedBase {
        precondition(
            split == .refusalTrain
                || split == .refusalValidation
                || split == .abstention
        )
        let malformed = malformedPrompt(
            parent: parent,
            failure: failure
        )
        let semantic = [
            "malformed",
            split.rawValue,
            malformed.1.rawValue,
            parent.row.semanticSHA256,
            String(index),
        ].joined(separator: "|")
        let rowID = [
            split.rawValue,
            String(format: "%06d", index),
            parent.generated.family.rawValue,
        ].joined(separator: "-")
        let row = try finalizedRow(
            rowID: rowID,
            split: split,
            family: parent.generated.family,
            generatorIndex: index,
            generatorAttempt: 0,
            difficulty: parent.generated.difficulty + 1,
            compositionDepth: parent.generated.depth,
            codebookID: parent.codebook.id,
            surfaceFormID: parent.surface.id,
            promptText: malformed.0,
            expectedCompletion: "ABSTAIN\n",
            expectedSemanticAnswer:
                "abstain:\(malformed.1.rawValue)",
            semanticCanonical: semantic,
            invariantIDs: [
                "malformed_input_rejection",
                "verify_abstain",
            ],
            mutationID: malformed.2,
            counterfactualOfRowID: parent.row.rowID,
            parentSemanticSHA256: parent.row.semanticSHA256,
            abstentionReason: malformed.1.rawValue
        )
        return NativeGeneratedBase(
            generated: parent.generated,
            codebook: parent.codebook,
            surface: parent.surface,
            row: row
        )
    }
}

/// Keeps question detection independently scoped from the renderer while
/// allowing malformed-row synthesis to insert a second query.
private enum NativeIndependentTextVerifierQuestion {
    static func isQuestionLike(_ line: String) -> Bool {
        [
            "What ", "Which ", "Is ", "Return ", "Report ",
            "Give ", "Determine ",
        ].contains { line.hasPrefix($0) }
    }
}

private struct NativeGeneratedCorpus {
    let rowsBySplit:
        [ErgenticsPrimeNativeTextCorpus.Split:
            [ErgenticsPrimeNativeTextCorpus.Row]]
}

extension ErgenticsPrimeNativeTextCorpus {
    private static let generatedCorpus: NativeGeneratedCorpus = {
        var rowsBySplit: [Split: [Row]] = [:]
        var seenSemanticHashes = Set<String>()
        var seenRowHashes = Set<String>()
        var seenPromptHashes = Set<String>()
        var validationBases: [NativeGeneratedBase] = []
        var combinationBases: [NativeGeneratedBase] = []

        for split in [
            Split.train,
            .validation,
            .combinationHoldout,
            .ood,
        ] {
            let count = rowCounts[split]!
            var rows: [Row] = []
            rows.reserveCapacity(count)
            if split == .validation {
                validationBases.reserveCapacity(count)
            }
            if split == .combinationHoldout {
                combinationBases.reserveCapacity(count)
            }
            for index in 0 ..< count {
                var accepted: NativeGeneratedBase?
                for attempt in 0 ..< 1_024 {
                    guard let candidate = try? validBase(
                        split: split,
                        index: index,
                        attempt: attempt
                    ) else {
                        continue
                    }
                    guard !seenSemanticHashes.contains(
                        candidate.row.semanticSHA256
                    ), !seenRowHashes.contains(candidate.row.rowSHA256),
                    !seenPromptHashes.contains(candidate.row.promptSHA256)
                    else {
                        continue
                    }
                    accepted = candidate
                    break
                }
                guard let accepted else {
                    preconditionFailure(
                        "Unable to generate unique \(split.rawValue) row \(index)"
                    )
                }
                seenSemanticHashes.insert(accepted.row.semanticSHA256)
                seenRowHashes.insert(accepted.row.rowSHA256)
                seenPromptHashes.insert(accepted.row.promptSHA256)
                rows.append(accepted.row)
                if split == .validation {
                    validationBases.append(accepted)
                }
                if split == .combinationHoldout {
                    combinationBases.append(accepted)
                }
            }
            rowsBySplit[split] = rows
        }

        var mutationRows: [Row] = []
        mutationRows.reserveCapacity(rowCounts[.mutation]!)
        for index in 0 ..< rowCounts[.mutation]! {
            let parent = combinationBases[index % combinationBases.count]
            var accepted: NativeGeneratedBase?
            for attempt in 0 ..< 1_024 {
                guard let candidate = try? mutationBase(
                    index: index,
                    parent: parent,
                    attempt: attempt
                ) else {
                    continue
                }
                guard !seenSemanticHashes.contains(
                    candidate.row.semanticSHA256
                ), !seenRowHashes.contains(candidate.row.rowSHA256),
                !seenPromptHashes.contains(candidate.row.promptSHA256)
                else {
                    continue
                }
                accepted = candidate
                break
            }
            guard let accepted else {
                preconditionFailure(
                    "Unable to generate unique mutation row \(index)"
                )
            }
            seenSemanticHashes.insert(accepted.row.semanticSHA256)
            seenRowHashes.insert(accepted.row.rowSHA256)
            seenPromptHashes.insert(accepted.row.promptSHA256)
            mutationRows.append(accepted.row)
        }
        rowsBySplit[.mutation] = mutationRows

        func parentKey(
            family: String,
            surfaceFormID: String
        ) -> String {
            "\(family)|\(surfaceFormID)"
        }
        let trainRowsByParentKey = Dictionary(
            grouping: rowsBySplit[.train]!
        ) {
            parentKey(
                family: $0.semanticFamily,
                surfaceFormID: $0.surfaceFormID
            )
        }
        let validationBasesByParentKey = Dictionary(
            grouping: validationBases
        ) {
            parentKey(
                family: $0.generated.family.rawValue,
                surfaceFormID: $0.surface.id
            )
        }
        let combinationBasesByParentKey = Dictionary(
            grouping: combinationBases
        ) {
            parentKey(
                family: $0.generated.family.rawValue,
                surfaceFormID: $0.surface.id
            )
        }

        func generateRefusalSplit(
            _ split: Split,
            parentAt: (String, Int) -> NativeGeneratedBase
        ) {
            var refusalRows: [Row] = []
            refusalRows.reserveCapacity(rowCounts[split]!)
            var parentCursors: [String: Int] = [:]
            for index in 0 ..< rowCounts[split]! {
                let semanticFamily = family(index: index)
                let failure = refusalFailure(
                    family: semanticFamily,
                    index: index
                )
                let surfaceFormID = refusalSurfaceID(
                    for: failure,
                    split: split
                )
                let key = parentKey(
                    family: semanticFamily.rawValue,
                    surfaceFormID: surfaceFormID
                )
                var accepted: NativeGeneratedBase?
                for _ in 0 ..< 1_024 {
                    let cursor = parentCursors[key, default: 0]
                    parentCursors[key] = cursor + 1
                    let parent = parentAt(key, cursor)
                    precondition(
                        parent.generated.family == semanticFamily
                            && parent.surface.id == surfaceFormID,
                        "Refusal parent contract mismatch for \(split.rawValue) row \(index)."
                    )
                    guard let value = try? refusalBase(
                        index: index,
                        parent: parent,
                        split: split,
                        failure: failure
                    ), !seenSemanticHashes.contains(
                        value.row.semanticSHA256
                    ), !seenRowHashes.contains(value.row.rowSHA256),
                    !seenPromptHashes.contains(value.row.promptSHA256)
                    else {
                        continue
                    }
                    accepted = value
                    break
                }
                guard let accepted else {
                    preconditionFailure(
                        "Unable to generate \(split.rawValue) row \(index)"
                    )
                }
                seenSemanticHashes.insert(accepted.row.semanticSHA256)
                seenRowHashes.insert(accepted.row.rowSHA256)
                seenPromptHashes.insert(accepted.row.promptSHA256)
                refusalRows.append(accepted.row)
            }
            rowsBySplit[split] = refusalRows
        }

        generateRefusalSplit(.refusalTrain) { key, cursor in
            guard let candidates = trainRowsByParentKey[key],
                  cursor < candidates.count else {
                preconditionFailure(
                    "Insufficient train parents for \(key) at \(cursor)."
                )
            }
            let row = candidates[cursor]
            guard let reconstructed = try? validBase(
                split: .train,
                index: row.generatorIndex,
                attempt: row.generatorAttempt
            ), reconstructed.row == row else {
                preconditionFailure(
                    "Unable to replay train refusal parent \(row.rowID)."
                )
            }
            return reconstructed
        }
        generateRefusalSplit(.refusalValidation) { key, cursor in
            guard let candidates = validationBasesByParentKey[key],
                  cursor < candidates.count else {
                preconditionFailure(
                    "Insufficient validation parents for \(key) at \(cursor)."
                )
            }
            return candidates[cursor]
        }
        generateRefusalSplit(.abstention) { key, cursor in
            guard let candidates = combinationBasesByParentKey[key],
                  cursor < candidates.count else {
                preconditionFailure(
                    "Insufficient final abstention parents for \(key) at \(cursor)."
                )
            }
            return candidates[cursor]
        }

        return NativeGeneratedCorpus(rowsBySplit: rowsBySplit)
    }()

    public static func rows(for split: Split) -> [Row] {
        generatedCorpus.rowsBySplit[split]!
    }

    public static func trainingRefusalRows() -> [Row] {
        rows(for: .refusalTrain)
    }

    public static func rows(forSplitName split: String) throws -> [Row] {
        guard let value = Split(rawValue: split) else {
            throw CorpusError.unsupportedSplit(split)
        }
        return rows(for: value)
    }

    public static func allRows() -> [Row] {
        Split.allCases.flatMap { rows(for: $0) }
    }
}

private struct NativeManifestPayload: Encodable {
    let schemaVersion: String
    let corpusID: String
    let ownership: String
    let license: String
    let productAuthorization: String
    let tokenizerID: String
    let tokenizerManifestSHA256: String
    let modelVocabularySize: Int
    let generator: ErgenticsPrimeNativeTextCorpus.GeneratorContract
    let codebooks: [ErgenticsPrimeNativeTextCorpus.Codebook]
    let surfaceForms: [ErgenticsPrimeNativeTextCorpus.SurfaceForm]
    let splitEvidence: [ErgenticsPrimeNativeTextCorpus.SplitEvidence]
    let tokenAccounting: ErgenticsPrimeNativeTextCorpus.TokenAccounting
    let leakageEvidence: ErgenticsPrimeNativeTextCorpus.LeakageEvidence
    let refusalCurriculumEvidence:
        ErgenticsPrimeNativeTextCorpus.RefusalCurriculumEvidence
    let falsifiers: [ErgenticsPrimeNativeTextCorpus.FalsifierEvidence]
    let evaluationContract:
        ErgenticsPrimeNativeTextCorpus.EvaluationContract
    let orderedCorpusRowsSHA256: String
    let falsifierSHA256: String

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case corpusID = "corpus_id"
        case ownership
        case license
        case productAuthorization = "product_authorization"
        case tokenizerID = "tokenizer_id"
        case tokenizerManifestSHA256 = "tokenizer_manifest_sha256"
        case modelVocabularySize = "model_vocabulary_size"
        case generator
        case codebooks
        case surfaceForms = "surface_forms"
        case splitEvidence = "split_evidence"
        case tokenAccounting = "token_accounting"
        case leakageEvidence = "leakage_evidence"
        case refusalCurriculumEvidence =
            "refusal_curriculum_evidence"
        case falsifiers
        case evaluationContract = "evaluation_contract"
        case orderedCorpusRowsSHA256 =
            "ordered_corpus_rows_sha256"
        case falsifierSHA256 = "falsifier_sha256"
    }
}

extension ErgenticsPrimeNativeTextCorpus {
    private static func counts(
        _ values: [String]
    ) -> [CoverageCount] {
        Dictionary(grouping: values, by: { $0 })
            .map { CoverageCount(id: $0.key, rowCount: $0.value.count) }
            .sorted { $0.id < $1.id }
    }

    private static func splitEvidence(
        split: Split,
        rows: [Row]
    ) -> SplitEvidence {
        var observedTokenTypes = Set<Int>()
        var sequenceLengths: [String: Int] = [:]
        var rawTokenInstances = 0
        for row in rows {
            let sequence = PrimeNativeByteTokenizer.encodeSequence(
                row.trainingText
            )
            rawTokenInstances += sequence.count
            observedTokenTypes.formUnion(sequence)
            sequenceLengths[row.sequenceTokenSHA256] = sequence.count
        }
        let verifications = rows.map(verify(row:))
        let familyCounts = Dictionary(
            grouping: rows,
            by: \.semanticFamily
        ).map {
            FamilyCount(
                semanticFamily: $0.key,
                rowCount: $0.value.count
            )
        }.sorted { $0.semanticFamily < $1.semanticFamily }
        let pairs = Dictionary(grouping: rows) {
            "\($0.codebookID)|\($0.surfaceFormID)"
        }.map { key, grouped in
            let pieces = key.split(separator: "|")
            return PairCount(
                codebookID: String(pieces[0]),
                surfaceFormID: String(pieces[1]),
                rowCount: grouped.count
            )
        }.sorted {
            ($0.codebookID, $0.surfaceFormID)
                < ($1.codebookID, $1.surfaceFormID)
        }
        let promptSet = Set(rows.map(\.promptSHA256))
        let sequenceSet = Set(rows.map(\.sequenceTokenSHA256))
        let semanticSet = Set(rows.map(\.semanticSHA256))
        return SplitEvidence(
            split: split.rawValue,
            rowCount: rows.count,
            uniquePromptCount: promptSet.count,
            uniqueSequenceCount: sequenceSet.count,
            uniqueSemanticCombinationCount: semanticSet.count,
            rawTokenInstances: rawTokenInstances,
            deduplicatedSequenceTokenInstances:
                sequenceLengths.values.reduce(0, +),
            observedTokenTypeCount: observedTokenTypes.count,
            minimumSequenceTokenCount:
                rows.map(\.sequenceTokenCount).min() ?? 0,
            maximumSequenceTokenCount:
                rows.map(\.sequenceTokenCount).max() ?? 0,
            familyCounts: familyCounts,
            invariantCounts: counts(
                rows.flatMap(\.invariantIDs)
            ),
            mutationCounts: counts(
                rows.compactMap(\.mutationID)
            ),
            codebookSurfacePairCounts: pairs,
            orderedRowsSHA256: canonicalSHA256(
                rows.map(\.rowSHA256)
            ),
            orderedEvaluationRowsSHA256: canonicalSHA256(
                rows.map(\.evaluationRowSHA256)
            ),
            semanticSetSHA256: canonicalSHA256(
                semanticSet.sorted()
            ),
            promptSetSHA256: canonicalSHA256(
                promptSet.sorted()
            ),
            sequenceSetSHA256: canonicalSHA256(
                sequenceSet.sorted()
            ),
            independentRegradeSHA256: canonicalSHA256(
                verifications.map(\.verifierSHA256)
            ),
            allRowsIndependentlyVerified:
                verifications.allSatisfy(\.accepted)
        )
    }

    private static func tokenAccounting(
        rows: [Row]
    ) -> TokenAccounting {
        var observedTypes = Set<Int>()
        var uniqueSequenceLengths: [String: Int] = [:]
        var rawInstances = 0
        for row in rows {
            let sequence = PrimeNativeByteTokenizer.encodeSequence(
                row.trainingText
            )
            rawInstances += sequence.count
            observedTypes.formUnion(sequence)
            uniqueSequenceLengths[row.sequenceTokenSHA256] = sequence.count
        }
        return TokenAccounting(
            vocabularyTokenTypeCount:
                PrimeNativeByteTokenizer.boundModelVocabularySize,
            observedTokenTypeCount: observedTypes.count,
            rawTokenInstances: rawInstances,
            deduplicatedSequenceTokenInstances:
                uniqueSequenceLengths.values.reduce(0, +),
            uniqueSequenceCount: uniqueSequenceLengths.count,
            uniqueSemanticCombinationCount:
                Set(rows.map(\.semanticSHA256)).count
        )
    }

    private static func pairSet(_ rows: [Row]) -> Set<String> {
        Set(rows.map { "\($0.codebookID)|\($0.surfaceFormID)" })
    }

    private static func refusalContractID(_ row: Row) -> String {
        [
            row.abstentionReason!,
            row.mutationID!,
            row.surfaceFormID,
        ].joined(separator: "|")
    }

    private static func leakageEvidence() -> LeakageEvidence {
        let validTrain = rows(for: .train)
        let refusalTrain = rows(for: .refusalTrain)
        let train = validTrain + refusalTrain
        let evaluation = [
            Split.validation,
            .refusalValidation,
            .combinationHoldout,
            .ood,
            .mutation,
            .abstention,
        ].flatMap { rows(for: $0) }
        let validSplits = [
            Split.train,
            .validation,
            .combinationHoldout,
            .ood,
            .mutation,
        ]
        let trainPrompts = Set(train.map(\.promptSHA256))
        let evaluationPrompts = Set(evaluation.map(\.promptSHA256))
        let trainSemantics = Set(train.map(\.semanticSHA256))
        let evaluationSemantics = Set(
            evaluation.map(\.semanticSHA256)
        )
        let combination = rows(for: .combinationHoldout)
        let ood = rows(for: .ood)
        let trainPairs = pairSet(validTrain)
        let combinationPairs = pairSet(combination)
        let trainCodebooks = Set(validTrain.map(\.codebookID))
        let trainSurfaces = Set(validTrain.map(\.surfaceFormID))
        let combinationCodebooks = Set(combination.map(\.codebookID))
        let combinationSurfaces = Set(combination.map(\.surfaceFormID))
        let oodCodebooks = Set(ood.map(\.codebookID))
        let oodSurfaces = Set(ood.map(\.surfaceFormID))

        var semanticOwner: [String: Split] = [:]
        var disjoint = true
        for split in validSplits {
            for hash in rows(for: split).map(\.semanticSHA256) {
                if semanticOwner.updateValue(split, forKey: hash) != nil {
                    disjoint = false
                }
            }
        }
        let all = allRows()
        return LeakageEvidence(
            trainEvaluationPromptOverlapCount:
                trainPrompts.intersection(evaluationPrompts).count,
            trainEvaluationSemanticOverlapCount:
                trainSemantics.intersection(evaluationSemantics).count,
            refusalTrainEvaluationPromptOverlapCount:
                Set(refusalTrain.map(\.promptSHA256))
                    .intersection(evaluationPrompts).count,
            refusalTrainEvaluationSemanticOverlapCount:
                Set(refusalTrain.map(\.semanticSHA256))
                    .intersection(evaluationSemantics).count,
            refusalTrainAbstentionContractOverlapCount:
                Set(refusalTrain.map(refusalContractID))
                    .intersection(
                        Set(
                            rows(for: .abstention).map(
                                refusalContractID
                            )
                        )
                    ).count,
            trainCombinationPairOverlapCount:
                trainPairs.intersection(combinationPairs).count,
            trainCombinationCodebookIDIntersectionCount:
                trainCodebooks.intersection(combinationCodebooks).count,
            trainCombinationSurfaceIDIntersectionCount:
                trainSurfaces.intersection(combinationSurfaces).count,
            trainOODCodebookIDIntersectionCount:
                trainCodebooks.intersection(oodCodebooks).count,
            trainOODSurfaceIDIntersectionCount:
                trainSurfaces.intersection(oodSurfaces).count,
            combinationComponentsSeenInTrain:
                combinationCodebooks.isSubset(of: trainCodebooks)
                    && combinationSurfaces.isSubset(of: trainSurfaces),
            combinationPairsAbsentFromTrain:
                trainPairs.isDisjoint(with: combinationPairs),
            exactLookupEvaluationHits:
                trainPrompts.intersection(evaluationPrompts).count,
            allRowIDsUnique:
                Set(all.map(\.rowID)).count == all.count,
            allRowHashesUnique:
                Set(all.map(\.rowSHA256)).count == all.count,
            allValidSemanticsDisjointAcrossSplits: disjoint
        )
    }

    private static func refusalContractCounts(
        _ rows: [Row]
    ) -> [RefusalContractCount] {
        Dictionary(grouping: rows, by: refusalContractID)
            .map { _, grouped in
                let row = grouped[0]
                return RefusalContractCount(
                    abstentionReason: row.abstentionReason!,
                    mutationID: row.mutationID!,
                    surfaceFormID: row.surfaceFormID,
                    rowCount: grouped.count
                )
            }
            .sorted {
                (
                    $0.abstentionReason,
                    $0.mutationID,
                    $0.surfaceFormID
                ) < (
                    $1.abstentionReason,
                    $1.mutationID,
                    $1.surfaceFormID
                )
            }
    }

    private static func refusalCurriculumEvidence()
        -> RefusalCurriculumEvidence
    {
        let training = rows(for: .refusalTrain)
        let tuning = rows(for: .refusalValidation)
        let finalEvaluation = rows(for: .abstention)
        let trainingPrompts = Set(training.map(\.promptSHA256))
        let tuningPrompts = Set(tuning.map(\.promptSHA256))
        let finalPrompts = Set(
            finalEvaluation.map(\.promptSHA256)
        )
        let trainingSemantics = Set(training.map(\.semanticSHA256))
        let tuningSemantics = Set(tuning.map(\.semanticSHA256))
        let finalSemantics = Set(
            finalEvaluation.map(\.semanticSHA256)
        )
        let trainingContracts = Set(
            training.map(refusalContractID)
        )
        let tuningContracts = Set(tuning.map(refusalContractID))
        let finalContracts = Set(
            finalEvaluation.map(refusalContractID)
        )
        let trainingReasons = Set(
            training.compactMap(\.abstentionReason)
        )
        let tuningReasons = Set(
            tuning.compactMap(\.abstentionReason)
        )
        let finalReasons = Set(
            finalEvaluation.compactMap(\.abstentionReason)
        )
        let trainingRegrades = training.map(verify(row:))
        let tuningRegrades = tuning.map(verify(row:))
        let finalRegrades = finalEvaluation.map(verify(row:))

        return RefusalCurriculumEvidence(
            trainingSplit: Split.refusalTrain.rawValue,
            tuningSplit: Split.refusalValidation.rawValue,
            finalEvaluationSplit: Split.abstention.rawValue,
            trainingRowCount: training.count,
            tuningRowCount: tuning.count,
            finalEvaluationRowCount: finalEvaluation.count,
            trainingReasonCounts: counts(
                training.compactMap(\.abstentionReason)
            ),
            tuningReasonCounts: counts(
                tuning.compactMap(\.abstentionReason)
            ),
            finalEvaluationReasonCounts: counts(
                finalEvaluation.compactMap(\.abstentionReason)
            ),
            trainingContractCounts:
                refusalContractCounts(training),
            tuningContractCounts:
                refusalContractCounts(tuning),
            finalEvaluationContractCounts:
                refusalContractCounts(finalEvaluation),
            trainingPromptSetSHA256: canonicalSHA256(
                trainingPrompts.sorted()
            ),
            tuningPromptSetSHA256: canonicalSHA256(
                tuningPrompts.sorted()
            ),
            finalEvaluationPromptSetSHA256: canonicalSHA256(
                finalPrompts.sorted()
            ),
            trainingSemanticSetSHA256: canonicalSHA256(
                trainingSemantics.sorted()
            ),
            tuningSemanticSetSHA256: canonicalSHA256(
                tuningSemantics.sorted()
            ),
            finalEvaluationSemanticSetSHA256: canonicalSHA256(
                finalSemantics.sorted()
            ),
            trainingIndependentRegradeSHA256: canonicalSHA256(
                trainingRegrades.map(\.verifierSHA256)
            ),
            tuningIndependentRegradeSHA256: canonicalSHA256(
                tuningRegrades.map(\.verifierSHA256)
            ),
            finalEvaluationIndependentRegradeSHA256:
                canonicalSHA256(
                    finalRegrades.map(\.verifierSHA256)
                ),
            trainingTuningPromptOverlapCount:
                trainingPrompts.intersection(tuningPrompts).count,
            trainingFinalEvaluationPromptOverlapCount:
                trainingPrompts.intersection(finalPrompts).count,
            tuningFinalEvaluationPromptOverlapCount:
                tuningPrompts.intersection(finalPrompts).count,
            trainingTuningSemanticOverlapCount:
                trainingSemantics.intersection(tuningSemantics).count,
            trainingFinalEvaluationSemanticOverlapCount:
                trainingSemantics.intersection(finalSemantics).count,
            tuningFinalEvaluationSemanticOverlapCount:
                tuningSemantics.intersection(finalSemantics).count,
            trainingTuningMutationContractOverlapCount:
                trainingContracts.intersection(tuningContracts).count,
            trainingFinalEvaluationMutationContractOverlapCount:
                trainingContracts.intersection(finalContracts).count,
            tuningFinalEvaluationMutationContractOverlapCount:
                tuningContracts.intersection(finalContracts).count,
            allReasonsTaughtBeforeTuningAndEvaluation:
                tuningReasons.isSubset(of: trainingReasons)
                    && finalReasons.isSubset(of: trainingReasons),
            allTuningAndEvaluationContractsHeldOut:
                trainingContracts.isDisjoint(with: tuningContracts)
                    && trainingContracts.isDisjoint(
                        with: finalContracts
                    )
                    && tuningContracts.isDisjoint(
                        with: finalContracts
                    ),
            allRowsIndependentlyVerified:
                trainingRegrades.allSatisfy(\.accepted)
                    && tuningRegrades.allSatisfy(\.accepted)
                    && finalRegrades.allSatisfy(\.accepted)
        )
    }

    private static func falsifierEvidence(
        leakage: LeakageEvidence,
        refusal: RefusalCurriculumEvidence
    ) -> [FalsifierEvidence] {
        let validation = Array(rows(for: .validation).prefix(1_024))
        var shuffledDetections = 0
        for (index, row) in validation.enumerated() {
            var offset = 1
            var wrong = validation[(index + offset) % validation.count]
                .expectedCompletion
            while wrong == row.expectedCompletion,
                  offset < validation.count {
                offset += 1
                wrong = validation[(index + offset) % validation.count]
                    .expectedCompletion
            }
            let parsed = try! NativeIndependentTextVerifier.parse(
                row.promptText
            )
            let derived =
                "Result: \(parsed.answer.display(using: parsed.codebook)).\n"
            shuffledDetections += derived != wrong ? 1 : 0
        }

        let ordered = NativeScalarProgram(
            initial: 4,
            operations: [.add(3), .negate]
        ).evaluate()
        let reordered = NativeScalarProgram(
            initial: 4,
            operations: [.negate, .add(3)]
        ).evaluate()
        let withNegation = NativeScalarProgram(
            initial: 5,
            operations: [.add(2), .negate]
        ).evaluate()
        let withoutNegation = NativeScalarProgram(
            initial: 5,
            operations: [.add(2)]
        ).evaluate()
        let withReversal = NativeScalarProgram(
            initial: 3,
            operations: [.add(9), .undo]
        ).evaluate()
        let withoutReversal = NativeScalarProgram(
            initial: 3,
            operations: [.add(9)]
        ).evaluate()

        let malformedConservation = [
            "Initially, amber holds 3; birch holds 4; cobalt holds 5.",
            "First, create 2 in amber.",
            "What does amber finally hold?",
            "Answer:",
            "",
        ].joined(separator: "\n")
        let conservationDetected: Bool
        do {
            _ = try NativeIndependentTextVerifier.parse(
                malformedConservation
            )
            conservationDetected = false
        } catch {
            conservationDetected = true
        }

        let sample = validation[0]
        let encoded = PrimeNativeByteTokenizer.encode(sample.promptText)
        let corrupted = encoded.map { $0 - 1 }
        let tokenizerDetected =
            PrimeNativeByteTokenizer.tokenIDsSHA256(encoded)
                != PrimeNativeByteTokenizer.tokenIDsSHA256(corrupted)
                && (try? PrimeNativeByteTokenizer.decode(corrupted))
                    != sample.promptText

        let sampleGenerated = generatedProgram(
            split: .validation,
            index: 5,
            attempt: 0
        )
        let sampleAnswer = sampleGenerated.program.evaluate()!
        let renderA = render(
            sampleGenerated,
            codebook: codebooks[0],
            surface: surfaceForms[0]
        )
        let renderB = render(
            sampleGenerated,
            codebook: codebooks[1],
            surface: surfaceForms[1]
        )
        let parsedA = try! NativeIndependentTextVerifier.parse(renderA)
        let parsedB = try! NativeIndependentTextVerifier.parse(renderB)
        let codebookDetected =
            parsedA.answer.canonical == sampleAnswer.canonical
                && parsedB.answer.canonical == sampleAnswer.canonical
                && renderA != renderB

        return [
            FalsifierEvidence(
                id: "exact_lookup_leakage",
                family: "lookup",
                detected:
                    leakage.exactLookupEvaluationHits == 0
                        && leakage.trainEvaluationSemanticOverlapCount == 0,
                trials: rows(for: .validation).count
                    + rows(for: .refusalValidation).count
                    + rows(for: .combinationHoldout).count
                    + rows(for: .ood).count
                    + rows(for: .mutation).count
                    + rows(for: .abstention).count,
                detections: leakage.exactLookupEvaluationHits == 0 ? 1 : 0,
                detail:
                    "No evaluation prompt or semantic program occurs in train."
            ),
            FalsifierEvidence(
                id: "shuffled_label_regrade",
                family: "label",
                detected: shuffledDetections == validation.count,
                trials: validation.count,
                detections: shuffledDetections,
                detail:
                    "Independent prompt parser rejects rotated completions."
            ),
            FalsifierEvidence(
                id: "operation_order_swap",
                family: "ordering",
                detected: ordered != reordered,
                trials: 1,
                detections: ordered != reordered ? 1 : 0,
                detail:
                    "add-then-negate differs from negate-then-add."
            ),
            FalsifierEvidence(
                id: "negation_drop",
                family: "negation",
                detected: withNegation != withoutNegation,
                trials: 1,
                detections: withNegation != withoutNegation ? 1 : 0,
                detail: "Dropping sign reversal changes the exact answer."
            ),
            FalsifierEvidence(
                id: "conservation_break",
                family: "conservation",
                detected: conservationDetected,
                trials: 1,
                detections: conservationDetected ? 1 : 0,
                detail:
                    "Unlicensed creation is outside transfer grammar and must abstain."
            ),
            FalsifierEvidence(
                id: "reversal_drop",
                family: "reversal",
                detected: withReversal != withoutReversal,
                trials: 1,
                detections: withReversal != withoutReversal ? 1 : 0,
                detail: "Dropping undo changes the exact answer."
            ),
            FalsifierEvidence(
                id: "token_offset_corruption",
                family: "tokenizer",
                detected: tokenizerDetected,
                trials: 1,
                detections: tokenizerDetected ? 1 : 0,
                detail:
                    "A one-ID byte offset must diverge in hash and decoded text."
            ),
            FalsifierEvidence(
                id: "codebook_surface_equivalence",
                family: "codebook_surface",
                detected: codebookDetected,
                trials: 2,
                detections: codebookDetected ? 2 : 0,
                detail:
                    "Two disjoint renderings independently regrade to one semantic answer."
            ),
            FalsifierEvidence(
                id: "duplicate_row_injection",
                family: "split_leakage",
                detected:
                    leakage.allRowIDsUnique
                        && leakage.allRowHashesUnique,
                trials: allRows().count,
                detections:
                    leakage.allRowIDsUnique
                        && leakage.allRowHashesUnique ? 1 : 0,
                detail:
                    "Frozen row ID and material-hash sets reject duplicate injection."
            ),
            FalsifierEvidence(
                id: "heldout_refusal_contract",
                family: "refusal_generalization",
                detected:
                    refusal.allReasonsTaughtBeforeTuningAndEvaluation
                        && refusal
                            .allTuningAndEvaluationContractsHeldOut
                        && refusal.trainingTuningPromptOverlapCount == 0
                        && refusal
                            .trainingFinalEvaluationPromptOverlapCount
                            == 0
                        && refusal
                            .tuningFinalEvaluationPromptOverlapCount
                            == 0
                        && refusal.trainingTuningSemanticOverlapCount
                            == 0
                        && refusal
                            .trainingFinalEvaluationSemanticOverlapCount
                            == 0
                        && refusal
                            .tuningFinalEvaluationSemanticOverlapCount
                            == 0,
                trials:
                    refusal.trainingRowCount
                        + refusal.tuningRowCount
                        + refusal.finalEvaluationRowCount,
                detections:
                    refusal.allTuningAndEvaluationContractsHeldOut
                        ? 1 : 0,
                detail:
                    "Refusal categories are taught, while tuning and final prompts, semantics, and mutation-surface contracts remain pairwise held out."
            ),
        ]
    }

    private static let cachedManifest: Manifest = {
        let all = allRows()
        let splitEvidence = Split.allCases.map {
            ErgenticsPrimeNativeTextCorpus.splitEvidence(
                split: $0,
                rows: rows(for: $0)
            )
        }
        let accounting = tokenAccounting(rows: all)
        let leakage = leakageEvidence()
        let refusal = refusalCurriculumEvidence()
        let falsifiers = falsifierEvidence(
            leakage: leakage,
            refusal: refusal
        )
        let tokenizer = PrimeNativeByteTokenizer.manifest()
        let generator = GeneratorContract(
            generatorID: generatorID,
            implementationLanguage: "swift",
            implementationPath:
                "prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsPrimeNativeTextCorpus.swift",
            entropyPrimitive:
                "SHA256(generator_id|split|index|attempt|field)",
            hostRandomness: false,
            externalText: false,
            inheritedTokenizer: false,
            inheritedWeights: false,
            fullRowsEmbedded: false,
            losslessReplay: true,
            canonicalTextNormalization: "NFC",
            sequenceConstruction:
                "BOS + NFC UTF-8 prompt + exact completion + EOS",
            maximumSequenceTokenCount: maximumSequenceTokenCount
        )
        let evaluation = EvaluationContract(
            promptField: "prompt_text",
            expectedCompletionField: "expected_completion",
            exactMatchNormalization: "none",
            causalLossMask:
                "loss begins at first expected_completion byte; prompt and BOS are masked",
            abstentionCompletion: "ABSTAIN\n",
            selectionTuningSplits: [
                Split.validation.rawValue,
                Split.refusalValidation.rawValue,
            ],
            requiredRawResultSplits: [
                Split.validation.rawValue,
                Split.combinationHoldout.rawValue,
                Split.ood.rawValue,
                Split.mutation.rawValue,
                Split.abstention.rawValue,
            ],
            requiredRawResultFields: [
                "seed",
                "row_id",
                "split",
                "semantic_family",
                "mutation_id",
                "evaluation_row_sha256",
                "corpus_row_sha256",
                "prompt_token_ids",
                "expected_completion_token_ids",
                "generated_token_ids",
                "generated_completion",
                "token_log_probabilities",
                "exact_match",
                "semantic_verifier_pass",
                "abstention_decision",
                "latency_seconds",
            ],
            evaluationRowSHA256CanonicalFields: [
                "row_id",
                "split",
                "semantic_family",
                "mutation_id",
                "prompt",
                "target",
            ],
            evaluationRowAbsentMutationEncoding: "json_null",
            szCanonicalFields: [
                "corpus_id",
                "manifest_sha256",
                "split",
                "ordered_evaluation_rows_sha256",
                "seed",
                "checkpoint_sha256",
                "raw_results_sha256",
            ],
            triadicWitnesses: [
                "swift_generator_replay",
                "independent_text_semantic_regrade",
                "foundation_data_tokenizer_replay",
            ],
            verifyAbstainMinimumIndependentWitnesses: 3,
            verifyAbstainCriticalLegs: [
                "manifest_and_row_hashes",
                "all_valid_semantic_regrades",
                "malformed_abstention_regrades",
                "mutation_synthesis",
                "multi_seed_consensus",
            ],
            multiSeedConsensusSeeds: consensusSeeds
        )
        let orderedCorpusHash = canonicalSHA256(
            Split.allCases.map { split in
                [
                    split.rawValue,
                    splitEvidence.first { $0.split == split.rawValue }!
                        .orderedRowsSHA256,
                ].joined(separator: "|")
            }
        )
        let falsifierHash = canonicalSHA256(falsifiers)
        let payload = NativeManifestPayload(
            schemaVersion: schemaVersion,
            corpusID: corpusID,
            ownership: "ergentics_first_party",
            license: "ergentics_first_party_controlled",
            productAuthorization: "research_canary_only",
            tokenizerID: tokenizer.tokenizerID,
            tokenizerManifestSHA256: tokenizer.manifestSHA256,
            modelVocabularySize:
                PrimeNativeByteTokenizer.boundModelVocabularySize,
            generator: generator,
            codebooks: codebooks,
            surfaceForms: surfaceForms,
            splitEvidence: splitEvidence,
            tokenAccounting: accounting,
            leakageEvidence: leakage,
            refusalCurriculumEvidence: refusal,
            falsifiers: falsifiers,
            evaluationContract: evaluation,
            orderedCorpusRowsSHA256: orderedCorpusHash,
            falsifierSHA256: falsifierHash
        )
        return Manifest(
            schemaVersion: payload.schemaVersion,
            corpusID: payload.corpusID,
            ownership: payload.ownership,
            license: payload.license,
            productAuthorization: payload.productAuthorization,
            tokenizerID: payload.tokenizerID,
            tokenizerManifestSHA256:
                payload.tokenizerManifestSHA256,
            modelVocabularySize: payload.modelVocabularySize,
            generator: payload.generator,
            codebooks: payload.codebooks,
            surfaceForms: payload.surfaceForms,
            splitEvidence: payload.splitEvidence,
            tokenAccounting: payload.tokenAccounting,
            leakageEvidence: payload.leakageEvidence,
            refusalCurriculumEvidence:
                payload.refusalCurriculumEvidence,
            falsifiers: payload.falsifiers,
            evaluationContract: payload.evaluationContract,
            orderedCorpusRowsSHA256:
                payload.orderedCorpusRowsSHA256,
            falsifierSHA256: payload.falsifierSHA256,
            manifestSHA256: canonicalSHA256(payload)
        )
    }()

    public static func manifest() -> Manifest {
        cachedManifest
    }

    public static func contentSHA256(of manifest: Manifest) -> String {
        canonicalSHA256(
            NativeManifestPayload(
                schemaVersion: manifest.schemaVersion,
                corpusID: manifest.corpusID,
                ownership: manifest.ownership,
                license: manifest.license,
                productAuthorization:
                    manifest.productAuthorization,
                tokenizerID: manifest.tokenizerID,
                tokenizerManifestSHA256:
                    manifest.tokenizerManifestSHA256,
                modelVocabularySize:
                    manifest.modelVocabularySize,
                generator: manifest.generator,
                codebooks: manifest.codebooks,
                surfaceForms: manifest.surfaceForms,
                splitEvidence: manifest.splitEvidence,
                tokenAccounting: manifest.tokenAccounting,
                leakageEvidence: manifest.leakageEvidence,
                refusalCurriculumEvidence:
                    manifest.refusalCurriculumEvidence,
                falsifiers: manifest.falsifiers,
                evaluationContract:
                    manifest.evaluationContract,
                orderedCorpusRowsSHA256:
                    manifest.orderedCorpusRowsSHA256,
                falsifierSHA256: manifest.falsifierSHA256
            )
        )
    }

    public static func verify(_ manifest: Manifest) throws {
        guard manifest.manifestSHA256 == contentSHA256(of: manifest)
        else {
            throw CorpusError.manifestSHA256Mismatch
        }
        let tokenizer = PrimeNativeByteTokenizer.manifest()
        guard manifest.tokenizerID == tokenizer.tokenizerID,
              manifest.tokenizerManifestSHA256
                == tokenizer.manifestSHA256,
              manifest.modelVocabularySize
                == PrimeNativeByteTokenizer.boundModelVocabularySize,
              manifest.modelVocabularySize == 512 else {
            throw CorpusError.tokenizerMismatch
        }
        guard manifest == cachedManifest,
              manifest.splitEvidence.allSatisfy(
                  \.allRowsIndependentlyVerified
              ),
              manifest.falsifiers.allSatisfy(\.detected),
              manifest.leakageEvidence
                .trainEvaluationPromptOverlapCount == 0,
              manifest.leakageEvidence
                .trainEvaluationSemanticOverlapCount == 0,
              manifest.leakageEvidence
                .refusalTrainEvaluationPromptOverlapCount == 0,
              manifest.leakageEvidence
                .refusalTrainEvaluationSemanticOverlapCount == 0,
              manifest.leakageEvidence
                .refusalTrainAbstentionContractOverlapCount == 0,
              manifest.refusalCurriculumEvidence
                .trainingRowCount == rowCounts[.refusalTrain],
              manifest.refusalCurriculumEvidence
                .tuningRowCount == rowCounts[.refusalValidation],
              manifest.refusalCurriculumEvidence
                .finalEvaluationRowCount == rowCounts[.abstention],
              manifest.refusalCurriculumEvidence
                .allReasonsTaughtBeforeTuningAndEvaluation,
              manifest.refusalCurriculumEvidence
                .allTuningAndEvaluationContractsHeldOut,
              manifest.refusalCurriculumEvidence
                .allRowsIndependentlyVerified,
              manifest.leakageEvidence
                .trainCombinationPairOverlapCount == 0,
              manifest.leakageEvidence
                .combinationComponentsSeenInTrain,
              manifest.leakageEvidence
                .combinationPairsAbsentFromTrain,
              manifest.leakageEvidence
                .trainOODCodebookIDIntersectionCount == 0,
              manifest.leakageEvidence
                .trainOODSurfaceIDIntersectionCount == 0,
              manifest.tokenAccounting
                .vocabularyTokenTypeCount == 512,
              manifest.generator.losslessReplay,
              !manifest.generator.externalText,
              !manifest.generator.inheritedTokenizer,
              !manifest.generator.inheritedWeights else {
            throw CorpusError.manifestMismatch
        }
    }

    @discardableResult
    public static func writeManifest(to url: URL) throws -> URL {
        let expected = manifest()
        try verify(expected)
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                let existing = try JSONDecoder().decode(
                    Manifest.self,
                    from: Data(contentsOf: url)
                )
                try verify(existing)
                guard existing == expected else {
                    throw CorpusError.refusingOverwrite(url.path)
                }
                return url
            } catch let error as CorpusError {
                if error == .refusingOverwrite(url.path) {
                    throw error
                }
                throw CorpusError.refusingOverwrite(url.path)
            } catch {
                throw CorpusError.refusingOverwrite(url.path)
            }
        }
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [
            .prettyPrinted,
            .sortedKeys,
            .withoutEscapingSlashes,
        ]
        try encoder.encode(expected).write(to: url, options: .atomic)
        return url
    }

    public static func loadManifest(from url: URL) throws -> Manifest {
        let value = try JSONDecoder().decode(
            Manifest.self,
            from: Data(contentsOf: url)
        )
        try verify(value)
        return value
    }
}
