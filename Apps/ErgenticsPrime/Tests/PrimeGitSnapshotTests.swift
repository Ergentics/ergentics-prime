import Foundation
import XCTest

final class PrimeGitSnapshotTests: XCTestCase {
    private let oid = String(repeating: "a", count: 40)

    private func fixture(_ changes: [String: Any] = [:]) -> [String: Any] {
        var value: [String: Any] = [
            "schema": PrimeGitSnapshot.schemaIdentifier,
            "repositoryPath": "/Users/example/Prime",
            "observedAt": "2026-08-30T18:00:00Z",
            "headMode": "branch", "branch": "main", "headOID": oid,
            "remotes": [], "consistency": "unchecked"
        ]
        changes.forEach { value[$0.key] = $0.value }
        return value
    }

    private func decode(_ changes: [String: Any] = [:]) throws -> PrimeGitSnapshot {
        try PrimeGitSnapshot.decode(JSONSerialization.data(withJSONObject: fixture(changes)))
    }

    func testMinimalSnapshotPreservesUnknownsRatherThanZero() throws {
        let snapshot = try decode()
        XCTAssertEqual(snapshot.headMode, .branch)
        XCTAssertEqual(snapshot.headOID, oid)
        XCTAssertNil(snapshot.changeCounts)
        XCTAssertNil(snapshot.upstream)
        XCTAssertTrue(snapshot.remotes.isEmpty)
        XCTAssertEqual(snapshot.consistency, .unchecked)
    }

    func testPartialCountsAndExplicitZeroRemainDistinct() throws {
        let snapshot = try decode(["changeCounts": ["staged": 0, "unstaged": NSNull()]])
        XCTAssertEqual(snapshot.changeCounts?.staged, 0)
        XCTAssertNil(snapshot.changeCounts?.unstaged)
        XCTAssertNil(snapshot.changeCounts?.untracked)
        XCTAssertEqual(try decode(["changeCounts": [:]]).changeCounts?.staged, nil)
    }

    func testDetachedAndUnbornModesHaveDistinctInvariants() throws {
        let detached = try decode(["headMode": "detached", "branch": NSNull()])
        XCTAssertEqual(detached.headMode, .detached)
        XCTAssertNil(detached.branch)
        let unborn = try decode(["headMode": "unborn", "headOID": NSNull()])
        XCTAssertEqual(unborn.headMode, .unborn)
        XCTAssertNil(unborn.headOID)
        XCTAssertThrowsError(try decode(["headMode": "detached"]))
        XCTAssertThrowsError(try decode(["headMode": "unborn"]))
        XCTAssertThrowsError(try decode(["headOID": NSNull()]))
        XCTAssertThrowsError(try decode(["branch": NSNull()]))
    }

    func testObjectIDFormatsAndNullSentinelAreValidated() throws {
        for length in [40, 64] {
            let objectID = String(repeating: "A", count: length)
            XCTAssertEqual(try decode(["headOID": objectID]).headOID, objectID)
        }
        for invalid in ["", String(repeating: "a", count: 39), String(repeating: "b", count: 65),
                        String(repeating: "g", count: 40), String(repeating: "0", count: 40)] {
            XCTAssertThrowsError(try decode(["headOID": invalid]))
        }
    }

    func testCachedUpstreamCountsRequireMatchedPairAndObjectIDs() throws {
        let complete: [String: Any] = ["ref": "refs/remotes/origin/main", "commitOID": String(repeating: "b", count: 40),
                                       "ahead": 0, "behind": 3]
        let snapshot = try decode(["upstream": complete])
        XCTAssertEqual(snapshot.upstream?.ahead, 0)
        XCTAssertEqual(snapshot.upstream?.behind, 3)
        let unknown = try decode(["upstream": ["ref": "refs/remotes/origin/main"]])
        XCTAssertNil(unknown.upstream?.commitOID)
        XCTAssertNil(unknown.upstream?.ahead)
        XCTAssertNil(unknown.upstream?.behind)
        XCTAssertThrowsError(try decode(["upstream": ["ref": "refs/remotes/origin/main", "commitOID": oid, "ahead": 1]]))
        XCTAssertThrowsError(try decode(["upstream": ["ref": "refs/remotes/origin/main", "ahead": 0, "behind": 0]]))
        XCTAssertThrowsError(try decode(["upstream": ["ref": "origin/main", "commitOID": oid]]))
        XCTAssertThrowsError(try decode(["upstream": ["ref": "refs/remotes/origin/main", "commitOID": String(repeating: "b", count: 64)]]))
        XCTAssertThrowsError(try decode(["headMode": "unborn", "headOID": NSNull(), "upstream": complete]))
    }

