import CryptoKit
import Foundation
import XCTest
@testable import PrimeLatinProposalIndependentReplay
@testable import PrimeLatinProposalPairCapture

final class PrimeLatinProposalIndependentReplayV1Tests: XCTestCase {
    func testExactFinalPlanGoldenCannotDrift() {
        let plan = PrimeLatinProposalIndependentReplayExpectedPlanV1.exactFinal

        XCTAssertEqual(
            plan.pairReceiptSHA256,
            "6c47d6ff17d72e48873c9f4ae9ce0a0fe7e57dea8e25db144c5f1d8d42761ff7")
        XCTAssertEqual(plan.pairReceiptByteCount, 1_833)
        XCTAssertEqual(plan.sourceRepository, "Ergentics/ergentics-llm")
        XCTAssertEqual(
            plan.sourceCommit,
            "776c412e3f10e8bf4e33cd0ae60787d9ca6b5831")
        XCTAssertEqual(
            plan.sourceTree,
            "c1f41758aea2860ab06039776f5ea0403dff1b61")
        XCTAssertEqual(
            plan.candidateCatalogSHA256,
            "12387e11fdbf68ab5b76cad79c6c958e9b82ddeca1cb588b844918a2ab0dc6b4")
        XCTAssertEqual(plan.candidateCatalogByteCount, 20_803)
        XCTAssertEqual(
            plan.experimentManifestSHA256,
            "8436ab6d656b2393792c564d0bdb9a25d1ade9f5c457ad3b96cf99bacc708a76")
        XCTAssertEqual(plan.experimentManifestByteCount, 3_364)
        XCTAssertEqual(
            plan.declarationTargetClosureSHA256,
            "815b3231fbb000968bbe2c19efe92013540d7241cba728c9b0ec1e89e9a4d193")
        XCTAssertEqual(plan.declarationTargetClosureByteCount, 1_961)
        XCTAssertEqual(
            plan.candidateIdentitySHA256,
            "64a288b62cdef276923eb72e5cc4d209a7195526408414fc5167522151481265")
        XCTAssertEqual(
            plan.declarationBundleSHA256,
            "6f07896e50b2b530ea5f5924859d1e66bf9880366c16cf37832138a0e6c7f4bd")
        XCTAssertEqual(plan.declarationBundleByteCount, 14_302)
        XCTAssertEqual(
            plan.candidateDeclarationSetSHA256,
            "45c787dba8c538794cbaf7cb90acb4528d2dedcaf666a1f0da151ca236138881")
        XCTAssertEqual(plan.candidateDeclarationSetByteCount, 14_860)
        XCTAssertEqual(
            plan.tokenizerBundleSHA256,
            "9fa3b6eea42a9c4c13ec1ecda2309ec4c35b3022638ae61a08dd2f0fcb9b074c")
        XCTAssertEqual(plan.tokenizerBundleByteCount, 2_930)
        XCTAssertEqual(plan.candidateID, "latin_structural_fixture_v1")
        XCTAssertEqual(
            plan.sourceAttribution,
            "ergentics_codex_assisted_structural_fixture")
        XCTAssertEqual(plan.tokenizerID, "ergentics_latin_bpe_v2")
        XCTAssertEqual(plan.vocabularySize, 16_384)
        XCTAssertEqual(plan.tokenizerCorpusLineCount, 98_858)
        XCTAssertEqual(plan.orderedTensorCount, 12)
        XCTAssertEqual(plan.uniqueParameterStorageCount, 11)
        XCTAssertEqual(plan.totalParameterCount, 131_736)
        XCTAssertEqual(
            plan.initializationAlgorithmID,
            "latin_structural_fixture_v3_776c412e_sha256_domain_v1")
        XCTAssertEqual(
            plan.initializationSeedDerivationSHA256,
            "82f8dbc28cfd3f538901bd1a36da5e3dafa9b8de7ee6d9ec50aad2e122daaf1a")
        XCTAssertEqual(
            plan.evaluationProcedureID,
            "latin_structural_fixture_evaluation_v1")
        XCTAssertEqual(
            plan.prospectiveCorpusID,
            "latin_structural_fixture_v3_776c412e")
        XCTAssertEqual(plan.optimizerSteps, 1)
        XCTAssertEqual(plan.trainingTokens, 128)
        XCTAssertEqual(plan.wallClockSeconds, 60)
        XCTAssertEqual(
            plan.outputNamespace,
            "models/latin-prospective/structural-fixture-v3-776c412e")
        XCTAssertEqual(plan.inputBindings.count, 21)
        XCTAssertEqual(
            plan.inputBindings.reduce(into: UInt64(0)) {
                $0 += $1.byteCount
            },
            8_084_712)
        XCTAssertEqual(
            plan.inputBindings.map(\.role),
            Self.exactInputRoles)
        XCTAssertEqual(plan.gitArtifacts.count, 7)
        XCTAssertEqual(
            plan.gitArtifacts.map(\.role),
            Array(Self.exactInputRoles.prefix(7)))
    }

    func testAuthorityCeilingIsExactAndNonAuthorizing() {
        let authority = PrimeLatinProposalIndependentReplayCaptureV1
            .makeAuthorityForTesting()

        XCTAssertEqual(
            authority.disposition,
            "abstain_independent_prime_structural_replay_complete_" +
                "live_producer_revalidation_not_composed_and_runtime_decoder_" +
                "initialization_evaluation_trial_and_publication_authority_absent")
        for value in [
            authority.pairCaptureAndRecaptureComplete,
            authority.inputSnapshotCaptureAndRecaptureComplete,
            authority.producerGitObservationComplete,
            authority.exactTwentyOneOriginalInputBindingsCrossBound,
            authority.exactTwentyOneOriginalInputBytesRetained,
            authority.retainedOriginalInputHashCountRecomputationComplete,
            authority.independentTokenizerBundleReconstructionComplete,
            authority.independentDeclarationTargetClosureReconstructionComplete,
            authority.independentCandidateIdentityReconstructionComplete,
            authority.independentCandidateDeclarationSetReconstructionComplete,
            authority.independentCandidateCatalogReconstructionComplete,
            authority.independentExperimentManifestReconstructionComplete,
            authority.canonicalCandidateCatalogBytesMatched,
            authority.canonicalExperimentManifestBytesMatched,
            authority.canonicalHashChainRecomputationComplete,
            authority.outputNamespaceAbsenceVerified,
            authority.referencedInputSnapshotAvailable,
            authority.referencedArtifactBytesAvailable,
            authority.llmGitStateIndependentlyObserved,
            authority.independentPrimeReplayComplete,
        ] {
            XCTAssertTrue(value)
        }
        for value in [
            authority.ergenticsLatinProducerModuleImported,
            authority.ergenticsLatinProducerFunctionInvoked,
            authority.ergenticsLatinProducerSourceUsedAsReplayImplementation,
            authority.liveProducerWorkspaceRevalidationComplete,
            authority.revalidatorToolSourceIndependentlyObserved,
            authority.originRemoteCryptographicallyAuthenticated,
            authority.ignoredWorkspaceBytesObserved,
            authority.declarationSourceSemanticsIndependentlyVerified,
            authority.tokenizerModelSemanticsIndependentlyValidated,
            authority.tokenizerTrainingReplayComplete,
            authority.evaluationExecutionComplete,
            authority.selectionObservationComplete,
            authority.durableInputSnapshotPublished,
            authority.durableGitObservationPublished,
            authority.durableIndependentReplayObservationPublished,
            authority.runtimeDecoderImplementationAvailable,
            authority.runtimeDependencyClosureEstablished,
            authority.runtimeInitializationEstablished,
            authority.primeProposalPacketProduced,
            authority.primeTrialAuthorizationProduced,
            authority.primeDecisionReceiptProduced,
            authority.candidateSelectionAuthorized,
            authority.trialExecutionAuthorized,
            authority.furtherTrainingAuthorized,
            authority.promotionAuthorized,
            authority.productUseAuthorized,
            authority.publicationAuthorized,
            authority.proposalPairPublicationPerformedByThisObservation,
            authority.primeDurableReceiptPublished,
        ] {
            XCTAssertFalse(value)
        }
    }

