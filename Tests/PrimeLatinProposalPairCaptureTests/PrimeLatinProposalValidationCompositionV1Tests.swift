import Foundation
import XCTest

@testable import PrimeLatinProposalValidationComposition

final class PrimeLatinProposalValidationCompositionV1Tests: XCTestCase {
    func testAuthorityBoundaryIsExactAndNonAuthorizing() {
        let authority = PrimeLatinProposalValidationCompositionCaptureV1
            .makeAuthorityForTesting()

        XCTAssertEqual(
            authority.disposition,
            "abstain_live_producer_revalidation_and_independent_prime_replay_composed_proposal_policy_runtime_decoder_initialization_evaluation_trial_decision_and_publication_authority_absent")

        let requiredTrue: [(String, Bool)] = [
            ("producerRevalidationCaptureAndRecaptureComplete",
             authority.producerRevalidationCaptureAndRecaptureComplete),
            ("independentReplayCaptureAndRecaptureComplete",
             authority.independentReplayCaptureAndRecaptureComplete),
            ("cooperativeSameRequestRootSequenceComplete",
             authority.cooperativeSameRequestRootSequenceComplete),
            ("producerRevalidationAuthorityBoundaryExact",
             authority.producerRevalidationAuthorityBoundaryExact),
            ("independentReplayAuthorityBoundaryExact",
             authority.independentReplayAuthorityBoundaryExact),
            ("exactPairReceiptCrossBindingMatched",
             authority.exactPairReceiptCrossBindingMatched),
            ("exactProducerSourceCrossBindingMatched",
             authority.exactProducerSourceCrossBindingMatched),
            ("exactCandidateCatalogCrossBindingMatched",
             authority.exactCandidateCatalogCrossBindingMatched),
            ("exactExperimentManifestCrossBindingMatched",
             authority.exactExperimentManifestCrossBindingMatched),
            ("exactCandidateDeclarationSetCrossBindingMatched",
             authority.exactCandidateDeclarationSetCrossBindingMatched),
            ("exactTokenizerBundleCrossBindingMatched",
             authority.exactTokenizerBundleCrossBindingMatched),
            ("exactCandidateIdentityInventoryCrossBindingMatched",
             authority.exactCandidateIdentityInventoryCrossBindingMatched),
            ("exactTwentyOneInputBindingCountCrossBindingMatched",
             authority.exactTwentyOneInputBindingCountCrossBindingMatched),
            ("exactTwentyOneOriginalInputBytesRetained",
             authority.exactTwentyOneOriginalInputBytesRetained),
            ("exactTrialBudgetCrossBindingMatched",
             authority.exactTrialBudgetCrossBindingMatched),
            ("exactOutputNamespaceCrossBindingMatched",
             authority.exactOutputNamespaceCrossBindingMatched),
            ("outputNamespaceAbsenceVerified",
             authority.outputNamespaceAbsenceVerified),
            ("referencedInputSnapshotAvailable",
             authority.referencedInputSnapshotAvailable),
            ("referencedArtifactBytesAvailable",
             authority.referencedArtifactBytesAvailable),
            ("llmGitStateIndependentlyObserved",
             authority.llmGitStateIndependentlyObserved),
            ("revalidatorToolSourceIndependentlyObserved",
             authority.revalidatorToolSourceIndependentlyObserved),
            ("liveProducerWorkspaceRevalidationComplete",
             authority.liveProducerWorkspaceRevalidationComplete),
            ("independentPrimeReplayComplete",
             authority.independentPrimeReplayComplete),
            ("validationCompositionComplete",
             authority.validationCompositionComplete),
        ]
        XCTAssertEqual(requiredTrue.count, 24)
        for (field, value) in requiredTrue {
            XCTAssertTrue(value, "expected true authority field: \(field)")
        }

        let requiredFalse: [(String, Bool)] = [
            ("atomicCrossProcessSnapshotEstablished",
             authority.atomicCrossProcessSnapshotEstablished),
            ("compilerCryptographicallyAuthenticated",
             authority.compilerCryptographicallyAuthenticated),
            ("externalSourceToBinaryAttestationAvailable",
             authority.externalSourceToBinaryAttestationAvailable),
            ("originRemoteCryptographicallyAuthenticated",
             authority.originRemoteCryptographicallyAuthenticated),
            ("ignoredWorkspaceBytesObserved",
             authority.ignoredWorkspaceBytesObserved),
            ("declarationSourceSemanticsIndependentlyVerified",
             authority.declarationSourceSemanticsIndependentlyVerified),
            ("tokenizerModelSemanticsIndependentlyValidated",
             authority.tokenizerModelSemanticsIndependentlyValidated),
            ("tokenizerTrainingReplayComplete",
             authority.tokenizerTrainingReplayComplete),
            ("evaluationExecutionComplete",
             authority.evaluationExecutionComplete),
            ("selectionObservationComplete",
             authority.selectionObservationComplete),
            ("durableInputSnapshotPublished",
             authority.durableInputSnapshotPublished),
            ("durableGitObservationPublished",
             authority.durableGitObservationPublished),
            ("durableProducerRevalidationObservationPublished",
             authority.durableProducerRevalidationObservationPublished),
            ("durableIndependentReplayObservationPublished",
             authority.durableIndependentReplayObservationPublished),
            ("durableValidationCompositionObservationPublished",
             authority.durableValidationCompositionObservationPublished),
            ("runtimeDecoderImplementationAvailable",
             authority.runtimeDecoderImplementationAvailable),
            ("runtimeDependencyClosureEstablished",
             authority.runtimeDependencyClosureEstablished),
            ("runtimeInitializationEstablished",
             authority.runtimeInitializationEstablished),
            ("primeProposalPolicyEstablished",
             authority.primeProposalPolicyEstablished),
            ("primeProposalPacketProduced",
             authority.primeProposalPacketProduced),
            ("primeTrialAuthorizationProduced",
             authority.primeTrialAuthorizationProduced),
            ("primeDecisionReceiptProduced",
             authority.primeDecisionReceiptProduced),
            ("candidateSelectionAuthorized",
             authority.candidateSelectionAuthorized),
            ("trialExecutionAuthorized",
             authority.trialExecutionAuthorized),
            ("furtherTrainingAuthorized",
             authority.furtherTrainingAuthorized),
            ("promotionAuthorized",
             authority.promotionAuthorized),
            ("productUseAuthorized",
             authority.productUseAuthorized),
            ("publicationAuthorized",
             authority.publicationAuthorized),
            ("proposalPairPublicationPerformedByThisComposition",
             authority.proposalPairPublicationPerformedByThisComposition),
            ("primeDurableReceiptPublished",
             authority.primeDurableReceiptPublished),
        ]
        XCTAssertEqual(requiredFalse.count, 30)
        for (field, value) in requiredFalse {
            XCTAssertFalse(value, "expected false authority field: \(field)")
        }
    }

