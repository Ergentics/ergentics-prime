import Darwin
import Foundation
import MLX
import MLXLLM
import MLXNN
import MLXOptimizers
import PrimeCore

private enum CalibrationError:
    Error,
    CustomStringConvertible
{
    case invalidArgument(String)
    case gpuAuthorizationRequired
    case wrongDevice(String)
    case invalidDeviceInfo(String)
    case parameterCount(expected: Int64, observed: Int64)
    case precision([String])
    case nonFinite(String)
    case weightUpdateMissing
    case deadlineExceeded
    case unsafeSourceFile(String)
    case incompleteSourceSnapshot
    case sourceIdentityMismatch(
        expected: String,
        observed: String
    )
    case releaseBuildRequired(String)
    case executableUnreadable(String)
    case receiptRoundTripMismatch
    case supervisorCapabilityRequired
    case supervisorCapabilityRejected
    case supervisorParentIdentityMismatch
    case supervisorAuthorityLeaseMissing
    case supervisorTerminationIncomplete(String)
    case publishedFailure(String)

    var description: String {
        switch self {
        case let .invalidArgument(value):
            "invalid argument: \(value)"
        case .gpuAuthorizationRequired:
            "3B FP32 allocation requires --authorize-gpu-allocation true"
        case let .wrongDevice(device):
            "calibration requires MLX GPU; observed \(device)"
        case let .invalidDeviceInfo(detail):
            "calibration device information is incomplete: \(detail)"
        case let .parameterCount(expected, observed):
            "parameter count mismatch expected=\(expected) observed=\(observed)"
        case let .precision(values):
            "FP32 parameter contract failed: \(values)"
        case let .nonFinite(label):
            "non-finite \(label)"
        case .weightUpdateMissing:
            "AdamW step did not change the selected parameter fingerprint"
        case .deadlineExceeded:
            "bounded mechanics calibration exceeded its declared active-time cap"
        case let .unsafeSourceFile(path):
            "source snapshot rejected unsafe file: \(path)"
        case .incompleteSourceSnapshot:
            "source snapshot is missing the package or calibration executor"
        case let .sourceIdentityMismatch(expected, observed):
            "running binary/source identity mismatch expected=\(expected) observed=\(observed)"
        case let .releaseBuildRequired(configuration):
            "GPU calibration requires a release binary; observed \(configuration)"
        case let .executableUnreadable(path):
            "running executable is not a safe readable regular file: \(path)"
        case .receiptRoundTripMismatch:
            "published canonical receipt did not round-trip exactly"
        case .supervisorCapabilityRequired:
            "internal worker requires an inherited Swift-supervisor capability"
        case .supervisorCapabilityRejected:
            "internal worker rejected the inherited Swift-supervisor capability"
        case .supervisorParentIdentityMismatch:
            "internal worker parent is not the same Prime Swift executable"
        case .supervisorAuthorityLeaseMissing:
            "internal worker could not prove its parent holds the artifact-root supervisor lease"
        case let .supervisorTerminationIncomplete(detail):
            "Swift supervisor could not prove worker termination: \(detail)"
        case let .publishedFailure(detail):
            detail
        }
    }
}

private struct Arguments {
    var artifactRoot: URL?
    var sourceRoot: URL?
    var historicalEvidenceRoot: URL?
    var leaseFile: URL?
    var receiptPath =
        "prime-gpu-calibration-receipt.v2.json"
    var gpuAuthorized = false
    var internalWorker = false
    var internalWorkerCapabilitySHA256: String?
}

private let workerCandidateReceiptPath =
    "content-staging/" +
    "prime-gpu-calibration-worker-candidate.v2.json"
private let supervisorAuthorityLeaseName =
    ".prime-supervisor-authority.lock"

private struct SourceFileSnapshot: Codable {
    let relativePath: String
    let sha256: String
    let byteCount: UInt64
    let contents: Data

    private enum CodingKeys: String, CodingKey {
        case relativePath = "relative_path"
        case sha256
        case byteCount = "byte_count"
        case contents
    }
}

private struct CalibrationSourceSnapshot: Codable {
    let schemaVersion = 1
    let artifactKind =
        "ergentics_prime_swift_source_snapshot"
    let sourceIdentitySHA256: String
    let embeddedSourceIdentitySHA256: String
    let buildConfiguration: String
    let files: [SourceFileSnapshot]

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case artifactKind = "artifact_kind"
        case sourceIdentitySHA256 =
            "source_identity_sha256"
        case embeddedSourceIdentitySHA256 =
            "embedded_source_identity_sha256"
        case buildConfiguration =
            "build_configuration"
        case files
    }
}

private final class GPUExecutionProgress {
    var deviceArchitecture: String?
    var deviceDescription: String?
    var metalExecution: PrimeBooleanObservation =
        .observed(false)
    var failureStage:
        PrimeGPUCalibrationFailureStage =
            .workerPreflight
}

private struct SourceIdentityRecord: Codable {
    let relativePath: String
    let sha256: String
    let byteCount: UInt64

    private enum CodingKeys: String, CodingKey {
        case relativePath = "relative_path"
        case sha256
        case byteCount = "byte_count"
    }
}

private func canonicalEmbeddedProvenanceSource(
    sourceIdentitySHA256: String
) -> Data {
    let lines = [
        "enum PrimeEmbeddedBuildProvenance {",
        "    #if DEBUG",
        "        static let buildConfiguration = \"debug\"",
        "    #else",
        "        static let buildConfiguration = \"release\"",
        "    #endif",
        "",
        "    // This file is excluded only to avoid a self-referential digest. Runtime",
        "    // verification requires this exact canonical template and digest; every",
        "    // other admitted package, source, test, and architecture file is hashed.",
        "    static let sourceIdentitySHA256 =",
        "        \"\(sourceIdentitySHA256)\"",
        "}",
        "",
    ]
    return Data(lines.joined(separator: "\n").utf8)
}

private func parseArguments() throws -> Arguments {
    var result = Arguments()
    var values = Array(CommandLine.arguments.dropFirst())
    while values.isEmpty == false {
        let key = values.removeFirst()
        guard values.isEmpty == false else {
            throw CalibrationError.invalidArgument(
                "\(key) requires a value"
            )
        }
        let value = values.removeFirst()
        switch key {
        case "--artifact-root":
            result.artifactRoot =
                URL(fileURLWithPath: value)
        case "--source-root":
            result.sourceRoot =
                URL(fileURLWithPath: value)
        case "--historical-evidence-root":
            result.historicalEvidenceRoot =
                URL(fileURLWithPath: value)
        case "--lease-file":
            result.leaseFile =
                URL(fileURLWithPath: value)
        case "--receipt-path":
            result.receiptPath = value
        case "--authorize-gpu-allocation":
            guard let parsed = Bool(value) else {
                throw CalibrationError.invalidArgument(key)
            }
            result.gpuAuthorized = parsed
        case "--internal-worker":
            guard let parsed = Bool(value) else {
                throw CalibrationError.invalidArgument(key)
            }
            result.internalWorker = parsed
        case "--internal-worker-capability-sha256":
            result.internalWorkerCapabilitySHA256 = value
        default:
            throw CalibrationError.invalidArgument(key)
        }
    }
    guard result.artifactRoot != nil else {
        throw CalibrationError.invalidArgument(
            "--artifact-root is required"
        )
    }
    guard result.sourceRoot != nil else {
        throw CalibrationError.invalidArgument(
            "--source-root is required"
        )
    }
    guard result.historicalEvidenceRoot != nil else {
        throw CalibrationError.invalidArgument(
            "--historical-evidence-root is required"
        )
    }
    guard result.leaseFile != nil else {
        throw CalibrationError.invalidArgument(
            "--lease-file is required"
        )
    }
    guard result.gpuAuthorized else {
        throw CalibrationError.gpuAuthorizationRequired
    }
    if result.internalWorker {
        guard let digest =
                result.internalWorkerCapabilitySHA256,
              digest.utf8.count == 64,
              digest.utf8.allSatisfy({
                  ($0 >= 48 && $0 <= 57)
                      || ($0 >= 97 && $0 <= 102)
              }) else {
            throw CalibrationError
                .supervisorCapabilityRequired
        }
    } else if result.internalWorkerCapabilitySHA256 != nil {
        throw CalibrationError.invalidArgument(
            "worker capability is valid only for an internal worker"
        )
    }
    let receiptComponents = result.receiptPath.split(
        separator: "/",
        omittingEmptySubsequences: false
    )
    guard !result.receiptPath.isEmpty,
          !result.receiptPath.hasPrefix("/"),
          receiptComponents.count == 1,
          receiptComponents.allSatisfy({
              !$0.isEmpty && $0 != "." && $0 != ".."
          }) else {
        throw CalibrationError.invalidArgument(
            "--receipt-path must be one safe root-level filename"
        )
    }
    guard result.receiptPath
            == "prime-gpu-calibration-receipt.v2.json" else {
        throw CalibrationError.invalidArgument(
            "--receipt-path is frozen for the initial allocation probe"
        )
    }
    return result
}

