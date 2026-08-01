import Foundation
import PrimeNativeNeuralGateReplayMechanics

public enum PrimeNativeNeuralGateTargetFreeScheduleStreamError:
    Error,
    Equatable,
    Sendable
{
    case invalidFrozenV2Contract
    case headerByteLimitExceeded(
        maximum: Int,
        observed: Int
    )
    case unexpectedHeaderKeys([String])
    case invalidHeader
    case noncanonicalHeaderEncoding
    case invalidHeaderIdentity
    case feedByteLimitExceeded(
        maximum: Int,
        observed: Int
    )
    case invalidDecoderPhase
    case rawStreamIdentityMismatch
    case outerStreamIdentityMismatch
    case rawCandidateIdentityMismatch
    case outerCandidateIdentityMismatch
    case deliveryIdentityMismatch
    case expectedCandidatePairMismatch
}

/// Additive V2 transport mechanics for two exact, independently framed
/// target-free slot streams. V1 values and identities remain unchanged.
///
/// A decoder success is only bounded byte admission. It is not source,
/// process-delivery, execution, evaluation, PASS, receipt, scientific, or
/// product authority.
public struct PrimeNativeNeuralGateTargetFreeScheduleStreamContract:
    Encodable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let contractID: String
    public let preservedV1ContractID: String
    public let invariantStreamCodecID: String
    public let exactScheduleRowCount: Int
    public let maximumHeaderJSONByteCount: Int
    public let maximumDescriptorFeedByteCount: Int
    public let maximumRawSlotJSONByteCount: Int
    public let maximumOuterSlotJSONByteCount: Int
    public let maximumRawAggregateRecordBytes: Int
    public let maximumOuterAggregateRecordBytes: Int
    public let maximumRawFramedStreamBytes: Int
    public let maximumOuterFramedStreamBytes: Int
    public let maximumCombinedFramedStreamBytes: Int
    public let exactDeclaredCountFailEarlyImplemented: Bool
    public let oneRecordAtATimeDecodingImplemented: Bool
    public let boundedCandidateStreamDecodingImplemented: Bool
    public let aggregateJSONCandidateDecodingForbidden: Bool
    public let candidateTypesRemainEncodableOnly: Bool
    public let sourceBindingEstablished: Bool
    public let durableArtifactOriginEstablished: Bool
    public let promptContentTargetIndependenceEstablished: Bool
    public let processOwnershipEstablished: Bool
    public let processDeliveryObserved: Bool
    public let workerMaterialized: Bool
    public let modelExecutionEstablished: Bool
    public let evaluationPerformed: Bool
    public let verdictPublicationAuthorized: Bool
    public let publicationAuthorized: Bool
    public let mechanicsPassAuthorized: Bool
    public let terminalReceiptAuthorized: Bool
    public let scientificAuthorityAuthorized: Bool
    public let productAuthorityAuthorized: Bool

    public static let frozenV2 = Self(
        schemaVersion: 2,
        contractID:
            "prime_stage_b_target_free_schedule_bounded_stream_transport_v2",
        preservedV1ContractID:
            PrimeNativeNeuralGateTargetFreeScheduleDeliveryContract
            .frozenV1.contractID,
        invariantStreamCodecID:
            PrimeNativeNeuralGateInvariantCodec
            .serializationContractID,
        exactScheduleRowCount: 18_432,
        maximumHeaderJSONByteCount: 4_096,
        maximumDescriptorFeedByteCount: 64 * 1_024,
        maximumRawSlotJSONByteCount: 16_384,
        maximumOuterSlotJSONByteCount: 1_024,
        maximumRawAggregateRecordBytes: 301_989_888,
        maximumOuterAggregateRecordBytes: 18_874_368,
        maximumRawFramedStreamBytes: 302_137_361,
        maximumOuterFramedStreamBytes: 19_021_841,
        maximumCombinedFramedStreamBytes: 321_159_202,
        exactDeclaredCountFailEarlyImplemented: true,
        oneRecordAtATimeDecodingImplemented: true,
        boundedCandidateStreamDecodingImplemented: true,
        aggregateJSONCandidateDecodingForbidden: true,
        candidateTypesRemainEncodableOnly: true,
        sourceBindingEstablished: false,
        durableArtifactOriginEstablished: false,
        promptContentTargetIndependenceEstablished: false,
        processOwnershipEstablished: false,
        processDeliveryObserved: false,
        workerMaterialized: false,
        modelExecutionEstablished: false,
        evaluationPerformed: false,
        verdictPublicationAuthorized: false,
        publicationAuthorized: false,
        mechanicsPassAuthorized: false,
        terminalReceiptAuthorized: false,
        scientificAuthorityAuthorized: false,
        productAuthorityAuthorized: false
    )

    public func validate() throws {
        let v1 =
            PrimeNativeNeuralGateTargetFreeScheduleDeliveryContract
            .frozenV1
        let rows = exactScheduleRowCount
        let framingOverhead = 9 + 8 + rows * 8
        guard self == .frozenV2,
              schemaVersion == 2,
              preservedV1ContractID == v1.contractID,
              invariantStreamCodecID
                == PrimeNativeNeuralGateInvariantCodec
                .serializationContractID,
              rows == v1.exactScheduleRowCount,
              maximumHeaderJSONByteCount == 4_096,
              maximumDescriptorFeedByteCount == 65_536,
              maximumRawSlotJSONByteCount
                == v1.maximumRawSlotJSONByteCount,
              maximumOuterSlotJSONByteCount
                == v1.maximumOuterSlotJSONByteCount,
              maximumRawAggregateRecordBytes
                == rows * maximumRawSlotJSONByteCount,
              maximumOuterAggregateRecordBytes
                == rows * maximumOuterSlotJSONByteCount,
              maximumRawFramedStreamBytes
                == framingOverhead
                    + maximumRawAggregateRecordBytes,
              maximumOuterFramedStreamBytes
                == framingOverhead
                    + maximumOuterAggregateRecordBytes,
              maximumCombinedFramedStreamBytes
                == maximumRawFramedStreamBytes
                    + maximumOuterFramedStreamBytes,
              exactDeclaredCountFailEarlyImplemented,
              oneRecordAtATimeDecodingImplemented,
              boundedCandidateStreamDecodingImplemented,
              aggregateJSONCandidateDecodingForbidden,
              candidateTypesRemainEncodableOnly,
              !sourceBindingEstablished,
              !durableArtifactOriginEstablished,
              !promptContentTargetIndependenceEstablished,
              !processOwnershipEstablished,
              !processDeliveryObserved,
              !workerMaterialized,
              !modelExecutionEstablished,
              !evaluationPerformed,
              !verdictPublicationAuthorized,
              !publicationAuthorized,
              !mechanicsPassAuthorized,
              !terminalReceiptAuthorized,
              !scientificAuthorityAuthorized,
              !productAuthorityAuthorized
        else {
            throw PrimeNativeNeuralGateTargetFreeScheduleStreamError
                .invalidFrozenV2Contract
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case contractID = "contract_id"
        case preservedV1ContractID = "preserved_v1_contract_id"
        case invariantStreamCodecID = "invariant_stream_codec_id"
        case exactScheduleRowCount = "exact_schedule_row_count"
        case maximumHeaderJSONByteCount =
            "maximum_header_json_byte_count"
        case maximumDescriptorFeedByteCount =
            "maximum_descriptor_feed_byte_count"
        case maximumRawSlotJSONByteCount =
            "maximum_raw_slot_json_byte_count"
        case maximumOuterSlotJSONByteCount =
            "maximum_outer_slot_json_byte_count"
        case maximumRawAggregateRecordBytes =
            "maximum_raw_aggregate_record_bytes"
        case maximumOuterAggregateRecordBytes =
            "maximum_outer_aggregate_record_bytes"
        case maximumRawFramedStreamBytes =
            "maximum_raw_framed_stream_bytes"
        case maximumOuterFramedStreamBytes =
            "maximum_outer_framed_stream_bytes"
        case maximumCombinedFramedStreamBytes =
            "maximum_combined_framed_stream_bytes"
        case exactDeclaredCountFailEarlyImplemented =
            "exact_declared_count_fail_early_implemented"
        case oneRecordAtATimeDecodingImplemented =
            "one_record_at_a_time_decoding_implemented"
        case boundedCandidateStreamDecodingImplemented =
            "bounded_candidate_stream_decoding_implemented"
        case aggregateJSONCandidateDecodingForbidden =
            "aggregate_json_candidate_decoding_forbidden"
        case candidateTypesRemainEncodableOnly =
            "candidate_types_remain_encodable_only"
        case sourceBindingEstablished = "source_binding_established"
        case durableArtifactOriginEstablished =
            "durable_artifact_origin_established"
        case promptContentTargetIndependenceEstablished =
            "prompt_content_target_independence_established"
        case processOwnershipEstablished =
            "process_ownership_established"
        case processDeliveryObserved = "process_delivery_observed"
        case workerMaterialized = "worker_materialized"
        case modelExecutionEstablished = "model_execution_established"
        case evaluationPerformed = "evaluation_performed"
        case verdictPublicationAuthorized =
            "verdict_publication_authorized"
        case publicationAuthorized = "publication_authorized"
        case mechanicsPassAuthorized = "mechanics_pass_authorized"
        case terminalReceiptAuthorized = "terminal_receipt_authorized"
        case scientificAuthorityAuthorized =
            "scientific_authority_authorized"
        case productAuthorityAuthorized = "product_authority_authorized"
    }
}