    func testNormalizedEngineCrossBindsTheExactFinalChildren() throws {
        let fixture = Self.exactProjections()
        let binding = try PrimeLatinProposalValidationCompositionEngineV1
            .validate(producer: fixture.producer, replay: fixture.replay)

        XCTAssertEqual(
            binding.pairReceiptSHA256,
            "6c47d6ff17d72e48873c9f4ae9ce0a0fe7e57dea8e25db144c5f1d8d42761ff7")
        XCTAssertEqual(binding.pairReceiptByteCount, 1_833)
        XCTAssertEqual(binding.producerRepository, "Ergentics/ergentics-llm")
        XCTAssertEqual(
            binding.producerCommit,
            "776c412e3f10e8bf4e33cd0ae60787d9ca6b5831")
        XCTAssertEqual(
            binding.producerTree,
            "c1f41758aea2860ab06039776f5ea0403dff1b61")
        XCTAssertEqual(
            binding.candidateCatalogSHA256,
            "12387e11fdbf68ab5b76cad79c6c958e9b82ddeca1cb588b844918a2ab0dc6b4")
        XCTAssertEqual(binding.candidateCatalogByteCount, 20_803)
        XCTAssertEqual(
            binding.experimentManifestSHA256,
            "8436ab6d656b2393792c564d0bdb9a25d1ade9f5c457ad3b96cf99bacc708a76")
        XCTAssertEqual(binding.experimentManifestByteCount, 3_364)
        XCTAssertEqual(
            binding.candidateDeclarationSetSHA256,
            "45c787dba8c538794cbaf7cb90acb4528d2dedcaf666a1f0da151ca236138881")
        XCTAssertEqual(binding.candidateDeclarationSetByteCount, 14_860)
        XCTAssertEqual(
            binding.tokenizerBundleSHA256,
            "9fa3b6eea42a9c4c13ec1ecda2309ec4c35b3022638ae61a08dd2f0fcb9b074c")
        XCTAssertEqual(binding.tokenizerBundleByteCount, 2_930)
        XCTAssertEqual(binding.candidateIDs, ["latin_structural_fixture_v1"])
        XCTAssertEqual(
            binding.candidateIdentitySHA256s,
            ["64a288b62cdef276923eb72e5cc4d209a7195526408414fc5167522151481265"])
        XCTAssertEqual(
            binding.declarationBundleSHA256s,
            ["6f07896e50b2b530ea5f5924859d1e66bf9880366c16cf37832138a0e6c7f4bd"])
        XCTAssertEqual(binding.inputBindingCount, 21)
        XCTAssertEqual(binding.retainedOriginalInputByteCount, 8_084_712)
        XCTAssertEqual(binding.optimizerSteps, 1)
        XCTAssertEqual(binding.trainingTokens, 128)
        XCTAssertEqual(binding.wallClockSeconds, 60)
        XCTAssertEqual(
            binding.outputNamespace,
            "models/latin-prospective/structural-fixture-v3-776c412e")
        XCTAssertEqual(binding.orderedTensorCount, 12)
        XCTAssertEqual(binding.uniqueParameterStorageCount, 11)
        XCTAssertEqual(binding.totalParameterCount, 131_736)
    }

