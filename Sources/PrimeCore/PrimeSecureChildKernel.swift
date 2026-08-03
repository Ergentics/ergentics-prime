// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin
import Dispatch
import Foundation

public enum PrimeValidationWorkflowFixtureChildError:
    Error,
    Equatable,
    Sendable
{
    case rejected(String)
}

extension PrimeValidationWorkflowFixtureChildError:
    LocalizedError
{
    public var errorDescription: String? {
        switch self {
        case let .rejected(detail):
            "validation fixture child rejected: \(detail)"
        }
    }
}

/// The complete closed behavior surface of the first-party validation
/// fixture. No case carries an executable, argument, environment, timeout,
/// path, or resource-limit value.
public enum PrimeValidationWorkflowFixtureChildMode:
    String,
    CaseIterable,
    Codable,
    Equatable,
    Sendable
{
    case pass
    case nonzeroExit = "nonzero-exit"
    case boundedStreams = "bounded-streams"
    case overflow
    case hang
    case selfSignal = "self-signal"
    case descendantRetainsStreams = "descendant-retains-streams"
    case exitWithoutResult = "exit-without-result"
}

public enum PrimeSecureChildCompletion:
    Equatable,
    Sendable
{
    case exited(status: Int32)
    case signaled(signal: Int32, coreDumped: Bool)
    case wallClockLimit(exitStatus: Int32, signal: Int32)
    case streamContainmentLimit(exitStatus: Int32, signal: Int32)
}

public struct PrimeSecureChildExecutableObservation:
    Equatable,
    Sendable
{
    public let deviceID: UInt64
    public let inode: UInt64
    public let byteCount: UInt64
    public let sha256: String
    public let ownerUserID: UInt32
    public let ownerGroupID: UInt32
    public let permissionMode: UInt16
    public let linkCount: UInt64
    public let modificationTimeSeconds: Int64
    public let modificationTimeNanoseconds: Int64
    public let statusChangeTimeSeconds: Int64
    public let statusChangeTimeNanoseconds: Int64
}

public struct PrimeSecureChildDirectoryJoinObservation:
    Equatable,
    Sendable
{
    public let descriptorDeviceID: UInt64
    public let descriptorInode: UInt64
    public let childCurrentDirectoryDeviceID: UInt64
    public let childCurrentDirectoryInode: UInt64
    public let exactDescriptorJoinObserved: Bool
}

public struct PrimeSecureChildMappedExecutableObservation:
    Equatable,
    Sendable
{
    public let mappedExecutableAbsolutePath: String
    public let queryCount: Int
    public let terminalErrno: Int32
    public let exactDescriptorJoinObserved: Bool
}

public struct PrimeSecureChildStreamObservation:
    Sendable
{
    public let artifactBinding: PrimeArtifactBinding
    public let prefixData: Data
    public let totalByteCount: UInt64
    public let capturedByteCount: UInt64
    public let overflowed: Bool
    public let reachedEOF: Bool
    public let readErrorNumber: Int32
    public let writeErrorNumber: Int32
}

/// Closed evidence returned by the validation-fixture capability.
/// The absence of a public initializer prevents callers from minting a
/// successful process observation.
public struct PrimeValidationWorkflowFixtureChildResult:
    Sendable
{
    public let mode: PrimeValidationWorkflowFixtureChildMode
    public let processIdentifier: Int32
    public let appliedSpawnFlags: UInt16
    public let sessionIdentifier: Int32
    public let processGroupIdentifier: Int32
    public let executableAbsolutePath: String
    public let executable:
        PrimeSecureChildExecutableObservation
    public let workingDirectoryAbsolutePath: String
    public let resultDirectoryAbsolutePath: String
    public let workingDirectoryJoin:
        PrimeSecureChildDirectoryJoinObservation
    public let mappedExecutable:
        PrimeSecureChildMappedExecutableObservation
    public let exactPIDWait:
        PrimeNativeNeuralGateExactPIDWaitObservation
    public let completion: PrimeSecureChildCompletion
    public let standardOutput:
        PrimeSecureChildStreamObservation
    public let standardError:
        PrimeSecureChildStreamObservation
    public let fixtureResultBinding: PrimeArtifactBinding?
    public let fixtureResultData: Data?
    public let fixtureDescendantProcessIdentifier: Int32?
    public let preReapProcessGroupMembers: [Int32]?
    public let processGroupEmptyAfterReap: Bool
    public let fixtureContractSatisfied: Bool
}

/// One-shot authority to execute only `PrimeValidationWorkflowFixtureChild`.
/// `executableURL` is a locator, not execution authority: preparation opens
/// and retains a no-symlink descriptor, authenticates its exact identity, and
/// all later checks join back to that held identity. The closed mode derives
/// every argument, environment entry, timeout, result name, and stream cap.
public final class PrimeValidationWorkflowFixtureChildCapability:
    @unchecked Sendable
{
    private let lock = NSLock()
    private var consumed = false
    private let prepared: PrimeSecureChildPreparedFixture

    private init(
        prepared: PrimeSecureChildPreparedFixture
    ) {
        self.prepared = prepared
    }

    @available(macOS 26.0, *)
    public static func prepare(
        executableURL: URL,
        privateWorkingDirectoryURL: URL,
        privateResultDirectoryURL: URL,
        mode: PrimeValidationWorkflowFixtureChildMode
    ) throws -> Self {
        Self(
            prepared:
                try PrimeSecureChildPreparedFixture(
                    executableURL: executableURL,
                    workingDirectoryURL:
                        privateWorkingDirectoryURL,
                    resultDirectoryURL:
                        privateResultDirectoryURL,
                    mode: mode
                )
        )
    }

    @available(macOS 26.0, *)
    public func execute() throws
        -> PrimeValidationWorkflowFixtureChildResult
    {
        lock.lock()
        guard !consumed else {
            lock.unlock()
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("capability_already_consumed")
        }
        consumed = true
        lock.unlock()
        return try PrimeSecureChildKernel.execute(
            prepared
        )
    }
}

struct PrimeSecureChildSpawnHandle {
    let processIdentifier: Int32
    let appliedFlags: UInt16
    let spawnReturnCode: Int32
    let spawnReturnedMonotonicNanoseconds: UInt64
    let standardOutputReadDescriptor: Int32
    let standardErrorReadDescriptor: Int32
}

enum PrimeSecureChildFixtureBinaryPin {
    static let byteCount: UInt64 = 88_976
    static let sha256 =
        "470a32c4387b838e6f4a6540c2729ce" +
        "c03963767ad7d418912121b4d01e5267e"
}

fileprivate struct PrimeSecureChildFileIdentity:
    Equatable,
    Sendable
{
    let deviceID: UInt64
    let inode: UInt64

    init(deviceID: UInt64, inode: UInt64) {
        self.deviceID = deviceID
        self.inode = inode
    }

    init(_ status: stat) {
        deviceID = UInt64(bitPattern: Int64(status.st_dev))
        inode = UInt64(status.st_ino)
    }
}

struct PrimeSecureChildFixtureInvocation {
    static let resultLeaf =
        "prime-validation-workflow-fixture-result-v1.txt"
    static let stdoutLeaf =
        "prime-validation-workflow-stdout-prefix-v1.bin"
    static let stderrLeaf =
        "prime-validation-workflow-stderr-prefix-v1.bin"
    static let streamPrefixLimit: UInt64 = 65_536

    let mode: PrimeValidationWorkflowFixtureChildMode
    let arguments: [String]
    let orderedEnvironment: [(String, String)]
    let maximumWallNanoseconds: UInt64
    let configuredPayloadStandardOutputBytes: Int
    let configuredPayloadStandardErrorBytes: Int
    let configuredExitCode: Int32
    let expectsResult: Bool

