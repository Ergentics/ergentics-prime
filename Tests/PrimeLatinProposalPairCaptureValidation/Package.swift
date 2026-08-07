// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "PrimeLatinProposalPairCaptureValidation",
    platforms: [
        .macOS(.v14),
    ],
    targets: [
        .target(
            name: "PrimeLatinProposalPairCapture"
        ),
        .executableTarget(
            name: "PrimeLatinProposalPairCaptureProbe",
            dependencies: [
                "PrimeLatinProposalPairCapture",
            ]
        ),
        .testTarget(
            name: "PrimeLatinProposalPairCaptureTests",
            dependencies: [
                "PrimeLatinProposalPairCapture",
            ]
        ),
    ]
)
