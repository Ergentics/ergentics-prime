import Foundation

public enum PrimeNativeResolvedContractAdapterError:
    Error,
    Equatable,
    Sendable
{
    case invalidPlan
    case invalidParentResolution(String)
    case invalidTokenizerManifest(String)
    case invalidCorpusManifest(String)
    case invalidSyntheticReceipt(String)
    case invalidProjection(String)
    case invalidReceipt(String)
    case mutationUndetected(String)
}

extension PrimeNativeResolvedContractAdapterError:
    LocalizedError
{
    public var errorDescription: String? {
        switch self {
        case .invalidPlan:
            "native resolved-contract adapter plan drifted"
        case let .invalidParentResolution(detail):
            "parent native contract resolution rejected: \(detail)"
        case let .invalidTokenizerManifest(detail):
            "resolved tokenizer manifest rejected: \(detail)"
        case let .invalidCorpusManifest(detail):
            "resolved corpus manifest rejected: \(detail)"
        case let .invalidSyntheticReceipt(detail):
            "resolved synthetic regrade receipt rejected: \(detail)"
        case let .invalidProjection(detail):
            "native compatibility projection rejected: \(detail)"
        case let .invalidReceipt(detail):
            "native compatibility adapter receipt rejected: \(detail)"
        case let .mutationUndetected(mutation):
            "native compatibility mutation was not detected: \(mutation)"
        }
    }
}

public struct PrimeNativeResolvedContractAdapterPlan:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let planID: String
    public let claimScope: String
    public let parentReceiptPath: String
    public let parentReceiptSHA256: String
    public let parentReceiptByteCount: UInt64
    public let parentResolverSourceRevision: String
    public let parentResolverSourceIdentitySHA256:
        String
    public let companionRevision: String
    public let companionTreeOID: String
    public let expectedParentArtifactCount: Int
    public let expectedParentArtifactByteCount: UInt64
    public let tokenizerArtifactID: String
    public let tokenizerArtifactSHA256: String
    public let tokenizerManifestSHA256: String
    public let corpusArtifactID: String
    public let corpusArtifactSHA256: String
    public let corpusManifestSHA256: String
    public let syntheticReceiptArtifactID: String
    public let syntheticReceiptArtifactSHA256: String
    public let scientificAuthorityLanguage: String
    public let compatibilityProjectionPath: String
    public let sourceSnapshotPath: String
    public let executablePath: String
    public let outputReceiptPath: String
    public let parentResolutionMustValidate: Bool
    public let parentArtifactsCopiedLosslessly: Bool
    public let corpusRowsRegenerated: Bool
    public let fixedCapEOSGenerationContractBound: Bool
    public let physicalGenerationShardsObserved: Bool
    public let independentRegradeExecuted: Bool
    public let phaseThreeCompatibilityComplete: Bool
    public let archiveExpansionAuthorized: Bool
    public let donorExecutionAuthorized: Bool
    public let neuralKitExecutionAuthorized: Bool
    public let modelExecutionAuthorized: Bool
    public let functionalTrainingAuthorized: Bool
    public let quantizationAuthorized: Bool
    public let productUseAuthorized: Bool
    public let pythonExecutionAuthorized: Bool
    public let authorityStatement: String

    public static let frozenV1 = Self(
        schemaVersion: 1,
        planID:
            "ergentics_prime_resolved_contract_compatibility_adapter_v1",
        claimScope:
            "frozen_tokenizer_corpus_evaluation_and_synthetic_regrade_envelope_compatibility_only",
        parentReceiptPath:
            "prime-native-contract-resolution-receipt.v1.json",
        parentReceiptSHA256:
            "d8e8caefb9f0c340a7418befeca4966daf178894164eaaebdfae7b565928c8f4",
        parentReceiptByteCount: 27_035,
        parentResolverSourceRevision:
            "7c7b0496a94fe776df2e542df7413fd4a8bcf250",
        parentResolverSourceIdentitySHA256:
            "51efb053b6c6ac4e338020842fab6a25715bf57076c0d62a3f8ea39c6a3ea05a",
        companionRevision:
            "163fc100710ece48119bc25954452d10f6a84f7f",
        companionTreeOID:
            "9009daa4f8a07fbd5897e00b9571cef44ec292db",
        expectedParentArtifactCount: 8,
        expectedParentArtifactByteCount: 11_969_097,
        tokenizerArtifactID:
            "native_byte_tokenizer_manifest",
        tokenizerArtifactSHA256:
            "5e3db93d26535cbb66b14f0170b1e04882aa942560af3c8b571d76dfaaa9f302",
        tokenizerManifestSHA256:
            "f9f768268edb488aaf7168453b703f2d2a78a1036572368c76f53f4f436434c7",
        corpusArtifactID:
            "native_compositional_corpus_manifest",
        corpusArtifactSHA256:
            "fbb7362ee63b5825d1914815e8ff93c26a2c9a7de8be19347ccec3e449de8031",
        corpusManifestSHA256:
            "7f42e6f0504e3751fca24bcce35f17fa361b4efcbd577f679fff7577f3e98ba7",
        syntheticReceiptArtifactID:
            "neuralkit_native_language_verify_abstain_receipt",
        syntheticReceiptArtifactSHA256:
            "91c6fd5f26492357cad938dcab1926356bc33914cc281c5ccd2297f1759b0b0a",
        scientificAuthorityLanguage: "swift",
        compatibilityProjectionPath:
            "adapter/prime-native-resolved-contract-projection.v1.json",
        sourceSnapshotPath:
            "adapter/prime-swift-source-snapshot.v1.json",
        executablePath:
            "adapter/PrimeNativeResolvedContractAdapterProbe.executable",
        outputReceiptPath:
            "prime-native-resolved-contract-adapter-receipt.v1.json",
        parentResolutionMustValidate: true,
        parentArtifactsCopiedLosslessly: true,
        corpusRowsRegenerated: false,
        fixedCapEOSGenerationContractBound: false,
        physicalGenerationShardsObserved: false,
        independentRegradeExecuted: false,
        phaseThreeCompatibilityComplete: false,
        archiveExpansionAuthorized: false,
        donorExecutionAuthorized: false,
        neuralKitExecutionAuthorized: false,
        modelExecutionAuthorized: false,
        functionalTrainingAuthorized: false,
        quantizationAuthorized: false,
        productUseAuthorized: false,
        pythonExecutionAuthorized: false,
        authorityStatement:
            "This Swift adapter revalidates the exact frozen resolver receipt, replays the resolved NFC UTF-8 byte tokenizer through two independent native byte paths, validates the resolved corpus/evaluation manifest and historical synthetic Verify/Abstain envelope, and publishes a typed Prime projection. The corpus manifest embeds no rows, and the admitted artifacts do not expose the fixed-cap/EOS generation wire contract. Therefore this slice does not regenerate corpus rows, inspect physical generation shards, execute a model or NeuralKit, perform an independent semantic regrade, expand the opaque historical archive, train, quantize, claim Phase-3 completion, claim an independent scientific oracle, or authorize product use."
    )

    public func validate() throws {
        guard self == .frozenV1 else {
            throw PrimeNativeResolvedContractAdapterError
                .invalidPlan
        }
    }
}

public struct PrimeNativeResolvedContractSplitProjection:
    Codable,
    Equatable,
    Sendable
{
    public let split: String
    public let rowCount: Int
    public let historicalManifestDeclaredAllRowsIndependentlyVerified:
        Bool

    private enum CodingKeys: String, CodingKey {
        case split
        case rowCount = "row_count"
        case historicalManifestDeclaredAllRowsIndependentlyVerified =
            "historical_manifest_declared_all_rows_independently_verified"
    }
}

