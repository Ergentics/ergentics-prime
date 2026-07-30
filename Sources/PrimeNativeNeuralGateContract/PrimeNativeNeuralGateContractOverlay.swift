import Foundation
import PrimeCore
import PrimeNativeCorpusReplay

public enum PrimeNativeNeuralGateContractError:
    Error,
    Equatable,
    LocalizedError,
    Sendable
{
    case invalidPlan
    case invalidParent(String)
    case invalidObservation(String)
    case invalidCandidate(String)
    case invalidReceipt(String)
    case replayMismatch(String)
    case mutationUndetected(String)

    public var errorDescription: String? {
        switch self {
        case .invalidPlan:
            "native neural-gate contract plan drifted"
        case let .invalidParent(detail):
            "native neural-gate contract parent rejected: \(detail)"
        case let .invalidObservation(detail):
            "native neural-gate contract observation rejected: \(detail)"
        case let .invalidCandidate(detail):
            "native neural-gate contract candidate rejected: \(detail)"
        case let .invalidReceipt(detail):
            "native neural-gate contract receipt rejected: \(detail)"
        case let .replayMismatch(detail):
            "native neural-gate contract fresh replay diverged: \(detail)"
        case let .mutationUndetected(mutation):
            "native neural-gate projection mutation was not detected: \(mutation)"
        }
    }
}

public struct PrimeNativeNeuralGateContractPlan:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let planID: String
    public let claimScope: String
    public let generationReceiptPath: String
    public let generationReceiptSHA256: String
    public let generationReceiptByteCount: UInt64
    public let corpusReplayReceiptPath: String
    public let corpusReplayReceiptSHA256: String
    public let corpusReplayReceiptByteCount: UInt64
    public let sourceSnapshotPath: String
    public let probeExecutablePath: String
    public let verifierExecutablePath: String
    public let projectionPath: String
    public let probeObservationPath: String
    public let candidatePath: String
    public let verifierObservationPath: String
    public let receiptPath: String
    public let companionRuntimeDependencyAuthorized:
        Bool
    public let sourceBlobResolutionAuthorized: Bool
    public let donorExecutionAuthorized: Bool
    public let neuralKitExecutionAuthorized: Bool
    public let modelExecutionAuthorized: Bool
    public let functionalTrainingAuthorized: Bool
    public let quantizationAuthorized: Bool
    public let productUseAuthorized: Bool
    public let pythonExecutionAuthorized: Bool
    public let shellScientificAuthorityAuthorized:
        Bool
    public let phaseThreeCompatibilityComplete:
        Bool
    public let authorityStatement: String

    public static let frozenV1 = Self(
        schemaVersion: 1,
        planID:
            "ergentics_prime_neuralkit_native_language_gate_contract_projection_replay_v1",
        claimScope:
            PrimeNativeNeuralGateContractProjection
            .frozenV1.claimScope,
        generationReceiptPath:
            "prime-native-generation-contract-projection-receipt.v1.json",
        generationReceiptSHA256:
            "05d135bb04bc377b85b7bce98a6eebbab35a80172567407d2c4625f4af9b990b",
        generationReceiptByteCount: 20_010,
        corpusReplayReceiptPath:
            "prime-native-full-corpus-replay-receipt.v1.json",
        corpusReplayReceiptSHA256:
            "88d243827c1aff0ce8125402f84c4ffe4012d058dedaf88f614099e975dafdc2",
        corpusReplayReceiptByteCount: 2_965,
        sourceSnapshotPath:
            "neural-gate-contract/prime-swift-source-snapshot.v1.json",
        probeExecutablePath:
            "bin/PrimeNativeNeuralGateContractProjectionProbe",
        verifierExecutablePath:
            "bin/PrimeNativeNeuralGateContractProjectionVerifier",
        projectionPath:
            PrimeNativeNeuralGateContractProjection
            .frozenV1.projectionRelativePath,
        probeObservationPath:
            "neural-gate-contract/probe-observation.v1.json",
        candidatePath:
            "neural-gate-contract/probe-candidate.v1.json",
        verifierObservationPath:
            "neural-gate-contract/verifier-observation.v1.json",
        receiptPath:
            "prime-native-neural-gate-contract-projection-receipt.v1.json",
        companionRuntimeDependencyAuthorized:
            false,
        sourceBlobResolutionAuthorized: false,
        donorExecutionAuthorized: false,
        neuralKitExecutionAuthorized: false,
        modelExecutionAuthorized: false,
        functionalTrainingAuthorized: false,
        quantizationAuthorized: false,
        productUseAuthorized: false,
        pythonExecutionAuthorized: false,
        shellScientificAuthorityAuthorized:
            false,
        phaseThreeCompatibilityComplete:
            false,
        authorityStatement:
            "This Swift-only Stage-A gate losslessly binds the canonical generation-contract and full-corpus replay receipts, publishes the bounded source-pinned NeuralKit native-language value contract with the selected eight-file native-gate pre-carrier compile closure plus generic-carrier and regression-fixture identities, executes fixed finite-field contract vectors and structural projection falsifiers in distinct Release probe and verifier processes, and exclusively seals a receipt only after exact replay. It does not resolve or execute companion source, import the broad generic verdict source closure, add a PMHNP runtime dependency, reconstruct the unpublished historical invariant records, execute the historical 46 semantic mutations, recompute their SZ fingerprint, perform a four-tier AgentContractKit audit, execute NeuralKit or a model, train, quantize, claim Phase-3 compatibility, or authorize product use."
    )

    public static let requiredPrimeSourcePaths:
        Set<String> = Set([
            "Package.swift",
            "Sources/PrimeCore/PrimeDurableArtifacts.swift",
            "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
            "Sources/PrimeCore/PrimeNativeContractMigration.swift",
            "Sources/PrimeCore/PrimeNativeContractMigrationResolver.swift",
            "Sources/PrimeCore/PrimeNativeGenerationContractOverlay.swift",
            "Sources/PrimeCore/PrimeNativeGenerationContractProjection.swift",
            "Sources/PrimeCore/PrimeNativeGitBlobTransport.swift",
            "Sources/PrimeCore/PrimeNativeNeuralGateContractArguments.swift",
            "Sources/PrimeCore/PrimeNativeNeuralGateContractProjection.swift",
            "Sources/PrimeCore/PrimeNativeResolvedContractAdapter.swift",
            "Sources/PrimeCore/PrimeNativeResolvedContractModels.swift",
            "Sources/PrimeCore/PrimeSecureRunningExecutableCapture.swift",
            "Sources/PrimeCore/PrimeSwiftSourceProvenance.swift",
            "Sources/PrimeNativeCorpusReplay/PrimeNativeCorpusReplayContract.swift",
            "Sources/PrimeNativeCorpusReplay/PrimeNativeCorpusReplayOverlay.swift",
            "Sources/PrimeNativeNeuralGateContract/PrimeNativeNeuralGateContractOverlay.swift",
            "Sources/PrimeNativeNeuralGateContractProjectionProbe/PrimeNativeNeuralGateContractProjectionProbeMain.swift",
            "Sources/PrimeNativeNeuralGateContractProjectionVerifier/PrimeNativeNeuralGateContractProjectionVerifierMain.swift",
        ])
        .union(
            PrimeNativeGenerationContractOverlay
                .requiredPrimeSourcePaths
        )
        .union(
            PrimeNativeCorpusReplayPlan
                .requiredPrimeSourcePaths
        )

    public func validate() throws {
        guard self == .frozenV1,
              schemaVersion == 1,
              claimScope
                == PrimeNativeNeuralGateContractProjection
                .frozenV1.claimScope,
              generationReceiptSHA256.utf8.count
                == 64,
              generationReceiptByteCount > 0,
              corpusReplayReceiptSHA256.utf8.count
                == 64,
              corpusReplayReceiptByteCount > 0,
              projectionPath
                == PrimeNativeNeuralGateContractProjection
                .frozenV1.projectionRelativePath,
              !companionRuntimeDependencyAuthorized,
              !sourceBlobResolutionAuthorized,
              !donorExecutionAuthorized,
              !neuralKitExecutionAuthorized,
              !modelExecutionAuthorized,
              !functionalTrainingAuthorized,
              !quantizationAuthorized,
              !productUseAuthorized,
              !pythonExecutionAuthorized,
              !shellScientificAuthorityAuthorized,
              !phaseThreeCompatibilityComplete,
              authorityStatement.contains(
                  "distinct Release probe and verifier processes"
              ),
              authorityStatement.contains(
                  "does not resolve or execute companion source"
              )
        else {
            throw PrimeNativeNeuralGateContractError
                .invalidPlan
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
        case planID = "plan_id"
        case claimScope = "claim_scope"
        case generationReceiptPath =
            "generation_receipt_path"
        case generationReceiptSHA256 =
            "generation_receipt_sha256"
        case generationReceiptByteCount =
            "generation_receipt_byte_count"
        case corpusReplayReceiptPath =
            "corpus_replay_receipt_path"
        case corpusReplayReceiptSHA256 =
            "corpus_replay_receipt_sha256"
        case corpusReplayReceiptByteCount =
            "corpus_replay_receipt_byte_count"
        case sourceSnapshotPath =
            "source_snapshot_path"
        case probeExecutablePath =
            "probe_executable_path"
        case verifierExecutablePath =
            "verifier_executable_path"
        case projectionPath = "projection_path"
        case probeObservationPath =
            "probe_observation_path"
        case candidatePath = "candidate_path"
        case verifierObservationPath =
            "verifier_observation_path"
        case receiptPath = "receipt_path"
        case companionRuntimeDependencyAuthorized =
            "companion_runtime_dependency_authorized"
        case sourceBlobResolutionAuthorized =
            "source_blob_resolution_authorized"
        case donorExecutionAuthorized =
            "donor_execution_authorized"
        case neuralKitExecutionAuthorized =
            "neural_kit_execution_authorized"
        case modelExecutionAuthorized =
            "model_execution_authorized"
        case functionalTrainingAuthorized =
            "functional_training_authorized"
        case quantizationAuthorized =
            "quantization_authorized"
        case productUseAuthorized =
            "product_use_authorized"
        case pythonExecutionAuthorized =
            "python_execution_authorized"
        case shellScientificAuthorityAuthorized =
            "shell_scientific_authority_authorized"
        case phaseThreeCompatibilityComplete =
            "phase_three_compatibility_complete"
        case authorityStatement =
            "authority_statement"
    }
}

