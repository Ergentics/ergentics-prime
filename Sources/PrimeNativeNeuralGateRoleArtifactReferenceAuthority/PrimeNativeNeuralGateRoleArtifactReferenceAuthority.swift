import Foundation
import PrimeNativeNeuralGateCorrectedProcessOwnershipContracts
import PrimeNativeNeuralGateRoleArtifactReferenceContracts
import PrimeNativeNeuralGateTargetFreeScheduleDeliveryContracts
import PrimeNativeNeuralGateTargetFreeScheduleDeliveryAuthority

public enum PrimeNativeNeuralGateRoleArtifactReferenceAuthorityError:
    Error,
    Equatable,
    Sendable
{
    case invalidFrozenContract
    case retainedDeliveryRejected
    case referenceProjectionRejected
    case branchOwnershipMismatch
    case retainedSourceChanged
    case captureBoundStreamProjectionRejected
    case captureBoundStreamAdmissionMismatch
}

/// Supervisor-side construction contract only. It may retain the existing V6
/// delivery-preparation capability, but it neither serializes that capability
/// nor creates a role artifact, worker, execution, or receipt.
public struct PrimeNativeNeuralGateRoleArtifactReferenceAuthorityContract:
    Encodable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let contractID: String
    public let roleArtifactReferenceContractID: String
    public let retainedScheduleDeliveryAuthorityContractID: String
    public let retainedPreProjectionRecaptureRequired: Bool
    public let retainedPostProjectionRecaptureRequired: Bool
    public let commonCaptureScheduleReferenceDerived: Bool
    public let branchCandidateIdentityReferenceDerived: Bool
    public let boundedUntrustedScalarHeaderPreflightBeforeRetainedBinding:
        Bool
    public let trustedExpectedHeaderBoundBeforeFramedRecordCallbacks: Bool
    public let captureBoundStreamDecoderImplemented: Bool
    public let exactStreamAdmissionReconciliationRequired: Bool
    public let retainedPostAdmissionRecaptureRequired: Bool
    public let captureBoundStreamAdmissionImplemented: Bool
    public let realizedRoleArtifactContentReferenceProduced: Bool
    public let sourcePinningObserved: Bool
    public let processDeliveryObserved: Bool
    public let workerMaterialized: Bool
    public let executionObserved: Bool
    public let evaluationPerformed: Bool
    public let mechanicsPassAuthorized: Bool
    public let terminalReceiptAuthorized: Bool
    public let sourceBindingV7Issued: Bool
    public let scientificAuthorityAuthorized: Bool
    public let productAuthorityAuthorized: Bool
    public let authorityStatement: String

    public static let frozenV1 = Self(
        schemaVersion: 1,
        contractID:
            "prime_stage_b_retained_delivery_role_artifact_reference_authority_v1",
        roleArtifactReferenceContractID:
            PrimeNativeNeuralGateRoleArtifactReferenceContract
            .frozenV1.contractID,
        retainedScheduleDeliveryAuthorityContractID:
            PrimeNativeNeuralGateTargetFreeScheduleDeliveryAuthorityContract
            .frozenV1.contractID,
        retainedPreProjectionRecaptureRequired: true,
        retainedPostProjectionRecaptureRequired: true,
        commonCaptureScheduleReferenceDerived: true,
        branchCandidateIdentityReferenceDerived: true,
        boundedUntrustedScalarHeaderPreflightBeforeRetainedBinding: true,
        trustedExpectedHeaderBoundBeforeFramedRecordCallbacks: true,
        captureBoundStreamDecoderImplemented: true,
        exactStreamAdmissionReconciliationRequired: true,
        retainedPostAdmissionRecaptureRequired: true,
        captureBoundStreamAdmissionImplemented: true,
        realizedRoleArtifactContentReferenceProduced: false,
        sourcePinningObserved: false,
        processDeliveryObserved: false,
        workerMaterialized: false,
        executionObserved: false,
        evaluationPerformed: false,
        mechanicsPassAuthorized: false,
        terminalReceiptAuthorized: false,
        sourceBindingV7Issued: false,
        scientificAuthorityAuthorized: false,
        productAuthorityAuthorized: false,
        authorityStatement:
            "This V1 supervisor-only authority first applies a bounded canonical 4 KiB scalar-header preflight before retained-capture work, then retains an already capture-bound target-free schedule delivery across pre/post unchanged recapture, derives sealed common and branch scalar references, binds the trusted expected header from the retained candidate pair, and compares it before reader construction or framed-record callbacks. It reconciles the complete bounded admission and recaptures unchanged after admission. It creates no realized role artifact content reference, source-pinned closure, descriptor-read claim, executable, process delivery, worker, execution, evaluation, PASS, receipt, V7, scientific authority, or product authority."
    )

    public func validate() throws {
        try PrimeNativeNeuralGateRoleArtifactReferenceContract
            .frozenV1.validate()
        try PrimeNativeNeuralGateTargetFreeScheduleDeliveryAuthorityContract
            .frozenV1.validate()
        guard self == .frozenV1,
              schemaVersion == 1,
              roleArtifactReferenceContractID
                == PrimeNativeNeuralGateRoleArtifactReferenceContract
                .frozenV1.contractID,
              retainedScheduleDeliveryAuthorityContractID
                == PrimeNativeNeuralGateTargetFreeScheduleDeliveryAuthorityContract
                .frozenV1.contractID,
              retainedPreProjectionRecaptureRequired,
              retainedPostProjectionRecaptureRequired,
              commonCaptureScheduleReferenceDerived,
              branchCandidateIdentityReferenceDerived,
              boundedUntrustedScalarHeaderPreflightBeforeRetainedBinding,
              trustedExpectedHeaderBoundBeforeFramedRecordCallbacks,
              captureBoundStreamDecoderImplemented,
              exactStreamAdmissionReconciliationRequired,
              retainedPostAdmissionRecaptureRequired,
              captureBoundStreamAdmissionImplemented,
              !realizedRoleArtifactContentReferenceProduced,
              !sourcePinningObserved,
              !processDeliveryObserved,
              !workerMaterialized,
              !executionObserved,
              !evaluationPerformed,
              !mechanicsPassAuthorized,
              !terminalReceiptAuthorized,
              !sourceBindingV7Issued,
              !scientificAuthorityAuthorized,
              !productAuthorityAuthorized
        else {
            throw PrimeNativeNeuralGateRoleArtifactReferenceAuthorityError
                .invalidFrozenContract
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case contractID = "contract_id"
        case roleArtifactReferenceContractID =
            "role_artifact_reference_contract_id"
        case retainedScheduleDeliveryAuthorityContractID =
            "retained_schedule_delivery_authority_contract_id"
        case retainedPreProjectionRecaptureRequired =
            "retained_pre_projection_recapture_required"
        case retainedPostProjectionRecaptureRequired =
            "retained_post_projection_recapture_required"
        case commonCaptureScheduleReferenceDerived =
            "common_capture_schedule_reference_derived"
        case branchCandidateIdentityReferenceDerived =
            "branch_candidate_identity_reference_derived"
        case boundedUntrustedScalarHeaderPreflightBeforeRetainedBinding =
            "bounded_untrusted_scalar_header_preflight_before_retained_binding"
        case trustedExpectedHeaderBoundBeforeFramedRecordCallbacks =
            "trusted_expected_header_bound_before_framed_record_callbacks"
        case captureBoundStreamDecoderImplemented =
            "capture_bound_stream_decoder_implemented"
        case exactStreamAdmissionReconciliationRequired =
            "exact_stream_admission_reconciliation_required"
        case retainedPostAdmissionRecaptureRequired =
            "retained_post_admission_recapture_required"
        case captureBoundStreamAdmissionImplemented =
            "capture_bound_stream_admission_implemented"
        case realizedRoleArtifactContentReferenceProduced =
            "realized_role_artifact_content_reference_produced"
        case sourcePinningObserved = "source_pinning_observed"
        case processDeliveryObserved = "process_delivery_observed"
        case workerMaterialized = "worker_materialized"
        case executionObserved = "execution_observed"
        case evaluationPerformed = "evaluation_performed"
        case mechanicsPassAuthorized = "mechanics_pass_authorized"
        case terminalReceiptAuthorized = "terminal_receipt_authorized"
        case sourceBindingV7Issued = "source_binding_v7_issued"
        case scientificAuthorityAuthorized =
            "scientific_authority_authorized"
        case productAuthorityAuthorized = "product_authority_authorized"
        case authorityStatement = "authority_statement"
    }
}

