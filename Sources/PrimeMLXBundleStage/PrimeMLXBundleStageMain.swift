import Foundation
import PrimeCore

private enum BundleStageError: Error, LocalizedError {
    case invalidArgument(String)

    var errorDescription: String? {
        switch self {
        case let .invalidArgument(detail):
            return detail
        }
    }
}

private struct Arguments {
    var sourceHost: URL?
    var destinationHost: URL?
}

private func parseArguments() throws -> Arguments {
    var result = Arguments()
    var values = Array(CommandLine.arguments.dropFirst())
    while !values.isEmpty {
        let key = values.removeFirst()
        guard !values.isEmpty else {
            throw BundleStageError.invalidArgument(
                "\(key) requires a value"
            )
        }
        let value = values.removeFirst()
        switch key {
        case "--source-host":
            guard result.sourceHost == nil else {
                throw BundleStageError.invalidArgument(
                    "--source-host may be provided once"
                )
            }
            result.sourceHost = URL(
                fileURLWithPath: value
            )
        case "--destination-host":
            guard result.destinationHost == nil else {
                throw BundleStageError.invalidArgument(
                    "--destination-host may be provided once"
                )
            }
            result.destinationHost = URL(
                fileURLWithPath: value
            )
        default:
            throw BundleStageError.invalidArgument(
                "unsupported argument: \(key)"
            )
        }
    }
    guard let sourceHost = result.sourceHost,
          let destinationHost =
            result.destinationHost else {
        throw BundleStageError.invalidArgument(
            "--source-host and --destination-host are required"
        )
    }
    let resolvedSource =
        sourceHost.resolvingSymlinksInPath()
    let resolvedDestination =
        destinationHost.resolvingSymlinksInPath()
    guard resolvedSource != resolvedDestination else {
        throw BundleStageError.invalidArgument(
            "source and destination hosts must differ"
        )
    }
    result.sourceHost = resolvedSource
    result.destinationHost = resolvedDestination
    return result
}

private func expectedBinding()
    -> PrimePinnedMLXMetallibBinding
{
    PrimePinnedMLXMetallibBinding(
        mlxSwiftVersion:
            PrimePinnedMLXMetallib.mlxSwiftVersion,
        sourceBundleRelativePath:
            PrimePinnedMLXMetallib
                .sourceBundleRelativePath,
        artifact: PrimeArtifactBinding(
            relativePath:
                PrimePinnedMLXMetallib
                    .artifactRelativePath,
            sha256:
                PrimePinnedMLXMetallib
                    .expectedSHA256,
            byteCount:
                PrimePinnedMLXMetallib
                    .expectedByteCount,
            purpose: .immutableData
        ),
        infoPlistSourceRelativePath:
            PrimePinnedMLXMetallib
                .infoPlistSourceRelativePath,
        infoPlistArtifact: PrimeArtifactBinding(
            relativePath:
                PrimePinnedMLXMetallib
                    .infoPlistArtifactRelativePath,
            sha256:
                PrimePinnedMLXMetallib
                    .expectedInfoPlistSHA256,
            byteCount:
                PrimePinnedMLXMetallib
                    .expectedInfoPlistByteCount,
            purpose: .immutableData
        ),
        runtimeEnvironmentPolicy:
            PrimeMLXRuntimeEnvironmentPolicy
                .declaration,
        runtimeImageLayout:
            PrimeMLXRuntimeImageLayout
                .declaration,
        releaseInstrumentationPolicy:
            PrimeReleaseInstrumentationAdmissionPolicy
                .declaration
    )
}

@main
enum PrimeMLXBundleStageCLI {
    static func main() {
        do {
            let arguments = try parseArguments()
            let destinationHost =
                arguments.destinationHost!
            let destinationBundle =
                destinationHost
                    .deletingLastPathComponent()
                    .appendingPathComponent(
                        PrimePinnedMLXMetallib
                            .bundleRelativePath
                    )
            if FileManager.default.fileExists(
                atPath: destinationBundle.path
            ) {
                let binding = expectedBinding()
                try PrimePinnedMLXMetallib
                    .reverifySibling(
                        of: destinationHost,
                        matches: binding
                    )
                print(
                    "Prime MLX bundle already staged: " +
                        "mlx_swift=\(binding.mlxSwiftVersion) " +
                        "metallib_sha256=" +
                        binding.artifact.sha256 + " " +
                        "info_plist_sha256=" +
                        binding.infoPlistArtifact.sha256
                )
                return
            }
            let destinationRoot =
                try PrimeArtifactRoot(
                    directoryURL:
                        destinationHost
                            .deletingLastPathComponent()
                )
            let binding =
                try PrimePinnedMLXMetallib
                    .captureSibling(
                        of: arguments.sourceHost!,
                        into: destinationRoot
                    )
            try PrimePinnedMLXMetallib
                .reverifySibling(
                    of: destinationHost,
                    matches: binding
                )
            print(
                "Prime MLX bundle staged: " +
                    "mlx_swift=\(binding.mlxSwiftVersion) " +
                    "metallib_sha256=\(binding.artifact.sha256) " +
                    "info_plist_sha256=" +
                    binding.infoPlistArtifact.sha256
            )
        } catch {
            FileHandle.standardError.write(
                Data(
                    "Prime MLX bundle staging failed: \(error)\n"
                        .utf8
                )
            )
            Foundation.exit(EXIT_FAILURE)
        }
    }
}