public struct PrimeNativeNeuralGateContractSourceState:
    Codable,
    Equatable,
    Sendable
{
    public let remoteURL: String
    public let revision: String
    public let treeOID: String
    public let clean: Bool

    public init(
        _ state:
            PrimeNativeMigrationResolverSourceState
    ) {
        remoteURL = state.remoteURL
        revision = state.revision
        treeOID = state.treeOID
        clean = state.clean
    }

    private enum CodingKeys: String, CodingKey {
        case remoteURL = "remote_url"
        case revision
        case treeOID = "tree_oid"
        case clean
    }
}

public enum PrimeNativeNeuralGateProjectionMutation:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Sendable
{
    case sourcePinSetDrift =
        "source_pin_set_drift"
    case sourceBlobIdentityDrift =
        "source_blob_identity_drift"
    case criticalLegOrderDrift =
        "critical_leg_order_drift"
    case mutationCatalogTruncation =
        "mutation_catalog_truncation"
    case mutationExpectedLegDrift =
        "mutation_expected_leg_drift"
    case finiteFieldPrimeDrift =
        "finite_field_prime_drift"
    case capabilityThresholdDrift =
        "capability_threshold_drift"
    case allCriticalRuleRemoved =
        "all_critical_rule_removed"
    case countLabelPromotedToFourTierAudit =
        "count_label_promoted_to_four_tier_audit"
    case syntheticSummaryPromotedToExecution =
        "synthetic_summary_promoted_to_execution"
    case sourceResolutionOverclaim =
        "source_resolution_overclaim"
    case phaseThreeAuthorityExpansion =
        "phase_three_authority_expansion"

    public var detectorID: String {
        "prime_neural_gate_projection_exact_decode_\(rawValue)_v1"
    }
}

