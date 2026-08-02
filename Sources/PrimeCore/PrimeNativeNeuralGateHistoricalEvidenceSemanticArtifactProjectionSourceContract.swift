// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

public enum
    PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjectionSourceContractError:
    Error,
    Equatable,
    Sendable
{
    case invalidFrozenContract
}

public struct
    PrimeNativeNeuralGateHistoricalProjectionSourceFileIdentity:
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
            && Self.isSHA256(sha256)
    }

    private static func isSHA256(_ value: String) -> Bool {
        value.utf8.count == 64
            && value.utf8.allSatisfy {
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
    PrimeNativeNeuralGateHistoricalProjectionTargetBinding:
    Codable,
    Equatable,
    Sendable
{
    public let targetName: String
    public let targetKind: String
    public let directLocalDependencyNames: [String]
    public let orderedSourceFiles:
        [PrimeNativeNeuralGateHistoricalProjectionSourceFileIdentity]
    public let copiedResourceRelativePaths: [String]
    public let externalProductDependencyNames: [String]
    public let productDeclared: Bool
    public let executableDeclared: Bool
    public let completeTargetInventoryBound: Bool

    fileprivate init(
        targetName: String,
        directLocalDependencyNames: [String],
        orderedSourceFiles:
            [PrimeNativeNeuralGateHistoricalProjectionSourceFileIdentity]
    ) {
        self.targetName = targetName
        targetKind = "internal_library"
        self.directLocalDependencyNames =
            directLocalDependencyNames
        self.orderedSourceFiles = orderedSourceFiles
        copiedResourceRelativePaths = []
        externalProductDependencyNames = []
        productDeclared = false
        executableDeclared = false
        completeTargetInventoryBound = true
    }

    fileprivate func validate() -> Bool {
        !targetName.isEmpty
            && targetKind == "internal_library"
            && !directLocalDependencyNames.isEmpty
            && Set(directLocalDependencyNames).count
                == directLocalDependencyNames.count
            && !orderedSourceFiles.isEmpty
            && Set(
                orderedSourceFiles.map(\.primeRelativePath)
            ).count == orderedSourceFiles.count
            && orderedSourceFiles.allSatisfy {
                $0.validate()
            }
            && copiedResourceRelativePaths.isEmpty
            && externalProductDependencyNames.isEmpty
            && !productDeclared
            && !executableDeclared
            && completeTargetInventoryBound
    }

    private enum CodingKeys: String, CodingKey {
        case targetName = "target_name"
        case targetKind = "target_kind"
        case directLocalDependencyNames =
            "direct_local_dependency_names"
        case orderedSourceFiles = "ordered_source_files"
        case copiedResourceRelativePaths =
            "copied_resource_relative_paths"
        case externalProductDependencyNames =
            "external_product_dependency_names"
        case productDeclared = "product_declared"
        case executableDeclared = "executable_declared"
        case completeTargetInventoryBound =
            "complete_target_inventory_bound"
    }
}

/// Frozen V16 source and package boundary for the pure historical carrier-to-
/// semantic-artifact projection codec.
///
/// V16 preserves every V1 through V15 identity. It closes the historical
/// namespace additively, retains all three seed-keyed statistics families,
/// and moves the byte-exact corrected mutation record source out of the
/// historical-safe semantic target. The projector is a package-internal,
/// in-memory codec. It is not reachable from the unavailable worker and has
/// no filesystem, transport, publication, receipt, execution, science, or
/// product authority.
public struct
    PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjectionSourceContract:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let contractID: String
    public let rightsHolder: String
    public let licenseExpression: String

    public let preservedDesignV15ID: String
    public let preservedDesignV15SHA256: String
    public let preservedTopologyV15ID: String
    public let preservedTopologyV15SHA256: String
    public let preservedNamespaceV4ID: String
    public let preservedNamespaceV4SHA256: String
    public let preservedSemanticRecordV8ID: String
    public let preservedSemanticRecordV8SHA256: String
    public let preservedExporterV13ID: String
    public let preservedExporterV13SHA256: String
    public let preservedWorkerCallEdgeV14ID: String
    public let preservedWorkerCallEdgeV14SHA256: String

    public let completeHistoricalNamespaceContractID: String
    public let completeHistoricalNamespaceContractSHA256: String
    public let completeHistoricalNamespaceSource:
        PrimeNativeNeuralGateHistoricalProjectionSourceFileIdentity
    public let priorNamespaceChanged: Bool
    public let exactNamespaceSpecificationCount: Int
    public let exactNamespaceSpecificationCountPerRole: Int
    public let exactHistoricalRoleCount: Int
    public let exactInvariantChunkCountPerRole: Int
    public let namespaceComplete: Bool
    public let namespaceAuthorizing: Bool

    public let admittedHistoricalSeeds: [Int]
    public let statisticsEnvelopeSchemaID: String
    public let statisticsJoinPolicyID: String
    public let exactSeedCount: Int
    public let heldoutFamilyRetainedPerSeed: Bool
    public let fixedPromptFamilyRetainedPerSeed: Bool
    public let capabilityFamilyRetainedPerSeed: Bool
    public let seedJoinIsExplicitlyKeyed: Bool
    public let positionalSeedJoinPermitted: Bool
    public let seedReductionApplied: Bool
    public let summaryMaySupplyEvidence: Bool

    public let correctedMutationOwnershipV2ID: String
    public let correctedMutationOwnershipV2SHA256: String
    public let mutationRecordOriginalTargetName: String
    public let mutationRecordOriginalSourceRelativePath: String
    public let correctedMutationRecordTargetBinding:
        PrimeNativeNeuralGateHistoricalProjectionTargetBinding
    public let mutationRecordSourceMovedByteForByte: Bool
    public let mutationRecordSourceAccessChanged: Bool

    public let semanticRecordTargetBinding:
        PrimeNativeNeuralGateHistoricalProjectionTargetBinding
    public let historicalObservedFailureLegValidationPolicyID: String
    public let observedFailureLegsUseFrozenHistoricalCriticalLegDomain:
        Bool
    public let uppercaseHistoricalNLFailureLegIDsPreserved: Bool
    public let unknownHistoricalFailureLegIDsRejected: Bool
    public let semanticV8CanonicalBytesChanged: Bool
    public let projectionTargetBinding:
        PrimeNativeNeuralGateHistoricalProjectionTargetBinding
    public let projectionPublicTypeName: String
    public let projectionPublicMethodName: String
    public let projectionInputCarrierTypeName: String
    public let projectionOutputArtifactSetTypeName: String
    public let projectionIsPureInMemoryCodec: Bool
    public let projectionComponentSyntheticMechanicsCoveredByFocusedTests:
        Bool
    public let projectionFocusedSyntheticMechanicsTestSource:
        PrimeNativeNeuralGateHistoricalProjectionSourceFileIdentity
    public let exactFocusedSyntheticMechanicsTestMethodCount: Int
    public let projectionPublicEntryPointRuntimeExercised: Bool
    public let syntheticTestsAreHistoricalEvidence: Bool
    public let exactProjectedArtifactCountPerRole: Int
    public let exactProjectedArtifactCountAcrossRoles: Int
    public let redundantFingerprintFieldsOmittedAfterExactCanonicalReconstruction:
        Bool
    public let nonDerivableCarrierInformationDropped: Bool
    public let carrierInformationDefaulted: Bool
    public let seedOrStatisticalReductionApplied: Bool

    public let workerTargetName: String
    public let workerDirectLocalDependencyNames: [String]
    public let workerSourceChanged: Bool
    public let workerDependenciesChanged: Bool
    public let workerCallGraphChanged: Bool
    public let workerMainUnavailable: Bool
    public let unavailableExitStatus: Int32
    public let workerMayReachProjectionTarget: Bool
    public let projectionMayReachWorkerTarget: Bool
    public let replayTransportIntegratedWithProjection: Bool
    public let workerRequestHandlingEnabled: Bool
    public let workerSealed: Bool
    public let workerLaunched: Bool
    public let workerExecuted: Bool
    public let exporterInvoked: Bool
    public let projectionInvoked: Bool
    public let historicalGateExecuted: Bool
    public let historicalEvidenceObserved: Bool
    public let artifactWritePerformed: Bool
    public let evidencePublished: Bool
    public let durablePublicationObserved: Bool
    public let modelExecutionObserved: Bool
    public let mechanicsPassAuthorized: Bool
    public let terminalReceiptAuthorized: Bool
    public let sourceBindingV7Issued: Bool
    public let scientificAuthorityAuthorized: Bool
    public let productAuthorityAuthorized: Bool
    public let nextImplementationPrerequisite: String
    public let authorityStatement: String

    public static let frozenV1: Self = {
        let design =
            PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjectionDesignContract
            .frozenV1
        let topology =
            PrimeNativeNeuralGateTrapDisjointTopologyContract
            .frozenV15

        return Self(
            schemaVersion: 1,
            contractID:
                "prime_source_bound_historical_evidence_semantic_artifact_projection_source_v16",
            rightsHolder: "Ergentics, LLC",
            licenseExpression:
                "LicenseRef-Ergentics-Proprietary",
            preservedDesignV15ID: design.contractID,
            preservedDesignV15SHA256:
                "2d7da9703cf710f6f795900d91872780297a0e8d18f345cca302711d7fd0ec27",
            preservedTopologyV15ID: topology.contractID,
            preservedTopologyV15SHA256:
                "c4fe0ddd24fc5d614b36ee2698d62cb7cdae745b087c02cc176225a070852eb0",
            preservedNamespaceV4ID:
                "prime_stage_b_non_authorizing_semantic_output_namespace_v4",
            preservedNamespaceV4SHA256:
                "60e10e6c10f9ec1f30102f5b6d27be123434a163c01d82c0cc5d4520824532d1",
            preservedSemanticRecordV8ID:
                "prime_stage_b_semantic_record_schema_contract_v1",
            preservedSemanticRecordV8SHA256:
                "67451098c4c486cd6a2d1701190c7ba3129d48f47956dc5c674295053f47cf9a",
            preservedExporterV13ID:
                "prime_source_bound_historical_evidence_export_source_v13",
            preservedExporterV13SHA256:
                "ecc329a7e56d843b53f9d894af4e335c9d00ac05d56efe308d61860835278d5e",
            preservedWorkerCallEdgeV14ID:
                "prime_source_bound_historical_worker_evidence_export_call_edge_v14",
            preservedWorkerCallEdgeV14SHA256:
                "8112cf3e6190fcd6385614322be11f391bccc1ca411b6af85c7bd8cf57c4a4e8",
            completeHistoricalNamespaceContractID:
                "prime_stage_b_complete_non_authorizing_historical_semantic_artifact_namespace_v1",
            completeHistoricalNamespaceContractSHA256:
                "eaabb04be1147b89c2e93a1dacd2c8a135383343c61a9e1756b5e7fcc3498c80",
            completeHistoricalNamespaceSource: file(
                "Sources/PrimeNativeNeuralGateReplayArtifactContracts/PrimeNativeNeuralGateHistoricalSemanticArtifactNamespaceContract.swift",
                16_655,
                "3f45249a2b5afa84d4b13f38f3bd467d1c765811e6295d62d5fe2a790eee311f"
            ),
            priorNamespaceChanged: false,
            exactNamespaceSpecificationCount: 44,
            exactNamespaceSpecificationCountPerRole: 22,
            exactHistoricalRoleCount: 2,
            exactInvariantChunkCountPerRole: 15,
            namespaceComplete: true,
            namespaceAuthorizing: false,
            admittedHistoricalSeeds: [1_618, 2_718, 3_141],
            statisticsEnvelopeSchemaID:
                "prime_stage_b_historical_keyed_three_seed_statistics_verdict_observation_v1",
            statisticsJoinPolicyID:
                "explicit_seed_keyed_three_family_exact_coverage_no_positional_join_v1",
            exactSeedCount: 3,
            heldoutFamilyRetainedPerSeed: true,
            fixedPromptFamilyRetainedPerSeed: true,
            capabilityFamilyRetainedPerSeed: true,
            seedJoinIsExplicitlyKeyed: true,
            positionalSeedJoinPermitted: false,
            seedReductionApplied: false,
            summaryMaySupplyEvidence: false,
            correctedMutationOwnershipV2ID:
                "prime_stage_b_corrected_mutation_producer_detector_source_assignment_v2",
            correctedMutationOwnershipV2SHA256:
                "488c02cb82c787228c64c6c10588b0bfcc6ac25f85d13c678ac24ec6af246540",
            mutationRecordOriginalTargetName:
                "PrimeNativeNeuralGateSemanticRecordContracts",
            mutationRecordOriginalSourceRelativePath:
                "Sources/PrimeNativeNeuralGateSemanticRecordContracts/PrimeNativeNeuralGateMutationRecordContracts.swift",
            correctedMutationRecordTargetBinding: target(
                "PrimeNativeNeuralGateCorrectedMutationRecordContracts",
                [
                    "PrimeNativeNeuralGateReplayArtifactContracts",
                    "PrimeNativeNeuralGateReplayMechanics",
                    "PrimeNativeNeuralGateCorrectedMutationSurfaceContracts",
                ],
                [
                    file(
                        "Sources/PrimeNativeNeuralGateCorrectedMutationRecordContracts/PrimeNativeNeuralGateMutationRecordContracts.swift",
                        12_148,
                        "ab41377c3cc4a6ea14de37927cc8faff625392d17d5210a967a7754d1481b638"
                    ),
                ]
            ),
            mutationRecordSourceMovedByteForByte: true,
            mutationRecordSourceAccessChanged: false,
            semanticRecordTargetBinding: target(
                "PrimeNativeNeuralGateSemanticRecordContracts",
                [
                    "PrimeNativeNeuralGateReplayArtifactContracts",
                    "PrimeNativeNeuralGateReplayMechanics",
                ],
                [
                    file(
                        "Sources/PrimeNativeNeuralGateSemanticRecordContracts/PrimeNativeNeuralGateHistoricalObservationContracts.swift",
                        41_851,
                        "3564322ec285d63aa89781b42062decf6997e8c5c9ffcf7a774ff70150b5e584"
                    ),
                    file(
                        "Sources/PrimeNativeNeuralGateSemanticRecordContracts/PrimeNativeNeuralGateMLXObservationContracts.swift",
                        17_792,
                        "1bee78c6d4e8a5c006654bf2092fe44e33d4da710ff308d1411b4d2f997c8f2a"
                    ),
                    file(
                        "Sources/PrimeNativeNeuralGateSemanticRecordContracts/PrimeNativeNeuralGateSemanticRecordContract.swift",
                        27_062,
                        "985901402cc6deb14dc5e84920ece9b5b894e618e3be41ebe755c3fb93622c9c"
                    ),
                    file(
                        "Sources/PrimeNativeNeuralGateSemanticRecordContracts/PrimeNativeNeuralGateStatisticsVerdictContracts.swift",
                        40_069,
                        "593b2299c75b2f496841d09679feec1ee46a79cbd553e9ff4645771cfc43023f"
                    ),
                ]
            ),
            historicalObservedFailureLegValidationPolicyID:
                "frozen_historical_critical_leg_domain_membership_v1",
            observedFailureLegsUseFrozenHistoricalCriticalLegDomain:
                true,
            uppercaseHistoricalNLFailureLegIDsPreserved: true,
            unknownHistoricalFailureLegIDsRejected: true,
            semanticV8CanonicalBytesChanged: false,
            projectionTargetBinding: target(
                "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection",
                [
                    "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics",
                    "PrimeNativeNeuralGateReplayArtifactContracts",
                    "PrimeNativeNeuralGateReplayMechanics",
                    "PrimeNativeNeuralGateSemanticRecordContracts",
                ],
                [
                    file(
                        "Sources/PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection/PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection.swift",
                        28_320,
                        "23e5d3bc6814e1283011f8b5049105dfdcfeef9d7e442130b7be7c6499431ec9"
                    ),
                    file(
                        "Sources/PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection/PrimeNativeNeuralGateHistoricalKeyedThreeSeedStatisticsEnvelope.swift",
                        46_950,
                        "e3b876a2bc9aff099b57da66bfa698f196dc4541a10e4c253d511a6d385fd7b7"
                    ),
                ]
            ),
            projectionPublicTypeName:
                "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection",
            projectionPublicMethodName: "project",
            projectionInputCarrierTypeName:
                "PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence",
            projectionOutputArtifactSetTypeName:
                "PrimeNativeNeuralGateHistoricalProjectedArtifactSet",
            projectionIsPureInMemoryCodec: true,
            projectionComponentSyntheticMechanicsCoveredByFocusedTests:
                true,
            projectionFocusedSyntheticMechanicsTestSource: file(
                "Tests/PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjectionTests/PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjectionTests.swift",
                46_286,
                "6d51b89395f8416237c80a8b6e7eaf487fe938638f2e6a74d462185e88d3fc94"
            ),
            exactFocusedSyntheticMechanicsTestMethodCount: 15,
            projectionPublicEntryPointRuntimeExercised: false,
            syntheticTestsAreHistoricalEvidence: false,
            exactProjectedArtifactCountPerRole: 22,
            exactProjectedArtifactCountAcrossRoles: 44,
            redundantFingerprintFieldsOmittedAfterExactCanonicalReconstruction:
                true,
            nonDerivableCarrierInformationDropped: false,
            carrierInformationDefaulted: false,
            seedOrStatisticalReductionApplied: false,
            workerTargetName:
                "PrimeNativeNeuralGateHistoricalFixtureWorker",
            workerDirectLocalDependencyNames: [
                "PrimeCore",
                "ErgenticsPrimeRuntime",
                "PrimeNativeNeuralGateHistoricalReplayMechanics",
                "PrimeNativeNeuralGateReplayTransport",
                "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics",
            ],
            workerSourceChanged: false,
            workerDependenciesChanged: false,
            workerCallGraphChanged: false,
            workerMainUnavailable: true,
            unavailableExitStatus: 78,
            workerMayReachProjectionTarget: false,
            projectionMayReachWorkerTarget: false,
            replayTransportIntegratedWithProjection: false,
            workerRequestHandlingEnabled: false,
            workerSealed: false,
            workerLaunched: false,
            workerExecuted: false,
            exporterInvoked: false,
            projectionInvoked: false,
            historicalGateExecuted: false,
            historicalEvidenceObserved: false,
            artifactWritePerformed: false,
            evidencePublished: false,
            durablePublicationObserved: false,
            modelExecutionObserved: false,
            mechanicsPassAuthorized: false,
            terminalReceiptAuthorized: false,
            sourceBindingV7Issued: false,
            scientificAuthorityAuthorized: false,
            productAuthorityAuthorized: false,
            nextImplementationPrerequisite:
                "source_bind_the_unavailable_historical_worker_carrier_to_pure_semantic_artifact_projection_call_edge_without_enabling_request_handling_sealing_launch_execution_io_publication_or_issuing_source_binding_v7",
            authorityStatement:
                [
                    "This V16 source contract preserves V1 through V15, V4 namespace identity, V8 semantic schema identity, V13 exporter identity, and the V14 worker/exporter call edge.",
                    "It additively binds a complete forty-four-spec non-authorizing historical namespace, a lossless explicit-key three-seed statistics envelope, the byte-exact corrected mutation-record source split, and one package-internal pure in-memory historical projection codec.",
                    "The corrected-mutation ownership V2 release-source-reference prerequisite remains deferred, component-local, and subordinate to this V16 topology-wide continuation; because every corrected-mutation target is outside the historical projector's transitive closure, it does not gate the disjoint historical worker-carrier-to-projector call edge.",
                    "The semantic target no longer reaches corrected mutation contracts. The projector directly depends only on the V13 exporter, replay-artifact contracts, pure replay mechanics, and historical-safe semantic records; through the exporter, its transitive local closure additionally includes the historical replay mechanics and ErgenticsPrimeRuntime.",
                    "V16 also corrects only the live historical observed-failure validator to use membership in the frozen historical critical-leg domain, preserving uppercase NL identifiers and rejecting unknown identifiers without changing V8 canonical contract bytes.",
                    "Deterministically redundant fingerprint fields are omitted only after exact canonical reconstruction; no non-derivable carrier information is dropped or defaulted and no seed or statistical reduction occurs.",
                    "Focused synthetic tests exercise pure component mechanics only; the public project(evidence:context:) entry point is not runtime-exercised, and synthetic mechanics are not historical evidence.",
                    "The V11 worker dependency order, call graph, unavailable main, and status 78 remain unchanged; neither worker nor ReplayTransport reaches the projector.",
                    "No worker request handling, sealing, launch, worker/exporter/projector/gate/model execution, artifact I/O, publication, durable evidence, mechanics PASS, terminal receipt, source or execution binding V7, scientific authority, or product authority is observed or authorized.",
                ].joined(separator: " ")
        )
    }()

    public func validate() throws {
        let design =
            PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjectionDesignContract
            .frozenV1
        let topology =
            PrimeNativeNeuralGateTrapDisjointTopologyContract
            .frozenV15
        try design.validate()
        try topology.validate()

        let expectedProjectionDependencies = [
            "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics",
            "PrimeNativeNeuralGateReplayArtifactContracts",
            "PrimeNativeNeuralGateReplayMechanics",
            "PrimeNativeNeuralGateSemanticRecordContracts",
        ]
        let correctedNames = [
            "PrimeNativeNeuralGateCorrectedMutationSurfaceContracts",
            "PrimeNativeNeuralGateCorrectedMutationRecordContracts",
            "PrimeNativeNeuralGateCorrectedMutationProducer",
            "PrimeNativeNeuralGateCorrectedMutationDetector",
        ]

        guard self == .frozenV1,
              schemaVersion == 1,
              contractID
                == "prime_source_bound_historical_evidence_semantic_artifact_projection_source_v16",
              rightsHolder == "Ergentics, LLC",
              licenseExpression
                == "LicenseRef-Ergentics-Proprietary",
              preservedDesignV15ID == design.contractID,
              preservedDesignV15SHA256
                == (try design.contentSHA256()),
              preservedTopologyV15ID == topology.contractID,
              preservedTopologyV15SHA256
                == (try topology.contentSHA256()),
              preservedNamespaceV4ID
                == design.preservedSemanticNamespaceContractID,
              preservedNamespaceV4SHA256
                == design.preservedSemanticNamespaceContractSHA256,
              preservedSemanticRecordV8ID
                == design.preservedSemanticRecordContractID,
              preservedSemanticRecordV8SHA256
                == design.preservedSemanticRecordContractSHA256,
              preservedExporterV13ID
                == design.preservedExporterSourceContractID,
              preservedExporterV13SHA256
                == design.preservedExporterSourceContractSHA256,
              preservedWorkerCallEdgeV14ID
                == design.preservedCallEdgeSourceContractID,
              preservedWorkerCallEdgeV14SHA256
                == design.preservedCallEdgeSourceContractSHA256,
              completeHistoricalNamespaceContractID
                == "prime_stage_b_complete_non_authorizing_historical_semantic_artifact_namespace_v1",
              completeHistoricalNamespaceContractSHA256
                == "eaabb04be1147b89c2e93a1dacd2c8a135383343c61a9e1756b5e7fcc3498c80",
              completeHistoricalNamespaceSource.validate(),
              completeHistoricalNamespaceSource.byteCount == 16_655,
              completeHistoricalNamespaceSource.sha256
                == "3f45249a2b5afa84d4b13f38f3bd467d1c765811e6295d62d5fe2a790eee311f",
              !priorNamespaceChanged,
              exactNamespaceSpecificationCount == 44,
              exactNamespaceSpecificationCountPerRole == 22,
              exactHistoricalRoleCount == 2,
              exactNamespaceSpecificationCount
                == exactNamespaceSpecificationCountPerRole
                    * exactHistoricalRoleCount,
              exactInvariantChunkCountPerRole == 15,
              namespaceComplete,
              !namespaceAuthorizing,
              admittedHistoricalSeeds == [1_618, 2_718, 3_141],
              statisticsEnvelopeSchemaID
                == "prime_stage_b_historical_keyed_three_seed_statistics_verdict_observation_v1",
              statisticsJoinPolicyID
                == "explicit_seed_keyed_three_family_exact_coverage_no_positional_join_v1",
              admittedHistoricalSeeds.count == exactSeedCount,
              exactSeedCount == 3,
              heldoutFamilyRetainedPerSeed,
              fixedPromptFamilyRetainedPerSeed,
              capabilityFamilyRetainedPerSeed,
              seedJoinIsExplicitlyKeyed,
              !positionalSeedJoinPermitted,
              !seedReductionApplied,
              !summaryMaySupplyEvidence,
              correctedMutationOwnershipV2ID
                == "prime_stage_b_corrected_mutation_producer_detector_source_assignment_v2",
              correctedMutationOwnershipV2SHA256
                == "488c02cb82c787228c64c6c10588b0bfcc6ac25f85d13c678ac24ec6af246540",
              mutationRecordOriginalTargetName
                == "PrimeNativeNeuralGateSemanticRecordContracts",
              mutationRecordOriginalSourceRelativePath
                == "Sources/PrimeNativeNeuralGateSemanticRecordContracts/PrimeNativeNeuralGateMutationRecordContracts.swift",
              correctedMutationRecordTargetBinding.validate(),
              correctedMutationRecordTargetBinding.targetName
                == "PrimeNativeNeuralGateCorrectedMutationRecordContracts",
              correctedMutationRecordTargetBinding
                .directLocalDependencyNames
                == [
                    "PrimeNativeNeuralGateReplayArtifactContracts",
                    "PrimeNativeNeuralGateReplayMechanics",
                    "PrimeNativeNeuralGateCorrectedMutationSurfaceContracts",
                ],
              correctedMutationRecordTargetBinding
                .orderedSourceFiles.count == 1,
              correctedMutationRecordTargetBinding
                .orderedSourceFiles[0].byteCount == 12_148,
              correctedMutationRecordTargetBinding
                .orderedSourceFiles[0].sha256
                == "ab41377c3cc4a6ea14de37927cc8faff625392d17d5210a967a7754d1481b638",
              mutationRecordSourceMovedByteForByte,
              !mutationRecordSourceAccessChanged,
              semanticRecordTargetBinding.validate(),
              semanticRecordTargetBinding.targetName
                == "PrimeNativeNeuralGateSemanticRecordContracts",
              semanticRecordTargetBinding
                .directLocalDependencyNames
                == [
                    "PrimeNativeNeuralGateReplayArtifactContracts",
                    "PrimeNativeNeuralGateReplayMechanics",
                ],
              semanticRecordTargetBinding.orderedSourceFiles.count
                == 4,
              correctedNames.allSatisfy({
                  !semanticRecordTargetBinding
                    .directLocalDependencyNames.contains($0)
              }),
              historicalObservedFailureLegValidationPolicyID
                == "frozen_historical_critical_leg_domain_membership_v1",
              observedFailureLegsUseFrozenHistoricalCriticalLegDomain,
              uppercaseHistoricalNLFailureLegIDsPreserved,
              unknownHistoricalFailureLegIDsRejected,
              !semanticV8CanonicalBytesChanged,
              projectionTargetBinding.validate(),
              projectionTargetBinding.targetName
                == "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection",
              projectionTargetBinding.directLocalDependencyNames
                == expectedProjectionDependencies,
              projectionTargetBinding.orderedSourceFiles.count == 2,
              correctedNames.allSatisfy({
                  !projectionTargetBinding
                    .directLocalDependencyNames.contains($0)
              }),
              projectionPublicTypeName
                == "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection",
              projectionPublicMethodName == "project",
              projectionInputCarrierTypeName
                == "PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence",
              projectionOutputArtifactSetTypeName
                == "PrimeNativeNeuralGateHistoricalProjectedArtifactSet",
              projectionIsPureInMemoryCodec,
              projectionComponentSyntheticMechanicsCoveredByFocusedTests,
              projectionFocusedSyntheticMechanicsTestSource.validate(),
              projectionFocusedSyntheticMechanicsTestSource
                .primeRelativePath
                == "Tests/PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjectionTests/PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjectionTests.swift",
              exactFocusedSyntheticMechanicsTestMethodCount == 15,
              !projectionPublicEntryPointRuntimeExercised,
              !syntheticTestsAreHistoricalEvidence,
              exactProjectedArtifactCountPerRole == 22,
              exactProjectedArtifactCountAcrossRoles == 44,
              redundantFingerprintFieldsOmittedAfterExactCanonicalReconstruction,
              !nonDerivableCarrierInformationDropped,
              !carrierInformationDefaulted,
              !seedOrStatisticalReductionApplied,
              workerTargetName
                == topology.historicalContainmentRootTargetName,
              workerDirectLocalDependencyNames
                == (try topology.target(
                    named: workerTargetName
                )).directLocalDependencyNames,
              !workerDirectLocalDependencyNames.contains(
                  projectionTargetBinding.targetName
              ),
              !workerSourceChanged,
              !workerDependenciesChanged,
              !workerCallGraphChanged,
              workerMainUnavailable,
              unavailableExitStatus == 78,
              !workerMayReachProjectionTarget,
              !projectionMayReachWorkerTarget,
              !replayTransportIntegratedWithProjection,
              !workerRequestHandlingEnabled,
              !workerSealed,
              !workerLaunched,
              !workerExecuted,
              !exporterInvoked,
              !projectionInvoked,
              !historicalGateExecuted,
              !historicalEvidenceObserved,
              !artifactWritePerformed,
              !evidencePublished,
              !durablePublicationObserved,
              !modelExecutionObserved,
              !mechanicsPassAuthorized,
              !terminalReceiptAuthorized,
              !sourceBindingV7Issued,
              !scientificAuthorityAuthorized,
              !productAuthorityAuthorized,
              !nextImplementationPrerequisite.isEmpty,
              !authorityStatement.isEmpty
        else {
            throw PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjectionSourceContractError
                .invalidFrozenContract
        }
    }

    public func contentSHA256() throws -> String {
        try validate()
        return PrimeSHA256.hexDigest(
            of: try PrimeCanonicalJSON.encode(self)
        )
    }

    private static func file(
        _ path: String,
        _ byteCount: UInt64,
        _ sha256: String
    ) -> PrimeNativeNeuralGateHistoricalProjectionSourceFileIdentity {
        .init(
            primeRelativePath: path,
            byteCount: byteCount,
            sha256: sha256
        )
    }

    private static func target(
        _ name: String,
        _ dependencies: [String],
        _ sourceFiles:
            [PrimeNativeNeuralGateHistoricalProjectionSourceFileIdentity]
    ) -> PrimeNativeNeuralGateHistoricalProjectionTargetBinding {
        .init(
            targetName: name,
            directLocalDependencyNames: dependencies,
            orderedSourceFiles: sourceFiles
        )
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case contractID = "contract_id"
        case rightsHolder = "rights_holder"
        case licenseExpression = "license_expression"
        case preservedDesignV15ID = "preserved_design_v15_id"
        case preservedDesignV15SHA256 =
            "preserved_design_v15_sha256"
        case preservedTopologyV15ID = "preserved_topology_v15_id"
        case preservedTopologyV15SHA256 =
            "preserved_topology_v15_sha256"
        case preservedNamespaceV4ID = "preserved_namespace_v4_id"
        case preservedNamespaceV4SHA256 =
            "preserved_namespace_v4_sha256"
        case preservedSemanticRecordV8ID =
            "preserved_semantic_record_v8_id"
        case preservedSemanticRecordV8SHA256 =
            "preserved_semantic_record_v8_sha256"
        case preservedExporterV13ID = "preserved_exporter_v13_id"
        case preservedExporterV13SHA256 =
            "preserved_exporter_v13_sha256"
        case preservedWorkerCallEdgeV14ID =
            "preserved_worker_call_edge_v14_id"
        case preservedWorkerCallEdgeV14SHA256 =
            "preserved_worker_call_edge_v14_sha256"
        case completeHistoricalNamespaceContractID =
            "complete_historical_namespace_contract_id"
        case completeHistoricalNamespaceContractSHA256 =
            "complete_historical_namespace_contract_sha256"
        case completeHistoricalNamespaceSource =
            "complete_historical_namespace_source"
        case priorNamespaceChanged = "prior_namespace_changed"
        case exactNamespaceSpecificationCount =
            "exact_namespace_specification_count"
        case exactNamespaceSpecificationCountPerRole =
            "exact_namespace_specification_count_per_role"
        case exactHistoricalRoleCount = "exact_historical_role_count"
        case exactInvariantChunkCountPerRole =
            "exact_invariant_chunk_count_per_role"
        case namespaceComplete = "namespace_complete"
        case namespaceAuthorizing = "namespace_authorizing"
        case admittedHistoricalSeeds = "admitted_historical_seeds"
        case statisticsEnvelopeSchemaID =
            "statistics_envelope_schema_id"
        case statisticsJoinPolicyID = "statistics_join_policy_id"
        case exactSeedCount = "exact_seed_count"
        case heldoutFamilyRetainedPerSeed =
            "heldout_family_retained_per_seed"
        case fixedPromptFamilyRetainedPerSeed =
            "fixed_prompt_family_retained_per_seed"
        case capabilityFamilyRetainedPerSeed =
            "capability_family_retained_per_seed"
        case seedJoinIsExplicitlyKeyed =
            "seed_join_is_explicitly_keyed"
        case positionalSeedJoinPermitted =
            "positional_seed_join_permitted"
        case seedReductionApplied = "seed_reduction_applied"
        case summaryMaySupplyEvidence = "summary_may_supply_evidence"
        case correctedMutationOwnershipV2ID =
            "corrected_mutation_ownership_v2_id"
        case correctedMutationOwnershipV2SHA256 =
            "corrected_mutation_ownership_v2_sha256"
        case mutationRecordOriginalTargetName =
            "mutation_record_original_target_name"
        case mutationRecordOriginalSourceRelativePath =
            "mutation_record_original_source_relative_path"
        case correctedMutationRecordTargetBinding =
            "corrected_mutation_record_target_binding"
        case mutationRecordSourceMovedByteForByte =
            "mutation_record_source_moved_byte_for_byte"
        case mutationRecordSourceAccessChanged =
            "mutation_record_source_access_changed"
        case semanticRecordTargetBinding =
            "semantic_record_target_binding"
        case historicalObservedFailureLegValidationPolicyID =
            "historical_observed_failure_leg_validation_policy_id"
        case observedFailureLegsUseFrozenHistoricalCriticalLegDomain =
            "observed_failure_legs_use_frozen_historical_critical_leg_domain"
        case uppercaseHistoricalNLFailureLegIDsPreserved =
            "uppercase_historical_nl_failure_leg_ids_preserved"
        case unknownHistoricalFailureLegIDsRejected =
            "unknown_historical_failure_leg_ids_rejected"
        case semanticV8CanonicalBytesChanged =
            "semantic_v8_canonical_bytes_changed"
        case projectionTargetBinding = "projection_target_binding"
        case projectionPublicTypeName = "projection_public_type_name"
        case projectionPublicMethodName = "projection_public_method_name"
        case projectionInputCarrierTypeName =
            "projection_input_carrier_type_name"
        case projectionOutputArtifactSetTypeName =
            "projection_output_artifact_set_type_name"
        case projectionIsPureInMemoryCodec =
            "projection_is_pure_in_memory_codec"
        case projectionComponentSyntheticMechanicsCoveredByFocusedTests =
            "projection_component_synthetic_mechanics_covered_by_focused_tests"
        case projectionFocusedSyntheticMechanicsTestSource =
            "projection_focused_synthetic_mechanics_test_source"
        case exactFocusedSyntheticMechanicsTestMethodCount =
            "exact_focused_synthetic_mechanics_test_method_count"
        case projectionPublicEntryPointRuntimeExercised =
            "projection_public_entry_point_runtime_exercised"
        case syntheticTestsAreHistoricalEvidence =
            "synthetic_tests_are_historical_evidence"
        case exactProjectedArtifactCountPerRole =
            "exact_projected_artifact_count_per_role"
        case exactProjectedArtifactCountAcrossRoles =
            "exact_projected_artifact_count_across_roles"
        case redundantFingerprintFieldsOmittedAfterExactCanonicalReconstruction =
            "redundant_fingerprint_fields_omitted_after_exact_canonical_reconstruction"
        case nonDerivableCarrierInformationDropped =
            "non_derivable_carrier_information_dropped"
        case carrierInformationDefaulted =
            "carrier_information_defaulted"
        case seedOrStatisticalReductionApplied =
            "seed_or_statistical_reduction_applied"
        case workerTargetName = "worker_target_name"
        case workerDirectLocalDependencyNames =
            "worker_direct_local_dependency_names"
        case workerSourceChanged = "worker_source_changed"
        case workerDependenciesChanged = "worker_dependencies_changed"
        case workerCallGraphChanged = "worker_call_graph_changed"
        case workerMainUnavailable = "worker_main_unavailable"
        case unavailableExitStatus = "unavailable_exit_status"
        case workerMayReachProjectionTarget =
            "worker_may_reach_projection_target"
        case projectionMayReachWorkerTarget =
            "projection_may_reach_worker_target"
        case replayTransportIntegratedWithProjection =
            "replay_transport_integrated_with_projection"
        case workerRequestHandlingEnabled =
            "worker_request_handling_enabled"
        case workerSealed = "worker_sealed"
        case workerLaunched = "worker_launched"
        case workerExecuted = "worker_executed"
        case exporterInvoked = "exporter_invoked"
        case projectionInvoked = "projection_invoked"
        case historicalGateExecuted = "historical_gate_executed"
        case historicalEvidenceObserved =
            "historical_evidence_observed"
        case artifactWritePerformed = "artifact_write_performed"
        case evidencePublished = "evidence_published"
        case durablePublicationObserved =
            "durable_publication_observed"
        case modelExecutionObserved = "model_execution_observed"
        case mechanicsPassAuthorized = "mechanics_pass_authorized"
        case terminalReceiptAuthorized = "terminal_receipt_authorized"
        case sourceBindingV7Issued = "source_binding_v7_issued"
        case scientificAuthorityAuthorized =
            "scientific_authority_authorized"
        case productAuthorityAuthorized = "product_authority_authorized"
        case nextImplementationPrerequisite =
            "next_implementation_prerequisite"
        case authorityStatement = "authority_statement"
    }
}
