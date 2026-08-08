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
