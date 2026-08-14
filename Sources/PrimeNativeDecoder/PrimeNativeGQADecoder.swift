// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import PrimeCore
import MLX
import MLXNN

public enum PrimeNativeGQADecoderConfigurationError:
    Error,
    Equatable,
    Sendable
{
    case nonPositive(String)
    case modelWidthMismatch(expected: Int, observed: Int)
    case queryHeadGroupingInvalid(queryHeads: Int, keyValueHeads: Int)
    case rotaryHeadWidthMustBeEven(Int)
    case invalidRMSNormEpsilon(Float)
    case invalidRoPETheta(Float)
    case runtimeDimensionExceedsInt32(name: String, value: Int)
    case parameterCountOverflow
}

public enum PrimeNativeGQADecoderInputError:
    Error,
    Equatable,
    Sendable
{
    case emptyTokenBatch
    case emptyTokenSequence
    case emptyTokenSequenceInBatch(row: Int)
    case raggedTokenBatch(row: Int, expected: Int, observed: Int)
    case tokenIDOutOfRange(index: Int, value: Int, vocabularySize: Int)
    case batchTokenIDOutOfRange(
        row: Int,
        index: Int,
        value: Int,
        vocabularySize: Int)
    case negativePositionOffset(Int)
    case nonZeroPositionOffsetRequiresCache(Int)
    case sequenceExceedsMaximum(offset: Int, count: Int, maximum: Int)
}

public enum PrimeNativeGQADecoderCacheError:
    Error,
    Equatable,
    Sendable
{
    case nonPositiveBatchSize(Int)
    case batchSizeExceedsInt32(Int)
    case decoderIdentityMismatch
    case batchSizeMismatch(expected: Int, observed: Int)
    case inconsistentLayerState(layer: Int)
    case materializationRequired(position: Int)
    case noMaterializationPending
    case cachePoisoned
    case modelParametersChanged(expected: UInt64, observed: UInt64)
}

