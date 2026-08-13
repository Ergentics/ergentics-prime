// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
import PrimeCore
import PrimeNativeDecoder
import MLX
import MLXNN
import MLXOptimizers

enum PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1:
    Error,
    Equatable,
    Sendable
{
    case emptyBatch
    case batchTooLarge(observed: Int, maximum: Int)
    case sequenceTooShort(Int)
    case sequenceTooLong(observed: Int, maximum: Int)
    case raggedTokenRow(row: Int, expected: Int, observed: Int)
    case validTokenCountCountMismatch(expected: Int, observed: Int)
    case invalidValidTokenCount(
        row: Int,
        observed: Int,
        sequenceLength: Int
    )
    case tokenIDOutOfRange(row: Int, column: Int, value: Int)
    case nonPaddingToken(
        row: Int,
        column: Int,
        observed: Int,
        expected: Int
    )
    case completionMaskRowCountMismatch(expected: Int, observed: Int)
    case raggedCompletionMaskRow(row: Int, expected: Int, observed: Int)
    case completionMaskSelectsFirstToken(row: Int)
    case completionMaskSelectsPadding(row: Int, column: Int)
    case emptyCompletion(row: Int)
    case nonContiguousCompletionSuffix(row: Int, column: Int)
    case maximumGlobalStepReached(maximum: Int, observed: Int)
    case nonCPUExecution(String)
    case parameterTopologyMismatch(expected: [String], observed: [String])
    case tensorShapeMismatch(
        scope: String,
        path: String,
        expected: [Int],
        observed: [Int]
    )
    case tensorDTypeMismatch(scope: String, path: String)
    case nonFiniteTensor(scope: String, path: String)
    case zeroGradient(String)
    case nonFiniteLoss(UInt32)
    case invalidGlobalGradientNorm(UInt32)
    case optimizerStateUnavailable
    case evaluationMutatedState
    case resumeBoundaryUnavailable
    case resumeTargetNotFresh
    case resumeStateMismatch(String)
    case resumeBatchUnavailable
    case internalInvariant(String)
}

struct PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeValidationStateV1:
    Equatable,
    Sendable
{
    let trainer: PrimeNativeDecoderTinyCPUTrainEvaluateValidationSnapshotV1
    let randomRecords: [PrimeNativeDecoderTinyCPUExplicitRNGRecordV1]
    let cursor: PrimeNativeDecoderTinyCPUDataCursorV1
    let evaluationCheckedAtCurrentStep: Bool
}

/// Owns the fixed two-batch trajectory. The caller can request only the next
/// admitted batch; there is no batch argument that can skip, duplicate, or
/// substitute cursor state.
public final class PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeSessionV1 {
    public static let stageID = "tiny_cpu_explicit_rng_cursor_resume_v1"
    public static let randomAlgorithmID = "sha256_counter_stream_v1"
    public static let cursorSchemaID =
        "prime_native_decoder_tiny_cpu_data_cursor_v1"

    static let secondBatchTokenAndMaskSHA256 = batchTokenAndMaskSHA256(
        try! secondBatch())

    private let trainer: PrimeNativeDecoderTinyCPUTrainEvaluateTrainerV1
    public private(set) var randomRecords:
        [PrimeNativeDecoderTinyCPUExplicitRNGRecordV1]
    public private(set) var cursor: PrimeNativeDecoderTinyCPUDataCursorV1
    private var evaluationCheckedAtCurrentStep = false

    public init() throws {
        trainer = try PrimeNativeDecoderTinyCPUTrainEvaluateTrainerV1()
        var records = Self.initialRandomRecords()
        records = Self.consuming(.modelInitialization, in: records)
        randomRecords = records
        cursor = Self.cursor(nextBatchOrdinal: 0)
    }

    public init(
        restoring snapshot: PrimeNativeDecoderTinyCPUInMemoryResumeSnapshotV1
    ) throws {
        let fresh = try PrimeNativeDecoderTinyCPUTrainEvaluateTrainerV1()
        try fresh.restoreInMemoryResumeSnapshot(snapshot)
        trainer = fresh
        randomRecords = snapshot.randomRecords
        cursor = snapshot.cursor
        evaluationCheckedAtCurrentStep = true
    }

    public var globalStep: Int { trainer.globalStep }

    public func trainNext()
        throws -> PrimeNativeDecoderTinyCPUTrainEvaluateStepResultV1
    {
        guard cursor.nextBatchOrdinal == trainer.globalStep,
              (0 ... 1).contains(cursor.nextBatchOrdinal)
        else {
            throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1
                .resumeBatchUnavailable
        }
        if trainer.globalStep == 1, !evaluationCheckedAtCurrentStep {
            throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1
                .resumeBoundaryUnavailable
        }
        let batch = try cursor.nextBatchOrdinal == 0
            ? Self.firstBatch()
            : Self.secondBatch()
        let result = try trainer.train(batch: batch)
        randomRecords = Self.consuming(.trainingDataOrder, in: randomRecords)
        cursor = Self.cursor(nextBatchOrdinal: result.globalStep)
        evaluationCheckedAtCurrentStep = false
        return result
    }

    public func checkedEvaluate()
        throws -> PrimeNativeDecoderTinyCPUTrainEvaluateEvaluationV1
    {
        let result = try trainer.evaluate(batch: Self.evaluationBatch())
        evaluationCheckedAtCurrentStep = true
        return result
    }

    public func exportInMemoryResumeSnapshot()
        throws -> PrimeNativeDecoderTinyCPUInMemoryResumeSnapshotV1
    {
        guard trainer.globalStep == 1,
              evaluationCheckedAtCurrentStep,
              cursor.nextBatchOrdinal == 1
        else {
            throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1
                .resumeBoundaryUnavailable
        }
        return try trainer.exportInMemoryResumeSnapshot(
            randomRecords: randomRecords,
            cursor: cursor)
    }

    func validationState() throws
        -> PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeValidationStateV1
    {
        .init(
            trainer: try trainer.validationSnapshot(),
            randomRecords: randomRecords,
            cursor: cursor,
            evaluationCheckedAtCurrentStep: evaluationCheckedAtCurrentStep)
    }

    func exactTensorState() throws
        -> PrimeNativeDecoderTinyCPUExactTensorStateV1
    {
        try trainer.exactTensorState()
    }

    static func firstBatch()
        throws -> PrimeNativeDecoderTinyCPUTrainEvaluateBatchV1
    {
        try .init(
            tokenIDs: [
                [1, 1, 1, 2, 3, 0],
                [4, 5, 6, 7, 8, 9],
            ],
            validTokenCounts: [5, 6],
            completionMask: [
                [false, false, false, true, true, false],
                [false, false, true, true, true, true],
            ])
    }

    static func secondBatch()
        throws -> PrimeNativeDecoderTinyCPUTrainEvaluateBatchV1
    {
        try .init(
            tokenIDs: [
                [10, 11, 12, 13, 0, 0],
                [14, 15, 15, 15, 16, 0],
            ],
            validTokenCounts: [4, 5],
            completionMask: [
                [false, true, true, true, false, false],
                [false, false, false, true, true, false],
            ])
    }

