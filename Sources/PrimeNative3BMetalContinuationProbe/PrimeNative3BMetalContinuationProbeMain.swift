import CryptoKit
import Darwin
import Foundation
import MLX
import MLXLLM
import MLXNN
import MLXOptimizers
import PrimeCore

private enum ProbeError: Error, CustomStringConvertible {
    case invalidArgument(String)
    case executableUnreadable
    case executableIdentityMismatch
    case supervisorCapabilityRequired
    case supervisorCapabilityRejected
    case supervisorParentIdentityMismatch
    case supervisorAuthorityLeaseMissing
    case artifactRootAdmissionFailed
    case sourceEvidence(String)
    case dependencyEvidence(String)
    case priorEvidence(String)
    case mechanics(String)
    case checkpoint(String)
    case workerRecord(String)
    case childFailed(
        role: String,
        status: Int32,
        outputByteCount: UInt64,
        outputSHA256: String,
        overflowed: Bool
    )
    case childTimedOut(String)
    case childTerminationUnobserved(
        role: String,
        detail: String
    )
    case childOutputDrainIncomplete(String)
    case receiptRoundTripMismatch

    var description: String {
        switch self {
        case let .invalidArgument(detail):
            "invalid argument: \(detail)"
        case .executableUnreadable:
            "running executable is unreadable"
        case .executableIdentityMismatch:
            "running executable differs from the staged executable"
        case .supervisorCapabilityRequired:
            "worker requires a supervisor capability"
        case .supervisorCapabilityRejected:
            "worker rejected the supervisor capability"
        case .supervisorParentIdentityMismatch:
            "worker parent is not the same executable"
        case .supervisorAuthorityLeaseMissing:
            "worker could not prove a live supervisor lease"
        case .artifactRootAdmissionFailed:
            "run root must be a new empty private directory"
        case let .sourceEvidence(detail):
            "Prime source evidence mismatch: \(detail)"
        case let .dependencyEvidence(detail):
            "MLX dependency evidence mismatch: \(detail)"
        case let .priorEvidence(detail):
            "Prime prior evidence mismatch: \(detail)"
        case let .mechanics(detail):
            "exact-3B mechanics failed: \(detail)"
        case let .checkpoint(detail):
            "checkpoint contract failed: \(detail)"
        case let .workerRecord(detail):
            "worker record failed: \(detail)"
        case let .childFailed(
            role,
            status,
            outputByteCount,
            outputSHA256,
            overflowed
        ):
            "\(role) exited with status \(status); output_bytes=\(outputByteCount) output_sha256=\(outputSHA256) overflowed=\(overflowed)"
        case let .childTimedOut(role):
            "\(role) exceeded its bounded execution window"
        case let .childTerminationUnobserved(role, detail):
            "\(role) termination was not observed; \(detail)"
        case let .childOutputDrainIncomplete(role):
            "\(role) output drain did not complete"
        case .receiptRoundTripMismatch:
            "published receipt did not round-trip exactly"
        }
    }
}

private enum ProbeRole: String {
    case parent
    case control
    case writer
    case restorer

    var workerRole:
        PrimeNative3BMetalContinuationWorkerRole?
    {
        switch self {
        case .parent:
            nil
        case .control:
            .control
        case .writer:
            .writer
        case .restorer:
            .restorer
        }
    }
}

private struct Arguments {
    var artifactRoot: URL?
    var sourceRoot: URL?
    var metalLeaseFile: URL?
    var role: ProbeRole = .parent
    var publishedExecutableSHA256: String?
    var internalWorkerCapabilitySHA256: String?
    var receiptPath =
        "prime-native-3b-metal-continuation-receipt.v1.json"
}

private struct ResolvedFile: Decodable {
    struct Pin: Decodable {
        struct State: Decodable {
            let revision: String
        }

        let identity: String
        let kind: String
        let location: String
        let state: State
    }

    let pins: [Pin]
}

private struct MirrorFile: Decodable, Equatable {
    struct Entry: Decodable, Equatable {
        let mirror: String
        let original: String
    }

    let object: [Entry]
    let version: Int
}

private struct BoundedOutput {
    let byteCount: UInt64
    let sha256: String
    let overflowed: Bool
    let drainCompleted: Bool
}

private final class BoundedPipeCapture:
    @unchecked Sendable
{
    private let maximumByteCount: Int
    private let lock = NSLock()
    private var bytes = Data()
    private var totalByteCount: UInt64 = 0
    private var didOverflow = false
    private var didComplete = false

    init(maximumByteCount: Int) {
        self.maximumByteCount = maximumByteCount
    }

    func start(
        reading handle: FileHandle,
        in group: DispatchGroup
    ) {
        group.enter()
        DispatchQueue.global(
            qos: .utility
        ).async {
            defer {
                self.lock.lock()
                self.didComplete = true
                self.lock.unlock()
                try? handle.close()
                group.leave()
            }
            while true {
                do {
                    guard let chunk =
                            try handle.read(
                                upToCount: 16 * 1024
                            ),
                          !chunk.isEmpty else {
                        return
                    }
                    self.lock.lock()
                    self.totalByteCount &+=
                        UInt64(chunk.count)
                    let remaining =
                        max(
                            0,
                            self.maximumByteCount
                                - self.bytes.count
                        )
                    if remaining > 0 {
                        self.bytes.append(
                            chunk.prefix(remaining)
                        )
                    }
                    if self.totalByteCount
                        > UInt64(
                            self.maximumByteCount
                        )
                    {
                        self.didOverflow = true
                    }
                    self.lock.unlock()
                } catch {
                    self.lock.lock()
                    self.didOverflow = true
                    self.lock.unlock()
                    return
                }
            }
        }
    }

    func snapshot() -> BoundedOutput {
        lock.lock()
        defer { lock.unlock() }
        return BoundedOutput(
            byteCount: totalByteCount,
            sha256:
                PrimeSHA256.hexDigest(of: bytes),
            overflowed: didOverflow,
            drainCompleted: didComplete
        )
    }
}

private struct ChildExit {
    let role: ProbeRole
    let processIdentifier: Int32
    let terminationReason:
        Process.TerminationReason
    let terminationStatus: Int32
    let output: BoundedOutput
    let record: PrimeArtifactBinding
}

private func supervisorObservation(
    exit: ChildExit,
    worker:
        PrimeNative3BMetalContinuationWorkerRecord
) throws -> PrimeNative3BSupervisorProcessObservation {
    try worker.validate()
    let expectedRole:
        PrimeNative3BMetalContinuationWorkerRole
    switch exit.role {
    case .control:
        expectedRole = .control
    case .writer:
        expectedRole = .writer
    case .restorer:
        expectedRole = .restorer
    case .parent:
        throw ProbeError.workerRecord(
            "parent cannot produce worker process evidence"
        )
    }
    guard worker.role == expectedRole,
          worker.processIdentifier
            == exit.processIdentifier else {
        throw ProbeError.workerRecord(
            "worker role or PID differs from the launched child"
        )
    }
    let observation =
        PrimeNative3BSupervisorProcessObservation(
            role: expectedRole,
            processIdentifier:
                exit.processIdentifier,
            terminationReason:
                exit.terminationReason == .exit
                ? .exit
                : .uncaughtSignal,
            terminationStatus:
                exit.terminationStatus,
            outputByteCount:
                exit.output.byteCount,
            outputSHA256:
                exit.output.sha256,
            outputOverflowed:
                exit.output.overflowed,
            outputDrainCompleted:
                exit.output.drainCompleted,
            workerRecord: exit.record
        )
    try observation.validate()
    return observation
}

private let stagedDirectory = "content-staging"
private let evidenceDirectory =
    "\(stagedDirectory)/evidence"
private let dependencyEvidenceDirectory =
    "\(evidenceDirectory)/mlx-swift"
private let dependencyTreeEvidencePath =
    "\(dependencyEvidenceDirectory)/dependency-source-tree.v1.json"
private let sourceSnapshotPath =
    "\(stagedDirectory)/prime-swift-source-snapshot.v1.json"
private let runtimeBindingPath =
    "\(stagedDirectory)/native-3b-continuation-runtime-image.v1.json"
private let priorEvidenceDirectory =
    "\(stagedDirectory)/prior-prime-evidence"
private let priorExact3BReceiptPath =
    "\(priorEvidenceDirectory)/prime-gpu-calibration-receipt.v2.json"
private let priorExact3BConfigurationPath =
    "\(priorEvidenceDirectory)/prime-3b-fp32-execution-configuration.v2.json"
private let priorExact3BSourceSnapshotPath =
    "\(priorEvidenceDirectory)/prime-swift-source-snapshot.v1.json"
private let priorTypedRestoreReceiptPath =
    "\(priorEvidenceDirectory)/prime-typed-optimizer-restore-receipt.v2.json"
private let controlRecordPath =
    "\(stagedDirectory)/native-3b-continuation-control.v1.json"
private let writerRecordPath =
    "\(stagedDirectory)/native-3b-continuation-writer.v1.json"
private let writerPreSaveRecordPath =
    "\(stagedDirectory)/native-3b-continuation-writer-pre-save.v1.json"
private let restorerRecordPath =
    "\(stagedDirectory)/native-3b-continuation-restorer.v1.json"
private let checkpointManifestPath =
    "\(stagedDirectory)/native-3b-continuation-checkpoint-manifest.v1.json"
private let modelCheckpointPath =
    "\(stagedDirectory)/model-after-step-1.v1.safetensors"
private let firstMomentCheckpointPath =
    "\(stagedDirectory)/adam-first-moment-after-step-1.v1.safetensors"
private let secondMomentCheckpointPath =
    "\(stagedDirectory)/adam-second-moment-after-step-1.v1.safetensors"
private let supervisorAuthorityLeaseName =
    ".prime-native-3b-supervisor-authority.lock"
private let stagedExecutablePath =
    PrimeMLXRuntimeImageLayout
        .native3BMetalContinuationProbe
        .stagedExecutableRelativePath
private let stagedExecutableMaximumBytes:
    UInt64 = 256 * 1024 * 1024
private let childOutputMaximumBytes =
    Int(
        PrimeNative3BMetalContinuationContract
            .childOutputMaximumByteCount
    )
private let childWallLimitSeconds = 3_600
private let terminationGraceMilliseconds = 10_000