public struct PrimeNativeResolvedContractProjection:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let artifactKind: String
    public let claimScope: String
    public let parentReceiptSHA256: String
    public let resolverSourceRevision: String
    public let companionRevision: String
    public let companionTreeOID: String
    public let tokenizerArtifactSHA256: String
    public let tokenizerManifestSHA256: String
    public let tokenizerID: String
    public let tokenizerReplayProbeIDs: [String]
    public let tokenizerReplayProbeSHA256: String
    public let tokenizerVocabularySize: Int
    public let tokenizerByteTokenBase: Int
    public let tokenizerByteTokenCount: Int
    public let tokenizerSpecialTokenIDs: [Int]
    public let corpusArtifactSHA256: String
    public let corpusManifestSHA256: String
    public let corpusID: String
    public let totalUniqueRowCount: Int
    public let totalTokenInstanceCount: Int
    public let splitEvidence:
        [PrimeNativeResolvedContractSplitProjection]
    public let evaluationResultFields: [String]
    public let evaluationSplits: [String]
    public let evaluationSeeds: [Int]
    public let triadicWitnesses: [String]
    public let syntheticReceiptSHA256: String
    public let syntheticClassification: String
    public let syntheticGateOutcome: String
    public let syntheticGateRecordCount: Int
    public let syntheticGateMutationCount: Int
    public let parentResolutionValidated: Bool
    public let tokenizerManifestCompatibilityComplete: Bool
    public let tokenizerMechanicsReplayComplete: Bool
    public let corpusManifestCompatibilityComplete: Bool
    public let evaluationRecordContractProjectionComplete: Bool
    public let promptOnlyGenerationBoundaryImplemented: Bool
    public let syntheticRegradeEnvelopeCompatibilityComplete: Bool
    public let corpusRowsRegenerated: Bool
    public let corpusSemanticRegradePerformed: Bool
    public let fixedCapEOSGenerationContractBound: Bool
    public let generationBehaviorCompatibilityComplete: Bool
    public let physicalGenerationShardsObserved: Bool
    public let independentRegradeExecuted: Bool
    public let phaseThreeCompatibilityComplete: Bool
    public let archiveExpanded: Bool
    public let donorExecuted: Bool
    public let neuralKitExecuted: Bool
    public let modelExecuted: Bool
    public let trainingPerformed: Bool
    public let quantizationPerformed: Bool
    public let productPromotionAuthorized: Bool
    public let independentScientificOracleClaimed: Bool
    public let nextMissingPrerequisite: String

    public func validate() throws {
        let plan =
            PrimeNativeResolvedContractAdapterPlan.frozenV1
        guard schemaVersion == 1,
              artifactKind
                == "prime_native_resolved_contract_compatibility_projection",
              claimScope == plan.claimScope,
              parentReceiptSHA256
                == plan.parentReceiptSHA256,
              resolverSourceRevision
                == plan.parentResolverSourceRevision,
              companionRevision == plan.companionRevision,
              companionTreeOID == plan.companionTreeOID,
              tokenizerArtifactSHA256
                == plan.tokenizerArtifactSHA256,
              tokenizerManifestSHA256
                == plan.tokenizerManifestSHA256,
              tokenizerID
                == "ergentics_prime_nfc_utf8_byte_v1",
              tokenizerReplayProbeIDs == [
                  "empty",
                  "ascii",
                  "nfc",
                  "multilingual",
                  "emoji",
                  "whitespace",
                  "nul",
              ],
              tokenizerReplayProbeSHA256
                == "9ce743183b0aecaf4e976d912382ebc11f5f6b07a868f76470dd5a0a6061f5bb",
              tokenizerVocabularySize == 512,
              tokenizerByteTokenBase == 256,
              tokenizerByteTokenCount == 256,
              tokenizerSpecialTokenIDs == [0, 1, 70],
              corpusArtifactSHA256
                == plan.corpusArtifactSHA256,
              corpusManifestSHA256
                == plan.corpusManifestSHA256,
              corpusID
                == "ergentics_prime_native_compositional_text_v1",
              totalUniqueRowCount == 155_648,
              totalTokenInstanceCount == 38_506_757,
              splitEvidence.map(\.split) == [
                  "train",
                  "refusal_train",
                  "validation",
                  "refusal_validation",
                  "combination_holdout",
                  "ood",
                  "mutation",
                  "abstention",
              ],
              splitEvidence.map(\.rowCount) == [
                  131_072,
                  4_096,
                  4_096,
                  2_048,
                  4_096,
                  4_096,
                  4_096,
                  2_048,
              ],
              splitEvidence.allSatisfy(
                  \.historicalManifestDeclaredAllRowsIndependentlyVerified
              ),
              evaluationResultFields
                == PrimeNativeResolvedContractAdapter
                .requiredEvaluationResultFields,
              evaluationSplits
                == PrimeNativeResolvedContractAdapter
                .requiredEvaluationSplits,
              evaluationSeeds == [1618, 2718, 3141],
              triadicWitnesses
                == PrimeNativeResolvedContractAdapter
                .requiredTriadicWitnesses,
              syntheticReceiptSHA256
                == plan.syntheticReceiptArtifactSHA256,
              syntheticClassification
                == "synthetic_first_party_contract_and_mutation_verification_only",
              syntheticGateOutcome == "GROUNDED",
              syntheticGateRecordCount == 59_497,
              syntheticGateMutationCount == 46,
              parentResolutionValidated,
              tokenizerManifestCompatibilityComplete,
              tokenizerMechanicsReplayComplete,
              corpusManifestCompatibilityComplete,
              evaluationRecordContractProjectionComplete,
              promptOnlyGenerationBoundaryImplemented,
              syntheticRegradeEnvelopeCompatibilityComplete,
              !corpusRowsRegenerated,
              !corpusSemanticRegradePerformed,
              !fixedCapEOSGenerationContractBound,
              !generationBehaviorCompatibilityComplete,
              !physicalGenerationShardsObserved,
              !independentRegradeExecuted,
              !phaseThreeCompatibilityComplete,
              !archiveExpanded,
              !donorExecuted,
              !neuralKitExecuted,
              !modelExecuted,
              !trainingPerformed,
              !quantizationPerformed,
              !productPromotionAuthorized,
              !independentScientificOracleClaimed,
              nextMissingPrerequisite
                == "resolve_exact_fixed_cap_eos_generation_contract_projection"
        else {
            throw PrimeNativeResolvedContractAdapterError
                .invalidProjection("structural contract")
        }
    }
}

public enum PrimeNativeResolvedContractMutation:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Sendable
{
    case wrongParentReceiptHash =
        "wrong_parent_receipt_hash"
    case tokenizerSemanticDrift =
        "tokenizer_semantic_drift"
    case tokenizerInternalHashDrift =
        "tokenizer_internal_hash_drift"
    case corpusTokenizerLinkDrift =
        "corpus_tokenizer_link_drift"
    case corpusAuthorityExpansion =
        "corpus_authority_expansion"
    case corpusEvaluationSeedDrift =
        "corpus_evaluation_seed_drift"
    case syntheticAdmissionExpansion =
        "synthetic_admission_expansion"
    case promptOnlyTargetLeakage =
        "prompt_only_target_leakage"
    case adapterAuthorityExpansion =
        "adapter_authority_expansion"

    public var detectorID: String {
        switch self {
        case .wrongParentReceiptHash:
            "exact_parent_receipt_binding_v1"
        case .tokenizerSemanticDrift:
            "native_tokenizer_semantic_replay_v1"
        case .tokenizerInternalHashDrift:
            "tokenizer_dual_hash_binding_v1"
        case .corpusTokenizerLinkDrift:
            "corpus_tokenizer_cross_binding_v1"
        case .corpusAuthorityExpansion:
            "corpus_research_scope_gate_v1"
        case .corpusEvaluationSeedDrift:
            "evaluation_seed_triad_gate_v1"
        case .syntheticAdmissionExpansion:
            "synthetic_receipt_non_admission_gate_v1"
        case .promptOnlyTargetLeakage:
            "target_unrepresentable_generation_boundary_v1"
        case .adapterAuthorityExpansion:
            "adapter_non_authority_gate_v1"
        }
    }
}

public struct PrimeNativeResolvedContractMutationRecord:
    Codable,
    Equatable,
    Sendable
{
    public let mutation:
        PrimeNativeResolvedContractMutation
    public let detectorID: String
    public let detected: Bool
    public let restored: Bool
    public let independentScientificOracleClaimed: Bool
}

public enum PrimeNativeResolvedContractAdapterOutcome:
    String,
    Codable,
    Equatable,
    Sendable
{
    case pass = "PASS"
}