    static func evaluationBatch()
        throws -> PrimeNativeDecoderTinyCPUTrainEvaluateBatchV1
    {
        try .init(
            tokenIDs: [
                [17, 18, 19, 0, 0, 0],
                [17, 18, 19, 20, 21, 22],
            ],
            validTokenCounts: [3, 6],
            completionMask: [
                [false, true, true, false, false, false],
                [false, true, true, true, true, true],
            ])
    }

    private static func initialRandomRecords()
        -> [PrimeNativeDecoderTinyCPUExplicitRNGRecordV1]
    {
        PrimeNativeDecoderTinyCPUExplicitRNGDomainV1.allCases.map { domain in
            let key = PrimeSHA256.hexDigest(
                of: Data(
                    "prime_rng_key_v1|7|\(domain.rawValue)".utf8))
            return .init(
                domain: domain,
                keySHA256: key,
                counter: 0,
                consumptionSHA256: PrimeSHA256.hexDigest(
                    of: Data(
                        "prime_rng_consumption_v1|\(domain.rawValue)|\(key)|0"
                            .utf8)))
        }
    }

    private static func consuming(
        _ domain: PrimeNativeDecoderTinyCPUExplicitRNGDomainV1,
        in records: [PrimeNativeDecoderTinyCPUExplicitRNGRecordV1]
    ) -> [PrimeNativeDecoderTinyCPUExplicitRNGRecordV1] {
        records.map { record in
            guard record.domain == domain else { return record }
            let next = record.counter + 1
            let output = PrimeSHA256.hexDigest(
                of: Data(
                    "prime_rng_output_v1|\(record.keySHA256)|\(record.counter)"
                        .utf8))
            let consumption = PrimeSHA256.hexDigest(
                of: Data(
                    "prime_rng_consumption_v1|\(domain.rawValue)|"
                        .appending(record.keySHA256)
                        .appending("|\(record.counter)|\(next)|\(output)")
                        .utf8))
            return .init(
                domain: domain,
                keySHA256: record.keySHA256,
                counter: next,
                consumptionSHA256: consumption)
        }
    }

    private static func cursor(
        nextBatchOrdinal: Int
    ) -> PrimeNativeDecoderTinyCPUDataCursorV1 {
        switch nextBatchOrdinal {
        case 0:
            return .init(
                epoch: 0,
                nextBatchOrdinal: 0,
                nextRowIndex: 0,
                nextRowIDs: ["train_row_0", "train_row_1"],
                nextBatchTokenAndMaskSHA256:
                    batchTokenAndMaskSHA256(try! firstBatch()))
        case 1:
            return .init(
                epoch: 0,
                nextBatchOrdinal: 1,
                nextRowIndex: 2,
                nextRowIDs: ["train_row_2", "train_row_3"],
                nextBatchTokenAndMaskSHA256:
                    secondBatchTokenAndMaskSHA256)
        default:
            return .init(
                epoch: 1,
                nextBatchOrdinal: 2,
                nextRowIndex: 4,
                nextRowIDs: [],
                nextBatchTokenAndMaskSHA256: PrimeSHA256.hexDigest(
                    of: Data("prime_no_next_batch_v1".utf8)))
        }
    }

    private static func batchTokenAndMaskSHA256(
        _ batch: PrimeNativeDecoderTinyCPUTrainEvaluateBatchV1
    ) -> String {
        var data = Data("prime_batch_tokens_masks_v1".utf8)
        for row in batch.tokenIDs.indices {
            for column in batch.tokenIDs[row].indices {
                var token = Int32(batch.tokenIDs[row][column]).bigEndian
                withUnsafeBytes(of: &token) { data.append(contentsOf: $0) }
                data.append(batch.completionMask[row][column] ? 1 : 0)
            }
        }
        return PrimeSHA256.hexDigest(of: data)
    }
}

/// The one fixed, deliberately tiny CPU train/evaluate fixture admitted by V1.
/// These values are mechanics inventory, not Native-300M training authority.
public struct PrimeNativeDecoderTinyCPUTrainEvaluateConfigurationV1:
    Equatable,
    Sendable
{
    public static let frozenV1 = Self()

    public let vocabularySize = 32
    public let modelWidth = 16
    public let layerCount = 2
    public let queryHeadCount = 4
    public let keyValueHeadCount = 2
    public let headWidth = 4
    public let intermediateWidth = 32
    public let maximumSequenceLength = 16
    public let maximumBatchSize = 2
    public let paddingTokenID = 0
    public let initializationSeed: UInt64 = 7
    public let uniqueParameterCount: Int64 = 5_200
    public let trainableParameterPathCount = 20
    public let maximumGlobalStep = 2

    public let learningRateFloat32BitPattern = Float(1e-4).bitPattern
    public let beta1Float32BitPattern = Float(0.9).bitPattern
    public let beta2Float32BitPattern = Float(0.999).bitPattern
    public let epsilonFloat32BitPattern = Float(1e-8).bitPattern
    public let weightDecayFloat32BitPattern = Float(0.01).bitPattern
    public let maximumGradientNormFloat32BitPattern = Float(1).bitPattern
    public let gradientNormEpsilonFloat32BitPattern = Float(1e-6).bitPattern

    public let tensorLogicalDigestAlgorithmID =
        "sha256_domain_utf8_path_u32be_rank_u32be_dimensions_"
            + "u64be_count_f32_bits_u32be_v1"
    public let stateLogicalDigestAlgorithmID =
        "sha256_domain_utf8_role_u32be_tensor_count_then_"
            + "canonical_tensor_records_v1"

    private init() {}
}

