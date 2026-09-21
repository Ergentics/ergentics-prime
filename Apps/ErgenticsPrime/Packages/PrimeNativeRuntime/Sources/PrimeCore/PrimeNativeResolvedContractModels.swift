import Foundation

public enum PrimeNativeResolvedContractModelError:
    Error,
    Equatable,
    LocalizedError,
    Sendable
{
    case invalidRowID
    case promptTooLarge
    case promptEncodingMismatch
    case generatedOutputTooLarge
    case generatedTokenLogProbabilityCountMismatch
    case nonFiniteGenerationObservation
    case positiveLogProbability
    case generationTerminationMismatch
    case generatedCompletionMismatch
    case invalidSHA256(String)
    case invalidExpectedCompletion
    case regradeRowMismatch
    case evaluationContractDrift
    case syntheticEnvelopeDrift
    case unexpectedField(String)

    public var errorDescription: String? {
        switch self {
        case .invalidRowID:
            "native contract row ID is invalid"
        case .promptTooLarge:
            "prompt exceeds the bounded native request size"
        case .promptEncodingMismatch:
            "prompt text, token IDs, or grouping key drifted"
        case .generatedOutputTooLarge:
            "generated output exceeds the bounded transport size"
        case .generatedTokenLogProbabilityCountMismatch:
            "generated token and log-probability counts differ"
        case .nonFiniteGenerationObservation:
            "generation observation contains a non-finite value"
        case .positiveLogProbability:
            "generation observation contains a positive log probability"
        case .generationTerminationMismatch:
            "generation termination evidence is inconsistent"
        case .generatedCompletionMismatch:
            "generated completion differs from its token IDs"
        case let .invalidSHA256(field):
            "native contract field is not lowercase SHA-256: \(field)"
        case .invalidExpectedCompletion:
            "expected completion differs from its token IDs"
        case .regradeRowMismatch:
            "generation and regrade authority row IDs differ"
        case .evaluationContractDrift:
            "resolved evaluation contract drifted"
        case .syntheticEnvelopeDrift:
            "resolved synthetic regrade envelope drifted"
        case let .unexpectedField(field):
            "native contract contains an unexpected field: \(field)"
        }
    }
}

private struct PrimeNativeResolvedContractAnyCodingKey:
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

private func rejectUnknownPrimeNativeContractKeys<K>(
    from decoder: Decoder,
    admittedBy _: K.Type
) throws
where
    K: CodingKey & CaseIterable & RawRepresentable,
    K.RawValue == String
{
    let dynamic = try decoder.container(
        keyedBy:
            PrimeNativeResolvedContractAnyCodingKey
            .self
    )
    let admitted = Set(
        K.allCases.map(\.rawValue)
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
                    "unadmitted native contract keys: \(unknown.joined(separator: ", "))"
            )
        )
    }
}

private func exactPrimeNativeUTF8String(
    tokenIDs: [Int],
    declared: String
) throws -> String {
    let bytes = try tokenIDs.map {
        try PrimeNativeByteTokenizer.byte(
            forTokenID: $0
        )
    }
    guard let decoded = String(
            data: Data(bytes),
            encoding: .utf8
          ),
          Array(declared.utf8) == bytes else {
        throw PrimeNativeResolvedContractModelError
            .generatedCompletionMismatch
    }
    return decoded
}

