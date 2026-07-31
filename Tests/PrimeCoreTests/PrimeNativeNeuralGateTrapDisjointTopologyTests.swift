import Foundation
@testable import PrimeCore
import XCTest

final class PrimeNativeNeuralGateTrapDisjointTopologyTests:
    XCTestCase
{
    private typealias Contract =
        PrimeNativeNeuralGateTrapDisjointTopologyContract

    func testFrozenTopologyValidatesAndDoesNotClaimExecution()
        throws
    {
        let contract = Contract.frozenV1

        XCTAssertNoThrow(try contract.validate())
        XCTAssertEqual(contract.schemaVersion, 1)
        XCTAssertEqual(
            contract.contractID,
            "prime_stage_b_trap_disjoint_topology_v1"
        )
        XCTAssertEqual(
            contract.status,
            .plannedNotMaterialized
        )
        XCTAssertFalse(
            contract.executionImplemented
        )
        XCTAssertTrue(
            contract.historicalContractsPreserved
        )
        XCTAssertTrue(
            contract
                .historicalFutureTargetGraphSuperseded
        )
        XCTAssertFalse(
            contract.sourceBindingV7Issued
        )
        XCTAssertEqual(
            contract.packageCaptureAuthority,
            "actual_package_secure_capture_only_not_v6_or_v7_execution_graph_reconciliation"
        )
        XCTAssertTrue(
            contract
                .mutationProducerDetectorMustBeDisjoint
        )
        XCTAssertTrue(
            contract
                .mutationProducerDetectorTargetAssignmentDeferred
        )
        XCTAssertEqual(
            try PrimeCanonicalJSON.decode(
                Contract.self,
                from:
                    PrimeCanonicalJSON.encode(
                        contract
                    )
            ),
            contract
        )
        XCTAssertEqual(
            try contract.contentSHA256(),
            "48e0f64fcb14193d74bf9c3d98a8aeef7ca366033cea6d8f00bc345ff0ad86b5"
        )
    }

    func testImplementedTargetClosuresAreExactlyTrapDisjoint()
        throws
    {
        let contract = Contract.frozenV1
        let expected: [String: [String]] = [
            "PrimeNativeNeuralGateReplayMechanics":
                [],
            "PrimeNativeNeuralGateCorrectedMechanics":
                [
                    "PrimeNativeNeuralGateReplayMechanics",
                ],
            "PrimeNativeNeuralGateCorrectedEvaluationMechanics":
                [
                    "PrimeNativeNeuralGateCorrectedMechanics",
                    "PrimeNativeNeuralGateReplayMechanics",
                ],
            "PrimeNativeNeuralGateCorrectedFixtureAuthority":
                [
                    "PrimeNativeCorpusReplayMechanics",
                    "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
                    "PrimeNativeNeuralGateCorrectedMechanics",
                    "PrimeNativeNeuralGateReplayMechanics",
                ],
            "PrimeNativeNeuralGatePromptSolver":
                [
                    "PrimeNativeNeuralGateCorrectedMechanics",
                    "PrimeNativeNeuralGateReplayMechanics",
                ],
            "PrimeNativeNeuralGateLogitSidecarMechanics":
                [
                    "PrimeNativeNeuralGateCorrectedMechanics",
                    "PrimeNativeNeuralGateReplayMechanics",
                ],
            "PrimeNativeNeuralGateMLXLogSoftmaxRecomputation":
                [
                    "PrimeNativeNeuralGateCorrectedMechanics",
                    "PrimeNativeNeuralGateLogitSidecarMechanics",
                    "PrimeNativeNeuralGateReplayMechanics",
                ],
        ]

        for (target, closure) in expected {
            XCTAssertEqual(
                try contract
                    .transitiveLocalTargetNames(
                        reachableFrom: target
                    ),
                closure,
                target
            )
        }
    }

    func testPlannedSupervisorAndWorkerClosuresStayDisjoint()
        throws
    {
        let contract = Contract.frozenV1

        let supervisorClosure = [
            "PrimeCore",
            "PrimeNativeNeuralGateReplayMechanics",
            "PrimeNativeNeuralGateReplayTransport",
        ]
        XCTAssertEqual(
            try contract
                .transitiveLocalTargetNames(
                    reachableFrom:
                        "PrimeNativeNeuralGateReplayProbe"
                ),
            supervisorClosure
        )
        XCTAssertEqual(
            try contract
                .transitiveLocalTargetNames(
                    reachableFrom:
                        "PrimeNativeNeuralGateReplayVerifier"
                ),
            supervisorClosure
        )
        XCTAssertEqual(
            try contract
                .transitiveLocalTargetNames(
                    reachableFrom:
                        "PrimeNativeNeuralGateHistoricalFixtureWorker"
                ),
            [
                "ErgenticsPrimeRuntime",
                "PrimeCore",
                "PrimeNativeNeuralGateHistoricalReplayMechanics",
                "PrimeNativeNeuralGateReplayMechanics",
                "PrimeNativeNeuralGateReplayTransport",
            ]
        )
        XCTAssertEqual(
            try contract
                .transitiveLocalTargetNames(
                    reachableFrom:
                        "PrimeNativeNeuralGateCorrectedRawWorker"
                ),
            [
                "PrimeCore",
                "PrimeNativeNeuralGateCorrectedMechanics",
                "PrimeNativeNeuralGateLogitSidecarMechanics",
                "PrimeNativeNeuralGatePromptSolver",
                "PrimeNativeNeuralGateReplayMechanics",
            ]
        )
    }

    func testActualPackageMatchesEveryImplementedTopologyEdge()
        throws
    {
        let package = compact(
            try String(
                contentsOf:
                    repositoryRoot
                    .appendingPathComponent(
                        "Package.swift"
                    ),
                encoding: .utf8
            )
        )
        let exactDeclarations = [
            #".target(name:"PrimeCore")"#,
            #".target(name:"PrimeNativeCorpusReplayMechanics")"#,
            #".target(name:"PrimeNativeNeuralGateReplayMechanics")"#,
            #".target(name:"PrimeNativeNeuralGateCorrectedMechanics",dependencies:["PrimeNativeNeuralGateReplayMechanics",])"#,
            #".target(name:"PrimeNativeNeuralGateCorrectedEvaluationMechanics",dependencies:["PrimeNativeNeuralGateReplayMechanics","PrimeNativeNeuralGateCorrectedMechanics",])"#,
            #".target(name:"PrimeNativeNeuralGateCorrectedFixtureAuthority",dependencies:["PrimeNativeCorpusReplayMechanics","PrimeNativeNeuralGateCorrectedMechanics","PrimeNativeNeuralGateCorrectedEvaluationMechanics",])"#,
            #".target(name:"PrimeNativeNeuralGatePromptSolver",dependencies:["PrimeNativeNeuralGateCorrectedMechanics",])"#,
            #".target(name:"PrimeNativeNeuralGateLogitSidecarMechanics",dependencies:["PrimeNativeNeuralGateCorrectedMechanics",])"#,
        ]
        for declaration in exactDeclarations {
            XCTAssertTrue(
                package.contains(declaration),
                declaration
            )
        }
        XCTAssertTrue(
            package.contains(
                #".target(name:"PrimeNativeNeuralGateMLXLogSoftmaxRecomputation",dependencies:["PrimeNativeNeuralGateLogitSidecarMechanics",.product(name:"MLX",package:"ergentics-mlx-swift"),.product(name:"MLXNN",package:"ergentics-mlx-swift"),])"#
            )
        )

        for target in Contract.frozenV1.targetGraph
        where target.materialization
            == .plannedNotMaterialized
        {
            XCTAssertFalse(
                package.contains(
                    #".target(name:"\#(target.targetName)""#
                ),
                target.targetName
            )
            XCTAssertFalse(
                package.contains(
                    #".executableTarget(name:"\#(target.targetName)""#
                ),
                target.targetName
            )
        }
    }

    func testRawTargetContainsNoEvaluationOrRegradeSymbols()
        throws
    {
        let rawSource = try source(
            target:
                "PrimeNativeNeuralGateCorrectedMechanics",
            file:
                "PrimeNativeNeuralGateCorrectedMechanics.swift"
        )
        let evaluationSource = try source(
            target:
                "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
            file:
                "PrimeNativeNeuralGateCorrectedEvaluationMechanics.swift"
        )
        let movedSymbols = [
            "PrimeNativeNeuralGateCorrectedCompletionFeasibility",
            "PrimeNativeNeuralGateCorrectedCorrelationEnvelope",
            "PrimeNativeNeuralGateObservedTruth",
            "PrimeNativeNeuralGatePostExecutionRegradeMaterial",
            "PrimeNativeNeuralGatePredictionRegradeObservation",
            "PrimeNativeNeuralGateWeightedLossStatistics",
            "PrimeNativeNeuralGateCapabilityObservation",
            "PrimeNativeNeuralGateCountDerivedVerdict",
            "PrimeNativeNeuralGateCorrectedMutationObservation",
        ]
        for symbol in movedSymbols {
            XCTAssertFalse(
                rawSource.contains(symbol),
                symbol
            )
            XCTAssertTrue(
                evaluationSource.contains(symbol),
                symbol
            )
        }
        XCTAssertTrue(
            evaluationSource.contains(
                "import PrimeNativeNeuralGateCorrectedMechanics"
            )
        )
        XCTAssertFalse(
            rawSource.contains(
                "import PrimeNativeNeuralGateCorrectedEvaluationMechanics"
            )
        )
    }

    func testHistoricalAdaptationIsPreservedButCannotDriveFutureRouting()
        throws
    {
        let historical =
            PrimeNativeNeuralGateAdaptationProofContract
            .frozenV2
        let oldDonorDestinations =
            historical.entries
                .filter {
                    [1, 9].contains($0.ordinal)
                }
                .compactMap(
                    \.primeDestinationRelativePath
                )
        XCTAssertEqual(
            oldDonorDestinations.count,
            2
        )
        XCTAssertTrue(
            oldDonorDestinations.allSatisfy {
                $0.hasPrefix(
                    "Sources/PrimeNativeNeuralGateReplayMechanics/"
                )
            }
        )
        let correction = Contract.frozenV1
        XCTAssertTrue(
            correction
                .donorAdaptationV2PreservedAsHistory
        )
        XCTAssertTrue(
            correction.donorAdaptationV3Required
        )
        XCTAssertEqual(
            correction
                .donorAdaptationV3RequiredDestination,
            "Sources/PrimeNativeNeuralGateHistoricalReplayMechanics/"
        )
        XCTAssertNotEqual(
            correction
                .donorAdaptationV3RequiredDestination,
            "Sources/PrimeNativeNeuralGateReplayMechanics/"
        )
    }

    func testHistoricalPlanAndSourceBindingIdentitiesRemainExact()
        throws
    {
        XCTAssertEqual(
            try PrimeNativeNeuralGateFixtureReplayPlan
                .frozenV3.contentSHA256(),
            "9e8e9c4820fcea592f79cb4cbdc9abdd217a0ca6e00e2b715a215d8a1d315ee6"
        )
        XCTAssertEqual(
            try PrimeNativeNeuralGateFixtureReplayPlan
                .frozenV4.contentSHA256(),
            "a458a2caf801d01fa98b403b21514d2ea18ddbe284ea4d893c101fc5ca7663be"
        )
        XCTAssertEqual(
            try PrimeNativeNeuralGateFixtureReplayPlan
                .frozenV5.contentSHA256(),
            "c811555bc3a04f053378519ca9c33d18de075d0eb7b347587a9789f4aff3466b"
        )
        XCTAssertEqual(
            PrimeNativeNeuralGateFixtureReplayPlan
                .frozenV5.sourceExecutionBinding
                .contractID,
            "prime_stage_b_release_source_executable_join_v6"
        )
    }

    func testMutationCannotRetainFrozenTopologyAuthority()
        throws
    {
        let data = try PrimeCanonicalJSON.encode(
            Contract.frozenV1
        )
        var object = try XCTUnwrap(
            JSONSerialization.jsonObject(
                with: data
            ) as? [String: Any]
        )
        object["source_binding_v7_issued"] = true
        let mutated = try JSONDecoder().decode(
            Contract.self,
            from:
                JSONSerialization.data(
                    withJSONObject: object,
                    options: [.sortedKeys]
                )
        )
        XCTAssertThrowsError(
            try mutated.validate()
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateTopologyError,
                .invalidFrozenContract
            )
        }
    }

    func testDuplicateDecodedTargetFailsClosedWithoutDictionaryTrap()
        throws
    {
        let data = try PrimeCanonicalJSON.encode(
            Contract.frozenV1
        )
        var object = try XCTUnwrap(
            JSONSerialization.jsonObject(
                with: data
            ) as? [String: Any]
        )
        var graph = try XCTUnwrap(
            object["target_graph"]
                as? [[String: Any]]
        )
        graph.append(try XCTUnwrap(graph.first))
        object["target_graph"] = graph
        let mutated = try JSONDecoder().decode(
            Contract.self,
            from:
                JSONSerialization.data(
                    withJSONObject: object,
                    options: [.sortedKeys]
                )
        )
        XCTAssertThrowsError(
            try mutated
                .transitiveLocalTargetNames(
                    reachableFrom: "PrimeCore"
                )
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateTopologyError,
                .duplicateTarget("PrimeCore")
            )
        }
    }

    private func source(
        target: String,
        file: String
    ) throws -> String {
        try String(
            contentsOf:
                repositoryRoot
                .appendingPathComponent("Sources")
                .appendingPathComponent(target)
                .appendingPathComponent(file),
            encoding: .utf8
        )
    }

    private func compact(
        _ source: String
    ) -> String {
        String(
            source.filter {
                !$0.isWhitespace
            }
        )
    }

    private var repositoryRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
