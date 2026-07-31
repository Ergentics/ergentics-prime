import Foundation
import PrimeNativeNeuralGateReplayMechanics

public enum PrimeNativeNeuralGateCorrectedMechanicsError:
    Error,
    Equatable,
    Sendable
{
    case unadmittedEvaluationSeed
    case emptyPrompt
    case promptTooLarge
    case invalidPromptTokens
    case invalidCorrelationID
    case emptyFixture
    case completionExceedsFixedCap(index: Int)
    case invalidRegradeAuthority
    case invalidDecisionOrdinal
    case invalidDecisionScoreCount
    case nonfiniteDecisionScore
    case invalidDecisionSequence
    case invalidTermination
    case invalidLossRow
    case lossWeightOverflow
    case nonfiniteLossStatistic
    case invalidFixedPromptReplay
    case invalidCapabilityRows
    case invalidCriticalLegs
    case invalidMutationCatalog
    case invalidMutationObservation(String)
}

/// Constants injected by the corrected mechanics implementation.
///
/// They are deliberately absent from the prediction input. In particular,
/// neither a caller-selected budget nor a caller-selected support set can be
/// stored beside a prompt.
public enum PrimeNativeNeuralGateCorrectedExecutionPolicy {
    public static let policyID =
        "prime_stage_b_corrected_replicate_seed_prompt_tokens_only_fixed_cap64_eos_full_vocabulary_logits_v4"
    public static let admittedEvaluationSeeds = [
        1_618,
        2_718,
        3_141,
    ]
    public static let beginningOfSequenceTokenID = 1
    public static let endOfSequenceTokenID = 70
    public static let byteTokenBase = 256
    public static let byteTokenRange = 256 ... 511
    public static let maximumPromptByteCount = 4_096
    public static let maximumGenerationDecisions = 64
    public static let fullVocabularyLogitCount = 512
    public static let probabilityDiagnosticPolicyID =
        "foundation_double_stable_logsumexp_over_float32_full_vocabulary_logits_non_evidentiary_v1"
    public static let fullVocabularyLogitDigestSerializationID =
        "primefvl1_then_512_float32_bit_patterns_uint32_big_endian_in_token_id_order_v1"

    /// EOS is first so an exact score tie terminates rather than inventing a
    /// byte. All 256 byte tokens remain available at every decision.
    public static let orderedCompletionSupport =
        [endOfSequenceTokenID]
            + Array(byteTokenRange)
    fileprivate static let completionSupportSet =
        Set(orderedCompletionSupport)

    public static let supportSerializationID =
        "uint16_big_endian_ordered_token_ids_v1"
    public static let
        orderedCompletionSupportKnownAnswerSHA256 =
        "8ee808dc28f42a6666875a2c89af9da241cce7238e3a32ab769f0a2b7bdefc9b"

    public static var orderedCompletionSupportSHA256:
        String
    {
        var data = Data()
        for tokenID in orderedCompletionSupport {
            appendUInt16(
                UInt16(tokenID),
                to: &data
            )
        }
        return PrimeNativeNeuralGateInvariantCodec
            .sha256(data)
    }

    fileprivate static func appendUInt16(
        _ value: UInt16,
        to data: inout Data
    ) {
        var bigEndian = value.bigEndian
        withUnsafeBytes(of: &bigEndian) {
            data.append(contentsOf: $0)
        }
    }

    fileprivate static func appendUInt32(
        _ value: UInt32,
        to data: inout Data
    ) {
        var bigEndian = value.bigEndian
        withUnsafeBytes(of: &bigEndian) {
            data.append(contentsOf: $0)
        }
    }

    fileprivate static func appendUInt64(
        _ value: UInt64,
        to data: inout Data
    ) {
        var bigEndian = value.bigEndian
        withUnsafeBytes(of: &bigEndian) {
            data.append(contentsOf: $0)
        }
    }
}

/// A pure feasibility observation over caller-provided completion values.
///
/// This is not source-bound fixture admission and cannot establish row
/// identity, completeness, inclusion, or execution authority. The later
/// executor must validate the complete source-derived fixture before any row
/// executes.
public struct PrimeNativeNeuralGateCorrectedCompletionFeasibility:
    Equatable,
    Sendable
{
    public let observedCompletionCount: Int
    public let allValuesCanonicalNFC: Bool
    public let allValuesFitFixedCapWithEOS: Bool

    private init(
        observedCompletionCount: Int,
        allValuesCanonicalNFC: Bool
    ) {
        self.observedCompletionCount =
            observedCompletionCount
        self.allValuesCanonicalNFC =
            allValuesCanonicalNFC
        allValuesFitFixedCapWithEOS = true
    }

    public static func recompute(
        expectedCompletions: [String]
    ) throws -> Self {
        guard !expectedCompletions.isEmpty else {
            throw PrimeNativeNeuralGateCorrectedMechanicsError
                .emptyFixture
        }
        var allCanonical = true
        for (
            index,
            completion
        ) in expectedCompletions.enumerated() {
            let canonical =
                completion
                .precomposedStringWithCanonicalMapping
            allCanonical =
                allCanonical
                && Data(completion.utf8)
                    == Data(canonical.utf8)
            let decisionsRequired =
                canonical.utf8.count + 1
            guard decisionsRequired
                    <= PrimeNativeNeuralGateCorrectedExecutionPolicy
                    .maximumGenerationDecisions
            else {
                throw PrimeNativeNeuralGateCorrectedMechanicsError
                    .completionExceedsFixedCap(
                        index: index
                    )
            }
        }
        return Self(
            observedCompletionCount:
                expectedCompletions.count,
            allValuesCanonicalNFC: allCanonical
        )
    }
}

