import Foundation

/// Complete deterministic observation of the transplanted first-party corpus.
///
/// This observation deliberately describes the embedded regrader as a
/// same-implementation evaluator. It is a useful exact replay witness, but it
/// is not an algorithmically independent or scientific oracle.
public struct PrimeNativeCorpusReplayObservation:
    Codable,
    Equatable,
    Sendable
{
    public struct NamedCount: Codable, Equatable, Sendable {
        public let id: String
        public let rowCount: Int

        public init(id: String, rowCount: Int) {
            self.id = id
            self.rowCount = rowCount
        }

        private enum CodingKeys: String, CodingKey {
            case id
            case rowCount = "row_count"
        }
    }

    public struct SplitObservation:
        Codable,
        Equatable,
        Sendable
    {
        public let split: String
        public let rowCount: Int
        public let rawTokenInstances: Int
        public let orderedRowsSHA256: String
        public let orderedEvaluationRowsSHA256: String
        public let semanticSetSHA256: String
        public let promptSetSHA256: String
        public let sequenceSetSHA256: String
        public let freshRegradeSHA256: String
        public let acceptedRowCount: Int
        public let firstRowID: String
        public let firstRowSHA256: String
        public let lastRowID: String
        public let lastRowSHA256: String

        public init(
            split: String,
            rowCount: Int,
            rawTokenInstances: Int,
            orderedRowsSHA256: String,
            orderedEvaluationRowsSHA256: String,
            semanticSetSHA256: String,
            promptSetSHA256: String,
            sequenceSetSHA256: String,
            freshRegradeSHA256: String,
            acceptedRowCount: Int,
            firstRowID: String,
            firstRowSHA256: String,
            lastRowID: String,
            lastRowSHA256: String
        ) {
            self.split = split
            self.rowCount = rowCount
            self.rawTokenInstances = rawTokenInstances
            self.orderedRowsSHA256 = orderedRowsSHA256
            self.orderedEvaluationRowsSHA256 =
                orderedEvaluationRowsSHA256
            self.semanticSetSHA256 = semanticSetSHA256
            self.promptSetSHA256 = promptSetSHA256
            self.sequenceSetSHA256 = sequenceSetSHA256
            self.freshRegradeSHA256 = freshRegradeSHA256
            self.acceptedRowCount = acceptedRowCount
            self.firstRowID = firstRowID
            self.firstRowSHA256 = firstRowSHA256
            self.lastRowID = lastRowID
            self.lastRowSHA256 = lastRowSHA256
        }

        private enum CodingKeys: String, CodingKey {
            case split
            case rowCount = "row_count"
            case rawTokenInstances = "raw_token_instances"
            case orderedRowsSHA256 =
                "ordered_rows_sha256"
            case orderedEvaluationRowsSHA256 =
                "ordered_evaluation_rows_sha256"
            case semanticSetSHA256 =
                "semantic_set_sha256"
            case promptSetSHA256 =
                "prompt_set_sha256"
            case sequenceSetSHA256 =
                "sequence_set_sha256"
            case freshRegradeSHA256 =
                "fresh_regrade_sha256"
            case acceptedRowCount =
                "accepted_row_count"
            case firstRowID = "first_row_id"
            case firstRowSHA256 =
                "first_row_sha256"
            case lastRowID = "last_row_id"
            case lastRowSHA256 =
                "last_row_sha256"
        }
    }

    public struct SplitMutationSummary:
        Codable,
        Equatable,
        Sendable
    {
        public let split: String
        public let mutatedRowCount: Int
        public let mutationCounts: [NamedCount]

        public init(
            split: String,
            mutatedRowCount: Int,
            mutationCounts: [NamedCount]
        ) {
            self.split = split
            self.mutatedRowCount = mutatedRowCount
            self.mutationCounts = mutationCounts
        }

        private enum CodingKeys: String, CodingKey {
            case split
            case mutatedRowCount =
                "mutated_row_count"
            case mutationCounts = "mutation_counts"
        }
    }

    public struct MutationSummary:
        Codable,
        Equatable,
        Sendable
    {
        public let totalMutatedRowCount: Int
        public let splitSummaries:
            [SplitMutationSummary]
        public let allCounterfactualParentsBound: Bool
        public let allMalformedReasonsBound: Bool

        public init(
            totalMutatedRowCount: Int,
            splitSummaries:
                [SplitMutationSummary],
            allCounterfactualParentsBound: Bool,
            allMalformedReasonsBound: Bool
        ) {
            self.totalMutatedRowCount =
                totalMutatedRowCount
            self.splitSummaries = splitSummaries
            self.allCounterfactualParentsBound =
                allCounterfactualParentsBound
            self.allMalformedReasonsBound =
                allMalformedReasonsBound
        }

        private enum CodingKeys: String, CodingKey {
            case totalMutatedRowCount =
                "total_mutated_row_count"
            case splitSummaries = "split_summaries"
            case allCounterfactualParentsBound =
                "all_counterfactual_parents_bound"
            case allMalformedReasonsBound =
                "all_malformed_reasons_bound"
        }
    }

    public struct RefusalSummary:
        Codable,
        Equatable,
        Sendable
    {
        public let trainingRowCount: Int
        public let tuningRowCount: Int
        public let finalEvaluationRowCount: Int
        public let trainingPromptSetSHA256: String
        public let tuningPromptSetSHA256: String
        public let finalEvaluationPromptSetSHA256:
            String
        public let trainingSemanticSetSHA256: String
        public let tuningSemanticSetSHA256: String
        public let finalEvaluationSemanticSetSHA256:
            String
        public let trainingFreshRegradeSHA256: String
        public let tuningFreshRegradeSHA256: String
        public let finalEvaluationFreshRegradeSHA256:
            String
        public let trainingTuningPromptOverlapCount: Int
        public let trainingFinalPromptOverlapCount: Int
        public let tuningFinalPromptOverlapCount: Int
        public let trainingTuningSemanticOverlapCount:
            Int
        public let trainingFinalSemanticOverlapCount:
            Int
        public let tuningFinalSemanticOverlapCount: Int
        public let trainingTuningContractOverlapCount:
            Int
        public let trainingFinalContractOverlapCount:
            Int
        public let tuningFinalContractOverlapCount: Int
        public let allReasonsTaught: Bool
        public let allTuningAndEvaluationContractsHeldOut:
            Bool
        public let allRowsAcceptedByFreshRegrade: Bool

        public init(
            trainingRowCount: Int,
            tuningRowCount: Int,
            finalEvaluationRowCount: Int,
            trainingPromptSetSHA256: String,
            tuningPromptSetSHA256: String,
            finalEvaluationPromptSetSHA256:
                String,
            trainingSemanticSetSHA256: String,
            tuningSemanticSetSHA256: String,
            finalEvaluationSemanticSetSHA256:
                String,
            trainingFreshRegradeSHA256: String,
            tuningFreshRegradeSHA256: String,
            finalEvaluationFreshRegradeSHA256:
                String,
            trainingTuningPromptOverlapCount: Int,
            trainingFinalPromptOverlapCount: Int,
            tuningFinalPromptOverlapCount: Int,
            trainingTuningSemanticOverlapCount:
                Int,
            trainingFinalSemanticOverlapCount:
                Int,
            tuningFinalSemanticOverlapCount: Int,
            trainingTuningContractOverlapCount:
                Int,
            trainingFinalContractOverlapCount:
                Int,
            tuningFinalContractOverlapCount: Int,
            allReasonsTaught: Bool,
            allTuningAndEvaluationContractsHeldOut:
                Bool,
            allRowsAcceptedByFreshRegrade: Bool
        ) {
            self.trainingRowCount = trainingRowCount
            self.tuningRowCount = tuningRowCount
            self.finalEvaluationRowCount =
                finalEvaluationRowCount
            self.trainingPromptSetSHA256 =
                trainingPromptSetSHA256
            self.tuningPromptSetSHA256 =
                tuningPromptSetSHA256
            self.finalEvaluationPromptSetSHA256 =
                finalEvaluationPromptSetSHA256
            self.trainingSemanticSetSHA256 =
                trainingSemanticSetSHA256
            self.tuningSemanticSetSHA256 =
                tuningSemanticSetSHA256
            self.finalEvaluationSemanticSetSHA256 =
                finalEvaluationSemanticSetSHA256
            self.trainingFreshRegradeSHA256 =
                trainingFreshRegradeSHA256
            self.tuningFreshRegradeSHA256 =
                tuningFreshRegradeSHA256
            self.finalEvaluationFreshRegradeSHA256 =
                finalEvaluationFreshRegradeSHA256
            self.trainingTuningPromptOverlapCount =
                trainingTuningPromptOverlapCount
            self.trainingFinalPromptOverlapCount =
                trainingFinalPromptOverlapCount
            self.tuningFinalPromptOverlapCount =
                tuningFinalPromptOverlapCount
            self.trainingTuningSemanticOverlapCount =
                trainingTuningSemanticOverlapCount
            self.trainingFinalSemanticOverlapCount =
                trainingFinalSemanticOverlapCount
            self.tuningFinalSemanticOverlapCount =
                tuningFinalSemanticOverlapCount
            self.trainingTuningContractOverlapCount =
                trainingTuningContractOverlapCount
            self.trainingFinalContractOverlapCount =
                trainingFinalContractOverlapCount
            self.tuningFinalContractOverlapCount =
                tuningFinalContractOverlapCount
            self.allReasonsTaught = allReasonsTaught
            self.allTuningAndEvaluationContractsHeldOut =
                allTuningAndEvaluationContractsHeldOut
            self.allRowsAcceptedByFreshRegrade =
                allRowsAcceptedByFreshRegrade
        }

        private enum CodingKeys: String, CodingKey {
            case trainingRowCount =
                "training_row_count"
            case tuningRowCount = "tuning_row_count"
            case finalEvaluationRowCount =
                "final_evaluation_row_count"
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
            case trainingFreshRegradeSHA256 =
                "training_fresh_regrade_sha256"
            case tuningFreshRegradeSHA256 =
                "tuning_fresh_regrade_sha256"
            case finalEvaluationFreshRegradeSHA256 =
                "final_evaluation_fresh_regrade_sha256"
            case trainingTuningPromptOverlapCount =
                "training_tuning_prompt_overlap_count"
            case trainingFinalPromptOverlapCount =
                "training_final_prompt_overlap_count"
            case tuningFinalPromptOverlapCount =
                "tuning_final_prompt_overlap_count"
            case trainingTuningSemanticOverlapCount =
                "training_tuning_semantic_overlap_count"
            case trainingFinalSemanticOverlapCount =
                "training_final_semantic_overlap_count"
            case tuningFinalSemanticOverlapCount =
                "tuning_final_semantic_overlap_count"
            case trainingTuningContractOverlapCount =
                "training_tuning_contract_overlap_count"
            case trainingFinalContractOverlapCount =
                "training_final_contract_overlap_count"
            case tuningFinalContractOverlapCount =
                "tuning_final_contract_overlap_count"
            case allReasonsTaught =
                "all_reasons_taught"
            case allTuningAndEvaluationContractsHeldOut =
                "all_tuning_and_evaluation_contracts_held_out"
            case allRowsAcceptedByFreshRegrade =
                "all_rows_accepted_by_fresh_regrade"
        }
    }

    public struct LeakageSummary:
        Codable,
        Equatable,
        Sendable
    {
        public let trainEvaluationPromptOverlapCount:
            Int
        public let trainEvaluationSemanticOverlapCount:
            Int
        public let refusalTrainEvaluationPromptOverlapCount:
            Int
        public let refusalTrainEvaluationSemanticOverlapCount:
            Int
        public let refusalTrainAbstentionContractOverlapCount:
            Int
        public let trainCombinationPairOverlapCount: Int
        public let trainCombinationCodebookIntersectionCount:
            Int
        public let trainCombinationSurfaceIntersectionCount:
            Int
        public let trainOODCodebookIntersectionCount: Int
        public let trainOODSurfaceIntersectionCount: Int
        public let combinationComponentsSeenInTrain:
            Bool
        public let combinationPairsAbsentFromTrain: Bool
        public let exactLookupEvaluationHits: Int
        public let allRowIDsUnique: Bool
        public let allRowHashesUnique: Bool
        public let allValidSemanticsDisjointAcrossSplits:
            Bool

        public init(
            trainEvaluationPromptOverlapCount:
                Int,
            trainEvaluationSemanticOverlapCount:
                Int,
            refusalTrainEvaluationPromptOverlapCount:
                Int,
            refusalTrainEvaluationSemanticOverlapCount:
                Int,
            refusalTrainAbstentionContractOverlapCount:
                Int,
            trainCombinationPairOverlapCount: Int,
            trainCombinationCodebookIntersectionCount:
                Int,
            trainCombinationSurfaceIntersectionCount:
                Int,
            trainOODCodebookIntersectionCount: Int,
            trainOODSurfaceIntersectionCount: Int,
            combinationComponentsSeenInTrain:
                Bool,
            combinationPairsAbsentFromTrain: Bool,
            exactLookupEvaluationHits: Int,
            allRowIDsUnique: Bool,
            allRowHashesUnique: Bool,
            allValidSemanticsDisjointAcrossSplits:
                Bool
        ) {
            self.trainEvaluationPromptOverlapCount =
                trainEvaluationPromptOverlapCount
            self.trainEvaluationSemanticOverlapCount =
                trainEvaluationSemanticOverlapCount
            self.refusalTrainEvaluationPromptOverlapCount =
                refusalTrainEvaluationPromptOverlapCount
            self.refusalTrainEvaluationSemanticOverlapCount =
                refusalTrainEvaluationSemanticOverlapCount
            self.refusalTrainAbstentionContractOverlapCount =
                refusalTrainAbstentionContractOverlapCount
            self.trainCombinationPairOverlapCount =
                trainCombinationPairOverlapCount
            self.trainCombinationCodebookIntersectionCount =
                trainCombinationCodebookIntersectionCount
            self.trainCombinationSurfaceIntersectionCount =
                trainCombinationSurfaceIntersectionCount
            self.trainOODCodebookIntersectionCount =
                trainOODCodebookIntersectionCount
            self.trainOODSurfaceIntersectionCount =
                trainOODSurfaceIntersectionCount
            self.combinationComponentsSeenInTrain =
                combinationComponentsSeenInTrain
            self.combinationPairsAbsentFromTrain =
                combinationPairsAbsentFromTrain
            self.exactLookupEvaluationHits =
                exactLookupEvaluationHits
            self.allRowIDsUnique = allRowIDsUnique
            self.allRowHashesUnique = allRowHashesUnique
            self.allValidSemanticsDisjointAcrossSplits =
                allValidSemanticsDisjointAcrossSplits
        }

        private enum CodingKeys: String, CodingKey {
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
            case trainCombinationCodebookIntersectionCount =
                "train_combination_codebook_intersection_count"
            case trainCombinationSurfaceIntersectionCount =
                "train_combination_surface_intersection_count"
            case trainOODCodebookIntersectionCount =
                "train_ood_codebook_intersection_count"
            case trainOODSurfaceIntersectionCount =
                "train_ood_surface_intersection_count"
            case combinationComponentsSeenInTrain =
                "combination_components_seen_in_train"
            case combinationPairsAbsentFromTrain =
                "combination_pairs_absent_from_train"
            case exactLookupEvaluationHits =
                "exact_lookup_evaluation_hits"
            case allRowIDsUnique =
                "all_row_ids_unique"
            case allRowHashesUnique =
                "all_row_hashes_unique"
            case allValidSemanticsDisjointAcrossSplits =
                "all_valid_semantics_disjoint_across_splits"
        }
    }

    public struct FalsifierSummary:
        Codable,
        Equatable,
        Sendable
    {
        public let falsifierCount: Int
        public let detectedCount: Int
        public let totalTrials: Int
        public let totalDetections: Int

        public init(
            falsifierCount: Int,
            detectedCount: Int,
            totalTrials: Int,
            totalDetections: Int
        ) {
            self.falsifierCount = falsifierCount
            self.detectedCount = detectedCount
            self.totalTrials = totalTrials
            self.totalDetections = totalDetections
        }

        private enum CodingKeys: String, CodingKey {
            case falsifierCount = "falsifier_count"
            case detectedCount = "detected_count"
            case totalTrials = "total_trials"
            case totalDetections = "total_detections"
        }
    }

    public let schemaVersion: Int
    public let artifactKind: String
    public let corpusID: String
    public let generatorID: String
    public let tokenizerID: String
    public let consensusSeeds: [Int]
    public let splitObservations: [SplitObservation]
    public let mutationSummary: MutationSummary
    public let refusalSummary: RefusalSummary
    public let leakageSummary: LeakageSummary
    public let falsifierSummary: FalsifierSummary
    public let fullRowCount: Int
    public let acceptedRowCount: Int
    public let rawTokenInstances: Int
    public let corpusManifestSHA256: String
    public let orderedCorpusRowsSHA256: String
    public let falsifierSHA256: String
    public let tokenizerManifestSHA256: String
    public let tokenizerReplayProbeSHA256: String
    public let corpusManifestPrettyBytesSHA256: String
    public let tokenizerManifestPrettyBytesSHA256:
        String
    public let sameImplementationSemanticEvaluator:
        Bool
    public let algorithmicallyIndependentSemanticOracle:
        Bool
    public let independentScientificOracleClaimed:
        Bool
    public let authorityStatement: String

    public init(
        schemaVersion: Int,
        artifactKind: String,
        corpusID: String,
        generatorID: String,
        tokenizerID: String,
        consensusSeeds: [Int],
        splitObservations: [SplitObservation],
        mutationSummary: MutationSummary,
        refusalSummary: RefusalSummary,
        leakageSummary: LeakageSummary,
        falsifierSummary: FalsifierSummary,
        fullRowCount: Int,
        acceptedRowCount: Int,
        rawTokenInstances: Int,
        corpusManifestSHA256: String,
        orderedCorpusRowsSHA256: String,
        falsifierSHA256: String,
        tokenizerManifestSHA256: String,
        tokenizerReplayProbeSHA256: String,
        corpusManifestPrettyBytesSHA256: String,
        tokenizerManifestPrettyBytesSHA256:
            String,
        sameImplementationSemanticEvaluator:
            Bool,
        algorithmicallyIndependentSemanticOracle:
            Bool,
        independentScientificOracleClaimed:
            Bool,
        authorityStatement: String
    ) {
        self.schemaVersion = schemaVersion
        self.artifactKind = artifactKind
        self.corpusID = corpusID
        self.generatorID = generatorID
        self.tokenizerID = tokenizerID
        self.consensusSeeds = consensusSeeds
        self.splitObservations = splitObservations
        self.mutationSummary = mutationSummary
        self.refusalSummary = refusalSummary
        self.leakageSummary = leakageSummary
        self.falsifierSummary = falsifierSummary
        self.fullRowCount = fullRowCount
        self.acceptedRowCount = acceptedRowCount
        self.rawTokenInstances = rawTokenInstances
        self.corpusManifestSHA256 =
            corpusManifestSHA256
        self.orderedCorpusRowsSHA256 =
            orderedCorpusRowsSHA256
        self.falsifierSHA256 = falsifierSHA256
        self.tokenizerManifestSHA256 =
            tokenizerManifestSHA256
        self.tokenizerReplayProbeSHA256 =
            tokenizerReplayProbeSHA256
        self.corpusManifestPrettyBytesSHA256 =
            corpusManifestPrettyBytesSHA256
        self.tokenizerManifestPrettyBytesSHA256 =
            tokenizerManifestPrettyBytesSHA256
        self.sameImplementationSemanticEvaluator =
            sameImplementationSemanticEvaluator
        self.algorithmicallyIndependentSemanticOracle =
            algorithmicallyIndependentSemanticOracle
        self.independentScientificOracleClaimed =
            independentScientificOracleClaimed
        self.authorityStatement = authorityStatement
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case artifactKind = "artifact_kind"
        case corpusID = "corpus_id"
        case generatorID = "generator_id"
        case tokenizerID = "tokenizer_id"
        case consensusSeeds = "consensus_seeds"
        case splitObservations = "split_observations"
        case mutationSummary = "mutation_summary"
        case refusalSummary = "refusal_summary"
        case leakageSummary = "leakage_summary"
        case falsifierSummary = "falsifier_summary"
        case fullRowCount = "full_row_count"
        case acceptedRowCount = "accepted_row_count"
        case rawTokenInstances = "raw_token_instances"
        case corpusManifestSHA256 =
            "corpus_manifest_sha256"
        case orderedCorpusRowsSHA256 =
            "ordered_corpus_rows_sha256"
        case falsifierSHA256 = "falsifier_sha256"
        case tokenizerManifestSHA256 =
            "tokenizer_manifest_sha256"
        case tokenizerReplayProbeSHA256 =
            "tokenizer_replay_probe_sha256"
        case corpusManifestPrettyBytesSHA256 =
            "corpus_manifest_pretty_bytes_sha256"
        case tokenizerManifestPrettyBytesSHA256 =
            "tokenizer_manifest_pretty_bytes_sha256"
        case sameImplementationSemanticEvaluator =
            "same_implementation_semantic_evaluator"
        case algorithmicallyIndependentSemanticOracle =
            "algorithmically_independent_semantic_oracle"
        case independentScientificOracleClaimed =
            "independent_scientific_oracle_claimed"
        case authorityStatement =
            "authority_statement"
    }
}

