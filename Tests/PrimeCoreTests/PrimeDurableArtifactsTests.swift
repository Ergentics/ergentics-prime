import Darwin
import Foundation
import XCTest
@testable import PrimeCore

final class PrimeDurableArtifactsTests: XCTestCase {
    private enum FixtureError: Error {
        case generationFailed
        case unexpectedPartialCount
    }

    private final class AsyncPOSIXStatus:
        @unchecked Sendable
    {
        private let lock = NSLock()
        private var storedError: Int32 = 0

        func fail(_ error: Int32) {
            lock.lock()
            if storedError == 0 {
                storedError = error
            }
            lock.unlock()
        }

        var error: Int32 {
            lock.lock()
            defer { lock.unlock() }
            return storedError
        }
    }

    private struct SeedDocument: Codable {
        let initialization: UInt64
        let trainingSchedule: UInt64
        let evaluation: UInt64

        private enum CodingKeys: String, CodingKey {
            case initialization
            case trainingSchedule = "training_schedule"
            case evaluation
        }
    }

    private struct Fixture {
        let root: PrimeArtifactRoot
        let seeds: PrimeExecutionSeeds
        let executable: PrimeArtifactBinding
        let source: PrimeArtifactBinding
        let configuration: PrimeArtifactBinding
        let artifacts: PrimeExecutionArtifactBindings
        let calibration: PrimeArtifactBinding
        let exclusionReason: String

        var authorization: PrimeRunAuthorization {
            PrimeRunAuthorization(
                seeds: seeds,
                artifacts: artifacts,
                calibrationReceipt: calibration,
                externalExecutionExclusionReason:
                    exclusionReason
            )
        }
    }

    private var temporaryURL: URL!

    override func setUpWithError() throws {
        temporaryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(
                "ergentics-prime-durable-\(UUID().uuidString)",
                isDirectory: true
            )
        try FileManager.default.createDirectory(
            at: temporaryURL,
            withIntermediateDirectories: false
        )
        guard chmod(temporaryURL.path, 0o700) == 0 else {
            throw POSIXError(
                POSIXErrorCode(rawValue: errno)!
            )
        }
    }

    override func tearDownWithError() throws {
        if let temporaryURL {
            try? FileManager.default.removeItem(
                at: temporaryURL
            )
        }
    }

    func testCanonicalObservationPreservesNullVersusFalse() throws {
        let unavailable =
            PrimeBooleanObservation.unavailable
        let observedFalse =
            PrimeBooleanObservation.observed(false)

        let unavailableData =
            try PrimeCanonicalJSON.encode(unavailable)
        let falseData =
            try PrimeCanonicalJSON.encode(observedFalse)

        XCTAssertNotEqual(unavailableData, falseData)
        XCTAssertEqual(
            String(decoding: unavailableData, as: UTF8.self),
            #"{"observation_available":false,"value":null}"#
        )
        XCTAssertEqual(
            String(decoding: falseData, as: UTF8.self),
            #"{"observation_available":true,"value":false}"#
        )
        XCTAssertEqual(
            try PrimeCanonicalJSON.decode(
                PrimeBooleanObservation.self,
                from: unavailableData
            ),
            unavailable
        )
        XCTAssertEqual(
            try PrimeCanonicalJSON.decode(
                PrimeBooleanObservation.self,
                from: falseData
            ),
            observedFalse
        )

        let missingValue = Data(
            #"{"observation_available":false}"#.utf8
        )
        XCTAssertThrowsError(
            try PrimeCanonicalJSON.decode(
                PrimeBooleanObservation.self,
                from: missingValue
            )
        )
        XCTAssertThrowsError(
            try PrimeCanonicalJSON.encode(
                PrimeBooleanObservation(
                    observationAvailable: false,
                    value: false
                )
            )
        )
    }

    func testPrivateRootModeRequiresExactOwnerOnlyAccess()
        throws
    {
        let root = try PrimeArtifactRoot(
            directoryURL: temporaryURL
        )
        try root.requirePrivateRootMode()

        XCTAssertEqual(chmod(temporaryURL.path, 0o755), 0)
        XCTAssertThrowsError(
            try root.requirePrivateRootMode()
        )
        XCTAssertEqual(chmod(temporaryURL.path, 0o700), 0)
        try root.requirePrivateRootMode()
    }

    func testArtifactRootRejectsIntermediateSymbolicLink()
        throws
    {
        let actualParent =
            temporaryURL.appendingPathComponent(
                "actual-parent",
                isDirectory: true
            )
        let actualRoot =
            actualParent.appendingPathComponent(
                "artifact-root",
                isDirectory: true
            )
        try FileManager.default.createDirectory(
            at: actualRoot,
            withIntermediateDirectories: true
        )
        XCTAssertEqual(
            chmod(actualRoot.path, 0o700),
            0
        )
        let linkedParent =
            temporaryURL.appendingPathComponent(
                "linked-parent",
                isDirectory: true
            )
        try FileManager.default.createSymbolicLink(
            at: linkedParent,
            withDestinationURL: actualParent
        )
        let redirectedRoot =
            linkedParent.appendingPathComponent(
                "artifact-root",
                isDirectory: true
            )

        XCTAssertThrowsError(
            try PrimeArtifactRoot(
                directoryURL: redirectedRoot
            )
        ) { error in
            guard case let .posix(
                operation,
                path,
                code
            ) = error as? PrimeDurableArtifactError else {
                return XCTFail(
                    "unexpected error: \(error)"
                )
            }
            XCTAssertEqual(
                operation,
                "openat trusted artifact root component"
            )
            XCTAssertEqual(path, redirectedRoot.path)
            XCTAssertTrue(
                code == ELOOP || code == ENOTDIR
            )
        }
    }

    #if os(macOS)
    func testArtifactRootAcceptsFixedMacOSTemporaryAlias()
        throws
    {
        let name =
            "ergentics-prime-root-alias-\(UUID().uuidString)"
        let physicalRoot = URL(
            fileURLWithPath: "/private/tmp/\(name)",
            isDirectory: true
        )
        let aliasRoot = URL(
            fileURLWithPath: "/tmp/\(name)",
            isDirectory: true
        )
        try FileManager.default.createDirectory(
            at: physicalRoot,
            withIntermediateDirectories: false
        )
        defer {
            try? FileManager.default.removeItem(
                at: physicalRoot
            )
        }
        XCTAssertEqual(
            chmod(physicalRoot.path, 0o700),
            0
        )

        let root = try PrimeArtifactRoot(
            directoryURL: aliasRoot
        )
        try root.requirePrivateRootMode()
        let payload = Data("fixed-root-alias".utf8)
        let binding = try root.publish(
            payload,
            at: "artifact.bin",
            purpose: .immutableData
        )
        XCTAssertEqual(
            try root.readVerified(binding),
            payload
        )
    }
    #endif