/// Replicate-scoped evaluation context.
///
/// The seed belongs to the whole replicate, matching the frozen generation
/// shard envelope. A later concrete executor must be initialized once from
/// this value and must not accept a seed in any row-level prediction input.
public struct PrimeNativeNeuralGateCorrectedReplicateContext:
    Equatable,
    Sendable
{
    public let evaluationSeed: Int

    public init(evaluationSeed: Int) throws {
        guard PrimeNativeNeuralGateCorrectedExecutionPolicy
            .admittedEvaluationSeeds
            .contains(evaluationSeed)
        else {
            throw PrimeNativeNeuralGateCorrectedMechanicsError
                .unadmittedEvaluationSeed
        }
        self.evaluationSeed = evaluationSeed
    }
}

/// A candidate row-level executor-visible value.
///
/// Stored shape is the security boundary: it contains only a canonical
/// BOS-plus-byte prompt. Seed is replicate-scoped. Correlation identity,
/// split, family, index, expected output, regrade material, grouping, budget,
/// and termination controls cannot be represented. This live value is
/// intentionally not `Codable`.
public struct PrimeNativeNeuralGatePromptOnlyExecutionInput:
    Equatable,
    Sendable
{
    public let promptTokenIDs: [Int]

    private init(
        promptTokenIDs: [Int]
    ) {
        self.promptTokenIDs = promptTokenIDs
    }

    public static func derive(
        promptText: String
    ) throws -> Self {
        let canonical =
            promptText
            .precomposedStringWithCanonicalMapping
        let bytes = Array(canonical.utf8)
        guard !bytes.isEmpty else {
            throw PrimeNativeNeuralGateCorrectedMechanicsError
                .emptyPrompt
        }
        guard bytes.count
                <= PrimeNativeNeuralGateCorrectedExecutionPolicy
                .maximumPromptByteCount
        else {
            throw PrimeNativeNeuralGateCorrectedMechanicsError
                .promptTooLarge
        }
        return Self(
            promptTokenIDs:
                [
                    PrimeNativeNeuralGateCorrectedExecutionPolicy
                        .beginningOfSequenceTokenID,
                ]
                + bytes.map {
                    Int($0)
                        + PrimeNativeNeuralGateCorrectedExecutionPolicy
                        .byteTokenBase
                }
        )
    }

    public func decodedCanonicalPrompt()
        throws -> String
    {
        guard promptTokenIDs.count > 1,
              promptTokenIDs.first
                == PrimeNativeNeuralGateCorrectedExecutionPolicy
                .beginningOfSequenceTokenID
        else {
            throw PrimeNativeNeuralGateCorrectedMechanicsError
                .invalidPromptTokens
        }
        let body = promptTokenIDs.dropFirst()
        guard body.count
                <= PrimeNativeNeuralGateCorrectedExecutionPolicy
                .maximumPromptByteCount,
              body.allSatisfy(
                  PrimeNativeNeuralGateCorrectedExecutionPolicy
                      .byteTokenRange.contains
              )
        else {
            throw PrimeNativeNeuralGateCorrectedMechanicsError
                .invalidPromptTokens
        }
        let bytes = body.map {
            UInt8(
                $0
                    - PrimeNativeNeuralGateCorrectedExecutionPolicy
                    .byteTokenBase
            )
        }
        guard let text = String(
            data: Data(bytes),
            encoding: .utf8
        ),
              text
                == text
                .precomposedStringWithCanonicalMapping
        else {
            throw PrimeNativeNeuralGateCorrectedMechanicsError
                .invalidPromptTokens
        }
        return text
    }

    public func canonicalBindingData() -> Data {
        var data = Data("PRIMECPI2".utf8)
        PrimeNativeNeuralGateCorrectedExecutionPolicy
            .appendUInt64(
                UInt64(promptTokenIDs.count),
                to: &data
            )
        for tokenID in promptTokenIDs {
            PrimeNativeNeuralGateCorrectedExecutionPolicy
                .appendUInt16(
                    UInt16(tokenID),
                    to: &data
                )
        }
        return data
    }

    public var bindingSHA256: String {
        PrimeNativeNeuralGateInvariantCodec
            .sha256(canonicalBindingData())
    }
}

/// Correlation exists outside the executor-visible value. No execution API in
/// this module accepts this envelope.
public struct PrimeNativeNeuralGateCorrectedCorrelationEnvelope:
    Equatable,
    Sendable
{
    public let correlationID: String
    public let executionInput:
        PrimeNativeNeuralGatePromptOnlyExecutionInput

    public init(
        correlationID: String,
        executionInput:
            PrimeNativeNeuralGatePromptOnlyExecutionInput
    ) throws {
        let bytes = Array(correlationID.utf8)
        guard !bytes.isEmpty,
              bytes.count <= 512,
              bytes.allSatisfy({
                  $0 >= 0x21 && $0 <= 0x7e
              })
        else {
            throw PrimeNativeNeuralGateCorrectedMechanicsError
                .invalidCorrelationID
        }
        self.correlationID = correlationID
        self.executionInput = executionInput
    }
}