    init(
        mode: PrimeValidationWorkflowFixtureChildMode,
        resultAbsolutePath: String
    ) throws {
        self.mode = mode
        orderedEnvironment = []

        let values: (Int, Int, Int32, Bool, UInt64)
        switch mode {
        case .pass:
            values = (0, 0, 0, true, 10)
        case .nonzeroExit:
            values = (0, 0, 23, true, 10)
        case .boundedStreams:
            values = (4_096, 2_048, 0, true, 10)
        case .overflow:
            values = (131_072, 131_072, 0, true, 10)
        case .hang:
            values = (0, 0, 0, true, 1)
        case .selfSignal:
            values = (0, 0, 0, true, 10)
        case .descendantRetainsStreams:
            values = (0, 0, 0, true, 1)
        case .exitWithoutResult:
            values = (0, 0, 0, false, 10)
        }
        configuredPayloadStandardOutputBytes = values.0
        configuredPayloadStandardErrorBytes = values.1
        configuredExitCode = values.2
        expectsResult = values.3
        maximumWallNanoseconds = values.4 * 1_000_000_000

        var exact = ["--mode", mode.rawValue]
        if expectsResult {
            try Self.requireFixtureResultPath(
                resultAbsolutePath
            )
            exact += [
                "--result-path",
                resultAbsolutePath,
            ]
        }
        if mode == .nonzeroExit {
            exact += [
                "--exit-code",
                String(configuredExitCode),
            ]
        }
        if mode == .boundedStreams || mode == .overflow {
            exact += [
                "--stdout-bytes",
                String(configuredPayloadStandardOutputBytes),
                "--stderr-bytes",
                String(configuredPayloadStandardErrorBytes),
            ]
        }
        arguments = exact
    }

    var expectedResultData: Data? {
        guard expectsResult,
              mode != .descendantRetainsStreams
        else { return nil }
        return Data(
            """
            schema=prime_validation_workflow_fixture_result_v1
            mode=\(mode.rawValue)
            configured_payload_stdout_bytes=\(configuredPayloadStandardOutputBytes)
            configured_payload_stderr_bytes=\(configuredPayloadStandardErrorBytes)
            configured_exit_code=\(configuredExitCode)

            """.utf8
        )
    }

    private static func requireFixtureResultPath(
        _ path: String
    ) throws {
        guard path.hasPrefix("/"),
              path != "/",
              !path.hasSuffix("/"),
              path.utf8.count <= 4_096,
              path.utf8.allSatisfy({
                  $0 >= 0x21 && $0 <= 0x7e
              }),
              !path.contains("\\")
        else {
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("fixture_result_path")
        }
    }
}

private enum PrimeSecureChildFixtureSemantic {
    static func descendantProcessIdentifier(
        from data: Data,
        invocation: PrimeSecureChildFixtureInvocation
    ) -> Int32? {
        guard invocation.mode == .descendantRetainsStreams,
              let text = String(data: data, encoding: .utf8),
              text.utf8.allSatisfy({ $0 >= 0x20 && $0 <= 0x7e || $0 == 0x0a })
        else { return nil }
        let lines = text.split(
            separator: "\n",
            omittingEmptySubsequences: false
        ).map(String.init)
        guard lines.count == 7,
              lines[0] == "schema=prime_validation_workflow_fixture_result_v1",
              lines[1] == "mode=descendant-retains-streams",
              lines[2] == "configured_payload_stdout_bytes=0",
              lines[3] == "configured_payload_stderr_bytes=0",
              lines[4] == "configured_exit_code=0",
              lines[5].hasPrefix("descendant_pid="),
              lines[6].isEmpty
        else { return nil }
        let raw = String(lines[5].dropFirst("descendant_pid=".count))
        guard !raw.isEmpty,
              raw.utf8.allSatisfy({ $0 >= 48 && $0 <= 57 }),
              let value = Int32(raw),
              value > 0,
              String(value) == raw
        else { return nil }
        return value
    }
}

private final class PrimeSecureChildPreparedFixture:
    @unchecked Sendable
{
    let mode: PrimeValidationWorkflowFixtureChildMode
    let executable: PrimeSecureChildHeldExecutable
    let workingDirectory: PrimeSecureChildHeldDirectory
    let resultDirectory: PrimeSecureChildHeldDirectory
    let invocation: PrimeSecureChildFixtureInvocation

    init(
        executableURL: URL,
        workingDirectoryURL: URL,
        resultDirectoryURL: URL,
        mode: PrimeValidationWorkflowFixtureChildMode
    ) throws {
        executable = try PrimeSecureChildHeldExecutable(
            url: executableURL
        )
        workingDirectory = try PrimeSecureChildHeldDirectory(
            url: workingDirectoryURL,
            label: "working_directory",
            permitsControlledEntryMutations: false
        )
        resultDirectory = try PrimeSecureChildHeldDirectory(
            url: resultDirectoryURL,
            label: "result_directory",
            permitsControlledEntryMutations: true
        )
        guard workingDirectory.identity.deviceID
                != resultDirectory.identity.deviceID
                || workingDirectory.identity.inode
                != resultDirectory.identity.inode
        else {
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("working_and_result_directories_not_disjoint")
        }
        invocation = try PrimeSecureChildFixtureInvocation(
            mode: mode,
            resultAbsolutePath:
                resultDirectory.absolutePath
                + "/"
                + PrimeSecureChildFixtureInvocation.resultLeaf
        )
        self.mode = mode
    }
}

