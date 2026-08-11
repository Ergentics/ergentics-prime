// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreGraphics
import Darwin
import Foundation
import Metal
import MLX
import MLXNN
import PrimeCore
import PrimeNativeDecoder
import PrimeNativeDecoderCheckpoint

private enum ProbeError: Error, CustomStringConvertible {
    case contractDrift(String)
    case missingEnvironmentValue(String)
    case invalidUnsignedInteger(key: String, value: String)
    case posix(operation: String, path: String, errorNumber: Int32)

    var description: String {
        switch self {
        case .contractDrift(let detail):
            "contract drift: \(detail)"
        case .missingEnvironmentValue(let key):
            "missing required environment value: \(key)"
        case .invalidUnsignedInteger(let key, let value):
            "invalid unsigned integer for \(key): \(value)"
        case .posix(let operation, let path, let errorNumber):
            "\(operation) failed for \(path): errno=\(errorNumber)"
        }
    }
}

private struct StructuralCatalogObservation {
    let descriptorCount: Int
    let parameterCount: UInt64
    let parameterByteCount: UInt64
}

private struct ArtifactPathObservation {
    let mode: UInt16
    let linkCount: UInt64
    let entryCount: Int
}

private final class HeldMetallib {
    let url: URL
    let byteCount: UInt64
    let sha256: String

    private let descriptor: Int32
    private let deviceID: UInt64
    private let inode: UInt64

    init(
        url: URL,
        expectedByteCount: UInt64,
        expectedSHA256: String
    ) throws {
        guard url.isFileURL,
              url.path.hasPrefix("/"),
              !url.path.hasSuffix("/") else {
            throw ProbeError.contractDrift("invalid metallib URL")
        }

        var pathStatus = stat()
        errno = 0
        guard lstat(url.path, &pathStatus) == 0 else {
            throw ProbeError.posix(
                operation: "lstat metallib",
                path: url.path,
                errorNumber: errno)
        }
        guard pathStatus.st_mode & S_IFMT == S_IFREG,
              pathStatus.st_mode & mode_t(0o777) == mode_t(0o444),
              pathStatus.st_nlink == 1,
              pathStatus.st_uid == geteuid(),
              pathStatus.st_size > 0,
              UInt64(pathStatus.st_size) == expectedByteCount else {
            throw ProbeError.contractDrift("unsafe metallib path metadata")
        }

        errno = 0
        let opened = open(url.path, O_RDONLY | O_NOFOLLOW | O_CLOEXEC)
        guard opened >= 0 else {
            throw ProbeError.posix(
                operation: "open metallib",
                path: url.path,
                errorNumber: errno)
        }
        var keepDescriptor = false
        defer {
            if !keepDescriptor {
                close(opened)
            }
        }

        var descriptorStatus = stat()
        errno = 0
        guard fstat(opened, &descriptorStatus) == 0 else {
            throw ProbeError.posix(
                operation: "fstat metallib",
                path: url.path,
                errorNumber: errno)
        }
        guard descriptorStatus.st_mode & S_IFMT == S_IFREG,
              descriptorStatus.st_nlink == 1,
              descriptorStatus.st_uid == geteuid(),
              (descriptorStatus.st_mode & mode_t(0o777))
                == (pathStatus.st_mode & mode_t(0o777)),
              descriptorStatus.st_dev == pathStatus.st_dev,
              descriptorStatus.st_ino == pathStatus.st_ino,
              descriptorStatus.st_size == pathStatus.st_size else {
            throw ProbeError.contractDrift(
                "metallib path and descriptor do not identify one file")
        }

        let data = try Self.read(
            descriptor: opened,
            byteCount: expectedByteCount,
            path: url.path)
        let observedSHA256 = PrimeSHA256.hexDigest(of: data)
        guard observedSHA256 == expectedSHA256 else {
            throw ProbeError.contractDrift("metallib SHA-256 mismatch")
        }

        self.url = url
        byteCount = expectedByteCount
        sha256 = observedSHA256
        descriptor = opened
        deviceID = UInt64(descriptorStatus.st_dev)
        inode = UInt64(descriptorStatus.st_ino)
        keepDescriptor = true
    }

    deinit {
        close(descriptor)
    }

    func revalidate() throws {
        var pathStatus = stat()
        errno = 0
        guard lstat(url.path, &pathStatus) == 0 else {
            throw ProbeError.posix(
                operation: "postflight lstat metallib",
                path: url.path,
                errorNumber: errno)
        }
        var descriptorStatus = stat()
        errno = 0
        guard fstat(descriptor, &descriptorStatus) == 0 else {
            throw ProbeError.posix(
                operation: "postflight fstat metallib",
                path: url.path,
                errorNumber: errno)
        }
        guard pathStatus.st_mode & S_IFMT == S_IFREG,
              pathStatus.st_mode & mode_t(0o777) == mode_t(0o444),
              pathStatus.st_nlink == 1,
              pathStatus.st_uid == geteuid(),
              UInt64(pathStatus.st_dev) == deviceID,
              UInt64(pathStatus.st_ino) == inode,
              descriptorStatus.st_dev == pathStatus.st_dev,
              descriptorStatus.st_ino == pathStatus.st_ino,
              (descriptorStatus.st_mode & mode_t(0o777))
                == (pathStatus.st_mode & mode_t(0o777)),
              descriptorStatus.st_size == pathStatus.st_size,
              UInt64(descriptorStatus.st_size) == byteCount else {
            throw ProbeError.contractDrift(
                "metallib path or descriptor changed during execution")
        }
        let data = try Self.read(
            descriptor: descriptor,
            byteCount: byteCount,
            path: url.path)
        guard PrimeSHA256.hexDigest(of: data) == sha256 else {
            throw ProbeError.contractDrift(
                "metallib bytes changed during execution")
        }
    }

