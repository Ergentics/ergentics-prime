import Foundation
import PrimeNativeNeuralGateCorrectedMechanics
import PrimeNativeNeuralGateLogitSidecarMechanics
import PrimeNativeNeuralGateReplayArtifactContracts
import PrimeNativeNeuralGateReplayMechanics
import PrimeNativeNeuralGateReplayTransport

public enum PrimeNativeNeuralGateReplayCompositionError:
    Error,
    Equatable,
    Sendable
{
    case invalidFrozenContract
    case invalidPromptRecordCount(
        expected: Int,
        observed: Int
    )
    case duplicatePromptRecord(index: Int)
    case noncanonicalPromptRecordOrder(index: Int)
    case promptRecordRoundTripMismatch(index: Int)
    case promptRecordDigestMismatch(index: Int)
    case promptGlobalStreamDigestMismatch
    case promptBindingMismatch(index: Int)
    case duplicatePromptBinding(index: Int)
    case invalidOuterRowCount(
        expected: Int,
        observed: Int
    )
    case duplicateOuterExecutionIndex(UInt32)
    case duplicateOuterCorrelationID(index: UInt32)
    case invalidOuterExecutionIndex
    case invalidRawRowCount(
        expected: Int,
        observed: Int
    )
    case duplicateRawExecutionIndex(UInt32)
    case invalidRawExecutionIndex
    case rawReplicateSeedMismatch(
        expected: Int,
        observed: Int
    )
    case logitReplicateSeedMismatch(
        expected: Int,
        observed: Int
    )
    case invalidLogitRowCount(
        expected: Int,
        observed: Int
    )
    case duplicateLogitRowOrdinal(Int)
    case invalidLogitRowOrdinal
    case rawPromptDigestMismatch(index: UInt32)
    case outerCorrelationMismatch(index: UInt32)
    case logitCorrelationMismatch(index: UInt32)
    case decisionCountMismatch(index: UInt32)
    case generatedTokenMismatch(index: UInt32)
    case terminationMismatch(index: UInt32)
    case traceDigestMismatch(index: UInt32)
}

