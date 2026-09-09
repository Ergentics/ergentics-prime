// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "PrimeNativeRuntime",
    platforms: [.macOS(.v14)],
    products: [.library(name: "PrimeNativeRuntime", type: .static, targets: ["PrimeNativeDecoderRuntime", "PrimeNativeGeneration"])],
    dependencies: [.package(path: "Vendor/ergentics-mlx-swift")],
    targets: [
        .target(name: "PrimeCore"),
        .target(name: "PrimeNativeDecoder", dependencies: ["PrimeCore", .product(name: "MLX", package: "ergentics-mlx-swift"), .product(name: "MLXNN", package: "ergentics-mlx-swift")]),
        .target(name: "PrimeNativeDecoderCheckpoint", dependencies: ["PrimeCore", "PrimeNativeDecoder", .product(name: "MLX", package: "ergentics-mlx-swift"), .product(name: "MLXNN", package: "ergentics-mlx-swift")]),
        .target(name: "PrimeNativeGeneration", dependencies: ["PrimeCore", "PrimeNativeDecoder", "PrimeNativeDecoderCheckpoint", .product(name: "MLX", package: "ergentics-mlx-swift")], linkerSettings: [.linkedFramework("Metal")]),
        .target(name: "PrimeNativeDecoderRuntime", dependencies: ["PrimeCore", "PrimeNativeDecoder", "PrimeNativeDecoderCheckpoint", .product(name: "MLX", package: "ergentics-mlx-swift")], linkerSettings: [.linkedFramework("CoreGraphics"), .linkedFramework("Metal")]),
    ]
)
