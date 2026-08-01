import Foundation
@testable import PrimeCore
import XCTest

final class
    PrimeNativeNeuralGateHistoricalWorkerEvidenceExportCallEdgeTopologyV14Tests:
    XCTestCase
{
    private typealias Contract =
        PrimeNativeNeuralGateTrapDisjointTopologyContract
    private typealias SourceContract =
        PrimeNativeNeuralGateHistoricalWorkerEvidenceExportCallEdgeSourceContract

    private let workerTargetName =
        "PrimeNativeNeuralGateHistoricalFixtureWorker"
    private let exporterTargetName =
        "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics"
    private let sourceContractID =
        "prime_source_bound_historical_worker_evidence_export_call_edge_v14"
    private let sourceContractSHA256 =
        "8112cf3e6190fcd6385614322be11f391bccc1ca411b6af85c7bd8cf57c4a4e8"

    func testFrozenV14BindsExactSourceAndAuthorityCeiling()
        throws
    {
        let contract = Contract.frozenV14
        let source = SourceContract.frozenV1

        XCTAssertNoThrow(try source.validate())
        XCTAssertNoThrow(try contract.validate())
        XCTAssertEqual(contract.schemaVersion, 14)
        XCTAssertEqual(
            contract.contractID,
            "prime_stage_b_historical_worker_evidence_export_call_edge_source_topology_v14"
        )
        XCTAssertEqual(
            contract
                .historicalWorkerEvidenceExportCallEdgeSourceContractID,
            sourceContractID
        )
        XCTAssertEqual(source.contractID, sourceContractID)
        XCTAssertEqual(
            contract
                .historicalWorkerEvidenceExportCallEdgeSourceContractSHA256,
            sourceContractSHA256
        )
        XCTAssertEqual(
            try source.contentSHA256(),
            sourceContractSHA256
        )
        XCTAssertEqual(contract.status, .plannedNotMaterialized)
        XCTAssertFalse(contract.executionImplemented)
        XCTAssertFalse(contract.sourceBindingV7Issued)
        XCTAssertFalse(source.workerRequestHandlingEnabled)
        XCTAssertFalse(source.workerSealed)
        XCTAssertFalse(source.workerLaunched)
        XCTAssertFalse(source.workerExecuted)
        XCTAssertFalse(source.fixtureMaterialized)
        XCTAssertFalse(source.exporterInvoked)
        XCTAssertFalse(source.modelExecutionObserved)
        XCTAssertFalse(source.historicalGateExecuted)
        XCTAssertFalse(source.historicalEvidenceObserved)
        XCTAssertFalse(source.evidenceEncodedOrPublished)
        XCTAssertFalse(source.durablePublicationObserved)
        XCTAssertFalse(source.independentDetectionEstablished)
        XCTAssertFalse(
            source.distinctImplementationFamiliesEstablished
        )
        XCTAssertFalse(
            source.agentContractKitFourTierAuditPerformed
        )
        XCTAssertFalse(source.mechanicsPassAuthorized)
        XCTAssertFalse(source.terminalReceiptAuthorized)
        XCTAssertFalse(source.sourceBindingV7Issued)
        XCTAssertFalse(source.scientificAuthorityAuthorized)
        XCTAssertFalse(source.productAuthorityAuthorized)
        XCTAssertTrue(
            contract.packageCaptureAuthority.contains(
                sourceContractSHA256
            )
        )
        XCTAssertTrue(
            contract.authorityStatement.contains(
                "Compilation proves only the typed call edge"
            )
        )
        XCTAssertTrue(
            contract.authorityStatement.contains(
                "No request handling, sealing, launch"
            )
        )
    }

    func testV14ChangesOnlyWorkerTargetAndAppendsExporter()
        throws
    {
        let previous = Contract.frozenV13
        let contract = Contract.frozenV14
        let previousWorker = try previous.target(
            named: workerTargetName
        )
        let worker = try contract.target(
            named: workerTargetName
        )

        XCTAssertEqual(
            contract.targetGraph.count,
            previous.targetGraph.count
        )
        XCTAssertEqual(worker.materialization, .implemented)
        XCTAssertEqual(
            worker.directLocalDependencyNames,
            [
                "PrimeCore",
                "ErgenticsPrimeRuntime",
                "PrimeNativeNeuralGateHistoricalReplayMechanics",
                "PrimeNativeNeuralGateReplayTransport",
                exporterTargetName,
            ]
        )
        XCTAssertEqual(
            Array(worker.directLocalDependencyNames.dropLast()),
            previousWorker.directLocalDependencyNames
        )
        XCTAssertEqual(
            worker.externalProductDependencyNames,
            previousWorker.externalProductDependencyNames
        )
        XCTAssertNotEqual(worker.authority, previousWorker.authority)

        for target in previous.targetGraph
        where target.targetName != workerTargetName {
            XCTAssertEqual(
                try contract.target(named: target.targetName),
                target,
                target.targetName
            )
        }
    }

    func testV14ChangesOnlyWorkerExporterReachabilityRule()
        throws
    {
        let previous = Contract.frozenV13
        let contract = Contract.frozenV14

        XCTAssertEqual(
            contract.forbiddenReachability.count,
            previous.forbiddenReachability.count
        )
        for previousRule in previous.forbiddenReachability {
            let rule = try XCTUnwrap(
                contract.forbiddenReachability.first {
                    $0.targetName == previousRule.targetName
                },
                previousRule.targetName
            )
            if previousRule.targetName == workerTargetName {
                XCTAssertTrue(
                    previousRule.forbiddenReachableTargetNames
                        .contains(exporterTargetName)
                )
                XCTAssertEqual(
                    rule.forbiddenReachableTargetNames,
                    previousRule.forbiddenReachableTargetNames
                        .filter { $0 != exporterTargetName }
                )
            } else {
                XCTAssertEqual(rule, previousRule)
            }
        }

        let exporterRule = try XCTUnwrap(
            contract.forbiddenReachability.first {
                $0.targetName == exporterTargetName
            }
        )
        XCTAssertTrue(
            exporterRule.forbiddenReachableTargetNames.contains(
                workerTargetName
            )
        )
    }

    func testWorkerAndExporterClosuresAreExactAndAcyclic()
        throws
    {
        let contract = Contract.frozenV14

        XCTAssertEqual(
            try contract.transitiveLocalTargetNames(
                reachableFrom: workerTargetName
            ),
            [
                "ErgenticsPrimeRuntime",
                "PrimeCore",
                exporterTargetName,
                "PrimeNativeNeuralGateHistoricalReplayMechanics",
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplayMechanics",
                "PrimeNativeNeuralGateReplayTransport",
            ]
        )
        let exporterClosure = try contract
            .transitiveLocalTargetNames(
                reachableFrom: exporterTargetName
            )
        XCTAssertEqual(
            exporterClosure,
            [
                "ErgenticsPrimeRuntime",
                "PrimeNativeNeuralGateHistoricalReplayMechanics",
                "PrimeNativeNeuralGateReplayMechanics",
            ]
        )
        XCTAssertFalse(exporterClosure.contains(workerTargetName))
    }

    func testPriorCanonicalIdentitiesRemainExact() throws {
        let expected: [(Contract, String)] = [
            (
                .frozenV10,
                "b7990ee20d69660b29d12e0ba9014df2849da5747329c80cbe168644b6a170a5"
            ),
            (
                .frozenV11,
                "06ce2af33e574c04ef4a46ca356402457ddd4e045bce6d100fed796c19c909eb"
            ),
            (
                .frozenV12,
                "335e6d54a94305ee2976c9433d0b5570cdd0f67ca8fea0fa00c8dd9f12eaebbe"
            ),
            (
                .frozenV13,
                "b1564c277a50b8bc2b2ba325809130920dcb123f0d02297efba73e3bb3aec4ea"
            ),
        ]

        for (contract, sha256) in expected {
            XCTAssertNoThrow(try contract.validate())
            XCTAssertEqual(try contract.contentSHA256(), sha256)
            XCTAssertNil(
                contract
                    .historicalWorkerEvidenceExportCallEdgeSourceContractID
            )
            XCTAssertNil(
                contract
                    .historicalWorkerEvidenceExportCallEdgeSourceContractSHA256
            )
        }
    }

    func testV14CodableRoundTripIsExact() throws {
        let contract = Contract.frozenV14
        let data = try PrimeCanonicalJSON.encode(contract)
        let decoded = try PrimeCanonicalJSON.decode(
            Contract.self,
            from: data
        )

        XCTAssertEqual(decoded, contract)
        XCTAssertNoThrow(try decoded.validate())
        XCTAssertEqual(try PrimeCanonicalJSON.encode(decoded), data)
    }

    func testV14BindingAndGraphMutationsFailClosed() throws {
        let data = try PrimeCanonicalJSON.encode(
            Contract.frozenV14
        )
        let canonicalObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: data)
                as? [String: Any]
        )
        let bindingKey =
            "historical_worker_evidence_export_call_edge_source_contract_binding"
        let binding = try XCTUnwrap(
            canonicalObject[bindingKey] as? [String: Any]
        )
        let targetGraph = try XCTUnwrap(
            canonicalObject["target_graph"] as? [[String: Any]]
        )
        var mutations: [[String: Any]] = []

        do {
            var object = canonicalObject
            object.removeValue(forKey: bindingKey)
            mutations.append(object)
        }
        do {
            var object = canonicalObject
            var drift = binding
            drift["contract_id"] = sourceContractID + "_drift"
            object[bindingKey] = drift
            mutations.append(object)
        }
        do {
            var object = canonicalObject
            var drift = binding
            drift["content_sha256"] =
                String(repeating: "f", count: 64)
            object[bindingKey] = drift
            mutations.append(object)
        }
        do {
            var object = canonicalObject
            var graph = targetGraph
            let workerIndex = try XCTUnwrap(
                graph.firstIndex {
                    $0["target_name"] as? String
                        == workerTargetName
                }
            )
            var worker = graph[workerIndex]
            worker["direct_local_dependency_names"] = [
                "PrimeCore",
            ]
            graph[workerIndex] = worker
            object["target_graph"] = graph
            mutations.append(object)
        }

        for (index, object) in mutations.enumerated() {
            let decoded = try JSONDecoder().decode(
                Contract.self,
                from: JSONSerialization.data(
                    withJSONObject: object,
                    options: [.sortedKeys]
                )
            )
            XCTAssertThrowsError(
                try decoded.validate(),
                "V14 mutation \(index)"
            )
        }
    }

    func testV14CanonicalHashIsExact() throws {
        XCTAssertEqual(
            try Contract.frozenV14.contentSHA256(),
            "4aee5e011a7db85ed74955684f885b03f306e82b8fd4d0f12422d0b791663564"
        )
    }
}
