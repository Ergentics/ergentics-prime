// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name:
        "PrimeTypedOptimizerRestoreMechanicsValidation",
    platforms: [
        .macOS(.v14),
    ],
    dependencies: [
        .package(path: "../.."),
        .package(
            url:
                "https://github.com/Ergentics/ergentics-mlx-swift",
            revision:
                "d37885a278f1c37484a94d0f401a418735e66519"
        ),
    ],
    targets: [
        .testTarget(
            name:
                "PrimeTypedOptimizerRestoreMechanicsTests",
            dependencies: [
                .product(
                    name: "PrimeCore",
                    package: "ergentics-prime"
                ),
                .product(
                    name:
                        "PrimeTypedOptimizerRestoreMechanics",
                    package: "ergentics-prime"
                ),
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
    ]
)