/// A validated rectangular token batch. The completion mask is aligned to
/// target token columns: column zero is never selected, and columns
/// `1..<validTokenCount` must be exactly `false* true+`. All later columns are
/// right padding with token ID zero and a false mask.
public struct PrimeNativeDecoderTinyCPUTrainEvaluateBatchV1:
    Equatable,
    Sendable
{
    public let tokenIDs: [[Int]]
    public let validTokenCounts: [Int]
    public let completionMask: [[Bool]]
    public let selectedTargetCount: Int

    public init(
        tokenIDs: [[Int]],
        validTokenCounts: [Int],
        completionMask: [[Bool]]
    ) throws {
        let configuration =
            PrimeNativeDecoderTinyCPUTrainEvaluateConfigurationV1.frozenV1
        guard !tokenIDs.isEmpty else {
            throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1.emptyBatch
        }
        guard tokenIDs.count <= configuration.maximumBatchSize else {
            throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1
                .batchTooLarge(
                    observed: tokenIDs.count,
                    maximum: configuration.maximumBatchSize)
        }
        let sequenceLength = tokenIDs[0].count
        guard sequenceLength >= 2 else {
            throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1
                .sequenceTooShort(sequenceLength)
        }
        guard sequenceLength <= configuration.maximumSequenceLength else {
            throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1
                .sequenceTooLong(
                    observed: sequenceLength,
                    maximum: configuration.maximumSequenceLength)
        }
        for row in tokenIDs.indices
        where tokenIDs[row].count != sequenceLength {
            throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1
                .raggedTokenRow(
                    row: row,
                    expected: sequenceLength,
                    observed: tokenIDs[row].count)
        }
        guard validTokenCounts.count == tokenIDs.count else {
            throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1
                .validTokenCountCountMismatch(
                    expected: tokenIDs.count,
                    observed: validTokenCounts.count)
        }
        guard completionMask.count == tokenIDs.count else {
            throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1
                .completionMaskRowCountMismatch(
                    expected: tokenIDs.count,
                    observed: completionMask.count)
        }

        var selectedTargetCount = 0
        for row in tokenIDs.indices {
            let validTokenCount = validTokenCounts[row]
            guard (2 ... sequenceLength).contains(validTokenCount) else {
                throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1
                    .invalidValidTokenCount(
                        row: row,
                        observed: validTokenCount,
                        sequenceLength: sequenceLength)
            }
            guard completionMask[row].count == sequenceLength else {
                throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1
                    .raggedCompletionMaskRow(
                        row: row,
                        expected: sequenceLength,
                        observed: completionMask[row].count)
            }
            for column in 0 ..< sequenceLength {
                let tokenID = tokenIDs[row][column]
                guard (0 ..< configuration.vocabularySize).contains(tokenID)
                else {
                    throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1
                        .tokenIDOutOfRange(
                            row: row,
                            column: column,
                            value: tokenID)
                }
            }
            for column in validTokenCount ..< sequenceLength {
                let tokenID = tokenIDs[row][column]
                guard tokenID == configuration.paddingTokenID else {
                    throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1
                        .nonPaddingToken(
                            row: row,
                            column: column,
                            observed: tokenID,
                            expected: configuration.paddingTokenID)
                }
                guard !completionMask[row][column] else {
                    throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1
                        .completionMaskSelectsPadding(
                            row: row,
                            column: column)
                }
            }
            guard !completionMask[row][0] else {
                throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1
                    .completionMaskSelectsFirstToken(row: row)
            }

            guard let firstSelected =
                    (1 ..< validTokenCount).first(where: {
                        completionMask[row][$0]
                    })
            else {
                throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1
                    .emptyCompletion(row: row)
            }
            for column in firstSelected ..< validTokenCount
            where !completionMask[row][column] {
                throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1
                    .nonContiguousCompletionSuffix(
                        row: row,
                        column: column)
            }
            selectedTargetCount += validTokenCount - firstSelected
        }

        self.tokenIDs = tokenIDs
        self.validTokenCounts = validTokenCounts
        self.completionMask = completionMask
        self.selectedTargetCount = selectedTargetCount
    }

    var batchSize: Int { tokenIDs.count }
    var sequenceLength: Int { tokenIDs[0].count }

    var flattenedTokenIDs: [Int32] {
        tokenIDs.flatMap { row in row.map(Int32.init) }
    }

    var flattenedCompletionMask: [Float] {
        completionMask.flatMap { row in
            row.map { $0 ? Float(1) : Float(0) }
        }
    }

    var selectedShiftedLossIndices: [Int] {
        let shiftedWidth = sequenceLength - 1
        var result = [Int]()
        result.reserveCapacity(selectedTargetCount)
        for row in completionMask.indices {
            for tokenColumn in 1 ..< sequenceLength
            where completionMask[row][tokenColumn] {
                result.append(row * shiftedWidth + tokenColumn - 1)
            }
        }
        return result
    }
}

public struct PrimeNativeDecoderTinyCPUTrainEvaluateStepResultV1:
    Equatable,
    Sendable
{
    public let globalStep: Int
    public let selectedTargetCount: Int
    public let lossFloat32BitPattern: UInt32
    public let selectedLossFloat32BitPatterns: [UInt32]
    public let rawGlobalGradientNormFloat32BitPattern: UInt32
    public let gradientClipScaleFloat32BitPattern: UInt32
    public let clippedGlobalGradientNormFloat32BitPattern: UInt32
    public let parameterStateSHA256: String
    public let firstMomentStateSHA256: String
    public let secondMomentStateSHA256: String
}

public struct PrimeNativeDecoderTinyCPUTrainEvaluateEvaluationV1:
    Equatable,
    Sendable
{
    public let globalStep: Int
    public let selectedTargetCount: Int
    public let lossFloat32BitPattern: UInt32
    public let selectedLossFloat32BitPatterns: [UInt32]
    public let parameterStateSHA256: String
    public let firstMomentStateSHA256: String
    public let secondMomentStateSHA256: String
}

struct PrimeNativeDecoderTinyCPUTrainEvaluateTensorDigestV1:
    Equatable,
    Sendable
{
    let path: String
    let shape: [Int]
    let valueCount: Int
    let logicalSHA256: String
    let allFinite: Bool
    let nonzeroValueCount: Int
}

struct PrimeNativeDecoderTinyCPUTrainEvaluateValidationSnapshotV1:
    Equatable,
    Sendable
{
    let globalStep: Int
    let decoderTrainingMode: Bool
    let modelParameters:
        [PrimeNativeDecoderTinyCPUTrainEvaluateTensorDigestV1]
    let firstMoments:
        [PrimeNativeDecoderTinyCPUTrainEvaluateTensorDigestV1]
    let secondMoments:
        [PrimeNativeDecoderTinyCPUTrainEvaluateTensorDigestV1]
    let lastRawGradients:
        [PrimeNativeDecoderTinyCPUTrainEvaluateTensorDigestV1]
    let lastClippedGradients:
        [PrimeNativeDecoderTinyCPUTrainEvaluateTensorDigestV1]
    let parameterStateSHA256: String
    let firstMomentStateSHA256: String
    let secondMomentStateSHA256: String
    let lastTrainResult:
        PrimeNativeDecoderTinyCPUTrainEvaluateStepResultV1?
}

struct PrimeNativeDecoderTinyCPUExactTensorValueV1:
    Equatable,
    Sendable
{
    let path: String
    let shape: [Int]
    let float32BitPatterns: [UInt32]
}

struct PrimeNativeDecoderTinyCPUExactTensorStateV1:
    Equatable,
    Sendable
{
    let modelParameters: [PrimeNativeDecoderTinyCPUExactTensorValueV1]
    let firstMoments: [PrimeNativeDecoderTinyCPUExactTensorValueV1]
    let secondMoments: [PrimeNativeDecoderTinyCPUExactTensorValueV1]
}

public enum PrimeNativeDecoderTinyCPUExplicitRNGDomainV1:
    String,
    CaseIterable,
    Equatable,
    Sendable
{
    case modelInitialization = "model_initialization_v1"
    case trainingDataOrder = "training_data_order_v1"
    case augmentation = "augmentation_v1"
    case evaluation = "evaluation_v1"
}

