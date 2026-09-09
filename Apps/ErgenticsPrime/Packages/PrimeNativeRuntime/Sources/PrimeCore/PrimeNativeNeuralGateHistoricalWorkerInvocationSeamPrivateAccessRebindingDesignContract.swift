// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

public enum
    PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingDesignContractError:
    Error,
    Equatable,
    Sendable
{
    case invalidFrozenContract
}

public struct
    PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingDesignSourceIdentity:
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

public struct
    PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingMutationGeometry:
    Codable,
    Equatable,
    Sendable
{
    public let mutationKind: String
    public let sourceRelativePath: String
    public let rawSeamEnclosingTypeName: String
    public let rawSeamMethodName: String
    public let currentNormalizedSignature: String
    public let projectedNormalizedSignature: String
    public let currentAccessLevel: String
    public let projectedAccessLevel: String
    public let accessTokenUTF8Offset: UInt64
    public let accessTokenRangeExclusiveUpperBound: UInt64
    public let currentAccessToken: String
    public let currentAccessTokenByteCount: UInt64
    public let currentAccessTokenSHA256: String
    public let projectedAccessToken: String
    public let projectedAccessTokenByteCount: UInt64
    public let projectedAccessTokenSHA256: String
    public let unchangedPrefixByteCount: UInt64
    public let unchangedPrefixSHA256: String
    public let unchangedSuffixByteCount: UInt64
    public let unchangedSuffixSHA256: String
    public let currentSourceByteCount: UInt64
    public let currentSourceSHA256: String
    public let projectedSourceByteCount: UInt64
    public let projectedSourceSHA256: String
    public let projectedPreV25SegmentByteCount: UInt64
    public let projectedPreV25SegmentSHA256: String
    public let unchangedV25SuffixByteCount: UInt64
    public let unchangedV25SuffixSHA256: String
    public let signedSourceByteCountDelta: Int64
    public let exactCurrentDeclarationMatchCount: Int
    public let exactPlannedReplacementCount: Int
    public let exactCurrentRawSeamExecutableCallerCount: Int
    public let exactProjectedRawSeamExecutableCallerCount: Int
    public let sourceEvolutionAppendOnly: Bool
    public let sourceEvolutionSingleNonAppendOnlyTokenReplacement: Bool
    public let anyOtherSourceByteMayChange: Bool
    public let commentsWhitespaceOrFormattingMayChange: Bool
    public let declarationNameSignatureBodyOrCallMayChange: Bool
    public let v25DispositionOrBoundarySourceMayChange: Bool

    fileprivate func validate() -> Bool {
        mutationKind
            == "single_utf8_access_control_token_replacement"
            && sourceRelativePath
                == "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactDecoderCallEdge.swift"
            && rawSeamEnclosingTypeName
                == "PrimeNativeNeuralGateHistoricalFixtureWorker.PrimeNativeNeuralGateHistoricalWorkerInvocationSeamResult"
            && rawSeamMethodName
                == "sourceBoundUnavailableHistoricalWorkerInvocationSeam"
            && currentAccessLevel == "internal"
            && projectedAccessLevel == "private"
            && currentAccessToken == currentAccessLevel
            && projectedAccessToken == projectedAccessLevel
            && currentAccessTokenByteCount
                == UInt64(currentAccessToken.utf8.count)
            && projectedAccessTokenByteCount
                == UInt64(projectedAccessToken.utf8.count)
            && accessTokenRangeExclusiveUpperBound
                == accessTokenUTF8Offset + currentAccessTokenByteCount
            && unchangedPrefixByteCount == accessTokenUTF8Offset
            && currentSourceByteCount
                == unchangedPrefixByteCount
                    + currentAccessTokenByteCount
                    + unchangedSuffixByteCount
            && projectedSourceByteCount
                == unchangedPrefixByteCount
                    + projectedAccessTokenByteCount
                    + unchangedSuffixByteCount
            && signedSourceByteCountDelta
                == Int64(projectedSourceByteCount)
                    - Int64(currentSourceByteCount)
            && projectedPreV25SegmentByteCount
                + unchangedV25SuffixByteCount
                == projectedSourceByteCount
            && exactCurrentDeclarationMatchCount == 1
            && exactPlannedReplacementCount == 1
            && exactCurrentRawSeamExecutableCallerCount == 1
            && exactProjectedRawSeamExecutableCallerCount == 1
            && !sourceEvolutionAppendOnly
            && sourceEvolutionSingleNonAppendOnlyTokenReplacement
            && !anyOtherSourceByteMayChange
            && !commentsWhitespaceOrFormattingMayChange
            && !declarationNameSignatureBodyOrCallMayChange
            && !v25DispositionOrBoundarySourceMayChange
            && [
                currentAccessTokenSHA256,
                projectedAccessTokenSHA256,
                unchangedPrefixSHA256,
                unchangedSuffixSHA256,
                currentSourceSHA256,
                projectedSourceSHA256,
                projectedPreV25SegmentSHA256,
                unchangedV25SuffixSHA256,
            ].allSatisfy {
                $0.utf8.count == 64
                    && $0 != String(repeating: "0", count: 64)
                    && $0.utf8.allSatisfy {
                        ($0 >= 48 && $0 <= 57)
                            || ($0 >= 97 && $0 <= 102)
                    }
            }
    }

    private enum CodingKeys: String, CodingKey {
        case mutationKind = "mutation_kind"
        case sourceRelativePath = "source_relative_path"
        case rawSeamEnclosingTypeName = "raw_seam_enclosing_type_name"
        case rawSeamMethodName = "raw_seam_method_name"
        case currentNormalizedSignature = "current_normalized_signature"
        case projectedNormalizedSignature = "projected_normalized_signature"
        case currentAccessLevel = "current_access_level"
        case projectedAccessLevel = "projected_access_level"
        case accessTokenUTF8Offset = "access_token_utf8_offset"
        case accessTokenRangeExclusiveUpperBound =
            "access_token_range_exclusive_upper_bound"
        case currentAccessToken = "current_access_token"
        case currentAccessTokenByteCount =
            "current_access_token_byte_count"
        case currentAccessTokenSHA256 = "current_access_token_sha256"
        case projectedAccessToken = "projected_access_token"
        case projectedAccessTokenByteCount =
            "projected_access_token_byte_count"
        case projectedAccessTokenSHA256 =
            "projected_access_token_sha256"
        case unchangedPrefixByteCount = "unchanged_prefix_byte_count"
        case unchangedPrefixSHA256 = "unchanged_prefix_sha256"
        case unchangedSuffixByteCount = "unchanged_suffix_byte_count"
        case unchangedSuffixSHA256 = "unchanged_suffix_sha256"
        case currentSourceByteCount = "current_source_byte_count"
        case currentSourceSHA256 = "current_source_sha256"
        case projectedSourceByteCount = "projected_source_byte_count"
        case projectedSourceSHA256 = "projected_source_sha256"
        case projectedPreV25SegmentByteCount =
            "projected_pre_v25_segment_byte_count"
        case projectedPreV25SegmentSHA256 =
            "projected_pre_v25_segment_sha256"
        case unchangedV25SuffixByteCount =
            "unchanged_v25_suffix_byte_count"
        case unchangedV25SuffixSHA256 = "unchanged_v25_suffix_sha256"
        case signedSourceByteCountDelta =
            "signed_source_byte_count_delta"
        case exactCurrentDeclarationMatchCount =
            "exact_current_declaration_match_count"
        case exactPlannedReplacementCount =
            "exact_planned_replacement_count"
        case exactCurrentRawSeamExecutableCallerCount =
            "exact_current_raw_seam_executable_caller_count"
        case exactProjectedRawSeamExecutableCallerCount =
            "exact_projected_raw_seam_executable_caller_count"
        case sourceEvolutionAppendOnly = "source_evolution_append_only"
        case sourceEvolutionSingleNonAppendOnlyTokenReplacement =
            "source_evolution_single_non_append_only_token_replacement"
        case anyOtherSourceByteMayChange =
            "any_other_source_byte_may_change"
        case commentsWhitespaceOrFormattingMayChange =
            "comments_whitespace_or_formatting_may_change"
        case declarationNameSignatureBodyOrCallMayChange =
            "declaration_name_signature_body_or_call_may_change"
        case v25DispositionOrBoundarySourceMayChange =
            "v25_disposition_or_boundary_source_may_change"
    }
}

