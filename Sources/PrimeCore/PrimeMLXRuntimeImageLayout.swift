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

public enum PrimeMLXRuntimeRole:
    String,
    Codable,
    CaseIterable,
    Sendable
{
    case calibration
    case optimizerRestoreProbe =
        "optimizer_restore_probe"
}

public enum PrimeMLXRuntimeImageLayoutError:
    Error,
    Equatable,
    Sendable
{
    case undeclaredLayout
    case roleMismatch(
        expected: PrimeMLXRuntimeRole,
        actual: PrimeMLXRuntimeRole
    )
}

public enum PrimeMLXRuntimeImageLayout {
    public static let calibration =
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

    public static let optimizerRestoreProbe =
        PrimeMLXRuntimeImageLayoutDeclaration(
            layoutID:
                "ergentics_prime_optimizer_restore_probe_mlx_sibling_bundle",
            layoutVersion: 1,
            stagedExecutableRelativePath:
                "PrimeOptimizerRestoreProbe.executable",
            siblingBundleRelativePath:
                PrimePinnedMLXMetallib
                    .bundleRelativePath
        )

    /// Compatibility spelling for the original calibration role.
    public static let declaration = calibration

    public static func declaration(
        for role: PrimeMLXRuntimeRole
    ) -> PrimeMLXRuntimeImageLayoutDeclaration {
        switch role {
        case .calibration:
            return calibration
        case .optimizerRestoreProbe:
            return optimizerRestoreProbe
        }
    }

    public static func destinationHostExecutableName(
        for role: PrimeMLXRuntimeRole
    ) -> String {
        switch role {
        case .calibration:
            return "PrimeGPUCalibration"
        case .optimizerRestoreProbe:
            return "PrimeOptimizerRestoreProbe"
        }
    }

    public static func role(
        for declaration:
            PrimeMLXRuntimeImageLayoutDeclaration
    ) throws -> PrimeMLXRuntimeRole {
        if declaration == calibration {
            return .calibration
        }
        if declaration == optimizerRestoreProbe {
            return .optimizerRestoreProbe
        }
        throw PrimeMLXRuntimeImageLayoutError
            .undeclaredLayout
    }

    public static func require(
        _ declaration:
            PrimeMLXRuntimeImageLayoutDeclaration,
        for expectedRole: PrimeMLXRuntimeRole
    ) throws {
        let actualRole = try role(
            for: declaration
        )
        guard actualRole == expectedRole else {
            throw PrimeMLXRuntimeImageLayoutError
                .roleMismatch(
                    expected: expectedRole,
                    actual: actualRole
                )
        }
    }
}
