#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif
import Foundation
import PrimeCore

private struct Summary: Codable {
    let outcome: String
    let claimScope: String
    let primeSourceRevision: String
    let companionRevision: String
    let sourcePinCount: Int
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
    let receiptPath: String
    let receiptSHA256: String
    let independentScientificOracleClaimed:
        Bool
}

@main
private enum PrimeNativeGenerationContractProjectionProbeMain {
    static func main() {
        do {
            let arguments =
                try PrimeNativeGenerationContractArguments
                .parse(CommandLine.arguments)
            let adapterRoot = try PrimeArtifactRoot(
                directoryURL: arguments.adapterRoot
            )
            let outputRoot = try PrimeArtifactRoot(
                directoryURL: arguments.artifactRoot
            )
            try adapterRoot.requirePrivateRootMode()
            try outputRoot.requirePrivateRootMode()
            try outputRoot.requireEmpty()

            let sourceState =
                try PrimeNativeGitBlobTransport()
                .sourceState(
                    repositoryRoot:
                        arguments.primeRoot,
                    phase: .preSnapshot
                )
            guard sourceState.clean else {
                throw PrimeNativeGenerationContractOverlayError
                    .invalidReceipt(
                        "Prime source tree is not clean"
                    )
            }
            let sourceSnapshot =
                try PrimeSwiftSourceProvenance
                .capture(
                    at: arguments.primeRoot,
                    requiredRelativePaths:
                        PrimeNativeGenerationContractOverlay
                        .requiredPrimeSourcePaths
                )
            let result =
                try PrimeNativeGenerationContractOverlay
                .publish(
                    adapterRoot: adapterRoot,
                    primeSourceRoot:
                        arguments.primeRoot,
                    primeSourcePreState:
                        sourceState,
                    primeSourceSnapshot:
                        sourceSnapshot,
                    to: outputRoot
                )
            let summary = Summary(
                outcome:
                    result.receipt.outcome.rawValue,
                claimScope:
                    result.receipt.claimScope,
                primeSourceRevision:
                    result.receipt
                    .primeSourceRevision,
                companionRevision:
                    PrimeNativeGenerationContractPlan
                    .frozenV1.companionRevision,
                sourcePinCount:
                    PrimeNativeGenerationContractPlan
                    .frozenV1.sourceBindings.count,
                sourceBlobEvidenceResolvedAtExecution:
                    result.receipt
                    .sourceBlobEvidenceResolvedAtExecution,
                freshVerifierSameSourceIdentityRequired:
                    result.receipt
                    .freshVerifierSameSourceIdentityRequired,
                kvCacheMechanicsProjected:
                    result.receipt
                    .kvCacheMechanicsProjected,
                cacheParityWitnessValuesObserved:
                    result.receipt
                    .cacheParityWitnessValuesObserved,
                fullVocabularyWitnessValuesRecomputedFromLogits:
                    result.receipt
                    .fullVocabularyWitnessValuesRecomputedFromLogits,
                fixedCapEOSGenerationContractBound:
                    result.receipt
                    .fixedCapEOSGenerationContractBound,
                generationBehaviorCompatibilityComplete:
                    result.receipt
                    .generationBehaviorCompatibilityComplete,
                receiptPath:
                    result.receiptBinding
                    .relativePath,
                receiptSHA256:
                    result.receiptBinding.sha256,
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
