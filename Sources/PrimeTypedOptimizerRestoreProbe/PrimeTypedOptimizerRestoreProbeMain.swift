import Darwin
import Foundation
import MLX
import MLXOptimizers
import PrimeCore
import PrimeTypedOptimizerRestoreMechanics

private enum ProbeError:
    Error,
    CustomStringConvertible
{
    case invalidArgument(String)
    case executableUnreadable
    case executableIdentityMismatch
    case artifactRootAdmissionFailed
    case sourceSemantics(String)
    case dependencySemantics(String)
    case childFailed(
        role: String,
        status: Int32,
        outputByteCount: UInt64,
        outputEvidenceSHA256: String,
        outputOverflowed: Bool
    )
    case childTimedOut(String)
    case childTerminationUnobserved(
        role: String,
        auditDetail: String
    )
    case childOutputRejected(
        role: String,
        byteCount: UInt64,
        evidenceSHA256: String,
        overflowed: Bool
    )
    case childOutputDrainIncomplete(String)
    case workerMismatch(String)
    case checkpointMismatch(String)
    case mutationSurvived(String)
    case receiptRoundTripMismatch

    var description: String {
        switch self {
        case let .invalidArgument(detail):
            "invalid argument: \(detail)"
        case .executableUnreadable:
            "running executable is unreadable"
        case .executableIdentityMismatch:
            "child executable differs from its staged immutable image"
        case .artifactRootAdmissionFailed:
            "typed optimizer run could not establish a new empty artifact root"
        case let .sourceSemantics(detail):
            "Prime source evidence mismatch: \(detail)"
        case let .dependencySemantics(detail):
            "dependency evidence mismatch: \(detail)"
        case let .childFailed(
            role,
            status,
            outputByteCount,
            outputEvidenceSHA256,
            outputOverflowed
        ):
            "\(role) child exited with status \(status); output_bytes=\(outputByteCount) output_evidence_sha256=\(outputEvidenceSHA256) output_overflowed=\(outputOverflowed)"
        case let .childTimedOut(role):
            "\(role) child exceeded its 30-second mechanics limit"
        case let .childTerminationUnobserved(
            role,
            auditDetail
        ):
            "\(role) child termination was not observed after timeout; \(auditDetail)"
        case let .childOutputRejected(
            role,
            byteCount,
            evidenceSHA256,
            overflowed
        ):
            "\(role) child emitted unexpected output; output_bytes=\(byteCount) output_evidence_sha256=\(evidenceSHA256) output_overflowed=\(overflowed)"
        case let .childOutputDrainIncomplete(role):
            "\(role) child output drain did not complete"
        case let .workerMismatch(detail):
            "worker mismatch: \(detail)"
        case let .checkpointMismatch(detail):
            "checkpoint mismatch: \(detail)"
        case let .mutationSurvived(detail):
            "mutation survived: \(detail)"
        case .receiptRoundTripMismatch:
            "published receipt did not round-trip exactly"
        }
    }

    var permitsFailureReceipt: Bool {
        switch self {
        case .childTerminationUnobserved,
                .artifactRootAdmissionFailed:
            return false
        default:
            return true
        }
    }
}

private enum ProbeRole: String {
    case parent
    case control
    case writer
    case restorer

    var workerRole:
        PrimeTypedOptimizerWorkerRole?
    {
        switch self {
        case .parent: nil
        case .control: .control
        case .writer: .writer
        case .restorer: .restorer
        }
    }
}