/// Frozen non-authorizing contract for composing independently ordered
/// Stage-B record streams.
///
/// Artifact namespace V4 remains byte-for-byte history. This separate
/// contract freezes the producer/decoder codec seam, prompt-derived schedule,
/// and exact outer/raw/logit join without changing any V4 artifact wire.
public struct PrimeNativeNeuralGateReplayCompositionContract:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let contractID: String
    public let artifactOutputContractID: String
    public let artifactOutputContractSHA256: String
    public let canonicalTransportCodecID: String
    public let invariantCodecID: String
    public let implementedRecordSchemaIDs: [String]
    public let promptScheduleID: String
    public let scheduleIdentityMagic: String
    public let scheduleIdentitySerializationID:
        String
    public let correlationIdentityMagic: String
    public let correlationIdentitySerializationID:
        String
    public let promptBindingMagic: String
    public let promptBindingSerializationID: String
    public let correctedTraceMagic: String
    public let logitSidecarCodecID: String
    public let logitRowsPerChunk: Int
    public let logitChunkCount: Int
    public let exactRowCount: Int
    public let admittedReplicateSeeds: [Int]
    public let canonicalCodecImplemented: Bool
    public let strictPromptScheduleImplemented: Bool
    public let exactCrossArtifactJoinImplemented: Bool
    public let correctedTraceRecomputationImplemented: Bool
    public let correlationScheduleCapabilityDeliveryImplemented:
        Bool
    public let independentPromptTargetCrosswalkImplemented:
        Bool
    public let descriptorStreamingImplemented: Bool
    public let durableArtifactOriginEstablished: Bool
    public let promptContentTargetIndependenceEstablished: Bool
    public let modelExecutionEstablished: Bool
    public let publicationAuthorized: Bool
    public let scientificAuthorityAuthorized: Bool
    public let mechanicsPassAuthorized: Bool
    public let terminalReceiptAuthorized: Bool
    public let productAuthorityAuthorized: Bool
    public let authorityStatement: String

    public static let frozenV1 = Self(
        schemaVersion: 1,
        contractID:
            "prime_stage_b_strict_prompt_schedule_exact_cross_artifact_join_v1",
        artifactOutputContractID:
            PrimeNativeNeuralGateReplayArtifactOutputContract
            .frozenV4.contractID,
        artifactOutputContractSHA256:
            "60e10e6c10f9ec1f30102f5b6d27be123434a163c01d82c0cc5d4520824532d1",
        canonicalTransportCodecID:
            PrimeNativeNeuralGateReplayTransportCodec
            .serializationContractID,
        invariantCodecID:
            PrimeNativeNeuralGateInvariantCodec
            .serializationContractID,
        implementedRecordSchemaIDs:
            PrimeNativeNeuralGateReplayRecordSchema
            .orderedImplementedIDs,
        promptScheduleID:
            "strict_ordinal_of_caller_provided_canonical_prompt_row_json_bytes_v1",
        scheduleIdentityMagic: "PRIMESCH1",
        scheduleIdentitySerializationID:
            "primesch1_then_uint32_big_endian_record_count_then_raw_prompt_global_stream_sha256_v1",
        correlationIdentityMagic:
            PrimeNativeNeuralGateReplayCorrelationIdentity
            .magic,
        correlationIdentitySerializationID:
            PrimeNativeNeuralGateReplayCorrelationIdentity
            .serializationContractID,
        promptBindingMagic: "PRIMECPI2",
        promptBindingSerializationID:
            "primecpi2_then_uint64_big_endian_token_count_then_uint16_big_endian_token_ids_v1",
        correctedTraceMagic: "PRIMECRT4",
        logitSidecarCodecID:
            PrimeNativeNeuralGateLogitSidecarPolicy
            .codecID,
        logitRowsPerChunk:
            PrimeNativeNeuralGateLogitSidecarPolicy
            .rowsPerChunk,
        logitChunkCount:
            PrimeNativeNeuralGateLogitSidecarPolicy
            .exactChunkCount,
        exactRowCount:
            PrimeNativeNeuralGateReplayArtifactOutputContract
            .frozenV4.exactCorrectedFixtureRowCount,
        admittedReplicateSeeds:
            PrimeNativeNeuralGateArtifactSeed
            .allCases.map(\.rawValue),
        canonicalCodecImplemented: true,
        strictPromptScheduleImplemented: true,
        exactCrossArtifactJoinImplemented: true,
        correctedTraceRecomputationImplemented: true,
        correlationScheduleCapabilityDeliveryImplemented:
            false,
        independentPromptTargetCrosswalkImplemented:
            false,
        descriptorStreamingImplemented: false,
        durableArtifactOriginEstablished: false,
        promptContentTargetIndependenceEstablished:
            false,
        modelExecutionEstablished: false,
        publicationAuthorized: false,
        scientificAuthorityAuthorized: false,
        mechanicsPassAuthorized: false,
        terminalReceiptAuthorized: false,
        productAuthorityAuthorized: false,
        authorityStatement:
            "This V1 composition contract preserves artifact namespace V4, uses its shared canonical transport codec, assigns execution indexes only as strict ordinals of exactly 18,432 caller-provided canonical prompt-row JSON records, derives target-free correlation identity from execution index plus PRIMECPI2 prompt binding, and requires exact outer/raw/logit-sidecar joins with PRIMECRT4 trace recomputation. It does not decode or validate a descriptor-rooted source stream, implement lawful schedule-capability delivery to disjoint producers, independently bind expected completion to prompt, establish durable artifact origin, prove prompt-content target independence, execute a model, authorize mechanics PASS, issue a receipt, or authorize product use."
    )

    public func validate() throws {
        guard self == .frozenV1,
              schemaVersion == 1,
              artifactOutputContractID
                == PrimeNativeNeuralGateReplayArtifactOutputContract
                .frozenV4.contractID,
              artifactOutputContractSHA256
                == "60e10e6c10f9ec1f30102f5b6d27be123434a163c01d82c0cc5d4520824532d1",
              canonicalTransportCodecID
                == PrimeNativeNeuralGateReplayTransportCodec
                .serializationContractID,
              invariantCodecID
                == PrimeNativeNeuralGateInvariantCodec
                .serializationContractID,
              implementedRecordSchemaIDs
                == PrimeNativeNeuralGateReplayRecordSchema
                .orderedImplementedIDs,
              scheduleIdentityMagic == "PRIMESCH1",
              scheduleIdentitySerializationID
                == "primesch1_then_uint32_big_endian_record_count_then_raw_prompt_global_stream_sha256_v1",
              correlationIdentityMagic
                == PrimeNativeNeuralGateReplayCorrelationIdentity
                .magic,
              correlationIdentitySerializationID
                == PrimeNativeNeuralGateReplayCorrelationIdentity
                .serializationContractID,
              exactRowCount == 18_432,
              admittedReplicateSeeds == [
                  1_618,
                  2_718,
                  3_141,
              ],
              logitRowsPerChunk == 1_024,
              logitChunkCount == 18,
              canonicalCodecImplemented,
              strictPromptScheduleImplemented,
              exactCrossArtifactJoinImplemented,
              correctedTraceRecomputationImplemented,
              !correlationScheduleCapabilityDeliveryImplemented,
              !independentPromptTargetCrosswalkImplemented,
              !descriptorStreamingImplemented,
              !durableArtifactOriginEstablished,
              !promptContentTargetIndependenceEstablished,
              !modelExecutionEstablished,
              !publicationAuthorized,
              !scientificAuthorityAuthorized,
              !mechanicsPassAuthorized,
              !terminalReceiptAuthorized,
              !productAuthorityAuthorized
        else {
            throw PrimeNativeNeuralGateReplayCompositionError
                .invalidFrozenContract
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case contractID = "contract_id"
        case artifactOutputContractID =
            "artifact_output_contract_id"
        case artifactOutputContractSHA256 =
            "artifact_output_contract_sha256"
        case canonicalTransportCodecID =
            "canonical_transport_codec_id"
        case invariantCodecID = "invariant_codec_id"
        case implementedRecordSchemaIDs =
            "implemented_record_schema_ids"
        case promptScheduleID = "prompt_schedule_id"
        case scheduleIdentityMagic =
            "schedule_identity_magic"
        case scheduleIdentitySerializationID =
            "schedule_identity_serialization_id"
        case correlationIdentityMagic =
            "correlation_identity_magic"
        case correlationIdentitySerializationID =
            "correlation_identity_serialization_id"
        case promptBindingMagic =
            "prompt_binding_magic"
        case promptBindingSerializationID =
            "prompt_binding_serialization_id"
        case correctedTraceMagic =
            "corrected_trace_magic"
        case logitSidecarCodecID =
            "logit_sidecar_codec_id"
        case logitRowsPerChunk =
            "logit_rows_per_chunk"
        case logitChunkCount = "logit_chunk_count"
        case exactRowCount = "exact_row_count"
        case admittedReplicateSeeds =
            "admitted_replicate_seeds"
        case canonicalCodecImplemented =
            "canonical_codec_implemented"
        case strictPromptScheduleImplemented =
            "strict_prompt_schedule_implemented"
        case exactCrossArtifactJoinImplemented =
            "exact_cross_artifact_join_implemented"
        case correctedTraceRecomputationImplemented =
            "corrected_trace_recomputation_implemented"
        case correlationScheduleCapabilityDeliveryImplemented =
            "correlation_schedule_capability_delivery_implemented"
        case independentPromptTargetCrosswalkImplemented =
            "independent_prompt_target_crosswalk_implemented"
        case descriptorStreamingImplemented =
            "descriptor_streaming_implemented"
        case durableArtifactOriginEstablished =
            "durable_artifact_origin_established"
        case promptContentTargetIndependenceEstablished =
            "prompt_content_target_independence_established"
        case modelExecutionEstablished =
            "model_execution_established"
        case publicationAuthorized =
            "publication_authorized"
        case scientificAuthorityAuthorized =
            "scientific_authority_authorized"
        case mechanicsPassAuthorized =
            "mechanics_pass_authorized"
        case terminalReceiptAuthorized =
            "terminal_receipt_authorized"
        case productAuthorityAuthorized =
            "product_authority_authorized"
        case authorityStatement = "authority_statement"
    }
}