private func parseArguments() throws -> Arguments {
    var result = Arguments()
    var values = Array(
        CommandLine.arguments.dropFirst()
    )
    while !values.isEmpty {
        let key = values.removeFirst()
        guard !values.isEmpty else {
            throw ProbeError.invalidArgument(
                "missing value for \(key)"
            )
        }
        let value = values.removeFirst()
        switch key {
        case "--artifact-root":
            result.artifactRoot = URL(
                fileURLWithPath: value,
                isDirectory: true
            ).standardizedFileURL
        case "--source-root":
            result.sourceRoot = URL(
                fileURLWithPath: value,
                isDirectory: true
            ).standardizedFileURL
        case "--metal-lease-file":
            result.metalLeaseFile = URL(
                fileURLWithPath: value
            ).standardizedFileURL
        case "--internal-role":
            guard let role = ProbeRole(
                rawValue: value
            ) else {
                throw ProbeError.invalidArgument(
                    "unknown role \(value)"
                )
            }
            result.role = role
        case "--published-executable-sha256":
            result.publishedExecutableSHA256 =
                value
        case "--internal-worker-capability-sha256":
            result.internalWorkerCapabilitySHA256 =
                value
        case "--receipt-path":
            result.receiptPath = value
        default:
            throw ProbeError.invalidArgument(
                "unknown option \(key)"
            )
        }
    }

    guard let artifactRoot = result.artifactRoot,
          let sourceRoot = result.sourceRoot,
          let metalLeaseFile =
            result.metalLeaseFile,
          artifactRoot.path.hasPrefix("/"),
          sourceRoot.path.hasPrefix("/"),
          metalLeaseFile.path.hasPrefix("/")
    else {
        throw ProbeError.invalidArgument(
            "absolute artifact root, source root, and Metal lease file are required"
        )
    }
    let receiptComponents =
        result.receiptPath.split(
            separator: "/",
            omittingEmptySubsequences: false
        )
    guard result.receiptPath
            == "prime-native-3b-metal-continuation-receipt.v1.json",
          receiptComponents.count == 1 else {
        throw ProbeError.invalidArgument(
            "receipt path is frozen to one root-level filename"
        )
    }
    if result.role == .parent {
        guard result
            .publishedExecutableSHA256 == nil,
            result
                .internalWorkerCapabilitySHA256
                == nil else {
            throw ProbeError.invalidArgument(
                "worker-only arguments are not valid for the parent"
            )
        }
    } else {
        guard let executableHash =
                result
                .publishedExecutableSHA256,
              let capabilityHash =
                result
                .internalWorkerCapabilitySHA256,
              isSHA256(executableHash),
              isSHA256(capabilityHash) else {
            throw ProbeError
                .supervisorCapabilityRequired
        }
    }
    return result
}

private func isSHA256(_ value: String) -> Bool {
    value.utf8.count == 64
        && value.utf8.allSatisfy {
            ($0 >= 48 && $0 <= 57)
                || ($0 >= 97 && $0 <= 102)
        }
}

private func verifyInheritedSupervisorCapability(
    expectedSHA256: String
) throws {
    let expectedByteCount = 36
    let deadline =
        DispatchTime.now().uptimeNanoseconds
        + 5_000_000_000
    var capability = Data()

    while capability.count < expectedByteCount {
        let now =
            DispatchTime.now().uptimeNanoseconds
        guard now < deadline else {
            throw ProbeError
                .supervisorCapabilityRejected
        }
        let remaining = deadline - now
        var descriptor = pollfd(
            fd: STDIN_FILENO,
            events: Int16(POLLIN | POLLHUP),
            revents: 0
        )
        let result = poll(
            &descriptor,
            1,
            Int32(
                min(
                    UInt64(Int32.max),
                    max(
                        UInt64(1),
                        (
                            remaining
                                + 999_999
                        ) / 1_000_000
                    )
                )
            )
        )
        if result < 0, errno == EINTR {
            continue
        }
        guard result > 0 else {
            throw ProbeError
                .supervisorCapabilityRejected
        }
        var buffer = [UInt8](
            repeating: 0,
            count:
                expectedByteCount
                - capability.count
        )
        let count =
            buffer.withUnsafeMutableBytes {
                read(
                    STDIN_FILENO,
                    $0.baseAddress,
                    $0.count
                )
            }
        if count < 0, errno == EINTR {
            continue
        }
        guard count >= 0 else {
            throw ProbeError
                .supervisorCapabilityRejected
        }
        guard count > 0 else {
            throw ProbeError
                .supervisorCapabilityRejected
        }
        capability.append(
            contentsOf: buffer[0 ..< count]
        )
    }
    guard capability.count == expectedByteCount,
          PrimeSHA256.hexDigest(of: capability)
            == expectedSHA256 else {
        throw ProbeError
            .supervisorCapabilityRejected
    }
}

private func runningExecutableURL() throws -> URL {
    var requiredSize: UInt32 = 0
    _ = _NSGetExecutablePath(nil, &requiredSize)
    guard requiredSize > 1 else {
        throw ProbeError.executableUnreadable
    }
    var buffer = [CChar](
        repeating: 0,
        count: Int(requiredSize)
    )
    guard _NSGetExecutablePath(
        &buffer,
        &requiredSize
    ) == 0 else {
        throw ProbeError.executableUnreadable
    }
    return URL(
        fileURLWithPath: String(cString: buffer)
    ).resolvingSymlinksInPath()
}

private func runningExecutableData() throws -> Data {
    do {
        let loaded =
            try PrimeNative3BLoadedExecutableVnode
                .observeCurrentProcess()
        return try stableRegularFileData(
            at: runningExecutableURL(),
            maximumBytes:
                256 * 1024 * 1024,
            expectedLoadedExecutable: loaded
        )
    } catch {
        throw ProbeError.executableUnreadable
    }
}

private func verifyExecutableIdentity(
    _ expectedSHA256: String
) throws {
    guard PrimeSHA256.hexDigest(
        of: try runningExecutableData()
    ) == expectedSHA256 else {
        throw ProbeError
            .executableIdentityMismatch
    }
}

private func verifySameExecutableSupervisorParent()
    throws
{
    var buffer = [CChar](
        repeating: 0,
        count: 4 * Int(MAXPATHLEN)
    )
    let count = proc_pidpath(
        getppid(),
        &buffer,
        UInt32(buffer.count)
    )
    guard count > 0 else {
        throw ProbeError
            .supervisorParentIdentityMismatch
    }
    let parentData =
        try stableRegularFileData(
            at: URL(
                fileURLWithPath:
                    String(cString: buffer)
            ),
            maximumBytes:
                256 * 1024 * 1024
        )
    let currentData =
        try runningExecutableData()
    guard parentData.count == currentData.count,
          PrimeSHA256.hexDigest(of: parentData)
            == PrimeSHA256.hexDigest(
                of: currentData
            ) else {
        throw ProbeError
            .supervisorParentIdentityMismatch
    }
}

private func verifySupervisorAuthorityLeaseHeld(
    artifactRootURL: URL
) throws {
    let leaseURL =
        artifactRootURL.appendingPathComponent(
            supervisorAuthorityLeaseName
        )
    do {
        let unexpected =
            try PrimeExclusiveProcessLease.acquire(
                at: leaseURL
            )
        unexpected.release()
    } catch let error as
        PrimeMetalDeviceLeaseError
    {
        guard error == .busy else {
            throw ProbeError
                .supervisorAuthorityLeaseMissing
        }
        return
    } catch {
        throw ProbeError
            .supervisorAuthorityLeaseMissing
    }
    throw ProbeError
        .supervisorAuthorityLeaseMissing
}

private struct VerifiedDependencySource {
    let packageManifest: Data
    let packageResolution: Data
    let mirrorConfiguration: Data
    let dependencyTree:
        PrimeTypedOptimizerDependencyTreeEvidence
    let license: Data
    let typedStateSource: Data
    let optimizerSource: Data
    let ioSource: Data
}

private struct WorkerContext {
    let executable: PrimeArtifactBinding
    let runtime: PrimePinnedMLXMetallibBinding
    let sourceSnapshot: PrimeArtifactBinding
    let priorEvidence:
        PrimeNative3BContinuationPriorEvidenceBindings
    let dependencyEvidence:
        PrimeNative3BContinuationDependencyEvidence
}

private func stableRegularFileData(
    at url: URL,
    maximumBytes: Int,
    expectedLoadedExecutable:
        PrimeNative3BLoadedExecutableVnode? = nil
) throws -> Data {
    var pathMetadata = stat()
    guard lstat(url.path, &pathMetadata) == 0,
          pathMetadata.st_mode & S_IFMT
            == S_IFREG,
          pathMetadata.st_size >= 0,
          pathMetadata.st_size
            <= off_t(maximumBytes) else {
        throw ProbeError.sourceEvidence(
            "unsafe regular file"
        )
    }
    let descriptor = open(
        url.path,
        O_RDONLY | O_CLOEXEC | O_NOFOLLOW
            | O_NONBLOCK
    )
    guard descriptor >= 0 else {
        throw ProbeError.sourceEvidence(
            "regular file open failed"
        )
    }
    defer { _ = close(descriptor) }
    var before = stat()
    guard fstat(descriptor, &before) == 0,
          before.st_mode & S_IFMT == S_IFREG,
          before.st_dev == pathMetadata.st_dev,
          before.st_ino == pathMetadata.st_ino,
          before.st_size == pathMetadata.st_size
    else {
        throw ProbeError.sourceEvidence(
            "regular file identity changed"
        )
    }
    if let expectedLoadedExecutable {
        try expectedLoadedExecutable.requireMatches(
            deviceID:
                UInt64(
                    bitPattern:
                        Int64(before.st_dev)
                ),
            inode: UInt64(before.st_ino)
        )
    }

    var result = Data()
    result.reserveCapacity(Int(before.st_size))
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
            throw ProbeError.sourceEvidence(
                "regular file read failed"
            )
        }
        if count == 0 {
            break
        }
        result.append(
            contentsOf: buffer[0 ..< count]
        )
        guard result.count <= maximumBytes
        else {
            throw ProbeError.sourceEvidence(
                "regular file exceeded cap"
            )
        }
    }
    var after = stat()
    guard fstat(descriptor, &after) == 0,
          before.st_dev == after.st_dev,
          before.st_ino == after.st_ino,
          before.st_size == after.st_size,
          before.st_mtimespec.tv_sec
            == after.st_mtimespec.tv_sec,
          before.st_mtimespec.tv_nsec
            == after.st_mtimespec.tv_nsec,
          before.st_ctimespec.tv_sec
            == after.st_ctimespec.tv_sec,
          before.st_ctimespec.tv_nsec
            == after.st_ctimespec.tv_nsec,
          result.count == Int(after.st_size)
    else {
        throw ProbeError.sourceEvidence(
            "regular file changed during read"
        )
    }
    return result
}

private func publishStagedExecutable(
    _ bytes: Data,
    root: PrimeArtifactRoot
) throws -> PrimeArtifactBinding {
    guard !bytes.isEmpty,
          UInt64(bytes.count)
            <= stagedExecutableMaximumBytes else {
        throw ProbeError.executableUnreadable
    }
    return try root.publishGeneratedFile(
        at: stagedExecutablePath,
        purpose: .executable,
        maximumByteCount:
            stagedExecutableMaximumBytes
    ) { descriptor in
        try bytes.withUnsafeBytes { buffer in
            guard let base = buffer.baseAddress
            else {
                throw ProbeError
                    .executableUnreadable
            }
            var offset = 0
            while offset < buffer.count {
                let count = Darwin.write(
                    descriptor,
                    base.advanced(by: offset),
                    buffer.count - offset
                )
                if count < 0, errno == EINTR {
                    continue
                }
                guard count > 0 else {
                    throw ProbeError
                        .executableUnreadable
                }
                offset += count
            }
        }
    }
}

private func checkoutURL(
    sourceRoot: URL
) -> URL {
    sourceRoot
        .appendingPathComponent(".build")
        .appendingPathComponent("checkouts")
        .appendingPathComponent(
            PrimeTypedOptimizerDependencyTree
                .checkoutDirectoryName
        )
}

