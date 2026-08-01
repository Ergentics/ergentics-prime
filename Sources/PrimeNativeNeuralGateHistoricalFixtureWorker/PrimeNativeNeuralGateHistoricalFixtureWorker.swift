import Darwin
import ErgenticsPrimeRuntime
import Foundation
import PrimeCore
import PrimeNativeNeuralGateHistoricalReplayMechanics
import PrimeNativeNeuralGateReplayTransport

/// A compiled but deliberately unavailable process boundary for the
/// source-faithful historical fixture.
///
/// V11 binds the fixture, lock file, target graph, and future call edge. It
/// does not execute the trap-bearing fixture or claim that the V10 public
/// observation seam can publish the complete frozen worker artifact set.
@main
enum PrimeNativeNeuralGateHistoricalFixtureWorker {
    static let sourceBoundaryID =
        "prime_source_bound_historical_fixture_worker_v11"

    static let exactCLIArgumentNames = [
        "--artifact-root",
        "--invocation-role",
        "--request-sha256",
    ]

    static let allowedInvocationRoles = [
        "probe",
        "verifier",
    ]

    static let unavailableExitStatus: Int32 = 78

    static func main() {
        Darwin.exit(unavailableExitStatus)
    }

    /// This call edge is source-bound for a later fresh-process worker slice.
    /// It is intentionally unreachable from `main` until a source-derived
    /// exporter can publish every frozen worker artifact without inventing
    /// the gate's private invariant records or mutation evidence.
    private static func reservedHistoricalObservationCallEdge()
        throws
        -> PrimeNativeNeuralGateHistoricalAssessmentSnapshot
    {
        guard let packageResolvedURL = Bundle.module.url(
            forResource: "Package",
            withExtension: "resolved",
            subdirectory: "HistoricalFixtureEvidence"
        ) else {
            throw ReservedCallEdgeError
                .missingPinnedPackageResolved
        }
        let fixture = try
            EngineProposesNativeLanguageVerifyAbstainFixture
            .materialize(
                packageResolvedURL: packageResolvedURL
            )
        return try PrimeNativeNeuralGateHistoricalObservationSeam
            .observe(fixture.materials)
    }

    private static func reservedFrozenWorkerContractCallEdge()
        -> PrimeNativeNeuralGateHistoricalWorkerContract
    {
        .frozenV2
    }

    private enum ReservedCallEdgeError: Error {
        case missingPinnedPackageResolved
    }
}