public struct PrimeNativeDecoderTinyCPUExplicitRNGRecordV1:
    Equatable,
    Sendable
{
    public let domain: PrimeNativeDecoderTinyCPUExplicitRNGDomainV1
    public let keySHA256: String
    public let counter: UInt64
    public let consumptionSHA256: String
}

public struct PrimeNativeDecoderTinyCPUDataCursorV1:
    Equatable,
    Sendable
{
    public let epoch: Int
    public let nextBatchOrdinal: Int
    public let nextRowIndex: Int
    public let nextRowIDs: [String]
    public let nextBatchTokenAndMaskSHA256: String
}

/// An immutable, process-local value. Tensor storage is deliberately not
/// Codable and has no filesystem representation.
public struct PrimeNativeDecoderTinyCPUInMemoryResumeSnapshotV1 {
    public let schemaVersion: Int
    public let globalStep: Int
    public let modelTensorCount: Int
    public let optimizerMomentTensorCount: Int
    public let parameterStateSHA256: String
    public let firstMomentStateSHA256: String
    public let secondMomentStateSHA256: String
    public let learningRateFloat32BitPattern: UInt32
    public let beta1Float32BitPattern: UInt32
    public let beta2Float32BitPattern: UInt32
    public let epsilonFloat32BitPattern: UInt32
    public let weightDecayFloat32BitPattern: UInt32
    public let scheduleID: String
    public let randomRecords: [PrimeNativeDecoderTinyCPUExplicitRNGRecordV1]
    public let cursor: PrimeNativeDecoderTinyCPUDataCursorV1
    public let accumulationPhase: Int
    public let pendingGradientTensorCount: Int
    public let pendingPrefetchItemCount: Int
    public let kvCacheEntryCount: Int

    let modelParameters: ModuleParameters
    let optimizerState: AdamOptimizerState

    init(
        globalStep: Int,
        modelParameters: ModuleParameters,
        optimizerState: AdamOptimizerState,
        parameterStateSHA256: String,
        firstMomentStateSHA256: String,
        secondMomentStateSHA256: String,
        randomRecords: [PrimeNativeDecoderTinyCPUExplicitRNGRecordV1],
        cursor: PrimeNativeDecoderTinyCPUDataCursorV1
    ) {
        let configuration =
            PrimeNativeDecoderTinyCPUTrainEvaluateConfigurationV1.frozenV1
        self.schemaVersion = 1
        self.globalStep = globalStep
        self.modelTensorCount = modelParameters.flattened().count
        self.optimizerMomentTensorCount =
            optimizerState.firstMoment.flattened().count
                + optimizerState.secondMoment.flattened().count
        self.parameterStateSHA256 = parameterStateSHA256
        self.firstMomentStateSHA256 = firstMomentStateSHA256
        self.secondMomentStateSHA256 = secondMomentStateSHA256
        self.learningRateFloat32BitPattern =
            configuration.learningRateFloat32BitPattern
        self.beta1Float32BitPattern = configuration.beta1Float32BitPattern
        self.beta2Float32BitPattern = configuration.beta2Float32BitPattern
        self.epsilonFloat32BitPattern = configuration.epsilonFloat32BitPattern
        self.weightDecayFloat32BitPattern =
            configuration.weightDecayFloat32BitPattern
        self.scheduleID = "constant_float32_learning_rate_v1"
        self.randomRecords = randomRecords
        self.cursor = cursor
        self.accumulationPhase = 0
        self.pendingGradientTensorCount = 0
        self.pendingPrefetchItemCount = 0
        self.kvCacheEntryCount = 0
        self.modelParameters = modelParameters
        self.optimizerState = optimizerState
    }
}

/// Stateful two-step CPU mechanics for the fixed true-GQA fixture. The model
/// and optimizer never leave this object, and every public observation is a
/// scalar bit pattern or a canonical logical SHA-256 digest.
public final class PrimeNativeDecoderTinyCPUTrainEvaluateTrainerV1 {
    public let configuration =
        PrimeNativeDecoderTinyCPUTrainEvaluateConfigurationV1.frozenV1
    public private(set) var globalStep = 0

    private let decoder: PrimeNativeGQADecoder
    private let optimizer: AdamW
    private var lastTrainResult:
        PrimeNativeDecoderTinyCPUTrainEvaluateStepResultV1?
    private var lastRawGradientDigests =
        [PrimeNativeDecoderTinyCPUTrainEvaluateTensorDigestV1]()
    private var lastClippedGradientDigests =
        [PrimeNativeDecoderTinyCPUTrainEvaluateTensorDigestV1]()

    public init() throws {
        let configuration = self.configuration
        let state = try Device.withDefaultDevice(.cpu) {
            try Self.requireCPUDefault()
            let decoderConfiguration =
                try PrimeNativeGQADecoderConfiguration(
                    vocabularySize: configuration.vocabularySize,
                    modelWidth: configuration.modelWidth,
                    layerCount: configuration.layerCount,
                    queryHeadCount: configuration.queryHeadCount,
                    keyValueHeadCount: configuration.keyValueHeadCount,
                    headWidth: configuration.headWidth,
                    intermediateWidth: configuration.intermediateWidth,
                    maximumSequenceLength:
                        configuration.maximumSequenceLength)
            guard decoderConfiguration.uniqueParameterCount
                    == configuration.uniqueParameterCount
            else {
                throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1
                    .internalInvariant("fixture parameter count")
            }
            let decoder = PrimeNativeGQADecoder.make(
                configuration: decoderConfiguration,
                seed: configuration.initializationSeed)
            let optimizer = AdamW(
                learningRate: Float(
                    bitPattern:
                        configuration.learningRateFloat32BitPattern),
                betas: (
                    Float(
                        bitPattern:
                            configuration.beta1Float32BitPattern),
                    Float(
                        bitPattern:
                            configuration.beta2Float32BitPattern)
                ),
                eps: Float(
                    bitPattern:
                        configuration.epsilonFloat32BitPattern),
                weightDecay: Float(
                    bitPattern:
                        configuration.weightDecayFloat32BitPattern))
            try checkedEval(decoder)
            try Self.validateParameters(
                decoder.parameters(),
                scope: "initial_model")
            return (decoder, optimizer)
        }
        self.decoder = state.0
        self.optimizer = state.1
    }