/// Sealed, non-Codable reference bundle. The retained delivery value privately
/// preserves the live capture capability; its public references remain scalar
/// observations and cannot be used to reconstruct that capability.
public struct PrimeNativeNeuralGateCaptureBoundRoleArtifactReferenceBundle:
    @unchecked Sendable
{
    public let contractID: String
    public let commonReference:
        PrimeNativeNeuralGateCommonCaptureScheduleReference
    public let branchReference:
        PrimeNativeNeuralGateBranchScheduleReference

    public let retainedCaptureBindingEstablished = true
    public let commonCaptureScheduleReferenceDerived = true
    public let branchCandidateIdentityReferenceDerived = true
    public let realizedRoleArtifactContentReferenceProduced = false
    public let sourcePinningObserved = false
    public let processDeliveryObserved = false
    public let workerMaterialized = false
    public let executionObserved = false
    public let evaluationPerformed = false
    public let mechanicsPassAuthorized = false
    public let terminalReceiptAuthorized = false
    public let sourceBindingV7Issued = false
    public let scientificAuthorityAuthorized = false
    public let productAuthorityAuthorized = false

    private let retainedDelivery:
        PrimeNativeNeuralGateCaptureBoundTargetFreeScheduleDelivery

    fileprivate init(
        commonReference:
            PrimeNativeNeuralGateCommonCaptureScheduleReference,
        branchReference:
            PrimeNativeNeuralGateBranchScheduleReference,
        retainedDelivery:
            PrimeNativeNeuralGateCaptureBoundTargetFreeScheduleDelivery
    ) {
        contractID =
            PrimeNativeNeuralGateRoleArtifactReferenceAuthorityContract
            .frozenV1.contractID
        self.commonReference = commonReference
        self.branchReference = branchReference
        self.retainedDelivery = retainedDelivery
    }

    public func validateSourceStillUnchanged() throws {
        do {
            try retainedDelivery.validateSourceStillUnchanged()
        } catch {
            throw PrimeNativeNeuralGateRoleArtifactReferenceAuthorityError
                .retainedSourceChanged
        }
    }
}

