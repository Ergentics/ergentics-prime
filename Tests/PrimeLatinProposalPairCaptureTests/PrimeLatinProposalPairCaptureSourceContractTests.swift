import CryptoKit
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
                    "\"PrimeLatinProposalIndependentReplay\"," +
                    "\"PrimeLatinProposalValidationComposition\"," +
                    "\"PrimeLatinProposalValidationCompositionReceipt\"," +
                    "\"PrimeLatinProposalValidationCompositionReceiptPublisher\"," +
                    "\"PrimeLatinProposalAdmissionPolicy\",])"))
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
                    "\"PrimeLatinProposalIndependentReplay\"," +
                    "\"PrimeLatinProposalValidationComposition\"," +
                    "\"PrimeLatinProposalValidationCompositionReceipt\"," +
                    "\"PrimeLatinProposalValidationCompositionReceiptPublisher\"," +
                    "\"PrimeLatinProposalAdmissionPolicy\",])"))
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

    func testValidationCompositionIsExactAndNonAuthorizing() throws {
        let source = try swiftSource(
            relativePath:
                "Sources/PrimeLatinProposalValidationComposition/" +
                    "PrimeLatinProposalValidationCompositionV1.swift")
        let imports = source.split(separator: "\n")
            .map(String.init)
            .filter { $0.hasPrefix("import ") }
        XCTAssertEqual(
            imports,
            [
                "import Foundation",
                "import PrimeLatinProposalIndependentReplay",
                "import PrimeLatinProposalProducerRevalidationObservation",
            ])
        for required in [
            "public enum PrimeLatinProposalValidationCompositionErrorV1",
            "public struct PrimeLatinProposalValidationCompositionAuthorityBoundaryV1",
            "public struct PrimeLatinProposalValidationCompositionObservationV1",
            "public final class PrimeLatinProposalValidationCompositionCaptureV1",
            "public static func capture(",
            "request: PrimeLatinProposalProducerRevalidationRequestV1",
            "public let observation",
            "public func recaptureAndValidateUnchanged()",
            "PrimeLatinProposalProducerRevalidationCaptureV1",
            "PrimeLatinProposalIndependentReplayCaptureV1",
            "compositionPolicyID",
            "producerRevalidationObservation",
            "independentReplayObservation",
            "invalidChildObservation",
            "crossBindingMismatch",
            "captureChanged",
            "ergentics_prime_latin_proposal_v3_validation_composition_observation_v1",
            "prime_latin_v3_producer_revalidation_independent_replay_composition_v1",
            "prime_owned_cooperative_same_request_root_sequence_composing_one_live_producer_revalidation_observation_and_one_independent_replay_observation_with_exact_shared_identity_hash_count_budget_and_output_namespace_cross_bindings_only_non_authorizing",
            "abstain_live_producer_revalidation_and_independent_prime_replay_composed_proposal_policy_runtime_decoder_initialization_evaluation_trial_decision_and_publication_authority_absent",
        ] {
            XCTAssertTrue(
                source.contains(required),
                "missing validation-composition anchor: \(required)")
        }
        let compact = source.filter { !$0.isWhitespace }
        for field in [
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
        ] {
            XCTAssertTrue(
                compact.contains("\(field)=true"),
                "validation-composition completion is not true: \(field)")
        }
        for field in [
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
        ] {
            XCTAssertTrue(
                compact.contains("\(field)=false"),
                "validation-composition authority ceiling is not false: \(field)")
        }
        for forbidden in [
            "import PrimeLatinProposalPairCapture",
            "import PrimeLatinProposalGitObservation",
            "PrimeLatinProposalPairCaptureV3",
            "PrimeLatinProposalGitSourceCaptureV3",
            "PrimeLatinProposalInputSnapshotCaptureV3",
            "import PrimeCore",
            "import ErgenticsLLM",
            "import ErgenticsTokenizer",
            "import MLX",
            "MLXLLM",
            "LlamaModel",
            "ErgenticsPrimeRuntime",
            "@main",
            "CommandLine",
            "Process(",
            "ProcessInfo.processInfo.environment",
            "FileManager",
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
                "validation composition contains a forbidden capability: \(forbidden)")
        }
    }

    func testValidationCompositionIsInternalAndUsesTheExistingTestLane()
        throws
    {
        let root = URL(
            fileURLWithPath: FileManager.default.currentDirectoryPath,
            isDirectory: true)
        for relativePath in [
            "Package.swift",
        ] {
            let manifest = try String(
                contentsOf: root.appendingPathComponent(relativePath),
                encoding: .utf8)
            let compact = manifest.filter { !$0.isWhitespace }
            XCTAssertTrue(
                compact.contains(
                    ".target(" +
                        "name:\"PrimeLatinProposalValidationComposition\"," +
                        "dependencies:[" +
                        "\"PrimeLatinProposalProducerRevalidationObservation\"," +
                        "\"PrimeLatinProposalIndependentReplay\",])"),
                "missing exact composition graph in \(relativePath)")
            XCTAssertTrue(
                compact.contains(
                    ".target(" +
                        "name:\"PrimeLatinProposalValidationCompositionReceipt\")"),
                "missing pure receipt target in \(relativePath)")
            XCTAssertTrue(
                compact.contains(
                    ".target(" +
                        "name:\"PrimeLatinProposalValidationCompositionReceiptPublisher\"," +
                        "dependencies:[\"PrimeCore\"," +
                        "\"PrimeLatinProposalValidationComposition\"," +
                        "\"PrimeLatinProposalValidationCompositionReceipt\",])"),
                "missing exact receipt-publisher graph in \(relativePath)")
            XCTAssertTrue(
                compact.contains(
                    ".target(" +
                        "name:\"PrimeLatinProposalAdmissionPolicy\"," +
                        "dependencies:[" +
                        "\"PrimeLatinProposalValidationCompositionReceipt\",])"),
                "missing exact admission-policy graph in \(relativePath)")
            XCTAssertTrue(
                compact.contains(
                    ".testTarget(" +
                        "name:\"PrimeLatinProposalPairCaptureTests\"," +
                        "dependencies:[\"PrimeLatinProposalPairCapture\"," +
                        "\"PrimeLatinProposalGitObservation\"," +
                        "\"PrimeLatinProposalProducerRevalidationObservation\"," +
                        "\"PrimeLatinProposalIndependentReplay\"," +
                        "\"PrimeLatinProposalValidationComposition\"," +
                        "\"PrimeLatinProposalValidationCompositionReceipt\"," +
                        "\"PrimeLatinProposalValidationCompositionReceiptPublisher\"," +
                        "\"PrimeLatinProposalAdmissionPolicy\",])"),
                "composition is outside the existing test lane in \(relativePath)")
            for forbidden in [
                ".library(name:\"PrimeLatinProposalValidationComposition\"",
                ".executable(name:\"PrimeLatinProposalValidationComposition\"",
                ".executableTarget(name:\"PrimeLatinProposalValidationComposition\"",
                "name:\"PrimeLatinProposalValidationComposition\"," +
                    "dependencies:[\"PrimeLatinProposalPairCapture\"",
                "name:\"PrimeLatinProposalValidationComposition\"," +
                    "dependencies:[\"PrimeLatinProposalGitObservation\"",
                "name:\"PrimeLatinProposalValidationComposition\"," +
                    "dependencies:[\"PrimeCore\"",
                "name:\"PrimeLatinProposalValidationComposition\"," +
                    "dependencies:[\"MLX\"",
                ".library(name:\"PrimeLatinProposalValidationCompositionReceipt\"",
                ".library(name:\"PrimeLatinProposalValidationCompositionReceiptPublisher\"",
                ".executable(name:\"PrimeLatinProposalValidationCompositionReceipt\"",
                ".executable(name:\"PrimeLatinProposalValidationCompositionReceiptPublisher\"",
                ".executableTarget(name:\"PrimeLatinProposalValidationCompositionReceipt\"",
                ".executableTarget(name:\"PrimeLatinProposalValidationCompositionReceiptPublisher\"",
                ".library(name:\"PrimeLatinProposalAdmissionPolicy\"",
                ".executable(name:\"PrimeLatinProposalAdmissionPolicy\"",
                ".executableTarget(name:\"PrimeLatinProposalAdmissionPolicy\"",
                "name:\"PrimeLatinProposalAdmissionPolicy\"," +
                    "dependencies:[\"PrimeCore\"",
                "name:\"PrimeLatinProposalAdmissionPolicy\"," +
                    "dependencies:[\"PrimeLatinProposalPairCapture\"",
                "name:\"PrimeLatinProposalAdmissionPolicy\"," +
                    "dependencies:[\"PrimeLatinProposalValidationComposition\"",
                "name:\"PrimeLatinProposalAdmissionPolicy\"," +
                    "dependencies:[\"PrimeLatinProposalValidationCompositionReceiptPublisher\"",
                "name:\"PrimeLatinProposalAdmissionPolicy\"," +
                    "dependencies:[\"MLX\"",
                "name:\"PrimeLatinProposalValidationCompositionReceipt\"," +
                    "dependencies:[",
                "name:\"PrimeLatinProposalValidationCompositionReceiptPublisher\"," +
                    "dependencies:[\"PrimeLatinProposalPairCapture\"",
                "name:\"PrimeLatinProposalValidationCompositionReceiptPublisher\"," +
                    "dependencies:[\"PrimeLatinProposalGitObservation\"",
                "name:\"PrimeLatinProposalValidationCompositionReceiptPublisher\"," +
                    "dependencies:[\"MLX\"",
            ] {
                XCTAssertFalse(
                    compact.contains(forbidden),
                    "forbidden validation-composition package surface in " +
                        "\(relativePath): \(forbidden)")
            }
        }
    }

    func testProposalAdmissionPolicyIsPureTypedAndNonAuthorizing() throws {
        let source = try swiftSource(
            relativePath:
                "Sources/PrimeLatinProposalAdmissionPolicy/" +
                    "PrimeLatinProposalAdmissionPolicyV1.swift")
        let imports = source.split(separator: "\n")
            .map(String.init)
            .filter { $0.hasPrefix("import ") }
        XCTAssertEqual(
            imports,
            ["import PrimeLatinProposalValidationCompositionReceipt"])

        for required in [
            "public enum PrimeLatinProposalAdmissionOutcomeV1",
            "case abstain = \"ABSTAIN\"",
            "public enum PrimeLatinProposalAdmissionReasonV1",
            "decoded_receipt_does_not_restore_current_live_validation",
            "exact_candidate_id_classified_as_structural_fixture_by_policy",
            "runtime_decoder_implementation_not_established_by_receipt",
            "runtime_dependency_closure_not_established_by_receipt",
            "runtime_initialization_not_established_by_receipt",
            "public struct PrimeLatinProposalAdmissionAuthorityBoundaryV1",
            "public struct PrimeLatinProposalAdmissionEvaluationV1",
            "public enum PrimeLatinProposalAdmissionPolicyV1",
            "public static func evaluate(",
            "try receipt.validateExactV1()",
            "ergentics_prime_latin_proposal_v3_admission_observation_v1",
            "exact_frozen_v3_typed_receipt_projection_only_no_artifact_",
            "binding_or_current_liveness",
            "prime_latin_v3_exact_typed_receipt_projection_admission_v1",
            "abstain_exact_typed_validation_composition_receipt_projection_",
            "admission_evaluated_current_live_validation_not_restored_",
            "candidate_classified_structural_fixture_runtime_decoder_",
            "dependency_closure_and_initialization_not_established_by_",
        ] {
            XCTAssertTrue(
                source.contains(required),
                "admission policy lacks exact anchor: \(required)")
        }

        let outcome = try sourceSection(
            source,
            from: "public enum PrimeLatinProposalAdmissionOutcomeV1:",
            to: "public enum PrimeLatinProposalAdmissionReasonV1:")
        let reasons = try sourceSection(
            source,
            from: "public enum PrimeLatinProposalAdmissionReasonV1:",
            to:
                "public struct " +
                    "PrimeLatinProposalAdmissionAuthorityBoundaryV1:")
        XCTAssertEqual(fixedOccurrenceCount("CaseIterable", in: outcome), 1)
        XCTAssertEqual(fixedOccurrenceCount("case ", in: outcome), 1)
        XCTAssertEqual(fixedOccurrenceCount("CaseIterable", in: reasons), 1)
        XCTAssertEqual(fixedOccurrenceCount("case ", in: reasons), 5)

        let authority = try sourceSection(
            source,
            from:
                "public struct " +
                    "PrimeLatinProposalAdmissionAuthorityBoundaryV1:",
            to:
                "public struct " +
                    "PrimeLatinProposalAdmissionEvaluationV1:")
        let evaluation = try sourceSection(
            source,
            from:
                "public struct PrimeLatinProposalAdmissionEvaluationV1:",
            to: "public enum PrimeLatinProposalAdmissionPolicyV1")
        for (surface, section) in [
            ("authority", authority),
            ("evaluation", evaluation),
        ] {
            for forbidden in [
                "Codable",
                "Encodable",
                "Decodable",
                "public init",
            ] {
                XCTAssertFalse(
                    section.contains(forbidden),
                    "admission \(surface) exposes \(forbidden)")
            }
        }

        let authorityCompact = authority.filter { !$0.isWhitespace }
        let trueFields = [
            "exactTypedReceiptProjectionValidated",
            "sourceReceiptHistoricalAuthorityClaimsRetained",
            "exactCandidateIDClassifiedAsStructuralFixtureByPolicy",
            "primeProposalPolicyEstablished",
            "proposalAdmissionEvaluationComplete",
            "typedAbstainProduced",
            "orderedAbstentionReasonsComplete",
        ]
        let falseFields = [
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
            "currentLiveProducerWorkspaceRevalidationRestoredFromReceipt",
            "currentIndependentPrimeReplayRestoredFromReceipt",
            "runtimeDecoderImplementationAvailable",
            "runtimeDependencyClosureEstablished",
            "runtimeInitializationEstablished",
            "receiptArtifactBindingVerified",
            "canonicalReceiptBytesVerified",
            "receiptContentAddressVerified",
            "durableInputSnapshotPublished",
            "durableGitObservationPublished",
            "durableProducerRevalidationObservationPublished",
            "durableIndependentReplayObservationPublished",
            "durableValidationCompositionObservationPublished",
            "rawProducerRevalidationObservationAvailableToPolicy",
            "rawIndependentReplayObservationAvailableToPolicy",
            "durableValidationCompositionReceiptPublished",
            "primeDurableReceiptPublished",
            "proposalAdmissionGranted",
            "primeProposalPacketProduced",
            "primeTrialAuthorizationProduced",
            "primeDecisionReceiptProduced",
            "candidateSelectionAuthorized",
            "trialExecutionAuthorized",
            "furtherTrainingAuthorized",
            "promotionAuthorized",
            "productUseAuthorized",
            "publicationAuthorized",
            "proposalPairPublicationPerformedByThisPolicy",
            "admissionObservationPublished",
            "publicNetworkPublicationPerformed",
        ]
        XCTAssertEqual(trueFields.count, 7)
        XCTAssertEqual(falseFields.count, 40)
        XCTAssertEqual(
            fixedOccurrenceCount(":Bool", in: authorityCompact), 47)
        for field in trueFields {
            XCTAssertTrue(
                authorityCompact.contains("publiclet\(field):Bool"),
                "admission authority lacks true field: \(field)")
            XCTAssertTrue(
                authorityCompact.contains("\(field)=true"),
                "admission completion is not true: \(field)")
        }
        for field in falseFields {
            XCTAssertTrue(
                authorityCompact.contains("publiclet\(field):Bool"),
                "admission authority lacks false field: \(field)")
            XCTAssertTrue(
                authorityCompact.contains("\(field)=false"),
                "admission ceiling is not false: \(field)")
        }

        XCTAssertEqual(
            fixedOccurrenceCount("try receipt.validateExactV1()", in: source),
            1)
        XCTAssertEqual(
            fixedOccurrenceCount("public static func evaluate(", in: source),
            1)
        XCTAssertEqual(
            fixedOccurrenceCount("public static let ", in: source), 1)
        for forbidden in [
            "import Foundation",
            "import PrimeCore",
            "import PrimeLatinProposalPairCapture",
            "import PrimeLatinProposalGitObservation",
            "import PrimeLatinProposalProducerRevalidationObservation",
            "import PrimeLatinProposalIndependentReplay",
            "import PrimeLatinProposalValidationComposition\n",
            "import PrimeLatinProposalValidationCompositionReceiptPublisher",
            "import ErgenticsLLM",
            "import ErgenticsTokenizer",
            "import MLX",
            "MLXLLM",
            "LlamaModel",
            "HuggingFace",
            "PMHNP",
            "ErgenticsPrimeRuntime",
            "@main",
            "CommandLine",
            "Process(",
            "ProcessInfo.processInfo.environment",
            "FileManager",
            "FileHandle",
            "URLSession",
            "NWConnection",
            "socket(",
            "connect(",
            "O_CREAT",
            "O_WRONLY",
            "O_RDWR",
            "createDirectory(",
            "createFile(",
            "removeItem(",
            "func publish",
            "PrimeLatinTrialProposal",
            "PrimeLatinTrialAuthorization",
            "--disable-sandbox",
        ] {
            XCTAssertFalse(
                source.contains(forbidden),
                "admission policy contains forbidden capability: \(forbidden)")
        }
    }

    func testValidationCompositionReceiptPublisherUsesExactPrimeCoreClosure()
        throws
    {
        let root = URL(
            fileURLWithPath: FileManager.default.currentDirectoryPath,
            isDirectory: true)
        let manifest = try String(
            contentsOf: root.appendingPathComponent("Package.swift"),
            encoding: .utf8)
        let manifestCompact = manifest.filter { !$0.isWhitespace }
        XCTAssertTrue(
            manifestCompact.contains(".target(name:\"PrimeCore\")"),
            "validation must compile the real PrimeCore target")
        XCTAssertFalse(
            manifestCompact.contains(".target(name:\"PrimeCore\",sources:"),
            "PrimeCore target must use the exact staged default inventory")
        XCTAssertTrue(
            manifestCompact.contains(
                ".target(" +
                    "name:\"PrimeLatinProposalValidationCompositionReceiptPublisher\"," +
                    "dependencies:[\"PrimeCore\"," +
                    "\"PrimeLatinProposalValidationComposition\"," +
                    "\"PrimeLatinProposalValidationCompositionReceipt\",])"),
            "receipt publisher must depend on the real PrimeCore target")

        let closure: [(
            name: String,
            sha256: String?,
            byteCount: Int,
            imports: [String]
        )] = [
            (
                "PrimeDurableArtifacts.swift",
                "faa8254ee6ecd97f064a6553efba8158fff6a33fc882607444ba117d56328430",
                144_993,
                [
                    "import Darwin",
                    "import Glibc",
                    "import CryptoKit",
                    "import CoreFoundation",
                    "import Foundation",
                ]
            ),
            (
                "PrimeEmbeddedBuildProvenance.swift",
                nil,
                546,
                []
            ),
            (
                "PrimeFactorizedExecution.swift",
                "8b60e3937d5c8aee8a13a8a14a7dd1e579e6fa07bc95d06841bf9511275d9338",
                40_428,
                ["import Foundation"]
            ),
            (
                "PrimeMLXRuntimeEnvironmentPolicy.swift",
                "20fee288a85722d61eae63f10d38dbae226312ee31774b03712ff6cf1759b0f0",
                2_315,
                ["import Foundation"]
            ),
            (
                "PrimeMLXRuntimeImageLayout.swift",
                "59ef17e619ef60d9445db624058ba9ebf133189461344e72d4b05c485ad1f623",
                5_342,
                []
            ),
            (
                "PrimeNative3BProfile.swift",
                "a2e64e16dc6f172d468e56229ae52487a6443d2b630385742d5cfe67998d5dc1",
                1_736,
                ["import Foundation"]
            ),
            (
                "PrimePinnedMLXMetallib.swift",
                "a5f875c089613f82e2bc1044f35fa1a2bfe13d3498685db4c9f9e5fc1ec51d78",
                51_777,
                [
                    "import Darwin",
                    "import Glibc",
                    "import Foundation",
                ]
            ),
            (
                "PrimeReleaseInstrumentationAdmissionPolicy.swift",
                "397d4ac8204c29ec84fdc1e88fa44ee9fef22a95261f76084ab132d42dcd95e6",
                12_184,
                [
                    "import Darwin",
                    "import Foundation",
                    "import MachO",
                ]
            ),
            (
                "PrimeSwiftSourceProvenance.swift",
                "c907444671a8c7c53d4400da8ebe832e588bbb398831aebb0b23778a85391565",
                26_105,
                [
                    "import Darwin",
                    "import Glibc",
                    "import Foundation",
                ]
            ),
        ]
        XCTAssertEqual(closure.count, 9)
        XCTAssertEqual(
            closure.map { $0.name },
            closure.map { $0.name }.sorted(),
            "PrimeCore validation closure must remain sorted")
        XCTAssertEqual(
            closure.reduce(0) { $0 + $1.byteCount },
            285_426)

        let primeCore = root.appendingPathComponent(
            "Sources/PrimeCore",
            isDirectory: true)
        var sources = [String: String]()
        for record in closure {
            let sourceURL = primeCore.appendingPathComponent(record.name)
            let data = try Data(contentsOf: sourceURL)
            let historicalData = ["PrimeDurableArtifacts.swift", "PrimePinnedMLXMetallib.swift"].contains(record.name)
                ? try PrimeHistoricalSourceEvolutionTestSupport.historicalData(
                    path: "Sources/PrimeCore/" + record.name, current: data,
                    expectedByteCount: UInt64(record.byteCount), expectedSHA256: try XCTUnwrap(record.sha256))
                : data
            XCTAssertEqual(
                historicalData.count,
                record.byteCount,
                "PrimeCore validation source byte count changed: \(record.name)")
            if let expectedSHA256 = record.sha256 {
                XCTAssertEqual(
                    sha256Hex(historicalData),
                    expectedSHA256,
                    "PrimeCore validation source hash changed: \(record.name)")
            }
            let source = String(decoding: data, as: UTF8.self)
            sources[record.name] = source
            let imports = source.split(separator: "\n")
                .map(String.init)
                .filter { $0.hasPrefix("import ") }
            XCTAssertEqual(
                imports,
                record.imports,
                "PrimeCore validation imports changed: \(record.name)")
            XCTAssertFalse(imports.contains { $0.hasPrefix("import MLX") })
            XCTAssertFalse(imports.contains { $0.hasPrefix("import Ergentics") })
        }

        try PrimeHistoricalSourceEvolutionTestSupport.assertRejectedMutations(root: root)

        let embedded = try XCTUnwrap(
            sources["PrimeEmbeddedBuildProvenance.swift"])
        let embeddedIdentities = embedded
            .split(separator: "\"", omittingEmptySubsequences: false)
            .map(String.init)
            .filter {
                $0.utf8.count == 64 && $0.utf8.allSatisfy {
                    ($0 >= 48 && $0 <= 57) || ($0 >= 97 && $0 <= 102)
                }
            }
        XCTAssertEqual(embeddedIdentities.count, 1)
        let embeddedIdentity = try XCTUnwrap(embeddedIdentities.first)
        let expectedEmbedded = [
            "public enum PrimeEmbeddedBuildProvenance {",
            "    #if DEBUG",
            "        public static let buildConfiguration = \"debug\"",
            "    #else",
            "        public static let buildConfiguration = \"release\"",
            "    #endif",
            "",
            "    // This file is excluded only to avoid a self-referential digest. Runtime",
            "    // verification requires this exact canonical template and digest; every",
            "    // other admitted package, source, test, and architecture file is hashed.",
            "    public static let sourceIdentitySHA256 =",
            "        \"\(embeddedIdentity)\"",
            "}",
        ].joined(separator: "\n") + "\n"
        XCTAssertEqual(embedded, expectedEmbedded)

        let durableArtifacts = try XCTUnwrap(
            sources["PrimeDurableArtifacts.swift"])
        for required in [
            "public enum PrimeCanonicalJSON",
            "public enum PrimeSHA256",
            "public enum PrimeArtifactPurpose",
            "public struct PrimeArtifactBinding",
            "public struct PrimeVerifiedArtifact",
            "public final class PrimeArtifactRoot",
            "public func requirePrivateRootMode() throws",
            "public func requireEmpty() throws",
            "public func ensurePrivateDirectory(",
            "public func requireAbsent(",
            "public func bindExisting(",
            "public func publishCanonicalExclusively<",
            "public func verify(",
            "public func decodeVerified<Value: Codable>(",
        ] {
            XCTAssertTrue(
                durableArtifacts.contains(required),
                "PrimeCore validation closure lacks capability: \(required)")
        }

        for (name, anchor) in [
            ("PrimeEmbeddedBuildProvenance.swift", "public enum PrimeEmbeddedBuildProvenance"),
            ("PrimeFactorizedExecution.swift", "public struct PrimeFactorizedExecutionContract"),
            ("PrimeMLXRuntimeEnvironmentPolicy.swift", "public enum PrimeMLXRuntimeEnvironmentPolicy"),
            ("PrimeMLXRuntimeImageLayout.swift", "public enum PrimeMLXRuntimeImageLayout"),
            ("PrimeNative3BProfile.swift", "public enum PrimeNativeProfiles"),
            ("PrimePinnedMLXMetallib.swift", "public enum PrimePinnedMLXMetallib"),
            ("PrimeReleaseInstrumentationAdmissionPolicy.swift", "public enum PrimeReleaseInstrumentationAdmissionPolicy"),
            ("PrimeSwiftSourceProvenance.swift", "public enum PrimeSwiftSourceProvenance"),
        ] {
            XCTAssertTrue(
                try XCTUnwrap(sources[name]).contains(anchor),
                "PrimeCore validation dependency closure lacks anchor: \(anchor)")
        }

        if !manifest.contains(".package(") {
            let stagedInventory = try FileManager.default.contentsOfDirectory(
                at: primeCore,
                includingPropertiesForKeys: nil)
                .map(\.lastPathComponent)
                .sorted()
            XCTAssertEqual(stagedInventory, closure.map { $0.name })
        }
    }

    func testValidationCompositionReceiptIsPureExactAndNonAuthorizing()
        throws
    {
        let source = try swiftSource(
            relativePath:
                "Sources/PrimeLatinProposalValidationCompositionReceipt/" +
                    "PrimeLatinProposalValidationCompositionReceiptV1.swift")
        let imports = source.split(separator: "\n")
            .map(String.init)
            .filter { $0.hasPrefix("import ") }
        XCTAssertEqual(imports, ["import Foundation"])

        for required in [
            "public enum " +
                "PrimeLatinProposalValidationCompositionReceiptErrorV1",
            "case invalidReceipt(String)",
            "package enum " +
                "PrimeLatinProposalValidationCompositionReceiptContractV1",
            "package struct " +
                "PrimeLatinProposalValidationCompositionReceiptProjectionV1",
            "public struct " +
                "PrimeLatinProposalValidationCompositionReceiptV1",
            "public static let maximumByteCount: UInt64 = 65_536",
            "package static var exactFinal: Self",
            "projecting projection:",
            "public init(from decoder: Decoder) throws",
            "public func validateExactV1() throws",
            "package var projection:",
            "package static func relativePath(",
            "forSHA256 sha256: String",
            "ergentics_prime_latin_proposal_v3_validation_composition_" +
                "receipt_v1",
            "durable_content_addressed_canonical_projection_of_one_exact_" +
                "prime_",
            "current_liveness_proposal_admission_runtime_trial_selection_",
            "promotion_product_and_model_publication_authority_absent",
            "prime_latin_v3_validation_composition_content_addressed_" +
                "receipt_v1",
            "latin-validation-composition-receipts",
            "return receiptDirectory + \"/\" + sha256 + \".json\"",
        ] {
            XCTAssertTrue(
                source.contains(required),
                "missing pure receipt anchor: \(required)")
        }

        let trueClaims = try sourceSection(
            source,
            from: "    package static let sourceAuthorityTrueClaims = [",
            to: "    package static let sourceAuthorityFalseClaims = [")
        let falseClaims = try sourceSection(
            source,
            from: "    package static let sourceAuthorityFalseClaims = [",
            to: "    package static let receiptDirectory =")
        let expectedTrueClaims = [
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
        let expectedFalseClaims = [
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
        XCTAssertEqual(expectedTrueClaims.count, 24)
        XCTAssertEqual(expectedFalseClaims.count, 30)
        XCTAssertEqual(
            trueClaims.split(separator: "\n").filter {
                String($0).trimmingCharacters(in: .whitespaces)
                    .hasPrefix("\"")
            }.count,
            expectedTrueClaims.count)
        XCTAssertEqual(
            falseClaims.split(separator: "\n").filter {
                String($0).trimmingCharacters(in: .whitespaces)
                    .hasPrefix("\"")
            }.count,
            expectedFalseClaims.count)
        for claim in expectedTrueClaims {
            XCTAssertEqual(
                fixedOccurrenceCount("\"\(claim)\"", in: trueClaims),
                1,
                "receipt true claim is not exact: \(claim)")
        }
        for claim in expectedFalseClaims {
            XCTAssertEqual(
                fixedOccurrenceCount("\"\(claim)\"", in: falseClaims),
                1,
                "receipt false claim is not exact: \(claim)")
        }

        XCTAssertEqual(
            fixedOccurrenceCount("try validateExactV1()", in: source), 1)
        XCTAssertEqual(
            fixedOccurrenceCount(
                "try self.init(projecting: projection)", in: source),
            1)
        XCTAssertEqual(
            fixedOccurrenceCount(
                "PrimeLatinProposalValidationCompositionReceiptProjectionV1(",
                in: source),
            2)
        for forbidden in [
            "import PrimeCore",
            "import PrimeLatinProposalValidationComposition",
            "import PrimeLatinProposalValidationCompositionReceiptPublisher",
            "import Darwin",
            "import Glibc",
            "import CryptoKit",
            "import MLX",
            "MLXLLM",
            "LlamaModel",
            "PrimeArtifactRoot",
            "PrimeCanonicalJSON",
            "PrimeSHA256",
            "PrimeLatinProposalValidationCompositionCaptureV1",
            "PrimeLatinProposalAdmissionPolicy",
            "@main",
            "CommandLine",
            "Process(",
            "ProcessInfo.processInfo.environment",
            "FileManager",
            "FileHandle",
            "URLSession",
            "NWConnection",
            "socket(",
            "connect(",
            "O_CREAT",
            "O_WRONLY",
            "O_RDWR",
            "mkdirat(",
            "renameat",
            "unlinkat(",
            "removeItem(",
            "createDirectory(",
            "createFile(",
            ".write(to:",
            "func publish",
            "--disable-sandbox",
        ] {
            XCTAssertFalse(
                source.contains(forbidden),
                "pure receipt contains forbidden capability: \(forbidden)")
        }
    }

    func testValidationCompositionReceiptPublisherIsExactAndQuarantined()
        throws
    {
        let source = try swiftSource(
            relativePath:
                "Sources/" +
                    "PrimeLatinProposalValidationCompositionReceiptPublisher/" +
                    "PrimeLatinProposalValidationCompositionReceiptPublisherV1.swift")
        let imports = source.split(separator: "\n")
            .map(String.init)
            .filter { $0.hasPrefix("import ") }
        XCTAssertEqual(
            imports,
            [
                "import Foundation",
                "import PrimeCore",
                "import PrimeLatinProposalValidationComposition",
                "import PrimeLatinProposalValidationCompositionReceipt",
            ])

        for required in [
            "public enum " +
                "PrimeLatinProposalValidationCompositionReceiptPublisherErrorV1",
            "case invalidSourceObservation(String)",
            "case captureChanged",
            "case receiptTooLarge",
            "case publicationFailed",
            "case verificationFailed",
            "public struct " +
                "PrimeLatinProposalValidationCompositionReceiptPublication" +
                "AuthorityBoundaryV1",
            "public struct " +
                "PrimeLatinProposalValidationCompositionReceiptPublication" +
                "ObservationV1",
            "public enum " +
                "PrimeLatinProposalValidationCompositionReceiptPublisherV1",
            "public static func publish(",
            "capture: PrimeLatinProposalValidationCompositionCaptureV1",
            "artifactRoot: PrimeArtifactRoot",
            "static func publishForTesting(",
            "private static func publishUsingSingleEngine(",
            "ergentics_prime_latin_proposal_v3_validation_composition_",
            "receipt_publication_observation_v1",
            "prime_owned_descriptor_safe_exclusive_content_addressed_",
            "publication_of_one_canonical_validation_composition_",
            "receipt_only_non_authorizing",
            "prime_latin_v3_validation_composition_receipt_publication_v1",
            "abstain_durable_validation_composition_receipt_published_",
            "decoded_receipt_does_not_restore_live_validation_or_",
            "establish_proposal_admission_packet_trial_runtime_selection_",
            "promotion_product_or_publication_authority",
        ] {
            XCTAssertTrue(
                source.contains(required),
                "missing receipt-publisher anchor: \(required)")
        }

        let authority = try sourceSection(
            source,
            from: "public struct " +
                "PrimeLatinProposalValidationCompositionReceiptPublication" +
                "AuthorityBoundaryV1:",
            to: "public struct " +
                "PrimeLatinProposalValidationCompositionReceiptPublication" +
                "ObservationV1:")
        let publicationObservation = try sourceSection(
            source,
            from: "public struct " +
                "PrimeLatinProposalValidationCompositionReceiptPublication" +
                "ObservationV1:",
            to: "public enum " +
                "PrimeLatinProposalValidationCompositionReceiptPublisherV1")
        for (surface, section) in [
            ("authority", authority),
            ("observation", publicationObservation),
        ] {
            for forbidden in [
                "Codable",
                "Encodable",
                "Decodable",
                "public init",
            ] {
                XCTAssertFalse(
                    section.contains(forbidden),
                    "receipt-publication \(surface) exposes \(forbidden)")
            }
        }
        let authorityCompact = authority.filter { !$0.isWhitespace }
        let trueFields = [
            "validationCompositionCaptureAndRecaptureComplete",
            "validationCompositionAuthorityBoundaryExact",
            "exactReceiptProjectionComplete",
            "canonicalReceiptEncodingComplete",
            "canonicalReceiptRedecodeComplete",
            "receiptContentAddressBindingVerified",
            "privateArtifactRootModeVerified",
            "artifactRootEmptyAtAdmission",
            "artifactRootEmptyAtFinalPrepublicationMutationCheck",
            "exclusiveNoReplacePublicationComplete",
            "immutableSingleLinkReceiptArtifactVerified",
            "receiptFileDurabilitySyncComplete",
            "receiptDirectoryDurabilitySyncComplete",
            "durableValidationCompositionReceiptPublished",
            "primeDurableReceiptPublished",
        ]
        let falseFields = [
            "atomicCrossProcessSnapshotEstablished",
            "exclusiveArtifactRootOwnershipEstablished",
            "postPublicationSourceRecaptureComplete",
            "compilerCryptographicallyAuthenticated",
            "externalSourceToBinaryAttestationAvailable",
            "publisherIdentityCryptographicallyAuthenticated",
            "receiptCryptographicallySigned",
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
            "rawProducerRevalidationObservationPublished",
            "rawIndependentReplayObservationPublished",
            "currentLiveProducerWorkspaceRevalidationRestoredFromReceipt",
            "currentIndependentPrimeReplayRestoredFromReceipt",
            "runtimeDecoderImplementationAvailable",
            "runtimeDependencyClosureEstablished",
            "runtimeInitializationEstablished",
            "primeProposalPolicyEstablished",
            "proposalAdmissionEvaluationComplete",
            "proposalAdmissionGranted",
            "primeProposalPacketProduced",
            "primeTrialAuthorizationProduced",
            "primeDecisionReceiptProduced",
            "candidateSelectionAuthorized",
            "trialExecutionAuthorized",
            "furtherTrainingAuthorized",
            "promotionAuthorized",
            "productUseAuthorized",
            "publicationAuthorized",
            "proposalPairPublicationPerformedByThisPublisher",
            "publicNetworkPublicationPerformed",
        ]
        XCTAssertEqual(trueFields.count, 15)
        XCTAssertEqual(falseFields.count, 40)
        XCTAssertEqual(
            fixedOccurrenceCount(":Bool", in: authorityCompact), 55)
        for field in trueFields {
            XCTAssertTrue(
                authorityCompact.contains("publiclet\(field):Bool"),
                "receipt-publication authority lacks true field: \(field)")
            XCTAssertTrue(
                authorityCompact.contains("\(field)=true"),
                "receipt-publication completion is not true: \(field)")
        }
        for field in falseFields {
            XCTAssertTrue(
                authorityCompact.contains("publiclet\(field):Bool"),
                "receipt-publication authority lacks false field: \(field)")
            XCTAssertTrue(
                authorityCompact.contains("\(field)=false"),
                "receipt-publication ceiling is not false: \(field)")
        }

        XCTAssertEqual(
            fixedOccurrenceCount("public static func ", in: source), 1)
        XCTAssertEqual(fixedOccurrenceCount("public func ", in: source), 0)
        XCTAssertEqual(
            fixedOccurrenceCount("publishUsingSingleEngine(", in: source),
            3)
        XCTAssertEqual(
            fixedOccurrenceCount(
                "capture.recaptureAndValidateUnchanged()", in: source),
            1)
        for (capability, count) in [
            ("artifactRoot.requirePrivateRootMode()", 2),
            ("artifactRoot.requireEmpty()", 2),
            ("artifactRoot.ensurePrivateDirectory(", 1),
            ("artifactRoot.requireAbsent(", 1),
            ("artifactRoot.publishCanonicalExclusively(", 1),
            ("artifactRoot.bindExisting(", 1),
            ("artifactRoot.verify(", 1),
            ("artifactRoot.decodeVerified(", 1),
            ("PrimeCanonicalJSON.encode(", 2),
            ("PrimeSHA256.hexDigest(", 1),
        ] {
            XCTAssertEqual(
                fixedOccurrenceCount(capability, in: source),
                count,
                "receipt-publisher capability count changed: \(capability)")
        }
        for required in [
            "try .init(projecting: initialProjection)",
            "currentProjection == initialProjection",
            "persisted.projection == currentProjection",
            "persistedData == canonicalData",
            "verified.actualMode == 0o444",
        ] {
            XCTAssertTrue(
                source.contains(required),
                "receipt publisher lacks exact rebound: \(required)")
        }
        for forbidden in [
            "import PrimeLatinProposalPairCapture",
            "import PrimeLatinProposalGitObservation",
            "import PrimeLatinProposalProducerRevalidationObservation",
            "import PrimeLatinProposalIndependentReplay",
            "import Darwin",
            "import Glibc",
            "import CryptoKit",
            "import ErgenticsLLM",
            "import ErgenticsTokenizer",
            "import MLX",
            "MLXLLM",
            "LlamaModel",
            "PrimeLatinProposalAdmissionPolicy",
            "@main",
            "CommandLine",
            "Process(",
            "ProcessInfo.processInfo.environment",
            "FileManager",
            "FileHandle",
            "URLSession",
            "NWConnection",
            "socket(",
            "connect(",
            "O_CREAT",
            "O_WRONLY",
            "O_RDWR",
            "open(",
            "mkdirat(",
            "renameat",
            "unlinkat(",
            "removeItem(",
            "createDirectory(",
            "createFile(",
            ".write(to:",
            "PrimeLatinProposalValidationCompositionCaptureV1.capture(",
            "PrimeLatinTrialProposal",
            "PrimeLatinTrialAuthorization",
            "--disable-sandbox",
        ] {
            XCTAssertFalse(
                source.contains(forbidden),
                "receipt publisher contains forbidden capability: \(forbidden)")
        }

        let tests = try swiftSource(
            relativePath:
                "Tests/PrimeLatinProposalPairCaptureTests/" +
                    "PrimeLatinProposalValidationCompositionReceipt" +
                    "PublisherV1Tests.swift")
        let testImports = tests.split(separator: "\n")
            .map(String.init)
            .filter {
                $0.hasPrefix("import ") || $0.hasPrefix("@testable import ")
            }
        XCTAssertEqual(
            testImports,
            [
                "import Darwin",
                "import Foundation",
                "import XCTest",
                "@testable import PrimeCore",
                "@testable import " +
                    "PrimeLatinProposalValidationCompositionReceipt",
                "@testable import " +
                    "PrimeLatinProposalValidationCompositionReceiptPublisher",
            ])
        XCTAssertEqual(
            fixedOccurrenceCount("publishForTesting(", in: tests), 2)
        XCTAssertEqual(
            fixedOccurrenceCount(
                "FileManager.default.temporaryDirectory", in: tests),
            1)
        for forbidden in [
            "PrimeLatinProposalValidationCompositionCaptureV1",
            ".publish(",
            "Process(",
            "ProcessInfo.processInfo.environment",
            "URLSession",
            "NWConnection",
            "socket(",
            "connect(",
            "\"/usr/bin/git\"",
            "\"fetch\"",
            "\"push\"",
            "\"clone\"",
            "--disable-sandbox",
        ] {
            XCTAssertFalse(
                tests.contains(forbidden),
                "receipt-publisher tests contain live path: \(forbidden)")
        }
    }

    func testValidationCompositionReceiptPublisherProjectionIsExhaustiveAndNonOracle()
        throws
    {
        let publisherSource = try swiftSource(
            relativePath:
                "Sources/" +
                    "PrimeLatinProposalValidationCompositionReceiptPublisher/" +
                    "PrimeLatinProposalValidationCompositionReceiptPublisherV1.swift")
        let projection = try sourceSection(
            publisherSource,
            from: "    private static func projection(",
            to: "    private static func trueClaims(")
        let trueClaims = try sourceSection(
            publisherSource,
            from: "    private static func trueClaims(",
            to: "    private static func falseClaims(")
        let falseClaims = try sourceSection(
            publisherSource,
            from: "    private static func falseClaims(",
            to: "    private static func append(")
        let projectionCompact = projection.filter { !$0.isWhitespace }
        let trueClaimsCompact = trueClaims.filter { !$0.isWhitespace }
        let falseClaimsCompact = falseClaims.filter { !$0.isWhitespace }

        let receiptOwnedMappings = [
            "schema:" +
                "PrimeLatinProposalValidationCompositionReceiptContractV1" +
                ".schema",
            "outcome:" +
                "PrimeLatinProposalValidationCompositionReceiptContractV1" +
                ".outcome",
            "verificationScope:" +
                "PrimeLatinProposalValidationCompositionReceiptContractV1" +
                ".verificationScope",
            "receiptPolicyID:" +
                "PrimeLatinProposalValidationCompositionReceiptContractV1" +
                ".receiptPolicyID",
        ]
        XCTAssertEqual(receiptOwnedMappings.count, 4)
        for mapping in receiptOwnedMappings {
            XCTAssertEqual(
                fixedOccurrenceCount(mapping, in: projectionCompact),
                1,
                "receipt-owned projection mapping is not exact: \(mapping)")
        }

        let sourceEnvelopeMappings = [
            ("sourceObservationSchema", "observation.schema"),
            ("sourceObservationOutcome", "observation.outcome"),
            (
                "sourceObservationVerificationScope",
                "observation.verificationScope"
            ),
            (
                "sourceCompositionPolicyID",
                "observation.compositionPolicyID"
            ),
            ("sourceAuthorityDisposition", "authority.disposition"),
        ]
        XCTAssertEqual(sourceEnvelopeMappings.count, 5)
        for (receiptField, rawValue) in sourceEnvelopeMappings {
            let mapping = "\(receiptField):\(rawValue)"
            XCTAssertEqual(
                fixedOccurrenceCount(mapping, in: projectionCompact),
                1,
                "source-envelope projection mapping is not exact: \(mapping)")
            XCTAssertEqual(
                fixedOccurrenceCount(rawValue, in: projectionCompact),
                1,
                "source-envelope value is not consumed exactly once: \(rawValue)")
        }

        let rawMappings = [
            ("pairReceiptSHA256", "observation.pairReceiptSHA256"),
            ("pairReceiptByteCount", "observation.pairReceiptByteCount"),
            ("producerRepository", "observation.producerRepository"),
            ("producerCommit", "observation.producerCommit"),
            ("producerTree", "observation.producerTree"),
            (
                "candidateCatalogSHA256",
                "observation.candidateCatalogSHA256"
            ),
            (
                "candidateCatalogByteCount",
                "observation.candidateCatalogByteCount"
            ),
            (
                "experimentManifestSHA256",
                "observation.experimentManifestSHA256"
            ),
            (
                "experimentManifestByteCount",
                "observation.experimentManifestByteCount"
            ),
            (
                "candidateDeclarationSetSHA256",
                "observation.candidateDeclarationSetSHA256"
            ),
            (
                "candidateDeclarationSetByteCount",
                "observation.candidateDeclarationSetByteCount"
            ),
            ("tokenizerBundleSHA256", "observation.tokenizerBundleSHA256"),
            (
                "tokenizerBundleByteCount",
                "observation.tokenizerBundleByteCount"
            ),
            ("candidateIDs", "observation.candidateIDs"),
            (
                "candidateIdentitySHA256s",
                "observation.candidateIdentitySHA256s"
            ),
            (
                "declarationBundleSHA256s",
                "observation.declarationBundleSHA256s"
            ),
            ("inputBindingCount", "observation.inputBindingCount"),
            (
                "retainedOriginalInputByteCount",
                "observation.retainedOriginalInputByteCount"
            ),
            ("optimizerSteps", "observation.optimizerSteps"),
            ("trainingTokens", "observation.trainingTokens"),
            ("wallClockSeconds", "observation.wallClockSeconds"),
            ("outputNamespace", "observation.outputNamespace"),
            ("orderedTensorCount", "observation.orderedTensorCount"),
            (
                "uniqueParameterStorageCount",
                "observation.uniqueParameterStorageCount"
            ),
            ("totalParameterCount", "observation.totalParameterCount"),
        ]
        XCTAssertEqual(rawMappings.count, 25)
        for (receiptField, rawValue) in rawMappings {
            let mapping = "\(receiptField):\(rawValue)"
            XCTAssertEqual(
                fixedOccurrenceCount(mapping, in: projectionCompact),
                1,
                "raw receipt projection mapping is not exact: \(mapping)")
            XCTAssertEqual(
                fixedOccurrenceCount(rawValue, in: projectionCompact),
                1,
                "raw observation value is not consumed exactly once: \(rawValue)")
        }
        XCTAssertEqual(
            fixedOccurrenceCount("observation.", in: projectionCompact),
            30,
            "projection must consume authority plus 29 raw observation fields")
        XCTAssertEqual(
            fixedOccurrenceCount("authority.", in: projectionCompact), 1)
        XCTAssertEqual(
            fixedOccurrenceCount(
                "sourceAuthorityTrueClaims:trueClaims(from:authority)",
                in: projectionCompact),
            1)
        XCTAssertEqual(
            fixedOccurrenceCount(
                "sourceAuthorityFalseClaims:falseClaims(from:authority)",
                in: projectionCompact),
            1)
        XCTAssertEqual(
            fixedOccurrenceCount(
                "letauthority=observation.authority", in: projectionCompact),
            1)
        XCTAssertEqual(
            fixedOccurrenceCount(
                "PrimeLatinProposalValidationCompositionReceiptProjectionV1(",
                in: projectionCompact),
            1)

        XCTAssertFalse(projection.contains("\""))
        XCTAssertNil(
            projection.range(
                of:
                    #"(?<![A-Za-z0-9_])(?:0|[1-9][0-9_]*)(?![A-Za-z0-9_])"#,
                options: .regularExpression),
            "raw projection may not substitute a numeric golden constant")
        for forbidden in [
            ".exactFinal",
            "producerRevalidationObservation",
            "independentReplayObservation",
            "PrimeSHA256",
            "Ergentics/ergentics-llm",
            "models/latin-prospective",
        ] {
            XCTAssertFalse(
                projection.contains(forbidden),
                "raw projection contains an oracle/substitution: \(forbidden)")
        }

        let expectedTrueClaims = [
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
        let expectedFalseClaims = [
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
        XCTAssertEqual(expectedTrueClaims.count, 24)
        XCTAssertEqual(expectedFalseClaims.count, 30)
        XCTAssertEqual(Set(expectedTrueClaims).count, 24)
        XCTAssertEqual(Set(expectedFalseClaims).count, 30)

        let compositionSource = try swiftSource(
            relativePath:
                "Sources/PrimeLatinProposalValidationComposition/" +
                    "PrimeLatinProposalValidationCompositionV1.swift")
        let compositionAuthority = try sourceSection(
            compositionSource,
            from: "public struct " +
                "PrimeLatinProposalValidationCompositionAuthorityBoundaryV1:",
            to: "public struct " +
                "PrimeLatinProposalValidationCompositionObservationV1:")
        let compositionAuthorityCompact = compositionAuthority.filter {
            !$0.isWhitespace
        }
        XCTAssertEqual(
            fixedOccurrenceCount(":Bool", in: compositionAuthorityCompact),
            54)

        XCTAssertEqual(
            fixedOccurrenceCount("append(", in: trueClaimsCompact), 24)
        XCTAssertEqual(
            fixedOccurrenceCount("authority.", in: trueClaimsCompact), 24)
        XCTAssertEqual(
            fixedOccurrenceCount("to:&claims)", in: trueClaimsCompact), 24)
        XCTAssertEqual(fixedOccurrenceCount("\"", in: trueClaimsCompact), 48)
        XCTAssertEqual(
            fixedOccurrenceCount("returnclaims", in: trueClaimsCompact), 1)
        XCTAssertFalse(trueClaimsCompact.contains("!authority."))
        XCTAssertFalse(trueClaimsCompact.contains(".exactFinal"))
        XCTAssertFalse(trueClaimsCompact.contains("when:true"))
        XCTAssertFalse(trueClaimsCompact.contains("when:false"))
        for claim in expectedTrueClaims {
            let mapping =
                "append(\"\(claim)\",when:authority.\(claim),to:&claims)"
            XCTAssertEqual(
                fixedOccurrenceCount(mapping, in: trueClaimsCompact),
                1,
                "true authority-to-name mapping is not exact: \(claim)")
            XCTAssertEqual(
                fixedOccurrenceCount("\"\(claim)\"", in: trueClaimsCompact),
                1)
            XCTAssertEqual(
                fixedOccurrenceCount("authority.\(claim)", in: trueClaimsCompact),
                1)
            XCTAssertTrue(
                compositionAuthorityCompact.contains("publiclet\(claim):Bool"),
                "true mapped claim is not a composition authority field")
        }

        XCTAssertEqual(
            fixedOccurrenceCount("append(", in: falseClaimsCompact), 30)
        XCTAssertEqual(
            fixedOccurrenceCount("!authority.", in: falseClaimsCompact), 30)
        XCTAssertEqual(
            fixedOccurrenceCount("to:&claims)", in: falseClaimsCompact), 30)
        XCTAssertEqual(fixedOccurrenceCount("\"", in: falseClaimsCompact), 60)
        XCTAssertEqual(
            fixedOccurrenceCount("returnclaims", in: falseClaimsCompact), 1)
        XCTAssertFalse(falseClaimsCompact.contains("when:authority."))
        XCTAssertFalse(falseClaimsCompact.contains(".exactFinal"))
        XCTAssertFalse(falseClaimsCompact.contains("when:true"))
        XCTAssertFalse(falseClaimsCompact.contains("when:false"))
        for claim in expectedFalseClaims {
            let mapping =
                "append(\"\(claim)\",when:!authority.\(claim),to:&claims)"
            XCTAssertEqual(
                fixedOccurrenceCount(mapping, in: falseClaimsCompact),
                1,
                "false authority-to-name mapping is not exact: \(claim)")
            XCTAssertEqual(
                fixedOccurrenceCount("\"\(claim)\"", in: falseClaimsCompact),
                1)
            XCTAssertEqual(
                fixedOccurrenceCount("authority.\(claim)", in: falseClaimsCompact),
                1)
            XCTAssertTrue(
                compositionAuthorityCompact.contains("publiclet\(claim):Bool"),
                "false mapped claim is not a composition authority field")
        }
    }

    func testValidationCompositionRawProjectionAndSingleEngineAreExact()
        throws
    {
        let source = try swiftSource(
            relativePath:
                "Sources/PrimeLatinProposalValidationComposition/" +
                    "PrimeLatinProposalValidationCompositionV1.swift")
        let producerProjection = try sourceSection(
            source,
            from: "    private static func projectProducer(",
            to: "    private static func projectReplay(")
        let replayProjection = try sourceSection(
            source,
            from: "    private static func projectReplay(",
            to: "    private static func producerContractExact(")
        let producerContract = try sourceSection(
            source,
            from: "    private static func producerContractExact(",
            to: "    private static func replayContractExact(")
        let engine = try sourceSection(
            source,
            from: "enum PrimeLatinProposalValidationCompositionEngineV1 {",
            to: "public final class PrimeLatinProposalValidationCompositionCaptureV1")
        let producerCompact = producerProjection.filter { !$0.isWhitespace }
        let replayCompact = replayProjection.filter { !$0.isWhitespace }
        let producerContractCompact = producerContract.filter {
            !$0.isWhitespace
        }

        let sharedValueFields = [
            "pairReceiptSHA256",
            "producerRepository",
            "producerCommit",
            "producerTree",
            "candidateCatalogSHA256",
            "candidateCatalogByteCount",
            "experimentManifestSHA256",
            "experimentManifestByteCount",
            "candidateDeclarationSetSHA256",
            "candidateDeclarationSetByteCount",
            "tokenizerBundleSHA256",
            "tokenizerBundleByteCount",
            "candidateIDs",
            "candidateIdentitySHA256s",
            "declarationBundleSHA256s",
            "inputBindingCount",
            "optimizerSteps",
            "trainingTokens",
            "wallClockSeconds",
            "outputNamespace",
        ]
        XCTAssertEqual(sharedValueFields.count, 20)
        for field in sharedValueFields {
            XCTAssertTrue(
                producerCompact.contains("\(field):value.\(field)"),
                "producer projection does not raw-project \(field)")
            XCTAssertTrue(
                replayCompact.contains("\(field):value.\(field)"),
                "replay projection does not raw-project \(field)")
        }
        for mapping in [
            "kind:.producer",
            "requestLabRoot:request.labRoot.path",
            "requestProducerRepositoryRoot:request.producerRepositoryRoot.path",
            "childContractExact:producerContractExact(value)",
            "pairReceiptByteCount:expected.pairReceiptByteCount",
            "retainedOriginalInputByteCount:expected.retainedOriginalInputByteCount",
            "orderedTensorCount:expected.orderedTensorCount",
            "uniqueParameterStorageCount:expected.uniqueParameterStorageCount",
            "totalParameterCount:expected.totalParameterCount",
        ] {
            XCTAssertTrue(
                producerCompact.contains(mapping),
                "producer projection lacks exact mapping: \(mapping)")
        }
        for mapping in [
            "kind:.replay",
            "requestLabRoot:request.labRoot.path",
            "requestProducerRepositoryRoot:request.producerRepositoryRoot.path",
            "childContractExact:replayContractExact(value)",
            "pairReceiptByteCount:value.pairReceiptByteCount",
            "retainedOriginalInputByteCount:value.retainedOriginalInputByteCount",
            "orderedTensorCount:value.orderedTensorCount",
            "uniqueParameterStorageCount:value.uniqueParameterStorageCount",
            "totalParameterCount:value.totalParameterCount",
        ] {
            XCTAssertTrue(
                replayCompact.contains(mapping),
                "replay projection lacks exact mapping: \(mapping)")
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
                producerContract.contains("&& authority.\(field)"),
                "producer child contract omits true field: \(field)")
        }
        for field in [
            "compilerCryptographicallyAuthenticated",
            "externalSourceToBinaryAttestationAvailable",
            "originRemoteCryptographicallyAuthenticated",
            "ignoredWorkspaceBytesObserved",
            "durableInputSnapshotPublished",
            "durableGitObservationPublished",
            "durableRevalidationObservationPublished",
            "independentPrimeReplayComplete",
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
                producerContract.contains("&& !authority.\(field)"),
                "producer child contract omits false field: \(field)")
        }
        for required in [
            "ergentics_prime_latin_proposal_v3_producer_revalidation_observation_v1",
            "prime_built_exact_merged_revalidator_source_closure_and_observed_two_cross_bound_live_producer_processes_only_non_authorizing",
            "prime_latin_exact_source_direct_swiftc_build_v1",
            "prime_latin_producer_revalidation_fixed_fresh_process_v1",
            "abstain_producer_revalidation_observation_complete_requires_independent_prime_replay",
            "source.artifacts.count == 4",
            "build.compileCommandCount == 3",
            "build.processLaunchCount == 5",
            "build.governanceArtifactCount == 4",
            "build.compilerInputSourceCount == 3",
            "process.invocationCount == 2",
            "process.standardOutputByteCount == 8_434",
            "process.standardErrorByteCount == 0",
        ] {
            XCTAssertTrue(
                producerContract.contains(required),
                "producer child contract omits exact policy/count: \(required)")
        }
        XCTAssertEqual(
            fixedOccurrenceCount("\"/usr/bin/xcrun\"", in: source),
            1,
            "xcrun must appear only as the exact producer child observation")
        XCTAssertTrue(
            producerContractCompact.contains(
                "build.compilerLauncher.absolutePath==\"/usr/bin/xcrun\""),
            "producer child contract must bind the exact xcrun observation")
        let producerChildSource = try swiftSource(
            relativePath:
                "Sources/PrimeLatinProposalProducerRevalidationObservation/" +
                    "PrimeLatinProposalProducerRevalidationObservationV1.swift")
        let producerAuthority = try sourceSection(
            producerChildSource,
            from:
                "public struct " +
                    "PrimeLatinProposalProducerRevalidationAuthorityBoundaryV1:",
            to:
                "public struct " +
                    "PrimeLatinProposalProducerRevalidationObservationV1:")
        let producerAuthorityFields = boolPropertyNames(in: producerAuthority)
        XCTAssertEqual(producerAuthorityFields.count, 41)
        for field in producerAuthorityFields {
            XCTAssertEqual(
                fixedOccurrenceCount("authority.\(field)", in: producerContract),
                1,
                "producer child authority is not projected exactly once: \(field)")
        }

        XCTAssertFalse(
            engine.contains("PrimeLatinProposalProducerRevalidationObservationV1"))
        XCTAssertFalse(
            engine.contains("PrimeLatinProposalIndependentReplayObservationV1"))
        XCTAssertEqual(
            fixedOccurrenceCount(
                "static func validate(",
                in: source),
            1)
        XCTAssertEqual(
            fixedOccurrenceCount(
                "PrimeLatinProposalValidationCompositionEngineV1.validate(",
                in: source),
            2)
        XCTAssertEqual(
            fixedOccurrenceCount(
                "PrimeLatinProposalValidationCompositionBindingV1(",
                in: source),
            1)
        XCTAssertTrue(
            engine.contains("PrimeLatinProposalValidationCompositionBindingV1("))
    }

    func testValidationCompositionReplayContractAndSequenceAreExact()
        throws
    {
        let source = try swiftSource(
            relativePath:
                "Sources/PrimeLatinProposalValidationComposition/" +
                    "PrimeLatinProposalValidationCompositionV1.swift")
        let replayContract = try sourceSection(
            source,
            from: "    private static func replayContractExact(",
            to: "\n    }\n}")
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
                replayContract.contains("&& authority.\(field)"),
                "replay child contract omits true field: \(field)")
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
                replayContract.contains("&& !authority.\(field)"),
                "replay child contract omits false field: \(field)")
        }
        for required in [
            "ergentics_prime_latin_proposal_v3_independent_replay_observation_v1",
            "prime_owned_independent_typed_reconstruction_from_one_git_bound_retained_twenty_one_original_input_snapshot_and_byte_exact_catalog_experiment_cross_check_only_non_authorizing",
            "prime_latin_v3_retained_original_input_independent_reconstruction_v1",
            "abstain_independent_prime_structural_replay_complete_live_producer_revalidation_not_composed_and_runtime_decoder_initialization_evaluation_trial_and_publication_authority_absent",
        ] {
            XCTAssertTrue(
                replayContract.contains(required),
                "replay child contract omits exact policy: \(required)")
        }
        let replayChildSource = try swiftSource(
            relativePath:
                "Sources/PrimeLatinProposalIndependentReplay/" +
                    "PrimeLatinProposalIndependentReplayV1.swift")
        let replayAuthority = try sourceSection(
            replayChildSource,
            from:
                "public struct " +
                    "PrimeLatinProposalIndependentReplayAuthorityBoundaryV1:",
            to:
                "public struct " +
                    "PrimeLatinProposalIndependentReplayObservationV1:")
        let replayAuthorityFields = boolPropertyNames(in: replayAuthority)
        XCTAssertEqual(replayAuthorityFields.count, 49)
        for field in replayAuthorityFields {
            XCTAssertEqual(
                fixedOccurrenceCount("authority.\(field)", in: replayContract),
                1,
                "replay child authority is not projected exactly once: \(field)")
        }

        let sequence = try sourceSection(
            source,
            from: "    static func validateSequenceForTesting(",
            to: "    private static func validateLiveSequence(")
            .filter { !$0.isWhitespace }
        XCTAssertTrue(
            sequence.contains(
                "letreplayBefore=tryrecaptureReplay()" +
                    "letproducerCurrent=tryrecaptureProducer()" +
                    "letreplayAfter=tryrecaptureReplay()"))
        XCTAssertTrue(
            sequence.contains(
                "replayBefore==initialReplay," +
                    "producerCurrent==initialProducer," +
                    "replayAfter==initialReplay," +
                    "replayBefore==replayAfter"))
        XCTAssertTrue(
            sequence.contains(
                "PrimeLatinProposalValidationCompositionEngineV1.validate(" +
                    "producer:producerCurrent,replay:replayAfter)"))

        let liveSequence = try sourceSection(
            source,
            from: "    private static func validateLiveSequence(",
            to: "    private static func exactProjectionForTesting(")
            .filter { !$0.isWhitespace }
        XCTAssertTrue(liveSequence.contains("returntryvalidateSequenceForTesting("))
        XCTAssertTrue(
            liveSequence.contains(
                "initialProducer:projectProducer(initialProducer,request:request)"))
        XCTAssertTrue(
            liveSequence.contains(
                "initialReplay:projectReplay(initialReplay,request:request)"))
        XCTAssertTrue(
            liveSequence.contains(
                "recaptureReplay:{letcurrent=tryreplayCapture" +
                    ".recaptureAndValidateUnchanged()" +
                    "returnprojectReplay(current,request:request)}"))
        XCTAssertTrue(
            liveSequence.contains(
                "recaptureProducer:{letcurrent=tryproducerCapture" +
                    ".recaptureAndValidateUnchanged()" +
                    "returnprojectProducer(current,request:request)}"))
        XCTAssertEqual(
            fixedOccurrenceCount("validateSequenceForTesting(", in: source),
            2)
        XCTAssertEqual(fixedOccurrenceCount("projectProducer(", in: source), 3)
        XCTAssertEqual(fixedOccurrenceCount("projectReplay(", in: source), 3)
    }

    private func sourceSection(
        _ source: String,
        from start: String,
        to end: String
    ) throws -> String {
        let startRange = try XCTUnwrap(source.range(of: start))
        let endRange = try XCTUnwrap(
            source.range(
                of: end,
                range: startRange.upperBound..<source.endIndex))
        return String(source[startRange.lowerBound..<endRange.lowerBound])
    }

    private func fixedOccurrenceCount(_ needle: String, in source: String)
        -> Int
    {
        source.components(separatedBy: needle).count - 1
    }

    private func boolPropertyNames(in source: String) -> [String] {
        source.split(separator: "\n").compactMap { line in
            let compact = String(line.filter { !$0.isWhitespace })
            let prefix = "publiclet"
            let suffix = ":Bool"
            guard compact.hasPrefix(prefix), compact.hasSuffix(suffix) else {
                return nil
            }
            return String(compact.dropFirst(prefix.count).dropLast(suffix.count))
        }
    }

    private func sha256Hex(_ data: Data) -> String {
        SHA256.hash(data: data).map {
            String(format: "%02x", Int($0))
        }.joined()
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