private func verifyDependency(
    sourceRoot: URL
) throws -> VerifiedDependencySource {
    let plan =
        PrimeNative3BContinuationDependencyPlan
            .frozenV1
    try plan.validate()
    let packageManifest =
        try stableRegularFileData(
            at:
                sourceRoot.appendingPathComponent(
                    "Package.swift"
                ),
            maximumBytes: 4 * 1024 * 1024
        )
    let packageResolution =
        try stableRegularFileData(
            at:
                sourceRoot.appendingPathComponent(
                    "Package.resolved"
                ),
            maximumBytes: 4 * 1024 * 1024
        )
    let mirrorConfiguration =
        try stableRegularFileData(
            at:
                sourceRoot.appendingPathComponent(
                    PrimeTypedOptimizerRestorePlan
                        .frozenSchemaV2
                        .mirrorConfigurationPath
                ),
            maximumBytes: 4 * 1024 * 1024
        )
    guard PrimeSHA256.hexDigest(
            of: packageManifest
          ) == plan.packageManifestSHA256,
          PrimeSHA256.hexDigest(
            of: packageResolution
          ) == plan.packageResolutionSHA256,
          PrimeSHA256.hexDigest(
            of: mirrorConfiguration
          ) == plan.mirrorConfigurationSHA256,
          let packageText = String(
            data: packageManifest,
            encoding: .utf8
          ),
          packageText.components(
              separatedBy: plan.forkRepository
          ).count == 2,
          packageText.components(
              separatedBy: plan.forkRevision
          ).count == 2 else {
        throw ProbeError.dependencyEvidence(
            "package declaration or hash"
        )
    }

    let resolved = try JSONDecoder().decode(
        ResolvedFile.self,
        from: packageResolution
    )
    let pins = resolved.pins.filter {
        $0.identity
            == PrimeTypedOptimizerDependencyTree
                .swiftPackageIdentity
    }
    guard pins.count == 1,
          pins[0].kind == "remoteSourceControl",
          pins[0].location
            == PrimeTypedOptimizerRestorePlan
                .frozenSchemaV2
                .packageResolvedCanonicalLocation,
          pins[0].state.revision
            == plan.forkRevision else {
        throw ProbeError.dependencyEvidence(
            "resolved fork revision"
        )
    }

    let mirror = try JSONDecoder().decode(
        MirrorFile.self,
        from: mirrorConfiguration
    )
    guard mirror == MirrorFile(
        object: [
            .init(
                mirror:
                    PrimeTypedOptimizerRestorePlan
                    .frozenSchemaV2
                    .mirrorTargetRepository,
                original:
                    PrimeTypedOptimizerRestorePlan
                    .frozenSchemaV2
                    .mirrorOriginalRepository
            ),
        ],
        version: 1
    ) else {
        throw ProbeError.dependencyEvidence(
            "mirror configuration"
        )
    }

    let checkout = checkoutURL(
        sourceRoot: sourceRoot
    )
    let license = try stableRegularFileData(
        at:
            checkout.appendingPathComponent(
                "LICENSE"
            ),
        maximumBytes: 4 * 1024 * 1024
    )
    let typedStateSource =
        try stableRegularFileData(
            at:
                checkout.appendingPathComponent(
                    plan.typedStateSourcePath
                ),
            maximumBytes: 4 * 1024 * 1024
        )
    let optimizerSource =
        try stableRegularFileData(
            at:
                checkout.appendingPathComponent(
                    plan.optimizerSourcePath
                ),
            maximumBytes: 4 * 1024 * 1024
        )
    let ioSource = try stableRegularFileData(
        at:
            checkout.appendingPathComponent(
                plan.ioSourcePath
            ),
        maximumBytes: 4 * 1024 * 1024
    )
    guard PrimeSHA256.hexDigest(of: license)
            == plan.licenseSHA256,
          PrimeSHA256.hexDigest(
              of: typedStateSource
          ) == plan.typedStateSourceSHA256,
          PrimeSHA256.hexDigest(
              of: optimizerSource
          ) == plan.optimizerSourceSHA256,
          PrimeSHA256.hexDigest(of: ioSource)
            == plan.ioSourceSHA256 else {
        throw ProbeError.dependencyEvidence(
            "reviewed dependency source hash"
        )
    }
    let dependencyTree =
        try PrimeTypedOptimizerDependencyTree
            .capture(at: checkout)
    try PrimeTypedOptimizerDependencyTree
        .validateStructure(dependencyTree)
    guard PrimeSHA256.hexDigest(
        of:
            try PrimeCanonicalJSON.encode(
                dependencyTree
            )
    ) == plan.dependencyTreeManifestSHA256
    else {
        throw ProbeError.dependencyEvidence(
            "complete dependency tree"
        )
    }
    return VerifiedDependencySource(
        packageManifest: packageManifest,
        packageResolution: packageResolution,
        mirrorConfiguration:
            mirrorConfiguration,
        dependencyTree: dependencyTree,
        license: license,
        typedStateSource: typedStateSource,
        optimizerSource: optimizerSource,
        ioSource: ioSource
    )
}

private func publishDependencyEvidence(
    sourceRoot: URL,
    root: PrimeArtifactRoot
) throws
    -> PrimeNative3BContinuationDependencyEvidence
{
    let source = try verifyDependency(
        sourceRoot: sourceRoot
    )
    try root.ensurePrivateDirectory(
        at: evidenceDirectory
    )
    try root.ensurePrivateDirectory(
        at: dependencyEvidenceDirectory
    )
    let evidence =
        PrimeNative3BContinuationDependencyEvidence(
            packageManifest: try root.publish(
                source.packageManifest,
                at:
                    "\(evidenceDirectory)/Package.swift",
                purpose: .immutableData
            ),
            packageResolution: try root.publish(
                source.packageResolution,
                at:
                    "\(evidenceDirectory)/Package.resolved",
                purpose: .immutableData
            ),
            mirrorConfiguration: try root.publish(
                source.mirrorConfiguration,
                at:
                    "\(evidenceDirectory)/mirrors.json",
                purpose: .immutableData
            ),
            dependencyTreeManifest:
                try root.publishCanonical(
                    source.dependencyTree,
                    at: dependencyTreeEvidencePath
                ),
            license: try root.publish(
                source.license,
                at:
                    "\(dependencyEvidenceDirectory)/LICENSE",
                purpose: .immutableData
            ),
            typedStateSource: try root.publish(
                source.typedStateSource,
                at:
                    "\(dependencyEvidenceDirectory)/AdamOptimizerState.swift",
                purpose: .immutableData
            ),
            optimizerSource: try root.publish(
                source.optimizerSource,
                at:
                    "\(dependencyEvidenceDirectory)/Optimizers.swift",
                purpose: .immutableData
            ),
            ioSource: try root.publish(
                source.ioSource,
                at:
                    "\(dependencyEvidenceDirectory)/FileDescriptorIO.swift",
                purpose: .immutableData
            )
        )
    try evidence.validate(
        plan:
            PrimeNative3BContinuationDependencyPlan
                .frozenV1
    )
    return evidence
}

private func bindDependencyEvidence(
    sourceRoot: URL,
    root: PrimeArtifactRoot
) throws
    -> PrimeNative3BContinuationDependencyEvidence
{
    let source = try verifyDependency(
        sourceRoot: sourceRoot
    )
    let evidence =
        PrimeNative3BContinuationDependencyEvidence(
            packageManifest:
                try root.bindExisting(
                    at:
                        "\(evidenceDirectory)/Package.swift",
                    purpose: .immutableData
                ),
            packageResolution:
                try root.bindExisting(
                    at:
                        "\(evidenceDirectory)/Package.resolved",
                    purpose: .immutableData
                ),
            mirrorConfiguration:
                try root.bindExisting(
                    at:
                        "\(evidenceDirectory)/mirrors.json",
                    purpose: .immutableData
                ),
            dependencyTreeManifest:
                try root.bindExisting(
                    at: dependencyTreeEvidencePath,
                    purpose: .immutableData
                ),
            license: try root.bindExisting(
                at:
                    "\(dependencyEvidenceDirectory)/LICENSE",
                purpose: .immutableData
            ),
            typedStateSource:
                try root.bindExisting(
                    at:
                        "\(dependencyEvidenceDirectory)/AdamOptimizerState.swift",
                    purpose: .immutableData
                ),
            optimizerSource:
                try root.bindExisting(
                    at:
                        "\(dependencyEvidenceDirectory)/Optimizers.swift",
                    purpose: .immutableData
                ),
            ioSource: try root.bindExisting(
                at:
                    "\(dependencyEvidenceDirectory)/FileDescriptorIO.swift",
                purpose: .immutableData
            )
        )
    try evidence.validate(
        plan:
            PrimeNative3BContinuationDependencyPlan
                .frozenV1
    )
    let publishedTree =
        try root.decodeVerified(
            PrimeTypedOptimizerDependencyTreeEvidence
                .self,
            binding:
                evidence.dependencyTreeManifest,
            maximumByteCount:
                256 * 1024 * 1024
        )
    guard publishedTree
            == source.dependencyTree else {
        throw ProbeError.dependencyEvidence(
            "published dependency tree"
        )
    }
    return evidence
}

private func arcArtifact(
    _ artifactID: String
) throws -> PrimeNativeArcArtifact {
    let plan = PrimeNativeArcContinuityPlan
        .frozenV1
    try plan.validate()
    guard let artifact = plan.artifacts.first(
        where: {
            $0.artifactID == artifactID
        }
    ),
        artifact.authorityOwner
            == "Ergentics/ergentics-prime",
        artifact.locatorScope
            == .repositoryRelativeAtPinnedRevision
    else {
        throw ProbeError.priorEvidence(
            "frozen artifact inventory"
        )
    }
    return artifact
}

private func stagePriorArtifact(
    artifactID: String,
    destinationPath: String,
    sourceRoot: URL,
    root: PrimeArtifactRoot
) throws -> PrimeArtifactBinding {
    let declaration = try arcArtifact(
        artifactID
    )
    let sourceURL =
        sourceRoot.appendingPathComponent(
            declaration.locator
        ).standardizedFileURL
    let prefix =
        sourceRoot.standardizedFileURL.path
        + "/"
    guard sourceURL.path.hasPrefix(prefix) else {
        throw ProbeError.priorEvidence(
            "source path escaped Prime"
        )
    }
    let data = try stableRegularFileData(
        at: sourceURL,
        maximumBytes: 128 * 1024 * 1024
    )
    guard PrimeSHA256.hexDigest(of: data)
            == declaration.sha256 else {
        throw ProbeError.priorEvidence(
            artifactID
        )
    }
    return try root.publish(
        data,
        at: destinationPath,
        purpose: .immutableData
    )
}