    func testIndependentReconstructionMatchesCanonicalHashChainAndObservation()
        throws
    {
        let fixture = try Self.makeFixture()
        XCTAssertEqual(
            fixture.plan.pairReceiptSHA256,
            "05c7693fe596015bafdd48cc14b045fb4fbe2ec258d1baefeb22c7ef0fe9eb7a")
        XCTAssertEqual(fixture.plan.pairReceiptByteCount, 1_833)
        XCTAssertEqual(
            fixture.plan.candidateCatalogSHA256,
            "4e9f5f56c08208416ef087fb5795509122fdda2f70244e4f7ff5ca400a79b24b")
        XCTAssertEqual(fixture.plan.candidateCatalogByteCount, 20_766)
        XCTAssertEqual(
            fixture.plan.experimentManifestSHA256,
            "20f3e4db98e23568054f81d21cbf71f29cdc10f872e9009058e2b91f1d89add5")
        XCTAssertEqual(fixture.plan.experimentManifestByteCount, 3_284)
        XCTAssertEqual(
            fixture.plan.declarationTargetClosureSHA256,
            "d0ccfc44f2ef4d532f347a1819ae28d87cf29f82be9f56783c5a4220456ddc0c")
        XCTAssertEqual(fixture.plan.declarationTargetClosureByteCount, 1_958)
        XCTAssertEqual(
            fixture.plan.candidateIdentitySHA256,
            "1dfee9b11e454dd98c1a2116068bc5efbe5a100f73ff5e005419563a28f51ccb")
        XCTAssertEqual(
            fixture.plan.declarationBundleSHA256,
            "bb12e4e650b0ae317ed24de0b962799ed10bb26cb24642dd92fd4b8c38fcab1a")
        XCTAssertEqual(fixture.plan.declarationBundleByteCount, 14_281)
        XCTAssertEqual(
            fixture.plan.candidateDeclarationSetSHA256,
            "b786d16f484bd7e0a4810a0d55e5b4e1194fadce21000ce5e8243cfb1f4f7d04")
        XCTAssertEqual(fixture.plan.candidateDeclarationSetByteCount, 14_839)
        XCTAssertEqual(
            fixture.plan.tokenizerBundleSHA256,
            "8406693719c2acb7d7a0190c9255238b94cbda336a8d0b7d4e082c5a27b8f1b3")
        XCTAssertEqual(fixture.plan.tokenizerBundleByteCount, 2_915)

        let reconstruction = try PrimeLatinProposalIndependentReplayCaptureV1
            .reconstructForTesting(
                originalInputs: fixture.originalInputs,
                expectedPlan: fixture.plan)
        XCTAssertEqual(reconstruction, fixture.reconstruction)
        XCTAssertEqual(
            Self.sha256(reconstruction.candidateCatalogData),
            fixture.plan.candidateCatalogSHA256)
        XCTAssertEqual(
            Self.sha256(reconstruction.experimentManifestData),
            fixture.plan.experimentManifestSHA256)
        XCTAssertEqual(
            Self.sha256(reconstruction.pairReceiptData),
            fixture.plan.pairReceiptSHA256)
        XCTAssertEqual(
            reconstruction.candidateDeclarationSetSHA256,
            fixture.plan.candidateDeclarationSetSHA256)
        XCTAssertEqual(
            reconstruction.tokenizerBundleSHA256,
            fixture.plan.tokenizerBundleSHA256)

        let observation = try PrimeLatinProposalIndependentReplayCaptureV1
            .compareForTesting(
                reconstruction: reconstruction,
                references: fixture.references,
                expectedPlan: fixture.plan)
        Self.assertObservation(observation, fixture: fixture)

        let capture = try PrimeLatinProposalIndependentReplayCaptureV1
            .captureForTesting(
                expectedPlan: fixture.plan,
                dependencies: fixture.stableDependencies())
        XCTAssertEqual(capture.observation, observation)
        XCTAssertEqual(
            try capture.recaptureAndValidateUnchanged(), observation)
    }

    func testPureReconstructionCannotConsultCatalogExperimentOrReceiptReferences()
        throws
    {
        let fixture = try Self.makeFixture()
        let first = try PrimeLatinProposalIndependentReplayCaptureV1
            .reconstructForTesting(
                originalInputs: fixture.originalInputs,
                expectedPlan: fixture.plan)

        // The pure seam accepts only original inputs plus policy. Poisoning each
        // reference child therefore cannot influence a second reconstruction.
        let second = try PrimeLatinProposalIndependentReplayCaptureV1
            .reconstructForTesting(
                originalInputs: fixture.originalInputs,
                expectedPlan: fixture.plan)
        XCTAssertEqual(first, second)

        let catalogPoisoned = Self.copyReferences(
            fixture.references,
            candidateCatalogData: Self.flipped(first.candidateCatalogData))
        XCTAssertThrowsError(
            try PrimeLatinProposalIndependentReplayCaptureV1
                .compareForTesting(
                    reconstruction: second,
                    references: catalogPoisoned,
                    expectedPlan: fixture.plan))

        let experimentPoisoned = Self.copyReferences(
            fixture.references,
            experimentManifestData:
                Self.flipped(first.experimentManifestData))
        XCTAssertThrowsError(
            try PrimeLatinProposalIndependentReplayCaptureV1
                .compareForTesting(
                    reconstruction: second,
                    references: experimentPoisoned,
                    expectedPlan: fixture.plan))

        let receiptPoisoned = Self.copyReferences(
            fixture.references,
            pairReceiptData: Self.flipped(first.pairReceiptData))
        XCTAssertThrowsError(
            try PrimeLatinProposalIndependentReplayCaptureV1
                .compareForTesting(
                    reconstruction: second,
                    references: receiptPoisoned,
                    expectedPlan: fixture.plan))
    }

    func testEveryRetainedOriginalInputIsByteHashAndCountBound() throws {
        let fixture = try Self.makeFixture()
        for index in fixture.originalInputs.artifacts.indices {
            let original = fixture.originalInputs.artifacts[index]
            var wrongCount = original.data
            wrongCount.append(UInt8(truncatingIfNeeded: index + 1))
            for changed in [Self.flipped(original.data), wrongCount] {
                var artifacts = fixture.originalInputs.artifacts
                artifacts[index] = .init(
                    role: original.role,
                    scope: original.scope,
                    relativePath: original.relativePath,
                    sha256: original.sha256,
                    byteCount: original.byteCount,
                    data: changed)
                XCTAssertThrowsError(
                    try PrimeLatinProposalIndependentReplayCaptureV1
                        .reconstructForTesting(
                            originalInputs: .init(artifacts: artifacts),
                            expectedPlan: fixture.plan),
                    "role unexpectedly accepted mutated bytes: \(original.role)")
            }
        }
    }

    func testReboundSemanticMutationsFailAcrossMajorInputFamilies() throws {
        let fixture = try Self.makeFixture()
        let mutations: [(String, String, String)] = [
            (
                "root_dependency_lock",
                "d37885a278f1c37484a94d0f401a418735e66519",
                "d37885a278f1c37484a94d0f401a418735e66518"),
            (
                "declaration_package_manifest",
                "dependencies: []",
                "dependencies: [\"ForbiddenDependency\"]"),
            (
                "candidate_architecture",
                "latin_structural_fixture_v1",
                "latin_structural_fixture_v0"),
            (
                "candidate_parameter_count_derivation",
                "\"total_parameter_count\":131736",
                "\"total_parameter_count\":131735"),
            (
                "evaluation_contract",
                "ergentics_latin_evaluation_contract_v1",
                "ergentics_latin_evaluation_contract_v0"),
            (
                "tokenizer_manifest",
                "prime_tokenizer_manifest_v2",
                "prime_tokenizer_manifest_v1"),
            (
                "tokenizer_recommendation",
                "\"approval_status\":\"pending\"",
                "\"approval_status\":\"approved\""),
            (
                "tokenizer_approval",
                "human:test-fixture",
                ""),
            (
                "tokenizer_staged_training_input",
                "arma virumque cano",
                "arma virumque canam"),
            (
                "initialization_contract",
                "\"fresh_weights_required\":true",
                "\"fresh_weights_required\":false"),
            (
                "prospective_corpus_manifest",
                "synthetic_train_v1",
                ""),
            (
                "training_split",
                "arma virumque cano",
                "arma virumque canam"),
            (
                "selection_observation_declaration",
                "unobserved_for_model_selection_declared\":true",
                "unobserved_for_model_selection_declared\":false"),
        ]
        for (role, old, new) in mutations {
            let original = try XCTUnwrap(
                fixture.originalInputs.artifacts.first { $0.role == role })
            let string = try XCTUnwrap(
                String(data: original.data, encoding: .utf8))
            let data = Data(
                string.replacingOccurrences(of: old, with: new).utf8)
            XCTAssertNotEqual(data, original.data, "invalid mutation: \(role)")
            let rebound = Self.rebinding(
                fixture: fixture, role: role, data: data)
            XCTAssertThrowsError(
                try PrimeLatinProposalIndependentReplayCaptureV1
                    .reconstructForTesting(
                        originalInputs: rebound.originalInputs,
                        expectedPlan: rebound.plan),
                "role unexpectedly accepted rebound mutation: \(role)")
        }
    }