public struct PrimeNativeNeuralGateProjectionMutationRecord:
    Codable,
    Equatable,
    Sendable
{
    public let mutation:
        PrimeNativeNeuralGateProjectionMutation
    public let detectorID: String
    public let detected: Bool
    public let restored: Bool
    public let historicalSemanticMutationExecuted:
        Bool
    public let independentScientificOracleClaimed:
        Bool

    public init(
        mutation:
            PrimeNativeNeuralGateProjectionMutation,
        detected: Bool,
        restored: Bool
    ) {
        self.mutation = mutation
        detectorID = mutation.detectorID
        self.detected = detected
        self.restored = restored
        historicalSemanticMutationExecuted =
            false
        independentScientificOracleClaimed =
            false
    }

    public func validate() throws {
        guard detectorID == mutation.detectorID,
              detected,
              restored,
              !historicalSemanticMutationExecuted,
              !independentScientificOracleClaimed
        else {
            throw PrimeNativeNeuralGateContractError
                .mutationUndetected(mutation.rawValue)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case mutation
        case detectorID = "detector_id"
        case detected
        case restored
        case historicalSemanticMutationExecuted =
            "historical_semantic_mutation_executed"
        case independentScientificOracleClaimed =
            "independent_scientific_oracle_claimed"
    }
}

public struct PrimeNativeNeuralGateContractObservation:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let artifactKind: String
    public let claimScope: String
    public let projectionSHA256: String
    public let sourcePinCount: Int
    public let criticalLegCount: Int
    public let historicalMutationContractCount:
        Int
    public let contractVectorRecords: [String]
    public let contractVectorFingerprint:
        PrimeNativeNeuralGateFiniteFieldFingerprint
    public let projectionMutationSweep:
        [PrimeNativeNeuralGateProjectionMutationRecord]
    public let finiteFieldContractVectorComputed:
        Bool
    public let historicalInvariantRecordsObserved:
        Bool
    public let historicalSemanticMutationsExecuted:
        Bool
    public let historicalSZFingerprintRecomputed:
        Bool
    public let agentContractKitFourTierAuditPerformed:
        Bool
    public let guardedStatisticalEntanglementPerformed:
        Bool
    public let neuralKitExecuted: Bool
    public let modelExecutionPerformed: Bool
    public let independentScientificOracleClaimed:
        Bool

    public static let contractVectorRecordsV1 = [
        "record|K",
        "record|\u{212A}",
        "record|\u{00E9}",
        "record|e\u{0301}",
        "control|0",
    ]

    public static func runAndValidate() throws -> Self {
        let projection =
            PrimeNativeNeuralGateContractProjection
            .frozenV1
        try projection.validate()
        let mutations =
            try PrimeNativeNeuralGateContractOverlay
            .projectionMutationSweep()
        let observation = Self(
            schemaVersion: 1,
            artifactKind:
                "ergentics_prime_native_neural_gate_contract_observation",
            claimScope: projection.claimScope,
            projectionSHA256:
                try projection.contentSHA256(),
            sourcePinCount:
                projection.sourceBindings.count,
            criticalLegCount:
                projection.criticalLegs.count,
            historicalMutationContractCount:
                projection.mutationCatalog.count,
            contractVectorRecords:
                contractVectorRecordsV1,
            contractVectorFingerprint:
                try projection.finiteField
                .fingerprint(
                    records: contractVectorRecordsV1
                ),
            projectionMutationSweep: mutations,
            finiteFieldContractVectorComputed:
                true,
            historicalInvariantRecordsObserved:
                false,
            historicalSemanticMutationsExecuted:
                false,
            historicalSZFingerprintRecomputed:
                false,
            agentContractKitFourTierAuditPerformed:
                false,
            guardedStatisticalEntanglementPerformed:
                false,
            neuralKitExecuted: false,
            modelExecutionPerformed: false,
            independentScientificOracleClaimed:
                false
        )
        try observation.validate()
        return observation
    }

    public func validate() throws {
        let projection =
            PrimeNativeNeuralGateContractProjection
            .frozenV1
        let expectedFingerprint =
            try projection.finiteField.fingerprint(
                records: Self.contractVectorRecordsV1
            )
        guard schemaVersion == 1,
              artifactKind
                == "ergentics_prime_native_neural_gate_contract_observation",
              claimScope == projection.claimScope,
              projectionSHA256
                == (try projection.contentSHA256()),
              sourcePinCount
                == projection.sourceBindings.count,
              criticalLegCount
                == projection.criticalLegs.count,
              historicalMutationContractCount
                == projection.mutationCatalog.count,
              contractVectorRecords
                == Self.contractVectorRecordsV1,
              contractVectorFingerprint
                == expectedFingerprint,
              projectionMutationSweep.map(\.mutation)
                == PrimeNativeNeuralGateProjectionMutation
                .allCases,
              projectionMutationSweep.allSatisfy({
                  (try? $0.validate()) != nil
              }),
              finiteFieldContractVectorComputed,
              !historicalInvariantRecordsObserved,
              !historicalSemanticMutationsExecuted,
              !historicalSZFingerprintRecomputed,
              !agentContractKitFourTierAuditPerformed,
              !guardedStatisticalEntanglementPerformed,
              !neuralKitExecuted,
              !modelExecutionPerformed,
              !independentScientificOracleClaimed
        else {
            throw PrimeNativeNeuralGateContractError
                .invalidObservation(
                    "frozen observation"
                )
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case artifactKind = "artifact_kind"
        case claimScope = "claim_scope"
        case projectionSHA256 =
            "projection_sha256"
        case sourcePinCount = "source_pin_count"
        case criticalLegCount =
            "critical_leg_count"
        case historicalMutationContractCount =
            "historical_mutation_contract_count"
        case contractVectorRecords =
            "contract_vector_records"
        case contractVectorFingerprint =
            "contract_vector_fingerprint"
        case projectionMutationSweep =
            "projection_mutation_sweep"
        case finiteFieldContractVectorComputed =
            "finite_field_contract_vector_computed"
        case historicalInvariantRecordsObserved =
            "historical_invariant_records_observed"
        case historicalSemanticMutationsExecuted =
            "historical_semantic_mutations_executed"
        case historicalSZFingerprintRecomputed =
            "historical_sz_fingerprint_recomputed"
        case agentContractKitFourTierAuditPerformed =
            "agent_contract_kit_four_tier_audit_performed"
        case guardedStatisticalEntanglementPerformed =
            "guarded_statistical_entanglement_performed"
        case neuralKitExecuted =
            "neural_kit_executed"
        case modelExecutionPerformed =
            "model_execution_performed"
        case independentScientificOracleClaimed =
            "independent_scientific_oracle_claimed"
    }
}

public struct PrimeNativeNeuralGateContractCandidate:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let artifactKind: String
    public let claimScope: String
    public let planSHA256: String
    public let probeProcessIdentifier: Int32
    public let preSourceState:
        PrimeNativeNeuralGateContractSourceState
    public let postSourceState:
        PrimeNativeNeuralGateContractSourceState
    public let sourceSnapshot: PrimeArtifactBinding
    public let probeExecutable: PrimeArtifactBinding
    public let generationReceipt: PrimeArtifactBinding
    public let corpusReplayReceipt:
        PrimeArtifactBinding
    public let copiedParentEvidence:
        [PrimeArtifactBinding]
    public let projection: PrimeArtifactBinding
    public let probeObservation:
        PrimeArtifactBinding
    public let receiptPublished: Bool
    public let authorityStatement: String

    public init(
        planSHA256: String,
        probeProcessIdentifier: Int32,
        preSourceState:
            PrimeNativeNeuralGateContractSourceState,
        postSourceState:
            PrimeNativeNeuralGateContractSourceState,
        sourceSnapshot: PrimeArtifactBinding,
        probeExecutable: PrimeArtifactBinding,
        generationReceipt: PrimeArtifactBinding,
        corpusReplayReceipt:
            PrimeArtifactBinding,
        copiedParentEvidence:
            [PrimeArtifactBinding],
        projection: PrimeArtifactBinding,
        probeObservation:
            PrimeArtifactBinding
    ) {
        schemaVersion = 1
        artifactKind =
            "ergentics_prime_native_neural_gate_contract_candidate"
        claimScope =
            PrimeNativeNeuralGateContractPlan
            .frozenV1.claimScope
        self.planSHA256 = planSHA256
        self.probeProcessIdentifier =
            probeProcessIdentifier
        self.preSourceState = preSourceState
        self.postSourceState = postSourceState
        self.sourceSnapshot = sourceSnapshot
        self.probeExecutable = probeExecutable
        self.generationReceipt =
            generationReceipt
        self.corpusReplayReceipt =
            corpusReplayReceipt
        self.copiedParentEvidence =
            copiedParentEvidence
        self.projection = projection
        self.probeObservation =
            probeObservation
        receiptPublished = false
        authorityStatement =
            "This immutable candidate binds a positive probe process identifier and projected contract evidence. It is incomplete until a distinct positive Release verifier process exactly replays the observation and publishes the final receipt. It is not a PASS receipt."
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case artifactKind = "artifact_kind"
        case claimScope = "claim_scope"
        case planSHA256 = "plan_sha256"
        case probeProcessIdentifier =
            "probe_process_identifier"
        case preSourceState =
            "pre_source_state"
        case postSourceState =
            "post_source_state"
        case sourceSnapshot = "source_snapshot"
        case probeExecutable =
            "probe_executable"
        case generationReceipt =
            "generation_receipt"
        case corpusReplayReceipt =
            "corpus_replay_receipt"
        case copiedParentEvidence =
            "copied_parent_evidence"
        case projection
        case probeObservation =
            "probe_observation"
        case receiptPublished =
            "receipt_published"
        case authorityStatement =
            "authority_statement"
    }
}

public enum PrimeNativeNeuralGateContractOutcome:
    String,
    Codable,
    Equatable,
    Sendable
{
    case pass = "PASS"
}