final class PrimeSecureChildHeldDirectory:
    @unchecked Sendable
{
    let root: PrimeArtifactRoot
    let absolutePath: String
    let identity: PrimeArtifactRootIdentity
    private(set) var descriptor: Int32
    private let label: String
    private let permitsControlledEntryMutations: Bool
    private let entryLedgerLock = NSLock()
    private var admittedEntries:
        [String: PrimeSecureChildFileIdentity] = [:]

    init(
        url: URL,
        label: String,
        permitsControlledEntryMutations: Bool
    ) throws {
        try PrimeSecureChildPath.requireCanonicalDirectoryURL(
            url,
            label: label
        )
        root = try PrimeArtifactRoot(directoryURL: url)
        try root.requirePrivateRootMode()
        try root.requireEmpty()
        identity = try root.verifiedRootIdentity()
        descriptor = try root
            .duplicateTrustedRootDescriptorForInventory()
        absolutePath = url.path
        self.label = label
        self.permitsControlledEntryMutations =
            permitsControlledEntryMutations
        do {
            _ = try PrimeNativeNeuralGateHeldSourceClosure
                .requireLocalAPFS(
                    rootDescriptor: descriptor
                )
            try requireStable()
        } catch {
            Darwin.close(descriptor)
            descriptor = -1
            throw error
        }
    }

    deinit {
        if descriptor >= 0 {
            Darwin.close(descriptor)
        }
    }

    func requireStable() throws {
        entryLedgerLock.lock()
        let expectedEntries = admittedEntries
        entryLedgerLock.unlock()
        let linkCountAddition = identity.linkCount
            .addingReportingOverflow(
                UInt64(expectedEntries.count)
            )
        guard !linkCountAddition.overflow else {
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("\(label)_link_count_overflow")
        }
        let expectedLinkCount = permitsControlledEntryMutations
            ? linkCountAddition.partialValue
            : identity.linkCount
        let current = try root.verifiedRootIdentity()
        var pathStatus = stat()
        guard descriptor >= 3,
              stableCapabilityIdentity(current, identity),
              current.linkCount == expectedLinkCount,
              permitsControlledEntryMutations || current == identity,
              lstat(absolutePath, &pathStatus) == 0,
              UInt64(bitPattern: Int64(pathStatus.st_dev))
                == identity.deviceID,
              UInt64(pathStatus.st_ino) == identity.inode,
              pathStatus.st_mode & mode_t(S_IFMT)
                == mode_t(S_IFDIR),
              pathStatus.st_uid == geteuid(),
              pathStatus.st_gid == identity.ownerGroupID,
              pathStatus.st_mode & mode_t(0o7777)
                == mode_t(0o700),
              UInt64(pathStatus.st_nlink) == expectedLinkCount,
              fcntl(descriptor, F_GETFD) & FD_CLOEXEC != 0
        else {
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("\(label)_changed")
        }
        if permitsControlledEntryMutations {
            guard try directoryEntries() == expectedEntries else {
                throw PrimeValidationWorkflowFixtureChildError
                    .rejected("\(label)_entry_ledger")
            }
        }
    }

    func createEmptyCaptureFile(
        leaf: String
    ) throws -> Int32 {
        let opened = leaf.withCString {
            openat(
                descriptor,
                $0,
                O_RDWR | O_CREAT | O_EXCL
                    | O_NOFOLLOW | O_CLOEXEC,
                mode_t(0o600)
            )
        }
        guard opened >= 3 else {
            if opened >= 0 { Darwin.close(opened) }
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("capture_file_open_\(errno)")
        }
        var status = stat()
        guard fstat(opened, &status) == 0,
              status.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
              status.st_uid == geteuid(),
              status.st_nlink == 1,
              status.st_mode & mode_t(0o7777) == mode_t(0o600),
              status.st_size == 0,
              fcntl(opened, F_GETFD) & FD_CLOEXEC != 0
        else {
            Darwin.close(opened)
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("capture_file_metadata")
        }
        entryLedgerLock.lock()
        let inserted = admittedEntries.updateValue(
            PrimeSecureChildFileIdentity(status),
            forKey: leaf
        ) == nil
        entryLedgerLock.unlock()
        guard inserted else {
            Darwin.close(opened)
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("capture_file_duplicate_ledger")
        }
        try requireStable()
        try synchronizeNamespace()
        return opened
    }

    func admitExpectedFixtureResult(
        expectsResult: Bool
    ) throws {
        if expectsResult {
            let leaf = PrimeSecureChildFixtureInvocation.resultLeaf
            let opened = leaf.withCString {
                openat(
                    descriptor,
                    $0,
                    O_RDONLY | O_NOFOLLOW | O_CLOEXEC
                )
            }
            guard opened >= 3 else {
                if opened >= 0 { Darwin.close(opened) }
                throw PrimeValidationWorkflowFixtureChildError
                    .rejected("fixture_result_admission_open_\(errno)")
            }
            var status = stat()
            let admitted = fstat(opened, &status) == 0
                && status.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG)
                && status.st_uid == geteuid()
                && status.st_nlink == 1
                && status.st_mode & mode_t(0o7777) == mode_t(0o600)
                && status.st_size > 0
                && status.st_size <= 4_096
                && fcntl(opened, F_GETFD) & FD_CLOEXEC != 0
            Darwin.close(opened)
            guard admitted else {
                throw PrimeValidationWorkflowFixtureChildError
                    .rejected("fixture_result_admission_metadata")
            }
            entryLedgerLock.lock()
            let inserted = admittedEntries.updateValue(
                PrimeSecureChildFileIdentity(status),
                forKey: leaf
            ) == nil
            entryLedgerLock.unlock()
            guard inserted else {
                throw PrimeValidationWorkflowFixtureChildError
                    .rejected("fixture_result_duplicate_ledger")
            }
        }
        try requireStable()
        try synchronizeNamespace()
    }

    func immutableBinding(
        leaf: String,
        maximumByteCount: UInt64
    ) throws -> PrimeArtifactBinding {
        try root.bindExisting(
            at: leaf,
            purpose: .immutableData,
            maximumByteCount: maximumByteCount
        )
    }

    func readAndFreezeFixtureResult(
        invocation: PrimeSecureChildFixtureInvocation
    ) throws -> (PrimeArtifactBinding?, Data?) {
        let leaf = PrimeSecureChildFixtureInvocation.resultLeaf
        let descriptor = leaf.withCString {
            openat(
                self.descriptor,
                $0,
                O_RDONLY | O_NOFOLLOW | O_CLOEXEC
            )
        }
        if !invocation.expectsResult {
            guard descriptor < 0, errno == ENOENT else {
                if descriptor >= 0 { Darwin.close(descriptor) }
                throw PrimeValidationWorkflowFixtureChildError
                    .rejected("unexpected_fixture_result")
            }
            return (nil, nil)
        }
        guard descriptor >= 3 else {
            if descriptor >= 0 { Darwin.close(descriptor) }
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("fixture_result_missing_\(errno)")
        }
        defer { Darwin.close(descriptor) }
        entryLedgerLock.lock()
        let admittedIdentity = admittedEntries[leaf]
        entryLedgerLock.unlock()
        var status = stat()
        guard fstat(descriptor, &status) == 0,
              PrimeSecureChildFileIdentity(status) == admittedIdentity,
              status.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
              status.st_uid == geteuid(),
              status.st_nlink == 1,
              status.st_mode & mode_t(0o7777) == mode_t(0o600),
              status.st_size > 0,
              status.st_size <= 4_096,
              fcntl(descriptor, F_GETFD) & FD_CLOEXEC != 0
        else {
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("fixture_result_metadata")
        }
        let data = try PrimeSecureChildPath.readExact(
            descriptor: descriptor,
            byteCount: Int(status.st_size)
        )
        if invocation.mode == .descendantRetainsStreams {
            guard PrimeSecureChildFixtureSemantic
                    .descendantProcessIdentifier(
                        from: data,
                        invocation: invocation
                    ) != nil
            else {
                throw PrimeValidationWorkflowFixtureChildError
                    .rejected("fixture_descendant_result_content")
            }
        } else {
            guard data == invocation.expectedResultData else {
                throw PrimeValidationWorkflowFixtureChildError
                    .rejected("fixture_result_content")
            }
        }
        guard fchmod(descriptor, mode_t(0o444)) == 0
        else {
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("fixture_result_content_or_freeze")
        }
        try Self.synchronize(descriptor, label: "fixture_result_file")
        var frozenStatus = stat()
        guard fstat(descriptor, &frozenStatus) == 0,
              PrimeSecureChildFileIdentity(frozenStatus)
                == admittedIdentity,
              frozenStatus.st_mode & mode_t(0o7777) == mode_t(0o444),
              frozenStatus.st_size == status.st_size
        else {
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("fixture_result_frozen_identity")
        }
        try requireStable()
        let binding = try immutableBinding(
            leaf: leaf,
            maximumByteCount: UInt64(status.st_size)
        )
        let expectedIdentity = PrimeSecureChildFileIdentity(frozenStatus)
        guard binding.sha256 == PrimeSHA256.hexDigest(of: data) else {
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("fixture_result_binding_digest")
        }
        let reboundData = try root.readVerified(
            binding,
            maximumByteCount: UInt64(frozenStatus.st_size)
        )
        guard reboundData == data else {
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("fixture_result_rebound_content")
        }
        try requireImmutableEntry(
            leaf: leaf,
            expectedIdentity: expectedIdentity,
            expectedByteCount: UInt64(frozenStatus.st_size),
            expectedSHA256: binding.sha256
        )
        return (binding, data)
    }

    private func stableCapabilityIdentity(
        _ lhs: PrimeArtifactRootIdentity,
        _ rhs: PrimeArtifactRootIdentity
    ) -> Bool {
        lhs.deviceID == rhs.deviceID
            && lhs.inode == rhs.inode
            && lhs.ownerUserID == rhs.ownerUserID
            && lhs.ownerGroupID == rhs.ownerGroupID
            && lhs.actualMode == rhs.actualMode
    }

    fileprivate func requireImmutableEntry(
        leaf: String,
        expectedIdentity: PrimeSecureChildFileIdentity,
        expectedByteCount: UInt64,
        expectedSHA256: String
    ) throws {
        let opened = leaf.withCString {
            openat(
                descriptor,
                $0,
                O_RDONLY | O_NOFOLLOW | O_CLOEXEC
            )
        }
        guard opened >= 3 else {
            if opened >= 0 { Darwin.close(opened) }
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("immutable_entry_open_\(errno)")
        }
        defer { Darwin.close(opened) }
        var before = stat()
        guard fstat(opened, &before) == 0,
              PrimeSecureChildFileIdentity(before) == expectedIdentity,
              before.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
              before.st_uid == geteuid(),
              before.st_nlink == 1,
              before.st_mode & mode_t(0o7777) == mode_t(0o444),
              before.st_size >= 0,
              UInt64(before.st_size) == expectedByteCount
        else {
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("immutable_entry_metadata")
        }
        let data = try PrimeSecureChildPath.readExact(
            descriptor: opened,
            byteCount: Int(before.st_size)
        )
        var after = stat()
        guard PrimeSHA256.hexDigest(of: data) == expectedSHA256,
              fstat(opened, &after) == 0,
              PrimeSecureChildFileIdentity(after) == expectedIdentity,
              after.st_mode == before.st_mode,
              after.st_size == before.st_size,
              after.st_mtimespec.tv_sec == before.st_mtimespec.tv_sec,
              after.st_mtimespec.tv_nsec == before.st_mtimespec.tv_nsec,
              after.st_ctimespec.tv_sec == before.st_ctimespec.tv_sec,
              after.st_ctimespec.tv_nsec == before.st_ctimespec.tv_nsec
        else {
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("immutable_entry_content_or_change")
        }
    }

    func requireImmutableCapture(
        leaf: String,
        snapshot: PrimeSecureChildFileBackedDrainSnapshot
    ) throws {
        guard snapshot.outputMetadataObserved else {
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("immutable_capture_missing_metadata")
        }
        try requireImmutableEntry(
            leaf: leaf,
            expectedIdentity: PrimeSecureChildFileIdentity(
                deviceID: snapshot.outputDeviceID,
                inode: snapshot.outputInode
            ),
            expectedByteCount: snapshot.outputByteCount,
            expectedSHA256: snapshot.outputSHA256
        )
    }

    private func directoryEntries() throws
        -> [String: PrimeSecureChildFileIdentity]
    {
        let duplicate = fcntl(descriptor, F_DUPFD_CLOEXEC, 3)
        guard duplicate >= 3,
              lseek(duplicate, 0, SEEK_SET) >= 0,
              let directory = fdopendir(duplicate)
        else {
            if duplicate >= 0 { Darwin.close(duplicate) }
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("\(label)_entry_enumeration_open")
        }
        defer { closedir(directory) }
        var result: [String: PrimeSecureChildFileIdentity] = [:]
        errno = 0
        while let entry = readdir(directory) {
            let name = withUnsafePointer(to: entry.pointee.d_name) {
                $0.withMemoryRebound(
                    to: CChar.self,
                    capacity: Int(MAXNAMLEN) + 1
                ) {
                    String(cString: $0)
                }
            }
            if name != "." && name != ".." {
                var status = stat()
                let observed = name.withCString {
                    fstatat(
                        descriptor,
                        $0,
                        &status,
                        AT_SYMLINK_NOFOLLOW
                    )
                }
                guard !name.isEmpty,
                      observed == 0,
                      status.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
                      result.updateValue(
                          PrimeSecureChildFileIdentity(status),
                          forKey: name
                      ) == nil
                else {
                    throw PrimeValidationWorkflowFixtureChildError
                        .rejected("\(label)_entry_enumeration_duplicate")
                }
            }
            errno = 0
        }
        guard errno == 0 else {
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("\(label)_entry_enumeration_\(errno)")
        }
        return result
    }

    private func synchronizeNamespace() throws {
        try Self.synchronize(
            descriptor,
            label: "\(label)_namespace"
        )
    }

    private static func synchronize(
        _ descriptor: Int32,
        label: String
    ) throws {
        guard fsync(descriptor) == 0,
              fcntl(descriptor, F_FULLFSYNC) == 0
        else {
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("\(label)_synchronize_\(errno)")
        }
    }
}