public enum PrimeNativeCorpusReplayObservationError:
    Error,
    Equatable,
    LocalizedError,
    Sendable
{
    case emptySplit(String)
    case splitOrderDrift
    case rowCountDrift(expected: Int, actual: Int)
    case rejectedRows(count: Int)
    case frozenGoldenDrift

    public var errorDescription: String? {
        switch self {
        case let .emptySplit(split):
            "Native corpus replay split is empty: \(split)"
        case .splitOrderDrift:
            "Native corpus replay split order drifted."
        case let .rowCountDrift(expected, actual):
            "Native corpus row count drifted: expected \(expected), observed \(actual)."
        case let .rejectedRows(count):
            "Fresh same-implementation regrade rejected \(count) corpus rows."
        case .frozenGoldenDrift:
            "Native corpus replay observation differs from explicit frozen goldens."
        }
    }
}

extension PrimeNativeCorpusReplayObservation {
    private typealias Corpus =
        ErgenticsPrimeNativeTextCorpus
    private typealias CorpusRow =
        ErgenticsPrimeNativeTextCorpus.Row

    public static func runAndValidate() throws -> Self {
        let tokenizerManifest =
            PrimeNativeByteTokenizer.manifest()
        try PrimeNativeByteTokenizer.verify(
            tokenizerManifest
        )
        let corpusManifest = Corpus.manifest()
        try Corpus.verify(corpusManifest)

        let splitOrder = Corpus.Split.allCases
        let splitNames = splitOrder.map(\.rawValue)
        guard splitNames == frozenV1.splitObservations.map(\.split)
        else {
            throw PrimeNativeCorpusReplayObservationError
                .splitOrderDrift
        }

        var rowsBySplit: [String: [CorpusRow]] = [:]
        var observations: [SplitObservation] = []
        var acceptedCount = 0
        var totalRawTokenInstances = 0

        for split in splitOrder {
            let rows = Corpus.rows(for: split)
            guard let first = rows.first,
                  let last = rows.last else {
                throw PrimeNativeCorpusReplayObservationError
                    .emptySplit(split.rawValue)
            }
            rowsBySplit[split.rawValue] = rows

            // This is intentionally a fresh invocation for every materialized
            // row rather than a reuse of cached manifest evidence.
            let verifications = rows.map(Corpus.verify(row:))
            let splitAccepted = verifications.reduce(into: 0) {
                $0 += $1.accepted ? 1 : 0
            }
            let rawTokenInstances = rows.reduce(into: 0) {
                $0 += PrimeNativeByteTokenizer.encodeSequence(
                    $1.trainingText
                ).count
            }
            acceptedCount += splitAccepted
            totalRawTokenInstances += rawTokenInstances

            observations.append(
                SplitObservation(
                    split: split.rawValue,
                    rowCount: rows.count,
                    rawTokenInstances: rawTokenInstances,
                    orderedRowsSHA256: Corpus.canonicalSHA256(
                        rows.map(\.rowSHA256)
                    ),
                    orderedEvaluationRowsSHA256:
                        Corpus.canonicalSHA256(
                            rows.map(\.evaluationRowSHA256)
                        ),
                    semanticSetSHA256: Corpus.canonicalSHA256(
                        Set(rows.map(\.semanticSHA256)).sorted()
                    ),
                    promptSetSHA256: Corpus.canonicalSHA256(
                        Set(rows.map(\.promptSHA256)).sorted()
                    ),
                    sequenceSetSHA256: Corpus.canonicalSHA256(
                        Set(
                            rows.map(\.sequenceTokenSHA256)
                        ).sorted()
                    ),
                    freshRegradeSHA256: Corpus.canonicalSHA256(
                        verifications.map(\.verifierSHA256)
                    ),
                    acceptedRowCount: splitAccepted,
                    firstRowID: first.rowID,
                    firstRowSHA256: first.rowSHA256,
                    lastRowID: last.rowID,
                    lastRowSHA256: last.rowSHA256
                )
            )
        }

        let allRows = splitOrder.flatMap {
            rowsBySplit[$0.rawValue]!
        }
        guard allRows.count == 155_648 else {
            throw PrimeNativeCorpusReplayObservationError
                .rowCountDrift(
                    expected: 155_648,
                    actual: allRows.count
                )
        }
        guard acceptedCount == allRows.count else {
            throw PrimeNativeCorpusReplayObservationError
                .rejectedRows(
                    count: allRows.count - acceptedCount
                )
        }

        let actual = Self(
            schemaVersion: 1,
            artifactKind:
                "ergentics_prime_native_full_corpus_replay_observation",
            corpusID: Corpus.corpusID,
            generatorID: Corpus.generatorID,
            tokenizerID:
                PrimeNativeByteTokenizer.tokenizerID,
            consensusSeeds: Corpus.consensusSeeds,
            splitObservations: observations,
            mutationSummary: mutationSummary(
                rowsBySplit: rowsBySplit
            ),
            refusalSummary: refusalSummary(
                rowsBySplit: rowsBySplit,
                splitObservations: observations
            ),
            leakageSummary: leakageSummary(
                rowsBySplit: rowsBySplit,
                allRows: allRows
            ),
            falsifierSummary: FalsifierSummary(
                falsifierCount:
                    corpusManifest.falsifiers.count,
                detectedCount:
                    corpusManifest.falsifiers.filter(\.detected)
                    .count,
                totalTrials:
                    corpusManifest.falsifiers.reduce(0) {
                        $0 + $1.trials
                    },
                totalDetections:
                    corpusManifest.falsifiers.reduce(0) {
                        $0 + $1.detections
                    }
            ),
            fullRowCount: allRows.count,
            acceptedRowCount: acceptedCount,
            rawTokenInstances: totalRawTokenInstances,
            corpusManifestSHA256:
                corpusManifest.manifestSHA256,
            orderedCorpusRowsSHA256:
                corpusManifest.orderedCorpusRowsSHA256,
            falsifierSHA256:
                corpusManifest.falsifierSHA256,
            tokenizerManifestSHA256:
                tokenizerManifest.manifestSHA256,
            tokenizerReplayProbeSHA256:
                tokenizerManifest.replayProbeSHA256,
            corpusManifestPrettyBytesSHA256:
                Corpus.sha256(
                    try prettyCorpusManifestData()
                ),
            tokenizerManifestPrettyBytesSHA256:
                Corpus.sha256(
                    try prettyTokenizerManifestData()
                ),
            sameImplementationSemanticEvaluator:
                true,
            algorithmicallyIndependentSemanticOracle:
                false,
            independentScientificOracleClaimed:
                false,
            authorityStatement:
                "Every row was freshly regraded by the transplanted corpus blob's same-implementation text evaluator. This is deterministic first-party replay evidence, not an algorithmically independent scientific oracle."
        )
        try actual.validateFrozen()
        return actual
    }

