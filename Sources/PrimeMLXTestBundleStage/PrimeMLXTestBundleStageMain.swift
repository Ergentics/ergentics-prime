import Foundation
import PrimeCore

private enum StageError: Error {
    case invalidArguments
    case unsafeDestination(String)
    case existingBundleMismatch
}

private struct Arguments {
    let sourceHost: URL
    let destinationResourcesRoot: URL

    static func parse() throws -> Self {
        var values = Array(
            CommandLine.arguments.dropFirst()
        )
        var sourceHost: URL?
        var destinationResourcesRoot: URL?
        while !values.isEmpty {
            let key = values.removeFirst()
            guard !values.isEmpty else {
                throw StageError.invalidArguments
            }
            let value = values.removeFirst()
            switch key {
            case "--source-host":
                sourceHost = URL(
                    fileURLWithPath: value
                ).standardizedFileURL
            case "--destination-resources-root":
                destinationResourcesRoot =
                    URL(
                        fileURLWithPath: value,
                        isDirectory: true
                    ).standardizedFileURL
            default:
                throw StageError.invalidArguments
            }
        }
        guard let sourceHost,
              let destinationResourcesRoot
        else {
            throw StageError.invalidArguments
        }
        let contents =
            destinationResourcesRoot
            .deletingLastPathComponent()
        let testBundle =
            contents
            .deletingLastPathComponent()
        guard destinationResourcesRoot
                .lastPathComponent
                == "Resources",
              contents.lastPathComponent
                == "Contents",
              testBundle.pathExtension
                == "xctest"
        else {
            throw StageError.unsafeDestination(
                destinationResourcesRoot.path
            )
        }
        return Self(
            sourceHost: sourceHost,
            destinationResourcesRoot:
                destinationResourcesRoot
        )
    }
}

@main
private enum PrimeMLXTestBundleStageMain {
    static func main() {
        do {
            _ = try
                PrimeMLXRuntimeEnvironmentPolicy
                .validateCurrentProcess()
            let arguments = try Arguments.parse()
            if !FileManager.default
                .fileExists(
                    atPath:
                        arguments
                        .destinationResourcesRoot
                        .path
                )
            {
                try FileManager.default
                    .createDirectory(
                        at:
                            arguments
                            .destinationResourcesRoot,
                        withIntermediateDirectories:
                            false,
                        attributes: [
                            .posixPermissions:
                                NSNumber(
                                    value: 0o700
                                ),
                        ]
                    )
            }
            let root = try PrimeArtifactRoot(
                directoryURL:
                    arguments
                    .destinationResourcesRoot
            )
            let metallibPath =
                PrimePinnedMLXMetallib
                .sourceBundleRelativePath
            let infoPath =
                PrimePinnedMLXMetallib
                .infoPlistSourceRelativePath
            let bundleURL =
                arguments
                .destinationResourcesRoot
                .appendingPathComponent(
                    PrimePinnedMLXMetallib
                    .bundleRelativePath,
                    isDirectory: true
                )
            if FileManager.default
                .fileExists(
                    atPath: bundleURL.path
                )
            {
                let metallib =
                    try root.bindExisting(
                        at: metallibPath,
                        purpose: .immutableData,
                        maximumByteCount:
                            PrimePinnedMLXMetallib
                            .expectedByteCount
                    )
                let info =
                    try root.bindExisting(
                        at: infoPath,
                        purpose: .immutableData,
                        maximumByteCount:
                            PrimePinnedMLXMetallib
                            .expectedInfoPlistByteCount
                    )
                guard metallib.sha256
                        == PrimePinnedMLXMetallib
                        .expectedSHA256,
                      metallib.byteCount
                        == PrimePinnedMLXMetallib
                        .expectedByteCount,
                      info.sha256
                        == PrimePinnedMLXMetallib
                        .expectedInfoPlistSHA256,
                      info.byteCount
                        == PrimePinnedMLXMetallib
                        .expectedInfoPlistByteCount
                else {
                    throw StageError
                        .existingBundleMismatch
                }
                print(
                    "Prime MLX test bundle already exact metallib_sha256=\(metallib.sha256)"
                )
                return
            }
            let binding =
                try PrimePinnedMLXMetallib
                .captureSibling(
                    of: arguments.sourceHost,
                    into: root,
                    runtimeRole:
                        .typedOptimizerRestoreProbe
                )
            print(
                "Prime MLX test bundle staged metallib_sha256=\(binding.artifact.sha256)"
            )
        } catch {
            FileHandle.standardError.write(
                Data(
                    "Prime MLX test bundle staging failed\n"
                        .utf8
                )
            )
            Foundation.exit(EXIT_FAILURE)
        }
    }
}
