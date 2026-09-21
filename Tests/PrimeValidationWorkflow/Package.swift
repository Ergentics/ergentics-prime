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
        .library(
            name: "PrimeValidationWorkflowDriverCore",
            targets: ["PrimeValidationWorkflowDriverCore"]
        ),
        .executable(
            name: "PrimeValidationWorkflowFixtureChild",
            targets: ["PrimeValidationWorkflowFixtureChild"]
        ),
        .executable(
            name: "PrimeValidationWorkflowSecureChildIntegration",
            targets: ["PrimeValidationWorkflowSecureChildIntegration"]
        ),
        .executable(
            name: "PrimeValidationWorkflowDriverV2Supervisor",
            targets: ["PrimeValidationWorkflowDriverV2Supervisor"]
        ),
        .executable(
            name: "PrimeValidationWorkflowDriverV2SpawnCanary",
            targets: ["PrimeValidationWorkflowDriverV2SpawnCanary"]
        ),
        .executable(
            name: "PrimeValidationWorkflowDriverV2ShotGovernor",
            targets: ["PrimeValidationWorkflowDriverV2ShotGovernor"]
        ),
        .executable(
            name: "PrimeValidationWorkflowDriverV2SessionFixture",
            targets: ["PrimeValidationWorkflowDriverV2SessionFixture"]
        ),
    ],
    dependencies: [
        .package(
            name: "ergentics-prime",
            path: "../.."
        ),
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
        .target(
            name: "PrimeValidationWorkflowDriverCore",
            dependencies: [
                "PrimeValidationWorkflowContracts",
                .product(
                    name: "PrimeCore",
                    package: "ergentics-prime"
                ),
            ]
        ),
        .executableTarget(
            name: "PrimeValidationWorkflowFixtureChild",
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-S",
                ]),
            ]
        ),
        .executableTarget(
            name: "PrimeValidationWorkflowSecureChildIntegration",
            dependencies: [
                .product(
                    name: "PrimeCore",
                    package: "ergentics-prime"
                ),
            ]
        ),
        .executableTarget(
            name: "PrimeValidationWorkflowDriverV2Supervisor",
            dependencies: [
                "PrimeValidationWorkflowDriverCore",
                .product(
                    name: "PrimeCore",
                    package: "ergentics-prime"
                ),
            ],
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-S",
                ]),
            ]
        ),
        .executableTarget(
            name: "PrimeValidationWorkflowDriverV2SpawnCanary",
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-S",
                ]),
            ]
        ),
        .target(
            name: "PrimeValidationWorkflowDriverV2ShotGovernorCore",
            dependencies: [
                "PrimeValidationWorkflowDriverCore",
                .product(
                    name: "PrimeCore",
                    package: "ergentics-prime"
                ),
            ]
        ),
        .executableTarget(
            name: "PrimeValidationWorkflowDriverV2ShotGovernor",
            dependencies: [
                "PrimeValidationWorkflowDriverV2ShotGovernorCore",
            ],
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-S",
                ]),
            ]
        ),
        .executableTarget(
            name: "PrimeValidationWorkflowDriverV2SessionFixture",
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-S",
                ]),
            ]
        ),
        .testTarget(
            name: "PrimeValidationWorkflowContractsTests",
            dependencies: [
                "PrimeValidationWorkflowContracts",
            ]
        ),
        .testTarget(
            name: "PrimeValidationWorkflowDriverCoreTests",
            dependencies: [
                "PrimeValidationWorkflowDriverCore",
                "PrimeValidationWorkflowDriverV2ShotGovernorCore",
                .product(
                    name: "PrimeCore",
                    package: "ergentics-prime"
                ),
            ],
            resources: [
                .copy("Resources/xctest.list"),
                .copy("Resources/swift-testing.list"),
                .copy("Resources/current-source-inventory-v1-xctest.list"),
                .copy("Resources/current-source-inventory-v1-swift-testing.list"),
            ]
        ),
    ]
)
