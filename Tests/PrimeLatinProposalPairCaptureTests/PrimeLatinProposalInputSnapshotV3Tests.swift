import CryptoKit
import Foundation
import XCTest
@testable import PrimeLatinProposalPairCapture

final class PrimeLatinProposalInputSnapshotV3Tests: XCTestCase {
    func testFinalPairExtractsExactTwentyOneRoleProductionPlan() throws {
        let pair = try PrimeLatinProposalSnapshotPublishedPairFixture()
        let material = try PrimeLatinProposalInputsV3.inputSnapshotMaterial(
            candidateCatalogData: Data(contentsOf: pair.catalogURL),
            experimentManifestData: Data(contentsOf: pair.experimentURL))

        XCTAssertEqual(
            material.expectations.map {
                $0.role + "|" + $0.scope.rawValue + "|" +
                    $0.relativePath + "|" + $0.sha256 + "|" +
                    String($0.byteCount)
            },
            Self.productionGoldenBindings)
        XCTAssertEqual(
            material.outputNamespace,
            "models/latin-prospective/golden-v3-input")
        XCTAssertEqual(
            material.inputsObservation.llmSource.commit,
            "776c412e3f10e8bf4e33cd0ae60787d9ca6b5831")
        XCTAssertEqual(
            material.inputsObservation.llmSource.tree,
            "c1f41758aea2860ab06039776f5ea0403dff1b61")
    }

