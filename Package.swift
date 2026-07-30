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
            dependencies: ["PrimeCore"]
        ),
    ]
)