public struct PrimeNativeResolvedContractAdapterReceipt:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let artifactKind: String
    public let outcome:
        PrimeNativeResolvedContractAdapterOutcome
    public let claimScope: String
    public let plan:
        PrimeNativeResolvedContractAdapterPlan
    public let adapterSourceRemoteURL: String
    public let adapterSourceRevision: String
    public let adapterSourceTreeOID: String
    public let adapterSourceTreeClean: Bool
    public let adapterSourceCommandObservations:
        [PrimeNativeMigrationGitCommandObservation]
    public let adapterSourceSnapshot:
        PrimeArtifactBinding
    public let adapterExecutable: PrimeArtifactBinding
    public let parentReceipt: PrimeArtifactBinding
    public let parentResolverSourceSnapshot:
        PrimeArtifactBinding
    public let parentResolverExecutable:
        PrimeArtifactBinding
    public let copiedParentArtifacts:
        [PrimeArtifactBinding]
    public let tokenizerManifest: PrimeArtifactBinding
    public let corpusManifest: PrimeArtifactBinding
    public let syntheticRegradeReceipt:
        PrimeArtifactBinding
    public let compatibilityProjection:
        PrimeArtifactBinding
    public let mutationSweep:
        [PrimeNativeResolvedContractMutationRecord]
    public let parentResolutionValidatedAtExecution:
        Bool
    public let parentArtifactsCopiedLosslessly: Bool
    public let tokenizerManifestCompatibilityComplete:
        Bool
    public let tokenizerMechanicsReplayComplete: Bool
    public let corpusManifestCompatibilityComplete:
        Bool
    public let evaluationRecordContractProjectionComplete:
        Bool
    public let promptOnlyGenerationBoundaryImplemented:
        Bool
    public let syntheticRegradeEnvelopeCompatibilityComplete:
        Bool
    public let corpusRowsRegenerated: Bool
    public let corpusSemanticRegradePerformed: Bool
    public let fixedCapEOSGenerationContractBound: Bool
    public let generationBehaviorCompatibilityComplete:
        Bool
    public let physicalGenerationShardsObserved: Bool
    public let independentRegradeExecuted: Bool
    public let phaseThreeCompatibilityComplete: Bool
    public let archiveExpanded: Bool
    public let companionWritePerformed: Bool
    public let companionRuntimeDependencyAdded: Bool
    public let donorExecutionPerformed: Bool
    public let neuralKitExecutionPerformed: Bool
    public let modelExecutionPerformed: Bool
    public let functionalTrainingPerformed: Bool
    public let quantizationPerformed: Bool
    public let productPromotionAuthorized: Bool
    public let independentScientificOracleClaimed: Bool
    public let nextMissingPrerequisite: String

    public init(
        adapterSourceRemoteURL: String,
        adapterSourceRevision: String,
        adapterSourceTreeOID: String,
        adapterSourceTreeClean: Bool,
        adapterSourceCommandObservations:
            [PrimeNativeMigrationGitCommandObservation],
        adapterSourceSnapshot:
            PrimeArtifactBinding,
        adapterExecutable: PrimeArtifactBinding,
        parentReceipt: PrimeArtifactBinding,
        parentResolverSourceSnapshot:
            PrimeArtifactBinding,
        parentResolverExecutable:
            PrimeArtifactBinding,
        copiedParentArtifacts:
            [PrimeArtifactBinding],
        tokenizerManifest: PrimeArtifactBinding,
        corpusManifest: PrimeArtifactBinding,
        syntheticRegradeReceipt:
            PrimeArtifactBinding,
        compatibilityProjection:
            PrimeArtifactBinding,
        mutationSweep:
            [PrimeNativeResolvedContractMutationRecord]
    ) {
        schemaVersion = 1
        artifactKind =
            "prime_native_resolved_contract_compatibility_adapter"
        outcome = .pass
        claimScope =
            PrimeNativeResolvedContractAdapterPlan
            .frozenV1.claimScope
        plan = .frozenV1
        self.adapterSourceRemoteURL =
            adapterSourceRemoteURL
        self.adapterSourceRevision =
            adapterSourceRevision
        self.adapterSourceTreeOID =
            adapterSourceTreeOID
        self.adapterSourceTreeClean =
            adapterSourceTreeClean
        self.adapterSourceCommandObservations =
            adapterSourceCommandObservations
        self.adapterSourceSnapshot =
            adapterSourceSnapshot
        self.adapterExecutable = adapterExecutable
        self.parentReceipt = parentReceipt
        self.parentResolverSourceSnapshot =
            parentResolverSourceSnapshot
        self.parentResolverExecutable =
            parentResolverExecutable
        self.copiedParentArtifacts =
            copiedParentArtifacts
        self.tokenizerManifest = tokenizerManifest
        self.corpusManifest = corpusManifest
        self.syntheticRegradeReceipt =
            syntheticRegradeReceipt
        self.compatibilityProjection =
            compatibilityProjection
        self.mutationSweep = mutationSweep
        parentResolutionValidatedAtExecution = true
        parentArtifactsCopiedLosslessly = true
        tokenizerManifestCompatibilityComplete = true
        tokenizerMechanicsReplayComplete = true
        corpusManifestCompatibilityComplete = true
        evaluationRecordContractProjectionComplete = true
        promptOnlyGenerationBoundaryImplemented = true
        syntheticRegradeEnvelopeCompatibilityComplete = true
        corpusRowsRegenerated = false
        corpusSemanticRegradePerformed = false
        fixedCapEOSGenerationContractBound = false
        generationBehaviorCompatibilityComplete = false
        physicalGenerationShardsObserved = false
        independentRegradeExecuted = false
        phaseThreeCompatibilityComplete = false
        archiveExpanded = false
        companionWritePerformed = false
        companionRuntimeDependencyAdded = false
        donorExecutionPerformed = false
        neuralKitExecutionPerformed = false
        modelExecutionPerformed = false
        functionalTrainingPerformed = false
        quantizationPerformed = false
        productPromotionAuthorized = false
        independentScientificOracleClaimed = false
        nextMissingPrerequisite =
            "resolve_exact_fixed_cap_eos_generation_contract_projection"
    }

    public func validate() throws {
        try plan.validate()
        let parentPlan =
            PrimeNativeContractMigrationPlan.frozenV1
        guard schemaVersion == 1,
              artifactKind
                == "prime_native_resolved_contract_compatibility_adapter",
              outcome == .pass,
              claimScope == plan.claimScope,
              parentPlan
                .acceptedResolverRemoteURLs
                .contains(adapterSourceRemoteURL),
              PrimeNativeContractMigrationPlan
                .isGitOID(adapterSourceRevision),
              PrimeNativeContractMigrationPlan
                .isGitOID(adapterSourceTreeOID),
              adapterSourceTreeClean,
              !adapterSourceCommandObservations.isEmpty,
              adapterSourceSnapshot.relativePath
                == plan.sourceSnapshotPath,
              adapterSourceSnapshot.purpose
                == .immutableData,
              adapterExecutable.relativePath
                == plan.executablePath,
              adapterExecutable.purpose == .executable,
              parentReceipt.relativePath
                == plan.parentReceiptPath,
              parentReceipt.sha256
                == plan.parentReceiptSHA256,
              parentReceipt.byteCount
                == plan.parentReceiptByteCount,
              parentReceipt.purpose == .immutableData,
              parentResolverSourceSnapshot.relativePath
                == "prime-swift-source-snapshot.v1.json",
              parentResolverSourceSnapshot.purpose
                == .immutableData,
              parentResolverExecutable.relativePath
                == PrimeNativeContractMigrationResolver
                .resolverExecutablePath,
              parentResolverExecutable.purpose
                == .executable,
              copiedParentArtifacts.count
                == plan.expectedParentArtifactCount,
              copiedParentArtifacts
                .reduce(UInt64(0), {
                    $0 + $1.byteCount
                })
                == plan.expectedParentArtifactByteCount,
              copiedParentArtifacts
                .allSatisfy({
                    $0.purpose == .immutableData
                }),
              tokenizerManifest.sha256
                == plan.tokenizerArtifactSHA256,
              tokenizerManifest.purpose
                == .immutableData,
              corpusManifest.sha256
                == plan.corpusArtifactSHA256,
              corpusManifest.purpose == .immutableData,
              syntheticRegradeReceipt.sha256
                == plan.syntheticReceiptArtifactSHA256,
              syntheticRegradeReceipt.purpose
                == .immutableData,
              compatibilityProjection.relativePath
                == plan.compatibilityProjectionPath,
              compatibilityProjection.purpose
                == .immutableData,
              mutationSweep.map(\.mutation)
                == PrimeNativeResolvedContractMutation
                .allCases,
              mutationSweep.allSatisfy({
                  $0.detectorID
                        == $0.mutation.detectorID
                      && $0.detected
                      && $0.restored
                      && !$0
                        .independentScientificOracleClaimed
              }),
              parentResolutionValidatedAtExecution,
              parentArtifactsCopiedLosslessly,
              tokenizerManifestCompatibilityComplete,
              tokenizerMechanicsReplayComplete,
              corpusManifestCompatibilityComplete,
              evaluationRecordContractProjectionComplete,
              promptOnlyGenerationBoundaryImplemented,
              syntheticRegradeEnvelopeCompatibilityComplete,
              !corpusRowsRegenerated,
              !corpusSemanticRegradePerformed,
              !fixedCapEOSGenerationContractBound,
              !generationBehaviorCompatibilityComplete,
              !physicalGenerationShardsObserved,
              !independentRegradeExecuted,
              !phaseThreeCompatibilityComplete,
              !archiveExpanded,
              !companionWritePerformed,
              !companionRuntimeDependencyAdded,
              !donorExecutionPerformed,
              !neuralKitExecutionPerformed,
              !modelExecutionPerformed,
              !functionalTrainingPerformed,
              !quantizationPerformed,
              !productPromotionAuthorized,
              !independentScientificOracleClaimed,
              nextMissingPrerequisite
                == "resolve_exact_fixed_cap_eos_generation_contract_projection"
        else {
            throw PrimeNativeResolvedContractAdapterError
                .invalidReceipt("structural contract")
        }
        try PrimeNativeContractMigrationResolver
            .validateResolverSourceCommandObservations(
                adapterSourceCommandObservations,
                remoteURL: adapterSourceRemoteURL,
                revision: adapterSourceRevision,
                treeOID: adapterSourceTreeOID,
                clean: adapterSourceTreeClean
            )
    }

    public func validate(
        in root: PrimeArtifactRoot
    ) throws {
        try validate()
        let parent = try root.decodeVerified(
            PrimeNativeContractMigrationReceipt.self,
            binding: parentReceipt,
            maximumByteCount: 4 * 1024 * 1024
        )
        try PrimeNativeResolvedContractAdapter
            .validateParentResolution(
                parent,
                in: root
            )
        guard parent.resolverSourceSnapshot
                == parentResolverSourceSnapshot,
              parent.resolverExecutable
                == parentResolverExecutable,
              parent.artifacts.map(\.artifact)
                == copiedParentArtifacts,
              parent.resolverSourceRevision
                == plan.parentResolverSourceRevision,
              parent.repository.resolvedRevision
                == plan.companionRevision,
              parent.repository.treeOID
                == plan.companionTreeOID else {
            throw PrimeNativeResolvedContractAdapterError
                .invalidReceipt("parent chain")
        }

        let sourceSnapshot = try root.decodeVerified(
            PrimeSwiftSourceSnapshot.self,
            binding: adapterSourceSnapshot,
            maximumByteCount: 64 * 1024 * 1024
        )
        try PrimeSwiftSourceProvenance.validate(
            sourceSnapshot,
            requiredRelativePaths:
                PrimeNativeResolvedContractAdapter
                .requiredAdapterSourcePaths
        )
        _ = try root.verify(adapterExecutable)

        let projection = try root.decodeVerified(
            PrimeNativeResolvedContractProjection.self,
            binding: compatibilityProjection,
            maximumByteCount: 4 * 1024 * 1024
        )
        try projection.validate()

        let tokenizerData = try root.readVerified(
            tokenizerManifest,
            maximumByteCount: 1024 * 1024
        )
        let corpusData = try root.readVerified(
            corpusManifest,
            maximumByteCount: 4 * 1024 * 1024
        )
        let syntheticData = try root.readVerified(
            syntheticRegradeReceipt,
            maximumByteCount: 4 * 1024 * 1024
        )
        let replayed =
            try PrimeNativeResolvedContractAdapter
            .projection(
                parent: parent,
                tokenizerData: tokenizerData,
                corpusData: corpusData,
                syntheticData: syntheticData
            )
        guard replayed == projection else {
            throw PrimeNativeResolvedContractAdapterError
                .invalidReceipt(
                    "compatibility projection replay"
                )
        }
        let replayedMutations =
            try PrimeNativeResolvedContractAdapter
            .mutationSweep(
                parentReceiptBinding: parentReceipt,
                tokenizerData: tokenizerData,
                corpusData: corpusData,
                syntheticData: syntheticData
            )
        guard replayedMutations == mutationSweep else {
            throw PrimeNativeResolvedContractAdapterError
                .invalidReceipt("mutation sweep replay")
        }
    }
}

