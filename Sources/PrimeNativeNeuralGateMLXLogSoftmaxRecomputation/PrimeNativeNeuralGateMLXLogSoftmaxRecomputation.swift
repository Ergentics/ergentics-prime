import CryptoKit
import Foundation
import MLX
import MLXNN
import PrimeNativeNeuralGateLogitSidecarMechanics

/// Exact source lineage for the Float32 log-softmax recomputation.
///
/// The companion executor and its package lock freeze the historical
/// operation call. The upstream and Ergentics-fork bindings freeze the Swift
/// implementation used here. These are source bindings, not a model, Metal,
/// scientific-independence, process, artifact-publication, or product claim.
public enum PrimeNativeNeuralGateMLXLogSoftmaxProvenance {
    public static let operationID =
        "mlxnn_float32_logsoftmax_axis_minus_one_over_full_512_vocabulary_v1"
    public static let implementationLanguage = "Swift"

    public static let companionRemoteURL =
        "https://github.com/Ergentics/pmhnp-companion-ergentics.git"
    public static let companionRevision =
        "163fc100710ece48119bc25954452d10f6a84f7f"
    public static let companionTreeOID =
        "9009daa4f8a07fbd5897e00b9571cef44ec292db"
    public static let companionExecutorRelativePath =
        "prime-runtime/Sources/PrimeNativeLanguageSwiftCanary/main.swift"
    public static let companionExecutorGitBlobOID =
        "94227842cdff73434c926527a6081aaf20f37155"
    public static let companionExecutorByteCount:
        UInt64 = 174_006
    public static let companionExecutorSHA256 =
        "7a3ba9477a7ac82dccfe6dcc7ec09af738b40298cdab6b259ddf1e9d36ec15b4"
    public static let companionPackageResolvedRelativePath =
        "prime-runtime/Package.resolved"
    public static let companionPackageResolvedGitBlobOID =
        "18aef69512c82c3e6cdff192f3aa0a6ee13c702e"
    public static let companionPackageResolvedByteCount:
        UInt64 = 1_949
    public static let companionPackageResolvedSHA256 =
        "cf1ba313dcb0c959e80ba09d6cbe0c56bcd921523bda5cec2c682c8ae7696ab3"

    public static let upstreamMLXSwiftRemoteURL =
        "https://github.com/ml-explore/mlx-swift.git"
    public static let upstreamMLXSwiftRevision =
        "072b684acaae80b6a463abab3a103732f33774bf"
    public static let upstreamMLXSwiftTreeOID =
        "aecc4c90c4720b0624def30913f139eb1e878ea5"
    public static let upstreamActivationsRelativePath =
        "Source/MLXNN/Activations.swift"
    public static let upstreamActivationsGitBlobOID =
        "f5ee9205eac15b537f6a9552371c30255c88e69e"
    public static let upstreamActivationsByteCount:
        UInt64 = 19_101
    public static let upstreamActivationsSHA256 =
        "c6e82121f1a7efceca0de234b5ef0058162f70bcccc4cef63b6d85d524ef1beb"

    public static let forkMLXSwiftRemoteURL =
        "https://github.com/Ergentics/ergentics-mlx-swift.git"
    public static let forkMLXSwiftRevision =
        "d37885a278f1c37484a94d0f401a418735e66519"
    public static let forkMLXSwiftTreeOID =
        "5310749549cca107fc1bb07d82dacf043bc02b9e"
    public static let forkActivationsRelativePath =
        "Source/MLXNN/Activations.swift"
    public static let forkActivationsGitBlobOID =
        "a40618fac9f7c2226599c0219eccc11fcfcb0df5"
    public static let forkActivationsByteCount:
        UInt64 = 23_918
    public static let forkActivationsSHA256 =
        "5145539a33687bb4e9ce5ac00b821fef9f5e18652818c278c1807443b5e552f1"
    public static let exactLogSoftmaxFunctionSerializationID =
        "utf8_exact_three_line_function_declaration_body_and_closing_brace_with_final_lf_v1"
    public static let exactLogSoftmaxFunctionSHA256 =
        "8d576115e1be7648d4a4da72c025893d23e67b1d30a53646d09e74bfe58fc639"

