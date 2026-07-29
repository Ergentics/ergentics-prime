import Foundation

public struct PrimeNativeModelProfile:
    Codable,
    Equatable,
    Sendable
{
    public let profileID: String
    public let modelDimension: Int
    public let layerCount: Int
    public let attentionHeads: Int
    public let keyValueHeads: Int
    public let headDimension: Int
    public let feedForwardDimension: Int
    public let maximumSequenceLength: Int
    public let ropeBase: Int
    public let vocabularySize: Int

    public var parameterCount: Int64 {
        let dimension = Int64(modelDimension)
        let queryHeads = Int64(attentionHeads)
        let keyValueHeads = Int64(keyValueHeads)
        let head = Int64(headDimension)
        let feedForward = Int64(feedForwardDimension)
        let embedding = Int64(vocabularySize) * dimension
        let query = dimension * queryHeads * head
        let keyAndValue =
            2 * dimension * keyValueHeads * head
        let output = queryHeads * head * dimension
        let gatedFeedForward =
            3 * dimension * feedForward
        let blockNorms = 2 * dimension
        let perLayer =
            query
            + keyAndValue
            + output
            + gatedFeedForward
            + blockNorms
        return embedding
            + Int64(layerCount) * perLayer
            + dimension
    }
}

public enum PrimeNativeProfiles {
    public static let exact3B = PrimeNativeModelProfile(
        profileID: "ergentics_prime_native_3b_gqa_v1",
        modelDimension: 3_072,
        layerCount: 28,
        attentionHeads: 24,
        keyValueHeads: 8,
        headDimension: 128,
        feedForwardDimension: 8_192,
        maximumSequenceLength: 2_048,
        ropeBase: 500_000,
        vocabularySize: 512
    )
}
