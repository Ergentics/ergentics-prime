// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

public enum
    PrimeNativeNeuralGateHistoricalWorkerExportedEvidenceProjectionDecodeCompositionCallEdgeSourceContractError:
    Error,
    Equatable,
    Sendable
{
    case invalidFrozenContract
}

public struct
    PrimeNativeNeuralGateHistoricalCompositionSourceIdentity:
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

/// Frozen V21 source boundary for the unavailable historical worker's private
/// exported-evidence projection/decode composition call edge.
///
/// V21 preserves the exact 7,050-byte V19 decoder-edge prefix and appends the
/// V20-designed result and two private static methods in that same file. The
/// append compiles but remains lexically unreachable from the status-78 main.
/// It changes no package declaration, target, dependency, product, resource,
/// transport edge, request handler, runtime-reachable execution path or entry
/// point, or authority boundary.
public struct
    PrimeNativeNeuralGateHistoricalWorkerExportedEvidenceProjectionDecodeCompositionCallEdgeSourceContract:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let contractID: String
    public let rightsHolder: String
    public let licenseExpression: String

    public let preservedCompositionDesignV20ContractID: String
    public let preservedCompositionDesignV20ContractSHA256: String
    public let preservedTopologyV20ID: String
    public let preservedTopologyV20SHA256: String
    public let preservedWorkerDecoderCallEdgeV19ContractID: String
    public let preservedWorkerDecoderCallEdgeV19ContractSHA256: String

    public let workerTargetName: String
    public let compositionSource:
        PrimeNativeNeuralGateHistoricalCompositionSourceIdentity
    public let preservedV19SourcePrefixByteCount: UInt64
    public let preservedV19SourcePrefixSHA256: String
    public let appendedV21SourceSuffixByteCount: UInt64
    public let appendedV21SourceSuffixSHA256: String
    public let exactPrefixPreserved: Bool
    public let sourceEvolutionAppendOnly: Bool
    public let packageSwift:
        PrimeNativeNeuralGateHistoricalCompositionSourceIdentity
    public let historicalV19TopologyTestBeforeV21:
        PrimeNativeNeuralGateHistoricalCompositionSourceIdentity
    public let currentV19TopologyTest:
        PrimeNativeNeuralGateHistoricalCompositionSourceIdentity
    public let historicalV20DesignTestBeforeV21:
        PrimeNativeNeuralGateHistoricalCompositionSourceIdentity
    public let currentV20DesignTest:
        PrimeNativeNeuralGateHistoricalCompositionSourceIdentity
    public let historicalTestsEvolvedTransparently: Bool

    public let orderedWorkerSwiftSourceRelativePaths: [String]
    public let exactWorkerSwiftSourceFileCount: Int
    public let workerDirectLocalDependencyNames: [String]
    public let exactWorkerDirectLocalDependencyCount: Int
    public let workerResourceRelativePaths: [String]
    public let packageGraphChanged: Bool
    public let workerSourceInventoryChanged: Bool
    public let workerDependenciesChanged: Bool
    public let workerResourcesChanged: Bool

    public let exactImportNames: [String]
    public let appendedImportName: String
    public let compositionErrorTypeName: String
    public let compositionErrorExactCaseNames: [String]
    public let compositionResultTypeName: String
    public let compositionResultAccessLevel: String
    public let compositionResultExactFieldNames: [String]
    public let compositionResultExactFieldSwiftTypeNames: [String]
    public let compositionResultExactFieldCount: Int
    public let compositionResultSendable: Bool
    public let compositionResultCodable: Bool
    public let compositionResultEquatable: Bool
    public let compositionResultHashable: Bool
    public let compositionResultIdentifiable: Bool
    public let compositionResultCustomStringConvertible: Bool
    public let compositionResultPublicInitializer: Bool
    public let compositionResultRetainsEvidence: Bool
    public let compositionResultRetainsContext: Bool

    public let compositionMethodName: String
    public let compositionNormalizedSignature: String
    public let compositionAccessLevel: String
    public let workerCallEdgeMethodName: String
    public let workerCallEdgeNormalizedSignature: String
    public let workerCallEdgeAccessLevel: String
    public let workerCallEdgeDelegatesOnlyToComposition: Bool
    public let exactCompositionInputLabels: [String]
    public let exactCompositionInputSwiftTypeNames: [String]
    public let evidenceMustBeAlreadyFormed: Bool
    public let evidencePassedToProjectorUnchanged: Bool
    public let contextMustBeExplicit: Bool
    public let contextPassedToProjectorUnchanged: Bool
    public let contextUnavailableGuardPrecedesProjection: Bool
    public let contextSourceBytesResolvedRequiredState: String
    public let contextAdaptationProofRecomputedRequiredState: String
    public let evidenceFieldInspectionPermitted: Bool
    public let evidenceEqualityHashEncodingOrDescriptionPermitted: Bool

    public let maintainedProjectionTypeName: String
    public let maintainedProjectionMethodName: String
    public let exactProjectionCallCount: Int
    public let maintainedV19DecoderMethodName: String
    public let exactMaintainedV19DecoderCallCount: Int
    public let exactProjectionThenDecodeOrder: Bool
    public let directV18DecoderCallPermitted: Bool
    public let duplicateV19ZipperPermitted: Bool
    public let customParserOrFrameArithmeticPermitted: Bool
    public let exactLinkageTypedKeyCount: Int
    public let linkageRequiresContextProjectedAndDecodedRoleEquality: Bool
    public let linkageRequiresUniqueDecodedTypedKeys: Bool
    public let linkageRequiresMaintainedCanonicalSpecificationOrder: Bool
    public let linkageUsesExactTypedKeyLookup: Bool
    public let linkageRequiresPerKeySpecificationEquality: Bool
    public let linkageRequiresPerKeyByteCountEquality: Bool
    public let linkageRequiresPerKeySHA256Equality: Bool
    public let positionalArtifactJoinPermitted: Bool
    public let sortFilterRankOrRecommendationPermitted: Bool
    public let retryCatchFallbackOrTryOptionalPermitted: Bool
    public let exactTypedFailurePropagationRequired: Bool

    public let resultTypeMaterialized: Bool
    public let compositionSourceAppended: Bool
    public let compositionCompilerBound: Bool
    public let compositionRuntimeExercised: Bool
    public let mainCanNameOrReachComposition: Bool
    public let mainRemainsUnconditionalUnavailableExit: Bool
    public let unavailableExitStatus: Int32
    public let runtimeInputAccepted: Bool
    public let runtimeOutputProduced: Bool
    public let workerRequestHandlingEnabled: Bool
    public let workerSealed: Bool
    public let workerLaunched: Bool
    public let workerExecuted: Bool
    public let fixtureMaterialized: Bool
    public let exporterRuntimeInvocationObserved: Bool
    public let projectorRuntimeInvocationObserved: Bool
    public let decoderRuntimeInvocationObserved: Bool
    public let artifactFilesystemReadPerformed: Bool
    public let artifactWritePerformed: Bool
    public let replayTransportIntegrated: Bool
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
        case preservedCompositionDesignV20ContractID =
            "preserved_composition_design_v20_contract_id"
        case preservedCompositionDesignV20ContractSHA256 =
            "preserved_composition_design_v20_contract_sha256"
        case preservedTopologyV20ID = "preserved_topology_v20_id"
        case preservedTopologyV20SHA256 = "preserved_topology_v20_sha256"
        case preservedWorkerDecoderCallEdgeV19ContractID =
            "preserved_worker_decoder_call_edge_v19_contract_id"
        case preservedWorkerDecoderCallEdgeV19ContractSHA256 =
            "preserved_worker_decoder_call_edge_v19_contract_sha256"
        case workerTargetName = "worker_target_name"
        case compositionSource = "composition_source"
        case preservedV19SourcePrefixByteCount =
            "preserved_v19_source_prefix_byte_count"
        case preservedV19SourcePrefixSHA256 =
            "preserved_v19_source_prefix_sha256"
        case appendedV21SourceSuffixByteCount =
            "appended_v21_source_suffix_byte_count"
        case appendedV21SourceSuffixSHA256 =
            "appended_v21_source_suffix_sha256"
        case exactPrefixPreserved = "exact_prefix_preserved"
        case sourceEvolutionAppendOnly = "source_evolution_append_only"
        case packageSwift = "package_swift"
        case historicalV19TopologyTestBeforeV21 =
            "historical_v19_topology_test_before_v21"
        case currentV19TopologyTest = "current_v19_topology_test"
        case historicalV20DesignTestBeforeV21 =
            "historical_v20_design_test_before_v21"
        case currentV20DesignTest = "current_v20_design_test"
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
        case packageGraphChanged = "package_graph_changed"
        case workerSourceInventoryChanged =
            "worker_source_inventory_changed"
        case workerDependenciesChanged = "worker_dependencies_changed"
        case workerResourcesChanged = "worker_resources_changed"
        case exactImportNames = "exact_import_names"
        case appendedImportName = "appended_import_name"
        case compositionErrorTypeName = "composition_error_type_name"
        case compositionErrorExactCaseNames =
            "composition_error_exact_case_names"
        case compositionResultTypeName = "composition_result_type_name"
        case compositionResultAccessLevel =
            "composition_result_access_level"
        case compositionResultExactFieldNames =
            "composition_result_exact_field_names"
        case compositionResultExactFieldSwiftTypeNames =
            "composition_result_exact_field_swift_type_names"
        case compositionResultExactFieldCount =
            "composition_result_exact_field_count"
        case compositionResultSendable = "composition_result_sendable"
        case compositionResultCodable = "composition_result_codable"
        case compositionResultEquatable = "composition_result_equatable"
        case compositionResultHashable = "composition_result_hashable"
        case compositionResultIdentifiable =
            "composition_result_identifiable"
        case compositionResultCustomStringConvertible =
            "composition_result_custom_string_convertible"
        case compositionResultPublicInitializer =
            "composition_result_public_initializer"
        case compositionResultRetainsEvidence =
            "composition_result_retains_evidence"
        case compositionResultRetainsContext =
            "composition_result_retains_context"
        case compositionMethodName = "composition_method_name"
        case compositionNormalizedSignature =
            "composition_normalized_signature"
        case compositionAccessLevel = "composition_access_level"
        case workerCallEdgeMethodName = "worker_call_edge_method_name"
        case workerCallEdgeNormalizedSignature =
            "worker_call_edge_normalized_signature"
        case workerCallEdgeAccessLevel = "worker_call_edge_access_level"
        case workerCallEdgeDelegatesOnlyToComposition =
            "worker_call_edge_delegates_only_to_composition"
        case exactCompositionInputLabels =
            "exact_composition_input_labels"
        case exactCompositionInputSwiftTypeNames =
            "exact_composition_input_swift_type_names"
        case evidenceMustBeAlreadyFormed =
            "evidence_must_be_already_formed"
        case evidencePassedToProjectorUnchanged =
            "evidence_passed_to_projector_unchanged"
        case contextMustBeExplicit = "context_must_be_explicit"
        case contextPassedToProjectorUnchanged =
            "context_passed_to_projector_unchanged"
        case contextUnavailableGuardPrecedesProjection =
            "context_unavailable_guard_precedes_projection"
        case contextSourceBytesResolvedRequiredState =
            "context_source_bytes_resolved_required_state"
        case contextAdaptationProofRecomputedRequiredState =
            "context_adaptation_proof_recomputed_required_state"
        case evidenceFieldInspectionPermitted =
            "evidence_field_inspection_permitted"
        case evidenceEqualityHashEncodingOrDescriptionPermitted =
            "evidence_equality_hash_encoding_or_description_permitted"
        case maintainedProjectionTypeName =
            "maintained_projection_type_name"
        case maintainedProjectionMethodName =
            "maintained_projection_method_name"
        case exactProjectionCallCount = "exact_projection_call_count"
        case maintainedV19DecoderMethodName =
            "maintained_v19_decoder_method_name"
        case exactMaintainedV19DecoderCallCount =
            "exact_maintained_v19_decoder_call_count"
        case exactProjectionThenDecodeOrder =
            "exact_projection_then_decode_order"
        case directV18DecoderCallPermitted =
            "direct_v18_decoder_call_permitted"
        case duplicateV19ZipperPermitted =
            "duplicate_v19_zipper_permitted"
        case customParserOrFrameArithmeticPermitted =
            "custom_parser_or_frame_arithmetic_permitted"
        case exactLinkageTypedKeyCount = "exact_linkage_typed_key_count"
        case linkageRequiresContextProjectedAndDecodedRoleEquality =
            "linkage_requires_context_projected_and_decoded_role_equality"
        case linkageRequiresUniqueDecodedTypedKeys =
            "linkage_requires_unique_decoded_typed_keys"
        case linkageRequiresMaintainedCanonicalSpecificationOrder =
            "linkage_requires_maintained_canonical_specification_order"
        case linkageUsesExactTypedKeyLookup =
            "linkage_uses_exact_typed_key_lookup"
        case linkageRequiresPerKeySpecificationEquality =
            "linkage_requires_per_key_specification_equality"
        case linkageRequiresPerKeyByteCountEquality =
            "linkage_requires_per_key_byte_count_equality"
        case linkageRequiresPerKeySHA256Equality =
            "linkage_requires_per_key_sha256_equality"
        case positionalArtifactJoinPermitted =
            "positional_artifact_join_permitted"
        case sortFilterRankOrRecommendationPermitted =
            "sort_filter_rank_or_recommendation_permitted"
        case retryCatchFallbackOrTryOptionalPermitted =
            "retry_catch_fallback_or_try_optional_permitted"
        case exactTypedFailurePropagationRequired =
            "exact_typed_failure_propagation_required"
        case resultTypeMaterialized = "result_type_materialized"
        case compositionSourceAppended = "composition_source_appended"
        case compositionCompilerBound = "composition_compiler_bound"
        case compositionRuntimeExercised =
            "composition_runtime_exercised"
        case mainCanNameOrReachComposition =
            "main_can_name_or_reach_composition"
        case mainRemainsUnconditionalUnavailableExit =
            "main_remains_unconditional_unavailable_exit"
        case unavailableExitStatus = "unavailable_exit_status"
        case runtimeInputAccepted = "runtime_input_accepted"
        case runtimeOutputProduced = "runtime_output_produced"
        case workerRequestHandlingEnabled =
            "worker_request_handling_enabled"
        case workerSealed = "worker_sealed"
        case workerLaunched = "worker_launched"
        case workerExecuted = "worker_executed"
        case fixtureMaterialized = "fixture_materialized"
        case exporterRuntimeInvocationObserved =
            "exporter_runtime_invocation_observed"
        case projectorRuntimeInvocationObserved =
            "projector_runtime_invocation_observed"
        case decoderRuntimeInvocationObserved =
            "decoder_runtime_invocation_observed"
        case artifactFilesystemReadPerformed =
            "artifact_filesystem_read_performed"
        case artifactWritePerformed = "artifact_write_performed"
        case replayTransportIntegrated = "replay_transport_integrated"
        case evidencePublished = "evidence_published"
        case durablePublicationObserved =
            "durable_publication_observed"
        case mechanicsPassAuthorized = "mechanics_pass_authorized"
        case terminalReceiptAuthorized = "terminal_receipt_authorized"
        case sourceBindingV7Issued = "source_binding_v7_issued"
        case scientificAuthorityAuthorized =
            "scientific_authority_authorized"
        case productAuthorityAuthorized = "product_authority_authorized"
        case primeDisposition = "prime_disposition"
        case nextImplementationPrerequisite =
            "next_implementation_prerequisite"
        case authorityStatement = "authority_statement"
    }

    public static let frozenV1: Self = {
        let workerPath =
            "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactDecoderCallEdge.swift"
        let v19TestPath =
            "Tests/PrimeCoreTests/PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactDecoderCallEdgeSourceTopologyV19Tests.swift"
        let v20TestPath =
            "Tests/PrimeCoreTests/PrimeNativeNeuralGateHistoricalWorkerExportedEvidenceProjectionDecodeCompositionDesignContractTests.swift"

        return Self(
            schemaVersion: 1,
            contractID:
                "prime_source_bound_historical_worker_exported_evidence_projection_decode_composition_call_edge_v21",
            rightsHolder: "Ergentics, LLC",
            licenseExpression: "LicenseRef-Ergentics-Proprietary",
            preservedCompositionDesignV20ContractID:
                "prime_source_bound_historical_worker_exported_evidence_projection_decode_composition_design_v20",
            preservedCompositionDesignV20ContractSHA256:
                "b1fc91f4026cb1c513be53f9cf6f5d53834489eab215e1343aa6b00f05a51f4c",
            preservedTopologyV20ID:
                "prime_stage_b_historical_worker_exported_evidence_projection_decode_composition_design_topology_v20",
            preservedTopologyV20SHA256:
                "b8045480883016fd49e7a63b02437f54835c1e7de6e61a4c2dea7f439a052a57",
            preservedWorkerDecoderCallEdgeV19ContractID:
                "prime_source_bound_historical_worker_semantic_artifact_decoder_call_edge_v19",
            preservedWorkerDecoderCallEdgeV19ContractSHA256:
                "f8739c0d162e026522dbdc2e6902403d935ebcfd2c9d13b07704b05ea3f9dac8",
            workerTargetName:
                "PrimeNativeNeuralGateHistoricalFixtureWorker",
            compositionSource: .init(
                primeRelativePath: workerPath,
                byteCount: 11_354,
                sha256:
                    "39cd879a54d6a1198f0a863f606751b1bb9d07f1ba6eb334dd74e9a079c40e1d"
            ),
            preservedV19SourcePrefixByteCount: 7_050,
            preservedV19SourcePrefixSHA256:
                "b8a4aaf4d9328df657f8fd62c3425b04ee2a293fb6dc75df19913635ef2f4cca",
            appendedV21SourceSuffixByteCount: 4_304,
            appendedV21SourceSuffixSHA256:
                "ba11c0a40cb2b49d56471b9863d63adc694fc0e52963de087e563e7105066c95",
            exactPrefixPreserved: true,
            sourceEvolutionAppendOnly: true,
            packageSwift: .init(
                primeRelativePath: "Package.swift",
                byteCount: 27_650,
                sha256:
                    "190b1d2dbeb2597830b1765fa80d6776a0044a34d5e2c6db8b14ace013654e7d"
            ),
            historicalV19TopologyTestBeforeV21: .init(
                primeRelativePath: v19TestPath,
                byteCount: 36_630,
                sha256:
                    "c3299463d56354424f57243737aa05611d7b7237f291bf723705762bfd63b476"
            ),
            currentV19TopologyTest: .init(
                primeRelativePath: v19TestPath,
                byteCount: 37_734,
                sha256:
                    "88fd3f1159794593ea71d18bdf994df584b821c2d6f94eea03be73ad50a9f841"
            ),
            historicalV20DesignTestBeforeV21: .init(
                primeRelativePath: v20TestPath,
                byteCount: 29_489,
                sha256:
                    "fcd0acea3e81123fb2764e46dfaa9bffb2f9c0d21167407e90a73ab03663343e"
            ),
            currentV20DesignTest: .init(
                primeRelativePath: v20TestPath,
                byteCount: 30_219,
                sha256:
                    "ccb83ef6eef21ae77aaf20cb056f49cfd6b04f4861e1f45ae1de4a32b7691eec"
            ),
            historicalTestsEvolvedTransparently: true,
            orderedWorkerSwiftSourceRelativePaths: [
                "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalEvidenceExportCallEdge.swift",
                "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalFixtureWorker.swift",
                workerPath,
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
            packageGraphChanged: false,
            workerSourceInventoryChanged: false,
            workerDependenciesChanged: false,
            workerResourcesChanged: false,
            exactImportNames: [
                "Foundation",
                "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection",
                "PrimeNativeNeuralGateHistoricalSemanticArtifactDecoder",
                "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics",
            ],
            appendedImportName:
                "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics",
            compositionErrorTypeName:
                "PrimeNativeNeuralGateHistoricalEvidenceProjectionDecodeCompositionError",
            compositionErrorExactCaseNames: [
                "contextMustRemainUnavailable",
                "invalidArtifactLinkage",
            ],
            compositionResultTypeName:
                "PrimeNativeNeuralGateHistoricalEvidenceProjectionDecodeCompositionResult",
            compositionResultAccessLevel: "private",
            compositionResultExactFieldNames: [
                "projectedArtifacts",
                "decodedArtifacts",
            ],
            compositionResultExactFieldSwiftTypeNames: [
                "PrimeNativeNeuralGateHistoricalProjectedArtifactSet",
                "PrimeNativeNeuralGateHistoricalDecodedSemanticArtifactSet",
            ],
            compositionResultExactFieldCount: 2,
            compositionResultSendable: true,
            compositionResultCodable: false,
            compositionResultEquatable: false,
            compositionResultHashable: false,
            compositionResultIdentifiable: false,
            compositionResultCustomStringConvertible: false,
            compositionResultPublicInitializer: false,
            compositionResultRetainsEvidence: false,
            compositionResultRetainsContext: false,
            compositionMethodName: "compose",
            compositionNormalizedSignature:
                "private static func compose(evidence: PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence, context: PrimeNativeNeuralGateHistoricalProjectionContext) throws -> PrimeNativeNeuralGateHistoricalEvidenceProjectionDecodeCompositionResult",
            compositionAccessLevel: "private",
            workerCallEdgeMethodName:
                "sourceBoundHistoricalEvidenceProjectionDecodeCompositionCallEdge",
            workerCallEdgeNormalizedSignature:
                "private static func sourceBoundHistoricalEvidenceProjectionDecodeCompositionCallEdge(evidence: PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence, context: PrimeNativeNeuralGateHistoricalProjectionContext) throws -> PrimeNativeNeuralGateHistoricalEvidenceProjectionDecodeCompositionResult",
            workerCallEdgeAccessLevel: "private",
            workerCallEdgeDelegatesOnlyToComposition: true,
            exactCompositionInputLabels: ["evidence", "context"],
            exactCompositionInputSwiftTypeNames: [
                "PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence",
                "PrimeNativeNeuralGateHistoricalProjectionContext",
            ],
            evidenceMustBeAlreadyFormed: true,
            evidencePassedToProjectorUnchanged: true,
            contextMustBeExplicit: true,
            contextPassedToProjectorUnchanged: true,
            contextUnavailableGuardPrecedesProjection: true,
            contextSourceBytesResolvedRequiredState: "unavailable",
            contextAdaptationProofRecomputedRequiredState: "unavailable",
            evidenceFieldInspectionPermitted: false,
            evidenceEqualityHashEncodingOrDescriptionPermitted: false,
            maintainedProjectionTypeName:
                "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection",
            maintainedProjectionMethodName: "project",
            exactProjectionCallCount: 1,
            maintainedV19DecoderMethodName:
                "sourceBoundHistoricalSemanticArtifactDecoderCallEdge",
            exactMaintainedV19DecoderCallCount: 1,
            exactProjectionThenDecodeOrder: true,
            directV18DecoderCallPermitted: false,
            duplicateV19ZipperPermitted: false,
            customParserOrFrameArithmeticPermitted: false,
            exactLinkageTypedKeyCount: 22,
            linkageRequiresContextProjectedAndDecodedRoleEquality: true,
            linkageRequiresUniqueDecodedTypedKeys: true,
            linkageRequiresMaintainedCanonicalSpecificationOrder: true,
            linkageUsesExactTypedKeyLookup: true,
            linkageRequiresPerKeySpecificationEquality: true,
            linkageRequiresPerKeyByteCountEquality: true,
            linkageRequiresPerKeySHA256Equality: true,
            positionalArtifactJoinPermitted: false,
            sortFilterRankOrRecommendationPermitted: false,
            retryCatchFallbackOrTryOptionalPermitted: false,
            exactTypedFailurePropagationRequired: true,
            resultTypeMaterialized: true,
            compositionSourceAppended: true,
            compositionCompilerBound: true,
            compositionRuntimeExercised: false,
            mainCanNameOrReachComposition: false,
            mainRemainsUnconditionalUnavailableExit: true,
            unavailableExitStatus: 78,
            runtimeInputAccepted: false,
            runtimeOutputProduced: false,
            workerRequestHandlingEnabled: false,
            workerSealed: false,
            workerLaunched: false,
            workerExecuted: false,
            fixtureMaterialized: false,
            exporterRuntimeInvocationObserved: false,
            projectorRuntimeInvocationObserved: false,
            decoderRuntimeInvocationObserved: false,
            artifactFilesystemReadPerformed: false,
            artifactWritePerformed: false,
            replayTransportIntegrated: false,
            evidencePublished: false,
            durablePublicationObserved: false,
            mechanicsPassAuthorized: false,
            terminalReceiptAuthorized: false,
            sourceBindingV7Issued: false,
            scientificAuthorityAuthorized: false,
            productAuthorityAuthorized: false,
            primeDisposition: "ABSTAIN",
            nextImplementationPrerequisite:
                "design_the_bounded_unavailable_historical_worker_invocation_seam_for_the_source_bound_v21_composition_before_any_private_access_change_replay_transport_integration_request_handling_sealing_launch_execution_artifact_io_publication_or_issuing_source_binding_v7",
            authorityStatement:
                [
                    "This V21 source contract preserves the exact V19 decoder-edge source as a 7,050-byte prefix, preserves the V20 design and topology identities, and transparently binds the append-only current worker source and historical-test evolution.",
                    "The appended private Sendable-only two-field result retains the exact projected and decoded artifact sets but no V14 Evidence value or object and no V16 context value or object. Evidence-derived bytes, the context-derived invocation role, and other transitive fail-closed metadata on those maintained sets remain unchanged; the result adds no dedicated path, descriptor, verdict, receipt, publication, or authority field or accessor and cannot promote retained metadata.",
                    "The private compose method rejects either context observation unless unavailable before passing one already-formed Evidence value and the explicit context unchanged to the maintained V16 projector exactly once, then passes the exact projected set to the same-file private V19 decoder edge exactly once.",
                    "Construction succeeds only after context, projected, and decoded roles match and all twenty-two maintained canonical typed keys have unique coverage, matching specification order, exact keyed lookup, and equal per-key specifications, byte counts, and SHA-256 values.",
                    "The new V21 composition layer directly inspects no Evidence field and invents no Evidence encoding, hash, description, comparison, sort, filter, rank, training, recommendation, or routing operation; it passes Evidence unchanged to the maintained V16 projector, whose existing projection behavior remains unchanged, bound, and maintained. No positional join, custom parser, frame arithmetic, duplicate zipper, retry, catch, fallback, optional try, or error-to-ABSTAIN conversion is admitted.",
                    "Package.swift, the four-file worker inventory, seven-dependency order, fixture resource, product graph, target graph, and forbidden reachability remain exact; the status-78 main cannot name either private V21 member.",
                    "Compilation proves only the typed source edge. No runtime input or output, request handling, sealing, launch, worker or model execution, artifact I/O, transport integration, publication, durability, mechanics PASS, terminal receipt, source or execution binding V7, scientific authority, or product authority is observed or authorized; Prime remains ABSTAIN.",
                ].joined(separator: " ")
        )
    }()

    public func validate() throws {
        guard self == .frozenV1 else {
            throw PrimeNativeNeuralGateHistoricalWorkerExportedEvidenceProjectionDecodeCompositionCallEdgeSourceContractError
                .invalidFrozenContract
        }
        let design =
            PrimeNativeNeuralGateHistoricalWorkerExportedEvidenceProjectionDecodeCompositionDesignContract
            .frozenV1
        let topology =
            PrimeNativeNeuralGateTrapDisjointTopologyContract
            .frozenV20
        let v19 =
            PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactDecoderCallEdgeSourceContract
            .frozenV1
        try design.validate()
        try topology.validate()
        try v19.validate()

        let identities = [
            compositionSource,
            packageSwift,
            historicalV19TopologyTestBeforeV21,
            currentV19TopologyTest,
            historicalV20DesignTestBeforeV21,
            currentV20DesignTest,
        ]
        guard schemaVersion == 1,
              contractID
                == "prime_source_bound_historical_worker_exported_evidence_projection_decode_composition_call_edge_v21",
              rightsHolder == "Ergentics, LLC",
              licenseExpression
                == "LicenseRef-Ergentics-Proprietary",
              preservedCompositionDesignV20ContractID
                == design.contractID,
              preservedCompositionDesignV20ContractSHA256
                == (try design.contentSHA256()),
              preservedTopologyV20ID == topology.contractID,
              preservedTopologyV20SHA256
                == (try topology.contentSHA256()),
              preservedWorkerDecoderCallEdgeV19ContractID
                == v19.contractID,
              preservedWorkerDecoderCallEdgeV19ContractSHA256
                == (try v19.contentSHA256()),
              identities.allSatisfy({ $0.validate() }),
              compositionSource.byteCount
                == preservedV19SourcePrefixByteCount
                    + appendedV21SourceSuffixByteCount,
              preservedV19SourcePrefixByteCount == 7_050,
              preservedV19SourcePrefixSHA256
                == v19.decoderCallEdgeSource.sha256,
              exactPrefixPreserved,
              sourceEvolutionAppendOnly,
              historicalV19TopologyTestBeforeV21.primeRelativePath
                == currentV19TopologyTest.primeRelativePath,
              historicalV20DesignTestBeforeV21.primeRelativePath
                == currentV20DesignTest.primeRelativePath,
              historicalTestsEvolvedTransparently,
              orderedWorkerSwiftSourceRelativePaths
                == v19.orderedWorkerSwiftSourceRelativePaths,
              exactWorkerSwiftSourceFileCount == 4,
              workerDirectLocalDependencyNames
                == v19.workerDirectLocalDependencyNames,
              exactWorkerDirectLocalDependencyCount == 7,
              workerResourceRelativePaths
                == [v19.fixtureResource.primeRelativePath],
              !packageGraphChanged,
              !workerSourceInventoryChanged,
              !workerDependenciesChanged,
              !workerResourcesChanged,
              exactImportNames
                == [
                    "Foundation",
                    "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection",
                    "PrimeNativeNeuralGateHistoricalSemanticArtifactDecoder",
                    "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics",
                ],
              appendedImportName
                == "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics",
              compositionErrorExactCaseNames
                == [
                    "contextMustRemainUnavailable",
                    "invalidArtifactLinkage",
                ],
              compositionResultAccessLevel == "private",
              compositionResultExactFieldNames
                == ["projectedArtifacts", "decodedArtifacts"],
              compositionResultExactFieldCount == 2,
              compositionResultSendable,
              !compositionResultCodable,
              !compositionResultEquatable,
              !compositionResultHashable,
              !compositionResultIdentifiable,
              !compositionResultCustomStringConvertible,
              !compositionResultPublicInitializer,
              !compositionResultRetainsEvidence,
              !compositionResultRetainsContext,
              compositionMethodName == "compose",
              compositionAccessLevel == "private",
              workerCallEdgeMethodName
                == "sourceBoundHistoricalEvidenceProjectionDecodeCompositionCallEdge",
              workerCallEdgeAccessLevel == "private",
              workerCallEdgeDelegatesOnlyToComposition,
              exactCompositionInputLabels == ["evidence", "context"],
              evidenceMustBeAlreadyFormed,
              evidencePassedToProjectorUnchanged,
              contextMustBeExplicit,
              contextPassedToProjectorUnchanged,
              contextUnavailableGuardPrecedesProjection,
              contextSourceBytesResolvedRequiredState == "unavailable",
              contextAdaptationProofRecomputedRequiredState
                == "unavailable",
              !evidenceFieldInspectionPermitted,
              !evidenceEqualityHashEncodingOrDescriptionPermitted,
              maintainedProjectionMethodName == "project",
              exactProjectionCallCount == 1,
              maintainedV19DecoderMethodName
                == "sourceBoundHistoricalSemanticArtifactDecoderCallEdge",
              exactMaintainedV19DecoderCallCount == 1,
              exactProjectionThenDecodeOrder,
              !directV18DecoderCallPermitted,
              !duplicateV19ZipperPermitted,
              !customParserOrFrameArithmeticPermitted,
              exactLinkageTypedKeyCount == 22,
              linkageRequiresContextProjectedAndDecodedRoleEquality,
              linkageRequiresUniqueDecodedTypedKeys,
              linkageRequiresMaintainedCanonicalSpecificationOrder,
              linkageUsesExactTypedKeyLookup,
              linkageRequiresPerKeySpecificationEquality,
              linkageRequiresPerKeyByteCountEquality,
              linkageRequiresPerKeySHA256Equality,
              !positionalArtifactJoinPermitted,
              !sortFilterRankOrRecommendationPermitted,
              !retryCatchFallbackOrTryOptionalPermitted,
              exactTypedFailurePropagationRequired,
              resultTypeMaterialized,
              compositionSourceAppended,
              compositionCompilerBound,
              !compositionRuntimeExercised,
              !mainCanNameOrReachComposition,
              mainRemainsUnconditionalUnavailableExit,
              unavailableExitStatus == 78,
              !runtimeInputAccepted,
              !runtimeOutputProduced,
              !workerRequestHandlingEnabled,
              !workerSealed,
              !workerLaunched,
              !workerExecuted,
              !fixtureMaterialized,
              !exporterRuntimeInvocationObserved,
              !projectorRuntimeInvocationObserved,
              !decoderRuntimeInvocationObserved,
              !artifactFilesystemReadPerformed,
              !artifactWritePerformed,
              !replayTransportIntegrated,
              !evidencePublished,
              !durablePublicationObserved,
              !mechanicsPassAuthorized,
              !terminalReceiptAuthorized,
              !sourceBindingV7Issued,
              !scientificAuthorityAuthorized,
              !productAuthorityAuthorized,
              primeDisposition == "ABSTAIN",
              nextImplementationPrerequisite
                == "design_the_bounded_unavailable_historical_worker_invocation_seam_for_the_source_bound_v21_composition_before_any_private_access_change_replay_transport_integration_request_handling_sealing_launch_execution_artifact_io_publication_or_issuing_source_binding_v7",
              authorityStatement.contains(
                "Compilation proves only the typed source edge."
              )
        else {
            throw PrimeNativeNeuralGateHistoricalWorkerExportedEvidenceProjectionDecodeCompositionCallEdgeSourceContractError
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