private func verifyInheritedSupervisorCapability(
    expectedSHA256: String
) throws {
    let maximumBytes = 128
    let deadline =
        DispatchTime.now().uptimeNanoseconds
        + 5_000_000_000
    var capability = Data()

    while true {
        let now = DispatchTime.now().uptimeNanoseconds
        guard now < deadline else {
            throw CalibrationError
                .supervisorCapabilityRejected
        }
        let remainingNanoseconds = deadline - now
        let timeoutMilliseconds = Int32(
            min(
                UInt64(Int32.max),
                max(
                    UInt64(1),
                    (
                        remainingNanoseconds
                        + 999_999
                    ) / 1_000_000
                )
            )
        )
        var descriptor = pollfd(
            fd: STDIN_FILENO,
            events: Int16(POLLIN | POLLHUP),
            revents: 0
        )
        let pollResult = poll(
            &descriptor,
            1,
            timeoutMilliseconds
        )
        if pollResult < 0, errno == EINTR {
            continue
        }
        guard pollResult > 0 else {
            throw CalibrationError
                .supervisorCapabilityRejected
        }

        var buffer = [UInt8](
            repeating: 0,
            count: 64
        )
        let count = buffer.withUnsafeMutableBytes {
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
            throw CalibrationError
                .supervisorCapabilityRejected
        }
        if count == 0 {
            break
        }
        capability.append(
            contentsOf: buffer[0 ..< count]
        )
        guard capability.count <= maximumBytes else {
            throw CalibrationError
                .supervisorCapabilityRejected
        }
    }

    guard capability.count == 36,
          PrimeSHA256.hexDigest(of: capability)
            == expectedSHA256 else {
        throw CalibrationError
            .supervisorCapabilityRejected
    }
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

private func parameterCount(
    _ parameters: ModuleParameters
) -> Int64 {
    parameters.flattened().reduce(0) {
        $0 + Int64($1.1.size)
    }
}

private func parameterDTypes(
    _ parameters: ModuleParameters
) -> [String] {
    Array(
        Set(
            parameters.flattened().map {
                String(describing: $0.1.dtype)
            }
        )
    ).sorted()
}

private func causalLoss(
    model: LlamaModel,
    inputs: MLXArray
) -> MLXArray {
    let length = inputs.shape[1]
    let logits = model(inputs, cache: nil)
    let shiftedLogits =
        logits[0..., 0 ..< (length - 1), 0...]
    let targets = inputs[0..., 1 ..< length]
    return crossEntropy(
        logits: shiftedLogits,
        targets: targets,
        reduction: .mean
    )
}

private func deterministicInputs(
    seed: UInt64,
    count: Int,
    batchSize: Int,
    sequenceLength: Int
) -> [MLXArray] {
    let root = MLXRandom.key(seed)
    return MLXRandom.split(key: root, into: count).map {
        MLXRandom.randInt(
            Int32(256) ..< Int32(512),
            [batchSize, sequenceLength],
            key: $0
        )
    }
}

private func finiteLoss(
    model: LlamaModel,
    inputs: MLXArray,
    label: String
) throws -> Double {
    model.train(false)
    let loss = causalLoss(model: model, inputs: inputs)
    eval(loss)
    let value = Double(loss.item(Float.self))
    guard value.isFinite else {
        throw CalibrationError.nonFinite(label)
    }
    return value
}

private func gradientNorm(
    _ gradients: ModuleParameters
) throws -> Double {
    let components = gradients.flattened().map {
        $0.1.asType(.float32).square().sum()
    }
    guard var total = components.first else {
        throw CalibrationError.nonFinite("empty gradient tree")
    }
    for component in components.dropFirst() {
        total = total + component
    }
    let norm = total.sqrt()
    eval(norm)
    let value = Double(norm.item(Float.self))
    guard value.isFinite, value > 0 else {
        throw CalibrationError.nonFinite("gradient norm")
    }
    return value
}

private func arrayNorm(
    _ arrays: [MLXArray],
    label: String
) throws -> Double {
    let components = arrays.map {
        $0.asType(.float32).square().sum()
    }
    guard var total = components.first else {
        throw CalibrationError.nonFinite(
            "empty \(label)"
        )
    }
    for component in components.dropFirst() {
        total = total + component
    }
    let norm = total.sqrt()
    eval(norm)
    let value = Double(norm.item(Float.self))
    guard value.isFinite, value > 0 else {
        throw CalibrationError.nonFinite(label)
    }
    return value
}

private func selectedParameterFingerprint(
    _ model: Module
) -> String {
    let parameters = model.parameters().flattened().sorted {
        $0.0 < $1.0
    }
    let selectedParameterIndices = Array(
        Set([
            0,
            max(0, parameters.count / 2),
            max(0, parameters.count - 1),
        ])
    ).sorted()
    var material = Data()
    for parameterIndex in selectedParameterIndices {
        let (name, value) = parameters[parameterIndex]
        let flat = value.reshaped([-1])
        let scalarIndices = Array(
            Set([
                0,
                max(0, value.size / 2),
                max(0, value.size - 1),
            ])
        ).sorted()
        material.append(Data(name.utf8))
        material.append(0)
        for scalarIndex in scalarIndices {
            let scalar = flat[scalarIndex].asType(.float32)
            eval(scalar)
            var bits =
                scalar.item(Float.self).bitPattern.bigEndian
            withUnsafeBytes(of: &bits) {
                material.append(contentsOf: $0)
            }
        }
    }
    return PrimeSHA256.hexDigest(of: material)
}

private func durationSeconds(
    _ duration: Duration
) -> Double {
    let components = duration.components
    return Double(components.seconds)
        + Double(components.attoseconds) / 1e18
}

private func regularFileData(
    at url: URL,
    maximumBytes: Int64
) throws -> Data {
    let descriptor = open(
        url.path,
        O_RDONLY | O_NOFOLLOW | O_CLOEXEC
    )
    guard descriptor >= 0 else {
        throw CalibrationError.unsafeSourceFile(url.path)
    }
    defer {
        close(descriptor)
    }
    var before = stat()
    guard fstat(descriptor, &before) == 0,
          before.st_mode & S_IFMT == S_IFREG,
          before.st_nlink == 1,
          before.st_size >= 0,
          before.st_size <= maximumBytes else {
        throw CalibrationError.unsafeSourceFile(url.path)
    }
    var data = Data()
    data.reserveCapacity(Int(before.st_size))
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
            throw CalibrationError.unsafeSourceFile(
                url.path
            )
        }
        if count == 0 {
            break
        }
        data.append(contentsOf: buffer[0 ..< count])
        guard data.count <= maximumBytes else {
            throw CalibrationError.unsafeSourceFile(
                url.path
            )
        }
    }
    var after = stat()
    guard fstat(descriptor, &after) == 0,
          before.st_dev == after.st_dev,
          before.st_ino == after.st_ino,
          before.st_size == after.st_size,
          data.count == Int(after.st_size) else {
        throw CalibrationError.unsafeSourceFile(url.path)
    }
    return data
}

