import Foundation
import PrimeNativeNeuralGateCorrectedMechanics
import PrimeNativeNeuralGateReplayArtifactContracts
import PrimeNativeNeuralGateReplayMechanics

public enum PrimeNativeNeuralGateTargetFreeScheduleDeliveryError:
    Error,
    Equatable,
    Sendable
{
    case invalidFrozenContract
    case unexpectedCodingKeys([String])
    case encodedSlotByteLimitExceeded(
        maximum: Int,
        observed: Int
    )
    case noncanonicalSlotEncoding
    case invalidExecutionIndex(UInt32)
    case invalidCanonicalPrompt
    case promptTokenMismatch
    case promptBindingMismatch
    case invalidCorrelationID
    case correlationMismatch
    case invalidPromptSourceBindingSHA256
    case invalidScheduleIdentitySHA256
    case invalidOrderedSlotsSHA256
    case invalidCandidateIdentitySHA256
    case invalidDeliveryIdentitySHA256
    case emptySchedule
    case candidateCardinalityExceeded(
        maximum: Int,
        observed: Int
    )
    case duplicateExecutionIndex(UInt32)
    case duplicateCorrelationID(String)
    case duplicatePromptBinding(String)
    case noncanonicalExecutionOrder(
        position: Int,
        expected: UInt32,
        observed: UInt32
    )
    case invocationRoleMismatch
    case pairedPromptSourceBindingMismatch
    case pairedScheduleIdentityMismatch
    case pairedScheduleCorrelationMismatch(
        executionIndex: UInt32
    )
    case exactCardinalityRequired(
        expected: Int,
        rawObserved: Int,
        outerObserved: Int
    )
    case canonicalEncodingRejected
}

/// The two future invocation domains are independent of PrimeCore's
/// historical worker enums. This value assigns no process and records no
/// invocation.
public enum PrimeNativeNeuralGateTargetFreeScheduleInvocationRole:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Sendable
{
    case probe
    case verifier
}

/// Scalar observation of a retained descriptor-root identity. It cannot open
/// a path, retain a descriptor, or reconstruct the capability that produced
/// it.
public struct PrimeNativeNeuralGateTargetFreeSourceRootIdentity:
    Encodable,
    Equatable,
    Sendable
{
    public let deviceID: UInt64
    public let inode: UInt64
    public let ownerUserID: UInt32
    public let ownerGroupID: UInt32
    public let actualMode: UInt16
    public let linkCount: UInt64
    public let modificationSeconds: Int64
    public let modificationNanoseconds: Int64
    public let statusChangeSeconds: Int64
    public let statusChangeNanoseconds: Int64

    public init(
        deviceID: UInt64,
        inode: UInt64,
        ownerUserID: UInt32,
        ownerGroupID: UInt32,
        actualMode: UInt16,
        linkCount: UInt64,
        modificationSeconds: Int64,
        modificationNanoseconds: Int64,
        statusChangeSeconds: Int64,
        statusChangeNanoseconds: Int64
    ) {
        self.deviceID = deviceID
        self.inode = inode
        self.ownerUserID = ownerUserID
        self.ownerGroupID = ownerGroupID
        self.actualMode = actualMode
        self.linkCount = linkCount
        self.modificationSeconds = modificationSeconds
        self.modificationNanoseconds = modificationNanoseconds
        self.statusChangeSeconds = statusChangeSeconds
        self.statusChangeNanoseconds = statusChangeNanoseconds
    }

    private enum CodingKeys: String, CodingKey {
        case deviceID = "device_id"
        case inode
        case ownerUserID = "owner_user_id"
        case ownerGroupID = "owner_group_id"
        case actualMode = "actual_mode"
        case linkCount = "link_count"
        case modificationSeconds = "modification_seconds"
        case modificationNanoseconds = "modification_nanoseconds"
        case statusChangeSeconds = "status_change_seconds"
        case statusChangeNanoseconds = "status_change_nanoseconds"
    }
}

