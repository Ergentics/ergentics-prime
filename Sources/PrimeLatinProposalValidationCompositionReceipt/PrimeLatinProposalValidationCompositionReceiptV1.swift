import Foundation

public enum PrimeLatinProposalValidationCompositionReceiptErrorV1:
    Error,
    Equatable,
    Sendable
{
    case invalidReceipt(String)
}

package enum PrimeLatinProposalValidationCompositionReceiptContractV1 {
    package static let schema =
        "ergentics_prime_latin_proposal_v3_validation_composition_receipt_v1"
    package static let outcome = "abstain"
    package static let verificationScope =
        "durable_content_addressed_canonical_projection_of_one_exact_prime_" +
        "validation_composition_observation_only_raw_child_observations_" +
        "current_liveness_proposal_admission_runtime_trial_selection_" +
        "promotion_product_and_model_publication_authority_absent"
    package static let receiptPolicyID =
        "prime_latin_v3_validation_composition_content_addressed_receipt_v1"

    package static let sourceObservationSchema =
        "ergentics_prime_latin_proposal_v3_validation_composition_" +
        "observation_v1"
    package static let sourceObservationOutcome = "abstain"
    package static let sourceObservationVerificationScope =
        "prime_owned_cooperative_same_request_root_sequence_composing_one_" +
        "live_producer_revalidation_observation_and_one_independent_replay_" +
        "observation_with_exact_shared_identity_hash_count_budget_and_" +
        "output_namespace_cross_bindings_only_non_authorizing"
    package static let sourceCompositionPolicyID =
        "prime_latin_v3_producer_revalidation_independent_replay_" +
        "composition_v1"
    package static let sourceAuthorityDisposition =
        "abstain_live_producer_revalidation_and_independent_prime_replay_" +
        "composed_proposal_policy_runtime_decoder_initialization_" +
        "evaluation_trial_decision_and_publication_authority_absent"

    package static let sourceAuthorityTrueClaims = [
        "producerRevalidationCaptureAndRecaptureComplete",
        "independentReplayCaptureAndRecaptureComplete",
        "cooperativeSameRequestRootSequenceComplete",
        "producerRevalidationAuthorityBoundaryExact",
        "independentReplayAuthorityBoundaryExact",
        "exactPairReceiptCrossBindingMatched",
        "exactProducerSourceCrossBindingMatched",
        "exactCandidateCatalogCrossBindingMatched",
        "exactExperimentManifestCrossBindingMatched",
        "exactCandidateDeclarationSetCrossBindingMatched",
        "exactTokenizerBundleCrossBindingMatched",
        "exactCandidateIdentityInventoryCrossBindingMatched",
        "exactTwentyOneInputBindingCountCrossBindingMatched",
        "exactTwentyOneOriginalInputBytesRetained",
        "exactTrialBudgetCrossBindingMatched",
        "exactOutputNamespaceCrossBindingMatched",
        "outputNamespaceAbsenceVerified",
        "referencedInputSnapshotAvailable",
        "referencedArtifactBytesAvailable",
        "llmGitStateIndependentlyObserved",
        "revalidatorToolSourceIndependentlyObserved",
        "liveProducerWorkspaceRevalidationComplete",
        "independentPrimeReplayComplete",
        "validationCompositionComplete",
    ]

    package static let sourceAuthorityFalseClaims = [
        "atomicCrossProcessSnapshotEstablished",
        "compilerCryptographicallyAuthenticated",
        "externalSourceToBinaryAttestationAvailable",
        "originRemoteCryptographicallyAuthenticated",
        "ignoredWorkspaceBytesObserved",
        "declarationSourceSemanticsIndependentlyVerified",
        "tokenizerModelSemanticsIndependentlyValidated",
        "tokenizerTrainingReplayComplete",
        "evaluationExecutionComplete",
        "selectionObservationComplete",
        "durableInputSnapshotPublished",
        "durableGitObservationPublished",
        "durableProducerRevalidationObservationPublished",
        "durableIndependentReplayObservationPublished",
        "durableValidationCompositionObservationPublished",
        "runtimeDecoderImplementationAvailable",
        "runtimeDependencyClosureEstablished",
        "runtimeInitializationEstablished",
        "primeProposalPolicyEstablished",
        "primeProposalPacketProduced",
        "primeTrialAuthorizationProduced",
        "primeDecisionReceiptProduced",
        "candidateSelectionAuthorized",
        "trialExecutionAuthorized",
        "furtherTrainingAuthorized",
        "promotionAuthorized",
        "productUseAuthorized",
        "publicationAuthorized",
        "proposalPairPublicationPerformedByThisComposition",
        "primeDurableReceiptPublished",
    ]

    package static let receiptDirectory =
        "latin-validation-composition-receipts"

    package static func relativePath(
        forSHA256 sha256: String
    ) throws -> String {
        guard sha256.utf8.count == 64,
              sha256.utf8.allSatisfy({ byte in
                  (byte >= 48 && byte <= 57)
                      || (byte >= 97 && byte <= 102)
              }) else {
            throw PrimeLatinProposalValidationCompositionReceiptErrorV1
                .invalidReceipt("content_address_sha256")
        }
        return receiptDirectory + "/" + sha256 + ".json"
    }
}