    public func train(
        batch: PrimeNativeDecoderTinyCPUTrainEvaluateBatchV1
    ) throws -> PrimeNativeDecoderTinyCPUTrainEvaluateStepResultV1 {
        // This rejection is intentionally before device scoping, graph
        // construction, parameter inspection, or any model/optimizer mutation.
        guard globalStep < configuration.maximumGlobalStep else {
            throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1
                .maximumGlobalStepReached(
                    maximum: configuration.maximumGlobalStep,
                    observed: globalStep)
        }

        return try Device.withDefaultDevice(.cpu) {
            try Self.requireCPUDefault()
            try Self.validateParameters(
                decoder.trainableParameters(),
                scope: "pre_step_model")
            decoder.train(true)

            let arrays = Self.arrays(for: batch)
            let observedBefore = Self.lossObservation(
                model: decoder,
                tokenIDs: arrays.tokenIDs,
                completionMask: arrays.completionMask,
                selectedTargetCount: batch.selectedTargetCount)
            let lossAndGradient = valueAndGrad(model: decoder) {
                model,
                tokenIDs,
                completionMask in
                Self.lossObservation(
                    model: model,
                    tokenIDs: tokenIDs,
                    completionMask: completionMask,
                    selectedTargetCount: batch.selectedTargetCount).loss
            }
            let (loss, gradients) = lossAndGradient(
                decoder,
                arrays.tokenIDs,
                arrays.completionMask)
            try checkedEval(
                observedBefore.loss,
                observedBefore.perTargetLoss,
                loss,
                gradients)

            let observedLoss = loss.item(Float.self)
            guard observedLoss.isFinite else {
                throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1
                    .nonFiniteLoss(observedLoss.bitPattern)
            }
            let independentlyObservedLoss =
                observedBefore.loss.item(Float.self)
            guard independentlyObservedLoss.bitPattern
                    == observedLoss.bitPattern
            else {
                throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1
                    .internalInvariant("loss replay mismatch")
            }
            try Self.validateGradients(gradients)
            let rawGradientDigests = try Self.tensorDigests(
                gradients,
                scope: "raw_gradient")

            let rawNorm = Self.globalGradientNorm(gradients)
            try checkedEval(rawNorm)
            let rawNormValue = rawNorm.item(Float.self)
            let clipScale = try Self.clipScale(globalNorm: rawNormValue)
            let clippedGradients: ModuleParameters
            if rawNormValue < Self.maximumGradientNorm {
                clippedGradients = gradients
            } else {
                clippedGradients = gradients.mapValues {
                    $0 * clipScale
                }
            }
            try Self.validateGradients(clippedGradients)
            let clippedGradientDigests = try Self.tensorDigests(
                clippedGradients,
                scope: "clipped_gradient")
            let clippedNorm = Self.globalGradientNorm(clippedGradients)
            try checkedEval(clippedNorm)
            let clippedNormValue = clippedNorm.item(Float.self)
            guard clippedNormValue.isFinite else {
                throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1
                    .invalidGlobalGradientNorm(clippedNormValue.bitPattern)
            }
            let selectedLossBitPatterns = try Self.selectedLossBitPatterns(
                observedBefore.perTargetLoss,
                batch: batch)

            optimizer.update(
                model: decoder,
                gradients: clippedGradients)
            try checkedEval(decoder, optimizer)

            try Self.validateParameters(
                decoder.parameters(),
                scope: "post_step_model")
            let optimizerState: AdamOptimizerState
            do {
                optimizerState = try optimizer.parameters()
            } catch AdamOptimizerStateError.emptyState {
                throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1
                    .optimizerStateUnavailable
            }
            try Self.validateOptimizerState(optimizerState)

            let modelCatalog = try Self.tensorDigests(
                decoder.parameters(),
                scope: "model_parameter")
            let firstCatalog = try Self.tensorDigests(
                optimizerState.firstMoment,
                scope: "first_moment")
            let secondCatalog = try Self.tensorDigests(
                optimizerState.secondMoment,
                scope: "second_moment")
            let completedStep = globalStep + 1
            let result =
                PrimeNativeDecoderTinyCPUTrainEvaluateStepResultV1(
                    globalStep: completedStep,
                    selectedTargetCount: batch.selectedTargetCount,
                    lossFloat32BitPattern: observedLoss.bitPattern,
                    selectedLossFloat32BitPatterns:
                        selectedLossBitPatterns,
                    rawGlobalGradientNormFloat32BitPattern:
                        rawNormValue.bitPattern,
                    gradientClipScaleFloat32BitPattern:
                        clipScale.bitPattern,
                    clippedGlobalGradientNormFloat32BitPattern:
                        clippedNormValue.bitPattern,
                    parameterStateSHA256: Self.stateDigest(
                        role: "model_parameter",
                        tensors: modelCatalog),
                    firstMomentStateSHA256: Self.stateDigest(
                        role: "first_moment",
                        tensors: firstCatalog),
                    secondMomentStateSHA256: Self.stateDigest(
                        role: "second_moment",
                        tensors: secondCatalog))
            globalStep = completedStep
            lastTrainResult = result
            lastRawGradientDigests = rawGradientDigests
            lastClippedGradientDigests = clippedGradientDigests
            return result
        }
    }

    public func evaluate(
        batch: PrimeNativeDecoderTinyCPUTrainEvaluateBatchV1
    ) throws -> PrimeNativeDecoderTinyCPUTrainEvaluateEvaluationV1 {
        try Device.withDefaultDevice(.cpu) {
            try Self.requireCPUDefault()
            let before = try validationSnapshot()
            let priorTrainingMode = decoder.training
            decoder.train(false)
            var trainingModeNeedsRestoration = true
            defer {
                if trainingModeNeedsRestoration {
                    decoder.train(priorTrainingMode)
                }
            }

            let arrays = Self.arrays(for: batch)
            let observation = Self.lossObservation(
                model: decoder,
                tokenIDs: arrays.tokenIDs,
                completionMask: arrays.completionMask,
                selectedTargetCount: batch.selectedTargetCount)
            try checkedEval(observation.loss, observation.perTargetLoss)
            let loss = observation.loss.item(Float.self)
            guard loss.isFinite else {
                throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1
                    .nonFiniteLoss(loss.bitPattern)
            }
            let selectedLossBitPatterns =
                try Self.selectedLossBitPatterns(
                    observation.perTargetLoss,
                    batch: batch)
            decoder.train(priorTrainingMode)
            trainingModeNeedsRestoration = false
            let after = try validationSnapshot()
            guard before == after,
                  decoder.training == priorTrainingMode else {
                throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1
                    .evaluationMutatedState
            }
            return PrimeNativeDecoderTinyCPUTrainEvaluateEvaluationV1(
                globalStep: globalStep,
                selectedTargetCount: batch.selectedTargetCount,
                lossFloat32BitPattern: loss.bitPattern,
                selectedLossFloat32BitPatterns: selectedLossBitPatterns,
                parameterStateSHA256: before.parameterStateSHA256,
                firstMomentStateSHA256: before.firstMomentStateSHA256,
                secondMomentStateSHA256: before.secondMomentStateSHA256)
        }
    }

