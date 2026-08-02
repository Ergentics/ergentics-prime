// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
import PrimeNativeNeuralGateReplayArtifactContracts

public enum PrimeNativeNeuralGateHistoricalStatisticsArtifactError:
    Error,
    Equatable,
    Sendable
{
    case emptyArtifact
    case artifactTooLarge(
        actualByteCount: Int,
        maximumByteCount: Int
    )
    case invalidJSON
    case invalidEnvelope(String)
    case canonicalEncodingFailed
    case nonCanonicalJSON
}

/// A pure, typed wire contract for the frozen V16 historical statistics
/// artifact. This carrier confers no scientific, product, mechanics-pass, or
/// terminal-receipt authority.
public struct PrimeNativeNeuralGateHistoricalStatisticsArtifactEnvelope:
    Encodable,
    Equatable,
    Sendable
{
    public struct NamedDoubleBitPattern:
        Codable,
        Equatable,
        Sendable
    {
        public let name: String
        public let bitPattern: UInt64

        private enum CodingKeys: String, CodingKey {
            case name
            case bitPattern = "bit_pattern"
        }
    }

    public struct HeldoutLossRow:
        Codable,
        Equatable,
        Sendable
    {
        public let rowID: String
        public let rowSHA256: String
        public let selectionSplitID: String
        public let targetClass: String
        public let semanticFamily: String
        public let targetTokenCount: Int
        public let nonPaddingTokenCount: Int
        public let crossEntropyBeforeBitPattern: UInt64
        public let crossEntropyAfterBitPattern: UInt64

        private enum CodingKeys: String, CodingKey {
            case rowID = "row_id"
            case rowSHA256 = "row_sha256"
            case selectionSplitID = "selection_split_id"
            case targetClass = "target_class"
            case semanticFamily = "semantic_family"
            case targetTokenCount = "target_token_count"
            case nonPaddingTokenCount = "non_padding_token_count"
            case crossEntropyBeforeBitPattern =
                "cross_entropy_before_bit_pattern"
            case crossEntropyAfterBitPattern =
                "cross_entropy_after_bit_pattern"
        }
    }

    public struct HeldoutSeedStatistics:
        Codable,
        Equatable,
        Sendable
    {
        public let seed: Int
        public let heldoutRowCount: Int
        public let heldoutValidRowCount: Int
        public let heldoutRefusalRowCount: Int
        public let heldoutTargetTokenCount: Int
        public let heldoutValidTargetTokenCount: Int
        public let heldoutRefusalTargetTokenCount: Int
        public let heldoutEvaluationNonPaddingTokenCount: Int
        public let heldoutCrossEntropyBeforeBitPattern: UInt64
        public let heldoutCrossEntropyAfterBitPattern: UInt64
        public let heldoutValidCrossEntropyBeforeBitPattern: UInt64
        public let heldoutValidCrossEntropyAfterBitPattern: UInt64
        public let heldoutRefusalCrossEntropyBeforeBitPattern: UInt64
        public let heldoutRefusalCrossEntropyAfterBitPattern: UInt64
        public let heldoutCrossEntropyStandardErrorBitPattern: UInt64
        public let heldoutCrossEntropyStandardErrorMethodID: String
        public let heldoutFamilyCrossEntropyBefore:
            [NamedDoubleBitPattern]
        public let heldoutFamilyCrossEntropyAfter:
            [NamedDoubleBitPattern]
        public let initialLossBitPattern: UInt64
        public let finalLossBitPattern: UInt64
        public let heldoutLossRows: [HeldoutLossRow]

        private enum CodingKeys: String, CodingKey {
            case seed
            case heldoutRowCount = "heldout_row_count"
            case heldoutValidRowCount = "heldout_valid_row_count"
            case heldoutRefusalRowCount = "heldout_refusal_row_count"
            case heldoutTargetTokenCount = "heldout_target_token_count"
            case heldoutValidTargetTokenCount =
                "heldout_valid_target_token_count"
            case heldoutRefusalTargetTokenCount =
                "heldout_refusal_target_token_count"
            case heldoutEvaluationNonPaddingTokenCount =
                "heldout_evaluation_non_padding_token_count"
            case heldoutCrossEntropyBeforeBitPattern =
                "heldout_cross_entropy_before_bit_pattern"
            case heldoutCrossEntropyAfterBitPattern =
                "heldout_cross_entropy_after_bit_pattern"
            case heldoutValidCrossEntropyBeforeBitPattern =
                "heldout_valid_cross_entropy_before_bit_pattern"
            case heldoutValidCrossEntropyAfterBitPattern =
                "heldout_valid_cross_entropy_after_bit_pattern"
            case heldoutRefusalCrossEntropyBeforeBitPattern =
                "heldout_refusal_cross_entropy_before_bit_pattern"
            case heldoutRefusalCrossEntropyAfterBitPattern =
                "heldout_refusal_cross_entropy_after_bit_pattern"
            case heldoutCrossEntropyStandardErrorBitPattern =
                "heldout_cross_entropy_standard_error_bit_pattern"
            case heldoutCrossEntropyStandardErrorMethodID =
                "heldout_cross_entropy_standard_error_method_id"
            case heldoutFamilyCrossEntropyBefore =
                "heldout_family_cross_entropy_before"
            case heldoutFamilyCrossEntropyAfter =
                "heldout_family_cross_entropy_after"
            case initialLossBitPattern = "initial_loss_bit_pattern"
            case finalLossBitPattern = "final_loss_bit_pattern"
            case heldoutLossRows = "heldout_loss_rows"
        }
    }

    public struct FixedPromptSeedReplay:
        Codable,
        Equatable,
        Sendable
    {
        public let seed: Int
        public let firstLogitFloatBitPatterns: [UInt32]
        public let replayLogitFloatBitPatterns: [UInt32]
        public let maximumLogitDeltaBitPattern: UInt64
        public let firstGreedyTokenID: Int
        public let replayGreedyTokenID: Int
        public let firstGreedyRunnerUpMarginBitPattern: UInt64
        public let replayGreedyRunnerUpMarginBitPattern: UInt64
        public let greedyTokenExact: Bool
        public let behavioralReplayExact: Bool
        public let firstResultSHA256: String
        public let replayResultSHA256: String
        public let resultExact: Bool

        private enum CodingKeys: String, CodingKey {
            case seed
            case firstLogitFloatBitPatterns =
                "first_logit_float_bit_patterns"
            case replayLogitFloatBitPatterns =
                "replay_logit_float_bit_patterns"
            case maximumLogitDeltaBitPattern =
                "maximum_logit_delta_bit_pattern"
            case firstGreedyTokenID = "first_greedy_token_id"
            case replayGreedyTokenID = "replay_greedy_token_id"
            case firstGreedyRunnerUpMarginBitPattern =
                "first_greedy_runner_up_margin_bit_pattern"
            case replayGreedyRunnerUpMarginBitPattern =
                "replay_greedy_runner_up_margin_bit_pattern"
            case greedyTokenExact = "greedy_token_exact"
            case behavioralReplayExact = "behavioral_replay_exact"
            case firstResultSHA256 = "first_result_sha256"
            case replayResultSHA256 = "replay_result_sha256"
            case resultExact = "result_exact"
        }
    }

    public struct CapabilitySplit:
        Codable,
        Equatable,
        Sendable
    {
        public let splitID: String
        public let rowCount: Int
        public let zeroShotExactAccuracyBitPattern: UInt64
        public let trainedExactAccuracyBitPattern: UInt64
        public let trainedMeanLogProbabilityBitPattern: UInt64

        private enum CodingKeys: String, CodingKey {
            case splitID = "split_id"
            case rowCount = "row_count"
            case zeroShotExactAccuracyBitPattern =
                "zero_shot_exact_accuracy_bit_pattern"
            case trainedExactAccuracyBitPattern =
                "trained_exact_accuracy_bit_pattern"
            case trainedMeanLogProbabilityBitPattern =
                "trained_mean_log_probability_bit_pattern"
        }
    }

    public struct AbstentionDecisionRow:
        Codable,
        Equatable,
        Sendable
    {
        public let rowID: String
        public let corpusRowSHA256: String
        public let evaluationRowSHA256: String
        public let splitID: String
        public let target: String
        public let trainedPrediction: String?
        public let trainedTerminatedByEOS: Bool
        public let trainedTerminationReason: String
        public let trainedUTF8Valid: Bool
        public let trainedExactMatch: Bool
        public let trainedSemanticVerifierPass: Bool
        public let trainedAbstentionDecision: Bool

        private enum CodingKeys: String, CodingKey {
            case rowID = "row_id"
            case corpusRowSHA256 = "corpus_row_sha256"
            case evaluationRowSHA256 = "evaluation_row_sha256"
            case splitID = "split_id"
            case target
            case trainedPrediction = "trained_prediction"
            case trainedTerminatedByEOS =
                "trained_terminated_by_eos"
            case trainedTerminationReason =
                "trained_termination_reason"
            case trainedUTF8Valid = "trained_utf8_valid"
            case trainedExactMatch = "trained_exact_match"
            case trainedSemanticVerifierPass =
                "trained_semantic_verifier_pass"
            case trainedAbstentionDecision =
                "trained_abstention_decision"
        }
    }

    public struct CapabilitySeedObservation:
        Codable,
        Equatable,
        Sendable
    {
        public let seed: Int
        public let orderedSplitValues: [CapabilitySplit]
        public let requiredAbstentionRowCount: Int
        public let orderedAbstentionDecisionRows:
            [AbstentionDecisionRow]
        public let exactAbstentionDecisionsObserved: Bool

        private enum CodingKeys: String, CodingKey {
            case seed
            case orderedSplitValues = "ordered_split_values"
            case requiredAbstentionRowCount =
                "required_abstention_row_count"
            case orderedAbstentionDecisionRows =
                "ordered_abstention_decision_rows"
            case exactAbstentionDecisionsObserved =
                "exact_abstention_decisions_observed"
        }
    }

    public struct SeedStatisticsEntry:
        Codable,
        Equatable,
        Sendable
    {
        public let seed: PrimeNativeNeuralGateArtifactSeed
        public let heldout: HeldoutSeedStatistics
        public let fixedPromptReplay: FixedPromptSeedReplay
        public let capability: CapabilitySeedObservation

        private enum CodingKeys: String, CodingKey {
            case seed
            case heldout
            case fixedPromptReplay = "fixed_prompt_replay"
            case capability
        }
    }

    public struct NamedBoolean:
        Codable,
        Equatable,
        Sendable
    {
        public let name: String
        public let value: Bool
    }

    public struct MutationVerdict:
        Codable,
        Equatable,
        Sendable
    {
        public let ordinal: Int
        public let mutationID: String
        public let expectedFailedLegID: String
        public let detected: Bool
        public let fingerprintDiverged: Bool
        public let restored: Bool
        public let restoredFingerprintExact: Bool

        private enum CodingKeys: String, CodingKey {
            case ordinal
            case mutationID = "mutation_id"
            case expectedFailedLegID = "expected_failed_leg_id"
            case detected
            case fingerprintDiverged = "fingerprint_diverged"
            case restored
            case restoredFingerprintExact =
                "restored_fingerprint_exact"
        }
    }

    public struct StatisticsSummary:
        Codable,
        Equatable,
        Sendable
    {
        public let historicalAgreeCount: Int
        public let historicalIndependentPassCount: Int
        public let historicalOutcome: String
        public let historicalTriadicLabel: String
        public let historicalNextAction: String
        public let materialReloadComponents: [NamedBoolean]
        public let historicalMutationOutcome: String
        public let historicalMutationTriadicLabel: String
        public let historicalMutationValues: [MutationVerdict]
        public let exactSingletonFailureSetsSatisfied: Bool
        public let sourceDerivedSingletonRegradeOutcome: String

        private enum CodingKeys: String, CodingKey {
            case historicalAgreeCount = "historical_agree_count"
            case historicalIndependentPassCount =
                "historical_independent_pass_count"
            case historicalOutcome = "historical_outcome"
            case historicalTriadicLabel =
                "historical_triadic_label"
            case historicalNextAction = "historical_next_action"
            case materialReloadComponents =
                "material_reload_components"
            case historicalMutationOutcome =
                "historical_mutation_outcome"
            case historicalMutationTriadicLabel =
                "historical_mutation_triadic_label"
            case historicalMutationValues =
                "historical_mutation_values"
            case exactSingletonFailureSetsSatisfied =
                "exact_singleton_failure_sets_satisfied"
            case sourceDerivedSingletonRegradeOutcome =
                "source_derived_singleton_regrade_outcome"
        }
    }

    public struct CriticalLegCarrierValue:
        Codable,
        Equatable,
        Sendable
    {
        public let ordinal: Int
        public let legID: String
        public let passed: Bool

        private enum CodingKeys: String, CodingKey {
            case ordinal
            case legID = "leg_id"
            case passed
        }
    }

    public static let schemaID =
        "prime_stage_b_historical_keyed_three_seed_statistics_verdict_observation_v1"
    public static let joinPolicyID =
        "explicit_seed_keyed_three_family_exact_coverage_no_positional_join_v1"
    public static let maximumCanonicalByteCount = 16_777_216
    public static let admittedSeeds:
        [PrimeNativeNeuralGateArtifactSeed] = [
            .seed1618,
            .seed2718,
            .seed3141,
        ]

    public let schemaVersion: Int
    public let schemaID: String
    public let invocationRole:
        PrimeNativeNeuralGateHistoricalArtifactRole
    public let admittedSeeds: [PrimeNativeNeuralGateArtifactSeed]
    public let joinPolicyID: String
    public let orderedSeedEntries: [SeedStatisticsEntry]
    public let summary: StatisticsSummary
    public let historicalCriticalLegValues:
        [CriticalLegCarrierValue]
    public let reductionApplied: Bool
    public let summaryMaySupplyEvidence: Bool
    public let mechanicsPassAuthorized: Bool
    public let terminalReceiptAuthorized: Bool
    public let sourceBindingV7Issued: Bool
    public let scientificAuthorityAuthorized: Bool
    public let productAuthorityAuthorized: Bool

    private struct DecodeWire: Decodable {
        let schemaVersion: Int
        let schemaID: String
        let invocationRole:
            PrimeNativeNeuralGateHistoricalArtifactRole
        let admittedSeeds: [PrimeNativeNeuralGateArtifactSeed]
        let joinPolicyID: String
        let orderedSeedEntries: [SeedStatisticsEntry]
        let summary: StatisticsSummary
        let historicalCriticalLegValues:
            [CriticalLegCarrierValue]
        let reductionApplied: Bool
        let summaryMaySupplyEvidence: Bool
        let mechanicsPassAuthorized: Bool
        let terminalReceiptAuthorized: Bool
        let sourceBindingV7Issued: Bool
        let scientificAuthorityAuthorized: Bool
        let productAuthorityAuthorized: Bool

        private enum CodingKeys: String, CodingKey {
            case schemaVersion = "schema_version"
            case schemaID = "schema_id"
            case invocationRole = "invocation_role"
            case admittedSeeds = "admitted_seeds"
            case joinPolicyID = "join_policy_id"
            case orderedSeedEntries = "ordered_seed_entries"
            case summary
            case historicalCriticalLegValues =
                "historical_critical_leg_values"
            case reductionApplied = "reduction_applied"
            case summaryMaySupplyEvidence =
                "summary_may_supply_evidence"
            case mechanicsPassAuthorized =
                "mechanics_pass_authorized"
            case terminalReceiptAuthorized =
                "terminal_receipt_authorized"
            case sourceBindingV7Issued = "source_binding_v7_issued"
            case scientificAuthorityAuthorized =
                "scientific_authority_authorized"
            case productAuthorityAuthorized =
                "product_authority_authorized"
        }
    }

    private init(_ wire: DecodeWire) {
        schemaVersion = wire.schemaVersion
        schemaID = wire.schemaID
        invocationRole = wire.invocationRole
        admittedSeeds = wire.admittedSeeds
        joinPolicyID = wire.joinPolicyID
        orderedSeedEntries = wire.orderedSeedEntries
        summary = wire.summary
        historicalCriticalLegValues =
            wire.historicalCriticalLegValues
        reductionApplied = wire.reductionApplied
        summaryMaySupplyEvidence = wire.summaryMaySupplyEvidence
        mechanicsPassAuthorized = wire.mechanicsPassAuthorized
        terminalReceiptAuthorized = wire.terminalReceiptAuthorized
        sourceBindingV7Issued = wire.sourceBindingV7Issued
        scientificAuthorityAuthorized =
            wire.scientificAuthorityAuthorized
        productAuthorityAuthorized = wire.productAuthorityAuthorized
    }

    /// Decodes only a bounded, validated, byte-canonical V16 artifact.
    /// The byte limit is checked before `JSONDecoder` sees the payload.
    public static func decodeCanonical(
        _ data: Data
    ) throws -> Self {
        guard !data.isEmpty else {
            throw PrimeNativeNeuralGateHistoricalStatisticsArtifactError
                .emptyArtifact
        }
        guard data.count <= maximumCanonicalByteCount else {
            throw PrimeNativeNeuralGateHistoricalStatisticsArtifactError
                .artifactTooLarge(
                    actualByteCount: data.count,
                    maximumByteCount: maximumCanonicalByteCount
                )
        }

        let wire: DecodeWire
        do {
            wire = try JSONDecoder().decode(
                DecodeWire.self,
                from: data
            )
        } catch {
            throw PrimeNativeNeuralGateHistoricalStatisticsArtifactError
                .invalidJSON
        }
        let value = Self(wire)
        try value.validate()
        guard try value.canonicalData() == data else {
            throw PrimeNativeNeuralGateHistoricalStatisticsArtifactError
                .nonCanonicalJSON
        }
        return value
    }

    public func validate() throws {
        guard schemaVersion == 1,
              schemaID == Self.schemaID,
              admittedSeeds == Self.admittedSeeds,
              joinPolicyID == Self.joinPolicyID,
              orderedSeedEntries.map(\.seed) == admittedSeeds,
              orderedSeedEntries.allSatisfy({
                  $0.seed.rawValue == $0.heldout.seed
                      && $0.seed.rawValue
                        == $0.fixedPromptReplay.seed
                      && $0.seed.rawValue == $0.capability.seed
              }),
              orderedSeedEntries.allSatisfy({
                  Self.validateHeldout($0.heldout)
                      && Self.validateFixedPrompt(
                          $0.fixedPromptReplay
                      )
                      && Self.validateCapability($0.capability)
                      && $0.capability.orderedSplitValues.count == 5
                      && $0.capability.requiredAbstentionRowCount
                        == 2_048
                      && $0.capability
                        .orderedAbstentionDecisionRows.count == 2_048
              }),
              orderedSeedEntries.allSatisfy({
                  Self.isLexicallyOrderedUnique(
                      $0.heldout.heldoutFamilyCrossEntropyBefore
                  ) && Self.isLexicallyOrderedUnique(
                      $0.heldout.heldoutFamilyCrossEntropyAfter
                  )
              }),
              historicalCriticalLegValues.count == 10,
              historicalCriticalLegValues.map(\.ordinal)
                == Array(1 ... 10),
              historicalCriticalLegValues.map(\.legID)
                == PrimeNativeNeuralGateReplayLegDomain
                .historicalCriticalLegIDs,
              summary.historicalMutationValues.count == 46,
              summary.historicalMutationValues.map(\.ordinal)
                == Array(1 ... 46),
              summary.historicalMutationValues.map(\.mutationID)
                == PrimeNativeNeuralGateMutationCatalog
                .historicalEntries.map(\.mutationID),
              summary.historicalMutationValues
                .map(\.expectedFailedLegID)
                == PrimeNativeNeuralGateMutationCatalog
                .historicalEntries.map(\.expectedFailedLegID),
              !reductionApplied,
              !summaryMaySupplyEvidence,
              !mechanicsPassAuthorized,
              !terminalReceiptAuthorized,
              !sourceBindingV7Issued,
              !scientificAuthorityAuthorized,
              !productAuthorityAuthorized
        else {
            throw PrimeNativeNeuralGateHistoricalStatisticsArtifactError
                .invalidEnvelope("shape_or_authority")
        }
    }

    public func canonicalData() throws -> Data {
        try validate()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [
            .sortedKeys,
            .withoutEscapingSlashes,
        ]

        let data: Data
        do {
            data = try encoder.encode(self)
        } catch {
            throw PrimeNativeNeuralGateHistoricalStatisticsArtifactError
                .canonicalEncodingFailed
        }
        guard data.count <= Self.maximumCanonicalByteCount else {
            throw PrimeNativeNeuralGateHistoricalStatisticsArtifactError
                .artifactTooLarge(
                    actualByteCount: data.count,
                    maximumByteCount:
                        Self.maximumCanonicalByteCount
                )
        }
        return data
    }

    private static func isLexicallyOrderedUnique(
        _ values: [NamedDoubleBitPattern]
    ) -> Bool {
        let names = values.map(\.name)
        return names == names.sorted {
            $0.utf8.lexicographicallyPrecedes($1.utf8)
        }
            && Set(names).count == names.count
    }

    private static func validateHeldout(
        _ value: HeldoutSeedStatistics
    ) -> Bool {
        let scalarPatterns = [
            value.heldoutCrossEntropyBeforeBitPattern,
            value.heldoutCrossEntropyAfterBitPattern,
            value.heldoutValidCrossEntropyBeforeBitPattern,
            value.heldoutValidCrossEntropyAfterBitPattern,
            value.heldoutRefusalCrossEntropyBeforeBitPattern,
            value.heldoutRefusalCrossEntropyAfterBitPattern,
            value.heldoutCrossEntropyStandardErrorBitPattern,
            value.initialLossBitPattern,
            value.finalLossBitPattern,
        ]
        return value.heldoutRowCount == 288
            && value.heldoutLossRows.count == value.heldoutRowCount
            && Self.sumEquals(
                value.heldoutValidRowCount,
                value.heldoutRefusalRowCount,
                value.heldoutRowCount
            )
            && Self.sumEquals(
                value.heldoutValidTargetTokenCount,
                value.heldoutRefusalTargetTokenCount,
                value.heldoutTargetTokenCount
            )
            && value.heldoutEvaluationNonPaddingTokenCount
                >= value.heldoutTargetTokenCount
            && !value.heldoutCrossEntropyStandardErrorMethodID.isEmpty
            && scalarPatterns.allSatisfy {
                Double(bitPattern: $0).isFinite
            }
            && value.heldoutFamilyCrossEntropyBefore.allSatisfy {
                !$0.name.isEmpty
                    && Double(bitPattern: $0.bitPattern).isFinite
            }
            && value.heldoutFamilyCrossEntropyAfter.allSatisfy {
                !$0.name.isEmpty
                    && Double(bitPattern: $0.bitPattern).isFinite
            }
            && value.heldoutLossRows.allSatisfy {
                Self.isLowercaseSHA256($0.rowSHA256)
                    && $0.targetTokenCount >= 0
                    && $0.nonPaddingTokenCount >= $0.targetTokenCount
                    && Double(
                        bitPattern:
                            $0.crossEntropyBeforeBitPattern
                    ).isFinite
                    && Double(
                        bitPattern:
                            $0.crossEntropyAfterBitPattern
                    ).isFinite
            }
    }

    private static func validateFixedPrompt(
        _ value: FixedPromptSeedReplay
    ) -> Bool {
        value.firstLogitFloatBitPatterns.count == 512
            && value.replayLogitFloatBitPatterns.count == 512
            && [
                value.maximumLogitDeltaBitPattern,
                value.firstGreedyRunnerUpMarginBitPattern,
                value.replayGreedyRunnerUpMarginBitPattern,
            ].allSatisfy { Double(bitPattern: $0).isFinite }
            && Self.isLowercaseSHA256(value.firstResultSHA256)
            && Self.isLowercaseSHA256(value.replayResultSHA256)
    }

    private static func validateCapability(
        _ value: CapabilitySeedObservation
    ) -> Bool {
        let expectedSplits = [
            ("validation", 4_096),
            ("combination_holdout", 4_096),
            ("ood", 4_096),
            ("mutation", 4_096),
            ("abstention", 2_048),
        ]
        return value.orderedSplitValues.map(\.splitID)
            == expectedSplits.map(\.0)
            && value.orderedSplitValues.map(\.rowCount)
                == expectedSplits.map(\.1)
            && value.orderedSplitValues.allSatisfy {
                [
                    $0.zeroShotExactAccuracyBitPattern,
                    $0.trainedExactAccuracyBitPattern,
                    $0.trainedMeanLogProbabilityBitPattern,
                ].allSatisfy {
                    Double(bitPattern: $0).isFinite
                }
            }
            && value.orderedAbstentionDecisionRows.allSatisfy {
                !$0.rowID.isEmpty
                    && Self.isLowercaseSHA256($0.corpusRowSHA256)
                    && Self.isLowercaseSHA256(
                        $0.evaluationRowSHA256
                    )
                    && $0.splitID == "abstention"
            }
    }

    private static func sumEquals(
        _ lhs: Int,
        _ rhs: Int,
        _ expected: Int
    ) -> Bool {
        let result = lhs.addingReportingOverflow(rhs)
        return !result.overflow && result.partialValue == expected
    }

    private static func isLowercaseSHA256(
        _ value: String
    ) -> Bool {
        value.utf8.count == 64
            && value.utf8.allSatisfy {
                ($0 >= 48 && $0 <= 57)
                    || ($0 >= 97 && $0 <= 102)
            }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case schemaID = "schema_id"
        case invocationRole = "invocation_role"
        case admittedSeeds = "admitted_seeds"
        case joinPolicyID = "join_policy_id"
        case orderedSeedEntries = "ordered_seed_entries"
        case summary
        case historicalCriticalLegValues =
            "historical_critical_leg_values"
        case reductionApplied = "reduction_applied"
        case summaryMaySupplyEvidence =
            "summary_may_supply_evidence"
        case mechanicsPassAuthorized =
            "mechanics_pass_authorized"
        case terminalReceiptAuthorized =
            "terminal_receipt_authorized"
        case sourceBindingV7Issued = "source_binding_v7_issued"
        case scientificAuthorityAuthorized =
            "scientific_authority_authorized"
        case productAuthorityAuthorized =
            "product_authority_authorized"
    }
}
