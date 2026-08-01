import PrimeNativeNeuralGateCorrectedProcessOwnershipContracts
import PrimeNativeNeuralGateReplayArtifactContracts

public enum PrimeNativeNeuralGateCorrectedEvaluationOwnershipContractError:
    Error,
    Equatable,
    Sendable
{
    case invalidFrozenContract
    case invalidEvaluationOwner(String)
}

public struct PrimeNativeNeuralGateCorrectedEvaluationOwnershipContract:
    Encodable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let contractID: String
    public let correctedProcessOwnershipContractID:
        String
    public let preservedHistoricalArtifactContractID:
        String
    public let preservedHistoricalArtifactContractSHA256:
        String
    public let evaluationWorkerRoles:
        [PrimeNativeNeuralGateCorrectedProcessRole]
    public let requiredRawResultRelativePaths:
        [String]
    public let roleScopedEvaluationSchemas:
        [PrimeNativeNeuralGateRoleScopedSchemaOwnership]
    public let distinctEvaluationProcessesRequired:
        Bool
    public let targetMaterialExcludedFromOuterSchedule:
        Bool
    public let rawWorkersCannotOwnEvaluationSchemas:
        Bool
    public let evaluationResultCanAuthorizeMechanicsPass:
        Bool
    public let declarativeSchemaOwnershipFrozen: Bool
    public let processDeliveryObserved: Bool
    public let executionObserved: Bool
    public let mechanicsPassAuthorized: Bool
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
            "prime_stage_b_corrected_evaluation_ownership_v1",
        correctedProcessOwnershipContractID:
            PrimeNativeNeuralGateCorrectedProcessOwnershipContract
            .frozenV1.contractID,
        preservedHistoricalArtifactContractID:
            "prime_stage_b_non_authorizing_semantic_output_namespace_v4",
        preservedHistoricalArtifactContractSHA256:
            "60e10e6c10f9ec1f30102f5b6d27be123434a163c01d82c0cc5d4520824532d1",
        evaluationWorkerRoles: [
            .probeCorrectedEvaluationWorker,
            .verifierCorrectedEvaluationWorker,
        ],
        requiredRawResultRelativePaths:
            Self.requiredRawResultPaths(),
        roleScopedEvaluationSchemas:
            Self.makeRoleScopedEvaluationSchemas(),
        distinctEvaluationProcessesRequired:
            true,
        targetMaterialExcludedFromOuterSchedule:
            true,
        rawWorkersCannotOwnEvaluationSchemas:
            true,
        evaluationResultCanAuthorizeMechanicsPass:
            false,
        declarativeSchemaOwnershipFrozen: true,
        processDeliveryObserved: false,
        executionObserved: false,
        mechanicsPassAuthorized: false,
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
            "This V1 contract assigns disjoint probe and verifier corrected-evaluation workers and freezes role-scoped target-free outer schedule, request, process-binding, execution, and result schema ownership. Evaluation workers consume only their branch-scoped corrected raw result and separately admitted evaluation authority; the outer schedule carries no target. These Encodable-only declarations are not process evidence: no delivery, execution, accepted result, PASS, receipt, V7, scientific claim, or product authority is observed or authorized. Mutation, statistics, verdict, and mutation producer/detector contracts remain deferred."
    )

    public func validate() throws {
        try PrimeNativeNeuralGateCorrectedProcessOwnershipContract
            .frozenV1.validate()
        let process =
            PrimeNativeNeuralGateCorrectedProcessOwnershipContract
            .frozenV1
        let rosterRoles = Set(
            process.processRoster.map(\.role)
        )
        let evaluationOwners =
            roleScopedEvaluationSchemas
            .filter {
                $0.schemaKind == .workerProcessBinding
                    || $0.schemaKind == .workerResult
            }
            .map(\.ownerProcessRole)
        guard self == .frozenV1,
              schemaVersion == 1,
              correctedProcessOwnershipContractID
                == process.contractID,
              preservedHistoricalArtifactContractID
                == process
                .preservedHistoricalArtifactContractID,
              preservedHistoricalArtifactContractSHA256
                == process
                .preservedHistoricalArtifactContractSHA256,
              evaluationWorkerRoles == [
                  .probeCorrectedEvaluationWorker,
                  .verifierCorrectedEvaluationWorker,
              ],
              Set(evaluationWorkerRoles).count == 2,
              evaluationWorkerRoles.allSatisfy({
                  rosterRoles.contains($0)
                      && $0.kind
                        == .correctedEvaluationWorker
              }),
              requiredRawResultRelativePaths
                == Self.requiredRawResultPaths(),
              roleScopedEvaluationSchemas
                == Self.makeRoleScopedEvaluationSchemas(),
              roleScopedEvaluationSchemas.count == 10,
              Set(
                  roleScopedEvaluationSchemas
                    .map(\.relativePath)
              ).count == 10,
              Set(evaluationOwners)
                == Set(evaluationWorkerRoles),
              distinctEvaluationProcessesRequired,
              targetMaterialExcludedFromOuterSchedule,
              rawWorkersCannotOwnEvaluationSchemas,
              !evaluationResultCanAuthorizeMechanicsPass,
              declarativeSchemaOwnershipFrozen,
              !processDeliveryObserved,
              !executionObserved,
              !mechanicsPassAuthorized,
              !terminalReceiptAuthorized,
              !scientificAuthorityAuthorized,
              !productAuthorityAuthorized,
              !sourceBindingV7Issued,
              mutationSemanticSchemasDeferred,
              statisticsSemanticSchemaDeferred,
              verdictSemanticSchemaDeferred,
              mutationProducerDetectorTargetAssignmentDeferred
        else {
            throw PrimeNativeNeuralGateCorrectedEvaluationOwnershipContractError
                .invalidFrozenContract
        }
        try roleScopedEvaluationSchemas.forEach {
            try $0.validateDeclarativeOwnership()
        }
        try Self.validateEvaluationSchemaOwnership(
            roleScopedEvaluationSchemas
        )
    }

    public static func expectedEvaluationOwner(
        branch:
            PrimeNativeNeuralGateCorrectedProcessBranch,
        schemaKind:
            PrimeNativeNeuralGateCorrectedSchemaKind
    ) -> PrimeNativeNeuralGateCorrectedProcessRole {
        let supervisor: PrimeNativeNeuralGateCorrectedProcessRole =
            branch == .probe
                ? .probeSupervisor
                : .verifierSupervisor
        let worker: PrimeNativeNeuralGateCorrectedProcessRole =
            branch == .probe
                ? .probeCorrectedEvaluationWorker
                : .verifierCorrectedEvaluationWorker
        switch schemaKind {
        case .outerSchedule,
             .workerRequest,
             .workerExecution:
            return supervisor
        case .workerProcessBinding,
             .workerResult:
            return worker
        case .rawSchedule:
            return supervisor
        }
    }

    public static func makeRoleScopedEvaluationSchemas()
        -> [PrimeNativeNeuralGateRoleScopedSchemaOwnership]
    {
        return PrimeNativeNeuralGateCorrectedProcessBranch
            .allCases.flatMap { branch in
                let prefix =
                    "neural-gate-replay/corrected/evaluation/\(branch.rawValue)"
                return [
                    schema(
                        "prime_stage_b_corrected_outer_schedule_delivery_v1",
                        .outerSchedule,
                        branch,
                        "\(prefix)/outer-delivery.v1.json"
                    ),
                    schema(
                        "prime_stage_b_corrected_evaluation_worker_request_v1",
                        .workerRequest,
                        branch,
                        "\(prefix)/worker-request.v1.json"
                    ),
                    schema(
                        "prime_stage_b_corrected_evaluation_worker_process_binding_v1",
                        .workerProcessBinding,
                        branch,
                        "\(prefix)/worker-process-binding.v1.json"
                    ),
                    schema(
                        "prime_stage_b_corrected_evaluation_worker_execution_v1",
                        .workerExecution,
                        branch,
                        "\(prefix)/worker-execution.v1.json"
                    ),
                    schema(
                        "prime_stage_b_corrected_evaluation_worker_result_v1",
                        .workerResult,
                        branch,
                        "\(prefix)/worker-result.v1.json"
                    ),
                ]
            }

        func schema(
            _ schemaID: String,
            _ kind:
                PrimeNativeNeuralGateCorrectedSchemaKind,
            _ branch:
                PrimeNativeNeuralGateCorrectedProcessBranch,
            _ path: String
        ) -> PrimeNativeNeuralGateRoleScopedSchemaOwnership {
            return PrimeNativeNeuralGateRoleScopedSchemaOwnership(
                schemaID: schemaID,
                schemaKind: kind,
                branch: branch,
                relativePath: path,
                requiredFieldNames:
                    evaluationRequiredFieldNames(
                        for: kind
                    ),
                ownerProcessRole:
                    expectedEvaluationOwner(
                        branch: branch,
                        schemaKind: kind
                    ),
                allowedReaderProcessRoles:
                    evaluationAllowedReaders(
                        branch: branch,
                        schemaKind: kind
                    )
            )
        }
    }

    public static func evaluationRequiredFieldNames(
        for schemaKind:
            PrimeNativeNeuralGateCorrectedSchemaKind
    ) -> [String] {
        let fields: [String]
        switch schemaKind {
        case .outerSchedule:
            fields = [
                "artifact_kind",
                "capture_identity_sha256",
                "invocation_role",
                "ordered_slot_count",
                "ordered_slots_sha256",
                "schedule_identity_sha256",
                "schema_version",
                "source_root_identity",
                "target_free_schedule_delivery_contract_id",
            ]
        case .workerRequest:
            fields = [
                "artifact_kind",
                "compiled_source_closure",
                "corrected_fixture_identity_sha256",
                "corrected_raw_worker_result",
                "invocation_role",
                "outer_schedule_delivery",
                "prime_source_snapshot",
                "prompt_target_crosswalk_binding",
                "required_output_relative_paths",
                "schema_version",
                "sealed_worker_executable",
                "target_free_schedule_delivery_contract_id",
            ]
        case .workerProcessBinding:
            fields = [
                "artifact_kind",
                "build_configuration",
                "captured_by_same_process",
                "compiled_source_closure",
                "embedded_source_identity_sha256",
                "invocation_role",
                "prime_source_snapshot",
                "process_identifier",
                "request",
                "running_worker_executable",
                "schema_version",
                "sealed_worker_executable",
                "source_identity_sha256",
                "supervisor_process_identifier",
            ]
        case .workerExecution:
            fields = [
                "accepted_worker_result",
                "artifact_kind",
                "invocation_role",
                "request",
                "running_worker_executable",
                "schema_version",
                "sealed_worker_executable",
                "standard_error_byte_count",
                "standard_error_sha256",
                "standard_output_byte_count",
                "standard_output_sha256",
                "worker_death_observed",
                "worker_process_binding",
                "worker_process_identifier",
                "worker_reaped",
                "worker_result",
                "worker_termination",
            ]
        case .workerResult:
            fields = [
                "artifact_kind",
                "corrected_raw_worker_result",
                "evaluation_observation_artifact_inventory",
                "invocation_role",
                "mechanics_pass_authorized",
                "outer_schedule_identity_sha256",
                "pre_result_produced_artifact_inventory",
                "prompt_target_crosswalk_binding",
                "request",
                "schema_version",
                "terminal_receipt_authorized",
                "worker_process_binding",
                "worker_process_identifier",
            ]
        case .rawSchedule:
            fields = []
        }
        return fields.sorted()
    }

    public static func evaluationAllowedReaders(
        branch:
            PrimeNativeNeuralGateCorrectedProcessBranch,
        schemaKind:
            PrimeNativeNeuralGateCorrectedSchemaKind
    ) -> [PrimeNativeNeuralGateCorrectedProcessRole] {
        let supervisor: PrimeNativeNeuralGateCorrectedProcessRole =
            branch == .probe
                ? .probeSupervisor
                : .verifierSupervisor
        let worker: PrimeNativeNeuralGateCorrectedProcessRole =
            branch == .probe
                ? .probeCorrectedEvaluationWorker
                : .verifierCorrectedEvaluationWorker
        let values:
            [PrimeNativeNeuralGateCorrectedProcessRole]
        switch schemaKind {
        case .outerSchedule,
             .workerRequest,
             .workerProcessBinding:
            values = [
                supervisor,
                worker,
                .verifierSupervisor,
            ]
        case .workerExecution:
            values = [
                supervisor,
                .verifierSupervisor,
            ]
        case .workerResult:
            values = [
                supervisor,
                worker,
                .verifierSupervisor,
            ]
        case .rawSchedule:
            values = []
        }
        return Array(Set(values)).sorted {
            $0.rawValue < $1.rawValue
        }
    }

    public static func requiredRawResultPaths()
        -> [String]
    {
        return [
            "neural-gate-replay/corrected/raw/probe/worker-result.v1.json",
            "neural-gate-replay/corrected/raw/verifier/worker-result.v1.json",
        ]
    }

    static func validateEvaluationSchemaOwnership(
        _ roleScopedEvaluationSchemas:
            [PrimeNativeNeuralGateRoleScopedSchemaOwnership]
    )
        throws
    {
        for branch in
            PrimeNativeNeuralGateCorrectedProcessBranch
            .allCases
        {
            let schemas = roleScopedEvaluationSchemas
                .filter { $0.branch == branch }
            let expectedKinds:
                [PrimeNativeNeuralGateCorrectedSchemaKind] =
                [
                    .outerSchedule,
                    .workerRequest,
                    .workerProcessBinding,
                    .workerExecution,
                    .workerResult,
                ]
            guard schemas.map(\.schemaKind)
                    == expectedKinds,
                  schemas.allSatisfy({ schema in
                      schema.ownerProcessRole
                        == Self.expectedEvaluationOwner(
                            branch: branch,
                            schemaKind:
                                schema.schemaKind
                        )
                          && schema.ownerProcessRole.kind
                            != .correctedRawWorker
                          && schema.requiredFieldNames
                            == Self.evaluationRequiredFieldNames(
                                for: schema.schemaKind
                            )
                          && schema.allowedReaderProcessRoles
                            == Self.evaluationAllowedReaders(
                                branch: branch,
                                schemaKind:
                                    schema.schemaKind
                            )
                  })
            else {
                throw PrimeNativeNeuralGateCorrectedEvaluationOwnershipContractError
                    .invalidEvaluationOwner(
                        branch.rawValue
                    )
            }
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case contractID = "contract_id"
        case correctedProcessOwnershipContractID =
            "corrected_process_ownership_contract_id"
        case preservedHistoricalArtifactContractID =
            "preserved_historical_artifact_contract_id"
        case preservedHistoricalArtifactContractSHA256 =
            "preserved_historical_artifact_contract_sha256"
        case evaluationWorkerRoles =
            "evaluation_worker_roles"
        case requiredRawResultRelativePaths =
            "required_raw_result_relative_paths"
        case roleScopedEvaluationSchemas =
            "role_scoped_evaluation_schemas"
        case distinctEvaluationProcessesRequired =
            "distinct_evaluation_processes_required"
        case targetMaterialExcludedFromOuterSchedule =
            "target_material_excluded_from_outer_schedule"
        case rawWorkersCannotOwnEvaluationSchemas =
            "raw_workers_cannot_own_evaluation_schemas"
        case evaluationResultCanAuthorizeMechanicsPass =
            "evaluation_result_can_authorize_mechanics_pass"
        case declarativeSchemaOwnershipFrozen =
            "declarative_schema_ownership_frozen"
        case processDeliveryObserved =
            "process_delivery_observed"
        case executionObserved =
            "execution_observed"
        case mechanicsPassAuthorized =
            "mechanics_pass_authorized"
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