/// Final bounded-stream observation that still retains the live source
/// capability. It is deliberately non-Codable: copied scalar identities do
/// not recreate the retained capture or establish process delivery.
public struct PrimeNativeNeuralGateCaptureBoundScheduleStreamAdmission:
    @unchecked Sendable
{
    public let contractID: String
    public let commonReference:
        PrimeNativeNeuralGateCommonCaptureScheduleReference
    public let branchReference:
        PrimeNativeNeuralGateBranchScheduleReference
    public let streamAdmission:
        PrimeNativeNeuralGateTargetFreeSchedulePairStreamAdmission

    public let retainedCaptureBindingEstablished = true
    public let contentBindingEstablished = true
    public let targetFreeScheduleContentBindingEstablished = true
    public let declarativeBranchOwnershipBound = true
    public let commonAndBranchReferenceBindingEstablished = true
    public let boundedStreamAdmissionEstablished = true
    public let descriptorReadAuthorityEstablished = false
    public let sourcePinningObserved = false
    public let promptContentTargetIndependenceEstablished = false
    public let processDeliveryObserved = false
    public let workerMaterialized = false
    public let modelExecutionEstablished = false
    public let evaluationPerformed = false
    public let verdictPublicationAuthorized = false
    public let publicationAuthorized = false
    public let mechanicsPassAuthorized = false
    public let terminalReceiptAuthorized = false
    public let sourceBindingV7Issued = false
    public let scientificAuthorityAuthorized = false
    public let productAuthorityAuthorized = false

    private let retainedDelivery:
        PrimeNativeNeuralGateCaptureBoundTargetFreeScheduleDelivery
    private let retainedReferenceBundle:
        PrimeNativeNeuralGateCaptureBoundRoleArtifactReferenceBundle

    fileprivate init(
        streamAdmission:
            PrimeNativeNeuralGateTargetFreeSchedulePairStreamAdmission,
        retainedDelivery:
            PrimeNativeNeuralGateCaptureBoundTargetFreeScheduleDelivery,
        retainedReferenceBundle:
            PrimeNativeNeuralGateCaptureBoundRoleArtifactReferenceBundle
    ) {
        contractID =
            PrimeNativeNeuralGateRoleArtifactReferenceAuthorityContract
            .frozenV1.contractID
        commonReference = retainedReferenceBundle.commonReference
        branchReference = retainedReferenceBundle.branchReference
        self.streamAdmission = streamAdmission
        self.retainedDelivery = retainedDelivery
        self.retainedReferenceBundle = retainedReferenceBundle
    }

    public func validateSourceStillUnchanged() throws {
        do {
            try retainedDelivery.validateSourceStillUnchanged()
            try retainedReferenceBundle.validateSourceStillUnchanged()
        } catch {
            throw PrimeNativeNeuralGateRoleArtifactReferenceAuthorityError
                .retainedSourceChanged
        }
    }
}

