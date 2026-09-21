import Foundation

public enum PrimeNativeNeuralGateHistoricalReplaySourceKind:
    String,
    Codable,
    Equatable,
    Sendable
{
    case byteExactDonor = "byte_exact_donor"
    case derivedDonor = "derived_donor"
    case primeAuthored = "prime_authored"
    case existingPrimeSource = "existing_prime_source"
}

public struct PrimeNativeNeuralGateHistoricalReplaySourcePin:
    Codable,
    Equatable,
    Sendable
{
    public let ordinal: Int
    public let targetName: String
    public let primeRelativePath: String
    public let sourceKind:
        PrimeNativeNeuralGateHistoricalReplaySourceKind
    public let originRepositoryRelativePath: String?
    public let originGitBlobOID: String?
    public let originByteCount: UInt64?
    public let originSHA256: String?
    public let derivationID: String?
    public let checkedInByteCount: UInt64
    public let checkedInSHA256: String

    fileprivate init(
        ordinal: Int,
        targetName: String,
        primeRelativePath: String,
        sourceKind:
            PrimeNativeNeuralGateHistoricalReplaySourceKind,
        originRepositoryRelativePath: String? = nil,
        originGitBlobOID: String? = nil,
        originByteCount: UInt64? = nil,
        originSHA256: String? = nil,
        derivationID: String? = nil,
        checkedInByteCount: UInt64,
        checkedInSHA256: String
    ) {
        self.ordinal = ordinal
        self.targetName = targetName
        self.primeRelativePath = primeRelativePath
        self.sourceKind = sourceKind
        self.originRepositoryRelativePath =
            originRepositoryRelativePath
        self.originGitBlobOID = originGitBlobOID
        self.originByteCount = originByteCount
        self.originSHA256 = originSHA256
        self.derivationID = derivationID
        self.checkedInByteCount = checkedInByteCount
        self.checkedInSHA256 = checkedInSHA256
    }

    fileprivate func validate() -> Bool {
        guard ordinal > 0,
              Self.safeIdentifier(targetName),
              Self.safeRelativePath(primeRelativePath),
              checkedInByteCount > 0,
              Self.lowercaseHex(
                  checkedInSHA256,
                  count: 64
              )
        else {
            return false
        }
        let completeOrigin =
            originRepositoryRelativePath != nil
                && originGitBlobOID != nil
                && originByteCount != nil
                && originSHA256 != nil
        if let originRepositoryRelativePath,
           !Self.safeRelativePath(
               originRepositoryRelativePath
           ) {
            return false
        }
        if let originGitBlobOID,
           !Self.lowercaseHex(originGitBlobOID, count: 40) {
            return false
        }
        if let originSHA256,
           !Self.lowercaseHex(originSHA256, count: 64) {
            return false
        }
        if let derivationID,
           !Self.safeIdentifier(derivationID) {
            return false
        }
        switch sourceKind {
        case .byteExactDonor:
            return completeOrigin
                && derivationID == nil
                && originByteCount == checkedInByteCount
                && originSHA256 == checkedInSHA256
        case .derivedDonor:
            return completeOrigin
                && derivationID != nil
        case .primeAuthored,
             .existingPrimeSource:
            return !completeOrigin
                && originRepositoryRelativePath == nil
                && originGitBlobOID == nil
                && originByteCount == nil
                && originSHA256 == nil
                && derivationID == nil
        }
    }

    private static func safeIdentifier(
        _ value: String
    ) -> Bool {
        !value.isEmpty
            && value.utf8.count <= 192
            && value.utf8.allSatisfy {
                ($0 >= 65 && $0 <= 90)
                    || ($0 >= 97 && $0 <= 122)
                    || ($0 >= 48 && $0 <= 57)
                    || $0 == 95
            }
    }

    private static func safeRelativePath(
        _ value: String
    ) -> Bool {
        guard !value.hasPrefix("/"),
              !value.contains("\\"),
              !value.contains("\0"),
              value.utf8.count <= 1_024
        else {
            return false
        }
        return value.split(
            separator: "/",
            omittingEmptySubsequences: false
        ).allSatisfy {
            !$0.isEmpty
                && $0 != "."
                && $0 != ".."
                && $0 != ".git"
        }
    }

    private static func lowercaseHex(
        _ value: String,
        count: Int
    ) -> Bool {
        value.utf8.count == count
            && value.utf8.allSatisfy {
                ($0 >= 48 && $0 <= 57)
                    || ($0 >= 97 && $0 <= 102)
            }
    }

    private enum CodingKeys: String, CodingKey {
        case ordinal
        case targetName = "target_name"
        case primeRelativePath = "prime_relative_path"
        case sourceKind = "source_kind"
        case originRepositoryRelativePath =
            "origin_repository_relative_path"
        case originGitBlobOID = "origin_git_blob_oid"
        case originByteCount = "origin_byte_count"
        case originSHA256 = "origin_sha256"
        case derivationID = "derivation_id"
        case checkedInByteCount = "checked_in_byte_count"
        case checkedInSHA256 = "checked_in_sha256"
    }
}