/// Immutable geometry for Prime's first owned grouped-query decoder.
///
/// This is implementation mechanics only. A configuration does not bind a
/// tokenizer, checkpoint, training run, Prime decision, or product authority.
public struct PrimeNativeGQADecoderConfiguration:
    Equatable,
    Sendable
{
    public static let architectureSchema =
        PrimeNativeDecoderDerivedDeltaPlan.frozenV1.architectureSchema
    public static let implementationID =
        PrimeNativeDecoderDerivedDeltaPlan.frozenV1
            .authoritativeImplementationID

    public let vocabularySize: Int
    public let modelWidth: Int
    public let layerCount: Int
    public let queryHeadCount: Int
    public let keyValueHeadCount: Int
    public let headWidth: Int
    public let intermediateWidth: Int
    public let maximumSequenceLength: Int
    public let ropeTheta: Float
    public let rmsNormEpsilon: Float
    public let uniqueParameterCount: Int64

    public var keyValueProjectionWidth: Int {
        keyValueHeadCount * headWidth
    }

    public var queryHeadsPerKeyValueHead: Int {
        queryHeadCount / keyValueHeadCount
    }

    public init(
        vocabularySize: Int,
        modelWidth: Int,
        layerCount: Int,
        queryHeadCount: Int,
        keyValueHeadCount: Int,
        headWidth: Int,
        intermediateWidth: Int,
        maximumSequenceLength: Int,
        ropeTheta: Float = 10_000,
        rmsNormEpsilon: Float = 1e-5
    ) throws {
        for (name, value) in [
            ("vocabulary_size", vocabularySize),
            ("model_width", modelWidth),
            ("layer_count", layerCount),
            ("query_head_count", queryHeadCount),
            ("key_value_head_count", keyValueHeadCount),
            ("head_width", headWidth),
            ("intermediate_width", intermediateWidth),
            ("maximum_sequence_length", maximumSequenceLength),
        ] where value <= 0 {
            throw PrimeNativeGQADecoderConfigurationError
                .nonPositive(name)
        }

        let expectedWidth = queryHeadCount.multipliedReportingOverflow(
            by: headWidth)
        guard !expectedWidth.overflow else {
            throw PrimeNativeGQADecoderConfigurationError
                .parameterCountOverflow
        }
        guard modelWidth == expectedWidth.partialValue else {
            throw PrimeNativeGQADecoderConfigurationError
                .modelWidthMismatch(
                    expected: expectedWidth.partialValue,
                    observed: modelWidth)
        }
        guard queryHeadCount >= keyValueHeadCount,
              queryHeadCount.isMultiple(of: keyValueHeadCount)
        else {
            throw PrimeNativeGQADecoderConfigurationError
                .queryHeadGroupingInvalid(
                    queryHeads: queryHeadCount,
                    keyValueHeads: keyValueHeadCount)
        }
        guard headWidth.isMultiple(of: 2) else {
            throw PrimeNativeGQADecoderConfigurationError
                .rotaryHeadWidthMustBeEven(headWidth)
        }
        guard rmsNormEpsilon.isFinite, rmsNormEpsilon > 0 else {
            throw PrimeNativeGQADecoderConfigurationError
                .invalidRMSNormEpsilon(rmsNormEpsilon)
        }
        guard ropeTheta.isFinite, ropeTheta > 0 else {
            throw PrimeNativeGQADecoderConfigurationError
                .invalidRoPETheta(ropeTheta)
        }
        for (name, value) in [
            ("vocabulary_size", vocabularySize),
            ("model_width", modelWidth),
            ("layer_count", layerCount),
            ("query_head_count", queryHeadCount),
            ("key_value_head_count", keyValueHeadCount),
            ("head_width", headWidth),
            ("intermediate_width", intermediateWidth),
            ("maximum_sequence_length", maximumSequenceLength),
        ] where value > Int(Int32.max) {
            throw PrimeNativeGQADecoderConfigurationError
                .runtimeDimensionExceedsInt32(name: name, value: value)
        }
        let keyValueProjectionWidth = keyValueHeadCount
            .multipliedReportingOverflow(by: headWidth)
        guard !keyValueProjectionWidth.overflow else {
            throw PrimeNativeGQADecoderConfigurationError
                .parameterCountOverflow
        }

        self.vocabularySize = vocabularySize
        self.modelWidth = modelWidth
        self.layerCount = layerCount
        self.queryHeadCount = queryHeadCount
        self.keyValueHeadCount = keyValueHeadCount
        self.headWidth = headWidth
        self.intermediateWidth = intermediateWidth
        self.maximumSequenceLength = maximumSequenceLength
        self.ropeTheta = ropeTheta
        self.rmsNormEpsilon = rmsNormEpsilon
        self.uniqueParameterCount = try Self.deriveUniqueParameterCount(
            vocabularySize: vocabularySize,
            modelWidth: modelWidth,
            layerCount: layerCount,
            keyValueProjectionWidth: keyValueProjectionWidth.partialValue,
            intermediateWidth: intermediateWidth)
    }

    /// Small true-GQA body for deterministic structure and forward tests only.
    static func syntheticFixture() throws -> Self {
        try Self(
            vocabularySize: 32,
            modelWidth: 16,
            layerCount: 2,
            queryHeadCount: 4,
            keyValueHeadCount: 2,
            headWidth: 4,
            intermediateWidth: 32,
            maximumSequenceLength: 16)
    }

    /// The frozen Logic-10M MHA geometry expressed by this generic decoder.
    /// Constructing the value is inventory only; the derived-delta contract
    /// does not claim numerical parity with the predecessor implementation.
    public static func logic10MInventory() throws -> Self {
        try Self(
            vocabularySize: 16_384,
            modelWidth: 256,
            layerCount: 8,
            queryHeadCount: 4,
            keyValueHeadCount: 4,
            headWidth: 64,
            intermediateWidth: 640,
            maximumSequenceLength: 2_048,
            ropeTheta: 10_000,
            rmsNormEpsilon: 1e-6)
    }

    /// Native-300M replacement-candidate geometry with a caller-owned
    /// tokenizer vocabulary. This is inventory only: constructing the value
    /// does not allocate or authorize execution of the model.
    public static func native300MInventory(vocabularySize: Int) throws -> Self {
        try Self(
            vocabularySize: vocabularySize,
            modelWidth: 1_024,
            layerCount: 24,
            queryHeadCount: 16,
            keyValueHeadCount: 4,
            headWidth: 64,
            intermediateWidth: 2_816,
            maximumSequenceLength: 2_048,
            ropeTheta: 10_000)
    }

    private static func deriveUniqueParameterCount(
        vocabularySize: Int,
        modelWidth: Int,
        layerCount: Int,
        keyValueProjectionWidth: Int,
        intermediateWidth: Int
    ) throws -> Int64 {
        let vocabulary = Int64(vocabularySize)
        let width = Int64(modelWidth)
        let layers = Int64(layerCount)
        let keyValueWidth = Int64(keyValueProjectionWidth)
        let intermediate = Int64(intermediateWidth)

        let embedding = try checkedMultiply(vocabulary, width)
        let twoNorms = try checkedMultiply(2, width)
        let twoSquareProjections = try checkedMultiply(
            2,
            checkedMultiply(width, width))
        let keyValueProjections = try checkedMultiply(
            2,
            checkedMultiply(width, keyValueWidth))
        let feedForward = try checkedMultiply(
            3,
            checkedMultiply(width, intermediate))
        let perLayer = try checkedAdd(
            checkedAdd(twoNorms, twoSquareProjections),
            checkedAdd(keyValueProjections, feedForward))
        return try checkedAdd(
            checkedAdd(embedding, checkedMultiply(layers, perLayer)),
            width)
    }

    private static func checkedMultiply(
        _ lhs: Int64,
        _ rhs: Int64
    ) throws -> Int64 {
        let result = lhs.multipliedReportingOverflow(by: rhs)
        guard !result.overflow else {
            throw PrimeNativeGQADecoderConfigurationError
                .parameterCountOverflow
        }
        return result.partialValue
    }

    private static func checkedAdd(
        _ lhs: Int64,
        _ rhs: Int64
    ) throws -> Int64 {
        let result = lhs.addingReportingOverflow(rhs)
        guard !result.overflow else {
            throw PrimeNativeGQADecoderConfigurationError
                .parameterCountOverflow
        }
        return result.partialValue
    }
}