    func testCountBoundsRejectNegativeOverflowAndWrongTypes() throws {
        XCTAssertEqual(try decode(["changeCounts": ["untracked": PrimeGitSnapshot.maximumCount]])
            .changeCounts?.untracked, PrimeGitSnapshot.maximumCount)
        for invalid in [-1, PrimeGitSnapshot.maximumCount + 1, 0.5, "0", true] as [Any] {
            XCTAssertThrowsError(try decode(["changeCounts": ["staged": invalid]]))
        }
        XCTAssertThrowsError(try decode(["upstream": ["ref": "refs/remotes/origin/main", "commitOID": oid,
                                                      "ahead": -1, "behind": 0]]))
    }

    func testComparisonCannotContradictReportedObjectIdentity() throws {
        let equal: [String: Any] = ["ref": "refs/remotes/origin/main", "commitOID": oid.uppercased(), "ahead": 0, "behind": 0]
        XCTAssertEqual(try decode(["upstream": equal]).upstream?.behind, 0)
        XCTAssertThrowsError(try decode(["upstream": ["ref": "refs/remotes/origin/main", "commitOID": oid, "ahead": 1, "behind": 0]]))
        XCTAssertThrowsError(try decode(["upstream": ["ref": "refs/remotes/origin/main", "commitOID": String(repeating: "b", count: 40), "ahead": 0, "behind": 0]]))
        XCTAssertNil(try decode(["upstream": ["ref": "refs/remotes/origin/main", "commitOID": oid]]).upstream?.ahead)
    }

    func testRemoteDisplayDropsCredentialsQueryAndFragment() throws {
        let snapshot = try decode(["remotes": [
            ["name": "origin", "url": "https://user:secret@example.invalid/team/Prime.git?token=secret#secret"],
            ["name": "backup", "url": "ssh://git@example.invalid/team/Prime.git"],
            ["name": "offline"]
        ]])
        XCTAssertEqual(snapshot.remotes[0].url, "https://example.invalid/team/Prime.git")
        XCTAssertEqual(snapshot.remotes[1].url, "ssh://example.invalid/team/Prime.git")
        XCTAssertNil(snapshot.remotes[2].url)
        let encoded = try JSONEncoder().encode(snapshot)
        XCTAssertFalse(String(decoding: encoded, as: UTF8.self).contains("secret"))
        XCTAssertEqual(try PrimeGitSnapshot.decode(encoded), snapshot)
    }

    func testUnsupportedRemoteURLsAndUnsafeNamesReject() throws {
        for invalid in ["javascript:alert(1)", "git@example.invalid:Prime.git", "https:///repo", "", "https://example.invalid/a\n"] {
            XCTAssertThrowsError(try decode(["remotes": [["name": "origin", "url": invalid]]]))
        }
        for name in ["", ".", "..", "remote/name", "bad name", String(repeating: "x", count: 129)] {
            XCTAssertThrowsError(try decode(["remotes": [["name": name]]]))
        }
        XCTAssertEqual(try decode(["remotes": [["name": "local", "url": "file:///Users/example/Prime"]]])
            .remotes.first?.url, "file:///Users/example/Prime")
    }

    func testRemoteArrayIsBoundedAndNamesUnique() throws {
        XCTAssertEqual(try decode(["remotes": (0..<32).map { ["name": "remote\($0)"] }]).remotes.count, 32)
        XCTAssertThrowsError(try decode(["remotes": (0..<33).map { ["name": "remote\($0)"] }]))
        XCTAssertThrowsError(try decode(["remotes": [["name": "origin"], ["name": "origin"]]]))
    }

