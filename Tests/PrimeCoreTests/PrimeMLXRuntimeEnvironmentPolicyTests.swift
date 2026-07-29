import XCTest
@testable import PrimeCore

final class PrimeMLXRuntimeEnvironmentPolicyTests:
    XCTestCase
{
    func testDeclarationIsFrozenForReceiptBinding() throws {
        let declaration =
            PrimeMLXRuntimeEnvironmentPolicy
                .declaration

        XCTAssertEqual(
            declaration.policyID,
            "ergentics_prime_mlx_runtime_environment"
        )
        XCTAssertEqual(declaration.policyVersion, 1)
        XCTAssertEqual(
            declaration.forbiddenKeyPrefixes,
            [
                "DYLD_",
                "LLVM_PROFILE_",
                "MLX_",
            ]
        )

        let encoded = try JSONEncoder().encode(
            declaration
        )
        XCTAssertEqual(
            try JSONDecoder().decode(
                PrimeMLXRuntimeEnvironmentPolicyDeclaration
                    .self,
                from: encoded
            ),
            declaration
        )
    }

    func testAllowsEnvironmentOutsideForbiddenNamespaces()
        throws
    {
        let declaration =
            try PrimeMLXRuntimeEnvironmentPolicy
                .validate(
                    environment: [
                        "PATH": "/usr/bin",
                        "PRIME_PROFILE": "exact3B",
                        "DYLD": "not-the-prefixed-namespace",
                        "A_DYLD_LIBRARY_PATH": "unrelated",
                        "mlx_debug": "case-sensitive",
                    ]
                )

        XCTAssertEqual(
            declaration,
            PrimeMLXRuntimeEnvironmentPolicy
                .declaration
        )
    }

    func testRejectsEveryForbiddenNamespaceRegardlessOfValue()
        throws
    {
        let forbiddenEnvironments: [
            [String: String]
        ] = [
            ["DYLD_INSERT_LIBRARIES": ""],
            ["LLVM_PROFILE_FILE": "/tmp/profile"],
            ["MLX_DISABLE_COMPILE": "0"],
        ]

        for environment in forbiddenEnvironments {
            let key = try XCTUnwrap(
                environment.keys.first
            )
            XCTAssertThrowsError(
                try PrimeMLXRuntimeEnvironmentPolicy
                    .validate(
                        environment: environment
                    )
            ) { error in
                XCTAssertEqual(
                    error as?
                        PrimeMLXRuntimeEnvironmentPolicyError,
                    .forbiddenEnvironmentKey(key)
                )
            }
        }
    }

    func testRejectsBareForbiddenPrefixes() {
        for key in [
            "DYLD_",
            "LLVM_PROFILE_",
            "MLX_",
        ] {
            XCTAssertThrowsError(
                try PrimeMLXRuntimeEnvironmentPolicy
                    .validate(
                        environment: [key: ""]
                    )
            ) { error in
                XCTAssertEqual(
                    error as?
                        PrimeMLXRuntimeEnvironmentPolicyError,
                    .forbiddenEnvironmentKey(key)
                )
            }
        }
    }

    func testMultipleForbiddenKeysFailDeterministically() {
        XCTAssertThrowsError(
            try PrimeMLXRuntimeEnvironmentPolicy
                .validate(
                    environment: [
                        "MLX_DISABLE_COMPILE": "1",
                        "DYLD_LIBRARY_PATH": "/tmp",
                        "LLVM_PROFILE_FILE": "",
                    ]
                )
        ) { error in
            XCTAssertEqual(
                error as?
                    PrimeMLXRuntimeEnvironmentPolicyError,
                .forbiddenEnvironmentKey(
                    "DYLD_LIBRARY_PATH"
                )
            )
        }
    }
}
