// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "ErgenticsResearch",
    platforms: [.macOS(.v14)],
    products: [
        .library(
            name: "ErgenticsShotResearchCore",
            targets: ["ErgenticsShotResearchCore"]
        ),
        .executable(
            name: "ErgenticsShotHypothesisChecker",
            targets: ["ErgenticsShotHypothesisChecker"]
        ),
    ],
    targets: [
        .target(
            name: "ErgenticsShotResearchCore",
            exclude: ["Resources"]
        ),
        .executableTarget(
            name: "ErgenticsShotHypothesisChecker",
            dependencies: ["ErgenticsShotResearchCore"],
            linkerSettings: [
                .unsafeFlags(
                    ["-Xlinker", "-S"],
                    .when(configuration: .release)
                ),
            ]
        ),
        .testTarget(
            name: "ErgenticsShotResearchCoreTests",
            dependencies: ["ErgenticsShotResearchCore"]
        ),
    ]
)
