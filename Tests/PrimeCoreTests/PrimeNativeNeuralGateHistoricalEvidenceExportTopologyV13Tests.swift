import Foundation
@testable import PrimeCore
import XCTest

final class
    PrimeNativeNeuralGateHistoricalEvidenceExportTopologyV13Tests:
    XCTestCase
{
    private typealias Contract =
        PrimeNativeNeuralGateTrapDisjointTopologyContract
    private typealias SourceContract =
        PrimeNativeNeuralGateHistoricalEvidenceExportSourceContract

    private let exporterTargetName =
        "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics"
    private let sourceContractID =
        "prime_source_bound_historical_evidence_export_source_v13"
    private let sourceContractSHA256 =
        "ecc329a7e56d843b53f9d894af4e335c9d00ac05d56efe308d61860835278d5e"

    func testFrozenV13BindsExactSourceAndAuthorityCeiling()
        throws
    {
        let contract = Contract.frozenV13
        let source = SourceContract.frozenV1

        XCTAssertNoThrow(try contract.validate())
        XCTAssertNoThrow(try source.validate())
        XCTAssertEqual(contract.schemaVersion, 13)
        XCTAssertEqual(
            contract.contractID,
            "prime_stage_b_source_bound_historical_evidence_export_source_topology_v13"
        )
        XCTAssertEqual(
            contract.historicalEvidenceExportSourceContractID,
            sourceContractID
        )
        XCTAssertEqual(source.contractID, sourceContractID)
        XCTAssertEqual(
            contract
                .historicalEvidenceExportSourceContractSHA256,
            sourceContractSHA256
        )
        XCTAssertEqual(
            try source.contentSHA256(),
            sourceContractSHA256
        )
        XCTAssertEqual(
            contract.historicalEvidenceExportTargetName,
            exporterTargetName
        )
        XCTAssertEqual(
            contract.status,
            .plannedNotMaterialized
        )
        XCTAssertFalse(contract.executionImplemented)
        XCTAssertFalse(contract.sourceBindingV7Issued)
        XCTAssertFalse(
            contract
                .mutationProducerDetectorTargetAssignmentDeferred
        )
        XCTAssertTrue(
            contract.mutationProducerDetectorMustBeDisjoint
        )
        XCTAssertTrue(
            contract.packageCaptureAuthority.contains(
                sourceContractSHA256
            )
        )
        XCTAssertTrue(
            contract.packageCaptureAuthority.contains(
                "not_exporter_or_worker_execution"
            )
        )
        XCTAssertTrue(
            contract.authorityStatement.contains(
                "No exporter, worker, fixture, mutation, gate, model, process, or Metal workload executes"
            )
        )
        XCTAssertTrue(
            contract.authorityStatement.contains(
                "source or execution binding V7"
            )
        )
    }

    func testV13AddsOnlyTheExactImplementedExporterClosure()
        throws
    {
        let previous = Contract.frozenV12
        let contract = Contract.frozenV13
        let exactDependencies = [
            contract.historicalRuntimeTargetName,
            contract.pureReplayTargetName,
            contract.historicalReplayTargetName,
        ]

        XCTAssertEqual(
            contract.targetGraph.count,
            previous.targetGraph.count + 1
        )
        XCTAssertEqual(
            Array(contract.targetGraph.dropLast()),
            previous.targetGraph
        )
        let exporter = try contract.target(
            named: exporterTargetName
        )
        XCTAssertEqual(exporter.targetName, exporterTargetName)
        XCTAssertEqual(exporter.materialization, .implemented)
        XCTAssertEqual(
            exporter.directLocalDependencyNames,
            exactDependencies
        )
        XCTAssertTrue(
            exporter.externalProductDependencyNames.isEmpty
        )
        XCTAssertTrue(
            exporter.authority.contains(
                "package-internal library"
            )
        )
        XCTAssertEqual(
            Set(
                try contract.transitiveLocalTargetNames(
                    reachableFrom: exporterTargetName
                )
            ),
            Set(exactDependencies)
        )
    }

    func testEveryPriorTargetForbidsAndCannotReachExporter()
        throws
    {
        let previous = Contract.frozenV12
        let contract = Contract.frozenV13

        for target in previous.targetGraph {
            let rule = try XCTUnwrap(
                contract.forbiddenReachability.first {
                    $0.targetName == target.targetName
                },
                target.targetName
            )
            XCTAssertTrue(
                rule.forbiddenReachableTargetNames.contains(
                    exporterTargetName
                ),
                target.targetName
            )
            XCTAssertFalse(
                try contract.transitiveLocalTargetNames(
                    reachableFrom: target.targetName
                ).contains(exporterTargetName),
                target.targetName
            )
        }
    }

    func testExporterForbidsEverythingOutsideExactHistoricalClosure()
        throws
    {
        let previous = Contract.frozenV12
        let contract = Contract.frozenV13
        let allowed = Set([
            contract.historicalRuntimeTargetName,
            contract.pureReplayTargetName,
            contract.historicalReplayTargetName,
        ])
        let exporterRule = try XCTUnwrap(
            contract.forbiddenReachability.first {
                $0.targetName == exporterTargetName
            }
        )
        let expectedForbidden = Set(
            previous.targetGraph.map(\.targetName).filter {
                !allowed.contains($0)
            }
        )

        XCTAssertEqual(
            Set(exporterRule.forbiddenReachableTargetNames),
            expectedForbidden
        )
        XCTAssertEqual(
            Set(
                try contract.transitiveLocalTargetNames(
                    reachableFrom: exporterTargetName
                )
            ),
            allowed
        )
        XCTAssertTrue(
            allowed.isDisjoint(with: expectedForbidden)
        )
    }

    func testHistoricalWorkerTargetAndReachabilityRemainUnchanged()
        throws
    {
        let previous = Contract.frozenV12
        let contract = Contract.frozenV13
        let worker =
            contract.historicalContainmentRootTargetName

        XCTAssertEqual(
            worker,
            previous.historicalContainmentRootTargetName
        )
        XCTAssertEqual(
            try contract.target(named: worker),
            try previous.target(named: worker)
        )
        XCTAssertEqual(
            try contract.target(named: worker)
                .directLocalDependencyNames,
            [
                "PrimeCore",
                "ErgenticsPrimeRuntime",
                "PrimeNativeNeuralGateHistoricalReplayMechanics",
                "PrimeNativeNeuralGateReplayTransport",
            ]
        )
        XCTAssertFalse(
            try contract.transitiveLocalTargetNames(
                reachableFrom: worker
            ).contains(exporterTargetName)
        )
        let workerRule = try XCTUnwrap(
            contract.forbiddenReachability.first {
                $0.targetName == worker
            }
        )
        XCTAssertTrue(
            workerRule.forbiddenReachableTargetNames.contains(
                exporterTargetName
            )
        )
        XCTAssertTrue(
            contract.authorityStatement.contains(
                "worker source, dependencies, call graph, unavailable main, and copied resource remain unchanged"
            )
        )
    }

    func testV11AndV12CanonicalIdentitiesRemainExact()
        throws
    {
        XCTAssertNoThrow(try Contract.frozenV11.validate())
        XCTAssertNoThrow(try Contract.frozenV12.validate())
        XCTAssertEqual(
            try Contract.frozenV11.contentSHA256(),
            "06ce2af33e574c04ef4a46ca356402457ddd4e045bce6d100fed796c19c909eb"
        )
        XCTAssertEqual(
            try Contract.frozenV12.contentSHA256(),
            "335e6d54a94305ee2976c9433d0b5570cdd0f67ca8fea0fa00c8dd9f12eaebbe"
        )
        XCTAssertNil(
            Contract.frozenV12
                .historicalEvidenceExportSourceContractID
        )
        XCTAssertNil(
            Contract.frozenV12
                .historicalEvidenceExportSourceContractSHA256
        )
        XCTAssertNil(
            Contract.frozenV12
                .historicalEvidenceExportTargetName
        )
    }

    func testV13CodableRoundTripIsExact() throws {
        let contract = Contract.frozenV13
        let data = try PrimeCanonicalJSON.encode(contract)
        let decoded = try PrimeCanonicalJSON.decode(
            Contract.self,
            from: data
        )

        XCTAssertEqual(decoded, contract)
        XCTAssertNoThrow(try decoded.validate())
        XCTAssertEqual(
            try PrimeCanonicalJSON.encode(decoded),
            data
        )
    }

    func testV13SourceBindingMutationsFailClosed() throws {
        let data = try PrimeCanonicalJSON.encode(
            Contract.frozenV13
        )
        let canonicalObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: data)
                as? [String: Any]
        )
        let sourceBindingKey =
            "historical_evidence_export_source_contract_binding"
        let targetNameKey =
            "historical_evidence_export_target_name"
        let sourceBinding = try XCTUnwrap(
            canonicalObject[sourceBindingKey]
                as? [String: Any]
        )
        var mutations: [[String: Any]] = []

        do {
            var object = canonicalObject
            object.removeValue(forKey: sourceBindingKey)
            mutations.append(object)
        }
        do {
            var object = canonicalObject
            var binding = sourceBinding
            binding["contract_id"] = sourceContractID + "_drift"
            object[sourceBindingKey] = binding
            mutations.append(object)
        }
        do {
            var object = canonicalObject
            var binding = sourceBinding
            binding["content_sha256"] =
                String(repeating: "0", count: 64)
            object[sourceBindingKey] = binding
            mutations.append(object)
        }
        do {
            var object = canonicalObject
            object.removeValue(forKey: targetNameKey)
            mutations.append(object)
        }
        do {
            var object = canonicalObject
            object[targetNameKey] = exporterTargetName + "Drift"
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
                "source-binding mutation \(index)"
            )
        }
    }

    func testTopologyV13CanonicalHashIsExact() throws {
        XCTAssertEqual(
            try Contract.frozenV13.contentSHA256(),
            "b1564c277a50b8bc2b2ba325809130920dcb123f0d02297efba73e3bb3aec4ea"
        )
    }
}
