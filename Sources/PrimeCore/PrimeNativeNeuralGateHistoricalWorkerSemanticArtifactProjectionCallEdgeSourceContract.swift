// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

public enum
    PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactProjectionCallEdgeSourceContractError:
    Error,
    Equatable,
    Sendable
{
    case invalidFrozenContract
}

public struct
    PrimeNativeNeuralGateHistoricalWorkerProjectionCallEdgeSourceIdentity:
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
        (
            primeRelativePath.hasPrefix("Sources/")
                || primeRelativePath.hasPrefix("Tests/")
        )
            && !primeRelativePath.contains("..")
            && !primeRelativePath.contains("\\")
            && byteCount > 0
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

/// Frozen V17 source and package boundary for the historical worker's private
/// carrier-to-semantic-artifact projector edge.
///
/// V17 appends one source file and one direct dependency to the existing
/// product-free worker target. The source accepts an already-formed V13
/// evidence carrier and an explicit V16 projection context. Its only
/// expression is the typed V16 projector call. The exact V11 `main` and V14
/// exporter edge remain in separate files and cannot name the new private
/// member, so compilation is not execution through the worker, exporter, or
/// public projector entry point.
public struct
    PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactProjectionCallEdgeSourceContract:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let contractID: String
    public let rightsHolder: String
    public let licenseExpression: String

    public let preservedWorkerExporterCallEdgeV14ContractID: String
    public let preservedWorkerExporterCallEdgeV14ContractSHA256: String
    public let preservedProjectionSourceV16ContractID: String
    public let preservedProjectionSourceV16ContractSHA256: String
    public let preservedTopologyV16ID: String
    public let preservedTopologyV16SHA256: String
    public let preservedProjectionTargetName: String
    public let preservedProjectionDirectLocalDependencyNames: [String]
    public let preservedProjectionOrderedSourceFiles:
        [PrimeNativeNeuralGateHistoricalWorkerProjectionCallEdgeSourceIdentity]
    public let preservedProjectionProductDeclared: Bool
    public let preservedProjectionExecutableDeclared: Bool

    public let workerTargetName: String
    public let primaryWorkerSource:
        PrimeNativeNeuralGateHistoricalWorkerProjectionCallEdgeSourceIdentity
    public let preservedExporterCallEdgeSource:
        PrimeNativeNeuralGateHistoricalWorkerProjectionCallEdgeSourceIdentity
    public let projectionCallEdgeSource:
        PrimeNativeNeuralGateHistoricalWorkerProjectionCallEdgeSourceIdentity
    public let fixtureResource:
        PrimeNativeNeuralGateHistoricalWorkerProjectionCallEdgeSourceIdentity
    public let focusedSourceGuardTest:
        PrimeNativeNeuralGateHistoricalWorkerProjectionCallEdgeSourceIdentity
    public let orderedWorkerSwiftSourceRelativePaths: [String]
    public let exactWorkerSwiftSourceFileCount: Int
    public let completeWorkerSourceInventoryBound: Bool
    public let primaryWorkerSourceChanged: Bool
    public let preservedExporterCallEdgeSourceChanged: Bool
    public let fixtureResourceChanged: Bool

    public let preservedWorkerDirectLocalDependencyNames: [String]
    public let workerDirectLocalDependencyNames: [String]
    public let exactAddedWorkerDependencyCount: Int
    public let addedWorkerDependencyTargetName: String
    public let preservedDependenciesRemainExactPrefix: Bool
    public let projectionTargetSourceOrDependenciesChanged: Bool
    public let exporterTargetSourceOrDependenciesChanged: Bool

    public let callEdgeEnclosingTypeName: String
    public let callEdgeMethodName: String
    public let callEdgeNormalizedSignature: String
    public let callEdgeAccessLevel: String
    public let callEdgeDeclaredInMainSource: Bool
    public let callEdgeDeclaredInExporterEdgeSource: Bool
    public let callEdgeInputEvidenceLabel: String
    public let callEdgeInputEvidenceSwiftTypeName: String
    public let callEdgeInputContextLabel: String
    public let callEdgeInputContextSwiftTypeName: String
    public let callEdgeOutputSwiftTypeName: String
    public let callEdgeProjectorTypeName: String
    public let callEdgeProjectorMethodName: String
    public let callEdgeNormalizedProjectorExpression: String
    public let exactProjectorCallCount: Int
    public let exactCallEdgeImportNames: [String]
    public let callEdgeAcceptsAlreadyFormedEvidence: Bool
    public let callEdgeConstructsOrInfersContext: Bool
    public let
        adapterAddsDefaultingReductionOrderingOrSerializationBeyondProjector:
        Bool
    public let delegatedProjectorTransformsCarrierIntoArtifactSet: Bool
    public let callEdgeContainsFixtureMaterializationOrExporterInvocation: Bool
    public let callEdgeContainsProcessTransportOrIO: Bool

    public let workerTargetMayReachProjectionTarget: Bool
    public let semanticRecordTargetNewlyReachableThroughProjection: Bool
    public let projectionTargetMayReachWorkerTarget: Bool
    public let mainCanNameOrReachProjectionCallEdge: Bool
    public let preservedExporterCallEdgeCanNameOrReachProjectionCallEdge:
        Bool
    public let mainRemainsUnconditionalUnavailableExit: Bool
    public let unavailableExitStatus: Int32
    public let callEdgeCompilerBound: Bool
    public let callEdgeRuntimeExercised: Bool
    public let replayTransportIntegratedWithProjection: Bool
    public let workerTargetRemainsExecutable: Bool
    public let workerDeclaredAsProduct: Bool
    public let packageGraphChanged: Bool
    public let workerSourceInventoryChanged: Bool
    public let testsImportWorker: Bool
    public let testsInvokeProjectionEntryPoint: Bool

    public let workerRequestHandlingEnabled: Bool
    public let workerSealed: Bool
    public let workerLaunched: Bool
    public let workerExecuted: Bool
    public let fixtureMaterialized: Bool
    public let exporterInvoked: Bool
    public let workerCallEdgeOrPublicProjectionEntryPointInvoked: Bool
    public let
        workerCallEdgeOrPublicProjectionEntryPointArtifactsConstructed:
        Bool
    public let historicalGateExecuted: Bool
    public let modelExecutionObserved: Bool
    public let historicalEvidenceObserved: Bool
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
        let projectorTargetName =
            "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection"

        return Self(
            schemaVersion: 1,
            contractID:
                "prime_source_bound_historical_worker_semantic_artifact_projection_call_edge_v17",
            rightsHolder: "Ergentics, LLC",
            licenseExpression:
                "LicenseRef-Ergentics-Proprietary",
            preservedWorkerExporterCallEdgeV14ContractID:
                "prime_source_bound_historical_worker_evidence_export_call_edge_v14",
            preservedWorkerExporterCallEdgeV14ContractSHA256:
                "8112cf3e6190fcd6385614322be11f391bccc1ca411b6af85c7bd8cf57c4a4e8",
            preservedProjectionSourceV16ContractID:
                "prime_source_bound_historical_evidence_semantic_artifact_projection_source_v16",
            preservedProjectionSourceV16ContractSHA256:
                "2b9c1565f103622eb82e53e4a83820b98d6dd0d3dfd5487353dde06c5a4fd4dd",
            preservedTopologyV16ID:
                "prime_stage_b_source_bound_historical_evidence_semantic_artifact_projection_topology_v16",
            preservedTopologyV16SHA256:
                "7e9dafad211bb0fb450ff9054be71a0022f5a259b4021d90123eb4736df747d3",
            preservedProjectionTargetName:
                projectorTargetName,
            preservedProjectionDirectLocalDependencyNames: [
                "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics",
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplayMechanics",
                "PrimeNativeNeuralGateSemanticRecordContracts",
            ],
            preservedProjectionOrderedSourceFiles: [
                .init(
                    primeRelativePath:
                        "Sources/PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection/PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection.swift",
                    byteCount: 28_320,
                    sha256:
                        "23e5d3bc6814e1283011f8b5049105dfdcfeef9d7e442130b7be7c6499431ec9"
                ),
                .init(
                    primeRelativePath:
                        "Sources/PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection/PrimeNativeNeuralGateHistoricalKeyedThreeSeedStatisticsEnvelope.swift",
                    byteCount: 46_950,
                    sha256:
                        "e3b876a2bc9aff099b57da66bfa698f196dc4541a10e4c253d511a6d385fd7b7"
                ),
            ],
            preservedProjectionProductDeclared: false,
            preservedProjectionExecutableDeclared: false,
            workerTargetName:
                "PrimeNativeNeuralGateHistoricalFixtureWorker",
            primaryWorkerSource: .init(
                primeRelativePath:
                    "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalFixtureWorker.swift",
                byteCount: 2_298,
                sha256:
                    "9f62827d4c35e98fb01f9984b1c227cb681dd42ac4c26147a86e9429958545df"
            ),
            preservedExporterCallEdgeSource: .init(
                primeRelativePath:
                    "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalEvidenceExportCallEdge.swift",
                byteCount: 1_512,
                sha256:
                    "d3ac7fcddd43844e92b61764c458dfce6291471fd465b1bb52f5186814e10319"
            ),
            projectionCallEdgeSource: .init(
                primeRelativePath:
                    "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactProjectionCallEdge.swift",
                byteCount: 1_227,
                sha256:
                    "dce631bd4749a05d8f04323b51c4da37e5ef67df14b950f1e5eee1d1565e0964"
            ),
            fixtureResource: .init(
                primeRelativePath:
                    "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/HistoricalFixtureEvidence/Package.resolved",
                byteCount: 1_949,
                sha256:
                    "cf1ba313dcb0c959e80ba09d6cbe0c56bcd921523bda5cec2c682c8ae7696ab3"
            ),
            focusedSourceGuardTest: .init(
                primeRelativePath:
                    "Tests/PrimeCoreTests/PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactProjectionCallEdgeSourceTests.swift",
                byteCount: 12_467,
                sha256:
                    "ff03b3a143ebc748dadf6d9a337d68753add478811395d78d27e5654c805a8f4"
            ),
            orderedWorkerSwiftSourceRelativePaths: [
                "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalEvidenceExportCallEdge.swift",
                "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalFixtureWorker.swift",
                "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactProjectionCallEdge.swift",
            ],
            exactWorkerSwiftSourceFileCount: 3,
            completeWorkerSourceInventoryBound: true,
            primaryWorkerSourceChanged: false,
            preservedExporterCallEdgeSourceChanged: false,
            fixtureResourceChanged: false,
            preservedWorkerDirectLocalDependencyNames: [
                "PrimeCore",
                "ErgenticsPrimeRuntime",
                "PrimeNativeNeuralGateHistoricalReplayMechanics",
                "PrimeNativeNeuralGateReplayTransport",
                "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics",
            ],
            workerDirectLocalDependencyNames: [
                "PrimeCore",
                "ErgenticsPrimeRuntime",
                "PrimeNativeNeuralGateHistoricalReplayMechanics",
                "PrimeNativeNeuralGateReplayTransport",
                "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics",
                projectorTargetName,
            ],
            exactAddedWorkerDependencyCount: 1,
            addedWorkerDependencyTargetName:
                projectorTargetName,
            preservedDependenciesRemainExactPrefix: true,
            projectionTargetSourceOrDependenciesChanged: false,
            exporterTargetSourceOrDependenciesChanged: false,
            callEdgeEnclosingTypeName:
                "PrimeNativeNeuralGateHistoricalFixtureWorker",
            callEdgeMethodName:
                "sourceBoundHistoricalEvidenceSemanticArtifactProjectionCallEdge",
            callEdgeNormalizedSignature:
                "private static func sourceBoundHistoricalEvidenceSemanticArtifactProjectionCallEdge(evidence: PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence, context: PrimeNativeNeuralGateHistoricalProjectionContext) throws -> PrimeNativeNeuralGateHistoricalProjectedArtifactSet",
            callEdgeAccessLevel: "private",
            callEdgeDeclaredInMainSource: false,
            callEdgeDeclaredInExporterEdgeSource: false,
            callEdgeInputEvidenceLabel: "evidence",
            callEdgeInputEvidenceSwiftTypeName:
                "PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence",
            callEdgeInputContextLabel: "context",
            callEdgeInputContextSwiftTypeName:
                "PrimeNativeNeuralGateHistoricalProjectionContext",
            callEdgeOutputSwiftTypeName:
                "PrimeNativeNeuralGateHistoricalProjectedArtifactSet",
            callEdgeProjectorTypeName:
                "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection",
            callEdgeProjectorMethodName: "project",
            callEdgeNormalizedProjectorExpression:
                "try PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection.project(evidence: evidence, context: context)",
            exactProjectorCallCount: 1,
            exactCallEdgeImportNames: [
                "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics",
                "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection",
            ],
            callEdgeAcceptsAlreadyFormedEvidence: true,
            callEdgeConstructsOrInfersContext: false,
            adapterAddsDefaultingReductionOrderingOrSerializationBeyondProjector:
                false,
            delegatedProjectorTransformsCarrierIntoArtifactSet: true,
            callEdgeContainsFixtureMaterializationOrExporterInvocation:
                false,
            callEdgeContainsProcessTransportOrIO: false,
            workerTargetMayReachProjectionTarget: true,
            semanticRecordTargetNewlyReachableThroughProjection: true,
            projectionTargetMayReachWorkerTarget: false,
            mainCanNameOrReachProjectionCallEdge: false,
            preservedExporterCallEdgeCanNameOrReachProjectionCallEdge:
                false,
            mainRemainsUnconditionalUnavailableExit: true,
            unavailableExitStatus: 78,
            callEdgeCompilerBound: true,
            callEdgeRuntimeExercised: false,
            replayTransportIntegratedWithProjection: false,
            workerTargetRemainsExecutable: true,
            workerDeclaredAsProduct: false,
            packageGraphChanged: true,
            workerSourceInventoryChanged: true,
            testsImportWorker: false,
            testsInvokeProjectionEntryPoint: false,
            workerRequestHandlingEnabled: false,
            workerSealed: false,
            workerLaunched: false,
            workerExecuted: false,
            fixtureMaterialized: false,
            exporterInvoked: false,
            workerCallEdgeOrPublicProjectionEntryPointInvoked: false,
            workerCallEdgeOrPublicProjectionEntryPointArtifactsConstructed:
                false,
            historicalGateExecuted: false,
            modelExecutionObserved: false,
            historicalEvidenceObserved: false,
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
                "design_and_source_bind_the_complete_v16_historical_semantic_artifact_decoder_boundary_for_six_canonical_json_leaves_and_descriptor_streamed_global_and_chunk_artifacts_per_role_before_any_replay_transport_integration_request_handling_sealing_launch_execution_io_publication_or_source_binding_v7",
            authorityStatement:
                [
                    "This V17 source contract preserves the exact V11 status-78 main, V14 private worker/exporter call edge, V16 projection source, V16 projector target, and V16 topology identities.",
                    "It appends one third worker Swift source and exactly one sixth direct dependency on the existing product-free V16 projector while preserving the prior five dependencies as an exact prefix.",
                    "The new private cross-file member accepts only an already-formed V13 Evidence carrier and explicit V16 projection context and contains one typed project(evidence:context:) expression.",
                    "It cannot call the private V14 edge, derive or materialize evidence, materialize the fixture, invoke the exporter, infer context, integrate ReplayTransport, or add any defaulting, reduction, ordering, serialization, process, filesystem, network, publication, or receipt behavior beyond the already-bound V16 projector call.",
                    "The worker target can now reach the projector and its historical-safe semantic-record dependency, but the exact main and V14 edge cannot name or reach the new member; compilation therefore proves only the typed call edge and is not runtime evidence.",
                    "V16 synthetic component tests remain non-historical mechanics evidence. No worker request handling, sealing, launch, worker call edge or public project(evidence:context:) entry-point invocation, worker-derived historical artifact construction or write, gate/model execution, historical evidence observation or publication, durable observation, independent detection, distinct implementation family, AgentContractKit four-tier audit, mechanics PASS, terminal receipt, source or execution binding V7, scientific authority, or product authority is observed or authorized.",
                ].joined(separator: " ")
        )
    }()

    public func validate() throws {
        let identities = [
            primaryWorkerSource,
            preservedExporterCallEdgeSource,
            projectionCallEdgeSource,
            fixtureResource,
            focusedSourceGuardTest,
        ] + preservedProjectionOrderedSourceFiles
        guard self == .frozenV1,
              schemaVersion == 1,
              contractID
                == "prime_source_bound_historical_worker_semantic_artifact_projection_call_edge_v17",
              rightsHolder == "Ergentics, LLC",
              licenseExpression
                == "LicenseRef-Ergentics-Proprietary",
              preservedWorkerExporterCallEdgeV14ContractID
                == "prime_source_bound_historical_worker_evidence_export_call_edge_v14",
              preservedWorkerExporterCallEdgeV14ContractSHA256
                == "8112cf3e6190fcd6385614322be11f391bccc1ca411b6af85c7bd8cf57c4a4e8",
              preservedProjectionSourceV16ContractID
                == "prime_source_bound_historical_evidence_semantic_artifact_projection_source_v16",
              preservedProjectionSourceV16ContractSHA256
                == "2b9c1565f103622eb82e53e4a83820b98d6dd0d3dfd5487353dde06c5a4fd4dd",
              preservedTopologyV16ID
                == "prime_stage_b_source_bound_historical_evidence_semantic_artifact_projection_topology_v16",
              preservedTopologyV16SHA256
                == "7e9dafad211bb0fb450ff9054be71a0022f5a259b4021d90123eb4736df747d3",
              preservedProjectionTargetName
                == "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection",
              preservedProjectionDirectLocalDependencyNames
                == [
                    "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics",
                    "PrimeNativeNeuralGateReplayArtifactContracts",
                    "PrimeNativeNeuralGateReplayMechanics",
                    "PrimeNativeNeuralGateSemanticRecordContracts",
                ],
              preservedProjectionOrderedSourceFiles.count == 2,
              Set(
                preservedProjectionOrderedSourceFiles
                    .map(\.primeRelativePath)
              ).count == 2,
              !preservedProjectionProductDeclared,
              !preservedProjectionExecutableDeclared,
              identities.allSatisfy({ $0.validate() }),
              workerTargetName
                == "PrimeNativeNeuralGateHistoricalFixtureWorker",
              primaryWorkerSource.byteCount == 2_298,
              preservedExporterCallEdgeSource.byteCount == 1_512,
              fixtureResource.byteCount == 1_949,
              orderedWorkerSwiftSourceRelativePaths
                == [
                    preservedExporterCallEdgeSource.primeRelativePath,
                    primaryWorkerSource.primeRelativePath,
                    projectionCallEdgeSource.primeRelativePath,
                ],
              Set(orderedWorkerSwiftSourceRelativePaths).count == 3,
              exactWorkerSwiftSourceFileCount == 3,
              completeWorkerSourceInventoryBound,
              !primaryWorkerSourceChanged,
              !preservedExporterCallEdgeSourceChanged,
              !fixtureResourceChanged,
              preservedWorkerDirectLocalDependencyNames
                == [
                    "PrimeCore",
                    "ErgenticsPrimeRuntime",
                    "PrimeNativeNeuralGateHistoricalReplayMechanics",
                    "PrimeNativeNeuralGateReplayTransport",
                    "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics",
                ],
              preservedWorkerDirectLocalDependencyNames.count == 5,
              workerDirectLocalDependencyNames
                == preservedWorkerDirectLocalDependencyNames
                    + [addedWorkerDependencyTargetName],
              exactAddedWorkerDependencyCount == 1,
              addedWorkerDependencyTargetName
                == preservedProjectionTargetName,
              preservedDependenciesRemainExactPrefix,
              !projectionTargetSourceOrDependenciesChanged,
              !exporterTargetSourceOrDependenciesChanged,
              callEdgeEnclosingTypeName == workerTargetName,
              callEdgeMethodName
                == "sourceBoundHistoricalEvidenceSemanticArtifactProjectionCallEdge",
              callEdgeAccessLevel == "private",
              !callEdgeDeclaredInMainSource,
              !callEdgeDeclaredInExporterEdgeSource,
              callEdgeInputEvidenceLabel == "evidence",
              callEdgeInputEvidenceSwiftTypeName
                == "PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence",
              callEdgeInputContextLabel == "context",
              callEdgeInputContextSwiftTypeName
                == "PrimeNativeNeuralGateHistoricalProjectionContext",
              callEdgeOutputSwiftTypeName
                == "PrimeNativeNeuralGateHistoricalProjectedArtifactSet",
              callEdgeProjectorTypeName
                == preservedProjectionTargetName,
              callEdgeProjectorMethodName
                == "project",
              exactProjectorCallCount == 1,
              exactCallEdgeImportNames
                == [
                    "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics",
                    preservedProjectionTargetName,
                ],
              callEdgeAcceptsAlreadyFormedEvidence,
              !callEdgeConstructsOrInfersContext,
              !adapterAddsDefaultingReductionOrderingOrSerializationBeyondProjector,
              delegatedProjectorTransformsCarrierIntoArtifactSet,
              !callEdgeContainsFixtureMaterializationOrExporterInvocation,
              !callEdgeContainsProcessTransportOrIO,
              workerTargetMayReachProjectionTarget,
              semanticRecordTargetNewlyReachableThroughProjection,
              !projectionTargetMayReachWorkerTarget,
              !mainCanNameOrReachProjectionCallEdge,
              !preservedExporterCallEdgeCanNameOrReachProjectionCallEdge,
              mainRemainsUnconditionalUnavailableExit,
              unavailableExitStatus == 78,
              callEdgeCompilerBound,
              !callEdgeRuntimeExercised,
              !replayTransportIntegratedWithProjection,
              workerTargetRemainsExecutable,
              !workerDeclaredAsProduct,
              packageGraphChanged,
              workerSourceInventoryChanged,
              !testsImportWorker,
              !testsInvokeProjectionEntryPoint,
              !workerRequestHandlingEnabled,
              !workerSealed,
              !workerLaunched,
              !workerExecuted,
              !fixtureMaterialized,
              !exporterInvoked,
              !workerCallEdgeOrPublicProjectionEntryPointInvoked,
              !workerCallEdgeOrPublicProjectionEntryPointArtifactsConstructed,
              !historicalGateExecuted,
              !modelExecutionObserved,
              !historicalEvidenceObserved,
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
              !nextImplementationPrerequisite.isEmpty,
              authorityStatement.contains(
                "compilation therefore proves only the typed call edge"
              )
        else {
            throw PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactProjectionCallEdgeSourceContractError
                .invalidFrozenContract
        }
    }

    public func contentSHA256() throws -> String {
        try validate()
        return PrimeSHA256.hexDigest(
            of: try PrimeCanonicalJSON.encode(self)
        )
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case contractID = "contract_id"
        case rightsHolder = "rights_holder"
        case licenseExpression = "license_expression"
        case preservedWorkerExporterCallEdgeV14ContractID =
            "preserved_worker_exporter_call_edge_v14_contract_id"
        case preservedWorkerExporterCallEdgeV14ContractSHA256 =
            "preserved_worker_exporter_call_edge_v14_contract_sha256"
        case preservedProjectionSourceV16ContractID =
            "preserved_projection_source_v16_contract_id"
        case preservedProjectionSourceV16ContractSHA256 =
            "preserved_projection_source_v16_contract_sha256"
        case preservedTopologyV16ID =
            "preserved_topology_v16_id"
        case preservedTopologyV16SHA256 =
            "preserved_topology_v16_sha256"
        case preservedProjectionTargetName =
            "preserved_projection_target_name"
        case preservedProjectionDirectLocalDependencyNames =
            "preserved_projection_direct_local_dependency_names"
        case preservedProjectionOrderedSourceFiles =
            "preserved_projection_ordered_source_files"
        case preservedProjectionProductDeclared =
            "preserved_projection_product_declared"
        case preservedProjectionExecutableDeclared =
            "preserved_projection_executable_declared"
        case workerTargetName = "worker_target_name"
        case primaryWorkerSource = "primary_worker_source"
        case preservedExporterCallEdgeSource =
            "preserved_exporter_call_edge_source"
        case projectionCallEdgeSource =
            "projection_call_edge_source"
        case fixtureResource = "fixture_resource"
        case focusedSourceGuardTest = "focused_source_guard_test"
        case orderedWorkerSwiftSourceRelativePaths =
            "ordered_worker_swift_source_relative_paths"
        case exactWorkerSwiftSourceFileCount =
            "exact_worker_swift_source_file_count"
        case completeWorkerSourceInventoryBound =
            "complete_worker_source_inventory_bound"
        case primaryWorkerSourceChanged =
            "primary_worker_source_changed"
        case preservedExporterCallEdgeSourceChanged =
            "preserved_exporter_call_edge_source_changed"
        case fixtureResourceChanged = "fixture_resource_changed"
        case preservedWorkerDirectLocalDependencyNames =
            "preserved_worker_direct_local_dependency_names"
        case workerDirectLocalDependencyNames =
            "worker_direct_local_dependency_names"
        case exactAddedWorkerDependencyCount =
            "exact_added_worker_dependency_count"
        case addedWorkerDependencyTargetName =
            "added_worker_dependency_target_name"
        case preservedDependenciesRemainExactPrefix =
            "preserved_dependencies_remain_exact_prefix"
        case projectionTargetSourceOrDependenciesChanged =
            "projection_target_source_or_dependencies_changed"
        case exporterTargetSourceOrDependenciesChanged =
            "exporter_target_source_or_dependencies_changed"
        case callEdgeEnclosingTypeName =
            "call_edge_enclosing_type_name"
        case callEdgeMethodName = "call_edge_method_name"
        case callEdgeNormalizedSignature =
            "call_edge_normalized_signature"
        case callEdgeAccessLevel = "call_edge_access_level"
        case callEdgeDeclaredInMainSource =
            "call_edge_declared_in_main_source"
        case callEdgeDeclaredInExporterEdgeSource =
            "call_edge_declared_in_exporter_edge_source"
        case callEdgeInputEvidenceLabel =
            "call_edge_input_evidence_label"
        case callEdgeInputEvidenceSwiftTypeName =
            "call_edge_input_evidence_swift_type_name"
        case callEdgeInputContextLabel =
            "call_edge_input_context_label"
        case callEdgeInputContextSwiftTypeName =
            "call_edge_input_context_swift_type_name"
        case callEdgeOutputSwiftTypeName =
            "call_edge_output_swift_type_name"
        case callEdgeProjectorTypeName =
            "call_edge_projector_type_name"
        case callEdgeProjectorMethodName =
            "call_edge_projector_method_name"
        case callEdgeNormalizedProjectorExpression =
            "call_edge_normalized_projector_expression"
        case exactProjectorCallCount = "exact_projector_call_count"
        case exactCallEdgeImportNames =
            "exact_call_edge_import_names"
        case callEdgeAcceptsAlreadyFormedEvidence =
            "call_edge_accepts_already_formed_evidence"
        case callEdgeConstructsOrInfersContext =
            "call_edge_constructs_or_infers_context"
        case adapterAddsDefaultingReductionOrderingOrSerializationBeyondProjector =
            "adapter_adds_defaulting_reduction_ordering_or_serialization_beyond_projector"
        case delegatedProjectorTransformsCarrierIntoArtifactSet =
            "delegated_projector_transforms_carrier_into_artifact_set"
        case callEdgeContainsFixtureMaterializationOrExporterInvocation =
            "call_edge_contains_fixture_materialization_or_exporter_invocation"
        case callEdgeContainsProcessTransportOrIO =
            "call_edge_contains_process_transport_or_io"
        case workerTargetMayReachProjectionTarget =
            "worker_target_may_reach_projection_target"
        case semanticRecordTargetNewlyReachableThroughProjection =
            "semantic_record_target_newly_reachable_through_projection"
        case projectionTargetMayReachWorkerTarget =
            "projection_target_may_reach_worker_target"
        case mainCanNameOrReachProjectionCallEdge =
            "main_can_name_or_reach_projection_call_edge"
        case preservedExporterCallEdgeCanNameOrReachProjectionCallEdge =
            "preserved_exporter_call_edge_can_name_or_reach_projection_call_edge"
        case mainRemainsUnconditionalUnavailableExit =
            "main_remains_unconditional_unavailable_exit"
        case unavailableExitStatus = "unavailable_exit_status"
        case callEdgeCompilerBound = "call_edge_compiler_bound"
        case callEdgeRuntimeExercised =
            "call_edge_runtime_exercised"
        case replayTransportIntegratedWithProjection =
            "replay_transport_integrated_with_projection"
        case workerTargetRemainsExecutable =
            "worker_target_remains_executable"
        case workerDeclaredAsProduct =
            "worker_declared_as_product"
        case packageGraphChanged = "package_graph_changed"
        case workerSourceInventoryChanged =
            "worker_source_inventory_changed"
        case testsImportWorker = "tests_import_worker"
        case testsInvokeProjectionEntryPoint =
            "tests_invoke_projection_entry_point"
        case workerRequestHandlingEnabled =
            "worker_request_handling_enabled"
        case workerSealed = "worker_sealed"
        case workerLaunched = "worker_launched"
        case workerExecuted = "worker_executed"
        case fixtureMaterialized = "fixture_materialized"
        case exporterInvoked = "exporter_invoked"
        case workerCallEdgeOrPublicProjectionEntryPointInvoked =
            "worker_call_edge_or_public_projection_entry_point_invoked"
        case workerCallEdgeOrPublicProjectionEntryPointArtifactsConstructed =
            "worker_call_edge_or_public_projection_entry_point_artifacts_constructed"
        case historicalGateExecuted = "historical_gate_executed"
        case modelExecutionObserved = "model_execution_observed"
        case historicalEvidenceObserved =
            "historical_evidence_observed"
        case artifactWritePerformed = "artifact_write_performed"
        case evidencePublished = "evidence_published"
        case durablePublicationObserved =
            "durable_publication_observed"
        case independentDetectionEstablished =
            "independent_detection_established"
        case distinctImplementationFamiliesEstablished =
            "distinct_implementation_families_established"
        case agentContractKitFourTierAuditPerformed =
            "agent_contract_kit_four_tier_audit_performed"
        case mechanicsPassAuthorized =
            "mechanics_pass_authorized"
        case terminalReceiptAuthorized =
            "terminal_receipt_authorized"
        case sourceBindingV7Issued = "source_binding_v7_issued"
        case scientificAuthorityAuthorized =
            "scientific_authority_authorized"
        case productAuthorityAuthorized =
            "product_authority_authorized"
        case nextImplementationPrerequisite =
            "next_implementation_prerequisite"
        case authorityStatement = "authority_statement"
    }
}
