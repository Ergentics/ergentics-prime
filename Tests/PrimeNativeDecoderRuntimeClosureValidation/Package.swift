// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "PrimeNativeDecoderRuntimeClosureValidation",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .executable(
            name: "PrimeNativeDecoderRuntimeClosureProbe",
            targets: [
                "PrimeNativeDecoderRuntimeClosureProbe",
            ]
        ),
    ],
    dependencies: [
        .package(
            name: "ergentics-prime",
            path: "../.."
        ),
    ],
    targets: [
        .executableTarget(
            name: "PrimeNativeDecoderRuntimeClosureProbe",
            dependencies: [
                .product(
                    name: "PrimeCore",
                    package: "ergentics-prime"
                ),
                .product(
                    name: "PrimeNativeDecoderRuntime",
                    package: "ergentics-prime"
                ),
            ]
        ),
        .testTarget(
            name: "PrimeNativeDecoderRuntimeClosureAuthorityTests",
            dependencies: [
                .product(
                    name: "PrimeCore",
                    package: "ergentics-prime"
                ),
                .product(
                    name: "PrimeNativeDecoderRuntime",
                    package: "ergentics-prime"
                ),
            ]
        ),
    ]
)
