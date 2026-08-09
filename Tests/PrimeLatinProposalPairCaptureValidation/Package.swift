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
        .target(
            name: "PrimeLatinProposalGitObservation",
            dependencies: [
                "PrimeLatinProposalPairCapture",
            ]
        ),
        .target(
            name: "PrimeLatinProposalProducerRevalidationObservation",
            dependencies: [
                "PrimeLatinProposalPairCapture",
                "PrimeLatinProposalGitObservation",
            ]
        ),
        .executableTarget(
            name: "PrimeLatinProposalPairCaptureProbe",
            dependencies: [
                "PrimeLatinProposalPairCapture",
            ]
        ),
        .executableTarget(
            name: "PrimeLatinProposalGitObservationProbe",
            dependencies: [
                "PrimeLatinProposalGitObservation",
            ]
        ),
        .executableTarget(
            name:
                "PrimeLatinProposalProducerRevalidationObservationProbe",
            dependencies: [
                "PrimeLatinProposalProducerRevalidationObservation",
            ]
        ),
        .testTarget(
            name: "PrimeLatinProposalPairCaptureTests",
            dependencies: [
                "PrimeLatinProposalPairCapture",
                "PrimeLatinProposalGitObservation",
                "PrimeLatinProposalProducerRevalidationObservation",
            ]
        ),
    ]
)