/// One-shot supervisor-side join. The expected header is derived from the
/// retained candidate pair before caller-supplied header or framed bytes enter
/// the strict target-free decoder.
public final class
    PrimeNativeNeuralGateCaptureBoundScheduleStreamDecoder
{
    private let retainedDelivery:
        PrimeNativeNeuralGateCaptureBoundTargetFreeScheduleDelivery
    private let retainedReferenceBundle:
        PrimeNativeNeuralGateCaptureBoundRoleArtifactReferenceBundle
    private let expectedHeader:
        PrimeNativeNeuralGateTargetFreeSchedulePairStreamHeader
    private let decoder:
        PrimeNativeNeuralGateTargetFreeScheduleCandidatePairStreamDecoder

    fileprivate init(
        retainedDelivery:
            PrimeNativeNeuralGateCaptureBoundTargetFreeScheduleDelivery,
        retainedReferenceBundle:
            PrimeNativeNeuralGateCaptureBoundRoleArtifactReferenceBundle,
        expectedHeader:
            PrimeNativeNeuralGateTargetFreeSchedulePairStreamHeader,
        decoder:
            PrimeNativeNeuralGateTargetFreeScheduleCandidatePairStreamDecoder
    ) {
        self.retainedDelivery = retainedDelivery
        self.retainedReferenceBundle = retainedReferenceBundle
        self.expectedHeader = expectedHeader
        self.decoder = decoder
    }

    public func consumeRaw(_ bytes: Data) throws {
        try decoder.consumeRaw(bytes)
    }

    /// Invoke only after actual EOF on the bounded read-only raw descriptor.
    public func finishRawAtEOF() throws {
        try decoder.finishRawAtEOF()
    }

    public func consumeOuter(_ bytes: Data) throws {
        try decoder.consumeOuter(bytes)
    }

    /// Invoke only after actual EOF on the bounded read-only outer descriptor.
    public func finishAtEOF() throws
        -> PrimeNativeNeuralGateCaptureBoundScheduleStreamAdmission
    {
        let admission = try decoder.finishAtEOF()
        try PrimeNativeNeuralGateRoleArtifactReferenceAuthority
            .validateCaptureBoundStreamAdmission(
                admission,
                expectedHeader: expectedHeader,
                candidatePair: retainedDelivery.candidatePair,
                referenceBundle: retainedReferenceBundle
            )
        do {
            try retainedDelivery.validateSourceStillUnchanged()
            try retainedReferenceBundle.validateSourceStillUnchanged()
        } catch {
            throw PrimeNativeNeuralGateRoleArtifactReferenceAuthorityError
                .retainedSourceChanged
        }
        return PrimeNativeNeuralGateCaptureBoundScheduleStreamAdmission(
            streamAdmission: admission,
            retainedDelivery: retainedDelivery,
            retainedReferenceBundle: retainedReferenceBundle
        )
    }
}

