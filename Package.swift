// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "ErgenticsPrime",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "PrimeCore",
            targets: ["PrimeCore"]
        ),
        .library(
            name:
                "PrimeNativeNeuralGateReplayTransport",
            targets: [
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplayTransport",
            ]
        ),
        .library(
            name:
                "PrimeNativeNeuralGateReplayComposition",
            targets: [
                "PrimeNativeNeuralGateReplayComposition",
            ]
        ),
        .library(
            name:
                "PrimeNativeNeuralGateReplaySourceBinding",
            targets: [
                "PrimeNativeNeuralGateReplaySourceBinding",
            ]
        ),
        .library(
            name:
                "PrimeNativeNeuralGateReplaySourceComposition",
            targets: [
                "PrimeNativeNeuralGateReplaySourceComposition",
            ]
        ),
        .library(
            name:
                "PrimeNativeNeuralGateReplayCaptureInventory",
            targets: [
                "PrimeNativeNeuralGateReplayCaptureInventory",
            ]
        ),
        .library(
            name:
                "PrimeNativeNeuralGatePromptTargetCrosswalkAuthority",
            targets: [
                "PrimeNativeNeuralGatePromptTargetCrosswalkAuthority",
            ]
        ),
        .library(
            name:
                "PrimeNativeNeuralGateMLXValidationMechanics",
            targets: [
                "PrimeNativeCorpusReplayMechanics",
                "PrimeNativeNeuralGateCorrectedMechanics",
                "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
                "PrimeNativeNeuralGateCorrectedFixtureAuthority",
                "PrimeNativeNeuralGatePromptSolver",
                "PrimeNativeNeuralGateLogitSidecarMechanics",
                "PrimeNativeNeuralGateMLXLogSoftmaxRecomputation",
            ]
        ),
        .library(
            name:
                "PrimeTypedOptimizerRestoreMechanics",
            targets: [
                "PrimeTypedOptimizerRestoreMechanics",
            ]
        ),
        .executable(
            name: "PrimeGPUCalibration",
            targets: ["PrimeGPUCalibration"]
        ),
        .executable(
            name: "PrimeNative3BMetalContinuationProbe",
            targets: [
                "PrimeNative3BMetalContinuationProbe",
            ]
        ),
        .executable(
            name: "PrimeNativeContractResolutionProbe",
            targets: [
                "PrimeNativeContractResolutionProbe",
            ]
        ),
        .executable(
            name: "PrimeNativeContractResolutionVerifier",
            targets: [
                "PrimeNativeContractResolutionVerifier",
            ]
        ),
        .executable(
            name: "PrimeNativeResolvedContractAdapterProbe",
            targets: [
                "PrimeNativeResolvedContractAdapterProbe",
            ]
        ),
        .executable(
            name: "PrimeNativeResolvedContractAdapterVerifier",
            targets: [
                "PrimeNativeResolvedContractAdapterVerifier",
            ]
        ),
        .executable(
            name: "PrimeNativeGenerationContractProjectionProbe",
            targets: [
                "PrimeNativeGenerationContractProjectionProbe",
            ]
        ),
        .executable(
            name: "PrimeNativeGenerationContractProjectionVerifier",
            targets: [
                "PrimeNativeGenerationContractProjectionVerifier",
            ]
        ),
        .executable(
            name: "PrimeNativeCorpusReplayProbe",
            targets: [
                "PrimeNativeCorpusReplayProbe",
            ]
        ),
        .executable(
            name: "PrimeNativeCorpusReplayVerifier",
            targets: [
                "PrimeNativeCorpusReplayVerifier",
            ]
        ),
        .executable(
            name: "PrimeNativeNeuralGateContractProjectionProbe",
            targets: [
                "PrimeNativeNeuralGateContractProjectionProbe",
            ]
        ),
        .executable(
            name: "PrimeNativeNeuralGateContractProjectionVerifier",
            targets: [
                "PrimeNativeNeuralGateContractProjectionVerifier",
            ]
        ),
        .executable(
            name: "PrimeLeaseHolder",
            targets: ["PrimeLeaseHolder"]
        ),
        .executable(
            name: "PrimeMLXBundleStage",
            targets: ["PrimeMLXBundleStage"]
        ),
        .executable(
            name: "PrimeMLXTestBundleStage",
            targets: ["PrimeMLXTestBundleStage"]
        ),
        .executable(
            name: "PrimeOptimizerRestoreProbe",
            targets: ["PrimeOptimizerRestoreProbe"]
        ),
        .executable(
            name: "PrimeTypedOptimizerRestoreProbe",
            targets: [
                "PrimeTypedOptimizerRestoreProbe",
            ]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/Ergentics/ergentics-mlx-swift",
            revision:
                "d37885a278f1c37484a94d0f401a418735e66519"
        ),
        .package(
            url: "https://github.com/ml-explore/mlx-swift-lm",
            exact: "3.31.3"
        ),
    ],
    targets: [
        .target(
            name: "PrimeCore"
        ),
        .target(
            name:
                "PrimeTypedOptimizerRestoreMechanics",
            dependencies: [
                "PrimeCore",
                .product(
                    name: "MLX",
                    package: "ergentics-mlx-swift"
                ),
                .product(
                    name: "MLXNN",
                    package: "ergentics-mlx-swift"
                ),
                .product(
                    name: "MLXOptimizers",
                    package: "ergentics-mlx-swift"
                ),
            ]
        ),
        .target(
            name: "PrimeNativeCorpusReplayMechanics"
        ),
        .target(
            name:
                "PrimeNativeNeuralGateReplayMechanics"
        ),
        .target(
            name: "ErgenticsPrimeRuntime"
        ),
        .target(
            name:
                "PrimeNativeNeuralGateHistoricalReplayMechanics",
            dependencies: [
                "ErgenticsPrimeRuntime",
                "PrimeNativeNeuralGateReplayMechanics",
            ]
        ),
        .target(
            name:
                "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics",
            dependencies: [
                "ErgenticsPrimeRuntime",
                "PrimeNativeNeuralGateReplayMechanics",
                "PrimeNativeNeuralGateHistoricalReplayMechanics",
            ]
        ),
        .executableTarget(
            name:
                "PrimeNativeNeuralGateHistoricalFixtureWorker",
            dependencies: [
                "PrimeCore",
                "ErgenticsPrimeRuntime",
                "PrimeNativeNeuralGateHistoricalReplayMechanics",
                "PrimeNativeNeuralGateReplayTransport",
            ],
            resources: [
                .copy("HistoricalFixtureEvidence"),
            ]
        ),
        .target(
            name:
                "PrimeNativeNeuralGateReplayArtifactContracts"
        ),
        .target(
            name:
                "PrimeNativeNeuralGateCorrectedMutationSurfaceContracts",
            dependencies: [
                "PrimeNativeNeuralGateReplayMechanics",
            ]
        ),
        .target(
            name:
                "PrimeNativeNeuralGateSemanticRecordContracts",
            dependencies: [
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplayMechanics",
                "PrimeNativeNeuralGateCorrectedMutationSurfaceContracts",
            ]
        ),
        .target(
            name:
                "PrimeNativeNeuralGateCorrectedMutationProducer",
            dependencies: [
                "PrimeNativeNeuralGateSemanticRecordContracts",
                "PrimeNativeNeuralGateCorrectedMutationSurfaceContracts",
            ]
        ),
        .target(
            name:
                "PrimeNativeNeuralGateCorrectedMutationDetector",
            dependencies: [
                "PrimeNativeNeuralGateCorrectedMutationSurfaceContracts",
            ]
        ),
        .target(
            name:
                "PrimeNativeNeuralGateHistoricalSourceDerivation",
            dependencies: [
                "PrimeNativeNeuralGateReplayMechanics",
            ],
            resources: [
                .copy("HistoricalEvidenceExportSource"),
            ]
        ),
        .target(
            name:
                "PrimeNativeNeuralGateTargetFreeScheduleDeliveryContracts",
            dependencies: [
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplayMechanics",
                "PrimeNativeNeuralGateCorrectedMechanics",
            ]
        ),
        .target(
            name:
                "PrimeNativeNeuralGateTargetFreeScheduleDeliveryAuthority",
            dependencies: [
                "PrimeNativeNeuralGateReplayCaptureInventory",
                "PrimeNativeNeuralGateReplaySourceComposition",
                "PrimeNativeNeuralGateTargetFreeScheduleDeliveryContracts",
                "PrimeNativeNeuralGateCorrectedProcessOwnershipContracts",
                "PrimeNativeNeuralGateCorrectedEvaluationOwnershipContracts",
            ]
        ),
        .target(
            name:
                "PrimeNativeNeuralGateCorrectedProcessOwnershipContracts",
            dependencies: [
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateTargetFreeScheduleDeliveryContracts",
            ]
        ),
        .target(
            name:
                "PrimeNativeNeuralGateCorrectedEvaluationOwnershipContracts",
            dependencies: [
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateCorrectedProcessOwnershipContracts",
            ]
        ),
        .target(
            name:
                "PrimeNativeNeuralGateTerminalReceiptOwnershipContracts",
            dependencies: [
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateCorrectedProcessOwnershipContracts",
                "PrimeNativeNeuralGateCorrectedEvaluationOwnershipContracts",
            ]
        ),
        .target(
            name:
                "PrimeNativeNeuralGateRoleArtifactReferenceContracts",
            dependencies: [
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplayMechanics",
                "PrimeNativeNeuralGateTargetFreeScheduleDeliveryContracts",
                "PrimeNativeNeuralGateCorrectedProcessOwnershipContracts",
                "PrimeNativeNeuralGateCorrectedEvaluationOwnershipContracts",
                "PrimeNativeNeuralGateTerminalReceiptOwnershipContracts",
            ]
        ),
        .target(
            name:
                "PrimeNativeNeuralGateRoleArtifactReferenceAuthority",
            dependencies: [
                "PrimeNativeNeuralGateRoleArtifactReferenceContracts",
                "PrimeNativeNeuralGateTargetFreeScheduleDeliveryAuthority",
                "PrimeNativeNeuralGateCorrectedProcessOwnershipContracts",
                "PrimeNativeNeuralGateTargetFreeScheduleDeliveryContracts",
            ]
        ),
        .target(
            name:
                "PrimeNativeNeuralGateReplayTransport",
            dependencies: [
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplayMechanics",
            ]
        ),
        .target(
            name:
                "PrimeNativeNeuralGateReplayComposition",
            dependencies: [
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplayTransport",
                "PrimeNativeNeuralGateReplayMechanics",
                "PrimeNativeNeuralGateCorrectedMechanics",
                "PrimeNativeNeuralGateLogitSidecarMechanics",
            ]
        ),
        .target(
            name:
                "PrimeNativeNeuralGateReplaySourceBinding",
            dependencies: [
                "PrimeCore",
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplayTransport",
                "PrimeNativeNeuralGateReplayMechanics",
                "PrimeNativeNeuralGateCorrectedMechanics",
                "PrimeNativeNeuralGateLogitSidecarMechanics",
            ]
        ),
        .target(
            name:
                "PrimeNativeNeuralGateReplaySourceComposition",
            dependencies: [
                "PrimeNativeNeuralGateReplaySourceBinding",
                "PrimeNativeNeuralGateReplayComposition",
                "PrimeNativeNeuralGateTargetFreeScheduleDeliveryContracts",
            ]
        ),
        .target(
            name:
                "PrimeNativeNeuralGateReplayCaptureInventory",
            dependencies: [
                "PrimeCore",
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplaySourceBinding",
            ]
        ),
        .target(
            name:
                "PrimeNativeNeuralGatePromptTargetCrosswalkAuthority",
            dependencies: [
                "PrimeCore",
                "PrimeNativeNeuralGateCorrectedFixtureAuthority",
                "PrimeNativeNeuralGateCorrectedMechanics",
                "PrimeNativeNeuralGateReplayCaptureInventory",
                "PrimeNativeNeuralGateReplayComposition",
                "PrimeNativeNeuralGateReplaySourceComposition",
                "PrimeNativeNeuralGateReplayTransport",
            ]
        ),
        .target(
            name:
                "PrimeNativeNeuralGateCorrectedMechanics",
            dependencies: [
                "PrimeNativeNeuralGateReplayMechanics",
            ]
        ),
        .target(
            name:
                "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
            dependencies: [
                "PrimeNativeNeuralGateReplayMechanics",
                "PrimeNativeNeuralGateCorrectedMechanics",
            ]
        ),
        .target(
            name:
                "PrimeNativeNeuralGateCorrectedFixtureAuthority",
            dependencies: [
                "PrimeNativeCorpusReplayMechanics",
                "PrimeNativeNeuralGateCorrectedMechanics",
                "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
            ]
        ),
        .target(
            name:
                "PrimeNativeNeuralGatePromptSolver",
            dependencies: [
                "PrimeNativeNeuralGateCorrectedMechanics",
            ]
        ),
        .target(
            name:
                "PrimeNativeNeuralGateLogitSidecarMechanics",
            dependencies: [
                "PrimeNativeNeuralGateCorrectedMechanics",
            ]
        ),
        .target(
            name:
                "PrimeNativeNeuralGateMLXLogSoftmaxRecomputation",
            dependencies: [
                "PrimeNativeNeuralGateLogitSidecarMechanics",
                .product(
                    name: "MLX",
                    package: "ergentics-mlx-swift"
                ),
                .product(
                    name: "MLXNN",
                    package: "ergentics-mlx-swift"
                ),
            ]
        ),
        .target(
            name: "PrimeNativeCorpusReplay",
            dependencies: [
                "PrimeCore",
                "PrimeNativeCorpusReplayMechanics",
            ]
        ),
        .target(
            name: "PrimeNativeNeuralGateContract",
            dependencies: [
                "PrimeCore",
                "PrimeNativeCorpusReplay",
            ]
        ),
        .executableTarget(
            name: "PrimeGPUCalibration",
            dependencies: [
                "PrimeCore",
                .product(
                    name: "MLX",
                    package: "ergentics-mlx-swift"
                ),
                .product(
                    name: "MLXNN",
                    package: "ergentics-mlx-swift"
                ),
                .product(
                    name: "MLXOptimizers",
                    package: "ergentics-mlx-swift"
                ),
                .product(
                    name: "MLXLLM",
                    package: "mlx-swift-lm"
                ),
            ]
        ),
        .executableTarget(
            name: "PrimeNative3BMetalContinuationProbe",
            dependencies: [
                "PrimeCore",
                .product(
                    name: "MLX",
                    package: "ergentics-mlx-swift"
                ),
                .product(
                    name: "MLXNN",
                    package: "ergentics-mlx-swift"
                ),
                .product(
                    name: "MLXOptimizers",
                    package: "ergentics-mlx-swift"
                ),
                .product(
                    name: "MLXLLM",
                    package: "mlx-swift-lm"
                ),
            ]
        ),
        .executableTarget(
            name: "PrimeNativeContractResolutionProbe",
            dependencies: ["PrimeCore"]
        ),
        .executableTarget(
            name: "PrimeNativeContractResolutionVerifier",
            dependencies: ["PrimeCore"]
        ),
        .executableTarget(
            name: "PrimeNativeResolvedContractAdapterProbe",
            dependencies: ["PrimeCore"]
        ),
        .executableTarget(
            name: "PrimeNativeResolvedContractAdapterVerifier",
            dependencies: ["PrimeCore"]
        ),
        .executableTarget(
            name: "PrimeNativeGenerationContractProjectionProbe",
            dependencies: ["PrimeCore"]
        ),
        .executableTarget(
            name: "PrimeNativeGenerationContractProjectionVerifier",
            dependencies: ["PrimeCore"]
        ),
        .executableTarget(
            name: "PrimeNativeCorpusReplayProbe",
            dependencies: [
                "PrimeCore",
                "PrimeNativeCorpusReplay",
                "PrimeNativeCorpusReplayMechanics",
            ]
        ),
        .executableTarget(
            name: "PrimeNativeCorpusReplayVerifier",
            dependencies: [
                "PrimeCore",
                "PrimeNativeCorpusReplay",
                "PrimeNativeCorpusReplayMechanics",
            ]
        ),
        .executableTarget(
            name: "PrimeNativeNeuralGateContractProjectionProbe",
            dependencies: [
                "PrimeCore",
                "PrimeNativeNeuralGateContract",
            ]
        ),
        .executableTarget(
            name: "PrimeNativeNeuralGateContractProjectionVerifier",
            dependencies: [
                "PrimeCore",
                "PrimeNativeNeuralGateContract",
            ]
        ),
        .executableTarget(
            name: "PrimeLeaseHolder",
            dependencies: ["PrimeCore"]
        ),
        .executableTarget(
            name: "PrimeMLXBundleStage",
            dependencies: ["PrimeCore"]
        ),
        .executableTarget(
            name: "PrimeMLXTestBundleStage",
            dependencies: ["PrimeCore"]
        ),
        .executableTarget(
            name: "PrimeOptimizerRestoreProbe",
            dependencies: [
                "PrimeCore",
                .product(
                    name: "MLX",
                    package: "ergentics-mlx-swift"
                ),
                .product(
                    name: "MLXNN",
                    package: "ergentics-mlx-swift"
                ),
                .product(
                    name: "MLXOptimizers",
                    package: "ergentics-mlx-swift"
                ),
            ]
        ),
        .executableTarget(
            name: "PrimeTypedOptimizerRestoreProbe",
            dependencies: [
                "PrimeCore",
                "PrimeTypedOptimizerRestoreMechanics",
                .product(
                    name: "MLX",
                    package: "ergentics-mlx-swift"
                ),
                .product(
                    name: "MLXOptimizers",
                    package: "ergentics-mlx-swift"
                ),
            ]
        ),
        .testTarget(
            name: "PrimeCoreTests",
            dependencies: [
                "PrimeCore",
                "PrimeNativeCorpusReplay",
                "PrimeNativeCorpusReplayMechanics",
                "PrimeNativeNeuralGateContract",
                "PrimeNativeNeuralGateReplayMechanics",
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateCorrectedMutationSurfaceContracts",
                "PrimeNativeNeuralGateSemanticRecordContracts",
                "PrimeNativeNeuralGateCorrectedMutationProducer",
                "PrimeNativeNeuralGateCorrectedMutationDetector",
                "PrimeNativeNeuralGateHistoricalSourceDerivation",
                "PrimeNativeNeuralGateReplayTransport",
                "PrimeNativeNeuralGateReplayComposition",
                "PrimeNativeNeuralGateReplaySourceBinding",
                "PrimeNativeNeuralGateReplaySourceComposition",
                "PrimeNativeNeuralGateReplayCaptureInventory",
                "PrimeNativeNeuralGatePromptTargetCrosswalkAuthority",
                "PrimeNativeNeuralGateTargetFreeScheduleDeliveryContracts",
                "PrimeNativeNeuralGateTargetFreeScheduleDeliveryAuthority",
                "PrimeNativeNeuralGateCorrectedProcessOwnershipContracts",
                "PrimeNativeNeuralGateCorrectedEvaluationOwnershipContracts",
                "PrimeNativeNeuralGateTerminalReceiptOwnershipContracts",
                "PrimeNativeNeuralGateRoleArtifactReferenceContracts",
                "PrimeNativeNeuralGateRoleArtifactReferenceAuthority",
                "PrimeNativeNeuralGateCorrectedMechanics",
                "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
                "PrimeNativeNeuralGateCorrectedFixtureAuthority",
                "PrimeNativeNeuralGatePromptSolver",
                "PrimeNativeNeuralGateLogitSidecarMechanics",
            ]
        ),
        .testTarget(
            name:
                "PrimeNativeNeuralGateSemanticRecordContractsTests",
            dependencies: [
                "PrimeNativeNeuralGateSemanticRecordContracts",
            ]
        ),
        .testTarget(
            name:
                "PrimeNativeNeuralGateCorrectedMutationSurfaceContractsTests",
            dependencies: [
                "PrimeNativeNeuralGateCorrectedMutationSurfaceContracts",
            ]
        ),
        .testTarget(
            name:
                "PrimeNativeNeuralGateCorrectedMutationProducerTests",
            dependencies: [
                "PrimeNativeNeuralGateSemanticRecordContracts",
                "PrimeNativeNeuralGateCorrectedMutationSurfaceContracts",
                "PrimeNativeNeuralGateCorrectedMutationProducer",
            ]
        ),
        .testTarget(
            name:
                "PrimeNativeNeuralGateCorrectedMutationDetectorTests",
            dependencies: [
                "PrimeNativeNeuralGateCorrectedMutationSurfaceContracts",
                "PrimeNativeNeuralGateCorrectedMutationDetector",
            ]
        ),
        .testTarget(
            name:
                "PrimeNativeNeuralGateHistoricalSourceDerivationTests",
            dependencies: [
                "PrimeCore",
                "PrimeNativeNeuralGateReplayMechanics",
                "PrimeNativeNeuralGateHistoricalSourceDerivation",
            ]
        ),
        .testTarget(
            name:
                "PrimeNativeNeuralGateHistoricalReplayMechanicsTests",
            dependencies: [
                "PrimeCore",
                "PrimeNativeNeuralGateHistoricalSourceDerivation",
                "PrimeNativeNeuralGateHistoricalReplayMechanics",
                "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics",
            ]
        ),
    ]
)