    func testTokenizerVocabularyRejectsDuplicateNonFiniteAndMissingByteRows()
        throws
    {
        let fixture = try Self.makeFixture()
        let vocabulary = try XCTUnwrap(
            fixture.originalInputs.artifacts.first {
                $0.role == "tokenizer_vocabulary"
            })
        let text = try XCTUnwrap(
            String(data: vocabulary.data, encoding: .utf8))
        let mutations = [
            text.replacingOccurrences(
                of: "piece260\t-1", with: "<0xFF>\t-1"),
            text.replacingOccurrences(
                of: "<0x00>\t-1", with: "<0x00>\tnan"),
            text.replacingOccurrences(
                of: "<0x00>\t-1", with: "missing_byte_zero\t-1"),
        ]
        for data in mutations.map({ Data($0.utf8) }) {
            let manifest = try XCTUnwrap(
                fixture.originalInputs.artifacts.first {
                    $0.role == "tokenizer_manifest"
                })
            let manifestText = try XCTUnwrap(
                String(data: manifest.data, encoding: .utf8))
            let changedManifest = Data(
                manifestText.replacingOccurrences(
                    of: vocabulary.sha256,
                    with: Self.sha256(data)).utf8)
            let rebound = Self.rebinding(
                fixture: fixture,
                replacements: [
                    "tokenizer_vocabulary": data,
                    "tokenizer_manifest": changedManifest,
                ])
            XCTAssertThrowsError(
                try PrimeLatinProposalIndependentReplayCaptureV1
                    .reconstructForTesting(
                        originalInputs: rebound.originalInputs,
                        expectedPlan: rebound.plan))
        }
    }

    func testSplitBytesRejectOverlapMissingTerminatorAndInvalidUTF8() throws {
        let fixture = try Self.makeFixture()
        let overlap = Data(
            "Laviniaque venit litora\nvalidation-only\n".utf8)
        let missingTerminator = Data("selection without terminator".utf8)
        let invalidUTF8 = Data([0xff, 0x0a])
        for (role, data) in [
            ("validation_split", overlap),
            ("selection_split", missingTerminator),
            ("selection_split", invalidUTF8),
        ] {
            let rebound = Self.rebinding(
                fixture: fixture, role: role, data: data)
            XCTAssertThrowsError(
                try PrimeLatinProposalIndependentReplayCaptureV1
                    .reconstructForTesting(
                        originalInputs: rebound.originalInputs,
                        expectedPlan: rebound.plan))
        }
    }

    func testInputInventoryRejectsReorderDuplicateLocationAndHashAliases()
        throws
    {
        let fixture = try Self.makeFixture()

        var reordered = fixture.originalInputs.artifacts
        reordered.swapAt(0, 1)
        XCTAssertThrowsError(
            try PrimeLatinProposalIndependentReplayCaptureV1
                .reconstructForTesting(
                    originalInputs: .init(artifacts: reordered),
                    expectedPlan: fixture.plan))

        var duplicated = fixture.originalInputs.artifacts
        duplicated.append(duplicated[0])
        XCTAssertThrowsError(
            try PrimeLatinProposalIndependentReplayCaptureV1
                .reconstructForTesting(
                    originalInputs: .init(artifacts: duplicated),
                    expectedPlan: fixture.plan))

        var aliasedArtifacts = fixture.originalInputs.artifacts
        var aliasedBindings = fixture.plan.inputBindings
        let old = aliasedArtifacts[1]
        let aliased = PrimeLatinProposalIndependentReplayOriginalInputV1(
            role: old.role,
            scope: old.scope,
            relativePath: aliasedArtifacts[0].relativePath,
            sha256: old.sha256,
            byteCount: old.byteCount,
            data: old.data)
        aliasedArtifacts[1] = aliased
        aliasedBindings[1] = .init(
            role: aliased.role,
            scope: aliased.scope,
            relativePath: aliased.relativePath,
            sha256: aliased.sha256,
            byteCount: aliased.byteCount)
        let aliasPlan = Self.copyPlan(
            fixture.plan,
            inputBindings: aliasedBindings,
            gitArtifacts: fixture.plan.gitArtifacts)
        XCTAssertThrowsError(
            try PrimeLatinProposalIndependentReplayCaptureV1
                .reconstructForTesting(
                    originalInputs: .init(artifacts: aliasedArtifacts),
                    expectedPlan: aliasPlan))

        let selection = try XCTUnwrap(
            fixture.originalInputs.artifacts.first {
                $0.role == "selection_split"
            })
        let digestAliased = Self.rebinding(
            fixture: fixture,
            role: "validation_split",
            data: selection.data)
        XCTAssertThrowsError(
            try PrimeLatinProposalIndependentReplayCaptureV1
                .reconstructForTesting(
                    originalInputs: digestAliased.originalInputs,
                    expectedPlan: digestAliased.plan))
    }

    func testCanonicalReferencesRejectDuplicateUnknownAndNoncanonicalJSON()
        throws
    {
        let fixture = try Self.makeFixture()
        let duplicate = Data("{\"x\":1,\"x\":2}".utf8)
        var unknown = fixture.reconstruction.experimentManifestData
        unknown.insert(
            contentsOf: Data("\"zz_unknown\":false,".utf8), at: 1)
        var noncanonical = fixture.reconstruction.pairReceiptData
        noncanonical.insert(0x20, at: 0)
        let references = [
            Self.copyReferences(
                fixture.references, candidateCatalogData: duplicate),
            Self.copyReferences(
                fixture.references, experimentManifestData: unknown),
            Self.copyReferences(
                fixture.references, pairReceiptData: noncanonical),
        ]
        for reference in references {
            XCTAssertThrowsError(
                try PrimeLatinProposalIndependentReplayCaptureV1
                    .compareForTesting(
                        reconstruction: fixture.reconstruction,
                        references: reference,
                        expectedPlan: fixture.plan))
        }
    }

    func testPairReceiptAuthorityAndChildBindingDriftAreRejected() throws {
        let fixture = try Self.makeFixture()
        let authorityDrift = try Self.mutatedJSONObject(
            fixture.reconstruction.pairReceiptData
        ) { root in
            var authority = root["authority"] as! [String: Any]
            authority["publicationAuthorized"] = true
            root["authority"] = authority
        }
        let childDrift = try Self.mutatedJSONObject(
            fixture.reconstruction.pairReceiptData
        ) { root in
            var child = root["candidateCatalog"] as! [String: Any]
            child["relativePath"] = "evidence/latin-proposal-artifacts/v3/catalogs/drift.json"
            root["candidateCatalog"] = child
        }
        for data in [authorityDrift, childDrift] {
            XCTAssertThrowsError(
                try PrimeLatinProposalIndependentReplayCaptureV1
                    .compareForTesting(
                        reconstruction: fixture.reconstruction,
                        references: Self.copyReferences(
                            fixture.references,
                            pairReceiptData: data),
                        expectedPlan: fixture.plan))
        }
    }

    func testIndependentGitBlobOIDDriftIsRejected() throws {
        let fixture = try Self.makeFixture()
        var artifacts = fixture.references.git.repositoryArtifacts
        let first = artifacts[0]
        artifacts[0] = .init(
            role: first.role,
            relativePath: first.relativePath,
            gitBlobOID: String(repeating: "0", count: 40),
            sha256: first.sha256,
            byteCount: first.byteCount)
        let references = Self.copyReferences(
            fixture.references,
            gitRepositoryArtifacts: artifacts)
        XCTAssertThrowsError(
            try PrimeLatinProposalIndependentReplayCaptureV1
                .compareForTesting(
                    reconstruction: fixture.reconstruction,
                    references: references,
                    expectedPlan: fixture.plan))
    }