    func testImmutablePublicationVerifiesExactAndRejectsOverwrite()
        throws
    {
        let root = try PrimeArtifactRoot(
            directoryURL: temporaryURL
        )
        let original = Data("first".utf8)
        let first = try root.publish(
            original,
            at: "artifact.bin",
            purpose: .immutableData
        )
        let repeated = try root.publish(
            original,
            at: "artifact.bin",
            purpose: .immutableData
        )
        XCTAssertEqual(first, repeated)
        XCTAssertEqual(
            try root.readVerified(first),
            original
        )

        XCTAssertThrowsError(
            try root.publish(
                Data("second".utf8),
                at: "artifact.bin",
                purpose: .immutableData
            )
        ) { error in
            XCTAssertEqual(
                error as? PrimeDurableArtifactError,
                .conflictingArtifact("artifact.bin")
            )
        }
        XCTAssertEqual(
            try root.readVerified(first),
            original
        )
        XCTAssertTrue(
            try partialArtifactNames().isEmpty
        )
    }

    func testDataPublicationSourceUsesHeldDescriptorReclamation()
        throws
    {
        let tests = URL(
            fileURLWithPath: #filePath
        ).deletingLastPathComponent()
        let root = tests
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let source = try String(
            contentsOf:
                root.appendingPathComponent(
                    "Sources/PrimeCore/PrimeDurableArtifacts.swift"
                ),
            encoding: .utf8
        )
        let start = try XCTUnwrap(
            source.range(
                of:
                    "    public func publish(\n        _ data: Data,"
            )
        )
        let end = try XCTUnwrap(
            source.range(
                of:
                    "\n    /// Publishes a file produced by a synchronous descriptor generator",
                range:
                    start.upperBound
                        ..< source.endIndex
            )
        )
        let implementation =
            source[
                start.lowerBound ..< end.lowerBound
            ]

        XCTAssertTrue(
            implementation.contains(
                "try verifyExisting("
            ),
            "identical existing artifacts must remain idempotent"
        )
        XCTAssertTrue(
            implementation.contains(
                "return try publishGeneratedFile("
            ),
            "new Data publication must reuse held-descriptor publication"
        )
        XCTAssertFalse(
            implementation.contains("unlinkat("),
            "Data publication must never reclaim a temporary by name"
        )
    }

    func testGeneratedDescriptorPublicationAndVerifiedLazyMaterialization()
        throws
    {
        let root = try PrimeArtifactRoot(
            directoryURL: temporaryURL
        )
        let payload = Data(
            (0 ..< (2 * 1024 * 1024 + 17)).map {
                UInt8(truncatingIfNeeded: $0)
            }
        )
        var generatedDescriptor: Int32 = -1
        let binding = try root.publishGeneratedFile(
            at: "checkpoint.safetensors",
            purpose: .immutableData,
            maximumByteCount: UInt64(payload.count)
        ) { descriptor in
            generatedDescriptor = descriptor
            XCTAssertEqual(
                fcntl(descriptor, F_GETFD) & FD_CLOEXEC,
                FD_CLOEXEC
            )
            try writeAll(payload, to: descriptor)
        }

        errno = 0
        let generatedDescriptorStatus =
            fcntl(generatedDescriptor, F_GETFD)
        let generatedDescriptorError = errno
        XCTAssertEqual(generatedDescriptorStatus, -1)
        XCTAssertEqual(generatedDescriptorError, EBADF)
        XCTAssertEqual(
            binding.sha256,
            PrimeSHA256.hexDigest(of: payload)
        )
        XCTAssertEqual(
            binding.byteCount,
            UInt64(payload.count)
        )
        let artifactURL = temporaryURL
            .appendingPathComponent(
                binding.relativePath
            )
        var metadata = stat()
        XCTAssertEqual(
            lstat(artifactURL.path, &metadata),
            0
        )
        XCTAssertEqual(
            metadata.st_mode & mode_t(0o7777),
            mode_t(0o444)
        )
        XCTAssertEqual(metadata.st_nlink, 1)

        var sequence = [String]()
        var loadedDescriptor: Int32 = -1
        let loadedCount: Int =
            try root.withVerifiedArtifactDescriptor(
                binding
            ) { descriptor in
                loadedDescriptor = descriptor
                sequence.append("load")
                XCTAssertEqual(
                    fcntl(descriptor, F_GETFD)
                        & FD_CLOEXEC,
                    FD_CLOEXEC
                )
                return {
                    try self.readAll(
                        from: descriptor
                    )
                }
            } materialize: { lazyRead in
                sequence.append("materialize")
                return try lazyRead().count
            }
        errno = 0
        let loadedDescriptorStatus =
            fcntl(loadedDescriptor, F_GETFD)
        let loadedDescriptorError = errno
        XCTAssertEqual(loadedDescriptorStatus, -1)
        XCTAssertEqual(loadedDescriptorError, EBADF)
        XCTAssertEqual(loadedCount, payload.count)
        XCTAssertEqual(
            sequence,
            ["load", "materialize"]
        )
        XCTAssertEqual(
            try root.readVerified(
                binding,
                maximumByteCount:
                    UInt64(payload.count)
            ),
            payload
        )
        XCTAssertTrue(
            try partialArtifactNames().isEmpty
        )
    }

