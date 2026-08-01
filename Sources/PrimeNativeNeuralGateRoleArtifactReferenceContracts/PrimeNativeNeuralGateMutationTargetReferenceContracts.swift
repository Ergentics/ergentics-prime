import Foundation
import PrimeNativeNeuralGateReplayMechanics

public enum PrimeNativeNeuralGateMutationTargetReferenceError:
    Error,
    Equatable,
    Sendable
{
    case invalidSourceReference
    case invalidDeclaration
    case invalidFrozenContract
    case canonicalEncodingRejected
}

/// The two corrected-mutation implementation roles are library roles only.
/// They do not extend the frozen Stage-B worker/process roster.
public enum PrimeNativeNeuralGateMutationTargetRole:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Sendable
{
    case producer
    case detector
}

/// A future Release source observation for one internal mutation target.
///
/// This deliberately has no executable reference: the V8 targets are
/// internal libraries, not workers or processes. Merely constructing this
/// value does not authorize it; the frozen V1 declarations retain `nil` until
/// a later live source-closure capture is issued.
public struct PrimeNativeNeuralGateMutationTargetSourceReference:
    Encodable,
    Equatable,
    Sendable
{
    public static let schemaID =
        "prime_stage_b_mutation_library_source_reference_v1"

    public let schemaVersion: Int
    public let referenceKind: String
    public let role: PrimeNativeNeuralGateMutationTargetRole
    public let targetName: String
    public let packageDescriptionSHA256: String
    public let primeSourceSnapshotSHA256: String
    public let compiledSourceClosureSHA256: String
    public let buildConfiguration: String
    public let referenceIdentitySHA256: String

    public let executableReferencePresent = false
    public let processObservationPresent = false
    public let executionAuthorityEstablished = false
    public let mechanicsPassAuthorized = false
    public let receiptAuthorized = false
    public let scientificAuthorityAuthorized = false
    public let productAuthorityAuthorized = false

    public init(
        role: PrimeNativeNeuralGateMutationTargetRole,
        targetName: String,
        packageDescriptionSHA256: String,
        primeSourceSnapshotSHA256: String,
        compiledSourceClosureSHA256: String,
        buildConfiguration: String
    ) throws {
        schemaVersion = 1
        referenceKind = Self.schemaID
        self.role = role
        self.targetName = targetName
        self.packageDescriptionSHA256 = packageDescriptionSHA256
        self.primeSourceSnapshotSHA256 = primeSourceSnapshotSHA256
        self.compiledSourceClosureSHA256 = compiledSourceClosureSHA256
        self.buildConfiguration = buildConfiguration
        try Self.validateScalars(
            role: role,
            targetName: targetName,
            packageDescriptionSHA256: packageDescriptionSHA256,
            primeSourceSnapshotSHA256: primeSourceSnapshotSHA256,
            compiledSourceClosureSHA256: compiledSourceClosureSHA256,
            buildConfiguration: buildConfiguration
        )
        referenceIdentitySHA256 = try mutationTargetSHA256(
            IdentityPayload(
                schemaVersion: 1,
                referenceKind: Self.schemaID,
                role: role,
                targetName: targetName,
                packageDescriptionSHA256: packageDescriptionSHA256,
                primeSourceSnapshotSHA256: primeSourceSnapshotSHA256,
                compiledSourceClosureSHA256: compiledSourceClosureSHA256,
                buildConfiguration: buildConfiguration
            )
        )
    }

    public func validate() throws {
        try Self.validateScalars(
            role: role,
            targetName: targetName,
            packageDescriptionSHA256: packageDescriptionSHA256,
            primeSourceSnapshotSHA256: primeSourceSnapshotSHA256,
            compiledSourceClosureSHA256: compiledSourceClosureSHA256,
            buildConfiguration: buildConfiguration
        )
        let expected = try mutationTargetSHA256(
            IdentityPayload(
                schemaVersion: schemaVersion,
                referenceKind: referenceKind,
                role: role,
                targetName: targetName,
                packageDescriptionSHA256: packageDescriptionSHA256,
                primeSourceSnapshotSHA256: primeSourceSnapshotSHA256,
                compiledSourceClosureSHA256: compiledSourceClosureSHA256,
                buildConfiguration: buildConfiguration
            )
        )
        guard schemaVersion == 1,
              referenceKind == Self.schemaID,
              referenceIdentitySHA256 == expected,
              !executableReferencePresent,
              !processObservationPresent,
              !executionAuthorityEstablished,
              !mechanicsPassAuthorized,
              !receiptAuthorized,
              !scientificAuthorityAuthorized,
              !productAuthorityAuthorized
        else {
            throw PrimeNativeNeuralGateMutationTargetReferenceError
                .invalidSourceReference
        }
    }

    private static func validateScalars(
        role: PrimeNativeNeuralGateMutationTargetRole,
        targetName: String,
        packageDescriptionSHA256: String,
        primeSourceSnapshotSHA256: String,
        compiledSourceClosureSHA256: String,
        buildConfiguration: String
    ) throws {
        guard targetName == role.targetName,
              buildConfiguration == "release",
              isLowercaseMutationTargetSHA256(
                  packageDescriptionSHA256
              ),
              isLowercaseMutationTargetSHA256(
                  primeSourceSnapshotSHA256
              ),
              isLowercaseMutationTargetSHA256(
                  compiledSourceClosureSHA256
              )
        else {
            throw PrimeNativeNeuralGateMutationTargetReferenceError
                .invalidSourceReference
        }
    }

    private struct IdentityPayload: Encodable {
        let schemaVersion: Int
        let referenceKind: String
        let role: PrimeNativeNeuralGateMutationTargetRole
        let targetName: String
        let packageDescriptionSHA256: String
        let primeSourceSnapshotSHA256: String
        let compiledSourceClosureSHA256: String
        let buildConfiguration: String

        private enum CodingKeys: String, CodingKey {
            case schemaVersion = "schema_version"
            case referenceKind = "reference_kind"
            case role
            case targetName = "target_name"
            case packageDescriptionSHA256 =
                "package_description_sha256"
            case primeSourceSnapshotSHA256 =
                "prime_source_snapshot_sha256"
            case compiledSourceClosureSHA256 =
                "compiled_source_closure_sha256"
            case buildConfiguration = "build_configuration"
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case referenceKind = "reference_kind"
        case role
        case targetName = "target_name"
        case packageDescriptionSHA256 =
            "package_description_sha256"
        case primeSourceSnapshotSHA256 =
            "prime_source_snapshot_sha256"
        case compiledSourceClosureSHA256 =
            "compiled_source_closure_sha256"
        case buildConfiguration = "build_configuration"
        case referenceIdentitySHA256 = "reference_identity_sha256"
        case executableReferencePresent =
            "executable_reference_present"
        case processObservationPresent =
            "process_observation_present"
        case executionAuthorityEstablished =
            "execution_authority_established"
        case mechanicsPassAuthorized = "mechanics_pass_authorized"
        case receiptAuthorized = "receipt_authorized"
        case scientificAuthorityAuthorized =
            "scientific_authority_authorized"
        case productAuthorityAuthorized = "product_authority_authorized"
    }
}

public extension PrimeNativeNeuralGateMutationTargetRole {
    var targetName: String {
        switch self {
        case .producer:
            "PrimeNativeNeuralGateCorrectedMutationProducer"
        case .detector:
            "PrimeNativeNeuralGateCorrectedMutationDetector"
        }
    }

    var sourceDirectoryPath: String {
        "Sources/\(targetName)"
    }

    var directLocalTargetDependencyNames: [String] {
        switch self {
        case .producer:
            [
                "PrimeNativeNeuralGateSemanticRecordContracts",
                "PrimeNativeNeuralGateCorrectedMutationSurfaceContracts",
            ]
        case .detector:
            [
                "PrimeNativeNeuralGateCorrectedMutationSurfaceContracts",
            ]
        }
    }

    var orderedContractIDs: [String] {
        switch self {
        case .producer:
            [
                "prime_stage_b_semantic_record_schema_contract_v1",
                "prime_stage_b_corrected_mutation_label_free_surface_contract_v1",
            ]
        case .detector:
            [
                "prime_stage_b_corrected_mutation_label_free_surface_contract_v1",
            ]
        }
    }
}

public struct PrimeNativeNeuralGateMutationTargetSourceReferenceDeclaration:
    Encodable,
    Equatable,
    Sendable
{
    public let role: PrimeNativeNeuralGateMutationTargetRole
    public let targetName: String
    public let targetKind: String
    public let sourceDirectoryPath: String
    public let directLocalTargetDependencyNames: [String]
    public let orderedContractIDs: [String]
    public let requiredBuildConfiguration: String
    public let requiredSourceReferenceKinds: [String]
    public let actualSourceReference:
        PrimeNativeNeuralGateMutationTargetSourceReference?

    public let targetAssignmentFrozen = true
    public let targetImplementationPresent = true
    public let sourceReferenceObserved: Bool
    public let sourceBindingV7Issued = false
    public let workerMaterialized = false
    public let processDeliveryObserved = false
    public let modelExecutionEstablished = false
    public let mechanicsPassAuthorized = false
    public let terminalReceiptAuthorized = false
    public let scientificAuthorityAuthorized = false
    public let productAuthorityAuthorized = false

    public init(
        role: PrimeNativeNeuralGateMutationTargetRole,
        actualSourceReference:
            PrimeNativeNeuralGateMutationTargetSourceReference? = nil
    ) throws {
        self.role = role
        targetName = role.targetName
        targetKind = "internal_swift_library"
        sourceDirectoryPath = role.sourceDirectoryPath
        directLocalTargetDependencyNames =
            role.directLocalTargetDependencyNames
        orderedContractIDs = role.orderedContractIDs
        requiredBuildConfiguration = "release"
        requiredSourceReferenceKinds = [
            "swift_package_description",
            "prime_source_snapshot",
            "compiled_source_closure",
        ]
        self.actualSourceReference = actualSourceReference
        sourceReferenceObserved = actualSourceReference != nil
        try validate()
    }

    public func validate() throws {
        if let actualSourceReference {
            try actualSourceReference.validate()
        }
        guard targetName == role.targetName,
              targetKind == "internal_swift_library",
              sourceDirectoryPath == role.sourceDirectoryPath,
              directLocalTargetDependencyNames
                == role.directLocalTargetDependencyNames,
              orderedContractIDs == role.orderedContractIDs,
              requiredBuildConfiguration == "release",
              requiredSourceReferenceKinds == [
                  "swift_package_description",
                  "prime_source_snapshot",
                  "compiled_source_closure",
              ],
              actualSourceReference == nil
                || (actualSourceReference?.role == role
                    && actualSourceReference?.targetName == targetName),
              sourceReferenceObserved
                == (actualSourceReference != nil),
              targetAssignmentFrozen,
              targetImplementationPresent,
              !sourceBindingV7Issued,
              !workerMaterialized,
              !processDeliveryObserved,
              !modelExecutionEstablished,
              !mechanicsPassAuthorized,
              !terminalReceiptAuthorized,
              !scientificAuthorityAuthorized,
              !productAuthorityAuthorized
        else {
            throw PrimeNativeNeuralGateMutationTargetReferenceError
                .invalidDeclaration
        }
    }

    private enum CodingKeys: String, CodingKey {
        case role
        case targetName = "target_name"
        case targetKind = "target_kind"
        case sourceDirectoryPath = "source_directory_path"
        case directLocalTargetDependencyNames =
            "direct_local_target_dependency_names"
        case orderedContractIDs = "ordered_contract_ids"
        case requiredBuildConfiguration =
            "required_build_configuration"
        case requiredSourceReferenceKinds =
            "required_source_reference_kinds"
        case actualSourceReference = "actual_source_reference"
        case targetAssignmentFrozen = "target_assignment_frozen"
        case targetImplementationPresent =
            "target_implementation_present"
        case sourceReferenceObserved = "source_reference_observed"
        case sourceBindingV7Issued = "source_binding_v7_issued"
        case workerMaterialized = "worker_materialized"
        case processDeliveryObserved = "process_delivery_observed"
        case modelExecutionEstablished = "model_execution_established"
        case mechanicsPassAuthorized = "mechanics_pass_authorized"
        case terminalReceiptAuthorized = "terminal_receipt_authorized"
        case scientificAuthorityAuthorized =
            "scientific_authority_authorized"
        case productAuthorityAuthorized = "product_authority_authorized"
    }
}

public struct PrimeNativeNeuralGateMutationTargetOwnershipContract:
    Encodable,
    Equatable,
    Sendable
{
    public static let frozenV1: Self = {
        do {
            return try Self(
                schemaVersion: 1,
                contractID:
                    "prime_stage_b_corrected_mutation_producer_detector_source_assignment_v1",
                orderedContractIDs: [
                    "prime_stage_b_semantic_record_schema_contract_v1",
                    "prime_stage_b_corrected_mutation_label_free_surface_contract_v1",
                ],
                declarations:
                    PrimeNativeNeuralGateMutationTargetRole.allCases.map {
                        try PrimeNativeNeuralGateMutationTargetSourceReferenceDeclaration(
                            role: $0
                        )
                    },
                mutationProducerDetectorMustBeDisjoint: true,
                sharedMutationImplementationSourceForbidden: true,
                internalLibraryTargetsRequired: true,
                productOrExecutableTargetsForbidden: true,
                sourceReferencesDeferred: true,
                nextPrerequisite:
                    "derive_source_pinned_historical_gate_carrier_and_forty_six_mutation_material_without_materializing_workers_or_issuing_source_binding_v7"
            )
        } catch {
            preconditionFailure("invalid frozen mutation target ownership contract: \(error)")
        }
    }()

    public let schemaVersion: Int
    public let contractID: String
    public let orderedContractIDs: [String]
    public let declarations:
        [PrimeNativeNeuralGateMutationTargetSourceReferenceDeclaration]
    public let mutationProducerDetectorMustBeDisjoint: Bool
    public let sharedMutationImplementationSourceForbidden: Bool
    public let internalLibraryTargetsRequired: Bool
    public let productOrExecutableTargetsForbidden: Bool
    public let sourceReferencesDeferred: Bool
    public let nextPrerequisite: String

    public let executionImplemented = false
    public let sourceBindingV7Issued = false
    public let processDeliveryObserved = false
    public let workerMaterialized = false
    public let modelExecutionEstablished = false
    public let mechanicsPassAuthorized = false
    public let terminalReceiptAuthorized = false
    public let scientificAuthorityAuthorized = false
    public let productAuthorityAuthorized = false

    public init(
        schemaVersion: Int,
        contractID: String,
        orderedContractIDs: [String],
        declarations:
            [PrimeNativeNeuralGateMutationTargetSourceReferenceDeclaration],
        mutationProducerDetectorMustBeDisjoint: Bool,
        sharedMutationImplementationSourceForbidden: Bool,
        internalLibraryTargetsRequired: Bool,
        productOrExecutableTargetsForbidden: Bool,
        sourceReferencesDeferred: Bool,
        nextPrerequisite: String
    ) throws {
        self.schemaVersion = schemaVersion
        self.contractID = contractID
        self.orderedContractIDs = orderedContractIDs
        self.declarations = declarations
        self.mutationProducerDetectorMustBeDisjoint =
            mutationProducerDetectorMustBeDisjoint
        self.sharedMutationImplementationSourceForbidden =
            sharedMutationImplementationSourceForbidden
        self.internalLibraryTargetsRequired = internalLibraryTargetsRequired
        self.productOrExecutableTargetsForbidden =
            productOrExecutableTargetsForbidden
        self.sourceReferencesDeferred = sourceReferencesDeferred
        self.nextPrerequisite = nextPrerequisite
        try validate()
    }

    public func validate() throws {
        try declarations.forEach { try $0.validate() }
        let expected = try PrimeNativeNeuralGateMutationTargetRole
            .allCases.map {
                try PrimeNativeNeuralGateMutationTargetSourceReferenceDeclaration(
                    role: $0
                )
            }
        guard schemaVersion == 1,
              contractID
                == "prime_stage_b_corrected_mutation_producer_detector_source_assignment_v1",
              orderedContractIDs == [
                  "prime_stage_b_semantic_record_schema_contract_v1",
                  "prime_stage_b_corrected_mutation_label_free_surface_contract_v1",
              ],
              declarations == expected,
              mutationProducerDetectorMustBeDisjoint,
              sharedMutationImplementationSourceForbidden,
              internalLibraryTargetsRequired,
              productOrExecutableTargetsForbidden,
              sourceReferencesDeferred,
              nextPrerequisite
                == "derive_source_pinned_historical_gate_carrier_and_forty_six_mutation_material_without_materializing_workers_or_issuing_source_binding_v7",
              !executionImplemented,
              !sourceBindingV7Issued,
              !processDeliveryObserved,
              !workerMaterialized,
              !modelExecutionEstablished,
              !mechanicsPassAuthorized,
              !terminalReceiptAuthorized,
              !scientificAuthorityAuthorized,
              !productAuthorityAuthorized
        else {
            throw PrimeNativeNeuralGateMutationTargetReferenceError
                .invalidFrozenContract
        }
    }

    public func contentSHA256() throws -> String {
        try mutationTargetSHA256(self)
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case contractID = "contract_id"
        case orderedContractIDs = "ordered_contract_ids"
        case declarations
        case mutationProducerDetectorMustBeDisjoint =
            "mutation_producer_detector_must_be_disjoint"
        case sharedMutationImplementationSourceForbidden =
            "shared_mutation_implementation_source_forbidden"
        case internalLibraryTargetsRequired =
            "internal_library_targets_required"
        case productOrExecutableTargetsForbidden =
            "product_or_executable_targets_forbidden"
        case sourceReferencesDeferred = "source_references_deferred"
        case nextPrerequisite = "next_prerequisite"
        case executionImplemented = "execution_implemented"
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

private func mutationTargetSHA256<Value: Encodable>(
    _ value: Value
) throws -> String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
    do {
        return PrimeNativeNeuralGateInvariantCodec.sha256(
            try encoder.encode(value)
        )
    } catch {
        throw PrimeNativeNeuralGateMutationTargetReferenceError
            .canonicalEncodingRejected
    }
}

private func isLowercaseMutationTargetSHA256(
    _ value: String
) -> Bool {
    value.utf8.count == 64
        && value.utf8.allSatisfy {
            ($0 >= 48 && $0 <= 57)
                || ($0 >= 97 && $0 <= 102)
        }
}
