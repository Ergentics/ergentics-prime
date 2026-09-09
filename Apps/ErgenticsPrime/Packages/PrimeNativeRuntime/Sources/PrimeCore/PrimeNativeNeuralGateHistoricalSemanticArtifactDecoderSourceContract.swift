// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

public enum
    PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderSourceContractError:
    Error,
    Equatable,
    Sendable
{
    case invalidFrozenContract
}

public struct
    PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderSourceIdentity:
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

public struct
    PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderTargetBinding:
    Codable,
    Equatable,
    Sendable
{
    public let targetName: String
    public let directLocalDependencyNames: [String]
    public let orderedSourceFiles:
        [PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderSourceIdentity]
    public let targetKind: String
    public let copiedResourceRelativePaths: [String]
    public let externalProductDependencyNames: [String]
    public let productDeclared: Bool
    public let executableDeclared: Bool
    public let completeTargetInventoryBound: Bool

    fileprivate init(
        targetName: String,
        directLocalDependencyNames: [String],
        orderedSourceFiles:
            [PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderSourceIdentity]
    ) {
        self.targetName = targetName
        self.directLocalDependencyNames = directLocalDependencyNames
        self.orderedSourceFiles = orderedSourceFiles
        targetKind = "internal_library"
        copiedResourceRelativePaths = []
        externalProductDependencyNames = []
        productDeclared = false
        executableDeclared = false
        completeTargetInventoryBound = true
    }

    fileprivate func validate() -> Bool {
        !targetName.isEmpty
            && !directLocalDependencyNames.isEmpty
            && Set(directLocalDependencyNames).count
                == directLocalDependencyNames.count
            && !orderedSourceFiles.isEmpty
            && Set(orderedSourceFiles.map(\.primeRelativePath)).count
                == orderedSourceFiles.count
            && orderedSourceFiles.allSatisfy { $0.validate() }
            && targetKind == "internal_library"
            && copiedResourceRelativePaths.isEmpty
            && externalProductDependencyNames.isEmpty
            && !productDeclared
            && !executableDeclared
            && completeTargetInventoryBound
    }

    private enum CodingKeys: String, CodingKey {
        case targetName = "target_name"
        case directLocalDependencyNames =
            "direct_local_dependency_names"
        case orderedSourceFiles = "ordered_source_files"
        case targetKind = "target_kind"
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

/// Frozen V18 source boundary for the pure consumer-side historical semantic
/// artifact decoder. The additive statistics wire target deliberately avoids
/// changing or importing the frozen V16 projector. The decoder admits caller-
/// supplied bytes only; it owns no descriptor, filesystem, transport, worker,
/// execution, publication, receipt, scientific, or product authority.
public struct
    PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderSourceContract:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let contractID: String
    public let rightsHolder: String
    public let licenseExpression: String

    public let preservedProjectionSourceV16ContractID: String
    public let preservedProjectionSourceV16ContractSHA256: String
    public let preservedWorkerProjectionCallEdgeV17ContractID: String
    public let preservedWorkerProjectionCallEdgeV17ContractSHA256: String
    public let preservedTopologyV17ID: String
    public let preservedTopologyV17SHA256: String
    public let priorPinnedProducerFilesChanged: Bool

    public let statisticsTargetBinding:
        PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderTargetBinding
    public let decoderTargetBinding:
        PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderTargetBinding
    public let focusedDecoderTestSource:
        PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderSourceIdentity

    public let completeCanonicalJSONLeafCountPerRole: Int
    public let exactArtifactCountPerRole: Int
    public let exactHistoricalRoleCount: Int
    public let exactInvariantRecordCount: Int
    public let exactInvariantChunkCountPerRole: Int
    public let descriptorFeedMaximumByteCount: Int
    public let exactStatisticsSeedCount: Int
    public let exactCapabilitySplitCountPerSeed: Int
    public let exactAbstentionRowCountPerSeed: Int
    public let exactMutationCount: Int
    public let exactCriticalLegCount: Int

    public let foundationCodableOwnsJSONParsing: Bool
    public let customJSONParserImplemented: Bool
    public let existingFramedRecordReaderReused: Bool
    public let customFrameParserImplemented: Bool
    public let canonicalReencodeRequired: Bool
    public let exactKeyedCoverageRequired: Bool
    public let positionalArtifactJoinPermitted: Bool
    public let globalChunkRecordEqualityRequired: Bool
    public let decoderPoisonsAfterFirstFailure: Bool
    public let statisticsProducerDecoderParityTested: Bool
    public let keyedStreamFragmentsRequired: Bool
    public let publicStatisticsDecodableConformanceExposed: Bool
    public let unverifiedRecordCallbackExposed: Bool
    public let materializedAllBinaryArtifactConvenienceExposed: Bool
    public let streamBindingsDerivedAfterTerminalAcceptance: Bool
    public let decoderClosureReachesProjector: Bool
    public let decoderClosureReachesExporterOrRuntime: Bool

    public let descriptorSourceBound: Bool
    public let replayTransportIntegrated: Bool
    public let workerRequestHandlingEnabled: Bool
    public let workerExecuted: Bool
    public let artifactWritePerformed: Bool
    public let evidencePublished: Bool
    public let mechanicsPassAuthorized: Bool
    public let terminalReceiptAuthorized: Bool
    public let sourceBindingV7Issued: Bool
    public let scientificAuthorityAuthorized: Bool
    public let productAuthorityAuthorized: Bool
    public let nextImplementationPrerequisite: String
    public let authorityStatement: String

    public static let frozenV1 = Self(
        schemaVersion: 1,
        contractID:
            "prime_source_bound_historical_semantic_artifact_decoder_v18",
        rightsHolder: "Ergentics, LLC",
        licenseExpression: "LicenseRef-Ergentics-Proprietary",
        preservedProjectionSourceV16ContractID:
            "prime_source_bound_historical_evidence_semantic_artifact_projection_source_v16",
        preservedProjectionSourceV16ContractSHA256:
            "2b9c1565f103622eb82e53e4a83820b98d6dd0d3dfd5487353dde06c5a4fd4dd",
        preservedWorkerProjectionCallEdgeV17ContractID:
            "prime_source_bound_historical_worker_semantic_artifact_projection_call_edge_v17",
        preservedWorkerProjectionCallEdgeV17ContractSHA256:
            "ccf2e46ffc9e980d96357980e128ecb411a5ac5f55b8e783bf611582ec32d6d3",
        preservedTopologyV17ID:
            "prime_stage_b_historical_worker_semantic_artifact_projection_call_edge_source_topology_v17",
        preservedTopologyV17SHA256:
            "3a14288df628b1d44936013af44dd237e876fd1cf2b38e4ce0afd3a4c5cd2166",
        priorPinnedProducerFilesChanged: false,
        statisticsTargetBinding: .init(
            targetName:
                "PrimeNativeNeuralGateHistoricalStatisticsArtifactContracts",
            directLocalDependencyNames: [
                "PrimeNativeNeuralGateReplayArtifactContracts",
            ],
            orderedSourceFiles: [
                .init(
                    primeRelativePath:
                        "Sources/PrimeNativeNeuralGateHistoricalStatisticsArtifactContracts/PrimeNativeNeuralGateHistoricalStatisticsArtifactContracts.swift",
                    byteCount: 28_668,
                    sha256:
                        "11a5d2d2bf82cad49a4767db1fd178422f32cdf0bf49a827f809848e5f50ea05"
                ),
            ]
        ),
        decoderTargetBinding: .init(
            targetName:
                "PrimeNativeNeuralGateHistoricalSemanticArtifactDecoder",
            directLocalDependencyNames: [
                "PrimeNativeNeuralGateHistoricalStatisticsArtifactContracts",
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplayMechanics",
                "PrimeNativeNeuralGateSemanticRecordContracts",
            ],
            orderedSourceFiles: [
                .init(
                    primeRelativePath:
                        "Sources/PrimeNativeNeuralGateHistoricalSemanticArtifactDecoder/PrimeNativeNeuralGateHistoricalSemanticArtifactDecoder.swift",
                    byteCount: 42_068,
                    sha256:
                        "22186320c67246dc0d97528bab2390dc6d95fc80f47b69732b11783957290ab8"
                ),
                .init(
                    primeRelativePath:
                        "Sources/PrimeNativeNeuralGateHistoricalSemanticArtifactDecoder/PrimeNativeNeuralGateHistoricalInvariantArtifactStreamDecoder.swift",
                    byteCount: 23_251,
                    sha256:
                        "3e543a7225afb1eedb8311a34cc995139fc725e1b3ea998fd66149f9783fcb30"
                ),
            ]
        ),
        focusedDecoderTestSource: .init(
            primeRelativePath:
                "Tests/PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderTests/PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderTests.swift",
            byteCount: 63_808,
            sha256:
                "4d3bd9f07eb8c6ab3320e1bde7626c78270009e1d3f8afc43440d36cad3b1b9c"
        ),
        completeCanonicalJSONLeafCountPerRole: 6,
        exactArtifactCountPerRole: 22,
        exactHistoricalRoleCount: 2,
        exactInvariantRecordCount: 59_497,
        exactInvariantChunkCountPerRole: 15,
        descriptorFeedMaximumByteCount: 65_536,
        exactStatisticsSeedCount: 3,
        exactCapabilitySplitCountPerSeed: 5,
        exactAbstentionRowCountPerSeed: 2_048,
        exactMutationCount: 46,
        exactCriticalLegCount: 10,
        foundationCodableOwnsJSONParsing: true,
        customJSONParserImplemented: false,
        existingFramedRecordReaderReused: true,
        customFrameParserImplemented: false,
        canonicalReencodeRequired: true,
        exactKeyedCoverageRequired: true,
        positionalArtifactJoinPermitted: false,
        globalChunkRecordEqualityRequired: true,
        decoderPoisonsAfterFirstFailure: true,
        statisticsProducerDecoderParityTested: true,
        keyedStreamFragmentsRequired: true,
        publicStatisticsDecodableConformanceExposed: false,
        unverifiedRecordCallbackExposed: false,
        materializedAllBinaryArtifactConvenienceExposed: false,
        streamBindingsDerivedAfterTerminalAcceptance: true,
        decoderClosureReachesProjector: false,
        decoderClosureReachesExporterOrRuntime: false,
        descriptorSourceBound: false,
        replayTransportIntegrated: false,
        workerRequestHandlingEnabled: false,
        workerExecuted: false,
        artifactWritePerformed: false,
        evidencePublished: false,
        mechanicsPassAuthorized: false,
        terminalReceiptAuthorized: false,
        sourceBindingV7Issued: false,
        scientificAuthorityAuthorized: false,
        productAuthorityAuthorized: false,
        nextImplementationPrerequisite:
            "source_bind_the_unavailable_historical_worker_already_formed_v16_projected_artifact_set_to_the_complete_v18_historical_semantic_artifact_decoder_call_edge_without_enabling_replay_transport_integration_request_handling_sealing_launch_execution_io_publication_or_issuing_source_binding_v7",
        authorityStatement:
            "This V18 source contract preserves every frozen V16/V17 producer byte and adds a product-free consumer-side typed statistics wire schema plus a pure bounded semantic-artifact decoder. Foundation Codable and the maintained framed reader own parsing; exact canonical bytes, keyed joins, keyed bounded stream fragments, full stream equality, terminally derived stream bindings, and poison-on-failure are required. The statistics envelope exposes no public Decodable conformance, and the stream boundary exposes neither an unverified record callback nor an all-binary-artifact materialization convenience. No descriptor is source-bound, no worker or model executes, no transport or I/O is integrated, no artifact is written or published, and no mechanics PASS, terminal receipt, source binding V7, scientific authority, or product authority is observed or authorized."
    )

    public func validate() throws {
        guard self == .frozenV1,
              schemaVersion == 1,
              rightsHolder == "Ergentics, LLC",
              licenseExpression == "LicenseRef-Ergentics-Proprietary",
              !priorPinnedProducerFilesChanged,
              statisticsTargetBinding.validate(),
              decoderTargetBinding.validate(),
              focusedDecoderTestSource.validate(),
              completeCanonicalJSONLeafCountPerRole == 6,
              exactArtifactCountPerRole == 22,
              exactHistoricalRoleCount == 2,
              exactInvariantRecordCount == 59_497,
              exactInvariantChunkCountPerRole == 15,
              descriptorFeedMaximumByteCount == 65_536,
              exactStatisticsSeedCount == 3,
              exactCapabilitySplitCountPerSeed == 5,
              exactAbstentionRowCountPerSeed == 2_048,
              exactMutationCount == 46,
              exactCriticalLegCount == 10,
              foundationCodableOwnsJSONParsing,
              !customJSONParserImplemented,
              existingFramedRecordReaderReused,
              !customFrameParserImplemented,
              canonicalReencodeRequired,
              exactKeyedCoverageRequired,
              !positionalArtifactJoinPermitted,
              globalChunkRecordEqualityRequired,
              decoderPoisonsAfterFirstFailure,
              statisticsProducerDecoderParityTested,
              keyedStreamFragmentsRequired,
              !publicStatisticsDecodableConformanceExposed,
              !unverifiedRecordCallbackExposed,
              !materializedAllBinaryArtifactConvenienceExposed,
              streamBindingsDerivedAfterTerminalAcceptance,
              !decoderClosureReachesProjector,
              !decoderClosureReachesExporterOrRuntime,
              !descriptorSourceBound,
              !replayTransportIntegrated,
              !workerRequestHandlingEnabled,
              !workerExecuted,
              !artifactWritePerformed,
              !evidencePublished,
              !mechanicsPassAuthorized,
              !terminalReceiptAuthorized,
              !sourceBindingV7Issued,
              !scientificAuthorityAuthorized,
              !productAuthorityAuthorized
        else {
            throw PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderSourceContractError
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