private final class PrimeSecureChildHeldExecutable:
    @unchecked Sendable
{
    static let expectedBasename =
        "PrimeValidationWorkflowFixtureChild"
    // Reproduced from independent arm64 Release compilations at disjoint
    // absolute paths. The linker's `-S` final-image audit is the authority
    // that removes path-bearing N_OSO symbols. The binaries compared
    // byte-for-byte, retained the identical
    // content-derived LC_UUID E84D1551-8A67-339F-846C-4A0EA37ABAFB, and the
    // launch canary reached the fixture parser before this authority froze.
    static let expectedByteCount =
        PrimeSecureChildFixtureBinaryPin.byteCount
    static let expectedSHA256 =
        PrimeSecureChildFixtureBinaryPin.sha256

    let absolutePath: String
    private(set) var descriptor: Int32
    let admittedSnapshot:
        PrimeNativeNeuralGateExecutableDescriptorSnapshot
    let observation: PrimeSecureChildExecutableObservation

    init(url: URL) throws {
        guard Self.expectedByteCount > 0,
              Self.expectedSHA256.utf8.count == 64,
              Self.expectedSHA256
                != String(repeating: "0", count: 64),
              Self.expectedSHA256.utf8.allSatisfy({
                  ($0 >= 48 && $0 <= 57)
                    || ($0 >= 97 && $0 <= 102)
              })
        else {
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("fixture_binary_pin_unconfigured_abstain")
        }
        try PrimeSecureChildPath.requireCanonicalFileURL(
            url,
            expectedBasename: Self.expectedBasename
        )
        absolutePath = url.path
        descriptor = Darwin.open(
            absolutePath,
            O_RDONLY | O_NOFOLLOW_ANY | O_CLOEXEC
        )
        guard descriptor >= 3 else {
            if descriptor >= 0 { Darwin.close(descriptor) }
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("executable_open_\(errno)")
        }
        do {
            let snapshot = try Self.readSnapshot(
                descriptor: descriptor,
                absolutePath: absolutePath
            )
            admittedSnapshot = snapshot
            observation = Self.observation(snapshot)
        } catch {
            Darwin.close(descriptor)
            descriptor = -1
            throw error
        }
    }

    deinit {
        if descriptor >= 0 { Darwin.close(descriptor) }
    }

    func requireUnchanged() throws {
        let current = try Self.readSnapshot(
            descriptor: descriptor,
            absolutePath: absolutePath
        )
        guard current == admittedSnapshot else {
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("executable_changed")
        }
    }

    private static func readSnapshot(
        descriptor: Int32,
        absolutePath: String
    ) throws -> PrimeNativeNeuralGateExecutableDescriptorSnapshot {
        var before = stat()
        var pathStatus = stat()
        guard descriptor >= 3,
              fstat(descriptor, &before) == 0,
              lstat(absolutePath, &pathStatus) == 0,
              sameIdentity(before, pathStatus),
              before.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
              before.st_uid == geteuid(),
              before.st_nlink == 1,
              before.st_size > 0,
              UInt64(before.st_size) == expectedByteCount,
              before.st_mode & mode_t(0o7000) == 0,
              before.st_mode & mode_t(0o022) == 0,
              before.st_mode & mode_t(0o500) == mode_t(0o500),
              fcntl(descriptor, F_GETFD) & FD_CLOEXEC != 0
        else {
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("executable_metadata")
        }
        try PrimeArtifactRoot
            .requireTrustedInventoryArtifactDescriptor(
                descriptor,
                path: absolutePath
            )
        let data = try PrimeSecureChildPath.readExact(
            descriptor: descriptor,
            byteCount: Int(before.st_size)
        )
        var after = stat()
        guard fstat(descriptor, &after) == 0,
              sameIdentity(before, after) else {
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("executable_changed_during_read")
        }
        let digest = PrimeSHA256.hexDigest(of: data)
        guard digest == expectedSHA256 else {
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("executable_digest")
        }
        return PrimeNativeNeuralGateExecutableDescriptorSnapshot(
            deviceID: UInt64(bitPattern: Int64(after.st_dev)),
            inode: UInt64(after.st_ino),
            byteCount: UInt64(after.st_size),
            sha256: digest,
            ownerUserID: after.st_uid,
            ownerGroupID: after.st_gid,
            permissionMode:
                UInt16(after.st_mode & mode_t(0o7777)),
            linkCount: UInt64(after.st_nlink),
            modificationTimeSeconds:
                Int64(after.st_mtimespec.tv_sec),
            modificationTimeNanoseconds:
                Int64(after.st_mtimespec.tv_nsec),
            statusChangeTimeSeconds:
                Int64(after.st_ctimespec.tv_sec),
            statusChangeTimeNanoseconds:
                Int64(after.st_ctimespec.tv_nsec),
            regularFile: true,
            openedWithNoSymbolicLinksInPath: true,
            closeOnExec: true
        )
    }

    private static func observation(
        _ value: PrimeNativeNeuralGateExecutableDescriptorSnapshot
    ) -> PrimeSecureChildExecutableObservation {
        PrimeSecureChildExecutableObservation(
            deviceID: value.deviceID,
            inode: value.inode,
            byteCount: value.byteCount,
            sha256: value.sha256,
            ownerUserID: value.ownerUserID,
            ownerGroupID: value.ownerGroupID,
            permissionMode: value.permissionMode,
            linkCount: value.linkCount,
            modificationTimeSeconds:
                value.modificationTimeSeconds,
            modificationTimeNanoseconds:
                value.modificationTimeNanoseconds,
            statusChangeTimeSeconds:
                value.statusChangeTimeSeconds,
            statusChangeTimeNanoseconds:
                value.statusChangeTimeNanoseconds
        )
    }

    private static func sameIdentity(
        _ lhs: stat,
        _ rhs: stat
    ) -> Bool {
        lhs.st_dev == rhs.st_dev
            && lhs.st_ino == rhs.st_ino
            && lhs.st_size == rhs.st_size
            && lhs.st_uid == rhs.st_uid
            && lhs.st_gid == rhs.st_gid
            && lhs.st_mode == rhs.st_mode
            && lhs.st_nlink == rhs.st_nlink
            && lhs.st_mtimespec.tv_sec == rhs.st_mtimespec.tv_sec
            && lhs.st_mtimespec.tv_nsec == rhs.st_mtimespec.tv_nsec
            && lhs.st_ctimespec.tv_sec == rhs.st_ctimespec.tv_sec
            && lhs.st_ctimespec.tv_nsec == rhs.st_ctimespec.tv_nsec
    }
}

