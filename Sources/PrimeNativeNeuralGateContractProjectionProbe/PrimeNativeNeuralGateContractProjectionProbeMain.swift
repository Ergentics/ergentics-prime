#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif
import Foundation
import PrimeCore
import PrimeNativeNeuralGateContract

private struct ProbeSummary: Codable {
    let phase: String
    let outcome: String
    let claimScope: String
    let sourcePinCount: Int
    let criticalLegCount: Int
    let historicalMutationContractCount: Int
    let projectionStructuralMutationCount:
        Int
    let finiteFieldContractVectorComputed:
        Bool
    let historicalSemanticMutationsExecuted:
        Bool
    let historicalSZFingerprintRecomputed:
        Bool
    let probeProcessIdentifier: Int32
    let candidatePath: String
    let candidateSHA256: String
    let receiptPublished: Bool

    private enum CodingKeys: String, CodingKey {
        case phase
        case outcome
        case claimScope = "claim_scope"
        case sourcePinCount = "source_pin_count"
        case criticalLegCount =
            "critical_leg_count"
        case historicalMutationContractCount =
            "historical_mutation_contract_count"
        case projectionStructuralMutationCount =
            "projection_structural_mutation_count"
        case finiteFieldContractVectorComputed =
            "finite_field_contract_vector_computed"
        case historicalSemanticMutationsExecuted =
            "historical_semantic_mutations_executed"
        case historicalSZFingerprintRecomputed =
            "historical_sz_fingerprint_recomputed"
        case probeProcessIdentifier =
            "probe_process_identifier"
        case candidatePath = "candidate_path"
        case candidateSHA256 =
            "candidate_sha256"
        case receiptPublished =
            "receipt_published"
    }
}

@main
private enum PrimeNativeNeuralGateContractProjectionProbeMain {
    static func main() {
        do {
            let arguments =
                try PrimeNativeNeuralGateContractArguments
                .parse(CommandLine.arguments)
            let generationRoot =
                try PrimeArtifactRoot(
                    directoryURL:
                        arguments.generationRoot
                )
            let corpusRoot =
                try PrimeArtifactRoot(
                    directoryURL:
                        arguments.corpusReplayRoot
                )
            let outputRoot =
                try PrimeArtifactRoot(
                    directoryURL:
                        arguments.artifactRoot
                )
            let result =
                try PrimeNativeNeuralGateContractOverlay
                .publishCandidate(
                    generationRoot: generationRoot,
                    corpusReplayRoot: corpusRoot,
                    primeSourceRoot:
                        arguments.primeRoot,
                    to: outputRoot
                )
            let observation = result.observation
            let summary = ProbeSummary(
                phase: "probe_candidate",
                outcome:
                    "INCOMPLETE_PENDING_FRESH_VERIFIER",
                claimScope:
                    PrimeNativeNeuralGateContractPlan
                    .frozenV1.claimScope,
                sourcePinCount:
                    observation.sourcePinCount,
                criticalLegCount:
                    observation.criticalLegCount,
                historicalMutationContractCount:
                    observation
                    .historicalMutationContractCount,
                projectionStructuralMutationCount:
                    observation.projectionMutationSweep
                    .count,
                finiteFieldContractVectorComputed:
                    observation
                    .finiteFieldContractVectorComputed,
                historicalSemanticMutationsExecuted:
                    observation
                    .historicalSemanticMutationsExecuted,
                historicalSZFingerprintRecomputed:
                    observation
                    .historicalSZFingerprintRecomputed,
                probeProcessIdentifier:
                    result.candidate
                    .probeProcessIdentifier,
                candidatePath:
                    result.candidateBinding
                    .relativePath,
                candidateSHA256:
                    result.candidateBinding.sha256,
                receiptPublished:
                    result.candidate.receiptPublished
            )
            FileHandle.standardOutput.write(
                try PrimeCanonicalJSON.encode(
                    summary
                )
            )
            FileHandle.standardOutput.write(
                Data([0x0a])
            )
        } catch {
            let message =
                (error as? LocalizedError)?
                .errorDescription
                ?? String(describing: error)
            FileHandle.standardError.write(
                Data(
                    ("ABSTAIN: \(message)\n").utf8
                )
            )
            #if canImport(Darwin)
            Darwin.exit(1)
            #else
            Glibc.exit(1)
            #endif
        }
    }
}