public enum PrimeNativeNeuralGateRoleArtifactReferenceAuthority {
    private typealias Error =
        PrimeNativeNeuralGateRoleArtifactReferenceAuthorityError

    public static func bind(
        retainedDelivery:
            PrimeNativeNeuralGateCaptureBoundTargetFreeScheduleDelivery
    ) throws
        -> PrimeNativeNeuralGateCaptureBoundRoleArtifactReferenceBundle
    {
        try PrimeNativeNeuralGateRoleArtifactReferenceAuthorityContract
            .frozenV1.validate()
        do {
            try retainedDelivery.validateSourceStillUnchanged()
        } catch {
            throw Error.retainedSourceChanged
        }
        guard retainedDelivery.retainedCaptureBindingEstablished,
              retainedDelivery
                .targetFreeScheduleContentBindingEstablished,
              retainedDelivery.declarativeBranchOwnershipBound,
              !retainedDelivery.processDeliveryObserved,
              !retainedDelivery.workerMaterialized,
              !retainedDelivery.modelExecutionEstablished,
              !retainedDelivery.evaluationPerformed,
              !retainedDelivery.mechanicsPassAuthorized,
              !retainedDelivery.terminalReceiptAuthorized,
              !retainedDelivery.scientificAuthorityAuthorized,
              !retainedDelivery.productAuthorityAuthorized
        else {
            throw Error.retainedDeliveryRejected
        }

        let commonReference: PrimeNativeNeuralGateCommonCaptureScheduleReference
        let branchReference: PrimeNativeNeuralGateBranchScheduleReference
        do {
            try retainedDelivery.candidatePair.validate()
            commonReference = try .init(
                captureIdentitySHA256:
                    retainedDelivery.captureIdentitySHA256,
                sourceRootIdentity:
                    retainedDelivery.sourceRootIdentity,
                promptSourceBindingSHA256:
                    retainedDelivery.promptSourceBindingSHA256,
                scheduleIdentitySHA256:
                    retainedDelivery.scheduleIdentitySHA256
            )
            branchReference = try .init(
                branch: retainedDelivery.branch,
                invocationRole: retainedDelivery.invocationRole,
                commonReferenceIdentitySHA256:
                    commonReference.referenceIdentitySHA256,
                rawCandidateIdentitySHA256:
                    retainedDelivery.candidatePair.rawSchedule
                    .candidateIdentitySHA256,
                outerCandidateIdentitySHA256:
                    retainedDelivery.candidatePair.outerSchedule
                    .candidateIdentitySHA256,
                deliveryIdentitySHA256:
                    retainedDelivery.candidatePair
                    .deliveryIdentitySHA256
            )
            try validatePreparedReferences(
                commonReference: commonReference,
                branchReference: branchReference,
                expectedBranch: retainedDelivery.branch,
                expectedInvocationRole:
                    retainedDelivery.invocationRole,
                expectedCaptureIdentitySHA256:
                    retainedDelivery.captureIdentitySHA256,
                expectedPromptSourceBindingSHA256:
                    retainedDelivery.promptSourceBindingSHA256,
                expectedScheduleIdentitySHA256:
                    retainedDelivery.scheduleIdentitySHA256,
                expectedRawCandidateIdentitySHA256:
                    retainedDelivery.candidatePair.rawSchedule
                    .candidateIdentitySHA256,
                expectedOuterCandidateIdentitySHA256:
                    retainedDelivery.candidatePair.outerSchedule
                    .candidateIdentitySHA256,
                expectedDeliveryIdentitySHA256:
                    retainedDelivery.candidatePair
                    .deliveryIdentitySHA256
            )
            try validateScheduleOwnership(
                retainedDelivery: retainedDelivery
            )
        } catch let error as Error {
            throw error
        } catch {
            throw Error.referenceProjectionRejected
        }

        do {
            try retainedDelivery.validateSourceStillUnchanged()
        } catch {
            throw Error.retainedSourceChanged
        }
        return PrimeNativeNeuralGateCaptureBoundRoleArtifactReferenceBundle(
            commonReference: commonReference,
            branchReference: branchReference,
            retainedDelivery: retainedDelivery
        )
    }

