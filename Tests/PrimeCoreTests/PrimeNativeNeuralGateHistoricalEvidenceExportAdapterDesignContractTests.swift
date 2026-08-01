import Foundation
@testable import PrimeCore
import XCTest

final class
    PrimeNativeNeuralGateHistoricalEvidenceExportAdapterDesignContractTests:
    XCTestCase
{
    private typealias Contract =
        PrimeNativeNeuralGateHistoricalEvidenceExportAdapterDesignContract
    private typealias Topology =
        PrimeNativeNeuralGateTrapDisjointTopologyContract

    private static let donorRootEnvironmentKey =
        "PRIME_PMHNP_COMPANION_ROOT"
    private static let donorRequirementEnvironmentKey =
        "PRIME_REQUIRE_V12_HISTORICAL_EVIDENCE_EXPORT_SOURCE_GATE"

    private enum DonorGatePolicyError:
        Error,
        Equatable
    {
        case invalidRequirementValue(String)
        case requiredRootMissing
    }

    func testFrozenDesignBindsRealityAndAuthorityCeiling()
        throws
    {
        let contract = Contract.frozenV1

        XCTAssertNoThrow(try contract.validate())
        XCTAssertEqual(contract.schemaVersion, 1)
        XCTAssertEqual(
            contract.contractID,
            "prime_source_bound_historical_evidence_export_adapter_design_v12"
        )
        XCTAssertEqual(contract.rightsHolder, "Ergentics, LLC")
        XCTAssertEqual(
            contract.licenseExpression,
            "LicenseRef-Ergentics-Proprietary"
        )
        XCTAssertEqual(contract.donorGateLineCount, 9_242)
        XCTAssertEqual(contract.donorGateByteCount, 368_918)
        XCTAssertEqual(
            contract.donorGateSHA256,
            "c3c93c637cb15f3a6944e78d8d44c0045f873f7df54f6121ee2d25e4f166b0f6"
        )
        XCTAssertEqual(
            contract.namespaceBasisDerivation
                .expectedOutputByteCount,
            368_953
        )
        XCTAssertEqual(
            contract.namespaceBasisDerivation
                .expectedOutputSHA256,
            "c323aab1b3f01c78552ee30e5d50c2c7974a1d846121d887dc5f005f6a89cd31"
        )
        XCTAssertEqual(
            contract.requiredEvidenceFields.map(\.ordinal),
            Array(1 ... 9)
        )
        XCTAssertEqual(
            contract.requiredEvidenceFields.map(\.fieldID),
            [
                "ordered_invariant_records",
                "ordered_invariant_record_ascii_flags",
                "baseline_invariant_bundle",
                "ordered_mutation_identities",
                "per_mutation_stream_identities",
                "per_mutation_fingerprints",
                "per_mutation_observed_failed_leg_ids",
                "historical_critical_leg_values",
                "historical_statistics_and_verdict_values",
            ]
        )
        XCTAssertEqual(
            contract.observedFailureDomain
                .orderedPrimitiveLegIDs.count,
            9
        )
        XCTAssertEqual(
            contract.observedFailureDomain
                .mutationSweepMetaLegID,
            "NL10_mutation_synthesis"
        )
        XCTAssertTrue(
            contract.observedFailureDomain
                .mutationSweepMetaLegExcludedFromPerMutationRegrade
        )
        XCTAssertTrue(
            contract.observedFailureDomain
                .allowedSetMustEqualExpectedSingleton
        )
        XCTAssertTrue(
            contract.observedFailureDomain
                .observedSetMustEqualAllowedSet
        )
        XCTAssertFalse(
            contract.observedFailureDomain
                .expectedLegSingletonMayStandInForObservedSet
        )
        XCTAssertEqual(
            contract.mutationFailurePolicies.count,
            46
        )
        XCTAssertTrue(
            contract.mutationFailurePolicies.allSatisfy {
                $0.orderedAllowedFailedLegIDs
                    == [$0.expectedFailedLegID]
                    && !$0.allowedSetMayBeWidenedAtRuntime
                    && !$0.allowedSetMayStandInForObservedSet
            }
        )
        XCTAssertEqual(
            contract.exactHistoricalInvariantRecordCount,
            59_497
        )
        XCTAssertEqual(
            contract.exactHistoricalInvariantChunkCount,
            15
        )
        XCTAssertEqual(
            contract.finalInvariantChunkRecordCount,
            2_153
        )
        XCTAssertEqual(
            contract.exactHistoricalMutationCount,
            46
        )
        XCTAssertEqual(
            contract.completeMaterialsBridgeFieldCount,
            12
        )
        XCTAssertEqual(
            contract.materialsBridgeFields.map(
                \.sourceFieldName
            ),
            [
                "reportData",
                "tokenizerManifestData",
                "corpusManifestData",
                "packageResolvedArtifactBinding",
                "probeTokenManifestDataBySeed",
                "evaluationShardDataBySeed",
                "executorArtifactDataByFileName",
                "recommenderArtifactDataByFileName",
                "checkpointArtifactBindingBySeed",
                "metalLibraryArtifactBindingBySeed",
                "trainingStageArtifactDataBySeed",
                "configurationArtifactDataBySeed",
            ]
        )
        XCTAssertTrue(
            contract.materialsBridgeFields.allSatisfy {
                $0.destinationParameterName
                    == $0.sourceFieldName
                    && $0.bridgeMustPassExplicitValue
                    && $0.identityMappingRequired
            }
        )
        XCTAssertEqual(
            contract.derivedMaterialsCacheKeyFieldName,
            "exactArtifactCacheKey"
        )
        XCTAssertTrue(
            contract
                .derivedMaterialsCacheKeyExcludedFromBridgeCount
        )

        XCTAssertTrue(contract.completeMaterialsBridgeRequired)
        XCTAssertFalse(contract.bridgeMayDropOrDefaultFields)
        XCTAssertTrue(contract.fullSourceDerivedVariantRequired)
        XCTAssertFalse(contract.thinWrapperPermitted)
        XCTAssertFalse(
            contract.compactReconstructionKernelPermitted
        )
        XCTAssertFalse(
            contract.reflectionOrUnsafeMemoryAccessPermitted
        )
        XCTAssertFalse(contract.donorAccessLevelMutationPermitted)
        XCTAssertFalse(
            contract.originalByteExactGateMutationPermitted
        )
        XCTAssertFalse(contract.exporterCarrierCodable)
        XCTAssertTrue(contract.exporterCarrierRoleNeutral)
        XCTAssertTrue(contract.exporterCarrierPathFree)
        XCTAssertTrue(contract.exporterCarrierTimingFree)
        XCTAssertTrue(contract.exporterCarrierAuthorityFree)
        XCTAssertTrue(
            contract.sameFamilyHistoricalReconstructionOnly
        )
        XCTAssertTrue(contract.namespaceBasisSourceBound)
        XCTAssertFalse(contract.exporterSuffixSourceBound)
        XCTAssertFalse(contract.finalDerivedSourceIdentityBound)
        XCTAssertFalse(contract.futureTargetMaterialized)
        XCTAssertFalse(contract.packageGraphChanged)
        XCTAssertFalse(contract.workerSourceChanged)
        XCTAssertTrue(contract.workerMainUnavailable)

        for observation in [
            contract.workerInvoked,
            contract.historicalGateExecuted,
            contract.historicalEvidenceObserved,
            contract.durablePublicationObserved,
            contract.independentDetectionEstablished,
            contract.distinctImplementationFamiliesEstablished,
            contract.agentContractKitFourTierAuditPerformed,
            contract.mechanicsPassAuthorized,
            contract.terminalReceiptAuthorized,
            contract.sourceBindingV7Issued,
            contract.scientificAuthorityAuthorized,
            contract.productAuthorityAuthorized,
        ] {
            XCTAssertFalse(observation)
        }
        XCTAssertEqual(
            contract.nextImplementationPrerequisite,
            "materialize_the_exact_source_bound_historical_evidence_export_variant_in_the_isolated_historical_replay_boundary_without_executing_the_gate_or_worker_sealing_or_launching_a_worker_or_issuing_source_binding_v7"
        )
        XCTAssertEqual(
            try contract.contentSHA256(),
            "e3305d5ee4054c977a7cb006dc2f1b38c169f5b1e2d905f568cf31166f803e8d"
        )
        XCTAssertEqual(
            try PrimeCanonicalJSON.decode(
                Contract.self,
                from: PrimeCanonicalJSON.encode(contract)
            ),
            contract
        )
    }

    func testNamespaceBasisDerivesExactlyFromCheckedInGate()
        throws
    {
        let contract = Contract.frozenV1
        let donor = try Data(
            contentsOf: repositoryRoot.appendingPathComponent(
                contract.checkedInByteExactGateRelativePath
            )
        )
        let first = try deriveNamespaceBasis(
            donor,
            contract: contract
        )
        let second = try deriveNamespaceBasis(
            donor,
            contract: contract
        )

        XCTAssertEqual(first, second)
        XCTAssertEqual(first.count, 368_953)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: first),
            "c323aab1b3f01c78552ee30e5d50c2c7974a1d846121d887dc5f005f6a89cd31"
        )
        let source = try XCTUnwrap(
            String(data: first, encoding: .utf8)
        )
        XCTAssertTrue(
            source.contains(
                "enum PrimeNeuralNativeLanguageVerifyAbstainGateEvidenceExportAdapter {"
            )
        )
        XCTAssertFalse(
            source.contains(
                "public enum PrimeNeuralNativeLanguageVerifyAbstainGate {"
            )
        )
    }

    func testNamespaceDerivationRejectsAnyDonorDrift()
        throws
    {
        let contract = Contract.frozenV1
        let donor = try Data(
            contentsOf: repositoryRoot.appendingPathComponent(
                contract.checkedInByteExactGateRelativePath
            )
        )
        var byteMutation = donor
        byteMutation[byteMutation.startIndex] ^= 0x01
        XCTAssertThrowsError(
            try deriveNamespaceBasis(
                byteMutation,
                contract: contract
            )
        )
        XCTAssertThrowsError(
            try deriveNamespaceBasis(
                Data(donor.dropLast()),
                contract: contract
            )
        )
        var carriageReturn = donor
        carriageReturn.insert(0x0d, at: carriageReturn.startIndex)
        XCTAssertThrowsError(
            try deriveNamespaceBasis(
                carriageReturn,
                contract: contract
            )
        )
    }

    func testPinnedDonorGateMatchesWhenV12GateIsRequired()
        throws
    {
        let environment = ProcessInfo.processInfo.environment
        guard let rootValue = try pinnedCompanionRoot(
            from: environment
        ) else {
            throw XCTSkip(
                "standalone mode: set PRIME_PMHNP_COMPANION_ROOT to run the V12 pinned donor source gate"
            )
        }
        let root = URL(fileURLWithPath: rootValue)
            .standardizedFileURL
        let contract = Contract.frozenV1
        let donor = try Data(
            contentsOf: root.appendingPathComponent(
                contract.donorGateRepositoryRelativePath
            )
        )

        XCTAssertEqual(
            try gitOutput(["rev-parse", "HEAD"], root: root),
            contract.companionRevision
        )
        XCTAssertEqual(
            try gitOutput(["rev-parse", "HEAD^{tree}"], root: root),
            contract.companionTreeOID
        )
        XCTAssertEqual(
            try gitOutput(
                [
                    "rev-parse",
                    "HEAD:\(contract.donorGateRepositoryRelativePath)",
                ],
                root: root
            ),
            contract.donorGateGitBlobOID
        )
        XCTAssertEqual(UInt64(donor.count), 368_918)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: donor),
            contract.donorGateSHA256
        )
        XCTAssertNoThrow(
            try deriveNamespaceBasis(
                donor,
                contract: contract
            )
        )
    }

    func testV12DonorRequirementPolicyFailsClosed()
        throws
    {
        XCTAssertNil(try pinnedCompanionRoot(from: [:]))
        XCTAssertEqual(
            try pinnedCompanionRoot(
                from: [
                    Self.donorRootEnvironmentKey:
                        "/pinned/companion",
                ]
            ),
            "/pinned/companion"
        )
        XCTAssertEqual(
            try pinnedCompanionRoot(
                from: [
                    Self.donorRequirementEnvironmentKey: "1",
                    Self.donorRootEnvironmentKey:
                        "/pinned/companion",
                ]
            ),
            "/pinned/companion"
        )
        XCTAssertThrowsError(
            try pinnedCompanionRoot(
                from: [
                    Self.donorRequirementEnvironmentKey:
                        "true",
                ]
            )
        ) { error in
            XCTAssertEqual(
                error as? DonorGatePolicyError,
                .invalidRequirementValue("true")
            )
        }
        for environment: [String: String] in [
            [Self.donorRequirementEnvironmentKey: "1"],
            [
                Self.donorRequirementEnvironmentKey: "1",
                Self.donorRootEnvironmentKey: "",
            ],
        ] {
            XCTAssertThrowsError(
                try pinnedCompanionRoot(
                    from: environment
                )
            ) { error in
                XCTAssertEqual(
                    error as? DonorGatePolicyError,
                    .requiredRootMissing
                )
            }
        }
    }

    func testPrivateEvidenceLossAndUnavailableWorkerRemainExact()
        throws
    {
        let contract = Contract.frozenV1
        let gateData = try Data(
            contentsOf: repositoryRoot.appendingPathComponent(
                contract.checkedInByteExactGateRelativePath
            )
        )
        XCTAssertEqual(UInt64(gateData.count), 368_918)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: gateData),
            contract.checkedInByteExactGateSHA256
        )
        let gateSource = try XCTUnwrap(
            String(data: gateData, encoding: .utf8)
        )
        let compactGateSource = String(
            gateSource.filter { !$0.isWhitespace }
        )
        for privateAnchor in [
            "private struct Evaluation {",
            "private struct InvariantRecordCollection {",
            "private struct MutationSweepRun {",
            "private static func evaluate(",
            "private static func invariantRecords(",
            "private static func mutationSweep(",
            "private static func namedLegFails(",
            "private static func mutatedReports(",
        ] {
            XCTAssertTrue(
                gateSource.contains(privateAnchor),
                privateAnchor
            )
        }
        let mutationResultStart = try XCTUnwrap(
            gateSource.range(
                of: "public struct MutationResult:"
            )
        ).lowerBound
        let mutationSweepStart = try XCTUnwrap(
            gateSource.range(
                of: "public struct MutationSweep:",
                range: mutationResultStart..<gateSource.endIndex
            )
        ).lowerBound
        let mutationResultSource =
            gateSource[mutationResultStart..<mutationSweepStart]
        XCTAssertFalse(
            mutationResultSource.contains("mutatedFingerprint")
        )
        XCTAssertFalse(
            mutationResultSource.contains("observedFailedLeg")
        )
        let compactTypeByID = [
            "array_data": "[Data]",
            "optional_data": "Data?",
            "optional_observed_package_resolved_binding":
                "ObservedPackageResolvedBinding?",
            "dictionary_int_data": "[Int:Data]",
            "dictionary_int_dictionary_string_data":
                "[Int:[String:Data]]",
            "dictionary_string_data": "[String:Data]",
            "dictionary_int_observed_checkpoint_binding":
                "[Int:ObservedCheckpointBinding]",
            "dictionary_int_observed_metal_library_binding":
                "[Int:ObservedMetalLibraryBinding]",
        ]
        for field in contract.materialsBridgeFields {
            let type = try XCTUnwrap(
                compactTypeByID[field.swiftTypeID],
                field.swiftTypeID
            )
            let declaration =
                "publiclet\(field.sourceFieldName):\(type)"
            XCTAssertGreaterThanOrEqual(
                compactGateSource.components(
                    separatedBy: declaration
                ).count - 1,
                1,
                field.sourceFieldName
            )
            XCTAssertTrue(
                compactGateSource.contains(
                    "\(field.destinationParameterName):\(type)"
                ),
                field.destinationParameterName
            )
        }
        XCTAssertTrue(
            compactGateSource.contains(
                "fileprivateletexactArtifactCacheKey:String"
            )
        )
        XCTAssertFalse(
            contract.materialsBridgeFields.map(
                \.sourceFieldName
            ).contains("exactArtifactCacheKey")
        )

        let package = try String(
            contentsOf:
                repositoryRoot.appendingPathComponent(
                    "Package.swift"
                ),
            encoding: .utf8
        )
        XCTAssertFalse(
            package.contains(contract.futureIsolatedTargetName)
        )
        XCTAssertFalse(
            FileManager.default.fileExists(
                atPath: repositoryRoot.appendingPathComponent(
                    contract.futureDerivedSourceRelativePath
                ).path
            )
        )

        let workerPath =
            PrimeNativeNeuralGateHistoricalFixtureWorkerSourceContract
            .frozenV1.materialPins[1].primeRelativePath
        let worker = try String(
            contentsOf:
                repositoryRoot.appendingPathComponent(workerPath),
            encoding: .utf8
        )
        XCTAssertFalse(
            worker.contains(
                contract.futureDerivedTopLevelTypeName
            )
        )
        let compactWorker = String(
            worker.filter { !$0.isWhitespace }
        )
        let mainStart = try XCTUnwrap(
            compactWorker.range(of: "staticfuncmain(){")
        ).upperBound
        let mainEnd = try XCTUnwrap(
            compactWorker.range(
                of: "}",
                range: mainStart..<compactWorker.endIndex
            )
        ).lowerBound
        XCTAssertEqual(
            compactWorker[mainStart..<mainEnd],
            "Darwin.exit(unavailableExitStatus)"
        )
    }

    func testTopologyV12ChangesNoPackageReachability()
        throws
    {
        let previous = Topology.frozenV11
        let contract = Topology.frozenV12

        XCTAssertNoThrow(try previous.validate())
        XCTAssertNoThrow(try contract.validate())
        XCTAssertEqual(contract.schemaVersion, 12)
        XCTAssertEqual(
            contract.contractID,
            "prime_stage_b_source_bound_historical_evidence_export_adapter_topology_v12"
        )
        XCTAssertEqual(contract.targetGraph, previous.targetGraph)
        XCTAssertEqual(
            contract.forbiddenReachability,
            previous.forbiddenReachability
        )
        XCTAssertEqual(contract.status, .plannedNotMaterialized)
        XCTAssertFalse(contract.executionImplemented)
        XCTAssertFalse(contract.sourceBindingV7Issued)
        XCTAssertEqual(
            contract.nextImplementationPrerequisite,
            Contract.frozenV1.nextImplementationPrerequisite
        )
        XCTAssertEqual(
            contract.historicalEvidenceExportDesignContractID,
            Contract.frozenV1.contractID
        )
        XCTAssertEqual(
            contract
                .historicalEvidenceExportDesignContractSHA256,
            try Contract.frozenV1.contentSHA256()
        )
        XCTAssertNil(
            previous.historicalEvidenceExportDesignContractID
        )
        XCTAssertNil(
            previous
                .historicalEvidenceExportDesignContractSHA256
        )
        XCTAssertTrue(
            contract.authorityStatement.contains(
                "thin wrapper cannot recover"
            )
        )
        XCTAssertTrue(
            contract.authorityStatement.contains(
                "worker main remains unavailable with status 78"
            )
        )
        XCTAssertEqual(
            try contract.contentSHA256(),
            "335e6d54a94305ee2976c9433d0b5570cdd0f67ca8fea0fa00c8dd9f12eaebbe"
        )
    }

    func testTopologyV12CodableDesignBindingFailsClosed()
        throws
    {
        let contract = Topology.frozenV12
        let data = try PrimeCanonicalJSON.encode(contract)
        XCTAssertEqual(
            try PrimeCanonicalJSON.decode(
                Topology.self,
                from: data
            ),
            contract
        )
        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: data)
                as? [String: Any]
        )
        let binding = try XCTUnwrap(
            object[
                "historical_evidence_export_design_contract_binding"
            ] as? [String: Any]
        )
        XCTAssertEqual(
            binding["contract_id"] as? String,
            Contract.frozenV1.contractID
        )
        XCTAssertEqual(
            binding["content_sha256"] as? String,
            try Contract.frozenV1.contentSHA256()
        )

        var mutations: [[String: Any]] = []
        do {
            var mutation = object
            mutation.removeValue(
                forKey:
                    "historical_evidence_export_design_contract_binding"
            )
            mutations.append(mutation)
        }
        do {
            var mutation = object
            var changedBinding = binding
            changedBinding["content_sha256"] =
                String(repeating: "0", count: 64)
            mutation[
                "historical_evidence_export_design_contract_binding"
            ] = changedBinding
            mutations.append(mutation)
        }

        for object in mutations {
            let decoded = try JSONDecoder().decode(
                Topology.self,
                from: JSONSerialization.data(
                    withJSONObject: object,
                    options: [.sortedKeys]
                )
            )
            XCTAssertThrowsError(try decoded.validate())
        }
    }

    func testDecodedDesignMutationsFailClosedWithoutIndexing()
        throws
    {
        let data = try PrimeCanonicalJSON.encode(
            Contract.frozenV1
        )
        let canonicalObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: data)
                as? [String: Any]
        )
        var mutations: [[String: Any]] = []

        for count in [0, 1, 8] {
            var object = canonicalObject
            let fields = try XCTUnwrap(
                object["required_evidence_fields"]
                    as? [[String: Any]]
            )
            object["required_evidence_fields"] =
                Array(fields.prefix(count))
            mutations.append(object)
        }
        do {
            var object = canonicalObject
            var domain = try XCTUnwrap(
                object["observed_failure_domain"]
                    as? [String: Any]
            )
            domain["ordered_primitive_leg_ids"] = []
            object["observed_failure_domain"] = domain
            mutations.append(object)
        }
        do {
            var object = canonicalObject
            let policies = try XCTUnwrap(
                object["mutation_failure_policies"]
                    as? [[String: Any]]
            )
            object["mutation_failure_policies"] =
                Array(policies.dropLast())
            mutations.append(object)
        }
        do {
            var object = canonicalObject
            var policies = try XCTUnwrap(
                object["mutation_failure_policies"]
                    as? [[String: Any]]
            )
            policies[0]["ordered_allowed_failed_leg_ids"] = [
                "NL1_canonical_material_reload",
                "NL2_finite_field_sz_pool_expansion",
            ]
            object["mutation_failure_policies"] = policies
            mutations.append(object)
        }
        do {
            var object = canonicalObject
            let fields = try XCTUnwrap(
                object["materials_bridge_fields"]
                    as? [[String: Any]]
            )
            object["materials_bridge_fields"] =
                Array(fields.dropLast())
            mutations.append(object)
        }
        do {
            var object = canonicalObject
            var fields = try XCTUnwrap(
                object["materials_bridge_fields"]
                    as? [[String: Any]]
            )
            fields[0]["destination_parameter_name"] =
                "tokenizerManifestData"
            object["materials_bridge_fields"] = fields
            mutations.append(object)
        }
        for promotedKey in [
            "thin_wrapper_permitted",
            "compact_reconstruction_kernel_permitted",
            "reflection_or_unsafe_memory_access_permitted",
            "donor_access_level_mutation_permitted",
            "original_byte_exact_gate_mutation_permitted",
            "exporter_suffix_source_bound",
            "future_target_materialized",
            "worker_invoked",
            "historical_gate_executed",
            "independent_detection_established",
            "mechanics_pass_authorized",
            "source_binding_v7_issued",
        ] {
            var object = canonicalObject
            object[promotedKey] = true
            mutations.append(object)
        }
        do {
            var object = canonicalObject
            object[
                "derived_materials_cache_key_excluded_from_bridge_count"
            ] = false
            mutations.append(object)
        }
        do {
            var object = canonicalObject
            var derivation = try XCTUnwrap(
                object["namespace_basis_derivation"]
                    as? [String: Any]
            )
            derivation["rewrites"] = []
            object["namespace_basis_derivation"] = derivation
            mutations.append(object)
        }

        for (index, object) in mutations.enumerated() {
            let decoded = try JSONDecoder().decode(
                Contract.self,
                from: JSONSerialization.data(
                    withJSONObject: object,
                    options: [.sortedKeys]
                )
            )
            XCTAssertThrowsError(
                try decoded.validate(),
                "mutation \(index)"
            )
        }
    }

    private func deriveNamespaceBasis(
        _ donor: Data,
        contract: Contract
    ) throws -> Data {
        guard UInt64(donor.count) == contract.donorGateByteCount,
              PrimeSHA256.hexDigest(of: donor)
                == contract.donorGateSHA256,
              donor.last == 0x0a,
              !donor.contains(0x0d),
              !donor.starts(with: [0xef, 0xbb, 0xbf]),
              var source = String(data: donor, encoding: .utf8)
        else {
            throw DerivationError.invalidDonor
        }
        let lineCount = source.utf8.reduce(into: 0) {
            if $1 == 0x0a { $0 += 1 }
        }
        guard lineCount == contract.donorGateLineCount else {
            throw DerivationError.invalidDonor
        }
        let derivation = contract.namespaceBasisDerivation
        try derivation.validate(
            donorByteCount: contract.donorGateByteCount,
            donorSHA256: contract.donorGateSHA256
        )
        for rewrite in derivation.rewrites {
            let pieces = source.components(
                separatedBy: rewrite.sourceUTF8
            )
            guard pieces.count == 2 else {
                throw DerivationError.invalidRewrite(
                    rewrite.rewriteID
                )
            }
            source = pieces[0]
                + rewrite.replacementUTF8
                + pieces[1]
        }
        let result = Data(source.utf8)
        guard UInt64(result.count)
                == derivation.expectedOutputByteCount,
              PrimeSHA256.hexDigest(of: result)
                == derivation.expectedOutputSHA256
        else {
            throw DerivationError.invalidOutput
        }
        return result
    }

    private func gitOutput(
        _ arguments: [String],
        root: URL
    ) throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["-C", root.path] + arguments
        let output = Pipe()
        let errors = Pipe()
        process.standardOutput = output
        process.standardError = errors
        try process.run()
        process.waitUntilExit()
        guard process.terminationReason == .exit,
              process.terminationStatus == 0
        else {
            let detail = String(
                data: errors.fileHandleForReading.readDataToEndOfFile(),
                encoding: .utf8
            ) ?? "git failed"
            throw DerivationError.gitFailure(detail)
        }
        return String(
            data: output.fileHandleForReading.readDataToEndOfFile(),
            encoding: .utf8
        )!.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func pinnedCompanionRoot(
        from environment: [String: String]
    ) throws -> String? {
        let requirement = environment[
            Self.donorRequirementEnvironmentKey
        ]
        if let requirement, requirement != "1" {
            throw DonorGatePolicyError
                .invalidRequirementValue(requirement)
        }
        let root = environment[
            Self.donorRootEnvironmentKey
        ].flatMap {
            $0.isEmpty ? nil : $0
        }
        if requirement == "1", root == nil {
            throw DonorGatePolicyError.requiredRootMissing
        }
        return root
    }

    private enum DerivationError: Error, Equatable {
        case invalidDonor
        case invalidRewrite(String)
        case invalidOutput
        case gitFailure(String)
    }

    private var repositoryRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