    public func validateFrozen() throws {
        guard self == Self.frozenV1 else {
            throw PrimeNativeCorpusReplayObservationError
                .frozenGoldenDrift
        }
    }

    public static func prettyTokenizerManifestData()
        throws -> Data
    {
        try prettyData(
            PrimeNativeByteTokenizer.manifest()
        )
    }

    public static func prettyCorpusManifestData()
        throws -> Data
    {
        try prettyData(Corpus.manifest())
    }

    public func canonicalData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [
            .sortedKeys,
            .withoutEscapingSlashes,
        ]
        return try encoder.encode(self)
    }

    public func contentSHA256() throws -> String {
        Corpus.sha256(try canonicalData())
    }

    private static func prettyData<T: Encodable>(
        _ value: T
    ) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [
            .prettyPrinted,
            .sortedKeys,
            .withoutEscapingSlashes,
        ]
        return try encoder.encode(value)
    }

    private static func mutationSummary(
        rowsBySplit: [String: [CorpusRow]]
    ) -> MutationSummary {
        let affectedSplits: [Corpus.Split] = [
            .refusalTrain,
            .refusalValidation,
            .mutation,
            .abstention,
        ]
        let summaries = affectedSplits.map { split in
            let rows = rowsBySplit[split.rawValue]!
            let mutationIDs = rows.compactMap(\.mutationID)
            let counts = Dictionary(
                grouping: mutationIDs,
                by: { $0 }
            ).map {
                NamedCount(
                    id: $0.key,
                    rowCount: $0.value.count
                )
            }.sorted { $0.id < $1.id }
            return SplitMutationSummary(
                split: split.rawValue,
                mutatedRowCount: mutationIDs.count,
                mutationCounts: counts
            )
        }
        let counterfactuals =
            rowsBySplit[Corpus.Split.mutation.rawValue]!
        let malformed = [
            Corpus.Split.refusalTrain,
            .refusalValidation,
            .abstention,
        ].flatMap { rowsBySplit[$0.rawValue]! }
        return MutationSummary(
            totalMutatedRowCount: summaries.reduce(0) {
                $0 + $1.mutatedRowCount
            },
            splitSummaries: summaries,
            allCounterfactualParentsBound:
                counterfactuals.allSatisfy {
                    $0.mutationID != nil
                        && $0.counterfactualOfRowID != nil
                        && $0.parentSemanticSHA256 != nil
                },
            allMalformedReasonsBound:
                malformed.allSatisfy {
                    $0.mutationID?.hasPrefix("malformed_")
                        == true
                        && $0.abstentionReason != nil
                }
        )
    }

    private static func refusalSummary(
        rowsBySplit: [String: [CorpusRow]],
        splitObservations: [SplitObservation]
    ) -> RefusalSummary {
        let training =
            rowsBySplit[Corpus.Split.refusalTrain.rawValue]!
        let tuning =
            rowsBySplit[
                Corpus.Split.refusalValidation.rawValue
            ]!
        let final =
            rowsBySplit[Corpus.Split.abstention.rawValue]!
        let trainingPrompts =
            Set(training.map(\.promptSHA256))
        let tuningPrompts = Set(tuning.map(\.promptSHA256))
        let finalPrompts = Set(final.map(\.promptSHA256))
        let trainingSemantics =
            Set(training.map(\.semanticSHA256))
        let tuningSemantics =
            Set(tuning.map(\.semanticSHA256))
        let finalSemantics =
            Set(final.map(\.semanticSHA256))
        let trainingContracts =
            Set(training.compactMap(refusalContractID))
        let tuningContracts =
            Set(tuning.compactMap(refusalContractID))
        let finalContracts =
            Set(final.compactMap(refusalContractID))
        let trainingReasons =
            Set(training.compactMap(\.abstentionReason))
        let tuningReasons =
            Set(tuning.compactMap(\.abstentionReason))
        let finalReasons =
            Set(final.compactMap(\.abstentionReason))
        let bySplit = Dictionary(
            uniqueKeysWithValues:
                splitObservations.map { ($0.split, $0) }
        )

        return RefusalSummary(
            trainingRowCount: training.count,
            tuningRowCount: tuning.count,
            finalEvaluationRowCount: final.count,
            trainingPromptSetSHA256: Corpus.canonicalSHA256(
                trainingPrompts.sorted()
            ),
            tuningPromptSetSHA256: Corpus.canonicalSHA256(
                tuningPrompts.sorted()
            ),
            finalEvaluationPromptSetSHA256:
                Corpus.canonicalSHA256(
                    finalPrompts.sorted()
                ),
            trainingSemanticSetSHA256:
                Corpus.canonicalSHA256(
                    trainingSemantics.sorted()
                ),
            tuningSemanticSetSHA256:
                Corpus.canonicalSHA256(
                    tuningSemantics.sorted()
                ),
            finalEvaluationSemanticSetSHA256:
                Corpus.canonicalSHA256(
                    finalSemantics.sorted()
                ),
            trainingFreshRegradeSHA256:
                bySplit[
                    Corpus.Split.refusalTrain.rawValue
                ]!.freshRegradeSHA256,
            tuningFreshRegradeSHA256:
                bySplit[
                    Corpus.Split.refusalValidation.rawValue
                ]!.freshRegradeSHA256,
            finalEvaluationFreshRegradeSHA256:
                bySplit[
                    Corpus.Split.abstention.rawValue
                ]!.freshRegradeSHA256,
            trainingTuningPromptOverlapCount:
                trainingPrompts.intersection(tuningPrompts)
                .count,
            trainingFinalPromptOverlapCount:
                trainingPrompts.intersection(finalPrompts)
                .count,
            tuningFinalPromptOverlapCount:
                tuningPrompts.intersection(finalPrompts).count,
            trainingTuningSemanticOverlapCount:
                trainingSemantics.intersection(tuningSemantics)
                .count,
            trainingFinalSemanticOverlapCount:
                trainingSemantics.intersection(finalSemantics)
                .count,
            tuningFinalSemanticOverlapCount:
                tuningSemantics.intersection(finalSemantics)
                .count,
            trainingTuningContractOverlapCount:
                trainingContracts.intersection(tuningContracts)
                .count,
            trainingFinalContractOverlapCount:
                trainingContracts.intersection(finalContracts)
                .count,
            tuningFinalContractOverlapCount:
                tuningContracts.intersection(finalContracts)
                .count,
            allReasonsTaught:
                tuningReasons.isSubset(of: trainingReasons)
                    && finalReasons.isSubset(
                        of: trainingReasons
                    ),
            allTuningAndEvaluationContractsHeldOut:
                trainingContracts.isDisjoint(
                    with: tuningContracts
                )
                    && trainingContracts.isDisjoint(
                        with: finalContracts
                    )
                    && tuningContracts.isDisjoint(
                        with: finalContracts
                    ),
            allRowsAcceptedByFreshRegrade:
                [
                    Corpus.Split.refusalTrain,
                    .refusalValidation,
                    .abstention,
                ].allSatisfy {
                    let observation = bySplit[$0.rawValue]!
                    return observation.acceptedRowCount
                        == observation.rowCount
                }
        )
    }

    private static func leakageSummary(
        rowsBySplit: [String: [CorpusRow]],
        allRows: [CorpusRow]
    ) -> LeakageSummary {
        let validTrain =
            rowsBySplit[Corpus.Split.train.rawValue]!
        let refusalTrain =
            rowsBySplit[Corpus.Split.refusalTrain.rawValue]!
        let train = validTrain + refusalTrain
        let evaluationSplits: [Corpus.Split] = [
            .validation,
            .refusalValidation,
            .combinationHoldout,
            .ood,
            .mutation,
            .abstention,
        ]
        let evaluation = evaluationSplits.flatMap {
            rowsBySplit[$0.rawValue]!
        }
        let trainPrompts = Set(train.map(\.promptSHA256))
        let evaluationPrompts =
            Set(evaluation.map(\.promptSHA256))
        let trainSemantics = Set(train.map(\.semanticSHA256))
        let evaluationSemantics =
            Set(evaluation.map(\.semanticSHA256))
        let combination =
            rowsBySplit[
                Corpus.Split.combinationHoldout.rawValue
            ]!
        let ood = rowsBySplit[Corpus.Split.ood.rawValue]!
        let trainPairs = pairSet(validTrain)
        let combinationPairs = pairSet(combination)
        let trainCodebooks = Set(validTrain.map(\.codebookID))
        let trainSurfaces =
            Set(validTrain.map(\.surfaceFormID))
        let combinationCodebooks =
            Set(combination.map(\.codebookID))
        let combinationSurfaces =
            Set(combination.map(\.surfaceFormID))
        let oodCodebooks = Set(ood.map(\.codebookID))
        let oodSurfaces = Set(ood.map(\.surfaceFormID))
        let refusalContracts =
            Set(refusalTrain.compactMap(refusalContractID))
        let finalContracts = Set(
            rowsBySplit[Corpus.Split.abstention.rawValue]!
                .compactMap(refusalContractID)
        )

        var semanticOwners: [String: String] = [:]
        var semanticsDisjoint = true
        for split in [
            Corpus.Split.train,
            .validation,
            .combinationHoldout,
            .ood,
            .mutation,
        ] {
            for hash in rowsBySplit[split.rawValue]!
                .map(\.semanticSHA256)
            {
                if semanticOwners.updateValue(
                    split.rawValue,
                    forKey: hash
                ) != nil {
                    semanticsDisjoint = false
                }
            }
        }

        return LeakageSummary(
            trainEvaluationPromptOverlapCount:
                trainPrompts.intersection(evaluationPrompts)
                .count,
            trainEvaluationSemanticOverlapCount:
                trainSemantics.intersection(
                    evaluationSemantics
                ).count,
            refusalTrainEvaluationPromptOverlapCount:
                Set(refusalTrain.map(\.promptSHA256))
                .intersection(evaluationPrompts).count,
            refusalTrainEvaluationSemanticOverlapCount:
                Set(refusalTrain.map(\.semanticSHA256))
                .intersection(evaluationSemantics).count,
            refusalTrainAbstentionContractOverlapCount:
                refusalContracts.intersection(finalContracts)
                .count,
            trainCombinationPairOverlapCount:
                trainPairs.intersection(combinationPairs).count,
            trainCombinationCodebookIntersectionCount:
                trainCodebooks.intersection(
                    combinationCodebooks
                ).count,
            trainCombinationSurfaceIntersectionCount:
                trainSurfaces.intersection(
                    combinationSurfaces
                ).count,
            trainOODCodebookIntersectionCount:
                trainCodebooks.intersection(oodCodebooks).count,
            trainOODSurfaceIntersectionCount:
                trainSurfaces.intersection(oodSurfaces).count,
            combinationComponentsSeenInTrain:
                combinationCodebooks.isSubset(of: trainCodebooks)
                    && combinationSurfaces.isSubset(
                        of: trainSurfaces
                    ),
            combinationPairsAbsentFromTrain:
                trainPairs.isDisjoint(with: combinationPairs),
            exactLookupEvaluationHits:
                trainPrompts.intersection(evaluationPrompts)
                .count,
            allRowIDsUnique:
                Set(allRows.map(\.rowID)).count
                    == allRows.count,
            allRowHashesUnique:
                Set(allRows.map(\.rowSHA256)).count
                    == allRows.count,
            allValidSemanticsDisjointAcrossSplits:
                semanticsDisjoint
        )
    }

    private static func refusalContractID(
        _ row: CorpusRow
    ) -> String? {
        guard let reason = row.abstentionReason,
              let mutation = row.mutationID else {
            return nil
        }
        return [
            reason,
            mutation,
            row.surfaceFormID,
        ].joined(separator: "|")
    }

    private static func pairSet(
        _ rows: [CorpusRow]
    ) -> Set<String> {
        Set(
            rows.map {
                "\($0.codebookID)|\($0.surfaceFormID)"
            }
        )
    }
}