public struct PrimeNativeNeuralGateContractReceipt:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let artifactKind: String
    public let outcome:
        PrimeNativeNeuralGateContractOutcome
    public let claimScope: String
    public let planSHA256: String
    public let primeSourceRevision: String
    public let primeSourceTreeOID: String
    public let probeProcessIdentifier: Int32
    public let verifierProcessIdentifier: Int32
    public let candidate: PrimeArtifactBinding
    public let verifierExecutable:
        PrimeArtifactBinding
    public let verifierObservation:
        PrimeArtifactBinding
    public let freshProcessReplayExact: Bool
    public let parentGenerationContractValidated:
        Bool
    public let parentFullCorpusReplayValidated:
        Bool
    public let parentEvidenceCopiedLosslessly:
        Bool
    public let sourceContractProjected: Bool
    public let historicalMutationCatalogProjected:
        Bool
    public let finiteFieldMechanicsProjected:
        Bool
    public let finiteFieldContractVectorComputed:
        Bool
    public let sourceBlobBytesResolvedAtExecution:
        Bool
    public let invariantRecordsObserved: Bool
    public let historicalSemanticMutationsExecuted:
        Bool
    public let historicalSZFingerprintRecomputed:
        Bool
    public let neuralKitExecuted: Bool
    public let agentContractKitFourTierAuditPerformed:
        Bool
    public let guardedStatisticalEntanglementPerformed:
        Bool
    public let physicalGenerationShardsObserved:
        Bool
    public let checkpointObserved: Bool
    public let modelExecutionPerformed: Bool
    public let functionalTrainingPerformed: Bool
    public let quantizationPerformed: Bool
    public let productUseAuthorized: Bool
    public let companionRuntimeDependencyAdded:
        Bool
    public let pythonScientificAuthorityUsed:
        Bool
    public let shellScientificAuthorityUsed:
        Bool
    public let phaseThreeCompatibilityComplete:
        Bool
    public let independentScientificOracleClaimed:
        Bool
    public let nextMissingPrerequisite: String
    public let authorityStatement: String

    public init(
        planSHA256: String,
        primeSourceRevision: String,
        primeSourceTreeOID: String,
        probeProcessIdentifier: Int32,
        verifierProcessIdentifier: Int32,
        exactReplayObserved: Bool,
        candidate: PrimeArtifactBinding,
        verifierExecutable:
            PrimeArtifactBinding,
        verifierObservation:
            PrimeArtifactBinding
    ) {
        schemaVersion = 1
        artifactKind =
            "ergentics_prime_native_neural_gate_contract_projection_receipt"
        outcome = .pass
        claimScope =
            PrimeNativeNeuralGateContractPlan
            .frozenV1.claimScope
        self.planSHA256 = planSHA256
        self.primeSourceRevision =
            primeSourceRevision
        self.primeSourceTreeOID =
            primeSourceTreeOID
        self.probeProcessIdentifier =
            probeProcessIdentifier
        self.verifierProcessIdentifier =
            verifierProcessIdentifier
        self.candidate = candidate
        self.verifierExecutable =
            verifierExecutable
        self.verifierObservation =
            verifierObservation
        freshProcessReplayExact =
            exactReplayObserved
                && probeProcessIdentifier > 0
                && verifierProcessIdentifier > 0
                && probeProcessIdentifier
                    != verifierProcessIdentifier
        parentGenerationContractValidated =
            true
        parentFullCorpusReplayValidated = true
        parentEvidenceCopiedLosslessly = true
        sourceContractProjected = true
        historicalMutationCatalogProjected =
            true
        finiteFieldMechanicsProjected = true
        finiteFieldContractVectorComputed = true
        sourceBlobBytesResolvedAtExecution =
            false
        invariantRecordsObserved = false
        historicalSemanticMutationsExecuted =
            false
        historicalSZFingerprintRecomputed =
            false
        neuralKitExecuted = false
        agentContractKitFourTierAuditPerformed =
            false
        guardedStatisticalEntanglementPerformed =
            false
        physicalGenerationShardsObserved =
            false
        checkpointObserved = false
        modelExecutionPerformed = false
        functionalTrainingPerformed = false
        quantizationPerformed = false
        productUseAuthorized = false
        companionRuntimeDependencyAdded = false
        pythonScientificAuthorityUsed = false
        shellScientificAuthorityUsed = false
        phaseThreeCompatibilityComplete =
            false
        independentScientificOracleClaimed =
            false
        nextMissingPrerequisite =
            "source_pinned_synthetic_fixture_materialization_and_gate_replay"
        authorityStatement =
            PrimeNativeNeuralGateContractPlan
            .frozenV1.authorityStatement
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case artifactKind = "artifact_kind"
        case outcome
        case claimScope = "claim_scope"
        case planSHA256 = "plan_sha256"
        case primeSourceRevision =
            "prime_source_revision"
        case primeSourceTreeOID =
            "prime_source_tree_oid"
        case probeProcessIdentifier =
            "probe_process_identifier"
        case verifierProcessIdentifier =
            "verifier_process_identifier"
        case candidate
        case verifierExecutable =
            "verifier_executable"
        case verifierObservation =
            "verifier_observation"
        case freshProcessReplayExact =
            "fresh_process_replay_exact"
        case parentGenerationContractValidated =
            "parent_generation_contract_validated"
        case parentFullCorpusReplayValidated =
            "parent_full_corpus_replay_validated"
        case parentEvidenceCopiedLosslessly =
            "parent_evidence_copied_losslessly"
        case sourceContractProjected =
            "source_contract_projected"
        case historicalMutationCatalogProjected =
            "historical_mutation_catalog_projected"
        case finiteFieldMechanicsProjected =
            "finite_field_mechanics_projected"
        case finiteFieldContractVectorComputed =
            "finite_field_contract_vector_computed"
        case sourceBlobBytesResolvedAtExecution =
            "source_blob_bytes_resolved_at_execution"
        case invariantRecordsObserved =
            "invariant_records_observed"
        case historicalSemanticMutationsExecuted =
            "historical_semantic_mutations_executed"
        case historicalSZFingerprintRecomputed =
            "historical_sz_fingerprint_recomputed"
        case neuralKitExecuted =
            "neural_kit_executed"
        case agentContractKitFourTierAuditPerformed =
            "agent_contract_kit_four_tier_audit_performed"
        case guardedStatisticalEntanglementPerformed =
            "guarded_statistical_entanglement_performed"
        case physicalGenerationShardsObserved =
            "physical_generation_shards_observed"
        case checkpointObserved =
            "checkpoint_observed"
        case modelExecutionPerformed =
            "model_execution_performed"
        case functionalTrainingPerformed =
            "functional_training_performed"
        case quantizationPerformed =
            "quantization_performed"
        case productUseAuthorized =
            "product_use_authorized"
        case companionRuntimeDependencyAdded =
            "companion_runtime_dependency_added"
        case pythonScientificAuthorityUsed =
            "python_scientific_authority_used"
        case shellScientificAuthorityUsed =
            "shell_scientific_authority_used"
        case phaseThreeCompatibilityComplete =
            "phase_three_compatibility_complete"
        case independentScientificOracleClaimed =
            "independent_scientific_oracle_claimed"
        case nextMissingPrerequisite =
            "next_missing_prerequisite"
        case authorityStatement =
            "authority_statement"
    }
}

public struct PrimeNativeNeuralGateContractCandidateResult:
    Sendable
{
    public let candidate:
        PrimeNativeNeuralGateContractCandidate
    public let candidateBinding:
        PrimeArtifactBinding
    public let observation:
        PrimeNativeNeuralGateContractObservation
}

public struct PrimeNativeNeuralGateContractReceiptResult:
    Sendable
{
    public let receipt:
        PrimeNativeNeuralGateContractReceipt
    public let receiptBinding:
        PrimeArtifactBinding
    public let observation:
        PrimeNativeNeuralGateContractObservation
}

public enum PrimeNativeNeuralGateContractOverlay {
    private static let maximumJSONBytes:
        UInt64 = 8 * 1024 * 1024
    private static let maximumSnapshotBytes:
        UInt64 = 128 * 1024 * 1024
    private static let maximumArtifactBytes =
        PrimeSecureRunningExecutableCapture
        .maximumByteCount
    private static let primeRemoteURL =
        "https://github.com/Ergentics/ergentics-prime.git"

