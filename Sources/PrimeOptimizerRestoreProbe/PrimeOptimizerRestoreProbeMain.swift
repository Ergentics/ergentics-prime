import Darwin
import Foundation
import MLX
import MLXNN
import MLXOptimizers
import PrimeCore

private enum ProbeError: Error, CustomStringConvertible {
    case invalidArgument(String)
    case executableUnreadable
    case executableIdentityMismatch
    case dependencyPinMismatch
    case dependencySourceMismatch(String)
    case childFailed(role: String, status: Int32)
    case childTimedOut(String)
    case nonCPUExecution(String)
    case missingTensor(String)
    case tensorMismatch(String)
    case processIdentityCollision
    case receiptRoundTripMismatch

    var description: String {
        switch self {
        case let .invalidArgument(detail):
            "invalid argument: \(detail)"
        case .executableUnreadable:
            "the running executable could not be read"
        case .executableIdentityMismatch:
            "the child executable did not match the published image"
        case .dependencyPinMismatch:
            "Package.resolved did not contain the frozen mlx-swift pin"
        case let .dependencySourceMismatch(path):
            "frozen dependency source mismatch: \(path)"
        case let .childFailed(role, status):
            "\(role) child exited with status \(status)"
        case let .childTimedOut(role):
            "\(role) child exceeded its 30-second mechanics limit"
        case let .nonCPUExecution(detail):
            "CPU-only execution admission failed: \(detail)"
        case let .missingTensor(key):
            "missing tensor: \(key)"
        case let .tensorMismatch(key):
            "tensor contract mismatch: \(key)"
        case .processIdentityCollision:
            "writer and verifier must be distinct processes"
        case .receiptRoundTripMismatch:
            "published receipt did not round-trip exactly"
        }
    }
}

private enum ProbeRole: String {
    case parent
    case writer
    case verifier
}

private struct Arguments {
    var artifactRoot: URL?
    var sourceRoot: URL?
    var role: ProbeRole = .parent
    var publishedExecutableSHA256: String?
    var receiptPath =
        "prime-optimizer-restore-receipt.v1.json"
}

private struct FrozenSourceFile:
    Codable,
    Equatable
{
    let relativePath: String
    let sha256: String

    private enum CodingKeys: String, CodingKey {
        case relativePath = "relative_path"
        case sha256
    }
}

private struct FrozenAPIEvidence:
    Codable,
    Equatable
{
    let schemaVersion = 1
    let artifactKind =
        "ergentics_prime_optimizer_restore_api_evidence"
    let packageIdentity = "mlx-swift"
    let packageVersion = "0.31.3"
    let packageRevision =
        "61b9e011e09a62b489f6bd647958f1555bdf2896"
    let sourceFiles: [FrozenSourceFile]

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case artifactKind = "artifact_kind"
        case packageIdentity = "package_identity"
        case packageVersion = "package_version"
        case packageRevision = "package_revision"
        case sourceFiles = "source_files"
    }
}

private struct ResolvedFile: Decodable {
    struct Pin: Decodable {
        struct State: Decodable {
            let revision: String
            let version: String?
        }

        let identity: String
        let state: State
    }

    let pins: [Pin]
}

private let stagedDirectory = "content-staging"
private let stagedExecutablePath =
    PrimeMLXRuntimeImageLayout.optimizerRestoreProbe
        .stagedExecutableRelativePath
private let runtimeBindingPath =
    "\(stagedDirectory)/optimizer-restore-runtime-image.v1.json"
private let apiEvidencePath =
    "\(stagedDirectory)/optimizer-restore-api-evidence.v1.json"
private let primeSourceSnapshotPath =
    "\(stagedDirectory)/prime-swift-source-snapshot.v1.json"
private let modelCheckpointPath =
    "\(stagedDirectory)/model-after-step-1.safetensors"
private let optimizerCheckpointPath =
    "\(stagedDirectory)/optimizer-state-after-step-1.safetensors"
private let writerRecordPath =
    "\(stagedDirectory)/optimizer-restore-writer.v1.json"
private let verifierRecordPath =
    "\(stagedDirectory)/optimizer-restore-verifier.v1.json"
private let executionTranscriptPath =
    "\(stagedDirectory)/optimizer-restore-execution-transcript.v1.json"
private let abstainExitStatus: Int32 = 2

