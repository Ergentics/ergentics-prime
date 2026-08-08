import CryptoKit
import Foundation
import XCTest
@testable import PrimeLatinProposalPairCapture

final class PrimeLatinProposalInputsV3Tests: XCTestCase {
    func testConsumesExactCanonicalGoldenPairAndRemainsAbstaining() throws {
        let fixture = try PrimeLatinProposalInputsV3Fixture()
        let observation = try PrimeLatinProposalInputsV3.consume(
            candidateCatalogData: fixture.catalogData,
            experimentManifestData: fixture.experimentData)

        XCTAssertEqual(
            observation.schema,
            "ergentics_prime_latin_proposal_inputs_v3_observation")
        XCTAssertEqual(observation.outcome, "abstain")
        XCTAssertEqual(
            observation.verificationScope,
            "canonical_v3_wire_and_embedded_hash_chain_only_non_authorizing")
        XCTAssertEqual(observation.llmSource.repository, FixtureConstant.repository)
        XCTAssertEqual(observation.llmSource.commit, FixtureConstant.commit)
        XCTAssertEqual(observation.llmSource.tree, FixtureConstant.tree)
        XCTAssertEqual(
            observation.candidateCatalogSHA256,
            fixture.catalogSHA256)
        XCTAssertEqual(
            observation.candidateCatalogByteCount,
            UInt64(fixture.catalogData.count))
        XCTAssertEqual(
            observation.candidateDeclarationSetSHA256,
            fixture.declarationSetSHA256)
        XCTAssertEqual(
            observation.candidateDeclarationSetByteCount,
            UInt64(fixture.declarationSetData.count))
        XCTAssertEqual(
            observation.tokenizerBundleSHA256,
            FixtureConstant.tokenizerBundleSHA256)
        XCTAssertEqual(observation.tokenizerBundleByteCount, 2_930)
        XCTAssertEqual(observation.candidateIDs, [FixtureConstant.candidateID])
        XCTAssertEqual(
            observation.candidateIdentitySHA256s,
            [fixture.candidateIdentitySHA256])
        XCTAssertEqual(
            observation.declarationBundleSHA256s,
            [fixture.declarationBundleSHA256])
        XCTAssertEqual(observation.outputNamespace, FixtureConstant.outputNamespace)

        let authority = observation.authority
        XCTAssertEqual(
            authority.disposition,
            "abstain_requires_original_bound_input_bytes_and_live_provenance")
        XCTAssertTrue(authority.canonicalWireRedecodeComplete)
        XCTAssertTrue(authority.embeddedHashChainRecomputationComplete)
        XCTAssertFalse(authority.referencedInputSnapshotAvailable)
        XCTAssertFalse(authority.referencedArtifactBytesAvailable)
        XCTAssertFalse(authority.liveProducerWorkspaceRevalidationComplete)
        XCTAssertFalse(authority.llmGitStateIndependentlyObserved)
        XCTAssertFalse(authority.independentReplayComplete)
        XCTAssertFalse(authority.runtimeDecoderImplementationAvailable)
        XCTAssertFalse(authority.runtimeDependencyClosureEstablished)
        XCTAssertFalse(authority.runtimeInitializationEstablished)
        XCTAssertFalse(authority.primeProposalPacketProduced)
        XCTAssertFalse(authority.primeTrialAuthorizationProduced)
        XCTAssertFalse(authority.primeDecisionReceiptProduced)
        XCTAssertFalse(authority.candidateSelectionAuthorized)
        XCTAssertFalse(authority.trialExecutionAuthorized)
        XCTAssertFalse(authority.furtherTrainingAuthorized)
        XCTAssertFalse(authority.promotionAuthorized)
        XCTAssertFalse(authority.productUseAuthorized)
        XCTAssertFalse(authority.publicationAuthorized)
        XCTAssertFalse(authority.durableReceiptPublished)

        XCTAssertEqual(
            FixtureJSON.sha256(fixture.tokenizerBundleData),
            FixtureConstant.tokenizerBundleSHA256)
        XCTAssertEqual(fixture.tokenizerBundleData.count, 2_930)
        XCTAssertEqual(
            FixtureJSON.sha256(fixture.architectureLineData),
            FixtureConstant.architectureSHA256)
        XCTAssertEqual(fixture.architectureLineData.count, 2_794)
        XCTAssertEqual(
            FixtureJSON.sha256(fixture.derivationLineData),
            FixtureConstant.derivationSHA256)
        XCTAssertEqual(fixture.derivationLineData.count, 2_702)
        XCTAssertEqual(
            fixture.catalogSHA256,
            FixtureConstant.goldenCatalogSHA256)
        XCTAssertEqual(fixture.catalogData.count, 20_779)
        XCTAssertEqual(
            FixtureJSON.sha256(fixture.experimentData),
            FixtureConstant.goldenExperimentSHA256)
        XCTAssertEqual(fixture.experimentData.count, 3_268)
        XCTAssertEqual(
            fixture.declarationSetSHA256,
            FixtureConstant.goldenDeclarationSetSHA256)
        XCTAssertEqual(fixture.declarationSetData.count, 14_860)
        XCTAssertEqual(
            fixture.declarationBundleSHA256,
            FixtureConstant.goldenDeclarationBundleSHA256)
        XCTAssertEqual(
            fixture.candidateIdentitySHA256,
            FixtureConstant.goldenCandidateIdentitySHA256)
    }

    func testRejectsNoncanonicalMissingUnknownPriorSchemasAndOversize() throws {
        let fixture = try PrimeLatinProposalInputsV3Fixture()

        var noncanonical = fixture.catalogData
        noncanonical.append(0x0A)
        assertConsumeFails(catalogData: noncanonical, fixture: fixture)

        var duplicateKey = Data(
            "{\"schema\":\"ergentics_latin_candidate_catalog_v3\",".utf8)
        duplicateKey.append(contentsOf: fixture.catalogData.dropFirst())
        assertConsumeFails(catalogData: duplicateKey, fixture: fixture)

        var missing = fixture.catalogObject
        missing.removeValue(forKey: "authorityStatus")
        assertConsumeFails(
            catalogData: try FixtureJSON.canonical(missing),
            fixture: fixture)

        var unknown = fixture.catalogObject
        unknown["unexpectedAuthority"] = false
        assertConsumeFails(
            catalogData: try FixtureJSON.canonical(unknown),
            fixture: fixture)

        var v1Catalog = fixture.catalogObject
        v1Catalog["schema"] = "ergentics_latin_candidate_catalog_v1"
        assertConsumeFails(
            catalogData: try FixtureJSON.canonical(v1Catalog),
            fixture: fixture)

        var v2Experiment = fixture.experimentObject
        v2Experiment["schema"] = "ergentics_latin_experiment_manifest_v2"
        assertConsumeFails(
            experimentData: try FixtureJSON.canonical(v2Experiment),
            fixture: fixture)

        let oversized = Data(repeating: 0x20, count: 1_048_577)
        assertConsumeFails(catalogData: oversized, fixture: fixture)
        assertConsumeFails(experimentData: oversized, fixture: fixture)
    }

    func testRejectsExactSourceBlobTokenizerHashChainAndCrossBindingMutations()
        throws
    {
        let fixture = try PrimeLatinProposalInputsV3Fixture()

        var source = fixture.catalogObject
        source["llmSource"] = FixtureObject.llmSource(
            commit: String(repeating: "0", count: 40))
        var sourceExperiment = fixture.experimentObject
        try FixtureRepair.catalogHash(
            catalog: source,
            experiment: &sourceExperiment)
        assertConsumeFails(
            catalogData: try FixtureJSON.canonical(source),
            experimentData: try FixtureJSON.canonical(sourceExperiment))

        var blob = fixture.catalogObject
        blob = try FixtureMutation.setting(
            blob,
            path: [
                .key("candidateDeclarations"), .key("candidates"), .index(0),
                .key("declarationBundle"), .key("architectureArtifact"),
                .key("gitBlobOID"),
            ],
            value: String(repeating: "0", count: 40))
        var blobExperiment = fixture.experimentObject
        try FixtureRepair.embeddedHashChain(
            catalog: &blob,
            experiment: &blobExperiment)
        assertConsumeFails(
            catalogData: try FixtureJSON.canonical(blob),
            experimentData: try FixtureJSON.canonical(blobExperiment))

        var tokenizer = fixture.catalogObject
        tokenizer = try FixtureMutation.setting(
            tokenizer,
            path: [
                .key("tokenizerProposalBinding"),
                .key("tokenizerBundleSHA256"),
            ],
            value: String(repeating: "a", count: 64))
        var tokenizerExperiment = fixture.experimentObject
        try FixtureRepair.catalogHash(
            catalog: tokenizer,
            experiment: &tokenizerExperiment)
        assertConsumeFails(
            catalogData: try FixtureJSON.canonical(tokenizer),
            experimentData: try FixtureJSON.canonical(tokenizerExperiment))

        var staleBundle = fixture.catalogObject
        staleBundle = try FixtureMutation.setting(
            staleBundle,
            path: [
                .key("candidateDeclarations"), .key("candidates"), .index(0),
                .key("declarationBundle"), .key("initializationStatus"),
            ],
            value: "mutated_without_rehash")
        assertConsumeFails(
            catalogData: try FixtureJSON.canonical(staleBundle),
            fixture: fixture)

        var crossBinding = fixture.experimentObject
        crossBinding["candidateDeclarationSetSHA256"] =
            String(repeating: "b", count: 64)
        assertConsumeFails(
            experimentData: try FixtureJSON.canonical(crossBinding),
            fixture: fixture)
    }

    func testRejectsDeepSemanticMutationsAfterRepairingOuterHashes() throws {
        let fixture = try PrimeLatinProposalInputsV3Fixture()

        try assertOuterRepairedCatalogMutationFails(
            fixture: fixture,
            expectedContext: "candidate_architecture_v1"
        ) { catalog in
            catalog = try FixtureMutation.setting(
                catalog,
                path: [
                    .key("candidateDeclarations"), .key("candidates"),
                    .index(0), .key("declarationBundle"),
                    .key("architecture"), .key("geometry"),
                    .key("model_width"),
                ],
                value: 9)
        }
        try assertOuterRepairedCatalogMutationFails(
            fixture: fixture,
            expectedContext: "candidate_parameter_derivation_v1"
        ) { catalog in
            catalog = try FixtureMutation.setting(
                catalog,
                path: [
                    .key("candidateDeclarations"), .key("candidates"),
                    .index(0), .key("declarationBundle"),
                    .key("parameterCountDerivation"),
                    .key("total_parameter_count"),
                ],
                value: 131_737)
        }
        try assertRepairedCatalogMutationFails(fixture: fixture) { catalog in
            catalog = try FixtureMutation.setting(
                catalog,
                path: [
                    .key("candidateDeclarations"), .key("candidates"),
                    .index(0), .key("declarationBundle"),
                    .key("declarationTargetClosure"),
                    .key("directTargetDependencies"),
                ],
                value: ["InjectedRuntimeTarget"])
        }
        try assertRepairedCatalogMutationFails(fixture: fixture) { catalog in
            catalog = try FixtureMutation.setting(
                catalog,
                path: [
                    .key("candidateDeclarations"), .key("candidates"),
                    .index(0), .key("declarationBundle"),
                    .key("runtimeDecoderImplementation"),
                ],
                value: "present")
        }
    }

