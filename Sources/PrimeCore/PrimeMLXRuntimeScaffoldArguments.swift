import Foundation

public enum PrimeMLXRuntimeScaffoldArgumentError:
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

public struct PrimeMLXRuntimeScaffoldArguments:
    Equatable,
    Sendable
{
    public let sourceRoot: URL
    public let destinationHost: URL
    public let runtimeRole: PrimeMLXRuntimeRole

    public static func parse(
        _ commandLineArguments: [String]
    ) throws -> Self {
        var sourceRoot: URL?
        var destinationHost: URL?
        var runtimeRole: PrimeMLXRuntimeRole?
        var values = commandLineArguments

        while !values.isEmpty {
            let key = values.removeFirst()
            guard !values.isEmpty else {
                throw PrimeMLXRuntimeScaffoldArgumentError
                    .invalidArgument(
                        "\(key) requires a value"
                    )
            }
            let value = values.removeFirst()
            switch key {
            case "--source-root":
                guard sourceRoot == nil else {
                    throw PrimeMLXRuntimeScaffoldArgumentError
                        .invalidArgument(
                            "--source-root may be provided once"
                        )
                }
                sourceRoot = URL(
                    fileURLWithPath: value,
                    isDirectory: true
                )
            case "--destination-host":
                guard destinationHost == nil else {
                    throw PrimeMLXRuntimeScaffoldArgumentError
                        .invalidArgument(
                            "--destination-host may be provided once"
                        )
                }
                destinationHost = URL(
                    fileURLWithPath: value
                )
            case "--runtime-role":
                guard runtimeRole == nil else {
                    throw PrimeMLXRuntimeScaffoldArgumentError
                        .invalidArgument(
                            "--runtime-role may be provided once"
                        )
                }
                guard let parsedRole =
                        PrimeMLXRuntimeRole(
                            rawValue: value
                        ) else {
                    throw PrimeMLXRuntimeScaffoldArgumentError
                        .invalidArgument(
                            "unsupported --runtime-role: \(value)"
                        )
                }
                runtimeRole = parsedRole
            default:
                throw PrimeMLXRuntimeScaffoldArgumentError
                    .invalidArgument(
                        "unsupported argument: \(key)"
                    )
            }
        }

        guard let sourceRoot,
              let destinationHost,
              let runtimeRole else {
            throw PrimeMLXRuntimeScaffoldArgumentError
                .invalidArgument(
                    "--source-root, --destination-host, and --runtime-role are required"
                )
        }
        let standardizedSourceRoot =
            sourceRoot.standardizedFileURL
        let standardizedDestination =
            destinationHost.standardizedFileURL
        let resolvedSourceRoot =
            standardizedSourceRoot
            .resolvingSymlinksInPath()
            .standardizedFileURL
        let resolvedDestination =
            standardizedDestination
            .resolvingSymlinksInPath()
            .standardizedFileURL
        guard standardizedSourceRoot
                == resolvedSourceRoot else {
            throw PrimeMLXRuntimeScaffoldArgumentError
                .invalidArgument(
                    "--source-root must not traverse symbolic links"
                )
        }
        guard standardizedDestination
                == resolvedDestination else {
            throw PrimeMLXRuntimeScaffoldArgumentError
                .invalidArgument(
                    "--destination-host must not traverse symbolic links"
                )
        }

        let expectedDestinationName =
            PrimeMLXRuntimeImageLayout
                .destinationHostExecutableName(
                    for: runtimeRole
                )
        guard resolvedDestination.lastPathComponent
                == expectedDestinationName else {
            throw PrimeMLXRuntimeScaffoldArgumentError
                .invalidArgument(
                    "--destination-host basename must be " +
                        "\(expectedDestinationName) for " +
                        "--runtime-role \(runtimeRole.rawValue)"
                )
        }

        return Self(
            sourceRoot: resolvedSourceRoot,
            destinationHost: resolvedDestination,
            runtimeRole: runtimeRole
        )
    }
}
