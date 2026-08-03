// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

public enum
    PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerSourceContractError:
    Error,
    Equatable,
    Sendable
{
    case invalidFrozenContract
}

public struct
    PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerSourceIdentity:
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

/// Frozen V25 source boundary for the unavailable historical worker's
/// caller and discard consumer.
///
/// V25 preserves the complete V23 worker source as an exact prefix and
/// appends only the V24-designed nested two-case disposition and one-call
/// nonthrowing boundary in the same physical source file. Compilation proves
/// the source shape only. No caller of the new boundary, process, request,
/// transport, execution, artifact I/O, publication, receipt, V7, scientific
/// authority, or product authority is materialized or authorized.
public struct
    PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerSourceContract:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let contractID: String
    public let rightsHolder: String
    public let licenseExpression: String

    public let preservedCallerAndResultConsumerDesignV24ContractID: String
    public let preservedCallerAndResultConsumerDesignV24ContractSHA256: String
    public let preservedTopologyV24ID: String
    public let preservedTopologyV24SHA256: String
    public let preservedInvocationSeamSourceV23ContractID: String
    public let preservedInvocationSeamSourceV23ContractSHA256: String
    public let preservedTopologyV23ID: String
    public let preservedTopologyV23SHA256: String

    public let callerAndResultConsumerDesignContractSource:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerSourceIdentity
    public let historicalV24DesignContractTestBeforeV25:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerSourceIdentity
    public let currentV24DesignContractTestAfterV25:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerSourceIdentity
    public let historicalTopologySourceBeforeV25:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerSourceIdentity
    public let topologyV24Test:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerSourceIdentity
    public let invocationSeamSourceV23ContractSource:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerSourceIdentity
    public let historicalV23SourceContractTestBeforeV25:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerSourceIdentity
    public let currentV23SourceContractTestAfterV25:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerSourceIdentity
    public let historicalTestsEvolvedPrefixSafely: Bool

    public let workerTargetName: String
    public let callerAndResultConsumerSource:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerSourceIdentity
    public let preservedV23SourcePrefixByteCount: UInt64
    public let preservedV23SourcePrefixSHA256: String
    public let appendedV25SourceSuffixByteCount: UInt64
    public let appendedV25SourceSuffixSHA256: String
    public let appendedV25WhitespaceStrippedByteCount: UInt64
    public let appendedV25WhitespaceStrippedSHA256: String
    public let appendedV25WhitespaceStrippedSource: String
    public let exactV23PrefixPreserved: Bool
    public let sourceEvolutionAppendOnly: Bool

    public let packageSwift:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerSourceIdentity
    public let workerMain:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerSourceIdentity
    public let workerEvidenceExportCallEdgeSource:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerSourceIdentity
    public let workerProjectionCallEdgeSource:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerSourceIdentity
    public let workerFixtureResource:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerSourceIdentity
    public let orderedWorkerSwiftSourceRelativePaths: [String]
    public let exactWorkerSwiftSourceFileCount: Int
    public let workerDirectLocalDependencyNames: [String]
    public let exactWorkerDirectLocalDependencyCount: Int
    public let workerResourceRelativePaths: [String]
    public let exactWorkerResourceCount: Int
    public let physicalWorkerInventoryExact: Bool
    public let exactImportNames: [String]
    public let packageGraphChanged: Bool
    public let targetGraphChanged: Bool
    public let forbiddenReachabilityChanged: Bool
    public let workerSourceInventoryChanged: Bool
    public let workerDependenciesChanged: Bool
    public let workerResourcesChanged: Bool
    public let importInventoryChanged: Bool

    public let appendedExtensionTargetTypeName: String
    public let exactAppendedExtensionCount: Int
    public let dispositionTypeName: String
    public let dispositionQualifiedSwiftTypeName: String
    public let dispositionDeclarationKind: String
    public let dispositionAccessLevel: String
    public let dispositionNestedInWrapper: Bool
    public let dispositionExactCaseNames: [String]
    public let dispositionExactCaseCount: Int
    public let dispositionAssociatedValueCount: Int
    public let dispositionHasRawType: Bool
    public let dispositionDeclaredConformanceNames: [String]
    public let dispositionAttributeNames: [String]
    public let dispositionStoredFieldCount: Int
    public let dispositionMethodCount: Int
    public let dispositionGenericParameterCount: Int
    public let dispositionImplicitSendable: Bool
    public let dispositionOrdinarilyCopyable: Bool
    public let dispositionProvidesConfidentialityBoundary: Bool
    public let dispositionProvidesAuthorityBoundary: Bool

    public let boundaryMethodEnclosingTypeName: String
    public let boundaryMethodName: String
    public let boundaryMethodNormalizedSignature: String
    public let boundaryMethodNormalizedBody: String
    public let boundaryMethodAccessLevel: String
    public let boundaryMethodStatic: Bool
    public let boundaryMethodAsync: Bool
    public let boundaryMethodThrows: Bool
    public let boundaryMethodReturnSwiftTypeName: String
    public let exactBoundaryInputLabels: [String]
    public let exactBoundaryInputSwiftTypeNames: [String]
    public let exactBoundaryInputCount: Int
    public let boundaryInputMayBeOptional: Bool
    public let boundaryInputMayHaveDefault: Bool
    public let boundaryInputMayBeVariadicOrInout: Bool
    public let boundaryMethodGenericParameterCount: Int

    public let maintainedV23SeamMethodName: String
    public let maintainedV23SeamAccessLevel: String
    public let evidencePassedToV23SeamUnchanged: Bool
    public let contextPassedToV23SeamUnchanged: Bool
    public let v23SeamUsesExplicitSelfQualification: Bool
    public let exactDoCount: Int
    public let exactV23SeamCallCount: Int
    public let exactTryCount: Int
    public let exactBareCatchCount: Int
    public let exactSuccessReturnCount: Int
    public let exactFailureReturnCount: Int
    public let successReturnOccursOnlyAfterSeamReturns: Bool
    public let everyCaughtSwiftErrorMapsToFailedClosedWithoutDetail: Bool
    public let wrapperValueNamedOrBound: Bool
    public let wrapperOrCompositionReturned: Bool
    public let wrapperOrCompositionExplicitlyCopied: Bool
    public let wrapperOrCompositionRetainedOrCaptured: Bool
    public let payloadAccessed: Bool
    public let evidenceContextWrapperCompositionOrErrorReflected: Bool
    public let evidenceContextWrapperCompositionOrErrorEncodedOrSerialized:
        Bool
    public let evidenceContextWrapperCompositionOrErrorLoggedOrPublished: Bool
    public let errorBoundInspectedOrReturned: Bool
    public let timingOrResourceMeasured: Bool
    public let retryFallbackOrSubstitutionPermitted: Bool
    public let directV21ComposeProjectorDecoderOrExporterCallPermitted: Bool
    public let dispositionEstablishesFixtureOriginOrAuthority: Bool

    public let extensionSourceMaterialized: Bool
    public let dispositionSourceMaterialized: Bool
    public let boundaryMethodSourceMaterialized: Bool
    public let rawSeamCallerMaterialized: Bool
    public let discardConsumerMaterialized: Bool
    public let callerOfNonpayloadBoundaryMaterialized: Bool
    public let exactWorkerSourceCompilerFeasibilityObserved: Bool
    public let reducedSwiftCanaryCompilerFeasibilityObserved: Bool
    public let rawV23SeamRemainsInternal: Bool
    public let v23PrivatePayloadOrInitializerAccessWidened: Bool
    public let boundaryIsSoleCheckedInRawSeamCaller: Bool
    public let otherRawSeamCallerMaterialized: Bool
    public let sameModuleSourcesCanNameRawSeam: Bool
    public let mainCanLexicallyNameRawSeam: Bool
    public let mainCanLexicallyNameBoundary: Bool
    public let ordinaryNonTestableOutsideModuleCanNameBoundary: Bool
    public let testableOrPrivilegedImportMayNameInternalBoundary: Bool
    public let sameModuleRawSeamBypassPrevented: Bool
    public let testableRawSeamBypassPrevented: Bool
    public let dynamicOrUnsafeBypassPrevented: Bool
    public let genericReflectionMayExposePrivatePayload: Bool
    public let confidentialityEstablished: Bool
    public let zeroizationEstablished: Bool
    public let constantTimeEstablished: Bool
    public let constantResourceUseEstablished: Bool
    public let trapsSignalsOrOutOfMemoryContained: Bool
    public let hardRuntimeRequiresHardenedIsolation: Bool

    public let mainReferencesOrCallsBoundary: Bool
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
        case preservedCallerAndResultConsumerDesignV24ContractID =
            "preserved_caller_and_result_consumer_design_v24_contract_id"
        case preservedCallerAndResultConsumerDesignV24ContractSHA256 =
            "preserved_caller_and_result_consumer_design_v24_contract_sha256"
        case preservedTopologyV24ID = "preserved_topology_v24_id"
        case preservedTopologyV24SHA256 = "preserved_topology_v24_sha256"
        case preservedInvocationSeamSourceV23ContractID =
            "preserved_invocation_seam_source_v23_contract_id"
        case preservedInvocationSeamSourceV23ContractSHA256 =
            "preserved_invocation_seam_source_v23_contract_sha256"
        case preservedTopologyV23ID = "preserved_topology_v23_id"
        case preservedTopologyV23SHA256 = "preserved_topology_v23_sha256"
        case callerAndResultConsumerDesignContractSource =
            "caller_and_result_consumer_design_contract_source"
        case historicalV24DesignContractTestBeforeV25 =
            "historical_v24_design_contract_test_before_v25"
        case currentV24DesignContractTestAfterV25 =
            "current_v24_design_contract_test_after_v25"
        case historicalTopologySourceBeforeV25 =
            "historical_topology_source_before_v25"
        case topologyV24Test = "topology_v24_test"
        case invocationSeamSourceV23ContractSource =
            "invocation_seam_source_v23_contract_source"
        case historicalV23SourceContractTestBeforeV25 =
            "historical_v23_source_contract_test_before_v25"
        case currentV23SourceContractTestAfterV25 =
            "current_v23_source_contract_test_after_v25"
        case historicalTestsEvolvedPrefixSafely =
            "historical_tests_evolved_prefix_safely"
        case workerTargetName = "worker_target_name"
        case callerAndResultConsumerSource =
            "caller_and_result_consumer_source"
        case preservedV23SourcePrefixByteCount =
            "preserved_v23_source_prefix_byte_count"
        case preservedV23SourcePrefixSHA256 =
            "preserved_v23_source_prefix_sha256"
        case appendedV25SourceSuffixByteCount =
            "appended_v25_source_suffix_byte_count"
        case appendedV25SourceSuffixSHA256 =
            "appended_v25_source_suffix_sha256"
        case appendedV25WhitespaceStrippedByteCount =
            "appended_v25_whitespace_stripped_byte_count"
        case appendedV25WhitespaceStrippedSHA256 =
            "appended_v25_whitespace_stripped_sha256"
        case appendedV25WhitespaceStrippedSource =
            "appended_v25_whitespace_stripped_source"
        case exactV23PrefixPreserved = "exact_v23_prefix_preserved"
        case sourceEvolutionAppendOnly = "source_evolution_append_only"
        case packageSwift = "package_swift"
        case workerMain = "worker_main"
        case workerEvidenceExportCallEdgeSource =
            "worker_evidence_export_call_edge_source"
        case workerProjectionCallEdgeSource =
            "worker_projection_call_edge_source"
        case workerFixtureResource = "worker_fixture_resource"
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
        case exactImportNames = "exact_import_names"
        case packageGraphChanged = "package_graph_changed"
        case targetGraphChanged = "target_graph_changed"
        case forbiddenReachabilityChanged =
            "forbidden_reachability_changed"
        case workerSourceInventoryChanged =
            "worker_source_inventory_changed"
        case workerDependenciesChanged = "worker_dependencies_changed"
        case workerResourcesChanged = "worker_resources_changed"
        case importInventoryChanged = "import_inventory_changed"
        case appendedExtensionTargetTypeName =
            "appended_extension_target_type_name"
        case exactAppendedExtensionCount =
            "exact_appended_extension_count"
        case dispositionTypeName = "disposition_type_name"
        case dispositionQualifiedSwiftTypeName =
            "disposition_qualified_swift_type_name"
        case dispositionDeclarationKind =
            "disposition_declaration_kind"
        case dispositionAccessLevel = "disposition_access_level"
        case dispositionNestedInWrapper =
            "disposition_nested_in_wrapper"
        case dispositionExactCaseNames =
            "disposition_exact_case_names"
        case dispositionExactCaseCount =
            "disposition_exact_case_count"
        case dispositionAssociatedValueCount =
            "disposition_associated_value_count"
        case dispositionHasRawType = "disposition_has_raw_type"
        case dispositionDeclaredConformanceNames =
            "disposition_declared_conformance_names"
        case dispositionAttributeNames =
            "disposition_attribute_names"
        case dispositionStoredFieldCount =
            "disposition_stored_field_count"
        case dispositionMethodCount = "disposition_method_count"
        case dispositionGenericParameterCount =
            "disposition_generic_parameter_count"
        case dispositionImplicitSendable =
            "disposition_implicit_sendable"
        case dispositionOrdinarilyCopyable =
            "disposition_ordinarily_copyable"
        case dispositionProvidesConfidentialityBoundary =
            "disposition_provides_confidentiality_boundary"
        case dispositionProvidesAuthorityBoundary =
            "disposition_provides_authority_boundary"
        case boundaryMethodEnclosingTypeName =
            "boundary_method_enclosing_type_name"
        case boundaryMethodName = "boundary_method_name"
        case boundaryMethodNormalizedSignature =
            "boundary_method_normalized_signature"
        case boundaryMethodNormalizedBody =
            "boundary_method_normalized_body"
        case boundaryMethodAccessLevel =
            "boundary_method_access_level"
        case boundaryMethodStatic = "boundary_method_static"
        case boundaryMethodAsync = "boundary_method_async"
        case boundaryMethodThrows = "boundary_method_throws"
        case boundaryMethodReturnSwiftTypeName =
            "boundary_method_return_swift_type_name"
        case exactBoundaryInputLabels =
            "exact_boundary_input_labels"
        case exactBoundaryInputSwiftTypeNames =
            "exact_boundary_input_swift_type_names"
        case exactBoundaryInputCount = "exact_boundary_input_count"
        case boundaryInputMayBeOptional =
            "boundary_input_may_be_optional"
        case boundaryInputMayHaveDefault =
            "boundary_input_may_have_default"
        case boundaryInputMayBeVariadicOrInout =
            "boundary_input_may_be_variadic_or_inout"
        case boundaryMethodGenericParameterCount =
            "boundary_method_generic_parameter_count"
        case maintainedV23SeamMethodName =
            "maintained_v23_seam_method_name"
        case maintainedV23SeamAccessLevel =
            "maintained_v23_seam_access_level"
        case evidencePassedToV23SeamUnchanged =
            "evidence_passed_to_v23_seam_unchanged"
        case contextPassedToV23SeamUnchanged =
            "context_passed_to_v23_seam_unchanged"
        case v23SeamUsesExplicitSelfQualification =
            "v23_seam_uses_explicit_self_qualification"
        case exactDoCount = "exact_do_count"
        case exactV23SeamCallCount = "exact_v23_seam_call_count"
        case exactTryCount = "exact_try_count"
        case exactBareCatchCount = "exact_bare_catch_count"
        case exactSuccessReturnCount = "exact_success_return_count"
        case exactFailureReturnCount = "exact_failure_return_count"
        case successReturnOccursOnlyAfterSeamReturns =
            "success_return_occurs_only_after_seam_returns"
        case everyCaughtSwiftErrorMapsToFailedClosedWithoutDetail =
            "every_caught_swift_error_maps_to_failed_closed_without_detail"
        case wrapperValueNamedOrBound = "wrapper_value_named_or_bound"
        case wrapperOrCompositionReturned =
            "wrapper_or_composition_returned"
        case wrapperOrCompositionExplicitlyCopied =
            "wrapper_or_composition_explicitly_copied"
        case wrapperOrCompositionRetainedOrCaptured =
            "wrapper_or_composition_retained_or_captured"
        case payloadAccessed = "payload_accessed"
        case evidenceContextWrapperCompositionOrErrorReflected =
            "evidence_context_wrapper_composition_or_error_reflected"
        case evidenceContextWrapperCompositionOrErrorEncodedOrSerialized =
            "evidence_context_wrapper_composition_or_error_encoded_or_serialized"
        case evidenceContextWrapperCompositionOrErrorLoggedOrPublished =
            "evidence_context_wrapper_composition_or_error_logged_or_published"
        case errorBoundInspectedOrReturned =
            "error_bound_inspected_or_returned"
        case timingOrResourceMeasured =
            "timing_or_resource_measured"
        case retryFallbackOrSubstitutionPermitted =
            "retry_fallback_or_substitution_permitted"
        case directV21ComposeProjectorDecoderOrExporterCallPermitted =
            "direct_v21_compose_projector_decoder_or_exporter_call_permitted"
        case dispositionEstablishesFixtureOriginOrAuthority =
            "disposition_establishes_fixture_origin_or_authority"
        case extensionSourceMaterialized =
            "extension_source_materialized"
        case dispositionSourceMaterialized =
            "disposition_source_materialized"
        case boundaryMethodSourceMaterialized =
            "boundary_method_source_materialized"
        case rawSeamCallerMaterialized =
            "raw_seam_caller_materialized"
        case discardConsumerMaterialized =
            "discard_consumer_materialized"
        case callerOfNonpayloadBoundaryMaterialized =
            "caller_of_nonpayload_boundary_materialized"
        case exactWorkerSourceCompilerFeasibilityObserved =
            "exact_worker_source_compiler_feasibility_observed"
        case reducedSwiftCanaryCompilerFeasibilityObserved =
            "reduced_swift_canary_compiler_feasibility_observed"
        case rawV23SeamRemainsInternal =
            "raw_v23_seam_remains_internal"
        case v23PrivatePayloadOrInitializerAccessWidened =
            "v23_private_payload_or_initializer_access_widened"
        case boundaryIsSoleCheckedInRawSeamCaller =
            "boundary_is_sole_checked_in_raw_seam_caller"
        case otherRawSeamCallerMaterialized =
            "other_raw_seam_caller_materialized"
        case sameModuleSourcesCanNameRawSeam =
            "same_module_sources_can_name_raw_seam"
        case mainCanLexicallyNameRawSeam =
            "main_can_lexically_name_raw_seam"
        case mainCanLexicallyNameBoundary =
            "main_can_lexically_name_boundary"
        case ordinaryNonTestableOutsideModuleCanNameBoundary =
            "ordinary_non_testable_outside_module_can_name_boundary"
        case testableOrPrivilegedImportMayNameInternalBoundary =
            "testable_or_privileged_import_may_name_internal_boundary"
        case sameModuleRawSeamBypassPrevented =
            "same_module_raw_seam_bypass_prevented"
        case testableRawSeamBypassPrevented =
            "testable_raw_seam_bypass_prevented"
        case dynamicOrUnsafeBypassPrevented =
            "dynamic_or_unsafe_bypass_prevented"
        case genericReflectionMayExposePrivatePayload =
            "generic_reflection_may_expose_private_payload"
        case confidentialityEstablished =
            "confidentiality_established"
        case zeroizationEstablished = "zeroization_established"
        case constantTimeEstablished = "constant_time_established"
        case constantResourceUseEstablished =
            "constant_resource_use_established"
        case trapsSignalsOrOutOfMemoryContained =
            "traps_signals_or_out_of_memory_contained"
        case hardRuntimeRequiresHardenedIsolation =
            "hard_runtime_requires_hardened_isolation"
        case mainReferencesOrCallsBoundary =
            "main_references_or_calls_boundary"
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
        let workerDirectory =
            "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/"
        let sourcePath = workerDirectory
            + "PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactDecoderCallEdge.swift"
        let wrapper =
            "PrimeNativeNeuralGateHistoricalWorkerInvocationSeamResult"
        let qualifiedWrapper = "\(worker).\(wrapper)"
        let disposition = "CallerResultConsumerDisposition"
        let compactSuffix =
            "extensionPrimeNativeNeuralGateHistoricalFixtureWorker.PrimeNativeNeuralGateHistoricalWorkerInvocationSeamResult{internalenumCallerResultConsumerDisposition{casecompositionCompletedAndDiscardedcasefailedClosedWithoutDetail}internalstaticfuncsourceBoundUnavailableHistoricalWorkerInvocationSeamCallerAndDiscardConsumer(evidence:PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence,context:PrimeNativeNeuralGateHistoricalProjectionContext)->CallerResultConsumerDisposition{do{_=trySelf.sourceBoundUnavailableHistoricalWorkerInvocationSeam(evidence:evidence,context:context)return.compositionCompletedAndDiscarded}catch{return.failedClosedWithoutDetail}}}"

        return Self(
            schemaVersion: 1,
            contractID:
                "prime_source_bound_historical_worker_bounded_unavailable_composition_invocation_seam_caller_result_consumer_v25",
            rightsHolder: "Ergentics, LLC",
            licenseExpression: "LicenseRef-Ergentics-Proprietary",
            preservedCallerAndResultConsumerDesignV24ContractID:
                "prime_source_bound_historical_worker_bounded_unavailable_composition_invocation_seam_caller_result_consumer_security_design_v24",
            preservedCallerAndResultConsumerDesignV24ContractSHA256:
                "3c9f34cfae3e50012e40a4b59e38eb5a90bc47e3906a1df5c5111978dac3c902",
            preservedTopologyV24ID:
                "prime_stage_b_historical_worker_bounded_unavailable_composition_invocation_seam_caller_result_consumer_security_design_topology_v24",
            preservedTopologyV24SHA256:
                "711f57d47575f7f166bee5f2b32708d3a86631406a3a3b96f370e1de1da8ce91",
            preservedInvocationSeamSourceV23ContractID:
                "prime_source_bound_historical_worker_bounded_unavailable_composition_invocation_seam_v23",
            preservedInvocationSeamSourceV23ContractSHA256:
                "6ae4cd1fadf95f3b18c38d7e4ec2d732f6e0b614399fb76334043bf9851bb656",
            preservedTopologyV23ID:
                "prime_stage_b_historical_worker_bounded_unavailable_composition_invocation_seam_source_topology_v23",
            preservedTopologyV23SHA256:
                "48f5f1359af1eb3151196ef1e9cb417a6189d8c6461b0c3e595edee39aaee3d9",
            callerAndResultConsumerDesignContractSource: .init(
                primeRelativePath:
                    "Sources/PrimeCore/PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerDesignContract.swift",
                byteCount: 55_753,
                sha256:
                    "08bf11deb2ceddabe6ffe321737e4f027f2ac526290fd3e37260106d2af38d9c"
            ),
            historicalV24DesignContractTestBeforeV25: .init(
                primeRelativePath:
                    "Tests/PrimeCoreTests/PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerDesignContractTests.swift",
                byteCount: 27_806,
                sha256:
                    "f1dabbded24243df79c4c367fd88795ad53131146a33516a58660279d4fe3096"
            ),
            currentV24DesignContractTestAfterV25: .init(
                primeRelativePath:
                    "Tests/PrimeCoreTests/PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerDesignContractTests.swift",
                byteCount: 28_931,
                sha256:
                    "8b964c9beaac49a42a2d5fdabd427c5d7d5ddadcd6e64a65ca87b6d7ff4c8926"
            ),
            historicalTopologySourceBeforeV25: .init(
                primeRelativePath:
                    "Sources/PrimeCore/PrimeNativeNeuralGateTrapDisjointTopology.swift",
                byteCount: 249_163,
                sha256:
                    "ee1464ca5e0579b41b2fd046f7fac1036f5b29efab99934412ee3dfc07b50280"
            ),
            topologyV24Test: .init(
                primeRelativePath:
                    "Tests/PrimeCoreTests/PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerDesignTopologyV24Tests.swift",
                byteCount: 20_581,
                sha256:
                    "88755aaff8c8aa191e4753a7ba4fed6e25127cbf55a9eebac39fa1b7c4e9d548"
            ),
            invocationSeamSourceV23ContractSource: .init(
                primeRelativePath:
                    "Sources/PrimeCore/PrimeNativeNeuralGateHistoricalWorkerInvocationSeamSourceContract.swift",
                byteCount: 59_396,
                sha256:
                    "ca4d2caa4769110c0e6c69d026ea67b468c2cec670ce1f9c20232ba0aa32b8a0"
            ),
            historicalV23SourceContractTestBeforeV25: .init(
                primeRelativePath:
                    "Tests/PrimeCoreTests/PrimeNativeNeuralGateHistoricalWorkerInvocationSeamSourceContractTests.swift",
                byteCount: 32_205,
                sha256:
                    "b4e9be3a7dfa8d04a32e3c072bb8dc57078884da2f8a4e4d8c74807f4e9c8de2"
            ),
            currentV23SourceContractTestAfterV25: .init(
                primeRelativePath:
                    "Tests/PrimeCoreTests/PrimeNativeNeuralGateHistoricalWorkerInvocationSeamSourceContractTests.swift",
                byteCount: 32_576,
                sha256:
                    "3ac8faf37a870a38b6893f6962212d58bdcc1ee91ce1d8af722ef66bef0bb1a0"
            ),
            historicalTestsEvolvedPrefixSafely: true,
            workerTargetName: worker,
            callerAndResultConsumerSource: .init(
                primeRelativePath: sourcePath,
                byteCount: 14_175,
                sha256:
                    "bac6238644345afea2fb3404a0e073885d232380c31d3f4ce02f53936abe47a8"
            ),
            preservedV23SourcePrefixByteCount: 13_227,
            preservedV23SourcePrefixSHA256:
                "62c0c413e25b95576a023f9b93f67b55a6c38f0cadbdfa4330dba31aea41ae54",
            appendedV25SourceSuffixByteCount: 948,
            appendedV25SourceSuffixSHA256:
                "ed9c1527b23190fb8c8e3d2ce2144929cf8e6d551d3b6a3c4dad6f4b9e08f626",
            appendedV25WhitespaceStrippedByteCount: 655,
            appendedV25WhitespaceStrippedSHA256:
                "f0b208db4f89c6c33970cc5c1a7539b53a093df3199bbe347a213bc3267c31e5",
            appendedV25WhitespaceStrippedSource: compactSuffix,
            exactV23PrefixPreserved: true,
            sourceEvolutionAppendOnly: true,
            packageSwift: .init(
                primeRelativePath: "Package.swift",
                byteCount: 27_650,
                sha256:
                    "190b1d2dbeb2597830b1765fa80d6776a0044a34d5e2c6db8b14ace013654e7d"
            ),
            workerMain: .init(
                primeRelativePath: workerDirectory
                    + "PrimeNativeNeuralGateHistoricalFixtureWorker.swift",
                byteCount: 2_298,
                sha256:
                    "9f62827d4c35e98fb01f9984b1c227cb681dd42ac4c26147a86e9429958545df"
            ),
            workerEvidenceExportCallEdgeSource: .init(
                primeRelativePath: workerDirectory
                    + "PrimeNativeNeuralGateHistoricalEvidenceExportCallEdge.swift",
                byteCount: 1_512,
                sha256:
                    "d3ac7fcddd43844e92b61764c458dfce6291471fd465b1bb52f5186814e10319"
            ),
            workerProjectionCallEdgeSource: .init(
                primeRelativePath: workerDirectory
                    + "PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactProjectionCallEdge.swift",
                byteCount: 1_227,
                sha256:
                    "dce631bd4749a05d8f04323b51c4da37e5ef67df14b950f1e5eee1d1565e0964"
            ),
            workerFixtureResource: .init(
                primeRelativePath: workerDirectory
                    + "HistoricalFixtureEvidence/Package.resolved",
                byteCount: 1_949,
                sha256:
                    "cf1ba313dcb0c959e80ba09d6cbe0c56bcd921523bda5cec2c682c8ae7696ab3"
            ),
            orderedWorkerSwiftSourceRelativePaths: [
                workerDirectory
                    + "PrimeNativeNeuralGateHistoricalEvidenceExportCallEdge.swift",
                workerDirectory
                    + "PrimeNativeNeuralGateHistoricalFixtureWorker.swift",
                sourcePath,
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
            physicalWorkerInventoryExact: true,
            exactImportNames: [
                "Foundation",
                "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection",
                "PrimeNativeNeuralGateHistoricalSemanticArtifactDecoder",
                "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics",
            ],
            packageGraphChanged: false,
            targetGraphChanged: false,
            forbiddenReachabilityChanged: false,
            workerSourceInventoryChanged: false,
            workerDependenciesChanged: false,
            workerResourcesChanged: false,
            importInventoryChanged: false,
            appendedExtensionTargetTypeName: qualifiedWrapper,
            exactAppendedExtensionCount: 1,
            dispositionTypeName: disposition,
            dispositionQualifiedSwiftTypeName:
                "\(qualifiedWrapper).\(disposition)",
            dispositionDeclarationKind: "enum",
            dispositionAccessLevel: "internal",
            dispositionNestedInWrapper: true,
            dispositionExactCaseNames: [
                "compositionCompletedAndDiscarded",
                "failedClosedWithoutDetail",
            ],
            dispositionExactCaseCount: 2,
            dispositionAssociatedValueCount: 0,
            dispositionHasRawType: false,
            dispositionDeclaredConformanceNames: [],
            dispositionAttributeNames: [],
            dispositionStoredFieldCount: 0,
            dispositionMethodCount: 0,
            dispositionGenericParameterCount: 0,
            dispositionImplicitSendable: true,
            dispositionOrdinarilyCopyable: true,
            dispositionProvidesConfidentialityBoundary: false,
            dispositionProvidesAuthorityBoundary: false,
            boundaryMethodEnclosingTypeName: qualifiedWrapper,
            boundaryMethodName:
                "sourceBoundUnavailableHistoricalWorkerInvocationSeamCallerAndDiscardConsumer",
            boundaryMethodNormalizedSignature:
                "internal static func sourceBoundUnavailableHistoricalWorkerInvocationSeamCallerAndDiscardConsumer(evidence: PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence, context: PrimeNativeNeuralGateHistoricalProjectionContext) -> CallerResultConsumerDisposition",
            boundaryMethodNormalizedBody:
                "do{_=trySelf.sourceBoundUnavailableHistoricalWorkerInvocationSeam(evidence:evidence,context:context)return.compositionCompletedAndDiscarded}catch{return.failedClosedWithoutDetail}",
            boundaryMethodAccessLevel: "internal",
            boundaryMethodStatic: true,
            boundaryMethodAsync: false,
            boundaryMethodThrows: false,
            boundaryMethodReturnSwiftTypeName: disposition,
            exactBoundaryInputLabels: ["evidence", "context"],
            exactBoundaryInputSwiftTypeNames: [
                "PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence",
                "PrimeNativeNeuralGateHistoricalProjectionContext",
            ],
            exactBoundaryInputCount: 2,
            boundaryInputMayBeOptional: false,
            boundaryInputMayHaveDefault: false,
            boundaryInputMayBeVariadicOrInout: false,
            boundaryMethodGenericParameterCount: 0,
            maintainedV23SeamMethodName:
                "sourceBoundUnavailableHistoricalWorkerInvocationSeam",
            maintainedV23SeamAccessLevel: "internal",
            evidencePassedToV23SeamUnchanged: true,
            contextPassedToV23SeamUnchanged: true,
            v23SeamUsesExplicitSelfQualification: true,
            exactDoCount: 1,
            exactV23SeamCallCount: 1,
            exactTryCount: 1,
            exactBareCatchCount: 1,
            exactSuccessReturnCount: 1,
            exactFailureReturnCount: 1,
            successReturnOccursOnlyAfterSeamReturns: true,
            everyCaughtSwiftErrorMapsToFailedClosedWithoutDetail: true,
            wrapperValueNamedOrBound: false,
            wrapperOrCompositionReturned: false,
            wrapperOrCompositionExplicitlyCopied: false,
            wrapperOrCompositionRetainedOrCaptured: false,
            payloadAccessed: false,
            evidenceContextWrapperCompositionOrErrorReflected: false,
            evidenceContextWrapperCompositionOrErrorEncodedOrSerialized:
                false,
            evidenceContextWrapperCompositionOrErrorLoggedOrPublished: false,
            errorBoundInspectedOrReturned: false,
            timingOrResourceMeasured: false,
            retryFallbackOrSubstitutionPermitted: false,
            directV21ComposeProjectorDecoderOrExporterCallPermitted: false,
            dispositionEstablishesFixtureOriginOrAuthority: false,
            extensionSourceMaterialized: true,
            dispositionSourceMaterialized: true,
            boundaryMethodSourceMaterialized: true,
            rawSeamCallerMaterialized: true,
            discardConsumerMaterialized: true,
            callerOfNonpayloadBoundaryMaterialized: false,
            exactWorkerSourceCompilerFeasibilityObserved: true,
            reducedSwiftCanaryCompilerFeasibilityObserved: true,
            rawV23SeamRemainsInternal: true,
            v23PrivatePayloadOrInitializerAccessWidened: false,
            boundaryIsSoleCheckedInRawSeamCaller: true,
            otherRawSeamCallerMaterialized: false,
            sameModuleSourcesCanNameRawSeam: true,
            mainCanLexicallyNameRawSeam: true,
            mainCanLexicallyNameBoundary: true,
            ordinaryNonTestableOutsideModuleCanNameBoundary: false,
            testableOrPrivilegedImportMayNameInternalBoundary: true,
            sameModuleRawSeamBypassPrevented: false,
            testableRawSeamBypassPrevented: false,
            dynamicOrUnsafeBypassPrevented: false,
            genericReflectionMayExposePrivatePayload: true,
            confidentialityEstablished: false,
            zeroizationEstablished: false,
            constantTimeEstablished: false,
            constantResourceUseEstablished: false,
            trapsSignalsOrOutOfMemoryContained: false,
            hardRuntimeRequiresHardenedIsolation: true,
            mainReferencesOrCallsBoundary: false,
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
                "design_the_one_token_non_append_only_raw_v23_invocation_seam_access_rebinding_from_internal_to_private_while_preserving_the_v25_internal_nonpayload_boundary_as_the_sole_ordinary_source_level_callable_path_before_any_main_or_cross_file_call_edge_untrusted_request_transport_launch_runtime_confidentiality_artifact_io_publication_authority_or_source_binding_v7",
            authorityStatement: [
                "V25 preserves the exact V24 design and topology, V23 source contract and topology, and the complete 13,227-byte V23 worker source as a byte-for-byte prefix.",
                "It appends only the compiler-checked 948-byte same-file extension containing one internal two-case nonpayload disposition and one internal static synchronous nonthrowing caller and discard consumer.",
                "The boundary calls the raw V23 seam exactly once through Self with unchanged Evidence and context, discards the opaque wrapper without a binding or payload access, and maps every normally thrown Swift Error without detail to one failed-closed disposition.",
                "The raw V23 seam remains internal and nameable by same-module or privileged code; source scans do not establish binary-symbol absence, dynamic resistance, confidentiality, zeroization, constant-time or constant-resource behavior, crash secrecy, or trap, signal, and out-of-memory containment.",
                "No checked-in caller of the nonpayload boundary, main or cross-file call edge, request, transport, launch, runtime input or output, artifact I/O, execution, publication, mechanics PASS, receipt, source or execution binding V7, scientific authority, or product authority exists; Prime remains ABSTAIN.",
                "The next slice is design-only and must explicitly authorize the one-token non-append-only raw-seam access rebinding from internal to private. Hardened module or process isolation remains required before any untrusted request, launch, or runtime confidentiality claim.",
            ].joined(separator: " ")
        )
    }()

    public func validate() throws {
        guard self == .frozenV1 else {
            throw PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerSourceContractError
                .invalidFrozenContract
        }

        let design =
            PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerDesignContract
            .frozenV1
        let topology =
            PrimeNativeNeuralGateTrapDisjointTopologyContract.frozenV24
        let source =
            PrimeNativeNeuralGateHistoricalWorkerInvocationSeamSourceContract
            .frozenV1
        let designSHA256 = PrimeSHA256.hexDigest(
            of: try PrimeCanonicalJSON.encode(design)
        )
        let topologySHA256 = PrimeSHA256.hexDigest(
            of: try PrimeCanonicalJSON.encode(topology)
        )
        let sourceSHA256 = PrimeSHA256.hexDigest(
            of: try PrimeCanonicalJSON.encode(source)
        )
        let identities = [
            callerAndResultConsumerDesignContractSource,
            historicalV24DesignContractTestBeforeV25,
            currentV24DesignContractTestAfterV25,
            historicalTopologySourceBeforeV25,
            topologyV24Test,
            invocationSeamSourceV23ContractSource,
            historicalV23SourceContractTestBeforeV25,
            currentV23SourceContractTestAfterV25,
            callerAndResultConsumerSource,
            packageSwift,
            workerMain,
            workerEvidenceExportCallEdgeSource,
            workerProjectionCallEdgeSource,
            workerFixtureResource,
        ]

        guard identities.allSatisfy({ $0.validate() }),
              preservedCallerAndResultConsumerDesignV24ContractID
                == design.contractID,
              preservedCallerAndResultConsumerDesignV24ContractSHA256
                == designSHA256,
              preservedCallerAndResultConsumerDesignV24ContractSHA256
                == "3c9f34cfae3e50012e40a4b59e38eb5a90bc47e3906a1df5c5111978dac3c902",
              preservedTopologyV24ID == topology.contractID,
              preservedTopologyV24SHA256 == topologySHA256,
              preservedTopologyV24SHA256
                == "711f57d47575f7f166bee5f2b32708d3a86631406a3a3b96f370e1de1da8ce91",
              preservedInvocationSeamSourceV23ContractID
                == source.contractID,
              preservedInvocationSeamSourceV23ContractSHA256
                == sourceSHA256,
              preservedInvocationSeamSourceV23ContractSHA256
                == "6ae4cd1fadf95f3b18c38d7e4ec2d732f6e0b614399fb76334043bf9851bb656",
              preservedV23SourcePrefixByteCount
                + appendedV25SourceSuffixByteCount
                == callerAndResultConsumerSource.byteCount,
              exactV23PrefixPreserved,
              sourceEvolutionAppendOnly,
              historicalTestsEvolvedPrefixSafely,
              exactWorkerSwiftSourceFileCount == 4,
              orderedWorkerSwiftSourceRelativePaths.count == 4,
              exactWorkerDirectLocalDependencyCount == 7,
              workerDirectLocalDependencyNames.count == 7,
              exactWorkerResourceCount == 1,
              workerResourceRelativePaths.count == 1,
              physicalWorkerInventoryExact,
              exactImportNames.count == 4,
              !packageGraphChanged,
              !targetGraphChanged,
              !forbiddenReachabilityChanged,
              !workerSourceInventoryChanged,
              !workerDependenciesChanged,
              !workerResourcesChanged,
              !importInventoryChanged,
              exactAppendedExtensionCount == 1,
              dispositionDeclarationKind == "enum",
              dispositionAccessLevel == "internal",
              dispositionNestedInWrapper,
              dispositionExactCaseCount == 2,
              dispositionExactCaseNames.count == 2,
              dispositionAssociatedValueCount == 0,
              !dispositionHasRawType,
              dispositionDeclaredConformanceNames.isEmpty,
              dispositionAttributeNames.isEmpty,
              dispositionStoredFieldCount == 0,
              dispositionMethodCount == 0,
              dispositionGenericParameterCount == 0,
              dispositionImplicitSendable,
              dispositionOrdinarilyCopyable,
              !dispositionProvidesConfidentialityBoundary,
              !dispositionProvidesAuthorityBoundary,
              boundaryMethodAccessLevel == "internal",
              boundaryMethodStatic,
              !boundaryMethodAsync,
              !boundaryMethodThrows,
              exactBoundaryInputCount == 2,
              exactBoundaryInputLabels.count == 2,
              exactBoundaryInputSwiftTypeNames.count == 2,
              !boundaryInputMayBeOptional,
              !boundaryInputMayHaveDefault,
              !boundaryInputMayBeVariadicOrInout,
              boundaryMethodGenericParameterCount == 0,
              maintainedV23SeamAccessLevel == "internal",
              evidencePassedToV23SeamUnchanged,
              contextPassedToV23SeamUnchanged,
              v23SeamUsesExplicitSelfQualification,
              exactDoCount == 1,
              exactV23SeamCallCount == 1,
              exactTryCount == 1,
              exactBareCatchCount == 1,
              exactSuccessReturnCount == 1,
              exactFailureReturnCount == 1,
              successReturnOccursOnlyAfterSeamReturns,
              everyCaughtSwiftErrorMapsToFailedClosedWithoutDetail,
              !wrapperValueNamedOrBound,
              !wrapperOrCompositionReturned,
              !wrapperOrCompositionExplicitlyCopied,
              !wrapperOrCompositionRetainedOrCaptured,
              !payloadAccessed,
              !evidenceContextWrapperCompositionOrErrorReflected,
              !evidenceContextWrapperCompositionOrErrorEncodedOrSerialized,
              !evidenceContextWrapperCompositionOrErrorLoggedOrPublished,
              !errorBoundInspectedOrReturned,
              !timingOrResourceMeasured,
              !retryFallbackOrSubstitutionPermitted,
              !directV21ComposeProjectorDecoderOrExporterCallPermitted,
              !dispositionEstablishesFixtureOriginOrAuthority,
              extensionSourceMaterialized,
              dispositionSourceMaterialized,
              boundaryMethodSourceMaterialized,
              rawSeamCallerMaterialized,
              discardConsumerMaterialized,
              !callerOfNonpayloadBoundaryMaterialized,
              exactWorkerSourceCompilerFeasibilityObserved,
              reducedSwiftCanaryCompilerFeasibilityObserved,
              rawV23SeamRemainsInternal,
              !v23PrivatePayloadOrInitializerAccessWidened,
              boundaryIsSoleCheckedInRawSeamCaller,
              !otherRawSeamCallerMaterialized,
              sameModuleSourcesCanNameRawSeam,
              mainCanLexicallyNameRawSeam,
              mainCanLexicallyNameBoundary,
              !ordinaryNonTestableOutsideModuleCanNameBoundary,
              testableOrPrivilegedImportMayNameInternalBoundary,
              !sameModuleRawSeamBypassPrevented,
              !testableRawSeamBypassPrevented,
              !dynamicOrUnsafeBypassPrevented,
              genericReflectionMayExposePrivatePayload,
              !confidentialityEstablished,
              !zeroizationEstablished,
              !constantTimeEstablished,
              !constantResourceUseEstablished,
              !trapsSignalsOrOutOfMemoryContained,
              hardRuntimeRequiresHardenedIsolation,
              !mainReferencesOrCallsBoundary,
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
              authorityStatement.contains("Prime remains ABSTAIN"),
              authorityStatement.contains("Hardened module or process isolation")
        else {
            throw PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerSourceContractError
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