    func testEveryNormalizedScalarAndArrayFamilyFailsClosedOnMutation() {
        typealias Projection =
            PrimeLatinProposalValidationCompositionChildProjectionV1
        let mutations: [(String, (inout Projection) -> Void)] = [
            ("pair receipt hash", { $0.pairReceiptSHA256 = Self.otherDigest }),
            ("pair receipt count", { $0.pairReceiptByteCount += 1 }),
            ("producer repository", { $0.producerRepository += "-other" }),
            ("producer commit", { $0.producerCommit = Self.otherCommit }),
            ("producer tree", { $0.producerTree = Self.otherCommit }),
            ("catalog hash", { $0.candidateCatalogSHA256 = Self.otherDigest }),
            ("catalog count", { $0.candidateCatalogByteCount += 1 }),
            ("experiment hash", {
                $0.experimentManifestSHA256 = Self.otherDigest
            }),
            ("experiment count", { $0.experimentManifestByteCount += 1 }),
            ("declaration set hash", {
                $0.candidateDeclarationSetSHA256 = Self.otherDigest
            }),
            ("declaration set count", {
                $0.candidateDeclarationSetByteCount += 1
            }),
            ("tokenizer hash", { $0.tokenizerBundleSHA256 = Self.otherDigest }),
            ("tokenizer count", { $0.tokenizerBundleByteCount += 1 }),
            ("candidate IDs", { $0.candidateIDs.append("other") }),
            ("candidate identity hashes", {
                $0.candidateIdentitySHA256s.append(Self.otherDigest)
            }),
            ("declaration bundle hashes", {
                $0.declarationBundleSHA256s.append(Self.otherDigest)
            }),
            ("input binding count", { $0.inputBindingCount += 1 }),
            ("retained original bytes", {
                $0.retainedOriginalInputByteCount += 1
            }),
            ("optimizer steps", { $0.optimizerSteps += 1 }),
            ("training tokens", { $0.trainingTokens += 1 }),
            ("wall clock", { $0.wallClockSeconds += 1 }),
            ("output namespace", { $0.outputNamespace += "-other" }),
            ("ordered tensor count", { $0.orderedTensorCount += 1 }),
            ("unique storage count", {
                $0.uniqueParameterStorageCount += 1
            }),
            ("parameter count", { $0.totalParameterCount += 1 }),
        ]
        XCTAssertEqual(mutations.count, 25)

        for (name, mutate) in mutations {
            let fixture = Self.exactProjections()
            var changedProducer = fixture.producer
            mutate(&changedProducer)
            XCTAssertThrowsError(
                try PrimeLatinProposalValidationCompositionEngineV1.validate(
                    producer: changedProducer,
                    replay: fixture.replay),
                "producer mutation accepted: \(name)")

            var changedReplay = fixture.replay
            mutate(&changedReplay)
            XCTAssertThrowsError(
                try PrimeLatinProposalValidationCompositionEngineV1.validate(
                    producer: fixture.producer,
                    replay: changedReplay),
                "replay mutation accepted: \(name)")
        }
    }

