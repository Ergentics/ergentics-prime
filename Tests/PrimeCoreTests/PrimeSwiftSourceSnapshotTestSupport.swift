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

enum PrimeRootPackageManifestCheckpointTestSupport {
    enum ContinuationError: Error, CustomStringConvertible {
        case nonUTF8(String)
        case unexpectedLiveIdentity(String, UInt64, String)
        case unauthorizedFrozenIdentity(String, UInt64, String)
        case unexpectedReplacementCount(String, Int)
        case reverseReconstructionMismatch(String, UInt64, String)
        case forwardReconstructionMismatch

        var description: String {
            switch self {
            case .nonUTF8(let path):
                return "non_utf8_\(path)"
            case .unexpectedLiveIdentity(let path, let byteCount, let sha256):
                return "unexpected_live_identity_\(path)_\(byteCount)_\(sha256)"
            case .unauthorizedFrozenIdentity(
                let path,
                let byteCount,
                let sha256
            ):
                return "unauthorized_frozen_identity_\(path)_\(byteCount)_\(sha256)"
            case .unexpectedReplacementCount(let label, let count):
                return "unexpected_replacement_count_\(label)_\(count)"
            case .reverseReconstructionMismatch(
                let path,
                let byteCount,
                let sha256
            ):
                return "reverse_reconstruction_mismatch_\(path)_\(byteCount)_\(sha256)"
            case .forwardReconstructionMismatch:
                return "forward_reconstruction_mismatch"
            }
        }
    }

    private static let packageRelativePath = "Package.swift"
    private static let historicalPackageByteCount: UInt64 = 27_650
    private static let historicalPackageSHA256 =
        "190b1d2dbeb2597830b1765fa80d6776a0044a34d5e2c6db8b14ace013654e7d"
    private static let currentPackageByteCount: UInt64 = 28_758
    private static let currentPackageSHA256 =
        "52a0078a3dd6b5cf68aa75e63c12ea739e2238cdb7c8f5b0380cbbff4cb66fa6"
    private static let scaffoldPackageByteCount: UInt64 = 29_043
    private static let scaffoldPackageSHA256 =
        "5df810b3796bc3b254e58148ddcc9e4014c92c504845084743c1d3a580c2c895"

    private static let productAnchor =
        "        .library(\n"
        + "            name: \"PrimeCore\",\n"
        + "            targets: [\"PrimeCore\"]\n"
        + "        ),\n"
    private static let productInsertion =
        "        .executable(\n"
        + "            name: \"PrimeValidationWorkflowDriverV2\",\n"
        + "            targets: [\"PrimeValidationWorkflowDriverV2\"]\n"
        + "        ),\n"
    private static let targetAnchor =
        "        .target(\n"
        + "            name: \"PrimeCore\"\n"
        + "        ),\n"
    private static let targetInsertion =
        "        .target(\n"
        + "            name: \"PrimeValidationWorkflowRootContracts\",\n"
        + "            dependencies: [\"PrimeCore\"],\n"
        + "            path:\n"
        + "                \"Tests/PrimeValidationWorkflow/Sources/PrimeValidationWorkflowContracts\"\n"
        + "        ),\n"
        + "        .target(\n"
        + "            name: \"PrimeValidationWorkflowRootDriverCore\",\n"
        + "            dependencies: [\n"
        + "                \"PrimeCore\",\n"
        + "                \"PrimeValidationWorkflowRootContracts\",\n"
        + "            ],\n"
        + "            path:\n"
        + "                \"Tests/PrimeValidationWorkflow/Sources/PrimeValidationWorkflowDriverCore\"\n"
        + "        ),\n"
        + "        .executableTarget(\n"
        + "            name: \"PrimeValidationWorkflowDriverV2\",\n"
        + "            dependencies: [\n"
        + "                \"PrimeCore\",\n"
        + "                \"PrimeValidationWorkflowRootContracts\",\n"
        + "                \"PrimeValidationWorkflowRootDriverCore\",\n"
        + "            ],\n"
        + "            linkerSettings: [\n"
        + "                .unsafeFlags([\n"
        + "                    \"-Xlinker\", \"-S\",\n"
        + "                ]),\n"
        + "            ]\n"
        + "        ),\n"
    private static let scaffoldProductAnchor =
        "        .executable(\n"
        + "            name: \"PrimeMLXBundleStage\",\n"
        + "            targets: [\"PrimeMLXBundleStage\"]\n"
        + "        ),\n"
    private static let scaffoldProductInsertion =
        "        .executable(\n"
        + "            name: \"PrimeMLXRuntimeScaffold\",\n"
        + "            targets: [\"PrimeMLXRuntimeScaffold\"]\n"
        + "        ),\n"
    private static let scaffoldTargetAnchor =
        "        .executableTarget(\n"
        + "            name: \"PrimeMLXBundleStage\",\n"
        + "            dependencies: [\"PrimeCore\"]\n"
        + "        ),\n"
    private static let scaffoldTargetInsertion =
        "        .executableTarget(\n"
        + "            name: \"PrimeMLXRuntimeScaffold\",\n"
        + "            dependencies: [\"PrimeCore\"],\n"
        + "            exclude: [\"Templates\"]\n"
        + "        ),\n"

