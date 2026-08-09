import Foundation
import XCTest

final class PrimeLatinProposalPairCaptureSourceContractTests: XCTestCase {
    func testCaptureSourceHasNoModelRuntimeOrHistoricalAuthorityDependency()
        throws
    {
        let source = try joinedSwiftSource(
            directory: "Sources/PrimeLatinProposalPairCapture")
        let forbidden = [
            "import PrimeCore",
            "import ErgenticsLLM",
            "import ErgenticsTokenizer",
            "import MLX",
            "import MLXNN",
            "import MLXLLM",
            "PrimeLatinLLMAuthority",
        ]
        for token in forbidden {
            XCTAssertFalse(
                source.lowercased().contains(token.lowercased()),
                "forbidden capture-source dependency token: \(token)")
        }
    }

    func testCaptureSourceCannotExecuteOrManufactureAuthority() throws {
        let source = try joinedSwiftSource(
            directory: "Sources/PrimeLatinProposalPairCapture")
        let forbidden = [
            "Process()",
            "ProcessInfo.processInfo.environment",
            "URLSession",
            "Network.framework",
            "/bin/" + "sh",
            "python",
            "--disable-sandbox",
            "trialExecutionAuthorized = true",
            "furtherTrainingAuthorized = true",
            "promotionAuthorized = true",
            "productUseAuthorized = true",
            "publicationAuthorized = true",
            "candidateSelectionAuthorized = true",
            "runtimeDecoderImplementationAvailable = true",
            "runtimeDependencyClosureEstablished = true",
            "runtimeInitializationEstablished = true",
            "primeProposalPacketProduced = true",
            "primeTrialAuthorizationProduced = true",
            "primeDecisionReceiptProduced = true",
            "durableReceiptPublished = true",
            "func publish",
            "O_WRONLY",
            "O_RDWR",
            "mkdirat(",
            "renameat",
            "unlinkat(",
            "removeItem(",
            "root.verify(",
        ]
        for token in forbidden {
            XCTAssertFalse(
                source.contains(token),
                "forbidden capture-source authority token: \(token)")
        }
    }

    func testV3InputConsumerIsDependencyFreeReadOnlyAndAbstaining() throws {
        let source = try swiftSource(
            relativePath:
                "Sources/PrimeLatinProposalPairCapture/" +
                    "PrimeLatinProposalInputsV3.swift")
        let compact = source.filter { !$0.isWhitespace }
        let imports = source.split(separator: "\n")
            .map(String.init)
            .filter { $0.hasPrefix("import ") }
        XCTAssertEqual(imports, ["import Foundation"])

        for required in [
            "public enum PrimeLatinProposalInputsV3",
            "public static func consume(",
            "candidateCatalogData: Data",
            "experimentManifestData: Data",
            "ergentics_latin_candidate_catalog_v3",
            "ergentics_latin_candidate_declaration_set_v3",
            "ergentics_latin_candidate_declaration_input_bundle_v1",
            "ergentics_latin_tokenizer_proposal_binding_v2",
            "ergentics_latin_experiment_manifest_v3",
            "root_bound_declaration_proposal_input_v3_only_non_authorizing",
            "candidate_declaration_bound_decoder_absent_runtime_initialization_and_runtime_dependency_closure_not_established_by_bridge",
            "evaluator_and_prospective_data_completeness_not_established_by_bridge",
            "contract_bound_runtime_initialization_not_established",
            "declarative_recomputed_not_runtime_reconciled",
            "not_implemented_v3",
            "not_implemented_input_bridge_only",
            "ergentics_prime_latin_proposal_inputs_v3_observation",
            "canonical_v3_wire_and_embedded_hash_chain_only_non_authorizing",
            "abstain_requires_original_bound_input_bytes_and_live_provenance",
        ] {
            XCTAssertTrue(
                source.contains(required),
                "missing V3 input-consumer contract anchor: \(required)")
        }

        for required in [
            "outcome=\"abstain\"",
            "canonicalWireRedecodeComplete=true",
            "embeddedHashChainRecomputationComplete=true",
            "referencedInputSnapshotAvailable=false",
            "referencedArtifactBytesAvailable=false",
            "liveProducerWorkspaceRevalidationComplete=false",
            "llmGitStateIndependentlyObserved=false",
            "independentReplayComplete=false",
            "runtimeDecoderImplementationAvailable=false",
            "runtimeDependencyClosureEstablished=false",
            "runtimeInitializationEstablished=false",
            "primeProposalPacketProduced=false",
            "primeTrialAuthorizationProduced=false",
            "primeDecisionReceiptProduced=false",
            "candidateSelectionAuthorized=false",
            "trialExecutionAuthorized=false",
            "furtherTrainingAuthorized=false",
            "promotionAuthorized=false",
            "productUseAuthorized=false",
            "publicationAuthorized=false",
            "durableReceiptPublished=false",
        ] {
            XCTAssertTrue(
                compact.contains(required),
                "missing V3 input-consumer abstention anchor: \(required)")
        }

        for forbidden in [
            "import PrimeCore",
            "import ErgenticsLLM",
            "import ErgenticsTokenizer",
            "import MLX",
            "import MLXNN",
            "import MLXLLM",
            "import Darwin",
            "Process(",
            "ProcessInfo.processInfo.environment",
            "URLSession",
            "Network.framework",
            "FileManager",
            "FileHandle",
            ".write(to:",
            "createDirectory(",
            "createFile(",
            "O_CREAT",
            "O_WRONLY",
            "O_RDWR",
            "mkdirat(",
            "renameat",
            "unlinkat(",
            "removeItem(",
            "func publish",
            "PrimeLatinTrialProposal",
            "PrimeLatinTrialAuthorization",
            "--disable-sandbox",
        ] {
            XCTAssertFalse(
                source.contains(forbidden),
                "forbidden V3 input-consumer capability: \(forbidden)")
        }

        for forbidden in [
            "referencedInputSnapshotAvailable=true",
            "referencedArtifactBytesAvailable=true",
            "liveProducerWorkspaceRevalidationComplete=true",
            "llmGitStateIndependentlyObserved=true",
            "independentReplayComplete=true",
            "runtimeDecoderImplementationAvailable=true",
            "runtimeDependencyClosureEstablished=true",
            "runtimeInitializationEstablished=true",
            "primeProposalPacketProduced=true",
            "primeTrialAuthorizationProduced=true",
            "primeDecisionReceiptProduced=true",
            "candidateSelectionAuthorized=true",
            "trialExecutionAuthorized=true",
            "furtherTrainingAuthorized=true",
            "promotionAuthorized=true",
            "productUseAuthorized=true",
            "publicationAuthorized=true",
            "durableReceiptPublished=true",
        ] {
            XCTAssertFalse(
                compact.contains(forbidden),
                "V3 input consumer manufactures authority: \(forbidden)")
        }
    }

