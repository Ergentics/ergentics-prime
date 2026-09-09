import Foundation
import CryptoKit
import XCTest

final class ManagedWorkspaceTests: XCTestCase {
    private let headOID = String(repeating: "a", count: 40)
    private let upstreamOID = String(repeating: "b", count: 40)

    private func snapshotData(consistency: String = "unchecked",
                              includeOptionalValues: Bool = true) throws -> Data {
        var value: [String: Any] = [
            "schema": PrimeGitSnapshot.schemaIdentifier,
            "repositoryPath": "/Users/example/Prime",
            "observedAt": "2026-08-30T18:00:00Z",
            "headMode": "branch",
            "branch": "main",
            "headOID": headOID,
            "remotes": [],
            "consistency": consistency
        ]
        if includeOptionalValues {
            value["changeCounts"] = ["staged": 0, "unstaged": NSNull(), "untracked": 3]
            value["remotes"] = [[
                "name": "origin",
                "url": "https://user:secret@example.invalid/team/Prime.git?token=secret#secret"
            ]]
            value["upstream"] = [
                "ref": "refs/remotes/origin/main",
                "commitOID": upstreamOID,
                "ahead": 2,
                "behind": 1
            ]
        }
        return try JSONSerialization.data(withJSONObject: value)
    }

    func testProductRegistryContainsOnlyPrimeInExplicitOrder() throws {
        XCTAssertEqual(ManagedWorkspaceRegistry.product.count, 1)
        let prime = try XCTUnwrap(ManagedWorkspaceRegistry.product.definition(for: .prime))
        XCTAssertEqual(prime.id, .prime)
        XCTAssertEqual(prime.ordinal, 1)
        XCTAssertEqual(prime.displayName, "Prime")
        XCTAssertEqual(prime.kind, .git)
        XCTAssertEqual(prime.selectionPolicy, .userSelectedReadOnly)
        XCTAssertEqual(ManagedWorkspaceRegistry.product.definition(for: .prime), prime)
    }

    func testRegistryLookupRequiresAnExplicitRegisteredIdentifier() throws {
        let unregistered = try XCTUnwrap(
            ManagedWorkspaceID(rawValue: "unregistered-test-workspace")
        )
        XCTAssertNil(ManagedWorkspaceRegistry.product.definition(for: unregistered))
        XCTAssertThrowsError(try ManagedWorkspaceRegistry.product.require(unregistered)) { error in
            XCTAssertEqual(error as? ManagedWorkspaceRegistryError, .unknownWorkspace)
        }
    }

    func testWorkspaceIdentifiersAreBoundedProductLocalLabels() {
        for invalid in [
            "", "Prime", "-prime", "prime-", "prime_workspace", "prime/workspace",
            String(repeating: "p", count: ManagedWorkspaceID.maximumUTF8Bytes + 1)
        ] {
            XCTAssertNil(ManagedWorkspaceID(rawValue: invalid), invalid)
        }
        XCTAssertEqual(ManagedWorkspaceID(rawValue: "prime.git-2")?.rawValue, "prime.git-2")
    }

    func testRegistryRejectsDuplicateAndUnorderedDefinitions() throws {
        let secondID = try XCTUnwrap(ManagedWorkspaceID(rawValue: "second"))
        let first = try ManagedWorkspaceDefinition(
            id: .prime, ordinal: 1, displayName: "Prime", kind: .git,
            selectionPolicy: .userSelectedReadOnly
        )
        let duplicateID = try ManagedWorkspaceDefinition(
            id: .prime, ordinal: 2, displayName: "Prime duplicate", kind: .git,
            selectionPolicy: .userSelectedReadOnly
        )
        let duplicateOrdinal = try ManagedWorkspaceDefinition(
            id: secondID, ordinal: 1, displayName: "Second", kind: .git,
            selectionPolicy: .userSelectedReadOnly
        )
        let preceding = try ManagedWorkspaceDefinition(
            id: secondID, ordinal: 2, displayName: "Second", kind: .git,
            selectionPolicy: .userSelectedReadOnly
        )

        XCTAssertThrowsError(try ManagedWorkspaceRegistry(validating: [first, duplicateID])) {
            XCTAssertEqual($0 as? ManagedWorkspaceRegistryError, .duplicateID)
        }
        XCTAssertThrowsError(try ManagedWorkspaceRegistry(validating: [first, duplicateOrdinal])) {
            XCTAssertEqual($0 as? ManagedWorkspaceRegistryError, .duplicateOrdinal)
        }
        XCTAssertThrowsError(try ManagedWorkspaceRegistry(validating: [preceding, first])) {
            XCTAssertEqual($0 as? ManagedWorkspaceRegistryError, .unorderedOrdinal)
        }
    }

    func testDefinitionRejectsInvalidOrdinalAndDisplayName() {
        XCTAssertThrowsError(try ManagedWorkspaceDefinition(
            id: .prime, ordinal: 0, displayName: "Prime", kind: .git,
            selectionPolicy: .userSelectedReadOnly
        )) {
            XCTAssertEqual($0 as? ManagedWorkspaceRegistryError, .invalidOrdinal)
        }
        for name in [
            "", " Prime", "Prime\n",
            "Cafe\u{301}", "Prime\u{200d}Workspace",
            String(repeating: "p", count: ManagedWorkspaceDefinition.maximumDisplayNameUTF8Bytes + 1)
        ] {
            XCTAssertThrowsError(try ManagedWorkspaceDefinition(
                id: .prime, ordinal: 1, displayName: name, kind: .git,
                selectionPolicy: .userSelectedReadOnly
            ), name) {
                XCTAssertEqual($0 as? ManagedWorkspaceRegistryError, .invalidDisplayName)
            }
        }
    }