/// Model-facing request whose type cannot represent target or verifier data.
///
/// The prompt is NFC-normalized and encoded immediately. The transport bound
/// is a memory-safety limit, not a fixed-cap/EOS scientific contract.
public struct PrimeNativePromptOnlyGenerationRequest:
    Codable,
    Equatable,
    Sendable
{
    public static let maximumPromptByteTokenCount =
        4_096

    public let rowID: String
    public let seed: Int
    public let promptText: String
    public let promptTokenIDs: [Int]
    public let promptGroupingKey: Int

    public init(
        rowID: String,
        seed: Int,
        promptText: String
    ) throws {
        guard Self.validRowID(rowID) else {
            throw PrimeNativeResolvedContractModelError
                .invalidRowID
        }
        let canonical =
            PrimeNativeByteTokenizer
            .canonicalize(promptText)
        let byteTokens =
            PrimeNativeByteTokenizer.encode(canonical)
        guard byteTokens.count
                <= Self
                .maximumPromptByteTokenCount else {
            throw PrimeNativeResolvedContractModelError
                .promptTooLarge
        }
        self.rowID = rowID
        self.seed = seed
        self.promptText = canonical
        self.promptTokenIDs =
            [
                PrimeNativeByteTokenizer
                    .beginningOfSequenceTokenID,
            ] + byteTokens
        promptGroupingKey = byteTokens.count
    }

    private static func validRowID(
        _ value: String
    ) -> Bool {
        !value.isEmpty
            && value.utf8.count <= 512
            && !value.contains("\0")
    }

    public init(from decoder: Decoder) throws {
        try rejectUnknownPrimeNativeContractKeys(
            from: decoder,
            admittedBy: CodingKeys.self
        )
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )
        let decodedPromptTokenIDs = try container.decode(
            [Int].self,
            forKey: .promptTokenIDs
        )
        let decodedPromptGroupingKey =
            try container.decode(
                Int.self,
                forKey: .promptGroupingKey
            )
        let validated = try Self(
            rowID: container.decode(
                String.self,
                forKey: .rowID
            ),
            seed: container.decode(
                Int.self,
                forKey: .seed
            ),
            promptText: container.decode(
                String.self,
                forKey: .promptText
            )
        )
        guard decodedPromptTokenIDs
                == validated.promptTokenIDs,
              decodedPromptGroupingKey
                == validated.promptGroupingKey else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: decoder.codingPath,
                    debugDescription:
                        "prompt tokenization or grouping key differs from the canonical prompt"
                )
            )
        }
        self = validated
    }

    private enum CodingKeys:
        String,
        CodingKey,
        CaseIterable
    {
        case rowID = "row_id"
        case seed
        case promptText = "prompt_text"
        case promptTokenIDs = "prompt_token_ids"
        case promptGroupingKey =
            "prompt_grouping_key"
    }
}

public enum PrimeNativeGenerationTermination:
    String,
    Codable,
    Equatable,
    Sendable
{
    case endOfSequence = "end_of_sequence"
    case decisionLimit = "decision_limit"
}

