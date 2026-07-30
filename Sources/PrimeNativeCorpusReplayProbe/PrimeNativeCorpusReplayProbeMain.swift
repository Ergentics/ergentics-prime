#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif
import Foundation
import PrimeCore
import PrimeNativeCorpusReplay

private struct ProbeSummary: Codable {
    let phase: String
    let outcome: String
    let claimScope: String
    let regeneratedRowCount: Int
    let regradedRowCount: Int
    let probeProcessIdentifier: Int32
    let candidatePath: String
    let candidateSHA256: String
    let receiptPublished: Bool
    let algorithmicallyIndependentSemanticOracle:
        Bool
    let independentScientificOracleClaimed:
        Bool
}

@main
private enum PrimeNativeCorpusReplayProbeMain {
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
                .publishCandidate(
                    primeSourceRoot:
                        arguments.primeRoot,
                    to: root
                )
            let summary = ProbeSummary(
                phase: "probe_candidate",
                outcome:
                    "INCOMPLETE_PENDING_FRESH_VERIFIER",
                claimScope:
                    PrimeNativeCorpusReplayPlan
                    .frozenV1.claimScope,
                regeneratedRowCount:
                    result.observation.fullRowCount,
                regradedRowCount:
                    result.observation
                    .acceptedRowCount,
                probeProcessIdentifier:
                    result.candidate
                    .probeProcessIdentifier,
                candidatePath:
                    result.candidateBinding
                    .relativePath,
                candidateSHA256:
                    result.candidateBinding.sha256,
                receiptPublished:
                    result.candidate
                    .receiptPublished,
                algorithmicallyIndependentSemanticOracle:
                    result.observation
                    .algorithmicallyIndependentSemanticOracle,
                independentScientificOracleClaimed:
                    result.observation
                    .independentScientificOracleClaimed
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
