// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
@testable import PrimeCore
import XCTest

final class
    PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderSourceTopologyV18Tests:
    XCTestCase
{
    private typealias Source =
        PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderSourceContract
    private typealias Topology =
        PrimeNativeNeuralGateTrapDisjointTopologyContract

    private static let statisticsTargetName =
        "PrimeNativeNeuralGateHistoricalStatisticsArtifactContracts"
    private static let decoderTargetName =
        "PrimeNativeNeuralGateHistoricalSemanticArtifactDecoder"
    private static let artifactTargetName =
        "PrimeNativeNeuralGateReplayArtifactContracts"
    private static let replayMechanicsTargetName =
        "PrimeNativeNeuralGateReplayMechanics"
    private static let semanticTargetName =
        "PrimeNativeNeuralGateSemanticRecordContracts"
    private static let workerTargetName =
        "PrimeNativeNeuralGateHistoricalFixtureWorker"

    // Frozen after all three V18 production sources and the focused decoder
    // test reached their final byte identities.
    private static let sourceContractSHA256 =
        "18b747001331df62115ba502a15f3bb8379a12f484176811860b191738235ae3"
    // Frozen after the source-contract digest above was bound into frozenV18.
    private static let topologyV18SHA256 =
        "aa9dd4031469742fca5d0241bd329e7712d98ec81677704fbca911d5bdcf043f"

    func testFrozenV18SourceContractBindsOnlyThePureDecoderBoundary()
        throws
    {
        let source = Source.frozenV1

        XCTAssertNoThrow(try source.validate())
        XCTAssertEqual(source.schemaVersion, 1)
        XCTAssertEqual(
            source.contractID,
            "prime_source_bound_historical_semantic_artifact_decoder_v18"
        )
        XCTAssertEqual(source.rightsHolder, "Ergentics, LLC")
        XCTAssertEqual(
            source.licenseExpression,
            "LicenseRef-Ergentics-Proprietary"
        )
        XCTAssertEqual(
            source.preservedProjectionSourceV16ContractID,
            "prime_source_bound_historical_evidence_semantic_artifact_projection_source_v16"
        )
        XCTAssertEqual(
            source.preservedProjectionSourceV16ContractSHA256,
            "2b9c1565f103622eb82e53e4a83820b98d6dd0d3dfd5487353dde06c5a4fd4dd"
        )
        XCTAssertEqual(
            source.preservedWorkerProjectionCallEdgeV17ContractID,
            "prime_source_bound_historical_worker_semantic_artifact_projection_call_edge_v17"
        )
        XCTAssertEqual(
            source.preservedWorkerProjectionCallEdgeV17ContractSHA256,
            "ccf2e46ffc9e980d96357980e128ecb411a5ac5f55b8e783bf611582ec32d6d3"
        )
        XCTAssertEqual(
            source.preservedTopologyV17ID,
            "prime_stage_b_historical_worker_semantic_artifact_projection_call_edge_source_topology_v17"
        )
        XCTAssertEqual(
            source.preservedTopologyV17SHA256,
            "3a14288df628b1d44936013af44dd237e876fd1cf2b38e4ce0afd3a4c5cd2166"
        )
        XCTAssertFalse(source.priorPinnedProducerFilesChanged)

        XCTAssertEqual(
            source.statisticsTargetBinding.targetName,
            Self.statisticsTargetName
        )
        XCTAssertEqual(
            source.statisticsTargetBinding.directLocalDependencyNames,
            [Self.artifactTargetName]
        )
        XCTAssertEqual(
            source.decoderTargetBinding.targetName,
            Self.decoderTargetName
        )
        XCTAssertEqual(
            source.decoderTargetBinding.directLocalDependencyNames,
            [
                Self.statisticsTargetName,
                Self.artifactTargetName,
                Self.replayMechanicsTargetName,
                Self.semanticTargetName,
            ]
        )
        for binding in [
            source.statisticsTargetBinding,
            source.decoderTargetBinding,
        ] {
            XCTAssertEqual(binding.targetKind, "internal_library")
            XCTAssertTrue(binding.copiedResourceRelativePaths.isEmpty)
            XCTAssertTrue(binding.externalProductDependencyNames.isEmpty)
            XCTAssertFalse(binding.productDeclared)
            XCTAssertFalse(binding.executableDeclared)
            XCTAssertTrue(binding.completeTargetInventoryBound)
        }

        XCTAssertEqual(source.completeCanonicalJSONLeafCountPerRole, 6)
        XCTAssertEqual(source.exactArtifactCountPerRole, 22)
        XCTAssertEqual(source.exactHistoricalRoleCount, 2)
        XCTAssertEqual(source.exactInvariantRecordCount, 59_497)
        XCTAssertEqual(source.exactInvariantChunkCountPerRole, 15)
        XCTAssertEqual(source.descriptorFeedMaximumByteCount, 65_536)
        XCTAssertEqual(source.exactStatisticsSeedCount, 3)
        XCTAssertEqual(source.exactCapabilitySplitCountPerSeed, 5)
        XCTAssertEqual(source.exactAbstentionRowCountPerSeed, 2_048)
        XCTAssertEqual(source.exactMutationCount, 46)
        XCTAssertEqual(source.exactCriticalLegCount, 10)
        XCTAssertTrue(source.foundationCodableOwnsJSONParsing)
        XCTAssertFalse(source.customJSONParserImplemented)
        XCTAssertTrue(source.existingFramedRecordReaderReused)
        XCTAssertFalse(source.customFrameParserImplemented)
        XCTAssertTrue(source.canonicalReencodeRequired)
        XCTAssertTrue(source.exactKeyedCoverageRequired)
        XCTAssertFalse(source.positionalArtifactJoinPermitted)
        XCTAssertTrue(source.globalChunkRecordEqualityRequired)
        XCTAssertTrue(source.decoderPoisonsAfterFirstFailure)
        XCTAssertTrue(source.statisticsProducerDecoderParityTested)
        XCTAssertTrue(source.keyedStreamFragmentsRequired)
        XCTAssertFalse(
            source.publicStatisticsDecodableConformanceExposed
        )
        XCTAssertFalse(source.unverifiedRecordCallbackExposed)
        XCTAssertFalse(
            source.materializedAllBinaryArtifactConvenienceExposed
        )
        XCTAssertTrue(
            source.streamBindingsDerivedAfterTerminalAcceptance
        )
        XCTAssertFalse(source.decoderClosureReachesProjector)
        XCTAssertFalse(source.decoderClosureReachesExporterOrRuntime)
        for falseClaim in [
            source.descriptorSourceBound,
            source.replayTransportIntegrated,
            source.workerRequestHandlingEnabled,
            source.workerExecuted,
            source.artifactWritePerformed,
            source.evidencePublished,
            source.mechanicsPassAuthorized,
            source.terminalReceiptAuthorized,
            source.sourceBindingV7Issued,
            source.scientificAuthorityAuthorized,
            source.productAuthorityAuthorized,
        ] {
            XCTAssertFalse(falseClaim)
        }
    }

    func testFrozenV18SourceCanonicalRoundTripAndPinnedHash()
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
        XCTAssertEqual(try PrimeCanonicalJSON.encode(decoded), canonical)
        let observed = try source.contentSHA256()
        XCTAssertEqual(observed.utf8.count, 64)
        XCTAssertEqual(observed, Self.sourceContractSHA256)
        XCTAssertEqual(observed, PrimeSHA256.hexDigest(of: canonical))
    }

    func testAllPinnedV18SourceFilesMatchTheLiveRepository()
        throws
    {
        let source = Source.frozenV1
        let identities =
            source.statisticsTargetBinding.orderedSourceFiles
            + source.decoderTargetBinding.orderedSourceFiles
            + [source.focusedDecoderTestSource]

        XCTAssertEqual(identities.count, 4)
        XCTAssertEqual(
            Set(identities.map(\.primeRelativePath)).count,
            identities.count
        )
        for identity in identities {
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
    }

    func testPackageDeclaresExactProductFreeResourceFreeTargets()
        throws
    {
        let package = try String(
            contentsOf:
                repositoryRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8
        ).filter { !$0.isWhitespace }

        let statisticsDeclaration =
            #".target(name:"PrimeNativeNeuralGateHistoricalStatisticsArtifactContracts",dependencies:["PrimeNativeNeuralGateReplayArtifactContracts",])"#
        let decoderDeclaration =
            #".target(name:"PrimeNativeNeuralGateHistoricalSemanticArtifactDecoder",dependencies:["PrimeNativeNeuralGateHistoricalStatisticsArtifactContracts","PrimeNativeNeuralGateReplayArtifactContracts","PrimeNativeNeuralGateReplayMechanics","PrimeNativeNeuralGateSemanticRecordContracts",])"#
        let focusedTestDeclaration =
            #".testTarget(name:"PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderTests",dependencies:["PrimeNativeNeuralGateHistoricalEvidenceExportMechanics","PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection","PrimeNativeNeuralGateHistoricalSemanticArtifactDecoder","PrimeNativeNeuralGateHistoricalStatisticsArtifactContracts","PrimeNativeNeuralGateReplayArtifactContracts","PrimeNativeNeuralGateReplayMechanics","PrimeNativeNeuralGateSemanticRecordContracts",])"#

        XCTAssertEqual(
            package.components(separatedBy: statisticsDeclaration).count
                - 1,
            1
        )
        XCTAssertEqual(
            package.components(separatedBy: decoderDeclaration).count - 1,
            1
        )
        XCTAssertEqual(
            package.components(separatedBy: focusedTestDeclaration).count
                - 1,
            1
        )
        for targetName in [
            Self.statisticsTargetName,
            Self.decoderTargetName,
        ] {
            XCTAssertFalse(
                package.contains(#".library(name:"\#(targetName)""#)
            )
            XCTAssertFalse(
                package.contains(
                    #".executableTarget(name:"\#(targetName)""#
                )
            )
            XCTAssertFalse(
                package.contains(
                    #".executable(name:"\#(targetName)""#
                )
            )
        }
    }

    func testTargetInventoriesImportsAndForbiddenAPIsAreExact()
        throws
    {
        let source = Source.frozenV1
        let bindings = [
            source.statisticsTargetBinding,
            source.decoderTargetBinding,
        ]
        let commonForbiddenFragments = [
            "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection",
            "PrimeNativeNeuralGateHistoricalEvidenceExporter",
            "PrimeNativeNeuralGateHistoricalFixtureWorker",
            "PrimeNativeNeuralGateHistoricalReplayMechanics",
            "PrimeNativeNeuralGateReplayTransport",
            "ErgenticsPrimeRuntime",
            "PrimeCore",
            "JSONSerialization",
            "globalMagic",
            "chunkMagic",
            "CommandLine",
            "ProcessInfo",
            "URLSession",
            "NWConnection",
            "CFReadStream",
            "createFile(",
            "write(to:",
            "O_WRONLY",
            "O_RDWR",
            "O_CREAT",
            "O_RDONLY",
            "openat(",
            "fopen(",
            "mmap(",
            "lstat(",
            "fstat(",
            "opendir(",
            "readdir(",
            "rename(",
            "unlink(",
        ]
        let commonForbiddenIdentifiers = [
            "FileHandle",
            "FileManager",
            "InputStream",
            "OutputStream",
            "Bundle",
            "NSFileCoordinator",
            "NSWorkspace",
            "DispatchIO",
        ]

        for binding in bindings {
            XCTAssertTrue(binding.completeTargetInventoryBound)
            XCTAssertTrue(binding.copiedResourceRelativePaths.isEmpty)
            XCTAssertTrue(binding.externalProductDependencyNames.isEmpty)
            XCTAssertFalse(binding.productDeclared)
            XCTAssertFalse(binding.executableDeclared)

            let targetDirectory = repositoryRoot
                .appendingPathComponent("Sources")
                .appendingPathComponent(binding.targetName)
            let actualPaths = try recursiveRegularFilePaths(
                in: targetDirectory
            )
            let expectedPaths = binding.orderedSourceFiles
                .map(\.primeRelativePath)
                .sorted()
            XCTAssertEqual(actualPaths, expectedPaths, binding.targetName)

            let allowedImports = Set(
                ["import Foundation"]
                    + binding.directLocalDependencyNames.map {
                        "import \($0)"
                    }
            )
            var observedImports = Set<String>()
            var combinedSource = ""
            for path in actualPaths {
                let swiftSource = try String(
                    contentsOf:
                        repositoryRoot.appendingPathComponent(path),
                    encoding: .utf8
                )
                combinedSource += swiftSource
                for rawLine in swiftSource.split(
                    separator: "\n",
                    omittingEmptySubsequences: false
                ) {
                    let line = rawLine.trimmingCharacters(
                        in: .whitespaces
                    )
                    XCTAssertFalse(
                        line.hasPrefix("@") && line.contains("import "),
                        "\(path): \(line)"
                    )
                    guard line.hasPrefix("import ") else { continue }
                    XCTAssertTrue(
                        allowedImports.contains(line),
                        "\(path): \(line)"
                    )
                    observedImports.insert(line)
                }
                for fragment in commonForbiddenFragments {
                    XCTAssertFalse(
                        swiftSource.contains(fragment),
                        "\(path): \(fragment)"
                    )
                }
                for identifier in commonForbiddenIdentifiers {
                    let escaped = NSRegularExpression.escapedPattern(
                        for: identifier
                    )
                    XCTAssertNil(
                        swiftSource.range(
                            of: "\\b\(escaped)\\b",
                            options: .regularExpression
                        ),
                        "\(path): \(identifier)"
                    )
                }
            }
            XCTAssertEqual(
                observedImports,
                allowedImports,
                binding.targetName
            )

            if binding.targetName == Self.statisticsTargetName {
                XCTAssertTrue(combinedSource.contains("JSONDecoder"))
                XCTAssertTrue(combinedSource.contains("JSONEncoder"))
                XCTAssertTrue(
                    combinedSource.contains(
                        "HistoricalStatisticsArtifactEnvelope:\n    Encodable,"
                    )
                )
                XCTAssertFalse(
                    combinedSource.contains(
                        "HistoricalStatisticsArtifactEnvelope:\n    Codable,"
                    )
                )
                XCTAssertFalse(
                    combinedSource.contains(
                        "PrimeNativeNeuralGateInvariantFramedRecordReader"
                    )
                )
            } else {
                XCTAssertTrue(combinedSource.contains("JSONDecoder"))
                XCTAssertTrue(combinedSource.contains("JSONEncoder"))
                XCTAssertTrue(
                    combinedSource.contains(
                        "PrimeNativeNeuralGateInvariantFramedRecordReader"
                    )
                )
                XCTAssertTrue(
                    combinedSource.contains(
                        "public func consume("
                    )
                )
                XCTAssertFalse(
                    combinedSource.contains("onInvariantRecord")
                )
                XCTAssertFalse(combinedSource.contains("UnicodeScalar"))
            }
        }
    }

    func testFrozenV18GraphAddsExactlyTwoPureTargets()
        throws
    {
        let previous = Topology.frozenV17
        let topology = Topology.frozenV18
        let source = Source.frozenV1

        XCTAssertNoThrow(try topology.validate())
        XCTAssertEqual(topology.schemaVersion, 18)
        XCTAssertEqual(
            topology.contractID,
            "prime_stage_b_historical_semantic_artifact_decoder_source_topology_v18"
        )
        XCTAssertEqual(
            topology.historicalSemanticArtifactDecoderSourceContractID,
            source.contractID
        )
        XCTAssertEqual(
            topology.historicalSemanticArtifactDecoderSourceContractSHA256,
            try source.contentSHA256()
        )
        XCTAssertEqual(
            topology.historicalStatisticsArtifactContractTargetName,
            Self.statisticsTargetName
        )
        XCTAssertEqual(
            topology.historicalSemanticArtifactDecoderTargetName,
            Self.decoderTargetName
        )
        XCTAssertEqual(
            topology.targetGraph.count,
            previous.targetGraph.count + 2
        )

        let previousByName = Dictionary(
            uniqueKeysWithValues:
                previous.targetGraph.map { ($0.targetName, $0) }
        )
        let topologyByName = Dictionary(
            uniqueKeysWithValues:
                topology.targetGraph.map { ($0.targetName, $0) }
        )
        XCTAssertEqual(
            Set(topologyByName.keys).subtracting(previousByName.keys),
            Set([Self.statisticsTargetName, Self.decoderTargetName])
        )
        for (name, oldTarget) in previousByName {
            XCTAssertEqual(topologyByName[name], oldTarget, name)
        }

        let statistics = try topology.target(
            named: Self.statisticsTargetName
        )
        XCTAssertEqual(statistics.materialization, .implemented)
        XCTAssertEqual(
            statistics.directLocalDependencyNames,
            [Self.artifactTargetName]
        )
        XCTAssertTrue(statistics.externalProductDependencyNames.isEmpty)

        let decoder = try topology.target(named: Self.decoderTargetName)
        XCTAssertEqual(decoder.materialization, .implemented)
        XCTAssertEqual(
            decoder.directLocalDependencyNames,
            [
                Self.statisticsTargetName,
                Self.artifactTargetName,
                Self.replayMechanicsTargetName,
                Self.semanticTargetName,
            ]
        )
        XCTAssertTrue(decoder.externalProductDependencyNames.isEmpty)
        XCTAssertEqual(topology.status, .plannedNotMaterialized)
        XCTAssertFalse(topology.executionImplemented)
        XCTAssertFalse(topology.sourceBindingV7Issued)
    }

    func testWorkerRemainsExactV17AndCannotReachEitherV18Target()
        throws
    {
        let previous = Topology.frozenV17
        let topology = Topology.frozenV18
        let previousWorker = try previous.target(
            named: Self.workerTargetName
        )
        let worker = try topology.target(named: Self.workerTargetName)

        XCTAssertEqual(worker, previousWorker)
        XCTAssertEqual(
            worker.directLocalDependencyNames,
            [
                "PrimeCore",
                "ErgenticsPrimeRuntime",
                "PrimeNativeNeuralGateHistoricalReplayMechanics",
                "PrimeNativeNeuralGateReplayTransport",
                "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics",
                "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection",
            ]
        )
        let closure = Set(
            try topology.transitiveLocalTargetNames(
                reachableFrom: Self.workerTargetName
            )
        )
        XCTAssertFalse(closure.contains(Self.statisticsTargetName))
        XCTAssertFalse(closure.contains(Self.decoderTargetName))
    }

    func testV18TargetClosuresAreExactAndProducerDisjoint()
        throws
    {
        let topology = Topology.frozenV18
        XCTAssertEqual(
            try topology.transitiveLocalTargetNames(
                reachableFrom: Self.statisticsTargetName
            ),
            [Self.artifactTargetName]
        )
        XCTAssertEqual(
            try topology.transitiveLocalTargetNames(
                reachableFrom: Self.decoderTargetName
            ),
            [
                Self.statisticsTargetName,
                Self.artifactTargetName,
                Self.replayMechanicsTargetName,
                Self.semanticTargetName,
            ].sorted()
        )

        let forbidden = [
            "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection",
            "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics",
            "PrimeNativeNeuralGateHistoricalReplayMechanics",
            "PrimeNativeNeuralGateHistoricalFixtureWorker",
            "ErgenticsPrimeRuntime",
            "PrimeCore",
            "PrimeNativeNeuralGateReplayTransport",
            "PrimeNativeNeuralGateCorrectedMutationSurfaceContracts",
            "PrimeNativeNeuralGateCorrectedMutationRecordContracts",
            "PrimeNativeNeuralGateCorrectedMutationProducer",
            "PrimeNativeNeuralGateCorrectedMutationDetector",
            "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
            "PrimeNativeNeuralGateCorrectedRawWorker",
            "PrimeNativeNeuralGateReplayProbe",
            "PrimeNativeNeuralGateReplayVerifier",
        ]
        for targetName in [
            Self.statisticsTargetName,
            Self.decoderTargetName,
        ] {
            let closure = Set(
                try topology.transitiveLocalTargetNames(
                    reachableFrom: targetName
                )
            )
            for forbiddenName in forbidden {
                XCTAssertFalse(
                    closure.contains(forbiddenName),
                    "\(targetName) -> \(forbiddenName)"
                )
            }
        }
    }

    func testEveryV17TargetForbidsReachingTheTwoV18Targets()
        throws
    {
        let previous = Topology.frozenV17
        let topology = Topology.frozenV18
        let rulesByName = Dictionary(
            uniqueKeysWithValues:
                topology.forbiddenReachability.map {
                    ($0.targetName, $0)
                }
        )

        for target in previous.targetGraph {
            let closure = Set(
                try topology.transitiveLocalTargetNames(
                    reachableFrom: target.targetName
                )
            )
            XCTAssertFalse(
                closure.contains(Self.statisticsTargetName),
                target.targetName
            )
            XCTAssertFalse(
                closure.contains(Self.decoderTargetName),
                target.targetName
            )
            let rule = try XCTUnwrap(
                rulesByName[target.targetName],
                target.targetName
            )
            XCTAssertTrue(
                rule.forbiddenReachableTargetNames.contains(
                    Self.statisticsTargetName
                ),
                target.targetName
            )
            XCTAssertTrue(
                rule.forbiddenReachableTargetNames.contains(
                    Self.decoderTargetName
                ),
                target.targetName
            )
        }
    }

    func testPinnedV16AndV17SourceContractsRemainCanonical()
        throws
    {
        let projection =
            PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjectionSourceContract
            .frozenV1
        let worker =
            PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactProjectionCallEdgeSourceContract
            .frozenV1

        XCTAssertNoThrow(try projection.validate())
        XCTAssertNoThrow(try worker.validate())
        XCTAssertEqual(
            PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(projection)
            ),
            "2b9c1565f103622eb82e53e4a83820b98d6dd0d3dfd5487353dde06c5a4fd4dd"
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(worker)
            ),
            "ccf2e46ffc9e980d96357980e128ecb411a5ac5f55b8e783bf611582ec32d6d3"
        )
        XCTAssertEqual(
            try Topology.frozenV16.contentSHA256(),
            "7e9dafad211bb0fb450ff9054be71a0022f5a259b4021d90123eb4736df747d3"
        )
        XCTAssertEqual(
            try Topology.frozenV17.contentSHA256(),
            "3a14288df628b1d44936013af44dd237e876fd1cf2b38e4ce0afd3a4c5cd2166"
        )
        XCTAssertEqual(
            Source.frozenV1.preservedProjectionSourceV16ContractSHA256,
            "2b9c1565f103622eb82e53e4a83820b98d6dd0d3dfd5487353dde06c5a4fd4dd"
        )
        XCTAssertEqual(
            Source.frozenV1
                .preservedWorkerProjectionCallEdgeV17ContractSHA256,
            "ccf2e46ffc9e980d96357980e128ecb411a5ac5f55b8e783bf611582ec32d6d3"
        )
    }

    func testAllV1ThroughV17CanonicalTopologyHashesRemainExact()
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
            (.frozenV17, "3a14288df628b1d44936013af44dd237e876fd1cf2b38e4ce0afd3a4c5cd2166"),
        ]

        for (topology, sha256) in expected {
            XCTAssertNoThrow(try topology.validate())
            XCTAssertEqual(try topology.contentSHA256(), sha256)
            XCTAssertNil(
                topology
                    .historicalSemanticArtifactDecoderSourceContractBinding
            )
            XCTAssertNil(
                topology
                    .historicalStatisticsArtifactContractTargetName
            )
            XCTAssertNil(
                topology.historicalSemanticArtifactDecoderTargetName
            )
        }
    }

    func testV18CanonicalRoundTripAndPinnedHash()
        throws
    {
        let topology = Topology.frozenV18
        let canonical = try PrimeCanonicalJSON.encode(topology)
        let decoded = try PrimeCanonicalJSON.decode(
            Topology.self,
            from: canonical
        )

        XCTAssertEqual(decoded, topology)
        XCTAssertNoThrow(try decoded.validate())
        XCTAssertEqual(try PrimeCanonicalJSON.encode(decoded), canonical)
        let observed = try topology.contentSHA256()
        XCTAssertEqual(observed.utf8.count, 64)
        XCTAssertEqual(observed, Self.topologyV18SHA256)
        XCTAssertEqual(observed, PrimeSHA256.hexDigest(of: canonical))
    }

    func testDecodedV18SourceAndTopologyMutationsFailClosed()
        throws
    {
        let sourceData = try PrimeCanonicalJSON.encode(Source.frozenV1)
        let sourceObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: sourceData)
                as? [String: Any]
        )
        var sourceMutations: [[String: Any]] = []
        for (key, value) in [
            ("priorPinnedProducerFilesChanged", true),
            ("customJSONParserImplemented", true),
            ("customFrameParserImplemented", true),
            ("positionalArtifactJoinPermitted", true),
            ("decoderClosureReachesProjector", true),
            ("decoderClosureReachesExporterOrRuntime", true),
            ("artifactWritePerformed", true),
            ("sourceBindingV7Issued", true),
        ] {
            var mutation = sourceObject
            mutation[key] = value
            sourceMutations.append(mutation)
        }
        do {
            var mutation = sourceObject
            var binding = try XCTUnwrap(
                mutation["decoderTargetBinding"] as? [String: Any]
            )
            binding["direct_local_dependency_names"] = ["PrimeCore"]
            mutation["decoderTargetBinding"] = binding
            sourceMutations.append(mutation)
        }
        do {
            var mutation = sourceObject
            var binding = try XCTUnwrap(
                mutation["statisticsTargetBinding"] as? [String: Any]
            )
            binding["copied_resource_relative_paths"] = ["fixture.bin"]
            mutation["statisticsTargetBinding"] = binding
            sourceMutations.append(mutation)
        }
        for (index, mutation) in sourceMutations.enumerated() {
            let decoded = try JSONDecoder().decode(
                Source.self,
                from: JSONSerialization.data(
                    withJSONObject: mutation,
                    options: [.sortedKeys]
                )
            )
            XCTAssertThrowsError(
                try decoded.validate(),
                "source mutation \(index)"
            )
        }

        var unknownSource = sourceObject
        unknownSource["unknown_future_authority"] = true
        let unknownSourceData = try JSONSerialization.data(
            withJSONObject: unknownSource,
            options: [.sortedKeys]
        )
        XCTAssertNoThrow(
            try JSONDecoder().decode(Source.self, from: unknownSourceData)
                .validate(),
            "plain JSONDecoder ignores unknown keys"
        )
        XCTAssertThrowsError(
            try PrimeCanonicalJSON.decode(
                Source.self,
                from: unknownSourceData
            ),
            "canonical decoding must reject unknown keys"
        )

        let topologyData = try PrimeCanonicalJSON.encode(
            Topology.frozenV18
        )
        let topologyObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: topologyData)
                as? [String: Any]
        )
        let graph = try XCTUnwrap(
            topologyObject["target_graph"] as? [[String: Any]]
        )
        var topologyMutations: [[String: Any]] = []
        do {
            var mutation = topologyObject
            mutation.removeValue(
                forKey:
                    "historical_semantic_artifact_decoder_source_contract_binding"
            )
            topologyMutations.append(mutation)
        }
        do {
            var mutation = topologyObject
            var changedGraph = graph
            let index = try XCTUnwrap(
                changedGraph.firstIndex {
                    $0["target_name"] as? String
                        == Self.decoderTargetName
                }
            )
            var decoder = changedGraph[index]
            decoder["direct_local_dependency_names"] = ["PrimeCore"]
            changedGraph[index] = decoder
            mutation["target_graph"] = changedGraph
            topologyMutations.append(mutation)
        }
        for (key, value) in [
            ("execution_implemented", true),
            ("source_binding_v7_issued", true),
        ] {
            var mutation = topologyObject
            mutation[key] = value
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