private func publishPriorEvidence(
    sourceRoot: URL,
    root: PrimeArtifactRoot
) throws
    -> PrimeNative3BContinuationPriorEvidenceBindings
{
    try root.ensurePrivateDirectory(
        at: priorEvidenceDirectory
    )
    let evidence =
        PrimeNative3BContinuationPriorEvidenceBindings(
            exact3BMechanicsReceipt:
                try stagePriorArtifact(
                    artifactID:
                        "prime_exact_3b_fp32_mechanics_receipt",
                    destinationPath:
                        priorExact3BReceiptPath,
                    sourceRoot: sourceRoot,
                    root: root
                ),
            exact3BExecutionConfiguration:
                try stagePriorArtifact(
                    artifactID:
                        "prime_exact_3b_fp32_execution_configuration",
                    destinationPath:
                        priorExact3BConfigurationPath,
                    sourceRoot: sourceRoot,
                    root: root
                ),
            exact3BSourceSnapshot:
                try stagePriorArtifact(
                    artifactID:
                        "prime_exact_3b_fp32_source_snapshot",
                    destinationPath:
                        priorExact3BSourceSnapshotPath,
                    sourceRoot: sourceRoot,
                    root: root
                ),
            typedOptimizerRestoreReceipt:
                try stagePriorArtifact(
                    artifactID:
                        "prime_typed_optimizer_restore_receipt",
                    destinationPath:
                        priorTypedRestoreReceiptPath,
                    sourceRoot: sourceRoot,
                    root: root
                )
        )
    try evidence.validate()
    return evidence
}

private func bindPriorEvidence(
    root: PrimeArtifactRoot
) throws
    -> PrimeNative3BContinuationPriorEvidenceBindings
{
    let evidence =
        PrimeNative3BContinuationPriorEvidenceBindings(
            exact3BMechanicsReceipt:
                try root.bindExisting(
                    at: priorExact3BReceiptPath,
                    purpose: .immutableData
                ),
            exact3BExecutionConfiguration:
                try root.bindExisting(
                    at:
                        priorExact3BConfigurationPath,
                    purpose: .immutableData
                ),
            exact3BSourceSnapshot:
                try root.bindExisting(
                    at:
                        priorExact3BSourceSnapshotPath,
                    purpose: .immutableData
                ),
            typedOptimizerRestoreReceipt:
                try root.bindExisting(
                    at:
                        priorTypedRestoreReceiptPath,
                    purpose: .immutableData
                )
        )
    try evidence.validate()
    return evidence
}

private func publishSeedProvenance(
    sourceRoot: URL,
    seeds: PrimeExecutionSeeds,
    root: PrimeArtifactRoot
) throws {
    let receipt = try arcArtifact(
        "prime_exact_3b_fp32_mechanics_receipt"
    )
    let evidenceRoot =
        sourceRoot.appendingPathComponent(
            receipt.locator
        ).deletingLastPathComponent()
    for seed in [
        seeds.initialization,
        seeds.trainingSchedule,
        seeds.evaluation,
    ] {
        let sourceURL =
            evidenceRoot.appendingPathComponent(
                seed.provenance.artifactPath
            ).standardizedFileURL
        let prefix =
            evidenceRoot.standardizedFileURL.path
            + "/"
        guard sourceURL.path.hasPrefix(prefix)
        else {
            throw ProbeError.priorEvidence(
                "seed source escaped evidence root"
            )
        }
        let data = try stableRegularFileData(
            at: sourceURL,
            maximumBytes: 16 * 1024 * 1024
        )
        guard PrimeSHA256.hexDigest(of: data)
                == seed.provenance
                    .artifactSHA256 else {
            throw ProbeError.priorEvidence(
                "seed provenance hash"
            )
        }
        _ = try root.publish(
            data,
            at: seed.provenance.artifactPath,
            purpose: .immutableData
        )
        try root.verifySeedProvenance(seed)
    }
}

private func verifySeedProvenance(
    _ seeds: PrimeExecutionSeeds,
    root: PrimeArtifactRoot
) throws {
    for seed in [
        seeds.initialization,
        seeds.trainingSchedule,
        seeds.evaluation,
    ] {
        try root.verifySeedProvenance(seed)
    }
}

private func loadRuntimeBinding(
    root: PrimeArtifactRoot
) throws -> PrimePinnedMLXMetallibBinding {
    let manifest = try root.bindExisting(
        at: runtimeBindingPath,
        purpose: .immutableData
    )
    let runtime = try root.decodeVerified(
        PrimePinnedMLXMetallibBinding.self,
        binding: manifest
    )
    _ = try root.verify(runtime.artifact)
    _ = try root.verify(
        runtime.infoPlistArtifact
    )
    try PrimeMLXRuntimeImageLayout.require(
        runtime.runtimeImageLayout,
        for:
            .native3BMetalContinuationProbe
    )
    return runtime
}

private func bindSourceSnapshot(
    sourceRoot: URL,
    root: PrimeArtifactRoot
) throws -> PrimeArtifactBinding {
    let binding = try root.bindExisting(
        at: sourceSnapshotPath,
        purpose: .immutableData
    )
    let published = try root.decodeVerified(
        PrimeSwiftSourceSnapshot.self,
        binding: binding,
        maximumByteCount:
            128 * 1024 * 1024
    )
    try PrimeSwiftSourceProvenance.validate(
        published,
        requiredRelativePaths:
            PrimeNative3BMetalContinuationContract
            .requiredPrimeSourceRelativePaths
    )
    let observed =
        try PrimeSwiftSourceProvenance.capture(
            at: sourceRoot,
            requiredRelativePaths:
                PrimeNative3BMetalContinuationContract
                .requiredPrimeSourceRelativePaths
        )
    guard observed == published else {
        throw ProbeError.sourceEvidence(
            "live source differs from staged snapshot"
        )
    }
    return binding
}

private func verifyChildContext(
    arguments: Arguments,
    root: PrimeArtifactRoot,
    seeds: PrimeExecutionSeeds
) throws -> WorkerContext {
    let expected =
        arguments
        .publishedExecutableSHA256!
    try verifyExecutableIdentity(expected)
    let executable = try root.bindExisting(
        at: stagedExecutablePath,
        purpose: .executable,
        maximumByteCount: 256 * 1024 * 1024
    )
    guard executable.sha256 == expected else {
        throw ProbeError
            .executableIdentityMismatch
    }
    let verifiedExecutable =
        try root.verify(executable)
    try PrimeNative3BLoadedExecutableVnode
        .observeCurrentProcess()
        .requireMatches(verifiedExecutable)
    let runtime = try loadRuntimeBinding(
        root: root
    )
    try PrimePinnedMLXMetallib
        .reverifySibling(
            of: runningExecutableURL(),
            matches: runtime,
            runtimeRole:
                .native3BMetalContinuationProbe
        )
    try verifySeedProvenance(
        seeds,
        root: root
    )
    return WorkerContext(
        executable: executable,
        runtime: runtime,
        sourceSnapshot:
            try bindSourceSnapshot(
                sourceRoot:
                    arguments.sourceRoot!,
                root: root
            ),
        priorEvidence:
            try bindPriorEvidence(root: root),
        dependencyEvidence:
            try bindDependencyEvidence(
                sourceRoot:
                    arguments.sourceRoot!,
                root: root
            )
    )
}

private func makeModel(
    profile: PrimeNativeModelProfile,
    initializationSeed: UInt64
) -> LlamaModel {
    MLXRandom.seed(initializationSeed)
    let configuration = LlamaConfiguration(
        hiddenSize: profile.modelDimension,
        hiddenLayers: profile.layerCount,
        intermediateSize: profile.feedForwardDimension,
        attentionHeads: profile.attentionHeads,
        headDimensions: profile.headDimension,
        rmsNormEps: 1e-5,
        vocabularySize: profile.vocabularySize,
        kvHeads: profile.keyValueHeads,
        maxPositionEmbeddings:
            profile.maximumSequenceLength,
        ropeTheta: Float(profile.ropeBase),
        tieWordEmbeddings: true,
        attentionBias: false,
        mlpBias: false
    )
    let model = LlamaModel(configuration)
    eval(model)
    return model
}

private func makeOptimizer() -> AdamW {
    let configuration =
        PrimeTypedOptimizerConfiguration
            .frozenAdamW
    return AdamW(
        learningRate:
            configuration.learningRate,
        betas: (
            configuration.beta1,
            configuration.beta2
        ),
        eps: configuration.epsilon,
        weightDecay:
            configuration.weightDecay
    )
}

private func causalLoss(
    model: LlamaModel,
    inputs: MLXArray
) -> MLXArray {
    let length = inputs.shape[1]
    let logits = model(inputs, cache: nil)
    let shifted =
        logits[0..., 0 ..< (length - 1), 0...]
    let targets = inputs[0..., 1 ..< length]
    return crossEntropy(
        logits: shifted,
        targets: targets,
        reduction: .mean
    )
}

private func deterministicRandomInputs(
    seed: UInt64,
    count: Int
) -> [MLXArray] {
    let root = MLXRandom.key(seed)
    return MLXRandom.split(
        key: root,
        into: count
    ).map {
        MLXRandom.randInt(
            Int32(256) ..< Int32(512),
            [1, 128],
            key: $0
        )
    }
}

private func inputSHA256(
    _ input: MLXArray
) -> String {
    eval(input)
    return PrimeSHA256.hexDigest(
        of: input.asData(access: .copy).data
    )
}

private func isolatedParameters(
    _ parameters: ModuleParameters
) -> ModuleParameters {
    let isolated = parameters.mapValues {
        $0.reshaped($0.shape)
    }
    eval(isolated)
    return isolated
}

private func parameterNorm(
    _ parameters: ModuleParameters
) throws -> MLXArray {
    let components =
        parameters.flattened().map {
            $0.1.asType(.float32)
                .square().sum()
        }
    guard var total = components.first else {
        throw ProbeError.mechanics(
            "empty parameter tree"
        )
    }
    for component in components.dropFirst() {
        total = total + component
    }
    return total.sqrt()
}

private func tensorCatalog(
    label: String,
    pairs: [(String, MLXArray)]
) throws -> PrimeNative3BContinuationTensorCatalog {
    let sorted = pairs.sorted {
        $0.0 < $1.0
    }
    guard !sorted.isEmpty,
          Set(sorted.map(\.0)).count
            == sorted.count else {
        throw ProbeError.mechanics(
            "empty or duplicate tensor paths for \(label)"
        )
    }
    let finiteFlags = sorted.map {
        MLX.all(MLX.isFinite($0.1))
    }
    let nonzeroFlags = sorted.map {
        notEqual(
            $0.1,
            MLXArray(0)
        ).any()
    }
    eval(finiteFlags + nonzeroFlags)

    var entries =
        [PrimeNative3BContinuationTensorEntry]()
    entries.reserveCapacity(sorted.count)
    for index in sorted.indices {
        let (path, array) = sorted[index]
        let data =
            array.asData(access: .copy).data
        entries.append(
            PrimeNative3BContinuationTensorEntry(
                path: path,
                shape: array.shape,
                dtype:
                    String(
                        describing: array.dtype
                    ),
                byteCount: UInt64(data.count),
                sha256:
                    PrimeSHA256.hexDigest(of: data),
                finite:
                    finiteFlags[index]
                    .item(Bool.self),
                nonzero:
                    nonzeroFlags[index]
                    .item(Bool.self)
            )
        )
    }
    let catalog =
        try PrimeNative3BContinuationTensorCatalog(
            label: label,
            entries: entries
        )
    try catalog.validate(
        expectedLabel: label
    )
    return catalog
}

