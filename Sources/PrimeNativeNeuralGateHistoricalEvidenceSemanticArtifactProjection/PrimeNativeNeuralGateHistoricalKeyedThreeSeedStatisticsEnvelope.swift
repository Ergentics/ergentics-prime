// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
import PrimeNativeNeuralGateHistoricalEvidenceExportMechanics
import PrimeNativeNeuralGateReplayArtifactContracts
import PrimeNativeNeuralGateReplayMechanics

public enum PrimeNativeNeuralGateHistoricalProjectionError:
    Error,
    Equatable,
    Sendable
{
    case duplicateSeed(String, Int)
    case missingSeed(String, Int)
    case unknownSeed(String, Int)
    case crossFamilySeedCoverage
    case invalidStatisticsEnvelope(String)
    case canonicalJSONTooLarge(Int)
    case nonCanonicalJSON
    case invalidInvariantEvidence(String)
    case invalidMutationEvidence(String)
    case invalidCriticalLegEvidence(String)
    case invalidArtifactSet(String)
}

public struct PrimeNativeNeuralGateNamedDoubleBitPattern:
    Codable,
    Equatable,
    Sendable
{
    public let name: String
    public let bitPattern: UInt64

    init(name: String, value: Double) {
        self.name = name
        bitPattern = value.bitPattern
    }

    private enum CodingKeys: String, CodingKey {
        case name
        case bitPattern = "bit_pattern"
    }
}

public struct PrimeNativeNeuralGateHistoricalHeldoutLossRow:
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

    init(
        _ source:
            PrimeNativeNeuralGateHistoricalEvidenceExporter
            .HeldoutLossRowValue
    ) {
        rowID = source.rowID
        rowSHA256 = source.rowSHA256
        selectionSplitID = source.selectionSplitID
        targetClass = source.targetClass
        semanticFamily = source.semanticFamily
        targetTokenCount = source.targetTokenCount
        nonPaddingTokenCount = source.nonPaddingTokenCount
        crossEntropyBeforeBitPattern =
            source.crossEntropyBefore.bitPattern
        crossEntropyAfterBitPattern =
            source.crossEntropyAfter.bitPattern
    }

    init(
        rowID: String,
        rowSHA256: String,
        selectionSplitID: String,
        targetClass: String,
        semanticFamily: String,
        targetTokenCount: Int,
        nonPaddingTokenCount: Int,
        crossEntropyBeforeBitPattern: UInt64,
        crossEntropyAfterBitPattern: UInt64
    ) {
        self.rowID = rowID
        self.rowSHA256 = rowSHA256
        self.selectionSplitID = selectionSplitID
        self.targetClass = targetClass
        self.semanticFamily = semanticFamily
        self.targetTokenCount = targetTokenCount
        self.nonPaddingTokenCount = nonPaddingTokenCount
        self.crossEntropyBeforeBitPattern =
            crossEntropyBeforeBitPattern
        self.crossEntropyAfterBitPattern =
            crossEntropyAfterBitPattern
    }

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

