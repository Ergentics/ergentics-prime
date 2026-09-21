import Foundation

public enum PrimeNativeNeuralGateHistoricalFixtureWorkerMaterialKind:
    String,
    Codable,
    Equatable,
    Sendable
{
    case derivedDonorSource = "derived_donor_source"
    case primeAuthoredSource = "prime_authored_source"
    case byteExactDonorResource = "byte_exact_donor_resource"
}

public struct PrimeNativeNeuralGateHistoricalFixtureWorkerMaterialPin:
    Codable,
    Equatable,
    Sendable
{
    public let ordinal: Int
    public let targetName: String
    public let primeRelativePath: String
    public let materialKind:
        PrimeNativeNeuralGateHistoricalFixtureWorkerMaterialKind
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
        materialKind:
            PrimeNativeNeuralGateHistoricalFixtureWorkerMaterialKind,
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
        self.materialKind = materialKind
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
              Self.lowercaseHex(checkedInSHA256, count: 64)
        else {
            return false
        }
        if let originRepositoryRelativePath,
           !Self.safeRelativePath(originRepositoryRelativePath) {
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
        let hasCompleteOrigin =
            originRepositoryRelativePath != nil
                && originGitBlobOID != nil
                && originByteCount != nil
                && originSHA256 != nil
        switch materialKind {
        case .derivedDonorSource:
            return hasCompleteOrigin
                && derivationID != nil
        case .primeAuthoredSource:
            return !hasCompleteOrigin
                && originRepositoryRelativePath == nil
                && originGitBlobOID == nil
                && originByteCount == nil
                && originSHA256 == nil
                && derivationID == nil
        case .byteExactDonorResource:
            return hasCompleteOrigin
                && derivationID == nil
                && originByteCount == checkedInByteCount
                && originSHA256 == checkedInSHA256
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
        case materialKind = "material_kind"
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

public enum PrimeNativeNeuralGateHistoricalFixtureTargetKind:
    String,
    Codable,
    Equatable,
    Sendable
{
    case internalLibrary = "internal_library"
    case internalExecutable = "internal_executable"
}

public struct PrimeNativeNeuralGateHistoricalFixtureTargetBinding:
    Codable,
    Equatable,
    Sendable
{
    public let ordinal: Int
    public let targetName: String
    public let targetKind:
        PrimeNativeNeuralGateHistoricalFixtureTargetKind
    public let directLocalDependencyNames: [String]
    public let orderedSourceRelativePaths: [String]
    public let copiedResourceRelativePaths: [String]
    public let externalProductDependencyNames: [String]
    public let productDeclared: Bool
    public let completeTargetInventoryBound: Bool

    fileprivate init(
        ordinal: Int,
        targetName: String,
        targetKind:
            PrimeNativeNeuralGateHistoricalFixtureTargetKind,
        directLocalDependencyNames: [String],
        orderedSourceRelativePaths: [String],
        copiedResourceRelativePaths: [String] = []
    ) {
        self.ordinal = ordinal
        self.targetName = targetName
        self.targetKind = targetKind
        self.directLocalDependencyNames =
            directLocalDependencyNames
        self.orderedSourceRelativePaths =
            orderedSourceRelativePaths
        self.copiedResourceRelativePaths =
            copiedResourceRelativePaths
        externalProductDependencyNames = []
        productDeclared = false
        completeTargetInventoryBound = true
    }

    private enum CodingKeys: String, CodingKey {
        case ordinal
        case targetName = "target_name"
        case targetKind = "target_kind"
        case directLocalDependencyNames =
            "direct_local_dependency_names"
        case orderedSourceRelativePaths =
            "ordered_source_relative_paths"
        case copiedResourceRelativePaths =
            "copied_resource_relative_paths"
        case externalProductDependencyNames =
            "external_product_dependency_names"
        case productDeclared = "product_declared"
        case completeTargetInventoryBound =
            "complete_target_inventory_bound"
    }
}

/// Frozen source/package contract for the additive V11 historical fixture
/// and unavailable worker boundary.
///
/// The fixture compiles in the historical replay module because its exact
/// source-faithful derivation accesses internal declarations of the pinned
/// donor gate. The worker executable target is materialized only so its
/// source closure and reserved future call edges compile. Its `main` exits
/// unavailable and neither the fixture nor the gate is executed here.
public struct PrimeNativeNeuralGateHistoricalFixtureWorkerSourceContract:
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
    public let preservedAdaptationProofV2ID: String
    public let preservedAdaptationProofV2SHA256: String
    public let requiredAdaptationProofV3ID: String
    public let requiredAdaptationProofV3SHA256: String
    public let historicalReplayContractID: String
    public let historicalReplayContractSHA256: String
    public let preservedTopologyV10ID: String
    public let preservedTopologyV10SHA256: String
    public let topologyV11ID: String
    public let historicalWorkerContractID: String
    public let fixtureDerivation:
        PrimeNativeNeuralGateSourceDerivationContract
    public let targetBindings:
        [PrimeNativeNeuralGateHistoricalFixtureTargetBinding]
    public let materialPins:
        [PrimeNativeNeuralGateHistoricalFixtureWorkerMaterialPin]
    public let exactNewSwiftSourceFileCount: Int
    public let exactNewResourceFileCount: Int
    public let exactNewMaterialByteCount: UInt64
    public let exactHistoricalTargetSourceFileCount: Int
    public let exactHistoricalTargetSourceByteCount: UInt64
    public let exactV10TransitiveSourceFileCount: Int
    public let exactV11TransitiveSourceFileCount: Int
    public let exactV11TransitiveSourceByteCount: UInt64
    public let completeCompiledWorkerSourceClosureObserved: Bool
    public let fixtureDerivationBound: Bool
    public let fixtureRoutedToHistoricalReplayTarget: Bool
    public let fixtureSharesModuleWithPinnedGate: Bool
    public let donorAccessLevelsChanged: Bool
    public let workerExecutableTargetMaterialized: Bool
    public let workerProductDeclared: Bool
    public let workerMainUnavailable: Bool
    public let reservedHistoricalCallEdgeReachableFromMain: Bool
    public let pmhnpPackageDependencyPresent: Bool
    public let sealedWorkerImageObserved: Bool
    public let workerInvoked: Bool
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
        let historical =
            "PrimeNativeNeuralGateHistoricalReplayMechanics"
        let worker =
            "PrimeNativeNeuralGateHistoricalFixtureWorker"
        let historicalRoot =
            "Sources/PrimeNativeNeuralGateHistoricalReplayMechanics/"
        let workerRoot =
            "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/"
        let fixturePath =
            historicalRoot
            + "EngineProposesNativeLanguageVerifyAbstainFixture.swift"
        let workerPath =
            workerRoot
            + "PrimeNativeNeuralGateHistoricalFixtureWorker.swift"
        let lockPath =
            workerRoot
            + "HistoricalFixtureEvidence/Package.resolved"
        let fixtureDerivation =
            PrimeNativeNeuralGateAdaptationProofContract
            .frozenV3.entries[9].derivation
        let historicalV10Paths =
            PrimeNativeNeuralGateHistoricalReplayMechanicsContract
            .frozenV1.sourcePins.filter {
                $0.targetName == historical
            }.map(\.primeRelativePath)

        return Self(
            schemaVersion: 1,
            contractID:
                "prime_source_bound_historical_fixture_worker_v11",
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
            preservedAdaptationProofV2ID:
                "prime_source_pinned_neural_gate_adaptation_proof_v2",
            preservedAdaptationProofV2SHA256:
                "2c5dc058ce03f329581db88fa3ab3f1e8baf6faf06ead734d772821ed8af9b28",
            requiredAdaptationProofV3ID:
                "prime_source_pinned_neural_gate_adaptation_proof_v3",
            requiredAdaptationProofV3SHA256:
                "40db6bae391ef4a74723451307a66cda9b7b834c2262ae05085a5f3db68694c1",
            historicalReplayContractID:
                "prime_source_bound_historical_replay_mechanics_contract_v1",
            historicalReplayContractSHA256:
                "6bd51cb07b0f6bf72eb9cba6dec1fd9686377dab838fd6468497c34d6704debe",
            preservedTopologyV10ID:
                "prime_stage_b_source_bound_historical_replay_mechanics_topology_v10",
            preservedTopologyV10SHA256:
                "b7990ee20d69660b29d12e0ba9014df2849da5747329c80cbe168644b6a170a5",
            topologyV11ID:
                "prime_stage_b_source_bound_historical_fixture_worker_topology_v11",
            historicalWorkerContractID:
                "prime_stage_b_historical_fixture_worker_v2",
            fixtureDerivation: fixtureDerivation,
            targetBindings: [
                .init(
                    ordinal: 1,
                    targetName: historical,
                    targetKind: .internalLibrary,
                    directLocalDependencyNames: [
                        "ErgenticsPrimeRuntime",
                        "PrimeNativeNeuralGateReplayMechanics",
                    ],
                    orderedSourceRelativePaths:
                        historicalV10Paths + [fixturePath]
                ),
                .init(
                    ordinal: 2,
                    targetName: worker,
                    targetKind: .internalExecutable,
                    directLocalDependencyNames: [
                        "PrimeCore",
                        "ErgenticsPrimeRuntime",
                        historical,
                        "PrimeNativeNeuralGateReplayTransport",
                    ],
                    orderedSourceRelativePaths: [workerPath],
                    copiedResourceRelativePaths: [
                        "HistoricalFixtureEvidence",
                    ]
                ),
            ],
            materialPins: [
                .init(
                    ordinal: 1,
                    targetName: historical,
                    primeRelativePath: fixturePath,
                    materialKind: .derivedDonorSource,
                    originRepositoryRelativePath:
                        "neural-kit/Tests/NeuralKitTests/EngineProposesNativeLanguageVerifyAbstainTests.swift",
                    originGitBlobOID:
                        "aa87aff21832ebd5c7a6598692139b81ae065e0b",
                    originByteCount: 165_692,
                    originSHA256:
                        "266475d337fb49ba9c84e03a53871269a73812c3200a830a799ef90f4901968c",
                    derivationID:
                        fixtureDerivation.derivationID,
                    checkedInByteCount: 88_141,
                    checkedInSHA256:
                        "e04daaf783f0cb79958daea9a70579fc959b47ceea4ae913bcb69cdc458fcf99"
                ),
                .init(
                    ordinal: 2,
                    targetName: worker,
                    primeRelativePath: workerPath,
                    materialKind: .primeAuthoredSource,
                    checkedInByteCount: 2_298,
                    checkedInSHA256:
                        "9f62827d4c35e98fb01f9984b1c227cb681dd42ac4c26147a86e9429958545df"
                ),
                .init(
                    ordinal: 3,
                    targetName: worker,
                    primeRelativePath: lockPath,
                    materialKind: .byteExactDonorResource,
                    originRepositoryRelativePath:
                        "neural-kit/Package.resolved",
                    originGitBlobOID:
                        "18aef69512c82c3e6cdff192f3aa0a6ee13c702e",
                    originByteCount: 1_949,
                    originSHA256:
                        "cf1ba313dcb0c959e80ba09d6cbe0c56bcd921523bda5cec2c682c8ae7696ab3",
                    checkedInByteCount: 1_949,
                    checkedInSHA256:
                        "cf1ba313dcb0c959e80ba09d6cbe0c56bcd921523bda5cec2c682c8ae7696ab3"
                ),
            ],
            exactNewSwiftSourceFileCount: 2,
            exactNewResourceFileCount: 1,
            exactNewMaterialByteCount: 92_388,
            exactHistoricalTargetSourceFileCount: 4,
            exactHistoricalTargetSourceByteCount: 484_774,
            exactV10TransitiveSourceFileCount: 11,
            exactV11TransitiveSourceFileCount: 12,
            exactV11TransitiveSourceByteCount: 1_236_033,
            completeCompiledWorkerSourceClosureObserved: false,
            fixtureDerivationBound: true,
            fixtureRoutedToHistoricalReplayTarget: true,
            fixtureSharesModuleWithPinnedGate: true,
            donorAccessLevelsChanged: false,
            workerExecutableTargetMaterialized: true,
            workerProductDeclared: false,
            workerMainUnavailable: true,
            reservedHistoricalCallEdgeReachableFromMain: false,
            pmhnpPackageDependencyPresent: false,
            sealedWorkerImageObserved: false,
            workerInvoked: false,
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
                "derive_and_source_bind_historical_worker_evidence_export_adapter_without_mutating_the_byte_exact_gate_executing_the_worker_or_issuing_source_binding_v7",
            authorityStatement:
                "This V1 source contract preserves adaptation proofs V2 and V3, the V10 replay source contract, and topology V10 byte-for-byte. It adds the exact source-derived 88,141-byte historical fixture to the isolated historical replay module because the source-faithful fixture requires same-module access to internal donor declarations; donor access levels are unchanged. It also binds the exact Prime-authored unavailable worker source and byte-exact package-lock resource in a package-internal executable target with the frozen worker V2 dependencies and CLI vocabulary. The worker main exits unavailable and its fixture/gate observation call edge is unreachable. PrimeCore is part of the worker closure, so a complete compiled-worker source snapshot cannot be self-pinned inside this contract without circular identity and remains unobserved. The pinned gate still withholds private invariant records, per-mutation fingerprints, and observed failed-leg sets. No sealed worker image, invocation, process, gate or model execution, durable evidence, independent detector, distinct-family/four-tier audit, mechanics PASS, terminal receipt, source/execution-binding V7, scientific authority, or product authority is observed or authorized."
        )
    }()

    public func validate() throws {
        let plan =
            PrimeNativeNeuralGateFixtureReplayPlan.frozenV5
        let adaptationV2 =
            PrimeNativeNeuralGateAdaptationProofContract
            .frozenV2
        let adaptationV3 =
            PrimeNativeNeuralGateAdaptationProofContract
            .frozenV3
        let replay =
            PrimeNativeNeuralGateHistoricalReplayMechanicsContract
            .frozenV1
        let topologyV10 =
            PrimeNativeNeuralGateTrapDisjointTopologyContract
            .frozenV10
        let topologyV11 =
            PrimeNativeNeuralGateTrapDisjointTopologyContract
            .frozenV11
        let worker =
            PrimeNativeNeuralGateHistoricalWorkerContract
            .frozenV2
        try adaptationV2.validate(against: plan.inputPins)
        try adaptationV3.validate(against: plan.inputPins)
        try replay.validate()
        try topologyV10.validate()
        try topologyV11.validate()
        try fixtureDerivation.validate(
            donorByteCount: plan.inputPins[9].byteCount,
            donorSHA256: plan.inputPins[9].sha256
        )

        let adaptationV2SHA256 =
            PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(
                    adaptationV2
                )
            )
        let adaptationV3SHA256 =
            PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(
                    adaptationV3
                )
            )
        let historical =
            "PrimeNativeNeuralGateHistoricalReplayMechanics"
        let workerTarget =
            "PrimeNativeNeuralGateHistoricalFixtureWorker"
        guard targetBindings.count == 2,
              materialPins.count == 3
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan(
                    "historical_fixture_worker_source_contract"
                )
        }
        let historicalBinding = targetBindings[0]
        let workerBinding = targetBindings[1]
        let fixturePin = materialPins[0]
        let workerPin = materialPins[1]

        guard self == .frozenV1,
              schemaVersion == 1,
              companionRevision == plan.companionRevision,
              companionTreeOID == plan.companionTreeOID,
              companionInputCatalogSHA256
                == plan.inputCatalogSHA256,
              preservedAdaptationProofV2ID
                == adaptationV2.contractID,
              preservedAdaptationProofV2SHA256
                == adaptationV2SHA256,
              requiredAdaptationProofV3ID
                == adaptationV3.contractID,
              requiredAdaptationProofV3SHA256
                == adaptationV3SHA256,
              historicalReplayContractID
                == replay.contractID,
              historicalReplayContractSHA256
                == (try replay.contentSHA256()),
              preservedTopologyV10ID
                == topologyV10.contractID,
              preservedTopologyV10SHA256
                == (try topologyV10.contentSHA256()),
              topologyV11ID == topologyV11.contractID,
              historicalWorkerContractID
                == worker.contractID,
              fixtureDerivation
                == adaptationV3.entries[9].derivation,
              fixtureDerivation.expectedOutputByteCount
                == fixturePin.checkedInByteCount,
              fixtureDerivation.expectedOutputSHA256
                == fixturePin.checkedInSHA256,
              targetBindings.map(\.ordinal) == [1, 2],
              materialPins.map(\.ordinal) == [1, 2, 3],
              materialPins.allSatisfy({ $0.validate() }),
              Set(materialPins.map(\.primeRelativePath)).count
                == materialPins.count,
              historicalBinding.targetName == historical,
              historicalBinding.targetKind
                == .internalLibrary,
              historicalBinding.directLocalDependencyNames
                == [
                    "ErgenticsPrimeRuntime",
                    "PrimeNativeNeuralGateReplayMechanics",
                ],
              historicalBinding
                .orderedSourceRelativePaths.count
                == exactHistoricalTargetSourceFileCount,
              historicalBinding
                .orderedSourceRelativePaths.last
                == fixturePin.primeRelativePath,
              historicalBinding
                .copiedResourceRelativePaths.isEmpty,
              workerBinding.targetName == workerTarget,
              workerBinding.targetKind
                == .internalExecutable,
              workerBinding.directLocalDependencyNames
                == [
                    "PrimeCore",
                    "ErgenticsPrimeRuntime",
                    historical,
                    "PrimeNativeNeuralGateReplayTransport",
                ],
              workerBinding.orderedSourceRelativePaths
                == [workerPin.primeRelativePath],
              workerBinding.copiedResourceRelativePaths
                == ["HistoricalFixtureEvidence"],
              targetBindings.allSatisfy({
                  $0.externalProductDependencyNames.isEmpty
                      && !$0.productDeclared
                      && $0.completeTargetInventoryBound
              }),
              exactNewSwiftSourceFileCount == 2,
              exactNewResourceFileCount == 1,
              materialPins.map(\.checkedInByteCount)
                .reduce(0, +)
                == exactNewMaterialByteCount,
              exactHistoricalTargetSourceByteCount
                == replay.exactHistoricalTargetSourceByteCount
                    + fixturePin.checkedInByteCount,
              exactV10TransitiveSourceFileCount
                == replay.exactTransitiveSourceFileCount,
              exactV11TransitiveSourceFileCount
                == exactV10TransitiveSourceFileCount + 1,
              exactV11TransitiveSourceByteCount
                == replay.exactTransitiveSourceByteCount
                    + fixturePin.checkedInByteCount,
              worker.executableTargetName == workerTarget,
              worker.exactCLIArgumentNames
                == [
                    "--artifact-root",
                    "--invocation-role",
                    "--request-sha256",
                ],
              worker.allowedInvocationRoles
                == [.probe, .verifier],
              !completeCompiledWorkerSourceClosureObserved,
              fixtureDerivationBound,
              fixtureRoutedToHistoricalReplayTarget,
              fixtureSharesModuleWithPinnedGate,
              !donorAccessLevelsChanged,
              workerExecutableTargetMaterialized,
              !workerProductDeclared,
              workerMainUnavailable,
              !reservedHistoricalCallEdgeReachableFromMain,
              !pmhnpPackageDependencyPresent,
              !sealedWorkerImageObserved,
              !workerInvoked,
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
                .invalidPlan(
                    "historical_fixture_worker_source_contract"
                )
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
        case preservedAdaptationProofV2ID =
            "preserved_adaptation_proof_v2_id"
        case preservedAdaptationProofV2SHA256 =
            "preserved_adaptation_proof_v2_sha256"
        case requiredAdaptationProofV3ID =
            "required_adaptation_proof_v3_id"
        case requiredAdaptationProofV3SHA256 =
            "required_adaptation_proof_v3_sha256"
        case historicalReplayContractID =
            "historical_replay_contract_id"
        case historicalReplayContractSHA256 =
            "historical_replay_contract_sha256"
        case preservedTopologyV10ID =
            "preserved_topology_v10_id"
        case preservedTopologyV10SHA256 =
            "preserved_topology_v10_sha256"
        case topologyV11ID = "topology_v11_id"
        case historicalWorkerContractID =
            "historical_worker_contract_id"
        case fixtureDerivation = "fixture_derivation"
        case targetBindings = "target_bindings"
        case materialPins = "material_pins"
        case exactNewSwiftSourceFileCount =
            "exact_new_swift_source_file_count"
        case exactNewResourceFileCount =
            "exact_new_resource_file_count"
        case exactNewMaterialByteCount =
            "exact_new_material_byte_count"
        case exactHistoricalTargetSourceFileCount =
            "exact_historical_target_source_file_count"
        case exactHistoricalTargetSourceByteCount =
            "exact_historical_target_source_byte_count"
        case exactV10TransitiveSourceFileCount =
            "exact_v10_transitive_source_file_count"
        case exactV11TransitiveSourceFileCount =
            "exact_v11_transitive_source_file_count"
        case exactV11TransitiveSourceByteCount =
            "exact_v11_transitive_source_byte_count"
        case completeCompiledWorkerSourceClosureObserved =
            "complete_compiled_worker_source_closure_observed"
        case fixtureDerivationBound =
            "fixture_derivation_bound"
        case fixtureRoutedToHistoricalReplayTarget =
            "fixture_routed_to_historical_replay_target"
        case fixtureSharesModuleWithPinnedGate =
            "fixture_shares_module_with_pinned_gate"
        case donorAccessLevelsChanged =
            "donor_access_levels_changed"
        case workerExecutableTargetMaterialized =
            "worker_executable_target_materialized"
        case workerProductDeclared =
            "worker_product_declared"
        case workerMainUnavailable =
            "worker_main_unavailable"
        case reservedHistoricalCallEdgeReachableFromMain =
            "reserved_historical_call_edge_reachable_from_main"
        case pmhnpPackageDependencyPresent =
            "pmhnp_package_dependency_present"
        case sealedWorkerImageObserved =
            "sealed_worker_image_observed"
        case workerInvoked = "worker_invoked"
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