public struct
    PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingAccessMatrix:
    Codable,
    Equatable,
    Sendable
{
    public let projectedRawSeamPrivate: Bool
    public let
        sameFileExtensionOfRawSeamDeclaringNestedTypeCanNameRawSeam:
        Bool
    public let otherWorkerSourceFileCanNameRawSeam: Bool
    public let mainCanNameRawSeam: Bool
    public let testableImportCanNameRawSeam: Bool
    public let ordinaryOutsideModuleCanNameRawSeam: Bool
    public let v25NonpayloadBoundaryRemainsInternal: Bool
    public let sameModuleSourceCanNameV25Boundary: Bool
    public let mainCanNameV25Boundary: Bool
    public let testableImportCanNameV25Boundary: Bool
    public let v25BoundaryRemainsSoleCheckedInRawSeamCaller: Bool
    public let
        futureSameFileExtensionOfRawSeamDeclaringNestedTypeCanAddRawSeamCaller:
        Bool
    public let ordinarySwiftCrossFileDirectRawSeamNameabilityPrevented:
        Bool
    public let dynamicDebuggerInjectedOrUnsafeBypassPrevented: Bool
    public let binarySymbolOrTypeMetadataAbsenceEstablished: Bool
    public let genericReflectionMayExposePrivatePayloadAfterWrapperPossession:
        Bool
    public let
        returnedVersusThrewDispositionWouldBeObservableToAnyBoundaryCaller:
        Bool
    public let rawErrorDetailSuppressionUniversal: Bool
    public let
        underscoredPrivateImportDebuggerOrCompilerPrivilegePrevented:
        Bool
    public let timingResourceOrCrashObservationContained: Bool
    public let authenticatedCallerPolicyEstablished: Bool
    public let confidentialityEstablished: Bool
    public let zeroizationEstablished: Bool
    public let constantTimeEstablished: Bool
    public let constantResourceUseEstablished: Bool
    public let trapsSignalsOrOutOfMemoryContained: Bool
    public let hardenedIsolationRequiredBeforeUntrustedRuntime: Bool

    fileprivate func validate() -> Bool {
        projectedRawSeamPrivate
            && sameFileExtensionOfRawSeamDeclaringNestedTypeCanNameRawSeam
            && !otherWorkerSourceFileCanNameRawSeam
            && !mainCanNameRawSeam
            && !testableImportCanNameRawSeam
            && !ordinaryOutsideModuleCanNameRawSeam
            && v25NonpayloadBoundaryRemainsInternal
            && sameModuleSourceCanNameV25Boundary
            && mainCanNameV25Boundary
            && testableImportCanNameV25Boundary
            && v25BoundaryRemainsSoleCheckedInRawSeamCaller
            && futureSameFileExtensionOfRawSeamDeclaringNestedTypeCanAddRawSeamCaller
            && ordinarySwiftCrossFileDirectRawSeamNameabilityPrevented
            && !dynamicDebuggerInjectedOrUnsafeBypassPrevented
            && !binarySymbolOrTypeMetadataAbsenceEstablished
            && genericReflectionMayExposePrivatePayloadAfterWrapperPossession
            && returnedVersusThrewDispositionWouldBeObservableToAnyBoundaryCaller
            && !rawErrorDetailSuppressionUniversal
            && !underscoredPrivateImportDebuggerOrCompilerPrivilegePrevented
            && !timingResourceOrCrashObservationContained
            && !authenticatedCallerPolicyEstablished
            && !confidentialityEstablished
            && !zeroizationEstablished
            && !constantTimeEstablished
            && !constantResourceUseEstablished
            && !trapsSignalsOrOutOfMemoryContained
            && hardenedIsolationRequiredBeforeUntrustedRuntime
    }

    private enum CodingKeys: String, CodingKey {
        case projectedRawSeamPrivate = "projected_raw_seam_private"
        case
            sameFileExtensionOfRawSeamDeclaringNestedTypeCanNameRawSeam =
            "same_file_extension_of_raw_seam_declaring_nested_type_can_name_raw_seam"
        case otherWorkerSourceFileCanNameRawSeam =
            "other_worker_source_file_can_name_raw_seam"
        case mainCanNameRawSeam = "main_can_name_raw_seam"
        case testableImportCanNameRawSeam =
            "testable_import_can_name_raw_seam"
        case ordinaryOutsideModuleCanNameRawSeam =
            "ordinary_outside_module_can_name_raw_seam"
        case v25NonpayloadBoundaryRemainsInternal =
            "v25_nonpayload_boundary_remains_internal"
        case sameModuleSourceCanNameV25Boundary =
            "same_module_source_can_name_v25_boundary"
        case mainCanNameV25Boundary = "main_can_name_v25_boundary"
        case testableImportCanNameV25Boundary =
            "testable_import_can_name_v25_boundary"
        case v25BoundaryRemainsSoleCheckedInRawSeamCaller =
            "v25_boundary_remains_sole_checked_in_raw_seam_caller"
        case
            futureSameFileExtensionOfRawSeamDeclaringNestedTypeCanAddRawSeamCaller =
            "future_same_file_extension_of_raw_seam_declaring_nested_type_can_add_raw_seam_caller"
        case ordinarySwiftCrossFileDirectRawSeamNameabilityPrevented =
            "ordinary_swift_cross_file_direct_raw_seam_nameability_prevented"
        case dynamicDebuggerInjectedOrUnsafeBypassPrevented =
            "dynamic_debugger_injected_or_unsafe_bypass_prevented"
        case binarySymbolOrTypeMetadataAbsenceEstablished =
            "binary_symbol_or_type_metadata_absence_established"
        case
            genericReflectionMayExposePrivatePayloadAfterWrapperPossession =
            "generic_reflection_may_expose_private_payload_after_wrapper_possession"
        case
            returnedVersusThrewDispositionWouldBeObservableToAnyBoundaryCaller =
            "returned_versus_threw_disposition_would_be_observable_to_any_boundary_caller"
        case rawErrorDetailSuppressionUniversal =
            "raw_error_detail_suppression_universal"
        case
            underscoredPrivateImportDebuggerOrCompilerPrivilegePrevented =
            "underscored_private_import_debugger_or_compiler_privilege_prevented"
        case timingResourceOrCrashObservationContained =
            "timing_resource_or_crash_observation_contained"
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
    }
}

