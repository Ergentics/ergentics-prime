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
            "primeProposalPacketProduced = true",
            "primeTrialAuthorizationProduced = true",
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
}