    public static let sourcePinnedOperationImplemented =
        true
    public static let companionRuntimeDependencyPresent =
        false
    public static let neuralKitRuntimeDependencyPresent =
        false
    public static let modelExecutionClaimed = false
    public static let metalExecutionAuthorityClaimed =
        false
    public static let durableStageBArtifactPublished =
        false
    public static let independentProcessReceiptPublished =
        false
    public static let scientificIndependenceClaimed =
        false
    public static let calibrationEvidenceClaimed =
        false
    public static let productAuthorityClaimed = false
}

public enum PrimeNativeNeuralGateMLXLogSoftmaxRecomputationError:
    Error,
    Equatable,
    Sendable
{
    case invalidDictionarySHA256
    case emptyDictionary
    case dictionaryVectorCountLimitExceeded(
        observed: Int
    )
    case invalidVocabularyCount(
        vectorIndex: Int,
        observed: Int
    )
    case nonfiniteInput(
        vectorIndex: Int,
        tokenID: Int
    )
    case elementCountOverflow
    case inputDTypeMismatch
    case inputShapeMismatch
    case outputDTypeMismatch
    case outputShapeMismatch
    case outputElementCountMismatch
    case nonfiniteOutput(
        vectorIndex: Int,
        tokenID: Int
    )
    case positiveLogProbability(
        vectorIndex: Int,
        tokenID: Int
    )
}

/// In-memory result of exact source-pinned MLX Float32 recomputation.
///
/// This value is intentionally not `Codable`. It is repository mechanics,
/// not a durable Stage-B artifact or receipt.
public struct
    PrimeNativeNeuralGateMLXFloat32LogSoftmaxObservation:
    Equatable,
    Sendable
{
    public let operationID: String
    public let inputDictionarySHA256: String
    public let evaluationSeed: Int
    public let vectorCount: Int
    public let vocabularyCount: Int
    public let logProbabilityVectors: [[Float]]
    public let bitPatternSerializationID:
        String
    public let bitPatternSHA256: String
    public let inputDType: String
    public let outputDType: String
    public let axis: Int
    public let durableArtifactPublished: Bool
    public let modelExecutionClaimed: Bool
    public let metalExecutionAuthorityClaimed:
        Bool
    public let scientificIndependenceClaimed:
        Bool

    fileprivate init(
        inputDictionarySHA256: String,
        evaluationSeed: Int,
        logProbabilityVectors: [[Float]],
        bitPatternSHA256: String
    ) {
        operationID =
            PrimeNativeNeuralGateMLXLogSoftmaxProvenance
            .operationID
        self.inputDictionarySHA256 =
            inputDictionarySHA256
        self.evaluationSeed = evaluationSeed
        vectorCount = logProbabilityVectors.count
        vocabularyCount =
            PrimeNativeNeuralGateMLXFloat32LogSoftmaxRecomputer
            .fullVocabularyLogitCount
        self.logProbabilityVectors =
            logProbabilityVectors
        bitPatternSerializationID =
            PrimeNativeNeuralGateMLXFloat32LogSoftmaxRecomputer
            .bitPatternSerializationID
        self.bitPatternSHA256 =
            bitPatternSHA256
        inputDType = "float32"
        outputDType = "float32"
        axis = -1
        durableArtifactPublished = false
        modelExecutionClaimed = false
        metalExecutionAuthorityClaimed = false
        scientificIndependenceClaimed = false
    }
}