/// Scalar expectation for two independently framed streams. It contains no
/// slots and remains Encodable-only. Decoding is available only through the
/// bounded, strict factory below.
public struct PrimeNativeNeuralGateTargetFreeSchedulePairStreamHeader:
    Encodable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let artifactKind: String
    public let streamContractID: String
    public let targetFreeScheduleDeliveryContractID: String
    public let invocationRole:
        PrimeNativeNeuralGateTargetFreeScheduleInvocationRole
    public let promptSourceBindingSHA256: String
    public let scheduleIdentitySHA256: String
    public let orderedSlotCount: Int
    public let rawOrderedSlotsSHA256: String
    public let outerOrderedSlotsSHA256: String
    public let rawCandidateIdentitySHA256: String
    public let outerCandidateIdentitySHA256: String
    public let deliveryIdentitySHA256: String

    public init(
        invocationRole:
            PrimeNativeNeuralGateTargetFreeScheduleInvocationRole,
        promptSourceBindingSHA256: String,
        scheduleIdentitySHA256: String,
        rawOrderedSlotsSHA256: String,
        outerOrderedSlotsSHA256: String
    ) throws {
        let streamContract =
            PrimeNativeNeuralGateTargetFreeScheduleStreamContract
            .frozenV2
        try streamContract.validate()
        guard isLowercaseStreamSHA256(promptSourceBindingSHA256),
              isLowercaseStreamSHA256(scheduleIdentitySHA256),
              isLowercaseStreamSHA256(rawOrderedSlotsSHA256),
              isLowercaseStreamSHA256(outerOrderedSlotsSHA256)
        else {
            throw PrimeNativeNeuralGateTargetFreeScheduleStreamError
                .invalidHeaderIdentity
        }
        let rowCount = streamContract.exactScheduleRowCount
        let rawCandidate = try targetFreeCandidateIdentitySHA256(
            role: invocationRole,
            promptSourceBindingSHA256: promptSourceBindingSHA256,
            scheduleIdentitySHA256: scheduleIdentitySHA256,
            orderedSlotsSHA256: rawOrderedSlotsSHA256,
            rowCount: rowCount,
            kind: "raw"
        )
        let outerCandidate = try targetFreeCandidateIdentitySHA256(
            role: invocationRole,
            promptSourceBindingSHA256: promptSourceBindingSHA256,
            scheduleIdentitySHA256: scheduleIdentitySHA256,
            orderedSlotsSHA256: outerOrderedSlotsSHA256,
            rowCount: rowCount,
            kind: "outer"
        )
        schemaVersion = 2
        artifactKind =
            "prime_stage_b_target_free_schedule_pair_stream_header_v2"
        streamContractID = streamContract.contractID
        targetFreeScheduleDeliveryContractID =
            streamContract.preservedV1ContractID
        self.invocationRole = invocationRole
        self.promptSourceBindingSHA256 = promptSourceBindingSHA256
        self.scheduleIdentitySHA256 = scheduleIdentitySHA256
        orderedSlotCount = rowCount
        self.rawOrderedSlotsSHA256 = rawOrderedSlotsSHA256
        self.outerOrderedSlotsSHA256 = outerOrderedSlotsSHA256
        rawCandidateIdentitySHA256 = rawCandidate
        outerCandidateIdentitySHA256 = outerCandidate
        deliveryIdentitySHA256 = try targetFreeDeliveryIdentitySHA256(
            role: invocationRole,
            promptSourceBindingSHA256: promptSourceBindingSHA256,
            scheduleIdentitySHA256: scheduleIdentitySHA256,
            rawCandidateIdentitySHA256: rawCandidate,
            outerCandidateIdentitySHA256: outerCandidate,
            rowCount: rowCount
        )
    }

    public init(
        expectedCandidatePair:
            PrimeNativeNeuralGateTargetFreeScheduleCandidatePair
    ) throws {
        try expectedCandidatePair.validate()
        try self.init(
            invocationRole:
                expectedCandidatePair.rawSchedule.invocationRole,
            promptSourceBindingSHA256:
                expectedCandidatePair.rawSchedule
                .promptSourceBindingSHA256,
            scheduleIdentitySHA256:
                expectedCandidatePair.rawSchedule
                .scheduleIdentitySHA256,
            rawOrderedSlotsSHA256:
                expectedCandidatePair.rawSchedule
                .orderedSlotsSHA256,
            outerOrderedSlotsSHA256:
                expectedCandidatePair.outerSchedule
                .orderedSlotsSHA256
        )
        guard rawCandidateIdentitySHA256
                == expectedCandidatePair.rawSchedule
                .candidateIdentitySHA256,
              outerCandidateIdentitySHA256
                == expectedCandidatePair.outerSchedule
                .candidateIdentitySHA256,
              deliveryIdentitySHA256
                == expectedCandidatePair.deliveryIdentitySHA256
        else {
            throw PrimeNativeNeuralGateTargetFreeScheduleStreamError
                .expectedCandidatePairMismatch
        }
    }

    public func canonicalJSON() throws -> Data {
        try canonicalStreamJSON(self)
    }

    public static func decodeBounded(
        from data: Data
    ) throws -> Self {
        let maximum =
            PrimeNativeNeuralGateTargetFreeScheduleStreamContract
            .frozenV2.maximumHeaderJSONByteCount
        guard data.count <= maximum else {
            throw PrimeNativeNeuralGateTargetFreeScheduleStreamError
                .headerByteLimitExceeded(
                    maximum: maximum,
                    observed: data.count
                )
        }
        let wire: PairStreamHeaderWire
        do {
            wire = try JSONDecoder().decode(
                PairStreamHeaderWire.self,
                from: data
            )
        } catch let error as
            PrimeNativeNeuralGateTargetFreeScheduleStreamError
        {
            throw error
        } catch {
            throw PrimeNativeNeuralGateTargetFreeScheduleStreamError
                .invalidHeader
        }
        let streamContract =
            PrimeNativeNeuralGateTargetFreeScheduleStreamContract
            .frozenV2
        guard wire.schemaVersion == 2,
              wire.artifactKind
                == "prime_stage_b_target_free_schedule_pair_stream_header_v2",
              wire.streamContractID == streamContract.contractID,
              wire.targetFreeScheduleDeliveryContractID
                == streamContract.preservedV1ContractID,
              wire.orderedSlotCount
                == streamContract.exactScheduleRowCount
        else {
            throw PrimeNativeNeuralGateTargetFreeScheduleStreamError
                .invalidHeader
        }
        let value = try Self(
            invocationRole: wire.invocationRole,
            promptSourceBindingSHA256:
                wire.promptSourceBindingSHA256,
            scheduleIdentitySHA256:
                wire.scheduleIdentitySHA256,
            rawOrderedSlotsSHA256:
                wire.rawOrderedSlotsSHA256,
            outerOrderedSlotsSHA256:
                wire.outerOrderedSlotsSHA256
        )
        guard value.rawCandidateIdentitySHA256
                == wire.rawCandidateIdentitySHA256,
              value.outerCandidateIdentitySHA256
                == wire.outerCandidateIdentitySHA256,
              value.deliveryIdentitySHA256
                == wire.deliveryIdentitySHA256
        else {
            throw PrimeNativeNeuralGateTargetFreeScheduleStreamError
                .invalidHeaderIdentity
        }
        guard try value.canonicalJSON() == data else {
            throw PrimeNativeNeuralGateTargetFreeScheduleStreamError
                .noncanonicalHeaderEncoding
        }
        return value
    }

    fileprivate enum CodingKeys: String, CodingKey, CaseIterable {
        case schemaVersion = "schema_version"
        case artifactKind = "artifact_kind"
        case streamContractID = "stream_contract_id"
        case targetFreeScheduleDeliveryContractID =
            "target_free_schedule_delivery_contract_id"
        case invocationRole = "invocation_role"
        case promptSourceBindingSHA256 =
            "prompt_source_binding_sha256"
        case scheduleIdentitySHA256 = "schedule_identity_sha256"
        case orderedSlotCount = "ordered_slot_count"
        case rawOrderedSlotsSHA256 = "raw_ordered_slots_sha256"
        case outerOrderedSlotsSHA256 = "outer_ordered_slots_sha256"
        case rawCandidateIdentitySHA256 =
            "raw_candidate_identity_sha256"
        case outerCandidateIdentitySHA256 =
            "outer_candidate_identity_sha256"
        case deliveryIdentitySHA256 = "delivery_identity_sha256"
    }
}