public enum PrimeNativeResolvedContractAdapter {
    public static let requiredAdapterSourcePaths:
        Set<String> = [
        "Sources/PrimeCore/PrimeDurableArtifacts.swift",
        "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
        "Sources/PrimeCore/PrimeNative3BMetalContinuation.swift",
        "Sources/PrimeCore/PrimeNativeByteTokenizer.swift",
        "Sources/PrimeCore/PrimeNativeContractMigration.swift",
        "Sources/PrimeCore/PrimeNativeContractMigrationResolver.swift",
        "Sources/PrimeCore/PrimeNativeGitBlobTransport.swift",
        "Sources/PrimeCore/PrimeNativeResolvedContractAdapter.swift",
        "Sources/PrimeCore/PrimeNativeResolvedContractArguments.swift",
        "Sources/PrimeCore/PrimeNativeResolvedContractModels.swift",
        "Sources/PrimeCore/PrimeSecureRunningExecutableCapture.swift",
        "Sources/PrimeCore/PrimeSwiftSourceProvenance.swift",
        "Sources/PrimeNativeResolvedContractAdapterProbe/PrimeNativeResolvedContractAdapterProbeMain.swift",
        "Sources/PrimeNativeResolvedContractAdapterVerifier/PrimeNativeResolvedContractAdapterVerifierMain.swift",
    ]

    public static let requiredEvaluationResultFields = [
        "seed",
        "row_id",
        "split",
        "semantic_family",
        "mutation_id",
        "evaluation_row_sha256",
        "corpus_row_sha256",
        "prompt_token_ids",
        "expected_completion_token_ids",
        "generated_token_ids",
        "generated_completion",
        "token_log_probabilities",
        "exact_match",
        "semantic_verifier_pass",
        "abstention_decision",
        "latency_seconds",
    ]

    public static let requiredEvaluationSplits = [
        "validation",
        "combination_holdout",
        "ood",
        "mutation",
        "abstention",
    ]

    public static let requiredTriadicWitnesses = [
        "swift_generator_replay",
        "independent_text_semantic_regrade",
        "foundation_data_tokenizer_replay",
    ]

    private static let expectedSplitNames = [
        "train",
        "refusal_train",
        "validation",
        "refusal_validation",
        "combination_holdout",
        "ood",
        "mutation",
        "abstention",
    ]

    private static let expectedSplitCounts = [
        131_072,
        4_096,
        4_096,
        2_048,
        4_096,
        4_096,
        4_096,
        2_048,
    ]

    private static let expectedFalsifierIDs = [
        "exact_lookup_leakage",
        "shuffled_label_regrade",
        "operation_order_swap",
        "negation_drop",
        "conservation_break",
        "reversal_drop",
        "token_offset_corruption",
        "codebook_surface_equivalence",
        "duplicate_row_injection",
        "heldout_refusal_contract",
    ]

    private struct CorpusManifest:
        Decodable,
        Equatable
    {
        let schemaVersion: String
        let corpusID: String
        let tokenizerID: String
        let tokenizerManifestSHA256: String
        let ownership: String
        let license: String
        let productAuthorization: String
        let modelVocabularySize: Int
        let generator: Generator
        let tokenAccounting: TokenAccounting
        let evaluationContract:
            PrimeNativeEvaluationContract
        let leakageEvidence: LeakageEvidence
        let refusalCurriculumEvidence:
            RefusalCurriculumEvidence
        let splitEvidence: [SplitEvidence]
        let falsifiers: [Falsifier]
        let falsifierSHA256: String
        let manifestSHA256: String

        private enum CodingKeys: String, CodingKey {
            case schemaVersion = "schema_version"
            case corpusID = "corpus_id"
            case tokenizerID = "tokenizer_id"
            case tokenizerManifestSHA256 =
                "tokenizer_manifest_sha256"
            case ownership
            case license
            case productAuthorization =
                "product_authorization"
            case modelVocabularySize =
                "model_vocabulary_size"
            case generator
            case tokenAccounting =
                "token_accounting"
            case evaluationContract =
                "evaluation_contract"
            case leakageEvidence =
                "leakage_evidence"
            case refusalCurriculumEvidence =
                "refusal_curriculum_evidence"
            case splitEvidence = "split_evidence"
            case falsifiers
            case falsifierSHA256 =
                "falsifier_sha256"
            case manifestSHA256 =
                "manifest_sha256"
        }
    }

    private struct Generator:
        Decodable,
        Equatable
    {
        let canonicalTextNormalization: String
        let entropyPrimitive: String
        let externalText: Bool
        let fullRowsEmbedded: Bool
        let generatorID: String
        let hostRandomness: Bool
        let implementationLanguage: String
        let implementationPath: String
        let inheritedTokenizer: Bool
        let inheritedWeights: Bool
        let losslessReplay: Bool
        let maximumSequenceTokenCount: Int
        let sequenceConstruction: String

        private enum CodingKeys: String, CodingKey {
            case canonicalTextNormalization =
                "canonical_text_normalization"
            case entropyPrimitive =
                "entropy_primitive"
            case externalText = "external_text"
            case fullRowsEmbedded =
                "full_rows_embedded"
            case generatorID = "generator_id"
            case hostRandomness =
                "host_randomness"
            case implementationLanguage =
                "implementation_language"
            case implementationPath =
                "implementation_path"
            case inheritedTokenizer =
                "inherited_tokenizer"
            case inheritedWeights =
                "inherited_weights"
            case losslessReplay = "lossless_replay"
            case maximumSequenceTokenCount =
                "maximum_sequence_token_count"
            case sequenceConstruction =
                "sequence_construction"
        }
    }

    private struct TokenAccounting:
        Decodable,
        Equatable
    {
        let deduplicatedSequenceTokenInstances: Int
        let observedTokenTypeCount: Int
        let rawTokenInstances: Int
        let uniqueSemanticCombinationCount: Int
        let uniqueSequenceCount: Int
        let vocabularyTokenTypeCount: Int

        private enum CodingKeys: String, CodingKey {
            case deduplicatedSequenceTokenInstances =
                "deduplicated_sequence_token_instances"
            case observedTokenTypeCount =
                "observed_token_type_count"
            case rawTokenInstances =
                "raw_token_instances"
            case uniqueSemanticCombinationCount =
                "unique_semantic_combination_count"
            case uniqueSequenceCount =
                "unique_sequence_count"
            case vocabularyTokenTypeCount =
                "vocabulary_token_type_count"
        }
    }

    private struct LeakageEvidence:
        Decodable,
        Equatable
    {
        let allRowHashesUnique: Bool
        let allRowIDsUnique: Bool
        let allValidSemanticsDisjointAcrossSplits: Bool
        let combinationComponentsSeenInTrain: Bool
        let combinationPairsAbsentFromTrain: Bool
        let exactLookupEvaluationHits: Int
        let refusalTrainAbstentionContractOverlapCount:
            Int
        let refusalTrainEvaluationPromptOverlapCount:
            Int
        let refusalTrainEvaluationSemanticOverlapCount:
            Int
        let trainCombinationPairOverlapCount: Int
        let trainEvaluationPromptOverlapCount: Int
        let trainEvaluationSemanticOverlapCount: Int
        let trainOODCodebookIDIntersectionCount: Int
        let trainOODSurfaceIDIntersectionCount: Int

        private enum CodingKeys: String, CodingKey {
            case allRowHashesUnique =
                "all_row_hashes_unique"
            case allRowIDsUnique =
                "all_row_ids_unique"
            case allValidSemanticsDisjointAcrossSplits =
                "all_valid_semantics_disjoint_across_splits"
            case combinationComponentsSeenInTrain =
                "combination_components_seen_in_train"
            case combinationPairsAbsentFromTrain =
                "combination_pairs_absent_from_train"
            case exactLookupEvaluationHits =
                "exact_lookup_evaluation_hits"
            case refusalTrainAbstentionContractOverlapCount =
                "refusal_train_abstention_contract_overlap_count"
            case refusalTrainEvaluationPromptOverlapCount =
                "refusal_train_evaluation_prompt_overlap_count"
            case refusalTrainEvaluationSemanticOverlapCount =
                "refusal_train_evaluation_semantic_overlap_count"
            case trainCombinationPairOverlapCount =
                "train_combination_pair_overlap_count"
            case trainEvaluationPromptOverlapCount =
                "train_evaluation_prompt_overlap_count"
            case trainEvaluationSemanticOverlapCount =
                "train_evaluation_semantic_overlap_count"
            case trainOODCodebookIDIntersectionCount =
                "train_ood_codebook_id_intersection_count"
            case trainOODSurfaceIDIntersectionCount =
                "train_ood_surface_id_intersection_count"
        }
    }