public struct PrimeNativeNeuralGateCompletionDecision:
    Equatable,
    Sendable
{
    public let ordinal: Int
    public let fullVocabularyLogits: [Float]

    private init(
        ordinal: Int,
        fullVocabularyLogits: [Float]
    ) {
        self.ordinal = ordinal
        self.fullVocabularyLogits =
            fullVocabularyLogits
    }

    public static func make(
        ordinal: Int,
        fullVocabularyLogits: [Float]
    ) throws -> Self {
        guard (1 ...
            PrimeNativeNeuralGateCorrectedExecutionPolicy
                .maximumGenerationDecisions)
            .contains(ordinal)
        else {
            throw PrimeNativeNeuralGateCorrectedMechanicsError
                .invalidDecisionOrdinal
        }
        guard fullVocabularyLogits.count
                == PrimeNativeNeuralGateCorrectedExecutionPolicy
                .fullVocabularyLogitCount
        else {
            throw PrimeNativeNeuralGateCorrectedMechanicsError
                .invalidDecisionScoreCount
        }
        guard fullVocabularyLogits
            .allSatisfy(\.isFinite)
        else {
            throw PrimeNativeNeuralGateCorrectedMechanicsError
                .nonfiniteDecisionScore
        }
        return Self(
            ordinal: ordinal,
            fullVocabularyLogits:
                fullVocabularyLogits
        )
    }

    public var selectedSupportIndex: Int {
        var selected = 0
        let support =
            PrimeNativeNeuralGateCorrectedExecutionPolicy
            .orderedCompletionSupport
        for index in support.indices
            .dropFirst()
        {
            if fullVocabularyLogits[support[index]]
                > fullVocabularyLogits[
                    support[selected]
                ]
            {
                selected = index
            }
        }
        return selected
    }

    public var selectedTokenID: Int {
        PrimeNativeNeuralGateCorrectedExecutionPolicy
            .orderedCompletionSupport[
                selectedSupportIndex
            ]
    }

    /// A deterministic Foundation/Double diagnostic over Float logits.
    ///
    /// This is deliberately not the frozen source-pinned Float32 log-softmax
    /// value and cannot populate an evidentiary generation artifact.
    public var foundationDoubleSelectedLogProbabilityDiagnostic:
        Double
    {
        logProbability(
            tokenID: selectedTokenID
        )
    }

    public var rawFullVocabularyArgmaxTokenID:
        Int
    {
        var selected = 0
        for index in fullVocabularyLogits.indices
            .dropFirst()
        {
            if fullVocabularyLogits[index]
                > fullVocabularyLogits[selected]
            {
                selected = index
            }
        }
        return selected
    }

    public var rawFullVocabularyAllowedSupportGreedyTokenParity:
        Bool
    {
        rawFullVocabularyArgmaxTokenID
            == selectedTokenID
    }

    public var rawFullVocabularyArgmaxIsDisallowed:
        Bool
    {
        !PrimeNativeNeuralGateCorrectedExecutionPolicy
            .orderedCompletionSupport
            .contains(
                rawFullVocabularyArgmaxTokenID
            )
    }

    /// A deterministic Foundation/Double diagnostic, not the frozen
    /// source-pinned Float32 disallowed-mass witness.
    public var foundationDoubleDisallowedTokenProbabilityMassDiagnostic:
        Double
    {
        let normalization = logNormalization
        return fullVocabularyLogits.indices
            .filter {
                !PrimeNativeNeuralGateCorrectedExecutionPolicy
                    .completionSupportSet
                    .contains($0)
            }
            .reduce(0.0) {
                $0 + Foundation.exp(
                    Double(
                        fullVocabularyLogits[$1]
                    )
                        - normalization
                )
            }
    }

    private var logNormalization: Double {
        let logits =
            fullVocabularyLogits.map(Double.init)
        let maximum = logits.reduce(
            -Double.infinity,
            Swift.max
        )
        let denominator = logits.reduce(0.0) {
            $0 + Foundation.exp($1 - maximum)
        }
        return maximum
            + Foundation.log(denominator)
    }

    private func logProbability(
        tokenID: Int
    ) -> Double {
        Double(fullVocabularyLogits[tokenID])
            - logNormalization
    }

    public func canonicalFullVocabularyLogitData()
        -> Data
    {
        var data = Data("PRIMEFVL1".utf8)
        for logit in fullVocabularyLogits {
            PrimeNativeNeuralGateCorrectedExecutionPolicy
                .appendUInt32(
                    logit.bitPattern,
                    to: &data
                )
        }
        return data
    }

    public var fullVocabularyLogitsSHA256:
        String
    {
        PrimeNativeNeuralGateInvariantCodec
            .sha256(
                canonicalFullVocabularyLogitData()
            )
    }
}

public enum PrimeNativeNeuralGateCorrectedTermination:
    String,
    Equatable,
    Sendable
{
    case eos
    case fixedCap = "fixed_cap"
}

