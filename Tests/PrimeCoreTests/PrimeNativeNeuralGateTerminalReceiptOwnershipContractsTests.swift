import Foundation
@testable import PrimeCore
import PrimeNativeNeuralGateCorrectedEvaluationOwnershipContracts
import PrimeNativeNeuralGateCorrectedProcessOwnershipContracts
@testable import PrimeNativeNeuralGateTerminalReceiptOwnershipContracts
import XCTest

final class PrimeNativeNeuralGateTerminalReceiptOwnershipContractsTests:
    XCTestCase
{
    private typealias Contract =
        PrimeNativeNeuralGateTerminalReceiptOwnershipContract

    func testFrozenV1AssignsReceiptV2OnlyToVerifierSupervisor()
        throws
    {
        let contract = Contract.frozenV1
        XCTAssertNoThrow(try contract.validate())
        XCTAssertEqual(
            contract.contractID,
            "prime_stage_b_terminal_receipt_v2_ownership_v1"
        )
        XCTAssertEqual(
            contract.receiptEnvelope.schemaID,
            "prime_native_neural_gate_fixture_replay_receipt_v2"
        )
        XCTAssertEqual(
            contract.receiptEnvelope.relativePath,
            "prime-native-neural-gate-fixture-replay-receipt.v2.json"
        )
        XCTAssertEqual(
            contract.uniqueReceiptOwner,
            .verifierSupervisor
        )
        XCTAssertEqual(
            contract.receiptEnvelope.ownerProcessRole,
            .verifierSupervisor
        )
        XCTAssertTrue(contract.receiptOwnerIsUnique)
        XCTAssertTrue(
            contract.exclusiveNoReplacePublicationRequired
        )
        XCTAssertTrue(contract.receiptPublishedLastRequired)
        XCTAssertTrue(
            contract.receiptEnvelope.publicationMustBeLast
        )
        XCTAssertTrue(
            contract.receiptEnvelope
                .immutableNoReplaceRequired
        )
    }

    func testReceiptEnvelopeBindsExactTenRoleRosterAndPairwiseDistinctPIDs()
    {
        let contract = Contract.frozenV1
        XCTAssertTrue(
            contract
                .exactTenRoleProcessRosterAndIdentifiersRequired
        )
        XCTAssertTrue(
            PrimeNativeNeuralGateCorrectedProcessOwnershipContract
                .frozenV1
                .allProcessIdentifiersPairwiseDistinctRequired
        )
        XCTAssertTrue(
            contract.receiptEnvelope.requiredFieldNames
                .contains("exact_process_roster")
        )
        XCTAssertTrue(
            contract.receiptEnvelope.requiredFieldNames
                .contains("process_identifiers_by_role")
        )
        XCTAssertTrue(
            contract.receiptEnvelope.requiredFieldNames
                .contains(
                    "child_death_and_reap_observations_by_role"
                )
        )
        XCTAssertTrue(
            contract.receiptEnvelope.requiredFieldNames
                .contains("child_execution_records_by_role")
        )
        XCTAssertEqual(
            PrimeNativeNeuralGateCorrectedProcessOwnershipContract
                .frozenV1.processRoster.count,
            10
        )
    }

    func testReceiptRequiresAllEightChildrenReapedAndBothEvaluationResults()
    {
        let contract = Contract.frozenV1
        XCTAssertEqual(
            contract.exactRequiredReapedChildRoles,
            [
                .probeSwiftPackageDescribeChild,
                .verifierSwiftPackageDescribeChild,
                .probeHistoricalWorker,
                .verifierHistoricalWorker,
                .probeCorrectedRawWorker,
                .verifierCorrectedRawWorker,
                .probeCorrectedEvaluationWorker,
                .verifierCorrectedEvaluationWorker,
            ]
        )
        XCTAssertEqual(
            contract.exactRequiredReapedChildRoles.count,
            8
        )
        XCTAssertEqual(
            Set(
                contract.exactRequiredReapedChildRoles
            ).count,
            8
        )
        XCTAssertTrue(
            contract.exactRequiredReapedChildRoles
                .allSatisfy { $0.kind != .supervisor }
        )
        XCTAssertTrue(
            contract
                .allEightChildDeathAndReapObservationsRequired
        )
        XCTAssertTrue(contract.bothEvaluationResultsRequired)
        XCTAssertEqual(
            contract.requiredEvaluationResultRelativePaths,
            [
                "neural-gate-replay/corrected/evaluation/probe/worker-result.v1.json",
                "neural-gate-replay/corrected/evaluation/verifier/worker-result.v1.json",
            ]
        )
    }

    func testPreReceiptInventoryIsExactSortedAndExcludesReceipt()
    {
        let contract = Contract.frozenV1
        let expected = Self.expectedPreReceiptPaths
        XCTAssertEqual(
            contract.exactPreReceiptOwnedArtifactRelativePaths,
            expected
        )
        XCTAssertEqual(expected.count, 20)
        XCTAssertEqual(Set(expected).count, 20)
        XCTAssertFalse(
            expected.contains(
                contract.receiptEnvelope.relativePath
            )
        )
        XCTAssertTrue(
            contract
                .exactPreReceiptRealizedPathMetadataContentInventoryRequired
        )
    }

    func testFullTwentyPathOwnerReaderMatrixIsIndependentAndExact()
    {
        let process =
            PrimeNativeNeuralGateCorrectedProcessOwnershipContract
            .frozenV1
        let evaluation =
            PrimeNativeNeuralGateCorrectedEvaluationOwnershipContract
            .frozenV1
        let actual = (
            process.roleScopedRawSchemas
                + evaluation.roleScopedEvaluationSchemas
        ).map {
            SchemaMatrixEntry(
                relativePath: $0.relativePath,
                owner: $0.ownerProcessRole,
                readers: $0.allowedReaderProcessRoles
            )
        }
        XCTAssertEqual(actual, Self.expectedFullMatrix)
        XCTAssertEqual(actual.count, 20)
        XCTAssertEqual(
            Set(actual.map(\.relativePath)).count,
            20
        )
    }

    func testContractAndEnvelopeRemainEntirelyNonAuthorizing()
    {
        let contract = Contract.frozenV1
        XCTAssertTrue(
            contract.receiptEnvelope.declarativeContractOnly
        )
        XCTAssertFalse(
            contract.receiptEnvelope
                .receiptEvidenceRepresented
        )
        XCTAssertFalse(contract.processDeliveryObserved)
        XCTAssertFalse(contract.executionObserved)
        XCTAssertFalse(contract.mechanicsPassAuthorized)
        XCTAssertFalse(contract.receiptPublicationObserved)
        XCTAssertFalse(contract.terminalReceiptAuthorized)
        XCTAssertFalse(contract.scientificAuthorityAuthorized)
        XCTAssertFalse(contract.productAuthorityAuthorized)
        XCTAssertFalse(contract.sourceBindingV7Issued)
        XCTAssertTrue(contract.mutationSemanticSchemasDeferred)
        XCTAssertTrue(contract.statisticsSemanticSchemaDeferred)
        XCTAssertTrue(contract.verdictSemanticSchemaDeferred)
        XCTAssertTrue(
            contract
                .mutationProducerDetectorTargetAssignmentDeferred
        )
        XCTAssertFalse(contract.poisonedRootRetryPermitted)
    }

    func testMissingReapedRoleMutationIsRejected()
        throws
    {
        var roles = Contract.frozenV1
            .exactRequiredReapedChildRoles
        roles.removeLast()
        XCTAssertThrowsError(
            try validateReceiptSafety(
                reapedChildRoles: roles
            )
        )
    }

    func testDuplicateReapedRoleMutationIsRejected()
        throws
    {
        var roles = Contract.frozenV1
            .exactRequiredReapedChildRoles
        roles[roles.count - 1] = roles[0]
        XCTAssertThrowsError(
            try validateReceiptSafety(
                reapedChildRoles: roles
            )
        )
    }

    func testPoisonedRootRetryPermittedTrueMutationIsRejected()
        throws
    {
        XCTAssertThrowsError(
            try validateReceiptSafety(
                poisonedRootRetryPermitted: true
            )
        )
    }

    func testReceiptPathInPreReceiptInventoryMutationIsRejected()
        throws
    {
        var paths = Contract.frozenV1
            .exactPreReceiptOwnedArtifactRelativePaths
        paths.append(
            Contract.frozenV1.receiptEnvelope
                .relativePath
        )
        XCTAssertThrowsError(
            try validateReceiptSafety(
                preReceiptPaths: paths
            )
        )
    }

    func testVerifierReceiptOwnerRemovalMutationIsRejected()
        throws
    {
        XCTAssertThrowsError(
            try validateReceiptSafety(
                envelopeOwner: .probeSupervisor
            )
        )
    }

    func testVerifierOwnerReaderRemovalMutationIsRejected()
        throws
    {
        XCTAssertThrowsError(
            try validateReceiptSafety(
                envelopeAllowedReaders: [
                    .probeSupervisor,
                ]
            )
        )
    }

    func testCanonicalIdentitiesMatchLiteralGoldenSHA256()
        throws
    {
        let contractData = try PrimeCanonicalJSON.encode(
            Contract.frozenV1
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: contractData),
            "7d15c024cff20a1d712c6664b4b6e878903eae104ce44fc2784547e4ab0406f6"
        )
        let envelopeData = try PrimeCanonicalJSON.encode(
            PrimeNativeNeuralGateTerminalReceiptEnvelopeSchema
                .frozenV2
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: envelopeData),
            "0afe62ebeac173ea7ffd1fb090e7d223a968dee97ba2a154375469ca6a5065a8"
        )
    }

    private func validateReceiptSafety(
        reapedChildRoles:
            [PrimeNativeNeuralGateCorrectedProcessRole]
            = Contract.frozenV1
                .exactRequiredReapedChildRoles,
        poisonedRootRetryPermitted: Bool = false,
        preReceiptPaths: [String] = Contract.frozenV1
            .exactPreReceiptOwnedArtifactRelativePaths,
        envelopeAllowedReaders:
            [PrimeNativeNeuralGateCorrectedProcessRole]
            = Contract.frozenV1.receiptEnvelope
                .allowedReaderProcessRoles,
        envelopeOwner:
            PrimeNativeNeuralGateCorrectedProcessRole
            = Contract.frozenV1.receiptEnvelope
                .ownerProcessRole
    ) throws {
        try Contract.validateReceiptSafety(
            uniqueReceiptOwner:
                Contract.frozenV1.uniqueReceiptOwner,
            envelopeOwner:
                envelopeOwner,
            envelopeAllowedReaders:
                envelopeAllowedReaders,
            exactRequiredReapedChildRoles:
                reapedChildRoles,
            exactPreReceiptOwnedArtifactRelativePaths:
                preReceiptPaths,
            receiptRelativePath:
                Contract.frozenV1.receiptEnvelope
                .relativePath,
            poisonedRootRetryPermitted:
                poisonedRootRetryPermitted
        )
    }

    private struct SchemaMatrixEntry: Equatable {
        let relativePath: String
        let owner:
            PrimeNativeNeuralGateCorrectedProcessRole
        let readers:
            [PrimeNativeNeuralGateCorrectedProcessRole]
    }

    private static let expectedPreReceiptPaths = [
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

    private static let expectedFullMatrix: [
        SchemaMatrixEntry
    ] = [
        .init(
            relativePath: "neural-gate-replay/corrected/raw/probe/schedule-delivery.v1.json",
            owner: .probeSupervisor,
            readers: [
                .probeCorrectedRawWorker,
                .probeSupervisor,
                .verifierSupervisor,
            ]
        ),
        .init(
            relativePath: "neural-gate-replay/corrected/raw/probe/worker-request.v1.json",
            owner: .probeSupervisor,
            readers: [
                .probeCorrectedRawWorker,
                .probeSupervisor,
                .verifierSupervisor,
            ]
        ),
        .init(
            relativePath: "neural-gate-replay/corrected/raw/probe/worker-process-binding.v1.json",
            owner: .probeCorrectedRawWorker,
            readers: [
                .probeCorrectedRawWorker,
                .probeSupervisor,
                .verifierSupervisor,
            ]
        ),
        .init(
            relativePath: "neural-gate-replay/corrected/raw/probe/worker-execution.v1.json",
            owner: .probeSupervisor,
            readers: [
                .probeSupervisor,
                .verifierSupervisor,
            ]
        ),
        .init(
            relativePath: "neural-gate-replay/corrected/raw/probe/worker-result.v1.json",
            owner: .probeCorrectedRawWorker,
            readers: [
                .probeCorrectedEvaluationWorker,
                .probeCorrectedRawWorker,
                .probeSupervisor,
                .verifierSupervisor,
            ]
        ),
        .init(
            relativePath: "neural-gate-replay/corrected/raw/verifier/schedule-delivery.v1.json",
            owner: .verifierSupervisor,
            readers: [
                .verifierCorrectedRawWorker,
                .verifierSupervisor,
            ]
        ),
        .init(
            relativePath: "neural-gate-replay/corrected/raw/verifier/worker-request.v1.json",
            owner: .verifierSupervisor,
            readers: [
                .verifierCorrectedRawWorker,
                .verifierSupervisor,
            ]
        ),
        .init(
            relativePath: "neural-gate-replay/corrected/raw/verifier/worker-process-binding.v1.json",
            owner: .verifierCorrectedRawWorker,
            readers: [
                .verifierCorrectedRawWorker,
                .verifierSupervisor,
            ]
        ),
        .init(
            relativePath: "neural-gate-replay/corrected/raw/verifier/worker-execution.v1.json",
            owner: .verifierSupervisor,
            readers: [
                .verifierSupervisor,
            ]
        ),
        .init(
            relativePath: "neural-gate-replay/corrected/raw/verifier/worker-result.v1.json",
            owner: .verifierCorrectedRawWorker,
            readers: [
                .verifierCorrectedEvaluationWorker,
                .verifierCorrectedRawWorker,
                .verifierSupervisor,
            ]
        ),
        .init(
            relativePath: "neural-gate-replay/corrected/evaluation/probe/outer-delivery.v1.json",
            owner: .probeSupervisor,
            readers: [
                .probeCorrectedEvaluationWorker,
                .probeSupervisor,
                .verifierSupervisor,
            ]
        ),
        .init(
            relativePath: "neural-gate-replay/corrected/evaluation/probe/worker-request.v1.json",
            owner: .probeSupervisor,
            readers: [
                .probeCorrectedEvaluationWorker,
                .probeSupervisor,
                .verifierSupervisor,
            ]
        ),
        .init(
            relativePath: "neural-gate-replay/corrected/evaluation/probe/worker-process-binding.v1.json",
            owner: .probeCorrectedEvaluationWorker,
            readers: [
                .probeCorrectedEvaluationWorker,
                .probeSupervisor,
                .verifierSupervisor,
            ]
        ),
        .init(
            relativePath: "neural-gate-replay/corrected/evaluation/probe/worker-execution.v1.json",
            owner: .probeSupervisor,
            readers: [
                .probeSupervisor,
                .verifierSupervisor,
            ]
        ),
        .init(
            relativePath: "neural-gate-replay/corrected/evaluation/probe/worker-result.v1.json",
            owner: .probeCorrectedEvaluationWorker,
            readers: [
                .probeCorrectedEvaluationWorker,
                .probeSupervisor,
                .verifierSupervisor,
            ]
        ),
        .init(
            relativePath: "neural-gate-replay/corrected/evaluation/verifier/outer-delivery.v1.json",
            owner: .verifierSupervisor,
            readers: [
                .verifierCorrectedEvaluationWorker,
                .verifierSupervisor,
            ]
        ),
        .init(
            relativePath: "neural-gate-replay/corrected/evaluation/verifier/worker-request.v1.json",
            owner: .verifierSupervisor,
            readers: [
                .verifierCorrectedEvaluationWorker,
                .verifierSupervisor,
            ]
        ),
        .init(
            relativePath: "neural-gate-replay/corrected/evaluation/verifier/worker-process-binding.v1.json",
            owner: .verifierCorrectedEvaluationWorker,
            readers: [
                .verifierCorrectedEvaluationWorker,
                .verifierSupervisor,
            ]
        ),
        .init(
            relativePath: "neural-gate-replay/corrected/evaluation/verifier/worker-execution.v1.json",
            owner: .verifierSupervisor,
            readers: [
                .verifierSupervisor,
            ]
        ),
        .init(
            relativePath: "neural-gate-replay/corrected/evaluation/verifier/worker-result.v1.json",
            owner: .verifierCorrectedEvaluationWorker,
            readers: [
                .verifierCorrectedEvaluationWorker,
                .verifierSupervisor,
            ]
        ),
    ]
}
