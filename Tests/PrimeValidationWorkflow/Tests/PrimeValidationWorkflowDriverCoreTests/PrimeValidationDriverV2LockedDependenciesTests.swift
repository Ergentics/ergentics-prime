// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin
import Dispatch
import Foundation
@_spi(PrimeValidationDriverV2RoleFacade) @testable import PrimeCore
import XCTest

/// Actual held-filesystem fixtures. These tests copy the source-sealed bare
/// repository bytes but never run Git, SwiftPM, a workload, or a model.
final class PrimeValidationDriverV2LockedDependenciesTests: XCTestCase {
    func testExactPinnedSourcesPublishOnlyTwoCanonicalLocalMirrors() throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let owner = try fixture.prepare()
        try owner.revalidate()
        let data = try Data(contentsOf: fixture.mirrors)
        XCTAssertEqual(data, try PrimeValidationDriverV2LockedDependencies.mirrorsData(
            primeRootAbsolutePath: fixture.prime.path))
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(object["version"] as? Int, 1)
        let mirrors = try XCTUnwrap(object["object"] as? [[String: String]])
        XCTAssertEqual(mirrors.map { $0["original"]! }, [
            "https://github.com/Ergentics/ergentics-mlx-swift",
            "https://github.com/apple/swift-numerics",
        ])
        XCTAssertTrue(mirrors.allSatisfy { $0["mirror"]!.hasPrefix("file://" + fixture.prime.path + "/") })
        var metadata = stat()
        XCTAssertEqual(lstat(fixture.mirrors.path, &metadata), 0)
        XCTAssertEqual(metadata.st_mode & 0o7777, 0o444)
        XCTAssertEqual(metadata.st_nlink, 1)
        XCTAssertEqual(try FileManager.default.contentsOfDirectory(atPath: fixture.config.path), ["mirrors.json"])
        for file in fixture.snapshot.files {
            XCTAssertEqual(try Data(contentsOf: fixture.prime.appendingPathComponent(file.relativePath)), file.contents)
        }
        XCTAssertEqual(try Data(contentsOf: fixture.outside), fixture.outsideBytes)
    }

    func testPreexistingMirrorsAreNeverOverwritten() throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        try fixture.outsideBytes.write(to: fixture.mirrors, options: .withoutOverwriting)
        XCTAssertThrowsError(try fixture.prepare())
        XCTAssertEqual(try Data(contentsOf: fixture.mirrors), fixture.outsideBytes)
    }

    func testMirrorSameNameReplacementRejects() throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let owner = try fixture.prepare()
        let bytes = try Data(contentsOf: fixture.mirrors)
        let away = fixture.config.appendingPathComponent("old-mirrors")
        XCTAssertEqual(rename(fixture.mirrors.path, away.path), 0)
        try bytes.write(to: fixture.mirrors, options: .withoutOverwriting)
        XCTAssertEqual(chmod(fixture.mirrors.path, 0o444), 0)
        try FileManager.default.removeItem(at: away)
        XCTAssertThrowsError(try owner.revalidate())
        XCTAssertEqual(try Data(contentsOf: fixture.outside), fixture.outsideBytes)
    }

    func testMirrorMutationAndRestorationPermanentlyPoisonHeldOwner() throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let owner = try fixture.prepare()
        let original = try Data(contentsOf: fixture.mirrors)
        XCTAssertEqual(chmod(fixture.mirrors.path, 0o600), 0)
        let writer = open(fixture.mirrors.path, O_WRONLY | O_NOFOLLOW | O_CLOEXEC)
        guard writer >= 3 else { throw Fixture.posixError() }
        defer { close(writer) }
        var byte: UInt8 = 0x5b
        XCTAssertEqual(pwrite(writer, &byte, 1, 0), 1)
        XCTAssertEqual(fchmod(writer, 0o444), 0)
        XCTAssertThrowsError(try owner.revalidate())
        XCTAssertEqual(original.withUnsafeBytes { pwrite(writer, $0.baseAddress, $0.count, 0) }, original.count)
        XCTAssertThrowsError(try owner.revalidate())
    }

    func testChangedSourcePinAndUnexpectedEmptyDirectoryRejectBeforePublication() throws {
        do {
            let fixture = try Fixture()
            defer { fixture.cleanup() }
            let path = fixture.prime.appendingPathComponent(fixture.snapshot.files[0].relativePath)
            var bytes = try Data(contentsOf: path)
            bytes[bytes.startIndex] ^= 1
            try bytes.write(to: path)
            XCTAssertThrowsError(try fixture.prepare())
            XCTAssertFalse(FileManager.default.fileExists(atPath: fixture.mirrors.path))
        }
        do {
            let fixture = try Fixture()
            defer { fixture.cleanup() }
            let path = fixture.prime.appendingPathComponent(
                PrimeValidationDriverV2LockedDependencies.sourcePrefix + "/ergentics-mlx-swift/hooks")
            try FileManager.default.createDirectory(at: path, withIntermediateDirectories: false)
            XCTAssertThrowsError(try fixture.prepare())
            XCTAssertFalse(FileManager.default.fileExists(atPath: fixture.mirrors.path))
        }
    }

    func testSourceSymlinkAndHardlinkRejectWithoutTouchingOutsideTarget() throws {
        for hardlink in [false, true] {
            let fixture = try Fixture()
            defer { fixture.cleanup() }
            let path = fixture.prime.appendingPathComponent(fixture.snapshot.files[0].relativePath)
            try FileManager.default.removeItem(at: path)
            XCTAssertEqual(hardlink ? link(fixture.outside.path, path.path) : symlink(fixture.outside.path, path.path), 0)
            XCTAssertThrowsError(try fixture.prepare())
            XCTAssertEqual(try Data(contentsOf: fixture.outside), fixture.outsideBytes)
            XCTAssertFalse(FileManager.default.fileExists(atPath: fixture.mirrors.path))
        }
    }

    func testSnapshotMustBindAllThirteenExactFiles() throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let original = fixture.snapshot.files
        let missing = fixture.makeSnapshot(Array(original.dropLast()))
        XCTAssertThrowsError(try PrimeValidationDriverV2LockedDependencies.validateSnapshot(missing))
        let duplicate = fixture.makeSnapshot(Array(original.dropLast()) + [original[0]])
        XCTAssertThrowsError(try PrimeValidationDriverV2LockedDependencies.validateSnapshot(duplicate))
        var wrong = original
        wrong[0] = .init(relativePath: wrong[0].relativePath, sha256: wrong[0].sha256,
            byteCount: wrong[0].byteCount, contents: Data(repeating: 0, count: wrong[0].contents.count))
        XCTAssertThrowsError(try PrimeValidationDriverV2LockedDependencies.validateSnapshot(fixture.makeSnapshot(wrong)))
        XCTAssertFalse(FileManager.default.fileExists(atPath: fixture.mirrors.path))
    }

    func testSourceMetadataDriftAndConfigInjectionRejectAfterCapture() throws {
        do {
            let fixture = try Fixture()
            defer { fixture.cleanup() }
            let owner = try fixture.prepare()
            let path = fixture.prime.appendingPathComponent(fixture.snapshot.files[0].relativePath)
            XCTAssertEqual(chmod(path.path, 0o600), 0)
            XCTAssertEqual(chmod(path.path, 0o644), 0)
            XCTAssertThrowsError(try owner.revalidate())
        }
        do {
            let fixture = try Fixture()
            defer { fixture.cleanup() }
            let owner = try fixture.prepare()
            try Data("unexpected".utf8).write(to: fixture.config.appendingPathComponent("registries.json"))
            XCTAssertThrowsError(try owner.revalidate())
        }
    }

    func testIndependentInputReaderJoinsMirrorsOnceAndRetainsBothBaselines() throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let reader = try fixture.reader()
        try reader.revalidate()
        try reader.checkpointMetadata()
        let owner = try fixture.prepare()
        let workspace = try fixture.workspaceRoot.duplicateTrustedRootDescriptorForInventory()
        defer { close(workspace) }
        try reader.bindExistingMirrors(workspaceRootDescriptor: workspace)
        try reader.revalidateBoundMirrors()
        try reader.checkpointMetadata()
        try owner.revalidate()
        XCTAssertThrowsError(try reader.bindExistingMirrors(workspaceRootDescriptor: workspace))
        XCTAssertThrowsError(try reader.revalidateBoundMirrors())
    }

    func testIndependentReaderRejectsInputChangeBeforeMirrorJoin() throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let reader = try fixture.reader()
        let path = fixture.prime.appendingPathComponent(fixture.snapshot.files[0].relativePath)
        XCTAssertEqual(chmod(path.path, 0o600), 0)
        XCTAssertEqual(chmod(path.path, 0o644), 0)
        XCTAssertThrowsError(try reader.revalidate())
        XCTAssertThrowsError(try reader.checkpointMetadata())
    }

    func testIndependentReaderRejectsWrongMirrorMappingAndMissingJoin() throws {
        do {
            let fixture = try Fixture()
            defer { fixture.cleanup() }
            let reader = try fixture.reader()
            try Data("{\"object\":[],\"version\":1}".utf8).write(to: fixture.mirrors)
            XCTAssertEqual(chmod(fixture.mirrors.path, 0o444), 0)
            let workspace = try fixture.workspaceRoot.duplicateTrustedRootDescriptorForInventory()
            defer { close(workspace) }
            XCTAssertThrowsError(try reader.bindExistingMirrors(workspaceRootDescriptor: workspace))
            XCTAssertThrowsError(try reader.revalidate())
        }
        do {
            let fixture = try Fixture()
            defer { fixture.cleanup() }
            let reader = try fixture.reader()
            XCTAssertThrowsError(try reader.revalidateBoundMirrors())
        }
    }

    func testIndependentReaderRejectsExpiredDeadlineAndWrongRootPath() throws {
        for path in ["/", "/private//tmp", "/private/./tmp", "/private/../tmp", "/private/tmp/"] {
            XCTAssertThrowsError(try PrimeValidationDriverV2LockedDependencies.mirrorsData(primeRootAbsolutePath: path))
        }
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let prime = try fixture.primeRoot.duplicateTrustedRootDescriptorForInventory()
        defer { close(prime) }
        XCTAssertThrowsError(try PrimeValidationDriverV2LockedDependencyReadback.capture(
            primeRootDescriptor: prime, primeRootAbsolutePath: fixture.prime.path, deadlineNanoseconds: 0))
        XCTAssertThrowsError(try PrimeValidationDriverV2LockedDependencyReadback.capture(
            primeRootDescriptor: prime, primeRootAbsolutePath: fixture.workspace.path,
            deadlineNanoseconds: DispatchTime.now().uptimeNanoseconds + 60_000_000_000))
    }

    private final class Fixture {
        let base: URL, prime: URL, workspace: URL, config: URL, mirrors: URL, outside: URL
        let outsideBytes = Data("outside fixed dependency mirror scope\n".utf8)
        let primeRoot: PrimeArtifactRoot, workspaceRoot: PrimeArtifactRoot
        let snapshot: PrimeSwiftSourceSnapshot

        init() throws {
            var pattern = Array("/private/tmp/prime-locked-dependencies-tests-XXXXXX".utf8CString)
            guard let temporary = mkdtemp(&pattern) else { throw Self.posixError() }
            base = URL(fileURLWithPath: String(cString: temporary), isDirectory: true)
            prime = base.appendingPathComponent("prime")
            workspace = base.appendingPathComponent("workspace")
            config = workspace.appendingPathComponent("config")
            mirrors = config.appendingPathComponent("mirrors.json")
            outside = base.appendingPathComponent("outside")
            do {
                for path in [prime, workspace, config] {
                    try FileManager.default.createDirectory(at: path, withIntermediateDirectories: false,
                        attributes: [.posixPermissions: 0o700])
                }
                var repository = URL(fileURLWithPath: #filePath)
                for _ in 0..<5 { repository.deleteLastPathComponent() }
                var files = [PrimeSwiftSourceFileSnapshot]()
                for spec in PrimeValidationDriverV2LockedDependencies.specifications {
                    let data = try Data(contentsOf: repository.appendingPathComponent(spec.path))
                    guard UInt64(data.count) == spec.count, PrimeSHA256.hexDigest(of: data) == spec.hash else {
                        throw POSIXError(.EINVAL)
                    }
                    let destination = prime.appendingPathComponent(spec.path)
                    try FileManager.default.createDirectory(at: destination.deletingLastPathComponent(),
                        withIntermediateDirectories: true, attributes: [.posixPermissions: 0o755])
                    try data.write(to: destination, options: .withoutOverwriting)
                    guard chmod(destination.path, 0o644) == 0 else { throw Self.posixError() }
                    files.append(.init(relativePath: spec.path, sha256: spec.hash,
                                       byteCount: spec.count, contents: data))
                }
                try outsideBytes.write(to: outside, options: .withoutOverwriting)
                primeRoot = try PrimeArtifactRoot(directoryURL: prime)
                workspaceRoot = try PrimeArtifactRoot(directoryURL: workspace)
                snapshot = PrimeSwiftSourceSnapshot(sourceIdentitySHA256: String(repeating: "0", count: 64),
                    embeddedSourceIdentitySHA256: String(repeating: "0", count: 64),
                    buildConfiguration: "release", files: files)
            } catch {
                try? FileManager.default.removeItem(at: base)
                throw error
            }
        }
        func prepare() throws -> PrimeValidationDriverV2LockedDependencies {
            try PrimeValidationDriverV2LockedDependencies.prepare(primeRoot: primeRoot,
                sourceSnapshot: snapshot, workspaceRoot: workspaceRoot, primeRootAbsolutePath: prime.path)
        }
        func reader() throws -> PrimeValidationDriverV2LockedDependencyReadback {
            let prime = try primeRoot.duplicateTrustedRootDescriptorForInventory()
            defer { close(prime) }
            return try .capture(primeRootDescriptor: prime, primeRootAbsolutePath: self.prime.path,
                deadlineNanoseconds: DispatchTime.now().uptimeNanoseconds + 120_000_000_000)
        }
        func makeSnapshot(_ files: [PrimeSwiftSourceFileSnapshot]) -> PrimeSwiftSourceSnapshot {
            .init(sourceIdentitySHA256: snapshot.sourceIdentitySHA256,
                  embeddedSourceIdentitySHA256: snapshot.embeddedSourceIdentitySHA256,
                  buildConfiguration: snapshot.buildConfiguration, files: files)
        }
        func cleanup() { try? FileManager.default.removeItem(at: base) }
        static func posixError() -> POSIXError { POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO) }
    }
}