private func sourceSnapshot(
    at sourceRoot: URL
) throws -> CalibrationSourceSnapshot {
    let root = sourceRoot.standardizedFileURL
    let rootPrefix = root.path + "/"
    var urls = [URL]()
    let fixedFiles = [
        ".gitignore",
        "LICENSE",
        "Package.swift",
        "Package.resolved",
        "README.md",
        "THIRD_PARTY_NOTICES.md",
    ]
    for relativePath in fixedFiles {
        urls.append(
            root.appendingPathComponent(relativePath)
        )
    }
    for directory in ["Sources", "Tests", "docs"] {
        let directoryURL =
            root.appendingPathComponent(
                directory,
                isDirectory: true
            )
        guard let enumerator =
                FileManager.default.enumerator(
                    at: directoryURL,
                    includingPropertiesForKeys: nil,
                    options: [.skipsHiddenFiles]
                ) else {
            throw CalibrationError.incompleteSourceSnapshot
        }
        for case let fileURL as URL in enumerator {
            var metadata = stat()
            guard lstat(fileURL.path, &metadata) == 0 else {
                throw CalibrationError.unsafeSourceFile(
                    fileURL.path
                )
            }
            if metadata.st_mode & S_IFMT == S_IFDIR {
                continue
            }
            guard metadata.st_mode & S_IFMT == S_IFREG else {
                throw CalibrationError.unsafeSourceFile(
                    fileURL.path
                )
            }
            urls.append(fileURL)
        }
    }

    var snapshots = [SourceFileSnapshot]()
    var observedPaths = Set<String>()
    for url in urls {
        let standardized = url.standardizedFileURL
        guard standardized.path.hasPrefix(rootPrefix) else {
            throw CalibrationError.unsafeSourceFile(
                standardized.path
            )
        }
        let relativePath = String(
            standardized.path.dropFirst(rootPrefix.count)
        )
        guard observedPaths.insert(relativePath).inserted else {
            throw CalibrationError.unsafeSourceFile(
                relativePath
            )
        }
        let data = try regularFileData(
            at: standardized,
            maximumBytes: 8 * 1024 * 1024
        )
        snapshots.append(
            SourceFileSnapshot(
                relativePath: relativePath,
                sha256:
                    PrimeSHA256.hexDigest(of: data),
                byteCount: UInt64(data.count),
                contents: data
            )
        )
    }
    snapshots.sort {
        $0.relativePath < $1.relativePath
    }
    guard observedPaths.contains("Package.swift"),
          observedPaths.contains("LICENSE"),
          observedPaths.contains(
              "THIRD_PARTY_NOTICES.md"
          ),
          observedPaths.contains(
              "Sources/PrimeGPUCalibration/" +
              "PrimeGPUCalibrationMain.swift"
          ),
          observedPaths.contains(
              "Sources/PrimeCore/" +
              "PrimeNative3BProfile.swift"
          ) else {
        throw CalibrationError.incompleteSourceSnapshot
    }
    let embeddedPath =
        "Sources/PrimeGPUCalibration/" +
        "PrimeEmbeddedBuildProvenance.swift"
    guard observedPaths.contains(embeddedPath) else {
        throw CalibrationError.incompleteSourceSnapshot
    }
    let identityRecords = snapshots
        .filter {
            $0.relativePath != embeddedPath
        }
        .map {
            SourceIdentityRecord(
                relativePath: $0.relativePath,
                sha256: $0.sha256,
                byteCount: $0.byteCount
            )
        }
    let identityData = try PrimeCanonicalJSON.encode(
        identityRecords
    )
    let observedIdentity =
        PrimeSHA256.hexDigest(of: identityData)
    let embeddedIdentity =
        PrimeEmbeddedBuildProvenance
            .sourceIdentitySHA256
    guard let embeddedSnapshot =
            snapshots.first(where: {
                $0.relativePath == embeddedPath
            }),
          embeddedSnapshot.contents
            == canonicalEmbeddedProvenanceSource(
                sourceIdentitySHA256:
                    embeddedIdentity
            ) else {
        throw CalibrationError.unsafeSourceFile(
            embeddedPath
        )
    }
    guard observedIdentity == embeddedIdentity else {
        throw CalibrationError.sourceIdentityMismatch(
            expected: embeddedIdentity,
            observed: observedIdentity
        )
    }
    let buildConfiguration =
        PrimeEmbeddedBuildProvenance
            .buildConfiguration
    guard buildConfiguration == "release" else {
        throw CalibrationError.releaseBuildRequired(
            buildConfiguration
        )
    }
    return CalibrationSourceSnapshot(
        sourceIdentitySHA256: observedIdentity,
        embeddedSourceIdentitySHA256:
            embeddedIdentity,
        buildConfiguration: buildConfiguration,
        files: snapshots
    )
}

private func runningExecutableURL() throws -> URL {
    var requiredSize: UInt32 = 0
    _ = _NSGetExecutablePath(nil, &requiredSize)
    guard requiredSize > 1 else {
        throw CalibrationError.executableUnreadable(
            "<current-process>"
        )
    }
    var buffer = [CChar](
        repeating: 0,
        count: Int(requiredSize)
    )
    guard _NSGetExecutablePath(
        &buffer,
        &requiredSize
    ) == 0 else {
        throw CalibrationError.executableUnreadable(
            "<current-process>"
        )
    }
    return URL(
        fileURLWithPath: String(cString: buffer)
    ).resolvingSymlinksInPath()
}

private func runningExecutableData() throws -> Data {
    let executableURL = try runningExecutableURL()
    do {
        return try regularFileData(
            at: executableURL,
            maximumBytes: 256 * 1024 * 1024
        )
    } catch {
        throw CalibrationError.executableUnreadable(
            executableURL.path
        )
    }
}

private func verifySameExecutableSupervisorParent()
    throws
{
    var buffer = [CChar](
        repeating: 0,
        count: 4 * Int(MAXPATHLEN)
    )
    let byteCount = proc_pidpath(
        getppid(),
        &buffer,
        UInt32(buffer.count)
    )
    guard byteCount > 0 else {
        throw CalibrationError
            .supervisorParentIdentityMismatch
    }
    let parentURL = URL(
        fileURLWithPath: String(cString: buffer)
    )
    let parentData: Data
    do {
        parentData = try regularFileData(
            at: parentURL,
            maximumBytes: 256 * 1024 * 1024
        )
    } catch {
        throw CalibrationError
            .supervisorParentIdentityMismatch
    }
    let currentData = try runningExecutableData()
    guard parentData.count == currentData.count,
          PrimeSHA256.hexDigest(of: parentData)
            == PrimeSHA256.hexDigest(of: currentData) else {
        throw CalibrationError
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
        let unexpectedLease =
            try PrimeExclusiveProcessLease.acquire(
                at: leaseURL
            )
        unexpectedLease.release()
    } catch let error as PrimeMetalDeviceLeaseError {
        guard error == .busy else {
            throw CalibrationError
                .supervisorAuthorityLeaseMissing
        }
        return
    } catch {
        throw CalibrationError
            .supervisorAuthorityLeaseMissing
    }
    throw CalibrationError
        .supervisorAuthorityLeaseMissing
}