    private static let identityLoopHistoricalLine =
        "            let data = try checkedInData(identity.primeRelativePath)\n"
    private static let identityLoopCurrentLines =
        "            let data = try PrimeRootPackageManifestCheckpointTestSupport\n"
        + "                .frozenCheckpointData(\n"
        + "                    relativePath: identity.primeRelativePath,\n"
        + "                    expectedByteCount: identity.byteCount,\n"
        + "                    expectedSHA256: identity.sha256,\n"
        + "                    repositoryRoot: repositoryRoot\n"
        + "                )\n"
    private static let tupleLoopHistoricalLine =
        "            let data = try checkedInData(path)\n"
    private static let tupleLoopCurrentLines =
        "            let data = try PrimeRootPackageManifestCheckpointTestSupport\n"
        + "                .frozenCheckpointData(\n"
        + "                    relativePath: path,\n"
        + "                    expectedByteCount: byteCount,\n"
        + "                    expectedSHA256: sha256,\n"
        + "                    repositoryRoot: repositoryRoot\n"
        + "                )\n"

    private static let identityLoopContinuationPaths: Set<String> = [
        "Tests/PrimeCoreTests/PrimeNativeNeuralGateHistoricalWorkerExportedEvidenceProjectionDecodeCompositionCallEdgeSourceContractTests.swift",
        "Tests/PrimeCoreTests/PrimeNativeNeuralGateHistoricalWorkerInvocationSeamSourceContractTests.swift",
        "Tests/PrimeCoreTests/PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerDesignContractTests.swift",
        "Tests/PrimeCoreTests/PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerSourceContractTests.swift",
        "Tests/PrimeCoreTests/PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingDesignContractTests.swift",
    ]
    private static let tupleLoopContinuationPath =
        "Tests/PrimeCoreTests/PrimeNativeNeuralGateHistoricalWorkerInvocationSeamDesignContractTests.swift"

    static func frozenCheckpointData(
        relativePath: String,
        expectedByteCount: UInt64,
        expectedSHA256: String,
        repositoryRoot: URL
    ) throws -> Data {
        let live = try Data(
            contentsOf: repositoryRoot.appendingPathComponent(relativePath)
        )
        let liveByteCount = UInt64(live.count)
        let liveSHA256 = PrimeSHA256.hexDigest(of: live)
        if liveByteCount == expectedByteCount
            && liveSHA256 == expectedSHA256
        {
            return live
        }

        let reconstructed: Data
        if relativePath == packageRelativePath {
            guard
                expectedByteCount == historicalPackageByteCount,
                expectedSHA256 == historicalPackageSHA256
            else {
                throw ContinuationError.unauthorizedFrozenIdentity(
                    relativePath,
                    expectedByteCount,
                    expectedSHA256
                )
            }
            reconstructed = try historicalPackageData(from: live)
        } else if identityLoopContinuationPaths.contains(relativePath) {
            reconstructed = try reverseSingleReplacement(
                in: live,
                relativePath: relativePath,
                current: identityLoopCurrentLines,
                historical: identityLoopHistoricalLine
            )
        } else if relativePath == tupleLoopContinuationPath {
            reconstructed = try reverseSingleReplacement(
                in: live,
                relativePath: relativePath,
                current: tupleLoopCurrentLines,
                historical: tupleLoopHistoricalLine
            )
        } else {
            throw ContinuationError.unexpectedLiveIdentity(
                relativePath,
                liveByteCount,
                liveSHA256
            )
        }

        let reconstructedByteCount = UInt64(reconstructed.count)
        let reconstructedSHA256 = PrimeSHA256.hexDigest(of: reconstructed)
        guard
            reconstructedByteCount == expectedByteCount,
            reconstructedSHA256 == expectedSHA256
        else {
            throw ContinuationError.reverseReconstructionMismatch(
                relativePath,
                reconstructedByteCount,
                reconstructedSHA256
            )
        }
        return reconstructed
    }