    public static func makeCaptureBoundStreamDecoder(
        retainedDelivery:
            PrimeNativeNeuralGateCaptureBoundTargetFreeScheduleDelivery,
        headerJSON: Data
    ) throws
        -> PrimeNativeNeuralGateCaptureBoundScheduleStreamDecoder
    {
        try PrimeNativeNeuralGateRoleArtifactReferenceAuthorityContract
            .frozenV1.validate()
        _ = try decodeUntrustedHeaderBeforeRetainedBinding(
            headerJSON
        )
        let referenceBundle = try bind(
            retainedDelivery: retainedDelivery
        )
        let expectedHeader:
            PrimeNativeNeuralGateTargetFreeSchedulePairStreamHeader
        let decoder:
            PrimeNativeNeuralGateTargetFreeScheduleCandidatePairStreamDecoder
        do {
            expectedHeader = try .init(
                expectedCandidatePair: retainedDelivery.candidatePair
            )
            try validateExpectedStreamHeader(
                expectedHeader,
                candidatePair: retainedDelivery.candidatePair,
                referenceBundle: referenceBundle
            )
            decoder = try .init(
                headerJSON: headerJSON,
                expectedHeader: expectedHeader
            )
            try retainedDelivery.validateSourceStillUnchanged()
        } catch let error as Error {
            throw error
        } catch {
            throw Error.captureBoundStreamProjectionRejected
        }
        return PrimeNativeNeuralGateCaptureBoundScheduleStreamDecoder(
            retainedDelivery: retainedDelivery,
            retainedReferenceBundle: referenceBundle,
            expectedHeader: expectedHeader,
            decoder: decoder
        )
    }

    /// Performs only the bounded 4 KiB scalar-header admission. The retained
    /// capture and 18,432-row candidate pair must not be touched until this
    /// cheap untrusted-input gate succeeds.
    static func decodeUntrustedHeaderBeforeRetainedBinding(
        _ headerJSON: Data
    ) throws
        -> PrimeNativeNeuralGateTargetFreeSchedulePairStreamHeader
    {
        do {
            return try .decodeBounded(from: headerJSON)
        } catch {
            throw Error.captureBoundStreamProjectionRejected
        }
    }

    static func validatePreparedReferences(
        commonReference:
            PrimeNativeNeuralGateCommonCaptureScheduleReference,
        branchReference:
            PrimeNativeNeuralGateBranchScheduleReference,
        expectedBranch:
            PrimeNativeNeuralGateCorrectedProcessBranch,
        expectedInvocationRole:
            PrimeNativeNeuralGateTargetFreeScheduleInvocationRole,
        expectedCaptureIdentitySHA256: String,
        expectedPromptSourceBindingSHA256: String,
        expectedScheduleIdentitySHA256: String,
        expectedRawCandidateIdentitySHA256: String,
        expectedOuterCandidateIdentitySHA256: String,
        expectedDeliveryIdentitySHA256: String
    ) throws {
        try commonReference.validate()
        try branchReference.validate(
            commonReference: commonReference
        )
        guard branchReference.branch == expectedBranch,
              branchReference.invocationRole
                == expectedInvocationRole,
              expectedInvocationRole
                == expectedBranch.targetFreeInvocationRole,
              commonReference.captureIdentitySHA256
                == expectedCaptureIdentitySHA256,
              commonReference.promptSourceBindingSHA256
                == expectedPromptSourceBindingSHA256,
              commonReference.scheduleIdentitySHA256
                == expectedScheduleIdentitySHA256,
              branchReference.rawCandidateIdentitySHA256
                == expectedRawCandidateIdentitySHA256,
              branchReference.outerCandidateIdentitySHA256
                == expectedOuterCandidateIdentitySHA256,
              branchReference.deliveryIdentitySHA256
                == expectedDeliveryIdentitySHA256
        else {
            throw Error.referenceProjectionRejected
        }
    }