    func testSecondReplayBarrierRejectsSnapshotDrift() throws {
        let fixture = try Self.makeFixture()
        let state = PrimeLatinProposalIndependentReplaySourceStateV1(
            originalInputs: fixture.originalInputs,
            references: fixture.references)
        let box = StateBox(state)
        let calls = CounterBox()
        let dependencies = PrimeLatinProposalIndependentReplayCaptureDependenciesV1(
            captureSource: {
                PrimeLatinProposalIndependentReplaySourceCaptureV1(
                    initial: state,
                    recapture: { box.get() })
            },
            beforeSecondReconstruction: {
                guard calls.increment() == 2 else { return }
                var artifacts = state.originalInputs.artifacts
                let first = artifacts[0]
                artifacts[0] = .init(
                    role: first.role,
                    scope: first.scope,
                    relativePath: first.relativePath,
                    sha256: first.sha256,
                    byteCount: first.byteCount,
                    data: Self.flipped(first.data))
                box.set(.init(
                    originalInputs: .init(artifacts: artifacts),
                    references: state.references))
            })
        let capture = try PrimeLatinProposalIndependentReplayCaptureV1
            .captureForTesting(
                expectedPlan: fixture.plan,
                dependencies: dependencies)

        XCTAssertThrowsError(try capture.recaptureAndValidateUnchanged()) {
            XCTAssertEqual(
                $0 as? PrimeLatinProposalIndependentReplayError,
                .captureChanged)
        }
    }

    func testFinalRecaptureBarrierRejectsIndependentGitDrift() throws {
        let fixture = try Self.makeFixture()
        let state = PrimeLatinProposalIndependentReplaySourceStateV1(
            originalInputs: fixture.originalInputs,
            references: fixture.references)
        let box = StateBox(state)
        let calls = CounterBox()
        let dependencies = PrimeLatinProposalIndependentReplayCaptureDependenciesV1(
            captureSource: {
                PrimeLatinProposalIndependentReplaySourceCaptureV1(
                    initial: state,
                    recapture: { box.get() })
            },
            beforeFinalRecapture: {
                guard calls.increment() == 2 else { return }
                let changed = Self.copyReferences(
                    state.references,
                    gitHeadCommit:
                        "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb")
                box.set(.init(
                    originalInputs: state.originalInputs,
                    references: changed))
            })
        let capture = try PrimeLatinProposalIndependentReplayCaptureV1
            .captureForTesting(
                expectedPlan: fixture.plan,
                dependencies: dependencies)

        XCTAssertThrowsError(try capture.recaptureAndValidateUnchanged()) {
            XCTAssertEqual(
                $0 as? PrimeLatinProposalIndependentReplayError,
                .captureChanged)
        }
    }

    private static let exactInputRoles = [
        "root_package_manifest",
        "root_dependency_lock",
        "declaration_package_manifest",
        "declaration_production_source",
        "candidate_architecture",
        "candidate_parameter_count_derivation",
        "evaluation_contract",
        "tokenizer_manifest",
        "tokenizer_sentencepiece_model",
        "tokenizer_vocabulary",
        "tokenizer_recommendation",
        "tokenizer_approval",
        "tokenizer_staged_training_input",
        "tokenizer_corpus_manifest",
        "tokenizer_admitted_corpus_input",
        "initialization_contract",
        "prospective_corpus_manifest",
        "training_split",
        "validation_split",
        "selection_split",
        "selection_observation_declaration",
    ]

    private struct Fixture: @unchecked Sendable {
        let originalInputs:
            PrimeLatinProposalIndependentReplayOriginalInputsV1
        let plan: PrimeLatinProposalIndependentReplayExpectedPlanV1
        let reconstruction:
            PrimeLatinProposalIndependentReplayReconstructionV1
        let references: PrimeLatinProposalIndependentReplayReferenceV1

        func stableDependencies()
            -> PrimeLatinProposalIndependentReplayCaptureDependenciesV1
        {
            let state = PrimeLatinProposalIndependentReplaySourceStateV1(
                originalInputs: originalInputs,
                references: references)
            return PrimeLatinProposalIndependentReplayCaptureDependenciesV1(
                captureSource: {
                    PrimeLatinProposalIndependentReplaySourceCaptureV1(
                        initial: state,
                        recapture: { state })
                })
        }
    }

    private struct ReboundFixture {
        let originalInputs:
            PrimeLatinProposalIndependentReplayOriginalInputsV1
        let plan: PrimeLatinProposalIndependentReplayExpectedPlanV1
    }

    private struct RawArtifact {
        let role: String
        let scope: PrimeLatinProposalInputArtifactScopeV3
        let relativePath: String
        let data: Data

        var original: PrimeLatinProposalIndependentReplayOriginalInputV1 {
            .init(
                role: role,
                scope: scope,
                relativePath: relativePath,
                sha256: PrimeLatinProposalIndependentReplayV1Tests
                    .sha256(data),
                byteCount: UInt64(data.count),
                data: data)
        }
    }

    private final class StateBox: @unchecked Sendable {
        private let lock = NSLock()
        private var value: PrimeLatinProposalIndependentReplaySourceStateV1

        init(_ value: PrimeLatinProposalIndependentReplaySourceStateV1) {
            self.value = value
        }

        func get() -> PrimeLatinProposalIndependentReplaySourceStateV1 {
            lock.lock()
            defer { lock.unlock() }
            return value
        }

        func set(_ value: PrimeLatinProposalIndependentReplaySourceStateV1) {
            lock.lock()
            defer { lock.unlock() }
            self.value = value
        }
    }

    private final class CounterBox: @unchecked Sendable {
        private let lock = NSLock()
        private var value = 0

        func increment() -> Int {
            lock.lock()
            defer { lock.unlock() }
            value += 1
            return value
        }
    }

