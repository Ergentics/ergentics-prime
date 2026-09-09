#if EPR_BOOT_EXPORT_TESTS
import CryptoKit
import Darwin
import Foundation
import XCTest

// Real descriptor/file operations on this suite's private fixtures only.
// No AppKit, application startup, VM, process, signal or production FD1 calls.
private enum BootExportFixtureFailure: Error { case posix(String, Int32) }

private func onBootExportWorker(_ body: @escaping @Sendable () throws -> Void) async throws {
    try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
        DispatchQueue.global(qos: .userInitiated).async {
            do { try body(); continuation.resume() }
            catch { continuation.resume(throwing: error) }
        }
    }
}

private enum BootExportFixtures {
    static var frame: Data { Data("ERGENTICS_RUST_BOOT_V1 {\"fixture\":true}\n".utf8) }

    static func directory(_ body: (URL) throws -> Void) throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("DevelopmentRustBootExportTests-" + UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: false,
                                                attributes: [.posixPermissions: 0o700])
        // Only the exact newly created test directory is cleaned. Production
        // outputs and prior retained evidence are never selected by this code.
        defer { try? FileManager.default.removeItem(at: root) }
        try body(root)
    }

    static func create(_ url: URL) throws -> Int32 {
        let fd = Darwin.open(url.path, O_RDWR | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC, mode_t(0o600))
        guard fd >= 0 else { throw BootExportFixtureFailure.posix("create", errno) }
        return fd
    }

    static func file(_ body: (Int32, URL, URL) throws -> Void) throws {
        try directory { root in
            let path = root.appendingPathComponent("output")
            let fd = try create(path)
            defer { Darwin.close(fd) }
            try body(fd, path, root)
        }
    }

    static func contents(_ fd: Int32) throws -> Data {
        var value = stat()
        guard fstat(fd, &value) == 0, value.st_size >= 0,
              value.st_size <= off_t(DevelopmentRustBootExport.maximumFrameBytes) else {
            throw BootExportFixtureFailure.posix("fixture-size", errno)
        }
        var result = Data(count: Int(value.st_size))
        if result.isEmpty { return result }
        try result.withUnsafeMutableBytes { bytes in
            var offset = 0
            while offset < bytes.count {
                let count = pread(fd, bytes.baseAddress!.advanced(by: offset), bytes.count - offset, off_t(offset))
                if count < 0, errno == EINTR { continue }
                guard count > 0 else { throw BootExportFixtureFailure.posix("fixture-read", errno) }
                offset += count
            }
        }
        return result
    }
}

// Deliberately permits a test-only race against the instance's one-winner latch.
// The production exporter itself is not Sendable and remains owner-confined.
private final class BootExportRace: @unchecked Sendable {
    let exporter: DevelopmentRustBootExport
    let frame: Data
    private let lock = NSLock()
    private var successes = 0
    private var failures: [String] = []

    init(_ exporter: DevelopmentRustBootExport, frame: Data) {
        self.exporter = exporter; self.frame = frame
    }
    func attempt() {
        do {
            _ = try exporter.export(frame: frame)
            lock.lock(); successes += 1; lock.unlock()
        } catch {
            let stage = (error as? DevelopmentRustBootExport.Failure)?.stage ?? "unexpected-error"
            lock.lock(); failures.append(stage); lock.unlock()
        }
    }
    func result() -> (Int, [String]) {
        lock.lock(); defer { lock.unlock() }
        return (successes, failures)
    }
}