/// Frozen, non-authorizing construction and encoding contract for a
/// target-free schedule candidate.
///
/// Individual slot decoding is byte-capped before JSON allocation. Candidate
/// and pair values deliberately remain Encodable-only until a bounded stream
/// decoder and retained-capture delivery authority exist. Candidate hashes
/// bind the exact encoded slot content and copied source references, but the
/// source references themselves are not authority.
public struct PrimeNativeNeuralGateTargetFreeScheduleDeliveryContract:
    Encodable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let contractID: String
    public let artifactOutputContractID: String
    public let correctedExecutionPolicyID: String
    public let correlationIdentityMagic: String
    public let correlationIdentitySerializationID: String
    public let slotStreamIdentityMagic: String
    public let candidateIdentityMagic: String
    public let deliveryIdentityMagic: String
    public let admittedInvocationRoles:
        [PrimeNativeNeuralGateTargetFreeScheduleInvocationRole]
    public let rawSlotWireFieldAllowlist: [String]
    public let outerSlotWireFieldAllowlist: [String]
    public let rawCandidateWireFieldAllowlist: [String]
    public let outerCandidateWireFieldAllowlist: [String]
    public let pairWireFieldAllowlist: [String]
    public let maximumRawSlotJSONByteCount: Int
    public let maximumOuterSlotJSONByteCount: Int
    public let maximumCandidateRowCount: Int
    public let exactScheduleRowCount: Int
    public let strictSlotUnknownKeyRejectionImplemented: Bool
    public let boundedSlotDecodingImplemented: Bool
    public let boundedCandidateDecodingImplemented: Bool
    public let maintainedPromptDerivationValidationImplemented: Bool
    public let primeCOR1RecomputationImplemented: Bool
    public let orderedUniqueCandidateValidationImplemented: Bool
    public let candidateContentBindingImplemented: Bool
    public let sourceScheduleReferenceIncluded: Bool
    public let sourceScheduleIdentityBindingImplemented: Bool

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
    public let authorityStatement: String

    public static let frozenV1 = Self(
        schemaVersion: 1,
        contractID:
            "prime_stage_b_target_free_schedule_delivery_contract_v1",
        artifactOutputContractID:
            PrimeNativeNeuralGateReplayArtifactOutputContract
            .frozenV4.contractID,
        correctedExecutionPolicyID:
            PrimeNativeNeuralGateCorrectedExecutionPolicy.policyID,
        correlationIdentityMagic: "PRIMECOR1",
        correlationIdentitySerializationID:
            PrimeNativeNeuralGateReplayCorrelationIdentity
            .serializationContractID,
        slotStreamIdentityMagic: "PRIMEIRM1",
        candidateIdentityMagic: "PRIMETFC1",
        deliveryIdentityMagic: "PRIMETFD1",
        admittedInvocationRoles: [.probe, .verifier],
        rawSlotWireFieldAllowlist: [
            "canonical_prompt",
            "correlation_id",
            "execution_index",
            "primecpi2_prompt_binding_sha256",
            "prompt_token_ids",
        ],
        outerSlotWireFieldAllowlist: [
            "correlation_id",
            "execution_index",
        ],
        rawCandidateWireFieldAllowlist: [
            "candidate_identity_sha256",
            "invocation_role",
            "ordered_slots",
            "ordered_slots_sha256",
            "prompt_source_binding_sha256",
            "schedule_identity_sha256",
        ],
        outerCandidateWireFieldAllowlist: [
            "candidate_identity_sha256",
            "invocation_role",
            "ordered_slots",
            "ordered_slots_sha256",
            "prompt_source_binding_sha256",
            "schedule_identity_sha256",
        ],
        pairWireFieldAllowlist: [
            "delivery_identity_sha256",
            "outer_schedule",
            "raw_schedule",
        ],
        maximumRawSlotJSONByteCount: 16_384,
        maximumOuterSlotJSONByteCount: 1_024,
        maximumCandidateRowCount: 18_432,
        exactScheduleRowCount: 18_432,
        strictSlotUnknownKeyRejectionImplemented: true,
        boundedSlotDecodingImplemented: true,
        boundedCandidateDecodingImplemented: false,
        maintainedPromptDerivationValidationImplemented: true,
        primeCOR1RecomputationImplemented: true,
        orderedUniqueCandidateValidationImplemented: true,
        candidateContentBindingImplemented: true,
        sourceScheduleReferenceIncluded: true,
        sourceScheduleIdentityBindingImplemented: false,
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
        productAuthorityAuthorized: false,
        authorityStatement:
            "This V1 contract defines exact target-free slot encoding, byte-capped strict slot decoding, ordered candidate validation, and self-derived PRIMEIRM1/PRIMETFC1/PRIMETFD1 content identities. Candidate and pair decoding remains unavailable until a bounded stream decoder exists. Copied prompt-source and PRIMESCH1 values remain non-authoritative references: retained-capture binding, role-scoped process ownership, and process delivery are not established by this target. No worker is materialized; no model executes; no evaluation, verdict, PASS, receipt, scientific claim, or product authority is created."
    )

    public func validate() throws {
        guard self == .frozenV1,
              schemaVersion == 1,
              artifactOutputContractID
                == PrimeNativeNeuralGateReplayArtifactOutputContract
                .frozenV4.contractID,
              correctedExecutionPolicyID
                == PrimeNativeNeuralGateCorrectedExecutionPolicy.policyID,
              correlationIdentityMagic == "PRIMECOR1",
              correlationIdentitySerializationID
                == PrimeNativeNeuralGateReplayCorrelationIdentity
                .serializationContractID,
              slotStreamIdentityMagic == "PRIMEIRM1",
              candidateIdentityMagic == "PRIMETFC1",
              deliveryIdentityMagic == "PRIMETFD1",
              admittedInvocationRoles == [.probe, .verifier],
              rawSlotWireFieldAllowlist == [
                  "canonical_prompt",
                  "correlation_id",
                  "execution_index",
                  "primecpi2_prompt_binding_sha256",
                  "prompt_token_ids",
              ],
              outerSlotWireFieldAllowlist == [
                  "correlation_id",
                  "execution_index",
              ],
              maximumRawSlotJSONByteCount == 16_384,
              maximumOuterSlotJSONByteCount == 1_024,
              maximumCandidateRowCount == 18_432,
              exactScheduleRowCount == 18_432,
              strictSlotUnknownKeyRejectionImplemented,
              boundedSlotDecodingImplemented,
              !boundedCandidateDecodingImplemented,
              maintainedPromptDerivationValidationImplemented,
              primeCOR1RecomputationImplemented,
              orderedUniqueCandidateValidationImplemented,
              candidateContentBindingImplemented,
              sourceScheduleReferenceIncluded,
              !sourceScheduleIdentityBindingImplemented,
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
            throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
                .invalidFrozenContract
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case contractID = "contract_id"
        case artifactOutputContractID = "artifact_output_contract_id"
        case correctedExecutionPolicyID = "corrected_execution_policy_id"
        case correlationIdentityMagic = "correlation_identity_magic"
        case correlationIdentitySerializationID =
            "correlation_identity_serialization_id"
        case slotStreamIdentityMagic = "slot_stream_identity_magic"
        case candidateIdentityMagic = "candidate_identity_magic"
        case deliveryIdentityMagic = "delivery_identity_magic"
        case admittedInvocationRoles = "admitted_invocation_roles"
        case rawSlotWireFieldAllowlist = "raw_slot_wire_field_allowlist"
        case outerSlotWireFieldAllowlist = "outer_slot_wire_field_allowlist"
        case rawCandidateWireFieldAllowlist =
            "raw_candidate_wire_field_allowlist"
        case outerCandidateWireFieldAllowlist =
            "outer_candidate_wire_field_allowlist"
        case pairWireFieldAllowlist = "pair_wire_field_allowlist"
        case maximumRawSlotJSONByteCount =
            "maximum_raw_slot_json_byte_count"
        case maximumOuterSlotJSONByteCount =
            "maximum_outer_slot_json_byte_count"
        case maximumCandidateRowCount = "maximum_candidate_row_count"
        case exactScheduleRowCount = "exact_schedule_row_count"
        case strictSlotUnknownKeyRejectionImplemented =
            "strict_slot_unknown_key_rejection_implemented"
        case boundedSlotDecodingImplemented =
            "bounded_slot_decoding_implemented"
        case boundedCandidateDecodingImplemented =
            "bounded_candidate_decoding_implemented"
        case maintainedPromptDerivationValidationImplemented =
            "maintained_prompt_derivation_validation_implemented"
        case primeCOR1RecomputationImplemented =
            "primecor1_recomputation_implemented"
        case orderedUniqueCandidateValidationImplemented =
            "ordered_unique_candidate_validation_implemented"
        case candidateContentBindingImplemented =
            "candidate_content_binding_implemented"
        case sourceScheduleReferenceIncluded =
            "source_schedule_reference_included"
        case sourceScheduleIdentityBindingImplemented =
            "source_schedule_identity_binding_implemented"
        case sourceBindingEstablished = "source_binding_established"
        case durableArtifactOriginEstablished =
            "durable_artifact_origin_established"
        case promptContentTargetIndependenceEstablished =
            "prompt_content_target_independence_established"
        case processOwnershipEstablished = "process_ownership_established"
        case processDeliveryObserved = "process_delivery_observed"
        case workerMaterialized = "worker_materialized"
        case modelExecutionEstablished = "model_execution_established"
        case evaluationPerformed = "evaluation_performed"
        case verdictPublicationAuthorized = "verdict_publication_authorized"
        case publicationAuthorized = "publication_authorized"
        case mechanicsPassAuthorized = "mechanics_pass_authorized"
        case terminalReceiptAuthorized = "terminal_receipt_authorized"
        case scientificAuthorityAuthorized =
            "scientific_authority_authorized"
        case productAuthorityAuthorized = "product_authority_authorized"
        case authorityStatement = "authority_statement"
    }
}