public struct PrimeNativeNeuralGateHistoricalHeldoutSeedStatistics:
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
        [PrimeNativeNeuralGateNamedDoubleBitPattern]
    public let heldoutFamilyCrossEntropyAfter:
        [PrimeNativeNeuralGateNamedDoubleBitPattern]
    public let initialLossBitPattern: UInt64
    public let finalLossBitPattern: UInt64
    public let heldoutLossRows:
        [PrimeNativeNeuralGateHistoricalHeldoutLossRow]

    init(
        _ source:
            PrimeNativeNeuralGateHistoricalEvidenceExporter
            .HeldoutStatisticsValue
    ) {
        seed = source.seed
        heldoutRowCount = source.heldoutRowCount
        heldoutValidRowCount = source.heldoutValidRowCount
        heldoutRefusalRowCount = source.heldoutRefusalRowCount
        heldoutTargetTokenCount = source.heldoutTargetTokenCount
        heldoutValidTargetTokenCount =
            source.heldoutValidTargetTokenCount
        heldoutRefusalTargetTokenCount =
            source.heldoutRefusalTargetTokenCount
        heldoutEvaluationNonPaddingTokenCount =
            source.heldoutEvaluationNonPaddingTokenCount
        heldoutCrossEntropyBeforeBitPattern =
            source.heldoutCrossEntropyBefore.bitPattern
        heldoutCrossEntropyAfterBitPattern =
            source.heldoutCrossEntropyAfter.bitPattern
        heldoutValidCrossEntropyBeforeBitPattern =
            source.heldoutValidCrossEntropyBefore.bitPattern
        heldoutValidCrossEntropyAfterBitPattern =
            source.heldoutValidCrossEntropyAfter.bitPattern
        heldoutRefusalCrossEntropyBeforeBitPattern =
            source.heldoutRefusalCrossEntropyBefore.bitPattern
        heldoutRefusalCrossEntropyAfterBitPattern =
            source.heldoutRefusalCrossEntropyAfter.bitPattern
        heldoutCrossEntropyStandardErrorBitPattern =
            source.heldoutCrossEntropyStandardError.bitPattern
        heldoutCrossEntropyStandardErrorMethodID =
            source.heldoutCrossEntropyStandardErrorMethodID
        heldoutFamilyCrossEntropyBefore =
            source.heldoutFamilyCrossEntropyBefore
            .map {
                PrimeNativeNeuralGateNamedDoubleBitPattern(
                    name: $0.key,
                    value: $0.value
                )
            }
            .sorted {
                $0.name.utf8.lexicographicallyPrecedes(
                    $1.name.utf8
                )
            }
        heldoutFamilyCrossEntropyAfter =
            source.heldoutFamilyCrossEntropyAfter
            .map {
                PrimeNativeNeuralGateNamedDoubleBitPattern(
                    name: $0.key,
                    value: $0.value
                )
            }
            .sorted {
                $0.name.utf8.lexicographicallyPrecedes(
                    $1.name.utf8
                )
            }
        initialLossBitPattern = source.initialLoss.bitPattern
        finalLossBitPattern = source.finalLoss.bitPattern
        heldoutLossRows = source.heldoutLossRows.map(
            PrimeNativeNeuralGateHistoricalHeldoutLossRow.init
        )
    }

    init(
        seed: Int,
        heldoutRowCount: Int,
        heldoutValidRowCount: Int,
        heldoutRefusalRowCount: Int,
        heldoutTargetTokenCount: Int,
        heldoutValidTargetTokenCount: Int,
        heldoutRefusalTargetTokenCount: Int,
        heldoutEvaluationNonPaddingTokenCount: Int,
        heldoutCrossEntropyBeforeBitPattern: UInt64,
        heldoutCrossEntropyAfterBitPattern: UInt64,
        heldoutValidCrossEntropyBeforeBitPattern: UInt64,
        heldoutValidCrossEntropyAfterBitPattern: UInt64,
        heldoutRefusalCrossEntropyBeforeBitPattern: UInt64,
        heldoutRefusalCrossEntropyAfterBitPattern: UInt64,
        heldoutCrossEntropyStandardErrorBitPattern: UInt64,
        heldoutCrossEntropyStandardErrorMethodID: String,
        heldoutFamilyCrossEntropyBefore:
            [PrimeNativeNeuralGateNamedDoubleBitPattern],
        heldoutFamilyCrossEntropyAfter:
            [PrimeNativeNeuralGateNamedDoubleBitPattern],
        initialLossBitPattern: UInt64,
        finalLossBitPattern: UInt64,
        heldoutLossRows:
            [PrimeNativeNeuralGateHistoricalHeldoutLossRow]
    ) {
        self.seed = seed
        self.heldoutRowCount = heldoutRowCount
        self.heldoutValidRowCount = heldoutValidRowCount
        self.heldoutRefusalRowCount = heldoutRefusalRowCount
        self.heldoutTargetTokenCount = heldoutTargetTokenCount
        self.heldoutValidTargetTokenCount =
            heldoutValidTargetTokenCount
        self.heldoutRefusalTargetTokenCount =
            heldoutRefusalTargetTokenCount
        self.heldoutEvaluationNonPaddingTokenCount =
            heldoutEvaluationNonPaddingTokenCount
        self.heldoutCrossEntropyBeforeBitPattern =
            heldoutCrossEntropyBeforeBitPattern
        self.heldoutCrossEntropyAfterBitPattern =
            heldoutCrossEntropyAfterBitPattern
        self.heldoutValidCrossEntropyBeforeBitPattern =
            heldoutValidCrossEntropyBeforeBitPattern
        self.heldoutValidCrossEntropyAfterBitPattern =
            heldoutValidCrossEntropyAfterBitPattern
        self.heldoutRefusalCrossEntropyBeforeBitPattern =
            heldoutRefusalCrossEntropyBeforeBitPattern
        self.heldoutRefusalCrossEntropyAfterBitPattern =
            heldoutRefusalCrossEntropyAfterBitPattern
        self.heldoutCrossEntropyStandardErrorBitPattern =
            heldoutCrossEntropyStandardErrorBitPattern
        self.heldoutCrossEntropyStandardErrorMethodID =
            heldoutCrossEntropyStandardErrorMethodID
        self.heldoutFamilyCrossEntropyBefore =
            heldoutFamilyCrossEntropyBefore
        self.heldoutFamilyCrossEntropyAfter =
            heldoutFamilyCrossEntropyAfter
        self.initialLossBitPattern = initialLossBitPattern
        self.finalLossBitPattern = finalLossBitPattern
        self.heldoutLossRows = heldoutLossRows
    }

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