    func testGeneratedDescriptorFailureReclaimsStorageWithoutUnlinkingPartials()
        throws
    {
        let root = try PrimeArtifactRoot(
            directoryURL: temporaryURL
        )
        var oversizedGenerationCompleted = false
        XCTAssertThrowsError(
            try root.publishGeneratedFile(
                at: "over-cap.safetensors",
                purpose: .immutableData,
                maximumByteCount: 3
            ) { descriptor in
                try writeAll(
                    Data("four".utf8),
                    to: descriptor
                )
                oversizedGenerationCompleted = true
            }
        ) { error in
            XCTAssertEqual(
                error as? PrimeDurableArtifactError,
                .artifactTooLarge(
                    "over-cap.safetensors"
                )
            )
        }
        XCTAssertTrue(oversizedGenerationCompleted)
        XCTAssertFalse(
            FileManager.default.fileExists(
                atPath: temporaryURL
                    .appendingPathComponent(
                        "over-cap.safetensors"
                    ).path
            )
        )
        try assertReclaimedPartialArtifacts(count: 1)

        XCTAssertThrowsError(
            try root.publishGeneratedFile(
                at: "thrown.safetensors",
                purpose: .immutableData,
                maximumByteCount: 1024
            ) { descriptor in
                try writeAll(
                    Data("partial".utf8),
                    to: descriptor
                )
                throw FixtureError.generationFailed
            }
        ) { error in
            XCTAssertTrue(error is FixtureError)
        }
        XCTAssertFalse(
            FileManager.default.fileExists(
                atPath: temporaryURL
                    .appendingPathComponent(
                        "thrown.safetensors"
                    ).path
            )
        )
        try assertReclaimedPartialArtifacts(count: 2)
    }

    func testGeneratedDescriptorPublicationIsNoReplace()
        throws
    {
        let root = try PrimeArtifactRoot(
            directoryURL: temporaryURL
        )
        let original = Data("original".utf8)
        let first = try publishGenerated(
            original,
            at: "checkpoint.safetensors",
            in: root
        )
        XCTAssertThrowsError(
            try publishGenerated(
                original,
                at: "checkpoint.safetensors",
                in: root
            )
        ) { error in
            XCTAssertEqual(
                error as? PrimeDurableArtifactError,
                .conflictingArtifact(
                    "checkpoint.safetensors"
                )
            )
        }

        XCTAssertThrowsError(
            try publishGenerated(
                Data("different".utf8),
                at: "checkpoint.safetensors",
                in: root
            )
        ) { error in
            XCTAssertEqual(
                error as? PrimeDurableArtifactError,
                .conflictingArtifact(
                    "checkpoint.safetensors"
                )
            )
        }
        XCTAssertEqual(
            try root.readVerified(first),
            original
        )
        XCTAssertTrue(
            try partialArtifactNames().isEmpty
        )
    }

    func testGeneratedDescriptorDestinationRaceFailsClosedAndPreservesNames()
        throws
    {
        let root = try PrimeArtifactRoot(
            directoryURL: temporaryURL
        )
        let generated = Data("generated".utf8)
        let racing = Data("racing destination".utf8)
        let destination = temporaryURL
            .appendingPathComponent(
                "raced.safetensors"
            )

        XCTAssertThrowsError(
            try root.publishGeneratedFile(
                at: "raced.safetensors",
                purpose: .immutableData,
                maximumByteCount:
                    UInt64(generated.count)
            ) { descriptor in
                try writeAll(
                    generated,
                    to: descriptor
                )
                try overwriteGeneratedFile(
                    at: destination,
                    with: racing,
                    create: true,
                    mode: mode_t(0o444)
                )
            }
        ) { error in
            XCTAssertEqual(
                error as? PrimeDurableArtifactError,
                .conflictingArtifact(
                    "raced.safetensors"
                )
            )
        }
        XCTAssertEqual(
            try Data(contentsOf: destination),
            racing
        )
        try assertReclaimedPartialArtifacts(count: 1)
    }

    func testGeneratedDescriptorRehashesAfterRename()
        throws
    {
        let root = try PrimeArtifactRoot(
            directoryURL: temporaryURL
        )
        let original = Data(
            repeating: 0x41,
            count: 2 * 1024 * 1024
        )
        let tampered = Data(
            repeating: 0x42,
            count: original.count
        )
        let finalURL = temporaryURL.appendingPathComponent(
            "post-rename-race.safetensors"
        )
        let writerFinished = DispatchSemaphore(value: 0)
        let writerStatus = AsyncPOSIXStatus()

        XCTAssertThrowsError(
            try root.publishGeneratedFile(
                at: "post-rename-race.safetensors",
                purpose: .immutableData,
                maximumByteCount: UInt64(original.count)
            ) { descriptor in
                try writeAll(original, to: descriptor)
                let partialURL =
                    try onlyPartialArtifactURL()
                let racingDescriptor = open(
                    partialURL.path,
                    O_RDWR | O_NOFOLLOW | O_CLOEXEC
                )
                guard racingDescriptor >= 0 else {
                    throw POSIXError(
                        POSIXErrorCode(rawValue: errno)!
                    )
                }
                DispatchQueue.global(
                    qos: .userInitiated
                ).async {
                    defer {
                        _ = close(racingDescriptor)
                        writerFinished.signal()
                    }
                    let deadline =
                        Date().addingTimeInterval(5)
                    var sealed = stat()
                    while true {
                        guard fstat(
                            racingDescriptor,
                            &sealed
                        ) == 0 else {
                            writerStatus.fail(errno)
                            return
                        }
                        if sealed.st_mode
                            & mode_t(0o7777)
                            == mode_t(0o444) {
                            break
                        }
                        guard Date() < deadline else {
                            writerStatus.fail(ETIMEDOUT)
                            return
                        }
                        usleep(100)
                    }

                    while true {
                        var published = stat()
                        if lstat(
                            finalURL.path,
                            &published
                        ) == 0 {
                            break
                        }
                        let statusError = errno
                        guard statusError == ENOENT else {
                            writerStatus.fail(statusError)
                            return
                        }
                        guard Date() < deadline else {
                            writerStatus.fail(ETIMEDOUT)
                            return
                        }
                        usleep(100)
                    }

                    tampered.withUnsafeBytes { bytes in
                        guard let base = bytes.baseAddress else {
                            return
                        }
                        var offset = 0
                        while offset < bytes.count {
                            let count = pwrite(
                                racingDescriptor,
                                base.advanced(by: offset),
                                bytes.count - offset,
                                off_t(offset)
                            )
                            if count < 0, errno == EINTR {
                                continue
                            }
                            guard count > 0 else {
                                writerStatus.fail(
                                    count < 0 ? errno : EIO
                                )
                                return
                            }
                            offset += count
                        }
                    }
                    guard writerStatus.error == 0 else {
                        return
                    }
                    var times = [
                        sealed.st_atimespec,
                        sealed.st_mtimespec,
                    ]
                    let restored =
                        times.withUnsafeMutableBufferPointer {
                            futimens(
                                racingDescriptor,
                                $0.baseAddress
                            )
                        }
                    if restored != 0 {
                        writerStatus.fail(errno)
                    }
                }
            }
        ) { error in
            switch error as? PrimeDurableArtifactError {
            case .hashMismatch, .unsafeArtifact:
                break
            default:
                XCTFail("unexpected error: \(error)")
            }
        }
        XCTAssertEqual(
            writerFinished.wait(
                timeout: .now() + 6
            ),
            .success
        )
        XCTAssertEqual(writerStatus.error, 0)
        XCTAssertEqual(
            try Data(contentsOf: finalURL),
            tampered
        )
    }