/// Raw post-generation observation. It contains no expected answer or grade.
///
/// The 4,096-token ceiling is only a transport-safety limit. This type does
/// not assert that the unresolved historical fixed-cap value was 4,096.
public struct PrimeNativeGenerationObservation:
    Codable,
    Equatable,
    Sendable
{
    public static let maximumGeneratedByteTokenCount =
        4_096

    public let rowID: String
    public let seed: Int
    public let generatedTokenIDs: [Int]
    public let generatedCompletion: String
    public let tokenLogProbabilities: [Double]
    public let termination:
        PrimeNativeGenerationTermination
    public let eosLogProbability: Double?
    public let latencySeconds: Double

    public init(
        rowID: String,
        seed: Int,
        generatedTokenIDs: [Int],
        generatedCompletion: String,
        tokenLogProbabilities: [Double],
        termination:
            PrimeNativeGenerationTermination,
        eosLogProbability: Double?,
        latencySeconds: Double
    ) throws {
        guard !rowID.isEmpty,
              rowID.utf8.count <= 512,
              !rowID.contains("\0") else {
            throw PrimeNativeResolvedContractModelError
                .invalidRowID
        }
        guard generatedTokenIDs.count
                <= Self
                .maximumGeneratedByteTokenCount else {
            throw PrimeNativeResolvedContractModelError
                .generatedOutputTooLarge
        }
        guard generatedTokenIDs.count
                == tokenLogProbabilities.count else {
            throw PrimeNativeResolvedContractModelError
                .generatedTokenLogProbabilityCountMismatch
        }
        guard tokenLogProbabilities
                .allSatisfy(\.isFinite),
              latencySeconds.isFinite,
              latencySeconds >= 0 else {
            throw PrimeNativeResolvedContractModelError
                .nonFiniteGenerationObservation
        }
        guard tokenLogProbabilities.allSatisfy({
            $0 <= 0
        }),
            eosLogProbability.map({
                $0 <= 0
            }) ?? true
        else {
            throw PrimeNativeResolvedContractModelError
                .positiveLogProbability
        }
        switch termination {
        case .endOfSequence:
            guard eosLogProbability?.isFinite == true else {
                throw PrimeNativeResolvedContractModelError
                    .generationTerminationMismatch
            }
        case .decisionLimit:
            guard eosLogProbability == nil else {
                throw PrimeNativeResolvedContractModelError
                    .generationTerminationMismatch
            }
        }
        let decoded = try exactPrimeNativeUTF8String(
            tokenIDs: generatedTokenIDs,
            declared: generatedCompletion
        )
        self.rowID = rowID
        self.seed = seed
        self.generatedTokenIDs =
            generatedTokenIDs
        self.generatedCompletion = decoded
        self.tokenLogProbabilities =
            tokenLogProbabilities
        self.termination = termination
        self.eosLogProbability =
            eosLogProbability
        self.latencySeconds = latencySeconds
    }

    public init(from decoder: Decoder) throws {
        try rejectUnknownPrimeNativeContractKeys(
            from: decoder,
            admittedBy: CodingKeys.self
        )
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )
        self = try Self(
            rowID: container.decode(
                String.self,
                forKey: .rowID
            ),
            seed: container.decode(
                Int.self,
                forKey: .seed
            ),
            generatedTokenIDs: container.decode(
                [Int].self,
                forKey: .generatedTokenIDs
            ),
            generatedCompletion: container.decode(
                String.self,
                forKey: .generatedCompletion
            ),
            tokenLogProbabilities:
                container.decode(
                    [Double].self,
                    forKey: .tokenLogProbabilities
                ),
            termination: container.decode(
                PrimeNativeGenerationTermination.self,
                forKey: .termination
            ),
            eosLogProbability:
                container.decodeIfPresent(
                    Double.self,
                    forKey: .eosLogProbability
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
        case rowID = "row_id"
        case seed
        case generatedTokenIDs =
            "generated_token_ids"
        case generatedCompletion =
            "generated_completion"
        case tokenLogProbabilities =
            "token_log_probabilities"
        case termination
        case eosLogProbability =
            "eos_log_probability"
        case latencySeconds = "latency_seconds"
    }
}

public enum PrimeNativeEvaluationSplit:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Sendable
{
    case validation
    case combinationHoldout =
        "combination_holdout"
    case outOfDistribution = "ood"
    case mutation
    case abstention
}

/// Target-bearing authority admitted only after model generation completes.
public struct PrimeNativeRegradeAuthority:
    Codable,
    Equatable,
    Sendable
{
    public let rowID: String
    public let corpusRowSHA256: String
    public let evaluationRowSHA256: String
    public let split: PrimeNativeEvaluationSplit
    public let semanticFamily: String
    public let mutationID: String?
    public let expectedCompletion: String
    public let expectedCompletionTokenIDs: [Int]

    public init(
        rowID: String,
        corpusRowSHA256: String,
        evaluationRowSHA256: String,
        split: PrimeNativeEvaluationSplit,
        semanticFamily: String,
        mutationID: String?,
        expectedCompletion: String,
        expectedCompletionTokenIDs: [Int]
    ) throws {
        guard !rowID.isEmpty,
              rowID.utf8.count <= 512,
              !rowID.contains("\0") else {
            throw PrimeNativeResolvedContractModelError
                .invalidRowID
        }
        guard Self.isSHA256(corpusRowSHA256) else {
            throw PrimeNativeResolvedContractModelError
                .invalidSHA256("corpus_row_sha256")
        }
        guard Self.isSHA256(
            evaluationRowSHA256
        ) else {
            throw PrimeNativeResolvedContractModelError
                .invalidSHA256(
                    "evaluation_row_sha256"
                )
        }
        let decoded: String
        do {
            decoded = try exactPrimeNativeUTF8String(
                tokenIDs:
                    expectedCompletionTokenIDs,
                declared: expectedCompletion
            )
        } catch {
            throw PrimeNativeResolvedContractModelError
                .invalidExpectedCompletion
        }
        self.rowID = rowID
        self.corpusRowSHA256 = corpusRowSHA256
        self.evaluationRowSHA256 =
            evaluationRowSHA256
        self.split = split
        self.semanticFamily = semanticFamily
        self.mutationID = mutationID
        self.expectedCompletion = decoded
        self.expectedCompletionTokenIDs =
            expectedCompletionTokenIDs
    }

    private static func isSHA256(
        _ value: String
    ) -> Bool {
        value.utf8.count == 64
            && value.utf8.allSatisfy {
                ($0 >= 48 && $0 <= 57)
                    || ($0 >= 97 && $0 <= 102)
            }
    }

    public init(from decoder: Decoder) throws {
        try rejectUnknownPrimeNativeContractKeys(
            from: decoder,
            admittedBy: CodingKeys.self
        )
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )
        self = try Self(
            rowID: container.decode(
                String.self,
                forKey: .rowID
            ),
            corpusRowSHA256: container.decode(
                String.self,
                forKey: .corpusRowSHA256
            ),
            evaluationRowSHA256:
                container.decode(
                    String.self,
                    forKey: .evaluationRowSHA256
                ),
            split: container.decode(
                PrimeNativeEvaluationSplit.self,
                forKey: .split
            ),
            semanticFamily: container.decode(
                String.self,
                forKey: .semanticFamily
            ),
            mutationID: container.decodeIfPresent(
                String.self,
                forKey: .mutationID
            ),
            expectedCompletion: container.decode(
                String.self,
                forKey: .expectedCompletion
            ),
            expectedCompletionTokenIDs:
                container.decode(
                    [Int].self,
                    forKey:
                        .expectedCompletionTokenIDs
                )
        )
    }

    private enum CodingKeys:
        String,
        CodingKey,
        CaseIterable
    {
        case rowID = "row_id"
        case corpusRowSHA256 =
            "corpus_row_sha256"
        case evaluationRowSHA256 =
            "evaluation_row_sha256"
        case split
        case semanticFamily = "semantic_family"
        case mutationID = "mutation_id"
        case expectedCompletion =
            "expected_completion"
        case expectedCompletionTokenIDs =
            "expected_completion_token_ids"
    }
}

