import Foundation

public enum PrimeLatinProposalInputsV3Error: Error, Equatable, Sendable {
    case invalidDocument(String)
    case invalidSemantics(String)
    case unsupportedSource(String)
}

public struct PrimeLatinProposalInputsV3SourceObservation:
    Equatable,
    Sendable
{
    public let repository: String
    public let commit: String
    public let tree: String

    fileprivate init(repository: String, commit: String, tree: String) {
        self.repository = repository
        self.commit = commit
        self.tree = tree
    }
}

public struct PrimeLatinProposalInputsV3AuthorityBoundary:
    Equatable,
    Sendable
{
    public let disposition: String
    public let canonicalWireRedecodeComplete: Bool
    public let embeddedHashChainRecomputationComplete: Bool
    public let referencedInputSnapshotAvailable: Bool
    public let referencedArtifactBytesAvailable: Bool
    public let liveProducerWorkspaceRevalidationComplete: Bool
    public let llmGitStateIndependentlyObserved: Bool
    public let independentReplayComplete: Bool
    public let runtimeDecoderImplementationAvailable: Bool
    public let runtimeDependencyClosureEstablished: Bool
    public let runtimeInitializationEstablished: Bool
    public let primeProposalPacketProduced: Bool
    public let primeTrialAuthorizationProduced: Bool
    public let primeDecisionReceiptProduced: Bool
    public let candidateSelectionAuthorized: Bool
    public let trialExecutionAuthorized: Bool
    public let furtherTrainingAuthorized: Bool
    public let promotionAuthorized: Bool
    public let productUseAuthorized: Bool
    public let publicationAuthorized: Bool
    public let durableReceiptPublished: Bool

    fileprivate init() {
        disposition =
            "abstain_requires_original_bound_input_bytes_and_live_provenance"
        canonicalWireRedecodeComplete = true
        embeddedHashChainRecomputationComplete = true
        referencedInputSnapshotAvailable = false
        referencedArtifactBytesAvailable = false
        liveProducerWorkspaceRevalidationComplete = false
        llmGitStateIndependentlyObserved = false
        independentReplayComplete = false
        runtimeDecoderImplementationAvailable = false
        runtimeDependencyClosureEstablished = false
        runtimeInitializationEstablished = false
        primeProposalPacketProduced = false
        primeTrialAuthorizationProduced = false
        primeDecisionReceiptProduced = false
        candidateSelectionAuthorized = false
        trialExecutionAuthorized = false
        furtherTrainingAuthorized = false
        promotionAuthorized = false
        productUseAuthorized = false
        publicationAuthorized = false
        durableReceiptPublished = false
    }
}

public struct PrimeLatinProposalInputsV3Observation:
    Equatable,
    Sendable
{
    public let schema: String
    public let outcome: String
    public let verificationScope: String
    public let llmSource: PrimeLatinProposalInputsV3SourceObservation
    public let candidateCatalogSHA256: String
    public let candidateCatalogByteCount: UInt64
    public let candidateDeclarationSetSHA256: String
    public let candidateDeclarationSetByteCount: UInt64
    public let tokenizerBundleSHA256: String
    public let tokenizerBundleByteCount: UInt64
    public let candidateIDs: [String]
    public let candidateIdentitySHA256s: [String]
    public let declarationBundleSHA256s: [String]
    public let outputNamespace: String
    public let authority: PrimeLatinProposalInputsV3AuthorityBoundary

    fileprivate init(
        catalogData: Data,
        catalog: PrimeLatinCandidateCatalogWireV3,
        experiment: PrimeLatinExperimentManifestWireV3
    ) {
        schema = "ergentics_prime_latin_proposal_inputs_v3_observation"
        outcome = "abstain"
        verificationScope =
            "canonical_v3_wire_and_embedded_hash_chain_only_non_authorizing"
        llmSource = PrimeLatinProposalInputsV3SourceObservation(
            repository: catalog.llmSource.repository,
            commit: catalog.llmSource.commit,
            tree: catalog.llmSource.tree)
        candidateCatalogSHA256 = PrimeLatinSHA256.hexDigest(of: catalogData)
        candidateCatalogByteCount = UInt64(catalogData.count)
        candidateDeclarationSetSHA256 =
            catalog.candidateDeclarationSetSHA256
        candidateDeclarationSetByteCount =
            catalog.candidateDeclarationSetByteCount
        tokenizerBundleSHA256 =
            catalog.tokenizerProposalBinding.tokenizerBundleSHA256
        tokenizerBundleByteCount =
            catalog.tokenizerProposalBinding.tokenizerBundleByteCount
        candidateIDs = experiment.candidateIDs
        candidateIdentitySHA256s = catalog.candidateDeclarations.candidates.map(
            \.candidateIdentitySHA256)
        declarationBundleSHA256s = catalog.candidateDeclarations.candidates.map(
            \.declarationBundleSHA256)
        outputNamespace = experiment.outputNamespace
        authority = PrimeLatinProposalInputsV3AuthorityBoundary()
    }
}

public enum PrimeLatinProposalInputsV3 {
    public static func consume(
        candidateCatalogData: Data,
        experimentManifestData: Data
    ) throws -> PrimeLatinProposalInputsV3Observation {
        let documents = try validatedDocuments(
            candidateCatalogData: candidateCatalogData,
            experimentManifestData: experimentManifestData)
        return PrimeLatinProposalInputsV3Observation(
            catalogData: candidateCatalogData,
            catalog: documents.catalog,
            experiment: documents.experiment)
    }

    static func inputSnapshotMaterial(
        candidateCatalogData: Data,
        experimentManifestData: Data
    ) throws -> PrimeLatinProposalInputsV3SnapshotMaterial {
        let documents = try validatedDocuments(
            candidateCatalogData: candidateCatalogData,
            experimentManifestData: experimentManifestData)
        guard isFinalHandoffSource(documents.catalog.llmSource),
              isFinalHandoffSource(documents.experiment.llmSource) else {
            throw PrimeLatinProposalInputsV3Error.unsupportedSource(
                "input_snapshot_source")
        }
        let observation = PrimeLatinProposalInputsV3Observation(
            catalogData: candidateCatalogData,
            catalog: documents.catalog,
            experiment: documents.experiment)
        return PrimeLatinProposalInputsV3SnapshotMaterial(
            inputsObservation: observation,
            expectations: normalizedSnapshotExpectations(
                catalog: documents.catalog,
                experiment: documents.experiment),
            outputNamespace: documents.experiment.outputNamespace)
    }

    private static func validatedDocuments(
        candidateCatalogData: Data,
        experimentManifestData: Data
    ) throws -> (
        catalog: PrimeLatinCandidateCatalogWireV3,
        experiment: PrimeLatinExperimentManifestWireV3
    ) {
        let catalog: PrimeLatinCandidateCatalogWireV3 = try decode(
            candidateCatalogData,
            document: "candidate_catalog_v3")
        let experiment: PrimeLatinExperimentManifestWireV3 = try decode(
            experimentManifestData,
            document: "experiment_manifest_v3")
        try validate(
            catalog: catalog,
            catalogData: candidateCatalogData,
            experiment: experiment)
        return (catalog, experiment)
    }

    private static func normalizedSnapshotExpectations(
        catalog: PrimeLatinCandidateCatalogWireV3,
        experiment: PrimeLatinExperimentManifestWireV3
    ) -> [PrimeLatinProposalInputArtifactExpectationV3] {
        let tokenizer = catalog.tokenizerProposalBinding.tokenizerBundle
        let candidate = catalog.candidateDeclarations.candidates[0]
            .declarationBundle
        return [
            snapshotExpectation(
                "root_package_manifest", catalog.packageManifest),
            snapshotExpectation(
                "root_dependency_lock", catalog.dependencyLock),
            snapshotExpectation(
                "declaration_package_manifest",
                candidate.nestedPackageManifest.artifact),
            snapshotExpectation(
                "declaration_production_source",
                candidate.productionSources[0].artifact),
            snapshotExpectation(
                "candidate_architecture",
                candidate.architectureArtifact.artifact),
            snapshotExpectation(
                "candidate_parameter_count_derivation",
                candidate.parameterCountDerivationArtifact.artifact),
            snapshotExpectation(
                "evaluation_contract", experiment.evaluationContract),
            snapshotExpectation(
                "tokenizer_manifest", tokenizer.tokenizerManifest.artifact),
            snapshotExpectation(
                "tokenizer_sentencepiece_model",
                tokenizer.sentencePieceModel.artifact),
            snapshotExpectation(
                "tokenizer_vocabulary", tokenizer.vocabulary.artifact),
            snapshotExpectation(
                "tokenizer_recommendation", tokenizer.recommendation.artifact),
            snapshotExpectation(
                "tokenizer_approval", tokenizer.approval.artifact),
            snapshotExpectation(
                "tokenizer_staged_training_input",
                tokenizer.stagedTrainingInput.artifact),
            snapshotExpectation(
                "tokenizer_corpus_manifest", tokenizer.corpusManifest.artifact),
            snapshotExpectation(
                "tokenizer_admitted_corpus_input",
                tokenizer.manifestListedCorpusInputs[0].artifact),
            snapshotExpectation(
                "initialization_contract", catalog.initializationContract),
            snapshotExpectation(
                "prospective_corpus_manifest", experiment.corpusManifest),
            snapshotExpectation(
                "training_split", experiment.splits.trainingSplit),
            snapshotExpectation(
                "validation_split", experiment.splits.validationSplit),
            snapshotExpectation(
                "selection_split", experiment.splits.selectionSplit),
            snapshotExpectation(
                "selection_observation_declaration",
                experiment.splits.selectionObservationDeclaration),
        ]
    }

