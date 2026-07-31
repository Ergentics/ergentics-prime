import Foundation
import PrimeNativeCorpusReplayMechanics
import PrimeNativeNeuralGateCorrectedMechanics
import PrimeNativeNeuralGateCorrectedEvaluationMechanics

public enum PrimeNativeNeuralGateCorrectedFixtureObservationError:
    Error,
    Equatable,
    Sendable
{
    case splitOrderDrift
    case splitCountDrift(
        split: String,
        expected: Int,
        actual: Int
    )
    case rowCountDrift(expected: Int, actual: Int)
    case duplicateRowIdentity
    case duplicatePromptIdentity
    case invalidSourceRow(String)
    case invalidSourceBinding
    case invalidReceiptBinding
    case tokenizerContractDrift
    case invalidTokenID(Int)
    case promptBindingDrift(String)
    case completionFeasibilityDrift
    case canonicalEncodingFailure
    case frozenGoldenDrift
}

/// Source-derived identity of the corrected Stage-B evaluation fixture.
///
/// This target intentionally depends on the trap-bearing, byte-exact corpus
/// transplant only to derive a frozen fixture observation. The pure corrected
/// executor target does not depend on this target or on the corpus transplant.
/// This value binds no solver, logits, model execution, Stage-B process,
/// receipt, or product authority.
public struct PrimeNativeNeuralGateCorrectedFixtureObservation:
    Codable,
    Equatable,
    Sendable
{
    public struct SplitIdentity:
        Codable,
        Equatable,
        Sendable
    {
        public let split: String
        public let rowCount: Int
        public let orderedEvaluationRowsSHA256:
            String
        public let firstRowID: String
        public let lastRowID: String

        private enum CodingKeys: String, CodingKey {
            case split
            case rowCount = "row_count"
            case orderedEvaluationRowsSHA256 =
                "ordered_evaluation_rows_sha256"
            case firstRowID = "first_row_id"
            case lastRowID = "last_row_id"
        }
    }

    public struct SourceBinding:
        Codable,
        Equatable,
        Sendable
    {
        public let role: String
        public let repositoryRelativePath: String
        public let mode: String
        public let objectType: String
        public let gitBlobOID: String
        public let byteCount: UInt64
        public let sha256: String

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

    public struct ReceiptBinding:
        Codable,
        Equatable,
        Sendable
    {
        public let role: String
        public let repositoryRelativePath: String
        public let byteCount: Int
        public let sha256: String
        public let artifactKind: String
        public let outcome: String
        public let claimScope: String
        public let planSHA256: String

        private enum CodingKeys: String, CodingKey {
            case role
            case repositoryRelativePath =
                "repository_relative_path"
            case byteCount = "byte_count"
            case sha256
            case artifactKind = "artifact_kind"
            case outcome
            case claimScope = "claim_scope"
            case planSHA256 = "plan_sha256"
        }
    }

    private struct RowBinding:
        Encodable,
        Equatable
    {
        let rowID: String
        let split: String
        let semanticFamily: String
        let generatorIndex: Int
        let sourceRowSHA256: String
        let evaluationRowSHA256: String
        let mutationID: String?
        let promptOnlyInputSHA256: String
        let targetTokenIDsWithEOSSHA256: String

        private enum CodingKeys: String, CodingKey {
            case rowID = "row_id"
            case split
            case semanticFamily = "semantic_family"
            case generatorIndex = "generator_index"
            case sourceRowSHA256 =
                "source_row_sha256"
            case evaluationRowSHA256 =
                "evaluation_row_sha256"
            case mutationID = "mutation_id"
            case promptOnlyInputSHA256 =
                "prompt_only_input_sha256"
            case targetTokenIDsWithEOSSHA256 =
                "target_token_ids_with_eos_sha256"
        }
    }

    private struct FixtureIdentityPayload:
        Encodable
    {
        let companionRemoteURL: String
        let companionRevision: String
        let companionTreeOID: String
        let fixtureIdentitySerializationID: String
        let sourceBindings: [SourceBinding]
        let receiptBindings: [ReceiptBinding]
        let historicalFixtureSourceAuthorityStatus:
            String
        let fullCorpusReplayObservationSHA256:
            String
        let corpusManifestArtifactSHA256: String
        let corpusManifestInternalSHA256: String
        let selectedSplitOrder: [String]
        let selectedSplitIdentities:
            [SplitIdentity]
        let rowOrderingID: String
        let rowIDBindingSerializationID: String
        let evaluationRowBindingSerializationID:
            String
        let promptBindingSerializationID: String
        let targetBindingSerializationID: String
        let completeRowBindingSerializationID:
            String
        let exactRowCount: Int
        let orderedRowIDsSHA256: String
        let orderedEvaluationRowsSHA256:
            String
        let orderedPromptOnlyInputBindingsSHA256:
            String
        let orderedTargetTokenBindingsSHA256:
            String
        let orderedCompleteRowBindingsSHA256:
            String

        private enum CodingKeys: String, CodingKey {
            case companionRemoteURL =
                "companion_remote_url"
            case companionRevision =
                "companion_revision"
            case companionTreeOID =
                "companion_tree_oid"
            case fixtureIdentitySerializationID =
                "fixture_identity_serialization_id"
            case sourceBindings =
                "source_bindings"
            case receiptBindings =
                "receipt_bindings"
            case historicalFixtureSourceAuthorityStatus =
                "historical_fixture_source_authority_status"
            case fullCorpusReplayObservationSHA256 =
                "full_corpus_replay_observation_sha256"
            case corpusManifestArtifactSHA256 =
                "corpus_manifest_artifact_sha256"
            case corpusManifestInternalSHA256 =
                "corpus_manifest_internal_sha256"
            case selectedSplitOrder =
                "selected_split_order"
            case selectedSplitIdentities =
                "selected_split_identities"
            case rowOrderingID = "row_ordering_id"
            case rowIDBindingSerializationID =
                "row_id_binding_serialization_id"
            case evaluationRowBindingSerializationID =
                "evaluation_row_binding_serialization_id"
            case promptBindingSerializationID =
                "prompt_binding_serialization_id"
            case targetBindingSerializationID =
                "target_binding_serialization_id"
            case completeRowBindingSerializationID =
                "complete_row_binding_serialization_id"
            case exactRowCount = "exact_row_count"
            case orderedRowIDsSHA256 =
                "ordered_row_ids_sha256"
            case orderedEvaluationRowsSHA256 =
                "ordered_evaluation_rows_sha256"
            case orderedPromptOnlyInputBindingsSHA256 =
                "ordered_prompt_only_input_bindings_sha256"
            case orderedTargetTokenBindingsSHA256 =
                "ordered_target_token_bindings_sha256"
            case orderedCompleteRowBindingsSHA256 =
                "ordered_complete_row_bindings_sha256"
        }
    }

    public static let companionRevision =
        "163fc100710ece48119bc25954452d10f6a84f7f"
    public static let companionTreeOID =
        "9009daa4f8a07fbd5897e00b9571cef44ec292db"
    public static let companionRemoteURL =
        "https://github.com/Ergentics/pmhnp-companion-ergentics.git"
    public static let tokenizerSourceRelativePath =
        "prime-runtime/Sources/ErgenticsPrimeRuntime/PrimeNativeByteTokenizer.swift"
    public static let tokenizerSourceGitBlobOID =
        "27f5d4f61864499027d3e65516ae4c5cfe1ff5d1"
    public static let tokenizerSourceByteCount:
        UInt64 = 21_320
    public static let tokenizerSourceSHA256 =
        "9cee58d44cf3c80bfe53b7568753c4ad4a76d6e54f2e32e6020b795ef0973721"
    public static let corpusSourceRelativePath =
        "prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsPrimeNativeTextCorpus.swift"
    public static let corpusSourceGitBlobOID =
        "b2a087c9410a71f2bc99debade752ff779d7a8a8"
    public static let corpusSourceByteCount:
        UInt64 = 177_032
    public static let corpusSourceSHA256 =
        "4758ac2ffc8452614c7eee428333105ac63b0707cb890938d1e42966d3a14210"
    public static let historicalFixtureSourceRelativePath =
        "neural-kit/Tests/NeuralKitTests/EngineProposesNativeLanguageVerifyAbstainTests.swift"
    public static let historicalFixtureSourceGitBlobOID =
        "aa87aff21832ebd5c7a6598692139b81ae065e0b"
    public static let historicalFixtureSourceByteCount:
        UInt64 = 165_692
    public static let historicalFixtureSourceSHA256 =
        "266475d337fb49ba9c84e03a53871269a73812c3200a830a799ef90f4901968c"
    public static let historicalFixtureSourceAuthorityStatus =
        "lineage_only_not_read_or_executed_corrected_selection_is_explicit_and_recomputed_from_pinned_corpus_v1"
    public static let stageAReceiptRelativePath =
        "artifacts/native-neural-gate-contract-projection-canonical-2026-07-30/prime-native-neural-gate-contract-projection-receipt.v1.json"
    public static let stageAReceiptByteCount = 3_193
    public static let stageAReceiptSHA256 =
        "2e523c459faca835a8d0b1b43a6d6f770923d451516f4477df2f18fd4f7b2aed"
    public static let stageAReceiptArtifactKind =
        "ergentics_prime_native_neural_gate_contract_projection_receipt"
    public static let stageAReceiptClaimScope =
        "source_pinned_neuralkit_native_language_gate_contract_projection_only"
    public static let stageAReceiptPlanSHA256 =
        "f4ab6e17319603d29d2410c597ba52a5bf5ebde4944c82021216098ed0781cf1"
    public static let fullCorpusReplayReceiptRelativePath =
        "artifacts/native-full-corpus-replay-canonical-2026-07-30/prime-native-full-corpus-replay-receipt.v1.json"
    public static let fullCorpusReplayReceiptByteCount =
        2_965
    public static let fullCorpusReplayReceiptSHA256 =
        "88d243827c1aff0ce8125402f84c4ffe4012d058dedaf88f614099e975dafdc2"
    public static let fullCorpusReplayReceiptArtifactKind =
        "ergentics_prime_native_full_corpus_replay_receipt"
    public static let fullCorpusReplayReceiptClaimScope =
        "source_pinned_full_swift_corpus_generator_transplant_replay_only"
    public static let fullCorpusReplayReceiptPlanSHA256 =
        "5e3b7a70fda678b0d666b15e052ca15a9bac064db9a28460d5f5c430a103ffba"
    public static let fullCorpusReplayObservationSHA256 =
        "520b9669d61d414463cccde512d39f9d631fae1ef6f44062aaf940e72f35fcb1"
    public static let corpusManifestArtifactSHA256 =
        "fbb7362ee63b5825d1914815e8ff93c26a2c9a7de8be19347ccec3e449de8031"
    public static let corpusManifestInternalSHA256 =
        "7f42e6f0504e3751fca24bcce35f17fa361b4efcbd577f679fff7577f3e98ba7"
    public static let selectedSplitOrder = [
        "validation",
        "combination_holdout",
        "ood",
        "mutation",
        "abstention",
    ]
    public static let rowOrderingID =
        "global_row_id_utf8_lexicographic_ascending_v1"
    public static let fixtureIdentitySerializationID =
        "sorted_key_json_complete_source_receipt_split_and_nested_binding_identity_payload_v2"
    public static let exactRowCount = 18_432
    public static let rowIDBindingSerializationID =
        "sorted_key_json_array_of_row_id_utf8_strings_in_global_row_id_utf8_lexicographic_order_v1"
    public static let evaluationRowBindingSerializationID =
        "sorted_key_json_array_of_lowercase_hex_source_evaluation_row_sha256_values_in_global_row_id_utf8_lexicographic_order_v1"
    public static let promptBindingSerializationID =
        "sorted_key_json_array_of_lowercase_hex_sha256_of_PRIMECPI2_domain_uint64be_count_then_uint16be_prompt_token_ids_in_global_row_id_utf8_lexicographic_order_v1"
    public static let targetBindingSerializationID =
        "sorted_key_json_array_of_lowercase_hex_sha256_of_PRIMECFT1_domain_then_uint16be_target_token_ids_then_eos_in_global_row_id_utf8_lexicographic_order_v1"
    public static let completeRowBindingSerializationID =
        "sorted_key_json_array_of_complete_source_row_outer_correlation_regrade_prompt_and_target_binding_records_in_global_row_id_utf8_lexicographic_order_v2"
    public static let frozenOrderedRowIDsSHA256 =
        "10f9c9ef4e60ceead116dd434823de9319544da2784b1958503a8c874915701e"
    public static let frozenOrderedEvaluationRowsSHA256 =
        "f9b192173a6880e0efbb6a9631e6b1d0532f7e3b25f016fe31f001a4c5ecc063"
    public static let
        frozenOrderedPromptOnlyInputBindingsSHA256 =
        "cc24455111a54a7f7b75806c24d9891e15ad543f403ea5354e68487e4f25dd7f"
    public static let frozenOrderedTargetTokenBindingsSHA256 =
        "0f55a644281ed11cbe73eb09c285234227e2f741c576cbc00a23747c2a22a370"
    public static let frozenOrderedCompleteRowBindingsSHA256 =
        "4c4917bd54e625fd8c1441eb19129c2be0cb7ad9762e16607e9212d8faac27b4"
    public static let frozenFixtureIdentitySHA256 =
        "c1f29a0d1067a4bce5541ee5100044276ccc16c63e57501b509fb3126fcd29a4"
    public static let frozenObservationSHA256 =
        "a30c7fe39157ce6e0de2e0783a8af8807c4a1b02b309a144ba3272a6cc6d931d"
    public static let frozenFirstRowID =
        "abstention-000000-arithmetic_composition"
    public static let frozenLastRowID =
        "validation-004095-sequence_ordering"
    public static let frozenMaximumPromptTokenCount =
        500
    public static let frozenMaximumCompletionTokenCount =
        17

    public let schemaVersion: Int
    public let artifactKind: String
    public let authorityStatus: String
    public let companionRemoteURL: String
    public let companionRevision: String
    public let companionTreeOID: String
    public let tokenizerSourceGitBlobOID: String
    public let tokenizerSourceSHA256: String
    public let corpusSourceGitBlobOID: String
    public let corpusSourceSHA256: String
    public let historicalFixtureSourceGitBlobOID:
        String
    public let historicalFixtureSourceSHA256:
        String
    public let stageAReceiptRelativePath: String
    public let stageAReceiptByteCount: Int
    public let stageAReceiptSHA256: String
    public let fullCorpusReplayReceiptRelativePath:
        String
    public let fullCorpusReplayReceiptByteCount:
        Int
    public let fullCorpusReplayReceiptSHA256:
        String
    public let fullCorpusReplayObservationSHA256:
        String
    public let corpusManifestArtifactSHA256:
        String
    public let corpusManifestInternalSHA256:
        String
    public let fixtureIdentitySerializationID:
        String
    public let sourceBindings: [SourceBinding]
    public let receiptBindings: [ReceiptBinding]
    public let historicalFixtureSourceAuthorityStatus:
        String
    public let selectedSplitOrder: [String]
    public let rowOrderingID: String
    public let rowIDBindingSerializationID: String
    public let evaluationRowBindingSerializationID:
        String
    public let promptBindingSerializationID: String
    public let targetBindingSerializationID: String
    public let completeRowBindingSerializationID:
        String
    public let selectedSplitIdentities:
        [SplitIdentity]
    public let exactRowCount: Int
    public let uniqueRowIDCount: Int
    public let uniquePromptOnlyInputCount: Int
    public let firstRowID: String
    public let lastRowID: String
    public let maximumPromptTokenCount: Int
    public let maximumCompletionTokenCount: Int
    public let maximumCompletionDecisionsIncludingEOS:
        Int
    public let allPromptsCanonicalNFC: Bool
    public let allCompletionsCanonicalNFC: Bool
    public let allCompletionsFitFixedCapWithEOS:
        Bool
    public let orderedRowIDsSHA256: String
    public let orderedEvaluationRowsSHA256:
        String
    public let orderedPromptOnlyInputBindingsSHA256:
        String
    public let orderedTargetTokenBindingsSHA256:
        String
    public let orderedCompleteRowBindingsSHA256:
        String
    public let fixtureIdentitySHA256: String
    public let sourceDerivedFixtureIdentityBound:
        Bool
    public let independentFixtureProbeVerifierReceiptPublished:
        Bool
    public let receiptBytesReadDuringDerivation:
        Bool
    public let promptOnlySolverSourceDerivationBound:
        Bool
    public let modelExecutionPerformed: Bool
    public let stageBExecutionAuthorized: Bool
    public let terminalReceiptAuthorized: Bool
    public let authorityStatement: String

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case artifactKind = "artifact_kind"
        case authorityStatus = "authority_status"
        case companionRemoteURL =
            "companion_remote_url"
        case companionRevision =
            "companion_revision"
        case companionTreeOID =
            "companion_tree_oid"
        case tokenizerSourceGitBlobOID =
            "tokenizer_source_git_blob_oid"
        case tokenizerSourceSHA256 =
            "tokenizer_source_sha256"
        case corpusSourceGitBlobOID =
            "corpus_source_git_blob_oid"
        case corpusSourceSHA256 =
            "corpus_source_sha256"
        case historicalFixtureSourceGitBlobOID =
            "historical_fixture_source_git_blob_oid"
        case historicalFixtureSourceSHA256 =
            "historical_fixture_source_sha256"
        case stageAReceiptRelativePath =
            "stage_a_receipt_relative_path"
        case stageAReceiptByteCount =
            "stage_a_receipt_byte_count"
        case stageAReceiptSHA256 =
            "stage_a_receipt_sha256"
        case fullCorpusReplayReceiptRelativePath =
            "full_corpus_replay_receipt_relative_path"
        case fullCorpusReplayReceiptByteCount =
            "full_corpus_replay_receipt_byte_count"
        case fullCorpusReplayReceiptSHA256 =
            "full_corpus_replay_receipt_sha256"
        case fullCorpusReplayObservationSHA256 =
            "full_corpus_replay_observation_sha256"
        case corpusManifestArtifactSHA256 =
            "corpus_manifest_artifact_sha256"
        case corpusManifestInternalSHA256 =
            "corpus_manifest_internal_sha256"
        case fixtureIdentitySerializationID =
            "fixture_identity_serialization_id"
        case sourceBindings = "source_bindings"
        case receiptBindings = "receipt_bindings"
        case historicalFixtureSourceAuthorityStatus =
            "historical_fixture_source_authority_status"
        case selectedSplitOrder =
            "selected_split_order"
        case rowOrderingID = "row_ordering_id"
        case rowIDBindingSerializationID =
            "row_id_binding_serialization_id"
        case evaluationRowBindingSerializationID =
            "evaluation_row_binding_serialization_id"
        case promptBindingSerializationID =
            "prompt_binding_serialization_id"
        case targetBindingSerializationID =
            "target_binding_serialization_id"
        case completeRowBindingSerializationID =
            "complete_row_binding_serialization_id"
        case selectedSplitIdentities =
            "selected_split_identities"
        case exactRowCount = "exact_row_count"
        case uniqueRowIDCount =
            "unique_row_id_count"
        case uniquePromptOnlyInputCount =
            "unique_prompt_only_input_count"
        case firstRowID = "first_row_id"
        case lastRowID = "last_row_id"
        case maximumPromptTokenCount =
            "maximum_prompt_token_count"
        case maximumCompletionTokenCount =
            "maximum_completion_token_count"
        case maximumCompletionDecisionsIncludingEOS =
            "maximum_completion_decisions_including_eos"
        case allPromptsCanonicalNFC =
            "all_prompts_canonical_nfc"
        case allCompletionsCanonicalNFC =
            "all_completions_canonical_nfc"
        case allCompletionsFitFixedCapWithEOS =
            "all_completions_fit_fixed_cap_with_eos"
        case orderedRowIDsSHA256 =
            "ordered_row_ids_sha256"
        case orderedEvaluationRowsSHA256 =
            "ordered_evaluation_rows_sha256"
        case orderedPromptOnlyInputBindingsSHA256 =
            "ordered_prompt_only_input_bindings_sha256"
        case orderedTargetTokenBindingsSHA256 =
            "ordered_target_token_bindings_sha256"
        case orderedCompleteRowBindingsSHA256 =
            "ordered_complete_row_bindings_sha256"
        case fixtureIdentitySHA256 =
            "fixture_identity_sha256"
        case sourceDerivedFixtureIdentityBound =
            "source_derived_fixture_identity_bound"
        case independentFixtureProbeVerifierReceiptPublished =
            "independent_fixture_probe_verifier_receipt_published"
        case receiptBytesReadDuringDerivation =
            "receipt_bytes_read_during_derivation"
        case promptOnlySolverSourceDerivationBound =
            "prompt_only_solver_source_derivation_bound"
        case modelExecutionPerformed =
            "model_execution_performed"
        case stageBExecutionAuthorized =
            "stage_b_execution_authorized"
        case terminalReceiptAuthorized =
            "terminal_receipt_authorized"
        case authorityStatement =
            "authority_statement"
    }
}