    private static func read(
        descriptor: Int32,
        byteCount: UInt64,
        path: String
    ) throws -> Data {
        guard byteCount <= UInt64(Int.max) else {
            throw ProbeError.contractDrift("metallib is too large")
        }
        var result = Data()
        result.reserveCapacity(Int(byteCount))
        var offset: UInt64 = 0
        var buffer = [UInt8](repeating: 0, count: 1_048_576)
        while offset < byteCount {
            let remaining = Int(min(
                UInt64(buffer.count),
                byteCount - offset))
            errno = 0
            let observed = buffer.withUnsafeMutableBytes { bytes in
                pread(
                    descriptor,
                    bytes.baseAddress,
                    remaining,
                    off_t(offset))
            }
            guard observed > 0 else {
                if observed == 0 {
                    throw ProbeError.contractDrift(
                        "metallib descriptor ended early")
                }
                if errno == EINTR {
                    continue
                }
                throw ProbeError.posix(
                    operation: "read metallib",
                    path: path,
                    errorNumber: errno)
            }
            result.append(buffer, count: observed)
            offset += UInt64(observed)
        }
        guard result.count == Int(byteCount) else {
            throw ProbeError.contractDrift("metallib byte count changed")
        }
        return result
    }
}

private func requiredEnvironmentValue(
    _ key: String,
    environment: [String: String]
) throws -> String {
    guard let value = environment[key], !value.isEmpty else {
        throw ProbeError.missingEnvironmentValue(key)
    }
    return value
}

private func requiredUInt64(
    _ key: String,
    environment: [String: String]
) throws -> UInt64 {
    let text = try requiredEnvironmentValue(key, environment: environment)
    guard let value = UInt64(text), String(value) == text else {
        throw ProbeError.invalidUnsignedInteger(key: key, value: text)
    }
    return value
}

private func currentExecutableURL() throws -> URL {
    var capacity: UInt32 = 0
    _ = _NSGetExecutablePath(nil, &capacity)
    guard capacity > 1 else {
        throw ProbeError.contractDrift("executable path is unavailable")
    }
    var bytes = [CChar](repeating: 0, count: Int(capacity))
    guard _NSGetExecutablePath(&bytes, &capacity) == 0 else {
        throw ProbeError.contractDrift("executable path capture failed")
    }
    return URL(fileURLWithPath: String(cString: bytes))
        .resolvingSymlinksInPath()
        .standardizedFileURL
}

private func requireSameMetalDevice(
    _ lhs: any MTLDevice,
    _ rhs: any MTLDevice
) throws {
    guard lhs.registryID == rhs.registryID,
          lhs.name == rhs.name,
          lhs.architecture.name == rhs.architecture.name else {
        throw ProbeError.contractDrift(
            "default Metal device does not match index zero")
    }
}

private func existingLoaderCandidateCount(
    executableURL: URL
) throws -> Int {
    let executableDirectory = executableURL.deletingLastPathComponent()
    var paths = Set<String>()

    func append(_ url: URL) {
        paths.insert(url.standardizedFileURL.path)
    }

    func appendSwiftPMBundle(baseURL: URL) {
        let bundleURL = baseURL.appendingPathComponent(
            "mlx-swift_Cmlx.bundle",
            isDirectory: true)
        guard let bundle = Bundle(url: bundleURL),
              let resourceURL = bundle.resourceURL else {
            return
        }
        append(resourceURL.appendingPathComponent("default.metallib"))
    }

    append(executableDirectory.appendingPathComponent("mlx.metallib"))
    append(
        executableDirectory
            .appendingPathComponent("Resources", isDirectory: true)
            .appendingPathComponent("mlx.metallib"))
    appendSwiftPMBundle(baseURL: Bundle.main.bundleURL)
    for bundle in Bundle.allBundles {
        if let resourceURL = bundle.resourceURL {
            appendSwiftPMBundle(baseURL: resourceURL)
        }
    }
    for framework in Bundle.allFrameworks
    where framework.bundleIdentifier == "mlx-swift_Cmlx" {
        if let resourceURL = framework.resourceURL {
            append(resourceURL.appendingPathComponent("default.metallib"))
        }
    }
    append(
        executableDirectory
            .appendingPathComponent("Resources", isDirectory: true)
            .appendingPathComponent("default.metallib"))
    let currentDirectoryURL = URL(
        fileURLWithPath: FileManager.default.currentDirectoryPath,
        isDirectory: true)
    append(currentDirectoryURL.appendingPathComponent("default.metallib"))

    var count = 0
    for path in paths.sorted() {
        var status = stat()
        errno = 0
        if lstat(path, &status) == 0 {
            guard status.st_mode & S_IFMT == S_IFREG else {
                throw ProbeError.contractDrift(
                    "loader candidate is not a regular file: \(path)")
            }
            count += 1
        } else if errno != ENOENT {
            throw ProbeError.posix(
                operation: "lstat loader candidate",
                path: path,
                errorNumber: errno)
        }
    }
    return count
}