    func testCapturesExactTwentyOneRoleSnapshotAndRemainsAbstaining()
        throws
    {
        let fixture = try InputSnapshotFixtureV3()
        let capture = try fixture.capture()
        let observation = capture.observation

        XCTAssertEqual(
            observation.schema,
            "ergentics_prime_latin_proposal_input_snapshot_v3_observation")
        XCTAssertEqual(observation.outcome, "abstain")
        XCTAssertEqual(
            observation.verificationScope,
            "descriptor_safe_exact_v3_original_bound_input_snapshot_only_" +
                "non_authorizing")
        XCTAssertEqual(observation.pairReceiptSHA256, fixture.pairSHA256)
        XCTAssertEqual(
            observation.llmSource.repository,
            "Ergentics/ergentics-llm")
        XCTAssertEqual(
            observation.llmSource.commit,
            "776c412e3f10e8bf4e33cd0ae60787d9ca6b5831")
        XCTAssertEqual(
            observation.llmSource.tree,
            "c1f41758aea2860ab06039776f5ea0403dff1b61")
        XCTAssertEqual(observation.artifactCount, 21)
        XCTAssertEqual(observation.artifacts.count, 21)
        XCTAssertEqual(
            observation.artifacts.map { $0.roles },
            fixture.artifacts.map { [$0.role] })
        XCTAssertEqual(
            observation.artifacts.map { $0.scope },
            fixture.artifacts.map { $0.scope })
        XCTAssertEqual(
            observation.artifacts.map { $0.relativePath },
            fixture.artifacts.map { $0.relativePath })
        XCTAssertEqual(
            observation.artifacts.map { $0.sha256 },
            fixture.artifacts.map { $0.sha256 })
        XCTAssertEqual(
            observation.artifacts.map { $0.byteCount },
            fixture.artifacts.map { UInt64($0.data.count) })
        XCTAssertEqual(
            observation.artifacts.map { $0.actualMode },
            fixture.artifacts.map { $0.mode })
        XCTAssertEqual(
            Array(observation.artifacts.prefix(7).map { $0.actualMode }),
            Array(repeating: UInt16(0o644), count: 7))
        XCTAssertTrue(
            observation.artifacts.dropFirst(7).contains {
                $0.actualMode == 0o644
            })
        XCTAssertTrue(
            observation.artifacts.dropFirst(7).contains {
                $0.actualMode == 0o444
            })
        XCTAssertEqual(observation.outputNamespace, fixture.outputNamespace)

        let duplicateHashes = Dictionary(
            grouping: observation.artifacts,
            by: { $0.sha256 }
        ).values.filter { $0.count > 1 }
        XCTAssertEqual(duplicateHashes.count, 1)
        XCTAssertEqual(
            Set(duplicateHashes[0].flatMap { $0.roles }),
            [
                "tokenizer_staged_training_input",
                "tokenizer_admitted_corpus_input",
            ])
        XCTAssertEqual(try fixture.uniqueDeviceAndInodeCount(), 21)

        let authority = observation.authority
        XCTAssertEqual(
            authority.disposition,
            "abstain_snapshot_mechanics_only_requires_live_producer_" +
                "revalidation_git_observation_and_independent_replay")
        XCTAssertTrue(authority.stablePairRootBoundCaptureComplete)
        XCTAssertTrue(authority.stableLLMRepositoryRootBoundCaptureComplete)
        XCTAssertTrue(authority.stableLabRootBoundCaptureComplete)
        XCTAssertTrue(authority.artifactPathRoleHashCountBindingsVerified)
        XCTAssertTrue(authority.outputNamespaceAbsenceVerified)
        XCTAssertTrue(authority.pairCaptureAndRecaptureComplete)
        XCTAssertTrue(authority.referencedInputSnapshotAvailable)
        XCTAssertTrue(authority.referencedArtifactBytesAvailable)
        XCTAssertFalse(authority.durableInputSnapshotPublished)
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

    func testRejectsMissingMutatedSwappedAndSemanticInputBytes() throws {
        let missing = try InputSnapshotFixtureV3()
        try FileManager.default.removeItem(
            at: missing.url(for: "tokenizer_manifest"))
        assertCaptureFails(missing)

        let mutated = try InputSnapshotFixtureV3()
        var sameLengthMutation = mutated.data(for: "tokenizer_vocabulary")
        sameLengthMutation[0] ^= 0x20
        XCTAssertEqual(
            sameLengthMutation.count,
            mutated.data(for: "tokenizer_vocabulary").count)
        try mutated.replace(
            role: "tokenizer_vocabulary",
            with: sameLengthMutation)
        assertCaptureFails(mutated)

        let swapped = try InputSnapshotFixtureV3()
        let training = swapped.data(for: "training_split")
        let validation = swapped.data(for: "validation_split")
        try swapped.replace(role: "training_split", with: validation)
        try swapped.replace(role: "validation_split", with: training)
        assertCaptureFails(swapped)

        let lineContract = try InputSnapshotFixtureV3()
        var selection = lineContract.data(for: "selection_split")
        XCTAssertEqual(selection.last, 0x0A)
        selection.removeLast()
        try lineContract.replace(role: "selection_split", with: selection)
        assertCaptureFails(lineContract)

        let initialization = try InputSnapshotFixtureV3()
        let changedInitialization = initialization.data(
            for: "initialization_contract"
        ).replacingUTF8(
            "\"freshInitializationRequired\":true",
            with: "\"freshInitializationRequired\":false")
        try initialization.replace(
            role: "initialization_contract",
            with: changedInitialization)
        assertCaptureFails(initialization)

        let evaluation = try InputSnapshotFixtureV3()
        let changedEvaluation = evaluation.data(
            for: "evaluation_contract"
        ).replacingUTF8(
            "\"thresholds_observed\":false",
            with: "\"thresholds_observed\":true")
        try evaluation.replace(
            role: "evaluation_contract",
            with: changedEvaluation)
        assertCaptureFails(evaluation)

        let corpus = try InputSnapshotFixtureV3()
        let changedCorpus = corpus.data(
            for: "prospective_corpus_manifest"
        ).replacingUTF8(
            "\"training_id\":\"latin_fixture_train_v3\"",
            with: "\"training_id\":\"validation_alias\"")
        try corpus.replace(
            role: "prospective_corpus_manifest",
            with: changedCorpus)
        assertCaptureFails(corpus)
    }

    func testRejectsInventoryAliasesRoleDriftAndOutputOverlap() throws {
        let fixture = try InputSnapshotFixtureV3()

        var reordered = fixture.expectations
        reordered.swapAt(0, 1)
        assertCaptureFails(fixture, expectations: reordered)

        var wrongScope = fixture.expectations
        wrongScope[0] = wrongScope[0].replacing(
            scope: .ergenticsMLXLab)
        assertCaptureFails(fixture, expectations: wrongScope)

        var locationAlias = fixture.expectations
        locationAlias[1] = locationAlias[1].replacing(
            relativePath: locationAlias[0].relativePath.uppercased())
        assertCaptureFails(fixture, expectations: locationAlias)

        var hashAlias = fixture.expectations
        hashAlias[0] = hashAlias[0].replacing(
            sha256: hashAlias[1].sha256,
            byteCount: hashAlias[1].byteCount)
        assertCaptureFails(fixture, expectations: hashAlias)

        var unsafePath = fixture.expectations
        unsafePath[0] = unsafePath[0].replacing(relativePath: "../Package.swift")
        assertCaptureFails(fixture, expectations: unsafePath)

        let aggregateOversize = fixture.expectations.map {
            $0.replacing(byteCount: 4_000_000)
        }
        XCTAssertGreaterThan(
            aggregateOversize.reduce(UInt64(0)) { $0 + $1.byteCount },
            64 * 1_024 * 1_024)
        assertCaptureFails(fixture, expectations: aggregateOversize)

        assertCaptureFails(
            fixture,
            outputNamespace: fixture.relativePath(for: "training_split"))
    }

    func testRejectsSymlinksHardlinksUnsafeModesAndRootAliases() throws {
        let symlink = try InputSnapshotFixtureV3()
        let selectionURL = symlink.url(for: "selection_split")
        try FileManager.default.removeItem(at: selectionURL)
        try FileManager.default.createSymbolicLink(
            at: selectionURL,
            withDestinationURL: symlink.url(for: "training_split"))
        assertCaptureFails(symlink)

        let hardlink = try InputSnapshotFixtureV3()
        let admittedURL = hardlink.url(
            for: "tokenizer_admitted_corpus_input")
        try FileManager.default.removeItem(at: admittedURL)
        try FileManager.default.linkItem(
            at: hardlink.url(for: "tokenizer_staged_training_input"),
            to: admittedURL)
        assertCaptureFails(hardlink)

        let unsafeMode = try InputSnapshotFixtureV3()
        try FileManager.default.setAttributes(
            [.posixPermissions: 0o664],
            ofItemAtPath: unsafeMode.url(for: "tokenizer_approval").path)
        assertCaptureFails(unsafeMode)

        let sameRoot = try InputSnapshotFixtureV3()
        assertCaptureFails(
            sameRoot,
            llmRepositoryRoot: sameRoot.labRoot)

        let nestedRoot = try InputSnapshotFixtureV3()
        let nestedURL = nestedRoot.labRoot.appendingPathComponent(
            "nested-llm-root",
            isDirectory: true)
        try FileManager.default.createDirectory(
            at: nestedURL,
            withIntermediateDirectories: false)
        assertCaptureFails(
            nestedRoot,
            llmRepositoryRoot: nestedURL)

        let aliasRoot = try InputSnapshotFixtureV3()
        let aliasURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(
                "prime-latin-v3-snapshot-root-alias-\(UUID().uuidString)")
        try FileManager.default.createSymbolicLink(
            at: aliasURL,
            withDestinationURL: aliasRoot.llmRepositoryRoot)
        defer { try? FileManager.default.removeItem(at: aliasURL) }
        assertCaptureFails(
            aliasRoot,
            llmRepositoryRoot: aliasURL)
    }

    func testRejectsLateInputOutputRootAndPairChangesAndRecaptureDrift()
        throws
    {
        let lateInput = try InputSnapshotFixtureV3()
        assertCaptureFails(lateInput) {
            try lateInput.replace(
                role: "tokenizer_recommendation",
                with: Data("late mutation\n".utf8))
        }

        let lateOutput = try InputSnapshotFixtureV3()
        XCTAssertThrowsError(
            try lateOutput.capture {
                try FileManager.default.createDirectory(
                    at: lateOutput.outputURL,
                    withIntermediateDirectories: true)
            }
        ) { error in
            XCTAssertEqual(
                error as? PrimeLatinProposalInputSnapshotError,
                .outputNamespacePresent(lateOutput.outputNamespace))
        }

        let existingOutput = try InputSnapshotFixtureV3()
        try FileManager.default.createDirectory(
            at: existingOutput.outputURL,
            withIntermediateDirectories: true)
        XCTAssertThrowsError(try existingOutput.capture()) { error in
            XCTAssertEqual(
                error as? PrimeLatinProposalInputSnapshotError,
                .outputNamespacePresent(existingOutput.outputNamespace))
        }

        let rootChange = try InputSnapshotFixtureV3()
        assertCaptureFails(rootChange) {
            try Data("root identity mutation\n".utf8).write(
                to: rootChange.labRoot.appendingPathComponent(
                    "late-root-marker"),
                options: .withoutOverwriting)
        }


        let repositoryRootChange = try InputSnapshotFixtureV3()
        assertCaptureFails(repositoryRootChange) {
            try Data("repository root identity mutation\n".utf8).write(
                to: repositoryRootChange.llmRepositoryRoot
                    .appendingPathComponent("late-repository-root-marker"),
                options: .withoutOverwriting)
        }

        let pairChange = try InputSnapshotFixtureV3()
        assertCaptureFails(pairChange) {
            try FileManager.default.setAttributes(
                [.posixPermissions: 0o644],
                ofItemAtPath: pairChange.pairURL.path)
        }

        let inputRecapture = try InputSnapshotFixtureV3()
        let inputCapture = try inputRecapture.capture()
        try inputRecapture.replace(
            role: "candidate_architecture",
            with: Data("post-capture architecture mutation\n".utf8))
        XCTAssertThrowsError(
            try inputCapture.recaptureAndValidateUnchanged()
        ) { error in
            XCTAssertEqual(
                error as? PrimeLatinProposalInputSnapshotError,
                .captureChanged)
        }

        let pairRecapture = try InputSnapshotFixtureV3()
        let pairCapture = try pairRecapture.capture()
        try FileManager.default.setAttributes(
            [.posixPermissions: 0o644],
            ofItemAtPath: pairRecapture.pairURL.path)
        XCTAssertThrowsError(
            try pairCapture.recaptureAndValidateUnchanged()
        ) { error in
            XCTAssertEqual(
                error as? PrimeLatinProposalInputSnapshotError,
                .captureChanged)
        }
    }

    private func assertCaptureFails(
        _ fixture: InputSnapshotFixtureV3,
        llmRepositoryRoot: URL? = nil,
        expectations: [PrimeLatinProposalInputArtifactExpectationV3]? = nil,
        outputNamespace: String? = nil,
        beforeFinalRecapture: () throws -> Void = {},
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(
            try fixture.capture(
                llmRepositoryRoot: llmRepositoryRoot,
                expectations: expectations,
                outputNamespace: outputNamespace,
                beforeFinalRecapture: beforeFinalRecapture),
            file: file,
            line: line)
    }

    private static let productionGoldenBindings = [
        "root_package_manifest|ergentics_llm_repository|Package.swift|" +
            "ab460122d5f364046224c6445a20f3beb34e2831de94db1271bbafb59726c902|6109",
        "root_dependency_lock|ergentics_llm_repository|Package.resolved|" +
            "2847fb936ec74eef250b8439d778f0a1ea8d0c630bf09438587764a4b99c6530|645",
        "declaration_package_manifest|ergentics_llm_repository|" +
            "Research/Latin/CandidateDeclarations/Package.swift|" +
            "9d5242248391613382c9c42bb388b1ad1d1597956f272e5d5b410b7891b38b63|892",
        "declaration_production_source|ergentics_llm_repository|" +
            "Research/Latin/CandidateDeclarations/Sources/" +
            "ErgenticsLatinCandidateDeclarations/" +
            "ErgenticsLatinCandidateDeclarations.swift|" +
            "676443927b5024c6e58caa562777a27945dad384c6cc88b5d94d11e73c047bc4|35119",
        "candidate_architecture|ergentics_llm_repository|Research/Latin/" +
            "candidates/latin_structural_fixture_v1/architecture.json|" +
            "4b31feeeba780bc39c064d4540f5701935f960e1e1d8c82c81d295a65e643a70|2794",
        "candidate_parameter_count_derivation|ergentics_llm_repository|" +
            "Research/Latin/candidates/latin_structural_fixture_v1/" +
            "parameter-count-derivation.json|" +
            "45d15481883cf606e8e739aa71815bf9bd2fdd51494059328e3ba16a9ed5fb8f|2702",
        "evaluation_contract|ergentics_llm_repository|" +
            "Research/Latin/evaluation_contract.json|" +
            "4a0dd1bc973f7ce380df9775413c4e43033ba0cc409fb45a9368c2bef6835d52|164",
        "tokenizer_manifest|ergentics_mlx_lab|tokenizer/" +
            "ergentics_latin_bpe_v2/manifest.json|" +
            "b1ae203307de9c657f9d2558875e104d33f62e464c2cb83504d2f2f714ac6b76|2180",
        "tokenizer_sentencepiece_model|ergentics_mlx_lab|tokenizer/" +
            "ergentics_latin_bpe_v2/model.spm|" +
            "3819dbc5381bfd5f52cc8b28e6f1e224ea5e30bdaaaf94dc5307fde91c9cccb5|285705",
        "tokenizer_vocabulary|ergentics_mlx_lab|tokenizer/" +
            "ergentics_latin_bpe_v2/vocab.txt|" +
            "fb7f86c49cca2b9115f55ff559ac76e8977110e1251a3a21baa9e7dc9132c3ce|256196",
        "tokenizer_recommendation|ergentics_mlx_lab|tokenizer/" +
            "ergentics_latin_bpe_v2/recommendation.json|" +
            "ce4c3be2e999057a102465593e2c87c4cd7424a7f633427c97c0790c20f34596|1836",
        "tokenizer_approval|ergentics_mlx_lab|tokenizer/" +
            "ergentics_latin_bpe_v2/approval.json|" +
            "34162b2625ba160f0cc3d38c8ec7ef2c8930b0b4376a19bfd9b0fff8c96d936b|277",
        "tokenizer_staged_training_input|ergentics_mlx_lab|tokenizer/" +
            "ergentics_latin_bpe_v2/staging/train-input.txt|" +
            "7a4dbdfc9885d734e802d912c72ee904f957f856ec0e4827a9583a7b8d357e76|3743426",
        "tokenizer_corpus_manifest|ergentics_mlx_lab|" +
            "corpus/la/L1/primary-corpus-manifest.json|" +
            "87a4dcdfbbd8a9ad3f297b320bc94012e98835f395d79b6e6d99e6ce410c36b4|1715",
        "tokenizer_admitted_corpus_input|ergentics_mlx_lab|" +
            "corpus/la/L1/train.txt|" +
            "7a4dbdfc9885d734e802d912c72ee904f957f856ec0e4827a9583a7b8d357e76|3743426",
        "initialization_contract|ergentics_mlx_lab|" +
            "contracts/latin_initialization_contract_v1.json|" +
            String(repeating: "1", count: 64) + "|211",
        "prospective_corpus_manifest|ergentics_mlx_lab|" +
            "corpus/la/L1/prospective-manifest-v3.json|" +
            String(repeating: "2", count: 64) + "|307",
        "training_split|ergentics_mlx_lab|" +
            "corpus/la/L1/prospective-train-v3.txt|" +
            String(repeating: "4", count: 64) + "|1001",
        "validation_split|ergentics_mlx_lab|" +
            "corpus/la/L1/prospective-validation-v3.txt|" +
            String(repeating: "5", count: 64) + "|503",
        "selection_split|ergentics_mlx_lab|" +
            "corpus/la/L1/prospective-selection-v3.txt|" +
            String(repeating: "6", count: 64) + "|509",
        "selection_observation_declaration|ergentics_mlx_lab|" +
            "corpus/la/L1/prospective-selection-observation-v3.json|" +
            String(repeating: "7", count: 64) + "|233",
    ]
}

private struct InputSnapshotArtifactV3 {
    let role: String
    let scope: PrimeLatinProposalInputArtifactScopeV3
    let relativePath: String
    let data: Data
    let mode: UInt16