    private struct RefusalCurriculumEvidence:
        Decodable,
        Equatable
    {
        let allReasonsTaughtBeforeTuningAndEvaluation:
            Bool
        let allRowsIndependentlyVerified: Bool
        let allTuningAndEvaluationContractsHeldOut:
            Bool
        let trainingRowCount: Int
        let trainingSplit: String
        let tuningRowCount: Int
        let tuningSplit: String
        let finalEvaluationRowCount: Int
        let finalEvaluationSplit: String
        let trainingFinalEvaluationMutationContractOverlapCount:
            Int
        let trainingFinalEvaluationPromptOverlapCount:
            Int
        let trainingFinalEvaluationSemanticOverlapCount:
            Int
        let trainingTuningMutationContractOverlapCount:
            Int
        let trainingTuningPromptOverlapCount: Int
        let trainingTuningSemanticOverlapCount: Int
        let tuningFinalEvaluationMutationContractOverlapCount:
            Int
        let tuningFinalEvaluationPromptOverlapCount:
            Int
        let tuningFinalEvaluationSemanticOverlapCount:
            Int

        private enum CodingKeys: String, CodingKey {
            case allReasonsTaughtBeforeTuningAndEvaluation =
                "all_reasons_taught_before_tuning_and_evaluation"
            case allRowsIndependentlyVerified =
                "all_rows_independently_verified"
            case allTuningAndEvaluationContractsHeldOut =
                "all_tuning_and_evaluation_contracts_held_out"
            case trainingRowCount = "training_row_count"
            case trainingSplit = "training_split"
            case tuningRowCount = "tuning_row_count"
            case tuningSplit = "tuning_split"
            case finalEvaluationRowCount =
                "final_evaluation_row_count"
            case finalEvaluationSplit =
                "final_evaluation_split"
            case trainingFinalEvaluationMutationContractOverlapCount =
                "training_final_evaluation_mutation_contract_overlap_count"
            case trainingFinalEvaluationPromptOverlapCount =
                "training_final_evaluation_prompt_overlap_count"
            case trainingFinalEvaluationSemanticOverlapCount =
                "training_final_evaluation_semantic_overlap_count"
            case trainingTuningMutationContractOverlapCount =
                "training_tuning_mutation_contract_overlap_count"
            case trainingTuningPromptOverlapCount =
                "training_tuning_prompt_overlap_count"
            case trainingTuningSemanticOverlapCount =
                "training_tuning_semantic_overlap_count"
            case tuningFinalEvaluationMutationContractOverlapCount =
                "tuning_final_evaluation_mutation_contract_overlap_count"
            case tuningFinalEvaluationPromptOverlapCount =
                "tuning_final_evaluation_prompt_overlap_count"
            case tuningFinalEvaluationSemanticOverlapCount =
                "tuning_final_evaluation_semantic_overlap_count"
        }
    }

    private struct SplitEvidence:
        Decodable,
        Equatable
    {
        let split: String
        let rowCount: Int
        let allRowsIndependentlyVerified: Bool

        private enum CodingKeys: String, CodingKey {
            case split
            case rowCount = "row_count"
            case allRowsIndependentlyVerified =
                "all_rows_independently_verified"
        }
    }

    private struct Falsifier:
        Decodable,
        Equatable
    {
        let id: String
        let family: String
        let detected: Bool
        let detections: Int
        let trials: Int
    }

    private struct SyntheticAdmissionHeader:
        Decodable,
        Equatable
    {
        let currentAdmissionEffect: Bool

        private enum CodingKeys: String, CodingKey {
            case currentAdmissionEffect =
                "current_admission_effect"
        }
    }

    private struct AuthorityClaims:
        Equatable
    {
        let archiveExpanded: Bool
        let companionWritePerformed: Bool
        let companionRuntimeDependencyAdded: Bool
        let donorExecutionPerformed: Bool
        let neuralKitExecutionPerformed: Bool
        let modelExecutionPerformed: Bool
        let functionalTrainingPerformed: Bool
        let quantizationPerformed: Bool
        let productPromotionAuthorized: Bool
        let independentScientificOracleClaimed: Bool

        static let frozen = Self(
            archiveExpanded: false,
            companionWritePerformed: false,
            companionRuntimeDependencyAdded: false,
            donorExecutionPerformed: false,
            neuralKitExecutionPerformed: false,
            modelExecutionPerformed: false,
            functionalTrainingPerformed: false,
            quantizationPerformed: false,
            productPromotionAuthorized: false,
            independentScientificOracleClaimed: false
        )
    }

    fileprivate static func projection(
        parent: PrimeNativeContractMigrationReceipt,
        tokenizerData: Data,
        corpusData: Data,
        syntheticData: Data
    ) throws -> PrimeNativeResolvedContractProjection {
        let plan =
            PrimeNativeResolvedContractAdapterPlan.frozenV1
        try plan.validate()
        try parent.validate()
        guard parent.resolverSourceRevision
                == plan.parentResolverSourceRevision,
              parent.repository.resolvedRevision
                == plan.companionRevision,
              parent.repository.treeOID
                == plan.companionTreeOID,
              parent.artifacts.count
                == plan.expectedParentArtifactCount,
              parent.totalMaterializedByteCount
                == plan.expectedParentArtifactByteCount else {
            throw PrimeNativeResolvedContractAdapterError
                .invalidParentResolution("frozen identity")
        }

        let tokenizer =
            try validateTokenizer(tokenizerData)
        let corpus = try validateCorpus(
            corpusData,
            tokenizerManifestSHA256:
                tokenizer.manifestSHA256
        )
        let synthetic =
            try validateSyntheticReceipt(syntheticData)

        let value =
            PrimeNativeResolvedContractProjection(
                schemaVersion: 1,
                artifactKind:
                    "prime_native_resolved_contract_compatibility_projection",
                claimScope: plan.claimScope,
                parentReceiptSHA256:
                    plan.parentReceiptSHA256,
                resolverSourceRevision:
                    parent.resolverSourceRevision,
                companionRevision:
                    parent.repository.resolvedRevision,
                companionTreeOID:
                    parent.repository.treeOID,
                tokenizerArtifactSHA256:
                    plan.tokenizerArtifactSHA256,
                tokenizerManifestSHA256:
                    tokenizer.manifestSHA256,
                tokenizerID: tokenizer.tokenizerID,
                tokenizerReplayProbeIDs:
                    tokenizer.replayProbes.map(\.id),
                tokenizerReplayProbeSHA256:
                    tokenizer.replayProbeSHA256,
                tokenizerVocabularySize:
                    tokenizer.tokenSpaceSize,
                tokenizerByteTokenBase:
                    tokenizer.byteTokenBase,
                tokenizerByteTokenCount:
                    tokenizer.byteTokenCount,
                tokenizerSpecialTokenIDs:
                    tokenizer.specialTokens.map(
                        \.tokenID
                    ),
                corpusArtifactSHA256:
                    plan.corpusArtifactSHA256,
                corpusManifestSHA256:
                    corpus.manifestSHA256,
                corpusID: corpus.corpusID,
                totalUniqueRowCount:
                    corpus.tokenAccounting
                    .uniqueSequenceCount,
                totalTokenInstanceCount:
                    corpus.tokenAccounting
                    .rawTokenInstances,
                splitEvidence:
                    corpus.splitEvidence.map {
                        PrimeNativeResolvedContractSplitProjection(
                            split: $0.split,
                            rowCount: $0.rowCount,
                            historicalManifestDeclaredAllRowsIndependentlyVerified:
                                $0
                                .allRowsIndependentlyVerified
                        )
                    },
                evaluationResultFields:
                    corpus.evaluationContract
                    .requiredRawResultFields,
                evaluationSplits:
                    corpus.evaluationContract
                    .requiredRawResultSplits,
                evaluationSeeds:
                    corpus.evaluationContract
                    .multiSeedConsensusSeeds,
                triadicWitnesses:
                    corpus.evaluationContract
                    .triadicWitnesses,
                syntheticReceiptSHA256:
                    plan.syntheticReceiptArtifactSHA256,
                syntheticClassification:
                    synthetic.classification,
                syntheticGateOutcome:
                    synthetic.gate.outcome,
                syntheticGateRecordCount:
                    synthetic.gate.recordCount,
                syntheticGateMutationCount:
                    synthetic.gate
                    .namedMutationsDetectedAndRestored,
                parentResolutionValidated: true,
                tokenizerManifestCompatibilityComplete:
                    true,
                tokenizerMechanicsReplayComplete:
                    true,
                corpusManifestCompatibilityComplete:
                    true,
                evaluationRecordContractProjectionComplete:
                    true,
                promptOnlyGenerationBoundaryImplemented:
                    true,
                syntheticRegradeEnvelopeCompatibilityComplete:
                    true,
                corpusRowsRegenerated: false,
                corpusSemanticRegradePerformed: false,
                fixedCapEOSGenerationContractBound:
                    false,
                generationBehaviorCompatibilityComplete:
                    false,
                physicalGenerationShardsObserved:
                    false,
                independentRegradeExecuted: false,
                phaseThreeCompatibilityComplete:
                    false,
                archiveExpanded: false,
                donorExecuted: false,
                neuralKitExecuted: false,
                modelExecuted: false,
                trainingPerformed: false,
                quantizationPerformed: false,
                productPromotionAuthorized: false,
                independentScientificOracleClaimed:
                    false,
                nextMissingPrerequisite:
                    "resolve_exact_fixed_cap_eos_generation_contract_projection"
            )
        try value.validate()
        return value
    }

    private static func validateTokenizer(
        _ data: Data
    ) throws -> PrimeNativeByteTokenizer.Manifest {
        let plan =
            PrimeNativeResolvedContractAdapterPlan.frozenV1
        let manifest:
            PrimeNativeByteTokenizer.Manifest
        do {
            manifest = try JSONDecoder().decode(
                PrimeNativeByteTokenizer
                    .Manifest.self,
                from: data
            )
            try PrimeNativeByteTokenizer
                .verify(manifest)
        } catch {
            throw PrimeNativeResolvedContractAdapterError
                .invalidTokenizerManifest(
                    String(describing: error)
                )
        }
        guard manifest.manifestSHA256
                == plan.tokenizerManifestSHA256,
              manifest.specialTokens.map(\.name) == [
                  "pad",
                  "beginning_of_sequence",
                  "end_of_sequence",
              ],
              manifest.specialTokens.map(\.tokenID)
                == [0, 1, 70],
              manifest.replayProbes.map(\.id) == [
                  "empty",
                  "ascii",
                  "nfc",
                  "multilingual",
                  "emoji",
                  "whitespace",
                  "nul",
              ] else {
            throw PrimeNativeResolvedContractAdapterError
                .invalidTokenizerManifest(
                    "frozen profile"
                )
        }
        return manifest
    }

