import XCTest
@testable import PrimeCore

final class PrimeMLXRuntimeImageLayoutTests:
    XCTestCase
{
    func testFrozenRoleSetAndDeclarations() throws {
        XCTAssertEqual(
            PrimeMLXRuntimeRole.allCases,
            [
                .calibration,
                .optimizerRestoreProbe,
                .typedOptimizerRestoreProbe,
                .native3BMetalContinuationProbe,
            ]
        )
        XCTAssertEqual(
            PrimeMLXRuntimeRole
                .optimizerRestoreProbe.rawValue,
            "optimizer_restore_probe"
        )
        XCTAssertEqual(
            PrimeMLXRuntimeRole
                .typedOptimizerRestoreProbe.rawValue,
            "typed_optimizer_restore_probe"
        )
        XCTAssertEqual(
            PrimeMLXRuntimeRole
                .native3BMetalContinuationProbe
                .rawValue,
            "native_3b_metal_continuation_probe"
        )
        XCTAssertNil(
            PrimeMLXRuntimeRole(
                rawValue: "caller_defined"
            )
        )

        let calibration =
            PrimeMLXRuntimeImageLayout.calibration
        XCTAssertEqual(
            PrimeMLXRuntimeImageLayout.declaration,
            calibration
        )
        XCTAssertEqual(
            calibration.layoutID,
            "ergentics_prime_mlx_sibling_bundle"
        )
        XCTAssertEqual(
            calibration.layoutVersion,
            1
        )
        XCTAssertEqual(
            calibration.stagedExecutableRelativePath,
            "PrimeGPUCalibration.executable"
        )
        XCTAssertEqual(
            calibration.siblingBundleRelativePath,
            PrimePinnedMLXMetallib
                .bundleRelativePath
        )

        let restoreProbe =
            PrimeMLXRuntimeImageLayout
                .optimizerRestoreProbe
        XCTAssertEqual(
            restoreProbe.layoutID,
            "ergentics_prime_optimizer_restore_probe_mlx_sibling_bundle"
        )
        XCTAssertEqual(
            restoreProbe.layoutVersion,
            1
        )
        XCTAssertEqual(
            restoreProbe
                .stagedExecutableRelativePath,
            "PrimeOptimizerRestoreProbe.executable"
        )
        XCTAssertEqual(
            restoreProbe.siblingBundleRelativePath,
            PrimePinnedMLXMetallib
                .bundleRelativePath
        )

        let typedRestoreProbe =
            PrimeMLXRuntimeImageLayout
                .typedOptimizerRestoreProbe
        XCTAssertEqual(
            typedRestoreProbe.layoutID,
            "ergentics_prime_typed_optimizer_restore_probe_mlx_sibling_bundle"
        )
        XCTAssertEqual(
            typedRestoreProbe.layoutVersion,
            1
        )
        XCTAssertEqual(
            typedRestoreProbe
                .stagedExecutableRelativePath,
            "PrimeTypedOptimizerRestoreProbe.executable"
        )
        XCTAssertEqual(
            typedRestoreProbe.siblingBundleRelativePath,
            PrimePinnedMLXMetallib
                .bundleRelativePath
        )

        let native3BMetalContinuationProbe =
            PrimeMLXRuntimeImageLayout
                .native3BMetalContinuationProbe
        XCTAssertEqual(
            native3BMetalContinuationProbe.layoutID,
            "ergentics_prime_native_3b_metal_continuation_probe_mlx_sibling_bundle"
        )
        XCTAssertEqual(
            native3BMetalContinuationProbe
                .layoutVersion,
            1
        )
        XCTAssertEqual(
            native3BMetalContinuationProbe
                .stagedExecutableRelativePath,
            "PrimeNative3BMetalContinuationProbe.executable"
        )
        XCTAssertEqual(
            native3BMetalContinuationProbe
                .siblingBundleRelativePath,
            PrimePinnedMLXMetallib
                .bundleRelativePath
        )
        XCTAssertEqual(
            PrimeMLXRuntimeImageLayout
                .destinationHostExecutableName(
                    for: .calibration
                ),
            "PrimeGPUCalibration"
        )
        XCTAssertEqual(
            PrimeMLXRuntimeImageLayout
                .destinationHostExecutableName(
                    for: .optimizerRestoreProbe
                ),
            "PrimeOptimizerRestoreProbe"
        )
        XCTAssertEqual(
            PrimeMLXRuntimeImageLayout
                .destinationHostExecutableName(
                    for:
                        .typedOptimizerRestoreProbe
                ),
            "PrimeTypedOptimizerRestoreProbe"
        )
        XCTAssertEqual(
            PrimeMLXRuntimeImageLayout
                .destinationHostExecutableName(
                    for:
                        .native3BMetalContinuationProbe
                ),
            "PrimeNative3BMetalContinuationProbe"
        )

        for role in PrimeMLXRuntimeRole.allCases {
            let declaration =
                PrimeMLXRuntimeImageLayout
                    .declaration(for: role)
            XCTAssertEqual(
                try PrimeMLXRuntimeImageLayout
                    .role(for: declaration),
                role
            )
            XCTAssertNoThrow(
                try PrimeMLXRuntimeImageLayout
                    .require(
                        declaration,
                        for: role
                    )
            )
        }
    }

    func testArbitraryLayoutMutationsAreRejected() {
        let calibration =
            PrimeMLXRuntimeImageLayout.calibration
        let mutations = [
            PrimeMLXRuntimeImageLayoutDeclaration(
                layoutID: "caller_defined",
                layoutVersion:
                    calibration.layoutVersion,
                stagedExecutableRelativePath:
                    calibration
                    .stagedExecutableRelativePath,
                siblingBundleRelativePath:
                    calibration
                    .siblingBundleRelativePath
            ),
            PrimeMLXRuntimeImageLayoutDeclaration(
                layoutID: calibration.layoutID,
                layoutVersion: 2,
                stagedExecutableRelativePath:
                    calibration
                    .stagedExecutableRelativePath,
                siblingBundleRelativePath:
                    calibration
                    .siblingBundleRelativePath
            ),
            PrimeMLXRuntimeImageLayoutDeclaration(
                layoutID: calibration.layoutID,
                layoutVersion:
                    calibration.layoutVersion,
                stagedExecutableRelativePath:
                    "CallerDefined.executable",
                siblingBundleRelativePath:
                    calibration
                    .siblingBundleRelativePath
            ),
            PrimeMLXRuntimeImageLayoutDeclaration(
                layoutID: calibration.layoutID,
                layoutVersion:
                    calibration.layoutVersion,
                stagedExecutableRelativePath:
                    calibration
                    .stagedExecutableRelativePath,
                siblingBundleRelativePath:
                    "caller-defined.bundle"
            ),
        ]

        for mutation in mutations {
            XCTAssertThrowsError(
                try PrimeMLXRuntimeImageLayout
                    .role(for: mutation)
            ) { error in
                XCTAssertEqual(
                    error as?
                        PrimeMLXRuntimeImageLayoutError,
                    .undeclaredLayout
                )
            }
        }
    }

    func testCrossRoleSubstitutionIsRejected() {
        for expectedRole
        in PrimeMLXRuntimeRole.allCases {
            for actualRole
            in PrimeMLXRuntimeRole.allCases
            where actualRole != expectedRole {
                XCTAssertThrowsError(
                    try PrimeMLXRuntimeImageLayout
                        .require(
                            PrimeMLXRuntimeImageLayout
                                .declaration(
                                    for: actualRole
                                ),
                            for: expectedRole
                        )
                ) { error in
                    XCTAssertEqual(
                        error as?
                            PrimeMLXRuntimeImageLayoutError,
                        .roleMismatch(
                            expected: expectedRole,
                            actual: actualRole
                        )
                    )
                }
            }
        }
    }
}