private func prepareArtifacts(
    arguments: Arguments,
    root: PrimeArtifactRoot,
    seeds: PrimeExecutionSeeds,
    plan: PrimeGPUCalibrationPlan
) throws -> PrimeExecutionArtifactBindings {
    let executableURL = try runningExecutableURL()
    let mlxDefaultMetallib =
        try PrimePinnedMLXMetallib.captureSibling(
            of: executableURL,
            into: root
        )
    for seed in [
        seeds.initialization,
        seeds.trainingSchedule,
        seeds.evaluation,
    ] {
        let relativePath =
            seed.provenance.artifactPath
        let sourceURL = arguments
            .historicalEvidenceRoot!
            .standardizedFileURL
            .appendingPathComponent(relativePath)
            .standardizedFileURL
        let historicalRootPrefix = arguments
            .historicalEvidenceRoot!
            .standardizedFileURL.path + "/"
        guard sourceURL.path.hasPrefix(
            historicalRootPrefix
        ) else {
            throw CalibrationError.unsafeSourceFile(
                sourceURL.path
            )
        }
        let data = try regularFileData(
            at: sourceURL,
            maximumBytes: 16 * 1024 * 1024
        )
        guard PrimeSHA256.hexDigest(of: data)
                == seed.provenance
                    .artifactSHA256.lowercased() else {
            throw CalibrationError.unsafeSourceFile(
                sourceURL.path
            )
        }
        _ = try root.publish(
            data,
            at: relativePath,
            purpose: .immutableData
        )
        try root.verifySeedProvenance(seed)
    }
    let executable = try root.publish(
        regularFileData(
            at: executableURL,
            maximumBytes: 256 * 1024 * 1024
        ),
        at:
            PrimeMLXRuntimeImageLayout
                .declaration
                .stagedExecutableRelativePath,
        purpose: .executable
    )
    let snapshot = try sourceSnapshot(
        at: arguments.sourceRoot!
    )
    let source = try root.publishCanonical(
        snapshot,
        at: "prime-swift-source-snapshot.v1.json"
    )
    let configuration =
        PrimeNative3BFP32ExecutionConfiguration(
            seeds: seeds,
            executable: executable,
            sourceSnapshot: source,
            mlxDefaultMetallib:
                mlxDefaultMetallib,
            calibrationPlan: plan,
            externalExecutionExclusionReason:
                PrimeSwiftExecutionBoundary
                    .strictExclusionReason
        )
    try configuration.validate()
    let configurationBinding =
        try root.publishCanonical(
            configuration,
            at:
                "prime-3b-fp32-execution-configuration.v2.json"
        )
    return PrimeExecutionArtifactBindings(
        executable: executable,
        configuration: configurationBinding,
        sourceSnapshot: source,
        mlxDefaultMetallib:
            mlxDefaultMetallib
    )
}

private func stagedExecutableURL(
    artifactRoot: PrimeArtifactRoot,
    artifacts: PrimeExecutionArtifactBindings
) throws -> URL {
    guard artifacts.executable.relativePath
            == PrimeMLXRuntimeImageLayout
                .declaration
                .stagedExecutableRelativePath,
          artifacts.executable.purpose
            == .executable else {
        throw CalibrationError.executableUnreadable(
            artifacts.executable.relativePath
        )
    }
    _ = try artifactRoot.verify(
        artifacts.executable
    )
    return artifactRoot.directoryURL
        .appendingPathComponent(
            artifacts.executable.relativePath
        )
}

private func failureReason(
    for error: Error
) -> PrimeGPUCalibrationFailureReason {
    if let calibration = error as? CalibrationError {
        switch calibration {
        case .deadlineExceeded:
            return .timeLimitObserved
        case .nonFinite:
            return .nonFinite
        case .wrongDevice,
             .invalidDeviceInfo,
             .parameterCount,
             .precision,
             .weightUpdateMissing,
             .receiptRoundTripMismatch:
            return .contractViolation
        default:
            break
        }
    }
    if error is PrimeDurableArtifactError {
        return .contractViolation
    }
    let normalized =
        String(describing: error).lowercased()
    if normalized.contains("out of memory")
        || normalized.contains("memory allocation")
        || normalized.contains("failed to allocate")
    {
        return .outOfMemory
    }
    return .executorFailure
}