public struct PrimeNativeNeuralGateScheduledPrompt:
    Equatable,
    Sendable
{
    public let executionIndex: UInt32
    public let promptRow:
        PrimeNativeNeuralGateReplayPromptRow
    public let canonicalPromptRecordSHA256: String
    public let primeCPI2PromptBindingSHA256: String
    public let correlationID: String

    fileprivate let executionInput:
        PrimeNativeNeuralGatePromptOnlyExecutionInput

    fileprivate init(
        executionIndex: UInt32,
        promptRow:
            PrimeNativeNeuralGateReplayPromptRow,
        canonicalPromptRecordSHA256: String,
        primeCPI2PromptBindingSHA256: String,
        correlationID: String,
        executionInput:
            PrimeNativeNeuralGatePromptOnlyExecutionInput
    ) {
        self.executionIndex = executionIndex
        self.promptRow = promptRow
        self.canonicalPromptRecordSHA256 =
            canonicalPromptRecordSHA256
        self.primeCPI2PromptBindingSHA256 =
            primeCPI2PromptBindingSHA256
        self.correlationID = correlationID
        self.executionInput = executionInput
    }
}

/// Non-authorizing observation used to reconstruct the pure V1 schedule from
/// records that another target has already decoded and source-bound. Public
/// construction is safe because the returned V1 schedule retains every false
/// source/authority flag and independently re-encodes each row.
public struct PrimeNativeNeuralGateCanonicalPromptRecordObservation:
    Equatable,
    Sendable
{
    public let promptRow:
        PrimeNativeNeuralGateReplayPromptRow
    public let canonicalRecordSHA256: String

    public init(
        promptRow:
            PrimeNativeNeuralGateReplayPromptRow,
        canonicalRecordSHA256: String
    ) {
        self.promptRow = promptRow
        self.canonicalRecordSHA256 =
            canonicalRecordSHA256
    }
}