    func testPrimeParserMapsImportedSnapshotWithoutAuthorityPromotion() throws {
        let observation = try ManagedWorkspaceObservationParser.primeSnapshot(snapshotData())

        XCTAssertEqual(observation.workspaceID, .prime)
        XCTAssertEqual(observation.workspaceKind, .git)
        XCTAssertEqual(observation.sourceSchema, PrimeGitSnapshot.schemaIdentifier)
        XCTAssertEqual(observation.sourceDisposition, .importedSnapshot)
        XCTAssertEqual(observation.sourceProvenance.parserID,
                       ManagedWorkspaceObservation.primeParserID)
        XCTAssertEqual(observation.importedPathLabel, "/Users/example/Prime")
        XCTAssertEqual(observation.observedAt, "2026-08-30T18:00:00Z")
        XCTAssertEqual(observation.producerConsistencyClaim, .unchecked)

        XCTAssertEqual(observation.git.headMode, .branch)
        XCTAssertEqual(observation.git.branch, "main")
        XCTAssertEqual(observation.git.headOID, headOID)
        XCTAssertEqual(observation.git.changeCounts?.staged, 0)
        XCTAssertNil(observation.git.changeCounts?.unstaged)
        XCTAssertEqual(observation.git.changeCounts?.untracked, 3)
        XCTAssertEqual(observation.git.remotes.count, 1)
        XCTAssertEqual(observation.git.remotes.first?.name, "origin")
        XCTAssertEqual(observation.git.remotes.first?.url,
                       "https://example.invalid/team/Prime.git")
        XCTAssertEqual(observation.git.upstream?.ref, "refs/remotes/origin/main")
        XCTAssertEqual(observation.git.upstream?.commitOID, upstreamOID)
        XCTAssertEqual(observation.git.upstream?.ahead, 2)
        XCTAssertEqual(observation.git.upstream?.behind, 1)
    }

    func testSourceProvenanceJoinsExactImportedBytesWithoutPromotingTruth() throws {
        let compact = try snapshotData(includeOptionalValues: false)
        let object = try JSONSerialization.jsonObject(with: compact)
        let pretty = try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys])
        XCTAssertNotEqual(compact, pretty)

        let first = try ManagedWorkspaceObservationParser.primeSnapshot(compact)
        let second = try ManagedWorkspaceObservationParser.primeSnapshot(pretty)
        XCTAssertEqual(first.git, second.git)
        XCTAssertEqual(first.producerConsistencyClaim, second.producerConsistencyClaim)
        XCTAssertEqual(first.sourceProvenance.byteCount, compact.count)
        XCTAssertEqual(second.sourceProvenance.byteCount, pretty.count)
        XCTAssertEqual(first.sourceProvenance.sha256,
                       SHA256.hash(data: compact).map { String(format: "%02x", $0) }.joined())
        XCTAssertEqual(second.sourceProvenance.sha256,
                       SHA256.hash(data: pretty).map { String(format: "%02x", $0) }.joined())
        XCTAssertNotEqual(first.sourceProvenance.sha256, second.sourceProvenance.sha256)
    }

    func testPrimeParserPreservesUnknownOptionalValues() throws {
        let observation = try ManagedWorkspaceObservationParser.primeSnapshot(
            snapshotData(includeOptionalValues: false)
        )
        XCTAssertNil(observation.git.changeCounts)
        XCTAssertTrue(observation.git.remotes.isEmpty)
        XCTAssertNil(observation.git.upstream)
    }

    func testProducerConsistencyNeverBecomesVerifiedConsistency() throws {
        let cases: [(String, ManagedWorkspaceObservation.ProducerConsistencyClaim)] = [
            ("unchecked", .unchecked),
            ("stable", .producerReportedStable),
            ("changed", .producerReportedChanged)
        ]
        for (source, expected) in cases {
            let observation = try ManagedWorkspaceObservationParser.primeSnapshot(
                snapshotData(consistency: source, includeOptionalValues: false)
            )
            XCTAssertEqual(observation.producerConsistencyClaim, expected, source)
        }
    }

    func testPrimeParserRetainsStrictSnapshotValidation() throws {
        var wrongSchema = try XCTUnwrap(
            JSONSerialization.jsonObject(with: snapshotData()) as? [String: Any]
        )
        wrongSchema["schema"] = "com.ergentics.provenance.prime-git.snapshot.v2"
        XCTAssertThrowsError(try ManagedWorkspaceObservationParser.primeSnapshot(
            JSONSerialization.data(withJSONObject: wrongSchema)
        ))

        var unknownField = try XCTUnwrap(
            JSONSerialization.jsonObject(with: snapshotData()) as? [String: Any]
        )
        unknownField["verified"] = true
        XCTAssertThrowsError(try ManagedWorkspaceObservationParser.primeSnapshot(
            JSONSerialization.data(withJSONObject: unknownField)
        ))

        XCTAssertThrowsError(try ManagedWorkspaceObservationParser.primeSnapshot(Data()))
        XCTAssertThrowsError(try ManagedWorkspaceObservationParser.primeSnapshot(
            Data(repeating: 32, count: PrimeGitSnapshot.maximumJSONBytes + 1)
        ))
    }
}