private func run(
    seeds: PrimeExecutionSeeds,
    artifacts: PrimeExecutionArtifactBindings,
    plan: PrimeGPUCalibrationPlan,
    progress: GPUExecutionProgress
) throws -> PrimeGPUCalibrationReceipt {
    let device = Device.defaultDevice()
    progress.deviceDescription = device.description
    guard device.deviceType == .gpu else {
        throw CalibrationError.wrongDevice(
            device.description
        )
    }
    let deviceInfo = GPU.deviceInfo()
    if deviceInfo.architecture != "Unknown",
       !deviceInfo.architecture.isEmpty {
        progress.deviceArchitecture =
            deviceInfo.architecture
    }
    guard deviceInfo.architecture != "Unknown",
          !deviceInfo.architecture.isEmpty,
          deviceInfo.memorySize > 0,
          deviceInfo.maxRecommendedWorkingSetSize > 0,
          deviceInfo.maxBufferSize > 0 else {
        throw CalibrationError.invalidDeviceInfo(
            deviceInfo.architecture
        )
    }
    let profile = PrimeNativeProfiles.exact3B
    Memory.memoryLimit =
        plan.requestedMLXMemoryLimitBytes
    Memory.cacheLimit = plan.memoryCacheLimitBytes
    Memory.clearCache()
    guard Memory.memoryLimit
            == plan.requestedMLXMemoryLimitBytes,
          Memory.cacheLimit
            == plan.memoryCacheLimitBytes else {
        throw CalibrationError.invalidArgument(
            "MLX memory controls did not retain the frozen plan"
        )
    }
    Memory.peakMemory = 0
    let clock = ContinuousClock()
    let started = clock.now
    let requireWithinObservedLimit = {
        let elapsed = durationSeconds(
            started.duration(to: clock.now)
        )
        guard elapsed
                <= plan
                    .workerActiveTimeLimitSeconds else {
            throw CalibrationError.deadlineExceeded
        }
    }
    progress.failureStage = .modelAllocation
    progress.metalExecution = .unavailable
    let model = makeModel(
        profile: profile,
        initializationSeed:
            seeds.initializationWitness().routedValue
    )
    progress.metalExecution = .observed(true)
    progress.failureStage = .forwardBackwardUpdate
    try requireWithinObservedLimit()
    let observedCount = parameterCount(model.parameters())
    guard observedCount == profile.parameterCount else {
        throw CalibrationError.parameterCount(
            expected: profile.parameterCount,
            observed: observedCount
        )
    }
    let dtypes = parameterDTypes(model.parameters())
    guard dtypes == ["float32"] else {
        throw CalibrationError.precision(dtypes)
    }
    let expectedOptimizerStateArrayCount =
        model.trainableParameters()
            .flattened().count * 2

    let trainingInputs = deterministicInputs(
        seed:
            seeds.trainingScheduleWitness().routedValue,
        count:
            plan.optimizerSteps
            * plan.gradientAccumulationSteps,
        batchSize: plan.batchSize,
        sequenceLength: plan.sequenceLength
    )
    let evaluationInputs = deterministicInputs(
        seed: seeds.evaluationWitness().routedValue,
        count: 1,
        batchSize: plan.batchSize,
        sequenceLength: plan.sequenceLength
    )[0]
    let initialEvaluationLoss = try finiteLoss(
        model: model,
        inputs: evaluationInputs,
        label: "initial evaluation loss"
    )
    let fingerprintBefore =
        selectedParameterFingerprint(model)

    let optimizer = AdamW(
        learningRate:
            Float(plan.optimizerLearningRate),
        betas: (
            Float(plan.optimizerBeta1),
            Float(plan.optimizerBeta2)
        ),
        eps: Float(plan.optimizerEpsilon),
        weightDecay:
            Float(plan.optimizerWeightDecay)
    )
    let lossAndGradient = valueAndGrad(model: model) {
        model, arrays in
        [causalLoss(model: model, inputs: arrays[0])]
    }
    var stepLosses = [Double]()
    var firstGradientNorm = 0.0
    for step in 0 ..< plan.optimizerSteps {
        var accumulated: ModuleParameters?
        var stepLoss = 0.0
        for microbatch in
            0 ..< plan.gradientAccumulationSteps
        {
            try requireWithinObservedLimit()
            let input = trainingInputs[
                step
                    * plan.gradientAccumulationSteps
                    + microbatch
            ]
            model.train()
            let (values, gradients) =
                lossAndGradient(model, [input])
            eval(values, gradients)
            let value =
                Double(values[0].item(Float.self))
            guard value.isFinite else {
                throw CalibrationError.nonFinite(
                    "training loss"
                )
            }
            stepLoss += value
            if let existing = accumulated {
                accumulated = existing.mapValues(
                    gradients
                ) { left, right in
                    left + right!
                }
            } else {
                accumulated = gradients
            }
            guard let currentAccumulation = accumulated else {
                throw CalibrationError.nonFinite(
                    "missing accumulated gradients"
                )
            }
            eval(currentAccumulation)
            try requireWithinObservedLimit()
        }
        guard let accumulated else {
            throw CalibrationError.nonFinite(
                "empty accumulation arm"
            )
        }
        let averaged = accumulated.mapValues {
            $0 / Float(
                plan.gradientAccumulationSteps
            )
        }
        eval(averaged)
        if step == 0 {
            firstGradientNorm =
                try gradientNorm(averaged)
        }
        let (clipped, _) = clipGradNorm(
            gradients: averaged,
            maxNorm: 1
        )
        optimizer.update(
            model: model,
            gradients: clipped
        )
        eval(model, optimizer)
        try requireWithinObservedLimit()
        stepLosses.append(
            stepLoss
                / Double(
                    plan.gradientAccumulationSteps
                )
        )
    }

    let postStepCount =
        parameterCount(model.parameters())
    guard postStepCount == observedCount else {
        throw CalibrationError.parameterCount(
            expected: observedCount,
            observed: postStepCount
        )
    }
    let postStepDTypes =
        parameterDTypes(model.parameters())
    guard postStepDTypes == dtypes else {
        throw CalibrationError.precision(
            postStepDTypes
        )
    }
    let optimizerState = optimizer.innerState()
    let optimizerStateDTypes = Array(
        Set(
            optimizerState.map {
                String(describing: $0.dtype)
            }
        )
    ).sorted()
    let optimizerStateL2Norm = try arrayNorm(
        optimizerState,
        label: "optimizer state norm"
    )
    let finalEvaluationLoss = try finiteLoss(
        model: model,
        inputs: evaluationInputs,
        label: "final evaluation loss"
    )
    try requireWithinObservedLimit()
    let fingerprintAfter =
        selectedParameterFingerprint(model)
    guard fingerprintAfter != fingerprintBefore else {
        throw CalibrationError.weightUpdateMissing
    }
    let probeLogits = model(evaluationInputs, cache: nil)
    let logitsFinite = MLX.all(
        MLX.isFinite(probeLogits)
    )
    eval(logitsFinite)
    try requireWithinObservedLimit()
    guard logitsFinite.item(Bool.self) else {
        throw CalibrationError.nonFinite("forward logits")
    }
    let elapsed = durationSeconds(
        started.duration(to: clock.now)
    )
    let processedPositions = UInt64(
        plan.optimizerSteps
        * plan.batchSize
        * plan.gradientAccumulationSteps
        * plan.sequenceLength
    )
    let supervisedTargets = UInt64(
        plan.optimizerSteps
        * plan.batchSize
        * plan.gradientAccumulationSteps
        * (plan.sequenceLength - 1)
    )
    return PrimeGPUCalibrationReceipt(
        outcome: .grounded,
        claimScope:
            "allocation_forward_backward_adamw_step_only_no_language_capability",
        recordedAtUTC:
            ISO8601DateFormatter()
                .string(from: Date()),
        expectedParameterCount: profile.parameterCount,
        observedParameterCount: observedCount,
        observedParameterDTypes: dtypes,
        parameterCountMatches: true,
        allParametersFP32: true,
        seeds: seeds,
        artifacts: artifacts,
        deviceType: "gpu",
        deviceDescription: device.description,
        deviceArchitecture:
            deviceInfo.architecture,
        deviceMemoryBytes:
            UInt64(deviceInfo.memorySize),
        deviceMaxRecommendedWorkingSetBytes:
            deviceInfo.maxRecommendedWorkingSetSize,
        deviceMaxBufferBytes:
            UInt64(deviceInfo.maxBufferSize),
        batchSize: plan.batchSize,
        gradientAccumulationSteps:
            plan.gradientAccumulationSteps,
        sequenceLength: plan.sequenceLength,
        completedSteps: plan.optimizerSteps,
        processedPaddedTokenPositions:
            processedPositions,
        supervisedTargetTokenCount:
            supervisedTargets,
        mechanicsActiveElapsedSeconds: elapsed,
        peakActiveMemoryBytes:
            UInt64(max(0, Memory.peakMemory)),
        mechanics: PrimeGPUCalibrationMechanics(
            forwardLogitsFinite: true,
            initialEvaluationLoss:
                initialEvaluationLoss,
            finalEvaluationLoss:
                finalEvaluationLoss,
            stepLosses: stepLosses,
            firstGradientNorm:
                firstGradientNorm,
            selectedParameterFingerprintBefore:
                fingerprintBefore,
            selectedParameterFingerprintAfter:
                fingerprintAfter,
            optimizerImplementation:
                "MLXOptimizers.AdamW",
            optimizerPackageVersion:
                plan.optimizerPackageVersion,
            optimizerLearningRate:
                plan.optimizerLearningRate,
            optimizerBeta1:
                plan.optimizerBeta1,
            optimizerBeta2:
                plan.optimizerBeta2,
            optimizerEpsilon:
                plan.optimizerEpsilon,
            optimizerWeightDecay:
                plan.optimizerWeightDecay,
            optimizerBiasCorrectionApplied:
                plan.optimizerBiasCorrectionApplied,
            expectedOptimizerStateArrayCount:
                expectedOptimizerStateArrayCount,
            optimizerStateArrayCount:
                optimizerState.count,
            optimizerStateDTypes:
                optimizerStateDTypes,
            optimizerStateL2Norm:
                optimizerStateL2Norm,
            optimizerStepChangedWeights: true,
            optimizerStateRestoreSupported: false
        ),
        boundary: PrimeGPUCalibrationBoundary(
            externalExecutionExclusionReason:
                PrimeSwiftExecutionBoundary
                    .strictExclusionReason
        ),
        stopReason: .mechanicsCompleted,
        functionalAutoregressiveOutputCount: 0,
        longTrainingAuthorized: false,
        nextAction:
            "implement_and_verify_exact_maintained_optimizer_state_restore_before_long_resumable_training"
    )
}