    func testChildKindsAuthorityBoundariesAndRequestRootsAreExact() {
        let fixture = Self.exactProjections()

        var wrongProducerKind = fixture.producer
        wrongProducerKind.kind = .replay
        Self.assertRejected(
            producer: wrongProducerKind,
            replay: fixture.replay,
            expected: .invalidChildObservation("producer_kind"))

        var wrongReplayKind = fixture.replay
        wrongReplayKind.kind = .producer
        Self.assertRejected(
            producer: fixture.producer,
            replay: wrongReplayKind,
            expected: .invalidChildObservation("replay_kind"))

        var producerAuthorityDrift = fixture.producer
        producerAuthorityDrift.childContractExact = false
        Self.assertRejected(
            producer: producerAuthorityDrift,
            replay: fixture.replay,
            expected: .invalidChildObservation("producer_authority"))

        var replayAuthorityDrift = fixture.replay
        replayAuthorityDrift.childContractExact = false
        Self.assertRejected(
            producer: fixture.producer,
            replay: replayAuthorityDrift,
            expected: .invalidChildObservation("replay_authority"))

        for mutate in [
            { (value: inout Projection) in value.requestLabRoot = "" },
            { (value: inout Projection) in
                value.requestProducerRepositoryRoot = ""
            },
            { (value: inout Projection) in
                value.requestLabRoot = "/synthetic/other-lab"
            },
            { (value: inout Projection) in
                value.requestProducerRepositoryRoot =
                    "/synthetic/other-producer"
            },
        ] {
            var replay = fixture.replay
            mutate(&replay)
            Self.assertRejected(
                producer: fixture.producer,
                replay: replay,
                expected: .crossBindingMismatch("same_request_roots"))
        }
    }

    func testSyntheticSequenceIsExactlyReplayProducerReplayAndRepeatable()
        throws
    {
        let fixture = Self.exactProjections()
        var order = [String]()
        let first = try PrimeLatinProposalValidationCompositionCaptureV1
            .validateSequenceForTesting(
                initialProducer: fixture.producer,
                initialReplay: fixture.replay,
                recaptureReplay: {
                    order.append("replay")
                    return fixture.replay
                },
                recaptureProducer: {
                    order.append("producer")
                    return fixture.producer
                })
        XCTAssertEqual(order, ["replay", "producer", "replay"])

        order.removeAll()
        let recaptured = try PrimeLatinProposalValidationCompositionCaptureV1
            .validateSequenceForTesting(
                initialProducer: fixture.producer,
                initialReplay: fixture.replay,
                recaptureReplay: {
                    order.append("replay")
                    return fixture.replay
                },
                recaptureProducer: {
                    order.append("producer")
                    return fixture.producer
                })
        XCTAssertEqual(order, ["replay", "producer", "replay"])
        XCTAssertEqual(recaptured, first)
    }

