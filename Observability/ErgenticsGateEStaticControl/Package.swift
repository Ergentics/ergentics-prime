// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "ErgenticsGateEStaticControl",
    platforms: [.macOS(.v14)],
    products: [
        .executable(
            name: "ErgenticsGateEJSONProjector",
            targets: ["ErgenticsGateEJSONProjector"]
        ),
        .executable(
            name: "ErgenticsGateECBORProjector",
            targets: ["ErgenticsGateECBORProjector"]
        ),
        .executable(
            name: "ErgenticsGateEDualGraphJoin",
            targets: ["ErgenticsGateEDualGraphJoin"]
        ),
    ],
    targets: [
        .target(name: "GateEJSONAuthority"),
        .target(name: "GateECBORAuthority"),
        .target(name: "GateEDualGraphJoin"),
        .executableTarget(
            name: "ErgenticsGateEJSONProjector",
            dependencies: ["GateEJSONAuthority"]
        ),
        .executableTarget(
            name: "ErgenticsGateECBORProjector",
            dependencies: ["GateECBORAuthority"]
        ),
        .executableTarget(
            name: "ErgenticsGateEDualGraphJoin",
            dependencies: ["GateEDualGraphJoin"]
        ),
        .testTarget(
            name: "GateEJSONAuthorityTests",
            dependencies: ["GateEJSONAuthority"]
        ),
        .testTarget(
            name: "GateECBORAuthorityTests",
            dependencies: ["GateECBORAuthority"]
        ),
        .testTarget(
            name: "GateEDualGraphJoinTests",
            dependencies: [
                "GateEDualGraphJoin",
                "GateEJSONAuthority",
                "GateECBORAuthority",
            ]
        ),
    ]
)