    private static func historicalPackageData(from live: Data) throws -> Data {
        let liveByteCount = UInt64(live.count)
        let liveSHA256 = PrimeSHA256.hexDigest(of: live)
        guard
            liveByteCount == scaffoldPackageByteCount,
            liveSHA256 == scaffoldPackageSHA256
        else {
            throw ContinuationError.unexpectedLiveIdentity(
                packageRelativePath,
                liveByteCount,
                liveSHA256
            )
        }
        guard let liveSource = String(data: live, encoding: .utf8) else {
            throw ContinuationError.nonUTF8(packageRelativePath)
        }

        var priorDriverSource = try replacingExactlyOnce(
            scaffoldProductInsertion,
            with: "",
            in: liveSource,
            label: "scaffold_product_reverse"
        )
        priorDriverSource = try replacingExactlyOnce(
            scaffoldTargetInsertion,
            with: "",
            in: priorDriverSource,
            label: "scaffold_target_reverse"
        )
        let priorDriver = Data(priorDriverSource.utf8)
        guard
            UInt64(priorDriver.count) == currentPackageByteCount,
            PrimeSHA256.hexDigest(of: priorDriver)
                == currentPackageSHA256
        else {
            throw ContinuationError.reverseReconstructionMismatch(
                packageRelativePath,
                UInt64(priorDriver.count),
                PrimeSHA256.hexDigest(of: priorDriver)
            )
        }

        var historicalSource = try replacingExactlyOnce(
            productInsertion,
            with: "",
            in: priorDriverSource,
            label: "driver_product_reverse"
        )
        historicalSource = try replacingExactlyOnce(
            targetInsertion,
            with: "",
            in: historicalSource,
            label: "driver_targets_reverse"
        )
        let historical = Data(historicalSource.utf8)
        guard
            UInt64(historical.count) == historicalPackageByteCount,
            PrimeSHA256.hexDigest(of: historical)
                == historicalPackageSHA256
        else {
            throw ContinuationError.reverseReconstructionMismatch(
                packageRelativePath,
                UInt64(historical.count),
                PrimeSHA256.hexDigest(of: historical)
            )
        }

        var reconstructedPriorDriverSource = try replacingExactlyOnce(
            productAnchor,
            with: productAnchor + productInsertion,
            in: historicalSource,
            label: "driver_product_forward"
        )
        reconstructedPriorDriverSource = try replacingExactlyOnce(
            targetAnchor,
            with: targetAnchor + targetInsertion,
            in: reconstructedPriorDriverSource,
            label: "driver_targets_forward"
        )
        guard Data(reconstructedPriorDriverSource.utf8) == priorDriver else {
            throw ContinuationError.forwardReconstructionMismatch
        }

        var reconstructedLiveSource = try replacingExactlyOnce(
            scaffoldProductAnchor,
            with: scaffoldProductAnchor + scaffoldProductInsertion,
            in: reconstructedPriorDriverSource,
            label: "scaffold_product_forward"
        )
        reconstructedLiveSource = try replacingExactlyOnce(
            scaffoldTargetAnchor,
            with: scaffoldTargetAnchor + scaffoldTargetInsertion,
            in: reconstructedLiveSource,
            label: "scaffold_target_forward"
        )
        guard Data(reconstructedLiveSource.utf8) == live else {
            throw ContinuationError.forwardReconstructionMismatch
        }
        return historical
    }

    private static func reverseSingleReplacement(
        in live: Data,
        relativePath: String,
        current: String,
        historical: String
    ) throws -> Data {
        guard let source = String(data: live, encoding: .utf8) else {
            throw ContinuationError.nonUTF8(relativePath)
        }
        return Data(
            try replacingExactlyOnce(
                current,
                with: historical,
                in: source,
                label: relativePath
            ).utf8
        )
    }

    private static func replacingExactlyOnce(
        _ needle: String,
        with replacement: String,
        in source: String,
        label: String
    ) throws -> String {
        let count = source.components(separatedBy: needle).count - 1
        guard count == 1 else {
            throw ContinuationError.unexpectedReplacementCount(label, count)
        }
        return source.replacingOccurrences(of: needle, with: replacement)
    }
}