private struct Arguments {
    var artifactRoot: URL?
    var sourceRoot: URL?
    var role: ProbeRole = .parent
    var publishedExecutableSHA256: String?
    var receiptPath =
        "prime-typed-optimizer-restore-receipt.v2.json"
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

private struct MirrorFile:
    Decodable,
    Equatable
{
    struct Entry: Decodable, Equatable {
        let mirror: String
        let original: String
    }

    let object: [Entry]
    let version: Int
}

private let stagedDirectory = "content-staging"
private let evidenceDirectory =
    "\(stagedDirectory)/evidence"
private let dependencyEvidenceDirectory =
    "\(evidenceDirectory)/mlx-swift"
private let dependencyTreeEvidencePath =
    "\(dependencyEvidenceDirectory)/dependency-source-tree.v1.json"
private let stagedExecutablePath =
    PrimeMLXRuntimeImageLayout
        .typedOptimizerRestoreProbe
        .stagedExecutableRelativePath
private let runtimeBindingPath =
    "\(stagedDirectory)/typed-optimizer-runtime-image.v2.json"
private let sourceSnapshotPath =
    "\(stagedDirectory)/prime-swift-source-snapshot.v2.json"
private let controlRecordPath =
    "\(stagedDirectory)/typed-optimizer-control.v2.json"
private let writerRecordPath =
    "\(stagedDirectory)/typed-optimizer-writer.v2.json"
private let restorerRecordPath =
    "\(stagedDirectory)/typed-optimizer-restorer.v2.json"
private var currentParentFailureStage:
    PrimeTypedOptimizerFailureStage = .preflight

private func modelCheckpointPath(
    _ fixture: PrimeTypedOptimizerFixture
) -> String {
    "\(stagedDirectory)/\(fixture.rawValue)-model-after-step-1.v2.safetensors"
}

private func optimizerCheckpointPath(
    _ fixture: PrimeTypedOptimizerFixture
) -> String {
    "\(stagedDirectory)/\(fixture.rawValue)-optimizer-after-step-1.v2.safetensors"
}

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
        case "--receipt-path":
            result.receiptPath = value
        default:
            throw ProbeError.invalidArgument(
                "unknown option \(key)"
            )
        }
    }
    guard result.artifactRoot != nil,
          result.sourceRoot != nil,
          !result.receiptPath.isEmpty else {
        throw ProbeError.invalidArgument(
            "artifact root, source root, and receipt path are required"
        )
    }
    if result.role != .parent {
        guard let hash =
                result.publishedExecutableSHA256,
              hash.count == 64,
              hash.allSatisfy({
                  $0.isHexDigit
                      && !$0.isUppercase
              }) else {
            throw ProbeError.invalidArgument(
                "child requires a lowercase staged executable SHA-256"
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
    guard data.count <= 256 * 1024 * 1024
    else {
        throw ProbeError.executableUnreadable
    }
    return data
}

private func verifyExecutableIdentity(
    _ expected: String
) throws {
    guard PrimeSHA256.hexDigest(
        of: try runningExecutableData()
    ) == expected else {
        throw ProbeError.executableIdentityMismatch
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
) throws
    -> PrimeTypedOptimizerDependencyTreeEvidence
{
    let plan =
        PrimeTypedOptimizerRestorePlan
            .frozenSchemaV2
    let packageData = try Data(
        contentsOf:
            sourceRoot.appendingPathComponent(
                "Package.swift"
            )
    )
    guard let package = String(
            data: packageData,
            encoding: .utf8
          ),
          package.components(
              separatedBy:
                  plan.firstPartyForkRepository
          ).count == 2,
          package.components(
              separatedBy:
                  plan.firstPartyForkRevision
          ).count == 2 else {
        throw ProbeError.dependencySemantics(
            "Package.swift fork declaration"
        )
    }

    let resolved = try JSONDecoder().decode(
        ResolvedFile.self,
        from: Data(
            contentsOf:
                sourceRoot.appendingPathComponent(
                    "Package.resolved"
                )
        )
    )
    let matching = resolved.pins.filter {
        $0.identity
            == PrimeTypedOptimizerDependencyTree
            .swiftPackageIdentity
    }
    guard matching.count == 1,
          matching[0].kind
            == "remoteSourceControl",
          matching[0].location
            == plan.packageResolvedCanonicalLocation,
          matching[0].state.revision
            == plan.firstPartyForkRevision else {
        throw ProbeError.dependencySemantics(
            "Package.resolved frozen Swift package pin"
        )
    }

    let mirror = try JSONDecoder().decode(
        MirrorFile.self,
        from: Data(
            contentsOf:
                sourceRoot.appendingPathComponent(
                    plan.mirrorConfigurationPath
                )
        )
    )
    guard mirror == MirrorFile(
        object: [
            .init(
                mirror: plan.mirrorTargetRepository,
                original:
                    plan.mirrorOriginalRepository
            ),
        ],
        version: 1
    ) else {
        throw ProbeError.dependencySemantics(
            "SwiftPM mirror"
        )
    }

    let checkout = checkoutURL(
        sourceRoot: sourceRoot
    )
    let exactFiles: [(String, String)] = [
        (
            plan.typedStateSourcePath,
            plan.typedStateSourceSHA256
        ),
        (
            plan.optimizerSourcePath,
            plan.optimizerSourceSHA256
        ),
        (
            "LICENSE",
            plan.dependencyLicenseSHA256
        ),
    ]
    for (path, expected) in exactFiles {
        let data = try Data(
            contentsOf:
                checkout.appendingPathComponent(
                    path
                )
        )
        guard PrimeSHA256.hexDigest(of: data)
                == expected else {
            throw ProbeError.dependencySemantics(
                path
            )
        }
    }
    let dependencyTree =
        try PrimeTypedOptimizerDependencyTree
        .capture(at: checkout)
    try PrimeTypedOptimizerDependencyTree
        .validateFrozen(dependencyTree)
    return dependencyTree
}

private func publishSourceEvidence(
    sourceRoot: URL,
    root: PrimeArtifactRoot
) throws -> PrimeTypedOptimizerSourceEvidence {
    let dependencyTree =
        try verifyDependency(
            sourceRoot: sourceRoot
        )
    for directory in [
        evidenceDirectory,
        dependencyEvidenceDirectory,
    ] {
        try root.ensurePrivateDirectory(
            at: directory
        )
    }
    let checkout = checkoutURL(
        sourceRoot: sourceRoot
    )
    let evidence =
        PrimeTypedOptimizerSourceEvidence(
            packageManifest: try root.publish(
                Data(
                    contentsOf:
                        sourceRoot
                        .appendingPathComponent(
                            "Package.swift"
                        )
                ),
                at:
                    "\(evidenceDirectory)/Package.swift",
                purpose: .immutableData
            ),
            packageResolution: try root.publish(
                Data(
                    contentsOf:
                        sourceRoot
                        .appendingPathComponent(
                            "Package.resolved"
                        )
                ),
                at:
                    "\(evidenceDirectory)/Package.resolved",
                purpose: .immutableData
            ),
            mirrorConfiguration: try root.publish(
                Data(
                    contentsOf:
                        sourceRoot
                        .appendingPathComponent(
                            PrimeTypedOptimizerRestorePlan
                            .frozenSchemaV2
                            .mirrorConfigurationPath
                        )
                ),
                at:
                    "\(evidenceDirectory)/mirrors.json",
                purpose: .immutableData
            ),
            dependencyTreeManifest:
                try root.publishCanonical(
                    dependencyTree,
                    at:
                        dependencyTreeEvidencePath
                ),
            license: try root.publish(
                Data(
                    contentsOf:
                        checkout
                        .appendingPathComponent(
                            "LICENSE"
                        )
                ),
                at:
                    "\(dependencyEvidenceDirectory)/LICENSE",
                purpose: .immutableData
            ),
            typedStateSource: try root.publish(
                Data(
                    contentsOf:
                        checkout
                        .appendingPathComponent(
                            PrimeTypedOptimizerRestorePlan
                            .frozenSchemaV2
                            .typedStateSourcePath
                        )
                ),
                at:
                    "\(dependencyEvidenceDirectory)/AdamOptimizerState.swift",
                purpose: .immutableData
            ),
            optimizerSource: try root.publish(
                Data(
                    contentsOf:
                        checkout
                        .appendingPathComponent(
                            PrimeTypedOptimizerRestorePlan
                            .frozenSchemaV2
                            .optimizerSourcePath
                        )
                ),
                at:
                    "\(dependencyEvidenceDirectory)/Optimizers.swift",
                purpose: .immutableData
            )
        )
    try evidence.validate()
    return evidence
}

private func bindSourceEvidence(
    root: PrimeArtifactRoot,
    observedDependencyTree:
        PrimeTypedOptimizerDependencyTreeEvidence
) throws -> PrimeTypedOptimizerSourceEvidence {
    let evidence =
        PrimeTypedOptimizerSourceEvidence(
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
                    at:
                        dependencyTreeEvidencePath,
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
                )
        )
    try evidence.validate()
    let publishedTree =
        try root.decodeVerified(
            PrimeTypedOptimizerDependencyTreeEvidence
                .self,
            binding:
                evidence
                .dependencyTreeManifest,
            maximumByteCount:
                4 * 1024 * 1024
        )
    try PrimeTypedOptimizerDependencyTree
        .validateFrozen(publishedTree)
    guard publishedTree
            == observedDependencyTree else {
        throw ProbeError.dependencySemantics(
            "published dependency tree diverged from the live checkout"
        )
    }
    return evidence
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
    try PrimeMLXRuntimeImageLayout.require(
        binding.runtimeImageLayout,
        for: .typedOptimizerRestoreProbe
    )
    return binding
}

private func verifyChildContext(
    arguments: Arguments,
    root: PrimeArtifactRoot
) throws -> (
    executable: PrimeArtifactBinding,
    sourceEvidence:
        PrimeTypedOptimizerSourceEvidence,
    runtime: PrimePinnedMLXMetallibBinding
) {
    let expected =
        arguments.publishedExecutableSHA256!
    try verifyExecutableIdentity(expected)
    let dependencyTree =
        try verifyDependency(
        sourceRoot: arguments.sourceRoot!
    )
    let executable = try root.bindExisting(
        at: stagedExecutablePath,
        purpose: .executable,
        maximumByteCount: 256 * 1024 * 1024
    )
    guard executable.sha256 == expected else {
        throw ProbeError.executableIdentityMismatch
    }
    let runtime = try loadRuntimeBinding(
        root: root
    )
    try PrimePinnedMLXMetallib.reverifySibling(
        of: runningExecutableURL(),
        matches: runtime,
        runtimeRole:
            .typedOptimizerRestoreProbe
    )
    return (
        executable,
        try bindSourceEvidence(
            root: root,
            observedDependencyTree:
                dependencyTree
        ),
        runtime
    )
}

private func withTemporaryDirectory<Result>(
    _ body: (URL) throws -> Result
) throws -> Result {
    let directory = FileManager.default
        .temporaryDirectory
        .appendingPathComponent(
            "PrimeTypedOptimizerRestore-\(UUID().uuidString)",
            isDirectory: true
        )
    try FileManager.default.createDirectory(
        at: directory,
        withIntermediateDirectories: false,
        attributes: [
            .posixPermissions: NSNumber(
                value: 0o700
            ),
        ]
    )
    defer {
        try? FileManager.default.removeItem(
            at: directory
        )
    }
    return try body(directory)
}

private func uniqueArrays(
    _ pairs: [(String, MLXArray)]
) throws -> [String: MLXArray] {
    var result = [String: MLXArray]()
    for (key, array) in pairs {
        guard result.updateValue(
            array,
            forKey: key
        ) == nil else {
            throw ProbeError.checkpointMismatch(
                "duplicate key \(key)"
            )
        }
    }
    return result
}

private func writeCheckpoint(
    pairs: [(String, MLXArray)],
    metadata: [String: String],
    publishedPath: String,
    root: PrimeArtifactRoot
) throws -> PrimeArtifactBinding {
    try withTemporaryDirectory { directory in
        let file = directory
            .appendingPathComponent(
                "checkpoint.safetensors"
            )
        try MLX.save(
            arrays: try uniqueArrays(pairs),
            metadata: metadata,
            url: file,
            stream: .cpu
        )
        return try root.publish(
            Data(contentsOf: file),
            at: publishedPath,
            purpose: .immutableData
        )
    }
}

private func loadCheckpoint(
    binding: PrimeArtifactBinding,
    root: PrimeArtifactRoot
) throws -> (
    arrays: [String: MLXArray],
    metadata: [String: String]
) {
    try withTemporaryDirectory { directory in
        let file = directory
            .appendingPathComponent(
                "checkpoint.safetensors"
            )
        try root.readVerified(
            binding,
            maximumByteCount: 64 * 1024 * 1024
        ).write(
            to: file,
            options: [.atomic]
        )
        return try MLX.loadArraysAndMetadata(
            url: file,
            stream: .cpu
        )
    }
}

private func runControl(
    arguments: Arguments,
    root: PrimeArtifactRoot
) throws {
    let context = try verifyChildContext(
        arguments: arguments,
        root: root
    )
    let manifests = try
        PrimeTypedOptimizerFixture.allCases
        .sorted().map {
            try PrimeTypedOptimizerMechanics
                .runControl(fixture: $0)
                .manifest
        }
    let record = PrimeTypedOptimizerWorkerRecord(
        role: .control,
        processIdentifier: getpid(),
        executable: context.executable,
        sourceEvidence: context.sourceEvidence,
        manifests: manifests,
        publicTypedRestoreAPIUsed: false
    )
    try record.validate()
    _ = try root.publishCanonical(
        record,
        at: controlRecordPath
    )
}

private func runWriter(
    arguments: Arguments,
    root: PrimeArtifactRoot
) throws {
    let context = try verifyChildContext(
        arguments: arguments,
        root: root
    )
    var manifests =
        [PrimeTypedOptimizerExecutionManifest]()
    var bindings =
        [PrimeTypedOptimizerCheckpointBindings]()
    for fixture in
        PrimeTypedOptimizerFixture.allCases
        .sorted()
    {
        let result =
            try PrimeTypedOptimizerMechanics
            .runWriter(fixture: fixture)
        try result.manifest.validate()
        let model = try writeCheckpoint(
            pairs:
                result.checkpoint
                .modelStoragePairs,
            metadata: [
                "artifact_kind":
                    "prime_typed_model_after_step_1",
                "fixture": fixture.rawValue,
                "schema_version": "2",
            ],
            publishedPath:
                modelCheckpointPath(fixture),
            root: root
        )
        let optimizer = try writeCheckpoint(
            pairs:
                result.checkpoint
                .optimizerStoragePairs,
            metadata: [
                "artifact_kind":
                    "prime_typed_adamw_state_after_step_1",
                "fixture": fixture.rawValue,
                "schema_version": "2",
            ],
            publishedPath:
                optimizerCheckpointPath(fixture),
            root: root
        )
        manifests.append(result.manifest)
        bindings.append(
            PrimeTypedOptimizerCheckpointBindings(
                fixture: fixture,
                model: model,
                optimizerState: optimizer
            )
        )
    }
    let record = PrimeTypedOptimizerWorkerRecord(
        role: .writer,
        processIdentifier: getpid(),
        executable: context.executable,
        sourceEvidence: context.sourceEvidence,
        manifests: manifests,
        checkpoints: bindings,
        publicTypedRestoreAPIUsed: false
    )
    try record.validate()
    _ = try root.publishCanonical(
        record,
        at: writerRecordPath
    )
}

private func runRestorer(
    arguments: Arguments,
    root: PrimeArtifactRoot
) throws {
    let context = try verifyChildContext(
        arguments: arguments,
        root: root
    )
    let writerBinding = try root.bindExisting(
        at: writerRecordPath,
        purpose: .immutableData
    )
    let writer = try root.decodeVerified(
        PrimeTypedOptimizerWorkerRecord.self,
        binding: writerBinding
    )
    try writer.validate()
    guard writer.role == .writer,
          writer.processIdentifier != getpid(),
          writer.executable == context.executable,
          writer.sourceEvidence
            == context.sourceEvidence else {
        throw ProbeError.workerMismatch(
            "writer provenance"
        )
    }

    var manifests =
        [PrimeTypedOptimizerExecutionManifest]()
    for fixture in
        PrimeTypedOptimizerFixture.allCases
        .sorted()
    {
        guard let bindings =
                writer.checkpoints.first(
                    where: {
                        $0.fixture == fixture
                    }
                ),
              let writerManifest =
                writer.manifests.first(
                    where: {
                        $0.fixture == fixture
                    }
                ) else {
            throw ProbeError.checkpointMismatch(
                fixture.rawValue
            )
        }
        // Ordered manifest validation precedes all checkpoint dictionaries.
        try writerManifest.validate()
        let model = try loadCheckpoint(
            binding: bindings.model,
            root: root
        )
        let optimizer = try loadCheckpoint(
            binding: bindings.optimizerState,
            root: root
        )
        guard model.metadata == [
            "artifact_kind":
                "prime_typed_model_after_step_1",
            "fixture": fixture.rawValue,
            "schema_version": "2",
        ],
            optimizer.metadata == [
                "artifact_kind":
                    "prime_typed_adamw_state_after_step_1",
                "fixture": fixture.rawValue,
                "schema_version": "2",
            ]
        else {
            throw ProbeError.checkpointMismatch(
                "metadata \(fixture.rawValue)"
            )
        }
        let checkpoint =
            try PrimeTypedOptimizerMechanics
            .rehydrateCheckpoint(
                fixture: fixture,
                modelArrays: model.arrays,
                optimizerArrays:
                    optimizer.arrays,
                writerManifest:
                    writerManifest
            )
        manifests.append(
            try PrimeTypedOptimizerMechanics
                .runRestorer(
                    checkpoint: checkpoint
                ).manifest
        )
    }
    let record = PrimeTypedOptimizerWorkerRecord(
        role: .restorer,
        processIdentifier: getpid(),
        executable: context.executable,
        sourceEvidence: context.sourceEvidence,
        manifests: manifests,
        writerRecord: writerBinding,
        publicTypedRestoreAPIUsed: true
    )
    try record.validate()
    _ = try root.publishCanonical(
        record,
        at: restorerRecordPath
    )
}

private final class BoundedPipeCapture:
    @unchecked Sendable
{
    private let maximumByteCount: Int
    private let lock = NSLock()
    private var captured = Data()
    private var totalByteCount: UInt64 = 0
    private var overflowed = false
    private var drainCompleted = false

    init(maximumByteCount: Int) {
        self.maximumByteCount =
            maximumByteCount
        captured.reserveCapacity(
            maximumByteCount
        )
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
                try? handle.close()
                group.leave()
            }
            do {
                while let chunk =
                    try handle.read(
                        upToCount: 8 * 1024
                    ),
                    !chunk.isEmpty
                {
                    self.append(chunk)
                }
                self.lock.lock()
                self.drainCompleted = true
                self.lock.unlock()
            } catch {
                self.lock.lock()
                self.drainCompleted = false
                self.lock.unlock()
            }
        }
    }

    func snapshot() -> (
        totalByteCount: UInt64,
        capturedSHA256: String,
        overflowed: Bool,
        drainCompleted: Bool
    ) {
        lock.lock()
        defer {
            lock.unlock()
        }
        return (
            totalByteCount,
            PrimeSHA256.hexDigest(
                of: captured
            ),
            overflowed,
            drainCompleted
        )
    }

    private func append(_ data: Data) {
        lock.lock()
        defer {
            lock.unlock()
        }
        let (nextTotal, didOverflow) =
            totalByteCount
            .addingReportingOverflow(
                UInt64(data.count)
            )
        if didOverflow {
            totalByteCount = UInt64.max
            overflowed = true
        } else {
            totalByteCount = nextTotal
        }
        let remaining =
            maximumByteCount - captured.count
        if remaining > 0 {
            captured.append(
                data.prefix(remaining)
            )
        }
        if data.count > remaining {
            overflowed = true
        }
    }
}

