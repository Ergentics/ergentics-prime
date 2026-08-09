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
        .target(
            name: "PrimeLatinProposalIndependentReplay",
            dependencies: [
                "PrimeLatinProposalPairCapture",
                "PrimeLatinProposalGitObservation",
            ]
        ),
        .target(
            name: "PrimeLatinProposalValidationComposition",
            dependencies: [
                "PrimeLatinProposalProducerRevalidationObservation",
                "PrimeLatinProposalIndependentReplay",
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
        .executableTarget(
            name: "PrimeLatinProposalIndependentReplayProbe",
            dependencies: [
                "PrimeLatinProposalIndependentReplay",
            ]
        ),
        .testTarget(
            name: "PrimeLatinProposalPairCaptureTests",
            dependencies: [
                "PrimeLatinProposalPairCapture",
                "PrimeLatinProposalGitObservation",
                "PrimeLatinProposalProducerRevalidationObservation",
                "PrimeLatinProposalIndependentReplay",
                "PrimeLatinProposalValidationComposition",
            ]
        ),
    ]
)
