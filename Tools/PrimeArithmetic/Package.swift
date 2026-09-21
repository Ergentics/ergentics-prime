// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "PrimeArithmetic",
    platforms: [.macOS(.v14)],
    products: [.executable(name: "PrimeArithmetic", targets: ["PrimeArithmetic"])],
    targets: [.executableTarget(name: "PrimeArithmetic")]
)