/// A self-consistent, non-evidentiary full-logit decision trace observation.
///
/// It is intentionally not `Codable`. It does not prove where scores came
/// from, that a source-bound solver ran, or that a complete fixture was
/// admitted. Later artifact transport must be decoded and independently
/// recomputed before it can become evidence.
public struct PrimeNativeNeuralGateRawExecution:
    Equatable,
    Sendable
{
    public let replicateContext:
        PrimeNativeNeuralGateCorrectedReplicateContext
    public let input:
        PrimeNativeNeuralGatePromptOnlyExecutionInput
    public let decisions:
        [PrimeNativeNeuralGateCompletionDecision]
    public let generatedTokenIDs: [Int]
    public let termination:
        PrimeNativeNeuralGateCorrectedTermination
    public let outputUTF8: Data
    public let outputText: String?

    private init(
        replicateContext:
            PrimeNativeNeuralGateCorrectedReplicateContext,
        input:
            PrimeNativeNeuralGatePromptOnlyExecutionInput,
        decisions:
            [PrimeNativeNeuralGateCompletionDecision],
        generatedTokenIDs: [Int],
        termination:
            PrimeNativeNeuralGateCorrectedTermination,
        outputUTF8: Data,
        outputText: String?
    ) {
        self.replicateContext = replicateContext
        self.input = input
        self.decisions = decisions
        self.generatedTokenIDs =
            generatedTokenIDs
        self.termination = termination
        self.outputUTF8 = outputUTF8
        self.outputText = outputText
    }

    public static func validate(
        replicateContext:
            PrimeNativeNeuralGateCorrectedReplicateContext,
        input:
            PrimeNativeNeuralGatePromptOnlyExecutionInput,
        decisions:
            [PrimeNativeNeuralGateCompletionDecision]
    ) throws -> Self {
        guard !decisions.isEmpty,
              decisions.count
                <= PrimeNativeNeuralGateCorrectedExecutionPolicy
                .maximumGenerationDecisions,
              decisions.map(\.ordinal)
                == Array(1 ... decisions.count)
        else {
            throw PrimeNativeNeuralGateCorrectedMechanicsError
                .invalidDecisionSequence
        }
        let selected = decisions.map(\.selectedTokenID)
        let eos =
            PrimeNativeNeuralGateCorrectedExecutionPolicy
            .endOfSequenceTokenID
        let eosOrdinals = selected.enumerated()
            .compactMap {
                $0.element == eos
                    ? $0.offset : nil
            }
        let termination:
            PrimeNativeNeuralGateCorrectedTermination
        let generated: [Int]
        if let eosIndex = eosOrdinals.first {
            guard eosOrdinals.count == 1,
                  eosIndex == selected.count - 1
            else {
                throw PrimeNativeNeuralGateCorrectedMechanicsError
                    .invalidTermination
            }
            termination = .eos
            generated = Array(
                selected.prefix(eosIndex)
            )
        } else {
            guard selected.count
                    == PrimeNativeNeuralGateCorrectedExecutionPolicy
                    .maximumGenerationDecisions
            else {
                throw PrimeNativeNeuralGateCorrectedMechanicsError
                    .invalidTermination
            }
            termination = .fixedCap
            generated = selected
        }
        guard generated.allSatisfy(
            PrimeNativeNeuralGateCorrectedExecutionPolicy
                .byteTokenRange.contains
        ) else {
            throw PrimeNativeNeuralGateCorrectedMechanicsError
                .invalidTermination
        }
        let bytes = generated.map {
            UInt8(
                $0
                    - PrimeNativeNeuralGateCorrectedExecutionPolicy
                    .byteTokenBase
            )
        }
        let output = Data(bytes)
        return Self(
            replicateContext: replicateContext,
            input: input,
            decisions: decisions,
            generatedTokenIDs: generated,
            termination: termination,
            outputUTF8: output,
            outputText: String(
                data: output,
                encoding: .utf8
            )
        )
    }

    public var decisionsExecuted: Int {
        decisions.count
    }

    public var rawFullVocabularyAllowedSupportGreedyTokenParity:
        Bool
    {
        decisions.allSatisfy(
            \.rawFullVocabularyAllowedSupportGreedyTokenParity
        )
    }

    public var disallowedFullVocabularyArgmaxCount:
        Int
    {
        decisions.filter(
            \.rawFullVocabularyArgmaxIsDisallowed
        ).count
    }

    /// Local Foundation/Double diagnostic only. The frozen source-pinned
    /// Float32 witness remains unobserved.
    public var maximumFoundationDoubleDisallowedTokenProbabilityMassDiagnostic:
        Double
    {
        decisions.map(
            \.foundationDoubleDisallowedTokenProbabilityMassDiagnostic
        ).max() ?? 0
    }

    public func canonicalTraceData() -> Data {
        var data = Data("PRIMECRT4".utf8)
        let policyID = Data(
            PrimeNativeNeuralGateCorrectedExecutionPolicy
                .policyID.utf8
        )
        PrimeNativeNeuralGateCorrectedExecutionPolicy
            .appendUInt64(
                UInt64(policyID.count),
                to: &data
            )
        data.append(policyID)
        let supportSHA = Data(
            PrimeNativeNeuralGateCorrectedExecutionPolicy
                .orderedCompletionSupportSHA256.utf8
        )
        PrimeNativeNeuralGateCorrectedExecutionPolicy
            .appendUInt64(
                UInt64(supportSHA.count),
                to: &data
            )
        data.append(supportSHA)
        PrimeNativeNeuralGateCorrectedExecutionPolicy
            .appendUInt64(
                UInt64(
                    replicateContext
                        .evaluationSeed
                ),
                to: &data
            )
        let inputData = input.canonicalBindingData()
        PrimeNativeNeuralGateCorrectedExecutionPolicy
            .appendUInt64(
                UInt64(inputData.count),
                to: &data
            )
        data.append(inputData)
        PrimeNativeNeuralGateCorrectedExecutionPolicy
            .appendUInt64(
                UInt64(decisions.count),
                to: &data
            )
        for decision in decisions {
            PrimeNativeNeuralGateCorrectedExecutionPolicy
                .appendUInt32(
                    UInt32(decision.ordinal),
                    to: &data
                )
            let digest = Data(
                decision
                    .fullVocabularyLogitsSHA256
                    .utf8
            )
            PrimeNativeNeuralGateCorrectedExecutionPolicy
                .appendUInt64(
                    UInt64(digest.count),
                    to: &data
                )
            data.append(digest)
        }
        return data
    }

    public var traceSHA256: String {
        PrimeNativeNeuralGateInvariantCodec
            .sha256(canonicalTraceData())
    }

    public func invariantRecords() -> [String] {
        var records = [
            "input_sha256=\(input.bindingSHA256)",
            "trace_sha256=\(traceSHA256)",
            "termination=\(termination.rawValue)",
            "decisions=\(decisions.count)",
            "output_hex=\(outputUTF8.map { String(format: "%02x", $0) }.joined())",
        ]
        records.append(
            "decision_logit_manifest="
                + decisions.map { decision in
                    "\(decision.ordinal):\(decision.selectedTokenID):\(decision.rawFullVocabularyArgmaxTokenID):\(decision.fullVocabularyLogitsSHA256)"
                }
                .joined(separator: ",")
        )
        records.append(
            "full_vocabulary_structural_witness="
                + "allowed_raw_parity=\(rawFullVocabularyAllowedSupportGreedyTokenParity)"
                + "|disallowed_argmax_count=\(disallowedFullVocabularyArgmaxCount)"
        )
        return records
    }
}

public enum PrimeNativeNeuralGateObservedTruth:
    String,
    Codable,
    Equatable,
    Sendable
{
    case unavailable
    case observedFalse = "observed_false"
    case observedTrue = "observed_true"
}