    private static func validateCorpus(
        _ data: Data,
        tokenizerManifestSHA256: String
    ) throws -> CorpusManifest {
        let plan =
            PrimeNativeResolvedContractAdapterPlan.frozenV1
        let manifest: CorpusManifest
        do {
            manifest = try JSONDecoder().decode(
                CorpusManifest.self,
                from: data
            )
        } catch {
            throw PrimeNativeResolvedContractAdapterError
                .invalidCorpusManifest(
                    "decode: \(error)"
                )
        }
        let contentHash = try canonicalContentSHA256(
            data,
            removingTopLevelKey:
                "manifest_sha256"
        )
        let falsifierHash = try canonicalArraySHA256(
            data,
            topLevelKey: "falsifiers"
        )
        do {
            try manifest.evaluationContract
                .validateFrozenV1()
        } catch {
            throw PrimeNativeResolvedContractAdapterError
                .invalidCorpusManifest(
                    "evaluation contract"
                )
        }

        let generator = manifest.generator
        let accounting = manifest.tokenAccounting
        let leakage = manifest.leakageEvidence
        let refusal =
            manifest.refusalCurriculumEvidence
        guard manifest.schemaVersion == "1",
              manifest.corpusID
                == "ergentics_prime_native_compositional_text_v1",
              manifest.tokenizerID
                == PrimeNativeByteTokenizer
                .tokenizerID,
              manifest.tokenizerManifestSHA256
                == tokenizerManifestSHA256,
              manifest.tokenizerManifestSHA256
                == plan.tokenizerManifestSHA256,
              manifest.ownership
                == "ergentics_first_party",
              manifest.license
                == "ergentics_first_party_controlled",
              manifest.productAuthorization
                == "research_canary_only",
              manifest.modelVocabularySize == 512,
              generator.canonicalTextNormalization
                == "NFC",
              generator.entropyPrimitive
                == "SHA256(generator_id|split|index|attempt|field)",
              !generator.externalText,
              !generator.fullRowsEmbedded,
              generator.generatorID
                == "ergentics_prime_swift_sha256_procedural_v1",
              !generator.hostRandomness,
              generator.implementationLanguage
                == "swift",
              generator.implementationPath
                == "prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsPrimeNativeTextCorpus.swift",
              !generator.inheritedTokenizer,
              !generator.inheritedWeights,
              generator.losslessReplay,
              generator.maximumSequenceTokenCount
                == 512,
              generator.sequenceConstruction
                == "BOS + NFC UTF-8 prompt + exact completion + EOS",
              accounting
                .deduplicatedSequenceTokenInstances
                == 38_506_757,
              accounting.rawTokenInstances
                == 38_506_757,
              accounting.uniqueSemanticCombinationCount
                == 155_648,
              accounting.uniqueSequenceCount
                == 155_648,
              accounting.vocabularyTokenTypeCount
                == 512,
              manifest.splitEvidence.map(\.split)
                == expectedSplitNames,
              manifest.splitEvidence.map(\.rowCount)
                == expectedSplitCounts,
              manifest.splitEvidence.allSatisfy(
                  \.allRowsIndependentlyVerified
              ),
              leakage.allRowHashesUnique,
              leakage.allRowIDsUnique,
              leakage
                .allValidSemanticsDisjointAcrossSplits,
              leakage.combinationComponentsSeenInTrain,
              leakage.combinationPairsAbsentFromTrain,
              leakage.exactLookupEvaluationHits == 0,
              leakage
                .refusalTrainAbstentionContractOverlapCount
                == 0,
              leakage
                .refusalTrainEvaluationPromptOverlapCount
                == 0,
              leakage
                .refusalTrainEvaluationSemanticOverlapCount
                == 0,
              leakage.trainCombinationPairOverlapCount
                == 0,
              leakage.trainEvaluationPromptOverlapCount
                == 0,
              leakage.trainEvaluationSemanticOverlapCount
                == 0,
              leakage.trainOODCodebookIDIntersectionCount
                == 0,
              leakage.trainOODSurfaceIDIntersectionCount
                == 0,
              refusal
                .allReasonsTaughtBeforeTuningAndEvaluation,
              refusal.allRowsIndependentlyVerified,
              refusal
                .allTuningAndEvaluationContractsHeldOut,
              refusal.trainingRowCount == 4_096,
              refusal.trainingSplit
                == "refusal_train",
              refusal.tuningRowCount == 2_048,
              refusal.tuningSplit
                == "refusal_validation",
              refusal.finalEvaluationRowCount
                == 2_048,
              refusal.finalEvaluationSplit
                == "abstention",
              refusal
                .trainingFinalEvaluationMutationContractOverlapCount
                == 0,
              refusal
                .trainingFinalEvaluationPromptOverlapCount
                == 0,
              refusal
                .trainingFinalEvaluationSemanticOverlapCount
                == 0,
              refusal
                .trainingTuningMutationContractOverlapCount
                == 0,
              refusal.trainingTuningPromptOverlapCount
                == 0,
              refusal
                .trainingTuningSemanticOverlapCount
                == 0,
              refusal
                .tuningFinalEvaluationMutationContractOverlapCount
                == 0,
              refusal
                .tuningFinalEvaluationPromptOverlapCount
                == 0,
              refusal
                .tuningFinalEvaluationSemanticOverlapCount
                == 0,
              manifest.falsifiers.map(\.id)
                == expectedFalsifierIDs,
              manifest.falsifiers.allSatisfy({
                  $0.detected
                      && $0.detections > 0
                      && $0.trials > 0
                      && !$0.family.isEmpty
              }),
              manifest.falsifierSHA256
                == "95d3241959b02b4a4cc57aa824078150f3059811f2e7745d84b7e8e16d3e104a",
              falsifierHash
                == manifest.falsifierSHA256,
              manifest.manifestSHA256
                == plan.corpusManifestSHA256,
              contentHash == manifest.manifestSHA256 else {
            throw PrimeNativeResolvedContractAdapterError
                .invalidCorpusManifest(
                    "frozen semantic contract"
                )
        }
        return manifest
    }

    private static func validateSyntheticReceipt(
        _ data: Data
    ) throws -> PrimeNativeSyntheticRegradeEnvelope {
        let envelope:
            PrimeNativeSyntheticRegradeEnvelope
        let header: SyntheticAdmissionHeader
        do {
            envelope = try JSONDecoder().decode(
                PrimeNativeSyntheticRegradeEnvelope
                    .self,
                from: data
            )
            header = try JSONDecoder().decode(
                SyntheticAdmissionHeader.self,
                from: data
            )
            try envelope.validateFrozenV1()
        } catch {
            throw PrimeNativeResolvedContractAdapterError
                .invalidSyntheticReceipt(
                    String(describing: error)
                )
        }
        guard !header.currentAdmissionEffect else {
            throw PrimeNativeResolvedContractAdapterError
                .invalidSyntheticReceipt(
                    "current admission effect"
                )
        }
        return envelope
    }

