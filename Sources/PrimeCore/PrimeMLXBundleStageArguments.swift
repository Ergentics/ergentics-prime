import Foundation

public enum PrimeMLXBundleStageArgumentError:
    Error,
    Equatable,
    LocalizedError,
    Sendable
{
    case invalidArgument(String)

    public var errorDescription: String? {
        switch self {
        case let .invalidArgument(detail):
            return detail
        }
    }
}

public struct PrimeMLXBundleStageArguments:
    Equatable,
    Sendable
{
    public let sourceHost: URL
    public let destinationHost: URL
    public let runtimeRole: PrimeMLXRuntimeRole

    public static func parse(
        _ commandLineArguments: [String]
    ) throws -> Self {
        var sourceHost: URL?
        var destinationHost: URL?
        var runtimeRole: PrimeMLXRuntimeRole?
        var values = commandLineArguments

        while !values.isEmpty {
            let key = values.removeFirst()
            guard !values.isEmpty else {
                throw PrimeMLXBundleStageArgumentError
                    .invalidArgument(
                        "\(key) requires a value"
                    )
            }
            let value = values.removeFirst()
            switch key {
            case "--source-host":
                guard sourceHost == nil else {
                    throw PrimeMLXBundleStageArgumentError
                        .invalidArgument(
                            "--source-host may be provided once"
                        )
                }
                sourceHost = URL(
                    fileURLWithPath: value
                )
            case "--destination-host":
                guard destinationHost == nil else {
                    throw PrimeMLXBundleStageArgumentError
                        .invalidArgument(
                            "--destination-host may be provided once"
                        )
                }
                destinationHost = URL(
                    fileURLWithPath: value
                )
            case "--runtime-role":
                guard runtimeRole == nil else {
                    throw PrimeMLXBundleStageArgumentError
                        .invalidArgument(
                            "--runtime-role may be provided once"
                        )
                }
                guard let parsedRole =
                        PrimeMLXRuntimeRole(
                            rawValue: value
                        ) else {
                    throw PrimeMLXBundleStageArgumentError
                        .invalidArgument(
                            "unsupported --runtime-role: \(value)"
                        )
                }
                runtimeRole = parsedRole
            default:
                throw PrimeMLXBundleStageArgumentError
                    .invalidArgument(
                        "unsupported argument: \(key)"
                    )
            }
        }

        guard let sourceHost,
              let destinationHost,
              let runtimeRole else {
            throw PrimeMLXBundleStageArgumentError
                .invalidArgument(
                    "--source-host, --destination-host, and --runtime-role are required"
                )
        }
        let resolvedSource =
            sourceHost.resolvingSymlinksInPath()
        let resolvedDestination =
            destinationHost.resolvingSymlinksInPath()
        guard resolvedSource != resolvedDestination else {
            throw PrimeMLXBundleStageArgumentError
                .invalidArgument(
                    "source and destination hosts must differ"
                )
        }

        let expectedDestinationName =
            PrimeMLXRuntimeImageLayout
                .destinationHostExecutableName(
                    for: runtimeRole
                )
        guard resolvedDestination.lastPathComponent
                == expectedDestinationName else {
            throw PrimeMLXBundleStageArgumentError
                .invalidArgument(
                    "--destination-host basename must be " +
                        "\(expectedDestinationName) for " +
                        "--runtime-role \(runtimeRole.rawValue)"
                )
        }

        return Self(
            sourceHost: resolvedSource,
            destinationHost: resolvedDestination,
            runtimeRole: runtimeRole
        )
    }
}
