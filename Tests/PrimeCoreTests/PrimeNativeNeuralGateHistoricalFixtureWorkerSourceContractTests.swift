import Foundation
@testable import PrimeCore
import XCTest

final class PrimeNativeNeuralGateHistoricalFixtureWorkerSourceContractTests:
    XCTestCase
{
    private typealias Contract =
        PrimeNativeNeuralGateHistoricalFixtureWorkerSourceContract
    private typealias Topology =
        PrimeNativeNeuralGateTrapDisjointTopologyContract

    func testFrozenContractBindsExactMaterialAndAuthorityCeiling()
        throws
    {
        let contract = Contract.frozenV1

        XCTAssertNoThrow(try contract.validate())
        XCTAssertEqual(contract.schemaVersion, 1)
        XCTAssertEqual(
            contract.contractID,
            "prime_source_bound_historical_fixture_worker_v11"
        )
        XCTAssertEqual(contract.rightsHolder, "Ergentics, LLC")
        XCTAssertEqual(
            contract.licenseExpression,
            "LicenseRef-Ergentics-Proprietary"
        )
        XCTAssertEqual(
            contract.materialPins.map(\.checkedInByteCount),
            [88_141, 2_298, 1_949]
        )
        XCTAssertEqual(
            contract.materialPins.map(\.checkedInSHA256),
            [
                "e04daaf783f0cb79958daea9a70579fc959b47ceea4ae913bcb69cdc458fcf99",
                "9f62827d4c35e98fb01f9984b1c227cb681dd42ac4c26147a86e9429958545df",
                "cf1ba313dcb0c959e80ba09d6cbe0c56bcd921523bda5cec2c682c8ae7696ab3",
            ]
        )
        XCTAssertEqual(
            contract.fixtureDerivation,
            PrimeNativeNeuralGateAdaptationProofContract
                .frozenV3.entries[9].derivation
        )
        XCTAssertEqual(
            contract.exactNewMaterialByteCount,
            92_388
        )
        XCTAssertEqual(
            contract.exactHistoricalTargetSourceByteCount,
            484_774
        )
        XCTAssertEqual(
            contract.exactV11TransitiveSourceByteCount,
            1_236_033
        )
        XCTAssertEqual(
            try PrimeCanonicalJSON.decode(
                Contract.self,
                from: PrimeCanonicalJSON.encode(contract)
            ),
            contract
        )
        XCTAssertEqual(
            try contract.contentSHA256(),
            "64f0de29eed04145db6b598f2895bf9ee9d7804b03b35971f1ca77a72f76e9fb"
        )

        XCTAssertTrue(contract.fixtureDerivationBound)
        XCTAssertTrue(
            contract.fixtureRoutedToHistoricalReplayTarget
        )
        XCTAssertTrue(contract.fixtureSharesModuleWithPinnedGate)
        XCTAssertFalse(contract.donorAccessLevelsChanged)
        XCTAssertTrue(contract.workerExecutableTargetMaterialized)
        XCTAssertFalse(contract.workerProductDeclared)
        XCTAssertTrue(contract.workerMainUnavailable)
        XCTAssertFalse(
            contract.reservedHistoricalCallEdgeReachableFromMain
        )
        XCTAssertFalse(
            contract.completeCompiledWorkerSourceClosureObserved
        )
        XCTAssertFalse(contract.pmhnpPackageDependencyPresent)

        for observation in [
            contract.sealedWorkerImageObserved,
            contract.workerInvoked,
            contract.historicalGateExecuted,
            contract.modelExecutionObserved,
            contract.durablePublicationObserved,
            contract.independentDetectionEstablished,
            contract.distinctImplementationFamiliesEstablished,
            contract.agentContractKitFourTierAuditPerformed,
            contract.mechanicsPassAuthorized,
            contract.terminalReceiptAuthorized,
            contract.sourceBindingV7Issued,
            contract.scientificAuthorityAuthorized,
            contract.productAuthorityAuthorized,
        ] {
            XCTAssertFalse(observation)
        }
        XCTAssertEqual(
            contract.nextImplementationPrerequisite,
            "derive_and_source_bind_historical_worker_evidence_export_adapter_without_mutating_the_byte_exact_gate_executing_the_worker_or_issuing_source_binding_v7"
        )
    }

    func testPriorFrozenIdentitiesRemainExact() throws {
        XCTAssertEqual(
            try PrimeNativeNeuralGateHistoricalReplayMechanicsContract
                .frozenV1.contentSHA256(),
            "6bd51cb07b0f6bf72eb9cba6dec1fd9686377dab838fd6468497c34d6704debe"
        )
        XCTAssertEqual(
            try Topology.frozenV9.contentSHA256(),
            "5b5f6aae6c74d7b3cf8380093e6ebc1ba8b321f22e9476ac884c8b852ceacc90"
        )
        XCTAssertEqual(
            try Topology.frozenV10.contentSHA256(),
            "b7990ee20d69660b29d12e0ba9014df2849da5747329c80cbe168644b6a170a5"
        )
        XCTAssertEqual(
            Contract.frozenV1.preservedAdaptationProofV2SHA256,
            "2c5dc058ce03f329581db88fa3ab3f1e8baf6faf06ead734d772821ed8af9b28"
        )
        XCTAssertEqual(
            Contract.frozenV1.requiredAdaptationProofV3SHA256,
            "40db6bae391ef4a74723451307a66cda9b7b834c2262ae05085a5f3db68694c1"
        )
    }

    func testCheckedInMaterialAndFrozenTargetSourcesRemainExact()
        throws
    {
        let contract = Contract.frozenV1
        for pin in contract.materialPins {
            let data = try Data(
                contentsOf:
                    repositoryRoot.appendingPathComponent(
                        pin.primeRelativePath
                    )
            )
            XCTAssertEqual(
                UInt64(data.count),
                pin.checkedInByteCount,
                pin.primeRelativePath
            )
            XCTAssertEqual(
                PrimeSHA256.hexDigest(of: data),
                pin.checkedInSHA256,
                pin.primeRelativePath
            )
        }

        for binding in contract.targetBindings {
            let directory = repositoryRoot
                .appendingPathComponent("Sources")
                .appendingPathComponent(binding.targetName)
            let completeActual = try recursiveSwiftSourcePaths(
                in: directory
            )
            let frozenActual: [String]
            if binding.targetKind == .internalExecutable {
                frozenActual = completeActual.filter {
                    binding.orderedSourceRelativePaths.contains($0)
                }
            } else {
                frozenActual = completeActual
            }
            XCTAssertEqual(
                frozenActual,
                binding.orderedSourceRelativePaths.sorted(),
                binding.targetName
            )
        }

        let workerBinding = try XCTUnwrap(
            contract.targetBindings.first {
                $0.targetKind == .internalExecutable
            }
        )
        XCTAssertEqual(
            workerBinding.copiedResourceRelativePaths,
            ["HistoricalFixtureEvidence"]
        )
        let resourceRoot = repositoryRoot
            .appendingPathComponent("Sources")
            .appendingPathComponent(workerBinding.targetName)
            .appendingPathComponent(
                workerBinding.copiedResourceRelativePaths[0]
            )
        XCTAssertEqual(
            try recursiveRegularFilePaths(in: resourceRoot),
            [
                "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/HistoricalFixtureEvidence/Package.resolved",
            ]
        )
    }

    func testTopologyV11MaterializesOnlyWorkerAndPreservesIsolation()
        throws
    {
        let prior = Topology.frozenV10
        let contract = Topology.frozenV11
        let historical =
            "PrimeNativeNeuralGateHistoricalReplayMechanics"
        let worker =
            "PrimeNativeNeuralGateHistoricalFixtureWorker"

        XCTAssertNoThrow(try prior.validate())
        XCTAssertNoThrow(try contract.validate())
        XCTAssertEqual(
            try contract.contentSHA256(),
            "06ce2af33e574c04ef4a46ca356402457ddd4e045bce6d100fed796c19c909eb"
        )
        XCTAssertEqual(contract.schemaVersion, 11)
        XCTAssertEqual(
            contract.contractID,
            "prime_stage_b_source_bound_historical_fixture_worker_topology_v11"
        )
        XCTAssertEqual(contract.status, .plannedNotMaterialized)
        XCTAssertFalse(contract.executionImplemented)
        XCTAssertFalse(contract.sourceBindingV7Issued)
        XCTAssertEqual(
            contract.targetGraph.count,
            prior.targetGraph.count
        )
        XCTAssertEqual(
            zip(prior.targetGraph, contract.targetGraph)
                .filter {
                    $0.0.materialization
                        != $0.1.materialization
                }.map { $0.1.targetName },
            [worker]
        )
        XCTAssertEqual(
            try contract.target(named: historical)
                .materialization,
            .implemented
        )
        XCTAssertEqual(
            try contract.target(named: worker)
                .materialization,
            .implemented
        )
        XCTAssertEqual(
            try contract.target(named: worker)
                .directLocalDependencyNames,
            [
                "PrimeCore",
                "ErgenticsPrimeRuntime",
                historical,
                "PrimeNativeNeuralGateReplayTransport",
            ]
        )
        XCTAssertEqual(
            try contract.transitiveLocalTargetNames(
                reachableFrom: worker
            ),
            [
                "ErgenticsPrimeRuntime",
                "PrimeCore",
                historical,
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplayMechanics",
                "PrimeNativeNeuralGateReplayTransport",
            ]
        )
        for absentRole in [
            "PrimeNativeNeuralGateReplayProbe",
            "PrimeNativeNeuralGateReplayVerifier",
            "PrimeNativeNeuralGateCorrectedRawWorker",
            "PrimeNativeNeuralGateCorrectedProbeEvaluationWorker",
            "PrimeNativeNeuralGateCorrectedVerifierEvaluationWorker",
        ] {
            XCTAssertEqual(
                try contract.target(named: absentRole)
                    .materialization,
                .plannedNotMaterialized,
                absentRole
            )
        }
        XCTAssertTrue(
            contract.authorityStatement.contains(
                "Same-module placement is required"
            )
        )
        XCTAssertTrue(
            contract.authorityStatement.contains(
                "cannot yet satisfy the complete frozen historical-worker artifact protocol"
            )
        )
        XCTAssertEqual(
            contract.nextImplementationPrerequisite,
            Contract.frozenV1.nextImplementationPrerequisite
        )
    }

    func testManifestAndWorkerSourceBindUnavailableBoundary()
        throws
    {
        let package = compact(
            try String(
                contentsOf:
                    repositoryRoot.appendingPathComponent(
                        "Package.swift"
                    ),
                encoding: .utf8
            )
        )
        XCTAssertEqual(
            try Topology.frozenV11.target(
                named:
                    "PrimeNativeNeuralGateHistoricalFixtureWorker"
            ).directLocalDependencyNames,
            [
                "PrimeCore",
                "ErgenticsPrimeRuntime",
                "PrimeNativeNeuralGateHistoricalReplayMechanics",
                "PrimeNativeNeuralGateReplayTransport",
            ]
        )
        let targetsStart = try XCTUnwrap(
            package.range(of: "targets:[")
        ).lowerBound
        XCTAssertFalse(
            package[..<targetsStart].contains(
                "PrimeNativeNeuralGateHistoricalFixtureWorker"
            )
        )
        XCTAssertFalse(package.contains("pmhnp-companion"))

        let workerSource = try String(
            contentsOf:
                repositoryRoot.appendingPathComponent(
                    Contract.frozenV1.materialPins[1]
                        .primeRelativePath
                ),
            encoding: .utf8
        )
        XCTAssertTrue(
            workerSource.contains(
                "prime_source_bound_historical_fixture_worker_v11"
            )
        )
        XCTAssertTrue(
            workerSource.contains(
                "static let unavailableExitStatus: Int32 = 78"
            )
        )
        XCTAssertTrue(
            workerSource.contains(
                "Darwin.exit(unavailableExitStatus)"
            )
        )
        XCTAssertTrue(
            workerSource.contains(
                "PrimeNativeNeuralGateHistoricalWorkerContract"
            )
        )
        XCTAssertFalse(workerSource.contains("CommandLine.arguments"))
        let compactWorker = compact(workerSource)
        let mainStart = try XCTUnwrap(
            compactWorker.range(of: "staticfuncmain(){")
        ).upperBound
        let mainEnd = try XCTUnwrap(
            compactWorker.range(
                of: "}",
                range: mainStart..<compactWorker.endIndex
            )
        ).lowerBound
        let mainBody = compactWorker[mainStart..<mainEnd]
        XCTAssertEqual(
            mainBody,
            "Darwin.exit(unavailableExitStatus)"
        )
    }

    func testMalformedDecodedCollectionsFailClosedWithoutTrap()
        throws
    {
        let data = try PrimeCanonicalJSON.encode(
            Contract.frozenV1
        )
        let canonicalObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: data)
                as? [String: Any]
        )

        for (key, retainedCount) in [
            ("target_bindings", 0),
            ("target_bindings", 1),
            ("material_pins", 0),
            ("material_pins", 1),
            ("material_pins", 2),
        ] {
            var object = canonicalObject
            let entries = try XCTUnwrap(
                object[key] as? [[String: Any]]
            )
            object[key] = Array(
                entries.prefix(retainedCount)
            )
            let mutated = try JSONDecoder().decode(
                Contract.self,
                from: JSONSerialization.data(
                    withJSONObject: object,
                    options: [.sortedKeys]
                )
            )
            XCTAssertThrowsError(
                try mutated.validate(),
                "\(key):\(retainedCount)"
            ) {
                XCTAssertEqual(
                    $0 as?
                        PrimeNativeNeuralGateFixtureReplayPlanError,
                    .invalidPlan(
                        "historical_fixture_worker_source_contract"
                    )
                )
            }
        }
    }

    func testResourceInventoryIncludesHiddenFilesAndRejectsSymlinks()
        throws
    {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent(
                "prime-v11-resource-inventory-\(UUID().uuidString)",
                isDirectory: true
            )
        try FileManager.default.createDirectory(
            at: root,
            withIntermediateDirectories: false
        )
        defer {
            try? FileManager.default.removeItem(at: root)
        }

        let hidden = root.appendingPathComponent(".hidden")
        try Data("fixture".utf8).write(to: hidden)
        XCTAssertEqual(
            try recursiveRegularFilePaths(
                in: root,
                relativeTo: root
            ),
            [".hidden"]
        )

        let symbolicLink = root.appendingPathComponent("link")
        try FileManager.default.createSymbolicLink(
            at: symbolicLink,
            withDestinationURL: hidden
        )
        XCTAssertThrowsError(
            try recursiveRegularFilePaths(
                in: root,
                relativeTo: root
            )
        ) {
            XCTAssertEqual(
                $0 as? InventoryError,
                .symbolicLink("link")
            )
        }
    }

    private func recursiveSwiftSourcePaths(
        in directory: URL
    ) throws -> [String] {
        try recursiveRegularFilePaths(in: directory)
            .filter { $0.hasSuffix(".swift") }
    }

    private func recursiveRegularFilePaths(
        in directory: URL,
        relativeTo relativeRoot: URL? = nil
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
                options: []
            )
        )
        let rootPath = (relativeRoot ?? repositoryRoot)
            .standardizedFileURL.path + "/"
        var paths: [String] = []
        for case let fileURL as URL in enumerator {
            let values = try fileURL.resourceValues(
                forKeys: keys
            )
            let path = fileURL.standardizedFileURL.path
            XCTAssertTrue(path.hasPrefix(rootPath), path)
            guard path.hasPrefix(rootPath)
            else {
                continue
            }
            let relativePath = String(
                path.dropFirst(rootPath.count)
            )
            if values.isSymbolicLink == true {
                throw InventoryError.symbolicLink(
                    relativePath
                )
            }
            if values.isRegularFile == true {
                paths.append(relativePath)
                continue
            }
            if values.isDirectory == true {
                continue
            }
            throw InventoryError.unsupportedNode(relativePath)
        }
        return paths.sorted()
    }

    private enum InventoryError: Error, Equatable {
        case symbolicLink(String)
        case unsupportedNode(String)
    }

    private func compact(_ source: String) -> String {
        String(source.filter { !$0.isWhitespace })
    }

    private var repositoryRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