    private static func snapshotExpectation(
        _ role: String,
        _ binding: PrimeLatinArtifactBindingWire
    ) -> PrimeLatinProposalInputArtifactExpectationV3 {
        PrimeLatinProposalInputArtifactExpectationV3(
            role: role,
            scope: binding.scope == .ergenticsLLMRepository
                ? .ergenticsLLMRepository
                : .ergenticsMLXLab,
            relativePath: binding.relativePath,
            sha256: binding.sha256,
            byteCount: binding.byteCount)
    }
}

private enum PrimeLatinArtifactScopeWire: String, Codable, Sendable {
    case ergenticsLLMRepository = "ergentics_llm_repository"
    case ergenticsMLXLab = "ergentics_mlx_lab"
}

private struct PrimeLatinGitSourceWire: Codable, Equatable, Sendable {
    let repository: String
    let commit: String
    let tree: String
}

private struct PrimeLatinArtifactBindingWire: Codable, Equatable, Sendable {
    let scope: PrimeLatinArtifactScopeWire
    let relativePath: String
    let sha256: String
    let byteCount: UInt64
}

private struct PrimeLatinCommittedArtifactBindingWire:
    Codable,
    Equatable,
    Sendable
{
    let artifact: PrimeLatinArtifactBindingWire
    let gitBlobOID: String
}

private struct PrimeLatinTokenizerRoleBindingWireV2:
    Codable,
    Equatable,
    Sendable
{
    let role: String
    let artifact: PrimeLatinArtifactBindingWire
}

private struct PrimeLatinTokenizerNonAuthorityWireV2:
    Codable,
    Equatable,
    Sendable
{
    let primeProposalAuthority: String
    let architectureAuthority: Bool
    let trialExecutionAuthority: Bool
    let trainingAuthority: Bool
    let promotionAuthority: Bool
    let productUseAuthority: Bool
}

private struct PrimeLatinTokenizerBundleWireV2:
    Codable,
    Equatable,
    Sendable
{
    let schema: String
    let tokenizerID: String
    let bindingScope: String
    let tokenizerManifest: PrimeLatinTokenizerRoleBindingWireV2
    let sentencePieceModel: PrimeLatinTokenizerRoleBindingWireV2
    let vocabulary: PrimeLatinTokenizerRoleBindingWireV2
    let recommendation: PrimeLatinTokenizerRoleBindingWireV2
    let approval: PrimeLatinTokenizerRoleBindingWireV2
    let stagedTrainingInput: PrimeLatinTokenizerRoleBindingWireV2
    let corpusManifest: PrimeLatinTokenizerRoleBindingWireV2
    let manifestListedCorpusInputs: [PrimeLatinTokenizerRoleBindingWireV2]
    let recommendationApprovalAttributionAssurance: String
    let cryptographicHumanAuthentication: Bool
    let corpusProvenanceScope: String
    let modelSemanticValidation: String
    let sentencePieceToolDisposition: String
    let sentencePieceTrainerValidation: String
    let trainingReplayStatus: String
    let snapshotConsistency: String
    let authorityStatus: String
    let authority: PrimeLatinTokenizerNonAuthorityWireV2
}

private struct PrimeLatinTokenizerProposalBindingWireV2:
    Codable,
    Equatable,
    Sendable
{
    let schema: String
    let tokenizerBundleSHA256: String
    let tokenizerBundleByteCount: UInt64
    let tokenizerBundle: PrimeLatinTokenizerBundleWireV2
    let bindingScope: String
    let liveRevalidationPolicy: String
    let publicationStatus: String
    let authorityStatus: String
}

private struct PrimeLatinUnreachablePackagePinWireV1:
    Codable,
    Equatable,
    Sendable
{
    let identity: String
    let kind: String
    let location: String
    let revision: String
    let version: String?
    let reachableFromDeclarationTarget: Bool

    enum CodingKeys: String, CodingKey {
        case identity
        case kind
        case location
        case revision
        case version
        case reachableFromDeclarationTarget =
            "reachable_from_declaration_target"
    }
}

private struct PrimeLatinDeclarationTargetClosureWireV1:
    Codable,
    Equatable,
    Sendable
{
    let schema: String
    let scope: String
    let targetName: String
    let nestedPackageManifest: PrimeLatinCommittedArtifactBindingWire
    let productionSources: [PrimeLatinCommittedArtifactBindingWire]
    let rootPackageLock: PrimeLatinCommittedArtifactBindingWire
    let directTargetDependencies: [String]
    let reachableLocalTargets: [String]
    let reachableExternalProducts: [String]
    let reachablePackagePins: [String]
    let unreachableRootPackagePins: [PrimeLatinUnreachablePackagePinWireV1]
    let pathDependencyCount: UInt64
    let binaryTargetCount: UInt64
    let systemLibraryTargetCount: UInt64
    let pluginCount: UInt64
    let macroCount: UInt64
    let unsafeFlagCount: UInt64
    let nestedPackageLockStatus: String
    let declarationTargetSourceClosure: String
    let declarationTargetDependencyClosure: String
}

private struct PrimeLatinCandidateAuthorityWireV1:
    Codable,
    Equatable,
    Sendable
{
    let runtimeDecoderImplementation: String
    let runtimeDependencyClosure: String
    let initialization: String
    let primeProposal: String
    let primeDecisionReceipt: String
    let primeAuthority: Bool
    let executionAuthority: Bool
    let trainingAuthority: Bool
    let promotionAuthority: Bool
    let productAuthority: Bool
    let publicationAuthority: Bool

    enum CodingKeys: String, CodingKey {
        case runtimeDecoderImplementation = "runtime_decoder_implementation"
        case runtimeDependencyClosure = "runtime_dependency_closure"
        case initialization
        case primeProposal = "prime_proposal"
        case primeDecisionReceipt = "prime_decision_receipt"
        case primeAuthority = "prime_authority"
        case executionAuthority = "execution_authority"
        case trainingAuthority = "training_authority"
        case promotionAuthority = "promotion_authority"
        case productAuthority = "product_authority"
        case publicationAuthority = "publication_authority"
    }
}

private struct PrimeLatinCandidateTokenizerWireV1:
    Codable,
    Equatable,
    Sendable
{
    let tokenizerID: String
    let proposalBundleSHA256: String
    let proposalBundleByteCount: UInt64
    let vocabularySize: UInt64
    let unknownTokenID: UInt64
    let beginningOfSequenceTokenID: UInt64
    let endOfSequenceTokenID: UInt64
    let paddingTokenID: UInt64

    enum CodingKeys: String, CodingKey {
        case tokenizerID = "tokenizer_id"
        case proposalBundleSHA256 = "proposal_bundle_sha256"
        case proposalBundleByteCount = "proposal_bundle_byte_count"
        case vocabularySize = "vocabulary_size"
        case unknownTokenID = "unk_token_id"
        case beginningOfSequenceTokenID = "bos_token_id"
        case endOfSequenceTokenID = "eos_token_id"
        case paddingTokenID = "pad_token_id"
    }
}

private struct PrimeLatinCandidateGeometryWireV1:
    Codable,
    Equatable,
    Sendable
{
    let maximumSequenceLength: UInt64
    let modelWidth: UInt64
    let layerCount: UInt64
    let attentionHeadCount: UInt64
    let attentionHeadWidth: UInt64
    let intermediateWidth: UInt64

    enum CodingKeys: String, CodingKey {
        case maximumSequenceLength = "maximum_sequence_length"
        case modelWidth = "model_width"
        case layerCount = "layer_count"
        case attentionHeadCount = "attention_head_count"
        case attentionHeadWidth = "attention_head_width"
        case intermediateWidth = "intermediate_width"
    }
}

private struct PrimeLatinCandidateAttentionPolicyWireV1:
    Codable,
    Equatable,
    Sendable
{
    let mechanism: String
    let causalMaskPolicy: String
    let biasPolicy: String

    enum CodingKeys: String, CodingKey {
        case mechanism
        case causalMaskPolicy = "causal_mask_policy"
        case biasPolicy = "bias_policy"
    }
}

private struct PrimeLatinCandidateFeedForwardPolicyWireV1:
    Codable,
    Equatable,
    Sendable
{
    let mechanism: String
    let activation: String
    let gatingPolicy: String
    let biasPolicy: String

    enum CodingKeys: String, CodingKey {
        case mechanism
        case activation
        case gatingPolicy = "gating_policy"
        case biasPolicy = "bias_policy"
    }
}

private struct PrimeLatinCandidateNormalizationEpsilonWireV1:
    Codable,
    Equatable,
    Sendable
{
    let numerator: UInt64
    let denominator: UInt64
}

private struct PrimeLatinCandidateNormalizationPolicyWireV1:
    Codable,
    Equatable,
    Sendable
{
    let placement: String
    let mechanism: String
    let parameterPolicy: String
    let epsilon: PrimeLatinCandidateNormalizationEpsilonWireV1

    enum CodingKeys: String, CodingKey {
        case placement
        case mechanism
        case parameterPolicy = "parameter_policy"
        case epsilon
    }
}

private struct PrimeLatinCandidatePoliciesWireV1:
    Codable,
    Equatable,
    Sendable
{
    let attention: PrimeLatinCandidateAttentionPolicyWireV1
    let feedForward: PrimeLatinCandidateFeedForwardPolicyWireV1
    let normalization: PrimeLatinCandidateNormalizationPolicyWireV1
    let position: String
    let projection: String

    enum CodingKeys: String, CodingKey {
        case attention
        case feedForward = "feed_forward"
        case normalization
        case position
        case projection
    }
}

