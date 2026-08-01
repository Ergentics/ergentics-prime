import PrimeNativeNeuralGateCorrectedEvaluationOwnershipContracts
import PrimeNativeNeuralGateCorrectedProcessOwnershipContracts
import PrimeNativeNeuralGateReplayCaptureInventory
import PrimeNativeNeuralGateReplaySourceComposition
import PrimeNativeNeuralGateTargetFreeScheduleDeliveryContracts

public enum PrimeNativeNeuralGateTargetFreeScheduleDeliveryAuthorityError:
    Error,
    Equatable,
    Sendable
{
    case invalidFrozenContract
    case retainedCaptureRejected
    case sourceProjectionRejected
    case captureBindingMismatch
    case branchOwnershipMismatch
    case retainedSourceChanged
}

/// Supervisor-only contract joining the retained V5 source capability to the
/// target-free content projection and the frozen branch ownership records.
public struct PrimeNativeNeuralGateTargetFreeScheduleDeliveryAuthorityContract:
    Encodable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let contractID: String
    public let captureInventoryContractID: String
    public let sourceCompositionContractID: String
    public let targetFreeScheduleContractID: String
    public let correctedProcessOwnershipContractID: String
    public let correctedEvaluationOwnershipContractID: String
    public let retainedPreProjectionRecaptureRequired: Bool
    public let retainedPostProjectionRecaptureRequired: Bool
    public let exactCaptureRootSourceScheduleBindingRequired: Bool
    public let exhaustiveBranchRoleMappingRequired: Bool
    public let candidateContentIdentityRecomputationRequired: Bool
    public let retainedCaptureBindingImplemented: Bool
    public let targetFreeScheduleContentBindingImplemented: Bool
    public let declarativeBranchOwnershipBindingImplemented: Bool
    public let processDeliveryObserved: Bool
    public let workerMaterialized: Bool
    public let modelExecutionEstablished: Bool
    public let evaluationPerformed: Bool
    public let mechanicsPassAuthorized: Bool
    public let terminalReceiptAuthorized: Bool
    public let scientificAuthorityAuthorized: Bool
    public let productAuthorityAuthorized: Bool
    public let authorityStatement: String

    public static let frozenV1 = Self(
        schemaVersion: 1,
        contractID:
            "prime_stage_b_retained_capture_bound_target_free_schedule_delivery_authority_v1",
        captureInventoryContractID:
            PrimeNativeNeuralGateReplayCaptureInventoryContract
            .frozenV1.contractID,
        sourceCompositionContractID:
            PrimeNativeNeuralGateReplaySourceCompositionContract
            .frozenV1.contractID,
        targetFreeScheduleContractID:
            PrimeNativeNeuralGateTargetFreeScheduleDeliveryContract
            .frozenV1.contractID,
        correctedProcessOwnershipContractID:
            PrimeNativeNeuralGateCorrectedProcessOwnershipContract
            .frozenV1.contractID,
        correctedEvaluationOwnershipContractID:
            PrimeNativeNeuralGateCorrectedEvaluationOwnershipContract
            .frozenV1.contractID,
        retainedPreProjectionRecaptureRequired: true,
        retainedPostProjectionRecaptureRequired: true,
        exactCaptureRootSourceScheduleBindingRequired: true,
        exhaustiveBranchRoleMappingRequired: true,
        candidateContentIdentityRecomputationRequired: true,
        retainedCaptureBindingImplemented: true,
        targetFreeScheduleContentBindingImplemented: true,
        declarativeBranchOwnershipBindingImplemented: true,
        processDeliveryObserved: false,
        workerMaterialized: false,
        modelExecutionEstablished: false,
        evaluationPerformed: false,
        mechanicsPassAuthorized: false,
        terminalReceiptAuthorized: false,
        scientificAuthorityAuthorized: false,
        productAuthorityAuthorized: false,
        authorityStatement:
            "This V1 supervisor-only adapter retains the live V5 exact-tree capture, recaptures before and after projection, derives the maintained source schedule from captured prompt records, verifies content-derived target-free identities, and binds probe/verifier to the frozen raw and outer schedule owners. The returned value is sealed and non-Codable. It prepares source- and owner-bound candidate state; aggregate decoding, byte delivery, and all processes remain unimplemented. It does not observe process delivery, materialize a worker, execute a model, evaluate output, authorize PASS, publish a receipt, make a scientific claim, or authorize product use."
    )

    public func validate() throws {
        guard self == .frozenV1,
              schemaVersion == 1,
              captureInventoryContractID
                == PrimeNativeNeuralGateReplayCaptureInventoryContract
                .frozenV1.contractID,
              sourceCompositionContractID
                == PrimeNativeNeuralGateReplaySourceCompositionContract
                .frozenV1.contractID,
              targetFreeScheduleContractID
                == PrimeNativeNeuralGateTargetFreeScheduleDeliveryContract
                .frozenV1.contractID,
              correctedProcessOwnershipContractID
                == PrimeNativeNeuralGateCorrectedProcessOwnershipContract
                .frozenV1.contractID,
              correctedEvaluationOwnershipContractID
                == PrimeNativeNeuralGateCorrectedEvaluationOwnershipContract
                .frozenV1.contractID,
              retainedPreProjectionRecaptureRequired,
              retainedPostProjectionRecaptureRequired,
              exactCaptureRootSourceScheduleBindingRequired,
              exhaustiveBranchRoleMappingRequired,
              candidateContentIdentityRecomputationRequired,
              retainedCaptureBindingImplemented,
              targetFreeScheduleContentBindingImplemented,
              declarativeBranchOwnershipBindingImplemented,
              !processDeliveryObserved,
              !workerMaterialized,
              !modelExecutionEstablished,
              !evaluationPerformed,
              !mechanicsPassAuthorized,
              !terminalReceiptAuthorized,
              !scientificAuthorityAuthorized,
              !productAuthorityAuthorized
        else {
            throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryAuthorityError
                .invalidFrozenContract
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case contractID = "contract_id"
        case captureInventoryContractID =
            "capture_inventory_contract_id"
        case sourceCompositionContractID =
            "source_composition_contract_id"
        case targetFreeScheduleContractID =
            "target_free_schedule_contract_id"
        case correctedProcessOwnershipContractID =
            "corrected_process_ownership_contract_id"
        case correctedEvaluationOwnershipContractID =
            "corrected_evaluation_ownership_contract_id"
        case retainedPreProjectionRecaptureRequired =
            "retained_pre_projection_recapture_required"
        case retainedPostProjectionRecaptureRequired =
            "retained_post_projection_recapture_required"
        case exactCaptureRootSourceScheduleBindingRequired =
            "exact_capture_root_source_schedule_binding_required"
        case exhaustiveBranchRoleMappingRequired =
            "exhaustive_branch_role_mapping_required"
        case candidateContentIdentityRecomputationRequired =
            "candidate_content_identity_recomputation_required"
        case retainedCaptureBindingImplemented =
            "retained_capture_binding_implemented"
        case targetFreeScheduleContentBindingImplemented =
            "target_free_schedule_content_binding_implemented"
        case declarativeBranchOwnershipBindingImplemented =
            "declarative_branch_ownership_binding_implemented"
        case processDeliveryObserved = "process_delivery_observed"
        case workerMaterialized = "worker_materialized"
        case modelExecutionEstablished = "model_execution_established"
        case evaluationPerformed = "evaluation_performed"
        case mechanicsPassAuthorized = "mechanics_pass_authorized"
        case terminalReceiptAuthorized = "terminal_receipt_authorized"
        case scientificAuthorityAuthorized =
            "scientific_authority_authorized"
        case productAuthorityAuthorized = "product_authority_authorized"
        case authorityStatement = "authority_statement"
    }
}