final class PrimeNativeGQALayerCacheState {
    static let capacityStep = 256

    private(set) var keys: MLXArray
    private(set) var values: MLXArray

    private init(keys: MLXArray, values: MLXArray) {
        self.keys = keys
        self.values = values
    }

    static func make(
        keys newKeys: MLXArray,
        values newValues: MLXArray,
        maximumSequenceLength: Int
    ) -> PrimeNativeGQALayerCacheState {
        let capacity = storageCapacity(
            required: newKeys.dim(2),
            maximum: maximumSequenceLength)
        let keys = MLXArray.zeros(
            [newKeys.dim(0), newKeys.dim(1), capacity, newKeys.dim(3)],
            dtype: newKeys.dtype)
        let values = MLXArray.zeros(
            [
                newValues.dim(0),
                newValues.dim(1),
                capacity,
                newValues.dim(3),
            ],
            dtype: newValues.dtype)
        let state = PrimeNativeGQALayerCacheState(
            keys: keys,
            values: values)
        _ = state.append(
            keys: newKeys,
            values: newValues,
            previousPosition: 0,
            maximumSequenceLength: maximumSequenceLength)
        return state
    }

    func append(
        keys newKeys: MLXArray,
        values newValues: MLXArray,
        previousPosition: Int,
        maximumSequenceLength: Int
    ) -> (keys: MLXArray, values: MLXArray) {
        let nextPosition = previousPosition + newKeys.dim(2)
        if nextPosition > keys.dim(2) {
            let nextCapacity = Self.storageCapacity(
                required: nextPosition,
                maximum: maximumSequenceLength)
            let addedCapacity = nextCapacity - keys.dim(2)
            let addedKeys = MLXArray.zeros(
                [keys.dim(0), keys.dim(1), addedCapacity, keys.dim(3)],
                dtype: keys.dtype)
            let addedValues = MLXArray.zeros(
                [
                    values.dim(0),
                    values.dim(1),
                    addedCapacity,
                    values.dim(3),
                ],
                dtype: values.dtype)
            keys = concatenated([keys, addedKeys], axis: 2)
            values = concatenated([values, addedValues], axis: 2)
        }

        keys[.ellipsis, previousPosition ..< nextPosition, 0...] = newKeys
        values[.ellipsis, previousPosition ..< nextPosition, 0...] =
            newValues
        return (
            keys: keys[.ellipsis, ..<nextPosition, 0...],
            values: values[.ellipsis, ..<nextPosition, 0...])
    }

    static func storageCapacity(
        required: Int,
        maximum: Int
    ) -> Int {
        precondition(required > 0 && required <= maximum)
        let rounded =
            ((required + capacityStep - 1) / capacityStep) * capacityStep
        return min(maximum, rounded)
    }
}

final class PrimeNativeGQACacheIdentity {
    private(set) var parameterRevision: UInt64 = 0

    func recordParameterMutation() {
        parameterRevision &+= 1
    }
}

/// Caller-owned, append-only inference state for one decoder instance.
///
/// The cache is intentionally a mutable, non-Sendable reference. A caller must
/// not share it between concurrent evaluations. It binds one decoder instance,
/// one rectangular batch size, and a uniform position across every layer.
/// Private K/V backing storage grows in bounded 256-token chunks and exposes
/// only its active prefix to attention. It is not a checkpoint, serializable
/// artifact, or source of model authority. Reset or discard it after any model
/// parameter mutation.
public final class PrimeNativeGQADecoderCache {
    public let batchSize: Int
    public let layerCount: Int
    public let keyValueHeadCount: Int
    public let headWidth: Int
    public let maximumSequenceLength: Int
    public private(set) var position: Int
    public private(set) var isPoisoned: Bool

    fileprivate let decoderIdentity: PrimeNativeGQACacheIdentity
    fileprivate var boundParameterRevision: UInt64
    fileprivate var layerStates: [PrimeNativeGQALayerCacheState?]
    fileprivate var pendingLogits: MLXArray?

    fileprivate init(
        decoderIdentity: PrimeNativeGQACacheIdentity,
        configuration: PrimeNativeGQADecoderConfiguration,
        batchSize: Int
    ) {
        self.decoderIdentity = decoderIdentity
        self.batchSize = batchSize
        self.layerCount = configuration.layerCount
        self.keyValueHeadCount = configuration.keyValueHeadCount
        self.headWidth = configuration.headWidth
        self.maximumSequenceLength = configuration.maximumSequenceLength
        self.position = 0
        self.isPoisoned = false
        self.boundParameterRevision = decoderIdentity.parameterRevision
        self.layerStates = Array(
            repeating: nil,
            count: configuration.layerCount)
        self.pendingLogits = nil
    }

    public var isEmpty: Bool {
        position == 0
    }

    public var isMaterializationPending: Bool {
        pendingLogits != nil
    }

