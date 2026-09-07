// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin
import Foundation
@_spi(PrimeValidationDriverV2RoleFacade) @testable import PrimeCore
import XCTest

/// Exercises actual private directories and files only. A staging utility and
/// these fixture journal bytes do not construct a native inventory owner.
final class PrimeValidationDriverV2InventoryStagingTests: XCTestCase {
    func testBindingFrameUsesProductionKeyOrderAndExactUnsignedIntegers() throws {
        struct Frame: Encodable {
            let exitStatus: Int = 0
            let exitedNormally: Bool = true
            let highest: UInt64 = .max
            let nested: [String: String] = ["key10": "ten", "key2": "two", "path": "/private/tmp"]
        }
        let canonical = try PrimeCanonicalJSON.encode(Frame())
        XCTAssertNoThrow(try PrimeValidationDriverV2CanonicalBindingFrame.validate(canonical))
        let object = try JSONSerialization.jsonObject(with: canonical)
        let alternate = try JSONSerialization.data(withJSONObject: object,
            options: [.sortedKeys, .withoutEscapingSlashes])
        XCTAssertNotEqual(alternate, canonical, "Regresses the two Foundation encoders' different key collation")
        for bytes in [alternate, canonical + Data([0x0a]), Data("{\"x\":1,\"x\":2}".utf8),
                      Data("[]".utf8), Data("{\"value\":1.5}".utf8)] {
            XCTAssertThrowsError(try PrimeValidationDriverV2CanonicalBindingFrame.validate(bytes))
        }
    }

