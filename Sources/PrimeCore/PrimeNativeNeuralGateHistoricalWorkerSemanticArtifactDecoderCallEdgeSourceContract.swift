// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

public enum
    PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactDecoderCallEdgeSourceContractError:
    Error,
    Equatable,
    Sendable
{
    case invalidFrozenContract
}

public struct
    PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactDecoderCallEdgeSourceIdentity:
    Codable,
    Equatable,
    Sendable
{
    public let primeRelativePath: String
    public let byteCount: UInt64
    public let sha256: String

    fileprivate init(
        primeRelativePath: String,
        byteCount: UInt64,
        sha256: String
    ) {
        self.primeRelativePath = primeRelativePath
        self.byteCount = byteCount
        self.sha256 = sha256
    }

    fileprivate func validate() -> Bool {
        (primeRelativePath.hasPrefix("Sources/")
            || primeRelativePath.hasPrefix("Tests/"))
            && !primeRelativePath.contains("..")
            && !primeRelativePath.contains("\\")
            && byteCount > 0
            && sha256 != String(repeating: "0", count: 64)
            && sha256.utf8.count == 64
            && sha256.utf8.allSatisfy {
                ($0 >= 48 && $0 <= 57)
                    || ($0 >= 97 && $0 <= 102)
            }
    }

    private enum CodingKeys: String, CodingKey {
        case primeRelativePath = "prime_relative_path"
        case byteCount = "byte_count"
        case sha256
    }
}

