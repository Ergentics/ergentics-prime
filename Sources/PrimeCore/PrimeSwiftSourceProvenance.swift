#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif
import Foundation

public enum PrimeSwiftSourceProvenanceError:
    Error,
    Equatable,
    Sendable
{
    case unsafeSourceFile(String)
    case incompleteSourceSnapshot
    case sourceIdentityMismatch(
        expected: String,
        observed: String
    )
    case releaseBuildRequired(String)
}

extension PrimeSwiftSourceProvenanceError:
    LocalizedError
{
    public var errorDescription: String? {
        switch self {
        case let .unsafeSourceFile(path):
            return "source snapshot rejected unsafe file: \(path)"
        case .incompleteSourceSnapshot:
            return "source snapshot is incomplete"
        case let .sourceIdentityMismatch(
            expected,
            observed
        ):
            return "running binary/source identity mismatch " +
                "expected=\(expected) observed=\(observed)"
        case let .releaseBuildRequired(configuration):
            return "source provenance requires a release " +
                "binary; observed \(configuration)"
        }
    }
}

public struct PrimeSwiftSourceFileSnapshot:
    Codable,
    Equatable,
    Sendable
{
    public let relativePath: String
    public let sha256: String
    public let byteCount: UInt64
    public let contents: Data

    public init(
        relativePath: String,
        sha256: String,
        byteCount: UInt64,
        contents: Data
    ) {
        self.relativePath = relativePath
        self.sha256 = sha256
        self.byteCount = byteCount
        self.contents = contents
    }

    private enum CodingKeys: String, CodingKey {
        case relativePath = "relative_path"
        case sha256
        case byteCount = "byte_count"
        case contents
    }
}

public struct PrimeSwiftSourceSnapshot:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let artifactKind: String
    public let sourceIdentitySHA256: String
    public let embeddedSourceIdentitySHA256: String
    public let buildConfiguration: String
    public let files: [PrimeSwiftSourceFileSnapshot]

    public init(
        sourceIdentitySHA256: String,
        embeddedSourceIdentitySHA256: String,
        buildConfiguration: String,
        files: [PrimeSwiftSourceFileSnapshot]
    ) {
        schemaVersion =
            PrimeSwiftSourceProvenance.snapshotSchemaVersion
        artifactKind =
            PrimeSwiftSourceProvenance.snapshotArtifactKind
        self.sourceIdentitySHA256 =
            sourceIdentitySHA256
        self.embeddedSourceIdentitySHA256 =
            embeddedSourceIdentitySHA256
        self.buildConfiguration = buildConfiguration
        self.files = files
    }

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

struct PrimeSwiftSourceProvenanceExpectation:
    Equatable,
    Sendable
{
    let sourceIdentitySHA256: String
    let buildConfiguration: String
}

private struct PrimeSwiftSourceIdentityRecord:
    Codable
{
    let relativePath: String
    let sha256: String
    let byteCount: UInt64

    private enum CodingKeys: String, CodingKey {
        case relativePath = "relative_path"
        case sha256
        case byteCount = "byte_count"
    }
}

/// Closed authority tokens for historical Prime Release snapshots that remain
/// prerequisites of a current receipt contract.
///
/// This deliberately has no raw-value conformance, associated value, or
/// public initializer. Callers can select an admitted historical source, but
/// cannot turn an artifact-supplied digest into a new authority token.
public enum PrimePinnedHistoricalReleaseSource:
    Sendable
{
    case nativeGenerationContractProjection20260730
    case nativeFullCorpusReplay20260730
    case nativeNeuralGateContractProjection20260730

    public var sourceIdentitySHA256:
        String
    {
        switch self {
        case
            .nativeGenerationContractProjection20260730:
            "a634994a9aedb2803b61353ffd30f0fcd0f1bad4356ce738f7d150f3cd08d2fb"
        case .nativeFullCorpusReplay20260730:
            "d13a817e2918e94972174b78eb1372dd0d4395161fca08b63850e7c2bfbbb08f"
        case
            .nativeNeuralGateContractProjection20260730:
            "c2a144054544b9db68a3765ed3068430cb2ccd284e6477cd6ece26220a8a6091"
        }
    }
}

public enum PrimeSwiftSourceProvenance {
    public static let snapshotSchemaVersion = 1
    public static let snapshotArtifactKind =
        "ergentics_prime_swift_source_snapshot"
    public static let embeddedProvenanceRelativePath =
        "Sources/PrimeCore/" +
        "PrimeEmbeddedBuildProvenance.swift"

