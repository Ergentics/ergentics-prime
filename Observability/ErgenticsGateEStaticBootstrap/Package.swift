// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "ErgenticsGateEStaticBootstrap",
    platforms: [.macOS(.v14)],
    products: [.executable(name: "ErgenticsGateEStaticBootstrap", targets: ["ErgenticsGateEStaticBootstrap"])],
    targets: [
        .target(name: "GateEStaticBootstrapPrimitives", publicHeadersPath: "include"),
        .target(name: "GateEStaticBootstrapCore", dependencies: ["GateEStaticBootstrapPrimitives"]),
        .executableTarget(name: "ErgenticsGateEStaticBootstrap", dependencies: ["GateEStaticBootstrapCore"]),
        .testTarget(name: "GateEStaticBootstrapCoreTests", dependencies: ["GateEStaticBootstrapCore"]),
    ]
)