private struct PrimeLatinCandidateTensorWireV1:
    Codable,
    Equatable,
    Sendable
{
    let role: String
    let storageID: String
    let dimensions: [UInt64]

    enum CodingKeys: String, CodingKey {
        case role
        case storageID = "storage_id"
        case dimensions
    }
}

private struct PrimeLatinCandidateCountTermWireV1:
    Codable,
    Equatable,
    Sendable
{
    let role: String
    let storageID: String
    let dimensions: [UInt64]
    let elementCount: UInt64
    let countedAsUniqueStorage: Bool

    enum CodingKeys: String, CodingKey {
        case role
        case storageID = "storage_id"
        case dimensions
        case elementCount = "element_count"
        case countedAsUniqueStorage = "counted_as_unique_storage"
    }
}

private struct PrimeLatinCandidateArchitectureWireV1:
    Codable,
    Equatable,
    Sendable
{
    let schema: String
    let candidateSlug: String
    let fixtureOnly: Bool
    let sourceAttribution: String
    let cryptographicHumanAuthentication: Bool
    let tokenizer: PrimeLatinCandidateTokenizerWireV1
    let geometry: PrimeLatinCandidateGeometryWireV1
    let policies: PrimeLatinCandidatePoliciesWireV1
    let orderedTensors: [PrimeLatinCandidateTensorWireV1]
    let authorityBoundary: PrimeLatinCandidateAuthorityWireV1

    enum CodingKeys: String, CodingKey {
        case schema
        case candidateSlug = "candidate_slug"
        case fixtureOnly = "fixture_only"
        case sourceAttribution = "source_attribution"
        case cryptographicHumanAuthentication =
            "cryptographic_human_authentication"
        case tokenizer
        case geometry
        case policies
        case orderedTensors = "ordered_tensors"
        case authorityBoundary = "authority_boundary"
    }
}

private struct PrimeLatinCandidateDerivationWireV1:
    Codable,
    Equatable,
    Sendable
{
    let schema: String
    let architectureSchema: String
    let candidateSlug: String
    let fixtureOnly: Bool
    let sourceAttribution: String
    let cryptographicHumanAuthentication: Bool
    let status: String
    let orderedTerms: [PrimeLatinCandidateCountTermWireV1]
    let uniqueStorageCount: UInt64
    let totalParameterCount: UInt64
    let authorityBoundary: PrimeLatinCandidateAuthorityWireV1

    enum CodingKeys: String, CodingKey {
        case schema
        case architectureSchema = "architecture_schema"
        case candidateSlug = "candidate_slug"
        case fixtureOnly = "fixture_only"
        case sourceAttribution = "source_attribution"
        case cryptographicHumanAuthentication =
            "cryptographic_human_authentication"
        case status
        case orderedTerms = "ordered_terms"
        case uniqueStorageCount = "unique_storage_count"
        case totalParameterCount = "total_parameter_count"
        case authorityBoundary = "authority_boundary"
    }
}

private struct PrimeLatinCandidateIdentityMaterialWireV1:
    Codable,
    Equatable,
    Sendable
{
    let schema: String
    let laneID: String
    let llmSource: PrimeLatinGitSourceWire
    let candidateSlug: String
    let sourceAttribution: String
    let tokenizerID: String
    let tokenizerBundleSHA256: String
    let tokenizerBundleByteCount: UInt64
    let tokenizerVocabularySize: UInt64
    let architectureSHA256: String
    let architectureByteCount: UInt64
    let parameterCountDerivationSHA256: String
    let parameterCountDerivationByteCount: UInt64
    let declarationTargetClosureSHA256: String
    let declarationTargetClosureByteCount: UInt64
}

private struct PrimeLatinCandidateDeclarationBundleWireV1:
    Codable,
    Equatable,
    Sendable
{
    let schema: String
    let laneID: String
    let llmSource: PrimeLatinGitSourceWire
    let tokenizerProposalBinding: PrimeLatinTokenizerProposalBindingWireV2
    let nestedPackageManifest: PrimeLatinCommittedArtifactBindingWire
    let productionSources: [PrimeLatinCommittedArtifactBindingWire]
    let architectureArtifact: PrimeLatinCommittedArtifactBindingWire
    let architecture: PrimeLatinCandidateArchitectureWireV1
    let parameterCountDerivationArtifact:
        PrimeLatinCommittedArtifactBindingWire
    let parameterCountDerivation: PrimeLatinCandidateDerivationWireV1
    let declarationTargetClosure: PrimeLatinDeclarationTargetClosureWireV1
    let identityMaterial: PrimeLatinCandidateIdentityMaterialWireV1
    let candidateIdentitySHA256: String
    let declarationTargetSourceClosure: String
    let declarationTargetDependencyClosure: String
    let parameterCountStatus: String
    let runtimeDecoderImplementation: String
    let runtimeDependencyClosure: String
    let initializationStatus: String
    let publicationStatus: String
    let authority: PrimeLatinCandidateAuthorityWireV1
}

private struct PrimeLatinCandidateDeclarationBindingWireV3:
    Codable,
    Equatable,
    Sendable
{
    let candidateID: String
    let sourceAttribution: String
    let attributionAssurance: String
    let cryptographicHumanAuthentication: Bool
    let candidateIdentitySHA256: String
    let declarationBundleSHA256: String
    let declarationBundleByteCount: UInt64
    let declarationBundle: PrimeLatinCandidateDeclarationBundleWireV1
}

private struct PrimeLatinCandidateDeclarationSetWireV3:
    Codable,
    Equatable,
    Sendable
{
    let schema: String
    let laneID: String
    let candidates: [PrimeLatinCandidateDeclarationBindingWireV3]
}

private struct PrimeLatinDependencyQuarantineWire:
    Codable,
    Equatable,
    Sendable
{
    let policyID: String
    let packageManifest: PrimeLatinArtifactBindingWire
    let dependencyLock: PrimeLatinArtifactBindingWire
    let candidateImplementationSources: [PrimeLatinArtifactBindingWire]
    let authorityTargetDependencyCount: UInt64
    let lockfilePinScanComplete: Bool
    let status: String
}

private struct PrimeLatinCandidateCatalogWireV3:
    Codable,
    Equatable,
    Sendable
{
    let schema: String
    let laneID: String
    let llmSource: PrimeLatinGitSourceWire
    let packageManifest: PrimeLatinArtifactBindingWire
    let dependencyLock: PrimeLatinArtifactBindingWire
    let tokenizerProposalBinding: PrimeLatinTokenizerProposalBindingWireV2
    let initializationContract: PrimeLatinArtifactBindingWire
    let candidateDeclarations: PrimeLatinCandidateDeclarationSetWireV3
    let candidateDeclarationSetSHA256: String
    let candidateDeclarationSetByteCount: UInt64
    let ergenticsMLXLocation: String
    let ergenticsMLXRevision: String
    let quarantinePolicyID: String
    let proposalInputDependencyQuarantine: PrimeLatinDependencyQuarantineWire
    let declarationTargetSourceClosureStatus: String
    let declarationTargetDependencyClosureStatus: String
    let runtimeDecoderImplementationStatus: String
    let runtimeCandidateDependencyClosureStatus: String
    let initializationStatus: String
    let parameterCountStatus: String
    let completenessStatus: String
    let primeConsumerStatus: String
    let publicationStatus: String
    let authorityStatus: String
}

private struct PrimeLatinSplitSetWire:
    Codable,
    Equatable,
    Sendable
{
    let trainingSplitID: String
    let validationSplitID: String
    let selectionSplitID: String
    let selectionDataStatus: String
    let trainingSplit: PrimeLatinArtifactBindingWire
    let validationSplit: PrimeLatinArtifactBindingWire
    let selectionSplit: PrimeLatinArtifactBindingWire
    let selectionObservationDeclaration: PrimeLatinArtifactBindingWire
}

private struct PrimeLatinTrialBudgetWire:
    Codable,
    Equatable,
    Sendable
{
    let application: String
    let optimizerSteps: UInt64
    let trainingTokens: UInt64
    let wallClockSeconds: UInt64
}

private struct PrimeLatinExperimentAuthorityWireV3:
    Codable,
    Equatable,
    Sendable
{
    let primeProposalPacket: String
    let primeTrialAuthorization: String
    let primeDecisionReceipt: String
    let candidateSelectionAuthorized: Bool
    let trialExecutionAuthorized: Bool
    let furtherTrainingAuthorized: Bool
    let promotionAuthorized: Bool
    let productUseAuthorized: Bool
    let publicationAuthorized: Bool
}

private struct PrimeLatinExperimentManifestWireV3:
    Codable,
    Equatable,
    Sendable
{
    let schema: String
    let laneID: String
    let llmSource: PrimeLatinGitSourceWire
    let candidateCatalogSHA256: String
    let candidateCatalogByteCount: UInt64
    let candidateDeclarationSetSHA256: String
    let candidateDeclarationSetByteCount: UInt64
    let candidateIDs: [String]
    let dependencyLock: PrimeLatinArtifactBindingWire
    let tokenizerBundleSHA256: String
    let tokenizerBundleByteCount: UInt64
    let initializationContract: PrimeLatinArtifactBindingWire
    let corpusManifest: PrimeLatinArtifactBindingWire
    let evaluationContract: PrimeLatinArtifactBindingWire
    let splits: PrimeLatinSplitSetWire
    let requestedTrialBudget: PrimeLatinTrialBudgetWire
    let outputNamespace: String
    let outputDisposition: String
    let completenessStatus: String
    let primeConsumerStatus: String
    let publicationStatus: String
    let authority: PrimeLatinExperimentAuthorityWireV3
}