    func testRejectsEmptyDuplicateAndReorderedCandidateSets() throws {
        let fixture = try PrimeLatinProposalInputsV3Fixture()

        try assertRepairedCatalogMutationFails(fixture: fixture) { catalog in
            catalog = try FixtureMutation.setting(
                catalog,
                path: [.key("candidateDeclarations"), .key("candidates")],
                value: [])
        }
        try assertRepairedCatalogMutationFails(fixture: fixture) { catalog in
            let binding = try FixtureMutation.value(
                catalog,
                path: [
                    .key("candidateDeclarations"), .key("candidates"), .index(0),
                ])
            catalog = try FixtureMutation.setting(
                catalog,
                path: [.key("candidateDeclarations"), .key("candidates")],
                value: [binding, binding])
        }
        try assertRepairedCatalogMutationFails(fixture: fixture) { catalog in
            let binding = try FixtureMutation.object(
                catalog,
                path: [
                    .key("candidateDeclarations"), .key("candidates"), .index(0),
                ])
            var first = binding
            first["candidateID"] = "latin_z_candidate"
            first["candidateIdentitySHA256"] = String(repeating: "c", count: 64)
            first["declarationBundleSHA256"] = String(repeating: "d", count: 64)
            var second = binding
            second["candidateID"] = "latin_a_candidate"
            second["candidateIdentitySHA256"] = String(repeating: "e", count: 64)
            second["declarationBundleSHA256"] = String(repeating: "f", count: 64)
            catalog = try FixtureMutation.setting(
                catalog,
                path: [.key("candidateDeclarations"), .key("candidates")],
                value: [first, second])
        }
    }

    func testRejectsExperimentAuthorityOutputBudgetSplitAndQuarantineMutations()
        throws
    {
        let fixture = try PrimeLatinProposalInputsV3Fixture()

        for authorityKey in [
            "candidateSelectionAuthorized", "trialExecutionAuthorized",
            "furtherTrainingAuthorized", "promotionAuthorized",
            "productUseAuthorized", "publicationAuthorized",
        ] {
            var experiment = fixture.experimentObject
            experiment = try FixtureMutation.setting(
                experiment,
                path: [.key("authority"), .key(authorityKey)],
                value: true)
            assertConsumeFails(
                experimentData: try FixtureJSON.canonical(experiment),
                fixture: fixture)
        }

        var decision = fixture.experimentObject
        decision = try FixtureMutation.setting(
            decision,
            path: [.key("authority"), .key("primeDecisionReceipt")],
            value: "present")
        assertConsumeFails(
            experimentData: try FixtureJSON.canonical(decision),
            fixture: fixture)

        var output = fixture.experimentObject
        output["outputNamespace"] = "../unsafe"
        assertConsumeFails(
            experimentData: try FixtureJSON.canonical(output),
            fixture: fixture)

        var budget = fixture.experimentObject
        budget = try FixtureMutation.setting(
            budget,
            path: [.key("requestedTrialBudget"), .key("optimizerSteps")],
            value: 0)
        assertConsumeFails(
            experimentData: try FixtureJSON.canonical(budget),
            fixture: fixture)

        var split = fixture.experimentObject
        split = try FixtureMutation.setting(
            split,
            path: [.key("splits"), .key("selectionSplitID")],
            value: "latin_train_v3")
        assertConsumeFails(
            experimentData: try FixtureJSON.canonical(split),
            fixture: fixture)

        try assertRepairedCatalogMutationFails(fixture: fixture) { catalog in
            catalog = try FixtureMutation.setting(
                catalog,
                path: [
                    .key("proposalInputDependencyQuarantine"),
                    .key("candidateImplementationSources"),
                ],
                value: [FixtureObject.binding(
                    scope: "ergentics_llm_repository",
                    path: "Sources/RuntimeDecoder.swift",
                    sha256: String(repeating: "9", count: 64),
                    byteCount: 99)])
        }
    }

    func testRejectsUnsafeOverlappingAndAliasedArtifactBindings() throws {
        let fixture = try PrimeLatinProposalInputsV3Fixture()

        var oversized = fixture.experimentObject
        oversized = try FixtureMutation.setting(
            oversized,
            path: [.key("corpusManifest"), .key("byteCount")],
            value: UInt64(8_388_609))
        assertConsumeFails(
            experimentData: try FixtureJSON.canonical(oversized),
            fixture: fixture)

        var unsafePath = fixture.experimentObject
        unsafePath = try FixtureMutation.setting(
            unsafePath,
            path: [.key("corpusManifest"), .key("relativePath")],
            value: "corpus/la/L1/../escape.json")
        assertConsumeFails(
            experimentData: try FixtureJSON.canonical(unsafePath),
            fixture: fixture)

        var outputOverlap = fixture.experimentObject
        outputOverlap = try FixtureMutation.setting(
            outputOverlap,
            path: [.key("corpusManifest"), .key("relativePath")],
            value: FixtureConstant.outputNamespace + "/corpus.json")
        assertConsumeFails(
            experimentData: try FixtureJSON.canonical(outputOverlap),
            fixture: fixture)

        let trainingSplit = try FixtureMutation.object(
            fixture.experimentObject,
            path: [.key("splits"), .key("trainingSplit")])
        let trainingPath = try FixtureMutation.value(
            trainingSplit,
            path: [.key("relativePath")])
        let trainingSHA256 = try FixtureMutation.value(
            trainingSplit,
            path: [.key("sha256")])
        let trainingByteCount = try FixtureMutation.value(
            trainingSplit,
            path: [.key("byteCount")])

        var inconsistentLocation = fixture.experimentObject
        inconsistentLocation = try FixtureMutation.setting(
            inconsistentLocation,
            path: [
                .key("splits"), .key("validationSplit"),
                .key("relativePath"),
            ],
            value: trainingPath)
        assertConsumeFails(
            experimentData: try FixtureJSON.canonical(inconsistentLocation),
            fixture: fixture)

        var inconsistentHash = fixture.experimentObject
        inconsistentHash = try FixtureMutation.setting(
            inconsistentHash,
            path: [
                .key("splits"), .key("validationSplit"), .key("sha256"),
            ],
            value: trainingSHA256)
        assertConsumeFails(
            experimentData: try FixtureJSON.canonical(inconsistentHash),
            fixture: fixture)

        var strictRoleAlias = fixture.experimentObject
        strictRoleAlias = try FixtureMutation.setting(
            strictRoleAlias,
            path: [
                .key("splits"), .key("validationSplit"), .key("sha256"),
            ],
            value: trainingSHA256)
        strictRoleAlias = try FixtureMutation.setting(
            strictRoleAlias,
            path: [
                .key("splits"), .key("validationSplit"),
                .key("byteCount"),
            ],
            value: trainingByteCount)
        assertConsumeFails(
            experimentData: try FixtureJSON.canonical(strictRoleAlias),
            fixture: fixture)
    }

    func testSupportedSourcesAreAcceptedAndArbitraryOrHybridSourcesAreRejected()
        throws
    {
        let finalFixture = try PrimeLatinProposalInputsV3Fixture(
            source: .finalPublisher)
        let finalObservation = try PrimeLatinProposalInputsV3.consume(
            candidateCatalogData: finalFixture.catalogData,
            experimentManifestData: finalFixture.experimentData)
        XCTAssertEqual(
            finalObservation.llmSource.commit,
            FixtureConstant.finalPublisherCommit)
        XCTAssertEqual(
            finalObservation.llmSource.tree,
            FixtureConstant.finalPublisherTree)

        let handoffFixture = try PrimeLatinProposalInputsV3Fixture(
            source: .finalHandoff)
        let handoffObservation = try PrimeLatinProposalInputsV3.consume(
            candidateCatalogData: handoffFixture.catalogData,
            experimentManifestData: handoffFixture.experimentData)
        XCTAssertEqual(
            handoffObservation.llmSource.commit,
            FixtureConstant.finalHandoffCommit)
        XCTAssertEqual(
            handoffObservation.llmSource.tree,
            FixtureConstant.finalHandoffTree)

        let arbitraryFixture = try PrimeLatinProposalInputsV3Fixture(
            source: FixtureSource(
                repository: FixtureConstant.repository,
                commit: String(repeating: "0", count: 40),
                tree: String(repeating: "1", count: 40)))
        XCTAssertThrowsError(
            try PrimeLatinProposalInputsV3.consume(
                candidateCatalogData: arbitraryFixture.catalogData,
                experimentManifestData: arbitraryFixture.experimentData))

        let supportedSources: [FixtureSource] = [
            .legacy, .finalPublisher, .finalHandoff,
        ]
        for commitSource in supportedSources {
            for treeSource in supportedSources
            where commitSource != treeSource {
                let hybridFixture = try PrimeLatinProposalInputsV3Fixture(
                    source: FixtureSource(
                        repository: FixtureConstant.repository,
                        commit: commitSource.commit,
                        tree: treeSource.tree))
                XCTAssertThrowsError(
                    try PrimeLatinProposalInputsV3.consume(
                        candidateCatalogData: hybridFixture.catalogData,
                        experimentManifestData: hybridFixture.experimentData))
            }
        }

        let legacyFixture = try PrimeLatinProposalInputsV3Fixture()
        var mixedExperiment = legacyFixture.experimentObject
        mixedExperiment["candidateCatalogSHA256"] =
            finalFixture.catalogSHA256
        mixedExperiment["candidateCatalogByteCount"] =
            UInt64(finalFixture.catalogData.count)
        mixedExperiment["candidateDeclarationSetSHA256"] =
            finalFixture.declarationSetSHA256
        mixedExperiment["candidateDeclarationSetByteCount"] =
            UInt64(finalFixture.declarationSetData.count)
        XCTAssertThrowsError(
            try PrimeLatinProposalInputsV3.consume(
                candidateCatalogData: finalFixture.catalogData,
                experimentManifestData:
                    try FixtureJSON.canonical(mixedExperiment)))
    }

    func testFinalHandoffRequiresExactTrackedEvaluationContractBinding()
        throws
    {
        let fixture = try PrimeLatinProposalInputsV3Fixture(
            source: .finalHandoff)
        let binding = try XCTUnwrap(
            fixture.experimentObject["evaluationContract"] as? JSONObject)
        XCTAssertEqual(binding["scope"] as? String,
                       "ergentics_llm_repository")
        XCTAssertEqual(
            binding["relativePath"] as? String,
            FixtureConstant.finalEvaluationContractPath)
        XCTAssertEqual(
            binding["sha256"] as? String,
            FixtureConstant.finalEvaluationContractSHA256)
        XCTAssertEqual(
            binding["byteCount"] as? UInt64,
            FixtureConstant.finalEvaluationContractByteCount)

        let mutations: [(String, Any)] = [
            ("relativePath", "Research/Latin/evaluation/other.json"),
            ("sha256", String(repeating: "0", count: 64)),
            ("byteCount", UInt64(165)),
            ("scope", "ergentics_mlx_lab"),
        ]
        for (key, value) in mutations {
            var experiment = fixture.experimentObject
            var changed = binding
            changed[key] = value
            experiment["evaluationContract"] = changed
            assertConsumeFails(
                experimentData: try FixtureJSON.canonical(experiment),
                fixture: fixture)
        }
    }