    static func validatedBatchSize(_ batchSize: Int) throws -> Int {
        guard batchSize > 0 else {
            throw PrimeNativeGQADecoderCacheError
                .nonPositiveBatchSize(batchSize)
        }
        guard batchSize <= Int(Int32.max) else {
            throw PrimeNativeGQADecoderCacheError
                .batchSizeExceedsInt32(batchSize)
        }
        return batchSize
    }

    static func validatedNextPosition(
        current: Int,
        appending count: Int,
        maximum: Int
    ) throws -> Int {
        guard current >= 0,
              count > 0,
              current <= maximum,
              count <= maximum - current
        else {
            throw PrimeNativeGQADecoderInputError
                .sequenceExceedsMaximum(
                    offset: current,
                    count: count,
                    maximum: maximum)
        }
        return current + count
    }

    /// Discards cached activations while retaining decoder and batch binding.
    public func reset() {
        position = 0
        isPoisoned = false
        boundParameterRevision = decoderIdentity.parameterRevision
        layerStates = Array(repeating: nil, count: layerCount)
        pendingLogits = nil
    }

    /// Realizes returned logits and the private backing state as one inference
    /// boundary. Call once before reusing this cache for the next token/chunk
    /// to prevent an unbounded lazy graph from accumulating.
    public func materialize() throws {
        guard !isPoisoned else {
            throw PrimeNativeGQADecoderCacheError.cachePoisoned
        }
        guard boundParameterRevision
                == decoderIdentity.parameterRevision
        else {
            let error = PrimeNativeGQADecoderCacheError
                .modelParametersChanged(
                    expected: boundParameterRevision,
                    observed: decoderIdentity.parameterRevision)
            pendingLogits = nil
            isPoisoned = true
            throw error
        }
        guard let pendingLogits else {
            throw PrimeNativeGQADecoderCacheError
                .noMaterializationPending
        }
        var arrays = [pendingLogits]
        for state in layerStates.compactMap({ $0 }) {
            arrays.append(state.keys)
            arrays.append(state.values)
        }
        do {
            try checkedEval(arrays)
            self.pendingLogits = nil
        } catch {
            self.pendingLogits = nil
            isPoisoned = true
            throw error
        }
    }

    var layerStateShapes: [(keys: [Int], values: [Int])?] {
        layerStates.map { state in
            state.map {
                (
                    keys: $0.keys[.ellipsis, ..<position, 0...].shape,
                    values: $0.values[.ellipsis, ..<position, 0...].shape)
            }
        }
    }

    var layerStateCapacities: [Int?] {
        layerStates.map { $0?.keys.dim(2) }
    }

    fileprivate func commit(
        _ states: [PrimeNativeGQALayerCacheState],
        position: Int,
        logits: MLXArray
    ) {
        precondition(states.count == layerCount)
        precondition(pendingLogits == nil)
        self.layerStates = states.map(Optional.some)
        self.position = position
        self.pendingLogits = logits
    }
}

final class PrimeNativeGQAAttention: Module {
    private let configuration: PrimeNativeGQADecoderConfiguration

    @ModuleInfo(key: "query_projection")
    private var queryProjection: Linear
    @ModuleInfo(key: "key_projection")
    private var keyProjection: Linear
    @ModuleInfo(key: "value_projection")
    private var valueProjection: Linear
    @ModuleInfo(key: "output_projection")
    private var outputProjection: Linear
    @ModuleInfo(key: "rotary_position_encoding")
    private var rotaryPositionEncoding: RoPE

    init(configuration: PrimeNativeGQADecoderConfiguration) {
        self.configuration = configuration
        self._queryProjection.wrappedValue = Linear(
            configuration.modelWidth,
            configuration.modelWidth,
            bias: false)
        self._keyProjection.wrappedValue = Linear(
            configuration.modelWidth,
            configuration.keyValueProjectionWidth,
            bias: false)
        self._valueProjection.wrappedValue = Linear(
            configuration.modelWidth,
            configuration.keyValueProjectionWidth,
            bias: false)
        self._outputProjection.wrappedValue = Linear(
            configuration.modelWidth,
            configuration.modelWidth,
            bias: false)
        self._rotaryPositionEncoding.wrappedValue = RoPE(
            dimensions: configuration.headWidth,
            traditional: false,
            base: configuration.ropeTheta)
        super.init()
    }

    func callAsFunction(
        _ input: MLXArray,
        positionOffset: Int
    ) -> MLXArray {
        let projected = projectedQueriesKeysValues(
            input,
            positionOffset: positionOffset)
        return attend(
            queries: projected.queries,
            keys: projected.keys,
            values: projected.values)
    }

    func forward(
        _ input: MLXArray,
        positionOffset: Int,
        cachedState: PrimeNativeGQALayerCacheState?
    ) -> (output: MLXArray, state: PrimeNativeGQALayerCacheState) {
        let (queries, keys, values) = projectedQueriesKeysValues(
            input,
            positionOffset: positionOffset)

        let state = cachedState
            ?? PrimeNativeGQALayerCacheState.make(
                keys: keys,
                values: values,
                maximumSequenceLength:
                    configuration.maximumSequenceLength)
        let active: (keys: MLXArray, values: MLXArray)
        if cachedState == nil {
            active = (
                keys: state.keys[.ellipsis, ..<keys.dim(2), 0...],
                values: state.values[.ellipsis, ..<values.dim(2), 0...])
        } else {
            active = state.append(
                keys: keys,
                values: values,
                previousPosition: positionOffset,
                maximumSequenceLength:
                    configuration.maximumSequenceLength)
        }

        return (
            output: attend(
                queries: queries,
                keys: active.keys,
                values: active.values),
            state: state)
    }

