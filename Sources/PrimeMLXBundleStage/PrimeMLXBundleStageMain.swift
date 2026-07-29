import Foundation
import PrimeCore

private func expectedBinding(
    runtimeRole: PrimeMLXRuntimeRole
)
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
                .declaration(
                    for: runtimeRole
                ),
        releaseInstrumentationPolicy:
            PrimeReleaseInstrumentationAdmissionPolicy
                .declaration
    )
}

@main
enum PrimeMLXBundleStageCLI {
    static func main() {
        do {
            let arguments =
                try PrimeMLXBundleStageArguments
                    .parse(
                        Array(
                            CommandLine.arguments
                                .dropFirst()
                        )
                    )
            let runtimeRole = arguments.runtimeRole
            let destinationHost =
                arguments.destinationHost
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
                let binding = expectedBinding(
                    runtimeRole: runtimeRole
                )
                try PrimePinnedMLXMetallib
                    .reverifyStagedRuntimeImage(
                        of: destinationHost,
                        matches: binding,
                        runtimeRole: runtimeRole
                    )
                print(
                    "Prime MLX bundle already staged: " +
                        "runtime_role=\(runtimeRole.rawValue) " +
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
                        of: arguments.sourceHost,
                        into: destinationRoot,
                        runtimeRole: runtimeRole
                    )
            try PrimePinnedMLXMetallib
                .reverifyStagedRuntimeImage(
                    of: destinationHost,
                    matches: binding,
                    runtimeRole: runtimeRole
                )
            print(
                "Prime MLX bundle staged: " +
                    "runtime_role=\(runtimeRole.rawValue) " +
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
