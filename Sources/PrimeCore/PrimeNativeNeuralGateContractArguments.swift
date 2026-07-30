import Foundation

public enum PrimeNativeNeuralGateContractArgumentError:
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
            "required arguments: --generation-root <absolute canonical path> --corpus-replay-root <absolute canonical path> --prime-root <absolute canonical path> --artifact-root <absolute canonical path>"
        case .invalidVerifierArguments:
            "required arguments: --prime-root <absolute canonical path> --artifact-root <absolute canonical path>"
        }
    }
}

/// Fixed roots for the source-pinned NeuralKit verification-contract
/// projection.
///
/// The two parent roots are immutable inputs. No donor checkout, source-file,
/// model, checkpoint, shard, seed, threshold, schema, or output-name knob is
/// admitted.
public struct PrimeNativeNeuralGateContractArguments:
    Equatable,
    Sendable
{
    public let generationRoot: URL
    public let corpusReplayRoot: URL
    public let primeRoot: URL
    public let artifactRoot: URL

    public static func parse(
        _ values: [String]
    ) throws -> Self {
        var generationRoot: URL?
        var corpusReplayRoot: URL?
        var primeRoot: URL?
        var artifactRoot: URL?
        var index = 1
        while index < values.count {
            guard index + 1 < values.count else {
                throw PrimeNativeNeuralGateContractArgumentError
                    .invalidProbeArguments
            }
            let key = values[index]
            let value: URL
            do {
                value =
                    try PrimeNativeResolvedContractArguments
                    .canonicalRoot(values[index + 1])
            } catch {
                throw PrimeNativeNeuralGateContractArgumentError
                    .invalidProbeArguments
            }
            switch key {
            case "--generation-root":
                guard generationRoot == nil else {
                    throw PrimeNativeNeuralGateContractArgumentError
                        .invalidProbeArguments
                }
                generationRoot = value
            case "--corpus-replay-root":
                guard corpusReplayRoot == nil else {
                    throw PrimeNativeNeuralGateContractArgumentError
                        .invalidProbeArguments
                }
                corpusReplayRoot = value
            case "--prime-root":
                guard primeRoot == nil else {
                    throw PrimeNativeNeuralGateContractArgumentError
                        .invalidProbeArguments
                }
                primeRoot = value
            case "--artifact-root":
                guard artifactRoot == nil else {
                    throw PrimeNativeNeuralGateContractArgumentError
                        .invalidProbeArguments
                }
                artifactRoot = value
            default:
                throw PrimeNativeNeuralGateContractArgumentError
                    .invalidProbeArguments
            }
            index += 2
        }

        guard let generationRoot,
              let corpusReplayRoot,
              let primeRoot,
              let artifactRoot,
              generationRoot != primeRoot,
              corpusReplayRoot != primeRoot,
              artifactRoot != primeRoot,
              admittedArtifactDescendant(
                  generationRoot,
                  of: primeRoot
              ),
              admittedArtifactDescendant(
                  corpusReplayRoot,
                  of: primeRoot
              ),
              admittedArtifactDescendant(
                  artifactRoot,
                  of: primeRoot
              ),
              disjoint(generationRoot, corpusReplayRoot),
              disjoint(generationRoot, artifactRoot),
              disjoint(corpusReplayRoot, artifactRoot)
        else {
            throw PrimeNativeNeuralGateContractArgumentError
                .invalidProbeArguments
        }
        return Self(
            generationRoot: generationRoot,
            corpusReplayRoot: corpusReplayRoot,
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

public struct PrimeNativeNeuralGateContractVerifierArguments:
    Equatable,
    Sendable
{
    public let primeRoot: URL
    public let artifactRoot: URL

    public static func parse(
        _ values: [String]
    ) throws -> Self {
        guard values.count == 5 else {
            throw PrimeNativeNeuralGateContractArgumentError
                .invalidVerifierArguments
        }
        var primeRoot: URL?
        var artifactRoot: URL?
        var index = 1
        while index < values.count {
            let root: URL
            do {
                root =
                    try PrimeNativeResolvedContractArguments
                    .canonicalRoot(values[index + 1])
            } catch {
                throw PrimeNativeNeuralGateContractArgumentError
                    .invalidVerifierArguments
            }
            switch values[index] {
            case "--prime-root":
                guard primeRoot == nil else {
                    throw PrimeNativeNeuralGateContractArgumentError
                        .invalidVerifierArguments
                }
                primeRoot = root
            case "--artifact-root":
                guard artifactRoot == nil else {
                    throw PrimeNativeNeuralGateContractArgumentError
                        .invalidVerifierArguments
                }
                artifactRoot = root
            default:
                throw PrimeNativeNeuralGateContractArgumentError
                    .invalidVerifierArguments
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
            throw PrimeNativeNeuralGateContractArgumentError
                .invalidVerifierArguments
        }
        return Self(
            primeRoot: primeRoot,
            artifactRoot: artifactRoot
        )
    }
}
