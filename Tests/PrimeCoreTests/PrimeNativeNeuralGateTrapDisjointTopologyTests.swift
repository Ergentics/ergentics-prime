import Foundation
@testable import PrimeCore
import PrimeNativeNeuralGateReplayCaptureInventory
import PrimeNativeNeuralGateRoleArtifactReferenceContracts
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

    func testTopologyV2MaterializesOnlyPureArtifactContractsAndTransport()
        throws
    {
        let historical = Contract.frozenV1
        let contract = Contract.frozenV2

        XCTAssertNoThrow(try historical.validate())
        XCTAssertNoThrow(try contract.validate())
        XCTAssertEqual(contract.schemaVersion, 2)
        XCTAssertEqual(
            contract.contractID,
            "prime_stage_b_trap_disjoint_topology_v2"
        )
        XCTAssertFalse(contract.executionImplemented)
        XCTAssertFalse(contract.sourceBindingV7Issued)
        XCTAssertTrue(
            contract
                .mutationProducerDetectorTargetAssignmentDeferred
        )
        XCTAssertEqual(
            try historical.contentSHA256(),
            "48e0f64fcb14193d74bf9c3d98a8aeef7ca366033cea6d8f00bc345ff0ad86b5"
        )
        XCTAssertEqual(
            try contract.contentSHA256(),
            "abc8f1ada303ecb95b7c9a44e72293ed314537b93e27354aebbb7763e1487415"
        )
        XCTAssertEqual(
            try contract
                .transitiveLocalTargetNames(
                    reachableFrom:
                        "PrimeNativeNeuralGateReplayArtifactContracts"
                ),
            []
        )
        XCTAssertEqual(
            try contract
                .transitiveLocalTargetNames(
                    reachableFrom:
                        "PrimeNativeNeuralGateReplayTransport"
                ),
            [
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplayMechanics",
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
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplayMechanics",
            ]
        )
        let implemented =
            contract.targetGraph
            .filter {
                $0.materialization == .implemented
            }
            .map(\.targetName)
        XCTAssertTrue(
            implemented.contains(
                "PrimeNativeNeuralGateReplayArtifactContracts"
            )
        )
        XCTAssertTrue(
            implemented.contains(
                "PrimeNativeNeuralGateReplayTransport"
            )
        )
        for target in [
            "ErgenticsPrimeRuntime",
            "PrimeNativeNeuralGateHistoricalReplayMechanics",
            "PrimeNativeNeuralGateHistoricalFixtureWorker",
            "PrimeNativeNeuralGateReplayProbe",
            "PrimeNativeNeuralGateReplayVerifier",
            "PrimeNativeNeuralGateCorrectedRawWorker",
        ] {
            XCTAssertEqual(
                try contract.target(
                    named: target
                ).materialization,
                .plannedNotMaterialized,
                target
            )
        }
    }

    func testTopologyV3MaterializesOnlyTrapFreeReplayComposition()
        throws
    {
        let historicalV1 = Contract.frozenV1
        let historicalV2 = Contract.frozenV2
        let contract = Contract.frozenV3

        XCTAssertNoThrow(try historicalV1.validate())
        XCTAssertNoThrow(try historicalV2.validate())
        XCTAssertNoThrow(try contract.validate())
        XCTAssertEqual(contract.schemaVersion, 3)
        XCTAssertEqual(
            contract.contractID,
            "prime_stage_b_trap_disjoint_topology_v3"
        )
        XCTAssertFalse(contract.executionImplemented)
        XCTAssertFalse(contract.sourceBindingV7Issued)
        XCTAssertEqual(
            try historicalV1.contentSHA256(),
            "48e0f64fcb14193d74bf9c3d98a8aeef7ca366033cea6d8f00bc345ff0ad86b5"
        )
        XCTAssertEqual(
            try historicalV2.contentSHA256(),
            "abc8f1ada303ecb95b7c9a44e72293ed314537b93e27354aebbb7763e1487415"
        )
        XCTAssertEqual(
            try contract.contentSHA256(),
            "b475e29347a31d27be8dc1aa54648fec84c4f1b47d673a1f111ccffb794985fd"
        )
        XCTAssertEqual(
            try contract.target(
                named:
                    "PrimeNativeNeuralGateReplayComposition"
            ).materialization,
            .implemented
        )
        XCTAssertEqual(
            try contract
                .transitiveLocalTargetNames(
                    reachableFrom:
                        "PrimeNativeNeuralGateReplayComposition"
                ),
            [
                "PrimeNativeNeuralGateCorrectedMechanics",
                "PrimeNativeNeuralGateLogitSidecarMechanics",
                "PrimeNativeNeuralGateReplayArtifactContracts",
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
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplayMechanics",
            ]
        )
        XCTAssertFalse(
            try contract.target(
                named:
                    "PrimeNativeNeuralGateCorrectedRawWorker"
            ).directLocalDependencyNames.contains(
                "PrimeNativeNeuralGateReplayComposition"
            )
        )
        for target in [
            "ErgenticsPrimeRuntime",
            "PrimeNativeNeuralGateHistoricalReplayMechanics",
            "PrimeNativeNeuralGateHistoricalFixtureWorker",
            "PrimeNativeNeuralGateReplayProbe",
            "PrimeNativeNeuralGateReplayVerifier",
            "PrimeNativeNeuralGateCorrectedRawWorker",
        ] {
            XCTAssertEqual(
                try contract.target(
                    named: target
                ).materialization,
                .plannedNotMaterialized,
                target
            )
        }
    }

    func testTopologyV4MaterializesDescriptorSourceBindingOutsidePureComposition()
        throws
    {
        let historicalV1 = Contract.frozenV1
        let historicalV2 = Contract.frozenV2
        let historicalV3 = Contract.frozenV3
        let contract = Contract.frozenV4

        XCTAssertNoThrow(try historicalV1.validate())
        XCTAssertNoThrow(try historicalV2.validate())
        XCTAssertNoThrow(try historicalV3.validate())
        XCTAssertNoThrow(try contract.validate())
        XCTAssertEqual(contract.schemaVersion, 4)
        XCTAssertEqual(
            contract.contractID,
            "prime_stage_b_descriptor_source_binding_topology_v4"
        )
        XCTAssertFalse(contract.executionImplemented)
        XCTAssertFalse(contract.sourceBindingV7Issued)
        XCTAssertEqual(
            try historicalV1.contentSHA256(),
            "48e0f64fcb14193d74bf9c3d98a8aeef7ca366033cea6d8f00bc345ff0ad86b5"
        )
        XCTAssertEqual(
            try historicalV2.contentSHA256(),
            "abc8f1ada303ecb95b7c9a44e72293ed314537b93e27354aebbb7763e1487415"
        )
        XCTAssertEqual(
            try historicalV3.contentSHA256(),
            "b475e29347a31d27be8dc1aa54648fec84c4f1b47d673a1f111ccffb794985fd"
        )
        XCTAssertEqual(
            try contract.contentSHA256(),
            "8339bbd42b0e4052888db880aacbb067770c08dd2106bf4a7820c853c4b715af"
        )
        XCTAssertEqual(
            try contract.target(
                named:
                    "PrimeNativeNeuralGateReplayComposition"
            ).directLocalDependencyNames,
            historicalV3.targetGraph.first {
                $0.targetName
                    == "PrimeNativeNeuralGateReplayComposition"
            }?.directLocalDependencyNames
        )
        XCTAssertEqual(
            try contract
                .transitiveLocalTargetNames(
                    reachableFrom:
                        "PrimeNativeNeuralGateReplaySourceBinding"
                ),
            [
                "PrimeCore",
                "PrimeNativeNeuralGateCorrectedMechanics",
                "PrimeNativeNeuralGateLogitSidecarMechanics",
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplayMechanics",
                "PrimeNativeNeuralGateReplayTransport",
            ]
        )
        XCTAssertEqual(
            try contract
                .transitiveLocalTargetNames(
                    reachableFrom:
                        "PrimeNativeNeuralGateReplaySourceComposition"
                ),
            [
                "PrimeCore",
                "PrimeNativeNeuralGateCorrectedMechanics",
                "PrimeNativeNeuralGateLogitSidecarMechanics",
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplayComposition",
                "PrimeNativeNeuralGateReplayMechanics",
                "PrimeNativeNeuralGateReplaySourceBinding",
                "PrimeNativeNeuralGateReplayTransport",
            ]
        )
        for target in [
            "ErgenticsPrimeRuntime",
            "PrimeNativeNeuralGateHistoricalReplayMechanics",
            "PrimeNativeNeuralGateHistoricalFixtureWorker",
            "PrimeNativeNeuralGateReplayProbe",
            "PrimeNativeNeuralGateReplayVerifier",
            "PrimeNativeNeuralGateCorrectedRawWorker",
        ] {
            XCTAssertEqual(
                try contract.target(
                    named: target
                ).materialization,
                .plannedNotMaterialized,
                target
            )
        }
    }

    func testTopologyV5MaterializesHeldRootCaptureAndCrosswalkWithoutWorkers()
        throws
    {
        let historicalV1 = Contract.frozenV1
        let historicalV2 = Contract.frozenV2
        let historicalV3 = Contract.frozenV3
        let historicalV4 = Contract.frozenV4
        let contract = Contract.frozenV5
        let captureTargetName =
            "PrimeNativeNeuralGateReplayCaptureInventory"
        let crosswalkTargetName =
            "PrimeNativeNeuralGatePromptTargetCrosswalkAuthority"

        XCTAssertNoThrow(try historicalV1.validate())
        XCTAssertNoThrow(try historicalV2.validate())
        XCTAssertNoThrow(try historicalV3.validate())
        XCTAssertNoThrow(try historicalV4.validate())
        XCTAssertNoThrow(try contract.validate())
        XCTAssertEqual(contract.schemaVersion, 5)
        XCTAssertEqual(
            contract.contractID,
            "prime_stage_b_held_root_capture_crosswalk_authority_topology_v5"
        )
        XCTAssertEqual(contract.status, .plannedNotMaterialized)
        XCTAssertFalse(contract.executionImplemented)
        XCTAssertFalse(contract.sourceBindingV7Issued)
        XCTAssertTrue(contract.historicalContractsPreserved)
        XCTAssertTrue(
            contract.historicalFutureTargetGraphSuperseded
        )
        XCTAssertTrue(
            contract.donorAdaptationV2PreservedAsHistory
        )
        XCTAssertTrue(contract.donorAdaptationV3Required)
        XCTAssertTrue(
            contract
                .mutationProducerDetectorTargetAssignmentDeferred
        )
        XCTAssertTrue(
            contract.mutationProducerDetectorMustBeDisjoint
        )
        XCTAssertEqual(
            contract.packageCaptureAuthority,
            "actual_package_secure_capture_only_not_v6_or_v7_execution_graph_reconciliation"
        )
        XCTAssertEqual(
            contract.nextImplementationPrerequisite,
            "freeze_corrected_process_evaluation_receipt_ownership_and_lawful_target_free_schedule_delivery_then_assign_disjoint_source_bound_mutation_producer_detector_without_materializing_workers"
        )

        XCTAssertEqual(
            try historicalV1.contentSHA256(),
            "48e0f64fcb14193d74bf9c3d98a8aeef7ca366033cea6d8f00bc345ff0ad86b5"
        )
        XCTAssertEqual(
            try historicalV2.contentSHA256(),
            "abc8f1ada303ecb95b7c9a44e72293ed314537b93e27354aebbb7763e1487415"
        )
        XCTAssertEqual(
            try historicalV3.contentSHA256(),
            "b475e29347a31d27be8dc1aa54648fec84c4f1b47d673a1f111ccffb794985fd"
        )
        XCTAssertEqual(
            try historicalV4.contentSHA256(),
            "8339bbd42b0e4052888db880aacbb067770c08dd2106bf4a7820c853c4b715af"
        )
        XCTAssertEqual(
            try contract.contentSHA256(),
            "252e027fc0f547e96b8c74b2e45cd1c316f1080d639a94619e9c03c87c480930"
        )

        let additiveTargetNames: Set<String> = [
            captureTargetName,
            crosswalkTargetName,
        ]
        XCTAssertEqual(
            contract.targetGraph.filter {
                !additiveTargetNames.contains($0.targetName)
            },
            historicalV4.targetGraph
        )
        let capture = try contract.target(
            named: captureTargetName
        )
        XCTAssertEqual(capture.materialization, .implemented)
        XCTAssertEqual(
            capture.directLocalDependencyNames,
            [
                "PrimeCore",
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplaySourceBinding",
            ]
        )
        XCTAssertTrue(
            capture.externalProductDependencyNames.isEmpty
        )
        let crosswalk = try contract.target(
            named: crosswalkTargetName
        )
        XCTAssertEqual(crosswalk.materialization, .implemented)
        XCTAssertEqual(
            crosswalk.directLocalDependencyNames,
            [
                "PrimeCore",
                "PrimeNativeNeuralGateCorrectedFixtureAuthority",
                "PrimeNativeNeuralGateCorrectedMechanics",
                captureTargetName,
                "PrimeNativeNeuralGateReplayComposition",
                "PrimeNativeNeuralGateReplaySourceComposition",
                "PrimeNativeNeuralGateReplayTransport",
            ]
        )
        XCTAssertTrue(
            crosswalk.externalProductDependencyNames.isEmpty
        )

        XCTAssertEqual(
            try contract.transitiveLocalTargetNames(
                reachableFrom: captureTargetName
            ),
            [
                "PrimeCore",
                "PrimeNativeNeuralGateCorrectedMechanics",
                "PrimeNativeNeuralGateLogitSidecarMechanics",
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplayMechanics",
                "PrimeNativeNeuralGateReplaySourceBinding",
                "PrimeNativeNeuralGateReplayTransport",
            ]
        )
        XCTAssertEqual(
            try contract.transitiveLocalTargetNames(
                reachableFrom: crosswalkTargetName
            ),
            [
                "PrimeCore",
                "PrimeNativeCorpusReplayMechanics",
                "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
                "PrimeNativeNeuralGateCorrectedFixtureAuthority",
                "PrimeNativeNeuralGateCorrectedMechanics",
                "PrimeNativeNeuralGateLogitSidecarMechanics",
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplayCaptureInventory",
                "PrimeNativeNeuralGateReplayComposition",
                "PrimeNativeNeuralGateReplayMechanics",
                "PrimeNativeNeuralGateReplaySourceBinding",
                "PrimeNativeNeuralGateReplaySourceComposition",
                "PrimeNativeNeuralGateReplayTransport",
            ]
        )

        let reverseProtectedTargets = [
            "PrimeNativeNeuralGateCorrectedMechanics",
            "PrimeNativeNeuralGatePromptSolver",
            "PrimeNativeNeuralGateLogitSidecarMechanics",
            "PrimeNativeNeuralGateMLXLogSoftmaxRecomputation",
            "PrimeNativeNeuralGateReplayArtifactContracts",
            "PrimeNativeNeuralGateReplayTransport",
            "PrimeNativeNeuralGateReplayProbe",
            "PrimeNativeNeuralGateReplayVerifier",
            "PrimeNativeNeuralGateCorrectedRawWorker",
            "PrimeNativeNeuralGateReplayComposition",
            "PrimeNativeNeuralGateReplaySourceBinding",
            "PrimeNativeNeuralGateReplaySourceComposition",
        ]
        for targetName in reverseProtectedTargets {
            let rule = try XCTUnwrap(
                contract.forbiddenReachability.first {
                    $0.targetName == targetName
                }
            )
            XCTAssertTrue(
                rule.forbiddenReachableTargetNames.contains(
                    captureTargetName
                ),
                targetName
            )
            XCTAssertTrue(
                rule.forbiddenReachableTargetNames.contains(
                    crosswalkTargetName
                ),
                targetName
            )
        }
        XCTAssertEqual(
            try XCTUnwrap(
                contract.forbiddenReachability.first {
                    $0.targetName == captureTargetName
                }
            ).forbiddenReachableTargetNames,
            [
                "PrimeNativeCorpusReplayMechanics",
                "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
                "PrimeNativeNeuralGateCorrectedFixtureAuthority",
                "PrimeNativeNeuralGatePromptSolver",
                "PrimeNativeNeuralGateMLXLogSoftmaxRecomputation",
                crosswalkTargetName,
                "ErgenticsPrimeRuntime",
                "PrimeNativeNeuralGateHistoricalReplayMechanics",
            ]
        )
        XCTAssertEqual(
            try XCTUnwrap(
                contract.forbiddenReachability.first {
                    $0.targetName == crosswalkTargetName
                }
            ).forbiddenReachableTargetNames,
            [
                "PrimeNativeNeuralGatePromptSolver",
                "PrimeNativeNeuralGateMLXLogSoftmaxRecomputation",
                "ErgenticsPrimeRuntime",
                "PrimeNativeNeuralGateHistoricalReplayMechanics",
                "PrimeNativeNeuralGateHistoricalFixtureWorker",
                "PrimeNativeNeuralGateReplayProbe",
                "PrimeNativeNeuralGateReplayVerifier",
                "PrimeNativeNeuralGateCorrectedRawWorker",
            ]
        )

        let supervisorClosure = [
            "PrimeCore",
            "PrimeNativeNeuralGateReplayArtifactContracts",
            "PrimeNativeNeuralGateReplayMechanics",
            "PrimeNativeNeuralGateReplayTransport",
        ]
        XCTAssertEqual(
            try contract.transitiveLocalTargetNames(
                reachableFrom:
                    "PrimeNativeNeuralGateReplayProbe"
            ),
            supervisorClosure
        )
        XCTAssertEqual(
            try contract.transitiveLocalTargetNames(
                reachableFrom:
                    "PrimeNativeNeuralGateReplayVerifier"
            ),
            supervisorClosure
        )
        XCTAssertEqual(
            try contract.transitiveLocalTargetNames(
                reachableFrom:
                    "PrimeNativeNeuralGateCorrectedRawWorker"
            ),
            [
                "PrimeCore",
                "PrimeNativeNeuralGateCorrectedMechanics",
                "PrimeNativeNeuralGateLogitSidecarMechanics",
                "PrimeNativeNeuralGatePromptSolver",
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplayMechanics",
            ]
        )
        for targetName in [
            "PrimeNativeNeuralGateReplayProbe",
            "PrimeNativeNeuralGateReplayVerifier",
            "PrimeNativeNeuralGateCorrectedRawWorker",
        ] {
            let closure = try contract.transitiveLocalTargetNames(
                reachableFrom: targetName
            )
            XCTAssertFalse(
                closure.contains(captureTargetName),
                targetName
            )
            XCTAssertFalse(
                closure.contains(crosswalkTargetName),
                targetName
            )
        }
        for targetName in [
            "ErgenticsPrimeRuntime",
            "PrimeNativeNeuralGateHistoricalReplayMechanics",
            "PrimeNativeNeuralGateHistoricalFixtureWorker",
            "PrimeNativeNeuralGateReplayProbe",
            "PrimeNativeNeuralGateReplayVerifier",
            "PrimeNativeNeuralGateCorrectedRawWorker",
        ] {
            XCTAssertEqual(
                try contract.target(
                    named: targetName
                ).materialization,
                .plannedNotMaterialized,
                targetName
            )
        }
    }

    func testTopologyV6FreezesOwnershipAndTargetFreeDeliveryWithoutProcesses()
        throws
    {
        let historicalV1 = Contract.frozenV1
        let historicalV2 = Contract.frozenV2
        let historicalV3 = Contract.frozenV3
        let historicalV4 = Contract.frozenV4
        let historicalV5 = Contract.frozenV5
        let contract = Contract.frozenV6
        let sourceCompositionTargetName =
            "PrimeNativeNeuralGateReplaySourceComposition"
        let rawWorkerTargetName =
            "PrimeNativeNeuralGateCorrectedRawWorker"
        let probeTargetName =
            "PrimeNativeNeuralGateReplayProbe"
        let verifierTargetName =
            "PrimeNativeNeuralGateReplayVerifier"
        let scheduleTargetName =
            "PrimeNativeNeuralGateTargetFreeScheduleDeliveryContracts"
        let processTargetName =
            "PrimeNativeNeuralGateCorrectedProcessOwnershipContracts"
        let evaluationTargetName =
            "PrimeNativeNeuralGateCorrectedEvaluationOwnershipContracts"
        let terminalTargetName =
            "PrimeNativeNeuralGateTerminalReceiptOwnershipContracts"
        let deliveryAuthorityTargetName =
            "PrimeNativeNeuralGateTargetFreeScheduleDeliveryAuthority"
        let probeEvaluationTargetName =
            "PrimeNativeNeuralGateCorrectedProbeEvaluationWorker"
        let verifierEvaluationTargetName =
            "PrimeNativeNeuralGateCorrectedVerifierEvaluationWorker"

        for historical in [
            historicalV1,
            historicalV2,
            historicalV3,
            historicalV4,
            historicalV5,
        ] {
            XCTAssertNoThrow(try historical.validate())
        }
        XCTAssertNoThrow(try contract.validate())
        XCTAssertEqual(contract.schemaVersion, 6)
        XCTAssertEqual(
            contract.contractID,
            "prime_stage_b_process_evaluation_receipt_ownership_target_free_delivery_topology_v6"
        )
        XCTAssertEqual(contract.status, .plannedNotMaterialized)
        XCTAssertFalse(contract.executionImplemented)
        XCTAssertFalse(contract.sourceBindingV7Issued)
        XCTAssertTrue(contract.historicalContractsPreserved)
        XCTAssertTrue(
            contract.historicalFutureTargetGraphSuperseded
        )
        XCTAssertTrue(
            contract.donorAdaptationV2PreservedAsHistory
        )
        XCTAssertTrue(contract.donorAdaptationV3Required)
        XCTAssertTrue(
            contract
                .mutationProducerDetectorTargetAssignmentDeferred
        )
        XCTAssertTrue(
            contract.mutationProducerDetectorMustBeDisjoint
        )
        XCTAssertEqual(
            contract.packageCaptureAuthority,
            "actual_package_secure_capture_only_not_v6_or_v7_execution_graph_reconciliation"
        )
        XCTAssertEqual(
            contract.nextImplementationPrerequisite,
            "freeze_typed_source_pinned_worker_and_role_artifact_references_with_common_capture_schedule_binding_and_bounded_candidate_stream_decoder_then_freeze_deferred_mutation_historical_mlx_statistics_verdict_schemas_and_assign_disjoint_source_bound_mutation_producer_detector_without_materializing_workers"
        )
        XCTAssertTrue(
            contract.authorityStatement.contains(
                "exact symmetric 10-process future topology"
            )
        )
        XCTAssertTrue(
            contract.authorityStatement.contains(
                "No process delivery"
            )
        )

        XCTAssertEqual(
            try historicalV1.contentSHA256(),
            "48e0f64fcb14193d74bf9c3d98a8aeef7ca366033cea6d8f00bc345ff0ad86b5"
        )
        XCTAssertEqual(
            try historicalV2.contentSHA256(),
            "abc8f1ada303ecb95b7c9a44e72293ed314537b93e27354aebbb7763e1487415"
        )
        XCTAssertEqual(
            try historicalV3.contentSHA256(),
            "b475e29347a31d27be8dc1aa54648fec84c4f1b47d673a1f111ccffb794985fd"
        )
        XCTAssertEqual(
            try historicalV4.contentSHA256(),
            "8339bbd42b0e4052888db880aacbb067770c08dd2106bf4a7820c853c4b715af"
        )
        XCTAssertEqual(
            try historicalV5.contentSHA256(),
            "252e027fc0f547e96b8c74b2e45cd1c316f1080d639a94619e9c03c87c480930"
        )
        XCTAssertEqual(
            try contract.contentSHA256(),
            "6a25a3d674a7ef3eda4475ed5532fff2366103b641736b410b37fabbc805bcd1"
        )

        let changedHistoricalTargetNames: Set<String> = [
            sourceCompositionTargetName,
            rawWorkerTargetName,
            probeTargetName,
            verifierTargetName,
        ]
        let newTargetNames: Set<String> = [
            scheduleTargetName,
            processTargetName,
            evaluationTargetName,
            terminalTargetName,
            deliveryAuthorityTargetName,
            probeEvaluationTargetName,
            verifierEvaluationTargetName,
        ]
        XCTAssertEqual(
            contract.targetGraph.filter {
                !changedHistoricalTargetNames.contains(
                    $0.targetName
                )
                    && !newTargetNames.contains(
                        $0.targetName
                    )
            },
            historicalV5.targetGraph.filter {
                !changedHistoricalTargetNames.contains(
                    $0.targetName
                )
            }
        )

        let schedule = try contract.target(
            named: scheduleTargetName
        )
        XCTAssertEqual(schedule.materialization, .implemented)
        XCTAssertEqual(
            schedule.directLocalDependencyNames,
            [
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplayMechanics",
                "PrimeNativeNeuralGateCorrectedMechanics",
            ]
        )
        XCTAssertTrue(
            schedule.externalProductDependencyNames.isEmpty
        )
        XCTAssertTrue(
            schedule.authority.contains(
                "raw slots admit only"
            )
        )
        let process = try contract.target(
            named: processTargetName
        )
        XCTAssertEqual(process.materialization, .implemented)
        XCTAssertEqual(
            process.directLocalDependencyNames,
            [
                "PrimeNativeNeuralGateReplayArtifactContracts",
                scheduleTargetName,
            ]
        )
        XCTAssertTrue(
            process.authority.contains(
                "exact symmetric 10-process topology"
            )
        )
        let evaluation = try contract.target(
            named: evaluationTargetName
        )
        XCTAssertEqual(evaluation.materialization, .implemented)
        XCTAssertEqual(
            evaluation.directLocalDependencyNames,
            [
                "PrimeNativeNeuralGateReplayArtifactContracts",
                processTargetName,
            ]
        )
        XCTAssertTrue(
            evaluation.authority.contains(
                "no fixture, crosswalk, evaluator implementation, or receipt authority"
            )
        )
        let terminal = try contract.target(
            named: terminalTargetName
        )
        XCTAssertEqual(terminal.materialization, .implemented)
        XCTAssertEqual(
            terminal.directLocalDependencyNames,
            [
                "PrimeNativeNeuralGateReplayArtifactContracts",
                processTargetName,
                evaluationTargetName,
            ]
        )
        XCTAssertTrue(
            terminal.authority.contains(
                "exclusive no-replace receipt-last ordering"
            )
        )
        XCTAssertTrue(
            terminal.authority.contains(
                "publication remains unimplemented and unauthorized"
            )
        )
        let deliveryAuthority = try contract.target(
            named: deliveryAuthorityTargetName
        )
        XCTAssertEqual(
            deliveryAuthority.materialization,
            .implemented
        )
        XCTAssertEqual(
            deliveryAuthority.directLocalDependencyNames,
            [
                "PrimeNativeNeuralGateReplayCaptureInventory",
                sourceCompositionTargetName,
                scheduleTargetName,
                processTargetName,
                evaluationTargetName,
            ]
        )
        XCTAssertTrue(
            deliveryAuthority.authority.contains(
                "pre/post recapture"
            )
        )
        XCTAssertTrue(
            deliveryAuthority.authority.contains(
                "no delivery is observed"
            )
        )

        XCTAssertEqual(
            try contract.target(
                named: sourceCompositionTargetName
            ).directLocalDependencyNames,
            [
                "PrimeNativeNeuralGateReplaySourceBinding",
                "PrimeNativeNeuralGateReplayComposition",
                scheduleTargetName,
            ]
        )
        XCTAssertEqual(
            try contract.target(
                named: rawWorkerTargetName
            ).directLocalDependencyNames,
            [
                "PrimeNativeNeuralGateCorrectedMechanics",
                "PrimeNativeNeuralGatePromptSolver",
                "PrimeNativeNeuralGateLogitSidecarMechanics",
                "PrimeNativeNeuralGateReplayArtifactContracts",
                scheduleTargetName,
                processTargetName,
            ]
        )
        XCTAssertEqual(
            try contract.target(
                named: probeTargetName
            ).directLocalDependencyNames,
            [
                "PrimeCore",
                "PrimeNativeNeuralGateReplayTransport",
                processTargetName,
            ]
        )
        XCTAssertEqual(
            try contract.target(
                named: verifierTargetName
            ).directLocalDependencyNames,
            [
                "PrimeCore",
                "PrimeNativeNeuralGateReplayTransport",
                processTargetName,
                evaluationTargetName,
                terminalTargetName,
            ]
        )

        for evaluationWorkerName in [
            probeEvaluationTargetName,
            verifierEvaluationTargetName,
        ] {
            let worker = try contract.target(
                named: evaluationWorkerName
            )
            XCTAssertEqual(
                worker.materialization,
                .plannedNotMaterialized
            )
            XCTAssertEqual(
                worker.directLocalDependencyNames,
                [
                    "PrimeCore",
                    "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
                    "PrimeNativeNeuralGatePromptTargetCrosswalkAuthority",
                    evaluationTargetName,
                ]
            )
            XCTAssertTrue(
                worker.externalProductDependencyNames.isEmpty
            )
            XCTAssertTrue(
                worker.authority.contains(
                    "cannot publish a terminal receipt"
                )
            )
        }

        XCTAssertEqual(
            try contract.transitiveLocalTargetNames(
                reachableFrom: scheduleTargetName
            ),
            [
                "PrimeNativeNeuralGateCorrectedMechanics",
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplayMechanics",
            ]
        )
        XCTAssertEqual(
            try contract.transitiveLocalTargetNames(
                reachableFrom: processTargetName
            ),
            [
                "PrimeNativeNeuralGateCorrectedMechanics",
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplayMechanics",
                scheduleTargetName,
            ]
        )
        XCTAssertEqual(
            try contract.transitiveLocalTargetNames(
                reachableFrom: evaluationTargetName
            ),
            [
                processTargetName,
                "PrimeNativeNeuralGateCorrectedMechanics",
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplayMechanics",
                scheduleTargetName,
            ].sorted()
        )
        XCTAssertEqual(
            try contract.transitiveLocalTargetNames(
                reachableFrom: terminalTargetName
            ),
            [
                evaluationTargetName,
                processTargetName,
                "PrimeNativeNeuralGateCorrectedMechanics",
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplayMechanics",
                scheduleTargetName,
            ].sorted()
        )
        XCTAssertEqual(
            try contract.transitiveLocalTargetNames(
                reachableFrom: rawWorkerTargetName
            ),
            [
                processTargetName,
                "PrimeNativeNeuralGateCorrectedMechanics",
                "PrimeNativeNeuralGateLogitSidecarMechanics",
                "PrimeNativeNeuralGatePromptSolver",
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplayMechanics",
                scheduleTargetName,
            ].sorted()
        )
        XCTAssertEqual(
            try contract.transitiveLocalTargetNames(
                reachableFrom: probeTargetName
            ),
            [
                processTargetName,
                "PrimeCore",
                "PrimeNativeNeuralGateCorrectedMechanics",
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplayMechanics",
                "PrimeNativeNeuralGateReplayTransport",
                scheduleTargetName,
            ].sorted()
        )
        XCTAssertEqual(
            try contract.transitiveLocalTargetNames(
                reachableFrom: verifierTargetName
            ),
            [
                evaluationTargetName,
                processTargetName,
                "PrimeCore",
                "PrimeNativeNeuralGateCorrectedMechanics",
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplayMechanics",
                "PrimeNativeNeuralGateReplayTransport",
                scheduleTargetName,
                terminalTargetName,
            ].sorted()
        )

        let rawClosure = Set(
            try contract.transitiveLocalTargetNames(
                reachableFrom: rawWorkerTargetName
            )
        )
        for forbidden in [
            "PrimeCore",
            "PrimeNativeCorpusReplayMechanics",
            "PrimeNativeNeuralGateReplayTransport",
            "PrimeNativeNeuralGateReplayComposition",
            "PrimeNativeNeuralGateReplaySourceBinding",
            sourceCompositionTargetName,
            "PrimeNativeNeuralGateReplayCaptureInventory",
            "PrimeNativeNeuralGatePromptTargetCrosswalkAuthority",
            "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
            "PrimeNativeNeuralGateCorrectedFixtureAuthority",
            evaluationTargetName,
            terminalTargetName,
            deliveryAuthorityTargetName,
            probeEvaluationTargetName,
            verifierEvaluationTargetName,
        ] {
            XCTAssertFalse(
                rawClosure.contains(forbidden),
                forbidden
            )
        }
        let rawRule = try XCTUnwrap(
            contract.forbiddenReachability.first {
                $0.targetName == rawWorkerTargetName
            }
        )
        for forbidden in [
            "PrimeCore",
            "PrimeNativeNeuralGateReplayTransport",
            "PrimeNativeNeuralGateReplayComposition",
            "PrimeNativeNeuralGateReplaySourceBinding",
            sourceCompositionTargetName,
            "PrimeNativeNeuralGateReplayCaptureInventory",
            "PrimeNativeNeuralGatePromptTargetCrosswalkAuthority",
            "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
            "PrimeNativeNeuralGateCorrectedFixtureAuthority",
            evaluationTargetName,
            terminalTargetName,
            deliveryAuthorityTargetName,
            "PrimeNativeNeuralGateCorrectedMutationDetector",
        ] {
            XCTAssertTrue(
                rawRule.forbiddenReachableTargetNames
                    .contains(forbidden),
                forbidden
            )
        }

        for contractTargetName in [
            scheduleTargetName,
            processTargetName,
            evaluationTargetName,
            terminalTargetName,
        ] {
            let rule = try XCTUnwrap(
                contract.forbiddenReachability.first {
                    $0.targetName == contractTargetName
                }
            )
            for forbidden in [
                "PrimeNativeNeuralGateReplayCaptureInventory",
                "PrimeNativeNeuralGatePromptTargetCrosswalkAuthority",
                "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
                "PrimeNativeNeuralGateCorrectedFixtureAuthority",
                probeEvaluationTargetName,
                verifierEvaluationTargetName,
                "PrimeNativeNeuralGateCorrectedMutationDetector",
                "ErgenticsPrimeRuntime",
                "PrimeNativeNeuralGateHistoricalReplayMechanics",
            ] {
                XCTAssertTrue(
                    rule.forbiddenReachableTargetNames
                        .contains(forbidden),
                    "\(contractTargetName): \(forbidden)"
                )
            }
        }
        let deliveryAuthorityRule = try XCTUnwrap(
            contract.forbiddenReachability.first {
                $0.targetName == deliveryAuthorityTargetName
            }
        )
        for forbidden in [
            "PrimeNativeNeuralGatePromptTargetCrosswalkAuthority",
            "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
            "PrimeNativeNeuralGateCorrectedFixtureAuthority",
            terminalTargetName,
            probeEvaluationTargetName,
            verifierEvaluationTargetName,
            "PrimeNativeNeuralGateCorrectedMutationDetector",
            "ErgenticsPrimeRuntime",
            "PrimeNativeNeuralGateHistoricalReplayMechanics",
        ] {
            XCTAssertTrue(
                deliveryAuthorityRule.forbiddenReachableTargetNames
                    .contains(forbidden),
                forbidden
            )
        }

        for targetName in [
            "ErgenticsPrimeRuntime",
            "PrimeNativeNeuralGateHistoricalReplayMechanics",
            "PrimeNativeNeuralGateHistoricalFixtureWorker",
            probeTargetName,
            verifierTargetName,
            rawWorkerTargetName,
            probeEvaluationTargetName,
            verifierEvaluationTargetName,
        ] {
            XCTAssertEqual(
                try contract.target(
                    named: targetName
                ).materialization,
                .plannedNotMaterialized,
                targetName
            )
        }
    }

    func testTopologyV7FreezesTypedReferencesAndBoundedStreamsWithoutWorkers()
        throws
    {
        let historical = Contract.frozenV6
        let contract = Contract.frozenV7
        let scheduleTargetName =
            "PrimeNativeNeuralGateTargetFreeScheduleDeliveryContracts"
        let referenceContractsTargetName =
            "PrimeNativeNeuralGateRoleArtifactReferenceContracts"
        let referenceAuthorityTargetName =
            "PrimeNativeNeuralGateRoleArtifactReferenceAuthority"

        XCTAssertNoThrow(try historical.validate())
        XCTAssertNoThrow(try contract.validate())
        XCTAssertEqual(contract.schemaVersion, 7)
        XCTAssertEqual(
            contract.contractID,
            "prime_stage_b_typed_worker_artifact_reference_and_bounded_schedule_stream_topology_v7"
        )
        XCTAssertEqual(contract.status, .plannedNotMaterialized)
        XCTAssertFalse(contract.executionImplemented)
        XCTAssertFalse(contract.sourceBindingV7Issued)
        XCTAssertTrue(contract.historicalContractsPreserved)
        XCTAssertTrue(
            contract.historicalFutureTargetGraphSuperseded
        )
        XCTAssertTrue(
            contract.mutationProducerDetectorTargetAssignmentDeferred
        )
        XCTAssertEqual(
            contract.nextImplementationPrerequisite,
            "freeze_deferred_mutation_historical_mlx_statistics_verdict_schemas_and_assign_disjoint_source_bound_mutation_producer_detector_without_materializing_workers"
        )
        XCTAssertTrue(
            contract.authorityStatement.contains(
                "no missing target is treated as a compiled closure"
            )
        )
        XCTAssertTrue(
            contract.authorityStatement.contains(
                "No process delivery"
            )
        )
        XCTAssertEqual(
            try historical.contentSHA256(),
            "6a25a3d674a7ef3eda4475ed5532fff2366103b641736b410b37fabbc805bcd1"
        )
        XCTAssertEqual(
            PrimeNativeNeuralGateCommonCaptureScheduleReference
                .captureInventoryContractID,
            PrimeNativeNeuralGateReplayCaptureInventoryContract
                .frozenV1.contractID
        )
        XCTAssertEqual(
            try contract.contentSHA256(),
            "88fd8b2da5590576a3c9868e1ede55efb228e82d853d5db67a1d17d58834c156"
        )

        let schedule = try contract.target(
            named: scheduleTargetName
        )
        XCTAssertEqual(schedule.materialization, .implemented)
        XCTAssertEqual(
            schedule.directLocalDependencyNames,
            try historical.target(
                named: scheduleTargetName
            ).directLocalDependencyNames
        )
        XCTAssertTrue(
            schedule.authority.contains(
                "exact-18432-record incremental PRIMEIRM1"
            )
        )
        XCTAssertTrue(
            schedule.authority.contains(
                "aggregate candidates remain non-Decodable"
            )
        )

        let references = try contract.target(
            named: referenceContractsTargetName
        )
        XCTAssertEqual(references.materialization, .implemented)
        XCTAssertEqual(
            references.directLocalDependencyNames,
            [
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplayMechanics",
                scheduleTargetName,
                "PrimeNativeNeuralGateCorrectedProcessOwnershipContracts",
                "PrimeNativeNeuralGateCorrectedEvaluationOwnershipContracts",
                "PrimeNativeNeuralGateTerminalReceiptOwnershipContracts",
            ]
        )
        XCTAssertTrue(
            references.authority.contains(
                "six-worker typed Release source-reference schema"
            )
        )
        XCTAssertTrue(
            references.authority.contains(
                "actual worker closures, executables, and artifact content remain unobserved"
            )
        )

        let authority = try contract.target(
            named: referenceAuthorityTargetName
        )
        XCTAssertEqual(authority.materialization, .implemented)
        XCTAssertEqual(
            authority.directLocalDependencyNames,
            [
                referenceContractsTargetName,
                "PrimeNativeNeuralGateTargetFreeScheduleDeliveryAuthority",
                "PrimeNativeNeuralGateCorrectedProcessOwnershipContracts",
                scheduleTargetName,
            ]
        )
        XCTAssertTrue(
            authority.authority.contains(
                "pre/post recapture"
            )
        )
        XCTAssertTrue(
            authority.authority.contains(
                "no artifact or process delivery is observed"
            )
        )

        let pureClosure = Set(
            try contract.transitiveLocalTargetNames(
                reachableFrom:
                    referenceContractsTargetName
            )
        )
        for forbidden in [
            "PrimeCore",
            "PrimeNativeNeuralGateReplayTransport",
            "PrimeNativeNeuralGateReplaySourceBinding",
            "PrimeNativeNeuralGateReplayCaptureInventory",
            "PrimeNativeNeuralGatePromptTargetCrosswalkAuthority",
            "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
            "PrimeNativeNeuralGateCorrectedFixtureAuthority",
            "PrimeNativeNeuralGateMLXLogSoftmaxRecomputation",
            "ErgenticsPrimeRuntime",
        ] {
            XCTAssertFalse(
                pureClosure.contains(forbidden),
                forbidden
            )
        }

        for rule in historical.forbiddenReachability {
            let updated = try XCTUnwrap(
                contract.forbiddenReachability.first {
                    $0.targetName == rule.targetName
                }
            )
            XCTAssertTrue(
                updated.forbiddenReachableTargetNames
                    .contains(referenceContractsTargetName),
                rule.targetName
            )
            XCTAssertTrue(
                updated.forbiddenReachableTargetNames
                    .contains(referenceAuthorityTargetName),
                rule.targetName
            )
        }

        for targetName in [
            "ErgenticsPrimeRuntime",
            "PrimeNativeNeuralGateHistoricalReplayMechanics",
            "PrimeNativeNeuralGateHistoricalFixtureWorker",
            "PrimeNativeNeuralGateReplayProbe",
            "PrimeNativeNeuralGateReplayVerifier",
            "PrimeNativeNeuralGateCorrectedRawWorker",
            "PrimeNativeNeuralGateCorrectedProbeEvaluationWorker",
            "PrimeNativeNeuralGateCorrectedVerifierEvaluationWorker",
        ] {
            XCTAssertEqual(
                try contract.target(
                    named: targetName
                ).materialization,
                .plannedNotMaterialized,
                targetName
            )
        }
    }

    func testTopologyV8FreezesSemanticRecordsAndDisjointMutationTargetsWithoutWorkers()
        throws
    {
        let historical = Contract.frozenV7
        let contract = Contract.frozenV8
        let surfaceTargetName =
            "PrimeNativeNeuralGateCorrectedMutationSurfaceContracts"
        let semanticTargetName =
            "PrimeNativeNeuralGateSemanticRecordContracts"
        let producerTargetName =
            "PrimeNativeNeuralGateCorrectedMutationProducer"
        let detectorTargetName =
            "PrimeNativeNeuralGateCorrectedMutationDetector"

        XCTAssertNoThrow(try historical.validate())
        XCTAssertNoThrow(try contract.validate())
        XCTAssertEqual(contract.schemaVersion, 8)
        XCTAssertEqual(
            contract.contractID,
            "prime_stage_b_semantic_record_schema_and_disjoint_corrected_mutation_targets_topology_v8"
        )
        XCTAssertEqual(contract.status, .plannedNotMaterialized)
        XCTAssertFalse(contract.executionImplemented)
        XCTAssertFalse(contract.sourceBindingV7Issued)
        XCTAssertTrue(contract.historicalContractsPreserved)
        XCTAssertTrue(
            contract.historicalFutureTargetGraphSuperseded
        )
        XCTAssertFalse(
            contract.mutationProducerDetectorTargetAssignmentDeferred
        )
        XCTAssertTrue(
            contract.mutationProducerDetectorMustBeDisjoint
        )
        XCTAssertEqual(
            contract.nextImplementationPrerequisite,
            "derive_source_pinned_historical_gate_carrier_and_forty_six_mutation_material_without_materializing_workers_or_issuing_source_binding_v7"
        )
        XCTAssertTrue(
            contract.authorityStatement.contains(
                "package materialization is not Stage-B execution evidence"
            )
        )
        XCTAssertTrue(
            contract.authorityStatement.contains(
                "every supervisor, worker, executable, process"
            )
        )
        XCTAssertTrue(
            contract.authorityStatement.contains(
                "durable or process-scoped mutation execution/detection observation"
            )
        )
        XCTAssertTrue(
            contract.authorityStatement.contains(
                "structurally unable to reach semantic catalog or identity mapping"
            )
        )

        let preservedTopologyDigests = [
            (
                Contract.frozenV1,
                "48e0f64fcb14193d74bf9c3d98a8aeef7ca366033cea6d8f00bc345ff0ad86b5"
            ),
            (
                Contract.frozenV2,
                "abc8f1ada303ecb95b7c9a44e72293ed314537b93e27354aebbb7763e1487415"
            ),
            (
                Contract.frozenV3,
                "b475e29347a31d27be8dc1aa54648fec84c4f1b47d673a1f111ccffb794985fd"
            ),
            (
                Contract.frozenV4,
                "8339bbd42b0e4052888db880aacbb067770c08dd2106bf4a7820c853c4b715af"
            ),
            (
                Contract.frozenV5,
                "252e027fc0f547e96b8c74b2e45cd1c316f1080d639a94619e9c03c87c480930"
            ),
            (
                Contract.frozenV6,
                "6a25a3d674a7ef3eda4475ed5532fff2366103b641736b410b37fabbc805bcd1"
            ),
            (
                Contract.frozenV7,
                "88fd8b2da5590576a3c9868e1ede55efb228e82d853d5db67a1d17d58834c156"
            ),
        ]
        for (preserved, expectedSHA256)
            in preservedTopologyDigests
        {
            XCTAssertNoThrow(try preserved.validate())
            XCTAssertEqual(
                try preserved.contentSHA256(),
                expectedSHA256
            )
        }
        XCTAssertEqual(
            try contract.contentSHA256(),
            "8f49c8322951249568915cb5b6a9971e251127ff865709292f0c7a7bd0f1db5b"
        )

        XCTAssertEqual(
            Array(contract.targetGraph.dropLast(4)),
            historical.targetGraph
        )
        XCTAssertEqual(
            contract.targetGraph.count,
            historical.targetGraph.count + 4
        )

        let surface = try contract.target(
            named: surfaceTargetName
        )
        XCTAssertEqual(surface.materialization, .implemented)
        XCTAssertEqual(
            surface.directLocalDependencyNames,
            ["PrimeNativeNeuralGateReplayMechanics"]
        )
        XCTAssertTrue(
            surface.externalProductDependencyNames.isEmpty
        )

        let semantic = try contract.target(
            named: semanticTargetName
        )
        XCTAssertEqual(semantic.materialization, .implemented)
        XCTAssertEqual(
            semantic.directLocalDependencyNames,
            [
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplayMechanics",
                surfaceTargetName,
            ]
        )
        XCTAssertTrue(
            semantic.externalProductDependencyNames.isEmpty
        )

        let producer = try contract.target(
            named: producerTargetName
        )
        XCTAssertEqual(producer.materialization, .implemented)
        XCTAssertEqual(
            producer.directLocalDependencyNames,
            [semanticTargetName, surfaceTargetName]
        )
        XCTAssertTrue(
            producer.externalProductDependencyNames.isEmpty
        )

        let detector = try contract.target(
            named: detectorTargetName
        )
        XCTAssertEqual(detector.materialization, .implemented)
        XCTAssertEqual(
            detector.directLocalDependencyNames,
            [surfaceTargetName]
        )
        XCTAssertTrue(
            detector.externalProductDependencyNames.isEmpty
        )

        let surfaceClosure = Set(
            try contract.transitiveLocalTargetNames(
                reachableFrom: surfaceTargetName
            )
        )
        XCTAssertEqual(
            surfaceClosure,
            ["PrimeNativeNeuralGateReplayMechanics"]
        )
        XCTAssertFalse(surfaceClosure.contains(semanticTargetName))
        XCTAssertFalse(surfaceClosure.contains(producerTargetName))
        XCTAssertFalse(surfaceClosure.contains(detectorTargetName))

        let semanticClosure = Set(
            try contract.transitiveLocalTargetNames(
                reachableFrom: semanticTargetName
            )
        )
        XCTAssertEqual(
            semanticClosure,
            [
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplayMechanics",
                surfaceTargetName,
            ]
        )
        XCTAssertFalse(semanticClosure.contains(producerTargetName))
        XCTAssertFalse(semanticClosure.contains(detectorTargetName))

        let expectedProducerClosure: Set<String> = [
            semanticTargetName,
            surfaceTargetName,
            "PrimeNativeNeuralGateReplayArtifactContracts",
            "PrimeNativeNeuralGateReplayMechanics",
        ]
        let producerClosure = Set(
            try contract.transitiveLocalTargetNames(
                reachableFrom: producerTargetName
            )
        )
        let detectorClosure = Set(
            try contract.transitiveLocalTargetNames(
                reachableFrom: detectorTargetName
            )
        )
        XCTAssertEqual(
            producerClosure,
            expectedProducerClosure
        )
        XCTAssertEqual(
            detectorClosure,
            [
                surfaceTargetName,
                "PrimeNativeNeuralGateReplayMechanics",
            ]
        )
        XCTAssertFalse(producerClosure.contains(detectorTargetName))
        XCTAssertFalse(detectorClosure.contains(producerTargetName))
        XCTAssertFalse(detectorClosure.contains(semanticTargetName))
        XCTAssertFalse(
            detectorClosure.contains(
                "PrimeNativeNeuralGateReplayArtifactContracts"
            )
        )

        let transportClosure = Set(
            try contract.transitiveLocalTargetNames(
                reachableFrom:
                    "PrimeNativeNeuralGateReplayTransport"
            )
        )
        XCTAssertFalse(transportClosure.contains(surfaceTargetName))
        XCTAssertFalse(transportClosure.contains(semanticTargetName))
        XCTAssertFalse(transportClosure.contains(producerTargetName))
        XCTAssertFalse(transportClosure.contains(detectorTargetName))

        let surfaceRule = try XCTUnwrap(
            contract.forbiddenReachability.first {
                $0.targetName == surfaceTargetName
            }
        )
        let semanticRule = try XCTUnwrap(
            contract.forbiddenReachability.first {
                $0.targetName == semanticTargetName
            }
        )
        let producerRule = try XCTUnwrap(
            contract.forbiddenReachability.first {
                $0.targetName == producerTargetName
            }
        )
        let detectorRule = try XCTUnwrap(
            contract.forbiddenReachability.first {
                $0.targetName == detectorTargetName
            }
        )
        XCTAssertTrue(
            producerRule.forbiddenReachableTargetNames
                .contains(detectorTargetName)
        )
        XCTAssertTrue(
            detectorRule.forbiddenReachableTargetNames
                .contains(producerTargetName)
        )
        XCTAssertTrue(
            surfaceRule.forbiddenReachableTargetNames
                .contains(semanticTargetName)
        )
        XCTAssertTrue(
            semanticRule.forbiddenReachableTargetNames
                .contains(detectorTargetName)
        )
        XCTAssertTrue(
            detectorRule.forbiddenReachableTargetNames
                .contains(semanticTargetName)
        )
        XCTAssertTrue(
            detectorRule.forbiddenReachableTargetNames
                .contains(
                    "PrimeNativeNeuralGateReplayArtifactContracts"
                )
        )
        for forbidden in [
            "PrimeCore",
            "PrimeNativeCorpusReplayMechanics",
            "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
            "PrimeNativeNeuralGateCorrectedFixtureAuthority",
            "PrimeNativeNeuralGatePromptTargetCrosswalkAuthority",
            "PrimeNativeNeuralGateMLXLogSoftmaxRecomputation",
            "PrimeNativeNeuralGateTargetFreeScheduleDeliveryAuthority",
            "PrimeNativeNeuralGateRoleArtifactReferenceAuthority",
            "PrimeNativeNeuralGateTerminalReceiptOwnershipContracts",
            "ErgenticsPrimeRuntime",
            "PrimeNativeNeuralGateHistoricalReplayMechanics",
            "PrimeNativeNeuralGateHistoricalFixtureWorker",
            "PrimeNativeNeuralGateReplayProbe",
            "PrimeNativeNeuralGateReplayVerifier",
            "PrimeNativeNeuralGateCorrectedRawWorker",
            "PrimeNativeNeuralGateCorrectedProbeEvaluationWorker",
            "PrimeNativeNeuralGateCorrectedVerifierEvaluationWorker",
        ] {
            XCTAssertTrue(
                producerRule.forbiddenReachableTargetNames
                    .contains(forbidden),
                forbidden
            )
            XCTAssertTrue(
                detectorRule.forbiddenReachableTargetNames
                    .contains(forbidden),
                forbidden
            )
        }

        for existingTarget in historical.targetGraph {
            let rule = try XCTUnwrap(
                contract.forbiddenReachability.first {
                    $0.targetName == existingTarget.targetName
                }
            )
            XCTAssertTrue(
                rule.forbiddenReachableTargetNames
                    .contains(surfaceTargetName),
                existingTarget.targetName
            )
            XCTAssertTrue(
                rule.forbiddenReachableTargetNames
                    .contains(semanticTargetName),
                existingTarget.targetName
            )
            XCTAssertTrue(
                rule.forbiddenReachableTargetNames
                    .contains(producerTargetName),
                existingTarget.targetName
            )
            XCTAssertTrue(
                rule.forbiddenReachableTargetNames
                    .contains(detectorTargetName),
                existingTarget.targetName
            )
        }

        for targetName in [
            "ErgenticsPrimeRuntime",
            "PrimeNativeNeuralGateHistoricalReplayMechanics",
            "PrimeNativeNeuralGateHistoricalFixtureWorker",
            "PrimeNativeNeuralGateReplayProbe",
            "PrimeNativeNeuralGateReplayVerifier",
            "PrimeNativeNeuralGateCorrectedRawWorker",
            "PrimeNativeNeuralGateCorrectedProbeEvaluationWorker",
            "PrimeNativeNeuralGateCorrectedVerifierEvaluationWorker",
        ] {
            XCTAssertEqual(
                try contract.target(
                    named: targetName
                ).materialization,
                .plannedNotMaterialized,
                targetName
            )
        }
    }

    func testTopologyV9DerivesPinnedHistoricalSourceMaterialWithoutWorkers()
        throws
    {
        let historical = Contract.frozenV8
        let contract = Contract.frozenV9
        let derivationTargetName =
            "PrimeNativeNeuralGateHistoricalSourceDerivation"

        XCTAssertNoThrow(try historical.validate())
        XCTAssertNoThrow(try contract.validate())
        XCTAssertEqual(contract.schemaVersion, 9)
        XCTAssertEqual(
            contract.contractID,
            "prime_stage_b_source_pinned_historical_gate_carrier_mutation_material_topology_v9"
        )
        XCTAssertEqual(
            contract.targetGraph.count,
            historical.targetGraph.count + 1
        )
        XCTAssertEqual(contract.status, .plannedNotMaterialized)
        XCTAssertFalse(contract.executionImplemented)
        XCTAssertFalse(contract.sourceBindingV7Issued)
        XCTAssertTrue(contract.historicalContractsPreserved)
        XCTAssertFalse(
            contract
                .mutationProducerDetectorTargetAssignmentDeferred
        )
        XCTAssertTrue(
            contract.mutationProducerDetectorMustBeDisjoint
        )
        XCTAssertEqual(
            contract.nextImplementationPrerequisite,
            "author_and_source_bind_prime_historical_observation_seam_and_materialize_historical_replay_mechanics_without_materializing_workers_or_issuing_source_binding_v7"
        )
        XCTAssertTrue(
            contract.authorityStatement.contains(
                "same-family named-leg dispatch"
            )
        )
        XCTAssertTrue(
            contract.authorityStatement.contains(
                "No PrimeCore"
            )
        )
        XCTAssertTrue(
            contract.authorityStatement.contains(
                "per-case parser"
            )
        )

        let target = try contract.target(
            named: derivationTargetName
        )
        XCTAssertEqual(target.materialization, .implemented)
        XCTAssertEqual(
            target.directLocalDependencyNames,
            [
                "PrimeNativeNeuralGateReplayMechanics",
            ]
        )
        XCTAssertTrue(
            target.externalProductDependencyNames.isEmpty
        )
        XCTAssertEqual(
            try contract.transitiveLocalTargetNames(
                reachableFrom: derivationTargetName
            ),
            [
                "PrimeNativeNeuralGateReplayMechanics",
            ]
        )

        for priorTarget in historical.targetGraph {
            let rule = try XCTUnwrap(
                contract.forbiddenReachability.first {
                    $0.targetName == priorTarget.targetName
                }
            )
            XCTAssertTrue(
                rule.forbiddenReachableTargetNames
                    .contains(derivationTargetName),
                priorTarget.targetName
            )
        }
        let derivationRule = try XCTUnwrap(
            contract.forbiddenReachability.first {
                $0.targetName == derivationTargetName
            }
        )
        for forbidden in historical.targetGraph.map(
            \.targetName
        ).filter({
            $0 != "PrimeNativeNeuralGateReplayMechanics"
        }) {
            XCTAssertTrue(
                derivationRule.forbiddenReachableTargetNames
                    .contains(forbidden),
                forbidden
            )
        }

        for targetName in [
            "ErgenticsPrimeRuntime",
            "PrimeNativeNeuralGateHistoricalReplayMechanics",
            "PrimeNativeNeuralGateHistoricalFixtureWorker",
            "PrimeNativeNeuralGateReplayProbe",
            "PrimeNativeNeuralGateReplayVerifier",
            "PrimeNativeNeuralGateCorrectedRawWorker",
            "PrimeNativeNeuralGateCorrectedProbeEvaluationWorker",
            "PrimeNativeNeuralGateCorrectedVerifierEvaluationWorker",
        ] {
            XCTAssertEqual(
                try contract.target(named: targetName)
                    .materialization,
                .plannedNotMaterialized,
                targetName
            )
        }

        let plan =
            PrimeNativeNeuralGateFixtureReplayPlan.frozenV3
        XCTAssertNoThrow(
            try PrimeNativeNeuralGateAdaptationProofContract
                .frozenV2.validate(
                    against: plan.inputPins
                )
        )
        XCTAssertNoThrow(
            try PrimeNativeNeuralGateAdaptationProofContract
                .frozenV3.validate(
                    against: plan.inputPins
                )
        )
        XCTAssertNoThrow(
            try PrimeNativeNeuralGateHistoricalSourceMaterialContract
                .frozenV1.validate()
        )
    }

    func testTopologyV10MaterializesOnlyHistoricalSourceClosure()
        throws
    {
        let historical = Contract.frozenV9
        let contract = Contract.frozenV10
        let runtime = "ErgenticsPrimeRuntime"
        let replay =
            "PrimeNativeNeuralGateHistoricalReplayMechanics"
        let pureReplay =
            "PrimeNativeNeuralGateReplayMechanics"

        XCTAssertNoThrow(try historical.validate())
        XCTAssertNoThrow(try contract.validate())
        XCTAssertEqual(
            try historical.contentSHA256(),
            "5b5f6aae6c74d7b3cf8380093e6ebc1ba8b321f22e9476ac884c8b852ceacc90"
        )
        XCTAssertEqual(
            try contract.contentSHA256(),
            "b7990ee20d69660b29d12e0ba9014df2849da5747329c80cbe168644b6a170a5"
        )
        XCTAssertEqual(contract.schemaVersion, 10)
        XCTAssertEqual(
            contract.contractID,
            "prime_stage_b_source_bound_historical_replay_mechanics_topology_v10"
        )
        XCTAssertEqual(
            contract.targetGraph.count,
            historical.targetGraph.count
        )
        XCTAssertEqual(contract.status, .plannedNotMaterialized)
        XCTAssertFalse(contract.executionImplemented)
        XCTAssertFalse(contract.sourceBindingV7Issued)
        XCTAssertTrue(contract.historicalContractsPreserved)
        XCTAssertTrue(
            contract.historicalFutureTargetGraphSuperseded
        )
        XCTAssertEqual(
            contract.nextImplementationPrerequisite,
            "derive_and_source_bind_source_faithful_historical_fixture_then_materialize_only_the_sealed_historical_worker_without_materializing_probe_verifier_or_issuing_source_binding_v7"
        )

        let changed = zip(
            historical.targetGraph,
            contract.targetGraph
        ).filter {
            $0.0.materialization != $0.1.materialization
        }.map { $0.1.targetName }
        XCTAssertEqual(changed, [runtime, replay])
        XCTAssertEqual(
            try contract.target(named: runtime)
                .materialization,
            .implemented
        )
        XCTAssertEqual(
            try contract.target(named: runtime)
                .directLocalDependencyNames,
            []
        )
        XCTAssertEqual(
            try contract.transitiveLocalTargetNames(
                reachableFrom: runtime
            ),
            []
        )
        XCTAssertEqual(
            try contract.target(named: replay)
                .materialization,
            .implemented
        )
        XCTAssertEqual(
            try contract.target(named: replay)
                .directLocalDependencyNames,
            [runtime, pureReplay]
        )
        XCTAssertEqual(
            try contract.transitiveLocalTargetNames(
                reachableFrom: replay
            ),
            [runtime, pureReplay]
        )

        for target in contract.targetGraph
        where ![
            runtime,
            replay,
            contract.historicalContainmentRootTargetName,
        ].contains(target.targetName) {
            let rule = try XCTUnwrap(
                contract.forbiddenReachability.first {
                    $0.targetName == target.targetName
                }
            )
            XCTAssertTrue(
                rule.forbiddenReachableTargetNames
                    .contains(runtime),
                target.targetName
            )
            XCTAssertTrue(
                rule.forbiddenReachableTargetNames
                    .contains(replay),
                target.targetName
            )
        }
        let runtimeRule = try XCTUnwrap(
            contract.forbiddenReachability.first {
                $0.targetName == runtime
            }
        )
        XCTAssertEqual(
            Set(runtimeRule.forbiddenReachableTargetNames),
            Set(
                contract.targetGraph.map(\.targetName)
                    .filter { $0 != runtime }
            )
        )
        let replayRule = try XCTUnwrap(
            contract.forbiddenReachability.first {
                $0.targetName == replay
            }
        )
        XCTAssertEqual(
            Set(replayRule.forbiddenReachableTargetNames),
            Set(
                contract.targetGraph.map(\.targetName)
                    .filter {
                        ![replay, runtime, pureReplay]
                            .contains($0)
                    }
            )
        )
        XCTAssertTrue(
            contract.authorityStatement.contains(
                "forces the Prime admission disposition to ABSTAIN"
            )
        )
        XCTAssertTrue(
            contract.authorityStatement.contains(
                "package materialization is not execution evidence"
            )
        )
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
            #".target(name:"PrimeNativeNeuralGateReplayArtifactContracts")"#,
            #".target(name:"PrimeNativeNeuralGateTargetFreeScheduleDeliveryContracts",dependencies:["PrimeNativeNeuralGateReplayArtifactContracts","PrimeNativeNeuralGateReplayMechanics","PrimeNativeNeuralGateCorrectedMechanics",])"#,
            #".target(name:"PrimeNativeNeuralGateTargetFreeScheduleDeliveryAuthority",dependencies:["PrimeNativeNeuralGateReplayCaptureInventory","PrimeNativeNeuralGateReplaySourceComposition","PrimeNativeNeuralGateTargetFreeScheduleDeliveryContracts","PrimeNativeNeuralGateCorrectedProcessOwnershipContracts","PrimeNativeNeuralGateCorrectedEvaluationOwnershipContracts",])"#,
            #".target(name:"PrimeNativeNeuralGateCorrectedProcessOwnershipContracts",dependencies:["PrimeNativeNeuralGateReplayArtifactContracts","PrimeNativeNeuralGateTargetFreeScheduleDeliveryContracts",])"#,
            #".target(name:"PrimeNativeNeuralGateCorrectedEvaluationOwnershipContracts",dependencies:["PrimeNativeNeuralGateReplayArtifactContracts","PrimeNativeNeuralGateCorrectedProcessOwnershipContracts",])"#,
            #".target(name:"PrimeNativeNeuralGateTerminalReceiptOwnershipContracts",dependencies:["PrimeNativeNeuralGateReplayArtifactContracts","PrimeNativeNeuralGateCorrectedProcessOwnershipContracts","PrimeNativeNeuralGateCorrectedEvaluationOwnershipContracts",])"#,
            #".target(name:"PrimeNativeNeuralGateRoleArtifactReferenceContracts",dependencies:["PrimeNativeNeuralGateReplayArtifactContracts","PrimeNativeNeuralGateReplayMechanics","PrimeNativeNeuralGateTargetFreeScheduleDeliveryContracts","PrimeNativeNeuralGateCorrectedProcessOwnershipContracts","PrimeNativeNeuralGateCorrectedEvaluationOwnershipContracts","PrimeNativeNeuralGateTerminalReceiptOwnershipContracts",])"#,
            #".target(name:"PrimeNativeNeuralGateRoleArtifactReferenceAuthority",dependencies:["PrimeNativeNeuralGateRoleArtifactReferenceContracts","PrimeNativeNeuralGateTargetFreeScheduleDeliveryAuthority","PrimeNativeNeuralGateCorrectedProcessOwnershipContracts","PrimeNativeNeuralGateTargetFreeScheduleDeliveryContracts",])"#,
            #".target(name:"PrimeNativeNeuralGateReplayTransport",dependencies:["PrimeNativeNeuralGateReplayArtifactContracts","PrimeNativeNeuralGateReplayMechanics",])"#,
            #".target(name:"PrimeNativeNeuralGateReplayComposition",dependencies:["PrimeNativeNeuralGateReplayArtifactContracts","PrimeNativeNeuralGateReplayTransport","PrimeNativeNeuralGateReplayMechanics","PrimeNativeNeuralGateCorrectedMechanics","PrimeNativeNeuralGateLogitSidecarMechanics",])"#,
            #".target(name:"PrimeNativeNeuralGateReplaySourceBinding",dependencies:["PrimeCore","PrimeNativeNeuralGateReplayArtifactContracts","PrimeNativeNeuralGateReplayTransport","PrimeNativeNeuralGateReplayMechanics","PrimeNativeNeuralGateCorrectedMechanics","PrimeNativeNeuralGateLogitSidecarMechanics",])"#,
            #".target(name:"PrimeNativeNeuralGateReplaySourceComposition",dependencies:["PrimeNativeNeuralGateReplaySourceBinding","PrimeNativeNeuralGateReplayComposition","PrimeNativeNeuralGateTargetFreeScheduleDeliveryContracts",])"#,
            #".target(name:"PrimeNativeNeuralGateReplayCaptureInventory",dependencies:["PrimeCore","PrimeNativeNeuralGateReplayArtifactContracts","PrimeNativeNeuralGateReplaySourceBinding",])"#,
            #".target(name:"PrimeNativeNeuralGatePromptTargetCrosswalkAuthority",dependencies:["PrimeCore","PrimeNativeNeuralGateCorrectedFixtureAuthority","PrimeNativeNeuralGateCorrectedMechanics","PrimeNativeNeuralGateReplayCaptureInventory","PrimeNativeNeuralGateReplayComposition","PrimeNativeNeuralGateReplaySourceComposition","PrimeNativeNeuralGateReplayTransport",])"#,
            #".target(name:"PrimeNativeNeuralGateCorrectedMechanics",dependencies:["PrimeNativeNeuralGateReplayMechanics",])"#,
            #".target(name:"PrimeNativeNeuralGateCorrectedEvaluationMechanics",dependencies:["PrimeNativeNeuralGateReplayMechanics","PrimeNativeNeuralGateCorrectedMechanics",])"#,
            #".target(name:"PrimeNativeNeuralGateCorrectedFixtureAuthority",dependencies:["PrimeNativeCorpusReplayMechanics","PrimeNativeNeuralGateCorrectedMechanics","PrimeNativeNeuralGateCorrectedEvaluationMechanics",])"#,
            #".target(name:"PrimeNativeNeuralGatePromptSolver",dependencies:["PrimeNativeNeuralGateCorrectedMechanics",])"#,
            #".target(name:"PrimeNativeNeuralGateLogitSidecarMechanics",dependencies:["PrimeNativeNeuralGateCorrectedMechanics",])"#,
            #".target(name:"PrimeNativeNeuralGateCorrectedMutationSurfaceContracts",dependencies:["PrimeNativeNeuralGateReplayMechanics",])"#,
            #".target(name:"PrimeNativeNeuralGateCorrectedMutationRecordContracts",dependencies:["PrimeNativeNeuralGateReplayArtifactContracts","PrimeNativeNeuralGateReplayMechanics","PrimeNativeNeuralGateCorrectedMutationSurfaceContracts",])"#,
            #".target(name:"PrimeNativeNeuralGateSemanticRecordContracts",dependencies:["PrimeNativeNeuralGateReplayArtifactContracts","PrimeNativeNeuralGateReplayMechanics",])"#,
            #".target(name:"PrimeNativeNeuralGateCorrectedMutationProducer",dependencies:["PrimeNativeNeuralGateCorrectedMutationRecordContracts","PrimeNativeNeuralGateCorrectedMutationSurfaceContracts",])"#,
            #".target(name:"PrimeNativeNeuralGateCorrectedMutationDetector",dependencies:["PrimeNativeNeuralGateCorrectedMutationSurfaceContracts",])"#,
            #".target(name:"PrimeNativeNeuralGateHistoricalSourceDerivation",dependencies:["PrimeNativeNeuralGateReplayMechanics",],resources:[.copy("HistoricalEvidenceExportSource"),])"#,
            #".target(name:"ErgenticsPrimeRuntime")"#,
            #".target(name:"PrimeNativeNeuralGateHistoricalReplayMechanics",dependencies:["ErgenticsPrimeRuntime","PrimeNativeNeuralGateReplayMechanics",])"#,
            #".target(name:"PrimeNativeNeuralGateHistoricalEvidenceExportMechanics",dependencies:["ErgenticsPrimeRuntime","PrimeNativeNeuralGateReplayMechanics","PrimeNativeNeuralGateHistoricalReplayMechanics",])"#,
            #".target(name:"PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection",dependencies:["PrimeNativeNeuralGateHistoricalEvidenceExportMechanics","PrimeNativeNeuralGateReplayArtifactContracts","PrimeNativeNeuralGateReplayMechanics","PrimeNativeNeuralGateSemanticRecordContracts",])"#,
            #".executableTarget(name:"PrimeNativeNeuralGateHistoricalFixtureWorker",dependencies:["PrimeCore","ErgenticsPrimeRuntime","PrimeNativeNeuralGateHistoricalReplayMechanics","PrimeNativeNeuralGateReplayTransport","PrimeNativeNeuralGateHistoricalEvidenceExportMechanics","PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection","PrimeNativeNeuralGateHistoricalSemanticArtifactDecoder",],resources:[.copy("HistoricalFixtureEvidence"),])"#,
        ]
        for declaration in exactDeclarations {
            XCTAssertTrue(
                package.contains(declaration),
                declaration
            )
        }

        let productsStart = try XCTUnwrap(
            package.range(of: "products:[")
        ).upperBound
        let productsEnd = try XCTUnwrap(
            package.range(
                of: "],dependencies:[",
                range: productsStart..<package.endIndex
            )
        ).lowerBound
        let productDeclarations = package[
            productsStart..<productsEnd
        ]
        for packageInternalContractTarget in [
            "PrimeNativeNeuralGateTargetFreeScheduleDeliveryContracts",
            "PrimeNativeNeuralGateTargetFreeScheduleDeliveryAuthority",
            "PrimeNativeNeuralGateCorrectedProcessOwnershipContracts",
            "PrimeNativeNeuralGateCorrectedEvaluationOwnershipContracts",
            "PrimeNativeNeuralGateTerminalReceiptOwnershipContracts",
            "PrimeNativeNeuralGateRoleArtifactReferenceContracts",
            "PrimeNativeNeuralGateRoleArtifactReferenceAuthority",
            "PrimeNativeNeuralGateCorrectedMutationSurfaceContracts",
            "PrimeNativeNeuralGateCorrectedMutationRecordContracts",
            "PrimeNativeNeuralGateSemanticRecordContracts",
            "PrimeNativeNeuralGateCorrectedMutationProducer",
            "PrimeNativeNeuralGateCorrectedMutationDetector",
            "PrimeNativeNeuralGateHistoricalSourceDerivation",
            "ErgenticsPrimeRuntime",
            "PrimeNativeNeuralGateHistoricalReplayMechanics",
            "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics",
            "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection",
            "PrimeNativeNeuralGateHistoricalFixtureWorker",
        ] {
            XCTAssertFalse(
                productDeclarations.contains(
                    packageInternalContractTarget
                ),
                packageInternalContractTarget
            )
        }
        XCTAssertFalse(
            productDeclarations.contains(
                "PrimeNativeNeuralGateCorrectedProcessContracts"
            )
        )
        XCTAssertTrue(
            package.contains(
                #".target(name:"PrimeNativeNeuralGateMLXLogSoftmaxRecomputation",dependencies:["PrimeNativeNeuralGateLogitSidecarMechanics",.product(name:"MLX",package:"ergentics-mlx-swift"),.product(name:"MLXNN",package:"ergentics-mlx-swift"),])"#
            )
        )
        for internalLibraryTarget in [
            "PrimeNativeNeuralGateCorrectedMutationSurfaceContracts",
            "PrimeNativeNeuralGateCorrectedMutationRecordContracts",
            "PrimeNativeNeuralGateSemanticRecordContracts",
            "PrimeNativeNeuralGateCorrectedMutationProducer",
            "PrimeNativeNeuralGateCorrectedMutationDetector",
            "PrimeNativeNeuralGateHistoricalSourceDerivation",
            "ErgenticsPrimeRuntime",
            "PrimeNativeNeuralGateHistoricalReplayMechanics",
            "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics",
            "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection",
        ] {
            XCTAssertFalse(
                package.contains(
                    #".executableTarget(name:"\#(internalLibraryTarget)""#
                ),
                internalLibraryTarget
            )
        }

        XCTAssertEqual(
            try Contract.frozenV1.target(
                named:
                    "PrimeNativeNeuralGateReplayTransport"
            ).materialization,
            .plannedNotMaterialized
        )

        for target in Contract.frozenV15.targetGraph
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
        let targetFreeSource = try source(
            target:
                "PrimeNativeNeuralGateTargetFreeScheduleDeliveryContracts",
            file:
                "PrimeNativeNeuralGateTargetFreeScheduleDeliveryContracts.swift"
        )
        let targetFreeStreamSource = try source(
            target:
                "PrimeNativeNeuralGateTargetFreeScheduleDeliveryContracts",
            file:
                "PrimeNativeNeuralGateTargetFreeScheduleStreamDecoder.swift"
        )
        let allTargetFreeSource =
            targetFreeSource + "\n" + targetFreeStreamSource
        let deliveryAuthoritySource = try source(
            target:
                "PrimeNativeNeuralGateTargetFreeScheduleDeliveryAuthority",
            file:
                "PrimeNativeNeuralGateTargetFreeScheduleDeliveryAuthority.swift"
        )
        let referenceContractsSource = try source(
            target:
                "PrimeNativeNeuralGateRoleArtifactReferenceContracts",
            file:
                "PrimeNativeNeuralGateRoleArtifactReferenceContracts.swift"
        )
        let referenceAuthoritySource = try source(
            target:
                "PrimeNativeNeuralGateRoleArtifactReferenceAuthority",
            file:
                "PrimeNativeNeuralGateRoleArtifactReferenceAuthority.swift"
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
        for forbiddenImport in [
            "import PrimeCore",
            "import PrimeNativeNeuralGateReplayTransport",
            "import PrimeNativeNeuralGateReplayComposition",
            "import PrimeNativeNeuralGateReplaySourceBinding",
            "import PrimeNativeNeuralGateReplayCaptureInventory",
            "import PrimeNativeNeuralGateCorrectedEvaluationMechanics",
            "import PrimeNativeNeuralGateCorrectedFixtureAuthority",
            "import PrimeNativeNeuralGatePromptTargetCrosswalkAuthority",
        ] {
            XCTAssertFalse(
                allTargetFreeSource.contains(forbiddenImport),
                forbiddenImport
            )
        }
        for forbiddenSymbol in movedSymbols {
            XCTAssertFalse(
                allTargetFreeSource.contains(forbiddenSymbol),
                forbiddenSymbol
            )
        }
        XCTAssertFalse(
            allTargetFreeSource.contains(
                "PrimeNativeNeuralGateReplayOuterEvaluationRow"
            )
        )
        let compactTargetFree = compact(allTargetFreeSource)
        for forbiddenConformance in [
            "PrimeNativeNeuralGateTargetFreeRawScheduleCandidate:Codable",
            "PrimeNativeNeuralGateTargetFreeRawScheduleCandidate:Decodable",
            "PrimeNativeNeuralGateTargetFreeOuterScheduleCandidate:Codable",
            "PrimeNativeNeuralGateTargetFreeOuterScheduleCandidate:Decodable",
            "PrimeNativeNeuralGateTargetFreeScheduleCandidatePair:Codable",
            "PrimeNativeNeuralGateTargetFreeScheduleCandidatePair:Decodable",
            "PrimeNativeNeuralGateTargetFreeSchedulePairStreamHeader:Codable",
            "PrimeNativeNeuralGateTargetFreeSchedulePairStreamHeader:Decodable",
            "PrimeNativeNeuralGateTargetFreeSchedulePairStreamAdmission:Codable",
            "PrimeNativeNeuralGateTargetFreeSchedulePairStreamAdmission:Decodable",
        ] {
            XCTAssertFalse(
                compactTargetFree.contains(
                    forbiddenConformance
                ),
                forbiddenConformance
            )
        }
        XCTAssertTrue(
            compactTargetFree.contains(
                "privatestructPairStreamHeaderWire:Decodable"
            )
        )
        XCTAssertTrue(
            compactTargetFree.contains(
                "PrimeNativeNeuralGateTargetFreeSchedulePairStreamAdmission:Equatable,Sendable"
            )
        )
        let compactAuthority = compact(
            deliveryAuthoritySource
        )
        XCTAssertTrue(
            compactAuthority.contains(
                "PrimeNativeNeuralGateCaptureBoundTargetFreeScheduleDelivery:@uncheckedSendable"
            )
        )
        XCTAssertFalse(
            compactAuthority.contains(
                "PrimeNativeNeuralGateCaptureBoundTargetFreeScheduleDelivery:Codable"
            )
        )
        XCTAssertFalse(
            compactAuthority.contains(
                "PrimeNativeNeuralGateCaptureBoundTargetFreeScheduleDelivery:Decodable"
            )
        )
        XCTAssertTrue(
            compactAuthority.contains("fileprivateinit(")
        )

        for forbiddenImport in [
            "import PrimeCore",
            "import PrimeNativeCorpusReplayMechanics",
            "import PrimeNativeNeuralGateReplayTransport",
            "import PrimeNativeNeuralGateReplayComposition",
            "import PrimeNativeNeuralGateReplaySourceBinding",
            "import PrimeNativeNeuralGateReplaySourceComposition",
            "import PrimeNativeNeuralGateReplayCaptureInventory",
            "import PrimeNativeNeuralGatePromptTargetCrosswalkAuthority",
            "import PrimeNativeNeuralGateCorrectedEvaluationMechanics",
            "import PrimeNativeNeuralGateCorrectedFixtureAuthority",
            "import PrimeNativeNeuralGateMLXLogSoftmaxRecomputation",
            "import ErgenticsPrimeRuntime",
        ] {
            XCTAssertFalse(
                referenceContractsSource.contains(forbiddenImport),
                forbiddenImport
            )
        }
        for forbiddenImport in [
            "import PrimeNativeCorpusReplayMechanics",
            "import PrimeNativeNeuralGatePromptTargetCrosswalkAuthority",
            "import PrimeNativeNeuralGateCorrectedEvaluationMechanics",
            "import PrimeNativeNeuralGateCorrectedFixtureAuthority",
            "import PrimeNativeNeuralGateMLXLogSoftmaxRecomputation",
            "import ErgenticsPrimeRuntime",
        ] {
            XCTAssertFalse(
                referenceAuthoritySource.contains(forbiddenImport),
                forbiddenImport
            )
        }
        let compactReferences = compact(referenceContractsSource)
        for forbiddenConformance in [
            "PrimeNativeNeuralGateCommonCaptureScheduleReference:Codable",
            "PrimeNativeNeuralGateCommonCaptureScheduleReference:Decodable",
            "PrimeNativeNeuralGateBranchScheduleReference:Codable",
            "PrimeNativeNeuralGateBranchScheduleReference:Decodable",
            "PrimeNativeNeuralGateWorkerSourceReference:Codable",
            "PrimeNativeNeuralGateWorkerSourceReference:Decodable",
            "PrimeNativeNeuralGateRoleArtifactContentReference:Codable",
            "PrimeNativeNeuralGateRoleArtifactContentReference:Decodable",
            "PrimeNativeNeuralGateRoleArtifactReferenceContract:Codable",
            "PrimeNativeNeuralGateRoleArtifactReferenceContract:Decodable",
        ] {
            XCTAssertFalse(
                compactReferences.contains(forbiddenConformance),
                forbiddenConformance
            )
        }
        let compactReferenceAuthority = compact(referenceAuthoritySource)
        for forbiddenConformance in [
            "PrimeNativeNeuralGateCaptureBoundRoleArtifactReferenceBundle:Codable",
            "PrimeNativeNeuralGateCaptureBoundRoleArtifactReferenceBundle:Decodable",
            "PrimeNativeNeuralGateCaptureBoundScheduleStreamAdmission:Codable",
            "PrimeNativeNeuralGateCaptureBoundScheduleStreamAdmission:Decodable",
            "PrimeNativeNeuralGateCaptureBoundScheduleStreamDecoder:Codable",
            "PrimeNativeNeuralGateCaptureBoundScheduleStreamDecoder:Decodable",
        ] {
            XCTAssertFalse(
                compactReferenceAuthority.contains(forbiddenConformance),
                forbiddenConformance
            )
        }
        XCTAssertTrue(
            compactReferenceAuthority.contains(
                "PrimeNativeNeuralGateCaptureBoundRoleArtifactReferenceBundle:@uncheckedSendable"
            )
        )
        XCTAssertTrue(
            compactReferenceAuthority.contains(
                "PrimeNativeNeuralGateCaptureBoundScheduleStreamAdmission:@uncheckedSendable"
            )
        )
        XCTAssertTrue(
            compactReferenceAuthority.contains("fileprivateinit(")
        )
        let streamFactoryStart = try XCTUnwrap(
            compactReferenceAuthority.range(
                of: "publicstaticfuncmakeCaptureBoundStreamDecoder("
            )
        ).lowerBound
        let streamFactorySource = compactReferenceAuthority[
            streamFactoryStart...
        ]
        let cheapHeaderGate = try XCTUnwrap(
            streamFactorySource.range(
                of: "decodeUntrustedHeaderBeforeRetainedBinding(headerJSON)"
            )
        ).lowerBound
        let retainedBind = try XCTUnwrap(
            streamFactorySource.range(
                of: "letreferenceBundle=trybind("
            )
        ).lowerBound
        XCTAssertLessThan(cheapHeaderGate, retainedBind)
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