    func validationSnapshot() throws
        -> PrimeNativeDecoderTinyCPUTrainEvaluateValidationSnapshotV1
    {
        try Device.withDefaultDevice(.cpu) {
            try Self.requireCPUDefault()
            let modelCatalog = try Self.tensorDigests(
                decoder.parameters(),
                scope: "model_parameter")
            let optimizerCatalogs: (
                first:
                    [PrimeNativeDecoderTinyCPUTrainEvaluateTensorDigestV1],
                second:
                    [PrimeNativeDecoderTinyCPUTrainEvaluateTensorDigestV1]
            )
            do {
                let state = try optimizer.parameters()
                try Self.validateOptimizerState(state)
                optimizerCatalogs = (
                    try Self.tensorDigests(
                        state.firstMoment,
                        scope: "first_moment"),
                    try Self.tensorDigests(
                        state.secondMoment,
                        scope: "second_moment")
                )
            } catch AdamOptimizerStateError.emptyState {
                optimizerCatalogs = ([], [])
            }
            return
                PrimeNativeDecoderTinyCPUTrainEvaluateValidationSnapshotV1(
                    globalStep: globalStep,
                    decoderTrainingMode: decoder.training,
                    modelParameters: modelCatalog,
                    firstMoments: optimizerCatalogs.first,
                    secondMoments: optimizerCatalogs.second,
                    lastRawGradients: lastRawGradientDigests,
                    lastClippedGradients: lastClippedGradientDigests,
                    parameterStateSHA256: Self.stateDigest(
                        role: "model_parameter",
                        tensors: modelCatalog),
                    firstMomentStateSHA256: Self.stateDigest(
                        role: "first_moment",
                        tensors: optimizerCatalogs.first),
                    secondMomentStateSHA256: Self.stateDigest(
                        role: "second_moment",
                        tensors: optimizerCatalogs.second),
                    lastTrainResult: lastTrainResult)
        }
    }

    func exactTensorState() throws
        -> PrimeNativeDecoderTinyCPUExactTensorStateV1
    {
        try Device.withDefaultDevice(.cpu) {
            try Self.requireCPUDefault()
            let optimizerState: AdamOptimizerState
            do {
                optimizerState = try optimizer.parameters()
            } catch AdamOptimizerStateError.emptyState {
                throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1
                    .optimizerStateUnavailable
            }
            try checkedEval(
                decoder.parameters(),
                optimizerState.firstMoment,
                optimizerState.secondMoment)
            return .init(
                modelParameters: try Self.exactTensorValues(
                    decoder.parameters()),
                firstMoments: try Self.exactTensorValues(
                    optimizerState.firstMoment),
                secondMoments: try Self.exactTensorValues(
                    optimizerState.secondMoment))
        }
    }

    func exportInMemoryResumeSnapshot(
        randomRecords: [PrimeNativeDecoderTinyCPUExplicitRNGRecordV1],
        cursor: PrimeNativeDecoderTinyCPUDataCursorV1
    ) throws -> PrimeNativeDecoderTinyCPUInMemoryResumeSnapshotV1 {
        guard globalStep == 1,
              lastTrainResult?.globalStep == 1,
              cursor.nextBatchOrdinal == 1,
              cursor.nextRowIndex == 2,
              cursor.nextRowIDs == ["train_row_2", "train_row_3"]
        else {
            throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1
                .resumeBoundaryUnavailable
        }
        return try Device.withDefaultDevice(.cpu) {
            try Self.requireCPUDefault()
            let validation = try validationSnapshot()
            let optimizerState: AdamOptimizerState
            do {
                optimizerState = try optimizer.parameters()
            } catch AdamOptimizerStateError.emptyState {
                throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1
                    .optimizerStateUnavailable
            }
            try Self.validateOptimizerState(optimizerState)
            let modelParameters = Self.isolatedSnapshot(decoder.parameters())
            let isolatedOptimizerState = try Self.isolatedSnapshot(optimizerState)
            try checkedEval(
                modelParameters,
                isolatedOptimizerState.firstMoment,
                isolatedOptimizerState.secondMoment)
            return PrimeNativeDecoderTinyCPUInMemoryResumeSnapshotV1(
                globalStep: globalStep,
                modelParameters: modelParameters,
                optimizerState: isolatedOptimizerState,
                parameterStateSHA256: validation.parameterStateSHA256,
                firstMomentStateSHA256: validation.firstMomentStateSHA256,
                secondMomentStateSHA256: validation.secondMomentStateSHA256,
                randomRecords: randomRecords,
                cursor: cursor)
        }
    }

    func restoreInMemoryResumeSnapshot(
        _ snapshot: PrimeNativeDecoderTinyCPUInMemoryResumeSnapshotV1
    ) throws {
        let before = try validationSnapshot()
        guard globalStep == 0,
              before.firstMoments.isEmpty,
              before.secondMoments.isEmpty,
              lastTrainResult == nil,
              lastRawGradientDigests.isEmpty,
              lastClippedGradientDigests.isEmpty
        else {
            throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1
                .resumeTargetNotFresh
        }
        try Self.validateResumeSnapshotMetadata(snapshot)
        try Device.withDefaultDevice(.cpu) {
            try Self.requireCPUDefault()
            try Self.validateParameters(
                snapshot.modelParameters,
                scope: "resume_model")
            try Self.validateOptimizerState(snapshot.optimizerState)
            try Self.validateOptimizerState(
                snapshot.optimizerState,
                matching: decoder.trainableParameters())

            try decoder.update(
                parameters: Self.isolatedSnapshot(snapshot.modelParameters),
                verify: .all)
            try optimizer.update(
                parameters: try Self.isolatedSnapshot(snapshot.optimizerState),
                matching: decoder.trainableParameters())
            try checkedEval(decoder, optimizer)
            globalStep = snapshot.globalStep
            decoder.train(true)

            let restored = try validationSnapshot()
            guard restored.parameterStateSHA256
                    == snapshot.parameterStateSHA256,
                  restored.firstMomentStateSHA256
                    == snapshot.firstMomentStateSHA256,
                  restored.secondMomentStateSHA256
                    == snapshot.secondMomentStateSHA256,
                  restored.modelParameters.count == snapshot.modelTensorCount,
                  restored.firstMoments.count + restored.secondMoments.count
                    == snapshot.optimizerMomentTensorCount
            else {
                throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1
                    .resumeStateMismatch("restored state identity")
            }
        }
    }

    private static func validateResumeSnapshotMetadata(
        _ snapshot: PrimeNativeDecoderTinyCPUInMemoryResumeSnapshotV1
    ) throws {
        let configuration =
            PrimeNativeDecoderTinyCPUTrainEvaluateConfigurationV1.frozenV1
        guard snapshot.schemaVersion == 1,
              snapshot.globalStep == 1,
              snapshot.modelTensorCount == 20,
              snapshot.optimizerMomentTensorCount == 40,
              snapshot.learningRateFloat32BitPattern
                == configuration.learningRateFloat32BitPattern,
              snapshot.beta1Float32BitPattern
                == configuration.beta1Float32BitPattern,
              snapshot.beta2Float32BitPattern
                == configuration.beta2Float32BitPattern,
              snapshot.epsilonFloat32BitPattern
                == configuration.epsilonFloat32BitPattern,
              snapshot.weightDecayFloat32BitPattern
                == configuration.weightDecayFloat32BitPattern,
              snapshot.scheduleID == "constant_float32_learning_rate_v1",
              snapshot.accumulationPhase == 0,
              snapshot.pendingGradientTensorCount == 0,
              snapshot.pendingPrefetchItemCount == 0,
              snapshot.kvCacheEntryCount == 0,
              snapshot.randomRecords.map(\.domain)
                == PrimeNativeDecoderTinyCPUExplicitRNGDomainV1.allCases,
              Set(snapshot.randomRecords.map(\.keySHA256)).count == 4,
              snapshot.randomRecords.allSatisfy({
                  $0.keySHA256.count == 64
                    && $0.consumptionSHA256.count == 64
              }),
              snapshot.cursor.epoch == 0,
              snapshot.cursor.nextBatchOrdinal == 1,
              snapshot.cursor.nextRowIndex == 2,
              snapshot.cursor.nextRowIDs == ["train_row_2", "train_row_3"],
              snapshot.cursor.nextBatchTokenAndMaskSHA256
                == PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeSessionV1
                    .secondBatchTokenAndMaskSHA256
        else {
            throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1
                .resumeStateMismatch("snapshot metadata")
        }
    }