private func parameterCatalog(
    label: String,
    parameters: ModuleParameters
) throws -> PrimeNative3BContinuationTensorCatalog {
    try tensorCatalog(
        label: label,
        pairs: parameters.flattened()
    )
}

private func initialModelCatalog(
    model: LlamaModel
) throws -> PrimeNative3BContinuationTensorCatalog {
    try parameterCatalog(
        label:
            PrimeNative3BContinuationCatalogLabel
                .initialModel,
        parameters:
            isolatedParameters(
                model.parameters()
            )
    )
}

private func poisonModelCatalog(
    model: LlamaModel
) throws -> PrimeNative3BContinuationTensorCatalog {
    try parameterCatalog(
        label:
            PrimeNative3BContinuationCatalogLabel
                .poisonModel,
        parameters:
            isolatedParameters(
                model.parameters()
            )
    )
}

private func fixedLogitsCatalog(
    model: LlamaModel,
    evaluationInput: MLXArray
) throws -> PrimeNative3BContinuationTensorCatalog {
    model.train(false)
    let logits = model(
        evaluationInput,
        cache: nil
    )
    eval(logits)
    return try tensorCatalog(
        label:
            PrimeNative3BContinuationCatalogLabel
                .fixedLogits,
        pairs: [("logits", logits)]
    )
}

private func runOptimizerStep(
    step: Int,
    model: LlamaModel,
    optimizer: AdamW,
    input: MLXArray,
    nextInput: MLXArray,
    evaluationInput: MLXArray
) throws -> PrimeNative3BContinuationStepWitness {
    let lossAndGradient = valueAndGrad(
        model: model
    ) { model, arrays in
        [
            causalLoss(
                model: model,
                inputs: arrays[0]
            ),
        ]
    }
    model.train()
    let (values, gradients) =
        lossAndGradient(model, [input])
    eval(values, gradients)
    guard let loss = values.first else {
        throw ProbeError.mechanics(
            "missing step loss"
        )
    }
    let lossValue = loss.item(Float.self)
    guard lossValue.isFinite else {
        throw ProbeError.mechanics(
            "nonfinite step loss"
        )
    }
    let (clipped, rawGradientNorm) =
        clipGradNorm(
            gradients: gradients,
            maxNorm: 1
        )
    let clippedGradientNorm =
        try parameterNorm(clipped)
    eval(
        clipped,
        rawGradientNorm,
        clippedGradientNorm
    )
    let rawNormValue =
        rawGradientNorm.item(Float.self)
    let clippedNormValue =
        clippedGradientNorm.item(Float.self)
    guard rawNormValue.isFinite,
          clippedNormValue.isFinite else {
        throw ProbeError.mechanics(
            "nonfinite gradient norm"
        )
    }

    let clippedSnapshot =
        isolatedParameters(clipped)
    optimizer.update(
        model: model,
        gradients: clipped
    )
    eval(model, optimizer)
    let modelSnapshot =
        isolatedParameters(
            model.parameters()
        )
    let state: AdamOptimizerState =
        try optimizer.parameters()
    let witness =
        PrimeNative3BContinuationStepWitness(
            step: step,
            inputSHA256: inputSHA256(input),
            lossBitPattern:
                lossValue.bitPattern,
            rawGradientNormBitPattern:
                rawNormValue.bitPattern,
            clippedGradientNormBitPattern:
                clippedNormValue.bitPattern,
            clippedGradient:
                try parameterCatalog(
                    label:
                        PrimeNative3BContinuationCatalogLabel
                        .clippedGradient,
                    parameters: clippedSnapshot
                ),
            model: try parameterCatalog(
                label:
                    PrimeNative3BContinuationCatalogLabel
                        .model,
                parameters: modelSnapshot
            ),
            firstMoment:
                try parameterCatalog(
                    label:
                        PrimeNative3BContinuationCatalogLabel
                        .firstMoment,
                    parameters: state.firstMoment
                ),
            secondMoment:
                try parameterCatalog(
                    label:
                        PrimeNative3BContinuationCatalogLabel
                        .secondMoment,
                    parameters: state.secondMoment
                ),
            fixedLogits:
                try fixedLogitsCatalog(
                    model: model,
                    evaluationInput:
                        evaluationInput
                ),
            cursor: step,
            nextInputSHA256:
                inputSHA256(nextInput)
        )
    try witness.validate()
    return witness
}

private func advanceWithoutWitness(
    model: LlamaModel,
    optimizer: AdamW,
    input: MLXArray
) throws {
    let lossAndGradient = valueAndGrad(
        model: model
    ) { model, arrays in
        [
            causalLoss(
                model: model,
                inputs: arrays[0]
            ),
        ]
    }
    model.train()
    let (values, gradients) =
        lossAndGradient(model, [input])
    eval(values, gradients)
    let (clipped, _) = clipGradNorm(
        gradients: gradients,
        maxNorm: 1
    )
    optimizer.update(
        model: model,
        gradients: clipped
    )
    eval(model, optimizer)
    guard values[0]
        .item(Float.self).isFinite else {
        throw ProbeError.mechanics(
            "poison trajectory loss is nonfinite"
        )
    }
}

private func uniqueArrays(
    _ parameters: ModuleParameters
) throws -> [String: MLXArray] {
    var arrays = [String: MLXArray]()
    for (path, array) in parameters.flattened() {
        guard arrays.updateValue(
            array,
            forKey: path
        ) == nil else {
            throw ProbeError.checkpoint(
                "duplicate tensor path \(path)"
            )
        }
    }
    guard !arrays.isEmpty else {
        throw ProbeError.checkpoint(
            "empty checkpoint component"
        )
    }
    return arrays
}

private func checkpointMetadata(
    kind: String,
    catalog:
        PrimeNative3BContinuationTensorCatalog
) throws -> [String: String] {
    [
        "artifact_kind": kind,
        "schema_version": "1",
        "profile_id":
            PrimeNativeProfiles.exact3B
                .profileID,
        "step": "1",
        "catalog_sha256":
            catalog.aggregateSHA256,
        "optimizer_configuration_sha256":
            PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(
                    PrimeTypedOptimizerConfiguration
                        .frozenAdamW
                )
            ),
        "seeds_sha256":
            PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(
                    PrimeExecutionSeeds
                        .initialFactorizedCalibrationTriple()
                )
            ),
    ]
}

private func publishCheckpointComponent(
    parameters: ModuleParameters,
    catalog:
        PrimeNative3BContinuationTensorCatalog,
    kind: String,
    path: String,
    root: PrimeArtifactRoot
) throws -> PrimeArtifactBinding {
    let arrays = try uniqueArrays(parameters)
    let metadata = try checkpointMetadata(
        kind: kind,
        catalog: catalog
    )
    return try root.publishGeneratedFile(
        at: path,
        purpose: .immutableData,
        maximumByteCount:
            PrimeNative3BMetalContinuationContract
            .checkpointComponentMaximumByteCount
    ) { descriptor in
        try MLX.save(
            arrays: arrays,
            metadata: metadata,
            fileDescriptor: descriptor,
            maximumBytes:
                PrimeNative3BMetalContinuationContract
                .checkpointComponentMaximumByteCount
        )
    }
}

private func loadCheckpointComponent(
    binding: PrimeArtifactBinding,
    expectedCatalog:
        PrimeNative3BContinuationTensorCatalog,
    kind: String,
    root: PrimeArtifactRoot
) throws -> ModuleParameters {
    guard binding.byteCount
            <= PrimeNative3BMetalContinuationContract
                .checkpointComponentMaximumByteCount
    else {
        throw ProbeError.checkpoint(
            "\(kind) exceeds checkpoint component cap"
        )
    }
    let loaded = try root
        .withVerifiedArtifactDescriptor(
            binding,
            load: { descriptor in
                // MLX 0.31.3 does not implement descriptor-backed Load on
                // Metal. Materialize and verify the immutable checkpoint on
                // the maintained CPU load path; the restored model and AdamW
                // continuation still execute under the GPU default device.
                try MLX.loadArraysAndMetadata(
                    fileDescriptor: descriptor,
                    stream: .cpu
                )
            },
            materialize: { loaded in
                eval(Array(loaded.0.values))
                return loaded
            }
        )
    let expectedMetadata = try checkpointMetadata(
        kind: kind,
        catalog: expectedCatalog
    )
    guard loaded.1 == expectedMetadata else {
        throw ProbeError.checkpoint(
            "\(kind) metadata mismatch"
        )
    }
    let parameters =
        ModuleParameters.unflattened(
            loaded.0
        )
    let observed = try parameterCatalog(
        label: expectedCatalog.label,
        parameters: parameters
    )
    let comparison =
        PrimeNative3BContinuationReconciler
            .compare(
                expected: expectedCatalog,
                observed: observed
            )
    guard comparison.exact else {
        throw ProbeError.checkpoint(
            "\(kind) logical mismatch \(comparison.firstMismatch ?? "unknown")"
        )
    }
    return parameters
}

private func restoreCheckpoint(
    manifest:
        PrimeNative3BContinuationCheckpointManifest,
    model: LlamaModel,
    root: PrimeArtifactRoot
) throws -> AdamW {
    let modelParameters =
        try loadCheckpointComponent(
            binding: manifest.model,
            expectedCatalog:
                manifest.stepOneWitness.model,
            kind:
                "prime_native_3b_model_after_step_1",
            root: root
        )
    let firstMoment =
        try loadCheckpointComponent(
            binding: manifest.firstMoment,
            expectedCatalog:
                manifest.stepOneWitness
                .firstMoment,
            kind:
                "prime_native_3b_adam_first_moment_after_step_1",
            root: root
        )
    let secondMoment =
        try loadCheckpointComponent(
            binding: manifest.secondMoment,
            expectedCatalog:
                manifest.stepOneWitness
                .secondMoment,
            kind:
                "prime_native_3b_adam_second_moment_after_step_1",
            root: root
        )
    try model.update(
        parameters: modelParameters,
        verify: .all
    )
    eval(model)
    let optimizer = makeOptimizer()
    try optimizer.update(
        parameters: AdamOptimizerState(
            firstMoment: firstMoment,
            secondMoment: secondMoment
        ),
        matching:
            model.trainableParameters()
    )
    let restoredState:
        AdamOptimizerState =
        try optimizer.parameters()
    eval(
        model,
        restoredState.firstMoment,
        restoredState.secondMoment
    )
    return optimizer
}