    func testGeneratedDescriptorRejectsHardLinkAndXattrAndPreservesReplacement()
        throws
    {
        let root = try PrimeArtifactRoot(
            directoryURL: temporaryURL
        )
        let hardLinkURL = temporaryURL
            .appendingPathComponent(
                "generated-hardlink"
            )
        XCTAssertThrowsError(
            try root.publishGeneratedFile(
                at: "hardlinked.safetensors",
                purpose: .immutableData,
                maximumByteCount: 1024
            ) { descriptor in
                try writeAll(
                    Data("linked".utf8),
                    to: descriptor
                )
                let partialURL =
                    try onlyPartialArtifactURL()
                XCTAssertEqual(
                    link(
                        partialURL.path,
                        hardLinkURL.path
                    ),
                    0
                )
            }
        )
        var hardLinkMetadata = stat()
        XCTAssertEqual(
            lstat(
                hardLinkURL.path,
                &hardLinkMetadata
            ),
            0
        )
        XCTAssertEqual(hardLinkMetadata.st_nlink, 2)
        XCTAssertEqual(hardLinkMetadata.st_size, 0)

        XCTAssertThrowsError(
            try root.publishGeneratedFile(
                at: "xattr.safetensors",
                purpose: .immutableData,
                maximumByteCount: 1024
            ) { descriptor in
                try writeAll(
                    Data("xattr".utf8),
                    to: descriptor
                )
                try addUnapprovedExtendedAttribute(
                    to: descriptor
                )
            }
        )

        let payload = Data("generated bytes".utf8)
        let replacementPayload =
            Data("unrelated replacement".utf8)
        let priorPartialNames = Set(
            try partialArtifactNames()
        )
        var reboundPartialURL: URL?
        XCTAssertThrowsError(
            try root.publishGeneratedFile(
                at: "replaced.safetensors",
                purpose: .immutableData,
                maximumByteCount: 1024
            ) { descriptor in
                try writeAll(payload, to: descriptor)
                let partialURL =
                    try onlyNewPartialArtifactURL(
                        excluding: priorPartialNames
                    )
                reboundPartialURL = partialURL
                XCTAssertEqual(
                    unlink(partialURL.path),
                    0
                )
                let replacement = open(
                    partialURL.path,
                    O_WRONLY | O_CREAT | O_EXCL
                        | O_NOFOLLOW | O_CLOEXEC,
                    mode_t(0o600)
                )
                XCTAssertGreaterThanOrEqual(
                    replacement,
                    0
                )
                guard replacement >= 0 else {
                    throw POSIXError(
                        POSIXErrorCode(
                            rawValue: errno
                        )!
                    )
                }
                defer { _ = close(replacement) }
                try writeAll(
                    replacementPayload,
                    to: replacement
                )
            }
        ) { error in
            guard case let .unsafeArtifact(path) =
                    error as? PrimeDurableArtifactError else {
                return XCTFail(
                    "unexpected error: \(error)"
                )
            }
            XCTAssertTrue(
                path.hasPrefix(".prime-partial-")
            )
        }
        XCTAssertFalse(
            FileManager.default.fileExists(
                atPath: temporaryURL
                    .appendingPathComponent(
                        "replaced.safetensors"
                    ).path
            )
        )
        let preservedURL = try XCTUnwrap(
            reboundPartialURL
        )
        XCTAssertEqual(
            try Data(contentsOf: preservedURL),
            replacementPayload
        )
        XCTAssertTrue(
            try partialArtifactNames().contains(
                preservedURL.lastPathComponent
            )
        )
    }

    func testDescriptorCallbacksResistArtifactRootPathABA()
        throws
    {
        let root = try PrimeArtifactRoot(
            directoryURL: temporaryURL
        )
        let original = Data("descriptor-bound".utf8)
        let malicious = Data("path-substitute".utf8)
        let binding = try root.publishGeneratedFile(
            at: "aba.safetensors",
            purpose: .immutableData,
            maximumByteCount: UInt64(original.count)
        ) { descriptor in
            try withArtifactRootPathReplaced { _ in
                try writeAll(
                    original,
                    to: descriptor
                )
            }
        }
        XCTAssertEqual(
            try root.readVerified(binding),
            original
        )

        let loaded: Data =
            try root.withVerifiedArtifactDescriptor(
                binding
            ) { descriptor in
                {
                    try self
                        .withArtifactRootPathReplaced {
                            replacementRoot in
                            let substitute =
                                replacementRoot
                                .appendingPathComponent(
                                    binding.relativePath
                                )
                            try self.overwriteGeneratedFile(
                                at: substitute,
                                with: malicious,
                                create: true,
                                mode: mode_t(0o444)
                            )
                            return try self.readAll(
                                from: descriptor
                            )
                        }
                }
            } materialize: { lazyRead in
                try lazyRead()
            }
        XCTAssertEqual(loaded, original)
    }

    func testVerifiedDescriptorRejectsPostMaterializationTamper()
        throws
    {
        let root = try PrimeArtifactRoot(
            directoryURL: temporaryURL
        )
        let binding = try publishGenerated(
            Data("original".utf8),
            at: "load-tamper.safetensors",
            in: root
        )
        let artifactURL = temporaryURL
            .appendingPathComponent(
                binding.relativePath
            )
        var sequence = [String]()
        XCTAssertThrowsError(
            try root.withVerifiedArtifactDescriptor(
                binding
            ) { descriptor in
                sequence.append("load")
                return {
                    try self.readAll(
                        from: descriptor
                    )
                }
            } materialize: { lazyRead in
                sequence.append("materialize")
                let loaded = try lazyRead()
                XCTAssertEqual(chmod(artifactURL.path, 0o600), 0)
                try overwriteGeneratedFile(
                    at: artifactURL,
                    with: Data("tampered".utf8)
                )
                XCTAssertEqual(chmod(artifactURL.path, 0o444), 0)
                return loaded.count
            }
        )
        XCTAssertEqual(
            sequence,
            ["load", "materialize"]
        )
    }