/// Non-Codable capability representing the exact prompt-derived schedule.
public struct PrimeNativeNeuralGatePromptSchedule:
    Equatable,
    Sendable
{
    public let contractID: String
    public let orderedPrompts:
        [PrimeNativeNeuralGateScheduledPrompt]
    public let promptGlobalStreamSHA256: String
    public let scheduleIdentitySHA256: String
    public let strictCanonicalRecordOrderObserved:
        Bool
    public let exactInMemoryScheduleIndexCoverageObserved:
        Bool
    public let correctedFixtureIdentityEstablished:
        Bool
    public let sourceStreamBindingEstablished: Bool
    public let mechanicsPassAuthorized: Bool

    fileprivate init(
        orderedPrompts:
            [PrimeNativeNeuralGateScheduledPrompt],
        promptGlobalStreamSHA256: String,
        scheduleIdentitySHA256: String
    ) {
        contractID =
            PrimeNativeNeuralGateReplayCompositionContract
            .frozenV1.contractID
        self.orderedPrompts = orderedPrompts
        self.promptGlobalStreamSHA256 =
            promptGlobalStreamSHA256
        self.scheduleIdentitySHA256 =
            scheduleIdentitySHA256
        strictCanonicalRecordOrderObserved = true
        exactInMemoryScheduleIndexCoverageObserved =
            true
        correctedFixtureIdentityEstablished = false
        sourceStreamBindingEstablished = false
        mechanicsPassAuthorized = false
    }
}

public struct PrimeNativeNeuralGateJoinedReplayRow:
    Equatable,
    Sendable
{
    public let scheduledPrompt:
        PrimeNativeNeuralGateScheduledPrompt
    public let outerEvaluation:
        PrimeNativeNeuralGateReplayOuterEvaluationRow
    public let rawExecution:
        PrimeNativeNeuralGateReplayRawExecutionReference
    public let logitReference:
        PrimeNativeNeuralGateLogitRowReference
}

/// Non-Codable exact mechanics join. It does not establish artifact origin.
public struct PrimeNativeNeuralGateJoinedReplayReplicate:
    Equatable,
    Sendable
{
    public let contractID: String
    public let replicateSeed:
        PrimeNativeNeuralGateArtifactSeed
    public let orderedRows:
        [PrimeNativeNeuralGateJoinedReplayRow]
    public let exactInMemoryJoinIndexCoverageObserved:
        Bool
    public let correctedFixtureIdentityEstablished:
        Bool
    public let promptDigestJoinObserved: Bool
    public let outerCorrelationJoinObserved: Bool
    public let correctedTraceJoinObserved: Bool
    public let outerExpectedCompletionBindingEstablished:
        Bool
    public let durableArtifactOriginEstablished: Bool
    public let promptContentTargetIndependenceEstablished:
        Bool
    public let modelExecutionEstablished: Bool
    public let mechanicsPassAuthorized: Bool

    fileprivate init(
        replicateSeed:
            PrimeNativeNeuralGateArtifactSeed,
        orderedRows:
            [PrimeNativeNeuralGateJoinedReplayRow]
    ) {
        contractID =
            PrimeNativeNeuralGateReplayCompositionContract
            .frozenV1.contractID
        self.replicateSeed = replicateSeed
        self.orderedRows = orderedRows
        exactInMemoryJoinIndexCoverageObserved = true
        correctedFixtureIdentityEstablished = false
        promptDigestJoinObserved = true
        outerCorrelationJoinObserved = true
        correctedTraceJoinObserved = true
        outerExpectedCompletionBindingEstablished =
            false
        durableArtifactOriginEstablished = false
        promptContentTargetIndependenceEstablished =
            false
        modelExecutionEstablished = false
        mechanicsPassAuthorized = false
    }
}