public struct PrimeNativeNeuralGateHistoricalFixedPromptSeedReplay:
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

    init(
        _ source:
            PrimeNativeNeuralGateHistoricalEvidenceExporter
            .FixedPromptReplayValue
    ) {
        seed = source.seed
        firstLogitFloatBitPatterns =
            source.firstLogitFloatBitPatterns
        replayLogitFloatBitPatterns =
            source.replayLogitFloatBitPatterns
        maximumLogitDeltaBitPattern =
            source.maximumLogitDelta.bitPattern
        firstGreedyTokenID = source.firstGreedyTokenID
        replayGreedyTokenID = source.replayGreedyTokenID
        firstGreedyRunnerUpMarginBitPattern =
            source.firstGreedyRunnerUpMargin.bitPattern
        replayGreedyRunnerUpMarginBitPattern =
            source.replayGreedyRunnerUpMargin.bitPattern
        greedyTokenExact = source.greedyTokenExact
        behavioralReplayExact = source.behavioralReplayExact
        firstResultSHA256 = source.firstResultSHA256
        replayResultSHA256 = source.replayResultSHA256
        resultExact = source.resultExact
    }

    init(
        seed: Int,
        firstLogitFloatBitPatterns: [UInt32],
        replayLogitFloatBitPatterns: [UInt32],
        maximumLogitDeltaBitPattern: UInt64,
        firstGreedyTokenID: Int,
        replayGreedyTokenID: Int,
        firstGreedyRunnerUpMarginBitPattern: UInt64,
        replayGreedyRunnerUpMarginBitPattern: UInt64,
        greedyTokenExact: Bool,
        behavioralReplayExact: Bool,
        firstResultSHA256: String,
        replayResultSHA256: String,
        resultExact: Bool
    ) {
        self.seed = seed
        self.firstLogitFloatBitPatterns =
            firstLogitFloatBitPatterns
        self.replayLogitFloatBitPatterns =
            replayLogitFloatBitPatterns
        self.maximumLogitDeltaBitPattern =
            maximumLogitDeltaBitPattern
        self.firstGreedyTokenID = firstGreedyTokenID
        self.replayGreedyTokenID = replayGreedyTokenID
        self.firstGreedyRunnerUpMarginBitPattern =
            firstGreedyRunnerUpMarginBitPattern
        self.replayGreedyRunnerUpMarginBitPattern =
            replayGreedyRunnerUpMarginBitPattern
        self.greedyTokenExact = greedyTokenExact
        self.behavioralReplayExact = behavioralReplayExact
        self.firstResultSHA256 = firstResultSHA256
        self.replayResultSHA256 = replayResultSHA256
        self.resultExact = resultExact
    }

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