    func testFIFOArtifactsAreRejectedWithoutBlocking()
        throws
    {
        let root = try PrimeArtifactRoot(
            directoryURL: temporaryURL
        )
        let relativePath = "occupied.safetensors"
        let fifoURL = temporaryURL
            .appendingPathComponent(relativePath)
        XCTAssertEqual(
            mkfifo(fifoURL.path, mode_t(0o444)),
            0
        )
        XCTAssertEqual(chmod(fifoURL.path, 0o444), 0)
        let binding = PrimeArtifactBinding(
            relativePath: relativePath,
            sha256: String(repeating: "0", count: 64),
            byteCount: 0,
            purpose: .immutableData
        )

        XCTAssertThrowsError(
            try root.withVerifiedArtifactDescriptor(
                binding
            ) { _ in
                XCTFail("FIFO reached loader")
            } materialize: { _ in
                ()
            }
        ) { error in
            XCTAssertEqual(
                error as? PrimeDurableArtifactError,
                .unsafeArtifact(relativePath)
            )
        }
        XCTAssertThrowsError(
            try root.publishGeneratedFile(
                at: relativePath,
                purpose: .immutableData,
                maximumByteCount: 0
            ) { _ in }
        ) { error in
            XCTAssertEqual(
                error as? PrimeDurableArtifactError,
                .unsafeArtifact(relativePath)
            )
        }
        XCTAssertTrue(
            try partialArtifactNames().isEmpty
        )
    }

    func testGeneratedDescriptorPublishesSparseMultiGigabyteSafetensors()
        throws
    {
        guard ProcessInfo.processInfo.environment[
            "PRIME_RUN_LARGE_ARTIFACT_TESTS"
        ] == "1" else {
            throw XCTSkip(
                "set PRIME_RUN_LARGE_ARTIFACT_TESTS=1"
            )
        }
        let root = try PrimeArtifactRoot(
            directoryURL: temporaryURL
        )
        let tensorByteCount =
            UInt64(UInt32.max) + 1
        var header = Data(
            #"{"tensor":{"data_offsets":[0,4294967296],"dtype":"U8","shape":[4294967296]}}"#
                .utf8
        )
        while header.count.isMultiple(of: 8) == false {
            header.append(0x20)
        }
        let artifactByteCount =
            UInt64(8 + header.count)
                + tensorByteCount
        let binding = try root.publishGeneratedFile(
            at: "large.safetensors",
            purpose: .immutableData,
            maximumByteCount: artifactByteCount
        ) { descriptor in
            var headerByteCount =
                UInt64(header.count).littleEndian
            let length = withUnsafeBytes(
                of: &headerByteCount
            ) {
                Data($0)
            }
            try writeAll(length, to: descriptor)
            try writeAll(header, to: descriptor)
            guard ftruncate(
                descriptor,
                off_t(artifactByteCount)
            ) == 0 else {
                throw POSIXError(
                    POSIXErrorCode(rawValue: errno)!
                )
            }
        }
        XCTAssertEqual(
            binding.byteCount,
            artifactByteCount
        )
        XCTAssertEqual(binding.sha256.utf8.count, 64)
        var metadata = stat()
        XCTAssertEqual(
            lstat(
                temporaryURL
                    .appendingPathComponent(
                        binding.relativePath
                    ).path,
                &metadata
            ),
            0
        )
        XCTAssertLessThan(
            UInt64(metadata.st_blocks) * 512,
            64 * 1024 * 1024
        )
    }

    func testNewRunRootMustBeEmpty()
        throws
    {
        let root = try PrimeArtifactRoot(
            directoryURL: temporaryURL
        )
        XCTAssertNoThrow(
            try root.requireEmpty()
        )
        _ = try root.publish(
            Data("prior run".utf8),
            at: "prior-run.json",
            purpose: .immutableData
        )
        XCTAssertThrowsError(
            try root.requireEmpty()
        ) { error in
            XCTAssertEqual(
                error as? PrimeDurableArtifactError,
                .nonemptyArtifactRoot
            )
        }
    }

    func testPrivateDirectoryAndOutputPreflightUseTrustedRoot()
        throws
    {
        let root = try PrimeArtifactRoot(
            directoryURL: temporaryURL
        )
        try root.ensurePrivateDirectory(
            at: "content-staging"
        )
        var metadata = stat()
        let directoryURL = temporaryURL
            .appendingPathComponent(
                "content-staging",
                isDirectory: true
            )
        XCTAssertEqual(
            lstat(directoryURL.path, &metadata),
            0
        )
        XCTAssertEqual(
            metadata.st_mode & mode_t(0o777),
            mode_t(0o700)
        )

        XCTAssertNoThrow(
            try root.requireAbsent(at: "receipt.json")
        )
        _ = try root.publish(
            Data("receipt".utf8),
            at: "receipt.json",
            purpose: .immutableData
        )
        XCTAssertThrowsError(
            try root.requireAbsent(at: "receipt.json")
        ) { error in
            XCTAssertEqual(
                error as? PrimeDurableArtifactError,
                .conflictingArtifact("receipt.json")
            )
        }
    }

    func testArtifactRootRejectsUnapprovedExtendedAttribute()
        throws
    {
        try addUnapprovedExtendedAttribute(
            at: temporaryURL,
            isDirectory: true
        )

        XCTAssertThrowsError(
            try PrimeArtifactRoot(
                directoryURL: temporaryURL
            )
        ) { error in
            XCTAssertEqual(
                error as? PrimeDurableArtifactError,
                .untrustedDirectory(temporaryURL.path)
            )
        }
    }

    func testOpenArtifactRootRejectsLaterUnapprovedExtendedAttribute()
        throws
    {
        let root = try PrimeArtifactRoot(
            directoryURL: temporaryURL
        )
        try addUnapprovedExtendedAttribute(
            at: temporaryURL,
            isDirectory: true
        )

        XCTAssertThrowsError(
            try root.requireAbsent(at: "receipt.json")
        ) { error in
            XCTAssertEqual(
                error as? PrimeDurableArtifactError,
                .untrustedDirectory(temporaryURL.path)
            )
        }
    }