    private static let fixedRelativePaths = [
        ".gitignore",
        ".swiftpm/configuration/mirrors.json",
        "Tests/PrimeTypedOptimizerRestoreMechanicsValidation/.swiftpm/configuration/mirrors.json",
        "Tests/PrimeNativeNeuralGateMLXValidation/.swiftpm/configuration/mirrors.json",
        "Tests/PrimeValidationWorkflow/.swiftpm/configuration/mirrors.json",
        "LICENSE",
        "Package.swift",
        "Package.resolved",
        "README.md",
        "THIRD_PARTY_NOTICES.md",
    ]
    private static let recursiveDirectoryRelativePaths = [
        "Sources",
        "Tests",
        "docs",
    ]
    private static let maximumSourceFileBytes:
        Int64 = 8 * 1024 * 1024
    static let maximumSnapshotFileCount = 4_096
    static let maximumSnapshotDirectoryCount =
        4_096
    static let maximumSnapshotAggregateBytes:
        UInt64 = 512 * 1024 * 1024
    static let maximumSnapshotRelativeDepth = 32

    public static func capture(
        at sourceRoot: URL,
        requiredRelativePaths: Set<String> = []
    ) throws -> PrimeSwiftSourceSnapshot {
        try capture(
            at: sourceRoot,
            requiredRelativePaths:
                requiredRelativePaths,
            expectation:
                embeddedExpectation
        )
    }

    public static func validate(
        _ snapshot: PrimeSwiftSourceSnapshot,
        requiredRelativePaths: Set<String> = []
    ) throws {
        try validate(
            snapshot,
            requiredRelativePaths:
                requiredRelativePaths,
            expectation:
                embeddedExpectation
        )
    }

    /// Validates a current complete Release snapshot against the source
    /// identity embedded in PrimeCore. Callers cannot supply the expectation
    /// or promote an artifact-provided digest to authority.
    public static func validateReleaseEvidence(
        _ snapshot: PrimeSwiftSourceSnapshot,
        requiredRelativePaths: Set<String> = []
    ) throws {
        try validate(
            snapshot,
            requiredRelativePaths:
                requiredRelativePaths,
            expectation:
                embeddedReleaseEvidenceExpectation
        )
    }

    /// Validates a historical Release snapshot against a closed identity pin.
    ///
    /// The snapshot never supplies its own authority. Parent-specific receipt
    /// validators must still authenticate the exact receipt, Git state, and
    /// snapshot binding before invoking this mechanics-only validator.
    public static func validatePinnedReleaseEvidence(
        _ snapshot: PrimeSwiftSourceSnapshot,
        requiredRelativePaths: Set<String> = [],
        pin: PrimePinnedHistoricalReleaseSource
    ) throws {
        try validate(
            snapshot,
            requiredRelativePaths:
                requiredRelativePaths,
            expectation:
                PrimeSwiftSourceProvenanceExpectation(
                    sourceIdentitySHA256:
                        pin.sourceIdentitySHA256,
                    buildConfiguration: "release"
                )
        )
    }

    static var embeddedReleaseEvidenceExpectation:
        PrimeSwiftSourceProvenanceExpectation
    {
        PrimeSwiftSourceProvenanceExpectation(
            sourceIdentitySHA256:
                PrimeEmbeddedBuildProvenance
                .sourceIdentitySHA256,
            buildConfiguration: "release"
        )
    }

