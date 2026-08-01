import PrimeNativeNeuralGateReplayComposition
import PrimeNativeNeuralGateReplaySourceBinding
import PrimeNativeNeuralGateTargetFreeScheduleDeliveryContracts

public enum PrimeNativeNeuralGateReplaySourceCompositionError:
    Error,
    Equatable,
    Sendable
{
    case invalidFrozenContract
    case sourceBindingRequired
    case rootIdentityMismatch
    case replicateSeedMismatch
    case scheduleBindingMismatch
    case targetFreeScheduleDeliveryRejected
    case joinedReplayRejected
}

/// Frozen conditional mechanics contract for the outer source adapter.
///
/// This contract records implemented code paths, not a claim that a Stage-B
/// artifact set, process delivery, model execution, or evaluation has been
/// observed.
public struct PrimeNativeNeuralGateReplaySourceCompositionContract:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let contractID: String
    public let sourceBindingContractID: String
    public let replayCompositionContractID: String
    public let replayCompositionContractSHA256: String
    public let rawScheduleProjectionID: String
    public let outerScheduleProjectionID: String
    public let descriptorSourceBindingImplemented: Bool
    public let sourceBoundLogitValidationImplemented: Bool
    public let incrementalPromptScheduleReconstructionImplemented:
        Bool
    public let asymmetricRoleProjectionImplemented: Bool
    public let exactSourceBoundJoinImplemented: Bool
    public let singleSourceCaptureEpochEstablished: Bool
    public let processDeliveryObserved: Bool
    public let independentPromptTargetCrosswalkImplemented:
        Bool
    public let promptContentTargetIndependenceEstablished:
        Bool
    public let modelExecutionEstablished: Bool
    public let mechanicsPassAuthorized: Bool
    public let terminalReceiptAuthorized: Bool
    public let scientificAuthorityAuthorized: Bool
    public let productAuthorityAuthorized: Bool
    public let authorityStatement: String

    public static let frozenV1 = Self(
        schemaVersion: 1,
        contractID:
            "prime_stage_b_descriptor_source_bound_schedule_delivery_v1",
        sourceBindingContractID:
            PrimeNativeNeuralGateReplaySourceBindingPolicy
            .serializationContractID,
        replayCompositionContractID:
            PrimeNativeNeuralGateReplayCompositionContract
            .frozenV1.contractID,
        replayCompositionContractSHA256:
            "75e6941913b561b6bdbd63d2e67f50962276942416bfea8a0443906d6d8ffb3e",
        rawScheduleProjectionID:
            "execution_index_prompt_tokens_prompt_text_primecpi2_binding_primecor1_correlation_no_target_v1",
        outerScheduleProjectionID:
            "execution_index_primecor1_correlation_no_prompt_no_target_v1",
        descriptorSourceBindingImplemented: true,
        sourceBoundLogitValidationImplemented: true,
        incrementalPromptScheduleReconstructionImplemented:
            true,
        asymmetricRoleProjectionImplemented: true,
        exactSourceBoundJoinImplemented: true,
        singleSourceCaptureEpochEstablished: false,
        processDeliveryObserved: false,
        independentPromptTargetCrosswalkImplemented:
            false,
        promptContentTargetIndependenceEstablished:
            false,
        modelExecutionEstablished: false,
        mechanicsPassAuthorized: false,
        terminalReceiptAuthorized: false,
        scientificAuthorityAuthorized: false,
        productAuthorityAuthorized: false,
        authorityStatement:
            "This V1 outer adapter conditionally composes sealed descriptor-rooted prompt, outer-evaluation, seed-scoped raw-execution, and lossless-logit capabilities that share one admitted PrimeArtifactRoot identity. It reconstructs the unchanged non-authorizing replay-composition V1 schedule with incremental PRIMEIRM1 digest equality, exposes a prompt-only raw projection and an index/correlation-only outer projection, and wraps the existing exact keyed join. Separate source binds do not prove a single capture epoch or complete descendant inventory, so even a successful join keeps durable origin false. It does not implement or observe interprocess delivery, independently bind prompt to expected completion, establish prompt-content target independence, execute a model, authorize mechanics PASS, issue a receipt, make a scientific claim, or authorize product use."
    )

    public func validate() throws {
        guard self == .frozenV1,
              schemaVersion == 1,
              sourceBindingContractID
                == PrimeNativeNeuralGateReplaySourceBindingPolicy
                .serializationContractID,
              replayCompositionContractID
                == PrimeNativeNeuralGateReplayCompositionContract
                .frozenV1.contractID,
              replayCompositionContractSHA256
                == "75e6941913b561b6bdbd63d2e67f50962276942416bfea8a0443906d6d8ffb3e",
              descriptorSourceBindingImplemented,
              sourceBoundLogitValidationImplemented,
              incrementalPromptScheduleReconstructionImplemented,
              asymmetricRoleProjectionImplemented,
              exactSourceBoundJoinImplemented,
              !singleSourceCaptureEpochEstablished,
              !processDeliveryObserved,
              !independentPromptTargetCrosswalkImplemented,
              !promptContentTargetIndependenceEstablished,
              !modelExecutionEstablished,
              !mechanicsPassAuthorized,
              !terminalReceiptAuthorized,
              !scientificAuthorityAuthorized,
              !productAuthorityAuthorized
        else {
            throw PrimeNativeNeuralGateReplaySourceCompositionError
                .invalidFrozenContract
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case contractID = "contract_id"
        case sourceBindingContractID =
            "source_binding_contract_id"
        case replayCompositionContractID =
            "replay_composition_contract_id"
        case replayCompositionContractSHA256 =
            "replay_composition_contract_sha256"
        case rawScheduleProjectionID =
            "raw_schedule_projection_id"
        case outerScheduleProjectionID =
            "outer_schedule_projection_id"
        case descriptorSourceBindingImplemented =
            "descriptor_source_binding_implemented"
        case sourceBoundLogitValidationImplemented =
            "source_bound_logit_validation_implemented"
        case incrementalPromptScheduleReconstructionImplemented =
            "incremental_prompt_schedule_reconstruction_implemented"
        case asymmetricRoleProjectionImplemented =
            "asymmetric_role_projection_implemented"
        case exactSourceBoundJoinImplemented =
            "exact_source_bound_join_implemented"
        case singleSourceCaptureEpochEstablished =
            "single_source_capture_epoch_established"
        case processDeliveryObserved =
            "process_delivery_observed"
        case independentPromptTargetCrosswalkImplemented =
            "independent_prompt_target_crosswalk_implemented"
        case promptContentTargetIndependenceEstablished =
            "prompt_content_target_independence_established"
        case modelExecutionEstablished =
            "model_execution_established"
        case mechanicsPassAuthorized =
            "mechanics_pass_authorized"
        case terminalReceiptAuthorized =
            "terminal_receipt_authorized"
        case scientificAuthorityAuthorized =
            "scientific_authority_authorized"
        case productAuthorityAuthorized =
            "product_authority_authorized"
        case authorityStatement = "authority_statement"
    }
}