extension PrimeNativeNeuralGateCorrectedFixtureObservation {
    private typealias Corpus =
        ErgenticsPrimeNativeTextCorpus
    private typealias Row =
        ErgenticsPrimeNativeTextCorpus.Row

    public static func derive() throws -> Self {
        guard PrimeNativeNeuralGateCorrectedExecutionPolicy
                .beginningOfSequenceTokenID
                == PrimeNativeByteTokenizer
                .beginningOfSequenceTokenID,
              PrimeNativeNeuralGateCorrectedExecutionPolicy
                .endOfSequenceTokenID
                == PrimeNativeByteTokenizer
                .endOfSequenceTokenID,
              PrimeNativeNeuralGateCorrectedExecutionPolicy
                .byteTokenBase
                == PrimeNativeByteTokenizer
                .byteTokenBase,
              PrimeNativeNeuralGateCorrectedExecutionPolicy
                .byteTokenRange
                == PrimeNativeByteTokenizer
                .byteTokenRange
        else {
            throw PrimeNativeNeuralGateCorrectedFixtureObservationError
                .tokenizerContractDrift
        }
        let sourceBindings = frozenSourceBindings
        let receiptBindings = frozenReceiptBindings
        guard sourceBindings.count == 3,
              Set(sourceBindings.map(\.role)).count
                == sourceBindings.count,
              sourceBindings.allSatisfy({
                  !$0.repositoryRelativePath.isEmpty
                      && $0.mode == "100644"
                      && $0.objectType == "blob"
                      && $0.gitBlobOID.count == 40
                      && $0.byteCount > 0
                      && $0.sha256.count == 64
              })
        else {
            throw PrimeNativeNeuralGateCorrectedFixtureObservationError
                .invalidSourceBinding
        }
        guard receiptBindings.count == 2,
              Set(receiptBindings.map(\.role)).count
                == receiptBindings.count,
              receiptBindings.allSatisfy({
                  $0.repositoryRelativePath
                      .hasPrefix("artifacts/")
                      && $0.byteCount > 0
                      && $0.sha256.count == 64
                      && !$0.artifactKind.isEmpty
                      && $0.outcome == "PASS"
                      && !$0.claimScope.isEmpty
                      && $0.planSHA256.count == 64
              })
        else {
            throw PrimeNativeNeuralGateCorrectedFixtureObservationError
                .invalidReceiptBinding
        }
        let splitMap: [String: Corpus.Split] = [
            "validation": .validation,
            "combination_holdout": .combinationHoldout,
            "ood": .ood,
            "mutation": .mutation,
            "abstention": .abstention,
        ]
        guard selectedSplitOrder.compactMap({
            splitMap[$0]
        }).map(\.rawValue) == selectedSplitOrder
        else {
            throw PrimeNativeNeuralGateCorrectedFixtureObservationError
                .splitOrderDrift
        }

        var splitRows: [String: [Row]] = [:]
        var splitIdentities: [SplitIdentity] = []
        for splitName in selectedSplitOrder {
            guard let split = splitMap[splitName],
                  let expected =
                    expectedSplitRowCounts[splitName],
                  let expectedEvaluationSHA256 =
                    expectedSplitOrderedEvaluationSHA256[
                        splitName
                    ]
            else {
                throw PrimeNativeNeuralGateCorrectedFixtureObservationError
                    .splitOrderDrift
            }
            let rows = Corpus.rows(for: split)
                .sorted(by: rowIDUTF8Precedes)
            guard rows.count == expected else {
                throw PrimeNativeNeuralGateCorrectedFixtureObservationError
                    .splitCountDrift(
                        split: splitName,
                        expected: expected,
                        actual: rows.count
                    )
            }
            guard let first = rows.first,
                  let last = rows.last else {
                throw PrimeNativeNeuralGateCorrectedFixtureObservationError
                    .splitCountDrift(
                        split: splitName,
                        expected: expected,
                        actual: rows.count
                    )
            }
            let orderedEvaluationRowsSHA256 =
                try canonicalSHA256(
                    rows.map(\.evaluationRowSHA256)
                )
            guard orderedEvaluationRowsSHA256
                    == expectedEvaluationSHA256
            else {
                throw PrimeNativeNeuralGateCorrectedFixtureObservationError
                    .invalidSourceRow(splitName)
            }
            splitRows[splitName] = rows
            splitIdentities.append(
                SplitIdentity(
                    split: splitName,
                    rowCount: rows.count,
                    orderedEvaluationRowsSHA256:
                        orderedEvaluationRowsSHA256,
                    firstRowID: first.rowID,
                    lastRowID: last.rowID
                )
            )
        }

        var selectedRows: [Row] = []
        for splitName in selectedSplitOrder {
            guard let rows = splitRows[splitName]
            else {
                throw PrimeNativeNeuralGateCorrectedFixtureObservationError
                    .splitOrderDrift
            }
            selectedRows.append(contentsOf: rows)
        }
        let rows = selectedRows.sorted(
            by: rowIDUTF8Precedes
        )
        guard rows.count == exactRowCount else {
            throw PrimeNativeNeuralGateCorrectedFixtureObservationError
                .rowCountDrift(
                    expected: exactRowCount,
                    actual: rows.count
                )
        }
        guard Set(
            rows.map {
                Data($0.rowID.utf8)
            }
        ).count == rows.count,
              zip(rows, rows.dropFirst())
                .allSatisfy({ pair in
                    rowIDUTF8Precedes(
                        pair.0,
                        pair.1
                    )
                }),
              let firstRow = rows.first,
              let lastRow = rows.last
        else {
            throw PrimeNativeNeuralGateCorrectedFixtureObservationError
                .duplicateRowIdentity
        }

        var promptBindings: [String] = []
        var targetBindings: [String] = []
        var rowBindings: [RowBinding] = []
        var maximumPromptTokenCount = 0
        var maximumCompletionTokenCount = 0
        var allPromptsCanonical = true
        var allCompletionsCanonical = true

        for row in rows {
            guard Corpus.verify(row: row).accepted,
                  row.evaluationRowSHA256
                    == Corpus.evaluationRowSHA256(row)
            else {
                throw PrimeNativeNeuralGateCorrectedFixtureObservationError
                    .invalidSourceRow(row.rowID)
            }
            let prompt =
                try PrimeNativeNeuralGatePromptOnlyExecutionInput
                    .derive(promptText: row.promptText)
            let donorPromptTokenIDs =
                [
                    PrimeNativeByteTokenizer
                        .beginningOfSequenceTokenID,
                ]
                + PrimeNativeByteTokenizer.encode(
                    row.promptText
                )
            guard prompt.promptTokenIDs
                    == donorPromptTokenIDs,
                  try prompt.decodedCanonicalPrompt()
                    == row.promptText
            else {
                throw PrimeNativeNeuralGateCorrectedFixtureObservationError
                    .promptBindingDrift(row.rowID)
            }
            let promptSHA = prompt.bindingSHA256
            let targetTokenIDs =
                PrimeNativeByteTokenizer.encode(
                    row.expectedCompletion
                )
            guard try PrimeNativeByteTokenizer.decode(
                targetTokenIDs
            ) == row.expectedCompletion
            else {
                throw PrimeNativeNeuralGateCorrectedFixtureObservationError
                    .tokenizerContractDrift
            }
            let targetSHA =
                try targetTokenBindingSHA256(
                    tokenIDs: targetTokenIDs
                )
            promptBindings.append(promptSHA)
            targetBindings.append(targetSHA)
            rowBindings.append(
                RowBinding(
                    rowID: row.rowID,
                    split: row.split,
                    semanticFamily:
                        row.semanticFamily,
                    generatorIndex:
                        row.generatorIndex,
                    sourceRowSHA256:
                        row.rowSHA256,
                    evaluationRowSHA256:
                        row.evaluationRowSHA256,
                    mutationID:
                        row.mutationID,
                    promptOnlyInputSHA256:
                        promptSHA,
                    targetTokenIDsWithEOSSHA256:
                        targetSHA
                )
            )
            maximumPromptTokenCount = max(
                maximumPromptTokenCount,
                prompt.promptTokenIDs.count
            )
            maximumCompletionTokenCount = max(
                maximumCompletionTokenCount,
                targetTokenIDs.count
            )
            allPromptsCanonical =
                allPromptsCanonical
                && row.promptText
                    == row.promptText
                    .precomposedStringWithCanonicalMapping
            allCompletionsCanonical =
                allCompletionsCanonical
                && row.expectedCompletion
                    == row.expectedCompletion
                    .precomposedStringWithCanonicalMapping
        }
        guard Set(promptBindings).count
                == promptBindings.count
        else {
            throw PrimeNativeNeuralGateCorrectedFixtureObservationError
                .duplicatePromptIdentity
        }

        let feasibility =
            try PrimeNativeNeuralGateCorrectedCompletionFeasibility
                .recompute(
                    expectedCompletions:
                        rows.map(\.expectedCompletion)
                )
        guard feasibility.observedCompletionCount
                == exactRowCount,
              feasibility.allValuesCanonicalNFC
                == allCompletionsCanonical,
              feasibility
                .allValuesFitFixedCapWithEOS
        else {
            throw PrimeNativeNeuralGateCorrectedFixtureObservationError
                .completionFeasibilityDrift
        }

        let orderedRowIDsSHA256 =
            try canonicalSHA256(rows.map(\.rowID))
        let orderedEvaluationRowsSHA256 =
            try canonicalSHA256(
                rows.map(\.evaluationRowSHA256)
            )
        let orderedPromptOnlyInputBindingsSHA256 =
            try canonicalSHA256(promptBindings)
        let orderedTargetTokenBindingsSHA256 =
            try canonicalSHA256(targetBindings)
        let orderedCompleteRowBindingsSHA256 =
            try canonicalSHA256(rowBindings)
        let fixtureIdentitySHA256 =
            try canonicalSHA256(
                FixtureIdentityPayload(
                    companionRemoteURL:
                        companionRemoteURL,
                    companionRevision:
                        companionRevision,
                    companionTreeOID:
                        companionTreeOID,
                    fixtureIdentitySerializationID:
                        fixtureIdentitySerializationID,
                    sourceBindings:
                        sourceBindings,
                    receiptBindings:
                        receiptBindings,
                    historicalFixtureSourceAuthorityStatus:
                        historicalFixtureSourceAuthorityStatus,
                    fullCorpusReplayObservationSHA256:
                        fullCorpusReplayObservationSHA256,
                    corpusManifestArtifactSHA256:
                        corpusManifestArtifactSHA256,
                    corpusManifestInternalSHA256:
                        corpusManifestInternalSHA256,
                    selectedSplitOrder:
                        selectedSplitOrder,
                    selectedSplitIdentities:
                        splitIdentities,
                    rowOrderingID: rowOrderingID,
                    rowIDBindingSerializationID:
                        rowIDBindingSerializationID,
                    evaluationRowBindingSerializationID:
                        evaluationRowBindingSerializationID,
                    promptBindingSerializationID:
                        promptBindingSerializationID,
                    targetBindingSerializationID:
                        targetBindingSerializationID,
                    completeRowBindingSerializationID:
                        completeRowBindingSerializationID,
                    exactRowCount: exactRowCount,
                    orderedRowIDsSHA256:
                        orderedRowIDsSHA256,
                    orderedEvaluationRowsSHA256:
                        orderedEvaluationRowsSHA256,
                    orderedPromptOnlyInputBindingsSHA256:
                        orderedPromptOnlyInputBindingsSHA256,
                    orderedTargetTokenBindingsSHA256:
                        orderedTargetTokenBindingsSHA256,
                    orderedCompleteRowBindingsSHA256:
                        orderedCompleteRowBindingsSHA256
                )
            )

        return Self(
            schemaVersion: 1,
            artifactKind:
                "prime_native_neural_gate_corrected_fixture_observation",
            authorityStatus:
                "source_derived_fixture_identity_bound_solver_and_execution_unbound",
            companionRemoteURL:
                companionRemoteURL,
            companionRevision:
                companionRevision,
            companionTreeOID:
                companionTreeOID,
            tokenizerSourceGitBlobOID:
                tokenizerSourceGitBlobOID,
            tokenizerSourceSHA256:
                tokenizerSourceSHA256,
            corpusSourceGitBlobOID:
                corpusSourceGitBlobOID,
            corpusSourceSHA256:
                corpusSourceSHA256,
            historicalFixtureSourceGitBlobOID:
                historicalFixtureSourceGitBlobOID,
            historicalFixtureSourceSHA256:
                historicalFixtureSourceSHA256,
            stageAReceiptRelativePath:
                stageAReceiptRelativePath,
            stageAReceiptByteCount:
                stageAReceiptByteCount,
            stageAReceiptSHA256:
                stageAReceiptSHA256,
            fullCorpusReplayReceiptRelativePath:
                fullCorpusReplayReceiptRelativePath,
            fullCorpusReplayReceiptByteCount:
                fullCorpusReplayReceiptByteCount,
            fullCorpusReplayReceiptSHA256:
                fullCorpusReplayReceiptSHA256,
            fullCorpusReplayObservationSHA256:
                fullCorpusReplayObservationSHA256,
            corpusManifestArtifactSHA256:
                corpusManifestArtifactSHA256,
            corpusManifestInternalSHA256:
                corpusManifestInternalSHA256,
            fixtureIdentitySerializationID:
                fixtureIdentitySerializationID,
            sourceBindings: sourceBindings,
            receiptBindings: receiptBindings,
            historicalFixtureSourceAuthorityStatus:
                historicalFixtureSourceAuthorityStatus,
            selectedSplitOrder:
                selectedSplitOrder,
            rowOrderingID: rowOrderingID,
            rowIDBindingSerializationID:
                rowIDBindingSerializationID,
            evaluationRowBindingSerializationID:
                evaluationRowBindingSerializationID,
            promptBindingSerializationID:
                promptBindingSerializationID,
            targetBindingSerializationID:
                targetBindingSerializationID,
            completeRowBindingSerializationID:
                completeRowBindingSerializationID,
            selectedSplitIdentities:
                splitIdentities,
            exactRowCount: rows.count,
            uniqueRowIDCount:
                Set(rows.map(\.rowID)).count,
            uniquePromptOnlyInputCount:
                Set(promptBindings).count,
            firstRowID: firstRow.rowID,
            lastRowID: lastRow.rowID,
            maximumPromptTokenCount:
                maximumPromptTokenCount,
            maximumCompletionTokenCount:
                maximumCompletionTokenCount,
            maximumCompletionDecisionsIncludingEOS:
                maximumCompletionTokenCount + 1,
            allPromptsCanonicalNFC:
                allPromptsCanonical,
            allCompletionsCanonicalNFC:
                allCompletionsCanonical,
            allCompletionsFitFixedCapWithEOS:
                feasibility
                    .allValuesFitFixedCapWithEOS,
            orderedRowIDsSHA256:
                orderedRowIDsSHA256,
            orderedEvaluationRowsSHA256:
                orderedEvaluationRowsSHA256,
            orderedPromptOnlyInputBindingsSHA256:
                orderedPromptOnlyInputBindingsSHA256,
            orderedTargetTokenBindingsSHA256:
                orderedTargetTokenBindingsSHA256,
            orderedCompleteRowBindingsSHA256:
                orderedCompleteRowBindingsSHA256,
            fixtureIdentitySHA256:
                fixtureIdentitySHA256,
            sourceDerivedFixtureIdentityBound:
                true,
            independentFixtureProbeVerifierReceiptPublished:
                false,
            receiptBytesReadDuringDerivation:
                false,
            promptOnlySolverSourceDerivationBound:
                false,
            modelExecutionPerformed: false,
            stageBExecutionAuthorized: false,
            terminalReceiptAuthorized: false,
            authorityStatement:
                "This offline Swift source-plan observation recomputes the exact 18,432-row corrected evaluation fixture from Prime's byte-exact, source-pinned corpus transplant and binds complete source-row and outer-regrade identity separately from canonical prompt-only and domain-separated target-feasibility values. The historical fixture source is lineage-only and is neither read nor executed here. Closed Stage-A and full-corpus receipt identities are bound as typed records but receipt bytes are not read during derivation; repository tests decode and validate the pinned files. No independent fixture probe/verifier receipt is published. This observation does not bind a solver, logits, model execution, Stage-B process, independent scientific oracle, or product authority."
        )
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

    public static func runAndValidate() throws -> Self {
        let observation = try derive()
        try observation.validateFrozen()
        return observation
    }

    public func validateFrozen() throws {
        guard schemaVersion == 1,
              artifactKind
                == "prime_native_neural_gate_corrected_fixture_observation",
              authorityStatus
                == "source_derived_fixture_identity_bound_solver_and_execution_unbound",
              companionRemoteURL
                == Self.companionRemoteURL,
              companionRevision
                == Self.companionRevision,
              companionTreeOID
                == Self.companionTreeOID,
              tokenizerSourceGitBlobOID
                == Self.tokenizerSourceGitBlobOID,
              tokenizerSourceSHA256
                == Self.tokenizerSourceSHA256,
              corpusSourceGitBlobOID
                == Self.corpusSourceGitBlobOID,
              corpusSourceSHA256
                == Self.corpusSourceSHA256,
              historicalFixtureSourceGitBlobOID
                == Self.historicalFixtureSourceGitBlobOID,
              historicalFixtureSourceSHA256
                == Self.historicalFixtureSourceSHA256,
              stageAReceiptRelativePath
                == Self.stageAReceiptRelativePath,
              stageAReceiptByteCount
                == Self.stageAReceiptByteCount,
              stageAReceiptSHA256
                == Self.stageAReceiptSHA256,
              fullCorpusReplayReceiptRelativePath
                == Self.fullCorpusReplayReceiptRelativePath,
              fullCorpusReplayReceiptByteCount
                == Self.fullCorpusReplayReceiptByteCount,
              fullCorpusReplayReceiptSHA256
                == Self.fullCorpusReplayReceiptSHA256,
              fullCorpusReplayObservationSHA256
                == Self.fullCorpusReplayObservationSHA256,
              corpusManifestArtifactSHA256
                == Self.corpusManifestArtifactSHA256,
              corpusManifestInternalSHA256
                == Self.corpusManifestInternalSHA256,
              fixtureIdentitySerializationID
                == Self.fixtureIdentitySerializationID,
              sourceBindings
                == Self.frozenSourceBindings,
              receiptBindings
                == Self.frozenReceiptBindings,
              historicalFixtureSourceAuthorityStatus
                == Self
                .historicalFixtureSourceAuthorityStatus,
              selectedSplitOrder
                == Self.selectedSplitOrder,
              rowOrderingID == Self.rowOrderingID,
              rowIDBindingSerializationID
                == Self.rowIDBindingSerializationID,
              evaluationRowBindingSerializationID
                == Self
                .evaluationRowBindingSerializationID,
              promptBindingSerializationID
                == Self.promptBindingSerializationID,
              targetBindingSerializationID
                == Self.targetBindingSerializationID,
              completeRowBindingSerializationID
                == Self.completeRowBindingSerializationID,
              exactRowCount == Self.exactRowCount,
              uniqueRowIDCount == exactRowCount,
              uniquePromptOnlyInputCount
                == exactRowCount,
              firstRowID == Self.frozenFirstRowID,
              lastRowID == Self.frozenLastRowID,
              maximumPromptTokenCount
                == Self.frozenMaximumPromptTokenCount,
              maximumCompletionTokenCount
                == Self.frozenMaximumCompletionTokenCount,
              maximumCompletionDecisionsIncludingEOS
                == Self.frozenMaximumCompletionTokenCount + 1,
              allPromptsCanonicalNFC,
              allCompletionsCanonicalNFC,
              allCompletionsFitFixedCapWithEOS,
              orderedRowIDsSHA256
                == Self.frozenOrderedRowIDsSHA256,
              orderedEvaluationRowsSHA256
                == Self.frozenOrderedEvaluationRowsSHA256,
              orderedPromptOnlyInputBindingsSHA256
                == Self.frozenOrderedPromptOnlyInputBindingsSHA256,
              orderedTargetTokenBindingsSHA256
                == Self.frozenOrderedTargetTokenBindingsSHA256,
              orderedCompleteRowBindingsSHA256
                == Self.frozenOrderedCompleteRowBindingsSHA256,
              fixtureIdentitySHA256
                == Self.frozenFixtureIdentitySHA256,
              sourceDerivedFixtureIdentityBound,
              !independentFixtureProbeVerifierReceiptPublished,
              !receiptBytesReadDuringDerivation,
              !promptOnlySolverSourceDerivationBound,
              !modelExecutionPerformed,
              !stageBExecutionAuthorized,
              !terminalReceiptAuthorized,
              try contentSHA256()
                == Self.frozenObservationSHA256
        else {
            throw PrimeNativeNeuralGateCorrectedFixtureObservationError
                .frozenGoldenDrift
        }
    }

    private static let expectedSplitRowCounts = [
        "validation": 4_096,
        "combination_holdout": 4_096,
        "ood": 4_096,
        "mutation": 4_096,
        "abstention": 2_048,
    ]

    private static let
        expectedSplitOrderedEvaluationSHA256 = [
        "validation":
            "8d1da3aa5923078f95cf4389364dba9e7554fd69afbf8807ffdb13f429a11f6b",
        "combination_holdout":
            "f1cfbeccf8daacbee95689fb46ee00395cada3d6dee3eafe6e838fca69dd4d4a",
        "ood":
            "82f5c29dc6cb50c23a661838adf45157840aef0cdefae6a1eb82f56862c100db",
        "mutation":
            "f2a043157e70725f91d9d1126f22ec2dbfc011c32650e778e41054b4b7e290b5",
        "abstention":
            "17e999ba61f0380e6ae1f91b944b75f48537d36d425e916372d18aeb4f24b684",
    ]

    private static let frozenSourceBindings = [
        SourceBinding(
            role: "native_byte_tokenizer_authority",
            repositoryRelativePath:
                tokenizerSourceRelativePath,
            mode: "100644",
            objectType: "blob",
            gitBlobOID: tokenizerSourceGitBlobOID,
            byteCount: tokenizerSourceByteCount,
            sha256: tokenizerSourceSHA256
        ),
        SourceBinding(
            role: "native_text_corpus_authority",
            repositoryRelativePath:
                corpusSourceRelativePath,
            mode: "100644",
            objectType: "blob",
            gitBlobOID: corpusSourceGitBlobOID,
            byteCount: corpusSourceByteCount,
            sha256: corpusSourceSHA256
        ),
        SourceBinding(
            role: "behavioral_regression_fixture_lineage_only",
            repositoryRelativePath:
                historicalFixtureSourceRelativePath,
            mode: "100644",
            objectType: "blob",
            gitBlobOID:
                historicalFixtureSourceGitBlobOID,
            byteCount:
                historicalFixtureSourceByteCount,
            sha256:
                historicalFixtureSourceSHA256
        ),
    ]

    private static let frozenReceiptBindings = [
        ReceiptBinding(
            role: "stage_a_contract_projection_parent",
            repositoryRelativePath:
                stageAReceiptRelativePath,
            byteCount: stageAReceiptByteCount,
            sha256: stageAReceiptSHA256,
            artifactKind:
                stageAReceiptArtifactKind,
            outcome: "PASS",
            claimScope:
                stageAReceiptClaimScope,
            planSHA256:
                stageAReceiptPlanSHA256
        ),
        ReceiptBinding(
            role: "full_corpus_replay_parent",
            repositoryRelativePath:
                fullCorpusReplayReceiptRelativePath,
            byteCount:
                fullCorpusReplayReceiptByteCount,
            sha256:
                fullCorpusReplayReceiptSHA256,
            artifactKind:
                fullCorpusReplayReceiptArtifactKind,
            outcome: "PASS",
            claimScope:
                fullCorpusReplayReceiptClaimScope,
            planSHA256:
                fullCorpusReplayReceiptPlanSHA256
        ),
    ]

    private static func rowIDUTF8Precedes(
        _ lhs: Row,
        _ rhs: Row
    ) -> Bool {
        lhs.rowID.utf8.lexicographicallyPrecedes(
            rhs.rowID.utf8
        )
    }

    private static func canonicalSHA256<
        Value: Encodable
    >(
        _ value: Value
    ) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [
            .sortedKeys,
            .withoutEscapingSlashes,
        ]
        do {
            return Corpus.sha256(
                try encoder.encode(value)
            )
        } catch {
            throw PrimeNativeNeuralGateCorrectedFixtureObservationError
                .canonicalEncodingFailure
        }
    }

    static func targetTokenBindingData(
        tokenIDs: [Int]
    ) throws -> Data {
        var data = Data("PRIMECFT1".utf8)
        for tokenID in tokenIDs
            + [
                PrimeNativeByteTokenizer
                    .endOfSequenceTokenID,
            ]
        {
            guard let exact = UInt16(
                exactly: tokenID
            ) else {
                throw PrimeNativeNeuralGateCorrectedFixtureObservationError
                    .invalidTokenID(tokenID)
            }
            appendUInt16(exact, to: &data)
        }
        return data
    }

    static func targetTokenBindingSHA256(
        tokenIDs: [Int]
    ) throws -> String {
        Corpus.sha256(
            try targetTokenBindingData(
                tokenIDs: tokenIDs
            )
        )
    }

    private static func appendUInt16(
        _ value: UInt16,
        to data: inout Data
    ) {
        var bigEndian = value.bigEndian
        withUnsafeBytes(of: &bigEndian) {
            data.append(contentsOf: $0)
        }
    }
}
