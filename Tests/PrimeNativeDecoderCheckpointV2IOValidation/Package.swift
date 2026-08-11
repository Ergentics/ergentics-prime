// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "PrimeNativeDecoderCheckpointV2IOValidation",
    platforms: [
        .macOS(.v14),
    ],
    dependencies: [
        .package(
            name: "ergentics-prime",
            path: "../.."
        ),
    ],
    targets: [
        .testTarget(
            name: "PrimeNativeDecoderCheckpointV2IOTests",
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