private func boundedOutputObservation(
    standardOutput: BoundedPipeCapture,
    standardError: BoundedPipeCapture
) -> PrimeTypedOptimizerBoundedOutputObservation {
    let output = standardOutput.snapshot()
    let error = standardError.snapshot()
    return PrimeTypedOptimizerBoundedOutputObservation(
        maximumBytesPerStream:
            PrimeTypedOptimizerBoundedOutputObservation
            .frozenMaximumBytesPerStream,
        standardOutputByteCount:
            output.totalByteCount,
        standardOutputSHA256:
            output.capturedSHA256,
        standardErrorByteCount:
            error.totalByteCount,
        standardErrorSHA256:
            error.capturedSHA256,
        overflowed:
            output.overflowed
            || error.overflowed,
        drainCompleted:
            output.drainCompleted
            && error.drainCompleted
    )
}

private func combinedOutputEvidenceSHA256(
    _ output:
        PrimeTypedOptimizerBoundedOutputObservation
) -> String {
    let material =
        "\(output.standardOutputByteCount)|\(output.standardOutputSHA256)|\(output.standardErrorByteCount)|\(output.standardErrorSHA256)|\(output.overflowed)|\(output.drainCompleted)"
    return PrimeSHA256.hexDigest(
        of: Data(material.utf8)
    )
}