private enum PrimeSecureChildKernel {
    @available(macOS 26.0, *)
    static func execute(
        _ prepared: PrimeSecureChildPreparedFixture
    ) throws -> PrimeValidationWorkflowFixtureChildResult {
        try prepared.executable.requireUnchanged()
        try prepared.workingDirectory.requireStable()
        try prepared.resultDirectory.requireStable()

        let stdoutFile = try prepared.resultDirectory
            .createEmptyCaptureFile(
                leaf: PrimeSecureChildFixtureInvocation.stdoutLeaf
            )
        let stderrFile: Int32
        do {
            stderrFile = try prepared.resultDirectory
                .createEmptyCaptureFile(
                    leaf: PrimeSecureChildFixtureInvocation.stderrLeaf
                )
        } catch {
            Darwin.close(stdoutFile)
            throw error
        }

        let spawn: PrimeSecureChildSpawnHandle
        do {
            spawn = try PrimeNativeNeuralGateSecureExternalChildCapture
                .spawnSuspendedSecureChild(
                    executableAbsolutePath:
                        prepared.executable.absolutePath,
                    workingDirectoryDescriptor:
                        prepared.workingDirectory.descriptor,
                    exactArguments:
                        prepared.invocation.arguments,
                    orderedEnvironment:
                        prepared.invocation.orderedEnvironment
                )
        } catch {
            Darwin.close(stdoutFile)
            Darwin.close(stderrFile)
            throw error
        }

        let stdoutDrain = PrimeSecureChildFileBackedBoundedDrain(
            inputDescriptor:
                spawn.standardOutputReadDescriptor,
            outputDescriptor: stdoutFile,
            maximumByteCount:
                PrimeSecureChildFixtureInvocation.streamPrefixLimit
        )
        let stderrDrain = PrimeSecureChildFileBackedBoundedDrain(
            inputDescriptor:
                spawn.standardErrorReadDescriptor,
            outputDescriptor: stderrFile,
            maximumByteCount:
                PrimeSecureChildFixtureInvocation.streamPrefixLimit
        )
        let drains = DispatchGroup()
        stdoutDrain.start(group: drains)
        stderrDrain.start(group: drains)

        let child = PrimeNativeNeuralGateSecureChildLifecycle
            .liveDarwin(processIdentifier: spawn.processIdentifier)
        child.startDeathObservation()

        let sessionIdentifier: Int32
        let processGroupIdentifier: Int32
        let workingDirectoryJoin:
            PrimeSecureChildDirectoryJoinObservation
        let mappedExecutable:
            PrimeSecureChildMappedExecutableObservation
        do {
            sessionIdentifier = getsid(spawn.processIdentifier)
            processGroupIdentifier = getpgid(spawn.processIdentifier)
            guard sessionIdentifier == spawn.processIdentifier,
                  processGroupIdentifier == spawn.processIdentifier,
                  child.establishIsolatedSessionAndDedicatedGroup()
            else {
                throw rejected("child_session_or_process_group")
            }
            workingDirectoryJoin = try childWorkingDirectoryJoin(
                processIdentifier: spawn.processIdentifier,
                directory: prepared.workingDirectory
            )
            let transcript = try PrimeNativeNeuralGateSecureExternalChildCapture
                .captureMappedExecutableForSecureChild(
                    processIdentifier: spawn.processIdentifier,
                    executableSnapshot:
                        prepared.executable.admittedSnapshot,
                    expectedExecutableAbsolutePath:
                        prepared.executable.absolutePath
                )
            mappedExecutable = PrimeSecureChildMappedExecutableObservation(
                mappedExecutableAbsolutePath:
                    transcript.mappedExecutablePathTelemetry,
                queryCount: transcript.queries.count,
                terminalErrno: transcript.terminalErrno,
                exactDescriptorJoinObserved: true
            )
            try prepared.executable.requireUnchanged()
            try prepared.workingDirectory.requireStable()
            try prepared.resultDirectory.requireStable()
        } catch {
            containOrFailStop(child)
            waitForDrainsOrFailStop(drains)
            throw error
        }

        errno = 0
        guard Darwin.kill(spawn.processIdentifier, SIGCONT) == 0,
              child.markResumed()
        else {
            let failure = errno
            containOrFailStop(child)
            waitForDrainsOrFailStop(drains)
            throw rejected("child_resume_\(failure)")
        }

        let deadline = deadline(
            after: prepared.invocation.maximumWallNanoseconds
        )
        var wallClockLimitReached = false
        var streamContainmentLimitReached = false
        var preReapMembers: [Int32]?
        let wait: PrimeNativeNeuralGateExactPIDWaitObservation

        if !child.observeDeath(untilNanoseconds: deadline) {
            wallClockLimitReached = true
            preReapMembers = child.processGroupMemberIdentifiers()
            containOrFailStop(child)
            waitForDrainsOrFailStop(drains)
            wait = requireRetainedWait(child)
        } else if drains.wait(
            timeout: DispatchTime(uptimeNanoseconds: deadline)
        ) != .success {
            streamContainmentLimitReached = true
            preReapMembers = child.processGroupMemberIdentifiers()
            containOrFailStop(child)
            waitForDrainsOrFailStop(drains)
            wait = requireRetainedWait(child)
        } else {
            preReapMembers = child.processGroupMemberIdentifiers()
            guard preReapMembers == [spawn.processIdentifier] else {
                streamContainmentLimitReached = true
                containOrFailStop(child)
                waitForDrainsOrFailStop(drains)
                wait = requireRetainedWait(child)
                return try finish(
                    prepared: prepared,
                    spawn: spawn,
                    sessionIdentifier: sessionIdentifier,
                    processGroupIdentifier: processGroupIdentifier,
                    workingDirectoryJoin: workingDirectoryJoin,
                    mappedExecutable: mappedExecutable,
                    wait: wait,
                    wallClockLimitReached: wallClockLimitReached,
                    streamContainmentLimitReached:
                        streamContainmentLimitReached,
                    preReapMembers: preReapMembers,
                    stdoutDrain: stdoutDrain,
                    stderrDrain: stderrDrain
                )
            }
            switch child.reapAfterObservedDeath() {
            case let .reaped(observation):
                wait = observation
            case let .mustFailStop(reason):
                failStop(reason)
            }
        }

        return try finish(
            prepared: prepared,
            spawn: spawn,
            sessionIdentifier: sessionIdentifier,
            processGroupIdentifier: processGroupIdentifier,
            workingDirectoryJoin: workingDirectoryJoin,
            mappedExecutable: mappedExecutable,
            wait: wait,
            wallClockLimitReached: wallClockLimitReached,
            streamContainmentLimitReached:
                streamContainmentLimitReached,
            preReapMembers: preReapMembers,
            stdoutDrain: stdoutDrain,
            stderrDrain: stderrDrain
        )
    }