package struct PrimeLatinProposalValidationCompositionReceiptProjectionV1:
    Equatable,
    Sendable
{
    package var schema: String
    package var outcome: String
    package var verificationScope: String
    package var receiptPolicyID: String
    package var sourceObservationSchema: String
    package var sourceObservationOutcome: String
    package var sourceObservationVerificationScope: String
    package var sourceCompositionPolicyID: String
    package var sourceAuthorityDisposition: String
    package var sourceAuthorityTrueClaims: [String]
    package var sourceAuthorityFalseClaims: [String]
    package var pairReceiptSHA256: String
    package var pairReceiptByteCount: UInt64
    package var producerRepository: String
    package var producerCommit: String
    package var producerTree: String
    package var candidateCatalogSHA256: String
    package var candidateCatalogByteCount: UInt64
    package var experimentManifestSHA256: String
    package var experimentManifestByteCount: UInt64
    package var candidateDeclarationSetSHA256: String
    package var candidateDeclarationSetByteCount: UInt64
    package var tokenizerBundleSHA256: String
    package var tokenizerBundleByteCount: UInt64
    package var candidateIDs: [String]
    package var candidateIdentitySHA256s: [String]
    package var declarationBundleSHA256s: [String]
    package var inputBindingCount: UInt64
    package var retainedOriginalInputByteCount: UInt64
    package var optimizerSteps: UInt64
    package var trainingTokens: UInt64
    package var wallClockSeconds: UInt64
    package var outputNamespace: String
    package var orderedTensorCount: UInt64
    package var uniqueParameterStorageCount: UInt64
    package var totalParameterCount: UInt64

    package init(
        schema: String,
        outcome: String,
        verificationScope: String,
        receiptPolicyID: String,
        sourceObservationSchema: String,
        sourceObservationOutcome: String,
        sourceObservationVerificationScope: String,
        sourceCompositionPolicyID: String,
        sourceAuthorityDisposition: String,
        sourceAuthorityTrueClaims: [String],
        sourceAuthorityFalseClaims: [String],
        pairReceiptSHA256: String,
        pairReceiptByteCount: UInt64,
        producerRepository: String,
        producerCommit: String,
        producerTree: String,
        candidateCatalogSHA256: String,
        candidateCatalogByteCount: UInt64,
        experimentManifestSHA256: String,
        experimentManifestByteCount: UInt64,
        candidateDeclarationSetSHA256: String,
        candidateDeclarationSetByteCount: UInt64,
        tokenizerBundleSHA256: String,
        tokenizerBundleByteCount: UInt64,
        candidateIDs: [String],
        candidateIdentitySHA256s: [String],
        declarationBundleSHA256s: [String],
        inputBindingCount: UInt64,
        retainedOriginalInputByteCount: UInt64,
        optimizerSteps: UInt64,
        trainingTokens: UInt64,
        wallClockSeconds: UInt64,
        outputNamespace: String,
        orderedTensorCount: UInt64,
        uniqueParameterStorageCount: UInt64,
        totalParameterCount: UInt64
    ) {
        self.schema = schema
        self.outcome = outcome
        self.verificationScope = verificationScope
        self.receiptPolicyID = receiptPolicyID
        self.sourceObservationSchema = sourceObservationSchema
        self.sourceObservationOutcome = sourceObservationOutcome
        self.sourceObservationVerificationScope =
            sourceObservationVerificationScope
        self.sourceCompositionPolicyID = sourceCompositionPolicyID
        self.sourceAuthorityDisposition = sourceAuthorityDisposition
        self.sourceAuthorityTrueClaims = sourceAuthorityTrueClaims
        self.sourceAuthorityFalseClaims = sourceAuthorityFalseClaims
        self.pairReceiptSHA256 = pairReceiptSHA256
        self.pairReceiptByteCount = pairReceiptByteCount
        self.producerRepository = producerRepository
        self.producerCommit = producerCommit
        self.producerTree = producerTree
        self.candidateCatalogSHA256 = candidateCatalogSHA256
        self.candidateCatalogByteCount = candidateCatalogByteCount
        self.experimentManifestSHA256 = experimentManifestSHA256
        self.experimentManifestByteCount = experimentManifestByteCount
        self.candidateDeclarationSetSHA256 = candidateDeclarationSetSHA256
        self.candidateDeclarationSetByteCount =
            candidateDeclarationSetByteCount
        self.tokenizerBundleSHA256 = tokenizerBundleSHA256
        self.tokenizerBundleByteCount = tokenizerBundleByteCount
        self.candidateIDs = candidateIDs
        self.candidateIdentitySHA256s = candidateIdentitySHA256s
        self.declarationBundleSHA256s = declarationBundleSHA256s
        self.inputBindingCount = inputBindingCount
        self.retainedOriginalInputByteCount = retainedOriginalInputByteCount
        self.optimizerSteps = optimizerSteps
        self.trainingTokens = trainingTokens
        self.wallClockSeconds = wallClockSeconds
        self.outputNamespace = outputNamespace
        self.orderedTensorCount = orderedTensorCount
        self.uniqueParameterStorageCount = uniqueParameterStorageCount
        self.totalParameterCount = totalParameterCount
    }

    package static var exactFinal: Self {
        let contract =
            PrimeLatinProposalValidationCompositionReceiptContractV1.self
        return Self(
            schema: contract.schema,
            outcome: contract.outcome,
            verificationScope: contract.verificationScope,
            receiptPolicyID: contract.receiptPolicyID,
            sourceObservationSchema: contract.sourceObservationSchema,
            sourceObservationOutcome: contract.sourceObservationOutcome,
            sourceObservationVerificationScope:
                contract.sourceObservationVerificationScope,
            sourceCompositionPolicyID: contract.sourceCompositionPolicyID,
            sourceAuthorityDisposition: contract.sourceAuthorityDisposition,
            sourceAuthorityTrueClaims: contract.sourceAuthorityTrueClaims,
            sourceAuthorityFalseClaims: contract.sourceAuthorityFalseClaims,
            pairReceiptSHA256:
                "6c47d6ff17d72e48873c9f4ae9ce0a0fe7e57dea8e25db144c5f1d8d42761ff7",
            pairReceiptByteCount: 1_833,
            producerRepository: "Ergentics/ergentics-llm",
            producerCommit:
                "776c412e3f10e8bf4e33cd0ae60787d9ca6b5831",
            producerTree:
                "c1f41758aea2860ab06039776f5ea0403dff1b61",
            candidateCatalogSHA256:
                "12387e11fdbf68ab5b76cad79c6c958e9b82ddeca1cb588b844918a2ab0dc6b4",
            candidateCatalogByteCount: 20_803,
            experimentManifestSHA256:
                "8436ab6d656b2393792c564d0bdb9a25d1ade9f5c457ad3b96cf99bacc708a76",
            experimentManifestByteCount: 3_364,
            candidateDeclarationSetSHA256:
                "45c787dba8c538794cbaf7cb90acb4528d2dedcaf666a1f0da151ca236138881",
            candidateDeclarationSetByteCount: 14_860,
            tokenizerBundleSHA256:
                "9fa3b6eea42a9c4c13ec1ecda2309ec4c35b3022638ae61a08dd2f0fcb9b074c",
            tokenizerBundleByteCount: 2_930,
            candidateIDs: ["latin_structural_fixture_v1"],
            candidateIdentitySHA256s: [
                "64a288b62cdef276923eb72e5cc4d209a7195526408414fc5167522151481265",
            ],
            declarationBundleSHA256s: [
                "6f07896e50b2b530ea5f5924859d1e66bf9880366c16cf37832138a0e6c7f4bd",
            ],
            inputBindingCount: 21,
            retainedOriginalInputByteCount: 8_084_712,
            optimizerSteps: 1,
            trainingTokens: 128,
            wallClockSeconds: 60,
            outputNamespace:
                "models/latin-prospective/structural-fixture-v3-776c412e",
            orderedTensorCount: 12,
            uniqueParameterStorageCount: 11,
            totalParameterCount: 131_736)
    }
}

