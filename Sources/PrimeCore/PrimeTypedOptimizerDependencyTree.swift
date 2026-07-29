#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif
import Foundation

public struct PrimeTypedOptimizerDependencyTreeEntry:
    Codable,
    Equatable,
    Sendable
{
    public let relativePath: String
    public let sha256: String
    public let byteCount: UInt64

    public init(
        relativePath: String,
        sha256: String,
        byteCount: UInt64
    ) {
        self.relativePath = relativePath
        self.sha256 = sha256
        self.byteCount = byteCount
    }

    private enum CodingKeys: String, CodingKey {
        case relativePath = "relative_path"
        case sha256
        case byteCount = "byte_count"
    }
}

/// Canonical evidence for the complete admitted MLX Swift package
/// manifest/source-tree superset used by Prime's typed optimizer experiment.
///
/// The scope intentionally includes the dependency Package.swift and every
/// regular file below Source. It is stricter than SwiftPM's platform-specific
/// target selection: an unreviewed source-tree addition or mutation fails the
/// gate even when the current platform would exclude that file.
public struct PrimeTypedOptimizerDependencyTreeEvidence:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let artifactKind: String
    public let scopeID: String
    public let treeSHA256: String
    public let fileCount: Int
    public let totalByteCount: UInt64
    public let entries:
        [PrimeTypedOptimizerDependencyTreeEntry]

    public init(
        treeSHA256: String,
        fileCount: Int,
        totalByteCount: UInt64,
        entries:
            [PrimeTypedOptimizerDependencyTreeEntry]
    ) {
        schemaVersion = 1
        artifactKind =
            "prime_typed_optimizer_mlx_swift_dependency_tree"
        scopeID =
            "package_manifest_plus_complete_source_tree_v1"
        self.treeSHA256 = treeSHA256
        self.fileCount = fileCount
        self.totalByteCount = totalByteCount
        self.entries = entries
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case artifactKind = "artifact_kind"
        case scopeID = "scope_id"
        case treeSHA256 = "tree_sha256"
        case fileCount = "file_count"
        case totalByteCount = "total_byte_count"
        case entries
    }
}

public enum PrimeTypedOptimizerDependencyTreeError:
    Error,
    Equatable,
    Sendable
{
    case unsafeRoot(String)
    case unsafePath(String)
    case unsafeFile(String)
    case incompleteTree
    case treeTooLarge
    case frozenTreeMismatch(
        expectedSHA256: String,
        observedSHA256: String,
        expectedFileCount: Int,
        observedFileCount: Int,
        expectedByteCount: UInt64,
        observedByteCount: UInt64
    )
}

public enum PrimeTypedOptimizerDependencyTree {
    public static let swiftPackageIdentity =
        "ergentics-mlx-swift"
    public static let checkoutDirectoryName =
        swiftPackageIdentity
    public static let expectedTreeSHA256 =
        "ef4e3c57d3c24bdc5705be78bdf60b630d84ab7bbbd9affc1faa41137b4ead43"
    public static let expectedFileCount = 1_667
    public static let expectedTotalByteCount:
        UInt64 = 21_822_344

    private static let maximumFileCount = 5_000
    private static let maximumFileByteCount:
        UInt64 = 8 * 1024 * 1024
    private static let maximumTotalByteCount:
        UInt64 = 256 * 1024 * 1024