/// Target-bearing material rejoins only after raw execution exists.
public struct PrimeNativeNeuralGatePostExecutionRegradeMaterial:
    Equatable,
    Sendable
{
    public let rawExpectedCompletionUTF8: Data
    public let canonicalExpectedCompletionUTF8:
        Data

    public init(
        expectedCompletion: String
    ) throws {
        let canonical =
            expectedCompletion
            .precomposedStringWithCanonicalMapping
        guard canonical.utf8.count + 1
                <= PrimeNativeNeuralGateCorrectedExecutionPolicy
                .maximumGenerationDecisions
        else {
            throw PrimeNativeNeuralGateCorrectedMechanicsError
                .invalidRegradeAuthority
        }
        rawExpectedCompletionUTF8 =
            Data(expectedCompletion.utf8)
        canonicalExpectedCompletionUTF8 =
            Data(canonical.utf8)
    }
}

public struct PrimeNativeNeuralGatePredictionRegradeObservation:
    Equatable,
    Sendable
{
    public let rawExecutionSHA256: String
    public let outputUTF8Valid: Bool
    public let exactMatch: Bool
    public let predictedAbstention: Bool
    public let semanticMatch:
        PrimeNativeNeuralGateObservedTruth

    public static func recompute(
        execution:
            PrimeNativeNeuralGateRawExecution,
        material:
            PrimeNativeNeuralGatePostExecutionRegradeMaterial
    ) -> Self {
        let canonicalOutputUTF8 =
            execution.outputText.map {
                Data(
                    $0
                    .precomposedStringWithCanonicalMapping
                    .utf8
                )
            }
        return Self(
            rawExecutionSHA256:
                execution.traceSHA256,
            outputUTF8Valid:
                execution.outputText != nil,
            exactMatch:
                execution.termination == .eos
                && canonicalOutputUTF8
                    == material
                    .canonicalExpectedCompletionUTF8,
            predictedAbstention:
                canonicalOutputUTF8
                    == Data("ABSTAIN\n".utf8),
            semanticMatch: .unavailable
        )
    }
}

public struct PrimeNativeNeuralGateWeightedLossRow:
    Equatable,
    Sendable
{
    public let targetTokenCount: Int
    public let crossEntropyBefore: Double
    public let crossEntropyAfter: Double

    public init(
        targetTokenCount: Int,
        crossEntropyBefore: Double,
        crossEntropyAfter: Double
    ) throws {
        guard targetTokenCount > 0,
              crossEntropyBefore.isFinite,
              crossEntropyBefore > 0,
              crossEntropyAfter.isFinite,
              crossEntropyAfter >= 0
        else {
            throw PrimeNativeNeuralGateCorrectedMechanicsError
                .invalidLossRow
        }
        self.targetTokenCount = targetTokenCount
        self.crossEntropyBefore =
            crossEntropyBefore
        self.crossEntropyAfter =
            crossEntropyAfter
    }
}

public struct PrimeNativeNeuralGateWeightedLossStatistics:
    Equatable,
    Sendable
{
    public let rowCount: Int
    public let totalTargetTokenCount: Int
    public let weightedMeanBefore: Double
    public let weightedMeanAfter: Double
    public let effectiveRows: Double
    public let unbiasedVarianceDenominator:
        Double
    public let weightedVarianceAfter: Double
    public let standardErrorAfter: Double

    public static func recompute(
        rows: [PrimeNativeNeuralGateWeightedLossRow]
    ) throws -> Self {
        guard !rows.isEmpty else {
            throw PrimeNativeNeuralGateCorrectedMechanicsError
                .invalidLossRow
        }
        var total = 0
        for row in rows {
            let addition = total.addingReportingOverflow(
                row.targetTokenCount
            )
            guard !addition.overflow else {
                throw PrimeNativeNeuralGateCorrectedMechanicsError
                    .lossWeightOverflow
            }
            total = addition.partialValue
        }
        let totalWeight = Double(total)
        let before = rows.reduce(0.0) {
            $0
                + $1.crossEntropyBefore
                * Double($1.targetTokenCount)
        } / totalWeight
        let after = rows.reduce(0.0) {
            $0
                + $1.crossEntropyAfter
                * Double($1.targetTokenCount)
        } / totalWeight
        let weightSquared = rows.reduce(0.0) {
            let weight =
                Double($1.targetTokenCount)
            return $0 + weight * weight
        }
        let effectiveRows =
            totalWeight * totalWeight
            / Swift.max(1, weightSquared)
        let denominator =
            totalWeight
            - weightSquared
            / Swift.max(1, totalWeight)
        let squaredDeviation = rows.reduce(0.0) {
            let delta =
                $1.crossEntropyAfter - after
            return $0
                + Double($1.targetTokenCount)
                * delta * delta
        }
        let variance =
            denominator > 0
            ? squaredDeviation / denominator
            : 0
        let standardError =
            Foundation.sqrt(
                variance
                    / Swift.max(1, effectiveRows)
            )
        let values = [
            before,
            after,
            effectiveRows,
            denominator,
            variance,
            standardError,
        ]
        guard values.allSatisfy(\.isFinite)
        else {
            throw PrimeNativeNeuralGateCorrectedMechanicsError
                .nonfiniteLossStatistic
        }
        return Self(
            rowCount: rows.count,
            totalTargetTokenCount: total,
            weightedMeanBefore: before,
            weightedMeanAfter: after,
            effectiveRows: effectiveRows,
            unbiasedVarianceDenominator:
                denominator,
            weightedVarianceAfter: variance,
            standardErrorAfter: standardError
        )
    }
}