    public static func publish(
        resolutionRoot: PrimeArtifactRoot,
        adapterSourceRoot: URL,
        adapterSourcePreState:
            PrimeNativeMigrationResolverSourceState,
        adapterSourceSnapshot:
            PrimeSwiftSourceSnapshot,
        to outputRoot: PrimeArtifactRoot
    ) throws -> (
        receipt:
            PrimeNativeResolvedContractAdapterReceipt,
        receiptBinding: PrimeArtifactBinding
    ) {
        let plan =
            PrimeNativeResolvedContractAdapterPlan.frozenV1
        try plan.validate()
        try resolutionRoot.requirePrivateRootMode()

        let parentReceiptBinding =
            try resolutionRoot.bindExisting(
                at: plan.parentReceiptPath,
                purpose: .immutableData,
                maximumByteCount: 4 * 1024 * 1024
            )
        try validateParentReceiptBinding(
            parentReceiptBinding
        )
        let parentReceiptData =
            try resolutionRoot.readVerified(
                parentReceiptBinding,
                maximumByteCount: 4 * 1024 * 1024
            )
        let parent =
            try resolutionRoot.decodeVerified(
                PrimeNativeContractMigrationReceipt.self,
                binding: parentReceiptBinding,
                maximumByteCount: 4 * 1024 * 1024
            )
        try validateParentResolution(
            parent,
            in: resolutionRoot
        )
        guard parent.resolverSourceRevision
                == plan.parentResolverSourceRevision,
              parent.repository.resolvedRevision
                == plan.companionRevision,
              parent.repository.treeOID
                == plan.companionTreeOID else {
            throw PrimeNativeResolvedContractAdapterError
                .invalidParentResolution(
                    "receipt identity"
                )
        }

        let tokenizerBinding = try selectedBinding(
            plan.tokenizerArtifactID,
            in: parent
        )
        let corpusBinding = try selectedBinding(
            plan.corpusArtifactID,
            in: parent
        )
        let syntheticBinding = try selectedBinding(
            plan.syntheticReceiptArtifactID,
            in: parent
        )
        guard tokenizerBinding.sha256
                == plan.tokenizerArtifactSHA256,
              corpusBinding.sha256
                == plan.corpusArtifactSHA256,
              syntheticBinding.sha256
                == plan.syntheticReceiptArtifactSHA256 else {
            throw PrimeNativeResolvedContractAdapterError
                .invalidParentResolution(
                    "selected artifact binding"
                )
        }
        let tokenizerData =
            try resolutionRoot.readVerified(
                tokenizerBinding,
                maximumByteCount: 1024 * 1024
            )
        let corpusData =
            try resolutionRoot.readVerified(
                corpusBinding,
                maximumByteCount: 4 * 1024 * 1024
            )
        let syntheticData =
            try resolutionRoot.readVerified(
                syntheticBinding,
                maximumByteCount: 4 * 1024 * 1024
            )
        let compatibilityProjection =
            try projection(
                parent: parent,
                tokenizerData: tokenizerData,
                corpusData: corpusData,
                syntheticData: syntheticData
            )
        let mutations = try mutationSweep(
            parentReceiptBinding:
                parentReceiptBinding,
            tokenizerData: tokenizerData,
            corpusData: corpusData,
            syntheticData: syntheticData
        )

        try validateSourceState(
            adapterSourcePreState,
            expectedRemoteURL: nil,
            expectedRevision: nil,
            expectedTreeOID: nil
        )
        try PrimeSwiftSourceProvenance.validate(
            adapterSourceSnapshot,
            requiredRelativePaths:
                requiredAdapterSourcePaths
        )
        let executableData =
            try PrimeSecureRunningExecutableCapture
            .data()
        let adapterSourcePostState =
            try PrimeNativeGitBlobTransport()
            .sourceState(
                repositoryRoot: adapterSourceRoot,
                phase: .postExecutable
            )
        try validateSourceState(
            adapterSourcePostState,
            expectedRemoteURL:
                adapterSourcePreState.remoteURL,
            expectedRevision:
                adapterSourcePreState.revision,
            expectedTreeOID:
                adapterSourcePreState.treeOID
        )
        let sourceCommandObservations =
            adapterSourcePreState
                .commandObservations
            + adapterSourcePostState
                .commandObservations
        try PrimeNativeContractMigrationResolver
            .validateResolverSourceCommandObservations(
                sourceCommandObservations,
                remoteURL:
                    adapterSourcePostState.remoteURL,
                revision:
                    adapterSourcePostState.revision,
                treeOID:
                    adapterSourcePostState.treeOID,
                clean:
                    adapterSourcePostState.clean
            )

        try outputRoot.requirePrivateRootMode()
        try outputRoot.requireEmpty()
        try outputRoot.ensurePrivateDirectory(
            at: "resolved"
        )
        try outputRoot.ensurePrivateDirectory(
            at: "adapter"
        )

        let parentResolverSourceSnapshot =
            try copy(
                parent.resolverSourceSnapshot,
                from: resolutionRoot,
                to: outputRoot,
                maximumByteCount: 64 * 1024 * 1024
            )
        let parentResolverExecutable =
            try copy(
                parent.resolverExecutable,
                from: resolutionRoot,
                to: outputRoot,
                maximumByteCount:
                    PrimeSecureRunningExecutableCapture
                    .maximumByteCount
            )
        let copiedParentArtifacts =
            try parent.artifacts.map {
                try copy(
                    $0.artifact,
                    from: resolutionRoot,
                    to: outputRoot,
                    maximumByteCount:
                        32 * 1024 * 1024
                )
            }
        let copiedParentReceipt =
            try outputRoot.publish(
                parentReceiptData,
                at: plan.parentReceiptPath,
                purpose: .immutableData
            )
        try validateParentReceiptBinding(
            copiedParentReceipt
        )
        try validateParentResolution(
            parent,
            in: outputRoot
        )

        let sourceSnapshotBinding =
            try outputRoot.publishCanonical(
                adapterSourceSnapshot,
                at: plan.sourceSnapshotPath
            )
        let executableBinding =
            try outputRoot.publish(
                executableData,
                at: plan.executablePath,
                purpose: .executable
            )
        let projectionBinding =
            try outputRoot.publishCanonical(
                compatibilityProjection,
                at: plan.compatibilityProjectionPath
            )
        let receipt =
            PrimeNativeResolvedContractAdapterReceipt(
                adapterSourceRemoteURL:
                    adapterSourcePostState.remoteURL,
                adapterSourceRevision:
                    adapterSourcePostState.revision,
                adapterSourceTreeOID:
                    adapterSourcePostState.treeOID,
                adapterSourceTreeClean:
                    adapterSourcePostState.clean,
                adapterSourceCommandObservations:
                    sourceCommandObservations,
                adapterSourceSnapshot:
                    sourceSnapshotBinding,
                adapterExecutable:
                    executableBinding,
                parentReceipt:
                    copiedParentReceipt,
                parentResolverSourceSnapshot:
                    parentResolverSourceSnapshot,
                parentResolverExecutable:
                    parentResolverExecutable,
                copiedParentArtifacts:
                    copiedParentArtifacts,
                tokenizerManifest:
                    try selectedBinding(
                        plan.tokenizerArtifactID,
                        in: parent
                    ),
                corpusManifest:
                    try selectedBinding(
                        plan.corpusArtifactID,
                        in: parent
                    ),
                syntheticRegradeReceipt:
                    try selectedBinding(
                        plan.syntheticReceiptArtifactID,
                        in: parent
                    ),
                compatibilityProjection:
                    projectionBinding,
                mutationSweep: mutations
            )
        try receipt.validate(in: outputRoot)
        let receiptBinding =
            try outputRoot.publishCanonical(
                receipt,
                at: plan.outputReceiptPath
            )
        let roundTrip = try outputRoot.decodeVerified(
            PrimeNativeResolvedContractAdapterReceipt
                .self,
            binding: receiptBinding,
            maximumByteCount: 4 * 1024 * 1024
        )
        guard roundTrip == receipt else {
            throw PrimeNativeResolvedContractAdapterError
                .invalidReceipt("canonical round trip")
        }
        try roundTrip.validate(in: outputRoot)
        return (roundTrip, receiptBinding)
    }

    static func mutationSweep(
        parentReceiptBinding: PrimeArtifactBinding,
        tokenizerData: Data,
        corpusData: Data,
        syntheticData: Data
    ) throws -> [PrimeNativeResolvedContractMutationRecord] {
        let tokenizer =
            try validateTokenizer(tokenizerData)
        _ = try validateCorpus(
            corpusData,
            tokenizerManifestSHA256:
                tokenizer.manifestSHA256
        )
        _ = try validateSyntheticReceipt(syntheticData)
        try validateAuthorityClaims(.frozen)

        var records =
            [PrimeNativeResolvedContractMutationRecord]()
        records.reserveCapacity(
            PrimeNativeResolvedContractMutation
                .allCases.count
        )
        for mutation in
            PrimeNativeResolvedContractMutation.allCases
        {
            let detected: Bool
            switch mutation {
            case .wrongParentReceiptHash:
                let changed =
                    PrimeArtifactBinding(
                        relativePath:
                            parentReceiptBinding
                            .relativePath,
                        sha256:
                            String(
                                repeating: "0",
                                count: 64
                            ),
                        byteCount:
                            parentReceiptBinding
                            .byteCount,
                        purpose:
                            parentReceiptBinding
                            .purpose
                    )
                detected = throwsError {
                    try validateParentReceiptBinding(
                        changed
                    )
                }

            case .tokenizerSemanticDrift:
                let changed = try mutateObjectData(
                    tokenizerData,
                    refreshingSelfHash:
                        "manifest_sha256"
                ) {
                    $0["algorithm"] =
                        "trimmed_byte_offset"
                }
                detected = throwsError {
                    _ = try validateTokenizer(changed)
                }

            case .tokenizerInternalHashDrift:
                let changed = try mutateObjectData(
                    tokenizerData
                ) {
                    $0["manifest_sha256"] =
                        String(
                            repeating: "0",
                            count: 64
                        )
                }
                detected = throwsError {
                    _ = try validateTokenizer(changed)
                }

            case .corpusTokenizerLinkDrift:
                let changed = try mutateObjectData(
                    corpusData,
                    refreshingSelfHash:
                        "manifest_sha256"
                ) {
                    $0["tokenizer_manifest_sha256"] =
                        PrimeNativeResolvedContractAdapterPlan
                        .frozenV1
                        .tokenizerArtifactSHA256
                }
                detected = throwsError {
                    _ = try validateCorpus(
                        changed,
                        tokenizerManifestSHA256:
                            tokenizer.manifestSHA256
                    )
                }

            case .corpusAuthorityExpansion:
                let changed = try mutateObjectData(
                    corpusData,
                    refreshingSelfHash:
                        "manifest_sha256"
                ) {
                    $0["product_authorization"] =
                        "product_authorized"
                }
                detected = throwsError {
                    _ = try validateCorpus(
                        changed,
                        tokenizerManifestSHA256:
                            tokenizer.manifestSHA256
                    )
                }

            case .corpusEvaluationSeedDrift:
                let changed = try mutateObjectData(
                    corpusData,
                    refreshingSelfHash:
                        "manifest_sha256"
                ) {
                    guard var evaluation =
                            $0[
                                "evaluation_contract"
                            ] as? [String: Any] else {
                        throw PrimeNativeResolvedContractAdapterError
                            .invalidCorpusManifest(
                                "mutation fixture"
                            )
                    }
                    evaluation[
                        "multi_seed_consensus_seeds"
                    ] = [1618, 2718, 3142]
                    $0["evaluation_contract"] =
                        evaluation
                }
                detected = throwsError {
                    _ = try validateCorpus(
                        changed,
                        tokenizerManifestSHA256:
                            tokenizer.manifestSHA256
                    )
                }

            case .syntheticAdmissionExpansion:
                let changed = try mutateObjectData(
                    syntheticData
                ) {
                    $0["current_admission_effect"] =
                        true
                }
                detected = throwsError {
                    _ = try validateSyntheticReceipt(
                        changed
                    )
                }

            case .promptOnlyTargetLeakage:
                let request =
                    try PrimeNativePromptOnlyGenerationRequest(
                        rowID: "mutation-row",
                        seed: 1618,
                        promptText: "Prime prompt\n"
                    )
                let requestData =
                    try PrimeCanonicalJSON.encode(
                        request
                    )
                try validatePromptOnlyRequestData(
                    requestData
                )
                let changed = try mutateObjectData(
                    requestData
                ) {
                    $0["target"] = "5\n"
                }
                detected = throwsError {
                    try validatePromptOnlyRequestData(
                        changed
                    )
                }

            case .adapterAuthorityExpansion:
                var claims = AuthorityClaims.frozen
                claims = AuthorityClaims(
                    archiveExpanded:
                        claims.archiveExpanded,
                    companionWritePerformed:
                        claims.companionWritePerformed,
                    companionRuntimeDependencyAdded:
                        claims
                        .companionRuntimeDependencyAdded,
                    donorExecutionPerformed:
                        claims.donorExecutionPerformed,
                    neuralKitExecutionPerformed:
                        claims.neuralKitExecutionPerformed,
                    modelExecutionPerformed:
                        claims.modelExecutionPerformed,
                    functionalTrainingPerformed:
                        claims.functionalTrainingPerformed,
                    quantizationPerformed:
                        claims.quantizationPerformed,
                    productPromotionAuthorized:
                        true,
                    independentScientificOracleClaimed:
                        claims
                        .independentScientificOracleClaimed
                )
                detected = throwsError {
                    try validateAuthorityClaims(claims)
                }
            }
            guard detected else {
                throw PrimeNativeResolvedContractAdapterError
                    .mutationUndetected(
                        mutation.rawValue
                    )
            }
            records.append(
                PrimeNativeResolvedContractMutationRecord(
                    mutation: mutation,
                    detectorID:
                        mutation.detectorID,
                    detected: true,
                    restored: true,
                    independentScientificOracleClaimed:
                        false
                )
            )
        }
        return records
    }

