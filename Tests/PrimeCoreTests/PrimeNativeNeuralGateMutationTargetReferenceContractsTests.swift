import XCTest
@testable import PrimeNativeNeuralGateRoleArtifactReferenceContracts

final class PrimeNativeNeuralGateMutationTargetReferenceContractsTests:
    XCTestCase
{
    func testFrozenAssignmentIsTwoDisjointInternalLibrariesWithoutSourceEvidence()
        throws
    {
        let contract =
            PrimeNativeNeuralGateMutationTargetOwnershipContract
            .frozenV1
        XCTAssertNoThrow(try contract.validate())
        XCTAssertEqual(contract.schemaVersion, 1)
        XCTAssertEqual(
            contract.contractID,
            "prime_stage_b_corrected_mutation_producer_detector_source_assignment_v1"
        )
        XCTAssertEqual(
            contract.declarations.map(\.role),
            PrimeNativeNeuralGateMutationTargetRole.allCases
        )
        XCTAssertEqual(
            contract.declarations.map(\.targetName),
            [
                "PrimeNativeNeuralGateCorrectedMutationProducer",
                "PrimeNativeNeuralGateCorrectedMutationDetector",
            ]
        )
        XCTAssertEqual(
            contract.orderedContractIDs,
            [
                "prime_stage_b_semantic_record_schema_contract_v1",
                "prime_stage_b_corrected_mutation_label_free_surface_contract_v1",
            ]
        )
        XCTAssertTrue(
            contract.declarations.allSatisfy {
                $0.targetKind == "internal_swift_library"
                    && $0.targetAssignmentFrozen
                    && $0.targetImplementationPresent
                    && !$0.sourceReferenceObserved
                    && $0.actualSourceReference == nil
                    && !$0.workerMaterialized
                    && !$0.processDeliveryObserved
                    && !$0.modelExecutionEstablished
            }
        )
        let producer = try XCTUnwrap(
            contract.declarations.first {
                $0.role == .producer
            }
        )
        XCTAssertEqual(
            producer.directLocalTargetDependencyNames,
            [
                "PrimeNativeNeuralGateSemanticRecordContracts",
                "PrimeNativeNeuralGateCorrectedMutationSurfaceContracts",
            ]
        )
        XCTAssertEqual(
            producer.orderedContractIDs,
            [
                "prime_stage_b_semantic_record_schema_contract_v1",
                "prime_stage_b_corrected_mutation_label_free_surface_contract_v1",
            ]
        )
        let detector = try XCTUnwrap(
            contract.declarations.first {
                $0.role == .detector
            }
        )
        XCTAssertEqual(
            detector.directLocalTargetDependencyNames,
            [
                "PrimeNativeNeuralGateCorrectedMutationSurfaceContracts",
            ]
        )
        XCTAssertEqual(
            detector.orderedContractIDs,
            [
                "prime_stage_b_corrected_mutation_label_free_surface_contract_v1",
            ]
        )
        XCTAssertFalse(
            detector.directLocalTargetDependencyNames.contains(
                "PrimeNativeNeuralGateSemanticRecordContracts"
            )
        )
        XCTAssertFalse(
            detector.orderedContractIDs.contains(
                "prime_stage_b_semantic_record_schema_contract_v1"
            )
        )
        XCTAssertTrue(
            contract.mutationProducerDetectorMustBeDisjoint
        )
        XCTAssertTrue(
            contract.sharedMutationImplementationSourceForbidden
        )
        XCTAssertTrue(contract.sourceReferencesDeferred)
        XCTAssertFalse(contract.executionImplemented)
        XCTAssertFalse(contract.sourceBindingV7Issued)
        XCTAssertFalse(contract.mechanicsPassAuthorized)
        XCTAssertFalse(contract.terminalReceiptAuthorized)
        XCTAssertFalse(contract.scientificAuthorityAuthorized)
        XCTAssertFalse(contract.productAuthorityAuthorized)
    }

    func testSourceReferenceIsTypedButStillNonAuthorizing()
        throws
    {
        let reference = try
            PrimeNativeNeuralGateMutationTargetSourceReference(
                role: .producer,
                targetName:
                    PrimeNativeNeuralGateMutationTargetRole
                    .producer.targetName,
                packageDescriptionSHA256:
                    String(repeating: "a", count: 64),
                primeSourceSnapshotSHA256:
                    String(repeating: "b", count: 64),
                compiledSourceClosureSHA256:
                    String(repeating: "c", count: 64),
                buildConfiguration: "release"
            )
        XCTAssertNoThrow(try reference.validate())
        XCTAssertFalse(reference.executableReferencePresent)
        XCTAssertFalse(reference.processObservationPresent)
        XCTAssertFalse(reference.executionAuthorityEstablished)
        XCTAssertFalse(reference.mechanicsPassAuthorized)
        XCTAssertFalse(reference.receiptAuthorized)
        XCTAssertFalse(reference.scientificAuthorityAuthorized)
        XCTAssertFalse(reference.productAuthorityAuthorized)

        let observed = try
            PrimeNativeNeuralGateMutationTargetSourceReferenceDeclaration(
                role: .producer,
                actualSourceReference: reference
            )
        XCTAssertTrue(observed.sourceReferenceObserved)
        XCTAssertEqual(
            observed.actualSourceReference,
            reference
        )
        XCTAssertFalse(observed.sourceBindingV7Issued)
    }

    func testSourceReferenceRejectsCrossRoleTargetName()
        throws
    {
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateMutationTargetSourceReference(
                role: .producer,
                targetName:
                    PrimeNativeNeuralGateMutationTargetRole
                    .detector.targetName,
                packageDescriptionSHA256:
                    String(repeating: "a", count: 64),
                primeSourceSnapshotSHA256:
                    String(repeating: "b", count: 64),
                compiledSourceClosureSHA256:
                    String(repeating: "c", count: 64),
                buildConfiguration: "release"
            )
        )
    }

    func testAssignmentContentIdentityIsPinned() throws {
        XCTAssertEqual(
            try PrimeNativeNeuralGateMutationTargetOwnershipContract
                .frozenV1.contentSHA256(),
            "020fa5275a4ab7941b935271ad26b094b35b96c9fb85be765db1dd9130de36e2"
        )
    }

    func testCorrectedV2AssignmentMovesOnlyProducerRecordDependency()
        throws
    {
        let historical =
            PrimeNativeNeuralGateMutationTargetOwnershipContract
            .frozenV1
        let corrected =
            PrimeNativeNeuralGateMutationTargetOwnershipContract
            .frozenV2

        XCTAssertNoThrow(try historical.validate())
        XCTAssertNoThrow(try corrected.validate())
        XCTAssertEqual(corrected.schemaVersion, 2)
        XCTAssertEqual(
            corrected.contractID,
            "prime_stage_b_corrected_mutation_producer_detector_source_assignment_v2"
        )
        let producer = try XCTUnwrap(
            corrected.declarations.first { $0.role == .producer }
        )
        XCTAssertEqual(
            producer.directLocalTargetDependencyNames,
            [
                "PrimeNativeNeuralGateCorrectedMutationRecordContracts",
                "PrimeNativeNeuralGateCorrectedMutationSurfaceContracts",
            ]
        )
        XCTAssertEqual(
            producer.orderedContractIDs,
            [
                "prime_stage_b_corrected_mutation_control_surface_contract_v1",
                "prime_stage_b_corrected_mutation_label_free_surface_contract_v1",
            ]
        )
        XCTAssertFalse(
            producer.directLocalTargetDependencyNames.contains(
                "PrimeNativeNeuralGateSemanticRecordContracts"
            )
        )
        let oldDetector = try XCTUnwrap(
            historical.declarations.first { $0.role == .detector }
        )
        let newDetector = try XCTUnwrap(
            corrected.declarations.first { $0.role == .detector }
        )
        XCTAssertEqual(newDetector, oldDetector)
        XCTAssertTrue(corrected.sourceReferencesDeferred)
        XCTAssertFalse(corrected.executionImplemented)
        XCTAssertFalse(corrected.sourceBindingV7Issued)
        XCTAssertFalse(corrected.mechanicsPassAuthorized)
    }

    func testCorrectedV2AssignmentContentIdentityIsPinned()
        throws
    {
        XCTAssertEqual(
            try PrimeNativeNeuralGateMutationTargetOwnershipContract
                .frozenV2.contentSHA256(),
            "488c02cb82c787228c64c6c10588b0bfcc6ac25f85d13c678ac24ec6af246540"
        )
    }
}
