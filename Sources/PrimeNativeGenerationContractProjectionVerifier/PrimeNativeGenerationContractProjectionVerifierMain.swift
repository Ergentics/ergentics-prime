#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif
import Foundation
import PrimeCore

private struct VerificationSummary: Codable {
    let outcome: String
    let claimScope: String
    let primeSourceRevision: String
    let sourcePinsBound: Bool
    let sourceBlobEvidenceResolvedAtExecution:
        Bool
    let freshVerifierSameSourceIdentityRequired:
        Bool
    let kvCacheMechanicsProjected: Bool
    let cacheParityWitnessValuesObserved: Bool
    let fullVocabularyWitnessValuesRecomputedFromLogits:
        Bool
    let fixedCapEOSGenerationContractBound:
        Bool
    let generationBehaviorCompatibilityComplete:
        Bool
    let phaseThreeCompatibilityComplete:
        Bool
    let receiptPath: String
    let receiptSHA256: String
    let sameSourceFreshProcessPersistenceValidated:
        Bool
    let independentScientificOracleClaimed:
        Bool
}

@main
private enum PrimeNativeGenerationContractProjectionVerifierMain {
    static func main() {
        do {
            let arguments =
                try PrimeNativeGenerationContractVerifierArguments
                .parse(CommandLine.arguments)
            let plan =
                PrimeNativeGenerationContractOverlayPlan
                .frozenV1
            try plan.validate()
            let root = try PrimeArtifactRoot(
                directoryURL: arguments.artifactRoot
            )
            try root.requirePrivateRootMode()
            let receiptBinding =
                try root.bindExisting(
                    at: plan.receiptPath,
                    purpose: .immutableData,
                    maximumByteCount:
                        4 * 1024 * 1024
                )
            let receipt =
                try root.decodeVerified(
                    PrimeNativeGenerationContractOverlayReceipt
                        .self,
                    binding: receiptBinding,
                    maximumByteCount:
                        4 * 1024 * 1024
                )
            try receipt.validate(in: root)
            let rebound =
                try root.bindExisting(
                    at: plan.receiptPath,
                    purpose: .immutableData,
                    maximumByteCount:
                        4 * 1024 * 1024
                )
            guard rebound == receiptBinding else {
                throw PrimeNativeGenerationContractOverlayError
                    .invalidReceipt(
                        "receipt changed during fresh-process validation"
                    )
            }
            let roundTrip =
                try root.decodeVerified(
                    PrimeNativeGenerationContractOverlayReceipt
                        .self,
                    binding: rebound,
                    maximumByteCount:
                        4 * 1024 * 1024
                )
            guard roundTrip == receipt else {
                throw PrimeNativeGenerationContractOverlayError
                    .invalidReceipt(
                        "receipt round trip changed"
                    )
            }
            try roundTrip.validate(in: root)

            let summary = VerificationSummary(
                outcome:
                    roundTrip.outcome.rawValue,
                claimScope:
                    roundTrip.claimScope,
                primeSourceRevision:
                    roundTrip.primeSourceRevision,
                sourcePinsBound:
                    roundTrip.sourcePinsBound,
                sourceBlobEvidenceResolvedAtExecution:
                    roundTrip
                    .sourceBlobEvidenceResolvedAtExecution,
                freshVerifierSameSourceIdentityRequired:
                    roundTrip
                    .freshVerifierSameSourceIdentityRequired,
                kvCacheMechanicsProjected:
                    roundTrip
                    .kvCacheMechanicsProjected,
                cacheParityWitnessValuesObserved:
                    roundTrip
                    .cacheParityWitnessValuesObserved,
                fullVocabularyWitnessValuesRecomputedFromLogits:
                    roundTrip
                    .fullVocabularyWitnessValuesRecomputedFromLogits,
                fixedCapEOSGenerationContractBound:
                    roundTrip
                    .fixedCapEOSGenerationContractBound,
                generationBehaviorCompatibilityComplete:
                    roundTrip
                    .generationBehaviorCompatibilityComplete,
                phaseThreeCompatibilityComplete:
                    roundTrip
                    .phaseThreeCompatibilityComplete,
                receiptPath:
                    rebound.relativePath,
                receiptSHA256:
                    rebound.sha256,
                sameSourceFreshProcessPersistenceValidated:
                    true,
                independentScientificOracleClaimed:
                    false
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