private func runChild(
    role: ProbeRole,
    executableURL: URL,
    executableSHA256: String,
    arguments: Arguments
) throws -> PrimeTypedOptimizerProcessObservation {
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
    let workerEnvironment = [String: String]()
    _ = try PrimeMLXRuntimeEnvironmentPolicy
        .validate(
            environment: workerEnvironment
        )
    process.environment = workerEnvironment
    process.standardInput = FileHandle.nullDevice
    let outputPipe = Pipe()
    let errorPipe = Pipe()
    process.standardOutput = outputPipe
    process.standardError = errorPipe
    let outputLimit = Int(
        PrimeTypedOptimizerBoundedOutputObservation
        .frozenMaximumBytesPerStream
    )
    let standardOutput =
        BoundedPipeCapture(
            maximumByteCount: outputLimit
        )
    let standardError =
        BoundedPipeCapture(
            maximumByteCount: outputLimit
        )
    let outputDrains = DispatchGroup()
    standardOutput.start(
        reading:
            outputPipe.fileHandleForReading,
        in: outputDrains
    )
    standardError.start(
        reading:
            errorPipe.fileHandleForReading,
        in: outputDrains
    )
    let completed = DispatchSemaphore(value: 0)
    process.terminationHandler = { _ in
        completed.signal()
    }
    do {
        try process.run()
    } catch {
        try? outputPipe
            .fileHandleForWriting.close()
        try? errorPipe
            .fileHandleForWriting.close()
        _ = outputDrains.wait(
            timeout: .now() + .seconds(5)
        )
        throw error
    }
    try? outputPipe
        .fileHandleForWriting.close()
    try? errorPipe
        .fileHandleForWriting.close()
    let timedOut = completed.wait(
        timeout: .now() + .seconds(30)
    ) == .timedOut
    if timedOut {
        let escalation =
            PrimeProcessTermination
            .escalateAfterTimeout(
                processIdentifier:
                    process
                    .processIdentifier,
                graceMilliseconds: 5_000,
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
                    auditDetail:
                        escalation.auditDetail
                )
        }
    }
    guard outputDrains.wait(
        timeout: .now() + .seconds(5)
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
    let output =
        boundedOutputObservation(
            standardOutput: standardOutput,
            standardError: standardError
        )
    let (combinedByteCount, byteCountOverflow) =
        output.standardOutputByteCount
        .addingReportingOverflow(
            output.standardErrorByteCount
        )
    let outputByteCount =
        byteCountOverflow
        ? UInt64.max
        : combinedByteCount
    let outputEvidenceSHA256 =
        combinedOutputEvidenceSHA256(output)
    if timedOut {
        throw ProbeError.childTimedOut(
            role.rawValue
        )
    }
    guard process.terminationReason == .exit,
          process.terminationStatus == 0 else {
        throw ProbeError.childFailed(
            role: role.rawValue,
            status: process.terminationStatus,
            outputByteCount:
                outputByteCount,
            outputEvidenceSHA256:
                outputEvidenceSHA256,
            outputOverflowed:
                output.overflowed
        )
    }
    guard output
            == .emptySuccess else {
        throw ProbeError.childOutputRejected(
            role: role.rawValue,
            byteCount: outputByteCount,
            evidenceSHA256:
                outputEvidenceSHA256,
            overflowed: output.overflowed
        )
    }
    let recordPath: String
    switch role {
    case .control:
        recordPath = controlRecordPath
    case .writer:
        recordPath = writerRecordPath
    case .restorer:
        recordPath = restorerRecordPath
    case .parent:
        throw ProbeError.invalidArgument(
            "parent cannot be launched as child"
        )
    }
    return PrimeTypedOptimizerProcessObservation(
        role: role.workerRole!,
        processIdentifier:
            process.processIdentifier,
        terminationReason: "exit",
        terminationStatus:
            process.terminationStatus,
        workerEnvironmentKeyCount:
            workerEnvironment.count,
        standardInputClosed: true,
        boundedOutput: output,
        record: try PrimeArtifactRoot(
            directoryURL: arguments.artifactRoot!
        ).bindExisting(
            at: recordPath,
            purpose: .immutableData
        )
    )
}

