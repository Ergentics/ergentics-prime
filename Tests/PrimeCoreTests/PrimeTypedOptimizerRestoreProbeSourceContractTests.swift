import Foundation
import XCTest

final class PrimeTypedOptimizerRestoreProbeSourceContractTests:
    XCTestCase
{
    func testProbeUsesSwiftPublicTypedStateAndFreshWorkers()
        throws
    {
        let source = try source(
            "Sources/PrimeTypedOptimizerRestoreProbe/PrimeTypedOptimizerRestoreProbeMain.swift"
        )
        for required in [
            "import PrimeTypedOptimizerRestoreMechanics",
            "case control",
            "case writer",
            "case restorer",
            "let process = Process()",
            ".rehydrateCheckpoint(",
            ".runRestorer(",
            "publicTypedRestoreAPIUsed: true",
            "PrimeTypedOptimizerProcessObservation(",
            "try receipt.validate(in: root)",
            "PrimeTypedOptimizerRestoreFailureReceipt(",
            "ABSTAIN receipt_sha256=",
            "process.environment = workerEnvironment",
            "process.standardInput = FileHandle.nullDevice",
            "BoundedPipeCapture(",
            "PrimeProcessTermination",
            "permitsFailureReceipt",
            "PrimeTypedOptimizerDependencyTree",
            ".reverifySibling(",
            "try root.requireEmpty()",
            "artifactRootAdmissionFailed",
            "observed.second.entries",
            "!= control.second.entries",
            "finalSourceSnapshot",
            "== sourceSnapshot",
        ] {
            XCTAssertTrue(
                source.contains(required),
                "missing \(required)"
            )
        }
        for forbidden in [
            "innerState(",
            "_updateInternal",
            "Mirror(",
            "python",
            "/bin/sh",
            "/bin/zsh",
            "dummy optimizer",
            "process.standardOutput = FileHandle.standardOutput",
            "process.standardError = FileHandle.standardError",
            "independentlyDerived: true",
            "process.terminate()",
            "observed != control.manifest",
        ] {
            XCTAssertFalse(
                source.contains(forbidden),
                "forbidden \(forbidden)"
            )
        }
    }

    func testContractMakesExactValidationRootMandatory()
        throws
    {
        let source = try source(
            "Sources/PrimeCore/PrimeTypedOptimizerRestoreContract.swift"
        )
        XCTAssertTrue(
            source.contains(
                "in root: PrimeArtifactRoot\n    ) throws"
            )
        )
        XCTAssertFalse(
            source.contains(
                "in root: PrimeArtifactRoot? = nil"
            )
        )
        for required in [
            "root.decodeVerified(",
            "root.verify(primeSourceSnapshot)",
            "PrimeSwiftSourceProvenance.validate(",
            "root.verify(runtimeImage.artifact)",
            "for binding in sourceEvidence.artifacts",
            "for binding in checkpointArtifacts",
            "validateDependencySemantics(",
        ] {
            XCTAssertTrue(
                source.contains(required),
                "missing transitive check \(required)"
            )
        }
    }

    func testMechanicsUsesOnlyLiteralInitialization()
        throws
    {
        let source = try source(
            "Sources/PrimeTypedOptimizerRestoreMechanics/PrimeTypedOptimizerRestoreMechanics.swift"
        )
        XCTAssertTrue(
            source.contains("Linear(\n                    weight:")
        )
        for forbidden in [
            "Linear(2, 2)",
            "MLXRandom",
        ] {
            XCTAssertFalse(
                source.contains(forbidden),
                "forbidden random initialization route \(forbidden)"
            )
        }
    }

    func testMutationSweepKeepsAllSynthesizedStateOnCPU()
        throws
    {
        let source = try source(
            "Sources/PrimeTypedOptimizerRestoreProbe/PrimeTypedOptimizerRestoreProbeMain.swift"
        )
        let start = try XCTUnwrap(
            source.range(
                of: "private func mutationSweep()"
            )
        )
        let end = try XCTUnwrap(
            source.range(
                of: "\nprivate func runParent(",
                range:
                    start.upperBound
                        ..< source.endIndex
            )
        )
        let mutationSweep =
            source[start.lowerBound
                ..< end.lowerBound]
        XCTAssertTrue(
            mutationSweep.contains(
                "try Device.withDefaultDevice(.cpu) {"
            )
        )
    }

    private func source(
        _ repositoryRelativePath: String
    ) throws -> String {
        let tests = URL(
            fileURLWithPath: #filePath
        ).deletingLastPathComponent()
        let root = tests
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        return try String(
            contentsOf:
                root.appendingPathComponent(
                    repositoryRelativePath
                ),
            encoding: .utf8
        )
    }
}
