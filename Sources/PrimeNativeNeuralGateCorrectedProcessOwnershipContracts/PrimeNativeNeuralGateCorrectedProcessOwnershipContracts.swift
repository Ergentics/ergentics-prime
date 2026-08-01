import PrimeNativeNeuralGateReplayArtifactContracts
import PrimeNativeNeuralGateTargetFreeScheduleDeliveryContracts

public enum PrimeNativeNeuralGateCorrectedProcessOwnershipContractError:
    Error,
    Equatable,
    Sendable
{
    case invalidFrozenContract
    case invalidProcessRoster
    case invalidSchemaOwnership(String)
}

public enum PrimeNativeNeuralGateCorrectedProcessBranch:
    String,
    Encodable,
    CaseIterable,
    Equatable,
    Sendable
{
    case probe
    case verifier

    public var targetFreeInvocationRole:
        PrimeNativeNeuralGateTargetFreeScheduleInvocationRole
    {
        switch self {
        case .probe:
            .probe
        case .verifier:
            .verifier
        }
    }

    public var supervisorRole:
        PrimeNativeNeuralGateCorrectedProcessRole
    {
        switch self {
        case .probe:
            .probeSupervisor
        case .verifier:
            .verifierSupervisor
        }
    }

    public var correctedRawWorkerRole:
        PrimeNativeNeuralGateCorrectedProcessRole
    {
        switch self {
        case .probe:
            .probeCorrectedRawWorker
        case .verifier:
            .verifierCorrectedRawWorker
        }
    }

    public var correctedEvaluationWorkerRole:
        PrimeNativeNeuralGateCorrectedProcessRole
    {
        switch self {
        case .probe:
            .probeCorrectedEvaluationWorker
        case .verifier:
            .verifierCorrectedEvaluationWorker
        }
    }
}

public enum PrimeNativeNeuralGateCorrectedProcessKind:
    String,
    Encodable,
    CaseIterable,
    Equatable,
    Sendable
{
    case supervisor
    case swiftPackageDescribeChild =
        "swift_package_describe_child"
    case historicalWorker = "historical_worker"
    case correctedRawWorker =
        "corrected_raw_worker"
    case correctedEvaluationWorker =
        "corrected_evaluation_worker"
}

/// Replacement Stage-B process roles. These cases intentionally do not
/// extend any historical CaseIterable role domain.
public enum PrimeNativeNeuralGateCorrectedProcessRole:
    String,
    Encodable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case probeSupervisor = "probe_supervisor"
    case verifierSupervisor = "verifier_supervisor"
    case probeSwiftPackageDescribeChild =
        "probe_swift_package_describe_child"
    case verifierSwiftPackageDescribeChild =
        "verifier_swift_package_describe_child"
    case probeHistoricalWorker =
        "probe_historical_worker"
    case verifierHistoricalWorker =
        "verifier_historical_worker"
    case probeCorrectedRawWorker =
        "probe_corrected_raw_worker"
    case verifierCorrectedRawWorker =
        "verifier_corrected_raw_worker"
    case probeCorrectedEvaluationWorker =
        "probe_corrected_evaluation_worker"
    case verifierCorrectedEvaluationWorker =
        "verifier_corrected_evaluation_worker"

    public var branch:
        PrimeNativeNeuralGateCorrectedProcessBranch
    {
        switch self {
        case .probeSupervisor,
             .probeSwiftPackageDescribeChild,
             .probeHistoricalWorker,
             .probeCorrectedRawWorker,
             .probeCorrectedEvaluationWorker:
            .probe
        case .verifierSupervisor,
             .verifierSwiftPackageDescribeChild,
             .verifierHistoricalWorker,
             .verifierCorrectedRawWorker,
             .verifierCorrectedEvaluationWorker:
            .verifier
        }
    }

    public var kind:
        PrimeNativeNeuralGateCorrectedProcessKind
    {
        switch self {
        case .probeSupervisor,
             .verifierSupervisor:
            .supervisor
        case .probeSwiftPackageDescribeChild,
             .verifierSwiftPackageDescribeChild:
            .swiftPackageDescribeChild
        case .probeHistoricalWorker,
             .verifierHistoricalWorker:
            .historicalWorker
        case .probeCorrectedRawWorker,
             .verifierCorrectedRawWorker:
            .correctedRawWorker
        case .probeCorrectedEvaluationWorker,
             .verifierCorrectedEvaluationWorker:
            .correctedEvaluationWorker
        }
    }

    public var supervisorRole: Self? {
        switch kind {
        case .supervisor:
            nil
        case .swiftPackageDescribeChild,
             .historicalWorker,
             .correctedRawWorker,
             .correctedEvaluationWorker:
            branch == .probe
                ? .probeSupervisor
                : .verifierSupervisor
        }
    }
}

