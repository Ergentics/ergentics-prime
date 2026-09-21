import Foundation

public enum PrimeNativeContractResolutionArgumentError:
    Error,
    Equatable,
    Sendable
{
    case invalidArguments
    case invalidVerifierArguments
}

extension PrimeNativeContractResolutionArgumentError:
    LocalizedError
{
    public var errorDescription: String? {
        switch self {
        case .invalidArguments:
            "required arguments: --companion-root <absolute canonical path> --prime-root <absolute canonical path> --artifact-root <absolute canonical path>"
        case .invalidVerifierArguments:
            "required arguments: --artifact-root <absolute canonical path>"
        }
    }
}

/// Fixed resolver root admission.
///
/// The companion donor must be disjoint from both the Prime source tree and
/// the publication root. The publication root may be a descendant of Prime's
/// ignored `artifacts/` directory, but it may not equal the Prime root.
public struct PrimeNativeContractResolutionArguments:
    Equatable,
    Sendable
{
    public let companionRoot: URL
    public let primeRoot: URL
    public let artifactRoot: URL

    public static func parse(
        _ values: [String]
    ) throws -> Self {
        var companionRoot: URL?
        var primeRoot: URL?
        var artifactRoot: URL?
        var index = 1
        while index < values.count {
            guard index + 1 < values.count else {
                throw PrimeNativeContractResolutionArgumentError
                    .invalidArguments
            }
            let key = values[index]
            let root = try canonicalRoot(values[index + 1])
            switch key {
            case "--companion-root":
                guard companionRoot == nil else {
                    throw PrimeNativeContractResolutionArgumentError
                        .invalidArguments
                }
                companionRoot = root
            case "--prime-root":
                guard primeRoot == nil else {
                    throw PrimeNativeContractResolutionArgumentError
                        .invalidArguments
                }
                primeRoot = root
            case "--artifact-root":
                guard artifactRoot == nil else {
                    throw PrimeNativeContractResolutionArgumentError
                        .invalidArguments
                }
                artifactRoot = root
            default:
                throw PrimeNativeContractResolutionArgumentError
                    .invalidArguments
            }
            index += 2
        }
        guard let companionRoot,
              let primeRoot,
              let artifactRoot,
              disjoint(companionRoot, primeRoot),
              disjoint(companionRoot, artifactRoot),
              primeRoot != artifactRoot,
              !primeRoot.path.hasPrefix(
                  artifactRoot.path + "/"
              ),
              !artifactRoot.path.hasPrefix(
                  primeRoot.path + "/"
              )
                || artifactRoot.path.hasPrefix(
                    primeRoot.path + "/artifacts/"
              ) else {
            throw PrimeNativeContractResolutionArgumentError
                .invalidArguments
        }
        return Self(
            companionRoot: companionRoot,
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
            throw PrimeNativeContractResolutionArgumentError
                .invalidArguments
        }
        let root = URL(
            fileURLWithPath: value,
            isDirectory: true
        )
        guard root.standardizedFileURL.path == value,
              root.resolvingSymlinksInPath()
                .standardizedFileURL.path == value else {
            throw PrimeNativeContractResolutionArgumentError
                .invalidArguments
        }
        return root
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

public struct PrimeNativeContractResolutionVerifierArguments:
    Equatable,
    Sendable
{
    public let artifactRoot: URL

    public static func parse(
        _ values: [String]
    ) throws -> Self {
        guard values.count == 3,
              values[1] == "--artifact-root" else {
            throw PrimeNativeContractResolutionArgumentError
                .invalidVerifierArguments
        }
        let artifactRoot: URL
        do {
            artifactRoot =
                try PrimeNativeContractResolutionArguments
                .canonicalRoot(values[2])
        } catch {
            throw PrimeNativeContractResolutionArgumentError
                .invalidVerifierArguments
        }
        return Self(
            artifactRoot: artifactRoot
        )
    }
}