    private static func makeFixture() throws -> Fixture {
        let tokenizerID = "ergentics_latin_bpe_v2"
        let candidateID = "latin_structural_fixture_v1"
        let attribution = "ergentics_codex_assisted_structural_fixture"
        let rootScope = PrimeLatinProposalInputArtifactScopeV3
            .ergenticsLLMRepository
        let labScope = PrimeLatinProposalInputArtifactScopeV3
            .ergenticsMLXLab
        var raw = [String: RawArtifact]()
        func insert(
            _ role: String,
            _ scope: PrimeLatinProposalInputArtifactScopeV3,
            _ relativePath: String,
            _ data: Data
        ) {
            raw[role] = RawArtifact(
                role: role,
                scope: scope,
                relativePath: relativePath,
                data: data)
        }

        insert(
            "root_package_manifest", rootScope, "Package.swift",
            Data(
                """
                // swift-tools-version: 6.1
                import PackageDescription
                let package = Package(
                    name: "ErgenticsLLM",
                    dependencies: [
                        .package(url: "https://github.com/Ergentics/ergentics-mlx-swift", exact: "0.0.1")
                    ],
                    targets: [.target(name: "ErgenticsLatinProposalArtifacts")]
                )
                """.utf8))
        insert(
            "root_dependency_lock", rootScope, "Package.resolved",
            try json([
                "originHash":
                    "20d66b7673267d4c6a015d569030ff5e170a472893bade61a20d37d043dcd45e",
                "pins": [
                    [
                        "identity": "ergentics-mlx-swift",
                        "kind": "remoteSourceControl",
                        "location":
                            "https://github.com/Ergentics/ergentics-mlx-swift",
                        "state": [
                            "revision":
                                "d37885a278f1c37484a94d0f401a418735e66519",
                        ],
                    ],
                    [
                        "identity": "swift-numerics",
                        "kind": "remoteSourceControl",
                        "location":
                            "https://github.com/apple/swift-numerics",
                        "state": [
                            "revision":
                                "0c0290ff6b24942dadb83a929ffaaa1481df04a2",
                            "version": "1.1.1",
                        ],
                    ],
                ],
                "version": 3,
            ]))
        insert(
            "declaration_package_manifest", rootScope,
            "Research/Latin/CandidateDeclarations/Package.swift",
            Data(
                """
                // swift-tools-version: 6.1
                import PackageDescription
                let package = Package(
                    name: "ErgenticsLatinCandidateDeclarations",
                    targets: [.target(
                        name: "ErgenticsLatinCandidateDeclarations",
                        dependencies: [],
                        sources: ["ErgenticsLatinCandidateDeclarations.swift"]
                    )]
                )
                """.utf8))
        insert(
            "declaration_production_source", rootScope,
            "Research/Latin/CandidateDeclarations/Sources/ErgenticsLatinCandidateDeclarations/ErgenticsLatinCandidateDeclarations.swift",
            Data(
                "public struct ErgenticsLatinCandidate { public init() {} }\n"
                    .utf8))

        let modelPath = "tokenizer/ergentics_latin_bpe_v2/model.spm"
        let vocabPath = "tokenizer/ergentics_latin_bpe_v2/vocab.txt"
        let recommendationPath =
            "tokenizer/ergentics_latin_bpe_v2/recommendation.json"
        let approvalPath = "tokenizer/ergentics_latin_bpe_v2/approval.json"
        let manifestPath = "tokenizer/ergentics_latin_bpe_v2/manifest.json"
        let stagedPath =
            "tokenizer/ergentics_latin_bpe_v2/staging/train-input.txt"
        let corpusManifestPath =
            "corpus/la/L1/primary-corpus-manifest.json"
        let admittedPath = "corpus/la/L1/train.txt"
        let admitted = Data("arma virumque cano\nTroiae qui primus\n".utf8)
        let model = Data("synthetic sentencepiece model bytes\n".utf8)
        var vocabularyRows = ["<unk>\t0", "<bos>\t0", "<eos>\t0", "<pad>\t0"]
        vocabularyRows += (0 ..< 256).map {
            String(format: "<0x%02X>\t-1", $0)
        }
        vocabularyRows += (260 ..< 16_384).map { "piece\($0)\t-1" }
        let vocabulary = Data((vocabularyRows.joined(separator: "\n") + "\n").utf8)
        insert("tokenizer_sentencepiece_model", labScope, modelPath, model)
        insert("tokenizer_vocabulary", labScope, vocabPath, vocabulary)
        insert("tokenizer_staged_training_input", labScope, stagedPath, admitted)
        insert("tokenizer_admitted_corpus_input", labScope, admittedPath, admitted)

        let corpusManifest = try json([
            "schema": "prime_corpus_manifest_v2",
            "files": [[
                "path": admittedPath,
                "sha256": sha256(admitted),
                "bytes": admitted.count,
                "language": "la",
                "level": "L1",
                "topics": ["synthetic"],
            ]],
        ])
        insert(
            "tokenizer_corpus_manifest", labScope, corpusManifestPath,
            corpusManifest)

        let normalization: [String: Any] = [
            "swift_pre_normalization": "nfc",
            "sentencepiece_rule": "identity",
            "add_dummy_prefix": false,
            "remove_extra_whitespaces": false,
            "escape_whitespaces": true,
        ]
        let specialTokens: [String: Any] = [
            "scheme": "sentencepiece_builtin_fixed_v1",
            "unk": ["id": 0, "piece": "<unk>"],
            "bos": ["id": 1, "piece": "<bos>"],
            "eos": ["id": 2, "piece": "<eos>"],
            "pad": ["id": 3, "piece": "<pad>"],
        ]
        let trainerOptions: [String: Any] = [
            "vocab_size": 16_384,
            "model_type": "bpe",
            "byte_fallback": true,
            "character_coverage": 1.0,
            "max_sentence_length": 128,
            "hard_vocab_limit": false,
            "input_sentence_size": 0,
            "shuffle_input_sentence": false,
            "random_seed": 0,
            "num_threads": 1,
            "user_defined_symbols": [],
        ]
        let corpusInput: [String: Any] = [
            "path": admittedPath,
            "sha256": sha256(admitted),
            "bytes": admitted.count,
        ]
        let recommendation = try json([
            "schema": "prime_tokenizer_recommendation_v2",
            "tokenizer_id": tokenizerID,
            "publication_contract": "atomic_candidate_rename_v1",
            "corpus_manifest_sha256": sha256(corpusManifest),
            "corpus_manifest_path": corpusManifestPath,
            "corpus_slice": ["languages": ["la"], "levels": ["L1"]],
            "corpus_inputs": [corpusInput],
            "corpus_line_count": 2,
            "normalization": normalization,
            "special_tokens": specialTokens,
            "sentencepiece_version": "sentencepiece synthetic",
            "sentencepiece_trainer_binary": "spm_train",
            "sentencepiece_trainer_sha256": String(repeating: "1", count: 64),
            "trainer_options": trainerOptions,
            "generated_by": "prime-independent-replay-test",
            "approval_status": "pending",
            "approved_by": NSNull(),
            "approved_at": NSNull(),
        ])
        insert(
            "tokenizer_recommendation", labScope, recommendationPath,
            recommendation)
        let approval = try json([
            "schema": "ergentics_tokenizer_human_approval_v1",
            "tokenizer_id": tokenizerID,
            "recommendation_sha256": sha256(recommendation),
            "approved_by": "human:test-fixture",
            "approved_at": "2026-08-08T00:00:00Z",
        ])
        insert("tokenizer_approval", labScope, approvalPath, approval)
        let tokenizerManifest = try json([
            "schema": "prime_tokenizer_manifest_v2",
            "tokenizer_id": tokenizerID,
            "publication_contract": "atomic_candidate_rename_v1",
            "model_path": modelPath,
            "model_sha256": sha256(model),
            "vocab_sha256": sha256(vocabulary),
            "vocab_size": 16_384,
            "sentencepiece_version": "sentencepiece synthetic",
            "sentencepiece_trainer_sha256": String(repeating: "1", count: 64),
            "normalization": normalization,
            "special_tokens": specialTokens,
            "trainer_options": trainerOptions,
            "corpus_manifest_path": corpusManifestPath,
            "corpus_manifest_sha256": sha256(corpusManifest),
            "corpus_slice": ["languages": ["la"], "levels": ["L1"]],
            "corpus_inputs": [corpusInput],
            "staged_train_input_sha256": sha256(admitted),
            "recommendation_sha256": sha256(recommendation),
            "approval_sha256": sha256(approval),
            "trained_at": "2026-08-08T00:00:01Z",
        ])
        insert("tokenizer_manifest", labScope, manifestPath, tokenizerManifest)

        let tokenizerInputs = try [
            "tokenizer_manifest", "tokenizer_sentencepiece_model",
            "tokenizer_vocabulary", "tokenizer_recommendation",
            "tokenizer_approval", "tokenizer_staged_training_input",
            "tokenizer_corpus_manifest", "tokenizer_admitted_corpus_input",
        ].map { try XCTUnwrap(raw[$0]).original }
        func tokenizerRole(
            _ role: String,
            _ inputIndex: Int
        ) -> PrimeLatinReplayTokenizerRoleBindingV1 {
            .init(
                role: role,
                artifact: PrimeLatinReplayArtifactBindingV1(
                    tokenizerInputs[inputIndex]))
        }
        let tokenizerBundle = PrimeLatinReplayTokenizerBundleV1(
            tokenizerID: tokenizerID,
            tokenizerManifest: tokenizerRole("tokenizer_manifest", 0),
            sentencePieceModel: tokenizerRole("sentencepiece_model", 1),
            vocabulary: tokenizerRole("vocabulary", 2),
            recommendation: tokenizerRole("recommendation", 3),
            approval: tokenizerRole("approval", 4),
            stagedTrainingInput: tokenizerRole("staged_training_input", 5),
            corpusManifest: tokenizerRole("corpus_manifest", 6),
            manifestListedCorpusInputs: [
                tokenizerRole("admitted_corpus_input", 7),
            ])
        let tokenizerBundleData = try canonical(tokenizerBundle)

        let tensors = exactTensors()
        let architecture = PrimeLatinReplayArchitectureV1(
            candidateSlug: candidateID,
            sourceAttribution: attribution,
            tokenizer: PrimeLatinReplayCandidateTokenizerV1(
                tokenizerID: tokenizerID,
                proposalBundleSHA256: sha256(tokenizerBundleData),
                proposalBundleByteCount: UInt64(tokenizerBundleData.count),
                vocabularySize: 16_384,
                unknownTokenID: 0,
                beginningOfSequenceTokenID: 1,
                endOfSequenceTokenID: 2,
                paddingTokenID: 3),
            geometry: PrimeLatinReplayGeometryV1(
                maximumSequenceLength: 16,
                modelWidth: 8,
                layerCount: 1,
                attentionHeadCount: 2,
                attentionHeadWidth: 4,
                intermediateWidth: 16),
            orderedTensors: tensors)
        insert(
            "candidate_architecture", rootScope,
            "Research/Latin/candidates/latin_structural_fixture_v1/architecture.json",
            try canonicalLine(architecture))
        let derivation = exactDerivation(
            tensors: tensors,
            candidateID: candidateID,
            attribution: attribution)
        insert(
            "candidate_parameter_count_derivation", rootScope,
            "Research/Latin/candidates/latin_structural_fixture_v1/parameter-count-derivation.json",
            try canonicalLine(derivation))

        insert(
            "evaluation_contract", rootScope,
            "Research/Latin/evaluation_contract.json",
            try json([
                "candidate_independent": true,
                "procedure_id": "synthetic_independent_replay_v1",
                "schema": "ergentics_latin_evaluation_contract_v1",
                "thresholds_observed": false,
            ]))
        insert(
            "initialization_contract", labScope,
            "evidence/latin-proposal-inputs/v3/synthetic/initialization-contract.json",
            try json([
                "algorithm_id": "synthetic_sha256_domain_v1",
                "fresh_weights_required": true,
                "imported_weights_allowed": false,
                "schema": "ergentics_latin_initialization_contract_v1",
                "seed_derivation_sha256": String(repeating: "2", count: 64),
            ]))

        let trainingPath = "corpus/la/L1/synthetic/training.txt"
        let validationPath = "corpus/la/L1/synthetic/validation.txt"
        let selectionPath = "corpus/la/L1/synthetic/selection.txt"
        let training = Data("arma virumque cano\n".utf8)
        let validation = Data("Italiam fato profugus\n".utf8)
        let selection = Data("Laviniaque venit litora\n".utf8)
        insert("training_split", labScope, trainingPath, training)
        insert("validation_split", labScope, validationPath, validation)
        insert("selection_split", labScope, selectionPath, selection)
        let corpus = try json([
            "corpus_id": "synthetic_independent_replay_v1",
            "schema": "ergentics_latin_corpus_manifest_v1",
            "splits": [
                [
                    "byte_count": training.count,
                    "relative_path": trainingPath,
                    "role": "training",
                    "sha256": sha256(training),
                    "split_id": "synthetic_train_v1",
                ],
                [
                    "byte_count": validation.count,
                    "relative_path": validationPath,
                    "role": "validation",
                    "sha256": sha256(validation),
                    "split_id": "synthetic_validation_v1",
                ],
                [
                    "byte_count": selection.count,
                    "relative_path": selectionPath,
                    "role": "selection",
                    "sha256": sha256(selection),
                    "split_id": "synthetic_selection_v1",
                ],
            ],
        ])
        insert(
            "prospective_corpus_manifest", labScope,
            "corpus/la/L1/synthetic/corpus-manifest.json", corpus)
        insert(
            "selection_observation_declaration", labScope,
            "corpus/la/L1/synthetic/selection-observation.json",
            try json([
                "cryptographic_human_authentication": false,
                "schema":
                    "ergentics_latin_selection_observation_declaration_v1",
                "selection_split_sha256": sha256(selection),
                "source_attribution": "synthetic_test_fixture",
                "unobserved_for_model_selection_declared": true,
            ]))

        let artifacts = try exactInputRoles.map { role in
            try XCTUnwrap(raw[role], "missing fixture role: \(role)").original
        }
        let originals = PrimeLatinProposalIndependentReplayOriginalInputsV1(
            artifacts: artifacts)
        let inputs = artifacts.map {
            PrimeLatinProposalIndependentReplayExpectedInputV1(
                role: $0.role,
                scope: $0.scope,
                relativePath: $0.relativePath,
                sha256: $0.sha256,
                byteCount: $0.byteCount)
        }
        let gitArtifacts = artifacts.prefix(7).map {
            PrimeLatinProposalIndependentReplayGitArtifactReferenceV1(
                role: $0.role,
                relativePath: $0.relativePath,
                gitBlobOID: gitBlobOID($0.data),
                sha256: $0.sha256,
                byteCount: $0.byteCount)
        }
        let bootstrapPlan = makePlan(
            inputBindings: inputs,
            gitArtifacts: gitArtifacts,
            tokenizerBundleSHA256: sha256(tokenizerBundleData),
            tokenizerBundleByteCount: UInt64(tokenizerBundleData.count))
        let bootstrap = try PrimeLatinProposalIndependentReplayCaptureV1
            .reconstructForTesting(
                originalInputs: originals,
                expectedPlan: bootstrapPlan)
        let declaration = try XCTUnwrap(
            bootstrap.candidateCatalog.candidateDeclarations.candidates.first)
        let identity = declaration.declarationBundle.identityMaterial
        let plan = makePlan(
            inputBindings: inputs,
            gitArtifacts: gitArtifacts,
            pairReceiptSHA256: sha256(bootstrap.pairReceiptData),
            pairReceiptByteCount: UInt64(bootstrap.pairReceiptData.count),
            candidateCatalogSHA256: sha256(bootstrap.candidateCatalogData),
            candidateCatalogByteCount:
                UInt64(bootstrap.candidateCatalogData.count),
            experimentManifestSHA256:
                sha256(bootstrap.experimentManifestData),
            experimentManifestByteCount:
                UInt64(bootstrap.experimentManifestData.count),
            declarationTargetClosureSHA256:
                identity.declarationTargetClosureSHA256,
            declarationTargetClosureByteCount:
                identity.declarationTargetClosureByteCount,
            candidateIdentitySHA256: declaration.candidateIdentitySHA256,
            declarationBundleSHA256: declaration.declarationBundleSHA256,
            declarationBundleByteCount: declaration.declarationBundleByteCount,
            candidateDeclarationSetSHA256:
                bootstrap.candidateDeclarationSetSHA256,
            candidateDeclarationSetByteCount:
                bootstrap.candidateDeclarationSetByteCount,
            tokenizerBundleSHA256: bootstrap.tokenizerBundleSHA256,
            tokenizerBundleByteCount: bootstrap.tokenizerBundleByteCount)
        let reconstruction = try PrimeLatinProposalIndependentReplayCaptureV1
            .reconstructForTesting(
                originalInputs: originals,
                expectedPlan: plan)
        let references = makeReferences(
            reconstruction: reconstruction,
            plan: plan)
        return Fixture(
            originalInputs: originals,
            plan: plan,
            reconstruction: reconstruction,
            references: references)
    }

