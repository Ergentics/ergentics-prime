// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary
import Foundation
import PrimeCore
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
    private static func digest(_ data: Data) -> String { PrimeSHA256.hexDigest(of: data) }

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
        // 6ca04a709fcb784e8ffab704567ca427f8c9d201 → 2ee5de6dddafa03ed6e2c1effedc060dea7c32ff
        .init(path: "Package.swift", historicalByteCount: 27650,
            historicalSHA256: "190b1d2dbeb2597830b1765fa80d6776a0044a34d5e2c6db8b14ace013654e7d", currentByteCount: 32843,
            currentSHA256: "fa68f463ca31a4ca25af6b14eb19b139df0c8ef8259a6348bb40e97c2dcdeb81", edits: [
            .init(historicalOffset: 264, currentOffset: 264,
                removedBase64: "",
                insertedBase64: "ICAgICAgICAubGlicmFyeSgKICAgICAgICAgICAgbmFtZTogIlByaW1lTmF0aXZlRGVjb2RlciIsCiAgICAgICAgICAgIHRhcmdldHM6IFsiUHJpbWVOYXRpdmVEZWNvZGVyIl0KICAgICAgICApLAogICAgICAgIC5saWJyYXJ5KAogICAgICAgICAgICBuYW1lOiAiUHJpbWVOYXRpdmVEZWNvZGVyVHJhaW5pbmciLAogICAgICAgICAgICB0YXJnZXRzOiBbIlByaW1lTmF0aXZlRGVjb2RlclRyYWluaW5nIl0KICAgICAgICApLAogICAgICAgIC5saWJyYXJ5KAogICAgICAgICAgICBuYW1lOiAiUHJpbWVOYXRpdmVEZWNvZGVyQ2hlY2twb2ludCIsCiAgICAgICAgICAgIHRhcmdldHM6IFsiUHJpbWVOYXRpdmVEZWNvZGVyQ2hlY2twb2ludCJdCiAgICAgICAgKSwKICAgICAgICAubGlicmFyeSgKICAgICAgICAgICAgbmFtZTogIlByaW1lTmF0aXZlRGVjb2RlclJ1bnRpbWUiLAogICAgICAgICAgICB0YXJnZXRzOiBbIlByaW1lTmF0aXZlRGVjb2RlclJ1bnRpbWUiXQogICAgICAgICksCiAgICAgICAgLmxpYnJhcnkoCiAgICAgICAgICAgIG5hbWU6ICJQcmltZUxhdGluUHJvcG9zYWxQYWlyQ2FwdHVyZSIsCiAgICAgICAgICAgIHRhcmdldHM6IFsKICAgICAgICAgICAgICAgICJQcmltZUxhdGluUHJvcG9zYWxQYWlyQ2FwdHVyZSIsCiAgICAgICAgICAgIF0KICAgICAgICApLAogICAgICAgIC5saWJyYXJ5KAogICAgICAgICAgICBuYW1lOiAiUHJpbWVMYXRpblByb3Bvc2FsR2l0T2JzZXJ2YXRpb24iLAogICAgICAgICAgICB0YXJnZXRzOiBbCiAgICAgICAgICAgICAgICAiUHJpbWVMYXRpblByb3Bvc2FsR2l0T2JzZXJ2YXRpb24iLAogICAgICAgICAgICBdCiAgICAgICAgKSwKICAgICAgICAubGlicmFyeSgKICAgICAgICAgICAgbmFtZTogIlByaW1lTGF0aW5Qcm9wb3NhbFByb2R1Y2VyUmV2YWxpZGF0aW9uT2JzZXJ2YXRpb24iLAogICAgICAgICAgICB0YXJnZXRzOiBbCiAgICAgICAgICAgICAgICAiUHJpbWVMYXRpblByb3Bvc2FsUHJvZHVjZXJSZXZhbGlkYXRpb25PYnNlcnZhdGlvbiIsCiAgICAgICAgICAgIF0KICAgICAgICApLAogICAgICAgIC5saWJyYXJ5KAogICAgICAgICAgICBuYW1lOiAiUHJpbWVMYXRpblByb3Bvc2FsSW5kZXBlbmRlbnRSZXBsYXkiLAogICAgICAgICAgICB0YXJnZXRzOiBbCiAgICAgICAgICAgICAgICAiUHJpbWVMYXRpblByb3Bvc2FsSW5kZXBlbmRlbnRSZXBsYXkiLAogICAgICAgICAgICBdCiAgICAgICAgKSwKICAgICAgICAuZXhlY3V0YWJsZSgKICAgICAgICAgICAgbmFtZTogIlByaW1lTGF0aW5Qcm9wb3NhbFBhaXJDYXB0dXJlUHJvYmUiLAogICAgICAgICAgICB0YXJnZXRzOiBbCiAgICAgICAgICAgICAgICAiUHJpbWVMYXRpblByb3Bvc2FsUGFpckNhcHR1cmVQcm9iZSIsCiAgICAgICAgICAgIF0KICAgICAgICApLAogICAgICAgIC5leGVjdXRhYmxlKAogICAgICAgICAgICBuYW1lOiAiUHJpbWVMYXRpblByb3Bvc2FsR2l0T2JzZXJ2YXRpb25Qcm9iZSIsCiAgICAgICAgICAgIHRhcmdldHM6IFsKICAgICAgICAgICAgICAgICJQcmltZUxhdGluUHJvcG9zYWxHaXRPYnNlcnZhdGlvblByb2JlIiwKICAgICAgICAgICAgXQogICAgICAgICksCiAgICAgICAgLmV4ZWN1dGFibGUoCiAgICAgICAgICAgIG5hbWU6CiAgICAgICAgICAgICAgICAiUHJpbWVMYXRpblByb3Bvc2FsUHJvZHVjZXJSZXZhbGlkYXRpb25PYnNlcnZhdGlvblByb2JlIiwKICAgICAgICAgICAgdGFyZ2V0czogWwogICAgICAgICAgICAgICAgIlByaW1lTGF0aW5Qcm9wb3NhbFByb2R1Y2VyUmV2YWxpZGF0aW9uT2JzZXJ2YXRpb25Qcm9iZSIsCiAgICAgICAgICAgIF0KICAgICAgICApLAogICAgICAgIC5leGVjdXRhYmxlKAogICAgICAgICAgICBuYW1lOiAiUHJpbWVMYXRpblByb3Bvc2FsSW5kZXBlbmRlbnRSZXBsYXlQcm9iZSIsCiAgICAgICAgICAgIHRhcmdldHM6IFsKICAgICAgICAgICAgICAgICJQcmltZUxhdGluUHJvcG9zYWxJbmRlcGVuZGVudFJlcGxheVByb2JlIiwKICAgICAgICAgICAgXQogICAgICAgICksCg=="),
            .init(historicalOffset: 2345, currentOffset: 4359,
                removedBase64: "ICAgICAgICAuZXhlY3V0YWJsZSgKICAgICAgICAgICAgbmFtZTogIlByaW1lR1BVQ2FsaWJyYXRpb24iLAogICAgICAgICAgICB0YXJnZXRzOiBbIlByaW1lR1BVQ2FsaWJyYXRpb24iXQogICAgICAgICksCiAgICAgICAgLmV4ZWN1dGFibGUoCiAgICAgICAgICAgIG5hbWU6ICJQcmltZU5hdGl2ZTNCTWV0YWxDb250aW51YXRpb25Qcm9iZSIsCiAgICAgICAgICAgIHRhcmdldHM6IFsKICAgICAgICAgICAgICAgICJQcmltZU5hdGl2ZTNCTWV0YWxDb250aW51YXRpb25Qcm9iZSIsCiAgICAgICAgICAgIF0KICAgICAgICApLAo=",
                insertedBase64: ""),
            .init(historicalOffset: 5407, currentOffset: 7122,
                removedBase64: "ICAgICAgICAucGFja2FnZSgKICAgICAgICAgICAgdXJsOiAiaHR0cHM6Ly9naXRodWIuY29tL21sLWV4cGxvcmUvbWx4LXN3aWZ0LWxtIiwKICAgICAgICAgICAgZXhhY3Q6ICIzLjMxLjMiCiAgICAgICAgKSwK",
                insertedBase64: ""),
            .init(historicalOffset: 5607, currentOffset: 7202,
                removedBase64: "",
                insertedBase64: "ICAgICAgICAudGFyZ2V0KAogICAgICAgICAgICBuYW1lOiAiUHJpbWVOYXRpdmVEZWNvZGVyIiwKICAgICAgICAgICAgZGVwZW5kZW5jaWVzOiBbCiAgICAgICAgICAgICAgICAiUHJpbWVDb3JlIiwKICAgICAgICAgICAgICAgIC5wcm9kdWN0KAogICAgICAgICAgICAgICAgICAgIG5hbWU6ICJNTFgiLAogICAgICAgICAgICAgICAgICAgIHBhY2thZ2U6ICJlcmdlbnRpY3MtbWx4LXN3aWZ0IgogICAgICAgICAgICAgICAgKSwKICAgICAgICAgICAgICAgIC5wcm9kdWN0KAogICAgICAgICAgICAgICAgICAgIG5hbWU6ICJNTFhOTiIsCiAgICAgICAgICAgICAgICAgICAgcGFja2FnZTogImVyZ2VudGljcy1tbHgtc3dpZnQiCiAgICAgICAgICAgICAgICApLAogICAgICAgICAgICBdCiAgICAgICAgKSwKICAgICAgICAudGFyZ2V0KAogICAgICAgICAgICBuYW1lOiAiUHJpbWVOYXRpdmVEZWNvZGVyVHJhaW5pbmciLAogICAgICAgICAgICBkZXBlbmRlbmNpZXM6IFsKICAgICAgICAgICAgICAgICJQcmltZUNvcmUiLAogICAgICAgICAgICAgICAgIlByaW1lTmF0aXZlRGVjb2RlciIsCiAgICAgICAgICAgICAgICAiUHJpbWVOYXRpdmVEZWNvZGVyQ2hlY2twb2ludCIsCiAgICAgICAgICAgICAgICAucHJvZHVjdCgKICAgICAgICAgICAgICAgICAgICBuYW1lOiAiTUxYIiwKICAgICAgICAgICAgICAgICAgICBwYWNrYWdlOiAiZXJnZW50aWNzLW1seC1zd2lmdCIKICAgICAgICAgICAgICAgICksCiAgICAgICAgICAgICAgICAucHJvZHVjdCgKICAgICAgICAgICAgICAgICAgICBuYW1lOiAiTUxYTk4iLAogICAgICAgICAgICAgICAgICAgIHBhY2thZ2U6ICJlcmdlbnRpY3MtbWx4LXN3aWZ0IgogICAgICAgICAgICAgICAgKSwKICAgICAgICAgICAgICAgIC5wcm9kdWN0KAogICAgICAgICAgICAgICAgICAgIG5hbWU6ICJNTFhPcHRpbWl6ZXJzIiwKICAgICAgICAgICAgICAgICAgICBwYWNrYWdlOiAiZXJnZW50aWNzLW1seC1zd2lmdCIKICAgICAgICAgICAgICAgICksCiAgICAgICAgICAgIF0KICAgICAgICApLAogICAgICAgIC50YXJnZXQoCiAgICAgICAgICAgIG5hbWU6ICJQcmltZU5hdGl2ZURlY29kZXJDaGVja3BvaW50IiwKICAgICAgICAgICAgZGVwZW5kZW5jaWVzOiBbCiAgICAgICAgICAgICAgICAiUHJpbWVDb3JlIiwKICAgICAgICAgICAgICAgICJQcmltZU5hdGl2ZURlY29kZXIiLAogICAgICAgICAgICAgICAgLnByb2R1Y3QoCiAgICAgICAgICAgICAgICAgICAgbmFtZTogIk1MWCIsCiAgICAgICAgICAgICAgICAgICAgcGFja2FnZTogImVyZ2VudGljcy1tbHgtc3dpZnQiCiAgICAgICAgICAgICAgICApLAogICAgICAgICAgICAgICAgLnByb2R1Y3QoCiAgICAgICAgICAgICAgICAgICAgbmFtZTogIk1MWE5OIiwKICAgICAgICAgICAgICAgICAgICBwYWNrYWdlOiAiZXJnZW50aWNzLW1seC1zd2lmdCIKICAgICAgICAgICAgICAgICksCiAgICAgICAgICAgIF0KICAgICAgICApLAogICAgICAgIC50YXJnZXQoCiAgICAgICAgICAgIG5hbWU6ICJQcmltZU5hdGl2ZURlY29kZXJSdW50aW1lIiwKICAgICAgICAgICAgZGVwZW5kZW5jaWVzOiBbCiAgICAgICAgICAgICAgICAiUHJpbWVDb3JlIiwKICAgICAgICAgICAgICAgICJQcmltZU5hdGl2ZURlY29kZXIiLAogICAgICAgICAgICAgICAgIlByaW1lTmF0aXZlRGVjb2RlckNoZWNrcG9pbnQiLAogICAgICAgICAgICAgICAgLnByb2R1Y3QoCiAgICAgICAgICAgICAgICAgICAgbmFtZTogIk1MWCIsCiAgICAgICAgICAgICAgICAgICAgcGFja2FnZTogImVyZ2VudGljcy1tbHgtc3dpZnQiCiAgICAgICAgICAgICAgICApLAogICAgICAgICAgICBdLAogICAgICAgICAgICBsaW5rZXJTZXR0aW5nczogWwogICAgICAgICAgICAgICAgLmxpbmtlZEZyYW1ld29yaygiQ29yZUdyYXBoaWNzIiksCiAgICAgICAgICAgICAgICAubGlua2VkRnJhbWV3b3JrKCJNZXRhbCIpLAogICAgICAgICAgICBdCiAgICAgICAgKSwKICAgICAgICAudGFyZ2V0KAogICAgICAgICAgICBuYW1lOiAiUHJpbWVMYXRpblByb3Bvc2FsUGFpckNhcHR1cmUiCiAgICAgICAgKSwKICAgICAgICAudGFyZ2V0KAogICAgICAgICAgICBuYW1lOiAiUHJpbWVMYXRpblByb3Bvc2FsR2l0T2JzZXJ2YXRpb24iLAogICAgICAgICAgICBkZXBlbmRlbmNpZXM6IFsKICAgICAgICAgICAgICAgICJQcmltZUxhdGluUHJvcG9zYWxQYWlyQ2FwdHVyZSIsCiAgICAgICAgICAgIF0KICAgICAgICApLAogICAgICAgIC50YXJnZXQoCiAgICAgICAgICAgIG5hbWU6ICJQcmltZUxhdGluUHJvcG9zYWxQcm9kdWNlclJldmFsaWRhdGlvbk9ic2VydmF0aW9uIiwKICAgICAgICAgICAgZGVwZW5kZW5jaWVzOiBbCiAgICAgICAgICAgICAgICAiUHJpbWVMYXRpblByb3Bvc2FsUGFpckNhcHR1cmUiLAogICAgICAgICAgICAgICAgIlByaW1lTGF0aW5Qcm9wb3NhbEdpdE9ic2VydmF0aW9uIiwKICAgICAgICAgICAgXQogICAgICAgICksCiAgICAgICAgLnRhcmdldCgKICAgICAgICAgICAgbmFtZTogIlByaW1lTGF0aW5Qcm9wb3NhbEluZGVwZW5kZW50UmVwbGF5IiwKICAgICAgICAgICAgZGVwZW5kZW5jaWVzOiBbCiAgICAgICAgICAgICAgICAiUHJpbWVMYXRpblByb3Bvc2FsUGFpckNhcHR1cmUiLAogICAgICAgICAgICAgICAgIlByaW1lTGF0aW5Qcm9wb3NhbEdpdE9ic2VydmF0aW9uIiwKICAgICAgICAgICAgXQogICAgICAgICksCiAgICAgICAgLnRhcmdldCgKICAgICAgICAgICAgbmFtZTogIlByaW1lTGF0aW5Qcm9wb3NhbFZhbGlkYXRpb25Db21wb3NpdGlvbiIsCiAgICAgICAgICAgIGRlcGVuZGVuY2llczogWwogICAgICAgICAgICAgICAgIlByaW1lTGF0aW5Qcm9wb3NhbFByb2R1Y2VyUmV2YWxpZGF0aW9uT2JzZXJ2YXRpb24iLAogICAgICAgICAgICAgICAgIlByaW1lTGF0aW5Qcm9wb3NhbEluZGVwZW5kZW50UmVwbGF5IiwKICAgICAgICAgICAgXQogICAgICAgICksCiAgICAgICAgLnRhcmdldCgKICAgICAgICAgICAgbmFtZTogIlByaW1lTGF0aW5Qcm9wb3NhbFZhbGlkYXRpb25Db21wb3NpdGlvblJlY2VpcHQiCiAgICAgICAgKSwKICAgICAgICAudGFyZ2V0KAogICAgICAgICAgICBuYW1lOiAiUHJpbWVMYXRpblByb3Bvc2FsVmFsaWRhdGlvbkNvbXBvc2l0aW9uUmVjZWlwdFB1Ymxpc2hlciIsCiAgICAgICAgICAgIGRlcGVuZGVuY2llczogWwogICAgICAgICAgICAgICAgIlByaW1lQ29yZSIsCiAgICAgICAgICAgICAgICAiUHJpbWVMYXRpblByb3Bvc2FsVmFsaWRhdGlvbkNvbXBvc2l0aW9uIiwKICAgICAgICAgICAgICAgICJQcmltZUxhdGluUHJvcG9zYWxWYWxpZGF0aW9uQ29tcG9zaXRpb25SZWNlaXB0IiwKICAgICAgICAgICAgXQogICAgICAgICksCiAgICAgICAgLnRhcmdldCgKICAgICAgICAgICAgbmFtZTogIlByaW1lTGF0aW5Qcm9wb3NhbEFkbWlzc2lvblBvbGljeSIsCiAgICAgICAgICAgIGRlcGVuZGVuY2llczogWwogICAgICAgICAgICAgICAgIlByaW1lTGF0aW5Qcm9wb3NhbFZhbGlkYXRpb25Db21wb3NpdGlvblJlY2VpcHQiLAogICAgICAgICAgICBdCiAgICAgICAgKSwK"),
            .init(historicalOffset: 17919, currentOffset: 23054,
                removedBase64: "ICAgICAgICAuZXhlY3V0YWJsZVRhcmdldCgKICAgICAgICAgICAgbmFtZTogIlByaW1lR1BVQ2FsaWJyYXRpb24iLAogICAgICAgICAgICBkZXBlbmRlbmNpZXM6IFsKICAgICAgICAgICAgICAgICJQcmltZUNvcmUiLAogICAgICAgICAgICAgICAgLnByb2R1Y3QoCiAgICAgICAgICAgICAgICAgICAgbmFtZTogIk1MWCIsCiAgICAgICAgICAgICAgICAgICAgcGFja2FnZTogImVyZ2VudGljcy1tbHgtc3dpZnQiCiAgICAgICAgICAgICAgICApLAogICAgICAgICAgICAgICAgLnByb2R1Y3QoCiAgICAgICAgICAgICAgICAgICAgbmFtZTogIk1MWE5OIiwKICAgICAgICAgICAgICAgICAgICBwYWNrYWdlOiAiZXJnZW50aWNzLW1seC1zd2lmdCIKICAgICAgICAgICAgICAgICksCiAgICAgICAgICAgICAgICAucHJvZHVjdCgKICAgICAgICAgICAgICAgICAgICBuYW1lOiAiTUxYT3B0aW1pemVycyIsCiAgICAgICAgICAgICAgICAgICAgcGFja2FnZTogImVyZ2VudGljcy1tbHgtc3dpZnQiCiAgICAgICAgICAgICAgICApLAogICAgICAgICAgICAgICAgLnByb2R1Y3QoCiAgICAgICAgICAgICAgICAgICAgbmFtZTogIk1MWExMTSIsCiAgICAgICAgICAgICAgICAgICAgcGFja2FnZTogIm1seC1zd2lmdC1sbSIKICAgICAgICAgICAgICAgICksCiAgICAgICAgICAgIF0KICAgICAgICApLAogICAgICAgIC5leGVjdXRhYmxlVGFyZ2V0KAogICAgICAgICAgICBuYW1lOiAiUHJpbWVOYXRpdmUzQk1ldGFsQ29udGludWF0aW9uUHJvYmUiLAogICAgICAgICAgICBkZXBlbmRlbmNpZXM6IFsKICAgICAgICAgICAgICAgICJQcmltZUNvcmUiLAogICAgICAgICAgICAgICAgLnByb2R1Y3QoCiAgICAgICAgICAgICAgICAgICAgbmFtZTogIk1MWCIsCiAgICAgICAgICAgICAgICAgICAgcGFja2FnZTogImVyZ2VudGljcy1tbHgtc3dpZnQiCiAgICAgICAgICAgICAgICApLAogICAgICAgICAgICAgICAgLnByb2R1Y3QoCiAgICAgICAgICAgICAgICAgICAgbmFtZTogIk1MWE5OIiwKICAgICAgICAgICAgICAgICAgICBwYWNrYWdlOiAiZXJnZW50aWNzLW1seC1zd2lmdCIKICAgICAgICAgICAgICAgICksCiAgICAgICAgICAgICAgICAucHJvZHVjdCgKICAgICAgICAgICAgICAgICAgICBuYW1lOiAiTUxYT3B0aW1pemVycyIsCiAgICAgICAgICAgICAgICAgICAgcGFja2FnZTogImVyZ2VudGljcy1tbHgtc3dpZnQiCiAgICAgICAgICAgICAgICApLAogICAgICAgICAgICAgICAgLnByb2R1Y3QoCiAgICAgICAgICAgICAgICAgICAgbmFtZTogIk1MWExMTSIsCiAgICAgICAgICAgICAgICAgICAgcGFja2FnZTogIm1seC1zd2lmdC1sbSIKICAgICAgICAgICAgICAgICksCiAgICAgICAgICAgIF0KICAgICAgICApLAo=",
                insertedBase64: ""),
            .init(historicalOffset: 21204, currentOffset: 24975,
                removedBase64: "",
                insertedBase64: "ICAgICAgICAuZXhlY3V0YWJsZVRhcmdldCgKICAgICAgICAgICAgbmFtZTogIlByaW1lTGF0aW5Qcm9wb3NhbFBhaXJDYXB0dXJlUHJvYmUiLAogICAgICAgICAgICBkZXBlbmRlbmNpZXM6IFsKICAgICAgICAgICAgICAgICJQcmltZUxhdGluUHJvcG9zYWxQYWlyQ2FwdHVyZSIsCiAgICAgICAgICAgIF0KICAgICAgICApLAogICAgICAgIC5leGVjdXRhYmxlVGFyZ2V0KAogICAgICAgICAgICBuYW1lOiAiUHJpbWVMYXRpblByb3Bvc2FsR2l0T2JzZXJ2YXRpb25Qcm9iZSIsCiAgICAgICAgICAgIGRlcGVuZGVuY2llczogWwogICAgICAgICAgICAgICAgIlByaW1lTGF0aW5Qcm9wb3NhbEdpdE9ic2VydmF0aW9uIiwKICAgICAgICAgICAgXQogICAgICAgICksCiAgICAgICAgLmV4ZWN1dGFibGVUYXJnZXQoCiAgICAgICAgICAgIG5hbWU6CiAgICAgICAgICAgICAgICAiUHJpbWVMYXRpblByb3Bvc2FsUHJvZHVjZXJSZXZhbGlkYXRpb25PYnNlcnZhdGlvblByb2JlIiwKICAgICAgICAgICAgZGVwZW5kZW5jaWVzOiBbCiAgICAgICAgICAgICAgICAiUHJpbWVMYXRpblByb3Bvc2FsUHJvZHVjZXJSZXZhbGlkYXRpb25PYnNlcnZhdGlvbiIsCiAgICAgICAgICAgIF0KICAgICAgICApLAogICAgICAgIC5leGVjdXRhYmxlVGFyZ2V0KAogICAgICAgICAgICBuYW1lOiAiUHJpbWVMYXRpblByb3Bvc2FsSW5kZXBlbmRlbnRSZXBsYXlQcm9iZSIsCiAgICAgICAgICAgIGRlcGVuZGVuY2llczogWwogICAgICAgICAgICAgICAgIlByaW1lTGF0aW5Qcm9wb3NhbEluZGVwZW5kZW50UmVwbGF5IiwKICAgICAgICAgICAgXQogICAgICAgICksCg=="),
            .init(historicalOffset: 22487, currentOffset: 27072,
                removedBase64: "",
                insertedBase64: "ICAgICAgICAudGVzdFRhcmdldCgKICAgICAgICAgICAgbmFtZTogIlByaW1lTGF0aW5Qcm9wb3NhbFBhaXJDYXB0dXJlVGVzdHMiLAogICAgICAgICAgICBkZXBlbmRlbmNpZXM6IFsKICAgICAgICAgICAgICAgICJQcmltZUxhdGluUHJvcG9zYWxQYWlyQ2FwdHVyZSIsCiAgICAgICAgICAgICAgICAiUHJpbWVMYXRpblByb3Bvc2FsR2l0T2JzZXJ2YXRpb24iLAogICAgICAgICAgICAgICAgIlByaW1lTGF0aW5Qcm9wb3NhbFByb2R1Y2VyUmV2YWxpZGF0aW9uT2JzZXJ2YXRpb24iLAogICAgICAgICAgICAgICAgIlByaW1lTGF0aW5Qcm9wb3NhbEluZGVwZW5kZW50UmVwbGF5IiwKICAgICAgICAgICAgICAgICJQcmltZUxhdGluUHJvcG9zYWxWYWxpZGF0aW9uQ29tcG9zaXRpb24iLAogICAgICAgICAgICAgICAgIlByaW1lTGF0aW5Qcm9wb3NhbFZhbGlkYXRpb25Db21wb3NpdGlvblJlY2VpcHQiLAogICAgICAgICAgICAgICAgIlByaW1lTGF0aW5Qcm9wb3NhbFZhbGlkYXRpb25Db21wb3NpdGlvblJlY2VpcHRQdWJsaXNoZXIiLAogICAgICAgICAgICAgICAgIlByaW1lTGF0aW5Qcm9wb3NhbEFkbWlzc2lvblBvbGljeSIsCiAgICAgICAgICAgIF0KICAgICAgICApLAo=")
        ]),
        // 7c3989bd0e448eddf3b8b8b87d83c90f518a7d0c → 2ee5de6dddafa03ed6e2c1effedc060dea7c32ff
        .init(path: "Package.resolved", historicalByteCount: 1182,
            historicalSHA256: "da7f7baa10f6da34b01ad69dc116f8a2d31140eca6770cb562ac05a7c50b356c", currentByteCount: 645,
            currentSHA256: "bd7a18ec5b8def3b453d7eb86ba43a2f277c2308c9da806845b69ca5f76cd375", edits: [
            .init(historicalOffset: 2, currentOffset: 2,
                removedBase64: "ICAib3JpZ2luSGFzaCIgOiAiNDNiOGIxYTg4N2Y2ZjYxZDBkZDJjNWFmYzExOGU5NDFiOTA0ZWU3Zjk2YWVkYjExZTAwMDBhMzc4ODcyYzhjYyIsCg==",
                insertedBase64: "ICAib3JpZ2luSGFzaCIgOiAiYmM4ODk0MzZmYjE2N2NjMjA2YWE4N2NiMDc5ZGE0ODg4YTdmZTk1ZTUxN2ViN2NmNjNjYmY0NGIzNWRjMjdjMiIsCg=="),
            .init(historicalOffset: 186, currentOffset: 186,
                removedBase64: "ICAgICAgImxvY2F0aW9uIiA6ICJodHRwczovL2dpdGh1Yi5jb20vbWwtZXhwbG9yZS9tbHgtc3dpZnQiLAo=",
                insertedBase64: "ICAgICAgImxvY2F0aW9uIiA6ICJodHRwczovL2dpdGh1Yi5jb20vRXJnZW50aWNzL2VyZ2VudGljcy1tbHgtc3dpZnQiLAo="),
            .init(historicalOffset: 345, currentOffset: 354,
                removedBase64: "ICAgIHsKICAgICAgImlkZW50aXR5IiA6ICJtbHgtc3dpZnQtbG0iLAogICAgICAia2luZCIgOiAicmVtb3RlU291cmNlQ29udHJvbCIsCiAgICAgICJsb2NhdGlvbiIgOiAiaHR0cHM6Ly9naXRodWIuY29tL21sLWV4cGxvcmUvbWx4LXN3aWZ0LWxtIiwKICAgICAgInN0YXRlIiA6IHsKICAgICAgICAicmV2aXNpb24iIDogIjFjMDUyNDhiYjA4OTllMmE3YTQ5NjJiODRkMzE5Y2YxMmY0ZTEyYWEiLAogICAgICAgICJ2ZXJzaW9uIiA6ICIzLjMxLjMiCiAgICAgIH0KICAgIH0sCg==",
                insertedBase64: ""),
            .init(historicalOffset: 878, currentOffset: 616,
                removedBase64: "ICAgIH0sCiAgICB7CiAgICAgICJpZGVudGl0eSIgOiAic3dpZnQtc3ludGF4IiwKICAgICAgImtpbmQiIDogInJlbW90ZVNvdXJjZUNvbnRyb2wiLAogICAgICAibG9jYXRpb24iIDogImh0dHBzOi8vZ2l0aHViLmNvbS9zd2lmdGxhbmcvc3dpZnQtc3ludGF4LmdpdCIsCiAgICAgICJzdGF0ZSIgOiB7CiAgICAgICAgInJldmlzaW9uIiA6ICIwNjg3ZjcxOTQ0MDIxZDYxNmQzNGQ5MjIzNDNkY2VmMDg2ODU1OTIwIiwKICAgICAgICAidmVyc2lvbiIgOiAiNjAwLjAuMSIKICAgICAgfQo=",
                insertedBase64: "")
        ]),
        // 2ee5de6dddafa03ed6e2c1effedc060dea7c32ff → exact historical-identity read adapter
        .init(path: "Tests/PrimeCoreTests/PrimeNativeNeuralGateHistoricalWorkerExportedEvidenceProjectionDecodeCompositionCallEdgeSourceContractTests.swift", historicalByteCount: 22674,
            historicalSHA256: "bfdfe2282192f45ddde57bbcbbec79fdce392ca2853d3b8b977578b45c88fc04", currentByteCount: 22880,
            currentSHA256: "38897877906e721d2abc242bd46abe75370b2c23caf288441025b4b578c6f820", edits: [
            .init(historicalOffset: 5805, currentOffset: 5805,
                removedBase64: "ICAgICAgICAgICAgbGV0IGRhdGEgPSB0cnkgY2hlY2tlZEluRGF0YShpZGVudGl0eS5wcmltZVJlbGF0aXZlUGF0aCkK",
                insertedBase64: "ICAgICAgICAgICAgbGV0IGRhdGEgPSB0cnkgUHJpbWVIaXN0b3JpY2FsU291cmNlRXZvbHV0aW9uVGVzdFN1cHBvcnQuaGlzdG9yaWNhbERhdGEoCiAgICAgICAgICAgICAgICBwYXRoOiBpZGVudGl0eS5wcmltZVJlbGF0aXZlUGF0aCwgY3VycmVudDogY2hlY2tlZEluRGF0YShpZGVudGl0eS5wcmltZVJlbGF0aXZlUGF0aCksCiAgICAgICAgICAgICAgICBleHBlY3RlZEJ5dGVDb3VudDogaWRlbnRpdHkuYnl0ZUNvdW50LCBleHBlY3RlZFNIQTI1NjogaWRlbnRpdHkuc2hhMjU2KQo=")
        ]),
        // 2ee5de6dddafa03ed6e2c1effedc060dea7c32ff → exact historical-identity read adapter
        .init(path: "Tests/PrimeCoreTests/PrimeNativeNeuralGateHistoricalWorkerInvocationSeamDesignContractTests.swift", historicalByteCount: 21969,
            historicalSHA256: "06ab036c190ab18a702dea80a6f75e9a0f41ce92bd0b2b061fa97dccf2ad92e6", currentByteCount: 22135,
            currentSHA256: "3d253b17b3787d3a51aec4c35a7a93ab2290a4d4e84d746d3f541fb76ce0f66d", edits: [
            .init(historicalOffset: 2456, currentOffset: 2456,
                removedBase64: "ICAgICAgICAgICAgbGV0IGRhdGEgPSB0cnkgY2hlY2tlZEluRGF0YShwYXRoKQo=",
                insertedBase64: "ICAgICAgICAgICAgbGV0IGRhdGEgPSB0cnkgUHJpbWVIaXN0b3JpY2FsU291cmNlRXZvbHV0aW9uVGVzdFN1cHBvcnQuaGlzdG9yaWNhbERhdGEoCiAgICAgICAgICAgICAgICBwYXRoOiBwYXRoLCBjdXJyZW50OiBjaGVja2VkSW5EYXRhKHBhdGgpLAogICAgICAgICAgICAgICAgZXhwZWN0ZWRCeXRlQ291bnQ6IGJ5dGVDb3VudCwgZXhwZWN0ZWRTSEEyNTY6IHNoYTI1NikK")
        ]),
        // 2ee5de6dddafa03ed6e2c1effedc060dea7c32ff → exact historical-identity read adapter
        .init(path: "Tests/PrimeCoreTests/PrimeNativeNeuralGateHistoricalWorkerInvocationSeamSourceContractTests.swift", historicalByteCount: 33756,
            historicalSHA256: "6b29947654a68154a91623335d0a887b306a57baf17845c35484bff1cd0a2e8c", currentByteCount: 33962,
            currentSHA256: "e2957f8466d9cb9361b74e1547c3c95ee6fa7a3a7996110d6cdb99b4bd134951", edits: [
            .init(historicalOffset: 3993, currentOffset: 3993,
                removedBase64: "ICAgICAgICAgICAgbGV0IGRhdGEgPSB0cnkgY2hlY2tlZEluRGF0YShpZGVudGl0eS5wcmltZVJlbGF0aXZlUGF0aCkK",
                insertedBase64: "ICAgICAgICAgICAgbGV0IGRhdGEgPSB0cnkgUHJpbWVIaXN0b3JpY2FsU291cmNlRXZvbHV0aW9uVGVzdFN1cHBvcnQuaGlzdG9yaWNhbERhdGEoCiAgICAgICAgICAgICAgICBwYXRoOiBpZGVudGl0eS5wcmltZVJlbGF0aXZlUGF0aCwgY3VycmVudDogY2hlY2tlZEluRGF0YShpZGVudGl0eS5wcmltZVJlbGF0aXZlUGF0aCksCiAgICAgICAgICAgICAgICBleHBlY3RlZEJ5dGVDb3VudDogaWRlbnRpdHkuYnl0ZUNvdW50LCBleHBlY3RlZFNIQTI1NjogaWRlbnRpdHkuc2hhMjU2KQo=")
        ]),
        // 2ee5de6dddafa03ed6e2c1effedc060dea7c32ff → exact historical-identity read adapter
        .init(path: "Tests/PrimeCoreTests/PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerDesignContractTests.swift", historicalByteCount: 30344,
            historicalSHA256: "b5b3acfec3b8179d46d9c8f01a50b17c4abd88dd119c625c1ad5773ee938e522", currentByteCount: 30550,
            currentSHA256: "17f2c0e6f9950570508fc0cc12f81196e8a27885df5c45668cccf9f18a2bf691", edits: [
            .init(historicalOffset: 2055, currentOffset: 2055,
                removedBase64: "ICAgICAgICAgICAgbGV0IGRhdGEgPSB0cnkgY2hlY2tlZEluRGF0YShpZGVudGl0eS5wcmltZVJlbGF0aXZlUGF0aCkK",
                insertedBase64: "ICAgICAgICAgICAgbGV0IGRhdGEgPSB0cnkgUHJpbWVIaXN0b3JpY2FsU291cmNlRXZvbHV0aW9uVGVzdFN1cHBvcnQuaGlzdG9yaWNhbERhdGEoCiAgICAgICAgICAgICAgICBwYXRoOiBpZGVudGl0eS5wcmltZVJlbGF0aXZlUGF0aCwgY3VycmVudDogY2hlY2tlZEluRGF0YShpZGVudGl0eS5wcmltZVJlbGF0aXZlUGF0aCksCiAgICAgICAgICAgICAgICBleHBlY3RlZEJ5dGVDb3VudDogaWRlbnRpdHkuYnl0ZUNvdW50LCBleHBlY3RlZFNIQTI1NjogaWRlbnRpdHkuc2hhMjU2KQo=")
        ]),
        // 2ee5de6dddafa03ed6e2c1effedc060dea7c32ff → exact historical-identity read adapter
        .init(path: "Tests/PrimeCoreTests/PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerSourceContractTests.swift", historicalByteCount: 34735,
            historicalSHA256: "40db1438d8b5fc3a283c4516fccaf70ccb560fde5cdb586af7d838bcf74110f9", currentByteCount: 34941,
            currentSHA256: "9e5b3f81de423232466db4db9a507a4c74acc535077686edc78a96cd153a2899", edits: [
            .init(historicalOffset: 4932, currentOffset: 4932,
                removedBase64: "ICAgICAgICAgICAgbGV0IGRhdGEgPSB0cnkgY2hlY2tlZEluRGF0YShpZGVudGl0eS5wcmltZVJlbGF0aXZlUGF0aCkK",
                insertedBase64: "ICAgICAgICAgICAgbGV0IGRhdGEgPSB0cnkgUHJpbWVIaXN0b3JpY2FsU291cmNlRXZvbHV0aW9uVGVzdFN1cHBvcnQuaGlzdG9yaWNhbERhdGEoCiAgICAgICAgICAgICAgICBwYXRoOiBpZGVudGl0eS5wcmltZVJlbGF0aXZlUGF0aCwgY3VycmVudDogY2hlY2tlZEluRGF0YShpZGVudGl0eS5wcmltZVJlbGF0aXZlUGF0aCksCiAgICAgICAgICAgICAgICBleHBlY3RlZEJ5dGVDb3VudDogaWRlbnRpdHkuYnl0ZUNvdW50LCBleHBlY3RlZFNIQTI1NjogaWRlbnRpdHkuc2hhMjU2KQo=")
        ]),
        // 2ee5de6dddafa03ed6e2c1effedc060dea7c32ff → exact historical-identity read adapter
        .init(path: "Tests/PrimeCoreTests/PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingDesignContractTests.swift", historicalByteCount: 32076,
            historicalSHA256: "9b1d961ab9ea87ef8b57b032ba4f781b295d9c35a48659e28e9ca30e73e6ac4c", currentByteCount: 32282,
            currentSHA256: "7b4d9b4fea4e87413ec51dd0971aba71e597ac62a29f16dc28170e88bafc2c5e", edits: [
            .init(historicalOffset: 3502, currentOffset: 3502,
                removedBase64: "ICAgICAgICAgICAgbGV0IGRhdGEgPSB0cnkgY2hlY2tlZEluRGF0YShpZGVudGl0eS5wcmltZVJlbGF0aXZlUGF0aCkK",
                insertedBase64: "ICAgICAgICAgICAgbGV0IGRhdGEgPSB0cnkgUHJpbWVIaXN0b3JpY2FsU291cmNlRXZvbHV0aW9uVGVzdFN1cHBvcnQuaGlzdG9yaWNhbERhdGEoCiAgICAgICAgICAgICAgICBwYXRoOiBpZGVudGl0eS5wcmltZVJlbGF0aXZlUGF0aCwgY3VycmVudDogY2hlY2tlZEluRGF0YShpZGVudGl0eS5wcmltZVJlbGF0aXZlUGF0aCksCiAgICAgICAgICAgICAgICBleHBlY3RlZEJ5dGVDb3VudDogaWRlbnRpdHkuYnl0ZUNvdW50LCBleHBlY3RlZFNIQTI1NjogaWRlbnRpdHkuc2hhMjU2KQo=")
        ])
    ]
}