    public static func capture(
        at checkoutRoot: URL
    ) throws
        -> PrimeTypedOptimizerDependencyTreeEvidence
    {
        let root =
            checkoutRoot.standardizedFileURL
        guard root.isFileURL else {
            throw PrimeTypedOptimizerDependencyTreeError
                .unsafeRoot(root.absoluteString)
        }
        try requireTrustedDirectory(root)

        let packageManifest =
            root.appendingPathComponent(
                "Package.swift"
            )
        let sourceRoot =
            root.appendingPathComponent(
                "Source",
                isDirectory: true
            )
        try requireTrustedDirectory(sourceRoot)

        var files = [packageManifest]
        guard let enumerator =
                FileManager.default.enumerator(
                    at: sourceRoot,
                    includingPropertiesForKeys: nil,
                    options: []
                ) else {
            throw PrimeTypedOptimizerDependencyTreeError
                .incompleteTree
        }
        for case let candidate as URL in enumerator {
            var metadata = stat()
            guard lstat(
                candidate.path,
                &metadata
            ) == 0 else {
                throw PrimeTypedOptimizerDependencyTreeError
                    .unsafePath(candidate.path)
            }
            if candidate.lastPathComponent
                == ".git"
            {
                switch metadata.st_mode
                    & mode_t(S_IFMT)
                {
                case mode_t(S_IFDIR):
                    try requireTrustedDirectory(
                        candidate
                    )
                    enumerator.skipDescendants()
                case mode_t(S_IFREG):
                    try requireTrustedMetadataFile(
                        candidate,
                        metadata: metadata
                    )
                default:
                    enumerator.skipDescendants()
                    throw PrimeTypedOptimizerDependencyTreeError
                        .unsafePath(candidate.path)
                }
                continue
            }
            switch metadata.st_mode & mode_t(S_IFMT) {
            case mode_t(S_IFDIR):
                try requireTrustedDirectory(
                    candidate
                )
            case mode_t(S_IFREG):
                files.append(candidate)
            default:
                enumerator.skipDescendants()
                throw PrimeTypedOptimizerDependencyTreeError
                    .unsafePath(candidate.path)
            }
            guard files.count <= maximumFileCount
            else {
                throw PrimeTypedOptimizerDependencyTreeError
                    .treeTooLarge
            }
        }

        let rootPrefix = root.path + "/"
        var entries =
            [PrimeTypedOptimizerDependencyTreeEntry]()
        var totalByteCount: UInt64 = 0
        var observedPaths = Set<String>()
        for file in files {
            let standardized =
                file.standardizedFileURL
            guard standardized.path.hasPrefix(
                rootPrefix
            ) else {
                throw PrimeTypedOptimizerDependencyTreeError
                    .unsafePath(standardized.path)
            }
            let relativePath = String(
                standardized.path.dropFirst(
                    rootPrefix.count
                )
            )
            guard isAdmitted(relativePath),
                  observedPaths.insert(
                      relativePath
                  ).inserted else {
                throw PrimeTypedOptimizerDependencyTreeError
                    .unsafePath(relativePath)
            }
            let data = try readTrustedFile(
                standardized
            )
            let byteCount = UInt64(data.count)
            let (nextTotal, overflow) =
                totalByteCount.addingReportingOverflow(
                    byteCount
                )
            guard !overflow,
                  nextTotal
                    <= maximumTotalByteCount else {
                throw PrimeTypedOptimizerDependencyTreeError
                    .treeTooLarge
            }
            totalByteCount = nextTotal
            entries.append(
                PrimeTypedOptimizerDependencyTreeEntry(
                    relativePath: relativePath,
                    sha256:
                        PrimeSHA256.hexDigest(
                            of: data
                        ),
                    byteCount: byteCount
                )
            )
        }
        entries.sort {
            $0.relativePath < $1.relativePath
        }
        let treeSHA256 =
            PrimeSHA256.hexDigest(
                of:
                    try PrimeCanonicalJSON
                    .encode(entries)
            )
        let evidence =
            PrimeTypedOptimizerDependencyTreeEvidence(
                treeSHA256: treeSHA256,
                fileCount: entries.count,
                totalByteCount: totalByteCount,
                entries: entries
            )
        try validateStructure(evidence)
        return evidence
    }

    public static func validateFrozen(
        _ evidence:
            PrimeTypedOptimizerDependencyTreeEvidence
    ) throws {
        try validateStructure(evidence)
        guard evidence.treeSHA256
                == expectedTreeSHA256,
              evidence.fileCount
                == expectedFileCount,
              evidence.totalByteCount
                == expectedTotalByteCount else {
            throw PrimeTypedOptimizerDependencyTreeError
                .frozenTreeMismatch(
                    expectedSHA256:
                        expectedTreeSHA256,
                    observedSHA256:
                        evidence.treeSHA256,
                    expectedFileCount:
                        expectedFileCount,
                    observedFileCount:
                        evidence.fileCount,
                    expectedByteCount:
                        expectedTotalByteCount,
                    observedByteCount:
                        evidence.totalByteCount
                )
        }
    }

    public static func validateStructure(
        _ evidence:
            PrimeTypedOptimizerDependencyTreeEvidence
    ) throws {
        guard evidence.schemaVersion == 1,
              evidence.artifactKind
                == "prime_typed_optimizer_mlx_swift_dependency_tree",
              evidence.scopeID
                == "package_manifest_plus_complete_source_tree_v1",
              !evidence.entries.isEmpty,
              evidence.entries.count
                <= maximumFileCount,
              evidence.fileCount
                == evidence.entries.count,
              evidence.entries.map(\.relativePath)
                == evidence.entries.map(
                    \.relativePath
                ).sorted(),
              Set(
                  evidence.entries.map(
                      \.relativePath
                  )
              ).count == evidence.entries.count,
              evidence.entries.first?
                .relativePath == "Package.swift"
        else {
            throw PrimeTypedOptimizerDependencyTreeError
                .incompleteTree
        }
        var totalByteCount: UInt64 = 0
        for entry in evidence.entries {
            guard isAdmitted(
                entry.relativePath
            ),
                entry.byteCount
                    <= maximumFileByteCount,
                isSHA256(entry.sha256)
            else {
                throw PrimeTypedOptimizerDependencyTreeError
                    .unsafePath(
                        entry.relativePath
                    )
            }
            let (nextTotal, overflow) =
                totalByteCount.addingReportingOverflow(
                    entry.byteCount
                )
            guard !overflow,
                  nextTotal
                    <= maximumTotalByteCount else {
                throw PrimeTypedOptimizerDependencyTreeError
                    .treeTooLarge
            }
            totalByteCount = nextTotal
        }
        guard totalByteCount
                == evidence.totalByteCount,
              PrimeSHA256.hexDigest(
                  of:
                      try PrimeCanonicalJSON
                      .encode(evidence.entries)
              ) == evidence.treeSHA256 else {
            throw PrimeTypedOptimizerDependencyTreeError
                .incompleteTree
        }
    }