    private func attend(
        queries: MLXArray,
        keys: MLXArray,
        values: MLXArray
    ) -> MLXArray {
        var attended = MLXFast.scaledDotProductAttention(
            queries: queries,
            keys: keys,
            values: values,
            scale: 1 / Float(configuration.headWidth).squareRoot(),
            mask: .causal)
        attended = attended
            .transposed(0, 2, 1, 3)
            .flattened(start: -2, end: -1)
        return outputProjection(attended)
    }

    func projectedQueriesKeysValues(
        _ input: MLXArray,
        positionOffset: Int
    ) -> (queries: MLXArray, keys: MLXArray, values: MLXArray) {
        let batchSize = input.dim(0)
        let sequenceLength = input.dim(1)

        var queries = queryProjection(input)
            .reshaped(
                batchSize,
                sequenceLength,
                configuration.queryHeadCount,
                configuration.headWidth)
            .transposed(0, 2, 1, 3)
        var keys = keyProjection(input)
            .reshaped(
                batchSize,
                sequenceLength,
                configuration.keyValueHeadCount,
                configuration.headWidth)
            .transposed(0, 2, 1, 3)
        let values = valueProjection(input)
            .reshaped(
                batchSize,
                sequenceLength,
                configuration.keyValueHeadCount,
                configuration.headWidth)
            .transposed(0, 2, 1, 3)

        // The pinned MLX scalar-offset RoPE specialization dispatches only
        // one batch plane when `sequenceLength == 1`. Supplying one explicit
        // offset per rectangular batch row keeps batch-one on the same
        // specialization while forcing the correct batch-aware kernel for
        // batched decoding.
        let positionOffsets = MLXArray(
            Array(
                repeating: Int32(positionOffset),
                count: batchSize))
        queries = rotaryPositionEncoding(
            queries,
            offset: positionOffsets)
        keys = rotaryPositionEncoding(
            keys,
            offset: positionOffsets)
        return (queries, keys, values)
    }
}

private final class PrimeNativeSwiGLU: Module {
    @ModuleInfo(key: "gate_projection")
    private var gateProjection: Linear
    @ModuleInfo(key: "up_projection")
    private var upProjection: Linear
    @ModuleInfo(key: "down_projection")
    private var downProjection: Linear

    init(configuration: PrimeNativeGQADecoderConfiguration) {
        self._gateProjection.wrappedValue = Linear(
            configuration.modelWidth,
            configuration.intermediateWidth,
            bias: false)
        self._upProjection.wrappedValue = Linear(
            configuration.modelWidth,
            configuration.intermediateWidth,
            bias: false)
        self._downProjection.wrappedValue = Linear(
            configuration.intermediateWidth,
            configuration.modelWidth,
            bias: false)
        super.init()
    }

    func callAsFunction(_ input: MLXArray) -> MLXArray {
        downProjection(silu(gateProjection(input)) * upProjection(input))
    }
}

private final class PrimeNativeGQADecoderBlock: Module {
    @ModuleInfo(key: "attention_norm")
    private var attentionNorm: RMSNorm
    @ModuleInfo(key: "attention")
    private var attention: PrimeNativeGQAAttention
    @ModuleInfo(key: "feed_forward_norm")
    private var feedForwardNorm: RMSNorm
    @ModuleInfo(key: "feed_forward")
    private var feedForward: PrimeNativeSwiGLU

    init(configuration: PrimeNativeGQADecoderConfiguration) {
        self._attentionNorm.wrappedValue = RMSNorm(
            dimensions: configuration.modelWidth,
            eps: configuration.rmsNormEpsilon)
        self._attention.wrappedValue = PrimeNativeGQAAttention(
            configuration: configuration)
        self._feedForwardNorm.wrappedValue = RMSNorm(
            dimensions: configuration.modelWidth,
            eps: configuration.rmsNormEpsilon)
        self._feedForward.wrappedValue = PrimeNativeSwiGLU(
            configuration: configuration)
        super.init()
    }

    func callAsFunction(
        _ input: MLXArray,
        positionOffset: Int
    ) -> MLXArray {
        var hidden = input
        hidden = hidden + attention(
            attentionNorm(hidden),
            positionOffset: positionOffset)
        return hidden + feedForward(feedForwardNorm(hidden))
    }

    func forward(
        _ input: MLXArray,
        positionOffset: Int,
        cachedState: PrimeNativeGQALayerCacheState?
    ) -> (
        output: MLXArray,
        state: PrimeNativeGQALayerCacheState
    ) {
        var hidden = input
        let attended = attention.forward(
            attentionNorm(hidden),
            positionOffset: positionOffset,
            cachedState: cachedState)
        hidden = hidden + attended.output
        return (
            output: hidden + feedForward(feedForwardNorm(hidden)),
            state: attended.state)
    }
}