    var sha256: String {
        InputSnapshotFixtureV3.sha256(data)
    }

    var expectation: PrimeLatinProposalInputArtifactExpectationV3 {
        PrimeLatinProposalInputArtifactExpectationV3(
            role: role,
            scope: scope,
            relativePath: relativePath,
            sha256: sha256,
            byteCount: UInt64(data.count))
    }
}

private final class InputSnapshotFixtureV3 {
    let pair: PrimeLatinProposalSnapshotPublishedPairFixture
    let llmRepositoryRoot: URL
    let artifacts: [InputSnapshotArtifactV3]
    let outputNamespace =
        "models/latin-prospective/structural-fixture-v3-776c412e"

    private let cleanup: InputSnapshotFixtureRootV3

    var labRoot: URL { pair.labRoot }
    var pairSHA256: String { pair.pairSHA256 }
    var pairURL: URL { pair.pairURL }
    var outputURL: URL { labRoot.appendingPathComponent(outputNamespace) }
    var expectations: [PrimeLatinProposalInputArtifactExpectationV3] {
        artifacts.map { $0.expectation }
    }

    init() throws {
        pair = try PrimeLatinProposalSnapshotPublishedPairFixture()
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(
            "prime-latin-v3-input-snapshot-\(UUID().uuidString)",
            isDirectory: true)
        try FileManager.default.createDirectory(
            at: root,
            withIntermediateDirectories: false)
        try FileManager.default.setAttributes(
            [.posixPermissions: 0o755],
            ofItemAtPath: root.path)
        llmRepositoryRoot = root.resolvingSymlinksInPath().standardizedFileURL
        cleanup = InputSnapshotFixtureRootV3(llmRepositoryRoot)

        artifacts = Self.makeArtifacts()
        for artifact in artifacts {
            let root = artifact.scope == .ergenticsLLMRepository
                ? llmRepositoryRoot
                : pair.labRoot
            let url = root.appendingPathComponent(artifact.relativePath)
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true)
            try artifact.data.write(to: url, options: .withoutOverwriting)
            try FileManager.default.setAttributes(
                [.posixPermissions: NSNumber(value: artifact.mode)],
                ofItemAtPath: url.path)
        }
    }