    static func validateExpectedStreamHeader(
        _ expectedHeader:
            PrimeNativeNeuralGateTargetFreeSchedulePairStreamHeader,
        candidatePair:
            PrimeNativeNeuralGateTargetFreeScheduleCandidatePair,
        referenceBundle:
            PrimeNativeNeuralGateCaptureBoundRoleArtifactReferenceBundle
    ) throws {
        try validateExpectedStreamHeader(
            expectedHeader,
            candidatePair: candidatePair,
            commonReference: referenceBundle.commonReference,
            branchReference: referenceBundle.branchReference
        )
    }

    static func validateExpectedStreamHeader(
        _ expectedHeader:
            PrimeNativeNeuralGateTargetFreeSchedulePairStreamHeader,
        candidatePair:
            PrimeNativeNeuralGateTargetFreeScheduleCandidatePair,
        commonReference:
            PrimeNativeNeuralGateCommonCaptureScheduleReference,
        branchReference:
            PrimeNativeNeuralGateBranchScheduleReference
    ) throws {
        try candidatePair.validate()
        let recomputed = try
            PrimeNativeNeuralGateTargetFreeSchedulePairStreamHeader(
                expectedCandidatePair: candidatePair
            )
        try commonReference.validate()
        try branchReference.validate(
            commonReference: commonReference
        )
        guard expectedHeader == recomputed,
              expectedHeader.invocationRole
                == branchReference.invocationRole,
              expectedHeader.promptSourceBindingSHA256
                == commonReference.promptSourceBindingSHA256,
              expectedHeader.scheduleIdentitySHA256
                == commonReference.scheduleIdentitySHA256,
              expectedHeader.rawOrderedSlotsSHA256
                == candidatePair.rawSchedule.orderedSlotsSHA256,
              expectedHeader.outerOrderedSlotsSHA256
                == candidatePair.outerSchedule.orderedSlotsSHA256,
              expectedHeader.rawCandidateIdentitySHA256
                == branchReference.rawCandidateIdentitySHA256,
              expectedHeader.outerCandidateIdentitySHA256
                == branchReference.outerCandidateIdentitySHA256,
              expectedHeader.deliveryIdentitySHA256
                == branchReference.deliveryIdentitySHA256
        else {
            throw Error.captureBoundStreamProjectionRejected
        }
    }

    static func validateCaptureBoundStreamAdmission(
        _ admission:
            PrimeNativeNeuralGateTargetFreeSchedulePairStreamAdmission,
        expectedHeader:
            PrimeNativeNeuralGateTargetFreeSchedulePairStreamHeader,
        candidatePair:
            PrimeNativeNeuralGateTargetFreeScheduleCandidatePair,
        referenceBundle:
            PrimeNativeNeuralGateCaptureBoundRoleArtifactReferenceBundle
    ) throws {
        try validateCaptureBoundStreamAdmission(
            admission,
            expectedHeader: expectedHeader,
            candidatePair: candidatePair,
            commonReference: referenceBundle.commonReference,
            branchReference: referenceBundle.branchReference
        )
    }