private func knownReclamationPaths(runnerTemp: String) throws -> [String] {
    guard runnerTemp.hasPrefix("/"),
          !runnerTemp.hasSuffix("/") else {
        throw ProbeError.contractDrift("invalid RUNNER_TEMP")
    }
    let families = [
        "prime-active-root",
        "prime-checkpoint-v2",
        "prime-checkpoint-v2-io",
        "prime-native-decoder",
        "prime-native-decoder-runtime-closure",
        "prime-native-decoder-tokenizer-compatibility",
    ]
    let suffixes = ["build", "cache", "config", "security"]
    return families.flatMap { family in
        suffixes.map { suffix in
            "\(runnerTemp)/\(family)-\(suffix)"
        }
    }
}

private func requireKnownReclamationPathsAbsent(
    runnerTemp: String
) throws -> Int {
    let paths = try knownReclamationPaths(runnerTemp: runnerTemp)
    guard paths.count == 24,
          Set(paths).count == paths.count else {
        throw ProbeError.contractDrift("reclamation path inventory")
    }
    for path in paths {
        var metadata = stat()
        errno = 0
        guard lstat(path, &metadata) != 0, errno == ENOENT else {
            throw ProbeError.contractDrift(
                "known predecessor temporary path remains: \(path)")
        }
    }
    return paths.count
}

private func availableFilesystemBytes(at path: String) throws -> UInt64 {
    var metadata = statfs()
    errno = 0
    guard statfs(path, &metadata) == 0,
          metadata.f_bavail >= 0,
          metadata.f_bsize > 0 else {
        throw ProbeError.posix(
            operation: "statfs checkpoint root",
            path: path,
            errorNumber: errno)
    }
    let bytes = UInt64(metadata.f_bavail).multipliedReportingOverflow(
        by: UInt64(metadata.f_bsize))
    guard !bytes.overflow else {
        throw ProbeError.contractDrift("filesystem capacity overflow")
    }
    return bytes.partialValue
}

private func inspectLoadedModelStructure(
    _ model: PrimeNativeGQADecoder,
    identity: PrimeNativeDecoderCompatibilityIdentityV2
) throws -> StructuralCatalogObservation {
    var arrays = [String: MLXArray]()
    for (path, array) in model.parameters().flattened() {
        guard arrays.updateValue(array, forKey: path) == nil else {
            throw ProbeError.contractDrift(
                "duplicate loaded parameter path: \(path)")
        }
    }
    let expectedPaths = identity.parameterCatalog.map(\.path)
    guard arrays.count == expectedPaths.count,
          Set(arrays.keys) == Set(expectedPaths) else {
        throw ProbeError.contractDrift("loaded parameter path set")
    }

    var parameterCount: UInt64 = 0
    var parameterByteCount: UInt64 = 0
    for descriptor in identity.parameterCatalog {
        guard let array = arrays[descriptor.path],
              array.shape == descriptor.shape,
              array.dtype == .float32,
              descriptor.dtype == "float32",
              array.size >= 0,
              UInt64(array.size) == descriptor.elementCount else {
            throw ProbeError.contractDrift(
                "loaded parameter metadata: \(descriptor.path)")
        }
        let nextCount = parameterCount.addingReportingOverflow(
            descriptor.elementCount)
        let nextBytes = parameterByteCount.addingReportingOverflow(
            descriptor.byteCount)
        guard !nextCount.overflow, !nextBytes.overflow else {
            throw ProbeError.contractDrift("loaded catalog overflow")
        }
        parameterCount = nextCount.partialValue
        parameterByteCount = nextBytes.partialValue
    }
    return StructuralCatalogObservation(
        descriptorCount: arrays.count,
        parameterCount: parameterCount,
        parameterByteCount: parameterByteCount)
}

private func executionRootIdentity(
    _ identity: PrimeArtifactRootIdentity
) -> PrimeNativeDecoderCheckpointV2ContainerIOExecutionRootIdentityV1 {
    PrimeNativeDecoderCheckpointV2ContainerIOExecutionRootIdentityV1(
        deviceID: identity.deviceID,
        inode: identity.inode,
        ownerUserID: identity.ownerUserID,
        ownerGroupID: identity.ownerGroupID,
        permissionMode: identity.actualMode,
        linkCount: identity.linkCount,
        modificationTimeSeconds: identity.modificationSeconds,
        modificationTimeNanoseconds: identity.modificationNanoseconds,
        changeTimeSeconds: identity.statusChangeSeconds,
        changeTimeNanoseconds: identity.statusChangeNanoseconds)
}