    func testV3PairLocatorUsesExactContentAddressedPublicationRoot() throws {
        let fixture = try FinalPublisherPairCaptureFixture()
        let locator = try PrimeLatinProposalPairLocatorV3(
            sha256: fixture.pairSHA256)

        XCTAssertEqual(locator.sha256, fixture.pairSHA256)
        XCTAssertEqual(
            locator.relativePath,
            "evidence/latin-proposal-artifacts/v3/pairs/" +
                "\(fixture.pairSHA256).json")
        XCTAssertThrowsError(
            try PrimeLatinProposalPairLocatorV3(
                sha256: fixture.pairSHA256.uppercased()))
        XCTAssertThrowsError(
            try PrimeLatinProposalPairLocatorV3(
                sha256: String(repeating: "a", count: 63)))

        let alias = FileManager.default.temporaryDirectory
            .appendingPathComponent(
                "prime-latin-v3-root-alias-\(UUID().uuidString)")
        try FileManager.default.createSymbolicLink(
            at: alias,
            withDestinationURL: fixture.labRoot)
        defer { try? FileManager.default.removeItem(at: alias) }
        XCTAssertThrowsError(
            try PrimeLatinProposalPairCaptureV3.capture(
                labRoot: alias,
                pairSHA256: fixture.pairSHA256))
    }

    func testPriorPublisherGoldenRemainsDataVerifiableButIsNotLiveCapturable()
        throws
    {
        let fixture = try FinalPublisherPairCaptureFixture(
            source: .finalPublisher)
        let observation = try PrimeLatinProposalInputsV3.consume(
            candidateCatalogData: fixture.inputs.catalogData,
            experimentManifestData: fixture.inputs.experimentData)

        XCTAssertEqual(
            fixture.inputs.catalogSHA256,
            FixtureConstant.finalCatalogSHA256)
        XCTAssertEqual(fixture.inputs.catalogData.count, 20_779)
        XCTAssertEqual(
            FixtureJSON.sha256(fixture.inputs.experimentData),
            FixtureConstant.finalExperimentSHA256)
        XCTAssertEqual(fixture.inputs.experimentData.count, 3_268)
        XCTAssertEqual(
            fixture.inputs.declarationSetSHA256,
            FixtureConstant.finalDeclarationSetSHA256)
        XCTAssertEqual(fixture.inputs.declarationSetData.count, 14_860)
        XCTAssertEqual(
            fixture.inputs.declarationBundleSHA256,
            FixtureConstant.finalDeclarationBundleSHA256)
        XCTAssertEqual(
            fixture.inputs.candidateIdentitySHA256,
            FixtureConstant.finalCandidateIdentitySHA256)
        XCTAssertEqual(fixture.pairSHA256,
                       FixtureConstant.finalReceiptSHA256)
        XCTAssertEqual(fixture.receiptData.count, 1_833)
        XCTAssertEqual(observation.outcome, "abstain")
        XCTAssertEqual(observation.llmSource.commit,
                       FixtureConstant.finalPublisherCommit)
        XCTAssertEqual(observation.llmSource.tree,
                       FixtureConstant.finalPublisherTree)
        XCTAssertFalse(observation.authority.primeProposalPacketProduced)
        XCTAssertFalse(observation.authority.primeTrialAuthorizationProduced)
        XCTAssertFalse(observation.authority.primeDecisionReceiptProduced)
        XCTAssertFalse(observation.authority.candidateSelectionAuthorized)
        XCTAssertFalse(observation.authority.trialExecutionAuthorized)
        XCTAssertFalse(observation.authority.furtherTrainingAuthorized)
        XCTAssertFalse(observation.authority.promotionAuthorized)
        XCTAssertFalse(observation.authority.productUseAuthorized)
        XCTAssertFalse(observation.authority.publicationAuthorized)
        XCTAssertFalse(observation.authority.durableReceiptPublished)

        XCTAssertThrowsError(
            try PrimeLatinProposalPairCaptureV3.capture(
                labRoot: fixture.labRoot,
                pairSHA256: fixture.pairSHA256)
        ) { error in
            XCTAssertEqual(
                error as? PrimeLatinProposalPairCaptureError,
                .invalidSemantics("unsupported_v3_publisher_source"))
        }
    }

    func testCapturesCanonicalFinalHandoffPairAndRemainsAbstaining()
        throws
    {
        let fixture = try FinalPublisherPairCaptureFixture(
            source: .finalHandoff)
        let capture = try PrimeLatinProposalPairCaptureV3.capture(
            labRoot: fixture.labRoot,
            pairSHA256: fixture.pairSHA256)
        let observation = capture.observation

        XCTAssertEqual(
            fixture.inputs.catalogSHA256,
            FixtureConstant.handoffCatalogSHA256)
        XCTAssertEqual(fixture.inputs.catalogData.count, 20_779)
        XCTAssertEqual(
            FixtureJSON.sha256(fixture.inputs.experimentData),
            FixtureConstant.handoffExperimentSHA256)
        XCTAssertEqual(fixture.inputs.experimentData.count, 3_253)
        XCTAssertEqual(
            fixture.inputs.declarationSetSHA256,
            FixtureConstant.handoffDeclarationSetSHA256)
        XCTAssertEqual(fixture.inputs.declarationSetData.count, 14_860)
        XCTAssertEqual(
            fixture.inputs.declarationBundleSHA256,
            FixtureConstant.handoffDeclarationBundleSHA256)
        XCTAssertEqual(
            fixture.inputs.candidateIdentitySHA256,
            FixtureConstant.handoffCandidateIdentitySHA256)
        XCTAssertEqual(
            fixture.pairSHA256,
            FixtureConstant.handoffReceiptSHA256)
        XCTAssertEqual(fixture.receiptData.count, 1_833)

        XCTAssertEqual(
            observation.schema,
            "ergentics_prime_latin_proposal_pair_capture_v3_observation")
        XCTAssertEqual(observation.outcome, "abstain")
        XCTAssertEqual(
            observation.verificationScope,
            "descriptor_safe_content_addressed_v3_pair_capture_and_" +
                "embedded_hash_chain_only_non_authorizing")
        XCTAssertEqual(observation.pairReceiptSHA256, fixture.pairSHA256)
        XCTAssertEqual(
            observation.pairReceiptByteCount,
            UInt64(fixture.receiptData.count))
        let receiptObject = try XCTUnwrap(
            try JSONSerialization.jsonObject(
                with: fixture.receiptData) as? JSONObject)
        let receiptSource = try XCTUnwrap(
            receiptObject["llmSource"] as? JSONObject)
        let catalogSource = try XCTUnwrap(
            fixture.inputs.catalogObject["llmSource"] as? JSONObject)
        let experimentSource = try XCTUnwrap(
            fixture.inputs.experimentObject["llmSource"] as? JSONObject)
        for key in ["repository", "commit", "tree"] {
            XCTAssertEqual(
                receiptSource[key] as? String,
                catalogSource[key] as? String)
            XCTAssertEqual(
                receiptSource[key] as? String,
                experimentSource[key] as? String)
        }
        XCTAssertEqual(
            observation.llmSource.repository,
            FixtureConstant.repository)
        XCTAssertEqual(
            observation.llmSource.commit,
            FixtureConstant.finalHandoffCommit)
        XCTAssertEqual(
            observation.llmSource.tree,
            FixtureConstant.finalHandoffTree)
        XCTAssertEqual(
            observation.candidateCatalogSHA256,
            fixture.inputs.catalogSHA256)
        XCTAssertEqual(
            observation.candidateCatalogByteCount,
            UInt64(fixture.inputs.catalogData.count))
        XCTAssertEqual(
            observation.experimentManifestSHA256,
            FixtureJSON.sha256(fixture.inputs.experimentData))
        XCTAssertEqual(
            observation.experimentManifestByteCount,
            UInt64(fixture.inputs.experimentData.count))
        XCTAssertEqual(
            observation.candidateDeclarationSetSHA256,
            fixture.inputs.declarationSetSHA256)
        XCTAssertEqual(
            observation.candidateDeclarationSetByteCount,
            UInt64(fixture.inputs.declarationSetData.count))
        XCTAssertEqual(
            observation.tokenizerBundleSHA256,
            FixtureConstant.tokenizerBundleSHA256)
        XCTAssertEqual(observation.tokenizerBundleByteCount, 2_930)
        XCTAssertEqual(
            observation.candidateIDs,
            [FixtureConstant.candidateID])
        XCTAssertEqual(
            observation.candidateIdentitySHA256s,
            [fixture.inputs.candidateIdentitySHA256])
        XCTAssertEqual(
            observation.declarationBundleSHA256s,
            [fixture.inputs.declarationBundleSHA256])
        XCTAssertEqual(
            observation.outputNamespace,
            FixtureConstant.outputNamespace)

        let authority = observation.authority
        XCTAssertEqual(
            authority.disposition,
            "abstain_requires_original_bound_input_bytes_and_live_provenance")
        XCTAssertTrue(authority.canonicalReceiptRedecodeComplete)
        XCTAssertTrue(authority.receiptContentAddressBindingVerified)
        XCTAssertTrue(authority.childContentAddressBindingsVerified)
        XCTAssertTrue(authority.stableRootBoundCaptureComplete)
        XCTAssertTrue(authority.pairChildDocumentBytesAvailable)
        XCTAssertTrue(authority.embeddedHashChainRecomputationComplete)
        XCTAssertTrue(authority.llmPairReceiptObserved)
        XCTAssertFalse(authority.referencedInputSnapshotAvailable)
        XCTAssertFalse(authority.referencedArtifactBytesAvailable)
        XCTAssertFalse(authority.liveProducerWorkspaceRevalidationComplete)
        XCTAssertFalse(authority.llmGitStateIndependentlyObserved)
        XCTAssertFalse(authority.independentReplayComplete)
        XCTAssertFalse(authority.runtimeDecoderImplementationAvailable)
        XCTAssertFalse(authority.runtimeDependencyClosureEstablished)
        XCTAssertFalse(authority.runtimeInitializationEstablished)
        XCTAssertFalse(authority.primeProposalPacketProduced)
        XCTAssertFalse(authority.primeTrialAuthorizationProduced)
        XCTAssertFalse(authority.primeDecisionReceiptProduced)
        XCTAssertFalse(authority.candidateSelectionAuthorized)
        XCTAssertFalse(authority.trialExecutionAuthorized)
        XCTAssertFalse(authority.furtherTrainingAuthorized)
        XCTAssertFalse(authority.promotionAuthorized)
        XCTAssertFalse(authority.productUseAuthorized)
        XCTAssertFalse(authority.publicationAuthorized)
        XCTAssertFalse(authority.primeDurableReceiptPublished)

        XCTAssertEqual(
            try capture.recaptureAndValidateUnchanged(),
            observation)
    }