/// Frozen V26 security design for the one-token private-access rebinding
/// reserved for V27.
///
/// V26 changes no worker source. It binds the exact V25 source and the only
/// future byte range authorized to change, plus the narrower lexical-access
/// claims and the security properties that remain unproven.
public struct
    PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingDesignContract:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let contractID: String
    public let rightsHolder: String
    public let licenseExpression: String

    public let preservedCallerAndResultConsumerSourceV25ContractID: String
    public let preservedCallerAndResultConsumerSourceV25ContractSHA256:
        String
    public let preservedTopologyV25ID: String
    public let preservedTopologyV25SHA256: String
    public let callerAndResultConsumerSourceContractSource:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingDesignSourceIdentity
    public let callerAndResultConsumerSourceContractTest:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingDesignSourceIdentity
    public let historicalTopologySourceBeforeV26:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingDesignSourceIdentity
    public let topologyV25Test:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingDesignSourceIdentity
    public let packageSwift:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingDesignSourceIdentity
    public let workerMain:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingDesignSourceIdentity
    public let workerEvidenceExportCallEdgeSource:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingDesignSourceIdentity
    public let workerProjectionCallEdgeSource:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingDesignSourceIdentity
    public let workerInvocationSeamAndBoundarySourceV25:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingDesignSourceIdentity
    public let workerFixtureResource:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingDesignSourceIdentity

    public let workerTargetName: String
    public let orderedCurrentWorkerSwiftSourceRelativePaths: [String]
    public let exactCurrentWorkerSwiftSourceFileCount: Int
    public let workerDirectLocalDependencyNames: [String]
    public let exactWorkerDirectLocalDependencyCount: Int
    public let workerResourceRelativePaths: [String]
    public let exactWorkerResourceCount: Int
    public let exactInvocationSourceImportNames: [String]
    public let currentPhysicalWorkerInventoryExact: Bool
    public let packageGraphMayChange: Bool
    public let targetGraphMayChange: Bool
    public let forbiddenReachabilityMayChange: Bool
    public let workerSourceInventoryMayChange: Bool
    public let workerDependenciesMayChange: Bool
    public let workerResourcesMayChange: Bool
    public let importInventoryMayChange: Bool

    public let mutation:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingMutationGeometry
    public let accessMatrix:
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingAccessMatrix

    public let preservedBoundaryMethodName: String
    public let preservedBoundaryNormalizedSignature: String
    public let preservedBoundaryNormalizedBody: String
    public let preservedBoundaryAccessLevel: String
    public let preservedDispositionTypeName: String
    public let preservedDispositionCaseNames: [String]
    public let evidencePassedToRawSeamUnchanged: Bool
    public let contextPassedToRawSeamUnchanged: Bool
    public let opaqueWrapperStillDiscardedWithoutBinding: Bool
    public let everySwiftErrorCaughtByV25BoundaryStillMapsWithoutDetail:
        Bool
    public let v25PrivatePayloadOrInitializerAccessWidened: Bool

    public let designOnly: Bool
    public let checkedInWorkerSourceChangedByV26: Bool
    public let futureSourceContractMaterialized: Bool
    public let projectedWorkerSourceCheckedIn: Bool
    public let projectedExactWorkerFrontendTypecheckObserved: Bool
    public let reducedSameFilePrivateExtensionCanaryObserved: Bool
    public let negativeCrossFilePrivateAccessCompilerCanaryObserved: Bool
    public let mainReferencesOrCallsV25Boundary: Bool
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
    public let
        v27MustPreserveV23ThroughV26CanonicalContractsAndTopologiesAsHistory:
        Bool
    public let
        v27MustEvolveV23ThroughV26HistoricalTestsWithoutRewritingHistory:
        Bool
    public let nextImplementationPrerequisite: String
    public let authorityStatement: String

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case contractID = "contract_id"
        case rightsHolder = "rights_holder"
        case licenseExpression = "license_expression"
        case preservedCallerAndResultConsumerSourceV25ContractID =
            "preserved_caller_and_result_consumer_source_v25_contract_id"
        case preservedCallerAndResultConsumerSourceV25ContractSHA256 =
            "preserved_caller_and_result_consumer_source_v25_contract_sha256"
        case preservedTopologyV25ID = "preserved_topology_v25_id"
        case preservedTopologyV25SHA256 = "preserved_topology_v25_sha256"
        case callerAndResultConsumerSourceContractSource =
            "caller_and_result_consumer_source_contract_source"
        case callerAndResultConsumerSourceContractTest =
            "caller_and_result_consumer_source_contract_test"
        case historicalTopologySourceBeforeV26 =
            "historical_topology_source_before_v26"
        case topologyV25Test = "topology_v25_test"
        case packageSwift = "package_swift"
        case workerMain = "worker_main"
        case workerEvidenceExportCallEdgeSource =
            "worker_evidence_export_call_edge_source"
        case workerProjectionCallEdgeSource =
            "worker_projection_call_edge_source"
        case workerInvocationSeamAndBoundarySourceV25 =
            "worker_invocation_seam_and_boundary_source_v25"
        case workerFixtureResource = "worker_fixture_resource"
        case workerTargetName = "worker_target_name"
        case orderedCurrentWorkerSwiftSourceRelativePaths =
            "ordered_current_worker_swift_source_relative_paths"
        case exactCurrentWorkerSwiftSourceFileCount =
            "exact_current_worker_swift_source_file_count"
        case workerDirectLocalDependencyNames =
            "worker_direct_local_dependency_names"
        case exactWorkerDirectLocalDependencyCount =
            "exact_worker_direct_local_dependency_count"
        case workerResourceRelativePaths = "worker_resource_relative_paths"
        case exactWorkerResourceCount = "exact_worker_resource_count"
        case exactInvocationSourceImportNames =
            "exact_invocation_source_import_names"
        case currentPhysicalWorkerInventoryExact =
            "current_physical_worker_inventory_exact"
        case packageGraphMayChange = "package_graph_may_change"
        case targetGraphMayChange = "target_graph_may_change"
        case forbiddenReachabilityMayChange =
            "forbidden_reachability_may_change"
        case workerSourceInventoryMayChange =
            "worker_source_inventory_may_change"
        case workerDependenciesMayChange = "worker_dependencies_may_change"
        case workerResourcesMayChange = "worker_resources_may_change"
        case importInventoryMayChange = "import_inventory_may_change"
        case mutation
        case accessMatrix = "access_matrix"
        case preservedBoundaryMethodName =
            "preserved_boundary_method_name"
        case preservedBoundaryNormalizedSignature =
            "preserved_boundary_normalized_signature"
        case preservedBoundaryNormalizedBody =
            "preserved_boundary_normalized_body"
        case preservedBoundaryAccessLevel =
            "preserved_boundary_access_level"
        case preservedDispositionTypeName =
            "preserved_disposition_type_name"
        case preservedDispositionCaseNames =
            "preserved_disposition_case_names"
        case evidencePassedToRawSeamUnchanged =
            "evidence_passed_to_raw_seam_unchanged"
        case contextPassedToRawSeamUnchanged =
            "context_passed_to_raw_seam_unchanged"
        case opaqueWrapperStillDiscardedWithoutBinding =
            "opaque_wrapper_still_discarded_without_binding"
        case everySwiftErrorCaughtByV25BoundaryStillMapsWithoutDetail =
            "every_swift_error_caught_by_v25_boundary_still_maps_without_detail"
        case v25PrivatePayloadOrInitializerAccessWidened =
            "v25_private_payload_or_initializer_access_widened"
        case designOnly = "design_only"
        case checkedInWorkerSourceChangedByV26 =
            "checked_in_worker_source_changed_by_v26"
        case futureSourceContractMaterialized =
            "future_source_contract_materialized"
        case projectedWorkerSourceCheckedIn =
            "projected_worker_source_checked_in"
        case projectedExactWorkerFrontendTypecheckObserved =
            "projected_exact_worker_frontend_typecheck_observed"
        case reducedSameFilePrivateExtensionCanaryObserved =
            "reduced_same_file_private_extension_canary_observed"
        case negativeCrossFilePrivateAccessCompilerCanaryObserved =
            "negative_cross_file_private_access_compiler_canary_observed"
        case mainReferencesOrCallsV25Boundary =
            "main_references_or_calls_v25_boundary"
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
        case durablePublicationObserved = "durable_publication_observed"
        case mechanicsPassAuthorized = "mechanics_pass_authorized"
        case terminalReceiptAuthorized = "terminal_receipt_authorized"
        case sourceBindingV7Issued = "source_binding_v7_issued"
        case scientificAuthorityAuthorized =
            "scientific_authority_authorized"
        case productAuthorityAuthorized = "product_authority_authorized"
        case primeDisposition = "prime_disposition"
        case
            v27MustPreserveV23ThroughV26CanonicalContractsAndTopologiesAsHistory =
            "v27_must_preserve_v23_through_v26_canonical_contracts_and_topologies_as_history"
        case
            v27MustEvolveV23ThroughV26HistoricalTestsWithoutRewritingHistory =
            "v27_must_evolve_v23_through_v26_historical_tests_without_rewriting_history"
        case nextImplementationPrerequisite =
            "next_implementation_prerequisite"
        case authorityStatement = "authority_statement"
    }

    public static let frozenV1: Self = {
        let worker =
            "PrimeNativeNeuralGateHistoricalFixtureWorker"
        let workerDirectory = "Sources/\(worker)/"
        let invocationSourcePath = workerDirectory
            + "PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactDecoderCallEdge.swift"
        let wrapper = worker
            + ".PrimeNativeNeuralGateHistoricalWorkerInvocationSeamResult"
        let rawSeam =
            "sourceBoundUnavailableHistoricalWorkerInvocationSeam"
        let boundary =
            "sourceBoundUnavailableHistoricalWorkerInvocationSeamCallerAndDiscardConsumer"

        return Self(
            schemaVersion: 1,
            contractID:
                "prime_source_bound_historical_worker_bounded_unavailable_composition_invocation_seam_private_access_rebinding_security_design_v26",
            rightsHolder: "Ergentics, LLC",
            licenseExpression: "LicenseRef-Ergentics-Proprietary",
            preservedCallerAndResultConsumerSourceV25ContractID:
                "prime_source_bound_historical_worker_bounded_unavailable_composition_invocation_seam_caller_result_consumer_v25",
            preservedCallerAndResultConsumerSourceV25ContractSHA256:
                "21f5a3805c6a5404072caa79d4c6c3463556c4a780d215e03fe570cd26d5a9d5",
            preservedTopologyV25ID:
                "prime_stage_b_historical_worker_bounded_unavailable_composition_invocation_seam_caller_result_consumer_source_topology_v25",
            preservedTopologyV25SHA256:
                "a5907c0d1505c004a4fbd67193d2b1f7f640cd8c8906fdd94cdbed6eab667ba3",
            callerAndResultConsumerSourceContractSource: .init(
                primeRelativePath:
                    "Sources/PrimeCore/PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerSourceContract.swift",
                byteCount: 55_872,
                sha256:
                    "85d21774ddf080d80a68066628b248ed801d53e5d68dae7ce2f54b4a446abddb"
            ),
            callerAndResultConsumerSourceContractTest: .init(
                primeRelativePath:
                    "Tests/PrimeCoreTests/PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerSourceContractTests.swift",
                byteCount: 33_946,
                sha256:
                    "f0d754eee4f1030bc3f28e21d90d1f3e55298293d4f25d8d2614c4a0b0f9b1d7"
            ),
            historicalTopologySourceBeforeV26: .init(
                primeRelativePath:
                    "Sources/PrimeCore/PrimeNativeNeuralGateTrapDisjointTopology.swift",
                byteCount: 261_012,
                sha256:
                    "d613057c800ca5bfeef57d5142d03bb94b9d41a9a7dc4a17100dce8eb4d98195"
            ),
            topologyV25Test: .init(
                primeRelativePath:
                    "Tests/PrimeCoreTests/PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerSourceTopologyV25Tests.swift",
                byteCount: 26_530,
                sha256:
                    "575b82b77d7324368a3c6505d3ef7b4bcdae96811b82e282c8bf2a2425690e7d"
            ),
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
            workerInvocationSeamAndBoundarySourceV25: .init(
                primeRelativePath: invocationSourcePath,
                byteCount: 14_175,
                sha256:
                    "bac6238644345afea2fb3404a0e073885d232380c31d3f4ce02f53936abe47a8"
            ),
            workerFixtureResource: .init(
                primeRelativePath: workerDirectory
                    + "HistoricalFixtureEvidence/Package.resolved",
                byteCount: 1_949,
                sha256:
                    "cf1ba313dcb0c959e80ba09d6cbe0c56bcd921523bda5cec2c682c8ae7696ab3"
            ),
            workerTargetName: worker,
            orderedCurrentWorkerSwiftSourceRelativePaths: [
                workerDirectory
                    + "PrimeNativeNeuralGateHistoricalEvidenceExportCallEdge.swift",
                workerDirectory
                    + "PrimeNativeNeuralGateHistoricalFixtureWorker.swift",
                invocationSourcePath,
                workerDirectory
                    + "PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactProjectionCallEdge.swift",
            ],
            exactCurrentWorkerSwiftSourceFileCount: 4,
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
            currentPhysicalWorkerInventoryExact: true,
            packageGraphMayChange: false,
            targetGraphMayChange: false,
            forbiddenReachabilityMayChange: false,
            workerSourceInventoryMayChange: false,
            workerDependenciesMayChange: false,
            workerResourcesMayChange: false,
            importInventoryMayChange: false,
            mutation: .init(
                mutationKind:
                    "single_utf8_access_control_token_replacement",
                sourceRelativePath: invocationSourcePath,
                rawSeamEnclosingTypeName: wrapper,
                rawSeamMethodName: rawSeam,
                currentNormalizedSignature:
                    "internal static func sourceBoundUnavailableHistoricalWorkerInvocationSeam(evidence: PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence, context: PrimeNativeNeuralGateHistoricalProjectionContext) throws -> Self",
                projectedNormalizedSignature:
                    "private static func sourceBoundUnavailableHistoricalWorkerInvocationSeam(evidence: PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence, context: PrimeNativeNeuralGateHistoricalProjectionContext) throws -> Self",
                currentAccessLevel: "internal",
                projectedAccessLevel: "private",
                accessTokenUTF8Offset: 12_555,
                accessTokenRangeExclusiveUpperBound: 12_563,
                currentAccessToken: "internal",
                currentAccessTokenByteCount: 8,
                currentAccessTokenSHA256:
                    "3bed2cb3a3acf7b6a8ef408420cc682d5520e26976d354254f528c965612054f",
                projectedAccessToken: "private",
                projectedAccessTokenByteCount: 7,
                projectedAccessTokenSHA256:
                    "715dc8493c36579a5b116995100f635e3572fdf8703e708ef1a08d943b36774e",
                unchangedPrefixByteCount: 12_555,
                unchangedPrefixSHA256:
                    "4a2a86438cb47eb1026d4492791b500f40814af91a59380bbb8ce54df8f0a59d",
                unchangedSuffixByteCount: 1_612,
                unchangedSuffixSHA256:
                    "db1118db558590f644eef151677d12f447a8ec6e8055098365a86da60f93a239",
                currentSourceByteCount: 14_175,
                currentSourceSHA256:
                    "bac6238644345afea2fb3404a0e073885d232380c31d3f4ce02f53936abe47a8",
                projectedSourceByteCount: 14_174,
                projectedSourceSHA256:
                    "767cc0101c52a311d40acc1dbba1747b7e3cdf7430f73d69a168ab62d1290e15",
                projectedPreV25SegmentByteCount: 13_226,
                projectedPreV25SegmentSHA256:
                    "1e2f3119d903c6819ebf916da1d5f3006d4bed0636a834a3caaaf9d31e519480",
                unchangedV25SuffixByteCount: 948,
                unchangedV25SuffixSHA256:
                    "ed9c1527b23190fb8c8e3d2ce2144929cf8e6d551d3b6a3c4dad6f4b9e08f626",
                signedSourceByteCountDelta: -1,
                exactCurrentDeclarationMatchCount: 1,
                exactPlannedReplacementCount: 1,
                exactCurrentRawSeamExecutableCallerCount: 1,
                exactProjectedRawSeamExecutableCallerCount: 1,
                sourceEvolutionAppendOnly: false,
                sourceEvolutionSingleNonAppendOnlyTokenReplacement: true,
                anyOtherSourceByteMayChange: false,
                commentsWhitespaceOrFormattingMayChange: false,
                declarationNameSignatureBodyOrCallMayChange: false,
                v25DispositionOrBoundarySourceMayChange: false
            ),
            accessMatrix: .init(
                projectedRawSeamPrivate: true,
                sameFileExtensionOfRawSeamDeclaringNestedTypeCanNameRawSeam:
                    true,
                otherWorkerSourceFileCanNameRawSeam: false,
                mainCanNameRawSeam: false,
                testableImportCanNameRawSeam: false,
                ordinaryOutsideModuleCanNameRawSeam: false,
                v25NonpayloadBoundaryRemainsInternal: true,
                sameModuleSourceCanNameV25Boundary: true,
                mainCanNameV25Boundary: true,
                testableImportCanNameV25Boundary: true,
                v25BoundaryRemainsSoleCheckedInRawSeamCaller: true,
                futureSameFileExtensionOfRawSeamDeclaringNestedTypeCanAddRawSeamCaller:
                    true,
                ordinarySwiftCrossFileDirectRawSeamNameabilityPrevented:
                    true,
                dynamicDebuggerInjectedOrUnsafeBypassPrevented: false,
                binarySymbolOrTypeMetadataAbsenceEstablished: false,
                genericReflectionMayExposePrivatePayloadAfterWrapperPossession:
                    true,
                returnedVersusThrewDispositionWouldBeObservableToAnyBoundaryCaller:
                    true,
                rawErrorDetailSuppressionUniversal: false,
                underscoredPrivateImportDebuggerOrCompilerPrivilegePrevented:
                    false,
                timingResourceOrCrashObservationContained: false,
                authenticatedCallerPolicyEstablished: false,
                confidentialityEstablished: false,
                zeroizationEstablished: false,
                constantTimeEstablished: false,
                constantResourceUseEstablished: false,
                trapsSignalsOrOutOfMemoryContained: false,
                hardenedIsolationRequiredBeforeUntrustedRuntime: true
            ),
            preservedBoundaryMethodName: boundary,
            preservedBoundaryNormalizedSignature:
                "internal static func sourceBoundUnavailableHistoricalWorkerInvocationSeamCallerAndDiscardConsumer(evidence: PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence, context: PrimeNativeNeuralGateHistoricalProjectionContext) -> CallerResultConsumerDisposition",
            preservedBoundaryNormalizedBody:
                "do{_=trySelf.sourceBoundUnavailableHistoricalWorkerInvocationSeam(evidence:evidence,context:context)return.compositionCompletedAndDiscarded}catch{return.failedClosedWithoutDetail}",
            preservedBoundaryAccessLevel: "internal",
            preservedDispositionTypeName:
                "CallerResultConsumerDisposition",
            preservedDispositionCaseNames: [
                "compositionCompletedAndDiscarded",
                "failedClosedWithoutDetail",
            ],
            evidencePassedToRawSeamUnchanged: true,
            contextPassedToRawSeamUnchanged: true,
            opaqueWrapperStillDiscardedWithoutBinding: true,
            everySwiftErrorCaughtByV25BoundaryStillMapsWithoutDetail:
                true,
            v25PrivatePayloadOrInitializerAccessWidened: false,
            designOnly: true,
            checkedInWorkerSourceChangedByV26: false,
            futureSourceContractMaterialized: false,
            projectedWorkerSourceCheckedIn: false,
            projectedExactWorkerFrontendTypecheckObserved: true,
            reducedSameFilePrivateExtensionCanaryObserved: true,
            negativeCrossFilePrivateAccessCompilerCanaryObserved: true,
            mainReferencesOrCallsV25Boundary: false,
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
            v27MustPreserveV23ThroughV26CanonicalContractsAndTopologiesAsHistory:
                true,
            v27MustEvolveV23ThroughV26HistoricalTestsWithoutRewritingHistory:
                true,
            nextImplementationPrerequisite:
                "source_bind_the_one_token_non_append_only_raw_v23_invocation_seam_access_rebinding_from_internal_to_private_while_preserving_every_other_v25_worker_source_byte_the_v25_internal_nonpayload_boundary_as_the_sole_checked_in_raw_seam_caller_and_the_four_file_worker_inventory_without_any_main_cross_file_caller_request_transport_launch_runtime_confidentiality_artifact_io_publication_authority_or_source_binding_v7",
            authorityStatement: [
                "V26 preserves the exact V25 source contract, topology, 14,175-byte worker source, Package.swift, status-78 main, four-file worker inventory, dependencies, resource, imports, forbidden reachability, and every V1 through V25 canonical identity; it materializes design only.",
                "The only future source mutation authorized for V27 replaces the eight UTF-8 bytes internal in the half-open zero-based range 12,555..<12,563 with the seven UTF-8 bytes private in the raw invocation-seam declaration. Every prefix, suffix, declaration name, signature, body, call, disposition, boundary, comment, whitespace byte, import, package edge, worker target-graph edge, and forbidden-reachability edge remains exact.",
                "A derived in-memory projection of that one-token source passed exact worker-source frontend typechecking against the existing Release-built dependency modules and generated resource accessor, a same-file extension canary passed, and a two-physical-file access canary was rejected; this was not a clean Release product build and the projected source is not checked in, launched, or executed.",
                "After V27, ordinary Swift code in other files, main, and testable imports cannot directly name the private raw seam. This closes that direct lexical wrapper-and-raw-error path only: the unchanged internal V25 boundary remains same-module and privileged-callable and remains the sole checked-in raw-seam caller, while a future same-file extension of the raw seam's declaring nested type could still add another caller.",
                "If a caller later invokes the internal V25 boundary with caller-chosen Evidence and context, returned versus threw plus timing, resource, and crash behavior remains observable; only Swift Errors caught by that boundary lose detail, while another same-file, dynamic, debugger, injected, unsafe, or compiler-privileged route can bypass that mapping. No caller, role, source, artifact lineage, or input origin is authenticated.",
                "The access narrowing does not hide binary symbols or metadata, prevent underscored private-source imports or other debugger/compiler privilege, make private payload reflection impossible after wrapper possession, contain trap, signal, or out-of-memory observation, establish confidentiality or zeroization, or create constant-time or constant-resource behavior.",
                "No worker-source change, source contract, main or cross-file caller, request, transport, sealing, launch, execution, runtime input or output, artifact I/O, publication, mechanics PASS, receipt, V7, scientific authority, or product authority is materialized, observed, or authorized; Prime remains ABSTAIN.",
            ].joined(separator: " ")
        )
    }()

    public func validate() throws {
        guard self == .frozenV1 else {
            throw PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingDesignContractError
                .invalidFrozenContract
        }

        let source =
            PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerSourceContract
            .frozenV1
        let topology =
            PrimeNativeNeuralGateTrapDisjointTopologyContract.frozenV25
        let sourceSHA256 = PrimeSHA256.hexDigest(
            of: try PrimeCanonicalJSON.encode(source)
        )
        let topologySHA256 = PrimeSHA256.hexDigest(
            of: try PrimeCanonicalJSON.encode(topology)
        )
        let identities = [
            callerAndResultConsumerSourceContractSource,
            callerAndResultConsumerSourceContractTest,
            historicalTopologySourceBeforeV26,
            topologyV25Test,
            packageSwift,
            workerMain,
            workerEvidenceExportCallEdgeSource,
            workerProjectionCallEdgeSource,
            workerInvocationSeamAndBoundarySourceV25,
            workerFixtureResource,
        ]

        guard identities.allSatisfy({ $0.validate() }),
              mutation.validate(),
              accessMatrix.validate(),
              preservedCallerAndResultConsumerSourceV25ContractID
                == source.contractID,
              preservedCallerAndResultConsumerSourceV25ContractSHA256
                == sourceSHA256,
              preservedCallerAndResultConsumerSourceV25ContractSHA256
                == "21f5a3805c6a5404072caa79d4c6c3463556c4a780d215e03fe570cd26d5a9d5",
              preservedTopologyV25ID == topology.contractID,
              preservedTopologyV25SHA256 == topologySHA256,
              preservedTopologyV25SHA256
                == "a5907c0d1505c004a4fbd67193d2b1f7f640cd8c8906fdd94cdbed6eab667ba3",
              mutation.currentSourceByteCount
                == workerInvocationSeamAndBoundarySourceV25.byteCount,
              mutation.currentSourceSHA256
                == workerInvocationSeamAndBoundarySourceV25.sha256,
              exactCurrentWorkerSwiftSourceFileCount
                == orderedCurrentWorkerSwiftSourceRelativePaths.count,
              exactWorkerDirectLocalDependencyCount
                == workerDirectLocalDependencyNames.count,
              exactWorkerResourceCount
                == workerResourceRelativePaths.count,
              currentPhysicalWorkerInventoryExact,
              !packageGraphMayChange,
              !targetGraphMayChange,
              !forbiddenReachabilityMayChange,
              !workerSourceInventoryMayChange,
              !workerDependenciesMayChange,
              !workerResourcesMayChange,
              !importInventoryMayChange,
              preservedBoundaryAccessLevel == "internal",
              preservedDispositionCaseNames == [
                  "compositionCompletedAndDiscarded",
                  "failedClosedWithoutDetail",
              ],
              evidencePassedToRawSeamUnchanged,
              contextPassedToRawSeamUnchanged,
              opaqueWrapperStillDiscardedWithoutBinding,
              everySwiftErrorCaughtByV25BoundaryStillMapsWithoutDetail,
              !v25PrivatePayloadOrInitializerAccessWidened,
              designOnly,
              !checkedInWorkerSourceChangedByV26,
              !futureSourceContractMaterialized,
              !projectedWorkerSourceCheckedIn,
              projectedExactWorkerFrontendTypecheckObserved,
              reducedSameFilePrivateExtensionCanaryObserved,
              negativeCrossFilePrivateAccessCompilerCanaryObserved,
              !mainReferencesOrCallsV25Boundary,
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
              v27MustPreserveV23ThroughV26CanonicalContractsAndTopologiesAsHistory,
              v27MustEvolveV23ThroughV26HistoricalTestsWithoutRewritingHistory,
              !nextImplementationPrerequisite.isEmpty,
              !authorityStatement.isEmpty
        else {
            throw PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingDesignContractError
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