/// Exact prompt-bearing material admitted to a future corrected raw worker.
/// Target, row, split/family, regrade, caller-budget, and termination material
/// cannot be represented.
public struct PrimeNativeNeuralGateTargetFreeRawScheduleSlot:
    Encodable,
    Equatable,
    Sendable
{
    public let executionIndex: UInt32
    public let promptTokenIDs: [UInt16]
    public let canonicalPrompt: String
    public let primeCPI2PromptBindingSHA256: String
    public let correlationID: String

    public let processDeliveryObserved = false
    public let promptContentTargetIndependenceEstablished = false
    public let modelExecutionEstablished = false
    public let mechanicsPassAuthorized = false

    public init(
        executionIndex: UInt32,
        promptTokenIDs: [UInt16],
        canonicalPrompt: String,
        primeCPI2PromptBindingSHA256: String,
        correlationID: String
    ) throws {
        guard executionIndex
                < UInt32(
                    PrimeNativeNeuralGateTargetFreeScheduleDeliveryContract
                    .frozenV1.maximumCandidateRowCount
                )
        else {
            throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
                .invalidExecutionIndex(executionIndex)
        }
        let input: PrimeNativeNeuralGatePromptOnlyExecutionInput
        do {
            input = try PrimeNativeNeuralGatePromptOnlyExecutionInput
                .derive(promptText: canonicalPrompt)
            guard Array(try input.decodedCanonicalPrompt().utf8)
                    == Array(canonicalPrompt.utf8)
            else {
                throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
                    .invalidCanonicalPrompt
            }
        } catch let error as
            PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
        {
            throw error
        } catch {
            throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
                .invalidCanonicalPrompt
        }
        guard Self.exactUInt16(input.promptTokenIDs) == promptTokenIDs
        else {
            throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
                .promptTokenMismatch
        }
        guard input.bindingSHA256 == primeCPI2PromptBindingSHA256
        else {
            throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
                .promptBindingMismatch
        }
        let expected: String
        do {
            expected = try PrimeNativeNeuralGateReplayCorrelationIdentity
                .derive(
                    executionIndex: executionIndex,
                    primeCPI2PromptBindingSHA256:
                        primeCPI2PromptBindingSHA256
                )
        } catch {
            throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
                .promptBindingMismatch
        }
        guard correlationID == expected else {
            throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
                .correlationMismatch
        }
        self.executionIndex = executionIndex
        self.promptTokenIDs = promptTokenIDs
        self.canonicalPrompt = canonicalPrompt
        self.primeCPI2PromptBindingSHA256 =
            primeCPI2PromptBindingSHA256
        self.correlationID = correlationID
    }

    public func validate() throws {
        _ = try Self(
            executionIndex: executionIndex,
            promptTokenIDs: promptTokenIDs,
            canonicalPrompt: canonicalPrompt,
            primeCPI2PromptBindingSHA256:
                primeCPI2PromptBindingSHA256,
            correlationID: correlationID
        )
    }

    public static func decodeBounded(
        from data: Data
    ) throws -> Self {
        let maximum =
            PrimeNativeNeuralGateTargetFreeScheduleDeliveryContract
            .frozenV1.maximumRawSlotJSONByteCount
        guard data.count <= maximum else {
            throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
                .encodedSlotByteLimitExceeded(
                    maximum: maximum,
                    observed: data.count
                )
        }
        let wire = try JSONDecoder().decode(
            PrimeNativeNeuralGateTargetFreeRawScheduleSlotWire.self,
            from: data
        )
        let value = try Self(
            executionIndex: wire.executionIndex,
            promptTokenIDs: wire.promptTokenIDs,
            canonicalPrompt: wire.canonicalPrompt,
            primeCPI2PromptBindingSHA256:
                wire.primeCPI2PromptBindingSHA256,
            correlationID: wire.correlationID
        )
        guard try value.canonicalJSON() == data else {
            throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
                .noncanonicalSlotEncoding
        }
        return value
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(executionIndex, forKey: .executionIndex)
        try container.encode(promptTokenIDs, forKey: .promptTokenIDs)
        try container.encode(canonicalPrompt, forKey: .canonicalPrompt)
        try container.encode(
            primeCPI2PromptBindingSHA256,
            forKey: .primeCPI2PromptBindingSHA256
        )
        try container.encode(correlationID, forKey: .correlationID)
    }

    fileprivate func canonicalJSON() throws -> Data {
        try canonicalTargetFreeScheduleJSON(self)
    }

    private static func exactUInt16(_ values: [Int]) -> [UInt16]? {
        var result = [UInt16]()
        result.reserveCapacity(values.count)
        for value in values {
            guard let exact = UInt16(exactly: value) else {
                return nil
            }
            result.append(exact)
        }
        return result
    }

    fileprivate enum CodingKeys: String, CodingKey, CaseIterable {
        case executionIndex = "execution_index"
        case promptTokenIDs = "prompt_token_ids"
        case canonicalPrompt = "canonical_prompt"
        case primeCPI2PromptBindingSHA256 =
            "primecpi2_prompt_binding_sha256"
        case correlationID = "correlation_id"
    }
}

