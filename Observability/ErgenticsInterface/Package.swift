// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "ErgenticsInterface",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "LedgerProjectionCore", targets: ["LedgerProjectionCore"]),
        .library(name: "DisposalProjectionCore", targets: ["DisposalProjectionCore"]),
        .executable(name: "ErgenticsLedgerProjector", targets: ["ErgenticsLedgerProjector"]),
        .executable(name: "ErgenticsDisposalProjector", targets: ["ErgenticsDisposalProjector"]),
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
        .target(
            name: "DisposalProjectionPrimitivesC",
            publicHeadersPath: "include"
        ),
        .target(
            name: "DisposalProjectionCore",
            dependencies: ["DisposalProjectionPrimitivesC"],
            resources: [.process("Resources")],
            linkerSettings: [.linkedLibrary("sqlite3")]
        ),
        .executableTarget(
            name: "ErgenticsDisposalProjector",
            dependencies: ["DisposalProjectionCore"]
        ),
        .executableTarget(
            name: "ErgenticsInterface",
            dependencies: ["LedgerProjectionCore", "DisposalProjectionCore"]
        ),
        .testTarget(
            name: "LedgerProjectionCoreTests",
            dependencies: ["LedgerProjectionCore"]
        ),
        .testTarget(
            name: "DisposalProjectionCoreTests",
            dependencies: ["DisposalProjectionCore"]
        ),
    ]
)