    func testV3CaptureRejectsReceiptWireStatusAuthorityAndSourceMutations()
        throws
    {
        let legacySource = try FinalPublisherPairCaptureFixture(
            source: .legacy)
        assertV3CaptureFails(legacySource)

        let noncanonical = try FinalPublisherPairCaptureFixture(
            receiptDataMutation: { data in
                var changed = data
                changed.append(0x0A)
                return changed
            })
        assertV3CaptureFails(noncanonical)

        let duplicateSchema = try FinalPublisherPairCaptureFixture(
            receiptDataMutation: { data in
                var changed = Data(
                    "{\"schema\":\"ergentics_latin_proposal_pair_receipt_v3\",".utf8)
                changed.append(contentsOf: data.dropFirst())
                return changed
            })
        assertV3CaptureFails(duplicateSchema)

        let missingField = try FinalPublisherPairCaptureFixture(
            receiptMutation: { receipt in
                receipt.removeValue(forKey: "completionScope")
            })
        assertV3CaptureFails(missingField)

        let unknownField = try FinalPublisherPairCaptureFixture(
            receiptMutation: { receipt in
                receipt["unexpectedAuthority"] = false
            })
        assertV3CaptureFails(unknownField)

        for field in [
            "publicationMechanicsStatus",
            "authorityStatus",
            "completionScope",
            "referencedInputSnapshot",
            "referencedArtifactBytes",
            "independentReplayStatus",
            "primeConsumerStatus",
            "externalStateCommitAtomicity",
            "publicationCoordination",
        ] {
            let fixture = try FinalPublisherPairCaptureFixture(
                receiptMutation: { receipt in
                    receipt[field] = "mutated"
                })
            assertV3CaptureFails(fixture)
        }

        for field in [
            "primeProposalPacket",
            "primeTrialAuthorization",
            "primeDecisionReceipt",
        ] {
            let fixture = try FinalPublisherPairCaptureFixture(
                receiptMutation: { receipt in
                    var authority = receipt["authority"] as! JSONObject
                    authority[field] = "present"
                    receipt["authority"] = authority
                })
            assertV3CaptureFails(fixture)
        }
        for field in [
            "candidateSelectionAuthorized",
            "trialExecutionAuthorized",
            "furtherTrainingAuthorized",
            "promotionAuthorized",
            "productUseAuthorized",
            "publicationAuthorized",
        ] {
            let fixture = try FinalPublisherPairCaptureFixture(
                receiptMutation: { receipt in
                    var authority = receipt["authority"] as! JSONObject
                    authority[field] = true
                    receipt["authority"] = authority
                })
            assertV3CaptureFails(fixture)
        }

        let source = try FinalPublisherPairCaptureFixture(
            receiptMutation: { receipt in
                var llmSource = receipt["llmSource"] as! JSONObject
                llmSource["tree"] = String(repeating: "0", count: 40)
                receipt["llmSource"] = llmSource
            })
        assertV3CaptureFails(source)

        let declarationHash = try FinalPublisherPairCaptureFixture(
            receiptMutation: { receipt in
                receipt["candidateDeclarationSetSHA256"] =
                    String(repeating: "0", count: 64)
            })
        assertV3CaptureFails(declarationHash)

        let declarationCount = try FinalPublisherPairCaptureFixture(
            receiptMutation: { receipt in
                receipt["candidateDeclarationSetByteCount"] = 1
            })
        assertV3CaptureFails(declarationCount)
    }

    func testV3CaptureRejectsChildKindPathHashAndCountMutations() throws {
        let wrongKind = try FinalPublisherPairCaptureFixture(
            receiptMutation: { receipt in
                var document = receipt["candidateCatalog"] as! JSONObject
                document["documentKind"] = "candidate_catalog"
                receipt["candidateCatalog"] = document
            })
        assertV3CaptureFails(wrongKind)

        let wrongPath = try FinalPublisherPairCaptureFixture(
            receiptMutation: { receipt in
                var document = receipt["experimentManifest"] as! JSONObject
                document["relativePath"] = "../experiment.json"
                receipt["experimentManifest"] = document
            })
        assertV3CaptureFails(wrongPath)

        let wrongHash = try FinalPublisherPairCaptureFixture(
            receiptMutation: { receipt in
                var document = receipt["candidateCatalog"] as! JSONObject
                document["sha256"] = String(repeating: "0", count: 64)
                receipt["candidateCatalog"] = document
            })
        assertV3CaptureFails(wrongHash)

        let wrongCount = try FinalPublisherPairCaptureFixture(
            receiptMutation: { receipt in
                var document = receipt["experimentManifest"] as! JSONObject
                document["byteCount"] = 1
                receipt["experimentManifest"] = document
            })
        assertV3CaptureFails(wrongCount)
    }

    func testV3CaptureRejectsUnsafeChildAndChangedChildRecapture() throws {
        let unsafeMode = try FinalPublisherPairCaptureFixture()
        try FileManager.default.setAttributes(
            [.posixPermissions: 0o644],
            ofItemAtPath: unsafeMode.catalogURL.path)
        assertV3CaptureFails(unsafeMode)

        let changed = try FinalPublisherPairCaptureFixture()
        let capture = try PrimeLatinProposalPairCaptureV3.capture(
            labRoot: changed.labRoot,
            pairSHA256: changed.pairSHA256)
        try FileManager.default.setAttributes(
            [.posixPermissions: 0o644],
            ofItemAtPath: changed.catalogURL.path)
        var changedData = try Data(contentsOf: changed.catalogURL)
        changedData.append(0x0A)
        try changedData.write(to: changed.catalogURL)
        try FileManager.default.setAttributes(
            [.posixPermissions: 0o444],
            ofItemAtPath: changed.catalogURL.path)
        XCTAssertThrowsError(try capture.recaptureAndValidateUnchanged())
    }

    private func assertV3CaptureFails(
        _ fixture: FinalPublisherPairCaptureFixture,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(
            try PrimeLatinProposalPairCaptureV3.capture(
                labRoot: fixture.labRoot,
                pairSHA256: fixture.pairSHA256),
            file: file,
            line: line)
    }

    private func assertOuterRepairedCatalogMutationFails(
        fixture: PrimeLatinProposalInputsV3Fixture,
        expectedContext: String,
        mutation: (inout JSONObject) throws -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        var catalog = fixture.catalogObject
        var experiment = fixture.experimentObject
        try mutation(&catalog)
        try FixtureRepair.outerCandidateHashChain(
            catalog: &catalog,
            experiment: &experiment)
        XCTAssertThrowsError(
            try PrimeLatinProposalInputsV3.consume(
                candidateCatalogData: try FixtureJSON.canonical(catalog),
                experimentManifestData: try FixtureJSON.canonical(experiment)),
            file: file,
            line: line
        ) { error in
            XCTAssertEqual(
                error as? PrimeLatinProposalInputsV3Error,
                .invalidSemantics(expectedContext),
                file: file,
                line: line)
        }
    }

    private func assertRepairedCatalogMutationFails(
        fixture: PrimeLatinProposalInputsV3Fixture,
        mutation: (inout JSONObject) throws -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        var catalog = fixture.catalogObject
        var experiment = fixture.experimentObject
        try mutation(&catalog)
        try FixtureRepair.embeddedHashChain(
            catalog: &catalog,
            experiment: &experiment)
        assertConsumeFails(
            catalogData: try FixtureJSON.canonical(catalog),
            experimentData: try FixtureJSON.canonical(experiment),
            file: file,
            line: line)
    }

    private func assertConsumeFails(
        catalogData: Data? = nil,
        experimentData: Data? = nil,
        fixture: PrimeLatinProposalInputsV3Fixture,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        assertConsumeFails(
            catalogData: catalogData ?? fixture.catalogData,
            experimentData: experimentData ?? fixture.experimentData,
            file: file,
            line: line)
    }

    private func assertConsumeFails(
        catalogData: Data,
        experimentData: Data,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(
            try PrimeLatinProposalInputsV3.consume(
                candidateCatalogData: catalogData,
                experimentManifestData: experimentData),
            file: file,
            line: line)
    }
}

private typealias JSONObject = [String: Any]

private struct FixtureSource: Equatable {
    let repository: String
    let commit: String
    let tree: String

    static let legacy = FixtureSource(
        repository: FixtureConstant.repository,
        commit: FixtureConstant.commit,
        tree: FixtureConstant.tree)
    static let finalPublisher = FixtureSource(
        repository: FixtureConstant.repository,
        commit: FixtureConstant.finalPublisherCommit,
        tree: FixtureConstant.finalPublisherTree)
    static let finalHandoff = FixtureSource(
        repository: FixtureConstant.repository,
        commit: FixtureConstant.finalHandoffCommit,
        tree: FixtureConstant.finalHandoffTree)
}

private enum FixtureConstant {
    static let repository = "Ergentics/ergentics-llm"
    static let commit = "c0e4cb37cc0ac221925b3b5c67b8ec3f24034537"
    static let tree = "81334b9f01391a80e16247d5a840692792ef2ea7"
    static let finalPublisherCommit =
        "3f6097af42510237595acd84bc8b442f953eef72"
    static let finalPublisherTree =
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
    static let outputNamespace =
        "models/latin-prospective/golden-v3-input"
    static let tokenizerBundleSHA256 =
        "9fa3b6eea42a9c4c13ec1ecda2309ec4c35b3022638ae61a08dd2f0fcb9b074c"
    static let architectureSHA256 =
        "4b31feeeba780bc39c064d4540f5701935f960e1e1d8c82c81d295a65e643a70"
    static let derivationSHA256 =
        "45d15481883cf606e8e739aa71815bf9bd2fdd51494059328e3ba16a9ed5fb8f"
    static let packageManifestSHA256 =
        "ab460122d5f364046224c6445a20f3beb34e2831de94db1271bbafb59726c902"
    static let dependencyLockSHA256 =
        "2847fb936ec74eef250b8439d778f0a1ea8d0c630bf09438587764a4b99c6530"
    static let goldenCatalogSHA256 =
        "3ae7fc6a5337d8c1f6f7a32dbf0e04c420f12ed2e35f8da62ad5ccb56c937edd"
    static let goldenExperimentSHA256 =
        "b0c4d9929603cded1b7d3478783430d96f0e277608eb92ee40eec9b4ccf6708b"
    static let goldenDeclarationSetSHA256 =
        "09c72d24311bc88503c8b371754f3bb647bcd6bf0fdbe9d7099fefe4575d799e"
    static let goldenDeclarationBundleSHA256 =
        "eef5aa372e6b2ee10875d7b2283b6e37fabf9409697e650f784faecde8d8ccfb"
    static let goldenCandidateIdentitySHA256 =
        "ae4a66fc0ccb1592875126e0ddf400ee3e858ca1bfdb900fc23a3a0f43667e37"
    static let finalCatalogSHA256 =
        "1798f82f351fb98f97498652ab42ac52cdd995146e0a5a158c634a8a09ea16c6"
    static let finalExperimentSHA256 =
        "f98cdd48b99ea23cb5d1b5013b976f39e4a0fcad86bbfab1c7c5e152facae155"
    static let finalDeclarationSetSHA256 =
        "9393e091b98dc3c40de36f228b035213bb78f678133a97591a9438ba10329372"
    static let finalDeclarationBundleSHA256 =
        "29a5bb950b4e3c323ccdc4b2db0d5c12906dba88b4267cc26e9a9d8870667686"
    static let finalCandidateIdentitySHA256 =
        "ff17b87589766d3a43fd35974a20cd46070c247ec16ecef1943ad0c0e4f2aa57"
    static let finalReceiptSHA256 =
        "4e7b6326c6f8d1487dedc4e4400ca588dc38277585fbfc820762c1b0ce31e3fb"
    static let handoffCatalogSHA256 =
        "250bf7fb4d3e7286760ab54d4cb08b7be948227a41579f890106b35e351075b3"
    static let handoffExperimentSHA256 =
        "c2c92730aeb9ce1e979a336ceefba28d4e49a1edf9509e35167cfff9068de5c4"
    static let handoffDeclarationSetSHA256 =
        "45c787dba8c538794cbaf7cb90acb4528d2dedcaf666a1f0da151ca236138881"
    static let handoffDeclarationBundleSHA256 =
        "6f07896e50b2b530ea5f5924859d1e66bf9880366c16cf37832138a0e6c7f4bd"
    static let handoffCandidateIdentitySHA256 =
        "64a288b62cdef276923eb72e5cc4d209a7195526408414fc5167522151481265"
    static let handoffReceiptSHA256 =
        "00c06565879236e367689a8acf491de160cac0a6f18c3a0395a9b16c1c3464d2"
}

private enum FixtureJSON {
    static func canonical(_ object: Any) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(FixtureCanonicalValue(object))
    }

    static func canonicalLine(_ object: Any) throws -> Data {
        var data = try canonical(object)
        data.append(0x0A)
        return data
    }

    static func canonicalEncodable<Value: Encodable>(
        _ value: Value
    ) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(value)
    }

    static func sha256(_ data: Data) -> String {
        SHA256.hash(data: data).map {
            String(format: "%02x", $0)
        }.joined()
    }
}