    func testV3PairCaptureIsDescriptorBoundReadOnlyAndAbstaining() throws {
        let source = try swiftSource(
            relativePath:
                "Sources/PrimeLatinProposalPairCapture/" +
                    "PrimeLatinProposalPairCaptureV3.swift")
        let compact = source.filter { !$0.isWhitespace }
        let imports = source.split(separator: "\n")
            .map(String.init)
            .filter { $0.hasPrefix("import ") }
        XCTAssertEqual(imports, ["import Foundation"])

        for required in [
            "public struct PrimeLatinProposalPairLocatorV3",
            "public final class PrimeLatinProposalPairCaptureV3",
            "public struct PrimeLatinProposalPairObservationV3",
            "public struct PrimeLatinProposalPairAuthorityBoundaryV3",
            "public static func capture(",
            "recaptureAndValidateUnchanged",
            "PrimeLatinArtifactRoot",
            "bindExisting(",
            "readVerifiedArtifact(",
            "verifiedRootIdentity()",
            ".immutableData",
            "ergentics_prime_latin_proposal_pair_capture_v3_observation",
            "descriptor_safe_content_addressed_v3_pair_capture_and_embedded_hash_chain_only_non_authorizing",
            "ergentics_latin_proposal_pair_receipt_v3",
            "evidence/latin-proposal-artifacts/v3",
            "candidate_catalog_v3",
            "experiment_manifest_v3",
            "proposal_pair_receipt_v3",
            "content_addressed_create_once_pair_complete",
            "mechanics_only_non_authorizing",
            "canonical_v3_catalog_experiment_pair_only",
            "absent_from_pair_except_catalog_and_experiment_children",
            "requires_original_bound_input_bytes_and_live_provenance",
            "prime_consumer_state_not_observed_by_producer",
            "absent_live_roots_revalidated_before_receipt_rename",
            "cooperative_process_lock_only",
        ] {
            XCTAssertTrue(
                source.contains(required),
                "missing V3 pair-capture contract anchor: \(required)")
        }

        for required in [
            "outcome=\"abstain\"",
            "disposition=\"abstain_requires_original_bound_input_bytes_and_live_provenance\"",
            "PrimeLatinProposalInputsV3.consume(",
            "canonicalReceiptRedecodeComplete=true",
            "receiptContentAddressBindingVerified=true",
            "childContentAddressBindingsVerified=true",
            "stableRootBoundCaptureComplete=true",
            "pairChildDocumentBytesAvailable=true",
            "embeddedHashChainRecomputationComplete=true",
            "llmPairReceiptObserved=true",
            "referencedInputSnapshotAvailable=false",
            "referencedArtifactBytesAvailable=false",
            "liveProducerWorkspaceRevalidationComplete=false",
            "llmGitStateIndependentlyObserved=false",
            "independentReplayComplete=false",
            "runtimeDecoderImplementationAvailable=false",
            "runtimeDependencyClosureEstablished=false",
            "runtimeInitializationEstablished=false",
            "primeProposalPacketProduced=false",
            "primeTrialAuthorizationProduced=false",
            "primeDecisionReceiptProduced=false",
            "candidateSelectionAuthorized=false",
            "trialExecutionAuthorized=false",
            "furtherTrainingAuthorized=false",
            "promotionAuthorized=false",
            "productUseAuthorized=false",
            "publicationAuthorized=false",
            "primeDurableReceiptPublished=false",
        ] {
            XCTAssertTrue(
                compact.contains(required),
                "missing V3 pair-capture boundary anchor: \(required)")
        }

        for forbidden in [
            "import PrimeCore",
            "import ErgenticsLLM",
            "import ErgenticsTokenizer",
            "import MLX",
            "import MLXNN",
            "import MLXLLM",
            "import Darwin",
            "Process(",
            "ProcessInfo.processInfo.environment",
            "URLSession",
            "Network.framework",
            "FileManager",
            "FileHandle",
            "CommandLine",
            "@main",
            ".write(to:",
            "createDirectory(",
            "createFile(",
            "O_CREAT",
            "O_WRONLY",
            "O_RDWR",
            "mkdirat(",
            "renameat",
            "unlinkat(",
            "removeItem(",
            "func publish",
            "PrimeLatinTrialProposal",
            "PrimeLatinTrialAuthorization",
            "--disable-sandbox",
        ] {
            XCTAssertFalse(
                source.contains(forbidden),
                "forbidden V3 pair-capture capability: \(forbidden)")
        }

        for forbidden in [
            "referencedInputSnapshotAvailable=true",
            "referencedArtifactBytesAvailable=true",
            "liveProducerWorkspaceRevalidationComplete=true",
            "llmGitStateIndependentlyObserved=true",
            "independentReplayComplete=true",
            "runtimeDecoderImplementationAvailable=true",
            "runtimeDependencyClosureEstablished=true",
            "runtimeInitializationEstablished=true",
            "primeProposalPacketProduced=true",
            "primeTrialAuthorizationProduced=true",
            "primeDecisionReceiptProduced=true",
            "candidateSelectionAuthorized=true",
            "trialExecutionAuthorized=true",
            "furtherTrainingAuthorized=true",
            "promotionAuthorized=true",
            "productUseAuthorized=true",
            "publicationAuthorized=true",
            "primeDurableReceiptPublished=true",
        ] {
            XCTAssertFalse(
                compact.contains(forbidden),
                "V3 pair capture manufactures authority: \(forbidden)")
        }
    }

