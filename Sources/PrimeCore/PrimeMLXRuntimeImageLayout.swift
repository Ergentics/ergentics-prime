public struct PrimeMLXRuntimeImageLayoutDeclaration:
    Codable,
    Equatable,
    Sendable
{
    public let layoutID: String
    public let layoutVersion: Int
    public let stagedExecutableRelativePath: String
    public let siblingBundleRelativePath: String

    public init(
        layoutID: String,
        layoutVersion: Int,
        stagedExecutableRelativePath: String,
        siblingBundleRelativePath: String
    ) {
        self.layoutID = layoutID
        self.layoutVersion = layoutVersion
        self.stagedExecutableRelativePath =
            stagedExecutableRelativePath
        self.siblingBundleRelativePath =
            siblingBundleRelativePath
    }
}

public enum PrimeMLXRuntimeImageLayout {
    public static let declaration =
        PrimeMLXRuntimeImageLayoutDeclaration(
            layoutID:
                "ergentics_prime_mlx_sibling_bundle",
            layoutVersion: 1,
            stagedExecutableRelativePath:
                "PrimeGPUCalibration.executable",
            siblingBundleRelativePath:
                PrimePinnedMLXMetallib
                    .bundleRelativePath
        )
}
