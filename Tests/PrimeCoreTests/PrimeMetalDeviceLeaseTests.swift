import Darwin
import Foundation
import XCTest
@testable import PrimeCore

// Foundation marks fork unavailable because arbitrary post-fork Swift work is
// unsafe in a multithreaded process. This test deliberately enters a syscall-
// only child path and exits with `_exit`, which is the narrow safe use needed
// to prove that the lease is inter-process rather than merely in-process.
@_silgen_name("fork")
private func primeLeaseTestFork() -> pid_t

final class PrimeMetalDeviceLeaseTests: XCTestCase {
    func testAcquireHoldsExclusiveLeaseAndReleaseIsIdempotent()
        throws
    {
        let directory = try SecureTemporaryDirectory()
        let leaseURL = directory.url
            .appendingPathComponent("metal.lock")

        let first = try PrimeMetalDeviceLease.acquire(
            at: leaseURL
        )
        XCTAssertTrue(first.isHeld)
        XCTAssertThrowsError(
            try PrimeMetalDeviceLease.acquire(at: leaseURL)
        ) { error in
            XCTAssertEqual(
                error as? PrimeMetalDeviceLeaseError,
                .busy
            )
        }

        first.release()
        first.release()
        XCTAssertFalse(first.isHeld)

        let second = try PrimeMetalDeviceLease.acquire(
            at: leaseURL
        )
        XCTAssertTrue(second.isHeld)
        second.release()
    }

    func testParentLockPreventsSplitLeaseAfterLeafRename()
        throws
    {
        let directory = try SecureTemporaryDirectory()
        let leaseURL = directory.url
            .appendingPathComponent("metal.lock")
        let displacedURL = directory.url
            .appendingPathComponent("displaced.lock")
        let first = try PrimeMetalDeviceLease.acquire(
            at: leaseURL
        )
        try FileManager.default.moveItem(
            at: leaseURL,
            to: displacedURL
        )
        try createRegularFile(
            at: leaseURL,
            mode: 0o600
        )

        XCTAssertThrowsError(
            try PrimeMetalDeviceLease.acquire(at: leaseURL)
        ) { error in
            XCTAssertEqual(
                error as? PrimeMetalDeviceLeaseError,
                .busy
            )
        }

        first.release()
        let second = try PrimeMetalDeviceLease.acquire(
            at: leaseURL
        )
        second.release()
    }

    func testCompetingProcessIsDeniedUntilHolderReleases()
        throws
    {
        let directory = try SecureTemporaryDirectory()
        let leaseURL = directory.url
            .appendingPathComponent("metal.lock")
        try createRegularFile(at: leaseURL, mode: 0o600)

        var readyPipe = [Int32](repeating: -1, count: 2)
        var releasePipe = [Int32](repeating: -1, count: 2)
        XCTAssertEqual(pipe(&readyPipe), 0)
        XCTAssertEqual(pipe(&releasePipe), 0)

        let pathBytes = leaseURL.path.utf8CString
        let forkResult = primeLeaseTestFork()
        if forkResult == 0 {
            close(readyPipe[0])
            close(releasePipe[1])

            let childDescriptor = pathBytes.withUnsafeBufferPointer {
                open(
                    $0.baseAddress!,
                    O_RDWR | O_NOFOLLOW | O_CLOEXEC
                )
            }
            var acquisitionResult: Int32 = -1
            if childDescriptor >= 0 {
                acquisitionResult = flock(
                    childDescriptor,
                    LOCK_EX | LOCK_NB
                )
            }
            Self.writeValue(
                acquisitionResult,
                to: readyPipe[1]
            )

            var releaseSignal: UInt8 = 0
            _ = withUnsafeMutableBytes(
                of: &releaseSignal
            ) {
                read(
                    releasePipe[0],
                    $0.baseAddress,
                    $0.count
                )
            }
            if childDescriptor >= 0 {
                flock(childDescriptor, LOCK_UN)
                close(childDescriptor)
            }
            _exit(0)
        }
        XCTAssertGreaterThan(forkResult, 0)
        guard forkResult > 0 else {
            return
        }
        var child = forkResult

        close(readyPipe[1])
        close(releasePipe[0])
        defer {
            close(readyPipe[0])
            close(releasePipe[1])
            var status: Int32 = 0
            if child > 0 {
                waitpid(child, &status, 0)
            }
        }

        let childResult: Int32 = try readValue(
            from: readyPipe[0]
        )
        XCTAssertEqual(childResult, 0)
        XCTAssertThrowsError(
            try PrimeMetalDeviceLease.acquire(at: leaseURL)
        ) { error in
            XCTAssertEqual(
                error as? PrimeMetalDeviceLeaseError,
                .busy
            )
        }

        var releaseSignal: UInt8 = 1
        let bytesWritten = withUnsafeBytes(
            of: &releaseSignal
        ) {
            write(
                releasePipe[1],
                $0.baseAddress,
                $0.count
            )
        }
        XCTAssertEqual(bytesWritten, 1)

        var status: Int32 = 0
        XCTAssertEqual(waitpid(child, &status, 0), child)
        child = -1
        close(readyPipe[0])
        readyPipe[0] = -1
        close(releasePipe[1])
        releasePipe[1] = -1

        let lease = try PrimeMetalDeviceLease.acquire(
            at: leaseURL
        )
        lease.release()
    }

