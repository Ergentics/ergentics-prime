import Foundation

public enum PrimeNativeCorpusReplayArgumentError:
    Error,
    Equatable,
    LocalizedError,
    Sendable
{
    case invalidArguments

    public var errorDescription: String? {
        "required arguments: --prime-root <absolute canonical path> --artifact-root <absolute canonical path beneath prime-root/artifacts>"
    }
}

/// Fixed roots for both phases of the corpus replay.
///
/// There are no donor, corpus, manifest, split, seed, row-count, model,
/// checkpoint, executable, command, schema, or output-name knobs.
public struct PrimeNativeCorpusReplayArguments:
    Equatable,
    Sendable
{
    public let primeRoot: URL
    public let artifactRoot: URL

    public static func parse(
        _ values: [String]
    ) throws -> Self {
        var primeRoot: URL?
        var artifactRoot: URL?
        var index = 1
        while index < values.count {
            guard index + 1 < values.count else {
                throw PrimeNativeCorpusReplayArgumentError
                    .invalidArguments
            }
            let key = values[index]
            let value = try canonicalRoot(
                values[index + 1]
            )
            switch key {
            case "--prime-root":
                guard primeRoot == nil else {
                    throw PrimeNativeCorpusReplayArgumentError
                        .invalidArguments
                }
                primeRoot = value
            case "--artifact-root":
                guard artifactRoot == nil else {
                    throw PrimeNativeCorpusReplayArgumentError
                        .invalidArguments
                }
                artifactRoot = value
            default:
                throw PrimeNativeCorpusReplayArgumentError
                    .invalidArguments
            }
            index += 2
        }
        guard let primeRoot,
              let artifactRoot,
              primeRoot != artifactRoot,
              artifactRoot.path.hasPrefix(
                  primeRoot.path + "/artifacts/"
              )
        else {
            throw PrimeNativeCorpusReplayArgumentError
                .invalidArguments
        }
        return Self(
            primeRoot: primeRoot,
            artifactRoot: artifactRoot
        )
    }

    private static func canonicalRoot(
        _ value: String
    ) throws -> URL {
        guard value.hasPrefix("/"),
              value != "/",
              !value.contains("\0")
        else {
            throw PrimeNativeCorpusReplayArgumentError
                .invalidArguments
        }
        let root = URL(
            fileURLWithPath: value,
            isDirectory: true
        )
        guard root.standardizedFileURL.path == value,
              root.resolvingSymlinksInPath()
                .standardizedFileURL.path == value
        else {
            throw PrimeNativeCorpusReplayArgumentError
                .invalidArguments
        }
        return root
    }
}