    static func capture(
        at sourceRoot: URL,
        requiredRelativePaths: Set<String>,
        expectation:
            PrimeSwiftSourceProvenanceExpectation
    ) throws -> PrimeSwiftSourceSnapshot {
        let root = sourceRoot.standardizedFileURL
        let rootPrefix = root.path + "/"
        var urls = fixedRelativePaths.map {
            root.appendingPathComponent($0)
        }
        var aggregateBytes: UInt64 = 0
        var directoryCount =
            recursiveDirectoryRelativePaths.count
        guard urls.count
                <= maximumSnapshotFileCount
        else {
            throw PrimeSwiftSourceProvenanceError
                .incompleteSourceSnapshot
        }
        for (relativePath, url) in zip(
            fixedRelativePaths,
            urls
        ) {
            var metadata = stat()
            guard relativePath.split(
                separator: "/"
            ).count
                <= maximumSnapshotRelativeDepth,
            lstat(
                url.path,
                &metadata
            ) == 0,
            metadata.st_mode & S_IFMT
                == S_IFREG,
            metadata.st_size >= 0,
            metadata.st_size
                <= maximumSourceFileBytes
            else {
                throw PrimeSwiftSourceProvenanceError
                    .unsafeSourceFile(
                        relativePath
                    )
            }
            let next =
                aggregateBytes
                .addingReportingOverflow(
                    UInt64(metadata.st_size)
                )
            guard !next.overflow,
                  next.partialValue
                    <= maximumSnapshotAggregateBytes
            else {
                throw PrimeSwiftSourceProvenanceError
                    .incompleteSourceSnapshot
            }
            aggregateBytes = next.partialValue
        }
        for directory in
            recursiveDirectoryRelativePaths
        {
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
                throw PrimeSwiftSourceProvenanceError
                    .incompleteSourceSnapshot
            }
            for case let fileURL as URL in enumerator {
                var metadata = stat()
                guard lstat(
                    fileURL.path,
                    &metadata
                ) == 0 else {
                    throw PrimeSwiftSourceProvenanceError
                        .unsafeSourceFile(fileURL.path)
                }
                if metadata.st_mode & S_IFMT
                    == S_IFDIR
                {
                    directoryCount += 1
                    guard directoryCount
                            <= maximumSnapshotDirectoryCount,
                          fileURL.path
                            .dropFirst(
                                rootPrefix.count
                            )
                            .split(
                                separator: "/"
                            ).count
                            <= maximumSnapshotRelativeDepth
                    else {
                        throw PrimeSwiftSourceProvenanceError
                            .incompleteSourceSnapshot
                    }
                    continue
                }
                guard metadata.st_mode & S_IFMT
                    == S_IFREG,
                    metadata.st_size >= 0,
                    metadata.st_size
                        <= maximumSourceFileBytes,
                    urls.count + 1
                        <= maximumSnapshotFileCount,
                    fileURL.path
                        .dropFirst(
                            rootPrefix.count
                        )
                        .split(
                            separator: "/"
                        ).count
                        <= maximumSnapshotRelativeDepth
                else {
                    throw PrimeSwiftSourceProvenanceError
                        .unsafeSourceFile(fileURL.path)
                }
                let next =
                    aggregateBytes
                    .addingReportingOverflow(
                        UInt64(
                            metadata.st_size
                        )
                    )
                guard !next.overflow,
                      next.partialValue
                        <= maximumSnapshotAggregateBytes
                else {
                    throw PrimeSwiftSourceProvenanceError
                        .incompleteSourceSnapshot
                }
                aggregateBytes =
                    next.partialValue
                urls.append(fileURL)
            }
        }

        var files = [PrimeSwiftSourceFileSnapshot]()
        var observedPaths = Set<String>()
        var actualReadAggregateBytes: UInt64 = 0
        for url in urls {
            let standardized =
                url.standardizedFileURL
            guard standardized.path.hasPrefix(
                rootPrefix
            ) else {
                throw PrimeSwiftSourceProvenanceError
                    .unsafeSourceFile(
                        standardized.path
                    )
            }
            let relativePath = String(
                standardized.path.dropFirst(
                    rootPrefix.count
                )
            )
            guard observedPaths
                .insert(relativePath).inserted
            else {
                throw PrimeSwiftSourceProvenanceError
                    .unsafeSourceFile(relativePath)
            }
            let data = try regularFileData(
                at: standardized
            )
            let nextActualReadAggregate =
                actualReadAggregateBytes
                .addingReportingOverflow(
                    UInt64(data.count)
                )
            guard !nextActualReadAggregate
                    .overflow,
                  nextActualReadAggregate
                    .partialValue
                    <= maximumSnapshotAggregateBytes
            else {
                throw PrimeSwiftSourceProvenanceError
                    .incompleteSourceSnapshot
            }
            actualReadAggregateBytes =
                nextActualReadAggregate
                .partialValue
            files.append(
                PrimeSwiftSourceFileSnapshot(
                    relativePath: relativePath,
                    sha256:
                        PrimeSHA256.hexDigest(of: data),
                    byteCount: UInt64(data.count),
                    contents: data
                )
            )
        }
        files.sort {
            $0.relativePath < $1.relativePath
        }