public struct PrimeNativeNeuralGateCorrectedProcessRosterEntry:
    Encodable,
    Equatable,
    Sendable
{
    public let role:
        PrimeNativeNeuralGateCorrectedProcessRole
    public let branch:
        PrimeNativeNeuralGateCorrectedProcessBranch
    public let kind:
        PrimeNativeNeuralGateCorrectedProcessKind
    public let supervisorRole:
        PrimeNativeNeuralGateCorrectedProcessRole?
    public let distinctPositiveProcessIdentifierRequired:
        Bool
    public let deathObservedBeforeContinuationRequired:
        Bool
    public let exactOnceReapBeforeReceiptRequired:
        Bool
    public let processMaterialized: Bool
    public let executionObserved: Bool

    public init(
        role:
            PrimeNativeNeuralGateCorrectedProcessRole
    ) {
        self.role = role
        branch = role.branch
        kind = role.kind
        supervisorRole = role.supervisorRole
        distinctPositiveProcessIdentifierRequired =
            true
        deathObservedBeforeContinuationRequired =
            role.kind != .supervisor
        exactOnceReapBeforeReceiptRequired =
            role.kind != .supervisor
        processMaterialized = false
        executionObserved = false
    }

    private enum CodingKeys: String, CodingKey {
        case role
        case branch
        case kind
        case supervisorRole = "supervisor_role"
        case distinctPositiveProcessIdentifierRequired =
            "distinct_positive_process_identifier_required"
        case deathObservedBeforeContinuationRequired =
            "death_observed_before_continuation_required"
        case exactOnceReapBeforeReceiptRequired =
            "exact_once_reap_before_receipt_required"
        case processMaterialized =
            "process_materialized"
        case executionObserved =
            "execution_observed"
    }
}

public enum PrimeNativeNeuralGateCorrectedSchemaKind:
    String,
    Encodable,
    CaseIterable,
    Equatable,
    Sendable
{
    case rawSchedule = "raw_schedule"
    case workerRequest = "worker_request"
    case workerProcessBinding =
        "worker_process_binding"
    case workerExecution = "worker_execution"
    case workerResult = "worker_result"
    case outerSchedule = "outer_schedule"
}