    func testNestedDirectoryRejectsUnapprovedExtendedAttribute()
        throws
    {
        let root = try PrimeArtifactRoot(
            directoryURL: temporaryURL
        )
        try root.ensurePrivateDirectory(at: "nested")
        let nestedURL = temporaryURL.appendingPathComponent(
            "nested",
            isDirectory: true
        )
        try addUnapprovedExtendedAttribute(
            at: nestedURL,
            isDirectory: true
        )

        XCTAssertThrowsError(
            try root.publish(
                Data("blocked".utf8),
                at: "nested/artifact.bin",
                purpose: .immutableData
            )
        ) { error in
            XCTAssertEqual(
                error as? PrimeDurableArtifactError,
                .untrustedDirectory(
                    "nested/artifact.bin"
                )
            )
        }
    }

    func testArtifactRejectsUnapprovedExtendedAttribute()
        throws
    {
        let root = try PrimeArtifactRoot(
            directoryURL: temporaryURL
        )
        let binding = try root.publish(
            Data("immutable".utf8),
            at: "artifact.bin",
            purpose: .immutableData
        )
        let artifactURL = temporaryURL.appendingPathComponent(
            binding.relativePath
        )
        XCTAssertEqual(chmod(artifactURL.path, 0o600), 0)
        try addUnapprovedExtendedAttribute(
            at: artifactURL,
            isDirectory: false
        )
        XCTAssertEqual(chmod(artifactURL.path, 0o444), 0)

        XCTAssertThrowsError(
            try root.verify(binding)
        ) { error in
            XCTAssertEqual(
                error as? PrimeDurableArtifactError,
                .unsafeArtifact(binding.relativePath)
            )
        }
    }

    func testArtifactRootRejectsSpecialModeBits()
        throws
    {
        XCTAssertEqual(chmod(temporaryURL.path, 0o1700), 0)
        defer {
            _ = chmod(temporaryURL.path, 0o700)
        }

        XCTAssertThrowsError(
            try PrimeArtifactRoot(
                directoryURL: temporaryURL
            )
        ) { error in
            XCTAssertEqual(
                error as? PrimeDurableArtifactError,
                .untrustedDirectory(temporaryURL.path)
            )
        }
    }

    func testPublicationAndResolutionRejectSymbolicLinks()
        throws
    {
        let root = try PrimeArtifactRoot(
            directoryURL: temporaryURL
        )
        let target = temporaryURL.appendingPathComponent(
            "target"
        )
        try Data("target".utf8).write(to: target)
        let link = temporaryURL.appendingPathComponent(
            "linked"
        )
        try FileManager.default.createSymbolicLink(
            at: link,
            withDestinationURL: target
        )

        XCTAssertThrowsError(
            try root.publish(
                Data("target".utf8),
                at: "linked",
                purpose: .immutableData
            )
        )

        let binding = PrimeArtifactBinding(
            relativePath: "linked",
            sha256: PrimeSHA256.hexDigest(
                of: Data("target".utf8)
            ),
            byteCount: 6,
            purpose: .immutableData
        )
        XCTAssertThrowsError(try root.verify(binding))
    }

    func testResolvedAuthorizationVerifiesFilesAndSemantics()
        throws
    {
        let fixture = try makeFixture()
        let resolved = try fixture.authorization.resolve(
            in: fixture.root
        )
        XCTAssertEqual(
            resolved.executable.binding,
            fixture.executable
        )
        XCTAssertEqual(
            resolved.configuration.binding,
            fixture.configuration
        )
        XCTAssertGreaterThan(resolved.executable.inode, 0)
    }

    func testAuthorizationRejectsDeclaredHashWithoutMatchingFile()
        throws
    {
        let fixture = try makeFixture()
        let wrongExecutable = PrimeArtifactBinding(
            relativePath:
                fixture.executable.relativePath,
            sha256: String(repeating: "0", count: 64),
            byteCount: fixture.executable.byteCount,
            purpose: .executable
        )
        let artifacts = PrimeExecutionArtifactBindings(
            executable: wrongExecutable,
            configuration: fixture.configuration,
            sourceSnapshot: fixture.source,
            mlxDefaultMetallib:
                fixture.artifacts
                    .mlxDefaultMetallib
        )
        let authorization = PrimeRunAuthorization(
            seeds: fixture.seeds,
            artifacts: artifacts,
            calibrationReceipt: fixture.calibration,
            externalExecutionExclusionReason:
                fixture.exclusionReason
        )
        XCTAssertThrowsError(
            try authorization.resolve(in: fixture.root)
        ) { error in
            guard case .hashMismatch =
                    error as? PrimeDurableArtifactError else {
                return XCTFail("unexpected error: \(error)")
            }
        }
    }

    func testAuthorizationRejectsTamperedArtifact()
        throws
    {
        let fixture = try makeFixture()
        let executableURL = temporaryURL
            .appendingPathComponent(
                fixture.executable.relativePath
            )
        XCTAssertEqual(chmod(executableURL.path, 0o755), 0)
        try Data("tampered-executable".utf8).write(
            to: executableURL
        )
        XCTAssertEqual(chmod(executableURL.path, 0o555), 0)

        XCTAssertThrowsError(
            try fixture.authorization.resolve(
                in: fixture.root
            )
        )
    }

    func testAuthorizationRejectsCorrectlyHashedSemanticTamper()
        throws
    {
        let fixture = try makeFixture()
        let changed = PrimeNative3BFP32ExecutionConfiguration(
            seeds: fixture.seeds,
            executable: fixture.executable,
            sourceSnapshot: fixture.source,
            mlxDefaultMetallib:
                fixture.artifacts
                    .mlxDefaultMetallib,
            pythonExecutionAuthorized: true,
            externalExecutionExclusionReason:
                fixture.exclusionReason
        )
        let changedBinding =
            try fixture.root.publishCanonical(
                changed,
                at: "semantic-tamper.json"
            )
        let artifacts = PrimeExecutionArtifactBindings(
            executable: fixture.executable,
            configuration: changedBinding,
            sourceSnapshot: fixture.source,
            mlxDefaultMetallib:
                fixture.artifacts
                    .mlxDefaultMetallib
        )
        let authorization = PrimeRunAuthorization(
            seeds: fixture.seeds,
            artifacts: artifacts,
            calibrationReceipt: fixture.calibration,
            externalExecutionExclusionReason:
                fixture.exclusionReason
        )

        XCTAssertThrowsError(
            try authorization.resolve(in: fixture.root)
        ) { error in
            guard case .invalidSemantics =
                    error as? PrimeDurableArtifactError else {
                return XCTFail("unexpected error: \(error)")
            }
        }
    }