private let modelCheckpointMetadata = [
    "artifact_kind":
        "ergentics_prime_model_after_step_1",
    "schema_version": "1",
]
private let optimizerCheckpointMetadata = [
    "artifact_kind":
        "ergentics_prime_anonymous_optimizer_state_after_step_1",
    "schema_version": "1",
]

private let frozenSourceFiles: [FrozenSourceFile] = [
    FrozenSourceFile(
        relativePath:
            "Source/MLXOptimizers/Optimizers.swift",
        sha256:
            "f2a36919b73cbec5f3fac6ea23022832474a7aca04b7bfc4ce63bd1f201f6e2d"
    ),
    FrozenSourceFile(
        relativePath: "Source/MLX/Protocols.swift",
        sha256:
            "1695559788cb24750c215ec0a3dd403464fb32d1a3ac3a35385fdba8bdc8823c"
    ),
    FrozenSourceFile(
        relativePath: "Source/MLX/MLXArray.swift",
        sha256:
            "0cd516b95d5d75840978e265d3069709a8f557de96264df8605f246d91b0126c"
    ),
    FrozenSourceFile(
        relativePath: "Source/MLX/Nested.swift",
        sha256:
            "29523d272fb85b6c535045fab0444c899acff508c9989dba6eea110e7ec69e22"
    ),
    FrozenSourceFile(
        relativePath: "Source/MLX/IO.swift",
        sha256:
            "2ebd6414fd168b9457b8d359cf4df8525dafc3328c23d753740f264b7610975d"
    ),
    FrozenSourceFile(
        relativePath: "Source/MLXNN/Module.swift",
        sha256:
            "bf3dd13a385f91cb808a9f21d5c84c6faac7e68ec922c45ea22ed2728374ae3b"
    ),
    FrozenSourceFile(
        relativePath: "LICENSE",
        sha256:
            "44326a4ea062241ae6fc26ee2ec90bdc81af7eb7b9d3966181b733fa69d42057"
    ),
]