    private static func finish(
        prepared: PrimeSecureChildPreparedFixture,
        spawn: PrimeSecureChildSpawnHandle,
        sessionIdentifier: Int32,
        processGroupIdentifier: Int32,
        workingDirectoryJoin:
            PrimeSecureChildDirectoryJoinObservation,
        mappedExecutable:
            PrimeSecureChildMappedExecutableObservation,
        wait: PrimeNativeNeuralGateExactPIDWaitObservation,
        wallClockLimitReached: Bool,
        streamContainmentLimitReached: Bool,
        preReapMembers: [Int32]?,
        stdoutDrain: PrimeSecureChildFileBackedBoundedDrain,
        stderrDrain: PrimeSecureChildFileBackedBoundedDrain
    ) throws -> PrimeValidationWorkflowFixtureChildResult {
        try prepared.executable.requireUnchanged()
        try prepared.workingDirectory.requireStable()
        try prepared.resultDirectory.admitExpectedFixtureResult(
            expectsResult: prepared.invocation.expectsResult
        )
        try prepared.resultDirectory.requireStable()
        let stdout = try streamObservation(
            drain: stdoutDrain,
            directory: prepared.resultDirectory,
            leaf: PrimeSecureChildFixtureInvocation.stdoutLeaf
        )
        let stderr = try streamObservation(
            drain: stderrDrain,
            directory: prepared.resultDirectory,
            leaf: PrimeSecureChildFixtureInvocation.stderrLeaf
        )
        let fixture = try prepared.resultDirectory
            .readAndFreezeFixtureResult(
                invocation: prepared.invocation
            )
        let descendantProcessIdentifier = fixture.1.flatMap {
            PrimeSecureChildFixtureSemantic
                .descendantProcessIdentifier(
                    from: $0,
                    invocation: prepared.invocation
                )
        }
        let completion = completion(
            wait: wait,
            wallClockLimitReached: wallClockLimitReached,
            streamContainmentLimitReached:
                streamContainmentLimitReached
        )
        let satisfied = fixtureContractSatisfied(
            invocation: prepared.invocation,
            completion: completion,
            stdout: stdout,
            stderr: stderr,
            fixtureResultData: fixture.1,
            descendantProcessIdentifier:
                descendantProcessIdentifier,
            parentProcessIdentifier:
                spawn.processIdentifier,
            preReapMembers: preReapMembers
        )
        return PrimeValidationWorkflowFixtureChildResult(
            mode: prepared.mode,
            processIdentifier: spawn.processIdentifier,
            appliedSpawnFlags: spawn.appliedFlags,
            sessionIdentifier: sessionIdentifier,
            processGroupIdentifier: processGroupIdentifier,
            executableAbsolutePath:
                prepared.executable.absolutePath,
            executable: prepared.executable.observation,
            workingDirectoryAbsolutePath:
                prepared.workingDirectory.absolutePath,
            resultDirectoryAbsolutePath:
                prepared.resultDirectory.absolutePath,
            workingDirectoryJoin: workingDirectoryJoin,
            mappedExecutable: mappedExecutable,
            exactPIDWait: wait,
            completion: completion,
            standardOutput: stdout,
            standardError: stderr,
            fixtureResultBinding: fixture.0,
            fixtureResultData: fixture.1,
            fixtureDescendantProcessIdentifier:
                descendantProcessIdentifier,
            preReapProcessGroupMembers: preReapMembers,
            processGroupEmptyAfterReap: true,
            fixtureContractSatisfied: satisfied
        )
    }

    private static func streamObservation(
        drain: PrimeSecureChildFileBackedBoundedDrain,
        directory: PrimeSecureChildHeldDirectory,
        leaf: String
    ) throws -> PrimeSecureChildStreamObservation {
        let snapshot = drain.snapshot()
        guard snapshot.workerFinished,
              snapshot.reachedEOF,
              snapshot.readErrorNumber == 0,
              snapshot.writeErrorNumber == 0,
              snapshot.outputMetadataObserved,
              snapshot.outputByteCount
                == snapshot.capturedByteCount,
              snapshot.outputPermissionMode == 0o444
        else {
            throw rejected("stream_capture")
        }
        try directory.requireImmutableCapture(
            leaf: leaf,
            snapshot: snapshot
        )
        let binding = try directory.immutableBinding(
            leaf: leaf,
            maximumByteCount:
                PrimeSecureChildFixtureInvocation.streamPrefixLimit
        )
        let data = try directory.root.readVerified(
            binding,
            maximumByteCount:
                PrimeSecureChildFixtureInvocation.streamPrefixLimit
        )
        guard UInt64(data.count) == snapshot.capturedByteCount else {
            throw rejected("stream_capture_binding")
        }
        guard binding.sha256 == snapshot.outputSHA256 else {
            throw rejected("stream_capture_descriptor_digest")
        }
        try directory.requireImmutableCapture(
            leaf: leaf,
            snapshot: snapshot
        )
        return PrimeSecureChildStreamObservation(
            artifactBinding: binding,
            prefixData: data,
            totalByteCount: snapshot.totalByteCount,
            capturedByteCount: snapshot.capturedByteCount,
            overflowed: snapshot.overflowed,
            reachedEOF: snapshot.reachedEOF,
            readErrorNumber: snapshot.readErrorNumber,
            writeErrorNumber: snapshot.writeErrorNumber
        )
    }

