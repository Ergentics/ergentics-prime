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
