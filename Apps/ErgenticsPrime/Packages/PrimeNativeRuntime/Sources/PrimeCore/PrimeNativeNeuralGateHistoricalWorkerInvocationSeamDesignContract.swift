// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

public enum
    PrimeNativeNeuralGateHistoricalWorkerInvocationSeamDesignContractError:
    Error,
    Equatable,
    Sendable
{
    case invalidFrozenContract
}

/// Frozen V22 design boundary for one future, nonpublic invocation seam around
/// the source-bound V21 historical-worker composition.
///
/// V22 materializes no worker source. A later slice may append the reserved
/// nested wrapper to the existing V21 source file. Keeping the sole invocation
/// method on that nested wrapper is required by Swift access control: it lets
/// the method use the wrapper's private initializer and the enclosing worker's
/// unchanged private V21 call edge without widening either boundary.
public struct
    PrimeNativeNeuralGateHistoricalWorkerInvocationSeamDesignContract:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let contractID: String
    public let rightsHolder: String
    public let licenseExpression: String

    public let preservedCompositionSourceV21ContractID: String
    public let preservedCompositionSourceV21ContractSHA256: String
    public let preservedTopologyV21ID: String
    public let preservedTopologyV21SHA256: String

    public let futureSourceRelativePath: String
    public let preservedV21SourcePrefixByteCount: UInt64
    public let preservedV21SourcePrefixSHA256: String
    public let packageSwiftRelativePath: String
    public let packageSwiftByteCount: UInt64
    public let packageSwiftSHA256: String
    public let workerMainRelativePath: String
    public let workerMainByteCount: UInt64
    public let workerMainSHA256: String

    public let workerTargetName: String
    public let orderedWorkerSwiftSourceRelativePaths: [String]
    public let exactWorkerSwiftSourceFileCount: Int
    public let workerDirectLocalDependencyNames: [String]
    public let exactWorkerDirectLocalDependencyCount: Int
    public let workerResourceRelativePaths: [String]
    public let exactWorkerResourceCount: Int
    public let packageGraphMayChange: Bool
    public let targetGraphMayChange: Bool
    public let forbiddenReachabilityMayChange: Bool
    public let workerSourceInventoryMayChange: Bool
    public let workerDependenciesMayChange: Bool
    public let workerResourcesMayChange: Bool

    public let futureSourceMustBeAppendOnlySameFileContinuation: Bool
    public let futureSourceMayRewritePreservedPrefix: Bool
    public let futureSourceMayUseSeparateFile: Bool
    public let futureSourceMayChangeImportInventory: Bool
    public let preservedV21PrivateMemberNames: [String]
    public let preservedV21PrivateMemberAccessLevel: String
    public let preservedV21PrivateAccessMayChange: Bool

    public let futureWrapperEnclosingTypeName: String
    public let futureWrapperTypeName: String
    public let futureWrapperQualifiedSwiftTypeName: String
    public let futureWrapperDeclarationKind: String
    public let futureWrapperAccessLevel: String
    public let futureWrapperNestedInWorker: Bool
    public let futureWrapperPublicPackageSPIOrExported: Bool
    public let futureWrapperExactStoredFieldNames: [String]
    public let futureWrapperExactStoredFieldSwiftTypeNames: [String]
    public let futureWrapperExactStoredFieldAccessLevels: [String]
    public let futureWrapperExactStoredFieldCount: Int
    public let futureWrapperExposedFieldOrAccessorCount: Int
    public let futureWrapperInitializerAccessLevel: String
    public let futureWrapperInitializerExactInputLabels: [String]
    public let futureWrapperInitializerExactInputSwiftTypeNames: [String]
    public let futureWrapperInitializerExactInputCount: Int
    public let futureWrapperDeclaredConformanceNames: [String]
    public let futureWrapperAdditionalStoredFieldPermitted: Bool
    public let futureWrapperComputedPropertyPermitted: Bool
    public let futureWrapperPayloadAccessorPermitted: Bool
    public let futureWrapperSubscriptPermitted: Bool
    public let futureWrapperCallbackOrClosureExposurePermitted: Bool
    public let futureWrapperDeclaredReflectionOrDescriptionSurfacePermitted:
        Bool
    public let genericSwiftReflectionMayExposePrivatePayload: Bool
    public let futureWrapperProvidesConfidentialityBoundary: Bool
    public let wrapperPossessionMayEstablishSecurityBoundary: Bool

    public let futureInvocationMethodEnclosingTypeName: String
    public let futureInvocationMethodName: String
    public let futureInvocationMethodNormalizedSignature: String
    public let futureInvocationMethodAccessLevel: String
    public let futureInvocationMethodStatic: Bool
    public let futureInvocationMethodThrows: Bool
    public let futureInvocationMethodReturnSwiftTypeName: String
    public let exactInvocationInputLabels: [String]
    public let exactInvocationInputSwiftTypeNames: [String]
    public let exactInvocationInputCount: Int
    public let invocationInputMayBeOptional: Bool
    public let invocationInputMayHaveDefault: Bool
    public let additionalInvocationInputPermitted: Bool
    public let evidenceMustBeAlreadyFormed: Bool
    public let contextMustBeExplicit: Bool
    public let evidencePassedToV21CallUnchanged: Bool
    public let contextPassedToV21CallUnchanged: Bool
    public let requiredSourceBytesResolvedState: String
    public let requiredAdaptationProofRecomputedState: String
    public let v21EnforcesBothContextStatesBeforeProjection: Bool
    public let seamDuplicatesOrInventsContextGuard: Bool
    public let unavailableObservedFalseOrNilConflationPermitted: Bool
    public let evidenceOrContextInspectionPermitted: Bool
    public let evidenceOrContextCopyEncodingHashComparisonOrNormalizationPermitted:
        Bool

    public let maintainedV21CallEdgeMethodName: String
    public let maintainedV21CallEdgeAccessLevel: String
    public let exactMaintainedV21CallCount: Int
    public let maintainedV21ReturnBecomesSolePrivatePayload: Bool
    public let directComposeCallPermitted: Bool
    public let directProjectorCallPermitted: Bool
    public let directDecoderCallPermitted: Bool
    public let directExporterOrFixtureCallPermitted: Bool
    public let seamGuardOrRevalidationPermitted: Bool
    public let newErrorTypeOrCasePermitted: Bool
    public let catchRetryFallbackOrSubstitutionPermitted: Bool
    public let optionalOrForcedTryPermitted: Bool
    public let loggingOrPartialResultPermitted: Bool
    public let exactTypedFailurePropagationRequired: Bool

    public let futureWrapperSourceMaterialized: Bool
    public let futureInvocationMethodSourceMaterialized: Bool
    public let exactWorkerSourceCompilerFeasibilityObserved: Bool
    public let crossFileCallerMaterialized: Bool
    public let mainCanNameOrReachFutureSeam: Bool
    public let mainRemainsUnconditionalUnavailableExit: Bool
    public let unavailableExitStatus: Int32
    public let runtimeInputAccepted: Bool
    public let runtimeOutputProduced: Bool
    public let workerRequestHandlingEnabled: Bool
    public let replayTransportIntegrated: Bool
    public let workerSealed: Bool
    public let workerLaunched: Bool
    public let workerExecuted: Bool
    public let compositionRuntimeExercised: Bool
    public let fixtureExporterProjectorOrDecoderExecuted: Bool
    public let gateModelTrainingMutationTriadSZOrEvaluationExecuted: Bool
    public let artifactFilesystemReadPerformed: Bool
    public let artifactWritePerformed: Bool
    public let evidencePublished: Bool
    public let durablePublicationObserved: Bool
    public let mechanicsPassAuthorized: Bool
    public let terminalReceiptAuthorized: Bool
    public let sourceBindingV7Issued: Bool
    public let scientificAuthorityAuthorized: Bool
    public let productAuthorityAuthorized: Bool
    public let primeDisposition: String
    public let nextImplementationPrerequisite: String
    public let authorityStatement: String

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case contractID = "contract_id"
        case rightsHolder = "rights_holder"
        case licenseExpression = "license_expression"
        case preservedCompositionSourceV21ContractID =
            "preserved_composition_source_v21_contract_id"
        case preservedCompositionSourceV21ContractSHA256 =
            "preserved_composition_source_v21_contract_sha256"
        case preservedTopologyV21ID = "preserved_topology_v21_id"
        case preservedTopologyV21SHA256 =
            "preserved_topology_v21_sha256"
        case futureSourceRelativePath = "future_source_relative_path"
        case preservedV21SourcePrefixByteCount =
            "preserved_v21_source_prefix_byte_count"
        case preservedV21SourcePrefixSHA256 =
            "preserved_v21_source_prefix_sha256"
        case packageSwiftRelativePath = "package_swift_relative_path"
        case packageSwiftByteCount = "package_swift_byte_count"
        case packageSwiftSHA256 = "package_swift_sha256"
        case workerMainRelativePath = "worker_main_relative_path"
        case workerMainByteCount = "worker_main_byte_count"
        case workerMainSHA256 = "worker_main_sha256"
        case workerTargetName = "worker_target_name"
        case orderedWorkerSwiftSourceRelativePaths =
            "ordered_worker_swift_source_relative_paths"
        case exactWorkerSwiftSourceFileCount =
            "exact_worker_swift_source_file_count"
        case workerDirectLocalDependencyNames =
            "worker_direct_local_dependency_names"
        case exactWorkerDirectLocalDependencyCount =
            "exact_worker_direct_local_dependency_count"
        case workerResourceRelativePaths =
            "worker_resource_relative_paths"
        case exactWorkerResourceCount = "exact_worker_resource_count"
        case packageGraphMayChange = "package_graph_may_change"
        case targetGraphMayChange = "target_graph_may_change"
        case forbiddenReachabilityMayChange =
            "forbidden_reachability_may_change"
        case workerSourceInventoryMayChange =
            "worker_source_inventory_may_change"
        case workerDependenciesMayChange =
            "worker_dependencies_may_change"
        case workerResourcesMayChange = "worker_resources_may_change"
        case futureSourceMustBeAppendOnlySameFileContinuation =
            "future_source_must_be_append_only_same_file_continuation"
        case futureSourceMayRewritePreservedPrefix =
            "future_source_may_rewrite_preserved_prefix"
        case futureSourceMayUseSeparateFile =
            "future_source_may_use_separate_file"
        case futureSourceMayChangeImportInventory =
            "future_source_may_change_import_inventory"
        case preservedV21PrivateMemberNames =
            "preserved_v21_private_member_names"
        case preservedV21PrivateMemberAccessLevel =
            "preserved_v21_private_member_access_level"
        case preservedV21PrivateAccessMayChange =
            "preserved_v21_private_access_may_change"
        case futureWrapperEnclosingTypeName =
            "future_wrapper_enclosing_type_name"
        case futureWrapperTypeName = "future_wrapper_type_name"
        case futureWrapperQualifiedSwiftTypeName =
            "future_wrapper_qualified_swift_type_name"
        case futureWrapperDeclarationKind =
            "future_wrapper_declaration_kind"
        case futureWrapperAccessLevel = "future_wrapper_access_level"
        case futureWrapperNestedInWorker =
            "future_wrapper_nested_in_worker"
        case futureWrapperPublicPackageSPIOrExported =
            "future_wrapper_public_package_spi_or_exported"
        case futureWrapperExactStoredFieldNames =
            "future_wrapper_exact_stored_field_names"
        case futureWrapperExactStoredFieldSwiftTypeNames =
            "future_wrapper_exact_stored_field_swift_type_names"
        case futureWrapperExactStoredFieldAccessLevels =
            "future_wrapper_exact_stored_field_access_levels"
        case futureWrapperExactStoredFieldCount =
            "future_wrapper_exact_stored_field_count"
        case futureWrapperExposedFieldOrAccessorCount =
            "future_wrapper_exposed_field_or_accessor_count"
        case futureWrapperInitializerAccessLevel =
            "future_wrapper_initializer_access_level"
        case futureWrapperInitializerExactInputLabels =
            "future_wrapper_initializer_exact_input_labels"
        case futureWrapperInitializerExactInputSwiftTypeNames =
            "future_wrapper_initializer_exact_input_swift_type_names"
        case futureWrapperInitializerExactInputCount =
            "future_wrapper_initializer_exact_input_count"
        case futureWrapperDeclaredConformanceNames =
            "future_wrapper_declared_conformance_names"
        case futureWrapperAdditionalStoredFieldPermitted =
            "future_wrapper_additional_stored_field_permitted"
        case futureWrapperComputedPropertyPermitted =
            "future_wrapper_computed_property_permitted"
        case futureWrapperPayloadAccessorPermitted =
            "future_wrapper_payload_accessor_permitted"
        case futureWrapperSubscriptPermitted =
            "future_wrapper_subscript_permitted"
        case futureWrapperCallbackOrClosureExposurePermitted =
            "future_wrapper_callback_or_closure_exposure_permitted"
        case futureWrapperDeclaredReflectionOrDescriptionSurfacePermitted =
            "future_wrapper_declared_reflection_or_description_surface_permitted"
        case genericSwiftReflectionMayExposePrivatePayload =
            "generic_swift_reflection_may_expose_private_payload"
        case futureWrapperProvidesConfidentialityBoundary =
            "future_wrapper_provides_confidentiality_boundary"
        case wrapperPossessionMayEstablishSecurityBoundary =
            "wrapper_possession_may_establish_security_boundary"
        case futureInvocationMethodEnclosingTypeName =
            "future_invocation_method_enclosing_type_name"
        case futureInvocationMethodName =
            "future_invocation_method_name"
        case futureInvocationMethodNormalizedSignature =
            "future_invocation_method_normalized_signature"
        case futureInvocationMethodAccessLevel =
            "future_invocation_method_access_level"
        case futureInvocationMethodStatic =
            "future_invocation_method_static"
        case futureInvocationMethodThrows =
            "future_invocation_method_throws"
        case futureInvocationMethodReturnSwiftTypeName =
            "future_invocation_method_return_swift_type_name"
        case exactInvocationInputLabels =
            "exact_invocation_input_labels"
        case exactInvocationInputSwiftTypeNames =
            "exact_invocation_input_swift_type_names"
        case exactInvocationInputCount = "exact_invocation_input_count"
        case invocationInputMayBeOptional =
            "invocation_input_may_be_optional"
        case invocationInputMayHaveDefault =
            "invocation_input_may_have_default"
        case additionalInvocationInputPermitted =
            "additional_invocation_input_permitted"
        case evidenceMustBeAlreadyFormed =
            "evidence_must_be_already_formed"
        case contextMustBeExplicit = "context_must_be_explicit"
        case evidencePassedToV21CallUnchanged =
            "evidence_passed_to_v21_call_unchanged"
        case contextPassedToV21CallUnchanged =
            "context_passed_to_v21_call_unchanged"
        case requiredSourceBytesResolvedState =
            "required_source_bytes_resolved_state"
        case requiredAdaptationProofRecomputedState =
            "required_adaptation_proof_recomputed_state"
        case v21EnforcesBothContextStatesBeforeProjection =
            "v21_enforces_both_context_states_before_projection"
        case seamDuplicatesOrInventsContextGuard =
            "seam_duplicates_or_invents_context_guard"
        case unavailableObservedFalseOrNilConflationPermitted =
            "unavailable_observed_false_or_nil_conflation_permitted"
        case evidenceOrContextInspectionPermitted =
            "evidence_or_context_inspection_permitted"
        case evidenceOrContextCopyEncodingHashComparisonOrNormalizationPermitted =
            "evidence_or_context_copy_encoding_hash_comparison_or_normalization_permitted"
        case maintainedV21CallEdgeMethodName =
            "maintained_v21_call_edge_method_name"
        case maintainedV21CallEdgeAccessLevel =
            "maintained_v21_call_edge_access_level"
        case exactMaintainedV21CallCount =
            "exact_maintained_v21_call_count"
        case maintainedV21ReturnBecomesSolePrivatePayload =
            "maintained_v21_return_becomes_sole_private_payload"
        case directComposeCallPermitted =
            "direct_compose_call_permitted"
        case directProjectorCallPermitted =
            "direct_projector_call_permitted"
        case directDecoderCallPermitted =
            "direct_decoder_call_permitted"
        case directExporterOrFixtureCallPermitted =
            "direct_exporter_or_fixture_call_permitted"
        case seamGuardOrRevalidationPermitted =
            "seam_guard_or_revalidation_permitted"
        case newErrorTypeOrCasePermitted =
            "new_error_type_or_case_permitted"
        case catchRetryFallbackOrSubstitutionPermitted =
            "catch_retry_fallback_or_substitution_permitted"
        case optionalOrForcedTryPermitted =
            "optional_or_forced_try_permitted"
        case loggingOrPartialResultPermitted =
            "logging_or_partial_result_permitted"
        case exactTypedFailurePropagationRequired =
            "exact_typed_failure_propagation_required"
        case futureWrapperSourceMaterialized =
            "future_wrapper_source_materialized"
        case futureInvocationMethodSourceMaterialized =
            "future_invocation_method_source_materialized"
        case exactWorkerSourceCompilerFeasibilityObserved =
            "exact_worker_source_compiler_feasibility_observed"
        case crossFileCallerMaterialized =
            "cross_file_caller_materialized"
        case mainCanNameOrReachFutureSeam =
            "main_can_name_or_reach_future_seam"
        case mainRemainsUnconditionalUnavailableExit =
            "main_remains_unconditional_unavailable_exit"
        case unavailableExitStatus = "unavailable_exit_status"
        case runtimeInputAccepted = "runtime_input_accepted"
        case runtimeOutputProduced = "runtime_output_produced"
        case workerRequestHandlingEnabled =
            "worker_request_handling_enabled"
        case replayTransportIntegrated = "replay_transport_integrated"
        case workerSealed = "worker_sealed"
        case workerLaunched = "worker_launched"
        case workerExecuted = "worker_executed"
        case compositionRuntimeExercised =
            "composition_runtime_exercised"
        case fixtureExporterProjectorOrDecoderExecuted =
            "fixture_exporter_projector_or_decoder_executed"
        case gateModelTrainingMutationTriadSZOrEvaluationExecuted =
            "gate_model_training_mutation_triad_sz_or_evaluation_executed"
        case artifactFilesystemReadPerformed =
            "artifact_filesystem_read_performed"
        case artifactWritePerformed = "artifact_write_performed"
        case evidencePublished = "evidence_published"
        case durablePublicationObserved =
            "durable_publication_observed"
        case mechanicsPassAuthorized = "mechanics_pass_authorized"
        case terminalReceiptAuthorized = "terminal_receipt_authorized"
        case sourceBindingV7Issued = "source_binding_v7_issued"
        case scientificAuthorityAuthorized =
            "scientific_authority_authorized"
        case productAuthorityAuthorized =
            "product_authority_authorized"
        case primeDisposition = "prime_disposition"
        case nextImplementationPrerequisite =
            "next_implementation_prerequisite"
        case authorityStatement = "authority_statement"
    }

    public static let frozenV1: Self = {
        let workerSource =
            "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactDecoderCallEdge.swift"
        let workerMain =
            "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalFixtureWorker.swift"
        let wrapper =
            "PrimeNativeNeuralGateHistoricalWorkerInvocationSeamResult"
        let worker =
            "PrimeNativeNeuralGateHistoricalFixtureWorker"

        return Self(
            schemaVersion: 1,
            contractID:
                "prime_source_bound_historical_worker_bounded_unavailable_composition_invocation_seam_design_v22",
            rightsHolder: "Ergentics, LLC",
            licenseExpression: "LicenseRef-Ergentics-Proprietary",
            preservedCompositionSourceV21ContractID:
                "prime_source_bound_historical_worker_exported_evidence_projection_decode_composition_call_edge_v21",
            preservedCompositionSourceV21ContractSHA256:
                "843b686a63245bffcf210441e1e98b94113b5c02b8f47b80371d3f041a205494",
            preservedTopologyV21ID:
                "prime_stage_b_historical_worker_exported_evidence_projection_decode_composition_call_edge_source_topology_v21",
            preservedTopologyV21SHA256:
                "6d9e2787b54b6ab20f449497e6ac2b91c9945567211badfd4383f37b417f14a4",
            futureSourceRelativePath: workerSource,
            preservedV21SourcePrefixByteCount: 11_354,
            preservedV21SourcePrefixSHA256:
                "39cd879a54d6a1198f0a863f606751b1bb9d07f1ba6eb334dd74e9a079c40e1d",
            packageSwiftRelativePath: "Package.swift",
            packageSwiftByteCount: 27_650,
            packageSwiftSHA256:
                "190b1d2dbeb2597830b1765fa80d6776a0044a34d5e2c6db8b14ace013654e7d",
            workerMainRelativePath: workerMain,
            workerMainByteCount: 2_298,
            workerMainSHA256:
                "9f62827d4c35e98fb01f9984b1c227cb681dd42ac4c26147a86e9429958545df",
            workerTargetName: worker,
            orderedWorkerSwiftSourceRelativePaths: [
                "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalEvidenceExportCallEdge.swift",
                workerMain,
                workerSource,
                "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactProjectionCallEdge.swift",
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
                "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/HistoricalFixtureEvidence/Package.resolved",
            ],
            exactWorkerResourceCount: 1,
            packageGraphMayChange: false,
            targetGraphMayChange: false,
            forbiddenReachabilityMayChange: false,
            workerSourceInventoryMayChange: false,
            workerDependenciesMayChange: false,
            workerResourcesMayChange: false,
            futureSourceMustBeAppendOnlySameFileContinuation: true,
            futureSourceMayRewritePreservedPrefix: false,
            futureSourceMayUseSeparateFile: false,
            futureSourceMayChangeImportInventory: false,
            preservedV21PrivateMemberNames: [
                "PrimeNativeNeuralGateHistoricalEvidenceProjectionDecodeCompositionError",
                "PrimeNativeNeuralGateHistoricalEvidenceProjectionDecodeCompositionResult",
                "compose",
                "sourceBoundHistoricalEvidenceProjectionDecodeCompositionCallEdge",
            ],
            preservedV21PrivateMemberAccessLevel: "private",
            preservedV21PrivateAccessMayChange: false,
            futureWrapperEnclosingTypeName: worker,
            futureWrapperTypeName: wrapper,
            futureWrapperQualifiedSwiftTypeName: "\(worker).\(wrapper)",
            futureWrapperDeclarationKind: "struct",
            futureWrapperAccessLevel: "internal",
            futureWrapperNestedInWorker: true,
            futureWrapperPublicPackageSPIOrExported: false,
            futureWrapperExactStoredFieldNames: [
                "compositionResult"
            ],
            futureWrapperExactStoredFieldSwiftTypeNames: [
                "PrimeNativeNeuralGateHistoricalEvidenceProjectionDecodeCompositionResult"
            ],
            futureWrapperExactStoredFieldAccessLevels: [
                "private"
            ],
            futureWrapperExactStoredFieldCount: 1,
            futureWrapperExposedFieldOrAccessorCount: 0,
            futureWrapperInitializerAccessLevel: "private",
            futureWrapperInitializerExactInputLabels: [
                "compositionResult"
            ],
            futureWrapperInitializerExactInputSwiftTypeNames: [
                "PrimeNativeNeuralGateHistoricalEvidenceProjectionDecodeCompositionResult"
            ],
            futureWrapperInitializerExactInputCount: 1,
            futureWrapperDeclaredConformanceNames: [],
            futureWrapperAdditionalStoredFieldPermitted: false,
            futureWrapperComputedPropertyPermitted: false,
            futureWrapperPayloadAccessorPermitted: false,
            futureWrapperSubscriptPermitted: false,
            futureWrapperCallbackOrClosureExposurePermitted: false,
            futureWrapperDeclaredReflectionOrDescriptionSurfacePermitted:
                false,
            genericSwiftReflectionMayExposePrivatePayload: true,
            futureWrapperProvidesConfidentialityBoundary: false,
            wrapperPossessionMayEstablishSecurityBoundary: false,
            futureInvocationMethodEnclosingTypeName: "\(worker).\(wrapper)",
            futureInvocationMethodName:
                "sourceBoundUnavailableHistoricalWorkerInvocationSeam",
            futureInvocationMethodNormalizedSignature:
                "internal static func sourceBoundUnavailableHistoricalWorkerInvocationSeam(evidence: PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence, context: PrimeNativeNeuralGateHistoricalProjectionContext) throws -> Self",
            futureInvocationMethodAccessLevel: "internal",
            futureInvocationMethodStatic: true,
            futureInvocationMethodThrows: true,
            futureInvocationMethodReturnSwiftTypeName:
                "\(worker).\(wrapper)",
            exactInvocationInputLabels: ["evidence", "context"],
            exactInvocationInputSwiftTypeNames: [
                "PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence",
                "PrimeNativeNeuralGateHistoricalProjectionContext",
            ],
            exactInvocationInputCount: 2,
            invocationInputMayBeOptional: false,
            invocationInputMayHaveDefault: false,
            additionalInvocationInputPermitted: false,
            evidenceMustBeAlreadyFormed: true,
            contextMustBeExplicit: true,
            evidencePassedToV21CallUnchanged: true,
            contextPassedToV21CallUnchanged: true,
            requiredSourceBytesResolvedState: "unavailable",
            requiredAdaptationProofRecomputedState: "unavailable",
            v21EnforcesBothContextStatesBeforeProjection: true,
            seamDuplicatesOrInventsContextGuard: false,
            unavailableObservedFalseOrNilConflationPermitted: false,
            evidenceOrContextInspectionPermitted: false,
            evidenceOrContextCopyEncodingHashComparisonOrNormalizationPermitted:
                false,
            maintainedV21CallEdgeMethodName:
                "sourceBoundHistoricalEvidenceProjectionDecodeCompositionCallEdge",
            maintainedV21CallEdgeAccessLevel: "private",
            exactMaintainedV21CallCount: 1,
            maintainedV21ReturnBecomesSolePrivatePayload: true,
            directComposeCallPermitted: false,
            directProjectorCallPermitted: false,
            directDecoderCallPermitted: false,
            directExporterOrFixtureCallPermitted: false,
            seamGuardOrRevalidationPermitted: false,
            newErrorTypeOrCasePermitted: false,
            catchRetryFallbackOrSubstitutionPermitted: false,
            optionalOrForcedTryPermitted: false,
            loggingOrPartialResultPermitted: false,
            exactTypedFailurePropagationRequired: true,
            futureWrapperSourceMaterialized: false,
            futureInvocationMethodSourceMaterialized: false,
            exactWorkerSourceCompilerFeasibilityObserved: false,
            crossFileCallerMaterialized: false,
            mainCanNameOrReachFutureSeam: false,
            mainRemainsUnconditionalUnavailableExit: true,
            unavailableExitStatus: 78,
            runtimeInputAccepted: false,
            runtimeOutputProduced: false,
            workerRequestHandlingEnabled: false,
            replayTransportIntegrated: false,
            workerSealed: false,
            workerLaunched: false,
            workerExecuted: false,
            compositionRuntimeExercised: false,
            fixtureExporterProjectorOrDecoderExecuted: false,
            gateModelTrainingMutationTriadSZOrEvaluationExecuted: false,
            artifactFilesystemReadPerformed: false,
            artifactWritePerformed: false,
            evidencePublished: false,
            durablePublicationObserved: false,
            mechanicsPassAuthorized: false,
            terminalReceiptAuthorized: false,
            sourceBindingV7Issued: false,
            scientificAuthorityAuthorized: false,
            productAuthorityAuthorized: false,
            primeDisposition: "ABSTAIN",
            nextImplementationPrerequisite:
                "source_bind_the_bounded_unavailable_historical_worker_invocation_seam_as_an_append_only_same_file_v21_composition_continuation_preserving_all_v21_private_members_and_delegating_exactly_once_from_one_new_internal_nonpublic_typed_bridge_without_adding_a_main_call_edge_replay_transport_integration_request_handling_sealing_launch_execution_artifact_io_publication_or_issuing_source_binding_v7",
            authorityStatement:
                [
                    "This V22 contract binds only a future bounded unavailable historical-worker composition invocation-seam design and preserves the exact V21 source contract and topology identities.",
                    "The complete 11,354-byte V21 composition source, 27,650-byte Package.swift, 2,298-byte status-78 main, four-file worker inventory, seven-dependency order, resource, target graph, and forbidden reachability remain exact and unchanged.",
                    "A later append-only same-file continuation may add one nested internal nonpublic value-type wrapper with exactly one private V21 composition-result payload, a private initializer, no additional or exposed fields, no declared payload accessor, and no declared conformances.",
                    "Swift private access is source-level API hiding, not confidentiality: generic Mirror or unsafe same-module code may expose the payload, so wrapper possession is never a security, secrecy, provenance, or authority boundary.",
                    "The wrapper's sole internal static throwing method accepts only an already-formed Evidence value and explicit projection context, passes both unchanged to the enclosing worker's unchanged private V21 call edge exactly once, and stores only that returned value.",
                    "Keeping the method on the nested wrapper is the minimal Swift access-control shape that permits its private initializer and the enclosing worker's private same-file member to remain private; an enclosing Worker method cannot invoke a nested type's private initializer.",
                    "The seam may add no guard, validation, parser, exporter, projector, decoder, fixture, error mapping, catch, retry, fallback, optional or forced try, logging, I/O, request, process, transport, publication, or authority behavior.",
                    "V22 materializes no wrapper, method, caller, access change, runtime input or output, execution, artifact observation, publication, mechanics PASS, receipt, source or execution binding V7, scientific authority, or product authority; exact worker-source compiler feasibility remains unobserved and Prime remains ABSTAIN.",
                ].joined(separator: " ")
        )
    }()

    public func validate() throws {
        guard self == .frozenV1 else {
            throw PrimeNativeNeuralGateHistoricalWorkerInvocationSeamDesignContractError
                .invalidFrozenContract
        }

        let source =
            PrimeNativeNeuralGateHistoricalWorkerExportedEvidenceProjectionDecodeCompositionCallEdgeSourceContract
            .frozenV1
        let topology =
            PrimeNativeNeuralGateTrapDisjointTopologyContract
            .frozenV21
        // V21 owns validation of its already-frozen contracts. Re-entering
        // their complete recursive validators from every V22 design check is
        // combinatorial and adds no new binding proof. V22 instead checks the
        // canonical bytes against the literal identities introduced at V21.
        let sourceSHA256 = PrimeSHA256.hexDigest(
            of: try PrimeCanonicalJSON.encode(source)
        )
        let topologySHA256 = PrimeSHA256.hexDigest(
            of: try PrimeCanonicalJSON.encode(topology)
        )
        let workerTarget = try topology.target(named: workerTargetName)

        guard schemaVersion == 1,
              contractID
                == "prime_source_bound_historical_worker_bounded_unavailable_composition_invocation_seam_design_v22",
              rightsHolder == "Ergentics, LLC",
              licenseExpression == "LicenseRef-Ergentics-Proprietary",
              preservedCompositionSourceV21ContractID
                == source.contractID,
              preservedCompositionSourceV21ContractSHA256
                == "843b686a63245bffcf210441e1e98b94113b5c02b8f47b80371d3f041a205494",
              preservedCompositionSourceV21ContractSHA256
                == sourceSHA256,
              preservedTopologyV21ID == topology.contractID,
              preservedTopologyV21SHA256
                == "6d9e2787b54b6ab20f449497e6ac2b91c9945567211badfd4383f37b417f14a4",
              preservedTopologyV21SHA256 == topologySHA256,
              futureSourceRelativePath
                == source.compositionSource.primeRelativePath,
              preservedV21SourcePrefixByteCount
                == source.compositionSource.byteCount,
              preservedV21SourcePrefixSHA256
                == source.compositionSource.sha256,
              packageSwiftRelativePath
                == source.packageSwift.primeRelativePath,
              packageSwiftByteCount == source.packageSwift.byteCount,
              packageSwiftSHA256 == source.packageSwift.sha256,
              workerTargetName == source.workerTargetName,
              orderedWorkerSwiftSourceRelativePaths
                == source.orderedWorkerSwiftSourceRelativePaths,
              exactWorkerSwiftSourceFileCount == 4,
              workerDirectLocalDependencyNames
                == source.workerDirectLocalDependencyNames,
              workerDirectLocalDependencyNames
                == workerTarget.directLocalDependencyNames,
              exactWorkerDirectLocalDependencyCount == 7,
              workerResourceRelativePaths
                == source.workerResourceRelativePaths,
              exactWorkerResourceCount == 1,
              !packageGraphMayChange,
              !targetGraphMayChange,
              !forbiddenReachabilityMayChange,
              !workerSourceInventoryMayChange,
              !workerDependenciesMayChange,
              !workerResourcesMayChange,
              futureSourceMustBeAppendOnlySameFileContinuation,
              !futureSourceMayRewritePreservedPrefix,
              !futureSourceMayUseSeparateFile,
              !futureSourceMayChangeImportInventory,
              preservedV21PrivateMemberNames.count == 4,
              preservedV21PrivateMemberAccessLevel == "private",
              !preservedV21PrivateAccessMayChange,
              futureWrapperEnclosingTypeName == workerTargetName,
              futureWrapperQualifiedSwiftTypeName
                == "\(workerTargetName).\(futureWrapperTypeName)",
              futureWrapperDeclarationKind == "struct",
              futureWrapperAccessLevel == "internal",
              futureWrapperNestedInWorker,
              !futureWrapperPublicPackageSPIOrExported,
              futureWrapperExactStoredFieldNames
                == ["compositionResult"],
              futureWrapperExactStoredFieldSwiftTypeNames
                == [source.compositionResultTypeName],
              futureWrapperExactStoredFieldAccessLevels == ["private"],
              futureWrapperExactStoredFieldCount == 1,
              futureWrapperExposedFieldOrAccessorCount == 0,
              futureWrapperInitializerAccessLevel == "private",
              futureWrapperInitializerExactInputLabels
                == futureWrapperExactStoredFieldNames,
              futureWrapperInitializerExactInputSwiftTypeNames
                == futureWrapperExactStoredFieldSwiftTypeNames,
              futureWrapperInitializerExactInputCount == 1,
              futureWrapperDeclaredConformanceNames.isEmpty,
              !futureWrapperAdditionalStoredFieldPermitted,
              !futureWrapperComputedPropertyPermitted,
              !futureWrapperPayloadAccessorPermitted,
              !futureWrapperSubscriptPermitted,
              !futureWrapperCallbackOrClosureExposurePermitted,
              !futureWrapperDeclaredReflectionOrDescriptionSurfacePermitted,
              genericSwiftReflectionMayExposePrivatePayload,
              !futureWrapperProvidesConfidentialityBoundary,
              !wrapperPossessionMayEstablishSecurityBoundary,
              futureInvocationMethodEnclosingTypeName
                == futureWrapperQualifiedSwiftTypeName,
              futureInvocationMethodName
                == "sourceBoundUnavailableHistoricalWorkerInvocationSeam",
              futureInvocationMethodAccessLevel == "internal",
              futureInvocationMethodStatic,
              futureInvocationMethodThrows,
              futureInvocationMethodReturnSwiftTypeName
                == futureWrapperQualifiedSwiftTypeName,
              exactInvocationInputLabels == ["evidence", "context"],
              exactInvocationInputSwiftTypeNames
                == source.exactCompositionInputSwiftTypeNames,
              exactInvocationInputCount == 2,
              !invocationInputMayBeOptional,
              !invocationInputMayHaveDefault,
              !additionalInvocationInputPermitted,
              evidenceMustBeAlreadyFormed,
              contextMustBeExplicit,
              evidencePassedToV21CallUnchanged,
              contextPassedToV21CallUnchanged,
              requiredSourceBytesResolvedState
                == source.contextSourceBytesResolvedRequiredState,
              requiredAdaptationProofRecomputedState
                == source.contextAdaptationProofRecomputedRequiredState,
              v21EnforcesBothContextStatesBeforeProjection,
              !seamDuplicatesOrInventsContextGuard,
              !unavailableObservedFalseOrNilConflationPermitted,
              !evidenceOrContextInspectionPermitted,
              !evidenceOrContextCopyEncodingHashComparisonOrNormalizationPermitted,
              maintainedV21CallEdgeMethodName
                == source.workerCallEdgeMethodName,
              maintainedV21CallEdgeAccessLevel == "private",
              exactMaintainedV21CallCount == 1,
              maintainedV21ReturnBecomesSolePrivatePayload,
              !directComposeCallPermitted,
              !directProjectorCallPermitted,
              !directDecoderCallPermitted,
              !directExporterOrFixtureCallPermitted,
              !seamGuardOrRevalidationPermitted,
              !newErrorTypeOrCasePermitted,
              !catchRetryFallbackOrSubstitutionPermitted,
              !optionalOrForcedTryPermitted,
              !loggingOrPartialResultPermitted,
              exactTypedFailurePropagationRequired,
              !futureWrapperSourceMaterialized,
              !futureInvocationMethodSourceMaterialized,
              !exactWorkerSourceCompilerFeasibilityObserved,
              !crossFileCallerMaterialized,
              !mainCanNameOrReachFutureSeam,
              mainRemainsUnconditionalUnavailableExit,
              unavailableExitStatus == 78,
              !runtimeInputAccepted,
              !runtimeOutputProduced,
              !workerRequestHandlingEnabled,
              !replayTransportIntegrated,
              !workerSealed,
              !workerLaunched,
              !workerExecuted,
              !compositionRuntimeExercised,
              !fixtureExporterProjectorOrDecoderExecuted,
              !gateModelTrainingMutationTriadSZOrEvaluationExecuted,
              !artifactFilesystemReadPerformed,
              !artifactWritePerformed,
              !evidencePublished,
              !durablePublicationObserved,
              !mechanicsPassAuthorized,
              !terminalReceiptAuthorized,
              !sourceBindingV7Issued,
              !scientificAuthorityAuthorized,
              !productAuthorityAuthorized,
              primeDisposition == "ABSTAIN",
              nextImplementationPrerequisite
                == "source_bind_the_bounded_unavailable_historical_worker_invocation_seam_as_an_append_only_same_file_v21_composition_continuation_preserving_all_v21_private_members_and_delegating_exactly_once_from_one_new_internal_nonpublic_typed_bridge_without_adding_a_main_call_edge_replay_transport_integration_request_handling_sealing_launch_execution_artifact_io_publication_or_issuing_source_binding_v7",
              authorityStatement.contains(
                "exact worker-source compiler feasibility remains unobserved"
              )
        else {
            throw PrimeNativeNeuralGateHistoricalWorkerInvocationSeamDesignContractError
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