private extension PrimeLatinProposalInputsV3 {
    static let maximumCanonicalDocumentBytes = 1_048_576
    static let maximumArtifactByteCount: UInt64 = 8_388_608
    static let repository = "Ergentics/ergentics-llm"
    static let mergedCommit =
        "c0e4cb37cc0ac221925b3b5c67b8ec3f24034537"
    static let mergedTree =
        "81334b9f01391a80e16247d5a840692792ef2ea7"
    static let mergedPublisherCommit =
        "3f6097af42510237595acd84bc8b442f953eef72"
    static let mergedPublisherTree =
        "489e96d317179943effc781103edb0b8efeafaea"
    static let finalHandoffCommit =
        "776c412e3f10e8bf4e33cd0ae60787d9ca6b5831"
    static let finalHandoffTree =
        "c1f41758aea2860ab06039776f5ea0403dff1b61"
    static let finalEvaluationContractPath =
        "Research/Latin/evaluation_contract.json"
    static let finalEvaluationContractSHA256 =
        "4a0dd1bc973f7ce380df9775413c4e43033ba0cc409fb45a9368c2bef6835d52"
    static let finalEvaluationContractByteCount: UInt64 = 164
    static let laneID = "latin_primary_prospective_v1"
    static let candidateID = "latin_structural_fixture_v1"
    static let sourceAttribution =
        "ergentics_codex_assisted_structural_fixture"
    static let quarantinePolicyID =
        "ergentics_latin_first_party_dependency_quarantine_v1"
    static let ergenticsMLXLocation =
        "https://github.com/Ergentics/ergentics-mlx-swift"
    static let ergenticsMLXRevision =
        "d37885a278f1c37484a94d0f401a418735e66519"
    static let tokenizerBundleSHA256 =
        "9fa3b6eea42a9c4c13ec1ecda2309ec4c35b3022638ae61a08dd2f0fcb9b074c"
    static let tokenizerBundleByteCount: UInt64 = 2_930

    static let forbiddenContext = [
        "llama",
        "mlxllm",
        "mlx-swift-lm",
        "mlx_swift_lm",
        "mlx-community",
        "huggingface",
        "runtime-bundle-3b",
        "primecore",
        "pmhnp",
        "ml-explore/mlx-swift",
    ]

    static func decode<Value: Codable>(
        _ data: Data,
        document: String
    ) throws -> Value {
        guard !data.isEmpty,
              data.count <= maximumCanonicalDocumentBytes
        else {
            throw PrimeLatinProposalInputsV3Error.invalidDocument(document)
        }
        do {
            return try PrimeLatinCanonicalJSON.decode(
                Value.self,
                from: data,
                artifact: document)
        } catch {
            throw PrimeLatinProposalInputsV3Error.invalidDocument(document)
        }
    }

    static func canonicalData<Value: Encodable>(
        _ value: Value,
        context: String
    ) throws -> Data {
        do {
            return try PrimeLatinCanonicalJSON.encode(value)
        } catch {
            throw PrimeLatinProposalInputsV3Error.invalidSemantics(context)
        }
    }

    static func canonicalLineData<Value: Encodable>(
        _ value: Value,
        context: String
    ) throws -> Data {
        var data = try canonicalData(value, context: context)
        data.append(0x0a)
        return data
    }

    static func validate(
        catalog: PrimeLatinCandidateCatalogWireV3,
        catalogData: Data,
        experiment: PrimeLatinExperimentManifestWireV3
    ) throws {
        try requireSupportedSource(catalog.llmSource)
        try requireSupportedSource(experiment.llmSource)
        guard catalog.llmSource == experiment.llmSource else {
            throw PrimeLatinProposalInputsV3Error.invalidSemantics(
                "llm_source_cross_binding")
        }

        try validateCatalogEnvelope(catalog)
        try validateTokenizer(catalog.tokenizerProposalBinding)
        try validateCandidateSet(
            catalog.candidateDeclarations,
            catalog: catalog)

        let declarationSetData = try canonicalData(
            catalog.candidateDeclarations,
            context: "candidate_declaration_set_v3")
        guard !declarationSetData.isEmpty,
              declarationSetData.count <= maximumCanonicalDocumentBytes,
              catalog.candidateDeclarationSetSHA256
                == PrimeLatinSHA256.hexDigest(of: declarationSetData),
              catalog.candidateDeclarationSetByteCount
                == UInt64(declarationSetData.count)
        else {
            throw PrimeLatinProposalInputsV3Error.invalidSemantics(
                "candidate_declaration_set_hash_chain")
        }

        try validateExperiment(
            experiment,
            catalog: catalog,
            catalogData: catalogData)
        try validateBindingConsistency(catalog: catalog, experiment: experiment)
    }

    static func validateCatalogEnvelope(
        _ catalog: PrimeLatinCandidateCatalogWireV3
    ) throws {
        guard catalog.schema == "ergentics_latin_candidate_catalog_v3",
              catalog.laneID == laneID,
              catalog.ergenticsMLXLocation == ergenticsMLXLocation,
              catalog.ergenticsMLXRevision == ergenticsMLXRevision,
              catalog.quarantinePolicyID == quarantinePolicyID,
              catalog.declarationTargetSourceClosureStatus == "established",
              catalog.declarationTargetDependencyClosureStatus == "exact_zero",
              catalog.runtimeDecoderImplementationStatus == "absent",
              catalog.runtimeCandidateDependencyClosureStatus
                == "not_established",
              catalog.initializationStatus
                == "contract_bound_runtime_initialization_not_established",
              catalog.parameterCountStatus
                == "declarative_recomputed_not_runtime_reconciled",
              catalog.completenessStatus
                == "candidate_declaration_bound_decoder_absent_runtime_initialization_and_runtime_dependency_closure_not_established_by_bridge",
              catalog.primeConsumerStatus == "not_implemented_v3",
              catalog.publicationStatus
                == "not_implemented_input_bridge_only",
              catalog.authorityStatus
                == "root_bound_declaration_proposal_input_v3_only_non_authorizing"
        else {
            throw PrimeLatinProposalInputsV3Error.invalidSemantics(
                "candidate_catalog_v3_status")
        }

        try requireExactBinding(
            catalog.packageManifest,
            scope: .ergenticsLLMRepository,
            path: "Package.swift",
            sha256:
                "ab460122d5f364046224c6445a20f3beb34e2831de94db1271bbafb59726c902",
            byteCount: 6_109,
            context: "root_package_manifest")
        try requireExactBinding(
            catalog.dependencyLock,
            scope: .ergenticsLLMRepository,
            path: "Package.resolved",
            sha256:
                "2847fb936ec74eef250b8439d778f0a1ea8d0c630bf09438587764a4b99c6530",
            byteCount: 645,
            context: "root_dependency_lock")
        try requireBinding(
            catalog.initializationContract,
            scope: .ergenticsMLXLab,
            context: "initialization_contract")

        let quarantine = catalog.proposalInputDependencyQuarantine
        guard quarantine.policyID == quarantinePolicyID,
              quarantine.packageManifest == catalog.packageManifest,
              quarantine.dependencyLock == catalog.dependencyLock,
              quarantine.candidateImplementationSources.isEmpty,
              quarantine.authorityTargetDependencyCount == 0,
              quarantine.lockfilePinScanComplete,
              quarantine.status == "producer_recomputed_pass"
        else {
            throw PrimeLatinProposalInputsV3Error.invalidSemantics(
                "proposal_input_dependency_quarantine")
        }
    }

