#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif
import Foundation

public final class PrimeNativeGitBlobTransport:
    @unchecked Sendable
{
    public static let gitExecutableURL =
        URL(fileURLWithPath: "/usr/bin/git")
    public static let environmentPolicyID =
        "prime_git_read_only_empty_environment_v1"

    private static let processTimeoutSeconds: Double = 30
    private static let stderrMaximumByteCount = 64 * 1024

    public init() {}

    public func resolve(
        companionRoot: URL
    ) throws -> PrimeNativeMigrationResolvedInput {
        let root = try Self.validateRepositoryRoot(
            companionRoot
        )
        let plan = PrimeNativeContractMigrationPlan.frozenV1
        try plan.validate()
        var observations:
            [PrimeNativeMigrationGitCommandObservation] = []

        let versionResult = try run(
            operation: "git_version",
            repositoryRoot: root,
            arguments: ["--version"],
            maximumStdoutByteCount: 4 * 1024
        )
        observations.append(versionResult.observation)
        let version = try Self.singleLine(
            versionResult.stdout,
            operation: "git_version"
        )
        let gitTool = try Self.gitToolBinding(
            version: version,
            versionData: versionResult.stdout
        )

        let remoteResult = try run(
            operation: "remote_identity",
            repositoryRoot: root,
            arguments: [
                "remote",
                "get-url",
                "origin",
            ],
            maximumStdoutByteCount: 16 * 1024
        )
        observations.append(remoteResult.observation)
        let remoteURL = try Self.singleLine(
            remoteResult.stdout,
            operation: "remote_identity"
        )
        guard plan.acceptedRemoteURLs.contains(
            remoteURL
        ) else {
            throw PrimeNativeContractMigrationError
                .repositoryIdentityMismatch
        }

        let objectFormatResult = try run(
            operation: "object_format",
            repositoryRoot: root,
            arguments: [
                "rev-parse",
                "--show-object-format",
            ],
            maximumStdoutByteCount: 1_024
        )
        observations.append(
            objectFormatResult.observation
        )
        let objectFormat = try Self.singleLine(
            objectFormatResult.stdout,
            operation: "object_format"
        )

        let revisionResult = try run(
            operation: "resolved_revision",
            repositoryRoot: root,
            arguments: [
                "rev-parse",
                "\(plan.companionRevision)^{commit}",
            ],
            maximumStdoutByteCount: 1_024
        )
        observations.append(revisionResult.observation)
        let resolvedRevision = try Self.singleLine(
            revisionResult.stdout,
            operation: "resolved_revision"
        )
        guard resolvedRevision
                == plan.companionRevision else {
            throw PrimeNativeContractMigrationError
                .repositoryRevisionMismatch(
                    expected: plan.companionRevision,
                    observed: resolvedRevision
                )
        }

        let treeResult = try run(
            operation: "resolved_tree",
            repositoryRoot: root,
            arguments: [
                "rev-parse",
                "\(plan.companionRevision)^{tree}",
            ],
            maximumStdoutByteCount: 1_024
        )
        observations.append(treeResult.observation)
        let treeOID = try Self.singleLine(
            treeResult.stdout,
            operation: "resolved_tree"
        )
        guard treeOID == plan.companionTreeOID else {
            throw PrimeNativeContractMigrationError
                .repositoryTreeMismatch(
                    expected: plan.companionTreeOID,
                    observed: treeOID
                )
        }

        let rawCommitResult = try run(
            operation: "raw_commit",
            repositoryRoot: root,
            arguments: [
                "cat-file",
                "-p",
                plan.companionRevision,
            ],
            maximumStdoutByteCount: 8 * 1024
        )
        observations.append(
            rawCommitResult.observation
        )
        let rawCommitByteCount =
            UInt64(rawCommitResult.stdout.count)
        let rawCommitSHA256 =
            PrimeSHA256.hexDigest(
                of: rawCommitResult.stdout
            )
        guard rawCommitByteCount
                == plan.companionRawCommitByteCount,
              rawCommitSHA256
                == plan.companionRawCommitSHA256 else {
            throw PrimeNativeContractMigrationError
                .repositoryIdentityMismatch
        }

        let treeInventoryResult = try run(
            operation: "inventory_tree",
            repositoryRoot: root,
            arguments:
                [
                    "ls-tree",
                    "-z",
                    "--full-tree",
                    plan.companionRevision,
                    "--",
                ]
                + plan.artifacts.map(
                    \.repositoryRelativePath
                ),
            maximumStdoutByteCount: 64 * 1024
        )
        observations.append(
            treeInventoryResult.observation
        )
        let treeEntries = try Self.parseTreeEntries(
            treeInventoryResult.stdout
        )
        guard treeEntries.count
                == plan.expectedArtifactCount else {
            throw PrimeNativeContractMigrationError
                .resolvedArtifactSetMismatch
        }

        var blobs:
            [String: PrimeNativeMigrationResolvedGitBlob] =
            [:]
        blobs.reserveCapacity(plan.artifacts.count)
        for specification in plan.artifacts {
            guard let entry =
                    treeEntries[
                        specification
                            .repositoryRelativePath
                    ] else {
                throw PrimeNativeContractMigrationError
                    .resolvedArtifactMissing(
                        specification.artifactID
                    )
            }
            guard entry.mode == "100644",
                  entry.objectType == "blob",
                  entry.objectID
                    == specification.gitBlobOID else {
                throw PrimeNativeContractMigrationError
                    .resolvedArtifactObjectMismatch(
                        specification.artifactID
                    )
            }
            let blobResult = try run(
                operation:
                    "blob:\(specification.artifactID)",
                repositoryRoot: root,
                arguments: [
                    "cat-file",
                    "blob",
                    entry.objectID,
                ],
                maximumStdoutByteCount:
                    Self.incremented(
                        specification.byteCount
                    )
            )
            observations.append(blobResult.observation)
            let blob =
                PrimeNativeMigrationResolvedGitBlob(
                    artifactID:
                        specification.artifactID,
                    repositoryRelativePath:
                        specification
                            .repositoryRelativePath,
                    mode: entry.mode,
                    objectType: entry.objectType,
                    gitBlobOID: entry.objectID,
                    data: blobResult.stdout
                )
            try PrimeNativeContractMigrationResolver
                .validate(
                    blob,
                    against: specification
                )
            blobs[specification.artifactID] = blob
        }

        let postRevision = try run(
            operation: "post_resolved_revision",
            repositoryRoot: root,
            arguments: [
                "rev-parse",
                "\(plan.companionRevision)^{commit}",
            ],
            maximumStdoutByteCount: 1_024
        )
        observations.append(postRevision.observation)
        let postTree = try run(
            operation: "post_resolved_tree",
            repositoryRoot: root,
            arguments: [
                "rev-parse",
                "\(plan.companionRevision)^{tree}",
            ],
            maximumStdoutByteCount: 1_024
        )
        observations.append(postTree.observation)
        guard try Self.singleLine(
            postRevision.stdout,
            operation: "post_resolved_revision"
        ) == resolvedRevision,
            try Self.singleLine(
                postTree.stdout,
                operation: "post_resolved_tree"
            ) == treeOID
        else {
            throw PrimeNativeContractMigrationError
                .repositoryIdentityMismatch
        }

        let input = PrimeNativeMigrationResolvedInput(
            repository:
                PrimeNativeMigrationRepositoryObservation(
                    observedRemoteURL: remoteURL,
                    requestedRevision:
                        plan.companionRevision,
                    resolvedRevision: resolvedRevision,
                    treeOID: treeOID,
                    objectFormat: objectFormat,
                    rawCommitByteCount:
                        rawCommitByteCount,
                    rawCommitSHA256:
                        rawCommitSHA256
                ),
            gitTool: gitTool,
            commandObservations: observations,
            blobsByArtifactID: blobs
        )
        try PrimeNativeContractMigrationResolver
            .validate(input)
        return input
    }

    public func sourceState(
        repositoryRoot: URL,
        phase: PrimeNativeMigrationResolverSourcePhase
    ) throws -> PrimeNativeMigrationResolverSourceState {
        let root = try Self.validateRepositoryRoot(
            repositoryRoot
        )
        let operationPrefix = phase.rawValue
        var observations:
            [PrimeNativeMigrationGitCommandObservation] = []
        let remoteResult = try run(
            operation: "\(operationPrefix)_remote",
            repositoryRoot: root,
            arguments: [
                "remote",
                "get-url",
                "origin",
            ],
            maximumStdoutByteCount: 16 * 1024
        )
        observations.append(remoteResult.observation)
        let remoteURL = try Self.singleLine(
            remoteResult.stdout,
            operation: "\(operationPrefix)_remote"
        )
        guard PrimeNativeContractMigrationPlan
                .frozenV1
                .acceptedResolverRemoteURLs.contains(
                    remoteURL
                ) else {
            throw PrimeNativeContractMigrationError
                .repositoryIdentityMismatch
        }
        let revisionResult = try run(
            operation: "\(operationPrefix)_revision",
            repositoryRoot: root,
            arguments: [
                "rev-parse",
                "HEAD^{commit}",
            ],
            maximumStdoutByteCount: 1_024
        )
        observations.append(revisionResult.observation)
        let revision = try Self.singleLine(
            revisionResult.stdout,
            operation: "\(operationPrefix)_revision"
        )
        guard PrimeNativeContractMigrationPlan
                .isGitOID(revision) else {
            throw PrimeNativeContractMigrationError
                .malformedGitOutput(
                    "\(operationPrefix)_revision"
                )
        }
        let treeResult = try run(
            operation: "\(operationPrefix)_tree",
            repositoryRoot: root,
            arguments: [
                "rev-parse",
                "HEAD^{tree}",
            ],
            maximumStdoutByteCount: 1_024
        )
        observations.append(treeResult.observation)
        let treeOID = try Self.singleLine(
            treeResult.stdout,
            operation: "\(operationPrefix)_tree"
        )
        guard PrimeNativeContractMigrationPlan
                .isGitOID(treeOID) else {
            throw PrimeNativeContractMigrationError
                .malformedGitOutput(
                    "\(operationPrefix)_tree"
                )
        }
        let statusResult = try run(
            operation: "\(operationPrefix)_status",
            repositoryRoot: root,
            arguments: [
                "status",
                "--porcelain=v1",
                "--untracked-files=all",
            ],
            maximumStdoutByteCount: 64 * 1024
        )
        observations.append(statusResult.observation)
        return PrimeNativeMigrationResolverSourceState(
            remoteURL: remoteURL,
            revision: revision,
            treeOID: treeOID,
            clean: statusResult.stdout.isEmpty,
            commandObservations: observations
        )
    }

    private struct TreeEntry {
        let mode: String
        let objectType: String
        let objectID: String
    }

    private struct ProcessResult {
        let stdout: Data
        let observation:
            PrimeNativeMigrationGitCommandObservation
    }

    private final class CaptureBox:
        @unchecked Sendable
    {
        private let maximumByteCount: UInt64
        private let lock = NSLock()
        private var bytes = Data()
        private var totalByteCount: UInt64 = 0
        private var overflowed = false

        init(maximumByteCount: UInt64) {
            self.maximumByteCount = maximumByteCount
        }

        func drain(_ handle: FileHandle) {
            defer {
                try? handle.close()
            }
            while true {
                do {
                    guard let chunk =
                            try handle.read(
                                upToCount: 64 * 1024
                            ),
                          !chunk.isEmpty else {
                        return
                    }
                    lock.lock()
                    let next = totalByteCount
                        .addingReportingOverflow(
                            UInt64(chunk.count)
                        )
                    if next.overflow {
                        overflowed = true
                        totalByteCount = UInt64.max
                    } else {
                        totalByteCount = next.partialValue
                    }
                    let remaining =
                        maximumByteCount
                            > UInt64(bytes.count)
                        ? maximumByteCount
                            - UInt64(bytes.count)
                        : 0
                    if remaining > 0 {
                        bytes.append(
                            chunk.prefix(Int(remaining))
                        )
                    }
                    if totalByteCount
                        > maximumByteCount
                    {
                        overflowed = true
                    }
                    lock.unlock()
                } catch {
                    lock.lock()
                    overflowed = true
                    lock.unlock()
                    return
                }
            }
        }

        func snapshot() -> (
            data: Data,
            totalByteCount: UInt64,
            overflowed: Bool
        ) {
            lock.lock()
            defer {
                lock.unlock()
            }
            return (bytes, totalByteCount, overflowed)
        }
    }

    private func run(
        operation: String,
        repositoryRoot: URL,
        arguments: [String],
        maximumStdoutByteCount: UInt64
    ) throws -> ProcessResult {
        let process = Process()
        process.executableURL = Self.gitExecutableURL
        let actualArguments =
            [
                "--no-replace-objects",
                "-c",
                "core.fsmonitor=false",
                "-C",
                repositoryRoot.path,
            ] + arguments
        process.arguments = actualArguments
        process.environment = [
            "GIT_NO_REPLACE_OBJECTS": "1",
            "GIT_OPTIONAL_LOCKS": "0",
            "GIT_CONFIG_NOSYSTEM": "1",
            "GIT_CONFIG_GLOBAL": "/dev/null",
            "GIT_CONFIG_SYSTEM": "/dev/null",
            "GIT_TERMINAL_PROMPT": "0",
            "GIT_PAGER": "cat",
            "GIT_FLUSH": "1",
            "LC_ALL": "C",
            "LANG": "C",
        ]
        process.currentDirectoryURL =
            URL(fileURLWithPath: "/")
        let standardInput =
            FileHandle(forReadingAtPath: "/dev/null")
        process.standardInput = standardInput
        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        let stdoutCapture = CaptureBox(
            maximumByteCount: maximumStdoutByteCount
        )
        let stderrCapture = CaptureBox(
            maximumByteCount:
                UInt64(Self.stderrMaximumByteCount)
        )
        let captureGroup = DispatchGroup()
        let termination = DispatchSemaphore(value: 0)
        process.terminationHandler = { _ in
            termination.signal()
        }

        do {
            try process.run()
        } catch {
            try? standardInput?.close()
            throw PrimeNativeContractMigrationError
                .gitProcessFailed(
                    operation: operation,
                    status: -1,
                    stderrSHA256:
                        PrimeSHA256.hexDigest(
                            of: Data()
                        )
                )
        }
        try? standardInput?.close()
        try? stdoutPipe.fileHandleForWriting.close()
        try? stderrPipe.fileHandleForWriting.close()

        captureGroup.enter()
        DispatchQueue.global(qos: .utility).async {
            stdoutCapture.drain(
                stdoutPipe.fileHandleForReading
            )
            captureGroup.leave()
        }
        captureGroup.enter()
        DispatchQueue.global(qos: .utility).async {
            stderrCapture.drain(
                stderrPipe.fileHandleForReading
            )
            captureGroup.leave()
        }

        let waitResult = termination.wait(
            timeout:
                .now()
                + Self.processTimeoutSeconds
        )
        if waitResult == .timedOut {
            process.terminate()
            if termination.wait(
                timeout: .now() + 2
            ) == .timedOut
            {
                #if canImport(Darwin)
                _ = Darwin.kill(
                    process.processIdentifier,
                    SIGKILL
                )
                #else
                _ = Glibc.kill(
                    process.processIdentifier,
                    SIGKILL
                )
                #endif
                _ = termination.wait(
                    timeout: .now() + 2
                )
            }
            _ = Self.finishCaptures(
                captureGroup,
                stdoutPipe: stdoutPipe,
                stderrPipe: stderrPipe
            )
            throw PrimeNativeContractMigrationError
                .gitProcessTimedOut(operation)
        }
        guard Self.finishCaptures(
            captureGroup,
            stdoutPipe: stdoutPipe,
            stderrPipe: stderrPipe
        ) else {
            throw PrimeNativeContractMigrationError
                .gitProcessTimedOut(operation)
        }

        let stdout = stdoutCapture.snapshot()
        let stderr = stderrCapture.snapshot()
        let overflowed =
            stdout.overflowed || stderr.overflowed
        let normalizedArguments =
            actualArguments.map {
                $0 == repositoryRoot.path
                    ? "<repository-root>"
                    : $0
            }
        let reason: String
        switch process.terminationReason {
        case .exit:
            reason = "exit"
        case .uncaughtSignal:
            reason = "uncaught_signal"
        @unknown default:
            reason = "unknown"
        }
        let observation =
            PrimeNativeMigrationGitCommandObservation(
                operation: operation,
                argv: normalizedArguments,
                processIdentifier:
                    process.processIdentifier,
                terminationStatus:
                    process.terminationStatus,
                terminationReason: reason,
                stdoutByteCount:
                    stdout.totalByteCount,
                stdoutSHA256:
                    PrimeSHA256.hexDigest(
                        of: stdout.data
                    ),
                stderrByteCount:
                    stderr.totalByteCount,
                stderrSHA256:
                    PrimeSHA256.hexDigest(
                        of: stderr.data
                    ),
                outputOverflowed: overflowed
            )
        guard !overflowed else {
            throw PrimeNativeContractMigrationError
                .gitOutputTooLarge(operation)
        }
        guard process.terminationReason == .exit,
              process.terminationStatus == 0 else {
            throw PrimeNativeContractMigrationError
                .gitProcessFailed(
                    operation: operation,
                    status:
                        process.terminationStatus,
                    stderrSHA256:
                        observation.stderrSHA256
                )
        }
        return ProcessResult(
            stdout: stdout.data,
            observation: observation
        )
    }

    private static func parseTreeEntries(
        _ data: Data
    ) throws -> [String: TreeEntry] {
        var entries: [String: TreeEntry] = [:]
        for record in data.split(separator: 0) {
            guard let tab = record.firstIndex(
                of: UInt8(ascii: "\t")
            ) else {
                throw PrimeNativeContractMigrationError
                    .malformedGitOutput(
                        "inventory_tree"
                    )
            }
            let header = String(
                decoding: record[..<tab],
                as: UTF8.self
            ).split(separator: " ")
            let pathStart = record.index(after: tab)
            let path = String(
                decoding: record[pathStart...],
                as: UTF8.self
            )
            guard header.count == 3,
                  !path.isEmpty,
                  entries[path] == nil else {
                throw PrimeNativeContractMigrationError
                    .malformedGitOutput(
                        "inventory_tree"
                    )
            }
            entries[path] = TreeEntry(
                mode: String(header[0]),
                objectType: String(header[1]),
                objectID: String(header[2])
            )
        }
        return entries
    }

    private static func singleLine(
        _ data: Data,
        operation: String
    ) throws -> String {
        guard let value = String(
            data: data,
            encoding: .utf8
        ) else {
            throw PrimeNativeContractMigrationError
                .malformedGitOutput(operation)
        }
        let lines = value.split(
            whereSeparator: \.isNewline
        )
        guard lines.count == 1,
              !lines[0].isEmpty else {
            throw PrimeNativeContractMigrationError
                .malformedGitOutput(operation)
        }
        return String(lines[0])
    }

    private static func validateRepositoryRoot(
        _ root: URL
    ) throws -> URL {
        guard root.isFileURL,
              root.path.hasPrefix("/"),
              root.standardizedFileURL.path == root.path,
              root.resolvingSymlinksInPath()
                .standardizedFileURL.path
                == root.path,
              !root.path.contains("\0") else {
            throw PrimeNativeContractMigrationError
                .invalidRepositoryRoot
        }
        var metadata = stat()
        guard lstat(root.path, &metadata) == 0,
              metadata.st_mode & mode_t(S_IFMT)
                == mode_t(S_IFDIR),
              metadata.st_uid == geteuid(),
              metadata.st_mode & mode_t(0o022) == 0 else {
            throw PrimeNativeContractMigrationError
                .invalidRepositoryRoot
        }
        return root
    }

    private static func gitToolBinding(
        version: String,
        versionData: Data
    ) throws -> PrimeNativeMigrationGitToolBinding {
        let url = gitExecutableURL
        var metadata = stat()
        guard lstat(url.path, &metadata) == 0,
              metadata.st_mode & mode_t(S_IFMT)
                == mode_t(S_IFREG),
              metadata.st_size > 0,
              metadata.st_ino > 0 else {
            throw PrimeNativeContractMigrationError
                .repositoryIdentityMismatch
        }
        let data = try Data(
            contentsOf: url,
            options: [.mappedIfSafe]
        )
        guard data.count
                == Int(metadata.st_size) else {
            throw PrimeNativeContractMigrationError
                .repositoryIdentityMismatch
        }
        return PrimeNativeMigrationGitToolBinding(
            absolutePath: url.path,
            sha256: PrimeSHA256.hexDigest(of: data),
            byteCount: UInt64(data.count),
            deviceID:
                UInt64(
                    bitPattern: Int64(metadata.st_dev)
                ),
            inode: UInt64(metadata.st_ino),
            version: version,
            versionOutputSHA256:
                PrimeSHA256.hexDigest(of: versionData),
            environmentPolicyID: environmentPolicyID
        )
    }

    private static func incremented(
        _ value: UInt64
    ) -> UInt64 {
        let next = value.addingReportingOverflow(1)
        return next.overflow ? UInt64.max : next.partialValue
    }

    private static func finishCaptures(
        _ group: DispatchGroup,
        stdoutPipe: Pipe,
        stderrPipe: Pipe
    ) -> Bool {
        if group.wait(
            timeout: .now() + 2
        ) == .success {
            return true
        }
        try? stdoutPipe.fileHandleForReading.close()
        try? stderrPipe.fileHandleForReading.close()
        _ = group.wait(
            timeout: .now() + 2
        )
        return false
    }
}