public struct PrimeLatinProposalValidationCompositionReceiptV1:
    Codable,
    Equatable,
    Sendable
{
    public static let maximumByteCount: UInt64 = 65_536

    public let schema: String
    public let outcome: String
    public let verificationScope: String
    public let receiptPolicyID: String
    public let sourceObservationSchema: String
    public let sourceObservationOutcome: String
    public let sourceObservationVerificationScope: String
    public let sourceCompositionPolicyID: String
    public let sourceAuthorityDisposition: String
    public let sourceAuthorityTrueClaims: [String]
    public let sourceAuthorityFalseClaims: [String]
    public let pairReceiptSHA256: String
    public let pairReceiptByteCount: UInt64
    public let producerRepository: String
    public let producerCommit: String
    public let producerTree: String
    public let candidateCatalogSHA256: String
    public let candidateCatalogByteCount: UInt64
    public let experimentManifestSHA256: String
    public let experimentManifestByteCount: UInt64
    public let candidateDeclarationSetSHA256: String
    public let candidateDeclarationSetByteCount: UInt64
    public let tokenizerBundleSHA256: String
    public let tokenizerBundleByteCount: UInt64
    public let candidateIDs: [String]
    public let candidateIdentitySHA256s: [String]
    public let declarationBundleSHA256s: [String]
    public let inputBindingCount: UInt64
    public let retainedOriginalInputByteCount: UInt64
    public let optimizerSteps: UInt64
    public let trainingTokens: UInt64
    public let wallClockSeconds: UInt64
    public let outputNamespace: String
    public let orderedTensorCount: UInt64
    public let uniqueParameterStorageCount: UInt64
    public let totalParameterCount: UInt64

    package init(
        projecting projection:
            PrimeLatinProposalValidationCompositionReceiptProjectionV1
    ) throws {
        schema = projection.schema
        outcome = projection.outcome
        verificationScope = projection.verificationScope
        receiptPolicyID = projection.receiptPolicyID
        sourceObservationSchema = projection.sourceObservationSchema
        sourceObservationOutcome = projection.sourceObservationOutcome
        sourceObservationVerificationScope =
            projection.sourceObservationVerificationScope
        sourceCompositionPolicyID = projection.sourceCompositionPolicyID
        sourceAuthorityDisposition = projection.sourceAuthorityDisposition
        sourceAuthorityTrueClaims = projection.sourceAuthorityTrueClaims
        sourceAuthorityFalseClaims = projection.sourceAuthorityFalseClaims
        pairReceiptSHA256 = projection.pairReceiptSHA256
        pairReceiptByteCount = projection.pairReceiptByteCount
        producerRepository = projection.producerRepository
        producerCommit = projection.producerCommit
        producerTree = projection.producerTree
        candidateCatalogSHA256 = projection.candidateCatalogSHA256
        candidateCatalogByteCount = projection.candidateCatalogByteCount
        experimentManifestSHA256 = projection.experimentManifestSHA256
        experimentManifestByteCount = projection.experimentManifestByteCount
        candidateDeclarationSetSHA256 =
            projection.candidateDeclarationSetSHA256
        candidateDeclarationSetByteCount =
            projection.candidateDeclarationSetByteCount
        tokenizerBundleSHA256 = projection.tokenizerBundleSHA256
        tokenizerBundleByteCount = projection.tokenizerBundleByteCount
        candidateIDs = projection.candidateIDs
        candidateIdentitySHA256s = projection.candidateIdentitySHA256s
        declarationBundleSHA256s = projection.declarationBundleSHA256s
        inputBindingCount = projection.inputBindingCount
        retainedOriginalInputByteCount =
            projection.retainedOriginalInputByteCount
        optimizerSteps = projection.optimizerSteps
        trainingTokens = projection.trainingTokens
        wallClockSeconds = projection.wallClockSeconds
        outputNamespace = projection.outputNamespace
        orderedTensorCount = projection.orderedTensorCount
        uniqueParameterStorageCount = projection.uniqueParameterStorageCount
        totalParameterCount = projection.totalParameterCount
        try validateExactV1()
    }

    public init(from decoder: Decoder) throws {
        let unknown = try decoder.container(
            keyedBy: PrimeLatinProposalValidationCompositionReceiptAnyKeyV1
                .self)
        let actualKeys = Set(unknown.allKeys.map(\.stringValue))
        let expectedKeys = Set(CodingKeys.allCases.map(\.rawValue))
        guard actualKeys == expectedKeys else {
            throw PrimeLatinProposalValidationCompositionReceiptErrorV1
                .invalidReceipt("key_set")
        }
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let projection =
            PrimeLatinProposalValidationCompositionReceiptProjectionV1(
                schema: try values.decode(String.self, forKey: .schema),
                outcome: try values.decode(String.self, forKey: .outcome),
                verificationScope: try values.decode(
                    String.self, forKey: .verificationScope),
                receiptPolicyID: try values.decode(
                    String.self, forKey: .receiptPolicyID),
                sourceObservationSchema: try values.decode(
                    String.self, forKey: .sourceObservationSchema),
                sourceObservationOutcome: try values.decode(
                    String.self, forKey: .sourceObservationOutcome),
                sourceObservationVerificationScope: try values.decode(
                    String.self,
                    forKey: .sourceObservationVerificationScope),
                sourceCompositionPolicyID: try values.decode(
                    String.self, forKey: .sourceCompositionPolicyID),
                sourceAuthorityDisposition: try values.decode(
                    String.self, forKey: .sourceAuthorityDisposition),
                sourceAuthorityTrueClaims: try values.decode(
                    [String].self, forKey: .sourceAuthorityTrueClaims),
                sourceAuthorityFalseClaims: try values.decode(
                    [String].self, forKey: .sourceAuthorityFalseClaims),
                pairReceiptSHA256: try values.decode(
                    String.self, forKey: .pairReceiptSHA256),
                pairReceiptByteCount: try values.decode(
                    UInt64.self, forKey: .pairReceiptByteCount),
                producerRepository: try values.decode(
                    String.self, forKey: .producerRepository),
                producerCommit: try values.decode(
                    String.self, forKey: .producerCommit),
                producerTree: try values.decode(
                    String.self, forKey: .producerTree),
                candidateCatalogSHA256: try values.decode(
                    String.self, forKey: .candidateCatalogSHA256),
                candidateCatalogByteCount: try values.decode(
                    UInt64.self, forKey: .candidateCatalogByteCount),
                experimentManifestSHA256: try values.decode(
                    String.self, forKey: .experimentManifestSHA256),
                experimentManifestByteCount: try values.decode(
                    UInt64.self, forKey: .experimentManifestByteCount),
                candidateDeclarationSetSHA256: try values.decode(
                    String.self, forKey: .candidateDeclarationSetSHA256),
                candidateDeclarationSetByteCount: try values.decode(
                    UInt64.self,
                    forKey: .candidateDeclarationSetByteCount),
                tokenizerBundleSHA256: try values.decode(
                    String.self, forKey: .tokenizerBundleSHA256),
                tokenizerBundleByteCount: try values.decode(
                    UInt64.self, forKey: .tokenizerBundleByteCount),
                candidateIDs: try values.decode(
                    [String].self, forKey: .candidateIDs),
                candidateIdentitySHA256s: try values.decode(
                    [String].self, forKey: .candidateIdentitySHA256s),
                declarationBundleSHA256s: try values.decode(
                    [String].self, forKey: .declarationBundleSHA256s),
                inputBindingCount: try values.decode(
                    UInt64.self, forKey: .inputBindingCount),
                retainedOriginalInputByteCount: try values.decode(
                    UInt64.self, forKey: .retainedOriginalInputByteCount),
                optimizerSteps: try values.decode(
                    UInt64.self, forKey: .optimizerSteps),
                trainingTokens: try values.decode(
                    UInt64.self, forKey: .trainingTokens),
                wallClockSeconds: try values.decode(
                    UInt64.self, forKey: .wallClockSeconds),
                outputNamespace: try values.decode(
                    String.self, forKey: .outputNamespace),
                orderedTensorCount: try values.decode(
                    UInt64.self, forKey: .orderedTensorCount),
                uniqueParameterStorageCount: try values.decode(
                    UInt64.self, forKey: .uniqueParameterStorageCount),
                totalParameterCount: try values.decode(
                    UInt64.self, forKey: .totalParameterCount))
        try self.init(projecting: projection)
    }

    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(schema, forKey: .schema)
        try values.encode(outcome, forKey: .outcome)
        try values.encode(verificationScope, forKey: .verificationScope)
        try values.encode(receiptPolicyID, forKey: .receiptPolicyID)
        try values.encode(
            sourceObservationSchema, forKey: .sourceObservationSchema)
        try values.encode(
            sourceObservationOutcome, forKey: .sourceObservationOutcome)
        try values.encode(
            sourceObservationVerificationScope,
            forKey: .sourceObservationVerificationScope)
        try values.encode(
            sourceCompositionPolicyID, forKey: .sourceCompositionPolicyID)
        try values.encode(
            sourceAuthorityDisposition, forKey: .sourceAuthorityDisposition)
        try values.encode(
            sourceAuthorityTrueClaims, forKey: .sourceAuthorityTrueClaims)
        try values.encode(
            sourceAuthorityFalseClaims, forKey: .sourceAuthorityFalseClaims)
        try values.encode(pairReceiptSHA256, forKey: .pairReceiptSHA256)
        try values.encode(pairReceiptByteCount, forKey: .pairReceiptByteCount)
        try values.encode(producerRepository, forKey: .producerRepository)
        try values.encode(producerCommit, forKey: .producerCommit)
        try values.encode(producerTree, forKey: .producerTree)
        try values.encode(
            candidateCatalogSHA256, forKey: .candidateCatalogSHA256)
        try values.encode(
            candidateCatalogByteCount, forKey: .candidateCatalogByteCount)
        try values.encode(
            experimentManifestSHA256, forKey: .experimentManifestSHA256)
        try values.encode(
            experimentManifestByteCount,
            forKey: .experimentManifestByteCount)
        try values.encode(
            candidateDeclarationSetSHA256,
            forKey: .candidateDeclarationSetSHA256)
        try values.encode(
            candidateDeclarationSetByteCount,
            forKey: .candidateDeclarationSetByteCount)
        try values.encode(
            tokenizerBundleSHA256, forKey: .tokenizerBundleSHA256)
        try values.encode(
            tokenizerBundleByteCount, forKey: .tokenizerBundleByteCount)
        try values.encode(candidateIDs, forKey: .candidateIDs)
        try values.encode(
            candidateIdentitySHA256s, forKey: .candidateIdentitySHA256s)
        try values.encode(
            declarationBundleSHA256s, forKey: .declarationBundleSHA256s)
        try values.encode(inputBindingCount, forKey: .inputBindingCount)
        try values.encode(
            retainedOriginalInputByteCount,
            forKey: .retainedOriginalInputByteCount)
        try values.encode(optimizerSteps, forKey: .optimizerSteps)
        try values.encode(trainingTokens, forKey: .trainingTokens)
        try values.encode(wallClockSeconds, forKey: .wallClockSeconds)
        try values.encode(outputNamespace, forKey: .outputNamespace)
        try values.encode(orderedTensorCount, forKey: .orderedTensorCount)
        try values.encode(
            uniqueParameterStorageCount,
            forKey: .uniqueParameterStorageCount)
        try values.encode(totalParameterCount, forKey: .totalParameterCount)
    }

    public func validateExactV1() throws {
        let expected =
            PrimeLatinProposalValidationCompositionReceiptProjectionV1
                .exactFinal
        let actual = projection
        for (field, matches) in [
            ("schema", actual.schema == expected.schema),
            ("outcome", actual.outcome == expected.outcome),
            ("verification_scope",
             actual.verificationScope == expected.verificationScope),
            ("receipt_policy_id",
             actual.receiptPolicyID == expected.receiptPolicyID),
            ("source_observation_schema",
             actual.sourceObservationSchema
                == expected.sourceObservationSchema),
            ("source_observation_outcome",
             actual.sourceObservationOutcome
                == expected.sourceObservationOutcome),
            ("source_observation_verification_scope",
             actual.sourceObservationVerificationScope
                == expected.sourceObservationVerificationScope),
            ("source_composition_policy_id",
             actual.sourceCompositionPolicyID
                == expected.sourceCompositionPolicyID),
            ("source_authority_disposition",
             actual.sourceAuthorityDisposition
                == expected.sourceAuthorityDisposition),
            ("source_authority_true_claims",
             actual.sourceAuthorityTrueClaims
                == expected.sourceAuthorityTrueClaims),
            ("source_authority_false_claims",
             actual.sourceAuthorityFalseClaims
                == expected.sourceAuthorityFalseClaims),
            ("pair_receipt_sha256",
             actual.pairReceiptSHA256 == expected.pairReceiptSHA256),
            ("pair_receipt_byte_count",
             actual.pairReceiptByteCount == expected.pairReceiptByteCount),
            ("producer_repository",
             actual.producerRepository == expected.producerRepository),
            ("producer_commit",
             actual.producerCommit == expected.producerCommit),
            ("producer_tree", actual.producerTree == expected.producerTree),
            ("candidate_catalog_sha256",
             actual.candidateCatalogSHA256
                == expected.candidateCatalogSHA256),
            ("candidate_catalog_byte_count",
             actual.candidateCatalogByteCount
                == expected.candidateCatalogByteCount),
            ("experiment_manifest_sha256",
             actual.experimentManifestSHA256
                == expected.experimentManifestSHA256),
            ("experiment_manifest_byte_count",
             actual.experimentManifestByteCount
                == expected.experimentManifestByteCount),
            ("candidate_declaration_set_sha256",
             actual.candidateDeclarationSetSHA256
                == expected.candidateDeclarationSetSHA256),
            ("candidate_declaration_set_byte_count",
             actual.candidateDeclarationSetByteCount
                == expected.candidateDeclarationSetByteCount),
            ("tokenizer_bundle_sha256",
             actual.tokenizerBundleSHA256
                == expected.tokenizerBundleSHA256),
            ("tokenizer_bundle_byte_count",
             actual.tokenizerBundleByteCount
                == expected.tokenizerBundleByteCount),
            ("candidate_ids", actual.candidateIDs == expected.candidateIDs),
            ("candidate_identity_sha256s",
             actual.candidateIdentitySHA256s
                == expected.candidateIdentitySHA256s),
            ("declaration_bundle_sha256s",
             actual.declarationBundleSHA256s
                == expected.declarationBundleSHA256s),
            ("input_binding_count",
             actual.inputBindingCount == expected.inputBindingCount),
            ("retained_original_input_byte_count",
             actual.retainedOriginalInputByteCount
                == expected.retainedOriginalInputByteCount),
            ("optimizer_steps",
             actual.optimizerSteps == expected.optimizerSteps),
            ("training_tokens",
             actual.trainingTokens == expected.trainingTokens),
            ("wall_clock_seconds",
             actual.wallClockSeconds == expected.wallClockSeconds),
            ("output_namespace",
             actual.outputNamespace == expected.outputNamespace),
            ("ordered_tensor_count",
             actual.orderedTensorCount == expected.orderedTensorCount),
            ("unique_parameter_storage_count",
             actual.uniqueParameterStorageCount
                == expected.uniqueParameterStorageCount),
            ("total_parameter_count",
             actual.totalParameterCount == expected.totalParameterCount),
        ] {
            guard matches else {
                throw PrimeLatinProposalValidationCompositionReceiptErrorV1
                    .invalidReceipt(field)
            }
        }
    }

    package var projection:
        PrimeLatinProposalValidationCompositionReceiptProjectionV1
    {
        PrimeLatinProposalValidationCompositionReceiptProjectionV1(
            schema: schema,
            outcome: outcome,
            verificationScope: verificationScope,
            receiptPolicyID: receiptPolicyID,
            sourceObservationSchema: sourceObservationSchema,
            sourceObservationOutcome: sourceObservationOutcome,
            sourceObservationVerificationScope:
                sourceObservationVerificationScope,
            sourceCompositionPolicyID: sourceCompositionPolicyID,
            sourceAuthorityDisposition: sourceAuthorityDisposition,
            sourceAuthorityTrueClaims: sourceAuthorityTrueClaims,
            sourceAuthorityFalseClaims: sourceAuthorityFalseClaims,
            pairReceiptSHA256: pairReceiptSHA256,
            pairReceiptByteCount: pairReceiptByteCount,
            producerRepository: producerRepository,
            producerCommit: producerCommit,
            producerTree: producerTree,
            candidateCatalogSHA256: candidateCatalogSHA256,
            candidateCatalogByteCount: candidateCatalogByteCount,
            experimentManifestSHA256: experimentManifestSHA256,
            experimentManifestByteCount: experimentManifestByteCount,
            candidateDeclarationSetSHA256: candidateDeclarationSetSHA256,
            candidateDeclarationSetByteCount:
                candidateDeclarationSetByteCount,
            tokenizerBundleSHA256: tokenizerBundleSHA256,
            tokenizerBundleByteCount: tokenizerBundleByteCount,
            candidateIDs: candidateIDs,
            candidateIdentitySHA256s: candidateIdentitySHA256s,
            declarationBundleSHA256s: declarationBundleSHA256s,
            inputBindingCount: inputBindingCount,
            retainedOriginalInputByteCount: retainedOriginalInputByteCount,
            optimizerSteps: optimizerSteps,
            trainingTokens: trainingTokens,
            wallClockSeconds: wallClockSeconds,
            outputNamespace: outputNamespace,
            orderedTensorCount: orderedTensorCount,
            uniqueParameterStorageCount: uniqueParameterStorageCount,
            totalParameterCount: totalParameterCount)
    }

    private enum CodingKeys: String, CodingKey, CaseIterable {
        case schema
        case outcome
        case verificationScope = "verification_scope"
        case receiptPolicyID = "receipt_policy_id"
        case sourceObservationSchema = "source_observation_schema"
        case sourceObservationOutcome = "source_observation_outcome"
        case sourceObservationVerificationScope =
            "source_observation_verification_scope"
        case sourceCompositionPolicyID = "source_composition_policy_id"
        case sourceAuthorityDisposition = "source_authority_disposition"
        case sourceAuthorityTrueClaims = "source_authority_true_claims"
        case sourceAuthorityFalseClaims = "source_authority_false_claims"
        case pairReceiptSHA256 = "pair_receipt_sha256"
        case pairReceiptByteCount = "pair_receipt_byte_count"
        case producerRepository = "producer_repository"
        case producerCommit = "producer_commit"
        case producerTree = "producer_tree"
        case candidateCatalogSHA256 = "candidate_catalog_sha256"
        case candidateCatalogByteCount = "candidate_catalog_byte_count"
        case experimentManifestSHA256 = "experiment_manifest_sha256"
        case experimentManifestByteCount = "experiment_manifest_byte_count"
        case candidateDeclarationSetSHA256 =
            "candidate_declaration_set_sha256"
        case candidateDeclarationSetByteCount =
            "candidate_declaration_set_byte_count"
        case tokenizerBundleSHA256 = "tokenizer_bundle_sha256"
        case tokenizerBundleByteCount = "tokenizer_bundle_byte_count"
        case candidateIDs = "candidate_ids"
        case candidateIdentitySHA256s = "candidate_identity_sha256s"
        case declarationBundleSHA256s = "declaration_bundle_sha256s"
        case inputBindingCount = "input_binding_count"
        case retainedOriginalInputByteCount =
            "retained_original_input_byte_count"
        case optimizerSteps = "optimizer_steps"
        case trainingTokens = "training_tokens"
        case wallClockSeconds = "wall_clock_seconds"
        case outputNamespace = "output_namespace"
        case orderedTensorCount = "ordered_tensor_count"
        case uniqueParameterStorageCount =
            "unique_parameter_storage_count"
        case totalParameterCount = "total_parameter_count"
    }
}

private struct PrimeLatinProposalValidationCompositionReceiptAnyKeyV1:
    CodingKey
{
    let stringValue: String
    let intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
        intValue = nil
    }

    init?(intValue: Int) {
        stringValue = String(intValue)
        self.intValue = intValue
    }
}
