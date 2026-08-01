import Foundation
@testable import PrimeCore
@testable import PrimeNativeNeuralGateCorrectedEvaluationOwnershipContracts
import PrimeNativeNeuralGateCorrectedProcessOwnershipContracts
import XCTest

final class PrimeNativeNeuralGateCorrectedEvaluationOwnershipContractsTests:
    XCTestCase
{
    private typealias Contract =
        PrimeNativeNeuralGateCorrectedEvaluationOwnershipContract

    func testFrozenV1AssignsTwoDistinctEvaluationWorkers()
        throws
    {
        let contract = Contract.frozenV1
        XCTAssertNoThrow(try contract.validate())
        XCTAssertEqual(
            contract.contractID,
            "prime_stage_b_corrected_evaluation_ownership_v1"
        )
        XCTAssertEqual(
            contract.correctedProcessOwnershipContractID,
            PrimeNativeNeuralGateCorrectedProcessOwnershipContract
                .frozenV1.contractID
        )
        XCTAssertEqual(
            contract.evaluationWorkerRoles,
            [
                .probeCorrectedEvaluationWorker,
                .verifierCorrectedEvaluationWorker,
            ]
        )
        XCTAssertEqual(
            Set(contract.evaluationWorkerRoles).count,
            2
        )
        XCTAssertTrue(
            contract.distinctEvaluationProcessesRequired
        )
        XCTAssertTrue(
            contract.rawWorkersCannotOwnEvaluationSchemas
        )
        XCTAssertFalse(
            contract
                .evaluationResultCanAuthorizeMechanicsPass
        )
    }

    func testEvaluationSchemasFreezeFieldsReadersAndOwnersWithoutRawReachability()
        throws
    {
        let contract = Contract.frozenV1
        XCTAssertEqual(
            contract.roleScopedEvaluationSchemas.count,
            10
        )
        XCTAssertEqual(
            Set(
                contract.roleScopedEvaluationSchemas
                    .map(\.relativePath)
            ).count,
            10
        )
        XCTAssertEqual(
            contract.roleScopedEvaluationSchemas.map {
                SchemaMatrixEntry(
                    relativePath: $0.relativePath,
                    owner: $0.ownerProcessRole,
                    readers: $0.allowedReaderProcessRoles
                )
            },
            Self.expectedEvaluationMatrix
        )
        for schema in
            contract.roleScopedEvaluationSchemas
        {
            XCTAssertNoThrow(
                try schema.validateDeclarativeOwnership()
            )
            XCTAssertEqual(
                schema.ownerProcessRole,
                Contract.expectedEvaluationOwner(
                    branch: schema.branch,
                    schemaKind: schema.schemaKind
                )
            )
            XCTAssertEqual(
                schema.requiredFieldNames,
                Contract.evaluationRequiredFieldNames(
                    for: schema.schemaKind
                )
            )
            XCTAssertEqual(
                schema.allowedReaderProcessRoles,
                Contract.evaluationAllowedReaders(
                    branch: schema.branch,
                    schemaKind: schema.schemaKind
                )
            )
            XCTAssertNotEqual(
                schema.ownerProcessRole.kind,
                .correctedRawWorker
            )
            XCTAssertFalse(
                schema.allowedReaderProcessRoles
                    .contains {
                        $0.kind == .correctedRawWorker
                    }
            )
            XCTAssertFalse(schema.processEvidenceRepresented)
            XCTAssertFalse(schema.deliveryObserved)
            XCTAssertFalse(schema.executionObserved)
            XCTAssertFalse(schema.mechanicsPassAuthorized)
            XCTAssertFalse(schema.terminalReceiptAuthorized)
        }
    }

    func testOuterScheduleIsTargetFreeAndResultSemanticsRemainBounded()
    {
        let contract = Contract.frozenV1
        let forbiddenOuterFields: Set<String> = [
            "expected_completion",
            "row_id",
            "semantic_family",
            "split",
            "target",
            "target_token_ids",
        ]
        let outer = contract.roleScopedEvaluationSchemas
            .filter { $0.schemaKind == .outerSchedule }
        XCTAssertEqual(outer.count, 2)
        for schema in outer {
            XCTAssertTrue(
                forbiddenOuterFields.isDisjoint(
                    with: schema.requiredFieldNames
                )
            )
        }

        let results = contract.roleScopedEvaluationSchemas
            .filter { $0.schemaKind == .workerResult }
        XCTAssertEqual(results.count, 2)
        for result in results {
            XCTAssertTrue(
                result.requiredFieldNames.contains(
                    "corrected_raw_worker_result"
                )
            )
            XCTAssertTrue(
                result.requiredFieldNames.contains(
                    "prompt_target_crosswalk_binding"
                )
            )
            XCTAssertTrue(
                result.requiredFieldNames.contains(
                    "mechanics_pass_authorized"
                )
            )
            XCTAssertFalse(
                result.requiredFieldNames.contains {
                    $0.contains("mutation")
                        || $0.contains("statistics")
                        || $0.contains("verdict")
                }
            )
        }
    }

    func testRawResultsAreExactBranchScopedInputs()
    {
        let contract = Contract.frozenV1
        XCTAssertEqual(
            contract.requiredRawResultRelativePaths,
            [
                "neural-gate-replay/corrected/raw/probe/worker-result.v1.json",
                "neural-gate-replay/corrected/raw/verifier/worker-result.v1.json",
            ]
        )
    }

    func testContractRemainsEntirelyNonAuthorizing()
    {
        let contract = Contract.frozenV1
        XCTAssertTrue(
            contract.targetMaterialExcludedFromOuterSchedule
        )
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

    func testEvaluationResultOwnerSwapMutationIsRejected()
        throws
    {
        var schemas = Contract.frozenV1
            .roleScopedEvaluationSchemas
        let index = try XCTUnwrap(
            schemas.firstIndex {
                $0.branch == .probe
                    && $0.schemaKind == .workerResult
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
            try Contract
                .validateEvaluationSchemaOwnership(
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
            "98df1fb980ce99eae93d22a887088999256c61ba8d1ec190ebe61da58afb913e"
        )
    }

    private struct SchemaMatrixEntry: Equatable {
        let relativePath: String
        let owner:
            PrimeNativeNeuralGateCorrectedProcessRole
        let readers:
            [PrimeNativeNeuralGateCorrectedProcessRole]
    }

    private static let expectedEvaluationMatrix: [
        SchemaMatrixEntry
    ] = [
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
