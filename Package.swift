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
    ],
    dependencies: [
        .package(
            url: "https://github.com/ml-explore/mlx-swift",
            exact: "0.31.3"
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
        .executableTarget(
            name: "PrimeGPUCalibration",
            dependencies: [
                "PrimeCore",
                .product(
                    name: "MLX",
                    package: "mlx-swift"
                ),
                .product(
                    name: "MLXNN",
                    package: "mlx-swift"
                ),
                .product(
                    name: "MLXOptimizers",
                    package: "mlx-swift"
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
        .testTarget(
            name: "PrimeCoreTests",
            dependencies: ["PrimeCore"]
        ),
    ]
)