private struct PrimeNativeNeuralGateTargetFreeRawScheduleSlotWire:
    Decodable
{
    let executionIndex: UInt32
    let promptTokenIDs: [UInt16]
    let canonicalPrompt: String
    let primeCPI2PromptBindingSHA256: String
    let correlationID: String

    init(from decoder: Decoder) throws {
        try rejectUnknownTargetFreeScheduleKeys(
            from: decoder,
            admittedBy:
                PrimeNativeNeuralGateTargetFreeRawScheduleSlot
                .CodingKeys.self
        )
        let container = try decoder.container(
            keyedBy:
                PrimeNativeNeuralGateTargetFreeRawScheduleSlot
                .CodingKeys.self
        )
        executionIndex = try container.decode(
            UInt32.self,
            forKey: .executionIndex
        )
        promptTokenIDs = try container.decode(
            [UInt16].self,
            forKey: .promptTokenIDs
        )
        canonicalPrompt = try container.decode(
            String.self,
            forKey: .canonicalPrompt
        )
        primeCPI2PromptBindingSHA256 = try container.decode(
            String.self,
            forKey: .primeCPI2PromptBindingSHA256
        )
        correlationID = try container.decode(
            String.self,
            forKey: .correlationID
        )
    }
}

/// Index/correlation-only material admitted to a future outer worker.
public struct PrimeNativeNeuralGateTargetFreeOuterScheduleSlot:
    Encodable,
    Equatable,
    Sendable
{
    public let executionIndex: UInt32
    public let correlationID: String

    public let processDeliveryObserved = false
    public let evaluationPerformed = false
    public let mechanicsPassAuthorized = false

    public init(
        executionIndex: UInt32,
        correlationID: String
    ) throws {
        guard executionIndex
                < UInt32(
                    PrimeNativeNeuralGateTargetFreeScheduleDeliveryContract
                    .frozenV1.maximumCandidateRowCount
                )
        else {
            throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
                .invalidExecutionIndex(executionIndex)
        }
        guard isLowercaseTargetFreeScheduleSHA256(correlationID) else {
            throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
                .invalidCorrelationID
        }
        self.executionIndex = executionIndex
        self.correlationID = correlationID
    }

    public func validate() throws {
        _ = try Self(
            executionIndex: executionIndex,
            correlationID: correlationID
        )
    }

    public static func decodeBounded(
        from data: Data
    ) throws -> Self {
        let maximum =
            PrimeNativeNeuralGateTargetFreeScheduleDeliveryContract
            .frozenV1.maximumOuterSlotJSONByteCount
        guard data.count <= maximum else {
            throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
                .encodedSlotByteLimitExceeded(
                    maximum: maximum,
                    observed: data.count
                )
        }
        let wire = try JSONDecoder().decode(
            PrimeNativeNeuralGateTargetFreeOuterScheduleSlotWire.self,
            from: data
        )
        let value = try Self(
            executionIndex: wire.executionIndex,
            correlationID: wire.correlationID
        )
        guard try value.canonicalJSON() == data else {
            throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
                .noncanonicalSlotEncoding
        }
        return value
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(executionIndex, forKey: .executionIndex)
        try container.encode(correlationID, forKey: .correlationID)
    }

    fileprivate func canonicalJSON() throws -> Data {
        try canonicalTargetFreeScheduleJSON(self)
    }

    fileprivate enum CodingKeys: String, CodingKey, CaseIterable {
        case executionIndex = "execution_index"
        case correlationID = "correlation_id"
    }
}