extension PrimeNativeCorpusReplayObservation {
    /// Explicit donor goldens from companion revision
    /// `163fc100710ece48119bc25954452d10f6a84f7f`.
    ///
    /// These values are literals by design. `runAndValidate()` must not derive
    /// its expected values from the manifest it just regenerated.
    public static let frozenV1 = Self(
        schemaVersion: 1,
        artifactKind:
            "ergentics_prime_native_full_corpus_replay_observation",
        corpusID:
            "ergentics_prime_native_compositional_text_v1",
        generatorID:
            "ergentics_prime_swift_sha256_procedural_v1",
        tokenizerID:
            "ergentics_prime_nfc_utf8_byte_v1",
        consensusSeeds: [
            1_618,
            2_718,
            3_141,
        ],
        splitObservations: [
            SplitObservation(
                split: "train",
                rowCount: 131_072,
                rawTokenInstances: 31_138_522,
                orderedRowsSHA256:
                    "c03b316f571f101ca45b75c440c83b6b0a264f9ced73ba96a61bbaf65a9e9813",
                orderedEvaluationRowsSHA256:
                    "248461a1bd27fd289df677ec98e0fe13bcf94df8be7affec72345752c8e02493",
                semanticSetSHA256:
                    "c1fa09804d89733aa818b51e9079d4fdea3002297d5e365c3541caf6304fb6a0",
                promptSetSHA256:
                    "7e9694c6b8d62c6e77630389c24ed984816d891730cf693bcbdd8e2f6e3650ef",
                sequenceSetSHA256:
                    "d7259ac8f558f574ecc75464f9f3678d3da2100abec5fc9404365dd9974f517f",
                freshRegradeSHA256:
                    "82da3e4164bbab0a01d931b015f1d3cff41ad95c861fefc1f3cccc48ccafd906",
                acceptedRowCount: 131_072,
                firstRowID:
                    "train-000000-arithmetic_composition",
                firstRowSHA256:
                    "28da0f6d6b043df1d88259c76e2193548737701d8a7f3c13318bdbffb10e2b55",
                lastRowID:
                    "train-131071-negation_composition",
                lastRowSHA256:
                    "eb112cdf45eb2ba9730d6a0cda6ce161e19e449336ec68277e66ef798dba8efb"
            ),
            SplitObservation(
                split: "refusal_train",
                rowCount: 4_096,
                rawTokenInstances: 1_008_508,
                orderedRowsSHA256:
                    "699dfe19924f09d15e3e0cd6fac1c511813d1223592a86b7a577095327011359",
                orderedEvaluationRowsSHA256:
                    "d37679915d36aa9fde3da88a737d988b59ef8326096a9ada46abb3bf537d3410",
                semanticSetSHA256:
                    "40599a219f4ee69dd1ae1e28ff9c8b74952b2605c12f6c4a1db9d293c4612c3d",
                promptSetSHA256:
                    "f219ba49ede0247f16e58ce96800176ef664d5f35b93d81b77c492a7985d6c49",
                sequenceSetSHA256:
                    "7ce0e2d87c0acf3192895bb297fdd1f2148fe56f23b0b5261152d2c4ca59ad3e",
                freshRegradeSHA256:
                    "d85f3c36e37faafdabacc9d322ce805412aa4a57654c14e414d6c0ac386e20be",
                acceptedRowCount: 4_096,
                firstRowID:
                    "refusal_train-000000-arithmetic_composition",
                firstRowSHA256:
                    "e8c4accfa5b8161727156b112903b61c1d87092b49dcff657513e3541143febd",
                lastRowID:
                    "refusal_train-004095-sequence_ordering",
                lastRowSHA256:
                    "7c759c6c36ed0c17ba670f1b11c4fe0b123fe93378c7393b6aae7b60336c99fe"
            ),
            SplitObservation(
                split: "validation",
                rowCount: 4_096,
                rawTokenInstances: 1_086_090,
                orderedRowsSHA256:
                    "b113836b0f299acd60d9390948bb1cdc163478973a15953f05b7035e26ccf24b",
                orderedEvaluationRowsSHA256:
                    "8d1da3aa5923078f95cf4389364dba9e7554fd69afbf8807ffdb13f429a11f6b",
                semanticSetSHA256:
                    "34d7925a5f51f692d9c3803faf72f8e44024d458379187ef66d8419c4b772eb3",
                promptSetSHA256:
                    "7f15781c4fcb5d6c79a0b6c41d0c08ef73cfba6e74d22a5e4d946ebfc19d5043",
                sequenceSetSHA256:
                    "1944ef76a5754a7995cfd9d5bc0db163c06ab09c0ed99a3a0b8c952654aecd22",
                freshRegradeSHA256:
                    "99c9eaec0aed1445a4193bf3511be75e1d20d491bf19af5332feb90d417d5a26",
                acceptedRowCount: 4_096,
                firstRowID:
                    "validation-000000-arithmetic_composition",
                firstRowSHA256:
                    "c10bcbce9e7979280766911b54317ae137a5a4587dbfc0116fe249390bb519d2",
                lastRowID:
                    "validation-004095-sequence_ordering",
                lastRowSHA256:
                    "2e420d131ed1e4bdcc02857c66d7612f7afebd353630c8cff4b56ab8c5c481a1"
            ),
            SplitObservation(
                split: "refusal_validation",
                rowCount: 2_048,
                rawTokenInstances: 594_403,
                orderedRowsSHA256:
                    "51482b1b7eb8bd0d4afeed7e153a7e866220778ba76d6521bcb59251a4cfc567",
                orderedEvaluationRowsSHA256:
                    "05f476eb53486f45241a871bd35ea3467de8ea9c39e7e18b4eaec3a15986272b",
                semanticSetSHA256:
                    "a83a624c4cbad88665bb3363dc8d30019ab168c59be19ac850bcbca89a6aca5d",
                promptSetSHA256:
                    "592269ca87c03531602a980937ee01b01bf6ad27792dd2c76cdf941f6d73c1a1",
                sequenceSetSHA256:
                    "7c63ccd5c8b717ed308e0547bac820123b891c476e79ad771eb8a6b6cefec675",
                freshRegradeSHA256:
                    "4181e7fb1628a922bf3515afa49a4e95c41ac1db35ce85a1ad01749e7018572d",
                acceptedRowCount: 2_048,
                firstRowID:
                    "refusal_validation-000000-arithmetic_composition",
                firstRowSHA256:
                    "1572beb6e09656a736c1137e022eae25d1095657675b16f17ab003acc07a6a51",
                lastRowID:
                    "refusal_validation-002047-negation_composition",
                lastRowSHA256:
                    "364f4444b803ce3775cfee548899b2f11035a20de56774bb584ad93108a5a32a"
            ),
            SplitObservation(
                split: "combination_holdout",
                rowCount: 4_096,
                rawTokenInstances: 1_205_827,
                orderedRowsSHA256:
                    "dc087b4ef26e7b43d86e3982a067f128abda150f456941509cca2ca60ccbe810",
                orderedEvaluationRowsSHA256:
                    "f1cfbeccf8daacbee95689fb46ee00395cada3d6dee3eafe6e838fca69dd4d4a",
                semanticSetSHA256:
                    "3bf449d7bd5131a91cd6445200642a0c9cc4ddc3970edcfaf13e53881e5a41ef",
                promptSetSHA256:
                    "a10c3eb643d14f54f1c7a2a330fac3117bb0bf593fe2c6b34d6ff6b9a54cef44",
                sequenceSetSHA256:
                    "fb9463d8f782e833253386d2d78108a120ee9c691e2434757a1885bb2f9e7f19",
                freshRegradeSHA256:
                    "92f008acb09e94b2d30a0dc1283d323261072c47a4e6c1e1dc7bd041978e2732",
                acceptedRowCount: 4_096,
                firstRowID:
                    "combination_holdout-000000-arithmetic_composition",
                firstRowSHA256:
                    "7a54ac874f566223a137c5c985b43e054ded784a96c4ddbb377ff582f7048e07",
                lastRowID:
                    "combination_holdout-004095-sequence_ordering",
                lastRowSHA256:
                    "cb94607f9a09291745002ed7c2bf4308efc7956b319ae9556334d2742bef8bf5"
            ),
            SplitObservation(
                split: "ood",
                rowCount: 4_096,
                rawTokenInstances: 1_553_752,
                orderedRowsSHA256:
                    "5ec1b747579a985637c30ff6c880f50668eddd0203bec0f580f78f30fc3edeea",
                orderedEvaluationRowsSHA256:
                    "82f5c29dc6cb50c23a661838adf45157840aef0cdefae6a1eb82f56862c100db",
                semanticSetSHA256:
                    "58bff8b5be51d10d0004a5c5712472c1e5bcfdc635fb5c61757c3fdd1cda965c",
                promptSetSHA256:
                    "1a52f78d5262280c94ea6872e210a1b0d6a99d26aead85eac7bdcef7873e78ef",
                sequenceSetSHA256:
                    "d4f7c4a48dc9a0c4d7c1eccc0f448cca16d61844c71285783ef6f3697f3b0b92",
                freshRegradeSHA256:
                    "0c8da4892e3cb7483886f2f48386680fa214f9c93da424057acd36df8e515f42",
                acceptedRowCount: 4_096,
                firstRowID:
                    "ood-000000-arithmetic_composition",
                firstRowSHA256:
                    "16178d57e068d638926c8b1bbf92c78fca012f0b5ec7cafeb3c397e16e5e8243",
                lastRowID:
                    "ood-004095-sequence_ordering",
                lastRowSHA256:
                    "7e961c3330bd5948f7ca772d76c16ab0b85a388c0f58319c1497c218da18455b"
            ),
            SplitObservation(
                split: "mutation",
                rowCount: 4_096,
                rawTokenInstances: 1_275_481,
                orderedRowsSHA256:
                    "5c7700ea8e52a61dcdb07b1b148c0993c2541b3e23c28801250ed08c2c6c9391",
                orderedEvaluationRowsSHA256:
                    "f2a043157e70725f91d9d1126f22ec2dbfc011c32650e778e41054b4b7e290b5",
                semanticSetSHA256:
                    "40f2411445180c15c8dea0005aaa906746fd0974c1a5b60d8390eb59c059fa94",
                promptSetSHA256:
                    "c8cbfc219371f30de7f05d6deca46ad91429942c38b6203a5962d04e7e1231ef",
                sequenceSetSHA256:
                    "e02be8198569d23fb222a12ab229c8105edcee984fd41294b4ae4f63deb611c3",
                freshRegradeSHA256:
                    "150161a3c63194e1ad3807dd8692b51431aca59ce1be68da3a229e7d1bed2199",
                acceptedRowCount: 4_096,
                firstRowID:
                    "mutation-000000-arithmetic_composition",
                firstRowSHA256:
                    "6e855de4b03c136e91afc4ce21f459d3373db7a4af3d8b6d9a21c9b2dfa2690e",
                lastRowID:
                    "mutation-004095-sequence_ordering",
                lastRowSHA256:
                    "d21bd835a7e9ebcba7ed27ba20e0d9bac6bf885fc92651892f6103467c63d305"
            ),
            SplitObservation(
                split: "abstention",
                rowCount: 2_048,
                rawTokenInstances: 644_174,
                orderedRowsSHA256:
                    "bd63a9592b03a5493de0b67036dce027031f239fa692f3d588272be807d7135f",
                orderedEvaluationRowsSHA256:
                    "17e999ba61f0380e6ae1f91b944b75f48537d36d425e916372d18aeb4f24b684",
                semanticSetSHA256:
                    "12dd719ebada4e1691d86324d55fc46e956acd283bea6ad4480150de8363a35e",
                promptSetSHA256:
                    "9072066b3d6d85c771dcdc3ee8eb435e581e66957c033afce52c50a9e07122c9",
                sequenceSetSHA256:
                    "59dd9308b4c3d9d273db74e106ce3babdf0da4e2a5b28cafff641283dcbd2637",
                freshRegradeSHA256:
                    "604fcb2aa939a3a8fb932a33f8c4e5398d9d087e179d60186932f39237a8cee8",
                acceptedRowCount: 2_048,
                firstRowID:
                    "abstention-000000-arithmetic_composition",
                firstRowSHA256:
                    "07a49c33e17abed1f9d1a9a51d4a02b796841331c0901d1d4413a62ccdbfd2d9",
                lastRowID:
                    "abstention-002047-negation_composition",
                lastRowSHA256:
                    "f2ef59d6a6a263ff29154330eb750d14d1fbc6e7c802f7557e8810da3dc266c6"
            ),
        ],
        mutationSummary: MutationSummary(
            totalMutatedRowCount: 12_288,
            splitSummaries: [
                SplitMutationSummary(
                    split: "refusal_train",
                    mutatedRowCount: 4_096,
                    mutationCounts: [
                        NamedCount(
                            id: "malformed_ambiguous_query",
                            rowCount: 2_050
                        ),
                        NamedCount(
                            id:
                                "malformed_contradictory_relation",
                            rowCount: 341
                        ),
                        NamedCount(
                            id: "malformed_duplicate_entity",
                            rowCount: 341
                        ),
                        NamedCount(
                            id: "malformed_invalid_number",
                            rowCount: 341
                        ),
                        NamedCount(
                            id: "malformed_missing_history",
                            rowCount: 341
                        ),
                        NamedCount(
                            id: "malformed_unknown_entity",
                            rowCount: 341
                        ),
                        NamedCount(
                            id: "malformed_unknown_operation",
                            rowCount: 341
                        ),
                    ]
                ),
                SplitMutationSummary(
                    split: "refusal_validation",
                    mutatedRowCount: 2_048,
                    mutationCounts: [
                        NamedCount(
                            id: "malformed_ambiguous_query",
                            rowCount: 1_026
                        ),
                        NamedCount(
                            id:
                                "malformed_contradictory_relation",
                            rowCount: 170
                        ),
                        NamedCount(
                            id: "malformed_duplicate_entity",
                            rowCount: 170
                        ),
                        NamedCount(
                            id: "malformed_invalid_number",
                            rowCount: 171
                        ),
                        NamedCount(
                            id: "malformed_missing_history",
                            rowCount: 170
                        ),
                        NamedCount(
                            id: "malformed_unknown_entity",
                            rowCount: 170
                        ),
                        NamedCount(
                            id: "malformed_unknown_operation",
                            rowCount: 171
                        ),
                    ]
                ),
                SplitMutationSummary(
                    split: "mutation",
                    mutatedRowCount: 4_096,
                    mutationCounts: [
                        NamedCount(
                            id: "counterfactual_order_query",
                            rowCount: 683
                        ),
                        NamedCount(
                            id:
                                "counterfactual_relation_query",
                            rowCount: 682
                        ),
                        NamedCount(
                            id:
                                "counterfactual_terminal_add",
                            rowCount: 2_048
                        ),
                        NamedCount(
                            id:
                                "counterfactual_transfer_direction",
                            rowCount: 683
                        ),
                    ]
                ),
                SplitMutationSummary(
                    split: "abstention",
                    mutatedRowCount: 2_048,
                    mutationCounts: [
                        NamedCount(
                            id: "malformed_ambiguous_query",
                            rowCount: 1_026
                        ),
                        NamedCount(
                            id:
                                "malformed_contradictory_relation",
                            rowCount: 170
                        ),
                        NamedCount(
                            id: "malformed_duplicate_entity",
                            rowCount: 170
                        ),
                        NamedCount(
                            id: "malformed_invalid_number",
                            rowCount: 171
                        ),
                        NamedCount(
                            id: "malformed_missing_history",
                            rowCount: 170
                        ),
                        NamedCount(
                            id: "malformed_unknown_entity",
                            rowCount: 170
                        ),
                        NamedCount(
                            id: "malformed_unknown_operation",
                            rowCount: 171
                        ),
                    ]
                ),
            ],
            allCounterfactualParentsBound: true,
            allMalformedReasonsBound: true
        ),
        refusalSummary: RefusalSummary(
            trainingRowCount: 4_096,
            tuningRowCount: 2_048,
            finalEvaluationRowCount: 2_048,
            trainingPromptSetSHA256:
                "f219ba49ede0247f16e58ce96800176ef664d5f35b93d81b77c492a7985d6c49",
            tuningPromptSetSHA256:
                "592269ca87c03531602a980937ee01b01bf6ad27792dd2c76cdf941f6d73c1a1",
            finalEvaluationPromptSetSHA256:
                "9072066b3d6d85c771dcdc3ee8eb435e581e66957c033afce52c50a9e07122c9",
            trainingSemanticSetSHA256:
                "40599a219f4ee69dd1ae1e28ff9c8b74952b2605c12f6c4a1db9d293c4612c3d",
            tuningSemanticSetSHA256:
                "a83a624c4cbad88665bb3363dc8d30019ab168c59be19ac850bcbca89a6aca5d",
            finalEvaluationSemanticSetSHA256:
                "12dd719ebada4e1691d86324d55fc46e956acd283bea6ad4480150de8363a35e",
            trainingFreshRegradeSHA256:
                "d85f3c36e37faafdabacc9d322ce805412aa4a57654c14e414d6c0ac386e20be",
            tuningFreshRegradeSHA256:
                "4181e7fb1628a922bf3515afa49a4e95c41ac1db35ce85a1ad01749e7018572d",
            finalEvaluationFreshRegradeSHA256:
                "604fcb2aa939a3a8fb932a33f8c4e5398d9d087e179d60186932f39237a8cee8",
            trainingTuningPromptOverlapCount: 0,
            trainingFinalPromptOverlapCount: 0,
            tuningFinalPromptOverlapCount: 0,
            trainingTuningSemanticOverlapCount: 0,
            trainingFinalSemanticOverlapCount: 0,
            tuningFinalSemanticOverlapCount: 0,
            trainingTuningContractOverlapCount: 0,
            trainingFinalContractOverlapCount: 0,
            tuningFinalContractOverlapCount: 0,
            allReasonsTaught: true,
            allTuningAndEvaluationContractsHeldOut: true,
            allRowsAcceptedByFreshRegrade: true
        ),
        leakageSummary: LeakageSummary(
            trainEvaluationPromptOverlapCount: 0,
            trainEvaluationSemanticOverlapCount: 0,
            refusalTrainEvaluationPromptOverlapCount: 0,
            refusalTrainEvaluationSemanticOverlapCount: 0,
            refusalTrainAbstentionContractOverlapCount: 0,
            trainCombinationPairOverlapCount: 0,
            trainCombinationCodebookIntersectionCount: 3,
            trainCombinationSurfaceIntersectionCount: 3,
            trainOODCodebookIntersectionCount: 0,
            trainOODSurfaceIntersectionCount: 0,
            combinationComponentsSeenInTrain: true,
            combinationPairsAbsentFromTrain: true,
            exactLookupEvaluationHits: 0,
            allRowIDsUnique: true,
            allRowHashesUnique: true,
            allValidSemanticsDisjointAcrossSplits: true
        ),
        falsifierSummary: FalsifierSummary(
            falsifierCount: 10,
            detectedCount: 10,
            totalTrials: 185_351,
            totalDetections: 1_034
        ),
        fullRowCount: 155_648,
        acceptedRowCount: 155_648,
        rawTokenInstances: 38_506_757,
        corpusManifestSHA256:
            "7f42e6f0504e3751fca24bcce35f17fa361b4efcbd577f679fff7577f3e98ba7",
        orderedCorpusRowsSHA256:
            "db7c62b9f1297c5b4fe020053548d1fdc46fde69b37cf59d4d822d01d0c1fb65",
        falsifierSHA256:
            "95d3241959b02b4a4cc57aa824078150f3059811f2e7745d84b7e8e16d3e104a",
        tokenizerManifestSHA256:
            "f9f768268edb488aaf7168453b703f2d2a78a1036572368c76f53f4f436434c7",
        tokenizerReplayProbeSHA256:
            "9ce743183b0aecaf4e976d912382ebc11f5f6b07a868f76470dd5a0a6061f5bb",
        corpusManifestPrettyBytesSHA256:
            "fbb7362ee63b5825d1914815e8ff93c26a2c9a7de8be19347ccec3e449de8031",
        tokenizerManifestPrettyBytesSHA256:
            "5e3db93d26535cbb66b14f0170b1e04882aa942560af3c8b571d76dfaaa9f302",
        sameImplementationSemanticEvaluator: true,
        algorithmicallyIndependentSemanticOracle: false,
        independentScientificOracleClaimed: false,
        authorityStatement:
            "Every row was freshly regraded by the transplanted corpus blob's same-implementation text evaluator. This is deterministic first-party replay evidence, not an algorithmically independent scientific oracle."
    )
}