    private static func selectedBinding(
        _ artifactID: String,
        in parent:
            PrimeNativeContractMigrationReceipt
    ) throws -> PrimeArtifactBinding {
        guard let artifact =
                parent.artifacts.first(
                    where: {
                        $0.artifactID == artifactID
                    }
                ),
              parent.artifacts.filter({
                  $0.artifactID == artifactID
              }).count == 1 else {
            throw PrimeNativeResolvedContractAdapterError
                .invalidParentResolution(
                    "selected artifact \(artifactID)"
                )
        }
        return artifact.artifact
    }

    static func validateParentResolution(
        _ parent:
            PrimeNativeContractMigrationReceipt,
        in root: PrimeArtifactRoot
    ) throws {
        let plan =
            PrimeNativeResolvedContractAdapterPlan.frozenV1
        try parent.validate()
        guard parent.resolverSourceRevision
                == plan.parentResolverSourceRevision,
              parent.repository.resolvedRevision
                == plan.companionRevision,
              parent.repository.treeOID
                == plan.companionTreeOID,
              parent.artifacts.count
                == plan.expectedParentArtifactCount,
              parent.totalMaterializedByteCount
                == plan.expectedParentArtifactByteCount else {
            throw PrimeNativeResolvedContractAdapterError
                .invalidParentResolution(
                    "historical receipt identity"
                )
        }
        let snapshot = try root.decodeVerified(
            PrimeSwiftSourceSnapshot.self,
            binding: parent.resolverSourceSnapshot,
            maximumByteCount: 64 * 1024 * 1024
        )
        let historicalExpectation =
            PrimeSwiftSourceProvenanceExpectation(
                sourceIdentitySHA256:
                    plan
                    .parentResolverSourceIdentitySHA256,
                buildConfiguration: "release"
            )
        try PrimeSwiftSourceProvenance.validate(
            snapshot,
            requiredRelativePaths:
                PrimeNativeContractMigrationResolver
                .requiredResolverSourcePaths,
            expectation: historicalExpectation
        )
        _ = try root.verify(
            parent.resolverExecutable
        )
        for artifact in parent.artifacts {
            _ = try root.verify(
                artifact.artifact
            )
        }
    }

    private static func validateParentReceiptBinding(
        _ binding: PrimeArtifactBinding
    ) throws {
        let plan =
            PrimeNativeResolvedContractAdapterPlan.frozenV1
        guard binding.relativePath
                == plan.parentReceiptPath,
              binding.sha256
                == plan.parentReceiptSHA256,
              binding.byteCount
                == plan.parentReceiptByteCount,
              binding.purpose == .immutableData else {
            throw PrimeNativeResolvedContractAdapterError
                .invalidParentResolution(
                    "receipt binding"
                )
        }
    }

    private static func validateSourceState(
        _ state:
            PrimeNativeMigrationResolverSourceState,
        expectedRemoteURL: String?,
        expectedRevision: String?,
        expectedTreeOID: String?
    ) throws {
        let parentPlan =
            PrimeNativeContractMigrationPlan.frozenV1
        guard parentPlan
                .acceptedResolverRemoteURLs
                .contains(state.remoteURL),
              expectedRemoteURL.map({
                  $0 == state.remoteURL
              }) ?? true,
              PrimeNativeContractMigrationPlan
                .isGitOID(state.revision),
              expectedRevision.map({
                  $0 == state.revision
              }) ?? true,
              PrimeNativeContractMigrationPlan
                .isGitOID(state.treeOID),
              expectedTreeOID.map({
                  $0 == state.treeOID
              }) ?? true,
              state.clean else {
            throw PrimeNativeResolvedContractAdapterError
                .invalidReceipt(
                    "adapter source identity"
                )
        }
    }

    private static func copy(
        _ binding: PrimeArtifactBinding,
        from inputRoot: PrimeArtifactRoot,
        to outputRoot: PrimeArtifactRoot,
        maximumByteCount: UInt64
    ) throws -> PrimeArtifactBinding {
        let data = try inputRoot.readVerified(
            binding,
            maximumByteCount: maximumByteCount
        )
        let copied = try outputRoot.publish(
            data,
            at: binding.relativePath,
            purpose: binding.purpose
        )
        guard copied == binding else {
            throw PrimeNativeResolvedContractAdapterError
                .invalidParentResolution(
                    "lossless artifact copy"
                )
        }
        return copied
    }

    private static func validatePromptOnlyRequestData(
        _ data: Data
    ) throws {
        let value = try JSONSerialization
            .jsonObject(with: data)
        guard let object =
                value as? [String: Any],
              Set(object.keys) == Set([
                  "row_id",
                  "seed",
                  "prompt_text",
                  "prompt_token_ids",
                  "prompt_grouping_key",
              ]) else {
            throw PrimeNativeResolvedContractAdapterError
                .invalidProjection(
                    "prompt-only request fields"
                )
        }
    }

    private static func validateAuthorityClaims(
        _ claims: AuthorityClaims
    ) throws {
        guard claims == .frozen else {
            throw PrimeNativeResolvedContractAdapterError
                .invalidProjection(
                    "authority expansion"
                )
        }
    }

    private static func canonicalContentSHA256(
        _ data: Data,
        removingTopLevelKey key: String
    ) throws -> String {
        let value = try JSONSerialization
            .jsonObject(with: data)
        guard var object =
                value as? [String: Any],
              object.removeValue(forKey: key)
                != nil else {
            throw PrimeNativeResolvedContractAdapterError
                .invalidCorpusManifest(
                    "content hash payload"
                )
        }
        return PrimeSHA256.hexDigest(
            of: try canonicalJSONObjectData(object)
        )
    }

    private static func canonicalArraySHA256(
        _ data: Data,
        topLevelKey key: String
    ) throws -> String {
        let value = try JSONSerialization
            .jsonObject(with: data)
        guard let object =
                value as? [String: Any],
              let array = object[key] as? [Any] else {
            throw PrimeNativeResolvedContractAdapterError
                .invalidCorpusManifest(
                    "array hash payload"
                )
        }
        return PrimeSHA256.hexDigest(
            of: try canonicalJSONObjectData(array)
        )
    }

    private static func mutateObjectData(
        _ data: Data,
        refreshingSelfHash: String? = nil,
        mutation:
            (inout [String: Any]) throws -> Void
    ) throws -> Data {
        let value = try JSONSerialization
            .jsonObject(with: data)
        guard var object =
                value as? [String: Any] else {
            throw PrimeNativeResolvedContractAdapterError
                .invalidProjection(
                    "mutation object"
                )
        }
        try mutation(&object)
        if let refreshingSelfHash {
            guard object.removeValue(
                forKey: refreshingSelfHash
            ) != nil else {
                throw PrimeNativeResolvedContractAdapterError
                    .invalidProjection(
                        "mutation self hash"
                    )
            }
            object[refreshingSelfHash] =
                PrimeSHA256.hexDigest(
                    of:
                        try canonicalJSONObjectData(
                            object
                        )
                )
        }
        return try canonicalJSONObjectData(object)
    }

    private static func canonicalJSONObjectData(
        _ value: Any
    ) throws -> Data {
        guard JSONSerialization.isValidJSONObject(
            value
        ) else {
            throw PrimeNativeResolvedContractAdapterError
                .invalidProjection(
                    "canonical JSON object"
                )
        }
        return try JSONSerialization.data(
            withJSONObject: value,
            options: [
                .sortedKeys,
                .withoutEscapingSlashes,
            ]
        )
    }

    private static func throwsError(
        _ operation: () throws -> Void
    ) -> Bool {
        do {
            try operation()
            return false
        } catch {
            return true
        }
    }
}