private struct PrimeNativeNeuralGateTargetFreeOuterScheduleSlotWire:
    Decodable
{
    let executionIndex: UInt32
    let correlationID: String

    init(from decoder: Decoder) throws {
        try rejectUnknownTargetFreeScheduleKeys(
            from: decoder,
            admittedBy:
                PrimeNativeNeuralGateTargetFreeOuterScheduleSlot
                .CodingKeys.self
        )
        let container = try decoder.container(
            keyedBy:
                PrimeNativeNeuralGateTargetFreeOuterScheduleSlot
                .CodingKeys.self
        )
        executionIndex = try container.decode(
            UInt32.self,
            forKey: .executionIndex
        )
        correlationID = try container.decode(
            String.self,
            forKey: .correlationID
        )
    }
}

/// Construct-only raw schedule. It cannot be decoded directly from an
/// untrusted aggregate JSON allocation.
public struct PrimeNativeNeuralGateTargetFreeRawScheduleCandidate:
    Encodable,
    Equatable,
    Sendable
{
    public let invocationRole:
        PrimeNativeNeuralGateTargetFreeScheduleInvocationRole
    public let promptSourceBindingSHA256: String
    public let scheduleIdentitySHA256: String
    public let orderedSlotsSHA256: String
    public let candidateIdentitySHA256: String
    public let orderedSlots:
        [PrimeNativeNeuralGateTargetFreeRawScheduleSlot]

    public let sourceBindingEstablished = false
    public let processOwnershipEstablished = false
    public let processDeliveryObserved = false
    public let workerMaterialized = false
    public let modelExecutionEstablished = false
    public let mechanicsPassAuthorized = false

    public init(
        invocationRole:
            PrimeNativeNeuralGateTargetFreeScheduleInvocationRole,
        promptSourceBindingSHA256: String,
        scheduleIdentitySHA256: String,
        orderedSlots:
            [PrimeNativeNeuralGateTargetFreeRawScheduleSlot]
    ) throws {
        try validateTargetFreeScheduleReference(
            promptSourceBindingSHA256: promptSourceBindingSHA256,
            scheduleIdentitySHA256: scheduleIdentitySHA256
        )
        try Self.validateSlots(orderedSlots)
        let slotsIdentity = try targetFreeRawSlotStreamSHA256(orderedSlots)
        let candidateIdentity = try targetFreeCandidateIdentitySHA256(
            role: invocationRole,
            promptSourceBindingSHA256: promptSourceBindingSHA256,
            scheduleIdentitySHA256: scheduleIdentitySHA256,
            orderedSlotsSHA256: slotsIdentity,
            rowCount: orderedSlots.count,
            kind: "raw"
        )
        self.invocationRole = invocationRole
        self.promptSourceBindingSHA256 = promptSourceBindingSHA256
        self.scheduleIdentitySHA256 = scheduleIdentitySHA256
        orderedSlotsSHA256 = slotsIdentity
        candidateIdentitySHA256 = candidateIdentity
        self.orderedSlots = orderedSlots
    }

    public func validate() throws {
        try validateTargetFreeScheduleReference(
            promptSourceBindingSHA256: promptSourceBindingSHA256,
            scheduleIdentitySHA256: scheduleIdentitySHA256
        )
        try Self.validateSlots(orderedSlots)
        let slotsIdentity = try targetFreeRawSlotStreamSHA256(orderedSlots)
        guard orderedSlotsSHA256 == slotsIdentity else {
            throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
                .invalidOrderedSlotsSHA256
        }
        guard candidateIdentitySHA256 == (try targetFreeCandidateIdentitySHA256(
            role: invocationRole,
            promptSourceBindingSHA256: promptSourceBindingSHA256,
            scheduleIdentitySHA256: scheduleIdentitySHA256,
            orderedSlotsSHA256: slotsIdentity,
            rowCount: orderedSlots.count,
            kind: "raw"
        )) else {
            throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
                .invalidCandidateIdentitySHA256
        }
    }

    private static func validateSlots(
        _ slots: [PrimeNativeNeuralGateTargetFreeRawScheduleSlot]
    ) throws {
        let maximum =
            PrimeNativeNeuralGateTargetFreeScheduleDeliveryContract
            .frozenV1.maximumCandidateRowCount
        guard !slots.isEmpty else {
            throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
                .emptySchedule
        }
        guard slots.count <= maximum else {
            throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
                .candidateCardinalityExceeded(
                    maximum: maximum,
                    observed: slots.count
                )
        }
        var indexes = Set<UInt32>()
        var correlations = Set<String>()
        var promptBindings = Set<String>()
        for (position, slot) in slots.enumerated() {
            try slot.validate()
            guard indexes.insert(slot.executionIndex).inserted else {
                throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
                    .duplicateExecutionIndex(slot.executionIndex)
            }
            guard correlations.insert(slot.correlationID).inserted else {
                throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
                    .duplicateCorrelationID(slot.correlationID)
            }
            guard promptBindings.insert(
                slot.primeCPI2PromptBindingSHA256
            ).inserted else {
                throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
                    .duplicatePromptBinding(
                        slot.primeCPI2PromptBindingSHA256
                    )
            }
            let expected = UInt32(position)
            guard slot.executionIndex == expected else {
                throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
                    .noncanonicalExecutionOrder(
                        position: position,
                        expected: expected,
                        observed: slot.executionIndex
                    )
            }
        }
    }

    private enum CodingKeys: String, CodingKey {
        case invocationRole = "invocation_role"
        case promptSourceBindingSHA256 =
            "prompt_source_binding_sha256"
        case scheduleIdentitySHA256 = "schedule_identity_sha256"
        case orderedSlotsSHA256 = "ordered_slots_sha256"
        case candidateIdentitySHA256 = "candidate_identity_sha256"
        case orderedSlots = "ordered_slots"
    }
}