public struct PrimeNativeNeuralGateFixedPromptReplayObservation:
    Equatable,
    Sendable
{
    public let logitCount: Int
    public let firstGreedyTokenID: Int
    public let replayGreedyTokenID: Int
    public let firstRunnerUpMargin: Double
    public let replayRunnerUpMargin: Double
    public let maximumAbsoluteLogitDelta:
        Double
    public let greedyTokenStable: Bool
    public let behavioralReplayExact: Bool
    public let bitwiseReplayExact: Bool

    public static func recompute(
        firstFloatBitPatterns: [UInt32],
        replayFloatBitPatterns: [UInt32]
    ) throws -> Self {
        guard firstFloatBitPatterns.count
                == PrimeNativeNeuralGateCorrectedExecutionPolicy
                .fullVocabularyLogitCount,
              firstFloatBitPatterns.count
                == replayFloatBitPatterns.count
        else {
            throw PrimeNativeNeuralGateCorrectedMechanicsError
                .invalidFixedPromptReplay
        }
        let first =
            firstFloatBitPatterns.map {
                Float(bitPattern: $0)
            }
        let replay =
            replayFloatBitPatterns.map {
                Float(bitPattern: $0)
            }
        guard first.allSatisfy(\.isFinite),
              replay.allSatisfy(\.isFinite)
        else {
            throw PrimeNativeNeuralGateCorrectedMechanicsError
                .invalidFixedPromptReplay
        }
        func greedyIndex(_ values: [Float])
            -> Int
        {
            var selected = 0
            for index in values.indices.dropFirst() {
                if values[index] > values[selected] {
                    selected = index
                }
            }
            return selected
        }
        func runnerUp(
            _ values: [Float],
            excluding index: Int
        ) -> Float {
            var result = -Float.infinity
            for candidate in values.indices
                where candidate != index
            {
                result = Swift.max(
                    result,
                    values[candidate]
                )
            }
            return result
        }
        let firstGreedy = greedyIndex(first)
        let replayGreedy = greedyIndex(replay)
        let firstMargin =
            Double(first[firstGreedy])
                - Double(
                    runnerUp(
                        first,
                        excluding: firstGreedy
                    )
                )
        let replayMargin =
            Double(replay[replayGreedy])
                - Double(
                    runnerUp(
                        replay,
                        excluding: replayGreedy
                    )
                )
        let maximumDelta = zip(first, replay)
            .map {
                abs(
                    Double($0.0)
                        - Double($0.1)
                )
            }
            .max() ?? 0
        let stable =
            firstGreedy == replayGreedy
        let doubledDelta = 2 * maximumDelta
        let behavioral =
            maximumDelta.isFinite
            && firstMargin.isFinite
            && replayMargin.isFinite
            && firstMargin > 0
            && replayMargin > 0
            && stable
            && doubledDelta.isFinite
            && doubledDelta
                < Swift.min(
                    firstMargin,
                    replayMargin
                )
        return Self(
            logitCount: first.count,
            firstGreedyTokenID: firstGreedy,
            replayGreedyTokenID: replayGreedy,
            firstRunnerUpMargin: firstMargin,
            replayRunnerUpMargin:
                replayMargin,
            maximumAbsoluteLogitDelta:
                maximumDelta,
            greedyTokenStable: stable,
            behavioralReplayExact: behavioral,
            bitwiseReplayExact:
                firstFloatBitPatterns
                == replayFloatBitPatterns
        )
    }
}

public enum PrimeNativeNeuralGateCapabilitySplit:
    String,
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

    public var requiredRowCount: Int {
        switch self {
        case .validation,
             .combinationHoldout,
             .outOfDistribution,
             .mutation:
            4_096
        case .abstention:
            2_048
        }
    }

    public var minimumCorrectedExactAccuracy:
        Double?
    {
        switch self {
        case .validation:
            nil
        case .combinationHoldout,
             .mutation:
            0.80
        case .outOfDistribution:
            0.70
        case .abstention:
            1
        }
    }

    public var correctedMustStrictlyImprove:
        Bool
    {
        self != .validation
    }
}

public struct PrimeNativeNeuralGateCapabilityRow:
    Equatable,
    Sendable
{
    public let split:
        PrimeNativeNeuralGateCapabilitySplit
    public let zeroShotExact: Bool
    public let correctedExact: Bool
    public let expectedAbstention: Bool
    public let correctedAbstention: Bool

    public init(
        split:
            PrimeNativeNeuralGateCapabilitySplit,
        zeroShotExact: Bool,
        correctedExact: Bool,
        expectedAbstention: Bool = false,
        correctedAbstention: Bool = false
    ) {
        self.split = split
        self.zeroShotExact = zeroShotExact
        self.correctedExact = correctedExact
        self.expectedAbstention =
            expectedAbstention
        self.correctedAbstention =
            correctedAbstention
    }
}

public struct PrimeNativeNeuralGateCapabilitySplitObservation:
    Equatable,
    Sendable
{
    public let split:
        PrimeNativeNeuralGateCapabilitySplit
    public let rowCount: Int
    public let zeroShotExactAccuracy: Double
    public let correctedExactAccuracy: Double
    public let thresholdSatisfied: Bool
}