private struct MutationDetection {
    let disposed: Bool
    let proposal: Data
    let derivation: Data
    let reason: String
}

private func optimizerStateEvidence(
    _ state: AdamOptimizerState
) throws -> Data {
    var lines = [String]()
    for (moment, parameters) in [
        ("first", state.firstMoment),
        ("second", state.secondMoment),
    ] {
        for (path, array) in
            parameters.flattened().sorted(
                by: { $0.0 < $1.0 }
            )
        {
            try checkedEval(array)
            lines.append(
                [
                    moment,
                    path,
                    String(describing: array.dtype),
                    array.shape.map(String.init)
                        .joined(separator: ","),
                    PrimeSHA256.hexDigest(
                        of: array.asData(
                            access: .copy
                        ).data
                    ),
                ].joined(separator: "|")
            )
        }
    }
    return Data(
        lines.joined(separator: "\n").utf8
    )
}

private func setJSONValue(
    _ object: inout [String: Any],
    path: ArraySlice<String>,
    value: Any
) throws {
    guard let key = path.first else {
        throw ProbeError.mutationSurvived(
            "empty JSON path"
        )
    }
    if path.count == 1 {
        guard object[key] != nil else {
            throw ProbeError.mutationSurvived(
                "missing JSON key \(key)"
            )
        }
        object[key] = value
        return
    }
    guard var child =
            object[key] as? [String: Any] else {
        throw ProbeError.mutationSurvived(
            "non-object JSON key \(key)"
        )
    }
    try setJSONValue(
        &child,
        path: path.dropFirst(),
        value: value
    )
    object[key] = child
}

private func mutateJSON<Value: Encodable>(
    _ value: Value,
    path: [String],
    replacement: Any
) throws -> Data {
    let baseline =
        try PrimeCanonicalJSON.encode(value)
    guard var object =
            try JSONSerialization
            .jsonObject(with: baseline)
            as? [String: Any] else {
        throw ProbeError.mutationSurvived(
            "JSON root"
        )
    }
    try setJSONValue(
        &object,
        path: path[...],
        value: replacement
    )
    return try JSONSerialization.data(
        withJSONObject: object,
        options: [.sortedKeys]
    )
}

private func planMutationDetection(
    mutation: PrimeTypedOptimizerRestoreMutation,
    path: [String],
    replacement: Any
) throws -> MutationDetection {
    let data = try mutateJSON(
        PrimeTypedOptimizerRestorePlan
            .frozenSchemaV2,
        path: path,
        replacement: replacement
    )
    let rejected: Bool
    do {
        let changed = try JSONDecoder().decode(
            PrimeTypedOptimizerRestorePlan.self,
            from: data
        )
        do {
            try changed.validate()
            rejected = false
        } catch {
            rejected = true
        }
    } catch {
        rejected = true
    }
    return MutationDetection(
        disposed: rejected,
        proposal: data,
        derivation: Data(
            "frozen_plan_rejected|\(mutation.rawValue)|\(rejected)"
                .utf8
        ),
        reason:
            "frozen plan equality rejected \(mutation.rawValue)"
    )
}

private func manifestDetection(
    mutation: PrimeTypedOptimizerRestoreMutation,
    manifest:
        PrimeTypedOptimizerExecutionManifest
) throws -> MutationDetection {
    let proposal =
        try PrimeCanonicalJSON.encode(manifest)
    let rejected: Bool
    do {
        try manifest.validate()
        rejected = false
    } catch {
        rejected = true
    }
    return MutationDetection(
        disposed: rejected,
        proposal: proposal,
        derivation: Data(
            "manifest_rejected|\(mutation.rawValue)|\(rejected)"
                .utf8
        ),
        reason:
            "ordered manifest validator rejected \(mutation.rawValue)"
    )
}

