import Foundation
import XCTest
@testable import PrimeCore

enum PinnedMLXMetallibTestSupport {
    static func sourceMetallibURL() throws -> URL {
        let environmentPath = ProcessInfo.processInfo
            .environment[
                "PRIME_TEST_PINNED_MLX_METALLIB"
            ]
        let repositoryRoot = URL(
            fileURLWithPath:
                FileManager.default.currentDirectoryPath,
            isDirectory: true
        )
        let candidates = [
            environmentPath.map {
                URL(fileURLWithPath: $0)
            },
            repositoryRoot.appendingPathComponent(
                ".build/apple/Build/Products/Release/" +
                    PrimePinnedMLXMetallib
                    .sourceBundleRelativePath
            ),
            repositoryRoot.appendingPathComponent(
                ".build/prime-pinned-mlx/" +
                    PrimePinnedMLXMetallib
                    .sourceBundleRelativePath
            ),
        ].compactMap { $0 }
        guard let source = candidates.first(where: {
            FileManager.default.fileExists(
                atPath: $0.path
            )
        }) else {
            throw PrimeDurableArtifactError.invalidSemantics(
                "full tests require PRIME_TEST_PINNED_MLX_METALLIB or an exact declared .build staging path for the independently reproduced pinned bundle"
            )
        }
        return source
    }

    static func publish(
        in root: PrimeArtifactRoot,
        runtimeRole: PrimeMLXRuntimeRole =
            .calibration
    ) throws -> PrimePinnedMLXMetallibBinding {
        let source = try sourceMetallibURL()
        let data = try Data(
            contentsOf: source,
            options: [.mappedIfSafe]
        )
        guard UInt64(data.count)
                == PrimePinnedMLXMetallib
                    .expectedByteCount,
              PrimeSHA256.hexDigest(of: data)
                == PrimePinnedMLXMetallib
                    .expectedSHA256 else {
            throw PrimeDurableArtifactError.hashMismatch(
                path: source.path,
                expected:
                    PrimePinnedMLXMetallib
                        .expectedSHA256,
                actual: PrimeSHA256.hexDigest(
                    of: data
                )
            )
        }
        try root.ensurePrivateDirectory(
            at:
                PrimePinnedMLXMetallib
                    .bundleRelativePath
        )
        try root.ensurePrivateDirectory(
            at:
                PrimePinnedMLXMetallib
                    .bundleRelativePath +
                    "/Contents"
        )
        try root.ensurePrivateDirectory(
            at:
                PrimePinnedMLXMetallib
                    .bundleRelativePath +
                    "/Contents/Resources"
        )
        let artifact = try root.publish(
            data,
            at:
                PrimePinnedMLXMetallib
                    .artifactRelativePath,
            purpose: .immutableData
        )
        let infoPlistSource = source
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Info.plist")
        let infoPlistData = try Data(
            contentsOf: infoPlistSource,
            options: [.mappedIfSafe]
        )
        guard UInt64(infoPlistData.count)
                == PrimePinnedMLXMetallib
                    .expectedInfoPlistByteCount,
              PrimeSHA256.hexDigest(
                  of: infoPlistData
              ) == PrimePinnedMLXMetallib
                    .expectedInfoPlistSHA256 else {
            throw PrimeDurableArtifactError.hashMismatch(
                path: infoPlistSource.path,
                expected:
                    PrimePinnedMLXMetallib
                        .expectedInfoPlistSHA256,
                actual: PrimeSHA256.hexDigest(
                    of: infoPlistData
                )
            )
        }
        let infoPlistArtifact = try root.publish(
            infoPlistData,
            at:
                PrimePinnedMLXMetallib
                    .infoPlistArtifactRelativePath,
            purpose: .immutableData
        )
        return PrimePinnedMLXMetallibBinding(
            mlxSwiftVersion:
                PrimePinnedMLXMetallib
                    .mlxSwiftVersion,
            sourceBundleRelativePath:
                PrimePinnedMLXMetallib
                    .sourceBundleRelativePath,
            artifact: artifact,
            infoPlistSourceRelativePath:
                PrimePinnedMLXMetallib
                    .infoPlistSourceRelativePath,
            infoPlistArtifact:
                infoPlistArtifact,
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
}
