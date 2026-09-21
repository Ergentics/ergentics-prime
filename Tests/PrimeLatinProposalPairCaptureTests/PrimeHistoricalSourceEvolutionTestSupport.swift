// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary
import Foundation
import CryptoKit
import XCTest

/// Test-only byte evolution. These values neither change a frozen contract
/// nor authorize a source root. Historical assertions receive reconstructed
/// historical bytes only after exact current bytes and both directions join.
/// Current import, target and capability checks continue reading live bytes.
enum PrimeHistoricalSourceEvolutionTestSupport {
    private struct Edit {
        let historicalOffset: Int
        let currentOffset: Int
        let removedBase64: String
        let insertedBase64: String
    }
    private struct Witness {
        let path: String
        let historicalByteCount: UInt64
        let historicalSHA256: String
        let currentByteCount: UInt64
        let currentSHA256: String
        let edits: [Edit]
    }
    private enum Rejection: Error { case sourceEvolution }
    private static func digest(_ data: Data) -> String { SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined() }

    static func historicalData(path: String, current: Data,
        expectedByteCount: UInt64, expectedSHA256: String) throws -> Data {
        guard current.count <= 1_048_576 else { throw Rejection.sourceEvolution }
        guard let witness = witnesses.first(where: { $0.path == path }) else {
            // Unchanged identities retain their exact old check, not a
            // generic rewrite or a fallback to whatever bytes were observed.
            guard UInt64(current.count) == expectedByteCount, digest(current) == expectedSHA256 else {
                throw Rejection.sourceEvolution
            }
            return current
        }
        guard expectedByteCount == witness.historicalByteCount,
              expectedSHA256 == witness.historicalSHA256,
              UInt64(current.count) == witness.currentByteCount,
              digest(current) == witness.currentSHA256,
              !witness.edits.isEmpty, witness.edits.count <= 32 else { throw Rejection.sourceEvolution }
        var decoded: [(edit: Edit, removed: Data, inserted: Data)] = []
        var oldEnd = 0, newEnd = 0
        for edit in witness.edits {
            guard let removed = Data(base64Encoded: edit.removedBase64),
                  let inserted = Data(base64Encoded: edit.insertedBase64),
                  edit.historicalOffset >= oldEnd, edit.currentOffset >= newEnd,
                  UInt64(edit.historicalOffset) <= witness.historicalByteCount,
                  UInt64(removed.count) <= witness.historicalByteCount - UInt64(edit.historicalOffset),
                  edit.currentOffset <= current.count,
                  inserted.count <= current.count - edit.currentOffset else { throw Rejection.sourceEvolution }
            oldEnd = edit.historicalOffset + removed.count
            newEnd = edit.currentOffset + inserted.count
            decoded.append((edit, removed, inserted))
        }
        var historical = current
        for item in decoded.reversed() {
            let range = item.edit.currentOffset..<(item.edit.currentOffset + item.inserted.count)
            guard historical.subdata(in: range) == item.inserted else { throw Rejection.sourceEvolution }
            historical.replaceSubrange(range, with: item.removed)
        }
        guard UInt64(historical.count) == expectedByteCount, digest(historical) == expectedSHA256 else {
            throw Rejection.sourceEvolution
        }
        var roundTrip = historical
        for item in decoded.reversed() {
            let range = item.edit.historicalOffset..<(item.edit.historicalOffset + item.removed.count)
            guard roundTrip.subdata(in: range) == item.removed else { throw Rejection.sourceEvolution }
            roundTrip.replaceSubrange(range, with: item.inserted)
        }
        guard roundTrip == current else { throw Rejection.sourceEvolution }
        return historical
    }