private func parseArguments() throws -> Arguments {
    var result = Arguments()
    var values = Array(CommandLine.arguments.dropFirst())
    while values.isEmpty == false {
        let key = values.removeFirst()
        guard values.isEmpty == false else {
            throw ProbeError.invalidArgument(
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
        case "--internal-role":
            guard let role = ProbeRole(rawValue: value) else {
                throw ProbeError.invalidArgument(key)
            }
            result.role = role
        case "--published-executable-sha256":
            result.publishedExecutableSHA256 = value
        case "--receipt-path":
            result.receiptPath = value
        default:
            throw ProbeError.invalidArgument(key)
        }
    }
    guard result.artifactRoot != nil else {
        throw ProbeError.invalidArgument(
            "--artifact-root is required"
        )
    }
    guard result.sourceRoot != nil else {
        throw ProbeError.invalidArgument(
            "--source-root is required"
        )
    }
    guard !result.receiptPath.isEmpty,
          !result.receiptPath.contains("/"),
          result.receiptPath != ".",
          result.receiptPath != ".." else {
        throw ProbeError.invalidArgument(
            "--receipt-path must be one safe filename"
        )
    }
    if result.role == .parent {
        guard result.publishedExecutableSHA256 == nil else {
            throw ProbeError.invalidArgument(
                "parent cannot accept child identity"
            )
        }
    } else {
        guard let digest =
                result.publishedExecutableSHA256,
              digest.count == 64 else {
            throw ProbeError.invalidArgument(
                "child requires published executable identity"
            )
        }
    }
    return result
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
    let data = try Data(
        contentsOf: runningExecutableURL(),
        options: [.mappedIfSafe]
    )
    guard data.count <= 256 * 1024 * 1024 else {
        throw ProbeError.executableUnreadable
    }
    return data
}

private func verifyChildExecutableIdentity(
    expected: String
) throws {
    guard PrimeSHA256.hexDigest(
        of: try runningExecutableData()
    ) == expected else {
        throw ProbeError.executableIdentityMismatch
    }
}

private func loadRuntimeBinding(
    root: PrimeArtifactRoot
) throws -> PrimePinnedMLXMetallibBinding {
    let manifest = try root.bindExisting(
        at: runtimeBindingPath,
        purpose: .immutableData
    )
    let binding = try root.decodeVerified(
        PrimePinnedMLXMetallibBinding.self,
        binding: manifest
    )
    _ = try root.verify(binding.artifact)
    _ = try root.verify(
        binding.infoPlistArtifact
    )
    return binding
}

private func reverifyCurrentRuntime(
    binding: PrimePinnedMLXMetallibBinding
) throws {
    try PrimePinnedMLXMetallib.reverifySibling(
        of: runningExecutableURL(),
        matches: binding,
        runtimeRole: .optimizerRestoreProbe
    )
}

private func verifyFrozenDependency(
    sourceRoot: URL
) throws -> FrozenAPIEvidence {
    let resolvedURL = sourceRoot.appendingPathComponent(
        "Package.resolved"
    )
    let resolved = try JSONDecoder().decode(
        ResolvedFile.self,
        from: Data(contentsOf: resolvedURL)
    )
    guard resolved.pins.contains(where: {
        $0.identity == "mlx-swift"
            && $0.state.version == "0.31.3"
            && $0.state.revision
                == "61b9e011e09a62b489f6bd647958f1555bdf2896"
    }) else {
        throw ProbeError.dependencyPinMismatch
    }

    let checkout = sourceRoot
        .appendingPathComponent(".build")
        .appendingPathComponent("checkouts")
        .appendingPathComponent("mlx-swift")
    for file in frozenSourceFiles {
        let data = try Data(
            contentsOf:
                checkout.appendingPathComponent(
                    file.relativePath
                )
        )
        guard PrimeSHA256.hexDigest(of: data)
                == file.sha256 else {
            throw ProbeError.dependencySourceMismatch(
                file.relativePath
            )
        }
    }
    return FrozenAPIEvidence(
        sourceFiles: frozenSourceFiles
    )
}

private func publishFrozenSourceEvidence(
    sourceRoot: URL,
    root: PrimeArtifactRoot
) throws -> PrimeArtifactBinding {
    let evidence =
        PrimeOptimizerRestoreSourceEvidence
            .frozenMLXSwift0313
    try evidence.validate()
    for directory in [
        "evidence",
        "evidence/mlx-swift",
        "evidence/mlx-swift/Source",
        "evidence/mlx-swift/Source/MLX",
        "evidence/mlx-swift/Source/MLXNN",
        "evidence/mlx-swift/Source/MLXOptimizers",
    ] {
        try root.ensurePrivateDirectory(at: directory)
    }

    let checkout = sourceRoot
        .appendingPathComponent(".build")
        .appendingPathComponent("checkouts")
        .appendingPathComponent("mlx-swift")
    let publications: [
        (
            sourceURL: URL,
            binding: PrimeArtifactBinding
        )
    ] = [
        (
            sourceRoot.appendingPathComponent(
                "Package.resolved"
            ),
            evidence.dependencyResolution
        ),
        (
            checkout.appendingPathComponent("LICENSE"),
            evidence.licenseArtifact
        ),
        (
            checkout.appendingPathComponent(
                evidence.optimizer
                    .repositoryRelativePath
            ),
            evidence.optimizer.sourceArtifact
        ),
        (
            checkout.appendingPathComponent(
                evidence.updatableProtocol
                    .repositoryRelativePath
            ),
            evidence.updatableProtocol.sourceArtifact
        ),
        (
            checkout.appendingPathComponent(
                evidence.arrayMutation
                    .repositoryRelativePath
            ),
            evidence.arrayMutation.sourceArtifact
        ),
        (
            checkout.appendingPathComponent(
                evidence.nestedStructure
                    .repositoryRelativePath
            ),
            evidence.nestedStructure.sourceArtifact
        ),
        (
            checkout.appendingPathComponent(
                evidence.tensorIO
                    .repositoryRelativePath
            ),
            evidence.tensorIO.sourceArtifact
        ),
        (
            checkout.appendingPathComponent(
                evidence.moduleRestore
                    .repositoryRelativePath
            ),
            evidence.moduleRestore.sourceArtifact
        ),
    ]
    for publication in publications {
        let observed = try root.publish(
            Data(contentsOf: publication.sourceURL),
            at: publication.binding.relativePath,
            purpose: .immutableData
        )
        guard observed == publication.binding else {
            throw ProbeError.dependencySourceMismatch(
                publication.binding.relativePath
            )
        }
    }
    return try root.publishCanonical(
        evidence,
        at: apiEvidencePath
    )
}

private func deterministicModel() -> Linear {
    Linear(
        weight: MLXArray(
            [
                Float(0.125), -0.25,
                -0.75, 0.375,
            ],
            [2, 2]
        ),
        bias: MLXArray(
            [Float(0.03125), -0.15625],
            [2]
        )
    )
}

private func differentDeterministicModel() -> Linear {
    Linear(
        weight: MLXArray(
            [
                Float(-1), -1,
                -1, -1,
            ],
            [2, 2]
        ),
        bias: MLXArray(
            [Float(1), 1],
            [2]
        )
    )
}

private func trainingInputs() -> (
    inputs: MLXArray,
    targets: MLXArray
) {
    (
        MLXArray(
            [
                Float(0.25), -0.5,
                1.0, 0.125,
            ],
            [2, 2]
        ),
        MLXArray(
            [
                Float(0.5), -0.125,
                0.25, 0.75,
            ],
            [2, 2]
        )
    )
}

private func requireCPUDefault() throws
    -> PrimeOptimizerRestoreCPUExecutionObservations
{
    let device = Device.defaultDevice()
    let streamDescription =
        StreamOrDevice.default.description
    let normalizedStream =
        streamDescription.lowercased()
    guard device.deviceType == .cpu,
          normalizedStream.contains("cpu") else {
        throw ProbeError.nonCPUExecution(
            "device=\(device) stream=\(streamDescription)"
        )
    }
    let observation =
        PrimeOptimizerRestoreCPUExecutionObservations(
            defaultDeviceType: .observed("cpu"),
            defaultStreamDescription:
                .observed(streamDescription),
            defaultStreamWasCPU: .observed(true)
        )
    try observation.validate()
    return observation
}

private func exactRecord(
    role: PrimeOptimizerTensorRole,
    key: String,
    array: MLXArray
) throws -> PrimeOptimizerTensorCatalogEntry {
    try checkedEval(array)
    guard array.dtype == .float32 else {
        throw ProbeError.tensorMismatch(key)
    }
    let logical = array.asData(access: .copy)
    guard logical.shape == array.shape,
          logical.dType == array.dtype,
          logical.data.count == array.size * 4 else {
        throw ProbeError.tensorMismatch(key)
    }
    return PrimeOptimizerTensorCatalogEntry(
        role: role,
        key: key,
        dtype: "float32",
        shape: array.shape,
        nbytes: UInt64(logical.data.count),
        logicalSHA256:
            PrimeSHA256.hexDigest(of: logical.data)
    )
}

private func requireExact(
    array: MLXArray,
    record: PrimeOptimizerTensorCatalogEntry
) throws {
    let observed = try exactRecord(
        role: record.role,
        key: record.key,
        array: array
    )
    guard observed == record else {
        throw ProbeError.tensorMismatch(record.key)
    }
}

private func withTemporaryDirectory<Result>(
    _ body: (URL) throws -> Result
) throws -> Result {
    let directory = FileManager.default
        .temporaryDirectory
        .appendingPathComponent(
            "PrimeOptimizerRestoreProbe-\(UUID().uuidString)",
            isDirectory: true
        )
    try FileManager.default.createDirectory(
        at: directory,
        withIntermediateDirectories: false,
        attributes: [
            .posixPermissions: NSNumber(value: 0o700),
        ]
    )
    defer {
        try? FileManager.default.removeItem(at: directory)
    }
    return try body(directory)
}

private func writeCheckpoint(
    arrays: [String: MLXArray],
    metadata: [String: String],
    temporaryName: String,
    publishedPath: String,
    root: PrimeArtifactRoot
) throws -> PrimeArtifactBinding {
    try withTemporaryDirectory { directory in
        let url = directory.appendingPathComponent(
            temporaryName
        )
        try MLX.save(
            arrays: arrays,
            metadata: metadata,
            url: url,
            stream: .cpu
        )
        return try root.publish(
            Data(contentsOf: url),
            at: publishedPath,
            purpose: .immutableData
        )
    }
}

private func runWriter(
    arguments: Arguments,
    root: PrimeArtifactRoot
) throws {
    let executableSHA256 =
        arguments.publishedExecutableSHA256!
    try verifyChildExecutableIdentity(
        expected: executableSHA256
    )
    let executable = try root.bindExisting(
        at: stagedExecutablePath,
        purpose: .executable,
        maximumByteCount: 256 * 1024 * 1024
    )
    guard executable.sha256
            == executableSHA256 else {
        throw ProbeError.executableIdentityMismatch
    }
    _ = try verifyFrozenDependency(
        sourceRoot: arguments.sourceRoot!
    )
    let runtimeBinding =
        try loadRuntimeBinding(root: root)
    try reverifyCurrentRuntime(
        binding: runtimeBinding
    )

    let record = try Device.withDefaultDevice(.cpu) {
        let cpuExecution =
            try requireCPUDefault()
        let model = deterministicModel()
        let batch = trainingInputs()
        let optimizer = AdamW(
            learningRate: 0.0001,
            betas: (0.9, 0.999),
            eps: 1e-8,
            weightDecay: 0.01
        )
        let lossAndGradient = valueAndGrad(
            model: model
        ) { model, inputs, targets in
            mean(
                square(
                    model(inputs) - targets
                )
            )
        }
        let (loss, gradients) = lossAndGradient(
            model,
            batch.inputs,
            batch.targets
        )
        optimizer.update(
            model: model,
            gradients: gradients
        )
        try checkedEval(
            [loss]
                + model.parameters().flattenedValues()
                + optimizer.innerState()
        )

        let modelPairs = model.parameters()
            .flattened()
            .sorted { $0.0 < $1.0 }
        let modelArrays = Dictionary(
            uniqueKeysWithValues: modelPairs
        )
        let orderedState = optimizer.innerState()
        let stateArrays = Dictionary(
            uniqueKeysWithValues:
                orderedState.enumerated().map {
                    index, array in
                    (
                        String(
                            format: "slot_%04d",
                            index
                        ),
                        array
                    )
                }
        )
        guard modelArrays.keys.sorted()
                == ["bias", "weight"],
              orderedState.count
                == modelPairs.count * 2 else {
            throw ProbeError.tensorMismatch(
                "writer tensor topology"
            )
        }

        var catalog =
            [PrimeOptimizerTensorCatalogEntry]()
        for (
            parameterIndex,
            (key, parameter)
        ) in modelPairs.enumerated() {
            catalog.append(
                try exactRecord(
                    role: .modelParameter,
                    key: key,
                    array: parameter
                )
            )
            catalog.append(
                try exactRecord(
                    role: .adamFirstMoment,
                    key: key,
                    array:
                        orderedState[
                            parameterIndex * 2
                        ]
                )
            )
            catalog.append(
                try exactRecord(
                    role: .adamSecondMoment,
                    key: key,
                    array:
                        orderedState[
                            parameterIndex * 2 + 1
                        ]
                )
            )
        }

        let modelBinding = try writeCheckpoint(
            arrays: modelArrays,
            metadata: modelCheckpointMetadata,
            temporaryName:
                "model-after-step-1.safetensors",
            publishedPath: modelCheckpointPath,
            root: root
        )
        let optimizerBinding = try writeCheckpoint(
            arrays: stateArrays,
            metadata: optimizerCheckpointMetadata,
            temporaryName:
                "optimizer-state-after-step-1.safetensors",
            publishedPath: optimizerCheckpointPath,
            root: root
        )
        return PrimeOptimizerRestoreWriterRecord(
            processIdentifier: getpid(),
            executable: executable,
            cpuExecution: cpuExecution,
            modelCheckpoint: modelBinding,
            optimizerStateCheckpoint:
                optimizerBinding,
            tensorCatalog: catalog
        )
    }
    try record.validate()
    try reverifyCurrentRuntime(
        binding: runtimeBinding
    )
    _ = try root.publishCanonical(
        record,
        at: writerRecordPath
    )
}

private func loadPublishedArrays(
    binding: PrimeArtifactBinding,
    root: PrimeArtifactRoot,
    temporaryName: String
) throws -> (
    arrays: [String: MLXArray],
    metadata: [String: String]
) {
    try withTemporaryDirectory { directory in
        let url = directory.appendingPathComponent(
            temporaryName
        )
        let data = try root.readVerified(
            binding,
            maximumByteCount: 64 * 1024 * 1024
        )
        try data.write(
            to: url,
            options: [.atomic, .completeFileProtection]
        )
        return try MLX.loadArraysAndMetadata(
            url: url,
            stream: .cpu
        )
    }
}

private func runVerifier(
    arguments: Arguments,
    root: PrimeArtifactRoot
) throws {
    let executableSHA256 =
        arguments.publishedExecutableSHA256!
    try verifyChildExecutableIdentity(
        expected: executableSHA256
    )
    let executable = try root.bindExisting(
        at: stagedExecutablePath,
        purpose: .executable,
        maximumByteCount: 256 * 1024 * 1024
    )
    guard executable.sha256
            == executableSHA256 else {
        throw ProbeError.executableIdentityMismatch
    }
    _ = try verifyFrozenDependency(
        sourceRoot: arguments.sourceRoot!
    )
    let runtimeBinding =
        try loadRuntimeBinding(root: root)
    try reverifyCurrentRuntime(
        binding: runtimeBinding
    )

    let writerBinding = try root.bindExisting(
        at: writerRecordPath,
        purpose: .immutableData
    )
    let writer = try root.decodeVerified(
        PrimeOptimizerRestoreWriterRecord.self,
        binding: writerBinding
    )
    try writer.validate()
    guard writer.executable
            == executable else {
        throw ProbeError.executableIdentityMismatch
    }
    guard writer.processIdentifier != getpid() else {
        throw ProbeError.processIdentityCollision
    }

    let record = try Device.withDefaultDevice(.cpu) {
        let cpuExecution =
            try requireCPUDefault()
        let loadedModel = try loadPublishedArrays(
            binding: writer.modelCheckpoint,
            root: root,
            temporaryName:
                "model-after-step-1.safetensors"
        )
        let loadedOptimizer = try loadPublishedArrays(
            binding: writer.optimizerStateCheckpoint,
            root: root,
            temporaryName:
                "optimizer-state-after-step-1.safetensors"
        )
        guard loadedModel.metadata
                == modelCheckpointMetadata,
              loadedOptimizer.metadata
                == optimizerCheckpointMetadata else {
            throw ProbeError.tensorMismatch(
                "checkpoint metadata"
            )
        }
        let modelArrays = loadedModel.arrays
        let optimizerArrays =
            loadedOptimizer.arrays
        try checkedEval(
            Array(modelArrays.values)
                + Array(optimizerArrays.values)
        )

        let modelRecords = writer.tensorCatalog.filter {
            $0.role == .modelParameter
        }
        let optimizerRecords =
            writer.tensorCatalog.filter {
                $0.role != .modelParameter
            }
        let expectedOptimizerSlots =
            (0 ..< optimizerRecords.count).map {
                String(
                    format: "slot_%04d",
                    $0
                )
            }
        guard Set(modelArrays.keys)
                == Set(modelRecords.map(\.key)),
              optimizerArrays.keys.sorted()
                == expectedOptimizerSlots else {
            throw ProbeError.tensorMismatch(
                "loaded tensor keys"
            )
        }
        for record in modelRecords {
            guard let array = modelArrays[record.key] else {
                throw ProbeError.missingTensor(record.key)
            }
            try requireExact(
                array: array,
                record: record
            )
        }
        for (index, record) in
            optimizerRecords.enumerated()
        {
            let slot = String(
                format: "slot_%04d",
                index
            )
            guard let array =
                    optimizerArrays[slot] else {
                throw ProbeError.missingTensor(slot)
            }
            try requireExact(
                array: array,
                record: record
            )
        }

        guard modelArrays["weight"]?.dtype == .float32,
              modelArrays["weight"]?.shape == [2, 2],
              modelArrays["bias"]?.dtype == .float32,
              modelArrays["bias"]?.shape == [2] else {
            throw ProbeError.tensorMismatch(
                "model restore preflight"
            )
        }
        let restoredModel =
            differentDeterministicModel()
        let parameters = ModuleParameters.unflattened(
            modelArrays.map { ($0.key, $0.value) }
        )
        try restoredModel.update(
            parameters: parameters,
            verify: .all
        )
        try checkedEval(
            restoredModel.parameters()
                .flattenedValues()
        )
        let restored = Dictionary(
            uniqueKeysWithValues:
                restoredModel.parameters().flattened()
        )
        for record in modelRecords {
            guard let array = restored[record.key] else {
                throw ProbeError.missingTensor(record.key)
            }
            try requireExact(
                array: array,
                record: record
            )
        }

        return PrimeOptimizerRestoreVerifierRecord(
            writerRecord: writerBinding,
            writerProcessIdentifier:
                writer.processIdentifier,
            verifierProcessIdentifier: getpid(),
            executable: executable,
            cpuExecution: cpuExecution,
            modelCheckpoint:
                writer.modelCheckpoint,
            optimizerStateCheckpoint:
                writer.optimizerStateCheckpoint,
            modelSupportedTypedRestoreExact:
                .observed(true),
            optimizerStateSafetensorsRoundTripExact:
                .observed(true)
        )
    }
    try record.validate()
    try reverifyCurrentRuntime(
        binding: runtimeBinding
    )
    _ = try root.publishCanonical(
        record,
        at: verifierRecordPath
    )
}

private func runChild(
    role: ProbeRole,
    executableURL: URL,
    executableSHA256: String,
    arguments: Arguments
) throws -> Int32 {
    let process = Process()
    process.executableURL = executableURL
    process.arguments = [
        "--artifact-root",
        arguments.artifactRoot!.path,
        "--source-root",
        arguments.sourceRoot!.path,
        "--internal-role",
        role.rawValue,
        "--published-executable-sha256",
        executableSHA256,
        "--receipt-path",
        arguments.receiptPath,
    ]
    process.standardOutput = FileHandle.standardOutput
    process.standardError = FileHandle.standardError
    let completed = DispatchSemaphore(value: 0)
    process.terminationHandler = { _ in
        completed.signal()
    }
    try process.run()
    guard completed.wait(
        timeout: .now() + .seconds(30)
    ) == .success else {
        process.terminate()
        if completed.wait(
            timeout: .now() + .seconds(5)
        ) != .success {
            kill(process.processIdentifier, SIGKILL)
            _ = completed.wait(
                timeout: .now() + .seconds(5)
            )
        }
        throw ProbeError.childTimedOut(role.rawValue)
    }
    guard process.terminationReason == .exit,
          process.terminationStatus == 0 else {
        throw ProbeError.childFailed(
            role: role.rawValue,
            status: process.terminationStatus
        )
    }
    return process.processIdentifier
}

private func runParent(
    arguments: Arguments,
    root: PrimeArtifactRoot
) throws {
    _ = try verifyFrozenDependency(
        sourceRoot: arguments.sourceRoot!
    )
    try root.ensurePrivateDirectory(
        at: stagedDirectory
    )
    let mlxDefaultMetallib =
        try PrimePinnedMLXMetallib.captureSibling(
            of: runningExecutableURL(),
            into: root,
            runtimeRole: .optimizerRestoreProbe
        )
    let executable = try root.publish(
        try runningExecutableData(),
        at: stagedExecutablePath,
        purpose: .executable
    )
    _ = try root.publishCanonical(
        mlxDefaultMetallib,
        at: runtimeBindingPath
    )
    let sourceEvidence =
        try publishFrozenSourceEvidence(
            sourceRoot: arguments.sourceRoot!,
            root: root
        )
    let primeSourceSnapshot =
        try PrimeSwiftSourceProvenance.capture(
            at: arguments.sourceRoot!,
            requiredRelativePaths:
                PrimeOptimizerRestoreReceipt
                    .requiredPrimeSourceRelativePaths
        )
    let primeSourceBinding =
        try root.publishCanonical(
            primeSourceSnapshot,
            at: primeSourceSnapshotPath
        )
    let publishedExecutableURL =
        arguments.artifactRoot!
            .appendingPathComponent(
                executable.relativePath
            )

    let launchedWriterPID = try runChild(
        role: .writer,
        executableURL: publishedExecutableURL,
        executableSHA256: executable.sha256,
        arguments: arguments
    )
    let launchedVerifierPID = try runChild(
        role: .verifier,
        executableURL: publishedExecutableURL,
        executableSHA256: executable.sha256,
        arguments: arguments
    )
    try PrimePinnedMLXMetallib
        .reverifyStagedRuntimeImage(
            of: publishedExecutableURL,
            matches: mlxDefaultMetallib,
            runtimeRole:
                .optimizerRestoreProbe
        )

    let writerBinding = try root.bindExisting(
        at: writerRecordPath,
        purpose: .immutableData
    )
    let writer = try root.decodeVerified(
        PrimeOptimizerRestoreWriterRecord.self,
        binding: writerBinding
    )
    let verifierBinding = try root.bindExisting(
        at: verifierRecordPath,
        purpose: .immutableData
    )
    let verifier = try root.decodeVerified(
        PrimeOptimizerRestoreVerifierRecord.self,
        binding: verifierBinding
    )
    try writer.validate()
    try verifier.validate()
    guard writer.processIdentifier
            == launchedWriterPID,
          verifier.verifierProcessIdentifier
            == launchedVerifierPID,
          writer.processIdentifier
            == verifier.writerProcessIdentifier,
          writer.processIdentifier
            != verifier.verifierProcessIdentifier,
          writer.executable == executable,
          verifier.executable == executable,
          verifier.writerRecord == writerBinding,
          verifier.modelSupportedTypedRestoreExact
            == .observed(true),
          verifier
            .optimizerStateSafetensorsRoundTripExact
            == .observed(true) else {
        throw ProbeError.processIdentityCollision
    }

    let catalog = writer.tensorCatalog
    let observations =
        PrimeOptimizerRestoreObservations(
            modelSafetensorsSave:
                .observed(true),
            modelSupportedTypedRestore:
                .observed(true),
            optimizerStateSafetensorsRoundTrip:
                .observed(true),
            supportedTypedOptimizerRestoreAPI:
                .observed(false),
            implementationDetailMutationUsed:
                .observed(false),
            exactTrajectoryContinuation:
                .unavailable,
            freshProcessOptimizerContinuationExact:
                .unavailable,
            checkpointWriterExitedCleanly:
                .observed(true),
            restoreVerifierWasFreshProcess:
                .observed(true)
        )
    let transcript =
        PrimeOptimizerRestoreExecutionTranscript(
            writerPID:
                writer.processIdentifier,
            verifierPID:
                verifier.verifierProcessIdentifier,
            writerExecutable: executable,
            verifierExecutable: executable,
            modelCheckpoint:
                writer.modelCheckpoint,
            optimizerStateCheckpoint:
                writer.optimizerStateCheckpoint,
            mlxDefaultMetallib:
                mlxDefaultMetallib,
            writerRecord: writerBinding,
            verifierRecord: verifierBinding,
            tensorCatalog: catalog,
            observations: observations
        )
    try transcript.validate()
    let transcriptBinding =
        try root.publishCanonical(
            transcript,
            at: executionTranscriptPath
        )
    let artifacts =
        PrimeOptimizerRestoreArtifactBindings(
            executable: executable,
            dependencyAPIEvidence: sourceEvidence,
            primeSourceSnapshot:
                primeSourceBinding,
            modelCheckpoint:
                writer.modelCheckpoint,
            optimizerStateCheckpoint:
                writer.optimizerStateCheckpoint,
            mlxDefaultMetallib:
                mlxDefaultMetallib,
            writerRecord: writerBinding,
            verifierRecord: verifierBinding,
            executionTranscript:
                transcriptBinding
        )
    let receipt = PrimeOptimizerRestoreReceipt(
        outcome: .abstain,
        recordedAtUTC:
            ISO8601DateFormatter()
                .string(from: Date()),
        artifacts: artifacts,
        tensorCatalog: catalog,
        observations: observations
    )
    try receipt.validate(in: root)
    let receiptBinding = try root.publishCanonical(
        receipt,
        at: arguments.receiptPath
    )
    let replayed = try root.decodeVerified(
        PrimeOptimizerRestoreReceipt.self,
        binding: receiptBinding
    )
    guard replayed == receipt else {
        throw ProbeError.receiptRoundTripMismatch
    }
    print(
        "ABSTAIN receipt_sha256=\(receiptBinding.sha256)"
    )
}

@main
private struct PrimeOptimizerRestoreProbeMain {
    static func main() {
        do {
            let arguments = try parseArguments()
            _ = try PrimeMLXRuntimeEnvironmentPolicy
                .validateCurrentProcess()
            let root = try PrimeArtifactRoot(
                directoryURL: arguments.artifactRoot!
            )
            switch arguments.role {
            case .parent:
                try runParent(
                    arguments: arguments,
                    root: root
                )
                exit(abstainExitStatus)
            case .writer:
                try runWriter(
                    arguments: arguments,
                    root: root
                )
            case .verifier:
                try runVerifier(
                    arguments: arguments,
                    root: root
                )
            }
        } catch {
            FileHandle.standardError.write(
                Data("ABSTAIN: \(error)\n".utf8)
            )
            exit(EXIT_FAILURE)
        }
    }
}