public struct PrimeNativeNeuralGateCapabilityObservation:
    Equatable,
    Sendable
{
    public let totalRowCount: Int
    public let splits:
        [PrimeNativeNeuralGateCapabilitySplitObservation]
    public let thresholdsSatisfied: Bool
    public let sourceBoundRowIdentityAndCoverageEstablished:
        Bool
    public let modelCapability:
        PrimeNativeNeuralGateObservedTruth

    public static func recompute(
        rows: [PrimeNativeNeuralGateCapabilityRow]
    ) throws -> Self {
        var observations: [
            PrimeNativeNeuralGateCapabilitySplitObservation
        ] = []
        for split in
            PrimeNativeNeuralGateCapabilitySplit
            .allCases
        {
            let splitRows =
                rows.filter { $0.split == split }
            guard splitRows.count
                    == split.requiredRowCount
            else {
                throw PrimeNativeNeuralGateCorrectedMechanicsError
                    .invalidCapabilityRows
            }
            let rowCount = splitRows.count
            let zero =
                Double(
                    splitRows.filter(\.zeroShotExact)
                        .count
                )
                / Double(rowCount)
            let corrected =
                Double(
                    splitRows.filter(\.correctedExact)
                        .count
                )
                / Double(rowCount)
            var passes =
                split.minimumCorrectedExactAccuracy
                .map { corrected >= $0 }
                ?? true
            if split.correctedMustStrictlyImprove {
                passes =
                    passes && corrected > zero
            }
            if split == .abstention {
                passes = passes
                    && splitRows.allSatisfy {
                        $0.expectedAbstention
                            && $0.correctedAbstention
                            && $0.correctedExact
                    }
            }
            observations.append(
                .init(
                    split: split,
                    rowCount: rowCount,
                    zeroShotExactAccuracy: zero,
                    correctedExactAccuracy:
                        corrected,
                    thresholdSatisfied: passes
                )
            )
        }
        let expectedTotal =
            PrimeNativeNeuralGateCapabilitySplit
            .allCases
            .map(\.requiredRowCount)
            .reduce(0, +)
        guard rows.count == expectedTotal else {
            throw PrimeNativeNeuralGateCorrectedMechanicsError
                .invalidCapabilityRows
        }
        return Self(
            totalRowCount: rows.count,
            splits: observations,
            thresholdsSatisfied:
                observations.allSatisfy(
                    \.thresholdSatisfied
                ),
            sourceBoundRowIdentityAndCoverageEstablished:
                false,
            modelCapability: .unavailable
        )
    }
}

public struct PrimeNativeNeuralGateCriticalLegObservation:
    Equatable,
    Sendable
{
    public let legID: String
    public let passed: Bool
    public let detail: String

    public init(
        legID: String,
        passed: Bool,
        detail: String
    ) {
        self.legID = legID
        self.passed = passed
        self.detail = detail
    }
}

public enum PrimeNativeNeuralGateMechanicsOutcome:
    String,
    Equatable,
    Sendable
{
    case grounded = "GROUNDED"
    case abstain = "ABSTAIN"
}

public struct PrimeNativeNeuralGateCountDerivedVerdict:
    Equatable,
    Sendable
{
    public static let orderedCriticalLegIDs = [
        "NL1_canonical_material_reload",
        "NL2_finite_field_sz_pool_expansion",
        "NL3_foundation_tokenizer_corpus_regrade",
        "NL4_raw_executor_row_regrade",
        "NL5_causal_training_mechanics",
        "NL6_checkpoint_durability",
        "NL7_same_seed_initialization_training_result_replay",
        "NL8_frozen_exact_seed_consensus",
        "NL9_capability_and_malformed_abstention",
        "NL10_mutation_synthesis",
    ]

    public let legs:
        [PrimeNativeNeuralGateCriticalLegObservation]
    public let passingCount: Int
    public let countDerivedLabel: String
    public let mechanicsOutcome:
        PrimeNativeNeuralGateMechanicsOutcome
    public let modelCapability:
        PrimeNativeNeuralGateObservedTruth
    public let sourceBoundCriticalLegEvidenceEstablished:
        Bool
    public let distinctImplementationFamiliesEstablished:
        Bool
    public let agentContractKitFourTierAuditPerformed:
        Bool

    public static func recompute(
        legs:
            [PrimeNativeNeuralGateCriticalLegObservation]
    ) throws -> Self {
        guard legs.map(\.legID)
                == orderedCriticalLegIDs,
              Set(legs.map(\.legID)).count
                == orderedCriticalLegIDs.count
        else {
            throw PrimeNativeNeuralGateCorrectedMechanicsError
                .invalidCriticalLegs
        }
        let count = legs.filter(\.passed).count
        let label =
            count >= 3
            ? "independentThreePlus(\(count))"
            : "oracleDerived(\(count))"
        return Self(
            legs: legs,
            passingCount: count,
            countDerivedLabel: label,
            mechanicsOutcome:
                count == orderedCriticalLegIDs.count
                ? .grounded : .abstain,
            modelCapability: .unavailable,
            sourceBoundCriticalLegEvidenceEstablished:
                false,
            distinctImplementationFamiliesEstablished:
                false,
            agentContractKitFourTierAuditPerformed:
                false
        )
    }
}

public enum PrimeNativeNeuralGateCorrectedMutationID:
    String,
    CaseIterable,
    Equatable,
    Sendable
{
    case targetValueChangesRawExecution =
        "target_value_changes_raw_execution"
    case targetLengthChangesRawExecution =
        "target_length_changes_raw_execution"
    case expectedCompletionInjectedIntoPrediction =
        "expected_completion_injected_into_prediction"
    case targetDependentPromptGrouping =
        "target_dependent_prompt_grouping"
    case targetDependentDecisionBudget =
        "target_dependent_decision_budget"
    case eosUnavailableAtDecision =
        "eos_unavailable_at_decision"
    case completionSupportNarrowed =
        "completion_support_narrowed"
    case fixedCapDrift = "fixed_cap_drift"
    case targetDependentTermination =
        "target_dependent_termination"
    case targetDependentRowInclusion =
        "target_dependent_row_inclusion"
    case correlationRowIDInjectedIntoPrediction =
        "correlation_row_id_injected_into_prediction"
    case correlationSplitInjectedIntoPrediction =
        "correlation_split_injected_into_prediction"
    case correlationSemanticFamilyInjectedIntoPrediction =
        "correlation_semantic_family_injected_into_prediction"
    case rowDependentEvaluationSeed =
        "row_dependent_evaluation_seed"
    case retainedStateChangesPermutedRowTrace =
        "retained_state_changes_permuted_row_trace"

    public var expectedFailedLeg: String {
        switch self {
        case .targetValueChangesRawExecution:
            "corrected_target_value_independence"
        case .targetLengthChangesRawExecution:
            "corrected_target_length_independence"
        case .expectedCompletionInjectedIntoPrediction,
             .correlationRowIDInjectedIntoPrediction,
             .correlationSplitInjectedIntoPrediction,
             .correlationSemanticFamilyInjectedIntoPrediction:
            "corrected_prediction_input_exclusion"
        case .targetDependentPromptGrouping:
            "corrected_prompt_grouping"
        case .targetDependentDecisionBudget:
            "corrected_decision_budget"
        case .eosUnavailableAtDecision:
            "corrected_eos_availability"
        case .completionSupportNarrowed:
            "corrected_completion_support"
        case .fixedCapDrift:
            "corrected_fixed_cap"
        case .targetDependentTermination:
            "corrected_termination_independence"
        case .targetDependentRowInclusion:
            "corrected_row_inclusion_independence"
        case .rowDependentEvaluationSeed:
            "corrected_replicate_seed_scope"
        case .retainedStateChangesPermutedRowTrace:
            "corrected_row_order_state_independence"
        }
    }
}