/// Sealed delivery-preparation capability. The private retained capture is the
/// authority; every public scalar is an observation only.
public struct PrimeNativeNeuralGateCaptureBoundTargetFreeScheduleDelivery:
    @unchecked Sendable
{
    public let contractID: String
    public let captureIdentitySHA256: String
    public let sourceRootIdentity:
        PrimeNativeNeuralGateTargetFreeSourceRootIdentity
    public let promptSourceBindingSHA256: String
    public let scheduleIdentitySHA256: String
    public let branch:
        PrimeNativeNeuralGateCorrectedProcessBranch
    public let invocationRole:
        PrimeNativeNeuralGateTargetFreeScheduleInvocationRole
    public let rawScheduleRelativePath: String
    public let rawScheduleOwnerRole:
        PrimeNativeNeuralGateCorrectedProcessRole
    public let rawWorkerRole:
        PrimeNativeNeuralGateCorrectedProcessRole
    public let outerScheduleRelativePath: String
    public let outerScheduleOwnerRole:
        PrimeNativeNeuralGateCorrectedProcessRole
    public let evaluationWorkerRole:
        PrimeNativeNeuralGateCorrectedProcessRole
    public let candidatePair:
        PrimeNativeNeuralGateTargetFreeScheduleCandidatePair

    public let retainedCaptureBindingEstablished = true
    public let targetFreeScheduleContentBindingEstablished = true
    public let declarativeBranchOwnershipBound = true
    public let processDeliveryObserved = false
    public let workerMaterialized = false
    public let modelExecutionEstablished = false
    public let evaluationPerformed = false
    public let mechanicsPassAuthorized = false
    public let terminalReceiptAuthorized = false
    public let scientificAuthorityAuthorized = false
    public let productAuthorityAuthorized = false

    private let retainedCapture:
        PrimeNativeNeuralGateFourSourceCaptureInventory

    fileprivate init(
        captureIdentitySHA256: String,
        sourceRootIdentity:
            PrimeNativeNeuralGateTargetFreeSourceRootIdentity,
        promptSourceBindingSHA256: String,
        scheduleIdentitySHA256: String,
        branch: PrimeNativeNeuralGateCorrectedProcessBranch,
        invocationRole:
            PrimeNativeNeuralGateTargetFreeScheduleInvocationRole,
        rawScheduleRelativePath: String,
        rawScheduleOwnerRole:
            PrimeNativeNeuralGateCorrectedProcessRole,
        rawWorkerRole:
            PrimeNativeNeuralGateCorrectedProcessRole,
        outerScheduleRelativePath: String,
        outerScheduleOwnerRole:
            PrimeNativeNeuralGateCorrectedProcessRole,
        evaluationWorkerRole:
            PrimeNativeNeuralGateCorrectedProcessRole,
        candidatePair:
            PrimeNativeNeuralGateTargetFreeScheduleCandidatePair,
        retainedCapture:
            PrimeNativeNeuralGateFourSourceCaptureInventory
    ) {
        contractID =
            PrimeNativeNeuralGateTargetFreeScheduleDeliveryAuthorityContract
            .frozenV1.contractID
        self.captureIdentitySHA256 = captureIdentitySHA256
        self.sourceRootIdentity = sourceRootIdentity
        self.promptSourceBindingSHA256 = promptSourceBindingSHA256
        self.scheduleIdentitySHA256 = scheduleIdentitySHA256
        self.branch = branch
        self.invocationRole = invocationRole
        self.rawScheduleRelativePath = rawScheduleRelativePath
        self.rawScheduleOwnerRole = rawScheduleOwnerRole
        self.rawWorkerRole = rawWorkerRole
        self.outerScheduleRelativePath = outerScheduleRelativePath
        self.outerScheduleOwnerRole = outerScheduleOwnerRole
        self.evaluationWorkerRole = evaluationWorkerRole
        self.candidatePair = candidatePair
        self.retainedCapture = retainedCapture
    }

    public func validateSourceStillUnchanged() throws {
        do {
            let current = try retainedCapture.validateStillUnchanged()
            guard current == retainedCapture.inventory else {
                throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryAuthorityError
                    .retainedSourceChanged
            }
        } catch let error as
            PrimeNativeNeuralGateTargetFreeScheduleDeliveryAuthorityError
        {
            throw error
        } catch {
            throw PrimeNativeNeuralGateTargetFreeScheduleDeliveryAuthorityError
                .retainedSourceChanged
        }
    }
}

