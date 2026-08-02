// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
@testable import PrimeCore
import XCTest

final class
    PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactProjectionCallEdgeSourceTopologyV17Tests:
    XCTestCase
{
    private typealias Source =
        PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactProjectionCallEdgeSourceContract
    private typealias Topology =
        PrimeNativeNeuralGateTrapDisjointTopologyContract
    private static let sourceContractSHA256 =
        "ccf2e46ffc9e980d96357980e128ecb411a5ac5f55b8e783bf611582ec32d6d3"
    private static let topologyV17SHA256 =
        "3a14288df628b1d44936013af44dd237e876fd1cf2b38e4ce0afd3a4c5cd2166"
    private static let workerTargetName =
        "PrimeNativeNeuralGateHistoricalFixtureWorker"
    private static let projectorTargetName =
        "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection"
    private static let semanticTargetName =
        "PrimeNativeNeuralGateSemanticRecordContracts"

    func testFrozenV17SourceContractBindsExactNonExecutingBoundary()
        throws
    {
        let source = Source.frozenV1

        XCTAssertNoThrow(try source.validate())
        XCTAssertEqual(source.schemaVersion, 1)
        XCTAssertEqual(
            source.contractID,
            "prime_source_bound_historical_worker_semantic_artifact_projection_call_edge_v17"
        )
        XCTAssertEqual(source.rightsHolder, "Ergentics, LLC")
        XCTAssertEqual(
            source.licenseExpression,
            "LicenseRef-Ergentics-Proprietary"
        )
        XCTAssertEqual(
            source.preservedWorkerExporterCallEdgeV14ContractSHA256,
            "8112cf3e6190fcd6385614322be11f391bccc1ca411b6af85c7bd8cf57c4a4e8"
        )
        XCTAssertEqual(
            source.preservedProjectionSourceV16ContractSHA256,
            "2b9c1565f103622eb82e53e4a83820b98d6dd0d3dfd5487353dde06c5a4fd4dd"
        )
        XCTAssertEqual(
            source.preservedTopologyV16SHA256,
            "7e9dafad211bb0fb450ff9054be71a0022f5a259b4021d90123eb4736df747d3"
        )
        XCTAssertEqual(source.exactWorkerSwiftSourceFileCount, 3)
        XCTAssertTrue(source.completeWorkerSourceInventoryBound)
        XCTAssertEqual(
            source.preservedWorkerDirectLocalDependencyNames.count,
            5
        )
        XCTAssertEqual(source.workerDirectLocalDependencyNames.count, 6)
        XCTAssertEqual(source.exactAddedWorkerDependencyCount, 1)
        XCTAssertTrue(source.preservedDependenciesRemainExactPrefix)
        XCTAssertTrue(source.callEdgeAcceptsAlreadyFormedEvidence)
        XCTAssertFalse(source.callEdgeConstructsOrInfersContext)
        XCTAssertFalse(
            source
                .adapterAddsDefaultingReductionOrderingOrSerializationBeyondProjector
        )
        XCTAssertTrue(
            source.delegatedProjectorTransformsCarrierIntoArtifactSet
        )
        XCTAssertFalse(
            source
                .callEdgeContainsFixtureMaterializationOrExporterInvocation
        )
        XCTAssertFalse(source.callEdgeContainsProcessTransportOrIO)
        XCTAssertTrue(source.workerTargetMayReachProjectionTarget)
        XCTAssertTrue(
            source.semanticRecordTargetNewlyReachableThroughProjection
        )
        XCTAssertFalse(source.projectionTargetMayReachWorkerTarget)
        XCTAssertFalse(source.mainCanNameOrReachProjectionCallEdge)
        XCTAssertFalse(
            source
                .preservedExporterCallEdgeCanNameOrReachProjectionCallEdge
        )
        XCTAssertTrue(source.mainRemainsUnconditionalUnavailableExit)
        XCTAssertEqual(source.unavailableExitStatus, 78)
        XCTAssertTrue(source.callEdgeCompilerBound)
        XCTAssertFalse(source.callEdgeRuntimeExercised)
        XCTAssertFalse(source.replayTransportIntegratedWithProjection)
        XCTAssertFalse(source.workerDeclaredAsProduct)
        XCTAssertFalse(source.testsImportWorker)
        XCTAssertFalse(source.testsInvokeProjectionEntryPoint)
        for falseClaim in [
            source.workerRequestHandlingEnabled,
            source.workerSealed,
            source.workerLaunched,
            source.workerExecuted,
            source.fixtureMaterialized,
            source.exporterInvoked,
            source.workerCallEdgeOrPublicProjectionEntryPointInvoked,
            source
                .workerCallEdgeOrPublicProjectionEntryPointArtifactsConstructed,
            source.historicalGateExecuted,
            source.modelExecutionObserved,
            source.historicalEvidenceObserved,
            source.artifactWritePerformed,
            source.evidencePublished,
            source.durablePublicationObserved,
            source.independentDetectionEstablished,
            source.distinctImplementationFamiliesEstablished,
            source.agentContractKitFourTierAuditPerformed,
            source.mechanicsPassAuthorized,
            source.terminalReceiptAuthorized,
            source.sourceBindingV7Issued,
            source.scientificAuthorityAuthorized,
            source.productAuthorityAuthorized,
        ] {
            XCTAssertFalse(falseClaim)
        }
    }

    func testFrozenSourceCanonicalRoundTripAndCurrentHash()
        throws
    {
        let source = Source.frozenV1
        let canonical = try PrimeCanonicalJSON.encode(source)
        let decoded = try PrimeCanonicalJSON.decode(
            Source.self,
            from: canonical
        )

        XCTAssertEqual(decoded, source)
        XCTAssertNoThrow(try decoded.validate())
        XCTAssertEqual(
            try PrimeCanonicalJSON.encode(decoded),
            canonical
        )
        let observed = try source.contentSHA256()
        XCTAssertEqual(observed.utf8.count, 64)
        XCTAssertEqual(observed, Self.sourceContractSHA256)
        XCTAssertEqual(
            observed,
            PrimeSHA256.hexDigest(of: canonical)
        )
    }

    func testAllPinnedV17FilesMatchTheLiveRepository()
        throws
    {
        let source = Source.frozenV1
        for identity in [
            source.primaryWorkerSource,
            source.preservedExporterCallEdgeSource,
            source.projectionCallEdgeSource,
            source.fixtureResource,
        ] + source.preservedProjectionOrderedSourceFiles {
            let data = try Data(
                contentsOf:
                    repositoryRoot.appendingPathComponent(
                        identity.primeRelativePath
                    )
            )
            XCTAssertEqual(
                UInt64(data.count),
                identity.byteCount,
                identity.primeRelativePath
            )
            XCTAssertEqual(
                PrimeSHA256.hexDigest(of: data),
                identity.sha256,
                identity.primeRelativePath
            )
        }
        XCTAssertEqual(
            source.focusedSourceGuardTest.primeRelativePath,
            "Tests/PrimeCoreTests/PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactProjectionCallEdgeSourceTests.swift"
        )
        XCTAssertEqual(source.focusedSourceGuardTest.byteCount, 12_467)
        XCTAssertEqual(
            source.focusedSourceGuardTest.sha256,
            "ff03b3a143ebc748dadf6d9a337d68753add478811395d78d27e5654c805a8f4"
        )
    }

    func testFrozenV17TopologyChangesOnlyTheWorkerEdge()
        throws
    {
        let previous = Topology.frozenV16
        let topology = Topology.frozenV17
        let source = Source.frozenV1

        XCTAssertNoThrow(try topology.validate())
        XCTAssertEqual(topology.schemaVersion, 17)
        XCTAssertEqual(
            topology.contractID,
            "prime_stage_b_historical_worker_semantic_artifact_projection_call_edge_source_topology_v17"
        )
        XCTAssertEqual(
            topology
                .historicalWorkerSemanticArtifactProjectionCallEdgeSourceContractID,
            source.contractID
        )
        XCTAssertEqual(
            topology
                .historicalWorkerSemanticArtifactProjectionCallEdgeSourceContractSHA256,
            try source.contentSHA256()
        )
        XCTAssertEqual(topology.targetGraph.count, previous.targetGraph.count)

        let previousByName = Dictionary(
            uniqueKeysWithValues:
                previous.targetGraph.map { ($0.targetName, $0) }
        )
        let topologyByName = Dictionary(
            uniqueKeysWithValues:
                topology.targetGraph.map { ($0.targetName, $0) }
        )
        XCTAssertEqual(
            Set(previousByName.keys),
            Set(topologyByName.keys)
        )
        for (name, previousTarget) in previousByName {
            let target = try XCTUnwrap(topologyByName[name], name)
            if name == Self.workerTargetName {
                XCTAssertEqual(
                    target.directLocalDependencyNames,
                    previousTarget.directLocalDependencyNames
                        + [Self.projectorTargetName]
                )
                XCTAssertEqual(
                    target.materialization,
                    previousTarget.materialization
                )
                XCTAssertEqual(
                    target.externalProductDependencyNames,
                    previousTarget.externalProductDependencyNames
                )
                XCTAssertNotEqual(target.authority, previousTarget.authority)
            } else {
                XCTAssertEqual(target, previousTarget, name)
            }
        }
        XCTAssertEqual(
            try topology.target(named: Self.projectorTargetName),
            try previous.target(named: Self.projectorTargetName)
        )
        XCTAssertEqual(topology.status, .plannedNotMaterialized)
        XCTAssertFalse(topology.executionImplemented)
        XCTAssertFalse(topology.sourceBindingV7Issued)
    }

    func testV17RelaxesOnlyTheTwoNecessaryWorkerProhibitions()
        throws
    {
        let previous = Topology.frozenV16
        let topology = Topology.frozenV17
        let previousByName = Dictionary(
            uniqueKeysWithValues:
                previous.forbiddenReachability.map {
                    ($0.targetName, $0)
                }
        )
        let topologyByName = Dictionary(
            uniqueKeysWithValues:
                topology.forbiddenReachability.map {
                    ($0.targetName, $0)
                }
        )

        XCTAssertEqual(
            Set(previousByName.keys),
            Set(topologyByName.keys)
        )
        for (name, previousRule) in previousByName {
            let rule = try XCTUnwrap(topologyByName[name], name)
            if name == Self.workerTargetName {
                XCTAssertTrue(
                    previousRule.forbiddenReachableTargetNames
                        .contains(Self.projectorTargetName)
                )
                XCTAssertTrue(
                    previousRule.forbiddenReachableTargetNames
                        .contains(Self.semanticTargetName)
                )
                XCTAssertEqual(
                    rule.forbiddenReachableTargetNames,
                    previousRule.forbiddenReachableTargetNames.filter {
                        $0 != Self.projectorTargetName
                            && $0 != Self.semanticTargetName
                    }
                )
            } else {
                XCTAssertEqual(rule, previousRule, name)
            }
        }

        let projectorRule = try XCTUnwrap(
            topologyByName[Self.projectorTargetName]
        )
        XCTAssertTrue(
            projectorRule.forbiddenReachableTargetNames
                .contains(Self.workerTargetName)
        )
        XCTAssertTrue(
            projectorRule.forbiddenReachableTargetNames
                .contains("PrimeNativeNeuralGateReplayTransport")
        )
    }

    func testWorkerAndProjectorClosuresRemainAsymmetricAndCorrectedDisjoint()
        throws
    {
        let topology = Topology.frozenV17
        XCTAssertEqual(
            try topology.transitiveLocalTargetNames(
                reachableFrom: Self.workerTargetName
            ),
            [
                "ErgenticsPrimeRuntime",
                "PrimeCore",
                "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics",
                Self.projectorTargetName,
                "PrimeNativeNeuralGateHistoricalReplayMechanics",
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplayMechanics",
                "PrimeNativeNeuralGateReplayTransport",
                Self.semanticTargetName,
            ]
        )
        XCTAssertEqual(
            try topology.transitiveLocalTargetNames(
                reachableFrom: Self.projectorTargetName
            ),
            [
                "ErgenticsPrimeRuntime",
                "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics",
                "PrimeNativeNeuralGateHistoricalReplayMechanics",
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplayMechanics",
                Self.semanticTargetName,
            ]
        )
        let workerClosure = Set(
            try topology.transitiveLocalTargetNames(
                reachableFrom: Self.workerTargetName
            )
        )
        for forbidden in [
            "PrimeNativeNeuralGateCorrectedMutationSurfaceContracts",
            "PrimeNativeNeuralGateCorrectedMutationRecordContracts",
            "PrimeNativeNeuralGateCorrectedMutationProducer",
            "PrimeNativeNeuralGateCorrectedMutationDetector",
            "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
            "PrimeNativeNeuralGateCorrectedRawWorker",
            "PrimeNativeNeuralGateReplayProbe",
            "PrimeNativeNeuralGateReplayVerifier",
        ] {
            XCTAssertFalse(workerClosure.contains(forbidden), forbidden)
        }
    }

    func testAllPriorCanonicalTopologyIdentitiesRemainExact()
        throws
    {
        let expected: [(Topology, String)] = [
            (.frozenV1, "48e0f64fcb14193d74bf9c3d98a8aeef7ca366033cea6d8f00bc345ff0ad86b5"),
            (.frozenV2, "abc8f1ada303ecb95b7c9a44e72293ed314537b93e27354aebbb7763e1487415"),
            (.frozenV3, "b475e29347a31d27be8dc1aa54648fec84c4f1b47d673a1f111ccffb794985fd"),
            (.frozenV4, "8339bbd42b0e4052888db880aacbb067770c08dd2106bf4a7820c853c4b715af"),
            (.frozenV5, "252e027fc0f547e96b8c74b2e45cd1c316f1080d639a94619e9c03c87c480930"),
            (.frozenV6, "6a25a3d674a7ef3eda4475ed5532fff2366103b641736b410b37fabbc805bcd1"),
            (.frozenV7, "88fd8b2da5590576a3c9868e1ede55efb228e82d853d5db67a1d17d58834c156"),
            (.frozenV8, "8f49c8322951249568915cb5b6a9971e251127ff865709292f0c7a7bd0f1db5b"),
            (.frozenV9, "5b5f6aae6c74d7b3cf8380093e6ebc1ba8b321f22e9476ac884c8b852ceacc90"),
            (.frozenV10, "b7990ee20d69660b29d12e0ba9014df2849da5747329c80cbe168644b6a170a5"),
            (.frozenV11, "06ce2af33e574c04ef4a46ca356402457ddd4e045bce6d100fed796c19c909eb"),
            (.frozenV12, "335e6d54a94305ee2976c9433d0b5570cdd0f67ca8fea0fa00c8dd9f12eaebbe"),
            (.frozenV13, "b1564c277a50b8bc2b2ba325809130920dcb123f0d02297efba73e3bb3aec4ea"),
            (.frozenV14, "4aee5e011a7db85ed74955684f885b03f306e82b8fd4d0f12422d0b791663564"),
            (.frozenV15, "c4fe0ddd24fc5d614b36ee2698d62cb7cdae745b087c02cc176225a070852eb0"),
            (.frozenV16, "7e9dafad211bb0fb450ff9054be71a0022f5a259b4021d90123eb4736df747d3"),
        ]

        for (topology, sha256) in expected {
            XCTAssertNoThrow(try topology.validate())
            XCTAssertEqual(try topology.contentSHA256(), sha256)
            XCTAssertNil(
                topology
                    .historicalWorkerSemanticArtifactProjectionCallEdgeSourceContractBinding
            )
        }
    }

    func testV17CanonicalRoundTripAndCurrentHash()
        throws
    {
        let topology = Topology.frozenV17
        let canonical = try PrimeCanonicalJSON.encode(topology)
        let decoded = try PrimeCanonicalJSON.decode(
            Topology.self,
            from: canonical
        )

        XCTAssertEqual(decoded, topology)
        XCTAssertNoThrow(try decoded.validate())
        XCTAssertEqual(
            try PrimeCanonicalJSON.encode(decoded),
            canonical
        )
        let observed = try topology.contentSHA256()
        XCTAssertEqual(observed.utf8.count, 64)
        XCTAssertEqual(observed, Self.topologyV17SHA256)
        XCTAssertEqual(
            observed,
            PrimeSHA256.hexDigest(of: canonical)
        )
    }

    func testDecodedSourceAndTopologyMutationsFailClosed()
        throws
    {
        let sourceData = try PrimeCanonicalJSON.encode(
            Source.frozenV1
        )
        let sourceObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: sourceData)
                as? [String: Any]
        )
        var reversedDependencies = try XCTUnwrap(
            sourceObject["worker_direct_local_dependency_names"]
                as? [String]
        )
        reversedDependencies.reverse()
        var reversedImports = try XCTUnwrap(
            sourceObject["exact_call_edge_import_names"]
                as? [String]
        )
        reversedImports.reverse()
        let sourceMutations: [(String, Any)] = [
            (
                "preserved_projection_source_v16_contract_sha256",
                String(repeating: "0", count: 64)
            ),
            (
                "worker_direct_local_dependency_names",
                reversedDependencies
            ),
            ("call_edge_access_level", "internal"),
            ("call_edge_constructs_or_infers_context", true),
            (
                "adapter_adds_defaulting_reduction_ordering_or_serialization_beyond_projector",
                true
            ),
            (
                "delegated_projector_transforms_carrier_into_artifact_set",
                false
            ),
            ("call_edge_normalized_signature", "drift"),
            ("call_edge_normalized_projector_expression", "drift"),
            ("exact_projector_call_count", 2),
            ("exact_call_edge_import_names", reversedImports),
            ("worker_target_may_reach_projection_target", false),
            ("projection_target_may_reach_worker_target", true),
            ("main_can_name_or_reach_projection_call_edge", true),
            ("call_edge_runtime_exercised", true),
            ("tests_import_worker", true),
            ("tests_invoke_projection_entry_point", true),
            (
                "worker_call_edge_or_public_projection_entry_point_invoked",
                true
            ),
            (
                "worker_call_edge_or_public_projection_entry_point_artifacts_constructed",
                true
            ),
            ("artifact_write_performed", true),
            ("source_binding_v7_issued", true),
        ]
        for (key, value) in sourceMutations {
            var mutation = sourceObject
            mutation[key] = value
            let decoded = try JSONDecoder().decode(
                Source.self,
                from: JSONSerialization.data(
                    withJSONObject: mutation,
                    options: [.sortedKeys]
                )
            )
            XCTAssertThrowsError(try decoded.validate(), key)
        }
        var unknownKeyMutation = sourceObject
        unknownKeyMutation["unknown_future_authority"] = true
        let unknownKeyData = try JSONSerialization.data(
            withJSONObject: unknownKeyMutation,
            options: [.sortedKeys]
        )
        let plainDecoded = try JSONDecoder().decode(
            Source.self,
            from: unknownKeyData
        )
        XCTAssertNoThrow(
            try plainDecoded.validate(),
            "plain JSONDecoder ignores unknown keys and is non-authoritative"
        )
        XCTAssertThrowsError(
            try PrimeCanonicalJSON.decode(
                Source.self,
                from: unknownKeyData
            ),
            "canonical decoding must reject an ignored unknown key"
        )

        let topologyData = try PrimeCanonicalJSON.encode(
            Topology.frozenV17
        )
        let topologyObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: topologyData)
                as? [String: Any]
        )
        let bindingKey =
            "historical_worker_semantic_artifact_projection_call_edge_source_contract_binding"
        let graph = try XCTUnwrap(
            topologyObject["target_graph"] as? [[String: Any]]
        )
        var topologyMutations: [[String: Any]] = []
        do {
            var mutation = topologyObject
            mutation.removeValue(forKey: bindingKey)
            topologyMutations.append(mutation)
        }
        do {
            var mutation = topologyObject
            var changedGraph = graph
            let workerIndex = try XCTUnwrap(
                changedGraph.firstIndex {
                    $0["target_name"] as? String
                        == Self.workerTargetName
                }
            )
            var worker = changedGraph[workerIndex]
            worker["direct_local_dependency_names"] = ["PrimeCore"]
            changedGraph[workerIndex] = worker
            mutation["target_graph"] = changedGraph
            topologyMutations.append(mutation)
        }
        do {
            var mutation = topologyObject
            mutation["execution_implemented"] = true
            topologyMutations.append(mutation)
        }
        do {
            var mutation = topologyObject
            mutation["source_binding_v7_issued"] = true
            topologyMutations.append(mutation)
        }
        for (index, mutation) in topologyMutations.enumerated() {
            let decoded = try JSONDecoder().decode(
                Topology.self,
                from: JSONSerialization.data(
                    withJSONObject: mutation,
                    options: [.sortedKeys]
                )
            )
            XCTAssertThrowsError(
                try decoded.validate(),
                "topology mutation \(index)"
            )
        }
    }

    func testTestsDoNotImportWorkerOrInvokeProjectionEntryPoint()
        throws
    {
        let testPaths = try recursiveRegularFilePaths(
            in: repositoryRoot.appendingPathComponent("Tests")
        ).filter { $0.hasSuffix(".swift") }
        let thisPath = repositoryRelativePath(
            URL(fileURLWithPath: #filePath)
        )
        let focusedSourceGuardPath =
            Source.frozenV1.focusedSourceGuardTest.primeRelativePath
        let privateMethodName =
            "sourceBoundHistoricalEvidenceSemanticArtifact"
                + "ProjectionCallEdge"
        let publicProjectionCall =
            Self.projectorTargetName
                + ".pro" + "ject(evidence:"
        let projectionSourceContract =
            PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjectionSourceContract
            .frozenV1
        let pinnedProjectionTest =
            projectionSourceContract
            .projectionFocusedSyntheticMechanicsTestSource
        let pinnedProjectionTestData = try Data(
            contentsOf:
                repositoryRoot.appendingPathComponent(
                    pinnedProjectionTest.primeRelativePath
                )
        )
        XCTAssertEqual(
            UInt64(pinnedProjectionTestData.count),
            pinnedProjectionTest.byteCount
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: pinnedProjectionTestData),
            pinnedProjectionTest.sha256
        )
        XCTAssertFalse(
            projectionSourceContract
                .projectionPublicEntryPointRuntimeExercised
        )

        for path in testPaths {
            let source = try String(
                contentsOf:
                    repositoryRoot.appendingPathComponent(path),
                encoding: .utf8
            )
            for line in source.split(
                separator: "\n",
                omittingEmptySubsequences: false
            ) {
                let trimmed = line.trimmingCharacters(
                    in: .whitespaces
                )
                XCTAssertNotEqual(
                    trimmed,
                    "import \(Self.workerTargetName)",
                    path
                )
                XCTAssertNotEqual(
                    trimmed,
                    "@testable import \(Self.workerTargetName)",
                    path
                )
            }
            if path != thisPath && path != focusedSourceGuardPath {
                XCTAssertFalse(source.contains(privateMethodName), path)
            }
            if path != thisPath {
                XCTAssertFalse(
                    source.filter { !$0.isWhitespace }
                        .contains(publicProjectionCall),
                    path
                )
            }
        }
    }

    private func recursiveRegularFilePaths(
        in directory: URL
    ) throws -> [String] {
        let keys: Set<URLResourceKey> = [
            .isDirectoryKey,
            .isRegularFileKey,
            .isSymbolicLinkKey,
        ]
        let enumerator = try XCTUnwrap(
            FileManager.default.enumerator(
                at: directory,
                includingPropertiesForKeys: Array(keys),
                options: [.skipsHiddenFiles]
            )
        )
        let rootPath = repositoryRoot.standardizedFileURL.path + "/"
        var paths: [String] = []
        for case let fileURL as URL in enumerator {
            let values = try fileURL.resourceValues(forKeys: keys)
            let path = fileURL.standardizedFileURL.path
            XCTAssertTrue(path.hasPrefix(rootPath), path)
            guard path.hasPrefix(rootPath) else { continue }
            let relativePath = String(path.dropFirst(rootPath.count))
            if values.isSymbolicLink == true {
                throw InventoryError.symbolicLink(relativePath)
            }
            if values.isRegularFile == true {
                paths.append(relativePath)
                continue
            }
            if values.isDirectory == true { continue }
            throw InventoryError.unsupportedNode(relativePath)
        }
        return paths.sorted()
    }

    private func repositoryRelativePath(_ url: URL) -> String {
        let root = repositoryRoot.standardizedFileURL.path + "/"
        let path = url.standardizedFileURL.path
        precondition(path.hasPrefix(root))
        return String(path.dropFirst(root.count))
    }

    private enum InventoryError: Error, Equatable {
        case symbolicLink(String)
        case unsupportedNode(String)
    }

    private var repositoryRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