    public static func publishCandidate(
        generationRoot: PrimeArtifactRoot,
        corpusReplayRoot: PrimeArtifactRoot,
        primeSourceRoot: URL,
        to root: PrimeArtifactRoot
    ) throws
        -> PrimeNativeNeuralGateContractCandidateResult
    {
        let plan =
            PrimeNativeNeuralGateContractPlan
            .frozenV1
        try plan.validate()
        let processIdentifier =
            ProcessInfo.processInfo.processIdentifier
        guard processIdentifier > 0 else {
            throw PrimeNativeNeuralGateContractError
                .invalidCandidate(
                    "probe process identifier"
                )
        }
        try generationRoot.requirePrivateRootMode()
        try corpusReplayRoot.requirePrivateRootMode()
        try root.requirePrivateRootMode()
        try root.requireEmpty()

        let generation =
            try validateGenerationParent(
                in: generationRoot
            )
        let corpus =
            try validateCorpusReplayParent(
                in: corpusReplayRoot
            )
        let transport =
            PrimeNativeGitBlobTransport()
        let preState = try transport.sourceState(
            repositoryRoot: primeSourceRoot,
            phase: .preSnapshot
        )
        try requireCleanSource(preState)
        let snapshot =
            try PrimeSwiftSourceProvenance.capture(
                at: primeSourceRoot,
                requiredRelativePaths:
                    PrimeNativeNeuralGateContractPlan
                    .requiredPrimeSourcePaths
            )
        let executable =
            try PrimeSecureRunningExecutableCapture
            .data()
        let projection =
            PrimeNativeNeuralGateContractProjection
            .frozenV1
        try projection.validate()
        let observation =
            try PrimeNativeNeuralGateContractObservation
            .runAndValidate()
        let postSnapshot =
            try PrimeSwiftSourceProvenance.capture(
                at: primeSourceRoot,
                requiredRelativePaths:
                    PrimeNativeNeuralGateContractPlan
                    .requiredPrimeSourcePaths
            )
        guard postSnapshot == snapshot else {
            throw PrimeNativeNeuralGateContractError
                .replayMismatch(
                    "Prime source changed during probe"
                )
        }
        let postState = try transport.sourceState(
            repositoryRoot: primeSourceRoot,
            phase: .postExecutable
        )
        try requireStableSource(
            preState,
            postState
        )

        for directory in [
            "adapter",
            "resolved",
            "generation-contract",
            "source",
            "bin",
            "corpus-replay",
            "neural-gate-contract",
        ] {
            try root.ensurePrivateDirectory(
                at: directory
            )
        }

        let generationReceipt =
            try copy(
                generation.receiptBinding,
                from: generationRoot,
                to: root
            )
        let corpusReceipt =
            try copy(
                corpus.receiptBinding,
                from: corpusReplayRoot,
                to: root
            )
        var copied =
            [PrimeArtifactBinding]()
        for binding in
            generation.evidenceBindings
        {
            copied.append(
                try copy(
                    binding,
                    from: generationRoot,
                    to: root
                )
            )
        }
        for binding in corpus.evidenceBindings {
            copied.append(
                try copy(
                    binding,
                    from: corpusReplayRoot,
                    to: root
                )
            )
        }
        copied.sort {
            $0.relativePath < $1.relativePath
        }
        guard Set(copied.map(\.relativePath))
                .count == copied.count
        else {
            throw PrimeNativeNeuralGateContractError
                .invalidParent(
                    "copied evidence path collision"
                )
        }

        let sourceBinding =
            try root.publishCanonical(
                snapshot,
                at: plan.sourceSnapshotPath
            )
        let executableBinding =
            try root.publish(
                executable,
                at: plan.probeExecutablePath,
                purpose: .executable
            )
        let projectionBinding =
            try root.publishCanonical(
                projection,
                at: plan.projectionPath
            )
        let observationBinding =
            try root.publishCanonical(
                observation,
                at: plan.probeObservationPath
            )
        let candidate =
            PrimeNativeNeuralGateContractCandidate(
                planSHA256:
                    try plan.contentSHA256(),
                probeProcessIdentifier:
                    processIdentifier,
                preSourceState:
                    PrimeNativeNeuralGateContractSourceState(
                        preState
                    ),
                postSourceState:
                    PrimeNativeNeuralGateContractSourceState(
                        postState
                    ),
                sourceSnapshot: sourceBinding,
                probeExecutable:
                    executableBinding,
                generationReceipt:
                    generationReceipt,
                corpusReplayReceipt:
                    corpusReceipt,
                copiedParentEvidence: copied,
                projection: projectionBinding,
                probeObservation:
                    observationBinding
            )
        try validate(candidate, in: root)
        let candidateBinding =
            try root.publishCanonical(
                candidate,
                at: plan.candidatePath
            )
        let rebound = try root.bindExisting(
            at: plan.candidatePath,
            purpose: .immutableData,
            maximumByteCount: maximumJSONBytes
        )
        guard rebound == candidateBinding,
              try root.decodeVerified(
                  PrimeNativeNeuralGateContractCandidate
                    .self,
                  binding: rebound,
                  maximumByteCount:
                    maximumJSONBytes
              ) == candidate
        else {
            throw PrimeNativeNeuralGateContractError
                .invalidCandidate(
                    "candidate persistence"
                )
        }
        try root.requireAbsent(at: plan.receiptPath)
        return PrimeNativeNeuralGateContractCandidateResult(
            candidate: candidate,
            candidateBinding: candidateBinding,
            observation: observation
        )
    }

    public static func verifyAndSeal(
        primeSourceRoot: URL,
        in root: PrimeArtifactRoot
    ) throws
        -> PrimeNativeNeuralGateContractReceiptResult
    {
        let plan =
            PrimeNativeNeuralGateContractPlan
            .frozenV1
        try plan.validate()
        let verifierProcessIdentifier =
            ProcessInfo.processInfo.processIdentifier
        try root.requirePrivateRootMode()
        try root.requireAbsent(
            at: plan.verifierExecutablePath
        )
        try root.requireAbsent(
            at: plan.verifierObservationPath
        )
        try root.requireAbsent(at: plan.receiptPath)

        let candidateBinding =
            try root.bindExisting(
                at: plan.candidatePath,
                purpose: .immutableData,
                maximumByteCount:
                    maximumJSONBytes
            )
        let candidate =
            try root.decodeVerified(
                PrimeNativeNeuralGateContractCandidate
                    .self,
                binding: candidateBinding,
                maximumByteCount:
                    maximumJSONBytes
            )
        try requireDistinctProcessIdentifiers(
            probe: candidate.probeProcessIdentifier,
            verifier: verifierProcessIdentifier
        )
        try validate(candidate, in: root)

        let transport =
            PrimeNativeGitBlobTransport()
        let preState = try transport.sourceState(
            repositoryRoot: primeSourceRoot,
            phase: .preSnapshot
        )
        try requireCleanSource(preState)
        guard PrimeNativeNeuralGateContractSourceState(
            preState
        ) == candidate.postSourceState
        else {
            throw PrimeNativeNeuralGateContractError
                .replayMismatch(
                    "verifier source state differs from probe"
                )
        }
        let probeSnapshot =
            try root.decodeVerified(
                PrimeSwiftSourceSnapshot.self,
                binding: candidate.sourceSnapshot,
                maximumByteCount:
                    maximumSnapshotBytes
            )
        let verifierSnapshot =
            try PrimeSwiftSourceProvenance.capture(
                at: primeSourceRoot,
                requiredRelativePaths:
                    PrimeNativeNeuralGateContractPlan
                    .requiredPrimeSourcePaths
            )
        guard verifierSnapshot == probeSnapshot
        else {
            throw PrimeNativeNeuralGateContractError
                .replayMismatch(
                    "verifier source snapshot differs from probe"
                )
        }

        let verifierExecutable =
            try PrimeSecureRunningExecutableCapture
            .data()
        let verifierExecutableBinding =
            try root.publish(
                verifierExecutable,
                at: plan.verifierExecutablePath,
                purpose: .executable
            )
        let observation =
            try PrimeNativeNeuralGateContractObservation
            .runAndValidate()
        let probeObservation =
            try root.decodeVerified(
                PrimeNativeNeuralGateContractObservation
                    .self,
                binding: candidate.probeObservation,
                maximumByteCount:
                    maximumJSONBytes
            )
        try probeObservation.validate()
        let observationData =
            try PrimeCanonicalJSON.encode(
                observation
            )
        let probeObservationData =
            try PrimeCanonicalJSON.encode(
                probeObservation
            )
        let exactReplay =
            observation == probeObservation
                && observationData
                    == probeObservationData
        guard exactReplay else {
            throw PrimeNativeNeuralGateContractError
                .replayMismatch(
                    "probe and verifier observations differ"
                )
        }

        let postSnapshot =
            try PrimeSwiftSourceProvenance.capture(
                at: primeSourceRoot,
                requiredRelativePaths:
                    PrimeNativeNeuralGateContractPlan
                    .requiredPrimeSourcePaths
            )
        guard postSnapshot == verifierSnapshot
        else {
            throw PrimeNativeNeuralGateContractError
                .replayMismatch(
                    "Prime source changed during verifier"
                )
        }
        let postState = try transport.sourceState(
            repositoryRoot: primeSourceRoot,
            phase: .postExecutable
        )
        try requireStableSource(
            preState,
            postState
        )
        guard PrimeNativeNeuralGateContractSourceState(
            postState
        ) == candidate.postSourceState
        else {
            throw PrimeNativeNeuralGateContractError
                .replayMismatch(
                    "verifier closure source state differs from probe"
                )
        }

        let verifierObservationBinding =
            try root.publishCanonical(
                observation,
                at: plan.verifierObservationPath
            )
        let receipt =
            PrimeNativeNeuralGateContractReceipt(
                planSHA256:
                    try plan.contentSHA256(),
                primeSourceRevision:
                    postState.revision,
                primeSourceTreeOID:
                    postState.treeOID,
                probeProcessIdentifier:
                    candidate.probeProcessIdentifier,
                verifierProcessIdentifier:
                    verifierProcessIdentifier,
                exactReplayObserved: exactReplay,
                candidate: candidateBinding,
                verifierExecutable:
                    verifierExecutableBinding,
                verifierObservation:
                    verifierObservationBinding
            )
        try validate(receipt, in: root)

        // Receipt publication is deliberately last.
        let receiptBinding =
            try root.publishCanonicalExclusively(
                receipt,
                at: plan.receiptPath
            )
        let rebound = try root.bindExisting(
            at: plan.receiptPath,
            purpose: .immutableData,
            maximumByteCount: maximumJSONBytes
        )
        let persisted =
            try root.decodeVerified(
                PrimeNativeNeuralGateContractReceipt
                    .self,
                binding: rebound,
                maximumByteCount:
                    maximumJSONBytes
            )
        guard rebound == receiptBinding,
              persisted == receipt
        else {
            throw PrimeNativeNeuralGateContractError
                .invalidReceipt(
                    "receipt persistence"
                )
        }
        try validate(persisted, in: root)
        return PrimeNativeNeuralGateContractReceiptResult(
            receipt: receipt,
            receiptBinding: receiptBinding,
            observation: observation
        )
    }