    private static func childWorkingDirectoryJoin(
        processIdentifier: Int32,
        directory: PrimeSecureChildHeldDirectory
    ) throws -> PrimeSecureChildDirectoryJoinObservation {
        var info = proc_vnodepathinfo()
        errno = 0
        let returned = withUnsafeMutablePointer(to: &info) {
            proc_pidinfo(
                processIdentifier,
                PROC_PIDVNODEPATHINFO,
                0,
                $0,
                Int32(MemoryLayout<proc_vnodepathinfo>.size)
            )
        }
        let status = info.pvi_cdir.vip_vi.vi_stat
        let childDevice = UInt64(bitPattern: Int64(status.vst_dev))
        let joined = returned
                == Int32(MemoryLayout<proc_vnodepathinfo>.size)
            && childDevice == directory.identity.deviceID
            && status.vst_ino == directory.identity.inode
            && status.vst_mode & UInt16(S_IFMT) == UInt16(S_IFDIR)
        guard joined else {
            throw rejected("child_cwd_descriptor_join_\(errno)")
        }
        return PrimeSecureChildDirectoryJoinObservation(
            descriptorDeviceID: directory.identity.deviceID,
            descriptorInode: directory.identity.inode,
            childCurrentDirectoryDeviceID: childDevice,
            childCurrentDirectoryInode: status.vst_ino,
            exactDescriptorJoinObserved: true
        )
    }

    private static func completion(
        wait: PrimeNativeNeuralGateExactPIDWaitObservation,
        wallClockLimitReached: Bool,
        streamContainmentLimitReached: Bool
    ) -> PrimeSecureChildCompletion {
        if wallClockLimitReached {
            return .wallClockLimit(
                exitStatus: wait.exitStatus,
                signal: wait.terminationSignal
            )
        }
        if streamContainmentLimitReached {
            return .streamContainmentLimit(
                exitStatus: wait.exitStatus,
                signal: wait.terminationSignal
            )
        }
        if wait.exitedNormally {
            return .exited(status: wait.exitStatus)
        }
        return .signaled(
            signal: wait.terminationSignal,
            coreDumped: wait.coreDumped
        )
    }

    private static func fixtureContractSatisfied(
        invocation: PrimeSecureChildFixtureInvocation,
        completion: PrimeSecureChildCompletion,
        stdout: PrimeSecureChildStreamObservation,
        stderr: PrimeSecureChildStreamObservation,
        fixtureResultData: Data?,
        descendantProcessIdentifier: Int32?,
        parentProcessIdentifier: Int32,
        preReapMembers: [Int32]?
    ) -> Bool {
        if invocation.mode == .descendantRetainsStreams {
            guard let descendantProcessIdentifier,
                  fixtureResultData != nil,
                  stdout.prefixData
                    == Data(
                        "spawned_descendant_pid=\(descendantProcessIdentifier)\n"
                            .utf8
                    ),
                  stdout.totalByteCount
                    == UInt64(stdout.prefixData.count),
                  !stdout.overflowed,
                  stderr.totalByteCount == 0,
                  stderr.prefixData.isEmpty,
                  !stderr.overflowed,
                  let preReapMembers,
                  Set(preReapMembers)
                    == Set([
                        parentProcessIdentifier,
                        descendantProcessIdentifier,
                    ])
            else { return false }
            if case .streamContainmentLimit = completion { return true }
            return false
        }
        guard preReapMembers == [parentProcessIdentifier],
              fixtureResultData == invocation.expectedResultData,
              stdout.totalByteCount
                == UInt64(
                    invocation
                        .configuredPayloadStandardOutputBytes
                ),
              stderr.totalByteCount
                == UInt64(
                    invocation
                        .configuredPayloadStandardErrorBytes
                ),
              stdout.prefixData.allSatisfy({ $0 == 0x4f }),
              stderr.prefixData.allSatisfy({ $0 == 0x45 })
        else { return false }
        switch invocation.mode {
        case .pass, .boundedStreams:
            return completion == .exited(status: 0)
                && !stdout.overflowed && !stderr.overflowed
        case .overflow:
            return completion == .exited(status: 0)
                && (stdout.overflowed || stderr.overflowed)
        case .nonzeroExit:
            return completion
                == .exited(status: invocation.configuredExitCode)
        case .hang:
            if case .wallClockLimit = completion { return true }
            return false
        case .selfSignal:
            if case .signaled(signal: SIGTERM, coreDumped: false) = completion {
                return true
            }
            return false
        case .descendantRetainsStreams:
            return false
        case .exitWithoutResult:
            return completion == .exited(status: 0)
                && fixtureResultData == nil
        }
    }

    private static func deadline(after delta: UInt64) -> UInt64 {
        let value = DispatchTime.now().uptimeNanoseconds
            .addingReportingOverflow(delta)
        return value.overflow ? UInt64.max : value.partialValue
    }

    private static func containOrFailStop(
        _ child: PrimeNativeNeuralGateSecureChildLifecycle
    ) {
        switch child.cleanupRejectedCapture() {
        case .contained:
            return
        case let .mustFailStop(reason):
            failStop(reason)
        }
    }

    private static func requireRetainedWait(
        _ child: PrimeNativeNeuralGateSecureChildLifecycle
    ) -> PrimeNativeNeuralGateExactPIDWaitObservation {
        guard let observation = child.exactPIDWaitObservation else {
            failStop(.exactPIDWaitFailed)
        }
        return observation
    }

    private static func waitForDrainsOrFailStop(
        _ drains: DispatchGroup
    ) {
        guard drains.wait(timeout: .now() + .seconds(3)) == .success else {
            failStop(.streamDrainUncontained)
        }
    }

    private static func failStop(
        _ reason: PrimeSecureChildContainmentFailureReason
    ) -> Never {
        let message = "prime-secure-child fail-stop: \(reason.rawValue)\n"
        _ = Array(message.utf8).withUnsafeBytes {
            Darwin.write(STDERR_FILENO, $0.baseAddress, $0.count)
        }
        Darwin._exit(70)
    }

    private static func rejected(
        _ detail: String
    ) -> PrimeValidationWorkflowFixtureChildError {
        .rejected(detail)
    }
}

struct PrimeSecureChildFileBackedDrainSnapshot:
    Equatable,
    Sendable
{
    let totalByteCount: UInt64
    let capturedByteCount: UInt64
    let overflowed: Bool
    let workerFinished: Bool
    let reachedEOF: Bool
    let readErrorNumber: Int32
    let writeErrorNumber: Int32
    let outputDeviceID: UInt64
    let outputInode: UInt64
    let outputByteCount: UInt64
    let outputPermissionMode: UInt16
    let outputSHA256: String
    let outputMetadataObserved: Bool
}