public struct PrimeNativeNeuralGateCorrectedMutationObservation:
    Equatable,
    Sendable
{
    public let mutationID:
        PrimeNativeNeuralGateCorrectedMutationID
    public let expectedFailedLeg: String
    public let baselineGlobalSHA256: String
    public let mutatedGlobalSHA256: String
    public let restoredGlobalSHA256: String
    public let baselineFingerprint:
        PrimeNativeNeuralGateFingerprint
    public let mutatedFingerprint:
        PrimeNativeNeuralGateFingerprint
    public let restoredFingerprint:
        PrimeNativeNeuralGateFingerprint
    public let callerReportedExpectedLegFailure:
        Bool
    public let independentMutationExecutionObserved:
        Bool
    public let independentDetectorObserved: Bool
    public let rawRecordsDiverged: Bool
    public let fingerprintDiverged: Bool
    public let rawRecordsRestoredExactly: Bool
    public let fingerprintRestoredExactly: Bool

    public static func recompute(
        mutationID:
            PrimeNativeNeuralGateCorrectedMutationID,
        baselineRecords: [String],
        mutatedRecords: [String],
        restoredRecords: [String],
        observedFailedLegIDs: [String]
    ) throws -> Self {
        let baseline =
            try PrimeNativeNeuralGateInvariantCodec
            .makeBundle(
                records:
                    baselineRecords.map {
                        Data($0.utf8)
                    }
            )
        let mutated =
            try PrimeNativeNeuralGateInvariantCodec
            .makeBundle(
                records:
                    mutatedRecords.map {
                        Data($0.utf8)
                    }
            )
        let restored =
            try PrimeNativeNeuralGateInvariantCodec
            .makeBundle(
                records:
                    restoredRecords.map {
                        Data($0.utf8)
                    }
            )
        let baselineFingerprint =
            baseline.fingerprintObservation.direct
        let mutatedFingerprint =
            mutated.fingerprintObservation.direct
        let restoredFingerprint =
            restored.fingerprintObservation.direct
        let expected = mutationID.expectedFailedLeg
        let observation = Self(
            mutationID: mutationID,
            expectedFailedLeg: expected,
            baselineGlobalSHA256:
                baseline.manifest
                .globalStreamSHA256,
            mutatedGlobalSHA256:
                mutated.manifest
                .globalStreamSHA256,
            restoredGlobalSHA256:
                restored.manifest
                .globalStreamSHA256,
            baselineFingerprint:
                baselineFingerprint,
            mutatedFingerprint:
                mutatedFingerprint,
            restoredFingerprint:
                restoredFingerprint,
            callerReportedExpectedLegFailure:
                observedFailedLegIDs
                .contains(expected),
            independentMutationExecutionObserved:
                false,
            independentDetectorObserved: false,
            rawRecordsDiverged:
                baseline.globalStream
                    != mutated.globalStream,
            fingerprintDiverged:
                baselineFingerprint
                    != mutatedFingerprint,
            rawRecordsRestoredExactly:
                baseline.globalStream
                    == restored.globalStream,
            fingerprintRestoredExactly:
                baselineFingerprint
                    == restoredFingerprint
        )
        try observation.validate()
        return observation
    }

    public func validate() throws {
        guard expectedFailedLeg
                == mutationID.expectedFailedLeg,
              callerReportedExpectedLegFailure,
              !independentMutationExecutionObserved,
              !independentDetectorObserved,
              rawRecordsDiverged,
              baselineGlobalSHA256
                != mutatedGlobalSHA256,
              fingerprintDiverged,
              baselineFingerprint
                != mutatedFingerprint,
              rawRecordsRestoredExactly,
              baselineGlobalSHA256
                == restoredGlobalSHA256,
              fingerprintRestoredExactly,
              baselineFingerprint
                == restoredFingerprint
        else {
            throw PrimeNativeNeuralGateCorrectedMechanicsError
                .invalidMutationObservation(
                    mutationID.rawValue
                )
        }
    }
}

public struct PrimeNativeNeuralGateCorrectedMutationSweepObservation:
    Equatable,
    Sendable
{
    public let observations:
        [PrimeNativeNeuralGateCorrectedMutationObservation]
    public let catalogComplete: Bool

    public static func recompute(
        observations:
            [PrimeNativeNeuralGateCorrectedMutationObservation]
    ) throws -> Self {
        guard observations.map(\.mutationID)
                == PrimeNativeNeuralGateCorrectedMutationID
                .allCases
        else {
            throw PrimeNativeNeuralGateCorrectedMechanicsError
                .invalidMutationCatalog
        }
        try observations.forEach {
            try $0.validate()
        }
        return Self(
            observations: observations,
            catalogComplete: true
        )
    }
}