    public static func validate(
        _ candidate:
            PrimeNativeNeuralGateContractCandidate,
        in root: PrimeArtifactRoot
    ) throws {
        let plan =
            PrimeNativeNeuralGateContractPlan
            .frozenV1
        try plan.validate()
        let expected =
            PrimeNativeNeuralGateContractCandidate(
                planSHA256:
                    try plan.contentSHA256(),
                probeProcessIdentifier:
                    candidate.probeProcessIdentifier,
                preSourceState:
                    candidate.preSourceState,
                postSourceState:
                    candidate.postSourceState,
                sourceSnapshot:
                    candidate.sourceSnapshot,
                probeExecutable:
                    candidate.probeExecutable,
                generationReceipt:
                    candidate.generationReceipt,
                corpusReplayReceipt:
                    candidate.corpusReplayReceipt,
                copiedParentEvidence:
                    candidate.copiedParentEvidence,
                projection: candidate.projection,
                probeObservation:
                    candidate.probeObservation
            )
        let paths =
            candidate.copiedParentEvidence
            .map(\.relativePath)
        guard candidate == expected,
              candidate.probeProcessIdentifier > 0,
              candidate.preSourceState
                == candidate.postSourceState,
              candidate.preSourceState.clean,
              candidate.preSourceState.remoteURL
                == primeRemoteURL,
              isGitOID(
                  candidate.preSourceState.revision
              ),
              isGitOID(
                  candidate.preSourceState.treeOID
              ),
              candidate.sourceSnapshot.relativePath
                == plan.sourceSnapshotPath,
              candidate.sourceSnapshot.purpose
                == .immutableData,
              candidate.probeExecutable.relativePath
                == plan.probeExecutablePath,
              candidate.probeExecutable.purpose
                == .executable,
              candidate.generationReceipt.relativePath
                == plan.generationReceiptPath,
              candidate.generationReceipt.sha256
                == plan.generationReceiptSHA256,
              candidate.generationReceipt.byteCount
                == plan.generationReceiptByteCount,
              candidate.corpusReplayReceipt.relativePath
                == plan.corpusReplayReceiptPath,
              candidate.corpusReplayReceipt.sha256
                == plan.corpusReplayReceiptSHA256,
              candidate.corpusReplayReceipt.byteCount
                == plan.corpusReplayReceiptByteCount,
              paths == paths.sorted(),
              Set(paths).count == paths.count,
              candidate.projection.relativePath
                == plan.projectionPath,
              candidate.projection.purpose
                == .immutableData,
              candidate.probeObservation.relativePath
                == plan.probeObservationPath,
              candidate.probeObservation.purpose
                == .immutableData,
              !candidate.receiptPublished,
              candidate.authorityStatement.contains(
                  "not a PASS receipt"
              )
        else {
            throw PrimeNativeNeuralGateContractError
                .invalidCandidate(
                    "structural contract"
                )
        }

        let snapshot =
            try root.decodeVerified(
                PrimeSwiftSourceSnapshot.self,
                binding: candidate.sourceSnapshot,
                maximumByteCount:
                    maximumSnapshotBytes
            )
        try PrimeSwiftSourceProvenance.validate(
            snapshot,
            requiredRelativePaths:
                PrimeNativeNeuralGateContractPlan
                .requiredPrimeSourcePaths
        )
        _ = try root.verify(
            candidate.probeExecutable
        )

        let generation =
            try root.decodeVerified(
                PrimeNativeGenerationContractOverlayReceipt
                    .self,
                binding: candidate.generationReceipt,
                maximumByteCount:
                    maximumJSONBytes
            )
        try generation.validate(in: root)
        let corpus =
            try root.decodeVerified(
                PrimeNativeCorpusReplayReceipt.self,
                binding:
                    candidate.corpusReplayReceipt,
                maximumByteCount:
                    maximumJSONBytes
            )
        try PrimeNativeCorpusReplayOverlay.validate(
            corpus,
            in: root
        )
        guard try expectedParentEvidence(
                  generation: generation,
                  corpus: corpus,
                  in: root
              ) == candidate.copiedParentEvidence
        else {
            throw PrimeNativeNeuralGateContractError
                .invalidCandidate(
                    "copied parent evidence"
                )
        }

        let projection =
            try root.decodeVerified(
                PrimeNativeNeuralGateContractProjection
                    .self,
                binding: candidate.projection,
                maximumByteCount:
                    maximumJSONBytes
            )
        try projection.validate()
        guard projection == .frozenV1
        else {
            throw PrimeNativeNeuralGateContractError
                .invalidCandidate(
                    "projection identity"
                )
        }
        let observation =
            try root.decodeVerified(
                PrimeNativeNeuralGateContractObservation
                    .self,
                binding: candidate.probeObservation,
                maximumByteCount:
                    maximumJSONBytes
            )
        try observation.validate()
    }