    private static func exactTensors() -> [PrimeLatinReplayTensorV1] {
        [
            .init(
                role: "token_embedding_weight",
                storageID: "token_embedding_and_output_projection",
                dimensions: [16_384, 8]),
            .init(
                role: "layer_0_attention_norm_scale",
                storageID: "layer_0_attention_norm_scale",
                dimensions: [8]),
            .init(
                role: "layer_0_attention_query_weight",
                storageID: "layer_0_attention_query_weight",
                dimensions: [8, 8]),
            .init(
                role: "layer_0_attention_key_weight",
                storageID: "layer_0_attention_key_weight",
                dimensions: [8, 8]),
            .init(
                role: "layer_0_attention_value_weight",
                storageID: "layer_0_attention_value_weight",
                dimensions: [8, 8]),
            .init(
                role: "layer_0_attention_output_weight",
                storageID: "layer_0_attention_output_weight",
                dimensions: [8, 8]),
            .init(
                role: "layer_0_feed_forward_norm_scale",
                storageID: "layer_0_feed_forward_norm_scale",
                dimensions: [8]),
            .init(
                role: "layer_0_feed_forward_gate_weight",
                storageID: "layer_0_feed_forward_gate_weight",
                dimensions: [16, 8]),
            .init(
                role: "layer_0_feed_forward_up_weight",
                storageID: "layer_0_feed_forward_up_weight",
                dimensions: [16, 8]),
            .init(
                role: "layer_0_feed_forward_down_weight",
                storageID: "layer_0_feed_forward_down_weight",
                dimensions: [8, 16]),
            .init(
                role: "final_norm_scale",
                storageID: "final_norm_scale",
                dimensions: [8]),
            .init(
                role: "output_projection_weight",
                storageID: "token_embedding_and_output_projection",
                dimensions: [16_384, 8]),
        ]
    }

    private static func exactDerivation(
        tensors: [PrimeLatinReplayTensorV1],
        candidateID: String,
        attribution: String
    ) -> PrimeLatinReplayDerivationV1 {
        var seen = Set<String>()
        var total: UInt64 = 0
        var uniqueCount: UInt64 = 0
        let terms = tensors.map { tensor -> PrimeLatinReplayTermV1 in
            let elements = tensor.dimensions.reduce(UInt64(1), *)
            let unique = seen.insert(tensor.storageID).inserted
            if unique {
                uniqueCount += 1
                total += elements
            }
            return .init(
                role: tensor.role,
                storageID: tensor.storageID,
                dimensions: tensor.dimensions,
                elementCount: elements,
                countedAsUniqueStorage: unique)
        }
        return PrimeLatinReplayDerivationV1(
            candidateSlug: candidateID,
            sourceAttribution: attribution,
            orderedTerms: terms,
            uniqueStorageCount: uniqueCount,
            totalParameterCount: total)
    }