public struct PrimeNativeNeuralGateHistoricalCapabilitySplit:
    Codable,
    Equatable,
    Sendable
{
    public let splitID: String
    public let rowCount: Int
    public let zeroShotExactAccuracyBitPattern: UInt64
    public let trainedExactAccuracyBitPattern: UInt64
    public let trainedMeanLogProbabilityBitPattern: UInt64

    init(
        _ source:
            PrimeNativeNeuralGateHistoricalEvidenceExporter
            .CapabilitySplitValue
    ) {
        splitID = source.splitID
        rowCount = source.rowCount
        zeroShotExactAccuracyBitPattern =
            source.zeroShotExactAccuracy.bitPattern
        trainedExactAccuracyBitPattern =
            source.trainedExactAccuracy.bitPattern
        trainedMeanLogProbabilityBitPattern =
            source.trainedMeanLogProbability.bitPattern
    }

    init(
        splitID: String,
        rowCount: Int,
        zeroShotExactAccuracyBitPattern: UInt64,
        trainedExactAccuracyBitPattern: UInt64,
        trainedMeanLogProbabilityBitPattern: UInt64
    ) {
        self.splitID = splitID
        self.rowCount = rowCount
        self.zeroShotExactAccuracyBitPattern =
            zeroShotExactAccuracyBitPattern
        self.trainedExactAccuracyBitPattern =
            trainedExactAccuracyBitPattern
        self.trainedMeanLogProbabilityBitPattern =
            trainedMeanLogProbabilityBitPattern
    }

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

public struct PrimeNativeNeuralGateHistoricalAbstentionDecisionRow:
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

    init(
        _ source:
            PrimeNativeNeuralGateHistoricalEvidenceExporter
            .AbstentionDecisionRowValue
    ) {
        rowID = source.rowID
        corpusRowSHA256 = source.corpusRowSHA256
        evaluationRowSHA256 = source.evaluationRowSHA256
        splitID = source.splitID
        target = source.target
        trainedPrediction = source.trainedPrediction
        trainedTerminatedByEOS = source.trainedTerminatedByEOS
        trainedTerminationReason = source.trainedTerminationReason
        trainedUTF8Valid = source.trainedUTF8Valid
        trainedExactMatch = source.trainedExactMatch
        trainedSemanticVerifierPass =
            source.trainedSemanticVerifierPass
        trainedAbstentionDecision = source.trainedAbstentionDecision
    }

    init(
        rowID: String,
        corpusRowSHA256: String,
        evaluationRowSHA256: String,
        splitID: String,
        target: String,
        trainedPrediction: String?,
        trainedTerminatedByEOS: Bool,
        trainedTerminationReason: String,
        trainedUTF8Valid: Bool,
        trainedExactMatch: Bool,
        trainedSemanticVerifierPass: Bool,
        trainedAbstentionDecision: Bool
    ) {
        self.rowID = rowID
        self.corpusRowSHA256 = corpusRowSHA256
        self.evaluationRowSHA256 = evaluationRowSHA256
        self.splitID = splitID
        self.target = target
        self.trainedPrediction = trainedPrediction
        self.trainedTerminatedByEOS = trainedTerminatedByEOS
        self.trainedTerminationReason = trainedTerminationReason
        self.trainedUTF8Valid = trainedUTF8Valid
        self.trainedExactMatch = trainedExactMatch
        self.trainedSemanticVerifierPass =
            trainedSemanticVerifierPass
        self.trainedAbstentionDecision = trainedAbstentionDecision
    }

    private enum CodingKeys: String, CodingKey {
        case rowID = "row_id"
        case corpusRowSHA256 = "corpus_row_sha256"
        case evaluationRowSHA256 = "evaluation_row_sha256"
        case splitID = "split_id"
        case target
        case trainedPrediction = "trained_prediction"
        case trainedTerminatedByEOS = "trained_terminated_by_eos"
        case trainedTerminationReason = "trained_termination_reason"
        case trainedUTF8Valid = "trained_utf8_valid"
        case trainedExactMatch = "trained_exact_match"
        case trainedSemanticVerifierPass =
            "trained_semantic_verifier_pass"
        case trainedAbstentionDecision =
            "trained_abstention_decision"
    }
}

