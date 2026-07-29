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
            ]
        )
        XCTAssertEqual(
            PrimeMLXRuntimeRole
                .optimizerRestoreProbe.rawValue,
            "optimizer_restore_probe"
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
        XCTAssertThrowsError(
            try PrimeMLXRuntimeImageLayout.require(
                PrimeMLXRuntimeImageLayout
                    .optimizerRestoreProbe,
                for: .calibration
            )
        ) { error in
            XCTAssertEqual(
                error as?
                    PrimeMLXRuntimeImageLayoutError,
                .roleMismatch(
                    expected: .calibration,
                    actual: .optimizerRestoreProbe
                )
            )
        }
        XCTAssertThrowsError(
            try PrimeMLXRuntimeImageLayout.require(
                PrimeMLXRuntimeImageLayout
                    .calibration,
                for: .optimizerRestoreProbe
            )
        ) { error in
            XCTAssertEqual(
                error as?
                    PrimeMLXRuntimeImageLayoutError,
                .roleMismatch(
                    expected:
                        .optimizerRestoreProbe,
                    actual: .calibration
                )
            )
        }
    }
}