/// Exact prompt material a future corrected raw producer may receive. There
/// is intentionally no target, row ID, split/family label, regrade material,
/// caller-selected budget, or caller-selected termination field.
public struct PrimeNativeNeuralGateRawScheduleSlot:
    Equatable,
    Sendable
{
    public let executionIndex: UInt32
    public let promptTokenIDs: [UInt16]
    public let canonicalPrompt: String
    public let primeCPI2PromptBindingSHA256: String
    public let correlationID: String

    fileprivate init(
        scheduled:
            PrimeNativeNeuralGateScheduledPrompt
    ) {
        executionIndex = scheduled.executionIndex
        promptTokenIDs =
            scheduled.promptRow.promptTokenIDs
        canonicalPrompt =
            scheduled.promptRow.canonicalPrompt
        primeCPI2PromptBindingSHA256 =
            scheduled.primeCPI2PromptBindingSHA256
        correlationID = scheduled.correlationID
    }
}

/// Exact schedule material a future outer-evaluation producer may receive.
/// Prompt content and expected completion both remain absent.
public struct PrimeNativeNeuralGateOuterScheduleSlot:
    Equatable,
    Sendable
{
    public let executionIndex: UInt32
    public let correlationID: String

    fileprivate init(
        scheduled:
            PrimeNativeNeuralGateScheduledPrompt
    ) {
        executionIndex = scheduled.executionIndex
        correlationID = scheduled.correlationID
    }
}

