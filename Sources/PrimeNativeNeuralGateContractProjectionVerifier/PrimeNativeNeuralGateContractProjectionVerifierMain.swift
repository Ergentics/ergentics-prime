#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif
import Foundation
import PrimeCore
import PrimeNativeNeuralGateContract

private struct VerificationSummary: Codable {
    let outcome: String
    let claimScope: String
    let primeSourceRevision: String
    let probeProcessIdentifier: Int32
    let verifierProcessIdentifier: Int32
    let freshProcessReplayExact: Bool
    let sourceContractProjected: Bool
    let historicalMutationCatalogProjected:
        Bool
    let finiteFieldContractVectorComputed:
        Bool
    let sourceBlobBytesResolvedAtExecution:
        Bool
    let invariantRecordsObserved: Bool
    let historicalSemanticMutationsExecuted:
        Bool
    let historicalSZFingerprintRecomputed:
        Bool
    let agentContractKitFourTierAuditPerformed:
        Bool
    let phaseThreeCompatibilityComplete:
        Bool
    let nextMissingPrerequisite: String
    let receiptPath: String
    let receiptSHA256: String

    private enum CodingKeys: String, CodingKey {
        case outcome
        case claimScope = "claim_scope"
        case primeSourceRevision =
            "prime_source_revision"
        case probeProcessIdentifier =
            "probe_process_identifier"
        case verifierProcessIdentifier =
            "verifier_process_identifier"
        case freshProcessReplayExact =
            "fresh_process_replay_exact"
        case sourceContractProjected =
            "source_contract_projected"
        case historicalMutationCatalogProjected =
            "historical_mutation_catalog_projected"
        case finiteFieldContractVectorComputed =
            "finite_field_contract_vector_computed"
        case sourceBlobBytesResolvedAtExecution =
            "source_blob_bytes_resolved_at_execution"
        case invariantRecordsObserved =
            "invariant_records_observed"
        case historicalSemanticMutationsExecuted =
            "historical_semantic_mutations_executed"
        case historicalSZFingerprintRecomputed =
            "historical_sz_fingerprint_recomputed"
        case agentContractKitFourTierAuditPerformed =
            "agent_contract_kit_four_tier_audit_performed"
        case phaseThreeCompatibilityComplete =
            "phase_three_compatibility_complete"
        case nextMissingPrerequisite =
            "next_missing_prerequisite"
        case receiptPath = "receipt_path"
        case receiptSHA256 =
            "receipt_sha256"
    }
}

@main
private enum PrimeNativeNeuralGateContractProjectionVerifierMain {
    static func main() {
        do {
            let arguments =
                try PrimeNativeNeuralGateContractVerifierArguments
                .parse(CommandLine.arguments)
            let root = try PrimeArtifactRoot(
                directoryURL: arguments.artifactRoot
            )
            let result =
                try PrimeNativeNeuralGateContractOverlay
                .verifyAndSeal(
                    primeSourceRoot:
                        arguments.primeRoot,
                    in: root
                )
            let receipt = result.receipt
            let summary = VerificationSummary(
                outcome: receipt.outcome.rawValue,
                claimScope: receipt.claimScope,
                primeSourceRevision:
                    receipt.primeSourceRevision,
                probeProcessIdentifier:
                    receipt.probeProcessIdentifier,
                verifierProcessIdentifier:
                    receipt.verifierProcessIdentifier,
                freshProcessReplayExact:
                    receipt.freshProcessReplayExact,
                sourceContractProjected:
                    receipt.sourceContractProjected,
                historicalMutationCatalogProjected:
                    receipt
                    .historicalMutationCatalogProjected,
                finiteFieldContractVectorComputed:
                    receipt
                    .finiteFieldContractVectorComputed,
                sourceBlobBytesResolvedAtExecution:
                    receipt
                    .sourceBlobBytesResolvedAtExecution,
                invariantRecordsObserved:
                    receipt.invariantRecordsObserved,
                historicalSemanticMutationsExecuted:
                    receipt
                    .historicalSemanticMutationsExecuted,
                historicalSZFingerprintRecomputed:
                    receipt
                    .historicalSZFingerprintRecomputed,
                agentContractKitFourTierAuditPerformed:
                    receipt
                    .agentContractKitFourTierAuditPerformed,
                phaseThreeCompatibilityComplete:
                    receipt
                    .phaseThreeCompatibilityComplete,
                nextMissingPrerequisite:
                    receipt.nextMissingPrerequisite,
                receiptPath:
                    result.receiptBinding
                    .relativePath,
                receiptSHA256:
                    result.receiptBinding.sha256
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