    /// Runs inside existing tests; adds no discovered test IDs and launches no
    /// child. Mutations exercise actual strict selection and reconstruction.
    static func assertRejectedMutations(root: URL) throws {
        XCTAssertEqual(Set(witnesses.map(\.path)).count, witnesses.count)
        for witness in witnesses {
            let current = try Data(contentsOf: root.appendingPathComponent(witness.path))
            let historical = try historicalData(path: witness.path, current: current,
                expectedByteCount: witness.historicalByteCount, expectedSHA256: witness.historicalSHA256)
            XCTAssertEqual(UInt64(historical.count), witness.historicalByteCount)
            XCTAssertEqual(digest(historical), witness.historicalSHA256)
            var offsets: Set<Int> = [0, current.count / 2, current.count - 1]
            for edit in witness.edits {
                let count = try XCTUnwrap(Data(base64Encoded: edit.insertedBase64)).count
                offsets.formUnion([edit.currentOffset - 1, edit.currentOffset,
                    edit.currentOffset + count / 2, edit.currentOffset + count - 1, edit.currentOffset + count])
            }
            for offset in offsets.sorted() where offset >= 0 && offset < current.count {
                var changed = current; changed[offset] ^= 1
                XCTAssertThrowsError(try historicalData(path: witness.path, current: changed,
                    expectedByteCount: witness.historicalByteCount, expectedSHA256: witness.historicalSHA256), witness.path)
            }
            for changed in [Data(current.dropLast()), current + Data([10]), historical] {
                XCTAssertThrowsError(try historicalData(path: witness.path, current: changed,
                    expectedByteCount: witness.historicalByteCount, expectedSHA256: witness.historicalSHA256), witness.path)
            }
            XCTAssertThrowsError(try historicalData(path: "unadmitted/" + witness.path, current: current,
                expectedByteCount: witness.historicalByteCount, expectedSHA256: witness.historicalSHA256))
            XCTAssertThrowsError(try historicalData(path: witness.path, current: current,
                expectedByteCount: witness.historicalByteCount + 1, expectedSHA256: witness.historicalSHA256))
            XCTAssertThrowsError(try historicalData(path: witness.path, current: current,
                expectedByteCount: witness.historicalByteCount, expectedSHA256: String(repeating: "0", count: 64)))
        }
    }