/// Construct-only outer schedule. It contains no prompt or target material.
public struct PrimeNativeNeuralGateTargetFreeOuterScheduleCandidate:
    Encodable,
    Equatable,
    Sendable
{
    public let invocationRole:
        PrimeNativeNeuralGateTargetFreeScheduleInvocationRole
    public let promptSourceBindingSHA256: String
    public let scheduleIdentitySHA256: String
    public let orderedSlotsSHA256: String
    public let candidateIdentitySHA256: String
    public let orderedSlots:
        [PrimeNativeNeuralGateTargetFreeOuterScheduleSlot]

    public let sourceBindingEstablished = false
    public let processOwnershipEstablished = false
    public let processDeliveryObserved = false
    public let evaluationPerformed = false
    public let mechanicsPassAuthorized = false

    public init(
        invocationRole:
            PrimeNativeNeuralGateTargetFreeScheduleInvocationRole,
        promptSourceBindingSHA256: String,
        scheduleIdentitySHA256: String,
        orderedSlots:
            [PrimeNativeNeuralGateTargetFreeOuterScheduleSlot]
    ) throws {
        try validateTargetFreeScheduleReference(
            promptSourceBindingSHA256: promptSourceBindingSHA256,
            scheduleIdentitySHA256: scheduleIdentitySHA256
        )
        try Self.validateSlots(orderedSlots)
        let slotsIdentity = try targetFreeOuterSlotStreamSHA256(orderedSlots)
        let candidateIdentity = try targetFreeCandidateIdentitySHA256(
            role: invocationRole,
            promptSourceBindingSHA256: promptSourceBindingSHA256,
            scheduleIdentitySHA256: scheduleIdentitySHA256,
            orderedSlotsSHA256: slotsIdentity,
            rowCount: orderedSlots.count,
            kind: "outer"
        )
        self.invocationRole = invocationRole
        self.promptSourceBindingSHA256 = promptSourceBindingSHA256
        self.scheduleIdentitySHA256 = scheduleIdentitySHA256
        orderedSlotsSHA256 = slotsIdentity
        candidateIdentitySHA256 = candidateIdentity
        self.orderedSlots = orderedSlots
    }

    public func validate() throws {
        try validateTargetFreeScheduleReference(
            promptSourceBindingSHA256: promptSourceBindingSHA256,
            scheduleIdentitySHA256: scheduleIdentitySHA256
        )
        try Self.validateSlots(orderedSlots)
        let slotsIdentity = try targetFreeOuterSlotStreamSHA256(orderedSlots)
        guard orderedSlotsSHA256 == slotsIdentity else {
            throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
                .invalidOrderedSlotsSHA256
        }
        guard candidateIdentitySHA256 == (try targetFreeCandidateIdentitySHA256(
            role: invocationRole,
            promptSourceBindingSHA256: promptSourceBindingSHA256,
            scheduleIdentitySHA256: scheduleIdentitySHA256,
            orderedSlotsSHA256: slotsIdentity,
            rowCount: orderedSlots.count,
            kind: "outer"
        )) else {
            throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
                .invalidCandidateIdentitySHA256
        }
    }

    private static func validateSlots(
        _ slots: [PrimeNativeNeuralGateTargetFreeOuterScheduleSlot]
    ) throws {
        let maximum =
            PrimeNativeNeuralGateTargetFreeScheduleDeliveryContract
            .frozenV1.maximumCandidateRowCount
        guard !slots.isEmpty else {
            throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
                .emptySchedule
        }
        guard slots.count <= maximum else {
            throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
                .candidateCardinalityExceeded(
                    maximum: maximum,
                    observed: slots.count
                )
        }
        var indexes = Set<UInt32>()
        var correlations = Set<String>()
        for (position, slot) in slots.enumerated() {
            try slot.validate()
            guard indexes.insert(slot.executionIndex).inserted else {
                throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
                    .duplicateExecutionIndex(slot.executionIndex)
            }
            guard correlations.insert(slot.correlationID).inserted else {
                throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
                    .duplicateCorrelationID(slot.correlationID)
            }
            let expected = UInt32(position)
            guard slot.executionIndex == expected else {
                throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
                    .noncanonicalExecutionOrder(
                        position: position,
                        expected: expected,
                        observed: slot.executionIndex
                    )
            }
        }
    }

    private enum CodingKeys: String, CodingKey {
        case invocationRole = "invocation_role"
        case promptSourceBindingSHA256 =
            "prompt_source_binding_sha256"
        case scheduleIdentitySHA256 = "schedule_identity_sha256"
        case orderedSlotsSHA256 = "ordered_slots_sha256"
        case candidateIdentitySHA256 = "candidate_identity_sha256"
        case orderedSlots = "ordered_slots"
    }
}

