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
    case typedOptimizerRestoreProbe =
        "typed_optimizer_restore_probe"
    case native3BMetalContinuationProbe =
        "native_3b_metal_continuation_probe"
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

    public static let typedOptimizerRestoreProbe =
        PrimeMLXRuntimeImageLayoutDeclaration(
            layoutID:
                "ergentics_prime_typed_optimizer_restore_probe_mlx_sibling_bundle",
            layoutVersion: 1,
            stagedExecutableRelativePath:
                "PrimeTypedOptimizerRestoreProbe.executable",
            siblingBundleRelativePath:
                PrimePinnedMLXMetallib
                    .bundleRelativePath
        )

    public static let native3BMetalContinuationProbe =
        PrimeMLXRuntimeImageLayoutDeclaration(
            layoutID:
                "ergentics_prime_native_3b_metal_continuation_probe_mlx_sibling_bundle",
            layoutVersion: 1,
            stagedExecutableRelativePath:
                "PrimeNative3BMetalContinuationProbe.executable",
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
        case .typedOptimizerRestoreProbe:
            return typedOptimizerRestoreProbe
        case .native3BMetalContinuationProbe:
            return native3BMetalContinuationProbe
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
        case .typedOptimizerRestoreProbe:
            return "PrimeTypedOptimizerRestoreProbe"
        case .native3BMetalContinuationProbe:
            return "PrimeNative3BMetalContinuationProbe"
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
        if declaration == typedOptimizerRestoreProbe {
            return .typedOptimizerRestoreProbe
        }
        if declaration
            == native3BMetalContinuationProbe
        {
            return .native3BMetalContinuationProbe
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