/// First-party decoder body with no LM wrapper, inherited model identity, or
/// product-app dependency. It evaluates complete prefixes and owns an opaque,
/// append-only KV cache for rectangular prompt prefill and uniform batched
/// continuation. Checkpoint and canary integration remain separate surfaces.
public final class PrimeNativeGQADecoder: Module {
    public static let defaultInitializationSeed: UInt64 = 42

    public let configuration: PrimeNativeGQADecoderConfiguration
    private let cacheIdentity = PrimeNativeGQACacheIdentity()

    @ModuleInfo(key: "token_embedding")
    private var tokenEmbedding: Embedding
    @ModuleInfo(key: "layers")
    private var layers: [PrimeNativeGQADecoderBlock]
    @ModuleInfo(key: "final_norm")
    private var finalNorm: RMSNorm

    private init(configuration: PrimeNativeGQADecoderConfiguration) {
        self.configuration = configuration
        self._tokenEmbedding.wrappedValue = Embedding(
            embeddingCount: configuration.vocabularySize,
            dimensions: configuration.modelWidth)
        self._layers.wrappedValue = (0 ..< configuration.layerCount).map { _ in
            PrimeNativeGQADecoderBlock(configuration: configuration)
        }
        self._finalNorm.wrappedValue = RMSNorm(
            dimensions: configuration.modelWidth,
            eps: configuration.rmsNormEpsilon)
        super.init()
    }

    public static func make(
        configuration: PrimeNativeGQADecoderConfiguration,
        seed: UInt64 = defaultInitializationSeed
    ) -> PrimeNativeGQADecoder {
        let randomState = MLXRandom.RandomState(seed: seed)
        return withRandomState(randomState) {
            PrimeNativeGQADecoder(configuration: configuration)
        }
    }

    /// Records standard `MLXNN.Module` parameter updates so an existing cache
    /// cannot silently mix activations from two parameter revisions. Direct
    /// child-module or raw-parameter-handle mutation is outside the supported
    /// cache API.
    @discardableResult
    public override func update(
        parameters: ModuleParameters,
        verify: VerifyUpdate,
        path: [String] = [],
        modulePath: [String] = []
    ) throws -> Self {
        cacheIdentity.recordParameterMutation()
        let updated = try super.update(
            parameters: parameters,
            verify: verify,
            path: path,
            modulePath: modulePath)
        return updated
    }

    @discardableResult
    public override func update(
        modules: ModuleChildren,
        verify: VerifyUpdate,
        path: [String] = [],
        modulePath: [String] = []
    ) throws -> Self {
        cacheIdentity.recordParameterMutation()
        let updated = try super.update(
            modules: modules,
            verify: verify,
            path: path,
            modulePath: modulePath)
        return updated
    }

    public override func updateModule(
        key: String,
        _ value: Any
    ) throws {
        cacheIdentity.recordParameterMutation()
        try super.updateModule(key: key, value)
    }

    public func makeCache(
        batchSize: Int
    ) throws -> PrimeNativeGQADecoderCache {
        let batchSize = try PrimeNativeGQADecoderCache
            .validatedBatchSize(batchSize)
        return PrimeNativeGQADecoderCache(
            decoderIdentity: cacheIdentity,
            configuration: configuration,
            batchSize: batchSize)
    }

    func callAsFunction(
        _ tokenIDs: MLXArray,
        positionOffset: Int = 0
    ) -> MLXArray {
        precondition(tokenIDs.ndim == 2, "token IDs must have rank two")
        let sequenceLength = tokenIDs.dim(1)
        precondition(sequenceLength > 0, "token sequence must not be empty")
        precondition(positionOffset >= 0, "position offset must not be negative")
        precondition(
            positionOffset == 0,
            "nonzero position offsets require the future KV-cache path")
        precondition(
            positionOffset <= configuration.maximumSequenceLength - sequenceLength,
            "token sequence exceeds maximum sequence length")

        var hidden = tokenEmbedding(tokenIDs)
        for layer in layers {
            hidden = layer(hidden, positionOffset: positionOffset)
        }
        hidden = finalNorm(hidden)
        return tokenEmbedding.asLinear(hidden)
    }

    /// Package-only full-token training path. This intentionally has no cache,
    /// position-offset, tokenizer, checkpoint, or generation surface.
    package func trainingLogitsNoCache(
        _ rankTwoTokenIDs: MLXArray
    ) -> MLXArray {
        precondition(
            rankTwoTokenIDs.ndim == 2,
            "training token IDs must have rank two")
        precondition(
            rankTwoTokenIDs.dtype == .int32,
            "training token IDs must use int32 storage")
        return self(rankTwoTokenIDs, positionOffset: 0)
    }

    /// Opt-in training path for the Stage-5 replacement assay. The flattened
    /// dense one-hot input projection is the only changed operation; decoder
    /// layers, final normalization, and the tied output projection are shared
    /// with the maintained path.
    package func trainingLogitsNoCacheFlattenedDenseOneHotMatmulInputEmbeddingV1(
        _ tokens: MLXArray
    ) -> MLXArray {
        var hidden = flattenedDenseOneHotMatmulInputEmbeddingV1(tokens)
        for layer in layers {
            hidden = layer(hidden, positionOffset: 0)
        }
        hidden = finalNorm(hidden)
        return tokenEmbedding.asLinear(hidden)
    }

