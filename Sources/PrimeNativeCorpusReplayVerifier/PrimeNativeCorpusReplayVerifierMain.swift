#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif
import Foundation
import PrimeCore
import PrimeNativeCorpusReplay

private struct VerificationSummary: Codable {
    let outcome: String
    let claimScope: String
    let primeSourceRevision: String
    let regeneratedRowCount: Int
    let regradedRowCount: Int
    let probeProcessIdentifier: Int32
    let verifierProcessIdentifier: Int32
    let freshProcessReplayExact: Bool
    let receiptPath: String
    let receiptSHA256: String
    let physicalRowShardsPublished: Bool
    let sameImplementationSemanticEvaluator:
        Bool
    let algorithmicallyIndependentSemanticOracle:
        Bool
    let independentScientificOracleClaimed:
        Bool
    let modelExecutionPerformed: Bool
    let functionalTrainingPerformed: Bool
    let quantizationPerformed: Bool
    let productUseAuthorized: Bool
}

@main
private enum PrimeNativeCorpusReplayVerifierMain {
    static func main() {
        do {
            let arguments =
                try PrimeNativeCorpusReplayArguments
                .parse(CommandLine.arguments)
            let root = try PrimeArtifactRoot(
                directoryURL: arguments.artifactRoot
            )
            let result =
                try PrimeNativeCorpusReplayOverlay
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
                regeneratedRowCount:
                    receipt.regeneratedRowCount,
                regradedRowCount:
                    receipt.regradedRowCount,
                probeProcessIdentifier:
                    receipt.probeProcessIdentifier,
                verifierProcessIdentifier:
                    receipt.verifierProcessIdentifier,
                freshProcessReplayExact:
                    receipt.freshProcessReplayExact,
                receiptPath:
                    result.receiptBinding
                    .relativePath,
                receiptSHA256:
                    result.receiptBinding.sha256,
                physicalRowShardsPublished:
                    receipt
                    .physicalRowShardsPublished,
                sameImplementationSemanticEvaluator:
                    receipt
                    .sameImplementationSemanticEvaluator,
                algorithmicallyIndependentSemanticOracle:
                    receipt
                    .algorithmicallyIndependentSemanticOracle,
                independentScientificOracleClaimed:
                    receipt
                    .independentScientificOracleClaimed,
                modelExecutionPerformed:
                    receipt.modelExecutionPerformed,
                functionalTrainingPerformed:
                    receipt
                    .functionalTrainingPerformed,
                quantizationPerformed:
                    receipt.quantizationPerformed,
                productUseAuthorized:
                    receipt.productUseAuthorized
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