    public static func validate(
        _ receipt:
            PrimeNativeNeuralGateContractReceipt,
        in root: PrimeArtifactRoot
    ) throws {
        let plan =
            PrimeNativeNeuralGateContractPlan
            .frozenV1
        try plan.validate()
        let expected =
            PrimeNativeNeuralGateContractReceipt(
                planSHA256:
                    try plan.contentSHA256(),
                primeSourceRevision:
                    receipt.primeSourceRevision,
                primeSourceTreeOID:
                    receipt.primeSourceTreeOID,
                probeProcessIdentifier:
                    receipt.probeProcessIdentifier,
                verifierProcessIdentifier:
                    receipt.verifierProcessIdentifier,
                exactReplayObserved:
                    receipt.freshProcessReplayExact,
                candidate: receipt.candidate,
                verifierExecutable:
                    receipt.verifierExecutable,
                verifierObservation:
                    receipt.verifierObservation
            )
        guard receipt == expected,
              receipt.outcome == .pass,
              isGitOID(
                  receipt.primeSourceRevision
              ),
              isGitOID(
                  receipt.primeSourceTreeOID
              ),
              receipt.freshProcessReplayExact,
              receipt.parentGenerationContractValidated,
              receipt.parentFullCorpusReplayValidated,
              receipt.parentEvidenceCopiedLosslessly,
              receipt.sourceContractProjected,
              receipt
                .historicalMutationCatalogProjected,
              receipt.finiteFieldMechanicsProjected,
              receipt
                .finiteFieldContractVectorComputed,
              !receipt
                .sourceBlobBytesResolvedAtExecution,
              !receipt.invariantRecordsObserved,
              !receipt
                .historicalSemanticMutationsExecuted,
              !receipt
                .historicalSZFingerprintRecomputed,
              !receipt.neuralKitExecuted,
              !receipt
                .agentContractKitFourTierAuditPerformed,
              !receipt
                .guardedStatisticalEntanglementPerformed,
              !receipt.physicalGenerationShardsObserved,
              !receipt.checkpointObserved,
              !receipt.modelExecutionPerformed,
              !receipt.functionalTrainingPerformed,
              !receipt.quantizationPerformed,
              !receipt.productUseAuthorized,
              !receipt.companionRuntimeDependencyAdded,
              !receipt.pythonScientificAuthorityUsed,
              !receipt.shellScientificAuthorityUsed,
              !receipt.phaseThreeCompatibilityComplete,
              !receipt.independentScientificOracleClaimed,
              receipt.nextMissingPrerequisite
                == "source_pinned_synthetic_fixture_materialization_and_gate_replay"
        else {
            throw PrimeNativeNeuralGateContractError
                .invalidReceipt(
                    "structural contract"
                )
        }
        try requireDistinctProcessIdentifiers(
            probe: receipt.probeProcessIdentifier,
            verifier:
                receipt.verifierProcessIdentifier
        )
        let candidate =
            try root.decodeVerified(
                PrimeNativeNeuralGateContractCandidate
                    .self,
                binding: receipt.candidate,
                maximumByteCount:
                    maximumJSONBytes
            )
        try validate(candidate, in: root)
        guard receipt.primeSourceRevision
                == candidate.postSourceState.revision,
              receipt.primeSourceTreeOID
                == candidate.postSourceState.treeOID,
              receipt.probeProcessIdentifier
                == candidate.probeProcessIdentifier,
              receipt.candidate.relativePath
                == plan.candidatePath,
              receipt.verifierExecutable.relativePath
                == plan.verifierExecutablePath,
              receipt.verifierExecutable.purpose
                == .executable,
              receipt.verifierObservation.relativePath
                == plan.verifierObservationPath,
              receipt.verifierObservation.purpose
                == .immutableData
        else {
            throw PrimeNativeNeuralGateContractError
                .invalidReceipt(
                    "source or artifact binding"
                )
        }
        _ = try root.verify(
            receipt.verifierExecutable
        )
        let probeObservation =
            try root.decodeVerified(
                PrimeNativeNeuralGateContractObservation
                    .self,
                binding: candidate.probeObservation,
                maximumByteCount:
                    maximumJSONBytes
            )
        let verifierObservation =
            try root.decodeVerified(
                PrimeNativeNeuralGateContractObservation
                    .self,
                binding: receipt.verifierObservation,
                maximumByteCount:
                    maximumJSONBytes
            )
        try probeObservation.validate()
        try verifierObservation.validate()
        guard probeObservation == verifierObservation
        else {
            throw PrimeNativeNeuralGateContractError
                .invalidReceipt(
                    "fresh observations differ"
                )
        }
    }

    static func projectionMutationSweep() throws
        -> [PrimeNativeNeuralGateProjectionMutationRecord]
    {
        var records =
            [PrimeNativeNeuralGateProjectionMutationRecord]()
        for mutation in
            PrimeNativeNeuralGateProjectionMutation
            .allCases
        {
            let detected: Bool
            switch mutation {
            case .sourcePinSetDrift:
                detected = try detectsProjectionMutation {
                    guard var bindings =
                            $0["source_bindings"]
                                as? [[String: Any]],
                          !bindings.isEmpty
                    else {
                        throw PrimeNativeNeuralGateContractError
                            .invalidObservation(
                                "mutation fixture"
                            )
                    }
                    bindings.removeLast()
                    $0["source_bindings"] = bindings
                }
            case .sourceBlobIdentityDrift:
                detected = try detectsProjectionMutation {
                    guard var bindings =
                            $0["source_bindings"]
                                as? [[String: Any]],
                          !bindings.isEmpty
                    else {
                        throw PrimeNativeNeuralGateContractError
                            .invalidObservation(
                                "mutation fixture"
                            )
                    }
                    bindings[0]["sha256"] =
                        String(repeating: "0", count: 64)
                    $0["source_bindings"] = bindings
                }
            case .criticalLegOrderDrift:
                detected = try detectsProjectionMutation {
                    guard var legs =
                            $0["critical_legs"]
                                as? [[String: Any]],
                          legs.count >= 2
                    else {
                        throw PrimeNativeNeuralGateContractError
                            .invalidObservation(
                                "mutation fixture"
                            )
                    }
                    legs.swapAt(0, 1)
                    $0["critical_legs"] = legs
                }
            case .mutationCatalogTruncation:
                detected = try detectsProjectionMutation {
                    guard var catalog =
                            $0["mutation_catalog"]
                                as? [[String: Any]],
                          !catalog.isEmpty
                    else {
                        throw PrimeNativeNeuralGateContractError
                            .invalidObservation(
                                "mutation fixture"
                            )
                    }
                    catalog.removeLast()
                    $0["mutation_catalog"] = catalog
                }
            case .mutationExpectedLegDrift:
                detected = try detectsProjectionMutation {
                    guard var catalog =
                            $0["mutation_catalog"]
                                as? [[String: Any]],
                          !catalog.isEmpty
                    else {
                        throw PrimeNativeNeuralGateContractError
                            .invalidObservation(
                                "mutation fixture"
                            )
                    }
                    catalog[0]["expected_failed_leg"] =
                        "NL2_finite_field_sz_pool_expansion"
                    $0["mutation_catalog"] = catalog
                }
            case .finiteFieldPrimeDrift:
                detected = try detectsProjectionMutation {
                    guard var field =
                            $0["finite_field"]
                                as? [String: Any]
                    else {
                        throw PrimeNativeNeuralGateContractError
                            .invalidObservation(
                                "mutation fixture"
                            )
                    }
                    field["prime"] = 2_147_483_629
                    $0["finite_field"] = field
                }
            case .capabilityThresholdDrift:
                detected = try detectsProjectionMutation {
                    guard var capabilityThresholds =
                            $0["capability_thresholds"]
                                as? [String: Any],
                          var splits =
                            capabilityThresholds["splits"]
                                as? [[String: Any]],
                          splits.count > 1
                    else {
                        throw PrimeNativeNeuralGateContractError
                            .invalidObservation(
                                "mutation fixture"
                            )
                    }
                    splits[1][
                        "minimum_trained_exact_accuracy"
                    ] = 0.79
                    capabilityThresholds["splits"] =
                        splits
                    $0["capability_thresholds"] =
                        capabilityThresholds
                }
            case .allCriticalRuleRemoved:
                detected = try detectsProjectionMutation {
                    guard var verdict =
                            $0["verdict"]
                                as? [String: Any]
                    else {
                        throw PrimeNativeNeuralGateContractError
                            .invalidObservation(
                                "mutation fixture"
                            )
                    }
                    verdict[
                        "all_critical_legs_required_for_grounded"
                    ] = false
                    $0["verdict"] = verdict
                }
            case .countLabelPromotedToFourTierAudit:
                detected = try detectsProjectionMutation {
                    guard var verdict =
                            $0["verdict"]
                                as? [String: Any]
                    else {
                        throw PrimeNativeNeuralGateContractError
                            .invalidObservation(
                                "mutation fixture"
                            )
                    }
                    verdict[
                        "agent_contract_kit_four_tier_audit_performed"
                    ] = true
                    $0["verdict"] = verdict
                }
            case .syntheticSummaryPromotedToExecution:
                detected = try detectsProjectionMutation {
                    $0[
                        "historical_semantic_mutations_executed"
                    ] = true
                }
            case .sourceResolutionOverclaim:
                detected = try detectsProjectionMutation {
                    $0[
                        "source_blob_bytes_resolved_at_execution"
                    ] = true
                }
            case .phaseThreeAuthorityExpansion:
                detected = try detectsProjectionMutation {
                    $0[
                        "phase_three_compatibility_complete"
                    ] = true
                }
            }
            guard detected else {
                throw PrimeNativeNeuralGateContractError
                    .mutationUndetected(
                        mutation.rawValue
                    )
            }
            let record =
                PrimeNativeNeuralGateProjectionMutationRecord(
                    mutation: mutation,
                    detected: true,
                    restored: true
                )
            try record.validate()
            records.append(record)
        }
        return records
    }