public enum PrimeNativeNeuralGateReplayComposition {
    private typealias Error =
        PrimeNativeNeuralGateReplayCompositionError
    private typealias Codec =
        PrimeNativeNeuralGateReplayTransportCodec
    private typealias Decoder =
        PrimeNativeNeuralGateReplayTransportDecoder

    public static func makePromptSchedule(
        canonicalPromptRecords: [Data]
    ) throws -> PrimeNativeNeuralGatePromptSchedule {
        let contract =
            PrimeNativeNeuralGateReplayCompositionContract
            .frozenV1
        try contract.validate()
        guard canonicalPromptRecords.count
                == contract.exactRowCount
        else {
            throw Error.invalidPromptRecordCount(
                expected: contract.exactRowCount,
                observed: canonicalPromptRecords.count
            )
        }
        var scheduled =
            [PrimeNativeNeuralGateScheduledPrompt]()
        scheduled.reserveCapacity(
            canonicalPromptRecords.count
        )
        var previous: Data?
        var promptBindings = Set<String>()
        for (index, record) in
            canonicalPromptRecords.enumerated()
        {
            if let previous {
                if previous == record {
                    throw Error.duplicatePromptRecord(
                        index: index
                    )
                }
                guard previous.lexicographicallyPrecedes(
                    record
                ) else {
                    throw Error
                        .noncanonicalPromptRecordOrder(
                            index: index
                        )
                }
            }
            let row = try Decoder.decodePromptOnlyRow(
                from: record
            )
            guard try Codec.encodePromptOnlyRow(row)
                    == record
            else {
                throw Error.promptRecordRoundTripMismatch(
                    index: index
                )
            }
            let input = try
                PrimeNativeNeuralGatePromptOnlyExecutionInput
                .derive(
                    promptText: row.canonicalPrompt
                )
            guard input.promptTokenIDs
                    == row.promptTokenIDs.map(Int.init)
            else {
                throw Error.promptBindingMismatch(
                    index: index
                )
            }
            guard promptBindings.insert(
                input.bindingSHA256
            ).inserted else {
                throw Error.duplicatePromptBinding(
                    index: index
                )
            }
            guard let executionIndex = UInt32(
                exactly: index
            ) else {
                throw Error.promptBindingMismatch(
                    index: index
                )
            }
            scheduled.append(
                PrimeNativeNeuralGateScheduledPrompt(
                    executionIndex: executionIndex,
                    promptRow: row,
                    canonicalPromptRecordSHA256:
                        PrimeNativeNeuralGateInvariantCodec
                        .sha256(record),
                    primeCPI2PromptBindingSHA256:
                        input.bindingSHA256,
                    correlationID:
                        try PrimeNativeNeuralGateReplayCorrelationIdentity
                        .derive(
                            executionIndex:
                                executionIndex,
                            primeCPI2PromptBindingSHA256:
                                input.bindingSHA256
                        ),
                    executionInput: input
                )
            )
            previous = record
        }
        let globalStream = try
            PrimeNativeNeuralGateInvariantCodec
            .encodeGlobal(
                canonicalRecords:
                    canonicalPromptRecords
            )
        let globalSHA256 =
            PrimeNativeNeuralGateInvariantCodec
            .sha256(globalStream)
        return PrimeNativeNeuralGatePromptSchedule(
            orderedPrompts: scheduled,
            promptGlobalStreamSHA256:
                globalSHA256,
            scheduleIdentitySHA256:
                try scheduleIdentitySHA256(
                    promptGlobalStreamSHA256:
                        globalSHA256,
                    recordCount:
                        canonicalPromptRecords.count
                )
        )
    }