private func writeCallerSourceModel(
    configuration: PrimeNativeGQADecoderConfiguration,
    initializationSeed: UInt64,
    root: PrimeArtifactRoot,
    relativePath: String
) throws -> PrimeNativeDecoderCheckpointExternalBindingV2 {
    let model = PrimeNativeGQADecoder.make(
        configuration: configuration,
        seed: initializationSeed)
    model.train(false)
    try checkedEval(model)
    let binding = try PrimeNativeDecoderCheckpointCodecV2
        .writeNative300MByte512(
            model: model,
            to: root,
            at: relativePath)
    withExtendedLifetime(model) {}
    return binding
}

private func loadAndInspectStructure(
    binding: PrimeNativeDecoderCheckpointExternalBindingV2,
    root: PrimeArtifactRoot,
    identity: PrimeNativeDecoderCompatibilityIdentityV2
) throws -> StructuralCatalogObservation {
    let loaded = try PrimeNativeDecoderCheckpointCodecV2
        .loadNative300MByte512(
            expected: binding,
            from: root)
    let observation = try inspectLoadedModelStructure(
        loaded,
        identity: identity)
    withExtendedLifetime(loaded) {}
    return observation
}

private func observePublishedArtifact(
    rootPath: String,
    expectedRelativePath: String,
    expectedRootDeviceID: UInt64
) throws -> ArtifactPathObservation {
    // This path inventory is supplementary telemetry only. The successful
    // public codec load below supplies the descriptor-held pre/post byte-count
    // and whole-container hash verification.
    let entries = try FileManager.default.contentsOfDirectory(
        atPath: rootPath)
    guard entries == [expectedRelativePath] else {
        throw ProbeError.contractDrift("artifact root entry inventory")
    }
    let artifactPath = "\(rootPath)/\(expectedRelativePath)"
    var metadata = stat()
    errno = 0
    guard lstat(artifactPath, &metadata) == 0 else {
        throw ProbeError.posix(
            operation: "lstat published checkpoint",
            path: artifactPath,
            errorNumber: errno)
    }
    guard metadata.st_mode & S_IFMT == S_IFREG,
          metadata.st_uid == geteuid(),
          metadata.st_nlink == 1,
          UInt64(bitPattern: Int64(metadata.st_dev))
            == expectedRootDeviceID else {
        throw ProbeError.contractDrift("published checkpoint metadata")
    }
    return ArtifactPathObservation(
        mode: UInt16(metadata.st_mode & mode_t(0o777)),
        linkCount: UInt64(metadata.st_nlink),
        entryCount: entries.count)
}

// The executable body follows the helper definitions so the environment
// contract is checked before the first CoreGraphics, Metal, MLX, or model use.

private func emitChunkedReceipt(
    _ evidence:
        PrimeNativeDecoderCheckpointV2ContainerIOExecutionEvidenceV1
) throws {
    let authority =
        PrimeNativeDecoderCheckpointV2ContainerIOExecutionAuthorityPlanV1
            .frozenV1
    let receipt = try evidence.canonicalReceiptData()
    let receiptSHA256 = PrimeSHA256.hexDigest(of: receipt)
    let encoded = Array(receipt.base64EncodedString().utf8)
    let chunkSize = authority.receiptChunkCharacterCount
    guard chunkSize > 0,
          chunkSize.isMultiple(of: 4),
          !encoded.isEmpty else {
        throw ProbeError.contractDrift("receipt transport configuration")
    }
    let chunkCount = (encoded.count + chunkSize - 1) / chunkSize
    let beginPayload =
        "byte_count=\(receipt.count);sha256=\(receiptSHA256);encoding=\(authority.receiptTransportEncoding);chunk_character_count=\(chunkSize);chunk_count=\(chunkCount);evidence_id=\(evidence.evidenceID);authority_id=\(evidence.authorityID)"
    let endPayload =
        "chunk_count=\(chunkCount);sha256=\(receiptSHA256)"
    let beginLine = authority.receiptBeginMarker + beginPayload
    let endLine = authority.receiptEndMarker + endPayload
    guard beginLine.utf8.count
            < authority.maximumReceiptTransportLineByteCount,
          endLine.utf8.count
            < authority.maximumReceiptTransportLineByteCount else {
        throw ProbeError.contractDrift("receipt boundary line too long")
    }

    // BEGIN is emitted only after all evidence validation and postflight
    // checks have completed. A truncated transport has no END and is never a
    // successful receipt.
    print(beginLine)
    for index in 0 ..< chunkCount {
        let start = index * chunkSize
        let end = min(start + chunkSize, encoded.count)
        let payload = String(
            decoding: encoded[start ..< end],
            as: UTF8.self)
        let ordinal = String(
            format: "%0*d",
            authority.receiptChunkOrdinalWidth,
            index)
        let line = authority.receiptChunkMarker
            + ordinal + ":" + payload
        guard !payload.isEmpty,
              payload.utf8.count.isMultiple(of: 4),
              (index == chunkCount - 1
                || payload.utf8.count == chunkSize),
              line.utf8.count
                < authority.maximumReceiptTransportLineByteCount else {
            throw ProbeError.contractDrift("receipt chunk shape")
        }
        print(line)
    }
    print(endLine)
}