    /// Returns the two input-embedding forwards from this exact model state.
    /// The dense member performs one and only one validated dense construction.
    package func trainingInputEmbeddingForwardPairForFlattenedDenseOneHotMatmulAssayV1(
        _ rankTwoTokenIDs: MLXArray
    ) -> (
        maintainedGather: MLXArray,
        flattenedDenseOneHotMatmul: MLXArray
    ) {
        let maintainedGather = tokenEmbedding(rankTwoTokenIDs)
        let flattenedDenseOneHotMatmul =
            flattenedDenseOneHotMatmulInputEmbeddingV1(rankTwoTokenIDs)
        return (maintainedGather, flattenedDenseOneHotMatmul)
    }

    private func flattenedDenseOneHotMatmulInputEmbeddingV1(
        _ tokens: MLXArray
    ) -> MLXArray {
        precondition(tokens.ndim == 2)
        precondition(tokens.dtype == .int32)

        let batchSize = tokens.dim(0)
        let sequenceLength = tokens.dim(1)
        precondition(batchSize > 0)
        precondition(sequenceLength > 0)
        precondition(
            sequenceLength <= configuration.maximumSequenceLength)

        let flattenedCount = batchSize.multipliedReportingOverflow(
            by: sequenceLength)
        precondition(!flattenedCount.overflow)

        let vocabularySize = configuration.vocabularySize
        guard let checkedInt32V = Int32(exactly: vocabularySize) else {
            preconditionFailure()
        }
        let tokenBounds = (
            (tokens .>= Int32(0)) .&& (tokens .< checkedInt32V)
        ).all()
        do {
            try checkedEval(tokenBounds)
        } catch {
            preconditionFailure()
        }
        StreamOrDevice.default.stream.synchronize()
        precondition(tokenBounds.item(Bool.self))

        let embeddingWeight = tokenEmbedding.weight
        precondition(embeddingWeight.dtype == .float32)
        precondition(
            embeddingWeight.shape
                == [configuration.vocabularySize, configuration.modelWidth])

        let flattenedTokens = tokens.reshaped(
            [flattenedCount.partialValue, 1])
        precondition(
            flattenedTokens.shape == [flattenedCount.partialValue, 1])
        let vocabulary = arange(vocabularySize, dtype: .int32)
            .reshaped([1, vocabularySize])
        precondition(vocabulary.shape == [1, vocabularySize])
        let oneHot = (flattenedTokens .== vocabulary).asType(.float32)
        precondition(oneHot.dtype == .float32)
        precondition(
            oneHot.shape == [flattenedCount.partialValue, vocabularySize])
        let flattenedEmbedding = matmul(oneHot, embeddingWeight)
        precondition(flattenedEmbedding.dtype == .float32)
        precondition(
            flattenedEmbedding.shape
                == [flattenedCount.partialValue, configuration.modelWidth])
        let restoredEmbedding = flattenedEmbedding.reshaped(
            [batchSize, sequenceLength, configuration.modelWidth])
        precondition(
            restoredEmbedding.shape
                == [batchSize, sequenceLength, configuration.modelWidth])
        return restoredEmbedding
    }

    public func forward(
        tokenIDs: [Int],
        positionOffset: Int = 0
    ) throws -> MLXArray {
        guard !tokenIDs.isEmpty else {
            throw PrimeNativeGQADecoderInputError.emptyTokenSequence
        }
        guard positionOffset >= 0 else {
            throw PrimeNativeGQADecoderInputError
                .negativePositionOffset(positionOffset)
        }
        guard positionOffset == 0 else {
            throw PrimeNativeGQADecoderInputError
                .nonZeroPositionOffsetRequiresCache(positionOffset)
        }
        guard positionOffset
                <= configuration.maximumSequenceLength - tokenIDs.count
        else {
            throw PrimeNativeGQADecoderInputError
                .sequenceExceedsMaximum(
                    offset: positionOffset,
                    count: tokenIDs.count,
                    maximum: configuration.maximumSequenceLength)
        }
        for (index, tokenID) in tokenIDs.enumerated()
        where !(0 ..< configuration.vocabularySize).contains(tokenID) {
            throw PrimeNativeGQADecoderInputError
                .tokenIDOutOfRange(
                    index: index,
                    value: tokenID,
                    vocabularySize: configuration.vocabularySize)
        }
        let input = MLXArray(tokenIDs)
            .reshaped(1, tokenIDs.count)
        return self(input, positionOffset: positionOffset)
    }