    private static func makePlan(
        inputBindings: [PrimeLatinProposalIndependentReplayExpectedInputV1],
        gitArtifacts:
            [PrimeLatinProposalIndependentReplayGitArtifactReferenceV1],
        pairReceiptSHA256: String = String(repeating: "0", count: 64),
        pairReceiptByteCount: UInt64 = 0,
        candidateCatalogSHA256: String = String(repeating: "0", count: 64),
        candidateCatalogByteCount: UInt64 = 0,
        experimentManifestSHA256: String = String(repeating: "0", count: 64),
        experimentManifestByteCount: UInt64 = 0,
        declarationTargetClosureSHA256: String = String(repeating: "0", count: 64),
        declarationTargetClosureByteCount: UInt64 = 0,
        candidateIdentitySHA256: String = String(repeating: "0", count: 64),
        declarationBundleSHA256: String = String(repeating: "0", count: 64),
        declarationBundleByteCount: UInt64 = 0,
        candidateDeclarationSetSHA256: String = String(repeating: "0", count: 64),
        candidateDeclarationSetByteCount: UInt64 = 0,
        tokenizerBundleSHA256: String = String(repeating: "0", count: 64),
        tokenizerBundleByteCount: UInt64 = 0
    ) -> PrimeLatinProposalIndependentReplayExpectedPlanV1 {
        PrimeLatinProposalIndependentReplayExpectedPlanV1(
            pairReceiptSHA256: pairReceiptSHA256,
            pairReceiptByteCount: pairReceiptByteCount,
            sourceRepository: "Ergentics/ergentics-llm",
            sourceCommit: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
            sourceTree: "cccccccccccccccccccccccccccccccccccccccc",
            candidateCatalogSHA256: candidateCatalogSHA256,
            candidateCatalogByteCount: candidateCatalogByteCount,
            experimentManifestSHA256: experimentManifestSHA256,
            experimentManifestByteCount: experimentManifestByteCount,
            declarationTargetClosureSHA256:
                declarationTargetClosureSHA256,
            declarationTargetClosureByteCount:
                declarationTargetClosureByteCount,
            candidateIdentitySHA256: candidateIdentitySHA256,
            declarationBundleSHA256: declarationBundleSHA256,
            declarationBundleByteCount: declarationBundleByteCount,
            candidateDeclarationSetSHA256:
                candidateDeclarationSetSHA256,
            candidateDeclarationSetByteCount:
                candidateDeclarationSetByteCount,
            tokenizerBundleSHA256: tokenizerBundleSHA256,
            tokenizerBundleByteCount: tokenizerBundleByteCount,
            candidateID: "latin_structural_fixture_v1",
            sourceAttribution:
                "ergentics_codex_assisted_structural_fixture",
            tokenizerID: "ergentics_latin_bpe_v2",
            vocabularySize: 16_384,
            tokenizerCorpusLineCount: 2,
            orderedTensorCount: 12,
            uniqueParameterStorageCount: 11,
            totalParameterCount: 131_736,
            initializationAlgorithmID: "synthetic_sha256_domain_v1",
            initializationSeedDerivationSHA256:
                String(repeating: "2", count: 64),
            evaluationProcedureID: "synthetic_independent_replay_v1",
            prospectiveCorpusID: "synthetic_independent_replay_v1",
            optimizerSteps: 1,
            trainingTokens: 128,
            wallClockSeconds: 60,
            outputNamespace:
                "models/latin-prospective/synthetic-independent-replay-v1",
            inputBindings: inputBindings,
            gitArtifacts: gitArtifacts)
    }

    private static func makeReferences(
        reconstruction: PrimeLatinProposalIndependentReplayReconstructionV1,
        plan: PrimeLatinProposalIndependentReplayExpectedPlanV1
    ) -> PrimeLatinProposalIndependentReplayReferenceV1 {
        PrimeLatinProposalIndependentReplayReferenceV1(
            pairReceiptSHA256: plan.pairReceiptSHA256,
            pairReceiptByteCount: plan.pairReceiptByteCount,
            source: reconstruction.source,
            candidateCatalogSHA256: plan.candidateCatalogSHA256,
            candidateCatalogByteCount: plan.candidateCatalogByteCount,
            experimentManifestSHA256: plan.experimentManifestSHA256,
            experimentManifestByteCount: plan.experimentManifestByteCount,
            candidateDeclarationSetSHA256:
                plan.candidateDeclarationSetSHA256,
            candidateDeclarationSetByteCount:
                plan.candidateDeclarationSetByteCount,
            tokenizerBundleSHA256: plan.tokenizerBundleSHA256,
            tokenizerBundleByteCount: plan.tokenizerBundleByteCount,
            candidateIDs: reconstruction.candidateIDs,
            candidateIdentitySHA256s:
                reconstruction.candidateIdentitySHA256s,
            declarationBundleSHA256s:
                reconstruction.declarationBundleSHA256s,
            outputNamespace: plan.outputNamespace,
            snapshotArtifacts: plan.inputBindings,
            pairAuthorityExact: true,
            snapshotAuthorityExact: true,
            pairReceiptData: reconstruction.pairReceiptData,
            candidateCatalogData: reconstruction.candidateCatalogData,
            experimentManifestData: reconstruction.experimentManifestData,
            git: PrimeLatinProposalIndependentReplayGitReferenceV1(
                pairReceiptSHA256: plan.pairReceiptSHA256,
                sourceRepository: plan.sourceRepository,
                headCommit: plan.sourceCommit,
                headTree: plan.sourceTree,
                statusSHA256: sha256(Data()),
                statusByteCount: 0,
                snapshotArtifactCount: UInt64(plan.inputBindings.count),
                repositoryArtifacts: plan.gitArtifacts,
                authorityExact: true))
    }

    private static func copyReferences(
        _ value: PrimeLatinProposalIndependentReplayReferenceV1,
        pairReceiptData: Data? = nil,
        candidateCatalogData: Data? = nil,
        experimentManifestData: Data? = nil,
        gitHeadCommit: String? = nil,
        gitRepositoryArtifacts:
            [PrimeLatinProposalIndependentReplayGitArtifactReferenceV1]? = nil
    ) -> PrimeLatinProposalIndependentReplayReferenceV1 {
        PrimeLatinProposalIndependentReplayReferenceV1(
            pairReceiptSHA256: value.pairReceiptSHA256,
            pairReceiptByteCount: value.pairReceiptByteCount,
            source: value.source,
            candidateCatalogSHA256: value.candidateCatalogSHA256,
            candidateCatalogByteCount: value.candidateCatalogByteCount,
            experimentManifestSHA256: value.experimentManifestSHA256,
            experimentManifestByteCount: value.experimentManifestByteCount,
            candidateDeclarationSetSHA256:
                value.candidateDeclarationSetSHA256,
            candidateDeclarationSetByteCount:
                value.candidateDeclarationSetByteCount,
            tokenizerBundleSHA256: value.tokenizerBundleSHA256,
            tokenizerBundleByteCount: value.tokenizerBundleByteCount,
            candidateIDs: value.candidateIDs,
            candidateIdentitySHA256s: value.candidateIdentitySHA256s,
            declarationBundleSHA256s: value.declarationBundleSHA256s,
            outputNamespace: value.outputNamespace,
            snapshotArtifacts: value.snapshotArtifacts,
            pairAuthorityExact: value.pairAuthorityExact,
            snapshotAuthorityExact: value.snapshotAuthorityExact,
            pairReceiptData: pairReceiptData ?? value.pairReceiptData,
            candidateCatalogData:
                candidateCatalogData ?? value.candidateCatalogData,
            experimentManifestData:
                experimentManifestData ?? value.experimentManifestData,
            git: PrimeLatinProposalIndependentReplayGitReferenceV1(
                pairReceiptSHA256: value.git.pairReceiptSHA256,
                sourceRepository: value.git.sourceRepository,
                headCommit: gitHeadCommit ?? value.git.headCommit,
                headTree: value.git.headTree,
                statusSHA256: value.git.statusSHA256,
                statusByteCount: value.git.statusByteCount,
                snapshotArtifactCount: value.git.snapshotArtifactCount,
                repositoryArtifacts:
                    gitRepositoryArtifacts ?? value.git.repositoryArtifacts,
                authorityExact: value.git.authorityExact))
    }

    private static func rebinding(
        fixture: Fixture,
        role: String,
        data: Data
    ) -> ReboundFixture {
        rebinding(fixture: fixture, replacements: [role: data])
    }