private struct PairStreamHeaderWire: Decodable {
    let schemaVersion: Int
    let artifactKind: String
    let streamContractID: String
    let targetFreeScheduleDeliveryContractID: String
    let invocationRole:
        PrimeNativeNeuralGateTargetFreeScheduleInvocationRole
    let promptSourceBindingSHA256: String
    let scheduleIdentitySHA256: String
    let orderedSlotCount: Int
    let rawOrderedSlotsSHA256: String
    let outerOrderedSlotsSHA256: String
    let rawCandidateIdentitySHA256: String
    let outerCandidateIdentitySHA256: String
    let deliveryIdentitySHA256: String

    init(from decoder: Decoder) throws {
        try rejectUnknownStreamHeaderKeys(from: decoder)
        let container = try decoder.container(
            keyedBy:
                PrimeNativeNeuralGateTargetFreeSchedulePairStreamHeader
                .CodingKeys.self
        )
        schemaVersion = try container.decode(
            Int.self,
            forKey: .schemaVersion
        )
        artifactKind = try container.decode(
            String.self,
            forKey: .artifactKind
        )
        streamContractID = try container.decode(
            String.self,
            forKey: .streamContractID
        )
        targetFreeScheduleDeliveryContractID = try container.decode(
            String.self,
            forKey: .targetFreeScheduleDeliveryContractID
        )
        invocationRole = try container.decode(
            PrimeNativeNeuralGateTargetFreeScheduleInvocationRole.self,
            forKey: .invocationRole
        )
        promptSourceBindingSHA256 = try container.decode(
            String.self,
            forKey: .promptSourceBindingSHA256
        )
        scheduleIdentitySHA256 = try container.decode(
            String.self,
            forKey: .scheduleIdentitySHA256
        )
        orderedSlotCount = try container.decode(
            Int.self,
            forKey: .orderedSlotCount
        )
        rawOrderedSlotsSHA256 = try container.decode(
            String.self,
            forKey: .rawOrderedSlotsSHA256
        )
        outerOrderedSlotsSHA256 = try container.decode(
            String.self,
            forKey: .outerOrderedSlotsSHA256
        )
        rawCandidateIdentitySHA256 = try container.decode(
            String.self,
            forKey: .rawCandidateIdentitySHA256
        )
        outerCandidateIdentitySHA256 = try container.decode(
            String.self,
            forKey: .outerCandidateIdentitySHA256
        )
        deliveryIdentitySHA256 = try container.decode(
            String.self,
            forKey: .deliveryIdentitySHA256
        )
    }
}