/// A frozen schema/owner declaration. It is not a serialized worker record
/// and cannot stand in for process, delivery, execution, or publication
/// evidence.
public struct PrimeNativeNeuralGateRoleScopedSchemaOwnership:
    Encodable,
    Equatable,
    Sendable
{
    public let schemaID: String
    public let schemaVersion: Int
    public let schemaKind:
        PrimeNativeNeuralGateCorrectedSchemaKind
    public let branch:
        PrimeNativeNeuralGateCorrectedProcessBranch
    public let relativePath: String
    public let requiredFieldNames: [String]
    public let ownerProcessRole:
        PrimeNativeNeuralGateCorrectedProcessRole
    public let allowedReaderProcessRoles:
        [PrimeNativeNeuralGateCorrectedProcessRole]
    public let canonicalJSONRequired: Bool
    public let immutableNoReplaceRequired: Bool
    public let declarativeContractOnly: Bool
    public let processEvidenceRepresented: Bool
    public let deliveryObserved: Bool
    public let executionObserved: Bool
    public let mechanicsPassAuthorized: Bool
    public let terminalReceiptAuthorized: Bool

    public init(
        schemaID: String,
        schemaKind:
            PrimeNativeNeuralGateCorrectedSchemaKind,
        branch:
            PrimeNativeNeuralGateCorrectedProcessBranch,
        relativePath: String,
        requiredFieldNames: [String],
        ownerProcessRole:
            PrimeNativeNeuralGateCorrectedProcessRole,
        allowedReaderProcessRoles:
            [PrimeNativeNeuralGateCorrectedProcessRole]
    ) {
        self.schemaID = schemaID
        schemaVersion = 1
        self.schemaKind = schemaKind
        self.branch = branch
        self.relativePath = relativePath
        self.requiredFieldNames =
            requiredFieldNames.sorted()
        self.ownerProcessRole = ownerProcessRole
        self.allowedReaderProcessRoles =
            allowedReaderProcessRoles.sorted {
                $0.rawValue < $1.rawValue
            }
        canonicalJSONRequired = true
        immutableNoReplaceRequired = true
        declarativeContractOnly = true
        processEvidenceRepresented = false
        deliveryObserved = false
        executionObserved = false
        mechanicsPassAuthorized = false
        terminalReceiptAuthorized = false
    }

    public func validateDeclarativeOwnership()
        throws
    {
        guard schemaVersion == 1,
              !schemaID.isEmpty,
              schemaID.utf8.count <= 160,
              schemaID.utf8.allSatisfy({
                  ($0 >= 97 && $0 <= 122)
                      || ($0 >= 48 && $0 <= 57)
                      || $0 == 95
              }),
              Self.isSafeRelativePath(relativePath),
              !requiredFieldNames.isEmpty,
              requiredFieldNames
                == requiredFieldNames.sorted(),
              Set(requiredFieldNames).count
                == requiredFieldNames.count,
              ownerProcessRole.branch == branch,
              !allowedReaderProcessRoles.isEmpty,
              allowedReaderProcessRoles
                == allowedReaderProcessRoles.sorted(by: {
                    $0.rawValue < $1.rawValue
                }),
              Set(allowedReaderProcessRoles).count
                == allowedReaderProcessRoles.count,
              allowedReaderProcessRoles.contains(
                  ownerProcessRole
              ),
              canonicalJSONRequired,
              immutableNoReplaceRequired,
              declarativeContractOnly,
              !processEvidenceRepresented,
              !deliveryObserved,
              !executionObserved,
              !mechanicsPassAuthorized,
              !terminalReceiptAuthorized
        else {
            throw PrimeNativeNeuralGateCorrectedProcessOwnershipContractError
                .invalidSchemaOwnership(relativePath)
        }
    }

    private static func isSafeRelativePath(
        _ path: String
    ) -> Bool {
        guard !path.hasPrefix("/"),
              !path.contains("\\"),
              !path.contains("\0"),
              path.utf8.allSatisfy({
                  $0 >= 0x21 && $0 <= 0x7e
              })
        else {
            return false
        }
        return path.split(
            separator: "/",
            omittingEmptySubsequences: false
        ).allSatisfy {
            !$0.isEmpty
                && $0 != "."
                && $0 != ".."
                && $0 != ".git"
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaID = "schema_id"
        case schemaVersion = "schema_version"
        case schemaKind = "schema_kind"
        case branch
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
        case declarativeContractOnly =
            "declarative_contract_only"
        case processEvidenceRepresented =
            "process_evidence_represented"
        case deliveryObserved =
            "delivery_observed"
        case executionObserved =
            "execution_observed"
        case mechanicsPassAuthorized =
            "mechanics_pass_authorized"
        case terminalReceiptAuthorized =
            "terminal_receipt_authorized"
    }
}

public struct PrimeNativeNeuralGateCorrectedProcessOwnershipContract:
    Encodable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let contractID: String
    public let targetFreeScheduleDeliveryContractID:
        String
    public let preservedHistoricalArtifactContractID:
        String
    public let preservedHistoricalArtifactContractSHA256:
        String
    public let supersededHistoricalSingularCorrectedProcessPaths:
        [String]
    public let preservedReplacementReceiptRelativePath:
        String
    public let historicalV4PreservedAsHistory: Bool
    public let singularCorrectedProcessPathsSuperseded:
        Bool
    public let exactProcessCount: Int
    public let exactSupervisorCount: Int
    public let exactChildProcessCount: Int
    public let allProcessIdentifiersPairwiseDistinctRequired:
        Bool
    public let processRoster:
        [PrimeNativeNeuralGateCorrectedProcessRosterEntry]
    public let roleScopedRawSchemas:
        [PrimeNativeNeuralGateRoleScopedSchemaOwnership]
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
            "prime_stage_b_corrected_ten_process_ownership_v1",
        targetFreeScheduleDeliveryContractID:
            PrimeNativeNeuralGateTargetFreeScheduleDeliveryContract
            .frozenV1.contractID,
        preservedHistoricalArtifactContractID:
            "prime_stage_b_non_authorizing_semantic_output_namespace_v4",
        preservedHistoricalArtifactContractSHA256:
            "60e10e6c10f9ec1f30102f5b6d27be123434a163c01d82c0cc5d4520824532d1",
        supersededHistoricalSingularCorrectedProcessPaths: [
            "neural-gate-replay/corrected/worker-request.v1.json",
            "neural-gate-replay/corrected/worker-process-binding.v1.json",
            "neural-gate-replay/corrected/worker-execution.v1.json",
            "neural-gate-replay/corrected/worker-result.v1.json",
        ],
        preservedReplacementReceiptRelativePath:
            "prime-native-neural-gate-fixture-replay-receipt.v2.json",
        historicalV4PreservedAsHistory: true,
        singularCorrectedProcessPathsSuperseded:
            true,
        exactProcessCount: 10,
        exactSupervisorCount: 2,
        exactChildProcessCount: 8,
        allProcessIdentifiersPairwiseDistinctRequired:
            true,
        processRoster:
            PrimeNativeNeuralGateCorrectedProcessRole
            .allCases.map {
                PrimeNativeNeuralGateCorrectedProcessRosterEntry(
                    role: $0
                )
            },
        roleScopedRawSchemas:
            Self.makeRoleScopedRawSchemas(),
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
            "This V1 replacement ownership contract freezes a symmetric ten-process Stage-B roster and role-scoped corrected raw schedule, request, process-binding, execution, and result schema ownership. It preserves the artifact namespace V4 identity and its four singular corrected-process reservations as superseded history while preserving the replacement receipt-v2 path. These Encodable-only values are declarations only: no process is materialized, no schedule is delivered, no child runs or is reaped, no result or PASS is accepted, no receipt is authorized, no V7 is issued, and no scientific or product claim is made. Mutation, statistics, verdict, and mutation producer/detector contracts remain deferred."
    )

    public func validate() throws {
        try PrimeNativeNeuralGateTargetFreeScheduleDeliveryContract
            .frozenV1.validate()
        try PrimeNativeNeuralGateReplayArtifactOutputContract
            .frozenV4.validate()
        let historical =
            PrimeNativeNeuralGateReplayArtifactOutputContract
            .frozenV4
        let historicalPaths = try [
            historical.spec(
                for: .correctedWorkerRequestReserved
            ).relativePath,
            historical.spec(
                for: .correctedWorkerProcessReserved
            ).relativePath,
            historical.spec(
                for: .correctedWorkerExecutionReserved
            ).relativePath,
            historical.spec(
                for: .correctedWorkerResultReserved
            ).relativePath,
        ]
        let historicalReceiptPath = try historical
            .spec(
                for: .replacementTerminalReceiptReserved
            ).relativePath
        let roles = processRoster.map(\.role)
        let childEntries = processRoster.filter {
            $0.kind != .supervisor
        }
        guard self == .frozenV1,
              schemaVersion == 1,
              targetFreeScheduleDeliveryContractID
                == "prime_stage_b_target_free_schedule_delivery_contract_v1",
              targetFreeScheduleDeliveryContractID
                == PrimeNativeNeuralGateTargetFreeScheduleDeliveryContract
                .frozenV1.contractID,
              preservedHistoricalArtifactContractID
                == historical.contractID,
              preservedHistoricalArtifactContractSHA256
                == "60e10e6c10f9ec1f30102f5b6d27be123434a163c01d82c0cc5d4520824532d1",
              supersededHistoricalSingularCorrectedProcessPaths
                == historicalPaths,
              preservedReplacementReceiptRelativePath
                == historicalReceiptPath,
              historicalV4PreservedAsHistory,
              singularCorrectedProcessPathsSuperseded,
              exactProcessCount == 10,
              exactSupervisorCount == 2,
              exactChildProcessCount == 8,
              allProcessIdentifiersPairwiseDistinctRequired,
              processRoster.count == exactProcessCount,
              roles
                == PrimeNativeNeuralGateCorrectedProcessRole
                .allCases,
              Set(roles).count == exactProcessCount,
              processRoster.filter({
                  $0.kind == .supervisor
              }).count == exactSupervisorCount,
              childEntries.count == exactChildProcessCount,
              childEntries.allSatisfy({
                  $0.supervisorRole != nil
                      && $0.deathObservedBeforeContinuationRequired
                      && $0.exactOnceReapBeforeReceiptRequired
              }),
              processRoster.allSatisfy({
                  $0.branch == $0.role.branch
                      && $0.kind == $0.role.kind
                      && $0.supervisorRole
                          == $0.role.supervisorRole
                      && $0.distinctPositiveProcessIdentifierRequired
                      && !$0.processMaterialized
                      && !$0.executionObserved
              }),
              roleScopedRawSchemas
                == Self.makeRoleScopedRawSchemas(),
              Set(roleScopedRawSchemas.map(\.relativePath))
                .count == roleScopedRawSchemas.count,
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
            throw PrimeNativeNeuralGateCorrectedProcessOwnershipContractError
                .invalidFrozenContract
        }
        try roleScopedRawSchemas.forEach {
            try $0.validateDeclarativeOwnership()
        }
        try Self.validateRosterSymmetry(processRoster)
        try Self.validateRawSchemaOwnership(
            roleScopedRawSchemas
        )
    }

    public static func expectedRawOwner(
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
                ? .probeCorrectedRawWorker
                : .verifierCorrectedRawWorker
        switch schemaKind {
        case .rawSchedule,
             .workerRequest,
             .workerExecution:
            return supervisor
        case .workerProcessBinding,
             .workerResult:
            return worker
        case .outerSchedule:
            return supervisor
        }
    }

    public static func makeRoleScopedRawSchemas()
        -> [PrimeNativeNeuralGateRoleScopedSchemaOwnership]
    {
        return PrimeNativeNeuralGateCorrectedProcessBranch
            .allCases.flatMap { branch in
                let prefix =
                    "neural-gate-replay/corrected/raw/\(branch.rawValue)"
                return [
                    schema(
                        "prime_stage_b_corrected_raw_schedule_delivery_v1",
                        .rawSchedule,
                        branch,
                        "\(prefix)/schedule-delivery.v1.json"
                    ),
                    schema(
                        "prime_stage_b_corrected_raw_worker_request_v1",
                        .workerRequest,
                        branch,
                        "\(prefix)/worker-request.v1.json"
                    ),
                    schema(
                        "prime_stage_b_corrected_raw_worker_process_binding_v1",
                        .workerProcessBinding,
                        branch,
                        "\(prefix)/worker-process-binding.v1.json"
                    ),
                    schema(
                        "prime_stage_b_corrected_raw_worker_execution_v1",
                        .workerExecution,
                        branch,
                        "\(prefix)/worker-execution.v1.json"
                    ),
                    schema(
                        "prime_stage_b_corrected_raw_worker_result_v1",
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
                    rawRequiredFieldNames(
                        for: kind
                    ),
                ownerProcessRole:
                    expectedRawOwner(
                        branch: branch,
                        schemaKind: kind
                    ),
                allowedReaderProcessRoles:
                    rawAllowedReaders(
                        branch: branch,
                        schemaKind: kind
                    )
            )
        }
    }

    public static func rawRequiredFieldNames(
        for schemaKind:
            PrimeNativeNeuralGateCorrectedSchemaKind
    ) -> [String] {
        let fields: [String]
        switch schemaKind {
        case .rawSchedule:
            fields = [
                "artifact_kind",
                "capture_identity_sha256",
                "invocation_role",
                "ordered_slot_count",
                "ordered_slots_sha256",
                "prompt_source_binding_sha256",
                "schedule_identity_sha256",
                "schema_version",
                "source_root_identity",
                "target_free_schedule_delivery_contract_id",
            ]
        case .workerRequest:
            fields = [
                "artifact_kind",
                "compiled_source_closure",
                "invocation_role",
                "prime_source_snapshot",
                "required_output_relative_paths",
                "schedule_delivery",
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
                "invocation_role",
                "logit_dictionary",
                "logit_manifest",
                "mechanics_pass_authorized",
                "ordered_logit_chunks",
                "ordered_raw_execution_chunks",
                "pre_result_produced_artifact_inventory",
                "raw_execution_global",
                "raw_execution_manifest",
                "replicate_seed",
                "request",
                "schedule_identity_sha256",
                "schema_version",
                "terminal_receipt_authorized",
                "worker_process_binding",
                "worker_process_identifier",
            ]
        case .outerSchedule:
            fields = []
        }
        return fields.sorted()
    }

    public static func rawAllowedReaders(
        branch:
            PrimeNativeNeuralGateCorrectedProcessBranch,
        schemaKind:
            PrimeNativeNeuralGateCorrectedSchemaKind
    ) -> [PrimeNativeNeuralGateCorrectedProcessRole] {
        let supervisor: PrimeNativeNeuralGateCorrectedProcessRole =
            branch == .probe
                ? .probeSupervisor
                : .verifierSupervisor
        let rawWorker: PrimeNativeNeuralGateCorrectedProcessRole =
            branch == .probe
                ? .probeCorrectedRawWorker
                : .verifierCorrectedRawWorker
        let evaluationWorker:
            PrimeNativeNeuralGateCorrectedProcessRole =
            branch == .probe
                ? .probeCorrectedEvaluationWorker
                : .verifierCorrectedEvaluationWorker
        let values:
            [PrimeNativeNeuralGateCorrectedProcessRole]
        switch schemaKind {
        case .rawSchedule,
             .workerRequest,
             .workerProcessBinding:
            values = [
                supervisor,
                rawWorker,
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
                rawWorker,
                evaluationWorker,
                .verifierSupervisor,
            ]
        case .outerSchedule:
            values = []
        }
        return Array(Set(values)).sorted {
            $0.rawValue < $1.rawValue
        }
    }

    static func validateRosterSymmetry(
        _ processRoster:
            [PrimeNativeNeuralGateCorrectedProcessRosterEntry]
    ) throws {
        for kind in
            PrimeNativeNeuralGateCorrectedProcessKind
            .allCases
        {
            let entries = processRoster.filter {
                $0.kind == kind
            }
            guard entries.count == 2,
                  Set(entries.map(\.branch))
                    == Set(
                        PrimeNativeNeuralGateCorrectedProcessBranch
                        .allCases
                    )
            else {
                throw PrimeNativeNeuralGateCorrectedProcessOwnershipContractError
                    .invalidProcessRoster
            }
        }
    }

    static func validateRawSchemaOwnership(
        _ roleScopedRawSchemas:
            [PrimeNativeNeuralGateRoleScopedSchemaOwnership]
    )
        throws
    {
        for branch in
            PrimeNativeNeuralGateCorrectedProcessBranch
            .allCases
        {
            let schemas = roleScopedRawSchemas
                .filter { $0.branch == branch }
            let expectedKinds:
                [PrimeNativeNeuralGateCorrectedSchemaKind] =
                [
                    .rawSchedule,
                    .workerRequest,
                    .workerProcessBinding,
                    .workerExecution,
                    .workerResult,
                ]
            guard schemas.map(\.schemaKind)
                    == expectedKinds,
                  schemas.allSatisfy({
                      $0.ownerProcessRole
                        == Self.expectedRawOwner(
                            branch: branch,
                            schemaKind: $0.schemaKind
                        )
                          && $0.requiredFieldNames
                            == Self.rawRequiredFieldNames(
                                for: $0.schemaKind
                            )
                          && $0.allowedReaderProcessRoles
                            == Self.rawAllowedReaders(
                                branch: branch,
                                schemaKind: $0.schemaKind
                            )
                  })
            else {
                throw PrimeNativeNeuralGateCorrectedProcessOwnershipContractError
                    .invalidSchemaOwnership(
                        branch.rawValue
                    )
            }
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case contractID = "contract_id"
        case targetFreeScheduleDeliveryContractID =
            "target_free_schedule_delivery_contract_id"
        case preservedHistoricalArtifactContractID =
            "preserved_historical_artifact_contract_id"
        case preservedHistoricalArtifactContractSHA256 =
            "preserved_historical_artifact_contract_sha256"
        case supersededHistoricalSingularCorrectedProcessPaths =
            "superseded_historical_singular_corrected_process_paths"
        case preservedReplacementReceiptRelativePath =
            "preserved_replacement_receipt_relative_path"
        case historicalV4PreservedAsHistory =
            "historical_v4_preserved_as_history"
        case singularCorrectedProcessPathsSuperseded =
            "singular_corrected_process_paths_superseded"
        case exactProcessCount = "exact_process_count"
        case exactSupervisorCount =
            "exact_supervisor_count"
        case exactChildProcessCount =
            "exact_child_process_count"
        case allProcessIdentifiersPairwiseDistinctRequired =
            "all_process_identifiers_pairwise_distinct_required"
        case processRoster = "process_roster"
        case roleScopedRawSchemas =
            "role_scoped_raw_schemas"
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