    /// Reconstructs the same pure V1 schedule from typed prompt observations
    /// without allocating a second complete invariant stream. The incremental
    /// accumulator re-creates the exact PRIMEIRM1 digest while every record is
    /// re-encoded, digest-checked, ordered, and bound to PRIMECPI2.
    public static func makePromptSchedule(
        canonicalPromptRecordObservations:
            [PrimeNativeNeuralGateCanonicalPromptRecordObservation],
        expectedPromptGlobalStreamSHA256: String
    ) throws -> PrimeNativeNeuralGatePromptSchedule {
        let contract =
            PrimeNativeNeuralGateReplayCompositionContract
            .frozenV1
        try contract.validate()
        guard canonicalPromptRecordObservations.count
                == contract.exactRowCount
        else {
            throw Error.invalidPromptRecordCount(
                expected: contract.exactRowCount,
                observed:
                    canonicalPromptRecordObservations.count
            )
        }
        let streamSpec = try
            PrimeNativeNeuralGateReplayArtifactOutputContract
            .frozenV4.spec(
                for: .promptOnlyFixtureGlobal
            )
        guard let maximumAggregateRecordBytes = Int(
            exactly: streamSpec.maximumByteCount
        ) else {
            throw Error.invalidPromptRecordCount(
                expected: contract.exactRowCount,
                observed:
                    canonicalPromptRecordObservations.count
            )
        }
        let limits = try
            PrimeNativeNeuralGateReplayDecodeLimits
            .bounded(
                maximumRecordCount:
                    contract.exactRowCount,
                maximumRecordByteCount:
                    PrimeNativeNeuralGateReplayRecordTransportPolicy
                    .maximumPromptOnlyRowByteCount,
                maximumAggregateRecordBytes:
                    maximumAggregateRecordBytes
            )
        var accumulator = try
            PrimeNativeNeuralGateInvariantGlobalStreamSHA256Accumulator(
                declaredRecordCount:
                    UInt64(contract.exactRowCount),
                limits: limits,
                requireCanonicalOrder: true
            )
        var scheduled =
            [PrimeNativeNeuralGateScheduledPrompt]()
        scheduled.reserveCapacity(
            canonicalPromptRecordObservations.count
        )
        var previous: Data?
        var promptBindings = Set<String>()
        for (index, observation) in
            canonicalPromptRecordObservations.enumerated()
        {
            let record = try Codec.encodePromptOnlyRow(
                observation.promptRow
            )
            guard PrimeNativeNeuralGateInvariantCodec
                    .sha256(record)
                    == observation
                    .canonicalRecordSHA256
            else {
                throw Error.promptRecordDigestMismatch(
                    index: index
                )
            }
            if let previous {
                if previous == record {
                    throw Error.duplicatePromptRecord(
                        index: index
                    )
                }
                guard previous.lexicographicallyPrecedes(
                    record
                ) else {
                    throw Error
                        .noncanonicalPromptRecordOrder(
                            index: index
                        )
                }
            }
            guard try Decoder.decodePromptOnlyRow(
                from: record
            ) == observation.promptRow else {
                throw Error.promptRecordRoundTripMismatch(
                    index: index
                )
            }
            let input = try
                PrimeNativeNeuralGatePromptOnlyExecutionInput
                .derive(
                    promptText:
                        observation
                        .promptRow.canonicalPrompt
                )
            guard input.promptTokenIDs
                    == observation.promptRow
                    .promptTokenIDs.map(Int.init)
            else {
                throw Error.promptBindingMismatch(
                    index: index
                )
            }
            guard promptBindings.insert(
                input.bindingSHA256
            ).inserted else {
                throw Error.duplicatePromptBinding(
                    index: index
                )
            }
            guard let executionIndex = UInt32(
                exactly: index
            ) else {
                throw Error.promptBindingMismatch(
                    index: index
                )
            }
            try accumulator.append(
                canonicalRecord: record
            )
            scheduled.append(
                PrimeNativeNeuralGateScheduledPrompt(
                    executionIndex: executionIndex,
                    promptRow: observation.promptRow,
                    canonicalPromptRecordSHA256:
                        observation
                        .canonicalRecordSHA256,
                    primeCPI2PromptBindingSHA256:
                        input.bindingSHA256,
                    correlationID:
                        try PrimeNativeNeuralGateReplayCorrelationIdentity
                        .derive(
                            executionIndex:
                                executionIndex,
                            primeCPI2PromptBindingSHA256:
                                input.bindingSHA256
                        ),
                    executionInput: input
                )
            )
            previous = record
        }
        let summary = try accumulator.finish()
        guard summary.streamSHA256
                == expectedPromptGlobalStreamSHA256
        else {
            throw Error.promptGlobalStreamDigestMismatch
        }
        return PrimeNativeNeuralGatePromptSchedule(
            orderedPrompts: scheduled,
            promptGlobalStreamSHA256:
                summary.streamSHA256,
            scheduleIdentitySHA256:
                try scheduleIdentitySHA256(
                    promptGlobalStreamSHA256:
                        summary.streamSHA256,
                    recordCount:
                        canonicalPromptRecordObservations
                        .count
                )
        )
    }