public struct PrimeNativeRegradeInput:
    Codable,
    Equatable,
    Sendable
{
    public let observation:
        PrimeNativeGenerationObservation
    public let authority:
        PrimeNativeRegradeAuthority

    public init(
        observation:
            PrimeNativeGenerationObservation,
        authority:
            PrimeNativeRegradeAuthority
    ) throws {
        guard observation.rowID
                == authority.rowID else {
            throw PrimeNativeResolvedContractModelError
                .regradeRowMismatch
        }
        self.observation = observation
        self.authority = authority
    }

    public init(from decoder: Decoder) throws {
        try rejectUnknownPrimeNativeContractKeys(
            from: decoder,
            admittedBy: CodingKeys.self
        )
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )
        self = try Self(
            observation: container.decode(
                PrimeNativeGenerationObservation.self,
                forKey: .observation
            ),
            authority: container.decode(
                PrimeNativeRegradeAuthority.self,
                forKey: .authority
            )
        )
    }

    private enum CodingKeys:
        String,
        CodingKey,
        CaseIterable
    {
        case observation
        case authority
    }
}

public struct PrimeNativeRegradeResult:
    Codable,
    Equatable,
    Sendable
{
    public let rowID: String
    public let seed: Int
    public let exactMatch: Bool
    public let semanticVerifierPass: Bool
    public let abstentionDecision: Bool
    public let independentScientificOracleClaimed:
        Bool

    public init(
        rowID: String,
        seed: Int,
        exactMatch: Bool,
        semanticVerifierPass: Bool,
        abstentionDecision: Bool
    ) {
        self.rowID = rowID
        self.seed = seed
        self.exactMatch = exactMatch
        self.semanticVerifierPass =
            semanticVerifierPass
        self.abstentionDecision =
            abstentionDecision
        independentScientificOracleClaimed = false
    }

    public init(from decoder: Decoder) throws {
        try rejectUnknownPrimeNativeContractKeys(
            from: decoder,
            admittedBy: CodingKeys.self
        )
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )
        guard try container.decode(
            Bool.self,
            forKey:
                .independentScientificOracleClaimed
        ) == false else {
            throw DecodingError.dataCorruptedError(
                forKey:
                    .independentScientificOracleClaimed,
                in: container,
                debugDescription:
                    "bounded regrade results cannot claim an independent scientific oracle"
            )
        }
        self = Self(
            rowID: try container.decode(
                String.self,
                forKey: .rowID
            ),
            seed: try container.decode(
                Int.self,
                forKey: .seed
            ),
            exactMatch: try container.decode(
                Bool.self,
                forKey: .exactMatch
            ),
            semanticVerifierPass:
                try container.decode(
                    Bool.self,
                    forKey: .semanticVerifierPass
                ),
            abstentionDecision:
                try container.decode(
                    Bool.self,
                    forKey: .abstentionDecision
                )
        )
    }

    private enum CodingKeys:
        String,
        CodingKey,
        CaseIterable
    {
        case rowID = "row_id"
        case seed
        case exactMatch = "exact_match"
        case semanticVerifierPass =
            "semantic_verifier_pass"
        case abstentionDecision =
            "abstention_decision"
        case independentScientificOracleClaimed =
            "independent_scientific_oracle_claimed"
    }
}

