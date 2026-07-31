// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name:
        "PrimeNativeNeuralGateMLXValidation",
    platforms: [
        .macOS(.v14),
    ],
    dependencies: [
        .package(path: "../.."),
    ],
    targets: [
        .testTarget(
            name:
                "PrimeNativeNeuralGateMLXValidationTests",
            dependencies: [
                .product(
                    name:
                        "PrimeNativeNeuralGateMLXValidationMechanics",
                    package: "ergentics-prime"
                ),
            ]
        ),
    ]
)
