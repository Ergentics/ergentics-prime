import Foundation
import PrimeNativeNeuralGateCorrectedEvaluationOwnershipContracts
import PrimeNativeNeuralGateCorrectedProcessOwnershipContracts
import PrimeNativeNeuralGateReplayArtifactContracts
import PrimeNativeNeuralGateReplayMechanics
import PrimeNativeNeuralGateTargetFreeScheduleDeliveryContracts
import PrimeNativeNeuralGateTerminalReceiptOwnershipContracts

public enum PrimeNativeNeuralGateRoleArtifactReferenceContractError:
    Error,
    Equatable,
    Sendable
{
    case invalidFrozenContract
    case invalidCommonCaptureScheduleReference
    case invalidBranchScheduleReference
    case invalidRoleArtifactRule(String)
    case invalidRoleArtifactContentReference(String)
    case invalidRoleDeclarationInventory
    case invalidWorkerSourceReferenceDeclaration(
        PrimeNativeNeuralGateCorrectedProcessRole
    )
    case invalidWorkerSourceArtifactReference(String)
    case invalidWorkerSourceReferenceAggregate(
        PrimeNativeNeuralGateCorrectedProcessRole
    )
    case canonicalEncodingRejected
}

/// Value-only observation shared by every future role-scoped Stage-B artifact.
/// It cannot reconstruct or retain the descriptor-rooted capture that produced
/// these values and therefore carries no source or delivery authority.
public struct PrimeNativeNeuralGateCommonCaptureScheduleReference:
    Encodable,
    Equatable,
    Sendable
{
    public static let schemaID =
        "prime_stage_b_common_capture_schedule_reference_v1"
    public static let captureInventoryContractID =
        "prime_stage_b_single_held_root_four_source_capture_inventory_v1"

    public let schemaVersion: Int
    public let referenceKind: String
    public let captureInventoryContractID: String
    public let targetFreeScheduleDeliveryContractID: String
    public let captureIdentitySHA256: String
    public let sourceRootIdentity:
        PrimeNativeNeuralGateTargetFreeSourceRootIdentity
    public let promptSourceBindingSHA256: String
    public let scheduleIdentitySHA256: String
    public let referenceIdentitySHA256: String

    public let retainedCaptureAuthorityEstablished = false
    public let sourceBindingV7Issued = false
    public let processDeliveryObserved = false
    public let workerMaterialized = false
    public let modelExecutionEstablished = false
    public let mechanicsPassAuthorized = false
    public let terminalReceiptAuthorized = false
    public let scientificAuthorityAuthorized = false
    public let productAuthorityAuthorized = false

    public init(
        captureIdentitySHA256: String,
        sourceRootIdentity:
            PrimeNativeNeuralGateTargetFreeSourceRootIdentity,
        promptSourceBindingSHA256: String,
        scheduleIdentitySHA256: String
    ) throws {
        schemaVersion = 1
        referenceKind = Self.schemaID
        captureInventoryContractID =
            Self.captureInventoryContractID
        targetFreeScheduleDeliveryContractID =
            PrimeNativeNeuralGateTargetFreeScheduleDeliveryContract
            .frozenV1.contractID
        self.captureIdentitySHA256 = captureIdentitySHA256
        self.sourceRootIdentity = sourceRootIdentity
        self.promptSourceBindingSHA256 =
            promptSourceBindingSHA256
        self.scheduleIdentitySHA256 = scheduleIdentitySHA256
        try Self.validateScalars(
            captureIdentitySHA256: captureIdentitySHA256,
            sourceRootIdentity: sourceRootIdentity,
            promptSourceBindingSHA256:
                promptSourceBindingSHA256,
            scheduleIdentitySHA256: scheduleIdentitySHA256
        )
        referenceIdentitySHA256 = try roleArtifactReferenceSHA256(
            CommonIdentityPayload(
                magic:
                    PrimeNativeNeuralGateRoleArtifactReferenceContract
                    .frozenV1.commonReferenceIdentityMagic,
                schemaVersion: 1,
                referenceKind: Self.schemaID,
                captureInventoryContractID:
                    Self.captureInventoryContractID,
                targetFreeScheduleDeliveryContractID:
                    PrimeNativeNeuralGateTargetFreeScheduleDeliveryContract
                    .frozenV1.contractID,
                captureIdentitySHA256: captureIdentitySHA256,
                sourceRootIdentity: sourceRootIdentity,
                promptSourceBindingSHA256:
                    promptSourceBindingSHA256,
                scheduleIdentitySHA256: scheduleIdentitySHA256
            )
        )
    }

    public func validate() throws {
        try Self.validateScalars(
            captureIdentitySHA256: captureIdentitySHA256,
            sourceRootIdentity: sourceRootIdentity,
            promptSourceBindingSHA256:
                promptSourceBindingSHA256,
            scheduleIdentitySHA256: scheduleIdentitySHA256
        )
        let expected = try roleArtifactReferenceSHA256(
            CommonIdentityPayload(
                magic:
                    PrimeNativeNeuralGateRoleArtifactReferenceContract
                    .frozenV1.commonReferenceIdentityMagic,
                schemaVersion: schemaVersion,
                referenceKind: referenceKind,
                captureInventoryContractID:
                    captureInventoryContractID,
                targetFreeScheduleDeliveryContractID:
                    targetFreeScheduleDeliveryContractID,
                captureIdentitySHA256: captureIdentitySHA256,
                sourceRootIdentity: sourceRootIdentity,
                promptSourceBindingSHA256:
                    promptSourceBindingSHA256,
                scheduleIdentitySHA256: scheduleIdentitySHA256
            )
        )
        guard schemaVersion == 1,
              referenceKind == Self.schemaID,
              captureInventoryContractID
                == Self.captureInventoryContractID,
              targetFreeScheduleDeliveryContractID
                == PrimeNativeNeuralGateTargetFreeScheduleDeliveryContract
                .frozenV1.contractID,
              referenceIdentitySHA256 == expected,
              !retainedCaptureAuthorityEstablished,
              !sourceBindingV7Issued,
              !processDeliveryObserved,
              !workerMaterialized,
              !modelExecutionEstablished,
              !mechanicsPassAuthorized,
              !terminalReceiptAuthorized,
              !scientificAuthorityAuthorized,
              !productAuthorityAuthorized
        else {
            throw PrimeNativeNeuralGateRoleArtifactReferenceContractError
                .invalidCommonCaptureScheduleReference
        }
    }

    private static func validateScalars(
        captureIdentitySHA256: String,
        sourceRootIdentity:
            PrimeNativeNeuralGateTargetFreeSourceRootIdentity,
        promptSourceBindingSHA256: String,
        scheduleIdentitySHA256: String
    ) throws {
        guard isLowercaseRoleArtifactSHA256(
                  captureIdentitySHA256
              ),
              isLowercaseRoleArtifactSHA256(
                  promptSourceBindingSHA256
              ),
              isLowercaseRoleArtifactSHA256(
                  scheduleIdentitySHA256
              ),
              sourceRootIdentity.deviceID > 0,
              sourceRootIdentity.inode > 0,
              sourceRootIdentity.actualMode == 0o700,
              sourceRootIdentity.linkCount > 0,
              sourceRootIdentity.modificationNanoseconds >= 0,
              sourceRootIdentity.modificationNanoseconds
                < 1_000_000_000,
              sourceRootIdentity.statusChangeNanoseconds >= 0,
              sourceRootIdentity.statusChangeNanoseconds
                < 1_000_000_000
        else {
            throw PrimeNativeNeuralGateRoleArtifactReferenceContractError
                .invalidCommonCaptureScheduleReference
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case referenceKind = "reference_kind"
        case captureInventoryContractID =
            "capture_inventory_contract_id"
        case targetFreeScheduleDeliveryContractID =
            "target_free_schedule_delivery_contract_id"
        case captureIdentitySHA256 = "capture_identity_sha256"
        case sourceRootIdentity = "source_root_identity"
        case promptSourceBindingSHA256 =
            "prompt_source_binding_sha256"
        case scheduleIdentitySHA256 = "schedule_identity_sha256"
        case referenceIdentitySHA256 = "reference_identity_sha256"
        case retainedCaptureAuthorityEstablished =
            "retained_capture_authority_established"
        case sourceBindingV7Issued = "source_binding_v7_issued"
        case processDeliveryObserved = "process_delivery_observed"
        case workerMaterialized = "worker_materialized"
        case modelExecutionEstablished = "model_execution_established"
        case mechanicsPassAuthorized = "mechanics_pass_authorized"
        case terminalReceiptAuthorized = "terminal_receipt_authorized"
        case scientificAuthorityAuthorized =
            "scientific_authority_authorized"
        case productAuthorityAuthorized = "product_authority_authorized"
    }
}

/// Branch-specific identities from one already-validated target-free pair.
/// This value does not retain the pair or establish that bytes crossed a
/// process boundary.
public struct PrimeNativeNeuralGateBranchScheduleReference:
    Encodable,
    Equatable,
    Sendable
{
    public static let schemaID =
        "prime_stage_b_branch_capture_schedule_reference_v1"

    public let schemaVersion: Int
    public let referenceKind: String
    public let branch:
        PrimeNativeNeuralGateCorrectedProcessBranch
    public let invocationRole:
        PrimeNativeNeuralGateTargetFreeScheduleInvocationRole
    public let commonReferenceIdentitySHA256: String
    public let rawCandidateIdentitySHA256: String
    public let outerCandidateIdentitySHA256: String
    public let deliveryIdentitySHA256: String
    public let referenceIdentitySHA256: String

    public let processDeliveryObserved = false
    public let workerMaterialized = false
    public let evaluationPerformed = false
    public let mechanicsPassAuthorized = false
    public let terminalReceiptAuthorized = false

    public init(
        branch: PrimeNativeNeuralGateCorrectedProcessBranch,
        invocationRole:
            PrimeNativeNeuralGateTargetFreeScheduleInvocationRole,
        commonReferenceIdentitySHA256: String,
        rawCandidateIdentitySHA256: String,
        outerCandidateIdentitySHA256: String,
        deliveryIdentitySHA256: String
    ) throws {
        guard invocationRole == branch.targetFreeInvocationRole,
              [
                  commonReferenceIdentitySHA256,
                  rawCandidateIdentitySHA256,
                  outerCandidateIdentitySHA256,
                  deliveryIdentitySHA256,
              ].allSatisfy(isLowercaseRoleArtifactSHA256)
        else {
            throw PrimeNativeNeuralGateRoleArtifactReferenceContractError
                .invalidBranchScheduleReference
        }
        schemaVersion = 1
        referenceKind = Self.schemaID
        self.branch = branch
        self.invocationRole = invocationRole
        self.commonReferenceIdentitySHA256 =
            commonReferenceIdentitySHA256
        self.rawCandidateIdentitySHA256 =
            rawCandidateIdentitySHA256
        self.outerCandidateIdentitySHA256 =
            outerCandidateIdentitySHA256
        self.deliveryIdentitySHA256 = deliveryIdentitySHA256
        referenceIdentitySHA256 = try roleArtifactReferenceSHA256(
            BranchIdentityPayload(
                magic:
                    PrimeNativeNeuralGateRoleArtifactReferenceContract
                    .frozenV1.branchReferenceIdentityMagic,
                schemaVersion: 1,
                referenceKind: Self.schemaID,
                branch: branch,
                invocationRole: invocationRole,
                commonReferenceIdentitySHA256:
                    commonReferenceIdentitySHA256,
                rawCandidateIdentitySHA256:
                    rawCandidateIdentitySHA256,
                outerCandidateIdentitySHA256:
                    outerCandidateIdentitySHA256,
                deliveryIdentitySHA256: deliveryIdentitySHA256
            )
        )
    }

    public func validate(
        commonReference:
            PrimeNativeNeuralGateCommonCaptureScheduleReference
    ) throws {
        try commonReference.validate()
        let expected = try Self(
            branch: branch,
            invocationRole: invocationRole,
            commonReferenceIdentitySHA256:
                commonReference.referenceIdentitySHA256,
            rawCandidateIdentitySHA256:
                rawCandidateIdentitySHA256,
            outerCandidateIdentitySHA256:
                outerCandidateIdentitySHA256,
            deliveryIdentitySHA256: deliveryIdentitySHA256
        )
        guard self == expected,
              commonReferenceIdentitySHA256
                == commonReference.referenceIdentitySHA256,
              !processDeliveryObserved,
              !workerMaterialized,
              !evaluationPerformed,
              !mechanicsPassAuthorized,
              !terminalReceiptAuthorized
        else {
            throw PrimeNativeNeuralGateRoleArtifactReferenceContractError
                .invalidBranchScheduleReference
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case referenceKind = "reference_kind"
        case branch
        case invocationRole = "invocation_role"
        case commonReferenceIdentitySHA256 =
            "common_reference_identity_sha256"
        case rawCandidateIdentitySHA256 =
            "raw_candidate_identity_sha256"
        case outerCandidateIdentitySHA256 =
            "outer_candidate_identity_sha256"
        case deliveryIdentitySHA256 = "delivery_identity_sha256"
        case referenceIdentitySHA256 = "reference_identity_sha256"
        case processDeliveryObserved = "process_delivery_observed"
        case workerMaterialized = "worker_materialized"
        case evaluationPerformed = "evaluation_performed"
        case mechanicsPassAuthorized = "mechanics_pass_authorized"
        case terminalReceiptAuthorized = "terminal_receipt_authorized"
    }
}

/// Exact frozen role/path rule derived from one V6 ownership declaration.
/// It reserves a content reference shape but contains no realized bytes.
public struct PrimeNativeNeuralGateRoleArtifactRule:
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
    public let ownerProcessRole:
        PrimeNativeNeuralGateCorrectedProcessRole
    public let allowedReaderProcessRoles:
        [PrimeNativeNeuralGateCorrectedProcessRole]
    public let maximumByteCount: UInt64
    public let purpose:
        PrimeNativeNeuralGateArtifactPurpose
    public let mode: String
    public let contentReferenceRequired: Bool
    public let realizedContentPresent: Bool
    public let mechanicsPassAuthorized: Bool
    public let terminalReceiptAuthorized: Bool

    init(
        schemaID: String,
        schemaVersion: Int,
        schemaKind: PrimeNativeNeuralGateCorrectedSchemaKind,
        branch: PrimeNativeNeuralGateCorrectedProcessBranch,
        relativePath: String,
        ownerProcessRole:
            PrimeNativeNeuralGateCorrectedProcessRole,
        allowedReaderProcessRoles:
            [PrimeNativeNeuralGateCorrectedProcessRole],
        maximumByteCount: UInt64,
        purpose: PrimeNativeNeuralGateArtifactPurpose,
        mode: String,
        contentReferenceRequired: Bool = true,
        realizedContentPresent: Bool = false,
        mechanicsPassAuthorized: Bool = false,
        terminalReceiptAuthorized: Bool = false
    ) {
        self.schemaID = schemaID
        self.schemaVersion = schemaVersion
        self.schemaKind = schemaKind
        self.branch = branch
        self.relativePath = relativePath
        self.ownerProcessRole = ownerProcessRole
        self.allowedReaderProcessRoles =
            allowedReaderProcessRoles
        self.maximumByteCount = maximumByteCount
        self.purpose = purpose
        self.mode = mode
        self.contentReferenceRequired = contentReferenceRequired
        self.realizedContentPresent = realizedContentPresent
        self.mechanicsPassAuthorized = mechanicsPassAuthorized
        self.terminalReceiptAuthorized = terminalReceiptAuthorized
    }

    init(
        ownership: PrimeNativeNeuralGateRoleScopedSchemaOwnership,
        maximumByteCount: UInt64
    ) {
        self.init(
            schemaID: ownership.schemaID,
            schemaVersion: ownership.schemaVersion,
            schemaKind: ownership.schemaKind,
            branch: ownership.branch,
            relativePath: ownership.relativePath,
            ownerProcessRole: ownership.ownerProcessRole,
            allowedReaderProcessRoles:
                ownership.allowedReaderProcessRoles,
            maximumByteCount: maximumByteCount,
            purpose: .immutableData,
            mode: "0444"
        )
    }

    func validate(
        against ownership:
            PrimeNativeNeuralGateRoleScopedSchemaOwnership,
        maximumByteCount expectedMaximum: UInt64
    ) throws {
        guard schemaID == ownership.schemaID,
              schemaVersion == ownership.schemaVersion,
              schemaKind == ownership.schemaKind,
              branch == ownership.branch,
              relativePath == ownership.relativePath,
              ownerProcessRole == ownership.ownerProcessRole,
              allowedReaderProcessRoles
                == ownership.allowedReaderProcessRoles,
              maximumByteCount == expectedMaximum,
              purpose == .immutableData,
              mode == "0444",
              contentReferenceRequired,
              !realizedContentPresent,
              !mechanicsPassAuthorized,
              !terminalReceiptAuthorized
        else {
            throw PrimeNativeNeuralGateRoleArtifactReferenceContractError
                .invalidRoleArtifactRule(relativePath)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaID = "schema_id"
        case schemaVersion = "schema_version"
        case schemaKind = "schema_kind"
        case branch
        case relativePath = "relative_path"
        case ownerProcessRole = "owner_process_role"
        case allowedReaderProcessRoles =
            "allowed_reader_process_roles"
        case maximumByteCount = "maximum_byte_count"
        case purpose
        case mode
        case contentReferenceRequired = "content_reference_required"
        case realizedContentPresent = "realized_content_present"
        case mechanicsPassAuthorized = "mechanics_pass_authorized"
        case terminalReceiptAuthorized = "terminal_receipt_authorized"
    }
}

public struct PrimeNativeNeuralGateRoleArtifactDeclaration:
    Encodable,
    Equatable,
    Sendable
{
    public let role:
        PrimeNativeNeuralGateCorrectedProcessRole
    public let artifactRules:
        [PrimeNativeNeuralGateRoleArtifactRule]
    public let realizedContentReferenceCount: Int
    public let processMaterialized: Bool
    public let executionObserved: Bool

    init(
        role: PrimeNativeNeuralGateCorrectedProcessRole,
        artifactRules: [PrimeNativeNeuralGateRoleArtifactRule],
        realizedContentReferenceCount: Int = 0,
        processMaterialized: Bool = false,
        executionObserved: Bool = false
    ) {
        self.role = role
        self.artifactRules = artifactRules
        self.realizedContentReferenceCount =
            realizedContentReferenceCount
        self.processMaterialized = processMaterialized
        self.executionObserved = executionObserved
    }

    private enum CodingKeys: String, CodingKey {
        case role
        case artifactRules = "artifact_rules"
        case realizedContentReferenceCount =
            "realized_content_reference_count"
        case processMaterialized = "process_materialized"
        case executionObserved = "execution_observed"
    }
}

public enum PrimeNativeNeuralGateWorkerSourceArtifactReferenceKind:
    String,
    CaseIterable,
    Encodable,
    Equatable,
    Sendable
{
    case primeSourceSnapshot = "prime_source_snapshot"
    case swiftPackageDescribe = "swift_package_describe"
    case compiledSourceClosure = "compiled_source_closure"
    case sealedWorkerExecutable = "sealed_worker_executable"
}

public enum PrimeNativeNeuralGateWorkerSourceArtifactPurpose:
    String,
    Encodable,
    Equatable,
    Sendable
{
    case immutableData = "immutable_data"
    case executable = "executable"
}

/// Shared value fields for one role-scoped source artifact. The four public
/// wrappers below select an exact kind and exact embedded-identity policy.
/// These are copied values only: no descriptor or capture capability is kept.
public struct PrimeNativeNeuralGateWorkerSourceArtifactDescriptor:
    Encodable,
    Equatable,
    Sendable
{
    public let referenceKind:
        PrimeNativeNeuralGateWorkerSourceArtifactReferenceKind
    public let workerRole:
        PrimeNativeNeuralGateCorrectedProcessRole
    public let workerTargetName: String
    public let relativePath: String
    public let contentSHA256: String
    public let byteCount: UInt64
    public let mode: String
    public let purpose:
        PrimeNativeNeuralGateWorkerSourceArtifactPurpose
    public let buildConfiguration: String
    public let sourceIdentitySHA256: String
    public let embeddedSourceIdentitySHA256: String?
    public let commonCaptureScheduleReferenceIdentitySHA256: String

    fileprivate init(
        referenceKind:
            PrimeNativeNeuralGateWorkerSourceArtifactReferenceKind,
        workerRole:
            PrimeNativeNeuralGateCorrectedProcessRole,
        workerTargetName: String,
        relativePath: String,
        contentSHA256: String,
        byteCount: UInt64,
        sourceIdentitySHA256: String,
        embeddedSourceIdentitySHA256: String?,
        commonReference:
            PrimeNativeNeuralGateCommonCaptureScheduleReference
    ) throws {
        try commonReference.validate()
        self.referenceKind = referenceKind
        self.workerRole = workerRole
        self.workerTargetName = workerTargetName
        self.relativePath = relativePath
        self.contentSHA256 = contentSHA256
        self.byteCount = byteCount
        switch referenceKind {
        case .sealedWorkerExecutable:
            mode = "0555"
            purpose = .executable
        case .primeSourceSnapshot,
             .swiftPackageDescribe,
             .compiledSourceClosure:
            mode = "0444"
            purpose = .immutableData
        }
        buildConfiguration = "release"
        self.sourceIdentitySHA256 = sourceIdentitySHA256
        self.embeddedSourceIdentitySHA256 =
            embeddedSourceIdentitySHA256
        commonCaptureScheduleReferenceIdentitySHA256 =
            commonReference.referenceIdentitySHA256
        try validate(expectedKind: referenceKind)
    }

    fileprivate func validate(
        expectedKind:
            PrimeNativeNeuralGateWorkerSourceArtifactReferenceKind
    ) throws {
        let embeddedRequired = expectedKind
            != .swiftPackageDescribe
        guard referenceKind == expectedKind,
              workerRole.kind == .historicalWorker
                || workerRole.kind == .correctedRawWorker
                || workerRole.kind == .correctedEvaluationWorker,
              isSafeRoleArtifactRelativePath(relativePath),
              isSafeRoleArtifactTargetName(workerTargetName),
              isLowercaseRoleArtifactSHA256(contentSHA256),
              byteCount > 0,
              buildConfiguration == "release",
              isLowercaseRoleArtifactSHA256(
                  sourceIdentitySHA256
              ),
              isLowercaseRoleArtifactSHA256(
                  commonCaptureScheduleReferenceIdentitySHA256
              ),
              embeddedRequired
                ? embeddedSourceIdentitySHA256
                    == sourceIdentitySHA256
                : embeddedSourceIdentitySHA256 == nil,
              expectedKind == .sealedWorkerExecutable
                ? (purpose == .executable && mode == "0555")
                : (purpose == .immutableData && mode == "0444")
        else {
            throw PrimeNativeNeuralGateRoleArtifactReferenceContractError
                .invalidWorkerSourceArtifactReference(
                    expectedKind.rawValue
                )
        }
    }

    private enum CodingKeys: String, CodingKey {
        case referenceKind = "reference_kind"
        case workerRole = "worker_role"
        case workerTargetName = "worker_target_name"
        case relativePath = "relative_path"
        case contentSHA256 = "content_sha256"
        case byteCount = "byte_count"
        case mode
        case purpose
        case buildConfiguration = "build_configuration"
        case sourceIdentitySHA256 = "source_identity_sha256"
        case embeddedSourceIdentitySHA256 =
            "embedded_source_identity_sha256"
        case commonCaptureScheduleReferenceIdentitySHA256 =
            "common_capture_schedule_reference_identity_sha256"
    }
}

public struct PrimeNativeNeuralGatePrimeSourceSnapshotReference:
    Encodable,
    Equatable,
    Sendable
{
    public static let schemaID =
        "prime_stage_b_prime_source_snapshot_reference_v1"
    public let schemaVersion = 1
    public let referenceKind = Self.schemaID
    public let artifact:
        PrimeNativeNeuralGateWorkerSourceArtifactDescriptor
    public let referenceIdentitySHA256: String
    public let descriptorContentVerified = false
    public let sourcePinningObserved = false

    public init(
        workerRole:
            PrimeNativeNeuralGateCorrectedProcessRole,
        workerTargetName: String,
        relativePath: String,
        contentSHA256: String,
        byteCount: UInt64,
        sourceIdentitySHA256: String,
        embeddedSourceIdentitySHA256: String,
        commonReference:
            PrimeNativeNeuralGateCommonCaptureScheduleReference
    ) throws {
        artifact = try .init(
            referenceKind: .primeSourceSnapshot,
            workerRole: workerRole,
            workerTargetName: workerTargetName,
            relativePath: relativePath,
            contentSHA256: contentSHA256,
            byteCount: byteCount,
            sourceIdentitySHA256: sourceIdentitySHA256,
            embeddedSourceIdentitySHA256:
                embeddedSourceIdentitySHA256,
            commonReference: commonReference
        )
        referenceIdentitySHA256 = try roleArtifactReferenceSHA256(
            WorkerTypedArtifactIdentityPayload(
                magic:
                    PrimeNativeNeuralGateRoleArtifactReferenceContract
                    .frozenV1.primeSourceSnapshotIdentityMagic,
                schemaVersion: 1,
                referenceKind: Self.schemaID,
                artifact: artifact,
                orderedDirectLocalTargetNames: nil
            )
        )
    }

    public func validate(
        commonReference:
            PrimeNativeNeuralGateCommonCaptureScheduleReference
    ) throws {
        try commonReference.validate()
        try artifact.validate(expectedKind: .primeSourceSnapshot)
        let expected = try Self(
            workerRole: artifact.workerRole,
            workerTargetName: artifact.workerTargetName,
            relativePath: artifact.relativePath,
            contentSHA256: artifact.contentSHA256,
            byteCount: artifact.byteCount,
            sourceIdentitySHA256: artifact.sourceIdentitySHA256,
            embeddedSourceIdentitySHA256:
                artifact.embeddedSourceIdentitySHA256 ?? "",
            commonReference: commonReference
        )
        guard self == expected,
              artifact
                .commonCaptureScheduleReferenceIdentitySHA256
                == commonReference.referenceIdentitySHA256,
              !descriptorContentVerified,
              !sourcePinningObserved
        else {
            throw PrimeNativeNeuralGateRoleArtifactReferenceContractError
                .invalidWorkerSourceArtifactReference(
                    artifact.referenceKind.rawValue
                )
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case referenceKind = "reference_kind"
        case artifact
        case referenceIdentitySHA256 = "reference_identity_sha256"
        case descriptorContentVerified =
            "descriptor_content_verified"
        case sourcePinningObserved = "source_pinning_observed"
    }
}

public struct PrimeNativeNeuralGateSwiftPackageDescribeReference:
    Encodable,
    Equatable,
    Sendable
{
    public static let schemaID =
        "prime_stage_b_swift_package_describe_reference_v1"
    public let schemaVersion = 1
    public let referenceKind = Self.schemaID
    public let artifact:
        PrimeNativeNeuralGateWorkerSourceArtifactDescriptor
    public let referenceIdentitySHA256: String
    public let descriptorContentVerified = false
    public let sourcePinningObserved = false

    public init(
        workerRole:
            PrimeNativeNeuralGateCorrectedProcessRole,
        workerTargetName: String,
        relativePath: String,
        contentSHA256: String,
        byteCount: UInt64,
        sourceIdentitySHA256: String,
        commonReference:
            PrimeNativeNeuralGateCommonCaptureScheduleReference
    ) throws {
        artifact = try .init(
            referenceKind: .swiftPackageDescribe,
            workerRole: workerRole,
            workerTargetName: workerTargetName,
            relativePath: relativePath,
            contentSHA256: contentSHA256,
            byteCount: byteCount,
            sourceIdentitySHA256: sourceIdentitySHA256,
            embeddedSourceIdentitySHA256: nil,
            commonReference: commonReference
        )
        referenceIdentitySHA256 = try roleArtifactReferenceSHA256(
            WorkerTypedArtifactIdentityPayload(
                magic:
                    PrimeNativeNeuralGateRoleArtifactReferenceContract
                    .frozenV1.swiftPackageDescribeIdentityMagic,
                schemaVersion: 1,
                referenceKind: Self.schemaID,
                artifact: artifact,
                orderedDirectLocalTargetNames: nil
            )
        )
    }

    public func validate(
        commonReference:
            PrimeNativeNeuralGateCommonCaptureScheduleReference
    ) throws {
        try commonReference.validate()
        try artifact.validate(expectedKind: .swiftPackageDescribe)
        let expected = try Self(
            workerRole: artifact.workerRole,
            workerTargetName: artifact.workerTargetName,
            relativePath: artifact.relativePath,
            contentSHA256: artifact.contentSHA256,
            byteCount: artifact.byteCount,
            sourceIdentitySHA256: artifact.sourceIdentitySHA256,
            commonReference: commonReference
        )
        guard self == expected,
              artifact
                .commonCaptureScheduleReferenceIdentitySHA256
                == commonReference.referenceIdentitySHA256,
              !descriptorContentVerified,
              !sourcePinningObserved
        else {
            throw PrimeNativeNeuralGateRoleArtifactReferenceContractError
                .invalidWorkerSourceArtifactReference(
                    artifact.referenceKind.rawValue
                )
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case referenceKind = "reference_kind"
        case artifact
        case referenceIdentitySHA256 = "reference_identity_sha256"
        case descriptorContentVerified =
            "descriptor_content_verified"
        case sourcePinningObserved = "source_pinning_observed"
    }
}

public struct PrimeNativeNeuralGateCompiledSourceClosureReference:
    Encodable,
    Equatable,
    Sendable
{
    public static let schemaID =
        "prime_stage_b_compiled_source_closure_reference_v1"
    public let schemaVersion = 1
    public let referenceKind = Self.schemaID
    public let artifact:
        PrimeNativeNeuralGateWorkerSourceArtifactDescriptor
    public let orderedDirectLocalTargetNames: [String]
    public let referenceIdentitySHA256: String
    public let descriptorContentVerified = false
    public let sourcePinningObserved = false

    public init(
        workerRole:
            PrimeNativeNeuralGateCorrectedProcessRole,
        workerTargetName: String,
        relativePath: String,
        contentSHA256: String,
        byteCount: UInt64,
        sourceIdentitySHA256: String,
        embeddedSourceIdentitySHA256: String,
        orderedDirectLocalTargetNames: [String],
        commonReference:
            PrimeNativeNeuralGateCommonCaptureScheduleReference
    ) throws {
        guard !orderedDirectLocalTargetNames.isEmpty,
              Set(orderedDirectLocalTargetNames).count
                == orderedDirectLocalTargetNames.count,
              orderedDirectLocalTargetNames.allSatisfy(
                  isSafeRoleArtifactTargetName
              )
        else {
            throw PrimeNativeNeuralGateRoleArtifactReferenceContractError
                .invalidWorkerSourceArtifactReference(
                    Self.schemaID
                )
        }
        artifact = try .init(
            referenceKind: .compiledSourceClosure,
            workerRole: workerRole,
            workerTargetName: workerTargetName,
            relativePath: relativePath,
            contentSHA256: contentSHA256,
            byteCount: byteCount,
            sourceIdentitySHA256: sourceIdentitySHA256,
            embeddedSourceIdentitySHA256:
                embeddedSourceIdentitySHA256,
            commonReference: commonReference
        )
        self.orderedDirectLocalTargetNames =
            orderedDirectLocalTargetNames
        referenceIdentitySHA256 = try roleArtifactReferenceSHA256(
            WorkerTypedArtifactIdentityPayload(
                magic:
                    PrimeNativeNeuralGateRoleArtifactReferenceContract
                    .frozenV1.compiledSourceClosureIdentityMagic,
                schemaVersion: 1,
                referenceKind: Self.schemaID,
                artifact: artifact,
                orderedDirectLocalTargetNames:
                    orderedDirectLocalTargetNames
            )
        )
    }

    public func validate(
        commonReference:
            PrimeNativeNeuralGateCommonCaptureScheduleReference
    ) throws {
        try artifact.validate(expectedKind: .compiledSourceClosure)
        let expected = try Self(
            workerRole: artifact.workerRole,
            workerTargetName: artifact.workerTargetName,
            relativePath: artifact.relativePath,
            contentSHA256: artifact.contentSHA256,
            byteCount: artifact.byteCount,
            sourceIdentitySHA256: artifact.sourceIdentitySHA256,
            embeddedSourceIdentitySHA256:
                artifact.embeddedSourceIdentitySHA256 ?? "",
            orderedDirectLocalTargetNames:
                orderedDirectLocalTargetNames,
            commonReference: commonReference
        )
        guard self == expected,
              artifact
                .commonCaptureScheduleReferenceIdentitySHA256
                == commonReference.referenceIdentitySHA256,
              !descriptorContentVerified,
              !sourcePinningObserved
        else {
            throw PrimeNativeNeuralGateRoleArtifactReferenceContractError
                .invalidWorkerSourceArtifactReference(
                    artifact.referenceKind.rawValue
                )
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case referenceKind = "reference_kind"
        case artifact
        case orderedDirectLocalTargetNames =
            "ordered_direct_local_target_names"
        case referenceIdentitySHA256 = "reference_identity_sha256"
        case descriptorContentVerified =
            "descriptor_content_verified"
        case sourcePinningObserved = "source_pinning_observed"
    }
}

public struct PrimeNativeNeuralGateSealedWorkerExecutableReference:
    Encodable,
    Equatable,
    Sendable
{
    public static let schemaID =
        "prime_stage_b_sealed_worker_executable_reference_v1"
    public let schemaVersion = 1
    public let referenceKind = Self.schemaID
    public let artifact:
        PrimeNativeNeuralGateWorkerSourceArtifactDescriptor
    public let referenceIdentitySHA256: String
    public let descriptorContentVerified = false
    public let sourcePinningObserved = false

    public init(
        workerRole:
            PrimeNativeNeuralGateCorrectedProcessRole,
        workerTargetName: String,
        relativePath: String,
        contentSHA256: String,
        byteCount: UInt64,
        sourceIdentitySHA256: String,
        embeddedSourceIdentitySHA256: String,
        commonReference:
            PrimeNativeNeuralGateCommonCaptureScheduleReference
    ) throws {
        artifact = try .init(
            referenceKind: .sealedWorkerExecutable,
            workerRole: workerRole,
            workerTargetName: workerTargetName,
            relativePath: relativePath,
            contentSHA256: contentSHA256,
            byteCount: byteCount,
            sourceIdentitySHA256: sourceIdentitySHA256,
            embeddedSourceIdentitySHA256:
                embeddedSourceIdentitySHA256,
            commonReference: commonReference
        )
        referenceIdentitySHA256 = try roleArtifactReferenceSHA256(
            WorkerTypedArtifactIdentityPayload(
                magic:
                    PrimeNativeNeuralGateRoleArtifactReferenceContract
                    .frozenV1.sealedWorkerExecutableIdentityMagic,
                schemaVersion: 1,
                referenceKind: Self.schemaID,
                artifact: artifact,
                orderedDirectLocalTargetNames: nil
            )
        )
    }

    public func validate(
        commonReference:
            PrimeNativeNeuralGateCommonCaptureScheduleReference
    ) throws {
        try artifact.validate(expectedKind: .sealedWorkerExecutable)
        let expected = try Self(
            workerRole: artifact.workerRole,
            workerTargetName: artifact.workerTargetName,
            relativePath: artifact.relativePath,
            contentSHA256: artifact.contentSHA256,
            byteCount: artifact.byteCount,
            sourceIdentitySHA256: artifact.sourceIdentitySHA256,
            embeddedSourceIdentitySHA256:
                artifact.embeddedSourceIdentitySHA256 ?? "",
            commonReference: commonReference
        )
        guard self == expected,
              artifact
                .commonCaptureScheduleReferenceIdentitySHA256
                == commonReference.referenceIdentitySHA256,
              !descriptorContentVerified,
              !sourcePinningObserved
        else {
            throw PrimeNativeNeuralGateRoleArtifactReferenceContractError
                .invalidWorkerSourceArtifactReference(
                    artifact.referenceKind.rawValue
                )
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case referenceKind = "reference_kind"
        case artifact
        case referenceIdentitySHA256 = "reference_identity_sha256"
        case descriptorContentVerified =
            "descriptor_content_verified"
        case sourcePinningObserved = "source_pinning_observed"
    }
}

/// Exact typed four-artifact closure for a future worker. Even a valid copied
/// aggregate is non-authorizing until a descriptor-rooted adapter observes and
/// reconciles the live files; this pure value always records that absence.
public struct PrimeNativeNeuralGateWorkerSourceReference:
    Encodable,
    Equatable,
    Sendable
{
    public static let schemaID =
        "prime_stage_b_typed_worker_source_reference_v1"
    public let schemaVersion = 1
    public let referenceKind = Self.schemaID
    public let workerRole:
        PrimeNativeNeuralGateCorrectedProcessRole
    public let workerTargetName: String
    public let orderedDirectLocalTargetNames: [String]
    public let commonCaptureScheduleReferenceIdentitySHA256: String
    public let primeSourceSnapshot:
        PrimeNativeNeuralGatePrimeSourceSnapshotReference
    public let swiftPackageDescribe:
        PrimeNativeNeuralGateSwiftPackageDescribeReference
    public let compiledSourceClosure:
        PrimeNativeNeuralGateCompiledSourceClosureReference
    public let sealedWorkerExecutable:
        PrimeNativeNeuralGateSealedWorkerExecutableReference
    public let referenceIdentitySHA256: String

    public let descriptorObservationsPresent = false
    public let sourcePinningObserved = false
    public let workerMaterialized = false
    public let executionObserved = false
    public let sourceBindingV7Issued = false

    public init(
        declaration:
            PrimeNativeNeuralGatePlannedWorkerSourceReferenceDeclaration,
        commonReference:
            PrimeNativeNeuralGateCommonCaptureScheduleReference,
        primeSourceSnapshot:
            PrimeNativeNeuralGatePrimeSourceSnapshotReference,
        swiftPackageDescribe:
            PrimeNativeNeuralGateSwiftPackageDescribeReference,
        compiledSourceClosure:
            PrimeNativeNeuralGateCompiledSourceClosureReference,
        sealedWorkerExecutable:
            PrimeNativeNeuralGateSealedWorkerExecutableReference
    ) throws {
        try commonReference.validate()
        try primeSourceSnapshot.validate(
            commonReference: commonReference
        )
        try swiftPackageDescribe.validate(
            commonReference: commonReference
        )
        try compiledSourceClosure.validate(
            commonReference: commonReference
        )
        try sealedWorkerExecutable.validate(
            commonReference: commonReference
        )
        workerRole = declaration.role
        workerTargetName = declaration.targetName
        orderedDirectLocalTargetNames =
            declaration.requiredDirectLocalTargetNames
        commonCaptureScheduleReferenceIdentitySHA256 =
            commonReference.referenceIdentitySHA256
        self.primeSourceSnapshot = primeSourceSnapshot
        self.swiftPackageDescribe = swiftPackageDescribe
        self.compiledSourceClosure = compiledSourceClosure
        self.sealedWorkerExecutable = sealedWorkerExecutable
        try Self.validateExactBindings(
            declaration: declaration,
            commonReference: commonReference,
            primeSourceSnapshot: primeSourceSnapshot,
            swiftPackageDescribe: swiftPackageDescribe,
            compiledSourceClosure: compiledSourceClosure,
            sealedWorkerExecutable: sealedWorkerExecutable
        )
        referenceIdentitySHA256 = try roleArtifactReferenceSHA256(
            WorkerSourceAggregateIdentityPayload(
                magic:
                    PrimeNativeNeuralGateRoleArtifactReferenceContract
                    .frozenV1.workerSourceAggregateIdentityMagic,
                schemaVersion: 1,
                referenceKind: Self.schemaID,
                workerRole: workerRole,
                workerTargetName: workerTargetName,
                orderedDirectLocalTargetNames:
                    orderedDirectLocalTargetNames,
                commonCaptureScheduleReferenceIdentitySHA256:
                    commonCaptureScheduleReferenceIdentitySHA256,
                primeSourceSnapshotIdentitySHA256:
                    primeSourceSnapshot.referenceIdentitySHA256,
                swiftPackageDescribeIdentitySHA256:
                    swiftPackageDescribe.referenceIdentitySHA256,
                compiledSourceClosureIdentitySHA256:
                    compiledSourceClosure.referenceIdentitySHA256,
                sealedWorkerExecutableIdentitySHA256:
                    sealedWorkerExecutable.referenceIdentitySHA256
            )
        )
    }

    public func validate(
        declaration:
            PrimeNativeNeuralGatePlannedWorkerSourceReferenceDeclaration,
        commonReference:
            PrimeNativeNeuralGateCommonCaptureScheduleReference
    ) throws {
        let expected = try Self(
            declaration: declaration,
            commonReference: commonReference,
            primeSourceSnapshot: primeSourceSnapshot,
            swiftPackageDescribe: swiftPackageDescribe,
            compiledSourceClosure: compiledSourceClosure,
            sealedWorkerExecutable: sealedWorkerExecutable
        )
        guard self == expected,
              !descriptorObservationsPresent,
              !sourcePinningObserved,
              !workerMaterialized,
              !executionObserved,
              !sourceBindingV7Issued
        else {
            throw PrimeNativeNeuralGateRoleArtifactReferenceContractError
                .invalidWorkerSourceReferenceAggregate(workerRole)
        }
    }

    private static func validateExactBindings(
        declaration:
            PrimeNativeNeuralGatePlannedWorkerSourceReferenceDeclaration,
        commonReference:
            PrimeNativeNeuralGateCommonCaptureScheduleReference,
        primeSourceSnapshot:
            PrimeNativeNeuralGatePrimeSourceSnapshotReference,
        swiftPackageDescribe:
            PrimeNativeNeuralGateSwiftPackageDescribeReference,
        compiledSourceClosure:
            PrimeNativeNeuralGateCompiledSourceClosureReference,
        sealedWorkerExecutable:
            PrimeNativeNeuralGateSealedWorkerExecutableReference
    ) throws {
        let artifacts = [
            primeSourceSnapshot.artifact,
            swiftPackageDescribe.artifact,
            compiledSourceClosure.artifact,
            sealedWorkerExecutable.artifact,
        ]
        let sourceIdentity =
            primeSourceSnapshot.artifact.sourceIdentitySHA256
        guard declaration.requiredReferenceKinds
                == PrimeNativeNeuralGateWorkerSourceArtifactReferenceKind
                    .allCases,
              declaration.actualWorkerSourceReference == nil,
              !declaration.sourcePinningObserved,
              artifacts.map(\.referenceKind)
                == PrimeNativeNeuralGateWorkerSourceArtifactReferenceKind
                    .allCases,
              Set(artifacts.map(\.relativePath)).count
                == artifacts.count,
              artifacts.allSatisfy({
                  $0.workerRole == declaration.role
                    && $0.workerTargetName
                        == declaration.targetName
                    && $0.buildConfiguration
                        == declaration.requiredBuildConfiguration
                    && $0.sourceIdentitySHA256 == sourceIdentity
                    && $0.commonCaptureScheduleReferenceIdentitySHA256
                        == commonReference.referenceIdentitySHA256
              }),
              compiledSourceClosure
                .orderedDirectLocalTargetNames
                == declaration.requiredDirectLocalTargetNames
        else {
            throw PrimeNativeNeuralGateRoleArtifactReferenceContractError
                .invalidWorkerSourceReferenceAggregate(
                    declaration.role
                )
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case referenceKind = "reference_kind"
        case workerRole = "worker_role"
        case workerTargetName = "worker_target_name"
        case orderedDirectLocalTargetNames =
            "ordered_direct_local_target_names"
        case commonCaptureScheduleReferenceIdentitySHA256 =
            "common_capture_schedule_reference_identity_sha256"
        case primeSourceSnapshot = "prime_source_snapshot"
        case swiftPackageDescribe = "swift_package_describe"
        case compiledSourceClosure = "compiled_source_closure"
        case sealedWorkerExecutable = "sealed_worker_executable"
        case referenceIdentitySHA256 = "reference_identity_sha256"
        case descriptorObservationsPresent =
            "descriptor_observations_present"
        case sourcePinningObserved = "source_pinning_observed"
        case workerMaterialized = "worker_materialized"
        case executionObserved = "execution_observed"
        case sourceBindingV7Issued = "source_binding_v7_issued"
    }
}

/// Planned source/executable closure for one future worker role. The exact
/// four typed reference kinds are mandatory, while the aggregate stays nil
/// until a live Release closure is captured and reconciled.
public struct PrimeNativeNeuralGatePlannedWorkerSourceReferenceDeclaration:
    Encodable,
    Equatable,
    Sendable
{
    public let role:
        PrimeNativeNeuralGateCorrectedProcessRole
    public let targetName: String
    public let requiredBuildConfiguration: String
    public let requiredDirectLocalTargetNames: [String]
    public let requiredReferenceKinds:
        [PrimeNativeNeuralGateWorkerSourceArtifactReferenceKind]
    public let actualWorkerSourceReference:
        PrimeNativeNeuralGateWorkerSourceReference?
    public let sourcePinningObserved: Bool
    public let workerMaterialized: Bool
    public let executionObserved: Bool
    public let sourceBindingV7Issued: Bool
    public let mechanicsPassAuthorized: Bool
    public let terminalReceiptAuthorized: Bool

    init(
        role: PrimeNativeNeuralGateCorrectedProcessRole,
        targetName: String,
        requiredBuildConfiguration: String = "release",
        requiredDirectLocalTargetNames: [String],
        requiredReferenceKinds:
            [PrimeNativeNeuralGateWorkerSourceArtifactReferenceKind]
                = PrimeNativeNeuralGateWorkerSourceArtifactReferenceKind
                    .allCases,
        actualWorkerSourceReference:
            PrimeNativeNeuralGateWorkerSourceReference? = nil,
        sourcePinningObserved: Bool = false,
        workerMaterialized: Bool = false,
        executionObserved: Bool = false,
        sourceBindingV7Issued: Bool = false,
        mechanicsPassAuthorized: Bool = false,
        terminalReceiptAuthorized: Bool = false
    ) {
        self.role = role
        self.targetName = targetName
        self.requiredBuildConfiguration =
            requiredBuildConfiguration
        self.requiredDirectLocalTargetNames =
            requiredDirectLocalTargetNames
        self.requiredReferenceKinds = requiredReferenceKinds
        self.actualWorkerSourceReference =
            actualWorkerSourceReference
        self.sourcePinningObserved = sourcePinningObserved
        self.workerMaterialized = workerMaterialized
        self.executionObserved = executionObserved
        self.sourceBindingV7Issued = sourceBindingV7Issued
        self.mechanicsPassAuthorized = mechanicsPassAuthorized
        self.terminalReceiptAuthorized = terminalReceiptAuthorized
    }

    private enum CodingKeys: String, CodingKey {
        case role
        case targetName = "target_name"
        case requiredBuildConfiguration =
            "required_build_configuration"
        case requiredDirectLocalTargetNames =
            "required_direct_local_target_names"
        case requiredReferenceKinds = "required_reference_kinds"
        case actualWorkerSourceReference =
            "actual_worker_source_reference"
        case sourcePinningObserved = "source_pinning_observed"
        case workerMaterialized = "worker_materialized"
        case executionObserved = "execution_observed"
        case sourceBindingV7Issued = "source_binding_v7_issued"
        case mechanicsPassAuthorized = "mechanics_pass_authorized"
        case terminalReceiptAuthorized = "terminal_receipt_authorized"
    }
}

/// Future realized content reference. Construction binds content bytes to one
/// exact frozen role/path rule and to the common and branch schedule identities,
/// but still does not prove descriptor origin, publication, or execution.
public struct PrimeNativeNeuralGateRoleArtifactContentReference:
    Encodable,
    Equatable,
    Sendable
{
    public static let schemaID =
        "prime_stage_b_role_artifact_content_reference_v1"

    public let schemaVersion: Int
    public let referenceKind: String
    public let role:
        PrimeNativeNeuralGateCorrectedProcessRole
    public let artifactSchemaID: String
    public let artifactSchemaVersion: Int
    public let artifactSchemaKind:
        PrimeNativeNeuralGateCorrectedSchemaKind
    public let relativePath: String
    public let allowedReaderProcessRoles:
        [PrimeNativeNeuralGateCorrectedProcessRole]
    public let contentSHA256: String
    public let byteCount: UInt64
    public let purpose:
        PrimeNativeNeuralGateArtifactPurpose
    public let mode: String
    public let commonReferenceIdentitySHA256: String
    public let branchReferenceIdentitySHA256: String
    public let referenceIdentitySHA256: String

    public let descriptorContentVerified = false
    public let processDeliveryObserved = false
    public let workerMaterialized = false
    public let executionObserved = false
    public let mechanicsPassAuthorized = false
    public let terminalReceiptAuthorized = false

    public init(
        rule: PrimeNativeNeuralGateRoleArtifactRule,
        contentSHA256: String,
        byteCount: UInt64,
        commonReference:
            PrimeNativeNeuralGateCommonCaptureScheduleReference,
        branchReference:
            PrimeNativeNeuralGateBranchScheduleReference
    ) throws {
        try commonReference.validate()
        try branchReference.validate(
            commonReference: commonReference
        )
        guard rule.branch == branchReference.branch,
              rule.ownerProcessRole.branch
                == branchReference.branch,
              isLowercaseRoleArtifactSHA256(contentSHA256),
              byteCount > 0,
              byteCount <= rule.maximumByteCount,
              rule.purpose == .immutableData,
              rule.mode == "0444",
              rule.contentReferenceRequired,
              !rule.realizedContentPresent
        else {
            throw PrimeNativeNeuralGateRoleArtifactReferenceContractError
                .invalidRoleArtifactContentReference(
                    rule.relativePath
                )
        }
        schemaVersion = 1
        referenceKind = Self.schemaID
        role = rule.ownerProcessRole
        artifactSchemaID = rule.schemaID
        artifactSchemaVersion = rule.schemaVersion
        artifactSchemaKind = rule.schemaKind
        relativePath = rule.relativePath
        allowedReaderProcessRoles =
            rule.allowedReaderProcessRoles
        self.contentSHA256 = contentSHA256
        self.byteCount = byteCount
        purpose = rule.purpose
        mode = rule.mode
        commonReferenceIdentitySHA256 =
            commonReference.referenceIdentitySHA256
        branchReferenceIdentitySHA256 =
            branchReference.referenceIdentitySHA256
        referenceIdentitySHA256 = try roleArtifactReferenceSHA256(
            ContentIdentityPayload(
                magic:
                    PrimeNativeNeuralGateRoleArtifactReferenceContract
                    .frozenV1.roleArtifactContentIdentityMagic,
                schemaVersion: 1,
                referenceKind: Self.schemaID,
                role: rule.ownerProcessRole,
                artifactSchemaID: rule.schemaID,
                artifactSchemaVersion: rule.schemaVersion,
                artifactSchemaKind: rule.schemaKind,
                relativePath: rule.relativePath,
                allowedReaderProcessRoles:
                    rule.allowedReaderProcessRoles,
                contentSHA256: contentSHA256,
                byteCount: byteCount,
                purpose: rule.purpose,
                mode: rule.mode,
                commonReferenceIdentitySHA256:
                    commonReference.referenceIdentitySHA256,
                branchReferenceIdentitySHA256:
                    branchReference.referenceIdentitySHA256
            )
        )
    }

    public func validate(
        rule: PrimeNativeNeuralGateRoleArtifactRule,
        commonReference:
            PrimeNativeNeuralGateCommonCaptureScheduleReference,
        branchReference:
            PrimeNativeNeuralGateBranchScheduleReference
    ) throws {
        let expected = try Self(
            rule: rule,
            contentSHA256: contentSHA256,
            byteCount: byteCount,
            commonReference: commonReference,
            branchReference: branchReference
        )
        guard self == expected,
              !descriptorContentVerified,
              !processDeliveryObserved,
              !workerMaterialized,
              !executionObserved,
              !mechanicsPassAuthorized,
              !terminalReceiptAuthorized
        else {
            throw PrimeNativeNeuralGateRoleArtifactReferenceContractError
                .invalidRoleArtifactContentReference(relativePath)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case referenceKind = "reference_kind"
        case role
        case artifactSchemaID = "artifact_schema_id"
        case artifactSchemaVersion = "artifact_schema_version"
        case artifactSchemaKind = "artifact_schema_kind"
        case relativePath = "relative_path"
        case allowedReaderProcessRoles =
            "allowed_reader_process_roles"
        case contentSHA256 = "content_sha256"
        case byteCount = "byte_count"
        case purpose
        case mode
        case commonReferenceIdentitySHA256 =
            "common_reference_identity_sha256"
        case branchReferenceIdentitySHA256 =
            "branch_reference_identity_sha256"
        case referenceIdentitySHA256 = "reference_identity_sha256"
        case descriptorContentVerified = "descriptor_content_verified"
        case processDeliveryObserved = "process_delivery_observed"
        case workerMaterialized = "worker_materialized"
        case executionObserved = "execution_observed"
        case mechanicsPassAuthorized = "mechanics_pass_authorized"
        case terminalReceiptAuthorized = "terminal_receipt_authorized"
    }
}

public struct PrimeNativeNeuralGateRoleArtifactReferenceContract:
    Encodable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let contractID: String
    public let artifactOutputContractID: String
    public let correctedProcessOwnershipContractID: String
    public let correctedEvaluationOwnershipContractID: String
    public let terminalReceiptOwnershipContractID: String
    public let targetFreeScheduleDeliveryContractID: String
    public let identitySerializationContractID: String
    public let commonReferenceIdentityMagic: String
    public let branchReferenceIdentityMagic: String
    public let primeSourceSnapshotIdentityMagic: String
    public let swiftPackageDescribeIdentityMagic: String
    public let compiledSourceClosureIdentityMagic: String
    public let sealedWorkerExecutableIdentityMagic: String
    public let workerSourceAggregateIdentityMagic: String
    public let roleArtifactContentIdentityMagic: String
    public let maximumRoleArtifactJSONByteCount: UInt64
    public let exactRoleCount: Int
    public let exactRoleScopedArtifactRuleCount: Int
    public let roleArtifactDeclarations:
        [PrimeNativeNeuralGateRoleArtifactDeclaration]
    public let plannedWorkerSourceReferenceDeclarations:
        [PrimeNativeNeuralGatePlannedWorkerSourceReferenceDeclaration]
    public let typedRoleArtifactRulesFrozen: Bool
    public let workerSourceReferenceDeclarationsFrozen: Bool
    public let realizedRoleArtifactContentReferencesPresent: Bool
    public let actualCompiledSourceClosuresPresent: Bool
    public let actualSealedExecutablesPresent: Bool
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

    public static let frozenV1: Self = {
        let maximum =
            PrimeNativeNeuralGateReplayArtifactOutputContract
            .frozenV4.maximumBoundedInMemoryByteCount
        return Self(
            schemaVersion: 1,
            contractID:
                "prime_stage_b_role_artifact_source_reference_contract_v1",
            artifactOutputContractID:
                PrimeNativeNeuralGateReplayArtifactOutputContract
                .frozenV4.contractID,
            correctedProcessOwnershipContractID:
                PrimeNativeNeuralGateCorrectedProcessOwnershipContract
                .frozenV1.contractID,
            correctedEvaluationOwnershipContractID:
                PrimeNativeNeuralGateCorrectedEvaluationOwnershipContract
                .frozenV1.contractID,
            terminalReceiptOwnershipContractID:
                PrimeNativeNeuralGateTerminalReceiptOwnershipContract
                .frozenV1.contractID,
            targetFreeScheduleDeliveryContractID:
                PrimeNativeNeuralGateTargetFreeScheduleDeliveryContract
                .frozenV1.contractID,
            identitySerializationContractID:
                PrimeNativeNeuralGateInvariantCodec
                .serializationContractID,
            commonReferenceIdentityMagic: "PRIMERAC1",
            branchReferenceIdentityMagic: "PRIMERAB1",
            primeSourceSnapshotIdentityMagic: "PRIMEWSS1",
            swiftPackageDescribeIdentityMagic: "PRIMEWSD1",
            compiledSourceClosureIdentityMagic: "PRIMEWSC1",
            sealedWorkerExecutableIdentityMagic: "PRIMEWSE1",
            workerSourceAggregateIdentityMagic: "PRIMEWSA1",
            roleArtifactContentIdentityMagic: "PRIMERAR1",
            maximumRoleArtifactJSONByteCount: maximum,
            exactRoleCount: 10,
            exactRoleScopedArtifactRuleCount: 20,
            roleArtifactDeclarations:
                Self.makeRoleArtifactDeclarations(
                    maximumByteCount: maximum
                ),
            plannedWorkerSourceReferenceDeclarations:
                Self.makePlannedWorkerSourceReferenceDeclarations(),
            typedRoleArtifactRulesFrozen: true,
            workerSourceReferenceDeclarationsFrozen: true,
            realizedRoleArtifactContentReferencesPresent: false,
            actualCompiledSourceClosuresPresent: false,
            actualSealedExecutablesPresent: false,
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
                "This V1 pure contract freezes exact role-to-path ownership rules for the twenty corrected V6 pre-receipt artifacts and planned Release source-reference declarations for the six historical, raw, and evaluation worker roles. It contains no realized content binding, source snapshot, compiled closure, executable, process, delivery, execution, evaluation, PASS, receipt, V7, scientific authority, or product authority. The four supervisor/package-describe roles without worker-source declarations and the four package-describe/historical roles without corrected V6 artifact paths remain explicit rather than receiving invented paths or hashes."
        )
    }()

    public func validate() throws {
        try PrimeNativeNeuralGateReplayArtifactOutputContract
            .frozenV4.validate()
        try PrimeNativeNeuralGateCorrectedProcessOwnershipContract
            .frozenV1.validate()
        try PrimeNativeNeuralGateCorrectedEvaluationOwnershipContract
            .frozenV1.validate()
        try PrimeNativeNeuralGateTerminalReceiptOwnershipContract
            .frozenV1.validate()
        let maximum =
            PrimeNativeNeuralGateReplayArtifactOutputContract
            .frozenV4.maximumBoundedInMemoryByteCount
        try Self.validateRoleArtifactDeclarations(
            roleArtifactDeclarations,
            maximumByteCount: maximum
        )
        try Self.validatePlannedWorkerSourceReferenceDeclarations(
            plannedWorkerSourceReferenceDeclarations
        )
        guard self == .frozenV1,
              schemaVersion == 1,
              artifactOutputContractID
                == PrimeNativeNeuralGateReplayArtifactOutputContract
                .frozenV4.contractID,
              correctedProcessOwnershipContractID
                == PrimeNativeNeuralGateCorrectedProcessOwnershipContract
                .frozenV1.contractID,
              correctedEvaluationOwnershipContractID
                == PrimeNativeNeuralGateCorrectedEvaluationOwnershipContract
                .frozenV1.contractID,
              terminalReceiptOwnershipContractID
                == PrimeNativeNeuralGateTerminalReceiptOwnershipContract
                .frozenV1.contractID,
              targetFreeScheduleDeliveryContractID
                == PrimeNativeNeuralGateTargetFreeScheduleDeliveryContract
                .frozenV1.contractID,
              identitySerializationContractID
                == PrimeNativeNeuralGateInvariantCodec
                .serializationContractID,
              commonReferenceIdentityMagic == "PRIMERAC1",
              branchReferenceIdentityMagic == "PRIMERAB1",
              primeSourceSnapshotIdentityMagic == "PRIMEWSS1",
              swiftPackageDescribeIdentityMagic == "PRIMEWSD1",
              compiledSourceClosureIdentityMagic == "PRIMEWSC1",
              sealedWorkerExecutableIdentityMagic == "PRIMEWSE1",
              workerSourceAggregateIdentityMagic == "PRIMEWSA1",
              roleArtifactContentIdentityMagic == "PRIMERAR1",
              maximumRoleArtifactJSONByteCount == maximum,
              exactRoleCount == 10,
              exactRoleScopedArtifactRuleCount == 20,
              typedRoleArtifactRulesFrozen,
              workerSourceReferenceDeclarationsFrozen,
              !realizedRoleArtifactContentReferencesPresent,
              !actualCompiledSourceClosuresPresent,
              !actualSealedExecutablesPresent,
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
            throw PrimeNativeNeuralGateRoleArtifactReferenceContractError
                .invalidFrozenContract
        }
    }

    public func contentSHA256() throws -> String {
        try validate()
        return try roleArtifactReferenceSHA256(self)
    }

    static func validateRoleArtifactDeclarations(
        _ declarations:
            [PrimeNativeNeuralGateRoleArtifactDeclaration],
        maximumByteCount: UInt64
    ) throws {
        let expected = makeRoleArtifactDeclarations(
            maximumByteCount: maximumByteCount
        )
        let rules = declarations.flatMap(\.artifactRules)
        let expectedPaths =
            PrimeNativeNeuralGateTerminalReceiptOwnershipContract
            .preReceiptOwnedArtifactPaths()
        guard declarations == expected,
              declarations.count == 10,
              declarations.map(\.role)
                == PrimeNativeNeuralGateCorrectedProcessRole.allCases,
              Set(declarations.map(\.role)).count == 10,
              declarations.allSatisfy({
                  $0.realizedContentReferenceCount == 0
                    && !$0.processMaterialized
                    && !$0.executionObserved
              }),
              rules.count == 20,
              Set(rules.map(\.relativePath)).count == 20,
              rules.map(\.relativePath).sorted()
                == expectedPaths.sorted()
        else {
            throw PrimeNativeNeuralGateRoleArtifactReferenceContractError
                .invalidRoleDeclarationInventory
        }
        let ownerships = allRoleScopedOwnerships()
        for rule in rules {
            guard let ownership = ownerships.first(where: {
                $0.relativePath == rule.relativePath
            }) else {
                throw PrimeNativeNeuralGateRoleArtifactReferenceContractError
                    .invalidRoleArtifactRule(rule.relativePath)
            }
            try rule.validate(
                against: ownership,
                maximumByteCount: maximumByteCount
            )
        }
    }

    static func validatePlannedWorkerSourceReferenceDeclarations(
        _ declarations:
            [PrimeNativeNeuralGatePlannedWorkerSourceReferenceDeclaration]
    ) throws {
        let expected = makePlannedWorkerSourceReferenceDeclarations()
        guard declarations == expected,
              declarations.count == 6,
              Set(declarations.map(\.role)).count == 6
        else {
            throw PrimeNativeNeuralGateRoleArtifactReferenceContractError
                .invalidFrozenContract
        }
        for declaration in declarations {
            guard declaration.role.kind == .historicalWorker
                    || declaration.role.kind == .correctedRawWorker
                    || declaration.role.kind
                        == .correctedEvaluationWorker,
                  !declaration.targetName.isEmpty,
                  declaration.requiredBuildConfiguration == "release",
                  !declaration.requiredDirectLocalTargetNames.isEmpty,
                  Set(
                      declaration.requiredDirectLocalTargetNames
                  ).count
                    == declaration.requiredDirectLocalTargetNames.count,
                  declaration.requiredDirectLocalTargetNames
                    .allSatisfy(isSafeRoleArtifactTargetName),
                  declaration.requiredReferenceKinds
                    == PrimeNativeNeuralGateWorkerSourceArtifactReferenceKind
                        .allCases,
                  declaration.actualWorkerSourceReference == nil,
                  !declaration.sourcePinningObserved,
                  !declaration.workerMaterialized,
                  !declaration.executionObserved,
                  !declaration.sourceBindingV7Issued,
                  !declaration.mechanicsPassAuthorized,
                  !declaration.terminalReceiptAuthorized
            else {
                throw PrimeNativeNeuralGateRoleArtifactReferenceContractError
                    .invalidWorkerSourceReferenceDeclaration(
                        declaration.role
                    )
            }
        }
    }

    private static func makeRoleArtifactDeclarations(
        maximumByteCount: UInt64
    ) -> [PrimeNativeNeuralGateRoleArtifactDeclaration] {
        let ownerships = allRoleScopedOwnerships()
        return PrimeNativeNeuralGateCorrectedProcessRole.allCases.map {
            role in
            let rules = ownerships
                .filter { $0.ownerProcessRole == role }
                .map {
                    PrimeNativeNeuralGateRoleArtifactRule(
                        ownership: $0,
                        maximumByteCount: maximumByteCount
                    )
                }
                .sorted {
                    rawUTF8RoleArtifactLess(
                        $0.relativePath,
                        $1.relativePath
                    )
                }
            return PrimeNativeNeuralGateRoleArtifactDeclaration(
                role: role,
                artifactRules: rules
            )
        }
    }

    private static func allRoleScopedOwnerships()
        -> [PrimeNativeNeuralGateRoleScopedSchemaOwnership]
    {
        PrimeNativeNeuralGateCorrectedProcessOwnershipContract
            .frozenV1.roleScopedRawSchemas
            + PrimeNativeNeuralGateCorrectedEvaluationOwnershipContract
            .frozenV1.roleScopedEvaluationSchemas
    }

    private static func makePlannedWorkerSourceReferenceDeclarations()
        -> [PrimeNativeNeuralGatePlannedWorkerSourceReferenceDeclaration]
    {
        let historical = [
            "PrimeCore",
            "ErgenticsPrimeRuntime",
            "PrimeNativeNeuralGateHistoricalReplayMechanics",
            "PrimeNativeNeuralGateReplayTransport",
        ]
        let raw = [
            "PrimeNativeNeuralGateCorrectedMechanics",
            "PrimeNativeNeuralGatePromptSolver",
            "PrimeNativeNeuralGateLogitSidecarMechanics",
            "PrimeNativeNeuralGateReplayArtifactContracts",
            "PrimeNativeNeuralGateTargetFreeScheduleDeliveryContracts",
            "PrimeNativeNeuralGateCorrectedProcessOwnershipContracts",
        ]
        let evaluation = [
            "PrimeCore",
            "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
            "PrimeNativeNeuralGatePromptTargetCrosswalkAuthority",
            "PrimeNativeNeuralGateCorrectedEvaluationOwnershipContracts",
        ]
        return [
            PrimeNativeNeuralGatePlannedWorkerSourceReferenceDeclaration(
                role: .probeHistoricalWorker,
                targetName:
                    "PrimeNativeNeuralGateHistoricalFixtureWorker",
                requiredDirectLocalTargetNames: historical
            ),
            PrimeNativeNeuralGatePlannedWorkerSourceReferenceDeclaration(
                role: .verifierHistoricalWorker,
                targetName:
                    "PrimeNativeNeuralGateHistoricalFixtureWorker",
                requiredDirectLocalTargetNames: historical
            ),
            PrimeNativeNeuralGatePlannedWorkerSourceReferenceDeclaration(
                role: .probeCorrectedRawWorker,
                targetName:
                    "PrimeNativeNeuralGateCorrectedRawWorker",
                requiredDirectLocalTargetNames: raw
            ),
            PrimeNativeNeuralGatePlannedWorkerSourceReferenceDeclaration(
                role: .verifierCorrectedRawWorker,
                targetName:
                    "PrimeNativeNeuralGateCorrectedRawWorker",
                requiredDirectLocalTargetNames: raw
            ),
            PrimeNativeNeuralGatePlannedWorkerSourceReferenceDeclaration(
                role: .probeCorrectedEvaluationWorker,
                targetName:
                    "PrimeNativeNeuralGateCorrectedProbeEvaluationWorker",
                requiredDirectLocalTargetNames: evaluation
            ),
            PrimeNativeNeuralGatePlannedWorkerSourceReferenceDeclaration(
                role: .verifierCorrectedEvaluationWorker,
                targetName:
                    "PrimeNativeNeuralGateCorrectedVerifierEvaluationWorker",
                requiredDirectLocalTargetNames: evaluation
            ),
        ]
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case contractID = "contract_id"
        case artifactOutputContractID = "artifact_output_contract_id"
        case correctedProcessOwnershipContractID =
            "corrected_process_ownership_contract_id"
        case correctedEvaluationOwnershipContractID =
            "corrected_evaluation_ownership_contract_id"
        case terminalReceiptOwnershipContractID =
            "terminal_receipt_ownership_contract_id"
        case targetFreeScheduleDeliveryContractID =
            "target_free_schedule_delivery_contract_id"
        case identitySerializationContractID =
            "identity_serialization_contract_id"
        case commonReferenceIdentityMagic =
            "common_reference_identity_magic"
        case branchReferenceIdentityMagic =
            "branch_reference_identity_magic"
        case primeSourceSnapshotIdentityMagic =
            "prime_source_snapshot_identity_magic"
        case swiftPackageDescribeIdentityMagic =
            "swift_package_describe_identity_magic"
        case compiledSourceClosureIdentityMagic =
            "compiled_source_closure_identity_magic"
        case sealedWorkerExecutableIdentityMagic =
            "sealed_worker_executable_identity_magic"
        case workerSourceAggregateIdentityMagic =
            "worker_source_aggregate_identity_magic"
        case roleArtifactContentIdentityMagic =
            "role_artifact_content_identity_magic"
        case maximumRoleArtifactJSONByteCount =
            "maximum_role_artifact_json_byte_count"
        case exactRoleCount = "exact_role_count"
        case exactRoleScopedArtifactRuleCount =
            "exact_role_scoped_artifact_rule_count"
        case roleArtifactDeclarations = "role_artifact_declarations"
        case plannedWorkerSourceReferenceDeclarations =
            "planned_worker_source_reference_declarations"
        case typedRoleArtifactRulesFrozen =
            "typed_role_artifact_rules_frozen"
        case workerSourceReferenceDeclarationsFrozen =
            "worker_source_reference_declarations_frozen"
        case realizedRoleArtifactContentReferencesPresent =
            "realized_role_artifact_content_references_present"
        case actualCompiledSourceClosuresPresent =
            "actual_compiled_source_closures_present"
        case actualSealedExecutablesPresent =
            "actual_sealed_executables_present"
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

private struct WorkerTypedArtifactIdentityPayload: Encodable {
    let magic: String
    let schemaVersion: Int
    let referenceKind: String
    let artifact:
        PrimeNativeNeuralGateWorkerSourceArtifactDescriptor
    let orderedDirectLocalTargetNames: [String]?

    private enum CodingKeys: String, CodingKey {
        case magic
        case schemaVersion = "schema_version"
        case referenceKind = "reference_kind"
        case artifact
        case orderedDirectLocalTargetNames =
            "ordered_direct_local_target_names"
    }
}

private struct WorkerSourceAggregateIdentityPayload: Encodable {
    let magic: String
    let schemaVersion: Int
    let referenceKind: String
    let workerRole:
        PrimeNativeNeuralGateCorrectedProcessRole
    let workerTargetName: String
    let orderedDirectLocalTargetNames: [String]
    let commonCaptureScheduleReferenceIdentitySHA256: String
    let primeSourceSnapshotIdentitySHA256: String
    let swiftPackageDescribeIdentitySHA256: String
    let compiledSourceClosureIdentitySHA256: String
    let sealedWorkerExecutableIdentitySHA256: String

    private enum CodingKeys: String, CodingKey {
        case magic
        case schemaVersion = "schema_version"
        case referenceKind = "reference_kind"
        case workerRole = "worker_role"
        case workerTargetName = "worker_target_name"
        case orderedDirectLocalTargetNames =
            "ordered_direct_local_target_names"
        case commonCaptureScheduleReferenceIdentitySHA256 =
            "common_capture_schedule_reference_identity_sha256"
        case primeSourceSnapshotIdentitySHA256 =
            "prime_source_snapshot_identity_sha256"
        case swiftPackageDescribeIdentitySHA256 =
            "swift_package_describe_identity_sha256"
        case compiledSourceClosureIdentitySHA256 =
            "compiled_source_closure_identity_sha256"
        case sealedWorkerExecutableIdentitySHA256 =
            "sealed_worker_executable_identity_sha256"
    }
}

private struct CommonIdentityPayload: Encodable {
    let magic: String
    let schemaVersion: Int
    let referenceKind: String
    let captureInventoryContractID: String
    let targetFreeScheduleDeliveryContractID: String
    let captureIdentitySHA256: String
    let sourceRootIdentity:
        PrimeNativeNeuralGateTargetFreeSourceRootIdentity
    let promptSourceBindingSHA256: String
    let scheduleIdentitySHA256: String

    private enum CodingKeys: String, CodingKey {
        case magic
        case schemaVersion = "schema_version"
        case referenceKind = "reference_kind"
        case captureInventoryContractID =
            "capture_inventory_contract_id"
        case targetFreeScheduleDeliveryContractID =
            "target_free_schedule_delivery_contract_id"
        case captureIdentitySHA256 = "capture_identity_sha256"
        case sourceRootIdentity = "source_root_identity"
        case promptSourceBindingSHA256 =
            "prompt_source_binding_sha256"
        case scheduleIdentitySHA256 = "schedule_identity_sha256"
    }
}

private struct BranchIdentityPayload: Encodable {
    let magic: String
    let schemaVersion: Int
    let referenceKind: String
    let branch: PrimeNativeNeuralGateCorrectedProcessBranch
    let invocationRole:
        PrimeNativeNeuralGateTargetFreeScheduleInvocationRole
    let commonReferenceIdentitySHA256: String
    let rawCandidateIdentitySHA256: String
    let outerCandidateIdentitySHA256: String
    let deliveryIdentitySHA256: String

    private enum CodingKeys: String, CodingKey {
        case magic
        case schemaVersion = "schema_version"
        case referenceKind = "reference_kind"
        case branch
        case invocationRole = "invocation_role"
        case commonReferenceIdentitySHA256 =
            "common_reference_identity_sha256"
        case rawCandidateIdentitySHA256 =
            "raw_candidate_identity_sha256"
        case outerCandidateIdentitySHA256 =
            "outer_candidate_identity_sha256"
        case deliveryIdentitySHA256 = "delivery_identity_sha256"
    }
}

private struct ContentIdentityPayload: Encodable {
    let magic: String
    let schemaVersion: Int
    let referenceKind: String
    let role: PrimeNativeNeuralGateCorrectedProcessRole
    let artifactSchemaID: String
    let artifactSchemaVersion: Int
    let artifactSchemaKind:
        PrimeNativeNeuralGateCorrectedSchemaKind
    let relativePath: String
    let allowedReaderProcessRoles:
        [PrimeNativeNeuralGateCorrectedProcessRole]
    let contentSHA256: String
    let byteCount: UInt64
    let purpose: PrimeNativeNeuralGateArtifactPurpose
    let mode: String
    let commonReferenceIdentitySHA256: String
    let branchReferenceIdentitySHA256: String

    private enum CodingKeys: String, CodingKey {
        case magic
        case schemaVersion = "schema_version"
        case referenceKind = "reference_kind"
        case role
        case artifactSchemaID = "artifact_schema_id"
        case artifactSchemaVersion = "artifact_schema_version"
        case artifactSchemaKind = "artifact_schema_kind"
        case relativePath = "relative_path"
        case allowedReaderProcessRoles =
            "allowed_reader_process_roles"
        case contentSHA256 = "content_sha256"
        case byteCount = "byte_count"
        case purpose
        case mode
        case commonReferenceIdentitySHA256 =
            "common_reference_identity_sha256"
        case branchReferenceIdentitySHA256 =
            "branch_reference_identity_sha256"
    }
}

private func roleArtifactReferenceSHA256<Value: Encodable>(
    _ value: Value
) throws -> String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
    do {
        return PrimeNativeNeuralGateInvariantCodec.sha256(
            try encoder.encode(value)
        )
    } catch {
        throw PrimeNativeNeuralGateRoleArtifactReferenceContractError
            .canonicalEncodingRejected
    }
}

private func isLowercaseRoleArtifactSHA256(
    _ value: String
) -> Bool {
    value.utf8.count == 64
        && value.utf8.allSatisfy {
            ($0 >= 48 && $0 <= 57)
                || ($0 >= 97 && $0 <= 102)
        }
}

private func isSafeRoleArtifactRelativePath(
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

private func isSafeRoleArtifactTargetName(
    _ value: String
) -> Bool {
    !value.isEmpty
        && value.utf8.count <= 160
        && value.utf8.allSatisfy {
            ($0 >= 48 && $0 <= 57)
                || ($0 >= 65 && $0 <= 90)
                || ($0 >= 97 && $0 <= 122)
                || $0 == 95
        }
}

private func rawUTF8RoleArtifactLess(
    _ lhs: String,
    _ rhs: String
) -> Bool {
    lhs.utf8.lexicographicallyPrecedes(rhs.utf8)
}