    func testSymbolicLinkLeaseIsDenied() throws {
        let directory = try SecureTemporaryDirectory()
        let targetURL = directory.url
            .appendingPathComponent("target")
        let leaseURL = directory.url
            .appendingPathComponent("metal.lock")
        try createRegularFile(at: targetURL, mode: 0o600)
        try FileManager.default.createSymbolicLink(
            at: leaseURL,
            withDestinationURL: targetURL
        )

        XCTAssertThrowsError(
            try PrimeMetalDeviceLease.acquire(at: leaseURL)
        ) { error in
            XCTAssertEqual(
                error as? PrimeMetalDeviceLeaseError,
                .leaseIsSymbolicLink
            )
        }
    }

    func testSymbolicLinkParentIsDenied() throws {
        let container = try SecureTemporaryDirectory()
        let realParent = container.url
            .appendingPathComponent("real")
        let linkedParent = container.url
            .appendingPathComponent("linked")
        try FileManager.default.createDirectory(
            at: realParent,
            withIntermediateDirectories: false
        )
        XCTAssertEqual(chmod(realParent.path, 0o700), 0)
        try FileManager.default.createSymbolicLink(
            at: linkedParent,
            withDestinationURL: realParent
        )

        XCTAssertThrowsError(
            try PrimeMetalDeviceLease.acquire(
                at: linkedParent
                    .appendingPathComponent("metal.lock")
            )
        ) { error in
            XCTAssertEqual(
                error as? PrimeMetalDeviceLeaseError,
                .parentIsSymbolicLink
            )
        }
    }

    func testHardLinkedLeaseIsDenied() throws {
        let directory = try SecureTemporaryDirectory()
        let originalURL = directory.url
            .appendingPathComponent("original")
        let leaseURL = directory.url
            .appendingPathComponent("metal.lock")
        try createRegularFile(at: originalURL, mode: 0o600)
        XCTAssertEqual(
            link(originalURL.path, leaseURL.path),
            0
        )

        XCTAssertThrowsError(
            try PrimeMetalDeviceLease.acquire(at: leaseURL)
        ) { error in
            XCTAssertEqual(
                error as? PrimeMetalDeviceLeaseError,
                .invalidLeaseLinkCount(actual: 2)
            )
        }
    }

    func testGroupWritableParentIsDenied() throws {
        let directory = try SecureTemporaryDirectory()
        XCTAssertEqual(chmod(directory.url.path, 0o770), 0)

        XCTAssertThrowsError(
            try PrimeMetalDeviceLease.acquire(
                at: directory.url
                    .appendingPathComponent("metal.lock")
            )
        ) { error in
            XCTAssertEqual(
                error as? PrimeMetalDeviceLeaseError,
                .untrustedParentPermissions(mode: 0o770)
            )
        }
    }

    func testNonPrivateLeaseModeIsDenied() throws {
        let directory = try SecureTemporaryDirectory()
        let leaseURL = directory.url
            .appendingPathComponent("metal.lock")
        try createRegularFile(at: leaseURL, mode: 0o640)

        XCTAssertThrowsError(
            try PrimeMetalDeviceLease.acquire(at: leaseURL)
        ) { error in
            XCTAssertEqual(
                error as? PrimeMetalDeviceLeaseError,
                .invalidLeasePermissions(mode: 0o640)
            )
        }
    }