    private static func isAdmitted(
        _ relativePath: String
    ) -> Bool {
        guard !relativePath.isEmpty,
              !relativePath.hasPrefix("/"),
              !relativePath.contains("\\"),
              !relativePath.split(
                  separator: "/",
                  omittingEmptySubsequences: false
              ).contains(where: {
                  $0.isEmpty
                      || $0 == "."
                      || $0 == ".."
                      || $0 == ".git"
              }) else {
            return false
        }
        return relativePath == "Package.swift"
            || relativePath.hasPrefix("Source/")
    }

    private static func requireTrustedDirectory(
        _ url: URL
    ) throws {
        var metadata = stat()
        guard lstat(url.path, &metadata) == 0,
              metadata.st_mode & mode_t(S_IFMT)
                == mode_t(S_IFDIR),
              metadata.st_uid == geteuid(),
              metadata.st_mode & mode_t(0o022)
                == 0,
              metadata.st_mode & mode_t(0o7000)
                == 0 else {
            throw PrimeTypedOptimizerDependencyTreeError
                .unsafeRoot(url.path)
        }
    }

    private static func requireTrustedMetadataFile(
        _ url: URL,
        metadata: stat
    ) throws {
        guard metadata.st_mode & mode_t(S_IFMT)
                == mode_t(S_IFREG),
              metadata.st_uid == geteuid(),
              metadata.st_nlink == 1,
              metadata.st_size >= 0,
              UInt64(metadata.st_size)
                <= maximumFileByteCount,
              metadata.st_mode & mode_t(0o022)
                == 0,
              metadata.st_mode & mode_t(0o7000)
                == 0 else {
            throw PrimeTypedOptimizerDependencyTreeError
                .unsafeFile(url.path)
        }
    }

    private static func readTrustedFile(
        _ url: URL
    ) throws -> Data {
        let descriptor = url.path.withCString {
            open(
                $0,
                O_RDONLY | O_NOFOLLOW | O_CLOEXEC
            )
        }
        guard descriptor >= 0 else {
            throw PrimeTypedOptimizerDependencyTreeError
                .unsafeFile(url.path)
        }
        defer {
            _ = close(descriptor)
        }
        var before = stat()
        guard fstat(descriptor, &before) == 0,
              before.st_mode & mode_t(S_IFMT)
                == mode_t(S_IFREG),
              before.st_uid == geteuid(),
              before.st_nlink == 1,
              before.st_size >= 0,
              UInt64(before.st_size)
                <= maximumFileByteCount,
              before.st_mode & mode_t(0o022)
                == 0,
              before.st_mode & mode_t(0o7000)
                == 0 else {
            throw PrimeTypedOptimizerDependencyTreeError
                .unsafeFile(url.path)
        }

        var data = Data()
        data.reserveCapacity(Int(before.st_size))
        var buffer = [UInt8](
            repeating: 0,
            count: 64 * 1024
        )
        while true {
            let count = buffer
                .withUnsafeMutableBytes {
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
                throw PrimeTypedOptimizerDependencyTreeError
                    .unsafeFile(url.path)
            }
            if count == 0 {
                break
            }
            data.append(
                contentsOf: buffer[0 ..< count]
            )
            guard UInt64(data.count)
                    <= maximumFileByteCount else {
                throw PrimeTypedOptimizerDependencyTreeError
                    .treeTooLarge
            }
        }
        var after = stat()
        guard fstat(descriptor, &after) == 0,
              before.st_dev == after.st_dev,
              before.st_ino == after.st_ino,
              before.st_size == after.st_size,
              before.st_uid == after.st_uid,
              before.st_nlink == after.st_nlink,
              before.st_mode == after.st_mode,
              data.count == Int(after.st_size)
        else {
            throw PrimeTypedOptimizerDependencyTreeError
                .unsafeFile(url.path)
        }
        return data
    }

    private static func isSHA256(
        _ value: String
    ) -> Bool {
        value.utf8.count == 64
            && value.utf8.allSatisfy({
                ($0 >= 48 && $0 <= 57)
                    || ($0 >= 97 && $0 <= 102)
            })
    }
}