private enum FixtureCanonicalValueError: Error {
    case unsupportedValueType(String)
    case invalidObjectKey(String)
}

private struct FixtureCanonicalObjectKey: CodingKey {
    let stringValue: String
    let intValue: Int? = nil

    init?(stringValue: String) {
        guard !stringValue.isEmpty else { return nil }
        self.stringValue = stringValue
    }

    init?(intValue: Int) {
        return nil
    }
}

private indirect enum FixtureCanonicalValue: Encodable {
    case object([String: FixtureCanonicalValue])
    case array([FixtureCanonicalValue])
    case string(String)
    case boolean(Bool)
    case unsignedInteger(UInt64)
    case signedInteger(Int64)

    init(_ value: Any) throws {
        switch value {
        case let value as JSONObject:
            var converted = [String: FixtureCanonicalValue]()
            converted.reserveCapacity(value.count)
            for (key, child) in value {
                guard FixtureCanonicalObjectKey(stringValue: key) != nil else {
                    throw FixtureCanonicalValueError.invalidObjectKey(key)
                }
                converted[key] = try FixtureCanonicalValue(child)
            }
            self = .object(converted)
        case let value as [Any]:
            self = .array(try value.map(FixtureCanonicalValue.init))
        case let value as String:
            self = .string(value)
        case let value as Bool:
            self = .boolean(value)
        case let value as UInt64:
            self = .unsignedInteger(value)
        case let value as UInt:
            self = .unsignedInteger(UInt64(value))
        case let value as Int:
            self = .signedInteger(Int64(value))
        case let value as Int64:
            self = .signedInteger(value)
        default:
            throw FixtureCanonicalValueError.unsupportedValueType(
                String(reflecting: type(of: value)))
        }
    }

    func encode(to encoder: Encoder) throws {
        switch self {
        case let .object(object):
            var container = encoder.container(
                keyedBy: FixtureCanonicalObjectKey.self)
            for (key, value) in object {
                guard let codingKey = FixtureCanonicalObjectKey(
                    stringValue: key) else {
                    throw FixtureCanonicalValueError.invalidObjectKey(key)
                }
                try container.encode(value, forKey: codingKey)
            }
        case let .array(array):
            var container = encoder.unkeyedContainer()
            for value in array {
                try container.encode(value)
            }
        case let .string(string):
            var container = encoder.singleValueContainer()
            try container.encode(string)
        case let .boolean(boolean):
            var container = encoder.singleValueContainer()
            try container.encode(boolean)
        case let .unsignedInteger(integer):
            var container = encoder.singleValueContainer()
            try container.encode(integer)
        case let .signedInteger(integer):
            var container = encoder.singleValueContainer()
            try container.encode(integer)
        }
    }
}

private enum FixturePath: Equatable {
    case key(String)
    case index(Int)
}

private enum FixtureMutationError: Error {
    case invalidPath
}

private enum FixtureMutation {
    static func value(_ root: Any, path: [FixturePath]) throws -> Any {
        guard let first = path.first else { return root }
        switch first {
        case let .key(key):
            guard let object = root as? JSONObject,
                  let child = object[key] else {
                throw FixtureMutationError.invalidPath
            }
            return try value(child, path: Array(path.dropFirst()))
        case let .index(index):
            guard let array = root as? [Any], array.indices.contains(index) else {
                throw FixtureMutationError.invalidPath
            }
            return try value(array[index], path: Array(path.dropFirst()))
        }
    }

    static func object(_ root: Any, path: [FixturePath]) throws -> JSONObject {
        guard let object = try value(root, path: path) as? JSONObject else {
            throw FixtureMutationError.invalidPath
        }
        return object
    }

    static func setting(
        _ root: JSONObject,
        path: [FixturePath],
        value replacement: Any
    ) throws -> JSONObject {
        guard let object = try settingValue(
            root,
            path: path,
            replacement: replacement) as? JSONObject else {
            throw FixtureMutationError.invalidPath
        }
        return object
    }

    private static func settingValue(
        _ current: Any,
        path: [FixturePath],
        replacement: Any
    ) throws -> Any {
        guard let first = path.first else { return replacement }
        let remainder = Array(path.dropFirst())
        switch first {
        case let .key(key):
            guard var object = current as? JSONObject,
                  let child = object[key] else {
                throw FixtureMutationError.invalidPath
            }
            object[key] = try settingValue(
                child,
                path: remainder,
                replacement: replacement)
            return object
        case let .index(index):
            guard var array = current as? [Any],
                  array.indices.contains(index) else {
                throw FixtureMutationError.invalidPath
            }
            array[index] = try settingValue(
                array[index],
                path: remainder,
                replacement: replacement)
            return array
        }
    }
}

private enum FixtureObject {
    static func llmSource(
        repository: String = FixtureConstant.repository,
        commit: String = FixtureConstant.commit,
        tree: String = FixtureConstant.tree
    ) -> JSONObject {
        [
            "repository": repository,
            "commit": commit,
            "tree": tree,
        ]
    }

    static func binding(
        scope: String,
        path: String,
        sha256: String,
        byteCount: UInt64
    ) -> JSONObject {
        [
            "scope": scope,
            "relativePath": path,
            "sha256": sha256,
            "byteCount": byteCount,
        ]
    }

    static func committed(
        artifact: JSONObject,
        gitBlobOID: String
    ) -> JSONObject {
        [
            "artifact": artifact,
            "gitBlobOID": gitBlobOID,
        ]
    }

    static let candidateAuthority: JSONObject = [
        "runtime_decoder_implementation": "absent",
        "runtime_dependency_closure": "not_established",
        "initialization": "not_established",
        "prime_proposal": "absent",
        "prime_decision_receipt": "absent",
        "prime_authority": false,
        "execution_authority": false,
        "training_authority": false,
        "promotion_authority": false,
        "product_authority": false,
        "publication_authority": false,
    ]

    static let experimentAuthority: JSONObject = [
        "primeProposalPacket": "absent",
        "primeTrialAuthorization": "absent",
        "primeDecisionReceipt": "absent",
        "candidateSelectionAuthorized": false,
        "trialExecutionAuthorized": false,
        "furtherTrainingAuthorized": false,
        "promotionAuthorized": false,
        "productUseAuthorized": false,
        "publicationAuthorized": false,
    ]

    static let packageManifest = binding(
        scope: "ergentics_llm_repository",
        path: "Package.swift",
        sha256: FixtureConstant.packageManifestSHA256,
        byteCount: 6_109)

    static let dependencyLock = binding(
        scope: "ergentics_llm_repository",
        path: "Package.resolved",
        sha256: FixtureConstant.dependencyLockSHA256,
        byteCount: 645)

    static let initializationContract = binding(
        scope: "ergentics_mlx_lab",
        path: "contracts/latin_initialization_contract_v1.json",
        sha256: String(repeating: "1", count: 64),
        byteCount: 211)

    static func tokenizerRole(
        _ role: String,
        path: String,
        sha256: String,
        byteCount: UInt64
    ) -> JSONObject {
        [
            "role": role,
            "artifact": binding(
                scope: "ergentics_mlx_lab",
                path: path,
                sha256: sha256,
                byteCount: byteCount),
        ]
    }

    static func tokenizerBundle() -> JSONObject {
        let tokenizerManifest = tokenizerRole(
            "tokenizer_manifest",
            path: "tokenizer/ergentics_latin_bpe_v2/manifest.json",
            sha256:
                "b1ae203307de9c657f9d2558875e104d33f62e464c2cb83504d2f2f714ac6b76",
            byteCount: 2_180)
        let sentencePieceModel = tokenizerRole(
            "sentencepiece_model",
            path: "tokenizer/ergentics_latin_bpe_v2/model.spm",
            sha256:
                "3819dbc5381bfd5f52cc8b28e6f1e224ea5e30bdaaaf94dc5307fde91c9cccb5",
            byteCount: 285_705)
        let vocabulary = tokenizerRole(
            "vocabulary",
            path: "tokenizer/ergentics_latin_bpe_v2/vocab.txt",
            sha256:
                "fb7f86c49cca2b9115f55ff559ac76e8977110e1251a3a21baa9e7dc9132c3ce",
            byteCount: 256_196)
        let recommendation = tokenizerRole(
            "recommendation",
            path: "tokenizer/ergentics_latin_bpe_v2/recommendation.json",
            sha256:
                "ce4c3be2e999057a102465593e2c87c4cd7424a7f633427c97c0790c20f34596",
            byteCount: 1_836)
        let approval = tokenizerRole(
            "approval",
            path: "tokenizer/ergentics_latin_bpe_v2/approval.json",
            sha256:
                "34162b2625ba160f0cc3d38c8ec7ef2c8930b0b4376a19bfd9b0fff8c96d936b",
            byteCount: 277)
        let stagedTrainingInput = tokenizerRole(
            "staged_training_input",
            path: "tokenizer/ergentics_latin_bpe_v2/staging/train-input.txt",
            sha256:
                "7a4dbdfc9885d734e802d912c72ee904f957f856ec0e4827a9583a7b8d357e76",
            byteCount: 3_743_426)
        let corpusManifest = tokenizerRole(
            "corpus_manifest",
            path: "corpus/la/L1/primary-corpus-manifest.json",
            sha256:
                "87a4dcdfbbd8a9ad3f297b320bc94012e98835f395d79b6e6d99e6ce410c36b4",
            byteCount: 1_715)
        let corpusInput = tokenizerRole(
            "admitted_corpus_input",
            path: "corpus/la/L1/train.txt",
            sha256:
                "7a4dbdfc9885d734e802d912c72ee904f957f856ec0e4827a9583a7b8d357e76",
            byteCount: 3_743_426)
        return [
            "schema": "ergentics_latin_tokenizer_bundle_v2",
            "tokenizerID": "ergentics_latin_bpe_v2",
            "bindingScope":
                "direct_tokenizer_bundle_and_declared_corpus_manifest",
            "tokenizerManifest": tokenizerManifest,
            "sentencePieceModel": sentencePieceModel,
            "vocabulary": vocabulary,
            "recommendation": recommendation,
            "approval": approval,
            "stagedTrainingInput": stagedTrainingInput,
            "corpusManifest": corpusManifest,
            "manifestListedCorpusInputs": [corpusInput],
            "recommendationApprovalAttributionAssurance":
                "trusted_local_declaration",
            "cryptographicHumanAuthentication": false,
            "corpusProvenanceScope":
                "manifest_declarations_bound_only_admitted_train_bytes_observed",
            "modelSemanticValidation": "opaque_bytes_hash_and_count_only",
            "sentencePieceToolDisposition":
                "third_party_tool_and_format_recorded_provenance_not_independently_replayed",
            "sentencePieceTrainerValidation":
                "recorded_declaration_only_binary_not_observed",
            "trainingReplayStatus": "not_performed",
            "snapshotConsistency":
                "cooperative_descriptor_reads_revalidated_not_atomic",
            "authorityStatus":
                "root_bound_tokenizer_input_only_non_authorizing",
            "authority": [
                "primeProposalAuthority": "absent",
                "architectureAuthority": false,
                "trialExecutionAuthority": false,
                "trainingAuthority": false,
                "promotionAuthority": false,
                "productUseAuthority": false,
            ],
        ]
    }

