import Darwin
import Foundation
@testable import PrimeCore
import XCTest

final class PrimeNativeNeuralGateHeldSourceClosureTests:
    XCTestCase
{
    private struct Fixture {
        let root: URL
        let watchedFile: URL
        let sourcesDirectory: URL
        let buildCacheFile: URL
        let monitor:
            PrimeNativeNeuralGateHeldSourceClosure
    }

    func testBuildCacheWriteDoesNotProduceSourceEvent()
        throws
    {
        let fixture = try makeFixture()
        defer {
            closeAndRemove(fixture)
        }
        try overwriteExact(
            fixture.buildCacheFile,
            bytes: Array("zzzz".utf8)
        )
        XCTAssertEqual(
            try fixture.monitor
                .drainPendingEventsForTesting(
                    maximumEventCount: 64,
                    maximumDurationNanoseconds:
                        100_000_000
                ),
            []
        )
    }

    func testSourceInPlaceWriteLatchesFileWrite()
        throws
    {
        let fixture = try makeFixture()
        defer {
            closeAndRemove(fixture)
        }
        try overwriteExact(
            fixture.watchedFile,
            bytes: Array("bbbb".utf8)
        )
        let events =
            try fixture.monitor
            .drainPendingEventsForTesting(
                maximumEventCount: 64,
                maximumDurationNanoseconds:
                    100_000_000
            )
        XCTAssertTrue(
            events.contains {
                !$0.isDirectory
                    && $0.relativePath
                        == "Sources/Watched.swift"
                    && $0.noteMask
                        & UInt32(NOTE_WRITE)
                        != 0
            }
        )
    }

    func testTransientSourceCreateAndUnlinkLatchesParentWrite()
        throws
    {
        let fixture = try makeFixture()
        defer {
            closeAndRemove(fixture)
        }
        let transient =
            fixture.sourcesDirectory
            .appendingPathComponent(
                "Transient.swift"
            )
        try createFile(
            transient,
            bytes: Array("x".utf8)
        )
        XCTAssertEqual(
            unlink(transient.path),
            0
        )
        let events =
            try fixture.monitor
            .drainPendingEventsForTesting(
                maximumEventCount: 64,
                maximumDurationNanoseconds:
                    100_000_000
            )
        XCTAssertTrue(
            events.contains {
                $0.isDirectory
                    && $0.relativePath
                        == "Sources"
                    && $0.noteMask
                        & UInt32(NOTE_WRITE)
                        != 0
            }
        )
    }

    func testRenameAwayAndBackLatchesFileRenameAndParentWrite()
        throws
    {
        let fixture = try makeFixture()
        defer {
            closeAndRemove(fixture)
        }
        let moved =
            fixture.sourcesDirectory
            .appendingPathComponent(
                "Watched.moved"
            )
        XCTAssertEqual(
            rename(
                fixture.watchedFile.path,
                moved.path
            ),
            0
        )
        XCTAssertEqual(
            rename(
                moved.path,
                fixture.watchedFile.path
            ),
            0
        )
        let events =
            try fixture.monitor
            .drainPendingEventsForTesting(
                maximumEventCount: 64,
                maximumDurationNanoseconds:
                    100_000_000
            )
        XCTAssertTrue(
            events.contains {
                !$0.isDirectory
                    && $0.relativePath
                        == "Sources/Watched.swift"
                    && $0.noteMask
                        & UInt32(NOTE_RENAME)
                        != 0
            }
        )
        XCTAssertTrue(
            events.contains {
                $0.isDirectory
                    && $0.relativePath
                        == "Sources"
                    && $0.noteMask
                        & UInt32(NOTE_WRITE)
                        != 0
            }
        )
    }

    func testVersionSpecificRootPackageManifestIsRejectedCaseSensitively()
        throws
    {
        XCTAssertThrowsError(
            try makeFixture(
                additionalRootFileName:
                    "Package@swift-6.0.swift"
            )
        ) { error in
            XCTAssertEqual(
                rejectionDetail(error),
                "source_root_version_specific_package_manifest"
            )
        }

        let lowercase =
            try makeFixture(
                additionalRootFileName:
                    "package@swift-6.0.swift"
            )
        closeAndRemove(lowercase)
    }

    func testProductionEventPollPoisonsOnFirstObservedEvent()
        throws
    {
        XCTAssertEqual(
            PrimeNativeNeuralGateHeldSourceClosure
                .productionPendingEventMaximumCount,
            1
        )
        XCTAssertEqual(
            PrimeNativeNeuralGateHeldSourceClosure
                .maximumProductionPollAttemptCount,
            8
        )
        let fixture = try makeFixture()
        defer {
            closeAndRemove(fixture)
        }
        try overwriteExact(
            fixture.watchedFile,
            bytes: Array("bbbb".utf8)
        )
        XCTAssertThrowsError(
            try fixture.monitor
                .validateBeforeResume()
        ) { error in
            XCTAssertEqual(
                rejectionDetail(error),
                "source_event_before_pre_resume"
            )
        }
        XCTAssertThrowsError(
            try fixture.monitor
                .validateBeforeResume()
        ) { error in
            XCTAssertEqual(
                rejectionDetail(error),
                "source_monitor_poisoned"
            )
        }
    }

    func testTestingEventCollectionRejectsMissingOrExcessiveBounds()
        throws
    {
        let fixture = try makeFixture()
        defer {
            closeAndRemove(fixture)
        }
        XCTAssertThrowsError(
            try fixture.monitor
                .drainPendingEventsForTesting(
                    maximumEventCount: 0,
                    maximumDurationNanoseconds:
                        100_000_000
                )
        ) { error in
            XCTAssertEqual(
                rejectionDetail(error),
                "source_testing_event_bounds"
            )
        }
        XCTAssertThrowsError(
            try fixture.monitor
                .drainPendingEventsForTesting(
                    maximumEventCount: 64,
                    maximumDurationNanoseconds:
                        1_000_000_001
                )
        ) { error in
            XCTAssertEqual(
                rejectionDetail(error),
                "source_testing_event_bounds"
            )
        }
    }

    func testHeldDescriptorsRequireTheRootLocalAPFSFilesystemIdentity()
        throws
    {
        let fixture = try makeFixture()
        defer {
            closeAndRemove(fixture)
        }
        let rootDescriptor =
            open(
                fixture.root.path,
                O_RDONLY
                    | O_DIRECTORY
                    | O_NOFOLLOW_ANY
                    | O_CLOEXEC
            )
        let fileDescriptor =
            open(
                fixture.watchedFile.path,
                O_RDONLY
                    | O_NOFOLLOW_ANY
                    | O_CLOEXEC
            )
        guard rootDescriptor >= 3,
              fileDescriptor >= 3
        else {
            if rootDescriptor >= 0 {
                _ = close(rootDescriptor)
            }
            if fileDescriptor >= 0 {
                _ = close(fileDescriptor)
            }
            XCTFail(
                "failed to open APFS fixture descriptors"
            )
            return
        }
        defer {
            _ = close(fileDescriptor)
            _ = close(rootDescriptor)
        }
        XCTAssertNoThrow(
            try PrimeNativeNeuralGateHeldSourceClosure
                .requireSameLocalAPFSFilesystemForTesting(
                    rootDescriptor:
                        rootDescriptor,
                    candidateDescriptor:
                        fileDescriptor
                )
        )

        let systemRootDescriptor =
            open(
                "/",
                O_RDONLY
                    | O_DIRECTORY
                    | O_NOFOLLOW_ANY
                    | O_CLOEXEC
            )
        guard systemRootDescriptor >= 3 else {
            if systemRootDescriptor >= 0 {
                _ = close(
                    systemRootDescriptor
                )
            }
            XCTFail(
                "failed to open the sealed system APFS volume"
            )
            return
        }
        defer {
            _ = close(
                systemRootDescriptor
            )
        }
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateHeldSourceClosure
                .requireSameLocalAPFSFilesystemForTesting(
                    rootDescriptor:
                        rootDescriptor,
                    candidateDescriptor:
                        systemRootDescriptor
                )
        ) { error in
            XCTAssertEqual(
                rejectionDetail(error),
                "source_test_candidate_filesystem_identity"
            )
        }

        let queueDescriptor = kqueue()
        guard queueDescriptor >= 3 else {
            if queueDescriptor >= 0 {
                _ = close(queueDescriptor)
            }
            XCTFail(
                "failed to create non-filesystem descriptor"
            )
            return
        }
        defer {
            _ = close(queueDescriptor)
        }
        XCTAssertEqual(
            fcntl(
                queueDescriptor,
                F_SETFD,
                FD_CLOEXEC
            ),
            0
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateHeldSourceClosure
                .requireSameLocalAPFSFilesystemForTesting(
                    rootDescriptor:
                        rootDescriptor,
                    candidateDescriptor:
                        queueDescriptor
                )
        )
    }

    private func makeFixture(
        additionalRootFileName:
            String? = nil
    ) throws
        -> Fixture
    {
        let root =
            URL(
                fileURLWithPath:
                    "/private/tmp",
                isDirectory: true
            )
            .appendingPathComponent(
                "prime-held-source-" +
                    UUID().uuidString,
                isDirectory: true
            )
        let sources =
            root.appendingPathComponent(
                "Sources",
                isDirectory: true
            )
        let build =
            root.appendingPathComponent(
                ".build",
                isDirectory: true
            )
        try FileManager.default
            .createDirectory(
                at: sources,
                withIntermediateDirectories:
                    true
            )
        try FileManager.default
            .createDirectory(
                at: build,
                withIntermediateDirectories:
                    false
            )
        let watched =
            sources.appendingPathComponent(
                "Watched.swift"
            )
        let watchedData =
            Data("aaaa".utf8)
        try createFile(
            watched,
            bytes: Array(watchedData)
        )
        let cache =
            build.appendingPathComponent(
                "cache.bin"
            )
        try createFile(
            cache,
            bytes: Array("cccc".utf8)
        )
        if let additionalRootFileName {
            try createFile(
                root.appendingPathComponent(
                    additionalRootFileName
                ),
                bytes: Array(
                    "// fixture".utf8
                )
            )
        }
        let snapshot =
            PrimeSwiftSourceSnapshot(
                sourceIdentitySHA256:
                    String(
                        repeating: "a",
                        count: 64
                    ),
                embeddedSourceIdentitySHA256:
                    String(
                        repeating: "a",
                        count: 64
                    ),
                buildConfiguration:
                    "release",
                files: [
                    PrimeSwiftSourceFileSnapshot(
                        relativePath:
                            "Sources/Watched.swift",
                        sha256:
                            PrimeSHA256
                            .hexDigest(
                                of: watchedData
                            ),
                        byteCount:
                            UInt64(
                                watchedData.count
                            ),
                        contents:
                            watchedData
                    ),
                ]
            )
        let rootDescriptor =
            open(
                root.path,
                O_RDONLY
                    | O_DIRECTORY
                    | O_NOFOLLOW_ANY
                    | O_CLOEXEC
            )
        guard rootDescriptor >= 3 else {
            if rootDescriptor >= 0 {
                _ = close(rootDescriptor)
            }
            try? FileManager.default
                .removeItem(at: root)
            throw CocoaError(
                .fileReadUnknown
            )
        }
        do {
            let monitor =
                try PrimeNativeNeuralGateHeldSourceClosure(
                    rootDescriptor:
                        rootDescriptor,
                    sourceSnapshot:
                        snapshot
                )
            _ = close(rootDescriptor)
            return Fixture(
                root: root,
                watchedFile: watched,
                sourcesDirectory: sources,
                buildCacheFile: cache,
                monitor: monitor
            )
        } catch {
            _ = close(rootDescriptor)
            try? FileManager.default
                .removeItem(at: root)
            throw error
        }
    }

    private func rejectionDetail(
        _ error: Error
    ) -> String? {
        guard case let
            PrimeNativeNeuralGateSecureExternalChildCaptureError
            .rejected(detail) = error
        else {
            return nil
        }
        return detail
    }

    private func closeAndRemove(
        _ fixture: Fixture
    ) {
        fixture.monitor.close()
        try? FileManager.default
            .removeItem(
                at: fixture.root
            )
    }

    private func createFile(
        _ url: URL,
        bytes: [UInt8]
    ) throws {
        let descriptor =
            open(
                url.path,
                O_WRONLY
                    | O_CREAT
                    | O_EXCL
                    | O_CLOEXEC,
                mode_t(0o600)
            )
        guard descriptor >= 0 else {
            throw CocoaError(
                .fileWriteUnknown
            )
        }
        defer {
            _ = close(descriptor)
        }
        try writeAll(
            descriptor,
            bytes: bytes
        )
        guard fsync(descriptor) == 0 else {
            throw CocoaError(
                .fileWriteUnknown
            )
        }
    }

    private func overwriteExact(
        _ url: URL,
        bytes: [UInt8]
    ) throws {
        let descriptor =
            open(
                url.path,
                O_WRONLY
                    | O_NOFOLLOW_ANY
                    | O_CLOEXEC
            )
        guard descriptor >= 0 else {
            throw CocoaError(
                .fileWriteUnknown
            )
        }
        defer {
            _ = close(descriptor)
        }
        let count =
            bytes.withUnsafeBytes {
                pwrite(
                    descriptor,
                    $0.baseAddress,
                    $0.count,
                    0
                )
            }
        guard count == bytes.count,
              fsync(descriptor) == 0
        else {
            throw CocoaError(
                .fileWriteUnknown
            )
        }
    }

    private func writeAll(
        _ descriptor: Int32,
        bytes: [UInt8]
    ) throws {
        var offset = 0
        while offset < bytes.count {
            let count =
                bytes.withUnsafeBytes {
                    write(
                        descriptor,
                        $0.baseAddress?
                            .advanced(
                                by: offset
                            ),
                        $0.count - offset
                    )
                }
            if count < 0,
               errno == EINTR
            {
                continue
            }
            guard count > 0 else {
                throw CocoaError(
                    .fileWriteUnknown
                )
            }
            offset += count
        }
    }
}