    static func validateCaptureBoundStreamAdmission(
        _ admission:
            PrimeNativeNeuralGateTargetFreeSchedulePairStreamAdmission,
        expectedHeader:
            PrimeNativeNeuralGateTargetFreeSchedulePairStreamHeader,
        candidatePair:
            PrimeNativeNeuralGateTargetFreeScheduleCandidatePair,
        commonReference:
            PrimeNativeNeuralGateCommonCaptureScheduleReference,
        branchReference:
            PrimeNativeNeuralGateBranchScheduleReference
    ) throws {
        try validateExpectedStreamHeader(
            expectedHeader,
            candidatePair: candidatePair,
            commonReference: commonReference,
            branchReference: branchReference
        )
        let contract =
            PrimeNativeNeuralGateTargetFreeScheduleStreamContract
            .frozenV2
        try contract.validate()
        let framingByteCount = UInt64(
            9 + 8 + contract.exactScheduleRowCount * 8
        )
        guard admission.streamContractID == contract.contractID,
              admission.invocationRole
                == branchReference.invocationRole,
              admission.promptSourceBindingSHA256
                == commonReference.promptSourceBindingSHA256,
              admission.scheduleIdentitySHA256
                == commonReference.scheduleIdentitySHA256,
              admission.orderedSlotCount
                == contract.exactScheduleRowCount,
              admission.orderedSlotCount
                == candidatePair.rawSchedule.orderedSlots.count,
              admission.orderedSlotCount
                == candidatePair.outerSchedule.orderedSlots.count,
              admission.rawOrderedSlotsSHA256
                == candidatePair.rawSchedule.orderedSlotsSHA256,
              admission.outerOrderedSlotsSHA256
                == candidatePair.outerSchedule.orderedSlotsSHA256,
              admission.rawCandidateIdentitySHA256
                == branchReference.rawCandidateIdentitySHA256,
              admission.outerCandidateIdentitySHA256
                == branchReference.outerCandidateIdentitySHA256,
              admission.deliveryIdentitySHA256
                == branchReference.deliveryIdentitySHA256,
              admission.rawFramedStreamByteCount
                == framingByteCount
                    + admission.rawAggregateRecordByteCount,
              admission.outerFramedStreamByteCount
                == framingByteCount
                    + admission.outerAggregateRecordByteCount,
              admission.rawFramedStreamByteCount
                <= UInt64(contract.maximumRawFramedStreamBytes),
              admission.outerFramedStreamByteCount
                <= UInt64(contract.maximumOuterFramedStreamBytes),
              admission.rawAggregateRecordByteCount > 0,
              admission.rawAggregateRecordByteCount
                <= UInt64(contract.maximumRawAggregateRecordBytes),
              admission.outerAggregateRecordByteCount > 0,
              admission.outerAggregateRecordByteCount
                <= UInt64(contract.maximumOuterAggregateRecordBytes),
              !admission.sourceBindingEstablished,
              !admission.durableArtifactOriginEstablished,
              !admission.promptContentTargetIndependenceEstablished,
              !admission.processOwnershipEstablished,
              !admission.processDeliveryObserved,
              !admission.workerMaterialized,
              !admission.modelExecutionEstablished,
              !admission.evaluationPerformed,
              !admission.verdictPublicationAuthorized,
              !admission.publicationAuthorized,
              !admission.mechanicsPassAuthorized,
              !admission.terminalReceiptAuthorized,
              !admission.scientificAuthorityAuthorized,
              !admission.productAuthorityAuthorized
        else {
            throw Error.captureBoundStreamAdmissionMismatch
        }
    }

    private static func validateScheduleOwnership(
        retainedDelivery:
            PrimeNativeNeuralGateCaptureBoundTargetFreeScheduleDelivery
    ) throws {
        let contract =
            PrimeNativeNeuralGateRoleArtifactReferenceContract.frozenV1
        let rules = contract.roleArtifactDeclarations
            .flatMap(\.artifactRules)
        guard let rawRule = rules.first(where: {
                  $0.relativePath
                    == retainedDelivery.rawScheduleRelativePath
              }),
              let outerRule = rules.first(where: {
                  $0.relativePath
                    == retainedDelivery.outerScheduleRelativePath
              }),
              rawRule.branch == retainedDelivery.branch,
              rawRule.schemaKind == .rawSchedule,
              rawRule.ownerProcessRole
                == retainedDelivery.rawScheduleOwnerRole,
              rawRule.ownerProcessRole
                == retainedDelivery.branch.supervisorRole,
              rawRule.allowedReaderProcessRoles.contains(
                  retainedDelivery.rawWorkerRole
              ),
              outerRule.branch == retainedDelivery.branch,
              outerRule.schemaKind == .outerSchedule,
              outerRule.ownerProcessRole
                == retainedDelivery.outerScheduleOwnerRole,
              outerRule.ownerProcessRole
                == retainedDelivery.branch.supervisorRole,
              outerRule.allowedReaderProcessRoles.contains(
                  retainedDelivery.evaluationWorkerRole
              )
        else {
            throw Error.branchOwnershipMismatch
        }
    }
}
