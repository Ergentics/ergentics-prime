import Foundation

public enum
    PrimeNativeNeuralGateHistoricalEvidenceExportSourceContractError:
    Error,
    Equatable,
    Sendable
{
    case invalidFrozenContract
}

public struct
    PrimeNativeNeuralGateHistoricalEvidenceExportSourceTargetBinding:
    Codable,
    Equatable,
    Sendable
{
    public let targetName: String
    public let targetKind: String
    public let directLocalDependencyNames: [String]
    public let orderedSourceRelativePaths: [String]
    public let copiedResourceRelativePaths: [String]
    public let externalProductDependencyNames: [String]
    public let productDeclared: Bool
    public let completeTargetInventoryBound: Bool

    fileprivate init(
        targetName: String,
        directLocalDependencyNames: [String],
        orderedSourceRelativePaths: [String]
    ) {
        self.targetName = targetName
        targetKind = "internal_library"
        self.directLocalDependencyNames =
            directLocalDependencyNames
        self.orderedSourceRelativePaths =
            orderedSourceRelativePaths
        copiedResourceRelativePaths = []
        externalProductDependencyNames = []
        productDeclared = false
        completeTargetInventoryBound = true
    }

    private enum CodingKeys: String, CodingKey {
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

public struct
    PrimeNativeNeuralGateHistoricalEvidenceExportNestedBridgeRequirement:
    Codable,
    Equatable,
    Sendable
{
    public let ordinal: Int
    public let sourceSwiftTypeName: String
    public let destinationSwiftTypeName: String
    public let orderedFieldNames: [String]
    public let explicitFieldwiseConversionRequired: Bool
    public let directNominalAssignmentPermitted: Bool
    public let fieldsMayBeDroppedDefaultedOrReinterpreted: Bool

    fileprivate init(
        ordinal: Int,
        sourceSwiftTypeName: String,
        destinationSwiftTypeName: String,
        orderedFieldNames: [String]
    ) {
        self.ordinal = ordinal
        self.sourceSwiftTypeName = sourceSwiftTypeName
        self.destinationSwiftTypeName =
            destinationSwiftTypeName
        self.orderedFieldNames = orderedFieldNames
        explicitFieldwiseConversionRequired = true
        directNominalAssignmentPermitted = false
        fieldsMayBeDroppedDefaultedOrReinterpreted = false
    }

    private enum CodingKeys: String, CodingKey {
        case ordinal
        case sourceSwiftTypeName =
            "source_swift_type_name"
        case destinationSwiftTypeName =
            "destination_swift_type_name"
        case orderedFieldNames = "ordered_field_names"
        case explicitFieldwiseConversionRequired =
            "explicit_fieldwise_conversion_required"
        case directNominalAssignmentPermitted =
            "direct_nominal_assignment_permitted"
        case fieldsMayBeDroppedDefaultedOrReinterpreted =
            "fields_may_be_dropped_defaulted_or_reinterpreted"
    }
}

public struct
    PrimeNativeNeuralGateHistoricalEvidenceExportSourceMutationPolicy:
    Codable,
    Equatable,
    Sendable
{
    public let ordinal: Int
    public let mutationID: String
    public let expectedFailedLegID: String
    public let orderedAllowedFailedLegIDs: [String]
    public let observedFailedLegIDsMustBeComputedIndependently: Bool
    public let expectedSingletonMayStandInForObservedSet: Bool
    public let allowedSetMayBeWidenedAtRuntime: Bool

    fileprivate init(
        mutation: PrimeNativeNeuralGateMutationContract
    ) {
        ordinal = mutation.ordinal
        mutationID = mutation.mutationID
        expectedFailedLegID = mutation.expectedFailedLeg
        orderedAllowedFailedLegIDs = [
            mutation.expectedFailedLeg,
        ]
        observedFailedLegIDsMustBeComputedIndependently = true
        expectedSingletonMayStandInForObservedSet = false
        allowedSetMayBeWidenedAtRuntime = false
    }

    fileprivate func validates(
        against mutation:
            PrimeNativeNeuralGateMutationContract
    ) -> Bool {
        ordinal == mutation.ordinal
            && mutationID == mutation.mutationID
            && expectedFailedLegID
                == mutation.expectedFailedLeg
            && orderedAllowedFailedLegIDs
                == [expectedFailedLegID]
            && observedFailedLegIDsMustBeComputedIndependently
            && !expectedSingletonMayStandInForObservedSet
            && !allowedSetMayBeWidenedAtRuntime
    }

    private enum CodingKeys: String, CodingKey {
        case ordinal
        case mutationID = "mutation_id"
        case expectedFailedLegID =
            "expected_failed_leg_id"
        case orderedAllowedFailedLegIDs =
            "ordered_allowed_failed_leg_ids"
        case observedFailedLegIDsMustBeComputedIndependently =
            "observed_failed_leg_ids_must_be_computed_independently"
        case expectedSingletonMayStandInForObservedSet =
            "expected_singleton_may_stand_in_for_observed_set"
        case allowedSetMayBeWidenedAtRuntime =
            "allowed_set_may_be_widened_at_runtime"
    }
}

/// Frozen V13 source and package-materialization boundary for the historical
/// evidence-export variant.
///
/// V13 preserves the byte-exact historical gate and every V12 design byte. It
/// binds the separately pinned append-only exporter suffix, the final derived
/// Swift source, and one package-internal library target. Materialization is
/// compile/source evidence only: the exporter, historical gate, and worker are
/// not invoked by this contract.
public struct
    PrimeNativeNeuralGateHistoricalEvidenceExportSourceContract:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let contractID: String
    public let rightsHolder: String
    public let licenseExpression: String

    public let preservedV12DesignContractID: String
    public let preservedV12DesignContractSHA256: String
    public let preservedTopologyV12ID: String
    public let preservedTopologyV12SHA256: String

    public let companionRepository: String
    public let companionRevision: String
    public let companionTreeOID: String
    public let donorGateRepositoryRelativePath: String
    public let donorGateGitBlobOID: String
    public let donorGateLineCount: Int
    public let donorGateByteCount: UInt64
    public let donorGateSHA256: String

    public let checkedInByteExactGateRelativePath: String
    public let checkedInByteExactGateByteCount: UInt64
    public let checkedInByteExactGateSHA256: String
    public let originalByteExactGateChanged: Bool
    public let originalByteExactGateAccessLevelsChanged: Bool

    public let namespaceBasisDerivationID: String
    public let namespaceBasisByteCount: UInt64
    public let namespaceBasisSHA256: String
    public let exporterSuffixMaterialID: String
    public let exporterSuffixCompositionPolicy: String
    public let exporterSuffixSourceTargetName: String
    public let exporterSuffixSourceRelativePath: String
    public let exporterSuffixStoredAsIndependentCopiedResource: Bool
    public let exporterSuffixByteCount: UInt64
    public let exporterSuffixSHA256: String
    public let finalSourceDerivationID: String
    public let finalDerivedSourceRelativePath: String
    public let finalDerivedAdapterTypeName: String
    public let finalDerivedSourceByteCount: UInt64
    public let finalDerivedSourceSHA256: String

    public let exactNewInternalTargetCount: Int
    public let targetBinding:
        PrimeNativeNeuralGateHistoricalEvidenceExportSourceTargetBinding

    public let publicFacadeTypeName: String
    public let publicFacadeMethodName: String
    public let publicFacadeInputSwiftTypeName: String
    public let publicFacadeOutputSwiftTypeName: String
    public let publicFacadeNormalizedSignature: String
    public let publicFacadeThrows: Bool
    public let publicFacadeIsSoleCrossModuleEntryPoint: Bool

    public let designEvidenceFieldIDs: [String]
    public let publicEvidenceFieldNames: [String]
    public let exactEvidenceFieldCount: Int
    public let exactHistoricalInvariantRecordCount: Int
    public let exactHistoricalInvariantChunkCount: Int
    public let exactHistoricalMutationCount: Int

    public let materialsBridgeLabels: [String]
    public let exactMaterialsBridgeFieldCount: Int
    public let nestedBridgeRequirements:
        [PrimeNativeNeuralGateHistoricalEvidenceExportNestedBridgeRequirement]
    public let completeExplicitMaterialsBridgeRequired: Bool
    public let materialsBridgeMayDropDefaultSwapOrReinterpretFields: Bool

    public let mutationFailurePolicies:
        [PrimeNativeNeuralGateHistoricalEvidenceExportSourceMutationPolicy]
    public let exactMutationFailurePolicyCount: Int
    public let observedFailureSetsRetainedSeparatelyFromAllowedSets: Bool
    public let mutationStreamsUseExactHistoricalSweepConstruction: Bool
    public let completePrimitiveRegradeUsesFullMutatedEvaluation: Bool
    public let recordedHeldoutNonPaddingAndLossBindingsExported: Bool
    public let exactAbstentionDecisionInputsExported: Bool
    public let sourceDerivedRegradeDispositionSeparatedFromHistoricalVerdicts:
        Bool

    public let workerSourceRelativePath: String
    public let workerSourceByteCount: UInt64
    public let workerSourceSHA256: String
    public let workerDirectLocalDependencyNames: [String]
    public let workerSourceChanged: Bool
    public let workerDependenciesChanged: Bool
    public let workerCallGraphChanged: Bool
    public let workerMainUnavailable: Bool

    public let exporterCarrierCodable: Bool
    public let exporterCarrierRoleNeutral: Bool
    public let exporterCarrierPathFree: Bool
    public let exporterCarrierTimingFree: Bool
    public let exporterCarrierAuthorityFree: Bool
    public let fullSourceDerivedVariantMaterialized: Bool
    public let namespaceBasisSourceBound: Bool
    public let exporterSuffixSourceBound: Bool
    public let finalDerivedSourceIdentityBound: Bool
    public let futureTargetMaterialized: Bool
    public let packageGraphChanged: Bool

    public let exporterInvoked: Bool
    public let workerInvoked: Bool
    public let historicalGateExecuted: Bool
    public let historicalEvidenceObserved: Bool
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
        let design =
            PrimeNativeNeuralGateHistoricalEvidenceExportAdapterDesignContract
            .frozenV1
        let topology =
            PrimeNativeNeuralGateTrapDisjointTopologyContract
            .frozenV12
        let worker =
            PrimeNativeNeuralGateHistoricalFixtureWorkerSourceContract
            .frozenV1
        let projection =
            PrimeNativeNeuralGateContractProjection.frozenV1
        let targetName = design.futureIsolatedTargetName
        let sourcePath = design.futureDerivedSourceRelativePath
        let workerTargetName =
            "PrimeNativeNeuralGateHistoricalFixtureWorker"
        let workerBinding = worker.targetBindings.first {
            $0.targetName == workerTargetName
        }!
        let workerSource = worker.materialPins.first {
            $0.targetName == workerTargetName
                && $0.materialKind == .primeAuthoredSource
        }!

        return Self(
            schemaVersion: 1,
            contractID:
                "prime_source_bound_historical_evidence_export_source_v13",
            rightsHolder: "Ergentics, LLC",
            licenseExpression:
                "LicenseRef-Ergentics-Proprietary",
            preservedV12DesignContractID:
                design.contractID,
            preservedV12DesignContractSHA256:
                "e3305d5ee4054c977a7cb006dc2f1b38c169f5b1e2d905f568cf31166f803e8d",
            preservedTopologyV12ID:
                topology.contractID,
            preservedTopologyV12SHA256:
                "335e6d54a94305ee2976c9433d0b5570cdd0f67ca8fea0fa00c8dd9f12eaebbe",
            companionRepository:
                design.companionRepository,
            companionRevision: design.companionRevision,
            companionTreeOID: design.companionTreeOID,
            donorGateRepositoryRelativePath:
                design.donorGateRepositoryRelativePath,
            donorGateGitBlobOID:
                design.donorGateGitBlobOID,
            donorGateLineCount: design.donorGateLineCount,
            donorGateByteCount: design.donorGateByteCount,
            donorGateSHA256: design.donorGateSHA256,
            checkedInByteExactGateRelativePath:
                design.checkedInByteExactGateRelativePath,
            checkedInByteExactGateByteCount:
                design.checkedInByteExactGateByteCount,
            checkedInByteExactGateSHA256:
                design.checkedInByteExactGateSHA256,
            originalByteExactGateChanged: false,
            originalByteExactGateAccessLevelsChanged: false,
            namespaceBasisDerivationID:
                design.namespaceBasisDerivation.derivationID,
            namespaceBasisByteCount: 368_953,
            namespaceBasisSHA256:
                "c323aab1b3f01c78552ee30e5d50c2c7974a1d846121d887dc5f005f6a89cd31",
            exporterSuffixMaterialID:
                "exact_append_only_historical_evidence_export_suffix_v1",
            exporterSuffixCompositionPolicy:
                "append_exact_suffix_bytes_after_exact_namespace_basis_without_intervening_bytes",
            exporterSuffixSourceTargetName:
                "PrimeNativeNeuralGateHistoricalSourceDerivation",
            exporterSuffixSourceRelativePath:
                "Sources/PrimeNativeNeuralGateHistoricalSourceDerivation/HistoricalEvidenceExportSource/PrimeNeuralNativeLanguageVerifyAbstainGateEvidenceExportAdapter.suffix.swiftpart",
            exporterSuffixStoredAsIndependentCopiedResource:
                true,
            exporterSuffixByteCount: 43_273,
            exporterSuffixSHA256:
                "5eb1481f71b6071b56306e5bc20bd6ed2805cf7cad8441b5e9deb5929f026b67",
            finalSourceDerivationID:
                "exact_whole_gate_namespace_clone_two_rewrite_append_only_evidence_export_suffix_v1",
            finalDerivedSourceRelativePath: sourcePath,
            finalDerivedAdapterTypeName:
                design.futureDerivedTopLevelTypeName,
            finalDerivedSourceByteCount: 412_226,
            finalDerivedSourceSHA256:
                "a20bb86529988f75a46340b9a62924ebda151744a4028ad7726a2d712a385eae",
            exactNewInternalTargetCount: 1,
            targetBinding: .init(
                targetName: targetName,
                directLocalDependencyNames: [
                    "ErgenticsPrimeRuntime",
                    "PrimeNativeNeuralGateReplayMechanics",
                    "PrimeNativeNeuralGateHistoricalReplayMechanics",
                ],
                orderedSourceRelativePaths: [sourcePath]
            ),
            publicFacadeTypeName:
                "PrimeNativeNeuralGateHistoricalEvidenceExporter",
            publicFacadeMethodName: "export",
            publicFacadeInputSwiftTypeName:
                "PrimeNativeNeuralGateHistoricalReplayMechanics.PrimeNeuralNativeLanguageVerifyAbstainGate.Materials",
            publicFacadeOutputSwiftTypeName:
                "PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence",
            publicFacadeNormalizedSignature:
                "PrimeNativeNeuralGateHistoricalEvidenceExporter.export(_:PrimeNativeNeuralGateHistoricalReplayMechanics.PrimeNeuralNativeLanguageVerifyAbstainGate.Materials)throws->PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence",
            publicFacadeThrows: true,
            publicFacadeIsSoleCrossModuleEntryPoint: true,
            designEvidenceFieldIDs:
                design.requiredEvidenceFields.map(\.fieldID),
            publicEvidenceFieldNames: [
                "orderedInvariantRecords",
                "orderedInvariantRecordASCIIFlags",
                "baselineInvariantBundle",
                "orderedMutationIdentities",
                "perMutationStreamIdentities",
                "perMutationFingerprints",
                "perMutationObservedFailedLegIDs",
                "historicalCriticalLegValues",
                "historicalStatisticsAndVerdictValues",
            ],
            exactEvidenceFieldCount: 9,
            exactHistoricalInvariantRecordCount:
                design.exactHistoricalInvariantRecordCount,
            exactHistoricalInvariantChunkCount:
                design.exactHistoricalInvariantChunkCount,
            exactHistoricalMutationCount:
                design.exactHistoricalMutationCount,
            materialsBridgeLabels:
                design.materialsBridgeFields.map(
                    \.sourceFieldName
                ),
            exactMaterialsBridgeFieldCount: 12,
            nestedBridgeRequirements: [
                .init(
                    ordinal: 1,
                    sourceSwiftTypeName:
                        "PrimeNativeNeuralGateHistoricalReplayMechanics.PrimeNeuralNativeLanguageVerifyAbstainGate.ObservedPackageResolvedBinding",
                    destinationSwiftTypeName:
                        "PrimeNeuralNativeLanguageVerifyAbstainGateEvidenceExportAdapter.ObservedPackageResolvedBinding",
                    orderedFieldNames: [
                        "fileName",
                        "sha256",
                        "byteCount",
                        "mlxSwiftRevision",
                        "mlxSwiftExamplesVersion",
                    ]
                ),
                .init(
                    ordinal: 2,
                    sourceSwiftTypeName:
                        "PrimeNativeNeuralGateHistoricalReplayMechanics.PrimeNeuralNativeLanguageVerifyAbstainGate.ObservedCheckpointBinding",
                    destinationSwiftTypeName:
                        "PrimeNeuralNativeLanguageVerifyAbstainGateEvidenceExportAdapter.ObservedCheckpointBinding",
                    orderedFieldNames: [
                        "fileName",
                        "sha256",
                        "byteCount",
                    ]
                ),
                .init(
                    ordinal: 3,
                    sourceSwiftTypeName:
                        "PrimeNativeNeuralGateHistoricalReplayMechanics.PrimeNeuralNativeLanguageVerifyAbstainGate.ObservedMetalLibraryBinding",
                    destinationSwiftTypeName:
                        "PrimeNeuralNativeLanguageVerifyAbstainGateEvidenceExportAdapter.ObservedMetalLibraryBinding",
                    orderedFieldNames: [
                        "primaryFileName",
                        "fallbackFileName",
                        "sha256",
                        "byteCount",
                    ]
                ),
            ],
            completeExplicitMaterialsBridgeRequired: true,
            materialsBridgeMayDropDefaultSwapOrReinterpretFields:
                false,
            mutationFailurePolicies:
                projection.mutationCatalog.map {
                    .init(mutation: $0)
                },
            exactMutationFailurePolicyCount: 46,
            observedFailureSetsRetainedSeparatelyFromAllowedSets:
                true,
            mutationStreamsUseExactHistoricalSweepConstruction:
                true,
            completePrimitiveRegradeUsesFullMutatedEvaluation:
                true,
            recordedHeldoutNonPaddingAndLossBindingsExported:
                true,
            exactAbstentionDecisionInputsExported: true,
            sourceDerivedRegradeDispositionSeparatedFromHistoricalVerdicts:
                true,
            workerSourceRelativePath:
                workerSource.primeRelativePath,
            workerSourceByteCount:
                workerSource.checkedInByteCount,
            workerSourceSHA256:
                workerSource.checkedInSHA256,
            workerDirectLocalDependencyNames:
                workerBinding.directLocalDependencyNames,
            workerSourceChanged: false,
            workerDependenciesChanged: false,
            workerCallGraphChanged: false,
            workerMainUnavailable: true,
            exporterCarrierCodable: false,
            exporterCarrierRoleNeutral: true,
            exporterCarrierPathFree: true,
            exporterCarrierTimingFree: true,
            exporterCarrierAuthorityFree: true,
            fullSourceDerivedVariantMaterialized: true,
            namespaceBasisSourceBound: true,
            exporterSuffixSourceBound: true,
            finalDerivedSourceIdentityBound: true,
            futureTargetMaterialized: true,
            packageGraphChanged: true,
            exporterInvoked: false,
            workerInvoked: false,
            historicalGateExecuted: false,
            historicalEvidenceObserved: false,
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
                "source_bind_the_historical_worker_evidence_export_call_edge_without_sealing_launching_or_executing_the_worker_or_issuing_source_binding_v7",
            authorityStatement:
                "This V13 source contract preserves the complete V12 design and topology identities and leaves the original byte-exact 368,918-byte historical gate unchanged. It binds the exact 368,953-byte namespace basis, independently checked-in 43,273-byte append-only exporter suffix, final 412,226-byte derived source, complete twelve-field Materials bridge with explicit nominal conversion of all nested package, checkpoint, and Metal binding fields, nine-field non-Codable authority-free evidence carrier, and forty-six exact singleton allowed-failure policies with complete observed failure sets retained separately. Mutation streams and fingerprints use the exact historical sweep construction while complete NL1 through NL9 failure sets use a separate full mutated evaluation; the source-derived singleton disposition remains separate from historical donor verdicts. The exact three-seed catalog is validated before non-trapping row-cache construction. Timing-free recorded heldout token/loss bindings and exact typed abstention decision inputs are retained. One package-internal library target has exactly three local dependencies. The public facade accepts only in-memory historical Materials and is not invoked. The historical worker source, dependencies, call graph, unavailable main, and copied resource remain unchanged. No exporter, gate, fixture, worker, model, mutation, or process executes; no historical evidence, durable publication, independent detector, distinct-family or four-tier audit, mechanics PASS, terminal receipt, source or execution binding V7, scientific authority, or product authority is observed or authorized."
        )
    }()

    public func validate() throws {
        let design =
            PrimeNativeNeuralGateHistoricalEvidenceExportAdapterDesignContract
            .frozenV1
        let topology =
            PrimeNativeNeuralGateTrapDisjointTopologyContract
            .frozenV12
        let worker =
            PrimeNativeNeuralGateHistoricalFixtureWorkerSourceContract
            .frozenV1
        let projection =
            PrimeNativeNeuralGateContractProjection.frozenV1
        try design.validate()
        try topology.validate()
        try worker.validate()
        try projection.validate()

        let workerTargetName =
            "PrimeNativeNeuralGateHistoricalFixtureWorker"
        guard let workerBinding = worker.targetBindings.first(
            where: { $0.targetName == workerTargetName }
        ),
              let workerSource = worker.materialPins.first(
                  where: {
                      $0.targetName == workerTargetName
                          && $0.materialKind
                            == .primeAuthoredSource
                  }
              )
        else {
            throw PrimeNativeNeuralGateHistoricalEvidenceExportSourceContractError
                .invalidFrozenContract
        }

        let expectedEvidenceFieldIDs = [
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
        let expectedPublicEvidenceFieldNames = [
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
        let expectedBridgeLabels = [
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
        let exactTargetDependencies = [
            "ErgenticsPrimeRuntime",
            "PrimeNativeNeuralGateReplayMechanics",
            "PrimeNativeNeuralGateHistoricalReplayMechanics",
        ]
        let mutationPoliciesValid =
            mutationFailurePolicies.count
                == projection.mutationCatalog.count
            && zip(
                mutationFailurePolicies,
                projection.mutationCatalog
            ).allSatisfy {
                $0.0.validates(against: $0.1)
            }

        guard self == .frozenV1,
              schemaVersion == 1,
              contractID
                == "prime_source_bound_historical_evidence_export_source_v13",
              rightsHolder == design.rightsHolder,
              licenseExpression == design.licenseExpression,
              preservedV12DesignContractID
                == design.contractID,
              preservedV12DesignContractSHA256
                == (try design.contentSHA256()),
              preservedTopologyV12ID
                == topology.contractID,
              preservedTopologyV12SHA256
                == (try topology.contentSHA256()),
              companionRepository
                == design.companionRepository,
              companionRevision == design.companionRevision,
              companionTreeOID == design.companionTreeOID,
              donorGateRepositoryRelativePath
                == design.donorGateRepositoryRelativePath,
              donorGateGitBlobOID
                == design.donorGateGitBlobOID,
              donorGateLineCount == design.donorGateLineCount,
              donorGateByteCount == 368_918,
              donorGateByteCount == design.donorGateByteCount,
              donorGateSHA256
                == "c3c93c637cb15f3a6944e78d8d44c0045f873f7df54f6121ee2d25e4f166b0f6",
              donorGateSHA256 == design.donorGateSHA256,
              checkedInByteExactGateRelativePath
                == design.checkedInByteExactGateRelativePath,
              checkedInByteExactGateByteCount
                == donorGateByteCount,
              checkedInByteExactGateSHA256
                == donorGateSHA256,
              !originalByteExactGateChanged,
              !originalByteExactGateAccessLevelsChanged,
              namespaceBasisDerivationID
                == design.namespaceBasisDerivation.derivationID,
              namespaceBasisByteCount == 368_953,
              namespaceBasisByteCount
                == design.namespaceBasisDerivation
                    .expectedOutputByteCount,
              namespaceBasisSHA256
                == "c323aab1b3f01c78552ee30e5d50c2c7974a1d846121d887dc5f005f6a89cd31",
              namespaceBasisSHA256
                == design.namespaceBasisDerivation
                    .expectedOutputSHA256,
              exporterSuffixMaterialID
                == "exact_append_only_historical_evidence_export_suffix_v1",
              exporterSuffixCompositionPolicy
                == "append_exact_suffix_bytes_after_exact_namespace_basis_without_intervening_bytes",
              exporterSuffixSourceTargetName
                == "PrimeNativeNeuralGateHistoricalSourceDerivation",
              exporterSuffixSourceRelativePath
                == "Sources/PrimeNativeNeuralGateHistoricalSourceDerivation/HistoricalEvidenceExportSource/PrimeNeuralNativeLanguageVerifyAbstainGateEvidenceExportAdapter.suffix.swiftpart",
              exporterSuffixStoredAsIndependentCopiedResource,
              exporterSuffixByteCount == 43_273,
              exporterSuffixSHA256
                == "5eb1481f71b6071b56306e5bc20bd6ed2805cf7cad8441b5e9deb5929f026b67",
              finalSourceDerivationID
                == "exact_whole_gate_namespace_clone_two_rewrite_append_only_evidence_export_suffix_v1",
              finalDerivedSourceRelativePath
                == design.futureDerivedSourceRelativePath,
              finalDerivedAdapterTypeName
                == design.futureDerivedTopLevelTypeName,
              finalDerivedSourceByteCount == 412_226,
              finalDerivedSourceByteCount
                == namespaceBasisByteCount
                    + exporterSuffixByteCount,
              finalDerivedSourceSHA256
                == "a20bb86529988f75a46340b9a62924ebda151744a4028ad7726a2d712a385eae",
              exactNewInternalTargetCount == 1,
              targetBinding.targetName
                == design.futureIsolatedTargetName,
              targetBinding.targetKind == "internal_library",
              targetBinding.directLocalDependencyNames
                == exactTargetDependencies,
              targetBinding.orderedSourceRelativePaths
                == [finalDerivedSourceRelativePath],
              targetBinding.copiedResourceRelativePaths.isEmpty,
              targetBinding.externalProductDependencyNames.isEmpty,
              !targetBinding.productDeclared,
              targetBinding.completeTargetInventoryBound,
              publicFacadeTypeName
                == "PrimeNativeNeuralGateHistoricalEvidenceExporter",
              publicFacadeMethodName == "export",
              publicFacadeInputSwiftTypeName
                == "PrimeNativeNeuralGateHistoricalReplayMechanics.PrimeNeuralNativeLanguageVerifyAbstainGate.Materials",
              publicFacadeOutputSwiftTypeName
                == "PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence",
              publicFacadeNormalizedSignature
                == "PrimeNativeNeuralGateHistoricalEvidenceExporter.export(_:PrimeNativeNeuralGateHistoricalReplayMechanics.PrimeNeuralNativeLanguageVerifyAbstainGate.Materials)throws->PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence",
              publicFacadeThrows,
              publicFacadeIsSoleCrossModuleEntryPoint,
              designEvidenceFieldIDs
                == expectedEvidenceFieldIDs,
              designEvidenceFieldIDs
                == design.requiredEvidenceFields.map(\.fieldID),
              publicEvidenceFieldNames
                == expectedPublicEvidenceFieldNames,
              exactEvidenceFieldCount == 9,
              designEvidenceFieldIDs.count
                == exactEvidenceFieldCount,
              publicEvidenceFieldNames.count
                == exactEvidenceFieldCount,
              exactHistoricalInvariantRecordCount == 59_497,
              exactHistoricalInvariantRecordCount
                == design.exactHistoricalInvariantRecordCount,
              exactHistoricalInvariantChunkCount == 15,
              exactHistoricalInvariantChunkCount
                == design.exactHistoricalInvariantChunkCount,
              exactHistoricalMutationCount == 46,
              exactHistoricalMutationCount
                == design.exactHistoricalMutationCount,
              materialsBridgeLabels == expectedBridgeLabels,
              materialsBridgeLabels
                == design.materialsBridgeFields.map(
                    \.sourceFieldName
                ),
              exactMaterialsBridgeFieldCount == 12,
              materialsBridgeLabels.count
                == exactMaterialsBridgeFieldCount,
              nestedBridgeRequirements
                == Self.expectedNestedBridgeRequirements,
              completeExplicitMaterialsBridgeRequired,
              !materialsBridgeMayDropDefaultSwapOrReinterpretFields,
              exactMutationFailurePolicyCount == 46,
              mutationFailurePolicies.count
                == exactMutationFailurePolicyCount,
              mutationPoliciesValid,
              observedFailureSetsRetainedSeparatelyFromAllowedSets,
              mutationStreamsUseExactHistoricalSweepConstruction,
              completePrimitiveRegradeUsesFullMutatedEvaluation,
              recordedHeldoutNonPaddingAndLossBindingsExported,
              exactAbstentionDecisionInputsExported,
              sourceDerivedRegradeDispositionSeparatedFromHistoricalVerdicts,
              workerSourceRelativePath
                == workerSource.primeRelativePath,
              workerSourceByteCount == 2_298,
              workerSourceByteCount
                == workerSource.checkedInByteCount,
              workerSourceSHA256
                == "9f62827d4c35e98fb01f9984b1c227cb681dd42ac4c26147a86e9429958545df",
              workerSourceSHA256
                == workerSource.checkedInSHA256,
              workerDirectLocalDependencyNames
                == workerBinding.directLocalDependencyNames,
              workerDirectLocalDependencyNames
                == [
                    "PrimeCore",
                    "ErgenticsPrimeRuntime",
                    "PrimeNativeNeuralGateHistoricalReplayMechanics",
                    "PrimeNativeNeuralGateReplayTransport",
                ],
              !workerSourceChanged,
              !workerDependenciesChanged,
              !workerCallGraphChanged,
              workerMainUnavailable,
              !exporterCarrierCodable,
              exporterCarrierRoleNeutral,
              exporterCarrierPathFree,
              exporterCarrierTimingFree,
              exporterCarrierAuthorityFree,
              fullSourceDerivedVariantMaterialized,
              namespaceBasisSourceBound,
              exporterSuffixSourceBound,
              finalDerivedSourceIdentityBound,
              futureTargetMaterialized,
              packageGraphChanged,
              !exporterInvoked,
              !workerInvoked,
              !historicalGateExecuted,
              !historicalEvidenceObserved,
              !durablePublicationObserved,
              !independentDetectionEstablished,
              !distinctImplementationFamiliesEstablished,
              !agentContractKitFourTierAuditPerformed,
              !mechanicsPassAuthorized,
              !terminalReceiptAuthorized,
              !sourceBindingV7Issued,
              !scientificAuthorityAuthorized,
              !productAuthorityAuthorized,
              !nextImplementationPrerequisite.isEmpty,
              !authorityStatement.isEmpty
        else {
            throw PrimeNativeNeuralGateHistoricalEvidenceExportSourceContractError
                .invalidFrozenContract
        }
    }

    public func contentSHA256() throws -> String {
        try validate()
        return PrimeSHA256.hexDigest(
            of: try PrimeCanonicalJSON.encode(self)
        )
    }

    private static let expectedNestedBridgeRequirements: [
        PrimeNativeNeuralGateHistoricalEvidenceExportNestedBridgeRequirement
    ] = [
        .init(
            ordinal: 1,
            sourceSwiftTypeName:
                "PrimeNativeNeuralGateHistoricalReplayMechanics.PrimeNeuralNativeLanguageVerifyAbstainGate.ObservedPackageResolvedBinding",
            destinationSwiftTypeName:
                "PrimeNeuralNativeLanguageVerifyAbstainGateEvidenceExportAdapter.ObservedPackageResolvedBinding",
            orderedFieldNames: [
                "fileName",
                "sha256",
                "byteCount",
                "mlxSwiftRevision",
                "mlxSwiftExamplesVersion",
            ]
        ),
        .init(
            ordinal: 2,
            sourceSwiftTypeName:
                "PrimeNativeNeuralGateHistoricalReplayMechanics.PrimeNeuralNativeLanguageVerifyAbstainGate.ObservedCheckpointBinding",
            destinationSwiftTypeName:
                "PrimeNeuralNativeLanguageVerifyAbstainGateEvidenceExportAdapter.ObservedCheckpointBinding",
            orderedFieldNames: [
                "fileName",
                "sha256",
                "byteCount",
            ]
        ),
        .init(
            ordinal: 3,
            sourceSwiftTypeName:
                "PrimeNativeNeuralGateHistoricalReplayMechanics.PrimeNeuralNativeLanguageVerifyAbstainGate.ObservedMetalLibraryBinding",
            destinationSwiftTypeName:
                "PrimeNeuralNativeLanguageVerifyAbstainGateEvidenceExportAdapter.ObservedMetalLibraryBinding",
            orderedFieldNames: [
                "primaryFileName",
                "fallbackFileName",
                "sha256",
                "byteCount",
            ]
        ),
    ]

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case contractID = "contract_id"
        case rightsHolder = "rights_holder"
        case licenseExpression = "license_expression"
        case preservedV12DesignContractID =
            "preserved_v12_design_contract_id"
        case preservedV12DesignContractSHA256 =
            "preserved_v12_design_contract_sha256"
        case preservedTopologyV12ID =
            "preserved_topology_v12_id"
        case preservedTopologyV12SHA256 =
            "preserved_topology_v12_sha256"
        case companionRepository = "companion_repository"
        case companionRevision = "companion_revision"
        case companionTreeOID = "companion_tree_oid"
        case donorGateRepositoryRelativePath =
            "donor_gate_repository_relative_path"
        case donorGateGitBlobOID = "donor_gate_git_blob_oid"
        case donorGateLineCount = "donor_gate_line_count"
        case donorGateByteCount = "donor_gate_byte_count"
        case donorGateSHA256 = "donor_gate_sha256"
        case checkedInByteExactGateRelativePath =
            "checked_in_byte_exact_gate_relative_path"
        case checkedInByteExactGateByteCount =
            "checked_in_byte_exact_gate_byte_count"
        case checkedInByteExactGateSHA256 =
            "checked_in_byte_exact_gate_sha256"
        case originalByteExactGateChanged =
            "original_byte_exact_gate_changed"
        case originalByteExactGateAccessLevelsChanged =
            "original_byte_exact_gate_access_levels_changed"
        case namespaceBasisDerivationID =
            "namespace_basis_derivation_id"
        case namespaceBasisByteCount =
            "namespace_basis_byte_count"
        case namespaceBasisSHA256 =
            "namespace_basis_sha256"
        case exporterSuffixMaterialID =
            "exporter_suffix_material_id"
        case exporterSuffixCompositionPolicy =
            "exporter_suffix_composition_policy"
        case exporterSuffixSourceTargetName =
            "exporter_suffix_source_target_name"
        case exporterSuffixSourceRelativePath =
            "exporter_suffix_source_relative_path"
        case exporterSuffixStoredAsIndependentCopiedResource =
            "exporter_suffix_stored_as_independent_copied_resource"
        case exporterSuffixByteCount =
            "exporter_suffix_byte_count"
        case exporterSuffixSHA256 =
            "exporter_suffix_sha256"
        case finalSourceDerivationID =
            "final_source_derivation_id"
        case finalDerivedSourceRelativePath =
            "final_derived_source_relative_path"
        case finalDerivedAdapterTypeName =
            "final_derived_adapter_type_name"
        case finalDerivedSourceByteCount =
            "final_derived_source_byte_count"
        case finalDerivedSourceSHA256 =
            "final_derived_source_sha256"
        case exactNewInternalTargetCount =
            "exact_new_internal_target_count"
        case targetBinding = "target_binding"
        case publicFacadeTypeName =
            "public_facade_type_name"
        case publicFacadeMethodName =
            "public_facade_method_name"
        case publicFacadeInputSwiftTypeName =
            "public_facade_input_swift_type_name"
        case publicFacadeOutputSwiftTypeName =
            "public_facade_output_swift_type_name"
        case publicFacadeNormalizedSignature =
            "public_facade_normalized_signature"
        case publicFacadeThrows = "public_facade_throws"
        case publicFacadeIsSoleCrossModuleEntryPoint =
            "public_facade_is_sole_cross_module_entry_point"
        case designEvidenceFieldIDs =
            "design_evidence_field_ids"
        case publicEvidenceFieldNames =
            "public_evidence_field_names"
        case exactEvidenceFieldCount =
            "exact_evidence_field_count"
        case exactHistoricalInvariantRecordCount =
            "exact_historical_invariant_record_count"
        case exactHistoricalInvariantChunkCount =
            "exact_historical_invariant_chunk_count"
        case exactHistoricalMutationCount =
            "exact_historical_mutation_count"
        case materialsBridgeLabels =
            "materials_bridge_labels"
        case exactMaterialsBridgeFieldCount =
            "exact_materials_bridge_field_count"
        case nestedBridgeRequirements =
            "nested_bridge_requirements"
        case completeExplicitMaterialsBridgeRequired =
            "complete_explicit_materials_bridge_required"
        case materialsBridgeMayDropDefaultSwapOrReinterpretFields =
            "materials_bridge_may_drop_default_swap_or_reinterpret_fields"
        case mutationFailurePolicies =
            "mutation_failure_policies"
        case exactMutationFailurePolicyCount =
            "exact_mutation_failure_policy_count"
        case observedFailureSetsRetainedSeparatelyFromAllowedSets =
            "observed_failure_sets_retained_separately_from_allowed_sets"
        case mutationStreamsUseExactHistoricalSweepConstruction =
            "mutation_streams_use_exact_historical_sweep_construction"
        case completePrimitiveRegradeUsesFullMutatedEvaluation =
            "complete_primitive_regrade_uses_full_mutated_evaluation"
        case recordedHeldoutNonPaddingAndLossBindingsExported =
            "recorded_heldout_non_padding_and_loss_bindings_exported"
        case exactAbstentionDecisionInputsExported =
            "exact_abstention_decision_inputs_exported"
        case sourceDerivedRegradeDispositionSeparatedFromHistoricalVerdicts =
            "source_derived_regrade_disposition_separated_from_historical_verdicts"
        case workerSourceRelativePath =
            "worker_source_relative_path"
        case workerSourceByteCount =
            "worker_source_byte_count"
        case workerSourceSHA256 = "worker_source_sha256"
        case workerDirectLocalDependencyNames =
            "worker_direct_local_dependency_names"
        case workerSourceChanged = "worker_source_changed"
        case workerDependenciesChanged =
            "worker_dependencies_changed"
        case workerCallGraphChanged =
            "worker_call_graph_changed"
        case workerMainUnavailable =
            "worker_main_unavailable"
        case exporterCarrierCodable =
            "exporter_carrier_codable"
        case exporterCarrierRoleNeutral =
            "exporter_carrier_role_neutral"
        case exporterCarrierPathFree =
            "exporter_carrier_path_free"
        case exporterCarrierTimingFree =
            "exporter_carrier_timing_free"
        case exporterCarrierAuthorityFree =
            "exporter_carrier_authority_free"
        case fullSourceDerivedVariantMaterialized =
            "full_source_derived_variant_materialized"
        case namespaceBasisSourceBound =
            "namespace_basis_source_bound"
        case exporterSuffixSourceBound =
            "exporter_suffix_source_bound"
        case finalDerivedSourceIdentityBound =
            "final_derived_source_identity_bound"
        case futureTargetMaterialized =
            "future_target_materialized"
        case packageGraphChanged = "package_graph_changed"
        case exporterInvoked = "exporter_invoked"
        case workerInvoked = "worker_invoked"
        case historicalGateExecuted =
            "historical_gate_executed"
        case historicalEvidenceObserved =
            "historical_evidence_observed"
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