/// Bounded transport admission. This is deliberately non-Codable and carries
/// no retained source capability or process observation.
public struct PrimeNativeNeuralGateTargetFreeSchedulePairStreamAdmission:
    Equatable,
    Sendable
{
    public let streamContractID: String
    public let invocationRole:
        PrimeNativeNeuralGateTargetFreeScheduleInvocationRole
    public let promptSourceBindingSHA256: String
    public let scheduleIdentitySHA256: String
    public let orderedSlotCount: Int
    public let rawOrderedSlotsSHA256: String
    public let outerOrderedSlotsSHA256: String
    public let rawCandidateIdentitySHA256: String
    public let outerCandidateIdentitySHA256: String
    public let deliveryIdentitySHA256: String
    public let rawFramedStreamByteCount: UInt64
    public let outerFramedStreamByteCount: UInt64
    public let rawAggregateRecordByteCount: UInt64
    public let outerAggregateRecordByteCount: UInt64

    public let sourceBindingEstablished = false
    public let durableArtifactOriginEstablished = false
    public let promptContentTargetIndependenceEstablished = false
    public let processOwnershipEstablished = false
    public let processDeliveryObserved = false
    public let workerMaterialized = false
    public let modelExecutionEstablished = false
    public let evaluationPerformed = false
    public let verdictPublicationAuthorized = false
    public let publicationAuthorized = false
    public let mechanicsPassAuthorized = false
    public let terminalReceiptAuthorized = false
    public let scientificAuthorityAuthorized = false
    public let productAuthorityAuthorized = false

    fileprivate init(
        header:
            PrimeNativeNeuralGateTargetFreeSchedulePairStreamHeader,
        raw:
            PrimeNativeNeuralGateInvariantFramedStreamSummary,
        outer:
            PrimeNativeNeuralGateInvariantFramedStreamSummary
    ) {
        streamContractID = header.streamContractID
        invocationRole = header.invocationRole
        promptSourceBindingSHA256 =
            header.promptSourceBindingSHA256
        scheduleIdentitySHA256 = header.scheduleIdentitySHA256
        orderedSlotCount = header.orderedSlotCount
        rawOrderedSlotsSHA256 = header.rawOrderedSlotsSHA256
        outerOrderedSlotsSHA256 = header.outerOrderedSlotsSHA256
        rawCandidateIdentitySHA256 =
            header.rawCandidateIdentitySHA256
        outerCandidateIdentitySHA256 =
            header.outerCandidateIdentitySHA256
        deliveryIdentitySHA256 = header.deliveryIdentitySHA256
        rawFramedStreamByteCount = raw.byteCount
        outerFramedStreamByteCount = outer.byteCount
        rawAggregateRecordByteCount =
            raw.aggregateRecordByteCount
        outerAggregateRecordByteCount =
            outer.aggregateRecordByteCount
    }
}

