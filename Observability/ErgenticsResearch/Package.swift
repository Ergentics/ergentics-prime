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
        .executable(
            name: "ErgenticsShotAttemptSupervisor",
            targets: ["ErgenticsShotAttemptSupervisor"]
        ),
        .executable(
            name: "ErgenticsShotHypothesisResultComparator",
            targets: ["ErgenticsShotHypothesisResultComparator"]
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
        .target(
            name: "ErgenticsShotAttemptSupervisorSupport"
        ),
        .executableTarget(
            name: "ErgenticsShotAttemptSupervisor",
            dependencies: ["ErgenticsShotAttemptSupervisorSupport"],
            linkerSettings: [
                .unsafeFlags(
                    ["-Xlinker", "-S"],
                    .when(configuration: .release)
                ),
            ]
        ),
        .executableTarget(
            name: "ErgenticsShotHypothesisResultComparator",
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
            dependencies: [
                "ErgenticsShotResearchCore",
                "ErgenticsShotAttemptSupervisorSupport",
            ]
        ),
    ]
)