private func restoredStateWitness(
    checkpoint:
        PrimeNative3BContinuationCheckpointManifest,
    model: LlamaModel,
    optimizer: AdamW,
    evaluationInput: MLXArray
) throws
    -> PrimeNative3BContinuationRestoredStateWitness
{
    let source = checkpoint.stepOneWitness
    let state: AdamOptimizerState =
        try optimizer.parameters()
    let witness =
        PrimeNative3BContinuationRestoredStateWitness(
            restoredAfterStep: 1,
            checkpointStepWitnessSHA256:
                PrimeSHA256.hexDigest(
                    of: try PrimeCanonicalJSON.encode(
                        source
                    )
                ),
            carriedForwardInputSHA256:
                source.inputSHA256,
            carriedForwardCursor: source.cursor,
            carriedForwardNextInputSHA256:
                source.nextInputSHA256,
            model: try parameterCatalog(
                label:
                    PrimeNative3BContinuationCatalogLabel
                        .model,
                parameters:
                    isolatedParameters(
                        model.parameters()
                    )
            ),
            firstMoment:
                try parameterCatalog(
                    label:
                        PrimeNative3BContinuationCatalogLabel
                        .firstMoment,
                    parameters: state.firstMoment
                ),
            secondMoment:
                try parameterCatalog(
                    label:
                        PrimeNative3BContinuationCatalogLabel
                        .secondMoment,
                    parameters: state.secondMoment
                ),
            fixedLogits:
                try fixedLogitsCatalog(
                    model: model,
                    evaluationInput:
                        evaluationInput
                )
        )
    try witness.validate()
    return witness
}

private func publishWorkerRecord(
    _ record:
        PrimeNative3BMetalContinuationWorkerRecord,
    at path: String,
    root: PrimeArtifactRoot
) throws -> PrimeArtifactBinding {
    try record.validate()
    let verifiedExecutable =
        try root.verify(record.executable)
    try PrimeNative3BLoadedExecutableVnode
        .observeCurrentProcess()
        .requireMatches(verifiedExecutable)
    let binding = try root.publishCanonical(
        record,
        at: path
    )
    let replayed = try root.decodeVerified(
        PrimeNative3BMetalContinuationWorkerRecord
            .self,
        binding: binding
    )
    guard replayed == record else {
        throw ProbeError.workerRecord(
            "record round trip"
        )
    }
    try replayed.validate()
    return binding
}

private func workerInputs(
    seeds: PrimeExecutionSeeds
) throws -> (
    training: [MLXArray],
    evaluation: MLXArray
) {
    let training = try (0 ..< 3).map {
        let tokens =
            try PrimeNative3BMetalContinuationContract
            .collisionFreeTrainingTokens(
                seed:
                    seeds.trainingSchedule.value,
                ordinal: $0
            )
        guard Set(tokens).count
                == PrimeNative3BMetalContinuationContract
                    .fixedEvaluationSequenceLength else {
            throw ProbeError.mechanics(
                "training input contains repeated token IDs"
            )
        }
        return MLXArray(
            tokens,
            [
                1,
                PrimeNative3BMetalContinuationContract
                    .fixedEvaluationSequenceLength,
            ]
        )
    }
    return (
        training,
        deterministicRandomInputs(
            seed: seeds.evaluation.value,
            count: 1
        )[0]
    )
}

private func runControl(
    arguments: Arguments,
    root: PrimeArtifactRoot
) throws {
    let seeds =
        try PrimeNative3BMetalContinuationContract
            .frozenSeeds()
    let context = try verifyChildContext(
        arguments: arguments,
        root: root,
        seeds: seeds
    )
    let record = try Device.withDefaultDevice(.gpu) {
        let profile = PrimeNativeProfiles.exact3B
        let model = makeModel(
            profile: profile,
            initializationSeed:
                seeds.initialization.value
        )
        let initial = try initialModelCatalog(
            model: model
        )
        let inputs = try workerInputs(seeds: seeds)
        let optimizer = makeOptimizer()
        let stepOne = try runOptimizerStep(
            step: 1,
            model: model,
            optimizer: optimizer,
            input: inputs.training[0],
            nextInput: inputs.training[1],
            evaluationInput:
                inputs.evaluation
        )
        let stepTwo = try runOptimizerStep(
            step: 2,
            model: model,
            optimizer: optimizer,
            input: inputs.training[1],
            nextInput: inputs.training[2],
            evaluationInput:
                inputs.evaluation
        )
        return PrimeNative3BMetalContinuationWorkerRecord(
            role: .control,
            processIdentifier: getpid(),
            executable: context.executable,
            runtimeImage: context.runtime,
            sourceSnapshot:
                context.sourceSnapshot,
            priorEvidence:
                context.priorEvidence,
            continuationDependencyEvidence:
                context.dependencyEvidence,
            seeds: seeds,
            initialModel: initial,
            witnesses: [stepOne, stepTwo]
        )
    }
    _ = try publishWorkerRecord(
        record,
        at: controlRecordPath,
        root: root
    )
}

private func readWriterAdmission() throws -> Bool {
    var descriptor = pollfd(
        fd: STDIN_FILENO,
        events: Int16(POLLIN | POLLHUP),
        revents: 0
    )
    while true {
        let result = poll(
            &descriptor,
            1,
            Int32(childWallLimitSeconds * 1_000)
        )
        if result < 0, errno == EINTR {
            continue
        }
        guard result > 0 else {
            throw ProbeError.workerRecord(
                "writer admission was not received"
            )
        }
        var value: UInt8 = 0
        let count = withUnsafeMutableBytes(
            of: &value
        ) {
            read(
                STDIN_FILENO,
                $0.baseAddress,
                1
            )
        }
        if count < 0, errno == EINTR {
            continue
        }
        guard count == 1,
              value == 0 || value == 1
        else {
            throw ProbeError.workerRecord(
                "writer admission was malformed"
            )
        }
        return value == 1
    }
}

private func runWriter(
    arguments: Arguments,
    root: PrimeArtifactRoot
) throws {
    let seeds =
        try PrimeNative3BMetalContinuationContract
            .frozenSeeds()
    let context = try verifyChildContext(
        arguments: arguments,
        root: root,
        seeds: seeds
    )
    try Device.withDefaultDevice(.gpu) {
        let model = makeModel(
            profile:
                PrimeNativeProfiles.exact3B,
            initializationSeed:
                seeds.initialization.value
        )
        let initial = try initialModelCatalog(
            model: model
        )
        let inputs = try workerInputs(seeds: seeds)
        let optimizer = makeOptimizer()
        let stepOne = try runOptimizerStep(
            step: 1,
            model: model,
            optimizer: optimizer,
            input: inputs.training[0],
            nextInput: inputs.training[1],
            evaluationInput:
                inputs.evaluation
        )
        let preliminary =
            PrimeNative3BMetalContinuationWorkerRecord(
                role: .writer,
                processIdentifier: getpid(),
                executable: context.executable,
                runtimeImage: context.runtime,
                sourceSnapshot:
                    context.sourceSnapshot,
                priorEvidence:
                    context.priorEvidence,
                continuationDependencyEvidence:
                    context.dependencyEvidence,
                seeds: seeds,
                initialModel: initial,
                witnesses: [stepOne]
            )
        _ = try publishWorkerRecord(
            preliminary,
            at: writerPreSaveRecordPath,
            root: root
        )
        guard try readWriterAdmission() else {
            return
        }

        let state: AdamOptimizerState =
            try optimizer.parameters()
        let modelBinding =
            try publishCheckpointComponent(
                parameters:
                    model.parameters(),
                catalog: stepOne.model,
                kind:
                    "prime_native_3b_model_after_step_1",
                path: modelCheckpointPath,
                root: root
            )
        let firstMomentBinding =
            try publishCheckpointComponent(
                parameters: state.firstMoment,
                catalog: stepOne.firstMoment,
                kind:
                    "prime_native_3b_adam_first_moment_after_step_1",
                path:
                    firstMomentCheckpointPath,
                root: root
            )
        let secondMomentBinding =
            try publishCheckpointComponent(
                parameters:
                    state.secondMoment,
                catalog: stepOne.secondMoment,
                kind:
                    "prime_native_3b_adam_second_moment_after_step_1",
                path:
                    secondMomentCheckpointPath,
                root: root
            )
        let checkpointManifest =
            PrimeNative3BContinuationCheckpointManifest(
                seeds: seeds,
                model: modelBinding,
                firstMoment:
                    firstMomentBinding,
                secondMoment:
                    secondMomentBinding,
                stepOneWitness: stepOne
            )
        try checkpointManifest.validate()
        _ = try root.publishCanonical(
            checkpointManifest,
            at: checkpointManifestPath
        )
        let writerRecord =
            PrimeNative3BMetalContinuationWorkerRecord(
                role: .writer,
                processIdentifier: getpid(),
                executable: context.executable,
                runtimeImage: context.runtime,
                sourceSnapshot:
                    context.sourceSnapshot,
                priorEvidence:
                    context.priorEvidence,
                continuationDependencyEvidence:
                    context.dependencyEvidence,
                seeds: seeds,
                initialModel: initial,
                checkpointManifest:
                    checkpointManifest,
                witnesses: [stepOne]
            )
        _ = try publishWorkerRecord(
            writerRecord,
            at: writerRecordPath,
            root: root
        )
    }
}

private func runRestorer(
    arguments: Arguments,
    root: PrimeArtifactRoot
) throws {
    let seeds =
        try PrimeNative3BMetalContinuationContract
            .frozenSeeds()
    let context = try verifyChildContext(
        arguments: arguments,
        root: root,
        seeds: seeds
    )
    let writerBinding = try root.bindExisting(
        at: writerRecordPath,
        purpose: .immutableData
    )
    let writer = try root.decodeVerified(
        PrimeNative3BMetalContinuationWorkerRecord
            .self,
        binding: writerBinding
    )
    try writer.validate()
    guard writer.role == .writer,
          let writerCheckpoint =
            writer.checkpointManifest else {
        throw ProbeError.workerRecord(
            "restorer requires writer checkpoint"
        )
    }
    let manifestBinding =
        try root.bindExisting(
            at: checkpointManifestPath,
            purpose: .immutableData
        )
    let manifest = try root.decodeVerified(
        PrimeNative3BContinuationCheckpointManifest
            .self,
        binding: manifestBinding
    )
    try manifest.validate()
    guard manifest == writerCheckpoint else {
        throw ProbeError.checkpoint(
            "manifest differs from writer"
        )
    }

    let record = try Device.withDefaultDevice(.gpu) {
        let model = makeModel(
            profile:
                PrimeNativeProfiles.exact3B,
            initializationSeed:
                seeds.initialization.value
        )
        let initial = try initialModelCatalog(
            model: model
        )
        let inputs = try workerInputs(seeds: seeds)
        let poisonOptimizer = makeOptimizer()
        try advanceWithoutWitness(
            model: model,
            optimizer: poisonOptimizer,
            input: inputs.training[0]
        )
        try advanceWithoutWitness(
            model: model,
            optimizer: poisonOptimizer,
            input: inputs.training[1]
        )
        let poison = try poisonModelCatalog(
            model: model
        )
        _ = consume poisonOptimizer
        Memory.clearCache()
        let optimizer = try restoreCheckpoint(
            manifest: manifest,
            model: model,
            root: root
        )
        let restoredAtOne =
            try restoredStateWitness(
                checkpoint: manifest,
                model: model,
                optimizer: optimizer,
                evaluationInput:
                    inputs.evaluation
            )
        let continuedAtTwo =
            try runOptimizerStep(
                step: 2,
                model: model,
                optimizer: optimizer,
                input: inputs.training[1],
                nextInput:
                    inputs.training[2],
                evaluationInput:
                    inputs.evaluation
            )
        return PrimeNative3BMetalContinuationWorkerRecord(
            role: .restorer,
            processIdentifier: getpid(),
            executable: context.executable,
            runtimeImage: context.runtime,
            sourceSnapshot:
                context.sourceSnapshot,
            priorEvidence:
                context.priorEvidence,
            continuationDependencyEvidence:
                context.dependencyEvidence,
            seeds: seeds,
            initialModel: initial,
            poisonModel: poison,
            checkpointManifest: manifest,
            writerRecord: writerBinding,
            restoredStateWitness:
                restoredAtOne,
            witnesses: [continuedAtTwo]
        )
    }
    _ = try publishWorkerRecord(
        record,
        at: restorerRecordPath,
        root: root
    )
}