    public static func join(
        schedule: PrimeNativeNeuralGatePromptSchedule,
        replicateSeed:
            PrimeNativeNeuralGateArtifactSeed,
        outerRows:
            [PrimeNativeNeuralGateReplayOuterEvaluationRow],
        rawRows:
            [PrimeNativeNeuralGateReplayRawExecutionReference],
        validatedLogitSidecar:
            PrimeNativeNeuralGateValidatedLogitSidecar
    ) throws -> PrimeNativeNeuralGateJoinedReplayReplicate {
        let contract =
            PrimeNativeNeuralGateReplayCompositionContract
            .frozenV1
        try contract.validate()
        let exactCount = contract.exactRowCount
        guard schedule.contractID == contract.contractID,
              schedule.orderedPrompts.count == exactCount,
              schedule.strictCanonicalRecordOrderObserved,
              schedule
                .exactInMemoryScheduleIndexCoverageObserved,
              !schedule
                .correctedFixtureIdentityEstablished,
              !schedule.sourceStreamBindingEstablished,
              !schedule.mechanicsPassAuthorized
        else {
            throw Error.invalidPromptRecordCount(
                expected: exactCount,
                observed: schedule.orderedPrompts.count
            )
        }
        guard outerRows.count == exactCount else {
            throw Error.invalidOuterRowCount(
                expected: exactCount,
                observed: outerRows.count
            )
        }
        guard rawRows.count == exactCount else {
            throw Error.invalidRawRowCount(
                expected: exactCount,
                observed: rawRows.count
            )
        }
        let sidecarSeed =
            validatedLogitSidecar.dictionary
            .replicateContext.evaluationSeed
        guard sidecarSeed == replicateSeed.rawValue else {
            throw Error.logitReplicateSeedMismatch(
                expected: replicateSeed.rawValue,
                observed: sidecarSeed
            )
        }
        let logitRows =
            validatedLogitSidecar.chunks
            .flatMap(\.rows)
        guard logitRows.count == exactCount else {
            throw Error.invalidLogitRowCount(
                expected: exactCount,
                observed: logitRows.count
            )
        }

        var outerByIndex = Array<
            PrimeNativeNeuralGateReplayOuterEvaluationRow?
        >(repeating: nil, count: exactCount)
        var correlations = Set<String>()
        for row in outerRows {
            guard let index = Int(
                exactly: row.executionIndex
            ),
                  outerByIndex.indices.contains(index)
            else {
                throw Error.invalidOuterExecutionIndex
            }
            guard outerByIndex[index] == nil else {
                throw Error.duplicateOuterExecutionIndex(
                    row.executionIndex
                )
            }
            guard correlations.insert(
                row.correlationID
            ).inserted else {
                throw Error.duplicateOuterCorrelationID(
                    index: row.executionIndex
                )
            }
            outerByIndex[index] = row
        }

        var rawByIndex = Array<
            PrimeNativeNeuralGateReplayRawExecutionReference?
        >(repeating: nil, count: exactCount)
        for row in rawRows {
            guard row.replicateSeed == replicateSeed else {
                throw Error.rawReplicateSeedMismatch(
                    expected: replicateSeed.rawValue,
                    observed: row.replicateSeed.rawValue
                )
            }
            guard let index = Int(
                exactly: row.executionIndex
            ),
                  rawByIndex.indices.contains(index)
            else {
                throw Error.invalidRawExecutionIndex
            }
            guard rawByIndex[index] == nil else {
                throw Error.duplicateRawExecutionIndex(
                    row.executionIndex
                )
            }
            rawByIndex[index] = row
        }

        var logitByIndex = Array<
            PrimeNativeNeuralGateLogitRowReference?
        >(repeating: nil, count: exactCount)
        for row in logitRows {
            guard logitByIndex.indices.contains(
                row.rowOrdinal
            ) else {
                throw Error.invalidLogitRowOrdinal
            }
            guard logitByIndex[row.rowOrdinal] == nil
            else {
                throw Error.duplicateLogitRowOrdinal(
                    row.rowOrdinal
                )
            }
            logitByIndex[row.rowOrdinal] = row
        }

        let replicateContext = try
            PrimeNativeNeuralGateCorrectedReplicateContext(
                evaluationSeed: replicateSeed.rawValue
            )
        var joined =
            [PrimeNativeNeuralGateJoinedReplayRow]()
        joined.reserveCapacity(exactCount)
        for scheduled in schedule.orderedPrompts {
            let index = scheduled.executionIndex
            guard let arrayIndex = Int(exactly: index),
                  outerByIndex.indices.contains(arrayIndex),
                  rawByIndex.indices.contains(arrayIndex),
                  logitByIndex.indices.contains(arrayIndex)
            else {
                throw Error.invalidPromptRecordCount(
                    expected: exactCount,
                    observed: schedule.orderedPrompts.count
                )
            }
            guard let outer = outerByIndex[arrayIndex]
            else {
                throw Error.invalidOuterRowCount(
                    expected: exactCount,
                    observed:
                        outerByIndex.compactMap { $0 }.count
                )
            }
            guard let raw = rawByIndex[arrayIndex] else {
                throw Error.invalidRawRowCount(
                    expected: exactCount,
                    observed:
                        rawByIndex.compactMap { $0 }.count
                )
            }
            guard let logit = logitByIndex[arrayIndex]
            else {
                throw Error.invalidLogitRowCount(
                    expected: exactCount,
                    observed:
                        logitByIndex.compactMap { $0 }.count
                )
            }
            guard raw.promptSHA256
                    == scheduled
                    .primeCPI2PromptBindingSHA256
            else {
                throw Error.rawPromptDigestMismatch(
                    index: index
                )
            }
            guard outer.correlationID
                    == scheduled.correlationID
            else {
                throw Error.outerCorrelationMismatch(
                    index: index
                )
            }
            guard logit.correlationID
                    == scheduled.correlationID
            else {
                throw Error.logitCorrelationMismatch(
                    index: index
                )
            }
            guard logit.decisions.count
                    == Int(raw.decisionCount)
            else {
                throw Error.decisionCountMismatch(
                    index: index
                )
            }
            let decisions = try logit.decisions.map {
                reference in
                try PrimeNativeNeuralGateCompletionDecision
                    .make(
                        ordinal: reference.ordinal,
                        fullVocabularyLogits:
                            try validatedLogitSidecar
                            .dictionary
                            .fullVocabularyLogits(
                                at:
                                    reference
                                    .dictionaryIndex
                            )
                    )
            }
            let recomputed = try
                PrimeNativeNeuralGateRawExecution.validate(
                    replicateContext: replicateContext,
                    input: scheduled.executionInput,
                    decisions: decisions
                )
            let recomputedTermination:
                PrimeNativeNeuralGateReplayTermination
            switch recomputed.termination {
            case .eos:
                recomputedTermination = .eos
            case .fixedCap:
                recomputedTermination = .fixedCap
            }
            guard recomputedTermination == raw.termination
            else {
                throw Error.terminationMismatch(
                    index: index
                )
            }
            guard recomputed.generatedTokenIDs
                    == raw.generatedTokenIDs.map(Int.init)
            else {
                throw Error.generatedTokenMismatch(
                    index: index
                )
            }
            guard recomputed.traceSHA256
                    == raw.traceSHA256
            else {
                throw Error.traceDigestMismatch(
                    index: index
                )
            }
            joined.append(
                PrimeNativeNeuralGateJoinedReplayRow(
                    scheduledPrompt: scheduled,
                    outerEvaluation: outer,
                    rawExecution: raw,
                    logitReference: logit
                )
            )
        }
        return PrimeNativeNeuralGateJoinedReplayReplicate(
            replicateSeed: replicateSeed,
            orderedRows: joined
        )
    }

