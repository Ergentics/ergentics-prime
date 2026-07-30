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
                "68904d54b72871f26968261ae05d4fbb7c5e3142"
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
