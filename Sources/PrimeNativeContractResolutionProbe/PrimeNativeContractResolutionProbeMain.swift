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
    let resolvedRevision: String
    let resolvedArtifactCount: Int
    let resolvedByteCount: UInt64
    let receiptPath: String
    let receiptSHA256: String
}

@main
private enum PrimeNativeContractResolutionProbeMain {
    static func main() {
        do {
            let arguments =
                try PrimeNativeContractResolutionArguments
                .parse(CommandLine.arguments)
            let plan =
                PrimeNativeContractMigrationPlan.frozenV1
            try plan.validate()

            let artifactRoot = try PrimeArtifactRoot(
                directoryURL: arguments.artifactRoot
            )
            try artifactRoot.requirePrivateRootMode()
            try artifactRoot.requireEmpty()

            let transport =
                PrimeNativeGitBlobTransport()
            let sourceState = try transport.sourceState(
                repositoryRoot: arguments.primeRoot,
                phase: .preSnapshot
            )
            guard sourceState.clean else {
                throw PrimeNativeContractMigrationError
                    .receiptInvalid(
                        "resolver source tree is not clean"
                    )
            }
            let sourceSnapshot =
                try PrimeSwiftSourceProvenance.capture(
                    at: arguments.primeRoot,
                    requiredRelativePaths:
                        PrimeNativeContractMigrationResolver
                        .requiredResolverSourcePaths
                )
            let input = try transport.resolve(
                companionRoot:
                    arguments.companionRoot
            )
            let result =
                try PrimeNativeContractMigrationResolver
                .publish(
                    input,
                    resolverSourceRoot:
                        arguments.primeRoot,
                    resolverSourcePreState:
                        sourceState,
                    resolverSourceSnapshot:
                        sourceSnapshot,
                    to: artifactRoot
                )
            let summary = Summary(
                outcome: result.receipt.outcome.rawValue,
                claimScope:
                    result.receipt.claimScope,
                resolvedRevision:
                    result.receipt.repository
                        .resolvedRevision,
                resolvedArtifactCount:
                    result.receipt.artifacts.count,
                resolvedByteCount:
                    result.receipt
                        .totalMaterializedByteCount,
                receiptPath:
                    result.receiptBinding.relativePath,
                receiptSHA256:
                    result.receiptBinding.sha256
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