private func combinedOutput(
    standardOutput: BoundedOutput,
    standardError: BoundedOutput
) -> BoundedOutput {
    let (byteCount, overflow) =
        standardOutput.byteCount
        .addingReportingOverflow(
            standardError.byteCount
        )
    let material = [
        String(standardOutput.byteCount),
        standardOutput.sha256,
        String(standardError.byteCount),
        standardError.sha256,
    ].joined(separator: "|")
    return BoundedOutput(
        byteCount:
            overflow ? UInt64.max : byteCount,
        sha256:
            PrimeSHA256.hexDigest(
                of: Data(material.utf8)
            ),
        overflowed:
            standardOutput.overflowed
            || standardError.overflowed,
        drainCompleted:
            standardOutput.drainCompleted
            && standardError.drainCompleted
    )
}

/// Cleanup guard for every error after `Process.run()` succeeds.
///
/// Closing the admission channel first lets a cooperative writer fail closed.
/// Signal escalation then handles every remaining role, and `waitUntilExit`
/// explicitly reaps the launched child before the stack unwinds.
private func terminateAndReapLaunchedChild(
    _ process: Process,
    completed: DispatchSemaphore,
    supervisorInput: Pipe,
    outputPipe: Pipe,
    errorPipe: Pipe,
    drains: DispatchGroup
) {
    try? supervisorInput
        .fileHandleForWriting.close()
    try? outputPipe
        .fileHandleForWriting.close()
    try? errorPipe
        .fileHandleForWriting.close()
    if process.isRunning {
        _ = PrimeProcessTermination
            .escalateAfterTimeout(
                processIdentifier:
                    process.processIdentifier,
                graceMilliseconds:
                    terminationGraceMilliseconds,
                waitForTermination: {
                    milliseconds in
                    if !process.isRunning {
                        return true
                    }
                    return completed.wait(
                        timeout:
                            .now()
                            + .milliseconds(
                                milliseconds
                            )
                    ) == .success
                        || !process.isRunning
                }
            )
    }
    if process.isRunning {
        _ = Darwin.kill(
            process.processIdentifier,
            SIGKILL
        )
    }
    process.waitUntilExit()
    if drains.wait(
        timeout: .now() + .seconds(10)
    ) != .success {
        try? outputPipe
            .fileHandleForReading.close()
        try? errorPipe
            .fileHandleForReading.close()
    }
}

private func runChild(
    role: ProbeRole,
    executableURL: URL,
    executableSHA256: String,
    arguments: Arguments,
    root: PrimeArtifactRoot,
    writerAdmission: ((
        PrimeArtifactBinding,
        PrimeNative3BMetalContinuationWorkerRecord
    ) throws -> Bool)? = nil
) throws -> ChildExit {
    let capability =
        Data(
            UUID().uuidString
                .lowercased().utf8
        )
    let capabilitySHA256 =
        PrimeSHA256.hexDigest(of: capability)
    let process = Process()
    process.executableURL = executableURL
    process.arguments = [
        "--artifact-root",
        arguments.artifactRoot!.path,
        "--source-root",
        arguments.sourceRoot!.path,
        "--metal-lease-file",
        arguments.metalLeaseFile!.path,
        "--internal-role",
        role.rawValue,
        "--published-executable-sha256",
        executableSHA256,
        "--internal-worker-capability-sha256",
        capabilitySHA256,
        "--receipt-path",
        arguments.receiptPath,
    ]
    let workerEnvironment = [String: String]()
    _ = try PrimeMLXRuntimeEnvironmentPolicy
        .validate(
            environment: workerEnvironment
        )
    process.environment = workerEnvironment
    let supervisorInput = Pipe()
    process.standardInput = supervisorInput
    let outputPipe = Pipe()
    let errorPipe = Pipe()
    process.standardOutput = outputPipe
    process.standardError = errorPipe
    let standardOutput =
        BoundedPipeCapture(
            maximumByteCount:
                childOutputMaximumBytes
        )
    let standardError =
        BoundedPipeCapture(
            maximumByteCount:
                childOutputMaximumBytes
        )
    let drains = DispatchGroup()
    standardOutput.start(
        reading:
            outputPipe.fileHandleForReading,
        in: drains
    )
    standardError.start(
        reading:
            errorPipe.fileHandleForReading,
        in: drains
    )
    let completed = DispatchSemaphore(value: 0)
    process.terminationHandler = { _ in
        completed.signal()
    }
    do {
        try process.run()
    } catch {
        try? supervisorInput.fileHandleForWriting.close()
        try? outputPipe
            .fileHandleForWriting.close()
        try? errorPipe
            .fileHandleForWriting.close()
        _ = drains.wait(
            timeout:
                .now() + .seconds(5)
        )
        throw error
    }
    var returnedChildExit = false
    defer {
        if !returnedChildExit {
            terminateAndReapLaunchedChild(
                process,
                completed: completed,
                supervisorInput: supervisorInput,
                outputPipe: outputPipe,
                errorPipe: errorPipe,
                drains: drains
            )
        }
    }
    supervisorInput.fileHandleForWriting.write(
        capability
    )
    try? outputPipe
        .fileHandleForWriting.close()
    try? errorPipe
        .fileHandleForWriting.close()

    let deadline =
        DispatchTime.now()
        + .seconds(childWallLimitSeconds)
    var terminationConsumed = false
    var admittedWriter = false
    if role == .writer {
        guard let writerAdmission else {
            throw ProbeError.workerRecord(
                "writer admission callback is absent"
            )
        }
        var preliminaryBinding:
            PrimeArtifactBinding?
        while preliminaryBinding == nil {
            do {
                preliminaryBinding =
                    try root.bindExisting(
                    at:
                        writerPreSaveRecordPath,
                    purpose: .immutableData
                )
                break
            } catch let error as
                PrimeDurableArtifactError
            {
                guard case let .posix(
                    _,
                    path,
                    code
                ) = error,
                    path
                        == writerPreSaveRecordPath,
                    code == ENOENT
                else {
                    throw error
                }
            }
            if completed.wait(
                timeout:
                    .now()
                    + .milliseconds(50)
            ) == .success
            {
                terminationConsumed = true
                break
            }
            guard DispatchTime.now() < deadline
            else {
                break
            }
        }
        if let preliminaryBinding {
            let preliminary =
                try root.decodeVerified(
                    PrimeNative3BMetalContinuationWorkerRecord
                        .self,
                    binding:
                        preliminaryBinding
                )
            try preliminary.validate()
            admittedWriter =
                try writerAdmission(
                    preliminaryBinding,
                    preliminary
                )
            supervisorInput.fileHandleForWriting.write(
                Data([
                    admittedWriter ? 1 : 0,
                ])
            )
        }
    }
    try? supervisorInput.fileHandleForWriting.close()

    var timedOut = false
    if !terminationConsumed {
        timedOut =
            completed.wait(timeout: deadline)
            == .timedOut
    }
    if timedOut {
        let escalation =
            PrimeProcessTermination
                .escalateAfterTimeout(
                    processIdentifier:
                        process.processIdentifier,
                    graceMilliseconds:
                        terminationGraceMilliseconds,
                    waitForTermination: {
                        milliseconds in
                        completed.wait(
                            timeout:
                                .now()
                                + .milliseconds(
                                    milliseconds
                                )
                        ) == .success
                    }
                )
        guard escalation
                .terminationObserved else {
            throw ProbeError
                .childTerminationUnobserved(
                    role: role.rawValue,
                    detail:
                        escalation.auditDetail
                )
        }
    }
    process.waitUntilExit()
    guard drains.wait(
        timeout: .now() + .seconds(10)
    ) == .success else {
        try? outputPipe
            .fileHandleForReading.close()
        try? errorPipe
            .fileHandleForReading.close()
        throw ProbeError
            .childOutputDrainIncomplete(
                role.rawValue
            )
    }
    let output = combinedOutput(
        standardOutput:
            standardOutput.snapshot(),
        standardError:
            standardError.snapshot()
    )
    if timedOut {
        throw ProbeError.childTimedOut(
            role.rawValue
        )
    }
    guard process.terminationReason == .exit,
          process.terminationStatus == 0,
          !output.overflowed,
          output.drainCompleted else {
        throw ProbeError.childFailed(
            role: role.rawValue,
            status:
                process.terminationStatus,
            outputByteCount:
                output.byteCount,
            outputSHA256: output.sha256,
            overflowed: output.overflowed
        )
    }
    let recordPath: String
    switch role {
    case .control:
        recordPath = controlRecordPath
    case .writer:
        recordPath =
            admittedWriter
            ? writerRecordPath
            : writerPreSaveRecordPath
    case .restorer:
        recordPath = restorerRecordPath
    case .parent:
        throw ProbeError.workerRecord(
            "parent cannot be a child"
        )
    }
    let childExit = ChildExit(
        role: role,
        processIdentifier:
            process.processIdentifier,
        terminationReason:
            process.terminationReason,
        terminationStatus:
            process.terminationStatus,
        output: output,
        record:
            try root.bindExisting(
                at: recordPath,
                purpose: .immutableData
            )
    )
    returnedChildExit = true
    return childExit
}

private func publishReceipt(
    _ receipt:
        PrimeNative3BMetalContinuationReceipt,
    arguments: Arguments,
    root: PrimeArtifactRoot
) throws -> PrimeArtifactBinding {
    try receipt.validate(in: root)
    let binding = try root.publishCanonical(
        receipt,
        at: arguments.receiptPath
    )
    let replayed = try root.decodeVerified(
        PrimeNative3BMetalContinuationReceipt
            .self,
        binding: binding
    )
    guard replayed == receipt else {
        throw ProbeError
            .receiptRoundTripMismatch
    }
    try replayed.validate(in: root)
    return binding
}