    func capture(
        llmRepositoryRoot: URL? = nil,
        expectations: [PrimeLatinProposalInputArtifactExpectationV3]? = nil,
        outputNamespace: String? = nil,
        beforeFinalRecapture: () throws -> Void = {}
    ) throws -> PrimeLatinProposalInputSnapshotCaptureV3 {
        try PrimeLatinProposalInputSnapshotCaptureV3.captureForTesting(
            labRoot: labRoot,
            llmRepositoryRoot: llmRepositoryRoot ?? self.llmRepositoryRoot,
            pairSHA256: pairSHA256,
            expectations: expectations ?? self.expectations,
            outputNamespace: outputNamespace ?? self.outputNamespace,
            beforeFinalRecapture: beforeFinalRecapture)
    }

    func artifact(for role: String) -> InputSnapshotArtifactV3 {
        artifacts.first { $0.role == role }!
    }

    func data(for role: String) -> Data {
        artifact(for: role).data
    }

    func relativePath(for role: String) -> String {
        artifact(for: role).relativePath
    }

    func url(for role: String) -> URL {
        let artifact = artifact(for: role)
        let root = artifact.scope == .ergenticsLLMRepository
            ? llmRepositoryRoot
            : labRoot
        return root.appendingPathComponent(artifact.relativePath)
    }