public enum
    PrimeNativeNeuralGateMLXFloat32LogSoftmaxRecomputer
{
    public static let fullVocabularyLogitCount =
        512
    public static let maximumDictionaryVectorCount =
        65_536
    public static let maximumMLXBatchVectorCount =
        256
    public static let bitPatternSerializationID =
        "primelsm1_then_uint32_be_vector_count_uint32_be_vocabulary_count_then_float32_bit_patterns_uint32_be_row_major_v1"

    private static let bitPatternMagic =
        Data("PRIMELSM1".utf8)

    public static func recompute(
        dictionary:
            PrimeNativeNeuralGateValidatedLogitDictionary
    ) throws
        -> PrimeNativeNeuralGateMLXFloat32LogSoftmaxObservation
    {
        try recompute(
            vectorCount: dictionary.entryCount,
            inputDictionarySHA256:
                dictionary
                .canonicalFileSHA256,
            evaluationSeed:
                dictionary.replicateContext
                .evaluationSeed,
            vectorAt: {
                try dictionary.fullVocabularyLogits(
                    at: UInt32($0)
                )
            }
        )
    }

    static func recompute(
        fullVocabularyLogitVectors:
            [[Float]],
        inputDictionarySHA256: String,
        evaluationSeed: Int = 1_618
    ) throws
        -> PrimeNativeNeuralGateMLXFloat32LogSoftmaxObservation
    {
        try recompute(
            vectorCount:
                fullVocabularyLogitVectors.count,
            inputDictionarySHA256:
                inputDictionarySHA256,
            evaluationSeed: evaluationSeed,
            vectorAt: {
                fullVocabularyLogitVectors[$0]
            }
        )
    }

    private static func recompute(
        vectorCount: Int,
        inputDictionarySHA256: String,
        evaluationSeed: Int,
        vectorAt: (Int) throws -> [Float]
    ) throws
        -> PrimeNativeNeuralGateMLXFloat32LogSoftmaxObservation
    {
        guard isLowercaseSHA256(
            inputDictionarySHA256
        ) else {
            throw PrimeNativeNeuralGateMLXLogSoftmaxRecomputationError
                .invalidDictionarySHA256
        }
        guard vectorCount > 0
        else {
            throw PrimeNativeNeuralGateMLXLogSoftmaxRecomputationError
                .emptyDictionary
        }
        guard vectorCount
                <= maximumDictionaryVectorCount
        else {
            throw PrimeNativeNeuralGateMLXLogSoftmaxRecomputationError
                .dictionaryVectorCountLimitExceeded(
                    observed: vectorCount
                )
        }
        let elementCountOverflow =
            vectorCount
            .multipliedReportingOverflow(
                by: fullVocabularyLogitCount
            ).overflow
        guard !elementCountOverflow else {
            throw PrimeNativeNeuralGateMLXLogSoftmaxRecomputationError
                .elementCountOverflow
        }

        var vectors: [[Float]] = []
        vectors.reserveCapacity(
            vectorCount
        )
        var batchStart = 0
        while batchStart < vectorCount {
            let batchEnd = min(
                batchStart
                    + maximumMLXBatchVectorCount,
                vectorCount
            )
            let batchVectorCount =
                batchEnd - batchStart
            var batchVectors: [[Float]] = []
            batchVectors.reserveCapacity(
                batchVectorCount
            )
            for vectorIndex in
                batchStart ..< batchEnd
            {
                let vector = try vectorAt(
                    vectorIndex
                )
                guard vector.count
                        == fullVocabularyLogitCount
                else {
                    throw PrimeNativeNeuralGateMLXLogSoftmaxRecomputationError
                        .invalidVocabularyCount(
                            vectorIndex:
                                vectorIndex,
                            observed:
                                vector.count
                        )
                }
                for (
                    tokenID,
                    value
                ) in vector.enumerated() {
                    guard value.isFinite else {
                        throw PrimeNativeNeuralGateMLXLogSoftmaxRecomputationError
                            .nonfiniteInput(
                                vectorIndex:
                                    vectorIndex,
                                tokenID:
                                    tokenID
                            )
                    }
                }
                batchVectors.append(vector)
            }
            let batchValues =
                batchVectors.flatMap { $0 }
            let expectedShape = [
                batchVectorCount,
                fullVocabularyLogitCount,
            ]
            let input = MLXArray(batchValues)
                .reshaped(expectedShape)
            guard input.dtype == .float32 else {
                throw PrimeNativeNeuralGateMLXLogSoftmaxRecomputationError
                    .inputDTypeMismatch
            }
            guard input.shape == expectedShape else {
                throw PrimeNativeNeuralGateMLXLogSoftmaxRecomputationError
                    .inputShapeMismatch
            }

            let output = MLXNN.logSoftmax(
                input,
                axis: -1
            )
            eval(output)
            guard output.dtype == .float32 else {
                throw PrimeNativeNeuralGateMLXLogSoftmaxRecomputationError
                    .outputDTypeMismatch
            }
            guard output.shape == expectedShape else {
                throw PrimeNativeNeuralGateMLXLogSoftmaxRecomputationError
                    .outputShapeMismatch
            }
            let outputValues =
                output.asArray(Float.self)
            guard outputValues.count
                    == batchValues.count
            else {
                throw PrimeNativeNeuralGateMLXLogSoftmaxRecomputationError
                    .outputElementCountMismatch
            }

            for localVectorIndex in
                0 ..< batchVectorCount
            {
                let vectorIndex =
                    batchStart + localVectorIndex
                let start =
                    localVectorIndex
                    * fullVocabularyLogitCount
                let end =
                    start
                    + fullVocabularyLogitCount
                let vector = Array(
                    outputValues[start ..< end]
                )
                for (
                    tokenID,
                    value
                ) in vector.enumerated() {
                    guard value.isFinite else {
                        throw PrimeNativeNeuralGateMLXLogSoftmaxRecomputationError
                            .nonfiniteOutput(
                                vectorIndex:
                                    vectorIndex,
                                tokenID: tokenID
                            )
                    }
                    guard value <= 0 else {
                        throw PrimeNativeNeuralGateMLXLogSoftmaxRecomputationError
                            .positiveLogProbability(
                                vectorIndex:
                                    vectorIndex,
                                tokenID: tokenID
                            )
                    }
                }
                vectors.append(vector)
            }
            batchStart = batchEnd
        }
        let sha256 =
            bitPatternSHA256(vectors)
        return PrimeNativeNeuralGateMLXFloat32LogSoftmaxObservation(
            inputDictionarySHA256:
                inputDictionarySHA256,
            evaluationSeed: evaluationSeed,
            logProbabilityVectors: vectors,
            bitPatternSHA256: sha256
        )
    }

    static func bitPatternSHA256(
        _ vectors: [[Float]]
    ) -> String {
        var hasher = SHA256()
        hasher.update(data: bitPatternMagic)
        var header = Data()
        appendUInt32(
            UInt32(vectors.count),
            to: &header
        )
        appendUInt32(
            UInt32(fullVocabularyLogitCount),
            to: &header
        )
        hasher.update(data: header)
        for vector in vectors {
            var vectorData = Data()
            vectorData.reserveCapacity(
                fullVocabularyLogitCount * 4
            )
            for value in vector {
                appendUInt32(
                    value.bitPattern,
                    to: &vectorData
                )
            }
            hasher.update(data: vectorData)
        }
        return hasher.finalize().map {
            String(format: "%02x", $0)
        }.joined()
    }

    private static func appendUInt32(
        _ value: UInt32,
        to data: inout Data
    ) {
        var bigEndian = value.bigEndian
        withUnsafeBytes(of: &bigEndian) {
            data.append(contentsOf: $0)
        }
    }

    private static func isLowercaseSHA256(
        _ value: String
    ) -> Bool {
        value.utf8.count == 64
            && value.utf8.allSatisfy {
                ($0 >= 48 && $0 <= 57)
                    || ($0 >= 97 && $0 <= 102)
            }
    }
}