        let observedIdentity =
            try sourceIdentitySHA256(
                for: files
            )
        let snapshot = PrimeSwiftSourceSnapshot(
            sourceIdentitySHA256:
                observedIdentity,
            embeddedSourceIdentitySHA256:
                expectation.sourceIdentitySHA256,
            buildConfiguration:
                expectation.buildConfiguration,
            files: files
        )
        try validate(
            snapshot,
            requiredRelativePaths:
                requiredRelativePaths,
            expectation: expectation
        )
        return snapshot
    }

    static func validate(
        _ snapshot: PrimeSwiftSourceSnapshot,
        requiredRelativePaths: Set<String>,
        expectation:
            PrimeSwiftSourceProvenanceExpectation
    ) throws {
        guard snapshot.schemaVersion
                == snapshotSchemaVersion,
              snapshot.artifactKind
                == snapshotArtifactKind
        else {
            throw PrimeSwiftSourceProvenanceError
                .incompleteSourceSnapshot
        }
        let paths = snapshot.files.map(\.relativePath)
        guard paths == paths.sorted(),
              Set(paths).count == paths.count
        else {
            throw PrimeSwiftSourceProvenanceError
                .unsafeSourceFile(
                    "<source-snapshot-order>"
                )
        }
        let admittedFixedPaths =
            Set(fixedRelativePaths)
        for file in snapshot.files {
            guard isAdmitted(
                file.relativePath,
                fixedPaths: admittedFixedPaths
            ) else {
                throw PrimeSwiftSourceProvenanceError
                    .unsafeSourceFile(
                        file.relativePath
                    )
            }
            guard file.contents.count
                    <= maximumSourceFileBytes,
                  file.byteCount
                    == UInt64(file.contents.count),
                  file.sha256
                    == PrimeSHA256.hexDigest(
                        of: file.contents
                    )
            else {
                throw PrimeSwiftSourceProvenanceError
                    .unsafeSourceFile(
                        file.relativePath
                    )
            }
        }

        let observedPaths = Set(paths)
        let requiredPaths =
            admittedFixedPaths
                .union([
                    embeddedProvenanceRelativePath,
                ])
                .union(requiredRelativePaths)
        guard requiredPaths.allSatisfy({
            observedPaths.contains($0)
        }) else {
            throw PrimeSwiftSourceProvenanceError
                .incompleteSourceSnapshot
        }
        guard requiredRelativePaths.allSatisfy({
            isAdmitted(
                $0,
                fixedPaths: admittedFixedPaths
            )
        }) else {
            throw PrimeSwiftSourceProvenanceError
                .unsafeSourceFile(
                    "<required-source-path>"
                )
        }

        let observedIdentity =
            try sourceIdentitySHA256(
                for: snapshot.files
            )
        guard snapshot.sourceIdentitySHA256
                == observedIdentity
        else {
            throw PrimeSwiftSourceProvenanceError
                .sourceIdentityMismatch(
                    expected:
                        snapshot.sourceIdentitySHA256,
                    observed: observedIdentity
                )
        }
        guard snapshot
                .embeddedSourceIdentitySHA256
                == expectation
                .sourceIdentitySHA256
        else {
            throw PrimeSwiftSourceProvenanceError
                .sourceIdentityMismatch(
                    expected:
                        expectation
                        .sourceIdentitySHA256,
                    observed:
                        snapshot
                        .embeddedSourceIdentitySHA256
                )
        }
        guard let embeddedFile =
                snapshot.files.first(where: {
                    $0.relativePath
                        == embeddedProvenanceRelativePath
                }),
              embeddedFile.contents
                == canonicalEmbeddedProvenanceSource(
                    sourceIdentitySHA256:
                        expectation
                        .sourceIdentitySHA256
                )
        else {
            throw PrimeSwiftSourceProvenanceError
                .unsafeSourceFile(
                    embeddedProvenanceRelativePath
                )
        }
        guard observedIdentity
                == expectation
                .sourceIdentitySHA256
        else {
            throw PrimeSwiftSourceProvenanceError
                .sourceIdentityMismatch(
                    expected:
                        expectation
                        .sourceIdentitySHA256,
                    observed: observedIdentity
                )
        }
        guard snapshot.buildConfiguration
                == expectation.buildConfiguration
        else {
            throw PrimeSwiftSourceProvenanceError
                .unsafeSourceFile(
                    "<build-configuration>"
                )
        }
        guard expectation.buildConfiguration
                == "release"
        else {
            throw PrimeSwiftSourceProvenanceError
                .releaseBuildRequired(
                    expectation.buildConfiguration
                )
        }
    }

    static func canonicalEmbeddedProvenanceSource(
        sourceIdentitySHA256: String
    ) -> Data {
        let lines = [
            "public enum PrimeEmbeddedBuildProvenance {",
            "    #if DEBUG",
            "        public static let buildConfiguration = \"debug\"",
            "    #else",
            "        public static let buildConfiguration = \"release\"",
            "    #endif",
            "",
            "    // This file is excluded only to avoid a self-referential digest. Runtime",
            "    // verification requires this exact canonical template and digest; every",
            "    // other admitted package, source, test, and architecture file is hashed.",
            "    public static let sourceIdentitySHA256 =",
            "        \"\(sourceIdentitySHA256)\"",
            "}",
            "",
        ]
        return Data(lines.joined(separator: "\n").utf8)
    }

    private static var embeddedExpectation:
        PrimeSwiftSourceProvenanceExpectation
    {
        PrimeSwiftSourceProvenanceExpectation(
            sourceIdentitySHA256:
                PrimeEmbeddedBuildProvenance
                .sourceIdentitySHA256,
            buildConfiguration:
                PrimeEmbeddedBuildProvenance
                .buildConfiguration
        )
    }

    private static func sourceIdentitySHA256(
        for files: [PrimeSwiftSourceFileSnapshot]
    ) throws -> String {
        let records = files
            .filter {
                $0.relativePath
                    != embeddedProvenanceRelativePath
            }
            .map {
                PrimeSwiftSourceIdentityRecord(
                    relativePath: $0.relativePath,
                    sha256: $0.sha256,
                    byteCount: $0.byteCount
                )
            }
        return PrimeSHA256.hexDigest(
            of: try PrimeCanonicalJSON.encode(records)
        )
    }

    private static func isAdmitted(
        _ relativePath: String,
        fixedPaths: Set<String>
    ) -> Bool {
        let components = relativePath.split(
            separator: "/",
            omittingEmptySubsequences: false
        )
        guard relativePath.hasPrefix("/") == false,
              relativePath.utf8.contains(0) == false,
              components.allSatisfy({
                  $0.isEmpty == false
                      && $0 != "."
                      && $0 != ".."
              })
        else {
            return false
        }
        if fixedPaths.contains(relativePath) {
            return true
        }
        return recursiveDirectoryRelativePaths
            .contains {
                relativePath.hasPrefix($0 + "/")
                    && relativePath.count
                        > $0.count + 1
            }
    }

    private static func regularFileData(
        at url: URL
    ) throws -> Data {
        let descriptor = open(
            url.path,
            O_RDONLY | O_NOFOLLOW | O_CLOEXEC
        )
        guard descriptor >= 0 else {
            throw PrimeSwiftSourceProvenanceError
                .unsafeSourceFile(url.path)
        }
        defer {
            _ = close(descriptor)
        }
        var before = stat()
        guard fstat(descriptor, &before) == 0,
              before.st_mode & S_IFMT == S_IFREG,
              before.st_nlink == 1,
              before.st_size >= 0,
              before.st_size
                <= maximumSourceFileBytes
        else {
            throw PrimeSwiftSourceProvenanceError
                .unsafeSourceFile(url.path)
        }
        var data = Data()
        data.reserveCapacity(Int(before.st_size))
        var buffer = [UInt8](
            repeating: 0,
            count: 64 * 1024
        )
        while true {
            let count =
                buffer.withUnsafeMutableBytes {
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
                throw PrimeSwiftSourceProvenanceError
                    .unsafeSourceFile(url.path)
            }
            if count == 0 {
                break
            }
            data.append(
                contentsOf: buffer[0 ..< count]
            )
            guard data.count
                <= maximumSourceFileBytes
            else {
                throw PrimeSwiftSourceProvenanceError
                    .unsafeSourceFile(url.path)
            }
        }
        var after = stat()
        guard fstat(descriptor, &after) == 0,
              before.st_dev == after.st_dev,
              before.st_ino == after.st_ino,
              before.st_size == after.st_size,
              data.count == Int(after.st_size)
        else {
            throw PrimeSwiftSourceProvenanceError
                .unsafeSourceFile(url.path)
        }
        return data
    }
}