    func testExactLeavesAreExclusiveAndTraversalCannotTouchOutsideFile() throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let stage = fixture.stage
        for leaf in ["../outside", "xctest-list.stdout.log/child", "stdout.log", "binding.json"] {
            XCTAssertThrowsError(try stage.createStream(leaf))
        }
        let descriptor = try stage.createStream("xctest-list.stdout.log")
        defer { close(descriptor) }
        XCTAssertThrowsError(try stage.createStream("xctest-list.stdout.log"))
        let binding = try stage.publish(Fixture.Record(value: "fixture only"),
            leaf: "01-xctest-prestart.json")
        XCTAssertEqual(binding.purpose, .immutableData)
        XCTAssertEqual(try stage.root.readVerified(binding),
            try PrimeCanonicalJSON.encode(Fixture.Record(value: "fixture only")))
        XCTAssertThrowsError(try stage.publish(Fixture.Record(value: "replacement"),
            leaf: "01-xctest-prestart.json"))
        XCTAssertThrowsError(try stage.publish(Fixture.Record(value: "outside"), leaf: "../outside"))
        XCTAssertNoThrow(try stage.revalidate())
        XCTAssertEqual(try fixture.names(), ["01-xctest-prestart.json", "xctest-list.stdout.log"])
        XCTAssertEqual(try Data(contentsOf: fixture.outside), fixture.outsideBytes)
    }

    func testSameNameStreamReplacementRejectsDespiteSameModeAndLength() throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let output = try fixture.stage.createStream("xctest-list.stdout.log")
        defer { close(output) }
        let parent = fixture.directory.descriptor
        XCTAssertEqual(renameat(parent, "xctest-list.stdout.log", parent, "away"), 0)
        let replacement = openat(parent, "xctest-list.stdout.log",
            O_RDWR | O_CREAT | O_EXCL | O_CLOEXEC | O_NOFOLLOW, 0o600)
        guard replacement >= 3 else { throw Fixture.posixError() }
        defer { close(replacement) }
        XCTAssertEqual(unlinkat(parent, "away", 0), 0)
        XCTAssertThrowsError(try fixture.stage.revalidate())
        XCTAssertEqual(try Data(contentsOf: fixture.outside), fixture.outsideBytes)
    }

    func testPublishedRecordCannotBeChangedThroughNewWriter() throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let record = try fixture.stage.publish(Fixture.Record(value: "original"),
            leaf: "01-xctest-prestart.json")
        let parent = fixture.directory.descriptor
        XCTAssertEqual(fchmodat(parent, record.relativePath, 0o600, 0), 0)
        let writer = openat(parent, record.relativePath, O_WRONLY | O_NOFOLLOW | O_CLOEXEC)
        guard writer >= 3 else { throw Fixture.posixError() }
        defer { close(writer) }
        var changed: UInt8 = 0x5b
        XCTAssertEqual(pwrite(writer, &changed, 1, 0), 1)
        XCTAssertEqual(fchmod(writer, 0o444), 0)
        XCTAssertEqual(fsync(writer), 0)
        XCTAssertThrowsError(try fixture.stage.revalidate())
    }

    func testUnexpectedSymlinkLeafRejectsWithoutFollowingTarget() throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        XCTAssertEqual(symlinkat(fixture.outside.path, fixture.directory.descriptor,
                                "xctest-list.stderr.log"), 0)
        XCTAssertThrowsError(try fixture.stage.createStream("xctest-list.stderr.log"))
        XCTAssertThrowsError(try fixture.stage.revalidate())
        XCTAssertEqual(try Data(contentsOf: fixture.outside), fixture.outsideBytes)
    }

    func testBindingCannotPublishBeforeBothCompleteChildRecordsAndStreams() throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let bytes = try PrimeCanonicalJSON.encode(Fixture.Record(value: "not authority"))
        XCTAssertThrowsError(try fixture.stage.publishBindingData(bytes))
        XCTAssertEqual(try fixture.names(), [])
        try fixture.stage.publish(Fixture.Record(value: "fixture terminal"), leaf: "terminal.json")
        XCTAssertThrowsError(try fixture.stage.publishBindingData(bytes))
        XCTAssertEqual(try fixture.names(), ["terminal.json"])
    }

    func testFrozenDirectoryRejectsTransientNameChangeEvenAfterRestoration() throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        try fixture.stage.publish(Fixture.Record(value: "stable"), leaf: "01-xctest-prestart.json")
        let parent = fixture.directory.descriptor
        XCTAssertEqual(renameat(parent, "01-xctest-prestart.json", parent, "away"), 0)
        XCTAssertEqual(renameat(parent, "away", parent, "01-xctest-prestart.json"), 0)
        XCTAssertThrowsError(try fixture.stage.revalidate())
    }

    func testFixedLeafSetsContainOnlyTwoRolesAndOneSequenceTerminal() {
        XCTAssertEqual(PrimeValidationDriverV2InventoryStaging.streamLeaves.count, 4)
        XCTAssertEqual(PrimeValidationDriverV2InventoryStaging.recordLeaves.count, 7)
        XCTAssertTrue(PrimeValidationDriverV2InventoryStaging.streamLeaves
            .isDisjoint(with: PrimeValidationDriverV2InventoryStaging.recordLeaves))
        XCTAssertFalse(PrimeValidationDriverV2InventoryStaging.recordLeaves.contains("binding.json"))
    }

    private final class Fixture {
        struct Record: Codable { let value: String }
        let base: URL
        let outside: URL
        let outsideBytes = Data("outside inventory namespace\n".utf8)
        let parentRoot: PrimeArtifactRoot
        let parent: Int32
        let directory: PrimeValidationDriverV2BuildStaging.Directory
        let stage: PrimeValidationDriverV2InventoryStaging

        init() throws {
            var pattern = Array("/private/tmp/prime-inventory-staging-tests-XXXXXX".utf8CString)
            guard let temporary = mkdtemp(&pattern) else { throw Self.posixError() }
            base = URL(fileURLWithPath: String(cString: temporary), isDirectory: true)
            outside = base.appendingPathComponent("outside")
            var retainedParent: Int32 = -1
            do {
                try outsideBytes.write(to: outside, options: .withoutOverwriting)
                parentRoot = try PrimeArtifactRoot(directoryURL: base)
                parent = try parentRoot.duplicateTrustedRootDescriptorForInventory()
                retainedParent = parent
                let predecessor = try parentRoot.publishCanonicalExclusively(
                    Record(value: "filesystem fixture predecessor; no native authority"), at: "binding.json")
                directory = try PrimeValidationDriverV2BuildStaging.Directory.create(
                    parent: parent, leaf: "inventory", path: base.appendingPathComponent("inventory").path)
                try directory.freezeMetadata()
                stage = try PrimeValidationDriverV2InventoryStaging(
                    directory: directory, predecessorBuildBinding: predecessor)
            } catch {
                if retainedParent >= 0 { close(retainedParent) }
                try? FileManager.default.removeItem(at: base)
                throw error
            }
        }
        deinit { close(parent) }
        func cleanup() { try? FileManager.default.removeItem(at: base) }
        func names() throws -> [String] {
            try FileManager.default.contentsOfDirectory(atPath: directory.path).sorted()
        }
        static func posixError() -> POSIXError {
            POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO)
        }
    }
}