    static func validateTokenizer(
        _ proposal: PrimeLatinTokenizerProposalBindingWireV2
    ) throws {
        guard proposal.schema
                == "ergentics_latin_tokenizer_proposal_binding_v2",
              proposal.bindingScope
                == "full_admitted_tokenizer_bundle_eight_live_inputs",
              proposal.liveRevalidationPolicy
                == "proposal_workspace_descriptor_safe_revalidation_required",
              proposal.publicationStatus
                == "not_implemented_input_bridge_only",
              proposal.authorityStatus
                == "tokenizer_proposal_input_only_non_authorizing"
        else {
            throw PrimeLatinProposalInputsV3Error.invalidSemantics(
                "tokenizer_proposal_binding_v2")
        }

        let bundle = proposal.tokenizerBundle
        guard bundle.schema == "ergentics_latin_tokenizer_bundle_v2",
              bundle.tokenizerID == "ergentics_latin_bpe_v2",
              bundle.bindingScope
                == "direct_tokenizer_bundle_and_declared_corpus_manifest",
              bundle.recommendationApprovalAttributionAssurance
                == "trusted_local_declaration",
              !bundle.cryptographicHumanAuthentication,
              bundle.corpusProvenanceScope
                == "manifest_declarations_bound_only_admitted_train_bytes_observed",
              bundle.modelSemanticValidation
                == "opaque_bytes_hash_and_count_only",
              bundle.sentencePieceToolDisposition
                == "third_party_tool_and_format_recorded_provenance_not_independently_replayed",
              bundle.sentencePieceTrainerValidation
                == "recorded_declaration_only_binary_not_observed",
              bundle.trainingReplayStatus == "not_performed",
              bundle.snapshotConsistency
                == "cooperative_descriptor_reads_revalidated_not_atomic",
              bundle.authorityStatus
                == "root_bound_tokenizer_input_only_non_authorizing",
              tokenizerAuthorityIsAbsent(bundle.authority)
        else {
            throw PrimeLatinProposalInputsV3Error.invalidSemantics(
                "tokenizer_bundle_v2")
        }

        let roleBindings = [
            bundle.tokenizerManifest,
            bundle.sentencePieceModel,
            bundle.vocabulary,
            bundle.recommendation,
            bundle.approval,
            bundle.stagedTrainingInput,
            bundle.corpusManifest,
        ] + bundle.manifestListedCorpusInputs
        let expected: [(String, String, String, UInt64)] = [
            (
                "tokenizer_manifest",
                "tokenizer/ergentics_latin_bpe_v2/manifest.json",
                "b1ae203307de9c657f9d2558875e104d33f62e464c2cb83504d2f2f714ac6b76",
                2_180),
            (
                "sentencepiece_model",
                "tokenizer/ergentics_latin_bpe_v2/model.spm",
                "3819dbc5381bfd5f52cc8b28e6f1e224ea5e30bdaaaf94dc5307fde91c9cccb5",
                285_705),
            (
                "vocabulary",
                "tokenizer/ergentics_latin_bpe_v2/vocab.txt",
                "fb7f86c49cca2b9115f55ff559ac76e8977110e1251a3a21baa9e7dc9132c3ce",
                256_196),
            (
                "recommendation",
                "tokenizer/ergentics_latin_bpe_v2/recommendation.json",
                "ce4c3be2e999057a102465593e2c87c4cd7424a7f633427c97c0790c20f34596",
                1_836),
            (
                "approval",
                "tokenizer/ergentics_latin_bpe_v2/approval.json",
                "34162b2625ba160f0cc3d38c8ec7ef2c8930b0b4376a19bfd9b0fff8c96d936b",
                277),
            (
                "staged_training_input",
                "tokenizer/ergentics_latin_bpe_v2/staging/train-input.txt",
                "7a4dbdfc9885d734e802d912c72ee904f957f856ec0e4827a9583a7b8d357e76",
                3_743_426),
            (
                "corpus_manifest",
                "corpus/la/L1/primary-corpus-manifest.json",
                "87a4dcdfbbd8a9ad3f297b320bc94012e98835f395d79b6e6d99e6ce410c36b4",
                1_715),
            (
                "admitted_corpus_input",
                "corpus/la/L1/train.txt",
                "7a4dbdfc9885d734e802d912c72ee904f957f856ec0e4827a9583a7b8d357e76",
                3_743_426),
        ]
        guard bundle.manifestListedCorpusInputs.count == 1,
              roleBindings.count == expected.count,
              Set(roleBindings.map(\.role)).count == roleBindings.count
        else {
            throw PrimeLatinProposalInputsV3Error.invalidSemantics(
                "tokenizer_role_inventory")
        }
        for (binding, expectedValue) in zip(roleBindings, expected) {
            guard binding.role == expectedValue.0 else {
                throw PrimeLatinProposalInputsV3Error.invalidSemantics(
                    "tokenizer_role_order")
            }
            try requireExactBinding(
                binding.artifact,
                scope: .ergenticsMLXLab,
                path: expectedValue.1,
                sha256: expectedValue.2,
                byteCount: expectedValue.3,
                context: "tokenizer_role_\(binding.role)")
        }

        let bundleData = try canonicalData(
            bundle,
            context: "tokenizer_bundle_v2")
        guard bundleData.count == tokenizerBundleByteCount,
              PrimeLatinSHA256.hexDigest(of: bundleData)
                == tokenizerBundleSHA256,
              proposal.tokenizerBundleSHA256 == tokenizerBundleSHA256,
              proposal.tokenizerBundleByteCount == tokenizerBundleByteCount
        else {
            throw PrimeLatinProposalInputsV3Error.invalidSemantics(
                "tokenizer_bundle_hash_chain")
        }
    }

    static func validateCandidateSet(
        _ declarationSet: PrimeLatinCandidateDeclarationSetWireV3,
        catalog: PrimeLatinCandidateCatalogWireV3
    ) throws {
        let candidates = declarationSet.candidates
        let candidateIDs = candidates.map(\.candidateID)
        let identityHashes = candidates.map(\.candidateIdentitySHA256)
        let bundleHashes = candidates.map(\.declarationBundleSHA256)
        guard declarationSet.schema
                == "ergentics_latin_candidate_declaration_set_v3",
              declarationSet.laneID == laneID,
              !candidates.isEmpty,
              candidates.count <= 64,
              candidateIDs == candidateIDs.sorted(),
              Set(candidateIDs).count == candidateIDs.count,
              Set(identityHashes).count == identityHashes.count,
              Set(bundleHashes).count == bundleHashes.count
        else {
            throw PrimeLatinProposalInputsV3Error.invalidSemantics(
                "candidate_declaration_set_v3")
        }
        for candidate in candidates {
            try requireLatinIdentifier(candidate.candidateID)
            try requireIdentifier(candidate.sourceAttribution)
            try requireSHA256(candidate.candidateIdentitySHA256)
            try requireSHA256(candidate.declarationBundleSHA256)
            guard candidate.attributionAssurance
                    == "trusted_local_declaration",
                  !candidate.cryptographicHumanAuthentication,
                  candidate.declarationBundleByteCount > 0,
                  candidate.declarationBundleByteCount
                    <= UInt64(maximumCanonicalDocumentBytes)
            else {
                throw PrimeLatinProposalInputsV3Error.invalidSemantics(
                    "candidate_declaration_binding_v3")
            }
            let bundleData = try canonicalData(
                candidate.declarationBundle,
                context: "candidate_declaration_bundle_v1")
            guard candidate.declarationBundleSHA256
                    == PrimeLatinSHA256.hexDigest(of: bundleData),
                  candidate.declarationBundleByteCount
                    == UInt64(bundleData.count),
                  candidate.candidateIdentitySHA256
                    == candidate.declarationBundle.candidateIdentitySHA256,
                  candidate.candidateID
                    == candidate.declarationBundle.architecture.candidateSlug,
                  candidate.sourceAttribution
                    == candidate.declarationBundle.architecture.sourceAttribution
            else {
                throw PrimeLatinProposalInputsV3Error.invalidSemantics(
                    "candidate_declaration_binding_hash_chain")
            }
        }

        // General set ordering and uniqueness are checked before the currently
        // admitted structural fixture is narrowed to its exact single member.
        guard candidates.count == 1,
              candidates[0].candidateID == candidateID,
              candidates[0].sourceAttribution == sourceAttribution
        else {
            throw PrimeLatinProposalInputsV3Error.invalidSemantics(
                "unsupported_candidate_declaration_set")
        }
        try validateCandidateBundle(
            candidates[0].declarationBundle,
            catalog: catalog)
    }

