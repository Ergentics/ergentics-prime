import Foundation
import PrimeNativeNeuralGateCorrectedMechanics

/// Exact first-party lineage for the prompt-only semantic adaptation.
///
/// The donor is Ergentics-owned source at a frozen companion revision. This
/// target adapts that grammar into a trap-free, prompt-only leaf; it is not a
/// byte-exact transplant and does not claim model execution, scientific
/// independence, or product authority.
public enum PrimeNativeNeuralGatePromptSolverProvenance {
    public static let rightsHolder = "Ergentics, LLC"
    public static let licenseIdentifier =
        "LicenseRef-Ergentics-Proprietary"
    public static let sourceRemoteURL =
        "https://github.com/Ergentics/pmhnp-companion-ergentics.git"
    public static let sourceRevision =
        "163fc100710ece48119bc25954452d10f6a84f7f"
    public static let sourceTreeOID =
        "9009daa4f8a07fbd5897e00b9571cef44ec292db"
    public static let donorRelativePath =
        "prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsPrimeNativeTextCorpus.swift"
    public static let donorGitBlobOID =
        "b2a087c9410a71f2bc99debade752ff779d7a8a8"
    public static let donorByteCount: UInt64 = 177_032
    public static let donorSHA256 =
        "4758ac2ffc8452614c7eee428333105ac63b0707cb890938d1e42966d3a14210"
    public static let implementationLanguage = "Swift"
    public static let adaptationByteExact = false
    public static let trapBearingDependencyPermitted = false
    public static let independentScientificOracleClaimed = false
    public static let modelExecutionClaimed = false
    public static let productAuthorityClaimed = false
    public static let adaptationDisposition =
        "trap_free_swift_foundation_semantic_adaptation_not_byte_exact_v1"
    public static let claimScope =
        "deterministic_synthetic_prompt_solver_no_model_execution_independent_scientific_oracle_or_product_claim_v1"
}

/// Frozen structural scores emitted by the deterministic prompt solver.
///
/// These values encode only which token the semantic solver selected. They
/// are not probabilities, calibrated scores, losses, source-pinned
/// log-softmax values, or observations from a model.
public enum PrimeNativeNeuralGatePromptSolverSyntheticLogitPolicy {
    public static let structuralEncodingID =
        "prime_prompt_solver_structural_non_probabilistic_full_512_selected_plus_one_unselected_minus_one_v1"
    public static let fullVocabularyLogitCount = 512
    public static let selectedLogitBitPattern:
        UInt32 = 0x3f80_0000
    public static let unselectedLogitBitPattern:
        UInt32 = 0xbf80_0000
    public static let selectedLogit =
        Float(bitPattern: selectedLogitBitPattern)
    public static let unselectedLogit =
        Float(bitPattern: unselectedLogitBitPattern)
    public static let fullVocabularyLogitDigestSerializationID =
        PrimeNativeNeuralGateCorrectedExecutionPolicy
        .fullVocabularyLogitDigestSerializationID
    public static let probabilityEvidenceClaimed = false
    public static let calibrationEvidenceClaimed = false
    public static let lossEvidenceClaimed = false
    public static let
        sourcePinnedFloat32LogSoftmaxEvidenceClaimed = false
    public static let modelEvidenceClaimed = false
}

public enum PrimeNativeNeuralGatePromptSolverError:
    Error,
    Equatable,
    Sendable
{
    case grammarCompilationFailure
    case generatedCompletionExceedsFixedCap
    case invalidGeneratedTokenID(Int)
}

/// Concrete prompt-only semantic executor for one admitted replicate.
///
/// Instance state is limited to the immutable replicate context and immutable
/// grammar. Parsing and evaluation allocate fresh local state for every call.
/// The seed is bound into `PrimeNativeNeuralGateRawExecution`; it does not
/// perturb the exact semantic verifier or create a row-dependent channel.
public struct PrimeNativeNeuralGatePromptOnlyReplicateSolver {
    public let replicateContext:
        PrimeNativeNeuralGateCorrectedReplicateContext
    private let grammar:
        PrimeNativeNeuralGatePromptSolverGrammar

    public init(
        replicateContext:
            PrimeNativeNeuralGateCorrectedReplicateContext
    ) throws {
        self.replicateContext = replicateContext
        do {
            grammar =
                try PrimeNativeNeuralGatePromptSolverGrammar()
        } catch {
            throw PrimeNativeNeuralGatePromptSolverError
                .grammarCompilationFailure
        }
    }

    public func solve(
        _ input:
            PrimeNativeNeuralGatePromptOnlyExecutionInput
    ) throws -> PrimeNativeNeuralGateRawExecution {
        let prompt = try input.decodedCanonicalPrompt()
        let completion: String
        if let answer = grammar.solve(prompt) {
            completion = "Result: \(answer).\n"
        } else {
            completion = "ABSTAIN\n"
        }
        return try rawExecution(
            completion: completion,
            input: input
        )
    }

    private func rawExecution(
        completion: String,
        input:
            PrimeNativeNeuralGatePromptOnlyExecutionInput
    ) throws -> PrimeNativeNeuralGateRawExecution {
        let bytes = Array(completion.utf8)
        let (
            decisionCount,
            countOverflow
        ) = bytes.count.addingReportingOverflow(1)
        guard !countOverflow,
              decisionCount
                <= PrimeNativeNeuralGateCorrectedExecutionPolicy
                .maximumGenerationDecisions
        else {
            throw PrimeNativeNeuralGatePromptSolverError
                .generatedCompletionExceedsFixedCap
        }

        var decisions:
            [PrimeNativeNeuralGateCompletionDecision] = []
        decisions.reserveCapacity(decisionCount)
        for (offset, byte) in bytes.enumerated() {
            let (
                tokenID,
                tokenOverflow
            ) =
                PrimeNativeNeuralGateCorrectedExecutionPolicy
                .byteTokenBase
                .addingReportingOverflow(Int(byte))
            let (
                ordinal,
                ordinalOverflow
            ) = offset.addingReportingOverflow(1)
            guard !tokenOverflow,
                  !ordinalOverflow
            else {
                throw PrimeNativeNeuralGatePromptSolverError
                    .invalidGeneratedTokenID(Int(byte))
            }
            decisions.append(
                try decision(
                    ordinal: ordinal,
                    selectedTokenID: tokenID
                )
            )
        }
        decisions.append(
            try decision(
                ordinal: decisionCount,
                selectedTokenID:
                    PrimeNativeNeuralGateCorrectedExecutionPolicy
                    .endOfSequenceTokenID
            )
        )
        return try PrimeNativeNeuralGateRawExecution
            .validate(
                replicateContext: replicateContext,
                input: input,
                decisions: decisions
            )
    }

    private func decision(
        ordinal: Int,
        selectedTokenID: Int
    ) throws -> PrimeNativeNeuralGateCompletionDecision {
        let count =
            PrimeNativeNeuralGatePromptSolverSyntheticLogitPolicy
            .fullVocabularyLogitCount
        guard (0 ..< count).contains(selectedTokenID)
        else {
            throw PrimeNativeNeuralGatePromptSolverError
                .invalidGeneratedTokenID(selectedTokenID)
        }
        var logits = Array(
            repeating:
                PrimeNativeNeuralGatePromptSolverSyntheticLogitPolicy
                .unselectedLogit,
            count: count
        )
        logits[selectedTokenID] =
            PrimeNativeNeuralGatePromptSolverSyntheticLogitPolicy
            .selectedLogit
        return try PrimeNativeNeuralGateCompletionDecision
            .make(
                ordinal: ordinal,
                fullVocabularyLogits: logits
            )
    }
}