private func detectMutation(
    _ mutation:
        PrimeTypedOptimizerRestoreMutation,
    writer: (
        step: PrimeTypedOptimizerStepResult,
        checkpoint: PrimeTypedOptimizerCheckpoint,
        manifest:
            PrimeTypedOptimizerExecutionManifest
    ),
    control: PrimeTypedOptimizerTrajectory
) throws -> MutationDetection {
    switch mutation {
    case .momentsSwapped,
            .sameShapePathSwap,
            .missingEntry,
            .extraEntry,
            .shapeMismatch,
            .dtypeMismatch:
        let stateMutation:
            PrimeTypedOptimizerStateMutation
        switch mutation {
        case .momentsSwapped:
            stateMutation = .momentsSwapped
        case .sameShapePathSwap:
            stateMutation = .sameShapePathSwap
        case .missingEntry:
            stateMutation = .missingFirstMoment
        case .extraEntry:
            stateMutation = .extraSecondMoment
        case .shapeMismatch:
            stateMutation =
                .firstMomentShapeMismatch
        case .dtypeMismatch:
            stateMutation =
                .secondMomentDTypeMismatch
        default:
            fatalError("exhaustive mapping")
        }
        let changed =
            try PrimeTypedOptimizerMechanics
            .mutatedState(
                writer.checkpoint.optimizerState,
                fixture: .nestedSameShape,
                mutation: stateMutation
            )
        let proposal = try optimizerStateEvidence(
            changed
        )
        let checkpoint =
            PrimeTypedOptimizerCheckpoint(
                fixture: .nestedSameShape,
                stepIndex: 1,
                modelParameters:
                    writer.checkpoint
                    .modelParameters,
                optimizerState: changed,
                modelStoragePairs:
                    writer.checkpoint
                    .modelStoragePairs,
                optimizerStoragePairs:
                    writer.checkpoint
                    .optimizerStoragePairs
            )
        let disposed: Bool
        let resultCode: String
        switch mutation {
        case .momentsSwapped:
            do {
                let observed =
                    try PrimeTypedOptimizerMechanics
                    .runRestorer(
                        checkpoint: checkpoint
                    )
                disposed =
                    observed.second.entries
                    != control.second.entries
                resultCode = disposed
                    ? "trajectory_diverged"
                    : "trajectory_matched"
            } catch let error
                as PrimeTypedOptimizerMechanicsError
            {
                guard case .nonFiniteTensor =
                        error else {
                    throw error
                }
                disposed = true
                resultCode =
                    "nonfinite_continuation_rejected"
            }

        case .sameShapePathSwap:
            let observed =
                try PrimeTypedOptimizerMechanics
                .runRestorer(
                    checkpoint: checkpoint
                )
            disposed =
                observed.second.entries
                != control.second.entries
            resultCode = disposed
                ? "trajectory_diverged"
                : "trajectory_matched"

        case .missingEntry,
                .extraEntry,
                .shapeMismatch,
                .dtypeMismatch:
            do {
                _ = try PrimeTypedOptimizerMechanics
                    .runRestorer(
                        checkpoint: checkpoint
                    )
                disposed = false
                resultCode =
                    "typed_import_accepted"
            } catch {
                guard typedStateMutationRejection(
                    error,
                    matches: mutation
                ) else {
                    throw error
                }
                disposed = true
                resultCode =
                    "typed_import_rejected"
            }

        default:
            fatalError("exhaustive state mutation mapping")
        }
        return MutationDetection(
            disposed: disposed,
            proposal: proposal,
            derivation: Data(
                "\(mutation.detectorID)|\(mutation.rawValue)|\(resultCode)"
                    .utf8
            ),
            reason:
                "\(mutation.detectorID) observed \(resultCode)"
        )

    case .duplicateEntry:
        var entries =
            writer.manifest.entries
        entries.insert(entries[0], at: 1)
        return try manifestDetection(
            mutation: mutation,
            manifest:
                PrimeTypedOptimizerExecutionManifest(
                    workerRole: .writer,
                    fixture: .nestedSameShape,
                    trainablePaths:
                        PrimeTypedOptimizerFixture
                        .nestedSameShape
                        .trainablePaths,
                    frozenPaths: [],
                    missingGradientPolicy: .reject,
                    semanticObservations:
                        .confirmed,
                    entries: entries
                )
        )

    case .orderPermutation:
        var entries =
            writer.manifest.entries
        entries.swapAt(0, 1)
        return try manifestDetection(
            mutation: mutation,
            manifest:
                PrimeTypedOptimizerExecutionManifest(
                    workerRole: .writer,
                    fixture: .nestedSameShape,
                    trainablePaths:
                        PrimeTypedOptimizerFixture
                        .nestedSameShape
                        .trainablePaths,
                    frozenPaths: [],
                    missingGradientPolicy: .reject,
                    semanticObservations:
                        .confirmed,
                    entries: entries
                )
        )

    case .trainablePolicyMismatch:
        return try manifestDetection(
            mutation: mutation,
            manifest:
                PrimeTypedOptimizerExecutionManifest(
                    workerRole: .writer,
                    fixture: .nestedSameShape,
                    trainablePaths:
                        Array(
                            PrimeTypedOptimizerFixture
                            .nestedSameShape
                            .trainablePaths.dropLast()
                        ),
                    frozenPaths: [],
                    missingGradientPolicy: .reject,
                    semanticObservations:
                        .confirmed,
                    entries: writer.manifest.entries
                )
        )

    case .frozenPolicyMismatch:
        return try manifestDetection(
            mutation: mutation,
            manifest:
                PrimeTypedOptimizerExecutionManifest(
                    workerRole: .writer,
                    fixture: .nestedSameShape,
                    trainablePaths:
                        PrimeTypedOptimizerFixture
                        .nestedSameShape
                        .trainablePaths,
                    frozenPaths: [
                        "layers.0.bias",
                    ],
                    missingGradientPolicy: .reject,
                    semanticObservations:
                        .confirmed,
                    entries: writer.manifest.entries
                )
        )

    case .missingGradientPolicyMismatch:
        let proposal = try mutateJSON(
            writer.manifest,
            path: ["missingGradientPolicy"],
            replacement: "allow"
        )
        let rejected: Bool
        do {
            _ = try JSONDecoder().decode(
                PrimeTypedOptimizerExecutionManifest
                    .self,
                from: proposal
            )
            rejected = false
        } catch {
            rejected = true
        }
        return MutationDetection(
            disposed: rejected,
            proposal: proposal,
            derivation: Data(
                "ordered_manifest_rejection|missing_gradient_policy|\(rejected)"
                    .utf8
            ),
            reason:
                "typed policy decoder rejected a non-reject missing-gradient policy"
        )

    case .optimizerConfigurationMismatch:
        return try planMutationDetection(
            mutation: mutation,
            path: ["configuration", "learningRate"],
            replacement: 0.0002
        )
    case .forkRevisionMismatch:
        return try planMutationDetection(
            mutation: mutation,
            path: ["firstPartyForkRevision"],
            replacement:
                String(repeating: "0", count: 40)
        )
    case .stepMismatch:
        return try planMutationDetection(
            mutation: mutation,
            path: ["completedSteps"],
            replacement: 3
        )
    case .scheduleMismatch:
        return try planMutationDetection(
            mutation: mutation,
            path: ["scheduleID"],
            replacement: "mutated_schedule"
        )
    case .batchMismatch:
        return try planMutationDetection(
            mutation: mutation,
            path: ["secondBatchID"],
            replacement: "mutated_batch"
        )
    case .seedDomainMismatch:
        return try planMutationDetection(
            mutation: mutation,
            path: ["initializationSeedDomain"],
            replacement:
                "mutated_initialization_seed_domain"
        )

    case .byteTamper:
        var entries = writer.manifest.entries
        let index = entries.firstIndex {
            $0.role == .firstMoment
        }!
        let original = entries[index]
        entries[index] =
            PrimeTypedOptimizerTensorEntry(
                fixture: original.fixture,
                stepIndex: original.stepIndex,
                role: original.role,
                path: original.path,
                storageKey: original.storageKey,
                dtype: original.dtype,
                shape: original.shape,
                byteCount: original.byteCount,
                logicalSHA256:
                    String(repeating: "0", count: 64)
            )
        let tampered =
            PrimeTypedOptimizerExecutionManifest(
                workerRole: .writer,
                fixture: .nestedSameShape,
                trainablePaths:
                    PrimeTypedOptimizerFixture
                    .nestedSameShape.trainablePaths,
                frozenPaths: [],
                missingGradientPolicy: .reject,
                semanticObservations: .confirmed,
                entries: entries
            )
        try tampered.validate()
        let proposal =
            try PrimeCanonicalJSON.encode(tampered)
        let rejected: Bool
        do {
            _ = try PrimeTypedOptimizerMechanics
                .rehydrateCheckpoint(
                    fixture: .nestedSameShape,
                    modelArrays:
                        try uniqueArrays(
                            writer.checkpoint
                            .modelStoragePairs
                        ),
                    optimizerArrays:
                        try uniqueArrays(
                            writer.checkpoint
                            .optimizerStoragePairs
                        ),
                    writerManifest: tampered
                )
            rejected = false
        } catch {
            rejected = true
        }
        return MutationDetection(
            disposed: rejected,
            proposal: proposal,
            derivation: Data(
                "checkpoint_logical_hash_rejection|byte_tamper|\(rejected)"
                    .utf8
            ),
            reason:
                "checkpoint logical-byte verifier rejected the tampered manifest"
        )

    case .aliasing:
        let first = try
            PrimeTypedOptimizerMechanics.restore(
                checkpoint: writer.checkpoint
            )
        let second = try
            PrimeTypedOptimizerMechanics.restore(
                checkpoint: writer.checkpoint
            )
        let beforeState =
            try second.optimizer.parameters()
        let before = try optimizerStateEvidence(
            beforeState
        )
        _ = try PrimeTypedOptimizerMechanics
            .runStep(
                model: first.model,
                optimizer: first.optimizer,
                batch:
                    PrimeTypedOptimizerMechanics
                    .batches(
                        fixture: .nestedSameShape
                    ).second,
                fixture: .nestedSameShape,
                stepIndex: 2
            )
        let after = try optimizerStateEvidence(
            second.optimizer.parameters()
        )
        let isolated = before == after
        return MutationDetection(
            disposed: isolated,
            proposal: Data(
                "two_public_imports|\(PrimeSHA256.hexDigest(of: before))"
                    .utf8
            ),
            derivation: Data(
                "public_state_alias_isolation|unchanged=\(isolated)|\(PrimeSHA256.hexDigest(of: after))"
                    .utf8
            ),
            reason:
                "independent public import remained byte-exact after the sibling optimizer advanced"
        )
    }
}