    func testV3InputSnapshotIsDescriptorBoundReadOnlyAndAbstaining() throws {
        let source = try swiftSource(
            relativePath:
                "Sources/PrimeLatinProposalPairCapture/" +
                    "PrimeLatinProposalInputSnapshotV3.swift")
        let inputsSource = try swiftSource(
            relativePath:
                "Sources/PrimeLatinProposalPairCapture/" +
                    "PrimeLatinProposalInputsV3.swift")
        let compact = source.filter { !$0.isWhitespace }

        for required in [
            "public final class PrimeLatinProposalInputSnapshotCaptureV3",
            "public static func capture(",
            "labRoot: URL",
            "llmRepositoryRoot: URL",
            "pairSHA256: String",
            "recaptureAndValidateUnchanged",
            "ergentics_prime_latin_proposal_input_snapshot_v3_observation",
            "descriptor_safe_exact_v3_original_bound_input_snapshot_only_non_authorizing",
            "abstain_snapshot_mechanics_only_requires_live_producer_revalidation_git_observation_and_independent_replay",
            "PrimeLatinProposalPairCaptureV3.capture(",
            "static func captureForTesting(",
            "maximumAggregateArtifactBytes: UInt64 = 67_108_864",
            "addingReportingOverflow(",
            "bound_input_aggregate_byte_count",
        ] {
            XCTAssertTrue(
                source.contains(required),
                "missing V3 input-snapshot contract anchor: \(required)")
        }
        XCTAssertEqual(
            source.components(separatedBy: "public static func capture(")
                .count,
            2)

        let orderedRoles = [
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
        let roleOffsets = try orderedRoles.map { role in
            try XCTUnwrap(
                inputsSource.range(of: "\"\(role)\"")?.lowerBound,
                "missing ordered role literal: \(role)")
        }
        for (first, second) in zip(roleOffsets, roleOffsets.dropFirst()) {
            XCTAssertLessThan(first, second)
        }

        for required in [
            "outcome=\"abstain\"",
            "disposition=\"abstain_snapshot_mechanics_only_requires_live_producer_revalidation_git_observation_and_independent_replay\"",
            "stablePairRootBoundCaptureComplete=true",
            "stableLLMRepositoryRootBoundCaptureComplete=true",
            "stableLabRootBoundCaptureComplete=true",
            "artifactPathRoleHashCountBindingsVerified=true",
            "outputNamespaceAbsenceVerified=true",
            "pairCaptureAndRecaptureComplete=true",
            "referencedInputSnapshotAvailable=true",
            "referencedArtifactBytesAvailable=true",
            "durableInputSnapshotPublished=false",
            "liveProducerWorkspaceRevalidationComplete=false",
            "llmGitStateIndependentlyObserved=false",
            "independentReplayComplete=false",
            "runtimeDecoderImplementationAvailable=false",
            "runtimeDependencyClosureEstablished=false",
            "runtimeInitializationEstablished=false",
            "primeProposalPacketProduced=false",
            "primeTrialAuthorizationProduced=false",
            "primeDecisionReceiptProduced=false",
            "candidateSelectionAuthorized=false",
            "trialExecutionAuthorized=false",
            "furtherTrainingAuthorized=false",
            "promotionAuthorized=false",
            "productUseAuthorized=false",
            "publicationAuthorized=false",
            "primeDurableReceiptPublished=false",
        ] {
            XCTAssertTrue(
                compact.contains(required),
                "missing V3 input-snapshot authority anchor: \(required)")
        }

        for forbidden in [
            "import PrimeCore",
            "import ErgenticsLLM",
            "import ErgenticsTokenizer",
            "import MLX",
            "import MLXNN",
            "import MLXLLM",
            "Process(",
            "ProcessInfo.processInfo.environment",
            "URLSession",
            "Network.framework",
            "CommandLine",
            "@main",
            ".write(to:",
            "createDirectory(",
            "createFile(",
            "O_CREAT",
            "O_WRONLY",
            "O_RDWR",
            "mkdirat(",
            "renameat",
            "unlinkat(",
            "removeItem(",
            "func publish",
            "PrimeLatinTrialProposal",
            "PrimeLatinTrialAuthorization",
            "--disable-sandbox",
        ] {
            XCTAssertFalse(
                source.contains(forbidden),
                "forbidden V3 input-snapshot capability: \(forbidden)")
        }

        for forbidden in [
            "publicstaticfunccaptureForTesting(",
            "publicinit(expectation:",
            "publicinit(pairObservation:",
            "publicstructPrimeLatinProposalInputArtifactExpectationV3",
            "Codable",
            "durableInputSnapshotPublished=true",
            "liveProducerWorkspaceRevalidationComplete=true",
            "llmGitStateIndependentlyObserved=true",
            "independentReplayComplete=true",
            "runtimeDecoderImplementationAvailable=true",
            "runtimeDependencyClosureEstablished=true",
            "runtimeInitializationEstablished=true",
            "primeProposalPacketProduced=true",
            "primeTrialAuthorizationProduced=true",
            "primeDecisionReceiptProduced=true",
            "candidateSelectionAuthorized=true",
            "trialExecutionAuthorized=true",
            "furtherTrainingAuthorized=true",
            "promotionAuthorized=true",
            "productUseAuthorized=true",
            "publicationAuthorized=true",
            "primeDurableReceiptPublished=true",
        ] {
            XCTAssertFalse(
                compact.contains(forbidden),
                "V3 input snapshot manufactures authority: \(forbidden)")
        }
    }

    func testV3GitSourceObservationIsFixedReadOnlyAndAbstaining() throws {
        let source = try swiftSource(
            relativePath:
                "Sources/PrimeLatinProposalGitObservation/" +
                    "PrimeLatinProposalGitSourceV3.swift")
        let compact = source.filter { !$0.isWhitespace }
        let imports = source.split(separator: "\n")
            .map(String.init)
            .filter { $0.hasPrefix("import ") }
        XCTAssertEqual(
            imports,
            [
                "import Darwin",
                "import Glibc",
                "import CryptoKit",
                "import Foundation",
                "import PrimeLatinProposalPairCapture",
            ])
        XCTAssertEqual(source.components(separatedBy: "Process()").count, 2)
        XCTAssertEqual(
            source.components(separatedBy: "process.executableURL").count,
            2)
        XCTAssertEqual(
            source.components(separatedBy: "\"/usr/bin/git\"").count,
            2)

        for required in [
            "public struct PrimeLatinProposalGitToolObservationV3",
            "public struct PrimeLatinProposalGitArtifactObservationV3",
            "public struct PrimeLatinProposalGitSourceAuthorityBoundaryV3",
            "public struct PrimeLatinProposalGitSourceObservationV3",
            "public enum PrimeLatinProposalGitSourceError",
            "public final class PrimeLatinProposalGitSourceCaptureV3",
            "public static func capture(",
            "labRoot: URL",
            "llmRepositoryRoot: URL",
            "pairSHA256: String",
            "recaptureAndValidateUnchanged",
            "PrimeLatinProposalInputSnapshotCaptureV3",
            "ergentics_prime_latin_proposal_git_source_v3_observation",
            "fixed_read_only_git_process_exact_head_tree_clean_status_and_seven_snapshot_repository_bindings_only_non_authorizing",
            "abstain_git_observation_only_requires_live_producer_revalidation_and_independent_replay",
            "locally_declared_origin_only_not_network_authenticated",
            "prime_latin_git_read_only_fixed_environment_v1",
            "https://github.com/Ergentics/ergentics-llm.git",
            "/usr/bin/git",
            "mode_t(0o6000) == 0",
            "Process()",
            "--no-replace-objects",
            "--no-includes",
            "remote.origin.url",
            "--show-toplevel",
            "repository_top_level",
            "tracked_index_visibility",
            "trackedIndexEntryCount",
            "trackedIndexInventoryByteCount",
            "trackedIndexInventorySHA256",
            "noAssumeUnchangedOrSkipWorktreeIndexEntriesObserved",
            "validateObservedTopLevel",
            "resolvedRealPath",
            "realpath(",
            "core.fsmonitor=false",
            "core.hooksPath=/dev/null",
            "core.fileMode=true",
            "\"GIT_NO_REPLACE_OBJECTS\": \"1\"",
            "\"GIT_OPTIONAL_LOCKS\": \"0\"",
            "\"GIT_CONFIG_NOSYSTEM\": \"1\"",
            "\"GIT_CONFIG_GLOBAL\": \"/dev/null\"",
            "\"GIT_CONFIG_SYSTEM\": \"/dev/null\"",
            "\"GIT_TERMINAL_PROMPT\": \"0\"",
            "\"GIT_NO_LAZY_FETCH\": \"1\"",
            "\"GIT_ALLOW_PROTOCOL\": \"none\"",
            "Insecure.SHA1.hash",
            "776c412e3f10e8bf4e33cd0ae60787d9ca6b5831",
            "c1f41758aea2860ab06039776f5ea0403dff1b61",
            "0e4e7ea646db282de4f23064acad5884586d01cdcc89611deae3c01298b29fed",
            "static let finalTrackedIndexEntryCount: UInt64 = 144",
            "static let finalTrackedIndexInventoryByteCount: UInt64 = 6_933",
            "101afd50470f669f8b4de14f9188e16854a4166b355bf8a4e9ec810a59a9e289",
            "Package.swift",
            "Package.resolved",
            "Research/Latin/CandidateDeclarations/Package.swift",
            "Research/Latin/CandidateDeclarations/Sources/" +
                "ErgenticsLatinCandidateDeclarations/" +
                "ErgenticsLatinCandidateDeclarations.swift",
            "Research/Latin/candidates/latin_structural_fixture_v1/" +
                "architecture.json",
            "Research/Latin/candidates/latin_structural_fixture_v1/" +
                "parameter-count-derivation.json",
            "Research/Latin/evaluation_contract.json",
        ] {
            XCTAssertTrue(
                source.contains(required),
                "missing V3 Git-observation contract anchor: \(required)")
        }

        let exactFinalArtifacts: [(
            role: String,
            relativePath: String,
            gitBlobOID: String,
            sha256: String,
            byteCountLiteral: String
        )] = [
            (
                "root_package_manifest",
                "Package.swift",
                "dabd1cd7002ddbfa4d05d7c4f7660133892d0050",
                "ab460122d5f364046224c6445a20f3beb34e2831de94db1271bbafb59726c902",
                "6_109"
            ),
            (
                "root_dependency_lock",
                "Package.resolved",
                "4e822bfadbe5f4dced15a277f4d5423a03d76890",
                "2847fb936ec74eef250b8439d778f0a1ea8d0c630bf09438587764a4b99c6530",
                "645"
            ),
            (
                "declaration_package_manifest",
                "Research/Latin/CandidateDeclarations/Package.swift",
                "67907b47cf941c6e36154dd729b284f64c90ca9b",
                "9d5242248391613382c9c42bb388b1ad1d1597956f272e5d5b410b7891b38b63",
                "892"
            ),
            (
                "declaration_production_source",
                "Research/Latin/CandidateDeclarations/Sources/" +
                    "ErgenticsLatinCandidateDeclarations/" +
                    "ErgenticsLatinCandidateDeclarations.swift",
                "a951d3710dba072aa7eb8554c60abafdd032cb7f",
                "676443927b5024c6e58caa562777a27945dad384c6cc88b5d94d11e73c047bc4",
                "35_119"
            ),
            (
                "candidate_architecture",
                "Research/Latin/candidates/latin_structural_fixture_v1/" +
                    "architecture.json",
                "a3a9582003bfdbce2c94707313c0e402955bca9b",
                "4b31feeeba780bc39c064d4540f5701935f960e1e1d8c82c81d295a65e643a70",
                "2_794"
            ),
            (
                "candidate_parameter_count_derivation",
                "Research/Latin/candidates/latin_structural_fixture_v1/" +
                    "parameter-count-derivation.json",
                "9957d0b17edd019ce760fdae9907a8ebadf408e3",
                "45d15481883cf606e8e739aa71815bf9bd2fdd51494059328e3ba16a9ed5fb8f",
                "2_702"
            ),
            (
                "evaluation_contract",
                "Research/Latin/evaluation_contract.json",
                "0f052ee6724d4815b8c18eae968175631035f00d",
                "4a0dd1bc973f7ce380df9775413c4e43033ba0cc409fb45a9368c2bef6835d52",
                "164"
            ),
        ]
        var orderedSearchStart = compact.startIndex
        for artifact in exactFinalArtifacts {
            let exactConstructor =
                "PrimeLatinProposalGitExpectedArtifactV3(" +
                "role:\"\(artifact.role)\"," +
                "relativePath:\"\(artifact.relativePath)\"," +
                "gitBlobOID:\"\(artifact.gitBlobOID)\"," +
                "sha256:\"\(artifact.sha256)\"," +
                "byteCount:\(artifact.byteCountLiteral))"
            guard let range = compact.range(
                of: exactConstructor,
                range: orderedSearchStart..<compact.endIndex
            ) else {
                XCTFail(
                    "missing or out-of-order exact final Git artifact: " +
                        artifact.role
                )
                return
            }
            orderedSearchStart = range.upperBound
        }
        XCTAssertTrue(
            compact.contains("rawCommitByteCount:1_222"),
            "missing exact final raw-commit byte count")
        XCTAssertTrue(
            compact.contains("arguments:[\"ls-files\",\"-v\",\"-z\"]"),
            "missing exact tracked-index visibility command")

        for required in [
            "outcome=\"abstain\"",
            "snapshotCaptureAndRecaptureComplete=true",
            "stableLLMRepositoryRootBoundObservationComplete=true",
            "stableGitToolObservationComplete=true",
            "exactHeadCommitObserved=true",
            "exactHeadTreeObserved=true",
            "cleanPorcelainV2StatusObserved=true",
            "noAssumeUnchangedOrSkipWorktreeIndexEntriesObserved=true",
            "exactRawCommitObjectObserved=true",
            "exactSevenRepositoryTreeEntriesObserved=true",
            "sevenRepositoryBlobHashCountBindingsMatchedSnapshot=true",
            "localOriginDeclarationObserved=true",
            "repeatedGitObservationUnchanged=true",
            "referencedInputSnapshotAvailable=true",
            "referencedArtifactBytesAvailable=true",
            "llmGitStateIndependentlyObserved=true",
            "originRemoteCryptographicallyAuthenticated=false",
            "ignoredWorkspaceBytesObserved=false",
            "durableInputSnapshotPublished=false",
            "durableGitObservationPublished=false",
            "liveProducerWorkspaceRevalidationComplete=false",
            "independentReplayComplete=false",
            "runtimeDecoderImplementationAvailable=false",
            "runtimeDependencyClosureEstablished=false",
            "runtimeInitializationEstablished=false",
            "primeProposalPacketProduced=false",
            "primeTrialAuthorizationProduced=false",
            "primeDecisionReceiptProduced=false",
            "candidateSelectionAuthorized=false",
            "trialExecutionAuthorized=false",
            "furtherTrainingAuthorized=false",
            "promotionAuthorized=false",
            "productUseAuthorized=false",
            "publicationAuthorized=false",
            "primeDurableReceiptPublished=false",
        ] {
            XCTAssertTrue(
                compact.contains(required),
                "missing V3 Git-observation authority anchor: \(required)")
        }

        for forbidden in [
            "import PrimeCore",
            "import ErgenticsLLM",
            "import ErgenticsTokenizer",
            "import MLX",
            "import MLXNN",
            "import MLXLLM",
            "ErgenticsPrimeRuntime",
            "LlamaModel",
            "HuggingFace",
            "PMHNP",
            "pmhnp-companion-ergentics",
            "ProcessInfo.processInfo.environment",
            "URLSession",
            "Network.framework",
            "NWConnection",
            "socket(",
            "connect(",
            "curl",
            "python",
            "ssh",
            "scp",
            "shell",
            "\"/bin/sh\"",
            "\"/bin/bash\"",
            "\"/usr/bin/env\"",
            "\"fetch\"",
            "\"push\"",
            "\"clone\"",
            "\"checkout\"",
            "\"reset\"",
            "\"clean\"",
            "\"add\"",
            "\"update-ref\"",
            ".write(to:",
            "createDirectory(",
            "createFile(",
            "O_CREAT",
            "O_WRONLY",
            "O_RDWR",
            "mkdirat(",
            "renameat",
            "unlinkat(",
            "removeItem(",
            "func publish",
            "PrimeLatinTrialProposal",
            "PrimeLatinTrialAuthorization",
            "--disable-sandbox",
        ] {
            XCTAssertFalse(
                source.contains(forbidden),
                "forbidden V3 Git-observation capability: \(forbidden)")
        }

        for forbidden in [
            "Codable",
            "publicstaticfunccaptureForTesting(",
            "publicinit(",
            "publicinit(observation:",
            "publicinit(snapshot:",
            "publicinit(gitTool:",
            "publicinit(disposition:",
            "publicinit(schema:",
            "noAssumeUnchangedOrSkipWorktreeIndexEntriesObserved=false",
            "originRemoteCryptographicallyAuthenticated=true",
            "ignoredWorkspaceBytesObserved=true",
            "durableInputSnapshotPublished=true",
            "durableGitObservationPublished=true",
            "liveProducerWorkspaceRevalidationComplete=true",
            "independentReplayComplete=true",
            "runtimeDecoderImplementationAvailable=true",
            "runtimeDependencyClosureEstablished=true",
            "runtimeInitializationEstablished=true",
            "primeProposalPacketProduced=true",
            "primeTrialAuthorizationProduced=true",
            "primeDecisionReceiptProduced=true",
            "candidateSelectionAuthorized=true",
            "trialExecutionAuthorized=true",
            "furtherTrainingAuthorized=true",
            "promotionAuthorized=true",
            "productUseAuthorized=true",
            "publicationAuthorized=true",
            "primeDurableReceiptPublished=true",
        ] {
            XCTAssertFalse(
                compact.contains(forbidden),
                "V3 Git observation manufactures authority: \(forbidden)")
        }
    }

    func testGitObservationTargetHasOnlyCaptureDependency() throws {
        let root = URL(
            fileURLWithPath: FileManager.default.currentDirectoryPath,
            isDirectory: true)
        let manifest = try String(
            contentsOf: root.appendingPathComponent("Package.swift"),
            encoding: .utf8)
        let compact = manifest.filter { !$0.isWhitespace }
        XCTAssertTrue(
            compact.contains(
                ".target(name:\"PrimeLatinProposalGitObservation\"," +
                "dependencies:[\"PrimeLatinProposalPairCapture\",])"))
        XCTAssertTrue(
            compact.contains(
                ".executableTarget(" +
                "name:\"PrimeLatinProposalGitObservationProbe\"," +
                "dependencies:[\"PrimeLatinProposalGitObservation\",])"))
        for forbidden in [
            "PrimeCore",
            "ErgenticsPrimeRuntime",
            "MLX",
            "MLXNN",
            "MLXLLM",
        ] {
            XCTAssertFalse(
                compact.contains(
                    ".target(" +
                    "name:\"PrimeLatinProposalGitObservation\"," +
                    "dependencies:[\"\(forbidden)"),
                "forbidden Git-observation target dependency: \(forbidden)")
        }
    }

    func testProducerRevalidationObserverFreezesExactSelfBuildAndToolSource()
        throws
    {
        let source = try swiftSource(
            relativePath:
                "Sources/PrimeLatinProposalProducerRevalidationObservation/" +
                    "PrimeLatinProposalProducerRevalidationObservationV1.swift")
        let imports = source.split(separator: "\n")
            .map(String.init)
            .filter { $0.hasPrefix("import ") }
        XCTAssertEqual(
            imports,
            [
                "import Darwin",
                "import Glibc",
                "import CryptoKit",
                "import Compression",
                "import Foundation",
                "import PrimeLatinProposalGitObservation",
                "import PrimeLatinProposalPairCapture",
            ])

        for required in [
            "public struct PrimeLatinProposalProducerRevalidationRequestV1",
            "public struct PrimeLatinProposalProducerRevalidationObservationV1",
            "public struct PrimeLatinProposalProducerRevalidationAuthorityBoundaryV1",
            "public final class PrimeLatinProposalProducerRevalidationCaptureV1",
            "public static func capture(",
            "request: PrimeLatinProposalProducerRevalidationRequestV1",
            "recaptureAndValidateUnchanged()",
            "ergentics_prime_latin_proposal_v3_producer_revalidation_observation_v1",
            "abstain_producer_revalidation_observation_complete_requires_independent_prime_replay",
            "ergentics_latin_proposal_v3_live_revalidation_observation_v1",
            "PrimeLatinProposalGitSourceCaptureV3.capture(",
            "/usr/bin/xcrun",
            "Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-driver",
            "fixed_developer_directory_exact_swift_driver_binary_observed_not_cryptographically_authenticated",
            "swiftc",
            "-module-cache-path",
            "-parse-as-library",
            "-emit-module",
            "-emit-object",
            "-module-name",
            "ErgenticsLatinProposalArtifacts",
            "ErgenticsLatinProposalV3Revalidation",
            "ErgenticsLatinProposalV3RevalidationProbe",
            "ModuleCache",
            "process.standardInput",
            "process.standardOutput",
            "process.standardError",
            "process.environment",
            "process.currentDirectoryURL",
            "maximumStandardOutputByteCount",
            "65_537",
            "PrimeLatinProposalProducerRevalidationCaptureDependenciesV1",
            "static func captureForTesting(",
            "scratchParent",
            "createScratch(in:",
            "mkdtemp(",
            "mkdir(",
            "removeItem(",
            "acl_get_fd_np",
            "ACL_TYPE_EXTENDED",
            "flistxattr",
            "com.apple.provenance",
            "O_NOFOLLOW",
            "fstat(",
            "lstat(",
            "realpath(",
            "decodeChildObservationForTesting",
            "validateRepeatedOutputsForTesting",
            "makeAuthorityForTesting",
            "observeToolStateForTesting",
            "validateRootForTesting",
            "validateFileForTesting",
        ] {
            XCTAssertTrue(
                source.contains(required),
                "missing producer-revalidation source anchor: \(required)")
        }

        let frozenIdentities = [
            "1ccfb6bf6718e2378f14ab87cacae1ada303cf48",
            "6ee438bf1132d26767fbf447355b8165455b956f",
            "776c412e3f10e8bf4e33cd0ae60787d9ca6b5831",
            "380c13a3f9f3421db875d2ccc3c4547002374a9d74427a0573e0c59f6d3078ac",
            "802f7505ad91869b27420e0beb152e6ba725eb82a801b4fd9289d999afac0c81",
            "302ccde06959cc6ffb411d455ad656c9e50e4ce1",
            "686ee51886ed5813db6a9883cc6e5e9fa86f1e3f918dafad865e06926824a6e3",
            "828f18920113f77a849dec56997618ae6f1addc7",
            "91aa0ca7ebeeb97e808493ad4f0cede9c54dbb08ecc7476619e52cada883a0ee",
            "b050f965afab11b46bed9037b42c0a59d27e3f26",
            "180ebeb889cd6d585c89384efa8b4b55984501b4e6be0dbb8928d92cffb2c52d",
            "9617fac7d88afb2bf33df7324ab15efa1a5a94aa",
            "136a65f9f574b6a1f3a6e25d4fed66e9b859e536c55b8f28f8a6dd4797d64bd6",
            "Sources/ErgenticsLatinProposalArtifacts/ErgenticsLatinProposalArtifacts.swift",
            "Sources/ErgenticsLatinProposalV3Revalidation/ErgenticsLatinProposalV3Revalidation.swift",
            "Sources/ErgenticsLatinProposalV3RevalidationProbe/ErgenticsLatinProposalV3RevalidationProbeMain.swift",
            ".github/scripts/latin-proposal-artifacts.Package.swift",
        ]
        for identity in frozenIdentities {
            XCTAssertTrue(
                source.contains(identity),
                "missing exact revalidator-tool identity: \(identity)")
        }

        let childProbeOptions = [
            "--producer-repository-root",
            "--lab-root",
            "--expected-pair-receipt-sha256",
            "--dependency-lock-relative-path",
            "--initialization-contract-relative-path",
            "--corpus-manifest-relative-path",
            "--evaluation-contract-relative-path",
            "--training-split-id",
            "--training-split-relative-path",
            "--validation-split-id",
            "--validation-split-relative-path",
            "--selection-split-id",
            "--selection-split-relative-path",
            "--selection-observation-relative-path",
            "--optimizer-steps",
            "--training-tokens",
            "--wall-clock-seconds",
            "--output-namespace",
        ]
        XCTAssertEqual(childProbeOptions.count, 18)
        for option in childProbeOptions {
            XCTAssertEqual(
                source.components(separatedBy: "\"\(option)\"").count,
                2,
                "child revalidation option is not exact once: \(option)")
        }

        XCTAssertEqual(
            source.components(separatedBy: "Process()").count,
            2,
            "producer observer must have one closed Process construction")
        XCTAssertEqual(
            source.components(separatedBy: "process.executableURL").count,
            2,
            "producer observer must have one executable assignment")
        for (needle, count) in [
            ("/usr/bin/xcrun", 4),
            ("\"swiftc\"", 1),
            ("acl_get_fd_np", 1),
            ("flistxattr", 2),
            ("O_NOFOLLOW", 3),
            ("fstat(", 3),
            ("lstat(", 2),
            ("realpath(", 1),
            ("mkdtemp(", 1),
            ("mkdir(", 1),
            ("FileManager.default.removeItem", 2),
        ] {
            XCTAssertEqual(
                source.components(separatedBy: needle).count,
                count + 1,
                "producer observer lexical receipt changed: \(needle)")
        }
        XCTAssertTrue(source.contains("processLaunchCount == 5"))
        XCTAssertEqual(
            source.components(separatedBy: "timeoutSeconds: 120").count,
            3,
            "three compiler launches and two probe launches use two fixed call sites")
        XCTAssertTrue(source.contains("timeoutSeconds <= 300"))

        let compact = source.filter { !$0.isWhitespace }
        for byteCount in [
            "toolRawCommitByteCount:UInt64=1_328",
            "trackedIndexEntryCount:UInt64=147",
            "trackedIndexInventoryByteCount:UInt64=14_281",
            "byteCount:325_892",
            "byteCount:55_905",
            "byteCount:8_115",
            "byteCount:1_463",
        ] {
            XCTAssertTrue(
                compact.contains(byteCount),
                "missing exact revalidator-tool byte count: \(byteCount)")
        }
        for exactCount in [
            "compileCommandCount:3",
            "processLaunchCount:5",
            "governanceArtifactCount:4",
            "compilerInputSourceCount:3",
            "invocationCount:2",
        ] {
            XCTAssertTrue(
                compact.contains(exactCount),
                "missing exact build/process count: \(exactCount)")
        }
        for field in [
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
        ] {
            XCTAssertTrue(
                compact.contains("\(field)=true"),
                "missing positive producer-revalidation fact: \(field)")
        }
        for field in [
            "compilerCryptographicallyAuthenticated",
            "externalSourceToBinaryAttestationAvailable",
            "independentPrimeReplayComplete",
            "originRemoteCryptographicallyAuthenticated",
            "ignoredWorkspaceBytesObserved",
            "durableInputSnapshotPublished",
            "durableGitObservationPublished",
            "durableRevalidationObservationPublished",
            "runtimeDecoderImplementationAvailable",
            "runtimeDependencyClosureEstablished",
            "runtimeInitializationEstablished",
            "primeProposalPacketProduced",
            "primeTrialAuthorizationProduced",
            "primeDecisionReceiptProduced",
            "candidateSelectionAuthorized",
            "trialExecutionAuthorized",
            "furtherTrainingAuthorized",
            "promotionAuthorized",
            "productUseAuthorized",
            "publicationAuthorized",
            "proposalPairPublicationPerformedByThisObservation",
            "primeDurableReceiptPublished",
        ] {
            XCTAssertTrue(
                compact.contains("\(field)=false"),
                "missing producer-revalidation authority ceiling: \(field)")
        }

        for forbidden in [
            "import PrimeCore",
            "import ErgenticsLLM",
            "import ErgenticsTokenizer",
            "import MLX",
            "import MLXNN",
            "import MLXLLM",
            "ErgenticsPrimeRuntime",
            "LlamaModel",
            "HuggingFace",
            "PMHNP",
            "ProcessInfo.processInfo.environment",
            "URLSession",
            "Network.framework",
            "NWConnection",
            "socket(",
            "connect(",
            "\"/bin/sh\"",
            "\"/bin/bash\"",
            "\"/usr/bin/env\"",
            "swift build",
            "swift package",
            "publishProposalPairV3",
            "func publish",
            "--disable-sandbox",
        ] {
            XCTAssertFalse(
                source.contains(forbidden),
                "forbidden producer-revalidation capability: \(forbidden)")
        }
    }

    func testProducerRevalidationTargetIsASeparateGitObservationLeaf()
        throws
    {
        let root = URL(
            fileURLWithPath: FileManager.default.currentDirectoryPath,
            isDirectory: true)
        let manifest = try String(
            contentsOf: root.appendingPathComponent("Package.swift"),
            encoding: .utf8)
        let compact = manifest.filter { !$0.isWhitespace }
        XCTAssertTrue(
            compact.contains(
                ".target(" +
                    "name:\"PrimeLatinProposalProducerRevalidationObservation\"," +
                    "dependencies:[\"PrimeLatinProposalPairCapture\"," +
                    "\"PrimeLatinProposalGitObservation\",])"))
        XCTAssertTrue(
            compact.contains(
                ".executableTarget(" +
                    "name:\"PrimeLatinProposalProducerRevalidationObservationProbe\"," +
                    "dependencies:[" +
                    "\"PrimeLatinProposalProducerRevalidationObservation\",])"))
        XCTAssertTrue(
            compact.contains(
                ".testTarget(" +
                    "name:\"PrimeLatinProposalPairCaptureTests\"," +
                    "dependencies:[\"PrimeLatinProposalPairCapture\"," +
                    "\"PrimeLatinProposalGitObservation\"," +
                    "\"PrimeLatinProposalProducerRevalidationObservation\"," +
                    "\"PrimeLatinProposalIndependentReplay\",])"))
        for forbidden in [
            "PrimeCore",
            "ErgenticsPrimeRuntime",
            "ErgenticsLLM",
            "ErgenticsTokenizer",
            "MLX",
            "MLXNN",
            "MLXLLM",
        ] {
            XCTAssertFalse(
                compact.contains(
                    ".target(" +
                        "name:" +
                        "\"PrimeLatinProposalProducerRevalidationObservation\"," +
                        "dependencies:[\"\(forbidden)"),
                "forbidden producer-revalidation dependency: \(forbidden)")
        }
    }

    func testCaptureTargetHasNoTargetOrPackageDependency() throws {
        let root = URL(
            fileURLWithPath: FileManager.default.currentDirectoryPath,
            isDirectory: true)
        let manifest = try String(
            contentsOf: root.appendingPathComponent("Package.swift"),
            encoding: .utf8)
        let compact = manifest.filter { !$0.isWhitespace }
        XCTAssertTrue(
            compact.contains(
                ".target(name:\"PrimeLatinProposalPairCapture\")"))
        XCTAssertFalse(
            compact.contains(
                ".target(name:\"PrimeLatinProposalPairCapture\"," +
                "dependencies:"))
        XCTAssertFalse(
            try joinedSwiftSource(
                directory: "Sources/PrimeLatinProposalPairCapture")
                .contains("import PrimeCore"))
    }

    func testCaptureSourceRetainsStrictDescriptorAndWireBoundaries() throws {
        let source = try joinedSwiftSource(
            directory: "Sources/PrimeLatinProposalPairCapture")
        for required in [
            "ergentics_latin_proposal_pair_receipt_v1",
            "ergentics_latin_candidate_catalog_v1",
            "ergentics_latin_experiment_manifest_v1",
            "mechanics_only_non_authorizing",
            "requires_original_bound_input_bytes",
            "cooperative_process_lock_only",
            "abstain_requires_original_bound_input_bytes",
            "PrimeLatinArtifactRoot",
            "PrimeLatinVerifiedPublicationRead",
            "bindExisting(",
            "readVerifiedArtifact(",
            "verifiedRootIdentity()",
            ".immutableData",
            "requireNoForbiddenContext",
            "\"llama\"",
            "\"mlxllm\"",
            "\"mlx-swift-lm\"",
            "\"mlx_swift_lm\"",
            "\"mlx-community\"",
            "\"huggingface\"",
            "\"runtime-bundle-3b\"",
            "\"primecore\"",
            "\"pmhnp\"",
            "\"ml-explore/mlx-swift\"",
        ] {
            XCTAssertTrue(
                source.contains(required),
                "missing strict capture-source anchor: \(required)")
        }
    }

    func testProbeIsEphemeralStdoutOnly() throws {
        let source = try joinedSwiftSource(
            directory: "Sources/PrimeLatinProposalPairCaptureProbe")
        for required in [
            "PrimeLatinProposalPairCaptureArguments",
            "PrimeLatinProposalPairCapture",
            ".parse",
            ".capture",
            "ephemeralSummary",
            "FileHandle.standardOutput",
        ] {
            XCTAssertTrue(
                source.contains(required),
                "missing capture-probe anchor: \(required)")
        }
        for forbidden in [
            "FileManager.default.createFile",
            ".write(to:",
            "Process()",
            "URLSession",
            "python",
            "--disable-sandbox",
            "MLX",
            "ErgenticsLLM",
        ] {
            XCTAssertFalse(
                source.contains(forbidden),
                "forbidden capture-probe token: \(forbidden)")
        }
    }

    func testGitObservationProbeHasExactOnceOnlyReadOnlySurface() throws {
        let source = try swiftSource(
            relativePath:
                "Sources/PrimeLatinProposalGitObservationProbe/" +
                    "PrimeLatinProposalGitObservationProbeMain.swift")
        let imports = source.split(separator: "\n")
            .map(String.init)
            .filter { $0.hasPrefix("import ") }
        XCTAssertEqual(
            imports,
            [
                "import Foundation",
                "import PrimeLatinProposalGitObservation",
            ])
        for required in [
            "PrimeLatinProposalGitObservationArguments",
            "rawArguments.count == 8",
            "action == \"observe\"",
            "pairSHA256.utf8.allSatisfy",
            "Array(CommandLine.arguments.dropFirst())",
            "PrimeLatinProposalGitSourceCaptureV3.capture(",
            "recaptureAndValidateUnchanged()",
            "FileHandle.standardOutput",
            "output.count <= 1_024",
            "llm_git_state_independently_observed",
            "no_assume_unchanged_or_skip_worktree_index_entries_observed",
            "tracked_index_entry_count",
            "tracked_index_inventory_byte_count",
            "tracked_index_inventory_sha256",
            "observation.outcome == \"abstain\"",
            "observation.trackedIndexEntryCount == 144",
            "observation.trackedIndexInventoryByteCount == 6_933",
            "101afd50470f669f8b4de14f9188e16854a4166b355bf8a4e9ec810a59a9e289",
            "observation.gitCommandCount == 17",
            "authority.noAssumeUnchangedOrSkipWorktreeIndexEntriesObserved",
            "!authority.originRemoteCryptographicallyAuthenticated",
            "!authority.independentReplayComplete",
            "!authority.runtimeInitializationEstablished",
            "!authority.primeProposalPacketProduced",
            "!authority.trialExecutionAuthorized",
            "!authority.publicationAuthorized",
        ] {
            XCTAssertTrue(
                source.contains(required),
                "missing Git-observation probe anchor: \(required)")
        }
        for option in [
            "--action",
            "--lab-root",
            "--llm-repository-root",
            "--pair-sha256",
        ] {
            XCTAssertEqual(
                source.components(separatedBy: "\"\(option)\"").count,
                2,
                "Git-observation option is not exact once: \(option)")
        }
        for forbidden in [
            "Process(",
            "ProcessInfo.processInfo.environment",
            "URLSession",
            "FileHandle.standardError",
            "FileManager",
            ".write(to:",
            "createDirectory(",
            "createFile(",
            "MLX",
            "ErgenticsLLM",
            "PrimeCore",
            "--disable-sandbox",
        ] {
            XCTAssertFalse(
                source.contains(forbidden),
                "forbidden Git-observation probe token: \(forbidden)")
        }
    }

    func testProducerRevalidationProbeIsProcessFreeAndExactOnceOnly()
        throws
    {
        let source = try swiftSource(
            relativePath:
                "Sources/PrimeLatinProposalProducerRevalidationObservationProbe/" +
                    "PrimeLatinProposalProducerRevalidationObservationProbeMain.swift")
        let imports = source.split(separator: "\n")
            .map(String.init)
            .filter { $0.hasPrefix("import ") }
        XCTAssertEqual(
            imports,
            [
                "import Foundation",
                "import PrimeLatinProposalProducerRevalidationObservation",
            ])
        for required in [
            "PrimeLatinProposalProducerRevalidationProbeArguments",
            "rawArguments.count == 10",
            "action == \"observe\"",
            "Array(CommandLine.arguments.dropFirst())",
            "PrimeLatinProposalProducerRevalidationRequestV1(",
            "PrimeLatinProposalProducerRevalidationCaptureV1",
            ".capture(request: request)",
            "recaptureAndValidateUnchanged()",
            "observation == capture.observation",
            "ergentics_prime_latin_proposal_v3_producer_revalidation_observation_v1",
            "1ccfb6bf6718e2378f14ab87cacae1ada303cf48",
            "6ee438bf1132d26767fbf447355b8165455b956f",
            "toolSource.trackedIndexEntryCount == 147",
            "toolSource.trackedIndexInventoryByteCount == 14_281",
            "802f7505ad91869b27420e0beb152e6ba725eb82a801b4fd9289d999afac0c81",
            "build.compileCommandCount == 3",
            "build.processLaunchCount == 5",
            "build.governanceArtifactCount == 4",
            "build.compilerInputSourceCount == 3",
            "process.invocationCount == 2",
            "authority.liveProducerWorkspaceRevalidationComplete",
            "!authority.externalSourceToBinaryAttestationAvailable",
            "!authority.independentPrimeReplayComplete",
            "!authority.runtimeInitializationEstablished",
            "!authority.primeProposalPacketProduced",
            "!authority.trialExecutionAuthorized",
            "!authority.publicationAuthorized",
            "!authority.proposalPairPublicationPerformedByThisObservation",
            "FileHandle.standardOutput",
            "output.count <= 1_024",
        ] {
            XCTAssertTrue(
                source.contains(required),
                "missing producer-revalidation probe anchor: \(required)")
        }
        for option in [
            "--action",
            "--lab-root",
            "--producer-repository-root",
            "--tool-repository-root",
            "--scratch-parent",
        ] {
            XCTAssertEqual(
                source.components(separatedBy: "\"\(option)\"").count,
                2,
                "producer-revalidation option is not exact once: \(option)")
        }
        for forbidden in [
            "Process(",
            "ProcessInfo.processInfo.environment",
            "URLSession",
            "FileHandle.standardError",
            "FileManager",
            ".write(to:",
            "createDirectory(",
            "createFile(",
            "removeItem(",
            "import PrimeCore",
            "import ErgenticsLLM",
            "import ErgenticsTokenizer",
            "import MLX",
            "MLXLLM",
            "LlamaModel",
            "PMHNP",
            "--disable-sandbox",
        ] {
            XCTAssertFalse(
                source.contains(forbidden),
                "forbidden producer-revalidation probe token: \(forbidden)")
        }
    }

    func testIndependentReplayIsPrimeOwnedAndCannotUseTheProducerAsAnOracle()
        throws
    {
        let source = try swiftSource(
            relativePath:
                "Sources/PrimeLatinProposalIndependentReplay/" +
                    "PrimeLatinProposalIndependentReplayV1.swift")
        let imports = source.split(separator: "\n")
            .map(String.init)
            .filter { $0.hasPrefix("import ") }
        XCTAssertEqual(
            imports,
            [
                "import CryptoKit",
                "import Foundation",
                "import PrimeLatinProposalGitObservation",
                "import PrimeLatinProposalPairCapture",
            ])
        for required in [
            "public enum PrimeLatinProposalIndependentReplayError",
            "public struct PrimeLatinProposalIndependentReplayAuthorityBoundaryV1",
            "public struct PrimeLatinProposalIndependentReplayObservationV1",
            "public final class PrimeLatinProposalIndependentReplayCaptureV1",
            "public static func capture(",
            "labRoot: URL",
            "llmRepositoryRoot: URL",
            "public let observation",
            "public func recaptureAndValidateUnchanged()",
            "public let producerRepository: String",
            "public let producerCommit: String",
            "public let producerTree: String",
            "public let retainedOriginalInputByteCount: UInt64",
            "ergentics_prime_latin_proposal_v3_independent_replay_observation_v1",
            "prime_owned_independent_typed_reconstruction_from_one_git_bound_retained_twenty_one_original_input_snapshot_and_byte_exact_catalog_experiment_cross_check_only_non_authorizing",
            "abstain_independent_prime_structural_replay_complete_live_producer_revalidation_not_composed_and_runtime_decoder_initialization_evaluation_trial_and_publication_authority_absent",
            "prime_latin_v3_retained_original_input_independent_reconstruction_v1",
            "6c47d6ff17d72e48873c9f4ae9ce0a0fe7e57dea8e25db144c5f1d8d42761ff7",
            "776c412e3f10e8bf4e33cd0ae60787d9ca6b5831",
            "c1f41758aea2860ab06039776f5ea0403dff1b61",
            "12387e11fdbf68ab5b76cad79c6c958e9b82ddeca1cb588b844918a2ab0dc6b4",
            "8436ab6d656b2393792c564d0bdb9a25d1ade9f5c457ad3b96cf99bacc708a76",
            "4b31feeeba780bc39c064d4540f5701935f960e1e1d8c82c81d295a65e643a70",
            "45d15481883cf606e8e739aa71815bf9bd2fdd51494059328e3ba16a9ed5fb8f",
            "815b3231fbb000968bbe2c19efe92013540d7241cba728c9b0ec1e89e9a4d193",
            "45c787dba8c538794cbaf7cb90acb4528d2dedcaf666a1f0da151ca236138881",
            "9fa3b6eea42a9c4c13ec1ecda2309ec4c35b3022638ae61a08dd2f0fcb9b074c",
            "64a288b62cdef276923eb72e5cc4d209a7195526408414fc5167522151481265",
            "6f07896e50b2b530ea5f5924859d1e66bf9880366c16cf37832138a0e6c7f4bd",
            "models/latin-prospective/structural-fixture-v3-776c412e",
        ] {
            XCTAssertTrue(
                source.contains(required),
                "missing independent-replay anchor: \(required)")
        }
        let compact = source.filter { !$0.isWhitespace }
        for field in [
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
            "llmGitStateIndependentlyObserved",
            "independentPrimeReplayComplete",
        ] {
            XCTAssertTrue(
                compact.contains("\(field)=true"),
                "independent-replay completion receipt is not true: \(field)")
        }
        for field in [
            "ergenticsLatinProducerModuleImported",
            "ergenticsLatinProducerFunctionInvoked",
            "ergenticsLatinProducerSourceUsedAsReplayImplementation",
            "liveProducerWorkspaceRevalidationComplete",
            "revalidatorToolSourceIndependentlyObserved",
            "originRemoteCryptographicallyAuthenticated",
            "ignoredWorkspaceBytesObserved",
            "declarationSourceSemanticsIndependentlyVerified",
            "tokenizerModelSemanticsIndependentlyValidated",
            "tokenizerTrainingReplayComplete",
            "evaluationExecutionComplete",
            "selectionObservationComplete",
            "durableInputSnapshotPublished",
            "durableGitObservationPublished",
            "durableIndependentReplayObservationPublished",
            "runtimeDecoderImplementationAvailable",
            "runtimeDependencyClosureEstablished",
            "runtimeInitializationEstablished",
            "primeProposalPacketProduced",
            "primeTrialAuthorizationProduced",
            "primeDecisionReceiptProduced",
            "candidateSelectionAuthorized",
            "trialExecutionAuthorized",
            "furtherTrainingAuthorized",
            "promotionAuthorized",
            "productUseAuthorized",
            "publicationAuthorized",
            "proposalPairPublicationPerformedByThisObservation",
            "primeDurableReceiptPublished",
        ] {
            XCTAssertTrue(
                compact.contains("\(field)=false"),
                "independent-replay authority ceiling is not false: \(field)")
        }
        for forbidden in [
            "import PrimeLatinProposalProducerRevalidationObservation",
            "PrimeLatinProposalProducerRevalidationCapture",
            "import PrimeCore",
            "import ErgenticsLLM",
            "import ErgenticsTokenizer",
            "import ErgenticsLatinProposalArtifacts",
            "import ErgenticsLatinCandidateDeclarations",
            "import MLX",
            "MLXLLM",
            "LlamaModel",
            "ErgenticsPrimeRuntime",
            "Process(",
            "ProcessInfo.processInfo.environment",
            "URLSession",
            "NWConnection",
            "socket(",
            "connect(",
            "FileHandle.standardOutput",
            "FileHandle.standardError",
            "O_CREAT",
            "O_WRONLY",
            "O_RDWR",
            "createDirectory(",
            "createFile(",
            "removeItem(",
            "publishProposalPairV3",
            "func publish",
            "--disable-sandbox",
        ] {
            XCTAssertFalse(
                source.contains(forbidden),
                "independent replay contains a forbidden oracle/capability: \(forbidden)")
        }
    }

    func testIndependentReplayTargetIsADisjointSiblingLeaf() throws {
        let root = URL(
            fileURLWithPath: FileManager.default.currentDirectoryPath,
            isDirectory: true)
        let manifest = try String(
            contentsOf: root.appendingPathComponent("Package.swift"),
            encoding: .utf8)
        let compact = manifest.filter { !$0.isWhitespace }
        XCTAssertTrue(
            compact.contains(
                ".target(" +
                    "name:\"PrimeLatinProposalIndependentReplay\"," +
                    "dependencies:[\"PrimeLatinProposalPairCapture\"," +
                    "\"PrimeLatinProposalGitObservation\",])"))
        XCTAssertTrue(
            compact.contains(
                ".executableTarget(" +
                    "name:\"PrimeLatinProposalIndependentReplayProbe\"," +
                    "dependencies:[" +
                    "\"PrimeLatinProposalIndependentReplay\",])"))
        XCTAssertTrue(
            compact.contains(
                ".testTarget(" +
                    "name:\"PrimeLatinProposalPairCaptureTests\"," +
                    "dependencies:[\"PrimeLatinProposalPairCapture\"," +
                    "\"PrimeLatinProposalGitObservation\"," +
                    "\"PrimeLatinProposalProducerRevalidationObservation\"," +
                    "\"PrimeLatinProposalIndependentReplay\",])"))
        XCTAssertFalse(
            compact.contains(
                "name:\"PrimeLatinProposalIndependentReplay\"," +
                    "dependencies:[" +
                    "\"PrimeLatinProposalProducerRevalidationObservation\""))
        for forbidden in [
            "PrimeCore",
            "ErgenticsPrimeRuntime",
            "ErgenticsLLM",
            "ErgenticsTokenizer",
            "MLX",
            "MLXNN",
            "MLXLLM",
        ] {
            XCTAssertFalse(
                compact.contains(
                    ".target(" +
                        "name:\"PrimeLatinProposalIndependentReplay\"," +
                        "dependencies:[\"\(forbidden)"),
                "forbidden independent-replay dependency: \(forbidden)")
        }
    }

    func testIndependentReconstructorCannotConsultReferenceOrProducerOracles()
        throws
    {
        let source = try swiftSource(
            relativePath:
                "Sources/PrimeLatinProposalIndependentReplay/" +
                    "PrimeLatinProposalIndependentReplayV1.swift")
        guard let reconstructorStart = source.range(
                of: "enum PrimeLatinProposalIndependentReconstructorV1"),
              let comparatorStart = source.range(
                of: "enum PrimeLatinProposalIndependentReplayComparatorV1"),
              reconstructorStart.lowerBound < comparatorStart.lowerBound else {
            return XCTFail("independent replay source boundaries are missing")
        }
        let reconstructor = String(
            source[
                reconstructorStart.lowerBound..<comparatorStart.lowerBound])
        guard let signatureStart = reconstructor.range(
                of: "static func reconstruct("),
              let signatureEnd = reconstructor.range(
                of:
                    ") throws -> " +
                        "PrimeLatinProposalIndependentReplayReconstructionV1 {",
                range: signatureStart.lowerBound..<reconstructor.endIndex) else {
            return XCTFail("independent reconstructor signature is missing")
        }
        let signature = String(
            reconstructor[
                signatureStart.lowerBound..<signatureEnd.upperBound])
            .filter { !$0.isWhitespace }
        XCTAssertEqual(
            signature,
            "staticfuncreconstruct(" +
                "originalInputs:" +
                "PrimeLatinProposalIndependentReplayOriginalInputsV1," +
                "expectedPlan:" +
                "PrimeLatinProposalIndependentReplayExpectedPlanV1)" +
                "throws->" +
                "PrimeLatinProposalIndependentReplayReconstructionV1{")
        for forbidden in [
            "PrimeLatinProposalIndependentReplayReferenceV1",
            "references:",
            "reference.",
            "PrimeLatinProposalProducerRevalidation",
            "ProducerRevalidation",
            "producerRevalidation",
        ] {
            XCTAssertFalse(
                reconstructor.contains(forbidden),
                "independent reconstructor contains an oracle: \(forbidden)")
        }
    }

    func testIndependentReplayProbeIsProcessFreeAndExactOnceOnly() throws {
        let source = try swiftSource(
            relativePath:
                "Sources/PrimeLatinProposalIndependentReplayProbe/" +
                    "PrimeLatinProposalIndependentReplayProbeMain.swift")
        let imports = source.split(separator: "\n")
            .map(String.init)
            .filter { $0.hasPrefix("import ") }
        XCTAssertEqual(
            imports,
            [
                "import Foundation",
                "import PrimeLatinProposalIndependentReplay",
            ])
        for required in [
            "PrimeLatinProposalIndependentReplayProbeArguments",
            "rawArguments.count == 6",
            "action == \"replay\"",
            "Array(CommandLine.arguments.dropFirst())",
            "PrimeLatinProposalIndependentReplayCaptureV1.capture(",
            "labRoot: arguments.labRoot",
            "llmRepositoryRoot: arguments.llmRepositoryRoot",
            "recaptureAndValidateUnchanged()",
            "recaptured == observation",
            "observation.producerRepository == \"Ergentics/ergentics-llm\"",
            "observation.producerCommit",
            "observation.producerTree",
            "observation.retainedOriginalInputByteCount == 8_084_712",
            "ergentics_prime_latin_proposal_v3_independent_replay_observation_v1",
            "authority.independentPrimeReplayComplete",
            "!authority.liveProducerWorkspaceRevalidationComplete",
            "!authority.ergenticsLatinProducerModuleImported",
            "!authority.ergenticsLatinProducerFunctionInvoked",
            "!authority.ergenticsLatinProducerSourceUsedAsReplayImplementation",
            "!authority.runtimeInitializationEstablished",
            "!authority.trialExecutionAuthorized",
            "!authority.publicationAuthorized",
            "FileHandle.standardOutput",
            "output.count <= 1_024",
        ] {
            XCTAssertTrue(
                source.contains(required),
                "missing independent-replay probe anchor: \(required)")
        }
        for option in [
            "--action",
            "--lab-root",
            "--llm-repository-root",
        ] {
            XCTAssertEqual(
                source.components(separatedBy: "\"\(option)\"").count,
                2,
                "independent-replay option is not exact once: \(option)")
        }
        for forbidden in [
            "Process(",
            "ProcessInfo.processInfo.environment",
            "URLSession",
            "FileHandle.standardError",
            "FileManager",
            ".write(to:",
            "createDirectory(",
            "createFile(",
            "removeItem(",
            "import PrimeCore",
            "import PrimeLatinProposalProducerRevalidationObservation",
            "import ErgenticsLLM",
            "import ErgenticsTokenizer",
            "import MLX",
            "MLXLLM",
            "LlamaModel",
            "PMHNP",
            "--disable-sandbox",
        ] {
            XCTAssertFalse(
                source.contains(forbidden),
                "forbidden independent-replay probe token: \(forbidden)")
        }
    }

    private func joinedSwiftSource(directory: String) throws -> String {
        let root = URL(
            fileURLWithPath: FileManager.default.currentDirectoryPath,
            isDirectory: true)
        let directoryURL = root.appendingPathComponent(
            directory,
            isDirectory: true)
        let files = try FileManager.default.contentsOfDirectory(
            at: directoryURL,
            includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "swift" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
        XCTAssertFalse(files.isEmpty, "no Swift source in \(directory)")
        return try files.map {
            try String(contentsOf: $0, encoding: .utf8)
        }.joined(separator: "\n")
    }

    private func swiftSource(relativePath: String) throws -> String {
        let root = URL(
            fileURLWithPath: FileManager.default.currentDirectoryPath,
            isDirectory: true)
        return try String(
            contentsOf: root.appendingPathComponent(relativePath),
            encoding: .utf8)
    }
}
