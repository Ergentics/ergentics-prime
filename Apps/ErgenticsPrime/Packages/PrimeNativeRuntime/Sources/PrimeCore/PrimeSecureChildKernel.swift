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
    case logicalArgumentZero = "logical-argument-zero"
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
    private let prepared: PrimeSecureChildPreparedFixture
    private let capture:
        PrimeTrustedSecureChildProcessCapture

    private init(
        prepared: PrimeSecureChildPreparedFixture,
        capture: PrimeTrustedSecureChildProcessCapture
    ) {
        self.prepared = prepared
        self.capture = capture
    }

    @available(macOS 26.0, *)
    public static func prepare(
        executableURL: URL,
        privateWorkingDirectoryURL: URL,
        privateResultDirectoryURL: URL,
        mode: PrimeValidationWorkflowFixtureChildMode
    ) throws -> Self {
        let plan = try PrimeSecureChildProcessPlanV1
            .validationWorkflowFixture(
                mode: mode
            )
        let prepared =
            try PrimeSecureChildPreparedFixture(
                executableURL: executableURL,
                workingDirectoryURL:
                    privateWorkingDirectoryURL,
                resultDirectoryURL:
                    privateResultDirectoryURL,
                plan: plan
            )
        return Self(
            prepared: prepared,
            capture:
                PrimeTrustedSecureChildProcessCapture(
                    plan: plan,
                    closedContext: prepared
                )
        )
    }

    @available(macOS 26.0, *)
    public func execute() throws
        -> PrimeValidationWorkflowFixtureChildResult
    {
        let consumption:
            PrimeTrustedSecureChildProcessCapture
            .Consumption
        do {
            consumption = try capture.consume()
        } catch {
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("capability_already_consumed")
        }
        let execution = try PrimeSecureChildExecutionKernel
            .execute(
                consumption: consumption,
                prepared: prepared
            )
        guard let fixtureResult = execution.fixtureResult else {
            throw PrimeValidationWorkflowFixtureChildError
                .rejected(
                    execution.operationalFailureCode
                    ?? "execution_kernel_result"
                )
        }
        return fixtureResult
    }
}

/// PrimeCore-internal, closed selection of the logical process personality.
/// No case carries caller-provided bytes. The physical executable remains a
/// separate held capability and is always the path supplied to `posix_spawn`.
enum PrimeSecureChildArgumentZeroPolicy:
    Equatable,
    Sendable
{
    case physicalExecutablePath
    case swiftBuildCanary

    static let swiftBuildCanaryValue =
        "swift-build"

    func resolved(
        physicalExecutableAbsolutePath: String
    ) -> String {
        switch self {
        case .physicalExecutablePath:
            physicalExecutableAbsolutePath
        case .swiftBuildCanary:
            Self.swiftBuildCanaryValue
        }
    }
}

enum PrimeSecureChildFixtureBinaryPin {
    static let byteCount: UInt64 = 89_632
    static let sha256 =
        "eae9573027fe736cab0d4aa319ae43f" +
        "22231eaef9c55af91d73fbe3d87bc9ebd"
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
    let argumentZeroPolicy:
        PrimeSecureChildArgumentZeroPolicy
    let arguments: [String]
    let orderedEnvironment: [(String, String)]
    let maximumWallNanoseconds: UInt64
    let configuredPayloadStandardOutputBytes: Int
    let configuredPayloadStandardErrorBytes: Int
    let configuredExitCode: Int32
    let expectsResult: Bool

    init(
        plan: PrimeSecureChildProcessPlanV1,
        resultAbsolutePath: String
    ) throws {
        let mode = plan.validationWorkflowFixtureMode
        self.mode = mode
        orderedEnvironment = plan.orderedEnvironment
        argumentZeroPolicy = mode == .logicalArgumentZero
            ? .swiftBuildCanary
            : .physicalExecutablePath

        let values: (Int, Int, Int32, Bool)
        switch mode {
        case .pass, .logicalArgumentZero:
            values = (0, 0, 0, true)
        case .nonzeroExit:
            values = (0, 0, 23, true)
        case .boundedStreams:
            values = (4_096, 2_048, 0, true)
        case .overflow:
            values = (131_072, 131_072, 0, true)
        case .hang:
            values = (0, 0, 0, true)
        case .selfSignal:
            values = (0, 0, 0, true)
        case .descendantRetainsStreams:
            values = (0, 0, 0, true)
        case .exitWithoutResult:
            values = (0, 0, 0, false)
        }
        configuredPayloadStandardOutputBytes = values.0
        configuredPayloadStandardErrorBytes = values.1
        configuredExitCode = values.2
        expectsResult = values.3
        maximumWallNanoseconds =
            plan.maximumWallNanoseconds
        try Self.requireFixtureResultPathIfRequired(
            resultAbsolutePath,
            expectsResult: expectsResult
        )
        arguments = try plan.exactArguments(
            resultAbsolutePath:
                expectsResult
                ? resultAbsolutePath
                : ""
        )
    }