    private static func isolatedSnapshot(
        _ parameters: ModuleParameters
    ) -> ModuleParameters {
        parameters.mapValues { $0.reshaped($0.shape) }
    }

    private static func exactTensorValues(
        _ parameters: ModuleParameters
    ) throws -> [PrimeNativeDecoderTinyCPUExactTensorValueV1] {
        try parameters.flattened().map { path, tensor in
            guard tensor.dtype == .float32 else {
                throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1
                    .resumeStateMismatch("non-Float32 tensor \(path)")
            }
            return .init(
                path: path,
                shape: tensor.shape,
                float32BitPatterns:
                    tensor.asArray(Float.self).map(\.bitPattern))
        }.sorted { utf8Less($0.path, $1.path) }
    }

    private static func isolatedSnapshot(
        _ state: AdamOptimizerState
    ) throws -> AdamOptimizerState {
        let snapshot = AdamOptimizerState(
            firstMoment: isolatedSnapshot(state.firstMoment),
            secondMoment: isolatedSnapshot(state.secondMoment))
        try checkedEval(snapshot.firstMoment, snapshot.secondMoment)
        return snapshot
    }

    private static func validateOptimizerState(
        _ state: AdamOptimizerState,
        matching parameters: ModuleParameters
    ) throws {
        let expected = Dictionary(
            uniqueKeysWithValues: parameters.flattened().map { ($0.0, $0.1) })
        let first = Dictionary(
            uniqueKeysWithValues: state.firstMoment.flattened().map {
                ($0.0, $0.1)
            })
        let second = Dictionary(
            uniqueKeysWithValues: state.secondMoment.flattened().map {
                ($0.0, $0.1)
            })
        guard Set(expected.keys) == Set(first.keys),
              Set(expected.keys) == Set(second.keys)
        else {
            throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1
                .resumeStateMismatch("optimizer paths")
        }
        for path in expected.keys {
            guard first[path]?.shape == expected[path]?.shape,
                  second[path]?.shape == expected[path]?.shape,
                  first[path]?.dtype == expected[path]?.dtype,
                  second[path]?.dtype == expected[path]?.dtype
            else {
                throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1
                    .resumeStateMismatch("optimizer topology \(path)")
            }
        }
    }

    static func validationClipScale(globalNorm: Float) throws -> Float {
        try clipScale(globalNorm: globalNorm)
    }

    private static let maximumGradientNorm = Float(1)
    private static let gradientNormEpsilon = Float(1e-6)

    private static let expectedParameterShapes: [(String, [Int])] = {
        var shapes: [(String, [Int])] = [
            ("token_embedding.weight", [32, 16]),
            ("final_norm.weight", [16]),
        ]
        for layer in 0 ..< 2 {
            let prefix = "layers.\(layer)"
            shapes.append(("\(prefix).attention_norm.weight", [16]))
            shapes.append(
                ("\(prefix).attention.query_projection.weight", [16, 16]))
            shapes.append(
                ("\(prefix).attention.key_projection.weight", [8, 16]))
            shapes.append(
                ("\(prefix).attention.value_projection.weight", [8, 16]))
            shapes.append(
                ("\(prefix).attention.output_projection.weight", [16, 16]))
            shapes.append(("\(prefix).feed_forward_norm.weight", [16]))
            shapes.append(
                ("\(prefix).feed_forward.gate_projection.weight", [32, 16]))
            shapes.append(
                ("\(prefix).feed_forward.up_projection.weight", [32, 16]))
            shapes.append(
                ("\(prefix).feed_forward.down_projection.weight", [16, 32]))
        }
        return shapes.sorted { utf8Less($0.0, $1.0) }
    }()

    private static var expectedParameterPaths: [String] {
        expectedParameterShapes.map(\.0)
    }

    private static func arrays(
        for batch: PrimeNativeDecoderTinyCPUTrainEvaluateBatchV1
    ) -> (tokenIDs: MLXArray, completionMask: MLXArray) {
        (
            MLXArray(
                batch.flattenedTokenIDs,
                [batch.batchSize, batch.sequenceLength]),
            MLXArray(
                batch.flattenedCompletionMask,
                [batch.batchSize, batch.sequenceLength])
        )
    }

    private static func lossObservation(
        model: PrimeNativeGQADecoder,
        tokenIDs: MLXArray,
        completionMask: MLXArray,
        selectedTargetCount: Int
    ) -> (loss: MLXArray, perTargetLoss: MLXArray) {
        let sequenceLength = tokenIDs.dim(1)
        let logits = model.trainingLogitsNoCache(tokenIDs)
        let shiftedLogits = logits[
            0...,
            ..<(sequenceLength - 1),
            0...
        ]
        let shiftedTargets = tokenIDs[0..., 1 ..< sequenceLength]
        let shiftedMask = completionMask[0..., 1 ..< sequenceLength]
        let perTargetLoss = crossEntropy(
            logits: shiftedLogits,
            targets: shiftedTargets,
            axis: -1,
            labelSmoothing: 0,
            reduction: .none)
        let loss = sum(perTargetLoss * shiftedMask)
            / Float(selectedTargetCount)
        return (loss, perTargetLoss)
    }

    private static func selectedLossBitPatterns(
        _ perTargetLoss: MLXArray,
        batch: PrimeNativeDecoderTinyCPUTrainEvaluateBatchV1
    ) throws -> [UInt32] {
        try checkedEval(perTargetLoss)
        guard perTargetLoss.dtype == .float32,
              perTargetLoss.shape
                == [batch.batchSize, batch.sequenceLength - 1]
        else {
            throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1
                .internalInvariant("per-target loss shape or dtype")
        }
        let values = perTargetLoss.asArray(Float.self)
        let selected = batch.selectedShiftedLossIndices.map { values[$0] }
        guard selected.count == batch.selectedTargetCount,
              selected.allSatisfy(\.isFinite) else {
            throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1
                .internalInvariant("selected per-target loss")
        }
        return selected.map(\.bitPattern)
    }