public enum PrimeNativeNeuralGateTargetFreeScheduleDeliveryAuthority {
    private typealias Error =
        PrimeNativeNeuralGateTargetFreeScheduleDeliveryAuthorityError

    public static func bind(
        capturedSource:
            PrimeNativeNeuralGateFourSourceCaptureInventory,
        branch:
            PrimeNativeNeuralGateCorrectedProcessBranch
    ) throws
        -> PrimeNativeNeuralGateCaptureBoundTargetFreeScheduleDelivery
    {
        let contract =
            PrimeNativeNeuralGateTargetFreeScheduleDeliveryAuthorityContract
            .frozenV1
        try contract.validate()
        try PrimeNativeNeuralGateReplayCaptureInventoryContract
            .frozenV1.validate()
        try PrimeNativeNeuralGateCorrectedProcessOwnershipContract
            .frozenV1.validate()
        try PrimeNativeNeuralGateCorrectedEvaluationOwnershipContract
            .frozenV1.validate()

        guard capturedSource.contractID
                == contract.captureInventoryContractID,
              capturedSource.exactWholeRootNodeClosureEstablished,
              capturedSource.singleSourceCaptureEpochEstablished,
              capturedSource.durableArtifactOriginEstablished,
              !capturedSource.processDeliveryObserved,
              !capturedSource.modelExecutionEstablished,
              !capturedSource.mechanicsPassAuthorized,
              !capturedSource.terminalReceiptAuthorized,
              capturedSource.promptRecords.rootIdentity
                == capturedSource.rootIdentity
        else {
            throw Error.retainedCaptureRejected
        }

        let before = try {
            do {
                return try capturedSource.validateStillUnchanged()
            } catch {
                throw Error.retainedSourceChanged
            }
        }()
        guard before == capturedSource.inventory else {
            throw Error.retainedSourceChanged
        }

        let schedule: PrimeNativeNeuralGateSourceBoundPromptSchedule
        let pair: PrimeNativeNeuralGateTargetFreeScheduleCandidatePair
        do {
            schedule = try PrimeNativeNeuralGateReplaySourceComposition
                .makePromptSchedule(
                    promptRecords: capturedSource.promptRecords
                )
            pair = try PrimeNativeNeuralGateReplaySourceComposition
                .makeTargetFreeScheduleCandidatePair(
                    schedule: schedule,
                    invocationRole: branch.targetFreeInvocationRole
                )
            try pair.validate()
        } catch {
            throw Error.sourceProjectionRejected
        }

        guard schedule.rootIdentity == capturedSource.rootIdentity,
              schedule.rawDelivery.rootIdentity
                == capturedSource.rootIdentity,
              schedule.outerDelivery.rootIdentity
                == capturedSource.rootIdentity,
              schedule.promptSourceBindingSHA256
                == capturedSource.promptRecords.sourceBindingSHA256,
              pair.rawSchedule.promptSourceBindingSHA256
                == capturedSource.promptRecords.sourceBindingSHA256,
              pair.outerSchedule.promptSourceBindingSHA256
                == capturedSource.promptRecords.sourceBindingSHA256,
              pair.rawSchedule.scheduleIdentitySHA256
                == schedule.schedule.scheduleIdentitySHA256,
              pair.outerSchedule.scheduleIdentitySHA256
                == schedule.schedule.scheduleIdentitySHA256
        else {
            throw Error.captureBindingMismatch
        }

        let rawSchemas =
            PrimeNativeNeuralGateCorrectedProcessOwnershipContract
            .frozenV1.roleScopedRawSchemas
        let evaluationSchemas =
            PrimeNativeNeuralGateCorrectedEvaluationOwnershipContract
            .frozenV1.roleScopedEvaluationSchemas
        guard let rawSchema = rawSchemas.first(where: {
                  $0.branch == branch
                    && $0.schemaKind == .rawSchedule
              }),
              let outerSchema = evaluationSchemas.first(where: {
                  $0.branch == branch
                    && $0.schemaKind == .outerSchedule
              }),
              rawSchema.ownerProcessRole == branch.supervisorRole,
              rawSchema.allowedReaderProcessRoles.contains(
                  branch.correctedRawWorkerRole
              ),
              outerSchema.ownerProcessRole == branch.supervisorRole,
              outerSchema.allowedReaderProcessRoles.contains(
                  branch.correctedEvaluationWorkerRole
              ),
              pair.rawSchedule.invocationRole
                == branch.targetFreeInvocationRole,
              pair.outerSchedule.invocationRole
                == branch.targetFreeInvocationRole
        else {
            throw Error.branchOwnershipMismatch
        }

        let after = try {
            do {
                return try capturedSource.validateStillUnchanged()
            } catch {
                throw Error.retainedSourceChanged
            }
        }()
        guard after == before else {
            throw Error.retainedSourceChanged
        }

        let root = capturedSource.rootIdentity
        return PrimeNativeNeuralGateCaptureBoundTargetFreeScheduleDelivery(
            captureIdentitySHA256:
                capturedSource.captureIdentitySHA256,
            sourceRootIdentity:
                PrimeNativeNeuralGateTargetFreeSourceRootIdentity(
                    deviceID: root.deviceID,
                    inode: root.inode,
                    ownerUserID: root.ownerUserID,
                    ownerGroupID: root.ownerGroupID,
                    actualMode: root.actualMode,
                    linkCount: root.linkCount,
                    modificationSeconds: root.modificationSeconds,
                    modificationNanoseconds:
                        root.modificationNanoseconds,
                    statusChangeSeconds: root.statusChangeSeconds,
                    statusChangeNanoseconds:
                        root.statusChangeNanoseconds
                ),
            promptSourceBindingSHA256:
                capturedSource.promptRecords.sourceBindingSHA256,
            scheduleIdentitySHA256:
                schedule.schedule.scheduleIdentitySHA256,
            branch: branch,
            invocationRole: branch.targetFreeInvocationRole,
            rawScheduleRelativePath: rawSchema.relativePath,
            rawScheduleOwnerRole: rawSchema.ownerProcessRole,
            rawWorkerRole: branch.correctedRawWorkerRole,
            outerScheduleRelativePath: outerSchema.relativePath,
            outerScheduleOwnerRole: outerSchema.ownerProcessRole,
            evaluationWorkerRole:
                branch.correctedEvaluationWorkerRole,
            candidatePair: pair,
            retainedCapture: capturedSource
        )
    }
}
