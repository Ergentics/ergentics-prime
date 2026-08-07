import Foundation
import XCTest
@testable import PrimeLatinLLMAuthority

final class PrimeLatinLLMAuthorityTests: XCTestCase {
    func testCanonicalProposalRoundTripsAndBindsMaterialDigest() throws {
        let packet = try fixturePacket()
        let data = try PrimeLatinLLMAuthority.canonicalData(packet)
        let decoded = try PrimeLatinLLMAuthority
            .decodeCanonicalProposalPacket(data)

        XCTAssertEqual(decoded, packet)
        XCTAssertEqual(
            packet.materialSHA256,
            PrimeLatinLLMAuthority.sha256(
                try PrimeLatinLLMAuthority.canonicalData(packet.material)))
    }

    func testProposalRejectsAlternateJSONAndDigestMutation() throws {
        let packet = try fixturePacket()
        let canonical = try PrimeLatinLLMAuthority.canonicalData(packet)
        var alternate = Data(" \n".utf8)
        alternate.append(canonical)
        XCTAssertThrowsError(
            try PrimeLatinLLMAuthority.decodeCanonicalProposalPacket(alternate)
        ) { error in
            XCTAssertEqual(
                error as? PrimeLatinLLMAuthorityError,
                .noncanonicalJSON)
        }

        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical) as? [String: Any])
        var mutated = object
        mutated["materialSHA256"] = String(repeating: "f", count: 64)
        let mutatedData = try JSONSerialization.data(
            withJSONObject: mutated,
            options: [.sortedKeys, .withoutEscapingSlashes])
        XCTAssertThrowsError(
            try PrimeLatinLLMAuthority.decodeCanonicalProposalPacket(mutatedData)
        ) { error in
            XCTAssertEqual(
                error as? PrimeLatinLLMAuthorityError,
                .packetDigestMismatch)
        }
    }

    func testProposalRequiresExactSortedArtifactAndCandidateSets() throws {
        let fixture = try fixtureParts()
        XCTAssertThrowsError(
            try PrimeLatinTrialProposalMaterial(
                llmSource: fixture.source,
                artifacts: Array(fixture.artifacts.reversed()),
                candidates: fixture.candidates,
                trialBudget: fixture.budget,
                evaluationDataStatus: .prospectiveUnobserved,
                outputNamespace: fixture.outputNamespace)
        ) { error in
            XCTAssertEqual(
                error as? PrimeLatinLLMAuthorityError,
                .invalidArtifactSet)
        }

        let unsorted = [
            try candidate("candidate_b", digestByte: "b"),
            try candidate("candidate_a", digestByte: "a"),
        ]
        XCTAssertThrowsError(
            try PrimeLatinTrialProposalMaterial(
                llmSource: fixture.source,
                artifacts: fixture.artifacts,
                candidates: unsorted,
                trialBudget: fixture.budget,
                evaluationDataStatus: .prospectiveUnobserved,
                outputNamespace: fixture.outputNamespace)
        ) { error in
            XCTAssertEqual(
                error as? PrimeLatinLLMAuthorityError,
                .invalidCandidateSet)
        }
    }

    func testHistoricalNamespaceAndLlamaContextAreRefused() throws {
        let fixture = try fixtureParts()
        XCTAssertThrowsError(
            try PrimeLatinTrialProposalMaterial(
                llmSource: fixture.source,
                artifacts: fixture.artifacts,
                candidates: fixture.candidates,
                trialBudget: fixture.budget,
                evaluationDataStatus: .prospectiveUnobserved,
                outputNamespace: "models/ergentics_latin_primary_v1")
        ) { error in
            XCTAssertEqual(
                error as? PrimeLatinLLMAuthorityError,
                .historicalOutputNamespace)
        }

        XCTAssertThrowsError(
            try PrimeLatinCandidateReference(
                candidateID: "latin_llama_candidate",
                declarationSHA256: String(repeating: "a", count: 64),
                sourceAttribution: "ergentics_research")
        ) { error in
            guard let authorityError =
                error as? PrimeLatinLLMAuthorityError,
                  case .forbiddenDependencyContext = authorityError
            else {
                return XCTFail("unexpected error: \(error)")
            }
        }
    }

    func testFoundationAuthorizationCanOnlyAbstain() throws {
        let packet = try fixturePacket()
        let receipt = try PrimeLatinLLMAuthority
            .foundationAuthorization(for: packet)

        XCTAssertEqual(receipt.disposition, .abstain)
        XCTAssertEqual(
            receipt.reasons,
            [.primeSelectionPolicyNotInstalled])
        XCTAssertFalse(receipt.trialExecutionAuthorized)
        XCTAssertFalse(receipt.furtherTrainingAuthorized)
        XCTAssertFalse(receipt.promotionAuthorized)
        XCTAssertFalse(receipt.productUseAuthorized)
        XCTAssertEqual(
            receipt.proposalMaterialSHA256,
            packet.materialSHA256)
    }

    func testAuthorizationReceiptRejectsForgedAuthorityAndAlternateBytes() throws {
        let receipt = try PrimeLatinLLMAuthority.foundationAuthorization(
            for: fixturePacket())
        let canonical = try PrimeLatinLLMAuthority.canonicalData(receipt)
        XCTAssertEqual(
            try PrimeLatinLLMAuthority
                .decodeCanonicalFoundationAuthorizationReceipt(canonical),
            receipt)

        var alternate = Data(" \n".utf8)
        alternate.append(canonical)
        XCTAssertThrowsError(
            try PrimeLatinLLMAuthority
                .decodeCanonicalFoundationAuthorizationReceipt(alternate)
        ) { error in
            XCTAssertEqual(
                error as? PrimeLatinLLMAuthorityError,
                .noncanonicalJSON)
        }

        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical) as? [String: Any])
        for key in [
            "trialExecutionAuthorized",
            "furtherTrainingAuthorized",
            "promotionAuthorized",
            "productUseAuthorized",
        ] {
            var forged = object
            forged[key] = true
            let data = try JSONSerialization.data(
                withJSONObject: forged,
                options: [.sortedKeys, .withoutEscapingSlashes])
            XCTAssertThrowsError(
                try PrimeLatinLLMAuthority
                    .decodeCanonicalFoundationAuthorizationReceipt(data)
            ) { error in
                XCTAssertEqual(
                    error as? PrimeLatinLLMAuthorityError,
                    .invalidAuthorizationReceipt)
            }
        }
    }

    func testAuthorityRecordsDoNotExposeUncheckedDecodableConformance() throws {
        let sourceURL = try packageRoot()
            .appendingPathComponent(
                "Sources/PrimeLatinLLMAuthority/PrimeLatinLLMAuthority.swift")
        let source = try String(contentsOf: sourceURL, encoding: .utf8)
        for declaration in [
            "public struct PrimeLatinTrialProposalPacket:\n    Encodable,",
            "public struct PrimeLatinTrialAuthorizationReceipt:\n    Encodable,",
        ] {
            XCTAssertTrue(source.contains(declaration))
        }
        XCTAssertFalse(
            source.contains(
                "public struct PrimeLatinTrialProposalPacket:\n    Codable,"))
        XCTAssertFalse(
            source.contains(
                "public struct PrimeLatinTrialAuthorizationReceipt:\n    Codable,"))
    }

    func testTargetHasNoPackageOrPrimeCoreDependency() throws {
        let packageURL = try packageRoot()
            .appendingPathComponent("Package.swift")
        let package = try String(contentsOf: packageURL, encoding: .utf8)
        let marker =
            ".target(\n            name: \"PrimeLatinLLMAuthority\"\n        )"
        XCTAssertTrue(package.contains(marker))

        let sourceURL = try packageRoot()
            .appendingPathComponent("Sources/PrimeLatinLLMAuthority")
        let sourceNames = try FileManager.default
            .contentsOfDirectory(atPath: sourceURL.path)
        XCTAssertEqual(sourceNames, ["PrimeLatinLLMAuthority.swift"])
        let source = try String(
            contentsOf: sourceURL.appendingPathComponent(sourceNames[0]),
            encoding: .utf8)
        for forbidden in [
            "import PrimeCore",
            "import MLX",
            "import MLXNN",
            "import MLXLLM",
        ] {
            XCTAssertFalse(source.contains(forbidden))
        }
    }

    private func fixturePacket() throws -> PrimeLatinTrialProposalPacket {
        let fixture = try fixtureParts()
        let material = try PrimeLatinTrialProposalMaterial(
            llmSource: fixture.source,
            artifacts: fixture.artifacts,
            candidates: fixture.candidates,
            trialBudget: fixture.budget,
            evaluationDataStatus: .prospectiveUnobserved,
            outputNamespace: fixture.outputNamespace)
        return try PrimeLatinLLMAuthority.makeProposalPacket(material: material)
    }

    private func fixtureParts() throws -> (
        source: PrimeLatinGitSourceBinding,
        artifacts: [PrimeLatinArtifactBinding],
        candidates: [PrimeLatinCandidateReference],
        budget: PrimeLatinTrialBudget,
        outputNamespace: String
    ) {
        let source = try PrimeLatinGitSourceBinding(
            repository: "Ergentics/ergentics-llm",
            commit: String(repeating: "a", count: 40),
            tree: String(repeating: "b", count: 40))
        let artifacts = try PrimeLatinArtifactRole.allCases
            .sorted { $0.rawValue < $1.rawValue }
            .enumerated()
            .map { index, role in
                try PrimeLatinArtifactBinding(
                    role: role,
                    scope: role == .dependencyLock
                        ? .ergenticsLLMRepository
                        : .ergenticsMLXLab,
                    relativePath: "latin/\(role.rawValue).json",
                    sha256: String(
                        repeating: String(format: "%x", index + 1),
                        count: 64),
                    byteCount: UInt64(index + 1))
            }
        return (
            source,
            artifacts,
            [try candidate("candidate_a", digestByte: "e")],
            try PrimeLatinTrialBudget(
                optimizerSteps: 1,
                trainingTokens: 128,
                wallClockSeconds: 60),
            "models/ergentics_latin_trial_fixture_v2")
    }

    private func candidate(
        _ id: String,
        digestByte: Character
    ) throws -> PrimeLatinCandidateReference {
        try PrimeLatinCandidateReference(
            candidateID: id,
            declarationSHA256: String(repeating: digestByte, count: 64),
            sourceAttribution: "ergentics_research")
    }

    private func packageRoot() throws -> URL {
        if let repositoryRoot = ProcessInfo.processInfo.environment[
            "PRIME_REPOSITORY_ROOT"
        ] {
            return URL(fileURLWithPath: repositoryRoot, isDirectory: true)
                .standardizedFileURL
        }
        var url = URL(fileURLWithPath: #filePath)
        for _ in 0..<3 {
            url.deleteLastPathComponent()
        }
        guard FileManager.default.fileExists(
            atPath: url.appendingPathComponent("Package.swift").path)
        else {
            throw CocoaError(.fileNoSuchFile)
        }
        return url
    }
}
