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
    let resolverSourceRevision: String
    let companionRevision: String
    let resolvedArtifactCount: Int
    let resolvedByteCount: UInt64
    let receiptPath: String
    let receiptSHA256: String
    let freshProcessPersistenceValidated: Bool
    let independentScientificOracleClaimed: Bool
}

@main
private enum PrimeNativeContractResolutionVerifierMain {
    static func main() {
        do {
            let arguments =
                try PrimeNativeContractResolutionVerifierArguments
                .parse(CommandLine.arguments)
            let plan =
                PrimeNativeContractMigrationPlan.frozenV1
            try plan.validate()
            let root = try PrimeArtifactRoot(
                directoryURL: arguments.artifactRoot
            )
            try root.requirePrivateRootMode()
            let receiptBinding = try root.bindExisting(
                at: plan.outputReceiptPath,
                purpose: .immutableData,
                maximumByteCount: 4 * 1024 * 1024
            )
            let receipt = try root.decodeVerified(
                PrimeNativeContractMigrationReceipt.self,
                binding: receiptBinding,
                maximumByteCount: 4 * 1024 * 1024
            )
            try receipt.validate(in: root)
            let rebound = try root.bindExisting(
                at: plan.outputReceiptPath,
                purpose: .immutableData,
                maximumByteCount: 4 * 1024 * 1024
            )
            guard rebound == receiptBinding else {
                throw PrimeNativeContractMigrationError
                    .receiptInvalid(
                        "receipt changed during fresh-process validation"
                    )
            }
            let roundTrip = try root.decodeVerified(
                PrimeNativeContractMigrationReceipt.self,
                binding: rebound,
                maximumByteCount: 4 * 1024 * 1024
            )
            guard roundTrip == receipt else {
                throw PrimeNativeContractMigrationError
                    .receiptInvalid(
                        "receipt round trip changed"
                    )
            }
            try roundTrip.validate(in: root)

            let summary = VerificationSummary(
                outcome: roundTrip.outcome.rawValue,
                claimScope: roundTrip.claimScope,
                resolverSourceRevision:
                    roundTrip.resolverSourceRevision,
                companionRevision:
                    roundTrip.repository.resolvedRevision,
                resolvedArtifactCount:
                    roundTrip.artifacts.count,
                resolvedByteCount:
                    roundTrip.totalMaterializedByteCount,
                receiptPath: rebound.relativePath,
                receiptSHA256: rebound.sha256,
                freshProcessPersistenceValidated: true,
                independentScientificOracleClaimed: false
            )
            FileHandle.standardOutput.write(
                try PrimeCanonicalJSON.encode(summary)
            )
            FileHandle.standardOutput.write(Data([0x0a]))
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