public struct PrimeNativeNeuralGateHistoricalCapabilitySeedObservation:
    Codable,
    Equatable,
    Sendable
{
    public let seed: Int
    public let orderedSplitValues:
        [PrimeNativeNeuralGateHistoricalCapabilitySplit]
    public let requiredAbstentionRowCount: Int
    public let orderedAbstentionDecisionRows:
        [PrimeNativeNeuralGateHistoricalAbstentionDecisionRow]
    public let exactAbstentionDecisionsObserved: Bool

    init(
        _ source:
            PrimeNativeNeuralGateHistoricalEvidenceExporter
            .CapabilityValue
    ) {
        seed = source.seed
        orderedSplitValues = source.orderedSplitValues.map(
            PrimeNativeNeuralGateHistoricalCapabilitySplit.init
        )
        requiredAbstentionRowCount =
            source.requiredAbstentionRowCount
        orderedAbstentionDecisionRows =
            source.orderedAbstentionDecisionRows.map(
                PrimeNativeNeuralGateHistoricalAbstentionDecisionRow.init
            )
        exactAbstentionDecisionsObserved =
            source.exactAbstentionDecisionsObserved
    }

    init(
        seed: Int,
        orderedSplitValues:
            [PrimeNativeNeuralGateHistoricalCapabilitySplit],
        requiredAbstentionRowCount: Int,
        orderedAbstentionDecisionRows:
            [PrimeNativeNeuralGateHistoricalAbstentionDecisionRow],
        exactAbstentionDecisionsObserved: Bool
    ) {
        self.seed = seed
        self.orderedSplitValues = orderedSplitValues
        self.requiredAbstentionRowCount =
            requiredAbstentionRowCount
        self.orderedAbstentionDecisionRows =
            orderedAbstentionDecisionRows
        self.exactAbstentionDecisionsObserved =
            exactAbstentionDecisionsObserved
    }

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

public struct PrimeNativeNeuralGateHistoricalSeedStatisticsEntry:
    Codable,
    Equatable,
    Sendable
{
    public let seed: PrimeNativeNeuralGateArtifactSeed
    public let heldout:
        PrimeNativeNeuralGateHistoricalHeldoutSeedStatistics
    public let fixedPromptReplay:
        PrimeNativeNeuralGateHistoricalFixedPromptSeedReplay
    public let capability:
        PrimeNativeNeuralGateHistoricalCapabilitySeedObservation

    private enum CodingKeys: String, CodingKey {
        case seed
        case heldout
        case fixedPromptReplay = "fixed_prompt_replay"
        case capability
    }
}

public struct PrimeNativeNeuralGateHistoricalNamedBoolean:
    Codable,
    Equatable,
    Sendable
{
    public let name: String
    public let value: Bool

    init(
        _ source:
            PrimeNativeNeuralGateHistoricalEvidenceExporter.NamedBoolean
    ) {
        name = source.name
        value = source.value
    }
}

public struct PrimeNativeNeuralGateHistoricalMutationVerdict:
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

    init(
        _ source:
            PrimeNativeNeuralGateHistoricalEvidenceExporter
            .HistoricalMutationVerdictValue
    ) {
        ordinal = source.ordinal
        mutationID = source.mutationID
        expectedFailedLegID = source.expectedFailedLegID
        detected = source.detected
        fingerprintDiverged = source.fingerprintDiverged
        restored = source.restored
        restoredFingerprintExact = source.restoredFingerprintExact
    }

    init(
        ordinal: Int,
        mutationID: String,
        expectedFailedLegID: String,
        detected: Bool,
        fingerprintDiverged: Bool,
        restored: Bool,
        restoredFingerprintExact: Bool
    ) {
        self.ordinal = ordinal
        self.mutationID = mutationID
        self.expectedFailedLegID = expectedFailedLegID
        self.detected = detected
        self.fingerprintDiverged = fingerprintDiverged
        self.restored = restored
        self.restoredFingerprintExact =
            restoredFingerprintExact
    }

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

public struct PrimeNativeNeuralGateHistoricalStatisticsSummary:
    Codable,
    Equatable,
    Sendable
{
    public let historicalAgreeCount: Int
    public let historicalIndependentPassCount: Int
    public let historicalOutcome: String
    public let historicalTriadicLabel: String
    public let historicalNextAction: String
    public let materialReloadComponents:
        [PrimeNativeNeuralGateHistoricalNamedBoolean]
    public let historicalMutationOutcome: String
    public let historicalMutationTriadicLabel: String
    public let historicalMutationValues:
        [PrimeNativeNeuralGateHistoricalMutationVerdict]
    public let exactSingletonFailureSetsSatisfied: Bool
    public let sourceDerivedSingletonRegradeOutcome: String

    init(
        _ source:
            PrimeNativeNeuralGateHistoricalEvidenceExporter
            .HistoricalStatisticsAndVerdictValues
    ) {
        historicalAgreeCount = source.historicalAgreeCount
        historicalIndependentPassCount =
            source.historicalIndependentPassCount
        historicalOutcome = source.historicalOutcome
        historicalTriadicLabel = source.historicalTriadicLabel
        historicalNextAction = source.historicalNextAction
        materialReloadComponents =
            source.materialReloadComponents.map(
                PrimeNativeNeuralGateHistoricalNamedBoolean.init
            )
        historicalMutationOutcome = source.historicalMutationOutcome
        historicalMutationTriadicLabel =
            source.historicalMutationTriadicLabel
        historicalMutationValues =
            source.historicalMutationValues.map(
                PrimeNativeNeuralGateHistoricalMutationVerdict.init
            )
        exactSingletonFailureSetsSatisfied =
            source.sourceDerivedSingletonRegradeDisposition
            .exactSingletonFailureSetsSatisfied
        sourceDerivedSingletonRegradeOutcome =
            source.sourceDerivedSingletonRegradeDisposition.outcome
    }

    init(
        historicalAgreeCount: Int,
        historicalIndependentPassCount: Int,
        historicalOutcome: String,
        historicalTriadicLabel: String,
        historicalNextAction: String,
        materialReloadComponents:
            [PrimeNativeNeuralGateHistoricalNamedBoolean],
        historicalMutationOutcome: String,
        historicalMutationTriadicLabel: String,
        historicalMutationValues:
            [PrimeNativeNeuralGateHistoricalMutationVerdict],
        exactSingletonFailureSetsSatisfied: Bool,
        sourceDerivedSingletonRegradeOutcome: String
    ) {
        self.historicalAgreeCount = historicalAgreeCount
        self.historicalIndependentPassCount =
            historicalIndependentPassCount
        self.historicalOutcome = historicalOutcome
        self.historicalTriadicLabel = historicalTriadicLabel
        self.historicalNextAction = historicalNextAction
        self.materialReloadComponents = materialReloadComponents
        self.historicalMutationOutcome = historicalMutationOutcome
        self.historicalMutationTriadicLabel =
            historicalMutationTriadicLabel
        self.historicalMutationValues = historicalMutationValues
        self.exactSingletonFailureSetsSatisfied =
            exactSingletonFailureSetsSatisfied
        self.sourceDerivedSingletonRegradeOutcome =
            sourceDerivedSingletonRegradeOutcome
    }

    private enum CodingKeys: String, CodingKey {
        case historicalAgreeCount = "historical_agree_count"
        case historicalIndependentPassCount =
            "historical_independent_pass_count"
        case historicalOutcome = "historical_outcome"
        case historicalTriadicLabel = "historical_triadic_label"
        case historicalNextAction = "historical_next_action"
        case materialReloadComponents = "material_reload_components"
        case historicalMutationOutcome = "historical_mutation_outcome"
        case historicalMutationTriadicLabel =
            "historical_mutation_triadic_label"
        case historicalMutationValues = "historical_mutation_values"
        case exactSingletonFailureSetsSatisfied =
            "exact_singleton_failure_sets_satisfied"
        case sourceDerivedSingletonRegradeOutcome =
            "source_derived_singleton_regrade_outcome"
    }
}

public struct PrimeNativeNeuralGateHistoricalCriticalLegCarrierValue:
    Codable,
    Equatable,
    Sendable
{
    public let ordinal: Int
    public let legID: String
    public let passed: Bool

    init(
        _ source:
            PrimeNativeNeuralGateHistoricalEvidenceExporter.CriticalLegValue
    ) {
        ordinal = source.ordinal
        legID = source.legID
        passed = source.passed
    }

    init(
        ordinal: Int,
        legID: String,
        passed: Bool
    ) {
        self.ordinal = ordinal
        self.legID = legID
        self.passed = passed
    }

    private enum CodingKeys: String, CodingKey {
        case ordinal
        case legID = "leg_id"
        case passed
    }
}

/// Lossless, role-scoped historical statistics carrier. It deliberately
/// contains no reduced or promoted statistic: all three families are joined
/// independently by their explicit seed and every `Double` is represented by
/// its exact IEEE-754 bit pattern.
public struct PrimeNativeNeuralGateHistoricalKeyedThreeSeedStatisticsEnvelope:
    Codable,
    Equatable,
    Sendable
{
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
    public let admittedSeeds:
        [PrimeNativeNeuralGateArtifactSeed]
    public let joinPolicyID: String
    public let orderedSeedEntries:
        [PrimeNativeNeuralGateHistoricalSeedStatisticsEntry]
    public let summary:
        PrimeNativeNeuralGateHistoricalStatisticsSummary
    public let historicalCriticalLegValues:
        [PrimeNativeNeuralGateHistoricalCriticalLegCarrierValue]
    public let reductionApplied: Bool
    public let summaryMaySupplyEvidence: Bool
    public let mechanicsPassAuthorized: Bool
    public let terminalReceiptAuthorized: Bool
    public let sourceBindingV7Issued: Bool
    public let scientificAuthorityAuthorized: Bool
    public let productAuthorityAuthorized: Bool

    public static func make(
        invocationRole:
            PrimeNativeNeuralGateHistoricalArtifactRole,
        values:
            PrimeNativeNeuralGateHistoricalEvidenceExporter
            .HistoricalStatisticsAndVerdictValues,
        historicalCriticalLegValues:
            [PrimeNativeNeuralGateHistoricalEvidenceExporter.CriticalLegValue]
    ) throws -> Self {
        let heldout = values.heldoutStatistics.map(
            PrimeNativeNeuralGateHistoricalHeldoutSeedStatistics.init
        )
        let replay = values.fixedPromptReplayValues.map(
            PrimeNativeNeuralGateHistoricalFixedPromptSeedReplay.init
        )
        let capability = values.capabilityValues.map(
            PrimeNativeNeuralGateHistoricalCapabilitySeedObservation.init
        )
        let entries = try exactSeedJoin(
            heldout: heldout,
            replay: replay,
            capability: capability
        )
        let result = Self(
            schemaVersion: 1,
            schemaID: schemaID,
            invocationRole: invocationRole,
            admittedSeeds: admittedSeeds,
            joinPolicyID: joinPolicyID,
            orderedSeedEntries: entries,
            summary:
                PrimeNativeNeuralGateHistoricalStatisticsSummary(values),
            historicalCriticalLegValues:
                historicalCriticalLegValues.map(
                    PrimeNativeNeuralGateHistoricalCriticalLegCarrierValue.init
                ),
            reductionApplied: false,
            summaryMaySupplyEvidence: false,
            mechanicsPassAuthorized: false,
            terminalReceiptAuthorized: false,
            sourceBindingV7Issued: false,
            scientificAuthorityAuthorized: false,
            productAuthorityAuthorized: false
        )
        try result.validate()
        return result
    }

    public func validate() throws {
        guard schemaVersion == 1,
              schemaID == Self.schemaID,
              admittedSeeds == Self.admittedSeeds,
              joinPolicyID == Self.joinPolicyID,
              orderedSeedEntries.map(\.seed) == admittedSeeds,
              orderedSeedEntries.allSatisfy({
                  $0.seed.rawValue == $0.heldout.seed
                      && $0.seed.rawValue == $0.fixedPromptReplay.seed
                      && $0.seed.rawValue == $0.capability.seed
              }),
              orderedSeedEntries.allSatisfy({
                  Self.validateHeldout($0.heldout)
                      && Self.validateFixedPrompt(
                          $0.fixedPromptReplay
                      )
                      && Self.validateCapability($0.capability)
                      && $0.capability.orderedSplitValues.count == 5
                      && $0.capability.requiredAbstentionRowCount == 2_048
                      && $0.capability.orderedAbstentionDecisionRows.count
                        == 2_048
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
            throw PrimeNativeNeuralGateHistoricalProjectionError
                .invalidStatisticsEnvelope("shape_or_authority")
        }
    }

    public func canonicalData() throws -> Data {
        try validate()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [
            .sortedKeys,
            .withoutEscapingSlashes,
        ]
        let data = try encoder.encode(self)
        guard data.count <= Self.maximumCanonicalByteCount else {
            throw PrimeNativeNeuralGateHistoricalProjectionError
                .canonicalJSONTooLarge(data.count)
        }
        return data
    }

    /// Trusted-byte test seam only. This is not a bounded production decoder
    /// and deliberately does not claim the namespace decoder obligation.
    static func decodeCanonicalTrustedForTesting(
        _ data: Data
    ) throws -> Self {
        guard data.count <= maximumCanonicalByteCount else {
            throw PrimeNativeNeuralGateHistoricalProjectionError
                .canonicalJSONTooLarge(data.count)
        }
        let value = try JSONDecoder().decode(Self.self, from: data)
        try value.validate()
        guard try value.canonicalData() == data else {
            throw PrimeNativeNeuralGateHistoricalProjectionError
                .nonCanonicalJSON
        }
        return value
    }

    static func exactSeedJoin(
        heldout:
            [PrimeNativeNeuralGateHistoricalHeldoutSeedStatistics],
        replay:
            [PrimeNativeNeuralGateHistoricalFixedPromptSeedReplay],
        capability:
            [PrimeNativeNeuralGateHistoricalCapabilitySeedObservation]
    ) throws -> [PrimeNativeNeuralGateHistoricalSeedStatisticsEntry] {
        let heldoutBySeed = try keyed(
            heldout,
            family: "heldout",
            seed: \.seed
        )
        let replayBySeed = try keyed(
            replay,
            family: "fixed_prompt_replay",
            seed: \.seed
        )
        let capabilityBySeed = try keyed(
            capability,
            family: "capability",
            seed: \.seed
        )
        let familySets = [
            Set(heldoutBySeed.keys),
            Set(replayBySeed.keys),
            Set(capabilityBySeed.keys),
        ]
        guard familySets.dropFirst().allSatisfy({
            $0 == familySets[0]
        }) else {
            throw PrimeNativeNeuralGateHistoricalProjectionError
                .crossFamilySeedCoverage
        }
        for seed in admittedSeeds.map(\.rawValue)
        where heldoutBySeed[seed] == nil {
            throw PrimeNativeNeuralGateHistoricalProjectionError
                .missingSeed("all_families", seed)
        }
        return try admittedSeeds.map { seed in
            guard let h = heldoutBySeed[seed.rawValue],
                  let r = replayBySeed[seed.rawValue],
                  let c = capabilityBySeed[seed.rawValue]
            else {
                throw PrimeNativeNeuralGateHistoricalProjectionError
                    .missingSeed("joined", seed.rawValue)
            }
            return PrimeNativeNeuralGateHistoricalSeedStatisticsEntry(
                seed: seed,
                heldout: h,
                fixedPromptReplay: r,
                capability: c
            )
        }
    }

    private static func keyed<T>(
        _ values: [T],
        family: String,
        seed: KeyPath<T, Int>
    ) throws -> [Int: T] {
        var result: [Int: T] = [:]
        for value in values {
            let valueSeed = value[keyPath: seed]
            guard admittedSeeds.map(\.rawValue).contains(valueSeed) else {
                throw PrimeNativeNeuralGateHistoricalProjectionError
                    .unknownSeed(family, valueSeed)
            }
            guard result.updateValue(value, forKey: valueSeed) == nil else {
                throw PrimeNativeNeuralGateHistoricalProjectionError
                    .duplicateSeed(family, valueSeed)
            }
        }
        return result
    }

    private static func isLexicallyOrderedUnique(
        _ values: [PrimeNativeNeuralGateNamedDoubleBitPattern]
    ) -> Bool {
        let names = values.map(\.name)
        return names == names.sorted {
            $0.utf8.lexicographicallyPrecedes($1.utf8)
        }
            && Set(names).count == names.count
    }

    private static func validateHeldout(
        _ value:
            PrimeNativeNeuralGateHistoricalHeldoutSeedStatistics
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
            && value.heldoutValidRowCount
                + value.heldoutRefusalRowCount
                == value.heldoutRowCount
            && value.heldoutValidTargetTokenCount
                + value.heldoutRefusalTargetTokenCount
                == value.heldoutTargetTokenCount
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
        _ value:
            PrimeNativeNeuralGateHistoricalFixedPromptSeedReplay
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
        _ value:
            PrimeNativeNeuralGateHistoricalCapabilitySeedObservation
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
                    && Self.isLowercaseSHA256($0.evaluationRowSHA256)
                    && $0.splitID == "abstention"
            }
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
        case summaryMaySupplyEvidence = "summary_may_supply_evidence"
        case mechanicsPassAuthorized = "mechanics_pass_authorized"
        case terminalReceiptAuthorized = "terminal_receipt_authorized"
        case sourceBindingV7Issued = "source_binding_v7_issued"
        case scientificAuthorityAuthorized =
            "scientific_authority_authorized"
        case productAuthorityAuthorized = "product_authority_authorized"
    }
}
