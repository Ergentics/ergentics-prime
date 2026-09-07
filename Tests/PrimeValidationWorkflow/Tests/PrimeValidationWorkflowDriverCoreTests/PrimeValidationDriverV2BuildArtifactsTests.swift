// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CryptoKit
import Darwin
import Dispatch
import Foundation
@_spi(PrimeValidationDriverV2RoleFacade) @testable import PrimeCore
import XCTest

/// Native filesystem fixtures only. The bytes marked executable are never
/// launched; the metallib bytes are deliberately not a Metal library.
final class PrimeValidationDriverV2BuildArtifactsTests: XCTestCase {
    func testActualExclusiveCopyCanonicalRoundTripAndRetainedReadback() throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let capture = try fixture.capture()
        let observation = capture.observation
        XCTAssertTrue(observation.exclusivePublicationObserved)
        XCTAssertTrue(observation.durableSynchronizationObserved)
        XCTAssertTrue(observation.sourceNamesAndDescriptorsRejoined)
        XCTAssertEqual(observation.capturedBundleRelativePath, "test-bundle")
        XCTAssertEqual(observation.metallibSHA256, fixture.metallibSHA256)
        XCTAssertEqual(observation.metallibByteCount, UInt64(fixture.metallibBytes.count))
        XCTAssertEqual(observation.immutableArtifactBindings.count, 4)
        XCTAssertEqual(observation.bundleEntries.filter { $0.kind == "directory" }.count, 4)
        XCTAssertEqual(observation.bundleEntries.filter { $0.kind == "executable" }.count, 1)
        XCTAssertTrue(observation.bundleEntries.contains {
            $0.relativePath == "Contents/Resources/Empty" && $0.byteCount == nil && $0.sha256 == nil
        })
        for binding in observation.immutableArtifactBindings {
            let verified = try fixture.artifactRoot.verify(binding)
            XCTAssertEqual(verified.actualMode, binding.purpose == .executable ? 0o555 : 0o444)
            let bytes = try Data(contentsOf: fixture.artifacts.appendingPathComponent(binding.relativePath))
            XCTAssertEqual(UInt64(bytes.count), binding.byteCount)
            XCTAssertEqual(Fixture.digest(bytes), binding.sha256)
        }
        let encoded = try PrimeCanonicalJSON.encode(observation)
        let decoded = try PrimeCanonicalJSON.decode(
            PrimeValidationDriverV2BuildArtifactsObservation.self, from: encoded)
        XCTAssertEqual(decoded, observation)
        XCTAssertEqual(try PrimeCanonicalJSON.encode(decoded), encoded)
        let reader = try fixture.readback(decoded)
        XCTAssertEqual(try reader.revalidate(), observation)
        XCTAssertNoThrow(try capture.revalidate())
        XCTAssertEqual(try fixture.names(fixture.base), ["artifacts", "outside-sentinel", "workspace"])
        XCTAssertEqual(try fixture.names(fixture.artifacts), ["default.metallib", "test-bundle"])
        XCTAssertEqual(try Data(contentsOf: fixture.outside), fixture.outsideBytes)
    }

    func testSourceFileSymlinkRejectsWithoutReadingOrChangingItsOutsideTarget() throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let linkURL = fixture.bundle.appendingPathComponent("Contents/Resources/alias")
        XCTAssertEqual(symlink(fixture.outside.path, linkURL.path), 0)
        XCTAssertThrowsError(try fixture.capture())
        XCTAssertEqual(try fixture.names(fixture.artifacts), [])
        XCTAssertEqual(try Data(contentsOf: fixture.outside), fixture.outsideBytes)
    }

    func testSourceDirectorySymlinkRejects() throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let alias = fixture.bundle.appendingPathComponent("Contents/linked-directory")
        XCTAssertEqual(symlink(fixture.base.path, alias.path), 0)
        XCTAssertThrowsError(try fixture.capture())
        XCTAssertEqual(try fixture.names(fixture.artifacts), [])
    }

    func testHardlinkedGeneratedFileRejects() throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let alias = fixture.bundle.appendingPathComponent("Contents/Resources/hardlink")
        XCTAssertEqual(link(fixture.outside.path, alias.path), 0)
        XCTAssertThrowsError(try fixture.capture())
        XCTAssertEqual(try fixture.names(fixture.artifacts), [])
        XCTAssertEqual(try Data(contentsOf: fixture.outside), fixture.outsideBytes)
    }

    func testMissingMetallibRejectsBeforePublication() throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        try FileManager.default.removeItem(at: fixture.metallib)
        XCTAssertThrowsError(try fixture.capture())
        XCTAssertEqual(try fixture.names(fixture.artifacts), [])
    }

    func testChangedMetallibBytesCannotSatisfyDeclaredPin() throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        var changed = fixture.metallibBytes
        changed[changed.startIndex] ^= 1
        try fixture.overwrite(fixture.metallib, bytes: changed)
        XCTAssertThrowsError(try fixture.capture())
        XCTAssertEqual(try Data(contentsOf: fixture.outside), fixture.outsideBytes)
    }

    func testPreexistingArtifactRootIsNotReused() throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let marker = fixture.artifacts.appendingPathComponent("preexisting")
        try fixture.write(marker, bytes: Data("preserve".utf8), mode: 0o600)
        XCTAssertThrowsError(try fixture.capture())
        XCTAssertEqual(try fixture.names(fixture.artifacts), ["preexisting"])
        XCTAssertEqual(try Data(contentsOf: marker), Data("preserve".utf8))
    }

    func testSecondCaptureCannotReusePreviouslyPublishedInventory() throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let capture = try fixture.capture()
        XCTAssertThrowsError(try fixture.capture())
        XCTAssertNoThrow(try capture.revalidate())
    }

    func testChangedOriginalBytesPoisonCaptureAndReadbackOwners() throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let capture = try fixture.capture()
        let reader = try fixture.readback(capture.observation)
        var changed = fixture.executableBytes
        changed[changed.startIndex] ^= 1
        try fixture.overwrite(fixture.executable, bytes: changed)
        XCTAssertThrowsError(try capture.revalidate())
        XCTAssertThrowsError(try reader.revalidate())
        XCTAssertThrowsError(try fixture.readback(capture.observation))
        // Restoring the bytes cannot unpoison either retained owner.
        try fixture.overwrite(fixture.executable, bytes: fixture.executableBytes)
        XCTAssertThrowsError(try capture.revalidate())
        XCTAssertThrowsError(try reader.revalidate())
    }

    func testChangedCopiedFileRejectsAndOriginalRemainsUntouched() throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let capture = try fixture.capture()
        let reader = try fixture.readback(capture.observation)
        let copied = fixture.artifacts.appendingPathComponent(
            "test-bundle/Contents/MacOS/ErgenticsPrimePackageTests")
        XCTAssertEqual(chmod(copied.path, 0o755), 0)
        var changed = fixture.executableBytes
        changed[changed.startIndex] ^= 1
        try fixture.overwrite(copied, bytes: changed)
        XCTAssertThrowsError(try capture.revalidate())
        XCTAssertThrowsError(try reader.revalidate())
        XCTAssertThrowsError(try fixture.readback(capture.observation))
        XCTAssertEqual(try Data(contentsOf: fixture.executable), fixture.executableBytes)
    }

    func testAdditionalCopiedEmptyDirectoryRejectsExactInventory() throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let capture = try fixture.capture()
        let extra = fixture.artifacts.appendingPathComponent("test-bundle/extra")
        XCTAssertEqual(mkdir(extra.path, 0o700), 0)
        XCTAssertThrowsError(try capture.revalidate())
        XCTAssertThrowsError(try fixture.readback(capture.observation))
    }

    func testZeroLengthBundleFileRejectsBeforePublication() throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        try fixture.write(fixture.bundle.appendingPathComponent("Contents/Resources/zero"),
            bytes: Data(), mode: 0o644)
        XCTAssertThrowsError(try fixture.capture())
        XCTAssertEqual(try fixture.names(fixture.artifacts), [])
    }

    func testFixedPathTraversalAndExpiredDeadlineRejectWithoutPublication() throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        XCTAssertThrowsError(try PrimeValidationDriverV2BuildArtifacts.capture(
            workspaceRoot: fixture.workspaceRoot, scratchRelativePath: "../workspace",
            testBundleRelativePath: PrimeValidationDriverV2BuildArtifacts.testBundlePath,
            metallibRelativePath: PrimeValidationDriverV2BuildArtifacts.metallibPath,
            expectedMetallibByteCount: UInt64(fixture.metallibBytes.count),
            expectedMetallibSHA256: fixture.metallibSHA256,
            artifactRoot: fixture.artifactRoot, deadlineNanoseconds: fixture.deadline))
        XCTAssertThrowsError(try PrimeValidationDriverV2BuildArtifacts.capture(
            workspaceRoot: fixture.workspaceRoot,
            scratchRelativePath: PrimeValidationDriverV2BuildArtifacts.scratchPath,
            testBundleRelativePath: PrimeValidationDriverV2BuildArtifacts.testBundlePath,
            metallibRelativePath: PrimeValidationDriverV2BuildArtifacts.metallibPath,
            expectedMetallibByteCount: UInt64(fixture.metallibBytes.count),
            expectedMetallibSHA256: fixture.metallibSHA256,
            artifactRoot: fixture.artifactRoot, deadlineNanoseconds: 0))
        XCTAssertEqual(try fixture.names(fixture.artifacts), [])
        XCTAssertEqual(try Data(contentsOf: fixture.outside), fixture.outsideBytes)
    }

    func testStagingStreamRejectsSameNameReplacement() throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let parent = try fixture.artifactRoot.duplicateTrustedRootDescriptorForInventory()
        defer { _ = close(parent) }
        let output = openat(parent, "stdout.log",
            O_RDWR | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC, 0o600)
        guard output >= 3 else { throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO) }
        defer { _ = close(output) }
        let stream = try PrimeValidationDriverV2BuildStaging.Stream(
            outputDescriptor: output, parent: parent, leaf: "stdout.log")
        XCTAssertNoThrow(try stream.revalidate(parent: parent, leaf: "stdout.log"))
        XCTAssertEqual(renameat(parent, "stdout.log", parent, "original-held-stream"), 0)
        try fixture.write(fixture.artifacts.appendingPathComponent("stdout.log"),
            bytes: Data(), mode: 0o600)
        var original = stat()
        var replacement = stat()
        XCTAssertEqual(fstat(output, &original), 0)
        XCTAssertEqual(fstatat(parent, "stdout.log", &replacement, AT_SYMLINK_NOFOLLOW), 0)
        XCTAssertNotEqual(original.st_ino, replacement.st_ino)
        XCTAssertEqual(original.st_nlink, 1)
        XCTAssertThrowsError(try stream.revalidate(parent: parent, leaf: "stdout.log"))
        XCTAssertEqual(try Data(contentsOf: fixture.outside), fixture.outsideBytes)
    }

    func testFrozenStagingStreamRejectsWriteThroughPreviouslyOpenedDescriptor() throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let parent = try fixture.artifactRoot.duplicateTrustedRootDescriptorForInventory()
        defer { _ = close(parent) }
        let earlierWriter = openat(parent, "stdout.log",
            O_RDWR | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC, 0o600)
        guard earlierWriter >= 3 else { throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO) }
        defer { _ = close(earlierWriter) }
        let stream = try PrimeValidationDriverV2BuildStaging.Stream(
            outputDescriptor: earlierWriter, parent: parent, leaf: "stdout.log")
        let payload = Data("native stream fixture\n".utf8)
        let initialCount = payload.withUnsafeBytes {
            Darwin.write(earlierWriter, $0.baseAddress, $0.count)
        }
        XCTAssertEqual(initialCount, payload.count)
        XCTAssertEqual(fchmod(earlierWriter, 0o444), 0)
        XCTAssertEqual(fsync(earlierWriter), 0)
        XCTAssertEqual(fcntl(earlierWriter, F_FULLFSYNC), 0)
        let binding = try fixture.artifactRoot.bindExisting(
            at: "stdout.log", purpose: .immutableData, maximumByteCount: 1024)
        XCTAssertEqual(binding.sha256, Fixture.digest(payload))
        try stream.freeze(binding: binding)
        XCTAssertNoThrow(try stream.revalidate(parent: parent, leaf: "stdout.log"))
        var before = stat()
        XCTAssertEqual(fstat(earlierWriter, &before), 0)
        var changed = payload
        changed[changed.startIndex] ^= 1
        let mutatedCount = changed.withUnsafeBytes {
            pwrite(earlierWriter, $0.baseAddress, $0.count, 0)
        }
        XCTAssertEqual(mutatedCount, changed.count)
        XCTAssertEqual(fsync(earlierWriter), 0)
        var after = stat()
        XCTAssertEqual(fstat(earlierWriter, &after), 0)
        XCTAssertEqual(after.st_ino, before.st_ino)
        XCTAssertEqual(after.st_size, before.st_size)
        XCTAssertEqual(after.st_mode & 0o7777, 0o444)
        XCTAssertNotEqual(try Data(contentsOf: fixture.artifacts.appendingPathComponent("stdout.log")),
            payload)
        XCTAssertThrowsError(try stream.revalidate(parent: parent, leaf: "stdout.log"))
    }

    func testFrozenStagingRunDirectoryRejectsChildRenameAndRestore() throws {
        let fixture = try Fixture()
        defer { fixture.cleanup() }
        let parent = try fixture.artifactRoot.duplicateTrustedRootDescriptorForInventory()
        defer { _ = close(parent) }
        let run = try PrimeValidationDriverV2BuildStaging.Directory.create(
            parent: parent, leaf: "run", path: fixture.artifacts.appendingPathComponent("run").path)
        XCTAssertEqual(mkdirat(run.descriptor, "build", 0o700), 0)
        XCTAssertEqual(mkdirat(run.descriptor, "artifacts", 0o700), 0)
        try run.freezeMetadata()
        XCTAssertNoThrow(try run.revalidate())
        var before = stat()
        XCTAssertEqual(fstat(run.descriptor, &before), 0)
        XCTAssertEqual(renameat(run.descriptor, "build", run.descriptor, "away"), 0)
        XCTAssertEqual(renameat(run.descriptor, "away", run.descriptor, "build"), 0)
        var after = stat()
        XCTAssertEqual(fstat(run.descriptor, &after), 0)
        XCTAssertEqual(after.st_ino, before.st_ino)
        XCTAssertEqual(after.st_nlink, before.st_nlink)
        XCTAssertEqual(try fixture.names(fixture.artifacts.appendingPathComponent("run")),
            ["artifacts", "build"])
        XCTAssertThrowsError(try run.revalidate())
        XCTAssertEqual(try Data(contentsOf: fixture.outside), fixture.outsideBytes)
    }

    private final class Fixture {
        let base: URL
        let workspace: URL
        let artifacts: URL
        let outside: URL
        let bundle: URL
        let executable: URL
        let metallib: URL
        let workspaceRoot: PrimeArtifactRoot
        let artifactRoot: PrimeArtifactRoot
        let executableBytes = Data("filesystem fixture only; never execute\n".utf8)
        let metallibBytes = Data("filesystem fixture only; not a Metal library\n".utf8)
        let outsideBytes = Data("outside capture scope; preserve these bytes\n".utf8)
        let deadline = DispatchTime.now().uptimeNanoseconds + 120_000_000_000
        var metallibSHA256: String { Self.digest(metallibBytes) }

        init() throws {
            var pattern = Array("/private/tmp/prime-build-artifacts-tests-XXXXXX".utf8CString)
            guard let temporary = mkdtemp(&pattern) else {
                throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO)
            }
            base = URL(fileURLWithPath: String(cString: temporary), isDirectory: true)
            workspace = base.appendingPathComponent("workspace", isDirectory: true)
            artifacts = base.appendingPathComponent("artifacts", isDirectory: true)
            outside = base.appendingPathComponent("outside-sentinel")
            bundle = workspace.appendingPathComponent(PrimeValidationDriverV2BuildArtifacts.testBundlePath)
            executable = bundle.appendingPathComponent("Contents/MacOS/ErgenticsPrimePackageTests")
            metallib = workspace.appendingPathComponent(PrimeValidationDriverV2BuildArtifacts.metallibPath)
            do {
                try Self.directory(workspace)
                try Self.directory(artifacts)
                try Self.directory(executable.deletingLastPathComponent())
                try Self.directory(bundle.appendingPathComponent("Contents/Resources/Empty"))
                try Self.directory(metallib.deletingLastPathComponent())
                workspaceRoot = try PrimeArtifactRoot(directoryURL: workspace)
                artifactRoot = try PrimeArtifactRoot(directoryURL: artifacts)
            } catch {
                try? FileManager.default.removeItem(at: base)
                throw error
            }
            do {
                try write(executable, bytes: executableBytes, mode: 0o755)
                try write(metallib, bytes: metallibBytes, mode: 0o644)
                try write(outside, bytes: outsideBytes, mode: 0o644)
                try write(bundle.appendingPathComponent("Contents/Info.plist"),
                    bytes: Data("fixture plist bytes\n".utf8), mode: 0o644)
                try write(bundle.appendingPathComponent("Contents/Resources/payload"),
                    bytes: Data("fixture payload bytes\n".utf8), mode: 0o644)
            } catch {
                cleanup()
                throw error
            }
        }

        func cleanup() { try? FileManager.default.removeItem(at: base) }

        func capture() throws -> PrimeValidationDriverV2BuildArtifacts {
            try PrimeValidationDriverV2BuildArtifacts.capture(
                workspaceRoot: workspaceRoot,
                scratchRelativePath: PrimeValidationDriverV2BuildArtifacts.scratchPath,
                testBundleRelativePath: PrimeValidationDriverV2BuildArtifacts.testBundlePath,
                metallibRelativePath: PrimeValidationDriverV2BuildArtifacts.metallibPath,
                expectedMetallibByteCount: UInt64(metallibBytes.count),
                expectedMetallibSHA256: metallibSHA256,
                artifactRoot: artifactRoot, deadlineNanoseconds: deadline)
        }

        func readback(_ expected: PrimeValidationDriverV2BuildArtifactsObservation)
            throws -> PrimeValidationDriverV2BuildArtifactsReadback {
            let workspaceFD = try workspaceRoot.duplicateTrustedRootDescriptorForInventory()
            defer { _ = close(workspaceFD) }
            let artifactFD = try artifactRoot.duplicateTrustedRootDescriptorForInventory()
            defer { _ = close(artifactFD) }
            return try PrimeValidationDriverV2BuildArtifactsReadback.capture(
                workspaceRootDescriptor: workspaceFD, artifactRootDescriptor: artifactFD,
                expected: expected, deadlineNanoseconds: deadline)
        }

        func names(_ directory: URL) throws -> [String] {
            try FileManager.default.contentsOfDirectory(atPath: directory.path).sorted()
        }

        func write(_ path: URL, bytes: Data, mode: mode_t) throws {
            let descriptor = open(path.path, O_WRONLY | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC, mode)
            guard descriptor >= 0 else { throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO) }
            defer { _ = close(descriptor) }
            try writeAll(descriptor, bytes: bytes)
            guard fchmod(descriptor, mode) == 0, fsync(descriptor) == 0 else {
                throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO)
            }
        }

        func overwrite(_ path: URL, bytes: Data) throws {
            let descriptor = open(path.path, O_WRONLY | O_NOFOLLOW | O_CLOEXEC)
            guard descriptor >= 0 else { throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO) }
            defer { _ = close(descriptor) }
            try writeAll(descriptor, bytes: bytes)
            guard fsync(descriptor) == 0 else {
                throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO)
            }
        }

        private func writeAll(_ descriptor: Int32, bytes: Data) throws {
            try bytes.withUnsafeBytes { buffer in
                var offset = 0
                while offset < buffer.count {
                    let count = Darwin.write(descriptor, buffer.baseAddress!.advanced(by: offset),
                        buffer.count - offset)
                    if count < 0 && errno == EINTR { continue }
                    guard count > 0 else { throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO) }
                    offset += count
                }
            }
        }

        private static func directory(_ path: URL) throws {
            try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true,
                attributes: [.posixPermissions: NSNumber(value: 0o700)])
        }

        static func digest(_ data: Data) -> String {
            SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
        }
    }
}