    static func requireDistinctProcessIdentifiers(
        probe: Int32,
        verifier: Int32
    ) throws {
        guard probe > 0,
              verifier > 0,
              probe != verifier
        else {
            throw PrimeNativeNeuralGateContractError
                .replayMismatch(
                    "probe and verifier process identifiers must be positive and distinct"
                )
        }
    }

    private static func validateGenerationParent(
        in root: PrimeArtifactRoot
    ) throws -> (
        receipt:
            PrimeNativeGenerationContractOverlayReceipt,
        receiptBinding: PrimeArtifactBinding,
        evidenceBindings: [PrimeArtifactBinding]
    ) {
        let plan =
            PrimeNativeNeuralGateContractPlan
            .frozenV1
        let binding = try root.bindExisting(
            at: plan.generationReceiptPath,
            purpose: .immutableData,
            maximumByteCount: maximumJSONBytes
        )
        guard binding.sha256
                == plan.generationReceiptSHA256,
              binding.byteCount
                == plan.generationReceiptByteCount
        else {
            throw PrimeNativeNeuralGateContractError
                .invalidParent(
                    "generation receipt identity"
                )
        }
        let receipt =
            try root.decodeVerified(
                PrimeNativeGenerationContractOverlayReceipt
                    .self,
                binding: binding,
                maximumByteCount:
                    maximumJSONBytes
            )
        try receipt.validate(in: root)
        return (
            receipt,
            binding,
            generationEvidence(receipt)
        )
    }

    private static func validateCorpusReplayParent(
        in root: PrimeArtifactRoot
    ) throws -> (
        receipt: PrimeNativeCorpusReplayReceipt,
        receiptBinding: PrimeArtifactBinding,
        evidenceBindings: [PrimeArtifactBinding]
    ) {
        let plan =
            PrimeNativeNeuralGateContractPlan
            .frozenV1
        let binding = try root.bindExisting(
            at: plan.corpusReplayReceiptPath,
            purpose: .immutableData,
            maximumByteCount: maximumJSONBytes
        )
        guard binding.sha256
                == plan.corpusReplayReceiptSHA256,
              binding.byteCount
                == plan.corpusReplayReceiptByteCount
        else {
            throw PrimeNativeNeuralGateContractError
                .invalidParent(
                    "corpus replay receipt identity"
                )
        }
        let receipt =
            try root.decodeVerified(
                PrimeNativeCorpusReplayReceipt.self,
                binding: binding,
                maximumByteCount:
                    maximumJSONBytes
            )
        try PrimeNativeCorpusReplayOverlay.validate(
            receipt,
            in: root
        )
        return (
            receipt,
            binding,
            try corpusEvidence(receipt, in: root)
        )
    }

    private static func expectedParentEvidence(
        generation:
            PrimeNativeGenerationContractOverlayReceipt,
        corpus: PrimeNativeCorpusReplayReceipt,
        in root: PrimeArtifactRoot
    ) throws -> [PrimeArtifactBinding] {
        var evidence = generationEvidence(
            generation
        )
        evidence.append(
            contentsOf:
                try corpusEvidence(corpus, in: root)
        )
        return evidence.sorted {
            $0.relativePath < $1.relativePath
        }
    }

    private static func generationEvidence(
        _ receipt:
            PrimeNativeGenerationContractOverlayReceipt
    ) -> [PrimeArtifactBinding] {
        (
            receipt.copiedParentEvidence + [
                receipt.primeSourceSnapshot,
                receipt.projectionExecutable,
                receipt.parentAdapterReceipt,
                receipt.generationContractProjection,
            ]
        ).sorted {
            $0.relativePath < $1.relativePath
        }
    }

    private static func corpusEvidence(
        _ receipt:
            PrimeNativeCorpusReplayReceipt,
        in root: PrimeArtifactRoot
    ) throws -> [PrimeArtifactBinding] {
        let candidate =
            try root.decodeVerified(
                PrimeNativeCorpusReplayCandidate.self,
                binding: receipt.candidate,
                maximumByteCount:
                    maximumJSONBytes
            )
        return [
            candidate.sourceSnapshot,
            candidate.probeExecutable,
            candidate.tokenizerManifest,
            candidate.corpusManifest,
            candidate.probeObservation,
            receipt.candidate,
            receipt.verifierExecutable,
            receipt.verifierObservation,
        ].sorted {
            $0.relativePath < $1.relativePath
        }
    }

    private static func copy(
        _ binding: PrimeArtifactBinding,
        from inputRoot: PrimeArtifactRoot,
        to outputRoot: PrimeArtifactRoot
    ) throws -> PrimeArtifactBinding {
        let data = try inputRoot.readVerified(
            binding,
            maximumByteCount:
                maximumArtifactBytes
        )
        let copied = try outputRoot.publish(
            data,
            at: binding.relativePath,
            purpose: binding.purpose
        )
        guard copied == binding else {
            throw PrimeNativeNeuralGateContractError
                .invalidParent(
                    "lossless evidence copy"
                )
        }
        return copied
    }

    private static func detectsProjectionMutation(
        _ mutation:
            (inout [String: Any]) throws -> Void
    ) throws -> Bool {
        let data =
            try PrimeCanonicalJSON.encode(
                PrimeNativeNeuralGateContractProjection
                .frozenV1
            )
        guard var object =
                try JSONSerialization
                .jsonObject(with: data)
                as? [String: Any]
        else {
            throw PrimeNativeNeuralGateContractError
                .invalidObservation(
                    "mutation fixture"
                )
        }
        try mutation(&object)
        let changed =
            try JSONSerialization.data(
                withJSONObject: object,
                options: [.sortedKeys]
            )
        do {
            let decoded =
                try JSONDecoder().decode(
                    PrimeNativeNeuralGateContractProjection
                        .self,
                    from: changed
                )
            try decoded.validate()
            return false
        } catch {
            return true
        }
    }

    private static func requireCleanSource(
        _ state:
            PrimeNativeMigrationResolverSourceState
    ) throws {
        guard state.clean,
              state.remoteURL == primeRemoteURL,
              isGitOID(state.revision),
              isGitOID(state.treeOID)
        else {
            throw PrimeNativeNeuralGateContractError
                .replayMismatch(
                    "Prime source is not clean and canonical"
                )
        }
    }

    private static func requireStableSource(
        _ before:
            PrimeNativeMigrationResolverSourceState,
        _ after:
            PrimeNativeMigrationResolverSourceState
    ) throws {
        try requireCleanSource(before)
        try requireCleanSource(after)
        guard before.remoteURL == after.remoteURL,
              before.revision == after.revision,
              before.treeOID == after.treeOID
        else {
            throw PrimeNativeNeuralGateContractError
                .replayMismatch(
                    "Prime source changed during execution"
                )
        }
    }

    private static func isGitOID(
        _ value: String
    ) -> Bool {
        value.utf8.count == 40
            && value.utf8.allSatisfy {
                ($0 >= 48 && $0 <= 57)
                    || ($0 >= 97 && $0 <= 102)
            }
    }
}
