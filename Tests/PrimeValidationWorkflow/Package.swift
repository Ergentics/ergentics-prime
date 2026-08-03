// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "PrimeValidationWorkflow",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "PrimeValidationWorkflowContracts",
            targets: ["PrimeValidationWorkflowContracts"]
        ),
    ],
    dependencies: [
        .package(path: "../.."),
    ],
    targets: [
        .target(
            name: "PrimeValidationWorkflowContracts",
            dependencies: [
                .product(
                    name: "PrimeCore",
                    package: "ergentics-prime"
                ),
            ]
        ),
        .testTarget(
            name: "PrimeValidationWorkflowContractsTests",
            dependencies: [
                "PrimeValidationWorkflowContracts",
            ]
        ),
    ]
)