    func replace(role: String, with data: Data) throws {
        let artifact = artifact(for: role)
        let url = self.url(for: role)
        try FileManager.default.setAttributes(
            [.posixPermissions: 0o644],
            ofItemAtPath: url.path)
        try data.write(to: url)
        try FileManager.default.setAttributes(
            [.posixPermissions: NSNumber(value: artifact.mode)],
            ofItemAtPath: url.path)
    }

    func uniqueDeviceAndInodeCount() throws -> Int {
        let identities = try artifacts.map { artifact -> String in
            let attributes = try FileManager.default.attributesOfItem(
                atPath: url(for: artifact.role).path)
            let device = try XCTUnwrap(
                attributes[.systemNumber] as? NSNumber)
            let inode = try XCTUnwrap(
                attributes[.systemFileNumber] as? NSNumber)
            return "\(device.uint64Value):\(inode.uint64Value)"
        }
        return Set(identities).count
    }

    static func sha256(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    private static func makeArtifacts() -> [InputSnapshotArtifactV3] {
        let tokenizerInput = Data(
            "Tokenizer staged and admitted bytes are intentionally equal.\n".utf8)
        let training = Data(
            "Prima forma verba Latina ad probationem structurae componit.\n".utf8)
        let validation = Data(
            "Secunda forma ordinem clausum diligenter explorat.\n".utf8)
        let selection = Data(
            "Tertia forma ante omnem electionem intacta manet.\n".utf8)
        let initialization = Data(
            ("{\"freshInitializationRequired\":true," +
             "\"importedWeightsAllowed\":false," +
             "\"schema\":\"ergentics_latin_initialization_contract_v1\"," +
             "\"seedSHA256\":\"" + String(repeating: "a", count: 64) +
             "\"}").utf8)
        let evaluation = Data(
            ("{\"candidate_independent\":true," +
             "\"procedure_id\":\"latin_structural_fixture_evaluation_v1\"," +
             "\"schema\":\"ergentics_latin_evaluation_contract_v1\"," +
             "\"thresholds_observed\":false}").utf8)
        let corpusManifest = Data(
            ("{\"schema\":\"ergentics_latin_prospective_corpus_manifest_v1\"," +
             "\"selection_id\":\"latin_fixture_selection_v3\"," +
             "\"selection_sha256\":\"\(sha256(selection))\"," +
             "\"training_id\":\"latin_fixture_train_v3\"," +
             "\"training_sha256\":\"\(sha256(training))\"," +
             "\"validation_id\":\"latin_fixture_validation_v3\"," +
             "\"validation_sha256\":\"\(sha256(validation))\"}").utf8)
        let selectionObservation = Data(
            ("{\"candidateSelectionAuthorized\":false," +
             "\"schema\":\"ergentics_latin_selection_observation_v1\"," +
             "\"selectionSHA256\":\"\(sha256(selection))\"," +
             "\"sourceAttribution\":\"ergentics_codex_assisted_structural_fixture\"}").utf8)

        let definitions: [(
            String,
            PrimeLatinProposalInputArtifactScopeV3,
            String,
            Data,
            UInt16
        )] = [
            (
                "root_package_manifest", .ergenticsLLMRepository,
                "Package.swift", Data("root package manifest fixture\n".utf8),
                0o644),
            (
                "root_dependency_lock", .ergenticsLLMRepository,
                "Package.resolved", Data("root dependency lock fixture\n".utf8),
                0o644),
            (
                "declaration_package_manifest", .ergenticsLLMRepository,
                "Research/Latin/CandidateDeclarations/Package.swift",
                Data("declaration package manifest fixture\n".utf8), 0o644),
            (
                "declaration_production_source", .ergenticsLLMRepository,
                "Research/Latin/CandidateDeclarations/Sources/" +
                    "ErgenticsLatinCandidateDeclarations/" +
                    "ErgenticsLatinCandidateDeclarations.swift",
                Data("declaration production source fixture\n".utf8), 0o644),
            (
                "candidate_architecture", .ergenticsLLMRepository,
                "Research/Latin/candidates/latin_structural_fixture_v1/" +
                    "architecture.json",
                Data("{\"architecture\":\"fixture\"}".utf8), 0o644),
            (
                "candidate_parameter_count_derivation",
                .ergenticsLLMRepository,
                "Research/Latin/candidates/latin_structural_fixture_v1/" +
                    "parameter-count-derivation.json",
                Data("{\"parameter_count\":131736}".utf8), 0o644),
            (
                "evaluation_contract", .ergenticsLLMRepository,
                "Research/Latin/evaluation_contract.json", evaluation, 0o644),
            (
                "tokenizer_manifest", .ergenticsMLXLab,
                "tokenizer/ergentics_latin_bpe_v2/manifest.json",
                Data("tokenizer manifest fixture\n".utf8), 0o644),
            (
                "tokenizer_sentencepiece_model", .ergenticsMLXLab,
                "tokenizer/ergentics_latin_bpe_v2/model.spm",
                Data("tokenizer sentencepiece model fixture\n".utf8), 0o644),
            (
                "tokenizer_vocabulary", .ergenticsMLXLab,
                "tokenizer/ergentics_latin_bpe_v2/vocab.txt",
                Data("tokenizer vocabulary fixture\n".utf8), 0o644),
            (
                "tokenizer_recommendation", .ergenticsMLXLab,
                "tokenizer/ergentics_latin_bpe_v2/recommendation.json",
                Data("tokenizer recommendation fixture\n".utf8), 0o644),
            (
                "tokenizer_approval", .ergenticsMLXLab,
                "tokenizer/ergentics_latin_bpe_v2/approval.json",
                Data("tokenizer approval fixture\n".utf8), 0o644),
            (
                "tokenizer_staged_training_input", .ergenticsMLXLab,
                "tokenizer/ergentics_latin_bpe_v2/staging/train-input.txt",
                tokenizerInput, 0o644),
            (
                "tokenizer_corpus_manifest", .ergenticsMLXLab,
                "corpus/la/L1/primary-corpus-manifest.json",
                Data("tokenizer corpus manifest fixture\n".utf8), 0o644),
            (
                "tokenizer_admitted_corpus_input", .ergenticsMLXLab,
                "corpus/la/L1/train.txt", tokenizerInput, 0o644),
            (
                "initialization_contract", .ergenticsMLXLab,
                "evidence/latin-proposal-inputs/v3/776c412e/" +
                    "initialization-contract.json",
                initialization, 0o444),
            (
                "prospective_corpus_manifest", .ergenticsMLXLab,
                "corpus/la/L1/prospective-v3-776c412e/corpus-manifest.json",
                corpusManifest, 0o444),
            (
                "training_split", .ergenticsMLXLab,
                "corpus/la/L1/prospective-v3-776c412e/training.txt",
                training, 0o444),
            (
                "validation_split", .ergenticsMLXLab,
                "corpus/la/L1/prospective-v3-776c412e/validation.txt",
                validation, 0o444),
            (
                "selection_split", .ergenticsMLXLab,
                "corpus/la/L1/prospective-v3-776c412e/selection.txt",
                selection, 0o444),
            (
                "selection_observation_declaration", .ergenticsMLXLab,
                "corpus/la/L1/prospective-v3-776c412e/" +
                    "selection-observation.json",
                selectionObservation, 0o444),
        ]
        return definitions.map {
            InputSnapshotArtifactV3(
                role: $0.0,
                scope: $0.1,
                relativePath: $0.2,
                data: $0.3,
                mode: $0.4)
        }
    }
}

private final class InputSnapshotFixtureRootV3 {
    private let root: URL

    init(_ root: URL) {
        self.root = root
    }

    deinit {
        try? FileManager.default.removeItem(at: root)
    }
}

private extension PrimeLatinProposalInputArtifactExpectationV3 {
    func replacing(
        role: String? = nil,
        scope: PrimeLatinProposalInputArtifactScopeV3? = nil,
        relativePath: String? = nil,
        sha256: String? = nil,
        byteCount: UInt64? = nil
    ) -> PrimeLatinProposalInputArtifactExpectationV3 {
        PrimeLatinProposalInputArtifactExpectationV3(
            role: role ?? self.role,
            scope: scope ?? self.scope,
            relativePath: relativePath ?? self.relativePath,
            sha256: sha256 ?? self.sha256,
            byteCount: byteCount ?? self.byteCount)
    }
}

private extension Data {
    func replacingUTF8(_ target: String, with replacement: String) -> Data {
        let source = String(decoding: self, as: UTF8.self)
        precondition(source.contains(target))
        return Data(source.replacingOccurrences(
            of: target,
            with: replacement).utf8)
    }
}