    static func tokenizerProposal() throws -> JSONObject {
        let bundle = tokenizerBundle()
        let data = try FixtureJSON.canonical(bundle)
        return [
            "schema": "ergentics_latin_tokenizer_proposal_binding_v2",
            "tokenizerBundleSHA256": FixtureJSON.sha256(data),
            "tokenizerBundleByteCount": UInt64(data.count),
            "tokenizerBundle": bundle,
            "bindingScope":
                "full_admitted_tokenizer_bundle_eight_live_inputs",
            "liveRevalidationPolicy":
                "proposal_workspace_descriptor_safe_revalidation_required",
            "publicationStatus": "not_implemented_input_bridge_only",
            "authorityStatus":
                "tokenizer_proposal_input_only_non_authorizing",
        ]
    }
}

private extension FixtureObject {
    static func architecture() -> JSONObject {
        [
            "schema": "ergentics_latin_candidate_architecture_v1",
            "candidate_slug": FixtureConstant.candidateID,
            "fixture_only": true,
            "source_attribution": FixtureConstant.sourceAttribution,
            "cryptographic_human_authentication": false,
            "tokenizer": [
                "tokenizer_id": "ergentics_latin_bpe_v2",
                "proposal_bundle_sha256":
                    FixtureConstant.tokenizerBundleSHA256,
                "proposal_bundle_byte_count": 2_930,
                "vocabulary_size": 16_384,
                "unk_token_id": 0,
                "bos_token_id": 1,
                "eos_token_id": 2,
                "pad_token_id": 3,
            ],
            "geometry": [
                "maximum_sequence_length": 16,
                "model_width": 8,
                "layer_count": 1,
                "attention_head_count": 2,
                "attention_head_width": 4,
                "intermediate_width": 16,
            ],
            "policies": [
                "attention": [
                    "mechanism": "multi_head_self_attention",
                    "causal_mask_policy": "required",
                    "bias_policy": "none",
                ],
                "feed_forward": [
                    "mechanism": "gated_mlp",
                    "activation": "silu",
                    "gating_policy": "multiplicative_gate",
                    "bias_policy": "none",
                ],
                "normalization": [
                    "placement": "pre_norm",
                    "mechanism": "rms_norm",
                    "parameter_policy": "learned_scale_only",
                    "epsilon": [
                        "numerator": 1,
                        "denominator": 100_000,
                    ],
                ],
                "position": "rotary_no_learned_parameters",
                "projection":
                    "token_embedding_tied_output_projection",
            ],
            "ordered_tensors": parameterTensors(),
            "authority_boundary": candidateAuthority,
        ]
    }

    static func parameterTensors() -> [JSONObject] {
        [
            tensor(
                role: "token_embedding_weight",
                storage: "token_embedding_and_output_projection",
                dimensions: [16_384, 8]),
            tensor(
                role: "layer_0_attention_norm_scale",
                storage: "layer_0_attention_norm_scale",
                dimensions: [8]),
            tensor(
                role: "layer_0_attention_query_weight",
                storage: "layer_0_attention_query_weight",
                dimensions: [8, 8]),
            tensor(
                role: "layer_0_attention_key_weight",
                storage: "layer_0_attention_key_weight",
                dimensions: [8, 8]),
            tensor(
                role: "layer_0_attention_value_weight",
                storage: "layer_0_attention_value_weight",
                dimensions: [8, 8]),
            tensor(
                role: "layer_0_attention_output_weight",
                storage: "layer_0_attention_output_weight",
                dimensions: [8, 8]),
            tensor(
                role: "layer_0_feed_forward_norm_scale",
                storage: "layer_0_feed_forward_norm_scale",
                dimensions: [8]),
            tensor(
                role: "layer_0_feed_forward_gate_weight",
                storage: "layer_0_feed_forward_gate_weight",
                dimensions: [16, 8]),
            tensor(
                role: "layer_0_feed_forward_up_weight",
                storage: "layer_0_feed_forward_up_weight",
                dimensions: [16, 8]),
            tensor(
                role: "layer_0_feed_forward_down_weight",
                storage: "layer_0_feed_forward_down_weight",
                dimensions: [8, 16]),
            tensor(
                role: "final_norm_scale",
                storage: "final_norm_scale",
                dimensions: [8]),
            tensor(
                role: "output_projection_weight",
                storage: "token_embedding_and_output_projection",
                dimensions: [16_384, 8]),
        ]
    }

    static func tensor(
        role: String,
        storage: String,
        dimensions: [Int]
    ) -> JSONObject {
        [
            "role": role,
            "storage_id": storage,
            "dimensions": dimensions,
        ]
    }

    static func derivation() -> JSONObject {
        let specifications: [(String, String, [Int], Int, Bool)] = [
            (
                "token_embedding_weight",
                "token_embedding_and_output_projection",
                [16_384, 8], 131_072, true),
            (
                "layer_0_attention_norm_scale",
                "layer_0_attention_norm_scale",
                [8], 8, true),
            (
                "layer_0_attention_query_weight",
                "layer_0_attention_query_weight",
                [8, 8], 64, true),
            (
                "layer_0_attention_key_weight",
                "layer_0_attention_key_weight",
                [8, 8], 64, true),
            (
                "layer_0_attention_value_weight",
                "layer_0_attention_value_weight",
                [8, 8], 64, true),
            (
                "layer_0_attention_output_weight",
                "layer_0_attention_output_weight",
                [8, 8], 64, true),
            (
                "layer_0_feed_forward_norm_scale",
                "layer_0_feed_forward_norm_scale",
                [8], 8, true),
            (
                "layer_0_feed_forward_gate_weight",
                "layer_0_feed_forward_gate_weight",
                [16, 8], 128, true),
            (
                "layer_0_feed_forward_up_weight",
                "layer_0_feed_forward_up_weight",
                [16, 8], 128, true),
            (
                "layer_0_feed_forward_down_weight",
                "layer_0_feed_forward_down_weight",
                [8, 16], 128, true),
            (
                "final_norm_scale",
                "final_norm_scale",
                [8], 8, true),
            (
                "output_projection_weight",
                "token_embedding_and_output_projection",
                [16_384, 8], 131_072, false),
        ]
        let terms: [JSONObject] = specifications.map {
            role, storage, dimensions, count, unique in
            [
                "role": role,
                "storage_id": storage,
                "dimensions": dimensions,
                "element_count": count,
                "counted_as_unique_storage": unique,
            ]
        }
        return [
            "schema": "ergentics_latin_parameter_count_derivation_v1",
            "architecture_schema":
                "ergentics_latin_candidate_architecture_v1",
            "candidate_slug": FixtureConstant.candidateID,
            "fixture_only": true,
            "source_attribution": FixtureConstant.sourceAttribution,
            "cryptographic_human_authentication": false,
            "status": "declarative_recomputed_not_runtime_reconciled",
            "ordered_terms": terms,
            "unique_storage_count": 11,
            "total_parameter_count": 131_736,
            "authority_boundary": candidateAuthority,
        ]
    }

    static let nestedPackageManifest = committed(
        artifact: binding(
            scope: "ergentics_llm_repository",
            path: "Research/Latin/CandidateDeclarations/Package.swift",
            sha256:
                "9d5242248391613382c9c42bb388b1ad1d1597956f272e5d5b410b7891b38b63",
            byteCount: 892),
        gitBlobOID: "67907b47cf941c6e36154dd729b284f64c90ca9b")

    static let declarationSource = committed(
        artifact: binding(
            scope: "ergentics_llm_repository",
            path:
                "Research/Latin/CandidateDeclarations/Sources/" +
                "ErgenticsLatinCandidateDeclarations/" +
                "ErgenticsLatinCandidateDeclarations.swift",
            sha256:
                "676443927b5024c6e58caa562777a27945dad384c6cc88b5d94d11e73c047bc4",
            byteCount: 35_119),
        gitBlobOID: "a951d3710dba072aa7eb8554c60abafdd032cb7f")

    static let architectureArtifact = committed(
        artifact: binding(
            scope: "ergentics_llm_repository",
            path:
                "Research/Latin/candidates/latin_structural_fixture_v1/" +
                "architecture.json",
            sha256: FixtureConstant.architectureSHA256,
            byteCount: 2_794),
        gitBlobOID: "a3a9582003bfdbce2c94707313c0e402955bca9b")

    static let derivationArtifact = committed(
        artifact: binding(
            scope: "ergentics_llm_repository",
            path:
                "Research/Latin/candidates/latin_structural_fixture_v1/" +
                "parameter-count-derivation.json",
            sha256: FixtureConstant.derivationSHA256,
            byteCount: 2_702),
        gitBlobOID: "9957d0b17edd019ce760fdae9907a8ebadf408e3")

    static let committedRootLock = committed(
        artifact: dependencyLock,
        gitBlobOID: "4e822bfadbe5f4dced15a277f4d5423a03d76890")

    static func declarationTargetClosure() -> JSONObject {
        [
            "schema": "ergentics_latin_declaration_target_closure_v1",
            "scope": "nested_declaration_target_only_not_runtime",
            "targetName": "ErgenticsLatinCandidateDeclarations",
            "nestedPackageManifest": nestedPackageManifest,
            "productionSources": [declarationSource],
            "rootPackageLock": committedRootLock,
            "directTargetDependencies": [],
            "reachableLocalTargets": ["ErgenticsLatinCandidateDeclarations"],
            "reachableExternalProducts": [],
            "reachablePackagePins": [],
            "unreachableRootPackagePins": [
                [
                    "identity": "ergentics-mlx-swift",
                    "kind": "remoteSourceControl",
                    "location":
                        "https://github.com/Ergentics/ergentics-mlx-swift",
                    "revision":
                        "d37885a278f1c37484a94d0f401a418735e66519",
                    "reachable_from_declaration_target": false,
                ],
                [
                    "identity": "swift-numerics",
                    "kind": "remoteSourceControl",
                    "location": "https://github.com/apple/swift-numerics",
                    "revision":
                        "0c0290ff6b24942dadb83a929ffaaa1481df04a2",
                    "version": "1.1.1",
                    "reachable_from_declaration_target": false,
                ],
            ],
            "pathDependencyCount": 0,
            "binaryTargetCount": 0,
            "systemLibraryTargetCount": 0,
            "pluginCount": 0,
            "macroCount": 0,
            "unsafeFlagCount": 0,
            "nestedPackageLockStatus": "absent_required",
            "declarationTargetSourceClosure": "established",
            "declarationTargetDependencyClosure": "exact_zero",
        ]
    }
}

private enum FixtureConstructionError: Error {
    case unexpectedFrozenArtifact(String)
    case invalidReceipt
}

private struct PrimeLatinProposalInputsV3Fixture {
    let source: FixtureSource
    let catalogObject: JSONObject
    let experimentObject: JSONObject
    let catalogData: Data
    let experimentData: Data
    let catalogSHA256: String
    let declarationSetData: Data
    let declarationSetSHA256: String
    let declarationBundleSHA256: String
    let candidateIdentitySHA256: String
    let tokenizerBundleData: Data
    let architectureLineData: Data
    let derivationLineData: Data