private func publishFailure(
    stage: PrimeGPUCalibrationFailureStage,
    reason: PrimeGPUCalibrationFailureReason,
    detail: String,
    elapsedSeconds: PrimeObservation<Double>,
    elapsedTimeScope:
        PrimeGPUCalibrationElapsedTimeScope,
    peakActiveMemoryBytes: PrimeObservation<UInt64>,
    metalExecutionBegan: PrimeBooleanObservation,
    deviceArchitecture: PrimeObservation<String>,
    deviceDescription: PrimeObservation<String>,
    receiptPath: String,
    artifactRoot: PrimeArtifactRoot,
    seeds: PrimeExecutionSeeds,
    artifacts: PrimeExecutionArtifactBindings,
    metallibReverification:
        PrimeMetallibReverification
) throws -> PrimeArtifactBinding {
    let executableURL = try stagedExecutableURL(
        artifactRoot: artifactRoot,
        artifacts: artifacts
    )
    switch metallibReverification {
    case .currentProcess:
        try PrimePinnedMLXMetallib.reverifySibling(
            of: executableURL,
            matches: artifacts.mlxDefaultMetallib
        )
    case .stagedRuntimeImage:
        try PrimePinnedMLXMetallib
            .reverifyStagedRuntimeImage(
                of: executableURL,
                matches:
                    artifacts.mlxDefaultMetallib
            )
    }
    let failure = PrimeGPUCalibrationFailureReceipt(
        recordedAtUTC:
            ISO8601DateFormatter()
                .string(from: Date()),
        claimScope:
            "failed_exact_3b_fp32_allocation_forward_backward_adamw_update",
        seeds: seeds,
        artifacts: artifacts,
        stage: stage,
        reason: reason,
        detail: detail,
        elapsedSeconds: elapsedSeconds,
        elapsedTimeScope: elapsedTimeScope,
        peakActiveMemoryBytes:
            peakActiveMemoryBytes,
        deviceArchitecture: deviceArchitecture,
        deviceDescription: deviceDescription,
        metalExecutionBegan:
            metalExecutionBegan,
        boundary: PrimeGPUCalibrationBoundary(
            externalExecutionExclusionReason:
                PrimeSwiftExecutionBoundary
                    .strictExclusionReason
        ),
        nextAction:
            "inspect_failure_receipt_before_any_repeat_or_larger_arm"
    )
    try failure.validate(in: artifactRoot)
    let binding = try artifactRoot.publishCanonical(
        failure,
        at: receiptPath
    )
    let replayed = try artifactRoot.decodeVerified(
        PrimeGPUCalibrationFailureReceipt.self,
        binding: binding
    )
    guard replayed == failure else {
        throw CalibrationError.receiptRoundTripMismatch
    }
    return binding
}

private enum PrimeMetallibReverification {
    case currentProcess
    case stagedRuntimeImage
}

private enum VerifiedWorkerReceipt {
    case grounded(
        PrimeGPUCalibrationReceipt,
        PrimeArtifactBinding
    )
    case abstain(
        PrimeGPUCalibrationFailureReceipt,
        PrimeArtifactBinding
    )
}

private func supervisorDisposition(
    process: Process,
    hardTimeoutObserved: Bool,
    candidate: PrimeWorkerCandidateKind
) -> PrimeSupervisorDisposition {
    let terminationKind:
        PrimeWorkerTerminationKind =
            process.terminationReason == .exit
                ? .exit
                : .uncaughtSignal
    return PrimeSupervisorPolicy.disposition(
        for: PrimeSupervisorObservation(
            terminationObserved: !process.isRunning,
            hardTimeoutObserved:
                hardTimeoutObserved,
            terminationKind: terminationKind,
            terminationStatus:
                process.terminationStatus,
            candidate: candidate
        )
    )
}

private func verifyWorkerReceipt(
    artifactRoot: PrimeArtifactRoot
) throws -> VerifiedWorkerReceipt {
    let binding = try artifactRoot.bindExisting(
        at: workerCandidateReceiptPath,
        purpose: .immutableData
    )
    if let grounded = try? artifactRoot.decodeVerified(
        PrimeGPUCalibrationReceipt.self,
        binding: binding
    ) {
        try grounded.validateWorkerCandidate(
            in: artifactRoot
        )
        return .grounded(grounded, binding)
    }
    let abstain = try artifactRoot.decodeVerified(
        PrimeGPUCalibrationFailureReceipt.self,
        binding: binding
    )
    try abstain.validate(in: artifactRoot)
    return .abstain(abstain, binding)
}

private func runWorker(
    arguments: Arguments,
    artifactRoot: PrimeArtifactRoot,
    seeds: PrimeExecutionSeeds,
    artifacts: PrimeExecutionArtifactBindings,
    plan: PrimeGPUCalibrationPlan
) throws {
    let executionClock = ContinuousClock()
    let executionStarted = executionClock.now
    let progress = GPUExecutionProgress()
    let executableURL = try runningExecutableURL()
    let lease: PrimeMetalDeviceLease
    do {
        lease = try PrimeMetalDeviceLease.acquire(
            at: arguments.leaseFile!
        )
    } catch {
        let elapsed = durationSeconds(
            executionStarted.duration(
                to: executionClock.now
            )
        )
        let binding = try publishFailure(
            stage: .metalLeaseAcquisition,
            reason: .executorFailure,
            detail:
                "Metal lease acquisition failed: \(error)",
            elapsedSeconds:
                elapsed > 0
                    ? .observed(elapsed)
                    : .unavailable,
            elapsedTimeScope: .workerExecution,
            peakActiveMemoryBytes: .unavailable,
            metalExecutionBegan: .observed(false),
            deviceArchitecture: .unavailable,
            deviceDescription: .unavailable,
            receiptPath:
                workerCandidateReceiptPath,
            artifactRoot: artifactRoot,
            seeds: seeds,
            artifacts: artifacts,
            metallibReverification:
                .currentProcess
        )
        throw CalibrationError.publishedFailure(
            "Prime GPU worker published Metal-lease ABSTAIN: receipt_sha256=\(binding.sha256)"
        )
    }
    defer {
        lease.release()
    }
    let receipt: PrimeGPUCalibrationReceipt
    do {
        receipt = try Device.withDefaultDevice(
            .gpu
        ) {
            try run(
                seeds: seeds,
                artifacts: artifacts,
                plan: plan,
                progress: progress
            )
        }
        progress.failureStage =
            .metallibReverification
        try PrimePinnedMLXMetallib
            .reverifySibling(
                of: executableURL,
                matches:
                    artifacts
                        .mlxDefaultMetallib
            )
        progress.failureStage = .receiptValidation
        try receipt.validateWorkerCandidate(
            in: artifactRoot
        )
    } catch {
        let mechanicsError = error
        let reportedError: Error
        do {
            try PrimePinnedMLXMetallib
                .reverifySibling(
                    of: executableURL,
                    matches:
                        artifacts
                            .mlxDefaultMetallib
                )
            reportedError = mechanicsError
        } catch {
            progress.failureStage =
                .metallibReverification
            reportedError = error
        }
        let elapsed = durationSeconds(
            executionStarted.duration(
                to: executionClock.now
            )
        )
        let peak = Memory.peakMemory
        let binding = try publishFailure(
            stage: progress.failureStage,
            reason: failureReason(
                for: reportedError
            ),
            detail:
                String(describing: reportedError),
            elapsedSeconds:
                elapsed > 0
                    ? .observed(elapsed)
                    : .unavailable,
            elapsedTimeScope: .workerExecution,
            peakActiveMemoryBytes:
                peak > 0
                    ? .observed(UInt64(peak))
                    : .unavailable,
            metalExecutionBegan:
                progress.metalExecution,
            deviceArchitecture:
                progress.deviceArchitecture.map {
                    .observed($0)
                } ?? .unavailable,
            deviceDescription:
                progress.deviceDescription.map {
                    .observed($0)
                } ?? .unavailable,
            receiptPath:
                workerCandidateReceiptPath,
            artifactRoot: artifactRoot,
            seeds: seeds,
            artifacts: artifacts,
            metallibReverification:
                .currentProcess
        )
        throw CalibrationError.publishedFailure(
            "Prime GPU calibration ABSTAIN receipt published: reason=\(failureReason(for: error).rawValue) receipt_sha256=\(binding.sha256)"
        )
    }

    let receiptBinding =
        try artifactRoot.publishCanonical(
            receipt,
            at: workerCandidateReceiptPath
        )
    let replayed = try artifactRoot.decodeVerified(
        PrimeGPUCalibrationReceipt.self,
        binding: receiptBinding
    )
    guard replayed == receipt else {
        throw CalibrationError.receiptRoundTripMismatch
    }
    print(
        "Prime GPU worker: outcome=\(receipt.outcome.rawValue) profile=\(receipt.profile.profileID) parameters=\(receipt.observedParameterCount) peak_active_memory=\(receipt.peakActiveMemoryBytes) receipt_sha256=\(receiptBinding.sha256)"
    )
}

