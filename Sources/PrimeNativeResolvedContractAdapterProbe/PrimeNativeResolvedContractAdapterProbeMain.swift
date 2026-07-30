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
    let adapterSourceRevision: String
    let companionRevision: String
    let tokenizerReplayProbeCount: Int
    let corpusRowCountDeclared: Int
    let phaseThreeCompatibilityComplete: Bool
    let receiptPath: String
    let receiptSHA256: String
    let independentScientificOracleClaimed: Bool
}

@main
private enum PrimeNativeResolvedContractAdapterProbeMain {
    static func main() {
        do {
            let arguments =
                try PrimeNativeResolvedContractArguments
                .parse(CommandLine.arguments)
            let plan =
                PrimeNativeResolvedContractAdapterPlan
                .frozenV1
            try plan.validate()

            let resolutionRoot = try PrimeArtifactRoot(
                directoryURL: arguments.resolutionRoot
            )
            let outputRoot = try PrimeArtifactRoot(
                directoryURL: arguments.artifactRoot
            )
            try outputRoot.requirePrivateRootMode()
            try outputRoot.requireEmpty()

            let sourceState =
                try PrimeNativeGitBlobTransport()
                .sourceState(
                    repositoryRoot: arguments.primeRoot,
                    phase: .preSnapshot
                )
            guard sourceState.clean else {
                throw PrimeNativeResolvedContractAdapterError
                    .invalidReceipt(
                        "adapter source tree is not clean"
                    )
            }
            let sourceSnapshot =
                try PrimeSwiftSourceProvenance.capture(
                    at: arguments.primeRoot,
                    requiredRelativePaths:
                        PrimeNativeResolvedContractAdapter
                        .requiredAdapterSourcePaths
                )
            let result =
                try PrimeNativeResolvedContractAdapter
                .publish(
                    resolutionRoot: resolutionRoot,
                    adapterSourceRoot:
                        arguments.primeRoot,
                    adapterSourcePreState:
                        sourceState,
                    adapterSourceSnapshot:
                        sourceSnapshot,
                    to: outputRoot
                )
            let projection =
                try outputRoot.decodeVerified(
                    PrimeNativeResolvedContractProjection
                        .self,
                    binding:
                        result.receipt
                        .compatibilityProjection
                )
            let summary = Summary(
                outcome:
                    result.receipt.outcome.rawValue,
                claimScope:
                    result.receipt.claimScope,
                adapterSourceRevision:
                    result.receipt
                    .adapterSourceRevision,
                companionRevision:
                    result.receipt.plan
                    .companionRevision,
                tokenizerReplayProbeCount:
                    projection
                    .tokenizerReplayProbeIDs.count,
                corpusRowCountDeclared:
                    projection.totalUniqueRowCount,
                phaseThreeCompatibilityComplete:
                    result.receipt
                    .phaseThreeCompatibilityComplete,
                receiptPath:
                    result.receiptBinding.relativePath,
                receiptSHA256:
                    result.receiptBinding.sha256,
                independentScientificOracleClaimed:
                    false
            )
            FileHandle.standardOutput.write(
                try PrimeCanonicalJSON.encode(summary)
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