/// One-shot decoder. Raw must reach exact EOF before outer bytes are admitted.
/// It retains only raw correlation identities needed for the independent pair
/// join; prompt text and token arrays are discarded after each slot callback.
public final class
    PrimeNativeNeuralGateTargetFreeScheduleCandidatePairStreamDecoder
{
    public let header:
        PrimeNativeNeuralGateTargetFreeSchedulePairStreamHeader
    private let expectedHeader:
        PrimeNativeNeuralGateTargetFreeSchedulePairStreamHeader

    private enum Phase: Equatable {
        case raw
        case outer
        case complete
        case failed
    }

    private var phase: Phase = .raw
    private let rawReader:
        PrimeNativeNeuralGateInvariantFramedRecordReader
    private let outerReader:
        PrimeNativeNeuralGateInvariantFramedRecordReader
    private var rawSummary:
        PrimeNativeNeuralGateInvariantFramedStreamSummary?
    private var rawObservedCount = 0
    private var outerObservedCount = 0
    private var rawIndexes = Set<UInt32>()
    private var rawCorrelations = [String]()
    private var rawCorrelationSet = Set<String>()
    private var rawPromptBindings = Set<String>()
    private var outerIndexes = Set<UInt32>()
    private var outerCorrelations = Set<String>()

    public init(
        headerJSON: Data,
        expectedHeader:
            PrimeNativeNeuralGateTargetFreeSchedulePairStreamHeader
    ) throws {
        let contract =
            PrimeNativeNeuralGateTargetFreeScheduleStreamContract
            .frozenV2
        try contract.validate()
        let prevalidatedExpectedHeader = try
            PrimeNativeNeuralGateTargetFreeSchedulePairStreamHeader
            .decodeBounded(
                from: expectedHeader.canonicalJSON()
            )
        let decodedHeader = try
            PrimeNativeNeuralGateTargetFreeSchedulePairStreamHeader
            .decodeBounded(from: headerJSON)
        guard prevalidatedExpectedHeader == expectedHeader,
              decodedHeader == expectedHeader
        else {
            throw PrimeNativeNeuralGateTargetFreeScheduleStreamError
                .expectedCandidatePairMismatch
        }
        header = decodedHeader
        self.expectedHeader = expectedHeader
        let rawLimits = try
            PrimeNativeNeuralGateReplayDecodeLimits.bounded(
                maximumRecordCount: contract.exactScheduleRowCount,
                maximumRecordByteCount:
                    contract.maximumRawSlotJSONByteCount,
                maximumAggregateRecordBytes:
                    contract.maximumRawAggregateRecordBytes
            )
        let outerLimits = try
            PrimeNativeNeuralGateReplayDecodeLimits.bounded(
                maximumRecordCount: contract.exactScheduleRowCount,
                maximumRecordByteCount:
                    contract.maximumOuterSlotJSONByteCount,
                maximumAggregateRecordBytes:
                    contract.maximumOuterAggregateRecordBytes
            )
        rawReader =
            PrimeNativeNeuralGateInvariantFramedRecordReader(
                kind: .global,
                limits: rawLimits,
                requireCanonicalOrder: false,
                requiredDeclaredRecordCount:
                    UInt64(contract.exactScheduleRowCount)
            )
        outerReader =
            PrimeNativeNeuralGateInvariantFramedRecordReader(
                kind: .global,
                limits: outerLimits,
                requireCanonicalOrder: false,
                requiredDeclaredRecordCount:
                    UInt64(contract.exactScheduleRowCount)
            )
        rawIndexes.reserveCapacity(contract.exactScheduleRowCount)
        rawCorrelations.reserveCapacity(contract.exactScheduleRowCount)
        rawCorrelationSet.reserveCapacity(contract.exactScheduleRowCount)
        rawPromptBindings.reserveCapacity(contract.exactScheduleRowCount)
        outerIndexes.reserveCapacity(contract.exactScheduleRowCount)
        outerCorrelations.reserveCapacity(contract.exactScheduleRowCount)
    }

    public convenience init(
        headerJSON: Data,
        expectedCandidatePair:
            PrimeNativeNeuralGateTargetFreeScheduleCandidatePair
    ) throws {
        try self.init(
            headerJSON: headerJSON,
            expectedHeader:
                PrimeNativeNeuralGateTargetFreeSchedulePairStreamHeader(
                    expectedCandidatePair: expectedCandidatePair
                )
        )
    }

    public func consumeRaw(_ bytes: Data) throws {
        guard phase == .raw else {
            throw PrimeNativeNeuralGateTargetFreeScheduleStreamError
                .invalidDecoderPhase
        }
        do {
            try requireBoundedFeed(bytes)
            try rawReader.consume(bytes) { [unowned self] record in
                try self.admitRaw(record)
            }
        } catch {
            phase = .failed
            throw error
        }
    }

    /// The caller must invoke this only after observing actual EOF on the
    /// bounded read-only raw descriptor.
    public func finishRawAtEOF() throws {
        guard phase == .raw else {
            throw PrimeNativeNeuralGateTargetFreeScheduleStreamError
                .invalidDecoderPhase
        }
        do {
            let summary = try rawReader.finish()
            let contract =
                PrimeNativeNeuralGateTargetFreeScheduleStreamContract
                .frozenV2
            guard summary.declaredRecordCount
                    == UInt64(contract.exactScheduleRowCount),
                  summary.observedRecordCount
                    == contract.exactScheduleRowCount,
                  summary.byteCount
                    <= UInt64(contract.maximumRawFramedStreamBytes),
                  summary.aggregateRecordByteCount
                    <= UInt64(
                        contract.maximumRawAggregateRecordBytes
                    ),
                  summary.streamSHA256
                    == header.rawOrderedSlotsSHA256
            else {
                throw PrimeNativeNeuralGateTargetFreeScheduleStreamError
                    .rawStreamIdentityMismatch
            }
            let candidate = try targetFreeCandidateIdentitySHA256(
                role: header.invocationRole,
                promptSourceBindingSHA256:
                    header.promptSourceBindingSHA256,
                scheduleIdentitySHA256:
                    header.scheduleIdentitySHA256,
                orderedSlotsSHA256: summary.streamSHA256,
                rowCount: summary.observedRecordCount,
                kind: "raw"
            )
            guard candidate == header.rawCandidateIdentitySHA256 else {
                throw PrimeNativeNeuralGateTargetFreeScheduleStreamError
                    .rawCandidateIdentityMismatch
            }
            rawSummary = summary
            rawIndexes.removeAll(keepingCapacity: false)
            rawCorrelationSet.removeAll(keepingCapacity: false)
            rawPromptBindings.removeAll(keepingCapacity: false)
            phase = .outer
        } catch {
            phase = .failed
            throw error
        }
    }

    public func consumeOuter(_ bytes: Data) throws {
        guard phase == .outer else {
            throw PrimeNativeNeuralGateTargetFreeScheduleStreamError
                .invalidDecoderPhase
        }
        do {
            try requireBoundedFeed(bytes)
            try outerReader.consume(bytes) { [unowned self] record in
                try self.admitOuter(record)
            }
        } catch {
            phase = .failed
            throw error
        }
    }

    /// The caller must invoke this only after observing actual EOF on the
    /// bounded read-only outer descriptor.
    public func finishAtEOF() throws
        -> PrimeNativeNeuralGateTargetFreeSchedulePairStreamAdmission
    {
        guard phase == .outer,
              let rawSummary
        else {
            throw PrimeNativeNeuralGateTargetFreeScheduleStreamError
                .invalidDecoderPhase
        }
        do {
            let summary = try outerReader.finish()
            let contract =
                PrimeNativeNeuralGateTargetFreeScheduleStreamContract
                .frozenV2
            guard summary.declaredRecordCount
                    == UInt64(contract.exactScheduleRowCount),
                  summary.observedRecordCount
                    == contract.exactScheduleRowCount,
                  summary.byteCount
                    <= UInt64(contract.maximumOuterFramedStreamBytes),
                  summary.aggregateRecordByteCount
                    <= UInt64(
                        contract.maximumOuterAggregateRecordBytes
                    ),
                  summary.streamSHA256
                    == header.outerOrderedSlotsSHA256
            else {
                throw PrimeNativeNeuralGateTargetFreeScheduleStreamError
                    .outerStreamIdentityMismatch
            }
            let outerCandidate = try targetFreeCandidateIdentitySHA256(
                role: header.invocationRole,
                promptSourceBindingSHA256:
                    header.promptSourceBindingSHA256,
                scheduleIdentitySHA256:
                    header.scheduleIdentitySHA256,
                orderedSlotsSHA256: summary.streamSHA256,
                rowCount: summary.observedRecordCount,
                kind: "outer"
            )
            guard outerCandidate
                    == header.outerCandidateIdentitySHA256
            else {
                throw PrimeNativeNeuralGateTargetFreeScheduleStreamError
                    .outerCandidateIdentityMismatch
            }
            let delivery = try targetFreeDeliveryIdentitySHA256(
                role: header.invocationRole,
                promptSourceBindingSHA256:
                    header.promptSourceBindingSHA256,
                scheduleIdentitySHA256:
                    header.scheduleIdentitySHA256,
                rawCandidateIdentitySHA256:
                    header.rawCandidateIdentitySHA256,
                outerCandidateIdentitySHA256: outerCandidate,
                rowCount: summary.observedRecordCount
            )
            guard delivery == header.deliveryIdentitySHA256 else {
                throw PrimeNativeNeuralGateTargetFreeScheduleStreamError
                    .deliveryIdentityMismatch
            }
            guard expectedHeader == header else {
                throw PrimeNativeNeuralGateTargetFreeScheduleStreamError
                    .expectedCandidatePairMismatch
            }
            let admission =
                PrimeNativeNeuralGateTargetFreeSchedulePairStreamAdmission(
                    header: header,
                    raw: rawSummary,
                    outer: summary
                )
            rawCorrelations.removeAll(keepingCapacity: false)
            outerIndexes.removeAll(keepingCapacity: false)
            outerCorrelations.removeAll(keepingCapacity: false)
            phase = .complete
            return admission
        } catch {
            phase = .failed
            throw error
        }
    }

    private func admitRaw(_ record: Data) throws {
        let slot = try
            PrimeNativeNeuralGateTargetFreeRawScheduleSlot
            .decodeBounded(from: record)
        guard rawIndexes.insert(slot.executionIndex).inserted else {
            throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
                .duplicateExecutionIndex(slot.executionIndex)
        }
        let expected = UInt32(rawObservedCount)
        guard slot.executionIndex == expected else {
            throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
                .noncanonicalExecutionOrder(
                    position: rawObservedCount,
                    expected: expected,
                    observed: slot.executionIndex
                )
        }
        guard rawCorrelationSet.insert(slot.correlationID).inserted
        else {
            throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
                .duplicateCorrelationID(slot.correlationID)
        }
        guard rawPromptBindings.insert(
            slot.primeCPI2PromptBindingSHA256
        ).inserted else {
            throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
                .duplicatePromptBinding(
                    slot.primeCPI2PromptBindingSHA256
                )
        }
        rawCorrelations.append(slot.correlationID)
        rawObservedCount += 1
    }

    private func admitOuter(_ record: Data) throws {
        let slot = try
            PrimeNativeNeuralGateTargetFreeOuterScheduleSlot
            .decodeBounded(from: record)
        guard outerIndexes.insert(slot.executionIndex).inserted else {
            throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
                .duplicateExecutionIndex(slot.executionIndex)
        }
        let expected = UInt32(outerObservedCount)
        guard slot.executionIndex == expected else {
            throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
                .noncanonicalExecutionOrder(
                    position: outerObservedCount,
                    expected: expected,
                    observed: slot.executionIndex
                )
        }
        guard outerCorrelations.insert(slot.correlationID).inserted
        else {
            throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
                .duplicateCorrelationID(slot.correlationID)
        }
        guard outerObservedCount < rawCorrelations.count,
              rawCorrelations[outerObservedCount]
                == slot.correlationID
        else {
            throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
                .pairedScheduleCorrelationMismatch(
                    executionIndex: slot.executionIndex
                )
        }
        outerObservedCount += 1
    }

    private func requireBoundedFeed(_ bytes: Data) throws {
        let maximum =
            PrimeNativeNeuralGateTargetFreeScheduleStreamContract
            .frozenV2.maximumDescriptorFeedByteCount
        guard bytes.count <= maximum else {
            throw PrimeNativeNeuralGateTargetFreeScheduleStreamError
                .feedByteLimitExceeded(
                    maximum: maximum,
                    observed: bytes.count
                )
        }
    }
}

