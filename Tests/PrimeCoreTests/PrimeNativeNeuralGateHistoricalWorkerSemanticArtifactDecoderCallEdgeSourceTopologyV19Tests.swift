// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
@testable import PrimeCore
import XCTest

final class
    PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactDecoderCallEdgeSourceTopologyV19Tests:
    XCTestCase
{
    private typealias Source =
        PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactDecoderCallEdgeSourceContract
    private typealias Topology =
        PrimeNativeNeuralGateTrapDisjointTopologyContract

    private static let workerTargetName =
        "PrimeNativeNeuralGateHistoricalFixtureWorker"
    private static let decoderTargetName =
        "PrimeNativeNeuralGateHistoricalSemanticArtifactDecoder"
    private static let statisticsTargetName =
        "PrimeNativeNeuralGateHistoricalStatisticsArtifactContracts"
    private static let projectorTargetName =
        "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection"
    private static let artifactTargetName =
        "PrimeNativeNeuralGateReplayArtifactContracts"
    private static let replayMechanicsTargetName =
        "PrimeNativeNeuralGateReplayMechanics"
    private static let semanticTargetName =
        "PrimeNativeNeuralGateSemanticRecordContracts"

    private static let sourceContractRelativePath =
        "Sources/PrimeCore/PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactDecoderCallEdgeSourceContract.swift"
    private static let decoderCallEdgeRelativePath =
        "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactDecoderCallEdge.swift"
    private static let historicalGuardRelativePath =
        "Tests/PrimeCoreTests/PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactProjectionCallEdgeSourceTests.swift"

    private static let sourceContractFileByteCount: UInt64 = 36_540
    private static let sourceContractFileSHA256 =
        "4d0cf2c55b51aa3f63c850afbd597ee4c8aff35549a239378843c2519d256fbf"

    // Frozen after every V19 source identity reached final bytes.
    private static let sourceContractSHA256 =
        "f8739c0d162e026522dbdc2e6902403d935ebcfd2c9d13b07704b05ea3f9dac8"
    // Frozen after the final source-contract digest was bound into V19.
    private static let topologyV19SHA256 =
        "84f07261ff86dab5836e96a2667a8d3a05b0ec597b9677d5f1bab77c2c8801ba"

    func testFrozenV19SourceContractBindsOnlyTheCompilerCheckedEdge()
        throws
    {
        let source = Source.frozenV1

        XCTAssertNoThrow(try source.validate())
        XCTAssertEqual(source.schemaVersion, 1)
        XCTAssertEqual(
            source.contractID,
            "prime_source_bound_historical_worker_semantic_artifact_decoder_call_edge_v19"
        )
        XCTAssertEqual(source.rightsHolder, "Ergentics, LLC")
        XCTAssertEqual(
            source.licenseExpression,
            "LicenseRef-Ergentics-Proprietary"
        )
        XCTAssertEqual(
            source.preservedWorkerProjectionCallEdgeV17ContractSHA256,
            "ccf2e46ffc9e980d96357980e128ecb411a5ac5f55b8e783bf611582ec32d6d3"
        )
        XCTAssertEqual(
            source.preservedSemanticArtifactDecoderV18ContractSHA256,
            "18b747001331df62115ba502a15f3bb8379a12f484176811860b191738235ae3"
        )
        XCTAssertEqual(
            source.preservedTopologyV17SHA256,
            "3a14288df628b1d44936013af44dd237e876fd1cf2b38e4ce0afd3a4c5cd2166"
        )
        XCTAssertEqual(
            source.preservedTopologyV18SHA256,
            "aa9dd4031469742fca5d0241bd329e7712d98ec81677704fbca911d5bdcf043f"
        )
        XCTAssertFalse(source.priorPinnedWorkerOrDecoderFilesChanged)
        XCTAssertEqual(source.exactWorkerSwiftSourceFileCount, 4)
        XCTAssertTrue(source.completeWorkerSourceInventoryBound)
        XCTAssertEqual(source.exactWorkerDirectLocalDependencyCount, 7)
        XCTAssertEqual(source.exactAddedWorkerDependencyCount, 1)
        XCTAssertEqual(
            source.addedWorkerDependencyTargetName,
            Self.decoderTargetName
        )
        XCTAssertTrue(source.preservedDependenciesRemainExactPrefix)
        XCTAssertTrue(
            source.callEdgeAcceptsAlreadyFormedProjectedArtifactSet
        )
        XCTAssertTrue(source.callEdgeValidatesProjectedArtifactSetFirst)
        XCTAssertTrue(source.callEdgeDerivesRoleOnlyFromProjectedArtifactSet)
        XCTAssertFalse(source.callEdgeConstructsOrInfersProjectionContext)
        XCTAssertFalse(source.callEdgeInvokesExporterOrProjector)
        XCTAssertFalse(source.callEdgeContainsFixtureMaterialization)
        XCTAssertFalse(source.callEdgeContainsProcessTransportOrIO)
        XCTAssertEqual(source.exactCanonicalLeafCount, 6)
        XCTAssertEqual(source.exactArtifactCountPerRole, 22)
        XCTAssertEqual(source.exactInvariantChunkCountPerRole, 15)
        XCTAssertEqual(source.descriptorFeedMaximumByteCount, 65_536)
        XCTAssertTrue(source.canonicalArtifactsJoinedByExactKey)
        XCTAssertFalse(source.positionalArtifactJoinPermitted)
        XCTAssertTrue(source.maintainedV18CanonicalLeafDecoderUsed)
        XCTAssertEqual(source.exactCanonicalLeafDecoderCallCount, 1)
        XCTAssertTrue(source.maintainedV18InvariantStreamDecoderUsed)
        XCTAssertEqual(
            source.exactInvariantStreamDecoderConstructionCount,
            1
        )
        XCTAssertEqual(
            source.exactTerminalSemanticArtifactSetFinishCallCount,
            1
        )
        XCTAssertTrue(source.manifestDeclaredChunkIndicesDriveIteration)
        XCTAssertTrue(source.allSemanticValidationDelegatedToV16AndV18Types)
        XCTAssertTrue(source.equalByteZipperImplemented)
        XCTAssertTrue(source.zipperFeedsGlobalBeforeCurrentChunk)
        XCTAssertTrue(source.zipperPairsEqualGlobalAndChunkByteCounts)
        XCTAssertTrue(source.zipperBoundsEveryFeedByDescriptorMaximum)
        XCTAssertTrue(source.zipperDrainsCurrentChunkRemainderBeforeChunkFinish)
        XCTAssertTrue(source.zipperFinishesEachChunkExactlyOnce)
        XCTAssertTrue(source.zipperDrainsGlobalRemainderAfterDeclaredChunks)
        XCTAssertTrue(source.zipperUsesOnlyFoundationDataIndicesAndSlices)
        XCTAssertTrue(source.foundationCodableOwnsJSONParsing)
        XCTAssertFalse(source.customJSONParserImplemented)
        XCTAssertTrue(source.maintainedV18FramedRecordReaderOwnsFrameParsing)
        XCTAssertFalse(source.customFrameParserImplemented)
        XCTAssertFalse(
            source.customFrameHeaderLengthOrRecordBoundaryMathImplemented
        )
        XCTAssertFalse(source.workerEdgeInspectsDecodedRecordPayloads)
        XCTAssertTrue(source.globalChunkRecordEqualityRemainsV18DecoderOwned)
        XCTAssertTrue(source.workerTargetMayReachDecoderTarget)
        XCTAssertTrue(source.statisticsTargetNewlyReachableThroughDecoder)
        XCTAssertFalse(source.decoderTargetMayReachWorkerTarget)
        XCTAssertTrue(source.mainRemainsUnconditionalUnavailableExit)
        XCTAssertEqual(source.unavailableExitStatus, 78)
        XCTAssertTrue(source.callEdgeCompilerBound)

        for falseClaim in [
            source.callEdgeRuntimeExercised,
            source.replayTransportIntegratedWithDecoder,
            source.workerDeclaredAsProduct,
            source.testsImportWorker,
            source.testsInvokeWorkerCallEdgeOrPublicDecoderEntryPoint,
            source.workerRequestHandlingEnabled,
            source.workerSealed,
            source.workerLaunched,
            source.workerExecuted,
            source.fixtureMaterialized,
            source.exporterRuntimeInvocationObserved,
            source.projectorRuntimeInvocationObserved,
            source.decoderRuntimeInvocationObserved,
            source.projectedArtifactsHistoricallyObserved,
            source.decodedArtifactsHistoricallyObserved,
            source.historicalGateExecuted,
            source.modelExecutionObserved,
            source.artifactFilesystemReadPerformed,
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
        XCTAssertTrue(
            source.authorityStatement.contains(
                "Compilation proves only the typed call edge"
            )
        )
    }

    func testFrozenV19SourceCanonicalRoundTripAndPinnedHash()
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
        XCTAssertEqual(observed, PrimeSHA256.hexDigest(of: canonical))
        XCTAssertEqual(observed, Self.sourceContractSHA256)
    }

    func testAllCurrentLiveIdentitiesMatchAndV17GuardDriftIsTransparent()
        throws
    {
        let source = Source.frozenV1
        let sourceContractBytes = try checkedInData(
            Self.sourceContractRelativePath
        )
        XCTAssertEqual(
            UInt64(sourceContractBytes.count),
            Self.sourceContractFileByteCount
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: sourceContractBytes),
            Self.sourceContractFileSHA256
        )

        for identity in [
            source.primaryWorkerSource,
            source.preservedExporterCallEdgeSource,
            source.preservedProjectionCallEdgeSource,
            source.decoderCallEdgeSource,
            source.fixtureResource,
            source.currentAdditivelyEvolvedHistoricalGuardSource,
        ] {
            let bytes = try checkedInData(identity.primeRelativePath)
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

        XCTAssertEqual(
            source.historicalV17GuardSource.primeRelativePath,
            source.currentAdditivelyEvolvedHistoricalGuardSource
                .primeRelativePath
        )
        XCTAssertEqual(source.historicalV17GuardSource.byteCount, 12_467)
        XCTAssertEqual(
            source.historicalV17GuardSource.sha256,
            "ff03b3a143ebc748dadf6d9a337d68753add478811395d78d27e5654c805a8f4"
        )
        XCTAssertEqual(
            source.currentAdditivelyEvolvedHistoricalGuardSource.byteCount,
            13_182
        )
        XCTAssertEqual(
            source.currentAdditivelyEvolvedHistoricalGuardSource.sha256,
            "abba5e6dc188dfdebe5f5e6f519199c52692bd8e10b2cabbb68f0e44ac976b39"
        )
        XCTAssertNotEqual(
            source.historicalV17GuardSource.byteCount,
            source.currentAdditivelyEvolvedHistoricalGuardSource.byteCount
        )
        XCTAssertNotEqual(
            source.historicalV17GuardSource.sha256,
            source.currentAdditivelyEvolvedHistoricalGuardSource.sha256
        )
        XCTAssertTrue(source.historicalGuardEvolvedAdditively)
        XCTAssertTrue(source.historicalGuardRetainsFrozenV17IdentityAssertions)
        XCTAssertTrue(source.historicalGuardAddsOnlyV19ContinuationAssertions)

        let guardSource = try checkedInString(
            Self.historicalGuardRelativePath
        )
        XCTAssertTrue(
            guardSource.contains(Self.decoderCallEdgeRelativePath)
        )

        let workerDirectory = repositoryRoot
            .appendingPathComponent("Sources")
            .appendingPathComponent(Self.workerTargetName)
        XCTAssertEqual(
            try recursiveRegularFilePaths(in: workerDirectory),
            [
                source.fixtureResource.primeRelativePath,
                source.preservedExporterCallEdgeSource.primeRelativePath,
                source.primaryWorkerSource.primeRelativePath,
                source.decoderCallEdgeSource.primeRelativePath,
                source.preservedProjectionCallEdgeSource.primeRelativePath,
            ].sorted()
        )
    }

    func testWorkerDecoderEdgeIsExactBoundedZipperWithNoForbiddenAPIs()
        throws
    {
        let sourceContract = Source.frozenV1
        let source = try checkedInString(
            Self.decoderCallEdgeRelativePath
        )
        let importLines = source.split(
            separator: "\n",
            omittingEmptySubsequences: false
        ).map {
            $0.trimmingCharacters(in: .whitespaces)
        }.filter {
            $0.hasPrefix("import ")
        }
        XCTAssertEqual(
            importLines,
            sourceContract.exactCallEdgeImportNames.map { "import \($0)" }
        )

        let compact = source.filter { !$0.isWhitespace }
        let compactSignature =
            sourceContract.callEdgeNormalizedSignature.filter {
                !$0.isWhitespace
            }
        XCTAssertTrue(compact.contains(compactSignature))
        XCTAssertTrue(compact.contains("tryprojectedArtifacts.validate()"))
        XCTAssertTrue(
            compact.contains("letrole=projectedArtifacts.invocationRole")
        )
        XCTAssertEqual(
            occurrenceCount(
                of:
                    "PrimeNativeNeuralGateHistoricalSemanticArtifactDecoder.decodeCanonicalLeaves(",
                in: compact
            ),
            1
        )
        XCTAssertEqual(
            occurrenceCount(
                of:
                    "PrimeNativeNeuralGateHistoricalInvariantArtifactStreamDecoder(decodedLeaves:",
                in: compact
            ),
            1
        )
        XCTAssertEqual(
            occurrenceCount(
                of: "streamDecoder.finishSemanticArtifactSet()",
                in: compact
            ),
            1
        )
        for key in sourceContract.exactCanonicalLeafKeyCaseNames {
            XCTAssertEqual(
                occurrenceCount(of: ".\(key)(role)", in: compact),
                2,
                key
            )
        }
        XCTAssertTrue(
            compact.contains(
                "letfeedByteCount=min(maximumFeedByteCount,pairedRemainingByteCount)"
            )
        )
        XCTAssertTrue(
            compact.contains(
                "letpairedRemainingByteCount=min(globalBytes.distance(from:globalOffset,to:globalBytes.endIndex),chunkBytes.distance(from:chunkOffset,to:chunkBytes.endIndex))"
            )
        )
        XCTAssertTrue(
            compact.contains(
                "forordinalindecodedLeaves.invariantManifest.manifest.chunks.indices"
            )
        )
        XCTAssertEqual(
            occurrenceCount(
                of: "streamDecoder.finishCurrentChunk()",
                in: compact
            ),
            1
        )
        let pairedLoopStart = try XCTUnwrap(
            compact.range(
                of:
                    "whileglobalOffset<globalBytes.endIndex,chunkOffset<chunkBytes.endIndex"
            )
        ).lowerBound
        let globalFeed = try XCTUnwrap(
            compact.range(
                of: "key:.invariantRecordsGlobal(role)",
                range: pairedLoopStart ..< compact.endIndex
            )
        ).lowerBound
        let chunkFeed = try XCTUnwrap(
            compact.range(
                of: "key:.invariantChunk(role,UInt32(ordinal))",
                range: pairedLoopStart ..< compact.endIndex
            )
        ).lowerBound
        XCTAssertLessThan(globalFeed, chunkFeed)

        for forbidden in [
            "JSONSerialization",
            "JSONDecoder",
            "JSONEncoder",
            "PrimeNativeNeuralGateInvariantFramedRecordReader",
            "globalMagic",
            "chunkMagic",
            "frameHeader",
            "recordBoundary",
            "UnicodeScalar",
            "Bundle.",
            "FileManager",
            "FileHandle",
            "InputStream",
            "OutputStream",
            "Process(",
            "CommandLine",
            "URLSession",
            "NWConnection",
            "posix_spawn",
            "execve(",
            "system(",
            "popen(",
            "createFile(",
            "write(to:",
            "openat(",
            "fopen(",
            "mmap(",
            "try!",
            "fatalError(",
            "precondition(",
            ".export(",
            ".project(",
            ".publish(",
            ".seal(",
            ".launch(",
            "Receipt",
            "sourceBindingV7",
        ] {
            XCTAssertFalse(source.contains(forbidden), forbidden)
        }
    }

    func testPackagePreservesDependencyPrefixAndAddsOnlyDecoderWithoutProduct()
        throws
    {
        let source = Source.frozenV1
        let package = try checkedInString("Package.swift")
            .filter { !$0.isWhitespace }
        let workerDeclaration =
            #".executableTarget(name:"PrimeNativeNeuralGateHistoricalFixtureWorker",dependencies:["PrimeCore","ErgenticsPrimeRuntime","PrimeNativeNeuralGateHistoricalReplayMechanics","PrimeNativeNeuralGateReplayTransport","PrimeNativeNeuralGateHistoricalEvidenceExportMechanics","PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection","PrimeNativeNeuralGateHistoricalSemanticArtifactDecoder",],resources:[.copy("HistoricalFixtureEvidence"),])"#
        XCTAssertEqual(
            package.components(separatedBy: workerDeclaration).count - 1,
            1
        )
        XCTAssertEqual(
            source.workerDirectLocalDependencyNames,
            source.preservedWorkerDirectLocalDependencyNames
                + [Self.decoderTargetName]
        )
        XCTAssertEqual(source.workerDirectLocalDependencyNames.count, 7)

        let targetsStart = try XCTUnwrap(
            package.range(of: "targets:[")
        ).lowerBound
        let productRegion = package[..<targetsStart]
        XCTAssertFalse(productRegion.contains(Self.workerTargetName))
        XCTAssertFalse(
            package.contains(
                #".library(name:"PrimeNativeNeuralGateHistoricalFixtureWorker""#
            )
        )
        XCTAssertFalse(
            package.contains(
                #".executable(name:"PrimeNativeNeuralGateHistoricalFixtureWorker""#
            )
        )
        XCTAssertTrue(
            package.contains(
                #".target(name:"PrimeNativeNeuralGateHistoricalSemanticArtifactDecoder",dependencies:["PrimeNativeNeuralGateHistoricalStatisticsArtifactContracts","PrimeNativeNeuralGateReplayArtifactContracts","PrimeNativeNeuralGateReplayMechanics","PrimeNativeNeuralGateSemanticRecordContracts",])"#
            )
        )
    }

    func testFrozenV19TopologyBindsSourceWithoutClaimingExecution()
        throws
    {
        let source = Source.frozenV1
        let topology = Topology.frozenV19

        XCTAssertNoThrow(try topology.validate())
        XCTAssertEqual(topology.schemaVersion, 19)
        XCTAssertEqual(
            topology.contractID,
            "prime_stage_b_historical_worker_semantic_artifact_decoder_call_edge_source_topology_v19"
        )
        XCTAssertEqual(
            topology
                .historicalWorkerSemanticArtifactDecoderCallEdgeSourceContractID,
            source.contractID
        )
        XCTAssertEqual(
            topology
                .historicalWorkerSemanticArtifactDecoderCallEdgeSourceContractSHA256,
            try source.contentSHA256()
        )
        XCTAssertEqual(
            topology.nextImplementationPrerequisite,
            source.nextImplementationPrerequisite
        )
        XCTAssertTrue(
            topology.packageCaptureAuthority.contains(
                try source.contentSHA256()
            )
        )
        XCTAssertEqual(topology.status, .plannedNotMaterialized)
        XCTAssertFalse(topology.executionImplemented)
        XCTAssertFalse(topology.sourceBindingV7Issued)
        XCTAssertTrue(topology.historicalContractsPreserved)
        XCTAssertTrue(
            topology.authorityStatement.contains(
                "Compilation proves only the typed call edge"
            )
        )
    }

    func testFrozenV19ChangesOnlyWorkerTargetAndAppendsDecoder()
        throws
    {
        let previous = Topology.frozenV18
        let topology = Topology.frozenV19
        let previousByName = Dictionary(
            uniqueKeysWithValues:
                previous.targetGraph.map { ($0.targetName, $0) }
        )
        let topologyByName = Dictionary(
            uniqueKeysWithValues:
                topology.targetGraph.map { ($0.targetName, $0) }
        )

        XCTAssertEqual(topology.targetGraph.count, previous.targetGraph.count)
        XCTAssertEqual(Set(topologyByName.keys), Set(previousByName.keys))
        for (name, previousTarget) in previousByName {
            let target = try XCTUnwrap(topologyByName[name], name)
            if name == Self.workerTargetName {
                XCTAssertEqual(
                    target.directLocalDependencyNames,
                    previousTarget.directLocalDependencyNames
                        + [Self.decoderTargetName]
                )
                XCTAssertEqual(
                    Array(target.directLocalDependencyNames.dropLast()),
                    previousTarget.directLocalDependencyNames
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
    }

    func testV19RemovesOnlyDecoderAndStatisticsWorkerProhibitions()
        throws
    {
        let previous = Topology.frozenV18
        let topology = Topology.frozenV19
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
            topology.forbiddenReachability.count,
            previous.forbiddenReachability.count
        )
        XCTAssertEqual(Set(topologyByName.keys), Set(previousByName.keys))
        for (name, previousRule) in previousByName {
            let rule = try XCTUnwrap(topologyByName[name], name)
            if name == Self.workerTargetName {
                XCTAssertTrue(
                    previousRule.forbiddenReachableTargetNames
                        .contains(Self.decoderTargetName)
                )
                XCTAssertTrue(
                    previousRule.forbiddenReachableTargetNames
                        .contains(Self.statisticsTargetName)
                )
                XCTAssertEqual(
                    rule.forbiddenReachableTargetNames,
                    previousRule.forbiddenReachableTargetNames.filter {
                        $0 != Self.decoderTargetName
                            && $0 != Self.statisticsTargetName
                    }
                )
            } else {
                XCTAssertEqual(rule, previousRule, name)
            }
        }
    }

    func testDecoderClosureRemainsProductFreeAndWorkerDisjoint()
        throws
    {
        let topology = Topology.frozenV19
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
        XCTAssertEqual(
            try topology.transitiveLocalTargetNames(
                reachableFrom: Self.statisticsTargetName
            ),
            [Self.artifactTargetName]
        )
        let decoderClosure = Set(
            try topology.transitiveLocalTargetNames(
                reachableFrom: Self.decoderTargetName
            )
        )
        for forbidden in [
            Self.workerTargetName,
            Self.projectorTargetName,
            "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics",
            "PrimeNativeNeuralGateHistoricalReplayMechanics",
            "PrimeNativeNeuralGateReplayTransport",
            "ErgenticsPrimeRuntime",
            "PrimeCore",
            "PrimeNativeNeuralGateCorrectedMutationSurfaceContracts",
            "PrimeNativeNeuralGateCorrectedMutationProducer",
            "PrimeNativeNeuralGateCorrectedMutationDetector",
            "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
            "PrimeNativeNeuralGateTerminalReceiptOwnershipContracts",
        ] {
            XCTAssertFalse(decoderClosure.contains(forbidden), forbidden)
        }
        let workerClosure = Set(
            try topology.transitiveLocalTargetNames(
                reachableFrom: Self.workerTargetName
            )
        )
        XCTAssertTrue(workerClosure.contains(Self.decoderTargetName))
        XCTAssertTrue(workerClosure.contains(Self.statisticsTargetName))

        let decoderRule = try XCTUnwrap(
            topology.forbiddenReachability.first {
                $0.targetName == Self.decoderTargetName
            }
        )
        XCTAssertTrue(
            decoderRule.forbiddenReachableTargetNames
                .contains(Self.workerTargetName)
        )
        XCTAssertTrue(
            decoderRule.forbiddenReachableTargetNames
                .contains(Self.projectorTargetName)
        )
    }

    func testAllV1ThroughV18CanonicalTopologyHashesRemainExact()
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
            (.frozenV18, "aa9dd4031469742fca5d0241bd329e7712d98ec81677704fbca911d5bdcf043f"),
        ]

        for (topology, sha256) in expected {
            XCTAssertNoThrow(try topology.validate())
            XCTAssertEqual(try topology.contentSHA256(), sha256)
            XCTAssertNil(
                topology
                    .historicalWorkerSemanticArtifactDecoderCallEdgeSourceContractBinding
            )
        }
    }

    func testFrozenV19TopologyCanonicalRoundTripAndPinnedHash()
        throws
    {
        let topology = Topology.frozenV19
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
        XCTAssertEqual(observed, PrimeSHA256.hexDigest(of: canonical))
        XCTAssertEqual(observed, Self.topologyV19SHA256)
    }

    func testSourceAndTopologyMutationsFailClosed()
        throws
    {
        let sourceData = try PrimeCanonicalJSON.encode(Source.frozenV1)
        let sourceObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: sourceData)
                as? [String: Any]
        )
        var sourceMutations: [[String: Any]] = []
        for (key, value): (String, Any) in [
            ("contractID", "drift"),
            ("callEdgeRuntimeExercised", true),
            ("workerExecuted", true),
            ("customFrameParserImplemented", true),
            ("zipperPairsEqualGlobalAndChunkByteCounts", false),
            ("artifactWritePerformed", true),
            ("sourceBindingV7Issued", true),
        ] {
            var mutation = sourceObject
            mutation[key] = value
            sourceMutations.append(mutation)
        }
        do {
            var mutation = sourceObject
            var identity = try XCTUnwrap(
                mutation["decoderCallEdgeSource"] as? [String: Any]
            )
            identity["sha256"] = String(repeating: "f", count: 64)
            mutation["decoderCallEdgeSource"] = identity
            sourceMutations.append(mutation)
        }
        for (index, object) in sourceMutations.enumerated() {
            let decoded = try JSONDecoder().decode(
                Source.self,
                from: JSONSerialization.data(
                    withJSONObject: object,
                    options: [.sortedKeys]
                )
            )
            XCTAssertThrowsError(
                try decoded.validate(),
                "source mutation \(index)"
            )
        }

        var unknownSourceObject = sourceObject
        unknownSourceObject["unknownFutureAuthority"] = true
        let unknownSourceData = try JSONSerialization.data(
            withJSONObject: unknownSourceObject,
            options: [.sortedKeys]
        )
        let plainDecoded = try JSONDecoder().decode(
            Source.self,
            from: unknownSourceData
        )
        XCTAssertNoThrow(try plainDecoded.validate())
        XCTAssertThrowsError(
            try PrimeCanonicalJSON.decode(
                Source.self,
                from: unknownSourceData
            )
        )

        let topologyData = try PrimeCanonicalJSON.encode(Topology.frozenV19)
        let topologyObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: topologyData)
                as? [String: Any]
        )
        let bindingKey =
            "historical_worker_semantic_artifact_decoder_call_edge_source_contract_binding"
        let binding = try XCTUnwrap(
            topologyObject[bindingKey] as? [String: Any]
        )
        let targetGraph = try XCTUnwrap(
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
            var drift = binding
            drift["content_sha256"] = String(repeating: "f", count: 64)
            mutation[bindingKey] = drift
            topologyMutations.append(mutation)
        }
        do {
            var mutation = topologyObject
            var graph = targetGraph
            let workerIndex = try XCTUnwrap(
                graph.firstIndex {
                    $0["target_name"] as? String == Self.workerTargetName
                }
            )
            var worker = graph[workerIndex]
            worker["direct_local_dependency_names"] = ["PrimeCore"]
            graph[workerIndex] = worker
            mutation["target_graph"] = graph
            topologyMutations.append(mutation)
        }
        do {
            var mutation = topologyObject
            mutation["execution_implemented"] = true
            topologyMutations.append(mutation)
        }
        for (index, object) in topologyMutations.enumerated() {
            let decoded = try JSONDecoder().decode(
                Topology.self,
                from: JSONSerialization.data(
                    withJSONObject: object,
                    options: [.sortedKeys]
                )
            )
            XCTAssertThrowsError(
                try decoded.validate(),
                "topology mutation \(index)"
            )
        }
    }

    private func occurrenceCount(
        of needle: String,
        in haystack: String
    ) -> Int {
        guard !needle.isEmpty else { return 0 }
        var count = 0
        var searchStart = haystack.startIndex
        while let range = haystack.range(
            of: needle,
            range: searchStart ..< haystack.endIndex
        ) {
            count += 1
            searchStart = range.upperBound
        }
        return count
    }

    private func checkedInData(
        _ relativePath: String
    ) throws -> Data {
        try Data(
            contentsOf:
                repositoryRoot.appendingPathComponent(relativePath)
        )
    }

    private func checkedInString(
        _ relativePath: String
    ) throws -> String {
        try String(
            contentsOf:
                repositoryRoot.appendingPathComponent(relativePath),
            encoding: .utf8
        )
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