private func typedStateMutationRejection(
    _ error: Error,
    matches mutation:
        PrimeTypedOptimizerRestoreMutation
) -> Bool {
    guard let stateError =
            error as? AdamOptimizerStateError else {
        return false
    }
    switch (mutation, stateError) {
    case (
        .missingEntry,
        .missingPath(moment: .first, path: _)
    ),
    (
        .extraEntry,
        .extraPath(moment: .second, path: _)
    ),
    (
        .shapeMismatch,
        .shapeMismatch(
            moment: .first,
            path: _,
            expected: _,
            actual: _
        )
    ),
    (
        .dtypeMismatch,
        .dtypeMismatch(
            moment: .second,
            path: _,
            expected: _,
            actual: _
        )
    ):
        return true
    default:
        return false
    }
}

private func mutationSweep()
    throws
    -> [PrimeTypedOptimizerMutationDisposition]
{
    try Device.withDefaultDevice(.cpu) {
        let writer =
            try PrimeTypedOptimizerMechanics
            .runWriter(fixture: .nestedSameShape)
        let control =
            try PrimeTypedOptimizerMechanics
            .runControl(fixture: .nestedSameShape)
        var results =
            [PrimeTypedOptimizerMutationDisposition]()
        for mutation in
            PrimeTypedOptimizerRestoreMutation.allCases
        {
            let detection = try detectMutation(
                mutation,
                writer: writer,
                control: control
            )
            guard detection.disposed else {
                throw ProbeError.mutationSurvived(
                    mutation.rawValue
                )
            }
            results.append(
                PrimeTypedOptimizerMutationDisposition(
                    mutation: mutation,
                    detectorID:
                        mutation.detectorID,
                    proposedEvidenceSHA256:
                        PrimeSHA256.hexDigest(
                            of: detection.proposal
                        ),
                    detectorEvidenceSHA256:
                        PrimeSHA256.hexDigest(
                            of: detection.derivation
                        ),
                    proposalMaterialized: true,
                    detectorExecuted: true,
                    independentScientificOracleClaimed:
                        false,
                    disposed: true,
                    reason: detection.reason
                )
            )
        }
        return results
    }
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
    currentParentFailureStage = .preflight
    let initialDependencyTree =
        try verifyDependency(
            sourceRoot:
                arguments.sourceRoot!
        )
    currentParentFailureStage = .staging
    try root.ensurePrivateDirectory(
        at: stagedDirectory
    )
    let runtime =
        try PrimePinnedMLXMetallib
        .captureSibling(
            of: runningExecutableURL(),
            into: root,
            runtimeRole:
                .typedOptimizerRestoreProbe
        )
    let executable = try root.publish(
        try runningExecutableData(),
        at: stagedExecutablePath,
        purpose: .executable
    )
    _ = try root.publishCanonical(
        runtime,
        at: runtimeBindingPath
    )
    _ = try publishSourceEvidence(
        sourceRoot: arguments.sourceRoot!,
        root: root
    )
    let sourceSnapshot =
        try PrimeSwiftSourceProvenance
        .capture(
            at: arguments.sourceRoot!,
            requiredRelativePaths:
                PrimeTypedOptimizerRestoreReceipt
                .requiredPrimeSourceRelativePaths
        )
    let sourceSnapshotBinding =
        try root.publishCanonical(
            sourceSnapshot,
            at: sourceSnapshotPath
        )
    let executableURL =
        arguments.artifactRoot!
        .appendingPathComponent(
            executable.relativePath
        )

    currentParentFailureStage = .control
    let controlExit = try runChild(
        role: .control,
        executableURL: executableURL,
        executableSHA256: executable.sha256,
        arguments: arguments
    )
    currentParentFailureStage = .writer
    let writerExit = try runChild(
        role: .writer,
        executableURL: executableURL,
        executableSHA256: executable.sha256,
        arguments: arguments
    )
    currentParentFailureStage = .restorer
    let restorerExit = try runChild(
        role: .restorer,
        executableURL: executableURL,
        executableSHA256: executable.sha256,
        arguments: arguments
    )
    try PrimePinnedMLXMetallib
        .reverifyStagedRuntimeImage(
            of: executableURL,
            matches: runtime,
            runtimeRole:
                .typedOptimizerRestoreProbe
        )

    let control = try root.decodeVerified(
        PrimeTypedOptimizerWorkerRecord.self,
        binding: controlExit.record
    )
    let writer = try root.decodeVerified(
        PrimeTypedOptimizerWorkerRecord.self,
        binding: writerExit.record
    )
    let restorer = try root.decodeVerified(
        PrimeTypedOptimizerWorkerRecord.self,
        binding: restorerExit.record
    )
    currentParentFailureStage =
        .mutationSweep
    let mutations = try mutationSweep()
    let finalDependencyTree =
        try verifyDependency(
            sourceRoot:
                arguments.sourceRoot!
        )
    guard finalDependencyTree
            == initialDependencyTree else {
        throw ProbeError.dependencySemantics(
            "dependency build-input tree changed during execution"
        )
    }
    let finalSourceSnapshot =
        try PrimeSwiftSourceProvenance
        .capture(
            at: arguments.sourceRoot!,
            requiredRelativePaths:
                PrimeTypedOptimizerRestoreReceipt
                .requiredPrimeSourceRelativePaths
        )
    guard finalSourceSnapshot
            == sourceSnapshot else {
        throw ProbeError.sourceSemantics(
            "Prime source changed during execution"
        )
    }
    try PrimePinnedMLXMetallib
        .reverifySibling(
            of: runningExecutableURL(),
            matches: runtime,
            runtimeRole:
                .typedOptimizerRestoreProbe
        )
    try PrimePinnedMLXMetallib
        .reverifyStagedRuntimeImage(
            of: executableURL,
            matches: runtime,
            runtimeRole:
                .typedOptimizerRestoreProbe
        )
    let receipt =
        PrimeTypedOptimizerRestoreReceipt(
            outcome: .exactTypedRestore,
            recordedAtUTC:
                ISO8601DateFormatter()
                .string(from: Date()),
            primeSourceSnapshot:
                sourceSnapshotBinding,
            runtimeImage: runtime,
            controlRecord:
                controlExit.record,
            writerRecord:
                writerExit.record,
            restorerRecord:
                restorerExit.record,
            workers:
                [control, writer, restorer],
            processTranscript: [
                controlExit,
                writerExit,
                restorerExit,
            ],
            mutationSweep: mutations
        )
    currentParentFailureStage =
        .finalValidation
    try receipt.validate(in: root)
    let binding = try root.publishCanonical(
        receipt,
        at: arguments.receiptPath
    )
    let replayed = try root.decodeVerified(
        PrimeTypedOptimizerRestoreReceipt.self,
        binding: binding
    )
    guard replayed == receipt else {
        throw ProbeError.receiptRoundTripMismatch
    }
    try replayed.validate(in: root)
    print(
        "EXACT_TYPED_RESTORE receipt_sha256=\(binding.sha256)"
    )
}