    func testReplayBeforeProducerAndReplayAfterDriftAllFailClosed() {
        let fixture = Self.exactProjections()

        do {
            var replayCalls = 0
            var changed = fixture.replay
            changed.candidateCatalogByteCount += 1
            XCTAssertThrowsError(
                try PrimeLatinProposalValidationCompositionCaptureV1
                    .validateSequenceForTesting(
                        initialProducer: fixture.producer,
                        initialReplay: fixture.replay,
                        recaptureReplay: {
                            replayCalls += 1
                            return replayCalls == 1 ? changed : fixture.replay
                        },
                        recaptureProducer: { fixture.producer })
            ) { error in
                XCTAssertEqual(
                    error as?
                        PrimeLatinProposalValidationCompositionErrorV1,
                    .captureChanged)
            }
            XCTAssertEqual(replayCalls, 2)
        }

        do {
            var changed = fixture.producer
            changed.outputNamespace += "-drift"
            XCTAssertThrowsError(
                try PrimeLatinProposalValidationCompositionCaptureV1
                    .validateSequenceForTesting(
                        initialProducer: fixture.producer,
                        initialReplay: fixture.replay,
                        recaptureReplay: { fixture.replay },
                        recaptureProducer: { changed })
            ) { error in
                XCTAssertEqual(
                    error as?
                        PrimeLatinProposalValidationCompositionErrorV1,
                    .captureChanged)
            }
        }

        do {
            var replayCalls = 0
            var changed = fixture.replay
            changed.candidateIDs.append("drift")
            XCTAssertThrowsError(
                try PrimeLatinProposalValidationCompositionCaptureV1
                    .validateSequenceForTesting(
                        initialProducer: fixture.producer,
                        initialReplay: fixture.replay,
                        recaptureReplay: {
                            replayCalls += 1
                            return replayCalls == 2 ? changed : fixture.replay
                        },
                        recaptureProducer: { fixture.producer })
            ) { error in
                XCTAssertEqual(
                    error as?
                        PrimeLatinProposalValidationCompositionErrorV1,
                    .captureChanged)
            }
            XCTAssertEqual(replayCalls, 2)
        }
    }

