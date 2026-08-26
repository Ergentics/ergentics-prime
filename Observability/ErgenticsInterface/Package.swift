// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "ErgenticsInterface",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "LedgerProjectionCore", targets: ["LedgerProjectionCore"]),
        .executable(name: "ErgenticsLedgerProjector", targets: ["ErgenticsLedgerProjector"]),
        .executable(name: "ErgenticsInterface", targets: ["ErgenticsInterface"]),
    ],
    targets: [
        .target(
            name: "LedgerProjectionCore",
            resources: [.process("Resources")],
            linkerSettings: [.linkedLibrary("sqlite3")]
        ),
        .executableTarget(
            name: "ErgenticsLedgerProjector",
            dependencies: ["LedgerProjectionCore"]
        ),
        .executableTarget(
            name: "ErgenticsInterface",
            dependencies: ["LedgerProjectionCore"]
        ),
        .testTarget(
            name: "LedgerProjectionCoreTests",
            dependencies: ["LedgerProjectionCore"]
        ),
    ]
)
