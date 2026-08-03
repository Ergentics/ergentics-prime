// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

public enum
    PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingSourceContractError:
    Error,
    Equatable,
    Sendable
{
    case invalidFrozenContract
}

public enum
    PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingBroadSuiteObservation:
    String,
    Codable,
    Equatable,
    Sendable
{
    case notCompletedWithinBoundedObservation =
        "not_completed_within_bounded_observation"
}

public struct
    PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingSourceIdentity:
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
                || primeRelativePath == "Package.swift"
                || primeRelativePath == "Package.resolved"
        )
            && !primeRelativePath.contains("..")
            && !primeRelativePath.contains("\\")
            && byteCount > 0
            && sha256.utf8.count == 64
            && sha256 != String(repeating: "0", count: 64)
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

/// Frozen V27 source receipt for the exact V26-designed raw-seam
/// `internal` to `private` access rebinding.
///
/// This contract binds source and compiler behavior only. It creates no caller,
/// request path, launch, execution, confidentiality boundary or authority.
public struct
    PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingSourceContract:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let contractID: String
    public let rightsHolder: String
    public let licenseExpression: String

    public let preservedPrivateAccessRebindingDesignV26ContractID: String
    public let preservedPrivateAccessRebindingDesignV26ContractSHA256: String
    public let preservedTopologyV26ID: String
    public let preservedTopologyV26SHA256: String

    public let privateAccessRebindingDesignContractSource:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingSourceIdentity
    public let historicalTopologySourceBeforeV27:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingSourceIdentity
    public let topologyV26Test:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingSourceIdentity
    public let historicalTestIdentitiesBeforeV27:
        [PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingSourceIdentity]
    public let historicalTestIdentitiesAfterV27:
        [PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingSourceIdentity]

    public let packageSwift:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingSourceIdentity
    public let packageResolved:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingSourceIdentity
    public let workerMain:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingSourceIdentity
    public let workerEvidenceExportCallEdgeSource:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingSourceIdentity
    public let workerProjectionCallEdgeSource:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingSourceIdentity
    public let workerPrivateInvocationSeamAndBoundarySourceV27:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingSourceIdentity
    public let workerFixtureResource:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingSourceIdentity

    public let workerTargetName: String
    public let orderedWorkerSwiftSourceRelativePaths: [String]
    public let exactWorkerSwiftSourceFileCount: Int
    public let workerDirectLocalDependencyNames: [String]
    public let exactWorkerDirectLocalDependencyCount: Int
    public let workerResourceRelativePaths: [String]
    public let exactWorkerResourceCount: Int
    public let exactInvocationSourceImportNames: [String]
    public let physicalWorkerInventoryExact: Bool
    public let packageGraphChanged: Bool
    public let targetGraphChanged: Bool
    public let forbiddenReachabilityChanged: Bool
    public let workerSourceInventoryChanged: Bool
    public let workerDependenciesChanged: Bool
    public let workerResourcesChanged: Bool
    public let importInventoryChanged: Bool

    public let adoptedMutation:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingMutationGeometry
    public let adoptedAccessMatrix:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingAccessMatrix
    public let designProjectionMatchesCheckedInSource: Bool
    public let reverseReconstructionMatchesV25Source: Bool
    public let everyByteOutsideAuthorizedTokenRangePreserved: Bool
    public let checkedInWorkerSourceChangedByV27: Bool
    public let sourceEvolutionAppendOnly: Bool
    public let sourceEvolutionSingleNonAppendOnlyTokenReplacement: Bool
    public let anyOtherWorkerSourceByteChanged: Bool

    public let rawSeamActualAccessLevel: String
    public let rawSeamNormalizedSignature: String
    public let exactInternalRawSeamDeclarationCount: Int
    public let exactPrivateRawSeamDeclarationCount: Int
    public let exactRawSeamExecutableCallerCount: Int
    public let preservedBoundaryAccessLevel: String
    public let preservedBoundaryMethodName: String
    public let preservedBoundaryNormalizedSignature: String
    public let preservedBoundaryNormalizedBody: String
    public let exactBoundaryDeclarationCount: Int
    public let exactBoundaryExecutableCallerCount: Int
    public let boundaryRemainsSoleCheckedInRawSeamCaller: Bool
    public let evidencePassedToRawSeamUnchanged: Bool
    public let contextPassedToRawSeamUnchanged: Bool
    public let opaqueWrapperStillDiscardedWithoutBinding: Bool
    public let everySwiftErrorCaughtByBoundaryMapsWithoutDetail: Bool

    public let isolatedFreshReleaseWorkerProductBuildObserved: Bool
    public let releaseWorkerProductCompiledAndLinked: Bool
    public let releaseWorkerProductLaunched: Bool
    public let actualSameFileRawSeamCallerCompiled: Bool
    public let actualFifthPhysicalFileDirectNameCompilerCanaryRejected: Bool
    public let minimalTwoPhysicalFileDirectNameCompilerCanaryRejected: Bool
    public let testableImportDirectNameCompilerCanaryRejected: Bool
    public let compilerRejectionReasonPrivateProtectionLevelObserved: Bool

    public let mainReferencesRawSeamOrBoundary: Bool
    public let crossFileBoundaryCallerMaterialized: Bool
    public let runtimeReachableFromMain: Bool
    public let mainRemainsUnconditionalUnavailableExit: Bool
    public let unavailableExitStatus: Int32
    public let runtimeInputAccepted: Bool
    public let runtimeOutputProduced: Bool
    public let requestHandlingEnabled: Bool
    public let replayTransportIntegrated: Bool
    public let workerSealed: Bool
    public let workerLaunched: Bool
    public let workerExecuted: Bool
    public let compositionRuntimeExercised: Bool
    public let fixtureExporterProjectorOrDecoderExecuted: Bool
    public let gateModelTrainingMutationTriadSZOrEvaluationExecuted: Bool
    public let workerRuntimeArtifactFilesystemReadPerformed: Bool
    public let artifactWritePerformed: Bool
    public let evidencePublished: Bool
    public let durablePublicationObserved: Bool
    public let mechanicsPassAuthorized: Bool
    public let terminalReceiptAuthorized: Bool
    public let sourceBindingV7Issued: Bool
    public let scientificAuthorityAuthorized: Bool
    public let productAuthorityAuthorized: Bool
    public let primeDisposition: String

    public let ordinarySwiftCrossFileDirectRawSeamNameabilityPrevented: Bool
    public let authenticatedCallerPolicyEstablished: Bool
    public let confidentialityEstablished: Bool
    public let zeroizationEstablished: Bool
    public let constantTimeEstablished: Bool
    public let constantResourceUseEstablished: Bool
    public let trapsSignalsOrOutOfMemoryContained: Bool
    public let hardenedIsolationRequiredBeforeUntrustedRuntime: Bool

    public let broadRepositorySuiteObservation:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingBroadSuiteObservation
    public let broadRepositorySuiteBoundedObservationSeconds: UInt64
    public let broadRepositorySuiteCountsAsPassing: Bool
    public let gitConfigurationCauseEstablished: Bool
    public let recursivePredecessorValidationPerformanceDebtObserved: Bool
    public let performanceRemediationIncludedInV27: Bool

    public let nextImplementationPrerequisite: String
    public let authorityStatement: String

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case contractID = "contract_id"
        case rightsHolder = "rights_holder"
        case licenseExpression = "license_expression"
        case preservedPrivateAccessRebindingDesignV26ContractID =
            "preserved_private_access_rebinding_design_v26_contract_id"
        case preservedPrivateAccessRebindingDesignV26ContractSHA256 =
            "preserved_private_access_rebinding_design_v26_contract_sha256"
        case preservedTopologyV26ID = "preserved_topology_v26_id"
        case preservedTopologyV26SHA256 = "preserved_topology_v26_sha256"
        case privateAccessRebindingDesignContractSource =
            "private_access_rebinding_design_contract_source"
        case historicalTopologySourceBeforeV27 =
            "historical_topology_source_before_v27"
        case topologyV26Test = "topology_v26_test"
        case historicalTestIdentitiesBeforeV27 =
            "historical_test_identities_before_v27"
        case historicalTestIdentitiesAfterV27 =
            "historical_test_identities_after_v27"
        case packageSwift = "package_swift"
        case packageResolved = "package_resolved"
        case workerMain = "worker_main"
        case workerEvidenceExportCallEdgeSource =
            "worker_evidence_export_call_edge_source"
        case workerProjectionCallEdgeSource =
            "worker_projection_call_edge_source"
        case workerPrivateInvocationSeamAndBoundarySourceV27 =
            "worker_private_invocation_seam_and_boundary_source_v27"
        case workerFixtureResource = "worker_fixture_resource"
        case workerTargetName = "worker_target_name"
        case orderedWorkerSwiftSourceRelativePaths =
            "ordered_worker_swift_source_relative_paths"
        case exactWorkerSwiftSourceFileCount =
            "exact_worker_swift_source_file_count"
        case workerDirectLocalDependencyNames =
            "worker_direct_local_dependency_names"
        case exactWorkerDirectLocalDependencyCount =
            "exact_worker_direct_local_dependency_count"
        case workerResourceRelativePaths = "worker_resource_relative_paths"
        case exactWorkerResourceCount = "exact_worker_resource_count"
        case exactInvocationSourceImportNames =
            "exact_invocation_source_import_names"
        case physicalWorkerInventoryExact = "physical_worker_inventory_exact"
        case packageGraphChanged = "package_graph_changed"
        case targetGraphChanged = "target_graph_changed"
        case forbiddenReachabilityChanged = "forbidden_reachability_changed"
        case workerSourceInventoryChanged = "worker_source_inventory_changed"
        case workerDependenciesChanged = "worker_dependencies_changed"
        case workerResourcesChanged = "worker_resources_changed"
        case importInventoryChanged = "import_inventory_changed"
        case adoptedMutation = "adopted_mutation"
        case adoptedAccessMatrix = "adopted_access_matrix"
        case designProjectionMatchesCheckedInSource =
            "design_projection_matches_checked_in_source"
        case reverseReconstructionMatchesV25Source =
            "reverse_reconstruction_matches_v25_source"
        case everyByteOutsideAuthorizedTokenRangePreserved =
            "every_byte_outside_authorized_token_range_preserved"
        case checkedInWorkerSourceChangedByV27 =
            "checked_in_worker_source_changed_by_v27"
        case sourceEvolutionAppendOnly = "source_evolution_append_only"
        case sourceEvolutionSingleNonAppendOnlyTokenReplacement =
            "source_evolution_single_non_append_only_token_replacement"
        case anyOtherWorkerSourceByteChanged =
            "any_other_worker_source_byte_changed"
        case rawSeamActualAccessLevel = "raw_seam_actual_access_level"
        case rawSeamNormalizedSignature = "raw_seam_normalized_signature"
        case exactInternalRawSeamDeclarationCount =
            "exact_internal_raw_seam_declaration_count"
        case exactPrivateRawSeamDeclarationCount =
            "exact_private_raw_seam_declaration_count"
        case exactRawSeamExecutableCallerCount =
            "exact_raw_seam_executable_caller_count"
        case preservedBoundaryAccessLevel =
            "preserved_boundary_access_level"
        case preservedBoundaryMethodName = "preserved_boundary_method_name"
        case preservedBoundaryNormalizedSignature =
            "preserved_boundary_normalized_signature"
        case preservedBoundaryNormalizedBody =
            "preserved_boundary_normalized_body"
        case exactBoundaryDeclarationCount =
            "exact_boundary_declaration_count"
        case exactBoundaryExecutableCallerCount =
            "exact_boundary_executable_caller_count"
        case boundaryRemainsSoleCheckedInRawSeamCaller =
            "boundary_remains_sole_checked_in_raw_seam_caller"
        case evidencePassedToRawSeamUnchanged =
            "evidence_passed_to_raw_seam_unchanged"
        case contextPassedToRawSeamUnchanged =
            "context_passed_to_raw_seam_unchanged"
        case opaqueWrapperStillDiscardedWithoutBinding =
            "opaque_wrapper_still_discarded_without_binding"
        case everySwiftErrorCaughtByBoundaryMapsWithoutDetail =
            "every_swift_error_caught_by_boundary_maps_without_detail"
        case isolatedFreshReleaseWorkerProductBuildObserved =
            "isolated_fresh_release_worker_product_build_observed"
        case releaseWorkerProductCompiledAndLinked =
            "release_worker_product_compiled_and_linked"
        case releaseWorkerProductLaunched =
            "release_worker_product_launched"
        case actualSameFileRawSeamCallerCompiled =
            "actual_same_file_raw_seam_caller_compiled"
        case actualFifthPhysicalFileDirectNameCompilerCanaryRejected =
            "actual_fifth_physical_file_direct_name_compiler_canary_rejected"
        case minimalTwoPhysicalFileDirectNameCompilerCanaryRejected =
            "minimal_two_physical_file_direct_name_compiler_canary_rejected"
        case testableImportDirectNameCompilerCanaryRejected =
            "testable_import_direct_name_compiler_canary_rejected"
        case compilerRejectionReasonPrivateProtectionLevelObserved =
            "compiler_rejection_reason_private_protection_level_observed"
        case mainReferencesRawSeamOrBoundary =
            "main_references_raw_seam_or_boundary"
        case crossFileBoundaryCallerMaterialized =
            "cross_file_boundary_caller_materialized"
        case runtimeReachableFromMain = "runtime_reachable_from_main"
        case mainRemainsUnconditionalUnavailableExit =
            "main_remains_unconditional_unavailable_exit"
        case unavailableExitStatus = "unavailable_exit_status"
        case runtimeInputAccepted = "runtime_input_accepted"
        case runtimeOutputProduced = "runtime_output_produced"
        case requestHandlingEnabled = "request_handling_enabled"
        case replayTransportIntegrated = "replay_transport_integrated"
        case workerSealed = "worker_sealed"
        case workerLaunched = "worker_launched"
        case workerExecuted = "worker_executed"
        case compositionRuntimeExercised = "composition_runtime_exercised"
        case fixtureExporterProjectorOrDecoderExecuted =
            "fixture_exporter_projector_or_decoder_executed"
        case gateModelTrainingMutationTriadSZOrEvaluationExecuted =
            "gate_model_training_mutation_triad_sz_or_evaluation_executed"
        case workerRuntimeArtifactFilesystemReadPerformed =
            "worker_runtime_artifact_filesystem_read_performed"
        case artifactWritePerformed = "artifact_write_performed"
        case evidencePublished = "evidence_published"
        case durablePublicationObserved = "durable_publication_observed"
        case mechanicsPassAuthorized = "mechanics_pass_authorized"
        case terminalReceiptAuthorized = "terminal_receipt_authorized"
        case sourceBindingV7Issued = "source_binding_v7_issued"
        case scientificAuthorityAuthorized =
            "scientific_authority_authorized"
        case productAuthorityAuthorized = "product_authority_authorized"
        case primeDisposition = "prime_disposition"
        case ordinarySwiftCrossFileDirectRawSeamNameabilityPrevented =
            "ordinary_swift_cross_file_direct_raw_seam_nameability_prevented"
        case authenticatedCallerPolicyEstablished =
            "authenticated_caller_policy_established"
        case confidentialityEstablished = "confidentiality_established"
        case zeroizationEstablished = "zeroization_established"
        case constantTimeEstablished = "constant_time_established"
        case constantResourceUseEstablished =
            "constant_resource_use_established"
        case trapsSignalsOrOutOfMemoryContained =
            "traps_signals_or_out_of_memory_contained"
        case hardenedIsolationRequiredBeforeUntrustedRuntime =
            "hardened_isolation_required_before_untrusted_runtime"
        case broadRepositorySuiteObservation =
            "broad_repository_suite_observation"
        case broadRepositorySuiteBoundedObservationSeconds =
            "broad_repository_suite_bounded_observation_seconds"
        case broadRepositorySuiteCountsAsPassing =
            "broad_repository_suite_counts_as_passing"
        case gitConfigurationCauseEstablished =
            "git_configuration_cause_established"
        case recursivePredecessorValidationPerformanceDebtObserved =
            "recursive_predecessor_validation_performance_debt_observed"
        case performanceRemediationIncludedInV27 =
            "performance_remediation_included_in_v27"
        case nextImplementationPrerequisite =
            "next_implementation_prerequisite"
        case authorityStatement = "authority_statement"
    }

    public static let frozenV1: Self = {
        let design =
            PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingDesignContract
            .frozenV1
        let worker =
            "PrimeNativeNeuralGateHistoricalFixtureWorker"
        let workerDirectory = "Sources/\(worker)/"
        let invocationSourcePath =
            workerDirectory
            + "PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactDecoderCallEdge.swift"
        let v23Test =
            "Tests/PrimeCoreTests/PrimeNativeNeuralGateHistoricalWorkerInvocationSeamSourceContractTests.swift"
        let v24Test =
            "Tests/PrimeCoreTests/PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerDesignContractTests.swift"
        let v25Test =
            "Tests/PrimeCoreTests/PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerSourceContractTests.swift"
        let v26Test =
            "Tests/PrimeCoreTests/PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingDesignContractTests.swift"

        return Self(
            schemaVersion: 1,
            contractID:
                "prime_source_bound_historical_worker_bounded_unavailable_composition_invocation_seam_private_access_rebinding_v27",
            rightsHolder: "Ergentics, LLC",
            licenseExpression: "LicenseRef-Ergentics-Proprietary",
            preservedPrivateAccessRebindingDesignV26ContractID:
                design.contractID,
            preservedPrivateAccessRebindingDesignV26ContractSHA256:
                "58bd67d365c38337b1eda6d2ca8e28422125f424ff7eccec72ca151a91dd4f8e",
            preservedTopologyV26ID:
                "prime_stage_b_historical_worker_bounded_unavailable_composition_invocation_seam_private_access_rebinding_security_design_topology_v26",
            preservedTopologyV26SHA256:
                "dfbba4e7adecac57febd8ab0946ab34f698d63d6b55d3fe119fe53c029c8da63",
            privateAccessRebindingDesignContractSource: .init(
                primeRelativePath:
                    "Sources/PrimeCore/PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingDesignContract.swift",
                byteCount: 53_925,
                sha256:
                    "9c1f8144e776a8dadf1c0586aaf470a44496e5168bf8079780c87d17ee424fd5"
            ),
            historicalTopologySourceBeforeV27: .init(
                primeRelativePath:
                    "Sources/PrimeCore/PrimeNativeNeuralGateTrapDisjointTopology.swift",
                byteCount: 273_346,
                sha256:
                    "d4446c98bb5e3baed9ecd62b1a7aa7734e62e5264463597d4fbf2c17410529b7"
            ),
            topologyV26Test: .init(
                primeRelativePath:
                    "Tests/PrimeCoreTests/PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingDesignTopologyV26Tests.swift",
                byteCount: 17_024,
                sha256:
                    "e5aba602873dbbfce17decbc3d8c610ae3792f60e301e470890adecad606434a"
            ),
            historicalTestIdentitiesBeforeV27: [
                .init(
                    primeRelativePath: v23Test,
                    byteCount: 32_576,
                    sha256:
                        "3ac8faf37a870a38b6893f6962212d58bdcc1ee91ce1d8af722ef66bef0bb1a0"
                ),
                .init(
                    primeRelativePath: v24Test,
                    byteCount: 28_931,
                    sha256:
                        "8b964c9beaac49a42a2d5fdabd427c5d7d5ddadcd6e64a65ca87b6d7ff4c8926"
                ),
                .init(
                    primeRelativePath: v25Test,
                    byteCount: 33_946,
                    sha256:
                        "f0d754eee4f1030bc3f28e21d90d1f3e55298293d4f25d8d2614c4a0b0f9b1d7"
                ),
                .init(
                    primeRelativePath: v26Test,
                    byteCount: 29_270,
                    sha256:
                        "ec54c97e6ac4173444dc150e5b320c3b331fe6bc36481a43c2a46c5e7d58601e"
                ),
            ],
            historicalTestIdentitiesAfterV27: [
                .init(
                    primeRelativePath: v23Test,
                    byteCount: 33_756,
                    sha256:
                        "6b29947654a68154a91623335d0a887b306a57baf17845c35484bff1cd0a2e8c"
                ),
                .init(
                    primeRelativePath: v24Test,
                    byteCount: 30_344,
                    sha256:
                        "b5b3acfec3b8179d46d9c8f01a50b17c4abd88dd119c625c1ad5773ee938e522"
                ),
                .init(
                    primeRelativePath: v25Test,
                    byteCount: 34_735,
                    sha256:
                        "40db1438d8b5fc3a283c4516fccaf70ccb560fde5cdb586af7d838bcf74110f9"
                ),
                .init(
                    primeRelativePath: v26Test,
                    byteCount: 32_076,
                    sha256:
                        "9b1d961ab9ea87ef8b57b032ba4f781b295d9c35a48659e28e9ca30e73e6ac4c"
                ),
            ],
            packageSwift: .init(
                primeRelativePath: "Package.swift",
                byteCount: 27_650,
                sha256:
                    "190b1d2dbeb2597830b1765fa80d6776a0044a34d5e2c6db8b14ace013654e7d"
            ),
            packageResolved: .init(
                primeRelativePath: "Package.resolved",
                byteCount: 1_182,
                sha256:
                    "da7f7baa10f6da34b01ad69dc116f8a2d31140eca6770cb562ac05a7c50b356c"
            ),
            workerMain: .init(
                primeRelativePath:
                    workerDirectory
                    + "PrimeNativeNeuralGateHistoricalFixtureWorker.swift",
                byteCount: 2_298,
                sha256:
                    "9f62827d4c35e98fb01f9984b1c227cb681dd42ac4c26147a86e9429958545df"
            ),
            workerEvidenceExportCallEdgeSource: .init(
                primeRelativePath:
                    workerDirectory
                    + "PrimeNativeNeuralGateHistoricalEvidenceExportCallEdge.swift",
                byteCount: 1_512,
                sha256:
                    "d3ac7fcddd43844e92b61764c458dfce6291471fd465b1bb52f5186814e10319"
            ),
            workerProjectionCallEdgeSource: .init(
                primeRelativePath:
                    workerDirectory
                    + "PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactProjectionCallEdge.swift",
                byteCount: 1_227,
                sha256:
                    "dce631bd4749a05d8f04323b51c4da37e5ef67df14b950f1e5eee1d1565e0964"
            ),
            workerPrivateInvocationSeamAndBoundarySourceV27: .init(
                primeRelativePath: invocationSourcePath,
                byteCount: 14_174,
                sha256:
                    "767cc0101c52a311d40acc1dbba1747b7e3cdf7430f73d69a168ab62d1290e15"
            ),
            workerFixtureResource: .init(
                primeRelativePath:
                    workerDirectory
                    + "HistoricalFixtureEvidence/Package.resolved",
                byteCount: 1_949,
                sha256:
                    "cf1ba313dcb0c959e80ba09d6cbe0c56bcd921523bda5cec2c682c8ae7696ab3"
            ),
            workerTargetName: worker,
            orderedWorkerSwiftSourceRelativePaths: [
                workerDirectory
                    + "PrimeNativeNeuralGateHistoricalEvidenceExportCallEdge.swift",
                workerDirectory
                    + "PrimeNativeNeuralGateHistoricalFixtureWorker.swift",
                invocationSourcePath,
                workerDirectory
                    + "PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactProjectionCallEdge.swift",
            ],
            exactWorkerSwiftSourceFileCount: 4,
            workerDirectLocalDependencyNames: [
                "PrimeCore",
                "ErgenticsPrimeRuntime",
                "PrimeNativeNeuralGateHistoricalReplayMechanics",
                "PrimeNativeNeuralGateReplayTransport",
                "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics",
                "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection",
                "PrimeNativeNeuralGateHistoricalSemanticArtifactDecoder",
            ],
            exactWorkerDirectLocalDependencyCount: 7,
            workerResourceRelativePaths: [
                workerDirectory
                    + "HistoricalFixtureEvidence/Package.resolved"
            ],
            exactWorkerResourceCount: 1,
            exactInvocationSourceImportNames: [
                "Foundation",
                "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection",
                "PrimeNativeNeuralGateHistoricalSemanticArtifactDecoder",
                "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics",
            ],
            physicalWorkerInventoryExact: true,
            packageGraphChanged: false,
            targetGraphChanged: false,
            forbiddenReachabilityChanged: false,
            workerSourceInventoryChanged: false,
            workerDependenciesChanged: false,
            workerResourcesChanged: false,
            importInventoryChanged: false,
            adoptedMutation: design.mutation,
            adoptedAccessMatrix: design.accessMatrix,
            designProjectionMatchesCheckedInSource: true,
            reverseReconstructionMatchesV25Source: true,
            everyByteOutsideAuthorizedTokenRangePreserved: true,
            checkedInWorkerSourceChangedByV27: true,
            sourceEvolutionAppendOnly: false,
            sourceEvolutionSingleNonAppendOnlyTokenReplacement: true,
            anyOtherWorkerSourceByteChanged: false,
            rawSeamActualAccessLevel: "private",
            rawSeamNormalizedSignature:
                design.mutation.projectedNormalizedSignature,
            exactInternalRawSeamDeclarationCount: 0,
            exactPrivateRawSeamDeclarationCount: 1,
            exactRawSeamExecutableCallerCount: 1,
            preservedBoundaryAccessLevel: "internal",
            preservedBoundaryMethodName:
                design.preservedBoundaryMethodName,
            preservedBoundaryNormalizedSignature:
                design.preservedBoundaryNormalizedSignature,
            preservedBoundaryNormalizedBody:
                design.preservedBoundaryNormalizedBody,
            exactBoundaryDeclarationCount: 1,
            exactBoundaryExecutableCallerCount: 0,
            boundaryRemainsSoleCheckedInRawSeamCaller: true,
            evidencePassedToRawSeamUnchanged: true,
            contextPassedToRawSeamUnchanged: true,
            opaqueWrapperStillDiscardedWithoutBinding: true,
            everySwiftErrorCaughtByBoundaryMapsWithoutDetail: true,
            isolatedFreshReleaseWorkerProductBuildObserved: true,
            releaseWorkerProductCompiledAndLinked: true,
            releaseWorkerProductLaunched: false,
            actualSameFileRawSeamCallerCompiled: true,
            actualFifthPhysicalFileDirectNameCompilerCanaryRejected: true,
            minimalTwoPhysicalFileDirectNameCompilerCanaryRejected: true,
            testableImportDirectNameCompilerCanaryRejected: true,
            compilerRejectionReasonPrivateProtectionLevelObserved: true,
            mainReferencesRawSeamOrBoundary: false,
            crossFileBoundaryCallerMaterialized: false,
            runtimeReachableFromMain: false,
            mainRemainsUnconditionalUnavailableExit: true,
            unavailableExitStatus: 78,
            runtimeInputAccepted: false,
            runtimeOutputProduced: false,
            requestHandlingEnabled: false,
            replayTransportIntegrated: false,
            workerSealed: false,
            workerLaunched: false,
            workerExecuted: false,
            compositionRuntimeExercised: false,
            fixtureExporterProjectorOrDecoderExecuted: false,
            gateModelTrainingMutationTriadSZOrEvaluationExecuted: false,
            workerRuntimeArtifactFilesystemReadPerformed: false,
            artifactWritePerformed: false,
            evidencePublished: false,
            durablePublicationObserved: false,
            mechanicsPassAuthorized: false,
            terminalReceiptAuthorized: false,
            sourceBindingV7Issued: false,
            scientificAuthorityAuthorized: false,
            productAuthorityAuthorized: false,
            primeDisposition: "ABSTAIN",
            ordinarySwiftCrossFileDirectRawSeamNameabilityPrevented: true,
            authenticatedCallerPolicyEstablished: false,
            confidentialityEstablished: false,
            zeroizationEstablished: false,
            constantTimeEstablished: false,
            constantResourceUseEstablished: false,
            trapsSignalsOrOutOfMemoryContained: false,
            hardenedIsolationRequiredBeforeUntrustedRuntime: true,
            broadRepositorySuiteObservation:
                .notCompletedWithinBoundedObservation,
            broadRepositorySuiteBoundedObservationSeconds: 1_800,
            broadRepositorySuiteCountsAsPassing: false,
            gitConfigurationCauseEstablished: false,
            recursivePredecessorValidationPerformanceDebtObserved: true,
            performanceRemediationIncludedInV27: false,
            nextImplementationPrerequisite:
                "design_hardened_nonexporting_fixture_only_isolation_authenticated_caller_and_observation_policy_with_explicit_timing_resource_crash_trap_signal_and_out_of_memory_containment_before_any_main_cross_file_caller_request_transport_launch_runtime_or_confidentiality_claim",
            authorityStatement: [
                "V27 preserves every V1 through V26 canonical contract and topology as history and source-binds only the exact V26-designed one-token raw invocation-seam access rebinding.",
                "The checked-in worker source is exactly 14,174 bytes with private at 12,555..<12,562; replacing only those seven bytes with internal reconstructs the exact 14,175-byte V25 source, and every prefix, suffix, V25 boundary, import, package edge, target edge, dependency, resource and forbidden-reachability edge remains exact.",
                "An isolated fresh Release worker product build compiled and linked the actual source; the unchanged same-file boundary caller compiled, while actual fifth-file, minimal two-file and testable-import direct raw-seam naming probes were rejected for private protection.",
                "Private narrows ordinary direct Swift naming only. The internal V25 boundary remains same-module and testable nameable, a future same-file extension can add a caller, and compiler privilege, debugger, dynamic, injected, reflection-after-possession and unsafe routes remain outside the guarantee.",
                "No authenticated caller, confidentiality, zeroization, constant-time or constant-resource behavior, or crash, trap, signal, out-of-memory, timing or resource containment is established.",
                "No main or cross-file caller, request, transport, launch, execution, runtime input or output, artifact I/O, publication, mechanics PASS, receipt, source-binding V7, scientific authority or product authority is materialized, observed or authorized; Prime remains ABSTAIN.",
                "The broad repository suite did not complete within the 1,800-second bounded observation and is not passing; recursive predecessor validation performance debt is tracked separately from V27 and no Git-configuration cause or remediation is claimed.",
            ].joined(separator: " ")
        )
    }()

    public func validate() throws {
        guard self == .frozenV1 else {
            throw PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingSourceContractError
                .invalidFrozenContract
        }

        let design =
            PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingDesignContract
            .frozenV1
        let topology =
            PrimeNativeNeuralGateTrapDisjointTopologyContract.frozenV26
        let designSHA256 = PrimeSHA256.hexDigest(
            of: try PrimeCanonicalJSON.encode(design)
        )
        let topologySHA256 = PrimeSHA256.hexDigest(
            of: try PrimeCanonicalJSON.encode(topology)
        )
        let identities = [
            privateAccessRebindingDesignContractSource,
            historicalTopologySourceBeforeV27,
            topologyV26Test,
            packageSwift,
            packageResolved,
            workerMain,
            workerEvidenceExportCallEdgeSource,
            workerProjectionCallEdgeSource,
            workerPrivateInvocationSeamAndBoundarySourceV27,
            workerFixtureResource,
        ] + historicalTestIdentitiesBeforeV27
            + historicalTestIdentitiesAfterV27

        guard identities.allSatisfy({ $0.validate() }),
              preservedPrivateAccessRebindingDesignV26ContractID
                == design.contractID,
              preservedPrivateAccessRebindingDesignV26ContractSHA256
                == designSHA256,
              preservedPrivateAccessRebindingDesignV26ContractSHA256
                == "58bd67d365c38337b1eda6d2ca8e28422125f424ff7eccec72ca151a91dd4f8e",
              preservedTopologyV26ID == topology.contractID,
              preservedTopologyV26SHA256 == topologySHA256,
              preservedTopologyV26SHA256
                == "dfbba4e7adecac57febd8ab0946ab34f698d63d6b55d3fe119fe53c029c8da63",
              adoptedMutation == design.mutation,
              adoptedAccessMatrix == design.accessMatrix,
              adoptedMutation.projectedSourceByteCount
                == workerPrivateInvocationSeamAndBoundarySourceV27.byteCount,
              adoptedMutation.projectedSourceSHA256
                == workerPrivateInvocationSeamAndBoundarySourceV27.sha256,
              exactWorkerSwiftSourceFileCount
                == orderedWorkerSwiftSourceRelativePaths.count,
              exactWorkerDirectLocalDependencyCount
                == workerDirectLocalDependencyNames.count,
              exactWorkerResourceCount == workerResourceRelativePaths.count,
              historicalTestIdentitiesBeforeV27.count == 4,
              historicalTestIdentitiesAfterV27.count == 4,
              historicalTestIdentitiesBeforeV27.map(\.primeRelativePath)
                == historicalTestIdentitiesAfterV27.map(\.primeRelativePath),
              physicalWorkerInventoryExact,
              !packageGraphChanged,
              !targetGraphChanged,
              !forbiddenReachabilityChanged,
              !workerSourceInventoryChanged,
              !workerDependenciesChanged,
              !workerResourcesChanged,
              !importInventoryChanged,
              designProjectionMatchesCheckedInSource,
              reverseReconstructionMatchesV25Source,
              everyByteOutsideAuthorizedTokenRangePreserved,
              checkedInWorkerSourceChangedByV27,
              !sourceEvolutionAppendOnly,
              sourceEvolutionSingleNonAppendOnlyTokenReplacement,
              !anyOtherWorkerSourceByteChanged,
              rawSeamActualAccessLevel == "private",
              exactInternalRawSeamDeclarationCount == 0,
              exactPrivateRawSeamDeclarationCount == 1,
              exactRawSeamExecutableCallerCount == 1,
              preservedBoundaryAccessLevel == "internal",
              exactBoundaryDeclarationCount == 1,
              exactBoundaryExecutableCallerCount == 0,
              boundaryRemainsSoleCheckedInRawSeamCaller,
              evidencePassedToRawSeamUnchanged,
              contextPassedToRawSeamUnchanged,
              opaqueWrapperStillDiscardedWithoutBinding,
              everySwiftErrorCaughtByBoundaryMapsWithoutDetail,
              isolatedFreshReleaseWorkerProductBuildObserved,
              releaseWorkerProductCompiledAndLinked,
              !releaseWorkerProductLaunched,
              actualSameFileRawSeamCallerCompiled,
              actualFifthPhysicalFileDirectNameCompilerCanaryRejected,
              minimalTwoPhysicalFileDirectNameCompilerCanaryRejected,
              testableImportDirectNameCompilerCanaryRejected,
              compilerRejectionReasonPrivateProtectionLevelObserved,
              !mainReferencesRawSeamOrBoundary,
              !crossFileBoundaryCallerMaterialized,
              !runtimeReachableFromMain,
              mainRemainsUnconditionalUnavailableExit,
              unavailableExitStatus == 78,
              !runtimeInputAccepted,
              !runtimeOutputProduced,
              !requestHandlingEnabled,
              !replayTransportIntegrated,
              !workerSealed,
              !workerLaunched,
              !workerExecuted,
              !compositionRuntimeExercised,
              !fixtureExporterProjectorOrDecoderExecuted,
              !gateModelTrainingMutationTriadSZOrEvaluationExecuted,
              !workerRuntimeArtifactFilesystemReadPerformed,
              !artifactWritePerformed,
              !evidencePublished,
              !durablePublicationObserved,
              !mechanicsPassAuthorized,
              !terminalReceiptAuthorized,
              !sourceBindingV7Issued,
              !scientificAuthorityAuthorized,
              !productAuthorityAuthorized,
              primeDisposition == "ABSTAIN",
              ordinarySwiftCrossFileDirectRawSeamNameabilityPrevented,
              !authenticatedCallerPolicyEstablished,
              !confidentialityEstablished,
              !zeroizationEstablished,
              !constantTimeEstablished,
              !constantResourceUseEstablished,
              !trapsSignalsOrOutOfMemoryContained,
              hardenedIsolationRequiredBeforeUntrustedRuntime,
              broadRepositorySuiteObservation
                == .notCompletedWithinBoundedObservation,
              broadRepositorySuiteBoundedObservationSeconds == 1_800,
              !broadRepositorySuiteCountsAsPassing,
              !gitConfigurationCauseEstablished,
              recursivePredecessorValidationPerformanceDebtObserved,
              !performanceRemediationIncludedInV27,
              !nextImplementationPrerequisite.isEmpty,
              !authorityStatement.isEmpty
        else {
            throw PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingSourceContractError
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