    func testAuthorizationResolvesSeedProvenanceNotJustHex()
        throws
    {
        let fixture = try makeFixture()
        let wrongProvenance =
            PrimeHistoricalFieldProvenance(
                kind: .historicalArtifactField,
                artifactPath: "seed-provenance.json",
                artifactSHA256:
                    String(repeating: "f", count: 64),
                fieldPath: "initialization"
            )
        let wrongInitialization =
            PrimeHistoricalSeedRecord(
                domain: .initialization,
                value: fixture.seeds.initialization.value,
                provenance: wrongProvenance
            )
        let wrongSeeds = try PrimeExecutionSeeds(
            initialization: wrongInitialization,
            trainingSchedule:
                fixture.seeds.trainingSchedule,
            evaluation: fixture.seeds.evaluation
        )
        let changed = PrimeNative3BFP32ExecutionConfiguration(
            seeds: wrongSeeds,
            executable: fixture.executable,
            sourceSnapshot: fixture.source,
            mlxDefaultMetallib:
                fixture.artifacts
                    .mlxDefaultMetallib,
            externalExecutionExclusionReason:
                fixture.exclusionReason
        )
        let changedBinding =
            try fixture.root.publishCanonical(
                changed,
                at: "wrong-provenance-config.json"
            )
        let authorization = PrimeRunAuthorization(
            seeds: wrongSeeds,
            artifacts: PrimeExecutionArtifactBindings(
                executable: fixture.executable,
                configuration: changedBinding,
                sourceSnapshot: fixture.source,
                mlxDefaultMetallib:
                    fixture.artifacts
                        .mlxDefaultMetallib
            ),
            calibrationReceipt: fixture.calibration,
            externalExecutionExclusionReason:
                fixture.exclusionReason
        )

        XCTAssertThrowsError(
            try authorization.resolve(in: fixture.root)
        ) { error in
            guard case .hashMismatch =
                    error as? PrimeDurableArtifactError else {
                return XCTFail("unexpected error: \(error)")
            }
        }
    }

    private func makeFixture() throws -> Fixture {
        let root = try PrimeArtifactRoot(
            directoryURL: temporaryURL
        )
        let seedDocument = SeedDocument(
            initialization: 1_618,
            trainingSchedule: 2_718,
            evaluation: 3_141
        )
        let seedBinding = try root.publishCanonical(
            seedDocument,
            at: "seed-provenance.json"
        )
        let seeds = try PrimeExecutionSeeds(
            initialization: seedRecord(
                domain: .initialization,
                value: seedDocument.initialization,
                field: "initialization",
                binding: seedBinding
            ),
            trainingSchedule: seedRecord(
                domain: .trainingSchedule,
                value: seedDocument.trainingSchedule,
                field: "training_schedule",
                binding: seedBinding
            ),
            evaluation: seedRecord(
                domain: .evaluation,
                value: seedDocument.evaluation,
                field: "evaluation",
                binding: seedBinding
            )
        )
        let executable = try root.publish(
            Data("Mach-O-test-fixture".utf8),
            at: "PrimeGPUCalibration",
            purpose: .executable
        )
        let sourceSnapshot =
            try PrimeSwiftSourceSnapshotTestSupport
                .currentReleaseSnapshot()
        let source = try root.publishCanonical(
            sourceSnapshot,
            at: "source.snapshot"
        )
        let metallib =
            try PinnedMLXMetallibTestSupport
                .publish(in: root)
        let reason =
            PrimeSwiftExecutionBoundary.strictExclusionReason
        let configuration =
            PrimeNative3BFP32ExecutionConfiguration(
                seeds: seeds,
                executable: executable,
                sourceSnapshot: source,
                mlxDefaultMetallib: metallib,
                externalExecutionExclusionReason: reason
            )
        let configurationBinding =
            try root.publishCanonical(
                configuration,
                at: "calibration-config.json"
            )
        let artifacts = PrimeExecutionArtifactBindings(
            executable: executable,
            configuration: configurationBinding,
            sourceSnapshot: source,
            mlxDefaultMetallib: metallib
        )
        let evidence = PrimeExecutionReceiptEvidence(
            seeds: seeds,
            artifacts: artifacts,
            stopReason: .mechanicsCompleted,
            gpu: PrimeGPUObservations(
                deviceName: .observed("Device(gpu,0)"),
                metalExecution: .observed(true)
            ),
            memory: PrimeMemoryObservations(
                peakActiveBytes:
                    .observed(69_202_999_904),
                peakCacheBytes: .unavailable
            ),
            timing: PrimeTimingObservations(
                endToEndWallSeconds: .observed(60),
                processedPaddedPositionsPerSecond:
                    .observed(100),
                processedPaddedPositions:
                    .observed(6_000),
                supervisedTargetTokens:
                    .observed(5_900)
            ),
            pythonExecution: .observed(false),
            shellScientificAuthority:
                .observed(false),
            externalExecutionExclusionReason: reason
        )
        let receipt = PrimeCalibrationReceipt(
            receiptID: "calibration-1",
            recordedAtUTC: "2026-07-29T00:00:00Z",
            verdict: .feasible,
            evidence: evidence
        )
        let receiptBinding = try root.publishCanonical(
            receipt,
            at: "calibration-receipt.json"
        )
        return Fixture(
            root: root,
            seeds: seeds,
            executable: executable,
            source: source,
            configuration: configurationBinding,
            artifacts: artifacts,
            calibration: receiptBinding,
            exclusionReason: reason
        )
    }