/// V19 source and package boundary for the unavailable historical worker's
/// private projected-artifact-set-to-decoder call edge.
///
/// V19 preserves the exact V11, V14, and V17 worker sources and appends one
/// fourth source plus the complete V18 decoder as the seventh direct worker
/// dependency. The new private cross-file member accepts only an already-
/// formed V16 projected artifact set. It uses exact keyed lookups and the
/// maintained V18 decoder, including a bounded global-first equal-byte zipper;
/// it implements no JSON parser, frame parser, frame-header arithmetic, I/O,
/// transport, execution, publication, or authority-bearing behavior.
public struct
    PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactDecoderCallEdgeSourceContract:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let contractID: String
    public let rightsHolder: String
    public let licenseExpression: String

    public let preservedWorkerProjectionCallEdgeV17ContractID: String
    public let preservedWorkerProjectionCallEdgeV17ContractSHA256: String
    public let preservedSemanticArtifactDecoderV18ContractID: String
    public let preservedSemanticArtifactDecoderV18ContractSHA256: String
    public let preservedTopologyV17ID: String
    public let preservedTopologyV17SHA256: String
    public let preservedTopologyV18ID: String
    public let preservedTopologyV18SHA256: String
    public let priorPinnedWorkerOrDecoderFilesChanged: Bool

    public let workerTargetName: String
    public let primaryWorkerSource:
        PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactDecoderCallEdgeSourceIdentity
    public let preservedExporterCallEdgeSource:
        PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactDecoderCallEdgeSourceIdentity
    public let preservedProjectionCallEdgeSource:
        PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactDecoderCallEdgeSourceIdentity
    public let decoderCallEdgeSource:
        PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactDecoderCallEdgeSourceIdentity
    public let fixtureResource:
        PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactDecoderCallEdgeSourceIdentity
    public let historicalV17GuardSource:
        PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactDecoderCallEdgeSourceIdentity
    public let currentAdditivelyEvolvedHistoricalGuardSource:
        PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactDecoderCallEdgeSourceIdentity
    public let preservedV17WorkerSwiftSourceRelativePaths: [String]
    public let orderedWorkerSwiftSourceRelativePaths: [String]
    public let exactWorkerSwiftSourceFileCount: Int
    public let completeWorkerSourceInventoryBound: Bool
    public let primaryWorkerSourceChanged: Bool
    public let preservedExporterCallEdgeSourceChanged: Bool
    public let preservedProjectionCallEdgeSourceChanged: Bool
    public let fixtureResourceChanged: Bool
    public let historicalGuardPathChanged: Bool
    public let historicalGuardEvolvedAdditively: Bool
    public let historicalGuardRetainsFrozenV17IdentityAssertions: Bool
    public let historicalGuardAddsOnlyV19ContinuationAssertions: Bool

    public let preservedWorkerDirectLocalDependencyNames: [String]
    public let workerDirectLocalDependencyNames: [String]
    public let exactWorkerDirectLocalDependencyCount: Int
    public let exactAddedWorkerDependencyCount: Int
    public let addedWorkerDependencyTargetName: String
    public let preservedDependenciesRemainExactPrefix: Bool
    public let projectionTargetSourceOrDependenciesChanged: Bool
    public let decoderTargetSourceOrDependenciesChanged: Bool
    public let statisticsTargetSourceOrDependenciesChanged: Bool
    public let exporterTargetSourceOrDependenciesChanged: Bool

    public let callEdgeEnclosingTypeName: String
    public let callEdgeMethodName: String
    public let callEdgeNormalizedSignature: String
    public let callEdgeAccessLevel: String
    public let callEdgeDeclaredInMainSource: Bool
    public let callEdgeDeclaredInExporterEdgeSource: Bool
    public let callEdgeDeclaredInProjectionEdgeSource: Bool
    public let callEdgeInputLabel: String
    public let callEdgeInputSwiftTypeName: String
    public let callEdgeOutputSwiftTypeName: String
    public let exactCallEdgeImportNames: [String]
    public let callEdgeAcceptsAlreadyFormedProjectedArtifactSet: Bool
    public let callEdgeValidatesProjectedArtifactSetFirst: Bool
    public let callEdgeDerivesRoleOnlyFromProjectedArtifactSet: Bool
    public let callEdgeConstructsOrInfersProjectionContext: Bool
    public let callEdgeInvokesExporterOrProjector: Bool
    public let callEdgeContainsFixtureMaterialization: Bool
    public let callEdgeContainsProcessTransportOrIO: Bool

    public let exactCanonicalLeafCount: Int
    public let exactCanonicalLeafKeyCaseNames: [String]
    public let exactArtifactCountPerRole: Int
    public let exactInvariantChunkCountPerRole: Int
    public let descriptorFeedMaximumByteCount: Int
    public let canonicalArtifactsJoinedByExactKey: Bool
    public let positionalArtifactJoinPermitted: Bool
    public let maintainedV18CanonicalLeafDecoderUsed: Bool
    public let exactCanonicalLeafDecoderCallCount: Int
    public let maintainedV18InvariantStreamDecoderUsed: Bool
    public let exactInvariantStreamDecoderConstructionCount: Int
    public let exactTerminalSemanticArtifactSetFinishCallCount: Int
    public let manifestDeclaredChunkIndicesDriveIteration: Bool
    public let allSemanticValidationDelegatedToV16AndV18Types: Bool

    public let equalByteZipperImplemented: Bool
    public let zipperFeedsGlobalBeforeCurrentChunk: Bool
    public let zipperPairsEqualGlobalAndChunkByteCounts: Bool
    public let zipperFeedByteCountExpression: String
    public let zipperBoundsEveryFeedByDescriptorMaximum: Bool
    public let zipperDrainsCurrentChunkRemainderBeforeChunkFinish: Bool
    public let zipperFinishesEachChunkExactlyOnce: Bool
    public let zipperDrainsGlobalRemainderAfterDeclaredChunks: Bool
    public let zipperUsesOnlyFoundationDataIndicesAndSlices: Bool
    public let foundationCodableOwnsJSONParsing: Bool
    public let customJSONParserImplemented: Bool
    public let maintainedV18FramedRecordReaderOwnsFrameParsing: Bool
    public let customFrameParserImplemented: Bool
    public let customFrameHeaderLengthOrRecordBoundaryMathImplemented: Bool
    public let workerEdgeInspectsDecodedRecordPayloads: Bool
    public let globalChunkRecordEqualityRemainsV18DecoderOwned: Bool

    public let workerTargetMayReachDecoderTarget: Bool
    public let statisticsTargetNewlyReachableThroughDecoder: Bool
    public let decoderTargetMayReachWorkerTarget: Bool
    public let mainCanNameOrReachDecoderCallEdge: Bool
    public let preservedExporterCallEdgeCanNameOrReachDecoderCallEdge: Bool
    public let preservedProjectionCallEdgeCanNameOrReachDecoderCallEdge: Bool
    public let mainRemainsUnconditionalUnavailableExit: Bool
    public let unavailableExitStatus: Int32
    public let callEdgeCompilerBound: Bool
    public let callEdgeRuntimeExercised: Bool
    public let replayTransportIntegratedWithDecoder: Bool
    public let workerTargetRemainsExecutable: Bool
    public let workerDeclaredAsProduct: Bool
    public let packageGraphChanged: Bool
    public let workerSourceInventoryChanged: Bool
    public let testsImportWorker: Bool
    public let testsInvokeWorkerCallEdgeOrPublicDecoderEntryPoint: Bool

    public let workerRequestHandlingEnabled: Bool
    public let workerSealed: Bool
    public let workerLaunched: Bool
    public let workerExecuted: Bool
    public let fixtureMaterialized: Bool
    public let exporterRuntimeInvocationObserved: Bool
    public let projectorRuntimeInvocationObserved: Bool
    public let decoderRuntimeInvocationObserved: Bool
    public let projectedArtifactsHistoricallyObserved: Bool
    public let decodedArtifactsHistoricallyObserved: Bool
    public let historicalGateExecuted: Bool
    public let modelExecutionObserved: Bool
    public let artifactFilesystemReadPerformed: Bool
    public let artifactWritePerformed: Bool
    public let evidencePublished: Bool
    public let durablePublicationObserved: Bool
    public let independentDetectionEstablished: Bool
    public let distinctImplementationFamiliesEstablished: Bool
    public let agentContractKitFourTierAuditPerformed: Bool
    public let mechanicsPassAuthorized: Bool
    public let terminalReceiptAuthorized: Bool
    public let sourceBindingV7Issued: Bool
    public let scientificAuthorityAuthorized: Bool
    public let productAuthorityAuthorized: Bool
    public let nextImplementationPrerequisite: String
    public let authorityStatement: String

    public static let frozenV1: Self = {
        let decoderTargetName =
            "PrimeNativeNeuralGateHistoricalSemanticArtifactDecoder"
        let primaryWorkerPath =
            "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalFixtureWorker.swift"
        let exporterEdgePath =
            "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalEvidenceExportCallEdge.swift"
        let projectionEdgePath =
            "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactProjectionCallEdge.swift"
        let decoderEdgePath =
            "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactDecoderCallEdge.swift"
        let historicalGuardPath =
            "Tests/PrimeCoreTests/PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactProjectionCallEdgeSourceTests.swift"
        let preservedDependencies = [
            "PrimeCore",
            "ErgenticsPrimeRuntime",
            "PrimeNativeNeuralGateHistoricalReplayMechanics",
            "PrimeNativeNeuralGateReplayTransport",
            "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics",
            "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection",
        ]

        return Self(
            schemaVersion: 1,
            contractID:
                "prime_source_bound_historical_worker_semantic_artifact_decoder_call_edge_v19",
            rightsHolder: "Ergentics, LLC",
            licenseExpression: "LicenseRef-Ergentics-Proprietary",
            preservedWorkerProjectionCallEdgeV17ContractID:
                "prime_source_bound_historical_worker_semantic_artifact_projection_call_edge_v17",
            preservedWorkerProjectionCallEdgeV17ContractSHA256:
                "ccf2e46ffc9e980d96357980e128ecb411a5ac5f55b8e783bf611582ec32d6d3",
            preservedSemanticArtifactDecoderV18ContractID:
                "prime_source_bound_historical_semantic_artifact_decoder_v18",
            preservedSemanticArtifactDecoderV18ContractSHA256:
                "18b747001331df62115ba502a15f3bb8379a12f484176811860b191738235ae3",
            preservedTopologyV17ID:
                "prime_stage_b_historical_worker_semantic_artifact_projection_call_edge_source_topology_v17",
            preservedTopologyV17SHA256:
                "3a14288df628b1d44936013af44dd237e876fd1cf2b38e4ce0afd3a4c5cd2166",
            preservedTopologyV18ID:
                "prime_stage_b_historical_semantic_artifact_decoder_source_topology_v18",
            preservedTopologyV18SHA256:
                "aa9dd4031469742fca5d0241bd329e7712d98ec81677704fbca911d5bdcf043f",
            priorPinnedWorkerOrDecoderFilesChanged: false,
            workerTargetName:
                "PrimeNativeNeuralGateHistoricalFixtureWorker",
            primaryWorkerSource: .init(
                primeRelativePath: primaryWorkerPath,
                byteCount: 2_298,
                sha256:
                    "9f62827d4c35e98fb01f9984b1c227cb681dd42ac4c26147a86e9429958545df"
            ),
            preservedExporterCallEdgeSource: .init(
                primeRelativePath: exporterEdgePath,
                byteCount: 1_512,
                sha256:
                    "d3ac7fcddd43844e92b61764c458dfce6291471fd465b1bb52f5186814e10319"
            ),
            preservedProjectionCallEdgeSource: .init(
                primeRelativePath: projectionEdgePath,
                byteCount: 1_227,
                sha256:
                    "dce631bd4749a05d8f04323b51c4da37e5ef67df14b950f1e5eee1d1565e0964"
            ),
            decoderCallEdgeSource: .init(
                primeRelativePath: decoderEdgePath,
                byteCount: 7_050,
                sha256:
                    "b8a4aaf4d9328df657f8fd62c3425b04ee2a293fb6dc75df19913635ef2f4cca"
            ),
            fixtureResource: .init(
                primeRelativePath:
                    "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/HistoricalFixtureEvidence/Package.resolved",
                byteCount: 1_949,
                sha256:
                    "cf1ba313dcb0c959e80ba09d6cbe0c56bcd921523bda5cec2c682c8ae7696ab3"
            ),
            historicalV17GuardSource: .init(
                primeRelativePath: historicalGuardPath,
                byteCount: 12_467,
                sha256:
                    "ff03b3a143ebc748dadf6d9a337d68753add478811395d78d27e5654c805a8f4"
            ),
            currentAdditivelyEvolvedHistoricalGuardSource: .init(
                primeRelativePath: historicalGuardPath,
                byteCount: 13_182,
                sha256:
                    "abba5e6dc188dfdebe5f5e6f519199c52692bd8e10b2cabbb68f0e44ac976b39"
            ),
            preservedV17WorkerSwiftSourceRelativePaths: [
                exporterEdgePath,
                primaryWorkerPath,
                projectionEdgePath,
            ],
            orderedWorkerSwiftSourceRelativePaths: [
                exporterEdgePath,
                primaryWorkerPath,
                decoderEdgePath,
                projectionEdgePath,
            ],
            exactWorkerSwiftSourceFileCount: 4,
            completeWorkerSourceInventoryBound: true,
            primaryWorkerSourceChanged: false,
            preservedExporterCallEdgeSourceChanged: false,
            preservedProjectionCallEdgeSourceChanged: false,
            fixtureResourceChanged: false,
            historicalGuardPathChanged: false,
            historicalGuardEvolvedAdditively: true,
            historicalGuardRetainsFrozenV17IdentityAssertions: true,
            historicalGuardAddsOnlyV19ContinuationAssertions: true,
            preservedWorkerDirectLocalDependencyNames:
                preservedDependencies,
            workerDirectLocalDependencyNames:
                preservedDependencies + [decoderTargetName],
            exactWorkerDirectLocalDependencyCount: 7,
            exactAddedWorkerDependencyCount: 1,
            addedWorkerDependencyTargetName: decoderTargetName,
            preservedDependenciesRemainExactPrefix: true,
            projectionTargetSourceOrDependenciesChanged: false,
            decoderTargetSourceOrDependenciesChanged: false,
            statisticsTargetSourceOrDependenciesChanged: false,
            exporterTargetSourceOrDependenciesChanged: false,
            callEdgeEnclosingTypeName:
                "PrimeNativeNeuralGateHistoricalFixtureWorker",
            callEdgeMethodName:
                "sourceBoundHistoricalSemanticArtifactDecoderCallEdge",
            callEdgeNormalizedSignature:
                "private static func sourceBoundHistoricalSemanticArtifactDecoderCallEdge(projectedArtifacts: PrimeNativeNeuralGateHistoricalProjectedArtifactSet) throws -> PrimeNativeNeuralGateHistoricalDecodedSemanticArtifactSet",
            callEdgeAccessLevel: "private",
            callEdgeDeclaredInMainSource: false,
            callEdgeDeclaredInExporterEdgeSource: false,
            callEdgeDeclaredInProjectionEdgeSource: false,
            callEdgeInputLabel: "projectedArtifacts",
            callEdgeInputSwiftTypeName:
                "PrimeNativeNeuralGateHistoricalProjectedArtifactSet",
            callEdgeOutputSwiftTypeName:
                "PrimeNativeNeuralGateHistoricalDecodedSemanticArtifactSet",
            exactCallEdgeImportNames: [
                "Foundation",
                "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection",
                decoderTargetName,
            ],
            callEdgeAcceptsAlreadyFormedProjectedArtifactSet: true,
            callEdgeValidatesProjectedArtifactSetFirst: true,
            callEdgeDerivesRoleOnlyFromProjectedArtifactSet: true,
            callEdgeConstructsOrInfersProjectionContext: false,
            callEdgeInvokesExporterOrProjector: false,
            callEdgeContainsFixtureMaterialization: false,
            callEdgeContainsProcessTransportOrIO: false,
            exactCanonicalLeafCount: 6,
            exactCanonicalLeafKeyCaseNames: [
                "materialIdentityManifest",
                "gateObservation",
                "invariantRecordsManifest",
                "fingerprintObservation",
                "mutationObservations",
                "statisticsVerdictObservation",
            ],
            exactArtifactCountPerRole: 22,
            exactInvariantChunkCountPerRole: 15,
            descriptorFeedMaximumByteCount: 65_536,
            canonicalArtifactsJoinedByExactKey: true,
            positionalArtifactJoinPermitted: false,
            maintainedV18CanonicalLeafDecoderUsed: true,
            exactCanonicalLeafDecoderCallCount: 1,
            maintainedV18InvariantStreamDecoderUsed: true,
            exactInvariantStreamDecoderConstructionCount: 1,
            exactTerminalSemanticArtifactSetFinishCallCount: 1,
            manifestDeclaredChunkIndicesDriveIteration: true,
            allSemanticValidationDelegatedToV16AndV18Types: true,
            equalByteZipperImplemented: true,
            zipperFeedsGlobalBeforeCurrentChunk: true,
            zipperPairsEqualGlobalAndChunkByteCounts: true,
            zipperFeedByteCountExpression:
                "min(maximumFeedByteCount,pairedRemainingByteCount)",
            zipperBoundsEveryFeedByDescriptorMaximum: true,
            zipperDrainsCurrentChunkRemainderBeforeChunkFinish: true,
            zipperFinishesEachChunkExactlyOnce: true,
            zipperDrainsGlobalRemainderAfterDeclaredChunks: true,
            zipperUsesOnlyFoundationDataIndicesAndSlices: true,
            foundationCodableOwnsJSONParsing: true,
            customJSONParserImplemented: false,
            maintainedV18FramedRecordReaderOwnsFrameParsing: true,
            customFrameParserImplemented: false,
            customFrameHeaderLengthOrRecordBoundaryMathImplemented: false,
            workerEdgeInspectsDecodedRecordPayloads: false,
            globalChunkRecordEqualityRemainsV18DecoderOwned: true,
            workerTargetMayReachDecoderTarget: true,
            statisticsTargetNewlyReachableThroughDecoder: true,
            decoderTargetMayReachWorkerTarget: false,
            mainCanNameOrReachDecoderCallEdge: false,
            preservedExporterCallEdgeCanNameOrReachDecoderCallEdge: false,
            preservedProjectionCallEdgeCanNameOrReachDecoderCallEdge: false,
            mainRemainsUnconditionalUnavailableExit: true,
            unavailableExitStatus: 78,
            callEdgeCompilerBound: true,
            callEdgeRuntimeExercised: false,
            replayTransportIntegratedWithDecoder: false,
            workerTargetRemainsExecutable: true,
            workerDeclaredAsProduct: false,
            packageGraphChanged: true,
            workerSourceInventoryChanged: true,
            testsImportWorker: false,
            testsInvokeWorkerCallEdgeOrPublicDecoderEntryPoint: false,
            workerRequestHandlingEnabled: false,
            workerSealed: false,
            workerLaunched: false,
            workerExecuted: false,
            fixtureMaterialized: false,
            exporterRuntimeInvocationObserved: false,
            projectorRuntimeInvocationObserved: false,
            decoderRuntimeInvocationObserved: false,
            projectedArtifactsHistoricallyObserved: false,
            decodedArtifactsHistoricallyObserved: false,
            historicalGateExecuted: false,
            modelExecutionObserved: false,
            artifactFilesystemReadPerformed: false,
            artifactWritePerformed: false,
            evidencePublished: false,
            durablePublicationObserved: false,
            independentDetectionEstablished: false,
            distinctImplementationFamiliesEstablished: false,
            agentContractKitFourTierAuditPerformed: false,
            mechanicsPassAuthorized: false,
            terminalReceiptAuthorized: false,
            sourceBindingV7Issued: false,
            scientificAuthorityAuthorized: false,
            productAuthorityAuthorized: false,
            nextImplementationPrerequisite:
                "design_the_unavailable_historical_worker_in_memory_exported_evidence_projection_decode_composition_boundary_accepting_only_already_formed_v14_evidence_and_explicit_v16_context_without_enabling_replay_transport_integration_request_handling_sealing_launch_execution_artifact_io_publication_or_issuing_source_binding_v7",
            authorityStatement:
                [
                    "This V19 source contract preserves the exact V11 status-78 main, V14 private exporter edge, V17 private projector edge, complete V18 decoder source contract, and V17/V18 topology identities.",
                    "It appends one fourth worker Swift source and exactly one seventh direct dependency on the product-free V18 decoder while preserving the exact six-dependency V17 prefix.",
                    "The new private cross-file member accepts only an already-formed and validated V16 projected artifact set, derives the role from that set, forms exactly six canonical inputs by exact key, and delegates all semantic decoding to the maintained V18 types.",
                    "Its bounded global-first zipper pairs equal global and current-chunk byte counts, drains the bounded current-chunk remainder before each chunk finish, then drains the bounded global remainder before the single terminal semantic-artifact-set finish.",
                    "Foundation Data indices and slices provide byte partitioning; Foundation Codable and the maintained V18 framed reader continue to own JSON and frame parsing. The worker edge implements no parser, frame-header arithmetic, record-boundary logic, positional join, or decoded-record inspection.",
                    "The frozen V17 historical guard is retained as historical identity and evolves additively only to admit the V19 worker source and seventh dependency while preserving the prior exact source assertions.",
                    "The exact main and V14/V17 private edges cannot name the V19 member. Compilation proves only the typed call edge; neither a worker test nor any public decoder entry point executes through it.",
                    "No replay transport integration, request handling, sealing, launch, worker/fixture/exporter/projector/decoder/gate/model execution, artifact filesystem read or write, historical observation, publication, durable evidence, independent detection, distinct implementation family, AgentContractKit four-tier audit, mechanics PASS, terminal receipt, source or execution binding V7, scientific authority, or product authority is observed or authorized.",
                ].joined(separator: " ")
        )
    }()

    public func validate() throws {
        let v17Source =
            PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactProjectionCallEdgeSourceContract
            .frozenV1
        let v18Source =
            PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderSourceContract
            .frozenV1
        let topologyV17 =
            PrimeNativeNeuralGateTrapDisjointTopologyContract
            .frozenV17
        let topologyV18 =
            PrimeNativeNeuralGateTrapDisjointTopologyContract
            .frozenV18
        try v17Source.validate()
        try v18Source.validate()
        try topologyV17.validate()
        try topologyV18.validate()

        let identities = [
            primaryWorkerSource,
            preservedExporterCallEdgeSource,
            preservedProjectionCallEdgeSource,
            decoderCallEdgeSource,
            fixtureResource,
            historicalV17GuardSource,
            currentAdditivelyEvolvedHistoricalGuardSource,
        ]
        let exactV17Dependencies = [
            "PrimeCore",
            "ErgenticsPrimeRuntime",
            "PrimeNativeNeuralGateHistoricalReplayMechanics",
            "PrimeNativeNeuralGateReplayTransport",
            "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics",
            "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection",
        ]
        let exactCanonicalKeys = [
            "materialIdentityManifest",
            "gateObservation",
            "invariantRecordsManifest",
            "fingerprintObservation",
            "mutationObservations",
            "statisticsVerdictObservation",
        ]

        guard self == .frozenV1,
              schemaVersion == 1,
              contractID
                == "prime_source_bound_historical_worker_semantic_artifact_decoder_call_edge_v19",
              rightsHolder == "Ergentics, LLC",
              licenseExpression == "LicenseRef-Ergentics-Proprietary",
              preservedWorkerProjectionCallEdgeV17ContractID
                == v17Source.contractID,
              preservedWorkerProjectionCallEdgeV17ContractSHA256
                == (try v17Source.contentSHA256()),
              preservedSemanticArtifactDecoderV18ContractID
                == v18Source.contractID,
              preservedSemanticArtifactDecoderV18ContractSHA256
                == (try v18Source.contentSHA256()),
              preservedTopologyV17ID == topologyV17.contractID,
              preservedTopologyV17SHA256
                == (try topologyV17.contentSHA256()),
              preservedTopologyV18ID == topologyV18.contractID,
              preservedTopologyV18SHA256
                == (try topologyV18.contentSHA256()),
              !priorPinnedWorkerOrDecoderFilesChanged,
              identities.allSatisfy({ $0.validate() }),
              workerTargetName
                == "PrimeNativeNeuralGateHistoricalFixtureWorker",
              primaryWorkerSource.byteCount == 2_298,
              preservedExporterCallEdgeSource.byteCount == 1_512,
              preservedProjectionCallEdgeSource.byteCount == 1_227,
              fixtureResource.byteCount == 1_949,
              historicalV17GuardSource.byteCount == 12_467,
              historicalV17GuardSource.primeRelativePath
                == currentAdditivelyEvolvedHistoricalGuardSource
                    .primeRelativePath,
              preservedV17WorkerSwiftSourceRelativePaths
                == [
                    preservedExporterCallEdgeSource.primeRelativePath,
                    primaryWorkerSource.primeRelativePath,
                    preservedProjectionCallEdgeSource.primeRelativePath,
                ],
              orderedWorkerSwiftSourceRelativePaths
                == [
                    preservedExporterCallEdgeSource.primeRelativePath,
                    primaryWorkerSource.primeRelativePath,
                    decoderCallEdgeSource.primeRelativePath,
                    preservedProjectionCallEdgeSource.primeRelativePath,
                ],
              Set(orderedWorkerSwiftSourceRelativePaths).count == 4,
              exactWorkerSwiftSourceFileCount == 4,
              completeWorkerSourceInventoryBound,
              !primaryWorkerSourceChanged,
              !preservedExporterCallEdgeSourceChanged,
              !preservedProjectionCallEdgeSourceChanged,
              !fixtureResourceChanged,
              !historicalGuardPathChanged,
              historicalGuardEvolvedAdditively,
              historicalGuardRetainsFrozenV17IdentityAssertions,
              historicalGuardAddsOnlyV19ContinuationAssertions,
              preservedWorkerDirectLocalDependencyNames
                == exactV17Dependencies,
              preservedWorkerDirectLocalDependencyNames.count == 6,
              workerDirectLocalDependencyNames
                == exactV17Dependencies
                    + [addedWorkerDependencyTargetName],
              exactWorkerDirectLocalDependencyCount == 7,
              exactAddedWorkerDependencyCount == 1,
              addedWorkerDependencyTargetName
                == "PrimeNativeNeuralGateHistoricalSemanticArtifactDecoder",
              preservedDependenciesRemainExactPrefix,
              !projectionTargetSourceOrDependenciesChanged,
              !decoderTargetSourceOrDependenciesChanged,
              !statisticsTargetSourceOrDependenciesChanged,
              !exporterTargetSourceOrDependenciesChanged,
              callEdgeEnclosingTypeName == workerTargetName,
              callEdgeMethodName
                == "sourceBoundHistoricalSemanticArtifactDecoderCallEdge",
              callEdgeNormalizedSignature
                == "private static func sourceBoundHistoricalSemanticArtifactDecoderCallEdge(projectedArtifacts: PrimeNativeNeuralGateHistoricalProjectedArtifactSet) throws -> PrimeNativeNeuralGateHistoricalDecodedSemanticArtifactSet",
              callEdgeAccessLevel == "private",
              !callEdgeDeclaredInMainSource,
              !callEdgeDeclaredInExporterEdgeSource,
              !callEdgeDeclaredInProjectionEdgeSource,
              callEdgeInputLabel == "projectedArtifacts",
              callEdgeInputSwiftTypeName
                == "PrimeNativeNeuralGateHistoricalProjectedArtifactSet",
              callEdgeOutputSwiftTypeName
                == "PrimeNativeNeuralGateHistoricalDecodedSemanticArtifactSet",
              exactCallEdgeImportNames
                == [
                    "Foundation",
                    "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection",
                    "PrimeNativeNeuralGateHistoricalSemanticArtifactDecoder",
                ],
              callEdgeAcceptsAlreadyFormedProjectedArtifactSet,
              callEdgeValidatesProjectedArtifactSetFirst,
              callEdgeDerivesRoleOnlyFromProjectedArtifactSet,
              !callEdgeConstructsOrInfersProjectionContext,
              !callEdgeInvokesExporterOrProjector,
              !callEdgeContainsFixtureMaterialization,
              !callEdgeContainsProcessTransportOrIO,
              exactCanonicalLeafCount == 6,
              exactCanonicalLeafKeyCaseNames == exactCanonicalKeys,
              exactArtifactCountPerRole == 22,
              exactInvariantChunkCountPerRole == 15,
              descriptorFeedMaximumByteCount == 65_536,
              canonicalArtifactsJoinedByExactKey,
              !positionalArtifactJoinPermitted,
              maintainedV18CanonicalLeafDecoderUsed,
              exactCanonicalLeafDecoderCallCount == 1,
              maintainedV18InvariantStreamDecoderUsed,
              exactInvariantStreamDecoderConstructionCount == 1,
              exactTerminalSemanticArtifactSetFinishCallCount == 1,
              manifestDeclaredChunkIndicesDriveIteration,
              allSemanticValidationDelegatedToV16AndV18Types,
              equalByteZipperImplemented,
              zipperFeedsGlobalBeforeCurrentChunk,
              zipperPairsEqualGlobalAndChunkByteCounts,
              zipperFeedByteCountExpression
                == "min(maximumFeedByteCount,pairedRemainingByteCount)",
              zipperBoundsEveryFeedByDescriptorMaximum,
              zipperDrainsCurrentChunkRemainderBeforeChunkFinish,
              zipperFinishesEachChunkExactlyOnce,
              zipperDrainsGlobalRemainderAfterDeclaredChunks,
              zipperUsesOnlyFoundationDataIndicesAndSlices,
              foundationCodableOwnsJSONParsing,
              !customJSONParserImplemented,
              maintainedV18FramedRecordReaderOwnsFrameParsing,
              !customFrameParserImplemented,
              !customFrameHeaderLengthOrRecordBoundaryMathImplemented,
              !workerEdgeInspectsDecodedRecordPayloads,
              globalChunkRecordEqualityRemainsV18DecoderOwned,
              workerTargetMayReachDecoderTarget,
              statisticsTargetNewlyReachableThroughDecoder,
              !decoderTargetMayReachWorkerTarget,
              !mainCanNameOrReachDecoderCallEdge,
              !preservedExporterCallEdgeCanNameOrReachDecoderCallEdge,
              !preservedProjectionCallEdgeCanNameOrReachDecoderCallEdge,
              mainRemainsUnconditionalUnavailableExit,
              unavailableExitStatus == 78,
              callEdgeCompilerBound,
              !callEdgeRuntimeExercised,
              !replayTransportIntegratedWithDecoder,
              workerTargetRemainsExecutable,
              !workerDeclaredAsProduct,
              packageGraphChanged,
              workerSourceInventoryChanged,
              !testsImportWorker,
              !testsInvokeWorkerCallEdgeOrPublicDecoderEntryPoint,
              !workerRequestHandlingEnabled,
              !workerSealed,
              !workerLaunched,
              !workerExecuted,
              !fixtureMaterialized,
              !exporterRuntimeInvocationObserved,
              !projectorRuntimeInvocationObserved,
              !decoderRuntimeInvocationObserved,
              !projectedArtifactsHistoricallyObserved,
              !decodedArtifactsHistoricallyObserved,
              !historicalGateExecuted,
              !modelExecutionObserved,
              !artifactFilesystemReadPerformed,
              !artifactWritePerformed,
              !evidencePublished,
              !durablePublicationObserved,
              !independentDetectionEstablished,
              !distinctImplementationFamiliesEstablished,
              !agentContractKitFourTierAuditPerformed,
              !mechanicsPassAuthorized,
              !terminalReceiptAuthorized,
              !sourceBindingV7Issued,
              !scientificAuthorityAuthorized,
              !productAuthorityAuthorized,
              nextImplementationPrerequisite
                == "design_the_unavailable_historical_worker_in_memory_exported_evidence_projection_decode_composition_boundary_accepting_only_already_formed_v14_evidence_and_explicit_v16_context_without_enabling_replay_transport_integration_request_handling_sealing_launch_execution_artifact_io_publication_or_issuing_source_binding_v7",
              authorityStatement.contains(
                "Compilation proves only the typed call edge"
              )
        else {
            throw PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactDecoderCallEdgeSourceContractError
                .invalidFrozenContract
        }
    }

    public func contentSHA256() throws -> String {
        try validate()
        return PrimeSHA256.hexDigest(
            of: try PrimeCanonicalJSON.encode(self)
        )
    }
}
