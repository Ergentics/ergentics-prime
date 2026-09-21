import Foundation

public enum PrimeNativeGenerationContractArgumentError:
    Error,
    Equatable,
    LocalizedError,
    Sendable
{
    case invalidProbeArguments
    case invalidVerifierArguments

    public var errorDescription: String? {
        switch self {
        case .invalidProbeArguments:
            "required arguments: --adapter-root <absolute canonical path> --prime-root <absolute canonical path> --artifact-root <absolute canonical path>"
        case .invalidVerifierArguments:
            "required arguments: --artifact-root <absolute canonical path>"
        }
    }
}

/// Fixed roots for the standalone fixed-cap/EOS contract projection.
///
/// The frozen adapter evidence is read-only. Publication occurs only in a
/// distinct, fresh Prime artifact root. No donor, source-file, archive,
/// model, checkpoint, schema, budget, seed, target, or execution knobs are
/// admitted.
public struct PrimeNativeGenerationContractArguments:
    Equatable,
    Sendable
{
    public let adapterRoot: URL
    public let primeRoot: URL
    public let artifactRoot: URL

    public static func parse(
        _ values: [String]
    ) throws -> Self {
        var adapterRoot: URL?
        var primeRoot: URL?
        var artifactRoot: URL?
        var index = 1
        while index < values.count {
            guard index + 1 < values.count else {
                throw PrimeNativeGenerationContractArgumentError
                    .invalidProbeArguments
            }
            let key = values[index]
            let value: URL
            do {
                value =
                    try PrimeNativeResolvedContractArguments
                    .canonicalRoot(values[index + 1])
            } catch {
                throw PrimeNativeGenerationContractArgumentError
                    .invalidProbeArguments
            }
            switch key {
            case "--adapter-root":
                guard adapterRoot == nil else {
                    throw PrimeNativeGenerationContractArgumentError
                        .invalidProbeArguments
                }
                adapterRoot = value
            case "--prime-root":
                guard primeRoot == nil else {
                    throw PrimeNativeGenerationContractArgumentError
                        .invalidProbeArguments
                }
                primeRoot = value
            case "--artifact-root":
                guard artifactRoot == nil else {
                    throw PrimeNativeGenerationContractArgumentError
                        .invalidProbeArguments
                }
                artifactRoot = value
            default:
                throw PrimeNativeGenerationContractArgumentError
                    .invalidProbeArguments
            }
            index += 2
        }
        guard let adapterRoot,
              let primeRoot,
              let artifactRoot,
              adapterRoot != primeRoot,
              artifactRoot != primeRoot,
              disjoint(adapterRoot, artifactRoot),
              admittedArtifactDescendant(
                  adapterRoot,
                  of: primeRoot
              ),
              admittedArtifactDescendant(
                  artifactRoot,
                  of: primeRoot
              ) else {
            throw PrimeNativeGenerationContractArgumentError
                .invalidProbeArguments
        }
        return Self(
            adapterRoot: adapterRoot,
            primeRoot: primeRoot,
            artifactRoot: artifactRoot
        )
    }

    private static func admittedArtifactDescendant(
        _ candidate: URL,
        of primeRoot: URL
    ) -> Bool {
        candidate.path.hasPrefix(
            primeRoot.path + "/artifacts/"
        )
    }

    private static func disjoint(
        _ lhs: URL,
        _ rhs: URL
    ) -> Bool {
        let left = lhs.path
        let right = rhs.path
        return left != right
            && !left.hasPrefix(right + "/")
            && !right.hasPrefix(left + "/")
    }
}

public struct PrimeNativeGenerationContractVerifierArguments:
    Equatable,
    Sendable
{
    public let artifactRoot: URL

    public static func parse(
        _ values: [String]
    ) throws -> Self {
        guard values.count == 3,
              values[1] == "--artifact-root" else {
            throw PrimeNativeGenerationContractArgumentError
                .invalidVerifierArguments
        }
        let root: URL
        do {
            root =
                try PrimeNativeResolvedContractArguments
                .canonicalRoot(values[2])
        } catch {
            throw PrimeNativeGenerationContractArgumentError
                .invalidVerifierArguments
        }
        return Self(artifactRoot: root)
    }
}