/// Sealed role projection. It proves construction in this target only; no
/// process delivery has been observed.
public struct PrimeNativeNeuralGateRawScheduleDelivery:
    Equatable,
    Sendable
{
    public let rootIdentity:
        PrimeNativeNeuralGateSourceRootIdentity
    public let promptSourceBindingSHA256: String
    public let scheduleIdentitySHA256: String
    public let orderedSlots:
        [PrimeNativeNeuralGateRawScheduleSlot]

    public let sourceStreamBindingEstablished = true
    public let roleProjectionImplemented = true
    public let processDeliveryObserved = false
    public let promptContentTargetIndependenceEstablished = false
    public let modelExecutionEstablished = false
    public let mechanicsPassAuthorized = false

    fileprivate init(
        rootIdentity:
            PrimeNativeNeuralGateSourceRootIdentity,
        promptSourceBindingSHA256: String,
        scheduleIdentitySHA256: String,
        orderedSlots:
            [PrimeNativeNeuralGateRawScheduleSlot]
    ) {
        self.rootIdentity = rootIdentity
        self.promptSourceBindingSHA256 =
            promptSourceBindingSHA256
        self.scheduleIdentitySHA256 =
            scheduleIdentitySHA256
        self.orderedSlots = orderedSlots
    }
}

/// Sealed outer role projection. It carries no prompt or target material and
/// records no process-delivery observation.
public struct PrimeNativeNeuralGateOuterScheduleDelivery:
    Equatable,
    Sendable
{
    public let rootIdentity:
        PrimeNativeNeuralGateSourceRootIdentity
    public let promptSourceBindingSHA256: String
    public let scheduleIdentitySHA256: String
    public let orderedSlots:
        [PrimeNativeNeuralGateOuterScheduleSlot]

    public let sourceStreamBindingEstablished = true
    public let roleProjectionImplemented = true
    public let processDeliveryObserved = false
    public let promptContentTargetIndependenceEstablished = false
    public let modelExecutionEstablished = false
    public let mechanicsPassAuthorized = false

    fileprivate init(
        rootIdentity:
            PrimeNativeNeuralGateSourceRootIdentity,
        promptSourceBindingSHA256: String,
        scheduleIdentitySHA256: String,
        orderedSlots:
            [PrimeNativeNeuralGateOuterScheduleSlot]
    ) {
        self.rootIdentity = rootIdentity
        self.promptSourceBindingSHA256 =
            promptSourceBindingSHA256
        self.scheduleIdentitySHA256 =
            scheduleIdentitySHA256
        self.orderedSlots = orderedSlots
    }
}

/// Source-bound wrapper around the unchanged, non-authorizing V1 schedule.
public struct PrimeNativeNeuralGateSourceBoundPromptSchedule:
    Equatable,
    Sendable
{
    public let contractID: String
    public let rootIdentity:
        PrimeNativeNeuralGateSourceRootIdentity
    public let promptSourceBindingSHA256: String
    public let schedule:
        PrimeNativeNeuralGatePromptSchedule
    public let rawDelivery:
        PrimeNativeNeuralGateRawScheduleDelivery
    public let outerDelivery:
        PrimeNativeNeuralGateOuterScheduleDelivery

    public let sourceStreamBindingEstablished = true
    public let durableArtifactOriginEstablished = false
    public let independentPromptTargetCrosswalkEstablished = false
    public let processDeliveryObserved = false
    public let modelExecutionEstablished = false
    public let mechanicsPassAuthorized = false
    public let terminalReceiptAuthorized = false
    public let scientificAuthorityAuthorized = false
    public let productAuthorityAuthorized = false

    fileprivate init(
        rootIdentity:
            PrimeNativeNeuralGateSourceRootIdentity,
        promptSourceBindingSHA256: String,
        schedule:
            PrimeNativeNeuralGatePromptSchedule,
        rawDelivery:
            PrimeNativeNeuralGateRawScheduleDelivery,
        outerDelivery:
            PrimeNativeNeuralGateOuterScheduleDelivery
    ) {
        contractID =
            PrimeNativeNeuralGateReplaySourceCompositionContract
            .frozenV1.contractID
        self.rootIdentity = rootIdentity
        self.promptSourceBindingSHA256 =
            promptSourceBindingSHA256
        self.schedule = schedule
        self.rawDelivery = rawDelivery
        self.outerDelivery = outerDelivery
    }
}