    private static func scheduleIdentitySHA256(
        promptGlobalStreamSHA256: String,
        recordCount: Int
    ) throws -> String {
        guard let count = UInt32(exactly: recordCount),
              promptGlobalStreamSHA256.utf8.count == 64
        else {
            throw Error.invalidPromptRecordCount(
                expected:
                    PrimeNativeNeuralGateReplayCompositionContract
                    .frozenV1.exactRowCount,
                observed: recordCount
            )
        }
        let contract =
            PrimeNativeNeuralGateReplayCompositionContract
            .frozenV1
        var data = Data(
            contract.scheduleIdentityMagic.utf8
        )
        var bigEndianCount = count.bigEndian
        withUnsafeBytes(of: &bigEndianCount) {
            data.append(contentsOf: $0)
        }
        let hexadecimal = Array(
            promptGlobalStreamSHA256.utf8
        )
        for index in stride(
            from: 0,
            to: hexadecimal.count,
            by: 2
        ) {
            guard let high = hexadecimalValue(
                hexadecimal[index]
            ),
                  let low = hexadecimalValue(
                      hexadecimal[index + 1]
                  )
            else {
                throw Error.promptBindingMismatch(
                    index: index / 2
                )
            }
            data.append(high << 4 | low)
        }
        return PrimeNativeNeuralGateInvariantCodec
            .sha256(data)
    }

    private static func hexadecimalValue(
        _ value: UInt8
    ) -> UInt8? {
        switch value {
        case 48 ... 57:
            return value - 48
        case 97 ... 102:
            return value - 87
        default:
            return nil
        }
    }
}