/// Exact bounded projection of the evaluation metadata present in the
/// resolved corpus manifest. This is not the separately missing fixed-cap/EOS
/// generation wire contract.
public struct PrimeNativeEvaluationContract:
    Codable,
    Equatable,
    Sendable
{
    public let promptField: String
    public let expectedCompletionField: String
    public let exactMatchNormalization: String
    public let causalLossMask: String
    public let abstentionCompletion: String
    public let selectionTuningSplits: [String]
    public let requiredRawResultSplits: [String]
    public let requiredRawResultFields: [String]
    public let evaluationRowSHA256CanonicalFields:
        [String]
    public let evaluationRowAbsentMutationEncoding:
        String
    public let szCanonicalFields: [String]
    public let triadicWitnesses: [String]
    public let verifyAbstainMinimumIndependentWitnesses:
        Int
    public let verifyAbstainCriticalLegs: [String]
    public let multiSeedConsensusSeeds: [Int]

    public static let frozenV1 = Self(
        promptField: "prompt_text",
        expectedCompletionField:
            "expected_completion",
        exactMatchNormalization: "none",
        causalLossMask:
            "loss begins at first expected_completion byte; prompt and BOS are masked",
        abstentionCompletion: "ABSTAIN\n",
        selectionTuningSplits: [
            "validation",
            "refusal_validation",
        ],
        requiredRawResultSplits: [
            "validation",
            "combination_holdout",
            "ood",
            "mutation",
            "abstention",
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
        evaluationRowAbsentMutationEncoding:
            "json_null",
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
        verifyAbstainMinimumIndependentWitnesses:
            3,
        verifyAbstainCriticalLegs: [
            "manifest_and_row_hashes",
            "all_valid_semantic_regrades",
            "malformed_abstention_regrades",
            "mutation_synthesis",
            "multi_seed_consensus",
        ],
        multiSeedConsensusSeeds: [
            1_618,
            2_718,
            3_141,
        ]
    )

    public init(
        promptField: String,
        expectedCompletionField: String,
        exactMatchNormalization: String,
        causalLossMask: String,
        abstentionCompletion: String,
        selectionTuningSplits: [String],
        requiredRawResultSplits: [String],
        requiredRawResultFields: [String],
        evaluationRowSHA256CanonicalFields:
            [String],
        evaluationRowAbsentMutationEncoding:
            String,
        szCanonicalFields: [String],
        triadicWitnesses: [String],
        verifyAbstainMinimumIndependentWitnesses:
            Int,
        verifyAbstainCriticalLegs: [String],
        multiSeedConsensusSeeds: [Int]
    ) {
        self.promptField = promptField
        self.expectedCompletionField =
            expectedCompletionField
        self.exactMatchNormalization =
            exactMatchNormalization
        self.causalLossMask = causalLossMask
        self.abstentionCompletion =
            abstentionCompletion
        self.selectionTuningSplits =
            selectionTuningSplits
        self.requiredRawResultSplits =
            requiredRawResultSplits
        self.requiredRawResultFields =
            requiredRawResultFields
        self.evaluationRowSHA256CanonicalFields =
            evaluationRowSHA256CanonicalFields
        self.evaluationRowAbsentMutationEncoding =
            evaluationRowAbsentMutationEncoding
        self.szCanonicalFields = szCanonicalFields
        self.triadicWitnesses = triadicWitnesses
        self
            .verifyAbstainMinimumIndependentWitnesses =
            verifyAbstainMinimumIndependentWitnesses
        self.verifyAbstainCriticalLegs =
            verifyAbstainCriticalLegs
        self.multiSeedConsensusSeeds =
            multiSeedConsensusSeeds
    }

    public func validateFrozenV1() throws {
        guard self == Self.frozenV1,
              Set(requiredRawResultSplits).count
                == requiredRawResultSplits.count,
              Set(requiredRawResultFields).count
                == requiredRawResultFields.count,
              Set(multiSeedConsensusSeeds).count
                == multiSeedConsensusSeeds.count else {
            throw PrimeNativeResolvedContractModelError
                .evaluationContractDrift
        }
    }

    private enum CodingKeys: String, CodingKey {
        case promptField = "prompt_field"
        case expectedCompletionField =
            "expected_completion_field"
        case exactMatchNormalization =
            "exact_match_normalization"
        case causalLossMask = "causal_loss_mask"
        case abstentionCompletion =
            "abstention_completion"
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
        case szCanonicalFields =
            "sz_canonical_fields"
        case triadicWitnesses =
            "triadic_witnesses"
        case verifyAbstainMinimumIndependentWitnesses =
            "verify_abstain_minimum_independent_witnesses"
        case verifyAbstainCriticalLegs =
            "verify_abstain_critical_legs"
        case multiSeedConsensusSeeds =
            "multi_seed_consensus_seeds"
    }
}

public struct PrimeNativeSyntheticRegradeClaimScope:
    Codable,
    Equatable,
    Sendable
{
    public let syntheticFirstPartyContractAndMutationVerification:
        Bool
    public let schema4ProfileExecutionPerformed: Bool
    public let schema4ProfileArtifactsPresent: Bool
    public let metalTrainingEvidenceClaimed: Bool
    public let checkpointAccepted: Bool
    public let functionalLanguageCapabilityClaimed: Bool
    public let broadLanguageCapabilityClaimed: Bool
    public let productPromotionAuthorized: Bool
    public let quantizationAuthorized: Bool
    public let diagonalHessianAuthorized: Bool

    public init(
        syntheticFirstPartyContractAndMutationVerification:
            Bool,
        schema4ProfileExecutionPerformed: Bool,
        schema4ProfileArtifactsPresent: Bool,
        metalTrainingEvidenceClaimed: Bool,
        checkpointAccepted: Bool,
        functionalLanguageCapabilityClaimed: Bool,
        broadLanguageCapabilityClaimed: Bool,
        productPromotionAuthorized: Bool,
        quantizationAuthorized: Bool,
        diagonalHessianAuthorized: Bool
    ) {
        self
            .syntheticFirstPartyContractAndMutationVerification =
            syntheticFirstPartyContractAndMutationVerification
        self.schema4ProfileExecutionPerformed =
            schema4ProfileExecutionPerformed
        self.schema4ProfileArtifactsPresent =
            schema4ProfileArtifactsPresent
        self.metalTrainingEvidenceClaimed =
            metalTrainingEvidenceClaimed
        self.checkpointAccepted = checkpointAccepted
        self.functionalLanguageCapabilityClaimed =
            functionalLanguageCapabilityClaimed
        self.broadLanguageCapabilityClaimed =
            broadLanguageCapabilityClaimed
        self.productPromotionAuthorized =
            productPromotionAuthorized
        self.quantizationAuthorized =
            quantizationAuthorized
        self.diagonalHessianAuthorized =
            diagonalHessianAuthorized
    }

    private enum CodingKeys: String, CodingKey {
        case syntheticFirstPartyContractAndMutationVerification =
            "synthetic_first_party_contract_and_mutation_verification"
        case schema4ProfileExecutionPerformed =
            "schema_4_profile_execution_performed"
        case schema4ProfileArtifactsPresent =
            "schema_4_profile_artifacts_present"
        case metalTrainingEvidenceClaimed =
            "metal_training_evidence_claimed"
        case checkpointAccepted =
            "checkpoint_accepted"
        case functionalLanguageCapabilityClaimed =
            "functional_language_capability_claimed"
        case broadLanguageCapabilityClaimed =
            "broad_language_capability_claimed"
        case productPromotionAuthorized =
            "product_promotion_authorized"
        case quantizationAuthorized =
            "quantization_authorized"
        case diagonalHessianAuthorized =
            "diagonal_hessian_authorized"
    }
}

public struct PrimeNativeSyntheticRegradeGate:
    Codable,
    Equatable,
    Sendable
{
    public let outcome: String
    public let criticalLegsPassed: Int
    public let criticalLegsTotal: Int
    public let namedMutationsDetectedAndRestored: Int
    public let namedMutationsTotal: Int
    public let recordCount: Int
    public let triadicVerdict: String
    public let printedNextAction: String
    public let printedNextActionScope: String
    public let printedNextActionSupersedesCurrentAction:
        Bool

    public init(
        outcome: String,
        criticalLegsPassed: Int,
        criticalLegsTotal: Int,
        namedMutationsDetectedAndRestored: Int,
        namedMutationsTotal: Int,
        recordCount: Int,
        triadicVerdict: String,
        printedNextAction: String,
        printedNextActionScope: String,
        printedNextActionSupersedesCurrentAction:
            Bool
    ) {
        self.outcome = outcome
        self.criticalLegsPassed =
            criticalLegsPassed
        self.criticalLegsTotal = criticalLegsTotal
        self.namedMutationsDetectedAndRestored =
            namedMutationsDetectedAndRestored
        self.namedMutationsTotal =
            namedMutationsTotal
        self.recordCount = recordCount
        self.triadicVerdict = triadicVerdict
        self.printedNextAction =
            printedNextAction
        self.printedNextActionScope =
            printedNextActionScope
        self
            .printedNextActionSupersedesCurrentAction =
            printedNextActionSupersedesCurrentAction
    }

    private enum CodingKeys: String, CodingKey {
        case outcome
        case criticalLegsPassed =
            "critical_legs_passed"
        case criticalLegsTotal =
            "critical_legs_total"
        case namedMutationsDetectedAndRestored =
            "named_mutations_detected_and_restored"
        case namedMutationsTotal =
            "named_mutations_total"
        case recordCount = "record_count"
        case triadicVerdict = "triadic_verdict"
        case printedNextAction =
            "printed_next_action"
        case printedNextActionScope =
            "printed_next_action_scope"
        case printedNextActionSupersedesCurrentAction =
            "printed_next_action_supersedes_current_action"
    }
}

/// Bounded projection of the historical synthetic Verify/Abstain receipt.
///
/// It deliberately omits process timing, shell-capture history, dependency
/// bindings, and any model or product authority.
public struct PrimeNativeSyntheticRegradeEnvelope:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: String
    public let artifactID: String
    public let classification: String
    public let executionLanguage: String
    public let contractReportSchemaVersion: String
    public let claimScope:
        PrimeNativeSyntheticRegradeClaimScope
    public let gate: PrimeNativeSyntheticRegradeGate
    public let currentAction: String

    public static let frozenV1 = Self(
        schemaVersion: "1",
        artifactID:
            "prime_native_language_schema4_verify_abstain_revalidation_receipt_v1",
        classification:
            "synthetic_first_party_contract_and_mutation_verification_only",
        executionLanguage: "swift",
        contractReportSchemaVersion: "4",
        claimScope:
            PrimeNativeSyntheticRegradeClaimScope(
                syntheticFirstPartyContractAndMutationVerification:
                    true,
                schema4ProfileExecutionPerformed:
                    false,
                schema4ProfileArtifactsPresent:
                    false,
                metalTrainingEvidenceClaimed:
                    false,
                checkpointAccepted: false,
                functionalLanguageCapabilityClaimed:
                    false,
                broadLanguageCapabilityClaimed:
                    false,
                productPromotionAuthorized:
                    false,
                quantizationAuthorized: false,
                diagonalHessianAuthorized: false
            ),
        gate: PrimeNativeSyntheticRegradeGate(
            outcome: "GROUNDED",
            criticalLegsPassed: 10,
            criticalLegsTotal: 10,
            namedMutationsDetectedAndRestored: 46,
            namedMutationsTotal: 46,
            recordCount: 59_497,
            triadicVerdict:
                "independentThreePlus(10)",
            printedNextAction:
                "admit_isolated_prime_domain_transfer_canary",
            printedNextActionScope:
                "synthetic_fixture_diagnostic_only",
            printedNextActionSupersedesCurrentAction:
                false
        ),
        currentAction:
            "run_fresh_schema_4_exact_9_discovery_then_conditional_6_confirmation_first_party_swift_mlx_metal_profile_screen"
    )

    public init(
        schemaVersion: String,
        artifactID: String,
        classification: String,
        executionLanguage: String,
        contractReportSchemaVersion: String,
        claimScope:
            PrimeNativeSyntheticRegradeClaimScope,
        gate: PrimeNativeSyntheticRegradeGate,
        currentAction: String
    ) {
        self.schemaVersion = schemaVersion
        self.artifactID = artifactID
        self.classification = classification
        self.executionLanguage = executionLanguage
        self.contractReportSchemaVersion =
            contractReportSchemaVersion
        self.claimScope = claimScope
        self.gate = gate
        self.currentAction = currentAction
    }

    public func validateFrozenV1() throws {
        guard self == Self.frozenV1,
              claimScope
                .syntheticFirstPartyContractAndMutationVerification,
              !claimScope
                .schema4ProfileExecutionPerformed,
              !claimScope.schema4ProfileArtifactsPresent,
              !claimScope.metalTrainingEvidenceClaimed,
              !claimScope.checkpointAccepted,
              !claimScope
                .functionalLanguageCapabilityClaimed,
              !claimScope
                .broadLanguageCapabilityClaimed,
              !claimScope.productPromotionAuthorized,
              !claimScope.quantizationAuthorized,
              !claimScope.diagonalHessianAuthorized,
              gate.criticalLegsPassed
                == gate.criticalLegsTotal,
              gate.namedMutationsDetectedAndRestored
                == gate.namedMutationsTotal,
              !gate
                .printedNextActionSupersedesCurrentAction else {
            throw PrimeNativeResolvedContractModelError
                .syntheticEnvelopeDrift
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case artifactID = "artifact_id"
        case classification
        case executionLanguage = "execution_language"
        case contractReportSchemaVersion =
            "contract_report_schema_version"
        case claimScope = "claim_scope"
        case gate
        case currentAction = "current_action"
    }
}