do {
    let environmentPolicy = try
        PrimeNativeDecoderCheckpointV2ContainerIOExecutionEnvironmentPolicyV1
            .validateLaunchedCurrentProcess()
    let releaseInstrumentation = try
        PrimeReleaseInstrumentationAdmissionPolicy.validateCurrentProcess()
    guard !releaseInstrumentation.observation.instrumentationObserved else {
        throw ProbeError.contractDrift("release instrumentation")
    }

    let authority =
        PrimeNativeDecoderCheckpointV2ContainerIOExecutionAuthorityPlanV1
            .frozenV1
    try authority.validateExactV1()
    guard PrimeEmbeddedBuildProvenance.buildConfiguration == "release" else {
        throw ProbeError.contractDrift("Release probe required")
    }

    let environment = ProcessInfo.processInfo.environment
    let prefix = "PRIME_NATIVE_DECODER_CHECKPOINT_V2_IO_"
    let executedRevision = try requiredEnvironmentValue(
        prefix + "EXECUTED_REVISION",
        environment: environment)
    let firstParent = try requiredEnvironmentValue(
        prefix + "FIRST_PARENT_REVISION",
        environment: environment)
    let secondParent = try requiredEnvironmentValue(
        prefix + "SECOND_PARENT_REVISION",
        environment: environment)
    let executedTree = try requiredEnvironmentValue(
        prefix + "EXECUTED_TREE",
        environment: environment)
    let reviewedHeadTree = try requiredEnvironmentValue(
        prefix + "REVIEWED_HEAD_TREE",
        environment: environment)
    let artifactRootPath = try requiredEnvironmentValue(
        prefix + "ARTIFACT_ROOT_PATH",
        environment: environment)
    let metallibPath = try requiredEnvironmentValue(
        prefix + "METALLIB_PATH",
        environment: environment)
    let metallibByteCount = try requiredUInt64(
        prefix + "METALLIB_BYTES",
        environment: environment)
    let metallibSHA256 = try requiredEnvironmentValue(
        prefix + "METALLIB_SHA256",
        environment: environment)
    let leasePath = try requiredEnvironmentValue(
        prefix + "METAL_LEASE_PATH",
        environment: environment)
    let availableAfterReclamation = try requiredUInt64(
        prefix + "AVAILABLE_BYTES_AFTER_RECLAMATION",
        environment: environment)
    let availableAfterBuild = try requiredUInt64(
        prefix + "AVAILABLE_BYTES_AFTER_BUILD",
        environment: environment)
    let predecessorLogCount = try requiredUInt64(
        prefix + "PREDECESSOR_VALIDATED_LOG_COUNT",
        environment: environment)
    let predecessorReceiptCount = try requiredUInt64(
        prefix + "PREDECESSOR_VALIDATED_RECEIPT_COUNT",
        environment: environment)
    let runnerTemp = try requiredEnvironmentValue(
        "RUNNER_TEMP",
        environment: environment)
    let executionRepository = try requiredEnvironmentValue(
        "GITHUB_REPOSITORY",
        environment: environment)
    let githubActions = try requiredEnvironmentValue(
        "GITHUB_ACTIONS",
        environment: environment)
    let runnerEnvironment = try requiredEnvironmentValue(
        "RUNNER_ENVIRONMENT",
        environment: environment)
    let executionEvent = try requiredEnvironmentValue(
        "GITHUB_EVENT_NAME",
        environment: environment)
    let executionRef = try requiredEnvironmentValue(
        "GITHUB_REF",
        environment: environment)
    let githubSHA = try requiredEnvironmentValue(
        "GITHUB_SHA",
        environment: environment)
    let runAttemptText = try requiredEnvironmentValue(
        "GITHUB_RUN_ATTEMPT",
        environment: environment)
    guard let runAttempt = Int(runAttemptText),
          String(runAttempt) == runAttemptText,
          executionRepository == authority.authoritativeRepository,
          githubActions == authority.requiredGitHubActionsValue,
          runnerEnvironment == authority.requiredRunnerEnvironment,
          executionEvent == authority.requiredExecutionEvent,
          executionRef == authority.requiredExecutionRef,
          runAttempt == authority.requiredExecutionRunAttempt,
          githubSHA == executedRevision,
          firstParent
            == authority.requiredDirectSuccessorFirstParentRevision,
          reviewedHeadTree == executedTree,
          predecessorLogCount == 8,
          predecessorReceiptCount == 2 else {
        throw ProbeError.contractDrift("hosted one-shot context")
    }

    let reclaimedPathCount = try requireKnownReclamationPathsAbsent(
        runnerTemp: runnerTemp)
    guard reclaimedPathCount
            == authority.reclaimableRunnerTemporaryRelativePaths.count,
          availableAfterReclamation
            >= authority.requiredAvailableFilesystemBytesAfterBuild,
          availableAfterBuild
            >= authority.requiredAvailableFilesystemBytesAfterBuild else {
        throw ProbeError.contractDrift("capacity or reclamation preflight")
    }

    let artifactRootURL = URL(
        fileURLWithPath: artifactRootPath,
        isDirectory: true).standardizedFileURL
    guard artifactRootPath == artifactRootURL.path,
          artifactRootPath.hasPrefix("/"),
          !artifactRootPath.hasSuffix("/") else {
        throw ProbeError.contractDrift("artifact root path")
    }
    let artifactRoot = try PrimeArtifactRoot(directoryURL: artifactRootURL)
    try artifactRoot.requirePrivateRootMode()
    try artifactRoot.requireEmpty()
    let rootBeforeWrite = executionRootIdentity(
        try artifactRoot.verifiedRootIdentity())
    try rootBeforeWrite.validatePrivateDirectory()
    guard rootBeforeWrite.ownerUserID == geteuid() else {
        throw ProbeError.contractDrift("artifact root owner")
    }

    let executableURL = try currentExecutableURL()
    let expectation = try
        PrimeNativeDecoderMaintainedRuntimeMetallibExpectationV1(
            byteCount: metallibByteCount,
            sha256: metallibSHA256)
    let expectedMetallibURL = executableURL
        .deletingLastPathComponent()
        .appendingPathComponent(expectation.artifactRelativePath)
        .standardizedFileURL
    let suppliedMetallibURL = URL(fileURLWithPath: metallibPath)
        .standardizedFileURL
    guard suppliedMetallibURL.path == expectedMetallibURL.path,
          metallibPath == suppliedMetallibURL.path else {
        throw ProbeError.contractDrift("unexpected metallib path")
    }
    let candidateCountBefore = try existingLoaderCandidateCount(
        executableURL: executableURL)
    guard candidateCountBefore == 1 else {
        throw ProbeError.contractDrift("loader candidates before execution")
    }
    let metallib = try HeldMetallib(
        url: suppliedMetallibURL,
        expectedByteCount: expectation.byteCount,
        expectedSHA256: expectation.sha256)
    let lease = try PrimeMetalDeviceLease.acquire(
        at: URL(fileURLWithPath: leasePath))
    defer { lease.release() }
    guard lease.isHeld else {
        throw ProbeError.contractDrift("Metal lease")
    }

    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard colorSpace.model == .rgb else {
        throw ProbeError.contractDrift("CoreGraphics bootstrap")
    }
    let metalDevices = MTLCopyAllDevices()
    guard metalDevices.count == 1,
          let indexZero = metalDevices.first,
          let defaultDevice = MTLCreateSystemDefaultDevice() else {
        throw ProbeError.contractDrift("singleton Metal device")
    }
    try requireSameMetalDevice(indexZero, defaultDevice)
    let validatedLibrary: any MTLLibrary
    do {
        validatedLibrary = try indexZero.makeLibrary(URL: metallib.url)
    } catch {
        throw ProbeError.contractDrift(
            "exact metallib URL validation failed: \(error)")
    }

    let identity = try PrimeNativeDecoderCompatibilityIdentityV2
        .native300MByte512()
    try identity.validate()
    let identityBytes = try PrimeCanonicalJSON.encode(identity)
    let identitySHA256 = PrimeSHA256.hexDigest(of: identityBytes)
    guard identityBytes.count
            == authority.compatibilityIdentityCanonicalByteCount,
          identitySHA256 == authority.compatibilityIdentitySHA256 else {
        throw ProbeError.contractDrift("compatibility identity")
    }
    let configuration = try PrimeNativeGQADecoderConfiguration
        .native300MInventory(vocabularySize: 512)
    guard PrimeNativeDecoderConfigurationSnapshotV1(configuration)
            == identity.configuration else {
        throw ProbeError.contractDrift("Native-300M configuration")
    }
    guard let mlxGPUIndex = Int32(exactly: authority.mlxGPUDeviceIndex) else {
        throw ProbeError.contractDrift("MLX GPU index representation")
    }
    let gpu = Device(.gpu, index: mlxGPUIndex)
    guard gpu.deviceType == .gpu else {
        throw ProbeError.contractDrift("MLX GPU index zero")
    }

    let execution = try withExtendedLifetime(validatedLibrary) {
        try Device.withDefaultDevice(gpu) {
            try withError {
                Memory.cacheLimit = authority.requiredMemoryCacheLimit
                guard Memory.cacheLimit
                        == authority.requiredMemoryCacheLimit else {
                    throw ProbeError.contractDrift("MLX cache limit")
                }
                let availableImmediatelyBeforeWrite = try
                    availableFilesystemBytes(at: artifactRootPath)
                guard availableImmediatelyBeforeWrite
                        >= authority
                            .requiredAvailableFilesystemBytesAfterBuild else {
                    throw ProbeError.contractDrift(
                        "immediate pre-write free space")
                }
                Memory.clearCache()
                let binding = try writeCallerSourceModel(
                    configuration: configuration,
                    initializationSeed: authority.initializationSeed,
                    root: artifactRoot,
                    relativePath: authority.artifactRelativePath)
                let rootAfterWrite = executionRootIdentity(
                    try artifactRoot.verifiedRootIdentity())
                guard rootBeforeWrite.stableObjectFieldsEqual(
                    to: rootAfterWrite) else {
                    throw ProbeError.contractDrift(
                        "artifact root changed identity during write")
                }
                let pathObservation = try observePublishedArtifact(
                    rootPath: artifactRootPath,
                    expectedRelativePath: authority.artifactRelativePath,
                    expectedRootDeviceID: rootAfterWrite.deviceID)

                Memory.clearCache()
                let structure = try loadAndInspectStructure(
                    binding: binding,
                    root: artifactRoot,
                    identity: identity)
                let rootAfterLoad = executionRootIdentity(
                    try artifactRoot.verifiedRootIdentity())
                guard rootAfterLoad == rootAfterWrite else {
                    throw ProbeError.contractDrift(
                        "artifact root changed during read-only load")
                }
                return (
                    binding,
                    rootAfterWrite,
                    rootAfterLoad,
                    pathObservation,
                    structure,
                    availableImmediatelyBeforeWrite)
            }
        }
    }
    let externalBinding = execution.0
    let rootAfterWrite = execution.1
    let rootAfterLoad = execution.2
    let pathObservation = execution.3
    let loadedStructure = execution.4
    let availableImmediatelyBeforeWrite = execution.5
    try externalBinding.validate()
    guard loadedStructure.descriptorCount
            == authority.parameterDescriptorCount,
          loadedStructure.parameterCount == authority.totalParameterCount,
          loadedStructure.parameterByteCount
            == authority.totalParameterByteCount,
          pathObservation.mode == authority.requiredPublishedArtifactMode,
          pathObservation.linkCount
            == authority.requiredPublishedArtifactLinkCount,
          pathObservation.entryCount
            == authority.requiredArtifactRootEntryCountAfterWrite else {
        throw ProbeError.contractDrift("loaded structure or artifact mode")
    }

    let postflightPolicy = try
        PrimeNativeDecoderCheckpointV2ContainerIOExecutionEnvironmentPolicyV1
            .validateLaunchedCurrentProcess()
    guard postflightPolicy == environmentPolicy else {
        throw ProbeError.contractDrift("launched environment changed")
    }
    let postflightInstrumentation = try
        PrimeReleaseInstrumentationAdmissionPolicy.validateCurrentProcess()
    guard !postflightInstrumentation.observation.instrumentationObserved else {
        throw ProbeError.contractDrift("postflight instrumentation")
    }
    try metallib.revalidate()
    let candidateCountAfter = try existingLoaderCandidateCount(
        executableURL: executableURL)
    guard candidateCountAfter == 1,
          lease.isHeld else {
        throw ProbeError.contractDrift("postflight loader or lease")
    }
    let postflightDevices = MTLCopyAllDevices()
    guard postflightDevices.count == 1,
          let postflightIndexZero = postflightDevices.first,
          let postflightDefault = MTLCreateSystemDefaultDevice() else {
        throw ProbeError.contractDrift("postflight singleton Metal device")
    }
    try requireSameMetalDevice(indexZero, postflightIndexZero)
    try requireSameMetalDevice(indexZero, postflightDefault)

    let externalBindingBytes = try PrimeCanonicalJSON.encode(
        externalBinding)
    let manifestBytes = try PrimeCanonicalJSON.encode(
        externalBinding.manifest)
    let tensorBindingBytes = try PrimeCanonicalJSON.encode(
        externalBinding.manifest.tensorBindings)
    let evidence = try
        PrimeNativeDecoderCheckpointV2ContainerIOExecutionEvidenceV1(
            executedRevision: executedRevision,
            executedOrderedParentRevisions: [firstParent, secondParent],
            executedTree: executedTree,
            reviewedPullRequestHeadTree: reviewedHeadTree,
            executedEmbeddedSourceIdentitySHA256:
                PrimeEmbeddedBuildProvenance.sourceIdentitySHA256,
            executionEvent: executionEvent,
            executionRef: executionRef,
            executionRunAttempt: runAttempt,
            executionRepository: executionRepository,
            githubActions: githubActions,
            runnerEnvironment: runnerEnvironment,
            operatingSystem: "macOS",
            architecture: "arm64",
            exactRevisionMatchedGitHubSHA: githubSHA == executedRevision,
            environmentPolicy: environmentPolicy,
            launchedEnvironmentValidatedBeforeFrameworkAccess: true,
            launchedEnvironmentRevalidatedAfterEvaluation: true,
            releaseInstrumentationEvidenceAbsent: true,
            coreGraphicsBootstrapObserved: true,
            enumeratedMetalDeviceCount: metalDevices.count,
            defaultMetalDeviceMatchedIndexZero: true,
            mlxDeviceType: "gpu",
            mlxDeviceIndex: authority.mlxGPUDeviceIndex,
            metalLeaseHeldBeforeAndAfterEvaluation: true,
            metallibArtifactRelativePath: expectation.artifactRelativePath,
            metallibByteCount: metallib.byteCount,
            metallibSHA256: metallib.sha256,
            existingMetallibCandidateCountBeforeExecution:
                candidateCountBefore,
            existingMetallibCandidateCountAfterExecution:
                candidateCountAfter,
            metallibPathAndDescriptorReverified: true,
            metalLibraryValidatedFromExactURL: true,
            focusedContractLogsValidatedBeforeReclamation: true,
            frozen44MetalLogValidatedBeforeReclamation: true,
            maintainedRuntimeAuthorityLogAndReceiptValidatedBeforeReclamation:
                true,
            tokenizerAuthorityLogAndReceiptValidatedBeforeReclamation: true,
            predecessorValidatedLogCount: Int(predecessorLogCount),
            predecessorValidatedReceiptCount: Int(predecessorReceiptCount),
            knownRunnerTemporaryReclamationPathCount:
                reclaimedPathCount,
            knownRunnerTemporaryPathsAbsentBeforeProbe: true,
            availableFilesystemBytesAfterReclamation:
                availableAfterReclamation,
            availableFilesystemBytesAfterBuild:
                availableImmediatelyBeforeWrite,
            requiredFreeSpaceMultiplier:
                authority.requiredFreeSpaceMultiplier,
            freeSpacePreflightPassed: true,
            artifactRootPathIsAbsolute: true,
            artifactRootOwnerMatchedEffectiveUser: true,
            artifactRootInitiallyEmpty: true,
            artifactRootEntryCountAfterWrite: pathObservation.entryCount,
            artifactRootIdentityBeforeWrite: rootBeforeWrite,
            artifactRootIdentityAfterWrite: rootAfterWrite,
            artifactRootIdentityAfterLoad: rootAfterLoad,
            compatibilityIdentityCanonicalByteCount: identityBytes.count,
            compatibilityIdentitySHA256: identitySHA256,
            compatibilityIdentityValidated: true,
            configuration: authority.configuration,
            initializationSeed: authority.initializationSeed,
            callerSourceModelConstructionCount: 1,
            initialParameterMaterializationEvaluationCount: 1,
            initialParameterMaterializationEvaluationAPI:
                authority.initialParameterMaterializationEvaluationAPI,
            memoryCacheLimit: Memory.cacheLimit,
            memoryCacheClearCount: 2,
            cacheClearedBeforeSourceMaterialization: true,
            sourceModelReferenceLexicalScopeEndedBeforePublicLoad: true,
            cacheClearedBetweenSourceWriteAndPublicLoad: true,
            publicCheckpointWriteInvocationCount: 1,
            publicCheckpointWriteCompletionCount: 1,
            publicCheckpointLoadInvocationCount: 1,
            publicCheckpointLoadCompletionCount: 1,
            externalBinding: externalBinding,
            externalBindingCanonicalByteCount:
                UInt64(externalBindingBytes.count),
            externalBindingCanonicalSHA256:
                PrimeSHA256.hexDigest(of: externalBindingBytes),
            manifestCanonicalByteCount: UInt64(manifestBytes.count),
            manifestCanonicalSHA256:
                PrimeSHA256.hexDigest(of: manifestBytes),
            manifestValidated: true,
            tensorBindingCount:
                externalBinding.manifest.tensorBindings.count,
            tensorBindingsCanonicalByteCount:
                UInt64(tensorBindingBytes.count),
            tensorBindingsSHA256:
                PrimeSHA256.hexDigest(of: tensorBindingBytes),
            observedParameterCount: loadedStructure.parameterCount,
            observedParameterByteCount:
                loadedStructure.parameterByteCount,
            publishedArtifactMode: pathObservation.mode,
            publishedArtifactLinkCount: pathObservation.linkCount,
            writerHiddenDescriptorRestoreAndReinspectionCompletedViaSuccessfulPinnedCodecReturn:
                true,
            loadedParameterCatalogAndLogicalHashesMatchedManifestViaPinnedCodec:
                true,
            loadedStructuralParameterCatalogMatched: true,
            artifactBindingVerifiedBeforeAndAfterCompleteMaterializationViaPinnedArtifactRoot:
                true,
            exclusiveNoReplacePublicationCompleted: true,
            generatedFileAndParentSynchronizationReturnedSuccess: true)
    try evidence.validate()
    try emitChunkedReceipt(evidence)
} catch {
    fputs(
        "prime-native-decoder-checkpoint-v2-io-execution-probe: \(error)\n",
        stderr)
    exit(2)
}