    static func validateCandidateBundle(
        _ bundle: PrimeLatinCandidateDeclarationBundleWireV1,
        catalog: PrimeLatinCandidateCatalogWireV3
    ) throws {
        try requireSupportedSource(bundle.llmSource)
        guard bundle.schema
                == "ergentics_latin_candidate_declaration_input_bundle_v1",
              bundle.laneID == laneID,
              bundle.llmSource == catalog.llmSource,
              bundle.tokenizerProposalBinding
                == catalog.tokenizerProposalBinding,
              bundle.declarationTargetSourceClosure == "established",
              bundle.declarationTargetDependencyClosure == "exact_zero",
              bundle.parameterCountStatus
                == "declarative_recomputed_not_runtime_reconciled",
              bundle.runtimeDecoderImplementation == "absent",
              bundle.runtimeDependencyClosure == "not_established",
              bundle.initializationStatus == "not_established",
              bundle.publicationStatus == "not_implemented_encode_only",
              candidateAuthorityIsAbsent(bundle.authority)
        else {
            throw PrimeLatinProposalInputsV3Error.invalidSemantics(
                "candidate_declaration_bundle_v1_status")
        }

        try requireExactCommittedBinding(
            bundle.nestedPackageManifest,
            path: "Research/Latin/CandidateDeclarations/Package.swift",
            sha256:
                "9d5242248391613382c9c42bb388b1ad1d1597956f272e5d5b410b7891b38b63",
            byteCount: 892,
            gitBlobOID: "67907b47cf941c6e36154dd729b284f64c90ca9b",
            context: "candidate_nested_package_manifest")
        guard bundle.productionSources.count == 1 else {
            throw PrimeLatinProposalInputsV3Error.invalidSemantics(
                "candidate_production_source_inventory")
        }
        try requireExactCommittedBinding(
            bundle.productionSources[0],
            path:
                "Research/Latin/CandidateDeclarations/Sources/" +
                "ErgenticsLatinCandidateDeclarations/" +
                "ErgenticsLatinCandidateDeclarations.swift",
            sha256:
                "676443927b5024c6e58caa562777a27945dad384c6cc88b5d94d11e73c047bc4",
            byteCount: 35_119,
            gitBlobOID: "a951d3710dba072aa7eb8554c60abafdd032cb7f",
            context: "candidate_production_source")
        try requireExactCommittedBinding(
            bundle.architectureArtifact,
            path:
                "Research/Latin/candidates/latin_structural_fixture_v1/" +
                "architecture.json",
            sha256:
                "4b31feeeba780bc39c064d4540f5701935f960e1e1d8c82c81d295a65e643a70",
            byteCount: 2_794,
            gitBlobOID: "a3a9582003bfdbce2c94707313c0e402955bca9b",
            context: "candidate_architecture_artifact")
        try requireExactCommittedBinding(
            bundle.parameterCountDerivationArtifact,
            path:
                "Research/Latin/candidates/latin_structural_fixture_v1/" +
                "parameter-count-derivation.json",
            sha256:
                "45d15481883cf606e8e739aa71815bf9bd2fdd51494059328e3ba16a9ed5fb8f",
            byteCount: 2_702,
            gitBlobOID: "9957d0b17edd019ce760fdae9907a8ebadf408e3",
            context: "candidate_parameter_derivation_artifact")

        try validateDeclarationTargetClosure(
            bundle.declarationTargetClosure,
            nestedPackageManifest: bundle.nestedPackageManifest,
            productionSources: bundle.productionSources,
            catalogDependencyLock: catalog.dependencyLock)
        try validateArchitectureAndParameterCount(bundle)

        let closureData = try canonicalData(
            bundle.declarationTargetClosure,
            context: "candidate_declaration_target_closure_v1")
        let identity = bundle.identityMaterial
        guard identity.schema
                == "ergentics_latin_candidate_identity_material_domain_v1",
              identity.laneID == laneID,
              identity.llmSource == bundle.llmSource,
              identity.candidateSlug == bundle.architecture.candidateSlug,
              identity.sourceAttribution
                == bundle.architecture.sourceAttribution,
              identity.tokenizerID == bundle.architecture.tokenizer.tokenizerID,
              identity.tokenizerBundleSHA256
                == bundle.architecture.tokenizer.proposalBundleSHA256,
              identity.tokenizerBundleByteCount
                == bundle.architecture.tokenizer.proposalBundleByteCount,
              identity.tokenizerVocabularySize
                == bundle.architecture.tokenizer.vocabularySize,
              identity.architectureSHA256
                == bundle.architectureArtifact.artifact.sha256,
              identity.architectureByteCount
                == bundle.architectureArtifact.artifact.byteCount,
              identity.parameterCountDerivationSHA256
                == bundle.parameterCountDerivationArtifact.artifact.sha256,
              identity.parameterCountDerivationByteCount
                == bundle.parameterCountDerivationArtifact.artifact.byteCount,
              identity.declarationTargetClosureSHA256
                == PrimeLatinSHA256.hexDigest(of: closureData),
              identity.declarationTargetClosureByteCount
                == UInt64(closureData.count)
        else {
            throw PrimeLatinProposalInputsV3Error.invalidSemantics(
                "candidate_identity_material_v1")
        }
        let identityData = try canonicalData(
            identity,
            context: "candidate_identity_material_v1")
        guard bundle.candidateIdentitySHA256
                == PrimeLatinSHA256.hexDigest(of: identityData)
        else {
            throw PrimeLatinProposalInputsV3Error.invalidSemantics(
                "candidate_identity_hash")
        }
    }

    static func validateDeclarationTargetClosure(
        _ closure: PrimeLatinDeclarationTargetClosureWireV1,
        nestedPackageManifest: PrimeLatinCommittedArtifactBindingWire,
        productionSources: [PrimeLatinCommittedArtifactBindingWire],
        catalogDependencyLock: PrimeLatinArtifactBindingWire
    ) throws {
        guard closure.schema
                == "ergentics_latin_declaration_target_closure_v1",
              closure.scope == "nested_declaration_target_only_not_runtime",
              closure.targetName == "ErgenticsLatinCandidateDeclarations",
              closure.nestedPackageManifest == nestedPackageManifest,
              closure.productionSources == productionSources,
              closure.directTargetDependencies.isEmpty,
              closure.reachableLocalTargets
                == ["ErgenticsLatinCandidateDeclarations"],
              closure.reachableExternalProducts.isEmpty,
              closure.reachablePackagePins.isEmpty,
              closure.pathDependencyCount == 0,
              closure.binaryTargetCount == 0,
              closure.systemLibraryTargetCount == 0,
              closure.pluginCount == 0,
              closure.macroCount == 0,
              closure.unsafeFlagCount == 0,
              closure.nestedPackageLockStatus == "absent_required",
              closure.declarationTargetSourceClosure == "established",
              closure.declarationTargetDependencyClosure == "exact_zero",
              closure.rootPackageLock.artifact == catalogDependencyLock
        else {
            throw PrimeLatinProposalInputsV3Error.invalidSemantics(
                "candidate_declaration_target_closure_v1")
        }
        try requireExactCommittedBinding(
            closure.rootPackageLock,
            path: "Package.resolved",
            sha256:
                "2847fb936ec74eef250b8439d778f0a1ea8d0c630bf09438587764a4b99c6530",
            byteCount: 645,
            gitBlobOID: "4e822bfadbe5f4dced15a277f4d5423a03d76890",
            context: "candidate_root_package_lock")

        guard closure.unreachableRootPackagePins.count == 2 else {
            throw PrimeLatinProposalInputsV3Error.invalidSemantics(
                "candidate_unreachable_root_pins")
        }
        let first = closure.unreachableRootPackagePins[0]
        let second = closure.unreachableRootPackagePins[1]
        guard first.identity == "ergentics-mlx-swift",
              first.kind == "remoteSourceControl",
              first.location == ergenticsMLXLocation,
              first.revision == ergenticsMLXRevision,
              first.version == nil,
              !first.reachableFromDeclarationTarget,
              second.identity == "swift-numerics",
              second.kind == "remoteSourceControl",
              second.location == "https://github.com/apple/swift-numerics",
              second.revision
                == "0c0290ff6b24942dadb83a929ffaaa1481df04a2",
              second.version == "1.1.1",
              !second.reachableFromDeclarationTarget
        else {
            throw PrimeLatinProposalInputsV3Error.invalidSemantics(
                "candidate_unreachable_root_pins")
        }
    }

