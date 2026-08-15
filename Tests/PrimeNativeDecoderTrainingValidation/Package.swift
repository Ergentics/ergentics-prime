// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "PrimeNativeDecoderTrainingValidation",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .executable(
            name:
                "PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution",
            targets: [
                "PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution",
            ]
        ),
        .executable(
            name:
                "PrimeNativeDecoderBSpecificNative300MResourceWitness",
            targets: [
                "PrimeNativeDecoderBSpecificNative300MResourceWitness",
            ]
        ),
        .executable(
            name:
                "PrimeNativeDecoderNative300MResourceOnlyOneStepProbe",
            targets: [
                "PrimeNativeDecoderNative300MResourceOnlyOneStepProbe",
            ]
        ),
    ],
    dependencies: [
        .package(
            name: "ergentics-prime",
            path: "../.."
        ),
        .package(
            url:
                "https://github.com/Ergentics/ergentics-mlx-swift",
            revision:
                "d37885a278f1c37484a94d0f401a418735e66519"
        ),
    ],
    targets: [
        .executableTarget(
            name:
                "PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution",
            dependencies: [
                .product(
                    name: "PrimeNativeDecoderTraining",
                    package: "ergentics-prime"
                ),
            ],
            path:
                "Sources/PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution",
            linkerSettings: [
                .linkedFramework("CoreGraphics"),
                .linkedFramework("Metal"),
            ]
        ),
        .executableTarget(
            name:
                "PrimeNativeDecoderBSpecificNative300MResourceWitness",
            dependencies: [
                .product(
                    name: "PrimeNativeDecoderTraining",
                    package: "ergentics-prime"
                ),
            ],
            path:
                "Sources/PrimeNativeDecoderBSpecificNative300MResourceWitness",
            linkerSettings: [
                .linkedFramework("CoreGraphics"),
                .linkedFramework("Metal"),
            ]
        ),
        .executableTarget(
            name:
                "PrimeNativeDecoderNative300MResourceOnlyOneStepProbe",
            dependencies: [
                .product(
                    name: "PrimeNativeDecoderTraining",
                    package: "ergentics-prime"
                ),
            ],
            path:
                "Sources/PrimeNativeDecoderNative300MResourceOnlyOneStepProbe",
            linkerSettings: [
                .linkedFramework("CoreGraphics"),
                .linkedFramework("Metal"),
            ]
        ),
        .testTarget(
            name: "PrimeNativeDecoderTrainingTests",
            dependencies: [
                .product(
                    name: "PrimeCore",
                    package: "ergentics-prime"
                ),
                .product(
                    name: "PrimeNativeDecoderTraining",
                    package: "ergentics-prime"
                ),
                .product(
                    name: "MLX",
                    package: "ergentics-mlx-swift"
                ),
            ],
            linkerSettings: [
                .linkedFramework("CoreGraphics"),
                .linkedFramework("Metal"),
            ]
        ),
    ]
)