final class DevelopmentRustBootExportTests: XCTestCase {
    func testRealWriteSyncAndOffsetPreservingReadback() async throws {
        try await onBootExportWorker {
            XCTAssertFalse(Thread.isMainThread)
            try BootExportFixtures.file { fd, _, _ in
                let flagsBefore = fcntl(fd, F_GETFL)
                XCTAssertEqual(flagsBefore, O_RDWR)
                let exporter = try DevelopmentRustBootExport(testDescriptor: fd)
                let frame = BootExportFixtures.frame
                let result = try exporter.export(frame: frame)
                let flagsAfter = fcntl(fd, F_GETFL)
                XCTAssertEqual(flagsAfter, flagsBefore | Int32(0x0001_0000))
                XCTAssertEqual(flagsBefore ^ flagsAfter, Int32(0x0001_0000),
                               "Only XNU's measured FWASWRITTEN bit may transition")
                XCTAssertEqual(result.bytes, frame.count)
                XCTAssertEqual(result.sha256, SHA256.hash(data: frame).map { String(format: "%02x", $0) }.joined())
                XCTAssertEqual(result.fsyncStatus, 0)
                XCTAssertEqual(result.fullSyncStatus, 0)
                XCTAssertEqual(result.identity, exporter.identity)
                XCTAssertEqual(lseek(fd, 0, SEEK_CUR), off_t(frame.count))
                XCTAssertEqual(try BootExportFixtures.contents(fd), frame)
                XCTAssertGreaterThanOrEqual(fcntl(fd, F_GETFD), 0, "Exporter must not close the borrowed FD")
            }
        }
    }

    func testSecondWriteRejectsAndPreservesFirstFrame() async throws {
        try await onBootExportWorker {
            try BootExportFixtures.file { fd, _, _ in
                let exporter = try DevelopmentRustBootExport(testDescriptor: fd)
                _ = try exporter.export(frame: BootExportFixtures.frame)
                XCTAssertThrowsError(try exporter.export(frame: BootExportFixtures.frame)) { error in
                    XCTAssertEqual((error as? DevelopmentRustBootExport.Failure)?.stage, "already-consumed")
                }
                XCTAssertEqual(try BootExportFixtures.contents(fd), BootExportFixtures.frame)
            }
        }
    }

    func testFramingFailureConsumesWithoutWritingOrSyncing() async throws {
        try await onBootExportWorker {
            let invalid = [Data(), Data("wrong {}\n".utf8), Data("ERGENTICS_RUST_BOOT_V1 {}".utf8),
                Data("ERGENTICS_RUST_BOOT_V1 {}\n\n".utf8), Data("ERGENTICS_RUST_BOOT_V1 {}\r\n".utf8),
                Data("ERGENTICS_RUST_BOOT_V1 []\n".utf8),
                DevelopmentRustBootExport.prefix + Data([123, 0xff, 125, 10]),
                Data(repeating: 65, count: DevelopmentRustBootExport.maximumFrameBytes + 1)]
            for frame in invalid {
                try BootExportFixtures.file { fd, _, _ in
                    let exporter = try DevelopmentRustBootExport(testDescriptor: fd)
                    XCTAssertThrowsError(try exporter.export(frame: frame)) { error in
                        let failure = error as? DevelopmentRustBootExport.Failure
                        XCTAssertNotNil(failure)
                        XCTAssertEqual(failure?.bytesWritten, 0)
                        XCTAssertEqual(failure?.fsyncStatus, Int32.min)
                        XCTAssertEqual(failure?.fullSyncStatus, Int32.min)
                    }
                    XCTAssertThrowsError(try exporter.export(frame: BootExportFixtures.frame))
                    XCTAssertEqual(try BootExportFixtures.contents(fd), Data())
                }
            }
        }
    }

    func testExactMaximumFrameIsAccepted() async throws {
        try await onBootExportWorker {
            let opening = DevelopmentRustBootExport.prefix + Data("{\"padding\":\"".utf8)
            let closing = Data("\"}\n".utf8)
            let padding = Data(repeating: 65,
                count: DevelopmentRustBootExport.maximumFrameBytes - opening.count - closing.count)
            let frame = opening + padding + closing
            try BootExportFixtures.file { fd, _, _ in
                let flagsBefore = fcntl(fd, F_GETFL)
                XCTAssertEqual(flagsBefore, O_RDWR)
                let result = try DevelopmentRustBootExport(testDescriptor: fd).export(frame: frame)
                let flagsAfter = fcntl(fd, F_GETFL)
                XCTAssertEqual(flagsAfter, flagsBefore | Int32(0x0001_0000))
                XCTAssertEqual(flagsBefore ^ flagsAfter, Int32(0x0001_0000))
                XCTAssertEqual(result.bytes, 524_288)
                XCTAssertEqual(try BootExportFixtures.contents(fd), frame)
            }
        }
    }