/// Exact source-bound join over four separately captured capabilities. Root
/// identity equality does not prove a single descendant-tree capture epoch,
/// so durable origin and all evaluation/product claims remain false.
public struct PrimeNativeNeuralGateSourceBoundJoinedReplayReplicate:
    Equatable,
    Sendable
{
    public let contractID: String
    public let rootIdentity:
        PrimeNativeNeuralGateSourceRootIdentity
    public let promptSourceBindingSHA256: String
    public let outerSourceBindingSHA256: String
    public let rawSourceBindingSHA256: String
    public let logitSourceBindingSHA256: String
    public let joinedReplay:
        PrimeNativeNeuralGateJoinedReplayReplicate

    public let exactSourceCapabilityJoinObserved = true
    public let singleSourceCaptureEpochEstablished = false
    public let durableArtifactOriginEstablished = false
    public let independentPromptTargetCrosswalkEstablished = false
    public let outerExpectedCompletionBindingEstablished = false
    public let promptContentTargetIndependenceEstablished = false
    public let processDeliveryObserved = false
    public let modelExecutionEstablished = false
    public let mechanicsPassAuthorized = false
    public let terminalReceiptAuthorized = false
    public let scientificAuthorityAuthorized = false
    public let productAuthorityAuthorized = false

    fileprivate init(
        rootIdentity:
            PrimeNativeNeuralGateSourceRootIdentity,
        promptSourceBindingSHA256: String,
        outerSourceBindingSHA256: String,
        rawSourceBindingSHA256: String,
        logitSourceBindingSHA256: String,
        joinedReplay:
            PrimeNativeNeuralGateJoinedReplayReplicate
    ) {
        contractID =
            PrimeNativeNeuralGateReplaySourceCompositionContract
            .frozenV1.contractID
        self.rootIdentity = rootIdentity
        self.promptSourceBindingSHA256 =
            promptSourceBindingSHA256
        self.outerSourceBindingSHA256 =
            outerSourceBindingSHA256
        self.rawSourceBindingSHA256 =
            rawSourceBindingSHA256
        self.logitSourceBindingSHA256 =
            logitSourceBindingSHA256
        self.joinedReplay = joinedReplay
    }
}

public enum PrimeNativeNeuralGateReplaySourceComposition {
    private typealias Error =
        PrimeNativeNeuralGateReplaySourceCompositionError

    public static func makePromptSchedule(
        promptRecords:
            PrimeNativeNeuralGateValidatedPromptRecordStream
    ) throws
        -> PrimeNativeNeuralGateSourceBoundPromptSchedule
    {
        let contract =
            PrimeNativeNeuralGateReplaySourceCompositionContract
            .frozenV1
        try contract.validate()
        guard promptRecords
                .sourceStreamBindingEstablished,
              !promptRecords
                .correctedFixtureIdentityEstablished,
              !promptRecords
                .durableArtifactOriginEstablished,
              !promptRecords.modelExecutionEstablished,
              !promptRecords.mechanicsPassAuthorized
        else {
            throw Error.sourceBindingRequired
        }
        let observations = promptRecords.records.map {
            PrimeNativeNeuralGateCanonicalPromptRecordObservation(
                promptRow: $0.row,
                canonicalRecordSHA256:
                    $0.canonicalRecordSHA256
            )
        }
        let schedule = try
            PrimeNativeNeuralGateReplayComposition
            .makePromptSchedule(
                canonicalPromptRecordObservations:
                    observations,
                expectedPromptGlobalStreamSHA256:
                    promptRecords.globalStreamSHA256
            )
        guard schedule.promptGlobalStreamSHA256
                == promptRecords.globalStreamSHA256,
              !schedule.sourceStreamBindingEstablished
        else {
            throw Error.scheduleBindingMismatch
        }
        let rawSlots = schedule.orderedPrompts.map(
            PrimeNativeNeuralGateRawScheduleSlot.init
        )
        let outerSlots = schedule.orderedPrompts.map(
            PrimeNativeNeuralGateOuterScheduleSlot.init
        )
        let raw = PrimeNativeNeuralGateRawScheduleDelivery(
            rootIdentity: promptRecords.rootIdentity,
            promptSourceBindingSHA256:
                promptRecords.sourceBindingSHA256,
            scheduleIdentitySHA256:
                schedule.scheduleIdentitySHA256,
            orderedSlots: rawSlots
        )
        let outer =
            PrimeNativeNeuralGateOuterScheduleDelivery(
                rootIdentity:
                    promptRecords.rootIdentity,
                promptSourceBindingSHA256:
                    promptRecords.sourceBindingSHA256,
                scheduleIdentitySHA256:
                    schedule.scheduleIdentitySHA256,
                orderedSlots: outerSlots
            )
        return PrimeNativeNeuralGateSourceBoundPromptSchedule(
            rootIdentity: promptRecords.rootIdentity,
            promptSourceBindingSHA256:
                promptRecords.sourceBindingSHA256,
            schedule: schedule,
            rawDelivery: raw,
            outerDelivery: outer
        )
    }

