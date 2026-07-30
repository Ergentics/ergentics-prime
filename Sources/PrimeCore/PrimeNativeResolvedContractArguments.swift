import Foundation

public enum PrimeNativeResolvedContractArgumentError:
    Error,
    Equatable,
    Sendable
{
    case invalidProbeArguments
    case invalidVerifierArguments
}

extension PrimeNativeResolvedContractArgumentError:
    LocalizedError
{
    public var errorDescription: String? {
        switch self {
        case .invalidProbeArguments:
            "required arguments: --resolution-root <absolute canonical path> --prime-root <absolute canonical path> --artifact-root <absolute canonical path>"
        case .invalidVerifierArguments:
            "required arguments: --artifact-root <absolute canonical path>"
        }
    }
}

/// Fixed roots for the post-resolution compatibility adapter.
///
/// The adapter has no companion, archive, source-file, report, executable,
/// schema, seed, or authority knobs. The frozen resolution root is read-only;
/// publication occurs only in a distinct, fresh root.
public struct PrimeNativeResolvedContractArguments:
    Equatable,
    Sendable
{
    public let resolutionRoot: URL
    public let primeRoot: URL
    public let artifactRoot: URL

    public static func parse(
        _ values: [String]
    ) throws -> Self {
        var resolutionRoot: URL?
        var primeRoot: URL?
        var artifactRoot: URL?
        var index = 1
        while index < values.count {
            guard index + 1 < values.count else {
                throw PrimeNativeResolvedContractArgumentError
                    .invalidProbeArguments
            }
            let key = values[index]
            let value: URL
            do {
                value = try canonicalRoot(
                    values[index + 1]
                )
            } catch {
                throw PrimeNativeResolvedContractArgumentError
                    .invalidProbeArguments
            }
            switch key {
            case "--resolution-root":
                guard resolutionRoot == nil else {
                    throw PrimeNativeResolvedContractArgumentError
                        .invalidProbeArguments
                }
                resolutionRoot = value
            case "--prime-root":
                guard primeRoot == nil else {
                    throw PrimeNativeResolvedContractArgumentError
                        .invalidProbeArguments
                }
                primeRoot = value
            case "--artifact-root":
                guard artifactRoot == nil else {
                    throw PrimeNativeResolvedContractArgumentError
                        .invalidProbeArguments
                }
                artifactRoot = value
            default:
                throw PrimeNativeResolvedContractArgumentError
                    .invalidProbeArguments
            }
            index += 2
        }
        guard let resolutionRoot,
              let primeRoot,
              let artifactRoot,
              disjoint(
                  resolutionRoot,
                  artifactRoot
              ),
              primeRoot != resolutionRoot,
              primeRoot != artifactRoot,
              admittedArtifactDescendant(
                  resolutionRoot,
                  of: primeRoot
              ),
              admittedArtifactDescendant(
                  artifactRoot,
                  of: primeRoot
              ) else {
            throw PrimeNativeResolvedContractArgumentError
                .invalidProbeArguments
        }
        return Self(
            resolutionRoot: resolutionRoot,
            primeRoot: primeRoot,
            artifactRoot: artifactRoot
        )
    }

    static func canonicalRoot(
        _ value: String
    ) throws -> URL {
        guard value.hasPrefix("/"),
              value != "/",
              !value.contains("\0") else {
            throw PrimeNativeResolvedContractArgumentError
                .invalidProbeArguments
        }
        let root = URL(
            fileURLWithPath: value,
            isDirectory: true
        )
        guard root.standardizedFileURL.path == value,
              root.resolvingSymlinksInPath()
                .standardizedFileURL.path == value else {
            throw PrimeNativeResolvedContractArgumentError
                .invalidProbeArguments
        }
        return root
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

public struct PrimeNativeResolvedContractVerifierArguments:
    Equatable,
    Sendable
{
    public let artifactRoot: URL

    public static func parse(
        _ values: [String]
    ) throws -> Self {
        guard values.count == 3,
              values[1] == "--artifact-root" else {
            throw PrimeNativeResolvedContractArgumentError
                .invalidVerifierArguments
        }
        let artifactRoot: URL
        do {
            artifactRoot =
                try PrimeNativeResolvedContractArguments
                .canonicalRoot(values[2])
        } catch {
            throw PrimeNativeResolvedContractArgumentError
                .invalidVerifierArguments
        }
        return Self(artifactRoot: artifactRoot)
    }
}
