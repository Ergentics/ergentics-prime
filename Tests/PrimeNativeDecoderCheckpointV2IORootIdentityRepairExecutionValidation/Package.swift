// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .executable(
            name: "PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionProbe",
            targets: [
                "PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionProbe",
            ]
        ),
    ],
    dependencies: [
        .package(
            name: "ergentics-prime",
            path: "../.."
        ),
        .package(
            url: "https://github.com/Ergentics/ergentics-mlx-swift",
            revision:
                "d37885a278f1c37484a94d0f401a418735e66519"
        ),
    ],
    targets: [
        .executableTarget(
            name: "PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionProbe",
            dependencies: [
                .product(
                    name: "PrimeCore",
                    package: "ergentics-prime"
                ),
                .product(
                    name: "PrimeNativeDecoder",
                    package: "ergentics-prime"
                ),
                .product(
                    name: "PrimeNativeDecoderCheckpoint",
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
            ],
            linkerSettings: [
                .linkedFramework("CoreGraphics"),
                .linkedFramework("Metal"),
            ]
        ),
        .testTarget(
            name: "PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionAuthorityTests",
            dependencies: [
                .product(
                    name: "PrimeCore",
                    package: "ergentics-prime"
                ),
                .product(
                    name: "PrimeNativeDecoderCheckpoint",
                    package: "ergentics-prime"
                ),
            ]
        ),
    ]
)