    init(source: FixtureSource = .legacy) throws {
        let tokenizerBundle = FixtureObject.tokenizerBundle()
        let tokenizerBundleData = try FixtureJSON.canonical(tokenizerBundle)
        guard tokenizerBundleData.count == 2_930,
              FixtureJSON.sha256(tokenizerBundleData)
                == FixtureConstant.tokenizerBundleSHA256 else {
            throw FixtureConstructionError.unexpectedFrozenArtifact(
                "tokenizer_bundle")
        }
        let tokenizerProposal = try FixtureObject.tokenizerProposal()

        let architecture = FixtureObject.architecture()
        let architectureLineData = try FixtureJSON.canonicalLine(architecture)
        guard architectureLineData.count == 2_794,
              FixtureJSON.sha256(architectureLineData)
                == FixtureConstant.architectureSHA256 else {
            throw FixtureConstructionError.unexpectedFrozenArtifact(
                "architecture")
        }
        let derivation = FixtureObject.derivation()
        let derivationLineData = try FixtureJSON.canonicalLine(derivation)
        guard derivationLineData.count == 2_702,
              FixtureJSON.sha256(derivationLineData)
                == FixtureConstant.derivationSHA256 else {
            throw FixtureConstructionError.unexpectedFrozenArtifact(
                "parameter_count_derivation")
        }
        let closure = FixtureObject.declarationTargetClosure()
        let closureData = try FixtureJSON.canonical(closure)
        let identityMaterial: JSONObject = [
            "schema":
                "ergentics_latin_candidate_identity_material_domain_v1",
            "laneID": FixtureConstant.laneID,
            "llmSource": FixtureObject.llmSource(
                repository: source.repository,
                commit: source.commit,
                tree: source.tree),
            "candidateSlug": FixtureConstant.candidateID,
            "sourceAttribution": FixtureConstant.sourceAttribution,
            "tokenizerID": "ergentics_latin_bpe_v2",
            "tokenizerBundleSHA256": FixtureConstant.tokenizerBundleSHA256,
            "tokenizerBundleByteCount": 2_930,
            "tokenizerVocabularySize": 16_384,
            "architectureSHA256": FixtureConstant.architectureSHA256,
            "architectureByteCount": 2_794,
            "parameterCountDerivationSHA256":
                FixtureConstant.derivationSHA256,
            "parameterCountDerivationByteCount": 2_702,
            "declarationTargetClosureSHA256":
                FixtureJSON.sha256(closureData),
            "declarationTargetClosureByteCount": UInt64(closureData.count),
        ]
        let identityData = try FixtureJSON.canonical(identityMaterial)
        let candidateIdentitySHA256 = FixtureJSON.sha256(identityData)
        let declarationBundle: JSONObject = [
            "schema":
                "ergentics_latin_candidate_declaration_input_bundle_v1",
            "laneID": FixtureConstant.laneID,
            "llmSource": FixtureObject.llmSource(
                repository: source.repository,
                commit: source.commit,
                tree: source.tree),
            "tokenizerProposalBinding": tokenizerProposal,
            "nestedPackageManifest": FixtureObject.nestedPackageManifest,
            "productionSources": [FixtureObject.declarationSource],
            "architectureArtifact": FixtureObject.architectureArtifact,
            "architecture": architecture,
            "parameterCountDerivationArtifact":
                FixtureObject.derivationArtifact,
            "parameterCountDerivation": derivation,
            "declarationTargetClosure": closure,
            "identityMaterial": identityMaterial,
            "candidateIdentitySHA256": candidateIdentitySHA256,
            "declarationTargetSourceClosure": "established",
            "declarationTargetDependencyClosure": "exact_zero",
            "parameterCountStatus":
                "declarative_recomputed_not_runtime_reconciled",
            "runtimeDecoderImplementation": "absent",
            "runtimeDependencyClosure": "not_established",
            "initializationStatus": "not_established",
            "publicationStatus": "not_implemented_encode_only",
            "authority": FixtureObject.candidateAuthority,
        ]
        let declarationBundleData = try FixtureJSON.canonical(declarationBundle)
        let declarationBundleSHA256 = FixtureJSON.sha256(declarationBundleData)
        let declarationBinding: JSONObject = [
            "candidateID": FixtureConstant.candidateID,
            "sourceAttribution": FixtureConstant.sourceAttribution,
            "attributionAssurance": "trusted_local_declaration",
            "cryptographicHumanAuthentication": false,
            "candidateIdentitySHA256": candidateIdentitySHA256,
            "declarationBundleSHA256": declarationBundleSHA256,
            "declarationBundleByteCount": UInt64(declarationBundleData.count),
            "declarationBundle": declarationBundle,
        ]
        let declarationSet: JSONObject = [
            "schema": "ergentics_latin_candidate_declaration_set_v3",
            "laneID": FixtureConstant.laneID,
            "candidates": [declarationBinding],
        ]
        let declarationSetData = try FixtureJSON.canonical(declarationSet)
        let declarationSetSHA256 = FixtureJSON.sha256(declarationSetData)

        let quarantine: JSONObject = [
            "policyID":
                "ergentics_latin_first_party_dependency_quarantine_v1",
            "packageManifest": FixtureObject.packageManifest,
            "dependencyLock": FixtureObject.dependencyLock,
            "candidateImplementationSources": [],
            "authorityTargetDependencyCount": 0,
            "lockfilePinScanComplete": true,
            "status": "producer_recomputed_pass",
        ]
        let catalogObject: JSONObject = [
            "schema": "ergentics_latin_candidate_catalog_v3",
            "laneID": FixtureConstant.laneID,
            "llmSource": FixtureObject.llmSource(
                repository: source.repository,
                commit: source.commit,
                tree: source.tree),
            "packageManifest": FixtureObject.packageManifest,
            "dependencyLock": FixtureObject.dependencyLock,
            "tokenizerProposalBinding": tokenizerProposal,
            "initializationContract": FixtureObject.initializationContract,
            "candidateDeclarations": declarationSet,
            "candidateDeclarationSetSHA256": declarationSetSHA256,
            "candidateDeclarationSetByteCount":
                UInt64(declarationSetData.count),
            "ergenticsMLXLocation":
                "https://github.com/Ergentics/ergentics-mlx-swift",
            "ergenticsMLXRevision":
                "d37885a278f1c37484a94d0f401a418735e66519",
            "quarantinePolicyID":
                "ergentics_latin_first_party_dependency_quarantine_v1",
            "proposalInputDependencyQuarantine": quarantine,
            "declarationTargetSourceClosureStatus": "established",
            "declarationTargetDependencyClosureStatus": "exact_zero",
            "runtimeDecoderImplementationStatus": "absent",
            "runtimeCandidateDependencyClosureStatus": "not_established",
            "initializationStatus":
                "contract_bound_runtime_initialization_not_established",
            "parameterCountStatus":
                "declarative_recomputed_not_runtime_reconciled",
            "completenessStatus":
                "candidate_declaration_bound_decoder_absent_runtime_initialization_and_runtime_dependency_closure_not_established_by_bridge",
            "primeConsumerStatus": "not_implemented_v3",
            "publicationStatus": "not_implemented_input_bridge_only",
            "authorityStatus":
                "root_bound_declaration_proposal_input_v3_only_non_authorizing",
        ]
        let catalogData = try FixtureJSON.canonical(catalogObject)
        let catalogSHA256 = FixtureJSON.sha256(catalogData)

        let corpusManifest = FixtureObject.binding(
            scope: "ergentics_mlx_lab",
            path: "corpus/la/L1/prospective-manifest-v3.json",
            sha256: String(repeating: "2", count: 64),
            byteCount: 307)
        let evaluationContract = source == .finalHandoff
            ? FixtureObject.binding(
                scope: "ergentics_llm_repository",
                path: FixtureConstant.finalEvaluationContractPath,
                sha256: FixtureConstant.finalEvaluationContractSHA256,
                byteCount: FixtureConstant.finalEvaluationContractByteCount)
            : FixtureObject.binding(
                scope: "ergentics_llm_repository",
                path:
                    "Research/Latin/evaluation/prospective-contract-v3.json",
                sha256: String(repeating: "3", count: 64),
                byteCount: 401)
        let trainingSplit = FixtureObject.binding(
            scope: "ergentics_mlx_lab",
            path: "corpus/la/L1/prospective-train-v3.txt",
            sha256: String(repeating: "4", count: 64),
            byteCount: 1_001)
        let validationSplit = FixtureObject.binding(
            scope: "ergentics_mlx_lab",
            path: "corpus/la/L1/prospective-validation-v3.txt",
            sha256: String(repeating: "5", count: 64),
            byteCount: 503)
        let selectionSplit = FixtureObject.binding(
            scope: "ergentics_mlx_lab",
            path: "corpus/la/L1/prospective-selection-v3.txt",
            sha256: String(repeating: "6", count: 64),
            byteCount: 509)
        let observationDeclaration = FixtureObject.binding(
            scope: "ergentics_mlx_lab",
            path: "corpus/la/L1/prospective-selection-observation-v3.json",
            sha256: String(repeating: "7", count: 64),
            byteCount: 233)
        let splits: JSONObject = [
            "trainingSplitID": "latin_train_v3",
            "validationSplitID": "latin_validation_v3",
            "selectionSplitID": "latin_selection_v3",
            "selectionDataStatus": "trusted_local_declared_unverified",
            "trainingSplit": trainingSplit,
            "validationSplit": validationSplit,
            "selectionSplit": selectionSplit,
            "selectionObservationDeclaration": observationDeclaration,
        ]
        let experimentObject: JSONObject = [
            "schema": "ergentics_latin_experiment_manifest_v3",
            "laneID": FixtureConstant.laneID,
            "llmSource": FixtureObject.llmSource(
                repository: source.repository,
                commit: source.commit,
                tree: source.tree),
            "candidateCatalogSHA256": catalogSHA256,
            "candidateCatalogByteCount": UInt64(catalogData.count),
            "candidateDeclarationSetSHA256": declarationSetSHA256,
            "candidateDeclarationSetByteCount":
                UInt64(declarationSetData.count),
            "candidateIDs": [FixtureConstant.candidateID],
            "dependencyLock": FixtureObject.dependencyLock,
            "tokenizerBundleSHA256": FixtureConstant.tokenizerBundleSHA256,
            "tokenizerBundleByteCount": 2_930,
            "initializationContract": FixtureObject.initializationContract,
            "corpusManifest": corpusManifest,
            "evaluationContract": evaluationContract,
            "splits": splits,
            "requestedTrialBudget": [
                "application": "identical_per_candidate_requested_ceiling",
                "optimizerSteps": 12,
                "trainingTokens": 4_096,
                "wallClockSeconds": 600,
            ],
            "outputNamespace": FixtureConstant.outputNamespace,
            "outputDisposition":
                "must_be_absent_create_once_non_restorable",
            "completenessStatus":
                "evaluator_and_prospective_data_completeness_not_established_by_bridge",
            "primeConsumerStatus": "not_implemented_v3",
            "publicationStatus": "not_implemented_input_bridge_only",
            "authority": FixtureObject.experimentAuthority,
        ]
        let experimentData = try FixtureJSON.canonical(experimentObject)

        self.source = source
        self.catalogObject = catalogObject
        self.experimentObject = experimentObject
        self.catalogData = catalogData
        self.experimentData = experimentData
        self.catalogSHA256 = catalogSHA256
        self.declarationSetData = declarationSetData
        self.declarationSetSHA256 = declarationSetSHA256
        self.declarationBundleSHA256 = declarationBundleSHA256
        self.candidateIdentitySHA256 = candidateIdentitySHA256
        self.tokenizerBundleData = tokenizerBundleData
        self.architectureLineData = architectureLineData
        self.derivationLineData = derivationLineData
    }
}

private struct FinalPublisherReceiptSourceV3: Encodable {
    let repository: String
    let commit: String
    let tree: String

    init(_ source: FixtureSource) {
        repository = source.repository
        commit = source.commit
        tree = source.tree
    }
}

private struct FinalPublisherPublishedDocumentV3: Encodable {
    let documentKind: String
    let relativePath: String
    let sha256: String
    let byteCount: UInt64
}

