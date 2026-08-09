import CryptoKit
import Foundation
import XCTest
@testable import PrimeLatinProposalValidationCompositionReceipt

final class PrimeLatinProposalValidationCompositionReceiptV1Tests:
    XCTestCase
{
    typealias Projection =
        PrimeLatinProposalValidationCompositionReceiptProjectionV1
    typealias Mutation = (inout Projection) -> Void

    func testExactFinalReceiptFreezesSchemaSourceAndAuthorityCeiling()
        throws
    {
        let receipt = try makeReceipt()

        XCTAssertEqual(
            receipt.schema,
            "ergentics_prime_latin_proposal_v3_validation_composition_" +
                "receipt_v1")
        XCTAssertEqual(receipt.outcome, "abstain")
        XCTAssertEqual(
            receipt.verificationScope,
            "durable_content_addressed_canonical_projection_of_one_exact_" +
                "prime_validation_composition_observation_only_raw_child_" +
                "observations_current_liveness_proposal_admission_runtime_" +
                "trial_selection_promotion_product_and_model_publication_" +
                "authority_absent")
        XCTAssertEqual(
            receipt.receiptPolicyID,
            "prime_latin_v3_validation_composition_content_addressed_" +
                "receipt_v1")
        XCTAssertEqual(
            receipt.sourceObservationSchema,
            "ergentics_prime_latin_proposal_v3_validation_composition_" +
                "observation_v1")
        XCTAssertEqual(receipt.sourceObservationOutcome, "abstain")
        XCTAssertEqual(
            receipt.sourceObservationVerificationScope,
            "prime_owned_cooperative_same_request_root_sequence_composing_" +
                "one_live_producer_revalidation_observation_and_one_" +
                "independent_replay_observation_with_exact_shared_identity_" +
                "hash_count_budget_and_output_namespace_cross_bindings_" +
                "only_non_authorizing")
        XCTAssertEqual(
            receipt.sourceCompositionPolicyID,
            "prime_latin_v3_producer_revalidation_independent_replay_" +
                "composition_v1")
        XCTAssertEqual(
            receipt.sourceAuthorityDisposition,
            "abstain_live_producer_revalidation_and_independent_prime_" +
                "replay_composed_proposal_policy_runtime_decoder_" +
                "initialization_evaluation_trial_decision_and_publication_" +
                "authority_absent")

        XCTAssertEqual(receipt.sourceAuthorityTrueClaims, trueClaims)
        XCTAssertEqual(receipt.sourceAuthorityTrueClaims.count, 24)
        XCTAssertEqual(receipt.sourceAuthorityFalseClaims, falseClaims)
        XCTAssertEqual(receipt.sourceAuthorityFalseClaims.count, 30)
        XCTAssertEqual(
            Set(receipt.sourceAuthorityTrueClaims).count,
            receipt.sourceAuthorityTrueClaims.count)
        XCTAssertEqual(
            Set(receipt.sourceAuthorityFalseClaims).count,
            receipt.sourceAuthorityFalseClaims.count)
        XCTAssertTrue(
            Set(receipt.sourceAuthorityTrueClaims).isDisjoint(
                with: Set(receipt.sourceAuthorityFalseClaims)))

        XCTAssertEqual(
            receipt.pairReceiptSHA256,
            "6c47d6ff17d72e48873c9f4ae9ce0a0fe7e57dea8e25db144c5f1d8d42761ff7")
        XCTAssertEqual(receipt.pairReceiptByteCount, 1_833)
        XCTAssertEqual(receipt.producerRepository, "Ergentics/ergentics-llm")
        XCTAssertEqual(
            receipt.producerCommit,
            "776c412e3f10e8bf4e33cd0ae60787d9ca6b5831")
        XCTAssertEqual(
            receipt.producerTree,
            "c1f41758aea2860ab06039776f5ea0403dff1b61")
        XCTAssertEqual(
            receipt.candidateCatalogSHA256,
            "12387e11fdbf68ab5b76cad79c6c958e9b82ddeca1cb588b844918a2ab0dc6b4")
        XCTAssertEqual(receipt.candidateCatalogByteCount, 20_803)
        XCTAssertEqual(
            receipt.experimentManifestSHA256,
            "8436ab6d656b2393792c564d0bdb9a25d1ade9f5c457ad3b96cf99bacc708a76")
        XCTAssertEqual(receipt.experimentManifestByteCount, 3_364)
        XCTAssertEqual(
            receipt.candidateDeclarationSetSHA256,
            "45c787dba8c538794cbaf7cb90acb4528d2dedcaf666a1f0da151ca236138881")
        XCTAssertEqual(receipt.candidateDeclarationSetByteCount, 14_860)
        XCTAssertEqual(
            receipt.tokenizerBundleSHA256,
            "9fa3b6eea42a9c4c13ec1ecda2309ec4c35b3022638ae61a08dd2f0fcb9b074c")
        XCTAssertEqual(receipt.tokenizerBundleByteCount, 2_930)
        XCTAssertEqual(receipt.candidateIDs, ["latin_structural_fixture_v1"])
        XCTAssertEqual(
            receipt.candidateIdentitySHA256s,
            [
                "64a288b62cdef276923eb72e5cc4d209a7195526408414fc5167522151481265",
            ])
        XCTAssertEqual(
            receipt.declarationBundleSHA256s,
            [
                "6f07896e50b2b530ea5f5924859d1e66bf9880366c16cf37832138a0e6c7f4bd",
            ])
        XCTAssertEqual(receipt.inputBindingCount, 21)
        XCTAssertEqual(receipt.retainedOriginalInputByteCount, 8_084_712)
        XCTAssertEqual(receipt.optimizerSteps, 1)
        XCTAssertEqual(receipt.trainingTokens, 128)
        XCTAssertEqual(receipt.wallClockSeconds, 60)
        XCTAssertEqual(
            receipt.outputNamespace,
            "models/latin-prospective/structural-fixture-v3-776c412e")
        XCTAssertEqual(receipt.orderedTensorCount, 12)
        XCTAssertEqual(receipt.uniqueParameterStorageCount, 11)
        XCTAssertEqual(receipt.totalParameterCount, 131_736)
        XCTAssertEqual(
            PrimeLatinProposalValidationCompositionReceiptV1
                .maximumByteCount,
            65_536)
        XCTAssertNoThrow(try receipt.validateExactV1())
    }

    func testCanonicalGoldenRoundTripAndExactKeySet() throws {
        let receipt = try makeReceipt()
        let data = try canonicalData(receipt)

        XCTAssertEqual(data.count, 4_744)
        XCTAssertEqual(
            sha256(data),
            "99517013a20c48962e9f8f1a19687e1158f0ce24e225bc30dd8487aca3d25832")
        XCTAssertLessThanOrEqual(
            UInt64(data.count),
            PrimeLatinProposalValidationCompositionReceiptV1
                .maximumByteCount)
        XCTAssertEqual(
            try JSONDecoder().decode(
                PrimeLatinProposalValidationCompositionReceiptV1.self,
                from: data),
            receipt)
        XCTAssertEqual(
            try canonicalData(
                JSONDecoder().decode(
                    PrimeLatinProposalValidationCompositionReceiptV1.self,
                    from: data)),
            data)

        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(Set(object.keys), expectedJSONKeys)
        XCTAssertEqual(object.keys.count, 36)
    }

    func testEveryReceiptFieldMutationIsRejectedByOneEngine() throws {
        let mutations: [(String, Mutation)] = [
            ("schema", { $0.schema += "_mutated" }),
            ("outcome", { $0.outcome = "pass" }),
            ("verification_scope", { $0.verificationScope += "_mutated" }),
            ("receipt_policy_id", { $0.receiptPolicyID += "_mutated" }),
            ("source_observation_schema",
             { $0.sourceObservationSchema += "_mutated" }),
            ("source_observation_outcome",
             { $0.sourceObservationOutcome = "pass" }),
            ("source_observation_verification_scope",
             { $0.sourceObservationVerificationScope += "_mutated" }),
            ("source_composition_policy_id",
             { $0.sourceCompositionPolicyID += "_mutated" }),
            ("source_authority_disposition",
             { $0.sourceAuthorityDisposition += "_mutated" }),
            ("source_authority_true_claims",
             { $0.sourceAuthorityTrueClaims.append("inventedTrueClaim") }),
            ("source_authority_false_claims",
             { $0.sourceAuthorityFalseClaims.append("inventedFalseClaim") }),
            ("pair_receipt_sha256", { $0.pairReceiptSHA256 = Self.badSHA }),
            ("pair_receipt_byte_count", { $0.pairReceiptByteCount += 1 }),
            ("producer_repository", { $0.producerRepository += "-mutated" }),
            ("producer_commit", { $0.producerCommit = Self.badGitOID }),
            ("producer_tree", { $0.producerTree = Self.badGitOID }),
            ("candidate_catalog_sha256",
             { $0.candidateCatalogSHA256 = Self.badSHA }),
            ("candidate_catalog_byte_count",
             { $0.candidateCatalogByteCount += 1 }),
            ("experiment_manifest_sha256",
             { $0.experimentManifestSHA256 = Self.badSHA }),
            ("experiment_manifest_byte_count",
             { $0.experimentManifestByteCount += 1 }),
            ("candidate_declaration_set_sha256",
             { $0.candidateDeclarationSetSHA256 = Self.badSHA }),
            ("candidate_declaration_set_byte_count",
             { $0.candidateDeclarationSetByteCount += 1 }),
            ("tokenizer_bundle_sha256",
             { $0.tokenizerBundleSHA256 = Self.badSHA }),
            ("tokenizer_bundle_byte_count",
             { $0.tokenizerBundleByteCount += 1 }),
            ("candidate_ids", { $0.candidateIDs.append("invented") }),
            ("candidate_identity_sha256s",
             { $0.candidateIdentitySHA256s[0] = Self.badSHA }),
            ("declaration_bundle_sha256s",
             { $0.declarationBundleSHA256s[0] = Self.badSHA }),
            ("input_binding_count", { $0.inputBindingCount += 1 }),
            ("retained_original_input_byte_count",
             { $0.retainedOriginalInputByteCount += 1 }),
            ("optimizer_steps", { $0.optimizerSteps += 1 }),
            ("training_tokens", { $0.trainingTokens += 1 }),
            ("wall_clock_seconds", { $0.wallClockSeconds += 1 }),
            ("output_namespace", { $0.outputNamespace += "-mutated" }),
            ("ordered_tensor_count", { $0.orderedTensorCount += 1 }),
            ("unique_parameter_storage_count",
             { $0.uniqueParameterStorageCount += 1 }),
            ("total_parameter_count", { $0.totalParameterCount += 1 }),
        ]
        XCTAssertEqual(mutations.count, 36)

        for (field, mutate) in mutations {
            var projection = Projection.exactFinal
            mutate(&projection)
            assertRejected(projection, field: field)
        }
    }

    func testEveryTrueClaimMutationAndOrderingAliasIsRejected() throws {
        XCTAssertEqual(Projection.exactFinal.sourceAuthorityTrueClaims, trueClaims)
        for index in trueClaims.indices {
            var projection = Projection.exactFinal
            projection.sourceAuthorityTrueClaims[index] += "_mutated"
            assertRejected(
                projection,
                field: "source_authority_true_claims")
        }

        var reordered = Projection.exactFinal
        reordered.sourceAuthorityTrueClaims.swapAt(0, 1)
        assertRejected(reordered, field: "source_authority_true_claims")

        var duplicate = Projection.exactFinal
        duplicate.sourceAuthorityTrueClaims[1] =
            duplicate.sourceAuthorityTrueClaims[0]
        assertRejected(duplicate, field: "source_authority_true_claims")

        var missing = Projection.exactFinal
        missing.sourceAuthorityTrueClaims.removeLast()
        assertRejected(missing, field: "source_authority_true_claims")
    }

    func testEveryFalseClaimMutationAndOrderingAliasIsRejected() throws {
        XCTAssertEqual(
            Projection.exactFinal.sourceAuthorityFalseClaims,
            falseClaims)
        for index in falseClaims.indices {
            var projection = Projection.exactFinal
            projection.sourceAuthorityFalseClaims[index] += "_mutated"
            assertRejected(
                projection,
                field: "source_authority_false_claims")
        }

        var reordered = Projection.exactFinal
        reordered.sourceAuthorityFalseClaims.swapAt(0, 1)
        assertRejected(reordered, field: "source_authority_false_claims")

        var duplicate = Projection.exactFinal
        duplicate.sourceAuthorityFalseClaims[1] =
            duplicate.sourceAuthorityFalseClaims[0]
        assertRejected(duplicate, field: "source_authority_false_claims")

        var missing = Projection.exactFinal
        missing.sourceAuthorityFalseClaims.removeLast()
        assertRejected(missing, field: "source_authority_false_claims")
    }

    func testDecoderRejectsUnknownMissingAndSemanticallyMutatedKeys()
        throws
    {
        let data = try canonicalData(makeReceipt())
        var object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: data) as? [String: Any])

        object["unknown_key"] = true
        assertDecodeRejected(
            try JSONSerialization.data(
                withJSONObject: object,
                options: [.sortedKeys]),
            field: "key_set")

        object.removeValue(forKey: "unknown_key")
        object.removeValue(forKey: "total_parameter_count")
        assertDecodeRejected(
            try JSONSerialization.data(
                withJSONObject: object,
                options: [.sortedKeys]),
            field: "key_set")

        object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: data) as? [String: Any])
        object["outcome"] = "pass"
        assertDecodeRejected(
            try JSONSerialization.data(
                withJSONObject: object,
                options: [.sortedKeys]),
            field: "outcome")
    }

    func testPureSchemaDecoderDoesNotClaimCanonicalByteAuthority() throws {
        let receipt = try makeReceipt()
        let canonical = try canonicalData(receipt)
        var padded = Data(" \n".utf8)
        padded.append(canonical)
        padded.append(contentsOf: Data("\n".utf8))

        XCTAssertNotEqual(padded, canonical)
        XCTAssertEqual(
            try JSONDecoder().decode(
                PrimeLatinProposalValidationCompositionReceiptV1.self,
                from: padded),
            receipt,
            "byte-canonicality belongs to the PrimeCore-backed publisher")
    }

    func testContentAddressPathRejectsEveryNonCanonicalDigestFamily()
        throws
    {
        let digest =
            "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
        XCTAssertEqual(
            try PrimeLatinProposalValidationCompositionReceiptContractV1
                .relativePath(forSHA256: digest),
            "latin-validation-composition-receipts/\(digest).json")

        for alias in [
            "",
            String(repeating: "a", count: 63),
            String(repeating: "a", count: 65),
            String(repeating: "A", count: 64),
            String(repeating: "g", count: 64),
            String(repeating: "0", count: 63) + "/",
        ] {
            XCTAssertThrowsError(
                try PrimeLatinProposalValidationCompositionReceiptContractV1
                    .relativePath(forSHA256: alias)
            ) { error in
                XCTAssertEqual(
                    error as?
                        PrimeLatinProposalValidationCompositionReceiptErrorV1,
                    .invalidReceipt("content_address_sha256"))
            }
        }
    }

    private func makeReceipt() throws
        -> PrimeLatinProposalValidationCompositionReceiptV1
    {
        try PrimeLatinProposalValidationCompositionReceiptV1(
            projecting: .exactFinal)
    }

    private func assertRejected(
        _ projection: Projection,
        field: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(
            try PrimeLatinProposalValidationCompositionReceiptV1(
                projecting: projection),
            file: file,
            line: line
        ) { error in
            XCTAssertEqual(
                error as?
                    PrimeLatinProposalValidationCompositionReceiptErrorV1,
                .invalidReceipt(field),
                file: file,
                line: line)
        }
    }

    private func assertDecodeRejected(
        _ data: Data,
        field: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(
            try JSONDecoder().decode(
                PrimeLatinProposalValidationCompositionReceiptV1.self,
                from: data),
            file: file,
            line: line
        ) { error in
            XCTAssertEqual(
                error as?
                    PrimeLatinProposalValidationCompositionReceiptErrorV1,
                .invalidReceipt(field),
                file: file,
                line: line)
        }
    }

    private func canonicalData<T: Encodable>(_ value: T) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(value)
    }

    private func sha256(_ data: Data) -> String {
        SHA256.hash(data: data).map {
            String(format: "%02x", $0)
        }.joined()
    }

    private let expectedJSONKeys: Set<String> = [
        "schema",
        "outcome",
        "verification_scope",
        "receipt_policy_id",
        "source_observation_schema",
        "source_observation_outcome",
        "source_observation_verification_scope",
        "source_composition_policy_id",
        "source_authority_disposition",
        "source_authority_true_claims",
        "source_authority_false_claims",
        "pair_receipt_sha256",
        "pair_receipt_byte_count",
        "producer_repository",
        "producer_commit",
        "producer_tree",
        "candidate_catalog_sha256",
        "candidate_catalog_byte_count",
        "experiment_manifest_sha256",
        "experiment_manifest_byte_count",
        "candidate_declaration_set_sha256",
        "candidate_declaration_set_byte_count",
        "tokenizer_bundle_sha256",
        "tokenizer_bundle_byte_count",
        "candidate_ids",
        "candidate_identity_sha256s",
        "declaration_bundle_sha256s",
        "input_binding_count",
        "retained_original_input_byte_count",
        "optimizer_steps",
        "training_tokens",
        "wall_clock_seconds",
        "output_namespace",
        "ordered_tensor_count",
        "unique_parameter_storage_count",
        "total_parameter_count",
    ]

    private let trueClaims = [
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

    private let falseClaims = [
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

    private static let badSHA = String(repeating: "0", count: 64)
    private static let badGitOID = String(repeating: "0", count: 40)
}