    /// Evaluates one rectangular token chunk and appends its per-layer K/V
    /// activations to `cache`. The first call is prompt prefill; later calls
    /// continue at the cache-derived RoPE offset. A one-token chunk is the
    /// intended generation path, while a larger continuation remains causal.
    /// Row order is stable identity for the cache lifetime and every row
    /// advances uniformly; this V1 surface has no padding mask or ragged
    /// per-row position. Materialize the pending step before cache reuse.
    public func forward(
        batchTokenIDs: [[Int]],
        cache: PrimeNativeGQADecoderCache
    ) throws -> MLXArray {
        guard !batchTokenIDs.isEmpty else {
            throw PrimeNativeGQADecoderInputError.emptyTokenBatch
        }
        let observedBatchSize = batchTokenIDs.count
        guard cache.decoderIdentity === cacheIdentity else {
            throw PrimeNativeGQADecoderCacheError
                .decoderIdentityMismatch
        }
        guard !cache.isPoisoned else {
            throw PrimeNativeGQADecoderCacheError.cachePoisoned
        }
        guard cache.boundParameterRevision
                == cacheIdentity.parameterRevision
        else {
            throw PrimeNativeGQADecoderCacheError
                .modelParametersChanged(
                    expected: cache.boundParameterRevision,
                    observed: cacheIdentity.parameterRevision)
        }
        guard !cache.isMaterializationPending else {
            throw PrimeNativeGQADecoderCacheError
                .materializationRequired(position: cache.position)
        }
        guard cache.batchSize == observedBatchSize else {
            throw PrimeNativeGQADecoderCacheError
                .batchSizeMismatch(
                    expected: cache.batchSize,
                    observed: observedBatchSize)
        }

        let sequenceLength = batchTokenIDs[0].count
        guard sequenceLength > 0 else {
            throw PrimeNativeGQADecoderInputError
                .emptyTokenSequenceInBatch(row: 0)
        }
        for (row, tokenIDs) in batchTokenIDs.enumerated() {
            guard !tokenIDs.isEmpty else {
                throw PrimeNativeGQADecoderInputError
                    .emptyTokenSequenceInBatch(row: row)
            }
            guard tokenIDs.count == sequenceLength else {
                throw PrimeNativeGQADecoderInputError
                    .raggedTokenBatch(
                        row: row,
                        expected: sequenceLength,
                        observed: tokenIDs.count)
            }
            for (index, tokenID) in tokenIDs.enumerated()
            where !(0 ..< configuration.vocabularySize).contains(tokenID) {
                throw PrimeNativeGQADecoderInputError
                    .batchTokenIDOutOfRange(
                        row: row,
                        index: index,
                        value: tokenID,
                        vocabularySize: configuration.vocabularySize)
            }
        }
        let nextPosition = try PrimeNativeGQADecoderCache
            .validatedNextPosition(
                current: cache.position,
                appending: sequenceLength,
                maximum: configuration.maximumSequenceLength)
        try validate(cache: cache)

        let input = MLXArray(batchTokenIDs.flatMap { $0 })
            .reshaped(observedBatchSize, sequenceLength)
        var hidden = tokenEmbedding(input)
        var nextStates = [PrimeNativeGQALayerCacheState]()
        nextStates.reserveCapacity(configuration.layerCount)
        for (index, layer) in layers.enumerated() {
            let result = layer.forward(
                hidden,
                positionOffset: cache.position,
                cachedState: cache.layerStates[index])
            hidden = result.output
            nextStates.append(result.state)
        }
        hidden = finalNorm(hidden)
        let logits = tokenEmbedding.asLinear(hidden)
        cache.commit(
            nextStates,
            position: nextPosition,
            logits: logits)
        return logits
    }

    public func forward(
        tokenIDs: [Int],
        cache: PrimeNativeGQADecoderCache
    ) throws -> MLXArray {
        guard !tokenIDs.isEmpty else {
            throw PrimeNativeGQADecoderInputError.emptyTokenSequence
        }
        for (index, tokenID) in tokenIDs.enumerated()
        where !(0 ..< configuration.vocabularySize).contains(tokenID) {
            throw PrimeNativeGQADecoderInputError
                .tokenIDOutOfRange(
                    index: index,
                    value: tokenID,
                    vocabularySize: configuration.vocabularySize)
        }
        return try forward(batchTokenIDs: [tokenIDs], cache: cache)
    }

    private func validate(
        cache: PrimeNativeGQADecoderCache
    ) throws {
        guard cache.layerStates.count == configuration.layerCount else {
            throw PrimeNativeGQADecoderCacheError
                .inconsistentLayerState(layer: cache.layerStates.count)
        }
        for (index, state) in cache.layerStates.enumerated() {
            if cache.position == 0 {
                guard state == nil else {
                    throw PrimeNativeGQADecoderCacheError
                        .inconsistentLayerState(layer: index)
                }
            } else {
                guard let state else {
                    throw PrimeNativeGQADecoderCacheError
                        .inconsistentLayerState(layer: index)
                }
                let capacity = state.keys.dim(2)
                let expectedKeys = [
                    cache.batchSize,
                    configuration.keyValueHeadCount,
                    capacity,
                    configuration.headWidth,
                ]
                guard capacity >= cache.position,
                      capacity <= configuration.maximumSequenceLength,
                      state.keys.shape == expectedKeys,
                      state.values.shape == expectedKeys,
                      state.keys.dtype == state.values.dtype
                else {
                    throw PrimeNativeGQADecoderCacheError
                        .inconsistentLayerState(layer: index)
                }
            }
        }
    }
}
