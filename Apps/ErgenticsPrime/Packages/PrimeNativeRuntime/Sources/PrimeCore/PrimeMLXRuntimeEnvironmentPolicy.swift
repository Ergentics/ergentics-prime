import Foundation

/// Frozen receipt material for the environment policy applied before any MLX
/// device access.
public struct PrimeMLXRuntimeEnvironmentPolicyDeclaration:
    Codable,
    Equatable,
    Sendable
{
    public let policyID: String
    public let policyVersion: Int
    public let forbiddenKeyPrefixes: [String]

    public init(
        policyID: String,
        policyVersion: Int,
        forbiddenKeyPrefixes: [String]
    ) {
        self.policyID = policyID
        self.policyVersion = policyVersion
        self.forbiddenKeyPrefixes =
            forbiddenKeyPrefixes
    }
}

public enum PrimeMLXRuntimeEnvironmentPolicyError:
    Error,
    Equatable,
    Sendable
{
    case forbiddenEnvironmentKey(String)
}

/// Fail-closed admission policy for the process environment used by the
/// maintained MLX executor.
///
/// Values are deliberately ignored. Presence of any key in a forbidden
/// namespace is sufficient to reject execution.
public enum PrimeMLXRuntimeEnvironmentPolicy {
    public static let declaration =
        PrimeMLXRuntimeEnvironmentPolicyDeclaration(
            policyID:
                "ergentics_prime_mlx_runtime_environment",
            policyVersion: 1,
            forbiddenKeyPrefixes: [
                "DYLD_",
                "LLVM_PROFILE_",
                "MLX_",
            ]
        )

    @discardableResult
    public static func validate(
        environment: [String: String]
    ) throws
        -> PrimeMLXRuntimeEnvironmentPolicyDeclaration
    {
        let forbiddenKey = environment.keys
            .filter { key in
                declaration.forbiddenKeyPrefixes
                    .contains { prefix in
                        key.hasPrefix(prefix)
                    }
            }
            .sorted()
            .first
        if let forbiddenKey {
            throw PrimeMLXRuntimeEnvironmentPolicyError
                .forbiddenEnvironmentKey(
                    forbiddenKey
                )
        }
        return declaration
    }

    @discardableResult
    public static func validateCurrentProcess(
        processInfo: ProcessInfo = .processInfo
    ) throws
        -> PrimeMLXRuntimeEnvironmentPolicyDeclaration
    {
        try validate(
            environment: processInfo.environment
        )
    }
}
