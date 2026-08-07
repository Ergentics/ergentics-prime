// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "PrimeLatinAuthorityFoundationGate",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "PrimeLatinLLMAuthority",
            targets: ["PrimeLatinLLMAuthority"]
        ),
    ],
    targets: [
        .target(
            name: "PrimeLatinLLMAuthority"
        ),
        .testTarget(
            name: "PrimeLatinLLMAuthorityTests",
            dependencies: ["PrimeLatinLLMAuthority"]
        ),
    ]
)