    func testPublicRawChildPathRetainsAndExhaustivelyProjectsBothChildren()
        throws
    {
        let root = URL(
            fileURLWithPath: FileManager.default.currentDirectoryPath,
            isDirectory: true)
        let source = try String(
            contentsOf: root.appendingPathComponent(
                "Sources/PrimeLatinProposalValidationComposition/" +
                    "PrimeLatinProposalValidationCompositionV1.swift"),
            encoding: .utf8)

        for exact in [
            "ergentics_prime_latin_proposal_v3_validation_composition_observation_v1",
            "outcome = \"abstain\"",
            "prime_latin_v3_producer_revalidation_independent_replay_composition_v1",
            "prime_owned_cooperative_same_request_root_sequence_composing_one_live_producer_revalidation_observation_and_one_independent_replay_observation_with_exact_shared_identity_hash_count_budget_and_output_namespace_cross_bindings_only_non_authorizing",
            "abstain_live_producer_revalidation_and_independent_prime_replay_composed_proposal_policy_runtime_decoder_initialization_evaluation_trial_decision_and_publication_authority_absent",
            "producerRevalidationObservation = producer",
            "independentReplayObservation = replay",
            "producerCapture = try .capture(request: request)",
            "labRoot: request.labRoot",
            "llmRepositoryRoot: request.producerRepositoryRoot",
            "guard current == observation",
        ] {
            XCTAssertTrue(source.contains(exact), "missing raw-path anchor: \(exact)")
        }

        let producerProjection = Self.sourceSection(
            source,
            from: "private static func projectProducer(",
            to: "private static func projectReplay(")
        let replayProjection = Self.sourceSection(
            source,
            from: "private static func projectReplay(",
            to: "private static func producerContractExact(")
        for field in [
            "pairReceiptSHA256", "producerRepository", "producerCommit",
            "producerTree", "candidateCatalogSHA256",
            "candidateCatalogByteCount", "experimentManifestSHA256",
            "experimentManifestByteCount",
            "candidateDeclarationSetSHA256",
            "candidateDeclarationSetByteCount", "tokenizerBundleSHA256",
            "tokenizerBundleByteCount", "candidateIDs",
            "candidateIdentitySHA256s", "declarationBundleSHA256s",
            "inputBindingCount", "optimizerSteps", "trainingTokens",
            "wallClockSeconds", "outputNamespace",
        ] {
            XCTAssertTrue(
                producerProjection.contains("value.\(field)"),
                "producer raw projection omits \(field)")
        }
        for policyField in [
            "pairReceiptByteCount", "retainedOriginalInputByteCount",
            "orderedTensorCount", "uniqueParameterStorageCount",
            "totalParameterCount",
        ] {
            XCTAssertTrue(
                producerProjection.contains("expected.\(policyField)"),
                "producer policy projection omits \(policyField)")
        }
        for field in [
            "pairReceiptSHA256", "pairReceiptByteCount",
            "producerRepository", "producerCommit", "producerTree",
            "candidateCatalogSHA256", "candidateCatalogByteCount",
            "experimentManifestSHA256", "experimentManifestByteCount",
            "candidateDeclarationSetSHA256",
            "candidateDeclarationSetByteCount", "tokenizerBundleSHA256",
            "tokenizerBundleByteCount", "candidateIDs",
            "candidateIdentitySHA256s", "declarationBundleSHA256s",
            "inputBindingCount", "retainedOriginalInputByteCount",
            "optimizerSteps", "trainingTokens", "wallClockSeconds",
            "outputNamespace", "orderedTensorCount",
            "uniqueParameterStorageCount", "totalParameterCount",
        ] {
            XCTAssertTrue(
                replayProjection.contains("value.\(field)"),
                "replay raw projection omits \(field)")
        }

        let producerContract = Self.sourceSection(
            source,
            from: "private static func producerContractExact(",
            to: "private static func replayContractExact(")
            .filter { !$0.isWhitespace }
        let replayContract = Self.sourceSection(
            source,
            from: "private static func replayContractExact(",
            to: nil)
            .filter { !$0.isWhitespace }

        let producerTrueAuthority = [
            "pairCaptureAndRecaptureComplete",
            "inputSnapshotCaptureAndRecaptureComplete",
            "producerGitObservationComplete",
            "exactMergedRevalidatorSourceObserved",
            "exactRevalidatorSourceClosureObserved",
            "compilerIdentityObserved",
            "localExactSourceClosureBuildObserved",
            "revalidatorExecutableBuiltFromObservedSourceClosure",
            "revalidatorExecutableIdentityStable",
            "boundedFreshProcessObservationComplete",
            "canonicalRevalidationObservationDecoded",
            "expectedPairReceiptCrossBindingValidated",
            "exactTwentyOneInputBindingsCrossBound",
            "canonicalHashChainCrossBindingsMatched",
            "repeatedProducerProcessObservationUnchanged",
            "outputNamespaceAbsenceVerified",
            "llmGitStateIndependentlyObserved",
            "revalidatorToolSourceIndependentlyObserved",
            "liveProducerWorkspaceRevalidationComplete",
        ]
        let producerFalseAuthority = [
            "compilerCryptographicallyAuthenticated",
            "externalSourceToBinaryAttestationAvailable",
            "originRemoteCryptographicallyAuthenticated",
            "ignoredWorkspaceBytesObserved",
            "durableInputSnapshotPublished", "durableGitObservationPublished",
            "durableRevalidationObservationPublished",
            "independentPrimeReplayComplete",
            "runtimeDecoderImplementationAvailable",
            "runtimeDependencyClosureEstablished",
            "runtimeInitializationEstablished", "primeProposalPacketProduced",
            "primeTrialAuthorizationProduced", "primeDecisionReceiptProduced",
            "candidateSelectionAuthorized", "trialExecutionAuthorized",
            "furtherTrainingAuthorized", "promotionAuthorized",
            "productUseAuthorized", "publicationAuthorized",
            "proposalPairPublicationPerformedByThisObservation",
            "primeDurableReceiptPublished",
        ]
        XCTAssertEqual(producerTrueAuthority.count, 19)
        XCTAssertEqual(producerFalseAuthority.count, 22)
        Self.assertAuthorityReferences(
            producerContract,
            trueFields: producerTrueAuthority,
            falseFields: producerFalseAuthority,
            label: "producer")

        let replayTrueAuthority = [
            "pairCaptureAndRecaptureComplete",
            "inputSnapshotCaptureAndRecaptureComplete",
            "producerGitObservationComplete",
            "exactTwentyOneOriginalInputBindingsCrossBound",
            "exactTwentyOneOriginalInputBytesRetained",
            "retainedOriginalInputHashCountRecomputationComplete",
            "independentTokenizerBundleReconstructionComplete",
            "independentDeclarationTargetClosureReconstructionComplete",
            "independentCandidateIdentityReconstructionComplete",
            "independentCandidateDeclarationSetReconstructionComplete",
            "independentCandidateCatalogReconstructionComplete",
            "independentExperimentManifestReconstructionComplete",
            "canonicalCandidateCatalogBytesMatched",
            "canonicalExperimentManifestBytesMatched",
            "canonicalHashChainRecomputationComplete",
            "outputNamespaceAbsenceVerified",
            "referencedInputSnapshotAvailable",
            "referencedArtifactBytesAvailable",
            "llmGitStateIndependentlyObserved", "independentPrimeReplayComplete",
        ]
        let replayFalseAuthority = [
            "ergenticsLatinProducerModuleImported",
            "ergenticsLatinProducerFunctionInvoked",
            "ergenticsLatinProducerSourceUsedAsReplayImplementation",
            "liveProducerWorkspaceRevalidationComplete",
            "revalidatorToolSourceIndependentlyObserved",
            "originRemoteCryptographicallyAuthenticated",
            "ignoredWorkspaceBytesObserved",
            "declarationSourceSemanticsIndependentlyVerified",
            "tokenizerModelSemanticsIndependentlyValidated",
            "tokenizerTrainingReplayComplete", "evaluationExecutionComplete",
            "selectionObservationComplete", "durableInputSnapshotPublished",
            "durableGitObservationPublished",
            "durableIndependentReplayObservationPublished",
            "runtimeDecoderImplementationAvailable",
            "runtimeDependencyClosureEstablished",
            "runtimeInitializationEstablished", "primeProposalPacketProduced",
            "primeTrialAuthorizationProduced", "primeDecisionReceiptProduced",
            "candidateSelectionAuthorized", "trialExecutionAuthorized",
            "furtherTrainingAuthorized", "promotionAuthorized",
            "productUseAuthorized", "publicationAuthorized",
            "proposalPairPublicationPerformedByThisObservation",
            "primeDurableReceiptPublished",
        ]
        XCTAssertEqual(replayTrueAuthority.count, 20)
        XCTAssertEqual(replayFalseAuthority.count, 29)
        Self.assertAuthorityReferences(
            replayContract,
            trueFields: replayTrueAuthority,
            falseFields: replayFalseAuthority,
            label: "replay")
    }