    /// Projects one sealed source-bound schedule into the narrow construct-
    /// only Encodable contract visible to future corrected process owners.
    /// The projection remains a candidate value: no bytes cross a process
    /// boundary and no execution, evaluation, PASS, or receipt authority is
    /// created.
    public static func makeTargetFreeScheduleCandidatePair(
        schedule:
            PrimeNativeNeuralGateSourceBoundPromptSchedule,
        invocationRole:
            PrimeNativeNeuralGateTargetFreeScheduleInvocationRole
    ) throws
        -> PrimeNativeNeuralGateTargetFreeScheduleCandidatePair
    {
        let deliveryContract =
            PrimeNativeNeuralGateTargetFreeScheduleDeliveryContract
            .frozenV1
        try deliveryContract.validate()
        guard schedule.sourceStreamBindingEstablished,
              !schedule.durableArtifactOriginEstablished,
              !schedule.processDeliveryObserved,
              schedule.rawDelivery.sourceStreamBindingEstablished,
              schedule.rawDelivery.roleProjectionImplemented,
              !schedule.rawDelivery.processDeliveryObserved,
              schedule.outerDelivery.sourceStreamBindingEstablished,
              schedule.outerDelivery.roleProjectionImplemented,
              !schedule.outerDelivery.processDeliveryObserved,
              schedule.rawDelivery.promptSourceBindingSHA256
                == schedule.promptSourceBindingSHA256,
              schedule.outerDelivery.promptSourceBindingSHA256
                == schedule.promptSourceBindingSHA256,
              schedule.rawDelivery.scheduleIdentitySHA256
                == schedule.schedule.scheduleIdentitySHA256,
              schedule.outerDelivery.scheduleIdentitySHA256
                == schedule.schedule.scheduleIdentitySHA256
        else {
            throw Error.scheduleBindingMismatch
        }

        do {
            let rawSlots = try schedule.rawDelivery
                .orderedSlots.map { slot in
                    try PrimeNativeNeuralGateTargetFreeRawScheduleSlot(
                        executionIndex: slot.executionIndex,
                        promptTokenIDs: slot.promptTokenIDs,
                        canonicalPrompt: slot.canonicalPrompt,
                        primeCPI2PromptBindingSHA256:
                            slot.primeCPI2PromptBindingSHA256,
                        correlationID: slot.correlationID
                    )
                }
            let outerSlots = try schedule.outerDelivery
                .orderedSlots.map { slot in
                    try PrimeNativeNeuralGateTargetFreeOuterScheduleSlot(
                        executionIndex: slot.executionIndex,
                        correlationID: slot.correlationID
                    )
                }
            let raw = try
                PrimeNativeNeuralGateTargetFreeRawScheduleCandidate(
                    invocationRole: invocationRole,
                    promptSourceBindingSHA256:
                        schedule.promptSourceBindingSHA256,
                    scheduleIdentitySHA256:
                        schedule.schedule.scheduleIdentitySHA256,
                    orderedSlots: rawSlots
                )
            let outer = try
                PrimeNativeNeuralGateTargetFreeOuterScheduleCandidate(
                    invocationRole: invocationRole,
                    promptSourceBindingSHA256:
                        schedule.promptSourceBindingSHA256,
                    scheduleIdentitySHA256:
                        schedule.schedule.scheduleIdentitySHA256,
                    orderedSlots: outerSlots
                )
            let pair = try
                PrimeNativeNeuralGateTargetFreeScheduleCandidatePair(
                    rawSchedule: raw,
                    outerSchedule: outer
                )
            guard !pair.processOwnershipEstablished,
                  !pair.processDeliveryObserved,
                  !pair.workerMaterialized,
                  !pair.modelExecutionEstablished,
                  !pair.evaluationPerformed,
                  !pair.verdictPublicationAuthorized,
                  !pair.mechanicsPassAuthorized,
                  !pair.terminalReceiptAuthorized,
                  !pair.scientificAuthorityAuthorized,
                  !pair.productAuthorityAuthorized
            else {
                throw Error.targetFreeScheduleDeliveryRejected
            }
            return pair
        } catch let error as Error {
            throw error
        } catch {
            throw Error.targetFreeScheduleDeliveryRejected
        }
    }