/// Exact paired candidate with a content-derived delivery identity. This is
/// still not retained-source or process-delivery evidence.
public struct PrimeNativeNeuralGateTargetFreeScheduleCandidatePair:
    Encodable,
    Equatable,
    Sendable
{
    public let deliveryIdentitySHA256: String
    public let rawSchedule:
        PrimeNativeNeuralGateTargetFreeRawScheduleCandidate
    public let outerSchedule:
        PrimeNativeNeuralGateTargetFreeOuterScheduleCandidate

    public let sourceBindingEstablished = false
    public let durableArtifactOriginEstablished = false
    public let processOwnershipEstablished = false
    public let processDeliveryObserved = false
    public let workerMaterialized = false
    public let modelExecutionEstablished = false
    public let evaluationPerformed = false
    public let verdictPublicationAuthorized = false
    public let mechanicsPassAuthorized = false
    public let terminalReceiptAuthorized = false
    public let scientificAuthorityAuthorized = false
    public let productAuthorityAuthorized = false

    public init(
        rawSchedule:
            PrimeNativeNeuralGateTargetFreeRawScheduleCandidate,
        outerSchedule:
            PrimeNativeNeuralGateTargetFreeOuterScheduleCandidate
    ) throws {
        try rawSchedule.validate()
        try outerSchedule.validate()
        try Self.validatePair(rawSchedule, outerSchedule)
        deliveryIdentitySHA256 = try targetFreeDeliveryIdentitySHA256(
            raw: rawSchedule,
            outer: outerSchedule
        )
        self.rawSchedule = rawSchedule
        self.outerSchedule = outerSchedule
    }

    public func validate() throws {
        try rawSchedule.validate()
        try outerSchedule.validate()
        try Self.validatePair(rawSchedule, outerSchedule)
        guard deliveryIdentitySHA256 == (try targetFreeDeliveryIdentitySHA256(
            raw: rawSchedule,
            outer: outerSchedule
        )) else {
            throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
                .invalidDeliveryIdentitySHA256
        }
    }

    private static func validatePair(
        _ raw:
            PrimeNativeNeuralGateTargetFreeRawScheduleCandidate,
        _ outer:
            PrimeNativeNeuralGateTargetFreeOuterScheduleCandidate
    ) throws {
        guard raw.invocationRole == outer.invocationRole else {
            throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
                .invocationRoleMismatch
        }
        guard raw.promptSourceBindingSHA256
                == outer.promptSourceBindingSHA256
        else {
            throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
                .pairedPromptSourceBindingMismatch
        }
        guard raw.scheduleIdentitySHA256
                == outer.scheduleIdentitySHA256
        else {
            throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
                .pairedScheduleIdentityMismatch
        }
        let exact =
            PrimeNativeNeuralGateTargetFreeScheduleDeliveryContract
            .frozenV1.exactScheduleRowCount
        guard raw.orderedSlots.count == exact,
              outer.orderedSlots.count == exact
        else {
            throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
                .exactCardinalityRequired(
                    expected: exact,
                    rawObserved: raw.orderedSlots.count,
                    outerObserved: outer.orderedSlots.count
                )
        }
        for (rawSlot, outerSlot) in zip(
            raw.orderedSlots,
            outer.orderedSlots
        ) {
            guard rawSlot.executionIndex == outerSlot.executionIndex,
                  rawSlot.correlationID == outerSlot.correlationID
            else {
                throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
                    .pairedScheduleCorrelationMismatch(
                        executionIndex: rawSlot.executionIndex
                    )
            }
        }
    }

    private enum CodingKeys: String, CodingKey {
        case deliveryIdentitySHA256 = "delivery_identity_sha256"
        case rawSchedule = "raw_schedule"
        case outerSchedule = "outer_schedule"
    }
}

private struct PrimeNativeNeuralGateTargetFreeCandidateIdentityPayload:
    Encodable
{
    let magic: String
    let contractID: String
    let kind: String
    let invocationRole:
        PrimeNativeNeuralGateTargetFreeScheduleInvocationRole
    let promptSourceBindingSHA256: String
    let scheduleIdentitySHA256: String
    let orderedSlotsSHA256: String
    let rowCount: Int

    private enum CodingKeys: String, CodingKey {
        case magic
        case contractID = "contract_id"
        case kind
        case invocationRole = "invocation_role"
        case promptSourceBindingSHA256 =
            "prompt_source_binding_sha256"
        case scheduleIdentitySHA256 = "schedule_identity_sha256"
        case orderedSlotsSHA256 = "ordered_slots_sha256"
        case rowCount = "row_count"
    }
}

private struct PrimeNativeNeuralGateTargetFreeDeliveryIdentityPayload:
    Encodable
{
    let magic: String
    let contractID: String
    let invocationRole:
        PrimeNativeNeuralGateTargetFreeScheduleInvocationRole
    let promptSourceBindingSHA256: String
    let scheduleIdentitySHA256: String
    let rawCandidateIdentitySHA256: String
    let outerCandidateIdentitySHA256: String
    let rowCount: Int

    private enum CodingKeys: String, CodingKey {
        case magic
        case contractID = "contract_id"
        case invocationRole = "invocation_role"
        case promptSourceBindingSHA256 =
            "prompt_source_binding_sha256"
        case scheduleIdentitySHA256 = "schedule_identity_sha256"
        case rawCandidateIdentitySHA256 =
            "raw_candidate_identity_sha256"
        case outerCandidateIdentitySHA256 =
            "outer_candidate_identity_sha256"
        case rowCount = "row_count"
    }
}

private func validateTargetFreeScheduleReference(
    promptSourceBindingSHA256: String,
    scheduleIdentitySHA256: String
) throws {
    guard isLowercaseTargetFreeScheduleSHA256(
        promptSourceBindingSHA256
    ) else {
        throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
            .invalidPromptSourceBindingSHA256
    }
    guard isLowercaseTargetFreeScheduleSHA256(
        scheduleIdentitySHA256
    ) else {
        throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
            .invalidScheduleIdentitySHA256
    }
}