    private func seedRecord(
        domain: PrimeSeedDomain,
        value: UInt64,
        field: String,
        binding: PrimeArtifactBinding
    ) -> PrimeHistoricalSeedRecord {
        PrimeHistoricalSeedRecord(
            domain: domain,
            value: value,
            provenance: PrimeHistoricalFieldProvenance(
                kind: .historicalArtifactField,
                artifactPath: binding.relativePath,
                artifactSHA256: binding.sha256,
                fieldPath: field
            )
        )
    }

    private func publishGenerated(
        _ data: Data,
        at relativePath: String,
        in root: PrimeArtifactRoot
    ) throws -> PrimeArtifactBinding {
        try root.publishGeneratedFile(
            at: relativePath,
            purpose: .immutableData,
            maximumByteCount: UInt64(data.count)
        ) { descriptor in
            try writeAll(data, to: descriptor)
        }
    }

    private func overwriteGeneratedFile(
        at url: URL,
        with data: Data,
        create: Bool = false,
        mode: mode_t = mode_t(0o600)
    ) throws {
        var flags =
            O_WRONLY | O_TRUNC | O_NOFOLLOW | O_CLOEXEC
        if create {
            flags |= O_CREAT | O_EXCL
        }
        let descriptor = open(
            url.path,
            flags,
            mode
        )
        guard descriptor >= 0 else {
            throw POSIXError(
                POSIXErrorCode(rawValue: errno)!
            )
        }
        defer { _ = close(descriptor) }
        try writeAll(data, to: descriptor)
    }

    private func readAll(
        from descriptor: Int32
    ) throws -> Data {
        guard lseek(descriptor, 0, SEEK_SET) >= 0 else {
            throw POSIXError(
                POSIXErrorCode(rawValue: errno)!
            )
        }
        var data = Data()
        var buffer = [UInt8](
            repeating: 0,
            count: 64 * 1024
        )
        while true {
            let count = buffer.withUnsafeMutableBytes {
                read(
                    descriptor,
                    $0.baseAddress,
                    $0.count
                )
            }
            if count < 0, errno == EINTR {
                continue
            }
            guard count >= 0 else {
                throw POSIXError(
                    POSIXErrorCode(rawValue: errno)!
                )
            }
            if count == 0 {
                return data
            }
            data.append(contentsOf: buffer[0 ..< count])
        }
    }

    private func writeAll(
        _ data: Data,
        to descriptor: Int32
    ) throws {
        try data.withUnsafeBytes { bytes in
            guard let base = bytes.baseAddress else {
                return
            }
            var offset = 0
            while offset < bytes.count {
                let count = write(
                    descriptor,
                    base.advanced(by: offset),
                    bytes.count - offset
                )
                if count < 0, errno == EINTR {
                    continue
                }
                guard count > 0 else {
                    throw POSIXError(
                        POSIXErrorCode(
                            rawValue: errno
                        )!
                    )
                }
                offset += count
            }
        }
    }

    private func onlyPartialArtifactURL()
        throws -> URL
    {
        let names = try partialArtifactNames()
        guard names.count == 1,
              let name = names.first else {
            throw FixtureError.unexpectedPartialCount
        }
        return temporaryURL.appendingPathComponent(name)
    }

    private func onlyNewPartialArtifactURL(
        excluding existingNames: Set<String>
    ) throws -> URL {
        let names = Set(
            try partialArtifactNames()
        ).subtracting(existingNames)
        guard names.count == 1,
              let name = names.first else {
            throw FixtureError.unexpectedPartialCount
        }
        return temporaryURL.appendingPathComponent(name)
    }

    private func assertReclaimedPartialArtifacts(
        count: Int
    ) throws {
        let names = try partialArtifactNames()
        XCTAssertEqual(names.count, count)
        for name in names {
            var metadata = stat()
            XCTAssertEqual(
                lstat(
                    temporaryURL
                        .appendingPathComponent(name).path,
                    &metadata
                ),
                0
            )
            XCTAssertEqual(
                metadata.st_mode & mode_t(S_IFMT),
                mode_t(S_IFREG)
            )
            XCTAssertEqual(metadata.st_size, 0)
        }
    }

    private func partialArtifactNames()
        throws -> [String]
    {
        try FileManager.default.contentsOfDirectory(
            atPath: temporaryURL.path
        ).filter {
            $0.hasPrefix(".prime-partial-")
        }
    }

    private func withArtifactRootPathReplaced<Result>(
        _ body: (URL) throws -> Result
    ) throws -> Result {
        let movedURL = temporaryURL
            .deletingLastPathComponent()
            .appendingPathComponent(
                "ergentics-prime-moved-\(UUID().uuidString)",
                isDirectory: true
            )
        guard rename(
            temporaryURL.path,
            movedURL.path
        ) == 0 else {
            throw POSIXError(
                POSIXErrorCode(rawValue: errno)!
            )
        }
        var restored = false
        defer {
            if !restored {
                try? FileManager.default.removeItem(
                    at: temporaryURL
                )
                _ = rename(
                    movedURL.path,
                    temporaryURL.path
                )
            }
        }
        guard mkdir(
            temporaryURL.path,
            mode_t(0o700)
        ) == 0 else {
            throw POSIXError(
                POSIXErrorCode(rawValue: errno)!
            )
        }
        let result = try body(temporaryURL)
        try FileManager.default.removeItem(
            at: temporaryURL
        )
        guard rename(
            movedURL.path,
            temporaryURL.path
        ) == 0 else {
            throw POSIXError(
                POSIXErrorCode(rawValue: errno)!
            )
        }
        restored = true
        return result
    }

    private func addUnapprovedExtendedAttribute(
        at url: URL,
        isDirectory: Bool
    ) throws {
        let flags = isDirectory
            ? O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC
            : O_RDWR | O_NOFOLLOW | O_CLOEXEC
        let descriptor = open(url.path, flags)
        guard descriptor >= 0 else {
            throw POSIXError(
                POSIXErrorCode(rawValue: errno)!
            )
        }
        defer {
            close(descriptor)
        }
        try addUnapprovedExtendedAttribute(
            to: descriptor
        )
    }

    private func addUnapprovedExtendedAttribute(
        to descriptor: Int32
    ) throws {
        let name =
            "com.ergentics.prime.unapproved-metadata"
        let value: [UInt8] = [1]
        let result = name.withCString { namePointer in
            value.withUnsafeBytes { valueBuffer in
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
        guard result == 0 else {
            throw POSIXError(
                POSIXErrorCode(rawValue: errno)!
            )
        }
    }

}