private func publishFailureReceipt(
    error: Error,
    arguments: Arguments,
    root: PrimeArtifactRoot
) {
    let candidates: [
        (String, PrimeArtifactPurpose)
    ] = [
        (stagedExecutablePath, .executable),
        (runtimeBindingPath, .immutableData),
        (
            PrimePinnedMLXMetallib
                .artifactRelativePath,
            .immutableData
        ),
        (
            PrimePinnedMLXMetallib
                .infoPlistArtifactRelativePath,
            .immutableData
        ),
        (sourceSnapshotPath, .immutableData),
        (controlRecordPath, .immutableData),
        (writerRecordPath, .immutableData),
        (restorerRecordPath, .immutableData),
        (
            "\(evidenceDirectory)/Package.swift",
            .immutableData
        ),
        (
            "\(evidenceDirectory)/Package.resolved",
            .immutableData
        ),
        (
            "\(evidenceDirectory)/mirrors.json",
            .immutableData
        ),
        (
            "\(dependencyEvidenceDirectory)/LICENSE",
            .immutableData
        ),
        (
            dependencyTreeEvidencePath,
            .immutableData
        ),
        (
            "\(dependencyEvidenceDirectory)/AdamOptimizerState.swift",
            .immutableData
        ),
        (
            "\(dependencyEvidenceDirectory)/Optimizers.swift",
            .immutableData
        ),
    ] + PrimeTypedOptimizerFixture
        .allCases.flatMap {
            [
                (
                    modelCheckpointPath($0),
                    PrimeArtifactPurpose
                        .immutableData
                ),
                (
                    optimizerCheckpointPath($0),
                    PrimeArtifactPurpose
                        .immutableData
                ),
            ]
        }
    let available = candidates.compactMap {
        path, purpose in
        try? root.bindExisting(
            at: path,
            purpose: purpose,
            maximumByteCount:
                purpose == .executable
                ? 256 * 1024 * 1024
                : 128 * 1024 * 1024
        )
    }.sorted {
        $0.relativePath < $1.relativePath
    }
    let identity = failureIdentity(error)
    let failure =
        PrimeTypedOptimizerRestoreFailureReceipt(
            recordedAtUTC:
                ISO8601DateFormatter()
                .string(from: Date()),
            stage: currentParentFailureStage,
            reasonCode: identity.reasonCode,
            failureDetailSHA256:
                identity.detailSHA256,
            availableArtifacts: available
        )
    do {
        try failure.validate(in: root)
        let binding = try root.publishCanonical(
            failure,
            at:
                arguments.receiptPath
                + ".abstain.json"
        )
        let replayed = try root.decodeVerified(
            PrimeTypedOptimizerRestoreFailureReceipt
                .self,
            binding: binding
        )
        guard replayed == failure else {
            throw ProbeError
                .receiptRoundTripMismatch
        }
        try replayed.validate(in: root)
        FileHandle.standardError.write(
            Data(
                "ABSTAIN receipt_sha256=\(binding.sha256)\n"
                    .utf8
            )
        )
    } catch {
        FileHandle.standardError.write(
            Data(
                "ABSTAIN receipt publication failed\n"
                    .utf8
            )
        )
    }
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
private struct PrimeTypedOptimizerRestoreProbeMain {
    static func main() {
        var parsedArguments: Arguments?
        do {
            _ = try
                PrimeMLXRuntimeEnvironmentPolicy
                .validateCurrentProcess()
            _ = try
                PrimeReleaseInstrumentationAdmissionPolicy
                .validateCurrentProcess()
            let arguments = try parseArguments()
            parsedArguments = arguments
            let root = try PrimeArtifactRoot(
                directoryURL:
                    arguments.artifactRoot!
            )
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
            let permitsFailureReceipt =
                (error as? ProbeError)?
                .permitsFailureReceipt
                ?? true
            if permitsFailureReceipt,
               let arguments = parsedArguments,
               arguments.role == .parent,
               let root = try? PrimeArtifactRoot(
                   directoryURL:
                       arguments.artifactRoot!
               ) {
                publishFailureReceipt(
                    error: error,
                    arguments: arguments,
                    root: root
                )
            }
            FileHandle.standardError.write(
                Data(
                    "Prime typed optimizer restore failed reason_code=\(identity.reasonCode) detail_sha256=\(identity.detailSHA256)\n"
                        .utf8
                )
            )
            exit(2)
        }
    }
}