private func runSupervisor(
    arguments: Arguments,
    artifactRoot: PrimeArtifactRoot,
    seeds: PrimeExecutionSeeds,
    artifacts: PrimeExecutionArtifactBindings,
    plan: PrimeGPUCalibrationPlan
) throws {
    let capability =
        UUID().uuidString.lowercased()
    let capabilityData = Data(capability.utf8)
    let capabilitySHA256 =
        PrimeSHA256.hexDigest(of: capabilityData)
    let supervisorInput = Pipe()
    let process = Process()
    process.executableURL = try stagedExecutableURL(
        artifactRoot: artifactRoot,
        artifacts: artifacts
    )
    process.arguments = [
        "--artifact-root",
        arguments.artifactRoot!.path,
        "--source-root",
        arguments.sourceRoot!.path,
        "--historical-evidence-root",
        arguments.historicalEvidenceRoot!.path,
        "--lease-file",
        arguments.leaseFile!.path,
        "--receipt-path",
        arguments.receiptPath,
        "--authorize-gpu-allocation",
        "true",
        "--internal-worker",
        "true",
        "--internal-worker-capability-sha256",
        capabilitySHA256,
    ]
    process.standardInput = supervisorInput
    process.standardOutput = FileHandle.standardOutput
    process.standardError = FileHandle.standardError
    let completed = DispatchSemaphore(value: 0)
    process.terminationHandler = { _ in
        completed.signal()
    }

    let clock = ContinuousClock()
    let started = clock.now
    let terminationGraceMilliseconds = Int(
        plan.terminationGraceSeconds * 1_000
    )
    do {
        try process.run()
        try supervisorInput.fileHandleForReading.close()
        try supervisorInput.fileHandleForWriting.write(
            contentsOf: capabilityData
        )
        try supervisorInput.fileHandleForWriting.close()
    } catch {
        try? supervisorInput.fileHandleForReading.close()
        try? supervisorInput.fileHandleForWriting.close()
        if process.isRunning {
            _ = kill(process.processIdentifier, SIGKILL)
            guard completed.wait(
                timeout:
                    .now()
                    + .milliseconds(
                        terminationGraceMilliseconds
                    )
            ) == .success else {
                throw CalibrationError
                    .supervisorTerminationIncomplete(
                        "capability delivery failed and SIGKILL was not observed"
                    )
            }
        }
        let binding = try publishFailure(
            stage: .supervisorLaunch,
            reason: .executorFailure,
            detail:
                "Swift worker launch failed: \(error)",
            elapsedSeconds: .unavailable,
            elapsedTimeScope:
                .supervisorEndToEnd,
            peakActiveMemoryBytes: .unavailable,
            metalExecutionBegan: .unavailable,
            deviceArchitecture: .unavailable,
            deviceDescription: .unavailable,
            receiptPath: arguments.receiptPath,
            artifactRoot: artifactRoot,
            seeds: seeds,
            artifacts: artifacts,
            metallibReverification:
                .stagedRuntimeImage
        )
        throw CalibrationError.publishedFailure(
            "Prime GPU calibration ABSTAIN receipt published: reason=executor_failure receipt_sha256=\(binding.sha256)"
        )
    }

    let timeoutMilliseconds = Int(
        plan.supervisorEndToEndWallLimitSeconds
            * 1_000
    )
    let timedOut =
        completed.wait(
            timeout:
                .now()
                + .milliseconds(timeoutMilliseconds)
        ) == .timedOut
    var terminationObserved = !timedOut
    if timedOut {
        let escalation =
            PrimeProcessTermination
                .escalateAfterTimeout(
                    processIdentifier:
                        process.processIdentifier,
                    graceMilliseconds:
                        terminationGraceMilliseconds,
                    waitForTermination: {
                        graceMilliseconds in
                        completed.wait(
                            timeout:
                                .now()
                                + .milliseconds(
                                    graceMilliseconds
                                )
                        ) == .success
                    }
                )
        terminationObserved =
            escalation.terminationObserved
        guard terminationObserved else {
            throw CalibrationError
                .supervisorTerminationIncomplete(
                    "timeout; \(escalation.auditDetail)"
                )
        }
    }
    guard terminationObserved else {
        throw CalibrationError
            .supervisorTerminationIncomplete(
                "worker termination handler did not complete"
            )
    }
    let elapsed = durationSeconds(
        started.duration(to: clock.now)
    )

    var candidateExists = false
    do {
        try artifactRoot.requireAbsent(
            at: workerCandidateReceiptPath
        )
    } catch let error as PrimeDurableArtifactError {
        if case .conflictingArtifact = error {
            candidateExists = true
        } else {
            throw error
        }
    }

    if timedOut {
        var candidateDetail = "none"
        var candidateKind:
            PrimeWorkerCandidateKind =
                candidateExists ? .invalid : .missing
        if candidateExists,
           let verified = try? verifyWorkerReceipt(
               artifactRoot: artifactRoot
           ) {
            switch verified {
            case let .grounded(_, binding):
                candidateKind = .grounded
                candidateDetail = binding.sha256
            case let .abstain(_, binding):
                candidateKind = .abstain
                candidateDetail = binding.sha256
            }
        }
        guard supervisorDisposition(
            process: process,
            hardTimeoutObserved: true,
            candidate: candidateKind
        ) == .publishTimeLimitAbstain else {
            throw CalibrationError
                .supervisorTerminationIncomplete(
                    "timeout adjudication did not select the time-limit ABSTAIN"
                )
        }
        let binding = try publishFailure(
            stage: .workerTermination,
            reason: .timeLimitObserved,
            detail:
                "Swift supervisor end-to-end deadline fired; worker_candidate_sha256=\(candidateDetail)",
            elapsedSeconds: .observed(elapsed),
            elapsedTimeScope:
                .supervisorEndToEnd,
            peakActiveMemoryBytes: .unavailable,
            metalExecutionBegan: .unavailable,
            deviceArchitecture: .unavailable,
            deviceDescription: .unavailable,
            receiptPath: arguments.receiptPath,
            artifactRoot: artifactRoot,
            seeds: seeds,
            artifacts: artifacts,
            metallibReverification:
                .stagedRuntimeImage
        )
        throw CalibrationError.publishedFailure(
            "Prime GPU supervisor published ABSTAIN after hard timeout: receipt_sha256=\(binding.sha256)"
        )
    }

    if candidateExists {
        do {
            switch try verifyWorkerReceipt(
                artifactRoot: artifactRoot
            ) {
            case let .grounded(receipt, candidateBinding):
                guard supervisorDisposition(
                    process: process,
                    hardTimeoutObserved: false,
                    candidate: .grounded
                ) == .promoteGrounded else {
                    let binding = try publishFailure(
                        stage: .workerTermination,
                        reason: .executorFailure,
                        detail:
                            "grounded worker candidate rejected after abnormal termination: reason=\(process.terminationReason.rawValue) status=\(process.terminationStatus) worker_candidate_sha256=\(candidateBinding.sha256)",
                        elapsedSeconds:
                            .observed(elapsed),
                        elapsedTimeScope:
                            .supervisorEndToEnd,
                        peakActiveMemoryBytes:
                            .observed(
                                receipt
                                    .peakActiveMemoryBytes
                            ),
                        metalExecutionBegan:
                            .observed(true),
                        deviceArchitecture:
                            .observed(
                                receipt
                                    .deviceArchitecture
                            ),
                        deviceDescription:
                            .observed(
                                receipt
                                    .deviceDescription
                            ),
                        receiptPath:
                            arguments.receiptPath,
                        artifactRoot: artifactRoot,
                        seeds: seeds,
                        artifacts: artifacts,
                        metallibReverification:
                            .stagedRuntimeImage
                    )
                    throw CalibrationError.publishedFailure(
                        "Prime GPU supervisor published ABSTAIN after grounded-candidate termination divergence: receipt_sha256=\(binding.sha256)"
                    )
                }
                let attestation =
                    PrimeGPUSupervisorAttestation(
                        workerCandidate:
                            candidateBinding,
                        supervisorEndToEndWallSeconds:
                            elapsed,
                        workerTerminationReason:
                            .exit,
                        workerTerminationStatus:
                            process.terminationStatus,
                        hardTimeoutObserved: false,
                        capabilityVerified: true,
                        runAuthorityLeaseHeld: true
                    )
                try PrimePinnedMLXMetallib
                    .reverifyStagedRuntimeImage(
                        of: try stagedExecutableURL(
                            artifactRoot:
                                artifactRoot,
                            artifacts: artifacts
                        ),
                        matches:
                            artifacts
                                .mlxDefaultMetallib
                    )
                let finalReceipt = receipt.finalized(
                    with: attestation
                )
                try finalReceipt.validate(
                    in: artifactRoot
                )
                let finalBinding =
                    try artifactRoot.publishCanonical(
                        finalReceipt,
                        at: arguments.receiptPath
                    )
                let replayed =
                    try artifactRoot.decodeVerified(
                        PrimeGPUCalibrationReceipt.self,
                        binding: finalBinding
                    )
                try replayed.validate(in: artifactRoot)
                guard replayed == finalReceipt else {
                    throw CalibrationError
                        .receiptRoundTripMismatch
                }
                print(
                    "Prime GPU supervisor: verified outcome=\(finalReceipt.outcome.rawValue) architecture=\(finalReceipt.deviceArchitecture) worker_candidate_sha256=\(candidateBinding.sha256) final_receipt_sha256=\(finalBinding.sha256)"
                )
                return
            case let .abstain(receipt, candidateBinding):
                guard supervisorDisposition(
                    process: process,
                    hardTimeoutObserved: false,
                    candidate: .abstain
                ) == .publishWorkerAbstain else {
                    throw CalibrationError
                        .supervisorTerminationIncomplete(
                            "worker ABSTAIN adjudication diverged"
                        )
                }
                let binding = try publishFailure(
                    stage: receipt.stage,
                    reason: receipt.reason,
                    detail:
                        "\(receipt.detail); worker termination reason=\(process.terminationReason.rawValue) status=\(process.terminationStatus) worker_candidate_sha256=\(candidateBinding.sha256)",
                    elapsedSeconds: .observed(elapsed),
                    elapsedTimeScope:
                        .supervisorEndToEnd,
                    peakActiveMemoryBytes:
                        receipt.peakActiveMemoryBytes,
                    metalExecutionBegan:
                        receipt.metalExecutionBegan,
                    deviceArchitecture:
                        receipt.deviceArchitecture,
                    deviceDescription:
                        receipt.deviceDescription,
                    receiptPath: arguments.receiptPath,
                    artifactRoot: artifactRoot,
                    seeds: seeds,
                    artifacts: artifacts,
                    metallibReverification:
                        .stagedRuntimeImage
                )
                throw CalibrationError.publishedFailure(
                    "Prime GPU supervisor: verified worker ABSTAIN and published final ABSTAIN reason=\(receipt.reason.rawValue) receipt_sha256=\(binding.sha256)"
                )
            }
        } catch let error as CalibrationError {
            throw error
        } catch {
            guard supervisorDisposition(
                process: process,
                hardTimeoutObserved: false,
                candidate: .invalid
            ) == .publishContractAbstain else {
                throw CalibrationError
                    .supervisorTerminationIncomplete(
                        "invalid-candidate adjudication diverged"
                    )
            }
            let binding = try publishFailure(
                stage: .receiptValidation,
                reason: .contractViolation,
                detail:
                    "worker candidate verification failed: \(error)",
                elapsedSeconds: .observed(elapsed),
                elapsedTimeScope:
                    .supervisorEndToEnd,
                peakActiveMemoryBytes: .unavailable,
                metalExecutionBegan: .unavailable,
                deviceArchitecture: .unavailable,
                deviceDescription: .unavailable,
                receiptPath: arguments.receiptPath,
                artifactRoot: artifactRoot,
                seeds: seeds,
                artifacts: artifacts,
                metallibReverification:
                    .stagedRuntimeImage
            )
            throw CalibrationError.publishedFailure(
                "Prime GPU supervisor published ABSTAIN after invalid worker candidate: receipt_sha256=\(binding.sha256)"
            )
        }
    }

    let detail =
        "Swift worker terminated without a receipt: " +
        "reason=\(process.terminationReason.rawValue) " +
        "status=\(process.terminationStatus)"
    guard supervisorDisposition(
        process: process,
        hardTimeoutObserved: false,
        candidate: .missing
    ) == .publishExecutorAbstain else {
        throw CalibrationError
            .supervisorTerminationIncomplete(
                "missing-candidate adjudication diverged"
            )
    }
    let binding = try publishFailure(
        stage: .workerTermination,
        reason: .executorFailure,
        detail: detail,
        elapsedSeconds:
            elapsed > 0
                ? .observed(elapsed)
                : .unavailable,
        elapsedTimeScope:
            .supervisorEndToEnd,
        peakActiveMemoryBytes: .unavailable,
        metalExecutionBegan: .unavailable,
        deviceArchitecture: .unavailable,
        deviceDescription: .unavailable,
        receiptPath: arguments.receiptPath,
        artifactRoot: artifactRoot,
        seeds: seeds,
        artifacts: artifacts,
        metallibReverification:
            .stagedRuntimeImage
    )
    throw CalibrationError.publishedFailure(
        "Prime GPU supervisor published ABSTAIN after worker termination without candidate: receipt_sha256=\(binding.sha256)"
    )
}

