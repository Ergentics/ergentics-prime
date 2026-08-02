// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
@testable import PrimeCore
import XCTest

final class
    PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjectionSourceTopologyV16Tests:
    XCTestCase
{
    private typealias Source =
        PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjectionSourceContract
    private typealias Topology =
        PrimeNativeNeuralGateTrapDisjointTopologyContract
    private static let sourceContractSHA256 =
        "2b9c1565f103622eb82e53e4a83820b98d6dd0d3dfd5487353dde06c5a4fd4dd"
    private static let topologyV16SHA256 =
        "7e9dafad211bb0fb450ff9054be71a0022f5a259b4021d90123eb4736df747d3"

    func testFrozenV16SourceContractBindsExactLosslessBoundary()
        throws
    {
        let source = Source.frozenV1

        XCTAssertNoThrow(try source.validate())
        XCTAssertEqual(source.schemaVersion, 1)
        XCTAssertEqual(
            source.contractID,
            "prime_source_bound_historical_evidence_semantic_artifact_projection_source_v16"
        )
        XCTAssertEqual(
            source.preservedDesignV15SHA256,
            "2d7da9703cf710f6f795900d91872780297a0e8d18f345cca302711d7fd0ec27"
        )
        XCTAssertEqual(
            source.preservedTopologyV15SHA256,
            "c4fe0ddd24fc5d614b36ee2698d62cb7cdae745b087c02cc176225a070852eb0"
        )
        XCTAssertEqual(source.exactNamespaceSpecificationCount, 44)
        XCTAssertEqual(source.exactNamespaceSpecificationCountPerRole, 22)
        XCTAssertEqual(source.exactHistoricalRoleCount, 2)
        XCTAssertEqual(
            source.admittedHistoricalSeeds,
            [1_618, 2_718, 3_141]
        )
        XCTAssertTrue(source.seedJoinIsExplicitlyKeyed)
        XCTAssertFalse(source.positionalSeedJoinPermitted)
        XCTAssertFalse(source.seedReductionApplied)
        XCTAssertFalse(source.summaryMaySupplyEvidence)
        XCTAssertTrue(
            source
                .redundantFingerprintFieldsOmittedAfterExactCanonicalReconstruction
        )
        XCTAssertFalse(source.nonDerivableCarrierInformationDropped)
        XCTAssertFalse(source.carrierInformationDefaulted)
        XCTAssertFalse(source.seedOrStatisticalReductionApplied)
        XCTAssertTrue(
            source
                .observedFailureLegsUseFrozenHistoricalCriticalLegDomain
        )
        XCTAssertTrue(
            source.uppercaseHistoricalNLFailureLegIDsPreserved
        )
        XCTAssertTrue(source.unknownHistoricalFailureLegIDsRejected)
        XCTAssertFalse(source.semanticV8CanonicalBytesChanged)
        XCTAssertTrue(source.projectionIsPureInMemoryCodec)
        XCTAssertTrue(
            source
                .projectionComponentSyntheticMechanicsCoveredByFocusedTests
        )
        XCTAssertEqual(
            source.exactFocusedSyntheticMechanicsTestMethodCount,
            15
        )
        XCTAssertFalse(
            source.projectionPublicEntryPointRuntimeExercised
        )
        XCTAssertFalse(source.syntheticTestsAreHistoricalEvidence)
        XCTAssertFalse(source.replayTransportIntegratedWithProjection)
        XCTAssertFalse(source.workerMayReachProjectionTarget)
        XCTAssertFalse(source.projectionMayReachWorkerTarget)
        XCTAssertFalse(source.workerRequestHandlingEnabled)
        XCTAssertFalse(source.workerExecuted)
        XCTAssertFalse(source.artifactWritePerformed)
        XCTAssertFalse(source.evidencePublished)
        XCTAssertFalse(source.mechanicsPassAuthorized)
        XCTAssertFalse(source.sourceBindingV7Issued)
    }

    func testFrozenSourceContractCanonicalRoundTripAndCurrentHash()
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
        XCTAssertEqual(
            observed,
            Self.sourceContractSHA256
        )
        XCTAssertEqual(
            observed,
            PrimeSHA256.hexDigest(of: canonical)
        )
    }

    func testEverySourceFilePinMatchesTheLiveRepository()
        throws
    {
        let source = Source.frozenV1
        let identities =
            [source.completeHistoricalNamespaceSource]
            + source.semanticRecordTargetBinding.orderedSourceFiles
            + source.correctedMutationRecordTargetBinding
                .orderedSourceFiles
            + source.projectionTargetBinding.orderedSourceFiles
            + [source.projectionFocusedSyntheticMechanicsTestSource]
        for identity in identities
        {
            let bytes = try Data(
                contentsOf:
                    repositoryRoot.appendingPathComponent(
                        identity.primeRelativePath
                    )
            )
            XCTAssertEqual(
                UInt64(bytes.count),
                identity.byteCount,
                identity.primeRelativePath
            )
            XCTAssertEqual(
                PrimeSHA256.hexDigest(of: bytes),
                identity.sha256,
                identity.primeRelativePath
            )
        }
    }

    func testCompleteTargetInventoriesAndPureSourceAuthorityRemainExact()
        throws
    {
        let source = Source.frozenV1
        let bindings = [
            source.semanticRecordTargetBinding,
            source.correctedMutationRecordTargetBinding,
            source.projectionTargetBinding,
        ]
        let commonForbiddenFragments = [
            "Foundation.Process",
            "Process(",
            "posix_spawn",
            "execve(",
            "system(",
            "popen(",
            "/bin/sh",
            "/bin/zsh",
            "\"python3\"",
            "try" + "!",
            "fatalError(",
            "precondition(",
            "preconditionFailure(",
            "FileManager.default",
            "Data(contentsOf:",
            "String(contentsOf:",
            "InputStream(",
            "OutputStream(",
            "print(",
            "debugPrint(",
            "dump(",
            "NSLog(",
            "URLSession",
            "NWConnection",
            "CFReadStream",
            "NSFileCoordinator",
            "createFile(",
            "write(to:",
            "read(",
            "O_WRONLY",
            "O_RDWR",
            "O_CREAT",
            "O_RDONLY",
            "open(",
            "openat(",
            "fopen(",
            "mmap(",
            "stat(",
            "lstat(",
            "fstat(",
            "access(",
            "opendir(",
            "readdir(",
            "rename(",
            "unlink(",
        ]
        let commonForbiddenIdentifiers = [
            "FileHandle",
            "Bundle",
        ]

        for binding in bindings {
            XCTAssertTrue(binding.completeTargetInventoryBound)
            XCTAssertTrue(binding.copiedResourceRelativePaths.isEmpty)
            let targetDirectory = repositoryRoot
                .appendingPathComponent("Sources")
                .appendingPathComponent(binding.targetName)
            let actualPaths = try recursiveRegularFilePaths(
                in: targetDirectory
            )
            let expectedPaths = binding.orderedSourceFiles
                .map(\.primeRelativePath)
                .sorted()
            XCTAssertEqual(
                actualPaths,
                expectedPaths,
                binding.targetName
            )

            let allowedImportLines = Set(
                ["import Foundation"]
                    + binding.directLocalDependencyNames.map {
                        "import \($0)"
                    }
            )
            var observedImportLines = Set<String>()
            for path in actualPaths {
                let swiftSource = try String(
                    contentsOf:
                        repositoryRoot.appendingPathComponent(path),
                    encoding: .utf8
                )
                for rawLine in swiftSource.split(
                    separator: "\n",
                    omittingEmptySubsequences: false
                ) {
                    let line = rawLine.trimmingCharacters(
                        in: .whitespaces
                    )
                    let isAttributedImport =
                        line.hasPrefix("@")
                        && line.contains("import ")
                    XCTAssertFalse(isAttributedImport, "\(path): \(line)")
                    guard line.hasPrefix("import ")
                    else {
                        continue
                    }
                    XCTAssertTrue(
                        allowedImportLines.contains(line),
                        "\(path): \(line)"
                    )
                    observedImportLines.insert(line)
                }
                for fragment in commonForbiddenFragments {
                    XCTAssertFalse(
                        swiftSource.contains(fragment),
                        "\(path): \(fragment)"
                    )
                }
                for identifier in commonForbiddenIdentifiers {
                    let escapedIdentifier =
                        NSRegularExpression.escapedPattern(
                            for: identifier
                        )
                    let pattern = "\\b\(escapedIdentifier)\\b"
                    XCTAssertNil(
                        swiftSource.range(
                            of: pattern,
                            options: .regularExpression
                        ),
                        "\(path): \(identifier)"
                    )
                }
                if binding.targetName
                    == "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection"
                {
                    for fragment in [
                        "PrimeNativeNeuralGateHistoricalEvidenceExporter"
                            + ".export(",
                        "PrimeNativeNeuralGateReplayTransport",
                        "PrimeNativeNeuralGateHistoricalFixtureWorker",
                        "PrimeCore",
                        "PrimeNativeNeuralGateCorrectedMutationSurfaceContracts",
                        "PrimeNativeNeuralGateCorrectedMutationRecordContracts",
                        "PrimeNativeNeuralGateCorrectedMutationProducer",
                        "PrimeNativeNeuralGateCorrectedMutationDetector",
                        "import MLX",
                        "import Metal",
                        "import Network",
                    ] {
                        XCTAssertFalse(
                            swiftSource.contains(fragment),
                            "\(path): \(fragment)"
                        )
                    }
                }
            }
            XCTAssertEqual(
                observedImportLines,
                allowedImportLines,
                binding.targetName
            )
        }
    }

    func testFrozenV16TopologyRewiresOnlyTheDeclaredSourceBoundary()
        throws
    {
        let previous = Topology.frozenV15
        let topology = Topology.frozenV16
        let source = Source.frozenV1

        XCTAssertNoThrow(try topology.validate())
        XCTAssertEqual(topology.schemaVersion, 16)
        XCTAssertEqual(
            topology.contractID,
            "prime_stage_b_source_bound_historical_evidence_semantic_artifact_projection_topology_v16"
        )
        XCTAssertEqual(
            topology
                .historicalEvidenceSemanticArtifactProjectionSourceContractID,
            source.contractID
        )
        XCTAssertEqual(
            topology
                .historicalEvidenceSemanticArtifactProjectionSourceContractSHA256,
            try source.contentSHA256()
        )
        XCTAssertEqual(
            topology.targetGraph.count,
            previous.targetGraph.count + 2
        )

        let semantic = try topology.target(
            named: "PrimeNativeNeuralGateSemanticRecordContracts"
        )
        XCTAssertEqual(
            semantic.directLocalDependencyNames,
            [
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplayMechanics",
            ]
        )
        let record = try topology.target(
            named: "PrimeNativeNeuralGateCorrectedMutationRecordContracts"
        )
        XCTAssertEqual(
            record.directLocalDependencyNames,
            [
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplayMechanics",
                "PrimeNativeNeuralGateCorrectedMutationSurfaceContracts",
            ]
        )
        let producer = try topology.target(
            named: "PrimeNativeNeuralGateCorrectedMutationProducer"
        )
        XCTAssertEqual(
            producer.directLocalDependencyNames,
            [
                "PrimeNativeNeuralGateCorrectedMutationRecordContracts",
                "PrimeNativeNeuralGateCorrectedMutationSurfaceContracts",
            ]
        )
        let projector = try topology.target(
            named:
                "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection"
        )
        XCTAssertEqual(
            projector.directLocalDependencyNames,
            [
                "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics",
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplayMechanics",
                "PrimeNativeNeuralGateSemanticRecordContracts",
            ]
        )
        XCTAssertEqual(record.materialization, .implemented)
        XCTAssertEqual(projector.materialization, .implemented)
        XCTAssertEqual(topology.status, .plannedNotMaterialized)
        XCTAssertFalse(topology.executionImplemented)
        XCTAssertFalse(topology.sourceBindingV7Issued)
    }

    func testWorkerGraphAndUnavailableAuthorityRemainExact()
        throws
    {
        let previous = Topology.frozenV15
        let topology = Topology.frozenV16
        let workerName =
            "PrimeNativeNeuralGateHistoricalFixtureWorker"
        let oldWorker = try previous.target(named: workerName)
        let worker = try topology.target(named: workerName)

        XCTAssertEqual(worker, oldWorker)
        XCTAssertEqual(
            worker.directLocalDependencyNames,
            [
                "PrimeCore",
                "ErgenticsPrimeRuntime",
                "PrimeNativeNeuralGateHistoricalReplayMechanics",
                "PrimeNativeNeuralGateReplayTransport",
                "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics",
            ]
        )
        XCTAssertFalse(
            worker.directLocalDependencyNames.contains(
                "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection"
            )
        )
        XCTAssertTrue(
            topology.authorityStatement.contains(
                "status-78 unavailable main"
            )
        )
        XCTAssertTrue(
            topology.authorityStatement.contains(
                "ReplayTransport remains materialized but has no V16 projector integration"
            )
        )
    }

    func testProjectorClosureIsHistoricalContainedAndCorrectedDisjoint()
        throws
    {
        let topology = Topology.frozenV16
        let projector =
            "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection"
        let closure = Set(
            try topology.transitiveLocalTargetNames(
                reachableFrom: projector
            )
        )

        XCTAssertTrue(
            closure.contains(
                "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics"
            )
        )
        XCTAssertTrue(
            closure.contains(
                "PrimeNativeNeuralGateHistoricalReplayMechanics"
            )
        )
        XCTAssertTrue(closure.contains("ErgenticsPrimeRuntime"))
        for forbidden in [
            "PrimeCore",
            "PrimeNativeNeuralGateReplayTransport",
            "PrimeNativeNeuralGateCorrectedMutationSurfaceContracts",
            "PrimeNativeNeuralGateCorrectedMutationRecordContracts",
            "PrimeNativeNeuralGateCorrectedMutationProducer",
            "PrimeNativeNeuralGateCorrectedMutationDetector",
            "PrimeNativeNeuralGateHistoricalFixtureWorker",
        ] {
            XCTAssertFalse(closure.contains(forbidden), forbidden)
        }
        let workerClosure = Set(
            try topology.transitiveLocalTargetNames(
                reachableFrom:
                    topology.historicalContainmentRootTargetName
            )
        )
        XCTAssertFalse(workerClosure.contains(projector))
    }

    func testActualPackageDeclaresExactV16TargetsWithoutWorkerIntegration()
        throws
    {
        let package = try String(
            contentsOf:
                repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        ).filter { !$0.isWhitespace }

        XCTAssertTrue(
            package.contains(
                #".target(name:"PrimeNativeNeuralGateSemanticRecordContracts",dependencies:["PrimeNativeNeuralGateReplayArtifactContracts","PrimeNativeNeuralGateReplayMechanics",])"#
            )
        )
        XCTAssertTrue(
            package.contains(
                #".target(name:"PrimeNativeNeuralGateCorrectedMutationRecordContracts",dependencies:["PrimeNativeNeuralGateReplayArtifactContracts","PrimeNativeNeuralGateReplayMechanics","PrimeNativeNeuralGateCorrectedMutationSurfaceContracts",])"#
            )
        )
        XCTAssertTrue(
            package.contains(
                #".target(name:"PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection",dependencies:["PrimeNativeNeuralGateHistoricalEvidenceExportMechanics","PrimeNativeNeuralGateReplayArtifactContracts","PrimeNativeNeuralGateReplayMechanics","PrimeNativeNeuralGateSemanticRecordContracts",])"#
            )
        )
        XCTAssertFalse(
            package.contains(
                #".executableTarget(name:"PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection""#
            )
        )
        XCTAssertFalse(
            package.contains(
                #".library(name:"PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection""#
            )
        )
        let worker = try Topology.frozenV16.target(
            named: "PrimeNativeNeuralGateHistoricalFixtureWorker"
        )
        XCTAssertEqual(
            worker,
            try Topology.frozenV15.target(
                named: worker.targetName
            )
        )
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
        ]

        for (topology, sha256) in expected {
            XCTAssertNoThrow(try topology.validate())
            XCTAssertEqual(try topology.contentSHA256(), sha256)
            XCTAssertNil(
                topology
                    .historicalEvidenceSemanticArtifactProjectionSourceContractBinding
            )
            XCTAssertNil(
                topology
                    .historicalEvidenceSemanticArtifactProjectionTargetName
            )
        }
    }

    func testV16CanonicalRoundTripAndCurrentHash()
        throws
    {
        let topology = Topology.frozenV16
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
        XCTAssertEqual(
            observed,
            Self.topologyV16SHA256
        )
        XCTAssertEqual(
            observed,
            PrimeSHA256.hexDigest(of: canonical)
        )
    }

    func testV16SourceGraphAndAuthorityMutationsFailClosed()
        throws
    {
        let canonical = try PrimeCanonicalJSON.encode(
            Topology.frozenV16
        )
        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical)
                as? [String: Any]
        )
        let bindingKey =
            "historical_evidence_semantic_artifact_projection_source_contract_binding"
        let binding = try XCTUnwrap(
            object[bindingKey] as? [String: Any]
        )
        let graph = try XCTUnwrap(
            object["target_graph"] as? [[String: Any]]
        )
        var mutations: [[String: Any]] = []

        do {
            var drift = object
            drift.removeValue(forKey: bindingKey)
            mutations.append(drift)
        }
        do {
            var drift = object
            var changed = binding
            changed["content_sha256"] =
                String(repeating: "0", count: 64)
            drift[bindingKey] = changed
            mutations.append(drift)
        }
        do {
            var drift = object
            drift["target_graph"] = Array(graph.dropLast())
            mutations.append(drift)
        }
        do {
            var drift = object
            drift["execution_implemented"] = true
            mutations.append(drift)
        }
        do {
            var drift = object
            drift["status"] = "implemented"
            mutations.append(drift)
        }
        do {
            var drift = object
            drift[
                "historical_evidence_semantic_artifact_projection_target_name"
            ] = "PrimeNativeNeuralGateHistoricalFixtureWorker"
            mutations.append(drift)
        }

        for (index, mutation) in mutations.enumerated() {
            let decoded = try JSONDecoder().decode(
                Topology.self,
                from: JSONSerialization.data(
                    withJSONObject: mutation,
                    options: [.sortedKeys]
                )
            )
            XCTAssertThrowsError(
                try decoded.validate(),
                "V16 mutation \(index)"
            )
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
                options: []
            )
        )
        let rootPath = repositoryRoot.standardizedFileURL.path + "/"
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
                throw InventoryError.symbolicLink(relativePath)
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

    private var repositoryRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