private func reverifyFinalInputs(
    arguments: Arguments,
    root: PrimeArtifactRoot,
    initialDependency:
        VerifiedDependencySource,
    initialSource:
        PrimeSwiftSourceSnapshot,
    runtime: PrimePinnedMLXMetallibBinding,
    executableURL: URL,
    parentExecutableSHA256: String
) throws {
    try verifyExecutableIdentity(
        parentExecutableSHA256
    )
    let finalDependency =
        try verifyDependency(
            sourceRoot:
                arguments.sourceRoot!
        )
    guard finalDependency.dependencyTree
            == initialDependency.dependencyTree,
          finalDependency.packageManifest
            == initialDependency.packageManifest,
          finalDependency.packageResolution
            == initialDependency.packageResolution,
          finalDependency.mirrorConfiguration
            == initialDependency.mirrorConfiguration
    else {
        throw ProbeError.dependencyEvidence(
            "dependency changed during execution"
        )
    }
    let finalSource =
        try PrimeSwiftSourceProvenance.capture(
            at: arguments.sourceRoot!,
            requiredRelativePaths:
                PrimeNative3BMetalContinuationContract
                .requiredPrimeSourceRelativePaths
        )
    guard finalSource == initialSource else {
        throw ProbeError.sourceEvidence(
            "Prime source changed during execution"
        )
    }
    try PrimePinnedMLXMetallib
        .reverifySibling(
            of: runningExecutableURL(),
            matches: runtime,
            runtimeRole:
                .native3BMetalContinuationProbe
        )
    try PrimePinnedMLXMetallib
        .reverifyStagedRuntimeImage(
            of: executableURL,
            matches: runtime,
            runtimeRole:
                .native3BMetalContinuationProbe
        )
}

private func runParent(
    arguments: Arguments,
    root: PrimeArtifactRoot
) throws {
    do {
        try root.requireEmpty()
    } catch {
        throw ProbeError
            .artifactRootAdmissionFailed
    }
    let supervisorLease =
        try PrimeExclusiveProcessLease.acquire(
            at:
                arguments.artifactRoot!
                .appendingPathComponent(
                    supervisorAuthorityLeaseName
                )
        )
    defer { supervisorLease.release() }
    let metalLease =
        try PrimeMetalDeviceLease.acquire(
            at: arguments.metalLeaseFile!
        )
    defer { metalLease.release() }

    let seeds =
        try PrimeNative3BMetalContinuationContract
            .frozenSeeds()
    let initialDependency =
        try verifyDependency(
            sourceRoot:
                arguments.sourceRoot!
        )
    try root.ensurePrivateDirectory(
        at: stagedDirectory
    )
    let runtime =
        try PrimePinnedMLXMetallib
            .captureSibling(
                of: runningExecutableURL(),
                into: root,
                runtimeRole:
                    .native3BMetalContinuationProbe
            )
    let executable = try publishStagedExecutable(
        try runningExecutableData(),
        root: root
    )
    _ = try root.publishCanonical(
        runtime,
        at: runtimeBindingPath
    )
    _ = try publishDependencyEvidence(
        sourceRoot: arguments.sourceRoot!,
        root: root
    )
    _ = try publishPriorEvidence(
        sourceRoot: arguments.sourceRoot!,
        root: root
    )
    try publishSeedProvenance(
        sourceRoot: arguments.sourceRoot!,
        seeds: seeds,
        root: root
    )
    let initialSource =
        try PrimeSwiftSourceProvenance.capture(
            at: arguments.sourceRoot!,
            requiredRelativePaths:
                PrimeNative3BMetalContinuationContract
                .requiredPrimeSourceRelativePaths
        )
    let sourceBinding =
        try root.publishCanonical(
            initialSource,
            at: sourceSnapshotPath
        )
    _ = sourceBinding
    let executableURL =
        arguments.artifactRoot!
        .appendingPathComponent(
            executable.relativePath
        )

    let controlExit = try runChild(
        role: .control,
        executableURL: executableURL,
        executableSHA256: executable.sha256,
        arguments: arguments,
        root: root
    )
    let control = try root.decodeVerified(
        PrimeNative3BMetalContinuationWorkerRecord
            .self,
        binding: controlExit.record
    )
    let controlProcess = try supervisorObservation(
        exit: controlExit,
        worker: control
    )
    var preliminaryComparison:
        PrimeNative3BContinuationComparisonResult?
    let writerExit = try runChild(
        role: .writer,
        executableURL: executableURL,
        executableSHA256: executable.sha256,
        arguments: arguments,
        root: root,
        writerAdmission: {
            _, preliminary in
            guard let controlN =
                    control.witness(at: 1),
                  let writerN =
                    preliminary.witness(at: 1)
            else {
                throw ProbeError.workerRecord(
                    "pre-save witness is absent"
                )
            }
            let comparison =
                PrimeNative3BContinuationReconciler
                .compare(
                    expected: controlN,
                    observed: writerN
                )
            preliminaryComparison = comparison
            return comparison.exact
        }
    )
    let writer = try root.decodeVerified(
        PrimeNative3BMetalContinuationWorkerRecord
            .self,
        binding: writerExit.record
    )
    let writerProcess = try supervisorObservation(
        exit: writerExit,
        worker: writer
    )
    guard let controlN =
            control.witness(at: 1),
          let writerN =
            writer.witness(at: 1)
    else {
        throw ProbeError.workerRecord(
            "step-1 witness is absent"
        )
    }
    let preSaveComparison =
        PrimeNative3BContinuationReconciler
            .compare(
                expected: controlN,
                observed: writerN
            )
    guard preSaveComparison
            == preliminaryComparison else {
        throw ProbeError.workerRecord(
            "writer changed after pre-save admission"
        )
    }

    if !preSaveComparison.exact {
        let restoredAtNComparison:
            PrimeObservation<
                PrimeNative3BContinuationComparisonResult
            > = .unavailable
        let continuedAtNPlus1Comparison:
            PrimeObservation<
                PrimeNative3BContinuationComparisonResult
            > = .unavailable
        let receipt =
            PrimeNative3BMetalContinuationReceipt(
                outcome: .abstain,
                recordedAtUTC:
                    ISO8601DateFormatter()
                    .string(from: Date()),
                seeds: seeds,
                controlRecord:
                    controlExit.record,
                writerRecord:
                    writerExit.record,
                restorerRecord: .unavailable,
                workers: [control, writer],
                supervisorProcesses: [
                    controlProcess,
                    writerProcess,
                ],
                preSaveComparison:
                    .observed(
                        preSaveComparison
                    ),
                restoredAtNComparison:
                    restoredAtNComparison,
                continuedAtNPlus1Comparison:
                    continuedAtNPlus1Comparison
            )
        try reverifyFinalInputs(
            arguments: arguments,
            root: root,
            initialDependency:
                initialDependency,
            initialSource: initialSource,
            runtime: runtime,
            executableURL: executableURL,
            parentExecutableSHA256:
                executable.sha256
        )
        try receipt.validate(in: root)
        let binding = try root.publishCanonical(
            receipt,
            at: arguments.receiptPath
        )
        let replayed = try root.decodeVerified(
            PrimeNative3BMetalContinuationReceipt
                .self,
            binding: binding
        )
        guard replayed == receipt else {
            throw ProbeError
                .receiptRoundTripMismatch
        }
        try replayed.validate(in: root)
        print(
            "ABSTAIN receipt_sha256=\(binding.sha256)"
        )
        return
    }

    let restorerExit = try runChild(
        role: .restorer,
        executableURL: executableURL,
        executableSHA256: executable.sha256,
        arguments: arguments,
        root: root
    )
    let restorer = try root.decodeVerified(
        PrimeNative3BMetalContinuationWorkerRecord
            .self,
        binding: restorerExit.record
    )
    let restorerProcess =
        try supervisorObservation(
            exit: restorerExit,
            worker: restorer
        )
    guard let restoredN =
            restorer.restoredStateWitness,
          let restoredNPlusOne =
            restorer.witness(at: 2),
          let controlNPlusOne =
            control.witness(at: 2),
          let checkpoint =
            writer.checkpointManifest else {
        throw ProbeError.workerRecord(
            "restored witness or checkpoint is absent"
        )
    }
    let restoredAtNComparison =
        PrimeNative3BContinuationReconciler
            .compareRestoredState(
                expected:
                    checkpoint.stepOneWitness,
                observed: restoredN
            )
    let continuedAtNPlus1Comparison =
        PrimeNative3BContinuationReconciler
            .compare(
                expected: controlNPlusOne,
                observed:
                    restoredNPlusOne
            )
    let outcome:
        PrimeNative3BMetalContinuationOutcome =
        restoredAtNComparison.exact
            && continuedAtNPlus1Comparison.exact
        ? .pass
        : .abstain
    let receipt =
        PrimeNative3BMetalContinuationReceipt(
            outcome: outcome,
            recordedAtUTC:
                ISO8601DateFormatter()
                .string(from: Date()),
            seeds: seeds,
            controlRecord: controlExit.record,
            writerRecord: writerExit.record,
            restorerRecord:
                .observed(
                    restorerExit.record
                ),
            workers: [
                control,
                writer,
                restorer,
            ],
            supervisorProcesses: [
                controlProcess,
                writerProcess,
                restorerProcess,
            ],
            preSaveComparison:
                .observed(
                    preSaveComparison
                ),
            restoredAtNComparison:
                .observed(
                    restoredAtNComparison
                ),
            continuedAtNPlus1Comparison:
                .observed(
                    continuedAtNPlus1Comparison
                )
        )
    try reverifyFinalInputs(
        arguments: arguments,
        root: root,
        initialDependency:
            initialDependency,
        initialSource: initialSource,
        runtime: runtime,
        executableURL: executableURL,
        parentExecutableSHA256:
            executable.sha256
    )
    let binding = try publishReceipt(
        receipt,
        arguments: arguments,
        root: root
    )
    print(
        "\(outcome.rawValue) receipt_sha256=\(binding.sha256)"
    )
}

private func failureIdentity(
    _ error: Error
) -> (
    reasonCode: String,
    detailSHA256: String
) {
    let typeName = String(
        reflecting: type(of: error)
    ).filter {
        $0.isLetter || $0.isNumber
            || $0 == "." || $0 == "_"
            || $0 == "-"
    }
    return (
        String(typeName.prefix(128)),
        PrimeSHA256.hexDigest(
            of: Data(
                String(describing: error).utf8
            )
        )
    )
}

@main
private struct PrimeNative3BMetalContinuationProbeMain {
    static func main() {
        do {
            _ = try
                PrimeMLXRuntimeEnvironmentPolicy
                .validateCurrentProcess()
            _ = try
                PrimeReleaseInstrumentationAdmissionPolicy
                .validateCurrentProcess()
            let arguments = try parseArguments()
            let root = try PrimeArtifactRoot(
                directoryURL:
                    arguments.artifactRoot!
            )
            if arguments.role != .parent {
                try verifyInheritedSupervisorCapability(
                    expectedSHA256:
                        arguments
                        .internalWorkerCapabilitySHA256!
                )
                try verifySameExecutableSupervisorParent()
                try verifySupervisorAuthorityLeaseHeld(
                    artifactRootURL:
                        arguments.artifactRoot!
                )
            }
            switch arguments.role {
            case .parent:
                try runParent(
                    arguments: arguments,
                    root: root
                )
            case .control:
                try runControl(
                    arguments: arguments,
                    root: root
                )
            case .writer:
                try runWriter(
                    arguments: arguments,
                    root: root
                )
            case .restorer:
                try runRestorer(
                    arguments: arguments,
                    root: root
                )
            }
        } catch {
            let identity = failureIdentity(error)
            FileHandle.standardError.write(
                Data(
                    "ABSTAIN reason_code=\(identity.reasonCode) detail_sha256=\(identity.detailSHA256)\n"
                        .utf8
                )
            )
            exit(2)
        }
    }
}