    func testReadOnlyWriteOnlyAndAppendDescriptorsReject() async throws {
        try await onBootExportWorker {
            for mode in [O_RDONLY, O_WRONLY, O_RDWR | O_APPEND] {
                try BootExportFixtures.file { original, path, _ in
                    let fd = Darwin.open(path.path, mode | O_NOFOLLOW | O_CLOEXEC)
                    guard fd >= 0 else { throw BootExportFixtureFailure.posix("reopen", errno) }
                    defer { Darwin.close(fd) }
                    XCTAssertThrowsError(try DevelopmentRustBootExport(testDescriptor: fd))
                    XCTAssertEqual(try BootExportFixtures.contents(original), Data())
                }
            }
        }
    }

    func testWrongModeAndHardLinkedFileReject() async throws {
        try await onBootExportWorker {
            try BootExportFixtures.file { fd, _, _ in
                guard fchmod(fd, mode_t(0o640)) == 0 else { throw BootExportFixtureFailure.posix("fixture-chmod", errno) }
                XCTAssertThrowsError(try DevelopmentRustBootExport(testDescriptor: fd))
            }
            try BootExportFixtures.file { fd, path, root in
                guard link(path.path, root.appendingPathComponent("second-link").path) == 0 else {
                    throw BootExportFixtureFailure.posix("fixture-link", errno)
                }
                XCTAssertThrowsError(try DevelopmentRustBootExport(testDescriptor: fd))
            }
        }
    }

    func testNonemptyAndNonzeroOffsetRejectAdmission() async throws {
        try await onBootExportWorker {
            try BootExportFixtures.file { fd, _, _ in
                var byte: UInt8 = 65
                XCTAssertEqual(Darwin.write(fd, &byte, 1), 1)
                XCTAssertEqual(lseek(fd, 0, SEEK_SET), 0)
                XCTAssertThrowsError(try DevelopmentRustBootExport(testDescriptor: fd))
                XCTAssertEqual(try BootExportFixtures.contents(fd), Data([65]))
            }
            try BootExportFixtures.file { fd, _, _ in
                XCTAssertEqual(lseek(fd, 1, SEEK_SET), 1)
                XCTAssertThrowsError(try DevelopmentRustBootExport(testDescriptor: fd))
                XCTAssertEqual(try BootExportFixtures.contents(fd), Data())
            }
        }
    }

    func testDirectoryAndInvalidDescriptorReject() async throws {
        try await onBootExportWorker {
            try BootExportFixtures.directory { root in
                let fd = Darwin.open(root.path, O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC)
                guard fd >= 0 else { throw BootExportFixtureFailure.posix("directory-open", errno) }
                defer { Darwin.close(fd) }
                XCTAssertThrowsError(try DevelopmentRustBootExport(testDescriptor: fd))
            }
            XCTAssertThrowsError(try DevelopmentRustBootExport(testDescriptor: -1))
        }
    }

    func testDescriptorReplacementRejectsWithoutWritingReplacement() async throws {
        try await onBootExportWorker {
            try BootExportFixtures.directory { root in
                let originalPath = root.appendingPathComponent("original")
                let replacementPath = root.appendingPathComponent("replacement")
                let original = try BootExportFixtures.create(originalPath)
                defer { Darwin.close(original) }
                let replacement = try BootExportFixtures.create(replacementPath)
                defer { Darwin.close(replacement) }
                let exporter = try DevelopmentRustBootExport(testDescriptor: original)
                guard dup2(replacement, original) == original else { throw BootExportFixtureFailure.posix("fixture-dup2", errno) }
                XCTAssertThrowsError(try exporter.export(frame: BootExportFixtures.frame))
                XCTAssertEqual(try BootExportFixtures.contents(original), Data())
                XCTAssertEqual(try BootExportFixtures.contents(replacement), Data())
                XCTAssertEqual(try Data(contentsOf: originalPath), Data())
                XCTAssertThrowsError(try exporter.export(frame: BootExportFixtures.frame))
            }
        }
    }