@main
enum PrimeGPUCalibrationCLI {
    static func main() {
        do {
            let arguments = try parseArguments()
            if arguments.internalWorker {
                try verifyInheritedSupervisorCapability(
                    expectedSHA256:
                        arguments
                            .internalWorkerCapabilitySHA256!
                )
            }
            let artifactRoot = try PrimeArtifactRoot(
                directoryURL: arguments.artifactRoot!
            )
            let supervisorLease:
                PrimeExclusiveProcessLease?
            if arguments.internalWorker {
                try verifySameExecutableSupervisorParent()
                try verifySupervisorAuthorityLeaseHeld(
                    artifactRootURL:
                        arguments.artifactRoot!
                )
                supervisorLease = nil
            } else {
                supervisorLease =
                    try PrimeExclusiveProcessLease.acquire(
                        at:
                            arguments.artifactRoot!
                            .appendingPathComponent(
                                supervisorAuthorityLeaseName
                            )
                    )
            }
            defer {
                supervisorLease?.release()
            }
            try artifactRoot.requireAbsent(
                at: arguments.receiptPath
            )
            try artifactRoot.ensurePrivateDirectory(
                at: "content-staging"
            )
            try artifactRoot.requireAbsent(
                at: workerCandidateReceiptPath
            )
            let seeds = try PrimeExecutionSeeds
                .initialFactorizedCalibrationTriple()
            let plan =
                PrimeGPUCalibrationPlan
                    .initialAllocationProbe
            let artifacts = try prepareArtifacts(
                arguments: arguments,
                root: artifactRoot,
                seeds: seeds,
                plan: plan
            )
            if arguments.internalWorker {
                try runWorker(
                    arguments: arguments,
                    artifactRoot: artifactRoot,
                    seeds: seeds,
                    artifacts: artifacts,
                    plan: plan
                )
            } else {
                try runSupervisor(
                    arguments: arguments,
                    artifactRoot: artifactRoot,
                    seeds: seeds,
                    artifacts: artifacts,
                    plan: plan
                )
            }
        } catch {
            fputs(
                "PrimeGPUCalibration: \(error)\n",
                stderr
            )
            Foundation.exit(1)
        }
    }
}
