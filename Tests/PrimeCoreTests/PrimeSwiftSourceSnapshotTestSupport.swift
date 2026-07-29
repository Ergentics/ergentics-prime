import Foundation
@testable import PrimeCore

enum PrimeSwiftSourceSnapshotTestSupport {
    private static let captured:
        Result<PrimeSwiftSourceSnapshot, Error> = Result {
            let sourceRoot = URL(
                fileURLWithPath:
                    FileManager.default
                    .currentDirectoryPath,
                isDirectory: true
            )
            return try PrimeSwiftSourceProvenance
                .capture(
                    at: sourceRoot,
                    requiredRelativePaths:
                        PrimeNative3BFP32ExecutionConfiguration
                        .requiredPrimeSourceRelativePaths,
                    expectation:
                        PrimeSwiftSourceProvenance
                        .embeddedReleaseEvidenceExpectation
                )
        }

    static func currentReleaseSnapshot()
        throws -> PrimeSwiftSourceSnapshot
    {
        try captured.get()
    }
}