public struct PrimeNativeNeuralGateHistoricalReplayTargetBinding:
    Codable,
    Equatable,
    Sendable
{
    public let ordinal: Int
    public let targetName: String
    public let directLocalDependencyNames: [String]
    public let orderedSourceRelativePaths: [String]
    public let internalLibraryTarget: Bool
    public let productDeclared: Bool
    public let executableDeclared: Bool
    public let externalProductDependencies: [String]

    fileprivate init(
        ordinal: Int,
        targetName: String,
        directLocalDependencyNames: [String],
        orderedSourceRelativePaths: [String]
    ) {
        self.ordinal = ordinal
        self.targetName = targetName
        self.directLocalDependencyNames =
            directLocalDependencyNames
        self.orderedSourceRelativePaths =
            orderedSourceRelativePaths
        internalLibraryTarget = true
        productDeclared = false
        executableDeclared = false
        externalProductDependencies = []
    }

    private enum CodingKeys: String, CodingKey {
        case ordinal
        case targetName = "target_name"
        case directLocalDependencyNames =
            "direct_local_dependency_names"
        case orderedSourceRelativePaths =
            "ordered_source_relative_paths"
        case internalLibraryTarget = "internal_library_target"
        case productDeclared = "product_declared"
        case executableDeclared = "executable_declared"
        case externalProductDependencies =
            "external_product_dependencies"
    }
}