    static func validateArchitectureAndParameterCount(
        _ bundle: PrimeLatinCandidateDeclarationBundleWireV1
    ) throws {
        let architecture = bundle.architecture
        let tokenizer = architecture.tokenizer
        let geometry = architecture.geometry
        let policies = architecture.policies
        guard architecture.schema
                == "ergentics_latin_candidate_architecture_v1",
              architecture.candidateSlug == candidateID,
              architecture.fixtureOnly,
              architecture.sourceAttribution == sourceAttribution,
              !architecture.cryptographicHumanAuthentication,
              candidateAuthorityIsAbsent(architecture.authorityBoundary),
              tokenizer.tokenizerID == "ergentics_latin_bpe_v2",
              tokenizer.proposalBundleSHA256 == tokenizerBundleSHA256,
              tokenizer.proposalBundleByteCount == tokenizerBundleByteCount,
              tokenizer.vocabularySize == 16_384,
              tokenizer.unknownTokenID == 0,
              tokenizer.beginningOfSequenceTokenID == 1,
              tokenizer.endOfSequenceTokenID == 2,
              tokenizer.paddingTokenID == 3,
              geometry.maximumSequenceLength == 16,
              geometry.modelWidth == 8,
              geometry.layerCount == 1,
              geometry.attentionHeadCount == 2,
              geometry.attentionHeadWidth == 4,
              geometry.intermediateWidth == 16,
              policies.attention.mechanism
                == "multi_head_self_attention",
              policies.attention.causalMaskPolicy == "required",
              policies.attention.biasPolicy == "none",
              policies.feedForward.mechanism == "gated_mlp",
              policies.feedForward.activation == "silu",
              policies.feedForward.gatingPolicy == "multiplicative_gate",
              policies.feedForward.biasPolicy == "none",
              policies.normalization.placement == "pre_norm",
              policies.normalization.mechanism == "rms_norm",
              policies.normalization.parameterPolicy == "learned_scale_only",
              policies.normalization.epsilon.numerator == 1,
              policies.normalization.epsilon.denominator == 100_000,
              policies.position == "rotary_no_learned_parameters",
              policies.projection
                == "token_embedding_tied_output_projection"
        else {
            throw PrimeLatinProposalInputsV3Error.invalidSemantics(
                "candidate_architecture_v1")
        }

        let expectedTensors: [(String, String, [UInt64])] = [
            (
                "token_embedding_weight",
                "token_embedding_and_output_projection",
                [16_384, 8]),
            (
                "layer_0_attention_norm_scale",
                "layer_0_attention_norm_scale",
                [8]),
            (
                "layer_0_attention_query_weight",
                "layer_0_attention_query_weight",
                [8, 8]),
            (
                "layer_0_attention_key_weight",
                "layer_0_attention_key_weight",
                [8, 8]),
            (
                "layer_0_attention_value_weight",
                "layer_0_attention_value_weight",
                [8, 8]),
            (
                "layer_0_attention_output_weight",
                "layer_0_attention_output_weight",
                [8, 8]),
            (
                "layer_0_feed_forward_norm_scale",
                "layer_0_feed_forward_norm_scale",
                [8]),
            (
                "layer_0_feed_forward_gate_weight",
                "layer_0_feed_forward_gate_weight",
                [16, 8]),
            (
                "layer_0_feed_forward_up_weight",
                "layer_0_feed_forward_up_weight",
                [16, 8]),
            (
                "layer_0_feed_forward_down_weight",
                "layer_0_feed_forward_down_weight",
                [8, 16]),
            ("final_norm_scale", "final_norm_scale", [8]),
            (
                "output_projection_weight",
                "token_embedding_and_output_projection",
                [16_384, 8]),
        ]
        guard architecture.orderedTensors.count == expectedTensors.count else {
            throw PrimeLatinProposalInputsV3Error.invalidSemantics(
                "candidate_tensor_inventory")
        }

        var seenStorage = Set<String>()
        var expectedUniqueCount: UInt64 = 0
        var expectedTotal: UInt64 = 0
        var expectedTermCounts = [UInt64]()
        var expectedUniqueFlags = [Bool]()
        for (tensor, expected) in zip(
            architecture.orderedTensors,
            expectedTensors
        ) {
            guard tensor.role == expected.0,
                  tensor.storageID == expected.1,
                  tensor.dimensions == expected.2
            else {
                throw PrimeLatinProposalInputsV3Error.invalidSemantics(
                    "candidate_tensor_shape")
            }
            let elementCount = try product(
                tensor.dimensions,
                context: "candidate_tensor_element_count")
            let isUnique = seenStorage.insert(tensor.storageID).inserted
            if isUnique {
                let nextCount = expectedUniqueCount.addingReportingOverflow(1)
                let nextTotal = expectedTotal.addingReportingOverflow(
                    elementCount)
                guard !nextCount.overflow, !nextTotal.overflow else {
                    throw PrimeLatinProposalInputsV3Error.invalidSemantics(
                        "candidate_parameter_overflow")
                }
                expectedUniqueCount = nextCount.partialValue
                expectedTotal = nextTotal.partialValue
            }
            expectedTermCounts.append(elementCount)
            expectedUniqueFlags.append(isUnique)
        }

        let derivation = bundle.parameterCountDerivation
        guard derivation.schema
                == "ergentics_latin_parameter_count_derivation_v1",
              derivation.architectureSchema == architecture.schema,
              derivation.candidateSlug == architecture.candidateSlug,
              derivation.fixtureOnly,
              derivation.sourceAttribution == architecture.sourceAttribution,
              !derivation.cryptographicHumanAuthentication,
              derivation.status
                == "declarative_recomputed_not_runtime_reconciled",
              derivation.orderedTerms.count
                == architecture.orderedTensors.count,
              derivation.uniqueStorageCount == expectedUniqueCount,
              derivation.totalParameterCount == expectedTotal,
              expectedUniqueCount == 11,
              expectedTotal == 131_736,
              candidateAuthorityIsAbsent(derivation.authorityBoundary)
        else {
            throw PrimeLatinProposalInputsV3Error.invalidSemantics(
                "candidate_parameter_derivation_v1")
        }
        for index in derivation.orderedTerms.indices {
            let term = derivation.orderedTerms[index]
            let tensor = architecture.orderedTensors[index]
            guard term.role == tensor.role,
                  term.storageID == tensor.storageID,
                  term.dimensions == tensor.dimensions,
                  term.elementCount == expectedTermCounts[index],
                  term.countedAsUniqueStorage == expectedUniqueFlags[index]
            else {
                throw PrimeLatinProposalInputsV3Error.invalidSemantics(
                    "candidate_parameter_term")
            }
        }

        let architectureData = try canonicalLineData(
            architecture,
            context: "candidate_architecture_v1")
        let derivationData = try canonicalLineData(
            derivation,
            context: "candidate_parameter_derivation_v1")
        guard PrimeLatinSHA256.hexDigest(of: architectureData)
                == bundle.architectureArtifact.artifact.sha256,
              UInt64(architectureData.count)
                == bundle.architectureArtifact.artifact.byteCount,
              PrimeLatinSHA256.hexDigest(of: derivationData)
                == bundle.parameterCountDerivationArtifact.artifact.sha256,
              UInt64(derivationData.count)
                == bundle.parameterCountDerivationArtifact.artifact.byteCount
        else {
            throw PrimeLatinProposalInputsV3Error.invalidSemantics(
                "candidate_declaration_canonical_line_hash")
        }
    }

    static func validateExperiment(
        _ experiment: PrimeLatinExperimentManifestWireV3,
        catalog: PrimeLatinCandidateCatalogWireV3,
        catalogData: Data
    ) throws {
        let candidateIDs = catalog.candidateDeclarations.candidates.map(
            \.candidateID)
        guard experiment.schema
                == "ergentics_latin_experiment_manifest_v3",
              experiment.laneID == laneID,
              experiment.llmSource == catalog.llmSource,
              experiment.candidateCatalogSHA256
                == PrimeLatinSHA256.hexDigest(of: catalogData),
              experiment.candidateCatalogByteCount
                == UInt64(catalogData.count),
              experiment.candidateDeclarationSetSHA256
                == catalog.candidateDeclarationSetSHA256,
              experiment.candidateDeclarationSetByteCount
                == catalog.candidateDeclarationSetByteCount,
              experiment.candidateIDs == candidateIDs,
              experiment.dependencyLock == catalog.dependencyLock,
              experiment.tokenizerBundleSHA256
                == catalog.tokenizerProposalBinding.tokenizerBundleSHA256,
              experiment.tokenizerBundleByteCount
                == catalog.tokenizerProposalBinding.tokenizerBundleByteCount,
              experiment.initializationContract
                == catalog.initializationContract,
              experiment.outputDisposition
                == "must_be_absent_create_once_non_restorable",
              experiment.completenessStatus
                == "evaluator_and_prospective_data_completeness_not_established_by_bridge",
              experiment.primeConsumerStatus == "not_implemented_v3",
              experiment.publicationStatus
                == "not_implemented_input_bridge_only",
              experimentAuthorityIsAbsent(experiment.authority)
        else {
            throw PrimeLatinProposalInputsV3Error.invalidSemantics(
                "experiment_manifest_v3_cross_binding")
        }

        try requireBinding(
            experiment.corpusManifest,
            scope: .ergenticsMLXLab,
            context: "experiment_corpus_manifest")
        try requireBinding(
            experiment.evaluationContract,
            scope: .ergenticsLLMRepository,
            context: "experiment_evaluation_contract")
        if isFinalHandoffSource(experiment.llmSource) {
            try requireExactBinding(
                experiment.evaluationContract,
                scope: .ergenticsLLMRepository,
                path: finalEvaluationContractPath,
                sha256: finalEvaluationContractSHA256,
                byteCount: finalEvaluationContractByteCount,
                context: "final_handoff_evaluation_contract")
        }
        for (binding, context) in [
            (experiment.splits.trainingSplit, "training_split"),
            (experiment.splits.validationSplit, "validation_split"),
            (experiment.splits.selectionSplit, "selection_split"),
            (
                experiment.splits.selectionObservationDeclaration,
                "selection_observation_declaration"),
        ] {
            try requireBinding(
                binding,
                scope: .ergenticsMLXLab,
                context: context)
        }

        let splitIDs = [
            experiment.splits.trainingSplitID,
            experiment.splits.validationSplitID,
            experiment.splits.selectionSplitID,
        ]
        for splitID in splitIDs {
            try requireLatinIdentifier(splitID)
        }
        guard Set(splitIDs).count == splitIDs.count,
              !experiment.splits.selectionSplitID.lowercased().contains(
                "holdout"),
              !experiment.splits.selectionSplitID.lowercased().contains(
                "primary_v1"),
              experiment.splits.selectionDataStatus
                == "trusted_local_declared_unverified"
        else {
            throw PrimeLatinProposalInputsV3Error.invalidSemantics(
                "experiment_split_set")
        }

        let budget = experiment.requestedTrialBudget
        guard budget.application
                == "identical_per_candidate_requested_ceiling",
              budget.optimizerSteps > 0,
              budget.trainingTokens > 0,
              budget.wallClockSeconds > 0
        else {
            throw PrimeLatinProposalInputsV3Error.invalidSemantics(
                "requested_trial_budget")
        }
        try requireRelativePath(experiment.outputNamespace)
        guard experiment.outputNamespace.hasPrefix(
                "models/latin-prospective/"),
              !experiment.outputNamespace.lowercased().contains(
                "ergentics_latin_primary_v1")
        else {
            throw PrimeLatinProposalInputsV3Error.invalidSemantics(
                "output_namespace")
        }
    }