    private typealias Projection =
        PrimeLatinProposalValidationCompositionChildProjectionV1

    private static let otherDigest = String(repeating: "0", count: 64)
    private static let otherCommit = String(repeating: "0", count: 40)

    private static func exactProjections()
        -> (producer: Projection, replay: Projection)
    {
        (
            producer: PrimeLatinProposalValidationCompositionCaptureV1
                .exactProducerProjectionForTesting(),
            replay: PrimeLatinProposalValidationCompositionCaptureV1
                .exactReplayProjectionForTesting()
        )
    }

    private static func assertRejected(
        producer: Projection,
        replay: Projection,
        expected: PrimeLatinProposalValidationCompositionErrorV1,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(
            try PrimeLatinProposalValidationCompositionEngineV1.validate(
                producer: producer,
                replay: replay),
            file: file,
            line: line
        ) { error in
            XCTAssertEqual(
                error as? PrimeLatinProposalValidationCompositionErrorV1,
                expected,
                file: file,
                line: line)
        }
    }

    private static func sourceSection(
        _ source: String,
        from start: String,
        to end: String?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> String {
        guard let lower = source.range(of: start)?.lowerBound else {
            XCTFail("missing source-section start: \(start)", file: file, line: line)
            return ""
        }
        let upper: String.Index
        if let end {
            guard let found = source.range(
                of: end,
                range: lower..<source.endIndex)?.lowerBound else {
                XCTFail("missing source-section end: \(end)", file: file, line: line)
                return ""
            }
            upper = found
        } else {
            upper = source.endIndex
        }
        return String(source[lower..<upper])
    }

    private static func assertAuthorityReferences(
        _ compactSource: String,
        trueFields: [String],
        falseFields: [String],
        label: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        for field in trueFields {
            XCTAssertTrue(
                compactSource.contains("&&authority.\(field)"),
                "\(label) contract omits true field \(field)",
                file: file,
                line: line)
        }
        for field in falseFields {
            XCTAssertTrue(
                compactSource.contains("&&!authority.\(field)"),
                "\(label) contract omits false field \(field)",
                file: file,
                line: line)
        }
    }
}