/// Frozen source and package-closure contract for the isolated historical
/// replay mechanics module.
///
/// The contract binds exact checked-in source. It does not execute the donor,
/// prove that a process loaded this closure, or convert compilation into
/// evidence, a verdict, or product authority.
public struct PrimeNativeNeuralGateHistoricalReplayMechanicsContract:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let contractID: String
    public let rightsHolder: String
    public let licenseExpression: String
    public let companionRepository: String
    public let companionRevision: String
    public let companionTreeOID: String
    public let companionInputCatalogSHA256: String
    public let adaptationProofV3ID: String
    public let adaptationProofV3SHA256: String
    public let sourceMaterialContractID: String
    public let sourceMaterialContractSHA256: String
    public let sourceMaterialAggregateSHA256: String
    public let targetBindings:
        [PrimeNativeNeuralGateHistoricalReplayTargetBinding]
    public let sourcePins:
        [PrimeNativeNeuralGateHistoricalReplaySourcePin]
    public let exactNewMaterializedSourceFileCount: Int
    public let exactTransitiveSourceFileCount: Int
    public let exactRuntimeSourceByteCount: UInt64
    public let exactHistoricalTargetSourceByteCount: UInt64
    public let exactTransitiveSourceByteCount: UInt64
    public let observationSeamPublicEntryPoint: String
    public let observationSeamInputType: String
    public let observationSeamOutputType: String
    public let sourceClosureContractBound: Bool
    public let pmhnpPackageDependencyPresent: Bool
    public let runtimeManifestMaySupplyExpectedValues: Bool
    public let artifactURLsAcceptedByObservationSeam: Bool
    public let phaseTelemetryIncludedInCanonicalObservation: Bool
    public let privateInvariantRecordsExposed: Bool
    public let perMutationFingerprintsExposed: Bool
    public let observedFailedLegSetsExposed: Bool
    public let historicalGateContainsTrapSites: Bool
    public let sealedFreshProcessRequiredBeforeExecutionEvidence: Bool
    public let workerMaterialized: Bool
    /// True only after the historical admission path evaluates artifacts by
    /// calling the donor `load`/`dispose` mechanics. Referencing donor types,
    /// catalogs, or carrier helpers does not satisfy this evidence field.
    public let historicalGateExecuted: Bool
    public let modelExecutionObserved: Bool
    public let durablePublicationObserved: Bool
    public let independentDetectionEstablished: Bool
    public let distinctImplementationFamiliesEstablished: Bool
    public let agentContractKitFourTierAuditPerformed: Bool
    public let mechanicsPassAuthorized: Bool
    public let terminalReceiptAuthorized: Bool
    public let sourceBindingV7Issued: Bool
    public let scientificAuthorityAuthorized: Bool
    public let productAuthorityAuthorized: Bool
    public let nextImplementationPrerequisite: String
    public let authorityStatement: String

    public static let frozenV1: Self = {
        let runtime = "ErgenticsPrimeRuntime"
        let pureReplay =
            "PrimeNativeNeuralGateReplayMechanics"
        let historical =
            "PrimeNativeNeuralGateHistoricalReplayMechanics"
        let runtimeRoot =
            "Sources/ErgenticsPrimeRuntime/"
        let historicalRoot =
            "Sources/PrimeNativeNeuralGateHistoricalReplayMechanics/"
        let pureReplayPath =
            "Sources/PrimeNativeNeuralGateReplayMechanics/PrimeNativeNeuralGateReplayMechanics.swift"

        func exact(
            _ ordinal: Int,
            _ target: String,
            _ primePath: String,
            _ donorPath: String,
            _ blob: String,
            _ bytes: UInt64,
            _ sha256: String
        ) -> PrimeNativeNeuralGateHistoricalReplaySourcePin {
            .init(
                ordinal: ordinal,
                targetName: target,
                primeRelativePath: primePath,
                sourceKind: .byteExactDonor,
                originRepositoryRelativePath: donorPath,
                originGitBlobOID: blob,
                originByteCount: bytes,
                originSHA256: sha256,
                checkedInByteCount: bytes,
                checkedInSHA256: sha256
            )
        }

        let pins: [
            PrimeNativeNeuralGateHistoricalReplaySourcePin
        ] = [
            exact(
                1,
                runtime,
                runtimeRoot + "PrimeNativeByteTokenizer.swift",
                "prime-runtime/Sources/ErgenticsPrimeRuntime/PrimeNativeByteTokenizer.swift",
                "27f5d4f61864499027d3e65516ae4c5cfe1ff5d1",
                21_320,
                "9cee58d44cf3c80bfe53b7568753c4ad4a76d6e54f2e32e6020b795ef0973721"
            ),
            exact(
                2,
                runtime,
                runtimeRoot + "ErgenticsPrimeNativeTextCorpus.swift",
                "prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsPrimeNativeTextCorpus.swift",
                "b2a087c9410a71f2bc99debade752ff779d7a8a8",
                177_032,
                "4758ac2ffc8452614c7eee428333105ac63b0707cb890938d1e42966d3a14210"
            ),
            exact(
                3,
                runtime,
                runtimeRoot + "ErgenticsNativeLanguageCanary.swift",
                "prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsNativeLanguageCanary.swift",
                "027a25b49dde1acfb4cd8af970e05ecd8241f427",
                216_815,
                "8706343bf93c1dac70f5c263f7111667574da751cd27d6c3321a92fd822f063f"
            ),
            exact(
                4,
                runtime,
                runtimeRoot + "ErgenticsNativeLanguageRunConfiguration.swift",
                "prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsNativeLanguageRunConfiguration.swift",
                "d9141e1c08263f10f06b68acada836dc59a45dc9",
                18_069,
                "1f770ed0a044597f6efd7ce1d74e14763cc5e64eeaa0e4036001a311d9e41c7b"
            ),
            exact(
                5,
                runtime,
                runtimeRoot + "ErgenticsNativeLanguageArtifactPathSafety.swift",
                "prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsNativeLanguageArtifactPathSafety.swift",
                "f7404c905c58e8ff2d51f90ee90dad6cb61cbedc",
                51_514,
                "cfeb5d3e3d3a39001f569239f5f9f4c1cb1c669342b366b12930793d36826f7c"
            ),
            exact(
                6,
                runtime,
                runtimeRoot + "ErgenticsNativeLanguageProfileTrialFailure.swift",
                "prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsNativeLanguageProfileTrialFailure.swift",
                "ed64476a8aea3010fe4e6a8b4f799eeb58e64d34",
                16_567,
                "42d022ad2f9c423c9d1ff9e7fc52fc6576a51320a972c738d9d98fd84a956463"
            ),
            exact(
                7,
                runtime,
                runtimeRoot + "ErgenticsNativeScaleEngineRecommend.swift",
                "prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsNativeScaleEngineRecommend.swift",
                "c3f1e242d07ad3cc7b8e961edab868a895d567df",
                190_002,
                "7cdc5ec341d7527c873b458c2ccb24ca27f9104709e9c37066d755bbb951a7ea"
            ),
            exact(
                8,
                historical,
                historicalRoot + "PrimeNeuralNativeLanguageVerifyAbstainGate.swift",
                "neural-kit/Sources/NeuralKit/PrimeNeuralNativeLanguageVerifyAbstainGate.swift",
                "795fff7c458ec68ba4562b6cd1c674fe8de7ffc4",
                368_918,
                "c3c93c637cb15f3a6944e78d8d44c0045f873f7df54f6121ee2d25e4f166b0f6"
            ),
            .init(
                ordinal: 9,
                targetName: historical,
                primeRelativePath:
                    historicalRoot
                    + "PrimeNeuralVerifyAbstainGateCarrier.swift",
                sourceKind: .derivedDonor,
                originRepositoryRelativePath:
                    "neural-kit/Sources/NeuralKit/PrimeNeuralVerifyAbstainGate.swift",
                originGitBlobOID:
                    "3866cc1fd1b39829c913376abece2454b0c11624",
                originByteCount: 4_659,
                originSHA256:
                    "7f5ee1ee5579d13cec0ea4802994e6f07c4117c8202714f40fe1e3a0de21a42c",
                derivationID:
                    "exact_lf_line_slice_verdict_carrier_v1",
                checkedInByteCount: 2_397,
                checkedInSHA256:
                    "4d9847738c6e3079d8951a3ade21355d6d5be56c193b98a6151b634930e2e51f"
            ),
            .init(
                ordinal: 10,
                targetName: historical,
                primeRelativePath:
                    historicalRoot
                    + "PrimeNativeNeuralGateHistoricalObservationSeam.swift",
                sourceKind: .primeAuthored,
                checkedInByteCount: 25_318,
                checkedInSHA256:
                    "537e51906fe26d1bcd252f0067a89ddf0cf83d1cb2a69c831265b06af546de7b"
            ),
            .init(
                ordinal: 11,
                targetName: pureReplay,
                primeRelativePath: pureReplayPath,
                sourceKind: .existingPrimeSource,
                checkedInByteCount: 59_940,
                checkedInSHA256:
                    "8c04e88c1ef9745c12499646e195a5e86e4c426112f324785aba8ad524896ffb"
            ),
        ]

        let runtimePaths = pins.prefix(7)
            .map(\.primeRelativePath)
        let historicalPaths = pins[7 ... 9]
            .map(\.primeRelativePath)
        return Self(
            schemaVersion: 1,
            contractID:
                "prime_source_bound_historical_replay_mechanics_contract_v1",
            rightsHolder: "Ergentics, LLC",
            licenseExpression:
                "LicenseRef-Ergentics-Proprietary",
            companionRepository:
                "Ergentics/pmhnp-companion-ergentics",
            companionRevision:
                "163fc100710ece48119bc25954452d10f6a84f7f",
            companionTreeOID:
                "9009daa4f8a07fbd5897e00b9571cef44ec292db",
            companionInputCatalogSHA256:
                "e9ac9a697dd24cbe6583c713e96840c810cda1771497a6a69ace1e190963bca4",
            adaptationProofV3ID:
                "prime_source_pinned_neural_gate_adaptation_proof_v3",
            adaptationProofV3SHA256:
                "40db6bae391ef4a74723451307a66cda9b7b834c2262ae05085a5f3db68694c1",
            sourceMaterialContractID:
                "prime_source_pinned_historical_gate_carrier_and_mutation_material_v1",
            sourceMaterialContractSHA256:
                "884588bbe5c0aad160366f611d096d88e14946f1923b88c78a5a8b3d6a546da8",
            sourceMaterialAggregateSHA256:
                "9184d0a2feab238a81728aa62c05710121dd77c0b9371761ec5d6d065d9702af",
            targetBindings: [
                .init(
                    ordinal: 1,
                    targetName: runtime,
                    directLocalDependencyNames: [],
                    orderedSourceRelativePaths: runtimePaths
                ),
                .init(
                    ordinal: 2,
                    targetName: pureReplay,
                    directLocalDependencyNames: [],
                    orderedSourceRelativePaths: [pureReplayPath]
                ),
                .init(
                    ordinal: 3,
                    targetName: historical,
                    directLocalDependencyNames: [
                        runtime,
                        pureReplay,
                    ],
                    orderedSourceRelativePaths: historicalPaths
                ),
            ],
            sourcePins: pins,
            exactNewMaterializedSourceFileCount: 10,
            exactTransitiveSourceFileCount: 11,
            exactRuntimeSourceByteCount: 691_319,
            exactHistoricalTargetSourceByteCount: 396_633,
            exactTransitiveSourceByteCount: 1_147_892,
            observationSeamPublicEntryPoint:
                "PrimeNativeNeuralGateHistoricalObservationSeam.observe(_:)",
            observationSeamInputType:
                "PrimeNeuralNativeLanguageVerifyAbstainGate.Materials",
            observationSeamOutputType:
                "PrimeNativeNeuralGateHistoricalAssessmentSnapshot",
            sourceClosureContractBound: true,
            pmhnpPackageDependencyPresent: false,
            runtimeManifestMaySupplyExpectedValues: false,
            artifactURLsAcceptedByObservationSeam: false,
            phaseTelemetryIncludedInCanonicalObservation: false,
            privateInvariantRecordsExposed: false,
            perMutationFingerprintsExposed: false,
            observedFailedLegSetsExposed: false,
            historicalGateContainsTrapSites: true,
            sealedFreshProcessRequiredBeforeExecutionEvidence: true,
            workerMaterialized: false,
            historicalGateExecuted: false,
            modelExecutionObserved: false,
            durablePublicationObserved: false,
            independentDetectionEstablished: false,
            distinctImplementationFamiliesEstablished: false,
            agentContractKitFourTierAuditPerformed: false,
            mechanicsPassAuthorized: false,
            terminalReceiptAuthorized: false,
            sourceBindingV7Issued: false,
            scientificAuthorityAuthorized: false,
            productAuthorityAuthorized: false,
            nextImplementationPrerequisite:
                "derive_and_source_bind_source_faithful_historical_fixture_then_materialize_only_the_sealed_historical_worker_without_materializing_probe_verifier_or_issuing_source_binding_v7",
            authorityStatement:
                "This V1 contract binds the exact seven-file Ergentics runtime authority, byte-exact historical native gate, V9-derived bounded carrier, Prime-authored assessment projection, and existing pure replay source as an internal three-target source closure. The historical target compiles but is unreachable from every current executable and product closure. The observation seam accepts only in-memory Materials, excludes artifact URLs and nondeterministic phase timing, marks private invariant and per-mutation detail unavailable, and forces Prime admission to ABSTAIN. The exact donor closure contains historical traps and filesystem-capable APIs, so compilation is not execution evidence. No worker, process, gate or model execution, durable publication, independent detector, distinct-family/four-tier audit, mechanics PASS, receipt, source/execution-binding V7, science, or product authority is observed or authorized."
        )
    }()

    public func validate() throws {
        try PrimeNativeNeuralGateAdaptationProofContract
            .frozenV3.validate(
                against:
                    PrimeNativeNeuralGateFixtureReplayPlan
                    .frozenV5.inputPins
            )
        try PrimeNativeNeuralGateHistoricalSourceMaterialContract
            .frozenV1.validate()
        guard self == .frozenV1,
              schemaVersion == 1,
              targetBindings.map(\.ordinal) == [1, 2, 3],
              Set(targetBindings.map(\.targetName)).count == 3,
              targetBindings.allSatisfy({
                  $0.internalLibraryTarget
                      && !$0.productDeclared
                      && !$0.executableDeclared
                      && $0.externalProductDependencies.isEmpty
              }),
              sourcePins.count == exactTransitiveSourceFileCount,
              sourcePins.map(\.ordinal)
                == Array(1 ... exactTransitiveSourceFileCount),
              sourcePins.allSatisfy({ $0.validate() }),
              Set(sourcePins.map(\.primeRelativePath)).count
                == sourcePins.count,
              Set(sourcePins.map(\.primeRelativePath))
                == Set(
                    targetBindings.flatMap(
                        \.orderedSourceRelativePaths
                    )
                ),
              sourcePins.prefix(exactNewMaterializedSourceFileCount)
                .map(\.checkedInByteCount).reduce(0, +)
                == exactRuntimeSourceByteCount
                    + exactHistoricalTargetSourceByteCount,
              sourcePins.map(\.checkedInByteCount).reduce(0, +)
                == exactTransitiveSourceByteCount,
              sourceClosureContractBound,
              !pmhnpPackageDependencyPresent,
              !runtimeManifestMaySupplyExpectedValues,
              !artifactURLsAcceptedByObservationSeam,
              !phaseTelemetryIncludedInCanonicalObservation,
              !privateInvariantRecordsExposed,
              !perMutationFingerprintsExposed,
              !observedFailedLegSetsExposed,
              historicalGateContainsTrapSites,
              sealedFreshProcessRequiredBeforeExecutionEvidence,
              !workerMaterialized,
              !historicalGateExecuted,
              !modelExecutionObserved,
              !durablePublicationObserved,
              !independentDetectionEstablished,
              !distinctImplementationFamiliesEstablished,
              !agentContractKitFourTierAuditPerformed,
              !mechanicsPassAuthorized,
              !terminalReceiptAuthorized,
              !sourceBindingV7Issued,
              !scientificAuthorityAuthorized,
              !productAuthorityAuthorized
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan("historical_replay_mechanics_contract")
        }
    }

    public func contentSHA256() throws -> String {
        try validate()
        return PrimeSHA256.hexDigest(
            of: try PrimeCanonicalJSON.encode(self)
        )
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case contractID = "contract_id"
        case rightsHolder = "rights_holder"
        case licenseExpression = "license_expression"
        case companionRepository = "companion_repository"
        case companionRevision = "companion_revision"
        case companionTreeOID = "companion_tree_oid"
        case companionInputCatalogSHA256 =
            "companion_input_catalog_sha256"
        case adaptationProofV3ID =
            "adaptation_proof_v3_id"
        case adaptationProofV3SHA256 =
            "adaptation_proof_v3_sha256"
        case sourceMaterialContractID =
            "source_material_contract_id"
        case sourceMaterialContractSHA256 =
            "source_material_contract_sha256"
        case sourceMaterialAggregateSHA256 =
            "source_material_aggregate_sha256"
        case targetBindings = "target_bindings"
        case sourcePins = "source_pins"
        case exactNewMaterializedSourceFileCount =
            "exact_new_materialized_source_file_count"
        case exactTransitiveSourceFileCount =
            "exact_transitive_source_file_count"
        case exactRuntimeSourceByteCount =
            "exact_runtime_source_byte_count"
        case exactHistoricalTargetSourceByteCount =
            "exact_historical_target_source_byte_count"
        case exactTransitiveSourceByteCount =
            "exact_transitive_source_byte_count"
        case observationSeamPublicEntryPoint =
            "observation_seam_public_entry_point"
        case observationSeamInputType =
            "observation_seam_input_type"
        case observationSeamOutputType =
            "observation_seam_output_type"
        case sourceClosureContractBound =
            "source_closure_contract_bound"
        case pmhnpPackageDependencyPresent =
            "pmhnp_package_dependency_present"
        case runtimeManifestMaySupplyExpectedValues =
            "runtime_manifest_may_supply_expected_values"
        case artifactURLsAcceptedByObservationSeam =
            "artifact_urls_accepted_by_observation_seam"
        case phaseTelemetryIncludedInCanonicalObservation =
            "phase_telemetry_included_in_canonical_observation"
        case privateInvariantRecordsExposed =
            "private_invariant_records_exposed"
        case perMutationFingerprintsExposed =
            "per_mutation_fingerprints_exposed"
        case observedFailedLegSetsExposed =
            "observed_failed_leg_sets_exposed"
        case historicalGateContainsTrapSites =
            "historical_gate_contains_trap_sites"
        case sealedFreshProcessRequiredBeforeExecutionEvidence =
            "sealed_fresh_process_required_before_execution_evidence"
        case workerMaterialized = "worker_materialized"
        case historicalGateExecuted =
            "historical_gate_executed"
        case modelExecutionObserved =
            "model_execution_observed"
        case durablePublicationObserved =
            "durable_publication_observed"
        case independentDetectionEstablished =
            "independent_detection_established"
        case distinctImplementationFamiliesEstablished =
            "distinct_implementation_families_established"
        case agentContractKitFourTierAuditPerformed =
            "agent_contract_kit_four_tier_audit_performed"
        case mechanicsPassAuthorized =
            "mechanics_pass_authorized"
        case terminalReceiptAuthorized =
            "terminal_receipt_authorized"
        case sourceBindingV7Issued =
            "source_binding_v7_issued"
        case scientificAuthorityAuthorized =
            "scientific_authority_authorized"
        case productAuthorityAuthorized =
            "product_authority_authorized"
        case nextImplementationPrerequisite =
            "next_implementation_prerequisite"
        case authorityStatement = "authority_statement"
    }
}
