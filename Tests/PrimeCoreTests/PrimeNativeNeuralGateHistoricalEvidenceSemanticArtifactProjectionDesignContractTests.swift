import Foundation
@testable import PrimeCore
import PrimeNativeNeuralGateReplayArtifactContracts
import PrimeNativeNeuralGateSemanticRecordContracts
import XCTest

final class
    PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjectionDesignContractTests:
    XCTestCase
{
    private typealias Contract =
        PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjectionDesignContract
    private typealias Disposition =
        PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjectionDisposition

    private static let designContractSHA256 =
        "2d7da9703cf710f6f795900d91872780297a0e8d18f345cca302711d7fd0ec27"

    func testFrozenContractBindsExactMappingsBlockersAndAuthorityCeiling()
        throws
    {
        let contract = Contract.frozenV1

        XCTAssertNoThrow(try contract.validate())
        XCTAssertEqual(contract.schemaVersion, 1)
        XCTAssertEqual(
            contract.contractID,
            "prime_source_bound_historical_evidence_semantic_artifact_projection_design_v15"
        )
        XCTAssertEqual(contract.rightsHolder, "Ergentics, LLC")
        XCTAssertEqual(
            contract.licenseExpression,
            "LicenseRef-Ergentics-Proprietary"
        )
        XCTAssertEqual(
            contract.preservedCallEdgeSourceContractSHA256,
            "8112cf3e6190fcd6385614322be11f391bccc1ca411b6af85c7bd8cf57c4a4e8"
        )
        XCTAssertEqual(
            contract.preservedTopologyV14SHA256,
            "4aee5e011a7db85ed74955684f885b03f306e82b8fd4d0f12422d0b791663564"
        )
        XCTAssertEqual(
            contract.preservedExporterSourceContractSHA256,
            "ecc329a7e56d843b53f9d894af4e335c9d00ac05d56efe308d61860835278d5e"
        )
        XCTAssertEqual(
            contract.preservedWorkerContractID,
            "prime_stage_b_historical_fixture_worker_v2"
        )

        XCTAssertEqual(contract.exactCarrierFieldCount, 9)
        XCTAssertEqual(
            contract.carrierFieldProjections.map(
                \.carrierSwiftPropertyName
            ),
            [
                "orderedInvariantRecords",
                "orderedInvariantRecordASCIIFlags",
                "baselineInvariantBundle",
                "orderedMutationIdentities",
                "perMutationStreamIdentities",
                "perMutationFingerprints",
                "perMutationObservedFailedLegIDs",
                "historicalCriticalLegValues",
                "historicalStatisticsAndVerdictValues",
            ]
        )
        XCTAssertEqual(
            contract.carrierFieldProjections.map(
                \.projectionDisposition
            ),
            [
                .exact,
                .validationOnly,
                .exact,
                .exact,
                .exact,
                .exact,
                .exact,
                .exact,
                .blocked,
            ] as [Disposition]
        )
        XCTAssertEqual(
            contract.carrierFieldProjections.last?.blockingReason,
            "lossless_three_seed_to_singular_statistics_projection_not_frozen"
        )
        XCTAssertEqual(
            contract.carrierFieldProjections.first?
                .destinationWorkerArtifactLeafNames,
            [
                "invariant-records.v1.bin",
                "invariant-chunks/{ordinal_8digit}.v1.bin",
            ]
        )

        XCTAssertEqual(
            contract.requiredExternalProjectionContextNames,
            [
                "invocationRole",
                "sourceBytesResolved",
                "adaptationProofRecomputed",
            ]
        )
        XCTAssertEqual(
            contract.externalContextDestinationWorkerArtifactLeafNames,
            ["material-identity-manifest.v1.json"]
        )
        XCTAssertFalse(
            contract.externalProjectionContextMayBeInferredFromCarrier
        )
        XCTAssertTrue(contract.invocationRoleRequired)
        XCTAssertTrue(contract.rolePrefixDerivedFromInvocationRole)

        XCTAssertEqual(contract.workerSemanticFixedLeafPaths.count, 7)
        XCTAssertEqual(contract.exactWorkerInvariantChunkCount, 15)
        XCTAssertEqual(
            contract.exactWorkerSemanticArtifactCountPerRole,
            22
        )
        XCTAssertEqual(
            contract.frozenNamespaceHistoricalKeyCountPerRole,
            3
        )
        XCTAssertEqual(
            contract.frozenNamespaceHistoricalEncoding,
            "reserved_schema_deferred"
        )
        XCTAssertEqual(
            contract.frozenNamespaceHistoricalDecoderMode,
            "schema_deferred"
        )
        XCTAssertFalse(
            contract.frozenNamespaceHistoricalSpecsProjectionReady
        )
        XCTAssertFalse(contract.semanticNamespaceComplete)
        XCTAssertEqual(contract.missingNamespaceFixedLeafPaths.count, 4)
        XCTAssertEqual(
            contract.missingNamespaceDynamicLeafPathPatterns,
            ["invariant-chunks/{ordinal_8digit}.v1.bin"]
        )

        XCTAssertEqual(
            contract.admittedHistoricalSeeds,
            [1_618, 2_718, 3_141]
        )
        XCTAssertFalse(contract.carrierSeedArrayOrderAuthoritative)
        XCTAssertTrue(contract.keyedSeedCanonicalizationDefined)
        XCTAssertEqual(contract.carrierHeldoutStatisticsCount, 3)
        XCTAssertEqual(contract.carrierFixedPromptReplayValueCount, 3)
        XCTAssertEqual(contract.carrierCapabilityValueCount, 3)
        XCTAssertEqual(contract.semanticWeightedStatisticsValueCount, 1)
        XCTAssertEqual(contract.semanticFixedPromptMarginValueCount, 1)
        XCTAssertEqual(contract.semanticCapabilityValueCount, 1)
        XCTAssertFalse(contract.losslessThreeSeedReductionDefined)
        XCTAssertFalse(contract.additiveKeyedThreeSeedEnvelopeDefined)
        XCTAssertFalse(contract.statisticsProjectionLossless)

        XCTAssertTrue(contract.semanticContextFieldPolicyComplete)
        XCTAssertTrue(
            contract.unresolvedSemanticContextFieldNames.isEmpty
        )
        XCTAssertEqual(contract.semanticContextFieldPolicyIDs.count, 10)
        XCTAssertFalse(
            contract.carrierDerivedObservationPromotionPermitted
        )
        for state in [
            contract.materialIdentitySourceBytesResolvedProjectionState,
            contract.materialIdentityAdaptationProofProjectionState,
            contract.criticalLegEvidenceProjectionState,
            contract.descriptorVerificationProjectionState,
            contract.durablePublicationProjectionState,
        ] {
            XCTAssertEqual(state, "unavailable")
        }

        XCTAssertEqual(
            contract.semanticRecordTargetDirectLocalDependencyNames,
            [
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplayMechanics",
                "PrimeNativeNeuralGateCorrectedMutationSurfaceContracts",
            ]
        )
        XCTAssertFalse(
            contract.historicalWorkerMayReachCorrectedMutationSurface
        )
        XCTAssertFalse(
            contract.historicalOnlySemanticProjectionBoundaryAvailable
        )
        XCTAssertFalse(contract.dependencyIsolationComplete)

        XCTAssertTrue(contract.projectionPlanSourceBound)
        for nonclaim in [
            contract.projectionCodecSourceBound,
            contract.projectionTargetMaterialized,
            contract.projectionSourceMaterialized,
            contract.packageGraphChanged,
            contract.workerSourceChanged,
            contract.workerDependenciesChanged,
            contract.workerRequestHandlingEnabled,
            contract.workerSealed,
            contract.workerLaunched,
            contract.workerExecuted,
            contract.fixtureMaterialized,
            contract.exporterInvoked,
            contract.projectionInvoked,
            contract.historicalGateExecuted,
            contract.historicalEvidenceObserved,
            contract.evidenceEncoded,
            contract.artifactBindingsCreated,
            contract.artifactWritePerformed,
            contract.evidencePublished,
            contract.durablePublicationObserved,
            contract.modelExecutionObserved,
            contract.independentDetectionEstablished,
            contract.distinctImplementationFamiliesEstablished,
            contract.agentContractKitFourTierAuditPerformed,
            contract.mechanicsPassAuthorized,
            contract.terminalReceiptAuthorized,
            contract.sourceBindingV7Issued,
            contract.scientificAuthorityAuthorized,
            contract.productAuthorityAuthorized,
        ] {
            XCTAssertFalse(nonclaim)
        }
        XCTAssertTrue(contract.workerMainUnavailable)
        XCTAssertEqual(contract.unavailableExitStatus, 78)
        XCTAssertEqual(
            contract.nextImplementationPrerequisite,
            "freeze_the_complete_non_authorizing_historical_semantic_artifact_namespace_and_additive_keyed_three_seed_statistics_envelope_then_source_bind_a_historical_only_projection_codec_without_enabling_worker_request_handling_sealing_launch_execution_publication_or_issuing_source_binding_v7"
        )
    }

    func testCanonicalRoundTripAndFrozenHashAreExact()
        throws
    {
        let contract = Contract.frozenV1
        let encoded = try PrimeCanonicalJSON.encode(contract)

        XCTAssertEqual(
            try PrimeCanonicalJSON.decode(
                Contract.self,
                from: encoded
            ),
            contract
        )
        XCTAssertEqual(
            try contract.contentSHA256(),
            Self.designContractSHA256
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: encoded),
            Self.designContractSHA256
        )
    }

    func testCrossModuleSemanticAndNamespaceIdentitiesAreExact()
        throws
    {
        let contract = Contract.frozenV1
        let semantic =
            PrimeNativeNeuralGateSemanticRecordContract
            .frozenV1
        let namespace =
            PrimeNativeNeuralGateReplayArtifactOutputContract
            .frozenV4

        XCTAssertNoThrow(try semantic.validate())
        XCTAssertNoThrow(try namespace.validate())
        XCTAssertEqual(
            semantic.contractID,
            contract.preservedSemanticRecordContractID
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(semantic)
            ),
            contract.preservedSemanticRecordContractSHA256
        )
        XCTAssertEqual(
            namespace.contractID,
            contract.preservedSemanticNamespaceContractID
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(namespace)
            ),
            contract.preservedSemanticNamespaceContractSHA256
        )

        for role in PrimeNativeNeuralGateHistoricalArtifactRole.allCases {
            for key in [
                PrimeNativeNeuralGateArtifactKey
                    .historicalMaterialManifest(role),
                .historicalGateObservation(role),
                .historicalMutationObservation(role),
            ] {
                let spec = try namespace.spec(for: key)
                XCTAssertEqual(spec.encoding, .reservedSchemaDeferred)
                XCTAssertEqual(spec.decoderMode, .schemaDeferred)
                XCTAssertFalse(spec.transportCanAuthorizeMechanicsPass)
                XCTAssertFalse(spec.transportCanAuthorizeCapability)
                XCTAssertFalse(spec.transportCanAuthorizeReceipt)
            }
        }

        for role in ["probe", "verifier"] {
            let prefix = "neural-gate-replay/historical/\(role)/"
            for leaf in contract.missingNamespaceFixedLeafPaths {
                XCTAssertFalse(
                    namespace.fixedRelativePaths.contains(prefix + leaf),
                    prefix + leaf
                )
            }
            XCTAssertFalse(
                namespace.dynamicRelativePathPatterns.contains(
                    prefix
                        + contract.workerInvariantChunkLeafPathPattern
                )
            )
        }
    }

    func testArtifactSetDestinationsCoverTheFrozenWorkerInventory()
        throws
    {
        let contract = Contract.frozenV1
        var destinations = Set(
            contract.externalContextDestinationWorkerArtifactLeafNames
        )
        for mapping in contract.carrierFieldProjections {
            destinations.formUnion(
                mapping.destinationWorkerArtifactLeafNames
            )
        }

        XCTAssertEqual(
            destinations,
            Set(
                contract.workerSemanticFixedLeafPaths
                    + [contract.workerInvariantChunkLeafPathPattern]
            )
        )
        XCTAssertEqual(contract.exactProjectionJoinRuleIDs.count, 6)
        XCTAssertTrue(
            contract.exactProjectionJoinRuleIDs.contains(
                "seed_arrays_keyed_and_canonicalized_by_seed_never_positionally_v1"
            )
        )
    }

    func testPackageWorkerAndReservedProjectionAbsenceRemainExact()
        throws
    {
        let contract = Contract.frozenV1
        let package = try checkedInString("Package.swift")
        let primaryPath =
            "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalFixtureWorker.swift"
        let callEdgePath =
            "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalEvidenceExportCallEdge.swift"
        let primary = try checkedInData(primaryPath)
        let callEdge = try checkedInData(callEdgePath)

        XCTAssertEqual(primary.count, 2_298)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: primary),
            "9f62827d4c35e98fb01f9984b1c227cb681dd42ac4c26147a86e9429958545df"
        )
        XCTAssertEqual(callEdge.count, 1_512)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: callEdge),
            "d3ac7fcddd43844e92b61764c458dfce6291471fd465b1bb52f5186814e10319"
        )
        XCTAssertFalse(
            package.contains(contract.reservedProjectionTargetName)
        )
        XCTAssertFalse(
            FileManager.default.fileExists(
                atPath:
                    repositoryRoot.appendingPathComponent(
                        contract.reservedProjectionSourceRelativePath
                    ).path
            )
        )
        XCTAssertEqual(
            try recursiveRegularFilePaths(
                in:
                    repositoryRoot.appendingPathComponent(
                        "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker"
                    )
            ),
            [
                "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/HistoricalFixtureEvidence/Package.resolved",
                callEdgePath,
                primaryPath,
            ]
        )
    }

    func testDecodedMutationsFailClosed() throws {
        let data = try PrimeCanonicalJSON.encode(
            Contract.frozenV1
        )
        let canonicalObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: data)
                as? [String: Any]
        )
        var reorderedMappings = try XCTUnwrap(
            canonicalObject["carrier_field_projections"]
                as? [[String: Any]]
        )
        reorderedMappings.swapAt(0, 1)
        let mutations: [(String, String, Any)] = [
            (
                "mapping-order",
                "carrier_field_projections",
                reorderedMappings
            ),
            (
                "namespace-promotion",
                "semantic_namespace_complete",
                true
            ),
            (
                "keyed-canonicalization-loss",
                "keyed_seed_canonicalization_defined",
                false
            ),
            (
                "invented-envelope",
                "additive_keyed_three_seed_envelope_defined",
                true
            ),
            (
                "context-policy-loss",
                "semantic_context_field_policy_complete",
                false
            ),
            (
                "corrected-surface-reachability",
                "historical_worker_may_reach_corrected_mutation_surface",
                true
            ),
            (
                "projector-materialization",
                "projection_target_materialized",
                true
            ),
            (
                "worker-execution",
                "worker_executed",
                true
            ),
            (
                "publication",
                "evidence_published",
                true
            ),
            (
                "source-binding-authority",
                "source_binding_v7_issued",
                true
            ),
        ]

        for (label, key, value) in mutations {
            var object = canonicalObject
            object[key] = value
            let mutated = try JSONDecoder().decode(
                Contract.self,
                from: JSONSerialization.data(
                    withJSONObject: object,
                    options: [.sortedKeys]
                )
            )
            XCTAssertThrowsError(
                try mutated.validate(),
                label
            ) {
                XCTAssertEqual(
                    $0 as?
                        PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjectionDesignContractError,
                    .invalidFrozenContract,
                    label
                )
            }
        }
    }

    private func checkedInData(
        _ relativePath: String
    ) throws -> Data {
        try Data(
            contentsOf:
                repositoryRoot.appendingPathComponent(
                    relativePath
                )
        )
    }

    private func checkedInString(
        _ relativePath: String
    ) throws -> String {
        try String(
            contentsOf:
                repositoryRoot.appendingPathComponent(
                    relativePath
                ),
            encoding: .utf8
        )
    }

    private func recursiveRegularFilePaths(
        in directory: URL
    ) throws -> [String] {
        let keys: Set<URLResourceKey> = [
            .isDirectoryKey,
            .isRegularFileKey,
            .isSymbolicLinkKey,
        ]
        let enumerator = try XCTUnwrap(
            FileManager.default.enumerator(
                at: directory,
                includingPropertiesForKeys: Array(keys),
                options: []
            )
        )
        let rootPath = repositoryRoot.standardizedFileURL.path
            + "/"
        var paths: [String] = []
        for case let fileURL as URL in enumerator {
            let values = try fileURL.resourceValues(
                forKeys: keys
            )
            let path = fileURL.standardizedFileURL.path
            guard path.hasPrefix(rootPath)
            else {
                throw InventoryError.escape(path)
            }
            let relativePath = String(
                path.dropFirst(rootPath.count)
            )
            if values.isSymbolicLink == true {
                throw InventoryError.symbolicLink(relativePath)
            }
            if values.isRegularFile == true {
                paths.append(relativePath)
                continue
            }
            if values.isDirectory == true {
                continue
            }
            throw InventoryError.unsupportedNode(relativePath)
        }
        return paths.sorted()
    }

    private enum InventoryError: Error {
        case escape(String)
        case symbolicLink(String)
        case unsupportedNode(String)
    }

    private var repositoryRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
