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
            name: "PrimeLatinProposalPairCapture",
            targets: [
                "PrimeLatinProposalPairCapture",
            ]
        ),
        .library(
            name: "PrimeLatinProposalGitObservation",
            targets: [
                "PrimeLatinProposalGitObservation",
            ]
        ),
        .library(
            name: "PrimeLatinProposalProducerRevalidationObservation",
            targets: [
                "PrimeLatinProposalProducerRevalidationObservation",
            ]
        ),
        .library(
            name: "PrimeLatinProposalIndependentReplay",
            targets: [
                "PrimeLatinProposalIndependentReplay",
            ]
        ),
        .executable(
            name: "PrimeLatinProposalPairCaptureProbe",
            targets: [
                "PrimeLatinProposalPairCaptureProbe",
            ]
        ),
        .executable(
            name: "PrimeLatinProposalGitObservationProbe",
            targets: [
                "PrimeLatinProposalGitObservationProbe",
            ]
        ),
        .executable(
            name:
                "PrimeLatinProposalProducerRevalidationObservationProbe",
            targets: [
                "PrimeLatinProposalProducerRevalidationObservationProbe",
            ]
        ),
        .executable(
            name: "PrimeLatinProposalIndependentReplayProbe",
            targets: [
                "PrimeLatinProposalIndependentReplayProbe",
            ]
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
    ],
    targets: [
        .target(
            name: "PrimeCore"
        ),
        .target(
            name: "PrimeLatinProposalPairCapture"
        ),
        .target(
            name: "PrimeLatinProposalGitObservation",
            dependencies: [
                "PrimeLatinProposalPairCapture",
            ]
        ),
        .target(
            name: "PrimeLatinProposalProducerRevalidationObservation",
            dependencies: [
                "PrimeLatinProposalPairCapture",
                "PrimeLatinProposalGitObservation",
            ]
        ),
        .target(
            name: "PrimeLatinProposalIndependentReplay",
            dependencies: [
                "PrimeLatinProposalPairCapture",
                "PrimeLatinProposalGitObservation",
            ]
        ),
        .target(
            name: "PrimeLatinProposalValidationComposition",
            dependencies: [
                "PrimeLatinProposalProducerRevalidationObservation",
                "PrimeLatinProposalIndependentReplay",
            ]
        ),
        .target(
            name: "PrimeLatinProposalValidationCompositionReceipt"
        ),
        .target(
            name: "PrimeLatinProposalValidationCompositionReceiptPublisher",
            dependencies: [
                "PrimeCore",
                "PrimeLatinProposalValidationComposition",
                "PrimeLatinProposalValidationCompositionReceipt",
            ]
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
        .target(
            name:
                "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection",
            dependencies: [
                "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics",
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplayMechanics",
                "PrimeNativeNeuralGateSemanticRecordContracts",
            ]
        ),
        .target(
            name:
                "PrimeNativeNeuralGateHistoricalStatisticsArtifactContracts",
            dependencies: [
                "PrimeNativeNeuralGateReplayArtifactContracts",
            ]
        ),
        .target(
            name:
                "PrimeNativeNeuralGateHistoricalSemanticArtifactDecoder",
            dependencies: [
                "PrimeNativeNeuralGateHistoricalStatisticsArtifactContracts",
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplayMechanics",
                "PrimeNativeNeuralGateSemanticRecordContracts",
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
                "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics",
                "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection",
                "PrimeNativeNeuralGateHistoricalSemanticArtifactDecoder",
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
                "PrimeNativeNeuralGateCorrectedMutationRecordContracts",
            dependencies: [
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplayMechanics",
                "PrimeNativeNeuralGateCorrectedMutationSurfaceContracts",
            ]
        ),
        .target(
            name:
                "PrimeNativeNeuralGateSemanticRecordContracts",
            dependencies: [
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplayMechanics",
            ]
        ),
        .target(
            name:
                "PrimeNativeNeuralGateCorrectedMutationProducer",
            dependencies: [
                "PrimeNativeNeuralGateCorrectedMutationRecordContracts",
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
            name: "PrimeLatinProposalPairCaptureProbe",
            dependencies: [
                "PrimeLatinProposalPairCapture",
            ]
        ),
        .executableTarget(
            name: "PrimeLatinProposalGitObservationProbe",
            dependencies: [
                "PrimeLatinProposalGitObservation",
            ]
        ),
        .executableTarget(
            name:
                "PrimeLatinProposalProducerRevalidationObservationProbe",
            dependencies: [
                "PrimeLatinProposalProducerRevalidationObservation",
            ]
        ),
        .executableTarget(
            name: "PrimeLatinProposalIndependentReplayProbe",
            dependencies: [
                "PrimeLatinProposalIndependentReplay",
            ]
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
            name: "PrimeLatinProposalPairCaptureTests",
            dependencies: [
                "PrimeLatinProposalPairCapture",
                "PrimeLatinProposalGitObservation",
                "PrimeLatinProposalProducerRevalidationObservation",
                "PrimeLatinProposalIndependentReplay",
                "PrimeLatinProposalValidationComposition",
                "PrimeLatinProposalValidationCompositionReceipt",
                "PrimeLatinProposalValidationCompositionReceiptPublisher",
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
                "PrimeNativeNeuralGateCorrectedMutationRecordContracts",
                "PrimeNativeNeuralGateSemanticRecordContracts",
                "PrimeNativeNeuralGateCorrectedMutationProducer",
                "PrimeNativeNeuralGateCorrectedMutationDetector",
                "PrimeNativeNeuralGateHistoricalSourceDerivation",
                "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection",
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
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplayMechanics",
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
                "PrimeNativeNeuralGateCorrectedMutationRecordContracts",
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
        .testTarget(
            name:
                "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjectionTests",
            dependencies: [
                "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics",
                "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection",
                "PrimeNativeNeuralGateReplayArtifactContracts",
            ]
        ),
        .testTarget(
            name:
                "PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderTests",
            dependencies: [
                "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics",
                "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection",
                "PrimeNativeNeuralGateHistoricalSemanticArtifactDecoder",
                "PrimeNativeNeuralGateHistoricalStatisticsArtifactContracts",
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplayMechanics",
                "PrimeNativeNeuralGateSemanticRecordContracts",
            ]
        ),
    ]
)