    func testMetadataFlagsAndOffsetChangesAfterAdmissionReject() async throws {
        try await onBootExportWorker {
            try BootExportFixtures.file { fd, _, _ in
                let exporter = try DevelopmentRustBootExport(testDescriptor: fd)
                guard fchmod(fd, mode_t(0o400)) == 0 else { throw BootExportFixtureFailure.posix("fixture-chmod", errno) }
                XCTAssertThrowsError(try exporter.export(frame: BootExportFixtures.frame))
                XCTAssertEqual(try BootExportFixtures.contents(fd), Data())
            }
            try BootExportFixtures.file { fd, _, _ in
                let exporter = try DevelopmentRustBootExport(testDescriptor: fd)
                guard fcntl(fd, F_SETFL, fcntl(fd, F_GETFL) | O_APPEND) == 0 else {
                    throw BootExportFixtureFailure.posix("fixture-flags", errno)
                }
                XCTAssertThrowsError(try exporter.export(frame: BootExportFixtures.frame))
                XCTAssertEqual(try BootExportFixtures.contents(fd), Data())
            }
            try BootExportFixtures.file { fd, _, _ in
                let flagsBefore = fcntl(fd, F_GETFL)
                let exporter = try DevelopmentRustBootExport(testDescriptor: fd)
                guard fcntl(fd, F_SETFL, flagsBefore | O_NONBLOCK) == 0 else {
                    throw BootExportFixtureFailure.posix("fixture-nonblock", errno)
                }
                XCTAssertThrowsError(try exporter.export(frame: BootExportFixtures.frame)) { error in
                    let failure = error as? DevelopmentRustBootExport.Failure
                    XCTAssertEqual(failure?.stage, "before-write-changed")
                    XCTAssertEqual(failure?.expectedState?.flags, flagsBefore)
                    XCTAssertEqual(failure?.observedState?.flags, flagsBefore | O_NONBLOCK)
                    XCTAssertEqual(failure?.bytesWritten, 0)
                }
                XCTAssertEqual(try BootExportFixtures.contents(fd), Data())
            }
            try BootExportFixtures.file { fd, _, _ in
                let exporter = try DevelopmentRustBootExport(testDescriptor: fd)
                XCTAssertEqual(lseek(fd, 1, SEEK_SET), 1)
                XCTAssertThrowsError(try exporter.export(frame: BootExportFixtures.frame))
                XCTAssertEqual(try BootExportFixtures.contents(fd), Data())
            }
            try BootExportFixtures.file { fd, path, root in
                let exporter = try DevelopmentRustBootExport(testDescriptor: fd)
                guard link(path.path, root.appendingPathComponent("late-link").path) == 0 else {
                    throw BootExportFixtureFailure.posix("fixture-link", errno)
                }
                XCTAssertThrowsError(try exporter.export(frame: BootExportFixtures.frame))
                XCTAssertEqual(try BootExportFixtures.contents(fd), Data())
            }
        }
    }

    func testForeignPrefixAfterAdmissionIsRetained() async throws {
        try await onBootExportWorker {
            try BootExportFixtures.file { fd, _, _ in
                let exporter = try DevelopmentRustBootExport(testDescriptor: fd)
                var foreign: UInt8 = 65
                XCTAssertEqual(Darwin.write(fd, &foreign, 1), 1)
                XCTAssertThrowsError(try exporter.export(frame: BootExportFixtures.frame)) { error in
                    XCTAssertEqual((error as? DevelopmentRustBootExport.Failure)?.bytesWritten, 0)
                }
                XCTAssertEqual(try BootExportFixtures.contents(fd), Data([65]))
                XCTAssertThrowsError(try exporter.export(frame: BootExportFixtures.frame))
            }
        }
    }

    func testConcurrentCallsHaveExactlyOneWinner() async throws {
        try await onBootExportWorker {
            try BootExportFixtures.file { fd, _, _ in
                let race = BootExportRace(try DevelopmentRustBootExport(testDescriptor: fd), frame: BootExportFixtures.frame)
                DispatchQueue.concurrentPerform(iterations: 8) { _ in race.attempt() }
                let (successes, failures) = race.result()
                XCTAssertEqual(successes, 1)
                XCTAssertEqual(failures.count, 7)
                XCTAssertEqual(Set(failures), ["already-consumed"])
                XCTAssertEqual(try BootExportFixtures.contents(fd), BootExportFixtures.frame)
            }
        }
    }
}
#endif