    func testImportedTimestampIsNotSilentlyRefreshedOrDeclaredFresh() throws {
        let old = try decode(["observedAt": "2001-01-01T00:00:00Z", "consistency": "stable"])
        XCTAssertEqual(old.observedAt, "2001-01-01T00:00:00Z")
        XCTAssertEqual(old.consistency, .stable)
        XCTAssertFalse(old.isChanged)
        let changed = try decode(["observedAt": "2026-08-30T11:00:00.125-07:00", "consistency": "changed"])
        XCTAssertTrue(changed.isChanged)
        XCTAssertEqual(changed.observedDate.timeIntervalSince(try decode().observedDate), 0.125, accuracy: 0.00001)
    }

    func testMalformedOrAmbiguousTimestampsReject() throws {
        for invalid in ["2026-08-30", "2026-08-30T18:00:00", "yesterday", "2026-02-30T00:00:00Z",
                        "2026-08-30T24:00:00Z", "2026-08-30T00:60:00Z", "2026-08-30T00:00:60Z"] {
            XCTAssertThrowsError(try decode(["observedAt": invalid]))
        }
    }

    func testPathAndReferenceLabelsRejectControlsAndDotTraversal() throws {
        for path in ["relative/Prime", "/", "/repo/../Prime", "/repo/./Prime", "/repo//Prime", "/repo/Prime/", "/repo/\u{0}Prime"] {
            XCTAssertThrowsError(try decode(["repositoryPath": path]))
        }
        for branch in ["", "..", "topic..work", ".hidden", "topic.lock", "topic//work", "topic@{1}", "bad branch", "topic\\work", "-main"] {
            XCTAssertThrowsError(try decode(["branch": branch]))
        }
        XCTAssertEqual(try decode(["branch": "feature/measurements"]).branch, "feature/measurements")
    }

    func testWrongSchemaUnknownFieldsAndUnknownEnumsReject() throws {
        XCTAssertThrowsError(try decode(["schema": "com.ergentics.provenance.prime-git.snapshot.v2"]))
        XCTAssertThrowsError(try decode(["verified": true]))
        XCTAssertThrowsError(try decode(["headMode": "unknown"]))
        XCTAssertThrowsError(try decode(["consistency": "verified"]))
        XCTAssertThrowsError(try decode(["changeCounts": ["clean": true]]))
        XCTAssertThrowsError(try decode(["remotes": [["name": "origin", "token": "secret"]]]))
    }

    func testMalformedTrailingDuplicateAndExcessiveNestingJSONReject() throws {
        let valid = try JSONSerialization.data(withJSONObject: fixture())
        XCTAssertThrowsError(try PrimeGitSnapshot.decode(valid + Data("{}".utf8)))
        XCTAssertThrowsError(try PrimeGitSnapshot.decode(Data(valid.dropLast())))
        XCTAssertThrowsError(try PrimeGitSnapshot.decode(Data([0xff])))
        let text = String(decoding: valid, as: UTF8.self)
        let duplicate = "{\"consistency\":\"stable\"," + String(text.dropFirst())
        XCTAssertThrowsError(try PrimeGitSnapshot.decode(Data(duplicate.utf8)))
        let escapedDuplicate = "{\"consisten\\u0063y\":\"stable\"," + String(text.dropFirst())
        XCTAssertThrowsError(try PrimeGitSnapshot.decode(Data(escapedDuplicate.utf8)))
        let deep = String(repeating: "[", count: 17) + "0" + String(repeating: "]", count: 17)
        XCTAssertThrowsError(try PrimeGitSnapshot.decode(Data(deep.utf8)))
    }

    func testJSONByteLimitAndCodableRoundTrip() throws {
        XCTAssertThrowsError(try PrimeGitSnapshot.decode(Data()))
        XCTAssertThrowsError(try PrimeGitSnapshot.decode(Data(repeating: 32, count: PrimeGitSnapshot.maximumJSONBytes + 1)))
        let snapshot = try decode(["changeCounts": ["staged": 1, "unstaged": 2, "untracked": 3], "consistency": "changed"])
        XCTAssertEqual(try PrimeGitSnapshot.decode(JSONEncoder().encode(snapshot)), snapshot)
    }
}