    var expectedResultData: Data? {
        guard expectsResult,
              mode != .descendantRetainsStreams
        else { return nil }
        var lines = [
            "schema=prime_validation_workflow_fixture_result_v1",
            "mode=\(mode.rawValue)",
            "configured_payload_stdout_bytes=\(configuredPayloadStandardOutputBytes)",
            "configured_payload_stderr_bytes=\(configuredPayloadStandardErrorBytes)",
            "configured_exit_code=\(configuredExitCode)",
        ]
        if mode == .logicalArgumentZero {
            lines.append(
                "observed_argument_zero="
                    + PrimeSecureChildArgumentZeroPolicy
                    .swiftBuildCanaryValue
            )
        }
        return Data(
            (lines.joined(separator: "\n") + "\n").utf8
        )
    }

    private static func requireFixtureResultPathIfRequired(
        _ path: String,
        expectsResult: Bool
    ) throws {
        guard expectsResult else { return }
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

final class PrimeSecureChildPreparedFixture:
    @unchecked Sendable
{
    let mode: PrimeValidationWorkflowFixtureChildMode
    fileprivate let executable:
        PrimeSecureChildHeldExecutable
    fileprivate let workingDirectory:
        PrimeSecureChildHeldDirectory
    fileprivate let resultDirectory:
        PrimeSecureChildHeldDirectory
    fileprivate let invocation:
        PrimeSecureChildFixtureInvocation

    init(
        executableURL: URL,
        workingDirectoryURL: URL,
        resultDirectoryURL: URL,
        plan: PrimeSecureChildProcessPlanV1
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
            plan: plan,
            resultAbsolutePath:
                resultDirectory.absolutePath
                + "/"
                + PrimeSecureChildFixtureInvocation.resultLeaf
        )
        mode = plan.validationWorkflowFixtureMode
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
        do {
            try requireStable()
            try synchronizeNamespace()
            return opened
        } catch {
            Darwin.close(opened)
            throw error
        }
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
                    O_RDONLY | O_NOFOLLOW | O_CLOEXEC | O_NONBLOCK
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
                O_RDONLY | O_NOFOLLOW | O_CLOEXEC | O_NONBLOCK
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
                O_RDONLY | O_NOFOLLOW | O_CLOEXEC | O_NONBLOCK
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

    /// Reads only a capture file already admitted by this held directory.
    /// This is the contained operational-error path: it does not mint an
    /// immutable artifact binding or claim successful finalization.
    func readContainedCapturePrefix(
        leaf: String,
        snapshot: PrimeSecureChildFileBackedDrainSnapshot
    ) throws -> Data {
        guard snapshot.workerFinished,
              snapshot.descriptorsClosed,
              snapshot.terminalReason != .active,
              snapshot.capturedByteCount
                <= PrimeSecureChildFixtureInvocation.streamPrefixLimit,
              snapshot.capturedByteCount <= UInt64(Int.max)
        else {
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("contained_capture_unsettled")
        }
        let opened = leaf.withCString {
            openat(
                descriptor,
                $0,
                O_RDONLY | O_NOFOLLOW | O_CLOEXEC | O_NONBLOCK
            )
        }
        guard opened >= 3 else {
            if opened >= 0 { Darwin.close(opened) }
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("contained_capture_open_\(errno)")
        }
        defer { Darwin.close(opened) }
        entryLedgerLock.lock()
        let admittedIdentity = admittedEntries[leaf]
        entryLedgerLock.unlock()
        var before = stat()
        guard let admittedIdentity,
              fstat(opened, &before) == 0,
              PrimeSecureChildFileIdentity(before)
                == admittedIdentity,
              before.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
              before.st_uid == geteuid(),
              before.st_nlink == 1,
              (
                  before.st_mode & mode_t(0o7777) == mode_t(0o600)
                    || before.st_mode & mode_t(0o7777) == mode_t(0o444)
              ),
              before.st_size >= 0,
              UInt64(before.st_size) == snapshot.capturedByteCount,
              fcntl(opened, F_GETFD) & FD_CLOEXEC != 0
        else {
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("contained_capture_metadata")
        }
        let data = try PrimeSecureChildPath.readExact(
            descriptor: opened,
            byteCount: Int(before.st_size)
        )
        var after = stat()
        guard fstat(opened, &after) == 0,
              PrimeSecureChildFileIdentity(after)
                == admittedIdentity,
              after.st_mode == before.st_mode,
              after.st_size == before.st_size,
              after.st_mtimespec.tv_sec == before.st_mtimespec.tv_sec,
              after.st_mtimespec.tv_nsec == before.st_mtimespec.tv_nsec,
              after.st_ctimespec.tv_sec == before.st_ctimespec.tv_sec,
              after.st_ctimespec.tv_nsec == before.st_ctimespec.tv_nsec,
              !snapshot.outputMetadataObserved
                || (
                    snapshot.outputDeviceID
                        == admittedIdentity.deviceID
                    && snapshot.outputInode
                        == admittedIdentity.inode
                    && snapshot.outputByteCount
                        == snapshot.capturedByteCount
                    && snapshot.outputSHA256
                        == PrimeSHA256.hexDigest(of: data)
                )
        else {
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("contained_capture_changed")
        }
        return data
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

fileprivate final class PrimeSecureChildHeldExecutable:
    @unchecked Sendable
{
    static let expectedBasename =
        "PrimeValidationWorkflowFixtureChild"
    // Reproduced from independent arm64 Release compilations at disjoint
    // absolute paths. The linker's `-S` final-image audit is the authority
    // that removes path-bearing N_OSO symbols. The binaries compared
    // byte-for-byte, retained the identical
    // content-derived LC_UUID 6ABE4B24-C019-3372-8144-C85CCEE5BA19, and the
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
            O_RDONLY | O_NOFOLLOW_ANY | O_CLOEXEC | O_NONBLOCK
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

extension PrimeSecureChildExecutionKernel {
    @available(macOS 26.0, *)
    static func execute(
        consumption:
            PrimeTrustedSecureChildProcessCapture.Consumption,
        prepared: PrimeSecureChildPreparedFixture
    ) throws -> Result {
        let claim:
            PrimeTrustedSecureChildProcessCapture
            .Consumption.ExecutionClaim
        do {
            claim = try consumption.claimForExecution()
        } catch {
            throw PrimeValidationWorkflowFixtureChildError
                .rejected(
                    "execution_authority_already_claimed"
                )
        }
        guard claim.retainsClosedContext(prepared),
              claim.plan
                .validationWorkflowFixtureMode == prepared.mode,
              claim.plan.standardInputPolicy == .devNull,
              claim.plan.orderedEnvironment.isEmpty,
              claim.plan
                .standardOutputMaximumByteCount
                == PrimeSecureChildFixtureInvocation.streamPrefixLimit,
              claim.plan
                .standardErrorMaximumByteCount
                == PrimeSecureChildFixtureInvocation.streamPrefixLimit
        else {
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("execution_kernel_context")
        }

        let outcome = try PrimeSecureChildKernel
            .execute(
                prepared,
                claim: claim
            )
        guard outcome.mode
                == claim.plan
                .validationWorkflowFixtureMode,
              UInt64(outcome.standardOutputPrefix.count)
                == outcome.standardOutputDrain.capturedByteCount,
              UInt64(outcome.standardErrorPrefix.count)
                == outcome.standardErrorDrain.capturedByteCount,
              outcome.fixtureResult != nil
                || outcome.operationalFailureCode == "stream_capture"
        else {
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("execution_kernel_outcome")
        }

        let evidence = processEvidence(
            outcome: outcome,
            leaseTelemetry:
                claim.leaseRetention?.telemetry
        )
        let diagnosticCanonicalData: Data
        do {
            diagnosticCanonicalData = try PrimeSecureChildDiagnosticProjection
                .canonicalData(for: evidence)
        } catch {
            if let failure = outcome.operationalFailureCode {
                throw PrimeValidationWorkflowFixtureChildError
                    .rejected(failure)
            }
            throw PrimeValidationWorkflowFixtureChildError
                .rejected("execution_kernel_evidence")
        }
        return Result(
            executionClaim: claim,
            rawOutcome: outcome,
            evidence: evidence,
            diagnosticCanonicalData:
                diagnosticCanonicalData
        )
    }
}

private enum PrimeSecureChildKernel {
    @available(macOS 26.0, *)
    static func execute(
        _ prepared: PrimeSecureChildPreparedFixture,
        claim:
            PrimeTrustedSecureChildProcessCapture
            .Consumption.ExecutionClaim
    ) throws -> PrimeSecureChildExecutionKernel.RawOutcome {
        let plan = claim.plan
        let phaseDeadline:
            PrimeSecureChildPhaseDeadline
        do {
            phaseDeadline =
                try PrimeSecureChildPhaseDeadline(
                    startUptimeNanoseconds:
                        DispatchTime.now()
                        .uptimeNanoseconds,
                    durationNanoseconds:
                        plan.maximumWallNanoseconds
                )
        } catch {
            throw rejected("deadline_overflow")
        }
        try prepared.executable.requireUnchanged()
        try prepared.workingDirectory.requireStable()
        try prepared.resultDirectory.requireStable()
        let heldWorkingDirectory =
            try heldWorkingDirectorySnapshot(
                prepared.workingDirectory
            )

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
        guard stdoutFile >= 0,
              stderrFile >= 0,
              stdoutFile != stderrFile
        else {
            Darwin.close(stdoutFile)
            Darwin.close(stderrFile)
            throw rejected(
                "stream_output_descriptor_pair"
            )
        }

        let supervision:
            PrimeSecureChildSupervisionCapability
        do {
            guard try phaseDeadline.authorizesNewWork(
                observedAtUptimeNanoseconds:
                    DispatchTime.now()
                    .uptimeNanoseconds
            ) else {
                throw rejected(
                    "wall_deadline_before_spawn"
                )
            }
            let spawn = try PrimeSecureChildDarwinSubstrate
                .spawnSuspended(
                    executableAbsolutePath:
                        prepared.executable.absolutePath,
                    argumentZero:
                        try plan.argumentZero(
                            physicalExecutableAbsolutePath:
                                prepared.executable.absolutePath
                        ),
                    workingDirectoryDescriptor:
                        prepared.workingDirectory.descriptor,
                    exactArguments:
                        try plan.exactArguments(
                            resultAbsolutePath:
                                prepared.invocation.expectsResult
                                ? prepared.resultDirectory.absolutePath
                                    + "/"
                                    + PrimeSecureChildFixtureInvocation
                                    .resultLeaf
                                : ""
                        ),
                    orderedEnvironment:
                        plan.orderedEnvironment
                )
            supervision =
                PrimeSecureChildSupervisionCapability
                .adoptFileBacked(
                    spawn: spawn,
                    phaseDeadline:
                        phaseDeadline,
                    standardOutputDescriptor:
                        stdoutFile,
                    standardErrorDescriptor:
                        stderrFile,
                    maximumByteCount:
                        plan
                        .standardOutputMaximumByteCount
                )
        } catch let error as
            PrimeSecureChildDarwinSubstrate.Rejection
        {
            Darwin.close(stdoutFile)
            Darwin.close(stderrFile)
            throw rejected(error.detail)
        } catch {
            Darwin.close(stdoutFile)
            Darwin.close(stderrFile)
            throw error
        }
        let sessionIdentifier: Int32
        let processGroupIdentifier: Int32
        let workingDirectoryJoin:
            PrimeSecureChildDirectoryJoinObservation
        let mappedExecutable:
            PrimeSecureChildMappedExecutableObservation
        do {
            guard supervision
                .establishIsolatedSessionAndDedicatedGroup()
            else {
                throw rejected("child_session_or_process_group")
            }
            sessionIdentifier =
                supervision.processIdentifier
            processGroupIdentifier =
                supervision.processIdentifier
            workingDirectoryJoin = try childWorkingDirectoryJoin(
                processIdentifier:
                    supervision.processIdentifier,
                heldDirectory:
                    heldWorkingDirectory
            )
            let transcript = try mappedExecutableJoin(
                    processIdentifier:
                        supervision.processIdentifier,
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
            containAndDrainOrFailStop(
                supervision
            )
            throw error
        }

        let resumeDisposition:
            PrimeSecureChildResumeDisposition
        do {
            resumeDisposition =
                try supervision.resume(
                    notBeforeUptimeNanoseconds:
                        DispatchTime.now()
                        .uptimeNanoseconds
                )
        } catch {
            containAndDrainOrFailStop(
                supervision
            )
            throw rejected(
                "wall_deadline_before_resume"
            )
        }
        switch resumeDisposition {
        case .resumed:
            break
        case .deadlineExpired:
            containAndDrainOrFailStop(
                supervision
            )
            throw rejected(
                "wall_deadline_before_resume"
            )
        case let .signalFailed(errorNumber):
            containAndDrainOrFailStop(
                supervision
            )
            throw rejected(
                "child_resume_\(errorNumber)"
            )
        case .stateRejected:
            containAndDrainOrFailStop(
                supervision
            )
            throw rejected(
                "child_resume_state"
            )
        }

        var wallClockLimitReached = false
        var streamContainmentLimitReached = false
        var preReapMembers: [Int32]?
        let wait: PrimeNativeNeuralGateExactPIDWaitObservation
        let drainEvidence:
            PrimeSecureChildDrainEvidence

        let deathObservation:
            PrimeSecureChildDeathObservationDisposition
        do {
            deathObservation =
                try supervision.observeDeath()
        } catch {
            containAndDrainOrFailStop(
                supervision
            )
            throw rejected(
                "wall_deadline_authority"
            )
        }
        switch deathObservation {
        case .stateRejected:
            containAndDrainOrFailStop(
                supervision
            )
            throw rejected(
                "child_death_observation_state"
            )
        case .deadlineExpired:
            wallClockLimitReached = true
            preReapMembers = supervision
                .processGroupMemberIdentifiers()
            containAndDrainOrFailStop(
                supervision
            )
            wait = requireRetainedWait(
                supervision
            )
            drainEvidence =
                supervision.drainEvidence()
        case .observed:
            guard let deathObservedAt =
                    supervision
                    .deathObservedMonotonicNanoseconds()
            else {
                containAndDrainOrFailStop(
                    supervision
                )
                failStop(
                    .invalidLifecycleTransition
                )
            }
            let phaseDrainDisposition:
                PrimeSecureChildPhaseDrainDisposition
            do {
                phaseDrainDisposition =
                    try supervision
                    .waitForPhaseDrainCompletion(
                        notBeforeUptimeNanoseconds:
                            deathObservedAt
                    )
            } catch {
                containAndDrainOrFailStop(
                    supervision
                )
                throw rejected(
                    "stream_deadline_authority"
                )
            }
            switch phaseDrainDisposition {
            case let .completed(evidence):
                drainEvidence = evidence
            case .deadlineExpired:
                streamContainmentLimitReached = true
                preReapMembers = supervision
                    .processGroupMemberIdentifiers()
                containAndDrainOrFailStop(
                    supervision
                )
                wait = requireRetainedWait(
                    supervision
                )
                drainEvidence =
                    supervision.drainEvidence()
                return try finish(
                    prepared: prepared,
                    supervision: supervision,
                    sessionIdentifier: sessionIdentifier,
                    processGroupIdentifier: processGroupIdentifier,
                    workingDirectoryJoin: workingDirectoryJoin,
                    mappedExecutable: mappedExecutable,
                    wait: wait,
                    wallClockLimitReached: wallClockLimitReached,
                    streamContainmentLimitReached:
                        streamContainmentLimitReached,
                    preReapMembers: preReapMembers,
                    drainEvidence: drainEvidence,
                    phaseDeadline:
                        phaseDeadline
                )
            case .stateRejected:
                containAndDrainOrFailStop(
                    supervision
                )
                throw rejected(
                    "stream_capture_state"
                )
            }

            preReapMembers = supervision
                .processGroupMemberIdentifiers()
            guard preReapMembers == [
                supervision.processIdentifier,
            ] else {
                streamContainmentLimitReached = true
                containAndDrainOrFailStop(
                    supervision
                )
                wait = requireRetainedWait(
                    supervision
                )
                return try finish(
                    prepared: prepared,
                    supervision: supervision,
                    sessionIdentifier: sessionIdentifier,
                    processGroupIdentifier: processGroupIdentifier,
                    workingDirectoryJoin: workingDirectoryJoin,
                    mappedExecutable: mappedExecutable,
                    wait: wait,
                    wallClockLimitReached: wallClockLimitReached,
                    streamContainmentLimitReached:
                        streamContainmentLimitReached,
                    preReapMembers: preReapMembers,
                    drainEvidence: drainEvidence,
                    phaseDeadline:
                        phaseDeadline
                )
            }
            switch supervision
                .reapAfterObservedDeath()
            {
            case let .reaped(observation):
                wait =
                    PrimeNativeNeuralGateExactPIDWaitObservation(
                        secureChildObservation:
                            observation
                    )
            case let .mustFailStop(reason):
                failStop(reason)
            }
            let reapCompletedWithinPhase:
                Bool
            do {
                reapCompletedWithinPhase =
                    try phaseDeadline
                    .acceptsCompletion(
                        observedAtUptimeNanoseconds:
                            wait
                            .returnedMonotonicNanoseconds
                    )
            } catch {
                throw rejected(
                    "wall_deadline_authority_after_reap"
                )
            }
            if !reapCompletedWithinPhase {
                wallClockLimitReached = true
            }
        }

        return try finish(
            prepared: prepared,
            supervision: supervision,
            sessionIdentifier: sessionIdentifier,
            processGroupIdentifier: processGroupIdentifier,
            workingDirectoryJoin: workingDirectoryJoin,
            mappedExecutable: mappedExecutable,
            wait: wait,
            wallClockLimitReached: wallClockLimitReached,
            streamContainmentLimitReached:
                streamContainmentLimitReached,
            preReapMembers: preReapMembers,
            drainEvidence: drainEvidence,
            phaseDeadline: phaseDeadline
        )
    }

    private static func finish(
        prepared: PrimeSecureChildPreparedFixture,
        supervision:
            PrimeSecureChildSupervisionCapability,
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
        drainEvidence:
            PrimeSecureChildDrainEvidence,
        phaseDeadline: PrimeSecureChildPhaseDeadline
    ) throws -> PrimeSecureChildExecutionKernel.RawOutcome {
        let stdoutSnapshot:
            PrimeSecureChildFileBackedDrainSnapshot
        let stderrSnapshot:
            PrimeSecureChildFileBackedDrainSnapshot
        switch drainEvidence {
        case let .fileBacked(
            standardOutput,
            standardError
        ):
            stdoutSnapshot = standardOutput
            stderrSnapshot = standardError
        case .memory:
            failStop(
                .invalidLifecycleTransition
            )
        }
        guard terminalDrainIsContained(stdoutSnapshot),
              terminalDrainIsContained(stderrSnapshot)
        else {
            failStop(.streamDrainUncontained)
        }
        try prepared.executable.requireUnchanged()
        try prepared.workingDirectory.requireStable()
        if !terminalDrainIsClean(stdoutSnapshot)
            || !terminalDrainIsClean(stderrSnapshot)
        {
            let stdoutPrefix: Data
            let stderrPrefix: Data
            do {
                stdoutPrefix = try prepared.resultDirectory
                    .readContainedCapturePrefix(
                        leaf:
                            PrimeSecureChildFixtureInvocation.stdoutLeaf,
                        snapshot: stdoutSnapshot
                    )
                stderrPrefix = try prepared.resultDirectory
                    .readContainedCapturePrefix(
                        leaf:
                            PrimeSecureChildFixtureInvocation.stderrLeaf,
                        snapshot: stderrSnapshot
                    )
            } catch {
                throw rejected("stream_capture")
            }
            let containedCompletion = completion(
                wait: wait,
                wallClockLimitReached:
                    wallClockLimitReached,
                streamContainmentLimitReached:
                    streamContainmentLimitReached
            )
            return PrimeSecureChildExecutionKernel.RawOutcome(
                fixtureResult: nil,
                operationalFailureCode:
                    "stream_capture",
                mode: prepared.mode,
                processIdentifier:
                    supervision.processIdentifier,
                appliedSpawnFlags:
                    supervision.appliedFlags,
                sessionIdentifier: sessionIdentifier,
                processGroupIdentifier:
                    processGroupIdentifier,
                executable:
                    prepared.executable.observation,
                workingDirectoryJoin:
                    workingDirectoryJoin,
                mappedExecutable:
                    mappedExecutable,
                exactPIDWait: wait,
                completion: containedCompletion,
                preReapProcessGroupMembers:
                    preReapMembers,
                processGroupEmptyAfterReap: true,
                fixtureContractSatisfied: false,
                standardOutputPrefix: stdoutPrefix,
                standardErrorPrefix: stderrPrefix,
                standardOutputDrain: stdoutSnapshot,
                standardErrorDrain: stderrSnapshot,
                phaseDeadline: phaseDeadline,
                spawnReturnCode:
                    supervision.spawnReturnCode,
                spawnReturnedMonotonicNanoseconds:
                    supervision
                    .spawnReturnedMonotonicNanoseconds,
                deathObservedMonotonicNanoseconds:
                    supervision
                    .deathObservedMonotonicNanoseconds(),
                cleanupTimeline:
                    supervision.cleanupTimelineSnapshot
            )
        }
        try prepared.resultDirectory.admitExpectedFixtureResult(
            expectsResult: prepared.invocation.expectsResult
        )
        try prepared.resultDirectory.requireStable()
        let stdout = try streamObservation(
            snapshot: stdoutSnapshot,
            directory: prepared.resultDirectory,
            leaf: PrimeSecureChildFixtureInvocation.stdoutLeaf
        )
        let stderr = try streamObservation(
            snapshot: stderrSnapshot,
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
        let finalExternalValidationObservedAt =
            DispatchTime.now()
            .uptimeNanoseconds
        let finalValidationCompletedWithinPhase:
            Bool
        do {
            finalValidationCompletedWithinPhase =
                try phaseDeadline
                .acceptsCompletion(
                    observedAtUptimeNanoseconds:
                        finalExternalValidationObservedAt,
                    notBeforeUptimeNanoseconds:
                        wait
                        .returnedMonotonicNanoseconds
                )
        } catch {
            throw rejected(
                "wall_deadline_authority_after_reap"
            )
        }
        let effectiveWallClockLimitReached =
            wallClockLimitReached
            || (
                !streamContainmentLimitReached
                    && !finalValidationCompletedWithinPhase
            )
        let completion = completion(
            wait: wait,
            wallClockLimitReached:
                effectiveWallClockLimitReached,
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
                supervision
                .processIdentifier,
            preReapMembers: preReapMembers
        )
        let fixtureResult =
            PrimeValidationWorkflowFixtureChildResult(
            mode: prepared.mode,
            processIdentifier:
                supervision.processIdentifier,
            appliedSpawnFlags:
                supervision.appliedFlags,
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
        return PrimeSecureChildExecutionKernel.RawOutcome(
            fixtureResult: fixtureResult,
            operationalFailureCode: nil,
            mode: prepared.mode,
            processIdentifier:
                supervision.processIdentifier,
            appliedSpawnFlags:
                supervision.appliedFlags,
            sessionIdentifier: sessionIdentifier,
            processGroupIdentifier:
                processGroupIdentifier,
            executable:
                prepared.executable.observation,
            workingDirectoryJoin:
                workingDirectoryJoin,
            mappedExecutable:
                mappedExecutable,
            exactPIDWait: wait,
            completion: completion,
            preReapProcessGroupMembers:
                preReapMembers,
            processGroupEmptyAfterReap: true,
            fixtureContractSatisfied: satisfied,
            standardOutputPrefix:
                stdout.prefixData,
            standardErrorPrefix:
                stderr.prefixData,
            standardOutputDrain: stdoutSnapshot,
            standardErrorDrain: stderrSnapshot,
            phaseDeadline: phaseDeadline,
            spawnReturnCode:
                supervision.spawnReturnCode,
            spawnReturnedMonotonicNanoseconds:
                supervision
                .spawnReturnedMonotonicNanoseconds,
            deathObservedMonotonicNanoseconds:
                supervision
                .deathObservedMonotonicNanoseconds(),
            cleanupTimeline:
                supervision.cleanupTimelineSnapshot
        )
    }

    private static func terminalDrainIsContained(
        _ snapshot:
            PrimeSecureChildFileBackedDrainSnapshot
    ) -> Bool {
        snapshot.workerFinished
            && snapshot.descriptorsClosed
            && snapshot.terminalReason != .active
    }

    private static func terminalDrainIsClean(
        _ snapshot:
            PrimeSecureChildFileBackedDrainSnapshot
    ) -> Bool {
        terminalDrainIsContained(snapshot)
            && snapshot.terminalReason == .endOfFile
            && snapshot.reachedEOF
            && snapshot.readErrorNumber == 0
            && snapshot.writeErrorNumber == 0
            && snapshot.finalizationErrorNumber == 0
            && snapshot.closeErrorNumber == 0
    }

    private static func streamObservation(
        snapshot:
            PrimeSecureChildFileBackedDrainSnapshot,
        directory: PrimeSecureChildHeldDirectory,
        leaf: String
    ) throws -> PrimeSecureChildStreamObservation {
        guard snapshot.workerFinished,
              snapshot.descriptorsClosed,
              snapshot.terminalReason == .endOfFile,
              snapshot.reachedEOF,
              snapshot.readErrorNumber == 0,
              snapshot.writeErrorNumber == 0,
              snapshot.finalizationErrorNumber == 0,
              snapshot.closeErrorNumber == 0,
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

    private static func heldWorkingDirectorySnapshot(
        _ directory: PrimeSecureChildHeldDirectory
    ) throws
        -> PrimeSecureChildDarwinProcessProof
        .HeldDirectorySnapshot
    {
        do {
            return try PrimeSecureChildDarwinProcessProof
                .snapshotHeldDirectory(
                    descriptor: directory.descriptor,
                    openedWithNoSymbolicLinksInPath:
                        true,
                    context:
                        .validationWorkingDirectory
                )
        } catch let error as
            PrimeSecureChildDarwinProcessProof.Rejection
        {
            throw rejected(error.detail)
        }
    }

    private static func childWorkingDirectoryJoin(
        processIdentifier: Int32,
        heldDirectory:
            PrimeSecureChildDarwinProcessProof
            .HeldDirectorySnapshot
    ) throws -> PrimeSecureChildDirectoryJoinObservation {
        do {
            let proof =
                try PrimeSecureChildDarwinProcessProof
                .captureSuspendedWorkingDirectory(
                    processIdentifier:
                        processIdentifier,
                    heldDirectory: heldDirectory
                )
            return PrimeSecureChildDirectoryJoinObservation(
                descriptorDeviceID:
                    proof.descriptorDeviceID,
                descriptorInode:
                    proof.descriptorInode,
                childCurrentDirectoryDeviceID:
                    proof
                    .suspendedChildCurrentDirectoryDeviceID,
                childCurrentDirectoryInode:
                    proof
                    .suspendedChildCurrentDirectoryInode,
                exactDescriptorJoinObserved:
                    proof.exactDescriptorJoinObserved
            )
        } catch let error as
            PrimeSecureChildDarwinProcessProof.Rejection
        {
            throw rejected(error.detail)
        }
    }

    private static func mappedExecutableJoin(
        processIdentifier: Int32,
        executableSnapshot:
            PrimeNativeNeuralGateExecutableDescriptorSnapshot,
        expectedExecutableAbsolutePath: String
    ) throws
        -> PrimeSecureChildDarwinProcessProof
        .MappedExecutableProof
    {
        do {
            return try PrimeSecureChildDarwinProcessProof
                .captureMappedExecutable(
                    processIdentifier:
                        processIdentifier,
                    heldExecutable:
                        try PrimeSecureChildDarwinProcessProof
                        .snapshotHeldExecutable(
                            deviceID:
                                executableSnapshot
                                .deviceID,
                            inode:
                                executableSnapshot.inode,
                            expectedCanonicalAbsolutePath:
                                expectedExecutableAbsolutePath
                        )
                )
        } catch let error as
            PrimeSecureChildDarwinProcessProof.Rejection
        {
            throw rejected(error.detail)
        }
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
        case .pass, .logicalArgumentZero, .boundedStreams:
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

    private static func containAndDrainOrFailStop(
        _ supervision:
            PrimeSecureChildSupervisionCapability
    ) {
        switch supervision
            .cleanupRejectedCapture()
        {
        case .contained:
            break
        case let .mustFailStop(reason):
            failStop(reason)
        }
    }

    private static func requireRetainedWait(
        _ supervision:
            PrimeSecureChildSupervisionCapability
    ) -> PrimeNativeNeuralGateExactPIDWaitObservation {
        guard let observation =
                supervision
                .exactPIDWaitObservation
        else {
            failStop(.exactPIDWaitFailed)
        }
        return PrimeNativeNeuralGateExactPIDWaitObservation(
            secureChildObservation: observation
        )
    }

    private static func failStop(
        _ reason: PrimeSecureChildContainmentFailureReason
    ) -> Never {
        // Containment is unresolved: inherited stderr must not delay termination.
        Darwin._exit(70)
    }

    private static func rejected(
        _ detail: String
    ) -> PrimeValidationWorkflowFixtureChildError {
        .rejected(detail)
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