private struct StreamHeaderAnyCodingKey: CodingKey {
    let stringValue: String
    let intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
        intValue = nil
    }

    init?(intValue: Int) {
        stringValue = String(intValue)
        self.intValue = intValue
    }
}

private func rejectUnknownStreamHeaderKeys(
    from decoder: Decoder
) throws {
    let dynamic = try decoder.container(
        keyedBy: StreamHeaderAnyCodingKey.self
    )
    let admitted = Set(
        PrimeNativeNeuralGateTargetFreeSchedulePairStreamHeader
        .CodingKeys.allCases.map(\.rawValue)
    )
    let unknown = dynamic.allKeys
        .map(\.stringValue)
        .filter { !admitted.contains($0) }
        .sorted()
    guard unknown.isEmpty else {
        throw PrimeNativeNeuralGateTargetFreeScheduleStreamError
            .unexpectedHeaderKeys(unknown)
    }
}

private func canonicalStreamJSON<Value: Encodable>(
    _ value: Value
) throws -> Data {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
    do {
        return try encoder.encode(value)
    } catch {
        throw PrimeNativeNeuralGateTargetFreeScheduleStreamError
            .invalidHeader
    }
}

private func isLowercaseStreamSHA256(_ value: String) -> Bool {
    value.utf8.count == 64
        && value.utf8.allSatisfy {
            ($0 >= 48 && $0 <= 57)
                || ($0 >= 97 && $0 <= 102)
        }
}