    private static func rebinding(
        fixture: Fixture,
        replacements: [String: Data]
    ) -> ReboundFixture {
        var artifacts = fixture.originalInputs.artifacts
        var inputs = fixture.plan.inputBindings
        var git = fixture.plan.gitArtifacts
        for (role, data) in replacements {
            let index = artifacts.firstIndex { $0.role == role }!
            let old = artifacts[index]
            let replacement =
                PrimeLatinProposalIndependentReplayOriginalInputV1(
                    role: old.role,
                    scope: old.scope,
                    relativePath: old.relativePath,
                    sha256: sha256(data),
                    byteCount: UInt64(data.count),
                    data: data)
            artifacts[index] = replacement
            inputs[index] =
                PrimeLatinProposalIndependentReplayExpectedInputV1(
                    role: replacement.role,
                    scope: replacement.scope,
                    relativePath: replacement.relativePath,
                    sha256: replacement.sha256,
                    byteCount: replacement.byteCount)
            if index < git.count {
                git[index] =
                    PrimeLatinProposalIndependentReplayGitArtifactReferenceV1(
                role: replacement.role,
                relativePath: replacement.relativePath,
                gitBlobOID: gitBlobOID(data),
                sha256: replacement.sha256,
                byteCount: replacement.byteCount)
            }
        }
        return ReboundFixture(
            originalInputs: .init(artifacts: artifacts),
            plan: copyPlan(fixture.plan, inputBindings: inputs, gitArtifacts: git))
    }

    private static func copyPlan(
        _ value: PrimeLatinProposalIndependentReplayExpectedPlanV1,
        inputBindings:
            [PrimeLatinProposalIndependentReplayExpectedInputV1],
        gitArtifacts:
            [PrimeLatinProposalIndependentReplayGitArtifactReferenceV1]
    ) -> PrimeLatinProposalIndependentReplayExpectedPlanV1 {
        PrimeLatinProposalIndependentReplayExpectedPlanV1(
            pairReceiptSHA256: value.pairReceiptSHA256,
            pairReceiptByteCount: value.pairReceiptByteCount,
            sourceRepository: value.sourceRepository,
            sourceCommit: value.sourceCommit,
            sourceTree: value.sourceTree,
            candidateCatalogSHA256: value.candidateCatalogSHA256,
            candidateCatalogByteCount: value.candidateCatalogByteCount,
            experimentManifestSHA256: value.experimentManifestSHA256,
            experimentManifestByteCount: value.experimentManifestByteCount,
            declarationTargetClosureSHA256:
                value.declarationTargetClosureSHA256,
            declarationTargetClosureByteCount:
                value.declarationTargetClosureByteCount,
            candidateIdentitySHA256: value.candidateIdentitySHA256,
            declarationBundleSHA256: value.declarationBundleSHA256,
            declarationBundleByteCount: value.declarationBundleByteCount,
            candidateDeclarationSetSHA256:
                value.candidateDeclarationSetSHA256,
            candidateDeclarationSetByteCount:
                value.candidateDeclarationSetByteCount,
            tokenizerBundleSHA256: value.tokenizerBundleSHA256,
            tokenizerBundleByteCount: value.tokenizerBundleByteCount,
            candidateID: value.candidateID,
            sourceAttribution: value.sourceAttribution,
            tokenizerID: value.tokenizerID,
            vocabularySize: value.vocabularySize,
            tokenizerCorpusLineCount: value.tokenizerCorpusLineCount,
            orderedTensorCount: value.orderedTensorCount,
            uniqueParameterStorageCount: value.uniqueParameterStorageCount,
            totalParameterCount: value.totalParameterCount,
            initializationAlgorithmID: value.initializationAlgorithmID,
            initializationSeedDerivationSHA256:
                value.initializationSeedDerivationSHA256,
            evaluationProcedureID: value.evaluationProcedureID,
            prospectiveCorpusID: value.prospectiveCorpusID,
            optimizerSteps: value.optimizerSteps,
            trainingTokens: value.trainingTokens,
            wallClockSeconds: value.wallClockSeconds,
            outputNamespace: value.outputNamespace,
            inputBindings: inputBindings,
            gitArtifacts: gitArtifacts)
    }

    private static func assertObservation(
        _ value: PrimeLatinProposalIndependentReplayObservationV1,
        fixture: Fixture,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(
            value.schema,
            "ergentics_prime_latin_proposal_v3_independent_replay_observation_v1",
            file: file, line: line)
        XCTAssertEqual(value.outcome, "abstain", file: file, line: line)
        XCTAssertEqual(
            value.verificationScope,
            "prime_owned_independent_typed_reconstruction_from_one_git_bound_" +
                "retained_twenty_one_original_input_snapshot_and_byte_exact_" +
                "catalog_experiment_cross_check_only_non_authorizing",
            file: file, line: line)
        XCTAssertEqual(
            value.replayPolicyID,
            "prime_latin_v3_retained_original_input_independent_reconstruction_v1",
            file: file, line: line)
        XCTAssertEqual(
            value.pairReceiptSHA256, fixture.plan.pairReceiptSHA256,
            file: file, line: line)
        XCTAssertEqual(
            value.pairReceiptByteCount, fixture.plan.pairReceiptByteCount,
            file: file, line: line)
        XCTAssertEqual(value.producerRepository, fixture.plan.sourceRepository)
        XCTAssertEqual(value.producerCommit, fixture.plan.sourceCommit)
        XCTAssertEqual(value.producerTree, fixture.plan.sourceTree)
        XCTAssertEqual(
            value.candidateCatalogSHA256,
            fixture.plan.candidateCatalogSHA256)
        XCTAssertEqual(
            value.candidateCatalogByteCount,
            fixture.plan.candidateCatalogByteCount)
        XCTAssertEqual(
            value.experimentManifestSHA256,
            fixture.plan.experimentManifestSHA256)
        XCTAssertEqual(
            value.experimentManifestByteCount,
            fixture.plan.experimentManifestByteCount)
        XCTAssertEqual(value.candidateIDs, [fixture.plan.candidateID])
        XCTAssertEqual(
            value.candidateIdentitySHA256s,
            [fixture.plan.candidateIdentitySHA256])
        XCTAssertEqual(
            value.declarationBundleSHA256s,
            [fixture.plan.declarationBundleSHA256])
        XCTAssertEqual(value.inputBindingCount, 21)
        XCTAssertEqual(
            value.retainedOriginalInputByteCount,
            fixture.plan.inputBindings.reduce(into: UInt64(0)) {
                $0 += $1.byteCount
            })
        XCTAssertEqual(value.optimizerSteps, 1)
        XCTAssertEqual(value.trainingTokens, 128)
        XCTAssertEqual(value.wallClockSeconds, 60)
        XCTAssertEqual(value.outputNamespace, fixture.plan.outputNamespace)
        XCTAssertEqual(value.orderedTensorCount, 12)
        XCTAssertEqual(value.uniqueParameterStorageCount, 11)
        XCTAssertEqual(value.totalParameterCount, 131_736)
        XCTAssertEqual(value.authority, .init())
    }

    private static func canonical<Value: Encodable>(_ value: Value) throws
        -> Data
    {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(value)
    }

    private static func canonicalLine<Value: Encodable>(_ value: Value) throws
        -> Data
    {
        var data = try canonical(value)
        data.append(0x0a)
        return data
    }

    private static func json(_ value: Any) throws -> Data {
        try JSONSerialization.data(
            withJSONObject: value,
            options: [.sortedKeys, .withoutEscapingSlashes])
    }

    private static func mutatedJSONObject(
        _ data: Data,
        mutation: (inout [String: Any]) -> Void
    ) throws -> Data {
        var root = try JSONSerialization.jsonObject(with: data)
            as! [String: Any]
        mutation(&root)
        return try json(root)
    }

    private static func sha256(_ data: Data) -> String {
        hex(SHA256.hash(data: data))
    }

    private static func gitBlobOID(_ data: Data) -> String {
        var framed = Data("blob \(data.count)\u{0}".utf8)
        framed.append(data)
        return hex(Insecure.SHA1.hash(data: framed))
    }

    private static func hex<Digest: Sequence>(_ digest: Digest) -> String
    where Digest.Element == UInt8 {
        digest.map { String(format: "%02x", $0) }.joined()
    }

    private static func flipped(_ data: Data) -> Data {
        precondition(!data.isEmpty)
        var result = data
        result[0] ^= 0x01
        return result
    }
}