private func targetFreeRawSlotStreamSHA256(
    _ slots: [PrimeNativeNeuralGateTargetFreeRawScheduleSlot]
) throws -> String {
    try targetFreeSlotStreamSHA256(
        slots,
        maximumRecordByteCount:
            PrimeNativeNeuralGateTargetFreeScheduleDeliveryContract
            .frozenV1.maximumRawSlotJSONByteCount,
        canonicalRecord: { try $0.canonicalJSON() }
    )
}

private func targetFreeOuterSlotStreamSHA256(
    _ slots: [PrimeNativeNeuralGateTargetFreeOuterScheduleSlot]
) throws -> String {
    try targetFreeSlotStreamSHA256(
        slots,
        maximumRecordByteCount:
            PrimeNativeNeuralGateTargetFreeScheduleDeliveryContract
            .frozenV1.maximumOuterSlotJSONByteCount,
        canonicalRecord: { try $0.canonicalJSON() }
    )
}

private func targetFreeSlotStreamSHA256<Slot>(
    _ slots: [Slot],
    maximumRecordByteCount: Int,
    canonicalRecord: (Slot) throws -> Data
) throws -> String {
    let maximumRows =
        PrimeNativeNeuralGateTargetFreeScheduleDeliveryContract
        .frozenV1.maximumCandidateRowCount
    let limits = try PrimeNativeNeuralGateReplayDecodeLimits.bounded(
        maximumRecordCount: maximumRows,
        maximumRecordByteCount: maximumRecordByteCount,
        maximumAggregateRecordBytes:
            maximumRows * maximumRecordByteCount
    )
    var accumulator = try
        PrimeNativeNeuralGateInvariantGlobalStreamSHA256Accumulator(
            declaredRecordCount: UInt64(slots.count),
            limits: limits,
            requireCanonicalOrder: false
        )
    for slot in slots {
        try accumulator.append(
            canonicalRecord: canonicalRecord(slot)
        )
    }
    return try accumulator.finish().streamSHA256
}

private func targetFreeCandidateIdentitySHA256(
    role: PrimeNativeNeuralGateTargetFreeScheduleInvocationRole,
    promptSourceBindingSHA256: String,
    scheduleIdentitySHA256: String,
    orderedSlotsSHA256: String,
    rowCount: Int,
    kind: String
) throws -> String {
    guard isLowercaseTargetFreeScheduleSHA256(orderedSlotsSHA256)
    else {
        throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
            .invalidOrderedSlotsSHA256
    }
    let contract =
        PrimeNativeNeuralGateTargetFreeScheduleDeliveryContract.frozenV1
    let payload = PrimeNativeNeuralGateTargetFreeCandidateIdentityPayload(
        magic: contract.candidateIdentityMagic,
        contractID: contract.contractID,
        kind: kind,
        invocationRole: role,
        promptSourceBindingSHA256: promptSourceBindingSHA256,
        scheduleIdentitySHA256: scheduleIdentitySHA256,
        orderedSlotsSHA256: orderedSlotsSHA256,
        rowCount: rowCount
    )
    return PrimeNativeNeuralGateInvariantCodec.sha256(
        try canonicalTargetFreeScheduleJSON(payload)
    )
}

private func targetFreeDeliveryIdentitySHA256(
    raw: PrimeNativeNeuralGateTargetFreeRawScheduleCandidate,
    outer: PrimeNativeNeuralGateTargetFreeOuterScheduleCandidate
) throws -> String {
    let contract =
        PrimeNativeNeuralGateTargetFreeScheduleDeliveryContract.frozenV1
    let payload = PrimeNativeNeuralGateTargetFreeDeliveryIdentityPayload(
        magic: contract.deliveryIdentityMagic,
        contractID: contract.contractID,
        invocationRole: raw.invocationRole,
        promptSourceBindingSHA256: raw.promptSourceBindingSHA256,
        scheduleIdentitySHA256: raw.scheduleIdentitySHA256,
        rawCandidateIdentitySHA256: raw.candidateIdentitySHA256,
        outerCandidateIdentitySHA256: outer.candidateIdentitySHA256,
        rowCount: raw.orderedSlots.count
    )
    return PrimeNativeNeuralGateInvariantCodec.sha256(
        try canonicalTargetFreeScheduleJSON(payload)
    )
}

private func canonicalTargetFreeScheduleJSON<Value: Encodable>(
    _ value: Value
) throws -> Data {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
    do {
        return try encoder.encode(value)
    } catch {
        throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
            .canonicalEncodingRejected
    }
}

private struct PrimeNativeNeuralGateTargetFreeScheduleAnyCodingKey:
    CodingKey
{
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

private func rejectUnknownTargetFreeScheduleKeys<K>(
    from decoder: Decoder,
    admittedBy _: K.Type
) throws
where
    K: CodingKey & CaseIterable & RawRepresentable,
    K.RawValue == String
{
    let dynamic = try decoder.container(
        keyedBy:
            PrimeNativeNeuralGateTargetFreeScheduleAnyCodingKey.self
    )
    let admitted = Set(K.allCases.map(\.rawValue))
    let unknown = dynamic.allKeys
        .map(\.stringValue)
        .filter { !admitted.contains($0) }
        .sorted()
    guard unknown.isEmpty else {
        throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryError
            .unexpectedCodingKeys(unknown)
    }
}

private func isLowercaseTargetFreeScheduleSHA256(
    _ value: String
) -> Bool {
    value.utf8.count == 64
        && value.utf8.allSatisfy {
            ($0 >= 48 && $0 <= 57)
                || ($0 >= 97 && $0 <= 102)
        }
}