final class PrimeSecureChildFileBackedBoundedDrain:
    @unchecked Sendable
{
    private let inputDescriptor: Int32
    private let outputDescriptor: Int32
    private let maximumByteCount: UInt64
    private let lock = NSLock()
    private var totalByteCount: UInt64 = 0
    private var capturedByteCount: UInt64 = 0
    private var overflowed = false
    private var workerFinished = false
    private var reachedEOF = false
    private var readErrorNumber: Int32 = 0
    private var writeErrorNumber: Int32 = 0
    private var outputDeviceID: UInt64 = 0
    private var outputInode: UInt64 = 0
    private var outputByteCount: UInt64 = 0
    private var outputPermissionMode: UInt16 = 0
    private var outputSHA256 = ""
    private var outputMetadataObserved = false

    init(
        inputDescriptor: Int32,
        outputDescriptor: Int32,
        maximumByteCount: UInt64
    ) {
        self.inputDescriptor = inputDescriptor
        self.outputDescriptor = outputDescriptor
        self.maximumByteCount = maximumByteCount
    }

    func start(group: DispatchGroup) {
        group.enter()
        DispatchQueue.global(qos: .utility).async {
            self.drain()
            group.leave()
        }
    }

    func snapshot() -> PrimeSecureChildFileBackedDrainSnapshot {
        lock.lock()
        defer { lock.unlock() }
        return PrimeSecureChildFileBackedDrainSnapshot(
            totalByteCount: totalByteCount,
            capturedByteCount: capturedByteCount,
            overflowed: overflowed,
            workerFinished: workerFinished,
            reachedEOF: reachedEOF,
            readErrorNumber: readErrorNumber,
            writeErrorNumber: writeErrorNumber,
            outputDeviceID: outputDeviceID,
            outputInode: outputInode,
            outputByteCount: outputByteCount,
            outputPermissionMode: outputPermissionMode,
            outputSHA256: outputSHA256,
            outputMetadataObserved: outputMetadataObserved
        )
    }

    private func drain() {
        defer {
            finalizeOutput()
            Darwin.close(outputDescriptor)
            Darwin.close(inputDescriptor)
            lock.lock()
            workerFinished = true
            lock.unlock()
        }
        var buffer = [UInt8](repeating: 0, count: 64 * 1024)
        while true {
            let count = buffer.withUnsafeMutableBytes {
                Darwin.read(inputDescriptor, $0.baseAddress, $0.count)
            }
            if count > 0 {
                consume(buffer[0 ..< count])
                continue
            }
            if count == 0 {
                lock.lock()
                reachedEOF = true
                lock.unlock()
                return
            }
            var failure = errno
            if failure == EINTR { continue }
            if failure == EAGAIN || failure == EWOULDBLOCK {
                var event = pollfd(
                    fd: inputDescriptor,
                    events: Int16(POLLIN | POLLHUP | POLLERR),
                    revents: 0
                )
                let polled = Darwin.poll(&event, 1, 100)
                if polled >= 0 || errno == EINTR { continue }
                failure = errno
            }
            lock.lock()
            readErrorNumber = failure
            lock.unlock()
            return
        }
    }

    private func consume(_ bytes: ArraySlice<UInt8>) {
        lock.lock()
        let addition = totalByteCount.addingReportingOverflow(
            UInt64(bytes.count)
        )
        totalByteCount = addition.overflow
            ? UInt64.max
            : addition.partialValue
        let remaining = maximumByteCount > capturedByteCount
            ? maximumByteCount - capturedByteCount
            : 0
        let wanted = Int(min(remaining, UInt64(bytes.count)))
        overflowed = addition.overflow
            || totalByteCount > maximumByteCount
        let mayWrite = writeErrorNumber == 0 && wanted > 0
        lock.unlock()

        guard mayWrite else { return }
        let prefix = bytes.prefix(wanted)
        var offset = 0
        while offset < prefix.count {
            let written = prefix.withUnsafeBytes {
                Darwin.write(
                    outputDescriptor,
                    $0.baseAddress!.advanced(by: offset),
                    $0.count - offset
                )
            }
            if written > 0 {
                offset += written
                continue
            }
            if written < 0 && errno == EINTR { continue }
            recordWriteError(errno)
            return
        }
        lock.lock()
        capturedByteCount += UInt64(offset)
        lock.unlock()
    }

    private func recordWriteError(_ value: Int32) {
        lock.lock()
        if writeErrorNumber == 0 {
            writeErrorNumber = value == 0 ? EIO : value
        }
        lock.unlock()
    }

    private func finalizeOutput() {
        if fchmod(outputDescriptor, mode_t(0o444)) != 0 {
            recordWriteError(errno)
        }
        if fsync(outputDescriptor) != 0 {
            recordWriteError(errno)
        }
        if fcntl(outputDescriptor, F_FULLFSYNC) != 0 {
            recordWriteError(errno)
        }
        var before = stat()
        lock.lock()
        let expectedByteCount = capturedByteCount
        lock.unlock()
        guard fstat(outputDescriptor, &before) == 0,
              before.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
              before.st_uid == geteuid(),
              before.st_nlink == 1,
              before.st_mode & mode_t(0o7777) == mode_t(0o444),
              before.st_size >= 0,
              UInt64(before.st_size) == expectedByteCount
        else {
            recordWriteError(errno == 0 ? EIO : errno)
            return
        }
        let data: Data
        do {
            data = try PrimeSecureChildPath.readExact(
                descriptor: outputDescriptor,
                byteCount: Int(before.st_size)
            )
        } catch {
            recordWriteError(EIO)
            return
        }
        var after = stat()
        guard fstat(outputDescriptor, &after) == 0,
              after.st_dev == before.st_dev,
              after.st_ino == before.st_ino,
              after.st_mode == before.st_mode,
              after.st_nlink == before.st_nlink,
              after.st_size == before.st_size,
              after.st_mtimespec.tv_sec == before.st_mtimespec.tv_sec,
              after.st_mtimespec.tv_nsec == before.st_mtimespec.tv_nsec,
              after.st_ctimespec.tv_sec == before.st_ctimespec.tv_sec,
              after.st_ctimespec.tv_nsec == before.st_ctimespec.tv_nsec
        else {
            recordWriteError(errno == 0 ? EIO : errno)
            return
        }
        lock.lock()
        outputDeviceID = UInt64(bitPattern: Int64(after.st_dev))
        outputInode = UInt64(after.st_ino)
        outputByteCount = UInt64(after.st_size)
        outputPermissionMode =
            UInt16(after.st_mode & mode_t(0o7777))
        outputSHA256 = PrimeSHA256.hexDigest(of: data)
        outputMetadataObserved = true
        lock.unlock()
    }
}

enum PrimeSecureChildPath {
    static func requireCanonicalDirectoryURL(
        _ url: URL,
        label: String
    ) throws {
        guard url.isFileURL,
              url.path.hasPrefix("/"),
              url.path != "/",
              !url.path.contains("\0"),
              try canonicalPath(url.path) == url.path
        else {
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("\(label)_url")
        }
    }

    static func requireCanonicalFileURL(
        _ url: URL,
        expectedBasename: String
    ) throws {
        guard url.isFileURL,
              url.path.hasPrefix("/"),
              url.path != "/",
              !url.path.contains("\0"),
              url.lastPathComponent == expectedBasename,
              try canonicalPath(url.path) == url.path
        else {
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("executable_url")
        }
    }

    static func canonicalPath(_ path: String) throws -> String {
        var buffer = [CChar](repeating: 0, count: Int(PATH_MAX))
        let succeeded = path.withCString { input in
            buffer.withUnsafeMutableBufferPointer {
                realpath(input, $0.baseAddress) != nil
            }
        }
        guard succeeded else {
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("canonical_path_\(errno)")
        }
        return buffer.withUnsafeBufferPointer {
            String(cString: $0.baseAddress!)
        }
    }

    static func readExact(
        descriptor: Int32,
        byteCount: Int
    ) throws -> Data {
        guard byteCount >= 0 else {
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("descriptor_byte_count")
        }
        var result = Data()
        result.reserveCapacity(byteCount)
        var offset = 0
        var buffer = [UInt8](repeating: 0, count: 64 * 1024)
        while offset < byteCount {
            let wanted = min(buffer.count, byteCount - offset)
            let count = buffer.withUnsafeMutableBytes {
                pread(descriptor, $0.baseAddress, wanted, off_t(offset))
            }
            if count < 0 && errno == EINTR { continue }
            guard count > 0 else {
                throw PrimeValidationWorkflowFixtureChildError
                    .rejected("descriptor_read_\(errno)")
            }
            result.append(contentsOf: buffer[0 ..< count])
            offset += count
        }
        var trailing: UInt8 = 0
        let trailingCount = withUnsafeMutablePointer(to: &trailing) {
            pread(descriptor, $0, 1, off_t(byteCount))
        }
        guard trailingCount == 0 else {
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("descriptor_trailing_bytes")
        }
        return result
    }
}