    private static func clipScale(globalNorm: Float) throws -> Float {
        guard globalNorm.isFinite,
              globalNorm >= 0 else {
            throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1
                .invalidGlobalGradientNorm(globalNorm.bitPattern)
        }
        if globalNorm < maximumGradientNorm {
            return 1
        }
        return maximumGradientNorm
            / (globalNorm + gradientNormEpsilon)
    }

    private static func globalGradientNorm(
        _ gradients: ModuleParameters
    ) -> MLXArray {
        let catalog = Dictionary(
            uniqueKeysWithValues: gradients.flattened())
        var total = MLXArray(Float(0))
        for path in expectedParameterPaths {
            let gradient = catalog[path]!
            total = total + sum(square(gradient.asType(.float32)))
        }
        return sqrt(total)
    }

    private static func requireCPUDefault() throws {
        let device = Device.defaultDevice()
        let stream = StreamOrDevice.default.description
        guard device.deviceType == .cpu,
              stream.lowercased().contains("cpu") else {
            throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1
                .nonCPUExecution("device=\(device) stream=\(stream)")
        }
    }

    private static func uniqueCatalog(
        _ parameters: ModuleParameters,
        scope: String
    ) throws -> [String: MLXArray] {
        var result = [String: MLXArray]()
        for (path, array) in parameters.flattened() {
            guard result.updateValue(array, forKey: path) == nil else {
                throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1
                    .internalInvariant("duplicate \(scope) path \(path)")
            }
        }
        return result
    }

    private static func validateParameters(
        _ parameters: ModuleParameters,
        scope: String
    ) throws {
        let catalog = try uniqueCatalog(parameters, scope: scope)
        let observedPaths = catalog.keys.sorted(by: utf8Less)
        guard observedPaths == expectedParameterPaths else {
            throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1
                .parameterTopologyMismatch(
                    expected: expectedParameterPaths,
                    observed: observedPaths)
        }
        var observedCount: Int64 = 0
        for (path, expectedShape) in expectedParameterShapes {
            let array = catalog[path]!
            guard array.shape == expectedShape else {
                throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1
                    .tensorShapeMismatch(
                        scope: scope,
                        path: path,
                        expected: expectedShape,
                        observed: array.shape)
            }
            guard array.dtype == .float32 else {
                throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1
                    .tensorDTypeMismatch(scope: scope, path: path)
            }
            observedCount += Int64(array.size)
        }
        guard observedCount
                == PrimeNativeDecoderTinyCPUTrainEvaluateConfigurationV1
                    .frozenV1.uniqueParameterCount
        else {
            throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1
                .internalInvariant("\(scope) parameter count")
        }
        try checkedEval(expectedParameterPaths.map { catalog[$0]! })
        for path in expectedParameterPaths {
            guard catalog[path]!.asArray(Float.self).allSatisfy(\.isFinite)
            else {
                throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1
                    .nonFiniteTensor(scope: scope, path: path)
            }
        }
    }

    private static func validateGradients(
        _ gradients: ModuleParameters
    ) throws {
        try validateParameters(gradients, scope: "gradient")
        let catalog = try uniqueCatalog(gradients, scope: "gradient")
        for path in expectedParameterPaths
        where !catalog[path]!.asArray(Float.self).contains(where: {
            $0 != 0
        }) {
            throw PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1
                .zeroGradient(path)
        }
    }

    private static func validateOptimizerState(
        _ state: AdamOptimizerState
    ) throws {
        try validateParameters(state.firstMoment, scope: "first_moment")
        try validateParameters(state.secondMoment, scope: "second_moment")
    }

    private static func tensorDigests(
        _ parameters: ModuleParameters,
        scope: String
    ) throws -> [PrimeNativeDecoderTinyCPUTrainEvaluateTensorDigestV1] {
        try validateParameters(parameters, scope: scope)
        let catalog = try uniqueCatalog(parameters, scope: scope)
        return expectedParameterPaths.map { path in
            let array = catalog[path]!
            let values = array.asArray(Float.self)
            return PrimeNativeDecoderTinyCPUTrainEvaluateTensorDigestV1(
                path: path,
                shape: array.shape,
                valueCount: values.count,
                logicalSHA256: tensorDigest(
                    path: path,
                    shape: array.shape,
                    values: values),
                allFinite: values.allSatisfy(\.isFinite),
                nonzeroValueCount: values.reduce(into: 0) {
                    if $1 != 0 { $0 += 1 }
                })
        }
    }

    private static func tensorDigest(
        path: String,
        shape: [Int],
        values: [Float]
    ) -> String {
        var data = Data(
            "prime_native_decoder_tensor_f32be_v1\0".utf8)
        appendUTF8(path, to: &data)
        appendUInt32(UInt32(shape.count), to: &data)
        for dimension in shape {
            appendUInt32(UInt32(dimension), to: &data)
        }
        appendUInt64(UInt64(values.count), to: &data)
        for value in values {
            appendUInt32(value.bitPattern, to: &data)
        }
        return PrimeSHA256.hexDigest(of: data)
    }

    private static func stateDigest(
        role: String,
        tensors: [PrimeNativeDecoderTinyCPUTrainEvaluateTensorDigestV1]
    ) -> String {
        var data = Data(
            "prime_native_decoder_state_digest_v1\0".utf8)
        appendUTF8(role, to: &data)
        appendUInt32(UInt32(tensors.count), to: &data)
        for tensor in tensors {
            appendUTF8(tensor.path, to: &data)
            appendUInt32(UInt32(tensor.shape.count), to: &data)
            for dimension in tensor.shape {
                appendUInt32(UInt32(dimension), to: &data)
            }
            appendUInt64(UInt64(tensor.valueCount), to: &data)
            appendUTF8(tensor.logicalSHA256, to: &data)
        }
        return PrimeSHA256.hexDigest(of: data)
    }

    private static func appendUTF8(_ value: String, to data: inout Data) {
        let bytes = Array(value.utf8)
        appendUInt32(UInt32(bytes.count), to: &data)
        data.append(contentsOf: bytes)
    }

    private static func appendUInt32(_ value: UInt32, to data: inout Data) {
        data.append(UInt8((value >> 24) & 0xff))
        data.append(UInt8((value >> 16) & 0xff))
        data.append(UInt8((value >> 8) & 0xff))
        data.append(UInt8(value & 0xff))
    }

    private static func appendUInt64(_ value: UInt64, to data: inout Data) {
        data.append(UInt8((value >> 56) & 0xff))
        data.append(UInt8((value >> 48) & 0xff))
        data.append(UInt8((value >> 40) & 0xff))
        data.append(UInt8((value >> 32) & 0xff))
        data.append(UInt8((value >> 24) & 0xff))
        data.append(UInt8((value >> 16) & 0xff))
        data.append(UInt8((value >> 8) & 0xff))
        data.append(UInt8(value & 0xff))
    }

    private static func utf8Less(_ lhs: String, _ rhs: String) -> Bool {
        lhs.utf8.lexicographicallyPrecedes(rhs.utf8)
    }
}