    public static func join(
        schedule:
            PrimeNativeNeuralGateSourceBoundPromptSchedule,
        outerRecords:
            PrimeNativeNeuralGateValidatedOuterEvaluationRecordStream,
        rawRecords:
            PrimeNativeNeuralGateValidatedRawExecutionRecordStream,
        logitSidecar:
            PrimeNativeNeuralGateSourceBoundLogitSidecar
    ) throws
        -> PrimeNativeNeuralGateSourceBoundJoinedReplayReplicate
    {
        let contract =
            PrimeNativeNeuralGateReplaySourceCompositionContract
            .frozenV1
        try contract.validate()
        guard schedule.contractID == contract.contractID,
              schedule.sourceStreamBindingEstablished,
              !schedule.durableArtifactOriginEstablished,
              !schedule.processDeliveryObserved,
              outerRecords.sourceStreamBindingEstablished,
              rawRecords.sourceStreamBindingEstablished,
              logitSidecar.sourceStreamBindingEstablished,
              !outerRecords.durableArtifactOriginEstablished,
              !rawRecords.durableArtifactOriginEstablished,
              !logitSidecar.durableArtifactOriginEstablished,
              !outerRecords.mechanicsPassAuthorized,
              !rawRecords.mechanicsPassAuthorized,
              !logitSidecar.mechanicsPassAuthorized
        else {
            throw Error.sourceBindingRequired
        }
        let rootIdentity = schedule.rootIdentity
        guard outerRecords.rootIdentity == rootIdentity,
              rawRecords.rootIdentity == rootIdentity,
              logitSidecar.rootIdentity == rootIdentity
        else {
            throw Error.rootIdentityMismatch
        }
        guard rawRecords.replicateSeed
                == logitSidecar.replicateSeed
        else {
            throw Error.replicateSeedMismatch
        }
        guard schedule.rawDelivery.rootIdentity
                == rootIdentity,
              schedule.outerDelivery.rootIdentity
                == rootIdentity,
              schedule.rawDelivery.promptSourceBindingSHA256
                == schedule.promptSourceBindingSHA256,
              schedule.outerDelivery.promptSourceBindingSHA256
                == schedule.promptSourceBindingSHA256,
              schedule.rawDelivery.scheduleIdentitySHA256
                == schedule.schedule.scheduleIdentitySHA256,
              schedule.outerDelivery.scheduleIdentitySHA256
                == schedule.schedule.scheduleIdentitySHA256,
              !schedule.rawDelivery.processDeliveryObserved,
              !schedule.outerDelivery.processDeliveryObserved
        else {
            throw Error.scheduleBindingMismatch
        }
        let joined: PrimeNativeNeuralGateJoinedReplayReplicate
        do {
            joined = try
                PrimeNativeNeuralGateReplayComposition.join(
                    schedule: schedule.schedule,
                    replicateSeed:
                        rawRecords.replicateSeed,
                    outerRows: outerRecords.records,
                    rawRows: rawRecords.records,
                    validatedLogitSidecar:
                        logitSidecar.validatedSidecar
                )
        } catch {
            throw Error.joinedReplayRejected
        }
        guard !joined
                .durableArtifactOriginEstablished,
              !joined
                .outerExpectedCompletionBindingEstablished,
              !joined.modelExecutionEstablished,
              !joined.mechanicsPassAuthorized
        else {
            throw Error.joinedReplayRejected
        }
        return PrimeNativeNeuralGateSourceBoundJoinedReplayReplicate(
            rootIdentity: rootIdentity,
            promptSourceBindingSHA256:
                schedule.promptSourceBindingSHA256,
            outerSourceBindingSHA256:
                outerRecords.sourceBindingSHA256,
            rawSourceBindingSHA256:
                rawRecords.sourceBindingSHA256,
            logitSourceBindingSHA256:
                logitSidecar.sourceBindingSHA256,
            joinedReplay: joined
        )
    }
}