    static func validateBindingConsistency(
        catalog: PrimeLatinCandidateCatalogWireV3,
        experiment: PrimeLatinExperimentManifestWireV3
    ) throws {
        let tokenizer = catalog.tokenizerProposalBinding.tokenizerBundle
        var bindings = [
            catalog.packageManifest,
            catalog.dependencyLock,
            catalog.initializationContract,
            tokenizer.tokenizerManifest.artifact,
            tokenizer.sentencePieceModel.artifact,
            tokenizer.vocabulary.artifact,
            tokenizer.recommendation.artifact,
            tokenizer.approval.artifact,
            tokenizer.stagedTrainingInput.artifact,
            tokenizer.corpusManifest.artifact,
        ] + tokenizer.manifestListedCorpusInputs.map(\.artifact) + [
            experiment.dependencyLock,
            experiment.initializationContract,
            experiment.corpusManifest,
            experiment.evaluationContract,
            experiment.splits.trainingSplit,
            experiment.splits.validationSplit,
            experiment.splits.selectionSplit,
            experiment.splits.selectionObservationDeclaration,
        ]
        for candidate in catalog.candidateDeclarations.candidates {
            let bundle = candidate.declarationBundle
            bindings.append(bundle.nestedPackageManifest.artifact)
            bindings.append(contentsOf: bundle.productionSources.map(\.artifact))
            bindings.append(bundle.architectureArtifact.artifact)
            bindings.append(bundle.parameterCountDerivationArtifact.artifact)
            bindings.append(bundle.declarationTargetClosure.rootPackageLock.artifact)
        }

        var identityByLocation =
            [String: (sha256: String, byteCount: UInt64)]()
        var byteCountBySHA256 = [String: UInt64]()
        for binding in bindings {
            try requireBinding(binding, scope: binding.scope, context: "binding")
            if binding.scope == .ergenticsMLXLab,
               pathsOverlap(binding.relativePath, experiment.outputNamespace) {
                throw PrimeLatinProposalInputsV3Error.invalidSemantics(
                    "input_output_path_overlap")
            }
            let location = binding.scope.rawValue + "\u{0}"
                + binding.relativePath.lowercased()
            if let existing = identityByLocation[location],
               existing.sha256 != binding.sha256
                || existing.byteCount != binding.byteCount {
                throw PrimeLatinProposalInputsV3Error.invalidSemantics(
                    "inconsistent_artifact_location")
            }
            identityByLocation[location] = (
                binding.sha256,
                binding.byteCount)
            if let existing = byteCountBySHA256[binding.sha256],
               existing != binding.byteCount {
                throw PrimeLatinProposalInputsV3Error.invalidSemantics(
                    "inconsistent_artifact_hash")
            }
            byteCountBySHA256[binding.sha256] = binding.byteCount
        }

        let strictExperimentRoles = [
            catalog.initializationContract,
            experiment.corpusManifest,
            experiment.evaluationContract,
            experiment.splits.trainingSplit,
            experiment.splits.validationSplit,
            experiment.splits.selectionSplit,
            experiment.splits.selectionObservationDeclaration,
        ]
        let strictLocations = strictExperimentRoles.map {
            $0.scope.rawValue + "\u{0}" + $0.relativePath.lowercased()
        }
        guard Set(strictLocations).count == strictLocations.count,
              Set(strictExperimentRoles.map(\.sha256)).count
                == strictExperimentRoles.count
        else {
            throw PrimeLatinProposalInputsV3Error.invalidSemantics(
                "aliased_experiment_artifact_roles")
        }
    }

    static func requireSupportedSource(
        _ source: PrimeLatinGitSourceWire
    ) throws {
        guard isGitOID(source.commit), isGitOID(source.tree) else {
            throw PrimeLatinProposalInputsV3Error.invalidSemantics(
                "llm_source_oid")
        }
        let isSupportedSource =
            (source.commit == mergedCommit && source.tree == mergedTree)
            || (source.commit == mergedPublisherCommit
                && source.tree == mergedPublisherTree)
            || isFinalHandoffSource(source)
        guard source.repository == repository, isSupportedSource else {
            throw PrimeLatinProposalInputsV3Error.unsupportedSource(
                "llm_source")
        }
    }

    static func isFinalHandoffSource(
        _ source: PrimeLatinGitSourceWire
    ) -> Bool {
        source.commit == finalHandoffCommit && source.tree == finalHandoffTree
    }

    static func requireExactCommittedBinding(
        _ binding: PrimeLatinCommittedArtifactBindingWire,
        path: String,
        sha256: String,
        byteCount: UInt64,
        gitBlobOID: String,
        context: String
    ) throws {
        try requireExactBinding(
            binding.artifact,
            scope: .ergenticsLLMRepository,
            path: path,
            sha256: sha256,
            byteCount: byteCount,
            context: context)
        guard isGitOID(binding.gitBlobOID),
              binding.gitBlobOID == gitBlobOID
        else {
            throw PrimeLatinProposalInputsV3Error.invalidSemantics(
                context + "_git_blob")
        }
    }

    static func requireExactBinding(
        _ binding: PrimeLatinArtifactBindingWire,
        scope: PrimeLatinArtifactScopeWire,
        path: String,
        sha256: String,
        byteCount: UInt64,
        context: String
    ) throws {
        try requireBinding(binding, scope: scope, context: context)
        guard binding.relativePath == path,
              binding.sha256 == sha256,
              binding.byteCount == byteCount
        else {
            throw PrimeLatinProposalInputsV3Error.invalidSemantics(context)
        }
    }

    static func requireBinding(
        _ binding: PrimeLatinArtifactBindingWire,
        scope: PrimeLatinArtifactScopeWire,
        context: String
    ) throws {
        guard binding.scope == scope,
              binding.byteCount > 0,
              binding.byteCount <= maximumArtifactByteCount
        else {
            throw PrimeLatinProposalInputsV3Error.invalidSemantics(context)
        }
        try requireRelativePath(binding.relativePath)
        try requireSHA256(binding.sha256)
    }

    static func requireSHA256(_ value: String) throws {
        guard value.utf8.count == 64,
              value.utf8.allSatisfy({
                  ($0 >= 48 && $0 <= 57) || ($0 >= 97 && $0 <= 102)
              })
        else {
            throw PrimeLatinProposalInputsV3Error.invalidSemantics("sha256")
        }
    }

    static func isGitOID(_ value: String) -> Bool {
        value.utf8.count == 40 && value.utf8.allSatisfy {
            ($0 >= 48 && $0 <= 57) || ($0 >= 97 && $0 <= 102)
        }
    }

    static func requireIdentifier(_ value: String) throws {
        guard !value.isEmpty,
              value.utf8.count <= 128,
              value.utf8.allSatisfy({
                  ($0 >= 97 && $0 <= 122)
                    || ($0 >= 48 && $0 <= 57)
                    || $0 == 45
                    || $0 == 46
                    || $0 == 95
              })
        else {
            throw PrimeLatinProposalInputsV3Error.invalidSemantics(
                "identifier")
        }
        try requireNoForbiddenContext(value)
    }

    static func requireLatinIdentifier(_ value: String) throws {
        try requireIdentifier(value)
        guard value.hasPrefix("latin_")
                || value.hasPrefix("ergentics_latin_")
        else {
            throw PrimeLatinProposalInputsV3Error.invalidSemantics(
                "latin_identifier")
        }
    }

    static func requireRelativePath(_ value: String) throws {
        guard !value.isEmpty,
              value.utf8.count <= 1_024,
              !value.hasPrefix("/"),
              !value.hasSuffix("/"),
              !value.contains("\\"),
              value.split(
                separator: "/",
                omittingEmptySubsequences: false
              ).allSatisfy({ component in
                  !component.isEmpty
                    && component != "."
                    && component != ".."
                    && component.utf8.allSatisfy({
                        ($0 >= 65 && $0 <= 90)
                            || ($0 >= 97 && $0 <= 122)
                            || ($0 >= 48 && $0 <= 57)
                            || $0 == 45
                            || $0 == 46
                            || $0 == 95
                    })
              })
        else {
            throw PrimeLatinProposalInputsV3Error.invalidSemantics(
                "relative_path")
        }
        try requireNoForbiddenContext(value)
    }

    static func requireNoForbiddenContext(_ value: String) throws {
        let normalized = value.lowercased()
        guard !forbiddenContext.contains(where: normalized.contains) else {
            throw PrimeLatinProposalInputsV3Error.invalidSemantics(
                "forbidden_dependency_context")
        }
    }

    static func product(
        _ dimensions: [UInt64],
        context: String
    ) throws -> UInt64 {
        guard !dimensions.isEmpty,
              dimensions.count <= 4,
              dimensions.allSatisfy({ $0 > 0 })
        else {
            throw PrimeLatinProposalInputsV3Error.invalidSemantics(context)
        }
        var result: UInt64 = 1
        for dimension in dimensions {
            let next = result.multipliedReportingOverflow(by: dimension)
            guard !next.overflow else {
                throw PrimeLatinProposalInputsV3Error.invalidSemantics(context)
            }
            result = next.partialValue
        }
        return result
    }

    static func pathsOverlap(_ first: String, _ second: String) -> Bool {
        let firstComponents = first.lowercased().split(separator: "/")
        let secondComponents = second.lowercased().split(separator: "/")
        let sharedCount = min(firstComponents.count, secondComponents.count)
        return firstComponents.prefix(sharedCount)
            == secondComponents.prefix(sharedCount)
    }

    static func tokenizerAuthorityIsAbsent(
        _ authority: PrimeLatinTokenizerNonAuthorityWireV2
    ) -> Bool {
        authority.primeProposalAuthority == "absent"
            && !authority.architectureAuthority
            && !authority.trialExecutionAuthority
            && !authority.trainingAuthority
            && !authority.promotionAuthority
            && !authority.productUseAuthority
    }

    static func candidateAuthorityIsAbsent(
        _ authority: PrimeLatinCandidateAuthorityWireV1
    ) -> Bool {
        authority.runtimeDecoderImplementation == "absent"
            && authority.runtimeDependencyClosure == "not_established"
            && authority.initialization == "not_established"
            && authority.primeProposal == "absent"
            && authority.primeDecisionReceipt == "absent"
            && !authority.primeAuthority
            && !authority.executionAuthority
            && !authority.trainingAuthority
            && !authority.promotionAuthority
            && !authority.productAuthority
            && !authority.publicationAuthority
    }

    static func experimentAuthorityIsAbsent(
        _ authority: PrimeLatinExperimentAuthorityWireV3
    ) -> Bool {
        authority.primeProposalPacket == "absent"
            && authority.primeTrialAuthorization == "absent"
            && authority.primeDecisionReceipt == "absent"
            && !authority.candidateSelectionAuthorized
            && !authority.trialExecutionAuthorized
            && !authority.furtherTrainingAuthorized
            && !authority.promotionAuthorized
            && !authority.productUseAuthorized
            && !authority.publicationAuthorized
    }
}
