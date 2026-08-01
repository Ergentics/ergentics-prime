// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

public enum
    PrimeNativeNeuralGateHistoricalWorkerEvidenceExportCallEdgeSourceContractError:
    Error,
    Equatable,
    Sendable
{
    case invalidFrozenContract
}

/// Frozen V14 source and package boundary for the historical worker's private
/// evidence-export call edge.
///
/// The original V11 `@main` source remains byte-exact and unavailable. V14
/// adds one separately pinned Swift source file to that existing executable
/// target and appends one package dependency. The new member is `private` in a
/// different file from `main`, so this checkpoint proves compilation of the
/// worker-to-exporter edge without making the edge reachable or executing it.
public struct
    PrimeNativeNeuralGateHistoricalWorkerEvidenceExportCallEdgeSourceContract:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let contractID: String
    public let rightsHolder: String
    public let licenseExpression: String

    public let preservedWorkerSourceContractID: String
    public let preservedWorkerSourceContractSHA256: String
    public let preservedExporterSourceContractID: String
    public let preservedExporterSourceContractSHA256: String
    public let preservedTopologyV13ID: String
    public let preservedTopologyV13SHA256: String

    public let workerTargetName: String
    public let primaryWorkerSourceRelativePath: String
    public let primaryWorkerSourceByteCount: UInt64
    public let primaryWorkerSourceSHA256: String
    public let primaryWorkerSourceChanged: Bool
    public let callEdgeSourceRelativePath: String
    public let callEdgeSourceByteCount: UInt64
    public let callEdgeSourceSHA256: String
    public let orderedWorkerSwiftSourceRelativePaths: [String]
    public let exactWorkerSwiftSourceFileCount: Int

    public let fixtureResourceRelativePath: String
    public let fixtureResourceByteCount: UInt64
    public let fixtureResourceSHA256: String
    public let fixtureResourceChanged: Bool

    public let preservedWorkerDirectLocalDependencyNames: [String]
    public let workerDirectLocalDependencyNames: [String]
    public let exactAddedWorkerDependencyCount: Int
    public let addedWorkerDependencyTargetName: String
    public let preservedDependenciesRemainExactPrefix: Bool

    public let callEdgeEnclosingTypeName: String
    public let callEdgeMethodName: String
    public let callEdgeNormalizedSignature: String
    public let callEdgeAccessLevel: String
    public let callEdgeDeclaredInMainSource: Bool
    public let callEdgeUsesBundleModule: Bool
    public let callEdgeResourceName: String
    public let callEdgeResourceExtension: String
    public let callEdgeResourceSubdirectory: String
    public let callEdgeMaterializerTypeName: String
    public let callEdgeExporterTypeName: String
    public let callEdgeExporterMethodName: String
    public let callEdgeExporterInputExpression: String
    public let callEdgeOutputSwiftTypeName: String

    public let mainSourceContainsExporterImportOrSymbol: Bool
    public let mainRemainsUnconditionalUnavailableExit: Bool
    public let unavailableExitStatus: Int32
    public let mainCanReachCallEdge: Bool
    public let callEdgeSourceContainsMainDeclaration: Bool

    public let workerDeclaredAsProduct: Bool
    public let workerTargetRemainsExecutable: Bool
    public let packageGraphChanged: Bool
    public let workerSourceInventoryChanged: Bool
    public let exporterTargetSourceOrDependenciesChanged: Bool
    public let testsImportOrInvokeWorkerOrExporter: Bool

    public let workerSealed: Bool
    public let workerLaunched: Bool
    public let workerExecuted: Bool
    public let workerRequestHandlingEnabled: Bool
    public let fixtureMaterialized: Bool
    public let exporterInvoked: Bool
    public let modelExecutionObserved: Bool
    public let historicalGateExecuted: Bool
    public let historicalEvidenceObserved: Bool
    public let evidenceEncodedOrPublished: Bool
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
        let worker =
            PrimeNativeNeuralGateHistoricalFixtureWorkerSourceContract
            .frozenV1
        let exporter =
            PrimeNativeNeuralGateHistoricalEvidenceExportSourceContract
            .frozenV1
        let topology =
            PrimeNativeNeuralGateTrapDisjointTopologyContract
            .frozenV13
        let preservedDependencies = [
            "PrimeCore",
            "ErgenticsPrimeRuntime",
            "PrimeNativeNeuralGateHistoricalReplayMechanics",
            "PrimeNativeNeuralGateReplayTransport",
        ]
        let exporterTargetName =
            "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics"

        return Self(
            schemaVersion: 1,
            contractID:
                "prime_source_bound_historical_worker_evidence_export_call_edge_v14",
            rightsHolder: "Ergentics, LLC",
            licenseExpression:
                "LicenseRef-Ergentics-Proprietary",
            preservedWorkerSourceContractID:
                worker.contractID,
            preservedWorkerSourceContractSHA256:
                "64f0de29eed04145db6b598f2895bf9ee9d7804b03b35971f1ca77a72f76e9fb",
            preservedExporterSourceContractID:
                exporter.contractID,
            preservedExporterSourceContractSHA256:
                "ecc329a7e56d843b53f9d894af4e335c9d00ac05d56efe308d61860835278d5e",
            preservedTopologyV13ID: topology.contractID,
            preservedTopologyV13SHA256:
                "b1564c277a50b8bc2b2ba325809130920dcb123f0d02297efba73e3bb3aec4ea",
            workerTargetName:
                "PrimeNativeNeuralGateHistoricalFixtureWorker",
            primaryWorkerSourceRelativePath:
                "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalFixtureWorker.swift",
            primaryWorkerSourceByteCount: 2_298,
            primaryWorkerSourceSHA256:
                "9f62827d4c35e98fb01f9984b1c227cb681dd42ac4c26147a86e9429958545df",
            primaryWorkerSourceChanged: false,
            callEdgeSourceRelativePath:
                "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalEvidenceExportCallEdge.swift",
            callEdgeSourceByteCount: 1_512,
            callEdgeSourceSHA256:
                "d3ac7fcddd43844e92b61764c458dfce6291471fd465b1bb52f5186814e10319",
            orderedWorkerSwiftSourceRelativePaths: [
                "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalEvidenceExportCallEdge.swift",
                "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalFixtureWorker.swift",
            ],
            exactWorkerSwiftSourceFileCount: 2,
            fixtureResourceRelativePath:
                "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/HistoricalFixtureEvidence/Package.resolved",
            fixtureResourceByteCount: 1_949,
            fixtureResourceSHA256:
                "cf1ba313dcb0c959e80ba09d6cbe0c56bcd921523bda5cec2c682c8ae7696ab3",
            fixtureResourceChanged: false,
            preservedWorkerDirectLocalDependencyNames:
                preservedDependencies,
            workerDirectLocalDependencyNames:
                preservedDependencies + [exporterTargetName],
            exactAddedWorkerDependencyCount: 1,
            addedWorkerDependencyTargetName:
                exporterTargetName,
            preservedDependenciesRemainExactPrefix: true,
            callEdgeEnclosingTypeName:
                "PrimeNativeNeuralGateHistoricalFixtureWorker",
            callEdgeMethodName:
                "sourceBoundHistoricalEvidenceExportCallEdge",
            callEdgeNormalizedSignature:
                "private static func sourceBoundHistoricalEvidenceExportCallEdge() throws -> PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence",
            callEdgeAccessLevel: "private",
            callEdgeDeclaredInMainSource: false,
            callEdgeUsesBundleModule: true,
            callEdgeResourceName: "Package",
            callEdgeResourceExtension: "resolved",
            callEdgeResourceSubdirectory:
                "HistoricalFixtureEvidence",
            callEdgeMaterializerTypeName:
                "EngineProposesNativeLanguageVerifyAbstainFixture",
            callEdgeExporterTypeName:
                "PrimeNativeNeuralGateHistoricalEvidenceExporter",
            callEdgeExporterMethodName: "export",
            callEdgeExporterInputExpression:
                "fixture.materials",
            callEdgeOutputSwiftTypeName:
                "PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence",
            mainSourceContainsExporterImportOrSymbol: false,
            mainRemainsUnconditionalUnavailableExit: true,
            unavailableExitStatus: 78,
            mainCanReachCallEdge: false,
            callEdgeSourceContainsMainDeclaration: false,
            workerDeclaredAsProduct: false,
            workerTargetRemainsExecutable: true,
            packageGraphChanged: true,
            workerSourceInventoryChanged: true,
            exporterTargetSourceOrDependenciesChanged: false,
            testsImportOrInvokeWorkerOrExporter: false,
            workerSealed: false,
            workerLaunched: false,
            workerExecuted: false,
            workerRequestHandlingEnabled: false,
            fixtureMaterialized: false,
            exporterInvoked: false,
            modelExecutionObserved: false,
            historicalGateExecuted: false,
            historicalEvidenceObserved: false,
            evidenceEncodedOrPublished: false,
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
                "design_and_source_bind_the_historical_evidence_carrier_to_frozen_worker_semantic_artifact_projection_without_enabling_worker_request_handling_sealing_launch_execution_or_issuing_source_binding_v7",
            authorityStatement:
                "This V14 source contract preserves the exact V11 primary worker source, unavailable main, pinned fixture resource, V13 historical evidence exporter source, and V13 topology identities. It adds one separately pinned Swift file to the existing historical worker target and appends exactly one direct local dependency on the existing product-free exporter target. The new source contains a private extension member in a different file from main; it performs the exact Bundle.module Package.resolved lookup, source-faithful historical fixture materialization expression, and typed PrimeNativeNeuralGateHistoricalEvidenceExporter.export(fixture.materials) call only if a later source change makes it reachable. The existing main remains an unconditional Darwin.exit(78) and cannot name the private cross-file member. Package compilation proves only the typed call edge. No worker request handling, sealing, launch, worker/fixture/exporter/gate/model execution, evidence observation, encoding, artifact write, durable publication, independent detection, distinct implementation family, AgentContractKit four-tier audit, mechanics PASS, terminal receipt, source or execution binding V7, scientific authority, or product authority is observed or authorized."
        )
    }()

    public func validate() throws {
        let worker =
            PrimeNativeNeuralGateHistoricalFixtureWorkerSourceContract
            .frozenV1
        let exporter =
            PrimeNativeNeuralGateHistoricalEvidenceExportSourceContract
            .frozenV1
        let topology =
            PrimeNativeNeuralGateTrapDisjointTopologyContract
            .frozenV13
        try worker.validate()
        try exporter.validate()
        try topology.validate()

        guard self == .frozenV1,
              schemaVersion == 1,
              contractID
                == "prime_source_bound_historical_worker_evidence_export_call_edge_v14",
              rightsHolder == "Ergentics, LLC",
              licenseExpression
                == "LicenseRef-Ergentics-Proprietary",
              preservedWorkerSourceContractID
                == worker.contractID,
              preservedWorkerSourceContractSHA256
                == (try worker.contentSHA256()),
              preservedExporterSourceContractID
                == exporter.contractID,
              preservedExporterSourceContractSHA256
                == (try exporter.contentSHA256()),
              preservedTopologyV13ID == topology.contractID,
              preservedTopologyV13SHA256
                == (try topology.contentSHA256()),
              workerTargetName
                == "PrimeNativeNeuralGateHistoricalFixtureWorker",
              primaryWorkerSourceByteCount == 2_298,
              primaryWorkerSourceSHA256
                == "9f62827d4c35e98fb01f9984b1c227cb681dd42ac4c26147a86e9429958545df",
              !primaryWorkerSourceChanged,
              callEdgeSourceByteCount == 1_512,
              callEdgeSourceSHA256
                == "d3ac7fcddd43844e92b61764c458dfce6291471fd465b1bb52f5186814e10319",
              orderedWorkerSwiftSourceRelativePaths.count == 2,
              Set(orderedWorkerSwiftSourceRelativePaths).count == 2,
              exactWorkerSwiftSourceFileCount == 2,
              fixtureResourceByteCount == 1_949,
              fixtureResourceSHA256
                == "cf1ba313dcb0c959e80ba09d6cbe0c56bcd921523bda5cec2c682c8ae7696ab3",
              !fixtureResourceChanged,
              workerDirectLocalDependencyNames
                == preservedWorkerDirectLocalDependencyNames
                    + [addedWorkerDependencyTargetName],
              preservedWorkerDirectLocalDependencyNames.count == 4,
              exactAddedWorkerDependencyCount == 1,
              addedWorkerDependencyTargetName
                == exporter.targetBinding.targetName,
              preservedDependenciesRemainExactPrefix,
              callEdgeEnclosingTypeName == workerTargetName,
              callEdgeMethodName
                == "sourceBoundHistoricalEvidenceExportCallEdge",
              callEdgeAccessLevel == "private",
              !callEdgeDeclaredInMainSource,
              callEdgeUsesBundleModule,
              callEdgeResourceName == "Package",
              callEdgeResourceExtension == "resolved",
              callEdgeResourceSubdirectory
                == "HistoricalFixtureEvidence",
              callEdgeMaterializerTypeName
                == "EngineProposesNativeLanguageVerifyAbstainFixture",
              callEdgeExporterTypeName
                == exporter.publicFacadeTypeName,
              callEdgeExporterMethodName
                == exporter.publicFacadeMethodName,
              callEdgeExporterInputExpression
                == "fixture.materials",
              callEdgeOutputSwiftTypeName
                == exporter.publicFacadeOutputSwiftTypeName,
              !mainSourceContainsExporterImportOrSymbol,
              mainRemainsUnconditionalUnavailableExit,
              unavailableExitStatus == 78,
              !mainCanReachCallEdge,
              !callEdgeSourceContainsMainDeclaration,
              !workerDeclaredAsProduct,
              workerTargetRemainsExecutable,
              packageGraphChanged,
              workerSourceInventoryChanged,
              !exporterTargetSourceOrDependenciesChanged,
              !testsImportOrInvokeWorkerOrExporter,
              !workerSealed,
              !workerLaunched,
              !workerExecuted,
              !workerRequestHandlingEnabled,
              !fixtureMaterialized,
              !exporterInvoked,
              !modelExecutionObserved,
              !historicalGateExecuted,
              !historicalEvidenceObserved,
              !evidenceEncodedOrPublished,
              !durablePublicationObserved,
              !independentDetectionEstablished,
              !distinctImplementationFamiliesEstablished,
              !agentContractKitFourTierAuditPerformed,
              !mechanicsPassAuthorized,
              !terminalReceiptAuthorized,
              !sourceBindingV7Issued,
              !scientificAuthorityAuthorized,
              !productAuthorityAuthorized
        else {
            throw PrimeNativeNeuralGateHistoricalWorkerEvidenceExportCallEdgeSourceContractError
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
        case preservedWorkerSourceContractID =
            "preserved_worker_source_contract_id"
        case preservedWorkerSourceContractSHA256 =
            "preserved_worker_source_contract_sha256"
        case preservedExporterSourceContractID =
            "preserved_exporter_source_contract_id"
        case preservedExporterSourceContractSHA256 =
            "preserved_exporter_source_contract_sha256"
        case preservedTopologyV13ID =
            "preserved_topology_v13_id"
        case preservedTopologyV13SHA256 =
            "preserved_topology_v13_sha256"
        case workerTargetName = "worker_target_name"
        case primaryWorkerSourceRelativePath =
            "primary_worker_source_relative_path"
        case primaryWorkerSourceByteCount =
            "primary_worker_source_byte_count"
        case primaryWorkerSourceSHA256 =
            "primary_worker_source_sha256"
        case primaryWorkerSourceChanged =
            "primary_worker_source_changed"
        case callEdgeSourceRelativePath =
            "call_edge_source_relative_path"
        case callEdgeSourceByteCount =
            "call_edge_source_byte_count"
        case callEdgeSourceSHA256 =
            "call_edge_source_sha256"
        case orderedWorkerSwiftSourceRelativePaths =
            "ordered_worker_swift_source_relative_paths"
        case exactWorkerSwiftSourceFileCount =
            "exact_worker_swift_source_file_count"
        case fixtureResourceRelativePath =
            "fixture_resource_relative_path"
        case fixtureResourceByteCount =
            "fixture_resource_byte_count"
        case fixtureResourceSHA256 =
            "fixture_resource_sha256"
        case fixtureResourceChanged =
            "fixture_resource_changed"
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
        case callEdgeEnclosingTypeName =
            "call_edge_enclosing_type_name"
        case callEdgeMethodName = "call_edge_method_name"
        case callEdgeNormalizedSignature =
            "call_edge_normalized_signature"
        case callEdgeAccessLevel = "call_edge_access_level"
        case callEdgeDeclaredInMainSource =
            "call_edge_declared_in_main_source"
        case callEdgeUsesBundleModule =
            "call_edge_uses_bundle_module"
        case callEdgeResourceName = "call_edge_resource_name"
        case callEdgeResourceExtension =
            "call_edge_resource_extension"
        case callEdgeResourceSubdirectory =
            "call_edge_resource_subdirectory"
        case callEdgeMaterializerTypeName =
            "call_edge_materializer_type_name"
        case callEdgeExporterTypeName =
            "call_edge_exporter_type_name"
        case callEdgeExporterMethodName =
            "call_edge_exporter_method_name"
        case callEdgeExporterInputExpression =
            "call_edge_exporter_input_expression"
        case callEdgeOutputSwiftTypeName =
            "call_edge_output_swift_type_name"
        case mainSourceContainsExporterImportOrSymbol =
            "main_source_contains_exporter_import_or_symbol"
        case mainRemainsUnconditionalUnavailableExit =
            "main_remains_unconditional_unavailable_exit"
        case unavailableExitStatus = "unavailable_exit_status"
        case mainCanReachCallEdge = "main_can_reach_call_edge"
        case callEdgeSourceContainsMainDeclaration =
            "call_edge_source_contains_main_declaration"
        case workerDeclaredAsProduct =
            "worker_declared_as_product"
        case workerTargetRemainsExecutable =
            "worker_target_remains_executable"
        case packageGraphChanged = "package_graph_changed"
        case workerSourceInventoryChanged =
            "worker_source_inventory_changed"
        case exporterTargetSourceOrDependenciesChanged =
            "exporter_target_source_or_dependencies_changed"
        case testsImportOrInvokeWorkerOrExporter =
            "tests_import_or_invoke_worker_or_exporter"
        case workerSealed = "worker_sealed"
        case workerLaunched = "worker_launched"
        case workerExecuted = "worker_executed"
        case workerRequestHandlingEnabled =
            "worker_request_handling_enabled"
        case fixtureMaterialized = "fixture_materialized"
        case exporterInvoked = "exporter_invoked"
        case modelExecutionObserved =
            "model_execution_observed"
        case historicalGateExecuted = "historical_gate_executed"
        case historicalEvidenceObserved =
            "historical_evidence_observed"
        case evidenceEncodedOrPublished =
            "evidence_encoded_or_published"
        case durablePublicationObserved =
            "durable_publication_observed"
        case independentDetectionEstablished =
            "independent_detection_established"
        case distinctImplementationFamiliesEstablished =
            "distinct_implementation_families_established"
        case agentContractKitFourTierAuditPerformed =
            "agent_contract_kit_four_tier_audit_performed"
        case mechanicsPassAuthorized = "mechanics_pass_authorized"
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