    private static let witnesses: [Witness] = [
        // 558f293568c0736836b610e4bb333bd5f1d98f62 → 91459ee654caa459fb91177c6f5c88e7157f49f8
        .init(path: "Sources/PrimeCore/PrimeDurableArtifacts.swift", historicalByteCount: 144993,
            historicalSHA256: "faa8254ee6ecd97f064a6553efba8158fff6a33fc882607444ba117d56328430", currentByteCount: 145670,
            currentSHA256: "706ee76bd54f535d7d28ffcd63ddda9f6197c3cd6484eb9256e78b24e95964ea", edits: [
            .init(historicalOffset: 7846, currentOffset: 7846,
                removedBase64: "",
                insertedBase64: "ICAgIC8vLyBEZXJpdmVzIGEgY2hpbGQgYXJ0aWZhY3QgY2FwYWJpbGl0eSBmcm9tIGFuIGFscmVhZHktaGVsZCwgbm8tZm9sbG93CiAgICAvLy8gZGlyZWN0b3J5LiBUaGUgVVJMIGlzIHRlbGVtZXRyeSBhbmQgaXMgbmV2ZXIgb3BlbmVkIGJ5IHRoaXMgaW5pdGlhbGl6ZXIuCiAgICBpbml0KGhlbGREaXJlY3RvcnlEZXNjcmlwdG9yOiBJbnQzMiwgZGlzcGxheVVSTDogVVJMKSB0aHJvd3MgewogICAgICAgIGxldCBkdXBsaWNhdGUgPSBmY250bChoZWxkRGlyZWN0b3J5RGVzY3JpcHRvciwgRl9EVVBGRF9DTE9FWEVDLCAzKQogICAgICAgIGd1YXJkIGR1cGxpY2F0ZSA+PSAzIGVsc2UgewogICAgICAgICAgICB0aHJvdyBTZWxmLnBvc2l4KCJkdXBsaWNhdGUgaGVsZCBhcnRpZmFjdCBkaXJlY3RvcnkiLCBkaXNwbGF5VVJMLnBhdGgpCiAgICAgICAgfQogICAgICAgIGRvIHsKICAgICAgICAgICAgdHJ5IFNlbGYucmVxdWlyZVRydXN0ZWREaXJlY3RvcnkoZHVwbGljYXRlLCBwYXRoOiBkaXNwbGF5VVJMLnBhdGgpCiAgICAgICAgfSBjYXRjaCB7CiAgICAgICAgICAgIF8gPSBjbG9zZShkdXBsaWNhdGUpCiAgICAgICAgICAgIHRocm93IGVycm9yCiAgICAgICAgfQogICAgICAgIGRlc2NyaXB0b3IgPSBkdXBsaWNhdGUKICAgICAgICBkaXJlY3RvcnlVUkwgPSBkaXNwbGF5VVJMCiAgICB9Cgo=")
        ]),
        // 2ee5de6dddafa03ed6e2c1effedc060dea7c32ff → root reviewed internal fixture namespace overload (30e4ed3378)
        .init(path: "Sources/PrimeCore/PrimePinnedMLXMetallib.swift", historicalByteCount: 51777,
            historicalSHA256: "a5f875c089613f82e2bc1044f35fa1a2bfe13d3498685db4c9f9e5fc1ec51d78", currentByteCount: 52760,
            currentSHA256: "30e4ed33782c9a3e8f41ff448da40bf97c9190892eed117770451242fd1c4b4c", edits: [
            .init(historicalOffset: 3037, currentOffset: 3037,
                removedBase64: "",
                insertedBase64: "ICAgICkgdGhyb3dzIC0+IFByaW1lUGlubmVkTUxYTWV0YWxsaWJCaW5kaW5nIHsKICAgICAgICB0cnkgY2FwdHVyZVNpYmxpbmcoCiAgICAgICAgICAgIG9mOiBydW5uaW5nRXhlY3V0YWJsZVVSTCwKICAgICAgICAgICAgaW50bzogYXJ0aWZhY3RSb290LAogICAgICAgICAgICBydW50aW1lUm9sZTogcnVudGltZVJvbGUsCiAgICAgICAgICAgIGxvYWRlckJ1bmRsZUNhbmRpZGF0ZXM6IG5pbAogICAgICAgICkKICAgIH0KCiAgICAvLyBUaGUgcHVibGljIHJ1bnRpbWUgZW50cnkgYWx3YXlzIHNhbXBsZXMgdGhlIGFjdHVhbCBwcm9jZXNzIGJ1bmRsZXMuCiAgICAvLyBJbnRlcm5hbCBmaXh0dXJlIGNhbGxlcnMgY2FuIHN1cHBseSB0aGVpciBvd24gYnVuZGxlIG5hbWVzcGFjZSB3aGlsZQogICAgLy8gcmV0YWluaW5nIHRoZSBzYW1lIHdvcmtpbmctZGlyZWN0b3J5LCBlbnZpcm9ubWVudCBhbmQgZmlsZSBjaGVja3MuCiAgICBzdGF0aWMgZnVuYyBjYXB0dXJlU2libGluZygKICAgICAgICBvZiBydW5uaW5nRXhlY3V0YWJsZVVSTDogVVJMLAogICAgICAgIGludG8gYXJ0aWZhY3RSb290OiBQcmltZUFydGlmYWN0Um9vdCwKICAgICAgICBydW50aW1lUm9sZTogUHJpbWVNTFhSdW50aW1lUm9sZSwKICAgICAgICBsb2FkZXJCdW5kbGVDYW5kaWRhdGVzOiBbVVJMXT8K"),
            .init(historicalOffset: 4955, currentOffset: 5618,
                removedBase64: "ICAgICAgICAgICAgaW5jbHVkZUN1cnJlbnRQcm9jZXNzQ29udGV4dDogdHJ1ZQo=",
                insertedBase64: "ICAgICAgICAgICAgaW5jbHVkZUN1cnJlbnRQcm9jZXNzQ29udGV4dDogdHJ1ZSwKICAgICAgICAgICAgbG9hZGVyQnVuZGxlQ2FuZGlkYXRlczogbG9hZGVyQnVuZGxlQ2FuZGlkYXRlcwo="),
            .init(historicalOffset: 42184, currentOffset: 42907,
                removedBase64: "ICAgICAgICBpbmNsdWRlQ3VycmVudFByb2Nlc3NDb250ZXh0OiBCb29sCg==",
                insertedBase64: "ICAgICAgICBpbmNsdWRlQ3VycmVudFByb2Nlc3NDb250ZXh0OiBCb29sLAogICAgICAgIGxvYWRlckJ1bmRsZUNhbmRpZGF0ZXM6IFtVUkxdPyA9IG5pbAo="),
            .init(historicalOffset: 42890, currentOffset: 43659,
                removedBase64: "ICAgICAgICB2YXIgYnVuZGxlQ2FuZGlkYXRlcyA9IFtVUkxdKCkKICAgICAgICBpZiBsZXQgbWFpbkJ1bmRsZVVSTCA9IEJ1bmRsZS5tYWluLmJ1bmRsZVVSTAogICAgICAgICAgICBhcyBVUkw/IHsKICAgICAgICAgICAgYnVuZGxlQ2FuZGlkYXRlcy5hcHBlbmQoCiAgICAgICAgICAgICAgICBtYWluQnVuZGxlVVJMCiAgICAgICAgICAgICAgICAgICAgLmFwcGVuZGluZ1BhdGhDb21wb25lbnQoCiAgICAgICAgICAgICAgICAgICAgICAgIHNvdXJjZUJ1bmRsZVJlbGF0aXZlUGF0aAogICAgICAgICAgICAgICAgICAgICkKICAgICAgICAgICAgKQogICAgICAgIH0KICAgICAgICBmb3IgYnVuZGxlIGluIEJ1bmRsZS5hbGxCdW5kbGVzIHsKICAgICAgICAgICAgaWYgbGV0IHJlc291cmNlVVJMID0gYnVuZGxlLnJlc291cmNlVVJMIHsK",
                insertedBase64: "ICAgICAgICB2YXIgYnVuZGxlQ2FuZGlkYXRlcyA9IGxvYWRlckJ1bmRsZUNhbmRpZGF0ZXMgPz8gW10KICAgICAgICBpZiBsb2FkZXJCdW5kbGVDYW5kaWRhdGVzID09IG5pbCB7CiAgICAgICAgICAgIGlmIGxldCBtYWluQnVuZGxlVVJMID0gQnVuZGxlLm1haW4uYnVuZGxlVVJMCiAgICAgICAgICAgICAgICBhcyBVUkw/IHsK"),
            .init(historicalOffset: 43348, currentOffset: 43886,
                removedBase64: "ICAgICAgICAgICAgICAgICAgICByZXNvdXJjZVVSTAo=",
                insertedBase64: "ICAgICAgICAgICAgICAgICAgICBtYWluQnVuZGxlVVJMCg=="),
            .init(historicalOffset: 43540, currentOffset: 44080,
                removedBase64: "ICAgICAgICB9CiAgICAgICAgZm9yIGZyYW1ld29yayBpbiBCdW5kbGUuYWxsRnJhbWV3b3JrcwogICAgICAgIHdoZXJlIGZyYW1ld29yay5idW5kbGVJZGVudGlmaWVyCiAgICAgICAgICAgID09ICJtbHgtc3dpZnRfQ21seCIKICAgICAgICAgICAgfHwgZnJhbWV3b3JrLmJ1bmRsZUlkZW50aWZpZXIKICAgICAgICAgICAgICAgID09ICJjb20uYXBwbGUubWx4LkNtbHgiCiAgICAgICAgewogICAgICAgICAgICBpZiBsZXQgcmVzb3VyY2VVUkwgPQogICAgICAgICAgICAgICAgICAgIGZyYW1ld29yay5yZXNvdXJjZVVSTCB7CiAgICAgICAgICAgICAgICBidW5kbGVDYW5kaWRhdGVzLmFwcGVuZCgKICAgICAgICAgICAgICAgICAgICByZXNvdXJjZVVSTAogICAgICAgICAgICAgICAgICAgICAgICAuYXBwZW5kaW5nUGF0aENvbXBvbmVudCgKICAgICAgICAgICAgICAgICAgICAgICAgICAgICJkZWZhdWx0Lm1ldGFsbGliIgogICAgICAgICAgICAgICAgICAgICAgICApCiAgICAgICAgICAgICAgICApCg==",
                insertedBase64: "ICAgICAgICAgICAgZm9yIGJ1bmRsZSBpbiBCdW5kbGUuYWxsQnVuZGxlcyB7CiAgICAgICAgICAgICAgICBpZiBsZXQgcmVzb3VyY2VVUkwgPSBidW5kbGUucmVzb3VyY2VVUkwgewogICAgICAgICAgICAgICAgICAgIGJ1bmRsZUNhbmRpZGF0ZXMuYXBwZW5kKAogICAgICAgICAgICAgICAgICAgICAgICByZXNvdXJjZVVSTAogICAgICAgICAgICAgICAgICAgICAgICAgICAgLmFwcGVuZGluZ1BhdGhDb21wb25lbnQoCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgc291cmNlQnVuZGxlUmVsYXRpdmVQYXRoCiAgICAgICAgICAgICAgICAgICAgICAgICAgICApCiAgICAgICAgICAgICAgICAgICAgKQogICAgICAgICAgICAgICAgfQogICAgICAgICAgICB9CiAgICAgICAgICAgIGZvciBmcmFtZXdvcmsgaW4gQnVuZGxlLmFsbEZyYW1ld29ya3MKICAgICAgICAgICAgd2hlcmUgZnJhbWV3b3JrLmJ1bmRsZUlkZW50aWZpZXIKICAgICAgICAgICAgICAgID09ICJtbHgtc3dpZnRfQ21seCIKICAgICAgICAgICAgICAgIHx8IGZyYW1ld29yay5idW5kbGVJZGVudGlmaWVyCiAgICAgICAgICAgICAgICAgICAgPT0gImNvbS5hcHBsZS5tbHguQ21seCIKICAgICAgICAgICAgewogICAgICAgICAgICAgICAgaWYgbGV0IHJlc291cmNlVVJMID0KICAgICAgICAgICAgICAgICAgICAgICAgZnJhbWV3b3JrLnJlc291cmNlVVJMIHsKICAgICAgICAgICAgICAgICAgICBidW5kbGVDYW5kaWRhdGVzLmFwcGVuZCgKICAgICAgICAgICAgICAgICAgICAgICAgcmVzb3VyY2VVUkwKICAgICAgICAgICAgICAgICAgICAgICAgICAgIC5hcHBlbmRpbmdQYXRoQ29tcG9uZW50KAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICJkZWZhdWx0Lm1ldGFsbGliIgogICAgICAgICAgICAgICAgICAgICAgICAgICAgKQogICAgICAgICAgICAgICAgICAgICkKICAgICAgICAgICAgICAgIH0K")
        ])
    ]
}
