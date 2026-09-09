// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

public enum
    PrimeNativeNeuralGateHistoricalWorkerInvocationSeamSourceContractError:
    Error,
    Equatable,
    Sendable
{
    case invalidFrozenContract
}

public struct
    PrimeNativeNeuralGateHistoricalWorkerInvocationSeamSourceIdentity:
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
            || primeRelativePath.hasPrefix("Tests/")
            || primeRelativePath == "Package.swift")
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

/// Frozen V23 source boundary for the unavailable historical worker's
/// nonpublic composition invocation seam.
///
/// V23 preserves the complete V21 worker source as an exact prefix and appends
/// only the V22-designed nested wrapper and one-call internal method. The new
/// internal method is nameable by same-module sources, including `main`, but no
/// caller or runtime edge exists. Compilation proves only this source shape.
public struct
    PrimeNativeNeuralGateHistoricalWorkerInvocationSeamSourceContract:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let contractID: String
    public let rightsHolder: String
    public let licenseExpression: String

    public let preservedInvocationSeamDesignV22ContractID: String
    public let preservedInvocationSeamDesignV22ContractSHA256: String
    public let preservedTopologyV22ID: String
    public let preservedTopologyV22SHA256: String
    public let preservedCompositionSourceV21ContractID: String
    public let preservedCompositionSourceV21ContractSHA256: String

    public let workerTargetName: String
    public let seamSource:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamSourceIdentity
    public let preservedV21SourcePrefixByteCount: UInt64
    public let preservedV21SourcePrefixSHA256: String
    public let appendedV23SourceSuffixByteCount: UInt64
    public let appendedV23SourceSuffixSHA256: String
    public let exactPrefixPreserved: Bool
    public let sourceEvolutionAppendOnly: Bool

    public let packageSwift:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamSourceIdentity
    public let workerMain:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamSourceIdentity
    public let workerEvidenceExportCallEdgeSource:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamSourceIdentity
    public let workerProjectionCallEdgeSource:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamSourceIdentity
    public let workerFixtureResource:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamSourceIdentity
    public let historicalV21SourceTestBeforeV23:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamSourceIdentity
    public let currentV21SourceTest:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamSourceIdentity
    public let historicalV22DesignTestBeforeV23:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamSourceIdentity
    public let currentV22DesignTest:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamSourceIdentity
    public let historicalTestsEvolvedTransparently: Bool

    public let orderedWorkerSwiftSourceRelativePaths: [String]
    public let exactWorkerSwiftSourceFileCount: Int
    public let workerDirectLocalDependencyNames: [String]
    public let exactWorkerDirectLocalDependencyCount: Int
    public let workerResourceRelativePaths: [String]
    public let exactWorkerResourceCount: Int
    public let physicalWorkerInventoryExact: Bool
    public let packageGraphChanged: Bool
    public let targetGraphChanged: Bool
    public let forbiddenReachabilityChanged: Bool
    public let workerSourceInventoryChanged: Bool
    public let workerDependenciesChanged: Bool
    public let workerResourcesChanged: Bool
    public let exactImportNames: [String]
    public let importInventoryChanged: Bool

    public let appendedExtensionTargetTypeName: String
    public let exactAppendedExtensionCount: Int
    public let wrapperTypeName: String
    public let wrapperQualifiedSwiftTypeName: String
    public let wrapperDeclarationKind: String
    public let wrapperAccessLevel: String
    public let wrapperNestedInWorker: Bool
    public let wrapperPublicPackageSPIOrExported: Bool
    public let wrapperDeclarationAttributeNames: [String]
    public let wrapperGenericParameterCount: Int
    public let wrapperExactStoredFieldNames: [String]
    public let wrapperExactStoredFieldSwiftTypeNames: [String]
    public let wrapperExactStoredFieldAccessLevels: [String]
    public let wrapperExactStoredFieldCount: Int
    public let wrapperDirectlyRetainsEvidence: Bool
    public let wrapperDirectlyRetainsContext: Bool
    public let wrapperTransitivelyRetainsProjectedAndDecodedArtifactSets: Bool
    public let wrapperInitializerAccessLevel: String
    public let wrapperInitializerExactInputLabels: [String]
    public let wrapperInitializerExactInputSwiftTypeNames: [String]
    public let wrapperInitializerExactInputCount: Int
    public let wrapperDeclaredConformanceNames: [String]
    public let wrapperDeclaredSendableConformance: Bool
    public let wrapperImplicitSendableConformance: Bool
    public let wrapperDeclaredCopyableConformance: Bool
    public let wrapperImplicitCopyableConformance: Bool
    public let wrapperAdditionalStoredFieldPermitted: Bool
    public let wrapperComputedPropertyPermitted: Bool
    public let wrapperPayloadAccessorPermitted: Bool
    public let wrapperSubscriptPermitted: Bool
    public let wrapperCallbackOrClosureExposurePermitted: Bool
    public let wrapperDeclaredReflectionOrDescriptionSurfacePermitted: Bool
    public let genericSwiftReflectionMayExposePrivatePayload: Bool
    public let wrapperProvidesConfidentialityBoundary: Bool
    public let wrapperPossessionMayEstablishSecurityBoundary: Bool

    public let invocationMethodEnclosingTypeName: String
    public let invocationMethodName: String
    public let invocationMethodNormalizedSignature: String
    public let invocationMethodAccessLevel: String
    public let invocationMethodAttributeNames: [String]
    public let invocationMethodStatic: Bool
    public let invocationMethodAsync: Bool
    public let invocationMethodThrows: Bool
    public let invocationMethodTypedThrowsDeclared: Bool
    public let invocationMethodReturnSwiftTypeName: String
    public let exactInvocationInputLabels: [String]
    public let exactInvocationInputSwiftTypeNames: [String]
    public let exactInvocationInputCount: Int
    public let invocationInputMayBeOptional: Bool
    public let invocationInputMayHaveDefault: Bool
    public let invocationInputMayBeVariadicOrInout: Bool
    public let invocationMethodGenericParameterCount: Int
    public let evidenceMustBeAlreadyFormed: Bool
    public let contextMustBeExplicit: Bool
    public let evidencePassedToV21CallUnchanged: Bool
    public let contextPassedToV21CallUnchanged: Bool
    public let requiredSourceBytesResolvedState: String
    public let requiredAdaptationProofRecomputedState: String
    public let v21EnforcesBothContextStatesBeforeProjection: Bool
    public let exactSeamContextGuardCount: Int
    public let seamDuplicatesOrInventsContextGuard: Bool
    public let unavailableObservedFalseOrNilConflationPermitted: Bool
    public let evidenceOrContextInspectionPermitted: Bool
    public let evidenceOrContextCopyEncodingHashComparisonOrNormalizationPermitted:
        Bool
    public let maintainedV21CallEdgeMethodName: String
    public let maintainedV21CallEdgeAccessLevel: String
    public let exactMaintainedV21CallCount: Int
    public let v21CallUsesExplicitWorkerQualification: Bool
    public let exactWrapperConstructionCount: Int
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
    public let errorValuesPropagateUnchanged: Bool

    public let wrapperSourceMaterialized: Bool
    public let invocationMethodSourceMaterialized: Bool
    public let exactWorkerSourceCompilerFeasibilityObserved: Bool
    public let sameModuleSourcesCanNameInvocationSeam: Bool
    public let mainCanLexicallyNameInvocationSeam: Bool
    public let ordinaryNonTestableOutsideModuleCanNameInvocationSeam: Bool
    public let testableOrPrivilegedImportMayNameInternalSeam: Bool
    public let compiledBinarySymbolOrTypeMetadataAbsenceAsserted: Bool
    public let dynamicLookupInjectionOrExternalInvocationResistanceEstablished:
        Bool
    public let privateV21MembersDirectlyNameableOutsideSourceFile: Bool
    public let internalSeamExpandsCallableAccessSurface: Bool
    public let v21PrivateDeclarationAccessWidened: Bool
    public let crossFileCallerMaterialized: Bool
    public let mainReferencesOrCallsInvocationSeam: Bool
    public let runtimeReachableFromMain: Bool
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
    public let sourceIntegrityTestFilesystemReadRequired: Bool
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
    public let nextImplementationPrerequisite: String
    public let authorityStatement: String

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case contractID = "contract_id"
        case rightsHolder = "rights_holder"
        case licenseExpression = "license_expression"
        case preservedInvocationSeamDesignV22ContractID =
            "preserved_invocation_seam_design_v22_contract_id"
        case preservedInvocationSeamDesignV22ContractSHA256 =
            "preserved_invocation_seam_design_v22_contract_sha256"
        case preservedTopologyV22ID = "preserved_topology_v22_id"
        case preservedTopologyV22SHA256 = "preserved_topology_v22_sha256"
        case preservedCompositionSourceV21ContractID =
            "preserved_composition_source_v21_contract_id"
        case preservedCompositionSourceV21ContractSHA256 =
            "preserved_composition_source_v21_contract_sha256"
        case workerTargetName = "worker_target_name"
        case seamSource = "seam_source"
        case preservedV21SourcePrefixByteCount =
            "preserved_v21_source_prefix_byte_count"
        case preservedV21SourcePrefixSHA256 =
            "preserved_v21_source_prefix_sha256"
        case appendedV23SourceSuffixByteCount =
            "appended_v23_source_suffix_byte_count"
        case appendedV23SourceSuffixSHA256 =
            "appended_v23_source_suffix_sha256"
        case exactPrefixPreserved = "exact_prefix_preserved"
        case sourceEvolutionAppendOnly = "source_evolution_append_only"
        case packageSwift = "package_swift"
        case workerMain = "worker_main"
        case workerEvidenceExportCallEdgeSource =
            "worker_evidence_export_call_edge_source"
        case workerProjectionCallEdgeSource =
            "worker_projection_call_edge_source"
        case workerFixtureResource = "worker_fixture_resource"
        case historicalV21SourceTestBeforeV23 =
            "historical_v21_source_test_before_v23"
        case currentV21SourceTest = "current_v21_source_test"
        case historicalV22DesignTestBeforeV23 =
            "historical_v22_design_test_before_v23"
        case currentV22DesignTest = "current_v22_design_test"
        case historicalTestsEvolvedTransparently =
            "historical_tests_evolved_transparently"
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
        case physicalWorkerInventoryExact =
            "physical_worker_inventory_exact"
        case packageGraphChanged = "package_graph_changed"
        case targetGraphChanged = "target_graph_changed"
        case forbiddenReachabilityChanged =
            "forbidden_reachability_changed"
        case workerSourceInventoryChanged =
            "worker_source_inventory_changed"
        case workerDependenciesChanged = "worker_dependencies_changed"
        case workerResourcesChanged = "worker_resources_changed"
        case exactImportNames = "exact_import_names"
        case importInventoryChanged = "import_inventory_changed"
        case appendedExtensionTargetTypeName =
            "appended_extension_target_type_name"
        case exactAppendedExtensionCount =
            "exact_appended_extension_count"
        case wrapperTypeName = "wrapper_type_name"
        case wrapperQualifiedSwiftTypeName =
            "wrapper_qualified_swift_type_name"
        case wrapperDeclarationKind = "wrapper_declaration_kind"
        case wrapperAccessLevel = "wrapper_access_level"
        case wrapperNestedInWorker = "wrapper_nested_in_worker"
        case wrapperPublicPackageSPIOrExported =
            "wrapper_public_package_spi_or_exported"
        case wrapperDeclarationAttributeNames =
            "wrapper_declaration_attribute_names"
        case wrapperGenericParameterCount =
            "wrapper_generic_parameter_count"
        case wrapperExactStoredFieldNames =
            "wrapper_exact_stored_field_names"
        case wrapperExactStoredFieldSwiftTypeNames =
            "wrapper_exact_stored_field_swift_type_names"
        case wrapperExactStoredFieldAccessLevels =
            "wrapper_exact_stored_field_access_levels"
        case wrapperExactStoredFieldCount =
            "wrapper_exact_stored_field_count"
        case wrapperDirectlyRetainsEvidence =
            "wrapper_directly_retains_evidence"
        case wrapperDirectlyRetainsContext =
            "wrapper_directly_retains_context"
        case wrapperTransitivelyRetainsProjectedAndDecodedArtifactSets =
            "wrapper_transitively_retains_projected_and_decoded_artifact_sets"
        case wrapperInitializerAccessLevel =
            "wrapper_initializer_access_level"
        case wrapperInitializerExactInputLabels =
            "wrapper_initializer_exact_input_labels"
        case wrapperInitializerExactInputSwiftTypeNames =
            "wrapper_initializer_exact_input_swift_type_names"
        case wrapperInitializerExactInputCount =
            "wrapper_initializer_exact_input_count"
        case wrapperDeclaredConformanceNames =
            "wrapper_declared_conformance_names"
        case wrapperDeclaredSendableConformance =
            "wrapper_declared_sendable_conformance"
        case wrapperImplicitSendableConformance =
            "wrapper_implicit_sendable_conformance"
        case wrapperDeclaredCopyableConformance =
            "wrapper_declared_copyable_conformance"
        case wrapperImplicitCopyableConformance =
            "wrapper_implicit_copyable_conformance"
        case wrapperAdditionalStoredFieldPermitted =
            "wrapper_additional_stored_field_permitted"
        case wrapperComputedPropertyPermitted =
            "wrapper_computed_property_permitted"
        case wrapperPayloadAccessorPermitted =
            "wrapper_payload_accessor_permitted"
        case wrapperSubscriptPermitted = "wrapper_subscript_permitted"
        case wrapperCallbackOrClosureExposurePermitted =
            "wrapper_callback_or_closure_exposure_permitted"
        case wrapperDeclaredReflectionOrDescriptionSurfacePermitted =
            "wrapper_declared_reflection_or_description_surface_permitted"
        case genericSwiftReflectionMayExposePrivatePayload =
            "generic_swift_reflection_may_expose_private_payload"
        case wrapperProvidesConfidentialityBoundary =
            "wrapper_provides_confidentiality_boundary"
        case wrapperPossessionMayEstablishSecurityBoundary =
            "wrapper_possession_may_establish_security_boundary"
        case invocationMethodEnclosingTypeName =
            "invocation_method_enclosing_type_name"
        case invocationMethodName = "invocation_method_name"
        case invocationMethodNormalizedSignature =
            "invocation_method_normalized_signature"
        case invocationMethodAccessLevel =
            "invocation_method_access_level"
        case invocationMethodAttributeNames =
            "invocation_method_attribute_names"
        case invocationMethodStatic = "invocation_method_static"
        case invocationMethodAsync = "invocation_method_async"
        case invocationMethodThrows = "invocation_method_throws"
        case invocationMethodTypedThrowsDeclared =
            "invocation_method_typed_throws_declared"
        case invocationMethodReturnSwiftTypeName =
            "invocation_method_return_swift_type_name"
        case exactInvocationInputLabels =
            "exact_invocation_input_labels"
        case exactInvocationInputSwiftTypeNames =
            "exact_invocation_input_swift_type_names"
        case exactInvocationInputCount = "exact_invocation_input_count"
        case invocationInputMayBeOptional =
            "invocation_input_may_be_optional"
        case invocationInputMayHaveDefault =
            "invocation_input_may_have_default"
        case invocationInputMayBeVariadicOrInout =
            "invocation_input_may_be_variadic_or_inout"
        case invocationMethodGenericParameterCount =
            "invocation_method_generic_parameter_count"
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
        case exactSeamContextGuardCount =
            "exact_seam_context_guard_count"
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
        case v21CallUsesExplicitWorkerQualification =
            "v21_call_uses_explicit_worker_qualification"
        case exactWrapperConstructionCount =
            "exact_wrapper_construction_count"
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
        case errorValuesPropagateUnchanged =
            "error_values_propagate_unchanged"
        case wrapperSourceMaterialized = "wrapper_source_materialized"
        case invocationMethodSourceMaterialized =
            "invocation_method_source_materialized"
        case exactWorkerSourceCompilerFeasibilityObserved =
            "exact_worker_source_compiler_feasibility_observed"
        case sameModuleSourcesCanNameInvocationSeam =
            "same_module_sources_can_name_invocation_seam"
        case mainCanLexicallyNameInvocationSeam =
            "main_can_lexically_name_invocation_seam"
        case ordinaryNonTestableOutsideModuleCanNameInvocationSeam =
            "ordinary_non_testable_outside_module_can_name_invocation_seam"
        case testableOrPrivilegedImportMayNameInternalSeam =
            "testable_or_privileged_import_may_name_internal_seam"
        case compiledBinarySymbolOrTypeMetadataAbsenceAsserted =
            "compiled_binary_symbol_or_type_metadata_absence_asserted"
        case dynamicLookupInjectionOrExternalInvocationResistanceEstablished =
            "dynamic_lookup_injection_or_external_invocation_resistance_established"
        case privateV21MembersDirectlyNameableOutsideSourceFile =
            "private_v21_members_directly_nameable_outside_source_file"
        case internalSeamExpandsCallableAccessSurface =
            "internal_seam_expands_callable_access_surface"
        case v21PrivateDeclarationAccessWidened =
            "v21_private_declaration_access_widened"
        case crossFileCallerMaterialized =
            "cross_file_caller_materialized"
        case mainReferencesOrCallsInvocationSeam =
            "main_references_or_calls_invocation_seam"
        case runtimeReachableFromMain = "runtime_reachable_from_main"
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
        case sourceIntegrityTestFilesystemReadRequired =
            "source_integrity_test_filesystem_read_required"
        case workerRuntimeArtifactFilesystemReadPerformed =
            "worker_runtime_artifact_filesystem_read_performed"
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
        let worker =
            "PrimeNativeNeuralGateHistoricalFixtureWorker"
        let sourcePath =
            "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactDecoderCallEdge.swift"
        let v21TestPath =
            "Tests/PrimeCoreTests/PrimeNativeNeuralGateHistoricalWorkerExportedEvidenceProjectionDecodeCompositionCallEdgeSourceContractTests.swift"
        let v22TestPath =
            "Tests/PrimeCoreTests/PrimeNativeNeuralGateHistoricalWorkerInvocationSeamDesignContractTests.swift"
        let wrapper =
            "PrimeNativeNeuralGateHistoricalWorkerInvocationSeamResult"

        return Self(
            schemaVersion: 1,
            contractID:
                "prime_source_bound_historical_worker_bounded_unavailable_composition_invocation_seam_v23",
            rightsHolder: "Ergentics, LLC",
            licenseExpression: "LicenseRef-Ergentics-Proprietary",
            preservedInvocationSeamDesignV22ContractID:
                "prime_source_bound_historical_worker_bounded_unavailable_composition_invocation_seam_design_v22",
            preservedInvocationSeamDesignV22ContractSHA256:
                "3954a98474cdaf79a62c65a20cf612f3a1ddaf6b8305aa941e94d3863791e757",
            preservedTopologyV22ID:
                "prime_stage_b_historical_worker_bounded_unavailable_composition_invocation_seam_design_topology_v22",
            preservedTopologyV22SHA256:
                "af914f70b10917e95b895fbf1fc24c6e52764893972d6616bdbb409ba712f4f5",
            preservedCompositionSourceV21ContractID:
                "prime_source_bound_historical_worker_exported_evidence_projection_decode_composition_call_edge_v21",
            preservedCompositionSourceV21ContractSHA256:
                "843b686a63245bffcf210441e1e98b94113b5c02b8f47b80371d3f041a205494",
            workerTargetName: worker,
            seamSource: .init(
                primeRelativePath: sourcePath,
                byteCount: 13_227,
                sha256:
                    "62c0c413e25b95576a023f9b93f67b55a6c38f0cadbdfa4330dba31aea41ae54"
            ),
            preservedV21SourcePrefixByteCount: 11_354,
            preservedV21SourcePrefixSHA256:
                "39cd879a54d6a1198f0a863f606751b1bb9d07f1ba6eb334dd74e9a079c40e1d",
            appendedV23SourceSuffixByteCount: 1_873,
            appendedV23SourceSuffixSHA256:
                "64a0db36f309d92dbd8737f9a6401bb7b9adf58b0193dd4c6d3e46d906017811",
            exactPrefixPreserved: true,
            sourceEvolutionAppendOnly: true,
            packageSwift: .init(
                primeRelativePath: "Package.swift",
                byteCount: 27_650,
                sha256:
                    "190b1d2dbeb2597830b1765fa80d6776a0044a34d5e2c6db8b14ace013654e7d"
            ),
            workerMain: .init(
                primeRelativePath:
                    "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalFixtureWorker.swift",
                byteCount: 2_298,
                sha256:
                    "9f62827d4c35e98fb01f9984b1c227cb681dd42ac4c26147a86e9429958545df"
            ),
            workerEvidenceExportCallEdgeSource: .init(
                primeRelativePath:
                    "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalEvidenceExportCallEdge.swift",
                byteCount: 1_512,
                sha256:
                    "d3ac7fcddd43844e92b61764c458dfce6291471fd465b1bb52f5186814e10319"
            ),
            workerProjectionCallEdgeSource: .init(
                primeRelativePath:
                    "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactProjectionCallEdge.swift",
                byteCount: 1_227,
                sha256:
                    "dce631bd4749a05d8f04323b51c4da37e5ef67df14b950f1e5eee1d1565e0964"
            ),
            workerFixtureResource: .init(
                primeRelativePath:
                    "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/HistoricalFixtureEvidence/Package.resolved",
                byteCount: 1_949,
                sha256:
                    "cf1ba313dcb0c959e80ba09d6cbe0c56bcd921523bda5cec2c682c8ae7696ab3"
            ),
            historicalV21SourceTestBeforeV23: .init(
                primeRelativePath: v21TestPath,
                byteCount: 22_073,
                sha256:
                    "47c576c0ef6157f5cb9fedf5285f13e6755032d563af701710fb9533233170c0"
            ),
            currentV21SourceTest: .init(
                primeRelativePath: v21TestPath,
                byteCount: 22_674,
                sha256:
                    "bfdfe2282192f45ddde57bbcbbec79fdce392ca2853d3b8b977578b45c88fc04"
            ),
            historicalV22DesignTestBeforeV23: .init(
                primeRelativePath: v22TestPath,
                byteCount: 21_325,
                sha256:
                    "5fcee9006d7f322f9ce3f7815dcc5ea370c053fd294e124d9e4a4e3c1e7f4c10"
            ),
            currentV22DesignTest: .init(
                primeRelativePath: v22TestPath,
                byteCount: 21_969,
                sha256:
                    "06ab036c190ab18a702dea80a6f75e9a0f41ce92bd0b2b061fa97dccf2ad92e6"
            ),
            historicalTestsEvolvedTransparently: true,
            orderedWorkerSwiftSourceRelativePaths: [
                "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalEvidenceExportCallEdge.swift",
                "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalFixtureWorker.swift",
                sourcePath,
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
                "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/HistoricalFixtureEvidence/Package.resolved"
            ],
            exactWorkerResourceCount: 1,
            physicalWorkerInventoryExact: true,
            packageGraphChanged: false,
            targetGraphChanged: false,
            forbiddenReachabilityChanged: false,
            workerSourceInventoryChanged: false,
            workerDependenciesChanged: false,
            workerResourcesChanged: false,
            exactImportNames: [
                "Foundation",
                "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection",
                "PrimeNativeNeuralGateHistoricalSemanticArtifactDecoder",
                "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics",
            ],
            importInventoryChanged: false,
            appendedExtensionTargetTypeName: worker,
            exactAppendedExtensionCount: 1,
            wrapperTypeName: wrapper,
            wrapperQualifiedSwiftTypeName: "\(worker).\(wrapper)",
            wrapperDeclarationKind: "struct",
            wrapperAccessLevel: "internal",
            wrapperNestedInWorker: true,
            wrapperPublicPackageSPIOrExported: false,
            wrapperDeclarationAttributeNames: [],
            wrapperGenericParameterCount: 0,
            wrapperExactStoredFieldNames: ["compositionResult"],
            wrapperExactStoredFieldSwiftTypeNames: [
                "PrimeNativeNeuralGateHistoricalEvidenceProjectionDecodeCompositionResult"
            ],
            wrapperExactStoredFieldAccessLevels: ["private"],
            wrapperExactStoredFieldCount: 1,
            wrapperDirectlyRetainsEvidence: false,
            wrapperDirectlyRetainsContext: false,
            wrapperTransitivelyRetainsProjectedAndDecodedArtifactSets: true,
            wrapperInitializerAccessLevel: "private",
            wrapperInitializerExactInputLabels: ["compositionResult"],
            wrapperInitializerExactInputSwiftTypeNames: [
                "PrimeNativeNeuralGateHistoricalEvidenceProjectionDecodeCompositionResult"
            ],
            wrapperInitializerExactInputCount: 1,
            wrapperDeclaredConformanceNames: [],
            wrapperDeclaredSendableConformance: false,
            wrapperImplicitSendableConformance: true,
            wrapperDeclaredCopyableConformance: false,
            wrapperImplicitCopyableConformance: true,
            wrapperAdditionalStoredFieldPermitted: false,
            wrapperComputedPropertyPermitted: false,
            wrapperPayloadAccessorPermitted: false,
            wrapperSubscriptPermitted: false,
            wrapperCallbackOrClosureExposurePermitted: false,
            wrapperDeclaredReflectionOrDescriptionSurfacePermitted: false,
            genericSwiftReflectionMayExposePrivatePayload: true,
            wrapperProvidesConfidentialityBoundary: false,
            wrapperPossessionMayEstablishSecurityBoundary: false,
            invocationMethodEnclosingTypeName: "\(worker).\(wrapper)",
            invocationMethodName:
                "sourceBoundUnavailableHistoricalWorkerInvocationSeam",
            invocationMethodNormalizedSignature:
                "internal static func sourceBoundUnavailableHistoricalWorkerInvocationSeam(evidence: PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence, context: PrimeNativeNeuralGateHistoricalProjectionContext) throws -> Self",
            invocationMethodAccessLevel: "internal",
            invocationMethodAttributeNames: [],
            invocationMethodStatic: true,
            invocationMethodAsync: false,
            invocationMethodThrows: true,
            invocationMethodTypedThrowsDeclared: false,
            invocationMethodReturnSwiftTypeName: "Self",
            exactInvocationInputLabels: ["evidence", "context"],
            exactInvocationInputSwiftTypeNames: [
                "PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence",
                "PrimeNativeNeuralGateHistoricalProjectionContext",
            ],
            exactInvocationInputCount: 2,
            invocationInputMayBeOptional: false,
            invocationInputMayHaveDefault: false,
            invocationInputMayBeVariadicOrInout: false,
            invocationMethodGenericParameterCount: 0,
            evidenceMustBeAlreadyFormed: true,
            contextMustBeExplicit: true,
            evidencePassedToV21CallUnchanged: true,
            contextPassedToV21CallUnchanged: true,
            requiredSourceBytesResolvedState: "unavailable",
            requiredAdaptationProofRecomputedState: "unavailable",
            v21EnforcesBothContextStatesBeforeProjection: true,
            exactSeamContextGuardCount: 0,
            seamDuplicatesOrInventsContextGuard: false,
            unavailableObservedFalseOrNilConflationPermitted: false,
            evidenceOrContextInspectionPermitted: false,
            evidenceOrContextCopyEncodingHashComparisonOrNormalizationPermitted:
                false,
            maintainedV21CallEdgeMethodName:
                "sourceBoundHistoricalEvidenceProjectionDecodeCompositionCallEdge",
            maintainedV21CallEdgeAccessLevel: "private",
            exactMaintainedV21CallCount: 1,
            v21CallUsesExplicitWorkerQualification: true,
            exactWrapperConstructionCount: 1,
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
            errorValuesPropagateUnchanged: true,
            wrapperSourceMaterialized: true,
            invocationMethodSourceMaterialized: true,
            exactWorkerSourceCompilerFeasibilityObserved: true,
            sameModuleSourcesCanNameInvocationSeam: true,
            mainCanLexicallyNameInvocationSeam: true,
            ordinaryNonTestableOutsideModuleCanNameInvocationSeam: false,
            testableOrPrivilegedImportMayNameInternalSeam: true,
            compiledBinarySymbolOrTypeMetadataAbsenceAsserted: false,
            dynamicLookupInjectionOrExternalInvocationResistanceEstablished:
                false,
            privateV21MembersDirectlyNameableOutsideSourceFile: false,
            internalSeamExpandsCallableAccessSurface: true,
            v21PrivateDeclarationAccessWidened: false,
            crossFileCallerMaterialized: false,
            mainReferencesOrCallsInvocationSeam: false,
            runtimeReachableFromMain: false,
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
            sourceIntegrityTestFilesystemReadRequired: true,
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
            nextImplementationPrerequisite:
                "design_the_security_and_leakage_audited_historical_worker_invocation_seam_caller_and_result_consumer_boundary_for_the_source_bound_v23_internal_bridge_before_any_cross_file_or_main_call_edge_payload_observation_replay_transport_integration_request_handling_sealing_launch_execution_artifact_io_publication_or_issuing_source_binding_v7",
            authorityStatement:
                [
                    "This V23 contract preserves the exact V21 composition source as an 11,354-byte prefix, preserves the V22 design and topology identities, and source-binds only the reviewed append-only internal invocation seam.",
                    "The appended internal wrapper has one private V21 composition-result payload and one private initializer. It declares no conformance, accessor, reflection surface, generic parameter, or extra state; Swift nevertheless synthesizes the applicable implicit Sendable and Copyable conformances, and generic reflection may expose its private payload.",
                    "Its sole internal static synchronous throwing method accepts only an already-formed Evidence value and explicit context, passes both unchanged to the exact private V21 call edge once, and stores only that returned value. It adds no guard, validation, inspection, parser, exporter, projector, decoder, catch, retry, fallback, optional or forced try, logging, I/O, or error mapping.",
                    "Internal access intentionally makes the wrapper and seam nameable by every same-module source, including main, and may also expose them to testable or otherwise privileged imports; ordinary non-testable outside-module imports cannot name them. The V21 result and call edge remain directly private to this file. No cross-file caller, checked-in call path from main, or observed invocation is established. V23 does not assert compiled binary symbol or type-metadata absence and does not establish resistance to dynamic lookup, injection, or external invocation.",
                    "Package.swift, the four-file worker inventory, seven-dependency order, one resource, imports, target graph, forbidden reachability, and the 2,298-byte status-78 main remain exact. Source-integrity tests read repository files, but the worker performs no artifact read or write.",
                    "Compilation proves only the typed source and lexical access surface. No runtime input or output, request handling, replay transport integration, sealing, launch, worker/exporter/projector/decoder/gate/model execution, artifact I/O, publication, durability, mechanics PASS, terminal receipt, source or execution binding V7, scientific authority, or product authority is observed or authorized; Prime remains ABSTAIN.",
                ].joined(separator: " ")
        )
    }()

    public func validate() throws {
        guard self == .frozenV1 else {
            throw PrimeNativeNeuralGateHistoricalWorkerInvocationSeamSourceContractError
                .invalidFrozenContract
        }

        let design =
            PrimeNativeNeuralGateHistoricalWorkerInvocationSeamDesignContract
            .frozenV1
        let topology =
            PrimeNativeNeuralGateTrapDisjointTopologyContract.frozenV22
        let v21 =
            PrimeNativeNeuralGateHistoricalWorkerExportedEvidenceProjectionDecodeCompositionCallEdgeSourceContract
            .frozenV1
        let designSHA256 = PrimeSHA256.hexDigest(
            of: try PrimeCanonicalJSON.encode(design)
        )
        let topologySHA256 = PrimeSHA256.hexDigest(
            of: try PrimeCanonicalJSON.encode(topology)
        )
        let v21SHA256 = PrimeSHA256.hexDigest(
            of: try PrimeCanonicalJSON.encode(v21)
        )
        let workerTarget = try topology.target(named: workerTargetName)
        let identities = [
            seamSource,
            packageSwift,
            workerMain,
            workerEvidenceExportCallEdgeSource,
            workerProjectionCallEdgeSource,
            workerFixtureResource,
            historicalV21SourceTestBeforeV23,
            currentV21SourceTest,
            historicalV22DesignTestBeforeV23,
            currentV22DesignTest,
        ]

        guard schemaVersion == 1,
              contractID
                == "prime_source_bound_historical_worker_bounded_unavailable_composition_invocation_seam_v23",
              rightsHolder == "Ergentics, LLC",
              licenseExpression == "LicenseRef-Ergentics-Proprietary",
              preservedInvocationSeamDesignV22ContractID
                == design.contractID,
              preservedInvocationSeamDesignV22ContractSHA256
                == designSHA256,
              preservedInvocationSeamDesignV22ContractSHA256
                == "3954a98474cdaf79a62c65a20cf612f3a1ddaf6b8305aa941e94d3863791e757",
              preservedTopologyV22ID == topology.contractID,
              preservedTopologyV22SHA256 == topologySHA256,
              preservedTopologyV22SHA256
                == "af914f70b10917e95b895fbf1fc24c6e52764893972d6616bdbb409ba712f4f5",
              preservedCompositionSourceV21ContractID
                == v21.contractID,
              preservedCompositionSourceV21ContractSHA256 == v21SHA256,
              preservedCompositionSourceV21ContractSHA256
                == "843b686a63245bffcf210441e1e98b94113b5c02b8f47b80371d3f041a205494",
              identities.allSatisfy({ $0.validate() }),
              seamSource.primeRelativePath
                == v21.compositionSource.primeRelativePath,
              seamSource.primeRelativePath
                == design.futureSourceRelativePath,
              seamSource.byteCount
                == preservedV21SourcePrefixByteCount
                    + appendedV23SourceSuffixByteCount,
              preservedV21SourcePrefixByteCount
                == v21.compositionSource.byteCount,
              preservedV21SourcePrefixByteCount
                == design.preservedV21SourcePrefixByteCount,
              preservedV21SourcePrefixSHA256
                == v21.compositionSource.sha256,
              preservedV21SourcePrefixSHA256
                == design.preservedV21SourcePrefixSHA256,
              exactPrefixPreserved,
              sourceEvolutionAppendOnly,
              workerTargetName == v21.workerTargetName,
              orderedWorkerSwiftSourceRelativePaths
                == v21.orderedWorkerSwiftSourceRelativePaths,
              exactWorkerSwiftSourceFileCount == 4,
              workerDirectLocalDependencyNames
                == v21.workerDirectLocalDependencyNames,
              workerDirectLocalDependencyNames
                == workerTarget.directLocalDependencyNames,
              exactWorkerDirectLocalDependencyCount == 7,
              workerResourceRelativePaths
                == v21.workerResourceRelativePaths,
              exactWorkerResourceCount == 1,
              physicalWorkerInventoryExact,
              !packageGraphChanged,
              !targetGraphChanged,
              !forbiddenReachabilityChanged,
              !workerSourceInventoryChanged,
              !workerDependenciesChanged,
              !workerResourcesChanged,
              exactImportNames == v21.exactImportNames,
              !importInventoryChanged,
              historicalV21SourceTestBeforeV23.primeRelativePath
                == currentV21SourceTest.primeRelativePath,
              historicalV22DesignTestBeforeV23.primeRelativePath
                == currentV22DesignTest.primeRelativePath,
              historicalTestsEvolvedTransparently,
              appendedExtensionTargetTypeName == workerTargetName,
              appendedExtensionTargetTypeName
                == design.futureWrapperEnclosingTypeName,
              exactAppendedExtensionCount == 1,
              wrapperTypeName == design.futureWrapperTypeName,
              wrapperQualifiedSwiftTypeName
                == "\(workerTargetName).\(wrapperTypeName)",
              wrapperQualifiedSwiftTypeName
                == design.futureWrapperQualifiedSwiftTypeName,
              wrapperDeclarationKind
                == design.futureWrapperDeclarationKind,
              wrapperAccessLevel == design.futureWrapperAccessLevel,
              wrapperNestedInWorker == design.futureWrapperNestedInWorker,
              wrapperPublicPackageSPIOrExported
                == design.futureWrapperPublicPackageSPIOrExported,
              wrapperDeclarationAttributeNames.isEmpty,
              wrapperGenericParameterCount == 0,
              wrapperExactStoredFieldNames
                == design.futureWrapperExactStoredFieldNames,
              wrapperExactStoredFieldSwiftTypeNames
                == design.futureWrapperExactStoredFieldSwiftTypeNames,
              wrapperExactStoredFieldSwiftTypeNames
                == [v21.compositionResultTypeName],
              wrapperExactStoredFieldAccessLevels
                == design.futureWrapperExactStoredFieldAccessLevels,
              wrapperExactStoredFieldCount
                == design.futureWrapperExactStoredFieldCount,
              !wrapperDirectlyRetainsEvidence,
              !wrapperDirectlyRetainsContext,
              wrapperTransitivelyRetainsProjectedAndDecodedArtifactSets,
              wrapperInitializerAccessLevel
                == design.futureWrapperInitializerAccessLevel,
              wrapperInitializerExactInputLabels
                == design.futureWrapperInitializerExactInputLabels,
              wrapperInitializerExactInputSwiftTypeNames
                == design.futureWrapperInitializerExactInputSwiftTypeNames,
              wrapperInitializerExactInputCount
                == design.futureWrapperInitializerExactInputCount,
              wrapperDeclaredConformanceNames
                == design.futureWrapperDeclaredConformanceNames,
              !wrapperDeclaredSendableConformance,
              wrapperImplicitSendableConformance,
              !wrapperDeclaredCopyableConformance,
              wrapperImplicitCopyableConformance,
              wrapperAdditionalStoredFieldPermitted
                == design.futureWrapperAdditionalStoredFieldPermitted,
              wrapperComputedPropertyPermitted
                == design.futureWrapperComputedPropertyPermitted,
              wrapperPayloadAccessorPermitted
                == design.futureWrapperPayloadAccessorPermitted,
              wrapperSubscriptPermitted
                == design.futureWrapperSubscriptPermitted,
              wrapperCallbackOrClosureExposurePermitted
                == design.futureWrapperCallbackOrClosureExposurePermitted,
              wrapperDeclaredReflectionOrDescriptionSurfacePermitted
                == design
                    .futureWrapperDeclaredReflectionOrDescriptionSurfacePermitted,
              genericSwiftReflectionMayExposePrivatePayload
                == design.genericSwiftReflectionMayExposePrivatePayload,
              wrapperProvidesConfidentialityBoundary
                == design.futureWrapperProvidesConfidentialityBoundary,
              wrapperPossessionMayEstablishSecurityBoundary
                == design.wrapperPossessionMayEstablishSecurityBoundary,
              invocationMethodEnclosingTypeName
                == design.futureInvocationMethodEnclosingTypeName,
              invocationMethodName
                == design.futureInvocationMethodName,
              invocationMethodNormalizedSignature
                == design.futureInvocationMethodNormalizedSignature,
              invocationMethodAccessLevel
                == design.futureInvocationMethodAccessLevel,
              invocationMethodAttributeNames.isEmpty,
              invocationMethodStatic
                == design.futureInvocationMethodStatic,
              !invocationMethodAsync,
              invocationMethodThrows
                == design.futureInvocationMethodThrows,
              !invocationMethodTypedThrowsDeclared,
              invocationMethodReturnSwiftTypeName == "Self",
              design.futureInvocationMethodReturnSwiftTypeName
                == wrapperQualifiedSwiftTypeName,
              exactInvocationInputLabels
                == design.exactInvocationInputLabels,
              exactInvocationInputSwiftTypeNames
                == design.exactInvocationInputSwiftTypeNames,
              exactInvocationInputCount == design.exactInvocationInputCount,
              invocationInputMayBeOptional
                == design.invocationInputMayBeOptional,
              invocationInputMayHaveDefault
                == design.invocationInputMayHaveDefault,
              !invocationInputMayBeVariadicOrInout,
              !design.additionalInvocationInputPermitted,
              invocationMethodGenericParameterCount == 0,
              evidenceMustBeAlreadyFormed
                == design.evidenceMustBeAlreadyFormed,
              contextMustBeExplicit == design.contextMustBeExplicit,
              evidencePassedToV21CallUnchanged
                == design.evidencePassedToV21CallUnchanged,
              contextPassedToV21CallUnchanged
                == design.contextPassedToV21CallUnchanged,
              requiredSourceBytesResolvedState
                == design.requiredSourceBytesResolvedState,
              requiredAdaptationProofRecomputedState
                == design.requiredAdaptationProofRecomputedState,
              v21EnforcesBothContextStatesBeforeProjection
                == design.v21EnforcesBothContextStatesBeforeProjection,
              exactSeamContextGuardCount == 0,
              seamDuplicatesOrInventsContextGuard
                == design.seamDuplicatesOrInventsContextGuard,
              unavailableObservedFalseOrNilConflationPermitted
                == design.unavailableObservedFalseOrNilConflationPermitted,
              evidenceOrContextInspectionPermitted
                == design.evidenceOrContextInspectionPermitted,
              evidenceOrContextCopyEncodingHashComparisonOrNormalizationPermitted
                == design
                    .evidenceOrContextCopyEncodingHashComparisonOrNormalizationPermitted,
              maintainedV21CallEdgeMethodName
                == design.maintainedV21CallEdgeMethodName,
              maintainedV21CallEdgeAccessLevel
                == design.maintainedV21CallEdgeAccessLevel,
              exactMaintainedV21CallCount
                == design.exactMaintainedV21CallCount,
              v21CallUsesExplicitWorkerQualification,
              exactWrapperConstructionCount == 1,
              maintainedV21ReturnBecomesSolePrivatePayload
                == design.maintainedV21ReturnBecomesSolePrivatePayload,
              directComposeCallPermitted == design.directComposeCallPermitted,
              directProjectorCallPermitted
                == design.directProjectorCallPermitted,
              directDecoderCallPermitted == design.directDecoderCallPermitted,
              directExporterOrFixtureCallPermitted
                == design.directExporterOrFixtureCallPermitted,
              seamGuardOrRevalidationPermitted
                == design.seamGuardOrRevalidationPermitted,
              newErrorTypeOrCasePermitted == design.newErrorTypeOrCasePermitted,
              catchRetryFallbackOrSubstitutionPermitted
                == design.catchRetryFallbackOrSubstitutionPermitted,
              optionalOrForcedTryPermitted
                == design.optionalOrForcedTryPermitted,
              loggingOrPartialResultPermitted
                == design.loggingOrPartialResultPermitted,
              errorValuesPropagateUnchanged
                == design.exactTypedFailurePropagationRequired,
              wrapperSourceMaterialized,
              invocationMethodSourceMaterialized,
              exactWorkerSourceCompilerFeasibilityObserved,
              sameModuleSourcesCanNameInvocationSeam,
              mainCanLexicallyNameInvocationSeam,
              !ordinaryNonTestableOutsideModuleCanNameInvocationSeam,
              testableOrPrivilegedImportMayNameInternalSeam,
              !compiledBinarySymbolOrTypeMetadataAbsenceAsserted,
              !dynamicLookupInjectionOrExternalInvocationResistanceEstablished,
              !privateV21MembersDirectlyNameableOutsideSourceFile,
              internalSeamExpandsCallableAccessSurface,
              !v21PrivateDeclarationAccessWidened,
              !crossFileCallerMaterialized,
              !mainReferencesOrCallsInvocationSeam,
              !runtimeReachableFromMain,
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
              sourceIntegrityTestFilesystemReadRequired,
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
              nextImplementationPrerequisite
                == "design_the_security_and_leakage_audited_historical_worker_invocation_seam_caller_and_result_consumer_boundary_for_the_source_bound_v23_internal_bridge_before_any_cross_file_or_main_call_edge_payload_observation_replay_transport_integration_request_handling_sealing_launch_execution_artifact_io_publication_or_issuing_source_binding_v7",
              authorityStatement.contains(
                  "nameable by every same-module source, including main"
              ),
              authorityStatement.contains(
                  "Prime remains ABSTAIN"
              )
        else {
            throw PrimeNativeNeuralGateHistoricalWorkerInvocationSeamSourceContractError
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