private struct FinalPublisherReceiptAuthorityV3: Encodable {
    let primeProposalPacket = "absent"
    let primeTrialAuthorization = "absent"
    let primeDecisionReceipt = "absent"
    let candidateSelectionAuthorized = false
    let trialExecutionAuthorized = false
    let furtherTrainingAuthorized = false
    let promotionAuthorized = false
    let productUseAuthorized = false
    let publicationAuthorized = false
}

private struct FinalPublisherReceiptV3: Encodable {
    let schema = "ergentics_latin_proposal_pair_receipt_v3"
    let llmSource: FinalPublisherReceiptSourceV3
    let candidateCatalog: FinalPublisherPublishedDocumentV3
    let experimentManifest: FinalPublisherPublishedDocumentV3
    let candidateDeclarationSetSHA256: String
    let candidateDeclarationSetByteCount: UInt64
    let publicationMechanicsStatus =
        "content_addressed_create_once_pair_complete"
    let authorityStatus = "mechanics_only_non_authorizing"
    let completionScope = "canonical_v3_catalog_experiment_pair_only"
    let referencedInputSnapshot = "absent"
    let referencedArtifactBytes =
        "absent_from_pair_except_catalog_and_experiment_children"
    let independentReplayStatus =
        "requires_original_bound_input_bytes_and_live_provenance"
    let primeConsumerStatus =
        "prime_consumer_state_not_observed_by_producer"
    let externalStateCommitAtomicity =
        "absent_live_roots_revalidated_before_receipt_rename"
    let publicationCoordination = "cooperative_process_lock_only"
    let authority = FinalPublisherReceiptAuthorityV3()
}

private struct FinalPublisherPairCaptureFixture {
    let labRoot: URL
    let inputs: PrimeLatinProposalInputsV3Fixture
    let receiptData: Data
    let pairSHA256: String
    let pairURL: URL
    let catalogURL: URL
    let experimentURL: URL
    private let cleanup: FinalPublisherFixtureRoot

    init(
        source: FixtureSource = .finalHandoff,
        receiptMutation: ((inout JSONObject) -> Void)? = nil,
        receiptDataMutation: ((Data) -> Data)? = nil
    ) throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(
            "prime-latin-v3-pair-capture-\(UUID().uuidString)",
            isDirectory: true)
        try FileManager.default.createDirectory(
            at: root,
            withIntermediateDirectories: true)
        let canonicalRoot = root.resolvingSymlinksInPath().standardizedFileURL
        let cleanup = FinalPublisherFixtureRoot(root)

        let inputs = try PrimeLatinProposalInputsV3Fixture(source: source)
        let experimentSHA256 = FixtureJSON.sha256(inputs.experimentData)
        let publicationRoot = "evidence/latin-proposal-artifacts/v3"
        let catalogPath = publicationRoot +
            "/catalogs/\(inputs.catalogSHA256).json"
        let experimentPath = publicationRoot +
            "/experiments/\(experimentSHA256).json"
        let receipt = FinalPublisherReceiptV3(
            llmSource: FinalPublisherReceiptSourceV3(inputs.source),
            candidateCatalog: FinalPublisherPublishedDocumentV3(
                documentKind: "candidate_catalog_v3",
                relativePath: catalogPath,
                sha256: inputs.catalogSHA256,
                byteCount: UInt64(inputs.catalogData.count)),
            experimentManifest: FinalPublisherPublishedDocumentV3(
                documentKind: "experiment_manifest_v3",
                relativePath: experimentPath,
                sha256: experimentSHA256,
                byteCount: UInt64(inputs.experimentData.count)),
            candidateDeclarationSetSHA256: inputs.declarationSetSHA256,
            candidateDeclarationSetByteCount:
                UInt64(inputs.declarationSetData.count))
        var receiptData = try FixtureJSON.canonicalEncodable(receipt)
        if let receiptMutation {
            guard var receiptObject = try JSONSerialization.jsonObject(
                with: receiptData) as? JSONObject else {
                throw FixtureConstructionError.invalidReceipt
            }
            receiptMutation(&receiptObject)
            receiptData = try FixtureJSON.canonical(receiptObject)
        }
        receiptData = receiptDataMutation?(receiptData) ?? receiptData
        let pairSHA256 = FixtureJSON.sha256(receiptData)
        let pairPath = publicationRoot + "/pairs/\(pairSHA256).json"

        let catalogURL = try Self.writeFinal(
            inputs.catalogData,
            root: canonicalRoot,
            relativePath: catalogPath)
        let experimentURL = try Self.writeFinal(
            inputs.experimentData,
            root: canonicalRoot,
            relativePath: experimentPath)
        let pairURL = try Self.writeFinal(
            receiptData,
            root: canonicalRoot,
            relativePath: pairPath)

        self.labRoot = canonicalRoot
        self.inputs = inputs
        self.receiptData = receiptData
        self.pairSHA256 = pairSHA256
        self.pairURL = pairURL
        self.catalogURL = catalogURL
        self.experimentURL = experimentURL
        self.cleanup = cleanup
    }

    private static func writeFinal(
        _ data: Data,
        root: URL,
        relativePath: String
    ) throws -> URL {
        let url = root.appendingPathComponent(relativePath)
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true)
        try data.write(to: url, options: .withoutOverwriting)
        try FileManager.default.setAttributes(
            [.posixPermissions: 0o444],
            ofItemAtPath: url.path)
        return url
    }
}

private final class FinalPublisherFixtureRoot {
    private let root: URL

    init(_ root: URL) {
        self.root = root
    }

    deinit {
        try? FileManager.default.removeItem(at: root)
    }
}

private enum FixtureRepair {
    static func embeddedHashChain(
        catalog: inout JSONObject,
        experiment: inout JSONObject
    ) throws {
        var declarationSet = try FixtureMutation.object(
            catalog,
            path: [.key("candidateDeclarations")])
        guard let rawCandidates = declarationSet["candidates"] as? [Any] else {
            throw FixtureMutationError.invalidPath
        }
        var candidates = [JSONObject]()
        candidates.reserveCapacity(rawCandidates.count)
        for rawCandidate in rawCandidates {
            guard var candidate = rawCandidate as? JSONObject,
                  var bundle = candidate["declarationBundle"] as? JSONObject,
                  let architecture = bundle["architecture"] as? JSONObject,
                  let derivation = bundle["parameterCountDerivation"]
                    as? JSONObject,
                  let closure = bundle["declarationTargetClosure"]
                    as? JSONObject,
                  var identity = bundle["identityMaterial"] as? JSONObject
            else {
                throw FixtureMutationError.invalidPath
            }

            let architectureData = try FixtureJSON.canonicalLine(architecture)
            var architectureArtifact = try FixtureMutation.object(
                bundle,
                path: [.key("architectureArtifact")])
            var architectureBinding = try FixtureMutation.object(
                architectureArtifact,
                path: [.key("artifact")])
            architectureBinding["sha256"] = FixtureJSON.sha256(architectureData)
            architectureBinding["byteCount"] = UInt64(architectureData.count)
            architectureArtifact["artifact"] = architectureBinding
            bundle["architectureArtifact"] = architectureArtifact
            identity["architectureSHA256"] =
                FixtureJSON.sha256(architectureData)
            identity["architectureByteCount"] = UInt64(architectureData.count)

            let derivationData = try FixtureJSON.canonicalLine(derivation)
            var derivationArtifact = try FixtureMutation.object(
                bundle,
                path: [.key("parameterCountDerivationArtifact")])
            var derivationBinding = try FixtureMutation.object(
                derivationArtifact,
                path: [.key("artifact")])
            derivationBinding["sha256"] = FixtureJSON.sha256(derivationData)
            derivationBinding["byteCount"] = UInt64(derivationData.count)
            derivationArtifact["artifact"] = derivationBinding
            bundle["parameterCountDerivationArtifact"] = derivationArtifact
            identity["parameterCountDerivationSHA256"] =
                FixtureJSON.sha256(derivationData)
            identity["parameterCountDerivationByteCount"] =
                UInt64(derivationData.count)

            let closureData = try FixtureJSON.canonical(closure)
            identity["declarationTargetClosureSHA256"] =
                FixtureJSON.sha256(closureData)
            identity["declarationTargetClosureByteCount"] =
                UInt64(closureData.count)
            let identityData = try FixtureJSON.canonical(identity)
            let candidateIdentitySHA256 = FixtureJSON.sha256(identityData)
            bundle["identityMaterial"] = identity
            bundle["candidateIdentitySHA256"] = candidateIdentitySHA256
            candidate["candidateIdentitySHA256"] = candidateIdentitySHA256

            let bundleData = try FixtureJSON.canonical(bundle)
            candidate["declarationBundle"] = bundle
            candidate["declarationBundleSHA256"] =
                FixtureJSON.sha256(bundleData)
            candidate["declarationBundleByteCount"] = UInt64(bundleData.count)
            candidates.append(candidate)
        }
        declarationSet["candidates"] = candidates
        let declarationSetData = try FixtureJSON.canonical(declarationSet)
        catalog["candidateDeclarations"] = declarationSet
        catalog["candidateDeclarationSetSHA256"] =
            FixtureJSON.sha256(declarationSetData)
        catalog["candidateDeclarationSetByteCount"] =
            UInt64(declarationSetData.count)
        experiment["candidateDeclarationSetSHA256"] =
            FixtureJSON.sha256(declarationSetData)
        experiment["candidateDeclarationSetByteCount"] =
            UInt64(declarationSetData.count)
        experiment["candidateIDs"] = candidates.compactMap {
            $0["candidateID"] as? String
        }
        try catalogHash(catalog: catalog, experiment: &experiment)
    }

    static func outerCandidateHashChain(
        catalog: inout JSONObject,
        experiment: inout JSONObject
    ) throws {
        var declarationSet = try FixtureMutation.object(
            catalog,
            path: [.key("candidateDeclarations")])
        guard let rawCandidates = declarationSet["candidates"] as? [Any] else {
            throw FixtureMutationError.invalidPath
        }
        var candidates = [JSONObject]()
        candidates.reserveCapacity(rawCandidates.count)
        for rawCandidate in rawCandidates {
            guard var candidate = rawCandidate as? JSONObject,
                  let bundle = candidate["declarationBundle"] as? JSONObject
            else {
                throw FixtureMutationError.invalidPath
            }
            let bundleData = try FixtureJSON.canonical(bundle)
            candidate["declarationBundleSHA256"] =
                FixtureJSON.sha256(bundleData)
            candidate["declarationBundleByteCount"] = UInt64(bundleData.count)
            candidates.append(candidate)
        }
        declarationSet["candidates"] = candidates
        let declarationSetData = try FixtureJSON.canonical(declarationSet)
        catalog["candidateDeclarations"] = declarationSet
        catalog["candidateDeclarationSetSHA256"] =
            FixtureJSON.sha256(declarationSetData)
        catalog["candidateDeclarationSetByteCount"] =
            UInt64(declarationSetData.count)
        experiment["candidateDeclarationSetSHA256"] =
            FixtureJSON.sha256(declarationSetData)
        experiment["candidateDeclarationSetByteCount"] =
            UInt64(declarationSetData.count)
        experiment["candidateIDs"] = candidates.compactMap {
            $0["candidateID"] as? String
        }
        try catalogHash(catalog: catalog, experiment: &experiment)
    }

    static func catalogHash(
        catalog: JSONObject,
        experiment: inout JSONObject
    ) throws {
        let catalogData = try FixtureJSON.canonical(catalog)
        experiment["candidateCatalogSHA256"] = FixtureJSON.sha256(catalogData)
        experiment["candidateCatalogByteCount"] = UInt64(catalogData.count)
    }
}