    func testExtendedAttributesAreDenied() throws {
        let directory = try SecureTemporaryDirectory()
        let leaseURL = directory.url
            .appendingPathComponent("metal.lock")
        try createRegularFile(at: leaseURL, mode: 0o600)
        let descriptor = open(
            leaseURL.path,
            O_RDWR | O_NOFOLLOW | O_CLOEXEC
        )
        XCTAssertGreaterThanOrEqual(descriptor, 0)
        defer {
            close(descriptor)
        }

        let attributeName = "com.ergentics.prime.test"
        let attributeValue: [UInt8] = [1]
        let setResult = attributeName.withCString {
            namePointer in
            attributeValue.withUnsafeBytes { valueBuffer in
                fsetxattr(
                    descriptor,
                    namePointer,
                    valueBuffer.baseAddress,
                    valueBuffer.count,
                    0,
                    0
                )
            }
        }
        XCTAssertEqual(setResult, 0)

        XCTAssertThrowsError(
            try PrimeMetalDeviceLease.acquire(at: leaseURL)
        ) { error in
            XCTAssertEqual(
                error as? PrimeMetalDeviceLeaseError,
                .leaseHasExtendedAttributes
            )
        }
    }

    func testStalePIDTextIsNeitherDeletedNorRewritten()
        throws
    {
        let directory = try SecureTemporaryDirectory()
        let leaseURL = directory.url
            .appendingPathComponent("metal.lock")
        let staleText = Data("999999\n".utf8)
        XCTAssertTrue(
            FileManager.default.createFile(
                atPath: leaseURL.path,
                contents: staleText
            )
        )
        XCTAssertEqual(chmod(leaseURL.path, 0o600), 0)

        var before = stat()
        XCTAssertEqual(lstat(leaseURL.path, &before), 0)
        let lease = try PrimeMetalDeviceLease.acquire(
            at: leaseURL
        )
        lease.release()
        var after = stat()
        XCTAssertEqual(lstat(leaseURL.path, &after), 0)

        XCTAssertEqual(before.st_dev, after.st_dev)
        XCTAssertEqual(before.st_ino, after.st_ino)
        XCTAssertEqual(
            try Data(contentsOf: leaseURL),
            staleText
        )
    }

    private func createRegularFile(
        at url: URL,
        mode: mode_t
    ) throws {
        let descriptor = open(
            url.path,
            O_RDWR | O_CREAT | O_EXCL | O_CLOEXEC,
            mode
        )
        guard descriptor >= 0 else {
            throw POSIXTestError(errno: errno)
        }
        close(descriptor)
        guard chmod(url.path, mode) == 0 else {
            throw POSIXTestError(errno: errno)
        }
    }

    private static func writeValue<T>(
        _ value: T,
        to descriptor: Int32
    ) {
        var mutableValue = value
        _ = withUnsafeBytes(of: &mutableValue) {
            write(
                descriptor,
                $0.baseAddress,
                $0.count
            )
        }
    }

    private func readValue<T>(
        from descriptor: Int32
    ) throws -> T {
        let expectedCount = MemoryLayout<T>.size
        let storage = UnsafeMutableRawPointer.allocate(
            byteCount: expectedCount,
            alignment: MemoryLayout<T>.alignment
        )
        defer {
            storage.deallocate()
        }
        let count = read(
            descriptor,
            storage,
            expectedCount
        )
        guard count == expectedCount else {
            throw POSIXTestError(
                errno: count < 0 ? errno : EIO
            )
        }
        return storage.load(as: T.self)
    }
}

private struct POSIXTestError: Error {
    let errno: Int32
}

private final class SecureTemporaryDirectory {
    let url: URL

    init() throws {
        url = FileManager.default.temporaryDirectory
            .appendingPathComponent(
                "PrimeMetalDeviceLeaseTests-\(UUID().uuidString)",
                isDirectory: true
            )
        try FileManager.default.createDirectory(
            at: url,
            withIntermediateDirectories: false
        )
        guard chmod(url.path, 0o700) == 0 else {
            throw POSIXTestError(errno: errno)
        }
    }

    deinit {
        try? FileManager.default.removeItem(at: url)
    }
}
