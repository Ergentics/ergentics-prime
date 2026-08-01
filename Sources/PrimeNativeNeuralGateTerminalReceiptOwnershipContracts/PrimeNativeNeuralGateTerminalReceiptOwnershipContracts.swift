import PrimeNativeNeuralGateCorrectedEvaluationOwnershipContracts
import PrimeNativeNeuralGateCorrectedProcessOwnershipContracts
import PrimeNativeNeuralGateReplayArtifactContracts

public enum PrimeNativeNeuralGateTerminalReceiptOwnershipContractError:
    Error,
    Equatable,
    Sendable
{
    case invalidFrozenContract
    case invalidReceiptOwner
    case invalidReceiptPublicationOrder
    case invalidPreReceiptInventory
}

/// The receipt-v2 envelope declaration. This schema does not represent an
/// issued receipt or evidence that any prerequisite has occurred.
public struct PrimeNativeNeuralGateTerminalReceiptEnvelopeSchema:
    Encodable,
    Equatable,
    Sendable
{
    public let schemaID: String
    public let schemaVersion: Int
    public let relativePath: String
    public let requiredFieldNames: [String]
    public let ownerProcessRole:
        PrimeNativeNeuralGateCorrectedProcessRole
    public let allowedReaderProcessRoles:
        [PrimeNativeNeuralGateCorrectedProcessRole]
    public let canonicalJSONRequired: Bool
    public let immutableNoReplaceRequired: Bool
    public let publicationMustBeLast: Bool
    public let declarativeContractOnly: Bool
    public let receiptEvidenceRepresented: Bool
    public let mechanicsPassAuthorized: Bool
    public let terminalReceiptAuthorized: Bool

    public static let frozenV2 = Self(
        schemaID:
            "prime_native_neural_gate_fixture_replay_receipt_v2",
        schemaVersion: 2,
        relativePath:
            "prime-native-neural-gate-fixture-replay-receipt.v2.json",
        requiredFieldNames: [
            "artifact_kind",
            "child_death_and_reap_observations_by_role",
            "child_execution_records_by_role",
            "corrected_evaluation_ownership_contract_id",
            "corrected_process_ownership_contract_id",
            "exact_process_roster",
            "mechanics_pass_authorized",
            "pre_receipt_artifact_inventory",
            "pre_receipt_inventory_identity_sha256",
            "probe_evaluation_result",
            "process_identifiers_by_role",
            "product_authority_authorized",
            "reaped_child_process_roles",
            "schema_version",
            "scientific_authority_authorized",
            "source_binding_v7_issued",
            "target_free_schedule_delivery_contract_id",
            "terminal_receipt_authorized",
            "verifier_evaluation_result",
        ],
        ownerProcessRole: .verifierSupervisor,
        allowedReaderProcessRoles: [
            .probeSupervisor,
            .verifierSupervisor,
        ],
        canonicalJSONRequired: true,
        immutableNoReplaceRequired: true,
        publicationMustBeLast: true,
        declarativeContractOnly: true,
        receiptEvidenceRepresented: false,
        mechanicsPassAuthorized: false,
        terminalReceiptAuthorized: false
    )

    public func validate() throws {
        guard self == .frozenV2,
              schemaVersion == 2,
              requiredFieldNames
                == requiredFieldNames.sorted(),
              Set(requiredFieldNames).count
                == requiredFieldNames.count,
              allowedReaderProcessRoles
                == allowedReaderProcessRoles.sorted(by: {
                    $0.rawValue < $1.rawValue
                }),
              Set(allowedReaderProcessRoles).count
                == allowedReaderProcessRoles.count,
              ownerProcessRole == .verifierSupervisor,
              allowedReaderProcessRoles.contains(
                  ownerProcessRole
              ),
              canonicalJSONRequired,
              immutableNoReplaceRequired,
              publicationMustBeLast,
              declarativeContractOnly,
              !receiptEvidenceRepresented,
              !mechanicsPassAuthorized,
              !terminalReceiptAuthorized
        else {
            throw PrimeNativeNeuralGateTerminalReceiptOwnershipContractError
                .invalidFrozenContract
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaID = "schema_id"
        case schemaVersion = "schema_version"
        case relativePath = "relative_path"
        case requiredFieldNames =
            "required_field_names"
        case ownerProcessRole =
            "owner_process_role"
        case allowedReaderProcessRoles =
            "allowed_reader_process_roles"
        case canonicalJSONRequired =
            "canonical_json_required"
        case immutableNoReplaceRequired =
            "immutable_no_replace_required"
        case publicationMustBeLast =
            "publication_must_be_last"
        case declarativeContractOnly =
            "declarative_contract_only"
        case receiptEvidenceRepresented =
            "receipt_evidence_represented"
        case mechanicsPassAuthorized =
            "mechanics_pass_authorized"
        case terminalReceiptAuthorized =
            "terminal_receipt_authorized"
    }
}

public struct PrimeNativeNeuralGateTerminalReceiptOwnershipContract:
    Encodable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let contractID: String
    public let correctedProcessOwnershipContractID:
        String
    public let correctedEvaluationOwnershipContractID:
        String
    public let preservedHistoricalArtifactContractID:
        String
    public let preservedHistoricalArtifactContractSHA256:
        String
    public let receiptEnvelope:
        PrimeNativeNeuralGateTerminalReceiptEnvelopeSchema
    public let uniqueReceiptOwner:
        PrimeNativeNeuralGateCorrectedProcessRole
    public let exactRequiredReapedChildRoles:
        [PrimeNativeNeuralGateCorrectedProcessRole]
    public let requiredEvaluationResultRelativePaths:
        [String]
    public let exactPreReceiptOwnedArtifactRelativePaths:
        [String]
    public let exactPreReceiptRealizedPathMetadataContentInventoryRequired:
        Bool
    public let exactTenRoleProcessRosterAndIdentifiersRequired:
        Bool
    public let allEightChildDeathAndReapObservationsRequired:
        Bool
    public let bothEvaluationResultsRequired: Bool
    public let exclusiveNoReplacePublicationRequired:
        Bool
    public let receiptPublishedLastRequired: Bool
    public let receiptOwnerIsUnique: Bool
    public let poisonedRootRetryPermitted: Bool
    public let declarativeReceiptOwnershipFrozen: Bool
    public let processDeliveryObserved: Bool
    public let executionObserved: Bool
    public let mechanicsPassAuthorized: Bool
    public let receiptPublicationObserved: Bool
    public let terminalReceiptAuthorized: Bool
    public let scientificAuthorityAuthorized: Bool
    public let productAuthorityAuthorized: Bool
    public let sourceBindingV7Issued: Bool
    public let mutationSemanticSchemasDeferred: Bool
    public let statisticsSemanticSchemaDeferred: Bool
    public let verdictSemanticSchemaDeferred: Bool
    public let mutationProducerDetectorTargetAssignmentDeferred:
        Bool
    public let authorityStatement: String

    public static let frozenV1 = Self(
        schemaVersion: 1,
        contractID:
            "prime_stage_b_terminal_receipt_v2_ownership_v1",
        correctedProcessOwnershipContractID:
            PrimeNativeNeuralGateCorrectedProcessOwnershipContract
            .frozenV1.contractID,
        correctedEvaluationOwnershipContractID:
            PrimeNativeNeuralGateCorrectedEvaluationOwnershipContract
            .frozenV1.contractID,
        preservedHistoricalArtifactContractID:
            "prime_stage_b_non_authorizing_semantic_output_namespace_v4",
        preservedHistoricalArtifactContractSHA256:
            "60e10e6c10f9ec1f30102f5b6d27be123434a163c01d82c0cc5d4520824532d1",
        receiptEnvelope: .frozenV2,
        uniqueReceiptOwner: .verifierSupervisor,
        exactRequiredReapedChildRoles:
            Self.requiredReapedChildren(),
        requiredEvaluationResultRelativePaths:
            Self.requiredEvaluationResultPaths(),
        exactPreReceiptOwnedArtifactRelativePaths:
            Self.preReceiptOwnedArtifactPaths(),
        exactPreReceiptRealizedPathMetadataContentInventoryRequired:
            true,
        exactTenRoleProcessRosterAndIdentifiersRequired:
            true,
        allEightChildDeathAndReapObservationsRequired:
            true,
        bothEvaluationResultsRequired: true,
        exclusiveNoReplacePublicationRequired:
            true,
        receiptPublishedLastRequired: true,
        receiptOwnerIsUnique: true,
        poisonedRootRetryPermitted: false,
        declarativeReceiptOwnershipFrozen: true,
        processDeliveryObserved: false,
        executionObserved: false,
        mechanicsPassAuthorized: false,
        receiptPublicationObserved: false,
        terminalReceiptAuthorized: false,
        scientificAuthorityAuthorized: false,
        productAuthorityAuthorized: false,
        sourceBindingV7Issued: false,
        mutationSemanticSchemasDeferred: true,
        statisticsSemanticSchemaDeferred: true,
        verdictSemanticSchemaDeferred: true,
        mutationProducerDetectorTargetAssignmentDeferred:
            true,
        authorityStatement:
            "This V1 ownership contract freezes the receipt-v2 schema under one verifier-supervisor owner. Exclusive no-replace publication must occur last and only after exact death-and-reap evidence for all eight children, both role-scoped evaluation results, and an exact pre-receipt realized path/metadata/content inventory. The preserved V4 identity and receipt path remain historical inputs. These Encodable-only declarations issue no receipt and establish no delivery, execution, accepted PASS, V7, scientific authority, or product authority. Mutation, statistics, verdict, and mutation producer/detector contracts remain deferred."
    )

    public func validate() throws {
        try PrimeNativeNeuralGateCorrectedProcessOwnershipContract
            .frozenV1.validate()
        try PrimeNativeNeuralGateCorrectedEvaluationOwnershipContract
            .frozenV1.validate()
        try receiptEnvelope.validate()
        let process =
            PrimeNativeNeuralGateCorrectedProcessOwnershipContract
            .frozenV1
        let evaluation =
            PrimeNativeNeuralGateCorrectedEvaluationOwnershipContract
            .frozenV1
        try Self.validateReceiptSafety(
            uniqueReceiptOwner: uniqueReceiptOwner,
            envelopeOwner:
                receiptEnvelope.ownerProcessRole,
            envelopeAllowedReaders:
                receiptEnvelope.allowedReaderProcessRoles,
            exactRequiredReapedChildRoles:
                exactRequiredReapedChildRoles,
            exactPreReceiptOwnedArtifactRelativePaths:
                exactPreReceiptOwnedArtifactRelativePaths,
            receiptRelativePath:
                receiptEnvelope.relativePath,
            poisonedRootRetryPermitted:
                poisonedRootRetryPermitted
        )
        guard self == .frozenV1,
              schemaVersion == 1,
              correctedProcessOwnershipContractID
                == process.contractID,
              correctedEvaluationOwnershipContractID
                == evaluation.contractID,
              preservedHistoricalArtifactContractID
                == process
                .preservedHistoricalArtifactContractID,
              preservedHistoricalArtifactContractSHA256
                == process
                .preservedHistoricalArtifactContractSHA256,
              receiptEnvelope.relativePath
                == process
                .preservedReplacementReceiptRelativePath,
              uniqueReceiptOwner
                == .verifierSupervisor,
              receiptEnvelope.ownerProcessRole
                == uniqueReceiptOwner,
              exactRequiredReapedChildRoles
                == Self.requiredReapedChildren(),
              exactRequiredReapedChildRoles.count
                == 8,
              Set(exactRequiredReapedChildRoles).count
                == 8,
              exactRequiredReapedChildRoles
                .allSatisfy({
                    $0.kind != .supervisor
                }),
              requiredEvaluationResultRelativePaths
                == Self.requiredEvaluationResultPaths(),
              requiredEvaluationResultRelativePaths
                .count == 2,
              exactPreReceiptOwnedArtifactRelativePaths
                == Self.preReceiptOwnedArtifactPaths(),
              Set(exactPreReceiptOwnedArtifactRelativePaths)
                .count
                == exactPreReceiptOwnedArtifactRelativePaths
                .count,
              !exactPreReceiptOwnedArtifactRelativePaths
                .contains(receiptEnvelope.relativePath),
              exactPreReceiptRealizedPathMetadataContentInventoryRequired,
              exactTenRoleProcessRosterAndIdentifiersRequired,
              process
                .allProcessIdentifiersPairwiseDistinctRequired,
              allEightChildDeathAndReapObservationsRequired,
              bothEvaluationResultsRequired,
              exclusiveNoReplacePublicationRequired,
              receiptPublishedLastRequired,
              receiptOwnerIsUnique,
              !poisonedRootRetryPermitted,
              declarativeReceiptOwnershipFrozen,
              !processDeliveryObserved,
              !executionObserved,
              !mechanicsPassAuthorized,
              !receiptPublicationObserved,
              !terminalReceiptAuthorized,
              !scientificAuthorityAuthorized,
              !productAuthorityAuthorized,
              !sourceBindingV7Issued,
              mutationSemanticSchemasDeferred,
              statisticsSemanticSchemaDeferred,
              verdictSemanticSchemaDeferred,
              mutationProducerDetectorTargetAssignmentDeferred
        else {
            throw PrimeNativeNeuralGateTerminalReceiptOwnershipContractError
                .invalidFrozenContract
        }
    }

    public static func requiredReapedChildren()
        -> [PrimeNativeNeuralGateCorrectedProcessRole]
    {
        return [
            .probeSwiftPackageDescribeChild,
            .verifierSwiftPackageDescribeChild,
            .probeHistoricalWorker,
            .verifierHistoricalWorker,
            .probeCorrectedRawWorker,
            .verifierCorrectedRawWorker,
            .probeCorrectedEvaluationWorker,
            .verifierCorrectedEvaluationWorker,
        ]
    }

    public static func requiredEvaluationResultPaths()
        -> [String]
    {
        return [
            "neural-gate-replay/corrected/evaluation/probe/worker-result.v1.json",
            "neural-gate-replay/corrected/evaluation/verifier/worker-result.v1.json",
        ]
    }

    public static func preReceiptOwnedArtifactPaths()
        -> [String]
    {
        return [
            "neural-gate-replay/corrected/evaluation/probe/outer-delivery.v1.json",
            "neural-gate-replay/corrected/evaluation/probe/worker-execution.v1.json",
            "neural-gate-replay/corrected/evaluation/probe/worker-process-binding.v1.json",
            "neural-gate-replay/corrected/evaluation/probe/worker-request.v1.json",
            "neural-gate-replay/corrected/evaluation/probe/worker-result.v1.json",
            "neural-gate-replay/corrected/evaluation/verifier/outer-delivery.v1.json",
            "neural-gate-replay/corrected/evaluation/verifier/worker-execution.v1.json",
            "neural-gate-replay/corrected/evaluation/verifier/worker-process-binding.v1.json",
            "neural-gate-replay/corrected/evaluation/verifier/worker-request.v1.json",
            "neural-gate-replay/corrected/evaluation/verifier/worker-result.v1.json",
            "neural-gate-replay/corrected/raw/probe/schedule-delivery.v1.json",
            "neural-gate-replay/corrected/raw/probe/worker-execution.v1.json",
            "neural-gate-replay/corrected/raw/probe/worker-process-binding.v1.json",
            "neural-gate-replay/corrected/raw/probe/worker-request.v1.json",
            "neural-gate-replay/corrected/raw/probe/worker-result.v1.json",
            "neural-gate-replay/corrected/raw/verifier/schedule-delivery.v1.json",
            "neural-gate-replay/corrected/raw/verifier/worker-execution.v1.json",
            "neural-gate-replay/corrected/raw/verifier/worker-process-binding.v1.json",
            "neural-gate-replay/corrected/raw/verifier/worker-request.v1.json",
            "neural-gate-replay/corrected/raw/verifier/worker-result.v1.json",
        ]
    }

    static func validateReceiptSafety(
        uniqueReceiptOwner:
            PrimeNativeNeuralGateCorrectedProcessRole,
        envelopeOwner:
            PrimeNativeNeuralGateCorrectedProcessRole,
        envelopeAllowedReaders:
            [PrimeNativeNeuralGateCorrectedProcessRole],
        exactRequiredReapedChildRoles:
            [PrimeNativeNeuralGateCorrectedProcessRole],
        exactPreReceiptOwnedArtifactRelativePaths:
            [String],
        receiptRelativePath: String,
        poisonedRootRetryPermitted: Bool
    ) throws {
        guard uniqueReceiptOwner == .verifierSupervisor,
              envelopeOwner == .verifierSupervisor,
              envelopeAllowedReaders == [
                  .probeSupervisor,
                  .verifierSupervisor,
              ]
        else {
            throw PrimeNativeNeuralGateTerminalReceiptOwnershipContractError
                .invalidReceiptOwner
        }
        guard exactRequiredReapedChildRoles
                == requiredReapedChildren(),
              exactRequiredReapedChildRoles.count == 8,
              Set(exactRequiredReapedChildRoles).count == 8,
              exactRequiredReapedChildRoles.allSatisfy({
                  $0.kind != .supervisor
              }),
              !poisonedRootRetryPermitted
        else {
            throw PrimeNativeNeuralGateTerminalReceiptOwnershipContractError
                .invalidReceiptPublicationOrder
        }
        guard exactPreReceiptOwnedArtifactRelativePaths
                == preReceiptOwnedArtifactPaths(),
              Set(
                  exactPreReceiptOwnedArtifactRelativePaths
              ).count
                == exactPreReceiptOwnedArtifactRelativePaths
                .count,
              !exactPreReceiptOwnedArtifactRelativePaths
                .contains(receiptRelativePath)
        else {
            throw PrimeNativeNeuralGateTerminalReceiptOwnershipContractError
                .invalidPreReceiptInventory
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case contractID = "contract_id"
        case correctedProcessOwnershipContractID =
            "corrected_process_ownership_contract_id"
        case correctedEvaluationOwnershipContractID =
            "corrected_evaluation_ownership_contract_id"
        case preservedHistoricalArtifactContractID =
            "preserved_historical_artifact_contract_id"
        case preservedHistoricalArtifactContractSHA256 =
            "preserved_historical_artifact_contract_sha256"
        case receiptEnvelope = "receipt_envelope"
        case uniqueReceiptOwner =
            "unique_receipt_owner"
        case exactRequiredReapedChildRoles =
            "exact_required_reaped_child_roles"
        case requiredEvaluationResultRelativePaths =
            "required_evaluation_result_relative_paths"
        case exactPreReceiptOwnedArtifactRelativePaths =
            "exact_pre_receipt_owned_artifact_relative_paths"
        case exactPreReceiptRealizedPathMetadataContentInventoryRequired =
            "exact_pre_receipt_realized_path_metadata_content_inventory_required"
        case exactTenRoleProcessRosterAndIdentifiersRequired =
            "exact_ten_role_process_roster_and_identifiers_required"
        case allEightChildDeathAndReapObservationsRequired =
            "all_eight_child_death_and_reap_observations_required"
        case bothEvaluationResultsRequired =
            "both_evaluation_results_required"
        case exclusiveNoReplacePublicationRequired =
            "exclusive_no_replace_publication_required"
        case receiptPublishedLastRequired =
            "receipt_published_last_required"
        case receiptOwnerIsUnique =
            "receipt_owner_is_unique"
        case poisonedRootRetryPermitted =
            "poisoned_root_retry_permitted"
        case declarativeReceiptOwnershipFrozen =
            "declarative_receipt_ownership_frozen"
        case processDeliveryObserved =
            "process_delivery_observed"
        case executionObserved =
            "execution_observed"
        case mechanicsPassAuthorized =
            "mechanics_pass_authorized"
        case receiptPublicationObserved =
            "receipt_publication_observed"
        case terminalReceiptAuthorized =
            "terminal_receipt_authorized"
        case scientificAuthorityAuthorized =
            "scientific_authority_authorized"
        case productAuthorityAuthorized =
            "product_authority_authorized"
        case sourceBindingV7Issued =
            "source_binding_v7_issued"
        case mutationSemanticSchemasDeferred =
            "mutation_semantic_schemas_deferred"
        case statisticsSemanticSchemaDeferred =
            "statistics_semantic_schema_deferred"
        case verdictSemanticSchemaDeferred =
            "verdict_semantic_schema_deferred"
        case mutationProducerDetectorTargetAssignmentDeferred =
            "mutation_producer_detector_target_assignment_deferred"
        case authorityStatement = "authority_statement"
    }
}
