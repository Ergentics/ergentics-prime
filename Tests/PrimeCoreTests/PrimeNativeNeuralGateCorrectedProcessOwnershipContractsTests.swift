import Foundation
@testable import PrimeCore
@testable import PrimeNativeNeuralGateCorrectedProcessOwnershipContracts
import PrimeNativeNeuralGateReplayArtifactContracts
import PrimeNativeNeuralGateTargetFreeScheduleDeliveryContracts
import XCTest

final class PrimeNativeNeuralGateCorrectedProcessOwnershipContractsTests:
    XCTestCase
{
    private typealias Contract =
        PrimeNativeNeuralGateCorrectedProcessOwnershipContract

    func testFrozenV1PreservesV4AndFreezesSymmetricTenProcessRoster()
        throws
    {
        let contract = Contract.frozenV1
        XCTAssertNoThrow(try contract.validate())
        XCTAssertEqual(
            contract.contractID,
            "prime_stage_b_corrected_ten_process_ownership_v1"
        )
        XCTAssertEqual(
            contract.targetFreeScheduleDeliveryContractID,
            PrimeNativeNeuralGateTargetFreeScheduleDeliveryContract
                .frozenV1.contractID
        )
        XCTAssertEqual(
            contract.preservedHistoricalArtifactContractID,
            "prime_stage_b_non_authorizing_semantic_output_namespace_v4"
        )
        XCTAssertEqual(
            contract.preservedHistoricalArtifactContractSHA256,
            "60e10e6c10f9ec1f30102f5b6d27be123434a163c01d82c0cc5d4520824532d1"
        )
        XCTAssertEqual(contract.exactProcessCount, 10)
        XCTAssertEqual(contract.exactSupervisorCount, 2)
        XCTAssertEqual(contract.exactChildProcessCount, 8)
        XCTAssertTrue(
            contract
                .allProcessIdentifiersPairwiseDistinctRequired
        )
        XCTAssertEqual(
            contract.processRoster.map(\.role),
            PrimeNativeNeuralGateCorrectedProcessRole
                .allCases
        )
        XCTAssertEqual(
            Set(contract.processRoster.map(\.role)).count,
            10
        )
        for kind in
            PrimeNativeNeuralGateCorrectedProcessKind
            .allCases
        {
            let entries = contract.processRoster.filter {
                $0.kind == kind
            }
            XCTAssertEqual(entries.count, 2)
            XCTAssertEqual(
                Set(entries.map(\.branch)),
                Set(
                    PrimeNativeNeuralGateCorrectedProcessBranch
                        .allCases
                )
            )
        }
        XCTAssertTrue(
            contract.processRoster.allSatisfy {
                !$0.processMaterialized
                    && !$0.executionObserved
            }
        )
    }

    func testRoleScopedRawSchemasFreezeFieldsReadersAndOwners()
        throws
    {
        let contract = Contract.frozenV1
        XCTAssertEqual(
            contract.roleScopedRawSchemas.count,
            10
        )
        XCTAssertEqual(
            Set(
                contract.roleScopedRawSchemas
                    .map(\.relativePath)
            ).count,
            10
        )
        XCTAssertEqual(
            contract.roleScopedRawSchemas.map {
                SchemaMatrixEntry(
                    relativePath: $0.relativePath,
                    owner: $0.ownerProcessRole,
                    readers: $0.allowedReaderProcessRoles
                )
            },
            Self.expectedRawMatrix
        )
        for schema in contract.roleScopedRawSchemas {
            XCTAssertNoThrow(
                try schema.validateDeclarativeOwnership()
            )
            XCTAssertEqual(
                schema.ownerProcessRole,
                Contract.expectedRawOwner(
                    branch: schema.branch,
                    schemaKind: schema.schemaKind
                )
            )
            XCTAssertEqual(
                schema.requiredFieldNames,
                Contract.rawRequiredFieldNames(
                    for: schema.schemaKind
                )
            )
            XCTAssertEqual(
                schema.allowedReaderProcessRoles,
                Contract.rawAllowedReaders(
                    branch: schema.branch,
                    schemaKind: schema.schemaKind
                )
            )
            XCTAssertFalse(schema.processEvidenceRepresented)
            XCTAssertFalse(schema.deliveryObserved)
            XCTAssertFalse(schema.executionObserved)
            XCTAssertFalse(schema.mechanicsPassAuthorized)
            XCTAssertFalse(schema.terminalReceiptAuthorized)
        }

        let results = contract.roleScopedRawSchemas
            .filter { $0.schemaKind == .workerResult }
        XCTAssertEqual(results.count, 2)
        for result in results {
            XCTAssertTrue(
                result.requiredFieldNames.contains(
                    "schedule_identity_sha256"
                )
            )
            XCTAssertTrue(
                result.requiredFieldNames.contains(
                    "replicate_seed"
                )
            )
            XCTAssertTrue(
                result.requiredFieldNames.contains(
                    "raw_execution_manifest"
                )
            )
            XCTAssertTrue(
                result.requiredFieldNames.contains(
                    "logit_manifest"
                )
            )
            XCTAssertTrue(
                result.requiredFieldNames.contains(
                    "mechanics_pass_authorized"
                )
            )
            XCTAssertTrue(
                result.requiredFieldNames.contains(
                    "terminal_receipt_authorized"
                )
            )
        }
    }

    func testHistoricalSingularReservationsRemainExactSupersededHistory()
        throws
    {
        let contract = Contract.frozenV1
        let historical =
            PrimeNativeNeuralGateReplayArtifactOutputContract
            .frozenV4
        XCTAssertTrue(contract.historicalV4PreservedAsHistory)
        XCTAssertTrue(
            contract.singularCorrectedProcessPathsSuperseded
        )
        XCTAssertEqual(
            contract
                .supersededHistoricalSingularCorrectedProcessPaths,
            try [
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
        )
        XCTAssertEqual(
            contract.preservedReplacementReceiptRelativePath,
            try historical.spec(
                for: .replacementTerminalReceiptReserved
            ).relativePath
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(
                    historical
                )
            ),
            contract.preservedHistoricalArtifactContractSHA256
        )
    }

    func testContractRemainsEntirelyNonAuthorizing()
    {
        let contract = Contract.frozenV1
        XCTAssertFalse(contract.processDeliveryObserved)
        XCTAssertFalse(contract.executionObserved)
        XCTAssertFalse(contract.mechanicsPassAuthorized)
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
    }

    func testProcessCountDowngradeMutationIsRejected()
        throws
    {
        var roster = Contract.frozenV1.processRoster
        roster.removeLast()
        XCTAssertThrowsError(
            try Contract.validateRosterSymmetry(roster)
        )
    }

    func testRawRequestOwnerSwapMutationIsRejected()
        throws
    {
        var schemas = Contract.frozenV1
            .roleScopedRawSchemas
        let index = try XCTUnwrap(
            schemas.firstIndex {
                $0.branch == .probe
                    && $0.schemaKind == .workerRequest
            }
        )
        let original = schemas[index]
        schemas[index] =
            PrimeNativeNeuralGateRoleScopedSchemaOwnership(
                schemaID: original.schemaID,
                schemaKind: original.schemaKind,
                branch: original.branch,
                relativePath: original.relativePath,
                requiredFieldNames:
                    original.requiredFieldNames,
                ownerProcessRole:
                    .probeCorrectedRawWorker,
                allowedReaderProcessRoles:
                    original.allowedReaderProcessRoles
            )
        XCTAssertThrowsError(
            try Contract.validateRawSchemaOwnership(
                schemas
            )
        )
    }

    func testCanonicalIdentityMatchesLiteralGoldenSHA256()
        throws
    {
        let data = try PrimeCanonicalJSON.encode(
            Contract.frozenV1
        )
        let digest = PrimeSHA256.hexDigest(of: data)
        XCTAssertEqual(
            digest,
            "24dda3ac4302922d52b6dbfe3e541954c98f7da74c9d3b71e277fb0bbebabbbb"
        )
    }

    private struct SchemaMatrixEntry: Equatable {
        let relativePath: String
        let owner:
            PrimeNativeNeuralGateCorrectedProcessRole
        let readers:
            [PrimeNativeNeuralGateCorrectedProcessRole]
    }

    private static let expectedRawMatrix: [
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
    ]
}
